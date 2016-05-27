;+
;*****************************************************************************************
;
;  FUNCTION :   colinear_test.pro
;  PURPOSE  :   Tests whether the 3 arrays of N-elements have any co-linear data points.
;                 If given three points A, B, and C and one wishes to triangulate these
;                 points, the process cannot be done if they are co-linear.  To test
;                 whether the points are co-linear, simply determine if the points
;                 consist of linear combinations of the other points.  Meaning, IF
;                 (vector AB is a real multiple of the vector BC) OR 
;                 (vector AB is a real multiple of the vector AC)
;                 THEN they are co-linear.  The default the numerical threshold used to
;                 test this in the program is 10^(-12).
;
;  CALLED BY:   
;               plot3d.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               X1      :  1st N-element array corresponding the 1st component of
;                            either the cartesian or spherical coordinate systems
;               X2      :  2nd N-element array corresponding the 2nd component of
;                            either the cartesian or spherical coordinate systems
;               X3      :  3rd N-element array corresponding the 3rd component of
;                            either the cartesian or spherical coordinate systems
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               SPHERE  :  If set, program assumes input is in spherical coordinates
;                            corresponding to:
;                            X1  :  SQRT(x^2 + y^2 + z^2)          [ = r]
;                            X2  :  ATAN(y,x)                      [ = phi]
;                            X3  :  ACOS(z/SQRT(x^2 + y^2 + z^2))  [ = theta]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  If input is spherical, make sure the angles (X2 and X3) are in 
;                     radians
;
;   CREATED:  03/19/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/19/2010   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION colinear_test,x1,x2,x3,SPHERE=sphere

;-----------------------------------------------------------------------------------------
; => Check Input
;-----------------------------------------------------------------------------------------
n1   = N_ELEMENTS(REFORM(x1))
n2   = N_ELEMENTS(REFORM(x2))
n3   = N_ELEMENTS(REFORM(x3))
test = (n1 NE n2) OR (n2 NE n3)
;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f         = !VALUES.F_NAN
d         = !VALUES.D_NAN
dumb      = REPLICATE(d,n1)
dumb3     = REPLICATE(d,n1,3)

IF (test) THEN RETURN,1 ELSE nn = n1
;-----------------------------------------------------------------------------------------
; => Check coordinate system
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(sphere) THEN BEGIN
  xx = REFORM(x1)*COS(REFORM(x2))*SIN(REFORM(x3))
  yy = REFORM(x1)*SIN(REFORM(x2))*SIN(REFORM(x3))
  zz = REFORM(x1)*COS(REFORM(x3))
ENDIF ELSE BEGIN
  xx = REFORM(x1)
  yy = REFORM(x2)
  zz = REFORM(x3)
ENDELSE

m   = 0
p   = 0
o   = 0
in1  = LINDGEN(nn)
in2  = SHIFT(in1,1)
in3  = SHIFT(in1,-1)
; => Define various vectors shifted by 0, +1, and -1 elements
v1   = [[xx[in1]],[yy[in1]],[zz[in1]]]
v2   = [[xx[in2]],[yy[in2]],[zz[in2]]]
v3   = [[xx[in3]],[yy[in3]],[zz[in3]]]
; => Find magnitudes
nv1  = SQRT(TOTAL(v1^2,2L,/NAN)) # REPLICATE(1d0,3L)
nv2  = SQRT(TOTAL(v2^2,2L,/NAN)) # REPLICATE(1d0,3L)
nv3  = SQRT(TOTAL(v3^2,2L,/NAN)) # REPLICATE(1d0,3L)
; => Normalize the vectors
vv1  = v1/nv1
vv2  = v2/nv2
vv3  = v3/nv3
; => Find the ratio between the shifted vectors
tt1  = vv1/vv2
tt2  = vv2/vv3
tt3  = vv3/vv1
; => Check the tolerance of the ratios
b1t  = (SQRT(TOTAL((tt1 - vv1)^2,2L,/NAN)) LE 1d-12)
b2t  = (SQRT(TOTAL((tt2 - vv2)^2,2L,/NAN)) LE 1d-12)
b3t  = (SQRT(TOTAL((tt3 - vv3)^2,2L,/NAN)) LE 1d-12)

bad1 = WHERE(b1t,bd1)
bad2 = WHERE(b2t,bd2)
bad3 = WHERE(b3t,bd3)
bad  = REPLICATE(0,nn,3)
IF (bd1 GT 0) THEN bad[bad1,0] = 1
IF (bd2 GT 0) THEN bad[bad2,1] = 1
IF (bd3 GT 0) THEN bad[bad3,2] = 1

RETURN,TOTAL(bad) GT 0.
END