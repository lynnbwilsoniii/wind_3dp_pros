;+
;*****************************************************************************************
;
;  PROCEDURE:   wrapper_vbulk_change____mms.pro
;  PURPOSE  :   This is a wrapping routine for the Vbulk Change IDL Libraries that takes
;                 an array of particle velocity distribution functions (VDFs) from
;                 only MMS FPI experiments.  These routines allow a user to dynamically
;                 and interactively change the reference frame used for plotting contour
;                 plots in a user-defined coordinate basis.
;
;                 This routine is a copy of wrapper_vbulk_change_thm_wi.pro but modified
;                 for MMS FPI IDL structures.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               test_file_path_format.pro
;               num2int_str.pro
;               lbw_test_mms_fpi_vdf_structure.pro
;               time_string.pro
;               file_name_times.pro
;               lbw_mms_energy_angle_to_velocity_array.pro
;               is_a_number.pro
;               delete_variable.pro
;               struct_value.pro
;               structure_compare.pro
;               is_a_3_vector.pro
;               lbw_window.pro
;               vbulk_change_test_windn.pro
;               general_prompt_routine.pro
;               vbulk_change_print_index_time.pro
;               vbulk_change_keywords_init.pro
;               str_element.pro
;               vbulk_change_vdf_plot_wrapper.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Vbulk Change IDL Libraries
;
;  INPUT:
;               DATA       :  [N]-Element [structure] array of particle velocity
;                               distribution functions (VDFs) from only the MMS FPI
;                               instruments.  Regardless, the structures must satisfy the
;                               criteria needed to produce a contour plot showing the
;                               phase (velocity) space density of the VDF.  The
;                               structures must also have the following three tags
;                               with finite values:
;                                 VSW     :  [3]-Element [float] array for the bulk flow
;                                              velocity [km/s] vector at time of VDF,
;                                              most likely from level-2 velocity moments
;                                 MAGF    :  [3]-Element [float] array for the quasi-static
;                                              magnetic field [nT] vector at time of VDF,
;                                              most likely from fluxgate magnetometer
;                                 SC_POT  :  Scalar [float] for the spacecraft electric
;                                              potential [eV] at time of VDF
;
;                               **********************************************************
;                               Note:  The routine will check for the VELOCITY tag if the
;                                        VSW tag is not found
;                               **********************************************************
;
;  EXAMPLES:    
;               [calling sequence]
;               [calling sequence]
;               wrapper_vbulk_change____mms, data [,DFRA_IN=dfra_in] [,EX_VECN=ex_vecn]      $
;                                                 [,VCIRC=vcirc] [,VC_XOFF=vc_xoff]          $
;                                                 [,VC_YOFF=vc_yoff] [,FACTORS=factors]      $
;                                                 [,STRUC_OUT=struc_out]
;
;  KEYWORDS:    
;               ***  INPUT  ***
;               FACTORS    :  [N,A,P,E]-Element [numeric] defining the conversion factors
;                               between counts and the data in phase space density units
;                               [e.g., # s^(+3) cm^(-6)] for MMS FPI structures only,
;                               where N = # of time stamps, A = # of azimuthal angle
;                               bins, P = # of poloidal/latitudinal angle bins, and E =
;                               # of energy bins.
;               DFRA_IN    :  [2]-Element array [float/double] defining the DF range
;                               [cm^(-3) km^(-3) s^(3)] that defines the minimum and
;                               maximum value for both the contour levels and the
;                               Y-Axis of the cuts plot
;                               [Default = range of data]
;               ***  INPUT --> Circles for Contour Plot  ***
;               VCIRC      :  Scalar(or array) [float/double] defining the value(s) to
;                               plot as a circle(s) of constant speed [km/s] on the
;                               contour plot [e.g. gyrospeed of specularly reflected ion]
;                               [Default = FALSE]
;               VC_XOFF    :  Scalar(or array) [float/double] defining the center of the
;                               circle(s) associated with VCIRC along the X-Axis
;                               (horizontal)
;                               [Default = 0.0]
;               VC_YOFF    :  Scalar(or array) [float/double] defining the center of the
;                               circle(s) associated with VCIRC along the Y-Axis
;                               (vertical)
;                               [Default = 0.0]
;               ***  INPUT --> Extras for Contour Plot  ***
;               EX_VECN    :  [V]-Element structure array containing extra vectors the
;                               user wishes to project onto the contour, each with
;                               the following format:
;                                  VEC   :  [3]-Element vector in the same coordinate
;                                             system as the bulk flow velocity etc.
;                                             contour plot projection
;                                             [e.g. VEC[0] = along X-GSE]
;                                  NAME  :  Scalar [string] used as a name for VEC
;                                             output onto the contour plot
;                                             [Default = 'Vec_j', j = index of EX_VECS]
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               STRUC_OUT  :  Set to a named variable to return a structure containing
;                               the relevant information associated with the plots,
;                               plot analysis, and results for each VDF in DATA.  The
;                               structure contains the tags from the VDF_INFO and
;                               CONT_STR structures passed by keyword in other routines,
;                               one for each element of DATA.
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Routine will limit the number of elements in DATA to 2000 to avoid
;                     bogging down the routines and brevity
;
;  REFERENCES:  
;               1)  Carlson et al., "An instrument for rapidly measuring plasma
;                      distribution functions with high resolution," Adv. Space Res. 2,
;                      pp. 67-70, 1983.
;               2)  Curtis et al., "On-board data analysis techniques for space plasma
;                      particle instruments," Rev. Sci. Inst. 60, pp. 372, 1989.
;               3)  Lin et al., "A three-dimensional plasma and energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev. 71,
;                      pp. 125, 1995.
;               4)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                      Data," ISSI Scientific Report, Noordwijk, The Netherlands.,
;                      Int. Space Sci. Inst., 1998.
;               5)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, 2008.
;               6)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, 2008.
;               7)  Auster, H.U., K.-H. Glassmeier, W. Magnes, O. Aydogar, W. Baumjohann,
;                      D. Constantinescu, D. Fischer, K.H. Fornacon, E. Georgescu,
;                      P. Harvey, O. Hillenmaier, R. Kroth, M. Ludlam, Y. Narita,
;                      R. Nakamura, K. Okrafka, F. Plaschke, I. Richter, H. Schwarzl,
;                      B. Stoll, A. Valavanoglou, and M. Wiedemann "The THEMIS Fluxgate
;                      Magnetometer," Space Sci. Rev. 141, pp. 235-264, 2008.
;               8)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;               9)  Wilson III, L.B., et al., "Quantified energy dissipation rates in the
;                      terrestrial bow shock: 1. Analysis techniques and methodology,"
;                      J. Geophys. Res. 119, pp. 6455--6474, doi:10.1002/2014JA019929,
;                      2014a.
;              10)  Wilson III, L.B., et al., "Quantified energy dissipation rates in the
;                      terrestrial bow shock: 2. Waves and dissipation,"
;                      J. Geophys. Res. 119, pp. 6475--6495, doi:10.1002/2014JA019930,
;                      2014b.
;              11)  Pollock, C., et al., "Fast Plasma Investigation for Magnetospheric
;                      Multiscale," Space Sci. Rev. 199, pp. 331--406,
;                      doi:10.1007/s11214-016-0245-4, 2016.
;              12)  Gershman, D.J., et al., "The calculation of moment uncertainties
;                      from velocity distribution functions with random errors,"
;                      J. Geophys. Res. 120, pp. 6633--6645, doi:10.1002/2014JA020775,
;                      2015.
;              13)  Bordini, F. "Channel electron multiplier efficiency for 10-1000 eV
;                      electrons," Nucl. Inst. & Meth. 97, pp. 405--408,
;                      doi:10.1016/0029-554X(71)90300-4, 1971.
;              14)  Meeks, C. and P.B. Siegel "Dead time correction via the time series,"
;                      Amer. J. Phys. 76, pp. 589--590, doi:10.1119/1.2870432, 2008.
;              15)  Furuya, K. and Y. Hatano "Pulse-height distribution of output signals
;                      in positive ion detection by a microchannel plate,"
;                      Int. J. Mass Spectrom. 218, pp. 237--243,
;                      doi:10.1016/S1387-3806(02)00725-X, 2002.
;              16)  Funsten, H.O., et al., "Absolute detection efficiency of space-based
;                      ion mass spectrometers and neutral atom imagers,"
;                      Rev. Sci. Inst. 76, pp. 053301, doi:10.1063/1.1889465, 2005.
;              17)  Oberheide, J., et al., "New results on the absolute ion detection
;                      efficiencies of a microchannel plate," Meas. Sci. Technol. 8,
;                      pp. 351--354, doi:10.1088/0957-0233/8/4/001, 1997.
;
;   CREATED:  03/14/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/14/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO wrapper_vbulk_change____mms,data,                                          $
                                FACTORS=factors,                               $  ;;  Conversion factors
                                DFRA_IN=dfra_in,                               $
                                EX_VECN=ex_vecn,                               $  ;;  ***  INPUT --> Extras for Contour Plot  ***
                                VCIRC=vcirc,VC_XOFF=vc_xoff,VC_YOFF=vc_yoff,   $  ;;  ***  INPUT --> Circles for Contour Plot  ***
                                STRUC_OUT=struc_out                               ;;  ***  OUTPUT  ***

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
all_probes     = ['1','2','3','4']        ;;  All spacecraft allowed
all_MMS_scns   = 'MMS'+all_probes
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
;;  Electromagnetic
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
;;  Define speed of light in km/s
c2             = c[0]^2
ckm            = c[0]*1d-3                ;;  m --> km
ckm2           = ckm[0]^2                 ;;  (km/s)^2
;;  Atomic
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
me_eV          = me[0]*c2[0]/qq[0]        ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c2[0]/qq[0]        ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;  Convert mass to units of energy per c^2 [eV km^(-2) s^(2)]
me_esa         = me_eV[0]/ckm2[0]
mp_esa         = mp_eV[0]/ckm2[0]
;;  Define species-specific arrays
chrg_ie        = [1e0,-1e0]
mass_ie        = [mp_esa[0],me_esa[0]]
insn_ie        = ['FPI Ion','FPI Electron']
ityp_ie        = ['dis_vdf','des_vdf']
;;  Default file name middles
xyzvecf        = ['V1','V1xV2xV1','V1xV2']
xy_suff        = xyzvecf[1]+'_vs_'+xyzvecf[0]+'_'
xz_suff        = xyzvecf[0]+'_vs_'+xyzvecf[2]+'_'
yz_suff        = xyzvecf[2]+'_vs_'+xyzvecf[1]+'_'
;;  Default plot window names
xy_winn        = xyzvecf[1]+' vs '+xyzvecf[0]
xz_winn        = xyzvecf[0]+' vs '+xyzvecf[2]
yz_winn        = xyzvecf[2]+' vs '+xyzvecf[1]
win_nms        = [xy_winn[0],xz_winn[0],yz_winn[0]]
;;  Default window numbers
def_winn       = [4L,5L,6L]
;;  Define the current working directory character
;;    e.g., './' [for unix and linux] otherwise guess './' or '.\'
slash          = get_os_slash()                    ;;  '/' for Unix-like, '\' for Windows
vers           = !VERSION.OS_FAMILY                ;;  e.g., 'unix'
vern           = !VERSION.RELEASE                  ;;  e.g., '7.1.1'
test           = test_file_path_format('.',EXISTS=exists,DIR_OUT=cwd_char)
;test           = (vern[0] GE '6.0')
;IF (test[0]) THEN cwd_char = FILE_DIRNAME('',/MARK_DIRECTORY) ELSE cwd_char = '.'+slash[0]
;;  Dummy error messages
noinpt_msg     = 'No input supplied...'
notstr_msg     = 'DATA must be an IDL structure...'
notvdf_msg     = 'DATA must be an array of IDL structures containing velocity distribution functions (VDFs)...'
badinp_msg     = 'DATA must be valid IDL structure from MMS/FPI...'
badsty_msg     = 'DATA must contain one species type from MMS/FPI...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(data) LT 2) OR (N_PARAMS() LT 1) OR (SIZE(data,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Make sure user did not enter more than 2000 structures
;;      => Define dummy copy of DATA to avoid changing input
IF (N_ELEMENTS(data) GT 2000L) THEN dat = data[0L:1999L] ELSE dat = data
ndat           = N_ELEMENTS(dat)
ind_ra         = [0L,ndat[0] - 1L]
sind_ra        = num2int_str(ind_ra,NUM_CHAR=4,/ZERO_PAD)
;;  Check format of DATA --> Make sure its an array of valid FPI structures
test1          = lbw_test_mms_fpi_vdf_structure(data,POST=post,/NOM)
mms_proc_tf    = test1[0] AND (post[0] EQ 2)
IF (~mms_proc_tf[0]) THEN BEGIN
  MESSAGE,badinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
species        = data.SPECIES[0]                           ;;  'i'('e') for ions(electrons)
stest          = (species EQ 'e')
IF (N_ELEMENTS(UNIQ(stest,SORT(stest))) NE 1) THEN BEGIN
  ;;  User sent multiple species types --> Not allowed
  MESSAGE,badsty_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Define indices
nes_i          = N_ELEMENTS(REFORM(dat[0].DATA[*,0,0]))      ;;  # of energy bins
nph_i          = N_ELEMENTS(REFORM(dat[0].DATA[0,*,0]))      ;;  # of azimuthal bins
nth_i          = N_ELEMENTS(REFORM(dat[0].DATA[0,0,*]))      ;;  # of latitudinal/poloidal bins
kk_i           = nes_i[0]*nph_i[0]*nth_i[0]
;;  Define plotting stuff
rmlow_on       = stest[0]                                  ;;  Logic for RMLOW keyword later
probe_n        = data.SPACECRAFT[0]                        ;;  e.g., '1' for probe 1
scft_names     = 'MMS'+probe_n
itypes         = ityp_ie[stest]                            ;;  e.g., 'dis_vdf'
inst_names     = insn_ie[stest]                            ;;  e.g., 'FPI Ion'
t_prefs        = scft_names+'_'+itypes+'_'                 ;;  e.g., 'MMS4_dis_vdf_'
pttl_prefs     = scft_names+' '+inst_names                 ;;  e.g., 'MMS4 FPI Ion'
pttl_midfs     = itypes
s_unix         = dat.TIME                                  ;;  Unix time at start of VDF
e_unix         = dat.END_TIME                              ;;  Unix time at end of VDF
s_str          = time_string(s_unix,PREC=5)
e_str          = time_string(e_unix,PREC=5)
;;  Define new SAVE_DIR
tdate          = STRMID(s_str[0],0L,10L)                   ;;  e.g., '2005-05-30'
sav_dir        = cwd_char[0]+t_prefs[0]+tdate[0]
;;  Define plot titles
pttl_all       = pttl_prefs+pttl_midfs+'!C'+s_str+' - '+STRMID(e_str,11)
;;  Define file name prefixes
fnm            = file_name_times(s_unix,PREC=5)
ftimes         = fnm.F_TIME                 ;; e.g., '2015-11-04_0528x34.54177'
file_prefs     = t_prefs+ftimes+'_'         ;; e.g., 'MMS4_dis_vdf_2015-11-04_0528x34.54177_'
;;----------------------------------------------------------------------------------------
;;  Define data arrays
;;----------------------------------------------------------------------------------------
;;  The following will alter DAT on return by removing data below SC potential, if electrons
vels_s_5d      = lbw_mms_energy_angle_to_velocity_array(dat,RMLOW=rmlow_on[0])
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check FACTORS
dumb_fac       = REPLICATE(d,ndat[0],kk_i[0])
IF (is_a_number(factors,/NOMSSG)) THEN BEGIN
  szdf           = SIZE(factors,/DIMENSIONS)
  IF (N_ELEMENTS(szdf) EQ 4) THEN BEGIN
    test = (szdf[0] EQ ndat[0]) AND (szdf[1] EQ nph_i[0]) AND (szdf[2] EQ nth_i[0]) AND (szdf[3] EQ nes_i[0])
    IF (test[0]) THEN BEGIN
      ;;  Properly set
      IF (N_ELEMENTS(data) GT 2000L) THEN fact = factors[ind_ra[0]:ind_ra[1],*,*,*] ELSE fact = factors
    ENDIF ELSE BEGIN
      ;;  Bad input format --> create dummy array
      fact = dumb_fac
    ENDELSE
  ENDIF ELSE BEGIN
    ;;  Bad input format --> create dummy array
    fact = dumb_fac
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Not set --> create dummy array
  fact = dumb_fac
ENDELSE
;;  Clean up
delete_variable,dumb_fac
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define structures for subroutines
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Reform arrays
data_i_4d      = TRANSPOSE(dat.DATA,[3,0,1,2])*1d15      ;;  cm^(-3)  -->  km^(-3)
data_i_2d      = REFORM(data_i_4d,ndat[0],kk_i[0])
fact_i_2d      = REFORM(fact,ndat[0],kk_i[0])*1d15       ;;  cm^(-3)  -->  km^(-3)
vels_i_2d      = REFORM(vels_s_5d,ndat[0],kk_i[0],3L)
dumb           = {VDF:REPLICATE(d,kk_i[0]),VELXYZ:REPLICATE(d,kk_i[0],3L)}
;;  Clean up
delete_variable,vels_s_5d,data_i_4d,fact
;;------------------------------------------------
;;  Define VDF structures with the following tags:
;;------------------------------------------------
;;      VDF     :  [N]-Element [float/double] array defining
;;                   the VDF in units of phase space density
;;                   [i.e., # s^(+3) km^(-3) cm^(-3)]
;;      VELXYZ  :  [N,3]-Element [float/double] array defining
;;                   the particle velocity 3-vectors for each
;;                   element of VDF
;;                   [km/s]
vdfarr         = REPLICATE(dumb[0],ndat[0])
vdf_1c         = REPLICATE(dumb[0],ndat[0])
FOR j=1L, ndat[0] - 1L DO BEGIN
  dumb           = {VDF:REFORM(data_i_2d[j,*]),VELXYZ:REFORM(vels_i_2d[j,*,*])}
  vdfarr[j]      = dumb[0]
  ;;  Compute one-count level equivalent
  cnts           = REPLICATE(1d0,kk_i[0])*REFORM(fact_i_2d[j,*])
  dumb           = {VDF:cnts,VELXYZ:REFORM(vels_i_2d[j,*,*])}
  vdf_1c[j]      = dumb[0]
ENDFOR
;;  Clean up
delete_variable,fact_i_2d,data_i_2d,vels_i_2d,dumb,cnts
;;-----------------------------------------------------
;;  Define VDF_INFO structures with the following tags:
;;-----------------------------------------------------
;;      SE_T   :  [2]-Element [double] array defining to the
;;                  start and end times [Unix] of the VDF
;;      SCFTN  :  Scalar [string] defining the spacecraft name
;;                  [e.g., 'Wind' or 'THEMIS-B']
;;      INSTN  :  Scalar [string] defining the instrument name
;;                  [e.g., '3DP' or 'ESA' or 'EESA' or 'SST']
;;      SCPOT  :  Scalar [float] defining the spacecraft
;;                  electrostatic potential [eV] at the time of
;;                  the VDF
;;      VSW    :  [3]-Element [float] array defining to the
;;                  bulk flow velocity [km/s] 3-vector at the
;;                  time of the VDF
;;      MAGF   :  [3]-Element [float] array defining to the
;;                  quasi-static magnetic field [nT] 3-vector at
;;                  the time of the VDF
def_tags       = ['se_t','scftn','instn','scpot','vsw','magf']
dumb3d         = REPLICATE(0d0,3L)
dumb2d         = dumb3d[0:1]
dumb3f         = FLOAT(dumb3d)
dumb           = CREATE_STRUCT(def_tags,dumb2d,'','',0e0,dumb3f,dumb3f)
vdf_info       = REPLICATE(dumb[0],ndat[0])
dim3v          = SIZE(vdf_info.VSW,/DIMENSIONS)
;;  MMS structures use VELOCITY tag
vsw            = struct_value(dat[0],'VELOCITY',INDEX=dind)
IF (dind[0] LT 0) THEN RETURN
vsw_tag        = 0b
vel_tag        = 1b
vbulk_tag      = (['vsw','velocity'])[(WHERE([vsw_tag[0],vel_tag[0]]))[0]]
;;  Define tags
vdf_info.SCFTN    = scft_names                           ;;  e.g., 'MMS1'
vdf_info.INSTN    = inst_names                           ;;  e.g., 'FPI Ion'
vdf_info.SE_T[0]  = s_unix
vdf_info.SE_T[1]  = e_unix
vdf_info.SCPOT[0] = REFORM(dat.SC_POT[0])
vdf_info.MAGF     = REFORM(dat.MAGF,dim3v[0],dim3v[1])
vbulk             = REFORM(dat.VELOCITY,dim3v[0],dim3v[1])
vdf_info.VSW      = vbulk
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check VCIRC
test           = is_a_number(vcirc,/NOMSSG) AND (N_ELEMENTS(vcirc) GT 0)
IF (test[0]) THEN BEGIN
  vrad   = DOUBLE(ABS(REFORM(vcirc)))
  nvr    = N_ELEMENTS(vrad)
  ;;  VCIRC is set --> Check VC_XOFF and VC_YOFF
  test   = (nvr[0] NE nvcxo[0]) OR (nvr[0] NE nvcyo[0])
  IF (test[0]) THEN BEGIN
    ;;  Bad format --> Use default offsets = 0.0 km/s
    vcirc_xoff = REPLICATE(0d0,nvr[0])
    vcirc_yoff = REPLICATE(0d0,nvr[0])
  ENDIF
  ;;  Define circle structure
  dumb     = {VRAD:0d0,VOX:0d0,VOY:0d0}
  circ_str = REPLICATE(dumb[0],nvr[0])
  FOR j=0L, nvr[0] - 1L DO circ_str[j] = {VRAD:vrad[j],VOX:vcirc_xoff[j],VOY:vcirc_yoff[j]}
ENDIF ELSE BEGIN
  circ_str = 0
ENDELSE
;;  Check EX_VECN
test           = (SIZE(ex_vecn,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  ;;  Not structure --> default to FALSE
  ex_vecs        = 0
ENDIF ELSE BEGIN
  ;;  Structure --> check format
  dumb           = {VEC:REPLICATE(0d0,3L),NAME:''}
  temp           = structure_compare(ex_vecn,dumb,EXACT=exact,MATCH_NT=match_nt,$
                                     MATCH_TG=match_tg,MATCH_TT=match_tt)
  test           = (temp[0] LE 4) OR (~match_nt[0] OR ~match_tg[0])
  IF (test[0]) THEN BEGIN
    ;;  Bad format --> default to FALSE
    ex_vecs        = 0
  ENDIF ELSE BEGIN
    ;;  Check that VEC tags contain 3-vectors
    test           = (is_a_3_vector(ex_vecn[0].VEC,V_OUT=v_out,/NOMSSG) EQ 0)
    IF (test[0]) THEN BEGIN
      ;;  Bad format --> default to FALSE
      ex_vecs        = 0
    ENDIF ELSE BEGIN
      ;;  Get relevant values
      nexv           = N_ELEMENTS(ex_vecn)
      ex_tags        = TAG_NAMES(dumb)
      extract_tags,dumb,ex_vecn[0],TAGS=ex_tags
      ex_vecs        = REPLICATE(dumb[0],nexv[0])
      ;;  Define tags
      ex_vecs.VEC    = ex_vecn.VEC
      ex_vecs.NAME   = ex_vecn.NAME
    ENDELSE
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Initialize windows
;;----------------------------------------------------------------------------------------
;;  Make sure device set to 'X'
IF (STRLOWCASE(!D.NAME) NE 'x') THEN SET_PLOT,'X'
;;  Get the status of the current windows [1 = open, 0 = no associated window]
DEVICE,WINDOW_STATE=wstate
;;  Get screen size to scale and position windows
DEVICE,GET_SCREEN_SIZE=scsize
;;  Keep the same aspect ratio of plot windows regardless of screen size
wdy            = 200L
aspect         = 800d0/1100d0                    ;;  x/y
ysize          = LONG(scsize[1] - wdy[0])        ;;  YSIZE keyword setting
xsize          = LONG(ysize[0]*aspect[0])        ;;  XSIZE keyword setting
wdx            = scsize[0] - (xsize[0] + 10)
wypos          = [0d0,3d0*wdy[0]/2d0]
wxpos          = [1d1,wdx[0]]
;;  Define some structures for WINDOW.PRO
wilim1         = {RETAIN:2,XSIZE:xsize[0],YSIZE:ysize[0],TITLE:xy_winn[0],XPOS:wxpos[0],YPOS:wypos[1]}
wilim2         = {RETAIN:2,XSIZE:xsize[0],YSIZE:ysize[0],TITLE:xz_winn[0],XPOS:wxpos[0],YPOS:wypos[0]}
wilim3         = {RETAIN:2,XSIZE:xsize[0],YSIZE:ysize[0],TITLE:yz_winn[0],XPOS:wxpos[1],YPOS:wypos[1]}
wstruc         = {WIN1:wilim1,WIN2:wilim2,WIN3:wilim3}
FOR j=0L, 2L DO BEGIN
  winn           = def_winn[j]
  wins           = wstruc.(j)
  lbw_window,/NEW_W,WIND_N=winn[0],_EXTRA=wins[0]
ENDFOR
test           = vbulk_change_test_windn(def_winn[0],DAT_OUT=windn)
IF (~test[0]) THEN STOP     ;;  Should not happen --> Debug
;;----------------------------------------------------------------------------------------
;;  Initialize first index
;;----------------------------------------------------------------------------------------
old_value      = 0L         ;;  start with first VDF as default
old_strval     = num2int_str(old_value[0],NUM_CHAR=5,/ZERO_PAD)
;;  Define instructions and info
pro_out        = ["[Type 'q' to quit at any time]","",$
                  "You can print the indices prior to choosing or enter the value",$
                  "if you already know which distribution you want to examine.","",$
                  "The default (and current) index is "+old_strval[0]]
str_out        = "Do you wish to print the indices prior to choosing (y/n)?"
read_out       = ''
WHILE (read_out NE 'y' AND read_out NE 'n' AND read_out NE 'q') DO BEGIN
  read_out = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
  IF (read_out EQ 'debug') THEN STOP
ENDWHILE
;;  Check if user wishes to quit
IF (read_out EQ 'q') THEN RETURN
IF (read_out EQ 'y') THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Print out indices first
  ;;--------------------------------------------------------------------------------------
  s_times        = s_unix
  e_times        = e_unix
  PRINT,';;'
  PRINT,';;  The list of available DF dates, start/end times, and associated index are:'
  PRINT,';;'
  vbulk_change_print_index_time,s_times,e_times
ENDIF
;;  Define prompt instructions
str_out        = "Enter a value between "+sind_ra[0]+" and "+sind_ra[1]+":  "
true           = 1
WHILE (true[0]) DO BEGIN
  temp           = general_prompt_routine(STR_OUT=str_out,FORM_OUT=3)
  value_out      = LONG(ABS(temp[0]))
  true           = (value_out[0] LT ind_ra[0]) OR (value_out[0] GT ind_ra[1])
ENDWHILE
;;  Define 1st index to plot
index          = value_out[0]
ind0           = index[0]
;;  Initialize some keywords
filepref       = file_prefs[ind0[0]]
vframe         = vdf_info[ind0[0]].VSW
vec1           = [1d0,0d0,0d0]
vec2           = [0d0,1d0,0d0]
;;----------------------------------------------------------------------------------------
;;  Initialize keywords
;;----------------------------------------------------------------------------------------
vbulk_change_keywords_init,vdfarr,SAVE_DIR=sav_dir[0],FILE_PREF=filepref[0],         $
                                  VFRAME=vframe,VEC1=vec1,VEC2=vec2,WINDN=windn,     $
                                  PLOT_STR=plot_str,CONT_STR=cont_str,               $
                                  DFRA_IN=dfra_in
;;  Define output version of CONT_STR
contstr0       = cont_str[0]
vframe0        = REFORM(contstr0[0].VFRAME)
cont_out       = REPLICATE(contstr0[0],ndat[0])
;;----------------------------------------------------------------------------------------
;;  Start Loop
;;----------------------------------------------------------------------------------------
;; Define parameters and initializations
true           = 1
data_out       = 0b
WHILE (true[0]) DO BEGIN
  ;; Reset outputs
  read_out       = ''
  ps_fname       = ''
  finished       = 0
  keep_out       = 0
  ;;  set file name variables
  ind0           = index[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Update VFRAME in CONT_STR using the VDF
  ;;--------------------------------------------------------------------------------------
  ;;  Check if user already altered VFRAME for this index (e.g., last setting was 'prev')
  diff           = FLOAT(ABS(REFORM(cont_out[ind0[0]].VFRAME) - vframe0))
  test           = (TOTAL(diff) GT 1e-6)         ;;  TRUE --> user altered VFRAME for this index
  IF (test[0]) THEN vframe = REFORM(cont_out[ind0[0]].VFRAME) ELSE vframe = vdf_info[ind0[0]].VSW
  str_element,cont_str,'VFRAME',vframe,/ADD_REPLACE
  ;;--------------------------------------------------------------------------------------
  ;; Plot and alter dynamically
  ;;--------------------------------------------------------------------------------------
  ;;  vbulk_change_vdf_plot_wrapper.pro
  vbulk_change_vdf_plot_wrapper,vdfarr,INDEX=ind0,VDF_INFO=vdf_info,CONT_STR=cont_str,     $
                                       WINDN=windn,PLOT_STR=plot_str,                      $
                                       EX_VECN=ex_vecs,VCIRC=circ_str,ALL_PTTLS=pttl_all,  $
                                       ALL_FPREFS=file_prefs,                              $
                                       DATA_OUT=data_out,READ_OUT=read_out,                $
                                       PS_FNAME=ps_fname,ONEC_ARR=vdf_1c
  ;;--------------------------------------------------------------------------------------
  ;;  Check if user quit
  ;;--------------------------------------------------------------------------------------
  IF (read_out[0] EQ 'q') THEN GOTO,JUMP_CHECK  ;;  go to next iteration or quit
  ;;  Update CONT_OUT
  cont_out[index[0]] = cont_str[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Check if user changed index
  ;;--------------------------------------------------------------------------------------
  ;;  Check current index value
  true           = (ind0[0] LE ndat[0] - 1L) AND (ind0[0] GE 0L)
  test           = (read_out[0] EQ 'next') OR (read_out[0] EQ 'prev') OR (read_out[0] EQ 'index')
  IF (test[0]) THEN BEGIN
    ;;  user changed index, so check if index is valid
    IF (true[0]) THEN index = ind0[0]
    ;;  Jump back to end of loop
    GOTO,JUMP_SKIP
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Check if user saved plots
  ;;--------------------------------------------------------------------------------------
  test           = (read_out[0] EQ 'save1') OR (read_out[0] EQ 'save3')
  IF (test[0]) THEN BEGIN
    ;;  user saved plots --> reset READ_OUT and check with user
    read_out       = ''
    ;;  Jump to checkpoint
    GOTO,JUMP_CHECK
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Check if user finished
  ;;--------------------------------------------------------------------------------------
  IF (N_ELEMENTS(ps_fname) GT 1) THEN finished = 1b ELSE finished = 0b
  IF (finished[0]) THEN BEGIN
    str_out        = "Do you want to add results to output (type 'a') or just move on to another DF (type 'n'):  "
    ;;  Set/Reset outputs
    read_out       = ''    ;; output value of decision
    WHILE (read_out[0] NE 'n' AND read_out[0] NE 'a' AND read_out[0] NE 'q') DO BEGIN
      read_out       = general_prompt_routine(STR_OUT=str_out,FORM_OUT=7)
      IF (read_out[0] EQ 'debug') THEN STOP
    ENDWHILE
    IF (read_out[0] EQ 'a') THEN keep_out = 1b ELSE keep_out = 0b
    IF (read_out[0] EQ 'q') THEN GOTO,JUMP_END
  ENDIF ELSE keep_out = 0
  IF (~keep_out[0] OR SIZE(data_out,/TYPE) NE 8) THEN GOTO,JUMP_CHECK  ;; go to next iteration
  ;;--------------------------------------------------------------------------------------
  ;;  Check if user quit
  ;;--------------------------------------------------------------------------------------
  ;;======================================================================================
  JUMP_CHECK:
  ;;======================================================================================
  IF (N_ELEMENTS(read_out) EQ 0) THEN read_out = ''
  test           = (read_out[0] EQ '') OR (read_out[0] EQ 'q')
  IF (test[0]) THEN BEGIN
    str_out        = "Did you want to quit (type 'q') or just move on to another DF (type 'n'):  "
    ;;  Set/Reset outputs
    read_out       = ''    ;; output value of decision
    WHILE (read_out[0] NE 'n' AND read_out[0] NE 'q') DO BEGIN
      read_out       = general_prompt_routine(STR_OUT=str_out,FORM_OUT=7)
      IF (read_out[0] EQ 'debug') THEN STOP
    ENDWHILE
    ;;  Check if user wishes to quit
    IF (read_out[0] EQ 'q') THEN GOTO,JUMP_END
    ;;  user quit, so reset values and move to next index
    index += true[0]
    ;;  Jump back to end of loop
    GOTO,JUMP_SKIP
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Check if user wants to continue or quit
  ;;--------------------------------------------------------------------------------------
  ;;  Set/Reset outputs
  read_out       = ''
  str_out        = "Did you want to continue (type 'c') or quit (type 'q'):  "
  pro_out        = ["[Type 'q' to quit at any time]"]
  WHILE (read_out[0] NE 'c' AND read_out[0] NE 'q') DO BEGIN
    read_out       = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
    IF (read_out[0] EQ 'debug') THEN STOP
  ENDWHILE
  ;;  Check if user wishes to quit [leave everything print nothing]
  IF (read_out[0] EQ 'q') THEN GOTO,JUMP_END
  ;;  Check if user wishes to continue fitting
  IF (read_out[0] EQ 'c') THEN true = 1b ELSE true = 0b
  ;;  Check current index value
  IF (index[0] EQ ind0[0])   THEN index += true[0]
  ;;======================================================================================
  JUMP_SKIP:
  ;;======================================================================================
ENDWHILE
;;========================================================================================
JUMP_END:
;;========================================================================================
;;  Define output structure
struc_out      = {CONT_STR:cont_out,VDF_INFO:vdf_info}
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END











