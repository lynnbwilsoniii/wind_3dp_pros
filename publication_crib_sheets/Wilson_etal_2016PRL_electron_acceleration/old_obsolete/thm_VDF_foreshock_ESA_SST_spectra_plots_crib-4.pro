;;----------------------------------------------------------------------------------------
;;  Papers relevant to energetic electrons at shocks:
;;
;;    -  Masters et al. [2013] Nature Phys. [Saturn up to ~1 MeV]
;;    -  Masters et al. [2013] Plasma Phys. Control. Fusion [in situ Obs. of high M shocks]
;;    -  Ho et al. [2003] ICRC [IP shocks to >38 keV --> ESP cause]
;;    -  Tsurutani and Lin [1985] JGR [IP shocks to >2 keV]
;;    -  Guo and Giacalone [2010] ApJ [IP shocks (simulations) to >few to ~10 keV]
;;    -  Lin, R.P. [1985] Solar Phys. [review of suprathermal electrons in IPM]
;;    -  Sarris and Krimigis [1985] ApJ [IP shock to >2 MeV at ~1.9 AU]
;;    -  Vandas et al. [1986] ASR [Qperp bow shocks to ≥30 keV]
;;    -  Krauss-Varban, D. [1994] JGR [Qperp bow shocks (simulations) to >few to ~10 keV]
;;    -  Yuan et al. [2007] ApJ [Qperp shocks (simulations) up to < 25 Vtherm, reformation]
;;    -  Yuan et al. [2007] JGR [Qperp shocks (simulations) up to < 10 Vtherm, overshoots]
;;    -  Yuan et al. [2008a] JGR A08109 [Qperp shocks (simulations) up to < 10 Vtherm]
;;    -  Yuan et al. [2008b] JGR A09106 [Qperp shocks (simulations) up to ≤ 25 Vtherm or E/Eo ≤ 800]
;;    -  Lopate, C. [1989] JGR [IP shocks to ~2-7 MeV between ~7-28 AU]
;;    -  Anderson, K.A. [1968] JGR [bow shocks to >40 keV]
;;    -  Anderson, K.A. [1969] JGR [bow shocks to >40 keV, Eo ~ 14 keV for BS, ~16 keV for US, ¥ ~ 2.1(BS), 1.8(US)]
;;    -  Anderson et al. [1979] JGR [bow shocks to >16 keV --> nearly continuous feature of electron foreshock]
;;    -  Anderson, K.A. [1981] JGR [bow shocks to ~2-100 keV at up to ~240 Re upstream]
;;    -  Gosling et al. [1989] JGR [bow shocks to >20 keV downstream Qperp only]
;;    -  Burgess [2006] ApJ [Qperp shocks (simulations) to >few to ~10 keV]
;;    -  Kronberg et al. [2011] JGR [BS, ~37-125 keV at up to 8500 Re upstream; attribute to magnetospheric activity]
;;    -  
;;    -  
;;    -  
;;----------------------------------------------------------------------------------------


;;----------------------------------------------------------------------------------------
;;  Compile relevant routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
GG             = 6.6740800000d-11         ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1), 2014 CODATA/NIST]
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
SB             = 5.6703670000d-08         ;;  Stefan-Boltzmann Constant [W m^(-2) K^(-4), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
ma_eV          = ma[0]*c[0]^2/qq[0]       ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
me_eV          = me[0]*c[0]^2/qq[0]       ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mn_eV          = mn[0]*c[0]^2/qq[0]       ;;  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c[0]^2/qq[0]       ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;  Astronomical
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2016 AA values]
M_E            = 5.9722000d24             ;;  Earth's mass [kg, 2015 AA values]
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km
;;  Conversion Factors
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
J_1eV          = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
K_eV           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
eV_K           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
valfen__fac    = 1d-9/SQRT(muo[0]*mp[0]*1d6)       ;;  factor for (proton-only) Alfvén speed [m s^(-1) nT^(-1) cm^(-3/2)]
gam            = 5d0/3d0                  ;;  Use gamma = 5/3
rho_fac        = (me[0] + mp[0])*1d6      ;;  kg, cm^(-3) --> m^(-3)
cs_fac         = SQRT(gam[0]/rho_fac[0])
;;  Useful variables
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
all_scs        = ['a','b','c','d','e']
coord_ssl      = 'ssl'
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_mag      = 'mag'
fb_string      = ['f','b']
vec_str        = ['x','y','z']
fac_vec_str    = ['perp1','perp2','para']
fac_dir_str    = ['para','perp','anti']
vec_col        = [250,150,50]

start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
;;  Define dummy time range arrays for later use
dt_70          = [-1,1]*7d1
dt_140         = [-1,1]*14d1
dt_200         = [-1,1]*20d1
dt_250         = [-1,1]*25d1
dt_400         = [-1,1]*40d1
;;----------------------------------------------------------------------------------------
;;  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  Probe A

;;  Probe B

;;  Probe C

probe          = 'c'
tdate          = '2008-07-14'
date           = '071408'

probe          = 'c'
tdate          = '2008-08-19'   ;;  tons of shocklets and SLAMS for this pass
date           = '081908'

probe          = 'c'
tdate          = '2008-09-08'
date           = '090808'

probe          = 'c'
tdate          = '2008-09-16'
date           = '091608'

;;  Probe D

;;  Probe E

;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_themis_foreshock_eVDFs_batch.pro
n_e            = N_ELEMENTS(dat_egse)
n_i            = N_ELEMENTS(dat_igse)
tra_sst        = time_double(tr_00)
;;  Sort by time (since it was not done, apparently)
sp             = SORT(dat_egse.TIME)
dat_egse       = TEMPORARY(dat_egse[sp])
sp             = SORT(dat_igse.TIME)
dat_igse       = TEMPORARY(dat_igse[sp])
;;  Insert NaNs at intervals
fgs_tpns       = tnames(scpref[0]+'fgl_*')
fgl_tpns       = tnames(scpref[0]+'fgl_*')
fgh_tpns       = tnames(scpref[0]+'fgh_*')
t_insert_nan_at_interval_se,fgs_tpns,GAP_THRESH=4d0
t_insert_nan_at_interval_se,fgl_tpns,GAP_THRESH=1d0/3d0
t_insert_nan_at_interval_se,fgh_tpns,GAP_THRESH=1d0/100d0
;;  Set defaults
lbw_tplot_set_defaults
tplot_options, 'XMARGIN',[20,15]      ;;  Change X-Margins slightly

fgs_tpns       = scpref[0]+'fgs_'+[coord_mag[0],coord_gse[0]]
fgl_tpns       = scpref[0]+'fgl_'+[coord_mag[0],coord_gse[0]]
fgh_tpns       = scpref[0]+'fgh_'+[coord_mag[0],coord_gse[0]]

tplot,fgs_tpns,TRANGE=tra_sst
tplot,fgl_tpns,TRANGE=tra_sst
tplot,fgh_tpns,TRANGE=tra_sst

;;  Determine fgh time intervals
fghnm          = scpref[0]+'fgh_'+[coord_mag[0],coord_gse[0]]
get_data,fghnm[0],DATA=temp,DLIM=dlim,LIM=lim
gap_thsh       = 1d-2
srate          = sample_rate(temp.X,GAP_THRESH=gap_thsh[0],/AVE,OUT_MED_AVG=sr_medavg)
med_sr         = sr_medavg[0]                     ;;  Median sample rate [sps]
med_dt         = 1d0/med_sr[0]                    ;;  Median sample period [s]
se_int         = t_interval_find(temp.X,GAP_THRESH=2d0*med_dt[0],/NAN)
sint_fgh       = temp.X[REFORM(se_int[*,0])]
eint_fgh       = temp.X[REFORM(se_int[*,1])]
;;----------------------------------------------------------------------------------------
;;  Define relevant time ranges
;;----------------------------------------------------------------------------------------
;;  Initialize defaults
t_tr_0         = tdate[0]+'/'+[start_of_day_t[0],end___of_day_t[0]]
t_tr_1         = t_tr_0
t_tr_2         = t_tr_0
t_tr_3         = t_tr_0
t_tr_4         = t_tr_0
t_tr_5         = t_tr_0
t_slam_cent    = tdate[0]+'/12:00:00.000000000'
t_hfa__cent    = t_slam_cent[0]
t_fb___cent    = t_slam_cent[0]
;;  Define date-specific time ranges
IF (tdate[0] EQ '2008-07-14') THEN t_tr_0 = tdate[0]+'/'+['12:19:46.000000','12:31:13.000000']
IF (tdate[0] EQ '2008-07-14') THEN t_tr_1 = tdate[0]+'/'+['13:10:43.900000','13:20:50.200000']
IF (tdate[0] EQ '2008-07-14') THEN t_tr_2 = tdate[0]+'/'+['15:17:03.300000','15:27:08.000000']
IF (tdate[0] EQ '2008-07-14') THEN t_tr_3 = tdate[0]+'/'+['19:57:59.400000','20:08:04.700000']
IF (tdate[0] EQ '2008-07-14') THEN t_tr_4 = tdate[0]+'/'+['21:53:44.000000','22:14:03.000000']
IF (tdate[0] EQ '2008-07-14') THEN t_tr_5 = tdate[0]+'/'+['22:33:28.800000','22:43:39.400000']
;;  Define center-times for specific TIFP
IF (tdate[0] EQ '2008-07-14') THEN t_slam_cent = tdate[0]+'/13:16:26'
IF (tdate[0] EQ '2008-07-14') THEN t_hfa__cent = tdate[0]+'/15:21:00'
IF (tdate[0] EQ '2008-07-14') THEN t_fb___cent = tdate[0]+'/21:58:10'

IF (tdate[0] EQ '2008-08-19') THEN t_slam_cent = tdate[0]+'/'+['21:48:55','21:53:45','22:10:20','22:14:00','22:14:40','22:17:35','22:18:30','22:22:30','22:34:10','22:35:24','22:37:45','22:42:48']
IF (tdate[0] EQ '2008-08-19') THEN t_hfa__cent = tdate[0]+'/'+['12:50:57','21:46:17','22:41:00']
IF (tdate[0] EQ '2008-08-19') THEN t_fb___cent = tdate[0]+'/'+['20:43:35','21:51:45','23:38:44']

IF (tdate[0] EQ '2008-09-08') THEN t_slam_cent = tdate[0]+'/'+['17:16:00','17:17:20','17:28:23','19:59:27','20:24:50','20:36:11','21:12:24','21:15:33']
IF (tdate[0] EQ '2008-09-08') THEN t_hfa__cent = tdate[0]+'/'+['17:01:41','19:13:57','20:26:44']
IF (tdate[0] EQ '2008-09-08') THEN t_fb___cent = tdate[0]+'/20:25:22'

;;  Define Unix version of time ranges
temp_tr0       = time_double(t_tr_0)
temp_tr1       = time_double(t_tr_1)
temp_tr2       = time_double(t_tr_2)
temp_tr3       = time_double(t_tr_3)
temp_tr4       = time_double(t_tr_4)
temp_tr5       = time_double(t_tr_5)
;;  Define several time windows
FOR j=0L, N_ELEMENTS(t_slam_cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_slam_cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_slam_70  = unix_ra[0,*] ELSE tr_slam_70  = [tr_slam_70, unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_slam_140 = unix_ra[0,*] ELSE tr_slam_140 = [tr_slam_140,unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_slam_200 = unix_ra[0,*] ELSE tr_slam_200 = [tr_slam_200,unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_slam_250 = unix_ra[0,*] ELSE tr_slam_250 = [tr_slam_250,unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_slam_400 = unix_ra[0,*] ELSE tr_slam_400 = [tr_slam_400,unix_ra[0,*]]

FOR j=0L, N_ELEMENTS(t_hfa__cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_hfa__cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_hfa__70  = unix_ra[0,*] ELSE tr_hfa__70  = [tr_hfa__70, unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_hfa__140 = unix_ra[0,*] ELSE tr_hfa__140 = [tr_hfa__140,unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_hfa__200 = unix_ra[0,*] ELSE tr_hfa__200 = [tr_hfa__200,unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_hfa__250 = unix_ra[0,*] ELSE tr_hfa__250 = [tr_hfa__250,unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_hfa__400 = unix_ra[0,*] ELSE tr_hfa__400 = [tr_hfa__400,unix_ra[0,*]]

FOR j=0L, N_ELEMENTS(t_fb___cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_fb___cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_fb___70  = unix_ra[0,*] ELSE tr_fb___70  = [tr_fb___70, unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_fb___140 = unix_ra[0,*] ELSE tr_fb___140 = [tr_fb___140,unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_fb___200 = unix_ra[0,*] ELSE tr_fb___200 = [tr_fb___200,unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_fb___250 = unix_ra[0,*] ELSE tr_fb___250 = [tr_fb___250,unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_fb___400 = unix_ra[0,*] ELSE tr_fb___400 = [tr_fb___400,unix_ra[0,*]]

;;  Show location of SLAMS, HFAs, and FBs
time_bar,t_slam_cent,COLOR=250
time_bar,t_hfa__cent,COLOR=200
time_bar,t_fb___cent,COLOR= 30
;;----------------------------------------------------------------------------------------
;;  Calculate bow shock parameters
;;----------------------------------------------------------------------------------------
;;    bow shock model [Slavin and Holzer, [1981]]
ecc            = (1.10 + 1.20)/2d0                       ; => eccentricity      [Table 4 estimates]
Lsemi          = (22.9 + 23.5)/2d0                       ; => semi-latus rectum [Re, Table 4 estimates]
xo             = 1.2d0
bow            = {STANDOFF:Lsemi[0],ECCENTRICITY:ecc[0],X_OFFSET:xo[0]}
;;  Get Bo and R_sc data
thm_pos_tpn    = scpref[0]+'state_pos_'+coord_gse[0]
thm_vsw_tpn    = scpref[0]+'peir_velocity_'+coord_gse[0]
get_data,   fgs_tpns[1],DATA=thm_bo,DLIM=dlim_bo,LIM=lim_bo
get_data,thm_pos_tpn[0],DATA=thm_ro,DLIM=dlim_ro,LIM=lim_ro
get_data,thm_vsw_tpn[0],DATA=thm_Vi,DLIM=dlim_Vi,LIM=lim_Vi
;;  Define params
thm_ro_t       = thm_ro.X
thm_ro_v       = thm_ro.Y/R_E[0]
thm_ro2        = {X:thm_ro_t,Y:thm_ro_v}
thm_bo2        = {X:thm_bo.X,Y:thm_bo.Y}
thm_Vi2        = {X:thm_Vi.X,Y:thm_Vi.Y}
;;  Define time range to use for BS parameter calcs
IF (tdate[0] EQ '2008-07-14') THEN tr_bs_cal = time_double(tdate[0]+'/'+['11:52:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-08-19') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:00:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-09-08') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:00:00','21:32:00'])

;;  Clip the data to the specified time range
thm_ro2        = trange_clip_data(thm_ro2,TRANGE=tr_bs_cal,PREC=3)
thm_bo2        = trange_clip_data(thm_bo2,TRANGE=tr_bs_cal,PREC=3)
thm_Vi2        = trange_clip_data(thm_Vi2,TRANGE=tr_bs_cal,PREC=3)

;;  Re-sample the data to Bo time stamps
thm_bo3        = thm_bo2
thm_ro3        = t_resample_tplot_struc(thm_ro2,thm_bo2.X,/NO_EXTRAPOLATE)
thm_Vi3        = t_resample_tplot_struc(thm_Vi2,thm_bo2.X,/NO_EXTRAPOLATE)

;;  Calculate model BS params
pos            = thm_ro3.Y
magf           = thm_bo3.Y
vsw            = thm_Vi3.Y
.compile $HOME/Desktop/swidl-0.1/wind_3dp_pros/DAVIN_PRO/cal_bs_param.pro
cal_bs_param,pos,magf,BOW=bow,VSW=vsw,STRUCT=bs_par_str

n_sh           = bs_par_str.SHNORM
shpos          = bs_par_str.SHPOS
thetabn        = bs_par_str.BSN
lsh_n          = bs_par_str.LSN
diff           = mag__vec(pos,/NAN) - mag__vec(shpos,/NAN)
bad            = WHERE(diff LE 0,bd)
IF (bd[0] GT 0) THEN thetabn[bad] = f
IF (bd[0] GT 0) THEN lsh_n[bad]   = f
IF (bd[0] GT 0) THEN n_sh[bad,*]  = f
thetabnc       = thetabn < (18e1 - thetabn)       ;;  Complementary angle only [deg]
;;  Calculate smoothed versions of parameters
smwd           = 25L                              ;;  Width of smoothing points
thetabn_sm     = SMOOTH(thetabn,smwd[0],/NAN,/EDGE_TRUNCATE)
lsh_n_sm       = SMOOTH(lsh_n,smwd[0],/NAN,/EDGE_TRUNCATE)
thetabnc_sm    = SMOOTH(thetabnc,smwd[0],/NAN,/EDGE_TRUNCATE)
n_sh_x_sm      = SMOOTH(n_sh[*,0],smwd[0],/NAN,/EDGE_TRUNCATE)
n_sh_y_sm      = SMOOTH(n_sh[*,1],smwd[0],/NAN,/EDGE_TRUNCATE)
n_sh_z_sm      = SMOOTH(n_sh[*,2],smwd[0],/NAN,/EDGE_TRUNCATE)
n_sh_sm        = [[n_sh_x_sm],[n_sh_y_sm],[n_sh_z_sm]]

thm_lsn_tpn    = scpref[0]+'lshn_re'
thm_bsn_tpn    = scpref[0]+'BS_thbn_deg'
thm_bsntpn2    = scpref[0]+'BS_thbn_c_deg'
lshn_struc     = {X:thm_bo3.X,Y:[[lsh_n],[lsh_n_sm]]}
thbn_struc     = {X:thm_bo3.X,Y:[[thetabn],[thetabn_sm]]}
tbnc_struc     = {X:thm_bo3.X,Y:[[thetabnc],[thetabnc_sm]]}

store_data,thm_lsn_tpn[0],DATA=lshn_struc,LIM=lim_ro
store_data,thm_bsn_tpn[0],DATA=thbn_struc,LIM=lim_ro
store_data,thm_bsntpn2[0],DATA=tbnc_struc,LIM=lim_ro
tlabs          = ['Value','Smoothed']
tcols          = vec_col[[2,0]]
options,thm_lsn_tpn[0],YTITLE='(Lsh . n)',YSUBTITLE='[Re]',COLORS=tcols,LABELS=tlabs,/DEF
options,thm_bsn_tpn[0],YTITLE='(Bo . n)',YSUBTITLE='[deg]',COLORS=tcols,LABELS=tlabs,/DEF
options,thm_bsntpn2[0],YTITLE='|(Bo . n)|',YSUBTITLE='[deg]',COLORS=tcols,LABELS=tlabs,/DEF

;;  Plot overview and save
nna            = [fgs_tpns,thm_vsw_tpn[0],thm_lsn_tpn[0],thm_bsntpn2[0]]
  tplot,nna,TRANGE=tr_bs_cal

popen_str      = {PORT:1,UNITS:'inches',XSIZE:8.5,YSIZE:11.}
scu            = STRUPCASE(sc[0])
fpref          = 'THM-'+scu[0]+'_Bo-fgs_Vi-Reduced_Lsh-n_ThetaBn_'
fmid           = 'red-SLAMS_orange-HFA_purple-FB_'
fnm_times      = file_name_times(t_get_current_trange(),PREC=0)
f_times        = fnm_times.F_TIME[0]+'-'+STRMID(fnm_times.F_TIME[1],11L)
fname          = fpref[0]+fmid[0]+f_times[0]

  tplot,nna,TRANGE=tr_bs_cal
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
popen,fname[0],_EXTRA=popen_str
  tplot,nna
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
pclose
;;----------------------------------------------------------------------------------------
;;  Calculate bow shock Mach numbers (assuming shock is stationary in Earth frame)
;;----------------------------------------------------------------------------------------
thm_vbulk_tpn  = scpref[0]+'peir_velocity_'+coord_gse[0]
thm_ipten_tpn  = scpref[0]+'peir_ptens'
thm_idens_tpn  = scpref[0]+'peir_density'
thm_itemp_tpn  = scpref[0]+'peir_avgtemp'
thm_etemp_tpn  = scpref[0]+'peer_avgtemp'
thm_epten_tpn  = scpref[0]+'peer_ptens'
;;  Get data
get_data,     fgs_tpns[1],DATA=thm_bo,DLIM=dlim_bo,LIM=lim_bo
get_data,thm_vbulk_tpn[0],DATA=thm_Vi,DLIM=dlim_Vi,LIM=lim_Vi
get_data,thm_ipten_tpn[0],DATA=thm_Pi,DLIM=dlim_Pi,LIM=lim_Pi
get_data,thm_idens_tpn[0],DATA=thm_Ni,DLIM=dlim_Ni,LIM=lim_Ni
get_data,thm_itemp_tpn[0],DATA=thm_Ti,DLIM=dlim_Ti,LIM=lim_Ti
get_data,thm_etemp_tpn[0],DATA=thm_Te,DLIM=dlim_Te,LIM=lim_Te
get_data,thm_epten_tpn[0],DATA=thm_Pe,DLIM=dlim_Pe,LIM=lim_Pe
n_sh_str       =     {X:thm_bo3.X,Y:n_sh_sm}
thbn_str       = {X:thm_bo3.X,Y:thetabnc_sm}
;;  Re-sample Te, Pe, Bo, nsh, and Theta_Bn to ion time stamps
thm_Te2        = t_resample_tplot_struc(thm_Te,thm_Vi.X,/NO_EXTRAPOLATE)
thm_Pe2        = t_resample_tplot_struc(thm_Pe,thm_Vi.X,/NO_EXTRAPOLATE)
thm_bo4        = t_resample_tplot_struc(thm_bo,thm_Vi.X,/NO_EXTRAPOLATE)
thm_nsh        = t_resample_tplot_struc(n_sh_str,thm_Vi.X,/NO_EXTRAPOLATE)
thm_thbn       = t_resample_tplot_struc(thbn_str,thm_Vi.X,/NO_EXTRAPOLATE)
;;  Calculate parameters
diag_els       = [0L,1L,2L]
Pi_scalar      = TOTAL(thm_Pi.Y[*,diag_els],2,/NAN)/3e0
Pe_scalar      = TOTAL(thm_Pe2.Y[*,diag_els],2,/NAN)/3e0
P_total        = (Pi_scalar + Pe_scalar)          ;;  Total scalar thermal pressure [eV cm^(-3)]
P_total       *= (J_1eV[0]*1d6)                   ;;  eV --> J, cm^(-3) --> m^(-3)
;;  Calculate relevant speeds
bmag           = mag__vec(thm_bo4.Y,/NAN)
V_A            = valfen__fac[0]*bmag/SQRT(thm_Ni.Y)
V_A           *= 1d-3                             ;;  m --> km
C_s            = cs_fac[0]*SQRT(P_total/thm_Ni.Y)
C_s           *= 1d-3                             ;;  m --> km
V_f_f0_2       = (V_A^2 + C_s^2)
V_f_f1         = 4d0*V_A^2*C_s^2*SIN(thm_thbn.Y*!DPI/18d1)^2
V_f_2          = (V_f_f0_2 + SQRT(V_f_f0_2^2 + V_f_f1))/2d0
V_f            = SQRT(V_f_2)                      ;;  Fast mode speed [km/s]
;;  Calculate relevant Mach #'s
v_mag          = mag__vec(thm_Vi.Y,/NAN)
vi_d_nsh       = my_dot_prod(thm_Vi.Y,thm_nsh.Y,/NOM)
vn_mag         = ABS(vi_d_nsh)

M_A            = vn_mag/V_A
M_s            = vn_mag/C_s
M_f            = vn_mag/V_f
bad_ma         = WHERE(ABS(M_A) GE 5e1,bd_ma)
IF (bd_ma[0] GT 0) THEN M_A[bad_ma] = f
IF (bd_ma[0] GT 0) THEN M_s[bad_ma] = f
IF (bd_ma[0] GT 0) THEN M_f[bad_ma] = f
;;  Send to TPLOT
thm_Machs_tpn  = scpref[0]+'BS_Ma_Ms_Mf'
Machs_str      = {X:thm_Vi.X,Y:[[M_A],[M_s],[M_f]]}
store_data,thm_Machs_tpn[0],DATA=Machs_str,LIM=lim_ro
Mlabs          = ['M_A','M_s','M_f']
Mcols          = vec_col
options,thm_Machs_tpn[0],YTITLE='Mach #s',YSUBTITLE='[Using (Vi . n)]',COLORS=mcols,LABELS=mlabs,/DEF

;;  Plot overview and save
nna            = [fgs_tpns,thm_Machs_tpn[0],thm_bsntpn2[0]]
  tplot,nna,TRANGE=tr_bs_cal

popen_str      = {PORT:1,UNITS:'inches',XSIZE:8.5,YSIZE:11.}
scu            = STRUPCASE(sc[0])
fpref          = 'THM-'+scu[0]+'_Bo-fgs_MA_Ms_Mf_ThetaBn_'
fmid           = 'red-SLAMS_orange-HFA_purple-FB_'
fnm_times      = file_name_times(t_get_current_trange(),PREC=0)
f_times        = fnm_times.F_TIME[0]+'-'+STRMID(fnm_times.F_TIME[1],11L)
fname          = fpref[0]+fmid[0]+f_times[0]

  tplot,nna,TRANGE=tr_bs_cal
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
popen,fname[0],_EXTRA=popen_str
  tplot,nna
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
pclose


;;----------------------------------------------------------------------------------------
;;  Load SST data
;;----------------------------------------------------------------------------------------
vern           = !VERSION.RELEASE     ;;  e.g., '7.1.1'
test           = (vern[0] GE '6.0')
IF (test[0]) THEN cwd_char = FILE_DIRNAME('',/MARK_DIRECTORY) ELSE cwd_char = '.'+slash[0]
cur_wdir       = FILE_EXPAND_PATH(cwd_char[0])
new_ts_dir     = add_os_slash(cur_wdir[0]);+'themis_data_dir'+slash[0]
new_sst_dir    = new_ts_dir[0]+'themis_sst_save'+slash[0]+tdate[0]+slash[0]
esname         = 'SSTE_*_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
isname         = 'SSTI_*_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
sste_file      = FILE_SEARCH(new_sst_dir[0],esname[0])
ssti_file      = FILE_SEARCH(new_sst_dir[0],isname[0])
test_sste      = (sste_file[0] NE '')
test_ssti      = (ssti_file[0] NE '')
IF (test_sste[0]) THEN RESTORE,sste_file[0]  ;;  Restore SST Electron structures
IF (test_ssti[0]) THEN RESTORE,ssti_file[0]  ;;  Restore SST Ion structures

p_test         = WHERE(all_scs EQ sc[0],pt)
p_t_arr        = [(p_test[0] EQ 0),(p_test[0] EQ 1),(p_test[0] EQ 2),(p_test[0] EQ 3),(p_test[0] EQ 4)]
IF (test_ssti[0] AND p_t_arr[0]) THEN nsif = N_ELEMENTS(psif_df_arr_a)
IF (test_ssti[0] AND p_t_arr[1]) THEN nsif = N_ELEMENTS(psif_df_arr_b)
IF (test_ssti[0] AND p_t_arr[2]) THEN nsif = N_ELEMENTS(psif_df_arr_c)
IF (test_ssti[0] AND p_t_arr[3]) THEN nsif = N_ELEMENTS(psif_df_arr_d)
IF (test_ssti[0] AND p_t_arr[4]) THEN nsif = N_ELEMENTS(psif_df_arr_e)
IF (test_ssti[0] AND p_t_arr[0]) THEN nsib = N_ELEMENTS(psib_df_arr_a)
IF (test_ssti[0] AND p_t_arr[1]) THEN nsib = N_ELEMENTS(psib_df_arr_b)
IF (test_ssti[0] AND p_t_arr[2]) THEN nsib = N_ELEMENTS(psib_df_arr_c)
IF (test_ssti[0] AND p_t_arr[3]) THEN nsib = N_ELEMENTS(psib_df_arr_d)
IF (test_ssti[0] AND p_t_arr[4]) THEN nsib = N_ELEMENTS(psib_df_arr_e)
IF (test_sste[0] AND p_t_arr[0]) THEN nsef = N_ELEMENTS(psef_df_arr_a)
IF (test_sste[0] AND p_t_arr[1]) THEN nsef = N_ELEMENTS(psef_df_arr_b)
IF (test_sste[0] AND p_t_arr[2]) THEN nsef = N_ELEMENTS(psef_df_arr_c)
IF (test_sste[0] AND p_t_arr[3]) THEN nsef = N_ELEMENTS(psef_df_arr_d)
IF (test_sste[0] AND p_t_arr[4]) THEN nsef = N_ELEMENTS(psef_df_arr_e)
IF (test_sste[0] AND p_t_arr[0]) THEN nseb = N_ELEMENTS(pseb_df_arr_a)
IF (test_sste[0] AND p_t_arr[1]) THEN nseb = N_ELEMENTS(pseb_df_arr_b)
IF (test_sste[0] AND p_t_arr[2]) THEN nseb = N_ELEMENTS(pseb_df_arr_c)
IF (test_sste[0] AND p_t_arr[3]) THEN nseb = N_ELEMENTS(pseb_df_arr_d)
IF (test_sste[0] AND p_t_arr[4]) THEN nseb = N_ELEMENTS(pseb_df_arr_e)

IF (nsib[0] GT 0) THEN IF (p_t_arr[0]) THEN dat_sib = psib_df_arr_a ELSE $
                       IF (p_t_arr[1]) THEN dat_sib = psib_df_arr_b ELSE $
                       IF (p_t_arr[2]) THEN dat_sib = psib_df_arr_c ELSE $
                       IF (p_t_arr[3]) THEN dat_sib = psib_df_arr_d ELSE $
                       IF (p_t_arr[4]) THEN dat_sib = psib_df_arr_e

IF (nsif[0] GT 0) THEN IF (p_t_arr[0]) THEN dat_sif = psif_df_arr_a ELSE $
                       IF (p_t_arr[1]) THEN dat_sif = psif_df_arr_b ELSE $
                       IF (p_t_arr[2]) THEN dat_sif = psif_df_arr_c ELSE $
                       IF (p_t_arr[3]) THEN dat_sif = psif_df_arr_d ELSE $
                       IF (p_t_arr[4]) THEN dat_sif = psif_df_arr_e

IF (nseb[0] GT 0) THEN IF (p_t_arr[0]) THEN dat_seb = pseb_df_arr_a ELSE $
                       IF (p_t_arr[1]) THEN dat_seb = pseb_df_arr_b ELSE $
                       IF (p_t_arr[2]) THEN dat_seb = pseb_df_arr_c ELSE $
                       IF (p_t_arr[3]) THEN dat_seb = pseb_df_arr_d ELSE $
                       IF (p_t_arr[4]) THEN dat_seb = pseb_df_arr_e

IF (nsef[0] GT 0) THEN IF (p_t_arr[0]) THEN dat_sef = psef_df_arr_a ELSE $
                       IF (p_t_arr[1]) THEN dat_sef = psef_df_arr_b ELSE $
                       IF (p_t_arr[2]) THEN dat_sef = psef_df_arr_c ELSE $
                       IF (p_t_arr[3]) THEN dat_sef = psef_df_arr_d ELSE $
                       IF (p_t_arr[4]) THEN dat_sef = psef_df_arr_e

PRINT,';; ',nseb[0],nsef[0],nsib[0],nsif[0],'  For Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0]
;;         1347         658           0       14009  For Probe:  THC on 2008-07-14
;;         1338         655           0       14019  For Probe:  THC on 2008-08-19
;;         1188         662           0       14092  For Probe:  THC on 2008-09-08
;;----------------------------------------------------------------------------------------
;;  Modify SST structures [just in case]
;;----------------------------------------------------------------------------------------
;;  Modify unit conversion procedure
IF (nsef[0] GT 0) THEN dat_sef.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'
IF (nseb[0] GT 0) THEN dat_seb.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'
IF (nsif[0] GT 0) THEN dat_sif.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'
IF (nsib[0] GT 0) THEN dat_sib.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'

;;  Modify particle charge
IF (nsef[0] GT 0) THEN dat_sef.CHARGE = -1e0
IF (nseb[0] GT 0) THEN dat_seb.CHARGE = -1e0
IF (nsif[0] GT 0) THEN dat_sif.CHARGE = 1e0
IF (nsib[0] GT 0) THEN dat_sib.CHARGE = 1e0
;;----------------------------------------------------------------------------------------
;;  Sort structures
;;----------------------------------------------------------------------------------------
IF (nsef[0] GT 0) THEN sp             =      SORT(dat_sef.TIME)
IF (nsef[0] GT 0) THEN dat_sef        = TEMPORARY(dat_sef[sp])
IF (nseb[0] GT 0) THEN sp             =      SORT(dat_seb.TIME)
IF (nseb[0] GT 0) THEN dat_seb        = TEMPORARY(dat_seb[sp])
IF (nsif[0] GT 0) THEN sp             =      SORT(dat_sif.TIME)
IF (nsif[0] GT 0) THEN dat_sif        = TEMPORARY(dat_sif[sp])
IF (nsib[0] GT 0) THEN sp             =      SORT(dat_sib.TIME)
IF (nsib[0] GT 0) THEN dat_sib        = TEMPORARY(dat_sib[sp])
;;----------------------------------------------------------------------------------------
;;  Create TPLOT handles for stacked spectra
;;----------------------------------------------------------------------------------------
fglnm          = scpref[0]+'fgl_'+[coord_mag[0],coord_gse[0]]
fghnm          = scpref[0]+'fgh_'+[coord_mag[0],coord_gse[0]]
;;--------------------------------------------
;;  EESA
;;--------------------------------------------
units          = 'flux'
bins           = REPLICATE(1b,dat_egse[0].NBINS)
num_pa         = 8L
erange         = [0e0,1e9]       ;;  Default energy bin range to include all energies [eV]
IF (tdate[0] EQ '2008-07-14') THEN erange         = [40e0,15e3]
IF (tdate[0] EQ '2008-08-19') THEN erange         = [50e0,10e3]
IF (tdate[0] EQ '2008-09-08') THEN erange         = [30e0,20e3]
name           = scpref[0]+'eesa_spec'
no_trans       = 0b
dat            = dat_egse
.compile /Users/lbwilson/Desktop/temp_idl/spectra_routines/temp_create_stacked_energy_spec_2_tplot.pro
.compile /Users/lbwilson/Desktop/temp_idl/spectra_routines/temp_create_stacked_pad_spec_2_tplot.pro
.compile /Users/lbwilson/Desktop/temp_idl/spectra_routines/temp_send_stacked_ener_pad_spec_2_tplot.pro
temp_send_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,  $
                                        ERANGE=erange,NAME=name,NO_TRANS=no_trans,$
                                        TPN_STRUC=tpn_struc_eesa
;;  Plot results
eeomni_tpn     = tnames(tpn_struc_eesa.OMNI.SPEC_TPLOT_NAME)
eepad_omni_tpn = tnames(tpn_struc_eesa.PAD.SPEC_TPLOT_NAME)
eepad_spec_tpn = tnames(tpn_struc_eesa.PAD.PAD_TPLOT_NAMES)
eeanisotro_tpn = tnames([tpn_struc_eesa.ANIS.(0),tpn_struc_eesa.ANIS.(1)])
tplot,[eeomni_tpn,eepad_omni_tpn,eepad_spec_tpn,eeanisotro_tpn],TRANGE=tr_hfa__70
tplot,[eeomni_tpn,eepad_omni_tpn,eeanisotro_tpn],TRANGE=tr_hfa__70
;;  Insert NaNs at intervals
t_insert_nan_at_interval_se,tnames(name[0]+'*'),GAP_THRESH=5d0

;;--------------------------------------------
;;  IESA [Multiple formats --> same EBIN has different energy --> Fix!]
;;--------------------------------------------
units          = 'flux'
bins           = REPLICATE(1b,dat_igse[0].NBINS)
num_pa         = 8L
erange         = [0e0,1e9]       ;;  Default energy bin range to include all energies [eV]
IF (tdate[0] EQ '2008-07-14') THEN erange         = [45e0,25e3]
zrange         = [1e-1,1e4]
name           = scpref[0]+'iesa_spec'
no_trans       = 0b
dat            = dat_igse
.compile /Users/lbwilson/Desktop/temp_idl/spectra_routines/temp_create_stacked_energy_spec_2_tplot.pro
.compile /Users/lbwilson/Desktop/temp_idl/spectra_routines/temp_create_stacked_pad_spec_2_tplot.pro
.compile /Users/lbwilson/Desktop/temp_idl/spectra_routines/temp_send_stacked_ener_pad_spec_2_tplot.pro
temp_send_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,  $
                                        ERANGE=erange,NAME=name,NO_TRANS=no_trans,$
                                        TPN_STRUC=tpn_struc_iesa
;;  compile the SPEDAS version of specplot.pro
;.compile specplot.pro
ieomni_tpn     = tnames( tpn_struc_iesa.OMNI.SPEC_TPLOT_NAME)
iepad_omni_tpn = tnames( tpn_struc_iesa.PAD.SPEC_TPLOT_NAME)
iepad_spec_tpn = tnames( tpn_struc_iesa.PAD.PAD_TPLOT_NAMES)
ieanisotro_tpn = tnames([tpn_struc_iesa.ANIS.(0),tpn_struc_iesa.ANIS.(1)])
tplot,[ieomni_tpn,iepad_omni_tpn,iepad_spec_tpn,ieanisotro_tpn],TRANGE=tr_hfa__70
tplot,[ieomni_tpn,iepad_omni_tpn,ieanisotro_tpn],TRANGE=tr_hfa__70
;;  Insert NaNs at intervals
t_insert_nan_at_interval_se,tnames(name[0]+'*'),GAP_THRESH=5d0
;;  Change to dynamic spectra because of the wildly changing energy bin values
ispec_tpns     = [ieomni_tpn,iepad_spec_tpn]
get_data,ispec_tpns[0],DATA=temp,DLIM=dlim,LIM=lim
zsub_ttle      = dlim.YSUBTITLE
ysub_ttle      = '[Energy (eV)]'
IF (tdate[0] EQ '2008-07-14') THEN yran_spec      = [10e1,25e3]
IF (tdate[0] EQ '2008-08-19') THEN yran_spec      = [40e1,25e3]
IF (tdate[0] EQ '2008-09-08') THEN yran_spec      = [50e0,20e3]
options,ispec_tpns,SPEC=1,ZLOG=1,ZTICKS=3,YRANGE=yran_spec,ZRANGE=zrange,$
                   YSUBTITLE=ysub_ttle[0],ZTITLE=zsub_ttle[0],/DEF
options,[iepad_omni_tpn[0],ieanisotro_tpn],SPEC=0,YRANGE=erange,/DEF
options,[iepad_omni_tpn[0],ieanisotro_tpn],  'ZLOG',/DEF
options,[iepad_omni_tpn[0],ieanisotro_tpn],'ZTICKS',/DEF
options,[iepad_omni_tpn[0],ieanisotro_tpn],'ZRANGE',/DEF
options,[iepad_omni_tpn[0],ieanisotro_tpn],'YRANGE',/DEF
dprint,SETVERBOSE=1

;;--------------------------------------------
;;  E-SST Burst and Full
;;--------------------------------------------
units          = 'flux'
bins           = REPLICATE(1b,dat_seb[0].NBINS)
num_pa         = 8L
erange         = [0e0,1e9]       ;;  Default energy bin range to include all energies [eV]
IF (tdate[0] EQ '2008-07-14') THEN erange         = [1e4,150e3]
IF (tdate[0] EQ '2008-08-19') THEN erange         = [1e4,300e3]
IF (tdate[0] EQ '2008-09-08') THEN erange         = [1e4,250e3]
name           = scpref[0]+'pseb_psef_spec'
no_trans       = 0b
dat            = dat_seb
dat2           = dat_sef
.compile /Users/lbwilson/Desktop/temp_idl/spectra_routines/temp_create_stacked_energy_spec_2_tplot.pro
.compile /Users/lbwilson/Desktop/temp_idl/spectra_routines/temp_create_stacked_pad_spec_2_tplot.pro
.compile /Users/lbwilson/Desktop/temp_idl/spectra_routines/temp_send_stacked_ener_pad_spec_2_tplot.pro
temp_send_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,  $
                                        ERANGE=erange,NAME=name,NO_TRANS=no_trans,$
                                        TPN_STRUC=tpn_struc_psebf,DAT_STR2=dat2

sebfomni_tp    = tnames( tpn_struc_psebf.OMNI.SPEC_TPLOT_NAME)
sebfpd_omni_tp = tnames( tpn_struc_psebf.PAD.SPEC_TPLOT_NAME)
sebfpd_spec_tp = tnames( tpn_struc_psebf.PAD.PAD_TPLOT_NAMES)
sebfanisotr_tp = tnames([tpn_struc_psebf.ANIS.(0),tpn_struc_psebf.ANIS.(1)])
tplot,[sebfomni_tp,sebfpd_omni_tp,sebfpd_spec_tp,sebfanisotr_tp],TRANGE=tr_hfa__70
tplot,[sebfomni_tp,sebfpd_omni_tp,sebfanisotr_tp],TRANGE=tr_hfa__70
;;  Insert NaNs at intervals
IF (tdate[0] NE '2008-09-08') THEN t_insert_nan_at_interval_se,tnames(name[0]+'*'),GAP_THRESH=100d0

;;--------------------------------------------
;;  I-SST Full
;;--------------------------------------------
units          = 'flux'
bins           = REPLICATE(1b,dat_sif[0].NBINS)
num_pa         = 8L
erange         = [0e0,1e9]       ;;  Default energy bin range to include all energies [eV]
IF (tdate[0] EQ '2008-07-14') THEN erange         = [1e4,500e3]
IF (tdate[0] EQ '2008-08-19') THEN erange         = [1e4,700e3]
IF (tdate[0] EQ '2008-09-08') THEN erange         = [1e4,500e3]
name           = scpref[0]+'psif_spec'
no_trans       = 0b
dat            = dat_sif
.compile /Users/lbwilson/Desktop/temp_idl/spectra_routines/temp_create_stacked_energy_spec_2_tplot.pro
.compile /Users/lbwilson/Desktop/temp_idl/spectra_routines/temp_create_stacked_pad_spec_2_tplot.pro
.compile /Users/lbwilson/Desktop/temp_idl/spectra_routines/temp_send_stacked_ener_pad_spec_2_tplot.pro
temp_send_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,  $
                                        ERANGE=erange,NAME=name,NO_TRANS=no_trans,$
                                        TPN_STRUC=tpn_struc_psif

sifomni_tp     = tnames( tpn_struc_psif.OMNI.SPEC_TPLOT_NAME)
sifpad_omni_tp = tnames( tpn_struc_psif.PAD.SPEC_TPLOT_NAME)
sifpad_spec_tp = tnames( tpn_struc_psif.PAD.PAD_TPLOT_NAMES)
sifanisotro_tp = tnames([tpn_struc_psif.ANIS.(0),tpn_struc_psif.ANIS.(1)])
tplot,[sifomni_tp,sifpad_omni_tp,sifpad_spec_tp,sifanisotro_tp],TRANGE=tr_hfa__70
tplot,[sifomni_tp,sifpad_omni_tp,sifanisotro_tp],TRANGE=tr_hfa__70
;;  Insert NaNs at intervals
t_insert_nan_at_interval_se,tnames(name[0]+'*'),GAP_THRESH=10d0

;;  Set defaults
lbw_tplot_set_defaults
;dprint,SETVERBOSE=1
tplot_options,  'XMARGIN',[20,20]
;;----------------------------------------------------------------------------------------
;;  Fix Y-Ranges and tick marks
;;----------------------------------------------------------------------------------------
eesa_sp_tpns   = tnames(scpref[0]+'eesa_spec*')
iesa_sp_tpns   = tnames(scpref[0]+'iesa_spec*')
sste_sp_tpns   = tnames(scpref[0]+'pseb_psef_spec*')
ssti_sp_tpns   = tnames(scpref[0]+'psif_spec*')

test_eesa      = (STRPOS(eesa_sp_tpns,'_para_to_perp') GE 0) OR (STRPOS(eesa_sp_tpns,'_para_to_anti') GE 0)
bad_eesa       = WHERE(test_eesa,bd_eesa,COMPLEMENT=good_eesa,NCOMPLEMENT=gd_eesa)
test_iesa      = (STRPOS(iesa_sp_tpns,'_para_to_perp') GE 0) OR (STRPOS(iesa_sp_tpns,'_para_to_anti') GE 0)
bad_iesa       = WHERE(test_iesa,bd_iesa,COMPLEMENT=good_iesa,NCOMPLEMENT=gd_iesa)
test_sste      = (STRPOS(sste_sp_tpns,'_para_to_perp') GE 0) OR (STRPOS(sste_sp_tpns,'_para_to_anti') GE 0)
bad_sste       = WHERE(test_sste,bd_sste,COMPLEMENT=good_sste,NCOMPLEMENT=gd_sste)
test_ssti      = (STRPOS(ssti_sp_tpns,'_para_to_perp') GE 0) OR (STRPOS(ssti_sp_tpns,'_para_to_anti') GE 0)
bad_ssti       = WHERE(test_ssti,bd_ssti,COMPLEMENT=good_ssti,NCOMPLEMENT=gd_ssti)

all_tpns       = {T0:eesa_sp_tpns[good_eesa],T2:sste_sp_tpns[good_sste],T3:ssti_sp_tpns[good_ssti]}
;;  Default flux(intensity) Y-Axis range to include all spectra [i.e., change after plotting]
all_ymnmx      = {T0:[1e-5,1e10],T2:[1e-8,1e3],T3:[1e-9,1e8]}
IF (tdate[0] EQ '2008-07-14') THEN all_ymnmx = {T0:[1e-1,1e7],T2:[1e-5,5e0],T3:[1e-6,1e5]}
IF (tdate[0] EQ '2008-08-19') THEN all_ymnmx = {T0:[1e-1,1e7],T2:[1e-5,3e0],T3:[1e-6,2e4]}
IF (tdate[0] EQ '2008-09-08') THEN all_ymnmx = {T0:[1e-1,1e7],T2:[1e-5,3e1],T3:[5e-6,2e4]}

n_tp           = N_TAGS(all_tpns)
def_yra        = [1d30,1d-30]
FOR jj=0L, n_tp[0] - 1L DO BEGIN                              $
  tpns0 = all_tpns.(jj)                                     & $
  IF (tpns0[0] EQ '') THEN CONTINUE                         & $
  nn      = N_ELEMENTS(tpns0)                               & $
  ymnmx   = all_ymnmx.(jj)                                  & $
  yra1    = def_yra                                         & $
  FOR kk=0L, nn[0] - 1L DO BEGIN                              $
    get_data,tpns0[kk],DATA=temp,DLIM=dlim,LIM=lim          & $
    test = FINITE(temp.Y) AND (temp.Y GT 0)                 & $
    good = WHERE(test,gd)                                   & $
    IF (gd EQ 0) THEN CONTINUE                              & $
    yra0 = [MIN(temp.Y[good],/NAN),MAX(temp.Y[good],/NAN)]  & $
    test = test_plot_axis_range(yra0,/NOMSSG)               & $
    IF (test[0] EQ 0) THEN CONTINUE                         & $
    IF (kk EQ 0) THEN yra1 = yra0 ELSE yra1 = [yra1,yra0]   & $
  ENDFOR                                                    & $
  yra1    = yra1[SORT(yra1)]                                & $
  test    = log10_tickmarks(yra1,RANGE=ymnmx,/FORCE_RA)     & $
  IF (SIZE(test,/TYPE) NE 8) THEN CONTINUE                  & $
  options,REFORM(tpns0),'YRANGE'                            & $
  options,REFORM(tpns0),YRANGE=ymnmx,YTICKNAME=test.TICKNAME,YTICKV=test.TICKV,YTICKS=test.TICKS

;;  Alter ratio TPLOT handles separately
all_tpns       = {T0:eesa_sp_tpns[bad_eesa],T1:iesa_sp_tpns[bad_iesa],T2:sste_sp_tpns[bad_sste],T3:ssti_sp_tpns[bad_ssti]}
n_tp           = N_TAGS(all_tpns)
def_yra        = [1d30,1d-30]
FOR jj=0L, n_tp[0] - 1L DO BEGIN                              $
  tpns0 = all_tpns.(jj)                                     & $
  IF (tpns0[0] EQ '') THEN CONTINUE                         & $
  nn      = N_ELEMENTS(tpns0)                               & $
  yra1    = def_yra                                         & $
  FOR kk=0L, nn[0] - 1L DO BEGIN                              $
    get_data,tpns0[kk],DATA=temp,DLIM=dlim,LIM=lim          & $
    test = FINITE(temp.Y) AND (temp.Y GT 0)                 & $
    good = WHERE(test,gd)                                   & $
    IF (gd EQ 0) THEN CONTINUE                              & $
    yra0 = [MIN(temp.Y[good],/NAN),MAX(temp.Y[good],/NAN)]  & $
    test = test_plot_axis_range(yra0,/NOMSSG)               & $
    IF (test[0] EQ 0) THEN CONTINUE                         & $
    IF (kk EQ 0) THEN yra1 = yra0 ELSE yra1 = [yra1,yra0]   & $
  ENDFOR                                                    & $
  yra1    = yra1[SORT(yra1)]                                & $
  yran    = calc_log_scale_yrange(yra1)                     & $
  IF (N_ELEMENTS(yran) NE 2) THEN CONTINUE                  & $
  test    = get_power_of_ten_ticks(yran)                    & $
  IF (SIZE(test,/TYPE) NE 8) THEN CONTINUE                  & $
  options,REFORM(tpns0),'YRANGE'                            & $
  options,REFORM(tpns0),YRANGE=yran,YTICKNAME=test.YTICKNAME,YTICKV=test.YTICKV,YTICKS=test.YTICKS
;;----------------------------------------------------------------------------------------
;;  Plot stacked spectra [overviews of foreshock]
;;----------------------------------------------------------------------------------------
br_str         = ['b','r']
lh_str         = ['l','h']
fglnm          = scpref[0]+'fg'+lh_str[0]+'_'+[coord_mag[0],coord_gse[0]]
fghnm          = scpref[0]+'fg'+lh_str[1]+'_'+[coord_mag[0],coord_gse[0]]
ni_tpns        = scpref[0]+'pei'+br_str+'_density'
Ti_tpns        = scpref[0]+'pei'+br_str+'_avgtemp'
Vi_tpns        = scpref[0]+'pei'+br_str+'_velocity_'+coord_gse[0]
Te_tpns        = scpref[0]+'pee'+br_str+'_avgtemp'
esasuffx       = ['density','avgtemp','velocity_*','magt3','ptens']
t_insert_nan_at_interval_se,tnames(scpref[0]+'pe*b_'+esasuffx),GAP_THRESH=3.5d0
;;  Define overview time range
get_data,sifomni_tp[0],DATA=temp,DLIM=dlim,LIM=lim
temp2          = trange_clip_data(temp,TRANGE=tr_jj,PREC=3)
tra_overv      = [MIN(temp2.X,/NAN),MAX(temp2.X,/NAN)] + [1,-6e0/4e0]*4d1*6d1  ;;  shrink by 40 minutes at start
;;  Define default ranges for Ni, Ti, and Te [i.e., change after plotting]
ni_yran        = [1e-2,1e2]
Ti_yran        = [1e-1,1e3]
Te_yran        = [1e-1,1e2]
IF (tdate[0] EQ '2008-07-14') THEN ni_yran = [1e-1,20e0]
IF (tdate[0] EQ '2008-07-14') THEN Ti_yran = [ 1e1,30e2]
IF (tdate[0] EQ '2008-07-14') THEN Te_yran = [ 1e0,30e1]
options,ni_tpns[1],YRANGE=ni_yran,YLOG=1,LABELS='N_ir',/DEF
options,Ti_tpns[1],YRANGE=Ti_yran,YLOG=1,LABELS='T_ir',/DEF
options,Te_tpns[1],YRANGE=Te_yran,YLOG=1,LABELS='T_er',/DEF

;;  Plot overview of foreshock [moments]
popen_str      = {PORT:1,UNITS:'inches',XSIZE:8.5,YSIZE:11.}
scu            = STRUPCASE(sc[0])
fpref          = 'THM-'+scu[0]+'_Bo-fgl_Nir_Vir_Tir_Ter_'
fnm_times      = file_name_times(tra_overv,PREC=0)
f_times        = fnm_times.F_TIME[0]+'-'+STRMID(fnm_times.F_TIME[1],11L)
fmid           = 'with_fgh_zooms_'
fnames         = fpref[0]+fmid[0]+f_times[0]

nna            = [fglnm,ni_tpns[1],Vi_tpns[1],Ti_tpns[1],Te_tpns[1]]
  tplot,nna,TRANGE=tra_overv
  time_bar,sint_fgh,COLOR=250,VARNAME=nna
  time_bar,eint_fgh,COLOR= 50,VARNAME=nna
popen,fnames[0],_EXTRA=popen_str
  tplot,nna,TRANGE=tra_overv
  time_bar,sint_fgh,COLOR=250,VARNAME=nna
  time_bar,eint_fgh,COLOR= 50,VARNAME=nna
pclose

;;  Plot overview of foreshock [OMNI fluxes]
fpref          = 'THM-'+scu[0]+'_Bo-fgl_OMNI_'+units[0]+'_peeb_peib_psebf_psif_'
fnm_times      = file_name_times(tra_overv,PREC=0)
f_times        = fnm_times.F_TIME[0]+'-'+STRMID(fnm_times.F_TIME[1],11L)
fmid           = 'with_fgh_zooms_'
fnames         = fpref[0]+fmid[0]+f_times[0]

nna            = [fglnm,eeomni_tpn[0],ieomni_tpn[0],sebfomni_tp[0],sifomni_tp[0]]
  tplot,nna,TRANGE=tra_overv
  time_bar,sint_fgh,COLOR=250,VARNAME=nna
  time_bar,eint_fgh,COLOR= 50,VARNAME=nna
popen,fnames[0],_EXTRA=popen_str
  tplot,nna,TRANGE=tra_overv
  time_bar,sint_fgh,COLOR=250,VARNAME=nna
  time_bar,eint_fgh,COLOR= 50,VARNAME=nna
pclose
;;----------------------------------------------------------------------------------------
;;  Plot stacked spectra [zooms of TIFP]
;;----------------------------------------------------------------------------------------
;;  Plot fgh zooms of TIFP [OMNI fluxes]
fpref          = 'THM-'+scu[0]+'_Bo-fgl_OMNI_'+units[0]+'_peeb_peib_psebf_psif_'
fnms_time      = file_name_times(sint_fgh,PREC=3)
fnme_time      = file_name_times(eint_fgh,PREC=3)
f_times        = fnms_time.F_TIME+'-'+STRMID(fnme_time.F_TIME,11L)
fmid           = 'TIFP_examples_'
fnames         = fpref[0]+fmid[0]+f_times
nf             = N_ELEMENTS(fnames)
nna            = [fglnm,eeomni_tpn[0],ieomni_tpn[0],sebfomni_tp[0],sifomni_tp[0]]

FOR j=0L, nf[0] - 1L DO BEGIN                                                    $
  tra0   = [sint_fgh[j],eint_fgh[j]]                                           & $
  fname0 = fnames[j]                                                           & $
    tplot,nna,TRANGE=tra0                                                      & $
    FOR k=0L, nz[0] - 1L DO time_bar,REFORM(tz_70[*,k]),COLOR=250,VARNAME=nna  & $
  popen,fname0[0],_EXTRA=popen_str                                             & $
    tplot,nna,TRANGE=tra0                                                      & $
    FOR k=0L, nz[0] - 1L DO time_bar,REFORM(tz_70[*,k]),COLOR=250,VARNAME=nna  & $
  pclose

;;  Plot fgh zooms of TIFP [{para,perp,anti} fluxes]
dir_inds       = [0L,3L,6L]
dir_midnms     = ['para','perp','anti']
fprefs         = 'THM-'+scu[0]+'_Bo-fgl_'+dir_midnms+'_'+units[0]+'_peeb_peib_psebf_psif_'
fnms_time      = file_name_times(sint_fgh,PREC=3)
fnme_time      = file_name_times(eint_fgh,PREC=3)
f_times        = fnms_time.F_TIME+'-'+STRMID(fnme_time.F_TIME,11L)
fmid           = 'TIFP_examples_'
nt             = N_ELEMENTS(f_times)
nd             = N_ELEMENTS(fprefs)
tz_70          = [[tr_slam_70],[tr_hfa__70],[tr_fb___70]]
nz             = N_ELEMENTS(tz_70[0,*])
all_tpns       = [[eepad_spec_tpn[dir_inds]],[iepad_spec_tpn[dir_inds]],[sebfpd_spec_tp[dir_inds]],[sifpad_spec_tp[dir_inds]]]
fnames         = STRARR(nt,nd)
FOR k=0L, nd[0] - 1L DO fnames[*,k] = fprefs[k]+fmid[0]+f_times


FOR j=0L, nt[0] - 1L DO BEGIN                                                      $
  tra0   = [sint_fgh[j],eint_fgh[j]]                                             & $
  FOR i=0L, nd[0] - 1L DO BEGIN                                                    $
    fname0 = fnames[j,i]                                                         & $
    nna            = [fglnm,REFORM(all_tpns[i,*])]                               & $
      tplot,nna,TRANGE=tra0                                                      & $
      FOR k=0L, nz[0] - 1L DO time_bar,REFORM(tz_70[*,k]),COLOR=250,VARNAME=nna  & $
    popen,fname0[0],_EXTRA=popen_str                                             & $
      tplot,nna,TRANGE=tra0                                                      & $
      FOR k=0L, nz[0] - 1L DO time_bar,REFORM(tz_70[*,k]),COLOR=250,VARNAME=nna  & $
    pclose



























