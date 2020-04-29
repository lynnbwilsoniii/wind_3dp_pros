;+
;*****************************************************************************************
;
;  FUNCTION :   fill_nan.pro
;  PURPOSE  :   This routine replaces the internals of any input DATA with an optional
;                 user-defined scalar value.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               fill_nan.pro
;
;  REQUIRES:    
;               1)  SPEDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA      :  Any numeric or structure type to be filled with INTFILL
;
;  EXAMPLES:    
;               [calling sequence]
;               fdat = fill_nan(data [,INTFILL=intfill])
;
;  KEYWORDS:    
;               INTFILL  :  Scalar value to use as a filler for internals of DATA
;                             but only for non-floating point input types (i.e., integer
;                             types only)
;                             [Default = 0]
;
;   CHANGED:  1)  Routine last modified by ??
;                                                                   [??/??/????   v1.0.0]
;             2)  Routine and Man. page updated
;                                                                   [02/20/2020   v1.0.1]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   CREATED:  ??/??/????
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/20/2020   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION fill_nan,data,INTFILL=intfill

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_intf       = 0
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check INTFILL
IF (N_ELEMENTS(intfill) EQ 0) THEN intfill = def_intf[0]
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
dt             = SIZE(data,/TYPE)
rdat           = data
CASE dt[0] OF
  1     :  rdat[*] = BYTE(intfill[0])       ;;  Byte                             [8-bit]
  2     :  rdat[*] = FIX(intfill[0])        ;;  Integer                          [16-bit]
  3     :  rdat[*] = LONG(intfill[0])       ;;  Long Integer                     [32-bit]
  4     :  rdat[*] = f[0]                   ;;  Single Precision Float           [32-bit]
  5     :  rdat[*] = d[0]                   ;;  Double Precision Float           [64-bit]
  6     :  rdat[*] = COMPLEX(f[0])          ;;  Single Precision Complex Float   [32-bit]
  7     :  rdat[*] = ''                     ;;  String
  8     :  BEGIN                            ;;  Structure
    n  = N_TAGS(rdat)
    FOR i=0L, n[0] - 1L DO rdat.(i) = fill_nan(rdat.(i),INTFILL=intfill[0])
  END
  9     :  rdat[*] = DCOMPLEX(d[0])         ;;  Double Precision Complex Float   [64-bit]
  12    :  rdat[*] = UINT(intfill[0])       ;;  Unsigned Integer                 [16-bit]
  13    :  rdat[*] = ULONG(intfill[0])      ;;  Unsigned Long Integer            [32-bit]
  14    :  rdat[*] = LONG64(intfill[0])     ;;  Long64 Integer                   [64-bit]
  15    :  rdat[*] = ULONG64(intfill[0])    ;;  Unsigned Long64 Integer          [64-bit]
  ELSE  :  MESSAGE,/INFO,'Data type not implemented'
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,rdat
END

