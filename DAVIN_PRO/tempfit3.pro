

function tempfit3, x,  $
    parameters=p  ;,  p_names = p_names, pder_values= pder_values

if not keyword_set(p) then $
   p = {dens:8.0d,temp:10.0d,tdif:0.0d, vx:0.d,vy:0.d,vz:0.d, $
        k_dens: 0.0d,  k_vh: 5000.0d,  k_k:6.0d,k_vx:0.d,k_vy:0.d,k_vz:0.d, $
        E_shift:0.d,sc_pot:0.d $
;        bkg_dens:1.d, bkg_temp: 1.d, $
;        bth:0.d,bph:0.d  $
       }

if data_type(x) eq 8 then begin
   energy = x.energy + p.E_shift    ;  True energy, accounting for HV offset
   mass = x.mass
   units = x.units_name
   vel = sqrt(2*(energy-p.sc_pot)/mass)  ;Particle velocity far from potential
   sphere_to_cart,vel,x.theta,x.phi,vx,vy,vz
   gf = x.geomfactor
   dt = x.eff * x.integ_t
   str_element,x,'magf',value=magf
   if n_elements(magf) eq 3 then xyz_to_polar,magf,theta=bth,phi=bph
endif else begin
   mass = 5.6856593e-06
   energy = .5 * mass * total(x*x,2)
   vx = x(*,0)
   vy = x(*,1)
   vz = x(*,2)
   units = 'eflux'
   bth = 0
   bph = 0
endelse

f = 0

sphere_to_cart,1.,bth,bph,bx,by,bz
;bdir = [bx,by,bz]

if p.dens ne 0 then begin
  vsx = vx - p.vx
  vsy = vy - p.vy
  vsz = vz - p.vz
  vtot2 = vsx*vsx + vsy*vsy + vsz*vsz
  cos2a = (vsx*bx + vsy*by + vsz*bz)^2/vtot2

  e = exp( -0.5*mass*vtot2 / p.temp * (1.d + cos2a*p.tdif) )
  k = (mass/2/!dpi)^1.5 * 1e10

  f = f + (k * p.dens * sqrt((1+p.tdif)/p.temp^3) ) * e
endif

if p.k_dens ne 0 then begin
  vsx = vx - p.k_vx
  vsy = vy - p.k_vy
  vsz = vz - p.k_vz
  vtot2 = vsx*vsx + vsy*vsy + vsz*vsz
  vh2 = (p.k_k-1.5)*p.k_vh^2
  kc = (!dpi*vh2)^(-1.5) *  factorial(p.k_k)/gamma(p.k_k-.5) *1e10
  kf = p.k_dens*kc*(1+(vtot2/vh2))^(-p.k_k-1) 
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


