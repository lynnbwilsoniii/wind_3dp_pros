;+
;*****************************************************************************************
;
;  FUNCTION :   pad_template.pro
;  PURPOSE  :   Create a dummy PAD structure to prevent code breaking upon
;                 multiple callings of the program my_pad_dist.pro.
;
;  CALLED BY:   
;               pad.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT     :  3DP data structure(s) either from get_??.pro
;                            [?? = el, elb, phb, sf, etc.]
;
;  EXAMPLES:    
;               test = pad_template(dat,NUM_PA=8L,ESTEPS=LINDGEN(15L))
;
;  KEYWORDS:    
;               NUM_PA  :  Scalar [integer] defining the number of pitch-angles to
;                            sum over
;                            [Default = 8L]
;               ESTEPS  :  [N]-Element [integer] array defining the energy bin
;                            numbers to use
;                            [Default = DAT.ENERGY[*]]
;
;   CHANGED:  1)  Added keyword ESTEPS
;                                                                   [12/08/2008   v2.0.0]
;             2)  Changed name from my_pad_template.pro to pad_template.pro
;                   and altered a few things
;                                                                   [07/20/2009   v2.1.0]
;             3)  Fixed a syntax issue
;                                                                   [08/05/2009   v2.1.1]
;             4)  Fixed a bug whereby the routine still required a structure input and
;                   updated/cleaned up Man. page and routine
;                                                                   [10/02/2014   v2.2.0]
;
;   NOTES:      
;               1)  See also:  pad.pro
;
;  REFERENCES:  
;               
;
;   CREATED:  04/20/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/02/2014   v2.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION pad_template,dat,NUM_PA=num_pa,ESTEPS=esteps

;;----------------------------------------------------------------------------------------
;;  Check input data
;;----------------------------------------------------------------------------------------
dtype = SIZE(dat,/TYPE)
f     = !VALUES.F_NAN
d     = !VALUES.D_NAN
IF (dtype[0] NE 8L) THEN BEGIN
  IF KEYWORD_SET(esteps) THEN BEGIN
    nenergy = N_ELEMENTS(esteps)
  ENDIF ELSE BEGIN
    nenergy = 15L   ;;  Default value (value used by ES analyzers)
  ENDELSE
  unconv  = 'convert_esa_units'      ;;  Unit Conversion Program
  pronme  = 'Wind 3D Plasma'         ;;  'Wind 3D Plasma'
  datnme  = 'Eesa Low Burst'         ;;  e.g. 'Pesa High Burst'
  untnme  = 'Counts'                 ;;  e.g. 'df'
  sttime  = 0d0                      ;;  Unix time at start of sample
  entime  = 0d0                      ;;  " " end of sample
  intime  = 0d0                      ;;  Integration time of sample
  mass    = 0d0                      ;;  Particle mass
ENDIF ELSE BEGIN
  IF KEYWORD_SET(esteps) THEN BEGIN
    nenergy = N_ELEMENTS(esteps)
  ENDIF ELSE BEGIN
    nenergy = dat[0].NENERGY
  ENDELSE
  unconv  = dat[0].UNITS_PROCEDURE   ;;  Unit Conversion Program
  pronme  = dat[0].PROJECT_NAME      ;;  'Wind 3D Plasma'
  datnme  = dat[0].DATA_NAME         ;;  e.g. 'Pesa High Burst'
  untnme  = dat[0].UNITS_NAME        ;;  e.g. 'df'
  sttime  = dat[0].TIME              ;;  Unix time at start of sample
  entime  = dat[0].END_TIME          ;;  " " end of sample
  intime  = dat[0].INTEG_T           ;;  Integration time of sample
  mass    = dat[0].MASS              ;;  Particle mass
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define number of pitch-angles
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(num_pa) THEN BEGIN
  pang = num_pa
ENDIF ELSE BEGIN
  pang = 8
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define dummy variables and dummy structure template
;;----------------------------------------------------------------------------------------
newd   = REPLICATE(f,nenergy,pang)   ;;  Dummy Data array
newp   = REPLICATE(f,nenergy,pang)   ;;  Dummy Pitch-Angle array
energy = REPLICATE(f,nenergy,pang)   ;;  Dummy Energy Bin array
dnergy = REPLICATE(f,nenergy,pang)   ;;  Dummy Differential " "
geom   = REPLICATE(f,nenergy,pang)   ;;  Dummy Geometry Factor array
dt     = REPLICATE(f,nenergy,pang)   ;;  Dummy Integration Time array
deadt  = REPLICATE(f,nenergy,pang)   ;;  Dummy Dead Time array
bph    = f                           ;;  Dummy B-field azimuthal angle
bth    = f                           ;;  Dummy B-field poloidal angle

pad = CREATE_STRUCT('PROJECT_NAME',pronme,'DATA_NAME',datnme+' PAD',                  $
                    'VALID',0,'UNITS_NAME',untnme,'TIME',sttime,                      $
                    'END_TIME',entime,'INTEG_T',intime,'NBINS',pang,                  $
                    'NENERGY',nenergy,'DATA',newd,'ENERGY',energy,'ANGLES',newp,      $
                    'DENERGY',dnergy,'BTH',f,'BPH',f,'GF',geom,'DT',dt,               $
                    'GEOMFACTOR',d,'MASS',mass,'UNITS_PROCEDURE',unconv,              $
                    'DEADTIME',deadt)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,pad
END
