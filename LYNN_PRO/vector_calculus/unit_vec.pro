;+
;*****************************************************************************************
;
;  FUNCTION :   unit_vec.pro
;  PURPOSE  :   This routine calculates the unit vectors of an input array of vectors.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_3_vector.pro
;               mag__vec.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VEC  :  [N,3]- or [3,N]-element [numeric] array to be converted to a
;                         [N,3]-element array of unit 3-vectors
;
;  EXAMPLES:    
;               [calling sequence]
;               uvec = unit_vec(vec [,/NAN])
;
;  KEYWORDS:    
;               NAN  :  If set, routine will replace computed zeros with NaNs on output
;                         for non-finite input values
;                         [Default = FALSE]
;
;   CHANGED:  1)  Added keyword:  NAN
;                   and now calls is_a_number.pro
;                                                                   [06/30/2015   v1.1.0]
;             2)  Optimize a little to reduce wasted computations and now calls
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

FUNCTION unit_vec,vec,NAN=nan

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_3_vector, mag__vec
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Error messages
noinput_mssg   = 'No input was supplied...'
no_num_mssg    = 'User must supply at least one numeric 3-vector'
badoutput_mssg = 'MAG__VEC.PRO returned a 0...?'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 1) OR (N_ELEMENTS(vec) LT 3)
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
;;  Format vector to an [N,3]-Element array
;;----------------------------------------------------------------------------------------
;vec2d          = format_2d_vec(vec)
;test2d         = (N_ELEMENTS(vec2d) LT 3)
;IF (test2d) THEN RETURN,0b         ;;  Error messages found in format_2d_vec.pro
;;----------------------------------------------------------------------------------------
;;  Calculate magnitude
;;----------------------------------------------------------------------------------------
mag2d          = mag__vec(vec2d,/TWO,NAN=nan)  ;;  [N,3]-element array
test2d         = (N_ELEMENTS(mag2d) LT 3)
IF (test2d[0]) THEN BEGIN
  MESSAGE,badoutput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Calculate unit vector
;;----------------------------------------------------------------------------------------
u_vec          = vec2d/mag2d
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,u_vec
END