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
IF (tdate[0] EQ '2008-09-16') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:20:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-07-14') THEN tra_overv = tr_bs_cal + [-1,1]*6d1*1d1                 ;;  expand by ±10 mins
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
tplot,fgs_tpns,TRANGE=tra_overv
tplot,fgl_tpns,TRANGE=tra_overv
tplot,fgh_tpns,TRANGE=tra_overv
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
;;  Determine fgh time intervals
fghnm          = scpref[0]+'fgh_'+[coord_mag[0],coord_gse[0]]
get_data,fghnm[0],DATA=temp,DLIM=dlim,LIM=lim
gap_thsh       = 1d-2
fgh_t          = temp.X
srate          = sample_rate(fgh_t,GAP_THRESH=gap_thsh[0],/AVE,OUT_MED_AVG=sr_medavg)
med_sr         = sr_medavg[0]                     ;;  Median sample rate [sps]
med_dt         = 1d0/med_sr[0]                    ;;  Median sample period [s]
se_int         = t_interval_find(fgh_t,GAP_THRESH=2d0*med_dt[0],/NAN)
sint_fgh       = REFORM(se_int[*,0])
eint_fgh       = REFORM(se_int[*,1])
;;  Some gaps on 2008-08-19 --> Merge intervals
IF (tdate[0] EQ '2008-08-19') THEN sint_fgh = TEMPORARY([sint_fgh[0],sint_fgh[3:6],sint_fgh[10]])
IF (tdate[0] EQ '2008-08-19') THEN eint_fgh = TEMPORARY([eint_fgh[2],eint_fgh[3:5],eint_fgh[9],eint_fgh[13]])
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define time stamps for each energy/angle bin
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Get example structures [all THETA/PHI angles in DSL]
dat0           = dat_e
dat1           = dat_seb
dat2           = dat_sif
;;  Sort structures by time
sp             = SORT(dat0.TIME)
dat0           = TEMPORARY(dat0[sp])
sp             = SORT(dat1.TIME)
dat1           = TEMPORARY(dat1[sp])
sp             = SORT(dat2.TIME)
dat2           = TEMPORARY(dat2[sp])
;;  Define start/end times for EESA and SSTe VDFs
t_st_esae      = dat0.TIME
t_en_esae      = dat0.END_TIME
t_st_sste      = dat1.TIME
t_en_sste      = dat1.END_TIME
t_st_ssti      = dat2.TIME
t_en_ssti      = dat2.END_TIME
;;  Keep only those within fgh intervals
t_st_fgh       = fgh_t[sint_fgh]
t_en_fgh       = fgh_t[eint_fgh]
n_ifgh         = N_ELEMENTS(t_st_fgh)
FOR j=0L, n_ifgh[0] - 1L DO BEGIN                                                     $
  good0_0 = WHERE(t_st_esae GE t_st_fgh[j] AND t_en_esae LE t_en_fgh[j],gd0)        & $
  good1_0 = WHERE(t_st_sste GE t_st_fgh[j] AND t_en_sste LE t_en_fgh[j],gd1)        & $
  good2_0 = WHERE(t_st_ssti GE t_st_fgh[j] AND t_en_ssti LE t_en_fgh[j],gd2)        & $
  IF (gd0 GT 0) THEN IF (j EQ 0) THEN good0 = good0_0 ELSE good0 = [good0,good0_0]  & $
  IF (gd1 GT 0) THEN IF (j EQ 0) THEN good1 = good1_0 ELSE good1 = [good1,good1_0]  & $
  IF (gd2 GT 0) THEN IF (j EQ 0) THEN good2 = good2_0 ELSE good2 = [good2,good2_0]

dat0           = TEMPORARY(dat0[good0])
dat1           = TEMPORARY(dat1[good1])
dat2           = TEMPORARY(dat2[good2])
;;  Redefine start/end times for EESA and SSTe VDFs
t_st_esae      = dat0.TIME
t_en_esae      = dat0.END_TIME
t_st_sste      = dat1.TIME
t_en_sste      = dat1.END_TIME
t_st_ssti      = dat2.TIME
t_en_ssti      = dat2.END_TIME
;;  Define time durations [s] for entire VDFs
diff_t_esae    = t_en_esae - t_st_esae
diff_t_sste    = t_en_sste - t_st_sste
diff_t_ssti    = t_en_ssti - t_st_ssti
PRINT, minmax(diff_t_esae,/POS), minmax(diff_t_sste,/POS), minmax(diff_t_ssti,/POS)

;;  Define # of bins and structures
;;    --> arrays w/in structures are formatted as [E,A]-element arrays
;;        where E = # of energy bins and A = # of solid angle bins
n_esae         = N_ELEMENTS(dat0)                ;;  Number of EESA data structures
n_sste         = N_ELEMENTS(dat1)                ;;  Number of SSTe data structures
n_ssti         = N_ELEMENTS(dat2)                ;;  Number of SSTi data structures
n_e_esae       = dat0[0].NENERGY                 ;;  Number of EESA energy bins
n_a_esae       = dat0[0].NBINS                   ;;  Number of EESA angle bins
n_e_sste       = dat1[0].NENERGY                 ;;  Number of SSTe energy bins
n_a_sste       = dat1[0].NBINS                   ;;  Number of SSTe angle bins
n_e_ssti       = dat2[0].NENERGY                 ;;  Number of SSTi energy bins
n_a_ssti       = dat2[0].NBINS                   ;;  Number of SSTi angle bins
;;  Define total accumulation times [s] for each VDF
dt_esae        = DBLARR(n_e_esae[0],n_a_esae[0],n_esae[0])    ;;  Total accumulation times [s] for each EESA bin
dt_sste        = DBLARR(n_e_sste[0],n_a_sste[0],n_sste[0])    ;;  Total accumulation times [s] for each SSTe bin
dt_ssti        = DBLARR(n_e_ssti[0],n_a_ssti[0],n_ssti[0])    ;;  Total accumulation times [s] for each SSTi bin
FOR j=0L, n_esae[0] - 1L DO dt_esae[*,*,j] = dat0[j].INTEG_T[0]*dat0[j].DT_ARR
dt_sste        = dat1.INTEG_T
dt_ssti        = dat2.INTEG_T
;;----------------------------------------------------------------------------------------
;;  Get spacecraft spin period [s]
;;----------------------------------------------------------------------------------------
;;  Get spacecraft spin period [s]
thm_spper_tpn  = scpref[0]+'state_spinper'
get_data,thm_spper_tpn[0],DATA=temp_spper,DLIM=dlim,LIM=lim
spper_t        = temp_spper.X
spper_v        = temp_spper.Y
;;  Interpolate to VDF times and use average
spper_st_esae  = interp(spper_v,spper_t,t_st_esae,/NO_EXTRAP)
spper_st_sste  = interp(spper_v,spper_t,t_st_sste,/NO_EXTRAP)
spper_st_ssti  = interp(spper_v,spper_t,t_st_ssti,/NO_EXTRAP)
spper_en_esae  = interp(spper_v,spper_t,t_en_esae,/NO_EXTRAP)
spper_en_sste  = interp(spper_v,spper_t,t_en_sste,/NO_EXTRAP)
spper_en_ssti  = interp(spper_v,spper_t,t_en_ssti,/NO_EXTRAP)
spper_av_esae  = (spper_st_esae + spper_en_esae)/2d0
spper_av_sste  = (spper_st_sste + spper_en_sste)/2d0
spper_av_ssti  = (spper_st_ssti + spper_en_ssti)/2d0
;;  Compute spin rate [deg/s]
sprate_esae    = 36d1/spper_av_esae
sprate_sste    = 36d1/spper_av_sste
sprate_ssti    = 36d1/spper_av_ssti
;;----------------------------------------------------------------------------------------
;;  Define time stamps [Unix] associated with each angle bin
;;----------------------------------------------------------------------------------------
t_phi_esae     = ts_array_esa_angle_bins(dat0,sprate_esae)
t_phi_sste     = ts_array_sst_angle_bins(dat1,sprate_sste)
t_phi_ssti     = ts_array_sst_angle_bins(dat2,sprate_ssti)
;;  Reform into 1D arrays
t_phi_esae_1d  = REFORM(t_phi_esae,n_e_esae[0]*n_a_esae[0]*n_esae[0])
t_phi_sste_1d  = REFORM(t_phi_sste,n_e_sste[0]*n_a_sste[0]*n_sste[0])
t_phi_ssti_1d  = REFORM(t_phi_ssti,n_e_ssti[0]*n_a_ssti[0]*n_ssti[0])
;;  Define sort elements
sp_esae        = SORT(t_phi_esae_1d)
sp_sste        = SORT(t_phi_sste_1d)
sp_ssti        = SORT(t_phi_ssti_1d)
;;  Define dummy indices for inverting B-field output (i.e., go back to data structure order)
ind_esae       = SORT(sp_esae)
ind_sste       = SORT(sp_sste)
ind_ssti       = SORT(sp_ssti)
;;  Define sorted times
t_phi_esae_sp  = t_phi_esae_1d[sp_esae]
t_phi_sste_sp  = t_phi_sste_1d[sp_sste]
t_phi_ssti_sp  = t_phi_ssti_1d[sp_ssti]
;;----------------------------------------------------------------------------------------
;;  Get FGM data [nT, DSL]
;;----------------------------------------------------------------------------------------
fgh_dsl_tpn    = scpref[0]+'fgh_'+coord_dsl[0]
get_data,fgh_dsl_tpn[0],DATA=temp_bdsl,DLIM=dlim,LIM=lim
tp_bdsl_esae   = t_resample_tplot_struc(temp_bdsl,t_phi_esae_sp,/NO_EXTRAPOLATE)
tp_bdsl_sste   = t_resample_tplot_struc(temp_bdsl,t_phi_sste_sp,/NO_EXTRAPOLATE)
tp_bdsl_ssti   = t_resample_tplot_struc(temp_bdsl,t_phi_ssti_sp,/NO_EXTRAPOLATE)
;;  Re-order to be consistent with VDF structure times
bdsl_v_esae_ro = tp_bdsl_esae.Y[ind_esae,*]
bdsl_v_sste_ro = tp_bdsl_sste.Y[ind_sste,*]
bdsl_v_ssti_ro = tp_bdsl_ssti.Y[ind_ssti,*]
;;  Reform back into 3D arrays of 3-vectors
bdsl_v_esae_3d = REFORM(bdsl_v_esae_ro,n_e_esae[0],n_a_esae[0],n_esae[0],3L)
bdsl_v_sste_3d = REFORM(bdsl_v_sste_ro,n_e_sste[0],n_a_sste[0],n_sste[0],3L)
bdsl_v_ssti_3d = REFORM(bdsl_v_ssti_ro,n_e_ssti[0],n_a_ssti[0],n_ssti[0],3L)
;;----------------------------------------------------------------------------------------
;;  Transform distributions into ion bulk flow reference frame
;;----------------------------------------------------------------------------------------
;;  Add DSL bulk flow velocities to structures
vbulk_tpn      = scpref[0]+'peib_velocity_'+coord_dsl[0]
add_vsw2,dat0,vbulk_tpn[0],/LEAVE_ALONE,VBULK_TAG='velocity'
add_vsw2,dat1,vbulk_tpn[0],/LEAVE_ALONE,VBULK_TAG='velocity'
add_vsw2,dat2,vbulk_tpn[0],/LEAVE_ALONE,VBULK_TAG='velocity'
;;  Define transformation velocities
vbulk_0        = TRANSPOSE(dat0.VELOCITY)
vbulk_1        = TRANSPOSE(dat1.VELOCITY)
vbulk_2        = TRANSPOSE(dat2.VELOCITY)
;;  Transform into bulk flow reference frame
dat0_sw        = transform_vframe_3d_array(dat0,vbulk_0)
dat1_sw        = transform_vframe_3d_array(dat1,vbulk_1)
dat2_sw        = transform_vframe_3d_array(dat2,vbulk_2)
;;----------------------------------------------------------------------------------------
;;  Convert input energies/angles to velocities
;;----------------------------------------------------------------------------------------
;;  Define azimuthal and poloidal angles [deg, DSL]
phi_esae_sw    = DOUBLE(dat0_sw.PHI)
phi_sste_sw    = DOUBLE(dat1_sw.PHI)
phi_ssti_sw    = DOUBLE(dat2_sw.PHI)
the_esae_sw    = DOUBLE(dat0_sw.THETA)
the_sste_sw    = DOUBLE(dat1_sw.THETA)
the_ssti_sw    = DOUBLE(dat2_sw.THETA)
;;  Define sines and cosines of angles
cphi_esae_sw   = COS(phi_esae_sw*!DPI/18d1)
cphi_sste_sw   = COS(phi_sste_sw*!DPI/18d1)
cphi_ssti_sw   = COS(phi_ssti_sw*!DPI/18d1)
sphi_esae_sw   = SIN(phi_esae_sw*!DPI/18d1)
sphi_sste_sw   = SIN(phi_sste_sw*!DPI/18d1)
sphi_ssti_sw   = SIN(phi_ssti_sw*!DPI/18d1)
cthe_esae_sw   = COS(the_esae_sw*!DPI/18d1)
cthe_sste_sw   = COS(the_sste_sw*!DPI/18d1)
cthe_ssti_sw   = COS(the_ssti_sw*!DPI/18d1)
sthe_esae_sw   = SIN(the_esae_sw*!DPI/18d1)
sthe_sste_sw   = SIN(the_sste_sw*!DPI/18d1)
sthe_ssti_sw   = SIN(the_ssti_sw*!DPI/18d1)
;;  Define energies [eV] and particle masses [eV km^(-2) s^(2)]
ener_esae_sw   = DOUBLE(dat0_sw.ENERGY)
ener_sste_sw   = DOUBLE(dat1_sw.ENERGY)
ener_ssti_sw   = DOUBLE(dat2_sw.ENERGY)
mass_esae      = DOUBLE(dat0_sw[0].MASS[0])
mass_sste      = DOUBLE(dat1_sw[0].MASS[0])
mass_ssti      = DOUBLE(dat2_sw[0].MASS[0])
;;  Convert energies to speeds [km/s]
speed_esae_sw  = energy_to_vel(ener_esae_sw,mass_esae[0])
speed_sste_sw  = energy_to_vel(ener_sste_sw,mass_sste[0])
speed_ssti_sw  = energy_to_vel(ener_ssti_sw,mass_ssti[0])
;;  Define unit vector directions [DSL]
x_esae_sw      = cthe_esae_sw*cphi_esae_sw
y_esae_sw      = cthe_esae_sw*sphi_esae_sw
z_esae_sw      = sthe_esae_sw
x_sste_sw      = cthe_sste_sw*cphi_sste_sw
y_sste_sw      = cthe_sste_sw*sphi_sste_sw
z_sste_sw      = sthe_sste_sw
x_ssti_sw      = cthe_ssti_sw*cphi_ssti_sw
y_ssti_sw      = cthe_ssti_sw*sphi_ssti_sw
z_ssti_sw      = sthe_ssti_sw
;;  Define velocity vectors [km/s, DSL]
vels_esae      = DBLARR(n_e_esae[0],n_a_esae[0],n_esae[0],3L)
vels_sste      = DBLARR(n_e_sste[0],n_a_sste[0],n_sste[0],3L)
vels_ssti      = DBLARR(n_e_ssti[0],n_a_ssti[0],n_ssti[0],3L)
FOR j=0L, n_esae[0] - 1L DO BEGIN                                      $
  xu = REFORM(x_esae_sw[*,*,j])                                      & $
  yu = REFORM(y_esae_sw[*,*,j])                                      & $
  zu = REFORM(z_esae_sw[*,*,j])                                      & $
  vm = REFORM(speed_esae_sw[*,*,j])                                  & $
  udir_str = {X:xu,Y:yu,Z:zu}                                        & $
  FOR k=0L, 2L DO vels_esae[*,*,j,k] = vm*udir_str.(k)

FOR j=0L, n_sste[0] - 1L DO BEGIN                                      $
  xu = REFORM(x_sste_sw[*,*,j])                                      & $
  yu = REFORM(y_sste_sw[*,*,j])                                      & $
  zu = REFORM(z_sste_sw[*,*,j])                                      & $
  vm = REFORM(speed_sste_sw[*,*,j])                                  & $
  udir_str = {X:xu,Y:yu,Z:zu}                                        & $
  FOR k=0L, 2L DO vels_sste[*,*,j,k] = vm*udir_str.(k)

FOR j=0L, n_ssti[0] - 1L DO BEGIN                                      $
  xu = REFORM(x_ssti_sw[*,*,j])                                      & $
  yu = REFORM(y_ssti_sw[*,*,j])                                      & $
  zu = REFORM(z_ssti_sw[*,*,j])                                      & $
  vm = REFORM(speed_ssti_sw[*,*,j])                                  & $
  udir_str = {X:xu,Y:yu,Z:zu}                                        & $
  FOR k=0L, 2L DO vels_ssti[*,*,j,k] = vm*udir_str.(k)
;;----------------------------------------------------------------------------------------
;;  Calculate pitch-angle distributions (PADs)
;;----------------------------------------------------------------------------------------
;;  Compute magnitudes of each vector
bdsl_m_esae_3d = SQRT(TOTAL(bdsl_v_esae_3d^2,4,/NAN,/DOUBLE))
bdsl_m_sste_3d = SQRT(TOTAL(bdsl_v_sste_3d^2,4,/NAN,/DOUBLE))
bdsl_m_ssti_3d = SQRT(TOTAL(bdsl_v_ssti_3d^2,4,/NAN,/DOUBLE))
vels_m_esae    = SQRT(TOTAL(vels_esae^2,4,/NAN,/DOUBLE))
vels_m_sste    = SQRT(TOTAL(vels_sste^2,4,/NAN,/DOUBLE))
vels_m_ssti    = SQRT(TOTAL(vels_ssti^2,4,/NAN,/DOUBLE))
;;  Compute dot product between vectors
B_dot_V_esae   = TOTAL(bdsl_v_esae_3d*vels_esae,4,/NAN,/DOUBLE)/(bdsl_m_esae_3d*vels_m_esae)
B_dot_V_sste   = TOTAL(bdsl_v_sste_3d*vels_sste,4,/NAN,/DOUBLE)/(bdsl_m_sste_3d*vels_m_sste)
B_dot_V_ssti   = TOTAL(bdsl_v_ssti_3d*vels_ssti,4,/NAN,/DOUBLE)/(bdsl_m_ssti_3d*vels_m_ssti)
;;  Calculate pitch-angles (PAs) [deg]
pa_esae        = ACOS(B_dot_V_esae)*18d1/!DPI
pa_sste        = ACOS(B_dot_V_sste)*18d1/!DPI
pa_ssti        = ACOS(B_dot_V_ssti)*18d1/!DPI
;;  Define range of pitch-angles to use for averaging
cut_ran        = 22.5d0                 ;;  angle [deg] range about each PA to average
cut_mids       = [22.5d0,9d1,157.5d0]   ;;  Default mid angles [deg] about which to define a range over which to average
cut_lows       = cut_mids - cut_ran[0]
cut_high       = cut_mids + cut_ran[0]
;;  Make sure values are not < 0 or > 180
cut_lows       = cut_lows > 0d0
cut_high       = cut_high < 18d1
;;  Define elements satisfying pitch-angle ranges
test_para_esae = (pa_esae LE cut_high[0]) AND (pa_esae GE cut_lows[0])
test_perp_esae = (pa_esae LE cut_high[1]) AND (pa_esae GE cut_lows[1])
test_anti_esae = (pa_esae LE cut_high[2]) AND (pa_esae GE cut_lows[2])
test_para_sste = (pa_sste LE cut_high[0]) AND (pa_sste GE cut_lows[0])
test_perp_sste = (pa_sste LE cut_high[1]) AND (pa_sste GE cut_lows[1])
test_anti_sste = (pa_sste LE cut_high[2]) AND (pa_sste GE cut_lows[2])
good_para_esae = WHERE(test_para_esae,gd_para_esae,COMPLEMENT=bad_para_esae,NCOMPLEMENT=bd_para_esae)
good_perp_esae = WHERE(test_perp_esae,gd_perp_esae,COMPLEMENT=bad_perp_esae,NCOMPLEMENT=bd_perp_esae)
good_anti_esae = WHERE(test_anti_esae,gd_anti_esae,COMPLEMENT=bad_anti_esae,NCOMPLEMENT=bd_anti_esae)
good_para_sste = WHERE(test_para_sste,gd_para_sste,COMPLEMENT=bad_para_sste,NCOMPLEMENT=bd_para_sste)
good_perp_sste = WHERE(test_perp_sste,gd_perp_sste,COMPLEMENT=bad_perp_sste,NCOMPLEMENT=bd_perp_sste)
good_anti_sste = WHERE(test_anti_sste,gd_anti_sste,COMPLEMENT=bad_anti_sste,NCOMPLEMENT=bd_anti_sste)
PRINT,';;',gd_para_esae,gd_perp_esae,gd_anti_esae,gd_para_sste,gd_perp_sste,gd_anti_sste & $
PRINT,';;',bd_para_esae,bd_perp_esae,bd_anti_esae,bd_para_sste,bd_perp_sste,bd_anti_sste
;;      618633     1424837      483129      198271      532256      198596
;;     3126647     2320443     3262151     1172865      838880     1172540

;;  Define data and energies
data_esae_sw   = DOUBLE(dat0_sw.DATA)
data_sste_sw   = DOUBLE(dat1_sw.DATA)
all_parad_esae = data_esae_sw
all_perpd_esae = data_esae_sw
all_antid_esae = data_esae_sw
all_parad_sste = data_sste_sw
all_perpd_sste = data_sste_sw
all_antid_sste = data_sste_sw

all_parae_esae = ener_esae_sw
all_perpe_esae = ener_esae_sw
all_antie_esae = ener_esae_sw
all_parae_sste = ener_sste_sw
all_perpe_sste = ener_sste_sw
all_antie_sste = ener_sste_sw
;;  Remove "bad" data and energies
IF (bd_para_esae GT 0) THEN all_parad_esae[bad_para_esae] = !VALUES.D_NAN
IF (bd_perp_esae GT 0) THEN all_perpd_esae[bad_perp_esae] = !VALUES.D_NAN
IF (bd_anti_esae GT 0) THEN all_antid_esae[bad_anti_esae] = !VALUES.D_NAN
IF (bd_para_sste GT 0) THEN all_parad_sste[bad_para_sste] = !VALUES.D_NAN
IF (bd_perp_sste GT 0) THEN all_perpd_sste[bad_perp_sste] = !VALUES.D_NAN
IF (bd_anti_sste GT 0) THEN all_antid_sste[bad_anti_sste] = !VALUES.D_NAN

IF (bd_para_esae GT 0) THEN all_parae_esae[bad_para_esae] = !VALUES.D_NAN
IF (bd_perp_esae GT 0) THEN all_perpe_esae[bad_perp_esae] = !VALUES.D_NAN
IF (bd_anti_esae GT 0) THEN all_antie_esae[bad_anti_esae] = !VALUES.D_NAN
IF (bd_para_sste GT 0) THEN all_parae_sste[bad_para_sste] = !VALUES.D_NAN
IF (bd_perp_sste GT 0) THEN all_perpe_sste[bad_perp_sste] = !VALUES.D_NAN
IF (bd_anti_sste GT 0) THEN all_antie_sste[bad_anti_sste] = !VALUES.D_NAN
;;  Define energy ranges for each instrument
xran_esa       = [5e1,2e4]                   ;;  0.05-20 keV
xran_sst       = [1e4,4e5]                   ;;  10-400 keV
test_para_esae = ((all_parae_esae LE xran_esa[0]) OR (all_parae_esae GE xran_esa[1])) OR (FINITE(all_parae_esae) EQ 0)
test_perp_esae = ((all_perpe_esae LE xran_esa[0]) OR (all_perpe_esae GE xran_esa[1])) OR (FINITE(all_perpe_esae) EQ 0)
test_anti_esae = ((all_antie_esae LE xran_esa[0]) OR (all_antie_esae GE xran_esa[1])) OR (FINITE(all_antie_esae) EQ 0)
test_para_sste = ((all_parae_sste LE xran_sst[0]) OR (all_parae_sste GE xran_sst[1])) OR (FINITE(all_parae_sste) EQ 0)
test_perp_sste = ((all_perpe_sste LE xran_sst[0]) OR (all_perpe_sste GE xran_sst[1])) OR (FINITE(all_perpe_sste) EQ 0)
test_anti_sste = ((all_antie_sste LE xran_sst[0]) OR (all_antie_sste GE xran_sst[1])) OR (FINITE(all_antie_sste) EQ 0)
bad_parae_esae = WHERE(test_para_esae,bd_parae_esae,COMPLEMENT=good_parae_esae,NCOMPLEMENT=gd_parae_esae)
bad_perpe_esae = WHERE(test_perp_esae,bd_perpe_esae,COMPLEMENT=good_perpe_esae,NCOMPLEMENT=gd_perpe_esae)
bad_antie_esae = WHERE(test_anti_esae,bd_antie_esae,COMPLEMENT=good_antie_esae,NCOMPLEMENT=gd_antie_esae)
bad_parae_sste = WHERE(test_para_sste,bd_parae_sste,COMPLEMENT=good_parae_sste,NCOMPLEMENT=gd_parae_sste)
bad_perpe_sste = WHERE(test_perp_sste,bd_perpe_sste,COMPLEMENT=good_perpe_sste,NCOMPLEMENT=gd_perpe_sste)
bad_antie_sste = WHERE(test_anti_sste,bd_antie_sste,COMPLEMENT=good_antie_sste,NCOMPLEMENT=gd_antie_sste)

IF (bd_parae_esae GT 0) THEN all_parad_esae[bad_parae_esae] = !VALUES.D_NAN
IF (bd_perpe_esae GT 0) THEN all_perpd_esae[bad_perpe_esae] = !VALUES.D_NAN
IF (bd_antie_esae GT 0) THEN all_antid_esae[bad_antie_esae] = !VALUES.D_NAN
IF (bd_parae_sste GT 0) THEN all_parad_sste[bad_parae_sste] = !VALUES.D_NAN
IF (bd_perpe_sste GT 0) THEN all_perpd_sste[bad_perpe_sste] = !VALUES.D_NAN
IF (bd_antie_sste GT 0) THEN all_antid_sste[bad_antie_sste] = !VALUES.D_NAN

IF (bd_parae_esae GT 0) THEN all_parae_esae[bad_parae_esae] = !VALUES.D_NAN
IF (bd_perpe_esae GT 0) THEN all_perpe_esae[bad_perpe_esae] = !VALUES.D_NAN
IF (bd_antie_esae GT 0) THEN all_antie_esae[bad_antie_esae] = !VALUES.D_NAN
IF (bd_parae_sste GT 0) THEN all_parae_sste[bad_parae_sste] = !VALUES.D_NAN
IF (bd_perpe_sste GT 0) THEN all_perpe_sste[bad_perpe_sste] = !VALUES.D_NAN
IF (bd_antie_sste GT 0) THEN all_antie_sste[bad_antie_sste] = !VALUES.D_NAN
;;  Average data and energies over PAs
AllAvE_par_esa = TOTAL(all_parae_esae,2L,/NAN)/TOTAL(FINITE(all_parae_esae),2L,/NAN)
AllAvE_per_esa = TOTAL(all_perpe_esae,2L,/NAN)/TOTAL(FINITE(all_perpe_esae),2L,/NAN)
AllAvE_ant_esa = TOTAL(all_antie_esae,2L,/NAN)/TOTAL(FINITE(all_antie_esae),2L,/NAN)
AllAvf_par_esa = TOTAL(all_parad_esae,2L,/NAN)/TOTAL(FINITE(all_parad_esae),2L,/NAN)
AllAvf_per_esa = TOTAL(all_perpd_esae,2L,/NAN)/TOTAL(FINITE(all_perpd_esae),2L,/NAN)
AllAvf_ant_esa = TOTAL(all_antid_esae,2L,/NAN)/TOTAL(FINITE(all_antid_esae),2L,/NAN)
AllAvE_par_sst = TOTAL(all_parae_sste,2L,/NAN)/TOTAL(FINITE(all_parae_sste),2L,/NAN)
AllAvE_per_sst = TOTAL(all_perpe_sste,2L,/NAN)/TOTAL(FINITE(all_perpe_sste),2L,/NAN)
AllAvE_ant_sst = TOTAL(all_antie_sste,2L,/NAN)/TOTAL(FINITE(all_antie_sste),2L,/NAN)
AllAvf_par_sst = TOTAL(all_parad_sste,2L,/NAN)/TOTAL(FINITE(all_parad_sste),2L,/NAN)
AllAvf_per_sst = TOTAL(all_perpd_sste,2L,/NAN)/TOTAL(FINITE(all_perpd_sste),2L,/NAN)
AllAvf_ant_sst = TOTAL(all_antid_sste,2L,/NAN)/TOTAL(FINITE(all_antid_sste),2L,/NAN)
;;----------------------------------------------------------------------------------------
;;  Setup for plotting individual spectra
;;----------------------------------------------------------------------------------------
units          = 'df'
IF (units[0] EQ 'flux') THEN yran_esa = [1e-1,1e6]
IF (units[0] EQ 'flux') THEN yran_sst = [1e-4,2e-1]
IF (units[0] EQ   'df') THEN yran_esa = [1e-19,2e-12]
IF (units[0] EQ   'df') THEN yran_sst = [1e-26,1e-20]
;;  Setup options
lim0           = {XSTYLE:1,YSTYLE:1,XMINOR:9,YMINOR:9,XMARGIN:[10,10],YMARGIN:[5,5],$
                  XLOG:1,YLOG:1}
pstr           = lim0
;;  Define popen structure
popen_str      = {PORT:1,UNITS:'inches',XSIZE:8.5,YSIZE:8.5,ASPECT:1}
;;  Define XRANGE and YRANGE
xran_out       = xran_esa
xran_out[0]    = xran_out[0] < xran_sst[0]
xran_out[1]    = xran_out[1] > xran_sst[1]
yran_out       = yran_esa
yran_out[0]    = yran_out[0] < yran_sst[0]
yran_out[1]    = yran_out[1] > yran_sst[1]
;;  Get tick marks
xtick          = get_power_of_ten_ticks(xran_out)
ytick          = get_power_of_ten_ticks(yran_out)
;;  Define titles
mission        = 'THEMIS'
probe          = STRUPCASE(dat0[0].SPACECRAFT[0])  ;;  e.g., 'C'
strn0          = dat_themis_esa_str_names(dat0[0])
strn1          = dat_themis_esa_str_names(dat1[0])
data_str_esa   = strn0.SN[0]     ;;  e.g., 'el' for Wind EESA Low or 'peeb' for THEMIS EESA
data_str_sst   = strn1.SN[0]     ;;  e.g., 'sf' for Wind SST Foil or 'pseb' for THEMIS SST Foil
temp           = strn0.LC[0]                  ;;  e.g., 'IESA 3D Burst Distribution'
tposi          = STRPOS(temp[0],'Distribution') - 1L
instnmmode_esa = STRMID(temp[0],0L,tposi[0])  ;;  e.g., 'IESA 3D Burst'
temp           = strn1.LC[0]                  ;;  e.g., 'SST Ion Burst Distribution'
tposi          = STRPOS(temp[0],'Distribution') - 1L
instnmmode_sst = STRMID(temp[0],0L,tposi[0])  ;;  e.g., 'SST Ion Burst'
esae_pref      = mission[0]+'-'+probe[0]+' '+instnmmode_esa[0]+': '
sste_pref      = mission[0]+'-'+probe[0]+' '+instnmmode_sst[0]+': '
ttle_ext       = 'SWF'
test           = (N_ELEMENTS(units) EQ 0) OR (SIZE(units,/TYPE) NE 7)
IF (test[0]) THEN gunits = 'flux' ELSE gunits = units[0]
new_units      = wind_3dp_units(gunits[0])
gunits         = new_units.G_UNIT_NAME      ;;  e.g., 'flux'
punits         = new_units.G_UNIT_P_NAME    ;;  e.g., ' (# cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
ytitle         = gunits[0]+' ['+ttle_ext[0]+']'+punits[0]
xtitle         = 'Energy [eV]'
;;  Add XRANGE and YRANGE to plot limits structure
str_element,pstr,   'XRANGE',       xran_out,/ADD_REPLACE
str_element,pstr,   'YRANGE',       yran_out,/ADD_REPLACE
;;  Add [X,Y]TICKNAME, [X,Y]TICKV, and [X,Y]TICKS to plot limits structure
str_element,pstr,'YTICKNAME',ytick.YTICKNAME,/ADD_REPLACE
str_element,pstr,   'YTICKV',   ytick.YTICKV,/ADD_REPLACE
str_element,pstr,   'YTICKS',   ytick.YTICKS,/ADD_REPLACE
str_element,pstr,'XTICKNAME',xtick.XTICKNAME,/ADD_REPLACE
str_element,pstr,   'XTICKV',   xtick.XTICKV,/ADD_REPLACE
str_element,pstr,   'XTICKS',   xtick.XTICKS,/ADD_REPLACE
;;  Add XTITLE and YTITLE to plot limits structure
str_element,pstr,   'XTITLE',      xtitle[0],/ADD_REPLACE
str_element,pstr,   'YTITLE',      ytitle[0],/ADD_REPLACE

legends        = ['Para.','Perp.','Anti.']+' Avg.: '+STRMID(fsuffx[0],1)+' '+legsuffx[0]
leg_fpl        = ['Dashed:  f(E) ~ E^(-2)','Dash-Dot:  f(E) ~ E^(-3)','Dash-Dot-Dot:  f(E) ~ E^(-4)']
plw_cols       = [ 30, 125, 200]
vec_cols       = [250,150, 50]
xyfacs         = [55d-2,105d-2,35d-2]
xposi          = [0.12,0.15]
yposi          = [0.34,0.31,0.28,0.24,0.21,0.18]
psym           = -6      ;;  square symbol and connect points with solid lines
;;----------------------------------------------------------------------------------------
;;  Open windows for plotting
;;----------------------------------------------------------------------------------------
wttles         = mission[0]+' '+['ESA','SST','ESA+SST']
w_struc        = {RETAIN:2,XSIZE:800,YSIZE:800}
ww             = 2L
wnum           = ww[0] + 1L
wstruc         = w_struc
str_element,wstruc,'TITLE',wttles[ww],/ADD_REPLACE
WINDOW,wnum[0],_EXTRA=wstruc
;;----------------------------------------------------------------------------------------
;;  Plot combined spectra
;;----------------------------------------------------------------------------------------
jj             = 826L
dat_00         = dat0_sw[jj]
diff           = ABS(dat1_sw.TIME - dat_00[0].TIME)
mndf           = MIN(diff,kk,/NAN)
dat_11         = dat1_sw[kk]
esae_suffx     = trange_str(dat_00[0].TIME,dat_00[0].END_TIME,/MSEC)
sste_suffx     = trange_str(dat_11[0].TIME,dat_11[0].END_TIME,/MSEC)
title_esa      = esae_pref[0]+': '+esae_suffx[0]
title_sst      = sste_pref[0]+': '+sste_suffx[0]
p_title        = title_esa[0]+'!C'+title_sst[0]

Avgf_para_esa  = REFORM(AllAvf_par_esa[*,jj])
Avgf_perp_esa  = REFORM(AllAvf_per_esa[*,jj])
Avgf_anti_esa  = REFORM(AllAvf_ant_esa[*,jj])
Avgf_para_sst  = REFORM(AllAvf_par_sst[*,kk])
Avgf_perp_sst  = REFORM(AllAvf_per_sst[*,kk])
Avgf_anti_sst  = REFORM(AllAvf_ant_sst[*,kk])

AvgE_para_esa  = REFORM(AllAvE_par_esa[*,jj])
AvgE_perp_esa  = REFORM(AllAvE_per_esa[*,jj])
AvgE_anti_esa  = REFORM(AllAvE_ant_esa[*,jj])
AvgE_para_sst  = REFORM(AllAvE_par_sst[*,kk])
AvgE_perp_sst  = REFORM(AllAvE_per_sst[*,kk])
AvgE_anti_sst  = REFORM(AllAvE_ant_sst[*,kk])

WSET,3
WSHOW,3
thck           = 2.0
symz           = 2.0
  PLOT,AvgE_para_esa,Avgf_para_esa,/NODATA,TITLE=p_title[0],_EXTRA=pstr
    ;;  Plot EESA data
    OPLOT,AvgE_para_esa,Avgf_para_esa,COLOR=vec_cols[0],PSYM=psym[0],SYMSIZE=symz[0],THICK=thck[0]
    OPLOT,AvgE_perp_esa,Avgf_perp_esa,COLOR=vec_cols[1],PSYM=psym[0],SYMSIZE=symz[0],THICK=thck[0]
    OPLOT,AvgE_anti_esa,Avgf_anti_esa,COLOR=vec_cols[2],PSYM=psym[0],SYMSIZE=symz[0],THICK=thck[0]
    ;;  Plot SSTe data
    OPLOT,AvgE_para_sst,Avgf_para_sst,COLOR=vec_cols[0],PSYM=psym[0],SYMSIZE=symz[0],THICK=thck[0]
    OPLOT,AvgE_perp_sst,Avgf_perp_sst,COLOR=vec_cols[1],PSYM=psym[0],SYMSIZE=symz[0],THICK=thck[0]
    OPLOT,AvgE_anti_sst,Avgf_anti_sst,COLOR=vec_cols[2],PSYM=psym[0],SYMSIZE=symz[0],THICK=thck[0]


;;----------------------------------------------------------------------------------------
;;  Save plot of combined spectra
;;----------------------------------------------------------------------------------------
exsuffx        = 'fgh-BVecs'
fsuffx         = '_PAD'
fpref          = mission[0]+'_'+gunits[0]+'_'+data_str_esa[0]+'-'
fend           = 'para-red_perp-green_anti-blue_wrt'+fsuffx[0]    ;;  e.g., 'para-red_perp-green_anti-blue_wrt_PAD'
fnm_esa        = file_name_times(dat_00[0].TIME,PREC=3)
fnm_sst        = file_name_times(dat_11[0].TIME,PREC=3)
ft_esa         = fnm_esa[0].F_TIME[0]             ;;  e.g., '1998-08-09_0801x09.494'
ft_sst         = STRMID(fnm_sst[0].F_TIME[0],11)  ;;  e.g., '0801x09.494'
fname          = fpref[0]+ft_esa[0]+'_'+data_str_sst[0]+'-'+ft_sst[0]+'_'+fend[0]+'_'+exsuffx[0]

thck           = 3.0
symz           = 1.0
popen,fname[0],_EXTRA=popen_str
  PLOT,AvgE_para_esa,Avgf_para_esa,/NODATA,TITLE=p_title[0],_EXTRA=pstr
    ;;  Plot EESA data
    OPLOT,AvgE_para_esa,Avgf_para_esa,COLOR=vec_cols[0],PSYM=psym[0],SYMSIZE=symz[0],THICK=thck[0]
    OPLOT,AvgE_perp_esa,Avgf_perp_esa,COLOR=vec_cols[1],PSYM=psym[0],SYMSIZE=symz[0],THICK=thck[0]
    OPLOT,AvgE_anti_esa,Avgf_anti_esa,COLOR=vec_cols[2],PSYM=psym[0],SYMSIZE=symz[0],THICK=thck[0]
    ;;  Plot SSTe data
    OPLOT,AvgE_para_sst,Avgf_para_sst,COLOR=vec_cols[0],PSYM=psym[0],SYMSIZE=symz[0],THICK=thck[0]
    OPLOT,AvgE_perp_sst,Avgf_perp_sst,COLOR=vec_cols[1],PSYM=psym[0],SYMSIZE=symz[0],THICK=thck[0]
    OPLOT,AvgE_anti_sst,Avgf_anti_sst,COLOR=vec_cols[2],PSYM=psym[0],SYMSIZE=symz[0],THICK=thck[0]
pclose


;;----------------------------------------------------------------------------------------
;;  Show one-count level for combined spectra
;;----------------------------------------------------------------------------------------
exsuffx        = 'BVecs_with_1count'
fsuffx         = '_PAD'
fpref          = mission[0]+'_'+gunits[0]+'_'+data_str_esa[0]+'-'
fend           = 'para-red_perp-green_anti-blue_wrt'+fsuffx[0]    ;;  e.g., 'para-red_perp-green_anti-blue_wrt_PAD'
fnm_esa        = file_name_times(dat_00[0].TIME,PREC=3)
fnm_sst        = file_name_times(dat_11[0].TIME,PREC=3)
ft_esa         = fnm_esa[0].F_TIME[0]             ;;  e.g., '1998-08-09_0801x09.494'
ft_sst         = STRMID(fnm_sst[0].F_TIME[0],11)  ;;  e.g., '0801x09.494'
fname          = fpref[0]+ft_esa[0]+'_'+data_str_sst[0]+'-'+ft_sst[0]+'_'+fend[0]+'_'+exsuffx[0]
extract_tags,lime_str,lim0
extract_tags,lims_str,lim0
str_element,lime_str, 'XRANGE',     xran_esa,/ADD_REPLACE
str_element,lime_str, 'YRANGE',     yran_esa,/ADD_REPLACE
str_element,lims_str, 'XRANGE',     xran_sst,/ADD_REPLACE
str_element,lims_str, 'YRANGE',     yran_sst,/ADD_REPLACE

sc_frame       = 0b
cut_ran        = 22.5d0
p_angle        = 1b
sundir         = 0b
vec            = 0b
leg_sffx       = '(Bo)'
.compile plot_esa_sst_combined_spec3d.pro
jj             = 826L
dat_00         = dat0_sw[jj]
diff           = ABS(dat1_sw.TIME - dat_00[0].TIME)
mndf           = MIN(diff,kk,/NAN)
dat_11         = dat1_sw[kk]
plot_esa_sst_combined_spec3d,dat_00,dat_11,LIM_ESA=lime_str,LIM_SST=lims_str,           $
                             ESA_ERAN=xran_esa,SST_ERAN=xran_sst,                       $
                             SC_FRAME=sc_frame,CUT_RAN=cut_ran,P_ANGLE=p_angle,         $
                             SUNDIR=sundir,VECTOR=vec,UNITS=units,EX_SUFFX=exsuffx,     $
                             LEG_SFFX=leg_sffx,/ONE_C













extract_tags,lime_str,lim0
extract_tags,lims_str,lim0
str_element,lime_str, 'XRANGE',     xran_esa,/ADD_REPLACE
str_element,lime_str, 'YRANGE',     yran_esa,/ADD_REPLACE
str_element,lims_str, 'XRANGE',     xran_sst,/ADD_REPLACE
str_element,lims_str, 'YRANGE',     yran_sst,/ADD_REPLACE












;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Define azimuthal angles and ranges/uncertainties [deg, DSL]
;;----------------------------------------------------------------------------------------
phi_esae       = DOUBLE(dat0.PHI)
phi_sste       = DOUBLE(dat1.PHI)
phi_ssti       = DOUBLE(dat2.PHI)
dphi_esae      = DOUBLE(dat0.DPHI)
dphi_sste      = DOUBLE(dat1.DPHI)
dphi_ssti      = DOUBLE(dat2.DPHI)
;;  Define start and end azimuthal angles [deg, DSL]
phi_st_esae    = (phi_esae - dphi_esae/2d0)
phi_st_sste    = (phi_sste - dphi_sste/2d0)
phi_st_ssti    = (phi_ssti - dphi_ssti/2d0)
phi_en_esae    = (phi_esae + dphi_esae/2d0)
phi_en_sste    = (phi_sste + dphi_sste/2d0)
phi_en_ssti    = (phi_ssti + dphi_ssti/2d0)
;;  Define time-zero [s] as time-equivalent of angle
t_zero_esae    = REFORM(phi_esae[0,0,*])/sprate_esae
t_zero_sste    = REFORM(phi_sste[0,0,*])/sprate_sste
t_zero_ssti    = REFORM(phi_ssti[0,0,*])/sprate_ssti
;;  Define time duration [s] of each aziumthal bin
dt_phi_esae    = DBLARR(n_e_esae[0],n_a_esae[0],n_esae[0])    ;;  Time duration [s] for each EESA bin
dt_phi_sste    = DBLARR(n_e_sste[0],n_a_sste[0],n_sste[0])    ;;  Time duration [s] for each EESA bin
dt_phi_ssti    = DBLARR(n_e_ssti[0],n_a_ssti[0],n_ssti[0])    ;;  Time duration [s] for each EESA bin
FOR j=0L, n_esae[0] - 1L DO dt_phi_esae[*,*,j] = (phi_en_esae[*,*,j] - phi_st_esae[*,*,j])/sprate_esae[j]
FOR j=0L, n_sste[0] - 1L DO dt_phi_sste[*,*,j] = (phi_en_sste[*,*,j] - phi_st_sste[*,*,j])/sprate_sste[j]
FOR j=0L, n_ssti[0] - 1L DO dt_phi_ssti[*,*,j] = (phi_en_ssti[*,*,j] - phi_st_ssti[*,*,j])/sprate_ssti[j]
;;  Define start and end times [s offset from start of VDF] of each aziumthal bin
t_off_av_esae  = DBLARR(n_e_esae[0],n_a_esae[0],n_esae[0])
t_off_av_sste  = DBLARR(n_e_sste[0],n_a_sste[0],n_sste[0])
t_off_av_ssti  = DBLARR(n_e_ssti[0],n_a_ssti[0],n_ssti[0])
FOR j=0L, n_esae[0] - 1L DO t_off_av_esae[*,*,j] = (phi_esae[*,*,j]/sprate_esae[j]) - t_zero_esae[j]
FOR j=0L, n_sste[0] - 1L DO t_off_av_sste[*,*,j] = (phi_sste[*,*,j]/sprate_sste[j]) - t_zero_sste[j]
FOR j=0L, n_ssti[0] - 1L DO t_off_av_ssti[*,*,j] = (phi_ssti[*,*,j]/sprate_ssti[j]) - t_zero_ssti[j]
;;  Remove smallest time --> start time offset = 0 s
FOR j=0L, n_esae[0] - 1L DO t_off_av_esae[*,*,j] -= MIN(t_off_av_esae[*,*,j],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_av_sste[*,*,j] -= MIN(t_off_av_sste[*,*,j],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_av_ssti[*,*,j] -= MIN(t_off_av_ssti[*,*,j],/NAN)
PRINT, minmax(t_off_av_esae), minmax(t_off_av_sste), minmax(t_off_av_ssti)

;;  Adjust by 1/2 the total accumulation times
dt_off_st_esae = t_off_av_esae + dt_esae/2d0
dt_off_st_sste = t_off_av_sste + dt_sste/2d0
dt_off_st_ssti = t_off_av_ssti + dt_ssti/2d0
PRINT, minmax(dt_off_st_esae), minmax(dt_off_st_sste), minmax(dt_off_st_ssti)

;;  Define time stamps [Unix] associated with each angle bin
t_phi_esae     = DBLARR(n_e_esae[0],n_a_esae[0],n_esae[0])
t_phi_sste     = DBLARR(n_e_sste[0],n_a_sste[0],n_sste[0])
t_phi_ssti     = DBLARR(n_e_ssti[0],n_a_ssti[0],n_ssti[0])
FOR j=0L, n_esae[0] - 1L DO t_phi_esae[*,*,j] = t_st_esae[j] + dt_off_st_esae[*,*,j]
FOR j=0L, n_sste[0] - 1L DO t_phi_sste[*,*,j] = t_st_sste[j] + dt_off_st_sste[*,*,j]
FOR j=0L, n_ssti[0] - 1L DO t_phi_ssti[*,*,j] = t_st_ssti[j] + dt_off_st_ssti[*,*,j]

;;  Need to add the VSW tag to the SST structures
dat10          = dat1[0]
dat20          = dat2[0]
str_element,dat10,'VSW',dat1[0].VELOCITY,/ADD_REPLACE
str_element,dat20,'VSW',dat2[0].VELOCITY,/ADD_REPLACE
dat11          = REPLICATE(dat10[0],n_sste[0])
dat22          = REPLICATE(dat20[0],n_ssti[0])
FOR j=0L, n_sste[0] - 1L DO BEGIN                                      $
  dat_0 = dat1[j]                                                    & $
  dat_1 = dat11[j]                                                   & $
  extract_tags,dat_1,dat_0                                           & $
  dat11[j] = dat_1[0]

FOR j=0L, n_ssti[0] - 1L DO BEGIN                                      $
  dat_0 = dat2[j]                                                    & $
  dat_1 = dat22[j]                                                   & $
  extract_tags,dat_1,dat_0                                           & $
  dat22[j] = dat_1[0]

;;  Redefine structures and cleanup
dat1           = dat11
dat2           = dat22
DELVAR,dat10,dat20,dat11,dat22,dat_0,dat_1

;;  Add DSL bulk flow velocities to structures
vbulk_tpn      = scpref[0]+'peib_velocity_'+coord_dsl[0]
add_vsw2,dat0,vbulk_tpn[0],/LEAVE_ALONE
add_vsw2,dat1,vbulk_tpn[0],/LEAVE_ALONE
add_vsw2,dat2,vbulk_tpn[0],/LEAVE_ALONE
;;  Define transformation velocities
vbulk_0        = TRANSPOSE(dat0.VSW)
vbulk_1        = TRANSPOSE(dat1.VSW)
vbulk_2        = TRANSPOSE(dat2.VSW)
;;  Transform into bulk flow reference frame
dat0_sw        = transform_vframe_3d_array(dat0,vbulk_0)
dat1_sw        = transform_vframe_3d_array(dat1,vbulk_1)
dat2_sw        = transform_vframe_3d_array(dat2,vbulk_2)

;;  Define charge and energy shift associated with each structure type
chg_eshft_esae = DBLARR(n_esae[0],2L)
chg_eshft_sste = DBLARR(n_sste[0],2L)
chg_eshft_ssti = DBLARR(n_ssti[0],2L)
FOR j=0L, n_esae[0] - 1L DO BEGIN                                      $
  charge = 0d0                                                       & $
  dat    = dat0[j]                                                   & $
  temp   = define_particle_charge(dat,E_SHIFT=e_shift)               & $
  test   = (N_ELEMENTS(e_shift) EQ 0) OR (SIZE(e_shift,/TYPE) LE 2)  & $
  IF (test[0]) THEN eshift = 0d0 ELSE eshift = e_shift[0]            & $
  test   = (temp EQ 0)                                               & $
  IF (test[0]) THEN CONTINUE ELSE charge = temp[0]                   & $
  chg_eshft_esae[j,*] = [charge[0],eshift[0]]

FOR j=0L, n_sste[0] - 1L DO BEGIN                                      $
  charge = 0d0                                                       & $
  dat    = dat1[j]                                                   & $
  temp   = define_particle_charge(dat,E_SHIFT=e_shift)               & $
  test   = (N_ELEMENTS(e_shift) EQ 0) OR (SIZE(e_shift,/TYPE) LE 2)  & $
  IF (test[0]) THEN eshift = 0d0 ELSE eshift = e_shift[0]            & $
  test   = (temp EQ 0)                                               & $
  IF (test[0]) THEN CONTINUE ELSE charge = temp[0]                   & $
  chg_eshft_sste[j,*] = [charge[0],eshift[0]]

FOR j=0L, n_ssti[0] - 1L DO BEGIN                                      $
  charge = 0d0                                                       & $
  dat    = dat2[j]                                                   & $
  temp   = define_particle_charge(dat,E_SHIFT=e_shift)               & $
  test   = (N_ELEMENTS(e_shift) EQ 0) OR (SIZE(e_shift,/TYPE) LE 2)  & $
  IF (test[0]) THEN eshift = 0d0 ELSE eshift = e_shift[0]            & $
  test   = (temp EQ 0)                                               & $
  IF (test[0]) THEN CONTINUE ELSE charge = temp[0]                   & $
  chg_eshft_ssti[j,*] = [charge[0],eshift[0]]





FOR j=0L, n_esae[0] - 1L DO BEGIN               $
  temp = energy_angle_to_velocity(dat0[j])    & $
  sztp = SIZE(temp,/N_DIMENSIONS)             & $
  test = (sztp[0] NE 3)                       & $
  IF (test[0]) THEN CONTINUE                  & $
  vels_esae[*,*,j,*] = temp

FOR j=0L, n_sste[0] - 1L DO BEGIN               $
  temp = energy_angle_to_velocity(dat1[j])    & $
  sztp = SIZE(temp,/N_DIMENSIONS)             & $
  test = (sztp[0] NE 3)                       & $
  IF (test[0]) THEN CONTINUE                  & $
  vels_sste[*,*,j,*] = temp

FOR j=0L, n_ssti[0] - 1L DO BEGIN               $
  temp = energy_angle_to_velocity(dat2[j])    & $
  sztp = SIZE(temp,/N_DIMENSIONS)             & $
  test = (sztp[0] NE 3)                       & $
  IF (test[0]) THEN CONTINUE                  & $
  vels_ssti[*,*,j,*] = temp



;;  Define start and end azimuthal angles [deg, DSL]
phi_st_esae    = (phi_esae - dphi_esae/2d0)
phi_st_sste    = (phi_sste - dphi_sste/2d0)
phi_st_ssti    = (phi_ssti - dphi_ssti/2d0)
phi_en_esae    = (phi_esae + dphi_esae/2d0)
phi_en_sste    = (phi_sste + dphi_sste/2d0)
phi_en_ssti    = (phi_ssti + dphi_ssti/2d0)
t_st_zero_esae = REFORM(phi_st_esae[0,0,*])/sprate_esae
t_st_zero_sste = REFORM(phi_st_sste[0,0,*])/sprate_sste
t_st_zero_ssti = REFORM(phi_st_ssti[0,0,*])/sprate_ssti
t_en_zero_esae = REFORM(phi_en_esae[0,0,*])/sprate_esae
t_en_zero_sste = REFORM(phi_en_sste[0,0,*])/sprate_sste
t_en_zero_ssti = REFORM(phi_en_ssti[0,0,*])/sprate_ssti
t_off_st_esae  = DBLARR(n_e_esae[0],n_a_esae[0],n_esae[0])
t_off_st_sste  = DBLARR(n_e_sste[0],n_a_sste[0],n_sste[0])
t_off_st_ssti  = DBLARR(n_e_ssti[0],n_a_ssti[0],n_ssti[0])
t_off_en_esae  = DBLARR(n_e_esae[0],n_a_esae[0],n_esae[0])
t_off_en_sste  = DBLARR(n_e_sste[0],n_a_sste[0],n_sste[0])
t_off_en_ssti  = DBLARR(n_e_ssti[0],n_a_ssti[0],n_ssti[0])
FOR j=0L, n_esae[0] - 1L DO t_off_st_esae[*,*,j] = (phi_st_esae[*,*,j]/sprate_esae[j]) - t_st_zero_esae[j]
FOR j=0L, n_sste[0] - 1L DO t_off_st_sste[*,*,j] = (phi_st_sste[*,*,j]/sprate_sste[j]) - t_st_zero_sste[j]
FOR j=0L, n_ssti[0] - 1L DO t_off_st_ssti[*,*,j] = (phi_st_ssti[*,*,j]/sprate_ssti[j]) - t_st_zero_ssti[j]
FOR j=0L, n_esae[0] - 1L DO t_off_en_esae[*,*,j] = (phi_en_esae[*,*,j]/sprate_esae[j]) - t_en_zero_esae[j]
FOR j=0L, n_sste[0] - 1L DO t_off_en_sste[*,*,j] = (phi_en_sste[*,*,j]/sprate_sste[j]) - t_en_zero_sste[j]
FOR j=0L, n_ssti[0] - 1L DO t_off_en_ssti[*,*,j] = (phi_en_ssti[*,*,j]/sprate_ssti[j]) - t_en_zero_ssti[j]
FOR j=0L, n_esae[0] - 1L DO t_off_st_esae[*,*,j] -= MIN([t_off_st_esae[*,*,j],t_off_en_esae[*,*,j]],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_st_sste[*,*,j] -= MIN([t_off_st_sste[*,*,j],t_off_en_sste[*,*,j]],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_st_ssti[*,*,j] -= MIN([t_off_st_ssti[*,*,j],t_off_en_ssti[*,*,j]],/NAN)
FOR j=0L, n_esae[0] - 1L DO t_off_en_esae[*,*,j] -= MIN([t_off_st_esae[*,*,j],t_off_en_esae[*,*,j]],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_en_sste[*,*,j] -= MIN([t_off_st_sste[*,*,j],t_off_en_sste[*,*,j]],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_en_ssti[*,*,j] -= MIN([t_off_st_ssti[*,*,j],t_off_en_ssti[*,*,j]],/NAN)

PRINT, minmax(t_off_av_esae), minmax(t_off_av_sste), minmax(t_off_av_ssti) & $
PRINT, minmax(t_off_st_esae), minmax(t_off_st_sste), minmax(t_off_st_ssti) & $
PRINT, minmax(t_off_en_esae), minmax(t_off_en_sste), minmax(t_off_en_ssti)
;;  Remove smallest time --> start time offset = 0 s
FOR j=0L, n_esae[0] - 1L DO t_off_av_esae[*,*,j] -= MIN(t_off_av_esae[*,*,j],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_av_sste[*,*,j] -= MIN(t_off_av_sste[*,*,j],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_av_ssti[*,*,j] -= MIN(t_off_av_ssti[*,*,j],/NAN)
FOR j=0L, n_esae[0] - 1L DO t_off_st_esae[*,*,j] -= MIN(t_off_en_esae[*,*,j],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_st_sste[*,*,j] -= MIN(t_off_en_sste[*,*,j],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_st_ssti[*,*,j] -= MIN(t_off_en_ssti[*,*,j],/NAN)
FOR j=0L, n_esae[0] - 1L DO t_off_en_esae[*,*,j] -= MIN(t_off_en_esae[*,*,j],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_en_sste[*,*,j] -= MIN(t_off_en_sste[*,*,j],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_en_ssti[*,*,j] -= MIN(t_off_en_ssti[*,*,j],/NAN)
;;  Remove smallest time --> start time offset = 0 s
FOR j=0L, n_esae[0] - 1L DO t_off_av_esae[*,*,j] -= MIN(t_off_av_esae[*,*,j],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_av_sste[*,*,j] -= MIN(t_off_av_sste[*,*,j],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_av_ssti[*,*,j] -= MIN(t_off_av_ssti[*,*,j],/NAN)
FOR j=0L, n_esae[0] - 1L DO t_off_st_esae[*,*,j] -= MIN(t_off_st_esae[*,*,j],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_st_sste[*,*,j] -= MIN(t_off_st_sste[*,*,j],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_st_ssti[*,*,j] -= MIN(t_off_st_ssti[*,*,j],/NAN)
FOR j=0L, n_esae[0] - 1L DO t_off_en_esae[*,*,j] -= MIN(t_off_st_esae[*,*,j],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_en_sste[*,*,j] -= MIN(t_off_st_sste[*,*,j],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_en_ssti[*,*,j] -= MIN(t_off_st_ssti[*,*,j],/NAN)
;;  Remove smallest time --> start time offset = 0 s
FOR j=0L, n_esae[0] - 1L DO t_off_av_esae[*,*,j] -= MIN(t_off_av_esae[*,*,j],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_av_sste[*,*,j] -= MIN(t_off_av_sste[*,*,j],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_av_ssti[*,*,j] -= MIN(t_off_av_ssti[*,*,j],/NAN)
FOR j=0L, n_esae[0] - 1L DO t_off_st_esae[*,*,j] -= MIN(t_off_st_esae[*,*,j],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_st_sste[*,*,j] -= MIN(t_off_st_sste[*,*,j],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_st_ssti[*,*,j] -= MIN(t_off_st_ssti[*,*,j],/NAN)
FOR j=0L, n_esae[0] - 1L DO t_off_en_esae[*,*,j] -= MIN(t_off_en_esae[*,*,j],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_en_sste[*,*,j] -= MIN(t_off_en_sste[*,*,j],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_en_ssti[*,*,j] -= MIN(t_off_en_ssti[*,*,j],/NAN)

;;  Remove smallest time --> start time offset = 0 s
FOR j=0L, n_esae[0] - 1L DO t_off_av_esae[*,*,j] -= MIN(t_off_av_esae[*,*,j],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_av_sste[*,*,j] -= MIN(t_off_av_sste[*,*,j],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_av_ssti[*,*,j] -= MIN(t_off_av_ssti[*,*,j],/NAN)
FOR j=0L, n_esae[0] - 1L DO t_off_st_esae[*,*,j] -= MIN([t_off_st_esae[*,*,j],t_off_en_esae[*,*,j]],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_st_sste[*,*,j] -= MIN([t_off_st_sste[*,*,j],t_off_en_sste[*,*,j]],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_st_ssti[*,*,j] -= MIN([t_off_st_ssti[*,*,j],t_off_en_ssti[*,*,j]],/NAN)
FOR j=0L, n_esae[0] - 1L DO t_off_en_esae[*,*,j] -= MIN([t_off_st_esae[*,*,j],t_off_en_esae[*,*,j]],/NAN)
FOR j=0L, n_sste[0] - 1L DO t_off_en_sste[*,*,j] -= MIN([t_off_st_sste[*,*,j],t_off_en_sste[*,*,j]],/NAN)
FOR j=0L, n_ssti[0] - 1L DO t_off_en_ssti[*,*,j] -= MIN([t_off_st_ssti[*,*,j],t_off_en_ssti[*,*,j]],/NAN)

;;  Shift angles to offset by zero at start [Assume zero element is starting angle]
phi_esae_off   = phi_esae
phi_sste_off   = phi_sste
phi_ssti_off   = phi_ssti
FOR j=0L, n_esae[0] - 1L DO phi_esae_off[*,*,j] = (phi_esae_off[*,*,j] - phi_esae[0,0,j])
FOR j=0L, n_sste[0] - 1L DO phi_sste_off[*,*,j] = (phi_sste_off[*,*,j] - phi_sste[0,0,j])
FOR j=0L, n_ssti[0] - 1L DO phi_ssti_off[*,*,j] = (phi_ssti_off[*,*,j] - phi_ssti[0,0,j])
FOR j=0L, n_esae[0] - 1L DO phi_st_esae[*,*,j]  = (phi_st_esae[*,*,j] - phi_st_esae[0,0,j]) + 36d1
FOR j=0L, n_sste[0] - 1L DO phi_st_sste[*,*,j]  = (phi_st_sste[*,*,j] - phi_st_sste[0,0,j]) + 36d1
FOR j=0L, n_ssti[0] - 1L DO phi_st_ssti[*,*,j]  = (phi_st_ssti[*,*,j] - phi_st_ssti[0,0,j]) + 36d1
FOR j=0L, n_esae[0] - 1L DO phi_en_esae[*,*,j]  = (phi_en_esae[*,*,j] - phi_en_esae[0,0,j]) + 36d1
FOR j=0L, n_sste[0] - 1L DO phi_en_sste[*,*,j]  = (phi_en_sste[*,*,j] - phi_en_sste[0,0,j]) + 36d1
FOR j=0L, n_ssti[0] - 1L DO phi_en_ssti[*,*,j]  = (phi_en_ssti[*,*,j] - phi_en_ssti[0,0,j]) + 36d1

;;  Remove smallest angle --> start angle = 0 deg
FOR j=0L, n_esae[0] - 1L DO phi_esae_off[*,*,j] -= MIN(phi_esae_off[*,*,j],/NAN)
FOR j=0L, n_sste[0] - 1L DO phi_sste_off[*,*,j] -= MIN(phi_sste_off[*,*,j],/NAN)
FOR j=0L, n_ssti[0] - 1L DO phi_ssti_off[*,*,j] -= MIN(phi_ssti_off[*,*,j],/NAN)
;;  Define start and end times [sec, offset from start of VDF] of each aziumthal bin
t_off_av_esae  = DBLARR(n_e_esae[0],n_a_esae[0],n_esae[0])
t_off_av_sste  = DBLARR(n_e_sste[0],n_a_sste[0],n_sste[0])
t_off_av_ssti  = DBLARR(n_e_ssti[0],n_a_ssti[0],n_ssti[0])
FOR j=0L, n_esae[0] - 1L DO t_off_av_esae[*,*,j] = phi_esae_off[*,*,j]/sprate_esae[j]
FOR j=0L, n_sste[0] - 1L DO t_off_av_sste[*,*,j] = phi_sste_off[*,*,j]/sprate_sste[j]
FOR j=0L, n_ssti[0] - 1L DO t_off_av_ssti[*,*,j] = phi_ssti_off[*,*,j]/sprate_ssti[j]
;;  Adjust by 1/2 the total accumulation times
dt_off_st_esae = t_off_av_esae + dt_esae/2d0
dt_off_st_sste = t_off_av_sste + dt_sste/2d0
dt_off_st_ssti = t_off_av_ssti + dt_ssti/2d0
;;  Define time stamps [Unix] associated with each angle bin
t_phi_esae     = 


;;  Define start and end azimuthal angles [deg, DSL]
phi_st_esae    = (phi_esae - dphi_esae/2d0)
phi_st_sste    = (phi_sste - dphi_sste/2d0)
phi_st_ssti    = (phi_ssti - dphi_ssti/2d0)
phi_en_esae    = (phi_esae + dphi_esae/2d0)
phi_en_sste    = (phi_sste + dphi_sste/2d0)
phi_en_ssti    = (phi_ssti + dphi_ssti/2d0)
;;  Shift angles to offset by zero at start [Assume zero element is starting angle]
FOR j=0L, n_esae[0] - 1L DO phi_st_esae[*,*,j] = (phi_st_esae[*,*,j] - phi_st_esae[0,0,j])
FOR j=0L, n_sste[0] - 1L DO phi_st_sste[*,*,j] = (phi_st_sste[*,*,j] - phi_st_sste[0,0,j])
FOR j=0L, n_ssti[0] - 1L DO phi_st_ssti[*,*,j] = (phi_st_ssti[*,*,j] - phi_st_ssti[0,0,j])
FOR j=0L, n_esae[0] - 1L DO phi_en_esae[*,*,j] = (phi_en_esae[*,*,j] - phi_st_esae[0,0,j])
FOR j=0L, n_sste[0] - 1L DO phi_en_sste[*,*,j] = (phi_en_sste[*,*,j] - phi_st_sste[0,0,j])
FOR j=0L, n_ssti[0] - 1L DO phi_en_ssti[*,*,j] = (phi_en_ssti[*,*,j] - phi_st_ssti[0,0,j])
;;  Remove smallest angle --> start angle = 0 deg
FOR j=0L, n_esae[0] - 1L DO phi_st_esae[*,*,j] -= MIN(phi_st_esae[*,*,j],/NAN)
FOR j=0L, n_sste[0] - 1L DO phi_st_sste[*,*,j] -= MIN(phi_st_sste[*,*,j],/NAN)
FOR j=0L, n_ssti[0] - 1L DO phi_st_ssti[*,*,j] -= MIN(phi_st_ssti[*,*,j],/NAN)
FOR j=0L, n_esae[0] - 1L DO phi_en_esae[*,*,j] -= MIN(phi_st_esae[*,*,j],/NAN)
FOR j=0L, n_sste[0] - 1L DO phi_en_sste[*,*,j] -= MIN(phi_st_sste[*,*,j],/NAN)
FOR j=0L, n_ssti[0] - 1L DO phi_en_ssti[*,*,j] -= MIN(phi_st_ssti[*,*,j],/NAN)
;;  Interpolate to VDF times and use average
spper_st_esae  = interp(spper_v,spper_t,t_st_esae,/NO_EXTRAP)
spper_st_sste  = interp(spper_v,spper_t,t_st_sste,/NO_EXTRAP)
spper_st_ssti  = interp(spper_v,spper_t,t_st_ssti,/NO_EXTRAP)
spper_en_esae  = interp(spper_v,spper_t,t_en_esae,/NO_EXTRAP)
spper_en_sste  = interp(spper_v,spper_t,t_en_sste,/NO_EXTRAP)
spper_en_ssti  = interp(spper_v,spper_t,t_en_ssti,/NO_EXTRAP)
spper_av_esae  = (spper_st_esae + spper_en_esae)/2d0
spper_av_sste  = (spper_st_sste + spper_en_sste)/2d0
spper_av_ssti  = (spper_st_ssti + spper_en_ssti)/2d0
;;  Compute spin rate [deg/s]
sprate_esae    = 36d1/spper_av_esae
sprate_sste    = 36d1/spper_av_sste
sprate_ssti    = 36d1/spper_av_ssti
;;  Define start and end times [s offset from start of VDF] of each aziumthal bin
t_off_st_esae  = DBLARR(n_e_esae[0],n_a_esae[0],n_esae[0])
t_off_st_sste  = DBLARR(n_e_sste[0],n_a_sste[0],n_sste[0])
t_off_st_ssti  = DBLARR(n_e_ssti[0],n_a_ssti[0],n_ssti[0])
t_off_en_esae  = DBLARR(n_e_esae[0],n_a_esae[0],n_esae[0])
t_off_en_sste  = DBLARR(n_e_sste[0],n_a_sste[0],n_sste[0])
t_off_en_ssti  = DBLARR(n_e_ssti[0],n_a_ssti[0],n_ssti[0])
FOR j=0L, n_esae[0] - 1L DO t_off_st_esae[*,*,j] = phi_st_esae[*,*,j]/sprate_esae[j]
FOR j=0L, n_sste[0] - 1L DO t_off_st_sste[*,*,j] = phi_st_sste[*,*,j]/sprate_sste[j]
FOR j=0L, n_ssti[0] - 1L DO t_off_st_ssti[*,*,j] = phi_st_ssti[*,*,j]/sprate_ssti[j]
FOR j=0L, n_esae[0] - 1L DO t_off_en_esae[*,*,j] = phi_en_esae[*,*,j]/sprate_esae[j]
FOR j=0L, n_sste[0] - 1L DO t_off_en_sste[*,*,j] = phi_en_sste[*,*,j]/sprate_sste[j]
FOR j=0L, n_ssti[0] - 1L DO t_off_en_ssti[*,*,j] = phi_en_ssti[*,*,j]/sprate_ssti[j]
t_off_av_esae  = (t_off_st_esae + t_off_en_esae)/2d0
t_off_av_sste  = (t_off_st_sste + t_off_en_sste)/2d0
t_off_av_ssti  = (t_off_st_ssti + t_off_en_ssti)/2d0
;;  Define time duration [s] of each aziumthal bin
dt_phi_esae    = DBLARR(n_e_esae[0],n_a_esae[0],n_esae[0])    ;;  Time duration [s] for each EESA bin
dt_phi_sste    = DBLARR(n_e_sste[0],n_a_sste[0],n_sste[0])    ;;  Time duration [s] for each EESA bin
dt_phi_ssti    = DBLARR(n_e_ssti[0],n_a_ssti[0],n_ssti[0])    ;;  Time duration [s] for each EESA bin
FOR j=0L, n_esae[0] - 1L DO dt_phi_esae[*,*,j] = (phi_en_esae[*,*,j] - phi_st_esae[*,*,j])/sprate_esae[j]
FOR j=0L, n_sste[0] - 1L DO dt_phi_sste[*,*,j] = (phi_en_sste[*,*,j] - phi_st_sste[*,*,j])/sprate_sste[j]
FOR j=0L, n_ssti[0] - 1L DO dt_phi_ssti[*,*,j] = (phi_en_ssti[*,*,j] - phi_st_ssti[*,*,j])/sprate_ssti[j]









phi_st_esae    = (phi_esae - dphi_esae/2d0) + 36d1
phi_st_sste    = (phi_sste - dphi_sste/2d0) + 36d1
phi_st_ssti    = (phi_ssti - dphi_ssti/2d0) + 36d1
phi_en_esae    = (phi_esae + dphi_esae/2d0) + 36d1
phi_en_sste    = (phi_sste + dphi_sste/2d0) + 36d1
phi_en_ssti    = (phi_ssti + dphi_ssti/2d0) + 36d1

phi_st_esae    = (phi_esae - dphi_esae/2d0 + 36d1) MOD 36d1
phi_st_sste    = (phi_sste - dphi_sste/2d0 + 36d1) MOD 36d1
phi_st_ssti    = (phi_ssti - dphi_ssti/2d0 + 36d1) MOD 36d1
phi_en_esae    = (phi_esae + dphi_esae/2d0 + 36d1) MOD 36d1
phi_en_sste    = (phi_sste + dphi_sste/2d0 + 36d1) MOD 36d1
phi_en_ssti    = (phi_ssti + dphi_ssti/2d0 + 36d1) MOD 36d1

FOR j=0L, n_esae[0] - 1L DO IF (phi_st_esae[0,0,j] NE 0) THEN phi_st_esae[*,*,j] = ((phi_st_esae[*,*,j] - phi_st_esae[0,0,j]) + 36d1) MOD 36d1
FOR j=0L, n_sste[0] - 1L DO IF (phi_st_sste[0,0,j] NE 0) THEN phi_st_sste[*,*,j] = ((phi_st_sste[*,*,j] - phi_st_sste[0,0,j]) + 36d1) MOD 36d1
FOR j=0L, n_ssti[0] - 1L DO IF (phi_st_ssti[0,0,j] NE 0) THEN phi_st_ssti[*,*,j] = ((phi_st_ssti[*,*,j] - phi_st_ssti[0,0,j]) + 36d1) MOD 36d1
FOR j=0L, n_esae[0] - 1L DO IF (phi_st_esae[0,0,j] NE 0) THEN phi_en_esae[*,*,j] = ((phi_en_esae[*,*,j] - phi_en_esae[0,0,j]) + 36d1) MOD 36d1
FOR j=0L, n_sste[0] - 1L DO IF (phi_st_sste[0,0,j] NE 0) THEN phi_en_sste[*,*,j] = ((phi_en_sste[*,*,j] - phi_en_sste[0,0,j]) + 36d1) MOD 36d1
FOR j=0L, n_ssti[0] - 1L DO IF (phi_st_ssti[0,0,j] NE 0) THEN phi_en_ssti[*,*,j] = ((phi_en_ssti[*,*,j] - phi_en_ssti[0,0,j]) + 36d1) MOD 36d1

FOR j=0L, n_esae[0] - 1L DO IF (phi_st_esae[0,0,j] NE 0) THEN phi_st_esae[*,*,j] = ((phi_st_esae[*,*,j] - phi_st_esae[0,0,j]) + 36d1) MOD 36d1
FOR j=0L, n_sste[0] - 1L DO IF (phi_st_sste[0,0,j] NE 0) THEN phi_st_sste[*,*,j] = ((phi_st_sste[*,*,j] - phi_st_sste[0,0,j]) + 36d1) MOD 36d1
FOR j=0L, n_ssti[0] - 1L DO IF (phi_st_ssti[0,0,j] NE 0) THEN phi_st_ssti[*,*,j] = ((phi_st_ssti[*,*,j] - phi_st_ssti[0,0,j]) + 36d1) MOD 36d1
FOR j=0L, n_esae[0] - 1L DO IF (phi_st_esae[0,0,j] NE 0) THEN phi_en_esae[*,*,j] = ((phi_en_esae[*,*,j] - phi_st_esae[0,0,j]) + 36d1) MOD 36d1
FOR j=0L, n_sste[0] - 1L DO IF (phi_st_sste[0,0,j] NE 0) THEN phi_en_sste[*,*,j] = ((phi_en_sste[*,*,j] - phi_st_sste[0,0,j]) + 36d1) MOD 36d1
FOR j=0L, n_ssti[0] - 1L DO IF (phi_st_ssti[0,0,j] NE 0) THEN phi_en_ssti[*,*,j] = ((phi_en_ssti[*,*,j] - phi_st_ssti[0,0,j]) + 36d1) MOD 36d1

FOR j=0L, n_esae[0] - 1L DO IF (phi_st_esae[0,0,j] NE 0) THEN phi_st_esae[*,*,j] = (phi_st_esae[*,*,j] - phi_st_esae[0,0,j])
FOR j=0L, n_sste[0] - 1L DO IF (phi_st_sste[0,0,j] NE 0) THEN phi_st_sste[*,*,j] = (phi_st_sste[*,*,j] - phi_st_sste[0,0,j])
FOR j=0L, n_ssti[0] - 1L DO IF (phi_st_ssti[0,0,j] NE 0) THEN phi_st_ssti[*,*,j] = (phi_st_ssti[*,*,j] - phi_st_ssti[0,0,j])
FOR j=0L, n_esae[0] - 1L DO IF (phi_st_esae[0,0,j] NE 0) THEN phi_en_esae[*,*,j] = (phi_en_esae[*,*,j] - phi_st_esae[0,0,j])
FOR j=0L, n_sste[0] - 1L DO IF (phi_st_sste[0,0,j] NE 0) THEN phi_en_sste[*,*,j] = (phi_en_sste[*,*,j] - phi_st_sste[0,0,j])
FOR j=0L, n_ssti[0] - 1L DO IF (phi_st_ssti[0,0,j] NE 0) THEN phi_en_ssti[*,*,j] = (phi_en_ssti[*,*,j] - phi_st_ssti[0,0,j])

FOR j=0L, n_esae[0] - 1L DO IF (phi_st_esae[0,0,j] NE 0) THEN phi_st_esae[*,*,j] = (phi_st_esae[*,*,j] - phi_st_esae[0,0,j]) + 36d1
FOR j=0L, n_sste[0] - 1L DO IF (phi_st_sste[0,0,j] NE 0) THEN phi_st_sste[*,*,j] = (phi_st_sste[*,*,j] - phi_st_sste[0,0,j]) + 36d1
FOR j=0L, n_ssti[0] - 1L DO IF (phi_st_ssti[0,0,j] NE 0) THEN phi_st_ssti[*,*,j] = (phi_st_ssti[*,*,j] - phi_st_ssti[0,0,j]) + 36d1
FOR j=0L, n_esae[0] - 1L DO IF (phi_st_esae[0,0,j] NE 0) THEN phi_en_esae[*,*,j] = (phi_en_esae[*,*,j] - phi_st_esae[0,0,j]) + 36d1
FOR j=0L, n_sste[0] - 1L DO IF (phi_st_sste[0,0,j] NE 0) THEN phi_en_sste[*,*,j] = (phi_en_sste[*,*,j] - phi_st_sste[0,0,j]) + 36d1
FOR j=0L, n_ssti[0] - 1L DO IF (phi_st_ssti[0,0,j] NE 0) THEN phi_en_ssti[*,*,j] = (phi_en_ssti[*,*,j] - phi_st_ssti[0,0,j]) + 36d1

FOR j=0L, n_esae[0] - 1L DO phi_st_esae[*,*,j] = (phi_st_esae[*,*,j] - phi_st_esae[0,0,j])
FOR j=0L, n_sste[0] - 1L DO phi_st_sste[*,*,j] = (phi_st_sste[*,*,j] - phi_st_sste[0,0,j])
FOR j=0L, n_ssti[0] - 1L DO phi_st_ssti[*,*,j] = (phi_st_ssti[*,*,j] - phi_st_ssti[0,0,j])
FOR j=0L, n_esae[0] - 1L DO phi_en_esae[*,*,j] = (phi_en_esae[*,*,j] - phi_en_esae[0,0,j])
FOR j=0L, n_sste[0] - 1L DO phi_en_sste[*,*,j] = (phi_en_sste[*,*,j] - phi_en_sste[0,0,j])
FOR j=0L, n_ssti[0] - 1L DO phi_en_ssti[*,*,j] = (phi_en_ssti[*,*,j] - phi_en_ssti[0,0,j])

FOR j=0L, n_esae[0] - 1L DO phi_st_esae[*,*,j] = (phi_st_esae[*,*,j] - phi_st_esae[0,0,j])
FOR j=0L, n_sste[0] - 1L DO phi_st_sste[*,*,j] = (phi_st_sste[*,*,j] - phi_st_sste[0,0,j])
FOR j=0L, n_ssti[0] - 1L DO phi_st_ssti[*,*,j] = (phi_st_ssti[*,*,j] - phi_st_ssti[0,0,j])
FOR j=0L, n_esae[0] - 1L DO phi_en_esae[*,*,j] = (phi_en_esae[*,*,j] - phi_st_esae[0,0,j])
FOR j=0L, n_sste[0] - 1L DO phi_en_sste[*,*,j] = (phi_en_sste[*,*,j] - phi_st_sste[0,0,j])
FOR j=0L, n_ssti[0] - 1L DO phi_en_ssti[*,*,j] = (phi_en_ssti[*,*,j] - phi_st_ssti[0,0,j])

FOR j=0L, n_esae[0] - 1L DO phi_st_esae[*,*,j] = (phi_st_esae[*,*,j] - phi_st_esae[0,0,j]) + 36d1
FOR j=0L, n_sste[0] - 1L DO phi_st_sste[*,*,j] = (phi_st_sste[*,*,j] - phi_st_sste[0,0,j]) + 36d1
FOR j=0L, n_ssti[0] - 1L DO phi_st_ssti[*,*,j] = (phi_st_ssti[*,*,j] - phi_st_ssti[0,0,j]) + 36d1
FOR j=0L, n_esae[0] - 1L DO phi_en_esae[*,*,j] = (phi_en_esae[*,*,j] - phi_en_esae[0,0,j]) + 36d1
FOR j=0L, n_sste[0] - 1L DO phi_en_sste[*,*,j] = (phi_en_sste[*,*,j] - phi_en_sste[0,0,j]) + 36d1
FOR j=0L, n_ssti[0] - 1L DO phi_en_ssti[*,*,j] = (phi_en_ssti[*,*,j] - phi_en_ssti[0,0,j]) + 36d1

FOR j=0L, n_esae[0] - 1L DO phi_st_esae[*,*,j] = (phi_st_esae[*,*,j] - phi_st_esae[0,0,j]) + 36d1
FOR j=0L, n_sste[0] - 1L DO phi_st_sste[*,*,j] = (phi_st_sste[*,*,j] - phi_st_sste[0,0,j]) + 36d1
FOR j=0L, n_ssti[0] - 1L DO phi_st_ssti[*,*,j] = (phi_st_ssti[*,*,j] - phi_st_ssti[0,0,j]) + 36d1
FOR j=0L, n_esae[0] - 1L DO phi_en_esae[*,*,j] = (phi_en_esae[*,*,j] - phi_st_esae[0,0,j]) + 36d1
FOR j=0L, n_sste[0] - 1L DO phi_en_sste[*,*,j] = (phi_en_sste[*,*,j] - phi_st_sste[0,0,j]) + 36d1
FOR j=0L, n_ssti[0] - 1L DO phi_en_ssti[*,*,j] = (phi_en_ssti[*,*,j] - phi_st_ssti[0,0,j]) + 36d1










