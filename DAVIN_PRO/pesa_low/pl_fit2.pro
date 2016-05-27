function pl_param2,dat
 p =    {np:10.0d, vp:[-300.d,0.d,0.d] $
         ,vpth:30.d $
        ,na:.05d, va:[-300.d,0.d,0.d] $
        ,vath:30.d  $
       }
       
if data_type(dat) eq 8 then begin
   moment_3d,dat,dens=n,veloc=v,pt3x3=pt,erange=[7,13]
   p.np = n
   p.vp = v
   p.vpth = total(pt([0,4,8]))/n
   alpha = dat
   alpha.mass = alpha.mass*4
   alpha.energy = alpha.energy *2
   moment_3d,alpha,dens=n,veloc=v,pt3x3=pt,erange=[0,6]
   p.na = n
   p.va = v
   p.vath = total(pt([0,4,8]))/n
   help,p,/st
endif

return,p

end







function pl_fit2, x,  $
    parameters=p ,set=set

if not keyword_set(p) then $
   p = pl_param2(x)

if data_type(x) eq 8 then begin
   energy = x.energy
   mass = x.mass
   units = x.units_name
   vel = velocity(energy,mass)
   sphere_to_cart,vel,x.theta,x.phi,vx,vy,vz
   gf = x.geomfactor * energy
   dt = replicate(x.integ_t/64/16,x.nenergy,x.nbins)
endif else begin
   mass = 5.6856593e-06 *1836.
   energy = .5 * mass * total(x*x,2)
   vx = x(*,0)
   vy = x(*,1)
   vz = x(*,2)
   units = 'eflux'
endelse

a = 2./mass^2/1e5

case strlowcase(units) of
'df'     :  conv = 1.
'flux'   :  conv = energy   * a
'eflux'  :  conv = energy^2 * a
'rate'   :  conv = energy * a * gf
'counts' :  conv = energy * a * gf * dt
endcase

;sphere_to_cart,1.,p.bth,p.bph,bx,by,bz


;vth = [[p.vxx,p.vxy,p.vxz],[p.vxy,p.vyy,p.vyz],[p.vxz,p.vyz,p.vzz]]
;vthi = invert(vth)

vx = (vx - p.vp(0))/p.vpth
vy = (vy - p.vp(1))/p.vpth
vz = (vz - p.vp(2))/p.vpth

;z = vall = [[vx],[vy],[vz]]
e = exp(-(vx^2 + vy^2 + vz^2))

vth = p.vpth
kv = (!dpi)^(-1.5) * vth^(-3) * 1e10
fp = conv * (kv * p.np) * e

vel = velocity(energy*2.,4.*mass)
sphere_to_cart,vel,x.theta,x.phi,vx,vy,vz
vth = p.vath
vx = (vx - p.va(0))/vth
vy = (vy - p.va(1))/vth
vz = (vz - p.va(2))/vth
e = exp(-(vx^2 + vy^2 + vz^2))
kv = (!dpi)^(-1.5) * vth^(-3) * 1e10
fa = conv / 4 * (kv * p.na) * e

f=fp+fa

if data_type(x) eq 8 and keyword_set(set) then begin
   x.data = f
   str_element,x,'bins',value = bins
   if n_elements(bins) gt 0 then begin
      ind = where(bins)
      f = f(ind)
   endif else f = reform(f,n_elements(f),/overwrite)
endif

return,f
end


