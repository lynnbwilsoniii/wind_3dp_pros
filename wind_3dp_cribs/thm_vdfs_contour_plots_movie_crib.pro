;+
;*****************************************************************************************
;
;  CRIBSHEET:   thm_vdfs_contour_plots_movie_crib.pro
;  PURPOSE  :   This is a crib sheet (i.e., enter commands by hand) meant to illustrate
;                 how to produce 2D contour plots as a movie showing how the particle
;                 velocity distribution functions (VDFs) evolve through different
;                 magnetic field structures.  The user can change which TPLOT handles
;                 are used for the movie.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               load_themis_fgm_esa_idlsave_batch.pro
;               tnames.pro
;               add_magf2.pro
;               add_vsw2.pro
;               contour_3d_1plane.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ffmpeg from ImageMagick at:
;                     http://www.imagemagick.org/script/index.php
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Enter commands line-by-line by hand (i.e., not a batch file)
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
;   CREATED:  12/04/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/04/2015   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;----------------------------------------------------------------------------------------
;;  Constants [Enter as necessary]
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
c2             = c[0]^2
ckm            = c[0]*1d-3                ;;  m --> km
ckm2           = ckm[0]^2                 ;;  (km/s)^2
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
GG             = 6.6740800000d-11         ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1), 2014 CODATA/NIST]
SB             = 5.6703670000d-08         ;;  Stefan-Boltzmann Constant [W m^(-2) K^(-4), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;  Electromagnetic
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;;  Atomic
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
ma_eV          = ma[0]*c2[0]/qq[0]        ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
me_eV          = me[0]*c2[0]/qq[0]        ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mn_eV          = mn[0]*c2[0]/qq[0]        ;;  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c2[0]/qq[0]        ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;  --> Define mass of particles in units used by THEMIS ESA/SST, Wind 3DP, etc.
me_eVkms2      = me_eV[0]/ckm2[0]         ;;  Electron mass [eV km^(-2) s^(2)]
mp_eVkms2      = mp_eV[0]/ckm2[0]         ;;  Proton mass [eV km^(-2) s^(2)]
mn_eVkms2      = mn_eV[0]/ckm2[0]         ;;  Neutron mass [eV km^(-2) s^(2)]
ma_eVkms2      = ma_eV[0]/ckm2[0]         ;;  Alpha-Particle mass [eV km^(-2) s^(2)]
;;  Astronomical
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
au_km          = au[0]*1d-3               ;;  m --> km
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km
;;----------------------------------------------------------------------------------------
;;  Conversion Factors
;;
;;      Input Units:
;;        B  :  nT
;;        n  :  # cm^(-3)
;;        T  :  nT
;;----------------------------------------------------------------------------------------
;;  Energy and Temperature
f_1eV          = qq[0]/hh[0]                       ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
J_1eV          = hh[0]*f_1eV[0]                    ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
K_eV           = qq[0]/kB[0]                       ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
eV_K           = kB[0]/qq[0]                       ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
;;  Frequency
wcefac         = qq[0]*1d-9/me[0]                  ;;  factor for electron cyclotron angular frequency [rad s^(-1) nT^(-1)]
wcpfac         = qq[0]*1d-9/mp[0]                  ;;  factor for proton cyclotron angular frequency [rad s^(-1) nT^(-1)]
wpefac         = SQRT(1d6*qq[0]^2/(me[0]*epo[0]))  ;;  factor for electron plasma angular frequency [rad s^(-1) cm^(+3/2)]
wppfac         = SQRT(1d6*qq[0]^2/(mp[0]*epo[0]))  ;;  factor for electron plasma angular frequency [rad s^(-1) cm^(+3/2)]
fcefac         = wcefac[0]/(2d0*!DPI)              ;;  factor for electron cyclotron frequency [Hz s^(-1) nT^(-1)]
fcpfac         = wcpfac[0]/(2d0*!DPI)              ;;  factor for proton cyclotron frequency [Hz s^(-1) nT^(-1)]
fpefac         = wpefac[0]/(2d0*!DPI)              ;;  factor for electron plasma frequency [Hz s^(-1) cm^(+3/2)]
fppfac         = wppfac[0]/(2d0*!DPI)              ;;  factor for electron plasma frequency [Hz s^(-1) cm^(+3/2)]
;;  Speeds
vte_mps_fac    = SQRT(2d0*K_eV[0]*kB[0]/me[0])     ;;  factor for electron thermal speed [m s^(-1) eV^(-1/2)] (most probable speed)
vtp_mps_fac    = SQRT(2d0*K_eV[0]*kB[0]/mp[0])     ;;  factor for proton thermal speed [m s^(-1) eV^(-1/2)] (most probable speed)
vte_rms_fac    = SQRT(K_eV[0]*kB[0]/me[0])         ;;  factor for electron thermal speed [m s^(-1) eV^(-1/2)] (rms speed)
vtp_rms_fac    = SQRT(K_eV[0]*kB[0]/mp[0])         ;;  factor for proton thermal speed [m s^(-1) eV^(-1/2)] (rms speed)
valfen__fac    = 1d-9/SQRT(muo[0]*mp[0]*1d6)       ;;  factor for (proton-only) Alfvén speed [m s^(-1) nT^(-1) cm^(-3/2)]
;;  Lengths
rhoe_mps_fac   = vte_mps_fac[0]/wcefac[0]          ;;  factor for electron (most probable speed) thermal Larmor radius [m eV^(-1/2) nT]
rhop_mps_fac   = vtp_mps_fac[0]/wcpfac[0]          ;;  factor for proton (most probable speed) thermal Larmor radius [m eV^(-1/2) nT]
rhoe_rms_fac   = vte_rms_fac[0]/wcefac[0]          ;;  factor for electron (rms speed) thermal Larmor radius [m eV^(-1/2) nT]
rhop_rms_fac   = vtp_rms_fac[0]/wcpfac[0]          ;;  factor for proton (rms speed) thermal Larmor radius [m eV^(-1/2) nT]
iner_Lee_fac   = c[0]/wpefac[0]                    ;;  factor for electron inertial length [m cm^(-3/2)]
iner_Lep_fac   = c[0]/wppfac[0]                    ;;  factor for proton inertial length [m cm^(-3/2)]
;;----------------------------------------------------------------------------------------
;;  Default strings, coordinates, probes, etc.
;;----------------------------------------------------------------------------------------
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
all_scs        = ['a','b','c','d','e']
coord_spg      = 'spg'
coord_ssl      = 'ssl'
coord_dsl      = 'dsl'
coord_gei      = 'gei'
coord_geo      = 'geo'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
;;----------------------------------------------------------------------------------------
;;  Define Probe
;;----------------------------------------------------------------------------------------
;;  Probe A

probe          = 'a'

;;  Probe B

probe          = 'b'

;;  Probe C

probe          = 'c'

;;  Probe D

probe          = 'd'

;;  Probe E

probe          = 'e'
;;----------------------------------------------------------------------------------------
;;  Define Date/Time
;;----------------------------------------------------------------------------------------
;;  *** Change these according to the interval of interest to you ***
tdate          = '2008-07-26'        ;;  TDATE format:  'YYYY-MM-DD'
date           = '072608'            ;;   DATE format:  'MMDDYY'
;;----------------------------------------------------------------------------------------
;;  Find location of the THEMIS IDL save files
;;    *** See load_save_themis_fgm_esa_batch.pro for examples of how to create these ***
;;----------------------------------------------------------------------------------------
;;  Define the current working directory character
test           = (vern[0] GE '6.0')
IF (test[0]) THEN cwd_char = FILE_DIRNAME('',/MARK_DIRECTORY) ELSE $
                  cwd_char = '.'+slash[0]
;;  Define location of the THEMIS IDL save files
;;  **********************************************
;;  **     this will change for your system     **
;;  **********************************************
th_data_dir    = cur_wdir[0]+'IDL_stuff'+slash[0]+'themis_data_dir'+slash[0]
;;  **********************************************
;;  **     this will change for your system     **
;;  **********************************************

;;----------------------------------------------------------------------------------------
;;  Load data previously saved using @load_save_themis_fgm_esa_batch.pro
;;----------------------------------------------------------------------------------------
;;  Note:  You may need to use the entire path to the following if your IDL path is not
;;           set fully/correctly, e.g., on MY system I would type:
;;           @$HOME/Desktop/swidl-0.1/wind_3dp_pros/wind_3dp_cribs/load_themis_fgm_esa_idlsave_batch.pro
@load_themis_fgm_esa_idlsave_batch.pro

;;----------------------------------------------------------------------------------------
;;  Check to see if data were loaded
;;----------------------------------------------------------------------------------------
n_e            = N_ELEMENTS(dat_egse)
n_i            = N_ELEMENTS(dat_igse)
test           = (n_e[0] EQ 0) OR (n_i[0] EQ 0) OR ((tnames())[0] EQ '')
IF (test[0]) THEN STOP        ;;  NOTHING was loaded!
IF (test[0]) THEN g_load = 0b ELSE g_load = 1b

IF (g_load[0]) THEN veldsl_tpn     = tnames(scpref[0]+'peib_velocity_'+coord_dsl[0])
IF (g_load[0]) THEN magn_dsl_1     = tnames(scpref[0]+'fgl_'+coord_dsl[0])
IF (g_load[0]) THEN magn_dsl_2     = tnames(scpref[0]+'fgh_'+coord_dsl[0])
IF (g_load[0]) THEN ;;  Check that MAGF and VSW tags are defined
IF (g_load[0]) THEN add_magf2,dat_i,magn_dsl_1[0],/LEAVE_ALONE
IF (g_load[0]) THEN add_magf2,dat_i,magn_dsl_2[0],/LEAVE_ALONE
IF (g_load[0]) THEN add_vsw2, dat_i,veldsl_tpn[0],/LEAVE_ALONE
IF (g_load[0]) THEN add_magf2,dat_e,magn_dsl_1[0],/LEAVE_ALONE
IF (g_load[0]) THEN add_magf2,dat_e,magn_dsl_2[0],/LEAVE_ALONE
IF (g_load[0]) THEN add_vsw2, dat_e,veldsl_tpn[0],/LEAVE_ALONE
;;----------------------------------------------------------------------------------------
;;  Define relevant time ranges
;;----------------------------------------------------------------------------------------
eesa_st        = dat_egse.TIME
iesa_st        = dat_igse.TIME
eesa_et        = dat_egse.END_TIME
iesa_et        = dat_igse.END_TIME
;;  The input structures here are Burst mode --> ~3s sample intervals [based upon spin rate of probe]
srate_e        = sample_rate(eesa_st,/AVERAGE,GAP_THRESH=4d0)
srate_i        = sample_rate(iesa_st,/AVERAGE,GAP_THRESH=4d0)
xperd_e        = 1.5d0/srate_e[0]
xperd_i        = 1.5d0/srate_i[0]
;;  Define interval start/end indices
se_int_e       = t_interval_find(eesa_st,GAP_THRESH=xperd_e[0],/NAN)
se_int_i       = t_interval_find(iesa_st,GAP_THRESH=xperd_i[0],/NAN)
;;  Define time ranges for each interval
st_unix_e      = eesa_st[REFORM(se_int_e[*,0])]
en_unix_e      = eesa_et[REFORM(se_int_e[*,1])]
st_unix_i      = iesa_st[REFORM(se_int_i[*,0])]
en_unix_i      = iesa_et[REFORM(se_int_i[*,1])]
;;  Define indices for each interval
n_tr_e         = N_TAGS(se_int_e[*,0])
n_tr_i         = N_TAGS(se_int_i[*,0])
FOR j=0L, n_tr_e[0] - 1L DO BEGIN                                 $
  jstr  = 'T'+STRTRIM(STRING(j[0],FORMAT='(I)'),2L)             & $
  dint  = (se_int_e[j,1] - se_int_e[j,0]) + 1L                  & $
  goode = LINDGEN(dint[0]) + (se_int_e[j,0] > 0)                & $
  goode = goode < (n_e[0] - 1L)                                 & $
  str_element,e_ind,jstr[0],goode,/ADD_REPLACE

FOR j=0L, n_tr_i[0] - 1L DO BEGIN                                 $
  jstr  = 'T'+STRTRIM(STRING(j[0],FORMAT='(I)'),2L)             & $
  dint  = (se_int_i[j,1] - se_int_i[j,0]) + 1L                  & $
  goodi = LINDGEN(dint[0]) + (se_int_i[j,0] > 0)                & $
  goodi = goodi < (n_i[0] - 1L)                                 & $
  str_element,i_ind,jstr[0],goodi,/ADD_REPLACE

;;----------------------------------------------------------------------------------------
;;  Define VDF phase space density ranges for each time interval
;;----------------------------------------------------------------------------------------
;;  EESA
dumb_dfra      = [1e30,1e-30]
e_max          = 15e3             ;;  *** Change according to your own interests ***
FOR j=0L, n_tr_e[0] - 1L DO BEGIN                                           $
  jstr  = 'T'+STRTRIM(STRING(j[0],FORMAT='(I)'),2L)                       & $
  ind       = e_ind.(j)                                                   & $
  vdf_e_all = dat_egse[ind]                                               & $
  n_ind     = N_ELEMENTS(ind)                                             & $
  t_dfra    = dumb_dfra                                                   & $
  FOR k=0L, n_ind[0] - 1L DO BEGIN                                          $
    dat   = vdf_e_all[k]                                                  & $
    transform_vframe_3d,dat,/EASY_TRAN,INTERP=0                           & $
    data0 = dat[0].DATA                                                   & $
    ener0 = dat[0].ENERGY                                                 & $
    test  = (data0 LE 0) OR (FINITE(data0) EQ 0) OR (ener0 GT e_max[0])   & $
    bad   = WHERE(test,bd)                                                & $
    IF (bd GT 0) THEN data0[bad] = f                                      & $
    mnmx  = [MIN(data0,/NAN),MAX(data0,/NAN)]                             & $
    IF FINITE(mnmx[0]) THEN t_dfra[0] = t_dfra[0] < mnmx[0]               & $
    IF FINITE(mnmx[1]) THEN t_dfra[1] = t_dfra[1] > mnmx[1]               & $
  ENDFOR                                                                  & $
  str_element,dfra_e_all,jstr[0],t_dfra,/ADD_REPLACE

;;  IESA
dumb_dfra      = [1e30,1e-30]
e_max          = 15e3             ;;  *** Change according to your own interests ***
FOR j=0L, n_tr_i[0] - 1L DO BEGIN                                           $
  jstr  = 'T'+STRTRIM(STRING(j[0],FORMAT='(I)'),2L)                       & $
  ind       = i_ind.(j)                                                   & $
  vdf_i_all = dat_igse[ind]                                               & $
  n_ind     = N_ELEMENTS(ind)                                             & $
  t_dfra    = dumb_dfra                                                   & $
  FOR k=0L, n_ind[0] - 1L DO BEGIN                                          $
    dat   = vdf_i_all[k]                                                  & $
    transform_vframe_3d,dat,/EASY_TRAN,INTERP=0                           & $
    data0 = dat[0].DATA                                                   & $
    ener0 = dat[0].ENERGY                                                 & $
    test  = (data0 LE 0) OR (FINITE(data0) EQ 0) OR (ener0 GT e_max[0])   & $
    bad   = WHERE(test,bd)                                                & $
    IF (bd GT 0) THEN data0[bad] = f                                      & $
    mnmx  = [MIN(data0,/NAN),MAX(data0,/NAN)]                             & $
    IF FINITE(mnmx[0]) THEN t_dfra[0] = t_dfra[0] < mnmx[0]               & $
    IF FINITE(mnmx[1]) THEN t_dfra[1] = t_dfra[1] > mnmx[1]               & $
  ENDFOR                                                                  & $
  str_element,dfra_i_all,jstr[0],t_dfra,/ADD_REPLACE

;;  Print out results to check if all are valid
;;  EESA
dfra_s         = dfra_e_all
n_tr           = n_tr_e[0]
FOR j=0L, n_tr[0] - 1L DO PRINT,';;',dfra_s.(j)[0],dfra_s.(j)[1]

;;  IESA
dfra_s         = dfra_i_all
n_tr           = n_tr_i[0]
FOR j=0L, n_tr[0] - 1L DO PRINT,';;',dfra_s.(j)[0],dfra_s.(j)[1]

;;----------------------------------------------------------------------------------------
;;  Expand to nearest even power of 10
;;----------------------------------------------------------------------------------------
;;  EESA
dfra_s         = dfra_e_all
n_tr           = n_tr_e[0]
FOR j=0L, n_tr[0] - 1L DO BEGIN                                              $
  dfra_0     = dfra_s.(j)                                                  & $
  l10e       = ALOG10(dfra_0)                                              & $
  l10en      = FLOOR(l10e)                                                 & $
  dfra_s.(j) = FLOAT(1d1^l10en)
;;  Redefine VDF ranges
dfra_e_all     = dfra_s

;;  IESA
dfra_s         = dfra_i_all
n_tr           = n_tr_i[0]
FOR j=0L, n_tr[0] - 1L DO BEGIN                                              $
  dfra_0     = dfra_s.(j)                                                  & $
  l10e       = ALOG10(dfra_0)                                              & $
  l10en      = FLOOR(l10e)                                                 & $
  dfra_s.(j) = FLOAT(1d1^l10en)
;;  Redefine VDF ranges
dfra_i_all     = dfra_s


;;  Print out results to check if all are valid
;;  EESA
dfra_s         = dfra_e_all
n_tr           = n_tr_e[0]
FOR j=0L, n_tr[0] - 1L DO PRINT,';;',dfra_s.(j)[0],dfra_s.(j)[1]

;;  IESA
dfra_s         = dfra_i_all
n_tr           = n_tr_i[0]
FOR j=0L, n_tr[0] - 1L DO PRINT,';;',dfra_s.(j)[0],dfra_s.(j)[1]
;;----------------------------------------------------------------------------------------
;;  Plot individual contour plots and merge into a movie
;;----------------------------------------------------------------------------------------
;;  Define some dummy/defaults
ngrid          = 30L               ;;  # of grid points to use
sunv           = [1.,0.,0.]        ;;  Direction of sun from probe in GSE (inaccurate since probe is displaced from Earth, but close enough for our purposes)
sunn           = 'Sun Dir.'        ;;  name of extra vector
xname          = 'B!Do!N'          ;;  name of VEC1 (see below)
yname          = 'V!Dsw!N'         ;;  name of VEC2 (see below)
interpo        = 0                 ;;  Do NOT interpolate back to original energies after transforming into bulk flow rest frame
;;  Define the # of points to smooth the cuts of the DF
ns             = 3L
smc            = 1
smct           = 1
;;  Define the min/max allowable range in DF plots
dfmax          = 1d-1
dfmin          = 1d-21
;;  Define time ranges for contour movie routine
tra_outer      = 21d0           ;;  time [s] on either side of 3 VDF contours to show in TPLOT handles
fps            = 5L             ;;  # of frames per second
plane          = 'xy'           ;;  plane of projection shown for VDF contours

;;  Change the following TPLOT handles accordingly
;;    [*** Read contour_df_pos_slide_wrapper.pro Man. page to see limitations ***]
timename       = scpref[0]+'fgh_'+['mag',coord_gse[0]]
tsnames        = 'FGM-fgh-GSE_'

;;-----------------------------------------
;;  Define VDF-specific variables
;;-----------------------------------------
;;  EESA [Define only one of these sets, not both...]
vlim           = 40e3              ;;  velocity [km/s] limit for contour and X-axis of cuts
vcirc          = [10e3,20e3,30e3]  ;;  output circles of constant speed [km/s] onto contours
dat            = dat_egse
inds           = e_ind
tr_all         = [[st_unix_e],[en_unix_e]]
df_ras         = dfra_e_all

;;  IESA [Define only one of these sets, not both...]
vlim           = 25e2              ;;  velocity [km/s] limit for contour and X-axis of cuts
vcirc          = [5e2,10e2,15e2]   ;;  output circles of constant speed [km/s] onto contours
dat            = dat_igse
inds           = i_ind
tr_all         = [[st_unix_i],[en_unix_i]]
df_ras         = dfra_i_all
;;-----------------------------------------
;;  Define interval-specific variables
;;-----------------------------------------
jj             = 0L             ;;  *** Change indices of interval accordingly ***
ind            = inds.(jj)
dat_aa         = dat[ind]
tr_aa          = REFORM(tr_all[jj,*])
;tr_aa          = [st_unix_e[jj],en_unix_e[jj]]
dfra           = df_ras.(jj)

;;-----------------------------------------
;;  Produce .MOV movie
;;-----------------------------------------
contour_df_pos_slide_wrapper,timename,dat_aa,VLIM=vlim[0],NGRID=ngrid[0],XNAME=xname[0],  $
                              YNAME=yname[0],VCIRC=vcirc,EX_VEC0=gnorm,                   $
                              EX_VN0=normnm,EX_VEC1=sunv,EX_VN1=sunn[0],                  $
                              PLANE=plane,SM_CONT=smct,DFRA=dfra,TRANGE=tr_aa,            $
                              TROUTER=tra_outer,INTERP=interpo,DFMIN=dfmin,DFMAX=dfmax,   $
                              TSNAMES=tsnames,FRAMERATE=fps[0]























