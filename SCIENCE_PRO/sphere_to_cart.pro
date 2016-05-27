;+
;*****************************************************************************************
;
;  FUNCTION :   sphere_to_cart.pro
;  PURPOSE  :   Transforms from a spherical to a cartesian coordinate system.
;
;  CALLED BY: 
;               add_df2dp.pro
;               add_df2d_to_ph.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               R      :  N-Element array of radial magnitudes in spherical coordinates
;               THETA  :  N-Element array of poloidal angles (deg)
;               PHI    :  N-Element array of azimuthal angles (deg)
;               X      :  Named variable to return the cartesian X-component
;               Y      :  Named variable to return the cartesian Y-component
;               Z      :  Named variable to return the cartesian Z-component
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               VEC    :  Set to a named variable to return the [N,3]-element
;                           cartesian vector array
;
;  NOTES:
;               -90 < theta < 90   (latitude not co-lat)  
;
;   CHANGED:  1)  Davin Larson changed something...       [11/01/2002   v1.0.6]
;             2)  Re-wrote and cleaned up                 [06/21/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/21/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO sphere_to_cart,r,theta,phi, x, y, z,VEC=vec

csp = COS(!DPI/18e1*phi)
cst = COS(!DPI/18e1*theta)
snp = SIN(!DPI/18e1*phi)
snt = SIN(!DPI/18e1*theta)
; => Define cartesian coordinates
x   = cst * csp * r
y   = cst * snp * r
z   = snt * r
vec = [[x],[y],[z]]

RETURN
END
