;+
;*****************************************************************************************
;
;  FUNCTION :   replace_x_with_y.pro
;  PURPOSE  :   Replaces values in an array matching some criteria with values
;                 defined by keyword settings.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X            :  [N]-Element [numeric] array in which to replace elements
;                                 satisfying a given test defined by the keywords with
;                                 the scalar RVAL
;               RVAL         :  Scalar [numeric] value to replace current values within
;                                 X for the elements that satisfy the user-defined test
;
;  EXAMPLES:    
;               [calling sequence]
;               newx = replace_x_with_y(x, rval [,/POSITIVE] [,/NEGATIVE] [,TESTVAL=testval] $
;                                      [,/NAN] [,/AND_POS] [,/AND_NEG])
;
;  KEYWORDS:    
;               ****************
;               ***  INPUTS  ***
;               ****************
;               NAN          :  If set, routine will require finite values in test
;                                 defining the elements to replace with RVAL
;                                 [Default = FALSE]
;               POSITIVE     :  If set, routine will replace all non-positive values,
;                                 including zeros, with RVAL.  If the NAN keyword is set
;                                 then the test will require values to also be finite.
;                                 [Default = FALSE]
;               NEGATIVE     :  If set, routine will replace all non-negative values,
;                                 including zeros, with RVAL.  If the NAN keyword is set
;                                 then the test will require values to also be finite.
;                                 [Default = FALSE]
;               TESTVAL      :  Scalar [numeric] defining the test value to search for
;                                 within X to be replaced with RVAL
;                                 [Default = FALSE]
;               AND_POS      :  If set in conjunction with a valid TESTVAL input, the
;                                 routine will define "bad" elements as those matching
;                                 TESTVAL or non-positive (including zero) values
;                                 [Default = FALSE]
;               AND_NEG      :  If set in conjunction with a valid TESTVAL input, the
;                                 routine will define "bad" elements as those matching
;                                 TESTVAL or non-negative (including zero) values
;                                 [Default = FALSE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Keyword order of precedence
;                     1  :  TESTVAL
;                       a  :  AND_POS
;                       b  :  AND_NEG
;                     2  :  POSITIVE
;                     3  :  NEGATIVE
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/13/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/13/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION replace_x_with_y,x,rval,POSITIVE=positive,NEGATIVE=negative,NAN=nan,  $
                                 TESTVAL=testval,AND_POS=andpos,AND_NEG=andneg

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
a_pos          = 0b
a_neg          = 0b
;;  Dummy error messages
no_inpt_msg    = 'User must supply X and RVAL as an [N]-element [numeric] array and scalar [numeric] value...'
badform_msg    = 'Incorrect input format:  X and RVAL must both be numeric and X must be an array of multiple points...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN BEGIN
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = ((N_ELEMENTS(x) LE 1) OR (is_a_number(x,/NOMSSG) EQ 0)) OR  $
                 (is_a_number(rval,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NAN
test           = (is_a_number(nan,/NOMSSG) EQ 0) OR ~KEYWORD_SET(nan)
IF (test[0]) THEN nan_on = 0b ELSE nan_on = 1b
;;  Check POSITIVE
test           = (is_a_number(positive,/NOMSSG) EQ 0) OR ~KEYWORD_SET(positive)
IF (test[0]) THEN pos_on = 0b ELSE pos_on = 1b
;;  Check NEGATIVE
test           = (is_a_number(negative,/NOMSSG) EQ 0) OR ~KEYWORD_SET(negative)
IF (test[0]) THEN neg_on = 0b ELSE neg_on = 1b
;;  Check for double-setting
IF (pos_on[0] AND neg_on[0]) THEN neg_on = 0b             ;;  Default to POSITIVE if both are set
;;  Check TESTVAL
test           = (is_a_number(testval,/NOMSSG) EQ 0)
IF (test[0]) THEN tval_on = 0b ELSE tval_on = 1b
IF (tval_on[0]) THEN BEGIN
  ;;  Shut off others
  pos_on = 0b
  neg_on = 0b
  t__val = testval[0]
  ;;  Check AND_POS and AND_NEG
  IF (KEYWORD_SET(andpos) OR KEYWORD_SET(andneg)) THEN BEGIN
    IF KEYWORD_SET(andpos) THEN a_pos = 1b
    IF KEYWORD_SET(andneg) THEN a_neg = 1b
    IF (a_pos[0] AND a_neg[0]) THEN a_neg = 0b      ;;  AND_POS takes precedence
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define tests and "bad" elements to replace
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
other_ar       = [pos_on[0],neg_on[0],tval_on[0]]
good_oth       = WHERE(other_ar,gd_oth)
IF (gd_oth[0] EQ 0) THEN BEGIN
  ;;  None are set --> use POSITIVE as default
  MESSAGE,'No test value setting defined --> Using default POSITIVE = TRUE',/INFORMATIONAL,/CONTINUE
  pos_on = 1b
ENDIF ELSE BEGIN
  ;;  Determine form of test
  CASE good_oth[0] OF
    0  :  BEGIN
      ;;0000000000000000000000000000000000000000000000000000000000000000000000000000000000
      ;;  Use POSITIVE
      IF (nan_on[0]) THEN test = (x LE 0) AND FINITE(x) ELSE test = (x LE 0)
    END
    1  :  BEGIN
      ;;1111111111111111111111111111111111111111111111111111111111111111111111111111111111
      ;;  Use NEGATIVE
      IF (nan_on[0]) THEN test = (x GE 0) AND FINITE(x) ELSE test = (x GE 0)
    END
    2  :  BEGIN
      ;;2222222222222222222222222222222222222222222222222222222222222222222222222222222222
      ;;  Use TESTVAL
      IF (nan_on[0]) THEN test = (x EQ t__val[0]) AND FINITE(x) ELSE test = (x EQ t__val[0])
      IF (a_pos[0] OR a_neg[0]) THEN BEGIN
        IF (a_pos[0]) THEN test = test OR (x LE 0)
        IF (a_neg[0]) THEN test = test OR (x GE 0)
      ENDIF
    END
  ENDCASE
ENDELSE
;;  Define "bad" elements to replace
xarr           = x
bad            = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd[0] GT 0) THEN BEGIN
  xarr[bad] = rval[0]
ENDIF ELSE BEGIN
  ;;  No values match criteria --> do nothing
  MESSAGE,'No values match test criteria --> No elements replaced...',/INFORMATIONAL,/CONTINUE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,xarr
END

