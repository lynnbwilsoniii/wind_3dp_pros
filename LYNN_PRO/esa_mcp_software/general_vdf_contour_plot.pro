;*****************************************************************************************
;
;  FUNCTION :   defaults_vdf_contour_plot.pro
;  PURPOSE  :   This routine sets up and defines the default settings for keywords
;                 not set by the user.
;
;  CALLED BY:   
;               general_vdf_contour_plot.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               is_a_3_vector.pro
;               mag__vec.pro
;               test_plot_axis_range.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VDF      :  [N]-Element [float/double] array defining particle velocity
;                             distribution function (VDF) in units of phase space density
;                             [e.g., # s^(+3) km^(-3) cm^(-3)]
;               VELXYZ   :  [N,3]-Element [float/double] array defining the particle
;                             velocity 3-vectors for each element of VDF
;
;  EXAMPLES:    
;               [calling sequence]
;               tests = defaults_vdf_contour_plot(vdf, velxyz [,VFRAME=vframe]           $
;                                                 [,VEC1=vec1] [,VEC2=vec2] [,VLIM=vlim] $
;                                                 [,NLEV=nlev] [,XNAME=xname]            $
;                                                 [,YNAME=yname] [,SM_CUTS=sm_cuts]      $
;                                                 [,SM_CONT=sm_cont] [,NSMCUT=nsmcut]    $
;                                                 [,NSMCON=nsmcon] [,PLANE=plane]        $
;                                                 [,DFMIN=dfmin] [,DFMAX=dfmax]          $
;                                                 [,DFRA=dfra] [,V_0X=v_0x] [,V_0Y=v_0y] $
;                                                 [,STRAHL=strahl] [,NGRID=ngrid]        $
;                                                 [,/SLICE2D] [,P_TITLE=p_title]         $
;                                                 [,ONE_C=one_c] [,BPARM=bparm]          $
;                                                 [,KPARM=bikap] [,S_SIGN=s_sign]        )
;
;  KEYWORDS:    
;               ***  INPUTS  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all of the following have default settings]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               VFRAME   :  [3]-Element [float/double] array defining the 3-vector
;                             velocity of the K'-frame relative to the K-frame [km/s]
;                             to use to transform the velocity distribution into the
;                             bulk flow reference frame
;                             [ Default = [10,0,0] ]
;               VEC1     :  [3]-Element vector to be used for "parallel" direction in
;                             a 3D rotation of the input data
;                             [e.g. see rotate_3dp_structure.pro]
;                             [ Default = [1.,0.,0.] ]
;               VEC2     :  [3]--Element vector to be used with VEC1 to define a 3D
;                             rotation matrix.  The new basis will have the following:
;                               X'  :  parallel to VEC1
;                               Z'  :  parallel to (VEC1 x VEC2)
;                               Y'  :  completes the right-handed set
;                             [ Default = [0.,1.,0.] ]
;               VLIM     :  Scalar [numeric] defining the velocity [km/s] limit for x-y
;                             velocity axes over which to plot data
;                             [Default = [-1,1]*MAX(ABS(VELXYZ))]
;               NLEV     :  Scalar [numeric] defining the # of contour levels to plot
;                             [Default = 30L]
;               XNAME    :  Scalar [string] defining the name of vector associated with
;                             the VEC1 input
;                             [Default = 'X']
;               YNAME    :  Scalar [string] defining the name of vector associated with
;                             the VEC2 input
;                             [Default = 'Y']
;               SM_CUTS  :  If set, program smoothes the cuts of the VDF before plotting
;                             [Default = FALSE]
;               SM_CONT  :  If set, program smoothes the contours of the VDF before
;                             plotting
;                             [Default = FALSE]
;               NSMCUT   :  Scalar [numeric] defining the # of points over which to
;                             smooth the 1D cuts of the VDF before plotting
;                             [Default = 3]
;               NSMCON   :  Scalar [numeric] defining the # of points over which to
;                             smooth the 2D contour of the VDF before plotting
;                             [Default = 3]
;               PLANE    :  Scalar [string] defining the plane projection to plot with
;                             corresponding cuts [Let V1 = VEC1, V2 = VEC2]
;                               'xy'  :  horizontal axis parallel to V1 and normal
;                                          vector to plane defined by (V1 x V2)
;                                          [default]
;                               'xz'  :  horizontal axis parallel to (V1 x V2) and
;                                          vertical axis parallel to V1
;                               'yz'  :  horizontal axis defined by (V1 x V2) x V1
;                                          and vertical axis (V1 x V2)
;                             [Default = 'xy']
;               DFMIN    :  Scalar [numeric] defining the minimum allowable phase space
;                             density to plot, which is useful for ion distributions with
;                             large angular gaps in data (prevents lower bound from
;                             falling below DFMIN)
;                             [Default = 1d-20]
;               DFMAX    :  Scalar [numeric] defining the maximum allowable phase space
;                             density to plot, which is useful for distributions with
;                             data spikes (prevents upper bound from exceeding DFMAX)
;                             [Default = 1d-2]
;               DFRA     :  [2]-Element [numeric] array specifying the VDF range in phase
;                             space density [e.g., # s^(+3) km^(-3) cm^(-3)] for the
;                             cuts and contour plots
;                             [Default = [MIN(VDF),MAX(VDF)]]
;               V_0X     :  Scalar [float/double] defining the velocity [km/s] along the
;                             X-Axis (horizontal) to shift the location where the
;                             perpendicular (vertical) cut of the DF will be performed
;                             [Default = 0.0]
;               V_0Y     :  Scalar [float/double] defining the velocity [km/s] along the
;                             Y-Axis (vertical) to shift the location where the
;                             parallel (horizontal) cut of the DF will be performed
;                             [Default = 0.0]
;               NGRID    :  Scalar [numeric] defining the number of grid points in each
;                             direction to use when triangulating the data.  The input
;                             will be limited to values between 30 and 300.
;                             [Default = 101]
;               SLICE2D  :  If set, routine will return a 2D slice instead of a 3D
;                             projection
;                             [Default = FALSE]
;               P_TITLE  :  Scalar [string] defining the plot title for the contour plot
;                             [Default = 'Contours of constant PSD']
;               ONE_C    :  [N]-Element [float/double] array defining particle VDF
;                             one-count level in units of phase space density
;                             [e.g., # s^(+3) km^(-3) cm^(-3)]
;                             [Default = FALSE]
;               BPARM    :  [6]-Element [numeric] array where each element is defined by
;                             the following quantities:
;                             PARAM[0] = Number Density [cm^(-3)]
;                             PARAM[1] = Parallel Thermal Speed [km/s]
;                             PARAM[2] = Perpendicular Thermal Speed [km/s]
;                             PARAM[3] = Parallel Drift Speed [km/s]
;                             PARAM[4] = Perpendicular Drift Speed [km/s]
;                             PARAM[5] = *** Not Used Here ***
;                           If set, the routine will output 1D cuts of a model
;                             bi-Maxwellian VDF defined by the above parameters
;                             [Default = FALSE]
;               KPARM    :  [6]-Element [numeric] array where each element is defined by
;                             the following quantities:
;                             PARAM[0] = Number Density [cm^(-3)]
;                             PARAM[1] = Parallel Thermal Speed [km/s]
;                             PARAM[2] = Perpendicular Thermal Speed [km/s]
;                             PARAM[3] = Parallel Drift Speed [km/s]
;                             PARAM[4] = Perpendicular Drift Speed [km/s]
;                             PARAM[5] = Kappa Value
;                           If set, the routine will output 1D cuts of a model
;                             bi-kappa VDF defined by the above parameters
;                             [Default = FALSE]
;               S_SIGN   :  Scalar [integer/long] defining the sign to apply to the
;                             computed strahl direction from find_strahl_direction.pro
;                             for times when the sun direction is nearly orthogonal to
;                             the quasi-static magnetic field and the strahl (as seen
;                             in plotted VDFs) is in the "wrong" direction.  If the value
;                             is positive, then the output from find_strahl_direction.pro
;                             will be used, otherwise the sign will flip.
;                             [Default = +1]
;               PSTATS   :  [N]-Element [float/double] array defining particle VDF
;                             Poisson statistics in phase space density units
;                             [i.e., s^(3) km^(-3) cm^(-3)]
;               RMBELOW  :  Scalar [numeric] defining the speed [km/s] below which all
;                             data will be killed before plotting
;                             [Default = 0]
;
;   CHANGED:  1)  Fixed a bug that occurs when VDF input contains zeros
;                                                                   [05/16/2016   v1.0.1]
;             2)  Fixed a bug that occurs when user sets the EX_INFO keyword
;                                                                   [05/17/2016   v1.0.2]
;             3)  Added keyword C_LOG to main routine
;                                                                   [05/26/2017   v1.0.3]
;             4)  Cleaned up
;                                                                   [05/26/2017   v1.0.4]
;             5)  Added keyword P_LOG to main routine
;                                                                   [05/30/2017   v1.0.5]
;             6)  Fixed an issue that occurs when user wants small VLIM with proper
;                   VFRAME setting that was previously causing the default setting to
;                   be used
;                                                                   [02/28/2018   v1.0.6]
;             7)  Added keyword BIMAX to main routine
;                                                                   [04/02/2018   v1.0.7]
;             8)  Added keyword BIKAP to main routine
;                                                                   [04/04/2018   v1.0.8]
;             9)  Added STRAHL keyword
;                                                                   [04/19/2018   v1.0.9]
;            10)  Added keywords:  NGRID, SLICE2D, P_TITLE, ONE_C, BPARM, and KPARM
;                                                                   [05/09/2018   v1.1.0]
;            11)  Added error handling for non-finite VEC1 and/or VEC2 inputs
;                                                                   [06/19/2018   v1.1.1]
;            12)  Added S_SIGN keyword
;                                                                   [08/07/2018   v1.1.2]
;            13)  Added PSTATS keyword
;                                                                   [07/06/2021   v1.1.3]
;            14)  Added keyword:  RMBELOW
;                                                                   [11/01/2021   v1.1.4]
;
;   NOTES:      
;               1)  Setting DFRA trumps any values set in DFMIN and DFMAX
;               2)  All inputs will be altered on output
;               3)  All keywords will be altered on output
;               4)  There are checks to make sure user's settings cannot produce useless
;                     plots, e.g., V_0X and V_0Y cannot fall outside 80% of VLIM
;               5)  There must be at least 10 finite VDF values with associated finite
;                     VELXYZ vector magnitudes and those ≥10 VDF values must be unique
;
;  REFERENCES:  
;               NA
;
;   CREATED:  04/07/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/01/2021   v1.1.4
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION defaults_vdf_contour_plot,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,          $
                             VLIM=vlim,NLEV=nlev,XNAME=xname,YNAME=yname,SM_CUTS=sm_cuts, $
                             SM_CONT=sm_cont,NSMCUT=nsmcut,NSMCON=nsmcon,PLANE=plane,     $
                             DFMIN=dfmin,DFMAX=dfmax,DFRA=dfra,V_0X=v_0x,V_0Y=v_0y,       $
                             STRAHL=strahl,NGRID=ngrid,SLICE2D=slice2d,P_TITLE=p_title,   $
                             ONE_C=one_c,BPARM=bimax,KPARM=bikap,S_SIGN=s_sign,           $
                             PSTATS=pstats,RMBELOW=rmbelow

FORWARD_FUNCTION is_a_number, is_a_3_vector, mag__vec, test_plot_axis_range
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
vec_str        = ['x','y','z']
vec_col        = [250,150,50]
all_planes     = ['xy','xz','yz']
;;  Position of contour plot [square]
;;               Xo    Yo    X1    Y1
pos_0con       = [0.22941,0.515,0.77059,0.915]
;;  Position of 1st DF cuts [square]
pos_0cut       = [0.22941,0.050,0.77059,0.450]
;;  Dummy error messages
no_inpt_msg    = 'User must supply a VDF and a corresponding array of 3-vector velocities...'
badvfor_msg    = 'Incorrect input format:  VDF and VELXYZ must have the same size first dimensions...'
nofinite_mssg  = 'Not enough finite and unique data was supplied...'
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
;;  Default frame and coordinates
def_vframe     = [1d1,0d0,0d0]          ;;  Assumes km/s units on input
def_vec1       = [1d0,0d0,0d0]
def_vec2       = [0d0,1d0,0d0]
;;  Default plot stuff
def_nlev       = 30L
def_xname      = 'X'
def_yname      = 'Y'
def_sm_cuts    = 0b
def_sm_cont    = 0b
def_nsmcut     = 3L
def_nsmcon     = 3L
def_plane      = 'xy'
def_con_xttl   = '(V dot '+def_xname[0]+') [1000 km/s]'
def_con_yttl   = '('+def_xname[0]+' x '+def_yname[0]+') x '+def_xname[0]+' [1000 km/s]'
def_con_zttl   = '('+def_xname[0]+' x '+def_yname[0]+') [1000 km/s]'
def_units_vdf  = '[sec!U3!N km!U-3!N cm!U-3!N'+']'
def_cut_yttl   = '1D VDF Cuts'+'!C'+def_units_vdf[0]
def_cut_xttl   = 'Velocity [1000 km/sec]'
def_con_pttl   = 'Contours of constant PSD'
;;  Define lower/upper bound on phase space densities
lower_lim      = 1e-20  ;;  Lowest expected value for DF [s^(+3) cm^(-3) km^(-3)]
upper_lim      = 1e-2   ;;  Highest expected value for DF [s^(+3) cm^(-3) km^(-3)]
def_dfnx       = [lower_lim[0],upper_lim[0]]
;;  Default crosshair location for cuts
def_vox        = 0d0
def_voy        = 0d0
;;  Default one-count setting
def_onec       = 0
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (is_a_number(vdf,/NOMSSG) EQ 0) OR  $
                 (is_a_3_vector(velxyz,V_OUT=vxyz,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
szdvdf         = SIZE(vdf,/DIMENSIONS)
szdvel         = SIZE(vxyz,/DIMENSIONS)
kk             = szdvdf[0]                      ;;  # of phase space density values
IF ((szdvdf[0] NE szdvel[0]) OR (szdvdf[0] LT 10)) THEN BEGIN
  MESSAGE,badvfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Now that we know these are at least formatted correct, test values
vmag           = mag__vec(vxyz,/NAN)
IF ((TOTAL(FINITE(vdf)) LT 10) OR (TOTAL(FINITE(vmag)) LT 10)) THEN BEGIN
  MESSAGE,'0: '+nofinite_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define default VLIM and DFRA
def_vlim       = MAX(ABS(vmag),/NAN)*1.05
def_dfra       = [MIN(ABS(vdf),/NAN) > def_dfnx[0],MAX(ABS(vdf),/NAN) < def_dfnx[1]]
;;  Make sure values are unique and have a finite range
IF (test_plot_axis_range(def_dfra,/NOMSSG) EQ 0) THEN BEGIN
  MESSAGE,'1: '+nofinite_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Inflate by ±5%
def_dfra      *= [0.95,1.05]
test           = (TOTAL(def_dfra LE 0) GT 0)
IF (test[0]) THEN def_dfra = def_dfnx  ;;  revert to default limits
;;----------------------------------------------------------------------------------------
;;  Check keywords [Inputs]
;;----------------------------------------------------------------------------------------
;;  Check VFRAME
IF (is_a_3_vector(vframe,V_OUT=vtrans,/NOMSSG) EQ 0) THEN vframe = def_vframe ELSE vframe = vtrans
;;  Define new frame |V| [km/s]
vf_new         = vxyz
;IF (TOTAL(FINITE(vframe)) EQ 3) THEN FOR k=0L, 2L DO vf_new[*,k] -= vframe[k]
IF (TOTAL(FINITE(vframe)) EQ 3) THEN BEGIN
  FOR k=0L, 2L DO vf_new[*,k] -= vframe[k]
ENDIF ELSE BEGIN
  ;;  VFRAME is not finite --> zero out
  vframe = REPLICATE(0d0,1,3)
ENDELSE
vmag_new       = mag__vec(vf_new,/NAN)
;;  Check VEC1 and VEC2
IF (is_a_3_vector(vec1,V_OUT=v1out,/NOMSSG) EQ 0) THEN vec1 = def_vec1 ELSE vec1 = v1out
IF (is_a_3_vector(vec2,V_OUT=v2out,/NOMSSG) EQ 0) THEN vec2 = def_vec2 ELSE vec2 = v2out
IF (TOTAL(FINITE(vec1)) NE 3) THEN vec1 = def_vec1
IF (TOTAL(FINITE(vec2)) NE 3) THEN vec2 = def_vec2
;;  Check VLIM
IF (is_a_number(vlim,/NOMSSG) EQ 0) THEN vlim = def_vlim[0] ELSE vlim = ABS(vlim[0])
IF (vlim[0] LE MIN(ABS(vmag_new),/NAN)) THEN vlim = def_vlim[0]
;;  Check NLEV
IF (is_a_number(nlev,/NOMSSG) EQ 0) THEN nlev = def_nlev[0] ELSE nlev = LONG(ABS(nlev[0]))
IF (nlev[0] LE 3) THEN nlev = def_nlev[0]
;;  Check XNAME and YNAME
IF (SIZE(xname,/TYPE) NE 7) THEN xname = def_xname[0] ELSE xname = xname[0]
IF (SIZE(yname,/TYPE) NE 7) THEN yname = def_yname[0] ELSE yname = yname[0]
;;  Check SM_CUTS and SM_CONT
sm_cuts        = KEYWORD_SET(sm_cuts) AND (N_ELEMENTS(sm_cuts) GT 0)
sm_cont        = KEYWORD_SET(sm_cont) AND (N_ELEMENTS(sm_cont) GT 0)
;;  Check NSMCUT and NSMCON
IF (is_a_number(nsmcut,/NOMSSG) EQ 0) THEN nsmcut = def_nsmcut[0] ELSE nsmcut = LONG(ABS(nsmcut[0]))
IF (is_a_number(nsmcon,/NOMSSG) EQ 0) THEN nsmcon = def_nsmcon[0] ELSE nsmcon = LONG(ABS(nsmcon[0]))
;;  Check PLANE
IF (SIZE(plane,/TYPE) NE 7) THEN plane = def_plane[0] ELSE plane = STRLOWCASE(plane[0])
IF (TOTAL(plane[0] EQ all_planes) LT 1) THEN plane = def_plane[0]
;;  Check for DFMIN, DFMAX, and DFRA
tests          = [is_a_number(dfmin,/NOMSSG),is_a_number(dfmax,/NOMSSG),$
                  (is_a_number(dfra,/NOMSSG) AND (N_ELEMENTS(dfra) GE 2))]
;;  Check DFMIN and DFMAX
IF (is_a_number(dfmin,/NOMSSG) EQ 0) THEN dfmin = def_dfnx[0] ELSE dfmin = ABS(dfmin[0])
IF (is_a_number(dfmax,/NOMSSG) EQ 0) THEN dfmax = def_dfnx[1] ELSE dfmax = ABS(dfmax[0])
;;  Check DFRA
IF ((is_a_number(dfra,/NOMSSG) EQ 0) OR (N_ELEMENTS(dfra) LT 2)) THEN dfra = def_dfra ELSE dfra = ABS(dfra)
IF (test_plot_axis_range(dfra,/NOMSSG) EQ 0) THEN BEGIN
  dfra     = def_dfra
  tests[2] = 0b    ;;  shut off user defined DFRA
ENDIF
;;  Now let user-defined keyword(s), if present, trump default values
IF (tests[2]) THEN BEGIN
  ;;  User correctly set DFRA --> redefine DFMIN and DFMAX
  dfmin = 0.95*dfra[0]
  dfmax = 1.05*dfra[1]
ENDIF ELSE BEGIN
  ;;  Check if user set DFMIN or DFMAX
  IF (tests[0]) THEN BEGIN
    ;;  User correctly set DFMIN --> redefine DFRA[0]
    dfra[0] = dfmin[0]
  ENDIF
  IF (tests[1]) THEN BEGIN
    ;;  User correctly set DFMAX --> redefine DFRA[1]
    dfra[1] = dfmax[0]
  ENDIF
ENDELSE
;;  Check V_0X and V_0Y
IF (is_a_number(v_0x,/NOMSSG) EQ 0) THEN v_0x = def_vox[0] ELSE v_0x = v_0x[0]
IF (is_a_number(v_0y,/NOMSSG) EQ 0) THEN v_0y = def_voy[0] ELSE v_0y = v_0y[0]
;;  Check STRAHL
strahl                  = (N_ELEMENTS(strahl) GT 0) AND KEYWORD_SET(strahl)
;;  Check S_SIGN
IF (N_ELEMENTS(s_sign) EQ 0) OR (is_a_number(s_sign,/NOMSSG) EQ 0) THEN s_sign = 1 ELSE s_sign = sign(s_sign[0])
IF (s_sign[0] EQ 0 OR FINITE(s_sign[0]) EQ 0) THEN s_sign = 1  ;;  force to default if zero or non-finite
;;  Check NGRID
IF (N_ELEMENTS(ngrid) EQ 0) OR (is_a_number(ngrid,/NOMSSG) EQ 0) THEN ngrid = 101L $
                                                                 ELSE ngrid = (LONG(ngrid[0]) > 30L) < 300L
;;  Check SLICE2D
slice2d        = (N_ELEMENTS(slice2d) EQ 1) AND KEYWORD_SET(slice2d)
;;  Check P_TITLE
IF (SIZE(p_title,/TYPE) NE 7) OR (N_ELEMENTS(p_title) LT 1) THEN p_title = def_con_pttl[0] ELSE p_title = p_title[0]
;;  Check ONE_C
onec_on        = (N_ELEMENTS(one_c) EQ kk[0]) AND is_a_number(one_c,/NOMSSG)
IF (onec_on[0]) THEN one_c = REFORM(one_c,kk[0])
;;  Check PSTATS
pstt_on        = (N_ELEMENTS(pstats) EQ kk[0]) AND is_a_number(pstats,/NOMSSG)
IF (pstt_on[0]) THEN pstats = REFORM(pstats,kk[0])
;;  Check BPARM
IF ((N_ELEMENTS(bimax) GE 4) AND is_a_number(bimax,/NOMSSG)) THEN BEGIN
  CASE N_ELEMENTS(bimax) OF
    4L    :  bimax = [DOUBLE(bimax),0d0,0d0]
    5L    :  bimax = [DOUBLE(bimax),0d0]
    ELSE  :  bimax = DOUBLE(bimax[0L:5L])
  ENDCASE
  ;;  Force drifts to zero to avoid offsets for dummy model comparison
  ;;    --> This assumes the user has centered the crosshairs on the peak of the VDF
  bimax[3L:4L] = 0d0
ENDIF ELSE BEGIN
  bimax        = 0
ENDELSE
;;  Check KPARM
bikap_on       = (N_ELEMENTS(bikap) EQ 6) AND is_a_number(bikap,/NOMSSG)
IF (bikap_on[0]) THEN bikap = DOUBLE(bikap) ELSE bikap = 0
;;  Check RMBELOW
IF (is_a_number(rmbelow,/NOMSSG)) THEN BEGIN
  ;;  Is numeric --> Make sure it's at least 0 (i.e., not negative)
  rmbelow        = rmbelow[0] > 0d0
ENDIF ELSE BEGIN
  ;;  Not numeric or not set --> Default to 0.0
  rmbelow        = 0d0
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Now make sure user hasn't set "dumb" values (i.e., make sure data falls within ranges)
;;----------------------------------------------------------------------------------------
IF (TOTAL(vdf GE dfra[0] AND vdf LE dfra[1]) LT 10) THEN BEGIN
  ;;  User set "bad" DFRA --> redefine DFMIN, DFMAX, and DFRA to defaults
  dfra  = def_dfra
  dfmin = 0.95*dfra[0]
  dfmax = 1.05*dfra[1]
  tests = REPLICATE(0b,3L)
ENDIF
IF (TOTAL(vmag_new GE 0d0 AND vmag_new LE vlim[0]) LT 10) THEN BEGIN
  ;;  User set "bad" VLIM --> redefine VLIM to default
  vlim  = def_vlim[0]
ENDIF
;;  Make sure V_0X and V_0Y are not outside 80% of VLIM
IF (ABS(v_0x[0]) GE 8d-1*vlim[0]) THEN v_0x = def_vox[0]
IF (ABS(v_0y[0]) GE 8d-1*vlim[0]) THEN v_0y = def_voy[0]
;;----------------------------------------------------------------------------------------
;;  Redefine input for output
;;----------------------------------------------------------------------------------------
vdf            = REFORM(TEMPORARY(vdf))
velxyz         = vxyz
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,tests
END


;+
;*****************************************************************************************
;
;  PROCEDURE:   general_vdf_contour_plot.pro
;  PURPOSE  :   This is a generalized plotting routine for velocity distribution
;                 functions (VDFs) observed by spacecraft.  It is generalized because
;                 it only requests the phase space density and corresponding velocity
;                 3-vectors on input and does not depend upon any routines specific
;                 to any instrument.  It is a specified routine because it is only
;                 meant for particle VDFs.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               defaults_vdf_contour_plot.pro
;
;  CALLS:
;               is_a_number.pro
;               is_a_3_vector.pro
;               mag__vec.pro
;               test_plot_axis_range.pro
;               defaults_vdf_contour_plot.pro
;               get_rotated_and_triangulated_vdf.pro

;               find_1d_cuts_2d_dist.pro
;               bimaxwellian.pro
;               bikappa.pro
;               unit_vec.pro
;               format_vector_string.pro
;               find_strahl_direction.pro
;               get_power_of_ten_ticks.pro
;               routine_version.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VDF      :  [N]-Element [float/double] array defining particle velocity
;                             distribution function (VDF) in units of phase space density
;                             [e.g., # s^(+3) km^(-3) cm^(-3)]
;               VELXYZ   :  [N,3]-Element [float/double] array defining the particle
;                             velocity 3-vectors for each element of VDF
;                             [e.g., km/s]
;
;  EXAMPLES:    
;               [calling sequence]
;               general_vdf_contour_plot, vdf, velxyz [,VFRAME=vframe] [,VEC1=vec1]      $
;                                      [,VEC2=vec2] [,VLIM=vlim] [,NLEV=nlev]            $
;                                      [,XNAME=xname] [,YNAME=yname] [,SM_CUTS=sm_cuts]  $
;                                      [,SM_CONT=sm_cont] [,NSMCUT=nsmcut]               $
;                                      [,NSMCON=nsmcon] [,PLANE=plane] [,DFMIN=dfmin]    $
;                                      [,DFMAX=dfmax] [,DFRA=dfra] [,V_0X=v_0x]          $
;                                      [,V_0Y=v_0y] [,C_LOG=c_log] [,NGRID=ngrid]        $
;                                      [,SLICE2D=slice2d] [,CIRCS=circs] [,P_LOG=p_log]  $
;                                      [,EX_VECS=ex_vecs] [,EX_INFO=ex_info]             $
;                                      [,P_TITLE=p_title] [,ONE_C=one_c]                 $
;                                      [,DAT_OUT=dat_out] [,BIMAX=bimax] [,BIKAP=bikap]  $
;                                      [,STRAHL=strahl] [,/GET_ROT] [,ROT_OUT=rot_out]   $
;                                      [,S_SIGN=s_sign] [,CLOSED=closed] [,/KEEPNAN]     $
;                                      [,F3D_QH=f3d_qh]
;
;  KEYWORDS:    
;               ***  INPUTS  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all of the following have default settings]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               VFRAME   :  [3]-Element [float/double] array defining the 3-vector
;                             velocity of the K'-frame relative to the K-frame [km/s]
;                             to use to transform the velocity distribution into the
;                             bulk flow reference frame
;                             [ Default = [10,0,0] ]
;               VEC1     :  [3]-Element vector to be used for "parallel" direction in
;                             a 3D rotation of the input data
;                             [e.g. see rotate_3dp_structure.pro]
;                             [ Default = [1.,0.,0.] ]
;               VEC2     :  [3]--Element vector to be used with VEC1 to define a 3D
;                             rotation matrix.  The new basis will have the following:
;                               X'  :  parallel to VEC1
;                               Z'  :  parallel to (VEC1 x VEC2)
;                               Y'  :  completes the right-handed set
;                             [ Default = [0.,1.,0.] ]
;               VLIM     :  Scalar [numeric] defining the velocity [km/s] limit for x-y
;                             velocity axes over which to plot data
;                             [Default = [-1,1]*MAX(ABS(VELXYZ))]
;               NLEV     :  Scalar [numeric] defining the # of contour levels to plot
;                             [Default = 30L]
;               XNAME    :  Scalar [string] defining the name of vector associated with
;                             the VEC1 input
;                             [Default = 'X']
;               YNAME    :  Scalar [string] defining the name of vector associated with
;                             the VEC2 input
;                             [Default = 'Y']
;               SM_CUTS  :  If set, program smoothes the cuts of the VDF before plotting
;                             [Default = FALSE]
;               SM_CONT  :  If set, program smoothes the contours of the VDF before
;                             plotting
;                             [Default = FALSE]
;               NSMCUT   :  Scalar [numeric] defining the # of points over which to
;                             smooth the 1D cuts of the VDF before plotting
;                             [Default = 3]
;               NSMCON   :  Scalar [numeric] defining the # of points over which to
;                             smooth the 2D contour of the VDF before plotting
;                             [Default = 3]
;               PLANE    :  Scalar [string] defining the plane projection to plot with
;                             corresponding cuts [Let V1 = VEC1, V2 = VEC2]
;                               'xy'  :  horizontal axis parallel to V1 and normal
;                                          vector to plane defined by (V1 x V2)
;                                          [default]
;                               'xz'  :  horizontal axis parallel to (V1 x V2) and
;                                          vertical axis parallel to V1
;                               'yz'  :  horizontal axis defined by (V1 x V2) x V1
;                                          and vertical axis (V1 x V2)
;                             [Default = 'xy']
;               DFMIN    :  Scalar [numeric] defining the minimum allowable phase space
;                             density to plot, which is useful for ion distributions with
;                             large angular gaps in data (prevents lower bound from
;                             falling below DFMIN)
;                             [Default = 1d-20]
;               DFMAX    :  Scalar [numeric] defining the maximum allowable phase space
;                             density to plot, which is useful for distributions with
;                             data spikes (prevents upper bound from exceeding DFMAX)
;                             [Default = 1d-2]
;               DFRA     :  [2]-Element [numeric] array specifying the VDF range in phase
;                             space density [e.g., # s^(+3) km^(-3) cm^(-3)] for the
;                             cuts and contour plots
;                             [Default = [MIN(VDF),MAX(VDF)]]
;               V_0X     :  Scalar [float/double] defining the velocity [km/s] along the
;                             X-Axis (horizontal) to shift the location where the
;                             perpendicular (vertical) cut of the DF will be performed
;                             [Default = 0.0]
;               V_0Y     :  Scalar [float/double] defining the velocity [km/s] along the
;                             Y-Axis (vertical) to shift the location where the
;                             parallel (horizontal) cut of the DF will be performed
;                             [Default = 0.0]
;               C_LOG    :  If set, routine will compute and plot VDF in logarithmic
;                             instead of linear space (good for sparse data)
;                             ***  Still Testing this keyword  ***
;                             [Default = FALSE]
;               NGRID    :  Scalar [numeric] defining the number of grid points in each
;                             direction to use when triangulating the data.  The input
;                             will be limited to values between 30 and 300.
;                             [Default = 101]
;               SLICE2D  :  If set, routine will return a 2D slice instead of a 3D
;                             projection
;                             [Default = FALSE]
;               P_LOG    :  If set, routine will compute the VDF in linear space but
;                             plot the base-10 log of the VDF.  If set, this keyword
;                             supercedes the C_LOG keyword and shuts it off to avoid
;                             infinite plot range errors, among other issues
;                             [Default = FALSE]
;               P_TITLE  :  Scalar [string] defining the plot title for the contour plot
;                             [Default = 'Contours of constant PSD']
;               ONE_C    :  [N]-Element [float/double] array defining particle VDF
;                             one-count level in units of phase space density
;                             [e.g., # s^(+3) km^(-3) cm^(-3)]
;                             [Default = FALSE]
;               STRAHL   :  If set, routine will output statements declaring the strahl
;                             direction to the plot so long as the EX_INFO is properly
;                             set and defined with finite/real data
;                             [Default = FALSE]
;               GET_ROT  :  If set, routine will skip the plotting and just return the
;                             structure returned by rotate_and_triangulate_dfs.pro
;                             [Default = FALSE]
;               S_SIGN   :  Scalar [integer/long] defining the sign to apply to the
;                             computed strahl direction from find_strahl_direction.pro
;                             for times when the sun direction is nearly orthogonal to
;                             the quasi-static magnetic field and the strahl (as seen
;                             in plotted VDFs) is in the "wrong" direction.  If the value
;                             is positive, then the output from find_strahl_direction.pro
;                             will be used, otherwise the sign will flip.
;                             [Default = +1]
;               CLOSED   :  If set, routine will only plot the closed contours
;                             [Default = FALSE]
;               KEEPNAN  :  If set, routine will keep track of places where NaNs were
;                             originally located and replace them if they are interpolated
;                             out
;               PSTATS   :  [N]-Element [float/double] array defining particle VDF
;                             Poisson statistics in phase space density units
;                             [i.e., s^(3) km^(-3) cm^(-3)]
;               RMBELOW  :  Scalar [numeric] defining the speed [km/s] below which all
;                             data will be killed before plotting
;                             [Default = 0]
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [none of the following have default settings]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               CIRCS    :  [C]-Element [structure] array containing the center
;                             locations and radii of circles the user wishes to
;                             project onto the contour and cut plots, each with
;                             the following format:
;                               VRAD  :  Scalar defining the velocity radius of the
;                                          circle to project centered at {VOX,VOY}
;                               VOX   :  Scalar defining the velocity offset along
;                                          X-Axis [Default = 0.0]
;                               VOY   :  Scalar defining the velocity offset along
;                                          Y-Axis [Default = 0.0]
;               EX_VECS  :  [V]-Element [structure] array containing extra vectors the
;                             user wishes to project onto the contour, each with
;                             the following format:
;                               VEC   :  [3]-Element [numeric] array of 3-vectors in the
;                                          same coordinate system as VELXYZ to be
;                                          projected onto the contour plot
;                                          [e.g. VEC[0] = along X-Axis]
;                               NAME  :  Scalar [string] used as a name for each VEC
;                                          to output onto the contour plot
;                                          [Default = 'Vec_j', j = index of EX_VECS]
;               EX_INFO  :  Scalar [structure] containing information relevant to the
;                             VDF with the following format [*** units matter here ***]:
;                               SCPOT  :  Scalar [numeric] defining the spacecraft
;                                           electrostatic potential [eV] at the time of
;                                           the VDF
;                               VSW    :  [3]-Element [numeric] array defining to the
;                                           bulk flow velocity [km/s] 3-vector at the
;                                           time of the VDF
;                               MAGF   :  [3]-Element [numeric] array defining to the
;                                           quasi-static magnetic field [nT] 3-vector at
;                                           the time of the VDF
;               BIMAX    :  [6]-Element [numeric] array where each element is defined by
;                             the following quantities:
;                             PARAM[0] = Number Density [cm^(-3)]
;                             PARAM[1] = Parallel Thermal Speed [km/s]
;                             PARAM[2] = Perpendicular Thermal Speed [km/s]
;                             PARAM[3] = Parallel Drift Speed [km/s]
;                             PARAM[4] = Perpendicular Drift Speed [km/s]
;                             PARAM[5] = *** Not Used Here ***
;                           If set, the routine will output 1D cuts of a model
;                             bi-Maxwellian VDF defined by the above parameters
;                             [Default = FALSE]
;               BIKAP    :  [6]-Element [numeric] array where each element is defined by
;                             the following quantities:
;                             PARAM[0] = Number Density [cm^(-3)]
;                             PARAM[1] = Parallel Thermal Speed [km/s]
;                             PARAM[2] = Perpendicular Thermal Speed [km/s]
;                             PARAM[3] = Parallel Drift Speed [km/s]
;                             PARAM[4] = Perpendicular Drift Speed [km/s]
;                             PARAM[5] = Kappa Value
;                           If set, the routine will output 1D cuts of a model
;                             bi-kappa VDF defined by the above parameters
;                             [Default = FALSE]
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               DAT_OUT  :  Set to a named variable to return all the relevant data
;                             used to create the contour plot and cuts of the VDF
;               ROT_OUT  :  Set to a named variable to return a structure containing
;                             the rotated and triangulated data and rotation matrices,
;                             i.e., the output from rotate_and_triangulate_dfs.pro
;               F3D_QH   :  Set to a named variable to return the 3D array of phase
;                             space densities triangulated onto a regular grid
;
;   CHANGED:  1)  Fixed a bug that occurs when VDF input contains zeros
;                                                                   [05/16/2016   v1.0.1]
;             2)  Fixed a bug that occurs when user sets the EX_INFO keyword
;                                                                   [05/17/2016   v1.0.2]
;             3)  Added keyword: C_LOG
;                                                                   [05/26/2017   v1.0.3]
;             4)  Cleaned up
;                                                                   [05/26/2017   v1.0.4]
;             5)  Added keywords: SLICE2D and NGRID
;                                                                   [05/27/2017   v1.1.0]
;             6)  Added keyword: P_LOG
;                                                                   [05/30/2017   v1.1.1]
;             7)  Added keywords: P_TITLE and DAT_OUT
;                                                                   [07/26/2017   v1.1.2]
;             8)  No longer calls log10_tickmarks.pro,
;                   now calls get_power_of_ten_ticks.pro
;                                                                   [08/01/2017   v1.1.3]
;             9)  Added ONE_C keyword and
;                   now outputs the value of VFRAME to inform the user of the
;                   currently used reference frame
;                                                                   [08/24/2017   v1.2.0]
;            10)  Fixed an issue that occurs when user wants small VLIM with proper
;                   VFRAME setting that was previously causing the default setting to
;                   be used
;                                                                   [02/28/2018   v1.2.1]
;            11)  Added BIMAX keyword and
;                   updated Man. page and changed other minor things
;                                                                   [04/02/2018   v1.2.2]
;            12)  Added BIKAP keyword
;                                                                   [04/04/2018   v1.2.3]
;            13)  Added STRAHL keyword and
;                   Now calls find_strahl_direction.pro and
;                   outputs the direction to the plot if the EX_INFO and STRAHL keywords
;                   are properly set
;                                                                   [04/19/2018   v1.2.4]
;            14)  Altered output structure to now return information regarding the
;                   one-count level
;                                                                   [05/07/2018   v1.2.5]
;            15)  Added keywords:  GET_ROT and ROT_OUT
;                                                                   [05/07/2018   v1.2.6]
;            16)  Now calls get_rotated_and_triangulated_vdf.pro and no longer calls
;                   rot_matrix_array_dfs.pro, rel_lorentz_trans_3vec.pro, or
;                   rotate_and_triangulate_dfs.pro and
;                   moved some error handling to defaults_vdf_contour_plot.pro
;                                                                   [05/09/2018   v1.3.0]
;            17)  Increased line and character thickness when saving to PS files
;                                                                   [05/23/2018   v1.3.1]
;            18)  Added error handling for non-finite VEC1 and/or VEC2 inputs
;                                                                   [06/19/2018   v1.3.2]
;            19)  Added error handling for case where user does not supply
;                   EX_INFO structure
;                                                                   [07/02/2018   v1.3.3]
;            20)  Added S_SIGN keyword to correct strahl direction for events where
;                   the sun direction is nearly orthogonal to Bo and the strahl is
;                   not along the direction predicted by find_strahl_direction.pro
;                                                                   [08/07/2018   v1.3.4]
;            21)  Fixed an issue where the one-count data does not return a valid
;                   triangulated structure
;                                                                   [04/10/2019   v1.3.5]
;            22)  Added keywords:  CLOSED, KEEPNAN, and F3D_QH
;                                                                   [04/12/2019   v1.3.6]
;            23)  Added PSTATS keyword
;                                                                   [07/06/2021   v1.3.7]
;            24)  Added keyword:  RMBELOW
;                                                                   [11/01/2021   v1.3.8]
;            25)  Fixed a typo in a structure tag reference for the Poisson stats
;                                                                   [01/21/2022   v1.3.9]
;
;   NOTES:      
;               1)  Setting DFRA trumps any values set in DFMIN and DFMAX
;               2)  All inputs will be altered on output
;               3)  All keywords will be altered on output
;               4)  There are checks to make sure user's settings cannot produce useless
;                     plots, e.g., V_0X and V_0Y cannot fall outside 80% of VLIM
;               5)  There must be at least 10 finite VDF values with associated finite
;                     VELXYZ vector magnitudes and those ≥10 VDF values must be unique
;               6)  Velocity and VDF units should be 'km/s' and 's^(3) cm^(-3) km^(-3)'
;                     on input since output results and axes labels assume this
;               7)  If set, P_LOG will supercede the C_LOG keyword settings
;               8)  It is generally a good idea to set the SLICE2D keyword
;
;  REFERENCES:  
;               1)  Carlson et al., "An instrument for rapidly measuring plasma
;                      distribution functions with high resolution,"
;                      Adv. Space Res. Vol. 2, pp. 67-70, 1983.
;               2)  Curtis et al., "On-board data analysis techniques for space plasma
;                      particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372, 1989.
;               3)  Lin et al., "A Three-Dimensional Plasma and Energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125, 1995.
;               4)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                      Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst., 1998.
;               5)  Wilson III, L.B., et al., "Low-frequency whistler waves and shocklets
;                      observed at quasi-perpendicular interplanetary shocks,"
;                      J. Geophys. Res. 114, pp. A10106, 2009.
;               6)  Wilson III, L.B., et al., "Large-amplitude electrostatic waves
;                      observed at a supercritical interplanetary shock,"
;                      J. Geophys. Res. 115, pp. A12104, 2010.
;               7)  Wilson III, L.B., et al., "Observations of electromagnetic whistler
;                      precursors at supercritical interplanetary shocks,"
;                      Geophys. Res. Lett. 39, pp. L08109, 2012.
;               8)  Wilson III, L.B., et al., "Electromagnetic waves and electron
;                      anisotropies downstream of supercritical interplanetary shocks,"
;                      J. Geophys. Res. 118(1), pp. 5--16, 2013a.
;               9)  Wilson III, L.B., et al., "Shocklets, SLAMS, and field-aligned ion
;                      beams in the terrestrial foreshock," J. Geophys. Res. 118(3),
;                      pp. 957--966, 2013b.
;              10)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 1. Analysis Techniques and Methodology,"
;                      J. Geophys. Res. 119(8), pp. 6455--6474, 2014a.
;              11)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 2. Waves and Dissipation,"
;                      J. Geophys. Res. 119(8), pp. 6475--6495, 2014b.
;              12)  Wilson III, L.B., et al., "Relativistic electrons produced by
;                      foreshock disturbances observed upstream of the Earth’s bow
;                      shock," Phys. Rev. Lett. 117(21), pp. 215101, 2016.
;
;   CREATED:  04/07/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/21/2022   v1.3.9
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO general_vdf_contour_plot,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,VLIM=vlim,  $
                             NLEV=nlev,XNAME=xname,YNAME=yname,SM_CUTS=sm_cuts,       $
                             SM_CONT=sm_cont,NSMCUT=nsmcut,NSMCON=nsmcon,PLANE=plane, $
                             DFMIN=dfmin,DFMAX=dfmax,DFRA=dfra,V_0X=v_0x,V_0Y=v_0y,   $
                             C_LOG=c_log,NGRID=ngrid,SLICE2D=slice2d,P_LOG=p_log,     $
                             P_TITLE=p_title,ONE_C=one_c,DAT_OUT=dat_out,             $
                             CIRCS=circs,EX_VECS=ex_vecs,EX_INFO=ex_info,             $
                             BIMAX=bimax,BIKAP=bikap,STRAHL=strahl,GET_ROT=get_rot,   $
                             ROT_OUT=rot_out,S_SIGN=s_sign,CLOSED=closed,             $
                             KEEPNAN=keep_nans,F3D_QH=f3d_qh,PSTATS=pstats,           $
                             RMBELOW=rmbelow

FORWARD_FUNCTION is_a_number, is_a_3_vector, mag__vec, test_plot_axis_range,              $
                 defaults_vdf_contour_plot, rot_matrix_array_dfs, rel_lorentz_trans_3vec, $
                 rotate_and_triangulate_dfs, find_1d_cuts_2d_dist, format_vector_string,  $
                 log10_tickmarks, routine_version, find_strahl_direction
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
vec_str        = ['x','y','z']
vec_col        = [250,150,50]
;;  Dummy plot labels/titles
def_units_vdf  = '[sec!U3!N km!U-3!N cm!U-3!N'+']'
def_cut_yttl   = '1D VDF Cuts'+'!C'+def_units_vdf[0]
def_cut_xttl   = 'Velocity [1000 km/sec]'
def_con_pttl   = 'Contours of constant PSD'
;;  Position of contour plot [square]
;;               Xo    Yo    X1    Y1
pos_0con       = [0.22941,0.515,0.77059,0.915]
;;  Position of 1st DF cuts [square]
pos_0cut       = [0.22941,0.050,0.77059,0.450]
;;  Dummy error messages
no_inpt_msg    = 'User must supply a VDF and a corresponding array of 3-vector velocities...'
badvfor_msg    = 'Incorrect input format:  VDF and VELXYZ must have the same size first dimensions...'
nofinite_mssg  = 'Not enough finite and unique data was supplied...'
;;  Defined user symbol for outputing locations of data on contour
xxo            = FINDGEN(17)*(!PI*2./16.)
USERSYM,0.27*COS(xxo),0.27*SIN(xxo),/FILL
;;  Default model VDF settings
param          = DBLARR(6L)
kparm          = param
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (is_a_number(vdf,/NOMSSG) EQ 0) OR  $
                 (is_a_3_vector(velxyz,V_OUT=vxyz,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  Incorrect inputs --> exit without plotting
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
df1d           = REFORM(vdf)
szdvdf         = SIZE(df1d,/DIMENSIONS)
szdvel         = SIZE(vxyz,/DIMENSIONS)
IF ((szdvdf[0] NE szdvel[0]) OR (szdvdf[0] LT 10)) THEN BEGIN
  ;;  Incorrect input format --> exit without plotting
  MESSAGE,badvfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Now that we know these are at least formatted correct, test values
vmag           = mag__vec(vxyz,/NAN)
IF ((TOTAL(FINITE(df1d)) LT 10) OR (TOTAL(FINITE(vmag)) LT 10)) THEN BEGIN
  ;;  VDF or VELXYZ have fewer than 10 finite points --> exit without plotting
  MESSAGE,'0: '+nofinite_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Make sure values are unique and have a finite range
def_dfra       = [MIN(ABS(df1d),/NAN),MAX(ABS(df1d),/NAN)]
IF (test_plot_axis_range(def_dfra,/NOMSSG) EQ 0) THEN BEGIN
  ;;  VDF is either all one value or has no finite values --> exit without plotting
  MESSAGE,'1: '+nofinite_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords with default options
;;----------------------------------------------------------------------------------------
tests          = defaults_vdf_contour_plot(df1d,vxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,  $
                                           VLIM=vlim,NLEV=nlev,XNAME=xname,YNAME=yname,  $
                                           SM_CUTS=sm_cuts,SM_CONT=sm_cont,NSMCUT=nsmcut,$
                                           NSMCON=nsmcon,PLANE=plane,DFMIN=dfmin,        $
                                           DFMAX=dfmax,DFRA=dfra,V_0X=v_0x,V_0Y=v_0y,    $
                                           STRAHL=strahl,NGRID=ngrid,SLICE2D=slice2d,    $
                                           P_TITLE=p_title,ONE_C=one_c,BPARM=bimax,      $
                                           KPARM=bikap,S_SIGN=s_sign,PSTATS=pstats,      $
                                           RMBELOW=rmbelow                               )
IF (N_ELEMENTS(tests) EQ 1) THEN RETURN      ;;  Something failed --> exit without plotting
;;  Check some outputs from default routine
nm             = ngrid[0]
slice_on       = slice2d[0]
con_pttl       = p_title[0]
bimax_on       = (N_ELEMENTS(bimax) EQ 6)
bikap_on       = (N_ELEMENTS(bikap) EQ 6)
IF (bimax_on[0]) THEN param = bimax
IF (bikap_on[0]) THEN kparm = bikap
kk             = N_ELEMENTS(df1d)                      ;;  # of phase space density values
onec_on        = (N_ELEMENTS(one_c) EQ kk[0])
IF (onec_on[0]) THEN vdf1c = one_c
pstt_on        = (N_ELEMENTS(pstats) EQ kk[0])
IF (pstt_on[0]) THEN vdf1p = pstats
;;  Check P_LOG
plog_on        = (N_ELEMENTS(p_log) EQ 1) AND KEYWORD_SET(p_log)
;;  Check C_LOG
clog_on        = (N_ELEMENTS(c_log) GE 1) AND KEYWORD_SET(c_log) AND ~plog_on[0]
IF (clog_on[0]) THEN BEGIN
  ;;  User wants to plot in log-space, not linear space
  df1do   = ALOG10(df1d)
  dfrao   = ALOG10(dfra)
  plog_on = 1b           ;;  Turn on logarithmic plotting
ENDIF ELSE BEGIN
  df1do   = df1d
  dfrao   = dfra
ENDELSE
;;  Check CLOSED
IF KEYWORD_SET(closed) THEN close_only = 1b ELSE close_only = 0b
;;  Check KEEPNAN
IF KEYWORD_SET(keep_nans) THEN nans_on = 1b ELSE nans_on = 0b
;;  Check RMBELOW
IF (rmbelow[0] GT 0) THEN rmlow = 1b ELSE rmlow = 0b
;;----------------------------------------------------------------------------------------
;;  Rotate velocities and VDF into new coordinate basis and triangulate
;;----------------------------------------------------------------------------------------
r_vels         = get_rotated_and_triangulated_vdf(vxyz,df1d,VLIM=vlim[0],C_LOG=clog_on[0],$
                                                  NGRID=nm[0],SLICE2D=slice_on[0],        $
                                                  VFRAME=vframe,VEC1=vec1,VEC2=vec2,      $
                                                  P_LOG=plog_on,ROTMXY=rotm,ROTMZY=rotz,  $
                                                  F3D_QH=f3d_qh                           )
;;  Check if user is only looking for the rotation structure
IF KEYWORD_SET(get_rot) THEN BEGIN
  rot_out = r_vels
  ;;  Return to user
  RETURN
ENDIF
IF (onec_on[0]) THEN BEGIN
  ;;  Compute one-count equivalent
  r_onec         = get_rotated_and_triangulated_vdf(vxyz,vdf1c,VLIM=vlim[0],C_LOG=clog_on[0],$
                                                    NGRID=nm[0],SLICE2D=slice_on[0],         $
                                                    P_LOG=plog_on,VFRAME=vframe,             $
                                                    VEC1=vec1,VEC2=vec2                      )
  IF (SIZE(r_onec,/TYPE) NE 8) THEN onec_on = 0b
ENDIF
IF (pstt_on[0]) THEN BEGIN
  ;;  Compute one-count equivalent
  r_pstt         = get_rotated_and_triangulated_vdf(vxyz,vdf1p,VLIM=vlim[0],C_LOG=clog_on[0],$
                                                    NGRID=nm[0],SLICE2D=slice_on[0],         $
                                                    P_LOG=plog_on,VFRAME=vframe,             $
                                                    VEC1=vec1,VEC2=vec2                      )
  IF (SIZE(r_pstt,/TYPE) NE 8) THEN pstt_on = 0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords without default options
;;----------------------------------------------------------------------------------------
;;  Check CIRCS
IF (SIZE(circs,/TYPE) EQ 8) THEN BEGIN
  ;;  Check structure format
  def_tags       = ['vrad','vox','voy']
  tags           = STRLOWCASE(TAG_NAMES(circs))
  nmatch         = 0
  FOR j=0L, 2L DO nmatch += TOTAL(def_tags[j] EQ tags)
  IF (nmatch[0] EQ 3) THEN BEGIN
    ;;  User set correct tags --> check value formats
    circs_on   = is_a_number(circs[0].(0),/NOMSSG) AND is_a_number(circs[0].(1),/NOMSSG) $
                 AND is_a_number(circs[0].(2),/NOMSSG)
    IF (circs_on[0]) THEN circle_str = circs  ;;  correct format --> define new structure(s)
  ENDIF
ENDIF ELSE circs_on = 0b
;;  Check EX_VECS
IF (SIZE(ex_vecs,/TYPE) EQ 8) THEN BEGIN
  ;;  Check structure format
  def_tags       = ['vec','name']
  tags           = STRLOWCASE(TAG_NAMES(ex_vecs))
  nmatch         = 0
  FOR j=0L, 1L DO nmatch += TOTAL(def_tags[j] EQ tags)
  IF (nmatch[0] EQ 2) THEN BEGIN
    ;;  User set correct tags --> check value formats
    exvec_on   = is_a_3_vector(ex_vecs[0].(0),/NOMSSG) AND (SIZE(ex_vecs[0].(1),/TYPE) EQ 7)
    IF (exvec_on[0]) THEN exvec_str = ex_vecs  ;;  correct format --> define new structure(s)
  ENDIF
ENDIF ELSE exvec_on = 0b
;;  Check EX_INFO
IF (SIZE(ex_info,/TYPE) EQ 8) THEN BEGIN
  ;;  Check structure format
  def_tags       = ['scpot','vsw','magf']
  tags           = STRLOWCASE(TAG_NAMES(ex_info))
  nmatch         = 0
  FOR j=0L, 2L DO nmatch += TOTAL(def_tags[j] EQ tags)
  IF (nmatch[0] EQ 3) THEN BEGIN
    ;;  User set correct tags --> check value formats
    tran_on    =   is_a_number(ex_info[0].(0),/NOMSSG) AND $
                 is_a_3_vector(ex_info[0].(1),/NOMSSG) AND $
                 is_a_3_vector(ex_info[0].(2),/NOMSSG)
    IF (tran_on[0]) THEN tran_info = ex_info  ;;  correct format --> define new structure(s)
  ENDIF
ENDIF ELSE tran_on = 0b
;;----------------------------------------------------------------------------------------
;;  Define parameters for contour plots
;;----------------------------------------------------------------------------------------
def_con_xttl   = '(V dot '+xname[0]+') [1000 km/s]'
def_con_yttl   = '('+xname[0]+' x '+yname[0]+') x '+xname[0]+' [1000 km/s]'
def_con_zttl   = '('+xname[0]+' x '+yname[0]+') [1000 km/s]'
;;  Define regularly gridded velocities (for contour plots) [km/s]
;;    [Note:  These should equal the outputs of str_??.V?_GRID_?? below]
vx2d           = r_vels.VX2D
vy2d           = r_vels.VY2D
nnct           = N_ELEMENTS(vx2d)
IF (rmlow[0]) THEN BEGIN
  v2dx          = vx2d # REPLICATE(1d0,nnct[0])
  v2dy          = REPLICATE(1d0,nnct[0]) # vy2d
  v2dspd        = SQRT(v2dx^2d0 + v2dy^2d0)
  spdmin        = rmbelow[0]
  badlow        = WHERE(v2dspd LE spdmin[0],bdlow)
ENDIF ELSE bdlow = 0L

CASE plane[0] OF
  'xy'  : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  plot Y vs. X
    ;;------------------------------------------------------------------------------------
    ;;  Define rotation matrix
    rmat     = REFORM(rotm[0,*,*])
    ;;  Define contour axis titles
    con_xttl = def_con_xttl[0]
    con_yttl = def_con_yttl[0]
    ;;  Define data projection
    df2d     = r_vels.PLANE_XY.DF2D_XY
    ;;  Define actual velocities for contour plot
    vxpts    = r_vels.PLANE_XY.VELX_XY
    vypts    = r_vels.PLANE_XY.VELY_XY
    vzpts    = r_vels.PLANE_XY.VELZ_XY
    ;;  Define one-count equivalent
    IF (onec_on[0]) THEN df1c = r_onec.PLANE_XY.DF2D_XY
    ;;  Define Poisson statistics equivalent
    IF (pstt_on[0]) THEN df1p = r_pstt.PLANE_XY.DF2D_XY
    ;;  Define elements [x,y]
    gels     = [0L,1L]
  END
  'xz'  : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  plot X vs. Z
    ;;------------------------------------------------------------------------------------
    ;;  Define rotation matrix
    rmat     = REFORM(rotm[0,*,*])
    ;;  Define contour axis titles
    con_xttl = def_con_zttl[0]
    con_yttl = def_con_xttl[0]
    ;;  Define data projection
    df2d     = r_vels.PLANE_XZ.DF2D_XZ
    ;;  define actual velocities for contour plot
    vxpts    = r_vels.PLANE_XZ.VELX_XZ
    vypts    = r_vels.PLANE_XZ.VELY_XZ
    vzpts    = r_vels.PLANE_XZ.VELZ_XZ
    ;;  Define one-count equivalent
    IF (onec_on[0]) THEN df1c = r_onec.PLANE_XZ.DF2D_XZ
    ;;  Define Poisson statistics equivalent
    IF (pstt_on[0]) THEN df1p = r_pstt.PLANE_XZ.DF2D_XZ
    ;;  Define elements [x,y]
    gels     = [2L,0L]
  END
  'yz'  : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  plot Z vs. Y
    ;;------------------------------------------------------------------------------------
    ;;  Define rotation matrix
    rmat     = REFORM(rotz[0,*,*])
    ;;  Define contour axis titles
    con_xttl = def_con_yttl[0]
    con_yttl = def_con_zttl[0]
    ;;  Define data projection
    df2d     = r_vels.PLANE_YZ.DF2D_YZ
    ;;  define actual velocities for contour plot
    vxpts    = r_vels.PLANE_YZ.VELX_YZ
    vypts    = r_vels.PLANE_YZ.VELY_YZ
    vzpts    = r_vels.PLANE_YZ.VELZ_YZ
    ;;  Define one-count equivalent
    IF (onec_on[0]) THEN df1c = r_onec.PLANE_YZ.DF2D_YZ
    ;;  Define Poisson statistics equivalent
    IF (pstt_on[0]) THEN df1p = r_pstt.PLANE_YZ.DF2D_YZ
    ;;  define elements [x,y]
    gels     = [0L,1L]
  END
  ELSE  : BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  use default:  Y vs. X
    ;;------------------------------------------------------------------------------------
    ;;  Define rotation matrix
    rmat     = REFORM(rotm[0,*,*])
    ;;  Define contour axis titles
    con_xttl = xaxist
    con_yttl = yaxist
    ;;  Define data projection
    df2d     = r_vels.PLANE_XY.DF2D_XY
    ;;  Define actual velocities for contour plot
    vxpts    = r_vels.PLANE_XY.VELX_XY
    vypts    = r_vels.PLANE_XY.VELY_XY
    vzpts    = r_vels.PLANE_XY.VELZ_XY
    ;;  Define one-count equivalent
    IF (onec_on[0]) THEN df1c = r_onec.PLANE_XY.DF2D_XY
    ;;  Define Poisson statistics equivalent
    IF (pstt_on[0]) THEN df1p = r_pstt.PLANE_XY.DF2D_XY
    ;;  Define elements [x,y]
    gels     = [0L,1L]
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Remove data below minimim speed if desired
;;----------------------------------------------------------------------------------------
IF (rmlow[0] AND bdlow[0] GT 0) THEN df2d[badlow] = d
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define cut through f(x,y) at offset {V_0X, V_0Y}
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
cuts_struc     = find_1d_cuts_2d_dist(df2d,vx2d,vy2d,X_0=v_0x,Y_0=v_0y)
vdf_para_cut   = cuts_struc.X_1D_FXY           ;;  horizontal 1D cut
vdf_perp_cut   = cuts_struc.Y_1D_FXY           ;;  vertical 1D cut
vpara_cut      = cuts_struc.X_CUT_COORD*1d-3   ;;  km --> Mm  (looks better when plotted)
vperp_cut      = cuts_struc.Y_CUT_COORD*1d-3   ;;  km --> Mm  (looks better when plotted)
hori_crsshair  = cuts_struc.X_XY_COORD*1d-3    ;;  [K,2]-Element array, VAL[*,0] = X, VAL[*,1] = Y
vert_crsshair  = cuts_struc.Y_XY_COORD*1d-3
hori_offset    = v_0x[0]*1d-3                  ;;  horizontal offset of crosshairs
vert_offset    = v_0y[0]*1d-3                  ;;  vertical offset of crosshairs
;;  Define one-count equivalent
IF (onec_on[0]) THEN BEGIN
  onec_struc     = find_1d_cuts_2d_dist(df1c,vx2d,vy2d,X_0=v_0x,Y_0=v_0y)
  onec_cpara     = onec_struc.X_1D_FXY         ;;  horizontal 1D cut
  onec_cperp     = onec_struc.Y_1D_FXY         ;;  horizontal 1D cut
ENDIF
;;  Define Poisson statistics equivalent
IF (pstt_on[0]) THEN BEGIN
  pstt_struc     = find_1d_cuts_2d_dist(df1p,vx2d,vy2d,X_0=v_0x,Y_0=v_0y)
  pstt_cpara     = pstt_struc.X_1D_FXY         ;;  horizontal 1D cut
  pstt_cperp     = pstt_struc.Y_1D_FXY         ;;  horizontal 1D cut
ENDIF
;;  Define bi-Maxwellian cuts (if set)
IF (bimax_on[0]) THEN BEGIN
  bimax_vdf     = bimaxwellian(vx2d,vy2d,param)
  bimax_struc   = find_1d_cuts_2d_dist(bimax_vdf,vx2d,vy2d,X_0=0d0,Y_0=0d0)
  bimax_cpara   = bimax_struc.X_1D_FXY         ;;  horizontal 1D cut
  bimax_cperp   = bimax_struc.Y_1D_FXY         ;;  vertical 1D cut
ENDIF
;;  Define bi-kappa cuts (if set)
IF (bikap_on[0]) THEN BEGIN
  bikap_vdf     = bikappa(vx2d,vy2d,kparm)
  bikap_struc   = find_1d_cuts_2d_dist(bikap_vdf,vx2d,vy2d,X_0=0d0,Y_0=0d0)
  bikap_cpara   = bikap_struc.X_1D_FXY         ;;  horizontal 1D cut
  bikap_cperp   = bikap_struc.Y_1D_FXY         ;;  vertical 1D cut
ENDIF
;;----------------------------------------------------------------------------------------
;;  Remove data below minimim speed if desired
;;----------------------------------------------------------------------------------------
IF (rmlow[0] AND bdlow[0] GT 0) THEN BEGIN
  badfcx         = WHERE(ABS(vpara_cut)*1d3 LE spdmin[0],bdfcx)
  badfcy         = WHERE(ABS(vperp_cut)*1d3 LE spdmin[0],bdfcy)
  IF (bdfcx[0] GT 0) THEN BEGIN
    vdf_para_cut[badfcx] = d
    IF (onec_on[0])  THEN onec_cpara[badfcx] = d
    IF (pstt_on[0])  THEN pstt_cpara[badfcx] = d
  ENDIF
  IF (bdfcy[0] GT 0) THEN BEGIN
    vdf_perp_cut[badfcy] = d
    IF (onec_on[0])  THEN onec_cperp[badfcy] = d
    IF (pstt_on[0])  THEN pstt_cperp[badfcy] = d
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define the 2D projection of the extra vectors in EX_VECS
;;----------------------------------------------------------------------------------------
IF (exvec_on[0]) THEN BEGIN
  n_exvec   = N_ELEMENTS(exvec_str)
  dumb      = {VEC:REPLICATE(d,3L),NAME:''}
  exvec_rot = REPLICATE(dumb[0],n_exvec[0])
  vec_cols  = LINDGEN(n_exvec[0])*(250L - 30L)/(n_exvec[0] - 1L) + 30L
  FOR j=0L, n_exvec[0] - 1L DO BEGIN
    tvec   = exvec_str[j].VEC
    tnam   = exvec_str[j].NAME
    ;;  Normalize vector first
    uvec   = REFORM(unit_vec(tvec))
    ;;  Rotate
    rvec   = REFORM(rmat ## uvec)
    ;;  Normalize to in-plane values only
    uv2d   = rvec[gels]/SQRT(TOTAL(rvec[gels]^2,/NAN))
    ;;  Scale to plot output
    v_mfac = (vlim[0]*95d-2)*1d-3        ;;  km --> Mm  (looks better when plotted)
    vscld  = uv2d*v_mfac[0]
    ;;  Fill j-th structure
    exvec_rot[j].VEC  = vscld
    exvec_rot[j].NAME = tnam[0]
  ENDFOR
ENDIF
;;----------------------------------------------------------------------------------------
;;  Re-scale values in CIRCS
;;----------------------------------------------------------------------------------------
IF (circs_on[0]) THEN BEGIN
  ;;  User wants to overplot circles of constant energy
  n_circs    = N_ELEMENTS(circle_str)
  nn         = 100L
  thetas     = DINDGEN(nn[0])*2d0*!DPI/(nn[0] - 1L)
  vc_lx      = DBLARR(n_circs[0])             ;;  Min. X-Location of circle in cut plot
  vc_xx      = DBLARR(n_circs[0])             ;;  Max. X-Location of circle in cut plot
  vc_x       = DBLARR(nn[0],n_circs[0])       ;;  X-Component of circles
  vc_y       = DBLARR(nn[0],n_circs[0])       ;;  Y-Component of circles
  FOR j=0L, n_circs[0] - 1L DO BEGIN
    trad      = circle_str[j].VRAD*1d-3       ;;  km --> Mm  (looks better when plotted)
    tvox      = circle_str[j].VOX*1d-3        ;;  km --> Mm  (looks better when plotted)
    tvoy      = circle_str[j].VOY*1d-3        ;;  km --> Mm  (looks better when plotted)
    ;;  Fill j-th arrays
    vc_x[*,j] = trad[0]*COS(thetas) + tvox[0]
    vc_y[*,j] = trad[0]*SIN(thetas) + tvoy[0]
    vc_lx[j]  = MIN(vc_x[*,j],/NAN)
    vc_xx[j]  = MAX(vc_x[*,j],/NAN)
  ENDFOR
ENDIF
;;----------------------------------------------------------------------------------------
;;  Format EX_INFO output
;;----------------------------------------------------------------------------------------
;;  Make sure dummy strings are defined in case user did not provide EX_INFO structure
sc_pot_str     = 'SC Pot.  :  0.00 [eV]'
vbulk          = format_vector_string(REPLICATE(0d0,3),PREC=2)+' [km/s]'
magf           = format_vector_string(REPLICATE(0d0,3),PREC=2)+' [nT]'
v__out_str     = 'Vbulk    :  '+vbulk[0]
b__out_str     = 'Bo       :  '+magf[0]
IF (tran_on[0]) THEN BEGIN
  ;;  Define string for spacecraft potential output
  scpot          = STRTRIM(STRING(FORMAT='(f10.2)',tran_info[0].SCPOT),2)
  plus           = STRMID(scpot[0],0L,1L) NE '-'
  IF (plus) THEN scpot = '+'+scpot[0]
  sc_pot_str     = 'SC Pot.  :  '+scpot[0]+' [eV]'
  ;;  Define string for bulk flow velocity and quasi-static magnetic field outputs
  vbulk          = format_vector_string(tran_info[0].VSW,PREC=2)+' [km/s]'
  magf           = format_vector_string(tran_info[0].MAGF,PREC=2)+' [nT]'
  v__out_str     = 'Vbulk    :  '+vbulk[0]
  b__out_str     = 'Bo       :  '+magf[0]
  ;;  Check if user wants to output info for strahl direction
  IF (strahl[0]) THEN BEGIN
    strahl_dir = find_strahl_direction(tran_info[0].MAGF)
    test       = (strahl_dir[0] NE 0)
    IF (test[0]) THEN BEGIN
      IF (s_sign[0] LT 0) THEN strahl_dir *= -1   ;;  User knows to switch sign
      strahl_out  = 'strahl '+(['','anti-']+'parallel to Bo')[(strahl_dir[0] LT 0)]
    ENDIF ELSE strahl_out = ''
  ENDIF ELSE strahl_out = ''
ENDIF ELSE strahl_out = ''
;;----------------------------------------------------------------------------------------
;;  Format VFRAME output
;;----------------------------------------------------------------------------------------
vframe_str     = format_vector_string(vframe,PREC=2)+' [km/s]'
vframe_out     = 'Vframe    :  '+vframe_str[0]
;;----------------------------------------------------------------------------------------
;;  Define contour levels
;;----------------------------------------------------------------------------------------
df_ran         = dfrao
;;  Define colors for contour levels
minclr         = 30L
c_cols         = minclr[0] + LINDGEN(nlev[0])*(250L - minclr[0])/(nlev[0] - 1L)
;;  Define inputs for log10_tickmarks.pro
IF (clog_on[0]) THEN BEGIN
  range          = df_ran
  df2d01         = REFORM(1d1^df2d,N_ELEMENTS(df2d))
  yrange         = 1d1^df_ran
ENDIF ELSE BEGIN
  range          = ALOG10(df_ran)
  df2d01         = df2d
  yrange         = df_ran
ENDELSE
;;  Define (log-based) contour levels
log10levs      = DINDGEN(nlev[0])*(range[1] - range[0])/(nlev[0] - 1L) + range[0]
;;  Define Y-axis tick marks for cuts plot
tick_str       = get_power_of_ten_ticks(yrange)
;;  Define the tick names, values, and number of ticks
cut_ytn        = tick_str.XTICKNAME
cut_yts        = tick_str.XTICKS
IF (plog_on[0]) THEN BEGIN
  ylog_cut       = 0b
  ymin_cut       = 10
  levels         = log10levs
  cut_ytv        = ALOG10(tick_str.XTICKV)
ENDIF ELSE BEGIN
  ylog_cut       = 1b
  ymin_cut       = 9
  levels         = 1d1^log10levs  ;;  contour level values in phase space density [e.g., s^(+3) cm^(-3) km^(-3)]
  cut_ytv        = tick_str.XTICKV
ENDELSE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Smooth cuts and contour if desired [typically necessary for ions or noisy data]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(sm_cuts) THEN BEGIN
  ;;  Smooth cuts
  vdf_cut_para0  = SMOOTH(vdf_para_cut,nsmcut[0],/NAN,/EDGE_TRUNCATE)
  vdf_cut_perp0  = SMOOTH(vdf_perp_cut,nsmcut[0],/NAN,/EDGE_TRUNCATE)
  ;;  Define one-count equivalent
  IF (onec_on[0]) THEN BEGIN
    onec_cut_par0 = SMOOTH(onec_cpara,nsmcut[0],/NAN,/EDGE_TRUNCATE)
    onec_cut_per0 = SMOOTH(onec_cperp,nsmcut[0],/NAN,/EDGE_TRUNCATE)
  ENDIF
  ;;  Define Poisson statistics equivalent
  IF (pstt_on[0]) THEN BEGIN
    pstt_cut_par0 = SMOOTH(pstt_cpara,nsmcut[0],/NAN,/EDGE_TRUNCATE)
    pstt_cut_per0 = SMOOTH(pstt_cperp,nsmcut[0],/NAN,/EDGE_TRUNCATE)
  ENDIF
  IF (nans_on[0]) THEN BEGIN
    ;;  Replace indices originally having NaNs with NaNs
    bad = WHERE(FINITE(vdf_para_cut) EQ 0,bd)
    IF (bd[0] GT 0) THEN vdf_cut_para0[bad] = d
    bad = WHERE(FINITE(vdf_perp_cut) EQ 0,bd)
    IF (bd[0] GT 0) THEN vdf_cut_perp0[bad] = d
  ENDIF
ENDIF ELSE BEGIN
  vdf_cut_para0  = vdf_para_cut
  vdf_cut_perp0  = vdf_perp_cut
  ;;  Define one-count equivalent
  IF (onec_on[0]) THEN BEGIN
    onec_cut_par0 = onec_cpara
    onec_cut_per0 = onec_cperp
  ENDIF
  ;;  Define Poisson statistics equivalent
  IF (pstt_on[0]) THEN BEGIN
    pstt_cut_par0 = pstt_cpara
    pstt_cut_per0 = pstt_cperp
  ENDIF
ENDELSE
IF KEYWORD_SET(sm_cont) THEN BEGIN
  ;;  Smooth contour
  df2ds0 = SMOOTH(df2d,nsmcon[0],/NAN,/EDGE_TRUNCATE)
  IF (nans_on[0]) THEN BEGIN
    ;;  Replace indices originally having NaNs with NaNs
    bad = WHERE(FINITE(df2d) EQ 0,bd)
    IF (bd[0] GT 0) THEN df2ds0[bad] = d
  ENDIF
ENDIF ELSE BEGIN
  df2ds0 = df2d
ENDELSE
;;  Check if user wants to plot in logarithmic space but computed everything linearly
IF (plog_on[0] AND ~clog_on[0]) THEN BEGIN
  ;;  Convert to logarithmic space
  df2ds          = ALOG10(df2ds0)
  vdf_cut_para   = ALOG10(vdf_cut_para0)
  vdf_cut_perp   = ALOG10(vdf_cut_perp0)
  cut_yrange     = ALOG10(df_ran)
  ;;  Define one-count equivalent
  IF (onec_on[0]) THEN BEGIN
    onec_cut_para = ALOG10(onec_cut_par0)
    onec_cut_perp = ALOG10(onec_cut_per0)
  ENDIF
  ;;  Define Poisson statistics equivalent
  IF (pstt_on[0]) THEN BEGIN
    pstt_cut_para = ALOG10(pstt_cut_par0)
    pstt_cut_perp = ALOG10(pstt_cut_per0)
  ENDIF
  IF (bimax_on[0]) THEN BEGIN
    bimax_cut_para = ALOG10(bimax_cpara)
    bimax_cut_perp = ALOG10(bimax_cperp)
  ENDIF
  IF (bikap_on[0]) THEN BEGIN
    bikap_cut_para = ALOG10(bikap_cpara)
    bikap_cut_perp = ALOG10(bikap_cperp)
  ENDIF
ENDIF ELSE BEGIN
  df2ds          = df2ds0
  vdf_cut_para   = vdf_cut_para0
  vdf_cut_perp   = vdf_cut_perp0
  cut_yrange     = df_ran
  ;;  Define one-count equivalent
  IF (onec_on[0]) THEN BEGIN
    onec_cut_para = onec_cut_par0
    onec_cut_perp = onec_cut_per0
  ENDIF
  ;;  Define Poisson statistics equivalent
  IF (pstt_on[0]) THEN BEGIN
    pstt_cut_para = pstt_cut_par0
    pstt_cut_perp = pstt_cut_per0
  ENDIF
  IF (bimax_on[0]) THEN BEGIN
    bimax_cut_para = bimax_cpara
    bimax_cut_perp = bimax_cperp
  ENDIF
  IF (bikap_on[0]) THEN BEGIN
    bikap_cut_para = bikap_cpara
    bikap_cut_perp = bikap_cperp
  ENDIF
ENDELSE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define plot limits structures for contour and cuts plots
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
con_xyran      = [-1d0,1d0]*vlim[0]*1d-3     ;;  km  -->  Mm  [just looks better when plotted]
;;  Contour plot setup structure
base_lim_cn    = {XRANGE:con_xyran,XSTYLE:1,XLOG:0,XMINOR:10, $
                  YRANGE:con_xyran,YSTYLE:1,YLOG:0,YMINOR:10, $
                  XTITLE:con_xttl[0],YTITLE:con_yttl[0],      $
                  POSITION:pos_0con,TITLE:con_pttl[0],NODATA:1}
;;  Structures for CONTOUR.PRO
con_lim        = {OVERPLOT:1,LEVELS:levels,NLEVELS:nlev[0],C_COLORS:c_cols}      ;;  should be the same for all planes
;;  Define cut plot setup structures
base_lim_ct    = {XRANGE:con_xyran, XSTYLE:1,XLOG:0,          XTITLE:def_cut_xttl[0],XMINOR:10,           $
                  YRANGE:cut_yrange,YSTYLE:1,YLOG:ylog_cut[0],YTITLE:def_cut_yttl[0],YMINOR:ymin_cut[0],  $
                  POSITION:pos_0cut,TITLE:' ',NODATA:1,YTICKS:cut_yts[0],                                $
                  YTICKV:cut_ytv,YTICKNAME:cut_ytn}
;;  Define routine version
IF (slice_on[0]) THEN vers_suffx = ';;  2D Slice' ELSE vers_suffx = ';;  3D Projection'
vers           = routine_version('general_vdf_contour_plot.pro')+vers_suffx[0]
;;  Set up plot stuff
!P.MULTI       = [0,1,2]
;IF (STRLOWCASE(!D.NAME) EQ 'ps') THEN l_thick  = 3e0 ELSE l_thick  = 2e0
IF (STRLOWCASE(!D.NAME) EQ 'ps') THEN BEGIN
  p_thick  = 3e0          ;;  Plot frame thickness
  l_thick  = 3e0          ;;  Plot line thickness
  c_thick  = 3e0          ;;  Contour line thickness
  chthick  = 3e0          ;;  Character line thickness
ENDIF ELSE BEGIN
  p_thick  = 2e0
  l_thick  = 2e0
  c_thick  = 2e0
  chthick  = 1.5e0
ENDELSE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot Contour
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Set up plot area for contour
PLOT,[0.0,1.0],[0.0,1.0],_EXTRA=base_lim_cn,CHARTHICK=chthick[0],XTHICK=p_thick[0],YTHICK=p_thick[0]
  ;;  Output actual locations of data in plane
  OPLOT,vxpts*1d-3,vypts*1d-3,PSYM=8,SYMSIZE=1.0,COLOR=100L
  ;;  Output contour plot
  IF (close_only[0]) THEN BEGIN
    CONTOUR,df2ds,vx2d*1d-3,vy2d*1d-3,_EXTRA=con_lim,C_THICK=c_thick[0],/PATH_DATA_COORDS,/PATH_DOUBLE,$
                                      PATH_INFO=cpath_info,PATH_XY=cpath_xy
    IF (SIZE(cpath_info,/TYPE) EQ 8) THEN BEGIN
      cpath  = {INFO:cpath_info,XY:cpath_xy}
      lbw_oplot_clines_from_struc,cpath,C_COLORS=c_cols,THICK=c_thick[0],/DATA,CLOSED=1b
    ENDIF
  ENDIF ELSE BEGIN
    ;;  Plot all contours [Default]
    CONTOUR,df2ds,vx2d*1d-3,vy2d*1d-3,_EXTRA=con_lim,C_THICK=c_thick[0]
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  Output arrows for EX_VECS
  ;;--------------------------------------------------------------------------------------
  IF (exvec_on[0]) THEN BEGIN
    xyposi = 94d-2*con_xyran
    FOR j=0L, n_exvec[0] - 1L DO BEGIN
      tvec   = exvec_rot[j].VEC
      tnam   = exvec_rot[j].NAME
      tcol   = vec_cols[j]
      ;;  Project arrow onto contour
      ARROW,0.,0.,tvec[0],tvec[1],/DATA,THICK=l_thick[0],COLOR=tcol[0]
      ;;  Output arrow label
      XYOUTS,xyposi[0],xyposi[1],tnam[0],/DATA,COLOR=tcol[0],CHARTHICK=chthick[0]
      ;;  Shift label position in negative Y-Direction
      xyposi[1] -= 0.08*con_xyran[1]
    ENDFOR
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Output circles for CIRCS
  ;;--------------------------------------------------------------------------------------
  IF (circs_on[0]) THEN BEGIN
    FOR j=0L, n_circs[0] - 1L DO BEGIN
      OPLOT,vc_x[*,j],vc_y[*,j],LINESTYLE=2,THICK=l_thick[0]
    ENDFOR
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Output crosshairs onto contour
  ;;--------------------------------------------------------------------------------------
  OPLOT,hori_crsshair[*,0],hori_crsshair[*,1],COLOR=250,THICK=l_thick[0]
  OPLOT,vert_crsshair[*,0],vert_crsshair[*,1],COLOR= 50,THICK=l_thick[0]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot Cuts
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Set up plot area for cuts
PLOT,[0.0,1.0],[0.0,1.0],_EXTRA=base_lim_ct,CHARTHICK=chthick[0],XTHICK=p_thick[0],YTHICK=p_thick[0]
  ;;  Output cuts point-by-point
  OPLOT,vpara_cut,vdf_cut_para,COLOR=250,PSYM=4  ;;  diamonds
  OPLOT,vperp_cut,vdf_cut_perp,COLOR= 50,PSYM=5  ;;  triangles
  ;;  Output cuts as solid lines
  OPLOT,vpara_cut,vdf_cut_para,COLOR=250,LINESTYLE=0,THICK=l_thick[0]
  OPLOT,vperp_cut,vdf_cut_perp,COLOR= 50,LINESTYLE=0,THICK=l_thick[0]
  ;;  Output cut labels
  xyposi     = [4d-1*con_xyran[0],6d0*df_ran[0]]
  XYOUTS,xyposi[0],xyposi[1],'Para. Cut',/DATA,COLOR=250,CHARTHICK=chthick[0]
  xyposi[1] *= 0.7
  XYOUTS,xyposi[0],xyposi[1],'Perp. Cut',/DATA,COLOR= 50,CHARTHICK=chthick[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Plot 1-Count Level if desired
  ;;--------------------------------------------------------------------------------------
  IF (onec_on[0]) THEN BEGIN
    OPLOT,vpara_cut,onec_cut_para,COLOR=150,LINESTYLE=4,THICK=l_thick[0]
    ;;  Shift in negative Y-Direction
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],'One-Count',/DATA,COLOR=150,CHARTHICK=chthick[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Plot Poisson statistics if desired
  ;;--------------------------------------------------------------------------------------
  IF (pstt_on[0]) THEN BEGIN
    OPLOT,vpara_cut,pstt_cut_para,COLOR=100,LINESTYLE=4,THICK=l_thick[0]
    ;;  Shift in negative Y-Direction
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],'Poisson',/DATA,COLOR=100,CHARTHICK=chthick[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Plot bi-Maxwellian if desired
  ;;--------------------------------------------------------------------------------------
  IF (bimax_on[0]) THEN BEGIN
    OPLOT,vpara_cut,bimax_cut_para,COLOR=200,LINESTYLE=3,THICK=l_thick[0]
    OPLOT,vperp_cut,bimax_cut_perp,COLOR= 75,LINESTYLE=3,THICK=l_thick[0]
    ;;  Shift in negative Y-Direction
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],'Bi-Max. Para.',/DATA,COLOR=200,CHARTHICK=chthick[0]
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],'Bi-Max. Perp.',/DATA,COLOR= 75,CHARTHICK=chthick[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Plot bi-kappa if desired
  ;;--------------------------------------------------------------------------------------
  IF (bikap_on[0]) THEN BEGIN
    OPLOT,vpara_cut,bikap_cut_para,COLOR=225,LINESTYLE=3,THICK=l_thick[0]
    OPLOT,vperp_cut,bikap_cut_perp,COLOR= 30,LINESTYLE=3,THICK=l_thick[0]
    ;;  Shift in positive X-Direction
    xyposi[0] += ABS(4d-1*con_xyran[0])
    XYOUTS,xyposi[0],xyposi[1],'Bi-kappa Para.',/DATA,COLOR=225,CHARTHICK=chthick[0]
    ;;  Shift in negative Y-Direction
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],'Bi-kappa Perp.',/DATA,COLOR= 30,CHARTHICK=chthick[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Output vertical lines for Max/Min values of CIRCS
  ;;--------------------------------------------------------------------------------------
  IF (circs_on[0]) THEN BEGIN
    FOR j=0L, n_circs[0] - 1L DO BEGIN
      OPLOT,[vc_lx[j],vc_lx[j]],df_ran,LINESTYLE=2,THICK=l_thick[0]
      OPLOT,[vc_xx[j],vc_xx[j]],df_ran,LINESTYLE=2,THICK=l_thick[0]
    ENDFOR
  ENDIF
;;----------------------------------------------------------------------------------------
;;  Output VFRAME setting
;;----------------------------------------------------------------------------------------
chsz           = 0.80
yposi          = 0.20
xposi          = 0.74
XYOUTS,xposi[0],yposi[0],vframe_out[0],/NORMAL,ORIENTATION=90,CHARSIZE=chsz[0],COLOR=30,CHARTHICK=chthick[0]
;;----------------------------------------------------------------------------------------
;;  Output strahl direction if desired
;;----------------------------------------------------------------------------------------
IF (strahl_out[0] NE '') THEN BEGIN
  xposi         -= 0.02
  XYOUTS,xposi[0],yposi[0],strahl_out[0],/NORMAL,ORIENTATION=90,CHARSIZE=chsz[0],COLOR=30,CHARTHICK=chthick[0]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Output EX_INFO if present
;;----------------------------------------------------------------------------------------
IF (tran_on[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Output SC Potential [eV]
  ;;--------------------------------------------------------------------------------------
  chsz           = 0.80
  yposi          = 0.20
  xposi          = 0.26
  XYOUTS,xposi[0],yposi[0],sc_pot_str[0],/NORMAL,ORIENTATION=90,CHARSIZE=chsz[0],COLOR=30,CHARTHICK=chthick[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Output Bulk Flow Velocity [km/s]
  ;;--------------------------------------------------------------------------------------
  xposi         += 0.02
  XYOUTS,xposi[0],yposi[0],v__out_str[0],/NORMAL,ORIENTATION=90,CHARSIZE=chsz[0],COLOR=30,CHARTHICK=chthick[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Output Magnetic Field Vector [nT]
  ;;--------------------------------------------------------------------------------------
  xposi         += 0.02
  XYOUTS,xposi[0],yposi[0],b__out_str[0],/NORMAL,ORIENTATION=90,CHARSIZE=chsz[0],COLOR=30,CHARTHICK=chthick[0]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Output version # and date produced
;;----------------------------------------------------------------------------------------
XYOUTS,0.785,0.06,vers[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=chthick[0]
;XYOUTS,0.795,0.06,vers[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.
;;----------------------------------------------------------------------------------------
;;  Define DAT_OUT output
;;----------------------------------------------------------------------------------------
;;  Define structures for contour of VDF
tags           = ['VXPTS','VYPTS','VXGRID','VYGRID','VDF_2D','HORZ_CRSHRS','VERT_CRSHRS','BASE_LIM','CONT_LIM']
con_struc      = CREATE_STRUCT(tags,vxpts*1d-3,vypts*1d-3,vx2d*1d-3,vy2d*1d-3,df2ds,   $
                               hori_crsshair,vert_crsshair,base_lim_cn,con_lim)
;;  Define structures for cuts of VDF
tags           = ['VPARA','CUT_PAR','COLOR','PSYM','LINESTYLE']
vdf_para       = CREATE_STRUCT(tags,vpara_cut,vdf_cut_para,250,4,0)
tags           = ['VPERP','CUT_PER','COLOR','PSYM','LINESTYLE']
vdf_perp       = CREATE_STRUCT(tags,vperp_cut,vdf_cut_perp, 50,5,0)
tags           = ['PARA_CUT_STR','PERP_CUT_STR','CUT_LIM']
cut_struc      = CREATE_STRUCT(tags,vdf_para,vdf_perp,base_lim_ct)
;;  Define structures for XYOUTS info
chsz           = 0.80
yposi          = 0.20
xposi          = 0.26
tags_xy        = ['XYPOSI','XYLAB','COLOR','ORIENTATION','CHARSIZE','NORMAL','DATA']
scpot_xy       = CREATE_STRUCT(tags_xy,[xposi[0],yposi[0]],sc_pot_str[0],30L,90,chsz[0],1b,0b)
xposi         += 0.02
vsw_xy         = CREATE_STRUCT(tags_xy,[xposi[0],yposi[0]],v__out_str[0],30L,90,chsz[0],1b,0b)
xposi         += 0.02
magf_xy        = CREATE_STRUCT(tags_xy,[xposi[0],yposi[0]],b__out_str[0],30L,90,chsz[0],1b,0b)
vers_xy        = CREATE_STRUCT(tags_xy,[0.795,0.06],vers[0],-1,90,0.65,1b,0b)
tags           = ['SCPOT_XY','VSW_XY','MAGF_XY','VERS_XY']
xyouts_str     = CREATE_STRUCT(tags,scpot_xy,vsw_xy,magf_xy,vers_xy)
;;  Define structure for one-count of VDF
tags           = ['VDF_2D','CUT_PAR','CUT_PER']
IF (onec_on[0]) THEN BEGIN
  onec_struc     = CREATE_STRUCT(tags,df1c,onec_cut_para,onec_cut_perp)
ENDIF ELSE BEGIN
  szdm           = SIZE(df2ds,/DIMENSIONS)
  df1c           = REPLICATE(d,szdm[0],szdm[1])
  onec_cut_para  = REFORM(df1c[*,0])
  onec_cut_perp  = onec_cut_para
  onec_struc     = CREATE_STRUCT(tags,df1c,onec_cut_para,onec_cut_perp)
ENDELSE
;;  Define structure for Poisson statistics of VDF
IF (pstt_on[0]) THEN BEGIN
  pstt_struc     = CREATE_STRUCT(tags,df1p,pstt_cut_para,pstt_cut_perp)
ENDIF ELSE BEGIN
  szdm           = SIZE(df2ds,/DIMENSIONS)
  df1p           = REPLICATE(d,szdm[0],szdm[1])
  pstt_cut_para  = REFORM(df1p[*,0])
  pstt_cut_perp  = pstt_cut_para
  pstt_struc     = CREATE_STRUCT(tags,df1p,pstt_cut_para,pstt_cut_perp)
ENDELSE
;;  Define DAT_OUT
tags           = ['CONT_DATA','CUTS_DATA','XYOUTS','ONE_CUT','POISSON']
dat_out        = CREATE_STRUCT(tags,con_struc,cut_struc,xyouts_str,onec_struc,pstt_struc)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END







