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
;;  Plot stacked spectra of TIFP [zooms of EESA times]
;;----------------------------------------------------------------------------------------
;;  Define some defaults/constants
time_se        = tr_eesa[*,0]                  ;;  Use EESA Burst start times
units          = 'flux'
dir_inds       = [0L,3L,6L]
dir_midnms     = ['para','perp','anti']
fmid           = 'TIFP_examples_EESABurst-Times_'
tz_70_str      = {T0:tr_slam_70,T1:tr_hfa__70,T2:tr_fb___70}
nt             = N_TAGS(tz_70_str)
tags           = TAG_NAMES(tz_70_str)
popen_str      = {PORT:1,UNITS:'inches',XSIZE:8.5,YSIZE:11.}
;;  Define earth-vec and b-vec TPLOT handles
all_bv_tpns    = [[eepad_spec_fac[dir_inds]],[iepad_spec_fac[dir_inds]],[sebfpd_specfac[dir_inds]],[sifpad_specfac[dir_inds]]]
all_ev_tpns    = [[eepad_spec_tpn[dir_inds]],[iepad_spec_tpn[dir_inds]],[sebfpd_spectpn[dir_inds]],[sifpad_spectpn[dir_inds]]]

;;  Plot ±70s zooms of TIFP [just fgh]
fprefs         = 'THM-'+scu[0]+'_Bo-fgh_GSE_'
nd             = N_ELEMENTS(fprefs)
DELVAR,fnames
;;  Define file names
FOR j=0L, nt[0] - 1L DO BEGIN                                                 $
  tras0   = tz_70_str.(j)                                                   & $
  tra_st  = REFORM(tras0[*,0])                                              & $
  tra_en  = REFORM(tras0[*,1])                                              & $
  fn_st   = file_name_times(tra_st,PREC=3)                                  & $
  fn_en   = file_name_times(tra_en,PREC=3)                                  & $
  f_times = fn_st.F_TIME+'-'+STRMID(fn_en.F_TIME,11L)                       & $
  fname0  = fprefs[0]+fmid[0]+f_times                                       & $
  str_element,fnames,tags[j],fname0,/ADD_REPLACE

;;  Plot zooms
FOR j=0L, nt[0] - 1L DO BEGIN                                                 $
  tras0   = tz_70_str.(j)                                                   & $
  ntr     = N_ELEMENTS(tras0[*,0])                                          & $
  fname0  = fnames.(j)                                                      & $
  nna     = fgh_tpns                                                        & $
  FOR k=0L, ntr[0] - 1L DO BEGIN                                              $
    fnam0        = fname0[k]                                                & $
    tra0         = REFORM(tras0[k,*])                                       & $
    tplot,nna,TRANGE=tra0                                                   & $
    time_bar,time_se,COLOR=250                                              & $
    popen,fnam0[0],_EXTRA=popen_str                                         & $
      tplot,nna,TRANGE=tra0                                                 & $
      time_bar,time_se,COLOR=250                                            & $
    pclose


;;  Plot ±70s zooms of TIFP [earthward-{para,perp,anti} and magf-{para,perp,anti} fluxes]
fprefs_bv      = 'THM-'+scu[0]+'_Bo-fgl_FAC-'+dir_midnms+'_'+units[0]+'_peeb_peib_psebf_psif_'
fprefs_ev      = 'THM-'+scu[0]+'_Bo-fgl_earthward-'+dir_midnms+'_'+units[0]+'_peeb_peib_psebf_psif_'
nd_bv          = N_ELEMENTS(fprefs_bv)
nd_ev          = N_ELEMENTS(fprefs_ev)

DELVAR,fnames_bv,fnames_ev
;;  Define file names
FOR j=0L, nt[0] - 1L DO BEGIN                                                 $
  tras0   = tz_70_str.(j)                                                   & $
  tra_st  = REFORM(tras0[*,0])                                              & $
  tra_en  = REFORM(tras0[*,1])                                              & $
  fn_st   = file_name_times(tra_st,PREC=3)                                  & $
  fn_en   = file_name_times(tra_en,PREC=3)                                  & $
  f_times = fn_st.F_TIME+'-'+STRMID(fn_en.F_TIME,11L)                       & $
  fname0  = STRARR(N_ELEMENTS(f_times),nd_bv)                               & $
  fname1  = STRARR(N_ELEMENTS(f_times),nd_ev)                               & $
  FOR k=0L, nd_bv[0] - 1L DO fname0[*,k] = fprefs_bv[k]+fmid[0]+f_times     & $
  FOR k=0L, nd_ev[0] - 1L DO fname1[*,k] = fprefs_ev[k]+fmid[0]+f_times     & $
  str_element,fnames_bv,tags[j],fname0,/ADD_REPLACE                         & $
  str_element,fnames_ev,tags[j],fname1,/ADD_REPLACE

nd             = (nd_bv[0] < nd_ev[0])
;;  Plot zooms
FOR j=0L, nt[0] - 1L DO BEGIN                                                 $
  tras0   = tz_70_str.(j)                                                   & $
  ntr     = N_ELEMENTS(tras0[*,0])                                          & $
  fname0  = fnames_bv.(j)                                                   & $
  fname1  = fnames_ev.(j)                                                   & $
  FOR i=0L, nd[0] - 1L DO BEGIN                                               $
    nna0           = [fgl_tpns,REFORM(all_bv_tpns[i,*])]                    & $
    nna1           = [fgl_tpns,REFORM(all_ev_tpns[i,*])]                    & $
    FOR k=0L, ntr[0] - 1L DO BEGIN                                            $
      fnam0        = fname0[k,i]                                            & $
      fnam1        = fname1[k,i]                                            & $
      tra0         = REFORM(tras0[k,*])                                     & $
      tplot,nna0,TRANGE=tra0                                                & $
      time_bar,time_se,COLOR=250                                            & $
      popen,fnam0[0],_EXTRA=popen_str                                       & $
        tplot,nna0,TRANGE=tra0                                              & $
        time_bar,time_se,COLOR=250                                          & $
      pclose                                                                & $
      tplot,nna1,TRANGE=tra0                                                & $
      time_bar,time_se,COLOR=250                                            & $
      popen,fnam1[0],_EXTRA=popen_str                                       & $
        tplot,nna1,TRANGE=tra0                                              & $
        time_bar,time_se,COLOR=250                                          & $
      pclose



