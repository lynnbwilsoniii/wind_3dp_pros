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
tdate          = '2009-07-21'
tr_00          = tdate[0]+'/'+['14:00:00','23:00:00']
date           = '072109'
probe          = 'c'
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
tr_jj          = time_double(tdate[0]+'/'+['19:09:30','19:29:24'])

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
;;       151552      104448      151552      415672


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
t_ramp         = MEAN(time_double(tdate[0]+'/'+['19:24:49.530','19:24:53.440']),/NAN)
;;  Shock Parameters
vshn_up        =  -31.373502d0
ushn_up        = -193.823000d0
ushn_dn        =  -54.939813d0
gnorm          = [0.92298712d0,0.20655033d0,-0.25200810d0]
theta_Bn       =   55.719721d0
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-250.544d0,37.1998d0,6.47334d0]
vswi_dn        = [-105.441d0,56.2725d0,2.44359d0]
magf_up        = [2.71915d0,6.94990d0,-0.754250d0]
magf_dn        = [1.66317d0,11.9934d0,-17.2641d0]
dens_up        =    7.36031d0
dens_dn        =   26.49950d0
Ti___up        =   16.11730d0
Ti___dn        =   80.01990d0
Te___up        =    9.29213d0
Te___dn        =   32.57890d0

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
;;    Intervals [0L,1L] are good for the following:
;;      *_scw_cal_*
;;      *_efw_cal_corrected_DownSampled_*
;;      *_S__TimeSeries_*
;;
;;    Intervals [0L,1L] are good for the following:
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
;;    Need to merge *_efw_cal_gse_* and *_efw_cal_corrected_gse_* to avoid too many
;;      TPLOT handles
;;
;;      0 -  1  -->  0
;;      2 -  6  -->  1
;;      7 - 10  -->  2
;;     11 - 11  -->  3
;;     12 - 13  -->  4
;;     14 - 16  -->  5
;;
;;------------------------------------------------
;;      *_efw_cal_gse_*
;;------------------------------------------------
efwcal_name    = tnames('*_efw_cal_gse_*')
ysubttles      = '[th'+sc[0]+' !9l!X 16384 sps, Int. '+STRING(LINDGEN(6L),FORMAT='(I3.3)')+']'
;;------------------------------------------------
;;      *_efw_cal_corrected_gse_*
;;------------------------------------------------
efwcal_name    = tnames('*_efw_cal_corrected_gse_*')
ysubttles      = '[th'+sc[0]+' !9l!X 16384 sps, Int. '+STRING(LINDGEN(6L),FORMAT='(I3.3)')+']'


;;  New 0
get_data,efwcal_name[0],DATA=temp0,DLIM=dlim0,LIM=lim0
get_data,efwcal_name[1],DATA=temp1,DLIM=dlim1,LIM=lim1
newdat0        = {X:[temp0.X,temp1.X],Y:[temp0.Y,temp1.Y]}
newdlim0       = dlim0
newlim0        = lim0
str_element,newdlim0,'YSUBTITLE',ysubttles[0],/ADD_REPLACE
;;  New 1
get_data,efwcal_name[2],DATA=temp0,DLIM=dlim0,LIM=lim0
get_data,efwcal_name[3],DATA=temp1,DLIM=dlim1,LIM=lim1
get_data,efwcal_name[4],DATA=temp2,DLIM=dlim2,LIM=lim2
get_data,efwcal_name[5],DATA=temp3,DLIM=dlim3,LIM=lim3
get_data,efwcal_name[6],DATA=temp4,DLIM=dlim4,LIM=lim4
newdat1        = {X:[temp0.X,temp1.X,temp2.X,temp3.X,temp4.X],Y:[temp0.Y,temp1.Y,temp2.Y,temp3.Y,temp4.Y]}
newdlim1       = dlim0
newlim1        = lim0
str_element,newdlim1,'YSUBTITLE',ysubttles[1],/ADD_REPLACE
;;  New 2
get_data, efwcal_name[7],DATA=temp0,DLIM=dlim0,LIM=lim0
get_data, efwcal_name[8],DATA=temp1,DLIM=dlim1,LIM=lim1
get_data, efwcal_name[9],DATA=temp2,DLIM=dlim2,LIM=lim2
get_data,efwcal_name[10],DATA=temp3,DLIM=dlim3,LIM=lim3
newdat2        = {X:[temp0.X,temp1.X,temp2.X,temp3.X],Y:[temp0.Y,temp1.Y,temp2.Y,temp3.Y]}
newdlim2       = dlim0
newlim2        = lim0
str_element,newdlim2,'YSUBTITLE',ysubttles[2],/ADD_REPLACE
;;  New 3
get_data,efwcal_name[11],DATA=temp0,DLIM=dlim0,LIM=lim0
newdat3        = {X:temp0.X,Y:temp0.Y}
newdlim3       = dlim0
newlim3        = lim0
str_element,newdlim3,'YSUBTITLE',ysubttles[3],/ADD_REPLACE
;;  New 4
get_data,efwcal_name[12],DATA=temp0,DLIM=dlim0,LIM=lim0
get_data,efwcal_name[13],DATA=temp1,DLIM=dlim1,LIM=lim1
newdat4        = {X:[temp0.X,temp1.X],Y:[temp0.Y,temp1.Y]}
newdlim4       = dlim0
newlim4        = lim0
str_element,newdlim4,'YSUBTITLE',ysubttles[4],/ADD_REPLACE
;;  New 5
get_data,efwcal_name[14],DATA=temp0,DLIM=dlim0,LIM=lim0
get_data,efwcal_name[15],DATA=temp1,DLIM=dlim1,LIM=lim1
get_data,efwcal_name[16],DATA=temp2,DLIM=dlim2,LIM=lim2
newdat5        = {X:[temp0.X,temp1.X,temp2.X],Y:[temp0.Y,temp1.Y,temp2.Y]}
newdlim5       = dlim0
newlim5        = lim0
str_element,newdlim5,'YSUBTITLE',ysubttles[5],/ADD_REPLACE
;;  Send New data to TPLOT
store_data,efwcal_name[0],DATA=newdat0,DLIM=newdlim0,LIM=newlim0
store_data,efwcal_name[1],DATA=newdat1,DLIM=newdlim1,LIM=newlim1
store_data,efwcal_name[2],DATA=newdat2,DLIM=newdlim2,LIM=newlim2
store_data,efwcal_name[3],DATA=newdat3,DLIM=newdlim3,LIM=newlim3
store_data,efwcal_name[4],DATA=newdat4,DLIM=newdlim4,LIM=newlim4
store_data,efwcal_name[5],DATA=newdat5,DLIM=newdlim5,LIM=newlim5
;;  Remove extras TPLOT
bind           = LINDGEN(17)
bind           = bind[6L:16L]
del_data,efwcal_name[bind]

gind           = [0L,1L,2L,3L,4L,5L]
.c

;;  Clean up edge effects
nna00          = tnames('*_nif_S1986a-RHS01_INT005')
tplot,nna00
kill_data_tr,NAMES=nna00

nna00          = tnames('*_gse_INT005')
tplot,nna00
kill_data_tr,NAMES=nna00

suffx0         = '_INT005'
str_00         = '*_scw_cal_HighPass_'+['gse','fac']+suffx0[0]
str_11         = '*_efw_cal'+['','_corrected']+'_gse'+suffx0[0]
str_22         = '*_efw_cal_corrected_DownSampled'+['gse','fac']+suffx0[0]
str_33         = '*_S__TimeSeries_fac'+suffx0[0]
nna00          = tnames([str_00,str_11,str_22,str_33])
tplot,nna00
kill_data_tr,NAMES=nna00

nna00          = tnames('*_neg-E-dot-j_efw_cal_*'+suffx0[0])
tplot,nna00
kill_data_tr,NAMES=nna00


nna00          = tnames('*_jmags_fgh_nif_*')
tplot,nna00
kill_data_tr,NAMES=nna00

nna00          = tnames('*_jvec_fgh_nif_*')
tplot,nna00
kill_data_tr,NAMES=nna00

;;----------------------------------------------------------------------------------------
;; => Print values to ASCII file
;;----------------------------------------------------------------------------------------
nsm            = 10L
;; => ASCII [1st Shock]
nif_suffx      = '-RHS01'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['19:24:49.530','19:24:53.440']),/NAN)
gint           = [4L,5L]
fsuffx         = '_1st-BS-Crossing'
magf_up        = [2.71915d0,6.94990d0,-0.754250d0]
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





























