;+
;*****************************************************************************************
;
;  FUNCTION :   is_a_number.pro
;  PURPOSE  :   This routine tests an input to determine if it has a numeric type code.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               XX  :  Scalar, array, structure, etc. to test
;
;  EXAMPLES:    
;               test = is_a_number(x)
;
;  KEYWORDS:    
;               NOMSSG  :  If set, routine will not print out warning message
;                            [Default = FALSE]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [04/01/2015   v1.0.0]
;             2)  Added keyword:  NOMSSG
;                                                                   [04/24/2015   v1.1.0]
;
;   NOTES:      
;               1)  See type codes in IDL documentation
;
;  REFERENCES:  
;               See IDL documentation for SIZE.PRO with TYPE keyword
;
;   CREATED:  03/28/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/24/2015   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION is_a_number,xx,NOMSSG=nomssg

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
test_num       = 0b
;;  Define allowed number types
all_num_type   = [1,2,3,4,5,6,9,12,13,14,15]
;;  Dummy error messages
noinpt_msg     = 'User must supply an input of some form...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 1) OR (N_ELEMENTS(xx) EQ 0)
IF (test) THEN BEGIN
  ;;  No input
  test           = ~KEYWORD_SET(nomssg)
  IF (test) THEN MESSAGE,noinpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,test_num[0]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define type
;;----------------------------------------------------------------------------------------
xt             = SIZE(xx,/TYPE)
;;  Check type
test_num       = (TOTAL(xt[0] EQ all_num_type) EQ 1)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,test_num[0]
END

