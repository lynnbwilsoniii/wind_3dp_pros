



function  euler_rot_matrix,ev,rot_angle=rot_angle,set_angle=sa
rot = dblarr(3,3)
e=double(ev)
if n_elements(sa) eq 1 then begin
   e= e / sqrt(total(e^2))
   e = sqrt((1-cosd(sa))/2) * e * sign(sa)
endif
e0 = sqrt( 1 - total(e^2) )
e1 = e[0]
e2 = e[1]
e3 = e[2]
rot[0,0] = e0^2+e1^2-e2^2-e3^2
rot[0,1] = 2*(e1*e2 + e0*e3)
rot[0,2] = 2*(e1*e3 - e0*e2)
rot[1,0] = 2*(e1*e2 - e0*e3)
rot[1,1] = e0^2-e1^2+e2^2-e3^2
rot[1,2] = 2*(e2*e3 + e0*e1)
rot[2,0] = 2*(e1*e3 + e0*e2)
rot[2,1] = 2*(e2*e3 - e0*e1)
rot[2,2] = e0^2-e1^2-e2^2+e3^2
rot_angle = acos(e0^2-e1^2-e2^2-e3^2)*180/!dpi * sign(total(e*ev))
return,set_zeros(rot,3e-16)
end

