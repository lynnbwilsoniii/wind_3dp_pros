;+
;*****************************************************************************************
;
;  FUNCTION :   spherical_poly_solidangle.pro
;  PURPOSE  :   This routine finds the solid angle subtended by a spherical polygon
;                 lying on a unit spherical shell given the [N]-vertices of the
;                 polygon in terms of the latitude and longitude.  The routine
;                 decomposes the polygon into N - 2 triangles and finds the solid
;                 angles [sr] of each triangle.  The returned value may contain negative
;                 and/or zeroed values, which are non-physical and degenerate results,
;                 respectively.  To find the total area of the polygon, sum over the
;                 positive-definite return values.
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
;               LAT        :  [N]-Element [float/double] array of latitudes [degrees]
;                               corresponding to the vertices of the polygon
;               LON        :  [N]-Element [float/double] array of longitudes [degrees]
;                               corresponding to the vertices of the polygon
;
;  EXAMPLES:    
;               sr = spherical_poly_solidangle(lat,lon,TRI_STRUC=tri_struc)
;
;  KEYWORDS:    
;               TRI_STRUC  :  Set to a named variable to return a structure containing
;                               the arc lengths {a,b,c} [radians] and the interior
;                               angles {A,B,C} [degrees] of each triangle within the
;                               polygon
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               0)  LAT = 90 - COLAT, where COLAT is the colatitude (or the spherical
;                     coordinate theta measured from the cartesian Z-axis)
;               1)  N = # of vertices of the spherical polygon [e.g., 3 for triangle]
;
;               2)  The general formula for the surface area of a spherical polygon is:
;                       ¥_n = { ∑ - [n - 2] π } R^2
;                     where n = # of vertices of the spherical polygon, ∑ is the sum of
;                     the interior angles, and R is the radius of the spherical shell
;                     upon which the polygon exists.  So for a spherical triangle with
;                     interior angles {A,B,C}, the equation reduces to:
;                       ¥_3 = { (A + B + C) - π } R^2 = E R^2
;                     where E is the spherical excess.
;
;               3)  If we start with the set of coordinates (ø_i,Ω_i) and (ø_j,Ω_j),
;                     where ø(Ω) defines the latitude(longitude) of the points on
;                     a spherical shell of radius R, and we define the spherical
;                     triangle to have arc length sides {a,b,c} opposite to the
;                     interior angles {A,B,C}, respectively, then we know that:
;                       b      = 90 - ø_j
;                       c      = 90 - ø_i
;                       A      = Ω_j - Ω_i = ∆Ω
;                     where we set R = 1.  These definitions hold because the input
;                     angles are defined with respect to a cartesian coordinate basis.
;
;                   From these definitions, we can see that the third side of the
;                     triangle between (ø_i,Ω_i) and (ø_j,Ω_j) is defined by the arc
;                     length opposite A or ∆Ω.  We can define the arc length of a by
;                     using the haversine formula to give:
;                       hav(a) = hav(b - c) + sin(b) sin(c) hav(A)
;                     and using sin(90 - x) = cos(x), we can show that:
;                        hav(a) = [1 - cos(a)]/2
;                               = hav(ø_j - ø_i) + cos(ø_j) cos(ø_i) hav(∆Ω)
;                               = [1 - cos(ø_j - ø_i)]/2 +
;                                 cos(ø_j) cos(ø_i) [1 - cos(∆Ω)]/2
;                       -cos(a) = -cos(ø_j - ø_i) + cos(ø_j) cos(ø_i) [1 - cos(∆Ω)]
;                        cos(a) = [cos(ø_j) cos(ø_i) + sin(ø_j) sin(ø_i)]
;                                  - cos(ø_j) cos(ø_i) + cos(ø_j) cos(ø_i) cos(∆Ω)
;                        cos(a) = sin(ø_j) sin(ø_i) + cos(ø_j) cos(ø_i) cos(∆Ω)
;
;                   This corresponds to the "spherical law of cosines," which we can
;                     derive using the dot-product of the vectors r_i and r_j, given by:
;                                /                 \
;                               | cos(Ω_i) cos(ø_i) |
;                       r_i = R | sin(Ω_i) cos(ø_i) |
;                               |     sin(ø_i)      |
;                                \                 /
;                     This results in:
;                            ∆ß = c/R = acos[(r_i . r_j)/R^2]
;                       cos(∆ß) = cos(ø_i) cos(ø_j) cos(Ω_i) cos(Ω_j) +
;                                 cos(ø_i) cos(ø_j) sin(Ω_i) sin(Ω_j) +
;                                 sin(ø_i) sin(ø_j)
;                               = cos(ø_i) cos(ø_j) [cos(Ω_i) cos(Ω_j) +
;                                 sin(Ω_i) sin(Ω_j)] + sin(ø_i) sin(ø_j)
;                               = cos(ø_i) cos(ø_j) cos(Ω_i - Ω_j) + sin(ø_i) sin(ø_j)
;
;                   If the arc length on the surface of the sphere associated with ∆ß
;                     is small, then this formula can produce large rounding errors.  To
;                     deal with these cases, we can use the haversine formula.
;
;                   Instead of using hav(x) = [1 - cos(x)]/2, use hav(x) = sin(x/2)^2
;                     in the manipulation of hav(a) shown above and we find:
;                       sin(a/2)^2 = sin[(ø_j - ø_i)/2]^2 + cos(ø_j) cos(ø_i) sin[∆Ω/2]^2
;                         sin(a/2) = [ sin[∆ø/2]^2 + cos(ø_j) cos(ø_i) sin[∆Ω/2]^2 ]^(1/2)
;
;                   Thus, from any two points (ø_i,Ω_i) and (ø_j,Ω_j), we can define the
;                     semi-perimeter, s, of the spherical triangle as:
;                       s = [a + b + c]/2
;                     which we can use to find the spherical excess, E, by using
;                     l'Huilier's theorem, which is given by:
;                       tan(E/4)^2 = tan(s/2) tan[(s - a)/2] tan[(s - b)/2]  tan[(s - c)/2]
;
;                   From Note (2) we can see that the area of the spherical triangle,
;                     ¥_3, is defined by E R^2.  So using a unit sphere, the area is
;                     dependent only upon E.
;
;               4)  Trigonometric Identities
;                     cos(a ± b) =   cos(a) cos(b) -/+ sin(a) sin(b)
;                     sin(a ± b) =   sin(a) cos(b)  ±  sin(b) cos(a)
;                     sin(2 a)   = 2 sin(a) cos(a)
;                     cos(x)     = 1 - 2 sin(x/2)^2
;                                = 1 - 2 hav(µ)      [hav = haversine]
;                     cos(x)     = sin(90 - x)
;                     sin(x)     = cos(90 - x)
;
;  REFERENCES:  
;               0)  See also:  spherical_angular_diff.pro
;               1)  http://en.wikipedia.org/wiki/Great-circle_distance
;               2)  http://en.wikipedia.org/wiki/Haversine_formula
;               3)  http://mathworld.wolfram.com/SphericalTrigonometry.html
;               4)  http://mathworld.wolfram.com/TrigonometricAdditionFormulas.html
;               5)  http://en.wikipedia.org/wiki/Solid_angle
;               6)  http://mathworld.wolfram.com/GreatCircle.html
;
;   CREATED:  06/21/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/21/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION spherical_poly_solidangle,lat,lon,TRI_STRUC=tri_struc

;;----------------------------------------------------------------------------------------
;; => Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
b_low          = 5d0*!DPI/18d1
;;  Dummy error messages
noinp__msg     = 'User must supply two arrays of angles...'
badinp_msg     = 'LAT and LON must have the same number of elements...'
baddim_msg     = 'LAT and LON must have the same dimensions...'
badn___msg     = 'LAT and LON must have at least 2 elements...'
;;----------------------------------------------------------------------------------------
;; => Check input structure format
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN BEGIN
  ;;  Incorrect input
  MESSAGE,noinp__msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

test           = (N_ELEMENTS(lat) NE N_ELEMENTS(lon))
IF (test) THEN BEGIN
  ;;  Unequal # of elements
  MESSAGE,badinp_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

test           = TOTAL(SIZE(lat,/DIMENSIONS) NE SIZE(lon,/DIMENSIONS)) NE 0
IF (test) THEN BEGIN
  ;;  Incompatible array dimensions
  MESSAGE,baddim_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

nn             = N_ELEMENTS(lat)
test           = (nn LT 2)
IF (test) THEN BEGIN
  ;;  Not enough elements in either input
  MESSAGE,badn___msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define variables
;;----------------------------------------------------------------------------------------
;;  convert to radians
latr           = lat*!DPI/18d1
lonr           = lon*!DPI/18d1
;;  Define indices for each latitude(longitude)
i              = LINDGEN(nn)
j              = SHIFT(i,1)      ;;  j = [(nn - 1L),i[0L:(nn - 2L)]]
;;  Define cos(ø)
clat           = COS(latr)
;;  Define sin(∆ø/2)^2 and sin(∆Ω/2)^2
sdlat_2        = SIN((latr[j] - latr[i])/2d0)^2
sdlon_2        = SIN((lonr[j] - lonr[i])/2d0)^2
;;  Compute the haversine formula to find the arc length, a
;;    hav(a) = sin(a/2)^2 = [ sin[∆ø/2]^2 + cos(ø_j) cos(ø_i) sin[∆Ω/2]^2 ]
sina2          = SQRT(sdlat_2 + clat[i]*clat[j]*sdlon_2)
a              = 2d0*ASIN(sina2)
;;  Define the arc lengths b and c
;;    b      = 90 - ø_j
;;    c      = 90 - ø_i
b              = !DPI/2d0 - latr[j]
c              = !DPI/2d0 - latr[i]
;;  Define the semi-perimeter, s
;;    s      = [a + b + c]/2
s              = (a + b + c)/2d0
;;  Define the half-angles used in the argument of l'Huilier's theorem, £
a0             = s/2d0
aa             = (s - a)/2d0
ab             = (s - b)/2d0
ac             = (s - c)/2d0
;;  Calculate the argument of l'Huilier's theorem, £
;;    tan(E/4)^2 = tan(s/2) tan[(s - a)/2] tan[(s - b)/2]  tan[(s - c)/2]
;;               = £
t              = TAN(a0)*TAN(aa)*TAN(ab)*TAN(ac)
;;  Define the absolute difference of the longitude, |∆Ω| < 360
;;    [i.e., shift ∆Ω by 2π if ∆Ω ≤ 0]
alon           = (lonr[j] - lonr[i]) + 2d0*!DPI*(lonr[i] GE lonr[j])
;;  Define the 'sign' of the spherical excess
;;    +1  :  for ∆Ω ≤ π
;;    -1  :  for ∆Ω > π
sign_lon       = (1d0 - 2d0*(alon GT !DPI))
;;  Define the spherical excess, E
;;    E = the solid angle area subtended by the triangle
fac0           = ABS(4d0*ATAN( SQRT( t ) ))
sph_exc        = fac0*sign_lon
;;----------------------------------------------------------------------------------------
;;  Define the rest of the triangle parameters
;;----------------------------------------------------------------------------------------
;ang_A          = (lonr[j] - lonr[i])*18d1/!DPI
ang_A          = ACOS((COS(a) - COS(b)*COS(c))/( SIN(b)*SIN(c) ))*18d1/!DPI
ang_B          = ACOS((COS(b) - COS(a)*COS(c))/( SIN(a)*SIN(c) ))*18d1/!DPI
ang_C          = ACOS((COS(c) - COS(a)*COS(b))/( SIN(a)*SIN(b) ))*18d1/!DPI
;;  Define a return structure for the triangle parameters
abs_str        = ['A','B','C']
info_str       = 'SIDE_[a,b,c] = radians, ANG_[A,B,C] = degrees'
tags           = ['SIDE_'+abs_str,'ANG_'+abs_str,'INFO']
tri_struc      = CREATE_STRUCT(tags,a,b,c,ang_A,ang_B,ang_C,info_str)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,sph_exc
END

