;+
;*****************************************************************************************
;
;  FUNCTION :   t_get_struc_unix.pro
;  PURPOSE  :   This routine gets the Unix time from an input TPLOT structure.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               tplot_struct_format_test.pro
;               struct_value.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STRUC          :  Scalar [structure] defining a valid TPLOT structure
;                                   from which the user wishes to extract the Unix
;                                   time stamps
;
;                                   The required structure tags for STRUC are:
;                                     X  :  [N]-Element array of Unix times
;                                     Y  :  [N,3]-Element array of 3-vectors
;
;                                   If the TSHIFT tag is present, the routine will assume
;                                   that STRUC.X is seconds from STRUC.TSHIFT[0].
;
;  EXAMPLES:    
;               [calling sequence]
;               unix = t_get_struc_unix(struc [,TSHFT_ON=tshft_on])
;
;  KEYWORDS:    
;               TSHFT_ON       :  Set to a named variable to return whether the TSHIFT
;                                   structure tag exists (TRUE) or does not (FALSE)
;                                   within the input STRUC
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This routine is mostly to reduce repetition in testing TPLOT
;                     structures for the TSHIFT tag and to prevent errors of omission
;                     when interpolating to time stamps but only include values from
;                     the X structure tag.
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/29/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/29/2016   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION t_get_struc_unix,struc,TSHFT_ON=tshft_on

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
no_inpt_msg    = 'User must supply an IDL structure...'
baddfor_msg    = 'Incorrect input format:  STRUC must be an IDL TPLOT structure'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (SIZE(struc,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check if TPLOT structure
test           = (tplot_struct_format_test(struc,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,baddfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get structure values
;;----------------------------------------------------------------------------------------
xx             = struct_value(struc,'X',DEFAULT=0d0,INDEX=index_x)
xo             = struct_value(struc,'TSHIFT',DEFAULT=0d0,INDEX=index_ts)
;;  Define output test
tshft_on       = (index_ts[0] GE 0)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,xx + xo[0]
END


