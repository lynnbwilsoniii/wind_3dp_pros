;+
;*****************************************************************************************
;
;  PROCEDURE:   t_set_trange.pro
;  PURPOSE  :   This routine uses currently stored TPLOT handles to define the time
;                 range as a wrapper to timespan.pro.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               tplot_com.pro
;
;  CALLS:
;               time_double.pro
;               tnames.pro
;               get_data.pro
;               t_get_struc_unix.pro
;               test_plot_axis_range.pro
;               str_element.pro
;               test_tdate_format.pro
;               time_string.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               t_set_trange
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See also:  set_tplot_times.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/14/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/14/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO t_set_trange

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define approximate current Unix-equivalent time (leap seconds not handled but this should not matter)
cur_unix       = time_double(SYSTIME(1))
;;  Define some error messages
no_tplot       = 'You must first load some data into TPLOT!'
no_plot        = 'You must first plot something in TPLOT!'
no_tran        = 'Not able to find any defined time ranges...'
;;----------------------------------------------------------------------------------------
;;  Make sure TPLOT variables exist
;;----------------------------------------------------------------------------------------
tpn_all        = tnames()
IF (tpn_all[0] EQ '') THEN BEGIN
  MESSAGE,no_tplot[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get TPLOT data and define full time ranges
;;----------------------------------------------------------------------------------------
ntpn           = N_ELEMENTS(tpn_all)
FOR j=0L, ntpn[0] - 1L DO BEGIN
  ;;  Reset variables
  temp           = 0
  unix           = 0
  tra            = 0
  ;;  Get TPLOT data
  get_data,tpn_all[j],DATA=temp
  ;;  Define values
  unix           = t_get_struc_unix(temp,TSHFT_ON=tshft_on)
  IF (SIZE(unix,/TYPE) NE 5) THEN CONTINUE
  IF (tshft_on[0]) THEN BEGIN
    tshift         = temp[0].TSHIFT[0]
    IF (tshift[0] EQ 0 AND temp[0].X[0] GT 1d3) THEN BEGIN
      ;;  TSHIFT is set but at zero --> probably not useful to have in the structure
      tra            = [MIN(temp[0].X,/NAN),MAX(temp[0].X,/NAN)]
    ENDIF ELSE BEGIN
      tra            = [tshift[0],MAX(temp[0].X,/NAN)]
    ENDELSE
  ENDIF ELSE BEGIN
    ;;  TSHIFT is not set
    tra            = [MIN(temp[0].X,/NAN),MAX(temp[0].X,/NAN)]
  ENDELSE
  ;;  Sort just in case
  sp             = SORT(tra)
  tra            = tra[sp]
  IF (j[0] EQ 0) THEN BEGIN
    ;;  Initialize
    tra_new = tra
  ENDIF ELSE BEGIN
    ;;  Expand if necessary
    tra_new[0] = (tra[0] < tra_new[0]) > 0d0
    tra_new[1] = (tra[1] > tra_new[1]) < cur_unix[0]
  ENDELSE
ENDFOR
;;  Clean up
dumb           = TEMPORARY(temp)
dumb           = TEMPORARY(unix)
dumb           = TEMPORARY(tra)
;;  Sort just in case
sp             = SORT(tra_new)
tra_new        = tra_new[sp]
;;  Check results
test           = test_plot_axis_range(tra_new,/NOMSSG)
IF (~test[0]) THEN BEGIN
  MESSAGE,no_tran[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Load common block
;;----------------------------------------------------------------------------------------
@tplot_com.pro
;;  Determine current settings
str_element,tplot_vars,'OPTIONS.REFDATE'     ,refdate
str_element,tplot_vars,'OPTIONS.TRANGE'      ,trange_set
str_element,tplot_vars,'OPTIONS.TRANGE_CUR'  ,trange_cur
str_element,tplot_vars,'OPTIONS.TRANGE_FULL' ,trange_ful
str_element,tplot_vars,'SETTINGS.TRANGE_OLD' ,trange_old
;;  Check if old settings need to be defined
test_rdate     = test_tdate_format(refdate,/NOMSSG)
test_trset     = test_plot_axis_range(trange_set,/NOMSSG)
test_trcur     = test_plot_axis_range(trange_cur,/NOMSSG)
test_trful     = test_plot_axis_range(trange_ful,/NOMSSG)
test_trold     = test_plot_axis_range(trange_old,/NOMSSG)
;;  Set TRANGE_FULL value
str_element,tplot_vars,'OPTIONS.TRANGE_FULL' ,tra_new,/ADD_REPLACE
IF (~test_rdate[0]) THEN BEGIN
  ;;  Set REFDATE
  str            = time_string(tra_new[0],PREC=0)
  refdate        = STRMID(str[0],0L,STRPOS(str[0],'/'))
  str_element,tplot_vars,'OPTIONS.REFDATE'     ,refdate,/ADD_REPLACE
ENDIF
IF (~test_trset[0]) THEN BEGIN
  IF (test_trcur[0]) THEN tra_set = trange_cur ELSE tra_set = tra_new
  str_element,tplot_vars,'OPTIONS.TRANGE'      ,tra_set,/ADD_REPLACE
ENDIF
IF (~test_trcur[0]) THEN BEGIN
  IF (test_trset[0]) THEN tra_cur = trange_set ELSE tra_cur = tra_new
  str_element,tplot_vars,'OPTIONS.TRANGE_CUR'  ,tra_cur,/ADD_REPLACE
ENDIF
IF (~test_trold[0]) THEN BEGIN
  IF (test_trset[0]) THEN tra_old = trange_set ELSE $
    IF (test_trcur[0]) THEN tra_old = trange_cur ELSE tra_old = tra_new
  str_element,tplot_vars,'SETTINGS.TRANGE_OLD' ,tra_old,/ADD_REPLACE
ENDIF
;;  Inform user of new time range setting
PRINT,'-->  Time range set from ',time_string(tra_new[0],PREC=3),' to ',time_string(tra_new[1],PREC=3)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END


