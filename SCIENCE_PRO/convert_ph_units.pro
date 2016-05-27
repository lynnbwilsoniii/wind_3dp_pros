;+
;*****************************************************************************************
;
;  FUNCTION :   convert_ph_units.pro
;  PURPOSE  :   Converts the units of the data array of ph data structures.  The data
;                 associated with data.DATA is rescaled to the new units and
;                 data.UNITS_NAME is changed to the appropriate units.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               str_element.pro
;
;  COMMON BLOCKS: 
;               **Obsolete**
;               get_ph_com.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA      :  A 3DP PESA High data structure returned by get_ph.pro
;                              or get_phb.pro
;               UNITS     :  A scalar string defining the units to convert to
;                              One of the following are allowed:
;                              1)  'counts'  ; => # per data bin per energy bin
;                              2)  'rate'    ; => (s)
;                              3)  'crate'   ; => (s) scaled rate
;                              4)  'eflux'   ; => energy flux
;                              5)  'flux'    ; => number flux
;                              6)  'df'      ; => distribution function units
;
;  EXAMPLES:    
;               to = time_double('1995-08-09/16:00:00')
;               ph = get_ph(to[0])
;               convert_ph_units,ph,'eflux'  ; => Convert to energy flux units
;
;  KEYWORDS:    
;               DEADTIME  :  Scalar or [N,M,K]-element array specifying the "deadtime"
;                              of the instrument  [Default = 1d-6]
;                              N = # of energy bins
;                              M = # of angle bins
;                              K = # of 3DP structures in DATA
;               SCALE     :  Set to a named variable to return the conversion factor
;                              array used to scale the data
;
;   CHANGED:  1)  Frank Marcoline changed something...              [04/21/1997   v1.0.1]
;             2)  Re-wrote and cleaned up                           [06/21/2009   v1.1.0]
;             3)  Fixed a syntax error                              [06/24/2009   v1.1.1]
;             4)  Fixed syntax issue if data is an array of structures
;                                                                   [08/25/2009   v1.1.2]
;             5)  Corrected how routine addresses the issue of dead time and now it uses
;                   the correct default value of 1d-6, which was stated in the
;                   comments of the original version but never defined as such
;                                                                   [02/10/2012   v1.2.0]
;
;   NOTES:      
;               1)  MCP = mutli-channel plate
;               2)  dead time = interval during which a detector is unable to register
;                                 counts due to either preamp cycle rate limits or
;                                 the limitations of the recovery time of the channels
;                                 in the MCP
;
;  REFERENCES:  
;               1)  Wuest, M., D.S. Evans, and R. von Steiger (2007), "Calibration of
;                      Particle Instruments in Space Physics," ISSI/ESA Publications
;                      Division, Keplerlaan 1, 2200 AG Noordwijk, The Netherlands.
;                      [Chapter 4.4.5 primarily]
;               2)  Lin et al., (1995), "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125.
;               3)  See get_pmom2.pro which uses a similar approach (though different)
;
;   ADAPTED FROM:  other convert_*_units.pro procedures
;   CREATED:  ??/??/????
;   CREATED BY:  Frank Marcoline
;    LAST MODIFIED:  02/10/2012   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO convert_ph_units,data,units,DEADTIME=deadt,SCALE=scale

;-----------------------------------------------------------------------------------------
; Set common blocks:
;-----------------------------------------------------------------------------------------
;  LBW III 02/10/2012
;    Comment:  There is no need nor cross-reference to this common block, so I removed it
;
;COMMON get_ph1_com, deadtime
;-----------------------------------------------------------------------------------------
; => Define default parameters and check input format
;-----------------------------------------------------------------------------------------
IF (STRUPCASE(units) EQ STRUPCASE(data[0].UNITS_NAME)) THEN RETURN

n_e    = data[0].NENERGY           ; => Number of energies          integer
nbins  = data[0].NBINS             ; => Number of bins              integer
n_str  = N_ELEMENTS(data)          ; => Number of data structures
mass   = data[0].MASS              ; => Particle mass [eV/(km/sec)^2] double
; =>     Geometric factor            [n_e,nbins,nstr]
gf     = data.GF * data[0].GEOMFACTOR
energy = data.ENERGY               ; => (eV)                        [n_e,nbins]
dt     = data.DT                   ; => Integration time            [n_e,nbins]

IF (STRUPCASE(data[0].UNITS_NAME) NE 'COUNTS') THEN MESSAGE , 'bad units'
;-----------------------------------------------------------------------------------------
; => Define default 2D and 3D structures
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(deadtime) EQ 0) THEN default = 1d-6   ;  default value
;IF (N_ELEMENTS(deadtime) EQ 0) THEN default = 0d0   ;  default value
; => Get the current dead time values (works for arrays of structures too)
str_element,data,'DEADTIME',VALUE=deadtest

dead_2d = REPLICATE(default[0],n_e,nbins)
dead_3d = REPLICATE(default[0],n_e,nbins,n_str)
CASE n_str OF
  1    : dead_def = dead_2d
  ELSE : dead_def = dead_3d
ENDCASE

check1  = (deadtest GT 0.) AND FINITE(deadtest)
good    = WHERE(check1,gd)
IF (gd GT 0 AND N_ELEMENTS(deadt) EQ 0) THEN deadt = data.DEADTIME
check   = (N_ELEMENTS(deadt) EQ 0) AND (N_ELEMENTS(deadtime) EQ 0)

IF (check) THEN BEGIN
  ; => Neither DEADTIME nor DEADT were not set
  deadt = dead_def
ENDIF ELSE BEGIN
  IF (N_ELEMENTS(deadt) NE 0) THEN dead0 = deadt ELSE dead0 = deadtime
  ; => check dimensions
  test1 = (SIZE(dead0,/DIMENSIONS) EQ SIZE(gf,/DIMENSIONS))
  test2 = (SIZE(dead0,/N_DIMENSIONS) NE SIZE(gf,/N_DIMENSIONS))
  IF (n_str EQ 1) THEN check = (TOTAL(test1) NE 2) ELSE check = (TOTAL(test1) NE 3)
  IF (check OR test2) THEN deadt = dead_def ELSE deadt = dead0
ENDELSE
; => Define dead time (s)
deadtime = deadt
rate     = data.DATA/dt
dt       = dt * (1d0 - rate*deadtime)   ; => Effective integration time (s) [n_e,nbins]
;-----------------------------------------------------------------------------------------
; => Determine type of units to convert to
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(scale) THEN scale = 1
CASE STRUPCASE(units) OF 
  'COUNTS' :  scale = 1.
  'RATE'   :  scale = 1. / dt
  'EFLUX'  :  scale = 1. / (dt * gf)
  'FLUX'   :  scale = 1. / (dt * gf * energy)
  'DF'     :  scale = 1. / (dt * gf * energy^2 * (2./mass/mass*1e5) )
  ELSE: BEGIN
    PRINT,'Undefined units: ',UNITS
    RETURN
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Determine type of units to convert from
;-----------------------------------------------------------------------------------------
CASE STRUPCASE(data[0].UNITS_NAME) OF 
  'COUNTS' :  scale = scale * 1.
  'RATE'   :  scale = scale * dt
  'EFLUX'  :  scale = scale * (dt * gf)
  'FLUX'   :  scale = scale * (dt * gf * energy)
  'DF'     :  scale = scale * (dt * gf * energy^2 * 2./mass/mass*1e5)
  ELSE: BEGIN
    PRINT,'Unknown starting units: ',data[0].UNITS_NAME
    RETURN
  END
ENDCASE

data.UNITS_NAME = units
tags = TAG_NAMES(data)
gtag = WHERE(tags EQ 'DDATA',gtg)
IF (gtg GT 0L) THEN data.DDATA *= scale  ; => Scale d(data) too!
data.DATA *= scale

RETURN
END
