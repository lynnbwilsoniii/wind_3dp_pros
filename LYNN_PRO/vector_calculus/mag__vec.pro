;+
;*****************************************************************************************
;
;  FUNCTION :   mag__vec.pro
;  PURPOSE  :   This routine finds the magnitude of an input vector and returns the
;                 result as either a one- or two-dimensional array.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_3_vector.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VEC  :  [N,3]- or [3,N]-element array of 3-vectors for which to compute
;                         their magnitude.  The output will be either an [N]-element
;                         or (TWO = FALSE) [N,3]-element (TWO = TRUE) array.
;
;  EXAMPLES:    
;               [calling sequence]
;               mag = mag__vec(vec [,/TWO] [,/NAN])
;
;  KEYWORDS:    
;               TWO  :  If set, routine returns |VEC| as an [N,3]--element array, where
;                         the magnitudes are copied in each of the 2nd dimensions
;                         [Default = FALSE]
;               NAN  :  If set, routine will replace computed zeros with NaNs on output
;                         for non-finite input values
;                         [Default = FALSE]
;
;   CHANGED:  1)  Routine can now handle complex inputs for VEC
;                                                                   [03/19/2014   v1.0.1]
;             2)  Added keyword:  NAN
;                   and now calls is_a_number.pro
;                                                                   [06/30/2015   v1.1.0]
;             3)  Optimize a little to reduce wasted computations and now calls
;                   is_a_3_vector.pro instead of format_2d_vec.pro and is_a_number.pro
;                                                                   [12/01/2017   v1.1.1]
;
;   NOTES:      
;               1)  See examples in format_2d_vec.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/10/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/01/2017   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION mag__vec,vec,TWO=two,NAN=nan

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_3_vector
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
dumb3r         = REPLICATE(1,3)
dumb3i         = REPLICATE(DCOMPLEX(1,1),3)
;;  Error messages
noinput_mssg   = 'No input was supplied...'
no_num_mssg    = 'User must supply at least one numeric 3-vector'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (N_ELEMENTS(vec) LT 3)
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_3_vector(vec,V_OUT=vec2d,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_num_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(nan) EQ 0) OR ~KEYWORD_SET(nan)
IF (test[0]) THEN rm_nan = 0b ELSE rm_nan = 1b
;;----------------------------------------------------------------------------------------
;;  Format vector
;;----------------------------------------------------------------------------------------
;vec2d          = format_2d_vec(vec)
;test           = (N_ELEMENTS(vec2d) LT 3)
;IF (test[0]) THEN RETURN,0b         ;;  Error messages found in format_2d_vec.pro
;;----------------------------------------------------------------------------------------
;;  Calculate magnitude
;;----------------------------------------------------------------------------------------
;;  Check for complex values
test_comp      = (TOTAL(IMAGINARY(vec2d)) EQ 0)
test2d         = (N_ELEMENTS(two) EQ 0) OR ~KEYWORD_SET(two)
IF (test_comp[0]) THEN BEGIN
  ;;  Input is real
  VdotV          = vec2d^2     ;;  Faster than  vec2d*vec2d
ENDIF ELSE BEGIN
  ;;  Input has finite imaginary parts
  VdotV          = ABS(vec2d*CONJ(vec2d))
ENDELSE
;;  Define output magnitude variable
mag0           = SQRT(TOTAL(VdotV,2L,/NAN))
IF (test2d[0]) THEN mag = mag0 ELSE mag = mag0 # dumb3r
;;----------------------------------------------------------------------------------------
;;  Replace zeros with NaNs if /NAN
;;----------------------------------------------------------------------------------------
IF (rm_nan[0]) THEN BEGIN
  ;;  User wants to replace zeros computed from input NaNs with NaNs
  test = FINITE(vec2d[*,0]) AND FINITE(vec2d[*,1]) AND FINITE(vec2d[*,2])
  good = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
  IF (bd[0] GT 0) THEN BEGIN
    IF (test_comp[0]) THEN fnan = f ELSE fnan = COMPLEX(f,f)
    ;;  Replace zeros with NaNs
    IF (test2d[0]) THEN mag[bad] = fnan[0] ELSE mag[bad,*] = fnan[0]
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN, mag
END