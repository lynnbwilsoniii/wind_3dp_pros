;;----------------------------------------------------------------------------------------
;; => Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;; => Electron mass [kg]
mp             = 1.6726217770d-27     ;; => Proton mass [kg]
ma             = 6.6446567500d-27     ;; => Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;; => Speed of light in vacuum [m/s]
epo            = 8.8541878170d-12     ;; => Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;; => Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;; => Fundamental charge [C]
kB             = 1.3806488000d-23     ;; => Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;; => Planck Constant [J s]
GG             = 6.6738400000d-11     ;; => Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;; => Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;; => Energy associated with 1 eV of energy [J]
;; => Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K
R_E            = 6.37814d3            ;; => Earth's Equitorial Radius [km]

;; => Compile necessary routines
@comp_lynn_pros
thm_init
;; => Date/Time and Probe
tdate          = '2009-07-13'
tr_00          = tdate[0]+'/'+['07:50:00','10:10:00']
date           = '071309'
probe          = 'b'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
;; => Shock Ramp Times
t_ramp_1       = time_double(tdate[0]+'/'+['08:59:45.440','08:59:48.290'])
t_ramp_2       = time_double(tdate[0]+'/'+['09:24:43.340','09:24:55.100'])
;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
;; => Restore TPLOT session
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_EFI-SCM-Corrected_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]+'.tplot'
file           = FILE_SEARCH(mdir,fname[0])
tplot_restore,FILENAME=file[0],VERBOSE=0

!themis.VERBOSE = 2
tplot_options,'VERBOSE',2

pref           = 'th'+sc[0]+'_'
pos_gse        = 'th'+sc[0]+'_state_pos_gse'
dtxncn_tpn     = pref[0]+'dx_n_dt_tramp'
dtxnrci_tpn    = pref[0]+'dxn_rci_dt_tramp'
dtxnLii_tpn    = pref[0]+'dxn_Lii_dt_tramp'
;;  Define tick marks
names2         = [REVERSE(pos_gse[0]+['_x','_y','_z']),dtxncn_tpn[0],dtxnrci_tpn[0],dtxnLii_tpn[0]]
tplot_options,VAR_LABEL=names2
options,tnames(),'LABFLAG',2,/DEF
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='EFI & SCM Plots ['+tdate[0]+']'

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01

coord          = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
velname        = pref[0]+'peib_velocity_'+coord[0]
magname        = pref[0]+'fgh_'+coord[0]
fgmnm          = pref[0]+'fgh_'+['mag',coord[0]]
tr_jj          = time_double(tdate[0]+'/'+['08:50:00.000','09:30:00.000'])

tplot,fgmnm,TRANGE=tr_jj
;;----------------------------------------------------------------------------------------
;; => Calibrate and Rotate SCM and EFI
;;----------------------------------------------------------------------------------------
magf_up        = [-2.88930d0,1.79045d0,-1.37976d0]
magf_dn        = [  -3.85673d0,10.8180d0,-8.72761d0]
vswi_up        = [-328.746d0,10.8691d0,16.8013d0]
vswi_dn        = [ -97.0335d0,23.6190d0,-9.12016d0]
dens_up        =    7.21921d0
dens_dn        =   47.84030d0

vshn_up        =  -52.769597d0
ushn_up        = -271.85307d0
gnorm          = [0.99012543d0,0.086580460d0,-0.0038282813d0]
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)

vsw_tpnm       = tnames(pref[0]+'Velocity_peib_no_GIs_UV')
tramp          = MEAN(t_ramp_1,/NAN)
nsm            = 10L

.compile temp_thm_cal_rot_ebfields
temp_thm_cal_rot_ebfields,PROBE=sc[0],TRANGE=tr_jj,NIF_STR=nif_str,$
                          VSW_TPNM=vsw_tpnm,TRAMP=tramp,NSM=nsm

;;-----------------------------------------------------------
;;  Remove unnecessary TPLOT handles
;;-----------------------------------------------------------
mode_efi       = ['efp','efw']
mode_scm       = ['scp','scw']
coord_in       = 'gse'
efpref         = pref[0]+mode_efi[1]+'_cal_corrected_DownSampled_'+coord_in[0]
bfpref         = pref[0]+mode_scm[1]+'_cal_NoCutoff_'+coord_in[0]
sfpref         = pref[0]+'S_'+'_TimeSeries_'+coord_in[0]
tp_prefs       = [efpref[0],bfpref[0],sfpref[0]]

n_int          = N_ELEMENTS(tnames(efpref[0]+'_INT*'))
ind            = LINDGEN(n_int)
s_ind          = STRTRIM(STRING(ind,FORMAT='(I3.3)'),2L)
isuffx         = '_INT'+s_ind

;;  Only need intervals 0 and 1 [Wave Burst]
good           = WHERE(ind GE 0 AND ind LE 1,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
del_data,'*_efw_*'+isuffx[bad]
del_data,'*_scw_*'+isuffx[bad]
del_data,'*_S__TimeSeries_*'+isuffx[bad]

;;  Only need interval 0 [Particle Burst]
good           = WHERE(ind EQ 0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
del_data,'*_efp_*'+isuffx[bad]
del_data,'*_scp_*'+isuffx[bad]
;;----------------------------------------------------------------------------------------
;; => Get -(E . j), (n . S), S(w,k), |S(w,k)|, and *eta*
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
coord_in       = 'gse'
coord_out      = 'nif_S1986a'
n_pint         = 2L
int_snum       = STRING(LINDGEN(n_pint),FORMAT='(I3.3)')
tsuffix        = '_INT'+int_snum
nsm            = 10L
nsms           = STRING(FORMAT='(I3.3)',nsm[0])
suffx          = '_sm'+nsms[0]+'pts'

;;  -(E . j) TPLOT names
mid_nmEdj      = 'neg-E-dot-j_efw_cal'
Edj_names      = tnames(pref[0]+mid_nmEdj[0]+suffx[0]+tsuffix)
;;  (n . S) TPLOT names
mid_nmndS      = 'n-dot-S'
ndS_names      = tnames(pref[0]+mid_nmndS[0]+tsuffix)
;;  S(w,k) TPLOT names
mid_nmsV       = 'efw-scw-cal_ExB_'
out_SnameV     = tnames(pref[0]+mid_nmsV[0]+coord_out[0]+tsuffix)
;;  |S(w,k)| TPLOT names
mid_nmsP       = 'efw-scw-cal_ExB-Power_'
out_SnameP     = tnames(pref[0]+mid_nmsP[0]+coord_out[0]+tsuffix)
;;  *eta* TPLOT name
name0          = 'Anom_Resistivities'
mid_nme2       = 'efw_cal-cor_DS_'
eta_name       = tnames(pref[0]+mid_nme2[0]+name0[0]+tsuffix)
;;  |j|^2 TPLOT name
cur_nmmag2     = tnames(pref[0]+'jmags_fgh_nif_S1986a_squared'+suffx[0])
;;  j-vector TPLOT name
mode           = 'fgh'
cur_nmvec      = tnames(pref[0]+'jvec_'+mode[0]+'_'+coord_out[0]+suffx[0])
;;---------------------------------------
;; => Get TPLOT data
;;---------------------------------------
;;  -(E . j) TPLOT names
get_data,Edj_names[0],DATA=temp_Edj0,DLIM=dlim_Edj0,LIM=lim_Edj0
get_data,Edj_names[1],DATA=temp_Edj1,DLIM=dlim_Edj1,LIM=lim_Edj1
;;  (n . S) TPLOT names
get_data,ndS_names[0],DATA=temp_ndS0,DLIM=dlim_ndS0,LIM=lim_ndS0
get_data,ndS_names[1],DATA=temp_ndS1,DLIM=dlim_ndS1,LIM=lim_ndS1
;;  S(w,k)
get_data,out_SnameV[0],DATA=temp_SV0,DLIM=dlim_SV0,LIM=lim_SV0
get_data,out_SnameV[1],DATA=temp_SV1,DLIM=dlim_SV1,LIM=lim_SV1
;;  |S(w,k)|
get_data,out_SnameP[0],DATA=temp_SP0,DLIM=dlim_SP0,LIM=lim_SP0
get_data,out_SnameP[1],DATA=temp_SP1,DLIM=dlim_SP1,LIM=lim_SP1
;;  *eta*
get_data,eta_name[0],DATA=temp_eta0,DLIM=dlim_eta0,LIM=lim_eta0
get_data,eta_name[1],DATA=temp_eta1,DLIM=dlim_eta1,LIM=lim_eta1
;;  |j|^2
get_data,cur_nmmag2[0],DATA=temp_j20,DLIM=dlim_j20,LIM=lim_j20
;;  j-vector
get_data,cur_nmvec[0],DATA=temp_jvec,DLIM=dlim_jvec,LIM=lim_jvec
;;---------------------------------------
;; => Combine intervals
;;---------------------------------------
;;  -(E . j) TPLOT names
Edj__t__int0   = temp_Edj0.X
Edj_val_int0   = temp_Edj0.Y      ;; µW m^(-3)
Edj__t__int1   = temp_Edj1.X
Edj_val_int1   = temp_Edj1.Y      ;; µW m^(-3)
Edj_vals       = [Edj_val_int0,Edj_val_int1]
Edj_t          = [Edj__t__int0,Edj__t__int1]
;;  (n . S) TPLOT names
ndS__t__int0   = temp_ndS0.X
ndS_val_int0   = temp_ndS0.Y      ;; µW m^(-3)
ndS__t__int1   = temp_ndS1.X
ndS_val_int1   = temp_ndS1.Y      ;; µW m^(-3)
ndS_vals       = [ndS_val_int0,ndS_val_int1]
ndS_t          = [ndS__t__int0,ndS__t__int1]
;;  S(w,k)
SVF__t__int0   = temp_SV0.X
SVF_val_int0   = temp_SV0.Y       ;; µW m^(-2)
SVF__t__int1   = temp_SV1.X
SVF_val_int1   = temp_SV1.Y       ;; µW m^(-2)
SVF_vals       = [SVF_val_int0,SVF_val_int1]
SVF_t          = [SVF__t__int0,SVF__t__int1]
;;  |S(w,k)|
SPF__t__int0   = temp_SP0.X
SPF_val_int0   = temp_SP0.Y       ;; µW m^(-2)
SPF__t__int1   = temp_SP1.X
SPF_val_int1   = temp_SP1.Y       ;; µW m^(-2)
SPF_vals       = [SPF_val_int0,SPF_val_int1]
SPF_t          = [SPF__t__int0,SPF__t__int1]
;;  *eta*
eta__t__int0   = temp_eta0.X
eta_val_int0   = temp_eta0.Y      ;; Ω m
eta__t__int1   = temp_eta1.X
eta_val_int1   = temp_eta1.Y      ;; Ω m
eta_vals       = [eta_val_int0,eta_val_int1]
eta_t          = [eta__t__int0,eta__t__int1]
;;---------------------------------------
;; => Smooth S(w,k) and |S(w,k)|
;;---------------------------------------
nsm            = 10L
sm_SPF_vals    = SMOOTH(SPF_vals,nsm[0],/NAN,/EDGE_TRUNCATE)
;; => smooth
nsm            = 10L
sm_SVF_valx    = SMOOTH(SVF_vals[*,0],nsm[0],/NAN,/EDGE_TRUNCATE)
sm_SVF_valy    = SMOOTH(SVF_vals[*,1],nsm[0],/NAN,/EDGE_TRUNCATE)
sm_SVF_valz    = SMOOTH(SVF_vals[*,2],nsm[0],/NAN,/EDGE_TRUNCATE)
sm_SVF_vals    = [[sm_SVF_valx],[sm_SVF_valy],[sm_SVF_valz]]
;;---------------------------------------
;; => Define time range
;;---------------------------------------
t_minj         =  MIN(temp_j20.X,/NAN)
t_maxj         =  MAX(temp_j20.X,/NAN)
t_min          =  MIN([ndS_t,eta_t,SPF_t,SVF_t],/NAN) > t_minj[0]
t_max          = (MAX([ndS_t,eta_t,SPF_t,SVF_t],/NAN) < t_maxj[0]) > t_min[0]
PRINT,';;  ', t_min[0] MOD 864d2, t_max[0] MOD 864d2, t_max[0] - t_min[0]
;;         32382.857       32395.732       12.875000

;; => Keep only data between these time ranges
jmag__t        = temp_j20.X
jmag_sq        = temp_j20.Y*1d-6  ;; A^(+2) m^(-4)
jvec__t        = temp_jvec.X
jvec_sm        = temp_jvec.Y      ;; µA m^(-2)

good           = WHERE(jmag__t GE t_min[0] AND jmag__t LE t_max[0],gd)
PRINT,';;  ', gd
;;          1648

IF (gd GT 0) THEN jvec_sm_t   = jvec__t[good]   ELSE jvec_sm_t   = d
IF (gd GT 0) THEN jvec_sm_val = jvec_sm[good,*] ELSE jvec_sm_val = d
IF (gd GT 0) THEN jmag_sq_t   = jmag__t[good] ELSE jmag_sq_t   = d
IF (gd GT 0) THEN jmag_sq_val = jmag_sq[good] ELSE jmag_sq_val = d
;;-------------------------------------------------------
;; => Interpolate to |j|^2 timestamps
;;-------------------------------------------------------
E_dot_j_sm     = Edj_vals[good,0]
ndotS_sm_jt    = interp(ndS_vals[*,1],   ndS_t,jvec_sm_t,/NO_EXTRAP)

sp_nif_vec_jtx = interp(SVF_vals[*,0],   SVF_t,jvec_sm_t,/NO_EXTRAP)
sp_nif_vec_jty = interp(SVF_vals[*,1],   SVF_t,jvec_sm_t,/NO_EXTRAP)
sp_nif_vec_jtz = interp(SVF_vals[*,2],   SVF_t,jvec_sm_t,/NO_EXTRAP)
smp_nifvec_jtx = interp(sm_SVF_vals[*,0],SVF_t,jvec_sm_t,/NO_EXTRAP)
smp_nifvec_jty = interp(sm_SVF_vals[*,1],SVF_t,jvec_sm_t,/NO_EXTRAP)
smp_nifvec_jtz = interp(sm_SVF_vals[*,2],SVF_t,jvec_sm_t,/NO_EXTRAP)
sp_nif_vec_jt  = [[sp_nif_vec_jtx],[sp_nif_vec_jty],[sp_nif_vec_jtz]]
smp_nif_vec_jt = [[smp_nifvec_jtx],[smp_nifvec_jty],[smp_nifvec_jtz]]

SPF_vals_jt    = interp(SPF_vals,SPF_t,jmag_sq_t,/NO_EXTRAP)
sm_SPF_vals_jt = interp(sm_SPF_vals,SPF_t,jmag_sq_t,/NO_EXTRAP)

eta__iawL88_jt = interp(eta_vals[*,0],eta_t,jmag_sq_t,/NO_EXTRAP)
eta_lhdiC85_jt = interp(eta_vals[*,1],eta_t,jmag_sq_t,/NO_EXTRAP)
eta_lhdiL88_jt = interp(eta_vals[*,2],eta_t,jmag_sq_t,/NO_EXTRAP)
eta_ecdiL88_jt = interp(eta_vals[*,3],eta_t,jmag_sq_t,/NO_EXTRAP)
;;---------------------------------------
;; => Compare |S(w,k)| with *eta* |j|^2
;;---------------------------------------
eta_j2__iawL88 = (eta__iawL88_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
eta_j2_lhdiC85 = (eta_lhdiC85_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
eta_j2_lhdiL88 = (eta_lhdiL88_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
eta_j2_ecdiL88 = (eta_ecdiL88_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
all_eta_j2     = [[eta_j2__iawL88],[eta_j2_lhdiC85],[eta_j2_lhdiL88],[eta_j2_ecdiL88]]





;;---------------------------------------
;; => Print values to ASCII file
;;---------------------------------------
fname          = 'Integrated-FFT-Poynting-Flux-Sm-NotSm_Dissipation-Rate_'+tdate[0]+'.txt'
mform          = '(a30,2E15.5,2f15.5,4E15.5)'

scets          = time_string(jmag_sq_t,PREC=3)
nvals          = N_ELEMENTS(scets)
;;  Open file
OPENW,gunit,fname[0],/GET_LUN
FOR i=0L, nvals - 1L DO BEGIN    $
  PRINTF,gunit,FORMAT=mform,scets[i],SPF_vals_jt[i],sm_SPF_vals_jt[i],$
               ndotS_sm_jt[i],E_dot_j_sm[i],REFORM(all_eta_j2[i,*])
;;  Open file
FREE_LUN,gunit



;; Save corrected fields
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_EFI-SCM-Corrected_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]
tplot_save,FILENAME=fname[0]





















































































;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
;; => Restore TPLOT session
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]+'.tplot'
file           = FILE_SEARCH(mdir,fname[0])
tplot_restore,FILENAME=file[0],VERBOSE=0

!themis.VERBOSE = 2
tplot_options,'VERBOSE',2

pref           = 'th'+sc[0]+'_'
pos_gse        = 'th'+sc[0]+'_state_pos_gse'
names          = [pref[0]+'_Rad',pos_gse[0]+['_x','_y','_z']]
tplot_options,VAR_LABEL=names
options,tnames(),'LABFLAG',2,/DEF

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='EFI & SCM Plots ['+tdate[0]+']'

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01

coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
velname   = pref[0]+'peib_velocity_'+coord[0]
magname   = pref[0]+'fgh_'+coord[0]
fgmnm     = pref[0]+'fgl_'+['mag',coord[0]]
tr_jj     = time_double(tdate[0]+'/'+['08:50:00.000','09:30:00.000'])

tplot,fgmnm,TRANGE=tr_jj
;;----------------------------------------------------------------------------------------
;; => Fix Fields
;;----------------------------------------------------------------------------------------
mode           = 'efp efw'
coord_in       = 'dsl'
coord_out      = 'gse'
typee          = 'calibrated'
fmin_b         = 10.
fcut_b         = 10.
despinb        = 0
nk             = 256L
flow           = 0.1
no_extra       = 1
no_spec        = 1
tran_fac       = 0
poynt_flux     = 0
loadefi        = 1
loadscm        = 1
tclip_fs       = 0
tra            = time_double(tr_00)

wrapper_thm_load_efiscm,PROBE=probe,TRANGE=tra,/GET_SUPPORT,POYNT_FLUX=poynt_flux,    $
                        TRAN_FAC=tran_fac,COORD_IN=coord_in[0],DATATYPE=mode[0],      $
                        LOAD_EFI=loadefi,TYPE_E=typee[0],SE_T_EFI_OUT=se_tefi,        $
                        LOAD_SCM=loadscm,TYPE_B=typee[0],SE_T_SCM_OUT=se_tscm,NK=nk,  $
                        /EDGE_TRUN,FMIN_B=fmin_b,FCUT_B=fcut_b,                       $
                        DESPIN_B=despin_b,FLOW=flow,NO_EXTRA=no_extra,                $
                        NO_SPEC=no_spec,DIRECT_CROSS=direct,TCLIP_FIELDS=tclip_fs,    $
                        COORD_OUT=coord_out[0]

;; => Remove "spikes" by hand
coord_in       = 'dsl'
scp_names      = tnames(pref[0]+'scp_cal_'+coord_in[0]+'*')
efp_names      = tnames(pref[0]+'efp_cal_'+coord_in[0]+'*')
all_fields     = [scp_names,efp_names]
names          = [fgmnm,all_fields]
tplot,names

kill_data_tr,NAMES=all_fields[1]

;; => Remove "spikes" by hand
coord_in       = 'dsl'
scw_names      = tnames(pref[0]+'scw_cal_'+coord_in[0]+'*')
efw_names      = tnames(pref[0]+'efw_cal_'+coord_in[0]+'*')
all_fields     = [scw_names,efw_names]
names          = [fgmnm,all_fields]
tplot,names

kill_data_tr,NAMES=all_fields[1]


;; => Remove NaNs in data
get_data,scp_names[0],DATA=temp_scp,DLIM=dlim_scp,LIM=lim_scp
get_data,scw_names[0],DATA=temp_scw,DLIM=dlim_scw,LIM=lim_scw
get_data,efp_names[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
get_data,efw_names[0],DATA=temp_efw,DLIM=dlim_efw,LIM=lim_efw

test_scp       = FINITE(temp_scp.Y[*,0]) AND FINITE(temp_scp.Y[*,1]) AND FINITE(temp_scp.Y[*,2])
good_scp       = WHERE(test_scp,gdscp)
test_scw       = FINITE(temp_scw.Y[*,0]) AND FINITE(temp_scw.Y[*,1]) AND FINITE(temp_scw.Y[*,2])
good_scw       = WHERE(test_scw,gdscw)
test_efp       = FINITE(temp_efp.Y[*,0]) AND FINITE(temp_efp.Y[*,1]) AND FINITE(temp_efp.Y[*,2])
good_efp       = WHERE(test_efp,gdefp)
test_efw       = FINITE(temp_efw.Y[*,0]) AND FINITE(temp_efw.Y[*,1]) AND FINITE(temp_efw.Y[*,2])
good_efw       = WHERE(test_efw,gdefw)
PRINT,'; ', gdscp, gdscw, gdefp, gdefw
;        16448      104448       16448      209314

IF (gdscp GT 0) THEN temp_scp = {X:temp_scp.X[good_scp],Y:temp_scp.Y[good_scp,*]} ELSE temp_scp = 0
IF (gdscw GT 0) THEN temp_scw = {X:temp_scw.X[good_scw],Y:temp_scw.Y[good_scw,*]} ELSE temp_scw = 0
IF (gdefp GT 0) THEN temp_efp = {X:temp_efp.X[good_efp],Y:temp_efp.Y[good_efp,*]} ELSE temp_efp = 0
IF (gdefw GT 0) THEN temp_efw = {X:temp_efw.X[good_efw],Y:temp_efw.Y[good_efw,*]} ELSE temp_efw = 0
IF (gdscp GT 0) THEN store_data,scp_names[0],DATA=temp_scp,DLIM=dlim_scp,LIM=lim_scp
IF (gdscw GT 0) THEN store_data,scw_names[0],DATA=temp_scw,DLIM=dlim_scw,LIM=lim_scw
IF (gdefp GT 0) THEN store_data,efp_names[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
IF (gdefw GT 0) THEN store_data,efw_names[0],DATA=temp_efw,DLIM=dlim_efw,LIM=lim_efw
IF (gdscp EQ 0) THEN del_data,scp_names[0]
IF (gdscw EQ 0) THEN del_data,scw_names[0]
IF (gdefp EQ 0) THEN del_data,efp_names[0]
IF (gdefw EQ 0) THEN del_data,efw_names[0]

;; => Clean up
DELVAR, test_scp, good_scp, test_scw, good_scw
DELVAR, test_efp, good_efp, test_efw, good_efw

;;----------------------------------------------------------------------------------------
;; => Calibrate and Rotate SCM and EFI
;;----------------------------------------------------------------------------------------
magf_up        = [-2.88930d0,1.79045d0,-1.37976d0]
magf_dn        = [  -3.85673d0,10.8180d0,-8.72761d0]
vswi_up        = [-328.746d0,10.8691d0,16.8013d0]
vswi_dn        = [ -97.0335d0,23.6190d0,-9.12016d0]
dens_up        =    7.21921d0
dens_dn        =   47.84030d0

vshn_up        =  -52.769597d0
ushn_up        = -271.85307d0
gnorm          = [0.99012543d0,0.086580460d0,-0.0038282813d0]
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)

vsw_tpnm       = tnames(pref[0]+'Velocity_peib_no_GIs_UV')
tramp          = MEAN(t_ramp_1,/NAN)

.compile temp_thm_cal_rot_ebfields
temp_thm_cal_rot_ebfields,PROBE=sc[0],TRANGE=tr_jj,NIF_STR=nif_str,$
                          VSW_TPNM=vsw_tpnm,TRAMP=tramp

;del_data,tnames('tha_*_cal_dsl_HighPass*')
;del_data,tnames('tha_*_cal_*_INT*')
;del_data,tnames('tha_*_cal_*_fac*')
;del_data,tnames('tha_*_cal_*_corrected*')
;
;del_data,'thb_scw_cal_HighPass_*'+isuffx[2:10]
;del_data,'thb_efw_cal_corrected_DownSampled_*'+isuffx[2:10]
;del_data,'thb_S__TimeSeries_*'+isuffx[2:10]

;;----------------------------------------------------------------------------------------
;;  Calculate quasi-linear anomalous resistivities
;;
;;  REFERENCES:  
;;               1)  Spitzer, L. and R. Harm (1953), "Transport Phenomena in a
;;                      Completely Ionized Gas," Phys. Rev., Vol. 89, pp. 977.
;;               2)  Labelle, J.W. and R.A. Treumann (1988), "Plasma Waves at the
;;                      Dayside Magnetopause," Space Sci. Rev., Vol. 47, pp. 175.
;;               3)  Coroniti, F.V. (1985), "Space Plasma Turbulent Dissipation:
;;                      Reality or Myth?," Space Sci. Rev., Vol. 42, pp. 399.
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
coord_out      = 'nif_S1986a'
frbsuf         = ['b','r','f']
frbytt         = ['Burst','Reduced','Full']
ei_mid         = ['e','i']
emid           = 'pee'+frbsuf
imid           = 'pei'+frbsuf
iden__mid      = 'N_'
itemp_mid      = 'T_avg_'
mom_suffx      = '_no_GIs_UV'
eden__suffx    = '_density'
etemp_suffx    = '_avgtemp'
;; => define interval suffix for TPLOT names
n_pint         = 2L
int_snum       = STRING(LINDGEN(n_pint),FORMAT='(I3.3)')
tsuffix        = '_INT'+int_snum

;;  Electron TPLOT moment names
dens_ebn       = pref[0]+emid[0]+eden__suffx[0]
temp_ebn       = pref[0]+emid[0]+etemp_suffx[0]
;;  Corrected Ion TPLOT moment names
dens_ibn       = pref[0]+iden__mid[0]+imid[0]+mom_suffx[0]
temp_ibn       = pref[0]+itemp_mid[0]+imid[0]+mom_suffx[0]
;;  E-Field [AC-Coupled] TPLOT names
mid_nme        = 'efw_cal_corrected_DownSampled_'
coord_out      = 'nif_S1986a'
efi_names      = tnames(pref[0]+mid_nme[0]+coord_out[0]+tsuffix)
;;  B-Field [quasi-static] TPLOT names
bmag_nm        = tnames(pref[0]+'fgh_mag')

get_data,efi_names[0],DATA=tempe,DLIM=dlime,LIM=lime
data_att_e0    = dlime.DATA_ATT

;; => Define some defaults
r_struct       = 0  ;; define dummy value which will be overwritten by routine
res_labs       = ['IAW[LT1988]','LHDI[C1985]','LHDI[LT1988]','ECDI[LT1988]']
res_cols       = [250,200,100,30]
yttl           = 'Anomalous Resistivities [Ohm m]'
note           = '[data in NIF but still in GSE basis]'
;; => Define default plot limits structure
data_att_res   = data_att_e0
str_element,data_att_res,'COORD_SYS','scalar',/ADD_REPLACE
str_element,data_att_res,'UNITS','Ohm m',/ADD_REPLACE
str_element,data_att_res,'NOTE',note[0],/ADD_REPLACE
dlim0          = dlime
str_element,dlim0,'CDF',/DELETE
str_element,dlim0,'DATA_ATT',data_att_res,/ADD_REPLACE
str_element,dlim0,'COLORS',res_cols,/ADD_REPLACE
str_element,dlim0,'LABELS',res_labs,/ADD_REPLACE
str_element,dlim0,'YTITLE',yttl,/ADD_REPLACE
str_element,dlim0,'YLOG',1,/ADD_REPLACE
;; => Define output TPLOT plot limits structures
res_dlim       = dlim0
res_lim        = lime
;; => Define output TPLOT name
name0          = 'Anom_Resistivities'
mid_nme2       = 'efw_cal-cor_DS_'
eta_name       = pref[0]+mid_nme2[0]+name0[0]+tsuffix
FOR j=0L, n_pint - 1L DO BEGIN                                                           $
  dE_nm    = efi_names[j]                                                              & $
  bo_nm    = bmag_nm[0]                                                                & $
  resistivity_calc_wrapper,dens_ibn[0],temp_ebn[0],DE_NAME=dE_nm[0],BO_NAME=bo_nm[0],    $
                           TI_NAME=temp_ibn[0],R_STRUCT=r_struct                       & $
  IF (SIZE(r_struct,/TYPE) NE 8L) THEN CONTINUE                                        & $
  times        = r_struct.ABSCISSA                                                     & $
  SH1953_res   = r_struct.ELECTRONION_RESISTIVITY_SH1953                               & $
  iaw_LT1988   = r_struct.IAW_RESISTIVITY_LT1988                                       & $
  lhdi_C1985   = r_struct.LHDI_RESISTIVITY_C1985                                       & $
  lhdi_L1988   = r_struct.LHDI_RESISTIVITY_LT1988                                      & $
  ecdi_L1988   = r_struct.ECDI_RESISTIVITY_LT1988                                      & $
  all_resits   = [[iaw_LT1988],[lhdi_C1985],[lhdi_L1988],[ecdi_L1988]]                 & $
  store_data,eta_name[j],DATA={X:times,Y:all_resits},DLIM=res_dlim,LIM=res_lim         & $
  str_element,SH1953_str,'T'+int_snum[j],{X:times,Y:SH1953_res},/ADD_REPLACE           & $
  r_struct     = 0

;;----------------------------------------------------------------------------------------
;;  Correlate |S(w,k)| with |j|^2
;;----------------------------------------------------------------------------------------
;;  Steps:  
;;          1)  get both intervals for |S(w,k)| and *eta* and combine them
;;          2)  get |j|^2 and downsample |S(w,k)| and *eta* to |j|^2 timestamps
;;          3)  multiply *eta* by |j|^2
;;          4)  compare |S(w,k)| with *eta* |j|^2
;;----------------------------------------------------------------------------------------
nsm            = 10L
nsms           = STRING(FORMAT='(I3.3)',nsm[0])
suffx          = '_sm'+nsms[0]+'pts'

sc             = probe[0]
pref           = 'th'+sc[0]+'_'
coord_in       = 'gse'
coord_out      = 'nif_S1986a'
;; => Define interval suffix for TPLOT names
n_pint         = 2L
int_snum       = STRING(LINDGEN(n_pint),FORMAT='(I3.3)')
tsuffix        = '_INT'+int_snum
;;  E-Field [AC-Coupled] TPLOT names
mid_nme        = 'efw_cal_corrected_DownSampled_'
efi_names      = tnames(pref[0]+mid_nme[0]+coord_out[0]+tsuffix)
;;  B-Field [AC-Coupled] TPLOT names
mid_nmb        = 'scw_cal_HighPass_'
scm_names      = tnames(pref[0]+mid_nmb[0]+coord_in[0]+tsuffix)
;;  |S(w,k)| TPLOT names
mid_nmsP       = 'efw-scw-cal_ExB-Power_'
out_SnameP     = tnames(pref[0]+mid_nmsP[0]+coord_out[0]+tsuffix)
;;  *eta* TPLOT name
name0          = 'Anom_Resistivities'
mid_nme2       = 'efw_cal-cor_DS_'
eta_name       = tnames(pref[0]+mid_nme2[0]+name0[0]+tsuffix)
;;  |j|^2 TPLOT name
cur_nmmag2     = tnames(pref[0]+'jmags_fgh_nif_S1986a_squared'+suffx[0])
;;---------------------------------------
;; => Get TPLOT data
;;---------------------------------------
;;  E [NIF (GSE basis)]
get_data,efi_names[0],DATA=temp_ef0,DLIM=dlim_ef0,LIM=lim_ef0
get_data,efi_names[1],DATA=temp_ef1,DLIM=dlim_ef1,LIM=lim_ef1
;;  B [NIF (GSE basis) = GSE]
get_data,scm_names[0],DATA=temp_bf0,DLIM=dlim_bf0,LIM=lim_bf0
get_data,scm_names[1],DATA=temp_bf1,DLIM=dlim_bf1,LIM=lim_bf1
;;  |S(w,k)|
get_data,out_SnameP[0],DATA=temp_SP0,DLIM=dlim_SP0,LIM=lim_SP0
get_data,out_SnameP[1],DATA=temp_SP1,DLIM=dlim_SP1,LIM=lim_SP1
;;  *eta*
get_data,eta_name[0],DATA=temp_eta0,DLIM=dlim_eta0,LIM=lim_eta0
get_data,eta_name[1],DATA=temp_eta1,DLIM=dlim_eta1,LIM=lim_eta1
;;  |j|^2
get_data,cur_nmmag2[0],DATA=temp_j20,DLIM=dlim_j20,LIM=lim_j20
;;---------------------------------------
;; => Define time range
;;---------------------------------------
t_minj         =  MIN(temp_j20.X,/NAN)
t_maxj         =  MAX(temp_j20.X,/NAN)
t_min          =  MIN([temp_SP0.X,temp_eta0.X],/NAN) > t_minj[0]
t_max          = (MAX([temp_SP1.X,temp_eta1.X],/NAN) < t_maxj[0]) > t_min[0]
PRINT,';;  ', t_min[0] MOD 864d2, t_max[0] MOD 864d2, t_max[0] - t_min[0]
;;         32382.857       32395.732       12.875000

;; => Keep only data between these time ranges
jmag__t        = temp_j20.X
jmag_sq        = temp_j20.Y*1d-6  ;; A^(+2) m^(-2)
good           = WHERE(jmag__t GE t_min[0] AND jmag__t LE t_max[0],gd)
PRINT,';;  ', gd
;;          1648

IF (gd GT 0) THEN jmag_sq_t   = jmag__t[good] ELSE jmag_sq_t   = d
IF (gd GT 0) THEN jmag_sq_val = jmag_sq[good] ELSE jmag_sq_val = d
;;---------------------------------------
;; => Combine intervals
;;---------------------------------------
;;  E-Fields
efi__t__int0   = temp_ef0.X
efi_val_int0   = temp_ef0.Y*1d-3 ;; V/m
efi__t__int1   = temp_ef1.X
efi_val_int1   = temp_ef1.Y*1d-3 ;; V/m
efi_vals       = [efi_val_int0,efi_val_int1]
efi_t          = [efi__t__int0,efi__t__int1]
;;  B-Fields
scm__t__int0   = temp_bf0.X
scm_val_int0   = temp_bf0.Y*1d-9 ;; T
scm__t__int1   = temp_bf1.X
scm_val_int1   = temp_bf1.Y*1d-9 ;; T
scm_vals       = [scm_val_int0,scm_val_int1]
scm_t          = [scm__t__int0,scm__t__int1]
;;  *eta*
eta__t__int0   = temp_eta0.X
eta_val_int0   = temp_eta0.Y      ;; Ω m
eta__t__int1   = temp_eta1.X
eta_val_int1   = temp_eta1.Y      ;; Ω m
eta_vals       = [eta_val_int0,eta_val_int1]
eta_t          = [eta__t__int0,eta__t__int1]
;;  |S(w,k)|
SPF__t__int0   = temp_SP0.X
SPF_val_int0   = temp_SP0.Y       ;; µW m^(-2)
SPF__t__int1   = temp_SP1.X
SPF_val_int1   = temp_SP1.Y       ;; µW m^(-2)
SPF_vals       = [SPF_val_int0,SPF_val_int1]
SPF_t          = [SPF__t__int0,SPF__t__int1]

nsm            = 10L
sm_SPF_vals    = SMOOTH(SPF_vals,nsm[0],/NAN,/EDGE_TRUNCATE)
;;-------------------------------------------------------
;; => Interpolate |S(w,k)| and *eta* to |j|^2 timestamps
;;-------------------------------------------------------
SPF_vals_jt    = interp(SPF_vals,SPF_t,jmag_sq_t,/NO_EXTRAP)
sm_SPF_vals_jt = interp(sm_SPF_vals,SPF_t,jmag_sq_t,/NO_EXTRAP)

eta__iawL88_jt = interp(eta_vals[*,0],eta_t,jmag_sq_t,/NO_EXTRAP)
eta_lhdiC85_jt = interp(eta_vals[*,1],eta_t,jmag_sq_t,/NO_EXTRAP)
eta_lhdiL88_jt = interp(eta_vals[*,2],eta_t,jmag_sq_t,/NO_EXTRAP)
eta_ecdiL88_jt = interp(eta_vals[*,3],eta_t,jmag_sq_t,/NO_EXTRAP)
;;---------------------------------------
;; => Compare |S(w,k)| with *eta* |j|^2
;;---------------------------------------
eta_j2__iawL88 = (eta__iawL88_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
eta_j2_lhdiC85 = (eta_lhdiC85_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
eta_j2_lhdiL88 = (eta_lhdiL88_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
eta_j2_ecdiL88 = (eta_ecdiL88_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
all_eta_j2     = [[eta_j2__iawL88],[eta_j2_lhdiC85],[eta_j2_lhdiL88],[eta_j2_ecdiL88]]
;;  Calculate |S(w,k)|/(*eta* |j|^2)  [km]
ratio__iawL88  = SPF_vals/eta_j2__iawL88*1d-3
ratio_lhdiC85  = SPF_vals/eta_j2_lhdiC85*1d-3
ratio_lhdiL88  = SPF_vals/eta_j2_lhdiL88*1d-3
ratio_ecdiL88  = SPF_vals/eta_j2_ecdiL88*1d-3
all_ratio      = [[ratio__iawL88],[ratio_lhdiC85],[ratio_lhdiL88],[ratio_ecdiL88]]

;;---------------------------------------
;; => Send to TPLOT
;;---------------------------------------
Delta_str      = STRUPCASE(get_greek_letter('delta'))
mu__str        = get_greek_letter('mu')
muo_str        = mu__str[0]+'!Do!N'
eta_str        = get_greek_letter('eta')
omega_str      = get_greek_letter('omega')
nsm            = 10L
nsms           = STRING(FORMAT='(I3.3)',nsm[0])
suffx          = '_sm'+nsms[0]+'pts'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'

;;  Combined intervals for |S(w,k)|
mid_nmsP       = 'efw-scw-cal_ExB-Power_'
out_SnameP01   = pref[0]+mid_nmsP[0]+coord_out[0]+'_INT-All'
dlim_SP01      = dlim_SP0
lim_SP01       = lim_SP0
yttl__out      = '|S| [FFT Power, 10^(-6) W/m^2, All Int.]'
str_element,dlim_SP01,'YTITLE',yttl__out,/ADD_REPLACE
spf_labs       = ['|S|','|S| [10 pt smoothed]']
str_element,dlim_SP01,'LABELS',spf_labs,/ADD_REPLACE
str_element,dlim_SP01,'COLORS',[ 50,250],/ADD_REPLACE
stru           = {X:SPF_t,Y:[[SPF_vals],[sm_SPF_vals]]}
store_data,out_SnameP01[0],DATA=stru,DLIM=dlim_SP01,LIM=lim_SP01

;;  *eta* |j|^2
diss_nme       = pref[0]+'eta-j-squared'+suffx[0]
ratio_nme      = pref[0]+'ratio_ExB-Power_to_eta-j-squared'+suffx[0]
dlim_etaj2     = dlim_j20
lim_etaj2      = lim_j20
yttl__out      = eta_str[0]+'|j|!U2!N [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
res_labs       = ['IAW[LT1988]','LHDI[C1985]','LHDI[LT1988]','ECDI[LT1988]']
res_cols       = [250,200,100,30]
str_element,dlim_etaj2,'COLORS',res_cols,/ADD_REPLACE
str_element,dlim_etaj2,'LABELS',res_labs,/ADD_REPLACE
str_element,dlim_etaj2,'YTITLE',yttl__out,/ADD_REPLACE
str_element,dlim_etaj2,'YLOG',1,/ADD_REPLACE
stru           = {X:jmag_sq_t,Y:all_eta_j2}
store_data,diss_nme[0],DATA=stru,DLIM=dlim_etaj2,LIM=lim_etaj2

;;  |S(w,k)|/(*eta* |j|^2)
note           = '[Ratio of (Integrated FFT Poynting Flux)/(Ohmic Dissipation Rate) -> scale length]'
yttl__out      = '|S('+omega_str[0]+',k)|/('+eta_str[0]+'|j|!U2!N'+')  [km]'
dlim_ratio     = dlim_SP0
lim_ratio      = lim_SP0
str_element,dlim_ratio,'COLORS',res_cols,/ADD_REPLACE
str_element,dlim_ratio,'LABELS',res_labs,/ADD_REPLACE
str_element,dlim_ratio,'YTITLE',yttl__out,/ADD_REPLACE
str_element,dlim_ratio,'YLOG',1,/ADD_REPLACE
str_element,dlim_ratio,'DATA_ATT.UNITS','km',/ADD_REPLACE
str_element,dlim_ratio,'DATA_ATT.NOTE',note[0],/ADD_REPLACE
stru           = {X:jmag_sq_t,Y:all_ratio}
store_data,ratio_nme[0],DATA=stru,DLIM=dlim_ratio,LIM=lim_ratio


;;---------------------------------------
;; => Print values to ASCII file
;;---------------------------------------
fname          = 'Integrated-FFT-Poynting-Flux-Sm-NotSm_Dissipation-Rate_'+tdate[0]+'.txt'
mform          = '(a30,2E15.5,4E15.5)'

scets          = time_string(jmag_sq_t,PREC=3)
nvals          = N_ELEMENTS(scets)

;;  Open file
OPENW,gunit,fname[0],/GET_LUN
FOR i=0L, nvals - 1L DO BEGIN    $
  PRINTF,gunit,FORMAT=mform,scets[i],SPF_vals_jt[i],sm_SPF_vals_jt[i],REFORM(all_eta_j2[i,*])
;;  Close file
FREE_LUN,gunit


;;---------------------------------------
;; => Save correlation plots
;;---------------------------------------

WSET,1
PLOT,SPF_vals_jt,jmag_sq_val,/YLOG,/XLOG,/NODATA
  OPLOT,SPF_vals_jt,jmag_sq_val,PSYM=2,COLOR=50
  OPLOT,sm_SPF_vals_jt,jmag_sq_val,PSYM=7,COLOR=250


yttle = eta_str[0]+'|j|!U2!N [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
xttle = '|S| [FFT Power, '+mu__str[0]+'W/m!U-2!N'+']'
pttle = 'Dissipation Rate vs. Integrated FFT Poynting Flux '+tdate[0]
pstr  = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1}
WSET,1
PLOT,SPF_vals_jt,all_eta_j2[*,0],_EXTRA=pstr
  OPLOT,SPF_vals_jt,all_eta_j2[*,0],PSYM=2,COLOR=50
  OPLOT,sm_SPF_vals_jt,all_eta_j2[*,0],PSYM=7,COLOR=250



pttle = 'Dissipation Rate vs. Integrated FFT Poynting Flux '+tdate[0]
popen,'Dissipation-Rate_vs_Integrated-FFT-Poynting-Flux_'+tdate[0],/LAND
  mu__strps      = get_greek_letter('mu')
  eta_strps      = get_greek_letter('eta')
  yttleps        = eta_strps[0]+'|j|!U2!N [Dissipation, '+mu__strps[0]+'W m!U-3!N'+']'
  xttleps        = '|S| [FFT Power, '+mu__strps[0]+'W/m!U-2!N'+']'
  pstrps         = {TITLE:pttle,XTITLE:xttleps,YTITLE:yttleps,YLOG:1,XLOG:1,NODATA:1}
  PLOT,SPF_vals_jt,all_eta_j2[*,0],_EXTRA=pstrps
    OPLOT,SPF_vals_jt,all_eta_j2[*,0],PSYM=2,COLOR=50
pclose


xttle = eta_str[0]+'|j|!U2!N [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
yttle = '|S| [FFT Power, '+mu__str[0]+'W/m!U-2!N'+']'
pttle = 'Integrated FFT Poynting Flux vs. Dissipation Rate '+tdate[0]
pstr  = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1}
WSET,1
PLOT,all_eta_j2[*,0],SPF_vals_jt,_EXTRA=pstr
  OPLOT,all_eta_j2[*,0],SPF_vals_jt,PSYM=2,COLOR=50
  OPLOT,all_eta_j2[*,0],sm_SPF_vals_jt,PSYM=7,COLOR=250





































;;--------------------------------------------------
;; Save corrected fields
;;--------------------------------------------------
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_EFI-SCM-Corrected_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]
tplot_save,FILENAME=fname[0]










































;-----------------------------------------------------------------------------------------
; => Load all relevant data
;-----------------------------------------------------------------------------------------
themis_load_all_inst,DATE=date[0],PROBE=probe[0],/LOAD_EFI,/LOAD_SCM,/TRAN_FAC,         $
                         /TCLIP_FIELDS,SE_T_EFI_OUT=tr_all_efi,SE_T_SCM_OUT=tr_all_scm, $
                         /NO_EXTRA,/NO_SPEC,/POYNT_FLUX,TRANGE=time_double(tr_00)

;; Reconfigure graphics
old_dev = !D.NAME             ;  save current device name
SET_PLOT,'PS'                 ;  change to PS so we can edit the font mapping
loadct2,43
;DEVICE,/SYMBOL,FONT_INDEX=19  ;set font !19 to Symbol
!P.FONT = -1
SET_PLOT,old_dev              ;  revert to old device
!P.FONT = -1
loadct2,43
DEVICE,DECOMPOSE=0,RETAIN=2
;; initialize font in popen
popen,FONT=-1
pclose
SPAWN,'rm -rf plot.ps'

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100


nefi           = N_ELEMENTS(REFORM(tr_all_efi[*,0]))
nscm           = N_ELEMENTS(REFORM(tr_all_scm[*,0]))
PRINT,'; ', nefi, nscm
;           17          17

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
;-----------------------------------------------------------------------------------------
; => Plot data
;-----------------------------------------------------------------------------------------
tr_eb   = tdate[0]+'/'+['08:50:00','09:45:00']
treb    = time_double(tr_eb)

sc      = probe[0]
pref    = 'th'+sc[0]+'_'
;coord   = 'gse'
coord   = 'dsl'

fgmnm   = pref[0]+'fgh_'+['mag',coord[0]]
efwnm   = pref[0]+'efw_cal_'+coord[0]+'_corrected*'
scwnm   = pref[0]+'scw_cal_'+coord[0]+'*'
names   = [fgmnm,efwnm,scwnm]


tplot,names,TRANGE=treb
;;----------------------------------------------------------------------------------------
;; => Save Plots
;;----------------------------------------------------------------------------------------
sc             = probe[0]
scu            = STRUPCASE(sc[0])
pref           = 'th'+sc[0]+'_'
coord          = 'gse'
fgmnm          = pref[0]+'fgh_'+['mag',coord[0]]  ;; FGM TPLOT handles

ind            = LINDGEN(nefi)
s_ind          = STRTRIM(STRING(ind,FORMAT='(I3.3)'),2L)
isuffx         = '_INT'+s_ind
stpref         = 'S__TimeSeries_'
;; => Rotate Poynting flux to GSE
in_names       = pref[0]+stpref[0]+'dsl'+isuffx
out_names      = pref[0]+stpref[0]+coord[0]+isuffx
FOR j=0L, nefi - 1L DO BEGIN $
  thm_cotrans,in_names[j],out_names[j],IN_COORD='dsl',OUT_COORD=coord[0],VERBOSE=0
;; => Fix YTITLE
poyn_names     = out_names
options,poyn_names,'YTITLE'
options,poyn_names,'YTITLE','S ['+STRUPCASE(coord[0])+', !7l!3W/m!U-2!N]',/DEF


efwpre         = 'efw_cal_'
scwpre         = 'scw_cal_'
ffname         = ['efw','scw']
tfname         = ['corrected'+['','_DownSampled'],'HighPass']
;; => Define TPLOT handles
efc__names     = pref[0]+efwpre[0]+tfname[0]+'_'+coord[0]+isuffx
efds_names     = pref[0]+efwpre[0]+tfname[1]+'_'+coord[0]+isuffx
bfhp_names     = pref[0]+scwpre[0]+tfname[2]+'_'+coord[0]+isuffx

;; => Determine time ranges
tra_all        = DBLARR(nefi,2)
FOR j=0L, nefi - 1L DO BEGIN                                         $
  aname  = [fgmnm,efds_names[j],bfhp_names[j],poyn_names[j]]       & $
  get_data,aname[2],DATA=tempe                                     & $
  get_data,aname[3],DATA=tempb                                     & $
  get_data,aname[4],DATA=temps                                     & $
  tra_l  = MIN([tempe.X,tempb.X,temps.X],/NAN) - 2d0               & $
  tra_h  = MAX([tempe.X,tempb.X,temps.X],/NAN) + 2d0               & $
  tra_all[j,*] = [tra_l[0],tra_h[0]]


;; => Define file name prefixes
s_fsuff = 'PoyntingFlux_'
f_pref  = 'FGM-fgh-GSE_TH-'+scu[0]+'_efw-cor-DownSampled_scw-HighPass_'+s_fsuff[0]

FOR j=0L, nefi - 1L DO BEGIN                                         $
  aname  = [fgmnm,efds_names[j],bfhp_names[j],poyn_names[j]]       & $
;  tra    = REFORM(tr_all_efi[j,*]) + [-1d0,1d0]*2d0                & $
  tra    = REFORM(tra_all[j,*])                                    & $
  get_data,aname[3],DATA=temp                                      & $
  testx  = (TOTAL(FINITE(temp.Y[*,0])) EQ 0)                       & $
  testy  = (TOTAL(FINITE(temp.Y[*,1])) EQ 0)                       & $
  testz  = (TOTAL(FINITE(temp.Y[*,2])) EQ 0)                       & $
  IF (testx OR testy OR testz) THEN CONTINUE                       & $
  fnm    = file_name_times(tra,PREC=3)                             & $
  ftimes = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)             & $
  fname  = f_pref[0]+ftimes[0]+isuffx[j]                           & $
  tplot,aname,TRANGE=tra,/NOM                                      & $
  popen,fname[0],/PORT                                             & $
    tplot,aname,TRANGE=tra,/NOM                                    & $
  pclose
;;----------------------------------------------------------------------------------------
;; => Load Wavelets
;;----------------------------------------------------------------------------------------
tplot,[fgmnm,efds_names[j],bfhp_names[j],poyn_names[j]],/NOM,TRANGE=REFORM(tra_all[j,*])

kill_data_tr,names=[efds_names[j],bfhp_names[j],poyn_names[j]]
;;  Bad indices
;;  j  =  3
;;  j  =  4
;;  j  =  5
;;  j  =  9
;;  j  = 10
;;  j  = 12
;;  j  = 13
;;  j  = 14
;;  j  = 16

ind            = LINDGEN(nefi)
test           = (ind LT 3) OR ((ind GT  5) AND ((ind NE  9) AND (ind NE 10) AND $
                                                 (ind NE 12) AND (ind NE 13) AND $
                                                 (ind NE 14) AND (ind NE 16)))
good           = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
gind           = REPLICATE(0b,nefi)
bind           = REPLICATE(1b,nefi)
bind[good]     = 0b
gind[good]     = 1b

vec_s          = ['x','y','z']
units          = 'mV/m'
sc             = probe[0]
scu            = STRUPCASE(sc[0])
coord          = 'gse'
instr          = 'efw'
yran           = [1d1,4096d0]
inpre          = 'thb_efw_cal_corrected_DownSampled_gse'
in_names       = inpre[0]+isuffx
out_names      = STRARR(nefi,3L)
FOR k=0L, 2L DO out_names[*,k] = inpre[0]+'_'+vec_s[k]+isuffx

;; keep only "good" names
in_names       = in_names[good]
out_names      = out_names[good,*]

;; => Load EFI Wavelets
themis_load_wavelets,in_names,out_names,COORD=coord[0],UNITS=units[0],$
                     INSTRUMENT=instr[0],SPACECRAFT='THEMIS-'+scu[0], $
                     NSCALE=nscale

efi_gse__namex = out_names.(0)
efi_wvlt_namex = efi_gse__namex+'_wavelet'
efi_conf_namex = efi_wvlt_namex+'_Conf_Level_95'
efi_gse__namey = out_names.(1)
efi_wvlt_namey = efi_gse__namey+'_wavelet'
efi_conf_namey = efi_wvlt_namey+'_Conf_Level_95'
efi_gse__namez = out_names.(2)
efi_wvlt_namez = efi_gse__namez+'_wavelet'
efi_conf_namez = efi_wvlt_namez+'_Conf_Level_95'
;; => Define options
efi_gse__names = [[efi_gse__namex],[efi_gse__namey],[efi_gse__namez]]
efi_wvlt_names = [[efi_wvlt_namex],[efi_wvlt_namey],[efi_wvlt_namez]]
efi_conf_names = [[efi_conf_namex],[efi_conf_namey],[efi_conf_namez]]
efi_wnms       = [out_names.(0),out_names.(1),out_names.(2)]+'_wavelet*'

options,efi_wnms,'YRANGE'
options,efi_wnms,'YRANGE',yran,/DEF
options,efi_wnms,'YLOG'
options,efi_wnms,'YLOG',1,/DEF
FOR k=0L, 2L DO options,efi_wvlt_names[*,k],'MIN_VALUE'
FOR k=0L, 2L DO options,efi_wvlt_names[*,k],'MIN_VALUE',1d-6,/DEF


units          = 'nT'
instr          = 'scw'
inpre          = 'thb_scw_cal_HighPass_gse'
in_names       = inpre[0]+isuffx
out_names      = STRARR(nefi,3L)
FOR k=0L, 2L DO out_names[*,k] = inpre[0]+'_'+vec_s[k]+isuffx
;; keep only "good" names
in_names       = in_names[good]
out_names      = out_names[good,*]

;; => Load SCM Wavelets
themis_load_wavelets,in_names,out_names,COORD=coord[0],UNITS=units[0],$
                     INSTRUMENT=instr[0],SPACECRAFT='THEMIS-'+scu[0], $
                     NSCALE=nscale

scm_gse__namex = out_names.(0)
scm_wvlt_namex = scm_gse__namex+'_wavelet'
scm_conf_namex = scm_wvlt_namex+'_Conf_Level_95'
scm_gse__namey = out_names.(1)
scm_wvlt_namey = scm_gse__namey+'_wavelet'
scm_conf_namey = scm_wvlt_namey+'_Conf_Level_95'
scm_gse__namez = out_names.(2)
scm_wvlt_namez = scm_gse__namez+'_wavelet'
scm_conf_namez = scm_wvlt_namez+'_Conf_Level_95'
;; => Define options
scm_gse__names = [[scm_gse__namex],[scm_gse__namey],[scm_gse__namez]]
scm_wvlt_names = [[scm_wvlt_namex],[scm_wvlt_namey],[scm_wvlt_namez]]
scm_conf_names = [[scm_conf_namex],[scm_conf_namey],[scm_conf_namez]]
scm_wnms       = [out_names.(0),out_names.(1),out_names.(2)]+'_wavelet*'

options,scm_wnms,'YRANGE'
options,scm_wnms,'YRANGE',yran,/DEF
options,scm_wnms,'YLOG'
options,scm_wnms,'YLOG',1,/DEF
FOR k=0L, 2L DO options,scm_wvlt_names[*,k],'MIN_VALUE'
FOR k=0L, 2L DO options,scm_wvlt_names[*,k],'MIN_VALUE',1d-8,/DEF


;; => Create nfce and (n+1/2)fce variable
get_data,fgmnm[0],DATA=fgm_bmag
bmag          = fgm_bmag.Y
fcefac        = qq[0]*1d-9/(2d0*!DPI*me[0])
fce_1         = fcefac[0]*bmag             ;; electron cyclotron frequency [Hz]
nf            = 4L
n_fce         = DINDGEN(nf) + 1d0
n_12_fce      = DINDGEN(nf) + 1d0/2d0
nfce          = DBLARR(N_ELEMENTS(fce_1),nf)
n12fce        = DBLARR(N_ELEMENTS(fce_1),nf)
FOR k=0L, nf - 1L DO nfce[*,k]   = fce_1*n_fce[k]
FOR k=0L, nf - 1L DO n12fce[*,k] = fce_1*n_12_fce[k]

nfce_str      = STRTRIM(STRING(n_fce,FORMAT='(I1.1)'),2L)
n12fce_st0    = STRTRIM(STRING(n_12_fce,FORMAT='(I1.1)'),2L)
n12fce_num    = LONG(n12fce_st0)*2L + 1L
n12fce_str    = STRTRIM(STRING(n12fce_num,FORMAT='(I1.1)'),2L)+'/2'

nfce_labs     = nfce_str+' f!Dce!N'
n12fce_labs   = n12fce_str+' f!Dce!N'
fce_cols      = LINDGEN(nf)*(250 - 30)/(nf - 1L) + 30L

op_nfce       = 'thb_fgh_nfce'
store_data,op_nfce[0],DATA={X:fgm_bmag.X,Y:nfce}
options,op_nfce,'YRANGE',yran,/DEF
options,op_nfce,'YLOG',1,/DEF
options,op_nfce,'YTITLE','n f!Dce!N [Hz]',/DEF
options,op_nfce,'LABELS',nfce_labs,/DEF

op_n12_fce    = 'thb_fgh_n12_fce'
store_data,op_n12_fce[0],DATA={X:fgm_bmag.X,Y:n12fce}
options,op_n12_fce,'YRANGE',yran,/DEF
options,op_n12_fce,'YLOG',1,/DEF
options,op_n12_fce,'YTITLE','n f!Dce!N [Hz]',/DEF
options,op_n12_fce,'LABELS',n12fce_labs,/DEF

options,[op_nfce[0],op_n12_fce[0]],'COLORS',fce_cols,/DEF


nnw           = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
;;----------------------------------------------------------------------------------------
;; => Save Wavelet Plots
;;----------------------------------------------------------------------------------------
tplot_options,'NO_INTERP',0       ;; allows interpolation in spectrograms


ltag          = ['LEVELS','C_ANNOTATION','YLOG','C_THICK']
lims          = CREATE_STRUCT(ltag,1.0,'95%',1,1.5)

vec_su        = STRUPCASE(['x','y','z'])
iwavsfx       = isuffx[good]
tra_wav       = tra_all[good,*]
ntr           = N_ELEMENTS(tra_wav[*,0])
;; => Determine wavelet time ranges
FOR j=0L, ntr - 1L DO BEGIN                                            $
  tra    = REFORM(tra_wav[j,*])                                      & $
  FOR k=0L, 2L DO BEGIN                                                $
    get_data,efi_gse__names[j,k],DATA=tempe                          & $
    get_data,efi_wvlt_names[j,k],DATA=tempw                          & $
    testx = (FINITE(tempe.Y) NE 0) AND (ABS(tempe.Y) GT 0.)          & $
    goodx = WHERE(testx,gdx)                                         & $
    tra_wav[j,0] = tra[0] > MIN(tempe.X[goodx],/NAN)                 & $
    tra_wav[j,1] = tra[1] < MAX(tempe.X[goodx],/NAN)
;; clean up
DELVAR,tempe,tempw,testx,goodx
;; Define EFI time ranges
tre_wav       = tra_wav




nz            = 21L
zmax_arr      = 1d1^(DINDGEN(nz)*20d0/(nz - 1) - 10d0)
;; => Determine EFI wavelet ranges
FOR j=0L, ntr - 1L DO BEGIN                                            $
  FOR k=0L, 2L DO BEGIN                                                $
    get_data,efi_wvlt_names[j,k],DATA=tempw                          & $
    testx = [MEAN(tempw.Y,/NAN),MAX(tempw.Y,/NAN)]                   & $
    IF (k EQ 0) THEN zra_0 = testx                                   & $
    zra_0[0] = zra_0[0] < testx[0]                                   & $
    zra_0[1] = zra_0[1] > testx[1]                                   & $
  ENDFOR                                                             & $
  gmin  = (WHERE(zmax_arr GE zra_0[0]))[0] - 1L                      & $
  gmax  = (WHERE(zmax_arr GE zra_0[1]))[0] - 1L                      & $
  options,REFORM(efi_wvlt_names[j,*]),'ZRANGE'                       & $
  options,REFORM(efi_wvlt_names[j,*]),'ZRANGE',[zmax_arr[gmin],zmax_arr[gmax]],/DEF
;; clean up
DELVAR,tempe,tempw,testx,tests

;; => Determine SCM wavelet ranges
FOR j=0L, ntr - 1L DO BEGIN                                            $
  FOR k=0L, 2L DO BEGIN                                                $
    get_data,scm_wvlt_names[j,k],DATA=tempw                          & $
    testx = [MEAN(tempw.Y,/NAN),MAX(tempw.Y,/NAN)]                   & $
    IF (k EQ 0) THEN zra_0 = testx                                   & $
    zra_0[0] = zra_0[0] < testx[0]                                   & $
    zra_0[1] = zra_0[1] > testx[1]                                   & $
  ENDFOR                                                             & $
  gmin  = (WHERE(zmax_arr GE zra_0[0]))[0] - 1L                      & $
  gmax  = (WHERE(zmax_arr GE zra_0[1]))[0] - 1L                      & $
  options,REFORM(scm_wvlt_names[j,*]),'ZRANGE'                       & $
  options,REFORM(scm_wvlt_names[j,*]),'ZRANGE',[zmax_arr[gmin],zmax_arr[gmax]],/DEF
;; clean up
DELVAR,tempe,tempw,testx,tests




;; => Define file name prefixes
s_fsuff       = 'wavelet_n1-2-fce_'  ;; use (n+1/2)fce
f_pref        = 'EFI_GSE-'+vec_su+'_TH-'+scu[0]+'_efw-cor-DownSampled_'+s_fsuff[0]
opname        = op_n12_fce[0]

FOR j=0L, ntr - 1L DO BEGIN                                            $
  tra    = REFORM(tre_wav[j,*])                                      & $
  fnm    = file_name_times(tra,PREC=3)                               & $
  ftimes = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)               & $
  FOR k=0L, 2L DO BEGIN                                                $
    aname  = [efi_gse__names[j,k],efi_wvlt_names[j,k]]               & $
;    opname = [efi_conf_names[j,k],op_n12_fce[0]]                     & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[j]                          & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra      & $
    popen,fname[0],/LAND                                             & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra      & $
    pclose



;; => Define file name prefixes
s_fsuff       = 'wavelet_n1-2-fce_'
f_pref        = 'SCM_GSE-'+vec_su+'_TH-'+scu[0]+'_scw-HighPass_'+s_fsuff[0]
opname        = op_n12_fce[0]

FOR j=0L, ntr - 1L DO BEGIN                                            $
  tra    = REFORM(tre_wav[j,*])                                      & $
  fnm    = file_name_times(tra,PREC=3)                               & $
  ftimes = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)               & $
  FOR k=0L, 2L DO BEGIN                                                $
    aname  = [scm_gse__names[j,k],scm_wvlt_names[j,k]]               & $
;    opname = [scm_conf_names[j,k],op_n12_fce[0]]                     & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[j]                          & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra      & $
    popen,fname[0],/LAND                                             & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra      & $
    pclose



;;----------------------------------------------------------------------------------------
;; => Zoom-in on Wavelet Plots
;;----------------------------------------------------------------------------------------

;;--------------------------------------------------
;; Interval 0
;;--------------------------------------------------
jj               = 0L
temp0            = tdate[0]+'/'+['08:59:43.488','08:59:43.789']
temp1            = tdate[0]+'/'+['08:59:43.982','08:59:44.460']
temp2            = tdate[0]+'/'+['08:59:44.580','08:59:44.769']
temp3            = tdate[0]+'/'+['08:59:44.761','08:59:44.894']
temp4            = tdate[0]+'/'+['08:59:44.911','08:59:45.057']
temp5            = tdate[0]+'/'+['08:59:45.246','08:59:45.414']
temp6            = tdate[0]+'/'+['08:59:45.496','08:59:45.616']
temp7            = tdate[0]+'/'+['08:59:45.616','08:59:45.909']
temp8            = tdate[0]+'/'+['08:59:45.943','08:59:46.235']
temp9            = tdate[0]+'/'+['08:59:46.240','08:59:46.566']
temp10           = tdate[0]+'/'+['08:59:46.661','08:59:47.087']
temp11           = tdate[0]+'/'+['08:59:47.087','08:59:47.332']
temp12           = tdate[0]+'/'+['08:59:47.383','08:59:47.590']
temp13           = tdate[0]+'/'+['08:59:47.740','08:59:48.020']
temp14           = tdate[0]+'/'+['08:59:48.015','08:59:48.243']
temp15           = tdate[0]+'/'+['08:59:48.299','08:59:48.544']
temp16           = tdate[0]+'/'+['08:59:48.652','08:59:48.940']
temp17           = tdate[0]+'/'+['08:59:48.948','08:59:49.232']
temp_a           = TRANSPOSE([[temp0],[temp1],[temp2],[temp3],[temp4],[temp5],[temp6],[temp7],[temp8],[temp9],$
                    [temp10],[temp11],[temp12],[temp13],[temp14],[temp15],[temp16],[temp17]])

;; => EFI Plots
s_fsuff          = 'wavelet_n1-2-fce_'  ;; use (n+1/2)fce
f_pref           = 'EFI_GSE-'+vec_su+'_TH-'+scu[0]+'_efw-cor-DownSampled_'+s_fsuff[0]
opname           = op_n12_fce[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  FOR k=0L, 2L DO BEGIN                                                        $
    aname       = [efi_gse__names[jj,k],efi_wvlt_names[jj,k]]                & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[jj]                                 & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    popen,fname[0],/LAND                                                     & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    pclose

;; => SCM Plots
s_fsuff       = 'wavelet_n1-2-fce_'
f_pref        = 'SCM_GSE-'+vec_su+'_TH-'+scu[0]+'_scw-HighPass_'+s_fsuff[0]
opname        = op_n12_fce[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  FOR k=0L, 2L DO BEGIN                                                        $
    aname       = [scm_gse__names[jj,k],scm_wvlt_names[jj,k]]                & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[jj]                                 & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    popen,fname[0],/LAND                                                     & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    pclose

;; => EFI, SCM, and Poynting Flux Plots
s_fsuff = 'PoyntingFlux_'
f_pref  = 'FGM-fgh-GSE_TH-'+scu[0]+'_efw-cor-DownSampled_scw-HighPass_'+s_fsuff[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  aname       = [efds_names[jj],bfhp_names[jj],poyn_names[jj]]               & $
  fname       = f_pref[0]+ftimes[0]+iwavsfx[jj]                              & $
    tplot,aname,TRANGE=tra,/NOM                                              & $
  popen,fname[0],/PORT                                                       & $
    tplot,aname,TRANGE=tra,/NOM                                              & $
  pclose


;;--------------------------------------------------
;; Interval 1
;;--------------------------------------------------
jj               = 1L
temp0            = tdate[0]+'/'+['08:59:49.326','08:59:50.241']
temp1            = tdate[0]+'/'+['08:59:50.301','08:59:50.605']
temp2            = tdate[0]+'/'+['08:59:50.635','08:59:50.905']
temp3            = tdate[0]+'/'+['08:59:51.080','08:59:51.392']
temp4            = tdate[0]+'/'+['08:59:51.422','08:59:51.504']
temp5            = tdate[0]+'/'+['08:59:51.555','08:59:51.630']
temp6            = tdate[0]+'/'+['08:59:51.683','08:59:51.876']
temp7            = tdate[0]+'/'+['08:59:51.987','08:59:52.252']
temp8            = tdate[0]+'/'+['08:59:52.496','08:59:52.595']
temp9            = tdate[0]+'/'+['08:59:52.864','08:59:52.945']
temp10           = tdate[0]+'/'+['08:59:53.574','08:59:53.771']
temp11           = tdate[0]+'/'+['08:59:54.370','08:59:54.570']
temp12           = tdate[0]+'/'+['08:59:54.875','08:59:55.055']
temp13           = tdate[0]+'/'+['08:59:55.393','08:59:55.701']
temp14           = tdate[0]+'/'+['08:59:52.830','08:59:52.966']
temp15           = tdate[0]+'/'+['08:59:52.870','08:59:52.940']
temp16           = tdate[0]+'/'+['08:59:52.890','08:59:52.930']
temp_a           = TRANSPOSE([[temp0],[temp1],[temp2],[temp3],[temp4],[temp5],[temp6],[temp7],[temp8],[temp9],$
                    [temp10],[temp11],[temp12],[temp13],[temp14],[temp15],[temp16]])

;; => EFI Plots
s_fsuff          = 'wavelet_n1-2-fce_'  ;; use (n+1/2)fce
f_pref           = 'EFI_GSE-'+vec_su+'_TH-'+scu[0]+'_efw-cor-DownSampled_'+s_fsuff[0]
opname           = op_n12_fce[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  FOR k=0L, 2L DO BEGIN                                                        $
    aname       = [efi_gse__names[jj,k],efi_wvlt_names[jj,k]]                & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[jj]                                 & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    popen,fname[0],/LAND                                                     & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    pclose

s_fsuff          = 'wavelet_n-fce_'  ;; use nfce
f_pref           = 'EFI_GSE-'+vec_su+'_TH-'+scu[0]+'_efw-cor-DownSampled_'+s_fsuff[0]
opname           = op_nfce[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  FOR k=0L, 2L DO BEGIN                                                        $
    aname       = [efi_gse__names[jj,k],efi_wvlt_names[jj,k]]                & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[jj]                                 & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    popen,fname[0],/LAND                                                     & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    pclose

;; => SCM Plots
s_fsuff          = 'wavelet_n1-2-fce_'
f_pref           = 'SCM_GSE-'+vec_su+'_TH-'+scu[0]+'_scw-HighPass_'+s_fsuff[0]
opname           = op_n12_fce[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  FOR k=0L, 2L DO BEGIN                                                        $
    aname       = [scm_gse__names[jj,k],scm_wvlt_names[jj,k]]                & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[jj]                                 & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    popen,fname[0],/LAND                                                     & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    pclose

s_fsuff          = 'wavelet_n-fce_'
f_pref           = 'SCM_GSE-'+vec_su+'_TH-'+scu[0]+'_scw-HighPass_'+s_fsuff[0]
opname           = op_nfce[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  FOR k=0L, 2L DO BEGIN                                                        $
    aname       = [scm_gse__names[jj,k],scm_wvlt_names[jj,k]]                & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[jj]                                 & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    popen,fname[0],/LAND                                                     & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    pclose

;; => EFI, SCM, and Poynting Flux Plots
s_fsuff          = 'PoyntingFlux_'
f_pref           = 'FGM-fgh-GSE_TH-'+scu[0]+'_efw-cor-DownSampled_scw-HighPass_'+s_fsuff[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  aname       = [efds_names[jj],bfhp_names[jj],poyn_names[jj]]               & $
  fname       = f_pref[0]+ftimes[0]+iwavsfx[jj]                              & $
    tplot,aname,TRANGE=tra,/NOM                                              & $
  popen,fname[0],/PORT                                                       & $
    tplot,aname,TRANGE=tra,/NOM                                              & $
  pclose



;;----------------------------------------------------------------------------------------
;; => Zoom-in and plot hodograms
;;----------------------------------------------------------------------------------------
magenta          = get_color_by_name('Magenta')
fgreen           = get_color_by_name('Forest Green')
orange           = get_color_by_name('Orange')
sunsym           = get_font_symbol('sun')
;; Define shock normal vector
gnorm            = [0.99012543d0,0.086580460d0,-0.0038282813d0]
;; renormalize
gnorm           /= SQRT(TOTAL(gnorm^2,/NAN))
;; Define shock normal string
gnorm_str        = 'n = '+format_vector_string(gnorm,PREC=4)+' [GSE]'
;; Define sun vector
sunv             = [1d0,0d0,0d0]
mag_name         = fgmnm[1]
get_data,mag_name[0],DATA=temp_bo,DLIM=dlim_bo,LIM=lim_bo
tmagf            = temp_bo.Y
tmagt            = temp_bo.X

chsz             = 1.25
multip           = '1 3'
xsize            = 500
ysize            = 1100
hscale           = 1d0
xposi            = hscale[0]*0.95 - 0.10
yposi            = hscale[0]*[0.99,0.90,0.81] - 0.10
zeros            = TRANSPOSE([0d0,0d0])
WINDOW,1,RETAIN=2,XSIZE=xsize,YSIZE=ysize
;; scale n to plot range
nvecxy           = TRANSPOSE(gnorm[[0,1]]*hscale[0]/SQRT(gnorm[0]^2 + gnorm[1]^2))
nvecxz           = TRANSPOSE(gnorm[[0,2]]*hscale[0]/SQRT(gnorm[0]^2 + gnorm[2]^2))
nvecyz           = TRANSPOSE(gnorm[[1,2]]*hscale[0]/SQRT(gnorm[1]^2 + gnorm[2]^2))
;; scale Xgse to plot range [50% shorter to avoid covering normal vector]
xvecxy           = TRANSPOSE(sunv[[0,1]]*hscale[0]/SQRT(sunv[0]^2 + sunv[1]^2))*5d-1
xvecxz           = TRANSPOSE(sunv[[0,2]]*hscale[0]/SQRT(sunv[0]^2 + sunv[2]^2))*5d-1
xvecyz           = TRANSPOSE(sunv[[1,2]]*hscale[0]/SQRT(sunv[1]^2 + sunv[2]^2))*5d-1
IF (TOTAL(FINITE(xvecyz)) EQ 0) THEN sun_sym = sunsym ELSE sun_sym = ''

;ath              = 1.75
ath              = 2.50
vec_shodo        = ['YvsX','ZvsX','ZvsY']
s_fsuff          = 'hodograms_'
f_pref           = 'EFI_GSE_TH-'+scu[0]+'_efw-cor-DownSampled_'+s_fsuff[0]
ex_bv            = {OVERPLOT:1,HSIZE:1.5,UARROWSIDE:'none',COLOR:magenta,THICK:ath,HTHICK:ath}
ex_nv            = {OVERPLOT:1,HSIZE:1.5,UARROWSIDE:'none',COLOR:fgreen,THICK:ath,HTHICK:ath}
ex_sv            = {OVERPLOT:1,HSIZE:1.5,UARROWSIDE:'none',COLOR:orange,THICK:ath,HTHICK:ath}

;;--------------------------------------------------
;; Interval 0
;;--------------------------------------------------
jj               = 0L
temp0            = tdate[0]+'/'+['08:59:43.488','08:59:43.789']
temp1            = tdate[0]+'/'+['08:59:43.982','08:59:44.460']
temp2            = tdate[0]+'/'+['08:59:44.580','08:59:44.769']
temp3            = tdate[0]+'/'+['08:59:44.761','08:59:44.894']
temp4            = tdate[0]+'/'+['08:59:44.911','08:59:45.057']
temp5            = tdate[0]+'/'+['08:59:45.246','08:59:45.414']
temp6            = tdate[0]+'/'+['08:59:45.496','08:59:45.616']
temp7            = tdate[0]+'/'+['08:59:45.616','08:59:45.909']
temp8            = tdate[0]+'/'+['08:59:45.943','08:59:46.235']
temp9            = tdate[0]+'/'+['08:59:46.240','08:59:46.566']
temp10           = tdate[0]+'/'+['08:59:46.661','08:59:47.087']
temp11           = tdate[0]+'/'+['08:59:47.087','08:59:47.332']
temp12           = tdate[0]+'/'+['08:59:47.383','08:59:47.590']
temp13           = tdate[0]+'/'+['08:59:47.740','08:59:48.020']
temp14           = tdate[0]+'/'+['08:59:48.015','08:59:48.243']
temp15           = tdate[0]+'/'+['08:59:48.299','08:59:48.544']
temp16           = tdate[0]+'/'+['08:59:48.652','08:59:48.940']
temp17           = tdate[0]+'/'+['08:59:48.948','08:59:49.232']
temp_a           = TRANSPOSE([[temp0],[temp1],[temp2],[temp3],[temp4],[temp5],[temp6],[temp7],[temp8],[temp9],$
                    [temp10],[temp11],[temp12],[temp13],[temp14],[temp15],[temp16],[temp17]])
;;--------------------------------------------------
;; Interval 1
;;--------------------------------------------------
jj               = 1L
temp0            = tdate[0]+'/'+['08:59:49.326','08:59:50.241']
temp1            = tdate[0]+'/'+['08:59:50.301','08:59:50.605']
temp2            = tdate[0]+'/'+['08:59:50.635','08:59:50.905']
temp3            = tdate[0]+'/'+['08:59:51.080','08:59:51.392']
temp4            = tdate[0]+'/'+['08:59:51.422','08:59:51.504']
temp5            = tdate[0]+'/'+['08:59:51.555','08:59:51.630']
temp6            = tdate[0]+'/'+['08:59:51.683','08:59:51.876']
temp7            = tdate[0]+'/'+['08:59:51.987','08:59:52.252']
temp8            = tdate[0]+'/'+['08:59:52.496','08:59:52.595']
temp9            = tdate[0]+'/'+['08:59:52.864','08:59:52.945']
temp10           = tdate[0]+'/'+['08:59:53.574','08:59:53.771']
temp11           = tdate[0]+'/'+['08:59:54.370','08:59:54.570']
temp12           = tdate[0]+'/'+['08:59:54.875','08:59:55.055']
temp13           = tdate[0]+'/'+['08:59:55.393','08:59:55.701']
temp14           = tdate[0]+'/'+['08:59:52.830','08:59:52.966']
temp15           = tdate[0]+'/'+['08:59:52.870','08:59:52.940']
temp16           = tdate[0]+'/'+['08:59:52.890','08:59:52.930']
temp_a           = TRANSPOSE([[temp0],[temp1],[temp2],[temp3],[temp4],[temp5],[temp6],[temp7],[temp8],[temp9],$
                    [temp10],[temp11],[temp12],[temp13],[temp14],[temp15],[temp16]])



xyz_name         = efds_names[jj]
get_data,xyz_name[0],DATA=temp_f,DLIM=dlim0,LIM=lim0

ttle             = dlim0.YTITLE  ;; Plot title
xyzmax           = MAX(ABS(temp_f.Y),/NAN)*1.05d0
xyran            = [-1d0,1d0]*xyzmax[0]

;; Define all XY-Ranges and Avg. B-field vectors
d                = !VALUES.D_NAN
n_tr             = N_ELEMENTS(temp_a[*,0])
xy_ran           = REPLICATE(!VALUES.D_NAN,n_tr,2L)
avg_bf           = REPLICATE(!VALUES.D_NAN,n_tr,3L)
FOR i=0L, n_tr - 1L DO BEGIN                                                   $
  xymx        = 0d0                                                          & $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  good_bo     = WHERE(temp_f.X GE tra[0] AND temp_f.X LE tra[1],gdbo)        & $
  IF (gdbo GT 0) THEN xymx = MAX(ABS(temp_f.Y[good_bo,*]),/NAN)*1.05d0       & $
  IF (xymx EQ 0) THEN xymx = xyzmax[0]                                       & $
  xy_ran[i,*] = [-1d0,1d0]*xymx[0]                                           & $
  good_bo     = WHERE(tmagt GE tra[0] AND tmagt LE tra[1],gdbo)              & $
  IF (gdbo GT 0) THEN abx = MEAN(tmagf[good_bo,0],/NAN) ELSE abx = d         & $
  IF (gdbo GT 0) THEN aby = MEAN(tmagf[good_bo,1],/NAN) ELSE aby = d         & $
  IF (gdbo GT 0) THEN abz = MEAN(tmagf[good_bo,2],/NAN) ELSE abz = d         & $
  avg_bf[i,*] = [abx[0],aby[0],abz[0]]

;; Define all Avg. B-field strings
avg_bf_str       = REPLICATE('',n_tr)
FOR i=0L, n_tr - 1L DO BEGIN                                                   $
  bvec        = REFORM(avg_bf[i,*])                                          & $
  bv_str      = format_vector_string(bvec,PREC=3)+' [nT, GSE]'               & $
  avg_bf_str[i] = 'Bo = '+bv_str[0]

;; Define all Avg. B-field magnitudes
avg_bm           = SQRT(TOTAL(avg_bf^2,2,/NAN)) # REPLICATE(1d0,3L)
;; normalize vectors
avg_bv           = avg_bf/avg_bm
;; Define all Avg. projection B-field magnitudes
avg_bxy          = SQRT(TOTAL(avg_bv[*,[0,1]]^2,2,/NAN)) # REPLICATE(1d0,2L)
avg_bxz          = SQRT(TOTAL(avg_bv[*,[0,2]]^2,2,/NAN)) # REPLICATE(1d0,2L)
avg_byz          = SQRT(TOTAL(avg_bv[*,[1,2]]^2,2,/NAN)) # REPLICATE(1d0,2L)
;; scale b to plot range
avg_b_vxy        = avg_bv[*,[0,1]]*hscale[0]/avg_bxy
avg_b_vxz        = avg_bv[*,[0,2]]*hscale[0]/avg_bxz
avg_b_vyz        = avg_bv[*,[1,2]]*hscale[0]/avg_byz


old_chsz         = !P.CHARSIZE
!P.CHARSIZE      = 0.75
FOR i=0L, n_tr - 1L DO BEGIN                                                   $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  xyra        = REFORM(xy_ran[i,*])                                          & $
  n_scl       = xyra[1]/hscale[0]*0.95                                       & $
  nxpos       = (xposi[0]-0.20)*n_scl[0]                                     & $
  nxpo2       = (xposi[0]+0.30)*n_scl[0]                                     & $
  nypos       = yposi*n_scl[0]                                               & $
  d_tr        = tra[1] - tra[0]                                              & $
  timespan,tra[0],d_tr[0],/SECONDS                                           & $
  tra_str     = time_string(tra,PREC=3)                                      & $
  tra_ttl     = tra_str[0]+'-'+STRMID(tra_str[1],11L)                        & $
  mttle       = 'EFW-GSE '+tra_ttl[0]                                        & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  fname       = f_pref[0]+ftimes[0]+iwavsfx[jj]                              & $
  xy_bo       = {DATA:1,COLOR:magenta,CHARSIZE:0.60,ORIENTATION:-90.}        & $
  xy_no       = {DATA:1,COLOR:fgreen ,CHARSIZE:0.60,ORIENTATION:-90.}        & $
  ex_xy       = {VERSUS:'xy',XRANGE:xyra,YRANGE:xyra,MULTI:multip,COLOR:250} & $
  ex_xz       = {VERSUS:'xz',XRANGE:xyra,YRANGE:xyra,ADDPANEL:1,COLOR:150}   & $
  ex_yz       = {VERSUS:'yz',XRANGE:xyra,YRANGE:xyra,ADDPANEL:1,COLOR: 50}   & $
  popen,fname[0],/PORT                                                       & $
    tplotxy,xyz_name[0],_EXTRA=ex_xy,MTITLE=mttle[0]                         & $
      plotxyvec,zeros,avg_b_vxy[i,*]*n_scl[0],_EXTRA=ex_bv                   & $
      plotxyvec,zeros,nvecxy*n_scl[0],_EXTRA=ex_nv                           & $
      plotxyvec,zeros,xvecxy*n_scl[0],_EXTRA=ex_sv                           & $
      XYOUTS,nxpo2[0],nypos[0],avg_bf_str[i],_EXTRA=xy_bo                    & $
      XYOUTS,nxpos[0],nypos[2],'Xgse',/DATA,COLOR=orange,CHARSIZE=chsz       & $
    tplotxy,xyz_name[0],_EXTRA=ex_xz,TITLE=''                                & $
      plotxyvec,zeros,avg_b_vxz[i,*]*n_scl[0],_EXTRA=ex_bv                   & $
      plotxyvec,zeros,nvecxz*n_scl[0],_EXTRA=ex_nv                           & $
      plotxyvec,zeros,xvecxz*n_scl[0],_EXTRA=ex_sv                           & $
      XYOUTS,nxpo2[0],nypos[1],gnorm_str[0],_EXTRA=xy_no                     & $
    tplotxy,xyz_name[0],_EXTRA=ex_yz,TITLE=''                                & $
      plotxyvec,zeros,avg_b_vyz[i,*]*n_scl[0],_EXTRA=ex_bv                   & $
      plotxyvec,zeros,nvecyz*n_scl[0],_EXTRA=ex_nv                           & $
      XYOUTS,nxpos[0],nypos[2],sun_sym,/DATA,COLOR=orange,CHARSIZE=1.50      & $
  pclose
!P.CHARSIZE      = old_chsz
























;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
; => Old
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
ath              = 2.5
ex_bv            = {OVERPLOT:1,HSIZE:1.5,UARROWSIDE:'none',COLOR:magenta,THICK:ath,HTHICK:ath}
ex_nv            = {OVERPLOT:1,HSIZE:1.5,UARROWSIDE:'none',COLOR:fgreen,THICK:ath,HTHICK:ath}
ex_sv            = {OVERPLOT:1,HSIZE:1.5,UARROWSIDE:'none',COLOR:orange,THICK:ath,HTHICK:ath}
tra         = time_double(REFORM(temp_a[i,*]))
xyra        = REFORM(xy_ran[i,*])
n_scl       = xyra[1]/hscale[0]*0.95
nxpos       = xposi[0]*n_scl[0]
nypos       = yposi*n_scl[0]
d_tr        = tra[1] - tra[0]
timespan,tra[0],d_tr[0],/SECONDS
tra_str     = time_string(tra,PREC=3)
tra_ttl     = tra_str[0]+'-'+STRMID(tra_str[1],11L)
mttle       = 'EFW-GSE '+tra_ttl[0]
fnm         = file_name_times(tra,PREC=3)
ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)
fname       = f_pref[0]+ftimes[0]+iwavsfx[jj]
ex_xy       = {VERSUS:'xy',XRANGE:xyra,YRANGE:xyra,MULTI:multip,COLOR:250}
ex_xz       = {VERSUS:'xz',XRANGE:xyra,YRANGE:xyra,ADDPANEL:1,COLOR:150}
ex_yz       = {VERSUS:'yz',XRANGE:xyra,YRANGE:xyra,ADDPANEL:1,COLOR: 50}
  tplotxy,xyz_name[0],_EXTRA=ex_xy,MTITLE=mttle[0]
    plotxyvec,zeros,avg_b_vxy[i,*]*n_scl[0],_EXTRA=ex_bv
    plotxyvec,zeros,nvecxy*n_scl[0],_EXTRA=ex_nv
    plotxyvec,zeros,xvecxy*n_scl[0],_EXTRA=ex_sv
    XYOUTS,nxpos[0],nypos[0],'B',/DATA,COLOR=magenta,  CHARSIZE=chsz
    XYOUTS,nxpos[0],nypos[1],'n',/DATA,COLOR=fgreen,   CHARSIZE=chsz
    XYOUTS,nxpos[0],nypos[2],'Xgse',/DATA,COLOR=orange,CHARSIZE=chsz
  tplotxy,xyz_name[0],_EXTRA=ex_xz,TITLE=''
    plotxyvec,zeros,avg_b_vxz[i,*]*n_scl[0],_EXTRA=ex_bv
    plotxyvec,zeros,nvecxz*n_scl[0],_EXTRA=ex_nv
    plotxyvec,zeros,xvecxz*n_scl[0],_EXTRA=ex_sv
  tplotxy,xyz_name[0],_EXTRA=ex_yz,TITLE=''
    plotxyvec,zeros,avg_b_vyz[i,*]*n_scl[0],_EXTRA=ex_bv
    plotxyvec,zeros,nvecyz*n_scl[0],_EXTRA=ex_nv
    XYOUTS,nxpos[0]*.90,nypos[2],sun_sym,/DATA,COLOR=orange,CHARSIZE=chsz


i                = 0L
;; Define time range
tra              = time_double(REFORM(temp_a[i,*]))
d_tr             = tra[1] - tra[0]
timespan,tra[0],d_tr[0],/SECONDS
;; Define plot title with time range
tra_str          = time_string(tra,PREC=3)
tra_ttl          = tra_str[0]+'-'+STRMID(tra_str[1],11L)
mttle            = 'EFW-GSE '+tra_ttl[0]

;; Determine Avg. Bo vector
good_bo          = WHERE(tmagt GE tra[0] AND tmagt LE tra[1],gdbo)
IF (gdbo GT 0) THEN avgbx = MEAN(tmagf[good_bo,0],/NAN) ELSE avgbx = !VALUES.D_NAN
IF (gdbo GT 0) THEN avgby = MEAN(tmagf[good_bo,1],/NAN) ELSE avgby = !VALUES.D_NAN
IF (gdbo GT 0) THEN avgbz = MEAN(tmagf[good_bo,2],/NAN) ELSE avgbz = !VALUES.D_NAN
avg_bmag         = SQRT(avgbx[0]^2 + avgby[0]^2 + avgbz[0]^2)
IF (FINITE(avg_bmag) EQ 0) THEN avg_bmag = 1d0
;; normalize vector
bvecxyz          = [avgbx[0],avgby[0],avgbz[0]]/avg_bmag[0]
;; scale b to plot range
bvecxy           = bvecxyz[[0,1]]*hscale[0]/SQRT(bvecxyz[0]^2 + bvecxyz[1]^2)
bvecxz           = bvecxyz[[0,2]]*hscale[0]/SQRT(bvecxyz[0]^2 + bvecxyz[2]^2)
bvecyz           = bvecxyz[[1,2]]*hscale[0]/SQRT(bvecxyz[1]^2 + bvecxyz[2]^2)



tplotxy,xyz_name[0],VERSUS='xy',XRANGE=xyran,YRANGE=xyran,MULTI=multip,COLOR=250,MTITLE=mttle[0]
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(bvecxy),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=magenta
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(nvecxy),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=fgreen
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(xvecxy),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=orange
  XYOUTS,xposi[0],yposi[0],'B',/DATA,COLOR=magenta,  CHARSIZE=chsz
  XYOUTS,xposi[0],yposi[1],'n',/DATA,COLOR=fgreen,   CHARSIZE=chsz
  XYOUTS,xposi[0],yposi[2],'Xgse',/DATA,COLOR=orange,CHARSIZE=chsz
tplotxy,xyz_name[0],VERSUS='xz',XRANGE=xyran,YRANGE=xyran,/ADDPANEL,COLOR=150
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(bvecxz),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=magenta
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(nvecxz),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=fgreen
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(xvecxz),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=orange
tplotxy,xyz_name[0],VERSUS='yz',XRANGE=xyran,YRANGE=xyran,/ADDPANEL,COLOR= 50
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(bvecyz),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=magenta
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(nvecyz),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=fgreen
  IF (TOTAL(FINITE(xvecyz)) NE 0) THEN plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(xvecyz),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=orange
  IF (TOTAL(FINITE(xvecyz)) EQ 0) THEN XYOUTS,xposi[0]*.90,yposi[2],sun_sym,/DATA,COLOR=orange,CHARSIZE=chsz


;-----------------------------------------------------------------------------------------
; => Save Plots
;-----------------------------------------------------------------------------------------
sc      = probe[0]
scu     = STRUPCASE(sc[0])
pref    = 'th'+sc[0]+'_'
coord   = 'gse'
fgmnm   = pref[0]+'fgh_'+['mag',coord[0]]


stpref  = 'S__TimeSeries_'
sppref  = 'S__PowerSpectra_'
efwpre  = 'efw_cal_'
scwpre  = 'scw_cal_'
ffname  = ['efw','scw']
tfname  = ['corrected','HighPass']

s_fsuff = 'PoyntingFlux_'
fepref  = 'FGM-fgh-GSE_TH-'+scu[0]+'_'+ffname[0]+'_'+s_fsuff[0]
fbpref  = 'FGM-fgh-GSE_TH-'+scu[0]+'_'+ffname[1]+'_'+s_fsuff[0]

;;  Poynting flux TPLOT handles
st_nm   = tnames(pref[0]+stpref[0]+coord[0]+'*')
sp_nm   = tnames(pref[0]+sppref[0]+coord[0]+'*')
n_st    = N_ELEMENTS(st_nm)
f_suffx = '_INT'+STRING(LINDGEN(n_st),FORMAT='(I3.3)')

;;  EFI TPLOT handles
efinm   = tnames(pref[0]+efwpre[0]+coord[0]+'_'+tfname[0]+'*')

;;  SCM TPLOT handles
scmnm   = tnames(pref[0]+scwpre[0]+coord[0]+'_'+tfname[1]+'*')

;;  Save EFI Plots
FOR j=0L, nefi - 1L DO BEGIN                                         $
  aname  = [fgmnm,efinm,st_nm[j],sp_nm[j]]                         & $
  tra    = REFORM(tr_all_efi[j,*])                                 & $
  fnm    = file_name_times(tra,PREC=3)                             & $
  ftimes = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)             & $
  fname  = fepref[0]+ftimes[0]+f_suffx[j]                          & $
  tplot,aname,TRANGE=tra,/NOM                                      & $
  popen,fname[0],/PORT                                             & $
    tplot,aname,TRANGE=tra,/NOM                                    & $
  pclose



;;  Save SCM Plots
FOR j=0L, nscm - 1L DO BEGIN                                         $
  aname  = [fgmnm,scmnm,st_nm[j],sp_nm[j]]                         & $
  tra    = REFORM(tr_all_scm[j,*])                                 & $
  fnm    = file_name_times(tra,PREC=3)                             & $
  ftimes = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)             & $
  fname  = fbpref[0]+ftimes[0]+f_suffx[j]                          & $
  tplot,aname,TRANGE=tra,/NOM                                      & $
  popen,fname[0],/PORT                                             & $
    tplot,aname,TRANGE=tra,/NOM                                    & $
  pclose

;-----------------------------------------------------------------------------------------
; => Plot specific zoomed in views
;-----------------------------------------------------------------------------------------
st_nm   = tnames(pref[0]+stpref[0]+coord[0]+'*')
efinm   = tnames(pref[0]+efwpre[0]+coord[0]+'*')
scmnm   = tnames(pref[0]+scwpre[0]+coord[0]+'*')

n_st    = N_ELEMENTS(st_nm)
f_suffx = '_INT'+STRING(LINDGEN(n_st),FORMAT='(I3.3)')

s_fsuff = 'PoyntingFlux_'
fapref  = 'FGM-fgh-GSE_TH-'+scu[0]+'_efw-scw_'+s_fsuff[0]


;; Int 0
temp0            = tdate[0]+'/'+['08:59:43.488','08:59:43.789']
temp1            = tdate[0]+'/'+['08:59:43.982','08:59:44.460']
temp2            = tdate[0]+'/'+['08:59:44.580','08:59:44.769']
temp3            = tdate[0]+'/'+['08:59:44.761','08:59:44.894']
temp4            = tdate[0]+'/'+['08:59:44.911','08:59:45.057']
temp5            = tdate[0]+'/'+['08:59:45.246','08:59:45.414']
temp6            = tdate[0]+'/'+['08:59:45.496','08:59:45.616']
temp7            = tdate[0]+'/'+['08:59:45.616','08:59:45.909']
temp8            = tdate[0]+'/'+['08:59:45.943','08:59:46.235']
temp9            = tdate[0]+'/'+['08:59:46.240','08:59:46.566']
temp10           = tdate[0]+'/'+['08:59:46.661','08:59:47.087']
temp11           = tdate[0]+'/'+['08:59:47.087','08:59:47.332']
temp12           = tdate[0]+'/'+['08:59:47.383','08:59:47.590']
temp13           = tdate[0]+'/'+['08:59:47.740','08:59:48.020']
temp14           = tdate[0]+'/'+['08:59:48.015','08:59:48.243']
temp15           = tdate[0]+'/'+['08:59:48.299','08:59:48.544']
temp16           = tdate[0]+'/'+['08:59:48.652','08:59:48.940']
temp17           = tdate[0]+'/'+['08:59:48.948','08:59:49.232']
temp_a           = TRANSPOSE([[temp0],[temp1],[temp2],[temp3],[temp4],[temp5],[temp6],[temp7],[temp8],[temp9],$
                    [temp10],[temp11],[temp12],[temp13],[temp14],[temp15],[temp16],[temp17]])
jj               = 0L
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  anames      = [fgmnm,efinm,scmnm,st_nm[jj]]                                & $
  fname_a     = fapref[0]+ftimes[0]+f_suffx[jj]                              & $
  tplot,anames,TRANGE=tra,/NOM                                               & $
  popen,fname_a[0],/PORT                                                     & $
    tplot,anames,TRANGE=tra,/NOM                                             & $
  pclose




;; Int 1
temp0            = tdate[0]+'/'+['08:59:49.326','08:59:50.241']
temp1            = tdate[0]+'/'+['08:59:50.301','08:59:50.605']
temp2            = tdate[0]+'/'+['08:59:50.635','08:59:50.905']
temp3            = tdate[0]+'/'+['08:59:51.080','08:59:51.392']
temp4            = tdate[0]+'/'+['08:59:51.422','08:59:51.504']
temp5            = tdate[0]+'/'+['08:59:51.555','08:59:51.630']
temp6            = tdate[0]+'/'+['08:59:51.683','08:59:51.876']
temp7            = tdate[0]+'/'+['08:59:51.987','08:59:52.252']
temp8            = tdate[0]+'/'+['08:59:52.496','08:59:52.595']
temp9            = tdate[0]+'/'+['08:59:52.864','08:59:52.945']
temp10           = tdate[0]+'/'+['08:59:53.574','08:59:53.771']
temp11           = tdate[0]+'/'+['08:59:54.370','08:59:54.570']
temp12           = tdate[0]+'/'+['08:59:54.875','08:59:55.055']
temp13           = tdate[0]+'/'+['08:59:55.393','08:59:55.701']
temp_a           = TRANSPOSE([[temp0],[temp1],[temp2],[temp3],[temp4],[temp5],[temp6],[temp7],[temp8],[temp9],$
                    [temp10],[temp11],[temp12],[temp13]])
jj               = 1L
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  anames      = [fgmnm,efinm,scmnm,st_nm[jj]]                                & $
  fname_a     = fapref[0]+ftimes[0]+f_suffx[jj]                              & $
  tplot,anames,TRANGE=tra,/NOM                                               & $
  popen,fname_a[0],/PORT                                                     & $
    tplot,anames,TRANGE=tra,/NOM                                             & $
  pclose












;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
; => Extras
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
inpre       = 'thb_efw_cal_corrected_DownSampled_gse'
in_names    = inpre[0]+'_INT00'+['0','1']
out_name0   = inpre[0]+['x','y','z']+'_INT000'
out_name1   = inpre[0]+['x','y','z']+'_INT001'
out_names   = TRANSPOSE([[out_name0],[out_name1]])

themis_load_wavelets,in_names,out_names,COORD='gse',UNITS='mV/m',INSTRUMENT='efw',SPACECRAFT='THEMIS-B'



ltag        = ['LEVELS','C_ANNOTATION','YLOG','C_THICK']
lims        = CREATE_STRUCT(ltag,1.0,'95%',1,1.5)
enames      = out_name1
wnames      = enames+'_wavelet'
op_conf     = wnames+'_Conf_Level_95'
op_fce      = 'thb_fgh_fci_flh_fce'
vec_s       = ['x','y','z']
vec_su      = STRUPCASE(vec_s)

options,wnames+'*','yrange'
options,wnames+'*','yrange',[1d1,4096d0],/def
options,op_fce,'yrange'
options,op_fce,'yrange',[1d1,4096d0],/def
options,op_fce,'ylog'
options,op_fce,'ylog',1,/def

;t_suff      = '2009-07-13_0859x50.651-0859x50.931'
t_suff      = '2009-07-13_0859x51.075-0859x51.233'
;t_suff      = '2009-07-13_0859x52.830-0859x52.966'
t_prefs     = 'efw_corrected_DownSampled_'+t_suff[0]

FOR k=0L, 2L DO BEGIN                                   $
  aname  = [enames[k],wnames[k]]                      & $
  opname = [op_conf[k],op_fce[0]]                     & $
  fname  = t_prefs[0]+'_'+vec_su[k]+'-GSE'            & $
    oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM    & $
  popen,fname[0],/LAND                                & $
    oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM    & $
  pclose





; => Load ESA Save Files
sc      = probe[0]
inames  = 'IESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
mdir    = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_esa_save/'+tdate[0]+'/')
ifiles  = FILE_SEARCH(mdir,inames[0])
RESTORE,ifiles[0]

;; => Redefine structures
dat_i     = peib_df_arr_b
i_time0   = dat_i.TIME
i_time1   = dat_i.END_TIME
;; Keep only structures between defined time range
;tr_jj     = tdate[0]+'/09:'+['18:34.000','20:10.000']
tr_jj     = tdate[0]+'/'+['08:50:00.000','09:20:10.000']
trtt      = time_double(tr_jj)
good_i    = WHERE(i_time0 GE trtt[0] AND i_time1 LE trtt[1],gdi)
PRINT,';', gdi
;          31




coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
magname   = pref[0]+'fgh_'+coord[0]   ;; 'fgh' GSE TPLOT handle
spperi    = pref[0]+'state_spinper'   ;; spacecraft spin period TPLOT handle
vel_name  = pref[0]+'peib_velocity_'+coord[0]
scname    = tnames(pref[0]+'peib_sc_pot')

dat_i     = peib_df_arr_b[good_i]
modify_themis_esa_struc,dat_i
dat_igse  = dat_i
rotate_esa_thetaphi_to_gse,dat_igse,MAGF_NAME=magname,VEL_NAME=vname_n

add_scpot,dat_igse,scname[0]
magn_1    = pref[0]+'fgs_dsl'
magn_2    = pref[0]+'fgh_dsl'
add_magf2,dat_igse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_igse,magn_2[0],/LEAVE_ALONE
add_vsw2,dat_i0,vel_name[0],/LEAVE_ALONE


dat_0   = dat_igse[j]
vec1    = dat_0.MAGF
vec2    = dat_0.VSW
WSET,2
WSHOW,2
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='xy',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]






dat_i0    = peib_df_arr_b[good_i]
modify_themis_esa_struc,dat_i0

coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
magname   = pref[0]+'fgh_'+coord[0]   ;; 'fgh' GSE TPLOT handle
spperi    = pref[0]+'state_spinper'   ;; spacecraft spin period TPLOT handle
vel_name  = pref[0]+'peib_velocity_'+coord[0]
scname    = tnames(pref[0]+'peib_sc_pot')

add_scpot,dat_i0,scname[0]
magn_1    = pref[0]+'fgs_gse'
magn_2    = pref[0]+'fgh_gse'
add_magf2,dat_i0,magn_1[0],/LEAVE_ALONE
add_magf2,dat_i0,magn_2[0],/LEAVE_ALONE
add_vsw2,dat_i0,vel_name[0],/LEAVE_ALONE


ngrid    = 30L
sunv     = [1.,0.,0.]
sunn     = 'Sun Dir.'
xname    = 'B!Do!N'
yname    = 'V!Dsw!N'
vlim     = 25e2
ns       = 7L
smc      = 1
smct     = 1
dfmax    = 1d-1
dfmin    = 1d-15
normnm   = 'Shock Normal[0]'
vcirc    = 5d2
dfra     = [1d-14,1d-8]
interpo  = 0

j        = 4L
dat_0    = dat_i0[j]
vec2     = dat_0[0].VSW
WSET,1
WSHOW,1
contour_esa_htr_1plane,dat_0,magname[0],vec2,spperi[0],VLIM=vlim[0],NGRID=ngrid[0],    $
                       XNAME=xname[0],YNAME=yname[0],SM_CUTS=smc[0],NSMOOTH=ns[0],     $
                       /ONE_C,VCIRC=vcirc,EX_VEC0=gnorm,EX_VN0=normnm[0],              $
                       EX_VEC1=sunv,EX_VN1=sunn[0],PLANE='xy',/NO_REDF,INTERP=interpo, $
                       SM_CONT=smct[0],DFRA=dfra,DFMIN=dfmin[0],DFMAX=dfmax[0],        $
                       MAGF_NAME=magname[0],VEL_NAME=vel_name[0]






