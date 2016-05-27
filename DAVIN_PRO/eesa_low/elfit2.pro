function far_theta,theta,e_pot,alpha
rad = !dpi/180.d

st2 = sin(theta*rad)
sg = (st2 gt 0) * 2 -1
st2 = st2^2
e = sqrt(1+4.d*e_pot*(e_pot-1)*st2)
th0 = acos(-1/e) - acos( (2*e_pot*st2-1)/e )
return,th0/rad*sg
end

; .r elfit2

function elfit2, x,  $
    set=set, $
    type = type, $
    parameters=p 

if not keyword_set(p) then begin
   core = {dist1,n:10.d,  t:10.d, tdif:0.d,  v:0.d}
   halo1 = {dist1,n:.1d,  t:100.d, tdif:0.d,  v:0.d}
   halo2 = {dist2,n:.1d,  vth:5000.d, k:4.3d,  v:0.d}
   p11 = {elfit11,core:core,  halo:halo1,  e_shift:0.d, sc_pot:5.d  }
   p12 = {elfit12,core:core,  halo:halo2,  e_shift:0.d, sc_pot:5.d  }
   if keyword_set(type) then p=p11 else p=p12
endif

if data_type(x) ne 8 then begin
   return,0
endif

energy = x.energy + p.E_shift    ;  True energy, accounting for HV offset
mass = x.mass
units = x.units_name
vel = sqrt(2*(energy-p.sc_pot)/mass)  ;Particle velocity far from potential
theta = x.theta
;theta = far_theta(x.theta,energy/p.sc_pot)
sphere_to_cart,vel,theta,x.phi,vx,vy,vz
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

if p.core.n ne 0 then begin
  vcore = vsw + bdir * p.core.v
  vsx = vx - vcore(0) 
  vsy = vy - vcore(1)
  vsz = vz - vcore(2)
  vtot2 = vsx*vsx + vsy*vsy + vsz*vsz
  cos2a = (vsx*bx + vsy*by + vsz*bz)^2/vtot2

  e = exp( -0.5*mass*vtot2 / p.core.t * (1.d + cos2a*p.core.tdif) )
  k = (mass/2/!dpi)^1.5 * 1e10

  f = f + (k * p.core.n * sqrt((1+p.core.tdif)/p.core.t^3) ) * e
endif

if p.halo.n ne 0 then begin
  vhalo = vsw + bdir *p.halo.v
  vsx = vx - vhalo(0)
  vsy = vy - vhalo(1)
  vsz = vz - vhalo(2)
  vtot2 = vsx*vsx + vsy*vsy + vsz*vsz
  cos2a = (vsx*bx + vsy*by + vsz*bz)^2/vtot2
  if tag_names(/str,p.halo) eq 'DIST2' then begin
     vh2 = (p.halo.k-1.5)*p.halo.vth^2
     kc = (!dpi*vh2)^(-1.5) *  gamma(p.halo.k+1)/gamma(p.halo.k-.5) *1e10
     kf = p.halo.n*kc*(1+(vtot2/vh2))^(-p.halo.k-1) 
     f = f+kf
  endif else begin
     e = exp( -0.5*mass*vtot2 / p.halo.t * (1.d + cos2a*p.halo.tdif) )
     k = (mass/2/!dpi)^1.5 * 1e10
     f = f + (k * p.halo.n * sqrt((1+p.halo.tdif)/p.halo.t^3) ) * e
  endelse
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
   if (c ne 0)  and (set eq 2) then x.data(w) = !values.f_nan
endif

return,f
end


