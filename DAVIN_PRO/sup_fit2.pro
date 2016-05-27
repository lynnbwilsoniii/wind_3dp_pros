
function sup_fit2, energy,detector,  parameters=p 

if not keyword_set(p) then begin
   maxw = {n:.5d,t:60d}
   kappa= {n: .10d,vh:4000.0d,k:6.0d}
   pow  = {h:.05d,p:-2.d}
;   p = {halo:maxw, suph:pow, bkg:0d, units:'flux'}
   p = {halo:kappa, suph:pow, bkg:0d, units:'flux'}
endif


if n_params() eq 0 then return,p

mass = 5.6856593e-06
;vel = sqrt(2*energy/mass)
k = (mass/2/!dpi)^1.5 
a = 2./mass^2*1e5

c = 2.9979d5      ;      Davin_units_to_eV = 8.9875e10
E0 = double(mass*c^2)
gam =  ( double(energy) + E0 ) / E0
vel = sqrt(1.0d - 1.0d/(gam*gam) ) * c ;   Velocity in km/s
v2 = vel^2

pk = p.halo
c1 = (!dpi)^(-1.5) * pk.vh^(-3) *  gamma(pk.k+1)/gamma(pk.k-.5)/pk.k^1.5
fhalo = pk.n*c1*(1+(v2/pk.k/pk.vh^2 )  ) ^(-pk.k-1)

if 0 then begin
exp1 = p.halo.t ^ (-1.5) * exp(- energy/p.halo.t)
fhalo =  p.halo.n * exp1
endif

fshalo =  p.suph.h * (energy/30000.)^ p.suph.p /energy/a

if n_elements(detector) eq 0 then detector = energy lt 28000.
bkg = p.bkg /a /energy^2 * (detector ne 0)


case strlowcase(p.units) of
'df'   :  conv = 1
'flux' :  conv = energy  * a
'eflux':  conv = energy^2 * a
else   : message,"Units not recognized!"
endcase

f = conv * (fhalo + fshalo + bkg)

return,f
end


