;+
;*****************************************************************************************
;
;  FUNCTION :   num2int_str.pro
;  PURPOSE  :   This routine converts an input number to a string output using the
;                 integer format code.  The user can explicitly define the length desired
;                 or use the general '(I)' format code.
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
;               INPUT     :  Scalar or [N]-element [numeric] array of values to be
;                              converted to strings with an integer format (i.e., all
;                              decimal places will be removed)
;
;  EXAMPLES:    
;               [calling sequence]
;               int_str = num2int_str( input [,NUM_CHAR=num_char] [,/NO_TRIM] [,/ZERO_PAD])
;
;               ;;  Output WITHOUT excess empty spaces
;               input          = 15
;               num_char       = 5L
;               PRINT,';;', num2int_str(input,NUM_CHAR=num_char)
;               ;;15
;               
;               ;;  Output WITH excess empty spaces
;               PRINT,';;', num2int_str(input,NUM_CHAR=num_char,/NO_TRIM)
;               ;;   15
;               
;               ;;  Output WITH zeros in excess empty spaces
;               PRINT,';;', num2int_str(input,NUM_CHAR=num_char,/NO_TRIM,/ZERO_PAD)
;               ;;00015
;               
;               ;;  Output WITH excess empty spaces but use default character width
;               input          = 15
;               PRINT,';;', num2int_str(input,/NO_TRIM)
;               ;;          15
;               
;               ;;  Output WITH excess empty spaces replaced with zeros and use default character width
;               input          = 15
;               PRINT,';;', num2int_str(input,/NO_TRIM,/ZERO_PAD)
;               ;;000000000015
;               
;               ;;  Make sure NUM_CHAR is large enough otherwise output is a string of asterisks
;               ;;    NUM_CHAR characters in length [e.g., see below]
;               input          = [-2,300,5e5,4d0,15]
;               num_char       = 4L
;               PRINT,';;', num2int_str(input,NUM_CHAR=num_char)
;               ;; -2 300 **** 4 15
;               
;               PRINT,';;  ', num2int_str(input,NUM_CHAR=num_char,/NO_TRIM)
;               ;;     -2  300 ****    4   15
;               
;               ;;  Use large enough NUM_CHAR
;               input          = [-2,300,5e5,4d0,15]
;               num_char       = 15L
;               PRINT,';;', num2int_str(input,NUM_CHAR=num_char,/NO_TRIM)
;               ;;              -2             300          500000               4              15
;
;  KEYWORDS:    
;               NUM_CHAR  :  Scalar [integer/long] defining the number of characters to
;                              include in the format statement.  For instance, if the
;                              value were set to 4 then the format code used would be
;                              '(I4.4)'.  The rout
;               NO_TRIM   :  If set, routine will not remove leading or trailing empty
;                              character spaces on output.
;                              [Default = FALSE]
;               ZERO_PAD  :  If set, routine will fill any empty leading character spaces
;                              with string zeros
;                              [Default = FALSE]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [06/04/2016   v1.0.0]
;             2)  Finished writing routine
;                                                                   [06/04/2016   v1.0.0]
;
;   NOTES:      
;               1)  This routine does not try to help the user much, so proper input
;                     formats should be used.
;               2)  The variable INPUT is converted to a LONG integer prior converting
;                     to a string unless INPUT is a ULONG, ULONG64, or LONG64
;               3)  The default NUM_CHAR value is 12 unless INPUT is a ULONG64 or
;                     LONG64, in which case it increases to 22
;
;  REFERENCES:  
;               NA
;
;   CREATED:  06/04/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/04/2016   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION num2int_str,input,NUM_CHAR=num_char,NO_TRIM=no_trim,ZERO_PAD=zero_pad

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
max_nc         = 255L                  ;;  Max. # of character width in format code
def_nch        = 12L                   ;;  Default character width
;;  Dummy error messages
no_inpt_msg    = 'User must supply either a scalar or [n]-element [numeric] array of values...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (is_a_number(input,/NOMSSG) EQ 0) OR $
                 (N_ELEMENTS(input) LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NUM_CHAR
test_nc        = ((N_ELEMENTS(num_char) GT 0) AND is_a_number(num_char,/NOMSSG))
IF (test_nc[0]) THEN test_nc = (LONG(num_char[0]) GT 0) AND (LONG(num_char[0]) LE max_nc[0])
IF (test_nc[0]) THEN BEGIN
  n_char    = LONG(num_char[0])
  exp_nc_on = 1b
ENDIF ELSE BEGIN
  n_char    = def_nch[0]
  exp_nc_on = 0b
ENDELSE
;;  Check NO_TRIM
test           = (N_ELEMENTS(no_trim) EQ 1) AND KEYWORD_SET(no_trim)
IF (test[0]) THEN trim = 0b ELSE trim = 1b
;;  Check ZERO_PAD
test           = (N_ELEMENTS(zero_pad) EQ 1) AND KEYWORD_SET(zero_pad)
IF (test[0]) THEN zpad = 1b ELSE zpad = 0b
;;----------------------------------------------------------------------------------------
;;  Define output format code
;;----------------------------------------------------------------------------------------
;;  Convert input to an integer
test           = (TOTAL(SIZE(input,/TYPE) EQ [13,14,15]) GT 0)
IF (test[0]) THEN BEGIN
  CASE SIZE(input,/TYPE) OF
    13  :  inv = ULONG(input)
    14  :  inv = LONG64(input)
    15  :  inv = ULONG64(input)
  ENDCASE
  ;;  Change default character length
  IF (SIZE(input,/TYPE) GT 13) THEN def_nch = 22L
ENDIF ELSE BEGIN
  inv = LONG(input)
ENDELSE
;;  Define the character length
IF (exp_nc_on[0]) THEN nch = LONG(n_char[0]) ELSE nch = def_nch[0]
nch_str        = (['','0'])[zpad[0]]+STRTRIM(STRING(LONG(nch[0]),FORMAT='(I)'),2L)
;;  Define format code
mform          = '(I'+nch_str[0]+')'
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
output0        = STRING(inv,FORMAT=mform[0])
IF (trim[0]) THEN output = STRTRIM(output0,2L) ELSE output = output0
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END
