;+
;*****************************************************************************************
;
;  FUNCTION :   pangle.pro
;  PURPOSE  :   Computes pitch-angle given two sets of theta and phi (first two 
;                 are typically from data and second two from B-field direction) and
;                 returns the pitch-angles with the same dimensions as the input THETA
;                 and PHI.
;
;  CALLED BY: 
;               pad.pro
;               my_pad_dist.pro
;
;  CALLS:
;               xyz_to_polar.pro
;               sphere_to_cart.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               THETA    :  N-Element array of poloidal angles (deg)
;               PHI      :  N-Element array of azimuthal angles (deg)
;               B_THETA  :  N-Element array of 2nd poloidal angles (deg) with which
;                             to calibrate the first set with
;               B_PHI    :  N-Element array of 2nd azimuthal angles (deg) with which
;                             to calibrate the first set with
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               VEC      :  Set to a 3-element cartesian vector array to calculate the
;                             values for B_THETA and B_PHI
;
;   CHANGED:  1)  Davin Larson changed something...       [11/28/1995   v1.0.4]
;             2)  Re-wrote and cleaned up                 [06/22/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/22/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION pangle, theta,phi,b_theta,b_phi,VEC=vec

;-----------------------------------------------------------------------------------------
; => Check input parameters
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(vec) EQ 3) THEN xyz_to_polar,vec,THETA=b_theta,PHI=b_phi
;-----------------------------------------------------------------------------------------
; => Convert 2nd set of angles to cartesian coordinates
;-----------------------------------------------------------------------------------------
sphere_to_cart,1.,b_theta,b_phi,bx,by,bz
;-----------------------------------------------------------------------------------------
; => Convert 1st set of angles to cartesian coordinates
;-----------------------------------------------------------------------------------------
sphere_to_cart,1.,  theta,  phi,sx,sy,sz
;-----------------------------------------------------------------------------------------
; => Calculate the dot product and thus angle between the two vectors
;-----------------------------------------------------------------------------------------
dot = (bx*sx + by*sy + bz*sz)
pa  = 18e1/!DPI*ACOS(dot)
RETURN, pa
END
