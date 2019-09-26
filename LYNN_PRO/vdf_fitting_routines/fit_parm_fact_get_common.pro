;+
;*****************************************************************************************
;
;  FUNCTION :   fit_parm_fact_get_common.pro
;  PURPOSE  :   This routine retrieves the common block variables specific to the
;                 calling fit routine.  Thus, the user should NOT call this routine
;                 but rather let the fit routines call it.
;
;  CALLED BY:   
;               model_mm_fit.pro
;               model_kk_fit.pro
;               model_ss_fit.pro
;               model_as_fit.pro
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
;               factors = fit_parm_fact_get_common([,/GET_??] [,STATUS=status] [,INITYES=inityes])
;
;  KEYWORDS:    
;               GET_??   :  If set, routine will get the common block variables specific
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
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
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
;    LAST MODIFIED:  09/16/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION fit_parm_fact_get_common,GET_MM=get_mm,GET_KK=get_kk,GET_SS=get_ss,GET_AS=get_as,$
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
;;  Check GET_??
checks         = [KEYWORD_SET(get_mm),KEYWORD_SET(get_kk),KEYWORD_SET(get_ss),KEYWORD_SET(get_as)]
good_ch        = WHERE(checks,gd_ch)
CASE good_ch[0] OF
  0L    :  BEGIN
    ;;  bi-Maxwellian model
    @model_mm_fit_com.pro
    status         = is_a_number(p_mm_fac,/NOMSSG) AND (N_ELEMENTS(p_mm_fac) EQ 6)
    IF (status[0]) THEN factors = p_mm_fac ELSE factors = dumb
    inityes        = KEYWORD_SET(init_ymm)
  END
  1L    :  BEGIN
    ;;  bi-kappa model
    @model_kk_fit_com.pro
    status         = is_a_number(p_kk_fac,/NOMSSG) AND (N_ELEMENTS(p_kk_fac) EQ 6)
    IF (status[0]) THEN factors = p_kk_fac ELSE factors = dumb
    inityes        = KEYWORD_SET(init_ykk)
  END
  2L    :  BEGIN
    ;;  symmetric bi-self similar model
    @model_ss_fit_com.pro
    status         = is_a_number(p_ss_fac,/NOMSSG) AND (N_ELEMENTS(p_ss_fac) EQ 6)
    IF (status[0]) THEN factors = p_ss_fac ELSE factors = dumb
    inityes        = KEYWORD_SET(init_yss)
  END
  3L    :  BEGIN
    ;;  asymmetric bi-self similar model
    @model_as_fit_com.pro
    status         = is_a_number(p_as_fac,/NOMSSG) AND (N_ELEMENTS(p_as_fac) EQ 6)
    IF (status[0]) THEN factors = p_as_fac ELSE factors = dumb
    inityes        = KEYWORD_SET(init_yas)
  END
  ELSE  :  BEGIN
    ;;  Default to symmetric bi-self similar model
    @model_ss_fit_com.pro
    status         = is_a_number(p_ss_fac,/NOMSSG) AND (N_ELEMENTS(p_ss_fac) EQ 6)
    IF (status[0]) THEN factors = p_ss_fac ELSE factors = dumb
    inityes        = KEYWORD_SET(init_yss)
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,factors
END

