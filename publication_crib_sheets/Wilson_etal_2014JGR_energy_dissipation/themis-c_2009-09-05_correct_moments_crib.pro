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
;;         582



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
;;         582

;;----------------------------------------------------------------------------------------
;; => Modify structures so they work in my plotting routines
;;----------------------------------------------------------------------------------------
coord_gse      = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
velname        = pref[0]+'peib_velocity_'+coord_gse[0]
vname_n        = velname[0]+'_fixed_3'
magname        = pref[0]+'fgh_'+coord_gse[0]            ;;  Use fgl to cover full time range
spperi         = pref[0]+'state_spinper'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
scnamei        = tnames(pref[0]+'peib_sc_pot')
scnamee        = tnames(pref[0]+'peeb_sc_pot')

modify_themis_esa_struc,dat_i
;; add SC potential to structures
add_scpot,dat_i,scnamei[0]
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
add_scpot,dat_e,scnamee[0]
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
;;----------------------------------------------------------------------------------------
;;  Define masks
;;
;;  Start Times
;;
;;  16:07:10-16:10:50  -->  ~250 km/s
;;  16:10:51-16:11:21  -->  ~750 km/s
;;  16:11:22-16:11:33  -->  ~500 km/s
;;  16:11:34-16:17:12  -->  ~250 km/s
;;  16:31:02-16:31:20  -->  ~750 km/s
;;  16:31:21-16:32:28  -->  ~500 km/s
;;  16:32:29-16:33:21  -->  ~750 km/s
;;  16:33:22-16:33:33  -->  ~500 km/s
;;  16:33:35-16:37:54  -->  ~750 km/s
;;  16:37:56-16:47:45  -->  ~250 km/s
;;  16:47:46-16:48:50  -->  ~750 km/s
;;  16:48:51-16:48:59  -->  ~500 km/s
;;  16:49:00-16:49:49  -->  ~300 km/s
;;  16:49:50-16:50:32  -->  ~750 km/s
;;  16:50:33-16:54:28  -->  ~250 km/s
;;  16:54:30-16:54:47  -->  ~500 km/s
;;  16:54:48-16:55:50  -->  ~750 km/s
;;  => ELSE {V_thresh = 750 km/s}
;;----------------------------------------------------------------------------------------
vsm            = 5L
sm_vstr        = STRTRIM(STRING(vsm[0],FORMAT='(I2.2)'),2)
vname_n5       = velname[0]+'_fixed_sm'+sm_vstr[0]+'pts'
vname_n5_fixed = vname_n5[0]+'_3'

dat_copy       = dat_igse
add_vsw2,dat_copy,vname_n5_fixed[0],/LEAVE_ALONE
;;  Replace the velocities I found by hand
dat_copy[bind].VSW[0] = vswx_fix_2
dat_copy[bind].VSW[1] = vswy_fix_2
dat_copy[bind].VSW[2] = vswz_fix_2


v_uv           = 60e1   ;;  = V_uv     [estimated by plotting contours with sun dir.]
v_thresh       = 25e1   ;;  = V_thresh [maximum speed of core]
mask_a250      = remove_uv_and_beam_ions(dat_copy,V_THRESH=v_thresh[0],V_UV=v_uv[0])

v_thresh       = 30e1   ;;  = V_thresh [maximum speed of core]
mask_a300      = remove_uv_and_beam_ions(dat_copy,V_THRESH=v_thresh[0],V_UV=v_uv[0])

v_thresh       = 50e1   ;;  = V_thresh [maximum speed of core in SWF]
mask_a500      = remove_uv_and_beam_ions(dat_copy,V_THRESH=v_thresh[0],V_UV=v_uv[0])

v_thresh       = 75e1   ;;  = V_thresh [maximum speed of core]
mask_a750      = remove_uv_and_beam_ions(dat_copy,V_THRESH=v_thresh[0],V_UV=v_uv[0])
;;----------------------------------------------------------------------------------------
;; => Create a dummy copy of spacecraft (SC) frame structures
;;----------------------------------------------------------------------------------------
;; Dummy copies of original with masks applied
dummy          = dat_copy
dumm_250       = dat_copy
dumm_300       = dat_copy
dumm_500       = dat_copy
dumm_750       = dat_copy
;; Data [counts]
data_250       = dummy.DATA
data_300       = dummy.DATA
data_500       = dummy.DATA
data_750       = dummy.DATA
;; => apply masks
data_250      *= mask_a250
data_300      *= mask_a300
data_500      *= mask_a500
data_750      *= mask_a750
;; => redefine data in each structure array
dumm_250.DATA  = data_250
dumm_300.DATA  = data_300
dumm_500.DATA  = data_500
dumm_750.DATA  = data_750
;;----------------------------------------------------------------------------------------
;; => Kill bad data
;;----------------------------------------------------------------------------------------
i_time0        = dat_copy.TIME
i_time1        = dat_copy.END_TIME
t_iesa         = (i_time0 + i_time1)/2d0

;;  Define mask time ranges
tr__bi0        = time_double(tdate[0]+'/'+['16:07:10','16:10:50'])
tr__bi1        = time_double(tdate[0]+'/'+['16:10:51','16:11:21'])
tr__bi2        = time_double(tdate[0]+'/'+['16:11:22','16:11:33'])
tr__bi3        = time_double(tdate[0]+'/'+['16:11:34','16:17:12'])
tr__bi4        = time_double(tdate[0]+'/'+['16:31:02','16:31:20'])
tr__bi5        = time_double(tdate[0]+'/'+['16:31:21','16:32:28'])
tr__bi6        = time_double(tdate[0]+'/'+['16:32:29','16:33:21'])
tr__bi7        = time_double(tdate[0]+'/'+['16:33:22','16:33:33'])
tr__bi8        = time_double(tdate[0]+'/'+['16:33:35','16:37:54'])
tr__bi9        = time_double(tdate[0]+'/'+['16:37:56','16:47:45'])
tr_bi10        = time_double(tdate[0]+'/'+['16:47:46','16:48:50'])
tr_bi11        = time_double(tdate[0]+'/'+['16:48:51','16:48:59'])
tr_bi12        = time_double(tdate[0]+'/'+['16:49:00','16:49:49'])
tr_bi13        = time_double(tdate[0]+'/'+['16:49:50','16:50:32'])
tr_bi14        = time_double(tdate[0]+'/'+['16:50:33','16:54:28'])
tr_bi15        = time_double(tdate[0]+'/'+['16:54:30','16:54:47'])
tr_bi16        = time_double(tdate[0]+'/'+['16:54:48','16:55:50'])
;;  Determine corresponding elements
bad0           = WHERE(i_time0 GE  tr__bi0[0] AND i_time0 LE  tr__bi0[1], bd0)
bad1           = WHERE(i_time0 GE  tr__bi1[0] AND i_time0 LE  tr__bi1[1], bd1)
bad2           = WHERE(i_time0 GE  tr__bi2[0] AND i_time0 LE  tr__bi2[1], bd2)
bad3           = WHERE(i_time0 GE  tr__bi3[0] AND i_time0 LE  tr__bi3[1], bd3)
bad4           = WHERE(i_time0 GE  tr__bi4[0] AND i_time0 LE  tr__bi4[1], bd4)
bad5           = WHERE(i_time0 GE  tr__bi5[0] AND i_time0 LE  tr__bi5[1], bd5)
bad6           = WHERE(i_time0 GE  tr__bi6[0] AND i_time0 LE  tr__bi6[1], bd6)
bad7           = WHERE(i_time0 GE  tr__bi7[0] AND i_time0 LE  tr__bi7[1], bd7)
bad8           = WHERE(i_time0 GE  tr__bi8[0] AND i_time0 LE  tr__bi8[1], bd8)
bad9           = WHERE(i_time0 GE  tr__bi9[0] AND i_time0 LE  tr__bi9[1], bd9)
bad10          = WHERE(i_time0 GE  tr_bi10[0] AND i_time0 LE  tr_bi10[1], bd10)
bad11          = WHERE(i_time0 GE  tr_bi11[0] AND i_time0 LE  tr_bi11[1], bd11)
bad12          = WHERE(i_time0 GE  tr_bi12[0] AND i_time0 LE  tr_bi12[1], bd12)
bad13          = WHERE(i_time0 GE  tr_bi13[0] AND i_time0 LE  tr_bi13[1], bd13)
bad14          = WHERE(i_time0 GE  tr_bi14[0] AND i_time0 LE  tr_bi14[1], bd14)
bad15          = WHERE(i_time0 GE  tr_bi15[0] AND i_time0 LE  tr_bi15[1], bd15)
bad16          = WHERE(i_time0 GE  tr_bi16[0] AND i_time0 LE  tr_bi16[1], bd16)
PRINT,';;', bd0, bd1, bd2, bd3, bd4, bd5, bd6, bd7, bd8, bd9
PRINT,';;', bd10, bd11, bd12, bd13, bd14, bd15, bd16
;;          71          10           4         109           6          22          17           4          84         101
;;          21           3          16          14          76           6          18

;; Start by applying default |V| ≤ 750 km/s filter
dummy          = dumm_750
;; Now apply for specific time ranges
IF ( bd0  GT 0) THEN dummy[bad0]  = dumm_250[bad0]
IF ( bd1  GT 0) THEN dummy[bad1]  = dumm_750[bad1]
IF ( bd2  GT 0) THEN dummy[bad2]  = dumm_500[bad2]
IF ( bd3  GT 0) THEN dummy[bad3]  = dumm_250[bad3]
IF ( bd4  GT 0) THEN dummy[bad4]  = dumm_750[bad4]
IF ( bd5  GT 0) THEN dummy[bad5]  = dumm_500[bad5]
IF ( bd6  GT 0) THEN dummy[bad6]  = dumm_750[bad6]
IF ( bd7  GT 0) THEN dummy[bad7]  = dumm_500[bad7]
IF ( bd8  GT 0) THEN dummy[bad8]  = dumm_750[bad8]
IF ( bd9  GT 0) THEN dummy[bad9]  = dumm_250[bad9]
IF ( bd10 GT 0) THEN dummy[bad10] = dumm_750[bad10]
IF ( bd11 GT 0) THEN dummy[bad11] = dumm_500[bad11]
IF ( bd12 GT 0) THEN dummy[bad12] = dumm_300[bad12]
IF ( bd13 GT 0) THEN dummy[bad13] = dumm_750[bad13]
IF ( bd14 GT 0) THEN dummy[bad14] = dumm_250[bad14]
IF ( bd15 GT 0) THEN dummy[bad15] = dumm_500[bad15]
IF ( bd16 GT 0) THEN dummy[bad16] = dumm_750[bad16]
;; Clean up
DELVAR,dumm_750,dumm_200,dumm_250,dumm_300,dumm_350,dumm_400,dumm_500
DELVAR,data_750,data_200,data_250,data_300,data_350,data_400,data_500
;;----------------------------------------------------------------------------------------
;;  Calculate moments [just core]
;;----------------------------------------------------------------------------------------
coord_gse      = 'gse'
tp_hand0       = ['T_avg','V_Therm','N','Velocity','Tpara','Tperp','Tanisotropy','Pressure']
xsuff          = ''
tp_coor0       = REPLICATE(xsuff[0],N_ELEMENTS(tp_hand0))
good_coor0     = WHERE(tp_hand0 EQ 'Velocity' OR tp_hand0 EQ 'Pressure',gdcr0)
IF (gdcr0 GT 0) THEN tp_coor0[good_coor0] = '_'+STRLOWCASE(coord_gse[0])
v_units        = ' [km/s]'
t_units        = ' [eV]'
p_units        = ' [eV/cm!U3!N'+']'
d_units        = ' [#/cm!U3!N'+']'
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
FOR j=0L, n_i - 1L DO BEGIN                                                        $
  del     = dummy[j]                                                             & $
  pot     = del[0].SC_POT                                                        & $
  tmagf   = REFORM(del[0].MAGF)                                                  & $
  tmoms   = 0                                                                    & $
  ex_str  = 0                                                                    & $
  test    = TOTAL(j EQ bind) EQ 1                                                & $
  IF (test) THEN ex_str = {FORMAT:sform,DOMEGA_WEIGHTS:1,TRUE_VBULK:del[0].VSW}  & $
  IF (SIZE(ex_str,/TYPE) NE 8) THEN ex_str = {FORMAT:sform,DOMEGA_WEIGHTS:1}     & $
  tmoms = moments_3d_new(del,SC_POT=pot[0],MAGDIR=tmagf,_EXTRA=ex_str)           & $
  str_element,tmoms,'END_TIME',del[0].END_TIME,/ADD_REPLACE                      & $
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

tp_hands       = pref[0]+tp_hand0+tp_coor0+'_peib_no_GIs_UV'
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
velocity[bind,0] = vswx_fix_2
velocity[bind,1] = vswy_fix_2
velocity[bind,2] = vswz_fix_2
;;  Define time at center of IESA distributions
tt0            = ti_vsw.X
vnew_str       = {X:tt0,Y:velocity}                             ;; TPLOT structure
sc             = probe[0]
scu            = STRUPCASE(sc[0])
;;  Define Y-Axis title and subtitle
yttl           = 'V!Dbulk!N [TH'+scu[0]+', km/s, '+STRUPCASE(coord[0])+']'
ysubt          = '[Corrected, Core]'

store_data,vname_n[0]+'_2',DATA=vnew_str,DLIM=dlim,LIM=lim

options,vname_n[0]+'_2','YTITLE',yttl[0],/DEF
options,vname_n[0]+'_2','YSUBTITLE',ysubt[0],/DEF












































;;----------------------------------------------------------------------------------------
;; => Save moments
;;----------------------------------------------------------------------------------------
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








































































































































































































































