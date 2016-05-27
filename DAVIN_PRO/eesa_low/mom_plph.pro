function mom_plph,pl,ph,format=format,sc_pot=sc_pot,erange=erange

if n_params() eq 0 then return,mom3d()

plef = conv_units(pl,"eflux")
phef = conv_units(ph,"eflux")

if not keyword_set(sc_pot) then sc_pot= 0.  ;sc_pot_el(el)

if not keyword_set(erange) then erange=[0.,30000.]
elow = erange[0]
ehigh = erange[1]

;plff = 1-( 0 > (alog(plef.energy/elow)/alog(ehigh/elow)) < 1)
;phff = ( 0 > (alog(phef.energy/elow)/alog(ehigh/elow)) < 1)

pr = minmax(pl.phi)
tr = minmax(pl.theta)

phff = ph.phi gt pr[1] or ph.phi lt pr[0] or ph.theta lt tr[0] or ph.theta gt tr[1]
plff = 1

plef.data = plef.data * plff
phef.data = phef.data * phff

plsum = mom_sum(plef,sc_pot=sc_pot)
phsum = mom_sum(phef,sc_pot=sc_pot)

psum = plsum
psum.n = plsum.n + phsum.n
psum.nv = plsum.nv + phsum.nv
psum.nvv = plsum.nvv + phsum.nvv
psum.nvvv = plsum.nvvv + phsum.nvvv
psum.nvvvv = plsum.nvvvv + phsum.nvvvv

mom = mom3d(sum=psum,format=format)
mom.time = pl.time

return,mom

end

