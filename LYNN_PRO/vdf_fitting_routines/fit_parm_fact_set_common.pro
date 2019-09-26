;+
;*****************************************************************************************
;
;  PROCEDURE:   fit_parm_fact_set_common.pro
;  PURPOSE  :   This routine sets/defines the common block variables specific to the
;                 calling fit routine.  Thus, the user should NOT call this routine
;                 but rather let the fit routines call it.
;
;  CALLED BY:   
;               
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               model_mm_fit_com.pro
;               model_kk_fit_com.pro
;               model_ss_fit_com.pro
;               model_as_fit_com.pro
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               fit_parm_fact_set_common [,/SET_??] [,STATUS=status] [,INITYES=inityes]
;
;  KEYWORDS:    
;               SET_??   :  [6]-Element [numeric] array of fit value factors specific
;                             to the fit routine associated with ??, where ?? can be:
;                               MM  :  bi-Maxwellian model
;                                        [model_mm_fit.pro]
;                               KK  :  bi-kappa model
;                                        [model_kk_fit.pro]
;                               SS  :  bi-self similar model (symmetric)
;                                        [model_ss_fit.pro]
;                               AS  :  bi-self similar model (asymmetric)
;                                        [model_as_fit.pro]
;               STATUS   :  Set to a named variable to return the (boolean) status of
;                             the retrieval
;                               TRUE   :  Successful completion
;                               FALSE  :  Failure
;               INITYES  :  Set to a named variable to return the (boolean) initialization
;                             status of the common block variables
;                               TRUE   :  Already initialized and set
;                               FALSE  :  Not yet initialized
;
;   CHANGED:  1)  Fixed an error handling bug
;                                                                   [09/17/2019   v1.0.1]
;
;   NOTES:      
;               1)  User should not call this routine
;               2)  To avoid issues with physical boundaries, leave exponent factor at
;                     unity
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/16/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/17/2019   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO fit_parm_fact_set_common,SET_MM=set_mm,SET_KK=set_kk,SET_SS=set_ss,SET_AS=set_as,$
                                  STATUS=status,INITYES=inityes

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
dumb           = REPLICATE(1d0,6L)
status         = 0b
inityes        = 0b
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check SET_??
checks         = [N_ELEMENTS(set_mm),N_ELEMENTS(set_kk),N_ELEMENTS(set_ss),N_ELEMENTS(set_as)] EQ 6
good_ch        = WHERE(checks,gd_ch)
IF (gd_ch[0] EQ 0) THEN RETURN              ;;  Exit without setting anything
CASE good_ch[0] OF
  0L    :  BEGIN
    ;;  bi-Maxwellian model
    @model_mm_fit_com.pro
    status         = is_a_number(set_mm,/NOMSSG)
    IF (status[0]) THEN BEGIN
      p_mm_fac       = DOUBLE(set_mm)
      inityes        = 1b
    ENDIF ELSE BEGIN
      p_mm_fac       = dumb
    ENDELSE
    init_ymm       = inityes[0]
  END
  1L    :  BEGIN
    ;;  bi-kappa model
    @model_kk_fit_com.pro
    status         = is_a_number(set_kk,/NOMSSG)
    IF (status[0]) THEN BEGIN
      p_kk_fac       = DOUBLE(set_kk)
      inityes        = 1b
    ENDIF ELSE BEGIN
      p_kk_fac       = dumb
    ENDELSE
    init_ykk       = inityes[0]
  END
  2L    :  BEGIN
    ;;  symmetric bi-self similar model
    @model_ss_fit_com.pro
    status         = is_a_number(set_ss,/NOMSSG)
    IF (status[0]) THEN BEGIN
      p_ss_fac       = DOUBLE(set_ss)
      inityes        = 1b
    ENDIF ELSE BEGIN
      p_ss_fac       = dumb
    ENDELSE
    init_yss       = inityes[0]
  END
  3L    :  BEGIN
    ;;  asymmetric bi-self similar model
    @model_as_fit_com.pro
    status         = is_a_number(set_as,/NOMSSG)
    IF (status[0]) THEN BEGIN
      p_as_fac       = DOUBLE(set_as)
      inityes        = 1b
    ENDIF ELSE BEGIN
      p_as_fac       = dumb
    ENDELSE
    init_yas       = inityes[0]
  END
  ELSE  :  BEGIN
    ;;  Default to symmetric bi-self similar model
    @model_ss_fit_com.pro
    status         = is_a_number(set_ss,/NOMSSG)
    IF (status[0]) THEN BEGIN
      p_ss_fac       = DOUBLE(set_ss)
      inityes        = 1b
    ENDIF ELSE BEGIN
      p_ss_fac       = dumb
    ENDELSE
    init_yss       = inityes[0]
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END







