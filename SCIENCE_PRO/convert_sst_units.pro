;+
;*****************************************************************************************
;
;  FUNCTION :   convert_sst_units.pro
;  PURPOSE  :   Converts data units for data from the SST instruments.
;
;  CALLED BY: 
;               conv_units.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATA      :  A 3DP data structure returned by get_??.pro
;               UNITS     :  A scalar string defining the units to convert to
;                              One of the following are allowed:
;                              1)  'counts'  ; => # per data bin per energy bin
;                              2)  'ncounts' ; => related to geometry factor
;                              3)  'rate'    ; => (s)
;                              4)  'nrate'   ; => (s) scaled rate
;                              5)  'eflux'   ; => energy flux
;                              6)  'flux'    ; => number flux
;                              7)  'fluxe'   ; => number flux efficiency
;                              8)  'df'      ; => distribution function units
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               SCALE     :  Set to a named variable to return the conversion factor
;                              array used to scale the data
;
;  NOTES:
;               There are two structure tag names in this routine which I cannot
;                 find anywhere in the 3DP TPLOT software (GEOM and EFF) which may
;                 be simply typos.  Regardless, this program will NOT work unless
;                 those are added to the structure before running.
;
;   CHANGED:  1)  Davin Larson changed something...       [08/22/1996   v1.0.10]
;             2)  Re-wrote and cleaned up                 [06/22/2009   v1.1.0]
;
;   CREATED:  ??/??/1995
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/22/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO convert_sst_units, data, units, SCALE=scale

;-----------------------------------------------------------------------------------------
; => Define default parameters and check input format
;-----------------------------------------------------------------------------------------
scale = 1
IF (STRUPCASE(units) EQ STRUPCASE(data.UNITS_NAME)) THEN RETURN
IF (STRUPCASE(data.UNITS_NAME) NE 'COUNTS') THEN BEGIN
  MESSAGE,'Cannot convert from '+data.UNITS_NAME+' to any other units'
  RETURN
ENDIF
units_names = ['Counts','Ncounts','Rate','Nrate','Eflux','Flux','DF']
;-----------------------------------------------------------------------------------------
; => Define relevant parameters
;-----------------------------------------------------------------------------------------
n_e      = data.NENERGY              ; => Number of energies          integer
nbins    = data.NBINS                ; => Number of bins              integer
mass     = data.MASS                 ; => Proton mass [eV/(km/sec)^2] double
energy   = data.ENERGY               ; => (eV)                        [n_e,nbins]
gf       = data.GF * data.GEOMFACTOR ; => Geometric factor            [n_e,nbins]
feff     = data.FEFF                 ; => Foil electron efficiency, for background subtracted data only
denergy  = data.DENERGY              ; => Differential energy (eV)
;-----------------------------------------------------------------------------------------
; =>  **** Note:  I cannot find this structure tag anywhere ****
geom     = data.GEOM             ; number of bins summed (nbins)
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
; =>  **** Note:  I cannot find this (EFF) structure tag anywhere ****
dt = data.EFF * data.INTEG_T  ; => (Effective duty cycle) x (integration time) [ne]
;-----------------------------------------------------------------------------------------
gf = data.GEOMFACTOR                 ; => geometric factor of smallest bin [?? is that right ??]

ndim0 = (SIZE(geom,/N_DIMENSIONS))[0]
IF (ndim0 EQ 0) THEN geom = [geom]

CASE STRUPCASE(units) OF 
  'COUNTS' :  RETURN
  'NCOUNTS':  scale =  REPLICATE(1.,n_e) # geom
  'RATE'   :  scale =  dt # REPLICATE(1.,nbins)
  'NRATE'  :  scale =  dt # geom
  'EFLUX'  :  scale = (dt # (gf * geom)) * denergy / energy
  'FLUX'   :  scale = (dt # (gf * geom)) * denergy
  'FLUXE'  :  scale = (dt # (gf * geom)) * denergy * feff
  'DF'     :  scale = (2./mass/mass*dt*1e5 # (gf * geom)) * denergy * energy
  ELSE: BEGIN
    MESSAGE,'Undefined units: ',UNITS
    RETURN
  END
ENDCASE

data.UNITS_NAME = units
tags = TAG_NAMES(data)
gtag = WHERE(tags EQ 'DDATA',gtg)
IF (gtg GT 0L) THEN data.DDATA /= scale  ; => Scale d(data) too!
data.DATA /= scale

RETURN
END
