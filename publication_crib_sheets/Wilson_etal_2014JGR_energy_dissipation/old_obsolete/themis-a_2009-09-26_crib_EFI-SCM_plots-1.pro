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
;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
;; => Restore TPLOT session
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
fpref          = 'TPLOT_save_file_THA_FGM-ALL_EESA-IESA-Moments_'
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
fpref          = 'TPLOT_save_file_FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_EFI-SCM-Corrected_'
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

