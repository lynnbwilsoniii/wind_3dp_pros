;-----------------------------------------------------------------------------------------
; => Constants
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
epo    = 8.854187817d-12   ; => Permittivity of free space (F/m)
muo    = 4d0*!DPI*1d-7     ; => Permeability of free space (N/A^2 or H/m)
me     = 9.10938291d-31    ; => Electron mass (kg) [2010 value]
mp     = 1.672621777d-27   ; => Proton mass (kg) [2010 value]
ma     = 6.64465675d-27    ; => Alpha-Particle mass (kg) [2010 value]
qq     = 1.602176565d-19   ; => Fundamental charge (C) [2010 value]
kB     = 1.3806488d-23     ; => Boltzmann Constant (J/K) [2010 value]
K_eV   = 1.1604519d4       ; => Factor [Kelvin/eV] [2010 value]
c      = 2.99792458d8      ; => Speed of light in vacuum (m/s)
R_E    = 6.37814d3         ; => Earth's Equitorial Radius (km)

; => Compile necessary routines
@comp_lynn_pros
; => Load all relevant data
tdate     = '2009-07-13'
tr_00     = tdate[0]+'/'+['07:50:00','10:10:00']
date      = '071309'
probe     = 'b'
themis_load_all_inst,DATE=date[0],PROBE=probe[0],TRANGE=time_double(tr_00)

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100

.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/SCIENCE_PRO/plot_map.pro

;; => Load packet info for structures
thm_load_esa_pkt,PROBE=probe[0]
;-----------------------------------------------------------------------------------------
; => Load ESA Save Files
;-----------------------------------------------------------------------------------------
coord   = 'gse'
sc      = probe[0]
pref    = 'th'+sc[0]+'_'
velname = pref[0]+'peib_velocity_'+coord[0]
magname = pref[0]+'fgh_'+coord[0]

; => Load IESA DFs [with THETA and PHI in GSE Coords]
;format  = pref[0]+'peib'
;peib_df_arr_b = thm_part_dist_array(FORMAT=format[0],TRANGE=tr,MAG_DATA=magname[0],$
;                                    VEL_DATA=velname[0])
;
; => Load IESA DFs [with THETA and PHI in GSE Coords]
;velname = pref[0]+'peeb_velocity_'+coord[0]
;format  = pref[0]+'peeb'
;peeb_df_arr_b = thm_part_dist_array(FORMAT=format[0],TRANGE=tr,MAG_DATA=magname[0],$
;                                    VEL_DATA=velname[0])
;

enames  = 'EESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames  = 'IESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
;SAVE,peeb_df_arr_b,FILENAME=enames[0]
;SAVE,peib_df_arr_b,FILENAME=inames[0]

mdir    = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_esa_save/'+tdate[0]+'/')
efiles  = FILE_SEARCH(mdir,enames[0])
ifiles  = FILE_SEARCH(mdir,inames[0])

RESTORE,efiles[0]
RESTORE,ifiles[0]

;; => Redefine structures
dat_i     = peib_df_arr_b
dat_e     = peeb_df_arr_b
n_i       = N_ELEMENTS(dat_i)
n_e       = N_ELEMENTS(dat_e)
PRINT,';', n_i, n_e
;        1371        1374

dat_i0    = dat_i[0]
HELP,dat_i0,/STRUCTURES,OUTPUT=out
FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';;  ',out[j]
;;----------------------------------------------------------------------------------------
;;  ** Structure <1865408>, 38 tags, length=152272, data length=152247, refs=3:
;;     PROJECT_NAME    STRING    'THEMIS'
;;     SPACECRAFT      STRING    'b'
;;     DATA_NAME       STRING    'IESA 3D burst'
;;     APID            INT            456
;;     UNITS_NAME      STRING    'counts'
;;     UNITS_PROCEDURE STRING    'thm_convert_esa_units'
;;     VALID           BYTE         1
;;     TIME            DOUBLE       1.2474697e+09
;;     END_TIME        DOUBLE       1.2474697e+09
;;     DELTA_T         DOUBLE           2.9679589
;;     INTEG_T         DOUBLE        0.0028983974
;;     DT_ARR          FLOAT     Array[32, 88]
;;     CONFIG1         BYTE         2
;;     CONFIG2         BYTE         1
;;     AN_IND          INT              1
;;     EN_IND          INT              1
;;     MODE            INT              2
;;     NENERGY         INT             32
;;     ENERGY          FLOAT     Array[32, 88]
;;     DENERGY         FLOAT     Array[32, 88]
;;     EFF             DOUBLE    Array[32, 88]
;;     BINS            INT       Array[32, 88]
;;     NBINS           INT             88
;;     THETA           FLOAT     Array[32, 88]
;;     DTHETA          FLOAT     Array[32, 88]
;;     PHI             FLOAT     Array[32, 88]
;;     DPHI            FLOAT     Array[32, 88]
;;     DOMEGA          FLOAT     Array[32, 88]
;;     GF              FLOAT     Array[32, 88]
;;     GEOM_FACTOR     FLOAT        0.00153000
;;     DEAD            FLOAT       1.70000e-07
;;     MASS            FLOAT         0.0104389
;;     CHARGE          FLOAT           1.00000
;;     SC_POT          FLOAT           0.00000
;;     MAGF            FLOAT     Array[3]
;;     BKG             FLOAT     Array[32, 88]
;;     DATA            FLOAT     Array[32, 88]
;;     VELOCITY        DOUBLE    Array[3]
;;----------------------------------------------------------------------------------------



;;----------------------------------------------------------------------------------------
;;  Create timestamps for each energy-angle bin
;;----------------------------------------------------------------------------------------


sc        = probe[0]
pref      = 'th'+sc[0]+'_'
get_data,pref[0]+'state_spinper',DATA=sp_per
sp_t      = sp_per.X
sp_p      = sp_per.Y          ;; Spacecraft spin period [s]


dat       = dat_e[0]
n_e       = dat.NENERGY       ;; => # of energy bins
n_a       = dat.NBINS         ;; => # of angle bins

phi       = dat.PHI           ;; [E,A]-Element Array of azimuthal angles [deg, DSL]
;; => Accumulation time [s] of each angle bin
tacc      = dat[0].INTEG_T[0]*dat[0].DT_ARR
t0        = dat.TIME[0]       ;; => Unix time at start of ESA sample period
t1        = dat.END_TIME[0]   ;; => Unix time at end of ESA sample period
del_t     = t1[0] - t0[0]     ;; => Total time of data sample
;; => Create array of dummy time stamps
dumbt     = DINDGEN(n_e,n_a)*del_t[0]/(n_e[0]*n_a[0] - 1L) + t0[0]
;; => Calculate spin period [s/rotation] at ESA structure time
spp0      = interp(sp_p,sp_t,dumbt,/NO_EXTRAP)
;; => Calculate spin rate [deg s^(-1)] at ESA structure time
sprate    = 36d1/spp0

phi_00    = phi[0,0]          ;; => 1st DSL azimuthal angle sampled
;; => Shift the rest of the angles so that phi_00 = 0d0
sh_phi    = phi - phi_00[0]
;; => Adjust negative values so they are > 360
shphi36   = sh_phi
low_phi   = WHERE(sh_phi LT 0,glw)
IF (glw GT 0) THEN shphi36[low_phi] += 36d1
;; => Define time diff. [s] from middle of first data point
d_t_phi   = shphi36/sprate
;; => These times are actually 1/2 an accumulation time from the true start time of each bin
d_t_trp   = d_t_phi + tacc/2d0
;; => Define the associated time stamps for each angle bin
ti_angs   = t0[0] + d_t_trp


dat       = dat_e[0]
name      = pref[0]+'state_spinper'
.compile timestamp_esa_angle_bins
ti_angs2  = timestamp_esa_angle_bins(dat,name[0])
diff      = ti_angs2 - ti_angs
PRINT,';; ',minmax(diff)
;;        0.0000000       0.0000000


dat_e2    = dat_e
modify_themis_esa_struc,dat_e2
;; add SC potential to structures
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
scname    = tnames(pref[0]+'pe*b_sc_pot')
add_scpot,dat_e2,scname[0]
;; => Rotate IESA (theta,phi)-angles DSL --> GSE
coord     = 'gse'
sc        = probe[0]
vel_name  = pref[0]+'peib_velocity_'+coord[0]
mag_name  = pref[0]+'fgh_'+coord[0]
rotate_esa_thetaphi_to_gse,dat_e2,MAGF_NAME=mag_name,VEL_NAME=vel_name


dat       = dat_e2[0]
name      = pref[0]+'state_spinper'
.compile timestamp_esa_angle_bins
ti_angs3  = timestamp_esa_angle_bins(dat,name[0])

diff      = ti_angs3 - ti_angs2
PRINT,';; ',minmax(diff)
;;       -2.8897061       2.9633517


;;----------------------------------------------------------------------------------------
;; => Modify structures so they work in my plotting routines
;;----------------------------------------------------------------------------------------
modify_themis_esa_struc,dat_i
modify_themis_esa_struc,dat_e

;; add SC potential to structures
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
scname    = tnames(pref[0]+'pe*b_sc_pot')

add_scpot,dat_e,scname[0]
add_scpot,dat_i,scname[1]

;; => Rotate IESA (theta,phi)-angles DSL --> GSE
coord    = 'gse'
sc       = probe[0]
vel_name = pref[0]+'peib_velocity_'+coord[0]
mag_name = pref[0]+'fgh_'+coord[0]
rotate_esa_thetaphi_to_gse,dat_i,MAGF_NAME=mag_name,VEL_NAME=vel_name


;; => Rotate EESA (theta,phi)-angles DSL --> GSE
coord    = 'gse'
sc       = probe[0]
vel_name = pref[0]+'peeb_velocity_'+coord[0]
mag_name = pref[0]+'fgh_'+coord[0]
rotate_esa_thetaphi_to_gse,dat_e,MAGF_NAME=mag_name,VEL_NAME=vel_name
;-----------------------------------------------------------------------------------------
; => Set up plot windows and defaults
;-----------------------------------------------------------------------------------------
WINDOW,1,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,2,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,3,RETAIN=2,XSIZE=800,YSIZE=1100

; => setup colors
LOADCT,39
DEVICE,DECOMPOSED=0


; => Define shock parameters
;;        => flip solutions to outward normal [contour min in opposite direction]
vshn_0  = -1d0*(3.6977553d0)
ushn_0  = -1d0*(204.62596d0)
gnorm_0 = -1d0*[-0.54904591d0,-0.068017244d0,0.82887820d0]
; => Vsw [GSE], |Vsw| (km/s)
vsw_up0 = [-252.883d0,-7.32447d0,83.2220d0]
vmag_u0 = NORM(vsw_up0)
; => B [GSE], |B| (nT)
mag_up0 = [-2.88930d0,1.79045d0,-1.37976d0]
bmag_u0 = NORM(mag_up0)

; => flip solutions to outward normal [contour min in opposite direction]
vshn_1  = -1d0*8.3990575d0
ushn_1  = -1d0*272.10318d0
gnorm_1 = -1d0*[-0.98231348d0,-0.10981114d0,0.019119436d0]
; => Vsw [GSE], |Vsw| (km/s)
vsw_up1 = [-284.261d0,-14.5620d0,-17.2934d0]
vmag_u1 = NORM(vsw_up1)
; => B [GSE], |B| (nT)
mag_up1 = [-2.16373d0,-1.43950d0,1.97681d0]
bmag_u1 = NORM(mag_up1)

vshn_2  = vshn_1[0]
ushn_2  = ushn_1[0]
gnorm_2 = gnorm_1
vsw_up2 = vsw_up1
vmag_u2 = vmag_u1
mag_up2 = mag_up1
bmag_u2 = bmag_u1

;-----------------------------------------------------
; => Calculate gyrospeeds of specular reflection
;-----------------------------------------------------

; => calculate unit vectors
bhat0    = mag_up0/bmag_u0[0]
vhat0    = vsw_up0/vmag_u0[0]
bhat1    = mag_up1/bmag_u1[0]
vhat1    = vsw_up1/vmag_u1[0]
bhat2    = bhat1
vhat2    = vhat1
; => calculate upstream inflow velocity
v_up_0   = vsw_up0 - gnorm_0*vshn_0[0]
v_up_1   = vsw_up1 - gnorm_1*vshn_1[0]
v_up_2   = v_up_1
; => Eq. 2 from Gosling et al., [1982]
;      [specularly reflected ion velocity]
Vref_0   = v_up_0 - gnorm_0*(2d0*my_dot_prod(v_up_0,gnorm_0,/NOM))
Vref_1   = v_up_1 - gnorm_1*(2d0*my_dot_prod(v_up_1,gnorm_1,/NOM))
Vref_2   = Vref_1
; => Eq. 4 and 3 from Gosling et al., [1982]
;      [guiding center velocity of a specularly reflected ion]
Vper_r0  = v_up_0 - bhat0*my_dot_prod(v_up_0,bhat0,/NOM)  ; => Eq. 4
Vper_r1  = v_up_1 - bhat1*my_dot_prod(v_up_1,bhat1,/NOM)  ; => Eq. 4
Vper_r2  = Vper_r1
Vgc_r_0  = Vper_r0 + bhat0*(my_dot_prod(Vref_0,bhat0,/NOM))
Vgc_r_1  = Vper_r1 + bhat1*(my_dot_prod(Vref_1,bhat1,/NOM))
Vgc_r_2  = Vgc_r_1
; => Eq. 6 from Gosling et al., [1982]
;      [gyro-velocity of a specularly reflected ion]
Vgy_r_0  = Vref_0 - Vgc_r_0
Vgy_r_1  = Vref_1 - Vgc_r_1
Vgy_r_2  = Vgy_r_1
; => Eq. 7 and 9 from Gosling et al., [1982]
;      [guiding center velocity of a specularly reflected ion perp. to shock surface]
Vgcn_r_0 = my_dot_prod(Vgc_r_0,gnorm_0,/NOM)
Vgcn_r_1 = my_dot_prod(Vgc_r_1,gnorm_1,/NOM)
Vgcn_r_2 = Vgcn_r_1
;      [guiding center velocity of a specularly reflected ion para. to B-field]
Vgcb_r_0 = my_dot_prod(Vgc_r_0,bhat0,/NOM)
Vgcb_r_1 = my_dot_prod(Vgc_r_1,bhat1,/NOM)
Vgcb_r_2 = Vgcb_r_1
; => gyrospeed
Vgy_rs_0 = NORM(REFORM(Vgy_r_0))
Vgy_rs_1 = NORM(REFORM(Vgy_r_1))
Vgy_rs_2 = Vgy_rs_1

PRINT,';', Vgy_rs_0[0], Vgy_rs_1[0], Vgy_rs_2[0]
;       406.31657       374.12222       374.12222


Vgy_rs   = [406.31657d0,374.12222d0,374.12222d0]
;-----------------------------------------------------
; IESA
;-----------------------------------------------------
i_time0 = dat_i.TIME
i_time1 = dat_i.END_TIME
tbow0   = time_double(tdate[0]+'/'+['08:56:00.000','09:10:00.000'])
tbow1   = time_double(tdate[0]+'/'+['09:14:00.000','09:30:00.000'])
tbow2   = time_double(tdate[0]+'/'+['09:30:00.000','09:44:00.000'])
good_i0 = WHERE(i_time0 GE tbow0[0] AND i_time1 LE tbow0[1],gdi0)
good_i1 = WHERE(i_time0 GE tbow1[0] AND i_time1 LE tbow1[1],gdi1)
good_i2 = WHERE(i_time0 GE tbow2[0] AND i_time1 LE tbow2[1],gdi2)
PRINT,';', gdi0, gdi1, gdi2
;         281         318         279

dat_i0  = dat_i[good_i0]
dat_i1  = dat_i[good_i1]
dat_i2  = dat_i[good_i2]

;gnorm   = [0.,1.,0.]
;normnm  = 'Y-GSE'
;vcirc   = 750d0             ; => Put a circle of constant energy at  750 km/s on contours

ngrid   = 30L
sunv    = [1.,0.,0.]
sunn    = 'Sun Dir.'
xname   = 'B!Do!N'
yname   = 'V!Dsw!N'

vlim    = 25e2
ns      = 7L
smc     = 1
smct    = 1
;dfmin   = 1d-20
dfmax   = 1d-1
dfmin   = 1d-15
;dfmax   = 1d-5

;j       = 102L
j       = 79L
tr_ie   = tbow0
dat_0   = dat_i0[j]
gnorm   = gnorm_0
normnm  = 'Shock Normal[0]'
vcirc   = Vgy_rs[0]
;tr_ie   = tbow1
;dat_0   = dat_i1[j]
;gnorm   = gnorm_1
;normnm  = 'Shock Normal[1]'
;vcirc   = Vgy_rs[1]
;tr_ie   = tbow2
;dat_0   = dat_i2[j]
;gnorm   = gnorm_2
;normnm  = 'Shock Normal[2]'
;vcirc   = Vgy_rs[2]
WSET,0
mode    = 'fgh'
names   = 'th'+sc[0]+'_'+[mode[0]+['_mag','_gsm'],'efw_cal_gsm','scw_gsm_L2']
  tplot,names,/NOM,TRANGE=tr_ie
  time_bar,dat_0[0].TIME,VARNAME=names,COLOR=250L
  time_bar,dat_0[0].END_TIME,VARNAME=names,COLOR= 50L

vec1    = dat_0.MAGF
vec2    = dat_0.VSW

WSET,1
WSHOW,1
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='xy',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]

WSET,2
WSHOW,2
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='xz',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]

WSET,3
WSHOW,3
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='yz',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]
;-----------------------------------------------------
; => Make a ?? fps movie
;-----------------------------------------------------
tbow0      = time_double(tdate[0]+'/'+['08:56:00.000','09:10:00.000'])
tbow1      = time_double(tdate[0]+'/'+['09:14:00.000','09:30:00.000'])
tbow2      = time_double(tdate[0]+'/'+['09:30:00.000','09:44:00.000'])
sunv       = [1.,0.,0.]     ; => sun direction in GSE coordinates
sunn       = 'Sun Dir.'     ; => string associated with sun direction
timename   = ['thb_fgh_mag','thb_fgh_gse']

dat_aa     = dat_i0
gnorm      = gnorm_0
normnm     = 'Shock Normal[0]'
vcirc      = Vgy_rs[0]
;tr_aa      = tbow0

;dat_aa     = dat_i1
;gnorm      = gnorm_1
;normnm     = 'Shock Normal[1]'
;vcirc      = Vgy_rs[1]
;tr_aa      = tbow1

ngrid      = 30L
xname      = 'B!Do!N'
yname      = 'V!Dsw!N'
vlim       = 25e2
ns         = 7L
smc        = 1
smct       = 1
dfmax      = 1d-6
dfmin      = 1d-15
fps        = 4L             ; frames per second

;tr_aa      = time_double(tdate[0]+'/'+['09:00:00.000','09:03:00.000'])
tr_aa      = time_double(tdate[0]+'/'+['09:00:00.000','09:04:00.000'])

contour_df_pos_slide_wrapper,timename,dat_aa,VLIM=vlim[0],NGRID=ngrid[0],XNAME=xname[0],  $
                              YNAME=yname[0],VCIRC=vcirc[0],EX_VEC0=gnorm,                $
                              EX_VN0=normnm[0],EX_VEC1=sunv,EX_VN1=sunn[0],               $
                              PLANE='xy',SM_CONT=smct,DFRA=dfra,TRANGE=tr_aa,TROUTER=21d0,$
                              TSNAMES='FGM-fgh-GSE_',FRAMERATE=fps[0],/KEEP_SNAPS


; => try making a movie with:
;     x-axis = n
;     y-axis = (n x Xgse) x Xgse
niesa      = N_ELEMENTS(dat_aa)
xname      = 'n!Dsh!N'
yname      = 'X!Dgse!N'
vector10   = gnorm_0
vector20   = [1d0,0d0,0d0]
vec1       = DBLARR(niesa,3L)
vec2       = DBLARR(niesa,3L)
FOR k=0L, 2L DO vec1[*,k] = vector10[k]
FOR k=0L, 2L DO vec2[*,k] = vector20[k]

contour_df_pos_slide_wrapper,timename,dat_aa,VLIM=vlim[0],NGRID=ngrid[0],XNAME=xname[0], $
                              YNAME=yname[0],VCIRC=vcirc[0],PLANE='xy',                  $
                              SM_CONT=smct,DFRA=dfra,TRANGE=tr_aa,TROUTER=21d0,          $
                              TSNAMES='FGM-fgh-GSE_',FRAMERATE=fps[0],VECTOR1=vec1,      $
                              VECTOR2=vec2,EX_VEC0=gnorm,EX_VN0=normnm[0],EX_VEC1=sunv,  $
                              EX_VN1=sunn[0]

;-----------------------------------------------------
; => full time range
;-----------------------------------------------------
dat_aa     = dat_i0
gnorm      = gnorm_0
normnm     = 'Shock Normal[0]'
vcirc      = Vgy_rs[0]
tr_aa      = tbow0

ngrid      = 30L
xname      = 'B!Do!N'
yname      = 'V!Dsw!N'
vlim       = 25e2
ns         = 7L
smc        = 1
smct       = 1
dfmax      = 1d-6
dfmin      = 1d-15
fps        = 5L             ; frames per second

niesa      = N_ELEMENTS(dat_aa)
xname      = 'n!Dsh!N'
yname      = 'X!Dgse!N'
vector10   = gnorm_0
vector20   = [1d0,0d0,0d0]
vec1       = DBLARR(niesa,3L)
vec2       = DBLARR(niesa,3L)
FOR k=0L, 2L DO vec1[*,k] = vector10[k]
FOR k=0L, 2L DO vec2[*,k] = vector20[k]

contour_df_pos_slide_wrapper,timename,dat_aa,VLIM=vlim[0],NGRID=ngrid[0],XNAME=xname[0], $
                              YNAME=yname[0],VCIRC=vcirc[0],PLANE='xy',                  $
                              SM_CONT=smct,DFRA=dfra,TRANGE=tr_aa,TROUTER=21d0,          $
                              TSNAMES='FGM-fgh-GSE_',FRAMERATE=fps[0],VECTOR1=vec1,      $
                              VECTOR2=vec2,EX_VEC0=gnorm,EX_VN0=normnm[0],EX_VEC1=sunv,  $
                              EX_VN1=sunn[0]


; => shorter:
tr_aa      = time_double(tdate[0]+'/'+['08:59:10.000','09:03:35.000'])
ngrid      = 30L
xname      = 'B!Do!N'
yname      = 'V!Dsw!N'
vlim       = 25e2
ns         = 7L
smc        = 1
smct       = 1
dfmax      = 1d-6
dfmin      = 1d-15
fps        = 5L             ; frames per second

niesa      = N_ELEMENTS(dat_aa)
xname      = 'n!Dsh!N'
yname      = 'X!Dgse!N'
vector10   = gnorm_0
vector20   = [1d0,0d0,0d0]
vec1       = DBLARR(niesa,3L)
vec2       = DBLARR(niesa,3L)
FOR k=0L, 2L DO vec1[*,k] = vector10[k]
FOR k=0L, 2L DO vec2[*,k] = vector20[k]
contour_df_pos_slide_wrapper,timename,dat_aa,VLIM=vlim[0],NGRID=ngrid[0],XNAME=xname[0], $
                              YNAME=yname[0],VCIRC=vcirc[0],PLANE='xy',                  $
                              SM_CONT=smct,DFRA=dfra,TRANGE=tr_aa,TROUTER=21d0,          $
                              TSNAMES='FGM-fgh-GSE_',FRAMERATE=fps[0],VECTOR1=vec1,      $
                              VECTOR2=vec2,EX_VEC0=gnorm,EX_VN0=normnm[0],EX_VEC1=sunv,  $
                              EX_VN1=sunn[0]

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------
; => Save plots
;-----------------------------------------------------
ngrid   = 30L
sunv    = [1.,0.,0.]
sunn    = 'Sun Dir.'
xname   = 'B!Do!N'
yname   = 'V!Dsw!N'

vlim    = 25e2
ns      = 7L
smc     = 1
smct    = 1
dfmin   = 1d-14
dfmax   = 1d-5

dat_aa  = dat_i0
gnorm   = gnorm_0
normnm  = 'Shock Normal[0]'
vcirc   = Vgy_rs_0[0]
;dat_aa  = dat_i1
;gnorm   = gnorm_1
;normnm  = 'Shock Normal[1]'
;vcirc   = Vgy_rs_1[0]
;dat_aa  = dat_i2
;gnorm   = gnorm_2
;normnm  = 'Shock Normal[2]'
;vcirc   = Vgy_rs_2[0]

niesa   = N_ELEMENTS(dat_aa)
fnm     = file_name_times(dat_aa.TIME,PREC=3)
ftimes  = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494


scu     = STRUPCASE(probe[0])
df_sfxa = STRCOMPRESS(STRING(dfmin[0],FORMAT='(E10.1)'),/REMOVE_ALL)
vlim_st = STRING(vlim[0],FORMAT='(I5.5)')
xyzvecs = ['(V.B)','(BxV)xB','(BxV)']
xyzvecf = ['V1','V1xV2xV1','V1xV2']
planes  = ['xy','xz','yz']
xy_suff = '_'+xyzvecf[1]+'_vs_'+xyzvecf[0]
xz_suff = '_'+xyzvecf[0]+'_vs_'+xyzvecf[2]
yz_suff = '_'+xyzvecf[2]+'_vs_'+xyzvecf[1]
;xy_suff = '_'+xyzvecs[1]+'_vs_'+xyzvecs[0]
;xz_suff = '_'+xyzvecs[0]+'_vs_'+xyzvecs[2]
;yz_suff = '_'+xyzvecs[2]+'_vs_'+xyzvecs[1]
midstr  = '_Cuts-DF-Above_'

pref_a  = 'IESA_TH-'+scu[0]+'_'+ftimes+'_30Grids_'+vlim_st[0]+'km-s'
fnamexy = pref_a+xy_suff[0]+midstr[0]+df_sfxa
fnamexz = pref_a+xz_suff[0]+midstr[0]+df_sfxa
fnameyz = pref_a+yz_suff[0]+midstr[0]+df_sfxa
fnames  = [[fnamexy],[fnamexz],[fnameyz]]

FOR j=0L, niesa - 1L DO BEGIN                                                    $
  dat_0   = dat_aa[j]                                                          & $
  vec1    = dat_0.MAGF                                                         & $
  vec2    = dat_0.VSW                                                          & $
  FOR k=0L, 2L DO BEGIN                                                          $
    popen,fnames[j,k],/PORT                                                    & $
      contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,       $
                        YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,               $
                        DFRA=dfra,VCIRC=vcirc[0],PLANE=planes[k],EX_VEC1=sunv,   $
                        EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],           $
                        SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],       $
                        DFMAX=dfmax[0]                                         & $
    pclose

;; # Bash commands
mv IESA_TH-B_*_V1_vs_V1xV2_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1_vs_V1xV2/
mv IESA_TH-B_*_V1xV2_vs_V1xV2xV1_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1xV2_vs_V1xV2xV1/
mv IESA_TH-B_*_V1xV2xV1_vs_V1_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1xV2xV1_vs_V1/

;;-----------------------------------------------------
;; => Force DF range for emphasizing contours
;;-----------------------------------------------------
dfra    = [1d-14,1d-8]
scu     = STRUPCASE(probe[0])
df_sfx0 = STRCOMPRESS(STRING(dfra[0],FORMAT='(E10.1)'),/REMOVE_ALL)
df_sfx1 = STRCOMPRESS(STRING(dfra[1],FORMAT='(E10.1)'),/REMOVE_ALL)
df_sfxa = df_sfx0[0]+'-'+df_sfx1[0]
vlim_st = STRING(vlim[0],FORMAT='(I5.5)')
xyzvecs = ['(V.B)','(BxV)xB','(BxV)']
xyzvecf = ['Bo','BoxVswxBo','BoxVsw']
planes  = ['xy','xz','yz']
xy_suff = '_'+xyzvecf[1]+'_vs_'+xyzvecf[0]
xz_suff = '_'+xyzvecf[0]+'_vs_'+xyzvecf[2]
yz_suff = '_'+xyzvecf[2]+'_vs_'+xyzvecf[1]
midstr  = '_Cuts-DF_'

pref_a  = 'ContourOnly_IESA_TH-'+scu[0]+'_'+ftimes+'_30Grids_'+vlim_st[0]+'km-s'
fnamexy = pref_a+xy_suff[0]+midstr[0]+df_sfxa[0]
fnamexz = pref_a+xz_suff[0]+midstr[0]+df_sfxa[0]
fnameyz = pref_a+yz_suff[0]+midstr[0]+df_sfxa[0]
fnames  = [[fnamexy],[fnamexz],[fnameyz]]

FOR j=0L, niesa - 1L DO BEGIN                                                    $
  dat_0   = dat_aa[j]                                                          & $
  vec1    = dat_0.MAGF                                                         & $
  vec2    = dat_0.VSW                                                          & $
  FOR k=0L, 2L DO BEGIN                                                          $
    popen,fnames[j,k],/PORT                                                    & $
      contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,       $
                        YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,               $
                        DFRA=dfra,VCIRC=vcirc[0],PLANE=planes[k],EX_VEC1=sunv,   $
                        EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],           $
                        SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],       $
                        DFMAX=dfmax[0]                                         & $
    pclose

;; # Bash commands
mv ContourOnly_IESA_TH-B_*_Bo_vs_BoxVsw_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1_vs_V1xV2/
mv ContourOnly_IESA_TH-B_*_BoxVsw_vs_BoxVswxBo_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1xV2_vs_V1xV2xV1/
mv ContourOnly_IESA_TH-B_*_BoxVswxBo_vs_Bo_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1xV2xV1_vs_V1/


;;-----------------------------------------------------
;; => Use shock normal as horizontal
;;      +Xgse as vertical
;;-----------------------------------------------------
ngrid   = 30L
sunv    = [1d0,0d0,0d0]
gnorm   = gnorm_0
yname   = 'X!Dgse!N'
xname   = 'n!Dsh!N'
exnm0   = 'B!Do!N'
exnm1   = 'X!Dgse!N'
exv1    = [1d0,0d0,0d0]

vlim    = 25e2
ns      = 7L
smc     = 1
smct    = 1
dfmin   = 1d-14
dfmax   = 1d-5
dfra    = [1d-14,1d-8]
vcirc   = Vgy_rs[0]

dat_aa  = dat_i0
niesa   = N_ELEMENTS(dat_aa)
fnm     = file_name_times(dat_aa.TIME,PREC=3)
ftimes  = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494

scu     = STRUPCASE(probe[0])
df_sfx0 = STRCOMPRESS(STRING(dfra[0],FORMAT='(E10.1)'),/REMOVE_ALL)
df_sfx1 = STRCOMPRESS(STRING(dfra[1],FORMAT='(E10.1)'),/REMOVE_ALL)
df_sfxa = df_sfx0[0]+'-'+df_sfx1[0]
vlim_st = STRING(vlim[0],FORMAT='(I5.5)')
xyzvecs = ['(V.B)','(BxV)xB','(BxV)']
xyzvecf = ['n','nxXGSExn','nxXGSE']
planes  = ['xy','xz','yz']
xy_suff = '_'+xyzvecf[1]+'_vs_'+xyzvecf[0]
xz_suff = '_'+xyzvecf[0]+'_vs_'+xyzvecf[2]
yz_suff = '_'+xyzvecf[2]+'_vs_'+xyzvecf[1]
midstr  = '_Cuts-DF_'

pref_a  = 'ContourOnly_IESA_TH-'+scu[0]+'_'+ftimes+'_30Grids_'+vlim_st[0]+'km-s'
fnamexy = pref_a+xy_suff[0]+midstr[0]+df_sfxa[0]
fnamexz = pref_a+xz_suff[0]+midstr[0]+df_sfxa[0]
fnameyz = pref_a+yz_suff[0]+midstr[0]+df_sfxa[0]
fnames  = [[fnamexy],[fnamexz],[fnameyz]]

FOR j=0L, niesa - 1L DO BEGIN                                                    $
  dat_0   = dat_aa[j]                                                          & $
  vec1    = gnorm                                                              & $
  vec2    = sunv                                                               & $
  exv0    = dat_0.MAGF                                                         & $
  FOR k=0L, 2L DO BEGIN                                                          $
    popen,fnames[j,k],/PORT                                                    & $
      contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,       $
                        YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,               $
                        DFRA=dfra,VCIRC=vcirc[0],PLANE=planes[k],EX_VEC1=exv1,   $
                        EX_VN1=exnm1[0],EX_VEC0=exv0,EX_VN0=exnm0[0],            $
                        SM_CONT=smct,/NO_REDF,INTERP=inter                     & $
    pclose



;; # Bash commands
mv ContourOnly_IESA_TH-B_*_n_vs_nxXGSE_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1_vs_V1xV2/
mv ContourOnly_IESA_TH-B_*_nxXGSE_vs_nxXGSExn_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1xV2_vs_V1xV2xV1/
mv ContourOnly_IESA_TH-B_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1xV2xV1_vs_V1/
;;-----------------------------------------------------
;; => Plot FGM with zoom times
;;-----------------------------------------------------
WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100
i_time  = dat_aa.TIME

sc      = probe[0]
pref    = 'th'+sc[0]+'_'
coord   = 'gse'
;fgmnm   = pref[0]+'fgl_'+['mag',coord[0]]
fgmnm   = pref[0]+'fgh_'+['mag',coord[0]]

tr_dd   = time_double(tdate[0]+'/'+['08:50:32.000','09:02:12.000'])
tr_dd   = time_double(tdate[0]+'/'+['08:57:02.000','09:02:12.000'])
tr_dd   = time_double(tdate[0]+'/'+['08:58:40.000','09:01:00.000'])
tr_dd   = time_double(tdate[0]+'/'+['08:59:00.000','09:00:20.000'])

fnm     = file_name_times(tr_dd,PREC=3)
ftpref  = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)  ; e.g. 1998-08-09_0801x09.494
;fpref   = 'FGM-fgl-GSE_TH-B_'
fpref   = 'FGM-fgh-GSE_TH-B_'
fsuff   = '_IESA-Times'
fname   = fpref[0]+ftpref[0]+fsuff[0]

  tplot,fgmnm,/NOM,TRANGE=tr_dd
  time_bar,i_time,VARNAME=fgmnm,COLOR=250L
popen,fname[0],/LAND
  tplot,fgmnm,/NOM,TRANGE=tr_dd
  time_bar,i_time,VARNAME=fgmnm,COLOR=250L
pclose
;-----------------------------------------------------
; EESA
;-----------------------------------------------------
e_time0 = dat_e.TIME
e_time1 = dat_e.END_TIME
tbow0   = time_double(tdate[0]+'/'+['08:56:00.000','09:10:00.000'])
tbow1   = time_double(tdate[0]+'/'+['09:14:00.000','09:30:00.000'])
tbow2   = time_double(tdate[0]+'/'+['09:30:00.000','09:44:00.000'])
good_e0 = WHERE(e_time0 GE tbow0[0] AND e_time1 LE tbow0[1],gde0)
good_e1 = WHERE(e_time0 GE tbow1[0] AND e_time1 LE tbow1[1],gde1)
good_e2 = WHERE(e_time0 GE tbow2[0] AND e_time1 LE tbow2[1],gde2)
PRINT,';', gde0, gde1, gde2
;         282         319         279

dat_e0  = dat_e[good_e0]
dat_e1  = dat_e[good_e1]
dat_e2  = dat_e[good_e2]

;gnorm   = [0.,1.,0.]
;normnm  = 'Y-GSE'

ngrid   = 30L
sunv    = [1.,0.,0.]
sunn    = 'Sun Dir.'
xname   = 'B!Do!N'
yname   = 'V!Dsw!N'
planes  = ['xy','xz','yz']

;vlim    = 100e3
;vlim    = 60e3
; => Put circles every 5,000 km/s
vcirc   = 5d3*[1d0,2d0,3d0,4d0];,5d0]
ns      = 3L
smc     = 1
smct    = 1
dfmin   = 1d-18
inter   = 0

j       = 72L
vlim    = 40e3
tr_ee   = tbow0
dat_0   = dat_e0[j]
gnorm   = gnorm_0
normnm  = 'Shock Normal[0]'
;vlim    = 40e3
;tr_ee   = tbow1
;dat_0   = dat_e1[j]
;gnorm   = gnorm_1
;normnm  = 'Shock Normal[1]'
;vlim    = 40e3
;tr_ee   = tbow2
;dat_0   = dat_e2[j]
;gnorm   = gnorm_2
;normnm  = 'Shock Normal[2]'
WSET,0
mode    = 'fgh'
names   = 'th'+sc[0]+'_'+[mode[0]+['_mag','_gsm'],'efw_cal_gsm','scw_gsm_L2']
  tplot,names,/NOM,TRANGE=tr_ee
  time_bar,dat_0[0].TIME,VARNAME=names,COLOR=250L
  time_bar,dat_0[0].END_TIME,VARNAME=names,COLOR= 50L

vec1    = dat_0.MAGF
vec2    = dat_0.VSW

WSET,1
WSHOW,1
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,          $
                      DFRA=dfra,VCIRC=vcirc,PLANE=planes[0],EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],      $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0]

WSET,2
WSHOW,2
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,          $
                      DFRA=dfra,VCIRC=vcirc,PLANE=planes[1],EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],      $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0]

WSET,3
WSHOW,3
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,          $
                      DFRA=dfra,VCIRC=vcirc,PLANE=planes[2],EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],      $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0]

;-----------------------------------------------------
; => Save plots
;-----------------------------------------------------
ngrid   = 30L
sunv    = [1.,0.,0.]
sunn    = 'Sun Dir.'
xname   = 'B!Do!N'
yname   = 'V!Dsw!N'
planes  = ['xy','xz','yz']

; => Put circles every 5,000 km/s
vcirc   = 5d3*[1d0,2d0,3d0,4d0];,5d0]
ns      = 3L
smc     = 1
smct    = 1
dfmin   = 1d-18
inter   = 0
vlim    = 20e3
;vlim    = 40e3

dat_aa  = dat_e0
gnorm   = gnorm_0
normnm  = 'Shock Normal[0]'
;dat_aa  = dat_e1
;gnorm   = gnorm_1
;normnm  = 'Shock Normal[1]'
;dat_aa  = dat_e2
;gnorm   = gnorm_2
;normnm  = 'Shock Normal[2]'
neesa   = N_ELEMENTS(dat_aa)
fnm     = file_name_times(dat_aa.TIME,PREC=3)
ftimes  = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494

scu     = STRUPCASE(probe[0])
df_sfxa = STRCOMPRESS(STRING(dfmin[0],FORMAT='(E10.1)'),/REMOVE_ALL)
vlim_st = STRING(vlim[0],FORMAT='(I5.5)')
xyzvecs = ['(V.B)','(BxV)xB','(BxV)']
xyzvecf = ['Bo','BoxVswxBo','BoxVsw']
planes  = ['xy','xz','yz']
xy_suff = '_'+xyzvecf[1]+'_vs_'+xyzvecf[0]
xz_suff = '_'+xyzvecf[0]+'_vs_'+xyzvecf[2]
yz_suff = '_'+xyzvecf[2]+'_vs_'+xyzvecf[1]
midstr  = '_no-interp_Cuts-DF-Above_'

pref_a  = 'EESA_TH-'+scu[0]+'_'+ftimes+'_30Grids_'+vlim_st[0]+'km-s'
fnamexy = pref_a+xy_suff[0]+midstr[0]+df_sfxa
fnamexz = pref_a+xz_suff[0]+midstr[0]+df_sfxa
fnameyz = pref_a+yz_suff[0]+midstr[0]+df_sfxa
fnames  = [[fnamexy],[fnamexz],[fnameyz]]

FOR j=0L, neesa - 1L DO BEGIN                                                    $
  dat_0   = dat_aa[j]                                                          & $
  vec1    = dat_0.MAGF                                                         & $
  vec2    = dat_0.VSW                                                          & $
  FOR k=0L, 2L DO BEGIN                                                          $
    popen,fnames[j,k],/PORT                                                    & $
      contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,       $
                        YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,               $
                        DFRA=dfra,VCIRC=vcirc,PLANE=planes[k],EX_VEC1=sunv,      $
                        EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],           $
                        SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0]      & $
    pclose

;; # Bash commands
mv EESA_TH-B_*_Bo_vs_BoxVsw_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/EESA_Burst_DF/Plane_V1_vs_V1xV2/
mv EESA_TH-B_*_BoxVsw_vs_BoxVswxBo_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/EESA_Burst_DF/Plane_V1xV2_vs_V1xV2xV1/
mv EESA_TH-B_*_BoxVswxBo_vs_Bo_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/EESA_Burst_DF/Plane_V1xV2xV1_vs_V1/





