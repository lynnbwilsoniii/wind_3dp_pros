;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
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

; => Compile necessary routines
@comp_lynn_pros
thm_init
; => Date/Time and Probe
tdate          = '2009-09-26'
tr_00          = tdate[0]+'/'+['12:00:00','17:40:00']
tr_jj          = time_double(tdate[0]+'/'+['15:48:20','15:58:25'])
date           = '092609'
probe          = 'a'
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

pos_gse        = 'th'+sc[0]+'_state_pos_gse'
names          = [pref[0]+'_Rad',pos_gse[0]+['_x','_y','_z']]
tplot_options,VAR_LABEL=names
options,tnames(),'LABFLAG',2,/DEF

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Moments Plots'


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
all_Ni_nme     = tnames(pref[0]+['pei*_density','N_peib_no_GIs_UV'])
all_Ti_nme     = tnames(pref[0]+['pei*_avgtemp','T_avg_peib_no_GIs_UV'])
all_Vi_nme     = tnames(pref[0]+['pei*_velocity_'+coord_in[0]+'*',coord_in[0]+'_Velocity_peib_no_GIs_UV'])
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


;;----------------------------------------------------------------------------------------
;; => Load ESA Save Files
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
coord          = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
velname        = pref[0]+'peib_velocity_'+coord[0]
vname_n        = velname[0]+'_fixed_3'
magname        = pref[0]+'fgh_'+coord[0]
spperi         = pref[0]+'state_spinper'
scname         = tnames(pref[0]+'pe*b_sc_pot')

modify_themis_esa_struc,dat_i
;; add SC potential to structures
add_scpot,dat_i,scname[1]
;; => Rotate DAT structure (theta,phi)-angles DSL --> GSE
dat_igse       = dat_i
rotate_esa_thetaphi_to_gse,dat_igse,MAGF_NAME=magname,VEL_NAME=velname
;; make sure MAGF tag is defined
magn_1         = pref[0]+'fgs_'+coord[0]
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
magn_1         = pref[0]+'fgs_'+coord[0]
magn_2         = pref[0]+'fgh_'+coord[0]
add_magf2,dat_egse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_egse,magn_2[0],/LEAVE_ALONE
;; make sure VSW tag is defined
add_vsw2,dat_egse,velname[0],/LEAVE_ALONE
add_vsw2,dat_egse,vname_n[0],/LEAVE_ALONE
;;----------------------------------------------------------------------------------------
;; Ion DFs consist primarily of gyrating ions between:
;;
;;  [Start Times]
;;    15:50:21 - 15:50:36 UT    {V_thresh = 250 km/s}
;;    15:51:52 - 15:52:09 UT    {V_thresh = 250 km/s}
;;    15:52:10 - 15:52:45 UT    {V_thresh = 500 km/s}
;;    15:52:46 - 15:53:31 UT    {V_thresh = 200 km/s}
;;    15:53:32 - 15:54:56 UT    {V_thresh = 250 km/s}
;;  => ELSE {V_thresh = 750 km/s}
;;
;;----------------------------------------------------------------------------------------
;; => Define overall mask
;;----------------------------------------------------------------------------------------
v_thresh       = 75e1   ;;  = V_thresh [maximum speed of core]
v_uv           = 60e1   ;;  = V_uv     [estimated by plotting contours with sun dir.]
mask_a750      = remove_uv_and_beam_ions(dat_igse,V_THRESH=v_thresh[0],V_UV=v_uv[0])

v_thresh       = 20e1   ;;  = V_thresh [maximum speed of core]
mask_a200      = remove_uv_and_beam_ions(dat_igse,V_THRESH=v_thresh[0],V_UV=v_uv[0])

v_thresh       = 25e1   ;;  = V_thresh [maximum speed of core]
mask_a250      = remove_uv_and_beam_ions(dat_igse,V_THRESH=v_thresh[0],V_UV=v_uv[0])

v_thresh       = 50e1   ;;  = V_thresh [maximum speed of core]
mask_a500      = remove_uv_and_beam_ions(dat_igse,V_THRESH=v_thresh[0],V_UV=v_uv[0])
;;----------------------------------------------------------------------------------------
;; => Create a dummy copy of spacecraft (SC) frame structures and kill bad data
;;----------------------------------------------------------------------------------------
i_time0        = dat_igse.TIME
i_time1        = dat_igse.END_TIME

tr_bi0         = time_double(tdate[0]+'/'+['15:50:21','15:50:36'])
tr_bi1         = time_double(tdate[0]+'/'+['15:51:52','15:52:09'])
tr_bi2         = time_double(tdate[0]+'/'+['15:52:10','15:52:45'])
tr_bi3         = time_double(tdate[0]+'/'+['15:52:46','15:53:31'])
tr_bi4         = time_double(tdate[0]+'/'+['15:53:32','15:54:56'])

dummy          = dat_igse               ;; Dummy copy of original with mask applied
dumm_750       = dat_igse
dumm_200       = dat_igse
dumm_250       = dat_igse
dumm_500       = dat_igse
;; Data [counts]
data_750       = dummy.DATA
data_200       = dummy.DATA
data_250       = dummy.DATA
data_500       = dummy.DATA
;; => apply mask
data_750      *= mask_a750
data_200      *= mask_a200
data_250      *= mask_a250
data_500      *= mask_a500
;; => redefine data in each structure array
dumm_750.DATA  = data_750
dumm_200.DATA  = data_200
dumm_250.DATA  = data_250
dumm_500.DATA  = data_500

;; => Only use these structures when gyrating ions present
bad0           = WHERE(i_time0 GE tr_bi0[0] AND i_time0 LE tr_bi0[1],bd0)
bad1           = WHERE(i_time0 GE tr_bi1[0] AND i_time0 LE tr_bi1[1],bd1)
bad2           = WHERE(i_time0 GE tr_bi2[0] AND i_time0 LE tr_bi2[1],bd2)
bad3           = WHERE(i_time0 GE tr_bi3[0] AND i_time0 LE tr_bi3[1],bd3)
bad4           = WHERE(i_time0 GE tr_bi4[0] AND i_time0 LE tr_bi4[1],bd4)
PRINT,';;', bd0, bd1, bd2, bd3, bd4
;;           5           6          12          15          28

;; Start by applying default |V| ≤ 750 km/s filter
dummy          = dumm_750
IF (bd0 GT 0) THEN dummy[bad0] = dumm_250[bad0]
IF (bd1 GT 0) THEN dummy[bad1] = dumm_250[bad1]
IF (bd2 GT 0) THEN dummy[bad2] = dumm_500[bad2]
IF (bd3 GT 0) THEN dummy[bad3] = dumm_200[bad3]
IF (bd4 GT 0) THEN dummy[bad4] = dumm_250[bad4]
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


;; Replace the velocities I found by hand
bind           = [0431L,0432L,0433L,0434L,0435L,0436L,0437L,0438L,0439L,0440L,0441L,0442L,0443L,0444L,0445L,0446L,0447L,0448L,0449L,0450L,0451L,0452L,0453L,0454L,0455L,0456L,0457L,0458L,0459L,0460L,0461L,0462L,0463L,0464L,0465L,0466L,0467L,0468L,0469L,0470L,0471L,0472L]
vswx_fix_2     = [-137.9495d0,-110.2283d0,-105.3032d0,-105.9883d0, -71.2267d0,-102.2990d0,-109.5847d0, -66.4465d0, -75.5031d0, -87.8034d0,-100.6902d0, -95.5636d0, -83.2152d0, -80.4176d0, -61.3938d0,-268.7820d0,-228.2926d0,-175.1602d0,-145.4946d0, -72.1457d0,-208.7206d0,-225.9606d0, -58.1883d0,-209.6236d0,-185.5990d0,-242.4396d0,-227.9896d0,-206.2243d0,-281.9052d0,-246.9158d0,-275.3937d0,-293.4430d0,-276.7850d0,-288.7143d0,-289.0691d0,-293.1015d0,-307.5211d0,-295.7074d0,-302.7530d0,-311.4771d0,-300.4407d0,-304.2030d0]
vswy_fix_2     = [  75.6631d0, -14.8001d0,  50.6739d0,  95.4643d0,  35.3232d0,  52.1533d0,   9.4318d0,  18.5063d0,  36.7798d0,   6.7589d0, -14.2377d0,  14.5795d0,   8.9486d0,  30.5933d0, -11.2194d0, -52.9654d0, -59.7955d0, -86.4655d0,-114.5890d0, -78.5700d0,-126.2231d0, -34.1284d0,  86.0834d0, -44.8225d0, -42.6352d0, -53.9310d0, -36.0743d0, -38.2412d0,  51.1507d0, -26.6392d0,  44.2013d0,  31.3775d0,  78.9969d0,  83.1941d0,  86.6903d0,  79.7859d0,  71.0870d0,  82.1187d0,  72.7096d0,  58.5958d0,  71.0253d0,  69.0152d0]
vswz_fix_2     = [ 96.1632d0, 62.1760d0, 44.9703d0, 21.9975d0, 21.8700d0, 14.2218d0, 42.6332d0, 36.8999d0, -2.6429d0,  1.5962d0, 25.8590d0, 40.1858d0, -2.0704d0,  5.9990d0,  6.3821d0, 26.8731d0, 16.4429d0, -5.4312d0, 22.0415d0, 26.1776d0,-29.3434d0, 42.9462d0, -4.0278d0, 28.0028d0,-30.3545d0, 37.2253d0, 39.8258d0, 42.6363d0, 20.9123d0, 35.1928d0, 45.4029d0,  5.9471d0, 35.6257d0, 25.2030d0, 29.5523d0, 27.5498d0, 15.1370d0, 25.8282d0, 14.3992d0, 29.6708d0, 28.4041d0, 28.4948d0]

velnm0         = pref[0]+'Velocity_peib_no_GIs_UV'
vname_n        = tnames(velnm0[0])
get_data,vname_n[0],DATA=ti_vsw,DLIM=dlim,LIM=lim
vbulk          = ti_vsw.Y
;;  Define components of V_new
smvx           = vbulk[*,0]
smvy           = vbulk[*,1]
smvz           = vbulk[*,2]
;; Replace "bad" values
smvx[bind]     = vswx_fix_2
smvy[bind]     = vswy_fix_2
smvz[bind]     = vswz_fix_2
smvel3         = [[smvx],[smvy],[smvz]]

;;  Define time at center of IESA distributions
tt0            = ti_vsw.X
vnew_str       = {X:tt0,Y:smvel3}                             ;; TPLOT structure
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














;; Save corrected fields
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]
tplot_save,FILENAME=fname[0]
























