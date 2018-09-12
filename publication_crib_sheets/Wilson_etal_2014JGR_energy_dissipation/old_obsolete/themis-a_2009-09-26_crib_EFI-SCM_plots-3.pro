;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
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

; => Compile necessary routines
@comp_lynn_pros
thm_init
; => Date/Time and Probe
tdate          = '2009-09-26'
tr_00          = tdate[0]+'/'+['12:00:00','17:40:00']
date           = '092609'
probe          = 'a'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
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
names          = [pref[0]+'_Rad',pos_gse[0]+['_x','_y','_z']]
tplot_options,VAR_LABEL=names
options,tnames(),'LABFLAG',2,/DEF

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='EFI & SCM Plots'

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
tr_jj          = time_double(tdate[0]+'/'+['15:48:20','15:58:25'])

tplot,fgmnm,TRANGE=tr_jj




























;;----------------------------------------------------------------------------------------
;; => Fix NIF rotations
;;----------------------------------------------------------------------------------------
evxbfac        = -1d0*1d3*1d-9*1d3  ;;  km/s -> m/s, nT -> T, V/m -> mV/m

vshn_up        =   -0.34323890d0
ushn_up        = -309.10030d0
gnorm          = [0.97873770d0,-0.11229654d0,-0.059902080d0]
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn)

;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-306.830d0,65.3250d0,30.0793d0]
vswi_dn        = [-66.1083d0,50.1763d0,-6.33199d0]
magf_up        = [2.03877d0,-0.451179d0,-3.02909d0]
magf_dn        = [-0.601265d0,-15.0333d0,-4.21656d0]
;; Calculate V_NIF
;;    V_NIF = n x (V_u x n)
;;          = n x [(Vsw - Vsh n) x n]
;;          = n x (Vsw x n) - Vsh [n x (n x n)]
;;          = n x (Vsw x n)
pref           = 'th'+sc[0]+'_'
coord_in       = ['gse','fac','nif']
vsw_name       = tnames(pref[0]+coord_in[0]+'_Velocity_peib_no_GIs_UV_2')
fglgse         = tnames(pref[0]+'fgl_'+coord_in[0])
get_data,vsw_name[0],DATA=vsw_str,DLIM=dlim__v,LIM=lim__v
get_data,fglgse[0],DATA=fgl_str,DLIM=dlim_Bo,LIM=lim_Bo
;; interpolate Bo to ion timestamps
nvsw           = N_ELEMENTS(vsw_str.X)
tempx          = interp(fgl_str.Y[*,0],fgl_str.X,vsw_str.X,/NO_EXTRAP)
tempy          = interp(fgl_str.Y[*,1],fgl_str.X,vsw_str.X,/NO_EXTRAP)
tempz          = interp(fgl_str.Y[*,2],fgl_str.X,vsw_str.X,/NO_EXTRAP)
magf_it        = [[tempx],[tempy],[tempz]]

;;  V_u     = Vsw - (Vsh n)
;;          = upstream bulk velocity in shock rest frame
u_norm         = gnorm/NORM(REFORM(gnorm))  ;; normalized
tempx          = vsw_str.Y[*,0] - vshn_up[0]*u_norm[0]
tempy          = vsw_str.Y[*,1] - vshn_up[0]*u_norm[1]
tempz          = vsw_str.Y[*,2] - vshn_up[0]*u_norm[2]
V_u            = [[tempx],[tempy],[tempz]]
;;    V_NIF = n x (V_u x n)
;;          = transformation velocity into the NIF
nxVuxn         = my_crossp_2(u_norm,my_crossp_2(V_u,u_norm,/NOM),/NOM)
;;    U_NIF = V_u - V_NIF
;;          = bulk velocity in the NIF
U_NIF          = V_u - nxVuxn
;;    E_NIF = -(U_NIF x B_u)
;;          = convection electric field in the NIF
E_NIF          = evxbfac[0]*my_crossp_2(U_NIF,magf_up,/NOM)


nxVxn          = my_crossp_2(u_norm,my_crossp_2(vsw_str.Y,u_norm,/NOM),/NOM)
vsh_nhat       = REPLICATE(1d0,nvsw) # (vshn_up[0]*u_norm)
;; convection velocity [km/s]
;;  V_conv = Vsh n + V_NIF
V_conv         = vsh_nhat + nxVxn
;; convection E-field [mV/m]
E_conv         = evxbfac[0]*my_crossp_2(V_conv,magf_it,/NOM)

;; construct rotation matrix
;;    V_NIF = n x (V_u x n)
v_nif08        = my_crossp_2(u_norm,my_crossp_2(vswi_up,u_norm,/NOM),/NOM)
;;    V'    = (Vsh n) + V_NIF
v_tran08       = vshn_up[0]*u_norm + v_nif08
;;    E_NIF = E_sc + (V' x Bo)
e_tran08       = evxbfac[0]*my_crossp_2(v_tran08,magf_u,/NOM)
u_e_tr08       = e_tran08/NORM(REFORM(e_tran08))  ;; normalized
;;    E_sc  = -(Vsw x Bo)
e_conv_sw      = -1d0*my_crossp_2(vsw_up,magf_u,/NOM)
e_cnmagsw      = NORM(REFORM(e_conv_sw))
u_e_conv_sw    = e_conv_sw/e_cnmagsw  ;; normalized


;; => Y'-vector
yvect          = my_crossp_2(magf_dn,magf_up,/NOM)
yvnor          = yvect/NORM(REFORM(yvect))
;; => Z'-vector
zvect          = my_crossp_2(u_norm,yvnor,/NOM)
zvnor          = zvect/NORM(REFORM(zvect))
;; => Rotation Matrix from NIF to GSE
rotgse         = TRANSPOSE([[u_norm],[u_e_conv_sw],[u_bmax]])
;; => Define rotation from GSE to NIF
rotnif         = LA_INVERT(rotgse)
PRINT,rotnif




;;----------------------------------------------------------------------------------------
;; => Calculate S = (E x B)/µ_o [Time Domain]
;;----------------------------------------------------------------------------------------
sfac           = 1d-3*1d-9*1d6/muo[0]       ;; mV->V, nT->T, W->µW, divide by µ_o
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
coord_in       = ['gse','fac','nif']
;; Calc. sample rates [sps]
get_data,(tnames(pref[0]+'scp_cal_dsl'))[0],DATA=tempb
get_data,(tnames(pref[0]+'efp_cal_dsl'))[0],DATA=tempe
srate_scp      = DOUBLE(ROUND(sample_rate(tempb.X,GAP_THRESH=2d0,/AVE)))
srate_efp      = DOUBLE(ROUND(sample_rate(tempe.X,GAP_THRESH=2d0,/AVE)))
PRINT,';;  ', srate_scp[0], srate_efp[0]
;;         128.00000       128.00000

get_data,(tnames(pref[0]+'scw_cal_dsl'))[0],DATA=tempb
get_data,(tnames(pref[0]+'efw_cal_dsl_corrected_DownSampled'))[0],DATA=tempe
srate_scw      = DOUBLE(ROUND(sample_rate(tempb.X,GAP_THRESH=2d0,/AVE)))
srate_efw      = DOUBLE(ROUND(sample_rate(tempe.X,GAP_THRESH=2d0,/AVE)))
PRINT,';;  ', srate_scw[0], srate_efw[0]
;;         8192.0000       8192.0000

srate_pstr     = STRTRIM(STRING(srate_scp[0],FORMAT='(f15.0)'),2L)
srate_wstr     = STRTRIM(STRING(srate_scw[0],FORMAT='(f15.0)'),2L)
;; remove '.'
srate_pstr     = STRMID(srate_pstr[0],0L,STRLEN(srate_pstr[0]) - 1L)
srate_wstr     = STRMID(srate_wstr[0],0L,STRLEN(srate_wstr[0]) - 1L)

;;------------------------------------
;;  Particle Burst
;;------------------------------------
scp_pref       = pref[0]+'scp_cal_'
efp_pref       = pref[0]+'efp_cal_'
scp_suff       = coord_in+'_INT*'
efp_suff       = coord_in+'_INT*'
scp_gse_names  = tnames(scp_pref[0]+scp_suff[0])
efp_gse_names  = tnames(efp_pref[0]+efp_suff[0])
scp_fac_names  = tnames(scp_pref[0]+scp_suff[1])
efp_fac_names  = tnames(efp_pref[0]+efp_suff[1])
scp_nif_names  = tnames(scp_pref[0]+scp_suff[2])
efp_nif_names  = tnames(efp_pref[0]+efp_suff[2])
scp_name_str   = {T0:scp_gse_names,T1:scp_fac_names,T2:scp_nif_names}
efp_name_str   = {T0:efp_gse_names,T1:efp_fac_names,T2:efp_nif_names}
n_pint         = N_ELEMENTS(scp_gse_names)  ;; # of SCP time intervals
;;  Define output names
tsuffix        = '_INT'+STRING(LINDGEN(n_pint),FORMAT='(I3.3)')
sfp_gse_out    = pref[0]+'efp-scp-cal_ExB_'+coord_in[0]+tsuffix
sfp_fac_out    = pref[0]+'efp-scp-cal_ExB_'+coord_in[1]+tsuffix
sfp_nif_out    = pref[0]+'efp-scp-cal_ExB_'+coord_in[2]+tsuffix
sfp_name_str   = {T0:sfp_gse_out,T1:sfp_fac_out,T2:sfp_nif_out}
;;  Define output structures
data_att_gse   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[0],UNITS:'microW/m^2'}
data_att_fac   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[1],UNITS:'microW/m^2'}
data_att_nif   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[2],UNITS:'microW/m^2'}
data_att_s     = {T0:data_att_gse,T1:data_att_fac,T2:data_att_nif}
;;  Calculate S [µW m^(-2)]
FOR i=0L, 2L DO BEGIN                                                 $
  scp_names = scp_name_str.(i)                                      & $
  efp_names = efp_name_str.(i)                                      & $
  data_atts = data_att_s.(i)                                        & $
  sfp_nmout = sfp_name_str.(i)                                      & $
  yttl_out  = 'S ['+STRUPCASE(coord_in[i])+', 10^(-6) W/m^2]'       & $
  FOR j=0L, n_pint - 1L DO BEGIN                                      $
    get_data,scp_names[j],DATA=t_scp,DLIM=dlimb,LIM=limb            & $
    get_data,efp_names[j],DATA=t_efp,DLIM=dlime,LIM=lime            & $
    tempx        = interp(t_efp.Y[*,0],t_efp.X,t_scp.X,/NO_EXTRAP)  & $
    tempy        = interp(t_efp.Y[*,1],t_efp.X,t_scp.X,/NO_EXTRAP)  & $
    tempz        = interp(t_efp.Y[*,2],t_efp.X,t_scp.X,/NO_EXTRAP)  & $
    tempef       = [[tempx],[tempy],[tempz]]                        & $
    sfp_dat      = my_crossp_2(tempef,t_scp.Y,/NOM)*sfac[0]         & $
    t_sfp        = {X:t_scp.X,Y:sfp_dat}                            & $
    dlims        = dlimb                                            & $
    str_element,dlims,'DATA_ATT',data_atts,/ADD_REPLACE             & $
    str_element,dlims,'YTITLE',yttl_out[0],/ADD_REPLACE             & $
    str_element,dlims,'CDF',/DELETE                                 & $
    store_data,sfp_nmout[j],DATA=t_sfp,DLIM=dlims,LIM=limb

;;------------------------------------
;; Wave Burst
;;------------------------------------
scw_pref       = pref[0]+'scw_cal_HighPass_'
efw_pref       = pref[0]+'efw_cal_corrected_DownSampled_'
scw_suff       = coord_in+'_INT*'
efw_suff       = coord_in+'_INT*'
scw_gse_names  = tnames(scw_pref[0]+scw_suff[0])
efw_gse_names  = tnames(efw_pref[0]+efw_suff[0])
scw_fac_names  = tnames(scw_pref[0]+scw_suff[1])
efw_fac_names  = tnames(efw_pref[0]+efw_suff[1])
scw_nif_names  = tnames(scw_pref[0]+scw_suff[2])
efw_nif_names  = tnames(efw_pref[0]+efw_suff[2])
scw_name_str   = {T0:scw_gse_names,T1:scw_fac_names,T2:scw_nif_names}
efw_name_str   = {T0:efw_gse_names,T1:efw_fac_names,T2:efw_nif_names}
n_wint         = N_ELEMENTS(scw_gse_names)  ;; # of SCW time intervals
;;  Define output names
tsuffix        = '_INT'+STRING(LINDGEN(n_wint),FORMAT='(I3.3)')
sfw_gse_out    = pref[0]+'efw-scw-cal_ExB_'+coord_in[0]+tsuffix
sfw_fac_out    = pref[0]+'efw-scw-cal_ExB_'+coord_in[1]+tsuffix
sfw_nif_out    = pref[0]+'efw-scw-cal_ExB_'+coord_in[2]+tsuffix
sfw_name_str   = {T0:sfw_gse_out,T1:sfw_fac_out,T2:sfw_nif_out}
;;  Define output structures
data_att_gse   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[0],UNITS:'microW/m^2'}
data_att_fac   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[1],UNITS:'microW/m^2'}
data_att_nif   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[2],UNITS:'microW/m^2'}
data_att_s     = {T0:data_att_gse,T1:data_att_fac,T2:data_att_nif}
;;  Calculate S [µW m^(-2)]
FOR i=0L, 2L DO BEGIN                                                 $
  scw_names = scw_name_str.(i)                                      & $
  efw_names = efw_name_str.(i)                                      & $
  data_atts = data_att_s.(i)                                        & $
  sfw_nmout = sfw_name_str.(i)                                      & $
  yttl_out  = 'S ['+STRUPCASE(coord_in[i])+', 10^(-6) W/m^2]'       & $
  FOR j=0L, n_wint - 1L DO BEGIN                                      $
    get_data,scw_names[j],DATA=t_scw,DLIM=dlimb,LIM=limb            & $
    get_data,efw_names[j],DATA=t_efw,DLIM=dlime,LIM=lime            & $
    tempx        = interp(t_efw.Y[*,0],t_efw.X,t_scw.X,/NO_EXTRAP)  & $
    tempy        = interp(t_efw.Y[*,1],t_efw.X,t_scw.X,/NO_EXTRAP)  & $
    tempz        = interp(t_efw.Y[*,2],t_efw.X,t_scw.X,/NO_EXTRAP)  & $
    tempef       = [[tempx],[tempy],[tempz]]                        & $
    sfw_dat      = my_crossp_2(tempef,t_scw.Y,/NOM)*sfac[0]         & $
    t_sfw        = {X:t_scw.X,Y:sfw_dat}                            & $
    dlims        = dlimb                                            & $
    str_element,dlims,'DATA_ATT',data_atts,/ADD_REPLACE             & $
    str_element,dlims,'YTITLE',yttl_out[0],/ADD_REPLACE             & $
    str_element,dlims,'CDF',/DELETE                                 & $
    store_data,sfw_nmout[j],DATA=t_sfw,DLIM=dlims,LIM=limb
;;----------------------------------------------------------------------------------------
;; => Calculate S = (E x B)/µ_o [Frequency Domain]
;;----------------------------------------------------------------------------------------
sfac           = 1d-3*1d-9*1d6/muo[0]       ;; mV->V, nT->T, W->µW, divide by µ_o
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
coord_in       = ['gse','fac','nif']

;;------------------------------------
;;  Particle Burst
;;------------------------------------
nfft           = 32L
nshft          = 8L
flow           = 0d0
yttl_out       = '|S| [Freq. Power, 10^(-6) W/m^2]'
ysub           = '[th'+sc[0]+' '+srate_pstr[0]+'sps, 32 Fbins, 8 pt-shift]'

scp_pref       = pref[0]+'scp_cal_'
efp_pref       = pref[0]+'efp_cal_'
scp_suff       = coord_in+'_INT*'
efp_suff       = coord_in+'_INT*'
scp_gse_names  = tnames(scp_pref[0]+scp_suff[0])
efp_gse_names  = tnames(efp_pref[0]+efp_suff[0])
scp_fac_names  = tnames(scp_pref[0]+scp_suff[1])
efp_fac_names  = tnames(efp_pref[0]+efp_suff[1])
scp_nif_names  = tnames(scp_pref[0]+scp_suff[2])
efp_nif_names  = tnames(efp_pref[0]+efp_suff[2])
scp_name_str   = {T0:scp_gse_names,T1:scp_fac_names,T2:scp_nif_names}
efp_name_str   = {T0:efp_gse_names,T1:efp_fac_names,T2:efp_nif_names}
n_pint         = N_ELEMENTS(scp_gse_names)  ;; # of SCP time intervals
;;  Define output names
tsuffix        = '_INT'+STRING(LINDGEN(n_pint),FORMAT='(I3.3)')
sfp_gse_out    = pref[0]+'efp-scp-cal_ExB-Power_'+coord_in[0]+tsuffix
sfp_fac_out    = pref[0]+'efp-scp-cal_ExB-Power_'+coord_in[1]+tsuffix
sfp_nif_out    = pref[0]+'efp-scp-cal_ExB-Power_'+coord_in[2]+tsuffix
sfp_name_str   = {T0:sfp_gse_out,T1:sfp_fac_out,T2:sfp_nif_out}
;;  Define output structures
data_att_gse   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[0],UNITS:'microW/m^2'}
data_att_fac   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[1],UNITS:'microW/m^2'}
data_att_nif   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[2],UNITS:'microW/m^2'}
data_att_s     = {T0:data_att_gse,T1:data_att_fac,T2:data_att_nif}
;;  Calculate S [µW m^(-2)]
FOR i=0L, 2L DO BEGIN                                                 $
  scp_names = scp_name_str.(i)                                      & $
  efp_names = efp_name_str.(i)                                      & $
  data_atts = data_att_s.(i)                                        & $
  sfp_nmout = sfp_name_str.(i)                                      & $
  FOR j=0L, n_pint - 1L DO BEGIN                                      $
    get_data,scp_names[j],DATA=t_scp,DLIM=dlimb,LIM=limb            & $
    get_data,efp_names[j],DATA=t_efp,DLIM=dlime,LIM=lime            & $
    tempx        = interp(t_efp.Y[*,0],t_efp.X,t_scp.X,/NO_EXTRAP)  & $
    tempy        = interp(t_efp.Y[*,1],t_efp.X,t_scp.X,/NO_EXTRAP)  & $
    tempz        = interp(t_efp.Y[*,2],t_efp.X,t_scp.X,/NO_EXTRAP)  & $
    tempef       = [[tempx],[tempy],[tempz]]                        & $
    efp2         = {X:t_scp.X,Y:tempef}                             & $
    temp         = calc_poynting_flux_freq(efp2,t_scp,FLOW=flow[0],NFFT=nfft[0],NSHFT=nshft[0])  & $
    dlims        = dlimb                                            & $
    str_element,dlims,'DATA_ATT',data_atts,/ADD_REPLACE             & $
    str_element,dlims,'YTITLE',yttl_out[0],/ADD_REPLACE             & $
    str_element,dlims,'YSUBTITLE',ysub[0],/ADD_REPLACE              & $
    str_element,dlims,'CDF',/DELETE                                 & $
    str_element,dlims,'COLORS',/DELETE                              & $
    str_element,dlims,'LABELS',/DELETE                              & $
    store_data,sfp_nmout[j],DATA=temp,DLIM=dlims,LIM=limb

;; clean up options
FOR i=0L, 2L DO BEGIN                                                 $
  sfp_nmout = sfp_name_str.(i)                                      & $
  FOR j=0L, n_pint - 1L DO BEGIN                                      $
    options,sfp_nmout[j],'COLOR_TABLE',/DEF                         & $
    options,sfp_nmout[j],'COLOR_TABLE'                              & $
    options,sfp_nmout[j],'COLORS',/DEF                              & $
    options,sfp_nmout[j],'COLORS'                                   & $
    options,sfp_nmout[j],'YLOG',1,/DEF                              & $
    options,sfp_nmout[j],'LABELS',/DEF                              & $
    options,sfp_nmout[j],'LABELS'

;;------------------------------------
;; Wave Burst
;;------------------------------------
nfft           = 128L
nshft          = 32L
flow           = 1d1
yttl_out       = '|S| [Freq. Power, 10^(-6) W/m^2]'
ysub           = '[th'+sc[0]+' '+srate_wstr[0]+'sps, 128 Fbins, 32 pt-shift]'

scw_pref       = pref[0]+'scw_cal_HighPass_'
efw_pref       = pref[0]+'efw_cal_corrected_DownSampled_'
scw_suff       = coord_in+'_INT*'
efw_suff       = coord_in+'_INT*'
scw_gse_names  = tnames(scw_pref[0]+scw_suff[0])
efw_gse_names  = tnames(efw_pref[0]+efw_suff[0])
scw_fac_names  = tnames(scw_pref[0]+scw_suff[1])
efw_fac_names  = tnames(efw_pref[0]+efw_suff[1])
scw_nif_names  = tnames(scw_pref[0]+scw_suff[2])
efw_nif_names  = tnames(efw_pref[0]+efw_suff[2])
scw_name_str   = {T0:scw_gse_names,T1:scw_fac_names,T2:scw_nif_names}
efw_name_str   = {T0:efw_gse_names,T1:efw_fac_names,T2:efw_nif_names}
n_wint         = N_ELEMENTS(scw_gse_names)  ;; # of SCW time intervals
;;  Define output names
tsuffix        = '_INT'+STRING(LINDGEN(n_wint),FORMAT='(I3.3)')
sfw_gse_out    = pref[0]+'efw-scw-cal_ExB-Power_'+coord_in[0]+tsuffix
sfw_fac_out    = pref[0]+'efw-scw-cal_ExB-Power_'+coord_in[1]+tsuffix
sfw_nif_out    = pref[0]+'efw-scw-cal_ExB-Power_'+coord_in[2]+tsuffix
sfw_name_str   = {T0:sfw_gse_out,T1:sfw_fac_out,T2:sfw_nif_out}
;;  Define output structures
data_att_gse   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[0],UNITS:'microW/m^2'}
data_att_fac   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[1],UNITS:'microW/m^2'}
data_att_nif   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[2],UNITS:'microW/m^2'}
data_att_s     = {T0:data_att_gse,T1:data_att_fac,T2:data_att_nif}
;;  Calculate S [µW m^(-2)]
FOR i=0L, 2L DO BEGIN                                                 $
  scw_names = scw_name_str.(i)                                      & $
  efw_names = efw_name_str.(i)                                      & $
  data_atts = data_att_s.(i)                                        & $
  sfw_nmout = sfw_name_str.(i)                                      & $
  FOR j=0L, n_wint - 1L DO BEGIN                                      $
    get_data,scw_names[j],DATA=t_scw,DLIM=dlimb,LIM=limb            & $
    get_data,efw_names[j],DATA=t_efw,DLIM=dlime,LIM=lime            & $
    tempx        = interp(t_efw.Y[*,0],t_efw.X,t_scw.X,/NO_EXTRAP)  & $
    tempy        = interp(t_efw.Y[*,1],t_efw.X,t_scw.X,/NO_EXTRAP)  & $
    tempz        = interp(t_efw.Y[*,2],t_efw.X,t_scw.X,/NO_EXTRAP)  & $
    tempef       = [[tempx],[tempy],[tempz]]                        & $
    efw2         = {X:t_scw.X,Y:tempef}                             & $
    temp         = calc_poynting_flux_freq(efw2,t_scw,FLOW=flow[0],NFFT=nfft[0],NSHFT=nshft[0])  & $
    dlims        = dlimb                                            & $
    str_element,dlims,'DATA_ATT',data_atts,/ADD_REPLACE             & $
    str_element,dlims,'YTITLE',yttl_out[0],/ADD_REPLACE             & $
    str_element,dlims,'YSUBTITLE',ysub[0],/ADD_REPLACE              & $
    str_element,dlims,'CDF',/DELETE                                 & $
    str_element,dlims,'COLORS',/DELETE                              & $
    str_element,dlims,'LABELS',/DELETE                              & $
    store_data,sfw_nmout[j],DATA=temp,DLIM=dlims,LIM=limb

;; clean up options
FOR i=0L, 2L DO BEGIN                                                 $
  sfw_nmout = sfw_name_str.(i)                                      & $
  FOR j=0L, n_wint - 1L DO BEGIN                                      $
    options,sfw_nmout[j],'COLOR_TABLE',/DEF                         & $
    options,sfw_nmout[j],'COLOR_TABLE'                              & $
    options,sfw_nmout[j],'COLORS',/DEF                              & $
    options,sfw_nmout[j],'COLORS'                                   & $
    options,sfw_nmout[j],'YLOG',1,/DEF                              & $
    options,sfw_nmout[j],'LABELS',/DEF                              & $
    options,sfw_nmout[j],'LABELS'











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
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]+'.tplot'
file           = FILE_SEARCH(mdir,fname[0])
tplot_restore,FILENAME=file[0],VERBOSE=0

!themis.VERBOSE = 0
tplot_options,'VERBOSE',2

pref           = 'th'+sc[0]+'_'
pos_gse        = 'th'+sc[0]+'_state_pos_gse'
names          = [pref[0]+'_Rad',pos_gse[0]+['_x','_y','_z']]
tplot_options,VAR_LABEL=names
options,tnames(),'LABFLAG',2,/DEF

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100

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
tr_jj     = time_double(tdate[0]+'/'+['15:48:20','15:58:25'])

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

;; => Remove data outside time range of interest
coord_in       = 'dsl'
scw_names      = tnames(pref[0]+'scw_cal_'+coord_in[0]+'*')
efw_names      = tnames(pref[0]+'efw_cal_'+coord_in[0]+'*')
scp_names      = tnames(pref[0]+'scp_cal_'+coord_in[0]+'*')
efp_names      = tnames(pref[0]+'efp_cal_'+coord_in[0]+'*')
all_fields     = [scp_names,scw_names,efp_names,efw_names]
kill_data_tr,NAMES=all_fields

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
;;----------------------------------------------------------------------------------------
;; => Calibrate and Rotate SCM and EFI
;;----------------------------------------------------------------------------------------
magf_up        = [2.03877d0,-0.451179d0,-3.02909d0]
magf_dn        = [-0.601265d0,-15.0333d0,-4.21656d0]
vswi_up        = [-306.830d0,65.3250d0,30.0793d0]
vswi_dn        = [-66.1083d0,50.1763d0,-6.33199d0]
vshn_up        =   -0.34323890d0
ushn_up        = -309.10030d0
gnorm          = [0.97873770d0,-0.11229654d0,-0.059902080d0]
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn)

.compile temp_thm_cal_rot_ebfields
temp_thm_cal_rot_ebfields,PROBE=sc[0],TRANGE=tr_jj,NIF_STR=nif_str

del_data,tnames('tha_*_cal_dsl_HighPass*')
del_data,tnames('tha_*_cal_*_INT*')
del_data,tnames('tha_*_cal_*_fac*')
del_data,tnames('tha_*_cal_*_corrected*')



















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
;; => Plot data
;;----------------------------------------------------------------------------------------
treb    = tr_jj

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
;; => Restore saved DFs
;;----------------------------------------------------------------------------------------
sc      = probe[0]
enames  = 'EESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames  = 'IESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'

mdir    = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_esa_save/'+tdate[0]+'/')
efiles  = FILE_SEARCH(mdir,enames[0])
ifiles  = FILE_SEARCH(mdir,inames[0])

RESTORE,ifiles[0]
;; => Redefine structures
dat_i     = peib_df_arr_a
;; Keep only structures between defined time range
trtt      = time_double(tr_00)
i_time0   = dat_i.TIME
i_time1   = dat_i.END_TIME
good_i    = WHERE(i_time0 GE trtt[0] AND i_time1 LE trtt[1],gdi)
dat_i     = peib_df_arr_a[good_i]
n_i       = N_ELEMENTS(dat_i)
PRINT,';', n_i
;         791


RESTORE,efiles[0]
;; => Redefine structures
dat_e     = peeb_df_arr_a
;; Keep only structures between defined time range
trtt      = time_double(tr_00)
e_time0   = dat_e.TIME
e_time1   = dat_e.END_TIME
good_e    = WHERE(e_time0 GE trtt[0] AND e_time1 LE trtt[1],gde)
dat_e     = peeb_df_arr_a[good_e]

n_e       = N_ELEMENTS(dat_e)
PRINT,';', n_e
;         790
;;----------------------------------------------------------------------------------------
;; => Modify structures so they work in my plotting routines
;;----------------------------------------------------------------------------------------
coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
velname   = pref[0]+'peib_velocity_'+coord[0]
vname_n   = velname[0]+'_fixed_3'
magname   = pref[0]+'fgh_'+coord[0]
spperi    = pref[0]+'state_spinper'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
scname    = tnames(pref[0]+'pe*b_sc_pot')

modify_themis_esa_struc,dat_i
;; add SC potential to structures
add_scpot,dat_i,scname[1]
;; => Rotate DAT structure (theta,phi)-angles DSL --> GSE
dat_igse  = dat_i
rotate_esa_thetaphi_to_gse,dat_igse,MAGF_NAME=magname,VEL_NAME=velname
;; make sure MAGF tag is defined
magn_1    = pref[0]+'fgs_'+coord[0]
magn_2    = pref[0]+'fgh_'+coord[0]
add_magf2,dat_igse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_igse,magn_2[0],/LEAVE_ALONE
;; make sure VSW tag is defined
add_vsw2,dat_igse,velname[0],/LEAVE_ALONE
add_vsw2,dat_igse,vname_n[0],/LEAVE_ALONE


modify_themis_esa_struc,dat_e
;; add SC potential to structures
add_scpot,dat_e,scname[0]
;; => Rotate DAT structure (theta,phi)-angles DSL --> GSE
dat_egse  = dat_e
rotate_esa_thetaphi_to_gse,dat_egse,MAGF_NAME=magname,VEL_NAME=velname
;; make sure MAGF tag is defined
magn_1    = pref[0]+'fgs_'+coord[0]
magn_2    = pref[0]+'fgh_'+coord[0]
add_magf2,dat_egse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_egse,magn_2[0],/LEAVE_ALONE
;; make sure VSW tag is defined
add_vsw2,dat_egse,velname[0],/LEAVE_ALONE
add_vsw2,dat_egse,vname_n[0],/LEAVE_ALONE






;; Upstream/Downstream determination
tr_up     = tdate[0]+'/'+['15:54:25','15:57:30']
tr_dn     = tdate[0]+'/'+['15:49:30','15:51:55']

