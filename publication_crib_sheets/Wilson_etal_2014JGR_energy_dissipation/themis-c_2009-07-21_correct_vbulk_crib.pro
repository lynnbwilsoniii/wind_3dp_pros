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
themis_load_all_inst,DATE=date[0],PROBE=probe[0],TRANGE=time_double(tr_00),$
                     /LOAD_EESA_DF,EESA_DF_OUT=poynter_peebf,/LOAD_IESA_DF,$
                     IESA_DF_OUT=poynter_peibf,ESA_BF_TYPE='both'
;;----------------------------------------------------------------------------------------
;; => Set defaults
;;----------------------------------------------------------------------------------------
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
;;----------------------------------------------------------------------------------------
;; => Check Y-Axis subtitles
;;----------------------------------------------------------------------------------------
scpref         = 'th'+sc[0]+'_'

modes_slh      = ['s','l','h']
mode_fgm       = 'fg'+modes_slh
fgm_pren       = scpref[0]+mode_fgm+'_'
fgm_mag        = tnames(fgm_pren[*]+'mag')
tplot,fgm_mag

;;  fix Y-subtitle
get_data,fgm_mag[0],DATA=temp,DLIM=dlim,LIM=lim
fgm_t          = temp.X
fgm_B          = temp.Y
;;  Define sample rate
srate_fgs      = DOUBLE(sample_rate(fgm_t,GAP_THRESH=6d0,/AVE))
sr_fgs_str     = STRTRIM(STRING(srate_fgs[0],FORMAT='(f15.2)'),2L)
;;  Define YSUBTITLE
ysubttle       = '[th'+sc[0]+' '+sr_fgs_str[0]+' sps, L2]'
;;  Find all fgs TPLOT handles
fgs_nms        = tnames(fgm_pren[0]+'*')
options,scpref[0]+'fgs_fci_flh_fce','YTITLE' 
options,scpref[0]+'fgs_fci_flh_fce','YTITLE',mode_fgm[0]+' [fci,flh,fce]',/DEF
options,fgs_nms,'YSUBTITLE'
options,fgs_nms,'YSUBTITLE',ysubttle[0],/DEF
;;  Clean up
DELVAR,temp,dlim,lim,fgm_t,fgm_B
;;----------------------------------------------------------------------------------------
;; => Plot fgh
;;----------------------------------------------------------------------------------------
coord          = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
velname        = pref[0]+'peib_velocity_'+coord[0]
magname        = pref[0]+'fgh_'+coord[0]
fgmnm          = pref[0]+'fgh_'+['mag',coord[0]]
tr_jj          = time_double(tdate[0]+'/'+['19:09:30','19:29:24'])

tplot,fgmnm,TRANGE=tr_jj


t_foot_se      = time_double(tdate[0]+'/'+['19:24:47.720','19:24:49.530'])
t_ramp_se      = time_double(tdate[0]+'/'+['19:24:49.530','19:24:53.440'])
;;----------------------------------------------------------------------------------------
;; => Restore saved DFs
;;----------------------------------------------------------------------------------------
tr_mom         = time_double(tdate[0]+'/'+['19:09:00','19:31:00'])

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
;;         398


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
;;         399
;;----------------------------------------------------------------------------------------
;; => Modify structures so they work in my plotting routines
;;----------------------------------------------------------------------------------------
coord          = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
velname        = pref[0]+'peir_velocity_'+coord[0]  ;;  Use reduced to cover full time range
magname        = pref[0]+'fgl_'+coord[0]            ;;  Use fgl to cover full time range
spperi         = pref[0]+'state_spinper'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
scnamei        = tnames(pref[0]+'peir_sc_pot')  ;;  Use reduced to cover full time range
scnamee        = tnames(pref[0]+'peeb_sc_pot')

modify_themis_esa_struc,dat_i
;; add SC potential to structures
add_scpot,dat_i,scnamei[0]
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


modify_themis_esa_struc,dat_e
;; add SC potential to structures
add_scpot,dat_e,scnamee[0]
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
;;----------------------------------------------------------------------------------------
;;    Convert into bulk flow frame and find new bulk flow velocities
;;
;;    This assumes the maximum peak of the distribution corresponds to the center of
;;      the "core" of the ion distribution.  If the source of error is due to ion beams,
;;      whether field-aligned or gyrating, then their maximum phase (velocity) space
;;      density should be less than the "core" part.  Therefore, the routine
;;      fix_vbulk_ions.pro finds the peak in phase (velocity) space density and then
;;      determines the corresponding velocity.  The steps are as follows:
;;        1)  transform into bulk flow frame  =>  V' = V - V_sw (transform_vframe_3d.pro)
;;        2)  define velocity of the peak, V_peak, in this frame  =>
;;              V" = V' - V_peak = V - (V_sw + V_peak)
;;        3)  return new transformation velocity, V_new = (V_sw + V_peak), from
;;              spacecraft frame to "true" bulk flow frame
;;
;;----------------------------------------------------------------------------------------
vbulk_old      = TRANSPOSE(dat_igse.VSW)  ;;  Level-2 Moment Estimates [km/s, GSE]
vbulk_new      = REPLICATE(d,n_i,3L)      ;;  New bulk flow velocities = V_new [km/s, GSE]
FOR j=0L, n_i - 1L DO BEGIN                     $
  dat0 = dat_igse[j]                          & $
  transform_vframe_3d,dat0,/EASY_TRAN         & $
  vstr = fix_vbulk_ions(dat0)                 & $
  vnew = vstr.VSW_NEW                         & $
  vbulk_new[j,*] = vnew

;;  Define time at center of IESA distributions
tt0            = (dat_i.TIME + dat_i.END_TIME)/2d0
;;  Define components of V_new
smvx           = vbulk_new[*,0]
smvy           = vbulk_new[*,1]
smvz           = vbulk_new[*,2]
;;  Remove "bad" points in magnetosheath [few points >500 km/s observed]
bdv            = 5d2
test           = (ABS(smvx) GE bdv) OR (ABS(smvy) GE bdv) OR (ABS(smvz) GE bdv)
bad            = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
PRINT,';;', gd, bd
;;         398           0

IF (bd GT 0) THEN smvx[bad] = d
IF (bd GT 0) THEN smvy[bad] = d
IF (bd GT 0) THEN smvz[bad] = d
;;  Linearly interpolate to fill NaNs
IF (gd GT 0) THEN smvx      = interp(smvx[good],tt0[good],tt0,/NO_EXTRAP)
IF (gd GT 0) THEN smvy      = interp(smvy[good],tt0[good],tt0,/NO_EXTRAP)
IF (gd GT 0) THEN smvz      = interp(smvz[good],tt0[good],tt0,/NO_EXTRAP)

;;  Smooth result to reduce data "spike" amplitudes
vsm            = 5L
smvx           = SMOOTH(smvx,vsm[0],/EDGE_TRUNCATE,/NAN)
smvy           = SMOOTH(smvy,vsm[0],/EDGE_TRUNCATE,/NAN)
smvz           = SMOOTH(smvz,vsm[0],/EDGE_TRUNCATE,/NAN)
smvel          = [[smvx],[smvy],[smvz]]

;;  Get reduced velocities and replace values in time range of interest
vred_name      = tnames(pref[0]+'peir_velocity_'+coord[0])
get_data,vred_name[0],DATA=vred_str
vred_t         = vred_str.X
vred_v         = vred_str.Y
tra_red        = [MIN(tt0,/NAN),MAX(tt0,/NAN)]
test           = (vred_t LE tra_red[1]) AND (vred_t GE tra_red[0])
bad_red        = WHERE(test,bdred,COMPLEMENT=good_red,NCOMPLEMENT=gdred)
PRINT,';;', gdred, bdred
;;       27168         387

vred_t         = vred_t[good_red]
vred_v         = vred_v[good_red,*]
;;  Combine values
vout_t         = [vred_t,tt0]
vout_v         = [vred_v,smvel]
;;  Sort
sp             = SORT(vout_t)
vout_t         = vout_t[sp]
vout_v         = vout_v[sp,*]
;;  Remove data points near each other
vout_tstr      = time_string(vout_t,PREC=3)
unq            = UNIQ(vout_tstr,SORT(vout_t))
sp             = SORT(unq)
unq            = unq[sp]
vout_t         = vout_t[unq]
vout_v         = vout_v[unq,*]
;;  Remove data points outside time range of interest
tr_dd          = time_double(tr_00)
test           = (vout_t LE tr_dd[1]) AND (vout_t GE tr_dd[0])
good           = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
PRINT,';;', gd, bd
;;       10354       17210

IF (gd GT 0) THEN vout_t   = vout_t[good]
IF (gd GT 0) THEN vout_v   = vout_v[good,*]
IF (gd GT 0) THEN vnew_str = {X:vout_t,Y:vout_v} ELSE vnew_str = 0


;;  Send result to TPLOT
;vnew_str       = {X:tt0,Y:smvel}                              ;; TPLOT structure
vn_prefx       = pref[0]+'peib_velocity_'+coord[0]
vname_n        = vn_prefx[0]+'_fixed'                         ;; TPLOT handle
yttl           = 'V!Dbulk!N [km/s, '+STRUPCASE(coord[0])+']'  ;; Y-Axis title
ysubt          = '[Shifted to DF Peak, 3s]'                   ;; Y-Axix subtitle
IF (gd GT 0) THEN store_data,vname_n[0],DATA=vnew_str
;;  Define plot options for new variable
IF (gd GT 0) THEN options,vname_n[0],'COLORS',[250,150, 50],/DEF
IF (gd GT 0) THEN options,vname_n[0],'LABELS',['x','y','z'],/DEF
IF (gd GT 0) THEN options,vname_n[0],'YTITLE',yttl[0],/DEF
IF (gd GT 0) THEN options,vname_n[0],'YSUBTITLE',ysubt[0],/DEF

;;  Set my default plot options for all TPLOT handles
nnw       = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01

;;  Remove spikes by hand
kill_data_tr,NAMES=tnames(vname_n)

;;  Get data and "fix" bad data
get_data,vname_n[0],DATA=vswnew,DLIM=dlim,LIM=lim
test           = FINITE(vswnew.Y[*,0]) AND FINITE(vswnew.Y[*,1]) AND FINITE(vswnew.Y[*,2])
good           = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
smvx           = interp(vswnew.Y[good,0],vswnew.X[good],vswnew.X,/NO_EXTRAP)
smvy           = interp(vswnew.Y[good,1],vswnew.X[good],vswnew.X,/NO_EXTRAP)
smvz           = interp(vswnew.Y[good,2],vswnew.X[good],vswnew.X,/NO_EXTRAP)
smvel          = [[smvx],[smvy],[smvz]]
vnew_str       = {X:vswnew.X,Y:smvel}
store_data,vname_n[0],DATA=vnew_str,DLIM=dlim,LIM=lim
;;----------------------------------------------------------------------------------------
;; => Plot DFs
;;----------------------------------------------------------------------------------------
add_vsw2,dat_igse,vname_n[0],/LEAVE_ALONE


.compile get_color_by_name
.compile get_font_symbol
.compile delete_variable
.compile format_vector_string
.compile contour_vdf

.compile beam_fit_struc_create
.compile beam_fit_struc_common
.compile beam_fit___get_common
.compile beam_fit___set_common
.compile beam_fit_unset_common

.compile beam_fit_cursor_select

.compile beam_fit_set_defaults
.compile beam_fit_gen_prompt
.compile beam_fit_prompts
.compile beam_fit_list_options
.compile beam_fit_print_index_time
.compile beam_fit_options
.compile beam_fit_keywords_init

.compile df_fit_beam_peak
.compile beam_fit_fit_prompts
.compile beam_fit_fit_wrapper

.compile beam_fit_change_parameter
.compile beam_fit_contour_plot
.compile find_beam_peak_and_mask
.compile find_df_indices
.compile find_dist_func_cuts
.compile region_cursor_select
.compile beam_fit_1df_plot_fit

.compile beam_fit_test_struct_format
.compile wrapper_beam_fit_array

;; Call wrapper
tags_exv       = ['VEC','NAME']
sunv           = [1d0,0d0,0d0]
sunn           = 'Sun Dir.'
dumb           = CREATE_STRUCT(tags_exv,REPLICATE(d,3L),'')
ex_vecn        = REPLICATE(dumb[0],1L)
ex_vecn[0]     = CREATE_STRUCT(tags_exv,sunv,sunn[0])
dat            = dat_igse
wrapper_beam_fit_array,dat,EX_VECN=ex_vecn

;;tr_bad_0       = time_double(tdate[0]+'/'+['19:20:00','19:35:00'])
;; indices : 00212-00397

times = time_string([dat[ind0[0]].TIME,dat[ind0[0]].END_TIME],PREC=3)
vsw00 = REFORM(data_out.VELOCITY.ORIG.VSW)
PRINT, ind0[0], times, vsw00, FORMAT='(";;",I12.4,2a27,3f15.4)'
read_out = 'n'
.c


;;        0212    2009-07-21/19:19:58.818    2009-07-21/19:20:01.803       -66.3324        12.0039       -87.9000
;;        0213    2009-07-21/19:20:01.803    2009-07-21/19:20:04.788         4.4145       -26.0599        11.8155
;;        0215    2009-07-21/19:20:07.773    2009-07-21/19:20:10.757      -137.4799       -17.8018        73.6326
;;        0216    2009-07-21/19:20:10.757    2009-07-21/19:20:13.742       -34.0094       -16.8963         2.2686
;;        0217    2009-07-21/19:20:13.742    2009-07-21/19:20:16.727       -78.9962        27.7604       -73.4300
;;        0218    2009-07-21/19:20:16.727    2009-07-21/19:20:19.711      -107.1573        35.0815       -34.0502
;;
;;        0225    2009-07-21/19:20:37.620    2009-07-21/19:20:40.604       -80.6096        17.9048        33.5520
;;        0228    2009-07-21/19:20:46.574    2009-07-21/19:20:49.559       -92.4517        16.3508        51.1989
;;        0229    2009-07-21/19:20:49.559    2009-07-21/19:20:52.543       -82.9166        51.0099        65.4665
;;        0230    2009-07-21/19:20:52.543    2009-07-21/19:20:55.528      -111.6954        80.2358        81.4269
;;        0232    2009-07-21/19:20:58.513    2009-07-21/19:21:01.498      -103.3097        66.4950        58.9178
;;
;;        0237    2009-07-21/19:21:13.436    2009-07-21/19:21:16.421      -119.1919        84.7312        77.7472
;;        0239    2009-07-21/19:21:19.406    2009-07-21/19:21:22.391      -172.5726        84.4560        79.7793
;;        0242    2009-07-21/19:21:28.360    2009-07-21/19:21:31.345      -162.8185       116.1447        22.5640
;;        0243    2009-07-21/19:21:31.345    2009-07-21/19:21:34.329      -222.2529       148.0554        22.4427
;;        0244    2009-07-21/19:21:34.329    2009-07-21/19:21:37.314      -225.0513        70.1642       -93.6586
;;        0245    2009-07-21/19:21:37.314    2009-07-21/19:21:40.299      -194.9502        16.8335       -50.2808
;;        0248    2009-07-21/19:21:46.268    2009-07-21/19:21:49.253      -215.2006        33.7643       -97.4916
;;        0249    2009-07-21/19:21:49.253    2009-07-21/19:21:52.238      -268.5831        46.6222      -103.8378
;;        0250    2009-07-21/19:21:52.238    2009-07-21/19:21:55.223      -244.6610        57.6431       -96.2640
;;        0252    2009-07-21/19:21:58.207    2009-07-21/19:22:01.192      -202.4694       -31.6629        25.3464
;;        0253    2009-07-21/19:22:01.192    2009-07-21/19:22:04.177      -244.1655        51.1703        -3.9886
;;        0254    2009-07-21/19:22:04.177    2009-07-21/19:22:07.161      -250.1317        43.8259       -50.2199
;;        0255    2009-07-21/19:22:07.161    2009-07-21/19:22:10.146      -248.0499        57.0528        19.7639
;;        0256    2009-07-21/19:22:10.146    2009-07-21/19:22:13.131      -244.0043        63.6059       -34.9942
;;        0257    2009-07-21/19:22:13.131    2009-07-21/19:22:16.116      -206.1373       -10.5386       -43.8829
;;        0258    2009-07-21/19:22:16.116    2009-07-21/19:22:19.100      -297.3607        53.7164       -63.3170
;;        0259    2009-07-21/19:22:19.100    2009-07-21/19:22:22.085      -285.1783        48.0395       -75.8230
;;        0261    2009-07-21/19:22:25.070    2009-07-21/19:22:28.054      -181.1424        72.8085       -80.2614
;;        0262    2009-07-21/19:22:28.054    2009-07-21/19:22:31.039      -131.8445        52.8300       -77.5382
;;        0263    2009-07-21/19:22:31.039    2009-07-21/19:22:34.024      -105.9926        -2.4265       -82.2102
;;        0264    2009-07-21/19:22:34.024    2009-07-21/19:22:37.009      -264.9839        86.4873       -99.3078
;;        0265    2009-07-21/19:22:37.009    2009-07-21/19:22:39.993      -218.3534        10.3366       -71.0442
;;        0266    2009-07-21/19:22:39.993    2009-07-21/19:22:42.978      -174.2904       -26.5899       -62.1987
;;        0267    2009-07-21/19:22:42.978    2009-07-21/19:22:45.963      -176.8320        32.5891       -73.1986
;;        0268    2009-07-21/19:22:45.963    2009-07-21/19:22:48.948      -160.1468        14.1506      -112.6395
;;        0269    2009-07-21/19:22:48.948    2009-07-21/19:22:51.932       -46.5016         2.5696       -42.0856
;;        0270    2009-07-21/19:22:51.932    2009-07-21/19:22:54.917       -98.9250        17.6630        15.0117
;;        0273    2009-07-21/19:23:00.886    2009-07-21/19:23:03.871       -72.3258        28.4602        20.5482
;;        0274    2009-07-21/19:23:03.871    2009-07-21/19:23:06.856       -47.3762        64.7338        26.3503
;;        0277    2009-07-21/19:23:12.825    2009-07-21/19:23:15.810       -18.8716        37.3067       -24.1314
;;        0278    2009-07-21/19:23:15.810    2009-07-21/19:23:18.795       -27.0511        68.8255       -92.8727
;;        0280    2009-07-21/19:23:21.779    2009-07-21/19:23:24.764       -70.1291        54.2998       -69.0745
;;        0282    2009-07-21/19:23:27.749    2009-07-21/19:23:30.734      -124.6126        68.3248        25.9831
;;        0283    2009-07-21/19:23:30.734    2009-07-21/19:23:33.718       -92.5699       -17.9142        27.1110
;;        0286    2009-07-21/19:23:39.688    2009-07-21/19:23:42.673      -205.8135        46.8467        31.3833
;;        0287    2009-07-21/19:23:42.673    2009-07-21/19:23:45.657      -150.4716        35.9319        73.7808
;;        0288    2009-07-21/19:23:45.657    2009-07-21/19:23:48.642      -190.7360       233.1425        54.5122
;;        0289    2009-07-21/19:23:48.642    2009-07-21/19:23:51.627      -108.6970       136.5689        55.7809
;;        0290    2009-07-21/19:23:51.627    2009-07-21/19:23:54.611       -78.4549       -20.5991        -5.6127
;;
;;        0296    2009-07-21/19:24:09.535    2009-07-21/19:24:12.520      -111.0058       -42.7062        44.3067
;;        0297    2009-07-21/19:24:12.520    2009-07-21/19:24:15.504       -51.5213       -55.0373        23.8250
;;        0298    2009-07-21/19:24:15.504    2009-07-21/19:24:18.489      -123.7240        86.9681        82.2451
;;        0299    2009-07-21/19:24:18.489    2009-07-21/19:24:21.474      -234.0357        47.2062       -91.3083
;;        0300    2009-07-21/19:24:21.474    2009-07-21/19:24:24.459       -95.3455        19.6267        34.0265
;;        0301    2009-07-21/19:24:24.459    2009-07-21/19:24:27.443      -111.9688        -0.7534        22.2441
;;        0302    2009-07-21/19:24:27.443    2009-07-21/19:24:30.428      -137.4312        -8.6697       -63.7385
;;        0303    2009-07-21/19:24:30.428    2009-07-21/19:24:33.413      -232.3100       -25.2770       -90.0661
;;        0304    2009-07-21/19:24:33.413    2009-07-21/19:24:36.398      -263.4565        66.4152      -105.1228
;;        0305    2009-07-21/19:24:36.398    2009-07-21/19:24:39.382      -180.7463       -19.6584       -60.2769
;;        0306    2009-07-21/19:24:39.382    2009-07-21/19:24:42.367      -149.9499       -24.5883       -14.7901
;;        0307    2009-07-21/19:24:42.367    2009-07-21/19:24:45.352      -103.7110         6.8137       -22.1835
;;        0308    2009-07-21/19:24:45.352    2009-07-21/19:24:48.336      -112.2276        53.9185        71.0140
;;        0309    2009-07-21/19:24:48.336    2009-07-21/19:24:51.321      -226.7647        62.8293        19.9308
;;        0310    2009-07-21/19:24:51.321    2009-07-21/19:24:54.306      -265.9658        38.0214        10.1507
;;
;;        0314    2009-07-21/19:25:03.260    2009-07-21/19:25:06.245      -271.5831        34.1858        33.5802
;;        0316    2009-07-21/19:25:09.229    2009-07-21/19:25:12.214      -283.6968        50.5589        27.0984
;;
;;        0320    2009-07-21/19:25:21.168    2009-07-21/19:25:24.153      -285.1324        33.0354        12.2048
;;        0322    2009-07-21/19:25:27.138    2009-07-21/19:25:30.123      -294.6334        66.3354         8.2477
;;        0323    2009-07-21/19:25:30.123    2009-07-21/19:25:33.107      -285.8503        40.1152         0.0228
;;        0324    2009-07-21/19:25:33.107    2009-07-21/19:25:36.092      -278.1801        56.1610         7.5950
;;        0325    2009-07-21/19:25:36.092    2009-07-21/19:25:39.077      -274.8725        60.9520        13.3070
;;        0326    2009-07-21/19:25:39.077    2009-07-21/19:25:42.061      -269.4849        53.1153         1.6376
;;        0328    2009-07-21/19:25:45.046    2009-07-21/19:25:48.031      -246.9284       -25.1639       -59.6247
;;        0329    2009-07-21/19:25:48.031    2009-07-21/19:25:51.016      -204.1693       -20.5170       -52.3429
;;        0331    2009-07-21/19:25:54.000    2009-07-21/19:25:56.985      -249.2258        22.6845        23.1814
;;        0332    2009-07-21/19:25:56.985    2009-07-21/19:25:59.970      -258.4899        50.0317        -0.2146
;;        0333    2009-07-21/19:25:59.970    2009-07-21/19:26:02.954      -284.7365        63.1775        44.4340
;;        0334    2009-07-21/19:26:02.954    2009-07-21/19:26:05.939      -289.8956        66.6966        47.1970
;;        0335    2009-07-21/19:26:05.939    2009-07-21/19:26:08.924      -297.8470        47.3018       -12.4291
;;        0336    2009-07-21/19:26:08.924    2009-07-21/19:26:11.909      -279.1911        34.7438         2.3394
;;        0337    2009-07-21/19:26:11.909    2009-07-21/19:26:14.893      -292.8238        49.2350       -13.0809
;;        0338    2009-07-21/19:26:14.893    2009-07-21/19:26:17.878      -273.5674       -38.8777        10.7045
;;        0339    2009-07-21/19:26:17.878    2009-07-21/19:26:20.863      -246.0919       -36.0657         9.4414
;;        0340    2009-07-21/19:26:20.863    2009-07-21/19:26:23.848      -228.5840       -46.6255         2.1247
;;        0341    2009-07-21/19:26:23.848    2009-07-21/19:26:26.832      -235.0892       -45.5515         9.8512
;;        0342    2009-07-21/19:26:26.832    2009-07-21/19:26:29.817      -247.2889        14.9461         9.3064
;;        0343    2009-07-21/19:26:29.817    2009-07-21/19:26:32.802      -247.1252        15.1120         9.4234
;;
;;        0348    2009-07-21/19:26:44.741    2009-07-21/19:26:47.725      -262.8331        42.1136        27.4916
;;        0349    2009-07-21/19:26:47.725    2009-07-21/19:26:50.710      -289.0674        53.3458        20.6938
;;        0350    2009-07-21/19:26:50.710    2009-07-21/19:26:53.695      -289.8274        29.1770        16.1608
;;        0353    2009-07-21/19:26:59.664    2009-07-21/19:27:02.649      -291.1602        51.2608         7.1536
;;        0354    2009-07-21/19:27:02.649    2009-07-21/19:27:05.634      -300.2289        59.1471        10.8689
;;        0355    2009-07-21/19:27:05.634    2009-07-21/19:27:08.618      -293.1192        68.8506        36.0876
;;        0356    2009-07-21/19:27:08.618    2009-07-21/19:27:11.603      -280.7290        75.8109        41.8650
;;        0357    2009-07-21/19:27:11.603    2009-07-21/19:27:14.588      -296.0938        76.5549        53.3350
;;        0358    2009-07-21/19:27:14.588    2009-07-21/19:27:17.573      -287.3900        65.2303        38.4421
;;        0359    2009-07-21/19:27:17.573    2009-07-21/19:27:20.557      -289.7205        50.6143        36.3342
;;        0360    2009-07-21/19:27:20.557    2009-07-21/19:27:23.542      -288.1214        46.7797        21.5565
;;        0361    2009-07-21/19:27:23.542    2009-07-21/19:27:26.527      -278.0900        43.2740        14.4652
;;        0362    2009-07-21/19:27:26.527    2009-07-21/19:27:29.511      -280.1126        52.3830         5.3618
;;        0363    2009-07-21/19:27:29.511    2009-07-21/19:27:32.496      -282.9535        48.6700        -4.8016
;;        0364    2009-07-21/19:27:32.496    2009-07-21/19:27:35.481      -262.0927        51.0272      -114.3552
;;        0365    2009-07-21/19:27:35.481    2009-07-21/19:27:38.466      -238.5548        43.3584       -99.9879
;;        0366    2009-07-21/19:27:38.466    2009-07-21/19:27:41.450      -242.7199       -15.2496       -88.6010
;;        0367    2009-07-21/19:27:41.450    2009-07-21/19:27:44.435      -232.1815       -39.3681        12.2123
;;        0368    2009-07-21/19:27:44.435    2009-07-21/19:27:47.420      -250.2820        46.7304         4.9322
;;        0369    2009-07-21/19:27:47.420    2009-07-21/19:27:50.404      -248.0668        53.9226         8.6132
;;        0370    2009-07-21/19:27:50.404    2009-07-21/19:27:53.389      -254.7874        49.8343       -20.3166
;;        0371    2009-07-21/19:27:53.389    2009-07-21/19:27:56.374      -252.0291        44.8791       -58.0771
;;        0372    2009-07-21/19:27:56.374    2009-07-21/19:27:59.359      -258.5573        50.9423       -55.6894
;;        0373    2009-07-21/19:27:59.359    2009-07-21/19:28:02.343      -263.4895        50.6783         0.4098
;;        0374    2009-07-21/19:28:02.343    2009-07-21/19:28:05.328      -265.7065        33.4196        11.7208
;;        0375    2009-07-21/19:28:05.328    2009-07-21/19:28:08.313      -252.3716        36.2620         3.9472
;;        0377    2009-07-21/19:28:11.298    2009-07-21/19:28:14.282      -261.1746        36.8663         3.6748
;;        0378    2009-07-21/19:28:14.282    2009-07-21/19:28:17.267      -266.7512        62.0836         0.9060
;;        0379    2009-07-21/19:28:17.267    2009-07-21/19:28:20.252      -252.0982        53.0972         2.9362
;;        0380    2009-07-21/19:28:20.252    2009-07-21/19:28:23.236      -250.5551        44.8767        36.4344
;;        0381    2009-07-21/19:28:23.236    2009-07-21/19:28:26.221      -239.0889        32.2854        19.9558
;;
;;        0385    2009-07-21/19:28:35.175    2009-07-21/19:28:38.160      -252.2227        32.5008        38.9549
;;        0386    2009-07-21/19:28:38.160    2009-07-21/19:28:41.145      -245.7826        29.2365        41.9517
;;        0388    2009-07-21/19:28:44.129    2009-07-21/19:28:47.114      -229.5438        25.8645         5.8534
;;        0389    2009-07-21/19:28:47.114    2009-07-21/19:28:50.099      -250.1396        35.0420         6.9832
;;        0390    2009-07-21/19:28:50.099    2009-07-21/19:28:53.084      -252.9209        30.9212        -8.8664
;;        0391    2009-07-21/19:28:53.084    2009-07-21/19:28:56.068      -250.5586        26.6607        10.5687
;;        0392    2009-07-21/19:28:56.068    2009-07-21/19:28:59.053      -255.4027        55.1723         2.1821
;;        0393    2009-07-21/19:28:59.053    2009-07-21/19:29:02.038      -243.7865         9.5548        27.5296
;;        0394    2009-07-21/19:29:02.038    2009-07-21/19:29:05.023      -234.2574         8.0498         8.9408
;;        0395    2009-07-21/19:29:05.023    2009-07-21/19:29:08.007      -231.7389        37.9400        22.1544
;;        0396    2009-07-21/19:29:08.007    2009-07-21/19:29:10.992      -257.7325        50.3922        21.3559
;;        0397    2009-07-21/19:29:10.992    2009-07-21/19:29:13.977      -323.0375        85.2590        45.7092


bind              = [0212L,0213L,0215L,0216L,0217L,0218L,0225L,0228L,0229L,0230L,0232L,0237L,0239L,0242L,0243L,0244L,0245L,0248L,0249L,0250L,0252L,0253L,0254L,0255L,0256L,0257L,0258L,0259L,0261L,0262L,0263L,0264L,0265L,0266L,0267L,0268L,0269L,0270L,0273L,0274L,0277L,0278L,0280L,0282L,0283L,0286L,0287L,0288L,0289L,0290L,0296L,0297L,0298L,0299L,0300L,0301L,0302L,0303L,0304L,0305L,0306L,0307L,0308L,0309L,0310L,0314L,0316L,0320L,0322L,0323L,0324L,0325L,0326L,0328L,0329L,0331L,0332L,0333L,0334L,0335L,0336L,0337L,0338L,0339L,0340L,0341L,0342L,0343L,0348L,0349L,0350L,0353L,0354L,0355L,0356L,0357L,0358L,0359L,0360L,0361L,0362L,0363L,0364L,0365L,0366L,0367L,0368L,0369L,0370L,0371L,0372L,0373L,0374L,0375L,0377L,0378L,0379L,0380L,0381L,0385L,0386L,0388L,0389L,0390L,0391L,0392L,0393L,0394L,0395L,0396L,0397L]
vswx_fix_2        = [ -66.3324d0,   4.4145d0,-137.4799d0, -34.0094d0, -78.9962d0,-107.1573d0, -80.6096d0, -92.4517d0, -82.9166d0,-111.6954d0,-103.3097d0,-119.1919d0,-172.5726d0,-162.8185d0,-222.2529d0,-225.0513d0,-194.9502d0,-215.2006d0,-268.5831d0,-244.6610d0,-202.4694d0,-244.1655d0,-250.1317d0,-248.0499d0,-244.0043d0,-206.1373d0,-297.3607d0,-285.1783d0,-181.1424d0,-131.8445d0,-105.9926d0,-264.9839d0,-218.3534d0,-174.2904d0,-176.8320d0,-160.1468d0, -46.5016d0, -98.9250d0, -72.3258d0, -47.3762d0, -18.8716d0, -27.0511d0, -70.1291d0,-124.6126d0, -92.5699d0,-205.8135d0,-150.4716d0,-190.7360d0,-108.6970d0, -78.4549d0,-111.0058d0, -51.5213d0,-123.7240d0,-234.0357d0, -95.3455d0,-111.9688d0,-137.4312d0,-232.3100d0,-263.4565d0,-180.7463d0,-149.9499d0,-103.7110d0,-112.2276d0,-226.7647d0,-265.9658d0,-271.5831d0,-283.6968d0,-285.1324d0,-294.6334d0,-285.8503d0,-278.1801d0,-274.8725d0,-269.4849d0,-246.9284d0,-204.1693d0,-249.2258d0,-258.4899d0,-284.7365d0,-289.8956d0,-297.8470d0,-279.1911d0,-292.8238d0,-273.5674d0,-246.0919d0,-228.5840d0,-235.0892d0,-247.2889d0,-247.1252d0,-262.8331d0,-289.0674d0,-289.8274d0,-291.1602d0,-300.2289d0,-293.1192d0,-280.7290d0,-296.0938d0,-287.3900d0,-289.7205d0,-288.1214d0,-278.0900d0,-280.1126d0,-282.9535d0,-262.0927d0,-238.5548d0,-242.7199d0,-232.1815d0,-250.2820d0,-248.0668d0,-254.7874d0,-252.0291d0,-258.5573d0,-263.4895d0,-265.7065d0,-252.3716d0,-261.1746d0,-266.7512d0,-252.0982d0,-250.5551d0,-239.0889d0,-252.2227d0,-245.7826d0,-229.5438d0,-250.1396d0,-252.9209d0,-250.5586d0,-255.4027d0,-243.7865d0,-234.2574d0,-231.7389d0,-257.7325d0,-323.0375d0]
vswy_fix_2        = [  12.0039d0, -26.0599d0, -17.8018d0, -16.8963d0,  27.7604d0,  35.0815d0,  17.9048d0,  16.3508d0,  51.0099d0,  80.2358d0,  66.4950d0,  84.7312d0,  84.4560d0, 116.1447d0, 148.0554d0,  70.1642d0,  16.8335d0,  33.7643d0,  46.6222d0,  57.6431d0, -31.6629d0,  51.1703d0,  43.8259d0,  57.0528d0,  63.6059d0, -10.5386d0,  53.7164d0,  48.0395d0,  72.8085d0,  52.8300d0,  -2.4265d0,  86.4873d0,  10.3366d0, -26.5899d0,  32.5891d0,  14.1506d0,   2.5696d0,  17.6630d0,  28.4602d0,  64.7338d0,  37.3067d0,  68.8255d0,  54.2998d0,  68.3248d0, -17.9142d0,  46.8467d0,  35.9319d0, 233.1425d0, 136.5689d0, -20.5991d0, -42.7062d0, -55.0373d0,  86.9681d0,  47.2062d0,  19.6267d0,  -0.7534d0,  -8.6697d0, -25.2770d0,  66.4152d0, -19.6584d0, -24.5883d0,   6.8137d0,  53.9185d0,  62.8293d0,  38.0214d0,  34.1858d0,  50.5589d0,  33.0354d0,  66.3354d0,  40.1152d0,  56.1610d0,  60.9520d0,  53.1153d0, -25.1639d0, -20.5170d0,  22.6845d0,  50.0317d0,  63.1775d0,  66.6966d0,  47.3018d0,  34.7438d0,  49.2350d0, -38.8777d0, -36.0657d0, -46.6255d0, -45.5515d0,  14.9461d0,  15.1120d0,  42.1136d0,  53.3458d0,  29.1770d0,  51.2608d0,  59.1471d0,  68.8506d0,  75.8109d0,  76.5549d0,  65.2303d0,  50.6143d0,  46.7797d0,  43.2740d0,  52.3830d0,  48.6700d0,  51.0272d0,  43.3584d0, -15.2496d0, -39.3681d0,  46.7304d0,  53.9226d0,  49.8343d0,  44.8791d0,  50.9423d0,  50.6783d0,  33.4196d0,  36.2620d0,  36.8663d0,  62.0836d0,  53.0972d0,  44.8767d0,  32.2854d0,  32.5008d0,  29.2365d0,  25.8645d0,  35.0420d0,  30.9212d0,  26.6607d0,  55.1723d0,   9.5548d0,   8.0498d0,  37.9400d0,  50.3922d0,  85.2590d0]
vswz_fix_2        = [ -87.9000d0,  11.8155d0,  73.6326d0,   2.2686d0, -73.4300d0, -34.0502d0,  33.5520d0,  51.1989d0,  65.4665d0,  81.4269d0,  58.9178d0,  77.7472d0,  79.7793d0,  22.5640d0,  22.4427d0, -93.6586d0, -50.2808d0, -97.4916d0,-103.8378d0, -96.2640d0,  25.3464d0,  -3.9886d0, -50.2199d0,  19.7639d0, -34.9942d0, -43.8829d0, -63.3170d0, -75.8230d0, -80.2614d0, -77.5382d0, -82.2102d0, -99.3078d0, -71.0442d0, -62.1987d0, -73.1986d0,-112.6395d0, -42.0856d0,  15.0117d0,  20.5482d0,  26.3503d0, -24.1314d0, -92.8727d0, -69.0745d0,  25.9831d0,  27.1110d0,  31.3833d0,  73.7808d0,  54.5122d0,  55.7809d0,  -5.6127d0,  44.3067d0,  23.8250d0,  82.2451d0, -91.3083d0,  34.0265d0,  22.2441d0, -63.7385d0, -90.0661d0,-105.1228d0, -60.2769d0, -14.7901d0, -22.1835d0,  71.0140d0,  19.9308d0,  10.1507d0,  33.5802d0,  27.0984d0,  12.2048d0,   8.2477d0,   0.0228d0,   7.5950d0,  13.3070d0,   1.6376d0, -59.6247d0, -52.3429d0,  23.1814d0,  -0.2146d0,  44.4340d0,  47.1970d0, -12.4291d0,   2.3394d0, -13.0809d0,  10.7045d0,   9.4414d0,   2.1247d0,   9.8512d0,   9.3064d0,   9.4234d0,  27.4916d0,  20.6938d0,  16.1608d0,   7.1536d0,  10.8689d0,  36.0876d0,  41.8650d0,  53.3350d0,  38.4421d0,  36.3342d0,  21.5565d0,  14.4652d0,   5.3618d0,  -4.8016d0,-114.3552d0, -99.9879d0, -88.6010d0,  12.2123d0,   4.9322d0,   8.6132d0, -20.3166d0, -58.0771d0, -55.6894d0,   0.4098d0,  11.7208d0,   3.9472d0,   3.6748d0,   0.9060d0,   2.9362d0,  36.4344d0,  19.9558d0,  38.9549d0,  41.9517d0,   5.8534d0,   6.9832d0,  -8.8664d0,  10.5687d0,   2.1821d0,  27.5296d0,   8.9408d0,  22.1544d0,  21.3559d0,  45.7092d0]


;;  Define time at center of IESA distributions
t_iesa            = (dat_igse.TIME + dat_igse.END_TIME)/2d0

;;  Get data and "fix" bad data
vn_prefx          = pref[0]+'peib_velocity_'+coord[0]
vname_n           = tnames(vn_prefx[0]+'_fixed')                 ;; TPLOT handle
vname_n2          = vn_prefx[0]+'_fixed_3'                        ;; TPLOT handle
get_data,velname[0],DATA=vswold,DLIM=dlimo,LIM=limo
get_data,vname_n[0],DATA=vswnew,DLIM=dlimn,LIM=limn
;;  Define parameters
vsw_old           = vswold.Y
vsw_to            = vswold.X
vsw_n2            = vswnew.Y
vsw_t2            = vswnew.X
;;  Put old Vsw on new timestamps
vxo               = interp(vsw_old[*,0],vsw_to,vsw_t2,/NO_EXTRAP)
vyo               = interp(vsw_old[*,1],vsw_to,vsw_t2,/NO_EXTRAP)
vzo               = interp(vsw_old[*,2],vsw_to,vsw_t2,/NO_EXTRAP)
vsw_o             = [[vxo],[vyo],[vzo]]

tra_bad           = time_double(tdate[0]+'/'+['19:20:00','19:29:14'])
testn             = (vsw_t2 GE tra_bad[0]) AND (vsw_t2 LE tra_bad[1])
bad_vswn          = WHERE(testn,bdvswn,COMPLEMENT=good_vswn,NCOMPLEMENT=gdvswn)
PRINT,';;', bdvswn, gdvswn
;;         186       10168


;;  Replace Vsw with original burst estimates near shock
vsw_n2[bad_vswn,*] = vsw_o[bad_vswn,*]
;;  Linearly interpolate to fill NaNs
test              = FINITE(vsw_n2[*,0]) AND FINITE(vsw_n2[*,1]) AND FINITE(vsw_n2[*,2])
good              = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
PRINT,';;', gd, bd
;;        5372        4982

IF (gd GT 0) THEN vxn = interp(vsw_n2[good,0],vsw_t2[good],vsw_t2,/NO_EXTRAP) ELSE vxn = 0
IF (gd GT 0) THEN vyn = interp(vsw_n2[good,1],vsw_t2[good],vsw_t2,/NO_EXTRAP) ELSE vyn = 0
IF (gd GT 0) THEN vzn = interp(vsw_n2[good,2],vsw_t2[good],vsw_t2,/NO_EXTRAP) ELSE vzn = 0
vsw_n             = [[vxn],[vyn],[vzn]]


;;  Define elements of VSW_N2 that correspond to BIND
tra_iesa          = [MIN(t_iesa,/NAN),MAX(t_iesa,/NAN)] + [-1d0,1d0]*2d0
test              = (vsw_t2 GE tra_iesa[0]) AND (vsw_t2 LE tra_iesa[1])
good_0            = WHERE(test,gd0,COMPLEMENT=bad_0,NCOMPLEMENT=bd0)
PRINT,';;', bd0, gd0, N_ELEMENTS(t_iesa)
;;        9956         398         398

;;  Replace "bad" values
bad_els           = good_0[bind]
vsw_n[bad_els,0]  = vswx_fix_2
vsw_n[bad_els,1]  = vswy_fix_2
vsw_n[bad_els,2]  = vswz_fix_2
struc             = {X:vsw_t2,Y:vsw_n}
store_data,vname_n2[0],DATA=struc,DLIM=dlimn,LIM=limn









;testo             = (vsw_to GE tra_bad[0]) AND (vsw_to LE tra_bad[1])
;bad_vswo          = WHERE(testo,bdvswo,COMPLEMENT=good_vswo,NCOMPLEMENT=gdvswo)
;PRINT,';;', bdvswo, gdvswo
;;;         177       27378































































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




;;----------------------------------------------------------------------------------------
;; => Save ESA DF IDL Data Structures
;;----------------------------------------------------------------------------------------
;;  Burst
peeb_dfarr_c0  = *(poynter_peebf.BURST)[0]
peeb_dfarr_c1  = *(poynter_peebf.BURST)[1]
peeb_dfarr_c2  = *(poynter_peebf.BURST)[2]
peib_dfarr_c0  = *(poynter_peibf.BURST)[0]
peib_dfarr_c1  = *(poynter_peibf.BURST)[1]
peib_dfarr_c2  = *(poynter_peibf.BURST)[2]
peeb_df_arr_c  = [peeb_dfarr_c0,peeb_dfarr_c1,peeb_dfarr_c2]
peib_df_arr_c  = [peib_dfarr_c0,peib_dfarr_c1,peib_dfarr_c2]
;;  Sort by time
sp             = SORT(peeb_df_arr_c.TIME)
peeb_df_arr_c  = peeb_df_arr_c[sp]
sp             = SORT(peib_df_arr_c.TIME)
peib_df_arr_c  = peib_df_arr_c[sp]


enames         = 'EESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames         = 'IESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
SAVE,peeb_df_arr_c,FILENAME=enames[0]
SAVE,peib_df_arr_c,FILENAME=inames[0]




























































;;----------------------------------------------------------------------------------------
;; => Save ESA DF IDL Data Structures
;;----------------------------------------------------------------------------------------
;;  Burst
peeb_dfarr_c0  = *(poynter_peebf.BURST)[0]
peeb_dfarr_c1  = *(poynter_peebf.BURST)[1]
peeb_dfarr_c2  = *(poynter_peebf.BURST)[2]
peib_dfarr_c0  = *(poynter_peibf.BURST)[0]
peib_dfarr_c1  = *(poynter_peibf.BURST)[1]
peib_dfarr_c2  = *(poynter_peibf.BURST)[2]
peeb_df_arr_c  = [peeb_dfarr_c0,peeb_dfarr_c1,peeb_dfarr_c2]
peib_df_arr_c  = [peib_dfarr_c0,peib_dfarr_c1,peib_dfarr_c2]
;;  Sort by time
sp             = SORT(peeb_df_arr_c.TIME)
peeb_df_arr_c  = peeb_df_arr_c[sp]
sp             = SORT(peib_df_arr_c.TIME)
peib_df_arr_c  = peib_df_arr_c[sp]
;;----------------------------------------------
;;  Full
;;----------------------------------------------
peef_dfarr_c0  = *(poynter_peebf.FULL)[0]
peef_dfarr_c1  = *(poynter_peebf.FULL)[1]
peif_dfarr_c0  = *(poynter_peibf.FULL)[0]
peif_dfarr_c1  = *(poynter_peibf.FULL)[1]
peef_df_arr_c  = [peef_dfarr_c0,peef_dfarr_c1]
peif_df_arr_c  = [peif_dfarr_c0,peif_dfarr_c1]
;;  Sort by time
sp             = SORT(peef_df_arr_c.TIME)
peef_df_arr_c  = peef_df_arr_c[sp]
sp             = SORT(peif_df_arr_c.TIME)
peif_df_arr_c  = peif_df_arr_c[sp]
;;----------------------------------------------
;;  Both
;;----------------------------------------------
peibf_dfarr_c  = [peib_df_arr_c,peif_df_arr_c]
peebf_dfarr_c  = [peeb_df_arr_c,peef_df_arr_c]
;;  Sort by time
sp             = SORT(peibf_dfarr_c.TIME)
peibf_dfarr_c  = peibf_dfarr_c[sp]
sp             = SORT(peebf_dfarr_c.TIME)
peebf_dfarr_c  = peebf_dfarr_c[sp]



enames         = 'EESA_Burst-Full_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames         = 'IESA_Burst-Full_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
SAVE,peebf_dfarr_c,FILENAME=enames[0]
SAVE,peibf_dfarr_c,FILENAME=inames[0]






















































































































