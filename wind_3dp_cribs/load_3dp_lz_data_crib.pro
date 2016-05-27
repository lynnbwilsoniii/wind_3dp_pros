;+
;*****************************************************************************************
;
;  CRIB     :   load_3dp_lz_data_crib
;  PURPOSE  :   This crib sheet provides an example of how to load the level zero (lz)
;                 data from the Wind/3DP instrument into IDL and then create IDL save
;                 files for later use.  Due to the nature of the decomutation software,
;                 the data can only be loaded while IDL is in 32-bit mode unless you
;                 are using a Linux or Mac OS with 64-bit capability (see shared objects
;                 in ~/WIND_PRO directory, or *.so files).  So I generally load the data
;                 while in 32-bit mode, save as IDL save files, then exit IDL and
;                 re-start in 64-bit mode.  That way, one can load more than a week of
;                 SST data, for instance, without running out of memory.  More recently,
;                 (as of Sep. 30, 2015) a 64-bit *.so file was created for Mac OS X
;                 machines allowing Mac users to run IDL in 64-bit.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               load_3dp_data.pro
;               tplot_names.pro
;               time_double.pro
;               get_valid_trange.pro
;               tplot.pro
;               read_shocks_jck_database_new.pro
;               mag__vec.pro
;               unit_vec.pro
;               dot_prod_angle.pro
;               wind_orbit_to_tplot.pro
;               options.pro
;               tplot_options.pro
;               pesa_low_moment_calibrate.pro
;               waves_tnr_rad_to_tplot.pro
;               lbw_tplot_set_defaults.pro
;               get_3dp_structs.pro
;               add_vsw2.pro
;               add_magf2.pro
;               add_scpot.pro
;               file_name_times.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               [Enter by hand, do NOT run like a bash script]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Updated Man. page and several aspects of this crib sheet, including
;                   routines called and some algorithms
;                                                                   [10/23/2015   v1.1.0]
;
;   NOTES:      
;               1)  Enter each line in the command-line prompt, do not run like a batch
;                     file
;               2)  Read the tutorial PDF file in the following directory:
;                     ./wind_3dp_pros/wind_3dp_cribs/
;               3)  See also:  load_3dp_data.pro
;               4)  TPLOT Notes:
;                     To plot in TPLOT, you need only type the name "tplot" (without
;                       quotes) and then specify which TPLOT handles you wish to plot.
;                       For instance, suppose you loaded data and assigned the TPLOT
;                       handle 'test_handle_1', then to plot this one would do:
;                         IDL> tplot,'test_handle_1'
;                     TPLOT handles    = string and integer value associated with stored
;                                          time series data used to interface with user
;                     TPLOT structures = All TPLOT IDL structures have the same basic
;                                          format with the following required tags:
;                                            X    :  {N}-Element [double] array of Unix
;                                                      times, upon which all other tags
;                                                      depend
;                                            Y    :  {N[,E,A]}-Element [float/double]
;                                                      array of data for each Unix time
;                                        If the data is a spectrogram-like plot or has
;                                          more than just one dimension, then the
;                                          following extra tags are required:
;                                            V    :  {N,E}-Element [float/double] array
;                                                      of Y-Axis values [if included,
;                                                      then Y data corresponds to Z-Axis
;                                                      (usually defined by a color bar)]
;                                            SPEC :  Scalar [integer/long/float/double]
;                                                      defining whether to plot data as a
;                                                      color-scale spectrogram (= 1) or
;                                                      as a stacked line plot (= 0),
;                                                      where each line corresponds to a
;                                                      given value in V
;                                        In the most complicated form, there are two
;                                          additional tags but when these are defined,
;                                          then V is not.  This almost always corresponds
;                                          to data that contains both energy and pitch-
;                                          angle bins.  So in the case of particle
;                                          spectra, we have:
;                                            V1   :  {N,E}-Element [float/double] array
;                                                      of energy bin values
;                                            V2   :  {N,A}-Element [float/double] array
;                                                      of pitch-angle bin values
;
;  REFERENCES:  
;               1)  Carlson et al., (1983), "An instrument for rapidly measuring
;                      plasma distribution functions with high resolution,"
;                      Adv. Space Res. Vol. 2, pp. 67-70.
;               2)  Curtis et al., (1989), "On-board data analysis techniques for
;                      space plasma particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372.
;               3)  Lin et al., (1995), "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125.
;               4)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               5)  Bougeret, J.-L., M.L. Kaiser, P.J. Kellogg, R. Manning, K. Goetz,
;                      S.J. Monson, N. Monge, L. Friel, C.A. Meetre, C. Perche,
;                      L. Sitruk, and S. Hoang (1995) "WAVES:  The Radio and Plasma
;                      Wave Investigation on the Wind Spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 231-263, doi:10.1007/BF00751331.
;               6)  Viñas, A.F. and J.D. Scudder (1986), "Fast and Optimal Solution to
;                      the 'Rankine-Hugoniot Problem'," J. Geophys. Res. 91, pp. 39-58.
;               7)  A. Szabo (1994), "An improved solution to the 'Rankine-Hugoniot'
;                      problem," J. Geophys. Res. 99, pp. 14,737-14,746.
;               8)  Koval, A. and A. Szabo (2008), "Modified 'Rankine-Hugoniot' shock
;                      fitting technique:  Simultaneous solution for shock normal and
;                      speed," J. Geophys. Res. 113, pp. A10110.
;               9)  Russell, C.T., J.T. Gosling, R.D. Zwickl, and E.J. Smith (1983),
;                      "Multiple spacecraft observations of interplanetary shocks:  ISEE
;                      Three-Dimensional Plasma Measurements," J. Geophys. Res. 88,
;                      pp. 9941-9947.
;
;   CREATED:  09/20/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/23/2015   v1.1.0
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
;;--------------------------------------------
;;  Astronomical
;;--------------------------------------------
R_S___m        = 6.9600000d08             ;;  Sun's Mean Equatorial Radius [m, 2015 AA values]
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
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
;;  Define date strings
;;----------------------------------------------------------------------------------------
date           = '040396'
tdate          = '1996-04-03'
;;----------------------------------------------------------------------------------------
;;  Load 3DP data
;;    -->  The following loads data from the level zero files found at:
;;           http://sprg.ssl.berkeley.edu/wind3dp/data/wi/3dp/lz/
;;    -->  load_3dp_data.pro requires the use of a shared object library, which are
;;           found in the ./wind_3dp_pros/WIND_PRO/ directory and are both operating
;;           system- (OS) and memory size-dependent (i.e., *_64.so files allow the use
;;           of 64 bit IDL, whereas others require 32 bit IDL)
;;----------------------------------------------------------------------------------------
;;  Define a start date and time
start_t        = tdate[0]+'/'+start_of_day_t[0]
;;  Define a duration of time to load [hours]
dur            = 120.
;;  Define the memory size to limit to [mostly for older systems]
memsz          = 150.
;;  Define the packet quality [2 allows "invalid" distributions through]
qual           = 2
;;  Load the level zero data files and store in pointer memory
load_3dp_data,start_t[0],dur[0],QUALITY=qual[0],MEMSIZE=memsz[0]

;;  Check to see if variables were loaded into TPLOT
;;    --> The following routine will print both the numeric and string TPLOT handles
tplot_names
;;----------------------------------------------------------------------------------------
;;  Define Time Range
;;----------------------------------------------------------------------------------------
;;  Default to entire day
tr_00          = tdate[0]+'/'+[start_of_day_t[0],end___of_day_t[0]]
trange         = time_double(tr_00)
test           = get_valid_trange(TRANGE=trange,PRECISION=6)
IF (SIZE(test,/TYPE) NE 8) THEN STOP        ;;  Stop before user runs into issues
;;  In general, time stamps in TPLOT are Unix times.  If in string format, then they must
;;    have a format consistent with:
;;      'YYYY-MM-DD/hh:mm:ss.xxx'
;;    where each part is defined as:
;;      YYYY  :  4 digit year
;;      MM    :  2 digit month of year
;;      DD    :  2 digit day of month
;;      hh    :  2 digit hour of day
;;      mm    :  2 digit minute of hour
;;      ss    :  2 digit second of minute
;;      xxx   :  N digit fractional second (seems to work up to ~6-7 digits before
;;                 rounding errors take over)
t              = test.STRING_TRANGE     ;;  [2]-element array [e.g., '1996-04-03/00:00:00']
tra            = test.UNIX_TRANGE       ;;  Unix times
tdates         = test.DATE_TRANGE       ;;  [e.g., '1996-04-03']
fdate          = ''                     ;;  [e.g., '04-03-1996']
fdate          = STRMID(tdates,5L)+'-'+STRMID(tdates,0L,4L)
;time_ra        = time_range_define(DATE=date[0])
;t              = time_ra.TR_STRING     ;;  [2]-element array [e.g., '1996-04-03/00:00:00']
;tra            = time_ra.TR_UNIX       ;;  Unix times
;tdates         = time_ra.TDATE_SE      ;;  [e.g., '1996-04-03']
;fdate          = time_ra.FDATE_SE      ;;  [e.g., '04-03-1996']
;;----------------------------------------------------------------------------------------
;;  Open window and plot
;;----------------------------------------------------------------------------------------
;;  Open window
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*7d-1
win_ttl        = 'Wind Plots ['+tdates[0]+']'
win_str        = {RETAIN:2,XSIZE:wsz[0],YSIZE:wsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
WINDOW,0,_EXTRA=win_str
;;  Plot MFI data
tplot,[1,2],TRANGE=tra
;;----------------------------------------------------------------------------------------
;;  Get Rankine-Hugoniot results, if available, from CfA Harvard Wind shock database at:
;;    https://www.cfa.harvard.edu/shocks/wi_data/
;;
;;  Let use define the following:
;;      SCF   :  spacecraft frame of reference
;;      SHF   :  shock rest frame of reference
;;
;;
;;  They assume several things, as they only use the SWE Faraday cup data (i.e., only
;;    ions).  They must assume Te ~ Ti, for instance.  Let use define the following:
;;      Cs    :  ion-acoustic sound speed or just sound speed
;;      VA    :  Alfvén speed
;;      W_j   :  thermal speed (i.e., rms speed) of species j
;;      ß     :  Total plasma beta
;;      Zi    :  Charge state of ion
;;      ¥j    :  polytrope index of species j (i.e., ratio of specific heats)
;;      T_j   :  Temperature of species j
;;      M_j   :  Mass " "
;;      kB    :  Boltzmann constant
;;    Then we can define these in terms of their parameter dependencies as:
;;      Cs^2  = [kB ( Zi ¥e T_e + ¥i T_i )/M_i]
;;            = (5/3)*W_i^2 [for CfA database results]
;;      W_e^2 = kB T_e/M_e = (M_i/2 M_e) W_i^2
;;      W_i^2 = kB T_i/M_i
;;      ß     = (3/5)*Cs^2/VA^2
;;----------------------------------------------------------------------------------------
test_bst       = read_shocks_jck_database_new(/CFA_METH_ONLY,GIND_3D=gind_3d_bst)
;;  Define internal structures
gen_info_str   = test_bst.GEN_INFO
asy_info_str   = test_bst.ASY_INFO
bvn_info_str   = test_bst.BVN_INFO
key_info_str   = test_bst.KEY_INFO
ups_info_str   = test_bst.UPS_INFO
dns_info_str   = test_bst.DNS_INFO
;;  Define general info
tdates_bst     = gen_info_str.TDATES
rhmeth_bst     = gen_info_str.RH_METHOD               ;;  Defines method used to determine shock normal
unix_ra        = gen_info_str.ARRT_UNIX.Y             ;;  Unix times at center of ramps
;;  Define upstream plasma parameters
vi_gse_up      = asy_info_str.VBULK_GSE.Y[*,*,0]      ;;  Avg. upstream bulk flow velocity [GSE, km/s]
bo_gse_up      = asy_info_str.MAGF_GSE.Y[*,*,0]       ;;  " " magnetic field vector [GSE, nT]
wi_rms_up      = asy_info_str.VTH_ION.Y[*,0]          ;;  " " ion thermal speed [rms speed, km/s]
ni_avg_up      = asy_info_str.DENS_ION.Y[*,0]         ;;  " " ion number density [cm^(-3)]
beta_t_up      = asy_info_str.PLASMA_BETA.Y[*,0]      ;;  " " total plasma beta
Cs_avg_up      = asy_info_str.SOUND_SPEED.Y[*,0]      ;;  " " ion-acoustic sound speed
VA_avg_up      = asy_info_str.ALFVEN_SPEED.Y[*,0]     ;;  " " Alfvén speed
;;  Define downstream plasma parameters
vi_gse_dn      = asy_info_str.VBULK_GSE.Y[*,*,1]      ;;  Avg. downstream bulk flow velocity [GSE, km/s]
bo_gse_dn      = asy_info_str.MAGF_GSE.Y[*,*,1]       ;;  " " magnetic field vector [GSE, nT]
wi_rms_dn      = asy_info_str.VTH_ION.Y[*,1]          ;;  " " ion thermal speed [rms speed, km/s]
ni_avg_dn      = asy_info_str.DENS_ION.Y[*,1]         ;;  " " ion number density [cm^(-3)]
beta_t_dn      = asy_info_str.PLASMA_BETA.Y[*,1]      ;;  " " total plasma beta
Cs_avg_dn      = asy_info_str.SOUND_SPEED.Y[*,1]      ;;  " " ion-acoustic sound speed
VA_avg_dn      = asy_info_str.ALFVEN_SPEED.Y[*,1]     ;;  " " Alfvén speed
;;  Define magnitudes for vectors
vi_mag_up      = mag__vec(vi_gse_up)
bo_mag_up      = mag__vec(bo_gse_up)
vi_mag_dn      = mag__vec(vi_gse_dn)
bo_mag_dn      = mag__vec(bo_gse_dn)
;;  Define unit vectors and angle between upstream/downstream Avg.s
vi_uvc_up      = unit_vec(vi_gse_up)
bo_uvc_up      = unit_vec(bo_gse_up)
vi_uvc_dn      = unit_vec(vi_gse_dn)
bo_uvc_dn      = unit_vec(bo_gse_dn)
vi_ang_ud      = dot_prod_angle(vi_uvc_up,vi_uvc_dn,/NAN)
bo_ang_ud      = dot_prod_angle(bo_uvc_up,bo_uvc_dn,/NAN)
;;  Define Key Shock Analysis parameters
thetbn_up      = key_info_str.THETA_BN.Y              ;;  Avg. upstream shock normal angle [deg]
vshn___up      = ABS(key_info_str.VSHN_UP.Y)          ;;  " " shock normal speed [SCF, km/s]
N2_N1__up      = ABS(key_info_str.NIDN_NIUP.Y)        ;;  Shock compression ratio [unitless]
nsh____up      = bvn_info_str.SH_N_GSE.Y              ;;  Shock normal unit vector [GSE, unitless]
;;  Define Upstream Shock Analysis results
ushn___up      = ABS(ups_info_str.USHN.Y)             ;;  Avg. upstream shock normal speed [SHF, km/s]
Vslow__up      = ABS(ups_info_str.V_SLOW.Y)           ;;  " " slow         mode phase speed [km/s]
Vint___up      = ABS(ups_info_str.V_INTM.Y)           ;;  " " intermediate mode phase speed [km/s]
Vfast__up      = ABS(ups_info_str.V_FAST.Y)           ;;  " " fast         mode phase speed [km/s]
Mslow__up      = ABS(ups_info_str.M_SLOW.Y)           ;;  " " slow         mode Mach number [unitless]
Mfast__up      = ABS(ups_info_str.M_FAST.Y)           ;;  " " fast         mode Mach number [unitless]
M_Cs___up      = ABS(ups_info_str.M_CS.Y)             ;;  " " sound             Mach number [unitless]
M_VA___up      = ABS(ups_info_str.M_VA.Y)             ;;  " " Alfvén            Mach number [unitless]
;;  Define Downstream Shock Analysis results
ushn___dn      = ABS(dns_info_str.USHN.Y)             ;;  Avg. downstream shock normal speed [SHF, km/s]
Vslow__dn      = ABS(dns_info_str.V_SLOW.Y)           ;;  " " slow         mode phase speed [km/s]
Vint___dn      = ABS(dns_info_str.V_INTM.Y)           ;;  " " intermediate mode phase speed [km/s]
Vfast__dn      = ABS(dns_info_str.V_FAST.Y)           ;;  " " fast         mode phase speed [km/s]
Mslow__dn      = ABS(dns_info_str.M_SLOW.Y)           ;;  " " slow         mode Mach number [unitless]
Mfast__dn      = ABS(dns_info_str.M_FAST.Y)           ;;  " " fast         mode Mach number [unitless]
M_Cs___dn      = ABS(dns_info_str.M_CS.Y)             ;;  " " sound             Mach number [unitless]
M_VA___dn      = ABS(dns_info_str.M_VA.Y)             ;;  " " Alfvén            Mach number [unitless]
;;  Determine which shock to use
gshock         = WHERE(tdates_bst EQ tdate[0],gsh)
PRINT,';; ',gsh[0]

;;  Some dates have two shocks per date, so choose which one to use
;;    [see two commented examples below]
IF (SIZE(kk,/TYPE) EQ 0) THEN kk = 0
gcomp          = N2_N1__up[gshock[kk]]
tura           = unix_ra[gshock[kk]]
gthbn          = thetbn_up[gshock[kk]]
gavsw          = REFORM(vi_gse_up[gshock[kk],*])
gmagf          = REFORM(bo_gse_up[gshock[kk],*])
gnorm          = REFORM(nsh____up[gshock[kk],*])
;;----------------------------------------------------------------------------------------
;;  Load orbit data
;;----------------------------------------------------------------------------------------
Bgse_tpnm      = 'wi_B3(GSE)'        ;;  TPLOT handle associated with Bo [GSE, nT]
wind_orbit_to_tplot,BNAME=Bgse_tpnm[0],TRANGE=tra
;;  Change Y-Axis titles
options,'Wind_Radial_Distance','YTITLE','Radial Dist. (R!DE!N)'
options,'Wind_GSE_Latitude','YTITLE','GSE Lat. [deg]'
options,'Wind_GSE_Longitude','YTITLE','GSE Lon. [deg]'
;;  Add these variables as tick mark labels
gnames         = ['Wind_Radial_Distance','Wind_GSE_Latitude','Wind_GSE_Longitude','Wind_MLT']
tplot_options,VAR_LABEL=gnames
;;  Replot data to see new tick mark labels
tplot
;;----------------------------------------------------------------------------------------
;;  Load ion moments
;;----------------------------------------------------------------------------------------
Bgse_tpnm      = 'wi_B3(GSE)'        ;;  TPLOT handle associated with Bo [GSE, nT]
Vgse_tpnm      = 'V_sw2'             ;;  " " Vsw [GSE, km/s]
pesa_low_moment_calibrate,DATE=date,TRANGE=tra,BNAME=Bgse_tpnm[0],$
                          COMPRESS=gcomp[0],MIDRA=tura[0]
;;  Determine which TPLOT handle to use for estimate of spacecraft potential [eV]
IF (tnames('sc_pot_3') EQ '') THEN scp_tpn = 'sc_pot_2' ELSE scp_tpn = 'sc_pot_3'
;;----------------------------------------------------------------------------------------
;;  Load WAVES radio data
;;----------------------------------------------------------------------------------------
fl        = 4.
fh        = 13e3
yscl      = 'log'
waves_tnr_rad_to_tplot,DATE=date,FLOW=fl[0],FHIGH=fh[0],YSCL=yscl[0],TRANGE=tra
;;----------------------------------------------------------------------------------------
;;  Set some defaults for TPLOT
;;----------------------------------------------------------------------------------------
lbw_tplot_set_defaults
;;----------------------------------------------------------------------------------------
;;  Get thermal [PESA Low] and suprathermal [PESA High]
;;    ion velocity distribution functions (VDFs)
;;
;;    Low   :  ~0.1-10.0 keV ions
;;    High  :  ~0.5-28.0 keV ions
;;----------------------------------------------------------------------------------------
fpref          = 'Pesa_3DP_Structures_'
fsuffx         = '_w-Vsw-Ni-SCPot.sav'
pldat          = get_3dp_structs('pl' ,TRANGE=tra)      ;;  PESA  Low
plbdat         = get_3dp_structs('plb',TRANGE=tra)      ;;  PESA  Low Burst
phdat          = get_3dp_structs('ph' ,TRANGE=tra)      ;;  PESA High
phbdat         = get_3dp_structs('phb',TRANGE=tra)      ;;  PESA High Burst
IF (SIZE( pldat,/TYPE) EQ 8) THEN apl  =  pldat.DATA
IF (SIZE( phdat,/TYPE) EQ 8) THEN aph  =  phdat.DATA
IF (SIZE(plbdat,/TYPE) EQ 8) THEN aplb = plbdat.DATA
IF (SIZE(phbdat,/TYPE) EQ 8) THEN aphb = phbdat.DATA

IF (SIZE( pldat,/TYPE) EQ 8) THEN add_vsw2,apl,Vgse_tpnm[0]
IF (SIZE( pldat,/TYPE) EQ 8) THEN add_magf2,apl,Bgse_tpnm[0]
IF (SIZE( pldat,/TYPE) EQ 8) THEN add_scpot,apl,scp_tpn[0]
IF (SIZE( phdat,/TYPE) EQ 8) THEN add_vsw2,aph,Vgse_tpnm[0]
IF (SIZE( phdat,/TYPE) EQ 8) THEN add_magf2,aph,Bgse_tpnm[0]
IF (SIZE( phdat,/TYPE) EQ 8) THEN add_scpot,aph,scp_tpn[0]

IF (SIZE(plbdat,/TYPE) EQ 8) THEN add_vsw2,aplb,Vgse_tpnm[0]
IF (SIZE(plbdat,/TYPE) EQ 8) THEN add_magf2,aplb,Bgse_tpnm[0]
IF (SIZE(plbdat,/TYPE) EQ 8) THEN add_scpot,aplb,scp_tpn[0]
IF (SIZE(phbdat,/TYPE) EQ 8) THEN add_vsw2,aphb,Vgse_tpnm[0]
IF (SIZE(phbdat,/TYPE) EQ 8) THEN add_magf2,aphb,Bgse_tpnm[0]
IF (SIZE(phbdat,/TYPE) EQ 8) THEN add_scpot,aphb,scp_tpn[0]

fnm            = file_name_times(tra,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
ftimes         = STRMID(ftimes[*],0L,15L)
tsuffx         = ftimes[0]+'_'+ftimes[1]
fname          = fpref[0]+tsuffx[0]+fsuffx[0]
;;  Print out name as a check
PRINT,';; ',fname[0]

HELP,apl,aplb,aph,aphb
;;  Create IDL save file
SAVE,apl,aph,FILENAME=fname[0]
SAVE,apl,aplb,aph,aphb,FILENAME=fname[0]

;;  Clean up
DELVAR,apl,aplb,aph,aphb,pldat,plbdat,phdat,phbdat
;;----------------------------------------------------------------------------------------
;;  Get thermal [EESA Low] and suprathermal [EESA High]
;;    electron velocity distribution functions (VDFs)
;;
;;    Low   :     ~5-1100  eV electrons
;;    High  :  ~0.14-28.0 keV electrons
;;----------------------------------------------------------------------------------------
fpref          = 'Eesa_3DP_Structures_'
fsuffx         = '_w-Vsw-Ni-SCPot.sav'
eldat          = get_3dp_structs('el' ,TRANGE=tra)      ;;  EESA  Low
elbdat         = get_3dp_structs('elb',TRANGE=tra)      ;;  EESA  Low Burst
ehdat          = get_3dp_structs('eh' ,TRANGE=tra)      ;;  EESA High
ehbdat         = get_3dp_structs('ehb',TRANGE=tra)      ;;  EESA High Burst
IF (SIZE( eldat,/TYPE) EQ 8) THEN ael  =  eldat.DATA
IF (SIZE( ehdat,/TYPE) EQ 8) THEN aeh  =  ehdat.DATA
IF (SIZE(elbdat,/TYPE) EQ 8) THEN aelb = elbdat.DATA
IF (SIZE(ehbdat,/TYPE) EQ 8) THEN aehb = ehbdat.DATA

IF (SIZE( eldat,/TYPE) EQ 8) THEN add_vsw2,ael,Vgse_tpnm[0]
IF (SIZE( eldat,/TYPE) EQ 8) THEN add_magf2,ael,Bgse_tpnm[0]
IF (SIZE( eldat,/TYPE) EQ 8) THEN add_scpot,ael,scp_tpn[0]
IF (SIZE( ehdat,/TYPE) EQ 8) THEN add_vsw2,aeh,Vgse_tpnm[0]
IF (SIZE( ehdat,/TYPE) EQ 8) THEN add_magf2,aeh,Bgse_tpnm[0]
IF (SIZE( ehdat,/TYPE) EQ 8) THEN add_scpot,aeh,scp_tpn[0]

IF (SIZE(elbdat,/TYPE) EQ 8) THEN add_vsw2,aelb,Vgse_tpnm[0]
IF (SIZE(elbdat,/TYPE) EQ 8) THEN add_magf2,aelb,Bgse_tpnm[0]
IF (SIZE(elbdat,/TYPE) EQ 8) THEN add_scpot,aelb,scp_tpn[0]
IF (SIZE(ehbdat,/TYPE) EQ 8) THEN add_vsw2,aehb,Vgse_tpnm[0]
IF (SIZE(ehbdat,/TYPE) EQ 8) THEN add_magf2,aehb,Bgse_tpnm[0]
IF (SIZE(ehbdat,/TYPE) EQ 8) THEN add_scpot,aehb,scp_tpn[0]

fnm            = file_name_times(tra,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
ftimes         = STRMID(ftimes[*],0L,15L)
tsuffx         = ftimes[0]+'_'+ftimes[1]
fname          = fpref[0]+tsuffx[0]+fsuffx[0]
;;  Print out name as a check
PRINT,';; ',fname[0]

HELP,ael,aelb,aeh,aehb
;;  Create IDL save file
SAVE,ael,aeh,FILENAME=fname[0]
SAVE,ael,aelb,aeh,FILENAME=fname[0]
SAVE,ael,aelb,aeh,aehb,FILENAME=fname[0]

;;  Clean up
DELVAR,ael,aelb,aeh,aehb,eldat,elbdat,ehdat,ehbdat
;;----------------------------------------------------------------------------------------
;;  Get solid-state telescope [SST] velocity distribution functions (VDFs)
;;    for electrons [Foil] and protons [Open]
;;
;;    Foil  :   ~20-550 keV electrons
;;    Open  :  ~70-6500 keV protons
;;----------------------------------------------------------------------------------------
fpref          = 'SST-Foil-Open_3DP_Structures_'
fsuffx         = '_w-Vsw-Ni-SCPot.sav'
sfdat          = get_3dp_structs( 'sf' ,TRANGE=tra)      ;;  SST Foil
sodat          = get_3dp_structs( 'so' ,TRANGE=tra)      ;;  SST Foil Burst
sfbdat         = get_3dp_structs('sfb' ,TRANGE=tra)      ;;  SST Open
sobdat         = get_3dp_structs('sob' ,TRANGE=tra)      ;;  SST Open Burst
IF (SIZE( sfdat,/TYPE) EQ 8) THEN asf  =  sfdat.DATA
IF (SIZE( sodat,/TYPE) EQ 8) THEN aso  =  sodat.DATA
IF (SIZE(sfbdat,/TYPE) EQ 8) THEN asfb = sfbdat.DATA
IF (SIZE(sobdat,/TYPE) EQ 8) THEN asob = sobdat.DATA

IF (SIZE( sfdat,/TYPE) EQ 8) THEN add_vsw2,asf,Vgse_tpnm[0]
IF (SIZE( sfdat,/TYPE) EQ 8) THEN add_magf2,asf,Bgse_tpnm[0]
IF (SIZE( sfdat,/TYPE) EQ 8) THEN add_scpot,asf,scp_tpn[0]
IF (SIZE( sodat,/TYPE) EQ 8) THEN add_vsw2,aso,Vgse_tpnm[0]
IF (SIZE( sodat,/TYPE) EQ 8) THEN add_magf2,aso,Bgse_tpnm[0]
IF (SIZE( sodat,/TYPE) EQ 8) THEN add_scpot,aso,scp_tpn[0]

IF (SIZE(sfbdat,/TYPE) EQ 8) THEN add_vsw2,asfb,Vgse_tpnm[0]
IF (SIZE(sfbdat,/TYPE) EQ 8) THEN add_magf2,asfb,Bgse_tpnm[0]
IF (SIZE(sfbdat,/TYPE) EQ 8) THEN add_scpot,asfb,scp_tpn[0]
IF (SIZE(sobdat,/TYPE) EQ 8) THEN add_vsw2,asob,Vgse_tpnm[0]
IF (SIZE(sobdat,/TYPE) EQ 8) THEN add_magf2,asob,Bgse_tpnm[0]
IF (SIZE(sobdat,/TYPE) EQ 8) THEN add_scpot,asob,scp_tpn[0]

fnm            = file_name_times(tra,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
ftimes         = STRMID(ftimes[*],0L,15L)
tsuffx         = ftimes[0]+'_'+ftimes[1]
fname          = fpref[0]+tsuffx[0]+fsuffx[0]
;;  Print out name as a check
PRINT,';; ',fname[0]

HELP,asf,asfb,aso,asob
;;  Create IDL save file
SAVE,asf,aso,FILENAME=fname[0]
SAVE,asf,aso,asfb,asob,FILENAME=fname[0]

;;  Clean up
DELVAR,asf,asfb,aso,asob,sfdat,sfbdat,sodat,sobdat






