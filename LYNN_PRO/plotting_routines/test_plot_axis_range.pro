;+
;*****************************************************************************************
;
;  FUNCTION :   test_plot_axis_range.pro
;  PURPOSE  :   This routine tests the format of a plot axis range specification used
;                 by IDL keywords like [XYZ]RANGE (e.g., for PLOT.PRO).
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
;               RANGE   :  [2]-Element [numeric] array specifying the range of values
;                            overwhich to define the viewable axis range for plotting
;                            routine keywords like [XYZ]RANGE
;
;  EXAMPLES:    
;               test = test_plot_axis_range(range)
;
;  KEYWORDS:    
;               NOMSSG  :  If set, routine will not print out warning message
;                            [Default = FALSE]
;
;   CHANGED:  1)  Fixed an issue to prevent routine from returning TRUE when input
;                   contains non-finite data
;                                                                   [02/06/2016   v1.0.1]
;
;   NOTES:      
;               1)  See IDL documentation on Graphics Keywords
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/29/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/06/2016   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION test_plot_axis_range,range,NOMSSG=nomssg

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number
;;----------------------------------------------------------------------------------------
;;  Define some constants, dummy variables, and defaults
;;----------------------------------------------------------------------------------------
;;  Dummy variables
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
test_ran       = 0b
;;  Dummy error messages
noinpt_msg     = 'User must supply a [2]-Element [numeric] array defining the plot range'
badinpt_msg    = 'RANGE must be a [2]-element [numeric] array with unique, finite values'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (is_a_number(range,NOMSSG=nomssg) EQ 0) OR    $
                 (N_ELEMENTS(range) NE 2)
IF (test) THEN BEGIN
  IF ~KEYWORD_SET(nomssg) THEN MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,test_ran[0]
ENDIF
test           = (range[0] EQ range[1]) OR (TOTAL(FINITE(range)) NE 2)
IF (test) THEN BEGIN
  IF ~KEYWORD_SET(nomssg) THEN MESSAGE,badinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,test_ran[0]
ENDIF
;;  Define output and sort range
test_ran       = 1b
range          = range[SORT(range)]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,test_ran[0]
END
