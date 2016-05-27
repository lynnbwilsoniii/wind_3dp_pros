function elfit2sum,fit,moment_format=mom_f,core_only=core_only 

if keyword_set(mom_f) then sum=mom_f else sum = mom_sum()

mass = 5.6856591e-06
charge = -1
norm = sqrt(abs(2*charge/mass))  ; km/s/eV^.5

sum.magf = fit.magf
sum.charge = charge
sum.mass = mass
sum.sc_pot = fit.sc_pot

rot = rot_mat(fit.magf)

csum = sum
csum.n = fit.core.n * norm
csum.nv = 0
tpar = fit.core.t/(1+fit.core.tdif)
tperp = fit.core.t
csum.nvv = [tperp,tperp,tpar,0,0,0] * fit.core.n/mass /norm  
csum.nvvv = 0
csum.nvvvv = 0
csum.nvvvv = [3*tpar*tpar,3*tperp*tperp,3*tperp*tperp,tperp*tperp,tpar*tperp,tpar*tperp] $
    *fit.core.n/mass^2/norm^3
core_shift = [0,0,1]*fit.core.v
csum = mom_translate(csum,core_shift/norm)

hsum = sum
halo_n = keyword_set(core_only) ? 0. : fit.halo.n
hsum.n = halo_n
hsum.nv = 0
thalo = .5*mass*fit.halo.vth^2
hsum.nvv = [thalo,thalo,thalo,0,0,0] * halo_n/mass /norm 
hsum.nvvv =  0. 
hsum.nvvvv = keyword_set(core_only) ? 0. : !values.f_nan
halo_shift = [0,0,1]*fit.halo.v
hsum = mom_translate(hsum,halo_shift/norm)

sum.n = csum.n + hsum.n
sum.nv = csum.nv + hsum.nv
sum.nvv = csum.nvv + hsum.nvv
sum.nvvv = csum.nvvv + hsum.nvvv
sum.nvvvv = csum.nvvvv + hsum.nvvvv

sum = mom_rotate(sum,transpose(rot))

sum = mom_translate(sum,fit.vsw/norm)

return,sum
end
