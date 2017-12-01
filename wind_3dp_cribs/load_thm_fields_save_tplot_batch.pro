;+
;*****************************************************************************************
;
;  BATCH    :   load_thm_fields_save_tplot_batch.pro
;  PURPOSE  :   This is a batch file to be called from the command line using the
;                 standard method of calling
;                 (i.e., @load_thm_fields_save_tplot_batch.pro).
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               test_tdate_format.pro
;               time_double.pro
;               get_valid_trange.pro
;               themis_load_fgm_esa_inst.pro
;               tnames.pro
;               lbw_tplot_set_defaults.pro
;               options.pro
;               file_name_times.pro
;               set_tplot_times.pro
;               tplot.pro
;               t_get_current_trange.pro
;               thm_load_efi.pro
;               tplot_save.pro
;               get_data.pro
;               sample_rate.pro
;               t_interval_find.pro
;               thm_efi_clean_efw.pro
;               thm_efi_clean_efp.pro
;               thm_load_scm.pro
;               trange_clip.pro
;               store_data.pro
;               tsmooth2.pro
;               thm_lsp_clean_timestamp.pro
;               thm_fac_matrix_make.pro
;               tvector_rotate.pro
;               t_insert_nan_at_interval_se.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS 8.0 or SPEDAS 1.0 (or greater) IDL libraries
;               2)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ;;  Load all State, FGM, ESA, EFI, and SCM data for 2008-07-26 for Probe B
;               ;;  **********************************************
;               ;;  **  variable names MUST exactly match these **
;               ;;  **********************************************
;               probe          = 'b'
;               tdate          = '2008-07-26'
;               date           = '072608'
;               th_data_dir    = './IDL_stuff/themis_data_dir/'
;               @load_thm_fields_save_tplot_batch.pro
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Changed name from load_thm_fgm_efi_scm_save_tplot_batch.pro to
;                   load_thm_fields_save_tplot_batch.pro
;                                                                   [08/12/2015   v1.1.0]
;             2)  Fixed some typos and added forgotten implementation
;                                                                   [08/15/2015   v1.1.1]
;             3)  Now calls test_tdate_format.pro and get_valid_trange.pro
;                                                                   [10/23/2015   v1.2.0]
;             4)  Changed calling sequence to thm_efi_clean_efw.pro
;                                                                   [12/10/2016   v1.2.1]
;
;   NOTES:      
;               1)  This batch routine expects a date (in two formats) and a probe,
;                     all input on the command line prior to calling (see EXAMPLES)
;               2)  If your paths are not set correctly, you may need to provide a full
;                     path to this routine, e.g., the following is figurative and should
;                     be replaced with the full file path to this batch file:
;                     @/full/file/path/to/load_thm_fields_save_tplot_batch.pro
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
;   CREATED:  08/07/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/10/2016   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  IDL system and OS stuff
;;----------------------------------------------------------------------------------------
vers           = !VERSION.OS_FAMILY   ;;  e.g., 'unix'
vern           = !VERSION.RELEASE     ;;  e.g., '7.1.1'
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
GG             = 6.6740800000d-11         ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1), 2014 CODATA/NIST]
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
SB             = 5.6703670000d-08         ;;  Stefan-Boltzmann Constant [W m^(-2) K^(-4), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;--------------------------------------------
;;  Electromagnetic
;;--------------------------------------------
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;;--------------------------------------------
;;  Atomic
;;--------------------------------------------
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
ma_eV          = ma[0]*c[0]^2/qq[0]       ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
me_eV          = me[0]*c[0]^2/qq[0]       ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mn_eV          = mn[0]*c[0]^2/qq[0]       ;;  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c[0]^2/qq[0]       ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;  --> Define mass ratios [unitless]
mp_me          = 1.83615267389d+03        ;;  Proton-to-electron mass ratio [unitless, 2014 CODATA/NIST]
mp_mn          = 9.98623478440d-01        ;;  Proton-to-neutron mass ratio [unitless, 2014 CODATA/NIST]
ma_me          = 7.29429954136d+03        ;;  Alpha-to-electron mass ratio [unitless, 2014 CODATA/NIST]
ma_mn          = 3.97259968907d+00        ;;  Alpha-to-neutron mass ratio [unitless, 2014 CODATA/NIST]
;;--------------------------------------------
;;  Physico-Chemical
;;--------------------------------------------
avagadro       = 6.0221408570d+23         ;;  Avogadro's constant [# mol^(-1), 2014 CODATA/NIST]
amu            = 1.6605390400d-27         ;;  Atomic mass constant [kg, 2014 CODATA/NIST]
amu_eV         = amu[0]*c[0]^2/qq[0]      ;;  kg --> eV [931.4940954 MeV, 2014 CODATA/NIST]
;;--------------------------------------------
;;  Astronomical
;;--------------------------------------------
R_S___m        = 6.9600000d08             ;;  Sun's Mean Equatorial Radius [m, 2015 AA values]
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
;;  --> Planetary masses as ratio to sun's mass
Ms_M_Ea        = 3.329460487d05           ;;  Ratio of sun-to-Earth's mass [unitless, 2015 AA values]
;;  --> Planetary masses in SI units
M_E            = 5.9722000d24             ;;  Earth's mass [kg, 2015 AA values]
M_S__kg        = 1.9884000d30             ;;  Sun's mass [kg, 2015 AA values]
M_Ea_kg        = M_S__kg[0]/Ms_M_Ea[0]    ;;  Earth's mass [kg, 2015 AA values]
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
;;----------------------------------------------------------------------------------------
;;  Conversion Factors
;;
;;    Input Units:
;;      B  :  nT
;;      n  :  # cm^(-3)
;;      T  :  nT
;;----------------------------------------------------------------------------------------
;;  Energy and Temperature
f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
J_1eV          = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
K_eV           = qq[0]/kB[0]          ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
eV_K           = kB[0]/qq[0]          ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
;;--------------------------------------------
;;  Frequency
;;--------------------------------------------
wcefac         = qq[0]*1d-9/me[0]                  ;;  factor for electron cyclotron angular frequency [rad s^(-1) nT^(-1)]
wcpfac         = qq[0]*1d-9/mp[0]                  ;;  factor for proton cyclotron angular frequency [rad s^(-1) nT^(-1)]
wpefac         = SQRT(1d6*qq[0]^2/(me[0]*epo[0]))  ;;  factor for electron plasma angular frequency [rad s^(-1) cm^(+3/2)]
wppfac         = SQRT(1d6*qq[0]^2/(mp[0]*epo[0]))  ;;  factor for electron plasma angular frequency [rad s^(-1) cm^(+3/2)]
fcefac         = wcefac[0]/(2d0*!DPI)              ;;  factor for electron cyclotron frequency [Hz s^(-1) nT^(-1)]
fcpfac         = wcpfac[0]/(2d0*!DPI)              ;;  factor for proton cyclotron frequency [Hz s^(-1) nT^(-1)]
fpefac         = wpefac[0]/(2d0*!DPI)              ;;  factor for electron plasma frequency [Hz s^(-1) cm^(+3/2)]
fppfac         = wppfac[0]/(2d0*!DPI)              ;;  factor for electron plasma frequency [Hz s^(-1) cm^(+3/2)]
;;--------------------------------------------
;;  Speeds
;;--------------------------------------------
vte_mps_fac    = SQRT(2d0*K_eV[0]*kB[0]/me[0])     ;;  factor for electron thermal speed [m s^(-1) eV^(-1/2)] (most probable speed)
vtp_mps_fac    = SQRT(2d0*K_eV[0]*kB[0]/mp[0])     ;;  factor for proton thermal speed [m s^(-1) eV^(-1/2)] (most probable speed)
vte_rms_fac    = SQRT(K_eV[0]*kB[0]/me[0])         ;;  factor for electron thermal speed [m s^(-1) eV^(-1/2)] (rms speed)
vtp_rms_fac    = SQRT(K_eV[0]*kB[0]/mp[0])         ;;  factor for proton thermal speed [m s^(-1) eV^(-1/2)] (rms speed)
valfen__fac    = 1d-9/SQRT(muo[0]*mp[0]*1d6)       ;;  factor for (proton-only) Alfvén speed [m s^(-1) nT^(-1) cm^(-3/2)]
;;--------------------------------------------
;;  Lengths
;;--------------------------------------------
rhoe_mps_fac   = vte_mps_fac[0]/wcefac[0]          ;;  factor for electron (most probable speed) thermal Larmor radius [m eV^(-1/2) nT]
rhop_mps_fac   = vtp_mps_fac[0]/wcpfac[0]          ;;  factor for proton (most probable speed) thermal Larmor radius [m eV^(-1/2) nT]
rhoe_rms_fac   = vte_rms_fac[0]/wcefac[0]          ;;  factor for electron (rms speed) thermal Larmor radius [m eV^(-1/2) nT]
rhop_rms_fac   = vtp_rms_fac[0]/wcpfac[0]          ;;  factor for proton (rms speed) thermal Larmor radius [m eV^(-1/2) nT]
iner_Lee_fac   = c[0]/wpefac[0]                    ;;  factor for electron inertial length [m cm^(-3/2)]
iner_Lep_fac   = c[0]/wppfac[0]                    ;;  factor for proton inertial length [m cm^(-3/2)]
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
vec_str        = ['x','y','z']
fac_vec_str    = ['perp1','perp2','para']
fac_dir_str    = ['para','perp','anti']
vec_col        = [250,150,50]
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}
;;----------------------------------------------------------------------------------------
;;  THEMIS-specific defaults
;;----------------------------------------------------------------------------------------
all_scs        = ['a','b','c','d','e']
modes_slh      = ['s','l','h']
modes_fpw      = ['f','p','w']
modes_fgm      = 'fg'+modes_slh
modes_efi      = 'ef'+modes_fpw
modes_scm      = 'sc'+modes_fpw

coord_spg      = 'spg'
coord_ssl      = 'ssl'
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_fac      = 'fac'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
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
test           = ((N_ELEMENTS(date) EQ 0) OR (N_ELEMENTS(tdate) EQ 0) OR $
                 (N_ELEMENTS(probe) EQ 0)) OR $
                 ((SIZE(date,/TYPE) NE 7) OR (SIZE(tdate,/TYPE) NE 7) OR (SIZE(probe,/TYPE) NE 7))
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
tr_00          = tdate[0]+'/'+[start_of_day_t[0],end___of_day_t[0]]
;;  Make sure valid time range
trange         = time_double(tr_00)
test           = get_valid_trange(TRANGE=trange,PRECISION=6)
IF (SIZE(test,/TYPE) NE 8) THEN STOP        ;;  Stop before user runs into issues
;;----------------------------------------------------------------------------------------
;;  Load all State, FGM, and ESA L2 Moment data
;;----------------------------------------------------------------------------------------
;themis_load_fgm_esa_inst,DATE=date[0],PROBE=probe[0],TRANGE=time_double(tr_00)
themis_load_fgm_esa_inst,DATE=date[0],PROBE=probe[0],TRANGE=time_double(tr_00)
;;  Check output
test           = ((tnames())[0] EQ '')
IF (test) THEN STOP           ;;  No State or FGM data so no point continuing
;;----------------------------------------------------------------------------------------
;;  Set defaults
;;----------------------------------------------------------------------------------------
lbw_tplot_set_defaults

;;  Fix Y-Axis titles for frequencies
options,scpref[0]+'fgs_fci_flh_fce','YTITLE' 
options,scpref[0]+'fgs_fci_flh_fce','YTITLE',mode_fgm[0]+' [fci,flh,fce]',/DEF

;;  Open window
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*7d-1
win_ttl        = 'THEMIS-'+scu[0]+' Plots ['+tdate[0]+']'
win_str        = {RETAIN:2,XSIZE:wsz[0],YSIZE:wsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
WINDOW,0,_EXTRA=win_str
;;----------------------------------------------------------------------------------------
;;  Define location of IDL save files
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(th_data_dir) EQ 0) OR (SIZE(th_data_dir,/TYPE) NE 7)
IF (test) THEN th_data_dir = FILE_DIRNAME('',/MARK_DIRECTORY)
;;  Check for trailing '/'
ll             = STRMID(th_data_dir[0], STRLEN(th_data_dir[0]) - 1L,1L)
test_ll        = (ll[0] NE slash[0])
IF (test_ll[0]) THEN th_data_dir = th_data_dir[0]+slash[0]
;;  Define location for TPLOT save file
tpnsave_dir    = th_data_dir[0]+'themis_tplot_save'+slash[0]
;;  Make directory if not already existing
FILE_MKDIR,tpnsave_dir[0]
;;  Define file names for the IDL save files
tpn_fpref      = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
;;----------------------------------------------------------------------------------------
;;  Plot FGM magnitudes [quick look]
;;----------------------------------------------------------------------------------------
;;  Set TPLOT times and reference dates
set_tplot_times
;;  Plot fields
fgm_pren       = scpref[0]+modes_fgm+'_'
fgm_mag        = tnames(fgm_pren[*]+'mag')
tplot,fgm_mag,TRANGE=time_double(tr_00)
trange         = t_get_current_trange()
;;----------------------------------------------------------------------------------------
;;  Load EFI data (L1)
;;----------------------------------------------------------------------------------------
type_e         = 'calibrated'     ;;  Use physical units (i.e., mV/m instead of ADC counts)
mode_e         = 'efp efw'
coords         = coord_dsl[0]     ;;  Use DSL coordinates
l1_cal_e_suffx = '_l1_'+STRMID(type_e[0],0L,3L)
suffx          = l1_cal_e_suffx[0]+'_'+coords[0]

thm_load_efi,PROBE=sc[0],TRANGE=tr,/GET_SUPPORT,TYPE=type_e[0],SUFFIX=suffx[0],$
             DATATYPE=mode_e[0],COORD=coords[0],LEVEL=1
;;  Set defaults
lbw_tplot_set_defaults
;;  Check if routine was successful
efp_dsl_name   = tnames(scpref[0]+modes_efi[1]+suffx[0])
efw_dsl_name   = tnames(scpref[0]+modes_efi[2]+suffx[0])
test           = (efw_dsl_name[0] EQ '')
IF (test) THEN save_now = 1b ELSE save_now = 0b           ;;  No EFI data so no point continuing
;;  Check if batch should save now and quit?
IF (save_now) THEN fname = tpnsave_dir[0]+tpn_fpref[0]+tsuffx[0]+'.tplot'
IF (save_now) THEN tplot_save,FILENAME=fname[0]
IF (save_now) THEN STOP
options,[efp_dsl_name[0],efw_dsl_name[0]],COLORS=null,LABFLAG=null        ;;  remove definitions
;;  add definitions to defaults
options,[efp_dsl_name[0],efw_dsl_name[0]],COLORS=vec_col,LABFLAG=2,LABELS='E'+vec_str,/DEF
;;----------------------------------------------------------------------------------------
;;  Check if AC or DC-coupled
;;----------------------------------------------------------------------------------------
ac_c           = 0b
efw_hed_ac_tpn = tnames(scpref[0]+'efw_hed_ac')
test           = (efw_hed_ac_tpn[0] EQ '')
IF (test) THEN efw_hed_ac_tpn = tnames(scpref[0]+'efw*hed_ac*')
test           = (efw_hed_ac_tpn[0] EQ '')
IF (test) THEN ac_c = 0b
test_hac       = (efw_hed_ac_tpn[0] EQ '')
;;  Get EFI data
get_data,  efw_dsl_name[0],DATA=temp_efw,   DLIM=dlim_efw,   LIM=lim_efw
get_data,efw_hed_ac_tpn[0],DATA=temp_efw_ac,DLIM=dlim_efw_ac,LIM=lim_efw_ac
test           = (SIZE(temp_efw_ac,/TYPE) NE 8)
IF (test) THEN ac_c = 0b
test_hac       = (SIZE(temp_efw_ac,/TYPE) EQ 8)

IF (test_hac) THEN nhedac = N_ELEMENTS(temp_efw_ac.Y)
;;  Define parameters
efw_t          = temp_efw.X
efw_v          = temp_efw.Y
dumb10         = REPLICATE(d,10)
IF (test_hac) THEN hed_t = temp_efw_ac.X ELSE hed_t = dumb10
IF (test_hac) THEN hed_v = temp_efw_ac.Y ELSE hed_v = dumb10
;;  Define sample rates [sps]
srate_efw      = sample_rate(efw_t,GAP_THRESH=1d0,/AVE)
PRINT,';;',srate_efw[0],'  For  '+tdate[0]+', Probe '+scu[0]
;;       8192.0000  For  2008-08-12, Probe C
;;  Define intervals
se_efw_els     = t_interval_find(efw_t,GAP_THRESH=2d0/srate_efw[0],/NAN)
n_int          = N_ELEMENTS(se_efw_els[*,0])      ;;  # of intervals
ac_dc_test     = REPLICATE(0b,n_int[0])
FOR j=0L, n_int[0] - 1L DO BEGIN                            $
  se = REFORM(se_efw_els[j,*])                            & $
  t0 = REFORM(efw_t[se[0]:se[1]])                         & $
  tr0 = minmax(t0)                                        & $
  test = (hed_t GE tr0[0]) AND (hed_t LE tr0[0])          & $
  good = WHERE(test,gd)                                   & $
  IF (gd GT 0) THEN temp_acdc = WHERE(hed_v[good],gd_ac)  & $
  IF (gd GT 0) THEN ac_dc_test[j] = (gd EQ gd_ac)
;;  Define whether AC- or DC-coupled
ac_c           = (TOTAL(ac_dc_test) EQ n_int[0])
;;----------------------------------------------------------------------------------------
;;  Clean and calibrate the EFI data
;;----------------------------------------------------------------------------------------
IF (ac_c) THEN ac_ttl = 'AC' ELSE ac_ttl = 'DC'
klen           = 1024L
k_2            = klen[0]/2L
b_length       = 8L*klen[0]
;;  First keep "spikes" in data
new_suff1      = l1_cal_e_suffx[0]+'_tdas_corrected'
out_ef_names   = scpref[0]+modes_efi[2]+new_suff1[0]+'_'+[coord_dsl[0],coord_fac[0]]
thm_efi_clean_efw,PROBE=sc[0],TRANGE=trange,ENAME=efw_dsl_name[0],EFPNAME=efp_dsl_name[0],$
                  SPIKEREMOVE=0,EDSLNAME=out_ef_names[0],EFACNAME=out_ef_names[1],$
                  EFWHEDACNAME=efw_hed_ac_tpn[0]
;;  Set defaults
lbw_tplot_set_defaults
;;  Check if routine was successful
test           = ((tnames(out_ef_names))[0] EQ '')
IF (test) THEN save_now = 1b ELSE save_now = 0b           ;;  No SCM data so no point continuing
;;  Check if batch should save now and quit?
IF (save_now) THEN fname = tpnsave_dir[0]+tpn_fpref[0]+'EFI-Cal_'+tsuffx[0]+'.tplot'
IF (save_now) THEN tplot_save,FILENAME=fname[0]
IF (save_now) THEN STOP
;;  Alter default YTITLE's etc.
srate_e_str    = STRTRIM(STRING(FORMAT='(f15.0)',srate_efw[0]),2L)
yttls          = 'E [EFW, '+STRUPCASE([coord_dsl[0],coord_fac[0]])+', mV/m]'
ysubt_cor      = '[th'+sc[0]+' '+srate_e_str[0]+' sps, Cal., '+ac_ttl[0]+']'
options,out_ef_names,YTITLE=null,YSUBTITLE=null,COLORS=null,LABELS=null,LABFLAG=null     ;;  Remove current settings
FOR k=0L, 1L DO options,out_ef_names[k],YTITLE=yttls[k],YSUBTITLE=ysubt_cor[0],/DEF
options,out_ef_names,COLORS=vec_col,LABFLAG=2,/DEF
options,out_ef_names,COLORS=vec_col,LABFLAG=2,/DEF
options,out_ef_names[0],LABELS='E'+vec_str,/DEF
options,out_ef_names[1],LABELS='E'+fac_vec_str,/DEF
;;----------------------------------------------------------------------------------------
;;  Clean and calibrate the EFI data [try removing spikes this time]
;;----------------------------------------------------------------------------------------
new_suff2      = l1_cal_e_suffx[0]+'_tdas_corrected_rmspikes'
out_ef_name2   = scpref[0]+modes_efi[2]+new_suff2[0]+'_'+[coord_dsl[0],coord_fac[0]]
thm_efi_clean_efw,PROBE=sc[0],TRANGE=trange,ENAME=efw_dsl_name[0],EFPNAME=efp_dsl_name[0],$
                  SPIKEREMOVE=1,EDSLNAME=out_ef_name2[0],EFACNAME=out_ef_name2[1],$
                  SPIKENFIT=300,EFWHEDACNAME=efw_hed_ac_tpn[0]
;;  Set defaults
lbw_tplot_set_defaults
;;  Check if routine was successful
test           = ((tnames(out_ef_name2))[0] NE '')
ysubt_cor      = '[th'+sc[0]+' '+srate_e_str[0]+' sps, Rm Spikes]'+'!C'+'[Cal., '+ac_ttl[0]+']'
yttls          = 'E [EFW, '+STRUPCASE([coord_dsl[0],coord_fac[0]])+', mV/m]'
IF (test) THEN options,out_ef_name2,YTITLE=null,YSUBTITLE=null,COLORS=null,LABELS=null,LABFLAG=null     ;;  Remove current settings
IF (test) THEN FOR k=0L, 1L DO options,out_ef_name2[k],YTITLE=yttls[k],YSUBTITLE=ysubt_cor[0],/DEF
IF (test) THEN options,out_ef_name2,COLORS=vec_col,LABFLAG=2,/DEF
IF (test) THEN options,out_ef_name2,COLORS=vec_col,LABFLAG=2,/DEF
IF (test) THEN options,out_ef_name2[0],LABELS='E'+vec_str,/DEF
IF (test) THEN options,out_ef_name2[1],LABELS='E'+fac_vec_str,/DEF

;;  Try cleaning up efp data
new_suff2      = l1_cal_e_suffx[0]+'_tdas_corrected_rmspikes'
out_ef_name3   = scpref[0]+modes_efi[1]+new_suff2[0]+'_'+[coord_dsl[0],coord_gsm[0],coord_fac[0]]
thm_efi_clean_efp,PROBE=sc[0],TRANGE=trange,/SUBSOLAR,SPIKEREMOVE=1,$
                  EDSLNAME=out_ef_name3[0],EGSMNAME=out_ef_name3[1],$
                  EFACNAME=out_ef_name3[2],SPIKENFIT=20
;;  Set defaults
lbw_tplot_set_defaults
get_data,  efp_dsl_name[0],DATA=temp_efp,   DLIM=dlim_efp,   LIM=lim_efp
srate_efp      = sample_rate(temp_efp.X,GAP_THRESH=1d0,/AVE)
srate_ep_str   = STRTRIM(STRING(FORMAT='(f15.0)',srate_efp[0]),2L)
;;  Check if routine was successful
test           = ((tnames(out_ef_name3))[0] NE '')
ysubt_cor      = '[th'+sc[0]+' '+srate_ep_str[0]+' sps, Rm Spikes]'+'!C'+'[Cal., DC]'
yttls          = 'E [EFP, '+STRUPCASE([coord_dsl[0],coord_gsm[0],coord_fac[0]])+', mV/m]'
IF (test) THEN options,out_ef_name3,YTITLE=null,YSUBTITLE=null,COLORS=null,LABELS=null,LABFLAG=null     ;;  Remove current settings
IF (test) THEN FOR k=0L, 1L DO options,out_ef_name3[k],YTITLE=yttls[k],YSUBTITLE=ysubt_cor[0],/DEF
IF (test) THEN options,out_ef_name3,COLORS=vec_col,LABFLAG=2,/DEF
IF (test) THEN options,out_ef_name3,COLORS=vec_col,LABFLAG=2,/DEF
IF (test) THEN options,out_ef_name3[0:1],LABELS='E'+vec_str,/DEF
IF (test) THEN options,out_ef_name3[2],LABELS='E'+fac_vec_str,/DEF
;;----------------------------------------------------------------------------------------
;;  Load SCM data
;;----------------------------------------------------------------------------------------
IF ~KEYWORD_SET(nk) THEN nk = 256L
;;  Define the lower cutoff frequency [Hz], min. freq. bin [Hz], and corresponding suffix
IF (ac_c) THEN fcut_b  = 1e1         ELSE fcut_b  = 1e-1
IF (ac_c) THEN fmin_b  = 1e1         ELSE fmin_b  = 0e0
IF (ac_c) THEN suff_nb = '_HighPass' ELSE suff_nb = '_NoCutoff'
type_b         = 'calibrated'     ;;  Use physical units (i.e., nT)
despin_b       = 0                ;;  Do not de-spin
coords         = coord_dsl[0]     ;;  Use DSL coordinates
l1_cal_b_suffx = '_l1_'+STRMID(type_b[0],0L,3L)
suffb0         = l1_cal_b_suffx[0]+suff_nb[0]+'_'+coords[0]
mode_b         = 'scp scw'
thm_load_scm,PROBE=sc[0],DATATYPE=mode_b[0],TRANGE=tr,SUFFIX=suffb0[0],  $
             TYPE=type_b,COORD=coords[0],/GET_SUPPORT_DATA,NK=nk,        $
             /EDGE_TRUNCATE,FMIN=fmin_b,FCUT=fcut_b,DESPIN=despin_b,     $
             VERBOSE=0
;;  Set defaults
lbw_tplot_set_defaults
;;  Check if SCM data were loaded
scp_dsl_name   = tnames(scpref[0]+modes_scm[1]+suffb0[0])
scw_dsl_name   = tnames(scpref[0]+modes_scm[2]+suffb0[0])
test           = (scw_dsl_name[0] EQ '')
IF (test) THEN save_now = 1b ELSE save_now = 0b           ;;  No SCM data so no point continuing
;;  Check if batch should save now and quit?
IF (save_now) THEN fname = tpnsave_dir[0]+tpn_fpref[0]+'EFI-Cal-Cor_'+tsuffx[0]+'.tplot'
IF (save_now) THEN tplot_save,FILENAME=fname[0]
IF (save_now) THEN STOP
;;  Get SCM data
get_data, scw_dsl_name[0],DATA=temp_scw,   DLIM=dlim_scw,   LIM=lim_scw
get_data, scp_dsl_name[0],DATA=temp_scp,   DLIM=dlim_scp,   LIM=lim_scp
;;  Define parameters
scw_t          = temp_scw.X
scw_v          = temp_scw.Y
scp_t          = temp_scp.X
scp_v          = temp_scp.Y
;;  Define sample rates [sps]
srate_scw      = sample_rate(scw_t,GAP_THRESH=1d0,/AVE)
srate_scp      = sample_rate(scp_t,GAP_THRESH=1d0,/AVE)
srate_b_str    = STRTRIM(STRING(FORMAT='(f15.0)',srate_scw[0]),2L)
;;  Alter default YTITLE's etc.
yttls          = 'B [SCW, '+STRUPCASE(coord_dsl[0])+', nT]'
ysubt_cor      = '[th'+sc[0]+' '+srate_b_str[0]+' sps, Cal., '+ac_ttl[0]+']'
options,scw_dsl_name[0],YTITLE=null,YSUBTITLE=null,COLORS=null,LABELS=null,LABFLAG=null     ;;  Remove current settings
options,scw_dsl_name[0],YTITLE=yttls[0],YSUBTITLE=ysubt_cor[0],COLORS=vec_col,$
                        LABFLAG=2,LABELS='B'+vec_str,/DEF

srate_b_str2   = STRTRIM(STRING(FORMAT='(f15.0)',srate_scp[0]),2L)
yttls          = 'B [SCP, '+STRUPCASE(coord_dsl[0])+', nT]'
ysubt_cor      = '[th'+sc[0]+' '+srate_b_str2[0]+' sps, Cal., DC]'
options,scp_dsl_name[0],YTITLE=null,YSUBTITLE=null,COLORS=null,LABELS=null,LABFLAG=null     ;;  Remove current settings
options,scp_dsl_name[0],YTITLE=yttls[0],YSUBTITLE=ysubt_cor[0],COLORS=vec_col,$
                        LABFLAG=2,LABELS='B'+vec_str,/DEF
;;  Get SCW data
get_data, scw_dsl_name[0],DATA=temp_scw,   DLIM=dlim_scw,   LIM=lim_scw
;;  Define parameters
scw_t          = temp_scw.X
scw_v          = temp_scw.Y
;;  Define intervals
se_scw_els     = t_interval_find(scw_t,GAP_THRESH=2d0/srate_efw[0],/NAN)
b_int          = N_ELEMENTS(se_scw_els[*,0])      ;;  # of intervals
;;----------------------------------------------------------------------------------------
;;  Rotate to FACs
;;----------------------------------------------------------------------------------------
nsmpts         = 11  ; smooth points
get_data,fgm_pren[2]+coord_dsl[0],DATA=temp_fgh,DLIM=lim,LIM=lim
med_dt         = 1d0/srate_scw[0]
;;  Define parameters
Bdsl           = temp_scw
Bfac           = Bdsl
FOR j=0L, b_int[0] - 1L DO BEGIN                                                     $
  SCMclip = Bdsl                                                                   & $
  FGHclip = temp_fgh                                                               & $
  se = REFORM(se_scw_els[j,*])                                                     & $
  t0 = REFORM(scw_t[se[0]:se[1]])                                                  & $
  tr0 = minmax(t0)                                                                 & $
  Ttemp1 = tr0 + [-1,1]*med_dt[0]/2d0                                              & $
  trange_clip,SCMclip,Ttemp1[0],Ttemp1[1],/DATA,BADCLIP=badclip                    & $
  store_data,'SCMclip',DATA=SCMclip,DLIM=dlim_scw,LIM=lim_scw                      & $
  Ttemp2 = tr0 + [-1,1]*med_dt[0]/2d0 + [-1,1]*3d0                                 & $
  trange_clip,FGHclip,Ttemp2[0],Ttemp2[1],/DATA,BADCLIP=badclip                    & $
  IF KEYWORD_SET(badclip) THEN Bfac.Y[se[0]:se[1],*] = d                           & $
  store_data,'Bclip',DATA=FGHclip,DLIM=lim,LIM=lim                                 & $
  tsmooth2,'Bclip',nsmpts[0],NEWNAME='Bclip'                                       & $
  thm_lsp_clean_timestamp,'Bclip'                                                  & $
  thm_lsp_clean_timestamp,'SCMclip'                                                & $
  thm_fac_matrix_make,'Bclip',OTHER_DIM='zdsl',NEWNAME=scpref[0]+'_fgh_fac_mat'    & $
  tvector_rotate,scpref[0]+'_fgh_fac_mat','SCMclip',NEWNAME='SCMclip',ERROR=error  & $
  get_data,'SCMclip',DATA=SCMclip                                                  & $
  Bfac.Y[se[0]:se[1],*] = SCMclip.Y

;;  Store data
scw_fac_name   = scpref[0]+modes_scm[2]+l1_cal_b_suffx[0]+suff_nb[0]+'_'+coord_fac[0]
store_data,scw_fac_name[0],DATA=Bfac,DLIM=dlim_scw,LIM=lim_scw
;;  Alter options
yttls          = 'B [SCW, '+STRUPCASE(coord_fac[0])+', nT]'
options,scw_fac_name[0],'DATA_ATT.COORD_SYS','fac: x in spin-plane',/DEF
options,scw_fac_name[0],LABELS='B'+fac_vec_str,COLORS=vec_col,LABFLAG=2,YTITLE=yttls[0],/DEF
;;  Clean up
store_data,['Bclip','SCMclip',scpref[0]+'_fgh_fac_mat'],/DELETE
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'
;;  Set defaults
lbw_tplot_set_defaults
;;----------------------------------------------------------------------------------------
;;  Insert NaN's at the start/end of each interval in the FGM, EFI, and SCM data
;;----------------------------------------------------------------------------------------
fgh_tp_names   = fgm_pren[2]+[coord_ssl[0],coord_dsl[0],coord_gse[0],coord_gsm[0],coord_mag[0]]
tpname         = [efp_dsl_name[0],efw_dsl_name[0],out_ef_names,out_ef_name2,$
                  scp_dsl_name[0],scw_dsl_name[0],scw_fac_name[0],fgh_tp_names,out_ef_name3]
t_insert_nan_at_interval_se,tpname
;;----------------------------------------------------------------------------------------
;;  Define output file name and save
;;----------------------------------------------------------------------------------------
;fname          = tpnsave_dir[0]+tpn_fpref[0]+'EFI-Cal-Cor_SCM-Cal-Cor_'+tsuffx[0]+'.tplot'
fname          = tpnsave_dir[0]+tpn_fpref[0]+'EFI-Cal-Cor_SCM-Cal-Cor_'+tsuffx[0]
tplot_save,FILENAME=fname[0]




