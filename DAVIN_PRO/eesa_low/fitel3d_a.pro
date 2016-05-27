function fitel3d_a,dat,options=opts,guess=fit,fdat=fdat,chi2=chi2,xchi=chi $
  ,true_dens = np
  
pot = sc_pot(np)
;em = moments_3d(dat,format=em,true_dens=np)
fit.core.v =0
fit.core.n = np - fit.halo.n
fit.sc_pot =  0 > fit.sc_pot < 9

;fex = np lt 4 ? 'core.n ' : ''
fex =  ''
  
fitnames = fex+'sc_pot core.t core.tdif core.n vsw halo'

opts.names = fitnames

fit = fitel3d(dat,options=opts,guess=fit,fdat=fdat,chi2=chi2,xchi=chi)
  
if chi2 gt 30. then chi2 = !values.f_nan
if finite(chi2) eq 0 then begin
;     fit.sc_pot = em.sc_pot
     fit.core.n = np
     fit.vsw = dat.vsw
     fit.core.t = .5 > fit.core.t < 20.
     fit.core.v = -50 > fit.core.v < 30
     fit.core.tdif = -.05
     fit.halo.n = .1 > fit.halo.n < 2
     fit.halo.k = 3 > fit.halo.k < 8
     fit.halo.vth = 1000 > fit.halo.vth < 5000
     fit.halo.v = -fit.halo.vth/10 > fit.halo.v < fit.halo.vth/10
     
;     opts.emin = 0  & opts.emax=(fit.core.t*2.5+fit.sc_pot > 15)
     opts.emin = 0  & opts.emax= 15
     opts.names='core.t sc_pot'
     fit = fitel3d(dat,options=opts,guess=fit,fdat=fdat,chi2=chi2)

     opts.emin = 60.  & opts.emax=3000.  & opts.names='halo.n halo.vth'     
     fit = fitel3d(dat,options=opts,guess=fit,fdat=fdat,chi2=chi2)
     
     opts.emin = 0.  & opts.emax=3000.      
     opts.names = fitnames
     fit = fitel3d(dat,options=opts,guess=fit,fdat=fdat,chi2=chi2)
endif
return,fit
end
