;;----------------------------------------------------------------------------------------
;;  Commands for detrending last interval
;;----------------------------------------------------------------------------------------
;;  get_data,'the_efw_cal_rmDCoffsets_dsl',DATA=temp,DLIM=dlim,LIM=lim
;;  good    = WHERE(temp.X ge tr_int10[0] and temp.X le tr_int10[1],gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
;;  print, gd, bd
;;  temp_v  = temp.Y[good,*]
;;  print, 16384d0/128d0
;;         128.00000
;;  smwd    = 128L
;;  sm_vx   = SMOOTH(temp_v[*,0],smwd[0],/NAN,/EDGE_TRUNCATE)
;;  sm_vy   = SMOOTH(temp_v[*,1],smwd[0],/NAN,/EDGE_TRUNCATE)
;;  sm_vz   = SMOOTH(temp_v[*,2],smwd[0],/NAN,/EDGE_TRUNCATE)
;;  temp_vx = temp_v[*,0] - sm_vx
;;  temp_vy = temp_v[*,1] - sm_vy
;;  temp_vz = temp_v[*,2] - sm_vz
;;  temp_v2 = [[temp_vx],[temp_vy],[temp_vz]] 
;;  gxx     = temp.X[good]
;;  bxx     = temp.X[bad]
;;  gyy     = temp_v2
;;  byy     = temp.Y[bad,*]
;;  xx      = [gxx,bxx]
;;  yy      = [gyy,byy]
;;  sp      = SORT(xx)
;;  xx      = xx[sp]
;;  yy      = yy[sp,*]
;;  store_data,'the_efw_cal_rmDCoffsets_dsl',data={X:xx,Y:yy},DLIM=dlim,LIM=lim
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
;;  2010-08-23 [2 Crossings with both EFI & SCM, 3 with EFI]
tdate          = '2010-08-23'
date           = '082310'
tr_00          = ['2010-08-23/14:00:00','2010-08-24/03:59:59']

probe          = 'e'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
scpref         = pref[0]

tr_aa          = time_double(tdate[0]+'/'+['16:00:00.000','23:00:00.000'])
tr_gg          = time_double(tdate[0]+'/'+['22:25:00.000','22:25:30.000'])
tr_ww          = time_double(tdate[0]+'/'+['22:25:11.400','22:25:18.000'])

tr_wav         = time_double(tdate[0]+'/'+['22:20:09.000','22:20:17.000'])
tr_swoosh      = time_double(tdate[0]+'/'+['17:30:52.800','17:31:03.800'])
tr_swoosh1     = time_double(tdate[0]+'/'+['17:34:06.250','17:34:08.664'])

;;  Timespan covering all 3 shock crossings
tr_jj          = time_double(tdate[0]+'/'+['22:04:50.000','22:26:10.000'])

;;  Timespans of EFI data near shock crossings
tr_efi_0       = time_double(tdate[0]+'/'+['22:09:37.500','22:09:51.600'])
tr_efi_1       = time_double(tdate[0]+'/'+['22:20:10.000','22:20:17.000'])
tr_efi_2       = time_double(tdate[0]+'/'+['22:25:11.000','22:25:18.000'])

;;  EFI interval timespans
tr_int0         = time_double(tdate[0]+'/'+['16:22:26.830','16:22:33.260'])
tr_int1         = time_double(tdate[0]+'/'+['16:22:39.800','16:22:46.280'])
tr_int2         = time_double(tdate[0]+'/'+['17:30:54.400','17:31:01.000'])
tr_int3         = time_double(tdate[0]+'/'+['17:34:03.600','17:34:10.200'])
tr_int4         = time_double(tdate[0]+'/'+['21:55:23.600','21:55:30.150'])
tr_int5         = time_double(tdate[0]+'/'+['21:55:30.180','21:55:36.650'])
tr_int6         = time_double(tdate[0]+'/'+['22:09:37.900','22:09:44.410'])
tr_int7         = time_double(tdate[0]+'/'+['22:09:44.420','22:09:50.900'])
tr_int8         = time_double(tdate[0]+'/'+['22:20:10.170','22:20:16.620'])
tr_int9         = time_double(tdate[0]+'/'+['22:25:11.460','22:25:17.920'])
tr_int10        = time_double(tdate[0]+'/'+['22:50:00.820','22:50:07.310'])

;;  Interesting interval with 3 wave types [entire EFI timespan]
;tr_int0         = time_double(tdate[0]+'/'+['16:22:26.830','16:22:33.260'])
;;  Timespan with 3 wave types
tr_int0_w       = time_double(tdate[0]+'/'+['16:22:31.922','16:22:33.225'])


;;  Time ranges of the foots and ramps of each bow shock crossing
t_foot_ra0     = time_double(tdate[0]+'/'+['22:09:48.679','22:09:52.218'])
t_foot_ra1     = time_double(tdate[0]+'/'+['22:20:00.150','22:20:10.830'])
t_foot_ra2     = time_double(tdate[0]+'/'+['22:25:00.150','22:25:22.016'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['22:09:48.421','22:09:48.679'])
t_ramp_ra1     = time_double(tdate[0]+'/'+['22:20:10.830','22:20:14.090'])
t_ramp_ra2     = time_double(tdate[0]+'/'+['22:25:15.094','22:25:15.433'])
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
coord_gse      = 'gse'
sc             = probe[0]
scpref         = 'th'+sc[0]+'_'
magname        = scpref[0]+'fgh_'+coord_gse[0]
fgmnm          = scpref[0]+'fgh_'+['mag',coord_gse[0]]

tplot,fgmnm,TRANGE=tr_jj
;;----------------------------------------------------------------------------------------
;; => Restore saved DFs
;;----------------------------------------------------------------------------------------
tr_mom         = tr_aa

sc             = probe[0]
enames         = 'EESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames         = 'IESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_esa_save/'+tdate[0]+'/')
efiles         = FILE_SEARCH(mdir,enames[0])
ifiles         = FILE_SEARCH(mdir,inames[0])
RESTORE,ifiles[0]
;; => Redefine structures
dat_i          = peib_df_arr_e
;; Keep only structures between defined time range
trtt           = time_double(tr_mom)
i_time0        = dat_i.TIME
i_time1        = dat_i.END_TIME
good_i         = WHERE(i_time0 GE trtt[0] AND i_time1 LE trtt[1],gdi)
dat_i          = dat_i[good_i]
n_i            = N_ELEMENTS(dat_i)
PRINT,';;', n_i
;;        1158


RESTORE,efiles[0]
;; => Redefine structures
dat_e          = peeb_df_arr_e
;; Keep only structures between defined time range
trtt           = time_double(tr_mom)
e_time0        = dat_e.TIME
e_time1        = dat_e.END_TIME
good_e         = WHERE(e_time0 GE trtt[0] AND e_time1 LE trtt[1],gde)
dat_e          = dat_e[good_e]
n_e            = N_ELEMENTS(dat_e)
PRINT,';;', n_e
;;        1156
;;----------------------------------------------------------------------------------------
;; => Modify structures so they work in my plotting routines
;;----------------------------------------------------------------------------------------
coord_gse      = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
vn_prefx       = pref[0]+'peib_velocity_'+coord_gse[0]
velname        = tnames(vn_prefx[0])
;velname        = tnames(vn_prefx[0]+'_fixed_3')
;vname_n        = tnames(pref[0]+coord_gse[0]+'_Velocity_peib_no_GIs_UV_2')
vname_n        = tnames(vn_prefx[0]+'_fixed')
magname        = pref[0]+'fgh_'+coord_gse[0]
spperi         = pref[0]+'state_spinper'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
scname         = tnames(pref[0]+'pe*b_sc_pot')

modify_themis_esa_struc,dat_i
;; add SC potential to structures
add_scpot,dat_i,scname[1]
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
add_scpot,dat_e,scname[0]
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











