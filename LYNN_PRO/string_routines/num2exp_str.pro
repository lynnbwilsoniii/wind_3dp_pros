;+
;*****************************************************************************************
;
;  FUNCTION :   num2exp_str.pro
;  PURPOSE  :   This routine converts an input number to a string output using the
;                 exponential format code.  The user can explicitly define the length
;                 and number of decimal places desired in addition to the character
;                 length of the numeric part of the exponent.
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
;                              converted to strings with a exponential (E) format
;
;  EXAMPLES:    
;               [calling sequence]
;               exp_str = num2exp_str(input [,NUM_CHAR=num_char] [,NUM_DEC=num_dec] $
;                                           [,NUM_EXP=num_exp] [,/NO_TRIM])
;
;               ;;  Output WITHOUT any keywords
;               input          = [-2,300,5e5,4d0,15]
;               PRINT,';;',num2exp_str(input)
;               ;; -2.0000E+00 +3.0000E+02 +5.0000E+05 +4.0000E+00 +1.5000E+01
;
;               ;;  Output WITH excess empty spaces
;               input          = [-2,300,5e5,4d0,15]
;               PRINT,';;',num2exp_str(input,/NO_TRIM)
;               ;;  -2.0000E+00  +3.0000E+02  +5.0000E+05  +4.0000E+00  +1.5000E+01
;
;               ;;  Output with limited decimal places
;               num_char       = 12L
;               num_dec        =  2L
;               input          = [-2.31738,300.95313,5.15287331e5,4.988237385d0,15.135343e0]
;               PRINT,';;',num2exp_str(input,NUM_CHAR=num_char,NUM_DEC=num_dec,/NO_TRIM)
;               ;;    -2.32E+00    +3.01E+02    +5.15E+05    +4.99E+00    +1.51E+01
;
;               ;;  Make sure NUM_CHAR is large enough otherwise output is forced to a new
;               ;;    format that is not consistent with the user defined settings
;               num_char       =  4L
;               num_dec        =  1L
;               input          = [-2.31738,300.95313,5.15287331e5,4.988237385d0,15.135343e0]
;               PRINT,';;',num2exp_str(input,NUM_CHAR=num_char,NUM_DEC=num_dec,/NO_TRIM)
;               ;; -2.E+00 +3.E+02 +5.E+05 +5.E+00 +2.E+01
;
;
;               ;;  Output after using bad keyword settings
;               ;;    Notice the 3rd element from zero is now ~500,000 instead of
;               ;;    ~10^(105)
;               num_char       = 12L
;               num_dec        =  2L
;               num_exp        =  1L
;               input          = [-2.31738,300.95313,5.15287331e5,4.988237385d105,15.135343e0]
;               PRINT,';;',num2exp_str(input,NUM_CHAR=num_char,NUM_DEC=num_dec,NUM_EXP=num_exp,/NO_TRIM)
;               ;;    -2.32E+0    +3.01E+2    +5.15E+5   +4.99E+5    +1.51E+1
;
;               ;;  Proper NUM_EXP setting (if not an odd choice)
;               num_char       = 15L
;               num_dec        =  3L
;               num_exp        =  5L
;               input          = [-2.31738,300.95313,5.15287331e5,4.988237385d105,15.135343e0]
;               PRINT,';;',num2exp_str(input,NUM_CHAR=num_char,NUM_DEC=num_dec,NUM_EXP=num_exp,/NO_TRIM)
;               ;;      -2.317E+00000      +3.010E+00002      +5.153E+00005     +4.988E+00105      +1.514E+00001
;
;  KEYWORDS:    
;               NUM_CHAR  :  Scalar [integer/long] defining the number of characters to
;                              include in the format statement.  For instance, if the
;                              value were set to 7 then the format code used would be
;                              '(e+7.x)'.  The routine will not try to correct a bad
;                              setting here, so the user should be aware of the possible
;                              output of repeated '*' characters of length NUM_CHAR if
;                              the value is too small.  However, the routine will limit
;                              any input value to being at least 7.
;                              [Default = 12]
;               NUM_DEC   :  Scalar [integer/long] defining the number of decimal places
;                              to include in the format statement.  For instance, if the
;                              value were set to 4 then the format code used would be
;                              '(e+x.4)'.  The routine will try to keep this value
;                              smaller than NUM_CHAR to avoid repeated '*' characters
;                              on output.
;                              [Default = 4]
;               NUM_EXP   :  Scalar [integer/long] defining the number of numeric values
;                              in the exponent, not including the sign.  Forcing this
;                              value can be useful for fixed-width outputs.
;                              [Default = 2]
;               NO_TRIM   :  If set, routine will not remove leading or trailing empty
;                              character spaces on output.
;                              [Default = FALSE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This routine does not try to help the user much, so proper input
;                     formats should be used.
;               2)  The variable INPUT is converted to a DOUBLE prior converting
;                     to a string unless INPUT is complex in which case the output is
;                     is zero byte
;               3)  The default NUM_CHAR value is 12 unless INPUT is a really large
;                     value
;               4)  The input must be of real, numeric type
;
;  REFERENCES:  
;               NA
;
;   CREATED:  02/20/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/20/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION num2exp_str,input,NUM_CHAR=num_char,NUM_DEC=num_dec,NUM_EXP=num_exp,NO_TRIM=no_trim

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
max_nc         = 255L                  ;;  Max. # for character width in format code
min_nch        =  7L                   ;;  Min. # for character width
def_nch        = 12L                   ;;  Default character width
def_dec        =  4L                   ;;  Default # of decimal places
def_exp        =  2L                   ;;  Default # of characters for numeric part-only of exponent
;;  Dummy error messages
no_inpt_msg    = 'User must supply either a scalar or [n]-element [numeric] array of values...'
cmplxin_msg    = 'INPUT must be a real scalar or [n]-element [numeric] array of values...'
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
  n_char    = LONG(num_char[0]) > min_nch[0]
  exp_nc_on = 1b
ENDIF ELSE BEGIN
  n_char    = def_nch[0]
  exp_nc_on = 0b
ENDELSE
;;  Check NUM_DEC
test_nc        = ((N_ELEMENTS(num_dec) GT 0) AND is_a_number(num_dec,/NOMSSG))
IF (test_nc[0]) THEN test_nc = (LONG(num_dec[0]) GE 0) AND (LONG(num_dec[0]) LE (n_char[0] - 7L))
IF (test_nc[0]) THEN BEGIN
  n_deci    = LONG(num_dec[0])
  dec_nc_on = 1b
ENDIF ELSE BEGIN
  n_deci    = (def_dec[0] < (n_char[0] - 7L)) > 0L
  dec_nc_on = 0b
ENDELSE
;;  Check NUM_EXP
test_nc        = ((N_ELEMENTS(num_exp) GT 0) AND is_a_number(num_exp,/NOMSSG))
IF (test_nc[0]) THEN test_nc = (LONG(num_exp[0]) GT 0) AND (LONG(num_exp[0]) LE 6L)
IF (test_nc[0]) THEN BEGIN
  n_expn    = (LONG(num_exp[0]) < 6L) > 1L
  exp_nc_on = 1b
ENDIF ELSE BEGIN
  n_expn    = def_exp[0]
  exp_nc_on = 0b
ENDELSE
;;  Check NO_TRIM
test           = (N_ELEMENTS(no_trim) EQ 1) AND KEYWORD_SET(no_trim)
IF (test[0]) THEN trim = 0b ELSE trim = 1b
;;----------------------------------------------------------------------------------------
;;  Define output format code
;;----------------------------------------------------------------------------------------
;;  Convert input to a double
test           = (TOTAL(SIZE(input,/TYPE) EQ [6,9]) GT 0)
IF (test[0]) THEN BEGIN
  ;;  Input is complex --> Return to user with message
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF ELSE BEGIN
  ;;  Force double precision type
  inv = DOUBLE(input)
ENDELSE
;;  Define the character length
nch            = LONG(n_char[0])
;;  Define the decimal places length
ndc            = LONG(n_deci[0])
;;  Define the length of the numeric part of the exponent
nex            = LONG(n_expn[0])
nch_str        = STRTRIM(STRING(nch[0],FORMAT='(I)'),2L)
dec_str        = STRTRIM(STRING(ndc[0],FORMAT='(I)'),2L)
exp_str        = STRTRIM(STRING(nex[0],FORMAT='(I)'),2L)
;;  Define format code
mform          = '(E+'+nch_str[0]+'.'+dec_str[0]+')'
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
output0        = STRING(inv,FORMAT=mform[0])
IF (trim[0]) THEN output = STRTRIM(output0,2L) ELSE output = output0
IF (exp_nc_on[0]) THEN BEGIN
  ;;  User wants to explicitly format the numeric value of the exponent
  gposi          = STRPOS(output,'E') + 2L   ;;  +2 for sign
  no             = N_ELEMENTS(output)
  dumb0          = STRJOIN(REPLICATE('0',15L),/SINGLE)
  out0           = output
  FOR k=0L, no[0] - 1L DO BEGIN
    temp    = STRMID(output[k],0L,gposi[k])
    texp    = STRMID(output[k],gposi[k])
    slen    = STRLEN(texp[0])
    diff    = n_expn[0] - slen[0]
    IF (diff[0] LT 0) THEN BEGIN
      ;;  Exponent is too long
      sexp    = LONG(ABS(diff[0])) < (slen[0] - 1L)
      nexp    = STRMID(texp[0],sexp[0])
      ;;  Define output
      out0[k] = temp[0]+nexp[0]
    ENDIF ELSE BEGIN
      IF (diff[0] GT 0) THEN BEGIN
        ;;  Exponent is too short
        sexp    = diff[0] < STRLEN(dumb0)
        nexp    = STRMID(dumb0[0],0L,sexp[0])+texp[0]
        ;;  Define output
        out0[k] = temp[0]+nexp[0]
      ENDIF ELSE BEGIN
        ;;  Exponents already proper length
        out0[k] = output[k]
      ENDELSE
    ENDELSE
  ENDFOR
  ;;  Redefine output
  output         = out0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END
