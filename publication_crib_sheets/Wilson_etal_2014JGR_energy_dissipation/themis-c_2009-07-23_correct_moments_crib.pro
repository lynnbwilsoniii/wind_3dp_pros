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
velname        = pref[0]+'peib_velocity_'+coord[0]
magname        = pref[0]+'fgh_'+coord[0]
fgmnm          = pref[0]+'fgh_'+['mag',coord[0]]
tr_jj          = time_double(tdate[0]+'/'+['17:57:30','18:30:00'])

tplot,fgmnm,TRANGE=tr_jj
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
dat_i     = peib_df_arr_c
;; Keep only structures between defined time range
trtt      = time_double(tr_00)
i_time0   = dat_i.TIME
i_time1   = dat_i.END_TIME
good_i    = WHERE(i_time0 GE trtt[0] AND i_time1 LE trtt[1],gdi)
dat_i     = peib_df_arr_c[good_i]
n_i       = N_ELEMENTS(dat_i)
PRINT,';;', n_i
;;        1352


RESTORE,efiles[0]
;; => Redefine structures
dat_e     = peeb_df_arr_c
;; Keep only structures between defined time range
trtt      = time_double(tr_00)
e_time0   = dat_e.TIME
e_time1   = dat_e.END_TIME
good_e    = WHERE(e_time0 GE trtt[0] AND e_time1 LE trtt[1],gde)
dat_e     = peeb_df_arr_c[good_e]

n_e       = N_ELEMENTS(dat_e)
PRINT,';;', n_e
;;        1354
;;----------------------------------------------------------------------------------------
;; => Modify structures so they work in my plotting routines
;;----------------------------------------------------------------------------------------
coord          = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
velname        = pref[0]+'peib_velocity_'+coord[0]
vname_n        = velname[0]+'_fixed_3'
magname        = pref[0]+'fgh_'+coord[0]
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
magn_1         = pref[0]+'fgl_'+coord[0]
magn_2         = pref[0]+'fgh_'+coord[0]
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
magn_1         = pref[0]+'fgl_'+coord[0]
magn_2         = pref[0]+'fgh_'+coord[0]
add_magf2,dat_egse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_egse,magn_2[0],/LEAVE_ALONE
;; make sure VSW tag is defined
add_vsw2,dat_egse,velname[0],/LEAVE_ALONE
add_vsw2,dat_egse,vname_n[0],/LEAVE_ALONE
;;----------------------------------------------------------------------------------------
;; => Define time ranges with suspect ion moments
;;
;; Ion DFs contain secondary species [e.g., gyrating ions] between:
;;----------------------------------------------------------------------------------------
tr_bad_0       = time_double(tdate[0]+'/'+['18:04:30','18:07:30'])
tr_bad_1       = time_double(tdate[0]+'/'+['18:22:30','18:29:45'])
;;----------------------------------------------------------------------------------------
;; => Define overall mask
;;
;;  Start Times
;;
;;  18:04:37-18:04:58  -->  ~300 km/s
;;  18:05:04-18:07:04  -->  ~400 km/s
;;  18:24:34-18:24:43  -->  ~250 km/s
;;  18:24:46-18:29:42  -->  ~300 km/s
;;  => ELSE {V_thresh = 750 km/s}
;;----------------------------------------------------------------------------------------
v_uv           = 60e1   ;;  = V_uv     [estimated by plotting contours with sun dir.]
v_thresh       = 25e1   ;;  = V_thresh [maximum speed of core]
mask_a250      = remove_uv_and_beam_ions(dat_igse,V_THRESH=v_thresh[0],V_UV=v_uv[0])

v_thresh       = 30e1   ;;  = V_thresh [maximum speed of core]
mask_a300      = remove_uv_and_beam_ions(dat_igse,V_THRESH=v_thresh[0],V_UV=v_uv[0])

v_thresh       = 40e1   ;;  = V_thresh [maximum speed of core]
mask_a400      = remove_uv_and_beam_ions(dat_igse,V_THRESH=v_thresh[0],V_UV=v_uv[0])

v_thresh       = 75e1   ;;  = V_thresh [maximum speed of core]
mask_a750      = remove_uv_and_beam_ions(dat_igse,V_THRESH=v_thresh[0],V_UV=v_uv[0])
;;----------------------------------------------------------------------------------------
;; => Create a dummy copy of spacecraft (SC) frame structures and kill bad data
;;----------------------------------------------------------------------------------------
i_time0        = dat_igse.TIME
i_time1        = dat_igse.END_TIME

tr_bi0         = time_double(tdate[0]+'/'+['18:04:37','18:04:59'])
tr_bi1         = time_double(tdate[0]+'/'+['18:05:04','18:07:05'])
tr_bi2         = time_double(tdate[0]+'/'+['18:24:34','18:24:44'])
tr_bi3         = time_double(tdate[0]+'/'+['18:24:46','18:29:42'])

;; Dummy copies of original with masks applied
dummy          = dat_igse
dumm_250       = dat_igse
dumm_300       = dat_igse
dumm_400       = dat_igse
dumm_750       = dat_igse
;; Data [counts]
data_250       = dummy.DATA
data_300       = dummy.DATA
data_400       = dummy.DATA
data_750       = dummy.DATA
;; => apply masks
data_250      *= mask_a250
data_300      *= mask_a300
data_400      *= mask_a400
data_750      *= mask_a750
;; => redefine data in each structure array
dumm_250.DATA  = data_250
dumm_300.DATA  = data_300
dumm_400.DATA  = data_400
dumm_750.DATA  = data_750

;; => Only use these structures when gyrating ions present
bad0           = WHERE(i_time0 GE tr_bi0[0] AND i_time0 LE tr_bi0[1],bd0)
bad1           = WHERE(i_time0 GE tr_bi1[0] AND i_time0 LE tr_bi1[1],bd1)
bad2           = WHERE(i_time0 GE tr_bi2[0] AND i_time0 LE tr_bi2[1],bd2)
bad3           = WHERE(i_time0 GE tr_bi3[0] AND i_time0 LE tr_bi3[1],bd3)
PRINT,';;', bd0, bd1, bd2, bd3
;;           8          41           4          99

;; Start by applying default |V| ≤ 750 km/s filter
dummy          = dumm_750
;; Now apply for specific time ranges
IF (bd0 GT 0) THEN dummy[bad0] = dumm_300[bad0]
IF (bd1 GT 0) THEN dummy[bad1] = dumm_400[bad1]
IF (bd2 GT 0) THEN dummy[bad2] = dumm_250[bad2]
IF (bd3 GT 0) THEN dummy[bad3] = dumm_300[bad3]
;; Clean up
DELVAR,dumm_750,dumm_200,dumm_250,dumm_500
DELVAR,data_750,data_200,data_250,data_500
;;----------------------------------------------------------------------------------------
;;  Calculate moments [just core]
;;----------------------------------------------------------------------------------------
tp_hand0       = ['T_avg','V_Therm','N','Velocity','Tpara','Tperp','Tanisotropy','Pressure']
xsuff          = ''
v_units        = ' (km/s)'
t_units        = ' (eV)'
p_units        = ' (eV/cm!U3!N'+')'
d_units        = ' (#/cm!U3!N'+')'
t_pref         = ['T!D','!N'+t_units]
v_pref         = ['V!D','!N'+v_units]
p_pref         = ['P!D','!N'+p_units]
d_pref         = ['N!D','!N'+d_units]
t_ttle         = t_pref[0]+xsuff+t_pref[1]
vv_ttle        = v_pref[0]+xsuff+v_pref[1]
vt_ttle        = v_pref[0]+'T'+xsuff+v_pref[1]
den_ttle       = d_pref[0]+xsuff+d_pref[1]
tpa_ttle       = t_pref[0]+'!9#!3'+xsuff+t_pref[1]
tpe_ttle       = t_pref[0]+'!9x!3'+xsuff+t_pref[1]
pre_ttle       = p_pref[0]+xsuff+p_pref[1]
tan_ttle       = t_pref[0]+'!9x!3'+xsuff+'!N'+'/'+t_pref[0]+'!9#!3'+xsuff+'!N'
tp_ttles       = [t_ttle,vt_ttle,den_ttle,vv_ttle,tpa_ttle,tpe_ttle,tan_ttle,pre_ttle]
;;----------------------------------------------------
;;----------------------------------------------------
sform          = moments_3du()
str_element,sform,'END_TIME',0d0,/ADD_REPLACE
dumb           = REPLICATE(sform[0],n_i)
FOR j=0L, n_i - 1L DO BEGIN                                             $
  del     = dummy[j]                                                  & $
  pot     = del[0].SC_POT                                             & $
  tmagf   = REFORM(del[0].MAGF)                                       & $
  tmoms   = moments_3du(del,FORMAT=sform,SC_POT=pot[0],MAGDIR=tmagf)  & $
  str_element,tmoms,'END_TIME',del[0].END_TIME,/ADD_REPLACE           & $
  dumb[j] = tmoms[0]

; => Define relevant quantities
p_els          = [0L,4L,8L]                 ; => Diagonal elements of a 3x3 matrix
avgtemp        = REFORM(dumb.AVGTEMP)       ; => Avg. Particle Temp (eV)
v_therm        = REFORM(dumb.VTHERMAL)      ; => Avg. Particle Thermal Speed (km/s)
tempvec        = TRANSPOSE(dumb.MAGT3)      ; => Vector Temp [perp1,perp2,para] (eV)
velocity       = TRANSPOSE(dumb.VELOCITY)   ; => Velocity vectors (km/s)
p_tensor       = TRANSPOSE(dumb.PTENS)      ; => Pressure tensor [eV cm^(-3)]
density        = REFORM(dumb.DENSITY)       ; => Particle density [# cm^(-3)]

t_perp         = 5e-1*(tempvec[*,0] + tempvec[*,1])
t_para         = REFORM(tempvec[*,2])
tanis          = t_perp/t_para
pressure       = TOTAL(p_tensor[*,p_els],2,/NAN)/3.
i_moments      = dumb

tp_hands       = pref[0]+tp_hand0+'_peib_no_GIs_UV'
scup           = STRUPCASE(sc[0])
ysubs          = '[TH-'+scup[0]+', IESA Burst]'+'!C'+'[Corrected]'
;; => Define dummy structure with data quantities
times          = (i_moments.TIME + i_moments.END_TIME)/2d0
dstr           = CREATE_STRUCT(tp_hands,avgtemp,v_therm,density,velocity,t_para,t_perp,$
                               tanis,pressure)
FOR j=0L, N_ELEMENTS(tp_hands) - 1L DO BEGIN                                $
  dat_0  = dstr.(j)                                                       & $
  store_data,tp_hands[j],DATA={X:times,Y:dat_0}                           & $
  options,tp_hands[j],'YTITLE',tp_ttles[j],/DEF                           & $
  options,tp_hands[j],'YSUBTITLE',ysubs[0],/DEF                           & $
  IF (tp_hand0[j] EQ 'Velocity') THEN gcols = 1 ELSE gcols = 0            & $
  IF (gcols) THEN options,tp_hands[j],'COLORS',[250L,150L,50L],/DEF

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01


velnm0         = pref[0]+'Velocity_peib_no_GIs_UV'
vname_n        = tnames(velnm0[0])
get_data,vname_n[0],DATA=ti_vsw,DLIM=dlim,LIM=lim
velocity       = ti_vsw.Y
;; Replace the velocities I found by hand
bind           = [0888L,0889L,0890L,0891L,0892L,0893L,0894L,0895L,0896L,0897L,0898L,0899L,0900L,0901L,0902L,0903L,0904L,0905L,0906L,0907L,0908L,0909L,0910L,0912L,0913L,0914L,0932L,0933L,0934L,0935L,0936L,0937L,0938L,0939L,0940L,0941L,0942L,0943L,0944L,0945L,0946L,0947L,0948L,1226L,1227L,1228L,1229L,1230L,1231L,1232L,1233L,1234L,1235L,1236L,1237L,1238L,1239L,1240L,1241L,1242L,1243L,1244L,1245L,1246L,1247L,1248L,1249L,1250L,1251L,1252L,1253L,1254L,1255L,1256L,1257L,1258L,1259L,1260L,1261L,1262L,1263L,1264L,1265L,1266L,1267L,1268L,1269L,1270L,1271L,1272L,1273L,1274L,1275L,1276L,1277L,1278L,1279L,1280L,1281L,1282L,1283L,1284L,1285L,1286L,1287L,1288L,1289L,1290L,1291L,1292L,1293L,1294L,1295L,1296L,1297L,1298L,1299L,1300L,1301L,1302L,1303L,1347L,1348L,1349L,1350L,1351L]
vswx_fix_2     = [-163.4660d0,   6.6793d0,-136.6288d0, -38.2706d0, -35.7126d0, -40.3469d0,-170.1354d0,-117.3885d0,-249.5415d0,-322.9148d0,-376.3583d0,-370.4772d0,-405.1876d0,-421.8609d0,-436.8770d0,-473.0652d0,-460.2977d0,-453.3601d0,-463.6375d0,-474.1777d0,-444.7398d0,-460.3014d0,-474.2829d0,-438.4265d0,-466.4189d0,-458.3333d0,-440.3295d0,-449.6929d0,-467.9083d0,-472.9339d0,-453.3421d0,-381.0065d0,-378.6855d0,-390.9757d0,-260.8448d0,-227.4573d0,-123.2987d0, -87.7573d0, -72.8541d0,-208.0114d0,-159.1860d0,-165.3393d0,-217.3748d0, -72.3670d0, -33.7777d0, -93.8189d0, -77.1908d0, -85.4950d0, -75.0680d0,-154.8044d0,-169.6077d0, -99.2970d0, -84.0972d0, -44.0003d0,-119.4290d0, -39.1548d0,  30.6797d0, -14.0705d0, -79.1394d0, -71.1532d0, -44.8545d0, -96.1485d0,-104.1356d0,-262.1887d0, -85.8964d0, -21.6065d0,-228.5681d0,-282.4290d0,-323.0959d0,-419.5569d0,-403.7578d0,-410.9563d0,-402.7877d0,-405.3104d0,-423.2826d0,-416.3961d0,-422.2570d0,-437.2900d0,-440.8390d0,-432.3517d0,-420.8497d0,-422.8370d0,-426.0029d0,-428.6529d0,-447.1267d0,-425.1146d0,-428.5486d0,-424.6603d0,-435.0846d0,-428.6574d0,-433.5827d0,-434.7744d0,-429.1674d0,-453.7024d0,-439.6152d0,-439.4703d0,-440.0347d0,-443.5101d0,-441.4425d0,-434.8939d0,-422.0971d0,-450.7509d0,-440.4606d0,-436.9511d0,-437.0033d0,-438.6399d0,-442.9345d0,-435.7210d0,-438.1794d0,-440.9129d0,-422.9924d0,-425.1782d0,-437.8309d0,-429.8473d0,-436.8322d0,-442.9632d0,-431.9973d0,-432.8677d0,-444.1331d0,-437.1586d0,-438.1105d0,-432.2922d0,-440.9523d0,-442.9475d0,-434.8033d0,-436.4508d0]
vswy_fix_2     = [ 111.9800d0,  63.8980d0, 239.5643d0, -42.7277d0, -45.6354d0, 174.8074d0, -72.9110d0, -17.7304d0, -16.5145d0,  14.6646d0,  31.0941d0,  59.9650d0,  72.2718d0,  66.0320d0,  95.5301d0, 105.5096d0, 115.2420d0,  46.7660d0, 111.4266d0, 123.6205d0, 115.0842d0,  82.4722d0,  91.6058d0,  60.0384d0, 108.0344d0, 109.8179d0, 126.6018d0, 116.4382d0,  33.0856d0, 124.8386d0,  96.1732d0,  49.6304d0,  78.4481d0,  71.8660d0, -34.8423d0, -50.6626d0,  46.0667d0, -17.8751d0, 189.9357d0,  54.8319d0, 121.6696d0,  57.3961d0, 136.3154d0,   4.6754d0, 132.4188d0, 128.4540d0, 141.1775d0,  72.3997d0, 105.7314d0, 142.5353d0, 124.6608d0, 107.5588d0, 134.6652d0,  39.8330d0, 176.2429d0, 152.0257d0, 123.7852d0,  92.8575d0, 110.7836d0, 120.9467d0,  98.4177d0, 147.2862d0, 168.5365d0, 125.4006d0,  50.9072d0,  53.2675d0, 123.8716d0, 175.2347d0,  83.8121d0,  86.5681d0,  65.4858d0,  83.3804d0,  60.9515d0,  56.1113d0,  91.1213d0,  94.8702d0, 107.4990d0,  67.1256d0,  73.6455d0, 106.4560d0,  93.7392d0,  83.4850d0,  71.8355d0,  73.8381d0,  79.9645d0,  85.6601d0,  86.6841d0,  94.1752d0,  93.4352d0, 104.6544d0,  87.4862d0,  62.2817d0,  89.3804d0,  88.3895d0,  74.4230d0,  97.1497d0,  95.5926d0,  83.7089d0,  74.7806d0,  64.2740d0,  85.1699d0,  56.6713d0,  78.0851d0,  72.3932d0,  58.2117d0,  78.7623d0,  55.3100d0,  67.1844d0,  60.4653d0,  78.0520d0,  72.4093d0,  81.7174d0,  59.8902d0,  79.9118d0,  69.9267d0,  53.0109d0,  88.7578d0,  84.0798d0,  56.4361d0,  64.9075d0,  93.0502d0,  57.7370d0,  85.6789d0,  70.6653d0,  75.8301d0,  87.0278d0]
vswz_fix_2     = [   0.0070d0,  -5.8361d0, -71.1807d0,-161.1892d0,-125.0879d0, -44.2822d0,-104.4756d0, -38.1324d0, -84.9812d0, -85.0704d0,-115.9322d0,-122.4874d0,-119.3136d0,-115.6004d0,-142.6314d0,-126.8562d0,-139.8744d0,-153.4724d0,-133.2068d0,-161.3383d0,-147.5120d0,-154.3517d0,-156.2576d0,-137.4112d0,-160.6223d0,-147.8088d0,-133.1704d0,-120.1089d0,-134.1035d0,-119.0361d0,-104.9708d0,-118.2507d0,-133.1215d0,-126.9042d0,   8.9681d0,-155.3561d0,-127.4646d0, -77.0064d0,-134.2513d0, -17.2869d0, -79.3997d0, -12.0358d0, -98.6835d0,   0.5720d0, -10.9507d0,  19.2695d0,   7.9164d0,  28.0740d0,  40.6170d0,  48.9530d0,  -4.3944d0,   4.8919d0,  -9.3083d0,-139.8530d0,  32.4255d0,  10.1481d0,  38.4775d0,  -9.5656d0,  82.4499d0,  62.4801d0,-106.8045d0,  76.6523d0,  15.3678d0, 120.4923d0,  32.3367d0,  52.4165d0, 142.5170d0,  23.2863d0,  17.6350d0,  52.3921d0,  30.0682d0,   7.7552d0,  31.8403d0,  37.5952d0,  51.9739d0,  56.4717d0,  36.4712d0,  33.8434d0,   9.3032d0,  57.2255d0,   4.9270d0,  -2.3467d0,  16.9062d0,   4.2001d0,  35.4002d0,   2.3427d0,  21.0483d0,  16.8172d0,  45.9158d0,  53.8036d0,  59.6488d0,  16.6749d0,   0.0858d0,  41.9192d0,  16.3448d0,  60.2746d0,  69.6927d0,  41.4890d0,  23.4414d0,  52.5316d0,  71.0919d0,  -3.5552d0,  46.6715d0,  38.4032d0,  16.7491d0,  60.4129d0,  22.3138d0,  18.4967d0,  14.6313d0,  37.2074d0,  -4.5629d0,   7.6037d0,  14.7280d0,  12.2227d0,  51.6573d0,  12.2455d0,  24.3325d0,   4.9964d0,  13.3960d0,  10.2725d0,  56.9355d0,  10.8624d0,  57.0375d0,  52.1214d0,  57.4309d0,  60.3245d0]
velocity[bind,0] = vswx_fix_2
velocity[bind,1] = vswy_fix_2
velocity[bind,2] = vswz_fix_2
;;  Define time at center of IESA distributions
tt0            = ti_vsw.X
vnew_str       = {X:tt0,Y:velocity}                             ;; TPLOT structure
sc             = probe[0]
scu            = STRUPCASE(sc[0])
yttl           = 'V!Dbulk!N [TH'+scu[0]+', km/s, '+STRUPCASE(coord[0])+']'  ;; Y-Axis title
ysubt          = '[Corrected, Core]'                   ;; Y-Axix subtitle

store_data,vname_n[0]+'_2',DATA=vnew_str
;;  Define plot options for new variable
options,vname_n[0]+'_2','COLORS',[250,150, 50],/DEF
options,vname_n[0]+'_2','LABELS',['x','y','z'],/DEF
options,vname_n[0]+'_2','YTITLE',yttl[0],/DEF
options,vname_n[0]+'_2','YSUBTITLE',ysubt[0],/DEF

;;  Set my default plot options for all TPLOT handles
nnw            = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01





































































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
















