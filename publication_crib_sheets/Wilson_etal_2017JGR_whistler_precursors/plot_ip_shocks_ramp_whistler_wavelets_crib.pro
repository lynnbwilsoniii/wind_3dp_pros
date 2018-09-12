;;  plot_ip_shocks_ramp_whistler_wavelets_crib.pro

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
vec_str        = ['x','y','z']
vec_col        = [250,150,50]
;;  Define save/setup stuff for TPLOT
popen_str      = {PORT:1,LANDSCAPE:0,UNITS:'inches',YSIZE:11,XSIZE:8.5}
;;  Define save directory
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'wavelet_plots'+slash[0]
inst_pref      = 'mfi_'
FILE_MKDIR,sav_dir[0]
fpref          = sav_dir[0]+slash[0]+'Wind_'+inst_pref[0]+'_'
fsuff          = '_Bmag_Bgse_wavelets'
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
delt           = [-1,1]*1d0*36d2        ;;  load ±1 hour about ramp
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/get_ip_shocks_whistler_ramp_times_batch.pro

all_stunix     = tura_mid + delt[0]
all_enunix     = tura_mid + delt[1]
all__trans     = [[all_stunix],[all_enunix]]
;;  Look at only events with definite whistlers
good           = good_y_all0
gd             = gd_y_all[0]
;;----------------------------------------------------------------------------------------
;;  Load MFI into TPLOT, filter, and plot
;;----------------------------------------------------------------------------------------
j              = 13L
jj             = gind_wav[j[0]]
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/load_ip_shocks_mfi_wavelets_batch.pro


tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-6,2]*1d1
IF (tdate[0] EQ '1998-02-18') THEN tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-6,2]*1d1
IF (tdate[0] EQ '1999-08-23') THEN tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-2,1]*1d1
IF (tdate[0] EQ '1999-11-05') THEN tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-2,2]*1d1
IF (tdate[0] EQ '2000-02-05') THEN tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-2,2]*1d1
IF (tdate[0] EQ '2001-03-03') THEN tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-2,2]*1d1
IF (tdate[0] EQ '2006-08-19') THEN tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-2,2]*1d1
IF (tdate[0] EQ '2008-06-24') THEN tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-6,2]*1d1
IF (tdate[0] EQ '2011-02-04') THEN tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-2,2]*1d1         ;;  nice example illustrating dispersive properties (i.e., frequencies increase away from shock ramp)
IF (tdate[0] EQ '2012-01-21') THEN tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-2,2]*1d1
IF (tdate[0] EQ '2013-07-12') THEN tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-2,2]*1d1
IF (tdate[0] EQ '2013-10-26') THEN tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-2,2]*1d1
IF (tdate[0] EQ '2014-04-19') THEN tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-2,2]*1d1
IF (tdate[0] EQ '2014-05-07') THEN tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-2,2]*1d1
IF (tdate[0] EQ '2014-05-29') THEN tra_plot       = [whis_st[ii[0]],tura_en[ii[0]]] + [-2,2]*1d1         ;;  nice nonlinear example

;;  Plot results
tra_prec       = [whis_st[ii[0]],whis_en[ii[0]]]
tplot,[mfi_mag_tpn[0],mfi_gse_tpn[0],tpn_wav[3],tpn_wav[0:2]],TRANGE=tra_plot
time_bar,tra_prec,COLOR=250
time_bar,tura_mid[ii[0]],COLOR=150
;;----------------------------------------------------------------------------------------
;;  Define save/setup stuff for TPLOT
;;----------------------------------------------------------------------------------------
fnm            = file_name_times(tra_plot,PREC=3)
ftime          = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)
fname          = fpref[0]+ftime[0]+fsuff[0]
;;----------------------------------------------------------------------------------------
;;  Save wavelets
;;----------------------------------------------------------------------------------------
  tplot,[mfi_mag_tpn[0],mfi_gse_tpn[0],tpn_wav[3],tpn_wav[0:2]],TRANGE=tra_plot
  time_bar,tra_prec,COLOR=250
  time_bar,tura_mid[ii[0]],COLOR=150
popen,fname[0],_EXTRA=popen_str
  tplot,[mfi_mag_tpn[0],mfi_gse_tpn[0],tpn_wav[3],tpn_wav[0:2]],TRANGE=tra_plot
  time_bar,tra_prec,COLOR=250
  time_bar,tura_mid[ii[0]],COLOR=150
pclose


;;  Create 2nd plot for long-duration precursor events
IF (tdate[0] EQ '2008-06-24') THEN tra_plot       = tura_mid[ii[0]] + [-6,2]*1d1
IF (tdate[0] EQ '2012-01-21') THEN tra_plot       = tura_mid[ii[0]] + [-2.5,2]*1d1
IF (tdate[0] EQ '2013-10-26') THEN tra_plot       = tura_mid[ii[0]] + [-8,2]*1d1                         ;;  nice example illustrating dispersive properties (i.e., frequencies increase away from shock ramp)
IF (tdate[0] EQ '2014-04-19') THEN tra_plot       = tura_mid[ii[0]] + [-3.5,2]*1d1

fnm            = file_name_times(tra_plot,PREC=3)
ftime          = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)
fname          = fpref[0]+ftime[0]+fsuff[0]
  tplot,[mfi_mag_tpn[0],mfi_gse_tpn[0],tpn_wav[3],tpn_wav[0:2]],TRANGE=tra_plot
  time_bar,tra_prec,COLOR=250
  time_bar,tura_mid[ii[0]],COLOR=150
popen,fname[0],_EXTRA=popen_str
  tplot,[mfi_mag_tpn[0],mfi_gse_tpn[0],tpn_wav[3],tpn_wav[0:2]],TRANGE=tra_plot
  time_bar,tra_prec,COLOR=250
  time_bar,tura_mid[ii[0]],COLOR=150
pclose















;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Might need to update whistler precursor times
DELVAR,data_out
t_get_values_from_plot,(tnames())[0],NDATA=2,DATA_OUT=data_out
PRINT,';;  Precursor Times:  ',time_string(t_get_struc_unix(data_out),PREC=3)



good           = gind_wav
gd             = N_ELEMENTS(good)
FOR j=0L, gd[0] - 1L DO PRINT,';;  ',j[0],good[j[0]],'     ',tdate_ramps[good[j[0]]]
;;             0          16     1998-02-18
;;             1          27     1999-08-23
;;             2          30     1999-11-05
;;             3          32     2000-02-05
;;             4          46     2001-03-03
;;             5          75     2006-08-19
;;             6          79     2008-06-24
;;             7          85     2011-02-04
;;             8          89     2012-01-21
;;             9          98     2013-07-12
;;            10         100     2013-10-26
;;            11         104     2014-04-19
;;            12         105     2014-05-07
;;            13         106     2014-05-29
