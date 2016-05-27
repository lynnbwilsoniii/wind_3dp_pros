;+
;*****************************************************************************************
;
;  FUNCTION :   str_valid_num.pro
;  PURPOSE  :   Test whether an input string would be an acceptable numeric value if
;                 converted using the standard routines.  The input string is parsed
;                 for characters that may possibly form a valid number.  Meaning, if the
;                 user entered something like '42.0noreason', the OUTVAL return would be
;                 the valid number, 42.0.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               ****************
;               ***   Input  ***
;               ****************
;               STR_IN   :  [N]-Element [string] array to be tested for valid numeric
;                             values
;               ****************
;               ***  Output  ***
;               ****************
;               [Optional]
;               OUTVAL   :  Set to a named variable to return the double-
;                             precision(integer) values defined by STR_IN for the
;                             keyword setting INTEGER = FALSE(TRUE)
;
;  EXAMPLES:    
;               [calling sequence]
;               test = str_valid_num(str_in [,outval] [,/INTEGER])
;
;               test   = str_valid_num(3.2,outval,/INTEGER)
;               % STR_VALID_NUM: Incorrect input type:  STR_IN must be of string type...
;               PRINT,';;',test[0]
;               ;;   0
;
;               test   = str_valid_num('3.2',outval,/INTEGER)
;               HELP,test,outval,OUTPUT=output
;               FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  ',output[j]
;               ;;  TEST            BYTE      =    0
;               ;;  OUTVAL          UNDEFINED = <Undefined>
;
;               str_in = ['-0.03','2.3g','3.2e12','540124']
;               test   = str_valid_num(str_in,outval)
;               PRINT,';;',test & $
;               PRINT,';;',outval
;               ;;   1   0   1   1
;               ;;    -0.030000000             NaN   3.2000000e+12       540124.00
;
;               str_in = ['-0.03','2.3g','3.2e12','540124']
;               test   = str_valid_num(str_in,outval,/INTEGER)
;               PRINT,';;',test & $
;               PRINT,';;',outval
;               ;;   0   0   0   1
;               ;;           0           0           0      540124
;
;               str_in = '2007-04-21'
;               test   = str_valid_num(str_in,outval,/INTEGER)
;               HELP,test,outval,OUTPUT=output
;               FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  ',output[j]
;               ;;  TEST            BYTE      =    0
;               ;;  OUTVAL          UNDEFINED = <Undefined>
;
;  KEYWORDS:    
;               INTEGER  :  If set, routine tests only for integer values
;                             [Default = FALSE]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See also:  valid_num.pro
;               2)  A derivation of the regular expressions below can be found at:
;                     http://wiki.tcl.tk/989
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM:  valid_num.pro [SPEDAS library, SSL]
;   CREATED:  11/02/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/02/2015   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION str_valid_num,str_in,outval,INTEGER=integer

;;----------------------------------------------------------------------------------------
;;  Define some defaults
;;----------------------------------------------------------------------------------------
;;  Constants
d              = !VALUES.D_NAN
l              = 0L
int_on         = 0b                                                       ;;  Logic variable used later
;;  Regular Expressions
str_regex_int  = '^[-+]?[0-9][0-9]*$'                                     ;;  Regular expression for integer-only
str_regex_num  = '^[-+]?([0-9]+\.?[0-9]*|\.[0-9]+)([eEdD][-+]?[0-9]+)?$'  ;;  " " for general numeric input
;;  Error messages
noinput_mssg   = 'No or incorrect input was supplied...'
bad_intype_msg = 'Incorrect input type:  STR_IN must be of string type...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (SIZE(str_in,/TYPE) NE 7)
IF (test[0]) THEN BEGIN
  MESSAGE,bad_intype_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check INTEGER
IF KEYWORD_SET(integer) THEN BEGIN
  regex  = str_regex_int[0]
  null   = l
  int_on = 1b
ENDIF ELSE BEGIN
  regex = str_regex_num[0]
  null  = d
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check for optional input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() EQ 1)  ;;  TRUE --> just return boolean test results
vv             = STREGEX(STRTRIM(str_in,2),regex,/BOOLEAN)
IF (test[0]) THEN RETURN, vv
;;  OUTVAL is set --> Define
;;----------------------------------------------------------------------------------------
;;  Check size of input
;;----------------------------------------------------------------------------------------
szns           = SIZE(str_in,/N_DIMENSIONS)
outvv          = REPLICATE(null[0],N_ELEMENTS(vv))
test           = (szns[0] EQ 0)
IF (test[0]) THEN BEGIN
  ;;  Scalar input
  IF (vv[0]) THEN outval = int_on[0] ? LONG(str_in[0]) : DOUBLE(str_in[0])
ENDIF ELSE BEGIN
  ;;  Array input
  outval = outvv
  good   = WHERE(vv,gd)
  IF (gd[0] GT 0) THEN BEGIN
    ;;  Found valid numeric strings
    IF (int_on[0]) THEN outval[good] = LONG(str_in[good]) ELSE outval[good] = DOUBLE(str_in[good])
  ENDIF
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,vv
END

