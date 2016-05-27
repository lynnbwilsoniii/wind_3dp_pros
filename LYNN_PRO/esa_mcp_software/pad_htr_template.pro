;+
;*****************************************************************************************
;
;  FUNCTION :   pad_htr_template.pro
;  PURPOSE  :   Create a dummy PAD structure to prevent code breaking upon
;                 multiple callings of the program pad_htr_magf.pro.
;
;  CALLED BY:   
;               pad_htr_magf.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  3DP data structure(s) either from get_??.pro
;                               [?? = el, elb, phb, sf, etc.]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               ESTEPS     :  Energy bins to use [2-Element array corresponding to
;                               first and last energy bin element or an array of
;                               energy bin elements]
;               NUM_PA     :  Number of pitch-angles to sum over (Default = 8L)
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  If DAT is not a 3DP data structure, NaNs, zeros, and null strings
;                     replace quantities like dat.NENERGY and routine assumes the
;                     format for an 'Eesa Low Burst' data structure
;
;   CREATED:  01/17/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/17/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION pad_htr_template,dat,ESTEPS=esteps,NUM_PA=num_pa

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
f        = !VALUES.F_NAN
d        = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input data
;-----------------------------------------------------------------------------------------
dtype    = SIZE(dat,/TYPE)
IF (dtype[0] NE 8L) THEN BEGIN
  IF KEYWORD_SET(esteps) THEN BEGIN
    nenergy = N_ELEMENTS(esteps)
  ENDIF ELSE BEGIN
    nenergy = 15L   ; => Default value (value used by ES analyzers)
  ENDELSE
  nbins   = 88L                   ; => # of data bins
  unconv  = 'convert_esa_units'   ; => Unit Conversion Program
  pronme  = 'Wind 3D Plasma'      ; => 'Wind 3D Plasma'
  datnme  = 'Eesa Low Burst'      ; => e.g. 'Pesa High Burst'
  untnme  = 'Counts'              ; => e.g. 'df'
  sttime  = 0d0                   ; => Unix time at start of sample
  entime  = 0d0                   ; => " " end of sample
  intime  = 0d0                   ; => Integration time of sample
ENDIF ELSE BEGIN
  IF KEYWORD_SET(esteps) THEN BEGIN
    nenergy = N_ELEMENTS(esteps)
  ENDIF ELSE BEGIN
    nenergy = dat.NENERGY
  ENDELSE
  nbins  = dat.NBINS             ; => # of data bins
  unconv = dat.UNITS_PROCEDURE   ; => Unit Conversion Program
  pronme = dat.PROJECT_NAME      ; => 'Wind 3D Plasma'
  datnme = dat.DATA_NAME         ; => e.g. 'Pesa High Burst'
  untnme = dat.UNITS_NAME        ; => e.g. 'df'
  sttime = dat.TIME              ; => Unix time at start of sample
  entime = dat.END_TIME          ; => " " end of sample
  intime = dat.INTEG_T           ; => Integration time of sample
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define number of pitch-angles
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(num_pa) THEN BEGIN
  pang = num_pa
ENDIF ELSE BEGIN
  pang = 8
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define dummy variables and dummy structure template
;-----------------------------------------------------------------------------------------
newd   = REPLICATE(f,nenergy,pang)   ; => Dummy Data array
newp   = REPLICATE(f,nenergy,pang)   ; => Dummy Pitch-Angle array
energy = REPLICATE(f,nenergy,pang)   ; => Dummy Energy Bin array
dnergy = REPLICATE(f,nenergy,pang)   ; => Dummy Differential " "
geom   = REPLICATE(f,nenergy,pang)   ; => Dummy Geometry Factor array
dt     = REPLICATE(f,nenergy,pang)   ; => Dummy Integration Time array
deadt  = REPLICATE(f,nenergy,pang)   ; => Dummy Dead Time array
bph    = REPLICATE(f,nenergy,nbins)  ; => Dummy B-field azimuthal angle
bth    = REPLICATE(f,nenergy,nbins)  ; => Dummy B-field poloidal angle
;-----------------------------------------------------------------------------------------
; => Define dummy structure template
;-----------------------------------------------------------------------------------------
pad = CREATE_STRUCT('PROJECT_NAME',pronme,'DATA_NAME',datnme+' PAD',                  $
                    'VALID',0,'UNITS_NAME',untnme,'TIME',sttime,                      $
                    'END_TIME',entime,'INTEG_T',intime,'NBINS',pang,                  $
                    'NENERGY',nenergy,'DATA',newd,'ENERGY',energy,'ANGLES',newp,      $
                    'DENERGY',dnergy,'BTH',f,'BPH',f,'GF',geom,'DT',dt,               $
                    'GEOMFACTOR',d,'MASS',dat.MASS,'UNITS_PROCEDURE',unconv,          $
                    'DEADTIME',deadt)
;-----------------------------------------------------------------------------------------
; => Return
;-----------------------------------------------------------------------------------------

RETURN,pad
END