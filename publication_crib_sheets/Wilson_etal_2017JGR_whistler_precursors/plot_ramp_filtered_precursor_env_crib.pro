;;  plot_ramp_filtered_precursor_env_crib.pro

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
inst_pref      = 'mfi_'
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'filtered_envelope_plots'+slash[0]
FILE_MKDIR,sav_dir[0]
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
all_ramp_stats = REPLICATE(f,gd[0],6L)
all_bavg_stats = REPLICATE(f,gd[0],6L)
all_bamp_stats = REPLICATE(f,gd[0],6L)
all_tdate      = REPLICATE('',gd[0])
.compile $HOME/Desktop/low_beta_Ma_whistlers/crib_sheets/temp_plot_ramp_filtered_precursor_env.pro
FOR jj=0L, gd[0] - 1L DO BEGIN                                        $
  struc = 0                                                         & $
  test  = temp_plot_ramp_filtered_precursor_env(jj)                 & $
  IF (SIZE(test,/TYPE) NE 8) THEN CONTINUE ELSE struc = test        & $
  all_ramp_stats[jj[0],*] = struc.RAMP_RAT                          & $
  all_bavg_stats[jj[0],*] = struc.BAVG_RAT                          & $
  all_bamp_stats[jj[0],*] = struc.BAMP_VAL                          & $
  all_tdate[jj[0]]        = struc.TDATE[0]

;;----------------------------------------------------------------------------------------
;;  Calculate predicted precursor amplitudes
;;
;;    Tidman & Krall [1971], page 159, Equation 9.11
;;    ∂B/<Bo>_up ~ [ ( <beta>_up Cos(theta_Bn)^2 )/( MA^2 - 1 ) ]^(1/2)
;;----------------------------------------------------------------------------------------
ind2           = good_A[good_y_all0]      ;;  All "good" shocks with whistlers
nz             = N_ELEMENTS(ind2)
ones           = [-1,0,1]
;;  Define all shock variable uncertainties
d_beta_t_up    = ABS(asy_info_str.PLASMA_BETA.DY[*,0])      ;;  Uncertainty:  Total plasma beta
d_thetbn_up    = ABS(key_info_str.THETA_BN.DY)              ;;  Uncertainty:  theta_Bn
d_M_VA___up    = ABS(ups_info_str.M_VA.DY)                  ;;  Uncertainty:  MA
d_Mfast__up    = ABS(ups_info_str.M_FAST.DY)                ;;  Uncertainty:  Mf
;;  Define perturbed variable values
beta_t_up_lmh  = REPLICATE(d,n_all_cfa[0],3L)               ;;  i.e., [A - ∂A, A, A + ∂A]
thetbn_up_lmh  = REPLICATE(d,n_all_cfa[0],3L)
M_VA___up_lmh  = REPLICATE(d,n_all_cfa[0],3L)
Mfast__up_lmh  = REPLICATE(d,n_all_cfa[0],3L)
FOR kk=0L, n_all_cfa[0] - 1L DO BEGIN                                                $
  beta_t_up_lmh[kk,*] = beta_t_up[kk] + ones*d_beta_t_up[kk]                       & $
  thetbn_up_lmh[kk,*] = thetbn_up[kk] + ones*d_thetbn_up[kk]                       & $
  M_VA___up_lmh[kk,*] = M_VA___up[kk] + ones*d_M_VA___up[kk]                       & $
  Mfast__up_lmh[kk,*] = Mfast__up[kk] + ones*d_Mfast__up[kk]
;;  Define theoretical normalized amplitudes
betaup         = beta_t_up_lmh[ind2,*]
MAup           = M_VA___up_lmh[ind2,*]
thetaBn        = thetbn_up_lmh[ind2,*]*!DPI/18d1
pred_dB_Bup    = REPLICATE(d,nz[0],2L)          ;;  [b,d_b]
FOR kk=0L, nz[0] - 1L DO BEGIN                                                       $
  xx            = REFORM( betaup[kk,*])                                            & $
  yy            = REFORM(thetaBn[kk,*])                                            & $
  zz            = REFORM(   MAup[kk,*])                                            & $
  temp_dbb       = REPLICATE(d,3L,3L,3L)                                           & $
  FOR ii=0L, 2L DO BEGIN                                                             $
    FOR jj=0L, 2L DO BEGIN                                                           $
      numer          = xx[ii]*COS(yy[jj])^2                                        & $
      denom          = zz^2 - 1d0                                                  & $
      temp_dbb[ii,jj,*] = SQRT(numer[0]/denom)                                     & $
    ENDFOR                                                                         & $
  ENDFOR                                                                           & $
  ww                = temp_dbb                                                     & $
  pred_dB_Bup[kk,*] = [MEAN(ww,/NAN),STDDEV(ww,/NAN)]

;;  Define output structure
bamp_struc     = {TDATE:all_tdate,RAMP_RAT:all_ramp_stats,BAVG_RAT:all_bavg_stats,$
                  BAMP_VAL:all_bamp_stats,PRED_DB_BUP:pred_dB_Bup}
;;  Define save directory
inst_pref      = 'mfi_'
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'idl_save_files'+slash[0]
FILE_MKDIR,sav_dir[0]
;;  Define output file name
fpref          = sav_dir[0]+slash[0]+'Wind_'+inst_pref[0]+'_all_precursor_shocks'
fsuff          = '_Det-Filt-Bo_Val_Norm2Bup_Norm2DB.sav'
fname_amps     = fpref[0]+fsuff[0]
;;  Create IDL save file
SAVE,bamp_struc,FILENAME=fname_amps[0]
