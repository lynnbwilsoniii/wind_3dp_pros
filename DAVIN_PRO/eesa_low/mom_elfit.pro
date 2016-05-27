function mom_elfit,dat,fit,fdat,hpardens=hpardens,format=mf,mh=mh

fc = fit
fc.halo.n = 0
;if not keyword_set(fdat) then $
;  dfit = fitel3d(dat,guess=fit,/no_fit,fdat=fdat)

hdat=dat
hdat.sc_pot = fc.sc_pot
hdat.data = dat.data-fdat.data
hdat.bins = dat.energy gt fc.sc_pot*1.4

  sumc = elfit2sum(fc,/core_only)
  sumh = mom_sum(hdat,pardens=hpardens)
  sumt = sumc
  sumt.n   = sumc.n   + sumh.n
  sumt.nv   = sumc.nv   + sumh.nv
  sumt.nvv   = sumc.nvv   + sumh.nvv
  sumt.nvvv   = sumc.nvvv  + sumh.nvvv
  sumt.nvvvv   = sumc.nvvvv  + sumh.nvvvv
  
  
mt = mom3d(sum=sumt,format=mf)  & mt.time = dat.time
mh = mom3d(sum=sumh,format=mf)  & mh.time = dat.time
;mc = mom3d(sum=sumc,format=mf)

return,mt
end

