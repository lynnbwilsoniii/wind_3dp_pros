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

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Moment Plots ['+tdate[0]+']'

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
;; => Avg. terms [1st Shock]
;;----------------------------------------------------------------------------------------
;;  Upstream
avg_magf_up  = [2.71915d0,6.94990d0,-0.754250d0]
avg_vswi_up  = [-250.544d0,37.1998d0,6.47334d0]
avg_dens_up  = 7.36031d0
avg_Ti_up    = 16.1173d0
avg_Te_up    = 9.29213d0
vshn_up      = -31.373502d0
ushn_up      = -193.82300d0
gnorm        = [0.92298712d0,0.20655033d0,-0.25200810d0]
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
;;       55.719721       3.2139767       3.0431766       2.0622194


;;  Downstream
avg_magf_dn  = [1.66317d0,11.9934d0,-17.2641d0]
avg_vswi_dn  = [-105.441d0,56.2725d0,2.44359d0]
avg_dens_dn  = 26.4995d0
avg_Ti_dn    = 80.0199d0
avg_Te_dn    = 32.5789d0
ushn_dn      = -54.939813d0
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
;;       55.719721      0.61488980      0.40976948      0.32094510       3.6003239

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
;;       412.89310       341.55345
;;      -100.08986       207.14363

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
tr_up          = time_double(tdate[0]+'/'+['19:27:54.000','19:29:00.000'])
tr_dn          = time_double(tdate[0]+'/'+['19:16:42.000','19:17:48.000'])
t_foot_se      = time_double(tdate[0]+'/'+['19:24:47.720','19:24:49.530'])
t_ramp_se      = time_double(tdate[0]+'/'+['19:24:49.530','19:24:53.440'])

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
;;         264          22          22          22          22          22
;;         264          22          22          22          22          22

;; => Interpolate to ion times
i_time         = ti_stru.X
;;  Bo
tx_magf        = interp(th_magf.Y[*,0],th_magf.X,i_time,/NO_EXTRAP)
ty_magf        = interp(th_magf.Y[*,1],th_magf.X,i_time,/NO_EXTRAP)
tz_magf        = interp(th_magf.Y[*,2],th_magf.X,i_time,/NO_EXTRAP)
tm_magf        = [[tx_magf],[ty_magf],[tz_magf]]
;;  Ti
ti_temp        = ti_stru.Y
;;  Pi
pi_temp        = interp(ti_pres.Y,ti_pres.X,i_time,/NO_EXTRAP)
;;  Ne
ne_temp        = interp(ti_dens.Y,ti_dens.X,i_time,/NO_EXTRAP)
;;  Te
te_temp        = interp(te_stru.Y,te_stru.X,i_time,/NO_EXTRAP)
;;  Vsw
vswx           = interp(ti_vsw.Y[*,0],ti_vsw.X,i_time,/NO_EXTRAP)
vswy           = interp(ti_vsw.Y[*,1],ti_vsw.X,i_time,/NO_EXTRAP)
vswz           = interp(ti_vsw.Y[*,2],ti_vsw.X,i_time,/NO_EXTRAP)

;; => Define [up,down]stream
up_magf        = FLOAT(tm_magf[good_up_Ti,*])
vswx_up        = FLOAT(vswx[good_up_Ti])
vswy_up        = FLOAT(vswy[good_up_Ti])
vswz_up        = FLOAT(vswz[good_up_Ti])
up_Ti          = FLOAT(ti_temp[good_up_Ti])
up_Te          = FLOAT(te_temp[good_up_Ti])
up_Ni          = FLOAT(ne_temp[good_up_Ti])
up_Pi          = FLOAT(pi_temp[good_up_Ti])

dn_magf        = FLOAT(tm_magf[good_dn_Ti,*])
vswx_dn        = FLOAT(vswx[good_dn_Ti])
vswy_dn        = FLOAT(vswy[good_dn_Ti])
vswz_dn        = FLOAT(vswz[good_dn_Ti])
dn_Ti          = FLOAT(ti_temp[good_dn_Ti])
dn_Te          = FLOAT(te_temp[good_dn_Ti])
dn_Ni          = FLOAT(ne_temp[good_dn_Ti])
dn_Pi          = FLOAT(pi_temp[good_dn_Ti])

PRINT,';;', up_Ni
PRINT,';;', up_Ti
PRINT,';;', up_Te
PRINT,';;', up_Pi
;;      8.31645      8.67712      7.40630      7.18448      7.50452      7.88873      8.73496      7.81069      6.83547      6.25612      6.39171      7.14978      6.90453      6.71361      6.73797      6.82553      7.05625      8.30786      8.68102      7.58535      6.46467      6.49367
;;      21.6582      21.2026      19.7488      14.1898      12.3766      14.7772      17.4932      15.2990      13.3706      13.7914      13.2749      13.4106      12.0070      11.4883      11.9794      13.4152      15.5948      16.5871      15.5264      18.7069      22.6503      26.0321
;;      9.78209      10.4590      9.57622      9.17588      9.79515      10.3753      10.8643      9.98958      9.00426      8.89945      8.89624      9.14434      9.63407      9.27669      8.86217      8.83323      8.73802      8.89814      8.67940      8.50978      8.47930      8.55423
;;      5.39490      9.07063      11.9421      16.1574      13.4360      9.21660      5.79031      10.7462      13.6695      8.56959      9.19795      11.7775      11.3017      11.4303      12.8192      9.75800      11.9298      13.4080      12.4724      9.85321      8.37616      8.60284
PRINT,';;', vswx_up
PRINT,';;', vswy_up
PRINT,';;', vswz_up
;;     -252.029     -258.557     -263.490     -265.707     -252.372     -246.680     -261.175     -266.751     -252.098     -250.555     -239.089     -240.882     -239.284     -243.914     -252.223     -245.783     -242.810     -229.544     -250.140     -252.921     -250.559     -255.403
;;      44.8791      50.9423      50.6783      33.4196      36.2620      32.5607      36.8663      62.0836      53.0972      44.8767      32.2854      26.3158      29.3843      33.1976      32.5008      29.2365      16.1495      25.8645      35.0420      30.9212      26.6607      55.1723
;;     -58.0771     -55.6894     0.409801      11.7208      3.94720      9.53158      3.67480     0.906000      2.93620      36.4344      19.9558      17.2179      17.0687      18.2569      38.9549      41.9517      16.4924      5.85340      6.98320     -8.86640      10.5687      2.18210
PRINT,';;', up_magf[*,0]
PRINT,';;', up_magf[*,1]
PRINT,';;', up_magf[*,2]
;;      4.82229      4.63308      4.02932      3.44271      2.84037      2.64673      2.63529      2.76585      2.37972      1.98794      1.39738      1.21914      1.33689      1.94864      2.09786      2.16347      2.42387      2.92340      3.28983      3.20636      2.92434      2.70674
;;      7.16286      7.74798      7.88001      7.59663      7.83664      8.10129      7.93510      7.27559      6.48152      6.14867      6.44034      7.07130      7.35861      6.74107      6.36738      6.49178      6.70230      6.52154      6.29711      5.87689      6.14621      6.71707
;;      1.35085      2.30552      2.91280      2.22750     0.579289     -1.08373     -1.94435     -2.04222     -1.49848    -0.916376     -1.01088    -0.900823     -1.04221     -1.10592     -1.35002     -1.20860     -1.80506     -2.56793     -2.99469     -2.67470     -1.31379    -0.509691


PRINT,';;', dn_Ni
PRINT,';;', dn_Ti
PRINT,';;', dn_Te
PRINT,';;', dn_Pi
;;      26.7586      28.4492      24.9637      25.1797      27.2801      27.8678      25.5643      26.0382      24.5717      26.4584      29.3981      26.9395      27.7959      26.8766      30.6361      28.4035      29.6536      25.9292      24.6204      24.9522      23.2756      21.3777
;;      100.548      93.5092      107.939      81.9885      76.8156      67.0779      76.0749      69.1720      97.6662      102.750      86.4698      63.3276      66.3187      81.6420      71.9752      77.4022      79.1747      76.6381      71.1612      59.8544      72.5566      80.3758
;;      32.2174      34.4196      32.3686      32.1424      33.4272      34.2605      33.0202      32.8837      32.4011      32.9398      32.9646      30.0516      32.1823      31.8918      33.8783      33.9563      35.0123      33.5542      32.5527      32.2373      30.2736      28.1001
;;      825.650      706.367      655.767      619.270      556.276      609.732      693.746      582.394      746.231      754.591      1001.62      538.282      525.591      686.332      804.077      624.427      714.002      650.028      703.361      595.917      522.665      565.826
PRINT,';;', vswx_dn
PRINT,';;', vswy_dn
PRINT,';;', vswz_dn
;;     -83.1450     -81.0056     -91.9657     -111.816     -107.133     -92.8042     -82.6390     -84.6774     -83.4176     -103.078     -105.546     -98.1923     -113.415     -109.037     -132.620     -144.186     -142.760     -140.735     -121.504     -92.7459     -93.1047     -104.173
;;      39.2251      58.7567      52.0019      37.2914      15.2087      15.0108      22.0988      38.6794      41.3678      41.7077      54.8207      50.9878      62.9462      83.8067      45.8108      83.3903      62.7107      78.7287      89.3931      102.433      83.8987      77.7204
;;     -24.1412     -40.6965     -45.6281     -23.1093     -27.2375     -8.86086    -0.513803      16.2152      10.7205      16.7423      19.6179      35.5084      48.0457      18.4919      19.2179      9.19438      15.0469      5.77509      10.3818      8.77417     -6.88277     -2.90311
PRINT,';;', dn_magf[*,0]
PRINT,';;', dn_magf[*,1]
PRINT,';;', dn_magf[*,2]
;;     -1.62460     -1.10121    -0.230356     0.194179    -0.862003     -1.67913     -1.81271     -1.07904     0.506501      2.62755      5.04597      5.66349      6.70031      9.36364      9.98311      7.04585      3.14220     0.725262     -1.40031     -2.52478     -2.26054     0.166255
;;      24.7313      24.1590      22.9509      20.8434      19.4439      17.9802      16.7569      15.9159      14.5874      13.1786      10.3931      7.94859      4.63129      5.20788      5.42506      5.63233      5.11448      5.30206      5.79441      6.61705      7.12949      4.11143
;;     -1.37957     -4.92033     -8.74956     -11.3075     -13.3743     -14.2631     -14.8267     -14.0848     -15.0347     -17.7298     -22.1081     -22.8915     -21.9973     -21.0468     -21.6382     -22.4402     -22.8127     -22.8008     -21.8461     -21.8455     -21.5453     -21.1676

;; => Upstream values
dens_up        = [ 8.31645,8.67712,7.40630,7.18448,7.50452,7.88873,8.73496,7.81069,6.83547,6.25612,6.39171,7.14978,6.90453,6.71361,6.73797,6.82553,7.05625,8.30786,8.68102,7.58535,6.46467,6.49367]
ti_avg_up      = [ 21.6582,21.2026,19.7488,14.1898,12.3766,14.7772,17.4932,15.2990,13.3706,13.7914,13.2749,13.4106,12.0070,11.4883,11.9794,13.4152,15.5948,16.5871,15.5264,18.7069,22.6503,26.0321]
te_avg_up      = [ 9.78209,10.4590,9.57622,9.17588,9.79515,10.3753,10.8643,9.98958,9.00426,8.89945,8.89624,9.14434,9.63407,9.27669,8.86217,8.83323,8.73802,8.89814,8.67940,8.50978,8.47930,8.55423]
Pi_up          = [ 5.39490,9.07063,11.9421,16.1574,13.4360,9.21660,5.79031,10.7462,13.6695,8.56959,9.19795,11.7775,11.3017,11.4303,12.8192,9.75800,11.9298,13.4080,12.4724,9.85321,8.37616,8.60284]
vsw_x_up       = [-252.029,-258.557,-263.490,-265.707,-252.372,-246.680,-261.175,-266.751,-252.098,-250.555,-239.089,-240.882,-239.284,-243.914,-252.223,-245.783,-242.810,-229.544,-250.140,-252.921,-250.559,-255.403]
vsw_y_up       = [ 44.8791,50.9423,50.6783,33.4196,36.2620,32.5607,36.8663,62.0836,53.0972,44.8767,32.2854,26.3158,29.3843,33.1976,32.5008,29.2365,16.1495,25.8645,35.0420,30.9212,26.6607,55.1723]
vsw_z_up       = [-58.0771,-55.6894,0.409801,11.7208,3.94720,9.53158,3.67480,0.906000,2.93620,36.4344,19.9558,17.2179,17.0687,18.2569,38.9549,41.9517,16.4924,5.85340,6.98320,-8.86640,10.5687,2.18210]
vsw_up         = [[vsw_x_up],[vsw_y_up],[vsw_z_up]]
mag_x_up       = [ 4.82229,4.63308,4.02932,3.44271,2.84037,2.64673,2.63529,2.76585,2.37972,1.98794,1.39738,1.21914,1.33689,1.94864,2.09786,2.16347,2.42387,2.92340,3.28983,3.20636,2.92434,2.70674]
mag_y_up       = [ 7.16286,7.74798,7.88001,7.59663,7.83664,8.10129,7.93510,7.27559,6.48152,6.14867,6.44034,7.07130,7.35861,6.74107,6.36738,6.49178,6.70230,6.52154,6.29711,5.87689,6.14621,6.71707]
mag_z_up       = [ 1.35085,2.30552,2.91280,2.22750,0.579289,-1.08373,-1.94435,-2.04222,-1.49848,-0.916376,-1.01088,-0.900823,-1.04221,-1.10592,-1.35002,-1.20860,-1.80506,-2.56793,-2.99469,-2.67470,-1.31379,-0.509691]
magf_up        = [[mag_x_up],[mag_y_up],[mag_z_up]]
temp_up        = te_avg_up + ti_avg_up
PRINT,';;', MEAN(dens_up,/NAN),  MEAN(ti_avg_up,/NAN),  MEAN(te_avg_up,/NAN)
PRINT,';;', MEAN(vsw_x_up,/NAN), MEAN(vsw_y_up,/NAN), MEAN(vsw_z_up,/NAN)
PRINT,';;', MEAN(mag_x_up,/NAN), MEAN(mag_y_up,/NAN), MEAN(mag_z_up,/NAN)
;;      7.36031      16.1173      9.29213
;;     -250.544      37.1998      6.47334
;;      2.71915      6.94990    -0.754250


;; => Downstream values
dens_dn        = [ 26.7586,28.4492,24.9637,25.1797,27.2801,27.8678,25.5643,26.0382,24.5717,26.4584,29.3981,26.9395,27.7959,26.8766,30.6361,28.4035,29.6536,25.9292,24.6204,24.9522,23.2756,21.3777]
ti_avg_dn      = [ 100.548,93.5092,107.939,81.9885,76.8156,67.0779,76.0749,69.1720,97.6662,102.750,86.4698,63.3276,66.3187,81.6420,71.9752,77.4022,79.1747,76.6381,71.1612,59.8544,72.5566,80.3758]
te_avg_dn      = [ 32.2174,34.4196,32.3686,32.1424,33.4272,34.2605,33.0202,32.8837,32.4011,32.9398,32.9646,30.0516,32.1823,31.8918,33.8783,33.9563,35.0123,33.5542,32.5527,32.2373,30.2736,28.1001]
Pi_dn          = [ 825.650,706.367,655.767,619.270,556.276,609.732,693.746,582.394,746.231,754.591,1001.62,538.282,525.591,686.332,804.077,624.427,714.002,650.028,703.361,595.917,522.665,565.826]
vsw_x_dn       = [-83.1450,-81.0056,-91.9657,-111.816,-107.133,-92.8042,-82.6390,-84.6774,-83.4176,-103.078,-105.546,-98.1923,-113.415,-109.037,-132.620,-144.186,-142.760,-140.735,-121.504,-92.7459,-93.1047,-104.173]
vsw_y_dn       = [ 39.2251,58.7567,52.0019,37.2914,15.2087,15.0108,22.0988,38.6794,41.3678,41.7077,54.8207,50.9878,62.9462,83.8067,45.8108,83.3903,62.7107,78.7287,89.3931,102.433,83.8987,77.7204]
vsw_z_dn       = [-24.1412,-40.6965,-45.6281,-23.1093,-27.2375,-8.86086,-0.513803,16.2152,10.7205,16.7423,19.6179,35.5084,48.0457,18.4919,19.2179,9.19438,15.0469,5.77509,10.3818,8.77417,-6.88277,-2.90311]
vsw_dn         = [[vsw_x_dn],[vsw_y_dn],[vsw_z_dn]]
mag_x_dn       = [-1.62460,-1.10121,-0.230356,0.194179,-0.862003,-1.67913,-1.81271,-1.07904,0.506501,2.62755,5.04597,5.66349,6.70031,9.36364,9.98311,7.04585,3.14220,0.725262,-1.40031,-2.52478,-2.26054,0.166255]
mag_y_dn       = [ 24.7313,24.1590,22.9509,20.8434,19.4439,17.9802,16.7569,15.9159,14.5874,13.1786,10.3931,7.94859,4.63129,5.20788,5.42506,5.63233,5.11448,5.30206,5.79441,6.61705,7.12949,4.11143]
mag_z_dn       = [-1.37957,-4.92033,-8.74956,-11.3075,-13.3743,-14.2631,-14.8267,-14.0848,-15.0347,-17.7298,-22.1081,-22.8915,-21.9973,-21.0468,-21.6382,-22.4402,-22.8127,-22.8008,-21.8461,-21.8455,-21.5453,-21.1676]
magf_dn        = [[mag_x_dn],[mag_y_dn],[mag_z_dn]]
temp_dn        = te_avg_dn + ti_avg_dn
PRINT,';;', MEAN(dens_dn,/NAN),  MEAN(ti_avg_dn,/NAN),  MEAN(te_avg_dn,/NAN)
PRINT,';;', MEAN(vsw_x_dn,/NAN), MEAN(vsw_y_dn,/NAN), MEAN(vsw_z_dn,/NAN)
PRINT,';;', MEAN(mag_x_dn,/NAN), MEAN(mag_y_dn,/NAN), MEAN(mag_z_dn,/NAN)
;;      26.4995      80.0199      32.5789
;;     -105.441      56.2725      2.44359
;;      1.66317      11.9934     -17.2641

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
;;  => Equations 2, 3, 4, and 5 for 2009-07-21 bow shock
;;===========================================================
;;      -16.103864       7.9157134
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-21 bow shock
;;===========================================================
;;      -14.781375       8.8499187
;;-----------------------------------------------------------

;; => Print out best fit azimuthal angles
PRINT,';', soln.PHI*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-21 bow shock
;;===========================================================
;;       11.671123       7.8002795
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-21 bow shock
;;===========================================================
;;       12.619809       8.1797025
;;-----------------------------------------------------------

;; => Print out best fit shock normal speed in spacecraft frame [km/s]
PRINT,';', soln.VSHN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-21 bow shock
;;===========================================================
;;      -32.431603       34.415424
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-21 bow shock
;;===========================================================
;;      -31.373502       34.182527
;;-----------------------------------------------------------

;; => Print out best fit upstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_UP
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-21 bow shock
;;===========================================================
;;      -193.61778       37.568015
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-21 bow shock
;;===========================================================
;;      -193.82300       37.862402
;;-----------------------------------------------------------

;; => Print out best fit downstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_DN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-21 bow shock
;;===========================================================
;;      -54.879184       15.509541
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-21 bow shock
;;===========================================================
;;      -54.939813       15.591312
;;-----------------------------------------------------------

;; => Print out best fit shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,0]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-21 bow shock
;;===========================================================
;;      0.92344720      0.19067247     -0.27470998
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-21 bow shock
;;===========================================================
;;      0.92298712      0.20655033     -0.25200810
;;-----------------------------------------------------------

;; => Print out best fit uncertainty in shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,1]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-21 bow shock
;;===========================================================
;;     0.048249890      0.12579350      0.13142445
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-21 bow shock
;;===========================================================
;;     0.052442476      0.13195176      0.14752184
;;-----------------------------------------------------------


















































































;;----------------------------------------------------------------------------------------
;; => Save moments
;;----------------------------------------------------------------------------------------
probe          = 'c'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]
tplot_save,FILENAME=fname[0]











vbulk_old      = TRANSPOSE(dat_igse.VSW)  ;;  Level-2 Moment Estimates [km/s, GSE]
vbulk_new      = REPLICATE(d,n_i,3L)      ;;  New bulk flow velocities = V_new [km/s, GSE]
FOR j=0L, n_i - 1L DO BEGIN                     $
  dat0 = dat_igse[j]                          & $
  one  = dat0[0]                              & $
  one.DATA = 1.0                              & $
  transform_vframe_3d,dat0,/EASY_TRAN         & $
  transform_vframe_3d,one,/EASY_TRAN          & $
  diff = dat0.DATA - onedf.DATA               & $
  bad  = WHERE(diff LE 0,bd)                  & $
  IF (bd GT 0) THEN dat0.DATA[bad] = f        & $
  vstr = fix_vbulk_ions(dat0,DFMAX=2d-6)      & $
  vnew = vstr.VSW_NEW                         & $
  vbulk_new[j,*] = vnew

