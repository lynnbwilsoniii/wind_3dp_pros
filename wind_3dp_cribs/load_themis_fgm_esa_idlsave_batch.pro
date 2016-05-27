;+
;*****************************************************************************************
;
;  BATCH    :   load_themis_fgm_esa_idlsave_batch.pro
;  PURPOSE  :   This is a batch file to be called from the command line using the
;                 standard method of calling
;                 (i.e., @load_themis_fgm_esa_idlsave_batch.pro).
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               test_tdate_format.pro
;               time_double.pro
;               get_valid_trange.pro
;               file_name_times.pro
;               tplot_restore.pro
;               tnames.pro
;               tplot_options.pro
;               lbw_tplot_set_defaults.pro
;               tplot.pro
;               modify_themis_esa_struc.pro
;               add_scpot.pro
;               rotate_esa_thetaphi_to_gse.pro
;               add_magf2.pro
;               add_vsw2.pro
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
;               probe          = 'b'           ;;  Probe B
;               tdate          = '2008-07-26'  ;;  July 26, 2008
;               date           = '072608'      ;;  July 26, 2008
;               ;;  Define the current working directory character
;               ;;    e.g., './' [for unix and linux] otherwise guess './' or '.\'
;               test           = (vern[0] GE '6.0')
;               IF (test[0]) THEN cwd_char = FILE_DIRNAME('',/MARK_DIRECTORY) ELSE $
;                                 cwd_char = '.'+slash[0]
;               ;;  Define location of the THEMIS IDL save files
;               ;;  **********************************************
;               ;;  **     this will change for your system     **
;               ;;  **********************************************
;               th_data_dir    = cur_wdir[0]+'IDL_stuff'+slash[0]+'themis_data_dir'+slash[0]
;               ;;  Load data previously saved using @load_save_themis_fgm_esa_batch.pro
;               @load_themis_fgm_esa_idlsave_batch.pro
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Fixed a typo in definition of dat_i and dat_e
;                                                                   [12/09/2014   v1.0.1]
;             2)  Now calls test_tdate_format.pro, get_valid_trange.pro, and
;                   lbw_tplot_set_defaults.pro
;                                                                   [10/23/2015   v1.1.0]
;
;   NOTES:      
;               0)  See also:  load_save_themis_fgm_esa_batch.pro
;               1)  This batch routine expects a date (in two formats) and a probe,
;                     all input on the command line prior to calling (see EXAMPLES)
;               2)  If your paths are not set correctly, you may need to provide a full
;                     path to this routine, e.g., on my machine this is:
;               @$HOME/wind_3dp_pros/wind_3dp_cribs/load_themis_fgm_esa_idlsave_batch.pro
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
;               6)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;
;   CREATED:  12/05/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/23/2015   v1.1.0
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
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
all_scs        = ['a','b','c','d','e']
coord_ssl      = 'ssl'
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
;;  Define dummy error messages
dummy_errmsg   = ['You have not defined the proper input!',                $
                  'This batch routine expects three inputs',               $
                  'with following EXACT variable names:',                  $
                  "date         ;; e.g., '072608' for July 26, 2008",      $
                  "tdate        ;; e.g., '2008-07-26' for July 26, 2008",  $
                  "probe        ;; e.g., 'b' for Probe B",                 $
                  "th_data_dir  ;; e.g., './IDL_stuff/themis_data_dir/'"   ]
nderrmsg       = N_ELEMENTS(dummy_errmsg) - 1L
;;----------------------------------------------------------------------------------------
;;  Define and times/dates Probe from input
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(date) EQ 0) OR (N_ELEMENTS(tdate) EQ 0) OR $
                 (N_ELEMENTS(probe) EQ 0) OR (N_ELEMENTS(th_data_dir) EQ 0)
IF (test) THEN FOR pj=0L, nderrmsg[0] DO PRINT,dummy_errmsg[pj]
IF (test) THEN STOP        ;;  Stop before user runs into issues
;;  Check TDATE format
test           = test_tdate_format(tdate)
IF (test EQ 0) THEN STOP        ;;  Stop before user runs into issues
;;----------------------------------------------------------------------------------------
;;  Define and times/dates Probe from input
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
scpref         = pref[0]
scu            = STRUPCASE(sc[0])
p_test         = WHERE(all_scs EQ sc[0],pt)
p_t_arr        = [(p_test[0] EQ 0),(p_test[0] EQ 1),(p_test[0] EQ 2),(p_test[0] EQ 3),(p_test[0] EQ 4)]
;;  Default to entire day
tr_00          = tdate[0]+'/'+[start_of_day_t[0],end___of_day_t[0]]
;tr_00          = tdate[0]+'/'+['00:00:00.000','23:59:59.999']
tr_jj          = time_double(tr_00)
;;  Make sure valid time range
test           = get_valid_trange(TRANGE=tr_jj,PRECISION=6)
IF (SIZE(test,/TYPE) NE 8) THEN STOP        ;;  Stop before user runs into issues
;;----------------------------------------------------------------------------------------
;;  Find all relevant data
;;----------------------------------------------------------------------------------------
;;  Define location of IDL save files
tpnsave_dir    = th_data_dir[0]+'themis_tplot_save'
esasave_dir    = th_data_dir[0]+'themis_esa_save'+slash[0]+tdate[0]
;;  Define file names for the IDL save files
tpn_fpref      = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_'
fnm            = file_name_times(tr_jj,PREC=0)
;fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = tpn_fpref[0]+tsuffx[0]+'.tplot'
enames         = 'EESA_*_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames         = 'IESA_*_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
;;  Find IDL save files
tpn__file      = FILE_SEARCH(tpnsave_dir[0],fname[0])
eesa_file      = FILE_SEARCH(esasave_dir[0],enames[0])
iesa_file      = FILE_SEARCH(esasave_dir[0],inames[0])
;;  Define tests
test_tpnf      = (tpn__file[0] NE '')
;;  If file was not found, try again without specific time range
IF (test_tpnf[0] EQ 0) THEN fname     = tpn_fpref[0]+tdate[0]+'*.tplot'
IF (test_tpnf[0] EQ 0) THEN tpn__file = FILE_SEARCH(tpnsave_dir[0],fname[0])
IF (test_tpnf[0] EQ 0) THEN test_tpnf = (tpn__file[0] NE '')
test_eesa      = (eesa_file[0] NE '')
test_iesa      = (iesa_file[0] NE '')
;;----------------------------------------------------------------------------------------
;;  Load TPLOT data
;;----------------------------------------------------------------------------------------
IF (test_tpnf[0] EQ 0) THEN STOP
IF (test_tpnf[0]) THEN tplot_restore,FILENAME=tpn__file[0],VERBOSE=0

;;  Define tick marks
IF (test_tpnf[0]) THEN pos_gse        = tnames(scpref[0]+'state_pos_'+coord_gse[0]+'_*')
IF (test_tpnf[0]) THEN rad_pos_tpnm   = tnames(scpref[0]+'_Rad')
IF (test_tpnf[0]) THEN names2         = [pos_gse,rad_pos_tpnm[0]]
IF (test_tpnf[0]) THEN tplot_options,VAR_LABEL=names2
;;  Set defaults
lbw_tplot_set_defaults
;IF (test_tpnf[0]) THEN !themis.VERBOSE = 2
;IF (test_tpnf[0]) THEN tplot_options,'VERBOSE',2
;IF (test_tpnf[0]) THEN options,tnames(),'LABFLAG',2,/DEF
;;;  Remove color table from default options
;IF (test_tpnf[0]) THEN options,tnames(),'COLOR_TABLE',/DEF
;IF (test_tpnf[0]) THEN options,tnames(),'COLOR_TABLE'
;IF (test_tpnf[0]) THEN tplot_options,'NO_INTERP',0  ;;  Allow interpolation in spectrograms
;IF (test_tpnf[0]) THEN nnw            = tnames()
;IF (test_tpnf[0]) THEN options,nnw,'YSTYLE',1
;IF (test_tpnf[0]) THEN options,nnw,'PANEL_SIZE',2.
;IF (test_tpnf[0]) THEN options,nnw,'XMINOR',5
;IF (test_tpnf[0]) THEN options,nnw,'XTICKLEN',0.04
;IF (test_tpnf[0]) THEN options,nnw,'YTICKLEN',0.01

;;  Open window
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*9d-1
WINDOW,0,RETAIN=2,XSIZE=wsz[0],YSIZE=wsz[1],TITLE='THEMIS-'+scu[0]+' Plots ['+tdate[0]+']'

;;  Plot fgh
IF (test_tpnf[0]) THEN magname        = scpref[0]+'fgh_'+coord_gse[0]
IF (test_tpnf[0]) THEN fgmnm          = scpref[0]+'fgh_'+['mag',coord_gse[0]]
IF (test_tpnf[0]) THEN tplot,fgmnm,TRANGE=tr_jj
;;----------------------------------------------------------------------------------------
;;  Load ESA data
;;----------------------------------------------------------------------------------------
IF (test_eesa[0]) THEN RESTORE,eesa_file[0]  ;;  Restore EESA structures
IF (test_iesa[0]) THEN RESTORE,iesa_file[0]  ;;  Restore IESA structures

IF (test_iesa[0] AND p_t_arr[0]) THEN dat_i = peib_df_arr_a
IF (test_iesa[0] AND p_t_arr[1]) THEN dat_i = peib_df_arr_b
IF (test_iesa[0] AND p_t_arr[2]) THEN dat_i = peib_df_arr_c
IF (test_iesa[0] AND p_t_arr[3]) THEN dat_i = peib_df_arr_d
IF (test_iesa[0] AND p_t_arr[4]) THEN dat_i = peib_df_arr_e

IF (test_eesa[0] AND p_t_arr[0]) THEN dat_e = peeb_df_arr_a
IF (test_eesa[0] AND p_t_arr[1]) THEN dat_e = peeb_df_arr_b
IF (test_eesa[0] AND p_t_arr[2]) THEN dat_e = peeb_df_arr_c
IF (test_eesa[0] AND p_t_arr[3]) THEN dat_e = peeb_df_arr_d
IF (test_eesa[0] AND p_t_arr[4]) THEN dat_e = peeb_df_arr_e

n_i            = N_ELEMENTS(dat_i)
n_e            = N_ELEMENTS(dat_e)
PRINT,';;  Ni = ', n_i[0]
PRINT,';;  Ne = ', n_e[0]
;;----------------------------------------------------------------------------------------
;;  Modify structures so they work in my plotting routines
;;----------------------------------------------------------------------------------------
velname        = tnames(scpref[0]+'peib_velocity_'+coord_gse[0])
spperi         = tnames(scpref[0]+'state_spinper')
magn_0         = tnames(scpref[0]+'fgs_'+coord_gse[0])
magn_1         = tnames(scpref[0]+'fgl_'+coord_gse[0])
magn_2         = tnames(scpref[0]+'fgh_'+coord_gse[0])
scname         = tnames(scpref[0]+'peeb_sc_pot')
scnami         = tnames(scpref[0]+'peib_sc_pot')
IF (magn_2[0]  NE '') THEN magname = magn_2[0]
IF (magname[0] EQ '') THEN magname = magn_1[0]
IF (magname[0] EQ '') THEN magname = magn_0[0]

;;  Add additional structure tags to IESA structures
modify_themis_esa_struc,dat_i
;;  Add SC potential to IESA structures
add_scpot,dat_i,scnami[0]
;;  Rotate IESA structures (theta,phi)-angles DSL --> GSE
dat_igse       = dat_i
rotate_esa_thetaphi_to_gse,dat_igse,MAGF_NAME=magname[0],VEL_NAME=velname[0]
;;  Check that MAGF tag is defined
add_magf2,dat_igse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_igse,magn_2[0],/LEAVE_ALONE
;;  Check that VSW tag is defined
add_vsw2,dat_igse,velname[0],/LEAVE_ALONE

;;  Add additional structure tags to EESA structures
modify_themis_esa_struc,dat_e
;;  Add SC potential to EESA structures
add_scpot,dat_e,scname[0]
;;  Rotate IESA structures (theta,phi)-angles DSL --> GSE
dat_egse       = dat_e
rotate_esa_thetaphi_to_gse,dat_egse,MAGF_NAME=magname[0],VEL_NAME=velname[0]
;;  Check that MAGF tag is defined
add_magf2,dat_egse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_egse,magn_2[0],/LEAVE_ALONE
;;  Check that VSW tag is defined
add_vsw2,dat_egse,velname[0],/LEAVE_ALONE

;;  Clean up
DELVAR,peeb_df_arr_a,peeb_df_arr_b,peeb_df_arr_c,peeb_df_arr_d,peeb_df_arr_e
DELVAR,peib_df_arr_a,peib_df_arr_b,peib_df_arr_c,peib_df_arr_d,peib_df_arr_e

PRINT,''
PRINT,';;  Successfully loaded data for Probe-'+scu[0]+' on '+tdate[0]
PRINT,''












