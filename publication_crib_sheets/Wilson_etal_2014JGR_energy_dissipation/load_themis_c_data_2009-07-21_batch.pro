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
;;  2009-07-21 [1 Crossing]
tdate          = '2009-07-21'
tr_00          = tdate[0]+'/'+['14:00:00','23:00:00']
date           = '072109'
probe          = 'c'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
tr_jj          = time_double(tdate[0]+'/'+['19:09:30.000','19:29:24.000'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['19:24:47.704','19:24:49.509'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = d
t_ramp2        = d
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
options,tnames(),'LABFLAG',2,/DEF
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'
tplot_options,'NO_INTERP',0  ;;  Allow interpolation in spectrograms

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='THEMIS Plots ['+tdate[0]+']'

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
scpref         = 'th'+sc[0]+'_'
magname        = scpref[0]+'fgh_'+coord[0]
fgmnm          = scpref[0]+'fgh_'+['mag',coord[0]]

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
;;         396


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
;;         397
;;----------------------------------------------------------------------------------------
;; => Modify structures so they work in my plotting routines
;;----------------------------------------------------------------------------------------
coord          = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
vn_prefx       = pref[0]+'peib_velocity_'+coord[0]
velname        = tnames(vn_prefx[0]+'_fixed_3')
vname_n        = tnames(pref[0]+'Velocity_peib_no_GIs_UV_2')
magname        = pref[0]+'fgl_'+coord[0]            ;;  Use fgl to cover full time range
spperi         = pref[0]+'state_spinper'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
scnamei        = tnames(pref[0]+'peir_sc_pot')  ;;  Use reduced to cover full time range
scnamee        = tnames(pref[0]+'peeb_sc_pot')

modify_themis_esa_struc,dat_i
;; add SC potential to structures
add_scpot,dat_i,scnamei[0]
;; => Rotate DAT structure (theta,phi)-angles DSL --> GSE
dat_igse       = dat_i
rotate_esa_thetaphi_to_gse,dat_igse,MAGF_NAME=magname,VEL_NAME=velname
;; make sure MAGF tag is defined
magn_1         = pref[0]+'fgl_'+coord[0]
magn_2         = pref[0]+'fgh_'+coord[0]
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
magn_1         = pref[0]+'fgl_'+coord[0]
magn_2         = pref[0]+'fgh_'+coord[0]
add_magf2,dat_egse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_egse,magn_2[0],/LEAVE_ALONE
;; make sure VSW tag is defined
add_vsw2,dat_egse,velname[0],/LEAVE_ALONE
add_vsw2,dat_egse,vname_n[0],/LEAVE_ALONE













