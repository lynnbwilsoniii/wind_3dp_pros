;;  plot_nonprecusor_ramps_crib.pro

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
vec_str        = ['x','y','z']
vec_col        = [250,150,50]
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}
;;  Define save/setup stuff for TPLOT
popen_str      = {PORT:1,LANDSCAPE:0,UNITS:'inches',YSIZE:11,XSIZE:8.5}
;;  Define save directory
slash          = get_os_slash()           ;;  '/' for Unix, '\' for Windows
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'zoom_plots'+slash[0]
inst_pref      = 'mfi_'
;;  Define relevant TPLOT handles
mfi_mag_tpn    = 'Wind_B_htr_mag'
mfi_gse_tpn    = 'Wind_B_htr_gse'
;;----------------------------------------------------------------------------------------
;;  Initialize and setup
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/print_ip_shocks_whistler_stats_batch.pro
;;  Convert zoom times to Unix
start_unix     = time_double(start_times)
end___unix     = time_double(end___times)
midt__unix     = (start_unix + end___unix)/2d0
delt           = [-1,1]*1d0*36d2        ;;  load ±1 hour about ramp
all_stunix     = midt__unix + delt[0]
all_enunix     = midt__unix + delt[1]
tran__unix     = [[all_stunix],[all_enunix]]
;;  Define a zoom-out range
n_gdA          = N_ELEMENTS(midt__unix)
delt           = [0d0,5d-1,1d0,2d0,5d0,1d1,2d1]
nzoom          = N_ELEMENTS(delt)
zoom_st        = REPLICATE(d,n_gdA[0],nzoom[0])
zoom_en        = REPLICATE(d,n_gdA[0],nzoom[0])
FOR k=0L, nzoom[0] - 1L DO BEGIN                                                 $
  zoom_st[*,k] = start_unix - delt[k]                                          & $
  zoom_en[*,k] = end___unix + delt[k]
;;----------------------------------------------------------------------------------------
;;  Define time ranges to load into TPLOT
;;----------------------------------------------------------------------------------------
delt           = [-1,1]*1d0*36d2        ;;  load ±1 hour about ramp
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/get_ip_shocks_whistler_ramp_times_batch.pro

all_stunix     = tura_mid + delt[0]
all_enunix     = tura_mid + delt[1]
all__trans     = [[all_stunix],[all_enunix]]

;;  Define dates for NN, NU, and MU
tdate_nn       = '1996-06-18'                      ;;  Plot [zoom 0]
tdate_nu       = '2007-07-20'                      ;;  Plot [zoom 4]
tdate_mu       = '1995-03-04'                      ;;  Plot [zoom 1]

good_nn        = WHERE(STRMID(start_times,0L,10L) EQ tdate_nn[0],gd_nn)
good_nu        = WHERE(STRMID(start_times,0L,10L) EQ tdate_nu[0],gd_nu)
good_mu        = WHERE(STRMID(start_times,0L,10L) EQ tdate_mu[0],gd_mu)
PRINT,';;  ',gd_nn[0],gd_nu[0],gd_mu[0]
;;             1           1           1

tdate_aa       = [tdate_nn[0],tdate_nu[0],tdate_mu[0]]
good_aa        = REFORM([good_nn[0],good_nu[0],good_mu[0]])
gd_aa          = N_ELEMENTS(good_aa)
zind           = [0L,4L,1L]

gind           = good_A[good_aa]
;;  Define relevant uncertainties
d_beta_t_up    = ABS(asy_info_str.PLASMA_BETA.DY[*,0])      ;;  Uncertainty:  Total plasma beta
d_thetbn_up    = ABS(key_info_str.THETA_BN.DY)              ;;  Uncertainty:  theta_Bn
d_M_VA___up    = ABS(ups_info_str.M_VA.DY)                  ;;  Uncertainty:  MA
d_Mfast__up    = ABS(ups_info_str.M_FAST.DY)                ;;  Uncertainty:  Mf
;;  Print shock params with uncertainties
mform          = '(";;  ",a10,f9.2,"±",f6.2,f9.2,"±",f6.2,f9.2,"±",f6.2,f9.2,"±",f6.2)'
FOR k=0L, gd_aa[0] - 1L DO BEGIN                                                                $
  j              = gind[k[0]]                                                                 & $
  nums           = [thetbn_up[j],Mfast__up[j],M_VA___up[j],beta_t_up[j]]                      & $
  d_nums         = [d_thetbn_up[j],d_Mfast__up[j],d_M_VA___up[j],d_beta_t_up[j]]              & $
  output         = [nums[0],d_nums[0],nums[1],d_nums[1],nums[2],d_nums[2],nums[3],d_nums[3]]  & $
  PRINT,tdate_aa[k],output,FORMAT=mform[0]
;;-------------------------------------------------------------------------------------------
;;     Date          Theta             M_f             M_A           beta_up
;;===========================================================================================
;;  1996-06-18    49.90±  3.00     1.42±  0.10     1.66±  0.11     0.32±  0.32
;;  2007-07-20    66.30±  1.90     1.41±  0.03     1.99±  0.05     0.64±  0.66
;;  1995-03-04    86.10±  4.80     1.96±  0.09     2.60±  0.17     0.47±  0.47
;;-------------------------------------------------------------------------------------------



;;  Define file names
zsuff          = 'zoom_'+num2int_str(LINDGEN(nzoom[0]))
fpref          = sav_dir[0]+'Wind_'+inst_pref[0]
fsuff          = '_Bmag_Bvec-GSE'
ftimes         = STRARR(n_gdA[0],nzoom[0])    ;; e.g., '2000-06-08_0705x58.886-0706x01.992'
FOR k=0L, nzoom[0] - 1L DO BEGIN                                                      $
  fnm_st         = file_name_times(zoom_st[*,k],PREC=3)                             & $
  fnm_en         = file_name_times(zoom_en[*,k],PREC=3)                             & $
  ftimes[*,k]    = fnm_st.F_TIME+'-'+STRMID(fnm_en.F_TIME,11L)    ;; e.g., '2000-06-08_0705x58.886-0706x01.992'

;;----------------------------------------------------------------------------------------
;;  Plot and save
;;----------------------------------------------------------------------------------------
;;  Compile relevant routine
.compile $HOME/Desktop/low_beta_Ma_whistlers/crib_sheets/load_ip_shocks_mfi_split_magvec.pro
;;  Define dummy variables
tshft_on       = 0b
unix           = 0d0
FOR k=0L, gd_aa[0] - 1L DO BEGIN                                                          $
  j              = good_aa[k[0]]                                                        & $
  dumb           = TEMPORARY(tshft_on)                                                  & $
  dumb           = TEMPORARY(unix)                                                      & $
  tran           = REFORM(tran__unix[j[0],*])                                           & $  ;;  loading time range
  nna            = tnames()                                                             & $
  IF (nna[0] NE '') THEN store_data,DELETE=nna                                          & $
  load_ip_shocks_mfi_split_magvec,TRANGE=tran,PRECISION=3                               & $
  nna            = tnames([mfi_mag_tpn[0],mfi_gse_tpn[0]])                              & $
  IF (nna[0] EQ '') THEN CONTINUE                                                       & $
  get_data,nna[0],DATA=temp,DLIM=dlim,LIM=lim                                           & $
  IF (SIZE(temp,/TYPE) NE 8) THEN CONTINUE                                              & $
  unix           = t_get_struc_unix(temp,TSHFT_ON=tshft_on)                             & $
  srate          = sample_rate(unix,/AVERAGE)                                           & $
  gapthsh        = 2d0/srate[0]                                                         & $
  t_insert_nan_at_interval_se,nna,GAP_THRESH=gapthsh[0]                                 & $
  z_i            = zind[k]                                                              & $  ;;  zoom index
  f_times        = ftimes[j[0],z_i[0]]                                                  & $
  f_names        = fpref[0]+f_times[0]+fsuff[0]+'_'+zsuff[z_i[0]]                       & $
  tzoom          = [zoom_st[j[0],z_i[0]],zoom_en[j[0],z_i[0]]]                          & $
    tplot,nna,TRANGE=tzoom                                                              & $
  popen,f_names[0],_EXTRA=popen_str                                                     & $
    tplot,nna,TRANGE=tzoom                                                              & $
  pclose







