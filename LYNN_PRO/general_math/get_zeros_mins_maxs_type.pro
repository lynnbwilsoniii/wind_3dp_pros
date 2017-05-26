;+
;*****************************************************************************************
;
;  FUNCTION :   get_zeros_mins_maxs_type.pro
;  PURPOSE  :   This routine returns system-specific values for the allowed type-
;                 dependent minima, maxima, zeros, and type-conversion function names
;                 for all types except for structures, pointers, objects, and undefined
;                 values.
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
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               zmx = get_zeros_mins_maxs_type()
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Fixed a typo where I forgot to use the system-dependent min/max
;                   floating-point values in the output structures
;                                                                   [05/19/2017   v1.0.1]
;
;   NOTES:      
;               1)  Below are the available/allowed type codes handled by this routine:
;                     TYPE  :  Scalar [integer/long] defining the type code of the prompt
;                                input and output.  Let us define the following:
;                                     FPN = floating-point #
;                                     SP  = single-precision
;                                     DP  = double-precision
;                                     UI  = unsigned integer
;                                     SI  = signed integer
;                                Possible values include:
;                                   1  :  BYTE     [8-bit UI]
;                                   2  :  FIX      [16-bit SI]
;                                   3  :  LONG     [32-bit SI]
;                                   4  :  FLOAT    [32-bit, SP, FPN]
;                                   5  :  DOUBLE   [64-bit, DP, FPN]
;                                   6  :  COMPLEX  [32-bit, SP, FPN for Real and Imaginary]
;                                   7  :  STRING   [0 to 2147483647 characters]
;                                   9  :  DCOMPLEX [64-bit, DP, FPN for Real and Imaginary]
;                                  12  :  UINT     [16-bit UI]
;                                  13  :  ULONG    [32-bit UI]
;                                  14  :  LONG64   [64-bit SI]
;                                  15  :  ULONG64  [64-bit UI]
;                   Bascially, all codes except for structures, pointers, objects, and
;                   undefined values are handled.
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/18/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/19/2017   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_zeros_mins_maxs_type

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Define system-based defaults (values may differ slightly from documentation)
;;----------------------------------------------------------------------------------------
;;  Define system-based bits
max_bits       = LONG(!VERSION.MEMORY_BITS[0])
;;  Define defaults for floating-point math
machine_f      = MACHAR()               ;;  Floating-point info (single-precision)
machine_d      = MACHAR(/DOUBLE)        ;;  Floating-point info (double-precision)
def_min_f      = -1e0*machine_f.XMAX    ;;  Minimum allowed floating-point number (single-precision)
def_max_f      =  1e0*machine_f.XMAX    ;;  Maximum allowed floating-point number (single-precision)
def_min_d      = -1d0*machine_d.XMAX    ;;  Minimum allowed floating-point number (double-precision)
def_max_d      =  1d0*machine_d.XMAX    ;;  Maximum allowed floating-point number (double-precision)
;;  Define defaults for integer math
radix          = machine_f.IBETA        ;;  base numeration value (should be 2 for most machines)
;;                0  1    2   3   4   5     6         7   8   9   10   11
;;                B  I    L   F   D   C     S        DC  UI  UL  L64 UL64
all_ok_bits    = [8L,16L,32L,32L,64L,32L,max_bits[0],64L,16L,32L,64L, 64L]
sign_exp       = all_ok_bits - 1L
usgn_exp       = all_ok_bits
;;  Define defaults for max for unsigned integer math
def_max_b      =    BYTE(radix[0])^usgn_exp[0] - 1B
def_max_ui     =    UINT(radix[0])^usgn_exp[8] - 1U
def_max_ul     =   ULONG(radix[0])^usgn_exp[9] - 1UL
def_max_ul64   = ULONG64(radix[0])^usgn_exp[11] - 1ULL
;;  Define defaults for min and max for signed integer math
def_max_i      =    FIX(radix[0])^sign_exp[1] - 1S
def_max_l      =   LONG(radix[0])^sign_exp[2] - 1L
def_max_l64    = LONG64(radix[0])^sign_exp[10] - 1LL
def_min_i      =   def_max_i[0] + 1S
def_min_l      =   def_max_l[0] + 1L
def_min_l64    = def_max_l64[0] + 1LL
;;  Initialize outputs
value_out      = 0.
;;----------------------------------------------------------------------------------------
;;  Define available/allowed parameters
;;----------------------------------------------------------------------------------------
;;  Define allowed types
all_ok_type    = [1L,2L,3L,4L,5L,6L,7L,9L,12L,13L,14L,15L]
;;  Define allowed type minima
all_ok_mins    = {B:0B,IN:def_min_i[0],L:def_min_l[0],F:def_min_f[0],D:def_min_d[0],   $
                  C:COMPLEX(def_min_f[0],def_min_f[0]), S:'',                          $
                  DC:DCOMPLEX(def_min_d[0],def_min_d[0]),UI:0U,UL:0UL,                 $
                  L64:def_min_l64[0],UL64:0ULL}
;;  Define allowed type maxima
all_ok_maxs    = {B:def_max_b[0],IN:def_max_i[0],L:def_max_l[0],F:def_max_f[0],        $
                  D:def_max_d[0],C:COMPLEX(def_max_f[0],def_max_f[0]),S:'',            $
                  DC:DCOMPLEX(def_max_d[0],def_max_d[0]),UI:def_max_ui[0],             $
                  UL:def_max_ul[0],L64:def_max_l64[0],UL64:def_max_ul64[0]}
;;  Define allowed type zeros
all_ok_zero    = {B:0B,IN:0S,L:0L,F:0e0,D:0d0,C:COMPLEX(0e0,0e0), $
                  S:'',DC:DCOMPLEX(0d0,0d0),UI:0U,UL:0UL,L64:0LL,$
                  UL64:0ULL}
;;  Define allowed type conversion function names
all_ok_func    = {B:'BYTE',IN:'FIX',L:'LONG',F:'FLOAT',D:'DOUBLE',C:'COMPLEX', $
                  S:'STRING',DC:'DCOMPLEX',UI:'UINT',UL:'ULONG',L64:'LONG64',$
                  UL64:'ULONG64'}
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
tags           = ['TYPES','MINS','MAXS','ZEROS','FUNCS']
struct         = CREATE_STRUCT(tags,all_ok_type,all_ok_mins,all_ok_maxs,all_ok_zero,all_ok_func)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END
