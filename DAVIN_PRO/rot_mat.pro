;+
;*****************************************************************************************
;
;  FUNCTION :   rot_mat.pro
;  PURPOSE  :   Creates a rotation matrix that takes two input vectors, V1 and V2, and
;                 rotates them into a new X'-Z' plane, where the V1 vector is along
;                 the new Z'-Axis and V2 is in the X'-Z' plane.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               V1  :  3-Element vector about which you wish to rotate other vectors
;               V2  :  3-Element vector (semi-optional)
;                       [  Default = [1.0,0.0,0.0]  ]
;
;  EXAMPLES:    
;               mrot = rot_mat(v1,v2)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  I renormalized the unit vectors to avoid floating point errors
;                   which become important when rotating high energy data
;                                                            [05/23/2008   v1.0.1]
;             2)  Updated man page                           [08/05/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/05/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rot_mat,v1,v2

;-----------------------------------------------------------------------------------------
; => Check input parameters
;-----------------------------------------------------------------------------------------
a0 = REFORM(v1)     ; => Make sure V1 is not an [1,3]-element array

a  = a0/ SQRT(TOTAL(a0^2,/NAN))   ; => Renormalize
IF NOT KEYWORD_SET(v2) THEN v2 = [1d0,0d0,0d0]
a1 = REFORM(v2)     ; => Make sure V2 is not an [1,3]-element array

b  = CROSSP(a,a1)
; => Renormalized (a x a1)
b  = b/ SQRT(TOTAL(b^2,/NAN))

c  = CROSSP(b,a)
; => Renormalized (b x a)
c = c/ SQRT(TOTAL(c^2,/NAN))
;-----------------------------------------------------------------------------------------
; -Now remove rounding errors (can become an issue if floats are used)
;-----------------------------------------------------------------------------------------
ftest    = REFORM(a)*1d3
badt     = WHERE(ABS(ftest) LT 0.1,bd)
IF (bd GT 0) THEN BEGIN
  a[badt] = 0.0
  ; -Need to renormalize the unit vector
  a       = a/ SQRT(TOTAL(a^2,/NAN))
ENDIF

ftest    = REFORM(b)*1d3
badt     = WHERE(ABS(ftest) LT 0.1,bd)
IF (bd GT 0) THEN BEGIN
  b[badt] = 0.0
  ; -Need to renormalize the unit vector
  b       = b/ SQRT(TOTAL(b^2,/NAN))
ENDIF

ftest    = REFORM(c)*1d3
badt     = WHERE(ABS(ftest) LT 0.1,bd)
IF (bd GT 0) THEN BEGIN
  c[badt] = 0.0
  ; -Need to renormalize the unit vector
  c       = c/ SQRT(TOTAL(c^2,/NAN))
ENDIF
;-----------------------------------------------------------------------------------------
; => Define rotation matrix
;-----------------------------------------------------------------------------------------
mrot = [[c],[b],[a]]
 
RETURN, mrot
END

