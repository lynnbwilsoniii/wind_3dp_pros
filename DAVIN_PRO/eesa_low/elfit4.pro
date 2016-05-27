function far_theta,theta,e_pot,alpha
rad = !dpi/180.d

st2 = sin(theta*rad)
sg = (st2 gt 0) * 2 -1
st2 = st2^2
e = sqrt(1+4.d*e_pot*(e_pot-1)*st2)
th0 = acos(-1/e) - acos( (2*e_pot*st2-1)/e )
return,th0/rad*sg
end



; .r elfit4

function elfit4, x,  $
    set=set, $
    type = type, $
    parameters=p 

if not keyword_set(p) then begin
;   photo = {norm:1.d }
   core = {dist1,n:10.d,  t:10.d, tdif:0.d,  v:0.d}
   halo1 = {dist1,n:.1d,  t:100.d, tdif:0.d,  v:0.d}
   halo2 = {dist2,n:.1d,  vth:5000.d, k:4.3d,  v:0.d}
   p11 = {elfit11,core:core,  halo:halo1,  e_shift:0.d, sc_pot:5.d, vsw:[500.d,0.d,0.d],deadtime:0.d  }
   p12 = {elfit12,core:core,  halo:halo2,  e_shift:0.d, sc_pot:5.d, vsw:[500.d,0.d,0.d],deadtime:0.d  }
   if keyword_set(type) then p=p11 else p=p12
endif

if data_type(x) ne 8 then begin
   return,0
endif

energy = x.energy + p.E_shift    ;  True energy, accounting for HV offset
mass = x.mass
units = x.units_name
nrg_inf  = (energy-p.sc_pot) 
vel = sqrt(2*(energy-p.sc_pot)/mass)  ;Particle velocity far from potential
theta = x.theta
;theta = far_theta(x.theta,energy/p.sc_pot)
sphere_to_cart,vel,theta,x.phi,vx,vy,vz
magf =x.magf
bdir = magf/sqrt(total(magf^2))
bx = bdir(0)
by = bdir(1)
bz = bdir(2)

vsw  = x.vsw   ; mod
vsw  = p.vsw
f = 0

;sphere_to_cart,1.,bth,bph,bx,by,bz
;bdir = [bx,by,bz]

;str_element,p,'photo',photo
;if keyword_set(photo) then begin
;   k = (mass/2/!dpi)^1.5 * 1e10
;   e = exp(- energy / photo.t  )
;   fphoto =  (k * photo.n / photo.t^3) * e
;   w = where(energy ge p.sc_pot or energy le 0.,c)
;   if c ne 0 then fphoto(w)=0
;   f = f+ fphoto
;endif

if p.core.n ne 0 then begin
  vcore = vsw + bdir * p.core.v
  vsx = vx - vcore[0] 
  vsy = vy - vcore[1]
  vsz = vz - vcore[2]
  vtot2 = vsx*vsx + vsy*vsy + vsz*vsz
  cos2a = (vsx*bx + vsy*by + vsz*bz)^2/vtot2

  e = exp( -0.5*mass*vtot2 / p.core.t * (1.d + cos2a*p.core.tdif) )
  k = (mass/2/!dpi)^1.5 * 1e10

  fcore = (k * p.core.n * sqrt((1+p.core.tdif)/p.core.t^3) ) * e
  w = where(energy le p.sc_pot or energy le 0.,c)
  if c ne 0 then fcore[w]=0.
  f= f+fcore
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
     fhalo = p.halo.n*kc*(1+(vtot2/vh2))^(-p.halo.k-1) 
  endif else begin
     e = exp( -0.5*mass*vtot2 / p.halo.t * (1.d + cos2a*p.halo.tdif) )
     k = (mass/2/!dpi)^1.5 * 1e10
     fhalo = (k * p.halo.n * sqrt((1+p.halo.tdif)/p.halo.t^3) ) * e
  endelse
  w = where(energy le p.sc_pot or energy le 0.,c)
  if c ne 0 then fhalo(w)=0
  f = f+fhalo

endif

a = 2./mass^2/1e5




case strlowcase(units) of
'df'     :  data = f
'flux'   :  data = f* energy   * a
'eflux'  :  data = f* energy^2 * a
else     : begin
    crate = a * x.geomfactor *x.gf * energy^2 * f
    anode = byte((90 - x.theta)/22.5)
    deadtime = (p.deadtime/[1.,1.,2.,4.,4.,2.,1.,1.])(anode)
    rate = crate/(1+ deadtime *crate)
    bkgrate = 0
    str_element,p,'bkgrate',bkgrate
    rate = rate + bkgrate
    case strlowcase(units) of
       'crate'  :  data = crate
       'rate'   :  data = rate
       'counts' :  data = rate * x.dt
    endcase
    end
endcase



if keyword_set(set) then begin
  x.data = data
  x.e_shift = p.e_shift
  x.sc_pot = p.sc_pot
  x.vsw = p.vsw
  str_element,/add,x,'deadtime', deadtime
endif

str_element,x,'bins',value = bins
if n_elements(bins) gt 0 then begin
   ind = where(bins)
   data = data(ind)
endif else data = reform(data,n_elements(data),/overwrite)
if keyword_set(set) and keyword_set(bins) then begin
   w = where(bins eq 0,c)
   if (c ne 0)  and (set eq 2) then x.data(w) = !values.f_nan
endif

return,data
end


