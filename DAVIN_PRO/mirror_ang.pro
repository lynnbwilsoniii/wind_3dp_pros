;+
;FUNCTION mirror_ang
;USAGE:
;  ang = mirror_ang(v,par=p)
;-

function mirror_ang, v, parameters=p  $
   , p_names = p_names, pder_values= pder_values 

if not keyword_set(p) then $
   p = {br:6.d, v0:1000.0d,  vs:0.d  }


a = p.br
b = -2*p.vs/v
c  = (p.v0^2+p.vs^2)/v^2-p.br+1

b2m4ac = b^2-4*a*c

bad = where(b2m4ac lt 0,count)
if count ne 0 then b2m4ac(bad) = !values.f_nan

cosa = (b + sqrt(b2m4ac))/2/a
;if p.br lt 0 then  cosa = (b + sqrt(b^2-4*a*c))/2/a  $
;else               cosa = (b  sqrt(b^2-4*a*c))/2/a

bad = where(cosa gt 1.,count)
if count ne 0 then cosa(bad) = !values.f_nan

ang = acos(cosa)
if p.vs le 0 then ang = !dpi-ang

;bad = where(a gt 1.,count)
;if count ne 0 then a(bad) = !values.f_nan
;if p.brat lt 0. then a= !pi - a

return,ang/!dtor
end


