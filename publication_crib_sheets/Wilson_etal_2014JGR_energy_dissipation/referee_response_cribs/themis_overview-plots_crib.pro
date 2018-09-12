;;----------------------------------------------------------------------------------------
;; => Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init

;;  NEW Average Shock Terms [1st Crossing]
vshn_up        =     29.30846018d0
dvshnup        =      7.55206074d0
ushn_up        =   -339.45568562d0
dushnup        =      0.15896800d0
ushn_dn        =    -84.80839576d0
dushndn        =      3.97398740d0
gnorm          = [     0.99876535d0,    -0.03063744d0,    -0.03910405d0]
magf_up        = [     2.23681456d0,     0.21691634d0,    -2.02624458d0]
magf_dn        = [     5.41577923d0,    -7.90257120d0,    13.88976979d0]
theta_Bn       =     40.33263596d0

;;  Particle Moment Terms [1st Crossing]
vswi_up        = [-307.345d0,65.0927d0,30.3775d0]
vswi_dn        = [-54.9544d0,43.4793d0,-18.3793d0]
dens_up        =    9.66698d0
dens_dn        =   40.5643d0
Ti___up        =   17.52810d0
Ti___dn        =  145.3160d0
Te___up        =    7.87657d0
Te___dn        =   31.0342d0

;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_a_data_2009-09-26_batch.pro
thprobe        = STRMID(scpref[0],0,3)

;;----------------------------------------------------------------------------------------
;; => Define time zooms around ramp
;;----------------------------------------------------------------------------------------
tz_facs        = [2.5d0,5d0,7.5d0,1d1,15d0,22.5d0,3d1,45d0,6d1,75d0,1d2]
tz_strs        = '_'+STRTRIM(STRING(2d0*tz_facs,FORMAT='(I3.3)'),2)+'-sec-window'
ntz            = N_ELEMENTS(tz_facs)
tzoom0         = DBLARR(ntz,2L)
tzoom1         = DBLARR(ntz,2L)
tzoom2         = DBLARR(ntz,2L)

tzoom0[*,0]    = t_ramp0[0] - tz_facs
tzoom0[*,1]    = t_ramp0[0] + tz_facs
tzoom1[*,0]    = t_ramp1[0] - tz_facs
tzoom1[*,1]    = t_ramp1[0] + tz_facs
tzoom2[*,0]    = t_ramp2[0] - tz_facs
tzoom2[*,1]    = t_ramp2[0] + tz_facs

fnm_s0         = file_name_times(tzoom0[*,0],PREC=4)
fnm_e0         = file_name_times(tzoom0[*,1],PREC=4)
fnm_s1         = file_name_times(tzoom1[*,0],PREC=4)
fnm_e1         = file_name_times(tzoom1[*,1],PREC=4)
fnm_s2         = file_name_times(tzoom2[*,0],PREC=4)
fnm_e2         = file_name_times(tzoom2[*,1],PREC=4)

ftimes0        = fnm_s0.F_TIME+'-'+STRMID(fnm_e0.F_TIME,11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
ftimes1        = fnm_s1.F_TIME+'-'+STRMID(fnm_e1.F_TIME,11L)
ftimes2        = fnm_s2.F_TIME+'-'+STRMID(fnm_e2.F_TIME,11L)

f_suffx0       = '_1st-BS-Crossing'
f_suffx1       = '_2nd-BS-Crossing'
f_suffx2       = '_3rd-BS-Crossing'
;;----------------------------------------------------------------------------------------
;; => Define coordinate system strings
;;----------------------------------------------------------------------------------------
coord_gse      = 'gse'
nif_suffx      = '-RHS01'
coord_nif      = 'nif_S1986a'+nif_suffx[0]
coord_ncb      = 'nif_ncb_S1986a'+nif_suffx[0]
coord_fac      = 'fac'
;;----------------------------------------------------------------------------------------
;; => Define different FGM TPLOT handles
;;----------------------------------------------------------------------------------------
mode_fgm       = ['fgs','fgl','fgh']
magname        = tnames(scpref[0]+mode_fgm+'_'+coord_gse[0])
tpnm_fgm_bmag  = tnames(scpref[0]+mode_fgm+'_mag')
tpnm_fgm_bgse  = tnames(scpref[0]+mode_fgm+'_'+coord_gse[0])
tpnm_fgm_bnif  = tnames(scpref[0]+mode_fgm+'_'+coord_nif[0])

fgs_gse_nm     = [tpnm_fgm_bmag[0],magname[0]]
fgl_gse_nm     = [tpnm_fgm_bmag[1],magname[1]]
fgh_gse_nm     = [tpnm_fgm_bmag[2],magname[2]]
fgs_nif_nm     = [tpnm_fgm_bmag[0],tpnm_fgm_bnif[0]]
fgl_nif_nm     = [tpnm_fgm_bmag[1],tpnm_fgm_bnif[1]]
fgh_nif_nm     = [tpnm_fgm_bmag[2],tpnm_fgm_bnif[2]]
;;  Set YRANGE for fgh magnitude
fgm_yra = [0d0,50d0]
options,tpnm_fgm_bmag,'YRANGE'
options,tpnm_fgm_bmag,'YRANGE',fgm_yra,/DEF
;;----------------------------------------------------------------------------------------
;; => Define different velocity moment TPLOT handles
;;----------------------------------------------------------------------------------------
vel_suffx      = '*Velocity_peib_no_GIs_UV_2'
den_suffx      = 'N_peib_no_GIs_UV'
itemp_suffx    = 'T_avg_peib_no_GIs_UV'
etemp_suffx    = 'peeb_avgtemp'

;;  Define "corrected" core ion velocity moment TPLOT handles
N_i_core       = tnames(scpref[0]+den_suffx[0])
T_i_core       = tnames(scpref[0]+itemp_suffx[0])
T_e_bulk       = tnames(scpref[0]+etemp_suffx[0])
V_i_core       = tnames(scpref[0]+vel_suffx[0])
;;----------------------------------------------------------------------------------------
;; => Define different waveform TPLOT handles
;;----------------------------------------------------------------------------------------
modes_pw       = ['p','w']
mode_efi       = 'ef'+modes_pw
mode_scm       = 'sc'+modes_pw

efw_midnm      = mode_efi[1]+'_cal_corrected_DownSampled_'+coord_ncb[0]
scw_midnm      = mode_scm[1]+'_cal_HighPass_'+coord_ncb[0]
ExB_midnm      = mode_efi[1]+'-'+mode_scm[1]+'-cal_ExB_'+coord_nif[0]
Spow_midnm     = mode_efi[1]+'-'+mode_scm[1]+'-cal_ExB-Power_'+coord_nif[0]
Edotj_midnm    = 'neg-E-dot-j_'+mode_efi[1]+'_cal_'+coord_nif[0]
jvec_midnm     = 'jvec_'+mode_fgm[2]+'_'+coord_nif[0]
jmag_midnm     = 'jmags_'+mode_fgm[2]+'_'+coord_nif[0]

scw_names      = tnames(scpref[0]+scw_midnm[0]+'_INT*')
efw_names      = tnames(scpref[0]+efw_midnm[0]+'_INT*')
ExB_names      = tnames(scpref[0]+ExB_midnm[0]+'_INT*')
Spow_names     = tnames(scpref[0]+Spow_midnm[0]+'_INT*')
Edotj_names    = tnames(scpref[0]+Edotj_midnm[0]+'_sm*')       ;;  (-Jo.∂E)  [∂E downsampled to Jo]
jvec_names     = tnames(scpref[0]+jvec_midnm[0])               ;;  j-vector
jmag_names     = tnames(scpref[0]+jmag_midnm[0])               ;;  |j|
;;  Define new TPLOT handle prefixes
jvec_prefx_US  = scpref[0]+'jvec_'+mode_fgm[2]+'_'+coord_ncb[0]+'_Upsampled_Smoothed'
Edotj_prefx    = scpref[0]+'neg-E-dot-j_'+mode_efi[1]+'_j-upsample-UpFrom128_Smooth'
Edotj_prefxcs  = scpref[0]+'neg-E-dot-j_'+mode_efi[1]+'_j-up-down-sample_CumSum_'+coord_ncb[0]
ExB_prefx_cs   = scpref[0]+mode_efi[1]+'-'+mode_scm[1]+'-cal_ExB_'+coord_nif[0]


;;----------------------------------------------------------------------------------------
;; => Add TPLOT variable where Te and Ti are together
;;----------------------------------------------------------------------------------------
temp_cols      = [250, 50]
temp_labs      = ['Te','Ti/3']
temp__yra      = [0d0,60d0]
temp_yttl      = 'Temp [eV, Burst]'
temp_ysub      = '['+thprobe[0]+', Avg., Te and Ti/3]'
Te_Ti_tpn      = scpref[0]+'Te-Ti_3_avgtemp'

get_data,T_e_bulk[0],DATA=temp0,DLIM=dlim0,LIM=lim0
get_data,T_i_core[0],DATA=temp1,DLIM=dlim1,LIM=lim1
;;  Combine
Te__t          = temp0.X
Te__v          = temp0.Y
Ti_at_Te_v     = interp(temp1.Y,temp1.X,Te__t,/NO_EXTRAP)/3d0    ;;  1/3 Ti at Te timesteps
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
;; => Add TPLOT variables where |Bo| and Bo are together
;;----------------------------------------------------------------------------------------
magf_cols      = [250,150,50,25]
magf_labs      = ['Bx','By','Bz','|B|']
magf__yra      = [-1d0,1d0]*5d1
mm             = 1L  ;; 1 for fgl, 2 for fgh
fgl_bmag_ncb   = scpref[0]+mode_fgm[mm[0]]+'_'+coord_nif[0]+'_mag'
mm             = 2L  ;; 1 for fgl, 2 for fgh
fgh_bmag_ncb   = scpref[0]+mode_fgm[mm[0]]+'_'+coord_nif[0]+'_mag'
;;  fgl [NIF and NCB]
get_data,fgl_nif_nm[0],DATA=temp0,DLIM=dlim0,LIM=lim0
get_data,fgl_nif_nm[1],DATA=temp1,DLIM=dlim1,LIM=lim1
magf_tpn       = fgl_bmag_ncb[0]

;;  fgh [NIF and NCB]
get_data,fgh_nif_nm[0],DATA=temp0,DLIM=dlim0,LIM=lim0
get_data,fgh_nif_nm[1],DATA=temp1,DLIM=dlim1,LIM=lim1
magf_tpn       = fgh_bmag_ncb[0]

;;  Combine
magf_vx        = REFORM(temp1.Y[*,0])
magf_vy        = REFORM(temp1.Y[*,1])
magf_vz        = REFORM(temp1.Y[*,2])
bmag_t         = temp0.X
bmag_v         = temp0.Y
magf_v         = [[magf_vx],[magf_vy],[magf_vz],[bmag_v]]
magf_str       = {X:bmag_t,Y:magf_v}
;;  Send to TPLOT
store_data,magf_tpn[0],DATA=magf_str,DLIM=dlim1,LIM=lim1
options,magf_tpn[0],'COLORS',magf_cols,/DEF
options,magf_tpn[0],'LABELS',magf_labs,/DEF
;;  Force YRANGE
options,magf_tpn[0],'YRANGE'
options,magf_tpn[0],'YRANGE',/DEF
options,magf_tpn[0],'YRANGE',magf__yra,/DEF
;;  Clean up
DELVAR,mm,magf_tpn,magf_vx,magf_vy,magf_vz,bmag_t,bmag_v,magf_v,magf_str
DELVAR,temp0,dlim0,lim0,temp1,dlim1,lim1

;;  Redefine TPLOT handles
fgl_bmag_ncb   = tnames(fgl_bmag_ncb[0])
fgh_bmag_ncb   = tnames(fgh_bmag_ncb[0])
;;----------------------------------------------------------------------------------------
;;  Get Jo and ∂E and upsample to ∂E time-stamps
;;----------------------------------------------------------------------------------------
;;  Get (-Jo.∂E) [NIF (NCB basis), µA m^(-2)]
get_data,Edotj_names[0],DATA=j_dot_dE_0,DLIM=dlim_jdE_0,LIM=lim_jdE_0
get_data,Edotj_names[1],DATA=j_dot_dE_1,DLIM=dlim_jdE_1,LIM=lim_jdE_1
Edotj_t0       = j_dot_dE_0.X
Edotj_v0       = j_dot_dE_0.Y[*,0]
Edotj_t1       = j_dot_dE_1.X
Edotj_v1       = j_dot_dE_1.Y[*,0]
;;  Combine two intervals
Edotj_t        = [Edotj_t0,Edotj_t1]
Edotj_v        = [Edotj_v0,Edotj_v1]
;;  Sort
sp             = SORT(Edotj_t)
Edotj_t        = Edotj_t[sp]
Edotj_v        = Edotj_v[sp]

;;  Get Jo [NIF (NCB basis), µA m^(-2)]
get_data,jvec_names[0],DATA=jvec_str_sm,DLIM=dlim_jsm,LIM=lim_jsm
jvec_t         = jvec_str_sm.X
jvec_v         = jvec_str_sm.Y

;;  Get ∂E [NIF (NCB basis), mV m^(-1)]
get_data,efw_names[0],DATA=efw_str_0,DLIM=dlim_efw_0,LIM=lim_efw_0
get_data,efw_names[1],DATA=efw_str_1,DLIM=dlim_efw_1,LIM=lim_efw_1
efw_t0         = efw_str_0.X
efw_v0         = efw_str_0.Y
efw_t1         = efw_str_1.X
efw_v1         = efw_str_1.Y
;;  Calc. sample rate
srate          = DOUBLE(sample_rate(efw_t0,GAP_THRESH=1d-3,/AVE))
;;  Combine two intervals
efw_t          = [efw_t0,efw_t1]
efw_v          = [efw_v0,efw_v1]
;;  Sort
sp             = SORT(efw_t)
efw_t          = efw_t[sp]
efw_v          = efw_v[sp,*]

;;  Define labels and variables for default LIMITS output
njdE           = N_ELEMENTS(efw_t)
low_sps        = 128d0
sr_str         = STRTRIM(STRING(DOUBLE(ROUND(srate[0])),FORMAT='(f15.1)'),2L)
dn_sr_str      = STRTRIM(STRING(DOUBLE(ROUND(low_sps[0])),FORMAT='(f15.1)'),2L)
smwidth        = ROUND(srate[0]/low_sps[0])*2L
smw_str        = STRTRIM(STRING(smwidth,FORMAT='(I)'),2L)
labs_jdE_upsam = 'Upsampled Jo: '+[sr_str[0]+'sps','Smoothed: '+smw_str[0]+'pts']
;;-----------------------------------------------------
;;  Upsample Jo and (-Jo.∂E) to ∂E time-stamps
;;-----------------------------------------------------
;;  Jo
jvecx_up       = interp(jvec_v[*,0],jvec_t,efw_t,/NO_EXTRAP)
jvecy_up       = interp(jvec_v[*,1],jvec_t,efw_t,/NO_EXTRAP)
jvecz_up       = interp(jvec_v[*,2],jvec_t,efw_t,/NO_EXTRAP)
jvec__up       = [[jvecx_up],[jvecy_up],[jvecz_up]]

dlim_j_US      = dlim_jsm
ysubt_j_US     = '['+thprobe[0]+', '+labs_jdE_upsam[0]+']'
ysubt_j_US     = ysubt_j_US[0]+'!C'+'['+labs_jdE_upsam[1]+']'
str_element,dlim_j_US,'YSUBTITLE',ysubt_j_US[0],/ADD_REPLACE
;;  Send smoothed Jo to TPLOT
jvecx_up       = SMOOTH(jvec__up[*,0],smwidth[0],/EDGE_TRUNCATE,/NAN)
jvecy_up       = SMOOTH(jvec__up[*,1],smwidth[0],/EDGE_TRUNCATE,/NAN)
jvecz_up       = SMOOTH(jvec__up[*,2],smwidth[0],/EDGE_TRUNCATE,/NAN)
jvec__up_sm    = [[jvecx_up],[jvecy_up],[jvecz_up]]

jvec_US_str    = {X:efw_t,Y:jvec__up_sm}
jvec_name_US   = jvec_prefx_US[0]+smw_str[0]        ;;  new j-vector TPLOT handle
store_data,jvec_name_US[0],DATA=jvec_US_str,DLIM=dlim_j_US,LIM=lim_jsm
;;-----------------------------------------------------
;;  Calculate (-Jo.∂E) and send to TPLOT
;;-----------------------------------------------------
jdE_fac        = -1d0*1d-6*1d-3*1d6   ;;  µA -> A, mV -> V, W -> µW
smwidth        = ROUND(srate[0]/low_sps[0])
smw_str        = STRTRIM(STRING(smwidth,FORMAT='(I)'),2L)
labs_jdE_upsam = 'Upsampled Jo: '+[sr_str[0]+'sps','Smoothed: '+smw_str[0]+'pts']
cols_jdE_upsam = [250,50]

;;  Calculate (-Jo.∂E)
j_dot_dE       = jdE_fac[0]*TOTAL(jvec__up_sm*efw_v,2,/NAN)
;;  Calculate smoothed (boxcar average) so points are at ~128 sps
j_dot_dE_sm    = SMOOTH(j_dot_dE,smwidth[0],/EDGE_TRUNCATE,/NAN)

;;  Change DLIMITS structure
dlim_j_up_dE   = dlim_jdE_0
ysubt_j_up_dE  = '['+thprobe[0]+', '+sr_str[0]+' sps]'
str_element,dlim_j_up_dE,'YSUBTITLE',ysubt_j_up_dE[0],/ADD_REPLACE
str_element,dlim_j_up_dE,'DATA_ATT.COORD_SYS','nif',/ADD_REPLACE

Edotj_upsample = Edotj_prefx[0]+smw_str[0]+'pts_'+coord_ncb[0]
;;  Send to TPLOT
jdotdE_str     = {X:efw_t,Y:[[j_dot_dE],[j_dot_dE_sm]]}
store_data,Edotj_upsample[0],DATA=jdotdE_str,DLIM=dlim_j_up_dE,LIM=lim_jdE_0
options,Edotj_upsample[0],'COLORS',cols_jdE_upsam,/DEF
options,Edotj_upsample[0],'LABELS',labs_jdE_upsam,/DEF
;;-----------------------------------------------------
;;  Send cumulative sum of (-Jo.∂E) to TPLOT
;;-----------------------------------------------------
labs_jdE_upsam = [sr_str[0]+'sps, [Cum. Sum]','Smoothed: '+smw_str[0]+'pts']
cols_jdE_upsam = [250, 50]

j_dot_dE_cs_sm = TOTAL(j_dot_dE_sm,/NAN,/CUMULATIVE)
j_dot_dE_cs_up = TOTAL(j_dot_dE,/NAN,/CUMULATIVE)
jdotdE_cs_str  = {X:efw_t,Y:[[j_dot_dE_cs_up],[j_dot_dE_cs_sm]]}

dlim_j_up_dE   = dlim_jdE_0
ysubt_j_up_dE  = '['+thprobe[0]+', '+sr_str[0]+' sps'+'!C'+'[Cumulative Sum]'
str_element,dlim_j_up_dE,'YSUBTITLE',ysubt_j_up_dE[0],/ADD_REPLACE

Edotj_upsam_cs = Edotj_prefxcs[0]
store_data,Edotj_upsam_cs[0],DATA=jdotdE_cs_str,DLIM=dlim_j_up_dE,LIM=lim_jdE_0
options,Edotj_upsam_cs[0],'LINESTYLE',2,/DEF
options,Edotj_upsam_cs[0],'COLORS',cols_jdE_upsam,/DEF
options,Edotj_upsam_cs[0],'LABELS',labs_jdE_upsam,/DEF

all_Edotj_name = [Edotj_upsample[0],Edotj_upsam_cs[0]]
options,all_Edotj_name,'YTICKLEN'
options,all_Edotj_name,'YTICKLEN',/DEF
options,all_Edotj_name,'YGRIDSTYLE'
options,all_Edotj_name,'YGRIDSTYLE',/DEF
options,all_Edotj_name,'YTICKLEN',1.0,/DEF       ;;  use full-length tick marks
options,all_Edotj_name,'YGRIDSTYLE',1,/DEF       ;;  use dotted lines
;;-----------------------------------------------------
;;  Calculate the cumulative sum for ∂S
;;-----------------------------------------------------
;;  Get ∂S [NIF (GSE basis), µW m^(-2)]
get_data,ExB_names[0],DATA=ExB_str_0,DLIM=dlim_ExB_0,LIM=lim_ExB_0
get_data,ExB_names[1],DATA=ExB_str_1,DLIM=dlim_ExB_1,LIM=lim_ExB_1
ExB_t0         = ExB_str_0.X
ExB_v0         = ExB_str_0.Y
ExB_t1         = ExB_str_1.X
ExB_v1         = ExB_str_1.Y

ExB_v0x_cs     = TOTAL(ExB_v0[*,0],/NAN,/CUMULATIVE)
ExB_v0y_cs     = TOTAL(ExB_v0[*,1],/NAN,/CUMULATIVE)
ExB_v0z_cs     = TOTAL(ExB_v0[*,2],/NAN,/CUMULATIVE)
ExB_v0_cs      = [[ExB_v0x_cs],[ExB_v0y_cs],[ExB_v0z_cs]]

ExB_v1x_cs     = TOTAL(ExB_v1[*,0],/NAN,/CUMULATIVE)
ExB_v1y_cs     = TOTAL(ExB_v1[*,1],/NAN,/CUMULATIVE)
ExB_v1z_cs     = TOTAL(ExB_v1[*,2],/NAN,/CUMULATIVE)
ExB_v1_cs      = [[ExB_v1x_cs],[ExB_v1y_cs],[ExB_v1z_cs]]
;;  Combine two intervals
ExB_t_cs       = [   ExB_t0,ExB_t1]
ExB_v_cs       = [ExB_v0_cs,ExB_v1_cs]
;;  Sort
sp             = SORT(ExB_t_cs)
ExB_t_cs       = ExB_t_cs[sp]
ExB_v_cs       = ExB_v_cs[sp,*]

dlim_ExB_cs    = dlim_ExB_0
ysubt_ExB_cs   = '['+thprobe[0]+', '+sr_str[0]+' sps'+'!C'+'[Cumulative Sum]'
str_element,dlim_ExB_cs,'YSUBTITLE',ysubt_ExB_cs[0],/ADD_REPLACE
;;  Send to TPLOT
ExB_names_cs   = ExB_prefx_cs[0]+'_CumSum'
ExB_cs_str     = {X:ExB_t_cs,Y:ExB_v_cs}
store_data,ExB_names_cs[0],DATA=ExB_cs_str,DLIM=dlim_ExB_cs,LIM=lim_ExB_0

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; => Plot velocity moment results (Figure 1)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Reset default Y-Axis tick lengths
all_mom_names  = [N_i_core[0],T_i_core[0],T_e_bulk[0],V_i_core[0]]
options,all_mom_names,'YTICKLEN'
options,all_mom_names,'YTICKLEN',/DEF
options,all_mom_names,'YTICKLEN',1.0       ;;  use full-length tick marks
options,all_mom_names,'YGRIDSTYLE',1       ;;  use dotted lines
;;  Set YRANGEs for moments
Nic_yra  = [0d0,80d0]
Tic_yra  = [0d0,20d1]
Te__yra  = [0d0,40d0]
Vic_yra  = [-350d0,100d0]
options,N_i_core[0],'MAX_VALUE',80d0,/DEF

options,N_i_core[0],'YRANGE',Nic_yra,/DEF
options,T_i_core[0],'YRANGE',Tic_yra,/DEF
options,T_e_bulk[0],'YRANGE',Te__yra,/DEF
options,V_i_core[0],'YRANGE',Vic_yra,/DEF

;;-----------------------------------------------------
;;  NIF and NCB Plots
;;-----------------------------------------------------
tz_struc       = {T0:2d2,T1:165d0,T2:135d0}
tz_stags       = TAG_NAMES(tz_struc)
FOR j=0L, 2L DO str_element,tz_struc,tz_stags[j],t_ramp0[0] + [-1d0,1d0]*tz_struc.(j),/ADD_REPLACE

tzoom          = tzoom0
tramp          = t_ramp0[0]
f_pref         = prefu[0]+'fgl-nif-ncb-mag-1_Nic_Tic_Te__Vic-gse_ALL-Zooms_'
nna            = [fgl_bmag_ncb,all_mom_names]
FOR j=0L, 2L DO BEGIN                                                     $
  tz_tra         = tz_struc.(j)                                         & $
  fnm_tra        = file_name_times(tz_tra,PREC=4)                       & $
  ftime0         = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  & $
  fname0         = f_pref[0]+ftime0+f_suffx0[0]                         & $
    tplot,nna,TRANGE=tz_tra                                             & $
  popen,fname0[0],/PORT                                                 & $
    tplot,nna,TRANGE=tz_tra                                             & $
    time_bar,tramp[0],COLOR=150                                         & $
    time_bar,REFORM(tzoom[*,0]),COLOR=250                               & $
    time_bar,REFORM(tzoom[*,1]),COLOR=250                               & $
  pclose


all_mom_names  = [N_i_core[0],Te_Ti_tpn[0],V_i_core[0]]
tzoom          = tzoom0
tramp          = t_ramp0[0]
f_pref         = prefu[0]+'fgl-nif-ncb-mag-1_Nic_Te-Tic_3__Vic-gse_ALL-Zooms_'
nna            = [fgl_bmag_ncb,all_mom_names]
FOR j=0L, 2L DO BEGIN                                                     $
  tz_tra         = tz_struc.(j)                                         & $
  fnm_tra        = file_name_times(tz_tra,PREC=4)                       & $
  ftime0         = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  & $
  fname0         = f_pref[0]+ftime0+f_suffx0[0]                         & $
    tplot,nna,TRANGE=tz_tra                                             & $
  popen,fname0[0],/PORT                                                 & $
    tplot,nna,TRANGE=tz_tra                                             & $
    time_bar,tramp[0],COLOR=150                                         & $
    time_bar,REFORM(tzoom[*,0]),COLOR=250                               & $
    time_bar,REFORM(tzoom[*,1]),COLOR=250                               & $
  pclose
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; => Plot magnetosonic-whistlers (Figure 2) with zoom to Figure 3
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Add spatial tick marks
pos_gse        = tnames(scpref[0]+'state_pos_'+coord_gse[0])
rad_pos_tpnm   = tnames(scpref[0]+'_Rad')
;; => Define TPLOT handles for spatial scales along shock normal
dtxncn_tpn     = tnames(scpref[0]+'dx_n_dt_tramp_'+coord_nif[0])
dtxnrci_tpn    = tnames(scpref[0]+'dxn_rci_dt_tramp_'+coord_nif[0])
dtxnLii_tpn    = tnames(scpref[0]+'dxn_Lii_dt_tramp_'+coord_nif[0])
;;  Define tick marks
names2         = [dtxncn_tpn[0],dtxnrci_tpn[0],dtxnLii_tpn[0],rad_pos_tpnm[0]]
tplot_options,VAR_LABEL=names2

;;-----------------------------------------------------
;;  NIF and NCB Plots
;;-----------------------------------------------------
zz_arr         = [4L,5L,6L]
tzoom          = tzoom0
tramp          = t_ramp0[0]
f_pref         = prefu[0]+'fgh-nif-ncb-mag-1_ALL-Zooms_'
nna            = fgh_bmag_ncb
FOR j=0L, 2L DO BEGIN                                                     $
  tz_tra         = REFORM(tzoom0[zz_arr[j],*])                          & $
  tzstr0         = tz_strs[zz_arr[j]]                                   & $
  fnm_tra        = file_name_times(tz_tra,PREC=4)                       & $
  ftime0         = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  & $
  fname0         = f_pref[0]+ftime0+tzstr0[0]+f_suffx0[0]               & $
    tplot,nna,TRANGE=tz_tra                                             & $
  popen,fname0[0],/PORT                                                 & $
    tplot,nna,TRANGE=tz_tra                                             & $
    time_bar,tramp[0],COLOR=150                                         & $
    time_bar,REFORM(tzoom[*,0]),COLOR=250                               & $
    time_bar,REFORM(tzoom[*,1]),COLOR=250                               & $
  pclose

;;-----------------------------------------------------
;;  NIF/NCB Plots with zoom to Figure 3
;;-----------------------------------------------------
zz_arr         = [4L,5L,6L]
tzoom          = tr_ww2
tramp          = t_ramp0[0]
fn_suffx       = 'fgh-nif-ncb-mag-1_Zoom-to-Waveforms_'
f_pref         = prefu[0]+fn_suffx[0]
nna            = fgh_bmag_ncb
FOR j=0L, 2L DO BEGIN                                                     $
  tz_tra         = REFORM(tzoom0[zz_arr[j],*])                          & $
  tzstr0         = tz_strs[zz_arr[j]]                                   & $
  fnm_tra        = file_name_times(tz_tra,PREC=4)                       & $
  ftime0         = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  & $
  fname0         = f_pref[0]+ftime0+tzstr0[0]+f_suffx0[0]               & $
    tplot,nna,TRANGE=tz_tra                                             & $
  popen,fname0[0],/PORT                                                 & $
    tplot,nna,TRANGE=tz_tra                                             & $
    time_bar,tramp[0],COLOR=150                                         & $
    time_bar,tzoom,COLOR=250                                            & $
  pclose

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; => Plot waveforms (Figure 3)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Fix Y-Ranges for better looking plots
fgm_mag_yra    = [0d0,50d0]
fgm_ncb_yra    = [-45d0,30d0]
scm_ncb_yra    = [-1d0,1d0]*1.5d0
efi_ncb_yra    = [-1d0,1d0]*375d0
ExB_nif_yra    = [-1d0,1d0]*300d0
ExB_cs_nif_yra = [-1d0,1d0]*7d3
jvec_sm_yra    = [-1d0,1d0]*15d0
Edotjsm_yra    = [-1d0,1d0]*2.75d0

options,tpnm_fgm_bmag,'YRANGE'
options,tpnm_fgm_bmag,'YRANGE',fgm_mag_yra,/DEF
options,fgh_nif_nm[1],'YRANGE'
options,fgh_nif_nm[1],'YRANGE',fgm_ncb_yra,/DEF
options,scw_names[1],'YRANGE'
options,scw_names[1],'YRANGE',scm_ncb_yra,/DEF
options,efw_names[1],'YRANGE'
options,efw_names[1],'YRANGE',efi_ncb_yra,/DEF
options,Edotj_upsample[0],'YRANGE'
options,Edotj_upsample[0],'YRANGE',Edotjsm_yra,/DEF
options,jvec_name_US[0],'YRANGE'
options,jvec_name_US[0],'YRANGE',jvec_sm_yra,/DEF
options,ExB_names[1],'YRANGE'
options,ExB_names[1],'YRANGE',ExB_nif_yra,/DEF
options,ExB_names_cs[0],'YRANGE'
options,ExB_names_cs[0],'YRANGE',ExB_cs_nif_yra,/DEF
;;  Define TPLOT handles
fgh_nna        = fgh_bmag_ncb
field_tpn      = [fgh_nna,scw_names[1],efw_names[1]]
jvec_tpn       = tnames(jvec_name_US[0])
Edotj_tpn      = tnames(Edotj_upsample[0])
;;  Define time ranges for plot
tz_tra         = tr_ww2
tramp          = t_ramp0[0]
tzoom          = [[tr_esw0],[tr_esw1],[tr_esw2],[tr_whi]]
tzoom          = TRANSPOSE(tzoom)
fnm_tra        = file_name_times(tz_tra,PREC=4)
ftime0         = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
;;  Define TPLOT handles and associated file names
fn_midSP       = ['Spow-NIF','Svec-NIF-CS']
poyn_tpn       = [Spow_names[1],ExB_names_cs[0]]      ;;  Choose |S(w,k)| or S
fn_midfx       = 'fgh-nif-ncb-mag-1_'
fn_suffx       = 'scw-efw-NIF-NCB_'+fn_midSP+'_jvec_neg-E.j-upsampled_Wave-Zooms_'
f_pref         = prefu[0]+fn_midfx[0]+fn_suffx
FOR j=0L, 1L DO BEGIN                                                     $
  nna            = [field_tpn,poyn_tpn[j],jvec_tpn[0],Edotj_tpn[0]]     & $
  fname0         = f_pref[j]+ftime0+f_suffx0[0]                         & $
    tplot,nna,TRANGE=tz_tra                                             & $
  popen,fname0[0]+'_Portrait',/PORT                                     & $
    tplot,nna,TRANGE=tz_tra                                             & $
    time_bar,REFORM(tzoom[*,0]),COLOR=250                               & $
    time_bar,REFORM(tzoom[*,1]),COLOR=250                               & $
    time_bar,tramp[0],COLOR=150                                         & $
  pclose                                                                & $
  popen,fname0[0]+'_Landscape',/LAND                                    & $
    tplot,nna,TRANGE=tz_tra                                             & $
    time_bar,REFORM(tzoom[*,0]),COLOR=250                               & $
    time_bar,REFORM(tzoom[*,1]),COLOR=250                               & $
    time_bar,tramp[0],COLOR=150                                         & $
  pclose

;;----------------------------------------------------------------------------------------
;; => Plot cumulative sum of (-Jo.∂E) [with upsampled Jo]
;;----------------------------------------------------------------------------------------
tramp          = t_ramp0[0]
tz_tra         = tr_ww2
fnm_tra        = file_name_times(tz_tra,PREC=4)
ftime0         = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
f_pref         = prefu[0]+'fgh-nif-ncb-mag-1_neg-E-dot-j_DownSamp-UpSamp-CumSum_'
fname0         = f_pref[0]+ftime0+f_suffx0[0]

all_Edotj_name = [Edotj_upsample[0],Edotj_upsam_cs[0]]
nna            = [fgh_bmag_ncb,all_Edotj_name]

options,all_Edotj_name,'YRANGE'
options,all_Edotj_name,'YRANGE',/DEF
options,all_Edotj_name[1],'YMINOR'
options,all_Edotj_name[1],'YMINOR',/DEF

options,all_Edotj_name[0],'YRANGE',[-1d0,1d0]*3.0,/DEF
options,all_Edotj_name[1],'YRANGE',[-1d0,1d0]*20d1,/DEF
options,all_Edotj_name[1],'YTICKS',8,/DEF
options,all_Edotj_name[1],'YMINOR',10,/DEF


  tplot,nna,TRANGE=tz_tra
  time_bar,tramp[0],COLOR=150
popen,fname0[0]+'_PORT',/PORT
  tplot,nna,TRANGE=tz_tra
  time_bar,tramp[0],COLOR=150
pclose

popen,fname0[0]+'_LAND',/LAND
  tplot,nna,TRANGE=tz_tra
  time_bar,tramp[0],COLOR=150
pclose















































































































































































