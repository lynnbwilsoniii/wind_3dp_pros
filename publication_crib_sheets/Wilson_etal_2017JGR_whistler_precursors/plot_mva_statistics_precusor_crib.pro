;;  plot_mva_statistics_precusor_crib.pro

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
;;  Define spacecraft-specific variables
sc             = 'Wind'
scpref         = sc[0]+'_'
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
fran_mods      = REPLICATE(0d0,nprec[0],2L)
fran_mods[*,0] = 1d-1         ;;  Put lower bound at 100 mHz
fran_mods[*,1] = 30d0         ;;  Put upper bound well above Nyquist frequency
special_dates  = ['1998-02-18','1999-08-23','1999-11-05','2000-02-05','2001-03-03','2006-08-19','2008-06-24','2011-02-04','2012-01-21','2013-07-12','2013-10-26','2014-04-19','2014-05-07','2014-05-29']
special_flow   = [2e-1,1e-1,1e-1,4e-1,2e-1,1e-1,2e-1,2e-1,5e-1,3e-1,3e-1,2e-1,2e-1,2e-1]
sind           = array_where(tdate_ramps,special_dates,/N_UNIQ)
sind_f         = REFORM(sind[*,0])
fran_mods[sind_f] = special_flow
;;----------------------------------------------------------------------------------------
;;  Define file name and plot stuff
;;----------------------------------------------------------------------------------------
date_in_pre0   = 'EventDate_'+tdate_ramps
date_in_pre    = 'EventDate_'+tdate_ramps+'_'
date_mid_0     = 'Event Date: '+tdate_ramps
date_mid_1     = 'Date: '+tdate_ramps
scpref0        = sc[0]
num_ip_str     = num2int_str(nprec[0],NUM_CHAR=3,/ZERO_PAD)

;;  Define tag prefixes
date_tpre      = 'DATE_'        ;;  Dates
iint_tpre      = 'INT_'         ;;  precursor time intervals for each date
fint_tpre      = 'FR_'          ;;  frequency range tags
;;  Define date and precursor interval tags
date_tags      = date_tpre[0]+tdate_ramps
prec_tags      = iint_tpre[0]+'000'
suffxs         = ', on '+tdate_ramps+', with '+STRUPCASE(scpref0[0])
;;----------------------------------------------------------------------------------------
;;  Restore IDL save file containing all "best" MVA results for all burst intervals
;;----------------------------------------------------------------------------------------
mva_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'mva_sav'+slash[0]
fname_suff     = 'Filtered_MFI_OnlyBest_MVA_Results.sav'
fname_out      = STRUPCASE(scpref[0])+'All_'+num_ip_str[0]+'_Precursor_Ints_'+fname_suff[0]             ;;  e.g., 'WIND_All_113_Precursor_Ints_Filtered_MFI_OnlyBest_MVA_Results.sav'
gfile          = FILE_SEARCH(mva_dir[0],fname_out[0])
test           = (gfile[0] NE '')
IF (test[0]) THEN RESTORE,gfile[0]
;all___mva__res
;best_subin_res
;best__mva__res
;all_polwav_res

;;  Define indices relative to CfA database
good           = good_y_all0
gd             = gd_y_all[0]
ind1           = good_A
ind2           = good_A[good_y_all0]      ;;  All "good" shocks with whistlers [indices for CfA arrays]
;;  Get Precursor MVA Statistics
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/count_precusor_mva_statistics_batch.pro


cnt_str        = (num2int_str(tot_cnt[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdmva_str      = (num2int_str(N_ELEMENTS(theta_kb),NUM_CHAR=6,/ZERO_PAD))[0]
allmva_str     = (num2int_str(all_mva_cnt[0],NUM_CHAR=8,/ZERO_PAD))[0]
suffixt        = ' Total Good MVA Intervals for '+scpref0[0]+' IP Shocks'
sout           = ';;  '+cnt_str[0]+' of '+gdmva_str[0]+suffixt[0]
sout2          = ';;  From a total of '+allmva_str[0]+' Total MVA Intervals Analyzed'
PRINT,''          & $
PRINT,sout[0]     & $
PRINT,sout2[0]    & $
PRINT,''
;;  000673 of 000711 Total Good MVA Intervals for Wind IP Shocks
;;  From a total of 02692488 Total MVA Intervals Analyzed

;;  Define unit vectors
kvecsu         = unit_vec(kvecs)
;;  Force angles:  0 ≤ ø ≤ 90
thetakb        = theta_kb < (18d1 - theta_kb)
thetakn        = theta_kn < (18d1 - theta_kn)
;;----------------------------------------------------------------------------------------
;;  Print wave amplitude stats
;;----------------------------------------------------------------------------------------
good_th        = WHERE(FINITE(theta_kb),gd_th)
good_wamps     = wave_amp[good_th,*]

x              = good_wamps[*,0]
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*tot_cnt[0])]
PRINT,';;  Min(∂B) [nT]:  ',stats
;;  Min(∂B) [nT]:      0.0045757259       1.2571814     0.062138658     0.044786832     0.075601142    0.0029142099

x              = good_wamps[*,1]
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*tot_cnt[0])]
PRINT,';;  Max(∂B) [nT]:  ',stats
;;  Max(∂B) [nT]:       0.049237137       11.299499      0.48963661      0.30202447      0.71832734     0.027689484

x              = good_wamps[*,2]
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*tot_cnt[0])]
PRINT,';;  Mean(∂B) [nT]:  ',stats
;;  Mean(∂B) [nT]:       0.068005164       11.600286      0.57176060      0.36152850      0.80098672     0.030875769

x              = good_wamps[*,3]
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*tot_cnt[0])]
PRINT,';;  Median(∂B) [nT]:  ',stats
;;  Median(∂B) [nT]:       0.040981570       7.5788682      0.35395238      0.21477591      0.51100037     0.019697617


;;----------------------------------------------------------------------------------------
;;  Print wave polarization stats
;;----------------------------------------------------------------------------------------
good_rh        = WHERE(righthand GT 0,gd_rh)
good_lh        = WHERE(righthand EQ 0,gd_lh)
bad_pol        = WHERE(righthand LT 0,bd_pl)
PRINT,';;  ',gd_rh[0],gd_lh[0],bd_pl[0] & $
PRINT,';;  ',1d2*[gd_rh[0],gd_lh[0],bd_pl[0]]/(1d0*tot_cnt[0])
;;           594          79          38
;;         88.261516       11.738484       5.6463596

;;----------------------------------------------------------------------------------------
;;  Print wave normal angle stats
;;----------------------------------------------------------------------------------------
;;---------------------------------------
;;  theta_kB angles
;;---------------------------------------
x              = thetakb
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*tot_cnt[0])]
PRINT,';;  theta_kB [deg]:  ',stats
;;  theta_kB [deg]:         1.8082329       89.491837       28.839094       24.139017       19.362232      0.74635919

uppthsh        = 30d0
good_low       = WHERE(x LE uppthsh[0],gd_low)
PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*tot_cnt[0]))
;;           406       60.326895

uppthsh        = 45d0
good_low       = WHERE(x LE uppthsh[0],gd_low)
PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*tot_cnt[0]))
;;           552       82.020802

lowthsh        = 30d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*tot_cnt[0]))
;;           267       39.673105

lowthsh        = 45d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*tot_cnt[0]))
;;           121       17.979198

;;---------------------------------------
;;  theta_kn angles
;;---------------------------------------
x              = thetakn
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*tot_cnt[0])]
PRINT,';;  theta_kn [deg]:  ',stats
;;  theta_kn [deg]:         12.118562       89.432608       53.535931       51.908206       16.703554      0.64387469

uppthsh        = 30d0
good_low       = WHERE(x LE uppthsh[0],gd_low)
PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*tot_cnt[0]))
;;            47       6.9836553

uppthsh        = 45d0
good_low       = WHERE(x LE uppthsh[0],gd_low)
PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*tot_cnt[0]))
;;           217       32.243685

lowthsh        = 30d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*tot_cnt[0]))
;;           626       93.016345

lowthsh        = 45d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*tot_cnt[0]))
;;           456       67.756315

;;----------------------------------------------------------------------------------------
;;  Plot results
;;----------------------------------------------------------------------------------------
wi,1
wi,2
popen_str      = {LANDSCAPE:1,UNITS:'inches',XSIZE:10.75,YSIZE:8.25}

;;  Define default plot stuff
tot_cnt_out    = 'Total #: '+(num2int_str(tot_cnt[0],NUM_CHAR=6,/ZERO_PAD))[0]
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
hist_kbpc      = 1d2*hist_thkb/(1d0*tot_cnt[0])
hist_knpc      = 1d2*hist_thkn/(1d0*tot_cnt[0])
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
fnameb         = STRUPCASE(scpref[0])+'All_Precursor_Ints_Wave_Normal_Angles_Bup'
fnamen         = STRUPCASE(scpref[0])+'All_Precursor_Ints_Wave_Normal_Angles_nsh'

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
ymax_cnt       = 18d1
ymax_prc       = 30d0
popen,fnameb[0]+'_clean_histogram',_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose

data           = thetakb
nbins          = 19L
xttl           = xttl0[0]
ttle           = titleb[0]
xran           = [0d0,9d1]
ymax_cnt       = 9d1
ymax_prc       = 15d0
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
ymax_cnt       = 18d1
ymax_prc       = 30d0
popen,fnamen[0]+'_clean_histogram',_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose

data           = thetakN
nbins          = 19L
xttl           = xttl1[0]
ttle           = titlen[0]
xran           = [0d0,9d1]
ymax_cnt       = 9d1
ymax_prc       = 15d0
popen,fnamen[0]+'_clean_2_histogram',_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose











;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
x              = 1d0*cnt_by_date
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nprec[0])]
PRINT,';;  Good MVA Int. Stats:  ',stats
;;  Good MVA Int. Stats:         0.0000000       65.000000       5.9557522       4.0000000       8.2725767      0.77821855

good_x         = WHERE(cnt_by_date GT 0,gd_x)
y              = x[good_x]
stats          = [MIN(y,/NAN),MAX(y,/NAN),MEAN(y,/NAN),MEDIAN(y),STDDEV(y,/NAN),STDDEV(y,/NAN)/SQRT(1d0*gd_x[0])]
PRINT,';;  Good MVA Int. Stats (Finite Only):  ',stats
;;  Good MVA Int. Stats (Finite Only):         1.0000000       65.000000       6.2314815       4.0000000       8.3605733      0.80449654

;;  Stats
x              = cnt_by_date

uppthsh        = 0d0
good_low       = WHERE(x LE uppthsh[0],gd_low)
PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*nprec[0]))
;;             5       4.4247788

uppthsh        = 10d0
good_low       = WHERE(x LE uppthsh[0] AND x GT 0,gd_low)
PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*nprec[0]))
;;            92       81.415929

uppthsh        = 5d0
good_low       = WHERE(x LE uppthsh[0] AND x GT 0,gd_low)
PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*nprec[0]))
;;            75       66.371681

uppthsh        = 2d0
good_low       = WHERE(x LE uppthsh[0] AND x GT 0,gd_low)
PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*nprec[0]))
;;            33       29.203540

lowthsh        = 2d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*nprec[0]))
;;            91       80.530973

lowthsh        = 3d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*nprec[0]))
;;            75       66.371681

lowthsh        = 4d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*nprec[0]))
;;            63       55.752212

lowthsh        = 11d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*nprec[0]))
;;            16       14.159292

lowthsh        = 15d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*nprec[0]))
;;             9       7.9646018

lowthsh        = 20d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*nprec[0]))
;;             4       3.5398230

lowthsh        = 30d0
good_upp       = WHERE(x GE lowthsh[0],gd_upp)
PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*nprec[0]))
;;             3       2.6548673


;;  Plot histogram
hist_y         = HISTOGRAM(y,BINSIZE=1,LOCATIONS=locs_y,MAX= 7d1,MIN=0d0,/NAN)
PLOT,locs_y,hist_y,PSYM=10,/YSTYLE,/XSTYLE,YRANGE=[0,20]


mform          = '(";;  ",a10,"  ",I3.3,"  Good MVA Intervals")'
FOR kk=0L, nprec[0] - 1L DO BEGIN                                                        $
  PRINT,tdate_ramps[kk],cnt_by_date[kk],FORMAT=mform[0]
;;  1995-04-17  002  Good MVA Intervals
;;  1995-07-22  005  Good MVA Intervals
;;  1995-08-22  004  Good MVA Intervals
;;  1995-08-24  004  Good MVA Intervals
;;  1995-10-22  001  Good MVA Intervals
;;  1995-12-24  001  Good MVA Intervals
;;  1996-02-06  001  Good MVA Intervals
;;  1996-04-03  005  Good MVA Intervals
;;  1996-04-08  002  Good MVA Intervals
;;  1997-03-15  005  Good MVA Intervals
;;  1997-04-10  006  Good MVA Intervals
;;  1997-10-24  018  Good MVA Intervals
;;  1997-11-01  004  Good MVA Intervals
;;  1997-12-10  003  Good MVA Intervals
;;  1997-12-30  003  Good MVA Intervals
;;  1998-01-06  010  Good MVA Intervals
;;  1998-02-18  008  Good MVA Intervals
;;  1998-05-29  000  Good MVA Intervals
;;  1998-08-06  013  Good MVA Intervals
;;  1998-08-19  001  Good MVA Intervals
;;  1998-11-08  003  Good MVA Intervals
;;  1998-12-28  002  Good MVA Intervals
;;  1999-01-13  001  Good MVA Intervals
;;  1999-02-17  005  Good MVA Intervals
;;  1999-04-16  005  Good MVA Intervals
;;  1999-06-26  001  Good MVA Intervals
;;  1999-08-04  004  Good MVA Intervals
;;  1999-08-23  015  Good MVA Intervals
;;  1999-09-22  000  Good MVA Intervals
;;  1999-10-21  004  Good MVA Intervals
;;  1999-11-05  009  Good MVA Intervals
;;  1999-11-13  009  Good MVA Intervals
;;  2000-02-05  007  Good MVA Intervals
;;  2000-02-14  003  Good MVA Intervals
;;  2000-06-23  004  Good MVA Intervals
;;  2000-07-13  002  Good MVA Intervals
;;  2000-07-26  003  Good MVA Intervals
;;  2000-07-28  005  Good MVA Intervals
;;  2000-08-10  003  Good MVA Intervals
;;  2000-08-11  001  Good MVA Intervals
;;  2000-10-28  002  Good MVA Intervals
;;  2000-10-31  015  Good MVA Intervals
;;  2000-11-06  004  Good MVA Intervals
;;  2000-11-26  001  Good MVA Intervals
;;  2000-11-28  012  Good MVA Intervals
;;  2001-01-17  001  Good MVA Intervals
;;  2001-03-03  002  Good MVA Intervals
;;  2001-03-22  003  Good MVA Intervals
;;  2001-03-27  004  Good MVA Intervals
;;  2001-04-21  001  Good MVA Intervals
;;  2001-05-06  005  Good MVA Intervals
;;  2001-05-12  004  Good MVA Intervals
;;  2001-09-13  005  Good MVA Intervals
;;  2001-10-28  003  Good MVA Intervals
;;  2001-11-30  003  Good MVA Intervals
;;  2001-12-21  005  Good MVA Intervals
;;  2001-12-30  002  Good MVA Intervals
;;  2002-01-17  001  Good MVA Intervals
;;  2002-01-31  004  Good MVA Intervals
;;  2002-03-23  008  Good MVA Intervals
;;  2002-03-29  000  Good MVA Intervals
;;  2002-05-21  005  Good MVA Intervals
;;  2002-06-29  002  Good MVA Intervals
;;  2002-08-01  004  Good MVA Intervals
;;  2002-09-30  006  Good MVA Intervals
;;  2002-11-09  001  Good MVA Intervals
;;  2003-05-29  002  Good MVA Intervals
;;  2003-06-18  006  Good MVA Intervals
;;  2004-04-12  007  Good MVA Intervals
;;  2005-05-06  013  Good MVA Intervals
;;  2005-05-07  001  Good MVA Intervals
;;  2005-06-16  011  Good MVA Intervals
;;  2005-07-10  006  Good MVA Intervals
;;  2005-08-24  004  Good MVA Intervals
;;  2005-09-02  004  Good MVA Intervals
;;  2006-08-19  024  Good MVA Intervals
;;  2007-08-22  016  Good MVA Intervals
;;  2007-12-17  000  Good MVA Intervals
;;  2008-05-28  019  Good MVA Intervals
;;  2008-06-24  042  Good MVA Intervals
;;  2009-02-03  001  Good MVA Intervals
;;  2009-06-24  001  Good MVA Intervals
;;  2009-06-27  009  Good MVA Intervals
;;  2009-10-21  005  Good MVA Intervals
;;  2010-04-11  005  Good MVA Intervals
;;  2011-02-04  002  Good MVA Intervals
;;  2011-07-11  007  Good MVA Intervals
;;  2011-09-16  011  Good MVA Intervals
;;  2011-09-25  031  Good MVA Intervals
;;  2012-01-21  008  Good MVA Intervals
;;  2012-01-30  000  Good MVA Intervals
;;  2012-06-16  003  Good MVA Intervals
;;  2012-10-08  003  Good MVA Intervals
;;  2012-11-12  002  Good MVA Intervals
;;  2012-11-26  002  Good MVA Intervals
;;  2013-02-13  005  Good MVA Intervals
;;  2013-04-30  002  Good MVA Intervals
;;  2013-06-10  004  Good MVA Intervals
;;  2013-07-12  002  Good MVA Intervals
;;  2013-09-02  006  Good MVA Intervals
;;  2013-10-26  065  Good MVA Intervals
;;  2014-02-13  013  Good MVA Intervals
;;  2014-02-15  006  Good MVA Intervals
;;  2014-02-19  003  Good MVA Intervals
;;  2014-04-19  004  Good MVA Intervals
;;  2014-05-07  011  Good MVA Intervals
;;  2014-05-29  007  Good MVA Intervals
;;  2014-07-14  001  Good MVA Intervals
;;  2015-05-06  002  Good MVA Intervals
;;  2015-06-24  005  Good MVA Intervals
;;  2015-08-15  002  Good MVA Intervals
;;  2016-03-11  004  Good MVA Intervals
;;  2016-03-14  001  Good MVA Intervals


all_cnt_date   = cnt_by_date
good_cntdate   = cnt_by_date
cc             = 0L
FOR kk=0L, nprec[0] - 1L DO BEGIN                                                        $
  low  = cc[0]                                                                         & $
  upp  = (cc[0] + all_cnt_date[kk] - 1L) > low[0]                                      & $
  gind = LINDGEN(upp[0] - low[0] + 1L) + low[0]                                        & $
  good = WHERE(FINITE(theta_kb[gind]),gd)                                              & $
  good_cntdate[kk] = gd[0]                                                             & $
  cc  += (all_cnt_date[kk] > 1L)

























;;  Perturb <Bo>_up and nsh
ones           = [-1,0,1]
buvc_up_lmh    = REPLICATE(d,tot_cnt[0],3L,3L)
nshu_up_lmh    = REPLICATE(d,tot_cnt[0],3L,3L)
FOR kk=0L, tot_cnt[0] - 1L DO BEGIN                                                               $
  FOR jj=0L, 2L DO BEGIN                                                                          $
    tempb                = unit_vec(REFORM(bvec_up[kk,*] + ones[jj]*dbvecup[kk,*]))             & $
    tempn                = unit_vec(REFORM(nvec_up[kk,*] + ones[jj]*dnvecup[kk,*]))             & $
    buvc_up_lmh[kk,*,jj] = tempb                                                                & $
    nshu_up_lmh[kk,*,jj] = tempn

;;  Define dot-products
k_dot_n_l      = my_dot_prod(kvecsu,nshu_up_lmh[*,*,0],/NOM)
k_dot_n_m      = my_dot_prod(kvecsu,nshu_up_lmh[*,*,1],/NOM)
k_dot_n_h      = my_dot_prod(kvecsu,nshu_up_lmh[*,*,2],/NOM)
k_dot_b_l      = my_dot_prod(kvecsu,buvc_up_lmh[*,*,0],/NOM)
k_dot_b_m      = my_dot_prod(kvecsu,buvc_up_lmh[*,*,1],/NOM)
k_dot_b_h      = my_dot_prod(kvecsu,buvc_up_lmh[*,*,2],/NOM)

;;  Define wave normal angles [deg]
theta_kn_l_0   = ACOS(k_dot_n_l)*18d1/!DPI
theta_kn_m_0   = ACOS(k_dot_n_m)*18d1/!DPI
theta_kn_h_0   = ACOS(k_dot_n_h)*18d1/!DPI
theta_kb_l_0   = ACOS(k_dot_b_l)*18d1/!DPI
theta_kb_m_0   = ACOS(k_dot_b_m)*18d1/!DPI
theta_kb_h_0   = ACOS(k_dot_b_h)*18d1/!DPI
theta_kn_l     = theta_kn_l_0 < (18d1 - theta_kn_l_0)
theta_kn_m     = theta_kn_m_0 < (18d1 - theta_kn_m_0)
theta_kn_h     = theta_kn_h_0 < (18d1 - theta_kn_h_0)
theta_kb_l     = theta_kb_l_0 < (18d1 - theta_kb_l_0)
theta_kb_m     = theta_kb_m_0 < (18d1 - theta_kb_m_0)
theta_kb_h     = theta_kb_h_0 < (18d1 - theta_kb_h_0)
;;  Define average wave normal angles [deg]
theta_kn       = (theta_kn_l + theta_kn_m + theta_kn_h)/3d0
theta_kb       = (theta_kb_l + theta_kb_m + theta_kb_h)/3d0


cnt_str        = (num2int_str(tot_cnt[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdmva_str      = (num2int_str(TOTAL(FINITE(theta_kb)),NUM_CHAR=6,/ZERO_PAD))[0]
suffixt        = ' Total Good MVA Intervals for '+scpref0[0]+' IP Shocks'
sout           = ';;  '+cnt_str[0]+' of '+gdmva_str[0]+suffixt[0]
PRINT,''          & $
PRINT,sout[0]     & $
PRINT,''
;;  000673 of 000711 Total Good MVA Intervals for Wind IP Shocks

