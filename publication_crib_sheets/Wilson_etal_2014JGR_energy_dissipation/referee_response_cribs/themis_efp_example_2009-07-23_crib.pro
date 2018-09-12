;;----------------------------------------------------------------------------------------
;; => Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;; => Correct initial Rankine-Hugoniot results
;;----------------------------------------------------------------------------------------

;;  NEW Average Shock Terms [2nd Crossing]
vshn_up        =     13.17536258d0
dvshnup        =      6.42775166d0
ushn_up        =   -504.39410371d0
dushnup        =      1.36460201d0
ushn_dn        =   -137.54280834d0
dushndn        =      4.15482271d0
gnorm          = [     0.99382696d0,    -0.10677753d0,    -0.03010859d0]
magf_up        = [    -0.38116612d0,    -0.03737344d0,    -6.40433103d0]
magf_dn        = [     2.50128126d0,   -15.99832368d0,   -13.30333209d0]
theta_Bn       =     88.37446439d0
;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_c_data_2009-07-23_batch.pro

t_ramp_ra0     = time_double(tdate[0]+'/'+['18:04:47.030','18:04:58.920'])
t_ramp_ra1     = time_double(tdate[0]+'/'+['18:07:07.340','18:07:08.100'])
t_ramp_ra2     = time_double(tdate[0]+'/'+['18:24:24.910','18:24:49.450'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = MEAN(t_ramp_ra1,/NAN)
t_ramp2        = MEAN(t_ramp_ra2,/NAN)
nif_suffx_1    = '-RHS01'
nif_suffx_2    = '-RHS02'
nif_suffx_3    = '-RHS03'
scpref         = 'th'+sc[0]+'_'
thprobe        = STRMID(scpref[0],0,3)
traz           = t_ramp1[0] + [-1d0,1d0]*30   ;;  30 s window around ramp

;;  Only need data near 2nd shock, so remove extra TPLOT handles
;;  Good intervals
;;  Particle Burst  :  Interval 0
;;  Wave Burst      :  Interval 1,2
del_data,'*'+nif_suffx_1[0]+'*'
del_data,'*'+nif_suffx_3[0]+'*'

del_data,scpref[0]+'*efp_*_INT001'
del_data,scpref[0]+'efw_*_INT000'
del_data,scpref[0]+'efw_*_INT005'
del_data,scpref[0]+'efw_*_INT006'
del_data,scpref[0]+'*scp_*_INT001'
del_data,scpref[0]+'scw_*_INT000'
del_data,scpref[0]+'scw_*_INT005'
del_data,scpref[0]+'scw_*_INT006'
;;----------------------------------------------------------------------------------------
;;  Define relevant TPLOT handles
;;----------------------------------------------------------------------------------------
mu_str         = get_greek_letter('mu')
vec_str        = ['x','y','z']
vec_cols       = [250L,150L, 50L]
yttl_nif_efi   = 'E [NIF (GSE basis), mV/m]'
yttl_ncb_efi   = 'E [NIF (NCB basis), mV/m]'
ncb_labs       = ['n','y = (b!D2!N x b!D1!N'+')','z = (n x y)']
JodE_units     = mu_str[0]+'W m!U-3!N'
;;  Define DATA_ATT notes
note_nif_gse   = '[data in NIF but still in GSE basis]'
note_nif_ncb   = '[data in NIF and in NIF basis]'
;;  Coordinate strings
coord_mag      = 'mag'
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_fac      = 'fac'
coord_nif      = 'nif_S1986a'+nif_suffx_2[0]
coord_ncb      = 'nif_ncb_S1986a'+nif_suffx_2[0]
;;  Middle parts of TPLOT handles
;;  FGM...
modes_slh      = ['s','l','h']
mode_fgm       = 'fg'+modes_slh
fgm_pren       = scpref[0]+mode_fgm+'_'
;;  SCM...
modes_scm      = 'sc'+['p','w']
scm_midnm      = '_cal_'
;;  EFI...
modes_efi      = 'ef'+['p','w']
efi_midnm      = '_cal_'
efi_nodcnm     = '_cal_rmDCoffsets_'
efp_spinfit_nm = '_cal_despiked_spinfit-model_'
efp_rmspftmod  = '_cal_despiked_rm-spinfit-model_'
;;  State...
state_midnm    = 'state_'
sp_per_suff    = state_midnm[0]+'spinper'
sp_phs_suff    = state_midnm[0]+'spinphase'

;;  State TPLOT handles
sp_per_tpnm    = tnames(scpref[0]+sp_per_suff[0])
sp_phs_tpnm    = tnames(scpref[0]+sp_phs_suff[0])
spphs_int_tpnm = sp_phs_tpnm[0]+'_int'
sunpulse_nm    = scpref[0]+state_midnm[0]+'sun_pulse'
;;  EFI TPLOT handles
efp_dsl_orig   = tnames(pref[0]+modes_efi[0]+efi_midnm[0]+coord_dsl[0]+'*')              ;;  Level-1 efp data [DSL, mV/m]
efw_dsl_orig   = tnames(pref[0]+modes_efi[1]+efi_midnm[0]+coord_dsl[0]+'*')              ;;  Level-1 efw data [DSL, mV/m]
efp_nodc_dsl   = pref[0]+modes_efi[0]+efi_nodcnm[0]+coord_dsl[0]                         ;;  Removed DC-offsets from EFP_DSL_ORIG
;;  SCM TPLOT handles
scp_dsl_orig   = tnames(pref[0]+modes_scm[0]+scm_midnm[0]+coord_dsl[0]+'*')
scw_dsl_orig   = tnames(pref[0]+modes_scm[1]+scm_midnm[0]+coord_dsl[0]+'*')
;;  FGM TPLOT handles
fgm_mag        = tnames(fgm_pren[*]+'mag')
fgm_dsl        = tnames(fgm_pren[*]+coord_dsl[0])
fgm_gse        = tnames(fgm_pren[*]+coord_gse[0])
fgm_gsm        = tnames(fgm_pren[*]+coord_gsm[0])
fgm_ncb        = tnames(fgm_pren[*]+coord_nif[0])  ;;  I screwed up the TPLOT handle, but this is in NCB and NIF
fgs_mag_dsl    = [fgm_mag[0],fgm_dsl[0]]
fgl_mag_dsl    = [fgm_mag[1],fgm_dsl[1]]
fgh_mag_dsl    = [fgm_mag[2],fgm_dsl[2]]
fgm_tpn_str    = {T0:fgs_mag_dsl,T1:fgl_mag_dsl,T2:fgh_mag_dsl}
;;----------------------------------------------------------------------------------------
;;  Determine intervals
;;----------------------------------------------------------------------------------------
;;  Get EFI data
get_data,efp_dsl_orig[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
;;  Define parameters
efp_t          = temp_efp.X
efp_v          = temp_efp.Y
;;  1st remove any DC-offsets from efw
sratefp        = DOUBLE(sample_rate(efp_t,GAP_THRESH=6d0,/AVE))
se_pels        = t_interval_find(efp_t,GAP_THRESH=4d0)
pint           = N_ELEMENTS(se_pels[*,0])
;;  Only use indices near 2nd shock
a_ind          = LINDGEN(N_ELEMENTS(efp_t))
gind           = LONG(a_ind[se_pels[0,0]:se_pels[0,1]])
;;----------------------------------------------------------------------------------------
;;  Plot Data
;;----------------------------------------------------------------------------------------
fgm_mode       = 0L      ;;  fgs
fgm_mode       = 1L      ;;  fgl
fgm_mode       = 2L      ;;  fgh

all_efi_tpnm   = [scp_dsl_orig[0],efp_dsl_orig[0]]
all_fgm_tpnm   = fgm_tpn_str.(fgm_mode[0])
nna            = [all_fgm_tpnm,all_efi_tpnm]

WSET,0
  tplot,nna,TRANGE=traz
;;----------------------------------------------------------------------------------------
;;  Calculate sunpulse data
;;----------------------------------------------------------------------------------------
;;  Get EFI data
get_data,efp_dsl_orig[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
;;  Get spin phase and period
get_data,sp_per_tpnm[0],DATA=temp_sp_per,DLIM=dlim_sp_per,LIM=lim_sp_per
get_data,sp_phs_tpnm[0],DATA=temp_sp_phs,DLIM=dlim_sp_phs,LIM=lim_sp_phs
;;  Define parameters
vec_t          = temp_efp.X
vec_v          = temp_efp.Y
sp_per_t       = temp_sp_per.X
sp_per_v       = temp_sp_per.Y
sp_phs_t       = temp_sp_phs.X
sp_phs_v       = temp_sp_phs.Y
;;  Calculate sunpulse data
thm_sunpulse,sp_per_t,sp_phs_v,sp_per_v,sunpulse,sunp_spinper,PROBE=sc[0],SUNPULSE_NAME=sunpulse_nm[0]
;;----------------------------------------------------------------------------------------
;;  Calculate spin fit model for spin phase
;;----------------------------------------------------------------------------------------
;;  Interpolate spin phase
model          = spinmodel_get_ptr(sc[0],USE_ECLIPSE_CORRECTIONS=use_eclipse_corrections)
spinmodel_interp_t,MODEL=model,TIME=vec_t,SPINPHASE=phase,SPINPER=spinper,USE_SPINPHASE_CORRECTION=1       ;a la J. L.
;;  Send result to TPLOT
struct         = {X:vec_t,Y:phase}
store_data,spphs_int_tpnm[0],DATA=struct,DLIM=dlim_sp_phs,LIM=lim_sp_phs
yttl           = STRUPCASE(sc[0])+' Spin Phase'+'!C'+'[interpolated to efp]'
options,spphs_int_tpnm[0],'YTITLE'
options,spphs_int_tpnm[0],'YTITLE',yttl[0],/DEF
options,spphs_int_tpnm[0],'YRANGE',[-5d0,365d0],/DEF
;;----------------------------------------------------------------------------------------
;;  Calculate spin fit model for DC-coupled fields
;;----------------------------------------------------------------------------------------
;;  Get spin phase and period
get_data,sp_per_tpnm[0],DATA=temp_sp_per,DLIM=dlim_sp_per,LIM=lim_sp_per
get_data,sp_phs_tpnm[0],DATA=temp_sp_phs,DLIM=dlim_sp_phs,LIM=lim_sp_phs
;;  Get EFI data
get_data,efp_dsl_orig[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
;;  Get sunpulse data
get_data,sunpulse_nm[0],DATA=thx_sunpulse_times,DLIM=dlim_sunpulse_times,LIM=lim_sunpulse_times
;;  Get spin phase model values interpolated for efp times
get_data,spphs_int_tpnm[0],DATA=spphs_int,DLIM=dlim_sp_phs,LIM=lim_sp_phs

;;  Define parameters
vec_t          = temp_efp.X
vec_v          = temp_efp.Y
sp_per_t       = temp_sp_per.X
sp_per_v       = temp_sp_per.Y
sp_phs_t       = temp_sp_phs.X
sp_phs_v       = temp_sp_phs.Y
sunp_t         = thx_sunpulse_times.X
sunp_v         = thx_sunpulse_times.Y
sphase_t       = spphs_int.X
sphase_v       = spphs_int.Y
sphase_vr      = sphase_v*!DPI/18d1

;;  First clean up de-spiked efp by removing DC offsets
;;  Use median filter to smooth and then remove DC-offsets
mxpts          = 50L
smpts          = 32L
efp_v_medfilt  = REPLICATE(d,SIZE(efp_v,/DIMENSIONS))
efp_v_nodc     = REPLICATE(d,SIZE(efp_v,/DIMENSIONS))
FOR j=0L, pint - 1L DO BEGIN                                                           $
  st       = se_pels[j,0] + mxpts[0]                                                 & $  ;; stay away from end pts
  en       = se_pels[j,1] - mxpts[0]                                                 & $
  inds     = st[0] + LINDGEN(en[0] - st[0] + 1L)                                     & $
  ind_vec  = vec_v[inds,*]                                                           & $
  t_efpvx  = MEDIAN(ind_vec[*,0],smpts[0],/EVEN)                                     & $
  t_efpvy  = MEDIAN(ind_vec[*,1],smpts[0],/EVEN)                                     & $
  t_efpvz  = MEDIAN(ind_vec[*,2],smpts[0],/EVEN)                                     & $
  t_efpv   = [[t_efpvx],[t_efpvy],[t_efpvz]]                                         & $
  efp_v_medfilt[inds,*] = t_efpv                                                     & $
  avgs     = [MEAN(t_efpv[*,0],/NAN),MEAN(t_efpv[*,1],/NAN),MEAN(t_efpv[*,2],/NAN)]  & $
  FOR k=0L, 2L DO efp_v_nodc[inds,k] = ind_vec[*,k] - avgs[k]


;;  Clean up
DELVAR,t_efpvx,t_efpvy,t_efpvz,t_efpv,ind_vec,avgs

;;  Check result
wi,1

se             = [20d1,60d1]
tt             = vec_t[gind] MOD 864d2
tt            -= MIN(tt,/NAN)
xyz            = vec_v[gind,*]
filt           = efp_v_medfilt[gind,*]
WSET,1
!P.MULTI       = [0,1,3]
;;  X-filtered
PLOT,tt,xyz[*,0],/NODATA,/XSTYLE,/YSTYLE,XRANGE=se
  OPLOT,tt, xyz[*,0],COLOR= 50
  OPLOT,tt,filt[*,0],COLOR=150,PSYM=3
;;  Y-filtered
PLOT,tt,xyz[*,1],/NODATA,/XSTYLE,/YSTYLE,XRANGE=se
  OPLOT,tt, xyz[*,1],COLOR= 50
  OPLOT,tt,filt[*,1],COLOR=150,PSYM=3
;;  Z-filtered
PLOT,tt,xyz[*,2],/NODATA,/XSTYLE,/YSTYLE,XRANGE=se
  OPLOT,tt, xyz[*,2],COLOR= 50
  OPLOT,tt,filt[*,2],COLOR=150,PSYM=3
!P.MULTI       = 0

;;  Clean up
WDELETE,1
DELVAR,tt,xyz,filt,se

;;  Send Eo without DC-offsets to TPLOT
temp_dc        = efp_v_nodc
temp_mid_nm    = efi_nodcnm[0]
efp_rmDCoffset = pref[0]+modes_efi[0]+temp_mid_nm[0]+coord_dsl[0]
rmDC_nm        = 'Rm: DC-offsets'
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E [efp, '+coord_up[0]+', mV/m]'+'!C'+'['+rmDC_nm[0]+']'
struct         = {X:vec_t,Y:temp_dc}
store_data,efp_rmDCoffset[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp
options,efp_rmDCoffset[0],'YTITLE',yttl[0],/DEF

;;  Send filtered Eo to TPLOT
smw_str        = STRTRIM(STRING(smpts,FORMAT='(I)'),2L)
temp_mid_nm    = '_cal_MedFilt-'+smw_str[0]+'pts_'
efp_mdfilt_dsl = pref[0]+modes_efi[0]+temp_mid_nm[0]+coord_dsl[0]
mdfilt_nm      = 'Filt: Median '+smw_str[0]+'pts'
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E [efp, '+coord_up[0]+', mV/m]'+'!C'+'['+mdfilt_nm[0]+']'
struct         = {X:vec_t,Y:efp_v_medfilt}
store_data,efp_mdfilt_dsl[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp
options,efp_mdfilt_dsl[0],'YTITLE',yttl[0],/DEF

;;  Send difference to TPLOT
efi_dtrnd_nm   = '_cal_detrended_'
efp_dtrnd_tpn  = pref[0]+modes_efi[0]+efi_dtrnd_nm[0]+coord_dsl[0]
rm_mdfilt_nm   = 'Rm: Median Filt. '+smw_str[0]+'pts'
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E [efp, '+coord_up[0]+', mV/m]'+'!C'+'['+rm_mdfilt_nm[0]+']'
detrended_Eo   = vec_v - efp_v_medfilt
struct         = {X:vec_t,Y:detrended_Eo}
store_data,efp_dtrnd_tpn[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp
options,efp_dtrnd_tpn[0],'YTITLE',yttl[0],/DEF























