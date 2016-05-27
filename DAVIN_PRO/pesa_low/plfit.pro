

function plfit, x,  $
    set=set, $
    parameters=p  

if data_type(p) ne 8 then $
   p = {p_dens:8.0d, p_vel:[500.d,0.d,0.d], p_vth,50.d, p_vrat:1.d, $
        a_dens:8.0d, a_vel:[500.d,0.d,0.d], a_vth,50.d, a_vrat:1.d  $
       }

if data_type(x) ne 8 then begin
   message,'Input must be a structure!',/info
   return,0
endif

energy = x.energy + p.E_shift    ;  True energy, accounting for HV offset
mass = x.mass
units = x.units_name
vel = sqrt(2*(energy-p.sc_pot)/mass)  ;Particle velocity far from potential
sphere_to_cart,vel,x.theta,x.phi,vx,vy,vz
gf = x.geomfactor
dt = x.eff * x.integ_t
magf =x.magf
bdir = magf/sqrt(total(magf^2))
bx = bdir(0)
by = bdir(1)
bz = bdir(2)

vsw  = x.vsw
f = 0

;sphere_to_cart,1.,bth,bph,bx,by,bz
;bdir = [bx,by,bz]

if p.dens_core ne 0 then begin
  vcore = vsw + bdir * p.vel_core
  vsx = vx - vcore(0) 
  vsy = vy - vcore(1)
  vsz = vz - vcore(2)
  vtot2 = vsx*vsx + vsy*vsy + vsz*vsz
  cos2a = (vsx*bx + vsy*by + vsz*bz)^2/vtot2

  e = exp( -0.5*mass*vtot2 / p.temp_core * (1.d + cos2a*p.tdif_core) )
  k = (mass/2/!dpi)^1.5 * 1e10

  f = f + (k * p.dens_core * sqrt((1+p.tdif_core)/p.temp_core^3) ) * e
endif

if p.dens_halo ne 0 then begin
  vhalo = vsw + bdir *p.vel_halo
  vsx = vx - vhalo(0)
  vsy = vy - vhalo(0)
  vsz = vz - vhalo(0)
  vtot2 = vsx*vsx + vsy*vsy + vsz*vsz
  vh2 = (p.k_halo-1.5)*p.vth_halo^2
  kc = (!dpi*vh2)^(-1.5) *  factorial(p.k_halo)/gamma(p.k_halo-.5) *1e10
  kf = p.dens_halo*kc*(1+(vtot2/vh2))^(-p.k_halo-1) 
  f = f+kf
endif

a = 2./mass^2/1e5
case strlowcase(units) of
'df'     :  conv = 1.
'flux'   :  conv = energy   * a
'eflux'  :  conv = energy^2 * a
'nrate'  :  conv = energy^2 * a * gf
'rate'   :  conv = energy^2 * a * gf * (replicate(1.,x.nenergy) # x.geom)
'ncounts':  conv = energy^2 * a * gf * (dt # replicate(1.,x.nbins))
'counts' :  conv = energy^2 * a * gf * (dt # x.geom)
endcase

f = conv * f


if keyword_set(set) then  x.data = f

str_element,x,'bins',value = bins
if n_elements(bins) gt 0 then begin
   ind = where(bins)
   f = f(ind)
endif else f = reform(f,n_elements(f),/overwrite)
if keyword_set(set) and keyword_set(bins) then begin
   w = where(bins eq 0,c)
   if c ne 0 then x.data(w) = !values.f_nan
endif

return,f
end


