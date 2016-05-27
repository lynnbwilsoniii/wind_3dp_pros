;+
;*****************************************************************************************
;
;  PROCEDURE:   beam_fit_contour_plot.pro
;  PURPOSE  :   Produces a contour plot of a particle velocity distribution function (DF)
;                 with cuts, parallel and perpendicular to horizontal axis, at user
;                 specified velocity offsets.  The planes of projection are defined by
;                 the vectors associated with the structure tags VSW and MAGF, which
;                 correspond to the bulk flow velocity and the quasi-static magnetic
;                 field vector.  Note that the coordinate basis used for these two
;                 vectors must match the coordinate basis of the THETA and PHI
;                 structure tags, otherwise the rotations are meaningless.  The resultant
;                 contour plot does NOT assume gyrotropy, so the features in the DF may
;                 show anisotropies more clearly.
;
;  CALLED BY:   
;               beam_fit_1df_plot_fit.pro
;
;  CALLS:
;               get_font_symbol.pro
;               test_wind_vs_themis_esa_struct.pro
;               dat_3dp_str_names.pro
;               convert_ph_units.pro
;               conv_units.pro
;               string_replace_char.pro
;               time_string.pro
;               routine_version.pro
;               beam_fit_struc_common.pro
;               delete_variable.pro
;               beam_fit___get_common.pro
;               transform_vframe_3d.pro
;               rotate_3dp_structure.pro
;               find_dist_func_cuts.pro
;               get_color_by_name.pro
;               contour_vdf.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  Scalar data structure containing a particle velocity
;                               distribution function (DF) from either the Wind/3DP
;                               instrument [use get_??.pro, ?? = e.g. phb] or from
;                               the THEMIS ESA instruments.  Regardless, the structure
;                               must satisfy the criteria needed to produce a contour
;                               plot showing the phase (velocity) space density of the
;                               DF.  The structure must also have the following two tags
;                               with finite [3]-element vectors:  VSW and MAGF.
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               ***  INPUT  ***
;               VCIRC      :  Scalar(or array) [float/double] defining the value(s) to
;                               plot as a circle(s) of constant speed [km/s] on the
;                               contour plot [e.g. gyrospeed of specularly reflected ion]
;                               [Default = FALSE]
;               VB_REG     :  [4]-element array specifying the velocity coordinates
;                               [X0,Y0,X1,Y1] associated with a rectangular region
;                               that encompasses a "beam" to be overplotted onto the
;                               contour plot [km/s]
;               VC_XOFF    :  Scalar(or array) [float/double] defining the center of the
;                               circle(s) associated with VCIRC along the X-Axis
;                               (horizontal)
;                               [Default = 0.0]
;               VC_YOFF    :  Scalar(or array) [float/double] defining the center of the
;                               circle(s) associated with VCIRC along the Y-Axis
;                               (vertical)
;                               [Default = 0.0]
;               MODEL      :  Scalar [float/double] defining the model distribution cuts
;                               the user wishes to overplot onto the data cuts plot
;                               [format consistent with find_dist_func_cuts.pro output]
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
;               ONE_C      :  If set, program makes a copy of the input array, redefines
;                               the data points equal to 1.0, and then calculates the 
;                               parallel cut and overplots it as the One Count Level
;
;  KEYWORDS:    
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               PLOT_STR   :  Set to a named variable to return the scaling factors
;                               needed to allow the user to interactively select,
;                               using their cursor, the regions of interest on the
;                               contour plot.  This structure contains information
;                               necessary to convert from NORMAL to DATA coordinates,
;                               which will be used by region_cursor_select.pro
;               V_LIM_OUT  :  Set to a named variable to return the maximum speed [km/s]
;                               used for the velocity ranges in the contour and cut plots
;               DF_RA_OUT  :  Set to a named variable to return the [2]-element array
;                               defining the DF range of phase (velocity) space
;                               densities [cm^(-3) km^(-3) s^(3)] used for the contour
;                               levels and cut Y-Axis
;               DF_MN_OUT  :  Set to a named variable to return the scalar defining the
;                               minimum allowable phase (velocity) space density
;                               [cm^(-3) km^(-3) s^(3)] used for the contour levels
;                               and cut Y-Axis
;               DF_MX_OUT  :  Set to a named variable to return the scalar defining the
;                               maximum allowable phase (velocity) space density
;                               [cm^(-3) km^(-3) s^(3)] used for the contour levels
;                               and cut Y-Axis
;               DF_OUT     :  Set to a named variable to return the regularly gridded
;                               2D projection of the phase (velocity) space density
;                               [cm^(-3) km^(-3) s^(3)] plotted in the contour
;               DFPAR_OUT  :  Set to a named variable to return the parallel cut
;               DFPER_OUT  :  Set to a named variable to return the perpendicular cut
;               VPAR_OUT   :  Set to a named variable to return the parallel
;                               velocities [km/s]
;               VPER_OUT   :  Set to a named variable to return the perpendicular
;                               velocities [km/s]
;
;   CHANGED:  1)  Continued to write routine                       [08/20/2012   v1.0.0]
;             2)  Continued to write routine                       [08/21/2012   v1.0.0]
;             3)  Continued to write routine                       [08/22/2012   v1.0.0]
;             4)  Continued to write routine                       [08/23/2012   v1.0.0]
;             5)  Continued to write routine                       [08/24/2012   v1.0.0]
;             6)  Continued to write routine                       [08/25/2012   v1.0.0]
;             7)  Continued to write routine                       [08/27/2012   v1.0.0]
;             8)  Continued to write routine                       [08/28/2012   v1.0.0]
;             9)  Changed name to beam_fit_contour_plot.pro        [08/29/2012   v2.0.0]
;            10)  Changed how the routine handles input => now uses commonb block
;                   variables instead of keyword input
;                                                                  [08/31/2012   v2.1.0]
;            11)  Changed how the routine handles range of data to plot for the contour
;                   and cut plots;  Now DFRA forces the plot ranges while DFMIN and
;                   DFMAX will correspond to the PLOT.PRO keywords MIN_VALUE and
;                   MAX_VALUE, respectively
;                                                                  [09/01/2012   v2.1.1]
;            12)  Updated man page, cleaned up, and
;                   added keywords:  VCIRC and EX_VECN
;                                                                  [09/04/2012   v2.2.0]
;            13)  Continued to change routine                      [09/05/2012   v2.2.1]
;            14)  Continued to change routine                      [09/06/2012   v2.2.2]
;            15)  Fixed the rotation matrix used with XZ and YZ planes
;                                                                  [09/08/2012   v2.3.0]
;            16)  No longer smoothes the model fit cuts
;                                                                  [09/11/2012   v2.3.1]
;            17)  Cleaned up and added keyword:  ONE_C
;                                                                  [10/09/2012   v2.4.0]
;            18)  Now one-count structure copy uses updated Vsw values
;                                                                  [10/22/2012   v2.4.1]
;
;   NOTES:      
;               1)  IDL's routine, CONTOUR.PRO, considers NGRID only a suggestion,
;                     so do not be surprised if the result does not have exactly
;                     NGRID contours
;               2)  Input structure, DAT, must have the following tag values/properties:
;                   A)  UNITS_NAME    = 'Counts'
;                   B)  VSW and MAGF  = [3]-Element finite vectors with units of km/s
;                                       and nT, respectively
;                   C)  THETA and PHI = [E,A]-Element arrays in same basis as VSW and MAGF
;                                       in units of degrees
;                                       [E = # of energy bins, A = # of solid angle bins]
;                   D)  ENERGY        = [E,A]-Element array with units of eV
;                   E)  DATA          = [E,A]-Element array with units of counts
;               3)  Input structure, DAT, must be consistent with either Wind/3DP or
;                     THEMIS ESA velocity data structures
;               4)  *** The keyword ANGLE is not well tested yet ***
;               5)  User should NOT call this routine
;               6)  See also:  contour_3d_1plane.pro, contour_3d_htr_1plane.pro, or
;                     contour_esa_htr_1plane.pro
;
;   ADAPTED FROM:  contour_3d_1plane.pro
;   CREATED:  08/18/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/22/2012   v2.4.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO beam_fit_contour_plot,dat,VCIRC=vcirc,VB_REG=vb_reg,VC_XOFF=vc_xoff,VC_YOFF=vc_yoff,$
                              MODEL=model,EX_VECN=ex_vecn,ONE_C=one_c,                  $
                              PLOT_STR=plot_str,V_LIM_OUT=vlim_out,DF_RA_OUT=dfra_out,  $
                              DF_MN_OUT=dfmin_out,DF_MX_OUT=dfmax_out,DF_OUT=df_out,    $
                              DFPAR_OUT=dfpar_out,DFPER_OUT=dfper_out,VPAR_OUT=vpar_out,$
                              VPER_OUT=vper_out

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
noinpt_msg     = 'No input supplied...'
notstr_msg     = 'Must be an IDL structure...'
nofint_msg     = 'No finite data...'
novbtags_msg   = 'VSW and MAGF must be defined as [3]-element vectors...'

;; => Position of contour plot [square]
;;               Xo    Yo    X1    Y1
pos_0con       = [0.22941,0.515,0.77059,0.915]
;; => Position of 1st DF cuts [square]
pos_0cut       = [0.22941,0.050,0.77059,0.450]
;; => Dummy plot labels
units_df       = '(sec!U3!N km!U-3!N cm!U-3!N'+')'
units_rdf      = '(sec!U2!N km!U-2!N cm!U-3!N'+')'
dumbytr        = 'quasi-reduced df '+units_rdf[0]
dumbytc        = 'cuts of df '+units_df[0]
suffc          = [' Cut',' Reduced DF']
cut_xttl       = 'Velocity (1000 km/sec)'
;; => Define strings associated with a diamond and triangle for legend on plot
tri_str        = get_font_symbol('triangle')
dia_str        = get_font_symbol('diamond')
tri_str        = STRJOIN(REPLICATE(tri_str[0],3L),/SINGLE)
dia_str        = STRJOIN(REPLICATE(dia_str[0],3L),/SINGLE)

;; hard code labels
yttlct         = dumbytc[0]  ;; => cut Y-Title
c_suff         = suffc[0]

lower_lim      = 1e-20  ;; => Lowest expected value for DF
upper_lim      = 1e-2   ;; => Highest expected value for DF
;; => Dummy tick mark arrays
exp_val        = LINDGEN(50) - 50L                    ;; => Array of exponent values
ytns           = '10!U'+STRTRIM(exp_val[*],2L)+'!N'   ;; => Y-Axis tick names
ytvs           = 1d1^FLOAT(exp_val[*])                ;; => Y-Axis tick values
;; => Defined user symbol for outputing locations of data on contour
xxo            = FINDGEN(17)*(!PI*2./16.)
USERSYM,0.27*COS(xxo),0.27*SIN(xxo),/FILL
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(dat)  EQ 0) OR (N_PARAMS() NE 1)
IF (test) THEN BEGIN
  ;; => no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  ;; => Create empty plot
  !P.MULTI = 0
  PLOT,[0.0,1.0],[0.0,1.0],/NODATA
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;; => Check DAT structure format
;;----------------------------------------------------------------------------------------
test0          = test_wind_vs_themis_esa_struct(dat,/NOM)
test           = (test0.(0) + test0.(1)) NE 1
IF (test) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  ;; => Create empty plot
  !P.MULTI = 0
  PLOT,[0.0,1.0],[0.0,1.0],/NODATA
  RETURN
ENDIF
;; => Define dummy data structure to avoid changing input
data           = dat[0]
IF KEYWORD_SET(one_c) THEN BEGIN
  onec         = data[0]
  onec[0].DATA = 1.0       ; => redefine all data points to 1 count
ENDIF
;;----------------------------------------------------------------------------------------
;; => Check which spacecraft is being used
;;----------------------------------------------------------------------------------------
IF (test0.(0)) THEN BEGIN
  ;-------------------------------------------
  ; Wind
  ;-------------------------------------------
  ; => Check which instrument is being used
  strns   = dat_3dp_str_names(data[0])
  IF (SIZE(strns,/TYPE) NE 8) THEN BEGIN
    ; => Create empty plot
    !P.MULTI = 0
    PLOT,[0.0,1.0],[0.0,1.0],/NODATA
    RETURN
  ENDIF
  shnme   = STRLOWCASE(STRMID(strns.SN[0],0L,2L))
  CASE shnme[0] OF
    'ph' : BEGIN
      convert_ph_units,data,'df'
      IF (SIZE(onec,/TYPE) EQ 8) THEN convert_ph_units,onec,'df'
    END
    ELSE : BEGIN
      data  = conv_units(data,'df')
      IF (SIZE(onec,/TYPE) EQ 8) THEN onec = conv_units(onec,'df')
    END
  ENDCASE
  ;; => Define contour plot title
  t_ttle     = data[0].PROJECT_NAME[0]
  t_ttle2    = STRTRIM(string_replace_char(t_ttle,'3D Plasma','3DP'),2L)
ENDIF ELSE BEGIN
  ;-------------------------------------------
  ; THEMIS
  ;-------------------------------------------
  ; => make sure the structure has been modified
  test_un = STRLOWCASE(data.UNITS_PROCEDURE) NE 'thm_convert_esa_units_lbwiii'
  IF (test_un) THEN BEGIN
    bad_in = 'If THEMIS ESA structures used, then they must be modified using modify_themis_esa_struc.pro'
    MESSAGE,bad_in[0],/INFORMATIONAL,/CONTINUE
    ; => Create empty plot
    !P.MULTI = 0
    PLOT,[0.0,1.0],[0.0,1.0],/NODATA
    RETURN
  ENDIF
  ; => structure modified appropriately so convert units
  data       = conv_units(data,'df')
  IF (SIZE(onec,/TYPE) EQ 8) THEN onec = conv_units(onec,'df')
  ;; => Define contour plot title
  t_ttle2    = data[0].PROJECT_NAME[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Define contour plot title
;;----------------------------------------------------------------------------------------
htr_suff       = ' [3s MFI]'
title0         = t_ttle2[0]+' '+data[0].DATA_NAME[0]+htr_suff[0]
tra_s          = time_string([data.TIME,data.END_TIME])
tra_out        = tra_s[0]+' - '+STRMID(tra_s[1],11)
con_ttl        = title0+'!C'+tra_out  ;; contour plot title
;;########################################################################################
;; => Define version for output
;;########################################################################################
mdir           = FILE_EXPAND_PATH('wind_3dp_pros/LYNN_PRO/beam_fitting_routines/')+'/'
file           = 'beam_fit_contour_plot.pro'
version        = routine_version(file,mdir)
;;----------------------------------------------------------------------------------------
;; => Load Common Block Variables
;;----------------------------------------------------------------------------------------
dumb           = beam_fit_struc_common(DEFINED=define_arr)
IF (SIZE(dumb,/TYPE) EQ 8) THEN BEGIN
  ntags          = N_TAGS(dumb)
  tag_n          = STRLOWCASE(TAG_NAMES(dumb))
  FOR j=0L, ntags - 1L DO BEGIN
    ;; Clean up before starting new cycle
    delete_variable,nval,defined
    ;; Define parameter
    nval           = dumb.(j[0])
    ;; Determine which it corresponds to
    CASE tag_n[j] OF
      'vlim'     :  BEGIN
        ;; => VLIM
        vlim       = nval[0]
        IF (define_arr[j] EQ 0) THEN BEGIN
          ;; => If not set, then get defaults
          vlim       = beam_fit___get_common('def_vlim',DEFINED=defined)
        ENDIF
      END
      'ngrid'    :  BEGIN
        ;; => NGRID
        ngrid      = nval[0]
        IF (define_arr[j] EQ 0) THEN BEGIN
          ;; => If not set, then get defaults
          ngrid      = beam_fit___get_common('def_ngrid',DEFINED=defined)
        ENDIF
      END
      'nsmooth'  :  BEGIN
        ;; => NSMOOTH
        nsmooth    = nval[0]
        IF (define_arr[j] EQ 0) THEN BEGIN
          ;; => If not set, then get defaults
          nsmooth    = beam_fit___get_common('def_nsmth',DEFINED=defined)
        ENDIF
      END
      'sm_cuts'  :  BEGIN
        ;; => SM_CUTS
        sm_cuts    = nval[0]
        IF (define_arr[j] EQ 0) THEN sm_cuts = 0
      END
      'sm_cont'  :  BEGIN
        ;; => SM_CONT
        sm_cont    = nval[0]
        IF (define_arr[j] EQ 0) THEN sm_cont = 0
      END
      'dfra'     :  BEGIN
        ;; => DFRA
        dfra       = nval
        IF (define_arr[j] EQ 0) THEN delete_variable,dfra
      END
      'dfmin'    :  BEGIN
        ;; => DFMIN
        dfmin      = nval[0]
        IF (define_arr[j] EQ 0) THEN BEGIN
          ;; => If not set, then get defaults
          dfmin      = beam_fit___get_common('def_dfmin',DEFINED=defined)
        ENDIF
      END
      'dfmax'    :  BEGIN
        ;; => DFMAX
        dfmax      = nval[0]
        IF (define_arr[j] EQ 0) THEN BEGIN
          ;; => If not set, then get defaults
          dfmax      = beam_fit___get_common('def_dfmax',DEFINED=defined)
        ENDIF
      END
      'plane'    :  BEGIN
        ;; => PLANE
        plane      = nval[0]
        IF (define_arr[j] EQ 0) THEN BEGIN
          ;; => If not set, then get defaults
          plane      = beam_fit___get_common('def_plane',DEFINED=defined)
        ENDIF
      END
      'angle'    :  BEGIN
        ;; => ANGLE
        angle      = nval[0]
        IF (define_arr[j] EQ 0) THEN angle = 0.
      END
      'vsw'      :  BEGIN
        ;; => VSW
        ;;    [LBW III  09/05/2012   v2.2.1]
        vsw        = REFORM(data[0].VSW)
        IF (TOTAL(FINITE(vsw)) NE 3) THEN BEGIN
          ;; Not defined in structure
          vsw        = nval
          IF (define_arr[j] EQ 0 OR TOTAL(FINITE(vsw)) NE 3) THEN BEGIN
            ;; => VSW not defined
            MESSAGE,novbtags_msg[0],/INFORMATIONAL,/CONTINUE
            ;; => Create empty plot
            !P.MULTI = 0
            PLOT,[0.0,1.0],[0.0,1.0],/NODATA
            RETURN
          ENDIF
        ENDIF
      END
      'vcmax'    :  BEGIN
        ;; => VCMAX [= VCIRC]
        IF (N_ELEMENTS(vcirc) EQ 0)  THEN vcirc = nval[0]
        ;; => If not set, then undefine
        test       = (define_arr[j] EQ 0) AND (N_ELEMENTS(vcirc) EQ 0)
        IF (test) THEN delete_variable,vcirc
      END
      'v_bx'     :  BEGIN
        ;; => V_BX
        v_bx       = nval[0]
        ;; => If not set, then undefine
        IF (define_arr[j] EQ 0) THEN delete_variable,v_bx
      END
      'v_by'     :  BEGIN
        ;; => V_BY
        v_by       = nval[0]
        ;; => If not set, then undefine
        IF (define_arr[j] EQ 0) THEN delete_variable,v_by
      END
      ;;----------------------------------------------------------------------------------
      ;; => Otherwise do nothing
      ;;----------------------------------------------------------------------------------
      ELSE :
    ENDCASE
  ENDFOR
ENDIF
;;----------------------------------------------------------------------------------------
;; => Check for finite vectors in VSW and MAGF IDL structure tags
;;----------------------------------------------------------------------------------------
v_vsws         = vsw
v_magf         = REFORM(data[0].MAGF)
test_v         = TOTAL(FINITE(v_vsws)) NE 3
test_b         = TOTAL(FINITE(v_magf)) NE 3
test           = test_b OR test_v
IF (test) THEN BEGIN
  ;; => VSW and/or MAGF not defined
  MESSAGE,novbtags_msg[0],/INFORMATIONAL,/CONTINUE
  ;; => Create empty plot
  !P.MULTI = 0
  PLOT,[0.0,1.0],[0.0,1.0],/NODATA
  RETURN
ENDIF
;; => VSW and MAGF values are okay
vec1           = v_magf
vec2           = v_vsws
xname          = 'B!Do!N'
yname          = 'V!Dsw!N'
;;----------------------------------------------------------------------------------------
;; => Check keywords
;;----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(plane)    THEN projxy = 'xy'           ELSE projxy = STRLOWCASE(plane[0])
test           = ((projxy[0] EQ 'xy') OR (projxy[0] EQ 'xz') OR (projxy[0] EQ 'yz')) EQ 0
IF (test)                    THEN projxy = 'xy'
IF NOT KEYWORD_SET(sm_cuts)  THEN sm_cut = 0              ELSE sm_cut = 1
IF NOT KEYWORD_SET(sm_cont)  THEN sm_con = 0              ELSE sm_con = 1
IF NOT KEYWORD_SET(nsmooth)  THEN ns     = 3              ELSE ns     = LONG(nsmooth)
IF (N_ELEMENTS(v_bx)  NE 1)  THEN vox    = 0d0            ELSE vox    = v_bx[0]
IF (N_ELEMENTS(v_by)  NE 1)  THEN voy    = 0d0            ELSE voy    = v_by[0]
IF (N_ELEMENTS(angle) NE 1)  THEN ang    = 0d0            ELSE ang    = angle[0]

;; => Define # of levels to use for contour.pro
IF NOT KEYWORD_SET(ngrid)    THEN nlevs  = 30L            ELSE nlevs  = ngrid[0]
;; => Define velocity limit (km/s)
IF NOT KEYWORD_SET(vlim) THEN BEGIN
  xran = MAX(SQRT(2*data[0].ENERGY/data[0].MASS),/NAN)
ENDIF ELSE BEGIN
  xran = FLOAT(vlim[0])
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Convert DAT into bulk flow frame
;;----------------------------------------------------------------------------------------
transform_vframe_3d,data,/EASY_TRAN
IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
  onec[0].VSW = v_vsws                  ;; make sure using updated Vsw
  transform_vframe_3d,onec,/EASY_TRAN
ENDIF
;;----------------------------------------------------------------------------------------
;; => Rotate DAT into new reference frame
;;----------------------------------------------------------------------------------------
rotate_3dp_structure,data,vec1,vec2,VLIM=xran[0]
;; => Define B-field at start of DF
magf_st        = vec1
IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
  rotate_3dp_structure,onec,vec1,vec2,VLIM=xran[0]
ENDIF
;;----------------------------------------------------------------------------------------
;; => Define plot parameters
;;----------------------------------------------------------------------------------------
tag_pref       = ['DF2D','VELX','VELY','TR','VX_GRID','VY_GRID','GOOD_IND']
;;  Define suffix for structure tags
tagsuf         = '_'+STRUPCASE(projxy[0])
IF (projxy[0] EQ 'xz') THEN gels = [2L,0L,1L]     ELSE gels = [0L,1L,2L]
IF (projxy[0] EQ 'yz') THEN rmat = data.ROT_MAT_Z ELSE rmat = data.ROT_MAT

all_tags       = STRLOWCASE(TAG_NAMES(data))
tags           = STRLOWCASE(tag_pref+tagsuf[0])
FOR j=0L, N_ELEMENTS(tags) - 1L DO BEGIN
  good = WHERE(all_tags EQ tags[j],gd)
  ;; => Define data projection for contour plot
  IF (j EQ 0) THEN df2d    = data.(good[0])  ;; => define data projection
  IF (SIZE(onec,/TYPE) EQ 8 AND j EQ 0) THEN BEGIN
    df2d1c  = onec.(good[0])
  ENDIF
  ;; => Define actual velocities for contour plot
  IF (j EQ 1) THEN vxpts   = data.(good[0])  ;; => define actual X-velocities
  IF (j EQ 2) THEN vypts   = data.(good[0])  ;; => define actual Y-velocities
  IF (j EQ 3) THEN trian   = data.(good[0])  ;; => define triangle vertices
  ;; => Define regularly gridded velocities for contour plot
  IF (j EQ 4) THEN vx2d    = data.(good[0])  ;; => define gridded X-velocities
  IF (j EQ 5) THEN vy2d    = data.(good[0])  ;; => define gridded Y-velocities
  IF (j EQ 6) THEN gind    = data.(good[0])  ;; => define good indices
ENDFOR
;;----------------------------------------------------------------------------------------
;; => Define the 2D projection of the VSW IDL structure tag in DAT and other vectors
;;----------------------------------------------------------------------------------------
v_mfac         = (xran[0]*95d-2)*1d-3
v_mag          = SQRT(TOTAL(v_vsws^2,/NAN))
vxy_pro        = REFORM(rmat ## v_vsws)/v_mag[0]  ;; normalized and rotated
;; define percentage in user specified plane
vxy_per        = SQRT(TOTAL(vxy_pro[gels[0:1]]^2,/NAN))/SQRT(TOTAL(vxy_pro^2,/NAN))*1d2
;; define string output of percentage in user specified plane
vswname        = yname[0]+' ('+STRTRIM(STRING(vxy_per[0],FORMAT='(f10.1)'),2L)+'% in Plane)'
vsw2d00        = vxy_pro[gels[0:1]]/SQRT(TOTAL(vxy_pro[gels[0:1]]^2,/NAN))*v_mfac[0]
;; define vectors to project
vsw2dx         = [0.,vsw2d00[0]]
vsw2dy         = [0.,vsw2d00[1]]
;;----------------------------------------------------------------------------------------
;; => Check for other vectors
;;----------------------------------------------------------------------------------------
tags_exv       = ['VEC','NAME']
ex_vec0        = CREATE_STRUCT(tags_exv,vsw2d00,vswname[0])
test           = (SIZE(ex_vecn,/TYPE) EQ 8)
IF (test) THEN BEGIN
  ;;  User supplied extra vectors to project onto contour
  ;;    => Check EX_VECN structure format
  nexvc          = N_ELEMENTS(ex_vecn)
  tagnm          = STRLOWCASE(TAG_NAMES(ex_vecn[0]))
  ntag           = N_TAGS(ex_vecn[0])
  testn          = (ntag NE N_ELEMENTS(tags_exv))  ;;  TRUE --> incorrect # of tags
  testt          = TOTAL(tagnm EQ STRLOWCASE(tags_exv)) NE N_ELEMENTS(tags_exv)
  teste          = testn OR testt
  IF (teste) THEN BEGIN
    ;;  User supplied extra vector structure had incorrect format
    ;;    => use ONLY Vsw
    ex_vecs        = ex_vec0
  ENDIF ELSE BEGIN
    ;;  User supplied extra vector structure had correct format
    IF (nexvc GT 7L) THEN ex_vec = ex_vecn[0L:6L] ELSE ex_vec = ex_vecn
    nexvc          = N_ELEMENTS(ex_vec)
    ex_vecs        = ex_vec0[0]
    FOR j=0L, nexvc - 1L DO BEGIN
      k              = j + 1L
      jstr           = STRTRIM(STRING(j[0],FORMAT='(I1.1)'),2L)
      vec0           = REFORM(ex_vec[j].VEC)
      name0          = ex_vec[j].NAME
      ;; Check name type
      IF (SIZE(name0[0],/TYPE) EQ 7) THEN name1 = name0[0] ELSE name1 = 'V!D'+jstr[0]+'!N'
      ;; Check vector format
      IF (N_ELEMENTS(vec0) EQ 3) THEN BEGIN
        ;;  Calculate total magnitude
        rnmagt         = SQRT(TOTAL(ABS(vec0)^2,/NAN))
        ;;  Rotate and normalize vectors
        rnvec0         = REFORM(rmat ## vec0)/rnmagt[0]  ;; normalized and rotated
        ;;  Calculate magnitude in plane
        rnmag_ip       = SQRT(TOTAL(rnvec0[gels[0:1]]^2,/NAN))
        ;;  Calculate % in plane
        rnvec_perc     = (rnmag_ip[0]/SQRT(TOTAL(rnvec0^2,/NAN)))*1d2
        ;;  Renormalize vector
        rrnvec0        = (rnvec0[gels[0:1]]/rnmag_ip[0])*v_mfac[0]
        ;;  Define output string
        out_string     = name1[0]+' ('+STRTRIM(STRING(rnvec_perc[0],FORMAT='(f10.1)'),2L)+'% in Plane)'
        ;;  Define structure element
        struc_0        = CREATE_STRUCT(tags_exv,rrnvec0,out_string[0])
        ;;  Add to arrow structure
        ex_vecs        = [ex_vecs,struc_0]
      ENDIF
    ENDFOR
  ENDELSE
ENDIF ELSE BEGIN
  ;;  User supplied no extra vectors to project onto contour
  ex_vecs        = ex_vec0[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Define dummy DF range of values
;;----------------------------------------------------------------------------------------
;; => Check if DFMIN and DFMAX are set
test           = (N_ELEMENTS(dfmin) EQ 0) AND (N_ELEMENTS(dfmax) EQ 0)
IF (test) THEN BEGIN
  ;; How did this happen???
  def_dfmin      = beam_fit___get_common('def_dfmin',DEFINED=defined_0)
  def_dfmax      = beam_fit___get_common('def_dfmax',DEFINED=defined_1)
  IF (defined_0 EQ 0) THEN def_dfmin      = 1d-18
  IF (defined_1 EQ 0) THEN def_dfmax      = 1d-2
  IF ~KEYWORD_SET(dfmin) THEN dfmin = def_dfmin
  IF ~KEYWORD_SET(dfmax) THEN dfmax = def_dfmax
ENDIF
IF KEYWORD_SET(dfmin) THEN low__range = dfmin[0] ELSE low__range = lower_lim[0]
IF KEYWORD_SET(dfmax) THEN high_range = dfmax[0] ELSE high_range = upper_lim[0]
;; => Determine plot ranges
vel_2d   = (vx2d # vy2d)/xran[0]
test_vr  = (ABS(vel_2d) LE 0.75*xran[0])
test_df  = (df2d GT 0.) AND FINITE(df2d)
good     = WHERE(test_vr AND test_df,gd)
good2    = WHERE(test_df,gd2)
IF (gd GT 0) THEN BEGIN
  mndf  = MIN(ABS(df2d[good]),/NAN) > low__range[0]
  mxdf  = MAX(ABS(df2d[good]),/NAN) < high_range[0]
ENDIF ELSE BEGIN
  IF (gd2 GT 0) THEN BEGIN
    ;; => some finite data
    mndf  = MIN(ABS(df2d[good2]),/NAN) > low__range[0]
    mxdf  = MAX(ABS(df2d[good2]),/NAN) < high_range[0]
  ENDIF ELSE BEGIN
    ;; => no finite data
    MESSAGE,nofint_msg[0],/INFORMATIONAL,/CONTINUE
    ;; => Create empty plot
    !P.MULTI = 0
    PLOT,[0.0,1.0],[0.0,1.0],/NODATA
    RETURN
  ENDELSE
ENDELSE
;; => Define plot ranges
test           = (N_ELEMENTS(dfra) EQ 0)
IF (test) THEN df_ran = [mndf[0],mxdf[0]]*[0.95,1.05] ELSE df_ran = dfra
;;----------------------------------------------------------------------------------------
;; => Define cuts of DF
;;----------------------------------------------------------------------------------------
cut_str        = find_dist_func_cuts(df2d,vx2d,vy2d,V_0X=vox[0],V_0Y=voy[0],ANGLE=ang[0])
dfpara         = cut_str.DF_PARA
dfperp         = cut_str.DF_PERP
v_c_para       = cut_str.V_CUT_PARA
v_c_perp       = cut_str.V_CUT_PERP
;; => Smooth cuts if desired
IF KEYWORD_SET(sm_cuts) THEN BEGIN
  dfpars   = SMOOTH(dfpara,ns[0],/EDGE_TRUNCATE,/NAN)
  dfpers   = SMOOTH(dfperp,ns[0],/EDGE_TRUNCATE,/NAN)
ENDIF ELSE BEGIN
  dfpars   = dfpara
  dfpers   = dfperp
ENDELSE
;; => Smooth contour if desired
;;    [LBW III  09/06/2012   v2.2.2]
sz             = SIZE(df2d,/DIMENSIONS)
df2ds          = df2d
IF KEYWORD_SET(sm_con) THEN ns_con = ns[0] ELSE ns_con = 3L
df2ds          = SMOOTH(df2d,ns_con[0],/EDGE_TRUNCATE,/NAN)
;;----------------------------------------------
;;  Perform the same on one-count levels
;;----------------------------------------------
IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
  one_cut        = find_dist_func_cuts(df2d1c,vx2d,vy2d,V_0X=0d0,V_0Y=0d0,ANGLE=0d0)
  onc_para       = one_cut.DF_PARA
  v1c_para       = one_cut.V_CUT_PARA
  ;; => Smooth cuts if desired
  IF KEYWORD_SET(sm_cuts) THEN BEGIN
    onc_paras   = SMOOTH(onc_para,ns[0],/EDGE_TRUNCATE,/NAN)
  ENDIF ELSE BEGIN
    onc_paras   = onc_para
  ENDELSE
ENDIF
;;----------------------------------------------------------------------------------------
;; => Define output keywords
;;----------------------------------------------------------------------------------------
vlim_out       = xran[0]
dfra_out       = df_ran
dfmin_out      = df_ran[0]
dfmax_out      = df_ran[1]
dfpar_out      = dfpars
dfper_out      = dfpers
vpar_out       = v_c_para
vper_out       = v_c_perp
df_out         = df2ds
;;----------------------------------------------------------------------------------------
;; => Define DF range and corresponding contour levels, colors, etc.
;;----------------------------------------------------------------------------------------
;; Define level range
lev_ra   = df_ran
IF KEYWORD_SET(dfmin) THEN lev_ra[0] = lev_ra[0] > dfmin[0]
IF KEYWORD_SET(dfmax) THEN lev_ra[1] = lev_ra[1] < dfmax[0]
range    = ALOG10(lev_ra)
;range    = ALOG10(df_ran)
lg_levs  = DINDGEN(nlevs)*(range[1] - range[0])/(nlevs - 1L) + range[0]
;; => Levels for contour plot
levels   = 1d1^lg_levs
nlevs    = N_ELEMENTS(levels)
minclr   = 30L
;; => Colors associated with each contour
c_cols   = minclr + LINDGEN(nlevs)*(250L - minclr)/(nlevs - 1L)
;;----------------------------------------------------------------------------------------
;; => Define plot parameters
;;----------------------------------------------------------------------------------------
;;  Define contour axes titles
xaxist         = '(V dot '+xname[0]+') [1000 km/s]'
yaxist         = '('+xname[0]+' x '+yname[0]+') x '+xname[0]+' [1000 km/s]'
zaxist         = '('+xname[0]+' x '+yname[0]+') [1000 km/s]'
IF (projxy[0] EQ 'xy') THEN xttl00 = xaxist
IF (projxy[0] EQ 'xy') THEN yttl00 = yaxist
IF (projxy[0] EQ 'xz') THEN xttl00 = zaxist
IF (projxy[0] EQ 'xz') THEN yttl00 = xaxist
IF (projxy[0] EQ 'yz') THEN xttl00 = yaxist
IF (projxy[0] EQ 'yz') THEN yttl00 = zaxist

vc1_col        = 250L
vc2_col        =  50L
;;  Define XY-Range for contour plot
xyran          = [-1d0,1d0]*xran[0]*1d-3

!P.MULTI       = [0,1,2]
IF (STRLOWCASE(!D.NAME) EQ 'ps') THEN l_thick  = 3 ELSE l_thick  = 2
;;----------------------------------------------------------------------------------------
;; => Define DF plot limits structures
;;----------------------------------------------------------------------------------------
;; => Define structure to set up contour plot area
lim_cn0  = {XRANGE:xyran,XSTYLE:1,XLOG:0,XTITLE:xttl00,XMINOR:10, $
            YRANGE:xyran,YSTYLE:1,YLOG:0,YTITLE:yttl00,YMINOR:10, $
            POSITION:pos_0con,TITLE:con_ttl,NODATA:1}
;; => Define contour plot structure
con_lim  = {OVERPLOT:1,LEVELS:levels,C_COLORS:c_cols}

;; => Define Y-Axis tick marks for cuts
goodyl   = WHERE(ytvs LE df_ran[1] AND ytvs GE df_ran[0],gdyl)
IF (gdyl LT 20 AND gdyl GT 0) THEN BEGIN
  ;; => structure for cuts plot with tick mark labels set
  lim_ct0  = {XRANGE:xyran, XSTYLE:1,XLOG:0,XTITLE:cut_xttl,XMINOR:10, $
              YRANGE:df_ran,YSTYLE:1,YLOG:1,YTITLE:yttlct,  YMINOR:9,  $
              POSITION:pos_0cut,TITLE:' ',NODATA:1,YTICKS:gdyl-1L,     $
              YTICKV:ytvs[goodyl],YTICKNAME:ytns[goodyl]}
ENDIF ELSE BEGIN
  ;; => structure for cuts plot without tick mark labels set
  lim_ct0  = {XRANGE:xyran, XSTYLE:1,XLOG:0,XTITLE:cut_xttl,XMINOR:10, $
              YRANGE:df_ran,YSTYLE:1,YLOG:1,YTITLE:yttlct,  YMINOR:9,  $
              POSITION:pos_0cut,TITLE:' ',NODATA:1}
ENDELSE
;; => Add Min/Max Values to structures
IF KEYWORD_SET(dfmin) THEN BEGIN
  ;; => Do    change data
  df2ds_2  = df2ds
  dfpars_2 = dfpars
  dfpers_2 = dfpers
  ;; => Find "bad" data
  bad     = WHERE(df2ds_2 LT dfmin[0],bd)
  IF (bd GT 0) THEN df2ds_2[bad] = d
  bad     = WHERE(dfpars_2 LT dfmin[0],bd)
  IF (bd GT 0) THEN dfpars_2[bad] = d
  bad     = WHERE(dfpers_2 LT dfmin[0],bd)
  IF (bd GT 0) THEN dfpers_2[bad] = d
ENDIF ELSE BEGIN
  ;; => Don't change data
  df2ds_2 = df2ds
  dfpars_2 = dfpars
  dfpers_2 = dfpers
ENDELSE

IF KEYWORD_SET(dfmax) THEN BEGIN
  ;; => Find "bad" data
  bad     = WHERE(df2ds_2 GT dfmax[0],bd)
  IF (bd GT 0) THEN df2ds_2[bad] = d
  bad     = WHERE(dfpars_2 GT dfmax[0],bd)
  IF (bd GT 0) THEN dfpars_2[bad] = d
  bad     = WHERE(dfpers_2 GT dfmax[0],bd)
  IF (bd GT 0) THEN dfpers_2[bad] = d
ENDIF
;;----------------------------------------------------------------------------------------
;; => Set up structures for contour wrapper
;;----------------------------------------------------------------------------------------
tags_con       = ['LIMITS_0','LIMITS_1','VX_PTS','VY_PTS','VX_GRID','VY_GRID','DF_GRID']
tags_cut       = ['LIMITS_0','VPARA','VPERP','DFPARA','DFPERP']
tags_cir       = ['VRAD','VOX','VOY']
tags_tra       = ['SCPOT','VSW','MAGF']
cont_struc     = CREATE_STRUCT(tags_con,lim_cn0,con_lim,vxpts*1d-3,vypts*1d-3,$
                               vx2d*1d-3,vy2d*1d-3,df2ds_2)
cuts_struc     = CREATE_STRUCT(tags_cut,lim_ct0,v_c_para*1d-3,v_c_perp*1d-3,dfpars_2,dfpers_2)
tran_info      = CREATE_STRUCT(tags_tra,data[0].SC_POT,v_vsws,magf_st)

IF (SIZE(model,/TYPE) EQ 8) THEN BEGIN
  fv_df_para     = model.DF_PARA
  fv_df_perp     = model.DF_PERP
  vpara_mod      = model.V_CUT_PARA*1d-3
  vperp_mod      = model.V_CUT_PERP*1d-3
  ;;-----------------------------------------------
  ;; => Smooth cuts if desired
  ;;-----------------------------------------------
  dfpar_mod   = fv_df_para
  dfper_mod   = fv_df_perp
  ;;-----------------------------------------------
  ;; => Create structure for plotting routine
  ;;-----------------------------------------------
  model_str = CREATE_STRUCT(tags_cut[1:4],vpara_mod,vperp_mod,dfpar_mod,dfper_mod)
ENDIF

IF KEYWORD_SET(vcirc) THEN BEGIN
  n_circ = N_ELEMENTS(vcirc)
  ;;-----------------------------------------------
  ;; => check X-offsets
  ;;-----------------------------------------------
  IF KEYWORD_SET(vc_xoff) THEN BEGIN
    IF (N_ELEMENTS(vcirc) NE n_circ) THEN BEGIN
      vc_xo = REPLICATE(vc_xoff[0],n_circ)
    ENDIF ELSE BEGIN
      vc_xo = vc_xoff
    ENDELSE
  ENDIF ELSE vc_xo = REPLICATE(0d0,n_circ)
  ;;-----------------------------------------------
  ;; => check Y-offsets
  ;;-----------------------------------------------
  IF KEYWORD_SET(vc_yoff) THEN BEGIN
    IF (N_ELEMENTS(vcirc) NE n_circ) THEN BEGIN
      vc_yo = REPLICATE(vc_yoff[0],n_circ)
    ENDIF ELSE BEGIN
      vc_yo = vc_yoff
    ENDELSE
  ENDIF ELSE vc_yo = REPLICATE(0d0,n_circ)
  ;;-----------------------------------------------
  ;; => Create structures for plotting routine
  ;;-----------------------------------------------
  dumb           = CREATE_STRUCT(tags_cir,d,d,d)
  circ_struc     = REPLICATE(dumb[0],n_circ)
  FOR j=0L, n_circ - 1L DO BEGIN
    dumb          = CREATE_STRUCT(tags_cir,vcirc[j]*1d-3,vc_xo[j]*1d-3,vc_yo[j]*1d-3)
    circ_struc[j] = dumb[0]
  ENDFOR
ENDIF
;;----------------------------------------------------------------------------------------
;; => Plot Contour
;;----------------------------------------------------------------------------------------
contour_vdf,cont_struc,cuts_struc,MODEL_STR=model_str,EX_VECS=ex_vecs, $
            CIRCLE_STR=circ_struc,VERSION=version,TRAN_INFO=tran_info, $
            V_0X=vox,V_0Y=voy,VB_REG=vb_reg,                           $
            XYDP_CON=xydp_con,XYDP_CUT=xydp_cut
;;----------------------------------------------------------------------------------------
;; => Overplot One-Count if desired
;;----------------------------------------------------------------------------------------
IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
  ;; green line for one-count level
  OPLOT,v1c_para*1d-3,onc_paras,COLOR=150,LINESTYLE=4
  ;; output label
  yra_cut        = lim_ct0.YRANGE
  fmin           = yra_cut[0]
  xyposi         = [4e-1*xyran[0],fmin[0]*4e0]
  ;; => Shift in negative Y-Direction
  xyposi[1] *= 0.7
  ;; => Shift in negative Y-Direction
  xyposi[1] *= 0.7
  ;; => Output label for one-count level
  XYOUTS,xyposi[0],xyposi[1],'- - - : One-Count Level',COLOR=150,/DATA
ENDIF
;;----------------------------------------------------------------------------------------
;; => Define XY-Scaling to return to calling routine
;;----------------------------------------------------------------------------------------
xscale   = xydp_con.X.S
yscale   = xydp_con.Y.S
xyfact   = 1d3
plot_str = {XSCALE:xscale,YSCALE:yscale,XFACT:xyfact[0],YFACT:xyfact[0]}
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------
!P.MULTI       = 0

RETURN
END
