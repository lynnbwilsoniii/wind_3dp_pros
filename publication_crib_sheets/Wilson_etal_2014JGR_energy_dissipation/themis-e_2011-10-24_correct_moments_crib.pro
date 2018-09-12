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

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Moments ['+tdate[0]+']'

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


;; => Times [1st Shock]
t_foot_se      = time_double(tdate[0]+'/'+['18:31:57.290','18:31:58.000'])
t_ramp_se      = time_double(tdate[0]+'/'+['18:31:56.880','18:31:57.290'])
tr_up          = time_double(tdate[0]+'/'+['18:32:42.300','18:35:08.400'])
tr_dn          = time_double(tdate[0]+'/'+['18:26:17.900','18:29:05.200'])
tr_up2         = time_double(tdate[0]+'/'+['18:32:13.800','18:33:47.800'])
tr_dn2         = time_double(tdate[0]+'/'+['18:30:12.000','18:31:46.000'])

;; => Times [2nd Shock]
t_foot_se      = time_double(tdate[0]+'/'+['23:27:57.200','23:28:14.596'])
t_ramp_se      = time_double(tdate[0]+'/'+['23:28:14.596','23:28:16.086'])
tr_up          = time_double(tdate[0]+'/'+['23:25:59.100','23:27:24.100'])
tr_dn          = time_double(tdate[0]+'/'+['23:32:17.700','23:33:42.700'])
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
dat_i          = peib_df_arr_e
;; Keep only structures between defined time range
trtt           = time_double(tr_mom)
i_time0        = dat_i.TIME
i_time1        = dat_i.END_TIME
good_i         = WHERE(i_time0 GE trtt[0] AND i_time1 LE trtt[1],gdi)
dat_i          = dat_i[good_i]
n_i            = N_ELEMENTS(dat_i)
PRINT,';;', n_i
;;         591


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
;;         591
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
;; => Define overall mask
;;
;;  Start Times
;;
;;  18:31:50-18:31:59  -->  ~500 km/s
;;  18:32:02-18:36:31  -->  ~350 km/s
;;  23:24:23-23:28:13  -->  ~300 km/s
;;  23:28:16-23:28:41  -->  ~350 km/s
;;  23:28:44-23:34:17  -->  ~500 km/s
;;  => ELSE {V_thresh = 750 km/s}
;;----------------------------------------------------------------------------------------
vname_n        = tnames(velname[0]+'_fixed_3')
;;  1st fix Vsw
bind           = [0240L,0242L,0243L,0244L,0245L,0246L,0247L,0248L,0249L,0250L,0251L,0252L,0255L,0256L,0258L,0260L,0261L,0264L,0265L,0266L,0267L,0268L,0269L,0271L,0272L,0273L,0274L,0275L,0278L,0279L,0280L,0281L,0282L,0283L,0284L,0285L,0286L,0287L,0288L,0289L,0290L,0291L,0295L,0296L,0298L,0299L,0300L,0301L,0302L,0303L,0304L,0305L,0306L,0307L,0308L,0309L,0310L,0311L,0312L,0313L,0314L,0315L,0392L,0393L,0394L,0395L,0396L,0400L,0401L,0410L,0412L,0417L,0425L,0435L,0440L,0445L,0450L,0455L,0456L,0457L,0458L,0459L,0460L,0461L,0462L,0463L,0464L,0465L,0466L,0467L,0468L,0469L,0470L,0471L,0472L,0473L,0474L,0475L,0476L,0477L,0478L,0479L,0480L,0481L,0482L,0483L,0484L,0485L,0486L,0487L,0488L,0489L,0490L,0491L,0492L,0493L,0494L,0495L,0496L,0497L,0498L,0499L,0502L,0503L,0504L,0505L,0506L,0507L,0508L,0509L,0510L,0511L,0512L,0513L,0514L,0515L,0517L,0519L,0520L,0521L,0522L,0523L,0524L,0525L,0526L,0527L,0528L,0529L,0530L,0533L,0534L,0535L,0536L,0537L,0538L,0588L,0589L,0590L]
vswx_fix_2     = [ -22.2375, -20.8975, -31.4684, -50.1135, -38.2663, -28.5258, -50.5455, -37.0525, -52.4205, -75.8961, -55.5955, -42.2545, -76.1105, -55.0321, -59.1140, -67.9592, -85.0787, -86.6656,-165.7803,-155.5970,-161.1799,-164.5339,-163.4626,-195.8456,-190.6209,-180.6026,-171.2746,-189.9414,-214.2633,-170.6799,-194.7436,-165.6755,-176.8099,-198.9595,-188.9900,-201.1098,-223.8196,-215.1279,-237.7004,-237.5406,-202.8666,-242.4741,-240.5492,-248.4241,-208.9492,-248.0300,-266.5732,-252.7448,-171.9336,-416.6897,-427.7102,-422.4732,-428.1075,-422.8754,-422.0484,-417.4254,-407.1513,-426.4162,-432.1802,-432.5009,-424.1391,-413.8757,-436.6653,-427.3261,-477.4982,-472.6063,-491.0960,-484.7038,-476.0039,-478.6040,-470.1458,-472.9130,-478.5520,-474.1313,-474.2446,-483.4757,-484.6997,-483.9268,-478.6117,-489.5364,-475.9829,-489.0022,-476.6211,-476.5212,-474.3086,-461.1207,-463.2950,-460.3700,-436.1124,-334.4982,-427.3933,-307.8507,-408.8549,-187.5798,-214.2509, -24.5185, -58.3881, -43.8546,-149.0352, -99.7848,-151.6889,-226.1858,-182.5964,-230.6068,-233.3256,-243.6142,-205.8860,-236.7597, -92.7536,-244.9280,-103.3896,-203.7918,-116.7949,-161.7182,-134.0125, -98.6021,-232.7570,-156.7654,-117.7047,-191.9128,-154.4654,-136.6308,-207.3373,-223.0638,-206.7074,-303.9314,-288.9467,-258.3245,-297.9183,-322.2312,-215.7945,-279.6010,-200.7656,-228.6562,-155.5145,-155.5377,-260.7617,-127.4099,-184.1972,-268.3562,-180.6085,-148.1669,-299.2335,-273.8454,-159.6930,-245.4652,-191.2634,-142.1139,-136.1534, -52.0759,-188.3409,-169.7417,-234.9799,-244.4852,-233.1139,-152.7398,-178.9815,-211.4082]
vswy_fix_2     = [  46.9724,  26.1912,  38.5809,  53.3664,  45.2797,  41.8962,  51.6076,  61.6778,  62.9439,  46.8126,  63.3642,  44.9856,  55.4008,  37.0007,  78.6121,  72.3730,  56.9631,  33.8840,  51.5045,   6.7490,  -8.9045,  21.2955,  35.5348,  46.6580,  40.8718,  29.6296,  27.9715,  50.3532,  55.3636,  35.1002,  78.0601,  33.5034,  28.4720,  39.6544,  30.7890,  17.0280,  82.8311,  36.4749,  71.0691,  -4.6451,  28.3374,  54.0879,  29.8179,  40.7764,  23.3671,  21.4400,  57.9565,  47.4606,  34.9640, -47.2565, -63.9046,  85.1429,  15.6994, -49.1496, -67.6574, -61.3131, -67.0520, -70.6109, -55.8342, -80.1230, -78.3917, -75.9573, -53.7762, -53.2294, 101.7855, 100.5807,  93.0007,  81.9285, 114.4351, 112.4960,  86.0239, 115.5908,  94.9821,  89.8203,  88.7078, 114.8165, 107.1207,  90.9896, 117.2507,  96.1846, 110.1957,  84.7890, 102.0832, 101.6098, 114.0164, 105.4691,  82.2120,  95.7052,  81.9659,  65.5296,  77.4100,  65.0364,  86.9347,  40.5724,  44.6432,  37.1695, 177.2601, 133.4549,  85.9668, 101.7726,  99.1951, 108.7254, 109.0130,  43.6902, 147.1749,  81.8162,  99.4793, 156.3158,  85.2635,  31.9714, 125.1310,  54.4928, 127.4219, 101.3554, 113.3547, 131.5692, 115.1678,  43.8616,  91.0829,  89.3611,  78.7544,  54.3285, 112.2610,  64.3848, 118.4769,  72.4461,  48.8788,  59.6780,  50.6078,  71.2206,  80.6499,  68.0151,  62.0533,  77.9529,  90.3433, 107.1201,  80.3848,  91.9651,  91.5254, 106.6292,  74.5395, 110.3511,  91.2482, 121.9229,  89.4306, 152.5293,  77.1813,  22.0534,  89.2428,  62.8151, 102.6301,  92.4603,  93.7977, 138.5950, 100.5660,  68.0435,  37.7080, 132.0922]
vswz_fix_2     = [  46.1903,  31.5615,  42.5169,  41.2616,  51.2129,  42.3790,  35.0799,  39.3617,  58.5516,  35.7357,  56.3489,  54.7638,  78.4627,  82.2579,  32.6858,  63.5531,  64.8745,  69.1628,  17.9401,  34.3289,  77.8216,  36.6791,  32.6318,  53.4783,  42.7114,  68.1643,  16.4791,  96.8100,  63.2288,  70.7090,  46.1501,  59.2964,  38.2384,  26.5779,  28.3403,  94.0494,  38.0122,   1.1032,   9.2482,  66.9217,  25.6222,  17.8913,  21.3622,  -7.8905,  26.6333,   1.4223,  26.1987, -17.2734, -18.1559,  65.7905,  38.8906,   4.4344, -14.2057,  35.7636,  14.9655,  38.1181,  21.0011,  11.9384,  14.9765,  13.9489,  18.5927,  16.2323,  42.6419,  13.5496,  42.8102,  43.4556,  55.3891,  62.7347,  73.3807,  40.4973,  69.6083,  32.2670,  55.0815,  57.9652,  52.8822,  38.9800,  60.6071,  52.3172,  31.9601,  68.4360,  38.6702,  54.0055,  44.5458,  33.7289,  17.2648,  71.9042,  62.4930,  28.7972,  30.4495,   4.6094,  23.5806, -38.9065,  44.9429,  24.3878, -21.7993,   0.9739, 141.0422,  98.2386, 116.5587, 107.8503,  70.0672,  50.4079,  86.6050,  38.0510,  63.3649,  47.8326, 125.1517,  56.4097,  75.1108,  47.4535,  70.0489,  44.2359,  81.7807,  84.7854,  88.3230, 128.8758, 132.6949,  74.6413,  93.9484,  62.9182,  87.9762,  99.3948, 149.1039,  81.8307, 141.0049,  59.9301,  74.9662,  37.9428,  47.4217,  56.4985,  37.3407,  39.7208, 111.4821, 116.3739,  89.1797,  39.5595, 124.7121,  93.1167, 103.7595,  28.2239,   6.8287,  26.7652,  40.8277,  38.6266,  56.2579,  54.8667,   0.6588, 111.8475,  86.5209, 117.1428, 127.5555, 109.0887, 170.1771,  60.1015,   1.8711,  74.0744,  93.2357, 103.8157]
add_vsw2,dat_igse,vname_n[0],/LEAVE_ALONE
;; Replace the velocities I found by hand
dat_igse[bind].VSW[0] = vswx_fix_2
dat_igse[bind].VSW[1] = vswy_fix_2
dat_igse[bind].VSW[2] = vswz_fix_2
;;  Define masks
v_uv           = 60e1   ;;  = V_uv     [estimated by plotting contours with sun dir.]
v_thresh       = 30e1   ;;  = V_thresh [maximum speed of core]
mask_a300      = remove_uv_and_beam_ions(dat_igse,V_THRESH=v_thresh[0],V_UV=v_uv[0])

v_thresh       = 35e1   ;;  = V_thresh [maximum speed of core]
mask_a350      = remove_uv_and_beam_ions(dat_igse,V_THRESH=v_thresh[0],V_UV=v_uv[0])

v_thresh       = 50e1   ;;  = V_thresh [maximum speed of core]
mask_a500      = remove_uv_and_beam_ions(dat_igse,V_THRESH=v_thresh[0],V_UV=v_uv[0])

v_thresh       = 75e1   ;;  = V_thresh [maximum speed of core]
mask_a750      = remove_uv_and_beam_ions(dat_igse,V_THRESH=v_thresh[0],V_UV=v_uv[0])
;;----------------------------------------------------------------------------------------
;; => Create a dummy copy of spacecraft (SC) frame structures and kill bad data
;;----------------------------------------------------------------------------------------
i_time0        = dat_igse.TIME
i_time1        = dat_igse.END_TIME

tr_bi0         = time_double(tdate[0]+'/'+['18:31:50','18:32:00'])
tr_bi1         = time_double(tdate[0]+'/'+['18:32:02','18:36:32'])
tr_bi2         = time_double(tdate[0]+'/'+['23:24:23','23:28:14'])
tr_bi3         = time_double(tdate[0]+'/'+['23:28:16','23:28:42'])
tr_bi4         = time_double(tdate[0]+'/'+['23:28:44','23:34:18'])

;; Dummy copies of original with masks applied
dummy          = dat_igse
dumm_300       = dat_igse
dumm_350       = dat_igse
dumm_500       = dat_igse
dumm_750       = dat_igse
;; Data [counts]
data_300       = dummy.DATA
data_350       = dummy.DATA
data_500       = dummy.DATA
data_750       = dummy.DATA
;; => apply masks
data_300      *= mask_a300
data_350      *= mask_a350
data_500      *= mask_a500
data_750      *= mask_a750
;; => redefine data in each structure array
dumm_300.DATA  = data_300
dumm_350.DATA  = data_350
dumm_500.DATA  = data_500
dumm_750.DATA  = data_750
;; => Only use these structures when gyrating ions present
bad0           = WHERE(i_time0 GE  tr_bi0[0] AND i_time0 LE  tr_bi0[1], bd0)
bad1           = WHERE(i_time0 GE  tr_bi1[0] AND i_time0 LE  tr_bi1[1], bd1)
bad2           = WHERE(i_time0 GE  tr_bi2[0] AND i_time0 LE  tr_bi2[1], bd2)
bad3           = WHERE(i_time0 GE  tr_bi3[0] AND i_time0 LE  tr_bi3[1], bd3)
bad4           = WHERE(i_time0 GE  tr_bi4[0] AND i_time0 LE  tr_bi4[1], bd4)
PRINT,';;', bd0, bd1, bd2, bd3, bd4
;;           4          90          77           9         111

;; Start by applying default |V| ≤ 750 km/s filter
dummy          = dumm_750
;; Now apply for specific time ranges
IF ( bd0 GT 0) THEN dummy[bad0]  = dumm_500[bad0]
IF ( bd1 GT 0) THEN dummy[bad1]  = dumm_350[bad1]
IF ( bd2 GT 0) THEN dummy[bad2]  = dumm_300[bad2]
IF ( bd3 GT 0) THEN dummy[bad3]  = dumm_350[bad3]
IF ( bd4 GT 0) THEN dummy[bad4]  = dumm_500[bad4]
;; Clean up
DELVAR,dumm_750,dumm_200,dumm_250,dumm_300,dumm_350,dumm_400
DELVAR,data_750,data_200,data_250,data_300,data_350,data_400
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
bind           = [0240L,0242L,0243L,0244L,0245L,0246L,0247L,0248L,0249L,0250L,0251L,0252L,0255L,0256L,0258L,0260L,0261L,0264L,0265L,0266L,0267L,0268L,0269L,0271L,0272L,0273L,0274L,0275L,0278L,0279L,0280L,0281L,0282L,0283L,0284L,0285L,0286L,0287L,0288L,0289L,0290L,0291L,0295L,0296L,0298L,0299L,0300L,0301L,0302L,0303L,0304L,0305L,0306L,0307L,0308L,0309L,0310L,0311L,0312L,0313L,0314L,0315L,0392L,0393L,0394L,0395L,0396L,0400L,0401L,0410L,0412L,0417L,0425L,0435L,0440L,0445L,0450L,0455L,0456L,0457L,0458L,0459L,0460L,0461L,0462L,0463L,0464L,0465L,0466L,0467L,0468L,0469L,0470L,0471L,0472L,0473L,0474L,0475L,0476L,0477L,0478L,0479L,0480L,0481L,0482L,0483L,0484L,0485L,0486L,0487L,0488L,0489L,0490L,0491L,0492L,0493L,0494L,0495L,0496L,0497L,0498L,0499L,0502L,0503L,0504L,0505L,0506L,0507L,0508L,0509L,0510L,0511L,0512L,0513L,0514L,0515L,0517L,0519L,0520L,0521L,0522L,0523L,0524L,0525L,0526L,0527L,0528L,0529L,0530L,0533L,0534L,0535L,0536L,0537L,0538L,0588L,0589L,0590L]
vswx_fix_2     = [ -22.2375, -20.8975, -31.4684, -50.1135, -38.2663, -28.5258, -50.5455, -37.0525, -52.4205, -75.8961, -55.5955, -42.2545, -76.1105, -55.0321, -59.1140, -67.9592, -85.0787, -86.6656,-165.7803,-155.5970,-161.1799,-164.5339,-163.4626,-195.8456,-190.6209,-180.6026,-171.2746,-189.9414,-214.2633,-170.6799,-194.7436,-165.6755,-176.8099,-198.9595,-188.9900,-201.1098,-223.8196,-215.1279,-237.7004,-237.5406,-202.8666,-242.4741,-240.5492,-248.4241,-208.9492,-248.0300,-266.5732,-252.7448,-171.9336,-416.6897,-427.7102,-422.4732,-428.1075,-422.8754,-422.0484,-417.4254,-407.1513,-426.4162,-432.1802,-432.5009,-424.1391,-413.8757,-436.6653,-427.3261,-477.4982,-472.6063,-491.0960,-484.7038,-476.0039,-478.6040,-470.1458,-472.9130,-478.5520,-474.1313,-474.2446,-483.4757,-484.6997,-483.9268,-478.6117,-489.5364,-475.9829,-489.0022,-476.6211,-476.5212,-474.3086,-461.1207,-463.2950,-460.3700,-436.1124,-334.4982,-427.3933,-307.8507,-408.8549,-187.5798,-214.2509, -24.5185, -58.3881, -43.8546,-149.0352, -99.7848,-151.6889,-226.1858,-182.5964,-230.6068,-233.3256,-243.6142,-205.8860,-236.7597, -92.7536,-244.9280,-103.3896,-203.7918,-116.7949,-161.7182,-134.0125, -98.6021,-232.7570,-156.7654,-117.7047,-191.9128,-154.4654,-136.6308,-207.3373,-223.0638,-206.7074,-303.9314,-288.9467,-258.3245,-297.9183,-322.2312,-215.7945,-279.6010,-200.7656,-228.6562,-155.5145,-155.5377,-260.7617,-127.4099,-184.1972,-268.3562,-180.6085,-148.1669,-299.2335,-273.8454,-159.6930,-245.4652,-191.2634,-142.1139,-136.1534, -52.0759,-188.3409,-169.7417,-234.9799,-244.4852,-233.1139,-152.7398,-178.9815,-211.4082]
vswy_fix_2     = [  46.9724,  26.1912,  38.5809,  53.3664,  45.2797,  41.8962,  51.6076,  61.6778,  62.9439,  46.8126,  63.3642,  44.9856,  55.4008,  37.0007,  78.6121,  72.3730,  56.9631,  33.8840,  51.5045,   6.7490,  -8.9045,  21.2955,  35.5348,  46.6580,  40.8718,  29.6296,  27.9715,  50.3532,  55.3636,  35.1002,  78.0601,  33.5034,  28.4720,  39.6544,  30.7890,  17.0280,  82.8311,  36.4749,  71.0691,  -4.6451,  28.3374,  54.0879,  29.8179,  40.7764,  23.3671,  21.4400,  57.9565,  47.4606,  34.9640, -47.2565, -63.9046,  85.1429,  15.6994, -49.1496, -67.6574, -61.3131, -67.0520, -70.6109, -55.8342, -80.1230, -78.3917, -75.9573, -53.7762, -53.2294, 101.7855, 100.5807,  93.0007,  81.9285, 114.4351, 112.4960,  86.0239, 115.5908,  94.9821,  89.8203,  88.7078, 114.8165, 107.1207,  90.9896, 117.2507,  96.1846, 110.1957,  84.7890, 102.0832, 101.6098, 114.0164, 105.4691,  82.2120,  95.7052,  81.9659,  65.5296,  77.4100,  65.0364,  86.9347,  40.5724,  44.6432,  37.1695, 177.2601, 133.4549,  85.9668, 101.7726,  99.1951, 108.7254, 109.0130,  43.6902, 147.1749,  81.8162,  99.4793, 156.3158,  85.2635,  31.9714, 125.1310,  54.4928, 127.4219, 101.3554, 113.3547, 131.5692, 115.1678,  43.8616,  91.0829,  89.3611,  78.7544,  54.3285, 112.2610,  64.3848, 118.4769,  72.4461,  48.8788,  59.6780,  50.6078,  71.2206,  80.6499,  68.0151,  62.0533,  77.9529,  90.3433, 107.1201,  80.3848,  91.9651,  91.5254, 106.6292,  74.5395, 110.3511,  91.2482, 121.9229,  89.4306, 152.5293,  77.1813,  22.0534,  89.2428,  62.8151, 102.6301,  92.4603,  93.7977, 138.5950, 100.5660,  68.0435,  37.7080, 132.0922]
vswz_fix_2     = [  46.1903,  31.5615,  42.5169,  41.2616,  51.2129,  42.3790,  35.0799,  39.3617,  58.5516,  35.7357,  56.3489,  54.7638,  78.4627,  82.2579,  32.6858,  63.5531,  64.8745,  69.1628,  17.9401,  34.3289,  77.8216,  36.6791,  32.6318,  53.4783,  42.7114,  68.1643,  16.4791,  96.8100,  63.2288,  70.7090,  46.1501,  59.2964,  38.2384,  26.5779,  28.3403,  94.0494,  38.0122,   1.1032,   9.2482,  66.9217,  25.6222,  17.8913,  21.3622,  -7.8905,  26.6333,   1.4223,  26.1987, -17.2734, -18.1559,  65.7905,  38.8906,   4.4344, -14.2057,  35.7636,  14.9655,  38.1181,  21.0011,  11.9384,  14.9765,  13.9489,  18.5927,  16.2323,  42.6419,  13.5496,  42.8102,  43.4556,  55.3891,  62.7347,  73.3807,  40.4973,  69.6083,  32.2670,  55.0815,  57.9652,  52.8822,  38.9800,  60.6071,  52.3172,  31.9601,  68.4360,  38.6702,  54.0055,  44.5458,  33.7289,  17.2648,  71.9042,  62.4930,  28.7972,  30.4495,   4.6094,  23.5806, -38.9065,  44.9429,  24.3878, -21.7993,   0.9739, 141.0422,  98.2386, 116.5587, 107.8503,  70.0672,  50.4079,  86.6050,  38.0510,  63.3649,  47.8326, 125.1517,  56.4097,  75.1108,  47.4535,  70.0489,  44.2359,  81.7807,  84.7854,  88.3230, 128.8758, 132.6949,  74.6413,  93.9484,  62.9182,  87.9762,  99.3948, 149.1039,  81.8307, 141.0049,  59.9301,  74.9662,  37.9428,  47.4217,  56.4985,  37.3407,  39.7208, 111.4821, 116.3739,  89.1797,  39.5595, 124.7121,  93.1167, 103.7595,  28.2239,   6.8287,  26.7652,  40.8277,  38.6266,  56.2579,  54.8667,   0.6588, 111.8475,  86.5209, 117.1428, 127.5555, 109.0887, 170.1771,  60.1015,   1.8711,  74.0744,  93.2357, 103.8157]
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

store_data,vname_n[0]+'_2',DATA=vnew_str,DLIM=dlim,LIM=lim
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
probe          = 'e'
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




;;----------------------------------------------------------------------------------------
;; => Save ESA DF IDL Data Structures
;;----------------------------------------------------------------------------------------
;;  Burst
peeb_df_arr_e  = *(poynter_peebf.BURST)[0]
peib_dfarr_e0  = *(poynter_peibf.BURST)[0]
peib_dfarr_e1  = *(poynter_peibf.BURST)[1]
peib_df_arr_e  = [peib_dfarr_e0,peib_dfarr_e1]
;;  Sort by time
sp             = SORT(peeb_df_arr_e.TIME)
peeb_df_arr_e  = peeb_df_arr_e[sp]
sp             = SORT(peib_df_arr_e.TIME)
peib_df_arr_e  = peib_df_arr_e[sp]


enames         = 'EESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames         = 'IESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
SAVE,peeb_df_arr_e,FILENAME=enames[0]
SAVE,peib_df_arr_e,FILENAME=inames[0]



















































































































































































