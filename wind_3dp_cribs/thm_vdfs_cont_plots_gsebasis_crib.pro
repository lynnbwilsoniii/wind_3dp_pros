;+
;*****************************************************************************************
;
;  CRIBSHEET:   thm_vdfs_cont_plots_gsebasis_crib.pro
;  PURPOSE  :   This is a crib sheet (i.e., enter commands by hand) meant to illustrate
;                 how to produce 2D contour plots with 1D cuts of a particle velocity
;                 distribution function (VDF) where the output is shown in the GSE
;                 coordinate basis.
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
;;  Setup for contour plots
;;----------------------------------------------------------------------------------------
WINDOW,1,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,2,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,3,RETAIN=2,XSIZE=800,YSIZE=1100

;;  Define plot output settings
ex_vn0         = 'B!Do!N'          ;;  String name of 1st output vector
ex_vn1         = 'V!Dsw!N'         ;;  String name of 2nd output vector
ngrid          = 30L               ;;  # of grid points to use [default setting, though I would not recommend changing this]
vlim           = 25e2              ;;  velocity limit for contour and X-axis of cuts
;;  Define plot range  [***  Change accordingly  ***]
dfra           = [1d-14,3d-6]      ;;  ***  Change accordingly  ***
;;  Define plot parameters
interpo        = 0                 ;;  Do not interpolate to original energies after transforming into PRF
no_redf        = 1                 ;;  Plot only cuts of the VDF
one_c          = 1                 ;;  Show one-count level
;;  Define smoothing parameters
nsmooth        = 4L                ;;  width to use in smoothing routine [change at user's discretion]
sm_cuts        = 1                 ;;  Smooth cuts [change at user's discretion]
sm_cont        = 0                 ;;  Do not smooth contours [change at user's discretion]
;;  Use XYZ-GSE as coordinate basis instead of FACs
xname          = 'Xgse'            ;;  Label used for plot axes titles
yname          = 'Ygse'            ;;  Label used for plot axes titles
vec1           = [1d0,0d0,0d0]     ;;  Use +X-GSE as 1st vector to construct coordinate basis
vec2           = [0d0,1d0,0d0]     ;;  Use +Y-GSE as 2nd " "
;;  Define VDF of interest
ind            = 846L              ;;  ***  Change accordingly  ***
dat            = dat_igse[ind[0]]
ex_vec0        = dat[0].MAGF       ;;  Values of 1st vector to construct coordinate basis
ex_vec1        = dat[0].VSW        ;;  Values of 2nd " "

WSET,1
WSHOW,1
plane          = 'xy'              ;;  Plot Y vs. X [X = VEC1, Y = (VEC1 x VEC2) x VEC1]
contour_3d_1plane,dat,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,YNAME=yname,       $
                      SM_CUTS=sm_cuts,NSMOOTH=nsmooth,ONE_C=one_c,DFRA=dfra,         $
                      VCIRC=vcirc,EX_VEC0=ex_vec0,EX_VN0=ex_vn0,EX_VEC1=ex_vec1,     $
                      EX_VN1=ex_vn1,NO_REDF=no_redf,PLANE=plane,                     $
                      NO_TRANS=no_trans,INTERP=interpo,SM_CONT=sm_cont,              $
                      DFMIN=dfmin,DFMAX=dfmax,DFSTR_OUT=dfstr_out


WSET,2
WSHOW,2
plane          = 'xz'              ;;  Plot X vs. Z [Z = (VEC1 x VEC2), X = VEC1]
contour_3d_1plane,dat,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,YNAME=yname,       $
                      SM_CUTS=sm_cuts,NSMOOTH=nsmooth,ONE_C=one_c,DFRA=dfra,         $
                      VCIRC=vcirc,EX_VEC0=ex_vec0,EX_VN0=ex_vn0,EX_VEC1=ex_vec1,     $
                      EX_VN1=ex_vn1,NO_REDF=no_redf,PLANE=plane,                     $
                      NO_TRANS=no_trans,INTERP=interpo,SM_CONT=sm_cont,              $
                      DFMIN=dfmin,DFMAX=dfmax,DFSTR_OUT=dfstr_out


WSET,3
WSHOW,3
plane          = 'yz'              ;;  Plot Z vs. Y [Z = (VEC1 x VEC2), Y = (VEC1 x VEC2) x VEC1]
contour_3d_1plane,dat,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,YNAME=yname,       $
                      SM_CUTS=sm_cuts,NSMOOTH=nsmooth,ONE_C=one_c,DFRA=dfra,         $
                      VCIRC=vcirc,EX_VEC0=ex_vec0,EX_VN0=ex_vn0,EX_VEC1=ex_vec1,     $
                      EX_VN1=ex_vn1,NO_REDF=no_redf,PLANE=plane,                     $
                      NO_TRANS=no_trans,INTERP=interpo,SM_CONT=sm_cont,              $
                      DFMIN=dfmin,DFMAX=dfmax,DFSTR_OUT=dfstr_out

;;----------------------------------------------------------------------------------------
;;  Compare GSE-rotated structures to original DSL
;;----------------------------------------------------------------------------------------
;;  The following was for a specific example and would change depending on time range
;;    loaded, user preferences, etc.
;    ind            = 846L              ;;  e.g., THC IESA Burst at 2008-07-14/21:58:25.037
;    PRINT,';;',dat_igse[ind].VSW & PRINT,';;',dat_i[ind].VSW
;    ;;      -612.78477       35.763135       15.090923
;    ;;      -606.25623      -36.680756      -90.110001
;    PRINT,';;',dat_igse[ind].MAGF & PRINT,';;',dat_i[ind].MAGF
;    ;;       1.7859265     -0.60941273      -3.9770446
;    ;;       1.2746922      0.87044406       4.1225343
;    
;    PRINT,';;', (mag__vec(dat_igse[ind].VSW))[0], (mag__vec(dat_i[ind].VSW))[0] & $
;    PRINT,';;',(mag__vec(dat_igse[ind].MAGF))[0],(mag__vec(dat_i[ind].MAGF))[0]
;    ;;       614.01296       614.01295
;    ;;       4.4020224       4.4020225
plane          = 'xy'              ;;  Plot Y vs. X [X = VEC1, Y = (VEC1 x VEC2) x VEC1]
plane          = 'xz'              ;;  Plot X vs. Z [Z = (VEC1 x VEC2), X = VEC1]
plane          = 'yz'              ;;  Plot Z vs. Y [Z = (VEC1 x VEC2), Y = (VEC1 x VEC2) x VEC1]
;;  Use XYZ-GSE as coordinate basis instead of FACs
xname          = 'Xgse'
yname          = 'Ygse'
vec1           = [1d0,0d0,0d0]     ;;  Use +X-GSE as 1st vector to construct coordinate basis
vec2           = [0d0,1d0,0d0]     ;;  Use +Y-GSE as 2nd " "
;;  Define VDF of interest
dat            = dat_igse[ind[0]]
ex_vec0        = dat[0].MAGF       ;;  Values of 1st vector to construct coordinate basis
ex_vec1        = dat[0].VSW        ;;  Values of 2nd " "

WSET,1
WSHOW,1
contour_3d_1plane,dat,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,YNAME=yname,       $
                      SM_CUTS=sm_cuts,NSMOOTH=nsmooth,ONE_C=one_c,DFRA=dfra,         $
                      VCIRC=vcirc,EX_VEC0=ex_vec0,EX_VN0=ex_vn0,EX_VEC1=ex_vec1,     $
                      EX_VN1=ex_vn1,NO_REDF=no_redf,PLANE=plane,                     $
                      NO_TRANS=no_trans,INTERP=interpo,SM_CONT=sm_cont,              $
                      DFMIN=dfmin,DFMAX=dfmax,DFSTR_OUT=dfstr_out


;;  Use XYZ-DSL as coordinate basis instead of FACs
xname          = 'Xdsl'
yname          = 'Ydsl'
vec1           = [1d0,0d0,0d0]     ;;  Use +X-DSL as 1st vector to construct coordinate basis
vec2           = [0d0,1d0,0d0]     ;;  Use +Y-DSL as 2nd " "
;;  Define VDF of interest
dat            = dat_i[ind[0]]
ex_vec0        = dat[0].MAGF       ;;  Values of 1st vector to construct coordinate basis
ex_vec1        = dat[0].VSW        ;;  Values of 2nd " "

WSET,2
WSHOW,2
contour_3d_1plane,dat,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,YNAME=yname,       $
                      SM_CUTS=sm_cuts,NSMOOTH=nsmooth,ONE_C=one_c,DFRA=dfra,         $
                      VCIRC=vcirc,EX_VEC0=ex_vec0,EX_VN0=ex_vn0,EX_VEC1=ex_vec1,     $
                      EX_VN1=ex_vn1,NO_REDF=no_redf,PLANE=plane,                     $
                      NO_TRANS=no_trans,INTERP=interpo,SM_CONT=sm_cont,              $
                      DFMIN=dfmin,DFMAX=dfmax,DFSTR_OUT=dfstr_out

















