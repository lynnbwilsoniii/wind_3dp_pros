;+
;*****************************************************************************************
;
;  CRIBSHEET:   plot_3dp_vdfs_2d_contour_crib.pro
;  PURPOSE  :   This crib sheet demonstrates one way to generate 2D contour plots in
;                 IDL from the Wind 3DP level zero file data.
;
;                 This routine has a lot of notes specifically for new users, so
;                 please read through and enter commands by hand as you go.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               load_3dp_data.pro
;               get_data.pro
;               t_get_struc_unix.pro
;               minmax.pro
;               time_string.pro
;               get_valid_trange.pro
;               lbw_window.pro
;               tplot.pro
;               store_data.pro
;               tnames.pro
;               options.pro
;               find_strahl_direction.pro
;               wind_orbit_to_tplot.pro
;               tplot_options.pro
;               waves_tnr_rad_to_tplot.pro
;               read_shocks_jck_database_new.pro
;               pesa_low_moment_calibrate.pro
;               wind_h1_swe_to_tplot.pro
;               lbw_tplot_set_defaults.pro
;               get_3dp_structs.pro
;               add_vsw2.pro
;               add_magf2.pro
;               add_scpot.pro
;               conv_units.pro
;               conv_vdfidlstr_2_f_vs_vxyz_thm_wi.pro
;               general_vdf_contour_plot.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  The following data:
;                     Wind/3DP level zero files
;                     Wind/MFI H0 CDF files
;                     Wind orbit ASCII files
;                     Wind WAVES ASCII files
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Follow notes in crib and enter each line by hand in the command line
;
;  REFERENCES:  
;               0)  Harten, R. and K. Clark (1995), "The Design Features of the GGS
;                      Wind and Polar Spacecraft," Space Sci. Rev. Vol. 71, pp. 23-40.
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
;              10)  Lepping et al., (1995), "The Wind Magnetic Field Investigation,"
;                      Space Sci. Rev. Vol. 71, pp. 207-229.
;              11)  K.W. Ogilvie et al., "SWE, A Comprehensive Plasma Instrument for the
;                     Wind Spacecraft," Space Science Reviews Vol. 71, pp. 55-77,
;                     doi:10.1007/BF00751326, 1995.
;              12)  J.C. Kasper et al., "Physics-based tests to identify the accuracy of
;                     solar wind ion measurements:  A case study with the Wind
;                     Faraday Cups," Journal of Geophysical Research Vol. 111,
;                     pp. A03105, doi:10.1029/2005JA011442, 2006.
;              13)  B.A. Maruca and J.C. Kasper "Improved interpretation of solar wind
;                     ion measurements via high-resolution magnetic field data,"
;                     Advances in Space Research Vol. 52, pp. 723-731,
;                     doi:10.1016/j.asr.2013.04.006, 2013.
;
;   CREATED:  02/05/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/05/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;----------------------------------------------------------------------------------------
;;  IDL system and OS stuff
;;----------------------------------------------------------------------------------------
vers           = !VERSION.OS_FAMILY   ;;  e.g., 'unix'
vern           = !VERSION.RELEASE     ;;  e.g., '7.1.1'
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;  Electromagnetic
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;;  Atomic
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
ma_eV          = ma[0]*c[0]^2/qq[0]       ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
me_eV          = me[0]*c[0]^2/qq[0]       ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mn_eV          = mn[0]*c[0]^2/qq[0]       ;;  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c[0]^2/qq[0]       ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;  Astronomical
R_S___m        = 6.9600000d08             ;;  Sun's Mean Equatorial Radius [m, 2015 AA values]
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
M_E            = 5.9722000d24             ;;  Earth's mass [kg, 2015 AA values]
M_S__kg        = 1.9884000d30             ;;  Sun's mass [kg, 2015 AA values]
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km
;;----------------------------------------------------------------------------------------
;;  Conversion Factors
;;----------------------------------------------------------------------------------------
;;  Energy and Temperature
f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]          ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]          ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
;;----------------------------------------------------------------------------------------
;;  Coordinates and vectors
;;----------------------------------------------------------------------------------------
;;  Define some coordinate strings
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_fac      = 'fac'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
vec_str        = ['x','y','z']
tensor_str     = ['x'+vec_str,'y'+vec_str[1:2],'zz']
fac_vec_str    = ['perp1','perp2','para']
fac_dir_str    = ['para','perp','anti']
vec_col        = [250,150, 50]
;;----------------------------------------------------------------------------------------
;;  Define some general variables
;;----------------------------------------------------------------------------------------
start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'

def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}

sc             = 'Wind'
scpref         = sc[0]+'_'
;;----------------------------------------------------------------------------------------
;;  Define date strings
;;----------------------------------------------------------------------------------------
;;  Define date of interest:  YYYY-MM-DD
date           = '121097'
tdate          = '1997-12-10'
;;----------------------------------------------------------------------------------------
;;  Load 3DP data
;;    -->  The following loads data from the level zero files found at:
;;           http://sprg.ssl.berkeley.edu/wind3dp/data/wi/3dp/lz/
;;    -->  load_3dp_data.pro assumes you have moved the level zero files to the
;;         following directory:
;;           ~/wind_3dp_pros/wind_data_dir/data1/wind/3dp/lz/YYYY/
;;    -->  load_3dp_data.pro requires the use of a shared object library, which are
;;           found in the ./wind_3dp_pros/WIND_PRO/ directory and are both operating
;;           system- (OS) and memory size-dependent (i.e., *_64.so files allow the use
;;           of 64 bit IDL, whereas others require 32 bit IDL)
;;    -->  Old missions like Wind used a packetization method for transmitting data
;;           from the spacecraft to the ground.  These were called major and minor
;;           frames and each had a set number of bits with specific bits corresponding
;;           to a known checksum error handler.  Wind also suffers from lower (i.e.,
;;           compared to current standards) telemetry rates and only one ~2 hour pass
;;           per day.  As a consequence, data from day X may not reach the ground until
;;           a few days later on day Y.  Thus, when looking for data measured on day X
;;           it is wise to load data from several days after to ensure all data from
;;           day X is found.  This is why the duration is much longer than 24 hours.
;;----------------------------------------------------------------------------------------
;;  Define a start date and time
start_t        = tdate[0]+'/'+start_of_day[0]
;;  Define a duration of time to load [hours]
dur            = 200.
;;  Define the memory size to limit to [mostly for older systems]
memsz          = 200.
;;  Define the packet quality [2 allows "invalid" distributions through]
qual           = 2
;;  Load the level zero data files and store in pointer memory
load_3dp_data,start_t[0],dur[0],QUALITY=qual[0],MEMSIZE=memsz[0]
;;  This routine mostly opens the level zero files for access by other routines to
;;    call later (see below).  It does, however, call load_wi_h0_mfi.pro which finds
;;    and loads Wind MFI CDF files into TPLOT.
;;----------------------------------------------------------------------------------------
;;  TPLOT Overview
;;----------------------------------------------------------------------------------------
;;    TPLOT variable   = A time series of data stored as a pointer heap variable to be
;;                         dynamically retrieved, manipulated, and/or plotted.
;;
;;    TPLOT handle     = A string and integer value associated with each TPLOT variable.
;;                         This is the identifier used to retrieve, manipulate, and/or
;;                         plot the data.
;;
;;    TPLOT structures = All TPLOT IDL structures have the same basic format with the
;;                         following required tags:
;;                           X    :  {N}-Element [double] array of Unix times
;;                           Y    :  {N[,E,A]}-Element [float/double] array of data
;;                       If the data is a spectrogram-like plot or has more than just one
;;                         dimension, then the following extra tags are required:
;;                           V    :  {N,E}-Element [float/double] array of Y-Axis values
;;                                     [if included, then Y data corresponds to Z-Axis
;;                                      (usually associated with a color bar)]
;;                           SPEC :  Scalar [integer/long/float/double] defining whether
;;                                     to plot data as a color-scale spectrogram (= 1)
;;                                     or as a stacked line plot (= 0), where each line
;;                                     corresponds to a given value in V
;;                       In the most complicated form, there are two additional tags but
;;                         when these are defined, then V is not.  This almost always
;;                         corresponds to data that contains both energy and pitch-angle
;;                         bins.  So in the case of particle spectra, we have:
;;                           V1   :  {N,E}-Element [float/double] array of energy bin
;;                                     values
;;                           V2   :  {N,A}-Element [float/double] array of pitch-angle
;;                                     bin values
;;
;;                       Note that MMS uses an additional structure tag for particle
;;                         data, V3, which may cause problems in some of my older
;;                         routines.  This is why I suggest you be careful with file
;;                         paths and avoid to much overlap with SPEDAS.
;;
;;  Do not worry too much about these details, as TPLOT should handle this for you.  You
;;    need only make sure that your structures have the correct format and that you store
;;    the data correctly.  Again, the example routine above does all of this for you, so
;;    you need not worry too much about the details.
;;
;;----------------------------------------------------------------------------------------
;;  Determine time range of loaded data
;;----------------------------------------------------------------------------------------
;;  Define the default TPLOT handle used by load_wi_h0_mfi.pro
def_wibmag_tpn = 'wi_B3_MAG(GSE)'
def_wibgse_tpn = 'wi_B3(GSE)'
;;  Get data
get_data,def_wibmag_tpn[0],DATA=temp
;;  Determine Unix times associated with data
unix           = t_get_struc_unix(temp)
trange         = minmax(unix,/POS)                             ;;  Define Unix time range of data
tr_00          = time_string(trange,PREC=3)                    ;;  Convert to string:  'YYYY-MM-DD/hh:mm:ss.xxx'
test           = get_valid_trange(TRANGE=trange,PRECISION=6)   ;;  Make sure format is valid
t              = test.STRING_TRANGE     ;;  [2]-element array [e.g., '1996-04-03/00:00:00']
tra            = test.UNIX_TRANGE       ;;  Unix times
tdates         = test.DATE_TRANGE       ;;  [e.g., '1996-04-03']
;;  Limit to one day
td_se          = [1,1]*tra[0] + [0,1]*864d2
tr_se          = time_string(td_se,PREC=3)
;;----------------------------------------------------------------------------------------
;;  Open window and plot MFI data
;;----------------------------------------------------------------------------------------
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*7d-1
win_ttl        = 'Wind Plots ['+tdates[0]+' to '+tdates[1]+']'
win_str        = {RETAIN:2,XSIZE:wsz[0],YSIZE:wsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
lbw_window,WIND_N=0,_EXTRA=win_str
;;  Plot MFI data
tplot,[def_wibmag_tpn[0],def_wibgse_tpn[0]],TRANGE=td_se
;;----------------------------------------------------------------------------------------
;;  Rename MFI TPLOT handles from default
;;----------------------------------------------------------------------------------------
;;  Get |Bo|
get_data,def_wibmag_tpn[0],DATA=temp_bo,DLIMIT=dlim_bo,LIMIT=lim_bo
;;  Get Bo
get_data,def_wibgse_tpn[0],DATA=temp_bb,DLIMIT=dlim_bb,LIMIT=lim_bb
;;  Define new TPLOT handles
new_wibmag_tpn = scpref[0]+'magf_3s_'+coord_mag[0]
new_wibgse_tpn = scpref[0]+'magf_3s_'+coord_gse[0]
;;  Store new TPLOT variables and remove old
store_data,DELETE=tnames()
store_data,new_wibmag_tpn[0],DATA=temp_bo,DLIMIT=dlim_bo,LIMIT=lim_bo
store_data,new_wibgse_tpn[0],DATA=temp_bb,DLIMIT=dlim_bb,LIMIT=lim_bb
;;  Replot
tplot,[new_wibmag_tpn[0],new_wibgse_tpn[0]],TRANGE=td_se
;;----------------------------------------------------------------------------------------
;;  Alter TPLOT options
;;
;;  The options.pro routine is used to alter plotting options for TPLOT variables.  It
;;    is a tremendously powerful routine.  For instance, if one wished to alter the
;;    Y-axis title, they could do so in two ways:
;;
;;      IDL> options,'[insert TPLOT handle]','YTITLE','New Y-axis title'
;;
;;    or
;;
;;      IDL> options,'[insert TPLOT handle]',YTITLE='New Y-axis title'
;;
;;    The options routine also allows the user to define values as the priority vs.
;;    default using the /DEFAULT keyword.  These are stored in two different structures
;;    associated with each TPLOT variable and can be retrieved using the DLIMIT and
;;    LIMIT keywords of store_data.pro (e.g., see example above).  So the above two
;;    examples would define the priority Y-Axis title, not the default, and would be
;;    returned in the LIMIT structure.  If the user defined the YTITLE structure tag
;;    for the DLIMIT structure and the same tag existed in the LIMIT structure, the
;;    value in the LIMIT structure would be shown.
;;
;;    Note that in the above examples I used a completely meaningless and useless
;;    string for the TPLOT handle.  I did so as a generic way to illustrate that the
;;    user will have their own TPLOT handles and that they should use the handle
;;    associated with the variable they wish to alter.  Do NOT copy the above examples
;;    verbatim as that will result in an error message.
;;----------------------------------------------------------------------------------------
;;  Erase old YTITLEs
options,[new_wibmag_tpn[0],new_wibgse_tpn[0]],'YTITLE'
options,[new_wibmag_tpn[0],new_wibgse_tpn[0]],'YTITLE',/DEF
;;  Define new
options,new_wibmag_tpn[0],YTITLE='|Bo| [nT]',/DEF
options,new_wibgse_tpn[0],YTITLE='Bo [nT,'+coord_gseu[0]+']',/DEF
;;----------------------------------------------------------------------------------------
;;  Find strahl direction
;;----------------------------------------------------------------------------------------
;;  Define params
magf_t         = t_get_struc_unix(temp)
toff           = MIN(magf_t,/NAN)
tsec           = magf_t - toff[0]
magf_v         = temp.Y
nt             = N_ELEMENTS(magf_t)
dumb           = REPLICATE(f,nt[0],2L)
;;  Call strahl finding routine
strahl_dir     = find_strahl_direction(magf_v)
good_para      = WHERE(FINITE(strahl_dir) AND strahl_dir EQ 1,gd_para)
good_perp      = WHERE(FINITE(strahl_dir) AND strahl_dir EQ -1,gd_perp)
IF (gd_para[0] GT 0) THEN dumb[good_para,0] = 1e0
IF (gd_perp[0] GT 0) THEN dumb[good_perp,1] = -1e0
;;  Define a dummy TPLOT structure
struc          = {X:tsec,Y:dumb,TSHIFT:toff[0]}
tpn            = 'solar_strahl_dir'
;;  Send to TPLOT
store_data,tpn[0],DATA=struc,DLIMIT=def_dlim,LIMIT=def__lim
;;  Define YTITLEs, YRANGE, etc.
options,tpn[0],YTITLE='Strahl Dir.',YRANGE=[-1,1]*1.5,YSUBTITLE='[Para/Anti]',$
               COLORS=vec_col[[0,2]],LABELS=fac_dir_str[[0,2]],/DEF
;;  Remove any pre-existing options in the LIMIT structure
options,tpn[0],'YTITLE' & options,tpn[0],'YRANGE' & options,tpn[0],'YSUBTITLE'
options,tpn[0],'COLORS' & options,tpn[0],'LABELS'
;;----------------------------------------------------------------------------------------
;;  Load orbit data  [***  Optional  ***]
;;----------------------------------------------------------------------------------------
wind_orbit_to_tplot,BNAME=new_wibgse_tpn[0],TRANGE=tra
;;  Change Y-Axis titles
options,'Wind_Radial_Distance','YTITLE','Radial Dist. (R!DE!N)'
options,'Wind_GSE_Latitude','YTITLE','GSE Lat. [deg]'
options,'Wind_GSE_Longitude','YTITLE','GSE Lon. [deg]'
;;  Add these variables as tick mark labels
gnames         = ['Wind_Radial_Distance','Wind_GSE_Latitude','Wind_GSE_Longitude','Wind_MLT']
tplot_options,VAR_LABEL=gnames
;;  Update plot
tplot
;;----------------------------------------------------------------------------------------
;;  Load WAVES radio data  [***  Optional  ***]
;;----------------------------------------------------------------------------------------
fl             = 4.
fh             = 13e3
yscl           = 'log'
waves_tnr_rad_to_tplot,DATE=date,FLOW=fl[0],FHIGH=fh[0],YSCL=yscl[0],TRANGE=tra
;;  ***  Ranges will change for different dates  ***
tpn_radio      = tnames(['RAD2_','RAD1_','TNR_']+'*')
zran_rad       = [1e0,1e2]
zran_tnr       = [1e0,1e2]
options,tpn_radio,'ZRANGE'
options,tpn_radio[0:1],ZRANGE=zran_rad,/DEF
options,tpn_radio[2],ZRANGE=zran_tnr,/DEF
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
;;  Return results only using the CfA method listed on each page
test_bst       = read_shocks_jck_database_new(/CFA_METH_ONLY,GIND_3D=gind_3d_bst)
;;  Define internal structures
gen_info_str   = test_bst.GEN_INFO
asy_info_str   = test_bst.ASY_INFO
bvn_info_str   = test_bst.BVN_INFO
key_info_str   = test_bst.KEY_INFO
ups_info_str   = test_bst.UPS_INFO
dns_info_str   = test_bst.DNS_INFO
;;  Define general info
tdates_bst     = gen_info_str.TDATES                  ;;  Dates of events ['YYYY-MM-DD']
rhmeth_bst     = gen_info_str.RH_METHOD               ;;  Defines method used to determine shock normal
unix_ra        = gen_info_str.ARRT_UNIX.Y             ;;  Unix times at center of ramps
;;  Define Key Shock Analysis parameters
thetbn_up      = key_info_str.THETA_BN.Y              ;;  Avg. upstream shock normal angle [deg]
vshn___up      = ABS(key_info_str.VSHN_UP.Y)          ;;  " " shock normal speed [SCF, km/s]
N2_N1__up      = ABS(key_info_str.NIDN_NIUP.Y)        ;;  Shock compression ratio [unitless]
nsh____up      = bvn_info_str.SH_N_GSE.Y              ;;  Shock normal unit vectors [GSE, unitless]
;;  Determine which shock to use
gshock         = WHERE(tdates_bst EQ tdate[0],gsh)
PRINT,';; ',gsh[0]

;;  Some dates have two shocks per date, so choose which one to use
;;    [see two commented examples below]
IF (SIZE(kk,/TYPE) EQ 0) THEN kk = 0
IF (gsh[0] GT 0) THEN gcomp = N2_N1__up[gshock[kk]]
IF (gsh[0] GT 0) THEN tura  = unix_ra[gshock[kk]]  
IF (gsh[0] GT 0) THEN gthbn = thetbn_up[gshock[kk]]
IF (gsh[0] GT 0) THEN gnorm = REFORM(nsh____up[gshock[kk],*]) ELSE gnorm = REPLICATE(f,3)
;;----------------------------------------------------------------------------------------
;;  Load ion moments
;;----------------------------------------------------------------------------------------
;;  The following routine loads ion velocity moments calculated on the ground and
;;    performs a kludgy calibration of the density and spacecraft potential in the
;;    downstream of the interplanetary shock for this specific date.  The example date
;;    used in the original version of this file has a quasi-perpendicular shock at
;;    04:33:14.664 UTC.  If the user changes the above date there may not be an
;;    associated shock and the following routine will not produce the modified density
;;    or spacecraft potential.  It should run without breaking but there will be
;;    two fewer TPLOT handles.
pesa_low_moment_calibrate,DATE=date,TRANGE=td_se,BNAME=new_wibgse_tpn[0],$
                          COMPRESS=gcomp,MIDRA=tura
;;----------------------------------------------------------------------------------------
;;  Load SWE ion moments
;;----------------------------------------------------------------------------------------
wind_h1_swe_to_tplot,TRANGE=td_se,/COMBINE_PA,/NO_SWE_B
;;----------------------------------------------------------------------------------------
;;  Set some of my preferred defaults for TPLOT
;;----------------------------------------------------------------------------------------
lbw_tplot_set_defaults              ;;  Load some of my personal defaults
tplot_options,'XMARGIN',[ 20, 15]
tplot_options,'YMARGIN',[ 5, 5]
;;----------------------------------------------------------------------------------------
;;  Get thermal [PESA Low] and suprathermal [PESA High]
;;    ion velocity distribution functions (VDFs)
;;
;;    Low   :  ~0.1-10.0 keV ions
;;    High  :  ~0.5-28.0 keV ions
;;----------------------------------------------------------------------------------------
pldat          = get_3dp_structs('pl' ,TRANGE=td_se)      ;;  PESA  Low
plbdat         = get_3dp_structs('plb',TRANGE=td_se)      ;;  PESA  Low Burst
phdat          = get_3dp_structs('ph' ,TRANGE=td_se)      ;;  PESA High
phbdat         = get_3dp_structs('phb',TRANGE=td_se)      ;;  PESA High Burst
IF (SIZE( pldat,/TYPE) EQ 8) THEN apl_ =  pldat.DATA ELSE apl_ = 0
IF (SIZE( phdat,/TYPE) EQ 8) THEN aph_ =  phdat.DATA ELSE aph_ = 0
IF (SIZE(plbdat,/TYPE) EQ 8) THEN aplb = plbdat.DATA ELSE aplb = 0
IF (SIZE(phbdat,/TYPE) EQ 8) THEN aphb = phbdat.DATA ELSE aphb = 0
;;----------------------------------------------------------------------------------------
;;  Get thermal [EESA Low] and suprathermal [EESA High]
;;    electron velocity distribution functions (VDFs)
;;
;;    Low   :     ~5-1100  eV electrons
;;    High  :  ~0.14-28.0 keV electrons
;;----------------------------------------------------------------------------------------
eldat          = get_3dp_structs('el' ,TRANGE=td_se)      ;;  EESA  Low
elbdat         = get_3dp_structs('elb',TRANGE=td_se)      ;;  EESA  Low Burst
ehdat          = get_3dp_structs('eh' ,TRANGE=td_se)      ;;  EESA High
ehbdat         = get_3dp_structs('ehb',TRANGE=td_se)      ;;  EESA High Burst
IF (SIZE( eldat,/TYPE) EQ 8) THEN ael_ =  eldat.DATA ELSE ael_ = 0
IF (SIZE( ehdat,/TYPE) EQ 8) THEN aeh_ =  ehdat.DATA ELSE aeh_ = 0
IF (SIZE(elbdat,/TYPE) EQ 8) THEN aelb = elbdat.DATA ELSE aelb = 0
IF (SIZE(ehbdat,/TYPE) EQ 8) THEN aehb = ehbdat.DATA ELSE aehb = 0
;;----------------------------------------------------------------------------------------
;;  Get solid-state telescope [SST] velocity distribution functions (VDFs)
;;    for electrons [Foil] and protons [Open]
;;
;;    Foil  :   ~20-550 keV electrons
;;    Open  :  ~70-6500 keV protons
;;----------------------------------------------------------------------------------------
sfdat          = get_3dp_structs( 'sf' ,TRANGE=td_se)      ;;  SST Foil
sodat          = get_3dp_structs( 'so' ,TRANGE=td_se)      ;;  SST Foil Burst
sfbdat         = get_3dp_structs('sfb' ,TRANGE=td_se)      ;;  SST Open
sobdat         = get_3dp_structs('sob' ,TRANGE=td_se)      ;;  SST Open Burst
IF (SIZE( sfdat,/TYPE) EQ 8) THEN asf_ =  sfdat.DATA ELSE asf_ = 0
IF (SIZE( sodat,/TYPE) EQ 8) THEN aso_ =  sodat.DATA ELSE aso_ = 0
IF (SIZE(sfbdat,/TYPE) EQ 8) THEN asfb = sfbdat.DATA ELSE asfb = 0
IF (SIZE(sobdat,/TYPE) EQ 8) THEN asob = sobdat.DATA ELSE asob = 0
;;----------------------------------------------------------------------------------------
;;  Define number of structures and add VSW, MAGF, and SC_POT values
;;----------------------------------------------------------------------------------------
;;  Define some TPLOT handles for later use
Vgse_tpnm      = 'V_sw2'             ;;  TPLOT handle associated with Vsw [GSE, km/s]
Bgse_tpnm      = new_wibgse_tpn[0]   ;;  TPLOT handle associated with Bo [GSE, nT]
;;  Determine which TPLOT handle to use for estimate of spacecraft potential [eV]
IF (tnames('sc_pot_3') EQ '') THEN scp_tpn = 'sc_pot_2' ELSE scp_tpn = 'sc_pot_3'
;;  Define number of structures
IF (SIZE(apl_,/TYPE) EQ 8) THEN n_pl_ = N_ELEMENTS(apl_) ELSE n_pl_ = 0L
IF (SIZE(aph_,/TYPE) EQ 8) THEN n_plb = N_ELEMENTS(aph_) ELSE n_plb = 0L
IF (SIZE(aplb,/TYPE) EQ 8) THEN n_ph_ = N_ELEMENTS(aplb) ELSE n_ph_ = 0L
IF (SIZE(aphb,/TYPE) EQ 8) THEN n_phb = N_ELEMENTS(aphb) ELSE n_phb = 0L
IF (SIZE(ael_,/TYPE) EQ 8) THEN n_el_ = N_ELEMENTS(ael_) ELSE n_el_ = 0L
IF (SIZE(aeh_,/TYPE) EQ 8) THEN n_elb = N_ELEMENTS(aeh_) ELSE n_elb = 0L
IF (SIZE(aelb,/TYPE) EQ 8) THEN n_eh_ = N_ELEMENTS(aelb) ELSE n_eh_ = 0L
IF (SIZE(aehb,/TYPE) EQ 8) THEN n_ehb = N_ELEMENTS(aehb) ELSE n_ehb = 0L
IF (SIZE(asf_,/TYPE) EQ 8) THEN n_sf_ = N_ELEMENTS(asf_) ELSE n_sf_ = 0L
IF (SIZE(aso_,/TYPE) EQ 8) THEN n_sfb = N_ELEMENTS(aso_) ELSE n_sfb = 0L
IF (SIZE(asfb,/TYPE) EQ 8) THEN n_so_ = N_ELEMENTS(asfb) ELSE n_so_ = 0L
IF (SIZE(asob,/TYPE) EQ 8) THEN n_sob = N_ELEMENTS(asob) ELSE n_sob = 0L
;;  Clean up
DELVAR,pldat,plbdat,phdat,phbdat,eldat,elbdat,ehdat,ehbdat,sfdat,sfbdat,sodat,sobdat
;;  Sort by time (just in case)
IF (n_pl_[0] GT 0) THEN sp_pl_ = SORT(apl_.TIME )
IF (n_plb[0] GT 0) THEN sp_plb = SORT(aplb.TIME)
IF (n_ph_[0] GT 0) THEN sp_ph_ = SORT(aph_.TIME )
IF (n_phb[0] GT 0) THEN sp_phb = SORT(aphb.TIME)
IF (n_el_[0] GT 0) THEN sp_el_ = SORT(ael_.TIME )
IF (n_elb[0] GT 0) THEN sp_elb = SORT(aelb.TIME)
IF (n_eh_[0] GT 0) THEN sp_eh_ = SORT(aeh_.TIME )
IF (n_ehb[0] GT 0) THEN sp_ehb = SORT(aehb.TIME)
IF (n_sf_[0] GT 0) THEN sp_sf_ = SORT(asf_.TIME )
IF (n_sfb[0] GT 0) THEN sp_sfb = SORT(asfb.TIME)
IF (n_so_[0] GT 0) THEN sp_so_ = SORT(aso_.TIME )
IF (n_sob[0] GT 0) THEN sp_sob = SORT(asob.TIME)

IF (n_pl_[0] GT 0) THEN apl_ = TEMPORARY(apl_[sp_pl_])
IF (n_plb[0] GT 0) THEN aplb = TEMPORARY(aplb[sp_plb])
IF (n_ph_[0] GT 0) THEN aph_ = TEMPORARY(aph_[sp_ph_])
IF (n_phb[0] GT 0) THEN aphb = TEMPORARY(aphb[sp_phb])
IF (n_el_[0] GT 0) THEN ael_ = TEMPORARY(ael_[sp_el_])
IF (n_elb[0] GT 0) THEN aelb = TEMPORARY(aelb[sp_elb])
IF (n_eh_[0] GT 0) THEN aeh_ = TEMPORARY(aeh_[sp_eh_])
IF (n_ehb[0] GT 0) THEN aehb = TEMPORARY(aehb[sp_ehb])
IF (n_sf_[0] GT 0) THEN asf_ = TEMPORARY(asf_[sp_sf_])
IF (n_sfb[0] GT 0) THEN asfb = TEMPORARY(asfb[sp_sfb])
IF (n_so_[0] GT 0) THEN aso_ = TEMPORARY(aso_[sp_so_])
IF (n_sob[0] GT 0) THEN asob = TEMPORARY(asob[sp_sob])
;;  Add bulk flow velocity [km/s] to structures
IF (n_pl_[0] GT 0) THEN add_vsw2,apl_,Vgse_tpnm[0],/LEAVE_ALONE
IF (n_plb[0] GT 0) THEN add_vsw2,aplb,Vgse_tpnm[0],/LEAVE_ALONE
IF (n_ph_[0] GT 0) THEN add_vsw2,aph_,Vgse_tpnm[0],/LEAVE_ALONE
IF (n_phb[0] GT 0) THEN add_vsw2,aphb,Vgse_tpnm[0],/LEAVE_ALONE
IF (n_el_[0] GT 0) THEN add_vsw2,ael_,Vgse_tpnm[0],/LEAVE_ALONE
IF (n_elb[0] GT 0) THEN add_vsw2,aelb,Vgse_tpnm[0],/LEAVE_ALONE
IF (n_eh_[0] GT 0) THEN add_vsw2,aeh_,Vgse_tpnm[0],/LEAVE_ALONE
IF (n_ehb[0] GT 0) THEN add_vsw2,aehb,Vgse_tpnm[0],/LEAVE_ALONE
IF (n_sf_[0] GT 0) THEN add_vsw2,asf_,Vgse_tpnm[0],/LEAVE_ALONE
IF (n_sfb[0] GT 0) THEN add_vsw2,asfb,Vgse_tpnm[0],/LEAVE_ALONE
IF (n_so_[0] GT 0) THEN add_vsw2,aso_,Vgse_tpnm[0],/LEAVE_ALONE
IF (n_sob[0] GT 0) THEN add_vsw2,asob,Vgse_tpnm[0],/LEAVE_ALONE
;;  Add quasi-static magnetic field [nT] to structures
IF (n_pl_[0] GT 0) THEN add_magf2,apl_,Bgse_tpnm[0],/LEAVE_ALONE
IF (n_plb[0] GT 0) THEN add_magf2,aplb,Bgse_tpnm[0],/LEAVE_ALONE
IF (n_ph_[0] GT 0) THEN add_magf2,aph_,Bgse_tpnm[0],/LEAVE_ALONE
IF (n_phb[0] GT 0) THEN add_magf2,aphb,Bgse_tpnm[0],/LEAVE_ALONE
IF (n_el_[0] GT 0) THEN add_magf2,ael_,Bgse_tpnm[0],/LEAVE_ALONE
IF (n_elb[0] GT 0) THEN add_magf2,aelb,Bgse_tpnm[0],/LEAVE_ALONE
IF (n_eh_[0] GT 0) THEN add_magf2,aeh_,Bgse_tpnm[0],/LEAVE_ALONE
IF (n_ehb[0] GT 0) THEN add_magf2,aehb,Bgse_tpnm[0],/LEAVE_ALONE
IF (n_sf_[0] GT 0) THEN add_magf2,asf_,Bgse_tpnm[0],/LEAVE_ALONE
IF (n_sfb[0] GT 0) THEN add_magf2,asfb,Bgse_tpnm[0],/LEAVE_ALONE
IF (n_so_[0] GT 0) THEN add_magf2,aso_,Bgse_tpnm[0],/LEAVE_ALONE
IF (n_sob[0] GT 0) THEN add_magf2,asob,Bgse_tpnm[0],/LEAVE_ALONE
;;  Add spacecraft potential [eV] to structures
IF (n_pl_[0] GT 0) THEN add_scpot,apl_,scp_tpn[0],/LEAVE_ALONE
IF (n_plb[0] GT 0) THEN add_scpot,aplb,scp_tpn[0],/LEAVE_ALONE
IF (n_ph_[0] GT 0) THEN add_scpot,aph_,scp_tpn[0],/LEAVE_ALONE
IF (n_phb[0] GT 0) THEN add_scpot,aphb,scp_tpn[0],/LEAVE_ALONE
IF (n_el_[0] GT 0) THEN add_scpot,ael_,scp_tpn[0],/LEAVE_ALONE
IF (n_elb[0] GT 0) THEN add_scpot,aelb,scp_tpn[0],/LEAVE_ALONE
IF (n_eh_[0] GT 0) THEN add_scpot,aeh_,scp_tpn[0],/LEAVE_ALONE
IF (n_ehb[0] GT 0) THEN add_scpot,aehb,scp_tpn[0],/LEAVE_ALONE
IF (n_sf_[0] GT 0) THEN add_scpot,asf_,scp_tpn[0],/LEAVE_ALONE
IF (n_sfb[0] GT 0) THEN add_scpot,asfb,scp_tpn[0],/LEAVE_ALONE
IF (n_so_[0] GT 0) THEN add_scpot,aso_,scp_tpn[0],/LEAVE_ALONE
IF (n_sob[0] GT 0) THEN add_scpot,asob,scp_tpn[0],/LEAVE_ALONE
;;----------------------------------------------------------------------------------------
;;  Open window and plot VDF data
;;----------------------------------------------------------------------------------------
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = MIN(s_size*7d-1)
win_ttl        = 'Wind 3DP Plots'
win_str        = {RETAIN:2,XSIZE:wsz[0],YSIZE:LONG(wsz[0]*1.375d0),TITLE:win_ttl[0],XPOS:10,YPOS:10}
lbw_window,WIND_N=1,_EXTRA=win_str
;;----------------------------------------------------------------------------------------
;;  Define VDF and plot
;;----------------------------------------------------------------------------------------
jj             = 10L
x_inds         = [0L,2L,1L]
y_inds         = [1L,0L,2L]
dumb_exv       = {VEC:REPLICATE(0e0,3L),NAME:''}

dat0           = aplb[jj]       ;;  PESA Low Burst
datc           = dat0[0]
datc.DATA      = 1e0            ;;  Create a one-count copy
;;  Convert to phase space density [# cm^(-3) km^(-3) s^(+3)]
dat_df         = conv_units(dat0,'df')
dat_1c         = conv_units(datc,'df')
;;  Convert F(energy,theta,phi) to F(Vx,Vy,Vz)
dat_fvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_df)
dat_1cxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_1c)
;;  Define EX_VECS stuff
ex_vecs        = REPLICATE(dumb_exv[0],4L)
ex_vecs[0]     = {VEC:FLOAT(dat_df[0].VSW),NAME:'Vsw'}
ex_vecs[1]     = {VEC:FLOAT(dat_df[0].MAGF),NAME:'Bo'}
ex_vecs[2]     = {VEC:FLOAT(gnorm),NAME:'nsh'}
ex_vecs[3]     = {VEC:[1e0,0e0,0e0],NAME:'Sun'}
;;  Define EX_INFO stuff
ex_info        = {SCPOT:dat_df[0].SC_POT,VSW:dat_df[0].VSW,MAGF:dat_df[0].MAGF}
plane          = 'xy'             ;;  Y vs. X plane
IF (plane[0] EQ 'xy') THEN k = 0L ELSE   $
  IF (plane[0] EQ 'xz') THEN k = 1L ELSE $
  IF (plane[0] EQ 'yz') THEN k = 2L
xyind          = [x_inds[k],y_inds[k]]
vframe         = [0d0,0d0,0d0]    ;;  Transformation velocity [km/s]
vec1           = [1d0,0d0,0d0]    ;;  V1
vec2           = [0d0,1d0,0d0]    ;;  V2
xname          = 'Xgse'           ;;  Name of V1
yname          = 'Ygse'           ;;  Name of V2
nlev           = 30L              ;;  # of contour levels to show
sm_cuts        = 0b               ;;  Do not smooth cuts
sm_cont        = 0b               ;;  Do not smooth contours
dfra_aplb      = [1e-9,5e-5]      ;;  Default VDF range for PESA Low Burst
vlim_aplb      = 75e1             ;;  Default velocity range for PESA Low Burst
vxy_offs       = [ex_info.VSW[xyind[0:1]]]
ptitle         = 'PESA Low Burst [SCF]'
;;  Define data
data_1d        = dat_fvxyz.VDF
vels_1d        = dat_fvxyz.VELXYZ
onec_1d        = dat_1cxyz.VDF
;;  Plot 2D contour in spacecraft frame of reference (SCF), in GSE coordinate basis
WSET,1
WSHOW,1
general_vdf_contour_plot,data_1d,vels_1d,VFRAME=vframe,VEC1=vec1,VEC2=vec2,VLIM=vlim_aplb[0],$
                         PLANE=plane[0],NLEV=nlev,SM_CUTS=sm_cuts,SM_CONT=sm_cont,           $
                         XNAME=xname,YNAME=yname,DFRA=dfra_aplb,EX_VECS=ex_vecs,             $
                         EX_INFO=ex_info,V_0X=vxy_offs[0],V_0Y=vxy_offs[1],/SLICE2D,         $
                         ONE_C=onec_1d,P_TITLE=ptitle














