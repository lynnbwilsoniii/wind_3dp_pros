;+
;*****************************************************************************************
;
;  FUNCTION :   convert_flux_units.pro
;  PURPOSE  :   Converts the units of the data array of Eesa data structures.  The data
;                 associated with data.DATA is rescaled to the new units and
;                 data.UNITS_NAME is changed to the appropriate units.
;
;  CALLED BY: 
;               convert_esa_units.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATA      :  A 3DP data structure returned by get_??.pro 
;               UNITS     :  A scalar string defining the units to convert to
;                              One of the following are allowed:
;                              1)  'eflux'   ; => energy flux
;                              2)  'flux'    ; => number flux
;                              3)  'df'      ; => distribution function units
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               SCALE     :  Set to a named variable to return the conversion factor
;                              array used to scale the data
;
;   CHANGED:  1)  Davin Larson changed something...       [??/??/????   v1.0.?]
;             2)  Re-wrote and cleaned up                 [06/22/2009   v1.1.0]
;             3)  Fixed syntax issue if data is an array of structures
;                                                         [08/05/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/05/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO convert_flux_units, data, units, SCALE=scale

;-----------------------------------------------------------------------------------------
; => Define relevant parameters
;-----------------------------------------------------------------------------------------
mass     = data[0].MASS              ; => Particle mass [eV/(km/sec)^2] double
energy   = data.ENERGY               ; => (eV)                        [n_e,nbins]
;-----------------------------------------------------------------------------------------
; => Determine type of units to convert to
;-----------------------------------------------------------------------------------------
CASE STRUPCASE(units) OF 
  'FLUX' : scale = 1.
  'EFLUX': scale = energy
  'DF'   : scale = 1./(energy * (2./mass/mass*1e5))
  ELSE: BEGIN
    MESSAGE,'Cannot convert to units of ',UNITS
    RETURN
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Determine type of units to convert from
;-----------------------------------------------------------------------------------------
CASE STRUPCASE(data[0].UNITS_NAME) OF 
  'FLUX' : scale = scale
  'EFLUX': scale = scale/energy
  'DF'   : scale = scale * energy * 2./mass/mass*1e5
ENDCASE

data.UNITS_NAME = units
tags = TAG_NAMES(data)
gtag = WHERE(tags EQ 'DDATA',gtg)
IF (gtg GT 0L) THEN data.DDATA *= scale  ; => Scale d(data) too!
data.DATA *= scale

RETURN
END
