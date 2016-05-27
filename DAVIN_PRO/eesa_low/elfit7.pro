function far_theta,theta,e_pot,alpha
rad = !dpi/180.d

st2 = sin(theta*rad)
sg = (st2 gt 0) * 2 -1
st2 = st2^2
e = sqrt(1+4.d*e_pot*(e_pot-1)*st2)
th0 = acos(-1/e) - acos( (2*e_pot*st2-1)/e )
return,th0/rad*sg
end


function el_response,volts,energy,denergy,nsteps=nsteps

common el_response_com,resp0,volts0,energy0,denergy0,nsteps0

if keyword_set(nsteps0) then begin
  if nsteps eq nsteps0 and total(volts ne volts0) eq 0 then begin
     energy=energy0
     denergy=denergy0
     return,resp0
  endif
endif
message,/info,'Computing instrument response.'

volts0=volts

w = where(volts lt 0,nw)
if nw ne 0 then begin
  volts[w] = max(volts)
  page,'Voltage correction'
endif

k_an = 6.42
;fwhm = .1
fwhm = .22

if keyword_set(nsteps) then begin
  erange = k_an*minmax(volts)*[1-fwhm,1+fwhm]^2
  energy = dgen(nsteps,/log,range=erange)
  i = lindgen(nsteps)
  denergy = abs(energy[i+1]-energy[i-1])/2
endif

nn = n_elements(energy)
nv = n_elements(volts)

dim = dimen(volts)
es = replicate(1.,nv) # energy
kvs = reform(k_an*volts,nv) # replicate(1.,nn) 
sigma = fwhm/(2*sqrt(2*alog(2))) * kvs
resp = exp( -((es-kvs)/sigma)^2 /2) / sqrt(2*!pi) / sigma
resp = resp * (replicate(1.,nv) # denergy)

if ndimen(volts) eq 2 then begin
  resp = reform(resp,dim[0],dim[1],nn)
  resp = total(resp,1)/dim[0]
endif

resp0=resp
energy0=energy
denergy0=denergy
nsteps0=nsteps

;plot,energy,resp(14,*),/xl
;for i=0,dimen1(resp)-1 do oplot,energy,resp(i,*)
return,resp
end





function el_df,energy,theta,phi,parameters=p

mass=5.6856591e-06
nrg_inf  = energy-p.sc_pot 
vel = sqrt(2*(nrg_inf > 0.01)/mass)  ;Particle velocity far from potential
;theta = far_theta(theta,energy/p.sc_pot)
sphere_to_cart,vel,theta,phi,vx,vy,vz
magf = p.magf
bdir = magf/sqrt(total(magf^2))
bx = bdir[0]
by = bdir[1]
bz = bdir[2]

vsw  = p.vsw

nn2 = dimen1(energy)
if nn2 gt 2 then begin
  if ndimen(energy) ge 2 then begin
    e0 = shift(energy,1,0)  & e0[0,*] = e0[1,*]
    e2 = shift(energy,-1,0) & e2[nn2-1,*] = e2[nn2-2,*]
  endif else begin
    e0 = shift(energy,1)  & e0[0] = e0[1]
    e2 = shift(energy,-1) & e2[nn2-1] = e2[nn2-2]
  endelse
  de = abs(e2-e0)
  wght =  0. > (energy+e0-2.*p.sc_pot)/de < 1.
endif else wght = energy gt p.sc_pot

f = 0.

a = 2./mass^2/1e5 
photo = p.ph

if keyword_set(photo.eflux[0]) then begin
   eflx2 = spl_init(alog(photo.nrg),alog(photo.eflux),/double)
   fphoto =  exp(spl_interp(alog(photo.nrg),alog(photo.eflux),eflx2,alog(energy))) /energy^2 /a
   f = f+ (1.-wght) * fphoto
endif

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
  f= f+ wght * fcore
endif

if p.halo.n ne 0 then begin
  vhalo = vsw + bdir *p.halo.v
  vsx = vx - vhalo(0)
  vsy = vy - vhalo(1)
  vsz = vz - vhalo(2)
  vtot2 = vsx*vsx + vsy*vsy + vsz*vsz
  cos2a = (vsx*bx + vsy*by + vsz*bz)^2/vtot2
  vh2 = (p.halo.k-1.5)*p.halo.vth^2
  kc = (!dpi*vh2)^(-1.5) *  gamma(p.halo.k+1)/gamma(p.halo.k-.5) *1e10
  fhalo = p.halo.n*kc*(1+(vtot2/vh2))^(-p.halo.k-1) 
  f = f+ wght*fhalo
endif

return,f
end




; .r elfit7

function elfit7, x,  $
    set=set, $
    type = type, $
    parameters=p 

;k_an = 6.42


if not keyword_set(p) then begin
 ;; eflux = [2.76005e+08,1.87363e+08,1.08779e+08,5.82489e+07,2.92734e+07,4.31295e+06,1.38850e+06]
 ;; pnrg = [7.00739,8.91540,11.8189,16.2156,22.7692,32.6411,47.4903]
   pnrg =  [5.18234, 5.92896, 7.25627, 9.41315, 12.8144, 18.2895, 27.2489, 41.7663, 65.2431, 103.320, 164.957, 264.837, 426.769, 689.161, 1112.99]
   eflux = [3.39420e+08, 2.77170e+08, 2.05402e+08, 1.49702e+08, 9.07756e+07, 3.88106e+07, 2.41517e+07, 1.01327e+07, 2.40907e+06, 400220., 368695., 271865., 145748., 59322.0, 26367.6]
   photo = {eflux:eflux,nrg:pnrg }
   core = {n:10.d,  t:10.d, tdif:0.d,  v:0.d}
   halo = {n:.1d,  vth:5000.d, k:4.3d,  v:0.d}
   p13 = {ph:photo,core:core,  halo:halo,  $
    e_shift:0.d, v_shift:0.31d, sc_pot:5.d, vsw:[500.d,0.d,0.d], $
    magf:[0.,0.,1.], $
    ntot:10.d,  $
    dflag:0, $
;    fflag:0l, $
;    erange:[0.,2000.], $
    deadtime:0.6d-6,expand:8  }
   p=p13
endif

if p.dflag then p.core.n = p.ntot-p.halo.n else p.ntot=p.core.n+p.halo.n

if data_type(x) ne 8  then begin
;   Set limits:
if 0 then begin
  p.sc_pot   =  1.    > p.sc_pot    < 50.
  p.ntot     = .05    > p.ntot    < 200
  p.core.n   = .05    > p.core.n    < 200
  p.core.t   = 0.5    > p.core.t    < 50
  p.core.tdif= -.6    > p.core.tdif < .3
  p.core.v   = -500   > p.core.v    < 500
  p.halo.n   = 0.00    > p.halo.n    < 1
  p.halo.vth = 2000   > abs(p.halo.vth)  < 6000
  p.halo.v   = -5000  > p.halo.v    < 5000
  p.halo.k   = 3      > p.halo.k    < 5
  p.vsw  = [-900.,-200.,-200.] > p.vsw < [200.,200.,200.]
endif
  return,0
endif

;energy = x.energy + p.E_shift    ;  True energy, accounting for HV offset
theta = x.theta
phi = x.phi

;p.ph.nrg = (reverse(k_an*average(x.volts,1)))[0:6]

if keyword_set(p.expand) then expand=16
str_element,x,'volts',volts
if not keyword_set(volts) then expand=0


if keyword_set(expand) then begin
;  nrg2 = (x.volts + p.v_shift) * k_an
  nn = x.nenergy
  resp = el_response(x.volts+p.v_shift,nrg2,nsteps=expand*nn)
;p.ph.nrg = (reverse(average(nrg2,1)))[0:6]

  nb = x.nbins
  i = replicate(1.,expand)
  nn2 = nn*expand
  energy = nrg2[*] # replicate(1.,nb)
  phi = reform(i # phi[*],nn2,nb)
  theta = reform(i # theta[*],nn2,nb)
  esteps = resp # nrg2
endif


mass = x.mass

a = 2./mass^2/1e5

f= el_df(energy,theta,phi,param=p)

eflux = f* energy^2 * a

if keyword_set(expand) then begin
  eflux  = resp # eflux
  energy = resp # energy
  theta  = resp # theta
  phi    = resp # phi
endif


units = x.units_name

case strlowcase(units) of
'df'     :  data = eflux/energy^2/a
'flux'   :  data = eflux/energy
'eflux'  :  data = eflux
else     : begin
    crate =  x.geomfactor *x.gf * eflux
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
  x.energy = energy
  x.e_shift = p.e_shift
  str_element,/add,x,'sc_pot',p.sc_pot    ;  x.sc_pot = p.sc_pot
  x.vsw = p.vsw
  x.magf = p.magf
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


