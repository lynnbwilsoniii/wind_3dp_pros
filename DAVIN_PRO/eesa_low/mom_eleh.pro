function mom_eleh,el,eh,format=format,sc_pot=sc_pot,erange=erange

if n_params() eq 0 then return,mom3d()

elef = conv_units(el,"eflux")
ehef = conv_units(eh,"eflux")

if not keyword_set(sc_pot) then sc_pot=sc_pot_el(el)

if not keyword_set(erange) then erange=[250.,800.]
elow = erange[0]
ehigh = erange[1]

elff = 1-( 0 > (alog(elef.energy/elow)/alog(ehigh/elow)) < 1)
ehff = ( 0 > (alog(ehef.energy/elow)/alog(ehigh/elow)) < 1)

elef.data = elef.data * elff
ehef.data = ehef.data * ehff

elsum = mom_sum(elef,sc_pot=sc_pot)
ehsum = mom_sum(ehef,sc_pot=sc_pot)

esum = elsum
esum.n = elsum.n + ehsum.n
esum.nv = elsum.nv + ehsum.nv
esum.nvv = elsum.nvv + ehsum.nvv
esum.nvvv = elsum.nvvv + ehsum.nvvv
esum.nvvvv = elsum.nvvvv + ehsum.nvvvv

mom = mom3d(sum=esum,format=format)
mom.time = el.time

return,mom

end

