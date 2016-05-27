;+
;NAME:
; cdf2idltype
;PURPOSE:
; Return an IDL type number given a CDF data type
;CALLING SEQUENCE:
; idl_type = cdf2idltype(code)
;INPUT:
; code = the CDF data type code for that variable
;OUTPUT:
; idl_type = the type number for the appropriate IDL variable
; CDF_TYPE      IDL_TYPE
;'CDF_UINT1'    1 (byte)
;'CDF_UCHAR'    1 (byte)
;'CDF_BYTE'     2 (int)
;'CDF_INT1'     2 (int)
;'CDF_INT2'     2 (int)
;'CDF_INT4'     3 (long)
;'CDF_FLOAT'    4 (float)
;'CDF_REAL4'    4 (float)
;'CDF_DOUBLE'   5 (double)
;'CDF_REAL8'    5 (double)
;'CDF_CHAR'     7 (string)
;'CDF_UINT2'    12 (unsigned int)
;'CDF_UINT4'    13 (unsigned long)
;'CDF_INT8'     14 (long64)
;'CDF_UINT8'    15 (unsigned long64)
; There are some CDF types that have no corresponding IDL type,
; e.g., CDF_BYTE and CDF_INT1 are signed bytes, here we return a type
; code of 2 (signed integer), The EPOCH and TT2000 are not handled
; here, and will return a code of 0
;HISTORY:
; 26-nov-2013, jmm, jimm@ssl.berkeley.edu
; $LastChangedBy: jimm $
; $LastChangedDate: 2013-11-26 12:22:47 -0800 (Tue, 26 Nov 2013) $
; $LastChangedRevision: 13597 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/CDF/cdf2idltype.pro $
;-
Function cdf2idltype, code

otp = 0

Case strupcase(strcompress(code,/remove_all)) Of
    'CDF_UINT1': otp = 1
    'CDF_UCHAR': otp = 1
    'CDF_BYTE': otp = 2
    'CDF_INT1': otp = 2
    'CDF_INT2': otp = 2
    'CDF_INT4': otp = 3
    'CDF_FLOAT': otp = 4
    'CDF_REAL4': otp = 4
    'CDF_DOUBLE': otp = 5
    'CDF_REAL8': otp = 5
    'CDF_CHAR': otp = 7
    'CDF_UINT2': otp = 12
    'CDF_UINT4': otp = 13
    'CDF_INT8': otp = 14
    'CDF_UINT8': otp = 15
    ELSE: otp = 0
Endcase

Return, otp

End
