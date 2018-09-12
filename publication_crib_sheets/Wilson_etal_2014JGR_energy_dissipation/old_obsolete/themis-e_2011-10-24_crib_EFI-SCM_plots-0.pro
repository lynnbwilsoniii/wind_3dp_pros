;;----------------------------------------------------------------------------------------
;;  Status Bar Legend
;;
;;    yellow       :  slow survey
;;    red          :  fast survey
;;    black below  :  particle burst
;;    black above  :  wave burst
;;
;;----------------------------------------------------------------------------------------



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
tdate          = '2011-10-24'
tr_00          = tdate[0]+'/'+['16:00:00','23:59:59']
date           = '102411'
probe          = 'e'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
;; => Restore TPLOT session
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_'
;fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_EFI-SCM-Corrected_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]+'.tplot'
file           = FILE_SEARCH(mdir,fname[0])
tplot_restore,FILENAME=file[0],VERBOSE=0
;;----------------------------------------------------------------------------------------
;; => Set defaults
;;----------------------------------------------------------------------------------------
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
;;----------------------------------------------------------------------------------------
;; => Plot fgh
;;----------------------------------------------------------------------------------------
coord          = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
velname        = pref[0]+'peib_velocity_'+coord[0]
magname        = pref[0]+'fgh_'+coord[0]
fgmnm          = pref[0]+'fgh_'+['mag',coord[0]]
tr_jj          = time_double(tdate[0]+'/'+['18:00:00','23:59:59'])

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

kill_data_tr,NAMES=[scp_names[0],efp_names[0]]
kill_data_tr,NAMES=scp_names[0]
kill_data_tr,NAMES=efp_names[0]

;; => Remove "spikes" by hand
coord_in       = 'dsl'
scw_names      = tnames(pref[0]+'scw_cal_'+coord_in[0]+'*')
efw_names      = tnames(pref[0]+'efw_cal_'+coord_in[0]+'*')
all_fields     = [scw_names,efw_names]
names          = [fgmnm,all_fields]
tplot,names

kill_data_tr,NAMES=[scw_names[0],efw_names[0]]
kill_data_tr,NAMES=scw_names[0]
kill_data_tr,NAMES=efw_names[0]


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
PRINT,';; ', gdscp, gdscw, gdefp, gdefw
;;       202451      262144      202451      262144


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


;; => Specify # of "spikes" to remove by hand each time and save time ranges
tr_ww          = time_double(tdate[0]+'/'+['18:31:25.000','18:31:56.000'])
tr_ww1         = time_double(tdate[0]+'/'+['18:31:25.000','18:31:34.380'])
tr_ww2         = time_double(tdate[0]+'/'+['18:31:46.970','18:31:55.140'])


tr_ww3         = time_double(tdate[0]+'/'+['23:28:20.100','23:28:37.200'])
tr_ww4         = time_double(tdate[0]+'/'+['23:28:20.640','23:28:28.730'])
tr_ww5         = time_double(tdate[0]+'/'+['23:28:28.730','23:28:36.800'])

kill_data_tr,NAMES=efw_names[0]

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
PRINT,';; ', gdscp, gdscw, gdefp, gdefw
;;       202451      262144      202451      260279

;; => Interpolate gaps
;;  efp
IF (gdefp GT 0) THEN temp_efpx = interp(temp_efp.Y[good_efp,0],temp_efp.X[good_efp],temp_efp.X,/NO_EXTRAP) ELSE temp_efpx = 0
IF (gdefp GT 0) THEN temp_efpy = interp(temp_efp.Y[good_efp,1],temp_efp.X[good_efp],temp_efp.X,/NO_EXTRAP) ELSE temp_efpy = 0
IF (gdefp GT 0) THEN temp_efpz = interp(temp_efp.Y[good_efp,2],temp_efp.X[good_efp],temp_efp.X,/NO_EXTRAP) ELSE temp_efpz = 0
;;  efw
IF (gdefw GT 0) THEN temp_efwx = interp(temp_efw.Y[good_efw,0],temp_efw.X[good_efw],temp_efw.X,/NO_EXTRAP) ELSE temp_efwx = 0
IF (gdefw GT 0) THEN temp_efwy = interp(temp_efw.Y[good_efw,1],temp_efw.X[good_efw],temp_efw.X,/NO_EXTRAP) ELSE temp_efwy = 0
IF (gdefw GT 0) THEN temp_efwz = interp(temp_efw.Y[good_efw,2],temp_efw.X[good_efw],temp_efw.X,/NO_EXTRAP) ELSE temp_efwz = 0
;; => Try again with efp and efw
temp_efpv      = [[temp_efpx],[temp_efpy],[temp_efpz]]
temp_efwv      = [[temp_efwx],[temp_efwy],[temp_efwz]]
test_efp       = FINITE(temp_efpv[*,0]) AND FINITE(temp_efpv[*,1]) AND FINITE(temp_efpv[*,2])
good_efp       = WHERE(test_efp,gdefp)
test_efw       = FINITE(temp_efwv[*,0]) AND FINITE(temp_efwv[*,1]) AND FINITE(temp_efwv[*,2])
good_efw       = WHERE(test_efw,gdefw)
PRINT,';; ', gdefp, gdefw
;;       202451      262127


IF (gdscp GT 0) THEN temp_scp = {X:temp_scp.X[good_scp],Y:temp_scp.Y[good_scp,*]} ELSE temp_scp = 0
IF (gdscw GT 0) THEN temp_scw = {X:temp_scw.X[good_scw],Y:temp_scw.Y[good_scw,*]} ELSE temp_scw = 0
IF (gdefp GT 0) THEN temp_efp = {X:temp_efp.X[good_efp],Y:temp_efpv[good_efp,*]} ELSE temp_efp = 0
IF (gdefw GT 0) THEN temp_efw = {X:temp_efw.X[good_efw],Y:temp_efwv[good_efw,*]} ELSE temp_efw = 0
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
t_ramp         = MEAN(time_double(tdate[0]+'/'+['18:31:56.880','18:31:57.290']),/NAN)
;;  Shock Parameters
vshn_up        = -58.924067d0
ushn_up        = -358.12372d0
ushn_dn        = -120.80463d0
gnorm          = [0.94742836d0,0.18668436d0,0.20001629d0]
theta_Bn       =  88.842702d0
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-435.801d0,-14.1659d0,-7.56588d0]
vswi_dn        = [-205.980d0,40.2591d0,39.5294d0]
magf_up        = [4.37016d0,-6.67269d0,-12.9573d0]
magf_dn        = [11.9059d0,-7.86599d0,-35.9012d0]
dens_up        = 33.5547d0
dens_dn        = 101.277d0
Ti___up        = 91.3863d0
Ti___dn        = 179.582d0
Te___up        = 31.2435d0
Te___dn        = 66.0967d0

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
;;    Intervals [1L] are good for the following:
;;      *_scp_cal_*
;;      *_efp_cal_gse_*
;;
;;    Intervals [0L,1L] are good for the following:
;;      *_scw_cal_*
;;      *_efw_cal_corrected_DownSampled_*
;;      *_S__TimeSeries_*
;;
;;    Intervals [2L,3L] are good for the following:
;;      *_efw_cal_gse_*
;;      *_efw_cal_corrected_gse_*
;;
;gint           = [0L,5L,6L]
gint           = LINDGEN(15)

.compile temp_thm_cal_rot_ebfields
.compile temp_calc_j_S_nif_etc
temp_thm_cal_rot_ebfields,PROBE=sc[0],TRANGE=tr_jj,NIF_STR=nif_str,$
                          VSW_TPNM=vsw_tpnm,TRAMP=tramp,NSM=nsm,   $
                          GINT=gint,NIF_SUFFX=nif_suffx[0]

;;  Enter the following by hand at 1st STOP statement in temp_thm_cal_rot_ebfields.pro
bind           = [0L,1L]
del_data,tnames('*_scw_cal_HighPass_*'+isuffx[bind])
del_data,tnames('*_efw_cal_corrected_DownSampled_*'+isuffx[bind])
del_data,tnames('*_S__TimeSeries_*'+isuffx[bind])

bind           = [0L]
del_data,tnames('*_scp_cal_gse'+isuffx[bind])
del_data,tnames('*_efp_cal_gse'+isuffx[bind])

;;  Rename *_efw_cal_gse_* and *_efw_cal_corrected_gse_*
store_data,'the_scw_cal_gse_INT002',NEWNAME='the_scw_cal_gse_INT004'
store_data,'the_scw_cal_gse_INT003',NEWNAME='the_scw_cal_gse_INT005'
store_data,'the_efw_cal_gse_INT002',NEWNAME='the_efw_cal_gse_INT004'
store_data,'the_efw_cal_gse_INT003',NEWNAME='the_efw_cal_gse_INT005'
store_data,'the_efw_cal_corrected_gse_INT002',NEWNAME='the_efw_cal_corrected_gse_INT004'
store_data,'the_efw_cal_corrected_gse_INT003',NEWNAME='the_efw_cal_corrected_gse_INT005'
store_data,'the_efw_cal_corrected_fac_INT002',NEWNAME='the_efw_cal_corrected_fac_INT004'
store_data,'the_efw_cal_corrected_fac_INT003',NEWNAME='the_efw_cal_corrected_fac_INT005'


store_data,'the_scw_cal_gse_INT000',NEWNAME='the_scw_cal_gse_INT002'
store_data,'the_scw_cal_gse_INT001',NEWNAME='the_scw_cal_gse_INT003'
store_data,'the_efw_cal_gse_INT000',NEWNAME='the_efw_cal_gse_INT002'
store_data,'the_efw_cal_gse_INT001',NEWNAME='the_efw_cal_gse_INT003'
store_data,'the_efw_cal_corrected_gse_INT000',NEWNAME='the_efw_cal_corrected_gse_INT002'
store_data,'the_efw_cal_corrected_gse_INT001',NEWNAME='the_efw_cal_corrected_gse_INT003'
store_data,'the_efw_cal_corrected_fac_INT000',NEWNAME='the_efw_cal_corrected_fac_INT002'
store_data,'the_efw_cal_corrected_fac_INT001',NEWNAME='the_efw_cal_corrected_fac_INT003'


gind           = [2L,3L,4L,5L]
.c

;;  Remove 1st NIF intervals [4L,5L]
del_data,tnames('*_nif_S1986a-RHS01_INT00'+['4','5'])



;;----------------------------------------------------------------------------------------
;; => Calibrate and Rotate SCM and EFI [2nd shock solutions]
;;----------------------------------------------------------------------------------------
;; => Avg. terms [2nd Shock]
t_ramp         = MEAN(time_double(tdate[0]+'/'+['23:28:14.596','23:28:16.086']),/NAN)
;;  Shock Parameters
vshn_up        = -37.141536d0
ushn_up        = -367.71181d0
ushn_dn        = -77.371965d0
gnorm          = [0.88335655d0,0.11512753d0,0.45176740d0]
theta_Bn       =  87.786598d0
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-477.028d0,104.805d0,9.88610d0]
vswi_dn        = [-186.710d0,109.106d0,83.7977d0]
magf_up        = [3.98054d0,14.6409d0,-9.96436d0]
magf_dn        = [1.06117d0,51.7175d0,-19.7248d0]
dens_up        = 20.4472d0
dens_dn        = 97.3820d0
Ti___up        = 64.2323d0
Ti___dn        = 176.665d0
Te___up        = 18.6656d0
Te___dn        = 81.4642d0

;;  Define RH Parameter Structure
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)

coord_in       = 'gse'
vsw_tpnm       = tnames(pref[0]+coord_in[0]+'_Velocity_peib_no_GIs_UV_2')
tramp          = t_ramp[0]
nsm            = 10L
nif_suffx      = '-RHS02'
;;  need to remove them by hand and then rename SCW and S b/c they have different
;;    # of intervals
;;
;;    Intervals [4L,5L] are good for the following:
;;      *_scw_cal_*
;;      *_efw_cal_corrected_DownSampled_*
;;      *_S__TimeSeries_*
;;
;;    Intervals [4L,5L] are good for the following:
;;      *_efw_cal_gse_*
;;      *_efw_cal_corrected_gse_*
;;
;gint           = [0L,5L,6L]

;;  Only call 2nd half of program
modes_pw       = ['p','w']
mode_efi       = 'ef'+modes_pw
mode_scm       = 'sc'+modes_pw
efi_name       = tnames(pref[0]+mode_efi[1]+'_cal_corrected_DownSampled_'+coord_in[0]+'_INT*')
scm_name       = tnames(pref[0]+mode_scm[1]+'_cal_HighPass_'+coord_in[0]+'_INT*')
get_data,efi_name[0],DATA=efw,DLIM=dlime,LIM=lime
get_data,scm_name[0],DATA=scw,DLIM=dlimb,LIM=limb
smrate         = DOUBLE(ROUND(sample_rate(efw.X,GAP_THRESH=2d0,/AVE)))
smratb         = DOUBLE(ROUND(sample_rate(scw.X,GAP_THRESH=2d0,/AVE)))

gint           = [2L,3L,4L,5L]
.compile temp_calc_j_S_nif_etc
temp_calc_j_S_nif_etc,PROBE=sc[0],TRANGE=tr_jj,NIF_STR=nif_str,       $
                      VSW_TPNM=vsw_tpnm,TRAMP=tramp[0],NSM=nsm,       $
                      GINT=gint,NIF_SUFFX=nif_suffx,                  $
                      SRATE_E=smrate[0],SRATE_B=smratb[0]

;;  Remove 2nd NIF intervals [2L,3L]
badnms         = tnames('*_nif_S1986a-RHS02_INT00'+['2','3'])
badnms         = badnms[1L:(N_ELEMENTS(badnms) - 1L)]
del_data,badnms
;;----------------------------------------------------------------------------------------
;; => Print values to ASCII file
;;----------------------------------------------------------------------------------------
nsm            = 10L
;; => ASCII [1st Shock]
nif_suffx      = '-RHS01'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['18:31:56.880','18:31:57.290']),/NAN)
gint           = [2L,3L]
fsuffx         = '_1st-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],$
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,   $
                                       FILE_SUFFX=fsuffx[0])
;; => ASCII [2nd Shock]
nif_suffx      = '-RHS02'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['23:28:14.596','23:28:16.086']),/NAN)
gint           = [4L,5L]
fsuffx         = '_2nd-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],$
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,   $
                                       FILE_SUFFX=fsuffx[0])





























































































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








































