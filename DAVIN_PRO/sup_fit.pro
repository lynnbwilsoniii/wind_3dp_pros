
function sup_fit, energy,  $
    parameters=p , mean_nrg=em

if not keyword_set(p) then $
   p = {sup_param,n1:10.0d,vh1:1500.0d,k1:6.0d, $
        n2: .10d,vh2:4000.0d,k2:6.0d, $
        n3: 1d-7,vh3:40000.0d,k3:6.0d , units:'df'}

if n_params() eq 0 then return,0

mass = 5.6856593e-06
vel = sqrt(2*energy/mass)

;c = 2.9979d5      ;      Davin_units_to_eV = 8.9875e10
;E0 = double(mass*c^2)
;gam =  ( double(energy) + E0 ) / E0
;vel = sqrt(1.0d - 1.0d/(gam*gam) ) * c ;   Velocity in km/s


case strlowcase(p.units) of
'df'   :  conv = 1
'flux' :  conv = energy  * 2./mass^2*1e5
'eflux':  conv = energy^2 * 2./mass^2*1e5
else   : message,"Units not recognized!"
endcase

v2 = vel^2

c1 = (!dpi)^(-1.5) * p.vh1^(-3) *  gamma(p.k1+1)/gamma(p.k1-.5)/p.k1^1.5
f1 = p.n1*c1*(1+(v2/p.k1/p.vh1^2 )  ) ^(-p.k1-1)

c2 = (!dpi)^(-1.5) * p.vh2^(-3) *  gamma(p.k2+1)/gamma(p.k2-.5)/p.k2^1.5
f2 = p.n2*c2*(1+(v2/p.k2/p.vh2^2 )  ) ^(-p.k2-1)

c3 = (!dpi)^(-1.5) * p.vh3^(-3) *  gamma(p.k3+1)/gamma(p.k3-.5)/p.k3^1.5
f3 = p.n3*c3*(1+(v2/p.k3/p.vh3^2 )  ) ^(-p.k3-1)

f = conv*(f1+f2+f3)

em={em1:0. , em2:0. , em3:0.}
em.em1=(p.k1*2/(2*p.k1-3))*.5*mass*p.vh1^2
em.em2=(p.k2*2/(2*p.k2-3))*.5*mass*p.vh2^2
em.em3=(p.k3*2/(2*p.k3-3))*.5*mass*p.vh3^2


return,f
end


