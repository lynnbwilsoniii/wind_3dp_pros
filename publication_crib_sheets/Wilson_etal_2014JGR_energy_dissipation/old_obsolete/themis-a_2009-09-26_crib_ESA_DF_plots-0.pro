tp_hand0  = ['T_avg','V_Therm','N','Velocity','Tpara','Tperp','Tanisotropy','Pressure']
xsuff     = ''
v_units   = ' (km/s)'
t_units   = ' (eV)'
p_units   = ' (eV/cm!U3!N'+')'
d_units   = ' (#/cm!U3!N'+')'
t_pref    = ['T!D','!N'+t_units]
v_pref    = ['V!D','!N'+v_units]
p_pref    = ['P!D','!N'+p_units]
d_pref    = ['N!D','!N'+d_units]
t_ttle    = t_pref[0]+xsuff+t_pref[1]
vv_ttle   = v_pref[0]+xsuff+v_pref[1]
vt_ttle   = v_pref[0]+'T'+xsuff+v_pref[1]
den_ttle  = d_pref[0]+xsuff+d_pref[1]
tpa_ttle  = t_pref[0]+'!9#!3'+xsuff+t_pref[1]
tpe_ttle  = t_pref[0]+'!9x!3'+xsuff+t_pref[1]
pre_ttle  = p_pref[0]+xsuff+p_pref[1]
tan_ttle  = t_pref[0]+'!9x!3'+xsuff+'!N'+'/'+t_pref[0]+'!9#!3'+xsuff+'!N'
tp_ttles  = [t_ttle,vt_ttle,den_ttle,vv_ttle,tpa_ttle,tpe_ttle,tan_ttle,pre_ttle]

;-----------------------------------------------------------------------------------------
; => Constants
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
epo            = 8.854187817d-12   ; => Permittivity of free space (F/m)
muo            = 4d0*!DPI*1d-7     ; => Permeability of free space (N/A^2 or H/m)
me             = 9.10938291d-31    ; => Electron mass (kg) [2010 value]
mp             = 1.672621777d-27   ; => Proton mass (kg) [2010 value]
ma             = 6.64465675d-27    ; => Alpha-Particle mass (kg) [2010 value]
qq             = 1.602176565d-19   ; => Fundamental charge (C) [2010 value]
kB             = 1.3806488d-23     ; => Boltzmann Constant (J/K) [2010 value]
K_eV           = 1.1604519d4       ; => Factor [Kelvin/eV] [2010 value]
c              = 2.99792458d8      ; => Speed of light in vacuum (m/s)
R_E            = 6.37814d3         ; => Earth's Equitorial Radius (km)

;; => Compile necessary routines
@comp_lynn_pros
thm_init
;; => Date/Time and Probe
tdate          = '2009-09-26'
tr_00          = tdate[0]+'/'+['12:00:00','17:40:00']
;;  Define shock time range of interest
tr_jj          = time_double(tdate[0]+'/'+['15:48:20','15:58:25'])
date           = '092609'
probe          = 'a'
sc             = probe[0]
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
tplot_options,'VERBOSE',0

pref           = 'th'+sc[0]+'_'
pos_gse        = 'th'+sc[0]+'_state_pos_gse'
names          = [pref[0]+'_Rad',pos_gse[0]+['_x','_y','_z']]
tplot_options,VAR_LABEL=names
options,tnames(),'LABFLAG',2,/DEF

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100

coord_in       = 'gse'
pref           = 'th'+sc[0]+'_'
fghgse         = tnames(pref[0]+'fgh_'+coord_in[0])
fghnme         = tnames(pref[0]+'fgh_'+['mag',coord_in[0]])
IF (STRMID(fghnme[0],2,/REVERSE) NE 'mag') THEN fghnme = REVERSE(fghnme)
;;  Electrons
all_Ne_nme     = tnames(pref[0]+'pee*_density')
all_Te_nme     = tnames(pref[0]+'pee*_avgtemp')
all_Ve_nme     = tnames(pref[0]+'pee*_velocity_'+coord_in[0])
all_scpot_e    = tnames(pref[0]+'pee*_sc_pot')

;;  Ions
all_Ni_nme     = tnames(pref[0]+'pei*_density')
all_Ti_nme     = tnames(pref[0]+'pei*_avgtemp')
all_Vi_nme     = tnames(pref[0]+'pei*_velocity_'+coord_in[0])
all_scpot_i    = tnames(pref[0]+'pei*_sc_pot')


;;  Plot Electrons
tplot,[fghnme,all_Ne_nme],TRANGE=tr_jj
tplot,[fghnme,all_Te_nme],TRANGE=tr_jj
tplot,[fghnme,all_Ve_nme],TRANGE=tr_jj
tplot,[fghnme,all_scpot_e],TRANGE=tr_jj

;;  Plot Ions
tplot,[fghnme,all_Ni_nme],TRANGE=tr_jj
tplot,[fghnme,all_Ti_nme],TRANGE=tr_jj
tplot,[fghnme,all_Vi_nme],TRANGE=tr_jj
tplot,[fghnme,all_scpot_i],TRANGE=tr_jj


;;  Plot just burst data
tplot,[fghnme,all_Ni_nme[2],all_Ti_nme[2],all_Te_nme[2],all_Vi_nme[0]],TRANGE=tr_jj

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
PRINT,';;', n_i
;;         749


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
PRINT,';;', n_e
;;         750
;;----------------------------------------------------------------------------------------
;; => Modify structures so they work in my plotting routines
;;----------------------------------------------------------------------------------------
coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
velname   = pref[0]+'peib_velocity_'+coord[0]
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

;;----------------------------------------------------------------------------------------
;; TPLOT stuff
;;----------------------------------------------------------------------------------------
coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
velname   = pref[0]+'peib_velocity_'+coord[0]
magname   = pref[0]+'fgh_'+coord[0]
spperi    = pref[0]+'state_spinper'

get_data,velname[0],DATA=vbulk_str
vbulk     = vbulk_str.Y
v_t       = vbulk_str.X

i_t       = (dat_i.TIME + dat_i.END_TIME)/2d0
vbulkix   = interp(vbulk[*,0],v_t,i_t,/NO_EXTRAP)
vbulkiy   = interp(vbulk[*,1],v_t,i_t,/NO_EXTRAP)
vbulkiz   = interp(vbulk[*,2],v_t,i_t,/NO_EXTRAP)
vbulk_i   = [[vbulkix],[vbulkiy],[vbulkiz]]
;;----------------------------------------------------------------------------------------
;; => Set up plot windows and defaults
;;----------------------------------------------------------------------------------------
WINDOW,1,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,2,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,3,RETAIN=2,XSIZE=800,YSIZE=1100


;-----------------------------------------------------
; IESA
;-----------------------------------------------------
i_time0        = dat_i.TIME
i_time1        = dat_i.END_TIME
tbow0          = time_double(tdate[0]+'/'+['15:48:20','15:58:25'])
good_i0        = WHERE(i_time0 GE tbow0[0] AND i_time1 LE tbow0[1],gdi0)
PRINT,';;', gdi0
;;         194

dat_i0         = dat_i[good_i0]
vsw_i0         = vbulk_i[good_i0,*]

gnorm_0        = [0.97873770d0,-0.11229654d0,-0.059902080d0]
Vgy_rs         = 482.91278d0

ngrid          = 30L
sunv           = [1.,0.,0.]
sunn           = 'Sun Dir.'
xname          = 'B!Do!N'
yname          = 'V!Dsw!N'
vlim           = 25e2
ns             = 7L
smc            = 1
smct           = 1
dfmax          = 1d-1
dfmin          = 1d-15
gnorm          = gnorm_0
normnm         = 'Shock Normal[0]'
vcirc          = Vgy_rs[0]            ;; use both solutions
dfra           = [1d-13,1d-5]
interpo        = 0

;;----------------------------------------------------
;; => Plot using 'fgh' B-fields
;;----------------------------------------------------
j              = 69L
dat_0          = dat_igse[good_i0[j]]
dat_1          = dat_i0[j]
vec2           = REFORM(vsw_i0[j,*])
vname_n        = velname[0]

WSET,1
contour_esa_htr_1plane,dat_0,dat_1,magname[0],vec2,spperi[0],VLIM=vlim[0],NGRID=ngrid[0], $
                       XNAME=xname[0],YNAME=yname[0],SM_CUTS=smc[0],NSMOOTH=ns[0],        $
                       /ONE_C,VCIRC=vcirc,EX_VEC0=gnorm,EX_VN0=normnm[0],                 $
                       EX_VEC1=sunv,EX_VN1=sunn[0],PLANE='xy',/NO_REDF,INTERP=interpo,    $
                       SM_CONT=smct[0],DFRA=dfra,DFMIN=dfmin[0],DFMAX=dfmax[0],           $
                       MAGF_NAME=magname[0],VEL_NAME=vname_n[0]

WSET,2
contour_esa_htr_1plane,dat_0,dat_1,magname[0],vec2,spperi[0],VLIM=vlim[0],NGRID=ngrid[0], $
                       XNAME=xname[0],YNAME=yname[0],SM_CUTS=smc[0],NSMOOTH=ns[0],        $
                       /ONE_C,VCIRC=vcirc,EX_VEC0=gnorm,EX_VN0=normnm[0],                 $
                       EX_VEC1=sunv,EX_VN1=sunn[0],PLANE='xz',/NO_REDF,INTERP=interpo,    $
                       SM_CONT=smct[0],DFRA=dfra,DFMIN=dfmin[0],DFMAX=dfmax[0],           $
                       MAGF_NAME=magname[0],VEL_NAME=vname_n[0]

WSET,3
contour_esa_htr_1plane,dat_0,dat_1,magname[0],vec2,spperi[0],VLIM=vlim[0],NGRID=ngrid[0], $
                       XNAME=xname[0],YNAME=yname[0],SM_CUTS=smc[0],NSMOOTH=ns[0],        $
                       /ONE_C,VCIRC=vcirc,EX_VEC0=gnorm,EX_VN0=normnm[0],                 $
                       EX_VEC1=sunv,EX_VN1=sunn[0],PLANE='yz',/NO_REDF,INTERP=interpo,    $
                       SM_CONT=smct[0],DFRA=dfra,DFMIN=dfmin[0],DFMAX=dfmax[0],           $
                       MAGF_NAME=magname[0],VEL_NAME=vname_n[0]

;;----------------------------------------------------
;; => Plot using 3s averaged B-fields
;;----------------------------------------------------
j              = 69L
dat_0          = dat_igse[good_i0[j]]
vec1           = dat_0.MAGF
vec2           = dat_0.VSW
dfra           = [1d-14,1d-8]

WSET,1
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='xy',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]

WSET,2
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='xz',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]

WSET,3
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='yz',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]















