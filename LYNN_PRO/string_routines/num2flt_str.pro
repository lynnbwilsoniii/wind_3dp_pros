;+
;*****************************************************************************************
;
;  FUNCTION :   num2flt_str.pro
;  PURPOSE  :   This routine converts an input number to a string output using the
;                 floating point format code.  The user can explicitly define the
;                 length and number of decimal places desired.
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
;                              converted to strings with a floating point format
;
;  EXAMPLES:    
;               [calling sequence]
;               flt_str = num2flt_str( input [,NUM_CHAR=num_char] [,NUM_DEC=num_dec] $
;                                            [,/NO_TRIM] [,/RM_PERI])
;
;               ;;  Output WITHOUT any keywords
;               input          = [-2,300,5e5,4d0,15]
;               PRINT,';;',num2flt_str(input)
;               ;; -2.0000 300.0000 500000.0000 4.0000 15.0000
;
;               ;;  Output WITH excess empty spaces
;               input          = [-2,300,5e5,4d0,15]
;               PRINT,';;',num2flt_str(input,/NO_TRIM)
;               ;;      -2.0000     300.0000  500000.0000       4.0000      15.0000
;
;               ;;  Output with limited decimal places
;               num_char       = 12L
;               num_dec        =  2L
;               input          = [-2.31738,300.95313,5.15287331e5,4.988237385d0,15.135343e0]
;               PRINT,';;',num2flt_str(input,NUM_CHAR=num_char,NUM_DEC=num_dec,/NO_TRIM)
;               ;;        -2.32       300.95    515287.34         4.99        15.14
;
;               ;;  Output without decimal places [1st approach]
;               num_char       = 12L
;               num_dec        =  0L
;               input          = [-2.31738,300.95313,5.15287331e5,4.988237385d0,15.135343e0]
;               PRINT,';;',num2flt_str(input,NUM_CHAR=num_char,NUM_DEC=num_dec,/NO_TRIM)
;               ;;          -2         301      515287           5          15
;
;               ;;  Output without decimal places [2nd approach]
;               num_char       = 12L
;               num_dec        =  4L
;               input          = [-2.31738,300.95313,5.15287331e5,4.988237385d0,15.135343e0]
;               PRINT,';;',num2flt_str(input,NUM_CHAR=num_char,NUM_DEC=num_dec,/NO_TRIM,/RM_PERI)
;               ;;      -2     300  515287       4      15
;
;               ;;  Make sure NUM_CHAR is large enough otherwise output is a string of asterisks
;               ;;    NUM_CHAR characters in length [e.g., see below]
;               num_char       =  4L
;               num_dec        =  1L
;               input          = [-2.31738,300.95313,5.15287331e5,4.988237385d0,15.135343e0]
;               PRINT,';;',num2flt_str(input,NUM_CHAR=num_char,NUM_DEC=num_dec,/NO_TRIM)
;               ;; -2.3 **** ****  5.0 15.1
;
;               ;;  Output after using bad keyword settings
;               ;;    Routine alters user defined NUM_DEC as best as possible
;               num_char       =  4L
;               num_dec        =  4L
;               input          = [-2.31738,300.95313,5.15287331e5,4.988237385d0,15.135343e0]
;               PRINT,';;',num2flt_str(input,NUM_CHAR=num_char,NUM_DEC=num_dec,/NO_TRIM)
;               ;; -2.3 **** ****  5.0 15.1
;
;  KEYWORDS:    
;               NUM_CHAR  :  Scalar [integer/long] defining the number of characters to
;                              include in the format statement.  For instance, if the
;                              value were set to 4 then the format code used would be
;                              '(f4.x)'.  The routine will not try to correct a bad
;                              setting here, so the user should be aware of the possible
;                              output of repeated '*' characters of length NUM_CHAR if
;                              the value is too small.
;                              [Default = 12]
;               NUM_DEC   :  Scalar [integer/long] defining the number of decimal places
;                              to include in the format statement.  For instance, if the
;                              value were set to 4 then the format code used would be
;                              '(fx.4)'.  The routine will try to keep this value
;                              smaller than NUM_CHAR to avoid repeated '*' characters
;                              on output.
;                              [Default = 4]
;               NO_TRIM   :  If set, routine will not remove leading or trailing empty
;                              character spaces on output.
;                              [Default = FALSE]
;               RM_PERI   :  If set, routine will remove the decimal character and all
;                              characters beyond without rounding or changing anything
;                              to the left of the decimal place.  If the NUM_DEC value
;                              is set to zero, it will cause this keyword to be TRUE.
;                              However, in this latter case there may be rounding.
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

FUNCTION num2flt_str,input,NUM_CHAR=num_char,NUM_DEC=num_dec,NO_TRIM=no_trim,RM_PERI=rm_peri

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
max_nc         = 255L                  ;;  Max. # of character width in format code
def_nch        = 12L                   ;;  Default character width
def_dec        =  4L                   ;;  Default # of decimal places
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
  n_char    = LONG(num_char[0])
  exp_nc_on = 1b
ENDIF ELSE BEGIN
  n_char    = def_nch[0]
  exp_nc_on = 0b
ENDELSE
;;  Check NUM_DEC
test_nc        = ((N_ELEMENTS(num_dec) GT 0) AND is_a_number(num_dec,/NOMSSG))
IF (test_nc[0]) THEN test_nc = (LONG(num_dec[0]) GE 0) AND (LONG(num_dec[0]) LE (n_char[0] - 3L))
IF (test_nc[0]) THEN BEGIN
  n_deci    = LONG(num_dec[0])
  dec_nc_on = 1b
ENDIF ELSE BEGIN
  n_deci    = (def_dec[0] < (n_char[0] - 3L)) > 0L
  dec_nc_on = 0b
ENDELSE
;;  Check NO_TRIM
test           = (N_ELEMENTS(no_trim) EQ 1) AND KEYWORD_SET(no_trim)
IF (test[0]) THEN trim = 0b ELSE trim = 1b
;;  Check RM_PERI
test           = ((N_ELEMENTS(rm_peri) EQ 1) AND KEYWORD_SET(rm_peri)) OR (n_deci[0] EQ 0)
IF (test[0]) THEN rmperi = 1b ELSE rmperi = 0b
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
nch_str        = STRTRIM(STRING(nch[0],FORMAT='(I)'),2L)
dec_str        = STRTRIM(STRING(ndc[0],FORMAT='(I)'),2L)
;;  Define format code
mform          = '(f'+nch_str[0]+'.'+dec_str[0]+')'
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
output0        = STRING(inv,FORMAT=mform[0])
IF (trim[0]) THEN output = STRTRIM(output0,2L) ELSE output = output0
IF (rmperi[0]) THEN BEGIN
  gposi          = STRPOS(output,'.')
  no             = N_ELEMENTS(output)
  out0           = output
  FOR k=0L, no[0] - 1L DO out0[k] = STRMID(output[k],0L,gposi[k])
  ;;  Redefine output
  output         = out0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END
