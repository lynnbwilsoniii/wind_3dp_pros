;+
;*****************************************************************************************
;
;  FUNCTION :   format_vector_string.pro
;  PURPOSE  :   This routine takes a [3]-element vector and converts the result into
;                 a string with separated components.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_3_vector.pro
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VEC        :  [3]-Element array [float/double] that you wish to return
;                               an associated formated string of the form:
;                                 '< sV0, sV1, sV2 >'
;                               where s = sign of the jth component of V
;
;  EXAMPLES:    
;               [calling sequence]
;               vstr  = format_vector_string( vec [,PRECISION=precision])
;               ;;  Use default value for PRECISION
;               vec   =  [ -1.05, 3.87, -9.45]
;               vstr  = format_vector_string(vec)
;               PRINT,vstr
;               < -1.05, +3.87, -9.45 >
;               ;;  Use PRECISION=4
;               vec   =  [ -1.05, 3.87, -9.45]
;               vstr  = format_vector_string(vec,PRECISION=4)
;               PRINT,vstr
;               < -1.0500, +3.8700, -9.4500 >
;
;  KEYWORDS:    
;               PRECISION  :  Scalar [long] defining the number of decimal places to
;                               keep when converting VEC into a string
;                               [Default = 2]
;
;   CHANGED:  1)  Added extra error handling by calling is_a_number.pro
;                                                                   [10/01/2015   v1.1.0]
;             2)  Updated Man. page and fixed an error that occurs if input is all
;                  zeros and now calls is_a_3_vector.pro
;                                                                   [06/03/2016   v1.2.0]
;
;   NOTES:      
;               1)  Limits:  -1 < PRECISION < 33
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/29/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/03/2016   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION format_vector_string,vec,PRECISION=precision

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define some defaults
def_vstr       = '< +NaN, +NaN, +NaN >'
signs          = ['','+']
prec_mnmx      = [0L,32L]
def_fmin       = 35L
all_zeros      = 0b
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;test           = (N_PARAMS() LT 1) OR (N_ELEMENTS(vec) NE 3) OR $
;                 (is_a_number(vec,/NOMSSG) EQ 0)
test           = (N_PARAMS() LT 1) OR (is_a_3_vector(vec,V_OUT=vout,/NOMSSG) EQ 0)
IF (test[0]) THEN RETURN,def_vstr[0]
vvv            = REFORM(vout)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check PRECISION
test           = (N_ELEMENTS(precision) LT 1) OR (is_a_number(precision,/NOMSSG) EQ 0)
IF (test[0]) THEN prec = 2L ELSE prec = LONG(precision[0])
;;  Make sure PRECISION is within range
prec           = (prec[0] > prec_mnmx[0]) < prec_mnmx[1]
;;----------------------------------------------------------------------------------------
;;  Define output format
;;----------------------------------------------------------------------------------------
;;  1st, make sure values are not all zeros or non-finite
test           = (TOTAL(ABS(vvv)) EQ 0) OR (TOTAL(FINITE(vvv)) EQ 0)
IF (test[0]) THEN BEGIN
  test           = (TOTAL(ABS(vvv)) EQ 0)
  IF (test[0]) THEN BEGIN
    ;;  All components = 0.0
    all_zeros  = 1b
  ENDIF ELSE BEGIN
    ;;  All components = non-finite
    RETURN,def_vstr[0]
  ENDELSE
ENDIF
;;  1st, check to see how large the number happens to be
l10            = ALOG10(vvv)
l10mx          = MAX(ABS(l10),/NAN)
test           = (l10mx[0] GT 1) AND ~all_zeros[0]
IF (test[0]) THEN fmin = def_fmin[0] + CEIL(l10mx[0]) ELSE fmin = def_fmin[0]
fmin_str       = STRTRIM(STRING(fmin[0],FORMAT='(I)'),2L)
;;  Define output format
IF (prec EQ 0) THEN BEGIN
  vform    = '(f'+fmin_str[0]+'.0)'
  remove_d = 1
ENDIF ELSE BEGIN
  sprec    = STRTRIM(STRING(prec[0],FORMAT='(I2.2)'),2L)
  vform    = '(f'+fmin_str[0]+'.'+sprec[0]+')'
  remove_d = 0
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Convert VEC to string
;;----------------------------------------------------------------------------------------
vstr           = STRTRIM(STRING(vvv,FORMAT=vform),2L)
IF (remove_d) THEN BEGIN
  ;;  remove '.' from end of string
  FOR j=0L, 2L DO BEGIN
    v0      = STRMID(vstr[j],0L,STRLEN(vstr[j]) - 1L)
    vstr[j] = v0[0]
  ENDFOR
ENDIF
;;----------------------------------------------------------------------------------------
;;  Add '+' to VSTR to string [if positive]
;;----------------------------------------------------------------------------------------
plus           = STRMID(vstr[*],0L,1L) NE '-'
str_s          = signs[plus]+vstr
;;----------------------------------------------------------------------------------------
;;  Format output
;;----------------------------------------------------------------------------------------
str_lmax       = MAX(STRLEN(str_s),/NAN)
lmxs           = STRTRIM(STRING(str_lmax[0],FORMAT='(I2.2)'),2L)
sform          = '("< ",a'+lmxs[0]+',", ",a'+lmxs[0]+',", ",a'+lmxs[0]+'," >")'
fstr_out       = STRING(str_s,FORMAT=sform)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,fstr_out
END
