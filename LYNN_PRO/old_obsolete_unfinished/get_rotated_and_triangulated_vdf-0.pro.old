;+
;*****************************************************************************************
;
;  FUNCTION :   get_rotated_and_triangulated_vdf.pro
;  PURPOSE  :   This is a wrapping routine for the rotation and triangulation routine
;                 rotate_and_triangulate_dfs.pro
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_3_vector.pro
;               is_a_number.pro
;               mag__vec.pro
;               rot_matrix_array_dfs.pro
;               rel_lorentz_trans_3vec.pro
;               rotate_and_triangulate_dfs.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VELS       :  [K,3]-Element [numeric] array of particle velocities [km/s]
;               DATA       :  [K]-Element [numeric] array of phase (velocity) space
;                               densities [e.g., s^(3) cm^(-3) km^(-3)]
;
;  EXAMPLES:    
;               [calling sequence]
;               rstruc = get_rotated_and_triangulated_vdf(vels, data [,VLIM=vlim]       $
;                                            [,/P_LOG] [,/C_LOG] [,NGRID=ngrid]         $
;                                            [,/SLICE2D][,VFRAME=vframe] [,VEC1=vec1]   $
;                                            [,VEC2=vec2]                               )
;
;  KEYWORDS:    
;               VLIM       :  Scalar [numeric] defining the speed limit for the velocity
;                               grids over which to triangulate the data [km/s]
;                               [Default = max vel. magnitude]
;               C_LOG      :  If set, routine assumes input DATA is in logarithmic
;                               instead of linear space, which really only changes
;                               some testing/error handling for TRIANGULATE.PRO and
;                               TRIGRID.PRO
;                               [Default = FALSE]
;               P_LOG      :  If set, routine will compute the VDF in linear space but
;                               plot the base-10 log of the VDF.  If set, this keyword
;                               supercedes the C_LOG keyword and shuts it off to avoid
;                               infinite plot range errors, among other issues
;                               [Default = FALSE]
;               NGRID      :  Scalar [numeric] defining the number of grid points in each
;                               direction to use when triangulating the data.  The input
;                               will be limited to values between 30 and 300.
;                               [Default = 101]
;               SLICE2D    :  If set, routine will return a 2D slice instead of a 3D
;                               projection
;                               [Default = FALSE]
;               VFRAME     :  [3]-Element [float/double] array defining the 3-vector
;                               velocity of the K'-frame relative to the K-frame [km/s]
;                               to use to transform the velocity distribution into the
;                               bulk flow reference frame
;                               [ Default = [10,0,0] ]
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
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ROTMXY     :  Set to a named variable to return the [K,3,3]-element
;                               [numeric] array of rotation matrices for the new
;                               XY- and XZ-Planes
;               ROTMZY     :  Set to a named variable to return the [K,3,3]-element
;                               [numeric] array of rotation matrices for the new
;                               ZY--Plane
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               1)  See IDL's documentation for:
;                     QHULL.PRO:        https://harrisgeospatial.com/docs/qhull.html
;                     QGRID3.PRO:       https://harrisgeospatial.com/docs/QGRID3.html
;                     TRIANGULATE.PRO:  https://harrisgeospatial.com/docs/TRIANGULATE.html
;                     TRIGRID.PRO:      https://harrisgeospatial.com/docs/TRIGRID.html
;
;   CREATED:  05/09/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/09/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_rotated_and_triangulated_vdf,vels,data,VLIM=vlim,C_LOG=c_log,NGRID=ngrid,$
                                          SLICE2D=slice2d,VFRAME=vframe,P_LOG=p_log,  $
                                          VEC1=vec1,VEC2=vec2,ROTMXY=rotm,ROTMZY=rotz

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
def_vframe     = [0d0,0d0,0d0]          ;;  Assumes km/s units on input
def_vec1       = [1d0,0d0,0d0]
def_vec2       = [0d0,1d0,0d0]
;;----------------------------------------------------------------------------------------
;;  Check input structure format
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN RETURN,0b
;;----------------------------------------------------------------------------------------
;;  Check inputs
;;----------------------------------------------------------------------------------------
test           = (is_a_3_vector(vels,V_OUT=swfv,/NOMSSG) EQ 0) OR (is_a_number(data,/NOMSSG) EQ 0)
IF (test[0]) THEN RETURN,0b
;;  Define paramters
szv            = SIZE(swfv,/DIMENSIONS)
kk             = szv[0]                      ;;  # of vectors
IF (N_ELEMENTS(data) NE kk[0]) THEN RETURN,0b
df1d           = REFORM(data,kk[0])          ;;  [K]-Element array
vmag           = mag__vec(swfv,/NAN)
;;  Define default VLIM
def_vlim       = MAX(ABS(vmag),/NAN)*1.05
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check P_LOG
plog_on        = (N_ELEMENTS(p_log) EQ 1) AND KEYWORD_SET(p_log)
;;  Check C_LOG
test           = (N_ELEMENTS(c_log) GE 1) AND KEYWORD_SET(c_log) AND ~plog_on[0]
IF (test[0]) THEN BEGIN
  ;;  User wants to plot in log-space, not linear space
  df1do   = ALOG10(df1d)
  clog_on = 1b
ENDIF ELSE BEGIN
  df1do   = df1d
  clog_on = 0b
ENDELSE
;;  Check NGRID
test           = (N_ELEMENTS(ngrid) EQ 0) OR (is_a_number(ngrid,/NOMSSG) EQ 0)
IF (test[0]) THEN nm = 101L ELSE nm = (LONG(ngrid[0]) > 30L) < 300L
;;  Check SLICE2D
test           = (N_ELEMENTS(slice2d) EQ 1) AND KEYWORD_SET(slice2d)
IF (test[0]) THEN slice_on = 1b ELSE slice_on = 0b
;;  Check VFRAME
test           = (is_a_3_vector(vframe,V_OUT=vtrans,/NOMSSG) EQ 0)
IF (test[0]) THEN vframe = def_vframe ELSE vframe = vtrans
;;  Define new frame |V| [km/s]
vf_new         = swfv
test           = (TOTAL(FINITE(vframe)) EQ 3)
IF (test[0]) THEN FOR k=0L, 2L DO vf_new[*,k] -= vframe[k]
vmag_new       = mag__vec(vf_new,/NAN)
;;  Check VEC1 and VEC2
test           = (is_a_3_vector(vec1,V_OUT=v1out,/NOMSSG) EQ 0)
IF (test[0]) THEN vv1 = def_vec1 ELSE vv1 = REFORM(v1out[0,*])
test           = (is_a_3_vector(vec2,V_OUT=v2out,/NOMSSG) EQ 0)
IF (test[0]) THEN vv2 = def_vec2 ELSE vv2 = REFORM(v2out[0,*])
;;  Check VLIM
test           = (is_a_number(vlim,/NOMSSG) EQ 0)
IF (test[0]) THEN vlim = def_vlim[0] ELSE vlim = ABS(vlim[0])
test           = (vlim[0] LE MIN(ABS(vmag_new),/NAN))
IF (test[0]) THEN vlim = def_vlim[0]
;;----------------------------------------------------------------------------------------
;;  Define rotation matrices
;;----------------------------------------------------------------------------------------
;;  Expand to make [K,3]-element arrays
v1             = REPLICATE(1d0,kk[0]) # vv1            ;; [K,3]-Element array
v2             = REPLICATE(1d0,kk[0]) # vv2            ;; [K,3]-Element array
;;  Define rotation matrices equivalent to cal_rot.pro
;;    CAL_ROT = TRUE  --> Primed unit basis vectors are given by:
;;           X'  :  V1
;;           Z'  :  (V1 x V2)       = (X x V2)
;;           Y'  :  (V1 x V2) x V1  = (Z x X)
rotm           = rot_matrix_array_dfs(v1,v2,/CAL_ROT)  ;;  [K,3,3]-element array
;;  Define rotation matrices equivalent to rot_mat.pro
;;    CAL_ROT = FALSE  --> Primed unit basis vectors are given by:
;;           Z'  :  V1
;;           Y'  :  (V1 x V2)       = (Z x V2)
;;           X'  :  (V1 x V2) x V1  = (Y x Z)
rotz           = rot_matrix_array_dfs(v1,v2)           ;;  [K,3,3]-element array
;;----------------------------------------------------------------------------------------
;;  Transform VDF into VFRAME
;;----------------------------------------------------------------------------------------
vtrxyz         = rel_lorentz_trans_3vec(swfv,vframe)
;;----------------------------------------------------------------------------------------
;;  Rotate velocities and VDF into new coordinate basis and triangulate
;;----------------------------------------------------------------------------------------
v_xyz          = FLOAT(vtrxyz)
r_vels         = rotate_and_triangulate_dfs(v_xyz,df1do,rotm,rotz,VLIM=vlim[0],  $
                                            C_LOG=clog_on[0],NGRID=nm[0],        $
                                            SLICE2D=slice_on[0]                  )
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,r_vels
END