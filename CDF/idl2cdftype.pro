;+
;NAME:
; idl2cdftype
;PURPOSE:
; Given an IDL variable, return the appropriate CDF type code
;CALLING SEQUENCE:
; code = idl2cdftype(var, format_out=format_out,
;        fillval_out=fillval_out, validmin_out=validmin_out,
;        validmax_out=validmax_out)
;INPUT:
; var = an IDL variable
;OUTPUT:
; code = the CDF data type code for that variable, if applicable, for
;        objects, complex,  and similar vars a null string is returned.
;    IDL_TYPE             CDF_TYPE
;    1 (byte)             'CDF_UINT1'
;    2 (int)              'CDF_INT2'
;    3 (long)             'CDF_INT4'
;    4 (float)            'CDF_FLOAT'
;    5 (double)           'CDF_DOUBLE'
;    7 (string)           'CDF_CHAR'
;    12 (unsigned int)    'CDF_UINT2'
;    13 (unsigned long)   'CDF_UINT4'
;    14 (long64)          'CDF_INT8'
;    15 (unsigned long64) 'CDF_UINT8'
;KEYWORDS:
; format_out = return a format code for the data type
;    1 (byte)             'I4'
;    2 (int)              'I6'
;    3 (long)             'I10'
;    4 (float)            'E13.6'
;    5 (double)           'E20.12'
;    7 (string)           strlen(value)
;    12 (unsigned int)    'I6'
;    13 (unsigned long)   'I10'
;    14 (long64)          'I20'
;    15 (unsigned long64) 'I20'
; fillval_out = a fill value
;    1 (byte)             255
;    2 (int)              -32768
;    3 (long)             -2147483648
;    4 (float)            !values.f_nan
;    5 (double)           !values.d_nan
;    7 (string)           ''
;    12 (unsigned int)    65535
;    13 (unsigned long)   4294967295
;    14 (long64)          -9223372036854775808
;    15 (unsigned long64) 18446744073709551615
; validmin_out = a min value
;    1 (byte)             0
;    2 (int)              -32768
;    3 (long)             -2147483648
;    4 (float)            -1.0e38
;    5 (double)           -1.0e308
;    7 (string)           'NA'
;    12 (unsigned int)    0
;    13 (unsigned long)   0
;    14 (long64)          -9223372036854775808
;    15 (unsigned long64) 0
; validmax_out = a max value
;    1 (byte)             255
;    2 (int)              32767
;    3 (long)             2147483647
;    4 (float)            1.0e38
;    5 (double)           1.0e308
;    7 (string)           'NA'
;    12 (unsigned int)    65535
;    13 (unsigned long)   4294967295
;    14 (long64)          -9223372036854775808
;    15 (unsigned long64) 18446744073709551615
;HISTORY:
; 26-nov-2013, jmm, jimm@ssl.berkeley.edu
; $LastChangedBy: jimm $
; $LastChangedDate: 2014-10-14 11:39:46 -0700 (Tue, 14 Oct 2014) $
; $LastChangedRevision: 15992 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/CDF/idl2cdftype.pro $
;-
Function idl2cdftype, var, format_out=format_out, fillval_out=fillval_out, $
                      validmin_out=validmin_out, validmax_out=validmax_out, _extra=_extra
;INPUT:

otp = ''
Case(size(var, /type)) Of        ;text code for type
    1: Begin
       otp = 'CDF_UINT1'
       format_out = 'I4'
       fillval_out = 255
       validmin_out = 0
       validmax_out = 255
    End
    2: Begin
       otp = 'CDF_INT2'
       format_out = 'I6'
       fillval_out = fix(-32768)     ;note that IDL changes -32768 to 4 bytes, CDF_INT4
       validmin_out = -32767
       validmax_out = 32767
    End
    3: Begin
       otp = 'CDF_INT4'
       format_out = 'I11'
       fillval_out = long(-2147483648) ;same here, 
       validmin_out = -2147483647
       validmax_out = 2147483647
    End
    4: Begin
       otp = 'CDF_FLOAT'
       format_out = 'E13.6'
       fillval_out = -1.0e31
       validmin_out = -1.0e31
       validmax_out = 1.0e31
    End
    5: Begin
       otp = 'CDF_DOUBLE'
       format_out = 'E25.18'
       fillval_out = double(-1.0d31)
       validmin_out = double(-1.0d31)
       validmax_out = double(1.0d31)
    End
    7: Begin
       otp = 'CDF_CHAR'
       format_out = 'A'+strcompress(/remove_all, string(strlen(var[0])+1))
       fillval_out = ''
       validmin_out = 'NA'
       validmax_out = 'NA'
    End
    12: Begin
       otp = 'CDF_UINT2'
       format_out = 'I6'
       fillval_out = 65535
       validmin_out = 0
       validmax_out = 65535
    End
    13: Begin
       otp = 'CDF_UINT4'
       format_out = 'I11'
       fillval_out = 4294967295
       validmin_out = 0
       validmax_out = 4294967295
    End
    14: Begin
       otp = 'CDF_INT8'
       format_out = 'I21'
       fillval_out = long64(-9223372036854775808)
       validmin_out = -9223372036854775807
       validmax_out =  9223372036854775807
    End
    15: Begin
       otp = 'CDF_UINT8'
       format_out = 'I21'
       fillval_out = 18446744073709551615
       validmin_out = 0
       validmax_out = 18446744073709551615
    End
    Else: otp = ''
Endcase

Return, otp
End
