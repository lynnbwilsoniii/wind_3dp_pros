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
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;;  Electron mass [kg]
mp             = 1.6726217770d-27     ;;  Proton mass [kg]
ma             = 6.6446567500d-27     ;;  Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;;  Speed of light in vacuum [m/s]
epo            = 8.8541878170d-12     ;;  Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;;  Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;;  Fundamental charge [C]
kB             = 1.3806488000d-23     ;;  Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;;  Planck Constant [J s]
GG             = 6.6738400000d-11     ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [J]
;;  Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K
R_E            = 6.37814d3            ;;  Earth's Equitorial Radius [km]
;;----------------------------------------------------------------------------------------
;;  Date/Time and Probe
;;----------------------------------------------------------------------------------------
probe          = 'c'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
scpref         = 'th'+sc[0]+'_'
thprobe        = STRMID(scpref[0],0,3)
scu            = STRUPCASE(sc[0])

tdate          = '2009-09-05'
date           = '090509'
tr_00          = tdate[0]+'/'+['12:00:00','23:59:59']  ;;  Multiple crossings
tr_11          = time_double(tdate[0]+'/'+['14:22:40.000','18:56:00.000'])
tr_jj          = time_double(tdate[0]+'/'+['16:07:10.000','16:56:20.000'])

t_foot_ra0     = time_double(tdate[0]+'/'+['16:11:33.800','16:12:11.660'])
t_foot_ra1     = time_double(tdate[0]+'/'+['16:37:59.000','16:38:11.680'])
t_foot_ra2     = time_double(tdate[0]+'/'+['16:52:55.970','16:54:31.240'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['16:11:32.910','16:11:33.800'])
t_ramp_ra1     = time_double(tdate[0]+'/'+['16:37:58.272','16:37:59.000'])
t_ramp_ra2     = time_double(tdate[0]+'/'+['16:54:31.240','16:54:33.120'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = MEAN(t_ramp_ra1,/NAN)
t_ramp2        = MEAN(t_ramp_ra2,/NAN)
traz           = t_ramp1[0] + [-1d0,1d0]*30   ;;  60 s window around ramp

nif_suffx_1    = '-RHS01'
nif_suffx_2    = '-RHS02'
nif_suffx_3    = '-RHS03'
;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
def_dir        = '../Lynn_B_Wilson_III/LaTeX/First_Author_Papers/themis_energy_dissipation/crib_sheets/'
mdir           = FILE_EXPAND_PATH(def_dir[0])
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_'
fsuff          = 'efp-despiked_rmEconv-DC-despun_'+tdate[0]+'_'
fname          = fpref[0]+fsuff[0]+'*.tplot'
file           = FILE_SEARCH(mdir,fname[0])
tplot_restore,FILENAME=file[0],VERBOSE=0
;;----------------------------------------------------------------------------------------
;;  Set defaults
;;----------------------------------------------------------------------------------------
!themis.VERBOSE = 2
tplot_options,'VERBOSE',2
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'
;;  Use default colors
coord_mag      = 'mag'
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
all_coords     = [coord_dsl[0],coord_gse[0],coord_gsm[0]]
FOR j=0L, N_ELEMENTS(all_coords) - 1L DO BEGIN       $
  options,tnames('*_'+all_coords[j]+'*'),'COLORS'  & $
  options,tnames('*_'+all_coords[j]+'*'),'COLORS',[250,150, 50],/DEF

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='THEMIS-'+scu[0]+' Plots ['+tdate[0]+']'

nnw            = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
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
;;  Prefixes, middle, and suffix parts of TPLOT handles
;;  Moments...
Te_mid_nm      = 'peeb_avgtemp'
Ti_mid_nm      = 'T_avg_peib_no_GIs_UV'
Ni_mid_nm      = 'N_peib_no_GIs_UV'
Vi_mid_nm      = 'Velocity_'+coord_gse[0]+'_peib_no_GIs_UV'

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
efw_ncb_mid    = modes_efi[1]+'_cal_corrected_DownSampled_'
;;  State...
state_midnm    = 'state_'
sp_per_suff    = state_midnm[0]+'spinper'
sp_phs_suff    = state_midnm[0]+'spinphase'
;;  Jo, (-Jo . E), and cumulative sum of (-Jo . E)...
jvec_prefx_US  = scpref[0]+'jvec_'+mode_fgm[2]+'_'+coord_ncb[0]+'_Upsampled_Smoothed'
JodotdE_prefx  = scpref[0]+'neg-Jo-dot-dE_'+modes_efi[0]+'_'
JoddECS_prefx  = scpref[0]+'neg-Jo-dot-dE_'+modes_efi[0]+'_CumSum_'
JodotEo_prefx  = scpref[0]+'neg-Jo-dot-Eo_'+modes_efi[0]+'_'
JodEoCS_prefx  = scpref[0]+'neg-Jo-dot-Eo_'+modes_efi[0]+'_CumSum_'

;;  Moments TPLOT handles
Te__tpnm       = tnames(scpref[0]+Te_mid_nm[0])
Ti__tpnm       = tnames(scpref[0]+Ti_mid_nm[0])
Ni__tpnm       = tnames(scpref[0]+Ni_mid_nm[0])
Vi__tpnm       = tnames(scpref[0]+Vi_mid_nm[0])

;;  State TPLOT handles
sp_per_tpnm    = tnames(scpref[0]+sp_per_suff[0])
sp_phs_tpnm    = tnames(scpref[0]+sp_phs_suff[0])
spphs_int_tpnm = sp_phs_tpnm[0]+'_int'
sunpulse_nm    = scpref[0]+state_midnm[0]+'sun_pulse'
;;  EFI TPLOT handles
efp_dsl_orig   = tnames(pref[0]+modes_efi[0]+efi_midnm[0]+coord_dsl[0]+'*')              ;;  Level-1 efp data [DSL, mV/m]
efw_dsl_orig   = tnames(pref[0]+modes_efi[1]+efi_midnm[0]+coord_dsl[0]+'*')              ;;  Level-1 efw data [DSL, mV/m]
efp_nodc_dsl   = tnames(pref[0]+modes_efi[0]+efi_nodcnm[0]+coord_dsl[0])                 ;;  Removed DC-offsets from EFP_DSL_ORIG
efw_ncb_tpn    = tnames(pref[0]+efw_ncb_mid[0]+coord_ncb[0]+'*')
efp_spinfitmod = tnames(pref[0]+modes_efi[0]+efp_spinfit_nm[0]+coord_dsl[0])
efp_rmspft_dsl = tnames(pref[0]+modes_efi[0]+efp_rmspftmod[0]+coord_dsl[0])
efp_rmspft_gse = tnames(pref[0]+modes_efi[0]+efp_rmspftmod[0]+coord_gse[0])
efp_rmspft_nif = tnames(pref[0]+modes_efi[0]+efp_rmspftmod[0]+coord_nif[0])
efp_rmspft_ncb = tnames(pref[0]+modes_efi[0]+efp_rmspftmod[0]+coord_ncb[0])


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
fgm_tpn_dsl    = {T0:fgs_mag_dsl,T1:fgl_mag_dsl,T2:fgh_mag_dsl}
fgs_mag_gse    = [fgm_mag[0],fgm_gse[0]]
fgl_mag_gse    = [fgm_mag[1],fgm_gse[1]]
fgh_mag_gse    = [fgm_mag[2],fgm_gse[2]]
fgm_tpn_gse    = {T0:fgs_mag_gse,T1:fgl_mag_gse,T2:fgh_mag_gse}
fgs_mag_ncb    = [fgm_mag[0],fgm_ncb[0]]
fgl_mag_ncb    = [fgm_mag[1],fgm_ncb[1]]
fgh_mag_ncb    = [fgm_mag[2],fgm_ncb[2]]
fgm_tpn_ncb    = {T0:fgs_mag_ncb,T1:fgl_mag_ncb,T2:fgh_mag_ncb}


;;  Jo, (-Jo . E), and cumulative sum of (-Jo . E) TPLOT handles
jvec_name_US   = tnames(jvec_prefx_US[0]+'*')
JodotdE_upsam  = tnames(JodotdE_prefx[0]+'*pts_'+coord_ncb[0])
JoddECS_upsam  = tnames(JoddECS_prefx[0]+'*pts_'+coord_ncb[0])
JodEo_efp_jvsm = tnames(JodotEo_prefx[0]+coord_ncb[0])
JodEoCS_efpjsm = tnames(JodEoCS_prefx[0]+coord_ncb[0])

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

;;  Clean up
DELVAR,temp_efp,dlim_efp,lim_efp,efp_t,efp_v
;;----------------------------------------------------------------------------------------
;;  Change name of thc_efp_cal_dsl
;;----------------------------------------------------------------------------------------
efp_dsl_nospk  = efp_dsl_orig[0]+'_despiked'
store_data,efp_dsl_orig[0],NEWNAME=efp_dsl_nospk[0]
;;  Reload original 
tra            = time_double(tr_00)
suffe          = '_cal_'+coord_dsl[0]
type_e         = 'calibrated'
thm_load_efi,PROBE=sc[0],DATATYPE='efp',TRANGE=tra,SUFFIX=suffe[0],TYPE=type_e,$
             COORD=coord_dsl[0],/GET_SUPPORT_DATA,VERBOSE=0

options,efp_dsl_orig[0],'COLORS'
options,efp_dsl_orig[0],'COLORS',[250,150,50],/DEF
;;----------------------------------------------------------------------------------------
;;  Add TPLOT variable where Te and Ti are together
;;----------------------------------------------------------------------------------------
t_fact         = 8d0
t_fac_str      = STRTRIM(STRING(t_fact[0],FORMAT='(I)'),2L)
temp_cols      = [250, 50]
temp_labs      = ['Te','Ti/'+t_fac_str[0]]
temp__yra      = [0d0,1d0]*65d0
temp_yttl      = 'Temp [eV, Burst]'
temp_ysub      = '['+thprobe[0]+', Avg., Te and Ti/'+t_fac_str[0]+']'
Te_Ti_tpn      = scpref[0]+'Te-Ti_'+t_fac_str[0]+'_avgtemp'

get_data,Te__tpnm[0],DATA=temp0,DLIM=dlim0,LIM=lim0
get_data,Ti__tpnm[0],DATA=temp1,DLIM=dlim1,LIM=lim1
;;  Combine
Te__t          = temp0.X
Te__v          = temp0.Y
Ti_at_Te_v     = interp(temp1.Y,temp1.X,Te__t,/NO_EXTRAP)/t_fact[0]    ;;  1/8 Ti at Te timesteps
Te_Ti_v        = [[Te__v],[Ti_at_Te_v]]
temp_str       = {X:Te__t,Y:Te_Ti_v}
;;  Send to TPLOT
store_data,Te_Ti_tpn[0],DATA=temp_str,DLIM=dlim0,LIM=lim0
options,Te_Ti_tpn[0],'COLORS',temp_cols,/DEF
options,Te_Ti_tpn[0],'LABELS',temp_labs,/DEF
;;  Force YRANGE
options,Te_Ti_tpn[0],'YRANGE'
options,Te_Ti_tpn[0],'YRANGE',/DEF
options,Te_Ti_tpn[0],'YRANGE',temp__yra,/DEF
;;  Change Y-Axis title and subtitle
options,Te_Ti_tpn[0],'YTITLE',temp_yttl[0],/DEF
options,Te_Ti_tpn[0],'YSUBTITLE',temp_ysub[0],/DEF
;;----------------------------------------------------------------------------------------
;;  Add TPLOT variable where |Bo| and Bo are together
;;----------------------------------------------------------------------------------------
fgm_bmag_dsl   = fgm_pren[*]+'_'+coord_dsl[0]+'_mag'
fgm_bmag_gse   = fgm_pren[*]+'_'+coord_gse[0]+'_mag'
fgm_bmag_ncb   = fgm_pren[*]+'_'+coord_ncb[0]+'_mag'

magf_cols      = [250,150,50,25]
magf_labs      = ['Bx','By','Bz','|B|']
magf__yra      = [-1d0,1d0]*2d1
fgm_all_coord  = {T0:fgm_tpn_dsl,T1:fgm_tpn_gse,T2:fgm_tpn_ncb}
fgm_all_out    = {T0:fgm_bmag_dsl,T1:fgm_bmag_gse,T2:fgm_bmag_ncb}

FOR cc=0L, 2L DO BEGIN                                                        $
  all_tpn__in = fgm_all_coord.(cc[0])                                       & $
  all_tpn_out = fgm_all_out.(cc[0])                                         & $
  FOR mm=0L, 2L DO BEGIN                                                      $
    tpn__in        = all_tpn__in.(mm[0])                                    & $
    tpn_out        = all_tpn_out[mm[0]]                                     & $
    get_data,tpn__in[0],DATA=temp0,DLIM=dlim0,LIM=lim0                      & $
    get_data,tpn__in[1],DATA=temp1,DLIM=dlim1,LIM=lim1                      & $
    magf_vx        = REFORM(temp1.Y[*,0])                                   & $
    magf_vy        = REFORM(temp1.Y[*,1])                                   & $
    magf_vz        = REFORM(temp1.Y[*,2])                                   & $
    bmag_t         = temp0.X                                                & $
    bmag_v         = temp0.Y                                                & $
    magf_str       = {X:bmag_t,Y:[[magf_vx],[magf_vy],[magf_vz],[bmag_v]]}  & $
    store_data,tpn_out[0],DATA=magf_str,DLIM=dlim1,LIM=lim1

;;  Update options
FOR cc=0L, 2L DO BEGIN                                                        $
  all_tpn_out = fgm_all_out.(cc[0])                                         & $
  options,all_tpn_out,'COLORS',magf_cols,/DEF                               & $
  options,all_tpn_out,'LABELS',magf_labs,/DEF                               & $
  options,all_tpn_out,'YRANGE'                                              & $
  options,all_tpn_out,'YRANGE',magf__yra,/DEF

nnw            = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
;;----------------------------------------------------------------------------------------
;;  Define relevant time ranges
;;----------------------------------------------------------------------------------------
get_data,efw_ncb_tpn[0],DATA=temp_efw_ncb,DLIM=dlim_efw_ncb,LIM=lim_efw_ncb
dE__t          = temp_efw_ncb.X

tra_overview   = t_ramp1[0] + [-1d0,1d0]*165d0  ;;  330 s window centered on ramp
tra_overview2  = t_ramp1[0] + [-1d0,1d0]*90d0   ;;  180 s window centered on ramp
tra_efp_0      = t_ramp1[0] + [-65d-2,1d0]*20
tra_efw_0      = minmax(dE__t) + [-1d0,1d0]

;;  Clean up
DELVAR,temp_efw_ncb,dlim_efw_ncb,lim_efw_ncb,dE__t
;;----------------------------------------------------------------------------------------
;;  Change Plot Settings
;;----------------------------------------------------------------------------------------
;tra_file       = t_get_current_trange()
fgm_mode       = 0L      ;;  fgs
fgm_mode       = 1L      ;;  fgl
fgm_mode       = 2L      ;;  fgh

all_efi_tpnm   = [scp_dsl_orig[0],efp_dsl_orig[0]]
all_fgm_tpnm   = fgm_all_out.(0)[fgm_mode[0]]

;;  Wave Burst Plots
jdE_tpns       = [JodEo_efp_jvsm[0],JodotdE_upsam[0]]
jdECS_tpns     = [JodEoCS_efpjsm[0],JoddECS_upsam[0]]
ef_names       = [efp_rmspft_ncb[0],efw_ncb_tpn[0]]
;;  Change tick style for (-Jo . E)
all_Jo_E_tpn   = [jdE_tpns,jdECS_tpns]
options,all_Jo_E_tpn,'YTICKLEN'
options,all_Jo_E_tpn,'YTICKLEN',/DEF
options,all_Jo_E_tpn,'YTICKLEN',1.0       ;;  use full-length tick marks
options,all_Jo_E_tpn,'YGRIDSTYLE',1       ;;  use dotted lines

;;  Fix Y-Ranges for better looking plots
jvec_sm_yra    = [-1d0,1d0]*75d-2
efp_dsl_yra    = [-1d0,1d0]*40d0
efp_ncb_yra    = [-1d0,1d0]*25d0
efw_ncb_yra    = [-1d0,1d0]*200d0
E_d_Jo_yra     = [-1d0,1d0]*4d-2
EdJoCS_yra     = [-1.5d0,5d-1]

;;  Remove any Y-ranges set in LIMITS structure
options,[jvec_name_US[0],ef_names,jdE_tpns,jdECS_tpns],'YRANGE'

options,jvec_name_US[0],'YRANGE',jvec_sm_yra,/DEF
options,efp_rmspft_ncb[0],'YRANGE',efp_ncb_yra,/DEF
options,efw_ncb_tpn[0],'YRANGE',efw_ncb_yra,/DEF
options,jdE_tpns,'YRANGE',E_d_Jo_yra,/DEF
options,jdECS_tpns,'YRANGE',EdJoCS_yra,/DEF
options,[efp_dsl_nospk[0],efp_spinfitmod[0],efp_rmspft_dsl[0]],'YRANGE',efp_dsl_yra,/DEF

;;  Plot (-Jo . E)
trange         = tra_efw_0
fgm_mode       = 2L      ;;  fgh
all_fgm_tpnm   = fgm_all_out.(1)[fgm_mode[0]]
Jo_names       = jdE_tpns
nna            = [all_fgm_tpnm,jvec_name_US[0],ef_names,Jo_names]
  tplot,nna,TRANGE=trange

;;  Plot the cumulative sum of (-Jo . E)
Jo_names       = jdECS_tpns
nna            = [all_fgm_tpnm,jvec_name_US[0],ef_names,Jo_names]
  tplot,nna,TRANGE=trange

;;----------------------------------------------------------------------------------------
;;  Calculate FFT (time and frequency averaged) of (-Jo . ∂E)
;;----------------------------------------------------------------------------------------
;.compile /Users/lbwilson/Desktop/temp_idl/time_and_freq_averaged_fft.pro
.compile time_and_freq_averaged_fft.pro

jvec_128_prefx = scpref[0]+'jvec_'+mode_fgm[2]+'_'+coord_nif[0]
get_data,jvec_128_prefx[0],DATA=temp_jvec,DLIM=dlim_jvec,LIM=lim_jvec
get_data,jvec_name_US[0],DATA=temp_jvec_US,DLIM=dlim_jvec_US,LIM=lim_jvec_US

get_data,JodEo_efp_jvsm[0],DATA=temp_JodotEo,DLIM=dlim_JodotEo,LIM=lim_JodotEo
get_data,JodotdE_upsam[0],DATA=temp_JodotdE,DLIM=dlim_JodotdE,LIM=lim_JodotdE
get_data,efw_ncb_tpn[0],DATA=temp_efw_ncb,DLIM=dlim_efw_ncb,LIM=lim_efw_ncb
get_data,efp_rmspft_ncb[0],DATA=temp_efp_ncb,DLIM=dlim_efp_ncb,LIM=lim_efp_ncb

;;  Force onto the same timestamps
Eo_t           = temp_efp_ncb.X
Eo_v           = temp_efp_ncb.Y
new_t          = temp_jvec.X
test           = (new_t GE tra_efw_0[0]) AND (new_t LE tra_efw_0[1])
good           = WHERE(test,gd)
new_t          = new_t[good]
Eo_v_on_jvec_t = resample_2d_vec(Eo_v,Eo_t,new_t,/NO_EXTRAPOLATE)

nfft           = 128L
nshft          = 32L
;nfft           = 128L/2L
;nshft          = 32L/2L
new_t          = temp_jvec.X[good]
test_fft_jvec  = time_and_freq_averaged_fft(new_t,temp_jvec.Y[good,*]*1d-6,NFFT=nfft,NSHFT=nshft)
test_fft__efp  = time_and_freq_averaged_fft(new_t,Eo_v_on_jvec_t[good,*]*1d-3,NFFT=nfft,NSHFT=nshft)

new_t          = temp_jvec_US.X
test_fft_jv_US = time_and_freq_averaged_fft(new_t,temp_jvec_US.Y*1d-6,NFFT=nfft,NSHFT=nshft)
test_fft__efw  = time_and_freq_averaged_fft(new_t,temp_efw_ncb.Y*1d-3,NFFT=nfft,NSHFT=nshft)

;;  Define FFT parameters
t_128_fft      = test_fft_jvec.TIME_FFT
jvec_fft       = test_fft_jvec.VEC_FFT
efp__fft       = test_fft__efp.VEC_FFT

t__US_fft      = test_fft__efw.TIME_FFT
jvec_US_fft    = test_fft_jv_US.VEC_FFT
efw__fft       = test_fft__efw.VEC_FFT
;;  Define sample rate
srate_efp      = DOUBLE(sample_rate(temp_efp_ncb.X,GAP_THRESH=1d0,/AVE))
srate_efw      = DOUBLE(sample_rate(temp_efw_ncb.X,GAP_THRESH=1d0,/AVE))
;;  Calculate (-Jo* . ∂E)
;fac            = 1d6       ;;  W --> µW
;fac_efp        = 1d6*srate_efp[0]/nfft[0]       ;;  W --> µW, [] --> Hz
;fac_efw        = 1d6*srate_efw[0]/nfft[0]       ;;  W --> µW, [] --> Hz
;fac_efp        = 1d6/(srate_efp[0]/nfft[0])      ;;  W --> µW, [] --> Hz^(-1)
;fac_efw        = 1d6/(srate_efw[0]/nfft[0])      ;;  W --> µW, [] --> Hz^(-1)
fac_efp        = 1d6                            ;;  W --> µW
fac_efw        = 1d6                            ;;  W --> µW
temp           = -1d0*CONJ(jvec_US_fft)*efw__fft/2d0
j_dot_dE_fft   = TOTAL(TOTAL(temp,3L,/NAN),2L,/NAN)*fac_efw[0]
temp           = -1d0*CONJ(jvec_fft)*efp__fft/2d0
j_dot_Eo_fft   = TOTAL(TOTAL(temp,3L,/NAN),2L,/NAN)*fac_efp[0]
;;  Upsample (-Jo* . Eo) so we can combine them
jdEo_fft_US    = interp(j_dot_Eo_fft,t_128_fft,t__US_fft,/NO_EXTRAP)


;;  Send to TPLOT
JoddE_US_FFT   = 'thc_neg-Jo-dot-dE_efw_128pts_nif_ncb_S1986a-RHS02_FFT'
struc          = {X:t__US_fft,Y:REAL_PART(j_dot_dE_fft)}
ysubt          = '[thc, 8192.0 sps, FFT Avg.]'
yttl           = '<(-Jo . ∂E)>!Dt!N [efw, NIF (NCB basis), !7l!XW m!U-3!N'+']'
;yttl           = '<(-Jo . ∂E)>!Dt!N [efw, NIF (NCB basis), !7l!XW m!U-3!N Hz!U-1!N'+']'
dlim           = dlim_JodotdE
str_element,dlim,'YTITLE',yttl[0],/ADD_REPLACE
str_element,dlim,'YSUBTITLE',ysubt[0],/ADD_REPLACE
store_data,JoddE_US_FFT[0],DATA=struc,DLIM=dlim,LIM=lim_JodotdE

JodEo_US_FFT   = 'thc_neg-Jo-dot-Eo_efp_128pts_nif_ncb_S1986a-RHS02_FFT'
struc          = {X:t_128_fft,Y:REAL_PART(j_dot_Eo_fft)}
ysubt          = '[thc, 128.0 sps, FFT Avg.]'
yttl           = '<(-Jo . Eo)>!Dt!N [efp, NIF (NCB basis), !7l!XW m!U-3!N'+']'
;yttl           = '<(-Jo . Eo)>!Dt!N [efp, NIF (NCB basis), !7l!XW m!U-3!N Hz!U-1!N'+']'
dlim           = dlim_JodotEo
str_element,dlim,'YTITLE',yttl[0],/ADD_REPLACE
str_element,dlim,'YSUBTITLE',ysubt[0],/ADD_REPLACE
store_data,JodEo_US_FFT[0],DATA=struc,DLIM=dlim,LIM=lim_JodotEo

JodEodE_US_FFT = 'thc_neg-Jo-dot-E_efp-efw_128pts_nif_ncb_S1986a-RHS02_FFT'
struc          = {X:t__US_fft,Y:[[REAL_PART(j_dot_dE_fft)],[REAL_PART(jdEo_fft_US)*1d0]]}
ysubt          = '[thc, {efp,efw}, 8192.0 sps, FFT Avg.]'
yttl           = '<(-Jo . E)>!Dt!N [NIF (NCB basis), !7l!XW m!U-3!N'+']'
;yttl           = '<(-Jo . E)>!Dt!N [NIF (NCB basis), !7l!XW m!U-3!N Hz!U-1!N'+']'
dlim           = dlim_JodotEo
str_element,dlim,'YTITLE',yttl[0],/ADD_REPLACE
str_element,dlim,'YSUBTITLE',ysubt[0],/ADD_REPLACE
store_data,JodEodE_US_FFT[0],DATA=struc,DLIM=dlim,LIM=lim_JodotEo

;;  Change options
;yran0          = [-2d1,1d1]/2d0
;yran0          = [-1d-2,4d-3]
;yran0          = [-6d-1,3d-1]
;yran0          = [-1d0,1d0]*1d-2
;yran0          = [-1d0,1d0]*6d-1
;yran0          = [-1d0,1d0]*2d0
;yran0          = [-1d0,1d0]*4d0
yran0          = [-1d0,1d0]*2d-2
options,[JodEo_US_FFT[0],JoddE_US_FFT[0]],'YRANGE'
options,[JodEo_US_FFT[0],JoddE_US_FFT[0]],'YRANGE',yran0,/DEF
options,[JodEo_US_FFT[0],JoddE_US_FFT[0]],'YTICKLEN',1.0       ;;  use full-length tick marks
options,[JodEo_US_FFT[0],JoddE_US_FFT[0]],'YGRIDSTYLE',1       ;;  use dotted lines
options,[JodEo_US_FFT[0],JoddE_US_FFT[0]],'COLORS'
options,[JodEo_US_FFT[0],JoddE_US_FFT[0]],'LABELS'
options,[JodEo_US_FFT[0],JoddE_US_FFT[0]],'COLORS', 50,/DEF
options,JodEo_US_FFT[0],'LABELS','FFT(-Jo . Eo)',/DEF
options,JoddE_US_FFT[0],'LABELS','FFT(-Jo . dE)',/DEF

;yran0          = [-1d0,1d0]*1d-2
;yran0          = [-1d0,1d0]*6d-1
;yran0          = [-1d0,1d0]*2d0
;yran0          = [-1d0,1d0]*4d0
yran0          = [-1d0,1d0]*2d-2
options,JodEodE_US_FFT[0],'YRANGE'
options,JodEodE_US_FFT[0],'YRANGE',yran0,/DEF
options,JodEodE_US_FFT[0],'YTICKLEN',1.0       ;;  use full-length tick marks
options,JodEodE_US_FFT[0],'YGRIDSTYLE',1       ;;  use dotted lines
options,JodEodE_US_FFT[0],'COLORS'
options,JodEodE_US_FFT[0],'LABELS'
options,JodEodE_US_FFT[0],'COLORS',[ 50,250],/DEF
options,JodEodE_US_FFT[0],'LABELS',['FFT(-Jo . dE)','FFT(-Jo . Eo)'],/DEF
;options,JodEodE_US_FFT[0],'LABELS',['FFT(-Jo . dE)','100 x FFT(-Jo . Eo)'],/DEF



;;  Plot (-Jo . E) and its cumulative sum with the FFT
trange         = tra_efw_0
fgm_mode       = 2L      ;;  fgh
all_fgm_tpnm   = fgm_all_out.(1)[fgm_mode[0]]
Jo_names       = [jdE_tpns,jdECS_tpns]
nna            = [all_fgm_tpnm,jvec_name_US[0],ef_names,Jo_names,JoddE_US_FFT[0]]
  tplot,nna,TRANGE=trange

nna            = [all_fgm_tpnm,jvec_name_US[0],ef_names,Jo_names,JodEodE_US_FFT[0]]
  tplot,nna,TRANGE=trange

;;----------------------------------------------------------------------------------------
;;  Combine efp and efw (-Jo . ∂E) and their cumulative sums
;;----------------------------------------------------------------------------------------
new_labs       = ['(-Jo . Eo)','(-Jo . dE)']
all_jjs        = [JodEo_efp_jvsm[0],JodotdE_upsam[0],JodEoCS_efpjsm[0],JoddECS_upsam[0]]
options,all_jjs,'YTICKLEN',1.0       ;;  use full-length tick marks
options,all_jjs,'YGRIDSTYLE',1       ;;  use dotted lines
;;  Remove old labels and colors
options,all_jjs,'COLORS'
options,all_jjs,'LABELS'
options,[JodEo_efp_jvsm[0],JodEoCS_efpjsm[0]],'COLORS',250,/DEF
options,[ JodotdE_upsam[0], JoddECS_upsam[0]],'COLORS', 50,/DEF
options,[JodEo_efp_jvsm[0],JodEoCS_efpjsm[0]],'LABELS',new_labs[0],/DEF
options,[ JodotdE_upsam[0], JoddECS_upsam[0]],'LABELS',new_labs[1],/DEF

efi_yran       = [-1d0,1d0]*2d2
options,[efp_rmspft_ncb[0],efw_ncb_tpn[0]],'YRANGE'
options,[efp_rmspft_ncb[0],efw_ncb_tpn[0]],'YRANGE',efi_yran,/DEF


;;  Get data
get_data,JodEo_efp_jvsm[0],DATA=temp_JodEo,DLIM=dlim_JodEo,LIM=lim_JodEo
get_data, JodotdE_upsam[0],DATA=temp_JoddE,DLIM=dlim_JoddE,LIM=lim_JoddE
get_data,JodEoCS_efpjsm[0],DATA=temp_JodEoCS,DLIM=dlim_JodEoCS,LIM=lim_JodEoCS
get_data, JoddECS_upsam[0],DATA=temp_JoddECS,DLIM=dlim_JoddECS,LIM=lim_JoddECS

;;  Define parameters
jE____efp_t    = temp_JodEo.X
jE_CS_efp_t    = temp_JodEoCS.X
jE____efp_v    = temp_JodEo.Y
jE_CS_efp_v    = temp_JodEoCS.Y
jE____efw_t    = temp_JoddE.X
jE_CS_efw_t    = temp_JoddECS.X
jE____efw_v    = temp_JoddE.Y
jE_CS_efw_v    = temp_JoddECS.Y
;;  Force onto the same timestamps
old_t          = jE____efp_t
new_t          = jE____efw_t
old_v          = jE____efp_v # REPLICATE(1d0,3L)
jE____efp_v_2  = resample_2d_vec(old_v,old_t,new_t,/NO_EXTRAPOLATE)
old_v          = jE_CS_efp_v # REPLICATE(1d0,3L)
jE_CS_efp_v_2  = resample_2d_vec(old_v,old_t,new_t,/NO_EXTRAPOLATE)
;;  Define new structures
jE____efp_efw  = [[jE____efw_v],[REFORM(jE____efp_v_2[*,0])]]
jE_CS_efp_efw  = [[jE_CS_efw_v],[REFORM(jE_CS_efp_v_2[*,0])]]
struc____jE    = {X:new_t,Y:jE____efp_efw}
struc_CS_jE    = {X:new_t,Y:jE_CS_efp_efw}
;;  New names
Jo_d_E_efpefw  = 'thc_neg-Jo-dot-E_efp-efw_'+coord_ncb[0]
JodE_CS_efpefw = 'thc_neg-Jo-dot-E_efp-efw_CumSum_'+coord_ncb[0]

;;  Send to TPLOT
ysubt         = '[thc, 8192.0 sps]'
yttl          = '(-Jo . E) [{efp,efw}, NIF (NCB basis), !7l!XW m!U-3!N]'
dlim          = dlim_JoddE
str_element,dlim,'YTITLE',yttl[0],/ADD_REPLACE
str_element,dlim,'YSUBTITLE',ysubt[0],/ADD_REPLACE
store_data, Jo_d_E_efpefw[0],DATA=struc____jE,DLIM=dlim,LIM=lim_JodEo

ysubt         = '[thc, 8192.0 sps]'
yttl          = '∑ (-Jo . E) [{efp,efw}, NIF (NCB basis), !7l!XW m!U-3!N]'
dlim          = dlim_JoddECS
str_element,dlim,'YTITLE',yttl[0],/ADD_REPLACE
str_element,dlim,'YSUBTITLE',ysubt[0],/ADD_REPLACE
store_data,JodE_CS_efpefw[0],DATA=struc_CS_jE,DLIM=dlim,LIM=lim_JoddECS
;;  Change colors and labels
options,[Jo_d_E_efpefw[0],JodE_CS_efpefw[0]],'COLORS'
options,[Jo_d_E_efpefw[0],JodE_CS_efpefw[0]],'LABELS'
options,[Jo_d_E_efpefw[0],JodE_CS_efpefw[0]],'COLORS',[ 50,250],/DEF
options,[Jo_d_E_efpefw[0],JodE_CS_efpefw[0]],'LABELS',REVERSE(new_labs),/DEF

;options,[Jo_d_E_efpefw[0],JodE_CS_efpefw[0]],'YTICKLEN',1.0       ;;  use full-length tick marks
;options,[Jo_d_E_efpefw[0],JodE_CS_efpefw[0]],'YGRIDSTYLE',1       ;;  use dotted lines



;;  Plot (-Jo . E) and its cumulative sum with the FFT
trange         = tra_efw_0
fgm_mode       = 2L      ;;  fgh
all_fgm_tpnm   = fgm_all_out.(1)[fgm_mode[0]]
Jo_names       = [Jo_d_E_efpefw[0],JodE_CS_efpefw[0]]
nna            = [all_fgm_tpnm,jvec_name_US[0],ef_names,Jo_names,JodEodE_US_FFT[0]]
  tplot,nna,TRANGE=trange


coord          = coord_ncb[0]
f_pref0        = prefu[0]+coord[0]+'-All_'+mode_fgm[fgm_mode[0]]
f_pref         = f_pref0[0]+'_Jo-US_efp-cal-despike-rmDCoff-despin_efw-cal-DS_JodEo_JoddE_'
f_pref         = f_pref[0]+'JodEoCS_JoddECS_FFT-JdE_'
fnm_tra        = file_name_times(trange,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
fnames         = f_pref[0]+ftime[0]
PRINT, fnames[0]

popen,fnames[0],/PORT
  tplot,nna,TRANGE=trange
pclose
  tplot,/NOM



coord          = coord_ncb[0]
f_pref0        = prefu[0]+coord[0]+'-All_'+mode_fgm[fgm_mode[0]]
f_pref         = f_pref0[0]+'_Jo-US_efp-cal-despike-rmDCoff-despin_efw-cal-DS_'
f_pref         = f_pref[0]+'FFT-JdE_'
fnm_tra        = file_name_times(trange,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
fnames         = f_pref[0]+ftime[0]
PRINT, fnames[0]

nna            = [all_fgm_tpnm,jvec_name_US[0],ef_names,JodEodE_US_FFT[0]]
  tplot,nna,TRANGE=trange
popen,fnames[0],/PORT
  tplot,nna,TRANGE=trange
pclose
  tplot,/NOM

;;----------------------------------------------------------------------------------------
;;  Calculate time-average of (-Jo . ∂E)
;;----------------------------------------------------------------------------------------
get_data,JodEo_efp_jvsm[0],DATA=temp_JodotEo,DLIM=dlim_JodotEo,LIM=lim_JodotEo
get_data,JodotdE_upsam[0],DATA=temp_JodotdE,DLIM=dlim_JodotdE,LIM=lim_JodotdE
;;  Define variables
JodotEo_t      = temp_JodotEo.X
JodotEo_v      = temp_JodotEo.Y
JodotdE_t      = temp_JodotdE.X
JodotdE_v      = temp_JodotdE.Y
tdE_0          = JodotdE_t - MIN(JodotdE_t,/NAN)
;;  Define # of points to smooth
nsm            = 128L
tempx128       = SMOOTH(JodotdE_v,nsm[0],/NAN,/EDGE_TRUNCATE,MISSING=d[0])
tempy128       = SMOOTH(JodotEo_v,nsm[0],/NAN,/EDGE_TRUNCATE,MISSING=d[0])
nsm            = 64L
tempx064       = SMOOTH(JodotdE_v,nsm[0],/NAN,/EDGE_TRUNCATE,MISSING=d[0])
tempy064       = SMOOTH(JodotEo_v,nsm[0],/NAN,/EDGE_TRUNCATE,MISSING=d[0])
nsm            = 32L
tempx032       = SMOOTH(JodotdE_v,nsm[0],/NAN,/EDGE_TRUNCATE,MISSING=d[0])
tempy032       = SMOOTH(JodotEo_v,nsm[0],/NAN,/EDGE_TRUNCATE,MISSING=d[0])
nsm            = 16L
tempx016       = SMOOTH(JodotdE_v,nsm[0],/NAN,/EDGE_TRUNCATE,MISSING=d[0])
tempy016       = SMOOTH(JodotEo_v,nsm[0],/NAN,/EDGE_TRUNCATE,MISSING=d[0])
nsm            = 08L
tempx008       = SMOOTH(JodotdE_v,nsm[0],/NAN,/EDGE_TRUNCATE,MISSING=d[0])
tempy008       = SMOOTH(JodotEo_v,nsm[0],/NAN,/EDGE_TRUNCATE,MISSING=d[0])
nsm            = 04L
tempx004       = SMOOTH(JodotdE_v,nsm[0],/NAN,/EDGE_TRUNCATE,MISSING=d[0])
tempy004       = SMOOTH(JodotEo_v,nsm[0],/NAN,/EDGE_TRUNCATE,MISSING=d[0])

;;  Define new "effective" sample rates
srate_dE       = DOUBLE(sample_rate(JodotdE_t,GAP_THRESH=1d0,/AVE))
srate_Eo       = DOUBLE(sample_rate(JodotEo_t,GAP_THRESH=1d0,/AVE))
nsm_all        = REVERSE(DOUBLE([128L,64L,32L,16L,8L,4L,1L]))
srate_dE_all   = srate_dE[0]/nsm_all

WINDOW,1,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Test Plots ['+tdate[0]+']'

;;  Define test plot parameters
xx000          = JodotdE_v
xx128          = tempx128
xx064          = tempx064
xx032          = tempx032
xx016          = tempx016
xx008          = tempx008
xx004          = tempx004

test           = (JodotEo_t GE tra_efw_0[0]) AND (JodotEo_t LE tra_efw_0[1])
good_tr        = WHERE(test,gdtr)
tEo_0          = JodotEo_t[good_tr] - MIN(JodotEo_t[good_tr],/NAN)
yy000          = JodotEo_v[good_tr]
yy128          = tempy128[good_tr]
yy064          = tempy064[good_tr]
yy032          = tempy032[good_tr]
yy016          = tempy016[good_tr]
yy008          = tempy008[good_tr]
yy004          = tempy004[good_tr]

thck           = 3.0
lnst           = 2
WSET,1
WSHOW,1
PLOT,tdE_0,xx000,YRANGE=[-1D0,1d0]*4d-2,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,tdE_0,xx000,LINESTYLE=0,COLOR= 30,THICK=thck[0]
  OPLOT,tEo_0,yy000,LINESTYLE=0,COLOR=250,THICK=thck[0]
  ;;  Plot 128 pt averages
  OPLOT,tdE_0,xx128,LINESTYLE=lnst[0],COLOR= 50,THICK=thck[0]/2
  OPLOT,tEo_0,yy128,LINESTYLE=lnst[0],COLOR=225,THICK=thck[0]/2
  ;;  Plot 064 pt averages
  OPLOT,tdE_0,xx064,LINESTYLE=lnst[0],COLOR= 70,THICK=thck[0]/2
  OPLOT,tEo_0,yy064,LINESTYLE=lnst[0],COLOR=200,THICK=thck[0]/2
  ;;  Plot 032 pt averages
  OPLOT,tdE_0,xx032,LINESTYLE=lnst[0],COLOR= 90,THICK=thck[0]/2
  OPLOT,tEo_0,yy032,LINESTYLE=lnst[0],COLOR=175,THICK=thck[0]/2
  ;;  Plot 016 pt averages
  OPLOT,tdE_0,xx016,LINESTYLE=lnst[0],COLOR=110,THICK=thck[0]/2
  OPLOT,tEo_0,yy016,LINESTYLE=lnst[0],COLOR=150,THICK=thck[0]/2

;;  Just plot efw
;thck           = [4.0,3.5,3.0,2.5,2.0,1.5,1.0] - 0.5
thck           = REVERSE(FINDGEN(7)*0.25 + 1.0)
lnst           = 0
WSET,1
WSHOW,1
PLOT,tdE_0,xx000,YRANGE=[-1D0,1d0]*4d-2,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,tdE_0,xx000,LINESTYLE=0,COLOR= 30,THICK=thck[0]
  ;;  Plot 004 pt averages
  OPLOT,tdE_0,xx008,LINESTYLE=lnst[0],COLOR=150,THICK=thck[1]
  ;;  Plot 008 pt averages
  OPLOT,tdE_0,xx008,LINESTYLE=lnst[0],COLOR=130,THICK=thck[2]
  ;;  Plot 016 pt averages
  OPLOT,tdE_0,xx016,LINESTYLE=lnst[0],COLOR=110,THICK=thck[3]
  ;;  Plot 032 pt averages
  OPLOT,tdE_0,xx032,LINESTYLE=lnst[0],COLOR= 90,THICK=thck[4]
  ;;  Plot 064 pt averages
  OPLOT,tdE_0,xx064,LINESTYLE=lnst[0],COLOR= 70,THICK=thck[5]
  ;;  Plot 128 pt averages
  OPLOT,tdE_0,xx128,LINESTYLE=lnst[0],COLOR= 50,THICK=thck[6]



tt000          = JodotdE_t
xx000          = JodotdE_v
xx128          = tempx128
xx064          = tempx064
xx032          = tempx032
xx016          = tempx016
xx008          = tempx008
xx004          = tempx004
;xxall          = REVERSE([[xx000],[xx128],[xx064],[xx032],[xx016],[xx008],[xx004]],2)
xxall          = [[xx000],[xx004],[xx008],[xx016],[xx032],[xx064],[xx128]]
struc          = {X:tt000,Y:xxall}
nsm_all        = REVERSE(DOUBLE([128L,64L,32L,16L,8L,4L,1L]))
n_nsm          = N_ELEMENTS(nsm_all)
srate_dE_all   = srate_dE[0]/nsm_all
sr_str_all     = STRING(srate_dE_all,FORMAT='(I4.4)')
nsm_str_all    = STRING(nsm_all,FORMAT='(I3.3)')
labs           = sr_str_all+' sps [Nsm : '+nsm_str_all+' pts]'
ysubt          = '[thc, 8192 sps, Time-Avgs]'
yttl           = '<(-Jo . ∂E)>!Dt!N [efw, NIF(NCB), !7l!XW m!U-3!N'+']'
cols           = LINDGEN(n_nsm[0])*(250L - 30L)/(n_nsm[0] - 1L) + 30L
dlim           = dlim_JodotdE
str_element,dlim,'YTITLE',yttl[0],/ADD_REPLACE
str_element,dlim,'YSUBTITLE',ysubt[0],/ADD_REPLACE
str_element,dlim,'COLORS',cols,/ADD_REPLACE
str_element,dlim,'LABELS',labs,/ADD_REPLACE
JoddE_US_TAvg  = 'thc_neg-Jo-dot-dE_efw_TimeAvg-Npts_nif_ncb_S1986a-RHS02'
store_data,JoddE_US_TAvg[0],DATA=struc,DLIM=dlim,LIM=lim_JodotdE

yran0          = [-1d0,1d0]*4d-2
options,JoddE_US_TAvg[0],'YRANGE'
options,JoddE_US_TAvg[0],'YRANGE',yran0,/DEF
options,JoddE_US_TAvg[0],'YTICKLEN',1.0       ;;  use full-length tick marks
options,JoddE_US_TAvg[0],'YGRIDSTYLE',1       ;;  use dotted lines


WSET,0

trange         = tra_efw_0
coord          = coord_ncb[0]
f_pref0        = prefu[0]+coord[0]+'-All_'+mode_fgm[fgm_mode[0]]
f_pref         = f_pref0[0]+'_Jo-US_efp-cal-despike-rmDCoff-despin_efw-cal-DS_'
f_pref         = f_pref[0]+'FFT-JdE_TimeAvg-Npts_'
fnm_tra        = file_name_times(trange,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
fnames         = f_pref[0]+ftime[0]
PRINT, fnames[0]


nna            = [all_fgm_tpnm,jvec_name_US[0],ef_names,JodEodE_US_FFT[0],JoddE_US_TAvg[0]]
  tplot,nna,TRANGE=trange
popen,fnames[0],/PORT
  tplot,nna,TRANGE=trange
pclose
  tplot,/NOM








