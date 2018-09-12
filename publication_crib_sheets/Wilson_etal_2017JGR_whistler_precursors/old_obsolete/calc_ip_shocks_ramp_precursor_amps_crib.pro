;;  calc_ip_shocks_ramp_precursor_amps_crib.pro

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
                 'low_beta_Ma_whistlers'+slash[0]+'zoom_plots'+slash[0]
inst_pref      = 'mfi_'
FILE_MKDIR,sav_dir[0]
fpref          = sav_dir[0]+slash[0]+'Wind_'+inst_pref[0]+'_'
fsuff          = '_Bmag_Bgse_Filt-Bo-w-envelope'
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
;;  Plot example of a filtered field with outer envelope
;;----------------------------------------------------------------------------------------
jj             = 104L  ;;  2014-04-19
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/calc_ip_shocks_ramp_precursor_amps_batch.pro
;;---------------------------------------------
;;  Plot |Bo|, Bo, and ∂Bo with envelope
;;---------------------------------------------
tra_plot       = [whis_st[jj[0]],tura_en[jj[0]]] + [-6,2]*1d1
IF (tdate[0] EQ '2014-04-19') THEN tra_plot       = [whis_st[jj[0]],tura_en[jj[0]]] + [-2,2]*1d1
IF (tdate[0] EQ '2014-04-19') THEN tra_plot       = tura_mid[jj[0]] + [-3.5,2]*1d1
;IF (tdate[0] EQ '2014-04-19') THEN fran_whf       = [2e-1,srate[0]]
;;  Plot results
tra_prec       = [whis_st[jj[0]],whis_en[jj[0]]]
tplot,[mfi_mag_tpn[0],mfi_gse_tpn[0],mfi_filt_tp[0]],TRANGE=tra_plot
time_bar,tra_prec,COLOR=250
time_bar,tura_mid[jj[0]],COLOR=150

;;  Send envelope to TPLOT and combine
struc          = {X:env_t,Y:envelope.V.ENV_VALS,TSHIFT:0d0}
store_data,'filtered_envelope',DATA=struc,DLIM=def_dlim,LIM=def__lim
options,'filtered_envelope',LABELS=['low','upp'],COLORS=[200,100],/DEF
;;  Merge envelope and filtered data
store_data,'Filt_Bo_with_envelope',DATA=['highpass_Bo','filtered_envelope'],LIM=def__lim

tplot,[mfi_mag_tpn[0],mfi_gse_tpn[0],'Filt_Bo_with_envelope'],TRANGE=tra_plot
time_bar,tra_prec,COLOR=250
time_bar,tura_mid[jj[0]],COLOR=150

fnm            = file_name_times(tra_plot,PREC=3)
ftime          = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)
fname          = fpref[0]+ftime[0]+fsuff[0]
  tplot,[mfi_mag_tpn[0],mfi_gse_tpn[0],'Filt_Bo_with_envelope'],TRANGE=tra_plot
popen,fname[0],_EXTRA=popen_str
  tplot,[mfi_mag_tpn[0],mfi_gse_tpn[0],'Filt_Bo_with_envelope'],TRANGE=tra_plot
pclose
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
;;  Define requirements/tests for all quasi-perp. shocks
;;----------------------------------------------------------------------------------------
test_0a        = (ABS(Mfast__up) GE 1e0) AND (ABS(M_VA___up) GE 1e0) AND (ABS(N2_N1__up) GE 1e0)
test_1a        = (ABS(thetbn_up) GE 45e0)
test_1b        = (ABS(thetbn_up) LT 45e0)
good_qperp     = WHERE(test_0a AND test_1a,gd_qperp)
good_qpara     = WHERE(test_0a AND test_1b,gd_qpara)
n_all_cfa      = N_ELEMENTS(Mfast__up)
PRINT,';;  ',n_all_cfa[0],gd_qperp[0],gd_qpara[0]
;;           430         250          83


;;----------------------------------------------------------------------------------------
;;  Print shock stats
;;    "good" = shocks satisfying the following:
;;      (M_f ≥ 1) && (ø_Bn ≥ 45) && (1 ≤ M_A ≤ 3) && (1 ≤ N2/N1 ≤ 3) && (ß_1 ≤ 1)
;;----------------------------------------------------------------------------------------
ind0           = good_qperp               ;;  All quasi-perpendicular shocks
ind1           = good_A                   ;;  All "good" shocks
ind2           = good_A[good_y_all0]      ;;  All "good" shocks with whistlers
nx             = N_ELEMENTS(ind0)
ny             = N_ELEMENTS(ind1)
nz             = N_ELEMENTS(ind2)
;;  Beta_up
xx             = beta_t_up[ind0]
yy             = beta_t_up[ind1]
zz             = beta_t_up[ind2]
beta_stats0    = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
beta_stats1    = [MIN(yy,/NAN),MAX(yy,/NAN),MEAN(yy,/NAN),MEDIAN(yy),STDDEV(yy,/NAN)*[1d0,1d0/SQRT(1d0*ny[0])]]
beta_stats2    = [MIN(zz,/NAN),MAX(zz,/NAN),MEAN(zz,/NAN),MEDIAN(zz),STDDEV(zz,/NAN)*[1d0,1d0/SQRT(1d0*nz[0])]]
;;  theta_Bn
xx             = thetbn_up[ind0]
yy             = thetbn_up[ind1]
zz             = thetbn_up[ind2]
thbn_stats0    = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
thbn_stats1    = [MIN(yy,/NAN),MAX(yy,/NAN),MEAN(yy,/NAN),MEDIAN(yy),STDDEV(yy,/NAN)*[1d0,1d0/SQRT(1d0*ny[0])]]
thbn_stats2    = [MIN(zz,/NAN),MAX(zz,/NAN),MEAN(zz,/NAN),MEDIAN(zz),STDDEV(zz,/NAN)*[1d0,1d0/SQRT(1d0*nz[0])]]
;;  Mf_up
xx             = Mfast__up[ind0]
yy             = Mfast__up[ind1]
zz             = Mfast__up[ind2]
Mfup_stats0    = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
Mfup_stats1    = [MIN(yy,/NAN),MAX(yy,/NAN),MEAN(yy,/NAN),MEDIAN(yy),STDDEV(yy,/NAN)*[1d0,1d0/SQRT(1d0*ny[0])]]
Mfup_stats2    = [MIN(zz,/NAN),MAX(zz,/NAN),MEAN(zz,/NAN),MEDIAN(zz),STDDEV(zz,/NAN)*[1d0,1d0/SQRT(1d0*nz[0])]]
;;  M_Aup
xx             = M_VA___up[ind0]
yy             = M_VA___up[ind1]
zz             = M_VA___up[ind2]
MAup_stats0    = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
MAup_stats1    = [MIN(yy,/NAN),MAX(yy,/NAN),MEAN(yy,/NAN),MEDIAN(yy),STDDEV(yy,/NAN)*[1d0,1d0/SQRT(1d0*ny[0])]]
MAup_stats2    = [MIN(zz,/NAN),MAX(zz,/NAN),MEAN(zz,/NAN),MEDIAN(zz),STDDEV(zz,/NAN)*[1d0,1d0/SQRT(1d0*nz[0])]]
;;  Vshn
xx             = vshn___up[ind0]
yy             = vshn___up[ind1]
zz             = vshn___up[ind2]
vshn_stats0    = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
vshn_stats1    = [MIN(yy,/NAN),MAX(yy,/NAN),MEAN(yy,/NAN),MEDIAN(yy),STDDEV(yy,/NAN)*[1d0,1d0/SQRT(1d0*ny[0])]]
vshn_stats2    = [MIN(zz,/NAN),MAX(zz,/NAN),MEAN(zz,/NAN),MEDIAN(zz),STDDEV(zz,/NAN)*[1d0,1d0/SQRT(1d0*nz[0])]]
;;  Ushn
xx             = ushn___up[ind0]
yy             = ushn___up[ind1]
zz             = ushn___up[ind2]
ushn_stats0    = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
ushn_stats1    = [MIN(yy,/NAN),MAX(yy,/NAN),MEAN(yy,/NAN),MEDIAN(yy),STDDEV(yy,/NAN)*[1d0,1d0/SQRT(1d0*ny[0])]]
ushn_stats2    = [MIN(zz,/NAN),MAX(zz,/NAN),MEAN(zz,/NAN),MEDIAN(zz),STDDEV(zz,/NAN)*[1d0,1d0/SQRT(1d0*nz[0])]]
;;  Bmag_up
xx             = bo_mag_up[ind0]
yy             = bo_mag_up[ind1]
zz             = bo_mag_up[ind2]
boup_stats0    = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
boup_stats1    = [MIN(yy,/NAN),MAX(yy,/NAN),MEAN(yy,/NAN),MEDIAN(yy),STDDEV(yy,/NAN)*[1d0,1d0/SQRT(1d0*ny[0])]]
boup_stats2    = [MIN(zz,/NAN),MAX(zz,/NAN),MEAN(zz,/NAN),MEDIAN(zz),STDDEV(zz,/NAN)*[1d0,1d0/SQRT(1d0*nz[0])]]
;;  Ni_up
xx             = ni_avg_up[ind0]
yy             = ni_avg_up[ind1]
zz             = ni_avg_up[ind2]
niup_stats0    = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
niup_stats1    = [MIN(yy,/NAN),MAX(yy,/NAN),MEAN(yy,/NAN),MEDIAN(yy),STDDEV(yy,/NAN)*[1d0,1d0/SQRT(1d0*ny[0])]]
niup_stats2    = [MIN(zz,/NAN),MAX(zz,/NAN),MEAN(zz,/NAN),MEDIAN(zz),STDDEV(zz,/NAN)*[1d0,1d0/SQRT(1d0*nz[0])]]
;;  ∆B = |Bmag_dn - Bmag_up|
xx             = ABS(bo_mag_dn[ind0] - bo_mag_up[ind0])
yy             = ABS(bo_mag_dn[ind1] - bo_mag_up[ind1])
zz             = ABS(bo_mag_dn[ind2] - bo_mag_up[ind2])
delb_stats0    = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
delb_stats1    = [MIN(yy,/NAN),MAX(yy,/NAN),MEAN(yy,/NAN),MEDIAN(yy),STDDEV(yy,/NAN)*[1d0,1d0/SQRT(1d0*ny[0])]]
delb_stats2    = [MIN(zz,/NAN),MAX(zz,/NAN),MEAN(zz,/NAN),MEDIAN(zz),STDDEV(zz,/NAN)*[1d0,1d0/SQRT(1d0*nz[0])]]

;;  Print stats
stat_labs      = ['Beta_up','thet_Bn','Mf___up','M_A__up','Vshn_up','Ushn_up','Bmag_up','Ni___up','Delta_B']
strc_stats0    = CREATE_STRUCT(stat_labs,beta_stats0,thbn_stats0,Mfup_stats0,MAup_stats0,vshn_stats0,ushn_stats0,boup_stats0,niup_stats0,delb_stats0)
strc_stats1    = CREATE_STRUCT(stat_labs,beta_stats1,thbn_stats1,Mfup_stats1,MAup_stats1,vshn_stats1,ushn_stats1,boup_stats1,niup_stats1,delb_stats1)
strc_stats2    = CREATE_STRUCT(stat_labs,beta_stats2,thbn_stats2,Mfup_stats2,MAup_stats2,vshn_stats2,ushn_stats2,boup_stats2,niup_stats2,delb_stats2)
mform          = '(";;  ",a7,":  ",6e15.4)'
np             = N_ELEMENTS(stat_labs)
PRINT,';;  N = ',nx[0]
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  stats = strc_stats0.(kk[0])                                                                             & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]

;;------------------------------------------------------------------------------------------------------
;;  All CfA Qperp Shocks
;;  N =          250
;;------------------------------------------------------------------------------------------------------
;;  Name              Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Beta_up:       1.8000e-02     3.8560e+00     5.4230e-01     3.9900e-01     5.2825e-01     3.3409e-02
;;  thet_Bn:       4.5200e+01     8.9800e+01     6.8286e+01     6.8200e+01     1.2721e+01     8.0454e-01
;;  Mf___up:       1.0200e+00     6.3900e+00     2.2001e+00     1.9200e+00     1.0549e+00     6.6721e-02
;;  M_A__up:       1.1485e+00     1.5607e+01     2.9491e+00     2.4716e+00     1.7875e+00     1.1305e-01
;;  Vshn_up:       9.3000e+00     1.1637e+03     4.8965e+02     4.6080e+02     1.6864e+02     1.0666e+01
;;  Ushn_up:       3.6900e+01     5.5010e+02     1.4185e+02     1.0940e+02     9.6545e+01     6.1061e+00
;;  Bmag_up:       1.0440e+00     1.8987e+01     5.9339e+00     5.4534e+00     2.9103e+00     1.8406e-01
;;  Ni___up:       6.0000e-01     3.5500e+01     8.5796e+00     7.0000e+00     5.7958e+00     3.6656e-01
;;  Delta_B:       4.0835e-01     2.8543e+01     5.9720e+00     4.6116e+00     4.4994e+00     2.8457e-01
;;------------------------------------------------------------------------------------------------------

PRINT,';;  N = ',ny[0]
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  stats = strc_stats1.(kk[0])                                                                             & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]

;;------------------------------------------------------------------------------------------------------
;;  All Shocks
;;  N =          145
;;------------------------------------------------------------------------------------------------------
;;  Name              Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Beta_up:       1.8000e-02     9.4100e-01     3.5219e-01     3.3600e-01     2.1244e-01     1.7643e-02
;;  thet_Bn:       4.5500e+01     8.8100e+01     6.7605e+01     6.8100e+01     1.2108e+01     1.0055e+00
;;  Mf___up:       1.0200e+00     2.5200e+00     1.6399e+00     1.6100e+00     3.5850e-01     2.9772e-02
;;  M_A__up:       1.1485e+00     2.9787e+00     2.0058e+00     2.0134e+00     4.8938e-01     4.0641e-02
;;  Vshn_up:       9.3000e+00     9.7560e+02     4.5215e+02     4.3310e+02     1.2405e+02     1.0301e+01
;;  Ushn_up:       3.8600e+01     2.7510e+02     1.0750e+02     9.8200e+01     4.9587e+01     4.1180e+00
;;  Bmag_up:       2.1119e+00     1.7345e+01     6.4204e+00     5.7454e+00     2.8400e+00     2.3585e-01
;;  Ni___up:       1.0000e+00     2.9500e+01     8.2828e+00     6.9000e+00     5.4993e+00     4.5669e-01
;;  Delta_B:       4.0835e-01     2.1372e+01     4.7670e+00     3.7738e+00     3.2466e+00     2.6962e-01
;;------------------------------------------------------------------------------------------------------

PRINT,';;  N = ',nz[0]
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  stats = strc_stats2.(kk[0])                                                                             & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]

;;------------------------------------------------------------------------------------------------------
;;  Only Shocks with Whistler Precursors
;;  N =          113
;;------------------------------------------------------------------------------------------------------
;;  Name              Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Beta_up:       1.8000e-02     8.2000e-01     3.1925e-01     3.0100e-01     1.9761e-01     1.8590e-02
;;  thet_Bn:       4.5500e+01     8.8100e+01     6.6417e+01     6.7000e+01     1.1586e+01     1.0899e+00
;;  Mf___up:       1.0200e+00     2.5200e+00     1.6618e+00     1.6800e+00     3.7152e-01     3.4949e-02
;;  M_A__up:       1.1485e+00     2.9497e+00     2.0003e+00     2.0134e+00     5.0948e-01     4.7928e-02
;;  Vshn_up:       9.3000e+00     9.0780e+02     4.5062e+02     4.3790e+02     1.2284e+02     1.1556e+01
;;  Ushn_up:       3.8600e+01     2.7510e+02     1.1158e+02     9.9200e+01     5.1970e+01     4.8889e+00
;;  Bmag_up:       2.1119e+00     1.7345e+01     6.7205e+00     6.0208e+00     2.9499e+00     2.7750e-01
;;  Ni___up:       1.0000e+00     2.9500e+01     8.3717e+00     6.6000e+00     5.6275e+00     5.2939e-01
;;  Delta_B:       4.0835e-01     2.1372e+01     5.1753e+00     4.3998e+00     3.4344e+00     3.2308e-01
;;------------------------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Print LaTeX table stats
;;----------------------------------------------------------------------------------------

numform        = 'f9.2'
texform        = '(";;  ",a7,":  "," & ",'+numform[0]+'," & ",'+numform[0]+'," & ",'+numform[0]+'," & ",'+numform[0]+'," & ",'+numform[0]+'," & ",'+numform[0]+',"  \tabularnewline")'
PRINT,';;  N = ',nx[0]                                                                                    & $
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  stats = strc_stats0.(kk[0])                                                                             & $
  PRINT,';;  \hline'                                                                                      & $
  PRINT,stat_labs[kk],stats,FORMAT=texform[0]
;;  N =          250
;;  \hline
;;  Beta_up:   &      0.02 &      3.86 &      0.54 &      0.40 &      0.53 &      0.03  \tabularnewline
;;  \hline
;;  thet_Bn:   &     45.20 &     89.80 &     68.29 &     68.20 &     12.72 &      0.80  \tabularnewline
;;  \hline
;;  Mf___up:   &      1.02 &      6.39 &      2.20 &      1.92 &      1.05 &      0.07  \tabularnewline
;;  \hline
;;  M_A__up:   &      1.15 &     15.61 &      2.95 &      2.47 &      1.79 &      0.11  \tabularnewline
;;  \hline
;;  Vshn_up:   &      9.30 &   1163.70 &    489.65 &    460.80 &    168.64 &     10.67  \tabularnewline
;;  \hline
;;  Ushn_up:   &     36.90 &    550.10 &    141.85 &    109.40 &     96.55 &      6.11  \tabularnewline
;;  \hline
;;  Bmag_up:   &      1.04 &     18.99 &      5.93 &      5.45 &      2.91 &      0.18  \tabularnewline
;;  \hline
;;  Ni___up:   &      0.60 &     35.50 &      8.58 &      7.00 &      5.80 &      0.37  \tabularnewline
;;  \hline
;;  Delta_B:   &      0.41 &     28.54 &      5.97 &      4.61 &      4.50 &      0.28  \tabularnewline

PRINT,';;  N = ',ny[0]                                                                                    & $
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  stats = strc_stats1.(kk[0])                                                                             & $
  PRINT,';;  \hline'                                                                                      & $
  PRINT,stat_labs[kk],stats,FORMAT=texform[0]
;;  N =          145
;;  \hline
;;  Beta_up:   &      0.02 &      0.94 &      0.35 &      0.34 &      0.21 &      0.02  \tabularnewline
;;  \hline
;;  thet_Bn:   &     45.50 &     88.10 &     67.60 &     68.10 &     12.11 &      1.01  \tabularnewline
;;  \hline
;;  Mf___up:   &      1.02 &      2.52 &      1.64 &      1.61 &      0.36 &      0.03  \tabularnewline
;;  \hline
;;  M_A__up:   &      1.15 &      2.98 &      2.01 &      2.01 &      0.49 &      0.04  \tabularnewline
;;  \hline
;;  Vshn_up:   &      9.30 &    975.60 &    452.15 &    433.10 &    124.05 &     10.30  \tabularnewline
;;  \hline
;;  Ushn_up:   &     38.60 &    275.10 &    107.50 &     98.20 &     49.59 &      4.12  \tabularnewline
;;  \hline
;;  Bmag_up:   &      2.11 &     17.35 &      6.42 &      5.75 &      2.84 &      0.24  \tabularnewline
;;  \hline
;;  Ni___up:   &      1.00 &     29.50 &      8.28 &      6.90 &      5.50 &      0.46  \tabularnewline
;;  \hline
;;  Delta_B:   &      0.41 &     21.37 &      4.77 &      3.77 &      3.25 &      0.27  \tabularnewline

PRINT,';;  N = ',nz[0]                                                                                    & $
FOR kk=0L, np[0] - 1L DO BEGIN                                                                              $
  stats = strc_stats2.(kk[0])                                                                             & $
  PRINT,';;  \hline'                                                                                      & $
  PRINT,stat_labs[kk],stats,FORMAT=texform[0]
;;  N =          113
;;  \hline
;;  Beta_up:   &      0.02 &      0.82 &      0.32 &      0.30 &      0.20 &      0.02  \tabularnewline
;;  \hline
;;  thet_Bn:   &     45.50 &     88.10 &     66.42 &     67.00 &     11.59 &      1.09  \tabularnewline
;;  \hline
;;  Mf___up:   &      1.02 &      2.52 &      1.66 &      1.68 &      0.37 &      0.03  \tabularnewline
;;  \hline
;;  M_A__up:   &      1.15 &      2.95 &      2.00 &      2.01 &      0.51 &      0.05  \tabularnewline
;;  \hline
;;  Vshn_up:   &      9.30 &    907.80 &    450.62 &    437.90 &    122.84 &     11.56  \tabularnewline
;;  \hline
;;  Ushn_up:   &     38.60 &    275.10 &    111.58 &     99.20 &     51.97 &      4.89  \tabularnewline
;;  \hline
;;  Bmag_up:   &      2.11 &     17.35 &      6.72 &      6.02 &      2.95 &      0.28  \tabularnewline
;;  \hline
;;  Ni___up:   &      1.00 &     29.50 &      8.37 &      6.60 &      5.63 &      0.53  \tabularnewline
;;  \hline
;;  Delta_B:   &      0.41 &     21.37 &      5.18 &      4.40 &      3.43 &      0.32  \tabularnewline



;;----------------------------------------------------------------------------------------
;;  Print stats
;;----------------------------------------------------------------------------------------

;;---------------------------------------------
;;  Stats:  ∂B/<B>_up = Ratio
;;---------------------------------------------
all_stats      = all_bavg_stats
;;  Determine number of events where Ratio ≥ 10%
thrsh          = 1e-1
test_min       = (all_stats[*,0] GE thrsh[0])
test_max       = (all_stats[*,1] GE thrsh[0])
test_avg       = (all_stats[*,2] GE thrsh[0])
test_med       = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min)
good_max       = WHERE(test_max,gd_max)
good_avg       = WHERE(test_avg,gd_avg)
good_med       = WHERE(test_med,gd_med)
PRINT,';;  ',gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  ',ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;             4         113          63          41
;;             4         100          56          36

;;  Determine number of events where Ratio ≥ 25%
thrsh          = 25e-2
test_min       = (all_stats[*,0] GE thrsh[0])
test_max       = (all_stats[*,1] GE thrsh[0])
test_avg       = (all_stats[*,2] GE thrsh[0])
test_med       = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min)
good_max       = WHERE(test_max,gd_max)
good_avg       = WHERE(test_avg,gd_avg)
good_med       = WHERE(test_med,gd_med)
PRINT,';;  ',gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  ',ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;             0         104          17          10
;;             0          92          15           9

;;  Determine number of events where Ratio ≥ 50%
thrsh          = 5e-1
test_min       = (all_stats[*,0] GE thrsh[0])
test_max       = (all_stats[*,1] GE thrsh[0])
test_avg       = (all_stats[*,2] GE thrsh[0])
test_med       = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min)
good_max       = WHERE(test_max,gd_max)
good_avg       = WHERE(test_avg,gd_avg)
good_med       = WHERE(test_med,gd_med)
PRINT,';;  ',gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  ',ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;             0          65           3           0
;;             0          58           3           0

;;  Determine number of events where Ratio ≥ 75%
thrsh          = 75e-2
test_min       = (all_stats[*,0] GE thrsh[0])
test_max       = (all_stats[*,1] GE thrsh[0])
test_avg       = (all_stats[*,2] GE thrsh[0])
test_med       = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min)
good_max       = WHERE(test_max,gd_max)
good_avg       = WHERE(test_avg,gd_avg)
good_med       = WHERE(test_med,gd_med)
PRINT,';;  ',gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  ',ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;             0          39           1           0
;;             0          35           1           0

;;  Print Stats for each stat
stat_labs      = ['Min','Max','Avg','Med','Std','SoM']
mform          = '(";;  ",a3,":  ",6e15.4)'
FOR kk=0L, 5L DO BEGIN                                                                                      $
  xx    = all_stats[*,kk]                                                                                 & $
  nx    = N_ELEMENTS(xx)                                                                                  & $
  stats = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]  & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;------------------------------------------------------------------------------------------------------
;;  Stat          Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Min:       5.3299e-03     1.9349e-01     2.9044e-02     1.8407e-02     2.9090e-02     2.7365e-03
;;  Max:       1.1002e-01     2.2422e+00     6.9765e-01     6.0430e-01     4.3112e-01     4.0557e-02
;;  Avg:       3.1396e-02     7.5202e-01     1.4930e-01     1.0825e-01     1.2327e-01     1.1597e-02
;;  Med:       1.9986e-02     4.9703e-01     1.1157e-01     8.1684e-02     9.6238e-02     9.0533e-03
;;  Std:       1.8120e-02     6.8495e-01     1.2273e-01     9.1855e-02     9.6641e-02     9.0912e-03
;;  SoM:       8.6332e-04     1.5316e-01     1.4916e-02     9.0003e-03     1.8628e-02     1.7524e-03
;;------------------------------------------------------------------------------------------------------

;;  Print list for all shocks
mform          = '(";;  ",a23,"  ",a23,6e15.4)'
FOR jj=0L, gd[0] - 1L DO BEGIN                                        $
  PRINT,prec_st[jj[0]],prec_en[jj[0]],REFORM(all_stats[jj[0],*]),FORMAT=mform[0]

;;---------------------------------------------
;;  Stats:  ∂B
;;---------------------------------------------
all_stats      = all_bamp_stats
;;  Determine number of events where ∂B ≥ 0.10
thrsh          = 1e-1
test_min       = (all_stats[*,0] GE thrsh[0])
test_max       = (all_stats[*,1] GE thrsh[0])
test_avg       = (all_stats[*,2] GE thrsh[0])
test_med       = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min)
good_max       = WHERE(test_max,gd_max)
good_avg       = WHERE(test_avg,gd_avg)
good_med       = WHERE(test_med,gd_med)
PRINT,';;  ',gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  ',ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;            60         113         113         113
;;            53         100         100         100

;;  Determine number of events where ∂B ≥ 0.50
thrsh          = 5e-1
test_min       = (all_stats[*,0] GE thrsh[0])
test_max       = (all_stats[*,1] GE thrsh[0])
test_avg       = (all_stats[*,2] GE thrsh[0])
test_med       = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min)
good_max       = WHERE(test_max,gd_max)
good_avg       = WHERE(test_avg,gd_avg)
good_med       = WHERE(test_med,gd_med)
PRINT,';;  ',gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  ',ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;            11         112          77          53
;;            10          99          68          47

;;  Determine number of events where ∂B ≥ 0.75
thrsh          = 75e-2
test_min       = (all_stats[*,0] GE thrsh[0])
test_max       = (all_stats[*,1] GE thrsh[0])
test_avg       = (all_stats[*,2] GE thrsh[0])
test_med       = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min)
good_max       = WHERE(test_max,gd_max)
good_avg       = WHERE(test_avg,gd_avg)
good_med       = WHERE(test_med,gd_med)
PRINT,';;  ',gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  ',ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;             3         109          46          34
;;             3          96          41          30

;;  Determine number of events where ∂B ≥ 1.00
thrsh          = 1e0
test_min       = (all_stats[*,0] GE thrsh[0])
test_max       = (all_stats[*,1] GE thrsh[0])
test_avg       = (all_stats[*,2] GE thrsh[0])
test_med       = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min)
good_max       = WHERE(test_max,gd_max)
good_avg       = WHERE(test_avg,gd_avg)
good_med       = WHERE(test_med,gd_med)
PRINT,';;  ',gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  ',ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;             2         109          33          26
;;             2          96          29          23

;;  Determine number of events where ∂B ≥ 2.00
thrsh          = 2e0
test_min       = (all_stats[*,0] GE thrsh[0])
test_max       = (all_stats[*,1] GE thrsh[0])
test_avg       = (all_stats[*,2] GE thrsh[0])
test_med       = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min)
good_max       = WHERE(test_max,gd_max)
good_avg       = WHERE(test_avg,gd_avg)
good_med       = WHERE(test_med,gd_med)
PRINT,';;  ',gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  ',ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;             0          92          13           9
;;             0          81          12           8

;;  Determine number of events where ∂B ≥ 5.00
thrsh          = 5e0
test_min       = (all_stats[*,0] GE thrsh[0])
test_max       = (all_stats[*,1] GE thrsh[0])
test_avg       = (all_stats[*,2] GE thrsh[0])
test_med       = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min)
good_max       = WHERE(test_max,gd_max)
good_avg       = WHERE(test_avg,gd_avg)
good_med       = WHERE(test_med,gd_med)
PRINT,';;  ',gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  ',ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;             0          39           0           0
;;             0          35           0           0

;;  Print Stats for each stat
stat_labs      = ['Min','Max','Avg','Med','Std','SoM']
mform          = '(";;  ",a3,":  ",6e15.4)'
FOR kk=0L, 5L DO BEGIN                                                                                      $
  xx    = all_stats[*,kk]                                                                                 & $
  nx    = N_ELEMENTS(xx)                                                                                  & $
  stats = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]  & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;------------------------------------------------------------------------------------------------------
;;  Stat          Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Min:       2.6203e-02     1.3869e+00     1.9593e-01     1.1145e-01     2.2285e-01     2.0964e-02
;;  Max:       4.8013e-01     1.7060e+01     4.5906e+00     3.3505e+00     3.4022e+00     3.2005e-01
;;  Avg:       1.1475e-01     4.3993e+00     9.8967e-01     6.9051e-01     8.7647e-01     8.2451e-02
;;  Med:       1.0125e-01     4.0985e+00     7.5096e-01     4.7405e-01     7.3438e-01     6.9085e-02
;;  Std:       5.9611e-02     3.4663e+00     7.9929e-01     5.8155e-01     6.3673e-01     5.9899e-02
;;  SoM:       2.8882e-03     7.7508e-01     9.6981e-02     6.4946e-02     1.1340e-01     1.0668e-02
;;------------------------------------------------------------------------------------------------------

;;  Print list for all shocks
mform          = '(";;  ",a23,"  ",a23,6e15.4)'
FOR jj=0L, gd[0] - 1L DO BEGIN                                        $
  PRINT,prec_st[jj[0]],prec_en[jj[0]],REFORM(all_stats[jj[0],*]),FORMAT=mform[0]

;;---------------------------------------------
;;  Stats:  ∂B/∆B
;;---------------------------------------------
all_stats      = all_ramp_stats
;;------------------------------------------------------------------------------------------------------
;;  Summary:
;;    Of the 430 FF IP shocks in the CfA database between Jan. 1, 1995 and Mar. 15, 2016,
;;    there were 145 satisfying:
;;      (M_f ≥ 1) && (ø_Bn ≥ 45) && (1 ≤ M_A ≤ 3) && (1 ≤ N2/N1 ≤ 3) && (ß_1 ≤ 1)
;;
;;    Of the 145 meeting these requirements, 113(~77.93%) show clear whistler precursors
;;
;;    For each of these 113 precursor periods, we compute the outer envelope (i.e., convex hull)
;;    of the three vector components using a 4 point sliding window.  We then compute the
;;    Min., Max., mean, median, standard deviation, and standard deviation of the mean of
;;    the peak-to-peak envelope values in the precursor interval, normalized to the
;;    change in magnetic field magnitude across the shock ramp.  We define these ratios
;;    by the symbol R_j, where j = min, max, avg, med, std, and som corresponding to the
;;    statistical parameters calculated for each interval.  From these statistics,
;;    we find:
;;      --  113(100%) satisfy R_max ≥ 10%; 112(99%) satisfy R_max ≥ 25%; 90(~80%) satisfy R_max ≥ 50%
;;      --  91(~81%) satisfy R_avg ≥ 10%; 27(~24%) satisfy R_avg ≥ 25%; 8(~7%) satisfy R_avg ≥ 50%
;;------------------------------------------------------------------------------------------------------

;;  Determine number of events where (Precursor Amp.)/(Ramp Amp.) ≥ 10%
thrsh          = 1e-1
test_min       = (all_stats[*,0] GE thrsh[0])
test_max       = (all_stats[*,1] GE thrsh[0])
test_avg       = (all_stats[*,2] GE thrsh[0])
test_med       = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min)
good_max       = WHERE(test_max,gd_max)
good_avg       = WHERE(test_avg,gd_avg)
good_med       = WHERE(test_med,gd_med)
PRINT,';;  ',gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  ',ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;            11         113          91          69
;;            10         100          81          61

;;  Determine number of events where (Precursor Amp.)/(Ramp Amp.) ≥ 25%
thrsh          = 25e-2
test_min       = (all_stats[*,0] GE thrsh[0])
test_max       = (all_stats[*,1] GE thrsh[0])
test_avg       = (all_stats[*,2] GE thrsh[0])
test_med       = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min)
good_max       = WHERE(test_max,gd_max)
good_avg       = WHERE(test_avg,gd_avg)
good_med       = WHERE(test_med,gd_med)
PRINT,';;  ',gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  ',ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;             2         112          27          15
;;             2          99          24          13

;;  Determine number of events where (Precursor Amp.)/(Ramp Amp.) ≥ 50%
thrsh          = 5e-1
test_min       = (all_stats[*,0] GE thrsh[0])
test_max       = (all_stats[*,1] GE thrsh[0])
test_avg       = (all_stats[*,2] GE thrsh[0])
test_med       = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min)
good_max       = WHERE(test_max,gd_max)
good_avg       = WHERE(test_avg,gd_avg)
good_med       = WHERE(test_med,gd_med)
PRINT,';;  ',gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  ',ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;             1          90           8           6
;;             1          80           7           5

;;  Determine number of events where (Precursor Amp.)/(Ramp Amp.) ≥ 75%
thrsh          = 75e-2
test_min       = (all_stats[*,0] GE thrsh[0])
test_max       = (all_stats[*,1] GE thrsh[0])
test_avg       = (all_stats[*,2] GE thrsh[0])
test_med       = (all_stats[*,3] GE thrsh[0])
good_min       = WHERE(test_min,gd_min)
good_max       = WHERE(test_max,gd_max)
good_avg       = WHERE(test_avg,gd_avg)
good_med       = WHERE(test_med,gd_med)
PRINT,';;  ',gd_min[0],gd_max[0],gd_avg[0],gd_med[0] & $
PRINT,';;  ',ROUND(gd_min[0]/(1d-2*gd[0])),ROUND(gd_max[0]/(1d-2*gd[0])),ROUND(gd_avg[0]/(1d-2*gd[0])),ROUND(gd_med[0]/(1d-2*gd[0]))
;;             0          65           5           5
;;             0          58           4           4

;;  Print Stats for each stat
stat_labs      = ['Min','Max','Avg','Med','Std','SoM']
mform          = '(";;  ",a3,":  ",6e15.4)'
FOR kk=0L, 5L DO BEGIN                                                                                      $
  xx    = all_stats[*,kk]                                                                                 & $
  nx    = N_ELEMENTS(xx)                                                                                  & $
  stats = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]  & $
  PRINT,stat_labs[kk],stats,FORMAT=mform[0]
;;------------------------------------------------------------------------------------------------------
;;  Stat          Min            Max            Avg            Med            Std            SoM
;;======================================================================================================
;;  Min:       5.9685e-03     5.0633e-01     4.6073e-02     2.7297e-02     6.6999e-02     6.3028e-03
;;  Max:       1.2574e-01     1.3826e+01     1.1323e+00     8.0198e-01     1.4552e+00     1.3690e-01
;;  Avg:       6.1780e-02     2.3411e+00     2.4411e-01     1.4823e-01     3.2767e-01     3.0824e-02
;;  Med:       2.9823e-02     1.7395e+00     1.8310e-01     1.0940e-01     2.5304e-01     2.3804e-02
;;  Std:       2.3227e-02     2.5390e+00     2.0147e-01     1.2476e-01     2.8912e-01     2.7198e-02
;;  SoM:       1.4274e-03     2.4814e-01     2.4048e-02     1.2456e-02     4.1116e-02     3.8679e-03
;;------------------------------------------------------------------------------------------------------



mform          = '(";;  ",a23,"  ",a23,6e15.4)'
FOR jj=0L, gd[0] - 1L DO BEGIN                                        $
  PRINT,prec_st[jj[0]],prec_en[jj[0]],REFORM(all_stats[jj[0],*]),FORMAT=mform[0]

;;----------------------------------------------------------------------------------------------------------------------------------------------
;;  ∂B/∆B Stats
;;
;;            ∂B  :  peak-to-peak amplitude of whistler precursor [nT]
;;            ∆B  :  <|B|>_dn - <|B|>_up [nT]
;;           Min  :  Minimum of all values during precursor interval
;;           Max  :  Maximum " "
;;           Avg  :  Average/Mean " "
;;           Med  :  Median " "
;;           Std  :  Standard deviation " "
;;           SoM  :  Standard deviation of the mean " "
;;
;;    Start Time  :  Time stamp [UTC] at beginning of precursor interval
;;      End Time  :  Time stamp [UTC] at end of precursor interval
;;
;;----------------------------------------------------------------------------------------------------------------------------------------------
;;       Start Time                 End Time                Min            Max            Avg            Med            Std            SoM
;;==============================================================================================================================================
;;  1995-04-17/23:32:57.740  1995-04-17/23:33:07.610     1.9796e-01     8.0603e-01     4.9654e-01     5.1328e-01     1.7064e-01     3.3465e-02
;;  1995-07-22/05:34:15.740  1995-07-22/05:35:45.049     1.7433e-02     1.0839e+00     1.1542e-01     7.2508e-02     1.4547e-01     9.3707e-03
;;  1995-08-22/12:56:39.240  1995-08-22/12:56:48.970     1.0643e-01     1.5105e+00     4.6203e-01     3.0640e-01     3.7727e-01     5.2828e-02
;;  1995-08-24/22:10:53.360  1995-08-24/22:11:04.379     4.2052e-02     5.9452e-01     1.7106e-01     1.4163e-01     1.2390e-01     1.6131e-02
;;  1995-10-22/21:20:09.761  1995-10-22/21:20:15.694     7.7529e-02     1.1119e+00     2.7318e-01     1.8450e-01     2.1225e-01     3.4893e-02
;;  1995-12-24/05:57:33.368  1995-12-24/05:57:35.006     4.6094e-02     8.3772e-01     3.0766e-01     2.9839e-01     1.8459e-01     2.5848e-02
;;  1996-02-06/19:14:13.830  1996-02-06/19:14:25.350     4.5507e-02     8.5099e-01     2.4754e-01     1.6930e-01     2.0711e-01     3.7813e-02
;;  1996-04-03/09:46:57.259  1996-04-03/09:47:17.037     2.2868e-02     1.0940e+00     1.0525e-01     7.1869e-02     1.3009e-01     1.2635e-02
;;  1996-04-08/02:41:03.620  1996-04-08/02:41:09.639     5.6034e-02     8.7306e-01     3.3170e-01     1.9104e-01     2.8030e-01     4.9550e-02
;;  1997-03-15/22:29:44.490  1997-03-15/22:30:32.279     3.9020e-02     1.2662e+00     2.7908e-01     1.9537e-01     2.3180e-01     2.0409e-02
;;  1997-04-10/12:57:53.649  1997-04-10/12:58:34.480     2.4326e-02     7.7752e-01     1.8137e-01     1.4119e-01     1.4011e-01     1.3359e-02
;;  1997-10-24/11:17:03.750  1997-10-24/11:18:09.830     1.9239e-02     1.5945e+00     1.4823e-01     9.2224e-02     1.7324e-01     9.1560e-03
;;  1997-11-01/06:14:27.659  1997-11-01/06:14:45.110     2.4120e-02     4.7414e-01     1.2495e-01     1.0420e-01     9.0374e-02     9.3214e-03
;;  1997-12-10/04:33:03.539  1997-12-10/04:33:14.666     3.4144e-02     8.8598e-01     2.1520e-01     1.3414e-01     2.3942e-01     4.4459e-02
;;  1997-12-30/01:13:20.450  1997-12-30/01:13:43.639     2.9168e-02     6.5547e-01     1.1137e-01     6.0725e-02     1.1736e-01     1.4905e-02
;;  1998-01-06/13:28:11.509  1998-01-06/13:29:00.182     1.8252e-01     1.3826e+01     2.3411e+00     1.4701e+00     2.5390e+00     2.2183e-01
;;  1998-02-18/07:46:50.370  1998-02-18/07:48:43.870     2.0786e-02     2.7982e+00     2.5940e-01     1.4076e-01     3.3204e-01     1.8950e-02
;;  1998-05-29/15:11:58.159  1998-05-29/15:12:04.299     7.7218e-02     5.3295e-01     2.1268e-01     1.8283e-01     1.2710e-01     3.2816e-02
;;  1998-08-06/07:14:35.190  1998-08-06/07:16:07.495     1.4173e-02     7.3066e-01     9.1671e-02     6.6959e-02     8.8391e-02     5.5903e-03
;;  1998-08-19/18:40:34.169  1998-08-19/18:40:41.519     1.7516e-01     1.2233e+00     4.4484e-01     3.5664e-01     2.6338e-01     6.0425e-02
;;  1998-11-08/04:40:53.240  1998-11-08/04:41:17.230     3.1595e-02     5.4809e-01     1.3106e-01     1.0698e-01     9.5673e-02     1.1959e-02
;;  1998-12-28/18:19:57.519  1998-12-28/18:20:16.065     1.5274e-02     5.2238e-01     1.3519e-01     1.2354e-01     9.5575e-02     1.3654e-02
;;  1999-01-13/10:47:36.970  1999-01-13/10:47:44.669     1.6615e-01     3.6328e+00     1.2184e+00     8.0528e-01     1.1097e+00     2.4814e-01
;;  1999-02-17/07:11:31.720  1999-02-17/07:12:13.843     2.0047e-02     5.9946e-01     1.2538e-01     9.8563e-02     9.4241e-02     8.8655e-03
;;  1999-04-16/11:13:23.500  1999-04-16/11:14:12.000     1.4302e-01     3.7383e+00     9.0854e-01     8.0527e-01     6.0580e-01     5.2929e-02
;;  1999-06-26/19:30:24.860  1999-06-26/19:30:55.759     5.6039e-02     9.3512e-01     2.6933e-01     1.8942e-01     2.0504e-01     2.2506e-02
;;  1999-08-04/01:44:01.429  1999-08-04/01:44:38.368     3.4228e-02     8.2555e-01     2.5963e-01     1.8442e-01     1.8079e-01     1.8171e-02
;;  1999-08-23/12:09:18.200  1999-08-23/12:11:14.590     1.3412e-02     1.0892e+00     1.7006e-01     1.1516e-01     1.8096e-01     1.0196e-02
;;  1999-09-22/12:09:24.743  1999-09-22/12:09:25.473     5.0633e-01     3.9949e+00     1.8508e+00     1.7395e+00     1.1152e+00     2.3253e-01
;;  1999-10-21/02:19:01.000  1999-10-21/02:20:51.235     1.6665e-02     7.0382e-01     1.2408e-01     1.0686e-01     8.1948e-02     4.7392e-03
;;  1999-11-05/20:01:36.899  1999-11-05/20:03:09.659     2.0490e-02     1.8101e+00     3.8267e-01     2.4781e-01     3.6707e-01     2.3169e-02
;;  1999-11-13/12:47:31.509  1999-11-13/12:48:57.250     1.7103e-02     7.8878e-01     9.6060e-02     6.2559e-02     1.0424e-01     6.8436e-03
;;  2000-02-05/15:25:06.629  2000-02-05/15:26:29.031     1.3950e-02     9.0750e-01     1.5839e-01     9.5699e-02     1.6998e-01     1.1383e-02
;;  2000-02-14/07:12:32.429  2000-02-14/07:12:59.740     1.1843e-01     2.5982e+00     5.3822e-01     4.1136e-01     4.4062e-01     5.1570e-02
;;  2000-06-23/12:57:16.379  2000-06-23/12:57:59.327     1.7660e-02     6.9230e-01     1.5043e-01     1.0940e-01     1.2118e-01     1.1252e-02
;;  2000-07-13/09:43:38.389  2000-07-13/09:43:51.580     1.1210e-01     2.0208e+00     5.9848e-01     4.1221e-01     4.9247e-01     8.3243e-02
;;  2000-07-26/18:59:52.940  2000-07-26/19:00:14.860     2.6160e-02     7.0035e-01     1.3258e-01     8.9553e-02     1.1709e-01     1.5375e-02
;;  2000-07-28/06:38:15.860  2000-07-28/06:38:45.817     3.1028e-02     1.3260e+00     2.1594e-01     1.7253e-01     1.8356e-01     2.0522e-02
;;  2000-08-10/05:12:21.080  2000-08-10/05:13:21.370     2.1913e-02     4.7105e-01     1.2923e-01     1.1284e-01     8.2366e-02     6.4514e-03
;;  2000-08-11/18:49:30.659  2000-08-11/18:49:34.379     6.9346e-02     5.9008e-01     2.5989e-01     2.0486e-01     1.6071e-01     2.9342e-02
;;  2000-10-28/09:30:28.309  2000-10-28/09:30:41.879     4.0974e-01     5.8811e+00     1.5848e+00     1.2592e+00     1.1627e+00     1.9378e-01
;;  2000-10-31/17:08:33.149  2000-10-31/17:09:59.284     1.3902e-02     1.4478e+00     1.3167e-01     6.0377e-02     1.8592e-01     1.2180e-02
;;  2000-11-06/09:29:09.789  2000-11-06/09:30:20.669     7.3098e-02     2.1320e+00     6.3054e-01     4.6242e-01     4.8957e-01     3.5424e-02
;;  2000-11-26/11:43:20.870  2000-11-26/11:43:26.710     1.1352e-01     1.2076e+00     3.4302e-01     2.6632e-01     2.4902e-01     4.8837e-02
;;  2000-11-28/05:25:33.700  2000-11-28/05:27:41.985     1.3641e-02     4.3889e-01     8.7251e-02     6.2844e-02     6.5856e-02     3.5353e-03
;;  2001-01-17/04:07:10.799  2001-01-17/04:07:53.059     1.7102e-02     2.9572e-01     1.1433e-01     1.0575e-01     5.4846e-02     5.1368e-03
;;  2001-03-03/11:28:22.080  2001-03-03/11:29:20.899     1.8582e-02     1.4589e+00     1.8993e-01     1.1057e-01     2.5338e-01     2.0094e-02
;;  2001-03-22/13:58:30.230  2001-03-22/13:59:06.240     5.9685e-03     4.6052e-01     6.1780e-02     2.9823e-02     8.1739e-02     8.2993e-03
;;  2001-03-27/18:07:15.600  2001-03-27/18:07:48.210     1.2912e-02     4.5931e-01     6.2641e-02     4.6158e-02     6.7183e-02     7.1617e-03
;;  2001-04-21/15:29:02.879  2001-04-21/15:29:14.123     4.7216e-02     2.8165e-01     1.0734e-01     8.3859e-02     5.8607e-02     1.0883e-02
;;  2001-05-06/09:05:27.789  2001-05-06/09:06:08.332     2.6777e-02     7.7151e-01     1.4049e-01     9.2750e-02     1.2476e-01     1.1950e-02
;;  2001-05-12/10:01:41.690  2001-05-12/10:03:14.317     1.5750e-02     3.7054e-01     8.2922e-02     7.4003e-02     4.7858e-02     3.0268e-03
;;  2001-09-13/02:30:10.129  2001-09-13/02:31:26.029     2.6803e-02     6.7168e-01     1.6890e-01     1.4167e-01     1.1185e-01     7.8892e-03
;;  2001-10-28/03:13:23.950  2001-10-28/03:13:48.500     2.1390e-02     5.8537e-01     1.4444e-01     1.1961e-01     1.0042e-01     1.2456e-02
;;  2001-11-30/18:15:10.889  2001-11-30/18:15:45.440     2.6098e-02     8.5306e-01     1.5539e-01     1.2370e-01     1.2858e-01     1.3333e-02
;;  2001-12-21/14:09:42.850  2001-12-21/14:10:17.090     3.9890e-02     9.4768e-01     2.5797e-01     2.3630e-01     1.6162e-01     1.6850e-02
;;  2001-12-30/20:04:29.870  2001-12-30/20:05:05.830     2.1035e-02     8.0008e-01     1.3586e-01     9.5677e-02     1.3437e-01     1.3714e-02
;;  2002-01-17/05:26:51.590  2002-01-17/05:26:56.879     5.0993e-02     4.7193e-01     2.4054e-01     2.1083e-01     1.2031e-01     2.0337e-02
;;  2002-01-31/21:37:31.419  2002-01-31/21:38:10.404     2.1287e-02     3.5433e-01     7.5030e-02     5.5578e-02     5.9284e-02     8.2212e-03
;;  2002-03-23/11:23:24.620  2002-03-23/11:24:09.210     8.4391e-03     5.0217e-01     7.4335e-02     4.6378e-02     7.8112e-02     7.1306e-03
;;  2002-03-29/22:15:09.809  2002-03-29/22:15:13.250     3.0831e-02     3.9706e-01     1.4096e-01     1.1635e-01     1.0333e-01     1.8866e-02
;;  2002-05-21/21:13:11.610  2002-05-21/21:14:15.840     3.0040e-02     7.7917e-01     1.8124e-01     1.2124e-01     1.6510e-01     1.2552e-02
;;  2002-06-29/21:09:57.429  2002-06-29/21:10:26.399     6.7661e-02     1.4389e+00     4.1490e-01     3.3871e-01     2.5471e-01     2.8840e-02
;;  2002-08-01/23:08:31.379  2002-08-01/23:09:07.282     2.7690e-02     8.8995e-01     1.1332e-01     7.8741e-02     1.1631e-01     1.1871e-02
;;  2002-09-30/07:53:38.919  2002-09-30/07:54:24.149     2.8931e-02     8.0198e-01     1.4124e-01     1.1626e-01     9.4995e-02     8.6005e-03
;;  2002-11-09/18:27:30.419  2002-11-09/18:27:49.240     1.3664e-02     4.0928e-01     8.9446e-02     6.0476e-02     8.6265e-02     1.2200e-02
;;  2003-05-29/18:30:49.730  2003-05-29/18:31:07.827     6.4890e-02     5.3008e-01     2.0584e-01     1.9177e-01     9.7407e-02     1.4060e-02
;;  2003-06-18/04:40:53.679  2003-06-18/04:42:06.159     3.4423e-02     1.0973e+00     2.2329e-01     1.7615e-01     1.7375e-01     1.2411e-02
;;  2004-04-12/18:28:23.210  2004-04-12/18:29:46.279     2.8394e-02     7.3559e-01     1.3580e-01     1.0161e-01     1.1082e-01     7.4043e-03
;;  2005-05-06/12:03:02.500  2005-05-06/12:08:38.930     1.3339e-02     1.3033e+00     1.0806e-01     7.5318e-02     1.1991e-01     3.9686e-03
;;  2005-05-07/18:26:09.069  2005-05-07/18:26:16.081     5.5219e-02     3.3192e-01     1.3150e-01     1.0774e-01     7.0278e-02     1.6565e-02
;;  2005-06-16/08:07:07.720  2005-06-16/08:09:10.069     8.0072e-03     1.0222e+00     8.8907e-02     5.0482e-02     1.1170e-01     6.1394e-03
;;  2005-07-10/02:41:17.430  2005-07-10/02:42:30.726     9.6666e-03     4.2421e-01     7.5726e-02     4.8999e-02     6.7490e-02     4.7963e-03
;;  2005-08-24/05:34:39.140  2005-08-24/05:35:24.414     9.8149e-03     3.6765e-01     7.2913e-02     4.7293e-02     7.2669e-02     6.5792e-03
;;  2005-09-02/13:48:38.779  2005-09-02/13:50:16.069     1.6529e-02     7.7939e-01     1.0133e-01     7.3866e-02     1.0198e-01     6.2883e-03
;;  2006-08-19/09:33:17.500  2006-08-19/09:38:48.400     2.1551e-02     2.1147e+00     2.8914e-01     1.7557e-01     3.1722e-01     1.0586e-02
;;  2007-08-22/04:31:24.700  2007-08-22/04:34:03.000     6.1213e-02     8.5308e-01     2.0389e-01     1.8284e-01     1.0592e-01     5.1316e-03
;;  2007-12-17/01:52:53.579  2007-12-17/01:53:18.549     3.8819e-02     9.6727e-01     1.3065e-01     9.0912e-02     1.5119e-01     1.8471e-02
;;  2008-05-28/01:14:59.750  2008-05-28/01:17:38.161     9.4231e-03     6.6212e-01     6.9991e-02     5.0285e-02     6.3672e-02     3.0777e-03
;;  2008-06-24/18:52:21.700  2008-06-24/19:10:41.963     1.2147e-02     1.7958e+00     6.5998e-02     5.1167e-02     7.7933e-02     1.4274e-03
;;  2009-02-03/19:21:01.865  2009-02-03/19:21:03.157     4.7669e-02     9.6611e-01     2.6188e-01     2.0625e-01     2.2583e-01     4.6098e-02
;;  2009-06-24/09:52:07.650  2009-06-24/09:52:20.400     3.8322e-02     4.8690e-01     1.3415e-01     1.0306e-01     9.8882e-02     1.6958e-02
;;  2009-06-27/11:03:13.559  2009-06-27/11:04:18.898     2.6908e-02     6.0992e-01     1.1793e-01     9.5971e-02     8.3463e-02     6.2912e-03
;;  2009-10-21/23:13:55.190  2009-10-21/23:15:09.880     2.0460e-02     8.2563e-01     1.1190e-01     8.3754e-02     1.0370e-01     7.2960e-03
;;  2010-04-11/12:19:16.900  2010-04-11/12:20:56.220     1.0810e-02     9.6742e-01     1.1069e-01     7.6103e-02     1.2023e-01     7.3306e-03
;;  2011-02-04/01:50:37.319  2011-02-04/01:50:55.670     3.4418e-02     8.3902e-01     2.1306e-01     1.1291e-01     2.1702e-01     3.1003e-02
;;  2011-07-11/08:26:30.220  2011-07-11/08:27:25.471     2.8047e-02     7.2353e-01     1.4506e-01     1.1461e-01     1.1601e-01     9.5041e-03
;;  2011-09-16/18:54:08.200  2011-09-16/18:57:15.299     5.4510e-02     1.9384e+00     4.6045e-01     3.4843e-01     3.1610e-01     1.4052e-02
;;  2011-09-25/10:43:56.410  2011-09-25/10:46:32.085     1.0909e-02     1.2828e+00     6.6576e-02     3.9072e-02     1.0244e-01     4.9867e-03
;;  2012-01-21/04:00:32.019  2012-01-21/04:02:01.809     1.5063e-02     5.1889e-01     7.8789e-02     5.4195e-02     8.2140e-02     5.2693e-03
;;  2012-01-30/15:43:03.640  2012-01-30/15:43:13.309     1.7310e-02     1.2574e-01     6.4828e-02     6.1338e-02     2.3227e-02     4.6454e-03
;;  2012-06-16/19:34:25.569  2012-06-16/19:34:39.369     6.2963e-02     5.7351e-01     1.7786e-01     1.3229e-01     1.1998e-01     1.9997e-02
;;  2012-10-08/04:11:45.970  2012-10-08/04:12:14.022     2.6371e-02     4.5240e-01     1.1215e-01     7.5007e-02     8.9271e-02     1.0308e-02
;;  2012-11-12/22:12:34.461  2012-11-12/22:12:41.579     3.4707e-02     5.1023e-01     1.7310e-01     1.0636e-01     1.4148e-01     3.3346e-02
;;  2012-11-26/04:32:36.150  2012-11-26/04:32:50.960     4.1473e-02     5.1944e-01     1.2530e-01     9.2784e-02     9.6034e-02     1.5378e-02
;;  2013-02-13/00:46:46.049  2013-02-13/00:47:45.742     2.7297e-02     1.1595e+00     1.7998e-01     1.4045e-01     1.4471e-01     1.1405e-02
;;  2013-04-30/08:52:30.789  2013-04-30/08:52:46.417     4.2216e-02     4.4177e-01     1.3418e-01     1.0527e-01     8.0703e-02     1.2604e-02
;;  2013-06-10/02:51:45.099  2013-06-10/02:52:01.335     3.5485e-02     7.8648e-01     2.2201e-01     1.8059e-01     1.6596e-01     2.5309e-02
;;  2013-07-12/16:42:29.809  2013-07-12/16:43:28.516     1.1170e-02     1.1322e+00     1.5230e-01     8.5946e-02     1.8795e-01     1.4952e-02
;;  2013-09-02/01:55:13.480  2013-09-02/01:56:49.119     4.6741e-02     1.5862e+00     2.6511e-01     1.8428e-01     2.3450e-01     1.4571e-02
;;  2013-10-26/21:18:46.200  2013-10-26/21:26:02.099     1.4261e-02     1.2550e+00     7.9379e-02     4.7419e-02     1.2636e-01     3.6740e-03
;;  2014-02-13/08:53:39.980  2014-02-13/08:55:28.934     8.3763e-03     7.6916e-01     6.2879e-02     3.0949e-02     9.0909e-02     5.2929e-03
;;  2014-02-15/12:46:04.039  2014-02-15/12:46:36.901     1.4773e-02     4.7326e-01     9.8319e-02     8.1871e-02     7.8616e-02     8.3805e-03
;;  2014-02-19/03:09:14.809  2014-02-19/03:09:38.861     1.7552e-02     4.7220e-01     7.3717e-02     5.0743e-02     7.9764e-02     9.9705e-03
;;  2014-04-19/17:46:30.859  2014-04-19/17:48:25.604     2.1552e-02     1.4951e+00     1.8746e-01     1.0102e-01     2.5723e-01     1.4586e-02
;;  2014-05-07/21:17:03.170  2014-05-07/21:19:38.779     1.4380e-02     1.3613e+00     1.8027e-01     1.0336e-01     2.0353e-01     9.9078e-03
;;  2014-05-29/08:25:13.950  2014-05-29/08:26:40.940     3.1560e-02     1.1190e+00     1.7100e-01     1.2935e-01     1.5003e-01     9.7867e-03
;;  2014-07-14/13:37:34.940  2014-07-14/13:38:08.971     1.6115e-02     2.9429e-01     8.3835e-02     6.9860e-02     5.7384e-02     6.0155e-03
;;  2015-05-06/00:55:30.509  2015-05-06/00:55:49.854     2.7308e-02     6.3971e-01     1.0809e-01     7.2109e-02     1.3290e-01     1.8430e-02
;;  2015-06-24/13:06:37.990  2015-06-24/13:07:14.601     3.5935e-02     5.3498e-01     1.5212e-01     1.4024e-01     8.1299e-02     8.2124e-03
;;  2015-08-15/07:43:17.430  2015-08-15/07:43:40.250     5.1629e-02     1.1462e+00     2.1690e-01     1.6586e-01     1.8521e-01     2.3713e-02
;;  2016-03-11/04:24:15.900  2016-03-11/04:29:29.400     1.4339e-02     1.4141e+00     2.0338e-01     1.6811e-01     1.4172e-01     4.8580e-03
;;  2016-03-14/16:16:06.680  2016-03-14/16:16:31.880     3.6450e-02     4.1726e-01     1.1152e-01     1.0349e-01     5.4651e-02     6.6767e-03
;;----------------------------------------------------------------------------------------------------------------------------------------------


;;----------------------------------------------------------------------------------------------------------------------------------------------
;;  ∂B/<B>_up Stats
;;
;;            ∂B  :  peak-to-peak amplitude of whistler precursor [nT]
;;            ∆B  :  <|B|>_up = upstream averaged quasi-static magnetic field magnitude [nT]
;;           Min  :  Minimum of all values during precursor interval
;;           Max  :  Maximum " "
;;           Avg  :  Average/Mean " "
;;           Med  :  Median " "
;;           Std  :  Standard deviation " "
;;           SoM  :  Standard deviation of the mean " "
;;
;;    Start Time  :  Time stamp [UTC] at beginning of precursor interval
;;      End Time  :  Time stamp [UTC] at end of precursor interval
;;
;;----------------------------------------------------------------------------------------------------------------------------------------------
;;       Start Time                 End Time                Min            Max            Avg            Med            Std            SoM
;;==============================================================================================================================================
;;  1995-04-17/23:32:57.740  1995-04-17/23:33:07.610     5.8107e-02     2.3659e-01     1.4575e-01     1.5066e-01     5.0086e-02     9.8227e-03
;;  1995-07-22/05:34:15.740  1995-07-22/05:35:45.049     1.4305e-02     8.8947e-01     9.4719e-02     5.9501e-02     1.1938e-01     7.6897e-03
;;  1995-08-22/12:56:39.240  1995-08-22/12:56:48.970     1.0172e-01     1.4438e+00     4.4160e-01     2.9286e-01     3.6059e-01     5.0493e-02
;;  1995-08-24/22:10:53.360  1995-08-24/22:11:04.379     2.8767e-02     4.0670e-01     1.1702e-01     9.6889e-02     8.4758e-02     1.1035e-02
;;  1995-10-22/21:20:09.761  1995-10-22/21:20:15.694     4.5168e-02     6.4782e-01     1.5915e-01     1.0749e-01     1.2365e-01     2.0329e-02
;;  1995-12-24/05:57:33.368  1995-12-24/05:57:35.006     5.6608e-02     1.0288e+00     3.7783e-01     3.6645e-01     2.2669e-01     3.1744e-02
;;  1996-02-06/19:14:13.830  1996-02-06/19:14:25.350     2.1956e-02     4.1058e-01     1.1943e-01     8.1684e-02     9.9926e-02     1.8244e-02
;;  1996-04-03/09:46:57.259  1996-04-03/09:47:17.037     1.3322e-02     6.3733e-01     6.1311e-02     4.1867e-02     7.5783e-02     7.3606e-03
;;  1996-04-08/02:41:03.620  1996-04-08/02:41:09.639     3.2744e-02     5.1018e-01     1.9383e-01     1.1164e-01     1.6379e-01     2.8955e-02
;;  1997-03-15/22:29:44.490  1997-03-15/22:30:32.279     1.0535e-02     3.4185e-01     7.5349e-02     5.2747e-02     6.2583e-02     5.5102e-03
;;  1997-04-10/12:57:53.649  1997-04-10/12:58:34.480     8.6106e-03     2.7522e-01     6.4200e-02     4.9977e-02     4.9594e-02     4.7286e-03
;;  1997-10-24/11:17:03.750  1997-10-24/11:18:09.830     1.9620e-02     1.6260e+00     1.5116e-01     9.4047e-02     1.7666e-01     9.3370e-03
;;  1997-11-01/06:14:27.659  1997-11-01/06:14:45.110     1.4856e-02     2.9203e-01     7.6961e-02     6.4180e-02     5.5663e-02     5.7412e-03
;;  1997-12-10/04:33:03.539  1997-12-10/04:33:14.666     4.1656e-02     1.0809e+00     2.6255e-01     1.6365e-01     2.9210e-01     5.4241e-02
;;  1997-12-30/01:13:20.450  1997-12-30/01:13:43.639     2.6892e-02     6.0433e-01     1.0268e-01     5.5986e-02     1.0821e-01     1.3742e-02
;;  1998-01-06/13:28:11.509  1998-01-06/13:29:00.182     1.1406e-02     8.6398e-01     1.4630e-01     9.1870e-02     1.5866e-01     1.3862e-02
;;  1998-02-18/07:46:50.370  1998-02-18/07:48:43.870     8.1443e-03     1.0964e+00     1.0163e-01     5.5150e-02     1.3009e-01     7.4249e-03
;;  1998-05-29/15:11:58.159  1998-05-29/15:12:04.299     5.2822e-02     3.6457e-01     1.4549e-01     1.2507e-01     8.6942e-02     2.2448e-02
;;  1998-08-06/07:14:35.190  1998-08-06/07:16:07.495     1.0356e-02     5.3391e-01     6.6986e-02     4.8928e-02     6.4589e-02     4.0850e-03
;;  1998-08-19/18:40:34.169  1998-08-19/18:40:41.519     1.9349e-01     1.3514e+00     4.9140e-01     3.9397e-01     2.9095e-01     6.6749e-02
;;  1998-11-08/04:40:53.240  1998-11-08/04:41:17.230     2.8815e-02     4.9987e-01     1.1953e-01     9.7564e-02     8.7256e-02     1.0907e-02
;;  1998-12-28/18:19:57.519  1998-12-28/18:20:16.065     1.1706e-02     4.0037e-01     1.0362e-01     9.4683e-02     7.3251e-02     1.0464e-02
;;  1999-01-13/10:47:36.970  1999-01-13/10:47:44.669     1.0255e-01     2.2422e+00     7.5202e-01     4.9703e-01     6.8495e-01     1.5316e-01
;;  1999-02-17/07:11:31.720  1999-02-17/07:12:13.843     1.2783e-02     3.8225e-01     7.9946e-02     6.2849e-02     6.0093e-02     5.6531e-03
;;  1999-04-16/11:13:23.500  1999-04-16/11:14:12.000     7.8471e-02     2.0511e+00     4.9849e-01     4.4183e-01     3.3239e-01     2.9041e-02
;;  1999-06-26/19:30:24.860  1999-06-26/19:30:55.759     5.4816e-02     9.1471e-01     2.6345e-01     1.8529e-01     2.0056e-01     2.2015e-02
;;  1999-08-04/01:44:01.429  1999-08-04/01:44:38.368     3.4767e-02     8.3854e-01     2.6372e-01     1.8732e-01     1.8364e-01     1.8457e-02
;;  1999-08-23/12:09:18.200  1999-08-23/12:11:14.590     5.3299e-03     4.3284e-01     6.7581e-02     4.5766e-02     7.1913e-02     4.0519e-03
;;  1999-09-22/12:09:24.743  1999-09-22/12:09:25.473     8.9060e-02     7.0269e-01     3.2554e-01     3.0596e-01     1.9615e-01     4.0901e-02
;;  1999-10-21/02:19:01.000  1999-10-21/02:20:51.235     2.8570e-02     1.2066e+00     2.1271e-01     1.8319e-01     1.4049e-01     8.1245e-03
;;  1999-11-05/20:01:36.899  1999-11-05/20:03:09.659     9.2404e-03     8.1630e-01     1.7257e-01     1.1176e-01     1.6554e-01     1.0449e-02
;;  1999-11-13/12:47:31.509  1999-11-13/12:48:57.250     1.0758e-02     4.9613e-01     6.0420e-02     3.9349e-02     6.5565e-02     4.3046e-03
;;  2000-02-05/15:25:06.629  2000-02-05/15:26:29.031     7.1082e-03     4.6241e-01     8.0703e-02     4.8762e-02     8.6613e-02     5.8000e-03
;;  2000-02-14/07:12:32.429  2000-02-14/07:12:59.740     6.8726e-02     1.5077e+00     3.1233e-01     2.3871e-01     2.5569e-01     2.9927e-02
;;  2000-06-23/12:57:16.379  2000-06-23/12:57:59.327     2.4621e-02     9.6516e-01     2.0972e-01     1.5252e-01     1.6895e-01     1.5686e-02
;;  2000-07-13/09:43:38.389  2000-07-13/09:43:51.580     7.7418e-02     1.3956e+00     4.1333e-01     2.8468e-01     3.4012e-01     5.7490e-02
;;  2000-07-26/18:59:52.940  2000-07-26/19:00:14.860     1.5618e-02     4.1814e-01     7.9153e-02     5.3466e-02     6.9909e-02     9.1795e-03
;;  2000-07-28/06:38:15.860  2000-07-28/06:38:45.817     3.6786e-02     1.5721e+00     2.5601e-01     2.0455e-01     2.1762e-01     2.4330e-02
;;  2000-08-10/05:12:21.080  2000-08-10/05:13:21.370     1.4400e-02     3.0954e-01     8.4921e-02     7.4148e-02     5.4125e-02     4.2394e-03
;;  2000-08-11/18:49:30.659  2000-08-11/18:49:34.379     7.2102e-02     6.1353e-01     2.7022e-01     2.1300e-01     1.6710e-01     3.0508e-02
;;  2000-10-28/09:30:28.309  2000-10-28/09:30:41.879     1.3900e-01     1.9951e+00     5.3763e-01     4.2716e-01     3.9442e-01     6.5736e-02
;;  2000-10-31/17:08:33.149  2000-10-31/17:09:59.284     9.4190e-03     9.8096e-01     8.9210e-02     4.0908e-02     1.2597e-01     8.2524e-03
;;  2000-11-06/09:29:09.789  2000-11-06/09:30:20.669     6.8859e-02     2.0083e+00     5.9397e-01     4.3560e-01     4.6118e-01     3.3370e-02
;;  2000-11-26/11:43:20.870  2000-11-26/11:43:26.710     6.6559e-02     7.0800e-01     2.0111e-01     1.5614e-01     1.4600e-01     2.8633e-02
;;  2000-11-28/05:25:33.700  2000-11-28/05:27:41.985     9.5671e-03     3.0781e-01     6.1191e-02     4.4074e-02     4.6186e-02     2.4794e-03
;;  2001-01-17/04:07:10.799  2001-01-17/04:07:53.059     6.8720e-03     1.1882e-01     4.5941e-02     4.2492e-02     2.2038e-02     2.0640e-03
;;  2001-03-03/11:28:22.080  2001-03-03/11:29:20.899     1.7370e-02     1.3638e+00     1.7754e-01     1.0335e-01     2.3685e-01     1.8783e-02
;;  2001-03-22/13:58:30.230  2001-03-22/13:59:06.240     5.4874e-03     4.2339e-01     5.6799e-02     2.7419e-02     7.5150e-02     7.6303e-03
;;  2001-03-27/18:07:15.600  2001-03-27/18:07:48.210     1.3778e-02     4.9011e-01     6.6842e-02     4.9254e-02     7.1688e-02     7.6420e-03
;;  2001-04-21/15:29:02.879  2001-04-21/15:29:14.123     2.5715e-02     1.5340e-01     5.8462e-02     4.5672e-02     3.1919e-02     5.9273e-03
;;  2001-05-06/09:05:27.789  2001-05-06/09:06:08.332     1.5869e-02     4.5724e-01     8.3260e-02     5.4969e-02     7.3941e-02     7.0822e-03
;;  2001-05-12/10:01:41.690  2001-05-12/10:03:14.317     5.9633e-03     1.4029e-01     3.1396e-02     2.8019e-02     1.8120e-02     1.1460e-03
;;  2001-09-13/02:30:10.129  2001-09-13/02:31:26.029     1.1696e-02     2.9309e-01     7.3698e-02     6.1818e-02     4.8805e-02     3.4424e-03
;;  2001-10-28/03:13:23.950  2001-10-28/03:13:48.500     3.0289e-02     8.2889e-01     2.0453e-01     1.6936e-01     1.4220e-01     1.7638e-02
;;  2001-11-30/18:15:10.889  2001-11-30/18:15:45.440     1.2534e-02     4.0968e-01     7.4627e-02     5.9406e-02     6.1751e-02     6.4033e-03
;;  2001-12-21/14:09:42.850  2001-12-21/14:10:17.090     1.3325e-02     3.1658e-01     8.6176e-02     7.8938e-02     5.3989e-02     5.6288e-03
;;  2001-12-30/20:04:29.870  2001-12-30/20:05:05.830     1.6699e-02     6.3518e-01     1.0785e-01     7.5958e-02     1.0668e-01     1.0888e-02
;;  2002-01-17/05:26:51.590  2002-01-17/05:26:56.879     4.1790e-02     3.8676e-01     1.9713e-01     1.7278e-01     9.8599e-02     1.6666e-02
;;  2002-01-31/21:37:31.419  2002-01-31/21:38:10.404     2.7722e-02     4.6143e-01     9.7710e-02     7.2378e-02     7.7204e-02     1.0706e-02
;;  2002-03-23/11:23:24.620  2002-03-23/11:24:09.210     1.7699e-02     1.0532e+00     1.5590e-01     9.7268e-02     1.6382e-01     1.4955e-02
;;  2002-03-29/22:15:09.809  2002-03-29/22:15:13.250     4.0023e-02     5.1545e-01     1.8298e-01     1.5104e-01     1.3414e-01     2.4491e-02
;;  2002-05-21/21:13:11.610  2002-05-21/21:14:15.840     2.5404e-02     6.5892e-01     1.5327e-01     1.0253e-01     1.3962e-01     1.0615e-02
;;  2002-06-29/21:09:57.429  2002-06-29/21:10:26.399     2.6167e-02     5.5649e-01     1.6045e-01     1.3099e-01     9.8503e-02     1.1153e-02
;;  2002-08-01/23:08:31.379  2002-08-01/23:09:07.282     2.4414e-02     7.8466e-01     9.9913e-02     6.9425e-02     1.0255e-01     1.0466e-02
;;  2002-09-30/07:53:38.919  2002-09-30/07:54:24.149     1.7087e-02     4.7366e-01     8.3422e-02     6.8666e-02     5.6106e-02     5.0796e-03
;;  2002-11-09/18:27:30.419  2002-11-09/18:27:49.240     1.1564e-02     3.4639e-01     7.5702e-02     5.1183e-02     7.3009e-02     1.0325e-02
;;  2003-05-29/18:30:49.730  2003-05-29/18:31:07.827     9.8078e-02     8.0118e-01     3.1112e-01     2.8985e-01     1.4723e-01     2.1250e-02
;;  2003-06-18/04:40:53.679  2003-06-18/04:42:06.159     1.9909e-02     6.3465e-01     1.2914e-01     1.0188e-01     1.0049e-01     7.1781e-03
;;  2004-04-12/18:28:23.210  2004-04-12/18:29:46.279     3.5151e-02     9.1064e-01     1.6811e-01     1.2579e-01     1.3719e-01     9.1664e-03
;;  2005-05-06/12:03:02.500  2005-05-06/12:08:38.930     7.2481e-03     7.0817e-01     5.8717e-02     4.0926e-02     6.5159e-02     2.1564e-03
;;  2005-05-07/18:26:09.069  2005-05-07/18:26:16.081     1.8303e-02     1.1002e-01     4.3589e-02     3.5714e-02     2.3295e-02     5.4906e-03
;;  2005-06-16/08:07:07.720  2005-06-16/08:09:10.069     5.8359e-03     7.4504e-01     6.4798e-02     3.6793e-02     8.1408e-02     4.4746e-03
;;  2005-07-10/02:41:17.430  2005-07-10/02:42:30.726     7.4813e-03     3.2831e-01     5.8607e-02     3.7922e-02     5.2233e-02     3.7120e-03
;;  2005-08-24/05:34:39.140  2005-08-24/05:35:24.414     1.1120e-02     4.1653e-01     8.2608e-02     5.3581e-02     8.2331e-02     7.4539e-03
;;  2005-09-02/13:48:38.779  2005-09-02/13:50:16.069     1.8407e-02     8.6792e-01     1.1284e-01     8.2257e-02     1.1356e-01     7.0026e-03
;;  2006-08-19/09:33:17.500  2006-08-19/09:38:48.400     6.7925e-03     6.6652e-01     9.1132e-02     5.5336e-02     9.9980e-02     3.3364e-03
;;  2007-08-22/04:31:24.700  2007-08-22/04:34:03.000     1.4293e-02     1.9919e-01     4.7607e-02     4.2693e-02     2.4731e-02     1.1982e-03
;;  2007-12-17/01:52:53.579  2007-12-17/01:53:18.549     4.1915e-02     1.0444e+00     1.4107e-01     9.8164e-02     1.6325e-01     1.9944e-02
;;  2008-05-28/01:14:59.750  2008-05-28/01:17:38.161     8.9019e-03     6.2549e-01     6.6120e-02     4.7504e-02     6.0150e-02     2.9074e-03
;;  2008-06-24/18:52:21.700  2008-06-24/19:10:41.963     7.3470e-03     1.0862e+00     3.9917e-02     3.0947e-02     4.7136e-02     8.6332e-04
;;  2009-02-03/19:21:01.865  2009-02-03/19:21:03.157     3.4394e-02     6.9706e-01     1.8895e-01     1.4881e-01     1.6294e-01     3.3260e-02
;;  2009-06-24/09:52:07.650  2009-06-24/09:52:20.400     2.6183e-02     3.3266e-01     9.1653e-02     7.0414e-02     6.7559e-02     1.1586e-02
;;  2009-06-27/11:03:13.559  2009-06-27/11:04:18.898     1.3571e-02     3.0762e-01     5.9480e-02     4.8404e-02     4.2095e-02     3.1730e-03
;;  2009-10-21/23:13:55.190  2009-10-21/23:15:09.880     1.0916e-02     4.4047e-01     5.9696e-02     4.4683e-02     5.5322e-02     3.8924e-03
;;  2010-04-11/12:19:16.900  2010-04-11/12:20:56.220     1.1580e-02     1.0364e+00     1.1858e-01     8.1527e-02     1.2880e-01     7.8530e-03
;;  2011-02-04/01:50:37.319  2011-02-04/01:50:55.670     2.8871e-02     7.0380e-01     1.7872e-01     9.4711e-02     1.8204e-01     2.6006e-02
;;  2011-07-11/08:26:30.220  2011-07-11/08:27:25.471     2.6043e-02     6.7185e-01     1.3470e-01     1.0643e-01     1.0773e-01     8.8253e-03
;;  2011-09-16/18:54:08.200  2011-09-16/18:57:15.299     9.7813e-03     3.4784e-01     8.2623e-02     6.2523e-02     5.6722e-02     2.5216e-03
;;  2011-09-25/10:43:56.410  2011-09-25/10:46:32.085     8.9639e-03     1.0541e+00     5.4704e-02     3.2105e-02     8.4174e-02     4.0975e-03
;;  2012-01-21/04:00:32.019  2012-01-21/04:02:01.809     8.6037e-03     2.9639e-01     4.5004e-02     3.0956e-02     4.6918e-02     3.0098e-03
;;  2012-01-30/15:43:03.640  2012-01-30/15:43:13.309     2.7722e-02     2.0138e-01     1.0382e-01     9.8232e-02     3.7198e-02     7.4395e-03
;;  2012-06-16/19:34:25.569  2012-06-16/19:34:39.369     6.1445e-02     5.5969e-01     1.7358e-01     1.2911e-01     1.1709e-01     1.9515e-02
;;  2012-10-08/04:11:45.970  2012-10-08/04:12:14.022     2.4555e-02     4.2124e-01     1.0443e-01     6.9842e-02     8.3124e-02     9.5983e-03
;;  2012-11-12/22:12:34.461  2012-11-12/22:12:41.579     3.6193e-02     5.3207e-01     1.8052e-01     1.1091e-01     1.4754e-01     3.4774e-02
;;  2012-11-26/04:32:36.150  2012-11-26/04:32:50.960     3.9669e-02     4.9684e-01     1.1985e-01     8.8746e-02     9.1855e-02     1.4709e-02
;;  2013-02-13/00:46:46.049  2013-02-13/00:47:45.742     2.1152e-02     8.9852e-01     1.3946e-01     1.0884e-01     1.1213e-01     8.8374e-03
;;  2013-04-30/08:52:30.789  2013-04-30/08:52:46.417     2.3142e-02     2.4217e-01     7.3552e-02     5.7704e-02     4.4239e-02     6.9090e-03
;;  2013-06-10/02:51:45.099  2013-06-10/02:52:01.335     1.9590e-02     4.3419e-01     1.2257e-01     9.9696e-02     9.1621e-02     1.3972e-02
;;  2013-07-12/16:42:29.809  2013-07-12/16:43:28.516     9.9719e-03     1.0108e+00     1.3597e-01     7.6729e-02     1.6779e-01     1.3349e-02
;;  2013-09-02/01:55:13.480  2013-09-02/01:56:49.119     2.5596e-02     8.6862e-01     1.4518e-01     1.0091e-01     1.2842e-01     7.9794e-03
;;  2013-10-26/21:18:46.200  2013-10-26/21:26:02.099     7.2396e-03     6.3709e-01     4.0297e-02     2.4072e-02     6.4150e-02     1.8651e-03
;;  2014-02-13/08:53:39.980  2014-02-13/08:55:28.934     5.4092e-03     4.9670e-01     4.0605e-02     1.9986e-02     5.8707e-02     3.4180e-03
;;  2014-02-15/12:46:04.039  2014-02-15/12:46:36.901     1.6265e-02     5.2104e-01     1.0825e-01     9.0137e-02     8.6553e-02     9.2266e-03
;;  2014-02-19/03:09:14.809  2014-02-19/03:09:38.861     1.3449e-02     3.6181e-01     5.6484e-02     3.8880e-02     6.1117e-02     7.6396e-03
;;  2014-04-19/17:46:30.859  2014-04-19/17:48:25.604     1.3298e-02     9.2253e-01     1.1568e-01     6.2337e-02     1.5872e-01     9.0003e-03
;;  2014-05-07/21:17:03.170  2014-05-07/21:19:38.779     6.3836e-03     6.0430e-01     8.0026e-02     4.5881e-02     9.0350e-02     4.3982e-03
;;  2014-05-29/08:25:13.950  2014-05-29/08:26:40.940     1.7002e-02     6.0286e-01     9.2120e-02     6.9687e-02     8.0824e-02     5.2724e-03
;;  2014-07-14/13:37:34.940  2014-07-14/13:38:08.971     1.1884e-02     2.1702e-01     6.1822e-02     5.1517e-02     4.2317e-02     4.4360e-03
;;  2015-05-06/00:55:30.509  2015-05-06/00:55:49.854     3.4420e-02     8.0632e-01     1.3624e-01     9.0889e-02     1.6751e-01     2.3230e-02
;;  2015-06-24/13:06:37.990  2015-06-24/13:07:14.601     3.1684e-02     4.7169e-01     1.3412e-01     1.2365e-01     7.1681e-02     7.2408e-03
;;  2015-08-15/07:43:17.430  2015-08-15/07:43:40.250     6.0878e-02     1.3515e+00     2.5575e-01     1.9557e-01     2.1839e-01     2.7962e-02
;;  2016-03-11/04:24:15.900  2016-03-11/04:29:29.400     1.0918e-02     1.0767e+00     1.5485e-01     1.2800e-01     1.0790e-01     3.6988e-03
;;  2016-03-14/16:16:06.680  2016-03-14/16:16:31.880     2.8853e-02     3.3030e-01     8.8278e-02     8.1923e-02     4.3261e-02     5.2852e-03
;;----------------------------------------------------------------------------------------------------------------------------------------------


;;----------------------------------------------------------------------------------------------------------------------------------------------
;;  ∂B Stats
;;
;;            ∂B  :  peak-to-peak amplitude of whistler precursor [nT]
;;           Min  :  Minimum of all values during precursor interval
;;           Max  :  Maximum " "
;;           Avg  :  Average/Mean " "
;;           Med  :  Median " "
;;           Std  :  Standard deviation " "
;;           SoM  :  Standard deviation of the mean " "
;;
;;    Start Time  :  Time stamp [UTC] at beginning of precursor interval
;;      End Time  :  Time stamp [UTC] at end of precursor interval
;;
;;----------------------------------------------------------------------------------------------------------------------------------------------
;;       Start Time                 End Time                Min            Max            Avg            Med            Std            SoM
;;==============================================================================================================================================
;;  1995-04-17/23:32:57.740  1995-04-17/23:33:07.610     4.5264e-01     1.8430e+00     1.1353e+00     1.1736e+00     3.9016e-01     7.6516e-02
;;  1995-07-22/05:34:15.740  1995-07-22/05:35:45.049     4.8322e-02     3.0045e+00     3.1995e-01     2.0099e-01     4.0324e-01     2.5975e-02
;;  1995-08-22/12:56:39.240  1995-08-22/12:56:48.970     2.1483e-01     3.0490e+00     9.3261e-01     6.1847e-01     7.6152e-01     1.0663e-01
;;  1995-08-24/22:10:53.360  1995-08-24/22:11:04.379     1.9001e-01     2.6864e+00     7.7296e-01     6.3998e-01     5.5985e-01     7.2887e-02
;;  1995-10-22/21:20:09.761  1995-10-22/21:20:15.694     1.9966e-01     2.8636e+00     7.0352e-01     4.7514e-01     5.4660e-01     8.9860e-02
;;  1995-12-24/05:57:33.368  1995-12-24/05:57:35.006     3.5846e-01     6.5148e+00     2.3926e+00     2.3205e+00     1.4355e+00     2.0102e-01
;;  1996-02-06/19:14:13.830  1996-02-06/19:14:25.350     8.5092e-02     1.5912e+00     4.6286e-01     3.1657e-01     3.8727e-01     7.0705e-02
;;  1996-04-03/09:46:57.259  1996-04-03/09:47:17.037     5.6425e-02     2.6994e+00     2.5969e-01     1.7733e-01     3.2098e-01     3.1176e-02
;;  1996-04-08/02:41:03.620  1996-04-08/02:41:09.639     1.8638e-01     2.9040e+00     1.1033e+00     6.3544e-01     9.3233e-01     1.6481e-01
;;  1997-03-15/22:29:44.490  1997-03-15/22:30:32.279     5.2843e-02     1.7147e+00     3.7795e-01     2.6458e-01     3.1392e-01     2.7639e-02
;;  1997-04-10/12:57:53.649  1997-04-10/12:58:34.480     7.3165e-02     2.3386e+00     5.4551e-01     4.2465e-01     4.2141e-01     4.0180e-02
;;  1997-10-24/11:17:03.750  1997-10-24/11:18:09.830     1.7934e-01     1.4863e+01     1.3818e+00     8.5970e-01     1.6149e+00     8.5350e-02
;;  1997-11-01/06:14:27.659  1997-11-01/06:14:45.110     8.7246e-02     1.7150e+00     4.5198e-01     3.7692e-01     3.2690e-01     3.3717e-02
;;  1997-12-10/04:33:03.539  1997-12-10/04:33:14.666     2.9591e-01     7.6782e+00     1.8650e+00     1.1625e+00     2.0749e+00     3.8530e-01
;;  1997-12-30/01:13:20.450  1997-12-30/01:13:43.639     1.4437e-01     3.2443e+00     5.5124e-01     3.0056e-01     5.8090e-01     7.3774e-02
;;  1998-01-06/13:28:11.509  1998-01-06/13:29:00.182     7.4534e-02     5.6457e+00     9.5600e-01     6.0033e-01     1.0368e+00     9.0585e-02
;;  1998-02-18/07:46:50.370  1998-02-18/07:48:43.870     1.2672e-01     1.7060e+01     1.5814e+00     8.5812e-01     2.0243e+00     1.1553e-01
;;  1998-05-29/15:11:58.159  1998-05-29/15:12:04.299     6.1251e-01     4.2275e+00     1.6871e+00     1.4502e+00     1.0082e+00     2.6030e-01
;;  1998-08-06/07:14:35.190  1998-08-06/07:16:07.495     1.0676e-01     5.5036e+00     6.9051e-01     5.0437e-01     6.6580e-01     4.2109e-02
;;  1998-08-19/18:40:34.169  1998-08-19/18:40:41.519     6.8410e-01     4.7778e+00     1.7374e+00     1.3929e+00     1.0287e+00     2.3599e-01
;;  1998-11-08/04:40:53.240  1998-11-08/04:41:17.230     4.9981e-01     8.6704e+00     2.0733e+00     1.6923e+00     1.5135e+00     1.8918e-01
;;  1998-12-28/18:19:57.519  1998-12-28/18:20:16.065     8.0520e-02     2.7538e+00     7.1270e-01     6.5125e-01     5.0384e-01     7.1977e-02
;;  1999-01-13/10:47:36.970  1999-01-13/10:47:44.669     5.1898e-01     1.1347e+01     3.8057e+00     2.5153e+00     3.4663e+00     7.7508e-01
;;  1999-02-17/07:11:31.720  1999-02-17/07:12:13.843     8.9489e-02     2.6760e+00     5.5968e-01     4.3999e-01     4.2070e-01     3.9576e-02
;;  1999-04-16/11:13:23.500  1999-04-16/11:14:12.000     5.1755e-01     1.3528e+01     3.2878e+00     2.9141e+00     2.1923e+00     1.9154e-01
;;  1999-06-26/19:30:24.860  1999-06-26/19:30:55.759     6.4942e-01     1.0837e+01     3.1212e+00     2.1952e+00     2.3762e+00     2.6082e-01
;;  1999-08-04/01:44:01.429  1999-08-04/01:44:38.368     2.1645e-01     5.2205e+00     1.6419e+00     1.1662e+00     1.1433e+00     1.1491e-01
;;  1999-08-23/12:09:18.200  1999-08-23/12:11:14.590     4.3572e-02     3.5385e+00     5.5248e-01     3.7413e-01     5.8789e-01     3.3124e-02
;;  1999-09-22/12:09:24.743  1999-09-22/12:09:25.473     1.0052e+00     7.9307e+00     3.6742e+00     3.4532e+00     2.2138e+00     4.6162e-01
;;  1999-10-21/02:19:01.000  1999-10-21/02:20:51.235     2.6199e-01     1.1064e+01     1.9506e+00     1.6798e+00     1.2883e+00     7.4502e-02
;;  1999-11-05/20:01:36.899  1999-11-05/20:03:09.659     6.2247e-02     5.4989e+00     1.1625e+00     7.5285e-01     1.1152e+00     7.0388e-02
;;  1999-11-13/12:47:31.509  1999-11-13/12:48:57.250     6.9792e-02     3.2187e+00     3.9199e-01     2.5528e-01     4.2537e-01     2.7927e-02
;;  2000-02-05/15:25:06.629  2000-02-05/15:26:29.031     4.1697e-02     2.7125e+00     4.7340e-01     2.8604e-01     5.0807e-01     3.4023e-02
;;  2000-02-14/07:12:32.429  2000-02-14/07:12:59.740     4.0203e-01     8.8200e+00     1.8271e+00     1.3964e+00     1.4957e+00     1.7506e-01
;;  2000-06-23/12:57:16.379  2000-06-23/12:57:59.327     1.8513e-01     7.2573e+00     1.5769e+00     1.1468e+00     1.2704e+00     1.1795e-01
;;  2000-07-13/09:43:38.389  2000-07-13/09:43:51.580     4.6023e-01     8.2965e+00     2.4572e+00     1.6924e+00     2.0219e+00     3.4177e-01
;;  2000-07-26/18:59:52.940  2000-07-26/19:00:14.860     9.0587e-02     2.4252e+00     4.5909e-01     3.1011e-01     4.0547e-01     5.3241e-02
;;  2000-07-28/06:38:15.860  2000-07-28/06:38:45.817     3.1544e-01     1.3481e+01     2.1952e+00     1.7540e+00     1.8661e+00     2.0863e-01
;;  2000-08-10/05:12:21.080  2000-08-10/05:13:21.370     9.5202e-02     2.0465e+00     5.6144e-01     4.9022e-01     3.5784e-01     2.8028e-02
;;  2000-08-11/18:49:30.659  2000-08-11/18:49:34.379     6.7672e-01     5.7584e+00     2.5361e+00     1.9991e+00     1.5683e+00     2.8634e-01
;;  2000-10-28/09:30:28.309  2000-10-28/09:30:41.879     9.3491e-01     1.3419e+01     3.6161e+00     2.8731e+00     2.6529e+00     4.4215e-01
;;  2000-10-31/17:08:33.149  2000-10-31/17:09:59.284     6.9707e-02     7.2598e+00     6.6022e-01     3.0274e-01     9.3225e-01     6.1073e-02
;;  2000-11-06/09:29:09.789  2000-11-06/09:30:20.669     3.3776e-01     9.8511e+00     2.9135e+00     2.1367e+00     2.2622e+00     1.6368e-01
;;  2000-11-26/11:43:20.870  2000-11-26/11:43:26.710     6.1198e-01     6.5098e+00     1.8491e+00     1.4357e+00     1.3424e+00     2.6326e-01
;;  2000-11-28/05:25:33.700  2000-11-28/05:27:41.985     6.3244e-02     2.0348e+00     4.0451e-01     2.9135e-01     3.0532e-01     1.6390e-02
;;  2001-01-17/04:07:10.799  2001-01-17/04:07:53.059     3.4702e-02     6.0003e-01     2.3199e-01     2.1457e-01     1.1129e-01     1.0423e-02
;;  2001-03-03/11:28:22.080  2001-03-03/11:29:20.899     6.8142e-02     5.3500e+00     6.9651e-01     4.0546e-01     9.2916e-01     7.3687e-02
;;  2001-03-22/13:58:30.230  2001-03-22/13:59:06.240     5.4582e-02     4.2114e+00     5.6498e-01     2.7274e-01     7.4750e-01     7.5897e-02
;;  2001-03-27/18:07:15.600  2001-03-27/18:07:48.210     1.4443e-01     5.1375e+00     7.0066e-01     5.1630e-01     7.5146e-01     8.0106e-02
;;  2001-04-21/15:29:02.879  2001-04-21/15:29:14.123     8.9747e-02     5.3535e-01     2.0403e-01     1.5939e-01     1.1140e-01     2.0686e-02
;;  2001-05-06/09:05:27.789  2001-05-06/09:06:08.332     7.8084e-02     2.2498e+00     4.0967e-01     2.7047e-01     3.6382e-01     3.4847e-02
;;  2001-05-12/10:01:41.690  2001-05-12/10:03:14.317     7.4149e-02     1.7444e+00     3.9038e-01     3.4839e-01     2.2531e-01     1.4250e-02
;;  2001-09-13/02:30:10.129  2001-09-13/02:31:26.029     9.8214e-02     2.4613e+00     6.1889e-01     5.1913e-01     4.0985e-01     2.8908e-02
;;  2001-10-28/03:13:23.950  2001-10-28/03:13:48.500     2.2957e-01     6.2826e+00     1.5503e+00     1.2837e+00     1.0778e+00     1.3369e-01
;;  2001-11-30/18:15:10.889  2001-11-30/18:15:45.440     4.5778e-02     1.4963e+00     2.7257e-01     2.1697e-01     2.2554e-01     2.3387e-02
;;  2001-12-21/14:09:42.850  2001-12-21/14:10:17.090     1.1934e-01     2.8353e+00     7.7179e-01     7.0697e-01     4.8353e-01     5.0411e-02
;;  2001-12-30/20:04:29.870  2001-12-30/20:05:05.830     1.9108e-01     7.2681e+00     1.2341e+00     8.6914e-01     1.2206e+00     1.2458e-01
;;  2002-01-17/05:26:51.590  2002-01-17/05:26:56.879     2.6552e-01     2.4573e+00     1.2525e+00     1.0978e+00     6.2647e-01     1.0589e-01
;;  2002-01-31/21:37:31.419  2002-01-31/21:38:10.404     1.6245e-01     2.7040e+00     5.7258e-01     4.2414e-01     4.5242e-01     6.2739e-02
;;  2002-03-23/11:23:24.620  2002-03-23/11:24:09.210     6.0411e-02     3.5948e+00     5.3212e-01     3.3200e-01     5.5916e-01     5.1044e-02
;;  2002-03-29/22:15:09.809  2002-03-29/22:15:13.250     2.1826e-01     2.8109e+00     9.9789e-01     8.2370e-01     7.3153e-01     1.3356e-01
;;  2002-05-21/21:13:11.610  2002-05-21/21:14:15.840     1.0912e-01     2.8303e+00     6.5834e-01     4.4039e-01     5.9971e-01     4.5595e-02
;;  2002-06-29/21:09:57.429  2002-06-29/21:10:26.399     1.5755e-01     3.3505e+00     9.6607e-01     7.8866e-01     5.9307e-01     6.7152e-02
;;  2002-08-01/23:08:31.379  2002-08-01/23:09:07.282     1.9834e-01     6.3746e+00     8.1170e-01     5.6401e-01     8.3310e-01     8.5028e-02
;;  2002-09-30/07:53:38.919  2002-09-30/07:54:24.149     2.2913e-01     6.3515e+00     1.1186e+00     9.2076e-01     7.5234e-01     6.8114e-02
;;  2002-11-09/18:27:30.419  2002-11-09/18:27:49.240     7.7654e-02     2.3260e+00     5.0833e-01     3.4369e-01     4.9025e-01     6.9332e-02
;;  2003-05-29/18:30:49.730  2003-05-29/18:31:07.827     1.3869e+00     1.1329e+01     4.3993e+00     4.0985e+00     2.0818e+00     3.0048e-01
;;  2003-06-18/04:40:53.679  2003-06-18/04:42:06.159     2.0959e-01     6.6810e+00     1.3595e+00     1.0725e+00     1.0579e+00     7.5564e-02
;;  2004-04-12/18:28:23.210  2004-04-12/18:29:46.279     1.4722e-01     3.8138e+00     7.0407e-01     5.2683e-01     5.7456e-01     3.8390e-02
;;  2005-05-06/12:03:02.500  2005-05-06/12:08:38.930     3.2244e-02     3.1504e+00     2.6121e-01     1.8206e-01     2.8986e-01     9.5931e-03
;;  2005-05-07/18:26:09.069  2005-05-07/18:26:16.081     2.4295e-01     1.4603e+00     5.7858e-01     4.7405e-01     3.0921e-01     7.2881e-02
;;  2005-06-16/08:07:07.720  2005-06-16/08:09:10.069     6.9046e-02     8.8148e+00     7.6664e-01     4.3531e-01     9.6317e-01     5.2940e-02
;;  2005-07-10/02:41:17.430  2005-07-10/02:42:30.726     8.0732e-02     3.5429e+00     6.3244e-01     4.0923e-01     5.6366e-01     4.0057e-02
;;  2005-08-24/05:34:39.140  2005-08-24/05:35:24.414     1.1515e-01     4.3134e+00     8.5546e-01     5.5487e-01     8.5260e-01     7.7190e-02
;;  2005-09-02/13:48:38.779  2005-09-02/13:50:16.069     1.1145e-01     5.2551e+00     6.8320e-01     4.9804e-01     6.8760e-01     4.2399e-02
;;  2006-08-19/09:33:17.500  2006-08-19/09:38:48.400     5.2112e-02     5.1136e+00     6.9917e-01     4.2454e-01     7.6705e-01     2.5597e-02
;;  2007-08-22/04:31:24.700  2007-08-22/04:34:03.000     3.4452e-02     4.8013e-01     1.1475e-01     1.0291e-01     5.9611e-02     2.8882e-03
;;  2007-12-17/01:52:53.579  2007-12-17/01:53:18.549     1.4931e-01     3.7206e+00     5.0254e-01     3.4969e-01     5.8155e-01     7.1048e-02
;;  2008-05-28/01:14:59.750  2008-05-28/01:17:38.161     3.4672e-02     2.4362e+00     2.5753e-01     1.8502e-01     2.3428e-01     1.1324e-02
;;  2008-06-24/18:52:21.700  2008-06-24/19:10:41.963     2.6203e-02     3.8738e+00     1.4237e-01     1.1037e-01     1.6811e-01     3.0791e-03
;;  2009-02-03/19:21:01.865  2009-02-03/19:21:03.157     1.5926e-01     3.2276e+00     8.7492e-01     6.8905e-01     7.5447e-01     1.5401e-01
;;  2009-06-24/09:52:07.650  2009-06-24/09:52:20.400     1.2047e-01     1.5306e+00     4.2170e-01     3.2398e-01     3.1085e-01     5.3310e-02
;;  2009-06-27/11:03:13.559  2009-06-27/11:04:18.898     5.1373e-02     1.1645e+00     2.2516e-01     1.8323e-01     1.5935e-01     1.2011e-02
;;  2009-10-21/23:13:55.190  2009-10-21/23:15:09.880     3.7860e-02     1.5277e+00     2.0705e-01     1.5498e-01     1.9188e-01     1.3501e-02
;;  2010-04-11/12:19:16.900  2010-04-11/12:20:56.220     5.3054e-02     4.7481e+00     5.4328e-01     3.7351e-01     5.9009e-01     3.5978e-02
;;  2011-02-04/01:50:37.319  2011-02-04/01:50:55.670     7.2581e-02     1.7693e+00     4.4930e-01     2.3810e-01     4.5765e-01     6.5379e-02
;;  2011-07-11/08:26:30.220  2011-07-11/08:27:25.471     1.4088e-01     3.6342e+00     7.2864e-01     5.7569e-01     5.8272e-01     4.7738e-02
;;  2011-09-16/18:54:08.200  2011-09-16/18:57:15.299     3.3400e-02     1.1877e+00     2.8213e-01     2.1350e-01     1.9369e-01     8.6104e-03
;;  2011-09-25/10:43:56.410  2011-09-25/10:46:32.085     5.4834e-02     6.4479e+00     3.3464e-01     1.9639e-01     5.1491e-01     2.5065e-02
;;  2012-01-21/04:00:32.019  2012-01-21/04:02:01.809     3.9021e-02     1.3442e+00     2.0411e-01     1.4040e-01     2.1279e-01     1.3651e-02
;;  2012-01-30/15:43:03.640  2012-01-30/15:43:13.309     8.3948e-02     6.0981e-01     3.1439e-01     2.9747e-01     1.1264e-01     2.2528e-02
;;  2012-06-16/19:34:25.569  2012-06-16/19:34:39.369     4.8867e-01     4.4512e+00     1.3805e+00     1.0268e+00     9.3120e-01     1.5520e-01
;;  2012-10-08/04:11:45.970  2012-10-08/04:12:14.022     1.9989e-01     3.4292e+00     8.5011e-01     5.6856e-01     6.7668e-01     7.8136e-02
;;  2012-11-12/22:12:34.461  2012-11-12/22:12:41.579     2.7426e-01     4.0318e+00     1.3679e+00     8.4043e-01     1.1180e+00     2.6351e-01
;;  2012-11-26/04:32:36.150  2012-11-26/04:32:50.960     1.9049e-01     2.3859e+00     5.7551e-01     4.2617e-01     4.4110e-01     7.0632e-02
;;  2013-02-13/00:46:46.049  2013-02-13/00:47:45.742     7.4815e-02     3.1780e+00     4.9328e-01     3.8495e-01     3.9661e-01     3.1257e-02
;;  2013-04-30/08:52:30.789  2013-04-30/08:52:46.417     1.1370e-01     1.1898e+00     3.6138e-01     2.8352e-01     2.1736e-01     3.3946e-02
;;  2013-06-10/02:51:45.099  2013-06-10/02:52:01.335     7.9358e-02     1.7589e+00     4.9650e-01     4.0386e-01     3.7115e-01     5.6600e-02
;;  2013-07-12/16:42:29.809  2013-07-12/16:43:28.516     5.1256e-02     5.1955e+00     6.9889e-01     3.9439e-01     8.6245e-01     6.8613e-02
;;  2013-09-02/01:55:13.480  2013-09-02/01:56:49.119     7.6616e-02     2.6001e+00     4.3456e-01     3.0206e-01     3.8439e-01     2.3885e-02
;;  2013-10-26/21:18:46.200  2013-10-26/21:26:02.099     3.0449e-02     2.6796e+00     1.6949e-01     1.0125e-01     2.6981e-01     7.8446e-03
;;  2014-02-13/08:53:39.980  2014-02-13/08:55:28.934     3.1078e-02     2.8538e+00     2.3330e-01     1.1483e-01     3.3730e-01     1.9638e-02
;;  2014-02-15/12:46:04.039  2014-02-15/12:46:36.901     1.0884e-01     3.4867e+00     7.2435e-01     6.0318e-01     5.7919e-01     6.1742e-02
;;  2014-02-19/03:09:14.809  2014-02-19/03:09:38.861     1.1433e-01     3.0758e+00     4.8018e-01     3.3053e-01     5.1957e-01     6.4946e-02
;;  2014-04-19/17:46:30.859  2014-04-19/17:48:25.604     7.3202e-02     5.0781e+00     6.3674e-01     3.4314e-01     8.7369e-01     4.9542e-02
;;  2014-05-07/21:17:03.170  2014-05-07/21:19:38.779     3.0361e-02     2.8741e+00     3.8061e-01     2.1821e-01     4.2971e-01     2.0918e-02
;;  2014-05-29/08:25:13.950  2014-05-29/08:26:40.940     8.0487e-02     2.8539e+00     4.3609e-01     3.2989e-01     3.8261e-01     2.4959e-02
;;  2014-07-14/13:37:34.940  2014-07-14/13:38:08.971     9.4898e-02     1.7330e+00     4.9369e-01     4.1139e-01     3.3792e-01     3.5424e-02
;;  2015-05-06/00:55:30.509  2015-05-06/00:55:49.854     1.9698e-01     4.6144e+00     7.7965e-01     5.2014e-01     9.5863e-01     1.3294e-01
;;  2015-06-24/13:06:37.990  2015-06-24/13:07:14.601     1.7438e-01     2.5960e+00     7.3816e-01     6.8054e-01     3.9450e-01     3.9851e-02
;;  2015-08-15/07:43:17.430  2015-08-15/07:43:40.250     6.5663e-01     1.4577e+01     2.7586e+00     2.1094e+00     2.3555e+00     3.0160e-01
;;  2016-03-11/04:24:15.900  2016-03-11/04:29:29.400     6.0532e-02     5.9696e+00     8.5855e-01     7.0965e-01     5.9825e-01     2.0508e-02
;;  2016-03-14/16:16:06.680  2016-03-14/16:16:31.880     1.6535e-01     1.8928e+00     5.0589e-01     4.6947e-01     2.4791e-01     3.0288e-02
;;----------------------------------------------------------------------------------------------------------------------------------------------


;;----------------------------------------------------------------------------------------
;;  Plot results
;;----------------------------------------------------------------------------------------
WINDOW,0,XSIZE=1000,YSIZE=600
;;  Define indices
ii             = good[jj[0]]
kk             = good_A[ii[0]]          ;;  index for CfA shock database params
ind            = good_A[good]

;;---------------------------------------------
;;  Look at all ratios
;;---------------------------------------------
yran           = [1e-3,2e1]
;;  Define < beta >_up
gd_beta_t_up   = beta_t_up[ind]
;;  Define plot parameters
xdat           = gd_beta_t_up
ydat           = all_stats
xran           = [1e-2,1e0]
xlog           = 1b

;;  Define Mf_up
gd_Mfast__up   = Mfast__up[ind]
;;  Define plot parameters
xdat           = gd_Mfast__up
ydat           = all_stats
xran           = [1e0,3e0]
xlog           = 0b

;;  Define M_Aup
gd_M_VA___up   = M_VA___up[ind]
;;  Define plot parameters
xdat           = gd_M_VA___up
ydat           = all_stats
xran           = [1e0,3e0]
xlog           = 0b

;;  Define Vshn
gd_vshn___up   = vshn___up[ind]
;;  Define plot parameters
xdat           = gd_vshn___up
ydat           = all_stats
xran           = [1e2,1e3]
xlog           = 1b

;;  Define Ushn
gd_ushn___up   = ushn___up[ind]
;;  Define plot parameters
xdat           = gd_ushn___up
ydat           = all_stats
xran           = [0e0,3e2]
xlog           = 0b

;;  Define theta_Bn
gd_thetbn_up   = thetbn_up[ind]
;;  Define plot parameters
xdat           = gd_thetbn_up
ydat           = all_stats
xran           = [45e0,90e0]
xlog           = 0b

;;  Define Cos(theta_Bn)
gd_thetbn_up   = COS(thetbn_up[ind]*!DPI/18d1)
;;  Define plot parameters
xdat           = gd_thetbn_up
ydat           = all_stats
xran           = [0e0,1e0]
xlog           = 0b

WSET,0
WSHOW,0
pstr           = {XRANGE:xran,YRANGE:yran,XSTYLE:1b,YSTYLE:1b,XLOG:xlog[0],YLOG:1b,NODATA:1b}
PLOT,xdat,REFORM(ydat[*,0]),_EXTRA=pstr
  OPLOT,xdat,REFORM(ydat[*,0]),COLOR=250,PSYM=4
  OPLOT,xdat,REFORM(ydat[*,1]),COLOR=200,PSYM=5
  OPLOT,xdat,REFORM(ydat[*,2]),COLOR=150,PSYM=6
  OPLOT,xdat,REFORM(ydat[*,3]),COLOR= 50,PSYM=7

;;---------------------------------------------
;;  Look at just the max ratios
;;---------------------------------------------
yran           = [1e-1,2e1]
;;  Define < beta >_up
gd_beta_t_up   = beta_t_up[ind]
;;  Define plot parameters
xdat           = gd_beta_t_up
ydat           = all_stats
xran           = [1e-2,1e0]
xlog           = 1b

;;  Define Mf_up
gd_Mfast__up   = Mfast__up[ind]
;;  Define plot parameters
xdat           = gd_Mfast__up
ydat           = all_stats
xran           = [1e0,3e0]
xlog           = 0b

;;  Define M_Aup
gd_M_VA___up   = M_VA___up[ind]
;;  Define plot parameters
xdat           = gd_M_VA___up
ydat           = all_stats
xran           = [1e0,3e0]
xlog           = 0b

;;  Define Vshn
gd_vshn___up   = vshn___up[ind]
;;  Define plot parameters
xdat           = gd_vshn___up
ydat           = all_stats
xran           = [1e2,1e3]
xlog           = 1b

;;  Define Ushn
gd_ushn___up   = ushn___up[ind]
;;  Define plot parameters
xdat           = gd_ushn___up
ydat           = all_stats
xran           = [0e0,3e2]
xlog           = 0b

;;  Define theta_Bn
gd_thetbn_up   = thetbn_up[ind]
;;  Define plot parameters
xdat           = gd_thetbn_up
ydat           = all_stats
xran           = [45e0,90e0]
xlog           = 0b


WSET,0
WSHOW,0
pstr           = {XRANGE:xran,YRANGE:yran,XSTYLE:1b,YSTYLE:1b,XLOG:xlog[0],YLOG:1b,NODATA:1b}
PLOT,xdat,REFORM(ydat[*,0]),_EXTRA=pstr
  OPLOT,xdat,REFORM(ydat[*,1]),COLOR=200,PSYM=5






mform          = '(a75,6e12.4)'
PRINT,';;  '+all_tdate[0]+'::  (Precursor Amp.)/(Ramp Amp.) [Min,Max,Avg,Med,Std,SoM]:  ',REFORM(all_stats[0,*]),FORMAT=mform[0]



;FOR mm=0L, gd[0] - 1L DO BEGIN                                        $
;  jj                 = mm[0]                                        & $
;  @/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/calc_ip_shocks_ramp_precursor_amps_batch.pro  & $
;
;jj             = 0L
;@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/calc_ip_shocks_ramp_precursor_amps_batch.pro
