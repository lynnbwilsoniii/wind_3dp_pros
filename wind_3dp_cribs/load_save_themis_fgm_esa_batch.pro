;+
;*****************************************************************************************
;
;  BATCH    :   load_save_themis_fgm_esa_batch.pro
;  PURPOSE  :   This is a batch file to be called from the command line using the
;                 standard method of calling
;                 (i.e., @load_save_themis_fgm_esa_batch.pro).
;
;  CALLED BY:   
;               themis_load_save_fgm_esa_crib.pro
;
;  CALLS:
;               get_os_slash.pro
;               test_tdate_format.pro
;               time_double.pro
;               get_valid_trange.pro
;               themis_load_fgm_esa_inst.pro
;               lbw_tplot_set_defaults.pro
;               tplot_options.pro
;               options.pro
;               tnames.pro
;               tplot.pro
;               file_name_times.pro
;               tplot_save.pro
;               merge_themis_esa_structs.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries and UMN Modified Wind/3DP IDL Libraries
;               2)  MUST run comp_lynn_pros.pro prior to calling this routine
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ;;  Load all ESA, State, and FGM data for 2008-07-26 for Probe B
;               ;;  **********************************************
;               ;;  **  variable names MUST exactly match these **
;               ;;  **********************************************
;               probe          = 'b'
;               tdate          = '2008-07-26'
;               date           = '072608'
;               @load_save_themis_fgm_esa_batch.pro
;
;  KEYWORDS:    
;               NO_CLEAN  :  If set prior to running, routine will not delete ESA
;                              structures upon completion
;                              [Default = FALSE]
;
;   CHANGED:  1)  Forgot to define the version number variable
;                                                                   [12/08/2014   v1.0.1]
;             2)  Now calls merge_themis_esa_structs.pro and correctly concatenates
;                   arrays of velocity distribution function structures
;                                                                   [12/09/2014   v1.1.0]
;             3)  Now calls test_tdate_format.pro, get_valid_trange.pro, and
;                   lbw_tplot_set_defaults.pro
;                                                                   [10/23/2015   v1.2.0]
;             4)  Added an optional keyword-like parameter that tells the batch file
;                   not to remove/delete variables upon completion
;                                                                   [04/13/2016   v1.3.0]
;
;   NOTES:      
;               1)  This batch routine expects a date (in two formats) and a probe,
;                     all input on the command line prior to calling (see EXAMPLES)
;               2)  If your paths are not set correctly, you may need to provide a full
;                     path to this routine, e.g., on my machine this is:
;               @$HOME/wind_3dp_pros/wind_3dp_cribs/load_save_themis_fgm_esa_batch.pro
;
;  REFERENCES:  
;               1)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, (2008).
;               2)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, (2008).
;               3)  Auster, H.U., K.-H. Glassmeier, W. Magnes, O. Aydogar, W. Baumjohann,
;                      D. Constantinescu, D. Fischer, K.H. Fornacon, E. Georgescu,
;                      P. Harvey, O. Hillenmaier, R. Kroth, M. Ludlam, Y. Narita,
;                      R. Nakamura, K. Okrafka, F. Plaschke, I. Richter, H. Schwarzl,
;                      B. Stoll, A. Valavanoglou, and M. Wiedemann "The THEMIS Fluxgate
;                      Magnetometer," Space Sci. Rev. 141, pp. 235-264, (2008).
;               4)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;
;   CREATED:  12/05/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/13/2016   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;;  Electron mass [kg]
mp             = 1.6726217770d-27     ;;  Proton mass [kg]
ma             = 6.6446567500d-27     ;;  Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;;  Speed of light in vacuum [m/s]
epo            = 8.8541878170d-12     ;;  Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;;  Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;;  Fundamental charge [C]
kB             = 1.3806488000d-23     ;;  Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;;  Planck Constant [J s]
GG             = 6.6738400000d-11     ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [J]
;;  Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K
R_E            = 6.37814d3            ;;  Earth's Equatorial Radius [km]

vers           = !VERSION.OS_FAMILY   ;;  e.g., 'unix'
vern           = !VERSION.RELEASE     ;;  e.g., '7.1.1'

slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
all_scs        = ['a','b','c','d','e']
coord_ssl      = 'ssl'
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
;;  Define dummy error messages
dummy_errmsg   = ['You have not defined the proper input!',          $
                  'This batch routine expects three inputs',         $
                  'with following EXACT variable names:',            $
                  "date   ;; e.g., '072608' for July 26, 2008",      $
                  "tdate  ;; e.g., '2008-07-26' for July 26, 2008",  $
                  "probe  ;; e.g., 'b' for Probe B"                  ]
nderrmsg       = N_ELEMENTS(dummy_errmsg) - 1L
;;----------------------------------------------------------------------------------------
;;  Define and times/dates Probe from input
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(date) EQ 0) OR (N_ELEMENTS(tdate) EQ 0) OR $
                 (N_ELEMENTS(probe) EQ 0)
IF (test) THEN FOR pj=0L, nderrmsg[0] DO PRINT,dummy_errmsg[pj]
IF (test) THEN STOP        ;;  Stop before user runs into issues
;;  Check TDATE format
test           = test_tdate_format(tdate)
IF (test EQ 0) THEN STOP        ;;  Stop before user runs into issues

sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
scpref         = pref[0]
scu            = STRUPCASE(sc[0])
;;  Default to entire day
tr_00          = tdate[0]+'/'+['00:00:00.000','23:59:59.999']
;;  Make sure valid time range
trange         = time_double(tr_00)
test           = get_valid_trange(TRANGE=trange,PRECISION=6)
IF (SIZE(test,/TYPE) NE 8) THEN STOP        ;;  Stop before user runs into issues
;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
themis_load_fgm_esa_inst,DATE=date[0],PROBE=probe[0],TRANGE=trange,              $
                         /LOAD_EESA_DF,EESA_DF_OUT=poynter_peeb,/LOAD_IESA_DF,   $
                         IESA_DF_OUT=poynter_peib,ESA_BF_TYPE='both'
;themis_load_fgm_esa_inst,DATE=date[0],PROBE=probe[0],TRANGE=time_double(tr_00), $
;                         /LOAD_EESA_DF,EESA_DF_OUT=poynter_peeb,/LOAD_IESA_DF, $
;                         IESA_DF_OUT=poynter_peib,ESA_BF_TYPE='both'
;;----------------------------------------------------------------------------------------
;;  Set defaults
;;----------------------------------------------------------------------------------------
;;  Set defaults
lbw_tplot_set_defaults

;;  Change options for energy spectrogram counts
;;    --> Fix Y-Axis ranges
scpref         = 'th'+sc[0]+'_'
tpn_en_cnt_e   = tnames(scpref[0]+'pee*_en_counts')
tpn_en_cnt_i   = tnames(scpref[0]+'pei*_en_counts')
options,[tpn_en_cnt_e,tpn_en_cnt_i],'YRANGE'
options,[tpn_en_cnt_e,tpn_en_cnt_i],'YRANGE',[5d0,35d3],/DEF
;;    --> Fix interpolation options
options,[tpn_en_cnt_e,tpn_en_cnt_i],'X_NO_INTERP'
options,[tpn_en_cnt_e,tpn_en_cnt_i],'Y_NO_INTERP'
options,[tpn_en_cnt_e,tpn_en_cnt_i],'X_NO_INTERP',0,/DEF
options,[tpn_en_cnt_e,tpn_en_cnt_i],'Y_NO_INTERP',0,/DEF
;;    --> Fix # of Z-Axis tick marks
options,[tpn_en_cnt_e,tpn_en_cnt_i],'ZTICKS'
options,[tpn_en_cnt_e,tpn_en_cnt_i],'ZTICKS',4,/DEF

;;  Open window
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*9d-1
WINDOW,0,RETAIN=2,XSIZE=wsz[0],YSIZE=wsz[1],TITLE='THEMIS-'+scu[0]+' Plots ['+tdate[0]+']'
;;----------------------------------------------------------------------------------------
;;  Plot FGM magnitudes
;;----------------------------------------------------------------------------------------
scpref         = 'th'+sc[0]+'_'

modes_slh      = ['s','l','h']
mode_fgm       = 'fg'+modes_slh
fgm_pren       = scpref[0]+mode_fgm+'_'
fgm_mag        = tnames(fgm_pren[*]+'mag')
tplot,fgm_mag

;;  Fix Y-Axis titles for frequencies
options,scpref[0]+'fgs_fci_flh_fce','YTITLE' 
options,scpref[0]+'fgs_fci_flh_fce','YTITLE',mode_fgm[0]+' [fci,flh,fce]',/DEF
;;----------------------------------------------------------------------------------------
;;  Save moments
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
;;  Define the current working directory character
;;    e.g., './' [for unix and linux] otherwise guess './' or '.\'
test           = (vern[0] GE '6.0')
IF (test[0]) THEN cwd_char = FILE_DIRNAME('',/MARK_DIRECTORY) ELSE cwd_char = '.'+slash[0]
;;  Create Data Directory for files
cur_wdir       = FILE_EXPAND_PATH(cwd_char[0])
;;  Check for trailing '/'
ll             = STRMID(cur_wdir[0], STRLEN(cur_wdir[0]) - 1L,1L)
test_ll        = (ll[0] NE slash[0])
IF (test_ll[0]) THEN cur_wdir = cur_wdir[0]+slash[0]
;;  Define new directory
new_ts_dir     = cur_wdir[0]+'themis_data_dir'+slash[0]
new_esa_dir    = new_ts_dir[0]+'themis_esa_save'+slash[0]+tdate[0]+slash[0]
FILE_MKDIR,new_ts_dir[0]
FILE_MKDIR,new_esa_dir[0]
;;  Define file name for TPLOT save file
fpref          = new_ts_dir[0]+'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 2008-07-26_0801x09
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]
tplot_save,FILENAME=fname[0]
;;----------------------------------------------------------------------------------------
;;  Define ESA DF IDL Data Structures
;;----------------------------------------------------------------------------------------
all_scs        = ['a','b','c','d','e']
p_test         = WHERE(all_scs EQ sc[0],pt)
p_t_arr        = [(p_test[0] EQ 0),(p_test[0] EQ 1),(p_test[0] EQ 2),(p_test[0] EQ 3),(p_test[0] EQ 4)]

nef            = 0L
nif            = 0L
neb            = 0L
nib            = 0L
mergedstre     = merge_themis_esa_structs(poynter_peeb)
IF (SIZE(mergedstre,/TYPE) EQ 8) THEN nef = N_ELEMENTS(mergedstre.FULL)
IF (SIZE(mergedstre,/TYPE) EQ 8) THEN neb = N_ELEMENTS(mergedstre.BURST)
mergedstri     = merge_themis_esa_structs(poynter_peib)
IF (SIZE(mergedstri,/TYPE) EQ 8) THEN nif = N_ELEMENTS(mergedstri.FULL)
IF (SIZE(mergedstri,/TYPE) EQ 8) THEN nib = N_ELEMENTS(mergedstri.BURST)

;;  EESA Full
IF (p_t_arr[0]) THEN IF (nef[0] GT 0) THEN peef_df_arr_a = mergedstre.FULL
IF (p_t_arr[1]) THEN IF (nef[0] GT 0) THEN peef_df_arr_b = mergedstre.FULL
IF (p_t_arr[2]) THEN IF (nef[0] GT 0) THEN peef_df_arr_c = mergedstre.FULL
IF (p_t_arr[3]) THEN IF (nef[0] GT 0) THEN peef_df_arr_d = mergedstre.FULL
IF (p_t_arr[4]) THEN IF (nef[0] GT 0) THEN peef_df_arr_e = mergedstre.FULL
;;  EESA Burst
IF (p_t_arr[0]) THEN IF (neb[0] GT 0) THEN peeb_df_arr_a = mergedstre.BURST
IF (p_t_arr[1]) THEN IF (neb[0] GT 0) THEN peeb_df_arr_b = mergedstre.BURST
IF (p_t_arr[2]) THEN IF (neb[0] GT 0) THEN peeb_df_arr_c = mergedstre.BURST
IF (p_t_arr[3]) THEN IF (neb[0] GT 0) THEN peeb_df_arr_d = mergedstre.BURST
IF (p_t_arr[4]) THEN IF (neb[0] GT 0) THEN peeb_df_arr_e = mergedstre.BURST

;;  IESA Full
IF (p_t_arr[0]) THEN IF (nif[0] GT 0) THEN peif_df_arr_a = mergedstri.FULL
IF (p_t_arr[1]) THEN IF (nif[0] GT 0) THEN peif_df_arr_b = mergedstri.FULL
IF (p_t_arr[2]) THEN IF (nif[0] GT 0) THEN peif_df_arr_c = mergedstri.FULL
IF (p_t_arr[3]) THEN IF (nif[0] GT 0) THEN peif_df_arr_d = mergedstri.FULL
IF (p_t_arr[4]) THEN IF (nif[0] GT 0) THEN peif_df_arr_e = mergedstri.FULL
;;  IESA Burst
IF (p_t_arr[0]) THEN IF (nib[0] GT 0) THEN peib_df_arr_a = mergedstri.BURST
IF (p_t_arr[1]) THEN IF (nib[0] GT 0) THEN peib_df_arr_b = mergedstri.BURST
IF (p_t_arr[2]) THEN IF (nib[0] GT 0) THEN peib_df_arr_c = mergedstri.BURST
IF (p_t_arr[3]) THEN IF (nib[0] GT 0) THEN peib_df_arr_d = mergedstri.BURST
IF (p_t_arr[4]) THEN IF (nib[0] GT 0) THEN peib_df_arr_e = mergedstri.BURST

;;  Inform user of defined parameters
HELP, peeb_df_arr_a,peeb_df_arr_b,peeb_df_arr_c,peeb_df_arr_d,peeb_df_arr_e
HELP, peib_df_arr_a,peib_df_arr_b,peib_df_arr_c,peib_df_arr_d,peib_df_arr_e
HELP, peef_df_arr_a,peef_df_arr_b,peef_df_arr_c,peef_df_arr_d,peef_df_arr_e
HELP, peif_df_arr_a,peif_df_arr_b,peif_df_arr_c,peif_df_arr_d,peif_df_arr_e
test_ef        = [(N_ELEMENTS(peef_df_arr_a) GT 0),$
                  (N_ELEMENTS(peef_df_arr_b) GT 0),$
                  (N_ELEMENTS(peef_df_arr_c) GT 0),$
                  (N_ELEMENTS(peef_df_arr_d) GT 0),$
                  (N_ELEMENTS(peef_df_arr_e) GT 0)]
test_eb        = [(N_ELEMENTS(peeb_df_arr_a) GT 0),$
                  (N_ELEMENTS(peeb_df_arr_b) GT 0),$
                  (N_ELEMENTS(peeb_df_arr_c) GT 0),$
                  (N_ELEMENTS(peeb_df_arr_d) GT 0),$
                  (N_ELEMENTS(peeb_df_arr_e) GT 0)]
test_if        = [(N_ELEMENTS(peif_df_arr_a) GT 0),$
                  (N_ELEMENTS(peif_df_arr_b) GT 0),$
                  (N_ELEMENTS(peif_df_arr_c) GT 0),$
                  (N_ELEMENTS(peif_df_arr_d) GT 0),$
                  (N_ELEMENTS(peif_df_arr_e) GT 0)]
test_ib        = [(N_ELEMENTS(peib_df_arr_a) GT 0),$
                  (N_ELEMENTS(peib_df_arr_b) GT 0),$
                  (N_ELEMENTS(peib_df_arr_c) GT 0),$
                  (N_ELEMENTS(peib_df_arr_d) GT 0),$
                  (N_ELEMENTS(peib_df_arr_e) GT 0)]
;;----------------------------------------------------------------------------------------
;;  Combine Full and Burst if both present
;;----------------------------------------------------------------------------------------
;;  Define dummy arrays for EESA
IF (p_t_arr[0]) THEN IF (test_ef[0]) THEN dat_ef = peeb_df_arr_a
IF (p_t_arr[1]) THEN IF (test_ef[1]) THEN dat_ef = peeb_df_arr_b
IF (p_t_arr[2]) THEN IF (test_ef[2]) THEN dat_ef = peeb_df_arr_c
IF (p_t_arr[3]) THEN IF (test_ef[3]) THEN dat_ef = peeb_df_arr_d
IF (p_t_arr[4]) THEN IF (test_ef[4]) THEN dat_ef = peeb_df_arr_e
IF (p_t_arr[0]) THEN IF (test_eb[0]) THEN dat_eb = peeb_df_arr_a
IF (p_t_arr[1]) THEN IF (test_eb[1]) THEN dat_eb = peeb_df_arr_b
IF (p_t_arr[2]) THEN IF (test_eb[2]) THEN dat_eb = peeb_df_arr_c
IF (p_t_arr[3]) THEN IF (test_eb[3]) THEN dat_eb = peeb_df_arr_d
IF (p_t_arr[4]) THEN IF (test_eb[4]) THEN dat_eb = peeb_df_arr_e
;;  Define dummy arrays for IESA
IF (p_t_arr[0]) THEN IF (test_if[0]) THEN dat_if = peib_df_arr_a
IF (p_t_arr[1]) THEN IF (test_if[1]) THEN dat_if = peib_df_arr_b
IF (p_t_arr[2]) THEN IF (test_if[2]) THEN dat_if = peib_df_arr_c
IF (p_t_arr[3]) THEN IF (test_if[3]) THEN dat_if = peib_df_arr_d
IF (p_t_arr[4]) THEN IF (test_if[4]) THEN dat_if = peib_df_arr_e
IF (p_t_arr[0]) THEN IF (test_ib[0]) THEN dat_ib = peib_df_arr_a
IF (p_t_arr[1]) THEN IF (test_ib[1]) THEN dat_ib = peib_df_arr_b
IF (p_t_arr[2]) THEN IF (test_ib[2]) THEN dat_ib = peib_df_arr_c
IF (p_t_arr[3]) THEN IF (test_ib[3]) THEN dat_ib = peib_df_arr_d
IF (p_t_arr[4]) THEN IF (test_ib[4]) THEN dat_ib = peib_df_arr_e
;;  Define combined dummy arrays
good_e         = WHERE([(nef[0] GT 0),(neb[0] GT 0)],gd_e)
test_e         = [(gd_e[0] GT [0,1]),[good_e[0] EQ [0,1]]]
good_i         = WHERE([(nif[0] GT 0),(nib[0] GT 0)],gd_i)
test_i         = [(gd_i[0] GT [0,1]),[good_i[0] EQ [0,1]]]
IF (test_e[1]) THEN dat_e = [dat_ef,dat_eb] ELSE $
  IF (test_e[0]) THEN IF (test_e[2]) THEN dat_e = dat_ef ELSE IF (test_e[3]) THEN dat_e = dat_eb
IF (test_i[1]) THEN dat_i = [dat_if,dat_ib] ELSE $
  IF (test_i[0]) THEN IF (test_i[2]) THEN dat_i = dat_if ELSE IF (test_i[3]) THEN dat_i = dat_ib
IF (TOTAL([test_e[1],test_i[1]]) GT 0) THEN smid_fnm = '_Both_THEMIS_' ELSE smid_fnm = '_Burst_THEMIS_'
;IF (TOTAL(tests) GT 0) THEN smid_fnm = '_Both_THEMIS_' ELSE smid_fnm = '_Burst_THEMIS_'

;;  Sort by time
n_e            = N_ELEMENTS(dat_e)
n_i            = N_ELEMENTS(dat_i)
IF (n_e[0] GT 0) THEN sp_e = SORT(dat_e.TIME) ELSE sp_e = -1
IF (n_i[0] GT 0) THEN sp_i = SORT(dat_i.TIME) ELSE sp_i = -1
IF (n_e[0] GT 0) THEN dat_e = TEMPORARY(dat_e[sp_e])
IF (n_i[0] GT 0) THEN dat_i = TEMPORARY(dat_i[sp_i])
;;  Define output arrays for IDL save files
;;  EESA
IF (p_t_arr[0] AND (n_e[0] GT 0)) THEN peeb_df_arr_a = dat_e
IF (p_t_arr[1] AND (n_e[0] GT 0)) THEN peeb_df_arr_b = dat_e
IF (p_t_arr[2] AND (n_e[0] GT 0)) THEN peeb_df_arr_c = dat_e
IF (p_t_arr[3] AND (n_e[0] GT 0)) THEN peeb_df_arr_d = dat_e
IF (p_t_arr[4] AND (n_e[0] GT 0)) THEN peeb_df_arr_e = dat_e
;;  IESA
IF (p_t_arr[0] AND (n_i[0] GT 0)) THEN peib_df_arr_a = dat_i
IF (p_t_arr[1] AND (n_i[0] GT 0)) THEN peib_df_arr_b = dat_i
IF (p_t_arr[2] AND (n_i[0] GT 0)) THEN peib_df_arr_c = dat_i
IF (p_t_arr[3] AND (n_i[0] GT 0)) THEN peib_df_arr_d = dat_i
IF (p_t_arr[4] AND (n_i[0] GT 0)) THEN peib_df_arr_e = dat_i
;;----------------------------------------------------------------------------------------
;;  Use Generalized Save Commands
;;----------------------------------------------------------------------------------------
enames         = new_esa_dir[0]+'EESA'+smid_fnm[0]+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames         = new_esa_dir[0]+'IESA'+smid_fnm[0]+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'

ei_str         = ['e','i']
inst_str       = 'pe'+ei_str+'b_df_arr_'
ei_suffx       = ',FILENAME='+ei_str+'names[0]'
exc_str_ei     = 'SAVE,'+inst_str+sc[0]+ei_suffx

;;   Save Electrons
test_e         = EXECUTE(exc_str_ei[0])
;;   Save Ions
test_i         = EXECUTE(exc_str_ei[1])

;;  Remove FULL distribution variables
DELVAR,peef_df_arr_a,peef_df_arr_b,peef_df_arr_c,peef_df_arr_d,peef_df_arr_e
DELVAR,peif_df_arr_a,peif_df_arr_b,peif_df_arr_c,peif_df_arr_d,peif_df_arr_e
;;  Remove dummy arrays
IF ~KEYWORD_SET(no_clean) THEN DELVAR,dat_e,dat_i,n_e,n_i
DELVAR,sp_e,sp_i,test_e,test_i
DELVAR,dat_ef,dat_if,dat_eb,dat_ib,test_ef,test_if,test_eb,test_ib
;;  Remove combined (or BURST) distributions if desired
DELVAR,peeb_df_arr_a,peeb_df_arr_b,peeb_df_arr_c,peeb_df_arr_d,peeb_df_arr_e
DELVAR,peib_df_arr_a,peib_df_arr_b,peib_df_arr_c,peib_df_arr_d,peib_df_arr_e
DELVAR,testj,temp,p_t_arr,p_test,mergedstre,mergedstri
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------









;IF (p_t_arr[0]) THEN IF (test_e[0]) THEN dat_e = [peeb_df_arr_a,peef_df_arr_a] ELSE dat_e = peeb_df_arr_a
;IF (p_t_arr[1]) THEN IF (test_e[1]) THEN dat_e = [peeb_df_arr_b,peef_df_arr_b] ELSE dat_e = peeb_df_arr_b
;IF (p_t_arr[2]) THEN IF (test_e[2]) THEN dat_e = [peeb_df_arr_c,peef_df_arr_c] ELSE dat_e = peeb_df_arr_c
;IF (p_t_arr[3]) THEN IF (test_e[3]) THEN dat_e = [peeb_df_arr_d,peef_df_arr_d] ELSE dat_e = peeb_df_arr_d
;IF (p_t_arr[4]) THEN IF (test_e[4]) THEN dat_e = [peeb_df_arr_e,peef_df_arr_e] ELSE dat_e = peeb_df_arr_e
;IF (p_t_arr[0]) THEN IF (test_i[0]) THEN dat_i = [peib_df_arr_a,peif_df_arr_a] ELSE dat_i = 
;IF (p_t_arr[1]) THEN IF (test_i[1]) THEN dat_i = [peib_df_arr_b,peif_df_arr_b] ELSE dat_i = 
;IF (p_t_arr[2]) THEN IF (test_i[2]) THEN dat_i = [peib_df_arr_c,peif_df_arr_c] ELSE dat_i = 
;IF (p_t_arr[3]) THEN IF (test_i[3]) THEN dat_i = [peib_df_arr_d,peif_df_arr_d] ELSE dat_i = 
;IF (p_t_arr[4]) THEN IF (test_i[4]) THEN dat_i = [peib_df_arr_e,peif_df_arr_e] ELSE dat_i = 

;IF (p_t_arr[0]) THEN IF (test_e[0]) THEN peeb_df_arr_a = dat_e
;IF (p_t_arr[1]) THEN IF (test_e[1]) THEN peeb_df_arr_b = dat_e
;IF (p_t_arr[2]) THEN IF (test_e[2]) THEN peeb_df_arr_c = dat_e
;IF (p_t_arr[3]) THEN IF (test_e[3]) THEN peeb_df_arr_d = dat_e
;IF (p_t_arr[4]) THEN IF (test_e[4]) THEN peeb_df_arr_e = dat_e
;
;IF (p_t_arr[0]) THEN IF (test_i[0]) THEN peib_df_arr_a = dat_i
;IF (p_t_arr[1]) THEN IF (test_i[1]) THEN peib_df_arr_b = dat_i
;IF (p_t_arr[2]) THEN IF (test_i[2]) THEN peib_df_arr_c = dat_i
;IF (p_t_arr[3]) THEN IF (test_i[3]) THEN peib_df_arr_d = dat_i
;IF (p_t_arr[4]) THEN IF (test_i[4]) THEN peib_df_arr_e = dat_i

;IF ~KEYWORD_SET(no_clean) THEN DELVAR,peeb_df_arr_a,peeb_df_arr_b,peeb_df_arr_c,peeb_df_arr_d,peeb_df_arr_e
;IF ~KEYWORD_SET(no_clean) THEN DELVAR,peib_df_arr_a,peib_df_arr_b,peib_df_arr_c,peib_df_arr_d,peib_df_arr_e


;nef            = N_ELEMENTS(poynter_peeb.FULL)
;nif            = N_ELEMENTS(poynter_peib.FULL)
;neb            = N_ELEMENTS(poynter_peeb.BURST)
;nib            = N_ELEMENTS(poynter_peib.BURST)
;
;;;  EESA Full
;FOR j=0L, nef[0] - 1L DO BEGIN                                                                              $
;  temp  = *(poynter_peeb.FULL)[j]                                                                         & $
;  testj = (j[0] EQ 0)                                                                                     & $
;  IF (p_t_arr[0]) THEN IF (testj[0]) THEN peef_df_arr_a = temp ELSE peef_df_arr_a = [peef_df_arr_a,temp]  & $ ;;  Probe A
;  IF (p_t_arr[1]) THEN IF (testj[0]) THEN peef_df_arr_b = temp ELSE peef_df_arr_b = [peef_df_arr_b,temp]  & $ ;;  Probe B
;  IF (p_t_arr[2]) THEN IF (testj[0]) THEN peef_df_arr_c = temp ELSE peef_df_arr_c = [peef_df_arr_c,temp]  & $ ;;  Probe C
;  IF (p_t_arr[3]) THEN IF (testj[0]) THEN peef_df_arr_d = temp ELSE peef_df_arr_d = [peef_df_arr_d,temp]  & $ ;;  Probe D
;  IF (p_t_arr[4]) THEN IF (testj[0]) THEN peef_df_arr_e = temp ELSE peef_df_arr_e = [peef_df_arr_e,temp]      ;;  Probe E
;
;;;  EESA Burst
;FOR j=0L, neb[0] - 1L DO BEGIN                                                                              $
;  temp  = *(poynter_peeb.BURST)[j]                                                                        & $
;  testj = (j[0] EQ 0)                                                                                     & $
;  IF (p_t_arr[0]) THEN IF (testj[0]) THEN peeb_df_arr_a = temp ELSE peeb_df_arr_a = [peeb_df_arr_a,temp]  & $ ;;  Probe A
;  IF (p_t_arr[1]) THEN IF (testj[0]) THEN peeb_df_arr_b = temp ELSE peeb_df_arr_b = [peeb_df_arr_b,temp]  & $ ;;  Probe B
;  IF (p_t_arr[2]) THEN IF (testj[0]) THEN peeb_df_arr_c = temp ELSE peeb_df_arr_c = [peeb_df_arr_c,temp]  & $ ;;  Probe C
;  IF (p_t_arr[3]) THEN IF (testj[0]) THEN peeb_df_arr_d = temp ELSE peeb_df_arr_d = [peeb_df_arr_d,temp]  & $ ;;  Probe D
;  IF (p_t_arr[4]) THEN IF (testj[0]) THEN peeb_df_arr_e = temp ELSE peeb_df_arr_e = [peeb_df_arr_e,temp]      ;;  Probe E
;
;;;  IESA Full
;FOR j=0L, nif[0] - 1L DO BEGIN                                                                              $
;  temp  = *(poynter_peib.FULL)[j]                                                                         & $
;  testj = (j[0] EQ 0)                                                                                     & $
;  IF (p_t_arr[0]) THEN IF (testj[0]) THEN peif_df_arr_a = temp ELSE peif_df_arr_a = [peif_df_arr_a,temp]  & $ ;;  Probe A
;  IF (p_t_arr[1]) THEN IF (testj[0]) THEN peif_df_arr_b = temp ELSE peif_df_arr_b = [peif_df_arr_b,temp]  & $ ;;  Probe B
;  IF (p_t_arr[2]) THEN IF (testj[0]) THEN peif_df_arr_c = temp ELSE peif_df_arr_c = [peif_df_arr_c,temp]  & $ ;;  Probe C
;  IF (p_t_arr[3]) THEN IF (testj[0]) THEN peif_df_arr_d = temp ELSE peif_df_arr_d = [peif_df_arr_d,temp]  & $ ;;  Probe D
;  IF (p_t_arr[4]) THEN IF (testj[0]) THEN peif_df_arr_e = temp ELSE peif_df_arr_e = [peif_df_arr_e,temp]      ;;  Probe E
;
;;;  IESA Burst
;FOR j=0L, nib[0] - 1L DO BEGIN                                                                              $
;  temp  = *(poynter_peib.BURST)[j]                                                                        & $
;  testj = (j[0] EQ 0)                                                                                     & $
;  IF (p_t_arr[0]) THEN IF (testj[0]) THEN peib_df_arr_a = temp ELSE peib_df_arr_a = [peib_df_arr_a,temp]  & $ ;;  Probe A
;  IF (p_t_arr[1]) THEN IF (testj[0]) THEN peib_df_arr_b = temp ELSE peib_df_arr_b = [peib_df_arr_b,temp]  & $ ;;  Probe B
;  IF (p_t_arr[2]) THEN IF (testj[0]) THEN peib_df_arr_c = temp ELSE peib_df_arr_c = [peib_df_arr_c,temp]  & $ ;;  Probe C
;  IF (p_t_arr[3]) THEN IF (testj[0]) THEN peib_df_arr_d = temp ELSE peib_df_arr_d = [peib_df_arr_d,temp]  & $ ;;  Probe D
;  IF (p_t_arr[4]) THEN IF (testj[0]) THEN peib_df_arr_e = temp ELSE peib_df_arr_e = [peib_df_arr_e,temp]      ;;  Probe E
