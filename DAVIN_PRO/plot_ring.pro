

pro plot_ring,dat,e,n

vs = dat.vs
magf = dat.magf

print,n
if !p.multi(0) eq n-1 then begin
   plot_88_angles
;   map_grid,/label,latdel=22.5,londel=22.5,glinest=0,charsi=.75
   return
endif
if !p.multi(0) eq n-2 then begin
   plot_pitchang,dat
   return
endif
return

v = velocity(e,dat.mass)

ma = mirror_ang(v,par=dat)
ra = acos(vs/v) / !dtor
if v lt vs then ra = !values.f_nan

get_ring,magf,ma,theta,phi
oplot,phi,theta;,linestyle = 1
phase = 90
if finite(ma) then $
  xyouts,phi(phase),theta(phase),strtrim(round(ma),2),align=.5

get_ring,magf,ra,theta,phi
oplot,phi,theta;,linestyle = 1
if finite(ra) then $
  xyouts,phi(0),theta(0),strtrim(round(ra),2),align=.5

print,'e=',e,'  ma=',ma,'  ra=',ra


return
end
