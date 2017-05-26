;+
;*****************************************************************************************
;
;  FUNCTION :   convert_num_type.pro
;  PURPOSE  :   This routine converts a numerical input from one to another type code.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_zeros_mins_maxs_type.pro
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               OLD_VAL   :  Scalar or [N]-element [numeric] array of input values of
;                              input type
;               NEW_TYPE  :  Scalar [numeric] value defining the new type code of the
;                              output values.  Possible values include:
;                                   1  :  BYTE     [8-bit UI]
;                                   2  :  FIX      [16-bit SI]
;                                   3  :  LONG     [32-bit SI]
;                                   4  :  FLOAT    [32-bit, SP, FPN]
;                                   5  :  DOUBLE   [64-bit, DP, FPN]
;                                   6  :  COMPLEX  [32-bit, SP, FPN for Real and Imaginary]
;                                   9  :  DCOMPLEX [64-bit, DP, FPN for Real and Imaginary]
;                                  12  :  UINT     [16-bit UI]
;                                  13  :  ULONG    [32-bit UI]
;                                  14  :  LONG64   [64-bit SI]
;                                  15  :  ULONG64  [64-bit UI]
;
;  EXAMPLES:    
;               [calling sequence]
;               new_val = convert_num_type( old_val, new_type [,NO_ARRAY=no_array] $
;                                          [,ABSOLUTE=absolute]                    )
;
;               ;;******************************************
;               ;;  Good Examples
;               ;;******************************************
;               ;;  Example:  Convert Float to Integer
;               old_val        = 3e0
;               new_typ        = 2L
;               arr_off        = 1b
;               abs__on        = 0b
;               new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
;               HELP,new_val,/STRUC,OUTPUT=output
;               FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;               ;;  NEW_VAL         INT       =        3
;
;               ;;  Example:  Convert Float to Long-Integer
;               old_val        = 3e0
;               new_typ        = 3L
;               arr_off        = 1b
;               abs__on        = 0b
;               new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
;               HELP,new_val,/STRUC,OUTPUT=output
;               FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;               ;;  NEW_VAL         LONG      =            3
;
;               ;;  Example:  Convert Complex to Float [use real part only]
;               old_val        = COMPLEX(3e0,3e0)
;               new_typ        = 4L
;               arr_off        = 1b
;               abs__on        = 0b
;               new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
;               HELP,new_val,/STRUC,OUTPUT=output
;               FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;               ;;  NEW_VAL         FLOAT     =       3.00000
;
;               ;;  Example:  Convert Complex to Float [use absolute value]
;               old_val        = COMPLEX(3e0,3e0)
;               new_typ        = 4L
;               arr_off        = 1b
;               abs__on        = 1b
;               new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
;               HELP,old_val,/STRUC,OUTPUT=outputo
;               HELP,new_val,/STRUC,OUTPUT=outputn
;               FOR j=0L, N_ELEMENTS(outputo) - 1L DO PRINT,';;  '+outputo[j] & $
;               FOR j=0L, N_ELEMENTS(outputn) - 1L DO PRINT,';;  '+outputn[j]
;               ;;  OLD_VAL         COMPLEX   = (      3.00000,      3.00000)
;               ;;  NEW_VAL         FLOAT     =       4.24264
;
;               ;;  Example:  Convert DComplex to Double [use absolute value]
;               old_val        = DCOMPLEX(3d0,4d0)
;               new_typ        = 5L
;               arr_off        = 1b
;               abs__on        = 1b
;               new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
;               HELP,old_val,/STRUC,OUTPUT=outputo
;               HELP,new_val,/STRUC,OUTPUT=outputn
;               FOR j=0L, N_ELEMENTS(outputo) - 1L DO PRINT,';;  '+outputo[j] & $
;               FOR j=0L, N_ELEMENTS(outputn) - 1L DO PRINT,';;  '+outputn[j]
;               ;;  OLD_VAL         DCOMPLEX  = (       3.0000000,       4.0000000)
;               ;;  NEW_VAL         DOUBLE    =        5.0000000
;
;               ;;  Example:  Convert Long64 to DComplex [ABSOLUTE keyword irrelevant for real input]
;               old_val        = 3LL
;               new_typ        = 9L
;               arr_off        = 1b
;               abs__on        = 0b
;               new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
;               HELP,old_val,/STRUC,OUTPUT=outputo
;               HELP,new_val,/STRUC,OUTPUT=outputn
;               FOR j=0L, N_ELEMENTS(outputo) - 1L DO PRINT,';;  '+outputo[j] & $
;               FOR j=0L, N_ELEMENTS(outputn) - 1L DO PRINT,';;  '+outputn[j]
;               ;;  OLD_VAL         LONG64    =                      3
;               ;;  NEW_VAL         DCOMPLEX  = (       3.0000000,       0.0000000)
;
;               ;;******************************************
;               ;;  Bad Examples
;               ;;******************************************
;               ;;  Example:  Undefined required input
;               old_val        = 3e0
;               new_typ        = 2L
;               arr_off        = 1b
;               abs__on        = 0b
;               new_val        = convert_num_type(old_val,new_ttt,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
;               HELP,new_val,/STRUC,OUTPUT=output
;               FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;               % CONVERT_NUM_TYPE: User must define OLD_VAL and NEW_TYPE on input...
;               ;;  NEW_VAL         BYTE      =    0
;
;               ;;  Example:  Unsupported output type
;               old_val        = 3e0
;               new_typ        = 7L
;               arr_off        = 1b
;               abs__on        = 0b
;               new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
;               HELP,new_val,/STRUC,OUTPUT=output
;               FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;               % CONVERT_NUM_TYPE: OLD_VAL and NEW_TYPE must both be a valid IDL numeric type...
;               ;;  NEW_VAL         BYTE      =    0
;
;               ;;  Example:  non-numerical input type
;               old_val        = '3e0'
;               new_typ        = 1L
;               arr_off        = 1b
;               abs__on        = 0b
;               new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
;               HELP,new_val,/STRUC,OUTPUT=output
;               FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;               % CONVERT_NUM_TYPE: OLD_VAL and NEW_TYPE must both be numeric values...
;               ;;  NEW_VAL         BYTE      =    0
;
;               ;;  Example:  "bad" numerical conversions (i.e., out of bounds)
;               arr_off        = 1b
;               abs__on        = 0b
;               ;;  Example:  300.0 to Byte
;               old_val        = 3e2
;               new_typ        = 1L
;               new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
;               HELP,new_val,/STRUC,OUTPUT=output
;               FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;               ;;  NEW_VAL         BYTE      =   44
;
;               ;;  Example:  300000.0 to Integer
;               old_val        = 3e5
;               new_typ        = 2L
;               new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
;               HELP,new_val,/STRUC,OUTPUT=output
;               FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;               ;;  NEW_VAL         INT       =   -27680
;
;               ;;  Example:  signed-input to unsigned output
;               old_val        = -3e0
;               new_typ        = 12L
;               new_val        = convert_num_type(old_val,new_typ,NO_ARRAY=arr_off,ABSOLUTE=abs__on)
;               HELP,new_val,/STRUC,OUTPUT=output
;               FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  '+output[j]
;               ;;  NEW_VAL         UINT      =    65533
;
;  KEYWORDS:    
;               NO_ARRAY  :  If set, routine will convert a single-element array
;                              into a scalar output.
;                              [Default = FALSE]
;               ABSOLUTE  :  If set, routine will use the absolute value of a complex
;                              input rather than separating the real and imaginary parts
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/18/2017   v1.0.0]
;             2)  Continued to write routine
;                                                                   [05/18/2017   v1.0.0]
;             3)  Cleaned up and finished writing
;                                                                   [05/19/2017   v1.0.0]
;
;   NOTES:      
;               1)  Let us define the following:
;                       FPN = floating-point #
;                       SP  = single-precision
;                       DP  = double-precision
;                       UI  = unsigned integer
;                       SI  = signed integer
;               2)  All examples above are for scalar input to make the conversions
;                     more obvious but array inputs are allowed as well
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/17/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/19/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION convert_num_type,old_val,new_type,NO_ARRAY=no_array,ABSOLUTE=absolute

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define allowed number types
all_num_type   = [1,2,3,4,5,6,9,12,13,14,15]
;;  Define allowed types
all_type_str   = get_zeros_mins_maxs_type()     ;;  Get all type info for system
all_ok_type    = all_type_str.TYPES             ;;  i.e., [1L,2L,3L,4L,5L,6L,7L,9L,12L,13L,14L,15L]
;;  Dummy error messages
notstr1msg     = 'User must define OLD_VAL and NEW_TYPE on input...'
notstr2msg     = 'OLD_VAL and NEW_TYPE must both be numeric values...'
notstr3msg     = 'OLD_VAL and NEW_TYPE must both be a valid IDL numeric type...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check for an input
test           = (N_ELEMENTS(old_val) EQ 0) OR (N_ELEMENTS(new_type) EQ 0) OR (N_PARAMS() NE 2)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr1msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_number(old_val,/NOMSSG) EQ 0) OR (is_a_number(new_type,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr2msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check against available types
old_t          = SIZE(old_val,/TYPE)
type_out       = FIX(new_type[0])
test           = (TOTAL(old_t[0] EQ all_num_type) EQ 0) OR (TOTAL(type_out[0] EQ all_num_type) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr3msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NO_ARRAY
test           = (N_ELEMENTS(no_array) GT 0) AND KEYWORD_SET(no_array)
IF (test[0]) THEN array_off = 1b ELSE array_off = 0b
;;  Check ABSOLUTE
test           = (N_ELEMENTS(absolute) GT 0) AND KEYWORD_SET(absolute)
IF (test[0]) THEN abs_on = 1b ELSE abs_on = 0b
;;----------------------------------------------------------------------------------------
;;  Define input functions and intialization
;;----------------------------------------------------------------------------------------
good           = WHERE(all_ok_type EQ old_t[0],gd)
;;  Define type-dependent zero and function name
read__in       = all_type_str.ZEROS.(good[0])
func__in       = all_type_str.FUNCS.(good[0])
;;  Check for complex input
CASE old_t[0] OF
  6L    :  complex_in     = 1b  ;;   6  :  COMPLEX  [32-bit, SP, FPN for Real and Imaginary]
  9L    :  complex_in     = 1b  ;;   9  :  DCOMPLEX [64-bit, DP, FPN for Real and Imaginary]
  ELSE  :  complex_in     = 0b
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Define output functions and intialization
;;----------------------------------------------------------------------------------------
good           = WHERE(all_ok_type EQ type_out[0],gd)
;;  Define type-dependent zero and function name
read_out       = all_type_str.ZEROS.(good[0])
func_out       = all_type_str.FUNCS.(good[0])
;;  Check for complex output
CASE type_out[0] OF
  6L    :  complex_on     = 1b  ;;   6  :  COMPLEX  [32-bit, SP, FPN for Real and Imaginary]
  9L    :  complex_on     = 1b  ;;   9  :  DCOMPLEX [64-bit, DP, FPN for Real and Imaginary]
  ELSE  :  complex_on     = 0b
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Define real and imaginary parts of input, if necessary
;;----------------------------------------------------------------------------------------
IF (complex_in[0]) THEN BEGIN
  ;;  Input type is complex
  IF (abs_on[0]) THEN BEGIN
    ;;  outr = |z| = |x + iy|
    ;;  outi = 0
    rp_oldv = CALL_FUNCTION(func__in[0],ABS(old_val))
    ip_oldv = REPLICATE(read__in[0],N_ELEMENTS(old_val))
  ENDIF ELSE BEGIN
    ;;  outr = Re[z] = Re[x + iy]
    ;;  outi = Im[z] = Im[x + iy]
    rp_oldv = CALL_FUNCTION(func__in[0],REAL_PART(old_val))
    ip_oldv = CALL_FUNCTION(func__in[0],IMAGINARY(old_val))
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Input type is real
  rp_oldv        = old_val
  ip_oldv        = REPLICATE(read__in[0],N_ELEMENTS(old_val))
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
IF (complex_on[0]) THEN BEGIN
  ;;  Output type is complex
  new_val0       = CALL_FUNCTION(func_out[0],rp_oldv,ip_oldv)
ENDIF ELSE BEGIN
  ;;  Output type is real
  new_val0       = CALL_FUNCTION(func_out[0],rp_oldv)
ENDELSE
;;  Check NO_ARRAY settings
test           = (N_ELEMENTS(new_val0) EQ 1) AND array_off[0]
IF (test[0]) THEN new_val = new_val0[0] ELSE new_val = new_val0
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,new_val
END

