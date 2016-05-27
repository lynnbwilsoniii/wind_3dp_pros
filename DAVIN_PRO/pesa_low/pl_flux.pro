
function pl_flux, energy_q , theta ,phi, par = p,  data = dat

mass = .010438871*p.m

vel = velocity(energy_q * p.q,mass)
sphere_to_cart,vel,theta,phi,vx,vy,vz

vpth = p.vth
vpx = (vx - p.v(0))/vpth
vpy = (vy - p.v(1))/vpth
vpz = (vz - p.v(2))/vpth

e = exp(-(vpx^2 + vpy^2 + vpz^2))
kv = (!dpi)^(-1.5) * vpth^(-3)
fp = (kv * p.n) * e

flux = 1e5 * 2./mass^2 * p.q * energy_q * fp

return,flux
end



