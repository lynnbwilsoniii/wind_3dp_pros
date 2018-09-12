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
;;  Ignore on 2008-08-19 --> Merge intervals

;;  Some gaps on 2008-08-19 --> Merge intervals
IF (tdate[0] EQ '2008-08-19') THEN sint_fgh = TEMPORARY([sint_fgh[0],sint_fgh[3:6],sint_fgh[10]])
IF (tdate[0] EQ '2008-08-19') THEN eint_fgh = TEMPORARY([eint_fgh[2],eint_fgh[3:5],eint_fgh[9],eint_fgh[13]])
t_st_fgh       = fgh_t[sint_fgh]
t_en_fgh       = fgh_t[eint_fgh]
;;----------------------------------------------------------------------------------------
;;  Define TPLOT handles
;;----------------------------------------------------------------------------------------
dir_inds       = [0L,3L,6L]
vec_str        = ['x','y','z']
vec_col        = [250,150,50]
mid_rfb        = ['r','f','b']
mid_ei_str     = ['e','i']
mid_esa_e_nms  = 'pe'+mid_ei_str[0]+mid_rfb
mid_esa_i_nms  = 'pe'+mid_ei_str[1]+mid_rfb
mid_sst_e_nms  = 'ps'+mid_ei_str[0]+mid_rfb
mid_sst_i_nms  = 'ps'+mid_ei_str[1]+mid_rfb
all_eemom_pref = scpref[0]+mid_esa_e_nms+'_'
all_iemom_pref = scpref[0]+mid_esa_i_nms+'_'
;;  Define earth-vec and b-vec TPLOT handles for spectra
all_bv_tpns    = [[eepad_spec_fac],[iepad_spec_fac],[sebfpd_specfac],[sifpad_specfac]]
all_ev_tpns    = [[eepad_spec_tpn],[iepad_spec_tpn],[sebfpd_spectpn],[sifpad_spectpn]]
papean_bv_tpns = [[eepad_spec_fac[dir_inds]],[iepad_spec_fac[dir_inds]],[sebfpd_specfac[dir_inds]],[sifpad_specfac[dir_inds]]]
papean_ev_tpns = [[eepad_spec_tpn[dir_inds]],[iepad_spec_tpn[dir_inds]],[sebfpd_spectpn[dir_inds]],[sifpad_spectpn[dir_inds]]]
;;  Define omni TPLOT handles
all_omni_tpns  = [eeomni_fac[0],ieomni_fac[0],sebfomnifac[0],sifomnifac[0]]
;;  Define electron velocity moment TPLOT handles
ne_tpns        = all_eemom_pref+'density'
Te_tpns        = all_eemom_pref+'avgtemp'
Ve_tpns        = all_eemom_pref+'velocity_'+coord_gse[0]
dens_e_b_tpns  = ne_tpns[2]
temp_e_b_tpns  = Te_tpns[2]
Vgse_e_b_tpns  = Ve_tpns[2]
;;  Define ion velocity moment TPLOT handles
ni_tpns        = all_iemom_pref+'density'
Ti_tpns        = all_iemom_pref+'avgtemp'
Vi_tpns        = all_iemom_pref+'velocity_'+coord_gse[0]
dens_i_b_tpns  = ni_tpns[2]
temp_i_b_tpns  = Ti_tpns[2]
Vgse_i_b_tpns  = Vi_tpns[2]

;;  Remove "old/default" options
options,[ni_tpns,Ti_tpns,Te_tpns],'YGRIDSTYLE',/DEF
options,[ni_tpns,Ti_tpns,Te_tpns],  'YTICKLEN',/DEF
options,[ni_tpns,Ti_tpns,Te_tpns], 'MAX_VALUE'
options,[ni_tpns,Ti_tpns,Te_tpns],    'YRANGE'
options,[ni_tpns,Ti_tpns,Te_tpns],      'YLOG'
options,[ni_tpns,Ti_tpns,Te_tpns],    'LABELS'
options,[ni_tpns,Ti_tpns,Te_tpns],    'COLORS'
options,Vi_tpns,'YTITLE'
options,Vi_tpns,'COLORS'

;;  Fix YTITLE for bulk flow velocity
options,Vi_tpns[0],YTITLE='Vi [km/s, '+coord_gse[0]+']',YSUBTITLE='[Reduced, All Qs]',/DEF
options,Vi_tpns[1],YTITLE='Vi [km/s, '+coord_gse[0]+']',YSUBTITLE='[Full, All Qs]',/DEF
options,Vgse_i_b_tpns[0],YTITLE='Vi [km/s, '+coord_gse[0]+']',YSUBTITLE='[Burst, All Qs]',/DEF
;;  Define universal YRANGEs for Ni, Ti, and Te [i.e., change after plotting]
ni_yran        = [ 1e-1, 40e0]
Ti_yran        = [ 30e0,300e1]
Te_yran        = [  5e0,300e0]
Vi_yran        = [-75e1,375e0]
;IF (tdate[0] EQ '2008-07-14') THEN ni_yran = [1e-1,20e0]
;IF (tdate[0] EQ '2008-08-19') THEN ni_yran = [1e-1,20e0]
;IF (tdate[0] EQ '2008-09-08') THEN ni_yran = [1e-1,40e0]
;IF (tdate[0] EQ '2008-09-16') THEN ni_yran = [2e-1,30e0]
;IF (tdate[0] EQ '2008-07-14') THEN Ti_yran = [ 5e1,15e2]
;IF (tdate[0] EQ '2008-08-19') THEN Ti_yran = [ 5e1,15e2]
;IF (tdate[0] EQ '2008-09-08') THEN Ti_yran = [ 3e1,30e2]
;IF (tdate[0] EQ '2008-09-16') THEN Ti_yran = [ 3e1,10e2]
;IF (tdate[0] EQ '2008-07-14') THEN Te_yran = [ 5e0,30e1]
;IF (tdate[0] EQ '2008-08-19') THEN Te_yran = [ 5e0,20e1]
;IF (tdate[0] EQ '2008-09-08') THEN Te_yran = [ 5e0,30e1]
;IF (tdate[0] EQ '2008-09-16') THEN Te_yran = [ 5e0,10e1]
FOR k=0L, 2L DO BEGIN                                                    $
  options,ni_tpns[k],LABELS='N_i'+mid_rfb[k],/DEF                      & $
  options,ne_tpns[k],LABELS='N_e'+mid_rfb[k],/DEF                      & $
  options,Ti_tpns[k],LABELS='T_i'+mid_rfb[k],/DEF                      & $
  options,Te_tpns[k],LABELS='T_e'+mid_rfb[k],/DEF                      & $
  options,Vi_tpns[k],LABELS='V_i'+mid_rfb[k]+','+vec_str,/DEF          & $
  options,Ve_tpns[k],LABELS='V_e'+mid_rfb[k]+','+vec_str,/DEF

options,Ti_tpns,MAX_VALUE=15e2,/DEF                            ;;  Ti > 1500 eV  -->  Questionable at best! [in foreshock]
options,Te_tpns,MAX_VALUE=50e1,/DEF                            ;;  Te >  500 eV  -->  Questionable at best! [in foreshock]
options,ni_tpns,YRANGE=ni_yran,YLOG=1,COLORS= 50,/DEF
options,Ti_tpns,YRANGE=Ti_yran,YLOG=1,COLORS= 50,/DEF
options,Te_tpns,YRANGE=Te_yran,YLOG=1,COLORS= 50,/DEF
options,Vi_tpns,YRANGE=Vi_yran,YLOG=0,COLORS=vec_col,/DEF
options,[ni_tpns,Ti_tpns,Te_tpns],YGRIDSTYLE=2,YTICKLEN=1e0    ;;  Add grid lines for reference


;;  Plot B-field and moments
nna            = [fgl_tpns,dens_i_b_tpns[0],Vgse_i_b_tpns[0],temp_e_b_tpns[0],temp_i_b_tpns[0]]
  tplot,nna,TRANGE=tra_overv
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
  time_bar,  t_bs_last,COLOR=100

;;----------------------------------------------------------------------------------------
;;  Define VDF structures only near fgh times
;;----------------------------------------------------------------------------------------
dat_ee         = dat_e
dat_es         = dat_seb
dat_ie         = dat_i
dat_is         = dat_sif
;;  Sort structures by time
sp             = SORT(dat_ee.TIME)
dat_ee         = TEMPORARY(dat_ee[sp])
sp             = SORT(dat_es.TIME)
dat_es         = TEMPORARY(dat_es[sp])
sp             = SORT(dat_ie.TIME)
dat_ie         = TEMPORARY(dat_ie[sp])
sp             = SORT(dat_is.TIME)
dat_is         = TEMPORARY(dat_is[sp])
;;  Define start/end times for EESA and SSTe VDFs
t_st_ee        = dat_ee.TIME
t_en_ee        = dat_ee.END_TIME
t_st_es        = dat_es.TIME
t_en_es        = dat_es.END_TIME
t_st_ie        = dat_ie.TIME
t_en_ie        = dat_ie.END_TIME
t_st_is        = dat_is.TIME
t_en_is        = dat_is.END_TIME
;;  Keep only those within fgh intervals
n_ifgh         = N_ELEMENTS(t_st_fgh)
FOR j=0L, n_ifgh[0] - 1L DO BEGIN                                                               $
  good0_ee = WHERE(t_st_ee GE t_st_fgh[j] AND t_en_ee LE t_en_fgh[j],gd_ee)                   & $
  good0_es = WHERE(t_st_es GE t_st_fgh[j] AND t_en_es LE t_en_fgh[j],gd_es)                   & $
  good0_ie = WHERE(t_st_ie GE t_st_fgh[j] AND t_en_ie LE t_en_fgh[j],gd_ie)                   & $
  good0_is = WHERE(t_st_is GE t_st_fgh[j] AND t_en_is LE t_en_fgh[j],gd_is)                   & $
  IF (gd_ee GT 0) THEN IF (j EQ 0) THEN good_ee = good0_ee ELSE good_ee = [good_ee,good0_ee]  & $
  IF (gd_es GT 0) THEN IF (j EQ 0) THEN good_es = good0_es ELSE good_es = [good_es,good0_es]  & $
  IF (gd_ie GT 0) THEN IF (j EQ 0) THEN good_ie = good0_ie ELSE good_ie = [good_ie,good0_ie]  & $
  IF (gd_is GT 0) THEN IF (j EQ 0) THEN good_is = good0_is ELSE good_is = [good_is,good0_is]

HELP,good_ee,good_es,good_ie,good_is
;;  Redefine structures
dat_ee         = TEMPORARY(dat_ee[good_ee])
dat_es         = TEMPORARY(dat_es[good_es])
dat_ie         = TEMPORARY(dat_ie[good_ie])
dat_is         = TEMPORARY(dat_is[good_is])
;;----------------------------------------------------------------------------------------
;;  Add DSL bulk flow velocities to structures
;;----------------------------------------------------------------------------------------
vbulk_tpn      = scpref[0]+'peib_velocity_'+coord_dsl[0]
add_vsw2,dat_ee,vbulk_tpn[0],/LEAVE_ALONE,VBULK_TAG='velocity'
add_vsw2,dat_es,vbulk_tpn[0],/LEAVE_ALONE,VBULK_TAG='velocity'
add_vsw2,dat_ie,vbulk_tpn[0],/LEAVE_ALONE,VBULK_TAG='velocity'
add_vsw2,dat_is,vbulk_tpn[0],/LEAVE_ALONE,VBULK_TAG='velocity'
;;  Kill "bad" energy bins
f              = !VALUES.F_NAN
temp_data_es   = dat_es.DATA
temp_data_is   = dat_is.DATA
temp_ener_es   = dat_es.ENERGY
temp_ener_is   = dat_is.ENERGY
temp_denr_es   = dat_es.DENERGY
temp_denr_is   = dat_is.DENERGY
bad_es         = WHERE(temp_denr_es LE 0 OR FINITE(temp_denr_es) EQ 0,bd_es)
bad_is         = WHERE(temp_denr_is LE 0 OR FINITE(temp_denr_is) EQ 0,bd_is)
IF (bd_es GT 0) THEN temp_data_es[bad_es] = f
IF (bd_es GT 0) THEN temp_ener_es[bad_es] = f
IF (bd_es GT 0) THEN temp_denr_es[bad_es] = f
IF (bd_is GT 0) THEN temp_data_is[bad_is] = f
IF (bd_is GT 0) THEN temp_ener_is[bad_is] = f
IF (bd_is GT 0) THEN temp_denr_is[bad_is] = f
;;  Redefine arrays within structures
dat_es.DATA    = temp_data_es
dat_es.ENERGY  = temp_ener_es
dat_es.DENERGY = temp_denr_es
dat_is.DATA    = temp_data_is
dat_is.ENERGY  = temp_ener_is
dat_is.DENERGY = temp_denr_is
;;----------------------------------------------------------------------------------------
;;  Calculate moments [SSTe and SSTi]
;;----------------------------------------------------------------------------------------
n_es           = N_ELEMENTS(dat_es)
n_is           = N_ELEMENTS(dat_is)

sform          = moments_3d_new()
str_element,sform,'END_TIME',0d0,/ADD_REPLACE
momb_es        = REPLICATE(sform[0],n_es[0])   ;;  Moments for SSTe VDF
momb_is        = REPLICATE(sform[0],n_is[0])   ;;  Moments for SSTi VDF
;;  SSTe
true_vbulk     = REFORM(dat_es.VELOCITY)
true_magf      = REFORM(dat_es.MAGF)
true_scpot     = REFORM(dat_es.SC_POT[0])
FOR j=0L, n_es[0] - 1L DO BEGIN                                                    $
  tmome      = 0                                                                 & $
  dele       = conv_units(dat_es[j],'eflux')                                     & $
  dphidthe   = dele[0].DPHI*dele[0].DTHETA*(!DPI/18d1)^2                         & $
  sthe       = SIN(dele[0].DTHETA*!DPI/18d1)                                     & $
  domega     = dphidthe*sthe                                                     & $
  str_element,dele,'DOMEGA',domega,/ADD_REPLACE                                  & $
  pot        = true_scpot[j]                                                     & $
  tmagf      = REFORM(true_magf[*,j])                                            & $
  tvsw       = REFORM(true_vbulk[*,j])                                           & $
  ex_str     = {FORMAT:sform,DOMEGA_WEIGHTS:1,TRUE_VBULK:tvsw,MAGDIR:tmagf}      & $
  tmome      = moments_3d_new(dele,SC_POT=pot[0],_EXTRA=ex_str)                  & $
  str_element,tmome,'END_TIME',dele[0].END_TIME,/ADD_REPLACE                     & $
  momb_es[j] = tmome[0]

;;  SSTi
true_vbulk     = REFORM(dat_is.VELOCITY)
true_magf      = REFORM(dat_is.MAGF)
true_scpot     = REFORM(dat_is.SC_POT[0])
FOR j=0L, n_is[0] - 1L DO BEGIN                                                    $
  tmomi      = 0                                                                 & $
  dele       = conv_units(dat_is[j],'eflux')                                     & $
  dphidthe   = dele[0].DPHI*dele[0].DTHETA*(!DPI/18d1)^2                         & $
  sthe       = SIN(dele[0].DTHETA*!DPI/18d1)                                     & $
  domega     = dphidthe*sthe                                                     & $
  str_element,dele,'DOMEGA',domega,/ADD_REPLACE                                  & $
  pot        = true_scpot[j]                                                     & $
  tmagf      = REFORM(true_magf[*,j])                                            & $
  tvsw       = REFORM(true_vbulk[*,j])                                           & $
  ex_str     = {FORMAT:sform,DOMEGA_WEIGHTS:1,TRUE_VBULK:tvsw,MAGDIR:tmagf}      & $
  tmomi      = moments_3d_new(dele,SC_POT=pot[0],_EXTRA=ex_str)                  & $
  str_element,tmomi,'END_TIME',dele[0].END_TIME,/ADD_REPLACE                     & $
  momb_is[j] = tmomi[0]


;;  Define Avg. times [Unix]
unix_sste      = (momb_es.TIME + momb_es.END_TIME)/2d0
unix_ssti      = (momb_is.TIME + momb_is.END_TIME)/2d0
;;  Define SST densities [# cm^(-3)]
dens_sste      = momb_es.DENSITY
dens_ssti      = momb_is.DENSITY
;;  Define SST particle [# cm^(-2) s^(-1)] and energy [eV cm^(-2) s^(-1) sr^(-1) eV^(-1)] fluxes
pflux_sste     = TRANSPOSE(momb_es.FLUX)
pflux_ssti     = TRANSPOSE(momb_is.FLUX)
eflux_sste     = TRANSPOSE(momb_es.EFLUX)
eflux_ssti     = TRANSPOSE(momb_is.EFLUX)
;;  Define SST FA temperature [eV] tensor components [perp1, perp2, para]
magt3_sste     = TRANSPOSE(momb_es.MAGT3)
magt3_ssti     = TRANSPOSE(momb_is.MAGT3)
;;----------------------------------------------------------------------------------------
;;  Send results to TPLOT
;;----------------------------------------------------------------------------------------
all_esmom_pref = scpref[0]+mid_sst_e_nms+'_'
all_ismom_pref = scpref[0]+mid_sst_i_nms+'_'
sst_suffx      = 'SST'+mid_ei_str
ysub_mids      = 'Burst, '+sst_suffx
;;  Define TPLOT handles
dens_sste_tpn  = all_esmom_pref[2]+'density'
dens_ssti_tpn  = all_ismom_pref[1]+'density'
pflx_sste_tpn  = all_esmom_pref[2]+'pflux_'+coord_dsl[0]
pflx_ssti_tpn  = all_ismom_pref[1]+'pflux_'+coord_dsl[0]
eflx_sste_tpn  = all_esmom_pref[2]+'eflux_'+coord_dsl[0]
eflx_ssti_tpn  = all_ismom_pref[1]+'eflux_'+coord_dsl[0]
FAT3_sste_tpn  = all_esmom_pref[2]+'magt3_'+coord_fac[0]
FAT3_ssti_tpn  = all_ismom_pref[1]+'magt3_'+coord_fac[0]

store_data,dens_sste_tpn[0],DATA={X:unix_sste,Y: dens_sste},LIM=def__lim
store_data,pflx_sste_tpn[0],DATA={X:unix_sste,Y:pflux_sste},LIM=def__lim
store_data,eflx_sste_tpn[0],DATA={X:unix_sste,Y:eflux_sste},LIM=def__lim
store_data,FAT3_sste_tpn[0],DATA={X:unix_sste,Y:magt3_sste},LIM=def__lim
store_data,dens_ssti_tpn[0],DATA={X:unix_ssti,Y: dens_ssti},LIM=def__lim
store_data,pflx_ssti_tpn[0],DATA={X:unix_ssti,Y:pflux_ssti},LIM=def__lim
store_data,eflx_ssti_tpn[0],DATA={X:unix_ssti,Y:eflux_ssti},LIM=def__lim
store_data,FAT3_ssti_tpn[0],DATA={X:unix_ssti,Y:magt3_ssti},LIM=def__lim
options,dens_sste_tpn[0],YTITLE='Ne [cm^(-3)]',YSUBTITLE='['+ysub_mids[0]+']',/DEF
options,pflx_sste_tpn[0],YTITLE='Fe [# cm^(-2) s^(-1), '+coord_dsl[0]+']',YSUBTITLE='['+ysub_mids[0]+']',/DEF
options,eflx_sste_tpn[0],YTITLE='Ee ['+ysub_mids[0]+', '+coord_dsl[0]+']',YSUBTITLE='[eV cm^(-2) s^(-1) sr^(-1) eV^(-1)]',/DEF
options,FAT3_sste_tpn[0],YTITLE='Te [eV, FAC]',YSUBTITLE='['+ysub_mids[0]+']',/DEF
options,dens_ssti_tpn[0],YTITLE='Ni [cm^(-3)]',YSUBTITLE='['+ysub_mids[1]+']',/DEF
options,pflx_ssti_tpn[0],YTITLE='Fi [# cm^(-2) s^(-1), '+coord_dsl[0]+']',YSUBTITLE='['+ysub_mids[1]+']',/DEF
options,eflx_ssti_tpn[0],YTITLE='Ei ['+ysub_mids[1]+', '+coord_dsl[0]+']',YSUBTITLE='[eV cm^(-2) s^(-1) sr^(-1) eV^(-1)]',/DEF
options,FAT3_ssti_tpn[0],YTITLE='Ti [eV, FAC]',YSUBTITLE='['+ysub_mids[1]+']',/DEF
options,[pflx_sste_tpn[0],eflx_sste_tpn[0],pflx_ssti_tpn[0],eflx_ssti_tpn[0]],LABELS=vec_str,YLOG=0,COLORS=vec_col,/DEF
options,[FAT3_sste_tpn[0],FAT3_ssti_tpn[0]],LABELS=fac_vec_str,YLOG=0,COLORS=vec_col,/DEF
options,[dens_sste_tpn[0],dens_ssti_tpn[0]],YLOG=1,/DEF

;;  Insert NaNs at intervals
tpn_all_sst    = [dens_sste_tpn[0],dens_ssti_tpn[0],pflx_sste_tpn[0],pflx_ssti_tpn[0]]
tpn_all_sst    = [tpn_all_sst,eflx_sste_tpn[0],eflx_ssti_tpn[0],FAT3_sste_tpn[0],FAT3_ssti_tpn[0]]
t_insert_nan_at_interval_se,tnames(tpn_all_sst),GAP_THRESH=5d0

;;  Remove "bad" spikes by hand
kill_data_tr,NAMES=[dens_sste_tpn[0],pflx_sste_tpn[0],eflx_sste_tpn[0],FAT3_sste_tpn[0]]
kill_data_tr,NAMES=[dens_ssti_tpn[0],pflx_ssti_tpn[0],eflx_ssti_tpn[0],FAT3_ssti_tpn[0]]


;;  Plot B-field and moments
nna0           = [fgl_tpns,dens_i_b_tpns[0],Vgse_i_b_tpns[0],temp_e_b_tpns[0],temp_i_b_tpns[0]]
nna            = [nna0,dens_sste_tpn[0],dens_ssti_tpn[0],pflx_sste_tpn[0],pflx_ssti_tpn[0]]
  tplot,nna,TRANGE=tra_overv
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
  time_bar,  t_bs_last,COLOR=100

nna            = [nna0,dens_sste_tpn[0],dens_ssti_tpn[0],eflx_sste_tpn[0],eflx_ssti_tpn[0]]
  tplot,nna,TRANGE=tra_overv
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
  time_bar,  t_bs_last,COLOR=100
;;----------------------------------------------------------------------------------------
;;  Determine noise level for normalization of fluxes
;;----------------------------------------------------------------------------------------
vbulk_ee       = TRANSPOSE(dat_ee.VELOCITY)
vbulk_ie       = TRANSPOSE(dat_ie.VELOCITY)
vbulk_es       = TRANSPOSE(dat_es.VELOCITY)
vbulk_is       = TRANSPOSE(dat_is.VELOCITY)
;;  Convert to bulk flow rest frame (for energies only)
dat_ee_swf     = transform_vframe_3d_array(dat_ee,vbulk_ee)
dat_ie_swf     = transform_vframe_3d_array(dat_ie,vbulk_ie)
dat_es_swf     = transform_vframe_3d_array(dat_es,vbulk_es)
dat_is_swf     = transform_vframe_3d_array(dat_is,vbulk_is)
;;  Define dummy copies to fill with one-count levels
dat_ee01c      = conv_units(dat_ee,'crate',/FRACTIONAL_COUNTS)
dat_ie01c      = conv_units(dat_ie,'crate',/FRACTIONAL_COUNTS)
dat_es01c      = conv_units(dat_es,'rate')
dat_is01c      = conv_units(dat_is,'rate')
;;  Define data = 1.0 [SCF]
dat_ee01c.DATA = 1e0
dat_es01c.DATA = 1e0
dat_ie01c.DATA = 1e0
dat_is01c.DATA = 1e0
;;  Convert back to counts for later use [SCF]
dat_ee_1c      = conv_units(dat_ee01c,'counts',/FRACTIONAL_COUNTS)
dat_es_1c      = conv_units(dat_es01c,'counts',/FRACTIONAL_COUNTS)
dat_ie_1c      = conv_units(dat_ie01c,'counts')
dat_is_1c      = conv_units(dat_is01c,'counts')
;;  Clean up
DELVAR,dat_ee01c,dat_es01c,dat_ie01c,dat_is01c

;;  Convert to number flux and phase space density for noise levels [SCF]
dat_ee_1c_flux = conv_units(dat_ee_1c,'flux',/FRACTIONAL_COUNTS)
dat_es_1c_flux = conv_units(dat_es_1c,'flux',/FRACTIONAL_COUNTS)
dat_ie_1c_flux = conv_units(dat_ie_1c,'flux')
dat_is_1c_flux = conv_units(dat_is_1c,'flux')
dat_ee_1c___df = conv_units(dat_ee_1c,  'df',/FRACTIONAL_COUNTS)
dat_es_1c___df = conv_units(dat_es_1c,  'df',/FRACTIONAL_COUNTS)
dat_ie_1c___df = conv_units(dat_ie_1c,  'df')
dat_is_1c___df = conv_units(dat_is_1c,  'df')

;;  Check if one-count level changes throughout day  [it does not... use just one for noise levels]
PRINT, minmax(dat_ee_1c_flux[100].DATA,/POS), minmax(dat_ee_1c_flux[500].DATA,/POS), minmax(dat_ee_1c_flux[1000].DATA,/POS)
PRINT, minmax(dat_es_1c_flux[100].DATA,/POS), minmax(dat_es_1c_flux[500].DATA,/POS), minmax(dat_es_1c_flux[1000].DATA,/POS)
PRINT, minmax(dat_ie_1c_flux[100].DATA,/POS), minmax(dat_ie_1c_flux[500].DATA,/POS), minmax(dat_ie_1c_flux[1000].DATA,/POS)
PRINT, minmax(dat_is_1c_flux[100].DATA,/POS), minmax(dat_is_1c_flux[500].DATA,/POS), minmax(dat_is_1c_flux[1000].DATA,/POS)

;;  Define dummy structure for noise estimates
kk             = 500L
dumb_ee_1cflux = dat_ee_1c_flux[kk]
dumb_es_1cflux = dat_es_1c_flux[kk]
dumb_ie_1cflux = dat_ie_1c_flux[kk]
dumb_is_1cflux = dat_is_1c_flux[kk]
dumb_ee_1c__df = dat_ee_1c___df[kk]
dumb_es_1c__df = dat_es_1c___df[kk]
dumb_ie_1c__df = dat_ie_1c___df[kk]
dumb_is_1c__df = dat_is_1c___df[kk]

;;  Calculate average DATA and ENERGY values (average over angles)
data_ee_1cflux = dumb_ee_1cflux[0].DATA
data_es_1cflux = dumb_es_1cflux[0].DATA
data_ie_1cflux = dumb_ie_1cflux[0].DATA
data_is_1cflux = dumb_is_1cflux[0].DATA
ener_ee_1cflux = dat_ee_swf.ENERGY
ener_ie_1cflux = dat_ie_swf.ENERGY
ener_es_1cflux = dat_es_swf.ENERGY
ener_is_1cflux = dat_is_swf.ENERGY
Avgf_ee_1cflux = TOTAL(data_ee_1cflux,2,/NAN,/DOUBLE)/TOTAL(FINITE(data_ee_1cflux),2,/NAN,/DOUBLE)
Avgf_es_1cflux = TOTAL(data_es_1cflux,2,/NAN,/DOUBLE)/TOTAL(FINITE(data_es_1cflux),2,/NAN,/DOUBLE)
Avgf_ie_1cflux = TOTAL(data_ie_1cflux,2,/NAN,/DOUBLE)/TOTAL(FINITE(data_ie_1cflux),2,/NAN,/DOUBLE)
Avgf_is_1cflux = TOTAL(data_is_1cflux,2,/NAN,/DOUBLE)/TOTAL(FINITE(data_is_1cflux),2,/NAN,/DOUBLE)
AvgE_ee_1cflux = TRANSPOSE(TOTAL(ener_ee_1cflux,2,/NAN,/DOUBLE)/TOTAL(FINITE(ener_ee_1cflux),2,/NAN,/DOUBLE))
AvgE_es_1cflux = TRANSPOSE(TOTAL(ener_es_1cflux,2,/NAN,/DOUBLE)/TOTAL(FINITE(ener_es_1cflux),2,/NAN,/DOUBLE))
AvgE_ie_1cflux = TRANSPOSE(TOTAL(ener_ie_1cflux,2,/NAN,/DOUBLE)/TOTAL(FINITE(ener_ie_1cflux),2,/NAN,/DOUBLE))
AvgE_is_1cflux = TRANSPOSE(TOTAL(ener_is_1cflux,2,/NAN,/DOUBLE)/TOTAL(FINITE(ener_is_1cflux),2,/NAN,/DOUBLE))

data_ee_1c__df = dumb_ee_1c__df[0].DATA
data_es_1c__df = dumb_es_1c__df[0].DATA
data_ie_1c__df = dumb_ie_1c__df[0].DATA
data_is_1c__df = dumb_is_1c__df[0].DATA
Avgf_ee_1c__df = TOTAL(data_ee_1c__df,2,/NAN,/DOUBLE)/TOTAL(FINITE(data_ee_1c__df),2,/NAN,/DOUBLE)
Avgf_es_1c__df = TOTAL(data_es_1c__df,2,/NAN,/DOUBLE)/TOTAL(FINITE(data_es_1c__df),2,/NAN,/DOUBLE)
Avgf_ie_1c__df = TOTAL(data_ie_1c__df,2,/NAN,/DOUBLE)/TOTAL(FINITE(data_ie_1c__df),2,/NAN,/DOUBLE)
Avgf_is_1c__df = TOTAL(data_is_1c__df,2,/NAN,/DOUBLE)/TOTAL(FINITE(data_is_1c__df),2,/NAN,/DOUBLE)
AvgE_ee_1c__df = AvgE_ee_1cflux
AvgE_es_1c__df = AvgE_es_1cflux
AvgE_ie_1c__df = AvgE_ie_1cflux
AvgE_is_1c__df = AvgE_is_1cflux

;;  For 2008-07-14, Avg. SSTe over 15:15:30-15:30:00 UTC
;;  For 2008-07-14, Avg. SSTi over 20:32:30-20:53:00 UTC
IF (tdate[0] EQ '2008-07-14') THEN Avgf_es_1cflux[0:5] = Avgf_es_1cflux[0:5] < [0.0042198238d0,0.0012811834d0,0.00060157898d0,0.00026515159d0,7.0481993d-5,3.9979669d-5]
IF (tdate[0] EQ '2008-07-14') THEN Avgf_is_1cflux[0:8] = Avgf_is_1cflux[0:8] < [0.00087181634d0,0.00033157752d0,0.00016527385d0,0.00010523354d0,0.00024535731d0,3.5851380d-5,5.8462911d-5,1.3108120d-5,9.1318015d-6]
;;  For 2008-08-19, Avg. SSTe over 12:53:47.0-12:58:44.5 UTC
;;  For 2008-08-19, Avg. SSTi over 16:01:00.0-16:09:30.0 UTC
IF (tdate[0] EQ '2008-08-19') THEN Avgf_es_1cflux[0:7] = Avgf_es_1cflux[0:7] < [0.0021065777d0,0.00035249503d0,0.00022541027d0,0.00015312852d0,5.0249343d-5,3.8698094d-5,3.4810268d-5,1d-5]
IF (tdate[0] EQ '2008-08-19') THEN Avgf_is_1cflux[0:9] = Avgf_is_1cflux[0:9] < [0.00092949295d0,0.00045455699d0,0.00030954414d0,0.00023610035d0,0.00016265656d0,5.7978870d-5,2.7012872d-5,1.2432507d-5,8.1701585d-6,3.7664474d-6]
;;  For 2008-09-08, Avg. SSTe over 21:07:20-21:18:20 UTC
;;  For 2008-09-08, Avg. SSTi over 17:54:20-17:58:40 UTC
IF (tdate[0] EQ '2008-09-08') THEN Avgf_es_1cflux[0:6] = Avgf_es_1cflux[0:6] < [0.0014574197d0,0.00029245975d0,0.00019690742d0,0.00012535517d0,4.7940972d-5,3.8797345d-5,3.8797345d-5]
IF (tdate[0] EQ '2008-09-08') THEN Avgf_is_1cflux[0:8] = Avgf_is_1cflux[0:8] < [0.0010991218d0,0.00064484494d0,0.00020092360d0,0.00010375266d0,7.8551205d-5,6.0184016d-5,2.8591923d-5,1.9712085d-5,1.9284669d-5]

;;  Averaging commands are below
;;  get_data,all_omni_tpns[2],data=temp,dlim=dlim,lim=lim
;;  tr             = t_get_current_trange()
;;  PRINT,';;',time_string(tr,PREC=3)
;;  clipped        = trange_clip_data(temp,TRANGE=tr,PREC=3)
;;  data_tr        = clipped.Y
;;  ener_tr        = clipped.V
;;  avg_f_tr       = TOTAL(data_tr,1,/NAN,/DOUBLE)/TOTAL(FINITE(data_tr),1,/NAN,/DOUBLE)
;;  avg_E_tr       = TOTAL(ener_tr,1,/NAN,/DOUBLE)/TOTAL(FINITE(ener_tr),1,/NAN,/DOUBLE)
;;  IF (tdate[0] EQ '2008-09-08') THEN avg_f_tr[6] = (avg_f_tr[5] < avg_f_tr[6])
;;  HELP,avg_f_tr,avg_E_tr
;;  PRINT,';;',avg_f_tr
;;  
;;  get_data,all_omni_tpns[3],data=temp1,dlim=dlim1,lim=lim1
;;  tr1            = t_get_current_trange()
;;  PRINT,';;',time_string(tr1,PREC=3)
;;  clipped1       = trange_clip_data(temp1,TRANGE=tr1,PREC=3)
;;  data_tr1       = clipped1.Y
;;  ener_tr1       = clipped1.V
;;  avg_f_tr1      = TOTAL(data_tr1,1,/NAN,/DOUBLE)/TOTAL(FINITE(data_tr1),1,/NAN,/DOUBLE)
;;  avg_E_tr1      = TOTAL(ener_tr1,1,/NAN,/DOUBLE)/TOTAL(FINITE(ener_tr1),1,/NAN,/DOUBLE)
;;  IF (tdate[0] EQ '2008-08-19') THEN avg_f_tr1[3] = (avg_f_tr1[2] + avg_f_tr1[4])/2d0  ;;  need to average due to low flux in the ~75 keV energy channel
;;  IF (tdate[0] EQ '2008-08-19') THEN avg_f_tr1[5:6] = REVERSE(avg_f_tr1[5:6])          ;;  need to switch due to low flux in the ~150 keV energy channel
;;  IF (tdate[0] EQ '2008-09-08') THEN avg_f_tr1[3:4] = REVERSE(avg_f_tr1[3:4])          ;;  need to switch due to low flux in the ~75 keV energy channel
;;  IF (tdate[0] EQ '2008-09-08') THEN avg_f_tr1[5:6] = REVERSE(avg_f_tr1[5:6])          ;;  need to switch due to low flux in the ~150 keV energy channel
;;  HELP,avg_f_tr1,avg_E_tr1
;;  PRINT,';;',avg_f_tr1

;;----------------------------------------------------------------------------------------
;;  Normalize fluxes and create new TPLOT handles
;;----------------------------------------------------------------------------------------
;;  Define start/end times for EESA and SSTe VDFs
t_st_ee        = dat_ee.TIME
t_en_ee        = dat_ee.END_TIME
t_st_es        = dat_es.TIME
t_en_es        = dat_es.END_TIME
t_st_ie        = dat_ie.TIME
t_en_ie        = dat_ie.END_TIME
t_st_is        = dat_is.TIME
t_en_is        = dat_is.END_TIME
t_av_ee        = (t_st_ee + t_en_ee)/2d0
t_av_es        = (t_st_es + t_en_es)/2d0
t_av_ie        = (t_st_ie + t_en_ie)/2d0
t_av_is        = (t_st_is + t_en_is)/2d0
;;  Define old and new TPLOT handles
old_units      = 'flux'
new_units      = 'normalized'
all_insts      = [mid_ei_str+'esa',mid_sst_e_nms[1]+'_'+mid_sst_e_nms[2],mid_sst_i_nms[1]]
mid_swf_tpn    = 'spec_swf'
fac_prefs      = scpref[0]+'magf_'+all_insts+'_'+mid_swf_tpn[0]
Eac_prefs      = scpref[0]+'earthvec_'+all_insts+'_'+mid_swf_tpn[0]
npa            = N_ELEMENTS(all_bv_tpns[*,0])
ninst          = N_ELEMENTS(all_insts)
ll             = LINDGEN(7)
uu             = ll + 1L
dir_suffxs     = '-2-'+STRING(ll,FORMAT='(I1.1)')+':'+STRING(uu,FORMAT='(I1.1)')

old_omni_tpn   = all_omni_tpns
old_facs_tpn   = all_bv_tpns
old_Eacs_tpn   = all_ev_tpns

new_omni_tpn   = fac_prefs+'_omni_'+new_units[0]
new_facs_tpn   = STRARR(npa[0],ninst[0])
new_Eacs_tpn   = STRARR(npa[0],ninst[0])
FOR j=0L, ninst[0] - 1L DO BEGIN                                  $
  new_facs_tpn[*,j] = fac_prefs[j]+'_'+new_units[0]+dir_suffxs  & $
  new_Eacs_tpn[*,j] = Eac_prefs[j]+'_'+new_units[0]+dir_suffxs


n_ener_all     = [N_ELEMENTS(AvgE_ee_1cflux[0,*]),N_ELEMENTS(AvgE_ie_1cflux[0,*]),$
                  N_ELEMENTS(AvgE_es_1cflux[0,*]),N_ELEMENTS(AvgE_is_1cflux[0,*]) ]
all_AvgE_1c    = {T0:AvgE_ee_1cflux,T1:AvgE_ie_1cflux,T2:AvgE_es_1cflux,T3:AvgE_is_1cflux}
all_Avgf_1c    = {T0:Avgf_ee_1cflux,T1:Avgf_ie_1cflux,T2:Avgf_es_1cflux,T3:Avgf_is_1cflux}
all_unix_ta    = {T0:t_av_ee,       T1:t_av_ie,       T2:t_av_es,       T3:t_av_is}
all_yttls      = [mid_esa_e_nms[2],mid_esa_i_nms[2],'ps'+mid_ei_str[0]+mid_rfb[1]+mid_rfb[2],mid_sst_i_nms[1]]+' '+old_units[0]
tags           = TAG_NAMES(all_Avgf_1c)
;;  Calculate normalized OMNI fluxes
FOR j=0L, ninst[0] - 1L DO BEGIN                                                    $
  get_data,old_omni_tpn[j],DATA=temp,DLIM=dlim0,LIM=lim0                          & $
  n_old_e  = N_ELEMENTS(temp.V[0,*])                                              & $
  avg_ener = all_AvgE_1c.(j)                                                      & $
  avg_1cfx = all_Avgf_1c.(j)                                                      & $
  t_avg    = all_unix_ta.(j)                                                      & $
  n_new_e  = N_ELEMENTS(avg_ener[0,*])                                            & $
  gind_t   = VALUE_LOCATE(temp.X,t_avg)                                           & $
  new__t   = temp.X[gind_t]                                                       & $
  nt       = N_ELEMENTS(new__t)                                                   & $
  new__y   = DBLARR(nt[0],n_old_e[0])                                             & $
  new_y0   = temp.Y[gind_t,*]                                                     & $
  new__v   = temp.V[gind_t,*]                                                     & $
  FOR k=0L, nt[0] - 1L DO BEGIN                                                     $
    ee0    = REFORM(new__v[k,*])                                                  & $
    good0  = WHERE(FINITE(ee0) AND ee0 GT 0,gd0)                                  & $
    IF (gd0 EQ 0) THEN CONTINUE                                                   & $
    ee1    = REFORM(avg_ener[k,*])                                                & $
    good1  = WHERE(FINITE(ee1) AND ee1 GT 0,gd1)                                  & $
    IF (gd1 EQ 0) THEN CONTINUE                                                   & $
    test_d = (ee1[good1[2]] GT ee1[good1[3]])                                     & $
    gind_e = VALUE_LOCATE(ee1[good1],ee0)                                         & $
    norm_f = REFORM(avg_1cfx[good1[gind_e] + test_d[0]])                          & $
    orig_f = REFORM(new_y0[k,*])                                                  & $
    rati_f = orig_f[good0]/norm_f[good0]                                          & $
    new__y[k,good0] = rati_f                                                      & $
  ENDFOR                                                                          & $
  new_struc = {X:new__t,Y:new__y,V:new__v}                                        & $
  str_element,dlim0,'DATA_ATT.NORM_VALS',avg_1cfx,/ADD_REPLACE                    & $
  store_data,new_omni_tpn[j],DATA=new_struc,DLIM=dlim0,LIM=lim0

FOR j=0L, ninst[0] - 1L DO options,new_omni_tpn[j],YTITLE=all_yttls[j],/DEF
options,new_omni_tpn,YSUBTITLE='[normalized 1c]',/DEF
options,new_omni_tpn,'YTICKNAME'
options,new_omni_tpn,   'YTICKV'
options,new_omni_tpn,   'YTICKS'
options,new_omni_tpn,   'YRANGE'
options,new_omni_tpn,'YTICKNAME',/DEF
options,new_omni_tpn,   'YTICKV',/DEF
options,new_omni_tpn,   'YTICKS',/DEF
options,new_omni_tpn,   'YRANGE',/DEF
new_zran       = [1e-2,1e3]
new_yran       = [1e2,30e3]
options,new_omni_tpn[1],ZRANGE=new_zran,YRANGE=new_yran,/DEF
t_insert_nan_at_interval_se,tnames(new_omni_tpn),GAP_THRESH=5d0

;;  Plot and examine
nna            = [fgl_tpns,new_omni_tpn]
  tplot,nna,TRANGE=tra_overv
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
  time_bar,  t_bs_last,COLOR=100


nna            = [fgl_tpns,old_omni_tpn]
  tplot,nna,TRANGE=tra_overv
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
  time_bar,  t_bs_last,COLOR=100









;    gind_e = VALUE_LOCATE(REVERSE(ROUND(ee1)),REVERSE(ROUND(ee0)))                & $
;    diff_e = ABS(REFORM(avg_ener[k,*]) - ee0)
;    mndf_e = MIN(diff_e,gind_e,/NAN)
