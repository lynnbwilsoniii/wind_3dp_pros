;;  calc_and_save_ip_shocks_ramp_prec_amps_critMach_crib.pro

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
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'idl_save_files'+slash[0]
inst_pref      = 'mfi_'
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
;;  Define requirements/tests for all quasi-perp. shocks
;;----------------------------------------------------------------------------------------
test_0a        = (ABS(Mfast__up) GE 1e0) AND (ABS(M_VA___up) GE 1e0) AND (ABS(N2_N1__up) GE 1e0)
test_1a        = (ABS(thetbn_up) GE 45e0)
test_1b        = (ABS(thetbn_up) LT 45e0)
good_qperp     = WHERE(test_0a AND test_1a,gd_qperp)
good_qpara     = WHERE(test_0a AND test_1b,gd_qpara)
n_all_cfa      = N_ELEMENTS(Mfast__up)
;;----------------------------------------------------------------------------------------
;;  Load MFI into TPLOT, filter, and plot
;;----------------------------------------------------------------------------------------
all_ramp_stats = REPLICATE(f,gd[0],6L)
all_bavg_stats = REPLICATE(f,gd[0],6L)
all_bamp_stats = REPLICATE(f,gd[0],6L)
all_tdate      = REPLICATE('',gd[0])
.compile $HOME/Desktop/low_beta_Ma_whistlers/crib_sheets/temp_calc_ip_shocks_ramp_precursor_amps.pro
FOR jj=0L, gd[0] - 1L DO BEGIN                                        $
  struc              = temp_calc_ip_shocks_ramp_precursor_amps(jj)  & $
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

;pred_dB_Bup    = SQRT(numer/denom)
;;  Define output structure
bamp_struc     = {TDATE:all_tdate,RAMP_RAT:all_ramp_stats,BAVG_RAT:all_bavg_stats,$
                  BAMP_VAL:all_bamp_stats,PRED_DB_BUP:pred_dB_Bup}
;;  Define output file name
fpref          = sav_dir[0]+slash[0]+'Wind_'+inst_pref[0]+'_all_precursor_shocks'
fsuff          = '_Filt-Bo_Val_Norm2Bup_Norm2DB.sav'
fname_amps     = fpref[0]+fsuff[0]
;;  Create IDL save file
SAVE,bamp_struc,FILENAME=fname_amps[0]

;;----------------------------------------------------------------------------------------
;;  Calculate critical Mach numbers
;;----------------------------------------------------------------------------------------
ones           = [-1,0,1]
;;  Compile critical Mach number routines
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/genarr.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/zbrent.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/crit_mf.pro
;;  Define necessary variables
ind0           = good_qperp               ;;  All quasi-perpendicular shocks
ind1           = good_A                   ;;  All "good" shocks
ind2           = good_A[good_y_all0]      ;;  All "good" shocks with whistlers
nx             = N_ELEMENTS(ind0)
ny             = N_ELEMENTS(ind1)
nz             = N_ELEMENTS(ind2)
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

;;  Define variable values
betaup0        = beta_t_up_lmh[ind0,*]                      ;;  i.e., [A - ∂A, A, A + ∂A]
betaup1        = beta_t_up_lmh[ind1,*]
betaup2        = beta_t_up_lmh[ind2,*]
thetaBn0       = thetbn_up_lmh[ind0,*]*!DPI/18d1
thetaBn1       = thetbn_up_lmh[ind1,*]*!DPI/18d1
thetaBn2       = thetbn_up_lmh[ind2,*]*!DPI/18d1
MAup0          = M_VA___up_lmh[ind0,*]
MAup1          = M_VA___up_lmh[ind1,*]
MAup2          = M_VA___up_lmh[ind2,*]
Mfup0          = Mfast__up_lmh[ind0,*]
Mfup1          = Mfast__up_lmh[ind1,*]
Mfup2          = Mfast__up_lmh[ind2,*]
;;  Define variable uncertainties
d_betaup0      = d_beta_t_up[ind0]
d_betaup1      = d_beta_t_up[ind1]
d_betaup2      = d_beta_t_up[ind2]
d_thetaBn0     = d_thetbn_up[ind0]*!DPI/18d1
d_thetaBn1     = d_thetbn_up[ind1]*!DPI/18d1
d_thetaBn2     = d_thetbn_up[ind2]*!DPI/18d1
d_MAup0        = d_M_VA___up[ind0]
d_MAup1        = d_M_VA___up[ind1]
d_MAup2        = d_M_VA___up[ind2]
d_Mfup0        = d_Mfast__up[ind0]
d_Mfup1        = d_Mfast__up[ind1]
d_Mfup2        = d_Mfast__up[ind2]

;;  Define 1st critical Mach numbers
Mcr_EK84_0     = REPLICATE(d,nx[0],2L)          ;;  1st critical Mach number, Mcr1, and uncertainty [Edmiston&Kennel, 1984]
Mcr_EK84_1     = REPLICATE(d,ny[0],2L)          ;;  [Mcr1,d_Mcr1]
Mcr_EK84_2     = REPLICATE(d,nz[0],2L)          ;;  [Mcr1,d_Mcr1]
gg             = 5d0/3d0
FOR kk=0L, nx[0] - 1L DO BEGIN                                                       $
  xx            = REFORM( betaup0[kk,*])                                           & $
  yy            = REFORM(thetaBn0[kk,*])                                           & $
  temp_Mcr      = REPLICATE(d,3L,3L)                                               & $
  FOR ii=0L, 2L DO BEGIN                                                             $
    FOR jj=0L, 2L DO BEGIN                                                           $
      temp_Mcr[ii,jj] = crit_mf(gg[0],xx[ii],yy[jj],TYPE='1',/SILENT)              & $
    ENDFOR                                                                         & $
  ENDFOR                                                                           & $
  zz               = temp_Mcr                                                      & $
  Mcr_EK84_0[kk,*] = [MEAN(zz,/NAN),STDDEV(zz,/NAN)]

FOR kk=0L, ny[0] - 1L DO BEGIN                                                       $
  xx            = REFORM( betaup1[kk,*])                                           & $
  yy            = REFORM(thetaBn1[kk,*])                                           & $
  temp_Mcr      = REPLICATE(d,3L,3L)                                               & $
  FOR ii=0L, 2L DO BEGIN                                                             $
    FOR jj=0L, 2L DO BEGIN                                                           $
      temp_Mcr[ii,jj] = crit_mf(gg[0],xx[ii],yy[jj],TYPE='1',/SILENT)              & $
    ENDFOR                                                                         & $
  ENDFOR                                                                           & $
  zz               = temp_Mcr                                                      & $
  Mcr_EK84_1[kk,*] = [MEAN(zz,/NAN),STDDEV(zz,/NAN)]

FOR kk=0L, nz[0] - 1L DO BEGIN                                                       $
  xx            = REFORM( betaup2[kk,*])                                           & $
  yy            = REFORM(thetaBn2[kk,*])                                           & $
  temp_Mcr      = REPLICATE(d,3L,3L)                                               & $
  FOR ii=0L, 2L DO BEGIN                                                             $
    FOR jj=0L, 2L DO BEGIN                                                           $
      temp_Mcr[ii,jj] = crit_mf(gg[0],xx[ii],yy[jj],TYPE='1',/SILENT)              & $
    ENDFOR                                                                         & $
  ENDFOR                                                                           & $
  zz               = temp_Mcr                                                      & $
  Mcr_EK84_2[kk,*] = [MEAN(zz,/NAN),STDDEV(zz,/NAN)]

;;  Define 3 whistler critical Mach numbers and uncertainties
mu             = me[0]/mp[0]                 ;;  electron-to-proton mass ratio
cthbn0         = COS(thetaBn0)
cthbn1         = COS(thetaBn1)
cthbn2         = COS(thetaBn2)
fac_ww         = 1d0/(2d0*SQRT(mu[0]))
fac_gr         = SQRT(27d0/(64d0*mu[0]))
fac_nw         = 1d0/(SQRT(2d0*mu[0]))
Mcr_ww_0       = REPLICATE(d,nx[0],2L)
Mcr_ww_1       = REPLICATE(d,ny[0],2L)
Mcr_ww_2       = REPLICATE(d,nz[0],2L)
Mcr_gr_0       = REPLICATE(d,nx[0],2L)
Mcr_gr_1       = REPLICATE(d,ny[0],2L)
Mcr_gr_2       = REPLICATE(d,nz[0],2L)
Mcr_nw_0       = REPLICATE(d,nx[0],2L)
Mcr_nw_1       = REPLICATE(d,ny[0],2L)
Mcr_nw_2       = REPLICATE(d,nz[0],2L)

FOR kk=0L, nx[0] - 1L DO BEGIN                                                       $
  temp_ww        = REFORM(fac_ww[0]*ABS(cthbn0[kk,*]))                             & $
  temp_gr        = REFORM(fac_gr[0]*ABS(cthbn0[kk,*]))                             & $
  temp_nw        = REFORM(fac_nw[0]*ABS(cthbn0[kk,*]))                             & $
  Mcr_ww_0[kk,*] = [MEAN(temp_ww,/NAN),STDDEV(temp_ww,/NAN)]                       & $
  Mcr_gr_0[kk,*] = [MEAN(temp_gr,/NAN),STDDEV(temp_gr,/NAN)]                       & $
  Mcr_nw_0[kk,*] = [MEAN(temp_nw,/NAN),STDDEV(temp_nw,/NAN)]

FOR kk=0L, ny[0] - 1L DO BEGIN                                                       $
  temp_ww        = REFORM(fac_ww[0]*ABS(cthbn1[kk,*]))                             & $
  temp_gr        = REFORM(fac_gr[0]*ABS(cthbn1[kk,*]))                             & $
  temp_nw        = REFORM(fac_nw[0]*ABS(cthbn1[kk,*]))                             & $
  Mcr_ww_1[kk,*] = [MEAN(temp_ww,/NAN),STDDEV(temp_ww,/NAN)]                       & $
  Mcr_gr_1[kk,*] = [MEAN(temp_gr,/NAN),STDDEV(temp_gr,/NAN)]                       & $
  Mcr_nw_1[kk,*] = [MEAN(temp_nw,/NAN),STDDEV(temp_nw,/NAN)]

FOR kk=0L, nz[0] - 1L DO BEGIN                                                       $
  temp_ww        = REFORM(fac_ww[0]*ABS(cthbn2[kk,*]))                             & $
  temp_gr        = REFORM(fac_gr[0]*ABS(cthbn2[kk,*]))                             & $
  temp_nw        = REFORM(fac_nw[0]*ABS(cthbn2[kk,*]))                             & $
  Mcr_ww_2[kk,*] = [MEAN(temp_ww,/NAN),STDDEV(temp_ww,/NAN)]                       & $
  Mcr_gr_2[kk,*] = [MEAN(temp_gr,/NAN),STDDEV(temp_gr,/NAN)]                       & $
  Mcr_nw_2[kk,*] = [MEAN(temp_nw,/NAN),STDDEV(temp_nw,/NAN)]

;cthbn0         = COS(thetaBn0[*,1])
;cthbn1         = COS(thetaBn1[*,1])
;cthbn2         = COS(thetaBn2[*,1])
;Mcr_ww_0       = MEAN(fac_ww[0]*ABS(cthbn0),/NAN)
;Mcr_ww_1       = MEAN(fac_ww[0]*ABS(cthbn1),/NAN)
;Mcr_ww_2       = MEAN(fac_ww[0]*ABS(cthbn2),/NAN)
;Mcr_gr_0       = MEAN(fac_gr[0]*ABS(cthbn0),/NAN)
;Mcr_gr_1       = MEAN(fac_gr[0]*ABS(cthbn1),/NAN)
;Mcr_gr_2       = MEAN(fac_gr[0]*ABS(cthbn2),/NAN)
;Mcr_nw_0       = MEAN(fac_nw[0]*ABS(cthbn0),/NAN)
;Mcr_nw_1       = MEAN(fac_nw[0]*ABS(cthbn1),/NAN)
;Mcr_nw_2       = MEAN(fac_nw[0]*ABS(cthbn2),/NAN)
;d_Mcr_ww_0     = fac_ww[0]*ABS(SIN(thetaBn0[*,1])*d_thetaBn0)
;d_Mcr_ww_1     = fac_ww[0]*ABS(SIN(thetaBn1[*,1])*d_thetaBn1)
;d_Mcr_ww_2     = fac_ww[0]*ABS(SIN(thetaBn2[*,1])*d_thetaBn2)
;d_Mcr_gr_0     = fac_gr[0]*ABS(SIN(thetaBn0[*,1])*d_thetaBn0)
;d_Mcr_gr_1     = fac_gr[0]*ABS(SIN(thetaBn1[*,1])*d_thetaBn1)
;d_Mcr_gr_2     = fac_gr[0]*ABS(SIN(thetaBn2[*,1])*d_thetaBn2)
;d_Mcr_nw_0     = fac_nw[0]*ABS(SIN(thetaBn0[*,1])*d_thetaBn0)
;d_Mcr_nw_1     = fac_nw[0]*ABS(SIN(thetaBn1[*,1])*d_thetaBn1)
;d_Mcr_nw_2     = fac_nw[0]*ABS(SIN(thetaBn2[*,1])*d_thetaBn2)

;;  Define ratios between Mf and all critical Mach numbers and uncertainties
MfMcEK840      = REPLICATE(d,nx[0],2L)      ;;  Mf/Mcr1
MfMcEK841      = REPLICATE(d,ny[0],2L)      ;;  Mf/Mcr1
MfMcEK842      = REPLICATE(d,nz[0],2L)      ;;  Mf/Mcr1
MfMwwK020      = REPLICATE(d,nx[0],2L)      ;;  Mf/Mww
MfMwwK021      = REPLICATE(d,ny[0],2L)      ;;  Mf/Mww
MfMwwK022      = REPLICATE(d,nz[0],2L)      ;;  Mf/Mww
MfMgrK020      = REPLICATE(d,nx[0],2L)      ;;  Mf/Mgr
MfMgrK021      = REPLICATE(d,ny[0],2L)      ;;  Mf/Mgr
MfMgrK022      = REPLICATE(d,nz[0],2L)      ;;  Mf/Mgr
MfMnwK020      = REPLICATE(d,nx[0],2L)      ;;  Mf/Mnw
MfMnwK021      = REPLICATE(d,ny[0],2L)      ;;  Mf/Mnw
MfMnwK022      = REPLICATE(d,nz[0],2L)      ;;  Mf/Mnw
;;  Values
MfMcEK840[*,0] = Mfup0[*,1]/Mcr_EK84_0[*,0]
MfMcEK841[*,0] = Mfup1[*,1]/Mcr_EK84_1[*,0]
MfMcEK842[*,0] = Mfup2[*,1]/Mcr_EK84_2[*,0]
MfMwwK020[*,0] = Mfup0[*,1]/Mcr_ww_0[*,0]
MfMwwK021[*,0] = Mfup1[*,1]/Mcr_ww_1[*,0]
MfMwwK022[*,0] = Mfup2[*,1]/Mcr_ww_2[*,0]
MfMgrK020[*,0] = Mfup0[*,1]/Mcr_gr_0[*,0]
MfMgrK021[*,0] = Mfup1[*,1]/Mcr_gr_1[*,0]
MfMgrK022[*,0] = Mfup2[*,1]/Mcr_gr_2[*,0]
MfMnwK020[*,0] = Mfup0[*,1]/Mcr_nw_0[*,0]
MfMnwK021[*,0] = Mfup1[*,1]/Mcr_nw_1[*,0]
MfMnwK022[*,0] = Mfup2[*,1]/Mcr_nw_2[*,0]
;;  Uncertainties
MfMcEK840[*,1] = MfMcEK840[*,0]*SQRT( (Mcr_EK84_0[*,1]/Mcr_EK84_0[*,0])^2 + (d_Mfup0/Mfup0[*,1])^2 )
MfMcEK841[*,1] = MfMcEK841[*,0]*SQRT( (Mcr_EK84_1[*,1]/Mcr_EK84_1[*,0])^2 + (d_Mfup1/Mfup1[*,1])^2 )
MfMcEK842[*,1] = MfMcEK842[*,0]*SQRT( (Mcr_EK84_2[*,1]/Mcr_EK84_2[*,0])^2 + (d_Mfup2/Mfup2[*,1])^2 )
MfMwwK020[*,1] = MfMwwK020[*,0]*SQRT( (Mcr_ww_0[*,1]/Mcr_ww_0[*,0])^2 + (d_Mfup0/Mfup0[*,1])^2 )
MfMwwK021[*,1] = MfMwwK021[*,0]*SQRT( (Mcr_ww_1[*,1]/Mcr_ww_1[*,0])^2 + (d_Mfup1/Mfup1[*,1])^2 )
MfMwwK022[*,1] = MfMwwK022[*,0]*SQRT( (Mcr_ww_2[*,1]/Mcr_ww_2[*,0])^2 + (d_Mfup2/Mfup2[*,1])^2 )
MfMgrK020[*,1] = MfMgrK020[*,0]*SQRT( (Mcr_ww_0[*,1]/Mcr_ww_0[*,0])^2 + (d_Mfup0/Mfup0[*,1])^2 )
MfMgrK021[*,1] = MfMgrK021[*,0]*SQRT( (Mcr_ww_1[*,1]/Mcr_ww_1[*,0])^2 + (d_Mfup1/Mfup1[*,1])^2 )
MfMgrK022[*,1] = MfMgrK022[*,0]*SQRT( (Mcr_ww_2[*,1]/Mcr_ww_2[*,0])^2 + (d_Mfup2/Mfup2[*,1])^2 )
MfMnwK020[*,1] = MfMnwK020[*,0]*SQRT( (Mcr_ww_0[*,1]/Mcr_ww_0[*,0])^2 + (d_Mfup0/Mfup0[*,1])^2 )
MfMnwK021[*,1] = MfMnwK021[*,0]*SQRT( (Mcr_ww_1[*,1]/Mcr_ww_1[*,0])^2 + (d_Mfup1/Mfup1[*,1])^2 )
MfMnwK022[*,1] = MfMnwK022[*,0]*SQRT( (Mcr_ww_2[*,1]/Mcr_ww_2[*,0])^2 + (d_Mfup2/Mfup2[*,1])^2 )

;;  Define output structure
mach_rat_str0  = {BETAUP:[[betaup0[*,1]],[d_betaup0]],THEBN:[[thetaBn0[*,1]],[d_thetaBn0]],$
                  MAUP:[[MAup0[*,1]],[d_MAup0]],MFUP:[[Mfup0[*,1]],[d_Mfup0]],             $
                  MMCEK84:Mcr_EK84_0,MWWK02:Mcr_ww_0,MGRK02:Mcr_gr_0,MNWK02:Mcr_nw_0,      $
                  MF_MCEK84:MfMcEK840,MF_MWWK02:MfMwwK020,MF_MGRK02:MfMgrK020,             $
                  MF_MNWK02:MfMnwK020}
mach_rat_str1  = {BETAUP:[[betaup1[*,1]],[d_betaup1]],THEBN:[[thetaBn1[*,1]],[d_thetaBn1]],$
                  MAUP:[[MAup1[*,1]],[d_MAup1]],MFUP:[[Mfup1[*,1]],[d_Mfup1]],             $
                  MMCEK84:Mcr_EK84_1,MWWK02:Mcr_ww_1,MGRK02:Mcr_gr_1,MNWK02:Mcr_nw_1,      $
                  MF_MCEK84:MfMcEK841,MF_MWWK02:MfMwwK021,MF_MGRK02:MfMgrK021,             $
                  MF_MNWK02:MfMnwK021}
mach_rat_str2  = {BETAUP:[[betaup2[*,1]],[d_betaup2]],THEBN:[[thetaBn2[*,1]],[d_thetaBn2]],$
                  MAUP:[[MAup2[*,1]],[d_MAup2]],MFUP:[[Mfup2[*,1]],[d_Mfup2]],             $
                  MMCEK84:Mcr_EK84_2,MWWK02:Mcr_ww_2,MGRK02:Mcr_gr_2,MNWK02:Mcr_nw_2,      $
                  MF_MCEK84:MfMcEK842,MF_MWWK02:MfMwwK022,MF_MGRK02:MfMgrK022,             $
                  MF_MNWK02:MfMnwK022}
mach_rat_stru  = {ALL_QPERP:mach_rat_str0,GOOD_QP:mach_rat_str1,GOOD_QP_WW:mach_rat_str2}
;;  Define output file name
fpref          = sav_dir[0]+slash[0]+'Wind_'+inst_pref[0]+'_all_Qperp_shocks'
fsuff          = '_betaup_theBn_MAup_Mfup_Mcr3WMcrs_and_ratios.sav'
fname_mach     = fpref[0]+fsuff[0]
;;  Create IDL save file
SAVE,mach_rat_stru,FILENAME=fname_mach[0]


;;----------------------------------------------------------------------------------------
;;  Save to IDL save files
;;----------------------------------------------------------------------------------------


