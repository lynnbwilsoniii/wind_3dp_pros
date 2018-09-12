;;----------------------------------------------------------------------------------------
;;  Status Bar Legend
;;
;;    yellow       :  slow survey
;;    red          :  fast survey
;;    black below  :  particle burst
;;    black above  :  wave burst
;;
;;----------------------------------------------------------------------------------------

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
;;----------------------------------------------------------------------------------------
;; => Date/Time and Probe
;;----------------------------------------------------------------------------------------
probe          = 'c'
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
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
scpref         = 'th'+sc[0]+'_'
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
coord_gse      = 'gse'
peib_tn        = 'peib_'
peeb_tn        = 'peeb_'

coord          = 'gse'
fglnm          = pref[0]+'fgl_'+coord_gse[0]
sm_fgmnm       = fglnm[0]+suffx[0]
velnm0         = pref[0]+'Velocity_'+coord_gse[0]+'_'+peib_tn[0]+'no_GIs_UV'
vsw_name       = tnames(velnm0[0])
den_name       = tnames(pref[0]+'N_'+peib_tn[0]+'no_GIs_UV')
Ti__name       = tnames(pref[0]+'T_avg_'+peib_tn[0]+'no_GIs_UV')
Te__name       = tnames(pref[0]+peeb_tn[0]+'avgtemp')
Pi__name       = tnames(pref[0]+'Pressure_'+coord_gse[0]+'_'+peib_tn[0]+'no_GIs_UV')
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


all_params     = [den_name[0],Ti__name[0],Te__name[0],vsw_name[0],Pi__name[0]]
options,all_params,'YTICKLEN'
options,all_params,'YTICKLEN',/DEF
options,all_params,'YGRIDSTYLE'
options,all_params,'YGRIDSTYLE',/DEF
options,all_params,'YTICKLEN',1.0,/DEF       ;;  use full-length tick marks
options,all_params,'YGRIDSTYLE',1,/DEF       ;;  use dotted lines
;;----------------------------------------------------------------------------------------
;; => Avg. terms [1st Shock]
;;----------------------------------------------------------------------------------------
t_foot_se      = time_double(tdate[0]+'/'+['16:11:33.800','16:12:11.660'])
t_ramp_se      = time_double(tdate[0]+'/'+['16:11:32.910','16:11:33.800'])
tr_up          = time_double(tdate[0]+'/'+['16:15:00.000','16:15:34.000'])
tr_dn          = time_double(tdate[0]+'/'+['16:10:54.900','16:11:28.900'])

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

FOR j=0L, 1L DO BEGIN $
  IF (j EQ 0) THEN PRINT,';;', gdupBo, gdupNi, gdupTi, gdupTe, gdupVi, gdupPi  & $
  IF (j EQ 1) THEN PRINT,';;', gddnBo, gddnNi, gddnTi, gddnTe, gddnVi, gddnPi
;;         136          11          11          11          11          11
;;         136          11          11          11          11          11


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
;;      2.74746      2.63503      2.55310      2.62704      2.41764      2.65645      2.69625      2.64081      2.71218      2.53692      2.54303
;;      8.55088      8.26501      8.00998      8.03532      8.44388      8.06652      8.27741      8.06267      8.11074      8.00202      8.20389
;;      12.4194      12.3775      13.6209      14.1289      14.4666      13.8679      13.4698      13.3386      13.5273      14.0566      14.7478
;;      10.2027      9.29157      8.25524      8.52344      8.59256      8.78458      9.29564      8.45274      9.11019      7.96194      8.35954

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vswx_up       & $
  IF (j EQ 1) THEN PRINT,';;', vswy_up       & $
  IF (j EQ 2) THEN PRINT,';;', vswz_up
;;     -376.532     -376.351     -376.841     -377.419     -378.033     -379.007     -378.893     -379.876     -379.686     -380.867     -383.603
;;      7.83977      7.28592      7.92277      7.26878      6.78583      5.47892      5.36511      4.96828      2.82403      4.13422      1.53799
;;     -5.20361     -4.42141     -4.43812     -5.14862     -6.54401     -6.39428     -8.92870     -7.01621     -6.75324     -9.15813     -10.7691

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', up_magf[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', up_magf[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', up_magf[*,2]
;;     0.581560     0.626457     0.596671     0.533517     0.554378     0.602951     0.585140     0.563207     0.563418     0.579196     0.629615
;;    -0.610748    -0.617448    -0.623948    -0.643724    -0.600628    -0.587427    -0.611435    -0.625434    -0.598062    -0.546986    -0.570952
;;    -0.409161    -0.458181    -0.421239    -0.289744    -0.255391    -0.280506    -0.321329    -0.373138    -0.431198    -0.409244    -0.325292

FOR j=0L, 3L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dn_Ni         & $
  IF (j EQ 1) THEN PRINT,';;', dn_Ti         & $
  IF (j EQ 2) THEN PRINT,';;', dn_Te         & $
  IF (j EQ 3) THEN PRINT,';;', dn_Pi
;;      3.01548      1.91662      2.18725      2.34226      2.47510      1.90352      2.74389      2.34493      13.2462      20.1632      20.6019
;;      262.334      422.596      367.398      422.843      429.037      464.810      414.681      387.317      71.9713      53.3489      65.3654
;;      71.8956      77.7809      83.6006      95.3711      100.746      111.350      93.3520      92.3883      42.4176      40.9043      37.5340
;;      302.171      304.073      301.200      324.413      253.258      224.494      277.035      138.945      389.750      603.928      631.438

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vswx_dn       & $
  IF (j EQ 1) THEN PRINT,';;', vswy_dn       & $
  IF (j EQ 2) THEN PRINT,';;', vswz_dn
;;     -95.9943     -113.784     -91.9186     -151.280     -244.676     -150.070     -107.657     -251.243     -156.409     -163.921     -175.175
;;     -140.235     -78.7697     -60.7398      36.3733     -30.1494     -70.5216     -20.6711      65.2090      103.075      79.2468      88.6847
;;     -38.5277     -29.4858     -55.9028     -31.6574     -7.13810     -40.1682     -64.8422      2.13400      61.7436     -7.60060      31.9321

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dn_magf[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', dn_magf[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', dn_magf[*,2]
;;     -2.85274     -1.80860    -0.819308    -0.438840    0.0107723     0.933281      2.01882      2.92823      3.13606      3.00192      2.98169
;;     -4.20480     -1.80470     0.215825     0.115694     -4.23300     -7.93249     -5.15349     -3.72875     -6.94817     -9.70987     -8.03452
;;     0.339288      1.58918     0.896786    -0.547763     -4.68333     -8.93511     -1.51705      8.07026      9.82553      1.71186     -1.76504

;; => Upstream values
dens_up        = [  2.74746,  2.63503,  2.55310,  2.62704,  2.41764,  2.65645,  2.69625,  2.64081,  2.71218,  2.53692,  2.54303]
ti_avg_up      = [  8.55088,  8.26501,  8.00998,  8.03532,  8.44388,  8.06652,  8.27741,  8.06267,  8.11074,  8.00202,  8.20389]
te_avg_up      = [  12.4194,  12.3775,  13.6209,  14.1289,  14.4666,  13.8679,  13.4698,  13.3386,  13.5273,  14.0566,  14.7478]
Pi_up          = [  10.2027,  9.29157,  8.25524,  8.52344,  8.59256,  8.78458,  9.29564,  8.45274,  9.11019,  7.96194,  8.35954]
vsw_x_up       = [ -376.532, -376.351, -376.841, -377.419, -378.033, -379.007, -378.893, -379.876, -379.686, -380.867, -383.603]
vsw_y_up       = [  7.83977,  7.28592,  7.92277,  7.26878,  6.78583,  5.47892,  5.36511,  4.96828,  2.82403,  4.13422,  1.53799]
vsw_z_up       = [ -5.20361, -4.42141, -4.43812, -5.14862, -6.54401, -6.39428, -8.92870, -7.01621, -6.75324, -9.15813, -10.7691]
mag_x_up       = [ 0.581560, 0.626457, 0.596671, 0.533517, 0.554378, 0.602951, 0.585140, 0.563207, 0.563418, 0.579196, 0.629615]
mag_y_up       = [-0.610748,-0.617448,-0.623948,-0.643724,-0.600628,-0.587427,-0.611435,-0.625434,-0.598062,-0.546986,-0.570952]
mag_z_up       = [-0.409161,-0.458181,-0.421239,-0.289744,-0.255391,-0.280506,-0.321329,-0.373138,-0.431198,-0.409244,-0.325292]
vsw_up         = [[vsw_x_up],[vsw_y_up],[vsw_z_up]]
magf_up        = [[mag_x_up],[mag_y_up],[mag_z_up]]
temp_up        = te_avg_up + ti_avg_up
FOR j=0L, 2L DO BEGIN                                                                             $
  IF (j EQ 0) THEN PRINT,';;', MEAN(dens_up,/NAN),  MEAN(ti_avg_up,/NAN), MEAN(te_avg_up,/NAN)  & $
  IF (j EQ 1) THEN PRINT,';;', MEAN(vsw_x_up,/NAN), MEAN(vsw_y_up,/NAN),  MEAN(vsw_z_up,/NAN)   & $
  IF (j EQ 2) THEN PRINT,';;', MEAN(mag_x_up,/NAN), MEAN(mag_y_up,/NAN),  MEAN(mag_z_up,/NAN)
;;      2.61508      8.18439      13.6383
;;     -378.828      5.58287     -6.79777
;;     0.583283    -0.603345    -0.361311


;; => Downstream values
;;    ->  The downstream density drops quickly because the region becomes rarified...
;;      ->  Take the last 2 values for each parameter only
;;      ->  Find the mean and standard deviation
;;      ->  Produce a random distribution of points about mean with FWHM = standard deviation
nn_up          = N_ELEMENTS(dens_up)
ind0           = nn_up[0] - 3L
ind1           = nn_up[0] - 1L
rand           = RANDOMU(seed,nn_up[0],/DOUBLE)
rand          -= MEAN(rand,/NAN)           ;;  center uniform distribution on zero
rand           = rand/MAX(ABS(rand),/NAN)  ;;  normalize uniform distribution

dens_dn_0      = [  3.01548,  1.91662,  2.18725,  2.34226,  2.47510,  1.90352,  2.74389,  2.34493,  13.2462,  20.1632,  20.6019]
ti_avg_dn_0    = [  262.334,  422.596,  367.398,  422.843,  429.037,  464.810,  414.681,  387.317,  71.9713,  53.3489,  65.3654]
te_avg_dn_0    = [  71.8956,  77.7809,  83.6006,  95.3711,  100.746,  111.350,  93.3520,  92.3883,  42.4176,  40.9043,  37.5340]
Pi_dn_0        = [  302.171,  304.073,  301.200,  324.413,  253.258,  224.494,  277.035,  138.945,  389.750,  603.928,  631.438]
vsw_x_dn_0     = [ -95.9943, -113.784, -91.9186, -151.280, -244.676, -150.070, -107.657, -251.243, -156.409, -163.921, -175.175]
vsw_y_dn_0     = [ -140.235, -78.7697, -60.7398,  36.3733, -30.1494, -70.5216, -20.6711,  65.2090,  103.075,  79.2468,  88.6847]
vsw_z_dn_0     = [ -38.5277, -29.4858, -55.9028, -31.6574, -7.13810, -40.1682, -64.8422,  2.13400,  61.7436, -7.60060,  31.9321]
mag_x_dn_0     = [ -2.85274, -1.80860,-0.819308,-0.438840,0.0107723, 0.933281,  2.01882,  2.92823,  3.13606,  3.00192,  2.98169]
mag_y_dn_0     = [ -4.20480, -1.80470, 0.215825, 0.115694, -4.23300, -7.93249, -5.15349, -3.72875, -6.94817, -9.70987, -8.03452]
mag_z_dn_0     = [ 0.339288,  1.58918, 0.896786,-0.547763, -4.68333, -8.93511, -1.51705,  8.07026,  9.82553,  1.71186, -1.76504]

x              =   MEAN(dens_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(dens_dn_0[ind0[0]:ind1[0]],/NAN)
dens_dn        = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(ti_avg_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(ti_avg_dn_0[ind0[0]:ind1[0]],/NAN)
ti_avg_dn      = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(te_avg_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(te_avg_dn_0[ind0[0]:ind1[0]],/NAN)
te_avg_dn      = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(Pi_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(Pi_dn_0[ind0[0]:ind1[0]],/NAN)
Pi_dn          = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(vsw_x_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(vsw_x_dn_0[ind0[0]:ind1[0]],/NAN)
vsw_x_dn       = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(vsw_y_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(vsw_y_dn_0[ind0[0]:ind1[0]],/NAN)
vsw_y_dn       = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(vsw_z_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(vsw_z_dn_0[ind0[0]:ind1[0]],/NAN)
vsw_z_dn       = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(mag_x_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(mag_x_dn_0[ind0[0]:ind1[0]],/NAN)
mag_x_dn       = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(mag_y_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(mag_y_dn_0[ind0[0]:ind1[0]],/NAN)
mag_y_dn       = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(mag_z_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(mag_z_dn_0[ind0[0]:ind1[0]],/NAN)
mag_z_dn       = FLOAT(rand*dx[0] + x[0])
vsw_dn         = [[vsw_x_dn],[vsw_y_dn],[vsw_z_dn]]
magf_dn        = [[mag_x_dn],[mag_y_dn],[mag_z_dn]]
temp_dn        = te_avg_dn + ti_avg_dn

FOR j=0L, 3L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dens_dn         & $
  IF (j EQ 1) THEN PRINT,';;', ti_avg_dn       & $
  IF (j EQ 2) THEN PRINT,';;', te_avg_dn       & $
  IF (j EQ 3) THEN PRINT,';;', Pi_dn
;;      20.6764      13.8778      19.2052      17.1787      17.3164      19.7631      14.6443      18.0413      19.5861      20.9819      16.7703
;;      69.6775      54.1206      66.3111      61.6740      61.9890      67.5876      55.8746      63.6476      67.1827      70.3766      60.7393
;;      41.9047      37.7853      41.0133      39.7854      39.8688      41.3513      38.2498      40.3080      41.2440      42.0898      39.5379
;;      627.412      409.391      580.234      515.248      519.663      598.123      433.972      542.907      592.449      637.210      502.149

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vsw_dn[*,0]   & $
  IF (j EQ 1) THEN PRINT,';;', vsw_dn[*,1]   & $
  IF (j EQ 2) THEN PRINT,';;', vsw_dn[*,2]
;;     -159.050     -174.613     -162.418     -167.057     -166.742     -161.141     -172.859     -165.083     -161.546     -158.351     -167.992
;;      98.1083      78.3359      93.8297      87.9361      88.3364      95.4520      80.5652      90.4445      94.9374      98.9968      86.7481
;;      51.2241     -6.09378      38.8210      21.7360      22.8966      43.5240     0.368590      29.0077      42.0322      53.7999      18.2923

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', magf_dn[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', magf_dn[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', magf_dn[*,2]
;;      3.09424      2.95599      3.06432      3.02311      3.02591      3.07566      2.97158      3.04065      3.07207      3.10045      3.01481
;;     -7.32965     -9.62213     -7.82572     -8.50906     -8.46263     -7.63762     -9.36366     -8.21821     -7.69729     -7.22663     -8.64679
;;      7.11020     -2.69040      4.98943      2.06811      2.26657      5.79358     -1.58542      3.31149      5.53849      7.55061      1.47930

FOR j=0L, 2L DO BEGIN                                                                             $
  IF (j EQ 0) THEN PRINT,';;', MEAN(dens_dn,/NAN),  MEAN(ti_avg_dn,/NAN), MEAN(te_avg_dn,/NAN)  & $
  IF (j EQ 1) THEN PRINT,';;', MEAN(vsw_x_dn,/NAN), MEAN(vsw_y_dn,/NAN),  MEAN(vsw_z_dn,/NAN)   & $
  IF (j EQ 2) THEN PRINT,';;', MEAN(mag_x_dn,/NAN), MEAN(mag_y_dn,/NAN),  MEAN(mag_z_dn,/NAN)
;;      18.0038      63.5619      40.2853
;;     -165.168      90.3355      28.6917
;;      3.03989     -8.23085      3.25745

;; => combine terms
vsw      = [[[vsw_up]],[[vsw_dn]]]
mag      = [[[magf_up]],[[magf_dn]]]
dens     = [[dens_up],[dens_dn]]
temp     = [[temp_up],[temp_dn]]
nmax     = 150L

.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/rh_pros/temp_rh_soln_print.pro
temp_rh_soln_print,dens,vsw,mag,temp,tdate[0],NMAX=nmax
;; => Print out best fit poloidal angles
PRINT,';', soln.THETA*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -65.763630       6.9803071
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;       3.5570470       4.7218951
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -59.943335       5.5388591
;;-----------------------------------------------------------

;; => Print out best fit azimuthal angles
PRINT,';', soln.PHI*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -100.20805       14.665353
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;       21.744966       0.0000000
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -45.283710       8.5636687
;;-----------------------------------------------------------

;; => Print out best fit shock normal speed in spacecraft frame [km/s]
PRINT,';', soln.VSHN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -62.842189       21.621565
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -77.654715       5.2538123
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -110.79199       20.359826
;;-----------------------------------------------------------

;; => Print out best fit upstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_UP
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;       93.298052       50.586963
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -270.84172       7.3626369
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -16.681495       39.636023
;;-----------------------------------------------------------

;; => Print out best fit downstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_DN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;       13.356849       6.9627628
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -39.924032       5.1344510
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -2.8590127       6.1985699
;;-----------------------------------------------------------

;; => Print out best fit shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,0]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;    -0.069873021     -0.38808090     -0.90509340
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      0.92425461      0.36864608     0.061934850
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      0.34679005     -0.35039751     -0.86153612
;;-----------------------------------------------------------

;; => Print out best fit uncertainty in shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,1]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      0.10595902      0.10811344     0.049001326
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;    0.0037427374    0.0014928197     0.077952387
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;     0.077268649     0.079449041     0.049312384
;;-----------------------------------------------------------

;;----------------------------------------------------------------------------------------
;; => Avg. terms [2nd Shock]
;;----------------------------------------------------------------------------------------
t_foot_se      = time_double(tdate[0]+'/'+['16:37:59.000','16:38:11.680'])
t_ramp_se      = time_double(tdate[0]+'/'+['16:37:58.272','16:37:59.000'])
tr_up          = time_double(tdate[0]+'/'+['16:39:50.000','16:40:36.000'])
tr_dn          = time_double(tdate[0]+'/'+['16:36:42.300','16:37:28.300'])

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

FOR j=0L, 1L DO BEGIN $
  IF (j EQ 0) THEN PRINT,';;', gdupBo, gdupNi, gdupTi, gdupTe, gdupVi, gdupPi  & $
  IF (j EQ 1) THEN PRINT,';;', gddnBo, gddnNi, gddnTi, gddnTe, gddnVi, gddnPi
;;         184          15          15          15          15          15
;;         184          15          15          15          15          15


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
;;      2.41680      2.33711      2.28506      2.69454      2.57237      2.59554      2.69309      2.93287      2.90507      2.71176      2.80963      2.79942      2.76790      2.74086      2.56405
;;      7.18576      7.42668      8.26502      7.35056      7.52570      7.28650      7.58460      7.48067      7.29504      7.41274      7.10406      7.38095      7.54963      7.40327      7.71353
;;      11.7326      11.8892      11.7679      12.2160      11.7759      11.9491      12.3500      12.2282      12.1168      11.8524      11.8470      11.7851      11.8309      11.3721      11.5521
;;      7.21368      7.64096     -11.4126      8.47828      8.33371      8.27231      8.79638      9.27374      9.06692      8.35535      8.55427      8.72345      8.69541      8.63015      8.39438

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vswx_up       & $
  IF (j EQ 1) THEN PRINT,';;', vswy_up       & $
  IF (j EQ 2) THEN PRINT,';;', vswz_up
;;     -356.795     -357.176     -356.916     -357.489     -355.988     -357.661     -356.937     -355.823     -355.147     -354.330     -352.694     -352.698     -356.639     -359.508     -362.632
;;     -31.4805     -31.7308     -30.8405     -33.5436     -32.6277     -30.8732     -29.0625     -30.2978     -32.1150     -33.0122     -32.4370     -33.0736     -31.8437     -31.5566     -29.0890
;;     -1.06336    -0.187475     -5.35450    -0.269654    -0.463820     -2.20128     -4.39498     -5.26573     -4.93198     -4.92957     -2.77715     -2.58695     -3.36132     -5.08675     -3.76593

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', up_magf[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', up_magf[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', up_magf[*,2]
;;     -1.06577     -1.02176     -1.05629     -1.10475     -1.12593     -1.10459     -1.14104     -1.18678     -1.21341     -1.18560     -1.14616     -1.13801     -1.12912     -1.11550     -1.12571
;;     -1.05238     -1.05730     -1.07723     -1.11538     -1.15707     -1.19804     -1.26178     -1.27550     -1.23978     -1.22951     -1.24766     -1.22759     -1.13551     -1.04886    -0.996385
;;    -0.203917    -0.187356    -0.224741    -0.257725    -0.268637    -0.301127    -0.325656    -0.322157    -0.308030    -0.319787    -0.334994    -0.315391    -0.296204    -0.252904    -0.269212

FOR j=0L, 3L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dn_Ni         & $
  IF (j EQ 1) THEN PRINT,';;', dn_Ti         & $
  IF (j EQ 2) THEN PRINT,';;', dn_Te         & $
  IF (j EQ 3) THEN PRINT,';;', dn_Pi
;;      18.9104      17.4221      15.7777      15.6550      16.6943      15.3561      14.4375      11.5364      12.9160      12.1205      12.0481      10.8075      10.7518      10.7467      17.2551
;;      104.632      105.751      116.829      129.735      132.024      144.523      112.901      108.509      91.7284      226.105      228.889      161.735      213.037      218.863      129.648
;;      37.8961      34.7533      33.9469      33.3598      33.0932      32.4692      31.7004      30.9698      32.4217      30.1276      30.8085      29.5674      27.4959      21.1753      22.6212
;;      614.879      415.825      274.993      486.843      444.467      409.247     -64.8569     -194.439     -90.2236      921.672      321.594      52.6520     -35.5406      716.679     -71.7001

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vswx_dn       & $
  IF (j EQ 1) THEN PRINT,';;', vswy_dn       & $
  IF (j EQ 2) THEN PRINT,';;', vswz_dn
;;     -165.204     -177.427     -157.656     -139.189     -141.996     -152.801     -224.923     -236.598     -264.847     -62.6322     -218.430     -291.611     -277.808     -234.325     -239.128
;;     -59.5039     -54.9828     -2.38950      13.1538     -13.4783      24.3639     -33.5592     -37.3236      112.998      25.6323     -15.3897      173.905      153.083      152.628    0.0406952
;;     -35.6094     -48.1784     -102.228     -76.6434     -56.2187     -66.7559     -51.7882     -93.7207     -102.876     -138.908     -92.6592     -52.2114      39.8396      23.2562     -58.9858

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dn_magf[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', dn_magf[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', dn_magf[*,2]
;;      1.50075     0.797319     0.229909     -1.44897     -1.34320    -0.962902     0.491040     0.461603     0.909222      1.07533     0.630802    -0.682124     -1.59057     -4.59684     -6.50032
;;     -7.49737     -5.58607     -3.90963     -3.63151     -3.74433     -4.60586     -4.39175     -3.63471     -3.33878     -3.14789     -2.42387     -1.35185      2.42033      3.39992      2.43781
;;     -5.20000     -6.92506     -8.65677     -8.43091     -6.72798     -4.60876     -5.22373     -4.31523     -4.89760     -4.41792     -2.73370     -2.98194     -2.57512     -2.58642     -2.75193

;; => Upstream values
dens_up        = [  2.41680,  2.33711,  2.28506,  2.69454,  2.57237,  2.59554,  2.69309,  2.93287,  2.90507,  2.71176,  2.80963,  2.79942,  2.76790,  2.74086,  2.56405]
ti_avg_up      = [  7.18576,  7.42668,  8.26502,  7.35056,  7.52570,  7.28650,  7.58460,  7.48067,  7.29504,  7.41274,  7.10406,  7.38095,  7.54963,  7.40327,  7.71353]
te_avg_up      = [  11.7326,  11.8892,  11.7679,  12.2160,  11.7759,  11.9491,  12.3500,  12.2282,  12.1168,  11.8524,  11.8470,  11.7851,  11.8309,  11.3721,  11.5521]
Pi_up          = [  7.21368,  7.64096, -11.4126,  8.47828,  8.33371,  8.27231,  8.79638,  9.27374,  9.06692,  8.35535,  8.55427,  8.72345,  8.69541,  8.63015,  8.39438]
vsw_x_up       = [ -356.795, -357.176, -356.916, -357.489, -355.988, -357.661, -356.937, -355.823, -355.147, -354.330, -352.694, -352.698, -356.639, -359.508, -362.632]
vsw_y_up       = [ -31.4805, -31.7308, -30.8405, -33.5436, -32.6277, -30.8732, -29.0625, -30.2978, -32.1150, -33.0122, -32.4370, -33.0736, -31.8437, -31.5566, -29.0890]
vsw_z_up       = [ -1.06336,-0.187475, -5.35450,-0.269654,-0.463820, -2.20128, -4.39498, -5.26573, -4.93198, -4.92957, -2.77715, -2.58695, -3.36132, -5.08675, -3.76593]
mag_x_up       = [ -1.06577, -1.02176, -1.05629, -1.10475, -1.12593, -1.10459, -1.14104, -1.18678, -1.21341, -1.18560, -1.14616, -1.13801, -1.12912, -1.11550, -1.12571]
mag_y_up       = [ -1.05238, -1.05730, -1.07723, -1.11538, -1.15707, -1.19804, -1.26178, -1.27550, -1.23978, -1.22951, -1.24766, -1.22759, -1.13551, -1.04886,-0.996385]
mag_z_up       = [-0.203917,-0.187356,-0.224741,-0.257725,-0.268637,-0.301127,-0.325656,-0.322157,-0.308030,-0.319787,-0.334994,-0.315391,-0.296204,-0.252904,-0.269212]
vsw_up         = [[vsw_x_up],[vsw_y_up],[vsw_z_up]]
magf_up        = [[mag_x_up],[mag_y_up],[mag_z_up]]
temp_up        = te_avg_up + ti_avg_up
FOR j=0L, 2L DO BEGIN                                                                             $
  IF (j EQ 0) THEN PRINT,';;', MEAN(dens_up,/NAN),  MEAN(ti_avg_up,/NAN), MEAN(te_avg_up,/NAN)  & $
  IF (j EQ 1) THEN PRINT,';;', MEAN(vsw_x_up,/NAN), MEAN(vsw_y_up,/NAN),  MEAN(vsw_z_up,/NAN)   & $
  IF (j EQ 2) THEN PRINT,';;', MEAN(mag_x_up,/NAN), MEAN(mag_y_up,/NAN),  MEAN(mag_z_up,/NAN)
;;      2.65507      7.46431      11.8844
;;     -356.562     -31.5722     -3.10936
;;     -1.12403     -1.15466    -0.279189


;; => Downstream values
dens_dn        = [  18.9104,  17.4221,  15.7777,  15.6550,  16.6943,  15.3561,  14.4375,  11.5364,  12.9160,  12.1205,  12.0481,  10.8075,  10.7518,  10.7467,  17.2551]
ti_avg_dn      = [  104.632,  105.751,  116.829,  129.735,  132.024,  144.523,  112.901,  108.509,  91.7284,  226.105,  228.889,  161.735,  213.037,  218.863,  129.648]
te_avg_dn      = [  37.8961,  34.7533,  33.9469,  33.3598,  33.0932,  32.4692,  31.7004,  30.9698,  32.4217,  30.1276,  30.8085,  29.5674,  27.4959,  21.1753,  22.6212]
Pi_dn          = [  614.879,  415.825,  274.993,  486.843,  444.467,  409.247, -64.8569, -194.439, -90.2236,  921.672,  321.594,  52.6520, -35.5406,  716.679, -71.7001]
vsw_x_dn       = [ -165.204, -177.427, -157.656, -139.189, -141.996, -152.801, -224.923, -236.598, -264.847, -62.6322, -218.430, -291.611, -277.808, -234.325, -239.128]
vsw_y_dn       = [ -59.5039, -54.9828, -2.38950,  13.1538, -13.4783,  24.3639, -33.5592, -37.3236,  112.998,  25.6323, -15.3897,  173.905,  153.083,  152.628,0.0406952]
vsw_z_dn       = [ -35.6094, -48.1784, -102.228, -76.6434, -56.2187, -66.7559, -51.7882, -93.7207, -102.876, -138.908, -92.6592, -52.2114,  39.8396,  23.2562, -58.9858]
mag_x_dn       = [  1.50075, 0.797319, 0.229909, -1.44897, -1.34320,-0.962902, 0.491040, 0.461603, 0.909222,  1.07533, 0.630802,-0.682124, -1.59057, -4.59684, -6.50032]
mag_y_dn       = [ -7.49737, -5.58607, -3.90963, -3.63151, -3.74433, -4.60586, -4.39175, -3.63471, -3.33878, -3.14789, -2.42387, -1.35185,  2.42033,  3.39992,  2.43781]
mag_z_dn       = [ -5.20000, -6.92506, -8.65677, -8.43091, -6.72798, -4.60876, -5.22373, -4.31523, -4.89760, -4.41792, -2.73370, -2.98194, -2.57512, -2.58642, -2.75193]
vsw_dn         = [[vsw_x_dn],[vsw_y_dn],[vsw_z_dn]]
magf_dn        = [[mag_x_dn],[mag_y_dn],[mag_z_dn]]
temp_dn        = te_avg_dn + ti_avg_dn
FOR j=0L, 2L DO BEGIN                                                                             $
  IF (j EQ 0) THEN PRINT,';;', MEAN(dens_dn,/NAN),  MEAN(ti_avg_dn,/NAN), MEAN(te_avg_dn,/NAN)  & $
  IF (j EQ 1) THEN PRINT,';;', MEAN(vsw_x_dn,/NAN), MEAN(vsw_y_dn,/NAN),  MEAN(vsw_z_dn,/NAN)   & $
  IF (j EQ 2) THEN PRINT,';;', MEAN(mag_x_dn,/NAN), MEAN(mag_y_dn,/NAN),  MEAN(mag_z_dn,/NAN)
;;      14.1623      148.327      30.8271
;;     -198.972      29.2785     -60.9125
;;    -0.735263     -2.60037     -4.86887

;; => combine terms
vsw      = [[[vsw_up]],[[vsw_dn]]]
mag      = [[[magf_up]],[[magf_dn]]]
dens     = [[dens_up],[dens_dn]]
temp     = [[temp_up],[temp_dn]]
nmax     = 150L

.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/rh_pros/temp_rh_soln_print.pro
temp_rh_soln_print,dens,vsw,mag,temp,tdate[0],NMAX=nmax
;; => Print out best fit poloidal angles
PRINT,';', soln.THETA*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;       10.512893       6.8862212
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -16.745657       6.8515454
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -19.413500       6.8339397
;;-----------------------------------------------------------

;; => Print out best fit azimuthal angles
PRINT,';', soln.PHI*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;       16.699566       12.194251
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;       11.601542       7.5012038
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;       11.811351       7.5170267
;;-----------------------------------------------------------

;; => Print out best fit shock normal speed in spacecraft frame [km/s]
PRINT,';', soln.VSHN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -148.58077       62.226518
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -119.30885       71.421698
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -113.63091       71.916235
;;-----------------------------------------------------------

;; => Print out best fit upstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_UP
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -186.55803       65.671514
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -215.04908       71.289339
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -215.38994       71.807267
;;-----------------------------------------------------------

;; => Print out best fit downstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_DN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -36.318351       16.387115
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -41.458855       16.532407
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -41.534067       16.669708
;;-----------------------------------------------------------

;; => Print out best fit shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,0]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      0.91409655      0.27376012      0.18116287
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      0.92343677      0.18955004     -0.28598932
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      0.90880942      0.19003136     -0.32995737
;;-----------------------------------------------------------

;; => Print out best fit uncertainty in shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,1]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;     0.070457459      0.19453952      0.11769902
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;     0.044596426      0.12131106      0.11331492
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;     0.048280240      0.11982205      0.11132563
;;-----------------------------------------------------------



;;----------------------------------------------------------------------------------------
;; => Avg. terms [3rd Shock]
;;----------------------------------------------------------------------------------------
t_foot_se      = time_double(tdate[0]+'/'+['16:52:55.970','16:54:31.240'])
t_ramp_se      = time_double(tdate[0]+'/'+['16:54:31.240','16:54:33.120'])
tr_up          = time_double(tdate[0]+'/'+['16:51:50.000','16:52:33.000'])
tr_dn          = time_double(tdate[0]+'/'+['16:55:01.500','16:55:44.500'])

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

FOR j=0L, 1L DO BEGIN $
  IF (j EQ 0) THEN PRINT,';;', gdupBo, gdupNi, gdupTi, gdupTe, gdupVi, gdupPi  & $
  IF (j EQ 1) THEN PRINT,';;', gddnBo, gddnNi, gddnTi, gddnTe, gddnVi, gddnPi
;;         172          14          14          14          14          14
;;         172          14          14          14          14          14


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
;;      2.54864      2.74374      2.68832      2.66041      2.52640      2.56741      2.53633      2.61612      2.65512      2.46911      2.42103      2.48777      2.40995      2.56769
;;      7.74817      8.23287      7.73743      7.83670      7.60066      7.63320      7.66339      7.71820      8.00515      7.56948      7.77534      7.95865      8.12286      7.69764
;;      17.3059      16.4813      16.3144      16.7833      17.3225      17.9289      17.8971      17.0073      16.7988      17.0694      17.4679      17.6488      16.8763      15.8844
;;      8.08390      9.20306      8.24183      7.81010      7.24943      7.64352      7.35853      7.72339      8.57356      7.41149      7.26255      7.51396      8.25551      7.93731

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vswx_up       & $
  IF (j EQ 1) THEN PRINT,';;', vswy_up       & $
  IF (j EQ 2) THEN PRINT,';;', vswz_up
;;     -378.045     -379.347     -380.669     -381.990     -382.196     -381.321     -382.239     -382.183     -380.915     -381.900     -380.986     -379.830     -376.437     -376.583
;;     -9.36395     -9.87620     -9.65507     -8.47809     -7.30610     -6.03849     -5.69043     -5.74346     -6.33354     -6.60762     -6.17814     -7.01193     -7.92023     -7.65788
;;      5.97705      5.38922      3.52518      1.39406     -1.27315     -3.14139     -3.51773     -3.04843     -3.33440     -1.40754     -1.78857     -2.01916    -0.966911     -1.64121

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', up_magf[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', up_magf[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', up_magf[*,2]
;;    -0.465889    -0.493973    -0.500432    -0.431878    -0.335807    -0.301160    -0.331262    -0.307549    -0.315317    -0.314314    -0.317028    -0.301928    -0.280609    -0.253644
;;     -1.35246     -1.34568     -1.32603     -1.32091     -1.31635     -1.28558     -1.26383     -1.28327     -1.28497     -1.26040     -1.28209     -1.31660     -1.30783     -1.30590
;;    -0.268362    -0.263340    -0.263261    -0.257034    -0.304556    -0.379843    -0.450124    -0.475392    -0.410793    -0.322460    -0.334267    -0.396158    -0.458182    -0.474766

FOR j=0L, 3L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dn_Ni         & $
  IF (j EQ 1) THEN PRINT,';;', dn_Ti         & $
  IF (j EQ 2) THEN PRINT,';;', dn_Te         & $
  IF (j EQ 3) THEN PRINT,';;', dn_Pi
;;      17.5786      13.6227      13.2441      36.1232      11.2701      16.7879      14.0890      9.71509      16.2027      13.3838      17.0298      11.6280      19.4157      12.1069
;;      193.047      208.596      179.237      109.422      233.989      179.255      211.438      282.086      213.071      161.405      169.996      259.769      162.868      284.260
;;      35.5301      33.3474      36.2121      38.6540      33.2820      35.8770      33.8960      32.9379      39.1637      39.5493      39.5342      37.3020      37.1826      34.9462
;;      715.794      799.711      1217.89      862.180      891.668      607.898      1055.27      467.342      1169.95      740.455      694.322      989.077      929.791      1384.95

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vswx_dn       & $
  IF (j EQ 1) THEN PRINT,';;', vswy_dn       & $
  IF (j EQ 2) THEN PRINT,';;', vswz_dn
;;     -128.515     -136.917      28.5920     -63.2389     -92.2343     -79.8067     -88.3492     -125.562     -98.5237     -78.0602     -61.0386     -77.7578     -115.237     -84.9790
;;      92.9888     -46.3045     -47.8925      49.9458      121.634      57.7484      113.083     -54.9657      42.3296      63.3085      18.4252      75.4841      41.6601      63.9095
;;      44.0997      61.7693      163.981      126.473     -25.7559     -18.2330     -37.6530     -56.4455      29.2825      33.4536      41.0629     -9.34507     -37.1887     -12.1188

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dn_magf[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', dn_magf[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', dn_magf[*,2]
;;      1.14077    -0.189973    -0.569511     -1.10752     0.800855      1.60383      3.07508     0.853497    -0.576236     -1.04564    -0.125044   -0.0927951      1.29850     0.651983
;;     -8.76333     -9.55739     -7.51149     -5.53896     -4.25738     -3.38518     -3.48671     -6.72082     -9.90945     -7.91853     -5.89071     -6.65906     -6.26467     -5.65603
;;     -4.39599     -2.03679    -0.663585    -0.653667     0.457842     -1.24822     -5.81630     -4.25564     0.558235      3.06788     0.981923     -1.06882     0.242518   -0.0639303

;; => Upstream values
dens_up        = [  2.54864,  2.74374,  2.68832,  2.66041,  2.52640,  2.56741,  2.53633,  2.61612,  2.65512,  2.46911,  2.42103,  2.48777,  2.40995,  2.56769]
ti_avg_up      = [  7.74817,  8.23287,  7.73743,  7.83670,  7.60066,  7.63320,  7.66339,  7.71820,  8.00515,  7.56948,  7.77534,  7.95865,  8.12286,  7.69764]
te_avg_up      = [  17.3059,  16.4813,  16.3144,  16.7833,  17.3225,  17.9289,  17.8971,  17.0073,  16.7988,  17.0694,  17.4679,  17.6488,  16.8763,  15.8844]
Pi_up          = [  8.08390,  9.20306,  8.24183,  7.81010,  7.24943,  7.64352,  7.35853,  7.72339,  8.57356,  7.41149,  7.26255,  7.51396,  8.25551,  7.93731]
vsw_x_up       = [ -378.045, -379.347, -380.669, -381.990, -382.196, -381.321, -382.239, -382.183, -380.915, -381.900, -380.986, -379.830, -376.437, -376.583]
vsw_y_up       = [ -9.36395, -9.87620, -9.65507, -8.47809, -7.30610, -6.03849, -5.69043, -5.74346, -6.33354, -6.60762, -6.17814, -7.01193, -7.92023, -7.65788]
vsw_z_up       = [  5.97705,  5.38922,  3.52518,  1.39406, -1.27315, -3.14139, -3.51773, -3.04843, -3.33440, -1.40754, -1.78857, -2.01916,-0.966911, -1.64121]
mag_x_up       = [-0.465889,-0.493973,-0.500432,-0.431878,-0.335807,-0.301160,-0.331262,-0.307549,-0.315317,-0.314314,-0.317028,-0.301928,-0.280609,-0.253644]
mag_y_up       = [ -1.35246, -1.34568, -1.32603, -1.32091, -1.31635, -1.28558, -1.26383, -1.28327, -1.28497, -1.26040, -1.28209, -1.31660, -1.30783, -1.30590]
mag_z_up       = [-0.268362,-0.263340,-0.263261,-0.257034,-0.304556,-0.379843,-0.450124,-0.475392,-0.410793,-0.322460,-0.334267,-0.396158,-0.458182,-0.474766]
vsw_up         = [[vsw_x_up],[vsw_y_up],[vsw_z_up]]
magf_up        = [[mag_x_up],[mag_y_up],[mag_z_up]]
temp_up        = te_avg_up + ti_avg_up
FOR j=0L, 2L DO BEGIN                                                                             $
  IF (j EQ 0) THEN PRINT,';;', MEAN(dens_up,/NAN),  MEAN(ti_avg_up,/NAN), MEAN(te_avg_up,/NAN)  & $
  IF (j EQ 1) THEN PRINT,';;', MEAN(vsw_x_up,/NAN), MEAN(vsw_y_up,/NAN),  MEAN(vsw_z_up,/NAN)   & $
  IF (j EQ 2) THEN PRINT,';;', MEAN(mag_x_up,/NAN), MEAN(mag_y_up,/NAN),  MEAN(mag_z_up,/NAN)
;;      2.56415      7.80712      17.0562
;;     -380.332     -7.41865    -0.418070
;;    -0.353628     -1.30371    -0.361324


;; => Downstream values
dens_dn        = [  17.5786,  13.6227,  13.2441,  36.1232,  11.2701,  16.7879,  14.0890,  9.71509,  16.2027,  13.3838,  17.0298,  11.6280,  19.4157,  12.1069]
ti_avg_dn      = [  193.047,  208.596,  179.237,  109.422,  233.989,  179.255,  211.438,  282.086,  213.071,  161.405,  169.996,  259.769,  162.868,  284.260]
te_avg_dn      = [  35.5301,  33.3474,  36.2121,  38.6540,  33.2820,  35.8770,  33.8960,  32.9379,  39.1637,  39.5493,  39.5342,  37.3020,  37.1826,  34.9462]
Pi_dn          = [  715.794,  799.711,  1217.89,  862.180,  891.668,  607.898,  1055.27,  467.342,  1169.95,  740.455,  694.322,  989.077,  929.791,  1384.95]
vsw_x_dn       = [ -128.515, -136.917,  28.5920, -63.2389, -92.2343, -79.8067, -88.3492, -125.562, -98.5237, -78.0602, -61.0386, -77.7578, -115.237, -84.9790]
vsw_y_dn       = [  92.9888, -46.3045, -47.8925,  49.9458,  121.634,  57.7484,  113.083, -54.9657,  42.3296,  63.3085,  18.4252,  75.4841,  41.6601,  63.9095]
vsw_z_dn       = [  44.0997,  61.7693,  163.981,  126.473, -25.7559, -18.2330, -37.6530, -56.4455,  29.2825,  33.4536,  41.0629, -9.34507, -37.1887, -12.1188]
mag_x_dn       = [  1.14077,-0.189973,-0.569511, -1.10752, 0.800855,  1.60383,  3.07508, 0.853497,-0.576236, -1.04564,-0.125044,-0.092795,  1.29850, 0.651983]
mag_y_dn       = [ -8.76333, -9.55739, -7.51149, -5.53896, -4.25738, -3.38518, -3.48671, -6.72082, -9.90945, -7.91853, -5.89071, -6.65906, -6.26467, -5.65603]
mag_z_dn       = [ -4.39599, -2.03679,-0.663585,-0.653667, 0.457842, -1.24822, -5.81630, -4.25564, 0.558235,  3.06788, 0.981923, -1.06882, 0.242518,-0.063930]
vsw_dn         = [[vsw_x_dn],[vsw_y_dn],[vsw_z_dn]]
magf_dn        = [[mag_x_dn],[mag_y_dn],[mag_z_dn]]
temp_dn        = te_avg_dn + ti_avg_dn
FOR j=0L, 2L DO BEGIN                                                                             $
  IF (j EQ 0) THEN PRINT,';;', MEAN(dens_dn,/NAN),  MEAN(ti_avg_dn,/NAN), MEAN(te_avg_dn,/NAN)  & $
  IF (j EQ 1) THEN PRINT,';;', MEAN(vsw_x_dn,/NAN), MEAN(vsw_y_dn,/NAN),  MEAN(vsw_z_dn,/NAN)   & $
  IF (j EQ 2) THEN PRINT,';;', MEAN(mag_x_dn,/NAN), MEAN(mag_y_dn,/NAN),  MEAN(mag_z_dn,/NAN)
;;      15.8713      203.460      36.2439
;;     -85.8305      42.2396      21.6701
;;     0.408414     -6.53712     -1.06390

;; => combine terms
vsw      = [[[vsw_up]],[[vsw_dn]]]
mag      = [[[magf_up]],[[magf_dn]]]
dens     = [[dens_up],[dens_dn]]
temp     = [[temp_up],[temp_dn]]
nmax     = 150L

.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/rh_pros/temp_rh_soln_print.pro
temp_rh_soln_print,dens,vsw,mag,temp,tdate[0],NMAX=nmax
;; => Print out best fit poloidal angles
PRINT,';', soln.THETA*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -83.959732       3.8213594
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;       5.8816513       5.7854935
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;       7.3354277       5.8599622
;;-----------------------------------------------------------

;; => Print out best fit azimuthal angles
PRINT,';', soln.PHI*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -68.428678       14.782776
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;       10.819187       7.0293597
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;       11.200549       7.3717920
;;-----------------------------------------------------------

;; => Print out best fit shock normal speed in spacecraft frame [km/s]
PRINT,';', soln.VSHN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -30.468428       71.049577
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -8.2850663       53.473328
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -7.2596082       54.264692
;;-----------------------------------------------------------

;; => Print out best fit upstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_UP
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;       17.381946       71.943343
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -360.08194       57.783499
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -359.28619       59.124334
;;-----------------------------------------------------------

;; => Print out best fit downstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_DN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;       1.7732017       13.588761
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -64.531981       21.279008
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -64.351660       21.272659
;;-----------------------------------------------------------

;; => Print out best fit shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,0]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;     0.037340537    -0.094420904     -0.99223920
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      0.96483420      0.18433992      0.10192542
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      0.95990739      0.19001984      0.12698249
;;-----------------------------------------------------------

;; => Print out best fit uncertainty in shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,1]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;     0.037568873     0.060724228    0.0072731920
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;     0.027424013      0.11829278     0.099899553
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;     0.030433239      0.12347399      0.10086566
;;-----------------------------------------------------------


;;========================================================================================
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; => Correct initial Rankine-Hugoniot results
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;========================================================================================


;;------------------------------------------------
;;  Initial estimates from R-H Analysis
;;------------------------------------------------
nrh_1st        = 11d0                                         ;;  # of plasma parameters used in solution
stdfac         = SQRT(nrh_1st)                                ;;  Factor to convert Std. Dev. --> Std. Dev. of the Mean
Vshn_up__1st   = -77.654715d0                                 ;;  Shock normal speed [km/s, SCF]
dVshn_up_1st   =  5.2538123d0/stdfac[0]                       ;;  Uncertainty in Vshn
Ushn_up__1st   = -270.84172d0                                 ;;  Upstream shock normal speed [km/s, SHF]
dUshn_up_1st   =  7.3626369d0/stdfac[0]                       ;;  Uncertainty in Ushn_up
Ushn_dn__1st   = -39.924032d0                                 ;;  Downstream shock normal speed [km/s, SHF]
dUshn_dn_1st   =  5.1344510d0/stdfac[0]                       ;;  Uncertainty in Ushn_dn
norm__1st      = [ 0.92425461d0, 0.36864608d0, 0.06193485d0]  ;;  Shock normal vector [GSE basis]
dnorm_1st      = [ 0.00374274d0, 0.00149282d0, 0.07795239d0]  ;;  Uncertainty in n


nrh_2nd        = 15d0                                         ;;  # of plasma parameters used in solution
stdfac         = SQRT(nrh_2nd)                                ;;  Factor to convert Std. Dev. --> Std. Dev. of the Mean
Vshn_up__2nd   = -113.63091d0                                 ;;  Shock normal speed [km/s, SCF]
dVshn_up_2nd   =  71.916235d0/stdfac[0]                       ;;  Uncertainty in Vshn
Ushn_up__2nd   = -215.38994d0                                 ;;  Upstream shock normal speed [km/s, SHF]
dUshn_up_2nd   =  71.807267d0/stdfac[0]                       ;;  Uncertainty in Ushn_up
Ushn_dn__2nd   = -41.534067d0                                 ;;  Downstream shock normal speed [km/s, SHF]
dUshn_dn_2nd   =  16.669708d0/stdfac[0]                       ;;  Uncertainty in Ushn_dn
norm__2nd      = [ 0.90880942d0, 0.19003136d0,-0.32995737d0]  ;;  Shock normal vector [GSE basis]
dnorm_2nd      = [ 0.04828024d0, 0.11982205d0, 0.11132563d0]  ;;  Uncertainty in n


nrh_3rd        = 14d0                                         ;;  # of plasma parameters used in solution
stdfac         = SQRT(nrh_3rd)                                ;;  Factor to convert Std. Dev. --> Std. Dev. of the Mean
Vshn_up__3rd   = -7.2596082d0                                 ;;  Shock normal speed [km/s, SCF]
dVshn_up_3rd   =  54.264692d0/stdfac[0]                       ;;  Uncertainty in Vshn
Ushn_up__3rd   = -359.28619d0                                 ;;  Upstream shock normal speed [km/s, SHF]
dUshn_up_3rd   =  59.124334d0/stdfac[0]                       ;;  Uncertainty in Ushn_up
Ushn_dn__3rd   = -64.351660d0                                 ;;  Downstream shock normal speed [km/s, SHF]
dUshn_dn_3rd   =  21.272659d0/stdfac[0]                       ;;  Uncertainty in Ushn_dn
norm__3rd      = [ 0.95990739d0, 0.19001984d0, 0.12698249d0]  ;;  Shock normal vector [GSE basis]
dnorm_3rd      = [ 0.03043324d0, 0.12347399d0, 0.10086566d0]  ;;  Uncertainty in n
;;------------------------------------------------
;;  
;;------------------------------------------------



bo_up          = magf_up    ;;  [N,3]-Element array of upstream B-field vectors [nT]
bo_dn          = magf_dn    ;;  [N,3]-Element array of downstream B-field vectors [nT]
ni_up          = dens_up    ;;  [N]-Element array of upstream number densities [cm^(-3)]
ni_dn          = dens_dn    ;;  [N]-Element array of downstream number densities [cm^(-3)]
vsw_up         = vsw_up     ;;  [N,3]-Element array of upstream bulk flow velocity vectors [km/s]
vsw_dn         = vsw_dn     ;;  [N,3]-Element array of downstream bulk flow velocity vectors [km/s]

n_vec          = norm__1st  ;;  [3]-Element array defining the initial shock normal vector [GSE]
dnvec          = dnorm_1st  ;;  Uncertainty in N_VEC

n_vec          = norm__2nd  ;;  [3]-Element array defining the initial shock normal vector [GSE]
dnvec          = dnorm_2nd  ;;  Uncertainty in N_VEC

n_vec          = norm__3rd  ;;  [3]-Element array defining the initial shock normal vector [GSE]
dnvec          = dnorm_3rd  ;;  Uncertainty in N_VEC

;;  Find the "correct" solutions by forcing co-planarity
.compile find_coplanarity_from_rhsolns.pro
coplane        = find_coplanarity_from_rhsolns(n_vec,dnvec,bo_up,bo_dn,V_UP=vsw_up,$
                                               N_UP=ni_up,V_DN=vsw_dn,N_DN=ni_dn)
;;  New Shock Parameters
vshn_up        = coplane.SPEEDS.V_SHN_UP[0]
dvshnup        = coplane.SPEEDS.V_SHN_UP[2]
ushn_up        = coplane.SPEEDS.U_SHN_UP[0]
dushnup        = coplane.SPEEDS.U_SHN_UP[2]
ushn_dn        = coplane.SPEEDS.U_SHN_DN[0]
dushndn        = coplane.SPEEDS.U_SHN_DN[2]
gnorm          = coplane.NEW_NVEC
;;  New Avg. upstream/downstream Bo
magf_up        = coplane.BO_AVG_UP
magf_dn        = coplane.BO_AVG_DN
;;  New theta_Bn
bvec_up        = magf_up/NORM(magf_up)
n_dot_Bo       = my_dot_prod(gnorm,bvec_up,/NOM)
angle0         = ACOS(n_dot_Bo)*18d1/!DPI
theta_Bn       = angle0[0] < (18d1 - angle0[0])

;;  Print out new parameters
crn_str_out    = ';;  NEW Average Shock Terms ['+['1st','2nd','3rd']+' Crossing]'
nf             = 'f15.8'
vecform        = '("[",'+nf[0]+',"d0,",'+nf[0]+',"d0,",'+nf[0]+',"d0]")'
scaform        = '('+nf[0]+',"d0")'
FOR i=0L, 9L DO BEGIN                                                                 $
  IF (i EQ 0) THEN PRINT, crn_str_out[k]                                            & $
  IF (i EQ 0) THEN PRINT, 'vshn_up        = '+STRING(vshn_up[0],FORMAT=scaform[0])  & $
  IF (i EQ 1) THEN PRINT, 'dvshnup        = '+STRING(dvshnup[0],FORMAT=scaform[0])  & $
  IF (i EQ 2) THEN PRINT, 'ushn_up        = '+STRING(ushn_up[0],FORMAT=scaform[0])  & $
  IF (i EQ 3) THEN PRINT, 'dushnup        = '+STRING(dushnup[0],FORMAT=scaform[0])  & $
  IF (i EQ 4) THEN PRINT, 'ushn_dn        = '+STRING(ushn_dn[0],FORMAT=scaform[0])  & $
  IF (i EQ 5) THEN PRINT, 'dushndn        = '+STRING(dushndn[0],FORMAT=scaform[0])  & $
  IF (i EQ 6) THEN PRINT, 'gnorm          = '+STRING(gnorm,FORMAT=vecform[0])       & $
  IF (i EQ 7) THEN PRINT, 'magf_up        = '+STRING(magf_up,FORMAT=vecform[0])     & $
  IF (i EQ 8) THEN PRINT, 'magf_dn        = '+STRING(magf_dn,FORMAT=vecform[0])     & $
  IF (i EQ 9) THEN PRINT, 'theta_Bn       = '+STRING(theta_Bn[0],FORMAT=scaform[0])

;;  NEW Average Shock Terms [1st Crossing]
vshn_up        =    -77.71897065d0
dvshnup        =      4.80469178d0
ushn_up        =   -269.64752023d0
dushnup        =      0.90093028d0
ushn_dn        =    -60.11173950d0
dushndn        =      8.88906398d0
gnorm          = [     0.91986927d0,     0.36689695d0,     0.13866201d0]
magf_up        = [     0.61279484d0,    -0.57618533d0,    -0.29177513d0]
magf_dn        = [     2.96029421d0,    -8.57990003d0,     1.29101706d0]
theta_Bn       =     69.49713994d0

;;  NEW Average Shock Terms [2nd Crossing]
vshn_up        =   -120.42239904d0
dvshnup        =     17.10918890d0
ushn_up        =   -219.90948937d0
dushnup        =      0.55434394d0
ushn_dn        =    -42.80976250d0
dushndn        =     14.02234390d0
gnorm          = [     0.92968239d0,     0.30098043d0,    -0.21237099d0]
magf_up        = [    -1.07332678d0,    -1.06251983d0,    -0.23281553d0]
magf_dn        = [    -2.95333773d0,    -5.69773245d0,    -6.91488147d0]
theta_Bn       =     33.91071437d0

;;  NEW Average Shock Terms [3rd Crossing]
vshn_up        =      0.98265883d0
dvshnup        =     15.08311669d0
ushn_up        =   -357.43730189d0
dushnup        =      0.51836578d0
ushn_dn        =    -63.81670800d0
dushndn        =     12.47117700d0
gnorm          = [     0.93123543d0,     0.29478399d0,     0.21424979d0]
magf_up        = [    -0.27134223d0,    -1.27554421d0,    -0.27749658d0]
magf_dn        = [     0.40841404d0,    -6.53712225d0,    -1.06389594d0]
theta_Bn       =     58.92700155d0








































;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/"Bad" solutions
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------


;;----------------------------------------------------------------------------------------
;; => Avg. terms [1st Shock]
;;----------------------------------------------------------------------------------------
t_foot_se      = time_double(tdate[0]+'/'+['16:11:33.800','16:12:11.660'])
t_ramp_se      = time_double(tdate[0]+'/'+['16:11:32.910','16:11:33.800'])
tr_up          = time_double(tdate[0]+'/'+['16:15:00.000','16:15:34.000'])
tr_dn          = time_double(tdate[0]+'/'+['16:10:54.900','16:11:28.900'])

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

FOR j=0L, 1L DO BEGIN $
  IF (j EQ 0) THEN PRINT,';;', gdupBo, gdupNi, gdupTi, gdupTe, gdupVi, gdupPi  & $
  IF (j EQ 1) THEN PRINT,';;', gddnBo, gddnNi, gddnTi, gddnTe, gddnVi, gddnPi
;;         136          11          11          11          11          11
;;         136          11          11          11          11          11


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
;;      2.74746      2.63503      2.55310      2.62704      2.41764      2.65645      2.69625      2.64081      2.71218      2.53692      2.54303
;;      8.55088      8.26501      8.00998      8.03532      8.44388      8.06652      8.27741      8.06267      8.11074      8.00202      8.20389
;;      12.4194      12.3775      13.6209      14.1289      14.4666      13.8679      13.4698      13.3386      13.5273      14.0566      14.7478
;;      10.2027      9.29157      8.25524      8.52344      8.59256      8.78458      9.29564      8.45274      9.11019      7.96194      8.35954

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vswx_up       & $
  IF (j EQ 1) THEN PRINT,';;', vswy_up       & $
  IF (j EQ 2) THEN PRINT,';;', vswz_up
;;     -376.532     -376.351     -376.841     -377.419     -378.033     -379.007     -378.893     -379.876     -379.686     -380.867     -383.603
;;      7.83977      7.28592      7.92277      7.26878      6.78583      5.47892      5.36511      4.96828      2.82403      4.13422      1.53799
;;     -5.20361     -4.42141     -4.43812     -5.14862     -6.54401     -6.39428     -8.92870     -7.01621     -6.75324     -9.15813     -10.7691

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', up_magf[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', up_magf[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', up_magf[*,2]
;;     0.581560     0.626457     0.596671     0.533517     0.554378     0.602951     0.585140     0.563207     0.563418     0.579196     0.629615
;;    -0.610748    -0.617448    -0.623948    -0.643724    -0.600628    -0.587427    -0.611435    -0.625434    -0.598062    -0.546986    -0.570952
;;    -0.409161    -0.458181    -0.421239    -0.289744    -0.255391    -0.280506    -0.321329    -0.373138    -0.431198    -0.409244    -0.325292

FOR j=0L, 3L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dn_Ni         & $
  IF (j EQ 1) THEN PRINT,';;', dn_Ti         & $
  IF (j EQ 2) THEN PRINT,';;', dn_Te         & $
  IF (j EQ 3) THEN PRINT,';;', dn_Pi
;;      3.01548      1.91662      2.18725      2.34226      2.47510      1.90352      2.74389      2.34493      13.2462      20.1632      20.6019
;;      262.334      422.596      367.398      422.843      429.037      464.810      414.681      387.317      71.9713      53.3489      65.3654
;;      71.8956      77.7809      83.6006      95.3711      100.746      111.350      93.3520      92.3883      42.4176      40.9043      37.5340
;;      302.171      304.073      301.200      324.413      253.258      224.494      277.035      138.945      389.750      603.928      631.438

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vswx_dn       & $
  IF (j EQ 1) THEN PRINT,';;', vswy_dn       & $
  IF (j EQ 2) THEN PRINT,';;', vswz_dn
;;     -95.9943     -113.784     -91.9186     -151.280     -244.676     -150.070     -107.657     -251.243     -156.409     -163.921     -175.175
;;     -140.235     -78.7697     -60.7398      36.3733     -30.1494     -70.5216     -20.6711      65.2090      103.075      79.2468      88.6847
;;     -38.5277     -29.4858     -55.9028     -31.6574     -7.13810     -40.1682     -64.8422      2.13400      61.7436     -7.60060      31.9321

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dn_magf[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', dn_magf[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', dn_magf[*,2]
;;     -2.85274     -1.80860    -0.819308    -0.438840    0.0107723     0.933281      2.01882      2.92823      3.13606      3.00192      2.98169
;;     -4.20480     -1.80470     0.215825     0.115694     -4.23300     -7.93249     -5.15349     -3.72875     -6.94817     -9.70987     -8.03452
;;     0.339288      1.58918     0.896786    -0.547763     -4.68333     -8.93511     -1.51705      8.07026      9.82553      1.71186     -1.76504

;; => Upstream values
dens_up        = [  2.74746,  2.63503,  2.55310,  2.62704,  2.41764,  2.65645,  2.69625,  2.64081,  2.71218,  2.53692,  2.54303]
ti_avg_up      = [  8.55088,  8.26501,  8.00998,  8.03532,  8.44388,  8.06652,  8.27741,  8.06267,  8.11074,  8.00202,  8.20389]
te_avg_up      = [  12.4194,  12.3775,  13.6209,  14.1289,  14.4666,  13.8679,  13.4698,  13.3386,  13.5273,  14.0566,  14.7478]
Pi_up          = [  10.2027,  9.29157,  8.25524,  8.52344,  8.59256,  8.78458,  9.29564,  8.45274,  9.11019,  7.96194,  8.35954]
vsw_x_up       = [ -376.532, -376.351, -376.841, -377.419, -378.033, -379.007, -378.893, -379.876, -379.686, -380.867, -383.603]
vsw_y_up       = [  7.83977,  7.28592,  7.92277,  7.26878,  6.78583,  5.47892,  5.36511,  4.96828,  2.82403,  4.13422,  1.53799]
vsw_z_up       = [ -5.20361, -4.42141, -4.43812, -5.14862, -6.54401, -6.39428, -8.92870, -7.01621, -6.75324, -9.15813, -10.7691]
mag_x_up       = [ 0.581560, 0.626457, 0.596671, 0.533517, 0.554378, 0.602951, 0.585140, 0.563207, 0.563418, 0.579196, 0.629615]
mag_y_up       = [-0.610748,-0.617448,-0.623948,-0.643724,-0.600628,-0.587427,-0.611435,-0.625434,-0.598062,-0.546986,-0.570952]
mag_z_up       = [-0.409161,-0.458181,-0.421239,-0.289744,-0.255391,-0.280506,-0.321329,-0.373138,-0.431198,-0.409244,-0.325292]
vsw_up         = [[vsw_x_up],[vsw_y_up],[vsw_z_up]]
magf_up        = [[mag_x_up],[mag_y_up],[mag_z_up]]
temp_up        = te_avg_up + ti_avg_up
FOR j=0L, 2L DO BEGIN                                                                             $
  IF (j EQ 0) THEN PRINT,';;', MEAN(dens_up,/NAN),  MEAN(ti_avg_up,/NAN), MEAN(te_avg_up,/NAN)  & $
  IF (j EQ 1) THEN PRINT,';;', MEAN(vsw_x_up,/NAN), MEAN(vsw_y_up,/NAN),  MEAN(vsw_z_up,/NAN)   & $
  IF (j EQ 2) THEN PRINT,';;', MEAN(mag_x_up,/NAN), MEAN(mag_y_up,/NAN),  MEAN(mag_z_up,/NAN)
;;      2.61508      8.18439      13.6383
;;     -378.828      5.58287     -6.79777
;;     0.583283    -0.603345    -0.361311


;; => Downstream values
dens_dn        = [  3.01548,  1.91662,  2.18725,  2.34226,  2.47510,  1.90352,  2.74389,  2.34493,  13.2462,  20.1632,  20.6019]
ti_avg_dn      = [  262.334,  422.596,  367.398,  422.843,  429.037,  464.810,  414.681,  387.317,  71.9713,  53.3489,  65.3654]
te_avg_dn      = [  71.8956,  77.7809,  83.6006,  95.3711,  100.746,  111.350,  93.3520,  92.3883,  42.4176,  40.9043,  37.5340]
Pi_dn          = [  302.171,  304.073,  301.200,  324.413,  253.258,  224.494,  277.035,  138.945,  389.750,  603.928,  631.438]
vsw_x_dn       = [ -95.9943, -113.784, -91.9186, -151.280, -244.676, -150.070, -107.657, -251.243, -156.409, -163.921, -175.175]
vsw_y_dn       = [ -140.235, -78.7697, -60.7398,  36.3733, -30.1494, -70.5216, -20.6711,  65.2090,  103.075,  79.2468,  88.6847]
vsw_z_dn       = [ -38.5277, -29.4858, -55.9028, -31.6574, -7.13810, -40.1682, -64.8422,  2.13400,  61.7436, -7.60060,  31.9321]
mag_x_dn       = [ -2.85274, -1.80860,-0.819308,-0.438840,0.0107723, 0.933281,  2.01882,  2.92823,  3.13606,  3.00192,  2.98169]
mag_y_dn       = [ -4.20480, -1.80470, 0.215825, 0.115694, -4.23300, -7.93249, -5.15349, -3.72875, -6.94817, -9.70987, -8.03452]
mag_z_dn       = [ 0.339288,  1.58918, 0.896786,-0.547763, -4.68333, -8.93511, -1.51705,  8.07026,  9.82553,  1.71186, -1.76504]
vsw_dn         = [[vsw_x_dn],[vsw_y_dn],[vsw_z_dn]]
magf_dn        = [[mag_x_dn],[mag_y_dn],[mag_z_dn]]
temp_dn        = te_avg_dn + ti_avg_dn
FOR j=0L, 2L DO BEGIN                                                                             $
  IF (j EQ 0) THEN PRINT,';;', MEAN(dens_dn,/NAN),  MEAN(ti_avg_dn,/NAN), MEAN(te_avg_dn,/NAN)  & $
  IF (j EQ 1) THEN PRINT,';;', MEAN(vsw_x_dn,/NAN), MEAN(vsw_y_dn,/NAN),  MEAN(vsw_z_dn,/NAN)   & $
  IF (j EQ 2) THEN PRINT,';;', MEAN(mag_x_dn,/NAN), MEAN(mag_y_dn,/NAN),  MEAN(mag_z_dn,/NAN)
;;      6.63094      305.609      77.0309
;;     -154.739     -2.59071     -16.3194
;;     0.826481     -4.67439     0.453146

;; => combine terms
vsw      = [[[vsw_up]],[[vsw_dn]]]
mag      = [[[magf_up]],[[magf_dn]]]
dens     = [[dens_up],[dens_dn]]
temp     = [[temp_up],[temp_dn]]
nmax     = 150L

.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/rh_pros/temp_rh_soln_print.pro
temp_rh_soln_print,dens,vsw,mag,temp,tdate[0],NMAX=nmax
;; => Print out best fit poloidal angles
PRINT,';', soln.THETA*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;       79.127517       6.6179437
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -82.359261       5.3112902
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -84.551015       3.7234497
;;-----------------------------------------------------------

;; => Print out best fit azimuthal angles
PRINT,';', soln.PHI*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;       12.036447       7.6216510
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;       12.032184       7.6404961
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -13.351222       14.630565
;;-----------------------------------------------------------

;; => Print out best fit shock normal speed in spacecraft frame [km/s]
PRINT,';', soln.VSHN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -24.983093       677.93838
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;       432.37141       1607.4925
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;       398.71654       1414.9061
;;-----------------------------------------------------------

;; => Print out best fit upstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_UP
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -50.239761       690.34489
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -474.11501       1610.3418
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -425.87833       1416.0276
;;-----------------------------------------------------------

;; => Print out best fit downstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_DN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -19.142739       680.79900
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -436.19056       1595.1212
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -396.25501       1401.2699
;;-----------------------------------------------------------

;; => Print out best fit shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,0]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      0.18163323     0.038727902      0.97551380
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      0.12830311     0.027346606     -0.98687509
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;     0.089212945    -0.021174860     -0.99338286
;;-----------------------------------------------------------

;; => Print out best fit uncertainty in shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,1]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      0.10968721     0.036694581     0.022462570
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;     0.088790122     0.028152562     0.013848630
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;     0.061212005     0.031446316    0.0068834071
;;-----------------------------------------------------------


;;----------------------------------------------------------------------------------------
;; => Avg. terms [1st Shock]
;;----------------------------------------------------------------------------------------
t_foot_se      = time_double(tdate[0]+'/'+['16:11:33.800','16:12:11.660'])
t_ramp_se      = time_double(tdate[0]+'/'+['16:11:32.910','16:11:33.800'])
tr_up          = time_double(tdate[0]+'/'+['16:15:00.000','16:15:34.000'])
tr_dn          = time_double(tdate[0]+'/'+['16:10:54.900','16:11:28.900'])

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

FOR j=0L, 1L DO BEGIN $
  IF (j EQ 0) THEN PRINT,';;', gdupBo, gdupNi, gdupTi, gdupTe, gdupVi, gdupPi  & $
  IF (j EQ 1) THEN PRINT,';;', gddnBo, gddnNi, gddnTi, gddnTe, gddnVi, gddnPi
;;         136          11          11          11          11          11
;;         136          11          11          11          11          11


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
;;      2.74746      2.63503      2.55310      2.62704      2.41764      2.65645      2.69625      2.64081      2.71218      2.53692      2.54303
;;      8.55088      8.26501      8.00998      8.03532      8.44388      8.06652      8.27741      8.06267      8.11074      8.00202      8.20389
;;      12.4194      12.3775      13.6209      14.1289      14.4666      13.8679      13.4698      13.3386      13.5273      14.0566      14.7478
;;      10.2027      9.29157      8.25524      8.52344      8.59256      8.78458      9.29564      8.45274      9.11019      7.96194      8.35954

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vswx_up       & $
  IF (j EQ 1) THEN PRINT,';;', vswy_up       & $
  IF (j EQ 2) THEN PRINT,';;', vswz_up
;;     -376.532     -376.351     -376.841     -377.419     -378.033     -379.007     -378.893     -379.876     -379.686     -380.867     -383.603
;;      7.83977      7.28592      7.92277      7.26878      6.78583      5.47892      5.36511      4.96828      2.82403      4.13422      1.53799
;;     -5.20361     -4.42141     -4.43812     -5.14862     -6.54401     -6.39428     -8.92870     -7.01621     -6.75324     -9.15813     -10.7691

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', up_magf[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', up_magf[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', up_magf[*,2]
;;     0.581560     0.626457     0.596671     0.533517     0.554378     0.602951     0.585140     0.563207     0.563418     0.579196     0.629615
;;    -0.610748    -0.617448    -0.623948    -0.643724    -0.600628    -0.587427    -0.611435    -0.625434    -0.598062    -0.546986    -0.570952
;;    -0.409161    -0.458181    -0.421239    -0.289744    -0.255391    -0.280506    -0.321329    -0.373138    -0.431198    -0.409244    -0.325292

FOR j=0L, 3L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dn_Ni         & $
  IF (j EQ 1) THEN PRINT,';;', dn_Ti         & $
  IF (j EQ 2) THEN PRINT,';;', dn_Te         & $
  IF (j EQ 3) THEN PRINT,';;', dn_Pi
;;      3.01548      1.91662      2.18725      2.34226      2.47510      1.90352      2.74389      2.34493      13.2462      20.1632      20.6019
;;      262.334      422.596      367.398      422.843      429.037      464.810      414.681      387.317      71.9713      53.3489      65.3654
;;      71.8956      77.7809      83.6006      95.3711      100.746      111.350      93.3520      92.3883      42.4176      40.9043      37.5340
;;      302.171      304.073      301.200      324.413      253.258      224.494      277.035      138.945      389.750      603.928      631.438

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vswx_dn       & $
  IF (j EQ 1) THEN PRINT,';;', vswy_dn       & $
  IF (j EQ 2) THEN PRINT,';;', vswz_dn
;;     -95.9943     -113.784     -91.9186     -151.280     -244.676     -150.070     -107.657     -251.243     -156.409     -163.921     -175.175
;;     -140.235     -78.7697     -60.7398      36.3733     -30.1494     -70.5216     -20.6711      65.2090      103.075      79.2468      88.6847
;;     -38.5277     -29.4858     -55.9028     -31.6574     -7.13810     -40.1682     -64.8422      2.13400      61.7436     -7.60060      31.9321

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dn_magf[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', dn_magf[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', dn_magf[*,2]
;;     -2.85274     -1.80860    -0.819308    -0.438840    0.0107723     0.933281      2.01882      2.92823      3.13606      3.00192      2.98169
;;     -4.20480     -1.80470     0.215825     0.115694     -4.23300     -7.93249     -5.15349     -3.72875     -6.94817     -9.70987     -8.03452
;;     0.339288      1.58918     0.896786    -0.547763     -4.68333     -8.93511     -1.51705      8.07026      9.82553      1.71186     -1.76504

;; => Upstream values
dens_up        = [  2.74746,  2.63503,  2.55310,  2.62704,  2.41764,  2.65645,  2.69625,  2.64081,  2.71218,  2.53692,  2.54303]
ti_avg_up      = [  8.55088,  8.26501,  8.00998,  8.03532,  8.44388,  8.06652,  8.27741,  8.06267,  8.11074,  8.00202,  8.20389]
te_avg_up      = [  12.4194,  12.3775,  13.6209,  14.1289,  14.4666,  13.8679,  13.4698,  13.3386,  13.5273,  14.0566,  14.7478]
Pi_up          = [  10.2027,  9.29157,  8.25524,  8.52344,  8.59256,  8.78458,  9.29564,  8.45274,  9.11019,  7.96194,  8.35954]
vsw_x_up       = [ -376.532, -376.351, -376.841, -377.419, -378.033, -379.007, -378.893, -379.876, -379.686, -380.867, -383.603]
vsw_y_up       = [  7.83977,  7.28592,  7.92277,  7.26878,  6.78583,  5.47892,  5.36511,  4.96828,  2.82403,  4.13422,  1.53799]
vsw_z_up       = [ -5.20361, -4.42141, -4.43812, -5.14862, -6.54401, -6.39428, -8.92870, -7.01621, -6.75324, -9.15813, -10.7691]
mag_x_up       = [ 0.581560, 0.626457, 0.596671, 0.533517, 0.554378, 0.602951, 0.585140, 0.563207, 0.563418, 0.579196, 0.629615]
mag_y_up       = [-0.610748,-0.617448,-0.623948,-0.643724,-0.600628,-0.587427,-0.611435,-0.625434,-0.598062,-0.546986,-0.570952]
mag_z_up       = [-0.409161,-0.458181,-0.421239,-0.289744,-0.255391,-0.280506,-0.321329,-0.373138,-0.431198,-0.409244,-0.325292]
vsw_up         = [[vsw_x_up],[vsw_y_up],[vsw_z_up]]
magf_up        = [[mag_x_up],[mag_y_up],[mag_z_up]]
temp_up        = te_avg_up + ti_avg_up
FOR j=0L, 2L DO BEGIN                                                                             $
  IF (j EQ 0) THEN PRINT,';;', MEAN(dens_up,/NAN),  MEAN(ti_avg_up,/NAN), MEAN(te_avg_up,/NAN)  & $
  IF (j EQ 1) THEN PRINT,';;', MEAN(vsw_x_up,/NAN), MEAN(vsw_y_up,/NAN),  MEAN(vsw_z_up,/NAN)   & $
  IF (j EQ 2) THEN PRINT,';;', MEAN(mag_x_up,/NAN), MEAN(mag_y_up,/NAN),  MEAN(mag_z_up,/NAN)
;;      2.61508      8.18439      13.6383
;;     -378.828      5.58287     -6.79777
;;     0.583283    -0.603345    -0.361311


;; => Downstream values
;;    ->  The downstream density drops quickly because the region becomes rarified...
;;      ->  Take the last 3 values for each parameter only
;;      ->  Find the mean and standard deviation
;;      ->  Produce a random distribution of points about mean with FWHM = standard deviation
nn_up          = N_ELEMENTS(dens_up)
ind0           = nn_up[0] - 4L
ind1           = nn_up[0] - 1L
rand           = RANDOMU(seed,nn_up[0],/DOUBLE)
rand          -= MEAN(rand,/NAN)           ;;  center uniform distribution on zero
rand           = rand/MAX(ABS(rand),/NAN)  ;;  normalize uniform distribution

dens_dn_0      = [  3.01548,  1.91662,  2.18725,  2.34226,  2.47510,  1.90352,  2.74389,  2.34493,  13.2462,  20.1632,  20.6019]
ti_avg_dn_0    = [  262.334,  422.596,  367.398,  422.843,  429.037,  464.810,  414.681,  387.317,  71.9713,  53.3489,  65.3654]
te_avg_dn_0    = [  71.8956,  77.7809,  83.6006,  95.3711,  100.746,  111.350,  93.3520,  92.3883,  42.4176,  40.9043,  37.5340]
Pi_dn_0        = [  302.171,  304.073,  301.200,  324.413,  253.258,  224.494,  277.035,  138.945,  389.750,  603.928,  631.438]
vsw_x_dn_0     = [ -95.9943, -113.784, -91.9186, -151.280, -244.676, -150.070, -107.657, -251.243, -156.409, -163.921, -175.175]
vsw_y_dn_0     = [ -140.235, -78.7697, -60.7398,  36.3733, -30.1494, -70.5216, -20.6711,  65.2090,  103.075,  79.2468,  88.6847]
vsw_z_dn_0     = [ -38.5277, -29.4858, -55.9028, -31.6574, -7.13810, -40.1682, -64.8422,  2.13400,  61.7436, -7.60060,  31.9321]
mag_x_dn_0     = [ -2.85274, -1.80860,-0.819308,-0.438840,0.0107723, 0.933281,  2.01882,  2.92823,  3.13606,  3.00192,  2.98169]
mag_y_dn_0     = [ -4.20480, -1.80470, 0.215825, 0.115694, -4.23300, -7.93249, -5.15349, -3.72875, -6.94817, -9.70987, -8.03452]
mag_z_dn_0     = [ 0.339288,  1.58918, 0.896786,-0.547763, -4.68333, -8.93511, -1.51705,  8.07026,  9.82553,  1.71186, -1.76504]

x              =   MEAN(dens_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(dens_dn_0[ind0[0]:ind1[0]],/NAN)
dens_dn        = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(ti_avg_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(ti_avg_dn_0[ind0[0]:ind1[0]],/NAN)
ti_avg_dn      = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(te_avg_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(te_avg_dn_0[ind0[0]:ind1[0]],/NAN)
te_avg_dn      = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(Pi_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(Pi_dn_0[ind0[0]:ind1[0]],/NAN)
Pi_dn          = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(vsw_x_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(vsw_x_dn_0[ind0[0]:ind1[0]],/NAN)
vsw_x_dn       = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(vsw_y_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(vsw_y_dn_0[ind0[0]:ind1[0]],/NAN)
vsw_y_dn       = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(vsw_z_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(vsw_z_dn_0[ind0[0]:ind1[0]],/NAN)
vsw_z_dn       = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(mag_x_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(mag_x_dn_0[ind0[0]:ind1[0]],/NAN)
mag_x_dn       = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(mag_y_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(mag_y_dn_0[ind0[0]:ind1[0]],/NAN)
mag_y_dn       = FLOAT(rand*dx[0] + x[0])
x              =   MEAN(mag_z_dn_0[ind0[0]:ind1[0]],/NAN)
dx             = STDDEV(mag_z_dn_0[ind0[0]:ind1[0]],/NAN)
mag_z_dn       = FLOAT(rand*dx[0] + x[0])
vsw_dn         = [[vsw_x_dn],[vsw_y_dn],[vsw_z_dn]]
magf_dn        = [[mag_x_dn],[mag_y_dn],[mag_z_dn]]
temp_dn        = te_avg_dn + ti_avg_dn

FOR j=0L, 3L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', dens_dn         & $
  IF (j EQ 1) THEN PRINT,';;', ti_avg_dn       & $
  IF (j EQ 2) THEN PRINT,';;', te_avg_dn       & $
  IF (j EQ 3) THEN PRINT,';;', Pi_dn
;;      15.4100      14.2561      20.2954      20.3472      19.8555      5.56561      12.4434      12.4448      13.7836      14.0787      6.49937
;;      169.617      147.677      262.504      263.491      254.140     -17.5604      113.210      113.238      138.693      144.303     0.193614
;;      57.3609      53.8231      72.3384      72.4975      70.9898      27.1797      48.2656      48.2702      52.3746      53.2792      30.0424
;;      476.433      445.494      607.417      608.808      595.622      212.487      396.891      396.931      432.826      440.736      237.522

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', vsw_dn[*,0]   & $
  IF (j EQ 1) THEN PRINT,';;', vsw_dn[*,1]   & $
  IF (j EQ 2) THEN PRINT,';;', vsw_dn[*,2]
;;     -179.911     -185.830     -154.850     -154.584     -157.107     -230.410     -195.129     -195.121     -188.254     -186.740     -225.620
;;      86.5230      84.3661      95.6547      95.7516      94.8324      68.1219      80.9777      80.9805      83.4829      84.0344      69.8672
;;      26.9114      22.6667      44.8818      45.0726      43.2637     -9.30078      15.9987      16.0041      20.9287      22.0140     -5.86602

FOR j=0L, 2L DO BEGIN                          $
  IF (j EQ 0) THEN PRINT,';;', magf_dn[*,0]  & $
  IF (j EQ 1) THEN PRINT,';;', magf_dn[*,1]  & $
  IF (j EQ 2) THEN PRINT,';;', magf_dn[*,2]
;;      3.02567      3.01371      3.07632      3.07686      3.07176      2.92360      2.99491      2.99493      3.00881      3.01187      2.93328
;;     -6.71455     -7.05591     -5.26935     -5.25401     -5.39949     -9.62677     -7.59216     -7.59172     -7.19568     -7.10841     -9.35054
;;      5.30064      4.56687      8.40713      8.44011      8.12740    -0.959258      3.41418      3.41513      4.26643      4.45404    -0.365500

FOR j=0L, 2L DO BEGIN                                                                             $
  IF (j EQ 0) THEN PRINT,';;', MEAN(dens_dn,/NAN),  MEAN(ti_avg_dn,/NAN), MEAN(te_avg_dn,/NAN)  & $
  IF (j EQ 1) THEN PRINT,';;', MEAN(vsw_x_dn,/NAN), MEAN(vsw_y_dn,/NAN),  MEAN(vsw_z_dn,/NAN)   & $
  IF (j EQ 2) THEN PRINT,';;', MEAN(mag_x_dn,/NAN), MEAN(mag_y_dn,/NAN),  MEAN(mag_z_dn,/NAN)
;;      14.0891      144.501      53.3110
;;     -186.687      84.0539      22.0523
;;      3.01198     -7.10533      4.46065

;; => combine terms
vsw      = [[[vsw_up]],[[vsw_dn]]]
mag      = [[[magf_up]],[[magf_dn]]]
dens     = [[dens_up],[dens_dn]]
temp     = [[temp_up],[temp_dn]]
nmax     = 150L

.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/rh_pros/temp_rh_soln_print.pro
temp_rh_soln_print,dens,vsw,mag,temp,tdate[0],NMAX=nmax
;; => Print out best fit poloidal angles
PRINT,';', soln.THETA*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -57.302635       6.9550463
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -61.019938       6.6308927
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -62.072426       6.8073308
;;-----------------------------------------------------------

;; => Print out best fit azimuthal angles
PRINT,';', soln.PHI*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -72.834532       14.786666
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -57.218571       9.7797018
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -56.627926       11.364395
;;-----------------------------------------------------------

;; => Print out best fit shock normal speed in spacecraft frame [km/s]
PRINT,';', soln.VSHN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      -96.243133       16.726084
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      -100.43044       17.150928
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      -97.953599       17.375158
;;-----------------------------------------------------------

;; => Print out best fit upstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_UP
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;       41.132588       55.614311
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;       6.8460865       41.826377
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;       6.8017881       44.578020
;;-----------------------------------------------------------

;; => Print out best fit downstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_DN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;       7.5803276       13.511627
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;     -0.18332285       10.892555
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;     -0.21537460       11.593458
;;-----------------------------------------------------------

;; => Print out best fit shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,0]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      0.15316353     -0.49549469     -0.83532965
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;      0.25675322     -0.39876772     -0.86899465
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;      0.25074649     -0.38082788     -0.87736110
;;-----------------------------------------------------------

;; => Print out best fit uncertainty in shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,1]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2 and 4 for 2009-09-05 bow shock
;;===========================================================
;;      0.13549802      0.10361750     0.064452185
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-09-05 bow shock
;;===========================================================
;;     0.087478848     0.094672629     0.057403744
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-09-05 bow shock
;;===========================================================
;;     0.095369817      0.10009606     0.056739661
;;-----------------------------------------------------------










































