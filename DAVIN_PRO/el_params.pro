function el_params,dat,ion,format=format

if dat.valid eq 0 then begin
  if keyword_set(format) then return,fill_nan(format)
  return,0
endif



str_element,format,'mt',mom
str_element,format,'fit',fit

str_element,format,'valid',valid
str_element,ion,'density',tdens


mt = mom_el(dat,true=tdens,fit=fit,format=mom,chi=chi,hmom=mh)

pot = fit.sc_pot

ethresh=500.
dfi = convert_vframe(dat,/int,ethresh=ethresh,evalues=evalues,sc_pot=pot)
dfi = conv_units(dfi,'flux')
pd = pad(dfi,NUM_PA=num_pa)

if not keyword_set(format) then begin
format=fill_nan({ $
        time:dat.time  $
       ,valid:dat.valid $
       ,vsw:dat.vsw $
       ,magf:dat.magf  $
       ,ion:ion  $
       ,fit:fit,  chi:chi $
       ,mt:mt  $
       ,mh:mh  $
       ,flux:pd.data $
       ,pangle:pd.angles $
       ,energy:evalues $
        })
endif

ret = format

ret.time = dat.time
ret.valid = dat.valid
ret.flux = pd.data
ret.energy = evalues
ret.pangle = pd.angles
ret.mt = mt
ret.mh = mh
ret.vsw = dat.vsw
ret.magf = dat.magf
ret.ion = ion
ret.fit = fit
ret.chi = chi

return,ret
end


