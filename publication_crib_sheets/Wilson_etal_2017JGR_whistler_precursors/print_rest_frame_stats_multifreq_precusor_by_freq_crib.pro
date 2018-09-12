;;  print_rest_frame_stats_multifreq_precusor_by_freq_crib.pro

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

good_lowf      = WHERE(f_lower LE 1d-1,gd_lowf)
good_midf      = WHERE(f_lower GT 1d-1 AND f_lower LE 5d-1,gd_midf)
good_upp0      = WHERE(f_lower GT 5d-1,gd_upp0)
good_upp1      = WHERE(f_lower GT 1d0, gd_upp1)
good_upp2      = WHERE(f_lower GT 1d-1,gd_upp2)
PRINT,';;  ',gd_lowf[0],gd_midf[0],gd_upp0[0],gd_upp1[0],gd_upp2[0]
;;           275         894         827         371        1721

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
gdlowf_str     = (num2int_str(gd_lowf[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdmidf_str     = (num2int_str(gd_midf[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdupp0_str     = (num2int_str(gd_upp0[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdupp1_str     = (num2int_str(gd_upp1[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdupp2_str     = (num2int_str(gd_upp2[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdmva_str      = (num2int_str(N_ELEMENTS(theta_kb),NUM_CHAR=6,/ZERO_PAD))[0]
allmva_str     = (num2int_str(all_mva_cnt[0],NUM_CHAR=8,/ZERO_PAD))[0]
suffixt        = ' Total Good MVA Intervals for '+scpref0[0]+' IP Shocks'
sout           = ';;  '+cnt_str[0]+' of '+gdmva_str[0]+suffixt[0]
sout1a         = ';;  '+gdlowf_str[0]+' of which have f ≤ 100 mHz'
sout1b         = ';;  '+gdmidf_str[0]+' of which have 100 mHz < f ≤ 500 mHz'
sout1c         = ';;  '+gdupp0_str[0]+' of which have 500 mHz < f'
sout1d         = ';;  '+gdupp1_str[0]+' of which have 1000 mHz < f'
sout1e         = ';;  '+gdupp2_str[0]+' of which have 100 mHz < f'
sout2          = ';;  From a total of '+allmva_str[0]+' Total MVA Intervals Analyzed'
PRINT,''          & $
PRINT,sout[0]     & $
PRINT,sout1a[0]   & $
PRINT,sout1b[0]   & $
PRINT,sout1c[0]   & $
PRINT,sout1d[0]   & $
PRINT,sout1e[0]   & $
PRINT,sout2[0]    & $
PRINT,''

;;  001996 of 002189 Total Good MVA Intervals for Wind IP Shocks
;;  000275 of which have f ≤ 100 mHz
;;  000894 of which have 100 mHz < f ≤ 500 mHz
;;  000827 of which have 500 mHz < f
;;  000371 of which have 1000 mHz < f
;;  001721 of which have 100 mHz < f
;;  From a total of 08790035 Total MVA Intervals Analyzed

;;----------------------------------------------------------------------------------------
;;  Define wave normal angles
;;----------------------------------------------------------------------------------------
;;  Define unit vectors
kvecsu         = unit_vec(kvecs)
;;  Force angles:  0 ≤ ø ≤ 90
thetakb_lowf   = theta_kb[good_lowf] < (18d1 - theta_kb[good_lowf])
thetakb_midf   = theta_kb[good_midf] < (18d1 - theta_kb[good_midf])
thetakb_upp0   = theta_kb[good_upp0] < (18d1 - theta_kb[good_upp0])
thetakb_upp1   = theta_kb[good_upp1] < (18d1 - theta_kb[good_upp1])
thetakb_upp2   = theta_kb[good_upp2] < (18d1 - theta_kb[good_upp2])

;;  theta_kb did not work for some reason --> calculate dot product here
bvecuup        = unit_vec(bvec_up)
k_dot_b        = my_dot_prod(kvecsu,bvecuup,/NOM)
theta2kb       = ACOS(k_dot_b)*18d1/!DPI
thetakb2lowf   = theta2kb[good_lowf] < (18d1 - theta2kb[good_lowf])
thetakb2midf   = theta2kb[good_midf] < (18d1 - theta2kb[good_midf])
thetakb2upp0   = theta2kb[good_upp0] < (18d1 - theta2kb[good_upp0])
thetakb2upp1   = theta2kb[good_upp1] < (18d1 - theta2kb[good_upp1])
thetakb2upp2   = theta2kb[good_upp2] < (18d1 - theta2kb[good_upp2])
;;  theta_kn did not work for some reason --> calculate dot product here
nvecuup        = unit_vec(nvec_up)
k_dot_n        = my_dot_prod(kvecsu,nvecuup,/NOM)
theta_kn       = ACOS(k_dot_n)*18d1/!DPI
;;  Define theta_kn by frequency
thetakn_lowf   = theta_kn[good_lowf] < (18d1 - theta_kn[good_lowf])
thetakn_midf   = theta_kn[good_midf] < (18d1 - theta_kn[good_midf])
thetakn_upp0   = theta_kn[good_upp0] < (18d1 - theta_kn[good_upp0])
thetakn_upp1   = theta_kn[good_upp1] < (18d1 - theta_kn[good_upp1])
thetakn_upp2   = theta_kn[good_upp2] < (18d1 - theta_kn[good_upp2])

;;----------------------------------------------------------------------------------------
;;  Define shock parameters
;;----------------------------------------------------------------------------------------
badcfaind      = WHERE(cfapreind LT 0,bdcfaind,COMPLEMENT=goodcfaind,NCOMPLEMENT=gdcfaind)
;;  Define theta_Bn [deg]
all_thbns      = thetbn_up[cfapreind]
;;  Define <Vsw>_up [km/s]
all_vi_up      = vi_gse_up[cfapreind,*]
all_vm_up      = mag__vec(all_vi_up,/NAN)
Vvecuup        = unit_vec(all_vi_up)
;;  Define <Ni>_up [cm^(-3)]
all_ni_up      = ni_avg_up[cfapreind]
;;  Define <|Bo|>_up [nT]
all_bm_up      = mag__vec(bvec_up,/NAN)
;;  Define <Wi>_up [km/s]
all_wi_up      = wi_rms_up[cfapreind]

IF (bdcfaind[0] GT 0) THEN all_thbns[badcfaind] = d
IF (bdcfaind[0] GT 0) THEN Vvecuup[badcfaind,*] = d
IF (bdcfaind[0] GT 0) THEN all_vm_up[badcfaind] = d
IF (bdcfaind[0] GT 0) THEN all_wi_up[badcfaind] = d
;;  Define theta_kV [deg]
k_dot_V        = my_dot_prod(kvecsu,Vvecuup,/NOM)
theta_kV       = ACOS(k_dot_V)*18d1/!DPI
;;  Define theta_Bn by frequency
thetaBn_lowf   = all_thbns[good_lowf] < (18d1 - all_thbns[good_lowf])
thetaBn_midf   = all_thbns[good_midf] < (18d1 - all_thbns[good_midf])
thetaBn_upp0   = all_thbns[good_upp0] < (18d1 - all_thbns[good_upp0])
thetaBn_upp1   = all_thbns[good_upp1] < (18d1 - all_thbns[good_upp1])
thetaBn_upp2   = all_thbns[good_upp2] < (18d1 - all_thbns[good_upp2])
;;  Define theta_kV by frequency
thetakV_lowf   = theta_kV[good_lowf] < (18d1 - theta_kV[good_lowf])
thetakV_midf   = theta_kV[good_midf] < (18d1 - theta_kV[good_midf])
thetakV_upp0   = theta_kV[good_upp0] < (18d1 - theta_kV[good_upp0])
thetakV_upp1   = theta_kV[good_upp1] < (18d1 - theta_kV[good_upp1])
thetakV_upp2   = theta_kV[good_upp2] < (18d1 - theta_kV[good_upp2])

;;----------------------------------------------------------------------------------------
;;  Calculate rest frame parameters
;;----------------------------------------------------------------------------------------
;;  Define conversion factors
vfac           = 1d-9/SQRT(muo[0]*me[0]*1d6)*1d-3
wcpfac         = qq[0]*1d-9/mp[0]
wcefac         = qq[0]*1d-9/me[0]
wpefac         = SQRT(1d6*qq[0]^2/(me[0]*epo[0]))
;;  Define upstream parameters
valf_e_up      = vfac[0]*all_bm_up/SQRT(all_ni_up)        ;;  electron Alfven speed [km/s]
wcp_up         = wcpfac[0]*all_bm_up                      ;;  proton cyclotron frequency [rad/s]
wce_up         = wcefac[0]*all_bm_up                      ;;  electron cyclotron frequency [rad/s]
wlh_up         = SQRT(wcp_up*wce_up)                      ;;  lower hybrid resonance frequency [rad/s]
wpe_up         = wpefac[0]*SQRT(all_ni_up)                ;;  electron plasma frequency [rad/s]
rho_cp_up      = all_wi_up/wcp_up                         ;;  proton thermal gyroradii [km]
rho_ce_up      = rho_cp_up*SQRT(me[0]/mp[0])              ;;  electron thermal gyroradii [km]
;;  Define ratios
wlh2wce_up     = wlh_up/wce_up
wcp2wce_up     = wcp_up/wce_up
wce2wcp_up     = wce_up/wcp_up
;;  Define 2D arrays
wcp_up_2d      = wcp_up # REPLICATE(1d0,3L)
wlh_up_2d      = wlh_up # REPLICATE(1d0,3L)
wce_up_2d      = wce_up # REPLICATE(1d0,3L)
wpe_up_2d      = wpe_up # REPLICATE(1d0,3L)
rhoceup2d      = rho_ce_up # REPLICATE(1d0,3L)


;;  0 = a x^3 + b x^2 + c x + d
;;
;;  a = [|Vsw| Cos(the_kV)/V_Ae]
;;  b = Cos(the_kB) - w_sc/w_ce
;;  c = a
;;  d = -(w_sc/w_ce)
;;  --> Define coefficients
theta_kVpos    = theta_kV < (18d1 - theta_kV)
theta_kVneg    = theta_kV > (18d1 - theta_kV)
theta2kbs      = theta2kb < (18d1 - theta2kb)

;;  Define a
a_coef_pos     = all_vm_up*COS(theta_kVpos*!DPI/18d1)/valf_e_up
a_coef_neg     = all_vm_up*COS(theta_kVneg*!DPI/18d1)/valf_e_up
;;  Define b
b_coef_low     = COS(theta2kbs*!DPI/18d1) - f_lower/wce_up
b_coef_upp     = COS(theta2kbs*!DPI/18d1) - f_upper/wce_up
;;  Define c
c_coef_pos     = a_coef_pos
c_coef_neg     = a_coef_neg
;;  Define d
d_coef_low     = -1d0*f_lower/wce_up
d_coef_upp     = -1d0*f_upper/wce_up
;;  Define coefficient arrays
coef_low_pos   = [[d_coef_low],[c_coef_pos],[b_coef_low],[a_coef_pos]]
coef_upp_pos   = [[d_coef_upp],[c_coef_pos],[b_coef_upp],[a_coef_pos]]
coef_low_neg   = [[d_coef_low],[c_coef_neg],[b_coef_low],[a_coef_neg]]
coef_upp_neg   = [[d_coef_upp],[c_coef_neg],[b_coef_upp],[a_coef_neg]]
;;  Calculate rest frame wavenumbers [wpe/c]
nwhi           = N_ELEMENTS(theta2kbs)
kbar_low_pos   = DBLARR(nwhi,3L)     ;;  dummy array of (k c)/w_pe solutions to cubic equation
kbar_upp_pos   = DBLARR(nwhi,3L)
kbar_low_neg   = DBLARR(nwhi,3L)
kbar_upp_neg   = DBLARR(nwhi,3L)
dcmb3          = REPLICATE(DCOMPLEX(d),3L)
FOR j=0L, nwhi[0] - 1L DO BEGIN                                                       $
  cofs0             = REFORM(coef_low_pos[j,*])                                     & $
  cofs1             = REFORM(coef_upp_pos[j,*])                                     & $
  cofs3             = REFORM(coef_low_neg[j,*])                                     & $
  cofs4             = REFORM(coef_upp_neg[j,*])                                     & $
  test0             = (TOTAL(FINITE(cofs0)) EQ 4)                                   & $
  test1             = (TOTAL(FINITE(cofs1)) EQ 4)                                   & $
  test3             = (TOTAL(FINITE(cofs3)) EQ 4)                                   & $
  test4             = (TOTAL(FINITE(cofs4)) EQ 4)                                   & $
  IF (test0[0]) THEN rts00 = FZ_ROOTS(cofs0,/DOUBLE,/NO_POLISH) ELSE rts00 = dcmb3  & $
  IF (test1[0]) THEN rts01 = FZ_ROOTS(cofs1,/DOUBLE,/NO_POLISH) ELSE rts01 = dcmb3  & $
  IF (test3[0]) THEN rts03 = FZ_ROOTS(cofs3,/DOUBLE,/NO_POLISH) ELSE rts03 = dcmb3  & $
  IF (test4[0]) THEN rts04 = FZ_ROOTS(cofs4,/DOUBLE,/NO_POLISH) ELSE rts04 = dcmb3  & $
  kbar_low_pos[j,*] = REAL_PART(rts00)                                              & $
  kbar_upp_pos[j,*] = REAL_PART(rts01)                                              & $
  kbar_low_neg[j,*] = REAL_PART(rts03)                                              & $
  kbar_upp_neg[j,*] = REAL_PART(rts04)

;;  Determine best/correct roots
goodk_low_pos  = WHERE(kbar_low_pos GT 0,gdk_low_pos,COMPLEMENT=badk_low_pos,NCOMPLEMENT=bdk_low_pos)
goodk_upp_pos  = WHERE(kbar_upp_pos GT 0,gdk_upp_pos,COMPLEMENT=badk_upp_pos,NCOMPLEMENT=bdk_upp_pos)
goodk_low_neg  = WHERE(kbar_low_neg GT 0,gdk_low_neg,COMPLEMENT=badk_low_neg,NCOMPLEMENT=bdk_low_neg)
goodk_upp_neg  = WHERE(kbar_upp_neg GT 0,gdk_upp_neg,COMPLEMENT=badk_upp_neg,NCOMPLEMENT=bdk_upp_neg)
IF (bdk_low_pos[0] GT 0) THEN kbar_low_pos[badk_low_pos] = d
IF (bdk_upp_pos[0] GT 0) THEN kbar_upp_pos[badk_upp_pos] = d
IF (bdk_low_neg[0] GT 0) THEN kbar_low_neg[badk_low_neg] = d
IF (bdk_upp_neg[0] GT 0) THEN kbar_upp_neg[badk_upp_neg] = d
;;  Calculate rest frame wavenumbers [1/rho_ce]
krce_low_pos   = (kbar_low_pos*wpe_up_2d/ckm[0])*rhoceup2d
krce_upp_pos   = (kbar_upp_pos*wpe_up_2d/ckm[0])*rhoceup2d
krce_low_neg   = (kbar_low_neg*wpe_up_2d/ckm[0])*rhoceup2d
krce_upp_neg   = (kbar_upp_neg*wpe_up_2d/ckm[0])*rhoceup2d
;;  Calculate rest frame frequencies [wce]
;;    wbar = kbar^2 [Cos[theta]/(1 + kbar^2)]
cthkb_3d       = COS(theta2kbs*!DPI/18d1) # REPLICATE(1d0,3L)
wrest_low_pos  = kbar_low_pos^2*cthkb_3d/(1d0 + kbar_low_pos^2)
wrest_upp_pos  = kbar_upp_pos^2*cthkb_3d/(1d0 + kbar_upp_pos^2)
wrest_low_neg  = kbar_low_neg^2*cthkb_3d/(1d0 + kbar_low_neg^2)
wrest_upp_neg  = kbar_upp_neg^2*cthkb_3d/(1d0 + kbar_upp_neg^2)
;;  Re-normalize frequency to w_lh and w_cp
w_wlh_low_pos  = (wrest_low_pos*wce_up_2d)/wlh_up_2d
w_wlh_upp_pos  = (wrest_upp_pos*wce_up_2d)/wlh_up_2d
w_wlh_low_neg  = (wrest_low_neg*wce_up_2d)/wlh_up_2d
w_wlh_upp_neg  = (wrest_upp_neg*wce_up_2d)/wlh_up_2d
w_wcp_low_pos  = (wrest_low_pos*wce_up_2d)/wcp_up_2d
w_wcp_upp_pos  = (wrest_upp_pos*wce_up_2d)/wcp_up_2d
w_wcp_low_neg  = (wrest_low_neg*wce_up_2d)/wcp_up_2d
w_wcp_upp_neg  = (wrest_upp_neg*wce_up_2d)/wcp_up_2d
;;  Define parameters in physical units
;;  Define |k| [km^(-1)]
k_km_low_pos   = kbar_low_pos*wpe_up_2d/ckm[0]  ;;  (wpe/c) --> km^(-1)
k_km_upp_pos   = kbar_upp_pos*wpe_up_2d/ckm[0]
k_km_low_neg   = kbar_low_neg*wpe_up_2d/ckm[0]
k_km_upp_neg   = kbar_upp_neg*wpe_up_2d/ckm[0]
;;  Define f_rest [Hz]
f_Hz_low_pos   = wrest_low_pos*wce_up_2d/(2d0*!DPI)  ;;  wce --> Hz
f_Hz_upp_pos   = wrest_upp_pos*wce_up_2d/(2d0*!DPI)
f_Hz_low_neg   = wrest_low_neg*wce_up_2d/(2d0*!DPI)
f_Hz_upp_neg   = wrest_upp_neg*wce_up_2d/(2d0*!DPI)
;;  Define V_ph [km/s]
V_ph_low_pos   = (2d0*!DPI*f_Hz_low_pos)/k_km_low_pos
V_ph_upp_pos   = (2d0*!DPI*f_Hz_upp_pos)/k_km_upp_pos
V_ph_low_neg   = (2d0*!DPI*f_Hz_low_neg)/k_km_low_neg
V_ph_upp_neg   = (2d0*!DPI*f_Hz_upp_neg)/k_km_upp_neg
;;  Define lambda [km]
L_km_low_pos   = (2d0*!DPI)/k_km_low_pos
L_km_upp_pos   = (2d0*!DPI)/k_km_upp_pos
L_km_low_neg   = (2d0*!DPI)/k_km_low_neg
L_km_upp_neg   = (2d0*!DPI)/k_km_upp_neg

;;----------------------------------------------------------------------------------------
;;  Limit results that satisfy the following:
;;
;;    --  Re[k] > 0
;;    --  <Ω_cp>_up ≤ w ≤ <Ω_lh>_up
;;    --  RH --> w_sc ≥ w_rest
;;    --  LH --> w_sc ≤ w_rest
;;
;;----------------------------------------------------------------------------------------
rindp          = [2L,2L]                ;;  Index of positive real root of |k|
rindn          = [1L,2L]                ;;  Index of positive real root of |k|
gind0          = good_upp2
;;  Determine handedness
r_handed       = righthand[good_upp2]
good_rh        = WHERE(r_handed GT 0,gd_rh)
good_lh        = WHERE(r_handed EQ 0,gd_lh)
bad_pol        = WHERE(r_handed LT 0,bd_pl)
PRINT,';;  ',gd_rh[0],gd_lh[0],bd_pl[0]                                          & $
PRINT,';;  ',1d2*[gd_rh[0],gd_lh[0],bd_pl[0]]/(1d0*gd_upp2[0])
;;  100 mHz < f
;;          1256         465           0
;;         72.980825       27.019175       0.0000000

;;  Define indices for handedness
gind_rh        = gind0[good_rh]
gind_lh        = gind0[good_lh]
;;  Define upstream parameter tests
test0_low_pos  =  ((ABS(wrest_low_pos[*,rindp[0]]) LE wlh2wce_up) AND (ABS(wrest_low_pos[*,rindp[0]]) GE wcp2wce_up)) OR ((ABS(wrest_low_pos[*,rindp[1]]) LE wlh2wce_up) AND (ABS(wrest_low_pos[*,rindp[1]]) GE wcp2wce_up))
test0_upp_pos  =  ((ABS(wrest_upp_pos[*,rindp[0]]) LE wlh2wce_up) AND (ABS(wrest_upp_pos[*,rindp[0]]) GE wcp2wce_up)) OR ((ABS(wrest_upp_pos[*,rindp[1]]) LE wlh2wce_up) AND (ABS(wrest_upp_pos[*,rindp[1]]) GE wcp2wce_up))
test01low_neg  =  ((ABS(wrest_low_neg[*,rindn[0]]) LE wlh2wce_up) AND (ABS(wrest_low_neg[*,rindn[0]]) GE wcp2wce_up))
test01upp_neg  =  ((ABS(wrest_upp_neg[*,rindn[0]]) LE wlh2wce_up) AND (ABS(wrest_upp_neg[*,rindn[0]]) GE wcp2wce_up))
test02low_neg  =  ((ABS(wrest_low_neg[*,rindn[1]]) LE wlh2wce_up) AND (ABS(wrest_low_neg[*,rindn[1]]) GE wcp2wce_up))
test02upp_neg  =  ((ABS(wrest_upp_neg[*,rindn[1]]) LE wlh2wce_up) AND (ABS(wrest_upp_neg[*,rindn[1]]) GE wcp2wce_up))
testr_low_pos  = (((ABS(wrest_low_pos[*,rindp[0]]) LE f_upper/wce_up) OR (ABS(wrest_low_pos[*,rindp[1]]) LE f_upper/wce_up)) AND (righthand GT 0))
testr_upp_pos  = (((ABS(wrest_upp_pos[*,rindp[0]]) LE f_upper/wce_up) OR (ABS(wrest_upp_pos[*,rindp[1]]) LE f_upper/wce_up)) AND (righthand GT 0))
testr_low_neg  = (((ABS(wrest_low_neg[*,rindn[0]]) LE f_upper/wce_up) OR (ABS(wrest_low_neg[*,rindn[1]]) LE f_upper/wce_up)) AND (righthand GT 0))
testr_upp_neg  = (((ABS(wrest_upp_neg[*,rindn[0]]) LE f_upper/wce_up) OR (ABS(wrest_upp_neg[*,rindn[1]]) LE f_upper/wce_up)) AND (righthand GT 0))
testl_low_pos  = (((ABS(wrest_low_pos[*,rindp[0]]) GE f_lower/wce_up) OR (ABS(wrest_low_pos[*,rindp[1]]) GE f_lower/wce_up)) AND (righthand EQ 0))
testl_upp_pos  = (((ABS(wrest_upp_pos[*,rindp[0]]) GE f_lower/wce_up) OR (ABS(wrest_upp_pos[*,rindp[1]]) GE f_lower/wce_up)) AND (righthand EQ 0))
testl_low_neg  = (((ABS(wrest_low_neg[*,rindn[0]]) GE f_lower/wce_up) OR (ABS(wrest_low_neg[*,rindn[1]]) GE f_lower/wce_up)) AND (righthand EQ 0))
testl_upp_neg  = (((ABS(wrest_upp_neg[*,rindn[0]]) GE f_lower/wce_up) OR (ABS(wrest_upp_neg[*,rindn[1]]) GE f_lower/wce_up)) AND (righthand EQ 0))

good0_low_pos  = WHERE(test0_low_pos,gd0_low_pos,COMPLEMENT=bad0_low_pos,NCOMPLEMENT=bd0_low_pos)
good0_upp_pos  = WHERE(test0_upp_pos,gd0_upp_pos,COMPLEMENT=bad0_upp_pos,NCOMPLEMENT=bd0_upp_pos)
good01low_neg  = WHERE(test01low_neg,gd01low_neg,COMPLEMENT=bad01low_neg,NCOMPLEMENT=bd01low_neg)
good01upp_neg  = WHERE(test01upp_neg,gd01upp_neg,COMPLEMENT=bad01upp_neg,NCOMPLEMENT=bd01upp_neg)
good02low_neg  = WHERE(test02low_neg,gd02low_neg,COMPLEMENT=bad02low_neg,NCOMPLEMENT=bd02low_neg)
good02upp_neg  = WHERE(test02upp_neg,gd02upp_neg,COMPLEMENT=bad02upp_neg,NCOMPLEMENT=bd02upp_neg)
goodr_low_pos  = WHERE(testr_low_pos,gdr_low_pos,COMPLEMENT=badr_low_pos,NCOMPLEMENT=bdr_low_pos)
goodr_upp_pos  = WHERE(testr_upp_pos,gdr_upp_pos,COMPLEMENT=badr_upp_pos,NCOMPLEMENT=bdr_upp_pos)
goodr_low_neg  = WHERE(testr_low_neg,gdr_low_neg,COMPLEMENT=badr_low_neg,NCOMPLEMENT=bdr_low_neg)
goodr_upp_neg  = WHERE(testr_upp_neg,gdr_upp_neg,COMPLEMENT=badr_upp_neg,NCOMPLEMENT=bdr_upp_neg)
goodl_low_pos  = WHERE(testl_low_pos,gdl_low_pos,COMPLEMENT=badl_low_pos,NCOMPLEMENT=bdl_low_pos)
goodl_upp_pos  = WHERE(testl_upp_pos,gdl_upp_pos,COMPLEMENT=badl_upp_pos,NCOMPLEMENT=bdl_upp_pos)
goodl_low_neg  = WHERE(testl_low_neg,gdl_low_neg,COMPLEMENT=badl_low_neg,NCOMPLEMENT=bdl_low_neg)
goodl_upp_neg  = WHERE(testl_upp_neg,gdl_upp_neg,COMPLEMENT=badl_upp_neg,NCOMPLEMENT=bdl_upp_neg)
PRINT,';;  ',gd0_low_pos[0],gd0_upp_pos[0],gd01low_neg[0],gd01upp_neg[0],gd02low_neg[0],gd02upp_neg[0],gdr_low_pos[0],gdr_upp_pos[0],gdr_low_neg[0],gdr_upp_neg[0],gdl_low_pos[0],gdl_upp_pos[0],gdl_low_neg[0],gdl_upp_neg[0]
;;            30         236        1240        1243          63          63        1435        1435          80          13           0          68         552         552

good0_lowposu2 = WHERE(test0_low_pos[gind0],gd0_lowposu2,COMPLEMENT=bad0_lowposu2,NCOMPLEMENT=bd0_lowposu2)
good0_uppposu2 = WHERE(test0_upp_pos[gind0],gd0_uppposu2,COMPLEMENT=bad0_uppposu2,NCOMPLEMENT=bd0_uppposu2)
good01lownegu2 = WHERE(test01low_neg[gind0],gd01lownegu2,COMPLEMENT=bad01lownegu2,NCOMPLEMENT=bd01lownegu2)
good01uppnegu2 = WHERE(test01upp_neg[gind0],gd01uppnegu2,COMPLEMENT=bad01uppnegu2,NCOMPLEMENT=bd01uppnegu2)
good02lownegu2 = WHERE(test02low_neg[gind0],gd02lownegu2,COMPLEMENT=bad02lownegu2,NCOMPLEMENT=bd02lownegu2)
good02uppnegu2 = WHERE(test02upp_neg[gind0],gd02uppnegu2,COMPLEMENT=bad02uppnegu2,NCOMPLEMENT=bd02uppnegu2)
goodr_lowposu2 = WHERE(testr_low_pos[gind0],gdr_lowposu2,COMPLEMENT=badr_lowposu2,NCOMPLEMENT=bdr_lowposu2)
goodr_uppposu2 = WHERE(testr_upp_pos[gind0],gdr_uppposu2,COMPLEMENT=badr_uppposu2,NCOMPLEMENT=bdr_uppposu2)
goodr_lownegu2 = WHERE(testr_low_neg[gind0],gdr_lownegu2,COMPLEMENT=badr_lownegu2,NCOMPLEMENT=bdr_lownegu2)
goodr_uppnegu2 = WHERE(testr_upp_neg[gind0],gdr_uppnegu2,COMPLEMENT=badr_uppnegu2,NCOMPLEMENT=bdr_uppnegu2)
goodl_lowposu2 = WHERE(testl_low_pos[gind0],gdl_lowposu2,COMPLEMENT=badl_lowposu2,NCOMPLEMENT=bdl_lowposu2)
goodl_uppposu2 = WHERE(testl_upp_pos[gind0],gdl_uppposu2,COMPLEMENT=badl_uppposu2,NCOMPLEMENT=bdl_uppposu2)
goodl_lownegu2 = WHERE(testl_low_neg[gind0],gdl_lownegu2,COMPLEMENT=badl_lownegu2,NCOMPLEMENT=bdl_lownegu2)
goodl_uppnegu2 = WHERE(testl_upp_neg[gind0],gdl_uppnegu2,COMPLEMENT=badl_uppnegu2,NCOMPLEMENT=bdl_uppnegu2)
PRINT,';;  ',gd0_lowposu2[0],gd0_uppposu2[0],gd01lownegu2[0],gd01uppnegu2[0],gd02lownegu2[0],gd02uppnegu2[0],gdr_lowposu2[0],gdr_uppposu2[0],gdr_lownegu2[0],gdr_uppnegu2[0],gdl_lowposu2[0],gdl_uppposu2[0],gdl_lownegu2[0],gdl_uppnegu2[0]
;;            30         236        1068        1064          54          54        1256        1256          78          11           0          55         456         456

;;  Define indices for later use
IF (gd0_lowposu2[0] GT 0) THEN gind0_lowposu2 = gind0[good0_lowposu2] ELSE gind0_lowposu2 = -1L
IF (gd0_uppposu2[0] GT 0) THEN gind0_uppposu2 = gind0[good0_uppposu2] ELSE gind0_uppposu2 = -1L
IF (gd01lownegu2[0] GT 0) THEN gind01lownegu2 = gind0[good01lownegu2] ELSE gind01lownegu2 = -1L
IF (gd01uppnegu2[0] GT 0) THEN gind01uppnegu2 = gind0[good01uppnegu2] ELSE gind01uppnegu2 = -1L
IF (gd02lownegu2[0] GT 0) THEN gind02lownegu2 = gind0[good02lownegu2] ELSE gind02lownegu2 = -1L
IF (gd02uppnegu2[0] GT 0) THEN gind02uppnegu2 = gind0[good02uppnegu2] ELSE gind02uppnegu2 = -1L
IF (gdr_lowposu2[0] GT 0) THEN gindr_lowposu2 = gind0[goodr_lowposu2] ELSE gindr_lowposu2 = -1L
IF (gdr_uppposu2[0] GT 0) THEN gindr_uppposu2 = gind0[goodr_uppposu2] ELSE gindr_uppposu2 = -1L
IF (gdr_lownegu2[0] GT 0) THEN gindr_lownegu2 = gind0[goodr_lownegu2] ELSE gindr_lownegu2 = -1L
IF (gdr_uppnegu2[0] GT 0) THEN gindr_uppnegu2 = gind0[goodr_uppnegu2] ELSE gindr_uppnegu2 = -1L
IF (gdl_lowposu2[0] GT 0) THEN gindl_lowposu2 = gind0[goodl_lowposu2] ELSE gindl_lowposu2 = -1L
IF (gdl_uppposu2[0] GT 0) THEN gindl_uppposu2 = gind0[goodl_uppposu2] ELSE gindl_uppposu2 = -1L
IF (gdl_lownegu2[0] GT 0) THEN gindl_lownegu2 = gind0[goodl_lownegu2] ELSE gindl_lownegu2 = -1L
IF (gdl_uppnegu2[0] GT 0) THEN gindl_uppnegu2 = gind0[goodl_uppnegu2] ELSE gindl_uppnegu2 = -1L

;;----------------------------------------------------------------------------------------
;;  Print rest frame parameters [normalized units]
;;----------------------------------------------------------------------------------------
;;  Results satisfying:
;;    --  Re[k] > 0
;;    --  <Ω_cp>_up ≤ w ≤ <Ω_lh>_up
PRINT,';;'                                                                                                                 & $
x              = kbar_low_pos[gind0_lowposu2,rindp[0]:rindp[1]]                                                            & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz Only]:  ',statx                                                          & $
x              = kbar_upp_pos[gind0_uppposu2,rindp[0]:rindp[1]]                                                            & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz Only]:  ',statx                                                          & $
x              = kbar_low_neg[gind01lownegu2,rindn[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  kbar1low_neg [wpe/c, fsc_low > 100 mHz Only]:  ',statx                                                          & $
x              = kbar_upp_neg[gind01uppnegu2,rindn[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  kbar1upp_neg [wpe/c, fsc_low > 100 mHz Only]:  ',statx                                                          & $
x              = kbar_low_neg[gind02lownegu2,rindn[1]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  kbar2low_neg [wpe/c, fsc_low > 100 mHz Only]:  ',statx                                                          & $
x              = kbar_upp_neg[gind02uppnegu2,rindn[1]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  kbar2upp_neg [wpe/c, fsc_low > 100 mHz Only]:  ',statx                                                          & $
PRINT,';;'                                                                                                                 & $
x              = wrest_low_pos[gind0_lowposu2,rindp[0]:rindp[1]]                                                           & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest_low_pos [wce, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = wrest_upp_pos[gind0_uppposu2,rindp[0]:rindp[1]]                                                           & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest_upp_pos [wce, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = wrest_low_neg[gind01lownegu2,rindn[0]]                                                                    & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest1low_neg [wce, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = wrest_upp_neg[gind01uppnegu2,rindn[0]]                                                                    & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest1upp_neg [wce, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = wrest_low_neg[gind02lownegu2,rindn[1]]                                                                    & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest2low_neg [wce, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = wrest_upp_neg[gind02uppnegu2,rindn[1]]                                                                    & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest2upp_neg [wce, fsc_low > 100 mHz Only]:  ',statx
;;
;;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz Only]:       0.024640736     0.091572320     0.037323528     0.031776969     0.013991059    0.0025544062
;;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz Only]:       0.023701159      0.23494271     0.038670344     0.032821627     0.019871196    0.0012935047
;;  kbar1low_neg [wpe/c, fsc_low > 100 mHz Only]:       0.024385786      0.79423816      0.11272850     0.096520905     0.080355158    0.0024588279
;;  kbar1upp_neg [wpe/c, fsc_low > 100 mHz Only]:       0.025144056      0.79058325      0.11577287      0.10102929     0.078493287    0.0024063661
;;  kbar2low_neg [wpe/c, fsc_low > 100 mHz Only]:        0.12574085       5.8615993      0.44395849      0.33608579      0.76308041      0.10384209
;;  kbar2upp_neg [wpe/c, fsc_low > 100 mHz Only]:        0.12573974       5.6115930      0.43918281      0.33603803      0.72958480     0.099283916
;;
;;  wrest_low_pos [wce, fsc_low > 100 mHz Only]:     0.00055755045    0.0025611124   0.00090711610   0.00073854324   0.00046483407   8.4866702e-05
;;  wrest_upp_pos [wce, fsc_low > 100 mHz Only]:     0.00054482172    0.0054376368    0.0010980841   0.00087631526   0.00068835582   4.4808147e-05
;;  wrest1low_neg [wce, fsc_low > 100 mHz Only]:     0.00054540036     0.023258985    0.0084496610    0.0069194103    0.0062134716   0.00019012914
;;  wrest1upp_neg [wce, fsc_low > 100 mHz Only]:     0.00056781777     0.023326678    0.0089013595    0.0076319307    0.0060925703   0.00018677973
;;  wrest2low_neg [wce, fsc_low > 100 mHz Only]:     0.00083593438     0.022950754    0.0097124653    0.0093149627    0.0067699707   0.00092127632
;;  wrest2upp_neg [wce, fsc_low > 100 mHz Only]:     0.00083591989     0.022948077    0.0097075482    0.0093149063    0.0067675639   0.00092094880


PRINT,';;'                                                                                                                 & $
x              = krce_low_pos[gind0_lowposu2,rindp[0]:rindp[1]]                                                            & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  krce_upp_pos [1/rho_ce, fsc_low > 100 mHz Only]:  ',statx                                                       & $
x              = krce_upp_pos[gind0_uppposu2,rindp[0]:rindp[1]]                                                            & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  krce_upp_pos [1/rho_ce, fsc_low > 100 mHz Only]:  ',statx                                                       & $
x              = krce_low_neg[gind01lownegu2,rindn[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  krce1low_neg [1/rho_ce, fsc_low > 100 mHz Only]:  ',statx                                                       & $
x              = krce_upp_neg[gind01uppnegu2,rindn[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  krce1upp_neg [1/rho_ce, fsc_low > 100 mHz Only]:  ',statx                                                       & $
x              = krce_low_neg[gind02lownegu2,rindn[1]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  krce2low_neg [1/rho_ce, fsc_low > 100 mHz Only]:  ',statx                                                       & $
x              = krce_upp_neg[gind02uppnegu2,rindn[1]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  krce2upp_neg [1/rho_ce, fsc_low > 100 mHz Only]:  ',statx                                                       & $
PRINT,';;'                                                                                                                 & $
x              = w_wcp_low_pos[gind0_lowposu2,rindp[0]:rindp[1]]                                                           & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  w_wcp_low_pos [wcp, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = w_wcp_upp_pos[gind0_uppposu2,rindp[0]:rindp[1]]                                                           & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  w_wcp_upp_pos [wcp, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = w_wcp_low_neg[gind01lownegu2,rindn[0]]                                                                    & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  w_wcp1low_neg [wcp, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = w_wcp_upp_neg[gind01uppnegu2,rindn[0]]                                                                    & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  w_wcp1upp_neg [wcp, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = w_wcp_low_neg[gind02lownegu2,rindn[1]]                                                                    & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  w_wcp2low_neg [wcp, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = w_wcp_upp_neg[gind02uppnegu2,rindn[1]]                                                                    & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  w_wcp2upp_neg [wcp, fsc_low > 100 mHz Only]:  ',statx                                                           & $
PRINT,';;'                                                                                                                 & $
x              = w_wlh_low_pos[gind0_lowposu2,rindp[0]:rindp[1]]                                                           & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  w_wlh_low_pos [wlh, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = w_wlh_upp_pos[gind0_uppposu2,rindp[0]:rindp[1]]                                                           & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  w_wlh_upp_pos [wlh, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = w_wlh_low_neg[gind01lownegu2,rindn[0]]                                                                    & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  w_wlh1low_neg [wlh, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = w_wlh_upp_neg[gind01uppnegu2,rindn[0]]                                                                    & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  w_wlh1upp_neg [wlh, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = w_wlh_low_neg[gind02lownegu2,rindn[1]]                                                                    & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  w_wlh2low_neg [wlh, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = w_wlh_upp_neg[gind02uppnegu2,rindn[1]]                                                                    & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  w_wlh2upp_neg [wlh, fsc_low > 100 mHz Only]:  ',statx
;;
;;  krce_upp_pos [1/rho_ce, fsc_low > 100 mHz Only]:      0.0094104697     0.070652000     0.023321441     0.020683844     0.013483428    0.0024617259
;;  krce_upp_pos [1/rho_ce, fsc_low > 100 mHz Only]:      0.0031986063      0.10682652     0.021340307     0.017792296     0.014135449   0.00092013934
;;  krce1low_neg [1/rho_ce, fsc_low > 100 mHz Only]:      0.0043088399      0.45640505     0.056949786     0.043126380     0.050515207    0.0015457402
;;  krce1upp_neg [1/rho_ce, fsc_low > 100 mHz Only]:      0.0040467874      0.45614865     0.058000066     0.045149751     0.050043416    0.0015341794
;;  krce2low_neg [1/rho_ce, fsc_low > 100 mHz Only]:       0.075100214       2.6652212      0.24365634      0.20015457      0.34454633     0.046886817
;;  krce2upp_neg [1/rho_ce, fsc_low > 100 mHz Only]:       0.075098231       2.5515454      0.24147568      0.20015357      0.32948098     0.044836682
;;
;;  w_wcp_low_pos [wcp, fsc_low > 100 mHz Only]:         1.0237477       4.7025933       1.6656036       1.3560781      0.85350632      0.15582822
;;  w_wcp_upp_pos [wcp, fsc_low > 100 mHz Only]:         1.0003758       9.9843313       2.0162500       1.6090486       1.2639264     0.082274599
;;  w_wcp1low_neg [wcp, fsc_low > 100 mHz Only]:         1.0014383       42.707047       15.514868       12.705094       11.408883      0.34910614
;;  w_wcp1upp_neg [wcp, fsc_low > 100 mHz Only]:         1.0426001       42.831342       16.344255       14.013390       11.186889      0.34295610
;;  w_wcp2low_neg [wcp, fsc_low > 100 mHz Only]:         1.5349031       42.141088       17.833569       17.103694       12.430700       1.6916040
;;  w_wcp2upp_neg [wcp, fsc_low > 100 mHz Only]:         1.5348765       42.136173       17.824541       17.103590       12.426281       1.6910026
;;
;;  w_wlh_low_pos [wlh, fsc_low > 100 mHz Only]:       0.023891233      0.10974457     0.038870244     0.031646838     0.019918304    0.0036365681
;;  w_wlh_upp_pos [wlh, fsc_low > 100 mHz Only]:       0.023345802      0.23300465     0.047053290     0.037550417     0.029496289    0.0019200449
;;  w_wlh1low_neg [wlh, fsc_low > 100 mHz Only]:       0.023370597      0.99665569      0.36207095      0.29649917      0.26624945    0.0081471007
;;  w_wlh1upp_neg [wlh, fsc_low > 100 mHz Only]:       0.024331191      0.99955636      0.38142639      0.32703092      0.26106878    0.0080035771
;;  w_wlh2low_neg [wlh, fsc_low > 100 mHz Only]:       0.035820082      0.98344789      0.41618256      0.39914943      0.29009563     0.039477015
;;  w_wlh2upp_neg [wlh, fsc_low > 100 mHz Only]:       0.035819462      0.98333319      0.41597186      0.39914702      0.28999250     0.039462980

;;----------------------------------------------------------------------------------------
;;  Print rest frame parameters [physical units]
;;----------------------------------------------------------------------------------------
;;  Results satisfying:
;;    --  Re[k] > 0
;;    --  <Ω_cp>_up ≤ w ≤ <Ω_lh>_up
x              = k_km_low_pos[gind0_lowposu2,rindp[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  k_km_upp_pos [km^(-1), fsc_low > 100 mHz Only]:  ',statx                                                        & $
x              = k_km_upp_pos[gind0_uppposu2,rindp[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  k_km_upp_pos [km^(-1), fsc_low > 100 mHz Only]:  ',statx                                                        & $
x              = k_km_low_neg[gind01lownegu2,rindn[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  k_km1low_neg [km^(-1), fsc_low > 100 mHz Only]:  ',statx                                                        & $
x              = k_km_upp_neg[gind01uppnegu2,rindn[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  k_km1upp_neg [km^(-1), fsc_low > 100 mHz Only]:  ',statx                                                        & $
x              = k_km_low_neg[gind02lownegu2,rindn[1]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  k_km2low_neg [km^(-1), fsc_low > 100 mHz Only]:  ',statx                                                        & $
x              = k_km_upp_neg[gind02uppnegu2,rindn[1]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  k_km2upp_neg [km^(-1), fsc_low > 100 mHz Only]:  ',statx                                                        & $
PRINT,';;'                                                                                                                 & $
x              = L_km_low_pos[gind0_lowposu2,rindp[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  L_km_upp_pos [km, fsc_low > 100 mHz Only]:  ',statx                                                             & $
x              = L_km_upp_pos[gind0_uppposu2,rindp[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  L_km_upp_pos [km, fsc_low > 100 mHz Only]:  ',statx                                                             & $
x              = L_km_low_neg[gind01lownegu2,rindn[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  L_km1low_neg [km, fsc_low > 100 mHz Only]:  ',statx                                                             & $
x              = L_km_upp_neg[gind01uppnegu2,rindn[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  L_km1upp_neg [km, fsc_low > 100 mHz Only]:  ',statx                                                             & $
x              = L_km_low_neg[gind02lownegu2,rindn[1]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  L_km2low_neg [km, fsc_low > 100 mHz Only]:  ',statx                                                             & $
x              = L_km_upp_neg[gind02uppnegu2,rindn[1]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  L_km2upp_neg [km, fsc_low > 100 mHz Only]:  ',statx                                                             & $
PRINT,';;'                                                                                                                 & $
x              = f_Hz_low_pos[gind0_lowposu2,rindp[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  f_Hz_low_pos [Hz, fsc_low > 100 mHz Only]:  ',statx                                                             & $
x              = f_Hz_upp_pos[gind0_uppposu2,rindp[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  f_Hz_upp_pos [Hz, fsc_low > 100 mHz Only]:  ',statx                                                             & $
x              = f_Hz_low_neg[gind01lownegu2,rindn[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  f_Hz1low_neg [Hz, fsc_low > 100 mHz Only]:  ',statx                                                             & $
x              = f_Hz_upp_neg[gind01uppnegu2,rindn[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  f_Hz1upp_neg [Hz, fsc_low > 100 mHz Only]:  ',statx                                                             & $
x              = f_Hz_low_neg[gind02lownegu2,rindn[1]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  f_Hz2low_neg [Hz, fsc_low > 100 mHz Only]:  ',statx                                                             & $
x              = f_Hz_upp_neg[gind02uppnegu2,rindn[1]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  f_Hz2upp_neg [Hz, fsc_low > 100 mHz Only]:  ',statx                                                             & $
PRINT,';;'                                                                                                                 & $
x              = V_ph_low_pos[gind0_lowposu2,rindp[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  V_ph_upp_pos [km/s, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = V_ph_upp_pos[gind0_uppposu2,rindp[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  V_ph_upp_pos [km/s, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = V_ph_low_neg[gind01lownegu2,rindn[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  V_ph1low_neg [km/s, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = V_ph_upp_neg[gind01uppnegu2,rindn[0]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  V_ph1upp_neg [km/s, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = V_ph_low_neg[gind02lownegu2,rindn[1]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  V_ph2low_neg [km/s, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = V_ph_upp_neg[gind02uppnegu2,rindn[1]]                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  V_ph2upp_neg [km/s, fsc_low > 100 mHz Only]:  ',statx
;;  k_km_upp_pos [km^(-1), fsc_low > 100 mHz Only]:      0.0090243683     0.033878129     0.016694031     0.014757794    0.0065076673    0.0011881321
;;  k_km_upp_pos [km^(-1), fsc_low > 100 mHz Only]:      0.0060390350      0.11780452     0.018299138     0.014937429     0.010400377   0.00067700687
;;  k_km1low_neg [km^(-1), fsc_low > 100 mHz Only]:      0.0065616534      0.54095012     0.055166535     0.044912114     0.044057343    0.0013481328
;;  k_km1upp_neg [km^(-1), fsc_low > 100 mHz Only]:      0.0062890696      0.53846078     0.056704412     0.047629257     0.043395267    0.0013303673
;;  k_km2low_neg [km^(-1), fsc_low > 100 mHz Only]:       0.064978832       2.9391119      0.22434368      0.15430959      0.38680823     0.052637934
;;  k_km2upp_neg [km^(-1), fsc_low > 100 mHz Only]:       0.064968879       2.8137542      0.22194029      0.15430516      0.37019157     0.050376692
;;
;;  L_km_upp_pos [km, fsc_low > 100 mHz Only]:         185.46435       696.24655       423.86049       429.61828       135.10291       24.666304
;;  L_km_upp_pos [km, fsc_low > 100 mHz Only]:         53.335688       1040.4287       410.58855       421.02813       157.74118       10.268076
;;  L_km1low_neg [km, fsc_low > 100 mHz Only]:         11.615092       957.56129       173.33714       139.95844       119.65983       3.6615312
;;  L_km1upp_neg [km, fsc_low > 100 mHz Only]:         11.668789       999.06436       164.31724       131.92704       112.44492       3.4472202
;;  L_km2low_neg [km, fsc_low > 100 mHz Only]:         2.1377836       96.695880       44.081438       41.058664       20.852547       2.8376722
;;  L_km2upp_neg [km, fsc_low > 100 mHz Only]:         2.2330256       96.710693       44.091872       41.060867       20.846586       2.8368610
;;
;;  f_Hz_low_pos [Hz, fsc_low > 100 mHz Only]:       0.043380405      0.32986072      0.13367429      0.12343898     0.060853041     0.011110194
;;  f_Hz_upp_pos [Hz, fsc_low > 100 mHz Only]:       0.038451190      0.71906428      0.19579027      0.16677182      0.11332000    0.0073765034
;;  f_Hz1low_neg [Hz, fsc_low > 100 mHz Only]:       0.052552380       7.9094722       1.5674906       1.2807997       1.2246355     0.037473238
;;  f_Hz1upp_neg [Hz, fsc_low > 100 mHz Only]:       0.085716976       8.1129898       1.6796757       1.3995536       1.2250363     0.037555898
;;  f_Hz2low_neg [Hz, fsc_low > 100 mHz Only]:        0.10766490       7.7915086       1.7429676       1.1895563       1.6286284      0.22162826
;;  f_Hz2upp_neg [Hz, fsc_low > 100 mHz Only]:        0.10766304       7.7914632       1.7421495       1.1895233       1.6283030      0.22158398
;;
;;  V_ph_upp_pos [km/s, fsc_low > 100 mHz Only]:         18.469368       105.67943       52.327639       54.729833       19.515366       3.5630020
;;  V_ph_upp_pos [km/s, fsc_low > 100 mHz Only]:         8.4668770       160.17029       70.562049       70.265536       28.603156       1.8619069
;;  V_ph1low_neg [km/s, fsc_low > 100 mHz Only]:         8.2189084       588.23087       185.69435       179.78659       94.028534       2.8772264
;;  V_ph1upp_neg [km/s, fsc_low > 100 mHz Only]:         8.2188383       507.34828       196.53181       188.69997       98.578193       3.0221084
;;  V_ph2low_neg [km/s, fsc_low > 100 mHz Only]:         6.3040472       172.16645       55.767616       44.842053       39.685371       5.4004949
;;  V_ph2upp_neg [km/s, fsc_low > 100 mHz Only]:         6.5679834       172.15985       55.765948       44.840845       39.678276       5.3995295




















































;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Limit results that satisfy the following:
;;
;;    --  Re[k] > 0
;;    --  <Ω_cp>_up ≤ w ≤ <Ω_lh>_up
;;    --  RH --> w_sc ≥ w_rest
;;    --  LH --> w_sc ≤ w_rest
;;
;;----------------------------------------------------------------------------------------
;test0_low_pos  =  ((ABS(wrest_low_pos[*,rindp[0]]) LE wlh2wce_up)     OR (ABS(wrest_low_pos[*,rindp[1]]) LE wlh2wce_up))     AND ((ABS(wrest_low_pos[*,rindp[0]]) GE wcp2wce_up) OR (ABS(wrest_low_pos[*,rindp[1]]) GE wcp2wce_up))
;test0_upp_pos  =  ((ABS(wrest_upp_pos[*,rindp[0]]) LE wlh2wce_up)     OR (ABS(wrest_upp_pos[*,rindp[1]]) LE wlh2wce_up))     AND ((ABS(wrest_upp_pos[*,rindp[0]]) GE wcp2wce_up) OR (ABS(wrest_upp_pos[*,rindp[1]]) GE wcp2wce_up))
;test0_low_neg  =  ((ABS(wrest_low_neg[*,rindn[0]]) LE wlh2wce_up)     OR (ABS(wrest_low_neg[*,rindn[1]]) LE wlh2wce_up))     AND ((ABS(wrest_low_neg[*,rindn[0]]) GE wcp2wce_up) OR (ABS(wrest_low_neg[*,rindn[1]]) GE wcp2wce_up))
;test0_upp_neg  =  ((ABS(wrest_upp_neg[*,rindn[0]]) LE wlh2wce_up)     OR (ABS(wrest_upp_neg[*,rindn[1]]) LE wlh2wce_up))     AND ((ABS(wrest_upp_neg[*,rindn[0]]) GE wcp2wce_up) OR (ABS(wrest_upp_neg[*,rindn[1]]) GE wcp2wce_up))
;test0_low_neg  =  ((ABS(wrest_low_neg[*,rindn[0]]) LE wlh2wce_up) AND (ABS(wrest_low_neg[*,rindn[0]]) GE wcp2wce_up)) OR ((ABS(wrest_low_neg[*,rindn[1]]) LE wlh2wce_up) AND (ABS(wrest_low_neg[*,rindn[1]]) GE wcp2wce_up))
;test0_upp_neg  =  ((ABS(wrest_upp_neg[*,rindn[0]]) LE wlh2wce_up) AND (ABS(wrest_upp_neg[*,rindn[0]]) GE wcp2wce_up)) OR ((ABS(wrest_upp_neg[*,rindn[1]]) LE wlh2wce_up) AND (ABS(wrest_upp_neg[*,rindn[1]]) GE wcp2wce_up))
;good0_low_neg  = WHERE(test0_low_neg,gd0_low_neg,COMPLEMENT=bad0_low_neg,NCOMPLEMENT=bd0_low_neg)
;good0_upp_neg  = WHERE(test0_upp_neg,gd0_upp_neg,COMPLEMENT=bad0_upp_neg,NCOMPLEMENT=bd0_upp_neg)
;PRINT,';;  ',gd0_low_pos[0],gd0_upp_pos[0],gd0_low_neg[0],gd0_upp_neg[0],gdr_low_pos[0],gdr_upp_pos[0],gdr_low_neg[0],gdr_upp_neg[0],gdl_low_pos[0],gdl_upp_pos[0],gdl_low_neg[0],gdl_upp_neg[0]
;;;            30         236        1240        1243        1435        1435          80          13           0          68         552         552
;good0_lownegu2 = WHERE(test0_low_neg[gind0],gd0_lownegu2,COMPLEMENT=bad0_lownegu2,NCOMPLEMENT=bd0_lownegu2)
;good0_uppnegu2 = WHERE(test0_upp_neg[gind0],gd0_uppnegu2,COMPLEMENT=bad0_uppnegu2,NCOMPLEMENT=bd0_uppnegu2)
;PRINT,';;  ',gd0_lowposu2[0],gd0_uppposu2[0],gd0_lownegu2[0],gd0_uppnegu2[0],gdr_lowposu2[0],gdr_uppposu2[0],gdr_lownegu2[0],gdr_uppnegu2[0],gdl_lowposu2[0],gdl_uppposu2[0],gdl_lownegu2[0],gdl_uppnegu2[0]
;;;            30         236        1068        1064        1256        1256          78          11           0          55         456         456
;IF (gd0_lownegu2[0] GT 0) THEN gind0_lownegu2 = gind0[good0_lownegu2] ELSE gind0_lownegu2 = -1L
;IF (gd0_uppnegu2[0] GT 0) THEN gind0_uppnegu2 = gind0[good0_uppnegu2] ELSE gind0_uppnegu2 = -1L

;;  Define upstream parameter tests
test0_low_pos  =  (ABS(wrest_low_pos[*,rind[0]]) LE wlh2wce_up) AND (ABS(wrest_low_pos[*,rind[0]]) GE wce2wcp_up)
test0_upp_pos  =  (ABS(wrest_upp_pos[*,rind[0]]) LE wlh2wce_up) AND (ABS(wrest_upp_pos[*,rind[0]]) GE wce2wcp_up)
test0_low_neg  =  (ABS(wrest_low_neg[*,rind[0]]) LE wlh2wce_up) AND (ABS(wrest_low_neg[*,rind[0]]) GE wce2wcp_up)
test0_upp_neg  =  (ABS(wrest_upp_neg[*,rind[0]]) LE wlh2wce_up) AND (ABS(wrest_upp_neg[*,rind[0]]) GE wce2wcp_up)
testr_low_pos  = ((ABS(wrest_low_pos[*,rind[0]]) LE f_lower/wce_up) AND (righthand GT 0))
testr_upp_pos  = ((ABS(wrest_upp_pos[*,rind[0]]) LE f_upper/wce_up) AND (righthand GT 0))
testr_low_neg  = ((ABS(wrest_low_neg[*,rind[0]]) LE f_lower/wce_up) AND (righthand GT 0))
testr_upp_neg  = ((ABS(wrest_upp_neg[*,rind[0]]) LE f_upper/wce_up) AND (righthand GT 0))
testl_low_pos  = ((ABS(wrest_low_pos[*,rind[0]]) GE f_lower/wce_up) AND (righthand EQ 0))
testl_upp_pos  = ((ABS(wrest_upp_pos[*,rind[0]]) GE f_upper/wce_up) AND (righthand EQ 0))
testl_low_neg  = ((ABS(wrest_low_neg[*,rind[0]]) GE f_lower/wce_up) AND (righthand EQ 0))
testl_upp_neg  = ((ABS(wrest_upp_neg[*,rind[0]]) GE f_upper/wce_up) AND (righthand EQ 0))


testr_low_pos  = (((ABS(wrest_low_pos[*,rindp[0]]) LE f_lower/wce_up) OR (ABS(wrest_low_pos[*,rindp[1]]) LE f_lower/wce_up)) AND (righthand GT 0))
testr_upp_pos  = (((ABS(wrest_upp_pos[*,rindp[0]]) LE f_upper/wce_up) OR (ABS(wrest_upp_pos[*,rindp[1]]) LE f_upper/wce_up)) AND (righthand GT 0))
testr_low_neg  = (((ABS(wrest_low_neg[*,rindn[0]]) LE f_lower/wce_up) OR (ABS(wrest_low_neg[*,rindn[1]]) LE f_lower/wce_up)) AND (righthand GT 0))
testr_upp_neg  = (((ABS(wrest_upp_neg[*,rindn[0]]) LE f_upper/wce_up) OR (ABS(wrest_upp_neg[*,rindn[1]]) LE f_upper/wce_up)) AND (righthand GT 0))
testl_low_pos  = (((ABS(wrest_low_pos[*,rindp[0]]) GE f_lower/wce_up) OR (ABS(wrest_low_pos[*,rindp[1]]) GE f_lower/wce_up)) AND (righthand EQ 0))
testl_upp_pos  = (((ABS(wrest_upp_pos[*,rindp[0]]) GE f_upper/wce_up) OR (ABS(wrest_upp_pos[*,rindp[1]]) GE f_upper/wce_up)) AND (righthand EQ 0))
testl_low_neg  = (((ABS(wrest_low_neg[*,rindn[0]]) GE f_lower/wce_up) OR (ABS(wrest_low_neg[*,rindn[1]]) GE f_lower/wce_up)) AND (righthand EQ 0))
testl_upp_neg  = (((ABS(wrest_upp_neg[*,rindn[0]]) GE f_upper/wce_up) OR (ABS(wrest_upp_neg[*,rindn[1]]) GE f_upper/wce_up)) AND (righthand EQ 0))

good0lr_lowpos = WHERE(test0_low_pos AND testr_low_pos AND testl_low_pos,gd0lr_lowpos,COMPLEMENT=bad0lr_lowpos,NCOMPLEMENT=bd0lr_lowpos)
good0lr_upppos = WHERE(test0_upp_pos AND testr_upp_pos AND testl_upp_pos,gd0lr_upppos,COMPLEMENT=bad0lr_upppos,NCOMPLEMENT=bd0lr_upppos)
good0lr_lowneg = WHERE(test0_low_neg AND testr_low_neg AND testl_low_neg,gd0lr_lowneg,COMPLEMENT=bad0lr_lowneg,NCOMPLEMENT=bd0lr_lowneg)
good0lr_uppneg = WHERE(test0_upp_neg AND testr_upp_neg AND testl_upp_neg,gd0lr_uppneg,COMPLEMENT=bad0lr_uppneg,NCOMPLEMENT=bd0lr_uppneg)
good0lr_lowpos = WHERE(test0_low_pos AND testr_low_pos AND testl_low_pos,gd0lr_lowpos,COMPLEMENT=bad0lr_lowpos,NCOMPLEMENT=bd0lr_lowpos)
good0lr_upppos = WHERE(test0_upp_pos AND testr_upp_pos AND testl_upp_pos,gd0lr_upppos,COMPLEMENT=bad0lr_upppos,NCOMPLEMENT=bd0lr_upppos)
good0lr_lowneg = WHERE(test0_low_neg AND testr_low_neg AND testl_low_neg,gd0lr_lowneg,COMPLEMENT=bad0lr_lowneg,NCOMPLEMENT=bd0lr_lowneg)
good0lr_uppneg = WHERE(test0_upp_neg AND testr_upp_neg AND testl_upp_neg,gd0lr_uppneg,COMPLEMENT=bad0lr_uppneg,NCOMPLEMENT=bd0lr_uppneg)
good0lr_lowpos = WHERE(test0_low_pos AND testr_low_pos AND testl_low_pos,gd0lr_lowpos,COMPLEMENT=bad0lr_lowpos,NCOMPLEMENT=bd0lr_lowpos)
good0lr_upppos = WHERE(test0_upp_pos AND testr_upp_pos AND testl_upp_pos,gd0lr_upppos,COMPLEMENT=bad0lr_upppos,NCOMPLEMENT=bd0lr_upppos)
good0lr_lowneg = WHERE(test0_low_neg AND testr_low_neg AND testl_low_neg,gd0lr_lowneg,COMPLEMENT=bad0lr_lowneg,NCOMPLEMENT=bd0lr_lowneg)
good0lr_uppneg = WHERE(test0_upp_neg AND testr_upp_neg AND testl_upp_neg,gd0lr_uppneg,COMPLEMENT=bad0lr_uppneg,NCOMPLEMENT=bd0lr_uppneg)
PRINT,';;  ',gd0lr_lowpos[0],gd0lr_upppos[0],gd0lr_lowneg[0],gd0lr_uppneg[0],gd0lr_lowpos[0],gd0lr_upppos[0],gd0lr_lowneg[0],gd0lr_uppneg[0],gd0lr_lowpos[0],gd0lr_upppos[0],gd0lr_lowneg[0],gd0lr_uppneg[0]
;;             0           0           0           0           0           0           0           0           0           0           0           0

x              = kbar_low_pos
good           = WHERE(x gt 0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
gind           = ARRAY_INDICES(x,good)
PRINT,';;  ', minmax(gind[1,*])
;;             2           2

x              = kbar_upp_pos
good           = WHERE(x gt 0)
gind           = ARRAY_INDICES(x,good)
PRINT,';;  ', minmax(gind[1,*])
;;             2           2

x              = kbar_low_neg
good           = WHERE(x gt 0)
gind           = ARRAY_INDICES(x,good)
PRINT,';;  ', minmax(gind[1,*])
;;             1           2

x              = kbar_upp_neg
good           = WHERE(x gt 0)
gind           = ARRAY_INDICES(x,good)
PRINT,';;  ', minmax(gind[1,*])
;;             1           2

goodw_upp_pos  = WHERE(ABS(wrest_upp_pos[gind,2]) LE upp_lim[0],gdw_upp_pos)
goodw_low_neg  = WHERE(ABS(wrest_low_neg[gind,2]) LE upp_lim[0],gdw_low_neg)
goodw_upp_neg  = WHERE(ABS(wrest_upp_neg[gind,2]) LE upp_lim[0],gdw_upp_neg)
PRINT,';;  ',gdw_low_pos[0] ,gdw_upp_pos[0] ,gdw_low_neg[0] ,gdw_upp_neg[0]

;;----------------------------------------------------------------------------------------
;;  Print rest frame parameters [normalized units]
;;----------------------------------------------------------------------------------------

gind           = good_upp2
x              = kbar_low_pos[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz Only]:  ',statx                                                          & $
x              = kbar_upp_pos[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz Only]:  ',statx                                                          & $
x              = kbar_low_neg[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  kbar_low_neg [wpe/c, fsc_low > 100 mHz Only]:  ',statx                                                          & $
x              = kbar_upp_neg[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  kbar_upp_neg [wpe/c, fsc_low > 100 mHz Only]:  ',statx                                                          & $
PRINT,';;'                                                                                                                 & $
x              = wrest_low_pos[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest_low_pos [wce, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = wrest_upp_pos[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest_upp_pos [wce, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = wrest_low_neg[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest_low_neg [wce, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = wrest_upp_neg[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest_upp_neg [wce, fsc_low > 100 mHz Only]:  ',statx
;;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz Only]:     0.00046981085      0.16513781    0.0077995067    0.0055027786    0.0087123697   0.00021001285
;;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz Only]:     0.00082025861      0.23494271     0.015337059     0.011677819     0.014268749   0.00034395013
;;  kbar_low_neg [wpe/c, fsc_low > 100 mHz Only]:       0.014160574       1374.6129       20.553287       7.7661100       74.958680       1.8068891
;;  kbar_upp_neg [wpe/c, fsc_low > 100 mHz Only]:       0.014160278       1374.4387       20.532365       7.7531605       74.882818       1.8050604
;;
;;  wrest_low_pos [wce, fsc_low > 100 mHz Only]:     9.6571145e-09    0.0025611124   7.2015422e-05   1.9820132e-05   0.00015316854   3.6921483e-06
;;  wrest_upp_pos [wce, fsc_low > 100 mHz Only]:     4.0952792e-08    0.0054376368   0.00025949142   8.8090789e-05   0.00044062641   1.0621359e-05
;;  wrest_low_neg [wce, fsc_low > 100 mHz Only]:     1.8407098e-07      0.99875032      0.70771770      0.83596018      0.30115320    0.0072593386
;;  wrest_upp_neg [wce, fsc_low > 100 mHz Only]:     1.8253000e-07      0.99875032      0.70764253      0.83587848      0.30120188    0.0072605119

;;  Check dependence on handedness
r_handed       = righthand[good_upp2]
good_rh        = WHERE(r_handed GT 0,gd_rh)
good_lh        = WHERE(r_handed EQ 0,gd_lh)

gind           = good_upp2[good_rh]
x              = kbar_low_pos[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]   & $
PRINT,';;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz and RH Only]:  ',statx                                                  & $
x              = kbar_upp_pos[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]   & $
PRINT,';;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz and RH Only]:  ',statx                                                  & $
x              = kbar_low_neg[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]   & $
PRINT,';;  kbar_low_neg [wpe/c, fsc_low > 100 mHz and RH Only]:  ',statx                                                  & $
x              = kbar_upp_neg[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]   & $
PRINT,';;  kbar_upp_neg [wpe/c, fsc_low > 100 mHz and RH Only]:  ',statx                                                  & $
PRINT,';;'                                                                                                                & $
gind           = good_upp2[good_lh]                                                                                       & $
x              = kbar_low_pos[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]   & $
PRINT,';;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz and LH Only]:  ',statx                                                  & $
x              = kbar_upp_pos[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]   & $
PRINT,';;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz and LH Only]:  ',statx                                                  & $
x              = kbar_low_neg[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]   & $
PRINT,';;  kbar_low_neg [wpe/c, fsc_low > 100 mHz and LH Only]:  ',statx                                                  & $
x              = kbar_upp_neg[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]   & $
PRINT,';;  kbar_upp_neg [wpe/c, fsc_low > 100 mHz and LH Only]:  ',statx
;;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz and RH Only]:     0.00046981085     0.091572320    0.0077760621    0.0058998496    0.0076346402   0.00021542384
;;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz and RH Only]:     0.00082025861      0.12732791     0.015473307     0.012266171     0.013142694   0.00037084256
;;  kbar_low_neg [wpe/c, fsc_low > 100 mHz and RH Only]:       0.016800238       1374.6129       20.759739       7.9862849       79.395708       2.2402795
;;  kbar_upp_neg [wpe/c, fsc_low > 100 mHz and RH Only]:       0.016729747       1374.4387       20.736749       7.9801107       79.304823       2.2377150
;;
;;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz and LH Only]:     0.00063392463      0.16513781    0.0078628323    0.0045946929     0.011122709   0.00051580330
;;  kbar_upp_pos [wpe/c, fsc_low > 100 mHz and LH Only]:      0.0014088322      0.23494271     0.014969042    0.0094162743     0.016951010   0.00078608428
;;  kbar_low_neg [wpe/c, fsc_low > 100 mHz and LH Only]:       0.014160574       766.89511       19.995643       6.5471301       61.466065       2.8504205
;;  kbar_upp_neg [wpe/c, fsc_low > 100 mHz and LH Only]:       0.014160278       766.49260       19.980307       6.5202102       61.440705       2.8492445


gind           = good_upp2[good_rh]
x              = wrest_low_pos[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest_upp_pos [wce, fsc_low > 100 mHz and RH Only]:  ',statx                                                    & $
x              = wrest_upp_pos[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest_upp_pos [wce, fsc_low > 100 mHz and RH Only]:  ',statx                                                    & $
x              = wrest_low_neg[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest_low_neg [wce, fsc_low > 100 mHz and RH Only]:  ',statx                                                    & $
x              = wrest_upp_neg[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest_upp_neg [wce, fsc_low > 100 mHz and RH Only]:  ',statx                                                    & $
PRINT,';;'                                                                                                                 & $
gind           = good_upp2[good_lh]                                                                                        & $
x              = wrest_low_pos[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest_upp_pos [wce, fsc_low > 100 mHz and LH Only]:  ',statx                                                    & $
x              = wrest_upp_pos[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest_upp_pos [wce, fsc_low > 100 mHz and LH Only]:  ',statx                                                    & $
x              = wrest_low_neg[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest_low_neg [wce, fsc_low > 100 mHz and LH Only]:  ',statx                                                    & $
x              = wrest_upp_neg[gind,2]                                                                                     & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  wrest_upp_neg [wce, fsc_low > 100 mHz and LH Only]:  ',statx
;;  wrest_upp_pos [wce, fsc_low > 100 mHz and RH Only]:     4.3751373e-08    0.0025611124   7.4226632e-05   2.5057175e-05   0.00015711271   4.4331916e-06
;;  wrest_upp_pos [wce, fsc_low > 100 mHz and RH Only]:     3.0639897e-07    0.0054376368   0.00027416690   0.00011926974   0.00045993997   1.2977957e-05
;;  wrest_low_neg [wce, fsc_low > 100 mHz and RH Only]:     1.8407098e-07      0.99875032      0.74832217      0.87158873      0.27637645    0.0077984127
;;  wrest_upp_neg [wce, fsc_low > 100 mHz and RH Only]:     1.8253000e-07      0.99875032      0.74824787      0.87157687      0.27642829    0.0077998754
;;
;;  wrest_upp_pos [wce, fsc_low > 100 mHz and LH Only]:     9.6571145e-09    0.0015354940   6.6042775e-05   1.3922551e-05   0.00014195812   6.5831502e-06
;;  wrest_upp_pos [wce, fsc_low > 100 mHz and LH Only]:     4.0952792e-08    0.0028755520   0.00021985183   4.7863065e-05   0.00038127215   1.7681073e-05
;;  wrest_low_neg [wce, fsc_low > 100 mHz and LH Only]:     5.9597461e-07      0.99707481      0.59804197      0.69190524      0.33626490     0.015593911
;;  wrest_upp_neg [wce, fsc_low > 100 mHz and LH Only]:     5.9594969e-07      0.99707421      0.59796443      0.69190481      0.33631020     0.015596012

;;----------------------------------------------------------------------------------------
;;  Print rest frame parameters [physical units]
;;----------------------------------------------------------------------------------------
wce_up_2d      = wce_up # REPLICATE(1d0,3L)
wpe_up_2d      = wpe_up # REPLICATE(1d0,3L)
;;  Define |k| [km^(-1)]
k_km_low_pos   = kbar_low_pos*wpe_up_2d/ckm[0]  ;;  (wpe/c) --> km^(-1)
k_km_upp_pos   = kbar_upp_pos*wpe_up_2d/ckm[0]
k_km_low_neg   = kbar_low_neg*wpe_up_2d/ckm[0]
k_km_upp_neg   = kbar_upp_neg*wpe_up_2d/ckm[0]
;;  Define f_rest [Hz]
f_Hz_low_pos   = wrest_low_pos*wce_up_2d/(2d0*!DPI)  ;;  wce --> Hz
f_Hz_upp_pos   = wrest_upp_pos*wce_up_2d/(2d0*!DPI)
f_Hz_low_neg   = wrest_low_neg*wce_up_2d/(2d0*!DPI)
f_Hz_upp_neg   = wrest_upp_neg*wce_up_2d/(2d0*!DPI)
;;  Define V_ph [km/s]
V_ph_low_pos   = (2d0*!DPI*f_Hz_low_pos)/k_km_low_pos
V_ph_upp_pos   = (2d0*!DPI*f_Hz_upp_pos)/k_km_upp_pos
V_ph_low_neg   = (2d0*!DPI*f_Hz_low_neg)/k_km_low_neg
V_ph_upp_neg   = (2d0*!DPI*f_Hz_upp_neg)/k_km_upp_neg

;;  Print stats
gind           = good_upp2
x              = k_km_low_pos[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  k_km_upp_pos [km^(-1), fsc_low > 100 mHz Only]:  ',statx                                                        & $
x              = k_km_upp_pos[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  k_km_upp_pos [km^(-1), fsc_low > 100 mHz Only]:  ',statx                                                        & $
x              = k_km_low_neg[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  k_km_low_neg [km^(-1), fsc_low > 100 mHz Only]:  ',statx                                                        & $
x              = k_km_upp_neg[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  k_km_upp_neg [km^(-1), fsc_low > 100 mHz Only]:  ',statx                                                        & $
PRINT,';;'                                                                                                                 & $
x              = f_Hz_low_pos[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  f_Hz_upp_pos [Hz, fsc_low > 100 mHz Only]:  ',statx                                                             & $
x              = f_Hz_upp_pos[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  f_Hz_upp_pos [Hz, fsc_low > 100 mHz Only]:  ',statx                                                             & $
x              = f_Hz_low_neg[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  f_Hz_low_neg [Hz, fsc_low > 100 mHz Only]:  ',statx                                                             & $
x              = f_Hz_upp_neg[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  f_Hz_upp_neg [Hz, fsc_low > 100 mHz Only]:  ',statx                                                             & $
PRINT,';;'                                                                                                                 & $
x              = V_ph_low_pos[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  V_ph_upp_pos [km/s, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = V_ph_upp_pos[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  V_ph_upp_pos [km/s, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = V_ph_low_neg[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  V_ph_low_neg [km/s, fsc_low > 100 mHz Only]:  ',statx                                                           & $
x              = V_ph_upp_neg[gind,2]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  V_ph_upp_neg [km/s, fsc_low > 100 mHz Only]:  ',statx
;;  k_km_upp_pos [km^(-1), fsc_low > 100 mHz Only]:     0.00027536381     0.082803085    0.0037850453    0.0025398998    0.0043024674   0.00010371156
;;  k_km_upp_pos [km^(-1), fsc_low > 100 mHz Only]:     0.00064015605      0.11780452    0.0074864632    0.0051468272    0.0072296861   0.00017427256
;;  k_km_low_neg [km^(-1), fsc_low > 100 mHz Only]:      0.0065813746       669.86205       10.090272       3.5406340       36.606633      0.88240783
;;  k_km_upp_neg [km^(-1), fsc_low > 100 mHz Only]:      0.0065812369       669.63998       10.080595       3.5398802       36.580143      0.88176928
;;
;;  f_Hz_upp_pos [Hz, fsc_low > 100 mHz Only]:     1.7872254e-06      0.32986072     0.013179857    0.0033775544     0.026074270   0.00062852379
;;  f_Hz_upp_pos [Hz, fsc_low > 100 mHz Only]:     7.0958591e-06      0.71906428     0.047313620     0.014968988     0.078319719    0.0018879074
;;  f_Hz_low_neg [Hz, fsc_low > 100 mHz Only]:     3.8744025e-05       476.37579       129.12061       115.40954       82.456876       1.9876341
;;  f_Hz_upp_neg [Hz, fsc_low > 100 mHz Only]:     3.8419673e-05       476.37571       129.10933       115.40732       82.464303       1.9878131
;;
;;  V_ph_upp_pos [km/s, fsc_low > 100 mHz Only]:       0.013405271       125.42970       13.510688       8.1875956       15.089349      0.36373080
;;  V_ph_upp_pos [km/s, fsc_low > 100 mHz Only]:       0.028400828       175.98401       26.881243       17.414663       27.632577      0.66608700
;;  V_ph_low_neg [km/s, fsc_low > 100 mHz Only]:       0.031176936       582.90912       198.37578       205.69165       108.08951       2.6055121
;;  V_ph_upp_neg [km/s, fsc_low > 100 mHz Only]:       0.031046197       583.61902       198.60773       205.86927       108.22775       2.6088445

;;----------------------------------------------------------------------------------------
;;  Limit results to those satisfying wbar ≤ 0.25
;;----------------------------------------------------------------------------------------
;;------------------------------------
;;  wrest/Wce ≤ 0.25
;;------------------------------------
gind           = good_upp2
upp_lim        = 25d-2
goodw_low_pos  = WHERE(ABS(wrest_low_pos[gind,2]) LE upp_lim[0],gdw_low_pos)
goodw_upp_pos  = WHERE(ABS(wrest_upp_pos[gind,2]) LE upp_lim[0],gdw_upp_pos)
goodw_low_neg  = WHERE(ABS(wrest_low_neg[gind,2]) LE upp_lim[0],gdw_low_neg)
goodw_upp_neg  = WHERE(ABS(wrest_upp_neg[gind,2]) LE upp_lim[0],gdw_upp_neg)
PRINT,';;  ',gdw_low_pos[0] ,gdw_upp_pos[0] ,gdw_low_neg[0] ,gdw_upp_neg[0]
;;          1721        1721         219         220

gind           = good_upp2
gindw_low_pos  = gind[goodw_low_pos]
gindw_upp_pos  = gind[goodw_upp_pos]
gindw_low_neg  = gind[goodw_low_neg]
gindw_upp_neg  = gind[goodw_upp_neg]

x              = [kbar_low_pos[gindw_low_pos,2],kbar_upp_pos[gindw_upp_pos,2],$
                  kbar_low_neg[gindw_low_neg,2],kbar_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  kbar [wpe/c, fsc_low > 100 mHz & wrest/Wce ≤ 0.25 Only]:  ',statx
;;  kbar [wpe/c, fsc_low > 100 mHz & wrest/Wce ≤ 0.25 Only]:     0.00046981085       374.54338      0.39516042    0.0090437309       8.6229738      0.13841567

x              = [wrest_low_pos[gindw_low_pos,2],wrest_upp_pos[gindw_upp_pos,2],$
                  wrest_low_neg[gindw_low_neg,2],wrest_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  wbar [wce, fsc_low > 100 mHz & wrest/Wce ≤ 0.25 Only]:  ',statx
;;  wbar [wce, fsc_low > 100 mHz & wrest/Wce ≤ 0.25 Only]:     9.6571145e-09      0.24989509    0.0097663996   5.5622647e-05     0.038062410   0.00061097644

x              = [k_km_low_pos[gindw_low_pos,2],k_km_upp_pos[gindw_upp_pos,2],$
                  k_km_low_neg[gindw_low_neg,2],k_km_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  |k| [km^(-1), fsc_low > 100 mHz & wrest/Wce ≤ 0.25 Only]:  ',statx
;;  |k| [km^(-1), fsc_low > 100 mHz & wrest/Wce ≤ 0.25 Only]:     0.00027536381       174.07559      0.18569580    0.0042349056       4.0002411     0.064211726

x              = [f_Hz_low_pos[gindw_low_pos,2],f_Hz_upp_pos[gindw_upp_pos,2],$
                  f_Hz_low_neg[gindw_low_neg,2],f_Hz_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  f_rest [Hz, fsc_low > 100 mHz & wrest/Wce ≤ 0.25 Only]:  ',statx
;;  f_rest [Hz, fsc_low > 100 mHz & wrest/Wce ≤ 0.25 Only]:     1.7872254e-06       91.874740       1.7696801    0.0091749479       7.4773978      0.12002692

;;------------------------------------
;;  wrest/Wce ≤ 0.10
;;------------------------------------
gind           = good_upp2
upp_lim        = 10d-2
goodw_low_pos  = WHERE(ABS(wrest_low_pos[gind,2]) LE upp_lim[0],gdw_low_pos)
goodw_upp_pos  = WHERE(ABS(wrest_upp_pos[gind,2]) LE upp_lim[0],gdw_upp_pos)
goodw_low_neg  = WHERE(ABS(wrest_low_neg[gind,2]) LE upp_lim[0],gdw_low_neg)
goodw_upp_neg  = WHERE(ABS(wrest_upp_neg[gind,2]) LE upp_lim[0],gdw_upp_neg)
PRINT,';;  ',gdw_low_pos[0] ,gdw_upp_pos[0] ,gdw_low_neg[0] ,gdw_upp_neg[0]
;;          1721        1721         135         135

gind           = good_upp2
gindw_low_pos  = gind[goodw_low_pos]
gindw_upp_pos  = gind[goodw_upp_pos]
gindw_low_neg  = gind[goodw_low_neg]
gindw_upp_neg  = gind[goodw_upp_neg]

x              = [kbar_low_pos[gindw_low_pos,2],kbar_upp_pos[gindw_upp_pos,2],$
                  kbar_low_neg[gindw_low_neg,2],kbar_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  kbar [wpe/c, fsc_low > 100 mHz & wrest/Wce ≤ 0.10 Only]:  ',statx
;;  kbar [wpe/c, fsc_low > 100 mHz & wrest/Wce ≤ 0.10 Only]:     0.00046981085       10.456352     0.058376013    0.0085321873      0.36119053    0.0059283300

x              = [wrest_low_pos[gindw_low_pos,2],wrest_upp_pos[gindw_upp_pos,2],$
                  wrest_low_neg[gindw_low_neg,2],wrest_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  wbar [wce, fsc_low > 100 mHz & wrest/Wce ≤ 0.10 Only]:  ',statx
;;  wbar [wce, fsc_low > 100 mHz & wrest/Wce ≤ 0.10 Only]:     9.6571145e-09     0.098996142    0.0022253252   4.8444111e-05     0.010863025   0.00017829814

x              = [k_km_low_pos[gindw_low_pos,2],k_km_upp_pos[gindw_upp_pos,2],$
                  k_km_low_neg[gindw_low_neg,2],k_km_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  |k| [km^(-1), fsc_low > 100 mHz & wrest/Wce ≤ 0.10 Only]:  ',statx
;;  |k| [km^(-1), fsc_low > 100 mHz & wrest/Wce ≤ 0.10 Only]:     0.00027536381       5.2430042     0.029108098    0.0039725113      0.17384685    0.0028534013

x              = [f_Hz_low_pos[gindw_low_pos,2],f_Hz_upp_pos[gindw_upp_pos,2],$
                  f_Hz_low_neg[gindw_low_neg,2],f_Hz_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  f_rest [Hz, fsc_low > 100 mHz & wrest/Wce ≤ 0.10 Only]:  ',statx
;;  f_rest [Hz, fsc_low > 100 mHz & wrest/Wce ≤ 0.10 Only]:     1.7872254e-06       28.490571      0.39826898    0.0076682499       2.0892085     0.034290815

x              = [V_ph_low_pos[gindw_low_pos,2],V_ph_upp_pos[gindw_upp_pos,2],$
                  V_ph_low_neg[gindw_low_neg,2],V_ph_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  V_ph [km/s, fsc_low > 100 mHz & wrest ≤ wlh Only]:  ',statx
;;  V_ph [km/s, fsc_low > 100 mHz & wrest ≤ wlh Only]:       0.013405271       340.58528       25.250278       12.774136       36.162491      0.59354596

;;------------------------------------
;;  wrest/Wce ≤ 1/43 (i.e., wrest ≤ wlh)
;;------------------------------------
gind           = good_upp2
upp_lim        = 1d0/43d0
goodw_low_pos  = WHERE(ABS(wrest_low_pos[gind,2]) LE upp_lim[0],gdw_low_pos)
goodw_upp_pos  = WHERE(ABS(wrest_upp_pos[gind,2]) LE upp_lim[0],gdw_upp_pos)
goodw_low_neg  = WHERE(ABS(wrest_low_neg[gind,2]) LE upp_lim[0],gdw_low_neg)
goodw_upp_neg  = WHERE(ABS(wrest_upp_neg[gind,2]) LE upp_lim[0],gdw_upp_neg)
PRINT,';;  ',gdw_low_pos[0] ,gdw_upp_pos[0] ,gdw_low_neg[0] ,gdw_upp_neg[0]
;;          1721        1721          77          77

gind           = good_upp2
gindw_low_pos  = gind[goodw_low_pos]
gindw_upp_pos  = gind[goodw_upp_pos]
gindw_low_neg  = gind[goodw_low_neg]
gindw_upp_neg  = gind[goodw_upp_neg]

x              = [kbar_low_pos[gindw_low_pos,2],kbar_upp_pos[gindw_upp_pos,2],$
                  kbar_low_neg[gindw_low_neg,2],kbar_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  kbar [wpe/c, fsc_low > 100 mHz & wrest ≤ wlh Only]:  ',statx
;;  kbar [wpe/c, fsc_low > 100 mHz & wrest ≤ wlh Only]:     0.00046981085       5.8615993     0.025173765    0.0081242666      0.14834279    0.0024737546

x              = [wrest_low_pos[gindw_low_pos,2],wrest_upp_pos[gindw_upp_pos,2],$
                  wrest_low_neg[gindw_low_neg,2],wrest_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  wbar [wce, fsc_low > 100 mHz & wrest ≤ wlh Only]:  ',statx
;;  wbar [wce, fsc_low > 100 mHz & wrest ≤ wlh Only]:     9.6571145e-09     0.022950754   0.00045220106   4.5119139e-05    0.0020293603   3.3841478e-05

x              = [k_km_low_pos[gindw_low_pos,2],k_km_upp_pos[gindw_upp_pos,2],$
                  k_km_low_neg[gindw_low_neg,2],k_km_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  |k| [km^(-1), fsc_low > 100 mHz & wrest ≤ wlh Only]:  ',statx
;;  |k| [km^(-1), fsc_low > 100 mHz & wrest ≤ wlh Only]:     0.00027536381       2.9391119     0.012568833    0.0037867717     0.075216277    0.0012543016

x              = [f_Hz_low_pos[gindw_low_pos,2],f_Hz_upp_pos[gindw_upp_pos,2],$
                  f_Hz_low_neg[gindw_low_neg,2],f_Hz_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  f_rest [Hz, fsc_low > 100 mHz & wrest ≤ wlh Only]:  ',statx
;;  f_rest [Hz, fsc_low > 100 mHz & wrest ≤ wlh Only]:     1.7872254e-06       7.7915086     0.081632207    0.0070754206      0.40888700    0.0068185725

x              = [V_ph_low_pos[gindw_low_pos,2],V_ph_upp_pos[gindw_upp_pos,2],$
                  V_ph_low_neg[gindw_low_neg,2],V_ph_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  V_ph [km/s, fsc_low > 100 mHz & wrest ≤ wlh Only]:  ',statx
;;  V_ph [km/s, fsc_low > 100 mHz & wrest ≤ wlh Only]:       0.013405271       175.98401       21.044060       12.030544       24.589968      0.41006067

;;------------------------------------
;;  1/1836 ≤ wrest/Wce ≤ 1/43 (i.e., Wci ≤ wrest ≤ wlh)
;;------------------------------------
gind           = good_upp2
low_lim        = 1d0/1836d0
upp_lim        = 1d0/43d0
goodw_low_pos  = WHERE(ABS(wrest_low_pos[gind,2]) LE upp_lim[0] AND ABS(wrest_low_pos[gind,2]) GE low_lim[0],gdw_low_pos)
goodw_upp_pos  = WHERE(ABS(wrest_upp_pos[gind,2]) LE upp_lim[0] AND ABS(wrest_upp_pos[gind,2]) GE low_lim[0],gdw_upp_pos)
goodw_low_neg  = WHERE(ABS(wrest_low_neg[gind,2]) LE upp_lim[0] AND ABS(wrest_low_neg[gind,2]) GE low_lim[0],gdw_low_neg)
goodw_upp_neg  = WHERE(ABS(wrest_upp_neg[gind,2]) LE upp_lim[0] AND ABS(wrest_upp_neg[gind,2]) GE low_lim[0],gdw_upp_neg)
PRINT,';;  ',gdw_low_pos[0] ,gdw_upp_pos[0] ,gdw_low_neg[0] ,gdw_upp_neg[0]
;;            30         236          54          54

gind           = good_upp2
gindw_low_pos  = gind[goodw_low_pos]
gindw_upp_pos  = gind[goodw_upp_pos]
gindw_low_neg  = gind[goodw_low_neg]
gindw_upp_neg  = gind[goodw_upp_neg]

x              = [kbar_low_pos[gindw_low_pos,2],kbar_upp_pos[gindw_upp_pos,2],$
                  kbar_low_neg[gindw_low_neg,2],kbar_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  kbar [wpe/c, fsc_low > 100 mHz & Wci ≤ wrest ≤ wlh Only]:  ',statx
;;  kbar [wpe/c, fsc_low > 100 mHz & Wci ≤ wrest ≤ wlh Only]:       0.023701159       5.8615993      0.15490785     0.039662122      0.43828359     0.022663105

x              = [wrest_low_pos[gindw_low_pos,2],wrest_upp_pos[gindw_upp_pos,2],$
                  wrest_low_neg[gindw_low_neg,2],wrest_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  wbar [wce, fsc_low > 100 mHz & Wci ≤ wrest ≤ wlh Only]:  ',statx
;;  wbar [wce, fsc_low > 100 mHz & Wci ≤ wrest ≤ wlh Only]:     0.00054482172     0.022950754    0.0035696312    0.0011115721    0.0053560813   0.00027695637

x              = [k_km_low_pos[gindw_low_pos,2],k_km_upp_pos[gindw_upp_pos,2],$
                  k_km_low_neg[gindw_low_neg,2],k_km_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  |k| [km^(-1), fsc_low > 100 mHz & Wci ≤ wrest ≤ wlh Only]:  ',statx
;;  |k| [km^(-1), fsc_low > 100 mHz & Wci ≤ wrest ≤ wlh Only]:      0.0060390350       2.9391119     0.077322865     0.020417773      0.22239731     0.011499891

x              = [f_Hz_low_pos[gindw_low_pos,2],f_Hz_upp_pos[gindw_upp_pos,2],$
                  f_Hz_low_neg[gindw_low_neg,2],f_Hz_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  f_rest [Hz, fsc_low > 100 mHz & Wci ≤ wrest ≤ wlh Only]:  ',statx
;;  f_rest [Hz, fsc_low > 100 mHz & Wci ≤ wrest ≤ wlh Only]:       0.038451190       7.7915086      0.63746807      0.20695722       1.1222486     0.058030095

x              = [V_ph_low_pos[gindw_low_pos,2],V_ph_upp_pos[gindw_upp_pos,2],$
                  V_ph_low_neg[gindw_low_neg,2],V_ph_upp_neg[gindw_upp_neg,2] ]
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]
PRINT,';;  V_ph [km/s, fsc_low > 100 mHz & Wci ≤ wrest ≤ wlh Only]:  ',statx
;;  V_ph [km/s, fsc_low > 100 mHz & Wci ≤ wrest ≤ wlh Only]:         6.3040472       172.16645       64.826966       62.119108       32.398944       1.6753095



















































