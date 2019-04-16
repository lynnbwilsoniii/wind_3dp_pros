;+
;*****************************************************************************************
;
;  PROCEDURE:   vbulk_change_keywords_init.pro
;  PURPOSE  :   This routine initializes the keywords etc. used by plotting routines and
;                 other subroutines called.  The values on output are only the default
;                 values and some may be changed later.
;
;  CALLED BY:   
;               wrapper_vbulk_change_thm_wi.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               vbulk_change_get_default_struc.pro
;               tag_names_r.pro
;               vbulk_change_test_vdf_str_form.pro
;               test_file_path_format.pro
;               str_element.pro
;               is_a_number.pro
;               vbulk_change_test_windn.pro
;               vbulk_change_test_plot_str_form.pro
;               is_a_3_vector.pro
;               vbulk_change_prompts.pro
;               struct_value.pro
;               num2int_str.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Vbulk Change IDL Libraries
;
;  INPUT:
;               DAT        :  Scalar data structure containing a particle velocity
;                               distribution function (VDF) with the following
;                               structure tags:
;                                 VDF     :  [N]-Element [float/double] array defining
;                                              the VDF in units of phase space density
;                                              [i.e., # s^(+3) km^(-3) cm^(-3)]
;                                 VELXYZ  :  [N,3]-Element [float/double] array defining
;                                              the particle velocity 3-vectors for each
;                                              element of VDF
;                                              [km/s]
;
;  EXAMPLES:    
;               [calling sequence]
;               vbulk_change_keywords_init, dat [,SAVE_DIR=save_dir]                   $
;                                          [,FILE_PREF=file_pref] [,VFRAME=vframe]     $
;                                          [,VEC1=vec1] [,VEC2=vec2] [,WINDN=windn]    $
;                                          [,PLOT_STR=plot_str] [,CONT_STR=cont_str]   $
;                                          [,DFRA_IN=dfra_in]
;
;  KEYWORDS:    
;               ***  INPUT --> Values user defines a priori  ***
;               SAVE_DIR   :  Scalar [string] defining the directory where the plots
;                               will be saved
;                               [Default = current working directory]
;               FILE_PREF  :  Scalar [string] defining the file name prefix associated
;                               the PostScript plot for each VDF on output
;                               [Default = defined by wrapping routine]
;               ***  INPUT --> Values user defines a priori (not required though)  ***
;               VFRAME     :  [3]-Element [float/double] array defining the 3-vector
;                               velocity of the K'-frame relative to the K-frame [km/s]
;                               to use to transform the velocity distribution into the
;                               bulk flow reference frame
;                               [ Default = [0,0,0] ]
;               VEC1       :  [3]-Element vector to be used for "parallel" direction in
;                               a 3D rotation of the input data
;                               [e.g. see rotate_3dp_structure.pro]
;                               [ Default = [1.,0.,0.] ]
;               VEC2       :  [3]--Element vector to be used with VEC1 to define a 3D
;                               rotation matrix.  The new basis will have the following:
;                                 X'  :  parallel to VEC1
;                                 Z'  :  parallel to (VEC1 x VEC2)
;                                 Y'  :  completes the right-handed set
;                               [ Default = [0.,1.,0.] ]
;               ***  INPUT --> System  ***
;               WINDN      :  Scalar [long] defining the index of the window to use when
;                               selecting the region of interest
;                               [Default = !D.WINDOW]
;               PLOT_STR   :  Scalar [structure] that defines the scaling factors for the
;                               contour plot shown in window WINDN to be used by
;                               general_cursor_select.pro
;               ***  INPUT  ***
;               DFRA_IN    :  [2]-Element array [float/double] defining the DF range
;                               [cm^(-3) km^(-3) s^(3)] that defines the minimum and
;                               maximum value for both the contour levels and the
;                               Y-Axis of the cuts plot
;                               [Default = range of data]
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               CONT_STR   :  Scalar [structure] containing tags defining all of the
;                               current plot settings associated with all of the above
;                               "INPUT --> Command to Change" keywords
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/23/2017   v1.0.0]
;             2)  Continued to write routine
;                                                                   [07/21/2017   v1.0.0]
;             3)  Continued to write routine
;                                                                   [07/25/2017   v1.0.0]
;             4)  Continued to write routine
;                                                                   [07/27/2017   v1.0.0]
;             5)  Continued to write routine
;                                                                   [07/28/2017   v1.0.0]
;             6)  Continued to write routine
;                                                                   [07/31/2017   v1.0.0]
;
;   NOTES:      
;               0)  User should not directly call this routine
;               1)  See routines called by this wrapping program for more information
;                     about their usage
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
;   CREATED:  05/22/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/31/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO vbulk_change_keywords_init,dat,SAVE_DIR=save_dir,FILE_PREF=file_pref,             $
                                   VFRAME=vframe,VEC1=vec1,VEC2=vec2,WINDN=windn,     $
                                   PLOT_STR=plot_str,CONT_STR=cont_str,               $
                                   DFRA_IN=dfra_in

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_ptags      = ['xscale','yscale','xfact','yfact']
def_con_tags   = ['vframe','vec1','vec2','vlim','nlev','xname','yname','sm_cuts','sm_cont',$
                  'nsmcut','nsmcon','plane','dfmin','dfmax','dfra','v_0x','v_0y',          $
                  'save_dir','file_pref','file_midf']
def_extra_str  = CREATE_STRUCT(def_con_tags,0b,0b,0b,0b,0b,0b,0b,0b,0b,0b,0b,0b,0b,0b,0b,  $
                                            0b,0b,0b,0b,0b)
ndt            = N_ELEMENTS(def_con_tags)
dumb2          = REPLICATE(0d0,2L)
;;  Define parts of file names
xyzvecf        = ['V1','V1xV2xV1','V1xV2']
xy_suff        = xyzvecf[1]+'_vs_'+xyzvecf[0]+'_'
xz_suff        = xyzvecf[0]+'_vs_'+xyzvecf[2]+'_'
yz_suff        = xyzvecf[2]+'_vs_'+xyzvecf[1]+'_'
;;  Default window numbers
def_winn       = [4L,5L,6L]
;;  ***************************************************
;;  The following are from general_vdf_contour_plot.pro
;;  ***************************************************
;;  Position of contour plot [square]
;;                   Xo    Yo    X1    Y1
pos_0con       = [0.22941,0.515,0.77059,0.915]
;;  Position of 1st DF cuts [square]
pos_0cut       = [0.22941,0.050,0.77059,0.450]
;;----------------------------------------------------------------------------------------
;;  Define defaults
;;----------------------------------------------------------------------------------------
def_vframe     = REPLICATE(0d0,3L)
def_vec__1     = [1d0,0d0,0d0]
def_vec__2     = [0d0,1d0,0d0]
;;----------------------------------------------------------------------------------------
;;  Define default contour structure
;;----------------------------------------------------------------------------------------
def_cont_str   = vbulk_change_get_default_struc()
tags_a         = tag_names_r(def_cont_str[0],TYPE=def_con_typs)
def_con_tags   = STRLOWCASE(tags_a)
;;----------------------------------------------------------------------------------------
;;  Define default plot structure
;;----------------------------------------------------------------------------------------
def_plot_str   = CREATE_STRUCT(def_ptags,dumb2,dumb2,1d3,1d3)
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check VDF structure format
test           = vbulk_change_test_vdf_str_form(dat)
IF (test[0] EQ 0) THEN RETURN
;;  Define values that will be altered later
cont_str       = def_cont_str[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check SAVE_DIR
test           = (SIZE(save_dir,/TYPE) NE 7) OR (N_ELEMENTS(save_dir) LT 1)
IF (test[0]) THEN savdir = def_cont_str.SAVE_DIR[0] ELSE savdir = save_dir[0]
true           = 1b
WHILE (true[0]) DO BEGIN
  test           = test_file_path_format(savdir,EXISTS=exists,DIR_OUT=dir_out)
  IF (~test[0]) THEN savdir = def_cont_str.SAVE_DIR[0]
  true           = ~test[0]
ENDWHILE
IF (~exists[0]) THEN FILE_MKDIR,dir_out[0]
;;  Add to CONT_STR
str_element,cont_str,'SAVE_DIR',dir_out[0],/ADD_REPLACE
;;  Check FILE_PREF
test           = (SIZE(file_pref,/TYPE) NE 7) OR (N_ELEMENTS(file_pref) LT 1)
IF (test[0]) THEN filepref = def_cont_str.FILE_PREF[0] ELSE filepref = file_pref[0]
;;  Add to CONT_STR
str_element,cont_str,'FILE_PREF', filepref[0],/ADD_REPLACE
;;  Check WINDN
test           = (is_a_number(windn,/NOMSSG) EQ 0) OR (N_ELEMENTS(windn) NE 1)
IF (test[0] EQ 0) THEN win0 = !D.WINDOW[0] ELSE win0 = (LONG(windn[0]) > 0L) < 32L
test           = vbulk_change_test_windn(win0[0],DAT_OUT=win)
IF (~test[0]) THEN RETURN
;;  Check PLOT_STR
;;    TRUE   -->  Allow use of general_cursor_select.pro routine
;;    FALSE  -->  Command-line input only
test           = vbulk_change_test_plot_str_form(plot_str,DAT_OUT=plot_out)
IF (~test[0]) THEN BEGIN
  ;;  Initialize structure
  plot_str = def_plot_str
  ;;  Alter values using current defaults
  WSET,win0[0]
  str_element,plot_str,def_ptags[0],!X.S,/ADD_REPLACE
  str_element,plot_str,def_ptags[1],!Y.S,/ADD_REPLACE
  str_element,plot_str,def_ptags[2], 1d3,/ADD_REPLACE
  str_element,plot_str,def_ptags[3], 1d3,/ADD_REPLACE
ENDIF ELSE plot_str = plot_out
;;  Check VFRAME
in_str         = 'vframe'
test           = is_a_3_vector(vframe,V_OUT=v_out,/NOMSSG) AND (N_ELEMENTS(vframe) EQ 3)
IF (test[0]) THEN str_element,cont_str,in_str[0],1d0*REFORM(v_out),/ADD_REPLACE    ;;  ELSE --> use default
;;  Check VEC1
in_str         = 'vec1'
test           = is_a_3_vector(vec1,V_OUT=v_out,/NOMSSG) AND (N_ELEMENTS(vec1) EQ 3)
IF (test[0]) THEN str_element,cont_str,in_str[0],1d0*REFORM(v_out),/ADD_REPLACE    ;;  ELSE --> use default
;;  Check VEC2
in_str         = 'vec2'
test           = is_a_3_vector(vec2,V_OUT=v_out,/NOMSSG) AND (N_ELEMENTS(vec2) EQ 3)
IF (test[0]) THEN str_element,cont_str,in_str[0],1d0*REFORM(v_out),/ADD_REPLACE    ;;  ELSE --> use default
;;  Check DFRA_IN
in_str         = 'dfra'
test           = test_plot_axis_range(dfra_in)
IF (test[0]) THEN str_element,cont_str,in_str[0],1d0*REFORM(dfra_in),/ADD_REPLACE  ;;  ELSE --> use default
;;----------------------------------------------------------------------------------------
;;  Initialize all keywords
;;----------------------------------------------------------------------------------------
FOR j=1L, ndt[0] - 4L DO BEGIN        ;;  Do not alter VFRAME, SAVE_DIR. FILE_PREF, or FILE_MIDF here
  in_str         = def_con_tags[j]
  ex_str         = def_extra_str
  old_typ        = SIZE(def_cont_str.(j),/TYPE)
  str_element,ex_str,in_str[0],1b,/ADD_REPLACE
  ;;--------------------------------------------------------------------------------------
  ;;  Call prompting routine
  ;;--------------------------------------------------------------------------------------
  vbulk_change_prompts,dat,_EXTRA=ex_str,                              $
                       CONT_STR=cont_str,WINDN=win,PLOT_STR=plot_str,  $
                       READ_OUT=read_out,VALUE_OUT=value_out
  ;;--------------------------------------------------------------------------------------
  ;;  Check output
  ;;--------------------------------------------------------------------------------------
  ;;  Check if user wishes to quit
  IF (read_out[0] EQ 'q') THEN RETURN
  ;;  Change parameter if valid output
  test           = (read_out[0] NE 'q') AND (SIZE(value_out,/TYPE) EQ old_typ[0])
  IF (test[0]) THEN BEGIN
    str_element,cont_str,in_str[0],value_out,/ADD_REPLACE
  ENDIF ELSE STOP     ;;  Something is wrong --> Debug
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define FILE_MIDF
;;----------------------------------------------------------------------------------------
nlevs          = struct_value(cont_str,'nlev',INDEX=dind)
IF (dind[0] LT 0) THEN nlevs = def_cont_str.NLEV
def_val_str    = num2int_str(nlevs[0],NUM_CHAR=2)+'CLevels_'
projxy         = struct_value(cont_str,'plane',INDEX=dind)
IF (dind[0] LT 0) THEN projxy = 'xy'
CASE projxy[0] OF
  'xy'  :  file_midf = xy_suff[0]+def_val_str[0]    ;;  e.g., 'V1xV2xV1_vs_V1_30CLevels_'
  'xz'  :  file_midf = xz_suff[0]+def_val_str[0]
  'yz'  :  file_midf = yz_suff[0]+def_val_str[0]
ENDCASE
;;  Define WINDN for output
windn          = def_winn[(WHERE(projxy[0] EQ ['xy','xz','yz']))[0]]
;;  Add to CONT_STR
str_element,cont_str,'FILE_MIDF',file_midf[0],/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Update PLOT_STR values (i.e., define proper scale factors)
;;----------------------------------------------------------------------------------------
vlim           = struct_value(cont_str,'vlim',INDEX=dind)
IF (dind[0] LT 0) THEN vlim = def_cont_str.VLIM
xyran          = [-1d0,1d0]*vlim[0]*1d-3     ;;  km  -->  Mm  [just looks better when plotted]
;;  Define ∆X_d and ∆Y_d
delta_xd       = MAX(xyran,/NAN) - MIN(xyran,/NAN)
delta_yd       = delta_xd
;;  Define ∆X_n and ∆Y_n
x_n            = pos_0con[[0,2]]
y_n            = pos_0con[[1,3]]
delta_xn       = x_n[1] - x_n[0]
delta_yn       = y_n[1] - y_n[0]
;;  Define scale factors, e.g.,  S_1x = (∆X_n/∆X_d) and S_0x = X_n1 - (∆X_n/∆X_d)*X_d1
sc_1x          = ABS(delta_xn[0]/delta_xd[0])
sc_0x          = x_n[1] - sc_1x[0]*xyran[1]
sc_1y          = ABS(delta_yn[0]/delta_yd[0])
sc_0y          = y_n[1] - sc_1y[0]*xyran[1]
sc_x           = DOUBLE([sc_0x[0],sc_1x[0]])
sc_y           = DOUBLE([sc_0y[0],sc_1y[0]])
;;  Update [X,Y]SCALE tags
str_element,plot_str,'XSCALE',sc_x,/ADD_REPLACE
str_element,plot_str,'YSCALE',sc_y,/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END




















