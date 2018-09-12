;+
;*****************************************************************************************
;
;  BATCH    :   load_themis_foreshock_eVDFs_everything_and_save_batch.pro
;  PURPOSE  :   This is a batch file that is meant to conglomerate all available
;                 TPLOT data into one TPLOT save file to for later use.
;
;  CALLED BY:   
;               thm_VDF_foreshock_eVDFs_everything_and_save_crib.pro
;
;  INCLUDES:
;               load_thm_FS_eVDFs_calc_sh_parms_batch.pro
;
;  CALLS:
;               get_os_slash.pro
;               test_tdate_format.pro
;               load_thm_FS_eVDFs_calc_sh_parms_batch.pro
;               add_os_slash.pro
;               tplot_restore.pro
;               lbw_tplot_set_defaults.pro
;               set_tplot_times.pro
;               tnames.pro
;               options.pro
;               tplot_options.pro
;               find_strahl_direction.pro
;               my_crossp_2.pro
;               store_data.pro
;               get_data.pro
;               get_power_of_ten_ticks.pro
;               file_name_times.pro
;               tplot_save.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS 8.0 or SPEDAS 1.0 (or greater) IDL libraries
;               2)  UMN Modified Wind/3DP IDL Libraries
;               3)  TPLOT save files created by load_thm_fields_save_tplot_batch.pro
;               4)  TPLOT save files created by load_thm_fgm_efi_scm_2_tplot_batch.pro
;               5)  IDL save files containing VDFs for both THEMIS ESAs and SSTs
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
;               @load_themis_foreshock_eVDFs_everything_and_save_batch.pro
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This batch routine expects a date and a probe input on the command
;                     line prior to calling (see EXAMPLES)
;               2)  If your paths are not set correctly, you may need to provide a full
;                     path to this routine, e.g., the following is figurative and should
;                     be replaced with the full file path to this batch file:
;                     @/full/file/path/to/load_themis_foreshock_eVDFs_everything_and_save_batch.pro
;               3)  This batch routine loads FGM, ESA moments, EFI, and SCM data from a
;                     TPLOT save file and adds particle spectra from both ESAs and SSTs
;                     to TPLOT before creating a new TPLOT save file upon completion
;               4)  See also:
;                              load_thm_fields_save_tplot_batch.pro
;                              load_thm_fgm_efi_scm_2_tplot_batch.pro
;                              load_thm_fgm_efi_scm_save_tplot_batch.pro
;                              load_thm_FS_eVDFs_calc_sh_parms_batch.pro
;                              load_themis_foreshock_eVDFs_batch.pro
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
;    LAST MODIFIED:  02/03/2016   v1.0.0
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
;;----------------------------------------------------------------------------------------
;;  Load 1st set of relevant data
;;----------------------------------------------------------------------------------------
no_load_spec   = 0b                    ;;  --> do load particle spectra

ex_start       = SYSTIME(1)            ;;  Time the execution of all events within
@$HOME/Desktop/swidl-0.1/IDL_Stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_thm_FS_eVDFs_calc_sh_parms_batch.pro
MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;;  Clean up
DELVAR,psif_df_arr_a,psif_df_arr_b,psif_df_arr_c,psif_df_arr_d,psif_df_arr_e
DELVAR,psef_df_arr_a,psef_df_arr_b,psef_df_arr_c,psef_df_arr_d,psef_df_arr_e
DELVAR,pseb_df_arr_a,pseb_df_arr_b,pseb_df_arr_c,pseb_df_arr_d,pseb_df_arr_e
DELVAR,dat_sib,dat_sif,dat_seb,dat_sef
DELVAR,tr_eesa,tr_iesa,tr_isst,tr_essb,tr_essf
DELVAR,se_eesa_posi,se_iesa_posi,se_essb_posi,se_essf_posi,se_isst_posi
DELVAR,avg_posx,avg_posy,avg_posz,avg_eesa_pos,avg_iesa_pos,avg_essb_pos,avg_essf_pos,avg_isst_pos
DELVAR,avg_eesa_posu,avg_iesa_posu,avg_essb_posu,avg_essf_posu,avg_isst_posu
DELVAR,avg_eesa_earth,avg_iesa_earth,avg_essb_earth,avg_essf_earth,avg_isst_earth
DELVAR,dat,dat_e,dat_i,dat_egse,dat_igse,temp,lim,dlim
PRINT,''
PRINT,''
PRINT,'  -->  Memory is freed up...'
PRINT,''
PRINT,''
;;----------------------------------------------------------------------------------------
;;  Load 2nd set of relevant data
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
;;  Define file names for the IDL save files
tpn_fpref      = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_EFI*SCM*'
;;  Define file name
fname          = tpn_fpref[0]+tdate[0]+'*.tplot'
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
;;  Create GSE equivalents for EFI and SCM TPLOT handles
;;----------------------------------------------------------------------------------------
;;  FGM TPLOT handles
magf__tpn      = scpref[0]+['fgh_'+[coord_mag[0],coord_dsl[0]],'fgl_'+coord_mag[0]]
;;  EFI TPLOT handles
all_efp_dsl    = tnames(scpref[0]+'efp_*_'+coord_dsl[0])
all_efw_dsl    = tnames(scpref[0]+'efw_*_'+coord_dsl[0])
;;  SCM TPLOT handles
all_scp_dsl    = tnames(scpref[0]+'scp_*_'+coord_dsl[0])
all_scw_dsl    = tnames(scpref[0]+'scw_*_'+coord_dsl[0])
;;  1st calculate FAC for SCP
.compile matrix_array_lib.pro   ;;  necessary to prevent tvector_rotate.pro from crashing
.compile tvector_rotate.pro
.compile $HOME/Desktop/temp_idl/temp_t_vec_2_fac.pro
;;  scp
in__name       = all_scp_dsl[0]
out_name       = STRMID(in__name[0],0L,STRLEN(in__name[0])-4L)
temp_t_vec_2_fac,in__name[0],magf__tpn[1],OUT_TPN=out_name[0],SM_WIDTH=11L,TPNS_OUT=tpns_out
scp_fac_tpns   = tpns_out
;;  2nd rotate EFI data to GSE
FOR j=0L, N_ELEMENTS(all_efp_dsl) - 1L DO BEGIN                                       $
  in__name = all_efp_dsl[j]                                                         & $
  out_name = STRMID(in__name[0],0L,STRLEN(in__name[0])-3L)+coord_gse[0]             & $
  thm_cotrans,in__name[0],out_name[0],IN_COORD=coord_dsl[0],OUT_COORD=coord_gse[0],VERBOSE=0

FOR j=0L, N_ELEMENTS(all_efw_dsl) - 1L DO BEGIN                                       $
  in__name = all_efw_dsl[j]                                                         & $
  out_name = STRMID(in__name[0],0L,STRLEN(in__name[0])-3L)+coord_gse[0]             & $
  thm_cotrans,in__name[0],out_name[0],IN_COORD=coord_dsl[0],OUT_COORD=coord_gse[0],VERBOSE=0

;;  3rd rotate SCM data to GSE
FOR j=0L, N_ELEMENTS(all_scp_dsl) - 1L DO BEGIN                                       $
  in__name = all_scp_dsl[j]                                                         & $
  out_name = STRMID(in__name[0],0L,STRLEN(in__name[0])-3L)+coord_gse[0]             & $
  thm_cotrans,in__name[0],out_name[0],IN_COORD=coord_dsl[0],OUT_COORD=coord_gse[0],VERBOSE=0

FOR j=0L, N_ELEMENTS(all_scw_dsl) - 1L DO BEGIN                                       $
  in__name = all_scw_dsl[j]                                                         & $
  out_name = STRMID(in__name[0],0L,STRLEN(in__name[0])-3L)+coord_gse[0]             & $
  thm_cotrans,in__name[0],out_name[0],IN_COORD=coord_dsl[0],OUT_COORD=coord_gse[0],VERBOSE=0


;;----------------------------------------------------------------------------------------
;;  Calculate the ∂B and ∂B/Bo [from fgh]
;;----------------------------------------------------------------------------------------
get_data,magf__tpn[0],DATA=temp_bmag,DLIM=dlim_bmag,LIM=lim_bmag
get_data,magf__tpn[1],DATA=temp_bdsl,DLIM=dlim_bdsl,LIM=lim_bdsl
;;  Define parameters
bmag__t        = temp_bmag.X
bmag__v        = temp_bmag.Y
bdsl__t        = temp_bdsl.X
bdsl__v        = temp_bdsl.Y
;;  Define "smoothed" Bo
new_sr         = 1d0
srate          = sample_rate(bmag__t,/AVE)
speri          = 1d0/srate[0]               ;;  sampling period [s]
wd             = LONG(1d0/(new_sr[0]/srate[0]))
bmag_sm        = MEDIAN(bmag__v,wd[0])
tempx          = MEDIAN(bdsl__v[*,0],wd[0])
tempy          = MEDIAN(bdsl__v[*,1],wd[0])
tempz          = MEDIAN(bdsl__v[*,2],wd[0])
bdsl_sm        = [[tempx],[tempy],[tempz]]
;;  Detrend Bo
bmag_dt        = ABS(bmag__v - bmag_sm)
bdsl_dt        = bdsl__v - bdsl_sm
;;  Define ∂B/Bo
bdsl_sm_mag    = mag__vec(bdsl_sm,/NAN,/TWO)
db_bov_dsl     = bdsl_dt/bdsl__v
db_bom_dsl     = bdsl_dt/bdsl_sm_mag
db_bom_mag     = bmag_dt/bmag__v
db_bom_mag_sm  = MEDIAN(db_bom_mag,wd[0]/4L)
db_bov_max     = 5d1
test           = (ABS(db_bov_dsl[*,0]) GE db_bov_max[0]) OR (ABS(db_bov_dsl[*,1]) GE db_bov_max[0]) OR $
                 (ABS(db_bov_dsl[*,2]) GE db_bov_max[0])
bad            = WHERE(test,bd)
IF (bd GT 0) THEN db_bov_dsl[bad,*] = d
;;  Send to TPLOT
db_bov_dsl_tpn = 'dB_Bovec_'+modes_fgm[2]+'_'+coord_dsl[0]
db_bom_dsl_tpn = 'dB_Bomag_'+modes_fgm[2]+'_'+coord_dsl[0]
db_bom_mag_tpn = 'dB_Bomag_'+modes_fgm[2]+'_'+coord_mag[0]
db_bov_dsl_str = {X:bdsl__t,Y:db_bov_dsl}
db_bom_dsl_str = {X:bdsl__t,Y:db_bom_dsl}
db_bom_mag_str = {X:bmag__t,Y:[[db_bom_mag],[db_bom_mag_sm]]}
wd_str         = STRTRIM(STRING(wd[0],FORMAT='(I3.3)'),2L)
ysubt          = '[DT:  '+wd_str[0]+' pts]'          ;;  DT = Detrended
db_bov_dsl_ytt = 'dB_j/Bo_j'
db_bom_dsl_ytt = 'dB_j/|Bo_j|'
db_bom_mag_ytt = '|dB|/|Bo|'

store_data,db_bov_dsl_tpn[0],DATA=db_bov_dsl_str,DLIM=def_dlim,LIM=def__lim
store_data,db_bom_dsl_tpn[0],DATA=db_bom_dsl_str,DLIM=def_dlim,LIM=def__lim
store_data,db_bom_mag_tpn[0],DATA=db_bom_mag_str,DLIM=def_dlim,LIM=def__lim
;;  Alter options
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN yran_db_bom_mag = [1e-4,2e1]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN yran_db_bom_mag = [1e-4,1e1]
all_dB_Bo_tpns = [db_bov_dsl_tpn[0],db_bom_dsl_tpn[0],db_bom_mag_tpn[0]]
options,all_dB_Bo_tpns,'LABELS'
options,all_dB_Bo_tpns,'COLORS'
options,all_dB_Bo_tpns,'YSUBTITLE'
options,all_dB_Bo_tpns,'LABELS',/DEF
options,all_dB_Bo_tpns,'YSUBTITLE',ysubt,/DEF
options,db_bom_mag_tpn[0],COLORS=vec_col[[2,1]],YTITLE=db_bom_mag_ytt[0],YLOG=1,YMINOR=9,/DEF
options,db_bov_dsl_tpn[0],COLORS=vec_col,   YTITLE=db_bov_dsl_ytt[0],LABELS=vec_str,YMINOR=4,/DEF
options,db_bom_dsl_tpn[0],COLORS=vec_col,   YTITLE=db_bom_dsl_ytt[0],LABELS=vec_str,YMINOR=4,/DEF
IF (N_ELEMENTS(yran_db_bom_mag) EQ 2) THEN options,db_bom_mag_tpn[0],YRANGE=yran_db_bom_mag,/DEF
;;----------------------------------------------------------------------------------------
;;  Calculate the ∂B and ∂B/Bo [from scp and scw]
;;----------------------------------------------------------------------------------------
scm_tpns       = scpref[0]+modes_scm[1:2]+'_l1_cal_*_'+coord_dsl[0]
get_data,tnames(scm_tpns[0]),DATA=temp_scp,DLIM=dlim_scp,LIM=lim_scp
get_data,tnames(scm_tpns[1]),DATA=temp_scw,DLIM=dlim_scw,LIM=lim_scw
;;  Define parameters
scp_dsl_t      = temp_scp.X
scp_dsl_v      = temp_scp.Y
scw_dsl_t      = temp_scw.X
scw_dsl_v      = temp_scw.Y
;;  Upsample |Bo| smoothed values to scp and scw time stamps
bmag_sm_scp_t  = interp(bmag_sm,bmag__t,scp_dsl_t,/NO_EXTRAP)
bmag_sm_scw_t  = interp(bmag_sm,bmag__t,scw_dsl_t,/NO_EXTRAP)
;;  Calculate ∂B_j/|Bo|
db_bo_scp_dsl  = scp_dsl_v/(bmag_sm_scp_t # REPLICATE(1d0,3L))
db_bo_scw_dsl  = scw_dsl_v/(bmag_sm_scw_t # REPLICATE(1d0,3L))
;;  Calculate ∂B/|Bo|
scp_mag_v      = mag__vec(scp_dsl_v,/NAN)
scw_mag_v      = mag__vec(scw_dsl_v,/NAN)
db_bo_scp_mag  = scp_mag_v/bmag_sm_scp_t
db_bo_scw_mag  = scw_mag_v/bmag_sm_scw_t
;;  Define "smoothed" ∂B/|Bo|
new_sr         = 1d0
srate_scp      = sample_rate(scp_dsl_t,/AVE)
srate_scw      = sample_rate(scw_dsl_t,/AVE)
new_sr_scp     = 1d0
new_sr_scw     = srate_scw[0]/srate_scp[0]
wd_scp         = LONG(1d0/(new_sr_scp[0]/srate_scp[0]))
wd_scw         = LONG(1d0/(new_sr_scw[0]/srate_scw[0]))
wd_scp_str     = STRTRIM(STRING(wd_scp[0],FORMAT='(I3.3)'),2L)
wd_scw_str     = STRTRIM(STRING(wd_scw[0],FORMAT='(I3.3)'),2L)
ysubt_sub      = '!C'+'[Sm: '+[wd_scp_str[0],wd_scw_str[0]]+' pts]'
db_bo_scp_smm  = MEDIAN(db_bo_scp_mag,wd_scp[0]/4L)
db_bo_scw_smm  = MEDIAN(db_bo_scw_mag,wd_scw[0]/4L)
;;  Define TPLOT handles and structures
scp_bo_dsl_tpn = 'dB_Bomag_'+modes_scm[1]+'_'+coord_dsl[0]
scw_bo_dsl_tpn = 'dB_Bomag_'+modes_scm[2]+'_'+coord_dsl[0]
scp_bo_mag_tpn = 'dB_Bomag_'+modes_scm[1]+'_'+coord_mag[0]
scw_bo_mag_tpn = 'dB_Bomag_'+modes_scm[2]+'_'+coord_mag[0]
scp_bo_dsl_str = {X:scp_dsl_t,Y:db_bo_scp_dsl}
scw_bo_dsl_str = {X:scw_dsl_t,Y:db_bo_scw_dsl}
scp_bo_mag_str = {X:scp_dsl_t,Y:[[db_bo_scp_mag],[db_bo_scp_smm]]}
scw_bo_mag_str = {X:scw_dsl_t,Y:[[db_bo_scw_mag],[db_bo_scw_smm]]}
;;  Define YTITLE and subtitles
ysubt_scp_scw  = '[dB: '+modes_scm[1:2]+', Bo: '+modes_fgm[2]+']'+ysubt_sub
scp_bo_dsl_ytt = 'dB_j/|Bo| ['+modes_scm[1]+', '+coord_dsl[0]+']'
scw_bo_dsl_ytt = 'dB_j/|Bo| ['+modes_scm[2]+', '+coord_dsl[0]+']'
scp_bo_mag_ytt = '|dB|/|Bo| ['+modes_scm[1]+']'
scw_bo_mag_ytt = '|dB|/|Bo| ['+modes_scm[2]+']'
;;  Send to TPLOT
store_data,scp_bo_dsl_tpn[0],DATA=scp_bo_dsl_str,DLIM=def_dlim,LIM=def__lim
store_data,scw_bo_dsl_tpn[0],DATA=scw_bo_dsl_str,DLIM=def_dlim,LIM=def__lim
store_data,scp_bo_mag_tpn[0],DATA=scp_bo_mag_str,DLIM=def_dlim,LIM=def__lim
store_data,scw_bo_mag_tpn[0],DATA=scw_bo_mag_str,DLIM=def_dlim,LIM=def__lim
;;  Alter options
scm_dB_Bo_tpns = [scp_bo_dsl_tpn[0],scw_bo_dsl_tpn[0],scp_bo_mag_tpn[0],scw_bo_mag_tpn[0]]
options,scm_dB_Bo_tpns,'LABELS'
options,scm_dB_Bo_tpns,'COLORS'
options,scm_dB_Bo_tpns,'YTITLE'
options,scm_dB_Bo_tpns,'YSUBTITLE'
options,scm_dB_Bo_tpns,'LABELS',/DEF
options,scm_dB_Bo_tpns[[0,2]],YSUBTITLE=ysubt_scp_scw[0],/DEF
options,scm_dB_Bo_tpns[[1,3]],YSUBTITLE=ysubt_scp_scw[1],/DEF
options,scm_dB_Bo_tpns[[0,1]],COLORS=vec_col,LABELS=vec_str,YMINOR=4,/DEF
options,scm_dB_Bo_tpns[[2,3]],COLORS=vec_col[[2,1]],YMINOR=9,YLOG=1,/DEF
options,scm_dB_Bo_tpns[0],YTITLE=scp_bo_dsl_ytt[0],/DEF
options,scm_dB_Bo_tpns[1],YTITLE=scw_bo_dsl_ytt[0],/DEF
options,scm_dB_Bo_tpns[2],YTITLE=scp_bo_mag_ytt[0],/DEF
options,scm_dB_Bo_tpns[3],YTITLE=scw_bo_mag_ytt[0],/DEF
;;----------------------------------------------------------------------------------------
;;  Define relevant TPLOT handles
;;----------------------------------------------------------------------------------------
tpn_midfn      = 'fgs_peir_'
mach_tpn       = scpref[0]+tpn_midfn[0]+'BS_Ma_Ms_Mf'         ;;  Mach numbers TPLOT handle
;mach_tpn       = scpref[0]+'MA_MCs_Mms'         ;;  Mach numbers TPLOT handle
;;  ∂B/Bo [fgh] TPLOT handles
db_bov_dsl_tpn = 'dB_Bovec_'+modes_fgm[2]+'_'+coord_dsl[0]
db_bom_dsl_tpn = 'dB_Bomag_'+modes_fgm[2]+'_'+coord_dsl[0]
db_bom_mag_tpn = 'dB_Bomag_'+modes_fgm[2]+'_'+coord_mag[0]
;;  ∂B/Bo [scp and scw] TPLOT handles
scp_bo_dsl_tpn = 'dB_Bomag_'+modes_scm[1]+'_'+coord_dsl[0]
scw_bo_dsl_tpn = 'dB_Bomag_'+modes_scm[2]+'_'+coord_dsl[0]
scp_bo_mag_tpn = 'dB_Bomag_'+modes_scm[1]+'_'+coord_mag[0]
scw_bo_mag_tpn = 'dB_Bomag_'+modes_scm[2]+'_'+coord_mag[0]

fgh_dB_Bo_tpns = [db_bov_dsl_tpn[0],db_bom_dsl_tpn[0],db_bom_mag_tpn[0]]
scm_dB_Bo_tpns = [scp_bo_dsl_tpn[0],scw_bo_dsl_tpn[0],scp_bo_mag_tpn[0],scw_bo_mag_tpn[0]]

all_efp_tpns   = tnames(scpref[0]+'efp_l1_cal_*_corrected_rmspikes*_'+[coord_dsl[0],coord_gse[0]])
all_scp_tpns   = tnames(scpref[0]+'scp_l1_cal_*_'+[coord_dsl[0],coord_gse[0]])
all_efw_tpns   = tnames(scpref[0]+'efw_l1_cal_*_corrected_rmspikes*_'+[coord_dsl[0],coord_gse[0]])
all_scw_tpns   = tnames(scpref[0]+'scw_l1_cal_*_'+[coord_dsl[0],coord_gse[0]])

efp_fac_tpns   = tnames(scpref[0]+'efp_l1_cal_*_corrected_rmspikes*_'+coord_fac[0])
scp_fac_tpns   = tnames(scpref[0]+'scp_l1_cal_*_zdsl_'+coord_fac[0])
efw_fac_tpns   = tnames(scpref[0]+'efw_l1_cal_*_corrected_rmspikes*_'+coord_fac[0])
scw_fac_tpns   = tnames(scpref[0]+'scw_l1_cal_*_zdsl_'+coord_fac[0])
;;----------------------------------------------------------------------------------------
;;  Define file paths and names to fit results
;;----------------------------------------------------------------------------------------
eVDF_dir       = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'TPLOT_THEMIS_PLOTS'+slash[0]+'eVDF_Fits'+slash[0]
fpref_dir      = 'eVDF_'+scpref[0]+'Fits_'+tdate[0]
fpref          = 'THEMIS_EESA_*_'+sc[0]+'_SWF_SCF_Power_Law_Exponential_Fit-Results_'
fname          = fpref[0]+tdate[0]+'*.sav'
dir            = eVDF_dir[0]+fpref_dir[0]+slash[0]
file           = FILE_SEARCH(dir[0],fname[0])
;;  If on laptop, then only need to look in Dropbox folder
IF (file[0] EQ '') THEN eVDF_dir = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Dropbox'+slash[0]
IF (file[0] EQ '') THEN eVDF_dir = eVDF_dir[0]+'eVDF_Fits'+slash[0]
IF (file[0] EQ '') THEN dir      = eVDF_dir[0]+fpref_dir[0]+slash[0]
IF (file[0] EQ '') THEN file     = FILE_SEARCH(dir[0],fname[0])
IF (file[0] NE '') THEN RESTORE,file[0] ELSE STOP

HELP, plexp_fit_pnt
gnne           = N_ELEMENTS(plexp_fit_pnt[*,1])
plexp_scf_ptr  = PTRARR(gnne[0],/ALLOCATE_HEAP)
plexp_swf_ptr  = PTRARR(gnne[0],/ALLOCATE_HEAP)
FOR j=0L, gnne[0] - 1L DO BEGIN                       $
  *plexp_scf_ptr[j] = *plexp_fit_pnt[j,1]           & $
  *plexp_swf_ptr[j] = *plexp_fit_pnt[j,0]

;;  Clean up
FOR frame=0L, 1L DO BEGIN                                            $
  FOR j=0L, gnne[0] - 1L DO BEGIN                                    $
    PTR_FREE,plexp_fit_pnt[j,frame]                                & $
    HEAP_FREE,plexp_fit_pnt[j,frame],/PTR
DELVAR,plexp_fit_pnt
;;----------------------------------------------------------------------------------------
;;  Define fit parameter results
;;----------------------------------------------------------------------------------------
;;------------------------------------------------
;;  (Power-Law + Exponential) Fits
;;    Y = A X^(B) e^(C X) + D
;;------------------------------------------------
n_fits         = N_ELEMENTS(plexp_swf_ptr)
unix_sten      = REPLICATE(d,n_fits[0],2L)
magf_vals      = REPLICATE(d,n_fits[0],3L)       ;;  GSE B-field vectors for each event [nT]
vsw__vals      = REPLICATE(d,n_fits[0],3L)       ;;  GSE bulk flow velocity vectors for each event [km/s]
fit_params     = REPLICATE(d,n_fits[0],4L,3L)    ;;  [N,4,3] --> 3 = Para, Perp, Anti
sig_params     = REPLICATE(d,n_fits[0],4L,3L)
fit_status     = REPLICATE(d,n_fits[0],3L)
dof__chisq     = REPLICATE(d,n_fits[0],2L,3L)

FOR j=0L, n_fits[0] - 1L DO BEGIN                                                        $
  st_unix   = (*plexp_swf_ptr[j]).INIT_STRUC.DATA.TIME[0]                              & $
  en_unix   = (*plexp_swf_ptr[j]).INIT_STRUC.DATA.END_TIME[0]                          & $
  temp_bgse = (*plexp_swf_ptr[j]).INIT_STRUC.DATA.MAGF                                 & $
  temp_vgse = (*plexp_swf_ptr[j]).INIT_STRUC.DATA.VSW                                  & $
  temp_par  = (*plexp_swf_ptr[j]).FIT_PARA_STRUC.FIT                                   & $
  temp_per  = (*plexp_swf_ptr[j]).FIT_PERP_STRUC.FIT                                   & $
  temp_ant  = (*plexp_swf_ptr[j]).FIT_ANTI_STRUC.FIT                                   & $
  temp_parm = [[temp_par.FIT_PARAMS],[temp_per.FIT_PARAMS],[temp_ant.FIT_PARAMS]]      & $
  temp_sigp = [[temp_par.SIG_PARAM],[temp_per.SIG_PARAM],[temp_ant.SIG_PARAM]]         & $
  temp_chi2 = [temp_par.CHISQ[0],temp_per.CHISQ[0],temp_ant.CHISQ[0]]                  & $
  temp_dof  = [temp_par.DOF[0],temp_per.DOF[0],temp_ant.DOF[0]]                        & $
  temp_stat = [temp_par.STATUS[0],temp_per.STATUS[0],temp_ant.STATUS[0]]               & $
  unix_sten[j,*] = [st_unix[0],en_unix[0]]                                             & $
  magf_vals[j,*] = temp_bgse                                                           & $
  vsw__vals[j,*] = temp_vgse                                                           & $
  fit_params[j,*,*] = temp_parm                                                        & $
  sig_params[j,*,*] = temp_sigp                                                        & $
  fit_status[j,*]   = temp_stat                                                        & $
  dof__chisq[j,0,*] = temp_dof                                                         & $
  dof__chisq[j,1,*] = temp_chi2

avg_unix       = (unix_sten[*,0] + unix_sten[*,1])/2d0
;;  Calculate the reduced chi-squared value
red_chisq      = REFORM(dof__chisq[*,1,*])/REFORM(dof__chisq[*,0,*])
;;  Find strahl direction [+1 = // to Bo, -1 = anti-// to Bo]
strahl_dir     = find_strahl_direction(magf_vals)
good_strahl    = WHERE(strahl_dir GT 0,gd_strahl,COMPLEMENT=bad_strahl,NCOMPLEMENT=bd_strahl)
strahl_vals    = REPLICATE(d,n_fits[0],2L)
IF (gd_strahl GT 0) THEN strahl_vals[good_strahl,0] = strahl_dir[good_strahl]
IF (bd_strahl GT 0) THEN strahl_vals[bad_strahl,1]  = strahl_dir[bad_strahl]
;;  Calculate Eo = - (V x B)
efac           = -1d0*1d3*1d-9*1d3     ;;  km --> m, nT --> T, V --> mV
econv          = efac[0]*my_crossp_2(vsw__vals,magf_vals,/NOM)
;;  Define fit function used
fit_func_ysub  = (*plexp_swf_ptr[0]).INIT_STRUC.LIMITS.YSUBTITLE[0]  ;;  e.g., 'Fit Function: Y = A X!UB!N e!UC X!N + D'
;;----------------------------------------------------------------------------------------
;;  Send results to TPLOT
;;----------------------------------------------------------------------------------------
all_fit_labs   = ['para','perp','anti']
strahl_labs    = all_fit_labs[[0,2]]
strahl_cols    = vec_col[[0,2]]
all_fit_midf   = 'peeb_eVDF_fits_'
all_fit_pref   = scpref[0]+all_fit_midf[0]
tpn_suffx_parm = 'parm_'+['A','B','C','D']
tpn_midf__parm = ['val','sig']+'_'
tpn_suffx_sdcr = ['fit_status','dof','chisq','red_chisq']
tpn_suffx_else = ['strahl_dir','vbulk','Bo','Econv']
;;  Define TPLOT handles
fit_parm_tpns  = all_fit_pref[0]+tpn_midf__parm[0]+tpn_suffx_parm
fit_sigm_tpns  = all_fit_pref[0]+tpn_midf__parm[1]+tpn_suffx_parm
fit_stat_tpn   = all_fit_pref[0]+tpn_suffx_sdcr[0]
fit_dof__tpn   = all_fit_pref[0]+tpn_suffx_sdcr[1]
fit_chrch_tpn  = all_fit_pref[0]+tpn_suffx_sdcr[2:3]
fit_strahl_tpn = all_fit_pref[0]+tpn_suffx_else[0]
fit_vbulk__tpn = all_fit_pref[0]+tpn_suffx_else[1]
fit_magf___tpn = all_fit_pref[0]+tpn_suffx_else[2]
fit_econv__tpn = all_fit_pref[0]+tpn_suffx_else[3]
;;  Define TPLOT structures
fit_aparm_str  = {X:avg_unix,Y:REFORM(fit_params[*,0,*])}
fit_bparm_str  = {X:avg_unix,Y:REFORM(fit_params[*,1,*])}
fit_cparm_str  = {X:avg_unix,Y:REFORM(fit_params[*,2,*])}
fit_dparm_str  = {X:avg_unix,Y:REFORM(fit_params[*,3,*])}
fit_asigm_str  = {X:avg_unix,Y:REFORM(sig_params[*,0,*])}
fit_bsigm_str  = {X:avg_unix,Y:REFORM(sig_params[*,1,*])}
fit_csigm_str  = {X:avg_unix,Y:REFORM(sig_params[*,2,*])}
fit_dsigm_str  = {X:avg_unix,Y:REFORM(sig_params[*,3,*])}
fit_stats_str  = {X:avg_unix,Y:fit_status}
fit_dof___str  = {X:avg_unix,Y:REFORM(dof__chisq[*,0,*])}
fit_chisq_str  = {X:avg_unix,Y:REFORM(dof__chisq[*,1,*])}
fit_redch_str  = {X:avg_unix,Y:red_chisq}
fit_strahl_str = {X:avg_unix,Y:strahl_vals}
fit_vbulk__str = {X:avg_unix,Y:vsw__vals}
fit_magf___str = {X:avg_unix,Y:magf_vals}
fit_econv__str = {X:avg_unix,Y:econv}
;;  Define YTITLEs for TPLOT variables
fit_parm_yttls = 'Fit Parm. '+['A','B','C','D']
fit_sigm_yttls = 'Fit Sigm. '+['A','B','C','D']
fit_sdcr_yttls = 'Fit '+['Status','DOF','Chi-Squared','Red. Chi-Squared']
fit_strhl_yttl = 'Strahl Dir.'
fit_strhl_ysub = '[(-)+1 = (anti-)// to Bo]'
fit_vbulk_yttl = 'Vbulk [km/s, '+coord_gse[0]+']'
fit_magf__yttl = 'Bo [nT, '+coord_gse[0]+']'
fit_econv_yttl = 'Econv [mV/m, '+coord_gse[0]+']'
fit_v_b_e_ysub = '[at time of fits]'
;;  Define YRANGE's
fit_stat_yran  = [-19e0,1e1]
fit_strhl_yran = [-1,1]*1.2
;;  Send to TPLOT
store_data, fit_parm_tpns[0],DATA=fit_aparm_str,DLIM=def_dlim,LIM=def__lim
store_data, fit_parm_tpns[1],DATA=fit_bparm_str,DLIM=def_dlim,LIM=def__lim
store_data, fit_parm_tpns[2],DATA=fit_cparm_str,DLIM=def_dlim,LIM=def__lim
store_data, fit_parm_tpns[3],DATA=fit_dparm_str,DLIM=def_dlim,LIM=def__lim
store_data, fit_sigm_tpns[0],DATA=fit_asigm_str,DLIM=def_dlim,LIM=def__lim
store_data, fit_sigm_tpns[1],DATA=fit_bsigm_str,DLIM=def_dlim,LIM=def__lim
store_data, fit_sigm_tpns[2],DATA=fit_csigm_str,DLIM=def_dlim,LIM=def__lim
store_data, fit_sigm_tpns[3],DATA=fit_dsigm_str,DLIM=def_dlim,LIM=def__lim
store_data,  fit_stat_tpn[0],DATA=fit_stats_str,DLIM=def_dlim,LIM=def__lim
store_data,  fit_dof__tpn[0],DATA=fit_dof___str,DLIM=def_dlim,LIM=def__lim
store_data, fit_chrch_tpn[0],DATA=fit_chisq_str,DLIM=def_dlim,LIM=def__lim
store_data, fit_chrch_tpn[1],DATA=fit_redch_str,DLIM=def_dlim,LIM=def__lim
store_data,fit_strahl_tpn[0],DATA=fit_strahl_str,DLIM=def_dlim,LIM=def__lim
store_data,fit_vbulk__tpn[0],DATA=fit_vbulk__str,DLIM=def_dlim,LIM=def__lim
store_data,fit_magf___tpn[0],DATA=fit_magf___str,DLIM=def_dlim,LIM=def__lim
store_data,fit_econv__tpn[0],DATA=fit_econv__str,DLIM=def_dlim,LIM=def__lim

;;  Add model function definition to outputs default limits structure
all_fit_tpns   = [fit_parm_tpns,fit_sigm_tpns,fit_stat_tpn[0],fit_dof__tpn[0],$
                  fit_chrch_tpn,fit_strahl_tpn[0],fit_vbulk__tpn[0],          $
                  fit_magf___tpn[0],fit_econv__tpn[0]]
options,all_fit_tpns,'DATA_ATT.FIT_FUNC',fit_func_ysub[0],/DEF
;;  Alter options
;;  Defined user symbol for outputing all data points
nxxo           = 25
xxro           = 0.55
xxo            = FINDGEN(nxxo[0])*(!PI*2.)/(nxxo[0] - 1L)
USERSYM,xxro[0]*COS(xxo),xxro[0]*SIN(xxo),/FILL
symb          = 8
;;  Set universal default options
options,all_fit_tpns,YLOG=0,YMINOR=4,PSYM=symb[0],COLORS=vec_col,LABELS=all_fit_labs,/DEF
;;  Exceptions
options,[fit_parm_tpns[0],fit_sigm_tpns[0],fit_chrch_tpn[1]],YLOG=1,YMINOR=9,/DEF
options,fit_strahl_tpn[0],LABELS=strahl_labs,COLORS=strahl_cols,/DEF
options,[fit_vbulk__tpn[0],fit_magf___tpn[0],fit_econv__tpn[0]],LABELS=vec_str,/DEF
options,[fit_vbulk__tpn[0],fit_magf___tpn[0],fit_econv__tpn[0]],'PSYM'
options,[fit_vbulk__tpn[0],fit_magf___tpn[0],fit_econv__tpn[0]],'PSYM',/DEF
;;  Set YTITLEs
options, fit_parm_tpns[0],YTITLE=fit_parm_yttls[0],/DEF
options, fit_parm_tpns[1],YTITLE=fit_parm_yttls[1],/DEF
options, fit_parm_tpns[2],YTITLE=fit_parm_yttls[2],/DEF
options, fit_parm_tpns[3],YTITLE=fit_parm_yttls[3],/DEF
options, fit_sigm_tpns[0],YTITLE=fit_sigm_yttls[0],/DEF
options, fit_sigm_tpns[1],YTITLE=fit_sigm_yttls[1],/DEF
options, fit_sigm_tpns[2],YTITLE=fit_sigm_yttls[2],/DEF
options, fit_sigm_tpns[3],YTITLE=fit_sigm_yttls[3],/DEF
options,  fit_stat_tpn[0],YTITLE=fit_sdcr_yttls[0],/DEF
options,  fit_dof__tpn[0],YTITLE=fit_sdcr_yttls[1],/DEF
options, fit_chrch_tpn[0],YTITLE=fit_sdcr_yttls[2],/DEF
options, fit_chrch_tpn[1],YTITLE=fit_sdcr_yttls[3],/DEF
options,fit_strahl_tpn[0],YTITLE=fit_strhl_yttl[0],/DEF
options,fit_vbulk__tpn[0],YTITLE=fit_vbulk_yttl[0],/DEF
options,fit_magf___tpn[0],YTITLE=fit_magf__yttl[0],/DEF
options,fit_econv__tpn[0],YTITLE=fit_econv_yttl[0],/DEF
;;  Extra options
options,fit_strahl_tpn[0],YSUBTITLE=fit_strhl_ysub[0],YRANGE=fit_strhl_yran,/DEF
options,[fit_vbulk__tpn[0],fit_magf___tpn[0],fit_econv__tpn[0]],YSUBTITLE=fit_v_b_e_ysub[0],/DEF
;;  Change LABFLAG settings
options,tnames(),'LABFLAG'
options,tnames(),'LABFLAG',-1,/DEF
;;----------------------------------------------------------------------------------------
;;  Define constraints to determine "quality"
;;----------------------------------------------------------------------------------------
get_data, fit_parm_tpns[0],DATA=fit_parm_A_str
get_data, fit_parm_tpns[1],DATA=fit_parm_B_str
get_data, fit_parm_tpns[2],DATA=fit_parm_C_str
get_data, fit_parm_tpns[3],DATA=fit_parm_D_str
get_data,  fit_stat_tpn[0],DATA=fit_status_str
get_data, fit_chrch_tpn[1],DATA=fit_redchi_str
get_data,fit_strahl_tpn[0],DATA=fit_strahl_str
;;  Define some constraints
min_Eo         = 75d0
max_B          = 1.5d0
max_rchi2      = 1d3
min_A          = 1d5

;;  Define tests to determine the "quality" of any given fit
bad_A_par_test = (fit_parm_A_str.Y[*,0] LT min_A[0]) OR (fit_redchi_str.Y[*,0] GT max_rchi2[0])
bad_A_per_test = (fit_parm_A_str.Y[*,1] LT min_A[0]) OR (fit_redchi_str.Y[*,1] GT max_rchi2[0])
bad_A_ant_test = (fit_parm_A_str.Y[*,2] LT min_A[0]) OR (fit_redchi_str.Y[*,2] GT max_rchi2[0])
bad_B_par_test = (fit_parm_B_str.Y[*,0] GE 0) OR (ABS(fit_parm_B_str.Y[*,0]) GT max_B[0])
bad_B_per_test = (fit_parm_B_str.Y[*,1] GE 0) OR (ABS(fit_parm_B_str.Y[*,1]) GT max_B[0])
bad_B_ant_test = (fit_parm_B_str.Y[*,2] GE 0) OR (ABS(fit_parm_B_str.Y[*,2]) GT max_B[0])
bad_C_par_test = (fit_parm_C_str.Y[*,0] GE 0) OR ((1d0/ABS(fit_parm_C_str.Y[*,0])) LT min_Eo[0])
bad_C_per_test = (fit_parm_C_str.Y[*,1] GE 0) OR ((1d0/ABS(fit_parm_C_str.Y[*,1])) LT min_Eo[0])
bad_C_ant_test = (fit_parm_C_str.Y[*,2] GE 0) OR ((1d0/ABS(fit_parm_C_str.Y[*,2])) LT min_Eo[0])
bad_par_test   = bad_A_par_test OR bad_B_par_test OR bad_C_par_test OR FINITE(fit_strahl_str.Y[*,0])
bad_per_test   = bad_A_per_test OR bad_B_per_test OR bad_C_per_test
bad_ant_test   = bad_A_ant_test OR bad_B_ant_test OR bad_C_ant_test OR FINITE(fit_strahl_str.Y[*,1])
bad_stats_test = (fit_status_str.Y[*,0] LE 0) OR (fit_status_str.Y[*,1] LE 0) OR (fit_status_str.Y[*,2] LE 0)

bad_par        = WHERE(bad_par_test OR bad_stats_test,bd_par,COMPLEMENT=good_par,NCOMPLEMENT=gd_par)
bad_per        = WHERE(bad_per_test OR bad_stats_test,bd_per,COMPLEMENT=good_per,NCOMPLEMENT=gd_per)
bad_ant        = WHERE(bad_ant_test OR bad_stats_test,bd_ant,COMPLEMENT=good_ant,NCOMPLEMENT=gd_ant)
PRINT,';;',gd_par[0],gd_per[0],gd_ant[0],'  For '+tdate[0]+', Probe '+scu[0] & $
PRINT,';;',bd_par[0],bd_per[0],bd_ant[0],'  For '+tdate[0]+', Probe '+scu[0]
;;         719         911          90  For 2008-07-14, Probe C
;;         611         419        1240  For 2008-07-14, Probe C

;;  Define arrays for the power-law indices and energy cutoffs
powerlaws_gb   = REPLICATE(d,n_fits[0],3L,2L)
enercutof_gb   = REPLICATE(d,n_fits[0],3L,2L)
;;  Define arrays for the fit status and reduced chi-squared
fitstat___gb   = REPLICATE(d,n_fits[0],3L,2L)
red_chisq_gb   = REPLICATE(d,n_fits[0],3L,2L)
;;  Fill arrays
IF (gd_par GT 0) THEN powerlaws_gb[good_par,0L,0L] = fit_params[good_par,1,0]
IF (gd_per GT 0) THEN powerlaws_gb[good_per,1L,0L] = fit_params[good_per,1,1]
IF (gd_ant GT 0) THEN powerlaws_gb[good_ant,2L,0L] = fit_params[good_ant,1,2]
IF (bd_par GT 0) THEN powerlaws_gb[ bad_par,0L,1L] = fit_params[ bad_par,1,0]
IF (bd_per GT 0) THEN powerlaws_gb[ bad_per,1L,1L] = fit_params[ bad_per,1,1]
IF (bd_ant GT 0) THEN powerlaws_gb[ bad_ant,2L,1L] = fit_params[ bad_ant,1,2]
IF (gd_par GT 0) THEN enercutof_gb[good_par,0L,0L] = 1d0/ABS(fit_params[good_par,2,0])
IF (gd_per GT 0) THEN enercutof_gb[good_per,1L,0L] = 1d0/ABS(fit_params[good_per,2,1])
IF (gd_ant GT 0) THEN enercutof_gb[good_ant,2L,0L] = 1d0/ABS(fit_params[good_ant,2,2])
IF (bd_par GT 0) THEN enercutof_gb[ bad_par,0L,1L] = 1d0/ABS(fit_params[ bad_par,2,0])
IF (bd_per GT 0) THEN enercutof_gb[ bad_per,1L,1L] = 1d0/ABS(fit_params[ bad_per,2,1])
IF (bd_ant GT 0) THEN enercutof_gb[ bad_ant,2L,1L] = 1d0/ABS(fit_params[ bad_ant,2,2])
IF (gd_par GT 0) THEN fitstat___gb[good_par,0L,0L] = fit_status[good_par,0]
IF (gd_per GT 0) THEN fitstat___gb[good_per,1L,0L] = fit_status[good_per,1]
IF (gd_ant GT 0) THEN fitstat___gb[good_ant,2L,0L] = fit_status[good_ant,2]
IF (bd_par GT 0) THEN fitstat___gb[ bad_par,0L,1L] = fit_status[ bad_par,0]
IF (bd_per GT 0) THEN fitstat___gb[ bad_per,1L,1L] = fit_status[ bad_per,1]
IF (bd_ant GT 0) THEN fitstat___gb[ bad_ant,2L,1L] = fit_status[ bad_ant,2]
IF (gd_par GT 0) THEN red_chisq_gb[good_par,0L,0L] = red_chisq[good_par,0]
IF (gd_per GT 0) THEN red_chisq_gb[good_per,1L,0L] = red_chisq[good_per,1]
IF (gd_ant GT 0) THEN red_chisq_gb[good_ant,2L,0L] = red_chisq[good_ant,2]
IF (bd_par GT 0) THEN red_chisq_gb[ bad_par,0L,1L] = red_chisq[ bad_par,0]
IF (bd_per GT 0) THEN red_chisq_gb[ bad_per,1L,1L] = red_chisq[ bad_per,1]
IF (bd_ant GT 0) THEN red_chisq_gb[ bad_ant,2L,1L] = red_chisq[ bad_ant,2]
;;  Add offsets to keep status' from overlapping in plots
fitstat___gb[*,1L,*] += 0.2
fitstat___gb[*,2L,*] += 0.4
;;----------------------------------------------------------------------------------------
;;  Send results to TPLOT
;;----------------------------------------------------------------------------------------
;;  Define output structures
avg_unix       = (unix_sten[*,0] + unix_sten[*,1])/2d0
good_pl_str    = {X:avg_unix,Y:powerlaws_gb[*,*,0]}
bad__pl_str    = {X:avg_unix,Y:powerlaws_gb[*,*,1]}
good_Eo_str    = {X:avg_unix,Y:enercutof_gb[*,*,0]}
bad__Eo_str    = {X:avg_unix,Y:enercutof_gb[*,*,1]}
good_fs_str    = {X:avg_unix,Y:fitstat___gb[*,*,0]}
bad__fs_str    = {X:avg_unix,Y:fitstat___gb[*,*,1]}
good_rc_str    = {X:avg_unix,Y:red_chisq_gb[*,*,0]}
bad__rc_str    = {X:avg_unix,Y:red_chisq_gb[*,*,1]}

;;  Define TPLOT handles
tpn_suffx_pe   = ['powerlaws','ener_cutoffs','fit_status','red_chisq']
tpn_suffx_gb   = ['good','bad']
good_pl_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[0]+'_'+tpn_suffx_gb[0]
bad__pl_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[0]+'_'+tpn_suffx_gb[1]
good_Eo_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[1]+'_'+tpn_suffx_gb[0]
bad__Eo_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[1]+'_'+tpn_suffx_gb[1]
good_fs_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[2]+'_'+tpn_suffx_gb[0]
bad__fs_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[2]+'_'+tpn_suffx_gb[1]
good_rc_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[3]+'_'+tpn_suffx_gb[0]
bad__rc_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[3]+'_'+tpn_suffx_gb[1]

;;  Define YTITLE's and YSUBTITLE's
good_pl_yttle  = 'Power Law Index'
bad__pl_yttle  = good_pl_yttle[0]
good_pl_ysubt  = '[Good Const.]'
bad__pl_ysubt  = '[Bad Const.]'
good_Eo_yttle  = 'Energy Cutoff [eV]'
good_Eo_ysubt  = good_pl_ysubt[0]
bad__Eo_yttle  = good_Eo_yttle[0]
bad__Eo_ysubt  = bad__pl_ysubt[0]
good_fs_yttle  = 'Fit Status'
good_fs_ysubt  = good_pl_ysubt[0]
bad__fs_yttle  = good_fs_yttle[0]
bad__fs_ysubt  = bad__pl_ysubt[0]
good_rc_yttle  = 'Red. Chi^2'
good_rc_ysubt  = good_pl_ysubt[0]
bad__rc_yttle  = good_rc_yttle[0]
bad__rc_ysubt  = bad__pl_ysubt[0]

;;  Define YRANGE's
good_pl_yran   = [-155e-2,0e00]
bad__pl_yran   = [MIN(bad__pl_str.Y,/NAN),MAX(bad__pl_str.Y,/NAN)]
good_Eo_yran   = [1e1,(MAX(good_Eo_str.Y,/NAN) > 1e2) < 1e6]
bad__Eo_yran   = [1e1,(MAX(bad__Eo_str.Y,/NAN) > 1e2) < 1e6]
good_Eo_ytick  = get_power_of_ten_ticks(good_Eo_yran)
bad__Eo_ytick  = get_power_of_ten_ticks(bad__Eo_yran)
good_fs_yran   = [0e0,1e1]
bad__fs_yran   = [-19e0,1e0]
good_rc_yran   = [(MIN(good_rc_str.Y,/NAN)) < 9e-1,max_rchi2[0]]
bad__rc_yran   = [1e-1,(MAX(bad__rc_str.Y,/NAN) > 1e1) < 1e6]

;;  Send to TPLOT
store_data,good_pl_tpn[0],DATA=good_pl_str,DLIM=def_dlim,LIM=def__lim
store_data,bad__pl_tpn[0],DATA=bad__pl_str,DLIM=def_dlim,LIM=def__lim
store_data,good_Eo_tpn[0],DATA=good_Eo_str,DLIM=def_dlim,LIM=def__lim
store_data,bad__Eo_tpn[0],DATA=bad__Eo_str,DLIM=def_dlim,LIM=def__lim
store_data,good_fs_tpn[0],DATA=good_fs_str,DLIM=def_dlim,LIM=def__lim
store_data,bad__fs_tpn[0],DATA=bad__fs_str,DLIM=def_dlim,LIM=def__lim
store_data,good_rc_tpn[0],DATA=good_rc_str,DLIM=def_dlim,LIM=def__lim
store_data,bad__rc_tpn[0],DATA=bad__rc_str,DLIM=def_dlim,LIM=def__lim

;;  Alter options
symb          = 8
options,good_pl_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=good_pl_yttle[0],YLOG=0,YMINOR=4,/DEF
options,bad__pl_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=bad__pl_yttle[0],YLOG=0,YMINOR=4,/DEF
options,good_Eo_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=good_Eo_yttle[0],YLOG=1,YMINOR=9,/DEF
options,bad__Eo_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=bad__Eo_yttle[0],YLOG=1,YMINOR=9,/DEF
options,good_pl_tpn[0],YRANGE=good_pl_yran,YSUBTITLE=good_pl_ysubt[0],PSYM=symb[0],/DEF
options,bad__pl_tpn[0],YRANGE=bad__pl_yran,YSUBTITLE=bad__pl_ysubt[0],PSYM=symb[0],/DEF
options,good_Eo_tpn[0],YRANGE=good_Eo_yran,YSUBTITLE=good_Eo_ysubt[0],PSYM=symb[0],/DEF
options,bad__Eo_tpn[0],YRANGE=bad__Eo_yran,YSUBTITLE=bad__Eo_ysubt[0],PSYM=symb[0],/DEF
options,good_Eo_tpn[0],YTICKNAME=good_Eo_ytick.YTICKNAME,YTICKV=good_Eo_ytick.YTICKV,YTICKS=good_Eo_ytick.YTICKS,/DEF
options,bad__Eo_tpn[0],YTICKNAME=bad__Eo_ytick.YTICKNAME,YTICKV=bad__Eo_ytick.YTICKV,YTICKS=bad__Eo_ytick.YTICKS,/DEF
options,good_fs_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=good_fs_yttle[0],YLOG=0,YMINOR=4,/DEF
options,bad__fs_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=bad__fs_yttle[0],YLOG=0,YMINOR=4,/DEF
options,good_fs_tpn[0],YRANGE=good_fs_yran,YSUBTITLE=good_fs_ysubt[0],PSYM=symb[0],/DEF
options,bad__fs_tpn[0],YRANGE=bad__fs_yran,YSUBTITLE=bad__fs_ysubt[0],PSYM=symb[0],/DEF
options,good_rc_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=good_rc_yttle[0],YLOG=1,YMINOR=9,/DEF
options,bad__rc_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=bad__rc_yttle[0],YLOG=1,YMINOR=9,/DEF
options,good_rc_tpn[0],YRANGE=good_rc_yran,YSUBTITLE=good_rc_ysubt[0],PSYM=symb[0],/DEF
options,bad__rc_tpn[0],YRANGE=bad__rc_yran,YSUBTITLE=bad__rc_ysubt[0],PSYM=symb[0],/DEF

;;  Plot results
all_pl_tpns    = [good_pl_tpn[0],bad__pl_tpn[0]]
all_Eo_tpns    = [good_Eo_tpn[0],bad__Eo_tpn[0]]
all_fs_tpns    = [good_fs_tpn[0],bad__fs_tpn[0]]
all_rc_tpns    = [good_rc_tpn[0],bad__rc_tpn[0]]
all_gd_tpns    = [all_pl_tpns[0],all_Eo_tpns[0],all_fs_tpns[0],all_rc_tpns[0]]
all_bd_tpns    = [all_pl_tpns[1],all_Eo_tpns[1],all_fs_tpns[1],all_rc_tpns[1]]
par_per_ant_ii = [1L,4L,7L]
pl_gb_tpns     = [all_gd_tpns[0],all_bd_tpns[0]]
eo_gb_tpns     = [all_gd_tpns[1],all_bd_tpns[1]]
all_dB_Bo_tpns = [db_bov_dsl_tpn[0],db_bom_dsl_tpn[0],db_bom_mag_tpn[0]]
;;----------------------------------------------------------------------------------------
;;  Save new results for later
;;----------------------------------------------------------------------------------------
tpn_fpref_out  = 'TPLOT_save_file_'+prefu[0]
inst_mid_out   = 'FGM-ALL_EESA-IESA-Moments_EFI-Cal-Cor_SCM-Cal-Cor_ESA-SST-Spectra_'
start_of_day_t = '00:00:00.000'
end___of_day_t = '23:59:59.999'
tr_all_day     = tdate[0]+'/'+[start_of_day_t[0],end___of_day_t[0]]
fnm            = file_name_times(tr_all_day,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
file_out       = tpn_fpref_out[0]+inst_mid_out[0]+'eVDF_fit_results_'+tsuffx[0]
tplot_save,FILENAME=file_out[0]   ;;  tpn__file defined in load_thm_EB_and_fits_2_tplot_batch.pro
























