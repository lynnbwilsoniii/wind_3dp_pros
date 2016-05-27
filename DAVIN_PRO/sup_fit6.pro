
function sup_fit6, x,detector,  parameters=p ,type=type,  $
   correct=correct,dflux=dflux,dparameter=dp

if not keyword_set(p) then begin
    est = [.67,1.,1.33,1.67,2., 2.33, 2.67, 3.0, 3.4,  4.33, 4.67, 5.0, 5.33, 5.67]
    energy =  keyword_set(x) ? float(x) : 10.^est
    flux = keyword_set(detector) ? detector : 1e10/energy^3
    el = {eff: 1.d, bkgr:3000.d}
    eh = {eff: 1.d, bkgr:150.d}
    sf = {eff: 1.d, bkgr: 0.d }
    maxw = {n:0d,t:10d}
    kappa= {n: .0d,vh:4000.0d,k:6.0d}
    pow  = {h:.0d,p:-2.d}
    p = {func:'sup_fit6', $
         el:el,  eh:eh, sf:sf, $
         core:maxw, $
         halo:kappa, $
         suph:pow, $
         spl:splfunc(energy,flux,/xlog,/ylog), $
         type:keyword_set(type), $
         units:'df'} 
    return,p
endif

if data_type(x) eq 8 then begin
   energy = x.e
   detector = x.det
   effs = [p.el.eff,p.eh.eff,p.sf.eff]   
   eff = effs[detector]
   gf = x.gf * eff
   bkgrs = [p.el.bkgr,p.eh.bkgr,p.sf.bkgr]
   bkgr = bkgrs[detector] 
   dt = x.dt
endif else begin
   energy = x
   eff = 1d
   bkgr = 0d
endelse

mass = 5.6856593e-06
a = 2./mass^2*1e5

if p.type then  begin
  k = (mass/2/!dpi)^1.5 

  c = 2.9979d5      ;      Davin_units_to_eV = 8.9875e10
  E0 = double(mass*c^2)
  gam =  ( double(energy) + E0 ) / E0
  vel = sqrt(1.0d - 1.0d/(gam*gam) ) * c ;   Velocity in km/s
  v2 = vel^2

  pm = p.core
  exp1 = pm.t ^ (-1.5) * exp(- energy/pm.t)
  fcore =  k * pm.n * exp1
  
  pk = p.halo
  c1 = (!dpi)^(-1.5) * pk.vh^(-3) *  gamma(pk.k+1)/gamma(pk.k-.5)/pk.k^1.5
  fhalo = pk.n*c1*(1+(v2/pk.k/pk.vh^2 )  ) ^(-pk.k-1)
  
  pp = p.suph
  fshalo =  pp.h * (energy/30000.)^ pp.p /energy/a
  
  df = fcore+fhalo+fshalo
;  flux = df*energy*a
  
;endif else flux =  splfunc(energy,param=p.spl) 
endif else df =  splfunc(energy,param=p.spl) 

case strlowcase(p.units) of
'df'   :  f = df 
'flux' :  f = df * energy * a
'eflux':  f = df * energy^2 *a
'rate' :  f = df * energy * a * gf + bkgr
'counts': f = (df * energy * a * gf + bkgr) * dt
else   : message,"Units not recognized!"
endcase

if 0 then begin
case strlowcase(p.units) of
'df'   :  f = flux / (energy * a)
'flux' :  f = flux
'eflux':  f = flux * energy
'rate' :  f = flux * gf + bkgr
'counts': f = (flux * gf + bkgr) * dt
else   : message,"Units not recognized!"
endcase
endif


return,f
end


