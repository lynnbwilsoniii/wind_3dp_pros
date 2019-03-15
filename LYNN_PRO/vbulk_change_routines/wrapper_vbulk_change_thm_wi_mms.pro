;+
;*****************************************************************************************
;
;  PROCEDURE:   wrapper_vbulk_change_thm_wi_mms.pro
;  PURPOSE  :   This is a wrapping routine for the Vbulk Change IDL Libraries that takes
;                 an array of particle velocity distribution functions (VDFs) from
;                 Wind/3DP, THEMIS ESA, or MMS FPI experiments.  These routines allow
;                 a user to dynamically and interactively change the reference frame used
;                 for plotting contour plots in a user-defined coordinate basis.
;
;                 This routine is literally a filter to determine which of the actual
;                 wrapping routines should be called.
;
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               test_wind_vs_themis_esa_struct.pro
;               lbw_test_mms_fpi_vdf_structure.pro
;               wrapper_vbulk_change_thm_wi.pro
;               wrapper_vbulk_change____mms.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Vbulk Change IDL Libraries
;
;  INPUT:
;               DATA       :  [N]-Element [structure] array of particle velocity
;                               distribution functions (VDFs) from Wind/3DP, MMS FPI,
;                               or the THEMIS ESA instruments.  Regardless, the
;                               structures must satisfy the criteria needed to produce
;                               a contour plot showing the phase (velocity) space density
;                               of the VDF.  The structures must also have the following
;                               three tags with finite values:
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
;               wrapper_vbulk_change_thm_wi_mms, data [,DFRA_IN=dfra_in] [,EX_VECN=ex_vecn] $
;                                                [,VCIRC=vcirc] [,VC_XOFF=vc_xoff]          $
;                                                [,VC_YOFF=vc_yoff] [,FACTORS=factors]      $
;                                                [,STRUC_OUT=struc_out]
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

PRO wrapper_vbulk_change_thm_wi_mms,data,                                          $
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
;;  Define the current working directory character
;;    e.g., './' [for unix and linux] otherwise guess './' or '.\'
slash          = get_os_slash()                    ;;  '/' for Unix-like, '\' for Windows
vers           = !VERSION.OS_FAMILY                ;;  e.g., 'unix'
vern           = !VERSION.RELEASE                  ;;  e.g., '7.1.1'
test           = (vern[0] GE '6.0')
IF (test[0]) THEN cwd_char = FILE_DIRNAME('',/MARK_DIRECTORY) ELSE cwd_char = '.'+slash[0]
;;  Dummy error messages
noinpt_msg     = 'No input supplied...'
notstr_msg     = 'DATA must be an IDL structure...'
notvdf_msg     = 'DATA must be an array of IDL structures containing velocity distribution functions (VDFs)...'
badinp_msg     = 'DATA must be valid IDL structure from Wind/3DP or THEMIS/ESA or MMS/FPI...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(data) LT 2) OR (N_PARAMS() LT 1) OR (SIZE(data,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Determine the spacecraft to use
;;----------------------------------------------------------------------------------------
test0          = test_wind_vs_themis_esa_struct(data,/NOM)
test1          = lbw_test_mms_fpi_vdf_structure(data,POST=post,/NOM)
wi_or_thm      = (test0.WIND[0] OR test0.THEMIS[0])
mms_proc_tf    = test1[0] AND (post[0] EQ 2)
test           = (~wi_or_thm[0] AND ~mms_proc_tf[0])
IF (test[0]) THEN BEGIN
  MESSAGE,badinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
CASE 1 OF
  wi_or_thm[0]    :  BEGIN
    ;;  VDFs from Wind or THEMIS
    wrapper_vbulk_change_thm_wi,data,DFRA_IN=dfra_in,EX_VECN=ex_vecn,VCIRC=vcirc,$
                                     VC_XOFF=vc_xoff,VC_YOFF=vc_yoff,STRUC_OUT=struc_out
    RETURN
  END
  mms_proc_tf[0]  :  BEGIN
    ;;  VDFs from MMS
    wrapper_vbulk_change____mms,data,FACTORS=factors,DFRA_IN=dfra_in,EX_VECN=ex_vecn, $
                                     VCIRC=vcirc,VC_XOFF=vc_xoff,VC_YOFF=vc_yoff,     $
                                     STRUC_OUT=struc_out
    RETURN
  END
  ELSE  :  STOP      ;;  Should not happen --> debug!
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END

