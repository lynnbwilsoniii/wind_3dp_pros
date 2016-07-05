;+
;*****************************************************************************************
;
;  FUNCTION :   test_tplot_handle.pro
;  PURPOSE  :   This is an error handling routine that verifies the existence and format
;                 of an input TPLOT handle.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               tnames.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TPNAME       :  Scalar or [N]-element [string or integer] array defining
;                                 the TPLOT handle(s) the user wishes to verify
;
;  EXAMPLES:    
;               test = test_tplot_handle(tpname,TPNMS=tpnms)
;
;  KEYWORDS:    
;               TPNMS        :  Set to a named variable to return the valid TPLOT
;                                 handle(s) from the input TPNAME
;               GIND         :  Set to a named variable to return the indices of the
;                                 valid TPLOT handle(s) of TPNAME corresponding to
;                                 TPNMS, i.e., TPNMS = TPNAME[GIND]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [10/20/2015   v1.0.0]
;             2)  Added keyword:  GIND
;                                                                   [11/12/2015   v1.1.0]
;             3)  Fixed an issue caused by using GIND with an input in the index form
;                                                                   [11/12/2015   v1.1.1]
;
;   NOTES:      
;               1)  See also:  tnames.pro
;               2)  tnames.pro cannot handle multi-dimensional arrays, so make sure
;                     that the input is only a one-dimensional array
;
;  REFERENCES:  
;               NA
;
;   CREATED:  10/10/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/12/2015   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION test_tplot_handle,tpname,TPNMS=tpnms,GIND=gind

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, tnames
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
tpnms          = ''            ;;  Start with default output of no valid handles
gind           = -1            ;;  Initialize with no matches
;;  Error messages
noinput_mssg   = 'No input was supplied...'
badinpt_mssg   = 'Incorrect input format was supplied:  TPNAME must be a string or number'
no_tpns_mssg   = 'No TPLOT handles match TPNAME input...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (N_ELEMENTS(tpname) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_number(tpname,/NOMSSG) EQ 0) AND (SIZE(tpname,/TYPE) NE 7)
IF (test[0]) THEN BEGIN
  MESSAGE,badinpt_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (TOTAL(tnames(tpname) NE '') LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,no_tpns_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF  ;;  passed tests --> at least some of the inputs are valid TPLOT handles
;;----------------------------------------------------------------------------------------
;;  Define output keywords
;;----------------------------------------------------------------------------------------
tpnms          = tnames(tpname,INDEX=tpind)
IF (tpnms[0] NE '') THEN BEGIN
  nt    = N_ELEMENTS(tpname)
  gind0 = REPLICATE(0b,nt[0])
  test  = (is_a_number(tpname,/NOMSSG) EQ 0)   ;;  TRUE --> Input is string
  IF (test[0]) THEN BEGIN
    FOR j=0L, nt[0] - 1L DO gind0 = (TOTAL(tpname[j] EQ tpnms) EQ 1)
  ENDIF ELSE BEGIN
    FOR j=0L, nt[0] - 1L DO gind0 = (TOTAL(tpname[j] EQ tpind) EQ 1)
  ENDELSE
  gind  = WHERE(gind0)
ENDIF ELSE BEGIN
  gind  = -1
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END
