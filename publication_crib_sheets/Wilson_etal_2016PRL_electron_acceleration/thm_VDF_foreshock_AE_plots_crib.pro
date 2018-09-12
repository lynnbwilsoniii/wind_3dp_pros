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
;no_load_vdfs   = 0b                    ;;  --> do load particle VDFs
no_load_vdfs   = 1b                    ;;  --> do NOT load particle VDFs

ex_start       = SYSTIME(1)            ;;  Time the execution of all events within
@$HOME/Desktop/swidl-0.1/IDL_Stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_themis_foreshock_eVDFs_all_data_batch.pro
MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;;  Clean up
bad_fit_tpn    = [tnames('*fit*'),tnames('*powerlaws*'),tnames('*ener_cutoffs*'),tnames('*red_chisq*')]
bad_spec_tpn   = [tnames(scpref[0]+'magf_*_flux*'),tnames(scpref[0]+'earthvec_*_flux*')]
bad_efi_tpn    = [tnames(scpref[0]+'efp_*'),tnames(scpref[0]+'efw_*')]
bad_scm_tpn    = [tnames(scpref[0]+'scp_*'),tnames(scpref[0]+'scw_*')]
store_data,DELETE=bad_fit_tpn
store_data,DELETE=bad_spec_tpn
store_data,DELETE=bad_efi_tpn
store_data,DELETE=bad_scm_tpn

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
;;----------------------------------------------------------------------------------------
;;  Force AE data onto uniform scale
;;----------------------------------------------------------------------------------------
ae_midnms      = ['AL','AU','AE']
ae_ind_tpn     = tnames(scpref[0]+ae_midnms+'_Index')

alind_ran      = [-36d1,0d0]
auind_ran      = [0d0,20d1]
aeind_ran      = [0d0,50d1]
options,ae_ind_tpn,'YRANGE'
options,ae_ind_tpn[0],YRANGE=alind_ran,/DEF
options,ae_ind_tpn[1],YRANGE=auind_ran,/DEF
options,ae_ind_tpn[2],YRANGE=aeind_ran,/DEF
options,ae_ind_tpn,YGRIDSTYLE=2,YTICKLEN=1e0

;;----------------------------------------------------------------------------------------
;;  Plot Bo and AE data overview
;;----------------------------------------------------------------------------------------
popen_str      = {PORT:1,UNITS:'inches',XSIZE:8.5,YSIZE:11.}
;;  Define AE index names
fprefs         = 'THM-'+scu[0]+'_Bo-fgl_GSE_AL-AU-AE-Inds_'
fmid           = 'TIFP_red-SLAMS_orange-HFA_purple-FB_'
fnm_times      = file_name_times(tra_overv,PREC=0)
f_times        = fnm_times.F_TIME[0]+'-'+STRMID(fnm_times.F_TIME[1],11L)
fnames         = fprefs[0]+fmid[0]+f_times[0]

nna            = [fgl_tpns,ae_ind_tpn]
  tplot,nna,TRANGE=tra_overv
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
popen,fnames[0],_EXTRA=popen_str
  tplot,nna,TRANGE=tra_overv
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
pclose




