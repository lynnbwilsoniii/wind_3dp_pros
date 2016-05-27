

function kappa, vel,  $
    parameters=p ,units=units

if not keyword_set(p) then $
   p = {func:'kappa',n:10.0d,vh:2000.0d,k:6.0d}

if n_params() eq 0 then return,0

mass = 5.6856593e-06
a = 2./mass^2*1e5

vh2 = (p.k-1.5)*p.vh^2
c = (!dpi*vh2)^(-1.5) *  gamma(p.k+1)/gamma(p.k-.5)

;energy = .5 * mass * total(vel*vel,2)
energy = .5 * mass * vel*vel

units = 'eflux'
case units of
'df'   :  conv = c
'flux' :  conv = c * a * energy
'eflux':  conv = c * a * energy^2
endcase

v2 = vel^2

f = p.n*conv*(1+(v2/vh2))^(-p.k-1)


return,f
end


