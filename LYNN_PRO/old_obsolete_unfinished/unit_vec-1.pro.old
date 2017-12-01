;+
;*****************************************************************************************
;
;  FUNCTION :   unit_vec.pro
;  PURPOSE  :   This routine calculates the unit vectors of an input array of vectors.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               format_2d_vec.pro
;               mag__vec.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VEC  :  [N,3]- or [3,N]-element array to be forced to a [N,3]-element
;                         array
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NAN  :  If set, routine will replace computed zeros with NaNs on output
;                         for non-finite input values
;                         [Default = FALSE]
;
;   CHANGED:  1)  Added keyword:  NAN
;                   and now calls is_a_number.pro
;                                                                   [06/30/2015   v1.1.0]
;
;   NOTES:      
;               1)  See examples in format_2d_vec.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/10/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/30/2015   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION unit_vec,vec,NAN=nan

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, format_2d_vec, mag__vec
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Error messages
noinput_mssg   = 'No input was supplied...'
badoutput_mssg = 'MAG__VEC.PRO returned a 0...?'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;test           = (N_PARAMS() NE 1) OR (N_ELEMENTS(vec) EQ 0)
test           = (N_PARAMS() NE 1) OR (N_ELEMENTS(vec) EQ 0) OR $
                 (is_a_number(vec,/NOMSSG) EQ 0)
IF (test) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
vv             = REFORM(vec)
;;----------------------------------------------------------------------------------------
;;  Format vector to an [N,3]-Element array
;;----------------------------------------------------------------------------------------
vec2d          = format_2d_vec(vec)
test2d         = (N_ELEMENTS(vec2d) LT 3)
IF (test2d) THEN RETURN,0b         ;;  Error messages found in format_2d_vec.pro
;test           = (N_ELEMENTS(vec2d) LT 3)
;IF (test) THEN RETURN,0         ;;  Error messages found in format_2d_vec.pro
;;----------------------------------------------------------------------------------------
;;  Calculate magnitude
;;----------------------------------------------------------------------------------------
;mag2d          = mag__vec(vec2d,/TWO)  ;;  [N,3]-element array
;test           = (N_ELEMENTS(vec2d) LT 3)
mag2d          = mag__vec(vec2d,/TWO,NAN=nan)  ;;  [N,3]-element array
IF (test2d) THEN BEGIN
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