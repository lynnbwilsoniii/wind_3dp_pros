;+
;*****************************************************************************************
;
;  FUNCTION :   cal_rot.pro
;  PURPOSE  :   Returns a rotation matrix that rotates V1 and V2 to the X'-Y' Plane where
;                 V1 is rotated to the X'-Axis and V2 into the X'-Y' Plane.
;
;  CALLED BY: 
;               add_df2d_to_ph.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               V1  :  3-Element vector to be X'-Axis about which V2 is rotated to make
;                        the new X'-Y' Plane
;               V2  :  3-Element vector
;
;  EXAMPLES:    NA
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  J. McFadden changed something...        [09/13/1995   v1.0.?]
;             2)  Re-wrote and cleaned up                 [06/21/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  J. McFadden
;    LAST MODIFIED:  06/21/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION cal_rot, v1, v2

;-----------------------------------------------------------------------------------------
; Make sure input are of the correct format
;-----------------------------------------------------------------------------------------
v1 = REFORM(v1)
v2 = REFORM(v2)

a  = v1/ SQRT(TOTAL(v1^2,/NAN))  ; => V1 unit vector
d  = v2/ SQRT(TOTAL(v2^2,/NAN))  ; => V2 " "
c  = CROSSP(a,d)                 ; => V1 \cross V2
; => Renormalize c
c /= SQRT(TOTAL(c^2,/NAN))

b  = -1.*CROSSP(a,c)             ; => -V1 \cross (V1 \cross V2)
; => Renormalize b
b /= SQRT(TOTAL(b^2,/NAN))
;-----------------------------------------------------------------------------------------
; Define the Inverted Rotation Matrix
;-----------------------------------------------------------------------------------------
rotinv      = DBLARR(3,3)
rotinv[0,*] = a
rotinv[1,*] = b
rotinv[2,*] = c
;-----------------------------------------------------------------------------------------
; Invert the Rotation Matrix
;-----------------------------------------------------------------------------------------
mrot = INVERT(rotinv)
RETURN, mrot
END
