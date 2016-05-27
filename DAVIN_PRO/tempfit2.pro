

function tempfit2, x,  $
    parameters=p  ;,  p_names = p_names, pder_values= pder_values

if not keyword_set(p) then $
   p = {dens:10.0d,tperp:15.0d,tpar:15.0d, vx:0.d,vy:0.d,vz:0.d, $
        bkg_dens:1.d, bkg_temp: 1.d, $
        bth:0.,bph:0.}

if data_type(x) eq 8 then begin
   energy = x.energy
   mass = x.mass
   units = x.units_name
   vel = sqrt(2*energy/mass)
   sphere_to_cart,vel,x.theta,x.phi,vx,vy,vz
   gf = x.geomfactor
   dt = x.eff * x.integ_t
endif else begin
   mass = 5.6856593e-06
   energy = .5 * mass * total(x*x,2)
   vx = x(*,0)
   vy = x(*,1)
   vz = x(*,2)
   units = 'eflux'
endelse

k = (mass/2/!dpi)^1.5 * 1e10
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

sphere_to_cart,1.,p.bth,p.bph,bx,by,bz
bdir = [bx,by,bz]
vx = vx - p.vx
vy = vy - p.vy
vz = vz - p.vz
vtot2 = vx*vx + vy*vy + vz*vz
cosa2 = (vx*bx + vy*by + vz*bz)^2/vtot2

e = exp( -mass*vtot2*(1/p.tperp + cosa2*(1/p.tpar-1/p.tperp)) /2)

f = conv * (k * p.dens / p.tperp / sqrt(p.tpar) ) * e

bkg = conv * (k * p.bkg_dens / p.bkg_temp^1.5) * exp( - energy / p.bkg_temp)
f = f+bkg

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


