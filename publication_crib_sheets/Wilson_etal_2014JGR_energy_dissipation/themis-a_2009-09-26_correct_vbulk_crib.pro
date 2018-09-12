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
fpref          = 'TPLOT_save_file_THA_FGM-ALL_EESA-IESA-Moments_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]+'.tplot'
file           = FILE_SEARCH(mdir,fname[0])
tplot_restore,FILENAME=file[0],VERBOSE=0

!themis.VERBOSE = 0
tplot_options,'VERBOSE',0

pref           = 'th'+sc[0]+'_'
pos_gse        = 'th'+sc[0]+'_state_pos_gse'
names          = [pref[0]+'_Rad',pos_gse[0]+['_x','_y','_z']]
tplot_options,VAR_LABEL=names
options,tnames(),'LABFLAG',2,/DEF

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01

coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
velname   = pref[0]+'peib_velocity_'+coord[0]
magname   = pref[0]+'fgh_'+coord[0]
fgmnm     = pref[0]+'fgl_'+['mag',coord[0]]
tr_jj     = time_double(tdate[0]+'/'+['15:48:20','15:58:25'])

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
coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
velname   = pref[0]+'peib_velocity_'+coord[0]
magname   = pref[0]+'fgh_'+coord[0]
spperi    = pref[0]+'state_spinper'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
scname    = tnames(pref[0]+'pe*b_sc_pot')

modify_themis_esa_struc,dat_i
;; add SC potential to structures
add_scpot,dat_i,scname[1]
;; => Rotate DAT structure (theta,phi)-angles DSL --> GSE
dat_igse  = dat_i
rotate_esa_thetaphi_to_gse,dat_igse,MAGF_NAME=magname,VEL_NAME=velname
;; make sure MAGF tag is defined
magn_1    = pref[0]+'fgs_'+coord[0]
magn_2    = pref[0]+'fgh_'+coord[0]
add_magf2,dat_igse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_igse,magn_2[0],/LEAVE_ALONE
;; make sure VSW tag is defined
add_vsw2,dat_igse,velname[0],/LEAVE_ALONE


modify_themis_esa_struc,dat_e
;; add SC potential to structures
add_scpot,dat_e,scname[0]
;; => Rotate DAT structure (theta,phi)-angles DSL --> GSE
dat_egse  = dat_e
rotate_esa_thetaphi_to_gse,dat_egse,MAGF_NAME=magname,VEL_NAME=velname
;; make sure MAGF tag is defined
magn_1    = pref[0]+'fgs_'+coord[0]
magn_2    = pref[0]+'fgh_'+coord[0]
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
vbulk_old = TRANSPOSE(dat_igse.VSW)  ;;  Level-2 Moment Estimates [km/s, GSE]
vbulk_new = REPLICATE(d,n_i,3L)      ;;  New bulk flow velocities = V_new [km/s, GSE]
FOR j=0L, n_i - 1L DO BEGIN                     $
  dat0 = dat_igse[j]                          & $
  transform_vframe_3d,dat0,/EASY_TRAN         & $
  vstr = fix_vbulk_ions(dat0)                 & $
  vnew = vstr.VSW_NEW                         & $
  vbulk_new[j,*] = vnew

;;  Define time at center of IESA distributions
tt0       = (dat_i.TIME + dat_i.END_TIME)/2d0
;;  Define components of V_new
smvx      = vbulk_new[*,0]
smvy      = vbulk_new[*,1]
smvz      = vbulk_new[*,2]
;;  Remove "bad" points in magnetosheath [few points >1000 km/s observed]
test      = (ABS(smvx) GE 1d3) OR (ABS(smvy) GE 1d3) OR (ABS(smvz) GE 1d3)
bad       = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0) THEN smvx[bad] = d
IF (bd GT 0) THEN smvy[bad] = d
IF (bd GT 0) THEN smvz[bad] = d
;;  Linearly interpolate to fill NaNs
IF (gd GT 0) THEN smvx      = interp(smvx[good],tt0[good],tt0,/NO_EXTRAP)
IF (gd GT 0) THEN smvy      = interp(smvy[good],tt0[good],tt0,/NO_EXTRAP)
IF (gd GT 0) THEN smvz      = interp(smvz[good],tt0[good],tt0,/NO_EXTRAP)


;;  Smooth result to reduce data "spike" amplitudes
vsm       = 5L
smvx      = SMOOTH(smvx,vsm[0],/EDGE_TRUNCATE,/NAN)
smvy      = SMOOTH(smvy,vsm[0],/EDGE_TRUNCATE,/NAN)
smvz      = SMOOTH(smvz,vsm[0],/EDGE_TRUNCATE,/NAN)
smvel     = [[smvx],[smvy],[smvz]]

;;  Send result to TPLOT
vnew_str  = {X:tt0,Y:smvel}                              ;; TPLOT structure
vname_n   = velname[0]+'_fixed'                          ;; TPLOT handle
yttl      = 'V!Dbulk!N [km/s, '+STRUPCASE(coord[0])+']'  ;; Y-Axis title
ysubt     = '[Shifted to DF Peak, 3s]'                   ;; Y-Axix subtitle

store_data,vname_n[0],DATA=vnew_str
;;  Define plot options for new variable
options,vname_n[0],'COLORS',[250,150, 50],/DEF
options,vname_n[0],'LABELS',['x','y','z'],/DEF
options,vname_n[0],'YTITLE',yttl[0],/DEF
options,vname_n[0],'YSUBTITLE',ysubt[0],/DEF

;;  Set my default plot options for all TPLOT handles
nnw       = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
;;----------------------------------------------------------------------------------------
;; => Plot DFs
;;----------------------------------------------------------------------------------------
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

;; indices : 431-490

times = time_string([dat[ind0[0]].TIME,dat[ind0[0]].END_TIME],PREC=3)
vsw00 = REFORM(data_out.VELOCITY.ORIG.VSW)
PRINT, ind0[0], times, vsw00, FORMAT='(";;",I12.4,2a27,3f15.4)'
read_out = 'n'
.c

;; Indices that I don't trust
;;        0445    2009-09-26/15:52:43.608    2009-09-26/15:52:46.639       -19.2551       -37.6696        20.0778
;;        0448    2009-09-26/15:52:52.703    2009-09-26/15:52:55.735       -30.6853       178.8779        61.4252
;;        0451    2009-09-26/15:53:01.798    2009-09-26/15:53:04.830        35.6943       -11.6056        17.8418
;;        0456    2009-09-26/15:53:16.957    2009-09-26/15:53:19.988        70.3807       150.2055         9.2872
;;        0462    2009-09-26/15:53:35.147    2009-09-26/15:53:38.179        95.1384       201.0357       -46.9940


;; Indices that need to be fixed
;;        0431    2009-09-26/15:52:01.164    2009-09-26/15:52:04.195      -137.9495        75.6631        96.1632
;;        0432    2009-09-26/15:52:04.195    2009-09-26/15:52:07.227      -110.2283       -14.8001        62.1760
;;        0433    2009-09-26/15:52:07.227    2009-09-26/15:52:10.259      -105.3032        50.6739        44.9703
;;        0434    2009-09-26/15:52:10.259    2009-09-26/15:52:13.291      -105.9883        95.4643        21.9975
;;        0435    2009-09-26/15:52:13.291    2009-09-26/15:52:16.322       -71.2267        35.3232        21.8700
;;        0436    2009-09-26/15:52:16.322    2009-09-26/15:52:19.354      -102.2990        52.1533        14.2218
;;        0437    2009-09-26/15:52:19.354    2009-09-26/15:52:22.386      -109.5847         9.4318        42.6332
;;        0438    2009-09-26/15:52:22.386    2009-09-26/15:52:25.417       -66.4465        18.5063        36.8999
;;        0439    2009-09-26/15:52:25.417    2009-09-26/15:52:28.449       -75.5031        36.7798        -2.6429
;;        0440    2009-09-26/15:52:28.449    2009-09-26/15:52:31.481       -87.8034         6.7589         1.5962
;;        0441    2009-09-26/15:52:31.481    2009-09-26/15:52:34.513      -100.6902       -14.2377        25.8590
;;        0442    2009-09-26/15:52:34.513    2009-09-26/15:52:37.544       -95.5636        14.5795        40.1858
;;        0443    2009-09-26/15:52:37.544    2009-09-26/15:52:40.576       -83.2152         8.9486        -2.0704
;;        0444    2009-09-26/15:52:40.576    2009-09-26/15:52:43.608       -80.4176        30.5933         5.9990
;;        0445    2009-09-26/15:52:43.608    2009-09-26/15:52:46.639       -61.3938       -11.2194         6.3821
;;        0446    2009-09-26/15:52:46.639    2009-09-26/15:52:49.671      -268.7820       -52.9654        26.8731
;;        0447    2009-09-26/15:52:49.671    2009-09-26/15:52:52.703      -228.2926       -59.7955        16.4429
;;        0448    2009-09-26/15:52:52.703    2009-09-26/15:52:55.735      -175.1602       -86.4655        -5.4312
;;        0449    2009-09-26/15:52:55.735    2009-09-26/15:52:58.766      -145.4946      -114.5890        22.0415
;;        0450    2009-09-26/15:52:58.766    2009-09-26/15:53:01.798       -72.1457       -78.5700        26.1776
;;        0451    2009-09-26/15:53:01.798    2009-09-26/15:53:04.830      -208.7206      -126.2231       -29.3434
;;        0452    2009-09-26/15:53:04.830    2009-09-26/15:53:07.861      -225.9606       -34.1284        42.9462
;;        0453    2009-09-26/15:53:07.861    2009-09-26/15:53:10.893       -58.1883        86.0834        -4.0278
;;        0454    2009-09-26/15:53:10.893    2009-09-26/15:53:13.925      -209.6236       -44.8225        28.0028
;;        0455    2009-09-26/15:53:13.925    2009-09-26/15:53:16.957      -185.5990       -42.6352       -30.3545
;;        0456    2009-09-26/15:53:16.957    2009-09-26/15:53:19.988      -242.4396       -53.9310        37.2253
;;        0457    2009-09-26/15:53:19.988    2009-09-26/15:53:23.020      -227.9896       -36.0743        39.8258
;;        0458    2009-09-26/15:53:23.020    2009-09-26/15:53:26.052      -206.2243       -38.2412        42.6363
;;        0459    2009-09-26/15:53:26.052    2009-09-26/15:53:29.083      -281.9052        51.1507        20.9123
;;        0460    2009-09-26/15:53:29.083    2009-09-26/15:53:32.115      -246.9158       -26.6392        35.1928
;;        0461    2009-09-26/15:53:32.115    2009-09-26/15:53:35.147      -275.3937        44.2013        45.4029
;;        0462    2009-09-26/15:53:35.147    2009-09-26/15:53:38.179      -293.4430        31.3775         5.9471
;;        0463    2009-09-26/15:53:38.179    2009-09-26/15:53:41.210      -276.7850        78.9969        35.6257
;;        0464    2009-09-26/15:53:41.210    2009-09-26/15:53:44.242      -288.7143        83.1941        25.2030
;;        0465    2009-09-26/15:53:44.242    2009-09-26/15:53:47.274      -289.0691        86.6903        29.5523
;;        0466    2009-09-26/15:53:47.274    2009-09-26/15:53:50.305      -293.1015        79.7859        27.5498
;;        0467    2009-09-26/15:53:50.305    2009-09-26/15:53:53.337      -307.5211        71.0870        15.1370
;;        0468    2009-09-26/15:53:53.337    2009-09-26/15:53:56.369      -295.7074        82.1187        25.8282
;;        0469    2009-09-26/15:53:56.369    2009-09-26/15:53:59.401      -302.7530        72.7096        14.3992
;;        0470    2009-09-26/15:53:59.401    2009-09-26/15:54:02.432      -311.4771        58.5958        29.6708
;;        0471    2009-09-26/15:54:02.432    2009-09-26/15:54:05.464      -300.4407        71.0253        28.4041
;;        0472    2009-09-26/15:54:05.464    2009-09-26/15:54:08.496      -304.2030        69.0152        28.4948

bind            = [0431L,0432L,0433L,0434L,0435L,0436L,0437L,0438L,0439L,0440L,0441L,0442L,0443L,0444L,0445L,0446L,0447L,0448L,0449L,0450L,0451L,0452L,0453L,0454L,0455L,0456L,0457L,0458L,0459L,0460L,0461L,0462L,0463L,0464L,0465L,0466L,0467L,0468L,0469L,0470L,0471L,0472L]
vswx_fix_2      = [-137.9495d0,-110.2283d0,-105.3032d0,-105.9883d0, -71.2267d0,-102.2990d0,-109.5847d0, -66.4465d0, -75.5031d0, -87.8034d0,-100.6902d0, -95.5636d0, -83.2152d0, -80.4176d0, -61.3938d0,-268.7820d0,-228.2926d0,-175.1602d0,-145.4946d0, -72.1457d0,-208.7206d0,-225.9606d0, -58.1883d0,-209.6236d0,-185.5990d0,-242.4396d0,-227.9896d0,-206.2243d0,-281.9052d0,-246.9158d0,-275.3937d0,-293.4430d0,-276.7850d0,-288.7143d0,-289.0691d0,-293.1015d0,-307.5211d0,-295.7074d0,-302.7530d0,-311.4771d0,-300.4407d0,-304.2030d0]
vswy_fix_2      = [  75.6631d0, -14.8001d0,  50.6739d0,  95.4643d0,  35.3232d0,  52.1533d0,   9.4318d0,  18.5063d0,  36.7798d0,   6.7589d0, -14.2377d0,  14.5795d0,   8.9486d0,  30.5933d0, -11.2194d0, -52.9654d0, -59.7955d0, -86.4655d0,-114.5890d0, -78.5700d0,-126.2231d0, -34.1284d0,  86.0834d0, -44.8225d0, -42.6352d0, -53.9310d0, -36.0743d0, -38.2412d0,  51.1507d0, -26.6392d0,  44.2013d0,  31.3775d0,  78.9969d0,  83.1941d0,  86.6903d0,  79.7859d0,  71.0870d0,  82.1187d0,  72.7096d0,  58.5958d0,  71.0253d0,  69.0152d0]
vswz_fix_2      = [ 96.1632d0, 62.1760d0, 44.9703d0, 21.9975d0, 21.8700d0, 14.2218d0, 42.6332d0, 36.8999d0, -2.6429d0,  1.5962d0, 25.8590d0, 40.1858d0, -2.0704d0,  5.9990d0,  6.3821d0, 26.8731d0, 16.4429d0, -5.4312d0, 22.0415d0, 26.1776d0,-29.3434d0, 42.9462d0, -4.0278d0, 28.0028d0,-30.3545d0, 37.2253d0, 39.8258d0, 42.6363d0, 20.9123d0, 35.1928d0, 45.4029d0,  5.9471d0, 35.6257d0, 25.2030d0, 29.5523d0, 27.5498d0, 15.1370d0, 25.8282d0, 14.3992d0, 29.6708d0, 28.4041d0, 28.4948d0]

vname_n         = tnames(velname[0]+'_fixed')                 ;; TPLOT handle
get_data,vname_n[0],DATA=ti_vsw,DLIM=dlim,LIM=lim
vbulk           = ti_vsw.Y
;;  Define components of V_new
smvx            = vbulk[*,0]
smvy            = vbulk[*,1]
smvz            = vbulk[*,2]
;; Replace "bad" values
smvx[bind]      = vswx_fix_2
smvy[bind]      = vswy_fix_2
smvz[bind]      = vswz_fix_2
smvel3          = [[smvx],[smvy],[smvz]]

;;  Define time at center of IESA distributions
tt0            = (dat_igse.TIME + dat_igse.END_TIME)/2d0
vnew_str       = {X:tt0,Y:smvel3}                             ;; TPLOT structure
vname_n3       = velname[0]+'_fixed_3'                        ;; TPLOT handle
yttl           = 'V!Dbulk!N [km/s, '+STRUPCASE(coord[0])+']'  ;; Y-Axis title
ysubt          = '[Shifted to DF Peak, 3s]'                   ;; Y-Axix subtitle

store_data,vname_n3[0],DATA=vnew_str
;;  Define plot options for new variable
options,vname_n3[0],'COLORS',[250,150, 50],/DEF
options,vname_n3[0],'LABELS',['x','y','z'],/DEF
options,vname_n3[0],'YTITLE',yttl[0],/DEF
options,vname_n3[0],'YSUBTITLE',ysubt[0],/DEF

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


































