;+
;*****************************************************************************************
;
;  FUNCTION :   get_1d_cuts_of_vdf_from_struc.pro
;  PURPOSE  :   This routine returns the 1D cuts of a 3D VDF when given an input
;                 structure of the proper format from 3DP, THEMIS ESA, or MMS DES.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               mag__vec.pro
;               is_a_3_vector.pro
;               is_a_number.pro
;               get_rotated_and_triangulated_vdf.pro
;               find_1d_cuts_2d_dist.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STRUC    :  Scalar [structure] with the format
;                             VDF     :  [T,N]-Element [numeric] array of phase space
;                                          densities, where T is the number of different
;                                          VDFs and N is the number of solid-angle and
;                                          energy bins [# cm^(-3) km^(-3) s^(+3)]
;                             VELXYZ  :  [T,N,3]-Element [numeric] array 3-vector
;                                          velocities [km/s]
;
;  EXAMPLES:    
;               [calling sequence]
;               cuts_str = get_1d_cuts_of_vdf_from_struc(struc [,VFRAME=vframe] [,VEC1=vec1] $
;                                                              [,VEC2=vec2] [,VLIM=vlim]     $
;                                                              [,PLANE=plane] [,NGRID=ngrid])
;
;  KEYWORDS:    
;               ***  INPUTS  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all of the following have default settings]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               VFRAME   :  [T,3]-Element [float/double] array defining the 3-vector
;                             velocity of the K'-frame relative to the K-frame [km/s]
;                             to use to transform the velocity distribution into the
;                             bulk flow reference frame
;                             [ Default = [0,0,0] ]
;               VEC1     :  [T,3]-Element vector to be used for "parallel" direction in
;                             a 3D rotation of the input data
;                             [e.g. see rotate_3dp_structure.pro]
;                             [ Default = [1.,0.,0.] ]
;               VEC2     :  [T,3]--Element vector to be used with VEC1 to define a 3D
;                             rotation matrix.  The new basis will have the following:
;                               X'  :  parallel to VEC1
;                               Z'  :  parallel to (VEC1 x VEC2)
;                               Y'  :  completes the right-handed set
;                             [ Default = [0.,1.,0.] ]
;               VLIM     :  Scalar [numeric] defining the velocity [km/s] limit for x-y
;                             velocity axes over which to plot data
;                             [Default = [-1,1]*MAX(ABS(VELXYZ))]
;               NGRID    :  Scalar [numeric] defining the number of grid points in each
;                             direction to use when triangulating the data.  The input
;                             will be limited to values between 30 and 300.
;                             [Default = 101]
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
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               0)  For MMS structures, there may also be a UNIX structure tag but it
;                     is ignored here
;
;  REFERENCES:  
;               1)  Lavraud, B., and D.E. Larson "Correcting moments of in situ particle
;                      distribution functions for spacecraft electrostatic charging,"
;                      J. Geophys. Res. 121, pp. 8462--8474, doi:10.1002/2016JA022591,
;                      2016.
;               2)  Meyer-Vernet, N., and C. Perche "Tool kit for antennae and thermal
;                      noise near the plasma frequency," J. Geophys. Res. 94(A3),
;                      pp. 2405--2415, doi:10.1029/JA094iA03p02405, 1989.
;               3)  Meyer-Vernet, N., K. Issautier, and M. Moncuquet "Quasi-thermal noise
;                      spectroscopy: The art and the practice," J. Geophys. Res. 122(8),
;                      pp. 7925--7945, doi:10.1002/2017JA024449, 2017.
;               4)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               5)  Lin et al., "A Three-Dimensional Plasma and Energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev.
;                      71, pp. 125--153, 1995.
;               6)  Bougeret, J.-L., M.L. Kaiser, P.J. Kellogg, R. Manning, K. Goetz,
;                      S.J. Monson, N. Monge, L. Friel, C.A. Meetre, C. Perche,
;                      L. Sitruk, and S. Hoang "WAVES:  The Radio and Plasma Wave
;                      Investigation on the Wind Spacecraft," Space Sci. Rev. 71,
;                      pp. 231--263, doi:10.1007/BF00751331, 1995.
;               7)  M. Wüest, D.S. Evans, and R. von Steiger "Calibration of Particle
;                      Instruments in Space Physics," ESA Publications Division,
;                      Keplerlaan 1, 2200 AG Noordwijk, The Netherlands, 2007.
;               8)  M. Wüest, et al., "Review of Instruments," ISSI Sci. Rep. Ser.
;                      Vol. 7, pp. 11--116, 2007.
;               9)  Wilson III, L.B., et al., "The Statistical Properties of Solar Wind
;                      Temperature Parameters Near 1 au," Astrophys. J. Suppl. 236(2),
;                      pp. 41, doi:10.3847/1538-4365/aab71c, 2018.
;              10)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      Astrophys. J. Suppl. 243(8), doi:10.3847/1538-4365/ab22bd, 2019a.
;              11)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: II. Statistics,"
;                      Astrophys. J. Suppl. 245(24), doi:10.3847/1538-4365/ab5445, 2019b.
;              12)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: III. Analysis,"
;                      Astrophys. J., Accepted Mar. 4, 2020.
;              13)  Wilson III, L.B., et al., "A Quarter Century of Wind Spacecraft
;                      Discoveries," Rev. Geophys. 59(2), pp. e2020RG000714,
;                      doi:10.1029/2020RG000714, 2021.
;              14)  Wilson III, L.B., et al., "The need for accurate measurements of
;                      thermal velocity distribution functions in the solar wind,"
;                      Front. Astron. Space Sci. 9, pp. 1063841,
;                      doi:10.3389/fspas.2022.1063841, 2022.
;              15)  Wilson III, L.B., et al., "Spacecraft floating potential measurements
;                      for the Wind spacecraft," Astrophys. J. Suppl. 269(52), pp. 10,
;                      doi:10.3847/1538-4365/ad0633, 2023.
;              16)  Wilson III, L.B., et al., "Erratum: 'The Statistical Properties of
;                      Solar Wind Temperature Parameters Near 1 au'," Astrophys. J. Suppl.
;                      269(62), pp. 12, doi:10.3847/1538-4365/ad07de, 2023.
;
;   CREATED:  10/28/2024
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/28/2024   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_1d_cuts_of_vdf_from_struc,struc,VFRAME=vframe,VEC1=vec1,VEC2=vec2,VLIM=vlim,  $
                                             PLANE=plane,NGRID=ngrid

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
no_stru_msg    = 'User must supply a scalar structure with VDF and VELXYZ tags...'
no_inpt_msg    = 'User must supply a VDF and a corresponding array of 3-vector velocities...'
badvfor_msg    = 'Incorrect input format:  VDF and VELXYZ must have the same size first dimensions...'
nofinite_mssg  = 'Not enough finite and unique data was supplied...'
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
all_planes     = ['xy','xz','yz']
;;  Default frame and coordinates
def_vframe     = [0d0,0d0,0d0]          ;;  Assumes km/s units on input
def_vec1       = [1d0,0d0,0d0]
def_vec2       = [0d0,1d0,0d0]
def_ngrid      = 101L
def_plane      = 'xy'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check for STRUC
test           = (N_PARAMS() LT 1) OR (SIZE(struc,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,'0:  '+no_stru_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check STRUC tags
stags          = STRLOWCASE(TAG_NAMES(struc))
test           = (TOTAL(stags EQ 'vdf') NE 1) OR (TOTAL(stags EQ 'velxyz') NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,'1:  '+no_stru_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define variables from STRUC tags
vdf            = struc.VDF
vxyz           = struc.VELXYZ
;;  Check STRUC tag value formats
szdvdf         = SIZE(vdf,/DIMENSIONS)
szdvel         = SIZE(vxyz,/DIMENSIONS)
;;  First check if MMS arrays
IF (N_ELEMENTS(szdvdf) EQ 2) THEN BEGIN
  ;;  VDF tag had at least 2 dimensions
  test           = (szdvdf[1] NE szdvel[1]) OR (szdvdf[1] LT 10)
  mms_on         = 1b
  vmag           = mag__vec(REFORM(vxyz,szdvel[0]*szdvel[1],szdvel[2]),/NAN)
ENDIF ELSE BEGIN
  ;;  VDF tag had only 1 dimension
  test           = (szdvdf[0] NE szdvel[0]) OR (szdvdf[0] LT 10)
  mms_on         = 0b
  vmag           = mag__vec(vxyz,/NAN)
ENDELSE
IF (test[0]) THEN BEGIN
  MESSAGE,badvfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define default VLIM and DFRA
def_vlim       = MAX(ABS(vmag),/NAN)*1.05
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check keywords [Inputs]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check VFRAME
IF (is_a_3_vector(vframe,V_OUT=vtrans,/NOMSSG) EQ 0) THEN vframe = def_vframe ELSE vframe = REFORM(vtrans)
IF (mms_on[0]) THEN BEGIN
  ones           = REPLICATE(1d0,szdvdf[0])
  szvd           = SIZE(vframe,/DIMENSIONS)
  IF (N_ELEMENTS(szvd) EQ 1) THEN BEGIN
    ;;  Resize so VFRAME matches dimensions of input
    vframe         = ones # vframe
  ENDIF ELSE BEGIN
    ;;  Check if dimensions match
    IF (szvd[0] NE szdvdf[0]) THEN vframe = ones # def_vframe
  ENDELSE
  ;;  Define number of expected finite vals
  nexfv          = 3L*szdvdf[0]
ENDIF ELSE BEGIN
  ;;  Define number of expected finite vals
  nexfv          = 3L
ENDELSE
;;  Define new frame |V| [km/s]
vf_new         = vxyz
IF (TOTAL(FINITE(vframe)) EQ nexfv[0]) THEN BEGIN
  IF (mms_on[0]) THEN BEGIN
    ;;  Shift for each VDF
    FOR j=0L, szdvdf[0] - 1L DO BEGIN
      FOR k=0L, 2L DO vf_new[j,*,k] -= vframe[j,k]
    ENDFOR
  ENDIF ELSE BEGIN
    FOR k=0L, 2L DO vf_new[*,k] -= vframe[k]
  ENDELSE
ENDIF ELSE BEGIN
  ;;  VFRAME is not finite --> zero out
  IF (mms_on[0]) THEN vframe = REPLICATE(0d0,szdvdf[0],3L) ELSE vframe = REPLICATE(0d0,3L)
ENDELSE
vmag_new       = mag__vec(vf_new,/NAN)
;;----------------------------------------------------------------------------------------
;;  Check VEC1 and VEC2
;;----------------------------------------------------------------------------------------
IF (is_a_3_vector(vec1,V_OUT=v1out,/NOMSSG) EQ 0) THEN vec1 = def_vec1 ELSE vec1 = REFORM(v1out)
IF (is_a_3_vector(vec2,V_OUT=v2out,/NOMSSG) EQ 0) THEN vec2 = def_vec2 ELSE vec2 = REFORM(v2out)
IF (TOTAL(FINITE(vec1)) NE 3) THEN vec1 = def_vec1
IF (TOTAL(FINITE(vec2)) NE 3) THEN vec2 = def_vec2
IF (mms_on[0]) THEN BEGIN
  ;;  Check if user supplied T input 3-vectors or just one
  ones           = REPLICATE(1d0,szdvdf[0])
  szv1d          = SIZE(vec1,/DIMENSIONS)
  szv2d          = SIZE(vec2,/DIMENSIONS)
  IF (N_ELEMENTS(szv1d) EQ 1) THEN BEGIN
    ;;  Only 1D --> make 2D
    vec1           = ones # vec1
  ENDIF ELSE BEGIN
    ;;  At least 2D --> make sure it's the correct # of dimensions and elements
    IF (szv1d[0] NE szdvdf[0]) THEN vec1 = ones # def_vec1
  ENDELSE
  IF (N_ELEMENTS(szv2d) EQ 1) THEN BEGIN
    ;;  Only 1D --> make 2D
    vec2           = ones # vec2
  ENDIF ELSE BEGIN
    ;;  At least 2D --> make sure it's the correct # of dimensions and elements
    IF (szv2d[0] NE szdvdf[0]) THEN vec2 = ones # def_vec2
  ENDELSE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check VLIM
;;----------------------------------------------------------------------------------------
IF (is_a_number(vlim,/NOMSSG) EQ 0) THEN vlim = def_vlim[0] ELSE vlim = ABS(vlim[0])
IF (vlim[0] LE MIN(ABS(vmag_new),/NAN)) THEN vlim = def_vlim[0]
;;----------------------------------------------------------------------------------------
;;  Check PLANE
;;----------------------------------------------------------------------------------------
IF (SIZE(plane,/TYPE) NE 7) THEN plane = def_plane[0] ELSE plane = STRLOWCASE(plane[0])
IF (TOTAL(plane[0] EQ all_planes) LT 1) THEN plane = def_plane[0]
;;----------------------------------------------------------------------------------------
;;  Check NGRID
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(ngrid) EQ 0) OR (is_a_number(ngrid,/NOMSSG) EQ 0) THEN ngrid = def_ngrid[0] $
                                                                 ELSE ngrid = (LONG(ngrid[0]) > 30L) < 300L
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Get re-gridded VDFs
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
IF (mms_on[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Multiple VDFs were passed on input --> find 1D cuts for each
  ;;--------------------------------------------------------------------------------------
  fpara_1d       = REPLICATE(d,szdvdf[0],ngrid[0])
  fperp_1d       = fpara_1d
  vpara_1d       = fpara_1d
  vperp_1d       = fpara_1d
  FOR j=0L, szdvdf[0] - 1L DO BEGIN
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;  Define variables for each VDF
    vfr0           = REFORM(vframe[j,*])
    df1d           = REFORM(vdf[j,*])
    vs1d           = REFORM(vxyz[j,*,*])
    vv1            = REFORM(vec1[j,*])
    vv2            = REFORM(vec2[j,*])
    ;;  Rotate and triangulate in 3D the input VDF
    r_vels         = get_rotated_and_triangulated_vdf(vs1d,df1d,VLIM=vlim[0],C_LOG=0b,     $
                                                      NGRID=ngrid[0],/SLICE2D,VFRAME=vfr0, $
                                                      VEC1=vv1,VEC2=vv2,P_LOG=0b)
    ;;  Check output
    IF (SIZE(r_vels,/TYPE) NE 8) THEN CONTINUE
    vx2d           = r_vels.VX2D
    vy2d           = r_vels.VY2D
    CASE plane[0] OF
      'xy'  : df2d = r_vels.PLANE_XY.DF2D_XY
      'xz'  : df2d = r_vels.PLANE_XZ.DF2D_XZ
      'yz'  : df2d = r_vels.PLANE_YZ.DF2D_YZ
      ELSE  : df2d = r_vels.PLANE_XY.DF2D_XY
    ENDCASE
    ;;------------------------------------------------------------------------------------
    ;;  Find 1D cuts
    ;;------------------------------------------------------------------------------------
    cuts_struc     = find_1d_cuts_2d_dist(df2d,vx2d,vy2d,X_0=0d0,Y_0=0d0)
    ;;  Check output
    IF (SIZE(cuts_struc,/TYPE) NE 8) THEN CONTINUE
    ;;  Fill output arrays
    fpara_1d[j,*]  = cuts_struc.X_1D_FXY
    fperp_1d[j,*]  = cuts_struc.Y_1D_FXY
    vpara_1d[j,*]  = cuts_struc.X_CUT_COORD
    vperp_1d[j,*]  = cuts_struc.Y_CUT_COORD
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
  ENDFOR
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Only 1 VDF was passed on input --> find 1D cuts for it
  ;;--------------------------------------------------------------------------------------
  fpara_1d       = REPLICATE(d,ngrid[0])
  fperp_1d       = fpara_1d
  vpara_1d       = fpara_1d
  vperp_1d       = fpara_1d
  ;;  Rotate and triangulate in 3D the input VDF
  r_vels         = get_rotated_and_triangulated_vdf(vs1d,df1d,VLIM=vlim[0],C_LOG=0b,     $
                                                    NGRID=ngrid[0],/SLICE2D,VFRAME=vfr0, $
                                                    VEC1=vec1,VEC2=vec2,P_LOG=0b)
  ;;  Check output
  IF (SIZE(r_vels,/TYPE) EQ 8) THEN BEGIN
    ;;  Structure format --> Find 1D cuts
    vx2d           = r_vels.VX2D
    vy2d           = r_vels.VY2D
    CASE plane[0] OF
      'xy'  : df2d = r_vels.PLANE_XY.DF2D_XY
      'xz'  : df2d = r_vels.PLANE_XZ.DF2D_XZ
      'yz'  : df2d = r_vels.PLANE_YZ.DF2D_YZ
      ELSE  : df2d = r_vels.PLANE_XY.DF2D_XY
    ENDCASE
    ;;------------------------------------------------------------------------------------
    ;;  Find 1D cuts
    ;;------------------------------------------------------------------------------------
    cuts_struc     = find_1d_cuts_2d_dist(df2d,vx2d,vy2d,X_0=0d0,Y_0=0d0)
    ;;  Check output
    IF (SIZE(cuts_struc,/TYPE) EQ 8) THEN BEGIN
      ;;  Fill output arrays
      fpara_1d       = cuts_struc.X_1D_FXY
      fperp_1d       = cuts_struc.Y_1D_FXY
      vpara_1d       = cuts_struc.X_CUT_COORD
      vperp_1d       = cuts_struc.Y_CUT_COORD
    ENDIF
  ENDIF
ENDELSE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
tags           = ['VPARA','VPERP','FPARA','FPERP']
out_str        = CREATE_STRUCT(tags,vpara_1d,vperp_1d,fpara_1d,fperp_1d)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN,out_str
END






































