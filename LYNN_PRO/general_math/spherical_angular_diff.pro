;+
;*****************************************************************************************
;
;  FUNCTION :   spherical_angular_diff.pro
;  PURPOSE  :   This routine finds the angle on a sphere between two input angular
;                 coordinates given in terms of their latitude and longitude.
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
;               LAT  :  [N]-Element [float/double] array of latitudes [degrees]
;                         corresponding to the points of interest
;               LON  :  [N]-Element [float/double] array of longitudes [degrees]
;                         corresponding to the points of interest
;
;  EXAMPLES:    
;               dang = spherical_angular_diff(lat,lon)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               0)  LAT = 90 - COLAT, where COLAT is the colatitude (or the spherical
;                     coordinate theta measured from the cartesian Z-axis)
;
;               1)  Let us define the set of coordinates (ø_i,Ω_i) and (ø_j,Ω_j),
;                     where ø(Ω) defines the latitude(longitude) of the points on
;                     a spherical shell of radius R.  We can then see that a vector
;                     from the origin to the coordinate (ø_i,Ω_i) is given by:
;                                /                 \
;                               | cos(Ω_i) cos(ø_i) |
;                       r_i = R | sin(Ω_i) cos(ø_i) |
;                               |     sin(ø_i)      |
;                                \                 /
;                     We can calculate the angular difference between r_i and r_j, ∆ß,
;                     by taking the dot-product between the two vectors.  Then we have:
;                       ∆ß = acos[(r_i . r_j)/R^2]
;                  cos(∆ß) = cos(ø_i) cos(ø_j) cos(Ω_i) cos(Ω_j) +
;                            cos(ø_i) cos(ø_j) sin(Ω_i) sin(Ω_j) + sin(ø_i) sin(ø_j)
;                          = cos(ø_i) cos(ø_j) [cos(Ω_i) cos(Ω_j) + sin(Ω_i) sin(Ω_j)] +
;                            sin(ø_i) sin(ø_j)
;                          = cos(ø_i) cos(ø_j) cos(Ω_i - Ω_j) + sin(ø_i) sin(ø_j)
;
;                   If the arc length on the surface of the sphere associated with ∆ß
;                     is small, then this formula can produce large rounding errors.  To
;                     deal with these cases, we can use the haversine formula.
;
;                   To start, assume we have three points on a spherical shell of
;                     radius R defined by the names {X,Y,Z}.  These points define a
;                     spherical triangle with interior angles {A,B,C} opposite to the
;                     arc length sides {a,b,c}, respectively.  Thus, the angle A is
;                     defined by the sides b and c.  Because our input are angles from
;                     well defined coordinate basis axes, we can be clever and choose
;                     the point Z to represent the Z-axis or 'north pole.'  Then the
;                     haversine formula for the arc length of c is given by:
;                       hav(c) = hav(a - b) + sin(a) sin(b) hav(C)
;                     Due to our choice above, and assuming R = 1, we know that:
;                       a      = 90 - ø_y
;                       b      = 90 - ø_x
;                       C      = Ω_y - Ω_x = ∆Ω
;                     and using sin(90 - x) = cos(x), we can show that:
;                               hav(c) = sin(c/2)^2
;                                      = hav(ø_x - ø_y) + cos(ø_x) cos(ø_y) hav(∆Ω)
;                       [1 - cos(c)]/2 = [1 - cos(ø_x - ø_y)]/2 +
;                                        cos(ø_x) cos(ø_y) [1 - cos(∆Ω)]/2
;                              -cos(c) = -cos(ø_x - ø_y) + cos(ø_x) cos(ø_y) [1 - cos(∆Ω)]
;                               cos(c) = [cos(ø_x) cos(ø_y) + sin(ø_x) sin(ø_y)]
;                                        - cos(ø_x) cos(ø_y) + cos(ø_x) cos(ø_y) cos(∆Ω)
;                               cos(c) = sin(ø_x) sin(ø_y) + cos(ø_x) cos(ø_y) cos(∆Ω)
;                     Therefore, we can see that c = ∆ß from the above equation.
;
;                   We can take a slightly different route to get a more familiar form.
;                     Instead of using hav(x) = [1 - cos(x)]/2, use hav(x) = sin(x/2)^2.
;                     This changes the formula for hav(c) to the following:
;                       sin(c/2)^2 = sin[(ø_x - ø_y)/2]^2 + cos(ø_x) cos(ø_y) sin[∆Ω/2]^2
;                         sin(c/2) = [ sin[∆ø/2]^2 + cos(ø_x) cos(ø_y) sin[∆Ω/2]^2 ]^(1/2)
;                                c = 2 asin{
;                                            [
;                                              sin(∆ø/2)^2 + cos(ø_x) cos(ø_y) sin(∆Ω/2)^2
;                                            ]^(1/2)
;                                           }
;
;               2)  Trigonometric Identities
;                     cos(a ± b) =   cos(a) cos(b) -/+ sin(a) sin(b)
;                     sin(a ± b) =   sin(a) cos(b)  ±  sin(b) cos(a)
;                     sin(2 a)   = 2 sin(a) cos(a)
;                     cos(x)     = 1 - 2 sin(x/2)^2
;                                = 1 - 2 hav(µ)      [hav = haversine]
;                     cos(x)     = sin(90 - x)
;                     sin(x)     = cos(90 - x)
;
;  REFERENCES:  
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

FUNCTION spherical_angular_diff,lat,lon

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
;;  Define cosine and sine of each latitude(longitude)
clat           = COS(latr)
slat           = SIN(latr)
;;  Define cosine and sine of their differences
sdlat_2        = SIN((latr[j] - latr[i])/2d0)^2
cdlon          = COS(lonr[j] - lonr[i])
sdlon_2        = SIN((lonr[j] - lonr[i])/2d0)^2
;;  Compute the spherical law of cosines
;;    cos(∆ß) = cos(ø_i) cos(ø_j) cos(Ω_j - Ω_i) + sin(ø_i) sin(ø_j)
;;       {where:  ø(Ω) defines the latitude(longitude) of the <i,j> points, i or j
;;                can = {x,y,z} for i ≠ j, and ∆Ω = Ω_j - Ω_i}
cosbeta        = slat[i]*slat[j] + clat[i]*clat[j]*cdlon
;;  Determine if cos(∆ß) ~ 1 within 10^(-2) or ∆ß ≤ 5 degrees
test           = TOTAL(ACOS(cosbeta) LE b_low) GT 0
IF (test) THEN BEGIN
  ;;  Some angles were small
  ;;    => use the haversine formula
  ;;      ∆ß = 2 asin{ [ sin[∆ø/2]^2 + cos(ø_i) cos(ø_j) sin[∆Ω/2]^2 ]^(1/2) }
  fac0   = SQRT(sdlat_2 + clat[i]*clat[j]*sdlon_2)
  dbeta  = 2d0*ASIN(fac0)*18d1/!DPI
ENDIF ELSE BEGIN
  ;;  Angles were large enough so return to user
  dbeta  = ACOS(cosbeta)*18d1/!DPI
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,dbeta
END
