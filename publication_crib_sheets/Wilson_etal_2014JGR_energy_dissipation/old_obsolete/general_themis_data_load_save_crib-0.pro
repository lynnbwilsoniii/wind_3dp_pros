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
;;  Potential Bow Shock Crossings:  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  Probe A
probe          = 'a'
tdate          = '2009-09-27'
date           = '092709'
tr_00          = tdate[0]+'/'+['12:00:00','23:59:59']  ;;  Multiple crossings

;;  Probe C
probe          = 'c'
tdate          = '2009-08-04'
date           = '080409'
tr_00          = tdate[0]+'/'+['12:00:00','23:59:59']

probe          = 'c'
tdate          = '2009-08-28'
date           = '082809'
tr_00          = tdate[0]+'/'+['12:00:00','23:59:59']


probe          = 'c'
tdate          = '2009-09-11'
date           = '091109'
tr_00          = tdate[0]+'/'+['12:00:00','23:59:59']  ;;  Multiple crossings

probe          = 'c'
tdate          = '2009-09-25'
date           = '092509'
tr_00          = tdate[0]+'/'+['12:00:00','23:59:59']

probe          = 'c'
tdate          = '2009-12-07'
date           = '120709'
tr_00          = tdate[0]+'/'+['00:00:00','12:00:00']  ;;  Multiple crossings

probe          = 'c'
tdate          = '2009-12-12'
date           = '121209'
tr_00          = tdate[0]+'/'+['08:00:00','20:00:00']



;;----------------------------------------------------------------------------------------
;; => Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  2009-07-13 [1 Crossing]
tdate          = '2009-07-13'
tr_00          = tdate[0]+'/'+['07:50:00','10:10:00']
date           = '071309'
probe          = 'b'
tr_jj          = time_double(tdate[0]+'/'+['08:50:00.000','09:30:00.000'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['08:59:45.440','08:59:48.290'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = d
t_ramp2        = d
;;  Example wavelet times
tr_ww          = time_double(tdate[0]+'/'+['08:59:40.000','08:59:57.000'])
tr_whi         = time_double(tdate[0]+'/'+['08:59:51.200','08:59:51.600'])
tr_ecdi        = time_double(tdate[0]+'/'+['08:59:52.890','08:59:52.930'])

;;-------------------------------------
;;  2009-07-21 [1 Crossing]
;;-------------------------------------
tdate          = '2009-07-21'
tr_00          = tdate[0]+'/'+['14:00:00','23:00:00']
date           = '072109'
probe          = 'c'
tr_jj          = time_double(tdate[0]+'/'+['19:09:30.000','19:29:24.000'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['19:24:47.704','19:24:49.509'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = d
t_ramp2        = d

;;-------------------------------------
;;  2009-07-23 [3 Crossings]
;;-------------------------------------
tdate          = '2009-07-23'
tr_00          = tdate[0]+'/'+['12:00:00','21:00:00']
date           = '072309'
probe          = 'c'
tr_jj          = time_double(tdate[0]+'/'+['17:57:30.000','18:30:00.000'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['18:04:47.030','18:04:58.920'])
t_ramp_ra1     = time_double(tdate[0]+'/'+['18:07:07.340','18:07:08.100'])
t_ramp_ra2     = time_double(tdate[0]+'/'+['18:24:24.910','18:24:49.450'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = MEAN(t_ramp_ra1,/NAN)
t_ramp2        = MEAN(t_ramp_ra2,/NAN)

;;-------------------------------------
;;  2009-09-05 [3 Crossings]
;;-------------------------------------
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


;;-------------------------------------
;;  2009-09-26 [1 Crossing]
;;-------------------------------------
tdate          = '2009-09-26'
tr_00          = tdate[0]+'/'+['12:00:00','17:40:00']
date           = '092609'
probe          = 'a'
tr_jj          = time_double(tdate[0]+'/'+['15:48:20.000','15:58:25.000'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['15:53:09.911','15:53:10.249'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = d
t_ramp2        = d
;;  Example wavelet times
tr_ww          = time_double(tdate[0]+'/'+['15:53:02.500','15:53:15.600'])
tr_esw0        = time_double(tdate[0]+'/'+['15:53:03.475','15:53:03.500'])  ;;  train of ESWs [efw, Int. 0]
tr_esw1        = time_double(tdate[0]+'/'+['15:53:04.474','15:53:04.503'])  ;;  train of ESWs [efw, Int. 0]
tr_esw2        = time_double(tdate[0]+'/'+['15:53:09.910','15:53:09.940'])  ;;  two      ESWs [efw, Int. 1]
tr_whi         = time_double(tdate[0]+'/'+['15:53:10.860','15:53:11.203'])  ;;  example whistlers [scw, Int. 1]
tr_ww1         = time_double(tdate[0]+'/'+['15:53:09.165','15:53:15.590'])
tr_ww2         = time_double(tdate[0]+'/'+['15:53:09.165','15:53:12.500'])

;;-------------------------------------
;;  2011-10-24 [2 Crossings]
;;-------------------------------------
tdate          = '2011-10-24'
tr_00          = tdate[0]+'/'+['16:00:00','23:59:59']
date           = '102411'
probe          = 'e'
tr_jj          = time_double(tdate[0]+'/'+['18:00:00.000','23:59:59.000'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['18:31:56.880','18:31:57.290'])
t_ramp_ra1     = time_double(tdate[0]+'/'+['23:28:14.596','23:28:16.086'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = MEAN(t_ramp_ra1,/NAN)
t_ramp2        = d

;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
scu            = STRUPCASE(sc[0])
prefu          = STRUPCASE(pref[0])

themis_load_all_inst,DATE=date[0],PROBE=probe[0],TRANGE=time_double(tr_00),$
                     /LOAD_EESA_DF,EESA_DF_OUT=poynter_peeb,/LOAD_IESA_DF, $
                     IESA_DF_OUT=poynter_peib,ESA_BF_TYPE='burst'

;;----------------------------------------------------------------------------------------
;; => Set defaults
;;----------------------------------------------------------------------------------------
!themis.VERBOSE = 2
tplot_options,'VERBOSE',2
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='THEMIS-'+scu[0]+' Plots ['+tdate[0]+']'

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
;;----------------------------------------------------------------------------------------
;; => Fix Y-Axis subtitles
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




;;----------------------------------------------------------------------------------------
;; => Save ESA DF IDL Data Structures
;;----------------------------------------------------------------------------------------

;;  Below is an example for an event observed by probe E
;;  Burst
;peeb_df_arr_e  = *(poynter_peebf.BURST)[0]
;peib_dfarr_e0  = *(poynter_peibf.BURST)[0]
;peib_dfarr_e1  = *(poynter_peibf.BURST)[1]
;peib_df_arr_e  = [peib_dfarr_e0,peib_dfarr_e1]
;;;  Sort by time
;sp             = SORT(peeb_df_arr_e.TIME)
;peeb_df_arr_e  = peeb_df_arr_e[sp]
;sp             = SORT(peib_df_arr_e.TIME)
;peib_df_arr_e  = peib_df_arr_e[sp]
;
;enames         = 'EESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
;inames         = 'IESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
;SAVE,peeb_df_arr_e,FILENAME=enames[0]
;SAVE,peib_df_arr_e,FILENAME=inames[0]


;;  Probe C
peeb_df_arr_c0 = *(poynter_peeb.BURST)[0]
peeb_df_arr_c1 = *(poynter_peeb.BURST)[1]
peeb_df_arr_c  = [peeb_df_arr_c0,peeb_df_arr_c1]

peib_df_arr_c0 = *(poynter_peib.BURST)[0]
peib_df_arr_c1 = *(poynter_peib.BURST)[1]
peib_df_arr_c  = [peib_df_arr_c0,peib_df_arr_c1]
;;  Sort by time
sp             = SORT(peeb_df_arr_c.TIME)
peeb_df_arr_c  = peeb_df_arr_c[sp]
sp             = SORT(peib_df_arr_c.TIME)
peib_df_arr_c  = peib_df_arr_c[sp]



;;  Generalized Save Commands
enames         = 'EESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames         = 'IESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'

ei_str         = ['e','i']
inst_str       = 'pe'+ei_str+'b_df_arr_'
ei_suffx       = ',FILENAME='+ei_str+'names[0]'
exc_str_ei     = 'SAVE,'+inst_str+sc[0]+ei_suffx

;;   Save Electrons
test_e         = EXECUTE(exc_str_ei[0])
;;   Save Ions
test_i         = EXECUTE(exc_str_ei[1])

;;----------------------------------------------------------------------------------------
;; => Load E&B-Fields
;;----------------------------------------------------------------------------------------
mode           = 'efp efw'
coord_in       = 'dsl'
coord_out      = 'gse'
typee          = 'calibrated'
fmin_b         = 10.
fcut_b         = 10.
despinb        = 0
nk             = 256L
flow           = 0.1
no_extra       = 1
no_spec        = 1
tran_fac       = 0
poynt_flux     = 0
loadefi        = 1
loadscm        = 1
tclip_fs       = 0
tra            = time_double(tr_00)

wrapper_thm_load_efiscm,PROBE=probe,TRANGE=tra,/GET_SUPPORT,POYNT_FLUX=poynt_flux,    $
                        TRAN_FAC=tran_fac,COORD_IN=coord_in[0],DATATYPE=mode[0],      $
                        LOAD_EFI=loadefi,TYPE_E=typee[0],SE_T_EFI_OUT=se_tefi,        $
                        LOAD_SCM=loadscm,TYPE_B=typee[0],SE_T_SCM_OUT=se_tscm,NK=nk,  $
                        /EDGE_TRUN,FMIN_B=fmin_b,FCUT_B=fcut_b,                       $
                        DESPIN_B=despin_b,FLOW=flow,NO_EXTRA=no_extra,                $
                        NO_SPEC=no_spec,DIRECT_CROSS=direct,TCLIP_FIELDS=tclip_fs,    $
                        COORD_OUT=coord_out[0]

;; => Remove "spikes" by hand
coord_in       = 'dsl'
scp_names      = tnames(pref[0]+'scp_cal_'+coord_in[0]+'*')
efp_names      = tnames(pref[0]+'efp_cal_'+coord_in[0]+'*')
names          = [fgm_mag[1],scp_names,efp_names,efw_names]
tplot,names

kill_data_tr,NAMES=[scp_names[0],efp_names[0]]
kill_data_tr,NAMES=scp_names[0]
kill_data_tr,NAMES=efp_names[0]

;; => Remove "spikes" by hand
coord_in       = 'dsl'
scw_names      = tnames(pref[0]+'scw_cal_'+coord_in[0]+'*')
efw_names      = tnames(pref[0]+'efw_cal_'+coord_in[0]+'*')
names          = [fgm_mag[1],scw_names,efw_names]
tplot,names

kill_data_tr,NAMES=[scw_names[0],efw_names[0]]
kill_data_tr,NAMES=scw_names[0]
kill_data_tr,NAMES=efw_names[0]

nk             = 4L
kill_data_tr,NAMES=efw_names[0],NKILL=nk


;;-------------------------------------
;; => Remove "spikes" in efp data
;;-------------------------------------
get_data,efp_names[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
test_efp       = (ABS(temp_efp.Y[*,0]) LT 2d2)
good_efp       = WHERE(test_efp,gdefp,COMPLEMENT=bad_efp,NCOMPLEMENT=bdefp)
PRINT,';; ', gdefp, bdefp
;;       223589      398491

IF (bdefp GT 0) THEN temp_efp.Y[bad_efp,*] = f
IF (gdefp GT 0) THEN store_data,efp_names[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp


nk             = 4L
kill_data_tr,NAMES=efp_names[0],NKILL=nk




;; => Remove NaNs in data
get_data,scp_names[0],DATA=temp_scp,DLIM=dlim_scp,LIM=lim_scp
get_data,scw_names[0],DATA=temp_scw,DLIM=dlim_scw,LIM=lim_scw
get_data,efp_names[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
get_data,efw_names[0],DATA=temp_efw,DLIM=dlim_efw,LIM=lim_efw

test_scp       = FINITE(temp_scp.Y[*,0]) AND FINITE(temp_scp.Y[*,1]) AND FINITE(temp_scp.Y[*,2])
good_scp       = WHERE(test_scp,gdscp)
test_scw       = FINITE(temp_scw.Y[*,0]) AND FINITE(temp_scw.Y[*,1]) AND FINITE(temp_scw.Y[*,2])
good_scw       = WHERE(test_scw,gdscw)
test_efp       = FINITE(temp_efp.Y[*,0]) AND FINITE(temp_efp.Y[*,1]) AND FINITE(temp_efp.Y[*,2])
good_efp       = WHERE(test_efp,gdefp)
test_efw       = FINITE(temp_efw.Y[*,0]) AND FINITE(temp_efw.Y[*,1]) AND FINITE(temp_efw.Y[*,2])
good_efw       = WHERE(test_efw,gdefw)
PRINT,';; ', gdscp, gdscw, gdefp, gdefw
;;       230912      262656      230912      520704


IF (gdscp GT 0) THEN temp_scp = {X:temp_scp.X[good_scp],Y:temp_scp.Y[good_scp,*]} ELSE temp_scp = 0
IF (gdscw GT 0) THEN temp_scw = {X:temp_scw.X[good_scw],Y:temp_scw.Y[good_scw,*]} ELSE temp_scw = 0
IF (gdefp GT 0) THEN temp_efp = {X:temp_efp.X[good_efp],Y:temp_efp.Y[good_efp,*]} ELSE temp_efp = 0
IF (gdefw GT 0) THEN temp_efw = {X:temp_efw.X[good_efw],Y:temp_efw.Y[good_efw,*]} ELSE temp_efw = 0
IF (gdscp GT 0) THEN store_data,scp_names[0],DATA=temp_scp,DLIM=dlim_scp,LIM=lim_scp
IF (gdscw GT 0) THEN store_data,scw_names[0],DATA=temp_scw,DLIM=dlim_scw,LIM=lim_scw
IF (gdefp GT 0) THEN store_data,efp_names[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
IF (gdefw GT 0) THEN store_data,efw_names[0],DATA=temp_efw,DLIM=dlim_efw,LIM=lim_efw
IF (gdscp EQ 0) THEN del_data,scp_names[0]
IF (gdscw EQ 0) THEN del_data,scw_names[0]
IF (gdefp EQ 0) THEN del_data,efp_names[0]
IF (gdefw EQ 0) THEN del_data,efw_names[0]

;; => Clean up
DELVAR, test_scp, good_scp, test_scw, good_scw
DELVAR, test_efp, good_efp, test_efw, good_efw



;;-----------------------------------------------------------
;;  Save corrected fields
;;-----------------------------------------------------------
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_EFI-SCM-Corrected_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]
tplot_save,FILENAME=fname[0]
























































;;-----------------------------------------------------------
;;  Try smoothing without using autoregressive backcasting
;;-----------------------------------------------------------
get_data,efp_names[0]+'_with_spikes',DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
;;  Find intervals
efp__t         = temp_efp.X
efp__v         = temp_efp.Y

test_efp       = (ABS(efp__v[*,0]) LT 25d0)
good_efp       = WHERE(test_efp,gdefp,COMPLEMENT=bad_efp,NCOMPLEMENT=bdefp)
PRINT,';; ', gdefp, bdefp
;;       213331       17581


temp_efp__v    = temp_efp.Y
IF (bdefp GT 0) THEN temp_efp__v[bad_efp,*] = f
IF (gdefp GT 0) THEN temp_efp__v[*,0]       = interp(efp__v[good_efp,0],efp__t[good_efp],efp__t,/NO_EXTRAP)
IF (gdefp GT 0) THEN temp_efp__v[*,1]       = interp(efp__v[good_efp,1],efp__t[good_efp],efp__t,/NO_EXTRAP)
IF (gdefp GT 0) THEN temp_efp__v[*,2]       = interp(efp__v[good_efp,2],efp__t[good_efp],efp__t,/NO_EXTRAP)

interv         = t_interval_find(efp__t,GAP_THRESH=1d0)
HELP, interv
;; INTERV          LONG      = Array[3, 2]

efp__v_i0      = REFORM(temp_efp__v[interv[0,0]:interv[0,1],*])
efp__v_i1      = REFORM(temp_efp__v[interv[1,0]:interv[1,1],*])
efp__v_i2      = REFORM(temp_efp__v[interv[2,0]:interv[2,1],*])

wd             = 128L
efp_vx_i0      = SMOOTH(efp__v_i0[*,0],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vy_i0      = SMOOTH(efp__v_i0[*,1],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vz_i0      = SMOOTH(efp__v_i0[*,2],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vx_i1      = SMOOTH(efp__v_i1[*,0],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vy_i1      = SMOOTH(efp__v_i1[*,1],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vz_i1      = SMOOTH(efp__v_i1[*,2],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vx_i2      = SMOOTH(efp__v_i2[*,0],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vy_i2      = SMOOTH(efp__v_i2[*,1],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vz_i2      = SMOOTH(efp__v_i2[*,2],wd[0],/NAN,/EDGE_TRUNCATE)

efp__vx        = [efp_vx_i0,efp_vx_i1,efp_vx_i2]
efp__vy        = [efp_vy_i0,efp_vy_i1,efp_vy_i2]
efp__vz        = [efp_vz_i0,efp_vz_i1,efp_vz_i2]
efp__v_sm      = [[efp__vx],[efp__vy],[efp__vz]]

temp_efp_sm    = {X:temp_efp.X,Y:efp__v_sm}
sm_str         = STRTRIM(STRING(wd[0],FORMAT='(I4.4)'),2)
tp_suffx       = '_with_spikes_boxcar_sm'+sm_str[0]+'pts'

store_data,efp_names[0]+tp_suffx[0],DATA=temp_efp_sm,DLIM=dlim_efp,LIM=lim_efp

;;  Subtract detrended values from original
del_efp_vx     = efp__v[*,0] - efp__v_sm[*,0]
del_efp_vy     = efp__v[*,1] - efp__v_sm[*,1]
del_efp_vz     = efp__v[*,2] - efp__v_sm[*,2]

del_efp_v      = [[del_efp_vx],[del_efp_vy],[del_efp_vz]]
tp_suffx       = '_subtract_boxcar_sm'+sm_str[0]+'pts'
temp_efp_dt    = {X:efp__t,Y:del_efp_v}
store_data,efp_names[0]+tp_suffx[0],DATA=temp_efp_dt,DLIM=dlim_efp,LIM=lim_efp

;;  Now remove spikes from detrended values
test_efp_dt    = (ABS(del_efp_v[*,0]) LT 25d0) AND (ABS(del_efp_v[*,1]) LT 25d0)
good_efp_dt    = WHERE(test_efp_dt,gdefpdt,COMPLEMENT=bad_efp_dt,NCOMPLEMENT=bdefpdt)
PRINT,';; ', gdefpdt, bdefpdt
;;       214586       16326

interv_bd      = t_interval_find(efp__t[bad_efp_dt],GAP_THRESH=1d-1)
bad_low        = bad_efp_dt[REFORM(interv_bd[*,0])]
bad_hig        = bad_efp_dt[REFORM(interv_bd[*,1])]
;;  Add to end/start points
bad_low        = (bad_low - 6L) > 0
bad_hig        = (bad_hig + 6L) < (N_ELEMENTS(efp__t) - 1L)

tempdt_efp__v  = del_efp_v
;IF (bdefpdt GT 0) THEN tempdt_efp__v[bad_efp_dt,*] = f
FOR j=0L, N_ELEMENTS(bad_low) - 1L DO tempdt_efp__v[bad_low[j]:bad_hig[j],*] = f


tp_suffx       = '_detrend_subtract_boxcar_sm'+sm_str[0]+'pts_no-spikes'
temp_efp_dt_2  = {X:efp__t,Y:tempdt_efp__v}
store_data,efp_names[0]+tp_suffx[0],DATA=temp_efp_dt_2,DLIM=dlim_efp,LIM=lim_efp






























































































;;-----------------------------------------------------------
;;  Try detrending the data
;;-----------------------------------------------------------
get_data,efp_names[0]+'_with_spikes',DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
;;  Find intervals
efp__t         = temp_efp.X
efp__v         = temp_efp.Y

interv         = t_interval_find(efp__t,GAP_THRESH=1d0)
HELP, interv
;; INTERV          LONG      = Array[3, 2]

efp__v_i0      = REFORM(efp__v[interv[0,0]:interv[0,1],*])
efp__v_i1      = REFORM(efp__v[interv[1,0]:interv[1,1],*])
efp__v_i2      = REFORM(efp__v[interv[2,0]:interv[2,1],*])

;;  Smooth data in each interval using autoregressive backcasting
wd             = 128L
efp_vx_i0      = remove_noise(efp__v_i0[*,0],NBINS=wd[0])
efp_vy_i0      = remove_noise(efp__v_i0[*,1],NBINS=wd[0])
efp_vz_i0      = remove_noise(efp__v_i0[*,2],NBINS=wd[0])

efp_vx_i1      = remove_noise(efp__v_i1[*,0],NBINS=wd[0])
efp_vy_i1      = remove_noise(efp__v_i1[*,1],NBINS=wd[0])
efp_vz_i1      = remove_noise(efp__v_i1[*,2],NBINS=wd[0])

efp_vx_i2      = remove_noise(efp__v_i2[*,0],NBINS=wd[0])
efp_vy_i2      = remove_noise(efp__v_i2[*,1],NBINS=wd[0])
efp_vz_i2      = remove_noise(efp__v_i2[*,2],NBINS=wd[0])

efp__vx        = [efp_vx_i0,efp_vx_i1,efp_vx_i2]
efp__vy        = [efp_vy_i0,efp_vy_i1,efp_vy_i2]
efp__vz        = [efp_vz_i0,efp_vz_i1,efp_vz_i2]
efp__v_sm      = [[efp__vx],[efp__vy],[efp__vz]]

temp_efp_sm    = {X:temp_efp.X,Y:efp__v_sm}
sm_str         = STRTRIM(STRING(wd[0],FORMAT='(I3.3)'),2)
tp_suffx       = '_with_spikes_ARBC_sm'+sm_str[0]+'pts'
tp_suffx2      = tp_suffx[0]+'_2'
tp_suffx3      = tp_suffx[0]+'_3'

store_data,efp_names[0]+tp_suffx[0],DATA=temp_efp_sm,DLIM=dlim_efp,LIM=lim_efp

test_efp       = (ABS(temp_efp_sm.Y[*,0]) LT 25d0)
good_efp       = WHERE(test_efp,gdefp,COMPLEMENT=bad_efp,NCOMPLEMENT=bdefp)
PRINT,';; ', gdefp, bdefp
;;       156894       74018

efp__t_sm      = temp_efp_sm.X
efp__v_sm      = temp_efp_sm.Y
ind_efp        = LINDGEN(N_ELEMENTS(efp__t_sm))

interv_bd      = t_interval_find(efp__t_sm[bad_efp],GAP_THRESH=1d0)
bad_low        = bad_efp[REFORM(interv_bd[*,0])]
bad_hig        = bad_efp[REFORM(interv_bd[*,1])]
;;  Add to end/start points
bad_low        = (bad_low - 6L) > 0
bad_hig        = (bad_hig + 6L) < (N_ELEMENTS(efp__t_sm) - 1L)

IF (bdefp GT 0) THEN FOR j=0L, N_ELEMENTS(bad_low) - 1L DO efp__v_sm[bad_low[j]:bad_hig[j],0] = f
temp_efp_sm_2  = {X:efp__t_sm,Y:efp__v_sm}
IF (gdefp GT 0) THEN store_data,efp_names[0]+tp_suffx2[0],DATA=temp_efp_sm_2,DLIM=dlim_efp,LIM=lim_efp

;;  Smooth to remove NaNs
dumb           = REPLICATE(1,N_ELEMENTS(efp__t_sm))
temp_v_sm_2    = efp__v_sm[*,0]
temp_t_sm_2    = efp__t_sm
FOR j=0L, N_ELEMENTS(bad_low) - 1L DO BEGIN  $
  bind = dumb                              & $
  bind[bad_low[j]:bad_hig[j]] = 0          & $
  gind = WHERE(bind,gd)                    & $
  temp0 = INTERPOL(temp_v_sm_2[gind],temp_t_sm_2[gind],temp_t_sm_2,/SPLINE)   & $
  temp_v_sm_2 = temp0
;;  Remove extrapolated points
mx0            = MAX(ABS(efp__v_sm[*,0]),/NAN)*1.1
bad            = WHERE(ABS(temp_v_sm_2) GT mx0[0],bd)
IF (bd GT 0) THEN temp_v_sm_2[bad] = f
efp__v_sm_2    = [[temp_v_sm_2],[efp__v_sm[*,1]],[efp__v_sm[*,2]]]
temp_efp_sm_3  = {X:temp_t_sm_2,Y:efp__v_sm_2}
store_data,efp_names[0]+tp_suffx3[0],DATA=temp_efp_sm_3,DLIM=dlim_efp,LIM=lim_efp



;;  Subtract from original
get_data,efp_names[0]+'_with_spikes',DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
get_data,efp_names[0]+tp_suffx2[0],DATA=temp_efp_sm_2,DLIM=dlim_efp_sm_2,LIM=lim_efp_sm_2
efp__t         = temp_efp.X
efp__v         = temp_efp.Y
efp__t_sm_2    = temp_efp_sm_2.X
efp__v_sm_2    = temp_efp_sm_2.Y

;;  Smooth to remove NaNs
smwd           = 150L
temp_vx_sm_2   = SMOOTH(efp__v_sm_2[*,0],smwd[0],/NAN,/EDGE_TRUNCATE)
temp_vy_sm_2   = SMOOTH(efp__v_sm_2[*,1],smwd[0],/NAN,/EDGE_TRUNCATE)
temp_vz_sm_2   = SMOOTH(efp__v_sm_2[*,2],smwd[0],/NAN,/EDGE_TRUNCATE)
temp_efp_sm_22 = {X:temp_efp_sm_2.X,Y:[[temp_vx_sm_2],[temp_vy_sm_2],[temp_vz_sm_2]]}
store_data,efp_names[0]+tp_suffx2[0],DATA=temp_efp_sm_22,DLIM=dlim_efp_sm_2,LIM=lim_efp_sm_2

;;  Subtract detrended values from original
del_efp_vx     = efp__v[*,0] - temp_vx_sm_2
del_efp_vy     = efp__v[*,1] - temp_vy_sm_2
del_efp_vz     = efp__v[*,2] - temp_vz_sm_2
;bad_efp_vx     = WHERE(FINITE(efp__v_sm_2[*,0]) EQ 0,bdefp_vx)
;IF (bdefp GT 0) THEN del_efp_vx[bad_efp_vx] = f

;test_efp       = (ABS(del_efp_vx) LT 3d1)
;good_efp       = WHERE(test_efp,gdefp,COMPLEMENT=bad_efp,NCOMPLEMENT=bdefp)
;IF (bdefp GT 0) THEN del_efp_vx[bad_efp] = f

del_efp_v      = [[del_efp_vx],[del_efp_vy],[del_efp_vz]]
tp_suffx       = '_detrend_subtract_ARBC_sm'+sm_str[0]+'pts'
temp_efp_dt    = {X:efp__t,Y:del_efp_v}
store_data,efp_names[0]+tp_suffx[0],DATA=temp_efp_dt,DLIM=dlim_efp,LIM=lim_efp

;;  Subtract new result from original
del_efp_vx_2   = efp__v[*,0] - del_efp_v[*,0]
del_efp_vy_2   = efp__v[*,1] - del_efp_v[*,1]
del_efp_vz_2   = efp__v[*,2] - del_efp_v[*,2]
del_efp_v_2    = [[del_efp_vx_2],[del_efp_vy_2],[del_efp_vz_2]]
tp_suffx2      = '_detrend_subtract_ARBC_sm'+sm_str[0]+'pts_2'
temp_efp_dt_2  = {X:efp__t,Y:del_efp_v_2}
store_data,efp_names[0]+tp_suffx2[0],DATA=temp_efp_dt_2,DLIM=dlim_efp,LIM=lim_efp








