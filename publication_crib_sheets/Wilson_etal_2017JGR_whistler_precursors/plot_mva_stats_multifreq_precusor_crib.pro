;;  plot_mva_stats_multifreq_precusor_crib.pro

;;  ***  Need to start in SPEDAS mode, not UIDL64  ***
;;  Compile relevant routines
@comp_lynn_pros
thm_init

;;----------------------------------------------------------------------------------------
;;  Coordinates and vectors
;;----------------------------------------------------------------------------------------
;;  Define some coordinate strings
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_fac      = 'fac'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
vec_str        = ['x','y','z']
tensor_str     = ['x'+vec_str,'y'+vec_str[1:2],'zz']
fac_vec_str    = ['perp1','perp2','para']
fac_dir_str    = ['para','perp','anti']
vec_col        = [250,150, 50]
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}
;;  Define save/setup stuff for TPLOT
popen_str      = {PORT:1,LANDSCAPE:0,UNITS:'inches',YSIZE:11,XSIZE:8.5}
;;  Define spacecraft-specific variables
sc             = 'Wind'
scpref         = sc[0]+'_'
;;  Define save directory
slash          = get_os_slash()           ;;  '/' for Unix, '\' for Windows
mva_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'mva_sav'+slash[0]
;;  Define relevant TPLOT handles
mfi_gse_tpn    = 'Wind_B_htr_gse'
mfi_mag_tpn    = 'Wind_B_htr_mag'
mfi_filt_lp    = 'lowpass_Bo'
mfi_filt_hp    = 'highpass_Bo'
mfi_filt_dettp = 'highpass_Bo_detrended'
;;----------------------------------------------------------------------------------------
;;  Initialize and setup
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/print_ip_shocks_whistler_stats_batch.pro
;;  Convert zoom times to Unix
start_unix     = time_double(start_times)
end___unix     = time_double(end___times)
midt__unix     = (start_unix + end___unix)/2d0
;;----------------------------------------------------------------------------------------
;;  Define time ranges to load into TPLOT
;;----------------------------------------------------------------------------------------
delt           = [-1,1]*6d0*36d2        ;;  load ±6 hours about ramp
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/get_ip_shocks_whistler_ramp_times_batch.pro

all_stunix     = tura_mid + delt[0]
all_enunix     = tura_mid + delt[1]
all__trans     = [[all_stunix],[all_enunix]]
nprec          = N_ELEMENTS(tura_mid)
;;----------------------------------------------------------------------------------------
;;  Define burst and precursor intervals
;;----------------------------------------------------------------------------------------
tran_brsts     = time_string(all__trans,PREC=3)
tran__subs     = [[prec_st],[prec_en]]
;;----------------------------------------------------------------------------------------
;;  Define frequency filter range
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/load_ip_shocks_prec_freq_range_batch.pro

;;----------------------------------------------------------------------------------------
;;  Restore IDL save file containing all "best" MVA results for all burst intervals
;;----------------------------------------------------------------------------------------
fname_suff     = 'Filtered_MultiFreq_MFI_MVA_Results.sav'
fname_out      = STRUPCASE(scpref[0])+'All_*_Precursor_Ints_'+fname_suff[0]             ;;  e.g., 'WIND_All_113_Precursor_Ints_Filtered_MFI_OnlyBest_MVA_Results.sav'
fname          = FILE_SEARCH(mva_dir[0],fname_out[0])
IF (fname[0] NE '') THEN RESTORE,fname[0]

;;  Define indices relative to CfA database
good           = good_y_all0
gd             = gd_y_all[0]
ind1           = good_A
ind2           = good_A[good_y_all0]      ;;  All "good" shocks with whistlers [indices for CfA arrays]
;;  Get Precursor MVA Statistics
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/count_precusor_mva_stats_multifreq_batch.pro

good_frq       = WHERE(f_lower GT 1d-1,gd_frq)
;good_frq       = WHERE(f_upper GT 1d-1,gd_frq)

;;  Define tag prefixes
date_tpre      = 'DATE_'        ;;  Dates
iint_tpre      = 'INT_'         ;;  precursor time intervals for each date
fint_tpre      = 'FR_'          ;;  frequency range tags
;;  Define date and precursor interval tags
scpref0        = sc[0]
date_tags      = date_tpre[0]+tdate_ramps
prec_tags      = iint_tpre[0]+'000'
suffxs         = ', on '+tdate_ramps+', with '+STRUPCASE(scpref0[0])
;;  Define output to summarize stats
cnt_str        = (num2int_str(tot_cnt[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdfrq_str      = (num2int_str(gd_frq[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdmva_str      = (num2int_str(N_ELEMENTS(theta_kb),NUM_CHAR=6,/ZERO_PAD))[0]
allmva_str     = (num2int_str(all_mva_cnt[0],NUM_CHAR=8,/ZERO_PAD))[0]
suffixt        = ' Total Good MVA Intervals for '+scpref0[0]+' IP Shocks'
sout           = ';;  '+cnt_str[0]+' of '+gdmva_str[0]+suffixt[0]
sout1          = ';;  '+gdfrq_str[0]+' of which have f_low > 100 mHz'
sout2          = ';;  From a total of '+allmva_str[0]+' Total MVA Intervals Analyzed'
PRINT,''          & $
PRINT,sout[0]     & $
PRINT,sout1[0]    & $
PRINT,sout2[0]    & $
PRINT,''
;;  001996 of 002189 Total Good MVA Intervals for Wind IP Shocks
;;  001721 of which have f_low > 100 mHz
;;  From a total of 08790035 Total MVA Intervals Analyzed

;;  Define unit vectors
kvecsu         = unit_vec(kvecs)
;;  Force angles:  0 ≤ ø ≤ 90
thetakb        = theta_kb[good_frq] < (18d1 - theta_kb[good_frq])
thetakn        = theta_kn[good_frq] < (18d1 - theta_kn[good_frq])
;;  theta_kn did not work for some reason --> calculate dot product here
nvecuup        = unit_vec(nvec_up)
k_dot_n        = my_dot_prod(kvecsu,nvecuup,/NOM)
theta_kn       = ACOS(k_dot_n)*18d1/!DPI
thetakn        = theta_kn[good_frq] < (18d1 - theta_kn[good_frq])

;;----------------------------------------------------------------------------------------
;;  Print wave amplitude stats
;;----------------------------------------------------------------------------------------
;good_th        = WHERE(FINITE(theta_kb),gd_th)
good_th        = WHERE(FINITE(thetakb),gd_th)
good_wamps     = wave_amp[good_th,*]

x              = good_wamps[*,0]
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*gd_th[0])]
PRINT,';;  ∂B_min [nT]:  ',stats
;;  ∂B_min [nT]:     1.1595208e-05      0.87529571     0.012702708    0.0034569239     0.035998762   0.00086800722

x              = good_wamps[*,1]
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*gd_th[0])]
PRINT,';;  ∂B_mid [nT]:  ',stats
;;  ∂B_mid [nT]:       0.028850230       6.1968367      0.23336270      0.11709646      0.39776960    0.0095910768

x              = good_wamps[*,2]
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*gd_th[0])]
PRINT,';;  ∂B_max [nT]:  ',stats
;;  ∂B_max [nT]:       0.046526427       7.8347084      0.28984672      0.15298777      0.46933618     0.011316700

x              = good_wamps[*,3]
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*gd_th[0])]
PRINT,';;  |∂B| [nT]:  ',stats
;;  |∂B| [nT]:         0.029280894       5.0567051      0.18258250     0.098170990      0.29804988    0.0071866208


;;----------------------------------------------------------------------------------------
;;  Print wave polarization stats
;;----------------------------------------------------------------------------------------
r_handed       = righthand[good_frq]
good_rh        = WHERE(r_handed GT 0,gd_rh)
good_lh        = WHERE(r_handed EQ 0,gd_lh)
bad_pol        = WHERE(r_handed LT 0,bd_pl)
PRINT,';;  ',gd_rh[0],gd_lh[0],bd_pl[0] & $
PRINT,';;  ',1d2*[gd_rh[0],gd_lh[0],bd_pl[0]]/(1d0*gd_frq[0])
;;          1256         465           0
;;         72.980825       27.019175       0.0000000

;;----------------------------------------------------------------------------------------
;;  Print wave normal angle stats
;;----------------------------------------------------------------------------------------
;;---------------------------------------
;;  theta_kB angles
;;---------------------------------------
x              = thetakb
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*gd_frq[0])]
PRINT,';;  theta_kB [deg]:  ',stats
;;  theta_kB [deg]:         3.7013590       89.949911       54.738071       57.332241       21.435009      0.51669379

uppthsh        = 30d0
good_low       = WHERE(x LE uppthsh[0],gd_low)
PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*gd_frq[0]))
;;           269       15.630447

uppthsh        = 45d0
good_low       = WHERE(x LE uppthsh[0],gd_low)
PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*gd_frq[0]))
;;           548       31.841952

lowthsh        = 30d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*gd_frq[0]))
;;          1451       84.311447

lowthsh        = 45d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*gd_frq[0]))
;;          1172       68.099942

;;---------------------------------------
;;  theta_kn angles
;;---------------------------------------
x              = thetakn
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*gd_frq[0])]
PRINT,';;  theta_kn [deg]:  ',stats
;;  theta_kn [deg]:         2.0362670       89.986043       52.287972       51.705863       19.563147      0.47157229

uppthsh        = 30d0
good_low       = WHERE(x LE uppthsh[0],gd_low)
PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*gd_frq[0]))
;;           226       13.131900

uppthsh        = 45d0
good_low       = WHERE(x LE uppthsh[0],gd_low)
PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*gd_frq[0]))
;;           631       36.664730

lowthsh        = 30d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*gd_frq[0]))
;;          1495       86.868100

lowthsh        = 45d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*gd_frq[0]))
;;          1090       63.335270

;;----------------------------------------------------------------------------------------
;;  Plot results
;;----------------------------------------------------------------------------------------
wi,1
wi,2
popen_str      = {LANDSCAPE:1,UNITS:'inches',XSIZE:10.75,YSIZE:8.25}

;;  Define default plot stuff
tot_cnt_out    = 'Total #: '+(num2int_str(gd_frq[0],NUM_CHAR=6,/ZERO_PAD))[0]
yttl0          = 'Number of Events'
yttl1          = 'Percentage of Events'
xttl0          = 'Wave Normal Angle [deg, theta_kB]'
xttl1          = 'Wave Normal Angle [deg, theta_kn]'
xran           = [0d0,9d1]
yrabprc        = [0d0,10d0]
yranprc        = [0d0,10d0]
titleb         = 'Wave Normal Angle:  (k . <Bo>_up)'
titlen         = 'Wave Normal Angle:  (k . n_sh)'
;;  Bin results
dth_kba        = 2.5d0
hist_thkb      = HISTOGRAM(thetakb,BINSIZE=dth_kba[0],LOCATIONS=locs_b,MAX= 9d1,MIN=0d0,/NAN)
hist_thkn      = HISTOGRAM(thetakn,BINSIZE=dth_kba[0],LOCATIONS=locs_n,MAX= 9d1,MIN=0d0,/NAN)
hist_kbpc      = 1d2*hist_thkb/(1d0*gd_frq[0])
hist_knpc      = 1d2*hist_thkn/(1d0*gd_frq[0])
;;  Define plot limits structures
yranb          = [1d0,(1.05*MAX(ABS(hist_thkb),/NAN)) > 2d2]
yrann          = [1d0,(1.05*MAX(ABS(hist_thkn),/NAN)) > 2d2]
pstrn          = {XRANGE:xran,XSTYLE:1,YRANGE:yranb,YSTYLE:1,XTICKS:9,XMINOR:10,NODATA:1,$
                  PSYM:10,XTITLE:xttl0[0],YLOG:1,YMINOR:9L}
pstrp          = {XRANGE:xran,XSTYLE:1,YRANGE:yrabprc,YSTYLE:1,XTICKS:9,XMINOR:10,NODATA:1,$
                  PSYM:10,XTITLE:xttl0[0],YLOG:1,YMINOR:9L}
;;  Define plot limits structures:  theta_kB
pstrnb         = pstrn
pstrpb         = pstrp
str_element,pstrnb,'YTITLE',yttl0[0],/ADD_REPLACE
str_element,pstrpb,'YTITLE',yttl1[0],/ADD_REPLACE
str_element,pstrpb,'YMINOR',      10,/ADD_REPLACE
str_element,pstrpb,  'YLOG',       0,/ADD_REPLACE

;;  Define plot limits structures:  theta_kn
pstrnn         = pstrn
pstrpn         = pstrp
str_element,pstrnn,'XTITLE',xttl0[0],/ADD_REPLACE
str_element,pstrpn,'XTITLE',xttl1[0],/ADD_REPLACE
str_element,pstrnn,'YTITLE',yttl0[0],/ADD_REPLACE
str_element,pstrpn,'YTITLE',yttl1[0],/ADD_REPLACE
str_element,pstrpn,'YRANGE', yranprc,/ADD_REPLACE
str_element,pstrpn,'YMINOR',      10,/ADD_REPLACE
str_element,pstrpn,  'YLOG',       0,/ADD_REPLACE

;;  Plot theta_kB angles
xdata          =    locs_b
ydata0         = hist_thkb
ydata1         = hist_kbpc
pstr0          =    pstrnb
pstr1          =    pstrpb
WSET,1
WSHOW,1
!P.MULTI       = [0,1,2]
PLOT,xdata,ydata0,_EXTRA=pstr0,TITLE=titleb[0]
  OPLOT,xdata,ydata0,PSYM=10,COLOR= 50
PLOT,xdata,ydata1,_EXTRA=pstr1,TITLE=titleb[0]
  OPLOT,xdata,ydata1,PSYM=10,COLOR= 50
  XYOUTS,0.45,0.90,tot_cnt_out[0],/NORMAL,COLOR=250,CHARSIZE=1.
!P.MULTI       = 0

;;  Plot theta_kn angles
xdata          =    locs_n
ydata0         = hist_thkn
ydata1         = hist_knpc
pstr0          =    pstrnn
pstr1          =    pstrpn
WSET,2
WSHOW,2
!P.MULTI       = [0,1,2]
PLOT,xdata,ydata0,_EXTRA=pstr0,TITLE=titlen[0]
  OPLOT,xdata,ydata0,PSYM=10,COLOR= 50
PLOT,xdata,ydata1,_EXTRA=pstr1,TITLE=titlen[0]
  OPLOT,xdata,ydata1,PSYM=10,COLOR= 50
  XYOUTS,0.45,0.90,tot_cnt_out[0],/NORMAL,COLOR=250,CHARSIZE=1.
!P.MULTI       = 0


;;  Plot theta_kB angles
LOADCT,39
data           = thetakb
nbins          = 10L
xttl           = xttl0[0]
ttle           = titleb[0]
xran           = [0d0,9d1]
WSET,1
WSHOW,1
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

;;  Plot theta_kn angles
data           = thetakN
nbins          = 10L
xttl           = xttl1[0]
ttle           = titlen[0]
xran           = [0d0,9d1]
WSET,2
WSHOW,2
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1


;;----------------------------------------------------------------------------------------
;;  Save results
;;----------------------------------------------------------------------------------------
fnameb         = STRUPCASE(scpref[0])+'All_Precursor_Ints_Wave_Normal_Angles_Bup_MultiFreqFilt'
fnamen         = STRUPCASE(scpref[0])+'All_Precursor_Ints_Wave_Normal_Angles_nsh_MultiFreqFilt'

;;  Plot theta_kB angles
thck           = 2e0
xdata          =    locs_b
ydata0         = hist_thkb
ydata1         = hist_kbpc
pstr0          =    pstrnb
pstr1          =    pstrpb
popen,fnameb[0]+'_histogram',_EXTRA=popen_str
  !P.MULTI       = [0,1,2]
  PLOT,xdata,ydata0,_EXTRA=pstr0,TITLE=titleb[0]
    OPLOT,xdata,ydata0,PSYM=10,COLOR= 50,THICK=thck[0]
  PLOT,xdata,ydata1,_EXTRA=pstr1,TITLE=titleb[0]
    OPLOT,xdata,ydata1,PSYM=10,COLOR= 50,THICK=thck[0]
    XYOUTS,0.45,0.90,tot_cnt_out[0],/NORMAL,COLOR=250,CHARSIZE=1.
  !P.MULTI       = 0
pclose


data           = thetakb
nbins          = 10L
xttl           = xttl0[0]
ttle           = titleb[0]
xran           = [0d0,9d1]
ymax_cnt       = 30d1
ymax_prc       = 20d0
popen,fnameb[0]+'_clean_histogram',_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose

data           = thetakb
nbins          = 19L
xttl           = xttl0[0]
ttle           = titleb[0]
xran           = [0d0,9d1]
ymax_cnt       = 18d1
ymax_prc       = 10d0
popen,fnameb[0]+'_clean_2_histogram',_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose

;;  Plot theta_kn angles
thck           = 2e0
xdata          =    locs_n
ydata0         = hist_thkn
ydata1         = hist_knpc
pstr0          =    pstrnn
pstr1          =    pstrpn
popen,fnamen[0]+'_histogram',_EXTRA=popen_str
  !P.MULTI       = [0,1,2]
  PLOT,xdata,ydata0,_EXTRA=pstr0,TITLE=titlen[0]
    OPLOT,xdata,ydata0,PSYM=10,COLOR= 50,THICK=thck[0]
  PLOT,xdata,ydata1,_EXTRA=pstr1,TITLE=titlen[0]
    OPLOT,xdata,ydata1,PSYM=10,COLOR= 50,THICK=thck[0]
    XYOUTS,0.45,0.90,tot_cnt_out[0],/NORMAL,COLOR=250,CHARSIZE=1.
  !P.MULTI       = 0
pclose

data           = thetakN
nbins          = 10L
xttl           = xttl1[0]
ttle           = titlen[0]
xran           = [0d0,9d1]
ymax_cnt       = 40d1
ymax_prc       = 25d0
popen,fnamen[0]+'_clean_histogram',_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose

data           = thetakN
nbins          = 19L
xttl           = xttl1[0]
ttle           = titlen[0]
xran           = [0d0,9d1]
ymax_cnt       = 20d1
ymax_prc       = 15d0
popen,fnamen[0]+'_clean_2_histogram',_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose






