function fit2mom,fit,moment_format=mom_f,core_only=core_only

if keyword_set(mom_f) then mom=mom_f else mom = moments_3d()

mass = 5.6856591e-06
magf = mom.magf
bhat = magf/sqrt(total(magf*magf))

mom.sc_pot = fit.sc_pot
halo_n = keyword_set(core_only) ? 0. : fit.halo.n
mom.density = fit.core.n + halo_n
vcore = fit.vsw + bhat * fit.core.v
vhalo = fit.vsw + bhat * fit.halo.v
mom.flux = (fit.core.n*vcore + halo_n*vhalo)*1e5
mom.velocity = (fit.core.n*vcore + halo_n*vhalo)/mom.density
tpar = fit.core.t/(1+fit.core.tdif)
tperp = fit.core.t

rot = rot_mat(magf,mom.flux)
map3x3 = [[0,3,4],[3,1,5],[4,5,2]]
mapt   = [0,4,8,1,2,5]

mom.magt3 = [tperp,tperp,tpar]
magt3x3 =  ([mom.magt3,0,0,0])[map3x3]
t3x3 = rot # (magt3x3 # invert(rot))
pt3x3 = mom.density * t3x3
mf3x3 = pt3x3 + (mom.velocity # mom.flux) * mass /1e5
mom.mftens = mf3x3[mapt]
mom.ptens  = pt3x3[mapt]
mom = moments_3d(format=mom) ;,/nodata

return,mom
end
