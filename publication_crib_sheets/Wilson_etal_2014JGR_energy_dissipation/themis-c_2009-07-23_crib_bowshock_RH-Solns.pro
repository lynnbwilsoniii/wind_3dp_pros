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

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='RH Solutions ['+tdate[0]+']'

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
tr_jj          = time_double(tdate[0]+'/'+['17:57:30','18:30:00'])

tplot,fgmnm,TRANGE=tr_jj
;;----------------------------------------------------------------------------------------
;; => Avg. terms [1st Shock]
;;----------------------------------------------------------------------------------------
;;  Upstream
avg_magf_up  = [-0.0836601d0,0.112276d0,-6.04225d0]
avg_vswi_up  = [-488.290d0,82.8993d0,-92.3297d0]
avg_dens_up  =    3.73654d0
avg_Ti_up    =   65.32560d0
avg_Te_up    =    9.42997d0
vshn_up      =  -62.20746d0
ushn_up      = -423.04605d0
gnorm        = [0.99518093d0,0.021020125d0,0.011474467d0]
bmag_up      = NORM(avg_magf_up)
vmag_up      = NORM(avg_vswi_up)
b_dot_n      = my_dot_prod(gnorm,avg_magf_up,/NOM)/(bmag_up[0]*NORM(gnorm))
theta_Bn     = ACOS(b_dot_n[0])*18d1/!DPI
theta_Bn     = theta_Bn[0] < (18d1 - theta_Bn[0])
nkT_up       = (avg_dens_up[0]*1d6)*(kB[0]*K_eV[0]*(avg_Te_up[0] + avg_Ti_up[0]))  ;; plasma pressure [J m^(-3)]
sound_up     = SQRT(5d0*nkT_up[0]/(3d0*(avg_dens_up[0]*1d6)*mp[0]))                ;; sound speed [m/s]
alfven_up    = (bmag_up[0]*1d-9)/SQRT(muo[0]*(avg_dens_up[0]*1d6)*mp[0])           ;; Alfven speed [m/s]
Vs_p_Va_2    = (sound_up[0]^2 + alfven_up[0]^2)
b2_4ac       = Vs_p_Va_2[0]^2 + 4d0*sound_up[0]^2*alfven_up[0]^2*SIN(theta_Bn[0]*!DPI/18d1)^2
fast_up      = SQRT((Vs_p_Va_2[0] + SQRT(b2_4ac[0]))/2d0)
;  Mach numbers
Ma_up        = ABS(ushn_up[0]*1d3/alfven_up[0])
Ms_up        = ABS(ushn_up[0]*1d3/sound_up[0])
Mf_up        = ABS(ushn_up[0]*1d3/fast_up[0])
PRINT,';;', theta_Bn[0], Ma_up[0], Ms_up[0], Mf_up[0]
;;       88.569206       6.2031317       3.8724443       3.0342230


;;  Downstream
avg_magf_dn  = [-1.17367d0,2.16511d0,-19.2497d0]
avg_vswi_dn  = [-167.447d0,102.874d0,-72.4411d0]
avg_dens_dn  =   15.3911d0
avg_Ti_dn    =  279.7200d0
avg_Te_dn    =   51.7205d0
ushn_dn      = -103.1011d0
bmag_dn      = NORM(avg_magf_dn)
vmag_dn      = NORM(avg_vswi_dn)
nkT_dn       = (avg_dens_dn[0]*1d6)*(kB[0]*K_eV[0]*(avg_Te_dn[0] + avg_Ti_dn[0]))  ;; plasma pressure [J m^(-3)]
sound_dn     = SQRT(5d0*nkT_dn[0]/(3d0*(avg_dens_dn[0]*1d6)*mp[0]))
alfven_dn    = (bmag_dn[0]*1d-9)/SQRT(muo[0]*(avg_dens_dn[0]*1d6)*mp[0])           ;; Alfven speed [m/s]
Vs_p_Va_2    = (sound_dn[0]^2 + alfven_dn[0]^2)
b2_4ac       = Vs_p_Va_2[0]^2 + 4d0*sound_dn[0]^2*alfven_dn[0]^2*SIN(theta_Bn[0]*!DPI/18d1)^2
fast_dn      = SQRT((Vs_p_Va_2[0] + SQRT(b2_4ac[0]))/2d0)
;  Mach numbers
Ma_dn        = ABS(ushn_dn[0]*1d3/alfven_dn[0])
Ms_dn        = ABS(ushn_dn[0]*1d3/sound_dn[0])
Mf_dn        = ABS(ushn_dn[0]*1d3/fast_dn[0])
PRINT,';;', theta_Bn[0], Ma_dn[0], Ms_dn[0], Mf_dn[0], avg_dens_dn[0]/avg_dens_up[0]
;;       88.569206      0.95554790      0.44820823      0.38162089       4.1190781

;-----------------------------------------------------
; => Calculate gyrospeeds of specular reflection
;-----------------------------------------------------
; => calculate unit vectors
bhat         = avg_magf_up/bmag_up[0]
vhat         = avg_vswi_up/vmag_up[0]
; => calculate upstream inflow velocity
v_up         = avg_vswi_up - gnorm*ABS(vshn_up[0])
; => Eq. 2 from Gosling et al., [1982]
;      [specularly reflected ion velocity]
Vref_s       = v_up - gnorm*(2d0*my_dot_prod(v_up,gnorm,/NOM))
; => Eq. 4 and 3 from Gosling et al., [1982]
;      [guiding center velocity of a specularly reflected ion]
Vper_r       = v_up - bhat*my_dot_prod(v_up,bhat,/NOM)  ; => Eq. 4
Vgc_r        = Vper_r + bhat*(my_dot_prod(Vref_s,bhat,/NOM))
; => Eq. 6 from Gosling et al., [1982]
;      [gyro-velocity of a specularly reflected ion]
Vgy_r        = Vref_s - Vgc_r
; => Eq. 7 and 9 from Gosling et al., [1982]
;      [guiding center velocity of a specularly reflected ion perp. to shock surface]
Vgcn_r       = my_dot_prod(Vgc_r,gnorm,/NOM)
;      [guiding center velocity of a specularly reflected ion para. to B-field]
Vgcb_r       = my_dot_prod(Vgc_r,bhat,/NOM)
; => gyrospeed and guiding center speed
Vgy_rs       = NORM(REFORM(Vgy_r))
Vgc_rs       = NORM(REFORM(Vgc_r))

PRINT,';;', Vgy_rs[0], Vgc_rs[0]
PRINT,';;', Vgcn_r[0], Vgcb_r[0]
;;       1088.5021       559.65747
;;      -546.22300       74.962358


;;----------------------------------------------------------------------------------------
;; => Avg. terms [2nd Shock]
;;----------------------------------------------------------------------------------------
;;  Upstream
avg_magf_up  = [-0.114245d0,0.135357d0,-6.06984d0]
avg_vswi_up  = [-488.163d0,82.9255d0,-92.5192d0]
avg_dens_up  =    3.71973d0
avg_Ti_up    =   65.21510d0
avg_Te_up    =    9.48648d0
vshn_up      =   13.87071d0
ushn_up      = -506.46806d0
gnorm        = [0.99615338d0,-0.079060538d0,-0.0026399172d0]
bmag_up      = NORM(avg_magf_up)
vmag_up      = NORM(avg_vswi_up)
b_dot_n      = my_dot_prod(gnorm,avg_magf_up,/NOM)/(bmag_up[0]*NORM(gnorm))
theta_Bn     = ACOS(b_dot_n[0])*18d1/!DPI
theta_Bn     = theta_Bn[0] < (18d1 - theta_Bn[0])
nkT_up       = (avg_dens_up[0]*1d6)*(kB[0]*K_eV[0]*(avg_Te_up[0] + avg_Ti_up[0]))  ;; plasma pressure [J m^(-3)]
sound_up     = SQRT(5d0*nkT_up[0]/(3d0*(avg_dens_up[0]*1d6)*mp[0]))                ;; sound speed [m/s]
alfven_up    = (bmag_up[0]*1d-9)/SQRT(muo[0]*(avg_dens_up[0]*1d6)*mp[0])           ;; Alfven speed [m/s]
Vs_p_Va_2    = (sound_up[0]^2 + alfven_up[0]^2)
b2_4ac       = Vs_p_Va_2[0]^2 + 4d0*sound_up[0]^2*alfven_up[0]^2*SIN(theta_Bn[0]*!DPI/18d1)^2
fast_up      = SQRT((Vs_p_Va_2[0] + SQRT(b2_4ac[0]))/2d0)
;  Mach numbers
Ma_up        = ABS(ushn_up[0]*1d3/alfven_up[0])
Ms_up        = ABS(ushn_up[0]*1d3/sound_up[0])
Mf_up        = ABS(ushn_up[0]*1d3/fast_up[0])
PRINT,';;', theta_Bn[0], Ma_up[0], Ms_up[0], Mf_up[0]
;;       88.975636       7.3747873       4.6377409       3.6248076


;;  Downstream
avg_magf_dn  = [1.48669d0,-17.6263d0,-15.3921d0]
avg_vswi_dn  = [-118.835d0,76.1801d0,-62.0601d0]
avg_dens_dn  =   13.67810d0
avg_Ti_dn    =  281.17600d0
avg_Te_dn    =   66.64910d0
ushn_dn      = -138.10784d0
bmag_dn      = NORM(avg_magf_dn)
vmag_dn      = NORM(avg_vswi_dn)
nkT_dn       = (avg_dens_dn[0]*1d6)*(kB[0]*K_eV[0]*(avg_Te_dn[0] + avg_Ti_dn[0]))  ;; plasma pressure [J m^(-3)]
sound_dn     = SQRT(5d0*nkT_dn[0]/(3d0*(avg_dens_dn[0]*1d6)*mp[0]))
alfven_dn    = (bmag_dn[0]*1d-9)/SQRT(muo[0]*(avg_dens_dn[0]*1d6)*mp[0])           ;; Alfven speed [m/s]
Vs_p_Va_2    = (sound_dn[0]^2 + alfven_dn[0]^2)
b2_4ac       = Vs_p_Va_2[0]^2 + 4d0*sound_dn[0]^2*alfven_dn[0]^2*SIN(theta_Bn[0]*!DPI/18d1)^2
fast_dn      = SQRT((Vs_p_Va_2[0] + SQRT(b2_4ac[0]))/2d0)
;  Mach numbers
Ma_dn        = ABS(ushn_dn[0]*1d3/alfven_dn[0])
Ms_dn        = ABS(ushn_dn[0]*1d3/sound_dn[0])
Mf_dn        = ABS(ushn_dn[0]*1d3/fast_dn[0])
PRINT,';;', theta_Bn[0], Ma_dn[0], Ms_dn[0], Mf_dn[0], avg_dens_dn[0]/avg_dens_up[0]
;;       88.975636      0.99868229      0.58608038      0.46856986       3.6771755

;-----------------------------------------------------
; => Calculate gyrospeeds of specular reflection
;-----------------------------------------------------
; => calculate unit vectors
bhat         = avg_magf_up/bmag_up[0]
vhat         = avg_vswi_up/vmag_up[0]
; => calculate upstream inflow velocity
v_up         = avg_vswi_up - gnorm*ABS(vshn_up[0])
; => Eq. 2 from Gosling et al., [1982]
;      [specularly reflected ion velocity]
Vref_s       = v_up - gnorm*(2d0*my_dot_prod(v_up,gnorm,/NOM))
; => Eq. 4 and 3 from Gosling et al., [1982]
;      [guiding center velocity of a specularly reflected ion]
Vper_r       = v_up - bhat*my_dot_prod(v_up,bhat,/NOM)  ; => Eq. 4
Vgc_r        = Vper_r + bhat*(my_dot_prod(Vref_s,bhat,/NOM))
; => Eq. 6 from Gosling et al., [1982]
;      [gyro-velocity of a specularly reflected ion]
Vgy_r        = Vref_s - Vgc_r
; => Eq. 7 and 9 from Gosling et al., [1982]
;      [guiding center velocity of a specularly reflected ion perp. to shock surface]
Vgcn_r       = my_dot_prod(Vgc_r,gnorm,/NOM)
;      [guiding center velocity of a specularly reflected ion para. to B-field]
Vgcb_r       = my_dot_prod(Vgc_r,bhat,/NOM)
; => gyrospeed and guiding center speed
Vgy_rs       = NORM(REFORM(Vgy_r))
Vgc_rs       = NORM(REFORM(Vgc_r))

PRINT,';;', Vgy_rs[0], Vgc_rs[0]
PRINT,';;', Vgcn_r[0], Vgcb_r[0]
;;       1012.0146       513.97405
;;      -506.12485       85.664989


;;----------------------------------------------------------------------------------------
;; => Avg. terms [3rd Shock]
;;----------------------------------------------------------------------------------------
;;  Upstream
avg_magf_up  = [3.88880d0,-4.95385d0,1.12260d0]
avg_vswi_up  = [-456.419d0,57.8130d0,7.73230d0]
avg_dens_up  =    3.88664d0
avg_Ti_up    =   53.45130d0
avg_Te_up    =   14.07640d0
vshn_up      =  -33.929926d0
ushn_up      = -415.52490d0
gnorm        = [0.99282966d0,0.064151304d0,-0.0022364971d0]
bmag_up      = NORM(avg_magf_up)
vmag_up      = NORM(avg_vswi_up)
b_dot_n      = my_dot_prod(gnorm,avg_magf_up,/NOM)/(bmag_up[0]*NORM(gnorm))
theta_Bn     = ACOS(b_dot_n[0])*18d1/!DPI
theta_Bn     = theta_Bn[0] < (18d1 - theta_Bn[0])
nkT_up       = (avg_dens_up[0]*1d6)*(kB[0]*K_eV[0]*(avg_Te_up[0] + avg_Ti_up[0]))  ;; plasma pressure [J m^(-3)]
sound_up     = SQRT(5d0*nkT_up[0]/(3d0*(avg_dens_up[0]*1d6)*mp[0]))                ;; sound speed [m/s]
alfven_up    = (bmag_up[0]*1d-9)/SQRT(muo[0]*(avg_dens_up[0]*1d6)*mp[0])           ;; Alfven speed [m/s]
Vs_p_Va_2    = (sound_up[0]^2 + alfven_up[0]^2)
b2_4ac       = Vs_p_Va_2[0]^2 + 4d0*sound_up[0]^2*alfven_up[0]^2*SIN(theta_Bn[0]*!DPI/18d1)^2
fast_up      = SQRT((Vs_p_Va_2[0] + SQRT(b2_4ac[0]))/2d0)
;  Mach numbers
Ma_up        = ABS(ushn_up[0]*1d3/alfven_up[0])
Ms_up        = ABS(ushn_up[0]*1d3/sound_up[0])
Mf_up        = ABS(ushn_up[0]*1d3/fast_up[0])
PRINT,';;', theta_Bn[0], Ma_up[0], Ms_up[0], Mf_up[0]
;;       56.199579       5.8708497       4.0019843       3.1078444


;;  Downstream
avg_magf_dn  = [4.13227d0,-15.5434d0,2.96303d0]
avg_vswi_dn  = [-191.874d0,80.5858d0,-7.70972d0]
avg_dens_dn  =   10.9126d0
avg_Ti_dn    =  311.0500d0
avg_Te_dn    =   56.7890d0
ushn_dn      = -151.38092d0
bmag_dn      = NORM(avg_magf_dn)
vmag_dn      = NORM(avg_vswi_dn)
nkT_dn       = (avg_dens_dn[0]*1d6)*(kB[0]*K_eV[0]*(avg_Te_dn[0] + avg_Ti_dn[0]))  ;; plasma pressure [J m^(-3)]
sound_dn     = SQRT(5d0*nkT_dn[0]/(3d0*(avg_dens_dn[0]*1d6)*mp[0]))
alfven_dn    = (bmag_dn[0]*1d-9)/SQRT(muo[0]*(avg_dens_dn[0]*1d6)*mp[0])           ;; Alfven speed [m/s]
Vs_p_Va_2    = (sound_dn[0]^2 + alfven_dn[0]^2)
b2_4ac       = Vs_p_Va_2[0]^2 + 4d0*sound_dn[0]^2*alfven_dn[0]^2*SIN(theta_Bn[0]*!DPI/18d1)^2
fast_dn      = SQRT((Vs_p_Va_2[0] + SQRT(b2_4ac[0]))/2d0)
;  Mach numbers
Ma_dn        = ABS(ushn_dn[0]*1d3/alfven_dn[0])
Ms_dn        = ABS(ushn_dn[0]*1d3/sound_dn[0])
Mf_dn        = ABS(ushn_dn[0]*1d3/fast_dn[0])
PRINT,';;', theta_Bn[0], Ma_dn[0], Ms_dn[0], Mf_dn[0], avg_dens_dn[0]/avg_dens_up[0]
;;       56.199579       1.4018958      0.62468570      0.54710160       2.8077208

;-----------------------------------------------------
; => Calculate gyrospeeds of specular reflection
;-----------------------------------------------------
; => calculate unit vectors
bhat         = avg_magf_up/bmag_up[0]
vhat         = avg_vswi_up/vmag_up[0]
; => calculate upstream inflow velocity
v_up         = avg_vswi_up - gnorm*ABS(vshn_up[0])
; => Eq. 2 from Gosling et al., [1982]
;      [specularly reflected ion velocity]
Vref_s       = v_up - gnorm*(2d0*my_dot_prod(v_up,gnorm,/NOM))
; => Eq. 4 and 3 from Gosling et al., [1982]
;      [guiding center velocity of a specularly reflected ion]
Vper_r       = v_up - bhat*my_dot_prod(v_up,bhat,/NOM)  ; => Eq. 4
Vgc_r        = Vper_r + bhat*(my_dot_prod(Vref_s,bhat,/NOM))
; => Eq. 6 from Gosling et al., [1982]
;      [gyro-velocity of a specularly reflected ion]
Vgy_r        = Vref_s - Vgc_r
; => Eq. 7 and 9 from Gosling et al., [1982]
;      [guiding center velocity of a specularly reflected ion perp. to shock surface]
Vgcn_r       = my_dot_prod(Vgc_r,gnorm,/NOM)
;      [guiding center velocity of a specularly reflected ion para. to B-field]
Vgcb_r       = my_dot_prod(Vgc_r,bhat,/NOM)
; => gyrospeed and guiding center speed
Vgy_rs       = NORM(REFORM(Vgy_r))
Vgc_rs       = NORM(REFORM(Vgc_r))

PRINT,';;', Vgy_rs[0], Vgc_rs[0]
PRINT,';;', Vgcn_r[0], Vgcb_r[0]
;;       798.70090       407.48385
;;      -187.10580       195.04577



;;----------------------------------------------------------------------------------------
;; => smooth Bo
;;----------------------------------------------------------------------------------------
coord          = 'gse'
fglnm          = pref[0]+'fgl_'+coord[0]
get_data,fglnm[0],DATA=th_magf,DLIM=dlim,LIM=lim
;; => Smooth the B-field [for Avg. or <B> upstream and downstream]
nsm            = 30L
nsms           = STRING(FORMAT='(I3.3)',nsm[0])
suffx          = '_sm'+nsms[0]+'pts'
name1          = fglnm[0]+suffx[0]
xmagf          = SMOOTH(th_magf.Y[*,0],nsm[0],/NAN,/EDGE_TRUNCATE)
ymagf          = SMOOTH(th_magf.Y[*,1],nsm[0],/NAN,/EDGE_TRUNCATE)
zmagf          = SMOOTH(th_magf.Y[*,2],nsm[0],/NAN,/EDGE_TRUNCATE)
smmagf         = [[xmagf],[ymagf],[zmagf]]
smbmag         = SQRT(TOTAL(smmagf^2,2,/NAN))
smmagf         = [[xmagf],[ymagf],[zmagf],[smbmag]]
store_data,name1[0],DATA={X:th_magf.X,Y:smmagf},DLIM=dlim,LIM=lim
options,name1[0],'COLORS',[250,150,50,25],/DEF
options,name1[0],'LABELS',['Bx','By','Bz','|B|'],/DEF
sm_fgmnm       = name1[0]

options,tnames(),'LABFLAG',2,/DEF

;;----------------------------------------------------------------------------------------
;; => Get parameters used in RH relations
;;----------------------------------------------------------------------------------------
nsm            = 30L
nsms           = STRING(FORMAT='(I3.3)',nsm[0])
suffx          = '_sm'+nsms[0]+'pts'
pref           = 'th'+sc[0]+'_'
coord_in       = 'gse'
peib_tn        = 'peib_'
peeb_tn        = 'peeb_'

coord          = 'gse'
fglnm          = pref[0]+'fgl_'+coord[0]
sm_fgmnm       = fglnm[0]+suffx[0]
velnm0         = pref[0]+'Velocity_'+peib_tn[0]+'no_GIs_UV_2'
vsw_name       = tnames(velnm0[0])
den_name       = tnames(pref[0]+'N_'+peib_tn[0]+'no_GIs_UV')
Ti__name       = tnames(pref[0]+'T_avg_'+peib_tn[0]+'no_GIs_UV')
Te__name       = tnames(pref[0]+peeb_tn[0]+'avgtemp')
Pi__name       = tnames(pref[0]+'Pressure_'+peib_tn[0]+'no_GIs_UV')
fglgse         = tnames(sm_fgmnm[0])

;;  Bo
get_data,fglgse[0],DATA=th_magf
;;  Ni
get_data,den_name[0],DATA=ti_dens
;;  Ti
get_data,Ti__name[0],DATA=ti_stru
;;  Vsw
get_data,vsw_name[0],DATA=ti_vsw
;;  Te
get_data,Te__name[0],DATA=te_stru
;;  Pi
get_data,Pi__name[0],DATA=ti_pres
;;----------------------------------------------------------------------------------------
;; => Avg. terms [1st Shock]
;;----------------------------------------------------------------------------------------
tr_up          = time_double(tdate[0]+'/'+['18:05:52.200','18:06:37.200'])
tr_dn          = time_double(tdate[0]+'/'+['18:02:25.800','18:03:10.800'])
t_ramp_se      = time_double(tdate[0]+'/'+['18:04:47.030','18:04:58.920'])

good_up_Bo     = WHERE(th_magf.X GE tr_up[0] AND th_magf.X LE tr_up[1],gdupBo)
good_up_Ni     = WHERE(ti_dens.X GE tr_up[0] AND ti_dens.X LE tr_up[1],gdupNi)
good_up_Ti     = WHERE(ti_stru.X GE tr_up[0] AND ti_stru.X LE tr_up[1],gdupTi)
good_up_Te     = WHERE(te_stru.X GE tr_up[0] AND te_stru.X LE tr_up[1],gdupTe)
good_up_Vi     = WHERE(ti_vsw.X  GE tr_up[0] AND ti_vsw.X  LE tr_up[1],gdupVi)
good_up_Pi     = WHERE(ti_pres.X GE tr_up[0] AND ti_pres.X LE tr_up[1],gdupPi)

good_dn_Bo     = WHERE(th_magf.X GE tr_dn[0] AND th_magf.X LE tr_dn[1],gddnBo)
good_dn_Ni     = WHERE(ti_dens.X GE tr_dn[0] AND ti_dens.X LE tr_dn[1],gddnNi)
good_dn_Ti     = WHERE(ti_stru.X GE tr_dn[0] AND ti_stru.X LE tr_dn[1],gddnTi)
good_dn_Te     = WHERE(te_stru.X GE tr_dn[0] AND te_stru.X LE tr_dn[1],gddnTe)
good_dn_Vi     = WHERE(ti_vsw.X  GE tr_dn[0] AND ti_vsw.X  LE tr_dn[1],gddnVi)
good_dn_Pi     = WHERE(ti_pres.X GE tr_dn[0] AND ti_pres.X LE tr_dn[1],gddnPi)

PRINT,';;', gdupBo, gdupNi, gdupTi, gdupTe, gdupVi, gdupPi
PRINT,';;', gddnBo, gddnNi, gddnTi, gddnTe, gddnVi, gddnPi
;;         180          15          15          15          15          15
;;         180          15          15          15          15          15

;; => Interpolate to ion times
;;  Bo
tx_magf        = interp(th_magf.Y[*,0],th_magf.X,ti_dens.X,/NO_EXTRAP)
ty_magf        = interp(th_magf.Y[*,1],th_magf.X,ti_dens.X,/NO_EXTRAP)
tz_magf        = interp(th_magf.Y[*,2],th_magf.X,ti_dens.X,/NO_EXTRAP)
tm_magf        = [[tx_magf],[ty_magf],[tz_magf]]
;;  Ti
ti_temp        = interp(ti_stru.Y,ti_stru.X,ti_dens.X,/NO_EXTRAP)
;;  Pi
pi_temp        = interp(ti_pres.Y,ti_pres.X,ti_dens.X,/NO_EXTRAP)
;;  Te
te_temp        = interp(te_stru.Y,te_stru.X,ti_dens.X,/NO_EXTRAP)
;;  Vsw
vswx           = interp(ti_vsw.Y[*,0],ti_vsw.X,ti_dens.X,/NO_EXTRAP)
vswy           = interp(ti_vsw.Y[*,1],ti_vsw.X,ti_dens.X,/NO_EXTRAP)
vswz           = interp(ti_vsw.Y[*,2],ti_vsw.X,ti_dens.X,/NO_EXTRAP)

;; => Define [up,down]stream
up_magf        = FLOAT(tm_magf[good_up_Ni,*])
vswx_up        = FLOAT(vswx[good_up_Ni])
vswy_up        = FLOAT(vswy[good_up_Ni])
vswz_up        = FLOAT(vswz[good_up_Ni])
up_Ti          = FLOAT(ti_temp[good_up_Ni])
up_Te          = FLOAT(te_temp[good_up_Ni])
up_Ni          = FLOAT(ti_dens.Y[good_up_Ni])
up_Pi          = FLOAT(pi_temp[good_up_Ni])

dn_magf        = FLOAT(tm_magf[good_dn_Ni,*])
vswx_dn        = FLOAT(vswx[good_dn_Ni])
vswy_dn        = FLOAT(vswy[good_dn_Ni])
vswz_dn        = FLOAT(vswz[good_dn_Ni])
dn_Ti          = FLOAT(ti_temp[good_dn_Ni])
dn_Te          = FLOAT(te_temp[good_dn_Ni])
dn_Ni          = FLOAT(ti_dens.Y[good_dn_Ni])
dn_Pi          = FLOAT(pi_temp[good_dn_Ni])

PRINT,';;', up_Ni
PRINT,';;', up_Ti
PRINT,';;', up_Te
PRINT,';;', up_Pi
;;      3.97767      3.71400      3.67120      3.72781      3.64282      3.62596      3.72209      3.68114      3.62656      3.75548      3.73672      3.76154      3.86371      3.84768      3.69372
;;      65.5496      66.5383      64.0601      65.4925      65.8209      64.6496      65.4988      66.0537      66.0473      67.9845      64.4572      65.8322      64.1350      63.7507      64.0134
;;      9.06374      9.06151      11.7931      9.29861      9.62223      9.14771      8.99538      9.02639      9.12409      9.01857      9.20982      9.22978      9.39782      9.93921      9.52153
;;      16.5202      14.3821      15.0373      13.7814      13.1362      13.8643      14.4602      13.5135      13.4873      12.6477      16.4646      16.5847      14.9911      18.6817      14.9081
PRINT,';;', vswx_up
PRINT,';;', vswy_up
PRINT,';;', vswz_up
;;     -487.003     -491.221     -482.000     -489.754     -489.004     -488.383     -491.927     -491.405     -492.613     -496.530     -483.834     -490.901     -483.494     -479.404     -486.873
;;      82.7046      82.7534      82.2147      82.9912      83.2759      83.3102      83.8608      83.7969      83.3719      83.6011      81.7873      83.3698      81.7884      81.6210      83.0429
;;     -90.2416     -91.9541     -90.9088     -92.0312     -88.2150     -94.0726     -94.0077     -91.8656     -92.5525     -87.8669     -93.6643     -95.1515     -93.4061     -93.8795     -95.1282
PRINT,';;', up_magf[*,0]
PRINT,';;', up_magf[*,1]
PRINT,';;', up_magf[*,2]
;;   -0.0105438     0.240829     0.335204     0.405830    0.0845831    -0.131994    -0.238947    -0.273008    -0.545304    -0.422076    -0.218986   -0.0632742    -0.111547    -0.104104    -0.201564
;;   -0.0170248   -0.0584700   -0.0335167     0.337760     0.222312     0.313244     0.290398     0.364247     0.253711     0.102740    -0.104149    -0.101017   -0.0151983     0.141721   -0.0126139
;;     -5.83439     -5.89134     -5.78036     -5.62734     -5.73847     -5.82742     -5.88058     -5.89138     -5.98315     -6.14102     -6.09644     -6.18463     -6.57868     -6.61921     -6.55928


PRINT,';;', dn_Ni
PRINT,';;', dn_Ti
PRINT,';;', dn_Te
PRINT,';;', dn_Pi
;;      17.9649      15.0112      14.6180      15.7014      15.2841      15.6614      17.3150      15.3803      13.8548      13.9105      16.3824      14.5374      16.7691      14.8325      13.6442
;;      260.098      269.390      276.318      276.318      270.643      261.406      283.695      292.879      254.769      279.457      324.743      291.094      277.876      276.575      300.536
;;      50.5250      49.0110      51.5541      52.4552      50.7236      48.8540      52.4923      50.7374      50.2526      50.7305      49.9982      56.3705      56.8171      54.3629      50.9233
;;      1561.58      1316.39      1553.81      1432.65      1475.60      1452.85      1834.08      1384.44      1202.48      1569.27      1795.81      1327.27      1742.55      1551.29      1469.19
PRINT,';;', vswx_dn
PRINT,';;', vswy_dn
PRINT,';;', vswz_dn
;;     -182.106     -154.076     -157.799     -162.897     -167.926     -133.983     -125.095     -154.407     -166.946     -214.533     -177.796     -173.203     -158.082     -191.475     -191.376
;;      107.113      145.660      106.945      124.987      83.8093      116.913      81.1765      65.0305      111.839      131.283      99.3800      94.8911      99.5053      85.9613      88.6184
;;     -83.5994     -66.1128     -69.3262     -68.2721     -91.5677     -78.5621     -52.7817     -77.4790     -82.4358     -79.4540     -79.4551     -60.5087     -54.3915     -75.7553     -66.9158
PRINT,';;', dn_magf[*,0]
PRINT,';;', dn_magf[*,1]
PRINT,';;', dn_magf[*,2]
;;     -2.91669    -0.381075    -0.737598     -1.37121     -2.47889     -3.36334     -2.65815     -2.10047    -0.922715     -1.05123     0.648970      1.82977      1.72159    -0.734504     -3.08950
;;      2.70848      4.45549      3.23752      3.18469      3.13658      3.36129      2.29248      2.53826      1.67842     0.156594    -0.255658    -0.200885      1.93085      1.66931      2.58318
;;     -19.8145     -20.5926     -20.3435     -20.2276     -21.7872     -20.7436     -19.3119     -19.3776     -19.1816     -18.6223     -18.3615     -19.4741     -18.4206     -16.6863     -15.8009

;; => Upstream values
dens_up        = [3.97767,3.71400,3.67120,3.72781,3.64282,3.62596,3.72209,3.68114,3.62656,3.75548,3.73672,3.76154,3.86371,3.84768,3.69372]
ti_avg_up      = [65.5496,66.5383,64.0601,65.4925,65.8209,64.6496,65.4988,66.0537,66.0473,67.9845,64.4572,65.8322,64.1350,63.7507,64.0134]
te_avg_up      = [9.06374,9.06151,11.7931,9.29861,9.62223,9.14771,8.99538,9.02639,9.12409,9.01857,9.20982,9.22978,9.39782,9.93921,9.52153]
Pi_up          = [16.5202,14.3821,15.0373,13.7814,13.1362,13.8643,14.4602,13.5135,13.4873,12.6477,16.4646,16.5847,14.9911,18.6817,14.9081]
vsw_x_up       = [-487.003,-491.221,-482.000,-489.754,-489.004,-488.383,-491.927,-491.405,-492.613,-496.530,-483.834,-490.901,-483.494,-479.404,-486.873]
vsw_y_up       = [ 82.7046,82.7534,82.2147,82.9912,83.2759,83.3102,83.8608,83.7969,83.3719,83.6011,81.7873,83.3698,81.7884,81.6210,83.0429]
vsw_z_up       = [-90.2416,-91.9541,-90.9088,-92.0312,-88.2150,-94.0726,-94.0077,-91.8656,-92.5525,-87.8669,-93.6643,-95.1515,-93.4061,-93.8795,-95.1282]
vsw_up         = [[vsw_x_up],[vsw_y_up],[vsw_z_up]]
mag_x_up       = [-0.0105438,0.240829,0.335204,0.405830,0.0845831,-0.131994,-0.238947,-0.273008,-0.545304,-0.422076,-0.218986,-0.0632742,-0.111547,-0.104104,-0.201564]
mag_y_up       = [-0.0170248,-0.0584700,-0.0335167,0.337760,0.222312,0.313244,0.290398,0.364247,0.253711,0.102740,-0.104149,-0.101017,-0.0151983,0.141721,-0.0126139]
mag_z_up       = [  -5.83439,-5.89134,-5.78036,-5.62734,-5.73847,-5.82742,-5.88058,-5.89138,-5.98315,-6.14102,-6.09644,-6.18463,-6.57868,-6.61921,-6.55928]
magf_up        = [[mag_x_up],[mag_y_up],[mag_z_up]]
temp_up        = te_avg_up + ti_avg_up
PRINT,';;', MEAN(dens_up,/NAN),  MEAN(ti_avg_up,/NAN),  MEAN(te_avg_up,/NAN)
PRINT,';;', MEAN(vsw_x_up,/NAN), MEAN(vsw_y_up,/NAN), MEAN(vsw_z_up,/NAN)
PRINT,';;', MEAN(mag_x_up,/NAN), MEAN(mag_y_up,/NAN), MEAN(mag_z_up,/NAN)
;;      3.73654      65.3256      9.42997
;;     -488.290      82.8993     -92.3297
;;   -0.0836601     0.112276     -6.04225


;; => Downstream values
dens_dn        = [17.9649,15.0112,14.6180,15.7014,15.2841,15.6614,17.3150,15.3803,13.8548,13.9105,16.3824,14.5374,16.7691,14.8325,13.6442]
ti_avg_dn      = [260.098,269.390,276.318,276.318,270.643,261.406,283.695,292.879,254.769,279.457,324.743,291.094,277.876,276.575,300.536]
te_avg_dn      = [50.5250,49.0110,51.5541,52.4552,50.7236,48.8540,52.4923,50.7374,50.2526,50.7305,49.9982,56.3705,56.8171,54.3629,50.9233]
Pi_dn          = [1561.58,1316.39,1553.81,1432.65,1475.60,1452.85,1834.08,1384.44,1202.48,1569.27,1795.81,1327.27,1742.55,1551.29,1469.19]
vsw_x_dn       = [-182.106,-154.076,-157.799,-162.897,-167.926,-133.983,-125.095,-154.407,-166.946,-214.533,-177.796,-173.203,-158.082,-191.475,-191.376]
vsw_y_dn       = [ 107.113,145.660,106.945,124.987,83.8093,116.913,81.1765,65.0305,111.839,131.283,99.3800,94.8911,99.5053,85.9613,88.6184]
vsw_z_dn       = [-83.5994,-66.1128,-69.3262,-68.2721,-91.5677,-78.5621,-52.7817,-77.4790,-82.4358,-79.4540,-79.4551,-60.5087,-54.3915,-75.7553,-66.9158]
vsw_dn         = [[vsw_x_dn],[vsw_y_dn],[vsw_z_dn]]
mag_x_dn       = [-2.91669,-0.381075,-0.737598,-1.37121,-2.47889,-3.36334,-2.65815,-2.10047,-0.922715,-1.05123,0.648970,1.82977,1.72159,-0.734504,-3.08950]
mag_y_dn       = [ 2.70848,4.45549,3.23752,3.18469,3.13658,3.36129,2.29248,2.53826,1.67842,0.156594,-0.255658,-0.200885,1.93085,1.66931,2.58318]
mag_z_dn       = [-19.8145,-20.5926,-20.3435,-20.2276,-21.7872,-20.7436,-19.3119,-19.3776,-19.1816,-18.6223,-18.3615,-19.4741,-18.4206,-16.6863,-15.8009]
magf_dn        = [[mag_x_dn],[mag_y_dn],[mag_z_dn]]
temp_dn        = te_avg_dn + ti_avg_dn
PRINT,';;', MEAN(dens_dn,/NAN),  MEAN(ti_avg_dn,/NAN),  MEAN(te_avg_dn,/NAN)
PRINT,';;', MEAN(vsw_x_dn,/NAN), MEAN(vsw_y_dn,/NAN), MEAN(vsw_z_dn,/NAN)
PRINT,';;', MEAN(mag_x_dn,/NAN), MEAN(mag_y_dn,/NAN), MEAN(mag_z_dn,/NAN)
;;      15.3911      279.720      51.7205
;;     -167.447      102.874     -72.4411
;;     -1.17367      2.16511     -19.2497

;; => combine terms
vsw      = [[[vsw_up]],[[vsw_dn]]]
mag      = [[[magf_up]],[[magf_dn]]]
dens     = [[dens_up],[dens_dn]]
temp     = [[temp_up],[temp_dn]]

.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/rh_pros/temp_rh_soln_print.pro
temp_rh_soln_print,dens,vsw,mag,temp,tdate[0],NMAX=120L
;; => Print out best fit poloidal angles
PRINT,';', soln.THETA*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;       1.3008403       4.9184867
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;      0.65871510       5.3398098
;;-----------------------------------------------------------

;; => Print out best fit azimuthal angles
PRINT,';', soln.PHI*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;       1.2100840       1.5622118
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;       1.2100840       1.5622118
;;-----------------------------------------------------------

;; => Print out best fit shock normal speed in spacecraft frame [km/s]
PRINT,';', soln.VSHN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;      -62.974493       24.429010
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;      -62.207463       24.453869
;;-----------------------------------------------------------

;; => Print out best fit upstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_UP
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;      -423.54053       25.717983
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;      -423.04605       25.719977
;;-----------------------------------------------------------

;; => Print out best fit downstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_DN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;      -103.22147       7.6977287
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;      -103.10106       7.6974835
;;-----------------------------------------------------------

;; => Print out best fit shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,0]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;      0.99565371     0.021030111     0.022646302
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;      0.99518093     0.021020125     0.011474467
;;-----------------------------------------------------------

;; => Print out best fit uncertainty in shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,1]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;    0.0031329205     0.025808391     0.084004076
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;    0.0033696292     0.025786150     0.091520592
;;-----------------------------------------------------------


;;----------------------------------------------------------------------------------------
;; => Avg. terms [2nd Shock]
;;----------------------------------------------------------------------------------------
tr_up          = time_double(tdate[0]+'/'+['18:05:57.300','18:06:38.300'])
tr_dn          = time_double(tdate[0]+'/'+['18:10:05.400','18:10:46.400'])
t_foot_se      = time_double(tdate[0]+'/'+['18:06:46.780','18:07:07.340'])
t_ramp_se      = time_double(tdate[0]+'/'+['18:07:07.340','18:07:08.100'])

good_up_Bo     = WHERE(th_magf.X GE tr_up[0] AND th_magf.X LE tr_up[1],gdupBo)
good_up_Ni     = WHERE(ti_dens.X GE tr_up[0] AND ti_dens.X LE tr_up[1],gdupNi)
good_up_Ti     = WHERE(ti_stru.X GE tr_up[0] AND ti_stru.X LE tr_up[1],gdupTi)
good_up_Te     = WHERE(te_stru.X GE tr_up[0] AND te_stru.X LE tr_up[1],gdupTe)
good_up_Vi     = WHERE(ti_vsw.X  GE tr_up[0] AND ti_vsw.X  LE tr_up[1],gdupVi)
good_up_Pi     = WHERE(ti_pres.X GE tr_up[0] AND ti_pres.X LE tr_up[1],gdupPi)

good_dn_Bo     = WHERE(th_magf.X GE tr_dn[0] AND th_magf.X LE tr_dn[1],gddnBo)
good_dn_Ni     = WHERE(ti_dens.X GE tr_dn[0] AND ti_dens.X LE tr_dn[1],gddnNi)
good_dn_Ti     = WHERE(ti_stru.X GE tr_dn[0] AND ti_stru.X LE tr_dn[1],gddnTi)
good_dn_Te     = WHERE(te_stru.X GE tr_dn[0] AND te_stru.X LE tr_dn[1],gddnTe)
good_dn_Vi     = WHERE(ti_vsw.X  GE tr_dn[0] AND ti_vsw.X  LE tr_dn[1],gddnVi)
good_dn_Pi     = WHERE(ti_pres.X GE tr_dn[0] AND ti_pres.X LE tr_dn[1],gddnPi)

PRINT,';;', gdupBo, gdupNi, gdupTi, gdupTe, gdupVi, gdupPi
PRINT,';;', gddnBo, gddnNi, gddnTi, gddnTe, gddnVi, gddnPi
;;         164          13          13          13          13          13
;;         164          13          13          13          13          13

;; => Interpolate to ion times
;;  Bo
tx_magf        = interp(th_magf.Y[*,0],th_magf.X,ti_dens.X,/NO_EXTRAP)
ty_magf        = interp(th_magf.Y[*,1],th_magf.X,ti_dens.X,/NO_EXTRAP)
tz_magf        = interp(th_magf.Y[*,2],th_magf.X,ti_dens.X,/NO_EXTRAP)
tm_magf        = [[tx_magf],[ty_magf],[tz_magf]]
;;  Ti
ti_temp        = interp(ti_stru.Y,ti_stru.X,ti_dens.X,/NO_EXTRAP)
;;  Pi
pi_temp        = interp(ti_pres.Y,ti_pres.X,ti_dens.X,/NO_EXTRAP)
;;  Te
te_temp        = interp(te_stru.Y,te_stru.X,ti_dens.X,/NO_EXTRAP)
;;  Vsw
vswx           = interp(ti_vsw.Y[*,0],ti_vsw.X,ti_dens.X,/NO_EXTRAP)
vswy           = interp(ti_vsw.Y[*,1],ti_vsw.X,ti_dens.X,/NO_EXTRAP)
vswz           = interp(ti_vsw.Y[*,2],ti_vsw.X,ti_dens.X,/NO_EXTRAP)

;; => Define [up,down]stream
up_magf        = FLOAT(tm_magf[good_up_Ni,*])
vswx_up        = FLOAT(vswx[good_up_Ni])
vswy_up        = FLOAT(vswy[good_up_Ni])
vswz_up        = FLOAT(vswz[good_up_Ni])
up_Ti          = FLOAT(ti_temp[good_up_Ni])
up_Te          = FLOAT(te_temp[good_up_Ni])
up_Ni          = FLOAT(ti_dens.Y[good_up_Ni])
up_Pi          = FLOAT(pi_temp[good_up_Ni])

dn_magf        = FLOAT(tm_magf[good_dn_Ni,*])
vswx_dn        = FLOAT(vswx[good_dn_Ni])
vswy_dn        = FLOAT(vswy[good_dn_Ni])
vswz_dn        = FLOAT(vswz[good_dn_Ni])
dn_Ti          = FLOAT(ti_temp[good_dn_Ni])
dn_Te          = FLOAT(te_temp[good_dn_Ni])
dn_Ni          = FLOAT(ti_dens.Y[good_dn_Ni])
dn_Pi          = FLOAT(pi_temp[good_dn_Ni])

PRINT,';;', up_Ni
PRINT,';;', up_Ti
PRINT,';;', up_Te
PRINT,';;', up_Pi
;;      3.67120      3.72781      3.64282      3.62596      3.72209      3.68114      3.62656      3.75548      3.73672      3.76154      3.86371      3.84768      3.69372
;;      64.0601      65.4925      65.8209      64.6496      65.4988      66.0537      66.0473      67.9845      64.4572      65.8322      64.1350      63.7507      64.0134
;;      11.7931      9.29861      9.62223      9.14771      8.99538      9.02639      9.12409      9.01857      9.20982      9.22978      9.39782      9.93921      9.52153
;;      15.0373      13.7814      13.1362      13.8643      14.4602      13.5135      13.4873      12.6477      16.4646      16.5847      14.9911      18.6817      14.9081
PRINT,';;', vswx_up
PRINT,';;', vswy_up
PRINT,';;', vswz_up
;;     -482.000     -489.754     -489.004     -488.383     -491.927     -491.405     -492.613     -496.530     -483.834     -490.901     -483.494     -479.404     -486.873
;;      82.2147      82.9912      83.2759      83.3102      83.8608      83.7969      83.3719      83.6011      81.7873      83.3698      81.7884      81.6210      83.0429
;;     -90.9088     -92.0312     -88.2150     -94.0726     -94.0077     -91.8656     -92.5525     -87.8669     -93.6643     -95.1515     -93.4061     -93.8795     -95.1282
PRINT,';;', up_magf[*,0]
PRINT,';;', up_magf[*,1]
PRINT,';;', up_magf[*,2]
;;     0.335204     0.405830    0.0845831    -0.131994    -0.238947    -0.273008    -0.545304    -0.422076    -0.218986   -0.0632742    -0.111547    -0.104104    -0.201564
;;   -0.0335167     0.337760     0.222312     0.313244     0.290398     0.364247     0.253711     0.102740    -0.104149    -0.101017   -0.0151983     0.141721   -0.0126139
;;     -5.78036     -5.62734     -5.73847     -5.82742     -5.88058     -5.89138     -5.98315     -6.14102     -6.09644     -6.18463     -6.57868     -6.61921     -6.55928


PRINT,';;', dn_Ni
PRINT,';;', dn_Ti
PRINT,';;', dn_Te
PRINT,';;', dn_Pi
;;      13.2894      13.6633      13.7414      13.6178      14.4607      13.2577      13.0477      13.7580      14.9694      14.3119      13.3839      12.6570      13.6572
;;      274.114      275.811      277.693      300.393      289.701      288.121      281.954      274.758      276.977      278.557      282.944      284.283      269.985
;;      63.9186      65.5380      67.3512      67.2182      67.3051      67.2898      66.3465      65.8355      69.2972      68.1353      65.6077      66.4209      66.1748
;;      1071.78      1177.16      1139.29      1280.31      1257.76      1096.16      1181.50      1234.66      1281.25      1137.22      1157.43      1019.11      1139.81
PRINT,';;', vswx_dn
PRINT,';;', vswy_dn
PRINT,';;', vswz_dn
;;     -125.706     -112.693     -111.996     -128.721     -107.861     -95.8961     -143.758     -135.034     -119.948     -120.902     -91.1511     -118.182     -133.010
;;      76.0840      63.2844      57.5193      80.8170      68.2826      91.5688      95.0344      65.2426      66.0857      73.0200      81.1880      91.4464      80.7675
;;     -61.9742     -45.0366     -41.5559     -61.9839     -40.8061     -84.7842     -100.362     -48.9528     -50.3166     -66.2105     -58.4715     -78.5976     -67.7298
PRINT,';;', dn_magf[*,0]
PRINT,';;', dn_magf[*,1]
PRINT,';;', dn_magf[*,2]
;;      2.31985      2.84931      2.91280      2.35022      1.66521     0.930442     0.418488     0.609328    0.0646042   -0.0506223      1.85531      1.98113      1.42087
;;     -20.9550     -19.6662     -18.3171     -16.6167     -17.0777     -17.7718     -18.9824     -18.1475     -16.0553     -14.8431     -16.2384     -16.9300     -17.5406
;;     -16.2034     -13.6225     -11.8529     -12.6840     -13.4321     -14.2577     -14.7117     -16.0638     -18.1507     -17.9198     -17.1805     -16.6652     -17.3524

;; => Upstream values
dens_up        = [3.67120,3.72781,3.64282,3.62596,3.72209,3.68114,3.62656,3.75548,3.73672,3.76154,3.86371,3.84768,3.69372]
ti_avg_up      = [64.0601,65.4925,65.8209,64.6496,65.4988,66.0537,66.0473,67.9845,64.4572,65.8322,64.1350,63.7507,64.0134]
te_avg_up      = [11.7931,9.29861,9.62223,9.14771,8.99538,9.02639,9.12409,9.01857,9.20982,9.22978,9.39782,9.93921,9.52153]
Pi_up          = [15.0373,13.7814,13.1362,13.8643,14.4602,13.5135,13.4873,12.6477,16.4646,16.5847,14.9911,18.6817,14.9081]
vsw_x_up       = [-482.000,-489.754,-489.004,-488.383,-491.927,-491.405,-492.613,-496.530,-483.834,-490.901,-483.494,-479.404,-486.873]
vsw_y_up       = [ 82.2147,82.9912,83.2759,83.3102,83.8608,83.7969,83.3719,83.6011,81.7873,83.3698,81.7884,81.6210,83.0429]
vsw_z_up       = [-90.9088,-92.0312,-88.2150,-94.0726,-94.0077,-91.8656,-92.5525,-87.8669,-93.6643,-95.1515,-93.4061,-93.8795,-95.1282]
vsw_up         = [[vsw_x_up],[vsw_y_up],[vsw_z_up]]
mag_x_up       = [ 0.335204,0.405830,0.0845831,-0.131994,-0.238947,-0.273008,-0.545304,-0.422076,-0.218986,-0.0632742,-0.111547,-0.104104,-0.201564]
mag_y_up       = [-0.0335167,0.337760,0.222312,0.313244,0.290398,0.364247,0.253711,0.102740,-0.104149,-0.101017,-0.0151983,0.141721,-0.0126139]
mag_z_up       = [-5.78036,-5.62734,-5.73847,-5.82742,-5.88058,-5.89138,-5.98315,-6.14102,-6.09644,-6.18463,-6.57868,-6.61921,-6.55928]
magf_up        = [[mag_x_up],[mag_y_up],[mag_z_up]]
temp_up        = te_avg_up + ti_avg_up
PRINT,';;', MEAN(dens_up,/NAN),  MEAN(ti_avg_up,/NAN),  MEAN(te_avg_up,/NAN)
PRINT,';;', MEAN(vsw_x_up,/NAN), MEAN(vsw_y_up,/NAN), MEAN(vsw_z_up,/NAN)
PRINT,';;', MEAN(mag_x_up,/NAN), MEAN(mag_y_up,/NAN), MEAN(mag_z_up,/NAN)
;;      3.71973      65.2151      9.48648
;;     -488.163      82.9255     -92.5192
;;    -0.114245     0.135357     -6.06984


;; => Downstream values
dens_dn        = [13.2894,13.6633,13.7414,13.6178,14.4607,13.2577,13.0477,13.7580,14.9694,14.3119,13.3839,12.6570,13.6572]
ti_avg_dn        = [274.114,275.811,277.693,300.393,289.701,288.121,281.954,274.758,276.977,278.557,282.944,284.283,269.985]
te_avg_dn      = [63.9186,65.5380,67.3512,67.2182,67.3051,67.2898,66.3465,65.8355,69.2972,68.1353,65.6077,66.4209,66.1748]
Pi_dn          = [1071.78,1177.16,1139.29,1280.31,1257.76,1096.16,1181.50,1234.66,1281.25,1137.22,1157.43,1019.11,1139.81]
vsw_x_dn       = [-125.706,-112.693,-111.996,-128.721,-107.861,-95.8961,-143.758,-135.034,-119.948,-120.902,-91.1511,-118.182,-133.010]
vsw_y_dn       = [ 76.0840,63.2844,57.5193,80.8170,68.2826,91.5688,95.0344,65.2426,66.0857,73.0200,81.1880,91.4464,80.7675]
vsw_z_dn       = [-61.9742,-45.0366,-41.5559,-61.9839,-40.8061,-84.7842,-100.362,-48.9528,-50.3166,-66.2105,-58.4715,-78.5976,-67.7298]
vsw_dn         = [[vsw_x_dn],[vsw_y_dn],[vsw_z_dn]]
mag_x_dn       = [ 2.31985,2.84931,2.91280,2.35022,1.66521,0.930442,0.418488,0.609328,0.0646042,-0.0506223,1.85531,1.98113,1.42087]
mag_y_dn       = [-20.9550,-19.6662,-18.3171,-16.6167,-17.0777,-17.7718,-18.9824,-18.1475,-16.0553,-14.8431,-16.2384,-16.9300,-17.5406]
mag_z_dn       = [-16.2034,-13.6225,-11.8529,-12.6840,-13.4321,-14.2577,-14.7117,-16.0638,-18.1507,-17.9198,-17.1805,-16.6652,-17.3524]
magf_dn        = [[mag_x_dn],[mag_y_dn],[mag_z_dn]]
temp_dn        = te_avg_dn + ti_avg_dn
PRINT,';;', MEAN(dens_dn,/NAN),  MEAN(ti_avg_dn,/NAN),  MEAN(te_avg_dn,/NAN)
PRINT,';;', MEAN(vsw_x_dn,/NAN), MEAN(vsw_y_dn,/NAN), MEAN(vsw_z_dn,/NAN)
PRINT,';;', MEAN(mag_x_dn,/NAN), MEAN(mag_y_dn,/NAN), MEAN(mag_z_dn,/NAN)
;;      13.6781      281.176      66.6491
;;     -118.835      76.1801     -62.0601
;;      1.48669     -17.6263     -15.3921


;; => combine terms
vsw      = [[[vsw_up]],[[vsw_dn]]]
mag      = [[[magf_up]],[[magf_dn]]]
dens     = [[dens_up],[dens_dn]]
temp     = [[temp_up],[temp_dn]]

.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/rh_pros/temp_rh_soln_print.pro
temp_rh_soln_print,dens,vsw,mag,temp,tdate[0],NMAX=120L
;; => Print out best fit poloidal angles
PRINT,';', soln.THETA*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;     -0.15126050       1.7246351
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;     -0.15126050       1.7246351
;;-----------------------------------------------------------

;; => Print out best fit azimuthal angles
PRINT,';', soln.PHI*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;       355.46218       2.1391466
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;       355.46218       2.1391466
;;-----------------------------------------------------------

;; => Print out best fit shock normal speed in spacecraft frame [km/s]
PRINT,';', soln.VSHN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;       13.870709       22.547102
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;       13.870709       22.547102
;;-----------------------------------------------------------

;; => Print out best fit upstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_UP
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;      -506.46806       21.841831
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;      -506.46806       21.841831
;;-----------------------------------------------------------

;; => Print out best fit downstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_DN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;      -138.10784       10.702731
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;      -138.10784       10.702731
;;-----------------------------------------------------------

;; => Print out best fit shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,0]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;      0.99615338    -0.079060538   -0.0026399172
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;      0.99615338    -0.079060538   -0.0026399172
;;-----------------------------------------------------------

;; => Print out best fit uncertainty in shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,1]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;    0.0022296330     0.027727393     0.027471605
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;    0.0022296330     0.027727393     0.027471605
;;-----------------------------------------------------------

;;----------------------------------------------------------------------------------------
;; => Avg. terms [3rd Shock]
;;----------------------------------------------------------------------------------------
tr_up          = time_double(tdate[0]+'/'+['18:27:23.800','18:28:28.800'])
tr_dn          = time_double(tdate[0]+'/'+['18:21:40.700','18:22:45.700'])
t_ramp_se      = time_double(tdate[0]+'/'+['18:24:24.910','18:24:49.450'])

good_up_Bo     = WHERE(th_magf.X GE tr_up[0] AND th_magf.X LE tr_up[1],gdupBo)
good_up_Ni     = WHERE(ti_dens.X GE tr_up[0] AND ti_dens.X LE tr_up[1],gdupNi)
good_up_Ti     = WHERE(ti_stru.X GE tr_up[0] AND ti_stru.X LE tr_up[1],gdupTi)
good_up_Te     = WHERE(te_stru.X GE tr_up[0] AND te_stru.X LE tr_up[1],gdupTe)
good_up_Vi     = WHERE(ti_vsw.X  GE tr_up[0] AND ti_vsw.X  LE tr_up[1],gdupVi)
good_up_Pi     = WHERE(ti_pres.X GE tr_up[0] AND ti_pres.X LE tr_up[1],gdupPi)

good_dn_Bo     = WHERE(th_magf.X GE tr_dn[0] AND th_magf.X LE tr_dn[1],gddnBo)
good_dn_Ni     = WHERE(ti_dens.X GE tr_dn[0] AND ti_dens.X LE tr_dn[1],gddnNi)
good_dn_Ti     = WHERE(ti_stru.X GE tr_dn[0] AND ti_stru.X LE tr_dn[1],gddnTi)
good_dn_Te     = WHERE(te_stru.X GE tr_dn[0] AND te_stru.X LE tr_dn[1],gddnTe)
good_dn_Vi     = WHERE(ti_vsw.X  GE tr_dn[0] AND ti_vsw.X  LE tr_dn[1],gddnVi)
good_dn_Pi     = WHERE(ti_pres.X GE tr_dn[0] AND ti_pres.X LE tr_dn[1],gddnPi)

PRINT,';;', gdupBo, gdupNi, gdupTi, gdupTe, gdupVi, gdupPi
PRINT,';;', gddnBo, gddnNi, gddnTi, gddnTe, gddnVi, gddnPi
;;         260          21          21          21          21          21
;;         260          21          21          21          21          21

;; => Interpolate to ion times
;;  Bo
tx_magf        = interp(th_magf.Y[*,0],th_magf.X,ti_dens.X,/NO_EXTRAP)
ty_magf        = interp(th_magf.Y[*,1],th_magf.X,ti_dens.X,/NO_EXTRAP)
tz_magf        = interp(th_magf.Y[*,2],th_magf.X,ti_dens.X,/NO_EXTRAP)
tm_magf        = [[tx_magf],[ty_magf],[tz_magf]]
;;  Ti
ti_temp        = interp(ti_stru.Y,ti_stru.X,ti_dens.X,/NO_EXTRAP)
;;  Pi
pi_temp        = interp(ti_pres.Y,ti_pres.X,ti_dens.X,/NO_EXTRAP)
;;  Te
te_temp        = interp(te_stru.Y,te_stru.X,ti_dens.X,/NO_EXTRAP)
;;  Vsw
vswx           = interp(ti_vsw.Y[*,0],ti_vsw.X,ti_dens.X,/NO_EXTRAP)
vswy           = interp(ti_vsw.Y[*,1],ti_vsw.X,ti_dens.X,/NO_EXTRAP)
vswz           = interp(ti_vsw.Y[*,2],ti_vsw.X,ti_dens.X,/NO_EXTRAP)

;; => Define [up,down]stream
up_magf        = FLOAT(tm_magf[good_up_Ni,*])
vswx_up        = FLOAT(vswx[good_up_Ni])
vswy_up        = FLOAT(vswy[good_up_Ni])
vswz_up        = FLOAT(vswz[good_up_Ni])
up_Ti          = FLOAT(ti_temp[good_up_Ni])
up_Te          = FLOAT(te_temp[good_up_Ni])
up_Ni          = FLOAT(ti_dens.Y[good_up_Ni])
up_Pi          = FLOAT(pi_temp[good_up_Ni])

dn_magf        = FLOAT(tm_magf[good_dn_Ni,*])
vswx_dn        = FLOAT(vswx[good_dn_Ni])
vswy_dn        = FLOAT(vswy[good_dn_Ni])
vswz_dn        = FLOAT(vswz[good_dn_Ni])
dn_Ti          = FLOAT(ti_temp[good_dn_Ni])
dn_Te          = FLOAT(te_temp[good_dn_Ni])
dn_Ni          = FLOAT(ti_dens.Y[good_dn_Ni])
dn_Pi          = FLOAT(pi_temp[good_dn_Ni])

PRINT,';;', up_Ni
PRINT,';;', up_Ti
PRINT,';;', up_Te
PRINT,';;', up_Pi
;;      3.87978      4.02949      3.97400      4.02469      3.87947      3.82145      3.97892      3.86782      3.98627      3.74739      4.02029      3.89604      3.88569      3.67088      3.69350      3.68523      3.80416      4.22227      3.83394      3.92443      3.79381
;;      53.0733      49.8847      53.6912      52.0637      53.6598      53.2007      54.0271      53.5525      52.9476      54.1991      50.4541      56.5445      56.4940      55.0889      54.1660      55.3461      53.7913      54.1387      52.6246      50.8885      52.6414
;;      13.9286      13.4895      13.7067      13.8220      13.4529      13.3576      13.5780      13.1160      12.6409      13.4283      13.8322      13.2141      14.0428      14.2817      14.5634      15.4813      15.4137      13.8568      15.4330      15.4635      15.5006
;;      27.1307      27.9698      25.7457      30.1200      25.5771      27.5005      30.9568      27.3358      29.1494      26.1212      27.3030      24.2919      26.7611      23.7249      23.6632      22.6117      24.5500      24.6567      25.4853      24.6362      26.0832
PRINT,';;', vswx_up
PRINT,';;', vswy_up
PRINT,';;', vswz_up
;;     -457.390     -454.220     -456.068     -459.762     -455.623     -460.209     -464.107     -460.368     -458.292     -457.150     -454.088     -455.623     -459.200     -456.180     -455.331     -451.511     -453.297     -453.473     -452.444     -454.085     -456.378
;;      57.8830      60.7526      58.4751      57.1817      59.3558      57.2762      54.2417      55.4526      57.0741      57.1308      60.4539      55.0635      53.4701      55.6929      55.7119      56.6511      58.9375      59.6777      60.2901      62.9608      60.3403
;;      9.21621      10.7170      6.75681      12.8476      5.75498      11.3815      14.4844      11.8958      10.4295      8.03443      9.83993      3.49662      7.55206      6.65678      7.71321      2.72581      3.39370      2.31416      4.49266      5.94652      6.72869
PRINT,';;', up_magf[*,0]
PRINT,';;', up_magf[*,1]
PRINT,';;', up_magf[*,2]
;;      3.68796      3.72186      3.69076      3.55824      3.50687      3.47899      3.43815      3.66072      3.85748      3.98805      4.07641      3.95551      3.81591      3.82316      4.01652      4.17722      4.25944      4.26528      4.25180      4.31157      4.12299
;;     -5.39062     -5.48992     -5.31667     -5.13549     -5.11102     -4.95301     -5.19379     -4.90067     -4.68617     -4.68304     -4.70102     -4.86403     -5.19892     -5.10300     -5.12620     -4.96838     -4.99549     -4.48578     -4.50716     -4.39669     -4.82380
;;      1.25301     0.999728      1.01717      1.13241      1.13094      1.68317      1.66111      1.47220      1.08976      1.06122      1.17932      1.11647      1.13662      1.38832      1.15572      1.03985     0.967024     0.953630     0.493382     0.683120     0.960400


PRINT,';;', dn_Ni
PRINT,';;', dn_Ti
PRINT,';;', dn_Te
PRINT,';;', dn_Pi
;;      9.28193      11.6102      9.54294      12.9192      12.1674      10.9958      11.7270      14.3654      10.5688      10.0051      9.86919      10.5606      11.1192      9.96580      9.48013      10.8892      12.8338      12.2765      11.4739      8.77951      8.73243
;;      371.217      339.322      374.439      280.702      311.467      295.543      248.818      315.631      320.660      307.128      277.508      426.758      287.702      303.414      346.943      308.321      277.596      276.881      297.313      287.266      277.411
;;      52.3136      55.5987      57.9898      61.0277      59.3392      52.9494      61.1086      56.8372      55.2493      51.9238      58.3847      55.1813      55.1369      61.2118      55.6507      57.3593      59.6361      55.2512      60.0513      56.0318      54.3360
;;      1396.88      1484.79      1434.61      1509.75      1764.07      1505.02      1050.70      1940.56      1716.34      1463.09      1078.13      1775.94      1362.03      1273.29      814.869      1215.36      1512.20      1330.94      1348.34      1027.55      1052.81
PRINT,';;', vswx_dn
PRINT,';;', vswy_dn
PRINT,';;', vswz_dn
;;     -184.294     -169.251     -176.650     -165.316     -184.580     -244.271     -213.936     -216.950     -225.803     -176.844     -204.692     -193.965     -199.094     -201.013     -194.280     -181.057     -143.342     -140.175     -212.258     -187.314     -214.260
;;      97.9446      69.2749      71.5579      65.7948      96.8973      75.3565      87.3190      97.8629      79.6041      48.6829      35.9421      82.2121      82.1494      92.0291      86.1183      98.9700      79.1636      55.8665      85.8108      120.943      82.8011
;;      6.15394     -21.0360     -15.9439     -29.6636     -52.5194     -3.93785     -48.6716      27.8878     -12.5502      17.6192      25.6328      11.6890     -13.4597     -27.7108     -16.4757      6.79671    -0.724971     -29.6154     -21.9408      5.26594      31.3005
PRINT,';;', dn_magf[*,0]
PRINT,';;', dn_magf[*,1]
PRINT,';;', dn_magf[*,2]
;;      3.90427      2.62785      1.80094      1.97481      3.50584      5.12203      5.78735      6.11337      5.28903      4.28592      3.35653      4.19374      5.54164      6.32142      6.70809      5.16462      1.52357     0.513950      2.69081      4.85474      5.49718
;;     -14.8492     -13.8413     -14.1380     -14.5578     -14.3720     -15.7977     -16.0209     -16.7703     -16.2655     -15.6551     -14.4456     -14.7066     -14.7703     -16.4809     -18.6337     -17.9369     -15.9375     -14.4299     -15.2176     -15.7854     -15.8001
;;      4.76063      4.83134      3.74214      3.38846      3.41878      3.17021      2.48103      3.15636      4.24912      4.08458      3.28272      2.27957      3.01599      2.38633      1.81811      2.36554      2.30287      2.17626      1.50555      1.56769      2.24034

;; => Upstream values
dens_up        = [3.87978,4.02949,3.97400,4.02469,3.87947,3.82145,3.97892,3.86782,3.98627,3.74739,4.02029,3.89604,3.88569,3.67088,3.69350,3.68523,3.80416,4.22227,3.83394,3.92443,3.79381]
ti_avg_up      = [53.0733,49.8847,53.6912,52.0637,53.6598,53.2007,54.0271,53.5525,52.9476,54.1991,50.4541,56.5445,56.4940,55.0889,54.1660,55.3461,53.7913,54.1387,52.6246,50.8885,52.6414]
te_avg_up      = [13.9286,13.4895,13.7067,13.8220,13.4529,13.3576,13.5780,13.1160,12.6409,13.4283,13.8322,13.2141,14.0428,14.2817,14.5634,15.4813,15.4137,13.8568,15.4330,15.4635,15.5006]
Pi_up          = [27.1307,27.9698,25.7457,30.1200,25.5771,27.5005,30.9568,27.3358,29.1494,26.1212,27.3030,24.2919,26.7611,23.7249,23.6632,22.6117,24.5500,24.6567,25.4853,24.6362,26.0832]
vsw_x_up       = [-457.390,-454.220,-456.068,-459.762,-455.623,-460.209,-464.107,-460.368,-458.292,-457.150,-454.088,-455.623,-459.200,-456.180,-455.331,-451.511,-453.297,-453.473,-452.444,-454.085,-456.378]
vsw_y_up       = [ 57.8830,60.7526,58.4751,57.1817,59.3558,57.2762,54.2417,55.4526,57.0741,57.1308,60.4539,55.0635,53.4701,55.6929,55.7119,56.6511,58.9375,59.6777,60.2901,62.9608,60.3403]
vsw_z_up       = [ 9.21621,10.7170,6.75681,12.8476,5.75498,11.3815,14.4844,11.8958,10.4295,8.03443,9.83993,3.49662,7.55206,6.65678,7.71321,2.72581,3.39370,2.31416,4.49266,5.94652,6.72869]
vsw_up         = [[vsw_x_up],[vsw_y_up],[vsw_z_up]]
mag_x_up       = [ 3.68796,3.72186,3.69076,3.55824,3.50687,3.47899,3.43815,3.66072,3.85748,3.98805,4.07641,3.95551,3.81591,3.82316,4.01652,4.17722,4.25944,4.26528,4.25180,4.31157,4.12299]
mag_y_up       = [-5.39062,-5.48992,-5.31667,-5.13549,-5.11102,-4.95301,-5.19379,-4.90067,-4.68617,-4.68304,-4.70102,-4.86403,-5.19892,-5.10300,-5.12620,-4.96838,-4.99549,-4.48578,-4.50716,-4.39669,-4.82380]
mag_z_up       = [ 1.25301,0.999728,1.01717,1.13241,1.13094,1.68317,1.66111,1.47220,1.08976,1.06122,1.17932,1.11647,1.13662,1.38832,1.15572,1.03985,0.967024,0.953630,0.493382,0.683120,0.960400]
magf_up        = [[mag_x_up],[mag_y_up],[mag_z_up]]
temp_up        = te_avg_up + ti_avg_up
PRINT,';;', MEAN(dens_up,/NAN),  MEAN(ti_avg_up,/NAN),  MEAN(te_avg_up,/NAN)
PRINT,';;', MEAN(vsw_x_up,/NAN), MEAN(vsw_y_up,/NAN), MEAN(vsw_z_up,/NAN)
PRINT,';;', MEAN(mag_x_up,/NAN), MEAN(mag_y_up,/NAN), MEAN(mag_z_up,/NAN)
;;      3.88664      53.4513      14.0764
;;     -456.419      57.8130      7.73230
;;      3.88880     -4.95385      1.12260


;; => Downstream values
dens_dn        = [9.28193,11.6102,9.54294,12.9192,12.1674,10.9958,11.7270,14.3654,10.5688,10.0051,9.86919,10.5606,11.1192,9.96580,9.48013,10.8892,12.8338,12.2765,11.4739,8.77951,8.73243]
ti_avg_dn        = [371.217,339.322,374.439,280.702,311.467,295.543,248.818,315.631,320.660,307.128,277.508,426.758,287.702,303.414,346.943,308.321,277.596,276.881,297.313,287.266,277.411]
te_avg_dn      = [52.3136,55.5987,57.9898,61.0277,59.3392,52.9494,61.1086,56.8372,55.2493,51.9238,58.3847,55.1813,55.1369,61.2118,55.6507,57.3593,59.6361,55.2512,60.0513,56.0318,54.3360]
Pi_dn          = [1396.88,1484.79,1434.61,1509.75,1764.07,1505.02,1050.70,1940.56,1716.34,1463.09,1078.13,1775.94,1362.03,1273.29,814.869,1215.36,1512.20,1330.94,1348.34,1027.55,1052.81]
vsw_x_dn       = [-184.294,-169.251,-176.650,-165.316,-184.580,-244.271,-213.936,-216.950,-225.803,-176.844,-204.692,-193.965,-199.094,-201.013,-194.280,-181.057,-143.342,-140.175,-212.258,-187.314,-214.260]
vsw_y_dn       = [ 97.9446,69.2749,71.5579,65.7948,96.8973,75.3565,87.3190,97.8629,79.6041,48.6829,35.9421,82.2121,82.1494,92.0291,86.1183,98.9700,79.1636,55.8665,85.8108,120.943,82.8011]
vsw_z_dn       = [ 6.15394,-21.0360,-15.9439,-29.6636,-52.5194,-3.93785,-48.6716,27.8878,-12.5502,17.6192,25.6328,11.6890,-13.4597,-27.7108,-16.4757,6.79671,-0.724971,-29.6154,-21.9408,5.26594,31.3005]
vsw_dn         = [[vsw_x_dn],[vsw_y_dn],[vsw_z_dn]]
mag_x_dn       = [ 3.90427,2.62785,1.80094,1.97481,3.50584,5.12203,5.78735,6.11337,5.28903,4.28592,3.35653,4.19374,5.54164,6.32142,6.70809,5.16462,1.52357,0.513950,2.69081,4.85474,5.49718]
mag_y_dn       = [-14.8492,-13.8413,-14.1380,-14.5578,-14.3720,-15.7977,-16.0209,-16.7703,-16.2655,-15.6551,-14.4456,-14.7066,-14.7703,-16.4809,-18.6337,-17.9369,-15.9375,-14.4299,-15.2176,-15.7854,-15.8001]
mag_z_dn       = [ 4.76063,4.83134,3.74214,3.38846,3.41878,3.17021,2.48103,3.15636,4.24912,4.08458,3.28272,2.27957,3.01599,2.38633,1.81811,2.36554,2.30287,2.17626,1.50555,1.56769,2.24034]
magf_dn        = [[mag_x_dn],[mag_y_dn],[mag_z_dn]]
temp_dn        = te_avg_dn + ti_avg_dn
PRINT,';;', MEAN(dens_dn,/NAN),  MEAN(ti_avg_dn,/NAN),  MEAN(te_avg_dn,/NAN)
PRINT,';;', MEAN(vsw_x_dn,/NAN), MEAN(vsw_y_dn,/NAN), MEAN(vsw_z_dn,/NAN)
PRINT,';;', MEAN(mag_x_dn,/NAN), MEAN(mag_y_dn,/NAN), MEAN(mag_z_dn,/NAN)
;;      10.9126      311.050      56.7890
;;     -191.874      80.5858     -7.70972
;;      4.13227     -15.5434      2.96303


;; => combine terms
vsw      = [[[vsw_up]],[[vsw_dn]]]
mag      = [[[magf_up]],[[magf_dn]]]
dens     = [[dens_up],[dens_dn]]
temp     = [[temp_up],[temp_dn]]

.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/rh_pros/temp_rh_soln_print.pro
temp_rh_soln_print,dens,vsw,mag,temp,tdate[0],NMAX=120L
;; => Print out best fit poloidal angles
PRINT,';', soln.THETA*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;     -0.15490534       4.5680877
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;     -0.12842873       4.9041469
;;-----------------------------------------------------------

;; => Print out best fit azimuthal angles
PRINT,';', soln.PHI*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;       3.1332533       2.6657149
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;       3.6974790       3.1614003
;;-----------------------------------------------------------

;; => Print out best fit shock normal speed in spacecraft frame [km/s]
PRINT,';', soln.VSHN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;      -34.894366       44.343683
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;      -33.929926       44.366165
;;-----------------------------------------------------------

;; => Print out best fit upstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_UP
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;      -415.81187       42.834381
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;      -415.52490       42.829938
;;-----------------------------------------------------------

;; => Print out best fit downstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_DN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;      -151.48492       30.253880
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;      -151.38092       30.255039
;;-----------------------------------------------------------

;; => Print out best fit shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,0]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;      0.99433180     0.054425732   -0.0026942278
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;      0.99282966     0.064151304   -0.0022364971
;;-----------------------------------------------------------

;; => Print out best fit uncertainty in shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,1]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-23 bow shock
;;===========================================================
;;    0.0046824289     0.045438901     0.079057177
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-23 bow shock
;;===========================================================
;;    0.0058436502     0.054022891     0.084956913
;;-----------------------------------------------------------








































