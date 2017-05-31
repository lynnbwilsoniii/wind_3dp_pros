;+
;*****************************************************************************************
;
;  PROCEDURE:   contour_3d_1plane.pro
;  PURPOSE  :   Produces a contour plot of the distribution function (DF) with parallel
;                 and perpendicular cuts with respect to the user defined input vectors.
;                 The contour plot does NOT assume gyrotropy, so the features in the DF
;                 may illustrate anisotropies more easily.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               get_font_symbol.pro
;               get_color_by_name.pro
;               get_os_slash.pro
;               test_wind_vs_themis_esa_struct.pro
;               dat_3dp_str_names.pro
;               pesa_high_bad_bins.pro
;               convert_ph_units.pro
;               conv_units.pro
;               string_replace_char.pro
;               time_string.pro
;               read_gen_ascii.pro
;               transform_vframe_3d.pro
;               rotate_3dp_structure.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  3DP data structure either from get_??.pro
;                               with defined structure tag quantities for VSW
;               VECTOR1    :  3-Element vector to be used for "parallel" direction in
;                               a 3D rotation of the input data
;                               [e.g. see rotate_3dp_structure.pro]
;                               [Default = MAGF ELSE {1.,0.,0.}]
;               VECTOR2    :  3-Element vector to be used with VECTOR1 to define a 3D
;                               rotation matrix.  The new basis will have the following:
;                                 X'  :  parallel to VECTOR1
;                                 Z'  :  parallel to (VECTOR1 x VECTOR2)
;                                 Y'  :  completes the right-handed set
;                               [Default = VSW ELSE {0.,1.,0.}]
;
;  EXAMPLES:    
;               ;;....................................................................
;               ;;  Define a time of interest
;               ;;....................................................................
;               to      = time_double('1998-08-09/16:00:00')
;               ;;....................................................................
;               ;;  Get a Wind 3DP PESA High data structure from level zero files
;               ;;....................................................................
;               dat     = get_ph(to)
;               ;;....................................................................
;               ;;  in the following lines, the strings correspond to TPLOT handles
;               ;;      and thus may be different for each user's preference
;               ;;....................................................................
;               add_vsw2,dat,'V_sw2'          ; => Add solar wind velocity to struct.
;               add_magf2,dat,'wi_B3(GSE)'    ; => Add magnetic field to struct.
;               add_scpot,dat,'sc_pot_3'      ; => Add spacecraft potential to struct.
;               ;;....................................................................
;               ;;  Plot contours of phase space density
;               ;;....................................................................
;               vec1     = dat.MAGF
;               vec2     = dat.VSW
;               vlim     = 25d2                ; => velocity range limit [km/s]
;               ngrid    = 20L                 ; => # of grids to use
;               dfra     = [1e-16,2e-10]       ; => define a range for contour levels
;               xname    = 'B'
;               yname    = 'Vsw'
;               contour_3d_1plane,dat,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,$
;                                     YNAME=yname,/SM_CUTS,NSMOOTH=3L,/ONE_C,     $
;                                     DFRA=dfra,VCIRC=7e2
;
;  KEYWORDS:    
;               VLIM       :  Limit for x-y velocity axes over which to plot data
;                               [Default = max vel. from energy bin values]
;               NGRID      :  # of isotropic velocity grids to use to triangulate the data
;                               [Default = 30L]
;               XNAME      :  Scalar string defining the name of vector associated with
;                               the VECTOR1 input
;                               [Default = 'X']
;               YNAME      :  Scalar string defining the name of vector associated with
;                               the VECTOR2 input
;                               [Default = 'Y']
;               SM_CUTS    :  If set, program plots the smoothed cuts of the DF
;                               [Default:  Not Smoothed]
;               NSMOOTH    :  Scalar # of points over which to smooth the DF
;                               [Default = 3]
;               ONE_C      :  If set, program makes a copy of the input array, redefines
;                               the data points equal to 1.0, and then calculates the 
;                               parallel cut and overplots it as the One Count Level
;               DFRA       :  2-Element array specifying a DF range (s^3/km^3/cm^3) for the
;                               cuts of the contour plot
;                               [Default = defined by range of data]
;               VCIRC      :  Scalar or array defining the value(s) to plot as a
;                               circle(s) of constant speed [km/s] on the contour
;                               plot [e.g. gyrospeed of specularly reflected ion]
;               EX_VEC0    :  3-Element unit vector for a quantity like heat flux or
;                               a wave vector, etc.
;               EX_VN0     :  A string name associated with EX_VEC0
;                               [Default = 'Vec 1']
;               EX_VEC1    :  3-Element unit vector for another quantity like the sun
;                               direction or shock normal vector vector, etc.
;               EX_VN1     :  A string name associated with EX_VEC1
;                               [Default = 'Vec 2']
;               NOKILL_PH  :  If set, program will not call pesa_high_bad_bins.pro for
;                               PESA High structures to remove "bad" data bins
;                               [Default = 0]
;               NO_REDF    :  If set, program will plot only cuts of the distribution,
;                               not quasi-reduced distributions
;                               [Default:  program plots quasi-reduced distributions]
;               PLANE      :  Scalar string defining the plane projection to plot with
;                               corresponding cuts [Let V1 = VECTOR1, V2 = VECTOR2]
;                                 'xy'  :  horizontal axis parallel to V1 and normal
;                                            vector to plane defined by (V1 x V2)
;                                            [default]
;                                 'xz'  :  horizontal axis parallel to (V1 x V2) and
;                                            vertical axis parallel to V1
;                                 'yz'  :  horizontal axis defined by (V1 x V2) x V1
;                                            and vertical axis (V1 x V2)
;               NO_TRANS   :  If set, routine will not transform data into SW frame
;                               [Default = 0 (i.e. DAT transformed into SW frame)]
;               INTERP     :  If set, data is interpolated to original energy estimates
;                               after transforming into new reference frame
;               SM_CONT    :  If set, program plots the smoothed contours of DF
;                               [Note:  Smoothed to the minimum # of points]
;               DFMIN      :  Scalar defining the minimum allowable phase space density
;                               to plot, which is useful for ion distributions with
;                               large angular gaps in data
;                               (prevents lower bound from falling below DFMIN)
;                               [Default = 1d-20]
;               DFMAX      :  Scalar defining the maximum allowable phase space density
;                               to plot, which is useful for distributions with data
;                               spikes
;                               (prevents upper bound from exceeding DFMAX)
;                               [Default = 1d-2]
;               DFSTR_OUT  :  Set to a named variable to return all the relevant data
;                               used to create the contour plot and cuts of the VDF
;
;   CHANGED:  1)  Fixed axis label typo for PLANE 'xz'             [02/10/2012   v1.0.1]
;             2)  Now removes energies < 1.3 * (SC Pot) and
;                   Added keywords:  INTERP and SM_CONT
;                                                                  [02/22/2012   v1.1.0]
;             3)  Changed maximum level of contours allowed        [03/14/2012   v1.1.1]
;             4)  Added keywords:  DFMIN and DFMAX and
;                   changed default minimum level of contours allowed and
;                   changed the number of minor tick marks
;                                                                  [03/29/2012   v1.2.0]
;             5)  Now calls test_wind_vs_themis_esa_struct.pro and no longer calls
;                   test_3dp_struc_format.pro                      [03/29/2012   v1.3.0]
;             6)  Fixed a typo dealing with VECTOR1 error handling that only
;                   affected output if the # of elements did not equal 3
;                                                                  [03/30/2012   v1.3.1]
;             7)  Changed thickness of projected lines and circles on contours and
;                   fixed the number of minor tick marks on plots and
;                   changed Vsw output and added % of vector in plane of projection
;                                                                  [04/17/2012   v1.3.2]
;             9)  Now outputs the SC Potential [eV], Vsw [km/s], and Bo [nT] used
;                   to create the distribution function plots and
;                   now includes error handling for version number errors
;                                                                  [07/09/2012   v1.4.0]
;            10)  Fixed an issue when using THEMIS ESA distributions and
;                   now uses arrows instead of lines for vector projections
;                                                                  [08/08/2012   v1.5.0]
;            11)  Fixed an issue that occurred when ONE_C was not set
;                                                                  [09/21/2012   v1.5.1]
;            12)  Now outputs crosshairs corresponding to where cuts were made and
;                   cleaned up some of the comments and now calls
;                   get_font_symbol.pro and get_color_by_name.pro
;                                                                  [10/23/2012   v1.6.0]
;            13)  Fixed an issue that occurred when user did not set NO_REDF and
;                   cleaned up a few things
;                                                                  [08/05/2013   v1.6.1]
;            14)  Fixed an issue that occurred when user did not set DFMIN or DFMAX and
;                   added DFSTR_OUT keyword and now calls get_os_slash.pro
;                                                                  [03/25/2015   v1.7.0]
;
;   NOTES:      
;               1)  Input structure, DAT, must have UNITS_NAME = 'Counts'
;               2)  see also:  eh_cont3d.pro, df_contours_3d.pro, and 
;                              df_htr_contours_3d.pro
;
;   CREATED:  02/09/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/25/2015   v1.7.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO contour_3d_1plane,dat,vector1,vector2,VLIM=vlim,NGRID=ngrid,XNAME=xname,YNAME=yname, $
                          SM_CUTS=sm_cuts,NSMOOTH=nsmooth,ONE_C=one_c,DFRA=dfra,         $
                          VCIRC=vcirc,EX_VEC0=ex_vec0,EX_VN0=ex_vn0,EX_VEC1=ex_vec1,     $
                          EX_VN1=ex_vn1,NOKILL_PH=nokill_ph,NO_REDF=no_redf,PLANE=plane, $
                          NO_TRANS=no_trans,INTERP=interpo,SM_CONT=sm_cont,              $
                          DFMIN=dfmin,DFMAX=dfmax,DFSTR_OUT=dfstr_out

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN

;;  Position of contour plot [square]
;;               Xo    Yo    X1    Y1
pos_0con       = [0.22941,0.515,0.77059,0.915]
;;  Position of 1st DF cuts [square]
pos_0cut       = [0.22941,0.050,0.77059,0.450]
;;  Define strings associated with a diamond and triangle for legend on plot
tri_str        = get_font_symbol('triangle')
dia_str        = get_font_symbol('diamond')
tri_str        = STRJOIN(REPLICATE(tri_str[0],3L),/SINGLE)
dia_str        = STRJOIN(REPLICATE(dia_str[0],3L),/SINGLE)
;;  Define default colors [byte]
blue           = get_color_by_name('blue')
red            = get_color_by_name('red')
;;  Define file path slash
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows

;;  Dummy plot labels
units_df       = '(sec!U3!N km!U-3!N cm!U-3!N'+')'
units_rdf      = '(sec!U2!N km!U-2!N cm!U-3!N'+')'
dumbytr        = 'quasi-reduced df '+units_rdf[0]
dumbytc        = 'cuts of df '+units_df[0]
suffc          = [' Cut',' Reduced DF']
cut_xttl       = 'Velocity (1000 km/sec)'
;;  Dummy error messages
noinpt_msg     = 'No input supplied...'
notstr_msg     = 'Must be an IDL structure...'
nofint_msg     = 'No finite data...'
nofred_msg     = 'No finite data in reduced distribution... Using regular cuts...'

;  LBW III  03/29/2012   v1.2.0
;lower_lim  = 1e-18  ; => Lowest expected value for DF
lower_lim      = 1e-20  ; => Lowest expected value for DF
upper_lim      = 1e-2   ; => Highest expected value for DF
;  LBW III  03/14/2012   v1.1.1
;upper_lim  = 1e-4   ; => Highest expected value for DF
;;  Dummy tick mark arrays
exp_val        = LINDGEN(50) - 50L                    ; => Array of exponent values
ytns           = '10!U'+STRTRIM(exp_val[*],2L)+'!N'   ; => Y-Axis tick names
ytvs           = 1d1^FLOAT(exp_val[*])                ; => Y-Axis tick values
;;  Defined user symbol for outputing locations of data on contour
xxo            = FINDGEN(17)*(!PI*2./16.)
USERSYM,0.27*COS(xxo),0.27*SIN(xxo),/FILL
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 1) THEN BEGIN
  ;;  no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  ;;  Create empty plot
  !P.MULTI = 0
  PLOT,[0.0,1.0],[0.0,1.0],/NODATA
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check DAT structure format
;;----------------------------------------------------------------------------------------
;  LBW III  03/29/2012   v1.3.0
;test       = test_3dp_struc_format(dat)
test0      = test_wind_vs_themis_esa_struct(dat,/NOM)
test       = (test0.(0) + test0.(1)) NE 1
IF (test) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  ;;  Create empty plot
  !P.MULTI = 0
  PLOT,[0.0,1.0],[0.0,1.0],/NODATA
  RETURN
ENDIF
;;  Define dummy data structure to avoid changing input
data       = dat[0]
IF KEYWORD_SET(one_c) THEN BEGIN
  onec         = data[0]
  onec[0].DATA = 1.0       ; => redefine all data points to 1 count
ENDIF

;;  Check which spacecraft is being used
;  LBW III  03/29/2012   v1.3.0
IF (test0.(0)) THEN BEGIN
  ;;-------------------------------------------
  ;; Wind
  ;;-------------------------------------------
  ;;  Check which instrument is being used
  strns   = dat_3dp_str_names(data[0])
  IF (SIZE(strns,/TYPE) NE 8) THEN BEGIN
    ;;  Create empty plot
    !P.MULTI = 0
    PLOT,[0.0,1.0],[0.0,1.0],/NODATA
    RETURN
  ENDIF
  shnme   = STRLOWCASE(STRMID(strns.SN[0],0L,2L))
  CASE shnme[0] OF
    'ph' : BEGIN
      ;;  Remove data glitch if necessary in PH data
      IF NOT KEYWORD_SET(nokill_ph) THEN BEGIN
        pesa_high_bad_bins,data
        IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
          pesa_high_bad_bins,onec
        ENDIF
      ENDIF
      convert_ph_units,data,'df'
      IF (SIZE(onec,/TYPE) EQ 8) THEN convert_ph_units,onec,'df'
    END
    ELSE : BEGIN
      data  = conv_units(data,'df')
      IF (SIZE(onec,/TYPE) EQ 8) THEN onec = conv_units(onec,'df')
    END
  ENDCASE
  ;;  Define contour plot title
  t_ttle     = data[0].PROJECT_NAME[0]
  t_ttle2    = STRTRIM(string_replace_char(t_ttle,'3D Plasma','3DP'),2L)
ENDIF ELSE BEGIN
  ;;-------------------------------------------
  ;; THEMIS
  ;;-------------------------------------------
  ;;  make sure the structure has been modified
  test_un = STRLOWCASE(data.UNITS_PROCEDURE) NE 'thm_convert_esa_units_lbwiii'
  IF (test_un) THEN BEGIN
    bad_in = 'If THEMIS ESA structures used, then they must be modified using modify_themis_esa_struc.pro'
    MESSAGE,bad_in[0],/INFORMATIONAL,/CONTINUE
    ;;  Create empty plot
    !P.MULTI = 0
    PLOT,[0.0,1.0],[0.0,1.0],/NODATA
    RETURN
  ENDIF
  ;;  structure modified appropriately so convert units
  data       = conv_units(data,'df')
  IF (SIZE(onec,/TYPE) EQ 8) THEN onec = conv_units(onec,'df')
  ;;  Define contour plot title
  t_ttle2    = data[0].PROJECT_NAME[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define contour plot title
;;----------------------------------------------------------------------------------------
htr_suff   = ' [3s MFI]'
title0     = t_ttle2[0]+' '+data[0].DATA_NAME[0]+htr_suff[0]
tra_s      = time_string([data.TIME,data.END_TIME])
tra_out    = tra_s[0]+' - '+STRMID(tra_s[1],11)
con_ttl    = title0+'!C'+tra_out
;;########################################################################################
;;  Define version for output
;;########################################################################################
;; Change the file path accordingly for your system
mdir     = FILE_EXPAND_PATH('.'+slash[0]+'wind_3dp_pros'+slash[0]+'LYNN_PRO')+slash[0]
file     = 'contour_3d_1plane.pro'
version  = routine_version(file,mdir)
;;----------------------------------------------------------------------------------------
;;  Check for finite vectors in VSW and MAGF IDL structure tags
;;----------------------------------------------------------------------------------------
v_vsws   = REFORM(data[0].VSW)
v_magf   = REFORM(data[0].MAGF)
test_v   = TOTAL(FINITE(v_vsws)) NE 3
test_b   = TOTAL(FINITE(v_magf)) NE 3

IF (test_b) THEN BEGIN
  ;;  MAGF values are not finite
  v_magf       = [1.,0.,0.]
  data[0].MAGF = v_magf
  bname        = 'X!DGSE!N'
ENDIF ELSE BEGIN
  ;;  MAGF values are okay
  bname        = 'B!Do!N'
ENDELSE

IF (test_v) THEN BEGIN
  ;;  VSW values are not finite
  v_vsws       = [0.,1.,0.]
  data[0].VSW  = v_vsws
  vname        = 'Y!DGSE!N'
  notran       = 1
ENDIF ELSE BEGIN
  ;;  VSW values are okay
  vname        = 'V!Dsw!N'
  IF NOT KEYWORD_SET(no_trans) THEN notran = 0 ELSE notran = no_trans[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;  LBW III  08/05/2013   v1.6.1
test           = (N_ELEMENTS(no_redf) EQ 0) OR ~KEYWORD_SET(no_redf)
IF (test) THEN noredf = 0       ELSE noredf = no_redf[0]
test           = (N_ELEMENTS(plane) EQ 0) OR (SIZE(plane,/TYPE) NE 7)
IF (test) THEN projxy = 'xy'    ELSE projxy = STRLOWCASE(plane[0])
test           = (N_ELEMENTS(sm_cont) EQ 0) OR ~KEYWORD_SET(sm_cont)
IF (test) THEN sm_con = 0       ELSE sm_con = 1
test           = (N_ELEMENTS(nsmooth) EQ 0) OR ~KEYWORD_SET(nsmooth)
IF (test) THEN ns     = 3       ELSE ns     = LONG(nsmooth)

;  LBW III  03/30/2012   v1.3.1
;IF (N_ELEMENTS(vector2) NE 3) THEN BEGIN
IF (N_ELEMENTS(vector1) NE 3) THEN BEGIN
  ;;  V1 is NOT set
  xname = bname[0]
  vec1  = v_magf
ENDIF ELSE BEGIN
  ;;  V1 is set
  IF NOT KEYWORD_SET(xname) THEN xname = 'X' ELSE xname = xname[0]
  vec1  = REFORM(vector1)
ENDELSE

IF (N_ELEMENTS(vector2) NE 3) THEN BEGIN
  ;;  V2 is NOT set
  yname = vname[0]
  vec2  = v_vsws
ENDIF ELSE BEGIN
  ;;  V2 is set
  IF NOT KEYWORD_SET(yname) THEN yname = 'Y' ELSE yname = yname[0]
  vec2  = REFORM(vector2)
ENDELSE

;;  Define # of levels to use for contour.pro
;  LBW III  08/05/2013   v1.6.1
test           = (N_ELEMENTS(ngrid) EQ 0) OR ~KEYWORD_SET(ngrid)
IF (test) THEN ngrid = 30L
;;  Define velocity limit (km/s)
test           = (N_ELEMENTS(vlim) EQ 0) OR ~KEYWORD_SET(vlim)
IF (test) THEN BEGIN
  vlim = MAX(SQRT(2*data[0].ENERGY/data[0].MASS),/NAN)
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Convert into solar wind frame
;;----------------------------------------------------------------------------------------
transform_vframe_3d,data,/EASY_TRAN,NO_TRANS=notran,INTERP=interpo
IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
  transform_vframe_3d,onec,/EASY_TRAN,NO_TRANS=notran,INTERP=interpo
ENDIF
;;----------------------------------------------------------------------------------------
;;  Calculate distribution function in rotated reference frame
;;----------------------------------------------------------------------------------------
rotate_3dp_structure,data,vec1,vec2,VLIM=vlim
;;  Define B-field at start of DF
magf_st = vec1
IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
  rotate_3dp_structure,onec,vec1,vec2,VLIM=vlim
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define plot parameters
;;----------------------------------------------------------------------------------------
xaxist = '(V dot '+xname[0]+') [1000 km/s]'
yaxist = '('+xname[0]+' x '+yname[0]+') x '+xname[0]+' [1000 km/s]'
zaxist = '('+xname[0]+' x '+yname[0]+') [1000 km/s]'
CASE projxy[0] OF
  'xy'  : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  plot Y vs. X
    ;;------------------------------------------------------------------------------------
    rmat   = data.ROT_MAT
    xttl00 = xaxist
    yttl00 = yaxist
    ;;  define data projection
    df2d   = data.DF2D_XY
    ;;  define actual velocities for contour plot
    vxpts  = data.VELX_XY
    vypts  = data.VELY_XY
    vzpts  = data.VELZ_XY
    IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
      ;;  define one-count projection and velocities
      df1c   = onec.DF2D_XY
      vx1c   = onec.VX2D
    ENDIF
    ;;  define elements [x,y]
    gels   = [0L,1L]
  END
  'xz'  : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  plot X vs. Z
    ;;------------------------------------------------------------------------------------
    rmat   = data.ROT_MAT
    xttl00 = zaxist
    yttl00 = xaxist
    ;;  define data projection
    df2d   = data.DF2D_XZ
    ;;  define actual velocities for contour plot
    vxpts  = data.VELX_XZ
    vypts  = data.VELY_XZ
    vzpts  = data.VELZ_XZ
    IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
      ;;  define one-count projection and velocities
      df1c   = onec.DF2D_XZ
      vx1c   = onec.VX2D
    ENDIF
    ;;  define elements [x,y]
    gels   = [2L,0L]
  END
  'yz'  : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  plot Z vs. Y
    ;;------------------------------------------------------------------------------------
    rmat   = data.ROT_MAT_Z
    xttl00 = yaxist
    yttl00 = zaxist
    ;;  define data projection
    df2d   = data.DF2D_YZ
    ;;  define actual velocities for contour plot
    vxpts  = data.VELX_YZ
    vypts  = data.VELY_YZ
    vzpts  = data.VELZ_YZ
    IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
      ;;  define one-count projection and velocities
      df1c   = onec.DF2D_YZ
      vx1c   = onec.VX2D
    ENDIF
    ;;  define elements [x,y]
    gels   = [0L,1L]
  END
  ELSE  : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  use default:  Y vs. X
    ;;------------------------------------------------------------------------------------
    rmat   = data.ROT_MAT
    xttl00 = xaxist
    yttl00 = yaxist
    ;;  define data projection
    df2d   = data.DF2D_XY
    ;;  define actual velocities for contour plot
    vxpts  = data.VELX_XY
    vypts  = data.VELY_XY
    vzpts  = data.VELZ_XY
    IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
      ;;  define one-count projection and velocities
      df1c   = onec.DF2D_XY
      vx1c   = onec.VX2D
    ENDIF
    ;;  define elements [x,y]
    gels   = [0L,1L]
  END
ENDCASE
;;  Define regularly gridded velocities for contour plot
vx2d   = data.VX2D
vy2d   = data.VY2D
;;----------------------------------------------------------------------------------------
;;  Define the 2D projection of the VSW IDL structure tag in DAT and other vectors
;;----------------------------------------------------------------------------------------
v_mfac   = (vlim[0]*95d-2)*1d-3
v_mag    = SQRT(TOTAL(v_vsws^2,/NAN))
IF (test_v EQ 0) THEN BEGIN
;  vswname = '- - - : '+vname[0]+' Projection'
  vxy_pro = REFORM(rmat ## v_vsws)/v_mag[0]
  vxy_per = SQRT(TOTAL(vxy_pro[gels]^2,/NAN))/SQRT(TOTAL(vxy_pro^2,/NAN))*1d2
  vswname = vname[0]+' ('+STRTRIM(STRING(vxy_per[0],FORMAT='(f10.1)'),2L)+'% in Plane)'
  vsw2d00 = vxy_pro[gels]/SQRT(TOTAL(vxy_pro[gels]^2,/NAN))*v_mfac[0]
  vsw2dx  = [0.,vsw2d00[0]]
  vsw2dy  = [0.,vsw2d00[1]]
ENDIF ELSE BEGIN
  vswname = ''
  vsw2dx  = REPLICATE(f,2)
  vsw2dy  = REPLICATE(f,2)
ENDELSE
;;  Check for EX_VEC0 and EX_VEC1
;  LBW III  08/05/2013   v1.6.1
test           = (N_ELEMENTS(ex_vec0) NE 3) OR ~KEYWORD_SET(ex_vec0)
IF (test) THEN evec0 = REPLICATE(f,3) ELSE evec0 = FLOAT(REFORM(ex_vec0))
test           = (N_ELEMENTS(ex_vec1) NE 3) OR ~KEYWORD_SET(ex_vec1)
IF (test) THEN evec1 = REPLICATE(f,3) ELSE evec1 = FLOAT(REFORM(ex_vec1))
;;  Define logic variables for output later
IF (TOTAL(FINITE(evec0)) NE 3) THEN out_v0 = 0 ELSE out_v0 = 1
IF (TOTAL(FINITE(evec1)) NE 3) THEN out_v1 = 0 ELSE out_v1 = 1
;  LBW III  08/05/2013   v1.6.1
test           = (N_ELEMENTS(ex_vn0) EQ 0) OR (SIZE(ex_vn0,/TYPE) NE 7)
IF (test) THEN vec0n = 'Vec 1' ELSE vec0n = ex_vn0[0]
test           = (N_ELEMENTS(ex_vn1) EQ 0) OR (SIZE(ex_vn1,/TYPE) NE 7)
IF (test) THEN vec1n = 'Vec 2' ELSE vec1n = ex_vn1[0]
;;  Rotate 1st extra vector
IF (out_v0) THEN BEGIN
  evec_0r  = REFORM(rmat ## evec0)/NORM(evec0)
  vec0_per = SQRT(TOTAL(evec_0r[gels]^2,/NAN))/SQRT(TOTAL(evec_0r^2,/NAN))*1d2
  vec0n    = vec0n[0]+' ('+STRTRIM(STRING(vec0_per[0],FORMAT='(f10.1)'),2L)+'% in Plane)'
ENDIF ELSE BEGIN
  evec_0r  = REPLICATE(f,3)
ENDELSE
;;  renormalize
evec_0r  = evec_0r/SQRT(TOTAL(evec_0r[gels]^2,/NAN))*v_mfac[0]
evec_0x  = [0.,evec_0r[gels[0]]]
evec_0y  = [0.,evec_0r[gels[1]]]
;;  Rotate 2nd extra vector
IF (out_v1) THEN BEGIN
  evec_1r  = REFORM(rmat ## evec1)/NORM(evec1)
  vec1_per = SQRT(TOTAL(evec_1r[gels]^2,/NAN))/SQRT(TOTAL(evec_1r^2,/NAN))*1d2
  vec1n    = vec1n[0]+' ('+STRTRIM(STRING(vec1_per[0],FORMAT='(f10.1)'),2L)+'% in Plane)'
ENDIF ELSE BEGIN
  evec_1r  = REPLICATE(f,3)
ENDELSE
;;  renormalize
evec_1r  = evec_1r/SQRT(TOTAL(evec_1r[gels]^2,/NAN))*v_mfac[0]
evec_1x  = [0.,evec_1r[gels[0]]]
evec_1y  = [0.,evec_1r[gels[1]]]

vc1_col  = 250L
vc2_col  =  50L
;;----------------------------------------------------------------------------------------
;;  Define dummy DF range of values
;;----------------------------------------------------------------------------------------
vel_2d   = (vx2d # vy2d)/vlim[0]
test_vr  = (ABS(vel_2d) LE 0.75*vlim[0])
test_df  = (df2d GT 0.) AND FINITE(df2d)
good     = WHERE(test_vr AND test_df,gd)
good2    = WHERE(test_df,gd2)
IF (gd GT 0) THEN BEGIN
  mndf  = MIN(ABS(df2d[good]),/NAN) > lower_lim[0]
  mxdf  = MAX(ABS(df2d[good]),/NAN) < upper_lim[0]
ENDIF ELSE BEGIN
  IF (gd2 GT 0) THEN BEGIN
    ;;  some finite data
    mndf  = MIN(ABS(df2d[good2]),/NAN) > lower_lim[0]
    mxdf  = MAX(ABS(df2d[good2]),/NAN) < upper_lim[0]
  ENDIF ELSE BEGIN
    ;;  no finite data
    MESSAGE,nofint_msg[0],/INFORMATIONAL,/CONTINUE
    ;;  Create empty plot
    !P.MULTI = 0
    PLOT,[0.0,1.0],[0.0,1.0],/NODATA
    RETURN
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define cuts
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(noredf) THEN BEGIN
  ;;  Cuts of DFs
  c_suff  = suffc[0]
  yttlct  = dumbytc[0]  ; => cut Y-Title
  ndf     = (SIZE(df2d,/DIMENSIONS))[0]/2L; + 1L
  ;;  Calculate Cuts of DFs
  dfpara  = REFORM(df2d[*,ndf[0]])                                  ; => Para. Cut of DF
  dfperp  = REFORM(df2d[ndf[0],*])                                  ; => Perp. Cut of DF
  IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
    ;;  Calculate one-count parallel Cut
    onec_para = REFORM(df1c[*,ndf[0]])
  ENDIF ELSE onec_para = REPLICATE(d,N_ELEMENTS(dfpara))
ENDIF ELSE BEGIN
  ;;  Quasi-Reduced DFs
  c_suff  = suffc[1]
  yttlct  = dumbytr[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Define volume element
  ;;--------------------------------------------------------------------------------------
  dvx     = (MAX(vx2d,/NAN) - MIN(vx2d,/NAN))/(N_ELEMENTS(vx2d) - 1L)
  dvy     = (MAX(vy2d,/NAN) - MIN(vy2d,/NAN))/(N_ELEMENTS(vy2d) - 1L)
  ;;  Calculate Quasi-Reduced DFs
  red_fx  = REFORM(!DPI*dvy[0]*(df2d # ABS(vy2d)))
  red_fy  = REFORM(!DPI*dvx[0]*(ABS(vx2d) # df2d))
  ;;--------------------------------------------------------------------------------------
  ;;  Normalize Quasi-Reduced DFs
  ;;--------------------------------------------------------------------------------------
  dfpara  = red_fx/( (TOTAL(FINITE(red_fx)) - 2d0)*MAX(ABS([vx2d,vy2d]),/NAN) )
  dfperp  = red_fy/( (TOTAL(FINITE(red_fy)) - 2d0)*MAX(ABS([vx2d,vy2d]),/NAN) )
;  dfpara  = red_fx/(TOTAL(FINITE(red_fx))*MAX(ABS([vx2d,vy2d]),/NAN))
;  dfperp  = red_fy/(TOTAL(FINITE(red_fy))*MAX(ABS([vx2d,vy2d]),/NAN))
  test_f0 = FINITE(dfpara) AND FINITE(dfperp)
  test_f1 = (dfpara GT 0.) AND (dfperp GT 0.)
  good    = WHERE(test_f0 AND test_f1,gd)
  ;;  Check dummy DF ranges
  IF (gd EQ 0)THEN BEGIN
    ;;  no finite data
    MESSAGE,nofred_msg[0],/INFORMATIONAL,/CONTINUE
    ;;------------------------------------------------------------------------------------
    ;;  Try again but use cuts only
    ;;------------------------------------------------------------------------------------
    ;;  Cuts of DFs
    c_suff  = suffc[0]
    yttlct  = dumbytc[0]  ; => cut Y-Title
    ndf     = (SIZE(df2d,/DIMENSIONS))[0]/2L; + 1L
    ;;  Calculate Cuts of DFs
    dfpara  = REFORM(df2d[*,ndf[0]])                                  ; => Para. Cut of DF
    dfperp  = REFORM(df2d[ndf[0],*])                                  ; => Perp. Cut of DF
    IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
      ;;  Calculate one-count parallel Cut
      onec_para = REFORM(df1c[*,ndf[0]])
    ENDIF ELSE onec_para = REPLICATE(d,N_ELEMENTS(dfpara))
;    ;;  Create empty plot
;    !P.MULTI = 0
;    PLOT,[0.0,1.0],[0.0,1.0],/NODATA
;    RETURN
  ENDIF ELSE BEGIN
    mxdf    = (mxdf[0] > MAX(ABS([dfpara[good],dfperp[good]]),/NAN)) < upper_lim[0]
    mndf    = (mndf[0] < MIN(ABS([dfpara[good],dfperp[good]]),/NAN)) > lower_lim[0]
    IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
      ;;  Calculate one-count parallel Quasi-Reduced DFs
      red_1cx   = REFORM(!DPI*dvy[0]*(df1c # ABS(vy2d)))
      onec_para = red_1cx/(TOTAL(FINITE(red_1cx))*MAX(ABS([vx2d,vy2d]),/NAN))
    ENDIF ELSE onec_para = REPLICATE(d,N_ELEMENTS(dfpara))
  ENDELSE
ENDELSE

;;  Smooth cuts if desired
IF KEYWORD_SET(sm_cuts) THEN BEGIN
  dfpars   = SMOOTH(dfpara,ns[0],/EDGE_TRUNCATE,/NAN)
  dfpers   = SMOOTH(dfperp,ns[0],/EDGE_TRUNCATE,/NAN)
  onec_par = SMOOTH(onec_para,ns[0],/EDGE_TRUNCATE,/NAN)
ENDIF ELSE BEGIN
  dfpars   = dfpara
  dfpers   = dfperp
  onec_par = onec_para
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define DF range and corresponding contour levels, colors, etc.
;;----------------------------------------------------------------------------------------
;;  LBW III  03/25/2015   v1.7.0
;;  Check if DFMIN is set
test           = (N_ELEMENTS(dfmin) NE 1) OR ~KEYWORD_SET(dfmin)
IF (test) THEN dfmin = lower_lim[0]
;;  Check if DFMAX is set
test           = (N_ELEMENTS(dfmax) NE 1) OR ~KEYWORD_SET(dfmax)
IF (test) THEN dfmax = upper_lim[0]
;;  LBW III  08/05/2013   v1.6.1
test           = (N_ELEMENTS(dfra) NE 2) OR ~KEYWORD_SET(dfra)
IF (test) THEN df_ran = [mndf[0],mxdf[0]]*[0.95,1.05] ELSE df_ran = dfra
;;  Check if DFMIN is set
test           = (N_ELEMENTS(dfmin) NE 1) OR ~KEYWORD_SET(dfmin)
IF (test) THEN df_ran[0] = df_ran[0] > dfmin[0]
;;  Check if DFMAX is set
test           = (N_ELEMENTS(dfmax) NE 1) OR ~KEYWORD_SET(dfmax)
IF (test) THEN df_ran[1] = df_ran[1] < dfmax[0]

range    = ALOG10(df_ran)
lg_levs  = DINDGEN(ngrid)*(range[1] - range[0])/(ngrid - 1L) + range[0]
levels   = 1d1^lg_levs
nlevs    = N_ELEMENTS(levels)
minclr   = 30L
c_cols   = minclr + LINDGEN(ngrid)*(250L - minclr)/(ngrid - 1L)
;;----------------------------------------------------------------------------------------
;;  Define plot limits structures
;;----------------------------------------------------------------------------------------
xyran    = [-1d0,1d0]*vlim[0]*1d-3
;;  structures for contour plot
lim_cn0  = {XRANGE:xyran,XSTYLE:1,XLOG:0,XTITLE:xttl00,XMINOR:10, $
            YRANGE:xyran,YSTYLE:1,YLOG:0,YTITLE:yttl00,YMINOR:10, $
            POSITION:pos_0con,TITLE:con_ttl,NODATA:1}
con_lim  = {OVERPLOT:1,LEVELS:levels,C_COLORS:c_cols}
;;  Define Y-Axis tick marks for cuts
goodyl   = WHERE(ytvs LE df_ran[1] AND ytvs GE df_ran[0],gdyl)
IF (gdyl LT 20 AND gdyl GT 0) THEN BEGIN
  ;;  structure for cuts plot with tick mark labels set
  lim_ct0  = {XRANGE:xyran, XSTYLE:1,XLOG:0,XTITLE:cut_xttl,XMINOR:10, $
              YRANGE:df_ran,YSTYLE:1,YLOG:1,YTITLE:yttlct,  YMINOR:9,  $
              POSITION:pos_0cut,TITLE:' ',NODATA:1,YTICKS:gdyl-1L,     $
              YTICKV:ytvs[goodyl],YTICKNAME:ytns[goodyl]}
ENDIF ELSE BEGIN
  ;;  structure for cuts plot without tick mark labels set
  lim_ct0  = {XRANGE:xyran, XSTYLE:1,XLOG:0,XTITLE:cut_xttl,XMINOR:10, $
              YRANGE:df_ran,YSTYLE:1,YLOG:1,YTITLE:yttlct,  YMINOR:9,  $
              POSITION:pos_0cut,TITLE:' ',NODATA:1}
ENDELSE

;;  Smooth contour if desired
IF KEYWORD_SET(sm_con) THEN BEGIN
  df2ds   = SMOOTH(df2d,3L,/EDGE_TRUNCATE,/NAN)
ENDIF ELSE BEGIN
  df2ds   = df2d
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Plot
;;----------------------------------------------------------------------------------------
!P.MULTI = [0,1,2]
IF (STRLOWCASE(!D.NAME) EQ 'ps') THEN l_thick  = 3 ELSE l_thick  = 2
;;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
PLOT,[0.0,1.0],[0.0,1.0],_EXTRA=lim_cn0
  ;;  Project locations of actual data points onto contour
  OPLOT,vxpts*1d-3,vypts*1d-3,PSYM=8,SYMSIZE=1.0,COLOR=100
  ;;--------------------------------------------------------------------------------------
  ;;  Draw contours
  ;;--------------------------------------------------------------------------------------
  CONTOUR,df2ds,vx2d*1d-3,vy2d*1d-3,_EXTRA=con_lim
    ;;------------------------------------------------------------------------------------
    ;;  Project V_sw onto contour
    ;;------------------------------------------------------------------------------------
    ARROW,vsw2dx[0],vsw2dy[0],vsw2dx[1],vsw2dy[1],/DATA,THICK=l_thick[0]
    xyposi = [-1d0*.94*vlim[0],0.94*vlim[0]]*1d-3
    IF (test_v EQ 0) THEN BEGIN
      XYOUTS,xyposi[0],xyposi[1],vswname[0],/DATA
      ;;  Shift in negative Y-Direction
      xyposi[1] -= 0.08*vlim*1d-3
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  Project 1st extra vector onto contour
    ;;------------------------------------------------------------------------------------
    ARROW,evec_0x[0],evec_0y[0],evec_0x[1],evec_0y[1],/DATA,THICK=l_thick[0],COLOR=vc1_col[0]
    IF (out_v0) THEN BEGIN
      XYOUTS,xyposi[0],xyposi[1],vec0n[0],/DATA,COLOR=vc1_col[0]
      ;;  Shift in negative Y-Direction
      xyposi[1] -= 0.08*vlim*1d-3
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  Project 2nd extra vector onto contour
    ;;------------------------------------------------------------------------------------
    ARROW,evec_1x[0],evec_1y[0],evec_1x[1],evec_1y[1],/DATA,THICK=l_thick[0],COLOR=vc2_col[0]
    IF (out_v1) THEN BEGIN
      XYOUTS,xyposi[0],xyposi[1],vec1n[0],/DATA,COLOR=vc2_col[0]
      ;;  Shift in negative Y-Direction
      xyposi[1] -= 0.08*vlim*1d-3
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  Project circle of constant speed onto contour
    ;;------------------------------------------------------------------------------------
    IF KEYWORD_SET(vcirc) THEN BEGIN
      n_circ = N_ELEMENTS(vcirc)
      thetas = DINDGEN(500)*2d0*!DPI/499L
      FOR j=0L, n_circ - 1L DO BEGIN
        vxcirc = vcirc[j]*1d-3*COS(thetas)
        vycirc = vcirc[j]*1d-3*SIN(thetas)
        OPLOT,vxcirc,vycirc,LINESTYLE=2,THICK=l_thick[0]
      ENDFOR
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  Project crosshairs onto contour
    ;;------------------------------------------------------------------------------------
    vx00 = [-1d0,1d0]*vlim[0]
    vy00 = [0d0,0d0]
    vx11 = [0d0,0d0]
    vy11 = [-1d0,1d0]*vlim[0]
    OPLOT,vx00,vy00,COLOR=red[0], THICK=l_thick[0]
    OPLOT,vx11,vy11,COLOR=blue[0],THICK=l_thick[0]
;;----------------------------------------------------------------------------------------
;;  Plot cuts of DF
;;----------------------------------------------------------------------------------------
PLOT,[0.0,1.0],[0.0,1.0],_EXTRA=lim_ct0
  ;;  Overplot point-by-point
  OPLOT,vx2d*1d-3,dfpars,COLOR=red[0], PSYM=4  ;; diamonds
  OPLOT,vy2d*1d-3,dfpers,COLOR=blue[0],PSYM=5  ;; triangles
;  ; => Plot point-by-point
;  OPLOT,vx2d*1d-3,dfpars,COLOR=250,PSYM=1
;  OPLOT,vy2d*1d-3,dfpers,COLOR= 50,PSYM=2
  ;;  Plot lines
  OPLOT,vx2d*1d-3,dfpars,COLOR=red[0], LINESTYLE=0
  OPLOT,vy2d*1d-3,dfpers,COLOR=blue[0],LINESTYLE=2
  ;;--------------------------------------------------------------------------------------
  ;;  Determine where to put labels
  ;;--------------------------------------------------------------------------------------
  fmin       = lim_ct0.YRANGE[0]
  xyposi     = [-1d0*4e-1*vlim[0]*1d-3,fmin[0]*4e0]
  ;;  Output label for para
  XYOUTS,xyposi[0],xyposi[1],dia_str[0]+' : Parallel Cut',/DATA,COLOR=red[0]
;  XYOUTS,xyposi[0],xyposi[1],'+++ : Parallel'+c_suff[0],/DATA,COLOR=250
  ;;  Shift in negative Y-Direction
  xyposi[1] *= 0.7
  ;;  Output label for perp
  XYOUTS,xyposi[0],xyposi[1],tri_str[0]+' : Perpendicular Cut',COLOR=blue[0],/DATA
;  XYOUTS,xyposi[0],xyposi[1],'*** : Perpendicular'+c_suff[0],COLOR=50,/DATA
  ;;--------------------------------------------------------------------------------------
  ;;  Plot 1-Count Level if desired
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
    OPLOT,vx1c*1d-3,onec_par,COLOR=150,LINESTYLE=4
    ;;  Shift in negative Y-Direction
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],'- - - : One-Count Level',COLOR=150,/DATA
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Plot vertical lines for circle of constant speed if desired
  ;;--------------------------------------------------------------------------------------
  IF KEYWORD_SET(vcirc) THEN BEGIN
    n_circ = N_ELEMENTS(vcirc)
    yras   = lim_ct0.YRANGE
    FOR j=0L, n_circ - 1L DO BEGIN
      OPLOT,[vcirc[j],vcirc[j]]*1d-3,yras,LINESTYLE=2,THICK=l_thick[0]
      OPLOT,-1d0*[vcirc[j],vcirc[j]]*1d-3,yras,LINESTYLE=2,THICK=l_thick[0]
    ENDFOR
  ENDIF
;;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;;----------------------------------------------------------------------------------------
;;  Output SC Potential [eV]
;;----------------------------------------------------------------------------------------
chsz        = 0.80
yposi       = 0.20
xposi       = 0.26
sc_pot_str  = STRTRIM(STRING(FORMAT='(f10.2)',data.SC_POT),2)
XYOUTS,xposi[0],yposi[0],'SC Potential : '+sc_pot_str[0]+' [eV]',/NORMAL,ORIENTATION=90,$
       CHARSIZE=chsz[0],COLOR=30L
;;----------------------------------------------------------------------------------------
;;  Output SW Velocity [km/s]
;;----------------------------------------------------------------------------------------
vsw_str     = STRTRIM(STRING(FORMAT='(f10.2)',v_vsws),2)
str_outv    = '<'+vsw_str[0]+','+vsw_str[1]+','+vsw_str[2]+'> [km/s]'
;str_out     = '<'+vsw_str[0]+','+vsw_str[1]+','+vsw_str[2]+'> [km/s]'
xposi      += 0.02
XYOUTS,xposi[0],yposi[0],'Vsw : '+str_outv[0],/NORMAL,ORIENTATION=90,$
       CHARSIZE=chsz[0],COLOR=30L
;;----------------------------------------------------------------------------------------
;;  Output Magnetic Field Vector [nT]  {at start of DF}
;;----------------------------------------------------------------------------------------
mag_str     = STRTRIM(STRING(FORMAT='(f10.2)',magf_st),2)
str_outm    = '<'+mag_str[0]+','+mag_str[1]+','+mag_str[2]+'> [nT]'
;str_out     = '<'+mag_str[0]+','+mag_str[1]+','+mag_str[2]+'> [nT]'
xposi      += 0.02
XYOUTS,xposi[0],yposi[0],'Bo : '+str_outm[0],/NORMAL,ORIENTATION=90,$
       CHARSIZE=chsz[0],COLOR=30L
;;----------------------------------------------------------------------------------------
;;  Output version # and date produced
;;----------------------------------------------------------------------------------------
XYOUTS,0.795,0.06,version[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.
;;----------------------------------------------------------------------------------------
;;  Define DFSTR_OUT output
;;----------------------------------------------------------------------------------------
;;  Define structures for contour of VDF
xyposi0        = [-1d0*.94*vlim[0],0.94*vlim[0]]*1d-3
tempvs         = {X:vsw2dx,Y:vsw2dy,XYPOSI:xyposi0,XYLAB:vswname[0],DATA:1}
xyposi0[1]    -= 0.08*vlim*1d-3
tempv0         = {X:evec_0x,Y:evec_0y,XYPOSI:xyposi0,XYLAB:vec0n[0],XYCOL:vc1_col,DATA:1}
xyposi0[1]    -= 0.08*vlim*1d-3
tempv1         = {X:evec_1x,Y:evec_1y,XYPOSI:xyposi0,XYLAB:vec1n[0],XYCOL:vc2_col,DATA:1}
tags           = ['VSW_ARROW','VEC_1_ARROW','VEC_2_ARROW']
arrow_str      = CREATE_STRUCT(tags,tempvs,tempv0,tempv1)
tags           = ['VXPTS','VYPTS','VXGRID','VYGRID','VDF_2D','ARROW_STR']
cont_data      = CREATE_STRUCT(tags,vxpts*1d-3,vypts*1d-3,vx2d*1d-3,vy2d*1d-3,df2ds,$
                                    arrow_str)
;;  Define structures for cuts of VDF
tags           = ['VPARA','CUT_PAR','COLOR','PSYM','LINESTYLE']
vdf_para       = CREATE_STRUCT(tags,vx2d*1d-3,dfpars,red,4,0)
tags           = ['VPERP','CUT_PER','COLOR','PSYM','LINESTYLE']
vdf_perp       = CREATE_STRUCT(tags,vy2d*1d-3,dfpers,blue,5,2)

fmin           = lim_ct0.YRANGE[0]
xyposi         = [-1d0*4e-1*vlim[0]*1d-3,fmin[0]*4e0]
tags           = ['XYPOSI','XYLAB','XYCOL','DATA']
para_xyout     = CREATE_STRUCT(tags,xyposi,dia_str[0]+' : Parallel Cut',red,1)
xyposi[1]     *= 0.7
perp_xyout     = CREATE_STRUCT(tags,xyposi,tri_str[0]+' : Perpendicular Cut',blue,1)
IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
  tags           = ['VPARA','CUT_PAR','COLOR','LINESTYLE']
  onec_vdf       = CREATE_STRUCT(tags,vx1c*1d-3,onec_par,150,4)
  tags           = ['XYPOSI','XYLAB','XYCOL','DATA']
  xyposi[1]     *= 0.7
  onec_xyout     = CREATE_STRUCT(tags,xyposi,'- - - : One-Count Level',150,1)
  tags_xyout     = ['PARA_LAB','PERP_LAB','ONEC_LAB']
  xyouts_str     = CREATE_STRUCT(tags_xyout,para_xyout,perp_xyout,onec_xyout)
  tags_cuts      = ['VDF_PAR','VDF_PER','ONEC_STR','XYOUTS']
  cuts_data      = CREATE_STRUCT(tags_cuts,vdf_para,vdf_perp,onec_vdf,xyouts_str)
ENDIF ELSE BEGIN
  tags_xyout     = ['PARA_LAB','PERP_LAB']
  xyouts_str     = CREATE_STRUCT(tags_xyout,para_xyout,perp_xyout)
  tags_cuts      = ['VDF_PAR','VDF_PER','XYOUTS']
  cuts_data      = CREATE_STRUCT(tags_cuts,vdf_para,vdf_perp,xyouts_str)
ENDELSE
;;  Define final XYOUTS info
chsz           = 0.80
yposi          = 0.20
xposi          = 0.26
tags_xy        = ['XYPOSI','XYLAB','XYCOL','XYORIENT','XYCHAR','XYNORMAL','XYDATA']
scpot_xy       = CREATE_STRUCT(tags_xy,[xposi,yposi],'SC Potential : '+sc_pot_str[0]+' [eV]',$
                                       30L,90,chsz,1,0)
xposi         += 0.02
vsw_xy         = CREATE_STRUCT(tags_xy,[xposi,yposi],'Vsw : '+str_outv[0],30L,90,chsz,1,0)
xposi         += 0.02
magf_xy        = CREATE_STRUCT(tags_xy,[xposi,yposi],'Bo : '+str_outm[0],30L,90,chsz,1,0)
vers_xy        = CREATE_STRUCT(tags_xy,[0.795,0.06],version[0],-1,90,0.65,1,0)
tags           = ['SCPOT_XY','VSW_XY','MAGF_XY','VERS_XY']
xyouts_str     = CREATE_STRUCT(tags,scpot_xy,vsw_xy,magf_xy,vers_xy)
;;  Define DFSTR_OUT
tags           = ['CONT_SETUP_LIM','CONT_LIM','CUTS_LIM','CONT_DATA','CUTS_DATA','XYOUTS']
dfstr_out      = CREATE_STRUCT(tags,lim_cn0,con_lim,lim_ct0,cont_data,cuts_data,xyouts_str)
;;----------------------------------------------------------------------------------------
;;  Return
;;----------------------------------------------------------------------------------------
!P.MULTI = 0

RETURN
END
