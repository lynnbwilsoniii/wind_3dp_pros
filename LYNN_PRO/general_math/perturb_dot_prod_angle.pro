;+
;*****************************************************************************************
;
;  FUNCTION :   perturb_dot_prod_angle.pro
;  PURPOSE  :   This routine finds the angle between two arrays of input vectors and
;                 the uncertainty by perturbing the input 3-vectors with user defined
;                 component uncertainties.  The output will be an [N,2]-element array
;                 where [N,0] = angles and [N,1] = uncertainties in the angles.
;
;                 The algorithm is very simple.  We just take the input arrays and
;                 perturb them by adding the uncertainties with a scale factor to get:
;                   V' = {V - ∂V, V, V + ∂V}
;                 where V' is a [N,3,3]-element array.  We compute the dot products by
;                 permuting the last dimension during the dot-product calculation to get:
;                   DP[*,j,k] = V'[*,*,j].W'[*,*,k]
;                 We then compute the corresponding angles, Ω, and find the maximum range
;                 of values for the last two dimensions such that our angle uncertainty
;                 becomes:
;                   dΩ[i] = (MAX(Ω[i,*,*]) - MIN(Ω[i,*,*]))/2
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_3_vector.pro
;               format_2d_vec.pro
;               mag__vec.pro
;               unit_vec.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               V1           :  [N,3]-Element [numeric] array of 3-vectors
;               V2           :  [N,3]-Element [numeric] array of 3-vectors
;
;  EXAMPLES:    
;               [calling sequence]
;               a_da = perturb_dot_prod_angle(v1,v2 [,NAN=nan] [,RADIANS=radians]       $
;                                             [,TH_0_90=th_0_90] [,PLANE=plane]         $
;                                             [,DELTA_V1=delta_v1] [,DELTA_V2=delta_v2] )
;
;  KEYWORDS:    
;               NAN          :  If set, routine will ignore non-finite values
;                                 [Default = FALSE]
;               RADIANS      :  If set, routine will return the angles between
;                                 V1 and V2 in radians instead of degrees
;                                 [Default = FALSE]
;               TH_0_90      :  If set, routine will constrain returned angles to values
;                                 between 0-90 degrees by choosing the following:
;                                   th = th < (18d1 - th)
;                                 [Default = FALSE]
;               PLANE        :  Scalar [string] defining the plane in which the user
;                                 wishes to find the angle between V1 and V2.
;                                 Meaning, if PLANE='xy', then only the 1st two
;                                 components of V1 and V2 are used in the dot-product.
;                                 Accepted inputs are:
;                                   'xy'
;                                   'xz'
;                                   'yz'
;                                 [Default = FALSE]
;               DELTA_V1     :  [N,3]-Element or [3]-element [numeric] array of 3-vectors
;                                 defining the uncertainties for the components of V1
;                                 [ Default = [0,0,0] ]
;               DELTA_V2     :  [N,3]-Element or [3]-element [numeric] array of 3-vectors
;                                 defining the uncertainties for the components of V2
;                                 [ Default = [0,0,0] ]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Either both inputs are [N,3]-element arrays or only one is while
;                     the other is a [3]-element array.  However, if V1 is an
;                     [N,3]-element array and V2 is an [M,3]-element array, where
;                     N does not equal M, then the routine will return a zero.
;               2)  Order matters if either vector has finite complex values because:
;                     (V1 . V2) = V1_i x (V2_i)*
;                     where z* is the complex conjugate of z.
;               3)  The angle between two vectors, if complex, is given by:
;                     Cos(ø) = Re[ ∑ V1_i x (V2_i)* ]/( |V1| |V2| )
;               4)  See also:  dot_prod_angle.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/04/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/04/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION perturb_dot_prod_angle,v1,v2,NAN=nan,RADIANS=radians,TH_0_90=th_0_90,$
                                      PLANE=plane,DELTA_V1=delta_v1,DELTA_V2=delta_v2

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
pertb          = [-1d0,0d0,1d0]
;;  Error messages
noinput_mssg   = 'No input was supplied...'
badinfm_mssg   = 'V1 and V2 must be [N,3]-element arrays of 3-vectors...'
incorne_mssg   = 'DP:  Incorrect number of elements.  One of the dimensions must be equal to 3.'
incordm_mssg   = 'Incorrect dimensions...  Either both inputs are [N,3]-element arrays or one is and the other is a [3]-element array...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 2) OR (N_ELEMENTS(v1) EQ 0) OR (N_ELEMENTS(v2) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check input format
test           = (is_a_3_vector(v1,/NOMSSG) EQ 0) OR (is_a_3_vector(v2,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,badinfm_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Force the input vectors to be [N,3]-element arrays
;;----------------------------------------------------------------------------------------
fv1            = format_2d_vec(v1)
fv2            = format_2d_vec(v2)
szd1           = SIZE(fv1,/DIMENSIONS)
szd2           = SIZE(fv2,/DIMENSIONS)
test           = (szd1[0] NE szd2[0]) AND ((szd1[0] NE 1) OR (szd2[0] NE 1))
IF (test[0]) THEN BEGIN
  ;;  Check to see if one of the inputs is a single vector
  test           = (szd1[0] NE szd2[0]) AND ((szd1[0] EQ 1) OR (szd2[0] EQ 1))
  IF (test[0]) THEN BEGIN
    IF (szd1[0] EQ 1) THEN BEGIN
      ;;  V1 is a [3]-element vector --> convert to 2D
      fv1f           = REPLICATE(1d0,szd2[0]) # fv1
      fv2f           = fv2
    ENDIF ELSE BEGIN
      ;;  V2 is a [3]-element vector --> convert to 2D
      fv1f           = fv1
      fv2f           = REPLICATE(1d0,szd1[0]) # fv2
    ENDELSE
  ENDIF ELSE BEGIN
    ;;  Input format is incorrect
    MESSAGE,incordm_mssg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0b
  ENDELSE
ENDIF ELSE BEGIN
  fv1f           = fv1
  fv2f           = fv2
ENDELSE
szd11          = SIZE(fv1f,/DIMENSIONS)
nv             = szd11[0]                  ;;  # of 3-vectors in each array
;;  Check for complex values
test           = (TOTAL(IMAGINARY(fv1f)) EQ 0) AND (TOTAL(IMAGINARY(fv2f)) EQ 0)
IF (test[0]) THEN cmplx_on = 0b ELSE cmplx_on = 1b
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check RADIANS
test           = (N_ELEMENTS(radians) EQ 1) AND KEYWORD_SET(radians)
IF (test[0]) THEN rad_on = 1b ELSE rad_on = 0b
;;  Check TH_0_90
test           = (N_ELEMENTS(th_0_90) EQ 1) AND KEYWORD_SET(th_0_90)
IF (test[0]) THEN th90_on = 1b ELSE th90_on = 0b
;;  Check PLANE
test           = KEYWORD_SET(plane) AND (SIZE(plane,/TYPE) EQ 7)
IF (test[0]) THEN plane_on = 1b ELSE plane_on = 0b
;;  Check DELTA_V1
test           = is_a_3_vector(delta_v1,/NOMSSG)
IF (test[0]) THEN BEGIN
  d_v1           = format_2d_vec(delta_v1)
  szdv1          = SIZE(d_v1,/DIMENSIONS)
  test           = (szdv1[0] EQ 1) OR (szdv1[0] EQ nv[0])
  IF (test[0]) THEN BEGIN
    IF (szdv1[0] EQ 1) THEN dv1 = REPLICATE(1d0,nv[0]) # ABS(d_v1) ELSE dv1 = ABS(d_v1)
  ENDIF ELSE BEGIN
    dv1            = REPLICATE(0d0,nv[0],3L)
  ENDELSE
ENDIF ELSE BEGIN
  dv1            = REPLICATE(0d0,nv[0],3L)
ENDELSE
;;  Check DELTA_V2
test           = is_a_3_vector(delta_v2,/NOMSSG)
IF (test[0]) THEN BEGIN
  d_v2           = format_2d_vec(delta_v2)
  szdv2          = SIZE(d_v2,/DIMENSIONS)
  test           = (szdv2[0] EQ 1) OR (szdv2[0] EQ nv[0])
  IF (test[0]) THEN BEGIN
    IF (szdv2[0] EQ 1) THEN dv2 = REPLICATE(1d0,nv[0]) # ABS(d_v2) ELSE dv2 = ABS(d_v2)
  ENDIF ELSE BEGIN
    dv2            = REPLICATE(0d0,nv[0],3L)
  ENDELSE
ENDIF ELSE BEGIN
  dv2            = REPLICATE(0d0,nv[0],3L)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check if user only wants to consider a 2D plane
;;----------------------------------------------------------------------------------------
IF (plane_on[0]) THEN BEGIN
  CASE STRLOWCASE(plane[0]) OF
    'xy'  :  BEGIN
      ;;  Angle between projection onto XY-Plane
      fv1f[*,2]      = 0d0
      fv2f[*,2]      = 0d0
    END
    'xz'  :  BEGIN
      ;;  Angle between projection onto XZ-Plane
      fv1f[*,1]      = 0d0
      fv2f[*,1]      = 0d0
    END
    'yz'  :  BEGIN
      ;;  Angle between projection onto YZ-Plane
      fv1f[*,0]      = 0d0
      fv2f[*,0]      = 0d0
    END
    ELSE  :  ;;  Do nothing
  ENDCASE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Perturb input vectors
;;    V' = {V - ∂V, V, V + ∂V}
;;----------------------------------------------------------------------------------------
IF (cmplx_on[0]) THEN dumb = DCOMPLEX(0d0,0d0) ELSE dumb = d
v1_dv          = REPLICATE(dumb[0],nv[0],3L,3L)
v2_dv          = REPLICATE(dumb[0],nv[0],3L,3L)
FOR k=0L, 2L DO BEGIN
  v1_dv[*,*,k] = fv1f + dv1*pertb[k]
  v2_dv[*,*,k] = fv2f + dv2*pertb[k]
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Calculate the dot product
;;----------------------------------------------------------------------------------------
u1_dot_u2      = REPLICATE(dumb[0],nv[0],3L,3L)
IF (cmplx_on[0]) THEN BEGIN
  ;;  Inputs have finite imaginary parts
  FOR k=0L, 2L DO BEGIN
    FOR j=0L, 2L DO BEGIN
      ;;  Calculate the magnitudes of the input vectors
      magv1            = mag__vec(v1_dv[*,*,j],NAN=nan)
      magv2            = mag__vec(v2_dv[*,*,k],NAN=nan)
      ;;  Calculate the dot product
      u1_dot_u2[*,j,k] = REAL_PART(TOTAL(v1_dv[*,*,j]*CONJ(v2_dv[*,*,k]),2L,NAN=nan,/DOUBLE))/(magv1*magv2)
    ENDFOR
  ENDFOR
ENDIF ELSE BEGIN
  ;;  Inputs are real
  FOR k=0L, 2L DO BEGIN
    FOR j=0L, 2L DO BEGIN
      ;;  Calculate the unit vectors
      uv1              = unit_vec(v1_dv[*,*,j])
      uv2              = unit_vec(v2_dv[*,*,k])
      ;;  Calculate the dot product
      u1_dot_u2[*,j,k] = TOTAL(uv1*uv2,2L,NAN=nan,/DOUBLE)
    ENDFOR
  ENDFOR
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Calculate the angle between the two vectors
;;----------------------------------------------------------------------------------------
test           = (ABS(u1_dot_u2) GT 1)
bad            = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0) THEN MESSAGE,'unit_vec.pro seems to have failed...?',/INFORMATIONAL,/CONTINUE
IF (bd GT 0) THEN u1_dot_u2[bad] = d  ;;  remove for now [if this happens, something is wrong]
;;  Calculate angle [radians]
thetas         = ACOS(u1_dot_u2)                             ;;  [N,3,3]-Element array
theta0         = MEAN(thetas,NAN=nan,/DOUBLE,DIMENSION=3)    ;;  [N,3]-Element array
gtheta         = MEAN(theta0,NAN=nan,/DOUBLE,DIMENSION=2)    ;;  [N]-Element array
theta0         = (thetas + 2d0*!DPI)                         ;;  Avoid roll over errors
mnth0          = MIN(theta0,NAN=nan,DIMENSION=3)             ;;  [N,3]-Element array
mnth1          = MIN( mnth0,NAN=nan,DIMENSION=2)             ;;  [N]-Element array
mxth0          = MAX(theta0,NAN=nan,DIMENSION=3)             ;;  [N,3]-Element array
mxth1          = MAX( mxth0,NAN=nan,DIMENSION=2)             ;;  [N]-Element array
dtheta         = (mxth1 - mnth1)/2d0                         ;;  [N]-Element array
;;----------------------------------------------------------------------------------------
;;  Convert to degrees and/or 0--90 degrees if desired
;;----------------------------------------------------------------------------------------
;;  Convert to:  0 ≤ Ω ≤ π/2
IF (th90_on[0]) THEN BEGIN
  gtheta         = gtheta < (!DPI - gtheta)
  dtheta         = dtheta < (!DPI - dtheta)         ;;  Not sure if I should keep this...
ENDIF
;;  Convert to:  degrees
IF (~rad_on[0]) THEN BEGIN
  gtheta         *= (18d1/!DPI)
  dtheta         *= (18d1/!DPI)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
;;  OUTPUT[*,0] = actual angles
;;  OUTPUT[*,1] = angle uncertainties
output         = [[gtheta],[dtheta]]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END


