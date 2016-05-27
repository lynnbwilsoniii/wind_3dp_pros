;+
;*****************************************************************************************
;
;  PROCEDURE:   t_print_current_trange.pro
;  PURPOSE  :   This is a simple procedure that prints the current time range being
;                 shown in TPLOT, where the routine automatically determines the
;                 precision.
;
;  CALLED BY:   
;               t_tr_nplfz.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               tnames.pro
;               t_get_current_trange.pro
;               set_tplot_times.pro
;               time_string.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               t_print_current_trange
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/14/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/14/2015   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO t_print_current_trange

;;  Let IDL know that the following are functions
FORWARD_FUNCTION tnames, t_get_current_trange, time_string
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
neg_prec       = [2,3,4,5,6]
pos_prec       = [1,0]
;;  Dummy error messages
no_tplot       = 'You must first load some data into TPLOT!'
no_plot        = 'You must first plot something in TPLOT!'
no_tr_set      = 'You must first define the time ranges in tplot_com.pro'
;;----------------------------------------------------------------------------------------
;;  Check to see if TPLOT has started
;;----------------------------------------------------------------------------------------
test           = (TOTAL(tnames() NE '') LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,no_tplot[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
cur_tr         = t_get_current_trange()
test           = (TOTAL(FINITE(cur_tr)) LT 2) OR (N_ELEMENTS(cur_tr) LT 2)
IF (test[0]) THEN BEGIN
  ;;  Try setting the times manually
  set_tplot_times
  cur_tr         = t_get_current_trange()
  test           = (TOTAL(FINITE(cur_tr)) LT 2) OR (N_ELEMENTS(cur_tr) LT 2)
  IF (test[0]) THEN BEGIN
    MESSAGE,'0:  '+no_tr_set[0],/INFORMATIONAL,/CONTINUE
    RETURN
  ENDIF
ENDIF
test           = (MAX(cur_tr,/NAN) EQ MIN(cur_tr,/NAN))
IF (test[0]) THEN BEGIN
  MESSAGE,'1:  '+no_tr_set[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Determine the precision to use
;;----------------------------------------------------------------------------------------
;;  Define current time duration
cur_dur        = ABS(MAX(cur_tr,/NAN) - MIN(cur_tr,/NAN))
;;  Define the order of magnitude of current duration
oom_cd         = ALOG10(cur_dur)
oom_cd_r       = ROUND(oom_cd[0])
test_pos_neg   = (oom_cd[0] GE 0)
IF (test_pos_neg[0]) THEN BEGIN
  ;;  current time duration ≥ 1.0 seconds
  CASE 1 OF
    (oom_cd_r[0] LT 3) : prec = 1     ;;  current time duration < 1000 seconds
    (oom_cd_r[0] GE 3) : prec = 0     ;;  current time duration ≥ 1000 seconds
  ENDCASE
ENDIF ELSE BEGIN
  ;;  current time duration < 1.0 seconds
  oom_cd_abs = CEIL(ABS(oom_cd[0]))
  prec       = (oom_cd_abs[0] + 1L) < 6
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Print the time range
;;----------------------------------------------------------------------------------------
tr_str         = time_string(cur_tr,PREC=prec[0])
PRINT,';;  Current TPLOT TRANGE:  '+tr_str[0]+'  -  '+tr_str[1]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
