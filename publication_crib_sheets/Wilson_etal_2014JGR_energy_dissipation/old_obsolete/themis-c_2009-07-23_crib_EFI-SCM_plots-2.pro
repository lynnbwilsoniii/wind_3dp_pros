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
;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
;; => Restore TPLOT session
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_EFI-SCM-Corrected_'
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

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='EFI&SCM Plots ['+tdate[0]+']'

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
;;----------------------------------------------------------------------------------------
;; => Calibrate and Rotate SCM and EFI [1st shock solutions]
;;----------------------------------------------------------------------------------------
;; => Avg. terms [1st Shock]
t_ramp         = MEAN(time_double(tdate[0]+'/'+['18:04:47.030','18:04:58.920']),/NAN)
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
;;  need to remove them by hand and then rename SCW and S b/c they have different
;;    # of intervals
;;
;;    Intervals [0L,1L,2L,5L,6L] are good for the following:
;;      *_scw_cal_*
;;      *_efw_cal_corrected_DownSampled_*
;;      *_S__TimeSeries_*
;;
;;    Intervals [0L,1L,2L,6L,7L] are good for the following:
;;      *_efw_cal_gse_*
;;      *_efw_cal_corrected_gse_*
;;
;gint           = [0L,5L,6L]
gint           = LINDGEN(8)

.compile temp_thm_cal_rot_ebfields
.compile temp_calc_j_S_nif_etc
temp_thm_cal_rot_ebfields,PROBE=sc[0],TRANGE=tr_jj,NIF_STR=nif_str,$
                          VSW_TPNM=vsw_tpnm,TRAMP=tramp,NSM=nsm,   $
                          GINT=gint,NIF_SUFFX=nif_suffx[0]
;;  Enter the following by hand at 1st STOP statement in temp_thm_cal_rot_ebfields.pro
bind           = [3,4]
del_data,tnames('*_scw_cal_*'+isuffx[bind])
del_data,tnames('*_efw_cal_corrected_DownSampled_*'+isuffx[bind])
del_data,tnames('*_S__TimeSeries_*'+isuffx[bind])
bind           = [3,4,5]
del_data,tnames('*_efw_cal_gse'+isuffx[bind])
del_data,tnames('*_efw_cal_corrected_gse'+isuffx[bind])
store_data,'thc_efw_cal_gse_INT006',NEWNAME='thc_efw_cal_gse_INT005'
store_data,'thc_efw_cal_gse_INT007',NEWNAME='thc_efw_cal_gse_INT006'
store_data,'thc_efw_cal_corrected_gse_INT006',NEWNAME='thc_efw_cal_corrected_gse_INT005'
store_data,'thc_efw_cal_corrected_gse_INT007',NEWNAME='thc_efw_cal_corrected_gse_INT006'
gind           = [0L,1L,2L,5L,6L]
.c

;;----------------------------------------------------------------------------------------
;; => Calibrate and Rotate SCM and EFI [2nd shock solutions]
;;----------------------------------------------------------------------------------------
;; => Avg. terms [2nd Shock]
t_ramp         = MEAN(time_double(tdate[0]+'/'+['18:07:07.340','18:07:08.100']),/NAN)
;;  Shock Parameters
vshn_up        =   13.87071d0
ushn_up        = -506.46806d0
ushn_dn        = -138.10784d0
gnorm          = [0.99615338d0,-0.079060538d0,-0.0026399172d0]
theta_Bn       =   88.975636d0
;;  Avg. upstream/downstream Vsw and Bo
magf_up        = [-0.114245d0,0.135357d0,-6.06984d0]
magf_dn        = [1.48669d0,-17.6263d0,-15.3921d0]
vswi_up        = [-488.163d0,82.9255d0,-92.5192d0]
vswi_dn        = [-118.835d0,76.1801d0,-62.0601d0]
dens_up        =    3.71973d0
dens_dn        =   13.67810d0
Ti___up        =   65.21510d0
Ti___dn        =  281.17600d0
Te___up        =    9.48648d0
Te___dn        =   66.64910d0

;;  Define RH Parameter Structure
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)

coord_in       = 'gse'
vsw_tpnm       = tnames(pref[0]+coord_in[0]+'_Velocity_peib_no_GIs_UV_2')
tramp          = t_ramp[0]
nsm            = 10L
nif_suffx      = '-RHS02'
gint           = [0L,1L,2L,5L,6L]
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
;; => Calibrate and Rotate SCM and EFI [3rd shock solutions]
;;----------------------------------------------------------------------------------------
;; => Avg. terms [3rd Shock]
t_ramp         = MEAN(time_double(tdate[0]+'/'+['18:24:24.910','18:24:49.450']),/NAN)
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
nif_suffx      = '-RHS03'
gint           = [0L,1L,2L,5L,6L]
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
;; => Print values to ASCII file
;;----------------------------------------------------------------------------------------
nsm            = 10L
;; => ASCII [1st Shock]
nif_suffx      = '-RHS01'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['18:04:47.030','18:04:58.920']),/NAN)
gint           = [0L]
fsuffx         = '_1st-BS-Crossing'
magf_up        = [-0.0836601d0,0.112276d0,-6.04225d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],$
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,   $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0])
;; => ASCII [2nd Shock]
nif_suffx      = '-RHS02'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['18:07:07.340','18:07:08.100']),/NAN)
gint           = [1L,2L]
fsuffx         = '_2nd-BS-Crossing'
magf_up        = [-0.114245d0,0.135357d0,-6.06984d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],$
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,   $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0])
;; => ASCII [3rd Shock]
nif_suffx      = '-RHS03'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['18:24:24.910','18:24:49.450']),/NAN)
tramp          = t_ramp[0]
gint           = [5L,6L]
fsuffx         = '_3rd-BS-Crossing'
magf_up        = [3.88880d0,-4.95385d0,1.12260d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],$
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,   $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0])




















































































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
















