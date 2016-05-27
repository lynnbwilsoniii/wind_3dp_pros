function mom2fit,mom,fit_format=fit_f

mass = 5.6856591e-06
magf = mom.magf
bhat = magf/sqrt(total(magf*magf))

if keyword_set(fit_f) then fit=fit_f else fit=fitel3d()

fit.sc_pot = mom.sc_pot
fit.halo.n = 0
fit.core.n = mom.density
fit.core.v = 0
fit.vsw = mom.flux/mom.density / 1e5
fit.core.tdif = 0
t3 = mom.magt3

t_par = t3[2]
t_perp = average(t3[0:1])
fit.core.t = t_perp
fit.core.tdif = t_perp/t_par - 1


return,fit

end
