;+
;*****************************************************************************************
;
;  BATCH    :   load_themis_foreshock_eVDFs_all_data_batch.pro
;  PURPOSE  :   This is a batch file that is meant to load the TPLOT save file that
;                 was created by load_themis_foreshock_eVDFs_everything_and_save_batch.pro
;
;  CALLED BY:   
;               thm_VDF_foreshock_eVDFs_all_data_crib.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               test_tdate_format.pro
;               time_double.pro
;               get_valid_trange.pro
;               add_os_slash.pro
;               tplot_restore.pro
;               lbw_tplot_set_defaults.pro
;               set_tplot_times.pro
;               tnames.pro
;               options.pro
;               tplot_options.pro
;               tplot.pro
;               modify_themis_esa_struc.pro
;               add_scpot.pro
;               rotate_esa_thetaphi_to_gse.pro
;               add_magf2.pro
;               add_vsw2.pro
;               test_tplot_handle.pro
;               get_data.pro
;               tplot_struct_format_test.pro
;               t_resample_tplot_struc.pro
;               unit_vec.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS 8.0 or SPEDAS 1.0 (or greater) IDL libraries
;               2)  UMN Modified Wind/3DP IDL Libraries
;               3)  TPLOT save files created by load_themis_foreshock_eVDFs_everything_and_save_batch.pro
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ;;  Initialize THEMIS defaults
;               thm_init
;               ;;  Load all State, FGM, ESA, EFI, and SCM data for 2008-07-26 for Probe B
;               ;;  **********************************************
;               ;;  **  variable names MUST exactly match these **
;               ;;  **********************************************
;               probe          = 'b'                             ;;  Spacecraft identifier/name
;               tdate          = '2008-07-26'                    ;;  Date of interest
;               date           = '072608'                        ;;  short date format
;               no_load_vdfs   = 0b                              ;;  FALSE --> load VDFs, TRUE --> do not load VDFs
;               @load_themis_foreshock_eVDFs_all_data_batch.pro
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Now loads particle VDF structures if user so desires
;                                                                   [02/05/2016   v1.1.0]
;
;   NOTES:      
;               1)  This batch routine expects a date and a probe input on the command
;                     line prior to calling (see EXAMPLES)
;               2)  If your paths are not set correctly, you may need to provide a full
;                     path to this routine, e.g., the following is figurative and should
;                     be replaced with the full file path to this batch file:
;                     @/full/file/path/to/load_themis_foreshock_eVDFs_all_data_batch.pro
;               3)  This batch routine loads FGM, ESA moments, EFI and SCM data, and
;                      particle spectra from both ESAs and SSTs from a TPLOT save file
;               4)  See also:
;                              load_thm_fields_save_tplot_batch.pro
;                              load_thm_fgm_efi_scm_2_tplot_batch.pro
;                              load_thm_fgm_efi_scm_save_tplot_batch.pro
;                              load_thm_FS_eVDFs_calc_sh_parms_batch.pro
;                              load_themis_foreshock_eVDFs_batch.pro
;                              load_themis_foreshock_eVDFs_everything_and_save_batch.pro
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
;               5)  Cully, C.M., R.E. Ergun, K. Stevens, A. Nammari, and J. Westfall
;                      "The THEMIS Digital Fields Board," Space Sci. Rev. 141,
;                      pp. 343-355, (2008).
;               6)  Roux, A., O. Le Contel, C. Coillot, A. Bouabdellah, B. de la Porte,
;                      D. Alison, S. Ruocco, and M.C. Vassal "The Search Coil
;                      Magnetometer for THEMIS," Space Sci. Rev. 141,
;                      pp. 265-275, (2008).
;               7)  Le Contel, O., A. Roux, P. Robert, C. Coillot, A. Bouabdellah,
;                      B. de la Porte, D. Alison, S. Ruocco, V. Angelopoulos,
;                      K. Bromund, C.C. Chaston, C.M. Cully, H.U. Auster,
;                      K.-H. Glassmeier, W. Baumjohann, C.W. Carlson, J.P. McFadden,
;                      and D. Larson "First Results of the THEMIS Search Coil
;                      Magnetometers," Space Sci. Rev. 141, pp. 509-534, (2008).
;
;   CREATED:  02/03/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/05/2016   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
GG             = 6.6740800000d-11         ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1), 2014 CODATA/NIST]
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
SB             = 5.6703670000d-08         ;;  Stefan-Boltzmann Constant [W m^(-2) K^(-4), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
ma_eV          = ma[0]*c[0]^2/qq[0]       ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
me_eV          = me[0]*c[0]^2/qq[0]       ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mn_eV          = mn[0]*c[0]^2/qq[0]       ;;  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c[0]^2/qq[0]       ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;  Astronomical
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2016 AA values]
M_E            = 5.9722000d24             ;;  Earth's mass [kg, 2015 AA values]
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km
;;  Conversion Factors
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
J_1eV          = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
K_eV           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
eV_K           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
valfen__fac    = 1d-9/SQRT(muo[0]*mp[0]*1d6)       ;;  factor for (proton-only) Alfvén speed [m s^(-1) nT^(-1) cm^(-3/2)]
gam            = 5d0/3d0                  ;;  Use gamma = 5/3
rho_fac        = (me[0] + mp[0])*1d6      ;;  kg, cm^(-3) --> m^(-3)
cs_fac         = SQRT(gam[0]/rho_fac[0])
;;  Useful variables
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
all_scs        = ['a','b','c','d','e']
coord_spg      = 'spg'
coord_ssl      = 'ssl'
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_fac      = 'fac'
coord_mag      = 'mag'
fb_string      = ['f','b']
vec_str        = ['x','y','z']
fac_vec_str    = ['perp1','perp2','para']
fac_dir_str    = ['para','perp','anti']
modes_slh      = ['s','l','h']
modes_fpw      = ['f','p','w']
modes_fgm      = 'fg'+modes_slh
modes_efi      = 'ef'+modes_fpw
modes_scm      = 'sc'+modes_fpw
vec_col        = [250,150,50]

start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}
;;  Define dummy time range arrays for later use
dt_70          = [-1,1]*7d1
dt_140         = [-1,1]*14d1
dt_200         = [-1,1]*20d1
dt_250         = [-1,1]*25d1
dt_400         = [-1,1]*40d1
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
IF (test[0]) THEN FOR pj=0L, nderrmsg[0] DO PRINT,dummy_errmsg[pj]
IF (test[0]) THEN PRINT,'%%  Stopping before starting...'
IF (test[0]) THEN STOP             ;;  Stop before user runs into issues
;;  Check TDATE format
test           = test_tdate_format(tdate)
IF (test[0] EQ 0) THEN STOP        ;;  Stop before user runs into issues

sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
scpref         = pref[0]
scu            = STRUPCASE(sc[0])
;;  Default to entire day
tr_00          = tdate[0]+'/'+[start_of_day_t[0],end___of_day_t[0]]
;;  Make sure valid time range
trange         = time_double(tr_00)
test           = get_valid_trange(TRANGE=trange,PRECISION=6)
IF (SIZE(test,/TYPE) NE 8) THEN STOP        ;;  Stop before user runs into issues

;;  Define probe tests
testp_a        = (sc[0] EQ 'a')
testp_b        = (sc[0] EQ 'b')
testp_c        = (sc[0] EQ 'c')
testp_d        = (sc[0] EQ 'd')
testp_e        = (sc[0] EQ 'e')
;;----------------------------------------------------------------------------------------
;;  Load ALL relevant data
;;----------------------------------------------------------------------------------------
th_data_dir    = 0
dumb           = TEMPORARY(th_data_dir)
;;  Define location of IDL save files
test           = (N_ELEMENTS(th_data_dir) EQ 0) OR (SIZE(th_data_dir,/TYPE) NE 7)
IF (test) THEN th_data_dir = FILE_DIRNAME('',/MARK_DIRECTORY)
;;  Add trailing '/'
th_data_dir    = add_os_slash(th_data_dir[0])
;;  Define location for TPLOT save file
tpnsave_dir    = th_data_dir[0]+'themis_tplot_save'+slash[0]
;;  Define TPLOT save file name
tpn_fpref_out  = 'TPLOT_save_file_'+prefu[0]
inst_mid_out   = 'FGM-ALL_EESA-IESA-Moments_EFI-Cal-Cor_SCM-Cal-Cor_ESA-SST-Spectra_'
fname          = tpn_fpref_out[0]+inst_mid_out[0]+'eVDF_fit_results_'+tdate[0]+'*.tplot'
;;  Define location of IDL save files containing VDFs
esa_data_dir   = th_data_dir[0]+'IDL_stuff'+slash[0]+'themis_data_dir'+slash[0]+$
                 'themis_esa_save'+slash[0]+tdate[0]
sst_data_dir   = th_data_dir[0]+'themis_sst_save'+slash[0]+tdate[0]+slash[0]
;;  Define VDF IDL save file names
eesa_name      = 'EESA_*_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
iesa_name      = 'IESA_*_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
esst_name      = 'SSTE_*_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
isst_name      = 'SSTI_*_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
;;  Find IDL save files
tpn__file      = FILE_SEARCH(tpnsave_dir[0],fname[0])
test_tpnf      = (tpn__file[0] NE '')
;;  Load new TPLOT data (make sure to append so as to not delete currently loaded data)
IF (test_tpnf[0]) THEN tplot_restore,FILENAME=tpn__file[0],VERBOSE=0,/APPEND,/SORT ELSE STOP
;;  Set defaults
lbw_tplot_set_defaults
;;  Force TPLOT to store things like REFDATE etc.
set_tplot_times
;;  Change colors for vectors
all_vec_coord  = [coord_spg[0],coord_ssl[0],coord_dsl[0],coord_gse[0],coord_gsm[0],coord_fac[0]]
all_vec_tpns   = tnames('*_'+all_vec_coord)
options,all_vec_tpns,'COLORS'
options,all_vec_tpns,'COLORS',vec_col,/DEF
tplot_options,  'XMARGIN',[20,20]
;;  Define spacecraft position as tick marks
pos_gse_tpn    = tnames(scpref[0]+'state_pos_'+coord_gse[0]+'_*')
rad_pos_tpn    = tnames(scpref[0]+'_Rad')
names2         = [REVERSE(pos_gse_tpn),rad_pos_tpn[0]]
tplot_options,VAR_LABEL=names2
;;----------------------------------------------------------------------------------------
;;  Open window and plot
;;----------------------------------------------------------------------------------------
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*7d-1
win_ttl        = 'THEMIS-'+scu[0]+' Plots ['+tdate[0]+']'
win_str        = {RETAIN:2,XSIZE:wsz[0],YSIZE:wsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
WINDOW,0,_EXTRA=win_str

;fgm_tpns       = scpref[0]+modes_fgm[2]+'_'+[coord_mag[0],coord_dsl[0]]
fgm_tpns       = scpref[0]+modes_fgm[1]+'_'+[coord_mag[0],coord_dsl[0]]
efi_tpns       = scpref[0]+modes_efi[1:2]+'_*_rmspikes_'+coord_dsl[0]
scm_tpns       = scpref[0]+modes_scm[1:2]+'_l1_cal_*_'+coord_dsl[0]
nna            = fgm_tpns
;nna            = [fgm_tpns,efi_tpns,scm_tpns]
tplot,nna
;;----------------------------------------------------------------------------------------
;;  Define relevant TPLOT handles
;;----------------------------------------------------------------------------------------
;;  FGM
fgs_tpns       = scpref[0]+'fgs_'+[coord_mag[0],coord_gse[0]]
fgl_tpns       = scpref[0]+'fgl_'+[coord_mag[0],coord_gse[0]]
fgh_tpns       = scpref[0]+'fgh_'+[coord_mag[0],coord_gse[0]]

;;--------------------------------------------
;;  FAC Spectra
;;--------------------------------------------
tpn_prefs      = scpref[0]+'magf_'
;;  EESA
name           = tpn_prefs[0]+'eesa_spec'
eeomni_fac     = tnames(name[0]+'*_omni_flux')
eepad_omni_fac = tnames(name[0]+'*_flux')
eepad_spec_fac = tnames(name[0]+'*_flux-*')
eeanisotro_fac = tnames(name[0]+'*_flux_para_to_*')
;;  IESA [Multiple formats --> same EBIN has different energy --> Fix!]
name           = tpn_prefs[0]+'iesa_spec'
ieomni_fac     = tnames(name[0]+'*_omni_flux')
iepad_omni_fac = tnames(name[0]+'*_flux')
iepad_spec_fac = tnames(name[0]+'*_flux-*')
ieanisotro_fac = tnames(name[0]+'*_flux_para_to_*')
;;  E-SST Burst and Full
name           = tpn_prefs[0]+'pseb_psef_spec'
sebfomnifac    = tnames(name[0]+'*_omni_flux')
sebfpd_omnifac = tnames(name[0]+'*_flux')
sebfpd_specfac = tnames(name[0]+'*_flux-*')
sebfanisotrfac = tnames(name[0]+'*_flux_para_to_*')
;;  I-SST Full
name           = tpn_prefs[0]+'psif_spec'
sifomnifac     = tnames(name[0]+'*_omni_flux')
sifpad_omnifac = tnames(name[0]+'*_flux')
sifpad_specfac = tnames(name[0]+'*_flux-*')
sifanisotrofac = tnames(name[0]+'*_flux_para_to_*')
;;--------------------------------------------
;;  Earth Vector Spectra
;;--------------------------------------------
tpn_prefs      = scpref[0]+'earthvec_'
;;  EESA
name           = tpn_prefs[0]+'eesa_spec'
eeomni_tpn     = tnames(name[0]+'*_omni_flux')
eepad_omni_tpn = tnames(name[0]+'*_flux')
eepad_spec_tpn = tnames(name[0]+'*_flux-*')
eeanisotro_tpn = tnames(name[0]+'*_flux_para_to_*')
;;  IESA [Multiple formats --> same EBIN has different energy --> Fix!]
name           = tpn_prefs[0]+'iesa_spec'
ieomni_tpn     = tnames(name[0]+'*_omni_flux')
iepad_omni_tpn = tnames(name[0]+'*_flux')
iepad_spec_tpn = tnames(name[0]+'*_flux-*')
ieanisotro_tpn = tnames(name[0]+'*_flux_para_to_*')
;;  E-SST Burst and Full
name           = tpn_prefs[0]+'pseb_psef_spec'
sebfomnitpn    = tnames(name[0]+'*_omni_flux')
sebfpd_omnitpn = tnames(name[0]+'*_flux')
sebfpd_spectpn = tnames(name[0]+'*_flux-*')
sebfanisotrtpn = tnames(name[0]+'*_flux_para_to_*')
;;  I-SST Full
name           = tpn_prefs[0]+'psif_spec'
sifomnitpn     = tnames(name[0]+'*_omni_flux')
sifpad_omnitpn = tnames(name[0]+'*_flux')
sifpad_spectpn = tnames(name[0]+'*_flux-*')
sifanisotrotpn = tnames(name[0]+'*_flux_para_to_*')


;;----------------------------------------------------------------------------------------
;;  Load all VDFs if desired
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(no_load_vdfs) THEN STOP
;;  Find files
eesa_file      = FILE_SEARCH(esa_data_dir[0],eesa_name[0])
iesa_file      = FILE_SEARCH(esa_data_dir[0],iesa_name[0])
esst_file      = FILE_SEARCH(sst_data_dir[0],esst_name[0])
isst_file      = FILE_SEARCH(sst_data_dir[0],isst_name[0])
;;  Check that files exist
test_esst      = (esst_file[0] NE '')
test_isst      = (isst_file[0] NE '')
test_eesa      = (eesa_file[0] NE '')
test_iesa      = (iesa_file[0] NE '')
test           = (test_eesa[0] EQ 0) AND (test_iesa[0] EQ 0) AND $
                 (test_esst[0] EQ 0) AND (test_isst[0] EQ 0)
IF (test[0]) THEN STOP      ;;  Nothing was found --> Exit
;;  If they exist --> load them
IF (test_eesa[0]) THEN RESTORE,eesa_file[0]
IF (test_iesa[0]) THEN RESTORE,iesa_file[0]
IF (test_esst[0]) THEN RESTORE,esst_file[0]  ;;  Restore SST Electron structures
IF (test_isst[0]) THEN RESTORE,isst_file[0]  ;;  Restore SST Ion structures
;;----------------------------------------------------------------------------------------
;;  Define ESA VDFs variables
;;----------------------------------------------------------------------------------------
IF (test_iesa[0] AND testp_a[0]) THEN dat_i = peib_df_arr_a
IF (test_iesa[0] AND testp_b[0]) THEN dat_i = peib_df_arr_b
IF (test_iesa[0] AND testp_c[0]) THEN dat_i = peib_df_arr_c
IF (test_iesa[0] AND testp_d[0]) THEN dat_i = peib_df_arr_d
IF (test_iesa[0] AND testp_e[0]) THEN dat_i = peib_df_arr_e

IF (test_eesa[0] AND testp_a[0]) THEN dat_e = peeb_df_arr_a
IF (test_eesa[0] AND testp_b[0]) THEN dat_e = peeb_df_arr_b
IF (test_eesa[0] AND testp_c[0]) THEN dat_e = peeb_df_arr_c
IF (test_eesa[0] AND testp_d[0]) THEN dat_e = peeb_df_arr_d
IF (test_eesa[0] AND testp_e[0]) THEN dat_e = peeb_df_arr_e
;;  Clean up
DELVAR,peib_df_arr_a,peib_df_arr_b,peib_df_arr_c,peib_df_arr_d,peib_df_arr_e
DELVAR,peeb_df_arr_a,peeb_df_arr_b,peeb_df_arr_c,peeb_df_arr_d,peeb_df_arr_e

n_i            = N_ELEMENTS(dat_i)
n_e            = N_ELEMENTS(dat_e)
PRINT,';;  Ni = ', n_i[0]
PRINT,';;  Ne = ', n_e[0]
;;  Modify structures so they work in my plotting routines
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
;;----------------------------------------------------------------------------------------
;;  Define SST VDFs variables
;;----------------------------------------------------------------------------------------
p_test         = WHERE(all_scs EQ sc[0],pt)
p_t_arr        = [(p_test[0] EQ 0),(p_test[0] EQ 1),(p_test[0] EQ 2),(p_test[0] EQ 3),(p_test[0] EQ 4)]
IF (test_isst[0] AND p_t_arr[0]) THEN nsif = N_ELEMENTS(psif_df_arr_a)
IF (test_isst[0] AND p_t_arr[1]) THEN nsif = N_ELEMENTS(psif_df_arr_b)
IF (test_isst[0] AND p_t_arr[2]) THEN nsif = N_ELEMENTS(psif_df_arr_c)
IF (test_isst[0] AND p_t_arr[3]) THEN nsif = N_ELEMENTS(psif_df_arr_d)
IF (test_isst[0] AND p_t_arr[4]) THEN nsif = N_ELEMENTS(psif_df_arr_e)
IF (test_isst[0] AND p_t_arr[0]) THEN nsib = N_ELEMENTS(psib_df_arr_a)
IF (test_isst[0] AND p_t_arr[1]) THEN nsib = N_ELEMENTS(psib_df_arr_b)
IF (test_isst[0] AND p_t_arr[2]) THEN nsib = N_ELEMENTS(psib_df_arr_c)
IF (test_isst[0] AND p_t_arr[3]) THEN nsib = N_ELEMENTS(psib_df_arr_d)
IF (test_isst[0] AND p_t_arr[4]) THEN nsib = N_ELEMENTS(psib_df_arr_e)
IF (test_esst[0] AND p_t_arr[0]) THEN nsef = N_ELEMENTS(psef_df_arr_a)
IF (test_esst[0] AND p_t_arr[1]) THEN nsef = N_ELEMENTS(psef_df_arr_b)
IF (test_esst[0] AND p_t_arr[2]) THEN nsef = N_ELEMENTS(psef_df_arr_c)
IF (test_esst[0] AND p_t_arr[3]) THEN nsef = N_ELEMENTS(psef_df_arr_d)
IF (test_esst[0] AND p_t_arr[4]) THEN nsef = N_ELEMENTS(psef_df_arr_e)
IF (test_esst[0] AND p_t_arr[0]) THEN nseb = N_ELEMENTS(pseb_df_arr_a)
IF (test_esst[0] AND p_t_arr[1]) THEN nseb = N_ELEMENTS(pseb_df_arr_b)
IF (test_esst[0] AND p_t_arr[2]) THEN nseb = N_ELEMENTS(pseb_df_arr_c)
IF (test_esst[0] AND p_t_arr[3]) THEN nseb = N_ELEMENTS(pseb_df_arr_d)
IF (test_esst[0] AND p_t_arr[4]) THEN nseb = N_ELEMENTS(pseb_df_arr_e)

IF (nsib[0] GT 0) THEN IF (p_t_arr[0]) THEN dat_sib = psib_df_arr_a ELSE $
                       IF (p_t_arr[1]) THEN dat_sib = psib_df_arr_b ELSE $
                       IF (p_t_arr[2]) THEN dat_sib = psib_df_arr_c ELSE $
                       IF (p_t_arr[3]) THEN dat_sib = psib_df_arr_d ELSE $
                       IF (p_t_arr[4]) THEN dat_sib = psib_df_arr_e

IF (nsif[0] GT 0) THEN IF (p_t_arr[0]) THEN dat_sif = psif_df_arr_a ELSE $
                       IF (p_t_arr[1]) THEN dat_sif = psif_df_arr_b ELSE $
                       IF (p_t_arr[2]) THEN dat_sif = psif_df_arr_c ELSE $
                       IF (p_t_arr[3]) THEN dat_sif = psif_df_arr_d ELSE $
                       IF (p_t_arr[4]) THEN dat_sif = psif_df_arr_e

IF (nseb[0] GT 0) THEN IF (p_t_arr[0]) THEN dat_seb = pseb_df_arr_a ELSE $
                       IF (p_t_arr[1]) THEN dat_seb = pseb_df_arr_b ELSE $
                       IF (p_t_arr[2]) THEN dat_seb = pseb_df_arr_c ELSE $
                       IF (p_t_arr[3]) THEN dat_seb = pseb_df_arr_d ELSE $
                       IF (p_t_arr[4]) THEN dat_seb = pseb_df_arr_e

IF (nsef[0] GT 0) THEN IF (p_t_arr[0]) THEN dat_sef = psef_df_arr_a ELSE $
                       IF (p_t_arr[1]) THEN dat_sef = psef_df_arr_b ELSE $
                       IF (p_t_arr[2]) THEN dat_sef = psef_df_arr_c ELSE $
                       IF (p_t_arr[3]) THEN dat_sef = psef_df_arr_d ELSE $
                       IF (p_t_arr[4]) THEN dat_sef = psef_df_arr_e

PRINT,';; ',nseb[0],nsef[0],nsib[0],nsif[0],'  For Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0]

;;  Clean up
DELVAR,psib_df_arr_a,psib_df_arr_b,psib_df_arr_c,psib_df_arr_d,psib_df_arr_e
DELVAR,psif_df_arr_a,psif_df_arr_b,psif_df_arr_c,psif_df_arr_d,psif_df_arr_e
DELVAR,pseb_df_arr_a,pseb_df_arr_b,pseb_df_arr_c,pseb_df_arr_d,pseb_df_arr_e
DELVAR,psef_df_arr_a,psef_df_arr_b,psef_df_arr_c,psef_df_arr_d,psef_df_arr_e
;;----------------------------------------------------------------------------------------
;;  Modify SST structures [just in case]
;;----------------------------------------------------------------------------------------
;;  Modify unit conversion procedure
IF (nsef[0] GT 0) THEN dat_sef.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'
IF (nseb[0] GT 0) THEN dat_seb.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'
IF (nsif[0] GT 0) THEN dat_sif.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'
IF (nsib[0] GT 0) THEN dat_sib.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'

;;  Modify particle charge
IF (nsef[0] GT 0) THEN dat_sef.CHARGE = -1e0
IF (nseb[0] GT 0) THEN dat_seb.CHARGE = -1e0
IF (nsif[0] GT 0) THEN dat_sif.CHARGE = 1e0
IF (nsib[0] GT 0) THEN dat_sib.CHARGE = 1e0
;;----------------------------------------------------------------------------------------
;;  Sort structures
;;----------------------------------------------------------------------------------------
IF (nsef[0] GT 0) THEN sp             =      SORT(dat_sef.TIME)
IF (nsef[0] GT 0) THEN dat_sef        = TEMPORARY(dat_sef[sp])
IF (nseb[0] GT 0) THEN sp             =      SORT(dat_seb.TIME)
IF (nseb[0] GT 0) THEN dat_seb        = TEMPORARY(dat_seb[sp])
IF (nsif[0] GT 0) THEN sp             =      SORT(dat_sif.TIME)
IF (nsif[0] GT 0) THEN dat_sif        = TEMPORARY(dat_sif[sp])
IF (nsib[0] GT 0) THEN sp             =      SORT(dat_sib.TIME)
IF (nsib[0] GT 0) THEN dat_sib        = TEMPORARY(dat_sib[sp])
;;----------------------------------------------------------------------------------------
;;  Determine Earth direction at times of each distribution
;;----------------------------------------------------------------------------------------
;;  Define tests for position vectors
thm_gse_pos_tp = scpref[0]+'state_pos_'+coord_gse[0]
thm_dsl_pos_tp = scpref[0]+'state_pos_'+coord_dsl[0]
test_gse_pos   = test_tplot_handle(thm_gse_pos_tp,TPNMS=tpn_gse_pos)
test_dsl_pos   = test_tplot_handle(thm_dsl_pos_tp,TPNMS=tpn_dsl_pos)
IF (test_gse_pos[0]) THEN get_data,tpn_gse_pos[0],DATA=thm_gse_pos,DLIM=dlim_gse_pos,LIM=lim_gse_pos
IF (test_dsl_pos[0]) THEN get_data,tpn_dsl_pos[0],DATA=thm_dsl_pos,DLIM=dlim_dsl_pos,LIM=lim_dsl_pos
test_gse_pos   = tplot_struct_format_test(thm_gse_pos,/YVECT,/NOMSSG)
test_dsl_pos   = tplot_struct_format_test(thm_dsl_pos,/YVECT,/NOMSSG)
test           = (test_gse_pos[0] EQ 0) OR (test_dsl_pos[0] EQ 0)
IF (test[0]) THEN STOP
;;  Define start/end times for each type of particle structure
tr_eesa        = [[dat_egse.TIME],[dat_egse.END_TIME]]
tr_iesa        = [[dat_igse.TIME],[dat_igse.END_TIME]]
tr_isst        = [[dat_sif.TIME],[dat_sif.END_TIME]]
tr_essb        = [[dat_seb.TIME],[dat_seb.END_TIME]]
tr_essf        = [[dat_sef.TIME],[dat_sef.END_TIME]]
tavg_eesa      = (tr_eesa[*,0] + tr_eesa[*,1])/2d0
tavg_iesa      = (tr_iesa[*,0] + tr_iesa[*,1])/2d0
tavg_essb      = (tr_essb[*,0] + tr_essb[*,1])/2d0
tavg_essf      = (tr_essf[*,0] + tr_essf[*,1])/2d0
tavg_isst      = (tr_isst[*,0] + tr_isst[*,1])/2d0
;;  Interpolate SC positions to VDF times
IF (test_gse_pos[0]) THEN avg_eesa_str = t_resample_tplot_struc(thm_gse_pos,tavg_eesa,/ISPLINE,/NO_EXTRAPOLATE)
IF (test_gse_pos[0]) THEN avg_iesa_str = t_resample_tplot_struc(thm_gse_pos,tavg_iesa,/ISPLINE,/NO_EXTRAPOLATE)
IF (test_dsl_pos[0]) THEN avg_essb_str = t_resample_tplot_struc(thm_dsl_pos,tavg_essb,/ISPLINE,/NO_EXTRAPOLATE)
IF (test_dsl_pos[0]) THEN avg_essf_str = t_resample_tplot_struc(thm_dsl_pos,tavg_essf,/ISPLINE,/NO_EXTRAPOLATE)
IF (test_dsl_pos[0]) THEN avg_isst_str = t_resample_tplot_struc(thm_dsl_pos,tavg_isst,/ISPLINE,/NO_EXTRAPOLATE)
;;  Convert to unit vectors
IF (SIZE(avg_eesa_str,/TYPE) EQ 8) THEN avg_eesa_posu  = unit_vec(avg_eesa_str.Y,/NAN)
IF (SIZE(avg_iesa_str,/TYPE) EQ 8) THEN avg_iesa_posu  = unit_vec(avg_iesa_str.Y,/NAN)
IF (SIZE(avg_essb_str,/TYPE) EQ 8) THEN avg_essb_posu  = unit_vec(avg_essb_str.Y,/NAN)
IF (SIZE(avg_essf_str,/TYPE) EQ 8) THEN avg_essf_posu  = unit_vec(avg_essf_str.Y,/NAN)
IF (SIZE(avg_isst_str,/TYPE) EQ 8) THEN avg_isst_posu  = unit_vec(avg_isst_str.Y,/NAN)
IF (SIZE(avg_eesa_str,/TYPE) EQ 8) THEN avg_eesa_earth = -1d0*avg_eesa_posu
IF (SIZE(avg_iesa_str,/TYPE) EQ 8) THEN avg_iesa_earth = -1d0*avg_iesa_posu
IF (SIZE(avg_essb_str,/TYPE) EQ 8) THEN avg_essb_earth = -1d0*avg_essb_posu
IF (SIZE(avg_essf_str,/TYPE) EQ 8) THEN avg_essf_earth = -1d0*avg_essf_posu
IF (SIZE(avg_isst_str,/TYPE) EQ 8) THEN avg_isst_earth = -1d0*avg_isst_posu




