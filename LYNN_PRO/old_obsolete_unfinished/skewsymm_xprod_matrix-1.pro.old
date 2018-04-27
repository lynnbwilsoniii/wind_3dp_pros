;+
;*****************************************************************************************
;
;  FUNCTION :   skewsymm_xprod_matrix.pro
;  PURPOSE  :   This routine constructs the skew-symmetric cross-product matrix of V,
;                 where V = A x B and AV,BV are 3-vectors.  This is useful for finding
;                 the rotation matrices between two coordinate bases if AV and BV
;                 are the same 3-vector, but defined within different bases.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               format_2d_vec.pro
;               unit_vec.pro
;               my_dot_prod.pro
;               my_crossp_2.pro
;               mag__vec.pro
;               vm_matrix.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               AV      :  [3]- or [N,3]-element [numeric] array of 3-vectors to rotate
;                            onto the 3-vectors BV
;               BV      :  [3]- or [N,3]-element [numeric] array of 3-vectors about
;                            which AV will be rotated
;
;  EXAMPLES:    
;               rotm = skewsymm_xprod_matrix(av,bv)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Now calls vm_matrix.pro  -->  now quasi-vectorized
;                                                                   [11/06/2015   v1.0.1]
;
;   NOTES:      
;               1)  Interestingly, the rotation matrix from one coordinate basis to
;                     another is not necessarily the same as the result returned by this
;                     routine.  Yet application of either matrix on AV should still
;                     result in the vector BV.
;
;  REFERENCES:  
;               1)  Useful explanation found at:
;                    http://math.stackexchange.com/questions/180418/calculate-rotation-matrix-to-align-vector-a-to-vector-b-in-3d
;               2)  Other useful links include:
;                    https://en.wikipedia.org/wiki/Rotation_matrix
;                    https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
;                    https://en.wikipedia.org/wiki/Skew-symmetric_matrix
;                    https://en.wikipedia.org/wiki/Axis–angle_representation
;
;   CREATED:  11/06/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/06/2015   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION skewsymm_xprod_matrix,av,bv

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, format_2d_vec, unit_vec, my_dot_prod, my_crossp_2, $
                 mag__vec, vm_matrix
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
ident          = IDENTITY(3,/DOUBLE)     ;;  3x3 identity or unit matrix
;;  Dummy error messages
no_inpt_msg    = 'User must supply two 3-vectors either as single or arrays of vectors'
badvfor_msg    = 'Incorrect input format:  AV and BV must be [N,3]-element [numeric] arrays of 3-vectors'
baddfor_msg    = 'Incorrect input format:  AV and BV must have the same dimensions if both are arrays of 3-vectors'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (is_a_number(av,/NOMSSG) EQ 0) OR  $
                 (is_a_number(bv,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check vector formats
av_2d          = format_2d_vec(av)    ;;  If a vector, routine will force to [N,3]-elements, even if N = 1
bv_2d          = format_2d_vec(bv)
test           = ((N_ELEMENTS(av_2d) LT 3) OR ((N_ELEMENTS(av_2d) MOD 3) NE 0)) OR $
                 ((N_ELEMENTS(bv_2d) LT 3) OR ((N_ELEMENTS(bv_2d) MOD 3) NE 0))
IF (test[0]) THEN BEGIN
  MESSAGE,badvfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Determine if either or both are [N,3]-element arrays
;;----------------------------------------------------------------------------------------
szdav          = SIZE(av_2d,/DIMENSIONS)
szdbv          = SIZE(bv_2d,/DIMENSIONS)
test           = (N_ELEMENTS(av_2d) EQ 3) AND (N_ELEMENTS(bv_2d) EQ 3)
IF (test[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Both are only single 3-vectors
  ;;--------------------------------------------------------------------------------------
  v1 = REFORM(av_2d,1,3)
  v2 = REFORM(bv_2d,1,3)
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  At least one of them is a [N,3]-element array
  ;;--------------------------------------------------------------------------------------
  test           = (N_ELEMENTS(av_2d) GT 3) AND (N_ELEMENTS(bv_2d) GT 3)
  IF (test[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Both are [N,3]-element arrays  -->  Make sure dimensions match
    ;;------------------------------------------------------------------------------------
    test           = (szdav[0] NE szdbv[0])
    IF (test[0]) THEN BEGIN
      MESSAGE,baddfor_msg,/INFORMATIONAL,/CONTINUE
      RETURN,0b
    ENDIF
    ;;  Elements are good --> Continue
    v1 = av_2d
    v2 = bv_2d
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Only one is an [N,3]-element array
    ;;------------------------------------------------------------------------------------
    test           = (N_ELEMENTS(av_2d) GT 3)
    IF (test[0]) THEN BEGIN
      ;;  BV = [N,3]-element array
      v1 = REPLICATE(1d0,szdbv[0]) # REFORM(av_2d)
      v2 = bv_2d
    ENDIF ELSE BEGIN
      ;;  AV = [N,3]-element array
      v1 = av_2d
      v2 = REPLICATE(1d0,szdav[0]) # REFORM(bv_2d)
    ENDELSE
  ENDELSE
ENDELSE
;;  Calculate unit vectors
u1             = unit_vec(v1)
u2             = unit_vec(v2)
szdu           = SIZE(u1,/DIMENSIONS)
nu             = szdu[0]
;;  Define [N]-Identity matrices
n_ident        = REPLICATE(0d0,nu,3,3)
FOR i=0L, nu - 1L DO n_ident[i,*,*] = ident
;;----------------------------------------------------------------------------------------
;;  Compute dot- and cross-products and magnitudes
;;----------------------------------------------------------------------------------------
u1_d_u2        = my_dot_prod(u1,u2,/NOM)     ;;  AV . BV
u1_x_u2        = my_crossp_2(u1,u2,/NOM)     ;;  AV x BV
uu             = unit_vec(u1_x_u2)
theta          = ACOS(u1_d_u2)               ;;  Angle between AV and BV, ø [0 --> π]
cc             = u1_d_u2                     ;;  Cos(ø)
ss             = mag__vec(u1_x_u2)           ;;  Sin(ø)
;ss             = SIN(theta)                  ;;  Sin(ø)
;;----------------------------------------------------------------------------------------
;;  Construct the skew-symmetric cross-product matrix
;;
;;    Let V = AV x BV, then the matrix is given by:
;;
;;
;;            |   0   -Vz  +Vy  |
;;            |                 |
;;      V  =  |  +Vz   0   -Vx  |
;;            |                 |
;;            |  -Vy  +Vx   0   |
;;
;;----------------------------------------------------------------------------------------
v_x            = REPLICATE(0d0,nu,3,3)
v_x[*,1,0]     = -1d0*u1_x_u2[*,2]
v_x[*,2,0]     =  1d0*u1_x_u2[*,1]
v_x[*,0,1]     =  1d0*u1_x_u2[*,2]
v_x[*,2,1]     = -1d0*u1_x_u2[*,0]
v_x[*,0,2]     = -1d0*u1_x_u2[*,1]
v_x[*,1,2]     =  1d0*u1_x_u2[*,0]
;;----------------------------------------------------------------------------------------
;;  Calculate the rotation matrices
;;----------------------------------------------------------------------------------------
fac0           = REPLICATE(0d0,nu,3,3)
FOR row=0L, 2L DO FOR col=0L, 2L DO fac0[*,col,row] = (1d0 - cc)/ss^2
rotm           = REPLICATE(0d0,nu,3,3)
v_x_2          = vm_matrix(v_x,v_x)    ;;  W = V . V or W[i,*,*] = (REFORM(v_x[i,*,*]) ## REFORM(v_x[i,*,*]))
rotm           = n_ident + v_x + fac0*v_x_2
;FOR i=0L, nu - 1L DO rotm[i,*,*] = ident + v_x[i,*,*] + fac0[i,0,0]*(REFORM(v_x[i,*,*]) ## REFORM(v_x[i,*,*]))
;;----------------------------------------------------------------------------------------
;;  Return to User
;;----------------------------------------------------------------------------------------

RETURN,rotm
END













