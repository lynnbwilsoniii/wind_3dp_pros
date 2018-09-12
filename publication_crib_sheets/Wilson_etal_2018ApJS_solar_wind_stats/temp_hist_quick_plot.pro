;;  .compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro

PRO temp_hist_quick_plot,xdata,XTITLE=xtitle,YTITLE=ytitle,XRANGE=xrange,YRANGE=yrange, $
                               TITLE=title,DELTAX=deltax,FILE_NAME=file_name,           $
                               WIND_N=wind_n

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy tick mark arrays
exp_val        = LINDGEN(501) - 250L                  ;;  Array of exponent values
exp_str        = STRTRIM(STRING(exp_val,FORMAT='(I)'),2L)
log10_tickn    = '10!U'+exp_str+'!N'                  ;;  Powers of 10 tick names
log10_tickv    = 1d1^DOUBLE(exp_val[*])               ;;  " " values
;;  Define some plot defaults
thck           = 2e0
psym           = 10                                   ;;  Histogram symbol
colr           = [50L,200L,250L]                           ;;  Use blue, orange, or red for color table 39
def_yttl       = 'Number of Events'
def_ttle       = 'Histogram of Events'
def_yran       = [1d0,1d2]
def_delx       = 1d0
xposi          = 0.25
yposi          = 0.90
dypos          = 0.03
def_pstr       = {XSTYLE:1,YSTYLE:1,XTICKS:9,XMINOR:9L,NODATA:1,PSYM:10,YLOG:1,$
                  YMINOR:9L,YTITLE:def_yttl[0],XLOG:1,CHARSIZE:2}
postruc        = {LANDSCAPE:0,PORT:1,UNITS:'inches',XSIZE:8.,YSIZE:8.,ASPECT:1.}
;;  Dummy tick mark arrays
exp_val        = LINDGEN(501) - 250L                  ;;  Array of exponent values
exp_str        = STRTRIM(STRING(exp_val,FORMAT='(I)'),2L)
log10_tickn    = '10!U'+exp_str+'!N'                  ;;  Powers of 10 tick names
log10_tickv    = 1d1^DOUBLE(exp_val[*])               ;;  " " values
;;  Dummy error messages
noinpt_msg     = 'No input supplied...'
nofint_msg     = 'Not enough finite data...'
badinp_msg     = 'XDATA and YDATA must both be [N]-element [numeric] arrays...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (is_a_number(xdata,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  No input
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Define data
px             = REFORM(xdata)
;;  Define default [X,Y]-Range
test_x         = FINITE(px)
good_xra       = WHERE(test_x,gdx)
IF (gdx[0] LT 10) THEN BEGIN
  ;;  Bad input
  MESSAGE,nofint_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
mnmx_x         = [MIN(px[good_xra],/NAN),MAX(px[good_xra],/NAN)]
IF (mnmx_x[1] LT mnmx_x[0]) THEN mnmx_x = REVERSE(mnmx_x)
def_xran       = mnmx_x
gd__x          = N_ELEMENTS(px)       ;;  Total # of points supplied
gd_fx          = gdx[0]               ;;  Total # of finite/valid points supplied
tot_cnt_out    = 'Total #    [ALL]: '+(num2int_str(gd__x[0],NUM_CHAR=10,/ZERO_PAD))[0]
tot_fnt_out    = 'Total # [FINITE]: '+(num2int_str(gd_fx[0],NUM_CHAR=10,/ZERO_PAD))[0]
;;  Define 1 variable stats mean and median
avg_med_std    = [MEAN(px,/NAN),MEDIAN(px),STDDEV(px,/NAN)]
stats_str      = format_number_2_string(avg_med_std,NV=24,ND=2,NEXP=0)
avg_str_out    = 'Mean     :  '+stats_str[0]
med_str_out    = 'Median   :  '+stats_str[1]
std_str_out    = 'Std. Dev.:  '+stats_str[2]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check WINDN
test           = test_window_number(wind_n,DAT_OUT=windn)
IF (test[0] EQ 0) THEN windn = 1L
;;  Check [X,Y]TITLE
test           = (SIZE(xtitle,/TYPE) NE 7) OR (N_ELEMENTS(xtitle) LT 1)
IF (test[0]) THEN xttl = 'XTITLE' ELSE xttl = xtitle[0]
test           = (SIZE(ytitle,/TYPE) NE 7) OR (N_ELEMENTS(ytitle) LT 1)
IF (test[0]) THEN yttl = def_yttl[0] ELSE yttl = ytitle[0]
;;  Check TITLE
test           = (SIZE(title,/TYPE) NE 7) OR (N_ELEMENTS(title) LT 1)
IF (test[0]) THEN ttle = def_ttle[0] ELSE ttle = title[0]
;;  Check FILE_NAME
test           = (SIZE(file_name,/TYPE) NE 7) OR (N_ELEMENTS(file_name) LT 1)
IF (test[0]) THEN save_on = 0b ELSE save_on = 1b
IF (save_on[0]) THEN fname = file_name[0]
;;  Check [X,Y]RANGE
;test           = (is_a_number(xrange,/NOMSSG) EQ 0) OR (N_ELEMENTS(xrange) LT 2)
test           = is_a_number(xrange,/NOMSSG) AND (N_ELEMENTS(xrange) EQ 2)
IF (test[0]) THEN test = test_plot_axis_range(xrange,/NOMSSG)
IF (test[0]) THEN xran = xrange ELSE xran = def_xran
;test           = (is_a_number(yrange,/NOMSSG) EQ 0) OR (N_ELEMENTS(yrange) LT 2)
test           = is_a_number(yrange,/NOMSSG) AND (N_ELEMENTS(yrange) EQ 2)
IF (test[0]) THEN test = test_plot_axis_range(yrange,/NOMSSG)
IF (test[0]) THEN yran_on = 1b ELSE yran_on = 0b
;;  Check DELTAX
test           = (is_a_number(xrange,/NOMSSG) EQ 0)
IF (test[0]) THEN delx = def_delx[0] ELSE delx = ABS(deltax[0])
;;----------------------------------------------------------------------------------------
;;  Open window
;;----------------------------------------------------------------------------------------
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*7d-1
win_str        = {RETAIN:2,XSIZE:wsz[1],YSIZE:wsz[1],XPOS:10,YPOS:10}
lbw_window,WIND_N=windn[0],_EXTRA=win_str
;;----------------------------------------------------------------------------------------
;;  Calculate histogram
;;----------------------------------------------------------------------------------------
;;  Use base-10 log
l10px          = ALOG10(px)
l10dx          = ALOG10(delx[0])
l10xr          = ALOG10(xran)
l10_hist       = HISTOGRAM(l10px,BINSIZE=l10dx[0],LOCATIONS=l10locs,MAX=l10xr[1],MIN=l10xr[0],/NAN)
yran0          = [1d0,(3.00*MAX(ABS(l10_hist),/NAN))]
IF (~yran_on[0]) THEN yran = yran0 ELSE yran = yrange
;;  Determine XY-tick marks
good_tx        = WHERE(log10_tickv GE xran[0] AND log10_tickv LE xran[1],gdtx)
good_ty        = WHERE(log10_tickv GE yran[0] AND log10_tickv LE yran[1],gdty)
IF (gdtx[0] GT 0) THEN xtick_str = {XTICKNAME:log10_tickn[good_tx],XTICKV:log10_tickv[good_tx],XTICKS:(gdtx[0] - 1L)}
IF (gdty[0] GT 0) THEN ytick_str = {YTICKNAME:log10_tickn[good_ty],YTICKV:log10_tickv[good_ty],YTICKS:(gdty[0] - 1L)}
;;  Update plot limits structure
new_pstr       = {XRANGE:xran,YRANGE:yran,XTITLE:xttl[0],YTITLE:yttl[0],TITLE:ttle[0]}
extract_tags,new_pstr,def_pstr
IF (SIZE(xtick_str,/TYPE) EQ 8) THEN extract_tags,new_pstr,xtick_str
IF (SIZE(ytick_str,/TYPE) EQ 8) THEN extract_tags,new_pstr,ytick_str
;;  Define plot values
hvals          = l10_hist
hlocs          = 1d1^(l10locs)
;;  Plot
!P.MULTI       = 0
WSET,windn[0]
WSHOW,windn[0]
PLOT,hlocs,hvals,_EXTRA=new_pstr
  OPLOT,hlocs,hvals,PSYM=psym[0],COLOR=colr[0],THICK=thck[0]
  ;;  Overplot Mean and Median vertical lines
  OPLOT,[avg_med_std[0],avg_med_std[0]],yran,COLOR=colr[1],THICK=thck[0]
  OPLOT,[avg_med_std[1],avg_med_std[1]],yran,COLOR=colr[2],THICK=thck[0]
  ;;  Output Values
  XYOUTS,xposi[0],yposi[0],tot_cnt_out[0],/NORMAL,COLOR=colr[2],CHARSIZE=1.
  yposi -= dypos[0]
  XYOUTS,xposi[0],yposi[0],tot_fnt_out[0],/NORMAL,COLOR=colr[2],CHARSIZE=1.
  yposi -= dypos[0]
  XYOUTS,xposi[0],yposi[0],avg_str_out[0],/NORMAL,COLOR=colr[1],CHARSIZE=1.
  yposi -= dypos[0]
  XYOUTS,xposi[0],yposi[0],med_str_out[0],/NORMAL,COLOR=colr[2],CHARSIZE=1.
  yposi -= dypos[0]
  XYOUTS,xposi[0],yposi[0],std_str_out[0],/NORMAL,COLOR=colr[0],CHARSIZE=1.
;;----------------------------------------------------------------------------------------
;;  Save color-coded plot (if desired)
;;----------------------------------------------------------------------------------------
IF (save_on[0]) THEN BEGIN
  !P.MULTI       = 0
  str_element,new_pstr,'CHARSIZE',1.25,/ADD_REPLACE
  popen,fname[0],_EXTRA=postruc
    PLOT,hlocs,hvals,_EXTRA=new_pstr
      OPLOT,hlocs,hvals,PSYM=psym[0],COLOR=colr[0],THICK=thck[0]
      ;;  Overplot Mean and Median vertical lines
      OPLOT,[avg_med_std[0],avg_med_std[0]],yran,COLOR=colr[1],THICK=thck[0]
      OPLOT,[avg_med_std[1],avg_med_std[1]],yran,COLOR=colr[2],THICK=thck[0]
      ;;  Output Values
      XYOUTS,xposi[0],yposi[0],tot_cnt_out[0],/NORMAL,COLOR=colr[2],CHARSIZE=1.
      yposi -= dypos[0]
      XYOUTS,xposi[0],yposi[0],tot_fnt_out[0],/NORMAL,COLOR=colr[2],CHARSIZE=1.
      yposi -= dypos[0]
      XYOUTS,xposi[0],yposi[0],avg_str_out[0],/NORMAL,COLOR=colr[1],CHARSIZE=1.
      yposi -= dypos[0]
      XYOUTS,xposi[0],yposi[0],med_str_out[0],/NORMAL,COLOR=colr[2],CHARSIZE=1.
      yposi -= dypos[0]
      XYOUTS,xposi[0],yposi[0],std_str_out[0],/NORMAL,COLOR=colr[0],CHARSIZE=1.
  pclose
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END







