;+
;FUNCTION:  pangle,theta,phi,b_theta,b_phi
;PURPOSE:
; Computes pitch angle given two sets of theta and phi
;INPUT:
;  theta,phi:       double (array or scaler)  first directions
;  b_theta,b_phi :  double (array or scaler)  second directions
;RETURNS:  pitch angle (array or scaler) same dimensions as theta and phi
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)pangle.pro	1.4 95/11/28
;
;-

function pangle, theta,phi,b_theta,b_phi,vec = vec
if n_elements(vec) eq 3 then xyz_to_polar,vec,theta=b_theta,phi=b_phi
sphere_to_cart,1.,b_theta,b_phi,bx,by,bz
sphere_to_cart,1.,  theta,  phi,sx,sy,sz
dot = (bx*sx + by*sy + bz*sz)
pa = 180./!dpi*acos(dot)
return, pa
end




