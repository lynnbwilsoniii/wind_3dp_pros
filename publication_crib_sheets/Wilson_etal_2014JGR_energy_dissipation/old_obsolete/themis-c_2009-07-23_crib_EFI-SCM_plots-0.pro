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
tdate          = '2009-07-23'
tr_00          = tdate[0]+'/'+['12:00:00','21:00:00']
date           = '072309'
probe          = 'c'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
t_ramp         = MEAN(time_double(tdate[0]+'/'+['18:04:47.030','18:04:58.920']),/NAN)
;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
;; => Restore TPLOT session
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
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Moment Plots ['+tdate[0]+']'

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01

coord          = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
modes_pw       = ['p','w']
mode_efi       = 'ef'+modes_pw
mode_scm       = 'sc'+modes_pw
velname        = pref[0]+'peib_velocity_'+coord[0]
magname        = pref[0]+'fgh_'+coord[0]
fgmnm          = pref[0]+'fgh_'+['mag',coord[0]]
tr_jj          = time_double(tdate[0]+'/'+['17:57:30','18:30:00'])

tplot,fgmnm,TRANGE=tr_jj
;;----------------------------------------------------------------------------------------
;; => Calibrate and Rotate SCM and EFI [1st shock solutions]
;;----------------------------------------------------------------------------------------
;; => Avg. terms [1st Shock]
;;  Shock Parameters
vshn_up        =  -62.20746d0
ushn_up        = -423.04605d0
ushn_dn        = -103.10110d0
gnorm          = [0.99518093d0,0.021020125d0,0.011474467d0]  ;; GSE
theta_Bn       =   88.569206d0
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-488.290d0,82.8993d0,-92.3297d0]
vswi_dn        = [-167.447d0,102.874d0,-72.4411d0]
magf_up        = [-0.0836601d0,0.112276d0,-6.04225d0]
magf_dn        = [-1.17367d0,2.16511d0,-19.2497d0]
dens_up        =    3.73654d0
dens_dn        =   15.39110d0
Ti___up        =   65.32560d0
Ti___dn        =  279.72000d0
Te___up        =    9.42997d0
Te___dn        =   51.72050d0

;;  Define RH Parameter Structure
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)

coord_in       = 'gse'
vsw_tpnm       = tnames(pref[0]+coord_in[0]+'_Velocity_peib_no_GIs_UV_2')
tramp          = t_ramp[0]
nsm            = 10L
nif_suffx      = '-RHS01'
gint           = [0L,5L,6L]

.compile temp_thm_cal_rot_ebfields
.compile temp_calc_j_S_nif_etc
temp_thm_cal_rot_ebfields,PROBE=sc[0],TRANGE=tr_jj,NIF_STR=nif_str,$
                          VSW_TPNM=vsw_tpnm,TRAMP=tramp,NSM=nsm,   $
                          GINT=gint,NIF_SUFFX=nif_suffx[0]
;;----------------------------------------------------------------------------------------
;; => Calibrate and Rotate SCM and EFI [2nd shock solutions]
;;----------------------------------------------------------------------------------------
;; => Avg. terms [2nd Shock]
;;  Shock Parameters
vshn_up        =  -33.929926d0
ushn_up        = -415.524900d0
ushn_dn        = -151.380920d0
gnorm          = [0.99282966d0,0.064151304d0,-0.0022364971d0]
theta_Bn       =   56.199579d0
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-456.419d0,57.8130d0,7.73230d0]
vswi_dn        = [-191.874d0,80.5858d0,-7.70972d0]
magf_up        = [3.88880d0,-4.95385d0,1.12260d0]
magf_dn        = [4.13227d0,-15.5434d0,2.96303d0]
dens_up        =    3.88664d0
dens_dn        =   10.91260d0
Ti___up        =   53.45130d0
Ti___dn        =  311.05000d0
Te___up        =   14.07640d0
Te___dn        =   56.78900d0

;;  Define RH Parameter Structure
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)

coord_in       = 'gse'
vsw_tpnm       = tnames(pref[0]+coord_in[0]+'_Velocity_peib_no_GIs_UV_2')
tramp          = t_ramp[0]
nsm            = 10L
nif_suffx      = '-RHS02'
gint           = [0L,5L,6L]
;;  Only call 2nd half of program
efi_name       = tnames(pref[0]+mode_efi[1]+'_cal_corrected_DownSampled_'+coord_in[0]+'_INT*')
scm_name       = tnames(pref[0]+mode_scm[1]+'_cal_HighPass_'+coord_in[0]+'_INT*')
get_data,efi_name[0],DATA=efw,DLIM=dlime,LIM=lime
get_data,scm_name[0],DATA=scw,DLIM=dlimb,LIM=limb
smrate         = DOUBLE(ROUND(sample_rate(efw.X,GAP_THRESH=2d0,/AVE)))
smratb         = DOUBLE(ROUND(sample_rate(scw.X,GAP_THRESH=2d0,/AVE)))

.compile temp_calc_j_S_nif_etc
temp_calc_j_S_nif_etc,PROBE=sc[0],TRANGE=tr_jj,NIF_STR=nif_str,       $
                      VSW_TPNM=vsw_tpnm,TRAMP=tramp[0],NSM=nsm,       $
                      GINT=gint,NIF_SUFFX=nif_suffx,                  $
                      SRATE_E=smrate[0],SRATE_B=smratb[0]























































































;;----------------------------------------------------------------------------------------
;;  Rename TPLOT handles [1st shock solution names]
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
modes_pw       = ['p','w']
mode_efi       = 'ef'+modes_pw
mode_scm       = 'sc'+modes_pw
coord_in       = 'gse'
efpref         = pref[0]+mode_efi[1]+'_cal_corrected_DownSampled_'+coord_in[0]
bfpref         = pref[0]+mode_scm[1]+'_cal_NoCutoff_'+coord_in[0]
sfpref         = pref[0]+'S_'+'_TimeSeries_'+coord_in[0]
tp_prefs       = [efpref[0],bfpref[0],sfpref[0]]

n_int          = N_ELEMENTS(tnames(efpref[0]+'_INT*'))
ind            = LINDGEN(n_int)
s_ind          = STRTRIM(STRING(ind,FORMAT='(I3.3)'),2L)
isuffx         = '_INT'+s_ind

nsm            = 10L
nsms           = STRING(FORMAT='(I3.3)',nsm[0])
sm_suffx       = '_sm'+nsms[0]+'pts'

sc             = probe[0]
pref           = 'th'+sc[0]+'_'
coord__in      = 'nif_S1986a'
coord_out      = 'nif-0_S1986a'
fgm_modes      = ['fgs_','fgl_','fgh_']
efi_modes      = 'ef'+['p_','w_']+'cal'
scm_modes      = 'sc'+['p_','w_']

mid_dx         = ['dx_n_dt_tramp','dxn_rci_dt_tramp','dxn_Lii_dt_tramp']
mid_vnif       = 'peib_velocity_'+coord__in[0]
mid_fgm        = fgm_modes+coord__in[0]
mid_jmag       = 'jmags_'+fgm_modes[2]+coord__in[0]+['','_squared']
mid_jvec       = 'jvec_'+fgm_modes[2]+coord__in[0]+['',sm_suffx[0]]
mid_jmagsm     = mid_jmag+sm_suffx[0]
mid_efp        = efi_modes[0]+'_'+coord__in[0]
mid_efw        = efi_modes[1]+'_'+'corrected_DownSampled_'+coord__in[0]
mid_svec       = 'efw-scw-cal_ExB_'+coord__in[0]
mid_spow       = 'efw-scw-cal_ExB-Power_'+coord__in[0]
mid_Sdotn      = 'n-dot-S'
mid_Edotj      = 'neg-E-dot-j_'+efi_modes+sm_suffx[0]

tpn_dx         = tnames(pref[0]+mid_dx        )
tpn_vnif       = tnames(pref[0]+mid_vnif      )
tpn_fgm        = tnames(pref[0]+mid_fgm       )
tpn_jmag       = tnames(pref[0]+mid_jmag      )
tpn_jvec       = tnames(pref[0]+mid_jvec      )
tpn_jmagsm     = tnames(pref[0]+mid_jmagsm    )
tpn_efp        = tnames(pref[0]+mid_efp+'*'   )
tpn_efw        = tnames(pref[0]+mid_efw+'*'   )
tpn_svec       = tnames(pref[0]+mid_svec+'*'  )
tpn_spow       = tnames(pref[0]+mid_spow+'*'  )
tpn_Sdotn      = tnames(pref[0]+mid_Sdotn+'*' )
tpn_Edotj      = tnames(pref[0]+mid_Edotj+'*' )

HELP, tpn_efp, tpn_efw, tpn_svec, tpn_spow, tpn_sdotn, tpn_edotj




;;-----------------------------------------------------------
;;  Remove unnecessary TPLOT handles
;;-----------------------------------------------------------
;;  Only need interval 0 [Wave Burst]
test           = (ind EQ 0)
good           = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
PRINT,';;  ', gd, bd
;;             1           6

del_data,'*_efw_*'+isuffx[bad]
del_data,'*_scw_*'+isuffx[bad]
del_data,'*_S__TimeSeries_*'+isuffx[bad]

;;  Only need interval 0 [Particle Burst]
good           = WHERE(ind EQ 0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
del_data,'*_efp_*'+isuffx[bad]
del_data,'*_scp_*'+isuffx[bad]


;;----------------------------------------------------------------------------------------
;; => Calibrate and Rotate SCM and EFI [2nd shock solutions]
;;----------------------------------------------------------------------------------------
;; => Avg. terms [2nd Shock]
;;  Shock Parameters
vshn_up        = 
ushn_up        = 
ushn_dn        = 
gnorm          = 
theta_Bn       = 
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-488.290d0,82.8993d0,-92.3297d0]
vswi_dn        = [-167.447d0,102.874d0,-72.4411d0]
magf_up        = [-0.0836601d0,0.112276d0,-6.04225d0]
magf_dn        = [-1.17367d0,2.16511d0,-19.2497d0]
dens_up        =    3.73654d0
dens_dn        =   15.39110d0
Ti___up        =   65.32560d0
Ti___dn        =  279.72000d0
Te___up        =    9.42997d0
Te___dn        =   51.72050d0

;;  Define RH Parameter Structure
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)

coord_in       = 'gse'
vsw_tpnm       = tnames(pref[0]+coord_in[0]+'_Velocity_peib_no_GIs_UV_2')
tramp          = t_ramp[0]
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

;;  Only need intervals 5 and 6 [Wave Burst]
test           = (ind EQ 5) OR (ind EQ 6)
good           = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
PRINT,';;  ', gd, bd
;;             3           4

del_data,'*_efw_*'+isuffx[bad]
del_data,'*_scw_*'+isuffx[bad]
del_data,'*_S__TimeSeries_*'+isuffx[bad]

;;  Only need interval 1 [Particle Burst]
good           = WHERE(ind EQ 1,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
del_data,'*_efp_*'+isuffx[bad]
del_data,'*_scp_*'+isuffx[bad]


;;----------------------------------------------------------------------------------------
;; => Calculate [(n . S) n] and [n x (S x n)]  [µW m^(-2)]
;;----------------------------------------------------------------------------------------
;; => Avg. terms [1st Shock]
gnorm          = [0.99518093d0,0.021020125d0,0.011474467d0]  ;; GSE
mu__str        = get_greek_letter('mu')
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
coord_in       = 'gse'
coord_out      = 'nif_S1986a'
mid_nmsV       = 'efw-scw-cal_ExB_'

out_SnameV     = tnames(pref[0]+mid_nmsV[0]+coord_out[0]+'_*')
gposi          = STRPOS(out_SnameV,'_INT')
n_pint         = N_ELEMENTS(gposi)
tsuffix        = STRARR(n_pint)
int_snum       = STRARR(n_pint)
FOR j=0L, n_pint - 1L DO tsuffix[j] = STRMID(out_SnameV[j],gposi[j])
gposi          = STRPOS(tsuffix,'0')
FOR j=0L, n_pint - 1L DO int_snum[j] = STRMID(tsuffix[j],gposi[j])


tvbasis        = 'GSE'
tvframe        = 'NIF'
mid_nt         = ['ndotS-n','nxSxn']+'_'+coord_out[0]
tvout_n        = pref[0]+mid_nt[0]+tsuffix
tvout_t        = pref[0]+mid_nt[1]+tsuffix
yttlen         = '(n . S) n ['+mu__str[0]+'W/m!U-2!N'+']'
yttlet         = 'n x (n x S) ['+mu__str[0]+'W/m!U-2!N'+']'
nvec           = gnorm
FOR j=0L, 0L DO BEGIN  $
  test = t_calc_trans_norm(out_SnameV[j],nvec,OUT_TNMN=tvout_n[j],OUT_TNMT=tvout_t[j],$
                           TV_BASIS=tvbasis[0],TV_FRAME=tvframe[0],$
                           OUT_YTLN=yttlen[0],OUT_YTLT=yttlet[0])


;; => Avg. terms [2nd Shock]
gnorm          = [0.99518093d0,0.021020125d0,0.011474467d0]  ;; GSE


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
;; => Load E&B-Fields
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
;       227840      261120      227840      625905

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









;;-----------------------------------------------------------
;;  Save corrected fields
;;-----------------------------------------------------------
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
















