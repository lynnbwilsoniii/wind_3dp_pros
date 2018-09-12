;;----------------------------------------------------------------------------------------
;;  Status Bar Legend
;;
;;    yellow       :  slow survey
;;    red          :  fast survey
;;    black below  :  particle burst
;;    black above  :  wave burst
;;
;;----------------------------------------------------------------------------------------
;; => Times [1st Shock]
t_foot_se      = time_double(tdate[0]+'/'+['18:31:57.290','18:31:58.000'])
t_ramp_se      = time_double(tdate[0]+'/'+['18:31:56.880','18:31:57.290'])
tr_up          = time_double(tdate[0]+'/'+['18:32:42.300','18:35:08.400'])
tr_dn          = time_double(tdate[0]+'/'+['18:26:17.900','18:29:05.200'])
tr_up2         = time_double(tdate[0]+'/'+['18:32:13.800','18:33:47.800'])
tr_dn2         = time_double(tdate[0]+'/'+['18:30:12.000','18:31:46.000'])

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

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='RH Solutions ['+tdate[0]+']'

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
;; => Avg. terms [1st Shock]
;;----------------------------------------------------------------------------------------
;;  Upstream
avg_magf_up  = [4.37016d0,-6.67269d0,-12.9573d0]
avg_vswi_up  = [-435.801d0,-14.1659d0,-7.56588d0]
avg_dens_up  = 33.5547d0
avg_Ti_up    = 91.3863d0
avg_Te_up    = 31.2435d0
vshn_up      = -58.924067d0
ushn_up      = -358.12372d0
gnorm        = [0.94742836d0,0.18668436d0,0.20001629d0]
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
;;       88.842702       6.2506369       2.5594956       2.2475029


;;  Downstream
avg_magf_dn  = [11.9059d0,-7.86599d0,-35.9012d0]
avg_vswi_dn  = [-205.980d0,40.2591d0,39.5294d0]
avg_dens_dn  = 101.277d0
avg_Ti_dn    = 179.582d0
avg_Te_dn    = 66.0967d0
ushn_dn      = -120.80463d0
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
;;       88.842702       1.4427220      0.60998498      0.53199715       3.0182657

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
;;       935.36392       488.63679
;;      -473.97409      -94.791498


;;----------------------------------------------------------------------------------------
;; => Avg. terms [2nd Shock]
;;----------------------------------------------------------------------------------------
;;  Upstream
avg_magf_up  = [3.98054d0,14.6409d0,-9.96436d0]
avg_vswi_up  = [-477.028d0,104.805d0,9.88610d0]
avg_dens_up  = 20.4472d0
avg_Ti_up    = 64.2323d0
avg_Te_up    = 18.6656d0
vshn_up      = -37.141536d0
ushn_up      = -367.71181d0
gnorm        = [0.88335655d0,0.11512753d0,0.45176740d0]
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
;;       87.786598       4.1995984       3.1963559       2.3274806


;;  Downstream
avg_magf_dn  = [1.06117d0,51.7175d0,-19.7248d0]
avg_vswi_dn  = [-186.710d0,109.106d0,83.7977d0]
avg_dens_dn  = 97.3820d0
avg_Ti_dn    = 176.665d0
avg_Te_dn    = 81.4642d0
ushn_dn      = -77.371965d0
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
;;       87.786598      0.63229402      0.38113986      0.30213575       4.7626081

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
;;       882.12682       519.05048
;;      -440.59328       7.1603002


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
den_name       = tnames(pref[0]+peeb_tn[0]+'density')  ;; ions are bad here
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
tr_up          = time_double(tdate[0]+'/'+['18:32:13.800','18:33:47.800'])
tr_dn          = time_double(tdate[0]+'/'+['18:30:12.000','18:31:46.000'])
t_foot_se      = time_double(tdate[0]+'/'+['18:31:57.290','18:31:58.000'])
t_ramp_se      = time_double(tdate[0]+'/'+['18:31:56.880','18:31:57.290'])

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
;;         376          31          31          31          31          31
;;         376          31          31          31          31          31

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

FOR j=0L, 3L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', up_Ni         & $
  IF (j EQ 1) THEN PRINT,';;', up_Ti         & $
  IF (j EQ 2) THEN PRINT,';;', up_Te         & $
  IF (j EQ 3) THEN PRINT,';;', up_Pi
;;      35.6923      35.0847      34.1306      33.9554      34.1509      34.2893      34.2972      33.8932      34.5136      33.4089      34.0324      34.4023      34.2296      33.8239      34.3125      34.2857      33.9989      34.2799      33.9282      34.0440      33.6116      30.8301      31.3817      31.0204      32.5213      33.5686      33.9807      32.1840      32.4275      31.9700      31.9471
;;      90.0413      75.6644      87.4799      91.1393      91.8614      94.5432      93.4037      88.1564      92.7436      87.3559      92.4325      89.5438      89.9547      93.1958      93.7196      92.9022      88.7231      88.9689      86.2650      90.9944      88.0597      97.2601      90.4160      92.9553      94.4807      95.5585      95.3728      95.7003      96.5227      94.1785      93.3804
;;      31.7435      31.5987      31.1731      31.0813      31.0985      31.3220      31.4034      31.1898      31.2618      30.7142      31.1607      31.2813      31.1673      30.5731      30.4886      30.4883      30.3924      30.6235      30.5442      30.6186      30.6784      30.2152      31.1751      31.0282      31.5209      32.3557      32.9799      31.9913      32.3041      32.2941      32.0809
;;      386.649      485.575      402.736      480.276      389.319      375.560      383.931      396.986      405.717      448.471      393.175      449.743      430.422      378.457      406.387      394.480      451.971      425.728      444.133      439.623      454.209      384.231      476.747      510.819      428.308      345.816      343.407      345.554      361.347      337.091      329.662
FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vswx_up       & $
  IF (j EQ 1) THEN PRINT,';;', vswy_up       & $
  IF (j EQ 2) THEN PRINT,';;', vswz_up
;;     -422.048     -417.425     -407.151     -426.416     -432.180     -432.501     -424.139     -413.876     -436.549     -436.648     -432.743     -435.720     -436.777     -439.405     -438.220     -436.200     -436.923     -440.545     -445.561     -440.013     -438.630     -441.239     -442.501     -442.981     -442.335     -446.372     -445.830     -447.045     -448.947     -441.769     -441.132
;;     -67.6574     -61.3131     -67.0520     -70.6108     -55.8343     -80.1230     -78.3917     -75.9570      5.26338     -9.47535      16.1410     -1.20867     -4.08319      3.20849      8.06642      8.36303     -6.10027     -9.93509     -16.1466     -3.44035     -8.90134      18.5140     -8.04423      1.20741      6.71617      19.2528      18.8233      30.8533      27.2973      8.95068      12.4730
;;      14.9656      38.1180      21.0011      11.9384      14.9765      13.9489      18.5927      16.2322     -15.5492     -6.58466     -22.2598     -8.71057     -11.8368     -26.0088     -24.6841     -23.2571     -9.69192     -13.6531     -4.32613     -17.7342     -12.9247     -34.2248      2.08494      3.50751     -12.9585     -19.3458     -17.9535     -23.1499     -24.6651     -29.5576     -30.8318
FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', up_magf[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', up_magf[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', up_magf[*,2]
;;      4.98308      5.30028      5.06638      5.43156      4.35536      4.43902      4.87375      5.26620      4.76749      5.15442      5.67474      5.76044      5.17808      5.46769      5.69417      5.75055      5.53723      5.38585      5.40052      6.14622      6.50155      6.25731      5.84892      4.11135      1.79930     0.341482     0.217570     0.348112     0.698422      1.67350      2.04440
;;     -6.91245     -6.99291     -7.80669     -7.47444     -5.72331     -4.90372     -3.84333     -4.95277     -6.71988     -7.25039     -6.73296     -7.07069     -7.39468     -7.30153     -7.24992     -8.51963     -10.8550     -12.3384     -13.1095     -13.3872     -13.5566     -13.4789     -12.0212     -8.17406     -3.79468    -0.785380     0.102909      1.12688      1.04575    -0.316428    -0.462276
;;     -14.3867     -14.2330     -13.2682     -12.7319     -13.7425     -14.0932     -14.5623     -14.1026     -13.8772     -13.6454     -13.6743     -13.1794     -13.6723     -14.1043     -13.8669     -12.7368     -11.6670     -10.8414     -9.95346     -8.68751     -6.97626     -4.81253     -4.98965     -8.98340     -13.9924     -16.4078     -16.4937     -16.5800     -16.9288     -17.1925     -17.2916


FOR j=0L, 3L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dn_Ni         & $
  IF (j EQ 1) THEN PRINT,';;', dn_Ti         & $
  IF (j EQ 2) THEN PRINT,';;', dn_Te         & $
  IF (j EQ 3) THEN PRINT,';;', dn_Pi
;;      84.1538      82.4700      92.2938      84.3407      93.1114      102.456      103.987      105.614      116.733      116.527      122.380      123.401      122.563      119.438      108.842      107.897      114.455      112.394      99.3665      97.3319      89.1490      97.4184      98.4232      93.7073      92.0525      91.2530      90.6552      91.8491      94.5250      95.5917      95.1931
;;      203.167      206.465      212.925      200.300      231.551      238.597      211.724      218.594      189.504      203.992      193.634      193.821      172.524      151.782      144.324      159.102      164.623      144.591      163.245      176.839      190.712      166.641      153.690      175.712      175.340      157.878      165.649      167.411      154.445      144.760      133.494
;;      65.5520      66.2468      69.8639      65.5085      66.8261      69.5204      67.9895      66.8319      69.1967      69.4179      70.7261      70.3919      69.9874      69.0176      67.1850      66.0982      66.3951      66.8642      62.2293      62.7972      61.1446      63.4619      65.2829      62.3069      61.6771      60.0666      61.3632      63.0711      66.0044      67.9745      67.9997
;;      6070.05      5506.01      5651.29      5082.29      5596.57      7003.42      6279.35      6382.03      6531.10      7233.81      7369.21      7190.85      5832.24      5253.21      4760.91      5244.80      5034.87      4697.74      5148.55      5255.62      5085.80      4947.22      4543.12      5346.34      4689.66      4213.40      4348.44      5144.58      4707.59      4295.53      3542.35
FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vswx_dn       & $
  IF (j EQ 1) THEN PRINT,';;', vswy_dn       & $
  IF (j EQ 2) THEN PRINT,';;', vswz_dn
;;     -164.534     -163.463     -186.777     -195.846     -190.621     -180.603     -171.275     -189.941     -208.786     -204.198     -214.263     -170.680     -194.744     -165.676     -176.810     -198.959     -188.990     -201.110     -223.820     -215.128     -237.700     -237.541     -202.867     -242.474     -241.564     -238.119     -231.950     -240.549     -248.424     -249.008     -208.949
;;      21.2955      35.5348      37.1956      46.6580      40.8718      29.6296      27.9716      50.3532      75.8553      77.7462      55.3635      35.1003      78.0600      33.5034      28.4720      39.6544      30.7890      17.0282      82.8310      36.4750      71.0689     -4.64502      28.3375      54.0878      25.3295      26.2830      34.0673      29.8179      40.7764      39.1525      23.3671
;;      36.6791      32.6318      46.2815      53.4783      42.7115      68.1642      16.4793      96.8099      67.8346      54.1448      63.2288      70.7089      46.1501      59.2963      38.2384      26.5779      28.3405      94.0493      38.0121      1.10322      9.24835      66.9216      25.6222      17.8913      27.7850      27.6824      16.0512      21.3621     -7.89044      13.1828      26.6332
FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dn_magf[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', dn_magf[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', dn_magf[*,2]
;;      15.7953      15.8612      18.0501      17.9056      14.0233      6.05683      5.26245      8.33595      8.90773      9.24797      7.46543      9.45342      12.4601      15.8120      16.1816      15.5242      14.3069      12.9873      9.45914      5.15661      7.73569      12.7738      15.3709      14.2676      12.5711      11.0875      9.92174      9.32360      12.0176      13.7330      12.0264
;;     -2.63540     -2.73143     -6.18385     -8.64964     -4.88663    -0.263104     0.351004     -1.70314      2.40304      4.76358      4.27183    0.0812840     -5.91112     -10.9529     -11.7512     -13.1873     -18.9784     -19.8413     -12.3210    -0.983280     -2.22378     -11.6495     -15.8824     -17.8363     -20.0708     -19.2687     -16.6003     -11.3354     -6.81166     -6.09486     -6.96295
;;     -48.5633     -46.0904     -45.0066     -43.0471     -36.1895     -29.0508     -29.2915     -28.7749     -23.0641     -17.2379     -16.8253     -21.6689     -30.7797     -36.8760     -38.9419     -36.8108     -34.8085     -32.9030     -34.8924     -34.4885     -35.8952     -36.6491     -39.8298     -39.8354     -39.8954     -41.6667     -44.1282     -42.7217     -41.6430     -42.4302     -42.9316

;; => Upstream values
dens_up        = [ 35.6923,35.0847,34.1306,33.9554,34.1509,34.2893,34.2972,33.8932,34.5136,33.4089,34.0324,34.4023,34.2296,33.8239,34.3125,34.2857,33.9989,34.2799,33.9282,34.0440,33.6116,30.8301,31.3817,31.0204,32.5213,33.5686,33.9807,32.1840,32.4275,31.9700,31.9471]
ti_avg_up      = [ 90.0413,75.6644,87.4799,91.1393,91.8614,94.5432,93.4037,88.1564,92.7436,87.3559,92.4325,89.5438,89.9547,93.1958,93.7196,92.9022,88.7231,88.9689,86.2650,90.9944,88.0597,97.2601,90.4160,92.9553,94.4807,95.5585,95.3728,95.7003,96.5227,94.1785,93.3804]
te_avg_up      = [ 31.7435,31.5987,31.1731,31.0813,31.0985,31.3220,31.4034,31.1898,31.2618,30.7142,31.1607,31.2813,31.1673,30.5731,30.4886,30.4883,30.3924,30.6235,30.5442,30.6186,30.6784,30.2152,31.1751,31.0282,31.5209,32.3557,32.9799,31.9913,32.3041,32.2941,32.0809]
Pi_up          = [ 386.649,485.575,402.736,480.276,389.319,375.560,383.931,396.986,405.717,448.471,393.175,449.743,430.422,378.457,406.387,394.480,451.971,425.728,444.133,439.623,454.209,384.231,476.747,510.819,428.308,345.816,343.407,345.554,361.347,337.091,329.662]
vsw_x_up       = [-422.048,-417.425,-407.151,-426.416,-432.180,-432.501,-424.139,-413.876,-436.549,-436.648,-432.743,-435.720,-436.777,-439.405,-438.220,-436.200,-436.923,-440.545,-445.561,-440.013,-438.630,-441.239,-442.501,-442.981,-442.335,-446.372,-445.830,-447.045,-448.947,-441.769,-441.132]
vsw_y_up       = [-67.6574,-61.3131,-67.0520,-70.6108,-55.8343,-80.1230,-78.3917,-75.9570,5.26338,-9.47535,16.1410,-1.20867,-4.08319,3.20849,8.06642,8.36303,-6.10027,-9.93509,-16.1466,-3.44035,-8.90134,18.5140,-8.04423,1.20741,6.71617,19.2528,18.8233,30.8533,27.2973,8.95068,12.4730]
vsw_z_up       = [ 14.9656,38.1180,21.0011,11.9384,14.9765,13.9489,18.5927,16.2322,-15.5492,-6.58466,-22.2598,-8.71057,-11.8368,-26.0088,-24.6841,-23.2571,-9.69192,-13.6531,-4.32613,-17.7342,-12.9247,-34.2248,2.08494,3.50751,-12.9585,-19.3458,-17.9535,-23.1499,-24.6651,-29.5576,-30.8318]
mag_x_up       = [ 4.98308,5.30028,5.06638,5.43156,4.35536,4.43902,4.87375,5.26620,4.76749,5.15442,5.67474,5.76044,5.17808,5.46769,5.69417,5.75055,5.53723,5.38585,5.40052,6.14622,6.50155,6.25731,5.84892,4.11135,1.79930,0.341482,0.217570,0.348112,0.698422,1.67350,2.04440]
mag_y_up       = [-6.91245,-6.99291,-7.80669,-7.47444,-5.72331,-4.90372,-3.84333,-4.95277,-6.71988,-7.25039,-6.73296,-7.07069,-7.39468,-7.30153,-7.24992,-8.51963,-10.8550,-12.3384,-13.1095,-13.3872,-13.5566,-13.4789,-12.0212,-8.17406,-3.79468,-0.785380,0.102909,1.12688,1.04575,-0.316428,-0.462276]
mag_z_up       = [-14.3867,-14.2330,-13.2682,-12.7319,-13.7425,-14.0932,-14.5623,-14.1026,-13.8772,-13.6454,-13.6743,-13.1794,-13.6723,-14.1043,-13.8669,-12.7368,-11.6670,-10.8414,-9.95346,-8.68751,-6.97626,-4.81253,-4.98965,-8.98340,-13.9924,-16.4078,-16.4937,-16.5800,-16.9288,-17.1925,-17.2916]
vsw_up         = [[vsw_x_up],[vsw_y_up],[vsw_z_up]]
magf_up        = [[mag_x_up],[mag_y_up],[mag_z_up]]
temp_up        = te_avg_up + ti_avg_up
FOR j=0L, 2L DO BEGIN                                                                             $
  IF (j EQ 0) THEN PRINT,';;', MEAN(dens_up,/NAN),  MEAN(ti_avg_up,/NAN), MEAN(te_avg_up,/NAN)  & $
  IF (j EQ 1) THEN PRINT,';;', MEAN(vsw_x_up,/NAN), MEAN(vsw_y_up,/NAN),  MEAN(vsw_z_up,/NAN)   & $
  IF (j EQ 2) THEN PRINT,';;', MEAN(mag_x_up,/NAN), MEAN(mag_y_up,/NAN),  MEAN(mag_z_up,/NAN)
;;      33.5547      91.3863      31.2435
;;     -435.801     -14.1659     -7.56588
;;      4.37016     -6.67269     -12.9573


;; => Downstream values
dens_dn        = [ 84.1538,82.4700,92.2938,84.3407,93.1114,102.456,103.987,105.614,116.733,116.527,122.380,123.401,122.563,119.438,108.842,107.897,114.455,112.394,99.3665,97.3319,89.1490,97.4184,98.4232,93.7073,92.0525,91.2530,90.6552,91.8491,94.5250,95.5917,95.1931]
ti_avg_dn      = [ 203.167,206.465,212.925,200.300,231.551,238.597,211.724,218.594,189.504,203.992,193.634,193.821,172.524,151.782,144.324,159.102,164.623,144.591,163.245,176.839,190.712,166.641,153.690,175.712,175.340,157.878,165.649,167.411,154.445,144.760,133.494]
te_avg_dn      = [ 65.5520,66.2468,69.8639,65.5085,66.8261,69.5204,67.9895,66.8319,69.1967,69.4179,70.7261,70.3919,69.9874,69.0176,67.1850,66.0982,66.3951,66.8642,62.2293,62.7972,61.1446,63.4619,65.2829,62.3069,61.6771,60.0666,61.3632,63.0711,66.0044,67.9745,67.9997]
Pi_dn          = [ 6070.05,5506.01,5651.29,5082.29,5596.57,7003.42,6279.35,6382.03,6531.10,7233.81,7369.21,7190.85,5832.24,5253.21,4760.91,5244.80,5034.87,4697.74,5148.55,5255.62,5085.80,4947.22,4543.12,5346.34,4689.66,4213.40,4348.44,5144.58,4707.59,4295.53,3542.35]
vsw_x_dn       = [-164.534,-163.463,-186.777,-195.846,-190.621,-180.603,-171.275,-189.941,-208.786,-204.198,-214.263,-170.680,-194.744,-165.676,-176.810,-198.959,-188.990,-201.110,-223.820,-215.128,-237.700,-237.541,-202.867,-242.474,-241.564,-238.119,-231.950,-240.549,-248.424,-249.008,-208.949]
vsw_y_dn       = [ 21.2955,35.5348,37.1956,46.6580,40.8718,29.6296,27.9716,50.3532,75.8553,77.7462,55.3635,35.1003,78.0600,33.5034,28.4720,39.6544,30.7890,17.0282,82.8310,36.4750,71.0689,-4.64502,28.3375,54.0878,25.3295,26.2830,34.0673,29.8179,40.7764,39.1525,23.3671]
vsw_z_dn       = [ 36.6791,32.6318,46.2815,53.4783,42.7115,68.1642,16.4793,96.8099,67.8346,54.1448,63.2288,70.7089,46.1501,59.2963,38.2384,26.5779,28.3405,94.0493,38.0121,1.10322,9.24835,66.9216,25.6222,17.8913,27.7850,27.6824,16.0512,21.3621,-7.89044,13.1828,26.6332]
mag_x_dn       = [ 15.7953,15.8612,18.0501,17.9056,14.0233,6.05683,5.26245,8.33595,8.90773,9.24797,7.46543,9.45342,12.4601,15.8120,16.1816,15.5242,14.3069,12.9873,9.45914,5.15661,7.73569,12.7738,15.3709,14.2676,12.5711,11.0875,9.92174,9.32360,12.0176,13.7330,12.0264]
mag_y_dn       = [-2.63540,-2.73143,-6.18385,-8.64964,-4.88663,-0.263104,0.351004,-1.70314,2.40304,4.76358,4.27183,0.0812840,-5.91112,-10.9529,-11.7512,-13.1873,-18.9784,-19.8413,-12.3210,-0.983280,-2.22378,-11.6495,-15.8824,-17.8363,-20.0708,-19.2687,-16.6003,-11.3354,-6.81166,-6.09486,-6.96295]
mag_z_dn       = [-48.5633,-46.0904,-45.0066,-43.0471,-36.1895,-29.0508,-29.2915,-28.7749,-23.0641,-17.2379,-16.8253,-21.6689,-30.7797,-36.8760,-38.9419,-36.8108,-34.8085,-32.9030,-34.8924,-34.4885,-35.8952,-36.6491,-39.8298,-39.8354,-39.8954,-41.6667,-44.1282,-42.7217,-41.6430,-42.4302,-42.9316]
vsw_dn         = [[vsw_x_dn],[vsw_y_dn],[vsw_z_dn]]
magf_dn        = [[mag_x_dn],[mag_y_dn],[mag_z_dn]]
temp_dn        = te_avg_dn + ti_avg_dn
FOR j=0L, 2L DO BEGIN                                                                             $
  IF (j EQ 0) THEN PRINT,';;', MEAN(dens_dn,/NAN),  MEAN(ti_avg_dn,/NAN), MEAN(te_avg_dn,/NAN)  & $
  IF (j EQ 1) THEN PRINT,';;', MEAN(vsw_x_dn,/NAN), MEAN(vsw_y_dn,/NAN),  MEAN(vsw_z_dn,/NAN)   & $
  IF (j EQ 2) THEN PRINT,';;', MEAN(mag_x_dn,/NAN), MEAN(mag_y_dn,/NAN),  MEAN(mag_z_dn,/NAN)
;;      101.277      179.582      66.0967
;;     -205.980      40.2591      39.5294
;;      11.9059     -7.86599     -35.9012

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
;;  => Equations 2, 3, 4, and 5 for 2011-10-24 bow shock
;;===========================================================
;;       13.378731       4.8127323
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2011-10-24 bow shock
;;===========================================================
;;       11.608364       6.3131453
;;-----------------------------------------------------------

;; => Print out best fit azimuthal angles
PRINT,';', soln.PHI*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2011-10-24 bow shock
;;===========================================================
;;       12.039725       7.4476791
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2011-10-24 bow shock
;;===========================================================
;;       11.149363       7.3837353
;;-----------------------------------------------------------

;; => Print out best fit shock normal speed in spacecraft frame [km/s]
PRINT,';', soln.VSHN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2011-10-24 bow shock
;;===========================================================
;;      -55.434457       46.611259
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2011-10-24 bow shock
;;===========================================================
;;      -58.924067       47.055054
;;-----------------------------------------------------------

;; => Print out best fit upstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_UP
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2011-10-24 bow shock
;;===========================================================
;;      -358.90271       52.087924
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2011-10-24 bow shock
;;===========================================================
;;      -358.12372       53.587383
;;-----------------------------------------------------------

;; => Print out best fit downstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_DN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2011-10-24 bow shock
;;===========================================================
;;      -121.04489       27.134678
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2011-10-24 bow shock
;;===========================================================
;;      -120.80463       27.525093
;;-----------------------------------------------------------

;; => Print out best fit shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,0]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2011-10-24 bow shock
;;===========================================================
;;      0.94022738      0.20054666      0.23057610
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2011-10-24 bow shock
;;===========================================================
;;      0.94742836      0.18668436      0.20001629
;;-----------------------------------------------------------

;; => Print out best fit uncertainty in shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,1]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2011-10-24 bow shock
;;===========================================================
;;     0.032865353      0.12215359     0.081169174
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2011-10-24 bow shock
;;===========================================================
;;     0.034078898      0.12191436      0.10723146
;;-----------------------------------------------------------












;;----------------------------------------------------------------------------------------
;; => Avg. terms [2nd Shock]
;;----------------------------------------------------------------------------------------
tr_up          = time_double(tdate[0]+'/'+['23:25:59.100','23:27:24.100'])
tr_dn          = time_double(tdate[0]+'/'+['23:32:17.700','23:33:42.700'])
t_foot_se      = time_double(tdate[0]+'/'+['23:27:57.200','23:28:14.596'])
t_ramp_se      = time_double(tdate[0]+'/'+['23:28:14.596','23:28:16.086'])

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
;;         340          28          28          28          28          28
;;         340          29          29          29          29          29

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

good_dn_Ni     = good_dn_Ni[0L:(gddnNi - 2L)]
gddnNi        -= 1L
dn_magf        = FLOAT(tm_magf[good_dn_Ni,*])
vswx_dn        = FLOAT(vswx[good_dn_Ni])
vswy_dn        = FLOAT(vswy[good_dn_Ni])
vswz_dn        = FLOAT(vswz[good_dn_Ni])
dn_Ti          = FLOAT(ti_temp[good_dn_Ni])
dn_Te          = FLOAT(te_temp[good_dn_Ni])
dn_Ni          = FLOAT(ti_dens.Y[good_dn_Ni])
dn_Pi          = FLOAT(pi_temp[good_dn_Ni])

FOR j=0L, 3L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', up_Ni         & $
  IF (j EQ 1) THEN PRINT,';;', up_Ti         & $
  IF (j EQ 2) THEN PRINT,';;', up_Te         & $
  IF (j EQ 3) THEN PRINT,';;', up_Pi
;;      20.4884      20.3999      20.4646      20.3362      20.2768      20.3263      20.3225      20.3453      20.2677      20.4107      20.3682      20.4984      20.4135      20.2733      20.3581      20.7056      20.9606      20.8741      20.7657      20.7135      20.4439      20.4884      20.3726      20.3967      20.4270      20.1912      20.3319      20.3011
;;      65.1907      65.2754      65.8492      66.4731      68.1623      65.8844      64.5873      65.2352      63.0126      62.6111      62.9895      63.5105      63.8370      63.3926      62.0900      63.6473      63.3889      63.3408      64.3072      64.6475      65.2912      64.0589      63.7401      62.8243      63.9233      62.3120      62.8625      66.0584
;;      17.9203      17.8061      17.8575      17.7225      17.7457      17.8344      17.9801      18.5486      19.0541      19.1813      19.3129      18.8355      19.3835      19.2115      18.8619      18.9377      18.4725      18.2105      18.2035      18.1943      18.3298      18.9282      19.6477      19.2154      19.1243      19.6260      19.0754      19.4169
;;      117.269      116.022      106.004      113.129      97.5187      108.953      118.672      118.931      132.185      130.396      126.886      126.471      128.811      135.722      135.675      126.543      127.753      124.968      122.607      120.933      117.813      126.954      130.194      135.250      125.165      124.339      130.758      109.645
FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vswx_up       & $
  IF (j EQ 1) THEN PRINT,';;', vswy_up       & $
  IF (j EQ 2) THEN PRINT,';;', vswz_up
;;     -475.979     -477.694     -475.387     -476.370     -478.039     -476.505     -475.722     -475.784     -476.461     -474.131     -475.023     -478.436     -476.520     -477.718     -474.245     -476.082     -477.565     -478.004     -477.053     -483.476     -477.940     -477.510     -476.510     -479.918     -484.700     -476.965     -474.051     -472.987
;;      105.490      105.294      105.437      105.796      106.474      105.641      105.428      105.564      104.915      89.8203      104.631      105.339      104.913      105.735      88.7078      105.545      105.187      105.507      105.992      114.816      106.098      105.884      105.621      106.474      107.121      105.270      105.429      106.415
;;     0.669752      1.62308     -3.40934     -2.99144     -8.76027     -2.01712      1.11664     0.786707      8.01699      57.9651      6.10666      6.82078      5.40401      7.03668      52.8821      4.14456      5.82437      5.63130      3.16333      38.9797      1.98838      4.30905      5.23688      8.79025      60.6070      8.07110      5.09184     -6.27728
FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', up_magf[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', up_magf[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', up_magf[*,2]
;;      3.95832      3.72796      3.44872      3.37134      3.64818      3.95980      4.11019      4.09106      4.13026      4.11809      3.91129      4.00379      4.13065      4.22834      4.27705      4.19532      4.12318      3.84574      3.74412      3.73317      3.81132      4.07961      4.11204      4.08909      3.86644      4.10861      4.24875      4.38268
;;      14.6157      14.3820      14.3355      13.9725      13.7714      13.7940      14.1976      14.6807      15.1602      15.2291      15.2456      15.3578      15.4312      15.3549      14.9211      14.7945      14.7080      14.8575      14.8072      14.7778      14.7784      14.7966      14.8657      14.7936      14.7969      14.5123      13.8042      13.2043
;;     -9.89026     -10.2917     -10.4310     -10.9467     -11.2107     -11.1283     -10.4809     -9.68801     -8.98478     -8.93028     -9.08622     -8.99087     -8.86571     -8.97449     -9.54341     -9.64122     -9.81439     -9.73680     -9.85830     -9.94296     -9.94670     -9.84675     -9.82825     -9.95791     -10.0279     -10.3055     -11.0187     -11.6332


FOR j=0L, 3L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dn_Ni         & $
  IF (j EQ 1) THEN PRINT,';;', dn_Ti         & $
  IF (j EQ 2) THEN PRINT,';;', dn_Te         & $
  IF (j EQ 3) THEN PRINT,';;', dn_Pi
;;      97.7353      103.961      96.1127      104.440      108.566      93.4252      106.570      100.165      91.6518      94.1491      95.0104      92.3584      95.6827      103.493      98.3369      94.1425      91.3264      91.9260      97.4444      100.038      93.8576      91.2367      96.1549      103.862      95.7850      98.2559      93.8839      97.1244
;;      161.794      154.807      159.586      191.842      165.086      203.221      163.249      158.627      188.689      169.491      166.042      171.503      177.154      177.277      184.716      179.410      186.594      183.954      184.144      190.805      185.872      197.127      163.966      169.817      198.813      161.190      172.726      179.104
;;      77.0573      81.4005      76.2019      78.8614      80.9883      79.4912      82.5376      82.2199      81.0119      81.7797      83.3978      82.7277      83.1693      85.7494      83.8226      81.3296      80.7120      80.8404      82.8453      82.8036      79.3457      80.4357      80.9059      85.4039      83.4979      82.1474      80.8335      79.4810
;;      4460.87      4325.13      5428.36      6148.06      5903.66      6337.65      5095.44      6202.89      5168.52      4867.63      4291.14      4449.05      5568.63      4822.79      7303.80      5444.26      4059.86      5846.77      5652.67      5737.97      5872.61      3826.03      4861.17      4681.93      5824.26      5105.41      4085.82      5362.99
FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vswx_dn       & $
  IF (j EQ 1) THEN PRINT,';;', vswy_dn       & $
  IF (j EQ 2) THEN PRINT,';;', vswz_dn
;;     -175.652     -160.571     -173.927     -182.551     -173.265     -216.669     -172.414     -203.041     -195.470     -176.645     -155.468     -177.561     -176.449     -193.567     -195.790     -214.438     -222.827     -209.365     -207.029     -188.173     -185.432     -172.070     -185.334     -183.822     -165.243     -195.732     -177.782     -191.599
;;      98.5058      91.7560      100.149      89.2872      90.5032      134.331      100.677      109.643      93.2638      100.867      102.160      123.756      128.028      122.465      110.640      123.830      116.334      119.238      128.063      125.369      119.962      116.710      110.021      115.997      91.3448      102.136      88.1795      101.750
;;      87.9536      85.5892      90.4649      94.8019      84.9232      97.2962      79.5297      48.7098      96.8125      77.3885      108.070      91.6150      118.049      119.705      69.6408      82.1466      65.8207      70.7889      90.4966      90.4354      78.1375      86.2036      62.0606      72.2139      81.6851      63.5564      73.8363      78.4062
FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dn_magf[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', dn_magf[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', dn_magf[*,2]
;;      7.97413      6.34274      3.81728      3.56164      3.26105     0.473852    -0.820525     0.147559    -0.697037    0.0705264     -2.27266     -1.05761     -2.74200     -2.17456     -3.46791     -2.16404     -4.20379     -5.02802     -5.34261     -4.09868     -1.03930     0.491873      1.95236      4.93173      6.92560      7.94071      7.92644      9.00408
;;      45.9117      44.5649      45.7249      44.0008      48.4214      51.2335      55.2072      53.8444      55.5970      56.4709      56.0299      53.8568      54.1458      55.4588      55.3757      54.7013      53.1143      54.3468      58.2819      58.5675      56.6824      56.5353      53.8411      49.5831      47.0836      44.6277      43.6704      41.2115
;;     -31.1549     -32.0156     -31.9886     -32.2277     -27.6668     -21.1195     -15.2046     -13.3969     -14.2768     -12.6439     -11.8614     -13.9432     -12.9898     -11.2997     -10.2390     -12.6414     -13.3496     -13.9953     -12.4773     -8.35180     -11.5563     -13.5146     -14.1254     -21.1855     -30.9652     -36.3960     -35.4089     -36.2981


;; => Upstream values
dens_up        = [ 20.4884,20.3999,20.4646,20.3362,20.2768,20.3263,20.3225,20.3453,20.2677,20.4107,20.3682,20.4984,20.4135,20.2733,20.3581,20.7056,20.9606,20.8741,20.7657,20.7135,20.4439,20.4884,20.3726,20.3967,20.4270,20.1912,20.3319,20.3011]
ti_avg_up      = [ 65.1907,65.2754,65.8492,66.4731,68.1623,65.8844,64.5873,65.2352,63.0126,62.6111,62.9895,63.5105,63.8370,63.3926,62.0900,63.6473,63.3889,63.3408,64.3072,64.6475,65.2912,64.0589,63.7401,62.8243,63.9233,62.3120,62.8625,66.0584]
te_avg_up      = [ 17.9203,17.8061,17.8575,17.7225,17.7457,17.8344,17.9801,18.5486,19.0541,19.1813,19.3129,18.8355,19.3835,19.2115,18.8619,18.9377,18.4725,18.2105,18.2035,18.1943,18.3298,18.9282,19.6477,19.2154,19.1243,19.6260,19.0754,19.4169]
Pi_up          = [ 117.269,116.022,106.004,113.129,97.5187,108.953,118.672,118.931,132.185,130.396,126.886,126.471,128.811,135.722,135.675,126.543,127.753,124.968,122.607,120.933,117.813,126.954,130.194,135.250,125.165,124.339,130.758,109.645]
vsw_x_up       = [-475.979,-477.694,-475.387,-476.370,-478.039,-476.505,-475.722,-475.784,-476.461,-474.131,-475.023,-478.436,-476.520,-477.718,-474.245,-476.082,-477.565,-478.004,-477.053,-483.476,-477.940,-477.510,-476.510,-479.918,-484.700,-476.965,-474.051,-472.987]
vsw_y_up       = [ 105.490,105.294,105.437,105.796,106.474,105.641,105.428,105.564,104.915,89.8203,104.631,105.339,104.913,105.735,88.7078,105.545,105.187,105.507,105.992,114.816,106.098,105.884,105.621,106.474,107.121,105.270,105.429,106.415]
vsw_z_up       = [0.669752,1.62308,-3.40934,-2.99144,-8.76027,-2.01712,1.11664,0.786707,8.01699,57.9651,6.10666,6.82078,5.40401,7.03668,52.8821,4.14456,5.82437,5.63130,3.16333,38.9797,1.98838,4.30905,5.23688,8.79025,60.6070,8.07110,5.09184,-6.27728]
mag_x_up       = [ 3.95832,3.72796,3.44872,3.37134,3.64818,3.95980,4.11019,4.09106,4.13026,4.11809,3.91129,4.00379,4.13065,4.22834,4.27705,4.19532,4.12318,3.84574,3.74412,3.73317,3.81132,4.07961,4.11204,4.08909,3.86644,4.10861,4.24875,4.38268]
mag_y_up       = [ 14.6157,14.3820,14.3355,13.9725,13.7714,13.7940,14.1976,14.6807,15.1602,15.2291,15.2456,15.3578,15.4312,15.3549,14.9211,14.7945,14.7080,14.8575,14.8072,14.7778,14.7784,14.7966,14.8657,14.7936,14.7969,14.5123,13.8042,13.2043]
mag_z_up       = [-9.89026,-10.2917,-10.4310,-10.9467,-11.2107,-11.1283,-10.4809,-9.68801,-8.98478,-8.93028,-9.08622,-8.99087,-8.86571,-8.97449,-9.54341,-9.64122,-9.81439,-9.73680,-9.85830,-9.94296,-9.94670,-9.84675,-9.82825,-9.95791,-10.0279,-10.3055,-11.0187,-11.6332]
vsw_up         = [[vsw_x_up],[vsw_y_up],[vsw_z_up]]
magf_up        = [[mag_x_up],[mag_y_up],[mag_z_up]]
temp_up        = te_avg_up + ti_avg_up
FOR j=0L, 2L DO BEGIN                                                                             $
  IF (j EQ 0) THEN PRINT,';;', MEAN(dens_up,/NAN),  MEAN(ti_avg_up,/NAN), MEAN(te_avg_up,/NAN)  & $
  IF (j EQ 1) THEN PRINT,';;', MEAN(vsw_x_up,/NAN), MEAN(vsw_y_up,/NAN),  MEAN(vsw_z_up,/NAN)   & $
  IF (j EQ 2) THEN PRINT,';;', MEAN(mag_x_up,/NAN), MEAN(mag_y_up,/NAN),  MEAN(mag_z_up,/NAN)
;;      20.4472      64.2323      18.6656
;;     -477.028      104.805      9.88610
;;      3.98054      14.6409     -9.96436


;; => Downstream values
dens_dn        = [ 97.7353,103.961,96.1127,104.440,108.566,93.4252,106.570,100.165,91.6518,94.1491,95.0104,92.3584,95.6827,103.493,98.3369,94.1425,91.3264,91.9260,97.4444,100.038,93.8576,91.2367,96.1549,103.862,95.7850,98.2559,93.8839,97.1244]
ti_avg_dn      = [ 161.794,154.807,159.586,191.842,165.086,203.221,163.249,158.627,188.689,169.491,166.042,171.503,177.154,177.277,184.716,179.410,186.594,183.954,184.144,190.805,185.872,197.127,163.966,169.817,198.813,161.190,172.726,179.104]
te_avg_dn      = [ 77.0573,81.4005,76.2019,78.8614,80.9883,79.4912,82.5376,82.2199,81.0119,81.7797,83.3978,82.7277,83.1693,85.7494,83.8226,81.3296,80.7120,80.8404,82.8453,82.8036,79.3457,80.4357,80.9059,85.4039,83.4979,82.1474,80.8335,79.4810]
Pi_dn          = [ 4460.87,4325.13,5428.36,6148.06,5903.66,6337.65,5095.44,6202.89,5168.52,4867.63,4291.14,4449.05,5568.63,4822.79,7303.80,5444.26,4059.86,5846.77,5652.67,5737.97,5872.61,3826.03,4861.17,4681.93,5824.26,5105.41,4085.82,5362.99]
vsw_x_dn       = [-175.652,-160.571,-173.927,-182.551,-173.265,-216.669,-172.414,-203.041,-195.470,-176.645,-155.468,-177.561,-176.449,-193.567,-195.790,-214.438,-222.827,-209.365,-207.029,-188.173,-185.432,-172.070,-185.334,-183.822,-165.243,-195.732,-177.782,-191.599]
vsw_y_dn       = [ 98.5058,91.7560,100.149,89.2872,90.5032,134.331,100.677,109.643,93.2638,100.867,102.160,123.756,128.028,122.465,110.640,123.830,116.334,119.238,128.063,125.369,119.962,116.710,110.021,115.997,91.3448,102.136,88.1795,101.750]
vsw_z_dn       = [ 87.9536,85.5892,90.4649,94.8019,84.9232,97.2962,79.5297,48.7098,96.8125,77.3885,108.070,91.6150,118.049,119.705,69.6408,82.1466,65.8207,70.7889,90.4966,90.4354,78.1375,86.2036,62.0606,72.2139,81.6851,63.5564,73.8363,78.4062]
mag_x_dn       = [ 7.97413,6.34274,3.81728,3.56164,3.26105,0.473852,-0.820525,0.147559,-0.697037,0.0705264,-2.27266,-1.05761,-2.74200,-2.17456,-3.46791,-2.16404,-4.20379,-5.02802,-5.34261,-4.09868,-1.03930,0.491873,1.95236,4.93173,6.92560,7.94071,7.92644,9.00408]
mag_y_dn       = [ 45.9117,44.5649,45.7249,44.0008,48.4214,51.2335,55.2072,53.8444,55.5970,56.4709,56.0299,53.8568,54.1458,55.4588,55.3757,54.7013,53.1143,54.3468,58.2819,58.5675,56.6824,56.5353,53.8411,49.5831,47.0836,44.6277,43.6704,41.2115]
mag_z_dn       = [-31.1549,-32.0156,-31.9886,-32.2277,-27.6668,-21.1195,-15.2046,-13.3969,-14.2768,-12.6439,-11.8614,-13.9432,-12.9898,-11.2997,-10.2390,-12.6414,-13.3496,-13.9953,-12.4773,-8.35180,-11.5563,-13.5146,-14.1254,-21.1855,-30.9652,-36.3960,-35.4089,-36.2981]
vsw_dn         = [[vsw_x_dn],[vsw_y_dn],[vsw_z_dn]]
magf_dn        = [[mag_x_dn],[mag_y_dn],[mag_z_dn]]
temp_dn        = te_avg_dn + ti_avg_dn
FOR j=0L, 2L DO BEGIN                                                                             $
  IF (j EQ 0) THEN PRINT,';;', MEAN(dens_dn,/NAN),  MEAN(ti_avg_dn,/NAN), MEAN(te_avg_dn,/NAN)  & $
  IF (j EQ 1) THEN PRINT,';;', MEAN(vsw_x_dn,/NAN), MEAN(vsw_y_dn,/NAN),  MEAN(vsw_z_dn,/NAN)   & $
  IF (j EQ 2) THEN PRINT,';;', MEAN(mag_x_dn,/NAN), MEAN(mag_y_dn,/NAN),  MEAN(mag_z_dn,/NAN)
;;      97.3820      176.665      81.4642
;;     -186.710      109.106      83.7977
;;      1.06117      51.7175     -19.7248

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
;;  => Equations 2, 3, 4, and 5 for 2011-10-24 bow shock
;;===========================================================
;;       27.731092       1.9169311
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2011-10-24 bow shock
;;===========================================================
;;       26.883117       2.5392768
;;-----------------------------------------------------------

;; => Print out best fit azimuthal angles
PRINT,';', soln.PHI*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2011-10-24 bow shock
;;===========================================================
;;       7.3109244       2.3988750
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2011-10-24 bow shock
;;===========================================================
;;       7.4255157       1.5798644
;;-----------------------------------------------------------

;; => Print out best fit shock normal speed in spacecraft frame [km/s]
PRINT,';', soln.VSHN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2011-10-24 bow shock
;;===========================================================
;;      -35.337053       22.480928
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2011-10-24 bow shock
;;===========================================================
;;      -37.141536       22.200237
;;-----------------------------------------------------------

;; => Print out best fit upstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_UP
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2011-10-24 bow shock
;;===========================================================
;;      -366.52901       25.238961
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2011-10-24 bow shock
;;===========================================================
;;      -367.71181       26.190841
;;-----------------------------------------------------------

;; => Print out best fit downstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_DN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2011-10-24 bow shock
;;===========================================================
;;      -77.122586       6.3587928
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2011-10-24 bow shock
;;===========================================================
;;      -77.371965       6.5384612
;;-----------------------------------------------------------

;; => Print out best fit shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,0]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2011-10-24 bow shock
;;===========================================================
;;      0.87679030      0.11248801      0.46508356
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2011-10-24 bow shock
;;===========================================================
;;      0.88335655      0.11512753      0.45176740
;;-----------------------------------------------------------

;; => Print out best fit uncertainty in shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,1]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2011-10-24 bow shock
;;===========================================================
;;     0.015560171     0.035325151     0.028433587
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2011-10-24 bow shock
;;===========================================================
;;     0.019337096     0.023456233     0.037794171
;;-----------------------------------------------------------
















