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
;;----------------------------------------------------------------------------------------
;; => Date/Time and Probe
;;----------------------------------------------------------------------------------------
probe          = 'c'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])

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
;;----------------------------------------------------------------------------------------
;; => Set defaults
;;----------------------------------------------------------------------------------------
!themis.VERBOSE = 2
tplot_options,'VERBOSE',2
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Vbulk Plots ['+tdate[0]+']'

coord_gse      = 'gse'
pos_gse        = tnames(scpref[0]+'state_pos_'+coord_gse[0]+'_*')
rad_pos_tpnm   = tnames(scpref[0]+'_Rad')
;;  Define tick marks
names2         = [pos_gse,rad_pos_tpnm[0]]
tplot_options,VAR_LABEL=names2

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

tplot,fgmnm,TRANGE=tr_jj
;;----------------------------------------------------------------------------------------
;; => Restore saved DFs
;;----------------------------------------------------------------------------------------
tr_mom         = tr_jj

sc             = probe[0]
enames         = 'EESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames         = 'IESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_esa_save/'+tdate[0]+'/')
efiles         = FILE_SEARCH(mdir,enames[0])
ifiles         = FILE_SEARCH(mdir,inames[0])

RESTORE,ifiles[0]
;; => Redefine structures
dat_i          = peib_df_arr_c
;; Keep only structures between defined time range
trtt           = time_double(tr_mom)
i_time0        = dat_i.TIME
i_time1        = dat_i.END_TIME
good_i         = WHERE(i_time0 GE trtt[0] AND i_time1 LE trtt[1],gdi)
dat_i          = dat_i[good_i]
n_i            = N_ELEMENTS(dat_i)
PRINT,';;', n_i
;;         582



RESTORE,efiles[0]
;; => Redefine structures
dat_e          = peeb_df_arr_c
;; Keep only structures between defined time range
trtt           = time_double(tr_mom)
e_time0        = dat_e.TIME
e_time1        = dat_e.END_TIME
good_e         = WHERE(e_time0 GE trtt[0] AND e_time1 LE trtt[1],gde)
dat_e          = dat_e[good_e]
n_e            = N_ELEMENTS(dat_e)
PRINT,';;', n_e
;;         582
;;----------------------------------------------------------------------------------------
;; => Modify structures so they work in my plotting routines
;;----------------------------------------------------------------------------------------
coord_gse      = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
velnm0         = pref[0]+'Velocity_'+coord_gse[0]+'_peib_no_GIs_UV'
velname        = pref[0]+'peib_velocity_'+coord_gse[0]
vname_n        = tnames(velnm0[0])
magname        = pref[0]+'fgh_'+coord_gse[0]            ;;  Use fgl to cover full time range
spperi         = pref[0]+'state_spinper'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
scnamei        = tnames(pref[0]+'peib_sc_pot')
scnamee        = tnames(pref[0]+'peeb_sc_pot')

modify_themis_esa_struc,dat_i
;; add SC potential to structures
add_scpot,dat_i,scnamei[0]
;; => Rotate DAT structure (theta,phi)-angles DSL --> GSE
dat_igse       = dat_i
rotate_esa_thetaphi_to_gse,dat_igse,MAGF_NAME=magname,VEL_NAME=velname
;; make sure MAGF tag is defined
magn_1         = pref[0]+'fgl_'+coord_gse[0]
magn_2         = pref[0]+'fgh_'+coord_gse[0]
add_magf2,dat_igse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_igse,magn_2[0],/LEAVE_ALONE
;; make sure VSW tag is defined
add_vsw2,dat_igse,velname[0],/LEAVE_ALONE
add_vsw2,dat_igse,vname_n[0],/LEAVE_ALONE


modify_themis_esa_struc,dat_e
;; add SC potential to structures
add_scpot,dat_e,scnamee[0]
;; => Rotate DAT structure (theta,phi)-angles DSL --> GSE
dat_egse       = dat_e
rotate_esa_thetaphi_to_gse,dat_egse,MAGF_NAME=magname,VEL_NAME=velname
;; make sure MAGF tag is defined
magn_1         = pref[0]+'fgl_'+coord_gse[0]
magn_2         = pref[0]+'fgh_'+coord_gse[0]
add_magf2,dat_egse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_egse,magn_2[0],/LEAVE_ALONE
;; make sure VSW tag is defined
add_vsw2,dat_egse,velname[0],/LEAVE_ALONE
add_vsw2,dat_egse,vname_n[0],/LEAVE_ALONE






