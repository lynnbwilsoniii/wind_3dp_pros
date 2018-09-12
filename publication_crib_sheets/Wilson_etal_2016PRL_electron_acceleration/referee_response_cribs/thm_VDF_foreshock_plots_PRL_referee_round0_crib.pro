;;  thm_VDF_foreshock_plots_PRL_referee_round0_crib.pro

;;----------------------------------------------------------------------------------------
;;  Compile relevant routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
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
;;  Constants and factors
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;  Electromagnetic
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;;  Atomic
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
;;  Astronomical
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km
;;  Energy and Temperature
f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [ J --> eV2J*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]          ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> eV2K*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]          ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> K2eV*Temp{K} = energy{eV}]

beta_fac       = 1d6*eV2J[0]*(2d0*muo[0]/1d-9/1d-9)
b_eden_fac     = (1d-9*1d-9)/(2d0*muo[0])*1d9
;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
no_load_vdfs   = 0b                    ;;  --> do load particle VDFs
;no_load_vdfs   = 1b                    ;;  --> do NOT load particle VDFs

ex_start       = SYSTIME(1)            ;;  Time the execution of all events within
@$HOME/Desktop/swidl-0.1/IDL_Stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_themis_foreshock_eVDFs_all_data_batch.pro
MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;;  Default to entire day
tr_00          = tdate[0]+'/'+['00:00:00.000','23:59:59.999']
;;  Define time range to use for foreshock overviews
IF (tdate[0] EQ '2008-07-14') THEN tr_bs_cal = time_double(tdate[0]+'/'+['11:52:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-08-19') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:00:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-09-08') THEN tr_bs_cal = time_double(tdate[0]+'/'+['16:30:00','21:32:00'])
IF (tdate[0] EQ '2008-09-16') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:20:00','20:00:00'])
IF (tdate[0] EQ '2008-07-14') THEN tra_overv = tr_bs_cal + [1,0]*3d1*6d1
;IF (tdate[0] EQ '2008-07-14') THEN tra_overv = tr_bs_cal + [-1,1]*6d1*1d1                 ;;  expand by ±10 mins
IF (tdate[0] EQ '2008-08-19') THEN tra_overv = tr_bs_cal + [1,0e0]*4d1*6d1                ;;  shrink by 40 minutes at start
IF (tdate[0] EQ '2008-09-08') THEN tra_overv = tr_bs_cal
IF (tdate[0] EQ '2008-09-16') THEN tra_overv = tr_bs_cal
;;  Define time of last (i.e., crossing at largest distance from Earth) bow shock crossings
IF (tdate[0] EQ '2008-07-14') THEN t_bs_last = time_double(tdate[0]+'/'+'12:32:18')
IF (tdate[0] EQ '2008-08-19') THEN t_bs_last = time_double(tdate[0]+'/'+'22:43:42')
IF (tdate[0] EQ '2008-09-08') THEN t_bs_last = time_double(tdate[0]+'/'+'21:18:10')
IF (tdate[0] EQ '2008-09-16') THEN t_bs_last = time_double(tdate[0]+'/'+'18:08:50')
;;  Define center-times for specific TIFP
IF (tdate[0] EQ '2008-07-14') THEN t_slam_cent = tdate[0]+'/'+['13:16:26','13:19:30']
IF (tdate[0] EQ '2008-07-14') THEN t_hfa__cent = tdate[0]+'/'+['15:21:00','22:37:22']
IF (tdate[0] EQ '2008-07-14') THEN t_fb___cent = tdate[0]+'/'+['20:03:21','21:55:45','21:58:10']

IF (tdate[0] EQ '2008-08-19') THEN t_slam_cent = tdate[0]+'/'+['21:48:55','21:53:45','22:17:35','22:18:30','22:22:30','22:37:45','22:42:48']
IF (tdate[0] EQ '2008-08-19') THEN t_hfa__cent = tdate[0]+'/'+['12:50:57','21:46:17','22:41:00']
IF (tdate[0] EQ '2008-08-19') THEN t_fb___cent = tdate[0]+'/'+['20:43:35','21:51:45']

IF (tdate[0] EQ '2008-09-08') THEN t_slam_cent = tdate[0]+'/'+['17:28:23','20:24:50','20:36:11','21:12:24','21:15:33']
IF (tdate[0] EQ '2008-09-08') THEN t_hfa__cent = tdate[0]+'/'+['17:01:41','19:13:57','20:26:44']
IF (tdate[0] EQ '2008-09-08') THEN t_fb___cent = tdate[0]+'/'+['20:25:22']

IF (tdate[0] EQ '2008-09-16') THEN t_slam_cent = tdate[0]+'/'+['00:00:00']
IF (tdate[0] EQ '2008-09-16') THEN t_hfa__cent = tdate[0]+'/'+['17:26:45']
IF (tdate[0] EQ '2008-09-16') THEN t_fb___cent = tdate[0]+'/'+['17:46:13']

tlimit,tra_overv

;;  Plot FGM data
;tplot,fgs_tpns,TRANGE=tra_overv
tplot,fgl_tpns,TRANGE=tra_overv
;tplot,fgh_tpns,TRANGE=tra_overv
;;  Show location of SLAMS, HFAs, and FBs
time_bar,t_slam_cent,COLOR=250
time_bar,t_hfa__cent,COLOR=200
time_bar,t_fb___cent,COLOR= 30
time_bar,  t_bs_last,COLOR=100
;;----------------------------------------------------------------------------------------
;;  Define TIFP specific information
;;----------------------------------------------------------------------------------------
IF (tdate[0] EQ '2008-07-14') THEN eee_slam_yn = [0b,0b]
IF (tdate[0] EQ '2008-07-14') THEN eee_hfa__yn = [0b,0b]
IF (tdate[0] EQ '2008-07-14') THEN eee_fb___yn = [0b,1b,1b]

IF (tdate[0] EQ '2008-08-19') THEN eee_slam_yn = [1b,1b,0b,1b,1b,0b,0b]
IF (tdate[0] EQ '2008-08-19') THEN eee_hfa__yn = [1b,0b,0b]
IF (tdate[0] EQ '2008-08-19') THEN eee_fb___yn = [0b,1b]

IF (tdate[0] EQ '2008-09-08') THEN eee_slam_yn = [0b,1b,0b,0b,0b]
IF (tdate[0] EQ '2008-09-08') THEN eee_hfa__yn = [1b,0b,0b]
IF (tdate[0] EQ '2008-09-08') THEN eee_fb___yn = [1b]

IF (tdate[0] EQ '2008-09-16') THEN eee_slam_yn = [0b]
IF (tdate[0] EQ '2008-09-16') THEN eee_hfa__yn = [0b]
IF (tdate[0] EQ '2008-09-16') THEN eee_fb___yn = [0b]
;;----------------------------------------------------------------------------------------
;;  Define several time windows
;;----------------------------------------------------------------------------------------
FOR j=0L, N_ELEMENTS(t_slam_cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_slam_cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_slam_70  = unix_ra[0,*] ELSE tr_slam_70  = [tr_slam_70, unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_slam_140 = unix_ra[1,*] ELSE tr_slam_140 = [tr_slam_140,unix_ra[1,*]]  & $
  IF (j EQ 0) THEN tr_slam_200 = unix_ra[2,*] ELSE tr_slam_200 = [tr_slam_200,unix_ra[2,*]]  & $
  IF (j EQ 0) THEN tr_slam_250 = unix_ra[3,*] ELSE tr_slam_250 = [tr_slam_250,unix_ra[3,*]]  & $
  IF (j EQ 0) THEN tr_slam_400 = unix_ra[4,*] ELSE tr_slam_400 = [tr_slam_400,unix_ra[4,*]]

FOR j=0L, N_ELEMENTS(t_hfa__cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_hfa__cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_hfa__70  = unix_ra[0,*] ELSE tr_hfa__70  = [tr_hfa__70, unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_hfa__140 = unix_ra[1,*] ELSE tr_hfa__140 = [tr_hfa__140,unix_ra[1,*]]  & $
  IF (j EQ 0) THEN tr_hfa__200 = unix_ra[2,*] ELSE tr_hfa__200 = [tr_hfa__200,unix_ra[2,*]]  & $
  IF (j EQ 0) THEN tr_hfa__250 = unix_ra[3,*] ELSE tr_hfa__250 = [tr_hfa__250,unix_ra[3,*]]  & $
  IF (j EQ 0) THEN tr_hfa__400 = unix_ra[4,*] ELSE tr_hfa__400 = [tr_hfa__400,unix_ra[4,*]]

FOR j=0L, N_ELEMENTS(t_fb___cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_fb___cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_fb___70  = unix_ra[0,*] ELSE tr_fb___70  = [tr_fb___70, unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_fb___140 = unix_ra[1,*] ELSE tr_fb___140 = [tr_fb___140,unix_ra[1,*]]  & $
  IF (j EQ 0) THEN tr_fb___200 = unix_ra[2,*] ELSE tr_fb___200 = [tr_fb___200,unix_ra[2,*]]  & $
  IF (j EQ 0) THEN tr_fb___250 = unix_ra[3,*] ELSE tr_fb___250 = [tr_fb___250,unix_ra[3,*]]  & $
  IF (j EQ 0) THEN tr_fb___400 = unix_ra[4,*] ELSE tr_fb___400 = [tr_fb___400,unix_ra[4,*]]
;;----------------------------------------------------------------------------------------
;;  Define relevant TPLOT handles
;;----------------------------------------------------------------------------------------
ie_mids        = ['i','e']
ch_mids        = ['c','h']
fbr_mids       = ['f','b','r']
pei_mids       = 'pe'+ie_mids[0]+fbr_mids
pee_mids       = 'pe'+ie_mids[1]+fbr_mids
moms_suffx     = ['density','avgtemp','velocity','eflux']
extr_suffx     = ['','','_'+coord_gse[0],'_'+coord_mag[0]]
fgm_eslh_mid   = 'fg'+['e','s','l','h']
latlong_suff   = ['lat','long']
beta_labs      = [ie_mids,'tot']
brat_labs      = ['scp2fgl','scw2fgl','scw2scp']
;;  Velocity moment handles
dens_ir_tpn    = scpref[0]+pei_mids[2]+'_'+moms_suffx[0]
temp_ir_tpn    = scpref[0]+pei_mids[2]+'_'+moms_suffx[1]
visw_ir_tpn    = scpref[0]+pei_mids[2]+'_'+moms_suffx[2]+extr_suffx[2]
dens_er_tpn    = scpref[0]+pee_mids[2]+'_'+moms_suffx[0]
temp_er_tpn    = scpref[0]+pee_mids[2]+'_'+moms_suffx[1]
visw_er_tpn    = scpref[0]+pee_mids[2]+'_'+moms_suffx[2]+extr_suffx[2]

vmag_ier_tpn   = scpref[0]+[pei_mids[2],pee_mids[2]]+'_'+moms_suffx[2]+extr_suffx[3]

;;  B-field handles
blat_gse_tpn   = scpref[0]+fgm_eslh_mid[2]+'_'+latlong_suff[0]+'_'+coord_gse[0]
blon_gse_tpn   = scpref[0]+fgm_eslh_mid[2]+'_'+latlong_suff[1]+'_'+coord_gse[0]

;;  plasma beta handles
beta_iet_tpn   = scpref[0]+'plasma_beta_iet'

;;  Core/Halo handles
dens_ce_tpn    = scpref[0]+ch_mids[0]+ie_mids[1]+'_'+moms_suffx[0]
dens_he_tpn    = scpref[0]+ch_mids[1]+ie_mids[1]+'_'+moms_suffx[0]
eflux_ce_tpn   = scpref[0]+ch_mids[0]+ie_mids[1]+'_'+moms_suffx[3]
eflux_he_tpn   = scpref[0]+ch_mids[1]+ie_mids[1]+'_'+moms_suffx[3]
dens_c2h_tpn   = scpref[0]+ch_mids[0]+'2'+ch_mids[1]+'_ratio__N'+ie_mids[1]+'_'+moms_suffx[0]
eflx_c2h_tpn   = scpref[0]+ch_mids[0]+'2'+ch_mids[1]+'_ratio_Ef'+ie_mids[1]+'_'+moms_suffx[3]

;;  SCM handles
pw_mid         = ['p','w']
scm_gse_tpns   = scpref[0]+'sc'+pw_mid+'_l1_cal_NoCutoff_'+coord_gse[0]

;;  B-field ratio handles
brat_tpn       = scpref[0]+'scp2fgl_scw2fgl_scw2scp_ratios_downsamp2fgl'

;;  Alter some TPLOT options
yran_all_vsw   = [-7d2,350d0]
yran_all_den   = [5d-2,30d0]
options,[dens_ir_tpn[0],dens_er_tpn[0]],YLOG=1,YMINOR=9,COLORS= 50,YRANGE=yran_all_den,/DEF
options,[visw_ir_tpn[0],visw_er_tpn[0]],YLOG=0,YRANGE=yran_all_vsw,/DEF
nna            = [dens_ir_tpn[0],dens_er_tpn[0],visw_ir_tpn[0],visw_er_tpn[0]]
options,nna,YGRIDSTYLE=2,YTICKLEN=1e0
yran_all_fglm  = [0d0,50d0]
options,fgl_tpns[0],'YRANGE'
options,fgl_tpns[0],YRANGE=yran_all_fglm,/DEF

options,scm_gse_tpns[0],YTITLE='Bscp [nT, GSE]',/DEF
options,scm_gse_tpns[1],YTITLE='Bscw [nT, GSE]',/DEF

;;----------------------------------------------------------------------------------------
;;  Calculate plasma beta and create latitude/longitude from B-field vectors
;;----------------------------------------------------------------------------------------
;;  Get data
get_data,fgl_tpns[1],DATA=t_fgl_gse,DLIMIT=dlim,LIMIT=lim
;;  Ni
get_data,dens_ir_tpn[0],DATA=t_iesa_dens,DLIMIT=dlim_ni,LIMIT=lim_ni
;;  Ti
get_data,temp_ir_tpn[0],DATA=t_iesa_temp,DLIMIT=dlim_ti,LIMIT=lim_ti
;;  Te
get_data,temp_er_tpn[0],DATA=t_eesa_temp,DLIMIT=dlim_te,LIMIT=lim_te

;;  Define params
b_t0           = t_get_struc_unix(t_fgl_gse)
b_v0           = t_fgl_gse.Y
Nit0           = t_get_struc_unix(t_iesa_dens)
Niv0           = t_iesa_dens.Y
Tit0           = t_get_struc_unix(t_iesa_temp)
Tiv0           = t_iesa_temp.Y
Tet0           = t_get_struc_unix(t_eesa_temp)
Tev0           = t_eesa_temp.Y
;;  Compute polar angles
;;    [ X, Y, Z]  <-->  [Lat.,Lon.]
;;    [+1, 0, 0]  <-->  [   0,   0]
;;    [-1, 0, 0]  <-->  [   0, 180]
;;    [+1, 1, 0]  <-->  [   0,  45]
;;    [-1,-1, 0]  <-->  [   0,-135]
;;    [+1, 0, 1]  <-->  [  45,   0]
;;    [+1, 0,-1]  <-->  [ -45,   0]
;;    [ 0,-1, 0]  <-->  [   0, -90]
;;    [ 0,-1,-1]  <-->  [ -45, -90]
cart_to_sphere,b_v0[*,0],b_v0[*,1],b_v0[*,2],b_mag,b_theta,b_phi
;;  Create TPLOT stuff
blat_str       = {X:b_t0,Y:b_theta}
blon_str       = {X:b_t0,Y:b_phi}
;;  Send to TPLOT
store_data,blat_gse_tpn[0],DATA=blat_str,DLIMIT=dlim,LIMIT=lim
store_data,blon_gse_tpn[0],DATA=blon_str,DLIMIT=dlim,LIMIT=lim
options,blat_gse_tpn[0],YTITLE='B [Lat., deg]',LABELS=latlong_suff[0],YRANGE=[-1,1]*9d1,YMINOR=5,COLORS= 50,YTICKS=4,/DEF
options,blon_gse_tpn[0],YTITLE='B [Long., deg]',LABELS=latlong_suff[1],YRANGE=[-1,1]*18d1,YMINOR=5,COLORS= 50,YTICKS=4,/DEF
options,[blat_gse_tpn[0],blon_gse_tpn[0]],YGRIDSTYLE=2,YTICKLEN=1e0

;;--------------------------------------
;;  Calculate betas
;;--------------------------------------
new_bo_it      = t_resample_tplot_struc(t_fgl_gse  ,Nit0,/IGNORE_INT)
new_ti_it      = t_resample_tplot_struc(t_iesa_temp,Nit0,/IGNORE_INT)
new_te_it      = t_resample_tplot_struc(t_eesa_temp,Nit0,/IGNORE_INT)
;;  Limit Ti ≤ 1500 eV and Te ≤ 500 eV
tie_max        = [15d2,5d2]
bad_ti         = WHERE(new_ti_it.Y GT tie_max[0],bd_ti)
bad_te         = WHERE(new_te_it.Y GT tie_max[1],bd_te)
IF (bd_ti[0] GT 0) THEN new_ti_it.Y[bad_ti] = f
IF (bd_te[0] GT 0) THEN new_te_it.Y[bad_te] = f
;;  Calculate |Bo| [nT]
new_bmag       = mag__vec(new_bo_it.Y,/NAN)
;;  Calculate betas
beta_i         = beta_fac[0]*Niv0*new_ti_it.Y/new_bmag^2
beta_e         = beta_fac[0]*Niv0*new_te_it.Y/new_bmag^2
beta_t         = beta_fac[0]*Niv0*(new_ti_it.Y + new_te_it.Y)/new_bmag^2
;;  Limit betas ≤ 100
beta_max       = 100d0
bad_bi         = WHERE(beta_i GT beta_max[0],bd_bi)
bad_be         = WHERE(beta_e GT beta_max[0],bd_be)
bad_bt         = WHERE(beta_t GT beta_max[0],bd_bt)
IF (bd_bi[0] GT 0) THEN beta_i[bad_bi] = f
IF (bd_be[0] GT 0) THEN beta_e[bad_be] = f
IF (bd_bt[0] GT 0) THEN beta_t[bad_bt] = f
beta_str       = {X:Nit0,Y:[[beta_i],[beta_e],[beta_t]]}
;;  Send to TPLOT
store_data,beta_iet_tpn[0],DATA=beta_str,DLIMIT=dlim_ni,LIMIT=lim_ni
options,beta_iet_tpn[0],YTITLE='plasma',YSUBTITLE='beta',LABELS=beta_labs,YLOG=1,$
                        YMINOR=9,COLORS=vec_col,/DEF
options,beta_iet_tpn[0],YGRIDSTYLE=2,YTICKLEN=1e0
yran_all_beta  = [5d-2,120d0]
options,beta_iet_tpn[0],'YRANGE'
options,beta_iet_tpn[0],YRANGE=yran_all_beta,/DEF

;;----------------------------------------------------------------------------------------
;;  Plot foreshock overview [Bo (lat,long), No, Vsw, beta]
;;----------------------------------------------------------------------------------------
nna            = [fgl_tpns[0],blat_gse_tpn[0],blon_gse_tpn[0],dens_ir_tpn[0],$
                  visw_ir_tpn[0],beta_iet_tpn[0]]
tplot,nna,TRANGE=tra_overv
time_bar,t_slam_cent,COLOR=250
time_bar,t_hfa__cent,COLOR=200
time_bar,t_fb___cent,COLOR= 30
;;  Save plots
popen_str      = {LANDSCAPE:1,UNITS:'inches',XSIZE:10.75,YSIZE:8.25}
scu            = STRUPCASE(sc[0])
fpref          = 'THM-'+scu[0]+'_fgl-mag-lat-long_Nibr_Vibr_betaietr_'
fnm_times      = file_name_times(tra_overv,PREC=0)
f_times        = fnm_times.F_TIME[0]+'-'+STRMID(fnm_times.F_TIME[1],11L)
fmid           = 'TIFP-centers_red-SLAMS_orange-HFA_purple-FB_cyan-BS_'
fnames         = fpref[0]+fmid[0]+f_times[0]
popen,fnames[0],_EXTRA=popen_str
  tplot,nna,TRANGE=tra_overv
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
  time_bar,  t_bs_last,COLOR=100
pclose
tplot,nna,TRANGE=tra_overv

;;  Plot but only for those with enhancements
fmid           = 'TIFP-w-enhancements_red-SLAMS_orange-HFA_purple-FB_cyan-BS_'
fnames         = fpref[0]+fmid[0]+f_times[0]
IF ((WHERE(eee_slam_yn))[0] GE 0) THEN t_gd_slam_cnt = t_slam_cent[WHERE(eee_slam_yn)] ELSE t_gd_slam_cnt = 0d0
IF ((WHERE(eee_hfa__yn))[0] GE 0) THEN t_gd_hfa__cnt = t_hfa__cent[WHERE(eee_hfa__yn)] ELSE t_gd_hfa__cnt = 0d0
IF ((WHERE(eee_fb___yn))[0] GE 0) THEN t_gd_fb___cnt = t_fb___cent[WHERE(eee_fb___yn)] ELSE t_gd_fb___cnt = 0d0
popen,fnames[0],_EXTRA=popen_str
  tplot,nna,TRANGE=tra_overv
  time_bar,t_gd_slam_cnt,COLOR=250
  time_bar,t_gd_hfa__cnt,COLOR=200
  time_bar,t_gd_fb___cnt,COLOR= 30
  time_bar,    t_bs_last,COLOR=100
pclose
tplot,nna,TRANGE=tra_overv
  time_bar,t_gd_slam_cnt,COLOR=250
  time_bar,t_gd_hfa__cnt,COLOR=200
  time_bar,t_gd_fb___cnt,COLOR= 30
  time_bar,    t_bs_last,COLOR=100


;;----------------------------------------------------------------------------------------
;;  Calculate energy flux and number density of enhanced and core
;;----------------------------------------------------------------------------------------
;;  Define structure times [i.e., (start + end)/2]
tavg_eea       = (dat_e.END_TIME + dat_e.TIME)/2d0
tavg_eia       = (dat_i.END_TIME + dat_i.TIME)/2d0
tavg_seb       = (dat_seb.END_TIME + dat_seb.TIME)/2d0
tavg_sef       = (dat_sef.END_TIME + dat_sef.TIME)/2d0
tavg_sif       = (dat_sif.END_TIME + dat_sif.TIME)/2d0
;tavg_sib       = (dat_sib.END_TIME + dat_sib.TIME)/2d0

dat_stre       = {EE:dat_e,SEB:dat_seb,SEF:dat_sef}
dat_te         = {EE:tavg_eea,SEB:tavg_seb,SEF:tavg_sef}
n_typ          = N_TAGS(dat_stre)
e_tags         = TAG_NAMES(dat_stre)
eran_core      = [0d0,2d2]                 ;;  Assume "core" extends to 200 eV
eran_halo      = [2d2,1d8]                 ;;  Assume "halo" exists above 200 eV
cee_ext        = {ENERGY:eran_core,FRACTIONAL_COUNTS:1}
hee_ext        = {ENERGY:eran_halo,FRACTIONAL_COUNTS:1}
hes_ext        = {ENERGY:eran_halo}
str_ext        = {EE:cee_ext,SEB:hee_ext,SEF:hes_ext}

;dat_astr       = {EE:dat_e,EI:dat_i,SEB:dat_seb,SEF:dat_sef,SIB:dat_sib,SIF:dat_sif}
;dat_at         = {EE:tavg_eea,EI:tavg_eia,SEB:tavg_seb,SEF:tavg_sef,SIB:tavg_sib,SIF:tavg_sif}

.compile /Users/lbwilson/Desktop/temp_idl/lbw_n_3d_new.pro
.compile /Users/lbwilson/Desktop/temp_idl/lbw_jeo_3d_new.pro
DELVAR,n_core,e_core,n_halo,e_halo
FOR k=0L, n_typ[0] - 1L DO BEGIN                                                   $
  stre = dat_stre.(k[0])                                                         & $
  time = dat_te.(k[0])                                                           & $
  nt   = N_ELEMENTS(time)                                                        & $
  nec  = 0                                                                       & $
  efc  = 0                                                                       & $
  neh  = 0                                                                       & $
  efh  = 0                                                                       & $
  FOR j=0L, nt[0] - 1L DO BEGIN                                                    $
    dat = stre[j[0]]                                                             & $
    test0 = FINITE(dat.DATA) AND FINITE(dat.ENERGY) AND FINITE(dat.DENERGY)      & $
    test1 = FINITE(dat.THETA) AND FINITE(dat.PHI)                                & $
    good  = WHERE(test0 AND test1,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)              & $
    IF (bd GT 0) THEN dat.DATA[bad]    = 0e0                                     & $
    IF (bd GT 0) THEN dat.ENERGY[bad]  = 0e0                                     & $
    IF (bd GT 0) THEN dat.DENERGY[bad] = 0e0                                     & $
    IF (bd GT 0) THEN dat.THETA[bad]   = 0e0                                     & $
    IF (bd GT 0) THEN dat.PHI[bad]     = 0e0                                     & $
    IF (FINITE(dat.SC_POT[0]) EQ 0) THEN dat.SC_POT = 0e0                        & $
    IF (k[0] EQ 0) THEN extc = str_ext.(0) ELSE extc = 0                         & $
    IF (k[0] EQ 0) THEN exth = str_ext.(1) ELSE exth = str_ext.(2)               & $
    IF (k[0] EQ 0) THEN nc0 = lbw_n_3d_new(dat,_EXTRA=extc) ELSE nc0 = d         & $
    IF (k[0] EQ 0) THEN ec0 = lbw_jeo_3d_new(dat,_EXTRA=extc) ELSE ec0 = d       & $
    nh0 = lbw_n_3d_new(dat,_EXTRA=exth)                                          & $
    eh0 = lbw_jeo_3d_new(dat,_EXTRA=exth)                                        & $
    IF (j[0] EQ 0) THEN nec = nc0 ELSE nec = [nec,nc0]                           & $
    IF (j[0] EQ 0) THEN efc = ec0 ELSE efc = [efc,ec0]                           & $
    IF (j[0] EQ 0) THEN neh = nh0 ELSE neh = [neh,nh0]                           & $
    IF (j[0] EQ 0) THEN efh = eh0 ELSE efh = [efh,eh0]                           & $
  ENDFOR                                                                         & $
  str_element,n_core,e_tags[k[0]],nec,/ADD_REPLACE                               & $
  str_element,e_core,e_tags[k[0]],efc,/ADD_REPLACE                               & $
  str_element,n_halo,e_tags[k[0]],neh,/ADD_REPLACE                               & $
  str_element,e_halo,e_tags[k[0]],efh,/ADD_REPLACE

;;  Get data for dummy limits structures
;;  Ni
get_data,dens_ir_tpn[0],DATA=t_iesa_dens,DLIMIT=dlim_ni,LIMIT=lim_ni

;;  Define dummy TPLOT structures
ee_time        = dat_te.EE
sp             = SORT(ee_time)
ee_time        = TEMPORARY(ee_time[sp])
ec_dens        = n_core.EE[sp]
ec_eflx        = e_core.EE[sp]
eh_dens        = n_halo.EE[sp]
eh_eflx        = e_halo.EE[sp]
;;    Core
nsc_struc      = {X:ee_time,Y:ec_dens}
efc_struc      = {X:ee_time,Y:ec_eflx}
;;    Halo
dumb_neh       = {X:ee_time,Y:eh_dens}               ;;  ESA
dumb_eeh       = {X:ee_time,Y:eh_eflx}               ;;  ESA
ttsh           = [dat_te.SEB,dat_te.SEF]             ;;  SST
nnsh           = [n_halo.SEB,n_halo.SEF]
efsh           = [e_halo.SEB,e_halo.SEF]
sp             = SORT(ttsh)
ttsh           = TEMPORARY(ttsh[sp])
nnsh           = TEMPORARY(nnsh[sp])
efsh           = TEMPORARY(efsh[sp])
dumb_nsh       = {X:ttsh,Y:nnsh}                     ;;  SST
dumb_esh       = {X:ttsh,Y:efsh}                     ;;  SST
new_nsh        = t_resample_tplot_struc(dumb_nsh,ee_time,/IGNORE_INT)
new_esh        = t_resample_tplot_struc(dumb_esh,ee_time,/IGNORE_INT)
;;  Combine ESA and SST results for halo
dumb_nh2d      = [[dumb_neh.Y],[new_nsh.Y]]
nsh_tot        = TOTAL(dumb_nh2d,2L,/NAN)            ;;  [# cm^(-3)]
nsht_2d        = nsh_tot # REPLICATE(1d0,2L)
nweight        = dumb_nh2d/nsht_2d
dumb_eh2d      = [[dumb_eeh.Y],[new_esh.Y]]
efh_tot        = TOTAL(dumb_eh2d,2L,/NAN)            ;;  [eV cm^(-2) s^(-1)]
nsh_struc      = {X:ee_time,Y:nsh_tot}
efh_struc      = {X:ee_time,Y:efh_tot}
;;  Send to TPLOT
store_data, dens_ce_tpn[0],DATA=nsc_struc,DLIMIT=dlim_ni,LIMIT=lim_ni
store_data, dens_he_tpn[0],DATA=nsh_struc,DLIMIT=dlim_ni,LIMIT=lim_ni
store_data,eflux_ce_tpn[0],DATA=efc_struc,DLIMIT=dlim_ni,LIMIT=lim_ni
store_data,eflux_he_tpn[0],DATA=efh_struc,DLIMIT=dlim_ni,LIMIT=lim_ni
nn0            = [ dens_ce_tpn[0], dens_he_tpn[0], eflux_ce_tpn[0], eflux_he_tpn[0]]
options,nn0,'YRANGE'
options,nn0,'YRANGE',/DEF

yran_all_nec   = [5d-2,30d0]
yran_all_neh   = [5d-3, 5d0]
yran_all_efx   = [ 1d9,2d12]
yttls_dens     = 'Ne'+ch_mids+' [cm^(-3)]'
yttls_eflx     = 'Efe'+ch_mids+' [eV cm^(-2) s^(-1)]'
ecmx_string    = num2int_str(eran_core)
ysubs_all      = '[Ec < '+ecmx_string[1]+' eV]'
;ysubs_all      = '[E '+['<','>']+' '+ecmx_string[1]+' eV]'
options,nn0[0],MAX_VALUE=yran_all_nec[1],MIN_VALUE=yran_all_nec[0],YRANGE=yran_all_nec,YTITLE=yttls_dens[0],YSUBTITLE=ysubs_all[0],/DEF
options,nn0[1],MAX_VALUE=yran_all_neh[1],MIN_VALUE=yran_all_neh[0],YRANGE=yran_all_neh,YTITLE=yttls_dens[1],YSUBTITLE=ysubs_all[0],/DEF
options,nn0[2],MAX_VALUE=yran_all_efx[1],MIN_VALUE=yran_all_efx[0],YRANGE=yran_all_efx,YTITLE=yttls_eflx[0],YSUBTITLE=ysubs_all[0],/DEF
options,nn0[3],MAX_VALUE=yran_all_efx[1],MIN_VALUE=yran_all_efx[0],YRANGE=yran_all_efx,YTITLE=yttls_eflx[1],YSUBTITLE=ysubs_all[0],/DEF
;;----------------------------------------------------------------------------------------
;;  Plot foreshock overview [Bo (lat,long), Ne, Nce, Nhe, Efce, Ehce]
;;----------------------------------------------------------------------------------------
nna            = [fgl_tpns[0],blat_gse_tpn[0],blon_gse_tpn[0],dens_er_tpn[0],$
                  dens_ce_tpn[0], dens_he_tpn[0], eflux_ce_tpn[0], eflux_he_tpn[0]]
tplot,nna,TRANGE=tra_overv
time_bar,t_slam_cent,COLOR=250
time_bar,t_hfa__cent,COLOR=200
time_bar,t_fb___cent,COLOR= 30
;;----------------------------------------------------------------------------------------
;;  Calculate ratios of Halo-to-Core eflux and density
;;----------------------------------------------------------------------------------------
;;  Get data for dummy limits structures
;;  Nce
get_data, dens_ce_tpn[0],DATA=t_nec_str,DLIMIT=dlim_nec,LIMIT=lim_nec
;;  Efce
get_data,eflux_ce_tpn[0],DATA=t_efc_str,DLIMIT=dlim_efc,LIMIT=lim_efc

ne_h2c_rat     = nsh_struc.Y/nsc_struc.Y
ef_h2c_rat     = efh_struc.Y/efc_struc.Y
;;  Send to TPLOT
ne_rat_str     = {X:ee_time,Y:ne_h2c_rat}
ef_rat_str     = {X:ee_time,Y:ef_h2c_rat}
store_data,dens_c2h_tpn[0],DATA=ne_rat_str,DLIMIT=dlim_nec,LIMIT=lim_nec
store_data,eflx_c2h_tpn[0],DATA=ef_rat_str,DLIMIT=dlim_efc,LIMIT=lim_efc
nn0            = [dens_c2h_tpn[0],eflx_c2h_tpn[0]]
options,nn0,   'YRANGE'
options,nn0,'MIN_VALUE'
options,nn0,'MAX_VALUE'
options,nn0,   'YRANGE',/DEF
options,nn0,'MIN_VALUE',/DEF
options,nn0,'MAX_VALUE',/DEF

yran_all_nrat  = [1d-3,1.2d0]
yran_all_erat  = [1d-1,20d0]
yttls_rats     = ['Ne','Efe']+' [Halo/Core]'
options,nn0[0],MAX_VALUE=yran_all_nrat[1]*2,MIN_VALUE=yran_all_nrat[0],YRANGE=yran_all_nrat,YTITLE=yttls_rats[0],YSUBTITLE=ysubs_all[0],/DEF
options,nn0[1],MAX_VALUE=yran_all_erat[1]*2,MIN_VALUE=yran_all_erat[0],YRANGE=yran_all_erat,YTITLE=yttls_rats[1],YSUBTITLE=ysubs_all[0],/DEF

;;----------------------------------------------------------------------------------------
;;  Plot foreshock overview [Bo (lat,long), Ne, Nce, Nhe, Efce, Ehce]
;;----------------------------------------------------------------------------------------
nna            = [fgl_tpns[0],blat_gse_tpn[0],blon_gse_tpn[0],dens_er_tpn[0],$
                  dens_ce_tpn[0],dens_he_tpn[0],dens_c2h_tpn[0],eflx_c2h_tpn[0]]
tplot,nna,TRANGE=tra_overv
time_bar,t_slam_cent,COLOR=250
time_bar,t_hfa__cent,COLOR=200
time_bar,t_fb___cent,COLOR= 30

;;----------------------------------------------------------------------------------------
;;  Plot ±250 s window about each TIFP type [Bo (lat,long), Nhe/Nce, Ehce/Efce]
;;----------------------------------------------------------------------------------------
nna            = [fgl_tpns[0],blat_gse_tpn[0],blon_gse_tpn[0],$
                  dens_c2h_tpn[0],eflx_c2h_tpn[0]]
tplot,nna,TRANGE=tra_overv

;;  Define structure containing logic [TRUE = energetic electron enhancement observed]
e_enhanced_str = {T0:eee_slam_yn,T1:eee_hfa__yn,T2:eee_fb___yn}
;;  Define ±250 s window about each TIFP type
tz_250_str     = {T0:tr_slam_250,T1:tr_hfa__250,T2:tr_fb___250}
nt             = N_TAGS(tz_250_str)
tags           = TAG_NAMES(tz_250_str)
fpref          = 'THM-'+scu[0]+'_fgl-mag-lat-long_Ne-rat-h2c_eflux-rat-h2c_'
fmid           = 'TIFP_red-SLAMS_orange-HFA_purple-FB_cyan-BS_'
;;  Define relevant TRANGEs
FOR j=0L, nt[0] - 1L DO BEGIN                                                 $
  tras0   = tz_250_str.(j)                                                  & $
  logic   = e_enhanced_str.(j)                                              & $
  good    = WHERE(logic,gd)                                                 & $
  IF (gd EQ 0) THEN CONTINUE                                                & $
  FOR k=0L, gd - 1L DO BEGIN                                                  $
    tra1       = REFORM(tras0[good[k[0]],*])                                & $
    fnm_times  = file_name_times(tra1,PREC=0)                               & $
    f_times    = fnm_times.F_TIME[0]+'-'+STRMID(fnm_times.F_TIME[1],11L)    & $
    fnames     = fpref[0]+fmid[0]+f_times[0]                                & $
      tplot,nna,TRANGE=tra1                                                 & $
    popen,fnames[0],_EXTRA=popen_str                                        & $
      tplot,nna,TRANGE=tra1                                                 & $
      time_bar,t_gd_slam_cnt,COLOR=250                                      & $
      time_bar,t_gd_hfa__cnt,COLOR=200                                      & $
      time_bar,t_gd_fb___cnt,COLOR= 30                                      & $
      time_bar,    t_bs_last,COLOR=100                                      & $
    pclose



;;  Define ±70 s window about each TIFP type
tz__70_str     = {T0:tr_slam_70,T1:tr_hfa__70,T2:tr_fb___70}
nt             = N_TAGS(tz__70_str)
tags           = TAG_NAMES(tz__70_str)
fpref          = 'THM-'+scu[0]+'_fgl-mag-lat-long_Ne-rat-h2c_eflux-rat-h2c_'
fmid           = 'TIFP_red-SLAMS_orange-HFA_purple-FB_cyan-BS_'
;;  Define relevant TRANGEs
FOR j=0L, nt[0] - 1L DO BEGIN                                                 $
  tras0   = tz__70_str.(j)                                                  & $
  logic   = e_enhanced_str.(j)                                              & $
  good    = WHERE(logic,gd)                                                 & $
  IF (gd EQ 0) THEN CONTINUE                                                & $
  FOR k=0L, gd - 1L DO BEGIN                                                  $
    tra1       = REFORM(tras0[good[k[0]],*])                                & $
    fnm_times  = file_name_times(tra1,PREC=0)                               & $
    f_times    = fnm_times.F_TIME[0]+'-'+STRMID(fnm_times.F_TIME[1],11L)    & $
    fnames     = fpref[0]+fmid[0]+f_times[0]                                & $
      tplot,nna,TRANGE=tra1                                                 & $
    popen,fnames[0],_EXTRA=popen_str                                        & $
      tplot,nna,TRANGE=tra1                                                 & $
      time_bar,t_gd_slam_cnt,COLOR=250                                      & $
      time_bar,t_gd_hfa__cnt,COLOR=200                                      & $
      time_bar,t_gd_fb___cnt,COLOR= 30                                      & $
      time_bar,    t_bs_last,COLOR=100                                      & $
    pclose


;;----------------------------------------------------------------------------------------
;;  Calculate magnetic field energy density of Bo and ∂B
;;    Use the following:  Bo = fgl, dB = scp, ∂B = scw
;;----------------------------------------------------------------------------------------
;;  Bo
get_data,    fgl_tpns[1],DATA=t_fgl_gse,DLIMIT=dlim,LIMIT=lim
;;  dB
get_data,scm_gse_tpns[0],DATA=t_scp_gse,DLIMIT=dlim_scp,LIMIT=lim_scp
;;  ∂B
get_data,scm_gse_tpns[1],DATA=t_scw_gse,DLIMIT=dlim_scw,LIMIT=lim_scw

;;  Define params
bo_t0          = t_get_struc_unix(t_fgl_gse)         ;;  fgl
bo_v0          = t_fgl_gse.Y
b__t0          = t_get_struc_unix(t_scp_gse)         ;;  scp
b__v0          = t_scp_gse.Y
db_t0          = t_get_struc_unix(t_scw_gse)         ;;  scw
db_v0          = t_scw_gse.Y
;;  Calculate magnetic field energy density
bo_mg          = mag__vec(bo_v0,/NAN)                ;;  fgl
b__mg          = mag__vec(b__v0,/NAN)                ;;  scp
db_mg          = mag__vec(db_v0,/NAN)                ;;  scw
bo_eden        = b_eden_fac[0]*(bo_mg*bo_mg)         ;;  fgl  [nJ m^(-3)]
b__eden        = b_eden_fac[0]*(b__mg*b__mg)         ;;  scp  [nJ m^(-3)]
db_eden        = b_eden_fac[0]*(db_mg*db_mg)         ;;  scw  [nJ m^(-3)]
;;  resample to fgl and scw times for ratios
new_b__bot     = t_resample_tplot_struc({X:b__t0,Y:b__eden},bo_t0,/IGNORE_INT,/NO_EXTRAPOLATE)
new_bo_dbt     = t_resample_tplot_struc({X:bo_t0,Y:bo_eden},db_t0,/IGNORE_INT,/NO_EXTRAPOLATE)
new_b__dbt     = t_resample_tplot_struc({X:b__t0,Y:b__eden},db_t0,/IGNORE_INT,/NO_EXTRAPOLATE)
;;  Calculate Ratios
b__2_bo_eden   = new_b__bot.Y/bo_mg                                 ;;  scp/fgl
;b__2_bo_eden   = new_b__dbt.Y/new_bo_dbt.Y
db_2_bo_eden   = db_eden/new_bo_dbt.Y                               ;;  scw/fgl
db_2_b__eden   = db_eden/new_b__dbt.Y                               ;;  scw/scp
;;  Avg. then reduce resolution
nwdth          = 8192d0/128d0
b_2bo_eden_sm  = b__2_bo_eden                                       ;;  scp/fgl
;b_2bo_eden_sm  = SMOOTH(b__2_bo_eden,nwdth[0],/NAN,/EDGE_TRUNCATE)  ;;  scp/fgl
db2bo_eden_sm  = SMOOTH(db_2_bo_eden,nwdth[0],/NAN,/EDGE_TRUNCATE)  ;;  scw/fgl
db2b__eden_sm  = SMOOTH(db_2_b__eden,nwdth[0],/NAN,/EDGE_TRUNCATE)  ;;  scw/scp
new_b__bot     = {X:bo_t0,Y:b_2bo_eden_sm}
;new_b__bot     = t_resample_tplot_struc({X:db_t0,Y:b_2bo_eden_sm},bo_t0,/IGNORE_INT)
;new_bo_bot     = t_resample_tplot_struc({X:db_t0,Y:db2bo_eden_sm},bo_t0,/IGNORE_INT)
;new_db_bot     = t_resample_tplot_struc({X:db_t0,Y:db2b__eden_sm},bo_t0,/IGNORE_INT)
new_bo_bot     = t_resample_tplot_struc({X:db_t0,Y:db2bo_eden_sm},bo_t0,/NO_EXTRAPOLATE)
new_db_bot     = t_resample_tplot_struc({X:db_t0,Y:db2b__eden_sm},bo_t0,/NO_EXTRAPOLATE)
all_brats      = [[new_b__bot.Y],[new_bo_bot.Y],[new_db_bot.Y]]
;;  Make sure SCM data not falsely interpolated to regions where data does not exist
sei_scp        = t_interval_find(b__t0,GAP_THRESH=3d0/128d0,/NAN)
sei_scw        = t_interval_find(db_t0,GAP_THRESH=3d0/8192d0,/NAN)
stt_scp        = b__t0[sei_scp[*,0]]
ent_scp        = b__t0[sei_scp[*,1]]
stt_scw        = db_t0[sei_scw[*,0]]
ent_scw        = db_t0[sei_scw[*,1]]
n_scp          = N_ELEMENTS(sei_scp[*,0])
n_scw          = N_ELEMENTS(sei_scw[*,0])
DELVAR,test,test0
FOR k=0L, n_scp[0] - 1L DO BEGIN                                                    $
  test0 = (bo_t0 GE stt_scp[k]) AND (bo_t0 LE ent_scp[k])                         & $
  IF (k EQ 0) THEN test = test0 ELSE test = test OR test0

test_scp       = test
good_scp       = WHERE(test_scp,gd_scp,COMPLEMENT=bad_scp,NCOMPLEMENT=bd_scp)
IF (bd_scp[0] GT 0) THEN all_brats[bad_scp,0] = f

DELVAR,test,test0
FOR k=0L, n_scw[0] - 1L DO BEGIN                                                    $
  test0 = (bo_t0 GE stt_scw[k]) AND (bo_t0 LE ent_scw[k])                         & $
  IF (k EQ 0) THEN test = test0 ELSE test = test OR test0

test_scw       = test
good_scw       = WHERE(test_scw,gd_scw,COMPLEMENT=bad_scw,NCOMPLEMENT=bd_scw)
IF (bd_scw[0] GT 0) THEN all_brats[bad_scw,1:2] = f
;IF (bd_scw[0] GT 0) THEN all_brats[bad_scw,2] = f
;;  Check for negative values (i.e., magnitudes must be ≥ 0)
bad            = WHERE(all_brats LE 0,bd)
IF (bd[0] GT 0) THEN all_brats[bad] = f
;;  Check for NaNs in fgl data (i.e., magnitudes must be ≥ 0)
good           = WHERE(FINITE(bo_mg),gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
IF (bd[0] GT 0) THEN all_brats[bad,0:1] = f

PRINT,';;',MIN(all_brats,/NAN),MAX(all_brats,/NAN),MEAN(all_brats,/NAN),STDDEV(all_brats,/NAN)

;;  Send results to TPLOT
brat_struc     = {X:bo_t0,Y:all_brats}
store_data,    brat_tpn[0],DATA=brat_struc,DLIMIT=dlim,LIMIT=lim
yran_all_brat  = [1d-6,5d-2]
options,brat_tpn[0],YTITLE='B/Bo',YSUBTITLE='[Ratios]',LABELS=brat_labs,YLOG=1,$
                        YMINOR=9,COLORS=vec_col,YRANGE=yran_all_brat,/DEF


;;----------------------------------------------------------------------------------------
;;  Plot ±70 s window about each TIFP type [Bo (mag,gse), scp, scw, |∂B^j|/|Bo|]
;;----------------------------------------------------------------------------------------
nna            = [fgl_tpns,scm_gse_tpns,brat_tpn[0]]
  tplot,nna,TRANGE=tra_overv
  time_bar,t_gd_slam_cnt,COLOR=250
  time_bar,t_gd_hfa__cnt,COLOR=200
  time_bar,t_gd_fb___cnt,COLOR= 30
  time_bar,    t_bs_last,COLOR=100


;;  Define structure containing logic [TRUE = energetic electron enhancement observed]
e_enhanced_str = {T0:eee_slam_yn,T1:eee_hfa__yn,T2:eee_fb___yn}
;;  Define ±70 s window about each TIFP type
tz__70_str     = {T0:tr_slam_70,T1:tr_hfa__70,T2:tr_fb___70}
nt             = N_TAGS(tz__70_str)
tags           = TAG_NAMES(tz__70_str)
fpref          = 'THM-'+scu[0]+'_Bo-fgl-mag-gse_B-scp_dB-scw_B2Bo-dB2Bo-dB2B-ratios_DS2fgl_'
fmid           = 'TIFP_red-SLAMS_orange-HFA_purple-FB_cyan-BS_'
yesno          = ['N','Y']
;yesno          = 'with'+['','out']+' enhancements'
;tbar_tstr      = {SLAMS:t_slam_cent,HFA:t_hfa__cent,FB:t_fb___cent,BS:t_bs_last}
;tbar_cols      = [250,200, 30,100]
tbar_tstr      = {SLAMS:time_double(t_slam_cent),HFA:time_double(t_hfa__cent),FB:time_double(t_fb___cent)}
tbar_cols      = [250,200, 30]
ntbar          = N_ELEMENTS(tbar_cols)
tbar_gstr      = {SLAMS:t_gd_slam_cnt,HFA:t_gd_hfa__cnt,FB:t_gd_fb___cnt}
xystr          = {NORMAL:1,CHARSIZE:2.}

FOR j=0L, nt[0] - 1L DO BEGIN                                                                   $
  tras0   = tz__70_str.(j)                                                                    & $
  nd      = N_ELEMENTS(tras0[*,0])                                                            & $
  ntvars  = 0                                                                                 & $
  FOR k=0L, nd[0] - 1L DO BEGIN                                                                 $
    tra1       = REFORM(tras0[k[0],*])                                                        & $
    fnm_times  = file_name_times(tra1,PREC=0)                                                 & $
    f_times    = fnm_times.F_TIME[0]+'-'+STRMID(fnm_times.F_TIME[1],11L)                      & $
    fnames     = fpref[0]+fmid[0]+f_times[0]                                                  & $
    dumb       = TEMPORARY(ntvars)                                                            & $
      tplot,nna,TRANGE=tra1,NEW_TVARS=ntvars                                                  & $
      time_bar,  t_bs_last,COLOR=100                                                          & $
      tsets    = ntvars.SETTINGS                                                              & $
      xwinn    = tsets.X[0].WINDOW                                                            & $
      xscle    = tsets.X[0].S                                                                 & $
      toffs    = struct_value(tsets,'TIME_OFFSET',DEFAULT=0d0)                                & $
      yposi    = tsets.Y[0].WINDOW[1]                                                         & $
      ydiff    = (1e0 - yposi[0])/2d0                                                         & $
      yposi    = (yposi[0] + ydiff[0]) < 1e0                                                  & $
      FOR i=0L, ntbar[0] - 1L DO BEGIN                                                          $
        logic  = e_enhanced_str.(i[0])                                                        & $
        xposi0 = tbar_tstr.(i[0])                                                             & $
        time_bar,xposi0,COLOR=tbar_cols[i[0]]                                                 & $
        strout = (yesno)[logic]                                                               & $
        xposid = xposi0 - toffs[0]                                                            & $
        xposi  = xscle[0] + xscle[1]*xposid                                                   & $
        ngx    = N_ELEMENTS(xposi)                                                            & $
        FOR gi=0L, ngx[0] - 1L DO BEGIN                                                         $
          XYOUTS,xposi[gi[0]],yposi[0],strout[gi[0]],_EXTRA=xystr,COLOR=tbar_cols[i[0]]       & $
        ENDFOR                                                                                & $
      ENDFOR                                                                                  & $
    dumb       = TEMPORARY(ntvars)                                                            & $
    popen,fnames[0],_EXTRA=popen_str                                                          & $
      tplot,nna,TRANGE=tra1,NEW_TVARS=ntvars                                                  & $
      time_bar,  t_bs_last,COLOR=100                                                          & $
      tsets    = ntvars.SETTINGS                                                              & $
      xwinn    = tsets.X[0].WINDOW                                                            & $
      xscle    = tsets.X[0].S                                                                 & $
      toffs    = struct_value(tsets,'TIME_OFFSET',DEFAULT=0d0)                                & $
      yposi    = tsets.Y[0].WINDOW[1]                                                         & $
      ydiff    = (1e0 - yposi[0])/2d0                                                         & $
      yposi    = (yposi[0] + ydiff[0]) < 1e0                                                  & $
      FOR i=0L, ntbar[0] - 1L DO BEGIN                                                          $
        logic  = e_enhanced_str.(i[0])                                                        & $
        xposi0 = tbar_tstr.(i[0])                                                             & $
        time_bar,xposi0,COLOR=tbar_cols[i[0]]                                                 & $
        strout = (yesno)[logic]                                                               & $
        xposid = xposi0 - toffs[0]                                                            & $
        xposi  = xscle[0] + xscle[1]*xposid                                                   & $
        ngx    = N_ELEMENTS(xposi)                                                            & $
        FOR gi=0L, ngx[0] - 1L DO BEGIN                                                         $
          XYOUTS,xposi[gi[0]],yposi[0],strout[gi[0]],_EXTRA=xystr,COLOR=tbar_cols[i[0]]       & $
        ENDFOR                                                                                & $
      ENDFOR                                                                                  & $
    pclose

;;----------------------------------------------------------------------------------------
;;  Get dB/Bo value stats within ±30 s about each TIFP type
;;----------------------------------------------------------------------------------------
;;  dB/Bo
get_data,brat_tpn[0],DATA=t_brat,DLIMIT=dlim_brat,LIMIT=lim_brat
;;  Define params
dbbo_t         = t_get_struc_unix(t_brat)         ;;  Unix times
dbbo_v         = t_brat.Y                         ;;  [scp/fgl, scw/fgl, scw/scp]
;;  Define structure containing logic [TRUE = energetic electron enhancement observed]
e_enhanced_str = {T0:eee_slam_yn,T1:eee_hfa__yn,T2:eee_fb___yn}
;;  Define time window range [s]
dtwin          = 30d0
t_cents        = t_slam_cent
FOR j=0L, N_ELEMENTS(t_cents) - 1L DO BEGIN                               $
  unix_0   = time_double(t_cents[j])                                    & $
  unix_ra  = TRANSPOSE(unix_0[0] + [-1,1]*dtwin[0])                     & $
  IF (j EQ 0) THEN tran_30  = unix_ra ELSE tran_30 = [tran_30,unix_ra]
tr_slam_30     = tran_30

t_cents        = t_hfa__cent
FOR j=0L, N_ELEMENTS(t_cents) - 1L DO BEGIN                               $
  unix_0   = time_double(t_cents[j])                                    & $
  unix_ra  = TRANSPOSE(unix_0[0] + [-1,1]*dtwin[0])                     & $
  IF (j EQ 0) THEN tran_30  = unix_ra ELSE tran_30 = [tran_30,unix_ra]
tr_hfa__30     = tran_30

t_cents        = t_fb___cent
FOR j=0L, N_ELEMENTS(t_cents) - 1L DO BEGIN                               $
  unix_0   = time_double(t_cents[j])                                    & $
  unix_ra  = TRANSPOSE(unix_0[0] + [-1,1]*dtwin[0])                     & $
  IF (j EQ 0) THEN tran_30  = unix_ra ELSE tran_30 = [tran_30,unix_ra]
tr_fb___30     = tran_30
;;  Define ±30 s window about each TIFP type
tz__30_str     = {T0:tr_slam_30,T1:tr_hfa__30,T2:tr_fb___30}
nt             = N_TAGS(tz__30_str)
tbar_tstr      = {SLAMS:time_double(t_slam_cent),HFA:time_double(t_hfa__cent),FB:time_double(t_fb___cent)}
fd_tags        = ['SLM','HFA','FSB']
yesno          = ['N','Y']
stat_tags      = ['MIN','MAX','AVG','STD','MED','YESNO']
pref_out       = ';;  '+brat_labs+' '
head_out       = ';;            YYYY-MM-DD/hh:mm:ss.xxx        '+STRJOIN(stat_tags,'          ',/SINGLE)
dumb3          = REPLICATE(d,3)
mform          = '(a18,a23,5e13.5,"        ",a1)'

DELVAR,stat_tr0,stat_tr
FOR j=0L, nt[0] - 1L DO BEGIN                                                                   $
  tras0   = tz__30_str.(j)                                                                    & $
  tcentd  = tbar_tstr.(j)                                                                     & $
  tcents  = time_string(tcentd,PREC=3)                                                        & $
  nd      = N_ELEMENTS(tras0[*,0])                                                            & $
  ktags   = 'T'+num2int_str(LINDGEN(nd[0]))                                                   & $
  logic   = e_enhanced_str.(j)                                                                & $
  strout  = (yesno)[logic]                                                                    & $
  preftyp = pref_out+fd_tags[j]+':  '                                                         & $
  stat_tr0 = 0                                                                                & $
  FOR k=0L, nd[0] - 1L DO BEGIN                                                                 $
    mins       = dumb3                                                                        & $
    maxs       = dumb3                                                                        & $
    avgs       = dumb3                                                                        & $
    stds       = dumb3                                                                        & $
    meds       = dumb3                                                                        & $
    tra1       = REFORM(tras0[k[0],*])                                                        & $
    clipped    = trange_clip_data(t_brat,TRANGE=tra1,PREC=3)                                  & $
    test       = (SIZE(clipped,/TYPE) EQ 8)                                                   & $
    IF (test[0]) THEN mins = MIN(clipped.Y,/NAN,DIMENSION=1,MAX=maxs)                         & $
    IF (test[0]) THEN avgs = MEAN(clipped.Y,/NAN,DIMENSION=1)                                 & $
    IF (test[0]) THEN stds = STDDEV(clipped.Y,/NAN,DIMENSION=1)                               & $
    IF (test[0]) THEN meds = MEDIAN(clipped.Y,/DOUBLE,DIMENSION=1)                            & $
    stats      = CREATE_STRUCT(stat_tags,mins,maxs,avgs,stds,meds,strout[k])                  & $
    str_element,stat_tr0,ktags[k],stats,/ADD_REPLACE                                          & $
    PRINT,head_out[0]                                                                         & $
    FOR i=0L, 2L DO BEGIN                                                                       $
      xarr = FLOAT([mins[i],maxs[i],avgs[i],stds[i],meds[i]])                                 & $
      PRINT,preftyp[i],tcents[k],xarr,strout[k],FORMAT=mform[0]                              & $
;      PRINT,pref_out[i],tcents[k],xarr,strout[k],FORMAT=mform[0]                              & $
;      PRINT,pref_out[i],tcents[k],xarr[0],xarr[1],xarr[2],xarr[3],xarr[4],'      ',strout[k]  & $
    ENDFOR                                                                                    & $
  ENDFOR                                                                                      & $
  str_element,stat_tr,fd_tags[j],stat_tr0,/ADD_REPLACE


;;========================================================================================
;;========================================================================================
;;  Yes Only
;;========================================================================================
;;========================================================================================

;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-07-14/21:55:45.000  6.56169e-06  1.10093e-03  1.64888e-04  2.03040e-04  9.87113e-05        Y
;;  scp2fgl FSB:  2008-07-14/21:58:10.000  8.65683e-06  6.69557e-03  3.50931e-04  6.16754e-04  1.27029e-04        Y
;;  scp2fgl SLM:  2008-08-19/21:48:55.000  3.73961e-05  1.72627e-03  1.84083e-04  1.50359e-04  1.48661e-04        Y
;;  scp2fgl SLM:  2008-08-19/21:53:45.000  1.25402e-06  1.43503e-03  3.01448e-04  2.33035e-04  2.46856e-04        Y
;;  scp2fgl SLM:  2008-08-19/22:18:30.000  9.43987e-06  1.82909e-03  2.28558e-04  2.26788e-04  1.66997e-04        Y
;;  scp2fgl SLM:  2008-08-19/22:22:30.000  7.58907e-06  6.71081e-03  4.14838e-04  8.44205e-04  1.56410e-04        Y
;;  scp2fgl HFA:  2008-08-19/12:50:57.000  2.51241e-05  9.82085e-04  2.28098e-04  2.62022e-04  1.08071e-04        Y
;;  scp2fgl FSB:  2008-08-19/21:51:45.000  1.70440e-05  5.34022e-03  4.06630e-04  5.93752e-04  1.71232e-04        Y
;;  scp2fgl SLM:  2008-09-08/20:24:50.000  1.43549e-06  2.49295e-03  2.49036e-04  3.05231e-04  1.61034e-04        Y
;;  scp2fgl HFA:  2008-09-08/17:01:41.000  3.79996e-07  6.26121e-03  3.88775e-04  9.14350e-04  8.00578e-05        Y
;;  scp2fgl FSB:  2008-09-08/20:25:22.000  1.00063e-05  1.28322e-02  6.31061e-04  1.00674e-03  4.02208e-04        Y
;;--------------------------------------------------------------------------------------------------------------------

;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scw2fgl FSB:  2008-07-14/21:55:45.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2fgl FSB:  2008-07-14/21:58:10.000  6.11191e-06  2.12855e-03  1.33194e-04  3.37347e-04  2.96156e-05        Y
;;  scw2fgl SLM:  2008-08-19/21:48:55.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2fgl SLM:  2008-08-19/21:53:45.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2fgl SLM:  2008-08-19/22:18:30.000  7.24513e-06  1.04706e-04  2.48221e-05  1.97253e-05  1.83940e-05        Y
;;  scw2fgl SLM:  2008-08-19/22:22:30.000  3.31596e-06  5.59025e-04  8.74155e-05  1.39650e-04  2.73490e-05        Y
;;  scw2fgl HFA:  2008-08-19/12:50:57.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2fgl FSB:  2008-08-19/21:51:45.000  5.02137e-06  7.12972e-04  9.24213e-05  1.73389e-04  1.88675e-05        Y
;;  scw2fgl SLM:  2008-09-08/20:24:50.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2fgl HFA:  2008-09-08/17:01:41.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2fgl FSB:  2008-09-08/20:25:22.000  5.61265e-06  4.07309e-04  5.53445e-05  7.70469e-05  3.44052e-05        Y
;;--------------------------------------------------------------------------------------------------------------------


;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-07-14/21:55:45.000  6.56169e-06  1.10093e-03  1.64888e-04  2.03040e-04  9.87113e-05        Y
;;  scw2fgl FSB:  2008-07-14/21:55:45.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2scp FSB:  2008-07-14/21:55:45.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-07-14/21:58:10.000  8.65683e-06  6.69557e-03  3.50931e-04  6.16754e-04  1.27029e-04        Y
;;  scw2fgl FSB:  2008-07-14/21:58:10.000  6.11191e-06  2.12855e-03  1.33194e-04  3.37347e-04  2.96156e-05        Y
;;  scw2scp FSB:  2008-07-14/21:58:10.000  4.20671e-05  2.39051e-02  1.57181e-03  3.91170e-03  3.24301e-04        Y
;;--------------------------------------------------------------------------------------------------------------------

;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-08-19/21:48:55.000  3.73961e-05  1.72627e-03  1.84083e-04  1.50359e-04  1.48661e-04        Y
;;  scw2fgl SLM:  2008-08-19/21:48:55.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2scp SLM:  2008-08-19/21:48:55.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-08-19/21:53:45.000  1.25402e-06  1.43503e-03  3.01448e-04  2.33035e-04  2.46856e-04        Y
;;  scw2fgl SLM:  2008-08-19/21:53:45.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2scp SLM:  2008-08-19/21:53:45.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-08-19/22:18:30.000  9.43987e-06  1.82909e-03  2.28558e-04  2.26788e-04  1.66997e-04        Y
;;  scw2fgl SLM:  2008-08-19/22:18:30.000  7.24513e-06  1.04706e-04  2.48221e-05  1.97253e-05  1.83940e-05        Y
;;  scw2scp SLM:  2008-08-19/22:18:30.000  3.29179e-05  1.87144e-03  2.36492e-04  3.11366e-04  1.70881e-04        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-08-19/22:22:30.000  7.58907e-06  6.71081e-03  4.14838e-04  8.44205e-04  1.56410e-04        Y
;;  scw2fgl SLM:  2008-08-19/22:22:30.000  3.31596e-06  5.59025e-04  8.74155e-05  1.39650e-04  2.73490e-05        Y
;;  scw2scp SLM:  2008-08-19/22:22:30.000  2.84320e-05  1.65105e-03  2.14305e-04  3.08687e-04  1.14703e-04        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-08-19/12:50:57.000  2.51241e-05  9.82085e-04  2.28098e-04  2.62022e-04  1.08071e-04        Y
;;  scw2fgl HFA:  2008-08-19/12:50:57.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2scp HFA:  2008-08-19/12:50:57.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-08-19/21:51:45.000  1.70440e-05  5.34022e-03  4.06630e-04  5.93752e-04  1.71232e-04        Y
;;  scw2fgl FSB:  2008-08-19/21:51:45.000  5.02137e-06  7.12972e-04  9.24213e-05  1.73389e-04  1.88675e-05        Y
;;  scw2scp FSB:  2008-08-19/21:51:45.000  5.22789e-05  8.42628e-03  8.64495e-04  1.92397e-03  2.02680e-04        Y
;;--------------------------------------------------------------------------------------------------------------------

;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-09-08/20:24:50.000  1.43549e-06  2.49295e-03  2.49036e-04  3.05231e-04  1.61034e-04        Y
;;  scw2fgl SLM:  2008-09-08/20:24:50.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2scp SLM:  2008-09-08/20:24:50.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-09-08/17:01:41.000  3.79996e-07  6.26121e-03  3.88775e-04  9.14350e-04  8.00578e-05        Y
;;  scw2fgl HFA:  2008-09-08/17:01:41.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2scp HFA:  2008-09-08/17:01:41.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-09-08/20:25:22.000  1.00063e-05  1.28322e-02  6.31061e-04  1.00674e-03  4.02208e-04        Y
;;  scw2fgl FSB:  2008-09-08/20:25:22.000  5.61265e-06  4.07309e-04  5.53445e-05  7.70469e-05  3.44052e-05        Y
;;  scw2scp FSB:  2008-09-08/20:25:22.000  2.05792e-05  2.06105e-03  2.53905e-04  3.72156e-04  1.26218e-04        Y
;;--------------------------------------------------------------------------------------------------------------------


;;========================================================================================
;;========================================================================================
;;  No Only
;;========================================================================================
;;========================================================================================
;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-07-14/13:16:26.000  1.14285e-05  1.00703e-02  6.77319e-04  1.13610e-03  2.47305e-04        N
;;  scp2fgl SLM:  2008-07-14/13:19:30.000  9.33565e-06  6.25747e-03  1.02503e-03  8.75961e-04  8.35964e-04        N
;;  scp2fgl HFA:  2008-07-14/15:21:00.000  5.30983e-07  1.82892e-03  8.12046e-05  1.48341e-04  3.57643e-05        N
;;  scp2fgl HFA:  2008-07-14/22:37:22.000  2.55581e-06  2.48998e-03  1.02946e-04  1.77526e-04  6.60477e-05        N
;;  scp2fgl FSB:  2008-07-14/20:03:21.000  4.31473e-06  3.99395e-04  1.41640e-04  7.48235e-05  1.46373e-04        N
;;  scp2fgl SLM:  2008-08-19/22:17:35.000  9.33168e-06  2.16076e-03  3.01902e-04  3.53093e-04  1.93350e-04        N
;;  scp2fgl SLM:  2008-08-19/22:37:45.000  8.01430e-06  2.63052e-03  2.66943e-04  3.73862e-04  1.42715e-04        N
;;  scp2fgl SLM:  2008-08-19/22:42:48.000  3.60538e-05  2.14161e-03  1.80138e-04  1.82999e-04  1.43135e-04        N
;;  scp2fgl HFA:  2008-08-19/21:46:17.000  2.33723e-06  3.17049e-04  1.20164e-04  5.52500e-05  1.07515e-04        N
;;  scp2fgl HFA:  2008-08-19/22:41:00.000  1.16706e-05  1.48707e-03  1.84299e-04  1.92118e-04  1.36582e-04        N
;;  scp2fgl FSB:  2008-08-19/20:43:35.000  1.95963e-06  1.05117e-03  1.56939e-04  1.76173e-04  9.40933e-05        N
;;  scp2fgl SLM:  2008-09-08/21:12:24.000  2.74240e-05  9.79893e-03  1.24900e-03  1.35093e-03  8.87559e-04        N
;;  scp2fgl SLM:  2008-09-08/21:15:33.000  4.56136e-06  1.19849e-02  7.52486e-04  1.32157e-03  3.76803e-04        N
;;  scp2fgl HFA:  2008-09-08/19:13:57.000  1.02327e-05  2.51391e-04  8.79974e-05  4.57256e-05  8.03052e-05        N
;;  scp2fgl HFA:  2008-09-08/20:26:44.000  7.74493e-07  8.75497e-04  1.42030e-04  9.97389e-05  1.24220e-04        N
;;  scp2fgl HFA:  2008-09-16/17:26:45.000  2.04177e-05  1.33769e-03  1.82790e-04  2.11031e-04  1.04160e-04        N
;;  scp2fgl FSB:  2008-09-16/17:46:13.000  2.65483e-05  1.31404e-03  1.80799e-04  2.02910e-04  1.08258e-04        N
;;--------------------------------------------------------------------------------------------------------------------

;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scw2fgl SLM:  2008-07-14/13:16:26.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2fgl SLM:  2008-07-14/13:19:30.000  5.35622e-06  2.98805e-04  4.13717e-05  5.50801e-05  2.60599e-05        N
;;  scw2fgl HFA:  2008-07-14/15:21:00.000  1.85058e-05  3.03869e-04  8.19824e-05  7.16870e-05  5.18807e-05        N
;;  scw2fgl HFA:  2008-07-14/22:37:22.000  1.00420e-05  4.11929e-03  2.51876e-04  7.30934e-04  4.73432e-05        N
;;  scw2fgl FSB:  2008-07-14/20:03:21.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2fgl SLM:  2008-08-19/22:17:35.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2fgl SLM:  2008-08-19/22:37:45.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2fgl SLM:  2008-08-19/22:42:48.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2fgl HFA:  2008-08-19/21:46:17.000  2.91401e-06  3.18388e-05  1.13486e-05  7.58505e-06  9.30075e-06        N
;;  scw2fgl HFA:  2008-08-19/22:41:00.000  1.72183e-06  2.37250e-05  9.67368e-06  5.57993e-06  8.13460e-06        N
;;  scw2fgl FSB:  2008-08-19/20:43:35.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2fgl SLM:  2008-09-08/17:28:23.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2fgl SLM:  2008-09-08/20:36:11.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2fgl SLM:  2008-09-08/21:12:24.000  2.43760e-06  3.81662e-03  2.20102e-04  5.34085e-04  3.81837e-05        N
;;  scw2fgl SLM:  2008-09-08/21:15:33.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2fgl HFA:  2008-09-08/19:13:57.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2fgl HFA:  2008-09-08/20:26:44.000  3.53997e-06  6.09001e-04  9.58472e-05  1.27030e-04  4.93066e-05        N
;;  scw2fgl HFA:  2008-09-16/17:26:45.000  1.13795e-05  1.39297e-04  5.91258e-05  3.29311e-05  5.10135e-05        N
;;  scw2fgl FSB:  2008-09-16/17:46:13.000  4.86430e-06  2.52773e-04  5.00264e-05  5.31850e-05  3.05911e-05        N
;;--------------------------------------------------------------------------------------------------------------------


;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-07-14/13:16:26.000  1.14285e-05  1.00703e-02  6.77319e-04  1.13610e-03  2.47305e-04        N
;;  scw2fgl SLM:  2008-07-14/13:16:26.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp SLM:  2008-07-14/13:16:26.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-07-14/13:19:30.000  9.33565e-06  6.25747e-03  1.02503e-03  8.75961e-04  8.35964e-04        N
;;  scw2fgl SLM:  2008-07-14/13:19:30.000  5.35622e-06  2.98805e-04  4.13717e-05  5.50801e-05  2.60599e-05        N
;;  scw2scp SLM:  2008-07-14/13:19:30.000  3.42889e-05  3.70410e-03  3.65706e-04  6.61088e-04  1.43214e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-07-14/15:21:00.000  5.30983e-07  1.82892e-03  8.12046e-05  1.48341e-04  3.57643e-05        N
;;  scw2fgl HFA:  2008-07-14/15:21:00.000  1.85058e-05  3.03869e-04  8.19824e-05  7.16870e-05  5.18807e-05        N
;;  scw2scp HFA:  2008-07-14/15:21:00.000  9.90311e-05  2.41076e-02  2.38935e-03  5.40196e-03  3.34609e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-07-14/22:37:22.000  2.55581e-06  2.48998e-03  1.02946e-04  1.77526e-04  6.60477e-05        N
;;  scw2fgl HFA:  2008-07-14/22:37:22.000  1.00420e-05  4.11929e-03  2.51876e-04  7.30934e-04  4.73432e-05        N
;;  scw2scp HFA:  2008-07-14/22:37:22.000  6.77805e-05  9.90407e-04  3.85513e-04  2.72085e-04  3.20161e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-07-14/20:03:21.000  4.31473e-06  3.99395e-04  1.41640e-04  7.48235e-05  1.46373e-04        N
;;  scw2fgl FSB:  2008-07-14/20:03:21.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp FSB:  2008-07-14/20:03:21.000          NaN          NaN         -NaN         -NaN          NaN        N
;;--------------------------------------------------------------------------------------------------------------------

;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-08-19/22:17:35.000  9.33168e-06  2.16076e-03  3.01902e-04  3.53093e-04  1.93350e-04        N
;;  scw2fgl SLM:  2008-08-19/22:17:35.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp SLM:  2008-08-19/22:17:35.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-08-19/22:37:45.000  8.01430e-06  2.63052e-03  2.66943e-04  3.73862e-04  1.42715e-04        N
;;  scw2fgl SLM:  2008-08-19/22:37:45.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp SLM:  2008-08-19/22:37:45.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-08-19/22:42:48.000  3.60538e-05  2.14161e-03  1.80138e-04  1.82999e-04  1.43135e-04        N
;;  scw2fgl SLM:  2008-08-19/22:42:48.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp SLM:  2008-08-19/22:42:48.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-08-19/21:46:17.000  2.33723e-06  3.17049e-04  1.20164e-04  5.52500e-05  1.07515e-04        N
;;  scw2fgl HFA:  2008-08-19/21:46:17.000  2.91401e-06  3.18388e-05  1.13486e-05  7.58505e-06  9.30075e-06        N
;;  scw2scp HFA:  2008-08-19/21:46:17.000  3.78091e-05  1.14356e-03  2.40711e-04  2.43917e-04  1.59070e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-08-19/22:41:00.000  1.16706e-05  1.48707e-03  1.84299e-04  1.92118e-04  1.36582e-04        N
;;  scw2fgl HFA:  2008-08-19/22:41:00.000  1.72183e-06  2.37250e-05  9.67368e-06  5.57993e-06  8.13460e-06        N
;;  scw2scp HFA:  2008-08-19/22:41:00.000  2.62224e-05  5.83286e-04  1.48885e-04  1.24716e-04  1.15729e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-08-19/20:43:35.000  1.95963e-06  1.05117e-03  1.56939e-04  1.76173e-04  9.40933e-05        N
;;  scw2fgl FSB:  2008-08-19/20:43:35.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp FSB:  2008-08-19/20:43:35.000          NaN          NaN         -NaN         -NaN          NaN        N
;;--------------------------------------------------------------------------------------------------------------------

;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-09-08/17:28:23.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2fgl SLM:  2008-09-08/17:28:23.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp SLM:  2008-09-08/17:28:23.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-09-08/20:36:11.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2fgl SLM:  2008-09-08/20:36:11.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp SLM:  2008-09-08/20:36:11.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-09-08/21:12:24.000  2.74240e-05  9.79893e-03  1.24900e-03  1.35093e-03  8.87559e-04        N
;;  scw2fgl SLM:  2008-09-08/21:12:24.000  2.43760e-06  3.81662e-03  2.20102e-04  5.34085e-04  3.81837e-05        N
;;  scw2scp SLM:  2008-09-08/21:12:24.000  1.66658e-05  1.87490e-02  8.43570e-04  2.40780e-03  2.17288e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-09-08/21:15:33.000  4.56136e-06  1.19849e-02  7.52486e-04  1.32157e-03  3.76803e-04        N
;;  scw2fgl SLM:  2008-09-08/21:15:33.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp SLM:  2008-09-08/21:15:33.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-09-08/19:13:57.000  1.02327e-05  2.51391e-04  8.79974e-05  4.57256e-05  8.03052e-05        N
;;  scw2fgl HFA:  2008-09-08/19:13:57.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp HFA:  2008-09-08/19:13:57.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-09-08/20:26:44.000  7.74493e-07  8.75497e-04  1.42030e-04  9.97389e-05  1.24220e-04        N
;;  scw2fgl HFA:  2008-09-08/20:26:44.000  3.53997e-06  6.09001e-04  9.58472e-05  1.27030e-04  4.93066e-05        N
;;  scw2scp HFA:  2008-09-08/20:26:44.000  4.53573e-05  2.03161e-02  2.29724e-03  4.69170e-03  3.35875e-04        N
;;--------------------------------------------------------------------------------------------------------------------

;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-09-16/17:26:45.000  2.04177e-05  1.33769e-03  1.82790e-04  2.11031e-04  1.04160e-04        N
;;  scw2fgl HFA:  2008-09-16/17:26:45.000  1.13795e-05  1.39297e-04  5.91258e-05  3.29311e-05  5.10135e-05        N
;;  scw2scp HFA:  2008-09-16/17:26:45.000  3.91661e-05  8.44295e-04  2.26188e-04  2.18108e-04  1.37746e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-09-16/17:46:13.000  2.65483e-05  1.31404e-03  1.80799e-04  2.02910e-04  1.08258e-04        N
;;  scw2fgl FSB:  2008-09-16/17:46:13.000  4.86430e-06  2.52773e-04  5.00264e-05  5.31850e-05  3.05911e-05        N
;;  scw2scp FSB:  2008-09-16/17:46:13.000  2.55838e-05  7.17542e-04  1.88888e-04  1.72688e-04  1.44936e-04        N
;;--------------------------------------------------------------------------------------------------------------------


;;========================================================================================
;;========================================================================================
;;  All
;;========================================================================================
;;========================================================================================

;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-07-14/13:16:26.000  1.14285e-05  1.00703e-02  6.77319e-04  1.13610e-03  2.47305e-04        N
;;  scw2fgl SLM:  2008-07-14/13:16:26.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp SLM:  2008-07-14/13:16:26.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-07-14/13:19:30.000  9.33565e-06  6.25747e-03  1.02503e-03  8.75961e-04  8.35964e-04        N
;;  scw2fgl SLM:  2008-07-14/13:19:30.000  5.35622e-06  2.98805e-04  4.13717e-05  5.50801e-05  2.60599e-05        N
;;  scw2scp SLM:  2008-07-14/13:19:30.000  3.42889e-05  3.70410e-03  3.65706e-04  6.61088e-04  1.43214e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-07-14/15:21:00.000  5.30983e-07  1.82892e-03  8.12046e-05  1.48341e-04  3.57643e-05        N
;;  scw2fgl HFA:  2008-07-14/15:21:00.000  1.85058e-05  3.03869e-04  8.19824e-05  7.16870e-05  5.18807e-05        N
;;  scw2scp HFA:  2008-07-14/15:21:00.000  9.90311e-05  2.41076e-02  2.38935e-03  5.40196e-03  3.34609e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-07-14/22:37:22.000  2.55581e-06  2.48998e-03  1.02946e-04  1.77526e-04  6.60477e-05        N
;;  scw2fgl HFA:  2008-07-14/22:37:22.000  1.00420e-05  4.11929e-03  2.51876e-04  7.30934e-04  4.73432e-05        N
;;  scw2scp HFA:  2008-07-14/22:37:22.000  6.77805e-05  9.90407e-04  3.85513e-04  2.72085e-04  3.20161e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-07-14/20:03:21.000  4.31473e-06  3.99395e-04  1.41640e-04  7.48235e-05  1.46373e-04        N
;;  scw2fgl FSB:  2008-07-14/20:03:21.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp FSB:  2008-07-14/20:03:21.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-07-14/21:55:45.000  6.56169e-06  1.10093e-03  1.64888e-04  2.03040e-04  9.87113e-05        Y
;;  scw2fgl FSB:  2008-07-14/21:55:45.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2scp FSB:  2008-07-14/21:55:45.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-07-14/21:58:10.000  8.65683e-06  6.69557e-03  3.50931e-04  6.16754e-04  1.27029e-04        Y
;;  scw2fgl FSB:  2008-07-14/21:58:10.000  6.11191e-06  2.12855e-03  1.33194e-04  3.37347e-04  2.96156e-05        Y
;;  scw2scp FSB:  2008-07-14/21:58:10.000  4.20671e-05  2.39051e-02  1.57181e-03  3.91170e-03  3.24301e-04        Y
;;--------------------------------------------------------------------------------------------------------------------

;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-08-19/21:48:55.000  3.73961e-05  1.72627e-03  1.84083e-04  1.50359e-04  1.48661e-04        Y
;;  scw2fgl SLM:  2008-08-19/21:48:55.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2scp SLM:  2008-08-19/21:48:55.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-08-19/21:53:45.000  1.25402e-06  1.43503e-03  3.01448e-04  2.33035e-04  2.46856e-04        Y
;;  scw2fgl SLM:  2008-08-19/21:53:45.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2scp SLM:  2008-08-19/21:53:45.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-08-19/22:17:35.000  9.33168e-06  2.16076e-03  3.01902e-04  3.53093e-04  1.93350e-04        N
;;  scw2fgl SLM:  2008-08-19/22:17:35.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp SLM:  2008-08-19/22:17:35.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-08-19/22:18:30.000  9.43987e-06  1.82909e-03  2.28558e-04  2.26788e-04  1.66997e-04        Y
;;  scw2fgl SLM:  2008-08-19/22:18:30.000  7.24513e-06  1.04706e-04  2.48221e-05  1.97253e-05  1.83940e-05        Y
;;  scw2scp SLM:  2008-08-19/22:18:30.000  3.29179e-05  1.87144e-03  2.36492e-04  3.11366e-04  1.70881e-04        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-08-19/22:22:30.000  7.58907e-06  6.71081e-03  4.14838e-04  8.44205e-04  1.56410e-04        Y
;;  scw2fgl SLM:  2008-08-19/22:22:30.000  3.31596e-06  5.59025e-04  8.74155e-05  1.39650e-04  2.73490e-05        Y
;;  scw2scp SLM:  2008-08-19/22:22:30.000  2.84320e-05  1.65105e-03  2.14305e-04  3.08687e-04  1.14703e-04        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-08-19/22:37:45.000  8.01430e-06  2.63052e-03  2.66943e-04  3.73862e-04  1.42715e-04        N
;;  scw2fgl SLM:  2008-08-19/22:37:45.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp SLM:  2008-08-19/22:37:45.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-08-19/22:42:48.000  3.60538e-05  2.14161e-03  1.80138e-04  1.82999e-04  1.43135e-04        N
;;  scw2fgl SLM:  2008-08-19/22:42:48.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp SLM:  2008-08-19/22:42:48.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-08-19/12:50:57.000  2.51241e-05  9.82085e-04  2.28098e-04  2.62022e-04  1.08071e-04        Y
;;  scw2fgl HFA:  2008-08-19/12:50:57.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2scp HFA:  2008-08-19/12:50:57.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-08-19/21:46:17.000  2.33723e-06  3.17049e-04  1.20164e-04  5.52500e-05  1.07515e-04        N
;;  scw2fgl HFA:  2008-08-19/21:46:17.000  2.91401e-06  3.18388e-05  1.13486e-05  7.58505e-06  9.30075e-06        N
;;  scw2scp HFA:  2008-08-19/21:46:17.000  3.78091e-05  1.14356e-03  2.40711e-04  2.43917e-04  1.59070e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-08-19/22:41:00.000  1.16706e-05  1.48707e-03  1.84299e-04  1.92118e-04  1.36582e-04        N
;;  scw2fgl HFA:  2008-08-19/22:41:00.000  1.72183e-06  2.37250e-05  9.67368e-06  5.57993e-06  8.13460e-06        N
;;  scw2scp HFA:  2008-08-19/22:41:00.000  2.62224e-05  5.83286e-04  1.48885e-04  1.24716e-04  1.15729e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-08-19/20:43:35.000  1.95963e-06  1.05117e-03  1.56939e-04  1.76173e-04  9.40933e-05        N
;;  scw2fgl FSB:  2008-08-19/20:43:35.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp FSB:  2008-08-19/20:43:35.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-08-19/21:51:45.000  1.70440e-05  5.34022e-03  4.06630e-04  5.93752e-04  1.71232e-04        Y
;;  scw2fgl FSB:  2008-08-19/21:51:45.000  5.02137e-06  7.12972e-04  9.24213e-05  1.73389e-04  1.88675e-05        Y
;;  scw2scp FSB:  2008-08-19/21:51:45.000  5.22789e-05  8.42628e-03  8.64495e-04  1.92397e-03  2.02680e-04        Y
;;--------------------------------------------------------------------------------------------------------------------

;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-09-08/17:28:23.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2fgl SLM:  2008-09-08/17:28:23.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp SLM:  2008-09-08/17:28:23.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-09-08/20:24:50.000  1.43549e-06  2.49295e-03  2.49036e-04  3.05231e-04  1.61034e-04        Y
;;  scw2fgl SLM:  2008-09-08/20:24:50.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2scp SLM:  2008-09-08/20:24:50.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-09-08/20:36:11.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2fgl SLM:  2008-09-08/20:36:11.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp SLM:  2008-09-08/20:36:11.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-09-08/21:12:24.000  2.74240e-05  9.79893e-03  1.24900e-03  1.35093e-03  8.87559e-04        N
;;  scw2fgl SLM:  2008-09-08/21:12:24.000  2.43760e-06  3.81662e-03  2.20102e-04  5.34085e-04  3.81837e-05        N
;;  scw2scp SLM:  2008-09-08/21:12:24.000  1.66658e-05  1.87490e-02  8.43570e-04  2.40780e-03  2.17288e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl SLM:  2008-09-08/21:15:33.000  4.56136e-06  1.19849e-02  7.52486e-04  1.32157e-03  3.76803e-04        N
;;  scw2fgl SLM:  2008-09-08/21:15:33.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp SLM:  2008-09-08/21:15:33.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-09-08/17:01:41.000  3.79996e-07  6.26121e-03  3.88775e-04  9.14350e-04  8.00578e-05        Y
;;  scw2fgl HFA:  2008-09-08/17:01:41.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;  scw2scp HFA:  2008-09-08/17:01:41.000          NaN          NaN         -NaN         -NaN          NaN        Y
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-09-08/19:13:57.000  1.02327e-05  2.51391e-04  8.79974e-05  4.57256e-05  8.03052e-05        N
;;  scw2fgl HFA:  2008-09-08/19:13:57.000          NaN          NaN         -NaN         -NaN          NaN        N
;;  scw2scp HFA:  2008-09-08/19:13:57.000          NaN          NaN         -NaN         -NaN          NaN        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-09-08/20:26:44.000  7.74493e-07  8.75497e-04  1.42030e-04  9.97389e-05  1.24220e-04        N
;;  scw2fgl HFA:  2008-09-08/20:26:44.000  3.53997e-06  6.09001e-04  9.58472e-05  1.27030e-04  4.93066e-05        N
;;  scw2scp HFA:  2008-09-08/20:26:44.000  4.53573e-05  2.03161e-02  2.29724e-03  4.69170e-03  3.35875e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-09-08/20:25:22.000  1.00063e-05  1.28322e-02  6.31061e-04  1.00674e-03  4.02208e-04        Y
;;  scw2fgl FSB:  2008-09-08/20:25:22.000  5.61265e-06  4.07309e-04  5.53445e-05  7.70469e-05  3.44052e-05        Y
;;  scw2scp FSB:  2008-09-08/20:25:22.000  2.05792e-05  2.06105e-03  2.53905e-04  3.72156e-04  1.26218e-04        Y
;;--------------------------------------------------------------------------------------------------------------------

;;--------------------------------------------------------------------------------------------------------------------
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl HFA:  2008-09-16/17:26:45.000  2.04177e-05  1.33769e-03  1.82790e-04  2.11031e-04  1.04160e-04        N
;;  scw2fgl HFA:  2008-09-16/17:26:45.000  1.13795e-05  1.39297e-04  5.91258e-05  3.29311e-05  5.10135e-05        N
;;  scw2scp HFA:  2008-09-16/17:26:45.000  3.91661e-05  8.44295e-04  2.26188e-04  2.18108e-04  1.37746e-04        N
;;            YYYY-MM-DD/hh:mm:ss.xxx        MIN          MAX          AVG          STD          MED          YESNO
;;  scp2fgl FSB:  2008-09-16/17:46:13.000  2.65483e-05  1.31404e-03  1.80799e-04  2.02910e-04  1.08258e-04        N
;;  scw2fgl FSB:  2008-09-16/17:46:13.000  4.86430e-06  2.52773e-04  5.00264e-05  5.31850e-05  3.05911e-05        N
;;  scw2scp FSB:  2008-09-16/17:46:13.000  2.55838e-05  7.17542e-04  1.88888e-04  1.72688e-04  1.44936e-04        N
;;--------------------------------------------------------------------------------------------------------------------






















;  logic   = e_enhanced_str.(j)                                                                & $
;  tb_yenh = tbar_gstr.(j)                                                                     & $
;  good    = WHERE(logic,gd)                                                                   & $


;        PRINT,';;',xposi,xwinn                                                                & $

;      toffs    = tra1[0]                                                                      & $
;      toffs    = struct_value(tsets,'TIME_OFFSET',DEFAULT=0d0)                                & $

;        xposi  = tbar_tstr.(i[0])                                                             & $
;        IF (gd EQ 0) THEN CONTINUE                                                            & $
;        xposi  = tb_yenh                                                                      & $
;        xposi -= toffs[0]                                                                     & $

;          XYOUTS,xposi[gi[0]],yposi[0],strout[gi[0]],/DATA,CHARSIZE=2.,COLOR=tbar_cols[i[0]]  & $

;        xposi  = xposi0 - toffs[0]                                                            & $






























