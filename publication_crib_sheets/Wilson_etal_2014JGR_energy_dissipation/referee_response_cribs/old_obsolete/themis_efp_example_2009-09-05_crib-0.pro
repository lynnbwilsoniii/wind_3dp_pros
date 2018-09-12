;;----------------------------------------------------------------------------------------
;; => Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;; => Correct initial Rankine-Hugoniot results
;;----------------------------------------------------------------------------------------

;;  NEW Average Shock Terms [2nd Crossing]
vshn_up        =   -120.42239904d0
dvshnup        =     17.10918890d0
ushn_up        =   -219.90948937d0
dushnup        =      0.55434394d0
ushn_dn        =    -42.80976250d0
dushndn        =     14.02234390d0
gnorm          = -1d0*[     0.92968239d0,     0.30098043d0,    -0.21237099d0]
magf_up        =      [    -1.07332678d0,    -1.06251983d0,    -0.23281553d0]
magf_dn        =      [    -2.95333773d0,    -5.69773245d0,    -6.91488147d0]
theta_Bn       =     33.91071437d0
;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_c_data_2009-09-05_batch.pro

t_foot_ra1     = time_double(tdate[0]+'/'+['16:37:59.000','16:38:11.680'])
t_ramp_ra1     = time_double(tdate[0]+'/'+['16:37:58.272','16:37:59.000'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = MEAN(t_ramp_ra1,/NAN)
t_ramp2        = MEAN(t_ramp_ra2,/NAN)
traz           = t_ramp1[0] + [-1d0,1d0]*30   ;;  60 s window around ramp

nif_suffx_1    = '-RHS01'
nif_suffx_2    = '-RHS02'
nif_suffx_3    = '-RHS03'
scpref         = 'th'+sc[0]+'_'
thprobe        = STRMID(scpref[0],0,3)

;;  Only need data near 2nd shock, so remove extra TPLOT handles
del_data,'*'+nif_suffx_1[0]+'*'
del_data,'*'+nif_suffx_3[0]+'*'

del_data,scpref[0]+'*efp_*_INT000'
del_data,scpref[0]+'*efp_*_INT002'
del_data,scpref[0]+'efw_*_INT000'
del_data,scpref[0]+'efw_*_INT001'
del_data,scpref[0]+'efw_*_INT005'
del_data,scpref[0]+'*scp_*_INT000'
del_data,scpref[0]+'*scp_*_INT002'
del_data,scpref[0]+'scw_*_INT000'
del_data,scpref[0]+'scw_*_INT001'
del_data,scpref[0]+'scw_*_INT005'

;;  Good intervals
;;  Particle Burst  :  Interval 1
;;  Wave Burst      :  Interval 3


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
gind           = LONG(a_ind[se_pels[1,0]:se_pels[1,1]])
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

;;  Remove Eo spikes manually
nna            = [efp_dsl_orig[0]]
kill_data_tr,NAMES=nna
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

se             = [38d1,44d1]
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


;;  Now use linear interpolation for NaNs
temp_dc        = efp_v_medfilt
t_efpvx        = remove_nans(vec_t,temp_dc[*,0],/NO_EXTRAPOLATE);,/SPLINE)
t_efpvy        = remove_nans(vec_t,temp_dc[*,1],/NO_EXTRAPOLATE);,/SPLINE)
t_efpvz        = remove_nans(vec_t,temp_dc[*,2],/NO_EXTRAPOLATE);,/SPLINE)
t_efpv         = [[t_efpvx],[t_efpvy],[t_efpvz]]
;;  Remove "bad" values
;;    --> First set NaNs outside of region of interest
test           = (a_ind LT MIN(gind,/NAN)) OR (a_ind GT MAX(gind,/NAN))
bind           = WHERE(test,bnd,COMPLEMENT=comp1,NCOMPLEMENT=nc1)
PRINT,';;',bnd,nc1
;;      545280       76800

IF (bnd GT 0) THEN t_efpv[bind,*] = d
IF (bnd GT 0) THEN temp_dc[bind,*] = d
;;  Check to make sure extrapolation has not modified amplitudes
test_x         = (t_efpv[*,0] GT MAX(temp_dc[*,0],/NAN)) OR (t_efpv[*,0] LT MIN(temp_dc[*,0],/NAN))
test_y         = (t_efpv[*,1] GT MAX(temp_dc[*,1],/NAN)) OR (t_efpv[*,1] LT MIN(temp_dc[*,1],/NAN))
test_z         = (t_efpv[*,2] GT MAX(temp_dc[*,2],/NAN)) OR (t_efpv[*,2] LT MIN(temp_dc[*,2],/NAN))
bad_x          = WHERE(test_x,bdx)
bad_y          = WHERE(test_y,bdy)
bad_z          = WHERE(test_z,bdz)
PRINT,';;',bdx,bdy,bdz
;;           0           0           0

IF (bdx GT 0) THEN t_efpv[bad_x,*] = d
IF (bdy GT 0) THEN t_efpv[bad_y,*] = d
IF (bdz GT 0) THEN t_efpv[bad_z,*] = d
;;  Now redefine variable
vec_vn         = t_efpv

;;--------------------------------
;;  Find X-Axis fit
;;--------------------------------
plane_dim      = 0
axis_dim       = 0
sun2sensor     = 0d0
spinfit,$
          vec_t[gind],vec_vn[gind,*],sunp_t,sunp_v,    $         ;;  Input
          a,b,c,spin_axis,med_axis,sig,npts,sun_data,  $         ;;  Output
          MIN_POINTS=min_points,ALPHA=alpha,BETA=beta, $
          PLANE_DIM=plane_dim,AXIS_DIM=axis_dim,PHASE_MASK_STARTS=phase_mask_starts,$
          PHASE_MASK_ENDS=phase_mask_ends,SUN2SENSOR=sun2sensor
;;  Redefine parameters
a_x            = a
b_x            = b
c_x            = c
sig_x          = sig
npt_x          = npts*1.
t_x_fit        = sun_data
;;  Clean up
DELVAR,a,b,c,spin_axis,med_axis,sig,npts,sun_data

;;--------------------------------
;;  Find Y-Axis fit
;;--------------------------------
plane_dim      = 1
axis_dim       = 1
sun2sensor     = 0d0
spinfit,$
          vec_t[gind],vec_vn[gind,*],sunp_t,sunp_v,    $         ;;  Input
          a,b,c,spin_axis,med_axis,sig,npts,sun_data,  $         ;;  Output
          MIN_POINTS=min_points,ALPHA=alpha,BETA=beta, $
          PLANE_DIM=plane_dim,AXIS_DIM=axis_dim,PHASE_MASK_STARTS=phase_mask_starts,$
          PHASE_MASK_ENDS=phase_mask_ends,SUN2SENSOR=sun2sensor
;;  Redefine parameters
a_y            = a
b_y            = b
c_y            = c
sig_y          = sig
npt_y          = npts*1.
t_y_fit        = sun_data
;;  Clean up
DELVAR,a,b,c,spin_axis,med_axis,sig,npts,sun_data

;;--------------------------------
;;  Find Z-Axis fit
;;--------------------------------
plane_dim      = 2
axis_dim       = 2
sun2sensor     = 0d0
spinfit,$
          vec_t[gind],vec_vn[gind,*],sunp_t,sunp_v,    $         ;;  Input
          a,b,c,spin_axis,med_axis,sig,npts,sun_data,  $         ;;  Output
          MIN_POINTS=min_points,ALPHA=alpha,BETA=beta, $
          PLANE_DIM=plane_dim,AXIS_DIM=axis_dim,PHASE_MASK_STARTS=phase_mask_starts,$
          PHASE_MASK_ENDS=phase_mask_ends,SUN2SENSOR=sun2sensor
;;  Redefine parameters
a_z            = a
b_z            = b
c_z            = c
sig_z          = sig
npt_z          = npts*1.
t_z_fit        = sun_data
;;  Clean up
DELVAR,a,b,c,spin_axis,med_axis,sig,npts,sun_data

;;--------------------------------
;;  Send to TPLOT
;;--------------------------------
fit_tpns       = ['a','b','c','sig','npts']
boomfit        = ['x','y','z']
temp_tpn       = 'test_spinfit_efp_'+boomfit+'_'
ysubt          = '[Spinfit to efp, E'+boomfit+']'

lim__fits      = lim_efp
dlim_fits      = dlim_efp
str_element,lim__fits,'LABELS',/DELETE
str_element,dlim_fits,'LABELS',/DELETE
str_element,dlim_fits,'COLORS',50,/ADD_REPLACE
;;  X-Fits
store_data,temp_tpn[0]+fit_tpns[0],   DATA={X:t_x_fit,  Y:a_x},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[0]+fit_tpns[1],   DATA={X:t_x_fit,  Y:b_x},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[0]+fit_tpns[2],   DATA={X:t_x_fit,  Y:c_x},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[0]+fit_tpns[3],   DATA={X:t_x_fit,Y:sig_x},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[0]+fit_tpns[4],   DATA={X:t_x_fit,Y:npt_x},DLIM=dlim_fits,LIM=lim__fits
options,   temp_tpn[0]+fit_tpns[0],'YSUBTITLE',ysubt[0]
options,   temp_tpn[0]+fit_tpns[1],'YSUBTITLE',ysubt[0]
options,   temp_tpn[0]+fit_tpns[2],'YSUBTITLE',ysubt[0]
options,   temp_tpn[0]+fit_tpns[3],'YSUBTITLE',ysubt[0]
options,   temp_tpn[0]+fit_tpns[4],'YSUBTITLE',ysubt[0]
;;  Y-Fits
store_data,temp_tpn[1]+fit_tpns[0],   DATA={X:t_y_fit,  Y:a_y},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[1]+fit_tpns[1],   DATA={X:t_y_fit,  Y:b_y},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[1]+fit_tpns[2],   DATA={X:t_y_fit,  Y:c_y},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[1]+fit_tpns[3],   DATA={X:t_y_fit,Y:sig_y},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[1]+fit_tpns[4],   DATA={X:t_y_fit,Y:npt_y},DLIM=dlim_fits,LIM=lim__fits
options,   temp_tpn[1]+fit_tpns[0],'YSUBTITLE',ysubt[1]
options,   temp_tpn[1]+fit_tpns[1],'YSUBTITLE',ysubt[1]
options,   temp_tpn[1]+fit_tpns[2],'YSUBTITLE',ysubt[1]
options,   temp_tpn[1]+fit_tpns[3],'YSUBTITLE',ysubt[1]
options,   temp_tpn[1]+fit_tpns[4],'YSUBTITLE',ysubt[1]
;;  Z-Fits
store_data,temp_tpn[2]+fit_tpns[0],   DATA={X:t_z_fit,  Y:a_z},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[2]+fit_tpns[1],   DATA={X:t_z_fit,  Y:b_z},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[2]+fit_tpns[2],   DATA={X:t_z_fit,  Y:c_z},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[2]+fit_tpns[3],   DATA={X:t_z_fit,Y:sig_z},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[2]+fit_tpns[4],   DATA={X:t_z_fit,Y:npt_z},DLIM=dlim_fits,LIM=lim__fits
options,   temp_tpn[2]+fit_tpns[0],'YSUBTITLE',ysubt[2]
options,   temp_tpn[2]+fit_tpns[1],'YSUBTITLE',ysubt[2]
options,   temp_tpn[2]+fit_tpns[2],'YSUBTITLE',ysubt[2]
options,   temp_tpn[2]+fit_tpns[3],'YSUBTITLE',ysubt[2]
options,   temp_tpn[2]+fit_tpns[4],'YSUBTITLE',ysubt[2]
;;  Fix Y-Axis title for both
options,tnames(temp_tpn[*]+fit_tpns[0]),'YTITLE','Spinfit Param. '+fit_tpns[0]
options,tnames(temp_tpn[*]+fit_tpns[1]),'YTITLE','Spinfit Param. '+fit_tpns[1]
options,tnames(temp_tpn[*]+fit_tpns[2]),'YTITLE','Spinfit Param. '+fit_tpns[2]
options,tnames(temp_tpn[*]+fit_tpns[3]),'YTITLE','Spinfit Param. '+fit_tpns[3]
options,tnames(temp_tpn[*]+fit_tpns[4]),'YTITLE','Spinfit Param. '+fit_tpns[4]

nnw            = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01


;;  Plot X-Fits
nna            = [fgh_mag_dsl,efp_dsl_orig[0],temp_tpn[0]+'*']
  tplot,nna,TRANGE=traz
;;  Plot Y-Fits
nna            = [fgh_mag_dsl,efp_dsl_orig[0],temp_tpn[1]+'*']
  tplot,nna,TRANGE=traz
;;  Plot Z-Fits
nna            = [fgh_mag_dsl,efp_dsl_orig[0],temp_tpn[2]+'*']
  tplot,nna,TRANGE=traz

;;  Remove finite fit values where data = NaN
nna            = tnames([temp_tpn[0]+'*',temp_tpn[1]+'*',temp_tpn[2]+'*'])
kill_data_tr,NAMES=nna

;;----------------------------------------------------------------------------------------
;;  Reconstruct E-field components
;;----------------------------------------------------------------------------------------
wi,1

;;  Get Eo data [DSL]
;get_data,efp_rmDCoffset[0],DATA=temp_efp_nodc,DLIM=dlim_efp_nodc,LIM=lim_efp_nodc
get_data,efp_mdfilt_dsl[0],DATA=temp_efp_nodc,DLIM=dlim_efp_nodc,LIM=lim_efp_nodc
;;  Get values from TPLOT, since I removed them by hand
get_data,temp_tpn[0]+fit_tpns[0],   DATA=temp_fit_a_x,DLIM=dlim_fit_a_x,LIM=lim__fit_a_x
get_data,temp_tpn[0]+fit_tpns[1],   DATA=temp_fit_b_x,DLIM=dlim_fit_b_x,LIM=lim__fit_b_x
get_data,temp_tpn[0]+fit_tpns[2],   DATA=temp_fit_c_x,DLIM=dlim_fit_c_x,LIM=lim__fit_c_x
get_data,temp_tpn[1]+fit_tpns[0],   DATA=temp_fit_a_y,DLIM=dlim_fit_a_y,LIM=lim__fit_a_y
get_data,temp_tpn[1]+fit_tpns[1],   DATA=temp_fit_b_y,DLIM=dlim_fit_b_y,LIM=lim__fit_b_y
get_data,temp_tpn[1]+fit_tpns[2],   DATA=temp_fit_c_y,DLIM=dlim_fit_c_y,LIM=lim__fit_c_y
get_data,temp_tpn[2]+fit_tpns[0],   DATA=temp_fit_a_z,DLIM=dlim_fit_a_z,LIM=lim__fit_a_z
get_data,temp_tpn[2]+fit_tpns[1],   DATA=temp_fit_b_z,DLIM=dlim_fit_b_z,LIM=lim__fit_b_z
get_data,temp_tpn[2]+fit_tpns[2],   DATA=temp_fit_c_z,DLIM=dlim_fit_c_z,LIM=lim__fit_c_z

;;  I am not sure why, but the spin phase (from model) needs to be shifted by -200 degrees...?
;phase_off_x    = 36d1 - (135d0 + 25d0)
phase_off_x    = 0d0
smpts          = 10L      ;;  # of points to smooth
;;  Define parameters
vec_t          = temp_efp_nodc.X
vec_v          = temp_efp_nodc.Y
sphase_t       = spphs_int.X
sphase_v       = spphs_int.Y
sphase_vr      = (sphase_v - phase_off_x[0])*!DPI/18d1
;;  Define fit parameters
a_x_t          = temp_fit_a_x.X
a_x_n          = temp_fit_a_x.Y
a_y_t          = temp_fit_a_y.X
a_y_n          = temp_fit_a_y.Y
a_z_t          = temp_fit_a_z.X
a_z_n          = temp_fit_a_z.Y

b_x_t          = temp_fit_b_x.X
b_x_n          = temp_fit_b_x.Y
b_y_t          = temp_fit_b_y.X
b_y_n          = temp_fit_b_y.Y
b_z_t          = temp_fit_b_z.X
b_z_n          = temp_fit_b_z.Y

c_x_t          = temp_fit_c_x.X
c_x_n          = temp_fit_c_x.Y
c_y_t          = temp_fit_c_y.X
c_y_n          = temp_fit_c_y.Y
c_z_t          = temp_fit_c_z.X
c_z_n          = temp_fit_c_z.Y
;;  Extend finite region one point on either side
test_a         = FINITE(a_x_n) AND FINITE(a_y_n) AND FINITE(a_z_n)
test_b         = FINITE(b_x_n) AND FINITE(b_y_n) AND FINITE(b_z_n)
test_c         = FINITE(c_x_n) AND FINITE(c_y_n) AND FINITE(c_z_n)
good_a         = WHERE(test_a,gda)
good_b         = WHERE(test_b,gdb)
good_c         = WHERE(test_c,gdc)
PRINT,';;',gda,gdb,gdc
;;          12          12          12

PRINT,';;', MIN(good_a), MAX(good_a) & $
PRINT,';;', MIN(good_b), MAX(good_b) & $
PRINT,';;', MIN(good_c), MAX(good_c)
;;         127         138
;;         127         138
;;         127         138

se_g           = [MIN(good_a), MAX(good_a)]
se_b           = se_g + [-1L,1L]
a_x_n[se_b]    = a_x_n[se_g]
b_x_n[se_b]    = b_x_n[se_g]
c_x_n[se_b]    = c_x_n[se_g]
a_y_n[se_b]    = a_y_n[se_g]
b_y_n[se_b]    = b_y_n[se_g]
c_y_n[se_b]    = c_y_n[se_g]
a_z_n[se_b]    = a_z_n[se_g]
b_z_n[se_b]    = b_z_n[se_g]
c_z_n[se_b]    = c_z_n[se_g]


;;  Use only time stamps near 2nd shock
up_t           = vec_t[gind]
;;  Reconstruct Eo_x
a_x_up         = interp(SMOOTH(a_x_n,smpts[0],/NAN,/EDGE_TRUNCATE),a_x_t,up_t,/NO_EXTRAPOLATE)
b_x_up         = interp(SMOOTH(b_x_n,smpts[0],/NAN,/EDGE_TRUNCATE),b_x_t,up_t,/NO_EXTRAPOLATE)
c_x_up         = interp(SMOOTH(c_x_n,smpts[0],/NAN,/EDGE_TRUNCATE),c_x_t,up_t,/NO_EXTRAPOLATE)
Eo_x_fit       = a_x_up + b_x_up*COS(sphase_vr) + c_x_up*SIN(sphase_vr)
;;  Reconstruct Eo_y
a_y_up         = interp(SMOOTH(a_y_n,smpts[0],/NAN,/EDGE_TRUNCATE),a_y_t,up_t,/NO_EXTRAPOLATE)
b_y_up         = interp(SMOOTH(b_y_n,smpts[0],/NAN,/EDGE_TRUNCATE),b_y_t,up_t,/NO_EXTRAPOLATE)
c_y_up         = interp(SMOOTH(c_y_n,smpts[0],/NAN,/EDGE_TRUNCATE),c_y_t,up_t,/NO_EXTRAPOLATE)
Eo_y_fit       = a_y_up + b_y_up*COS(sphase_vr) + c_y_up*SIN(sphase_vr)
;;  Reconstruct Eo_z
a_z_up         = interp(SMOOTH(a_z_n,smpts[0],/NAN,/EDGE_TRUNCATE),a_z_t,up_t,/NO_EXTRAPOLATE)
b_z_up         = interp(SMOOTH(b_z_n,smpts[0],/NAN,/EDGE_TRUNCATE),b_z_t,up_t,/NO_EXTRAPOLATE)
c_z_up         = interp(SMOOTH(c_z_n,smpts[0],/NAN,/EDGE_TRUNCATE),c_z_t,up_t,/NO_EXTRAPOLATE)
Eo_z_fit       = a_z_up + b_z_up*COS(sphase_vr) + c_z_up*SIN(sphase_vr)
;;  Define Eo Spinfit Model data [DSL]
Eo_fit_v       = [[Eo_x_fit],[Eo_y_fit],[Eo_z_fit]]


se             = [37d1,45d1]
up_t_sod       = (up_t MOD 864d2)    ;;  convert to seconds of day (SOD)
up_t_sod      -= MIN(up_t_sod,/NAN)  ;;  remove offset from 0
dat_xyz        = vec_v[gind,*]
mod_xyz        = Eo_fit_v
WSET,1
!P.MULTI       = [0,1,3]
;;  X-fits
PLOT,up_t_sod,dat_xyz[*,0],/NODATA,/XSTYLE,/YSTYLE,XRANGE=se
  OPLOT,up_t_sod,dat_xyz[*,0],COLOR=250
  OPLOT,up_t_sod,mod_xyz[*,0],COLOR= 50,PSYM=3
;;  Y-fits
PLOT,up_t_sod,dat_xyz[*,1],/NODATA,/XSTYLE,/YSTYLE,XRANGE=se
  OPLOT,up_t_sod,dat_xyz[*,1],COLOR=250
  OPLOT,up_t_sod,mod_xyz[*,1],COLOR= 50,PSYM=3
;;  Z-fits
PLOT,up_t_sod,dat_xyz[*,2],/NODATA,/XSTYLE,/YSTYLE,XRANGE=se
  OPLOT,up_t_sod,dat_xyz[*,2],COLOR=250
  OPLOT,up_t_sod,mod_xyz[*,2],COLOR= 50,PSYM=3
!P.MULTI       = 0


;;----------------------------------------------------------------------------------------
;;  Send reconstruct E-field to TPLOT
;;----------------------------------------------------------------------------------------
;;;  Get Eo data [DSL]
;get_data,efp_rmDCoffset[0],DATA=temp_efp_nodc,DLIM=dlim_efp_nodc,LIM=lim_efp_nodc
;;;  Define parameters
;vec_t          = temp_efp_nodc.X
;vec_v          = temp_efp_nodc.Y
;;  Get Eo data [DSL]
get_data,efp_dsl_orig[0],DATA=temp_efp_nodc,DLIM=dlim_efp_nodc,LIM=lim_efp_nodc
;;  Define parameters
vec_t          = temp_efp_nodc.X
vec_v          = temp_efp_nodc.Y
gd_tp_t        = vec_t[gind]
gd_tp_v        = vec_v[gind,*]

;;  Define TPLOT parameters
;temp_mid_nm    = '_cal_despiked_spinfit-model_'
temp_mid_nm    = efp_spinfit_nm[0]
efp_spinfitmod = pref[0]+modes_efi[0]+temp_mid_nm[0]+coord_dsl[0]
spinfit_mod_nm = 'Spinfit Model'
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E [efp, '+coord_up[0]+', mV/m]'+'!C'+'['+spinfit_mod_nm[0]+']'
str_element,dlim_efp_nodc,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:gd_tp_t,Y:Eo_fit_v}
store_data,efp_spinfitmod[0],DATA=struct,DLIM=dlim_efp_nodc,LIM=lim_efp_nodc
;;----------------------------------------------------------------------------------------
;;  Send difference to TPLOT
;;----------------------------------------------------------------------------------------
;;  Use median filtered data to remove artificial DC-offset in Z-component
;;  Get Eo data [DSL]
get_data,efp_mdfilt_dsl[0],DATA=temp_efp_mdfilt,DLIM=dlim_efp_mdfilt,LIM=lim_efp_mdfilt
;;  Define params
efp_mdfilt_t   = temp_efp_mdfilt.X[gind]
efp_mdfilt_v   = temp_efp_mdfilt.Y[gind,*]
avg_z0         = MEAN(Eo_fit_v[*,2],/NAN)
;;  Remove DC-offset from model results
temp_z         = efp_mdfilt_v[*,2]
model_z        = Eo_fit_v[*,2] - avg_z0[0]
;;  Remove spin fit results
diff_Eo        = gd_tp_v - Eo_fit_v
;;  Now use linear interpolation for NaNs
t_efpvx        = remove_nans(gd_tp_t,diff_Eo[*,0],/NO_EXTRAPOLATE);,/SPLINE)
t_efpvy        = remove_nans(gd_tp_t,diff_Eo[*,1],/NO_EXTRAPOLATE);,/SPLINE)
t_efpvz        = remove_nans(gd_tp_t,diff_Eo[*,2],/NO_EXTRAPOLATE);,/SPLINE)
t_efpv         = [[t_efpvx],[t_efpvy],[t_efpvz]]

temp_mid_nm    = efp_rmspftmod[0]
;temp_mid_nm    = '_cal_despiked_rm-spinfit-model_'
rmspfit_mod_nm = 'Rm: Spinfit Model'
efp_rmspft_dsl = pref[0]+modes_efi[0]+temp_mid_nm[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E [efp, '+coord_up[0]+', mV/m]'+'!C'+'['+rmspfit_mod_nm[0]+']'
str_element,dlim_efp_nodc,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:gd_tp_t,Y:t_efpv}
store_data,efp_rmspft_dsl[0],DATA=struct,DLIM=dlim_efp_nodc,LIM=lim_efp_nodc

;;  Plot Spinfit Model with actual data
nna            = [fgh_mag_dsl,efp_dsl_orig[0],efp_spinfitmod[0],efp_rmspft_dsl[0],efp_mdfilt_dsl[0],efp_dtrnd_tpn[0]]
WSET,0
  tplot,nna,TRANGE=traz


;;----------------------------------------------------------------------------------------
;;  Rotate result into GSE coordinates
;;----------------------------------------------------------------------------------------
tpnm__in       = tnames(efp_rmspft_dsl[0])
tpnm_out       = STRMID(tpnm__in[0],0L,STRLEN(tpnm__in[0]) - 3L)+coord_gse[0]
thm_cotrans,tpnm__in[0],tpnm_out[0],IN_COORD=coord_dsl[0],OUT_COORD=coord_gse[0],VERBOSE=0
efp_rmspft_gse = tpnm_out[0]
;;----------------------------------------------------------------------------------------
;;  Transform into NIF and rotate result into NCB
;;----------------------------------------------------------------------------------------
;;  Get EFI data [GSE basis]
get_data,efp_rmspft_gse[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
vec_t          = temp_efp.X
vec_v          = temp_efp.Y

trange         = time_double(['2009-09-05/16:37:46.4100','2009-09-05/16:38:25.2000'])
tran_j         = trange + [-1d0,1d0]*6d2      ;;  Need to expand time range
;; => Avg. terms [2nd Shock]
t_ramp         = MEAN(time_double(tdate[0]+'/'+['16:37:58.272','16:37:59.000']),/NAN)
;;  NEW Average Shock Terms [2nd Crossing]
vshn_up        =   -120.42239904d0
dvshnup        =     17.10918890d0
ushn_up        =   -219.90948937d0
dushnup        =      0.55434394d0
ushn_dn        =    -42.80976250d0
dushndn        =     14.02234390d0
gnorm          = -1d0*[ 0.92968239d0, 0.30098043d0,-0.21237099d0]
theta_Bn       =     33.91071437d0
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-356.562d0, -31.5722d0, -3.10936d0]
vswi_dn        = [-198.972d0,  29.2785d0, -60.9125d0]
magf_up        = [-1.07332678d0,-1.06251983d0,-0.23281553d0]
magf_dn        = [-2.95333773d0,-5.69773245d0,-6.91488147d0]
;;  Avg. upstream/downstream density and temperatures
dens_up        = 2.65507d0
dens_dn        = 14.1623d0
Ti___up        = 7.46431d0
Ti___dn        = 148.327d0
Te___up        = 11.8844d0
Te___dn        = 30.8271d0

;;  Define RH Parameter Structure
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)
tramp          = t_ramp[0]
nsm            = 10L
nif_suffx      = '-RHS02'
;;  Define TPLOT handles
fgh_gse        = fgm_gse[2]
vsw_gse        = tnames(pref[0]+'Velocity_'+coord_gse[0]+'_peib_no_GIs_UV')
pos_gse        = tnames(scpref[0]+'state_pos_'+coord_gse[0])

;;  Calculate ∆x, E_conv, j, etc.
struct         = t_nif_s1986a_scale_norm(nif_str,VSW_TPNM=vsw_gse[0],MAGF_TPNM=fgh_gse[0], $
                                         SCPOS_TPNM=pos_gse[0],NSM=nsm[0],TRANGE=tran_j,   $
                                         TRAMP=tramp[0])
;; => Define rotation from GSE to NIF
rotnif         = struct.DELTA_XSTR.ROT_ICB_NCB
;;  Get NIF E_conv [GSE basis]
e_conv_t       = struct.E_CONV_STR.TIME
E_conv         = struct.E_CONV_STR.E_CONV_NIF_ICB     ;;  mV/m
;;  Upsample E_conv
t_econv_x      = interp(E_conv[*,0],e_conv_t,vec_t,/NO_EXTRAPOLATE)
t_econv_y      = interp(E_conv[*,1],e_conv_t,vec_t,/NO_EXTRAPOLATE)
t_econv_z      = interp(E_conv[*,2],e_conv_t,vec_t,/NO_EXTRAPOLATE)
t_econv_v      = [[t_econv_x],[t_econv_y],[t_econv_z]]
;;  Transform efp to NIF
vec_v_nif_gse  = vec_v - t_econv_v
;;  Send result to TPLOT
efp_rmspft_nif = pref[0]+modes_efi[0]+temp_mid_nm[0]+coord_nif[0]
store_data,efp_rmspft_nif[0],DATA={X:vec_t,Y:vec_v_nif_gse},DLIM=dlim_efp,LIM=lim_efp
options,efp_rmspft_nif[0],'YTITLE',yttl_nif_efi[0],/DEF
options,efp_rmspft_nif[0],'LABELS',vec_str,/DEF
options,efp_rmspft_nif[0],'DATA_ATT.NOTE',note_nif_gse[0],/DEF
;;----------------------------------------------------------------------------------------
;;  Rotate result into NCB
;;----------------------------------------------------------------------------------------
vec_v_nif_ncb  = REFORM(rotnif ## vec_v_nif_gse)
efp_rmspft_ncb = pref[0]+modes_efi[0]+temp_mid_nm[0]+coord_ncb[0]
store_data,efp_rmspft_ncb[0],DATA={X:vec_t,Y:vec_v_nif_ncb},DLIM=dlim_efp,LIM=lim_efp
options,efp_rmspft_ncb[0],'YTITLE',yttl_ncb_efi[0],/DEF
options,efp_rmspft_ncb[0],'LABELS',ncb_labs,/DEF
options,efp_rmspft_ncb[0],'DATA_ATT.NOTE',note_nif_ncb[0],/DEF
options,efp_rmspft_ncb[0],'COLORS',vec_cols,/DEF
options,efp_rmspft_ncb[0],'LABELS'
options,efp_rmspft_ncb[0],'COLORS'

;;----------------------------------------------------------------------------------------
;;  Calculate (-Jo . ∂E)
;;----------------------------------------------------------------------------------------
jdE_fac        = -1d0*1d-6*1d-3*1d6                            ;;  µA -> A, mV -> V, W -> µW
low_sps        = 128d0
jvec_midnm     = 'jvec_'+mode_fgm[2]+'_'+coord_nif[0]
jvec_names     = tnames(scpref[0]+jvec_midnm[0])               ;;  j-vector
;;  Get (-Jo . ∂E) [NIF (NCB basis), µA m^(-2)]
Edotj_midnm    = 'neg-E-dot-j_'+modes_efi[1]+'_cal_'+coord_nif[0]
Edotj_names    = tnames(scpref[0]+Edotj_midnm[0]+'_sm*')       ;;  (-Jo.∂E)  [∂E downsampled to Jo]
get_data,Edotj_names[0],DATA=j_dot_dE_0,DLIM=dlim_jdE_0,LIM=lim_jdE_0
;;  Get Jo [NIF (NCB basis), µA m^(-2)]
get_data,jvec_names[0],DATA=jvec_str_sm,DLIM=dlim_jsm,LIM=lim_jsm
;jvec_t         = jvec_str_sm.X
;jvec_v         = jvec_str_sm.Y
jvec_t         = struct.DELTA_JSTR.DELTA_J_NIF_STR.TIME
jvec_v         = struct.DELTA_JSTR.DELTA_J_NIF_STR.JVEC_NIF
;;  Get Eo [NIF (NCB basis), mV/m]
efw_ncb_mid    = modes_efi[1]+'_cal_corrected_DownSampled_'
efw_ncb_tpn    = tnames(pref[0]+efw_ncb_mid[0]+coord_ncb[0]+'*')
get_data,efw_ncb_tpn[0],DATA=temp_efw_ncb,DLIM=dlim_efw_ncb,LIM=lim_efw_ncb
dE__t          = temp_efw_ncb.X
dE__v          = temp_efw_ncb.Y
;;  Calc. sample rate
srate          = DOUBLE(sample_rate(dE__t,GAP_THRESH=1d0,/AVE))
sr_str         = STRTRIM(STRING(DOUBLE(ROUND(srate[0])),FORMAT='(f15.1)'),2L)
smwidth        = ROUND(srate[0]/low_sps[0])*2L
smw_str        = STRTRIM(STRING(smwidth,FORMAT='(I)'),2L)
;;  Upsample Jo to ∂E time-stamps
jvecx_up       = interp(jvec_v[*,0],jvec_t,dE__t,/NO_EXTRAP)
jvecy_up       = interp(jvec_v[*,1],jvec_t,dE__t,/NO_EXTRAP)
jvecz_up       = interp(jvec_v[*,2],jvec_t,dE__t,/NO_EXTRAP)
jvec__up       = [[jvecx_up],[jvecy_up],[jvecz_up]]
;;  Smoothed upsampled Jo
jvecx_up       = SMOOTH(jvec__up[*,0],smwidth[0],/EDGE_TRUNCATE,/NAN)
jvecy_up       = SMOOTH(jvec__up[*,1],smwidth[0],/EDGE_TRUNCATE,/NAN)
jvecz_up       = SMOOTH(jvec__up[*,2],smwidth[0],/EDGE_TRUNCATE,/NAN)
jvec__up_sm    = [[jvecx_up],[jvecy_up],[jvecz_up]]
;;  Send smoothed Jo to TPLOT
labs_jdE_upsam = 'Upsampled Jo: '+[sr_str[0]+'sps','Smoothed: '+smw_str[0]+'pts']
dlim_j_US      = dlim_jsm
ysubt_j_US     = '['+thprobe[0]+', '+labs_jdE_upsam[0]+']'
ysubt_j_US     = ysubt_j_US[0]+'!C'+'['+labs_jdE_upsam[1]+']'
str_element,dlim_j_US,'YSUBTITLE',ysubt_j_US[0],/ADD_REPLACE
jvec_prefx_US  = scpref[0]+'jvec_'+mode_fgm[2]+'_'+coord_ncb[0]+'_Upsampled_Smoothed'
jvec_name_US   = jvec_prefx_US[0]+smw_str[0]        ;;  new j-vector TPLOT handle
jvec_US_str    = {X:dE__t,Y:jvec__up_sm}
store_data,jvec_name_US[0],DATA=jvec_US_str,DLIM=dlim_j_US,LIM=lim_jsm

;;  Calculate (-Jo . ∂E) and send to TPLOT
Jo_dot_dE      = jdE_fac[0]*TOTAL(jvec__up_sm*dE__v,2,/NAN)
;;  Change DLIMITS structure
dlim_j_up_dE   = dlim_efw_ncb
yttl           = '(-Jo . ∂E) [efw, NIF (NCB basis), '+JodE_units[0]+']'
ysubt_j_up_dE  = '['+thprobe[0]+', '+sr_str[0]+' sps]'
str_element,dlim_j_up_dE,'YTITLE',yttl[0],/ADD_REPLACE
str_element,dlim_j_up_dE,'YSUBTITLE',ysubt_j_up_dE[0],/ADD_REPLACE
str_element,dlim_j_up_dE,'DATA_ATT.COORD_SYS','nif',/ADD_REPLACE
str_element,dlim_j_up_dE,'LABELS','(-Jo . ∂E)',/ADD_REPLACE
str_element,dlim_j_up_dE,'COLORS', 250,/ADD_REPLACE
JodotdE_prefx  = scpref[0]+'neg-Jo-dot-dE_'+modes_efi[0]+'_'
JodotdE_upsam  = JodotdE_prefx[0]+smw_str[0]+'pts_'+coord_ncb[0]
jdotdE_str     = {X:dE__t,Y:Jo_dot_dE}
store_data,JodotdE_upsam[0],DATA=jdotdE_str,DLIM=dlim_j_up_dE,LIM=lim_efw_ncb

;;  Calculate ∑ (-Jo . ∂E) and send to TPLOT
Jo_dot_dE_CS   = TOTAL(Jo_dot_dE,/NAN,/CUMULATIVE)
yttl           = '∑ (-Jo . ∂E) [efw, NIF (NCB basis), '+JodE_units[0]+']'
str_element,dlim_j_up_dE,'YTITLE',yttl[0],/ADD_REPLACE
str_element,dlim_j_up_dE,'LABELS','∑ (-Jo . ∂E)',/ADD_REPLACE
JoddECS_prefx  = scpref[0]+'neg-Jo-dot-dE_'+modes_efi[0]+'_CumSum_'
JoddECS_upsam  = JoddECS_prefx[0]+smw_str[0]+'pts_'+coord_ncb[0]
jddECS_str     = {X:dE__t,Y:Jo_dot_dE_CS}
store_data,JoddECS_upsam[0],DATA=jddECS_str,DLIM=dlim_j_up_dE,LIM=lim_efw_ncb
;;----------------------------------------------------------------------------------------
;;  Calculate (-Jo . Eo)
;;----------------------------------------------------------------------------------------
jdE_fac        = -1d0*1d-6*1d-3*1d6                            ;;  µA -> A, mV -> V, W -> µW
jvec_names     = tnames(jvec_name_US[0])                       ;;  j-vector
;;  Get Jo [NIF (NCB basis), µA m^(-2)]
get_data,jvec_names[0],DATA=jvec_str_sm,DLIM=dlim_jsm,LIM=lim_jsm
;jvec_t         = jvec_str_sm.X
;jvec_v         = jvec_str_sm.Y
jvec_t         = struct.DELTA_JSTR.DELTA_J_NIF_STR.TIME
jvec_v         = struct.DELTA_JSTR.DELTA_J_NIF_STR.JVEC_NIF
;;  Get Eo [NIF (NCB basis), mV/m]
get_data,efp_rmspft_ncb[0],DATA=temp_efp_ncb,DLIM=dlim_efp_ncb,LIM=lim_efp_ncb
Eo__t          = temp_efp_ncb.X
Eo__v          = temp_efp_ncb.Y
;;  Calc. sample rate
srate          = DOUBLE(sample_rate(Eo__t,GAP_THRESH=1d0,/AVE))
sr_str         = STRTRIM(STRING(DOUBLE(ROUND(srate[0])),FORMAT='(f15.1)'),2L)
;;  Force on same time steps
jvec_efp_x     = interp(jvec_v[*,0],jvec_t,Eo__t,/NO_EXTRAPOLATE)
jvec_efp_y     = interp(jvec_v[*,1],jvec_t,Eo__t,/NO_EXTRAPOLATE)
jvec_efp_z     = interp(jvec_v[*,2],jvec_t,Eo__t,/NO_EXTRAPOLATE)
jvec_efp_v     = [[jvec_efp_x],[jvec_efp_y],[jvec_efp_z]]

;;  Calculate (-Jo . Eo)
Jo_dot_Eo      = jdE_fac[0]*TOTAL(jvec_efp_v*Eo__v,2,/NAN)
;;  Send to TPLOT
JodotEo_prefx  = scpref[0]+'neg-Jo-dot-Eo_'+modes_efi[0]+'_'
JodEo_efp_jvsm = JodotEo_prefx[0]+coord_ncb[0]
ysubt_JodotEo  = '['+thprobe[0]+', '+sr_str[0]+' sps]'
yttl           = '(-Jo . Eo) [efp, NIF (NCB basis), '+JodE_units[0]+']'
dlim_JodotEo   = dlim_jdE_0
str_element,dlim_JodotEo,'YTITLE',yttl[0],/ADD_REPLACE
str_element,dlim_JodotEo,'YSUBTITLE',ysubt_JodotEo[0],/ADD_REPLACE
str_element,dlim_JodotEo,'LABELS','(-Jo . Eo)',/ADD_REPLACE
str_element,dlim_JodotEo,'COLORS', 250,/ADD_REPLACE
store_data,JodEo_efp_jvsm[0],DATA={X:Eo__t,Y:Jo_dot_Eo},DLIM=dlim_JodotEo,LIM=lim_efp
options,JodEo_efp_jvsm[0],'LABELS'
options,JodEo_efp_jvsm[0],'COLORS'
options,JodEo_efp_jvsm[0],'YTITLE'
options,JodEo_efp_jvsm[0],'YSUBTITLE'

;;  Calculate cumulative sum of (-Jo . Eo) to TPLOT
Jo_dot_Eo_cs   = TOTAL(Jo_dot_Eo,/NAN,/CUMULATIVE)
;;  Send to TPLOT
JodEoCS_prefx  = scpref[0]+'neg-Jo-dot-Eo_'+modes_efi[0]+'_CumSum_'
JodEoCS_efpjsm = JodEoCS_prefx[0]+coord_ncb[0]
ysubt_JodotEo  = '['+thprobe[0]+', '+sr_str[0]+' sps]'
yttl           = '∑ (-Jo . Eo) [efp, NIF (NCB basis), '+JodE_units[0]+']'
yttl           = yttl[0]+'!C'+'[Cumulative Sum]'
str_element,dlim_JodotEo,'YTITLE',yttl[0],/ADD_REPLACE
str_element,dlim_JodotEo,'YSUBTITLE',ysubt_JodotEo[0],/ADD_REPLACE
str_element,dlim_JodotEo,'LABELS','∑ (-Jo . Eo)',/ADD_REPLACE
store_data,JodEoCS_efpjsm[0],DATA={X:Eo__t,Y:Jo_dot_Eo_cs},DLIM=dlim_JodotEo,LIM=lim_efp
options,JodEoCS_efpjsm[0],'LABELS'
options,JodEoCS_efpjsm[0],'COLORS'
options,JodEoCS_efpjsm[0],'YTITLE'
options,JodEoCS_efpjsm[0],'YSUBTITLE'



;;----------------------------------------------------------------------------------------
;;  Plot and save
;;----------------------------------------------------------------------------------------
tlimit,minmax(dE__t) + [-1d0,1d0]
traz           = t_get_current_trange()

fgm__tpn       = [fgm_mag[2],fgm_ncb[2]]
jvec_tpn       = tnames(jvec_name_US[0])
efp_ncb_tpn    = tnames(efp_rmspft_ncb[0])
efw_ncb_tpn    = tnames(efw_ncb_tpn[0])
jdE_tpns       = [JodEo_efp_jvsm[0],JodotdE_upsam[0]]
jdECS_tpns     = [JodEoCS_efpjsm[0],JoddECS_upsam[0]]

ef_names       = [efp_ncb_tpn[0],efw_ncb_tpn[0]]
Jo_names       = jdE_tpns
Jo_names       = jdECS_tpns

;;  Change tick style for (-Jo . E)
all_Jo_E_tpn   = [jdE_tpns,jdECS_tpns]
options,all_Jo_E_tpn,'YTICKLEN'
options,all_Jo_E_tpn,'YTICKLEN',/DEF
options,all_Jo_E_tpn,'YTICKLEN',1.0       ;;  use full-length tick marks
options,all_Jo_E_tpn,'YGRIDSTYLE',1       ;;  use dotted lines
;;  Fix Y-Ranges for better looking plots
fgm_mag_yra    = [0d0,20d0]
fgm_dsl_yra    = [-10d0,20d0]
fgm_ncb_yra    = [-20d0,15d0]
jvec_sm_yra    = [-1d0,1d0]*75d-2
efp_dsl_yra    = [-1d0,1d0]*40d0
efp_ncb_yra    = [-1d0,1d0]*25d0
efw_ncb_yra    = [-1d0,1d0]*200d0
E_d_Jo_yra     = [-1d0,1d0]*4d-2
EdJoCS_yra     = [-1.5d0,5d-1]

;;  Remove any Y-ranges set in LIMITS structure
options,[fgm__tpn,jvec_tpn[0],ef_names,jdE_tpns,jdECS_tpns],'YRANGE'

options,fgm__tpn[0],'YRANGE',fgm_mag_yra,/DEF
options,fgm__tpn[1],'YRANGE',fgm_ncb_yra,/DEF
options,fgh_mag_dsl[1],'YRANGE',fgm_dsl_yra,/DEF
options,jvec_tpn[0],'YRANGE',jvec_sm_yra,/DEF
options,efp_ncb_tpn[0],'YRANGE',efp_ncb_yra,/DEF
options,efw_ncb_tpn[0],'YRANGE',efw_ncb_yra,/DEF
options,jdE_tpns,'YRANGE',E_d_Jo_yra,/DEF
options,jdECS_tpns,'YRANGE',EdJoCS_yra,/DEF
options,[efp_dsl_orig[0],efp_spinfitmod[0],efp_rmspft_dsl[0]],'YRANGE',efp_dsl_yra,/DEF


nna            = [fgm__tpn,jvec_tpn[0],ef_names,Jo_names]
  tplot,nna,TRANGE=traz


;;  Save Examples
coord          = coord_ncb[0]
f_pref         = prefu[0]+coord[0]+'-All_fgh_Jo-US_efp-cal-despike-rmDCoff-despin_efw-cal-DS_JodEo_JoddE_'
Jo_names       = jdE_tpns
nna            = [fgm__tpn,jvec_tpn[0],ef_names,Jo_names]

coord          = coord_ncb[0]
f_pref         = prefu[0]+coord[0]+'-All_fgh_Jo-US_efp-cal-despike-rmDCoff-despin_efw-cal-DS_JodEoCS_JoddECS_'
Jo_names       = jdECS_tpns
nna            = [fgm__tpn,jvec_tpn[0],ef_names,Jo_names]


traz           = t_get_current_trange()
fnm_tra        = file_name_times(traz,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
fnames         = f_pref[0]+ftime[0]
PRINT, fnames[0]

popen,fnames[0],/PORT
  tplot,nna,TRANGE=traz
pclose
  tplot,/NOM




;;  Plot Spinfit Model with actual data
traz           = t_ramp1[0] + [-65d-2,1d0]*20
coord          = coord_dsl[0]
nna            = [fgh_mag_dsl,efp_dsl_orig[0],efp_spinfitmod[0],efp_rmspft_dsl[0]]
f_pref         = prefu[0]+coord[0]+'-All_fgh_efp-cal-despike_efp-spinfitmodel_efp-rmDCoff-despin_'

traz           = t_get_current_trange()
fnm_tra        = file_name_times(traz,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
fnames         = f_pref[0]+ftime[0]
PRINT, fnames[0]

popen,fnames[0],/PORT
  tplot,nna,TRANGE=traz
pclose
  tplot,/NOM


;;----------------------------------------------------------------------------------------
;;  Save data for later
;;----------------------------------------------------------------------------------------
traz           = t_ramp1[0] + [-1d0,1d0]*165d0  ;;  330 s window centered on ramp
tlimit,traz

fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_'
fsuff          = 'efp-despiked_rmEconv-DC-despun_'
traz           = t_get_current_trange()
fnm_tra        = file_name_times(traz,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
fname          = fpref[0]+fsuff[0]+ftime[0]
PRINT, fname[0]

tplot_save,FILENAME=fname[0]





































