function eldf,energy,theta,phi,parameter=p


if size(p,/type) ne 8 then begin
   eflux = [2.76005e+08,1.87363e+08,1.08779e+08,5.82489e+07,2.92734e+07,4.31295e+06,1.38850e+06]
   pnrg = [7.00739,8.91540,11.8189,16.2156,22.7692,32.6411,47.4903]
   photo = {eflux:eflux,nrg:pnrg }
   core = {n:9.5d,  t:10.d, trat:1.d,   v:0.d}
   halo = {n: .5d,  t:60.d, trat:1.d,   v:0.d}
   p = {ph:photo,core:core,  halo:halo,  $
    mass:5.6856591e-06,  $   ; electron mass
    sc_pot:5.d,  $
    vsw:[-500.d,0.d,0.d], $
    magf:[-5.,5.,0.], $
    ntot:10.d,  $
    fix_scp_wght:0, $
    units:'df' }
endif

if n_params() eq 0 then return,p
if n_params() eq 1 then begin & theta=0. &  phi=0. &  end

nrg_inf  = energy - p.sc_pot 
vel = sqrt(2*(nrg_inf > 0.)/p.mass)  ;Particle velocity far from potential
sphere_to_cart,vel,theta,phi,vx,vy,vz

bdir = p.magf/sqrt(total(p.magf^2))
bx = bdir[0]
by = bdir[1]
bz = bdir[2]

nn2 = dimen1(energy)
if p.sc_pot ne 0 and p.fix_scp_wght and nn2 gt 2  then begin
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

a = 2./p.mass^2*1e5 
photo = p.ph

if keyword_set(photo.eflux[0]) then begin
   eflx2 = spl_init(alog(photo.nrg),alog(photo.eflux),/double)
   fphoto =  exp(spl_interp(alog(photo.nrg),alog(photo.eflux),eflx2,alog(energy))) /energy^2 /a
   f = f+ (1.-wght) * fphoto
endif

mass = p.mass
vsw = p.vsw
if p.core.n ne 0 then begin
  maxw = p.core
  vrel = vsw + bdir * maxw.v
  vsx = vx - vrel[0] 
  vsy = vy - vrel[1]
  vsz = vz - vrel[2]
  vtot2 = vsx*vsx + vsy*vsy + vsz*vsz
  r = maxw.trat
  if r ne 1 then begin
  cos2a = (vsx*bx + vsy*by + vsz*bz)^2/vtot2
  w = where(vtot2 eq 0,c)
  if c ne 0 then cos2a[w]= 0
  ff = (2+r)/3 + cos2a*(2-r-r^2)/3/r
  endif else ff= 1.
  e = exp( -0.5*mass / maxw.t * ff * vtot2)
  k = (mass/2/!dpi)^1.5 
  fm = (k * maxw.n / sqrt(r*(3/(2+r)*maxw.t)^3) ) * e
  f = f + wght * fm
endif

if p.halo.n ne 0 then begin
  maxw = p.halo
  vrel = vsw + bdir * maxw.v
  vsx = vx - vrel[0] 
  vsy = vy - vrel[1]
  vsz = vz - vrel[2]
  vtot2 = vsx*vsx + vsy*vsy + vsz*vsz
  r = maxw.trat
  if r ne 1 then begin
  cos2a = (vsx*bx + vsy*by + vsz*bz)^2/vtot2
  w = where(vtot2 eq 0,c)
  if c ne 0 then cos2a[w]= 0
  ff = (2+r)/3 + cos2a*(2-r-r^2)/3/r
  endif else ff= 1.
  e = exp( -0.5*mass / maxw.t * ff * vtot2)
  k = (mass/2/!dpi)^1.5 
  fm = (k * maxw.n / sqrt(r*(3/(2+r)*maxw.t)^3) ) * e
  f = f + wght * fm
endif


case strlowcase(p.units) of
'df'     :  data = f
'flux'   :  data = f * energy * a
'eflux'  :  data = f * energy^2 * a
endcase

return,data
end



