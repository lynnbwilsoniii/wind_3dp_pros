function pl_param,dat
 p =    {np:10.0d, vpx:-300.d,vpy:0.d,vpz:0.d $
         ,vpth:30.d $
        ,na:.05d, vax:-300.d,vay:0.d,vaz:0.d $
        ,vath:30.d  $
;        , vxx:30.d,vyy:0.d,vzz:0.d,vxy:0.d,vxz:0.d,vyz:0.d $
;        ,tperp:15.0d,tpar:15.0d  $
       }
       
if data_type(dat) eq 8 then begin
   moment_3d,dat,dens=n,veloc=v,pt3x3=pt
   p.np = n
   p.vpx = v(0)
   p.vpy = v(1)
   p.vpz = v(2)
   p.tpth = total(pt([0,4,8]))/n
   help,p,/st
endif

return,p

end







function pl_fit1, x,  $
    parameters=p  ;,  p_names = p_names, pder_values= pder_values

if not keyword_set(p) then $
   p = pl_param(x)

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

vx = (vx - p.vpx)/p.vpth
vy = (vy - p.vpy)/p.vpth
vz = (vz - p.vpz)/p.vpth

;z = vall = [[vx],[vy],[vz]]
e = exp(-(vx^2 + vy^2 + vz^2))

vth = p.vpth
kv = (!dpi)^(-1.5) * vth^(-3) * 1e10
fp = conv * (kv * p.np) * e

vel = velocity(energy*2.,4.*mass)
sphere_to_cart,vel,x.theta,x.phi,vx,vy,vz
vth = p.vath
vx = (vx - p.vax)/vth
vy = (vy - p.vay)/vth
vz = (vz - p.vaz)/vth
e = exp(-(vx^2 + vy^2 + vz^2))
kv = (!dpi)^(-1.5) * vth^(-3) * 1e10
fa = conv / 4 * (kv * p.na) * e

f=fp+fa

if data_type(x) eq 8 then begin
   x.data = f
   str_element,x,'bins',value = bins
   if n_elements(bins) gt 0 then begin
      ind = where(bins)
      f = f(ind)
   endif else f = reform(f,n_elements(f),/overwrite)
endif

return,f
end


