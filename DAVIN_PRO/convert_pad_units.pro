pro convert_pad_units,dat,units,scale=scale
   ind = where(dat.cnt gt 0)
   bad = where(dat.cnt eq 0)
   dat.energy(ind) = dat.energy(ind) / dat.cnt(ind)
   dat.angles(ind) = dat.angles(ind) / dat.cnt(ind)
   dat.data(ind)   = dat.data(ind)   / dat.cnt(ind)
   dat.ddata(ind)  = sqrt(dat.ddata(ind)/dat.cnt(ind) - (dat.data(ind))^2)

   nan = !values.f_nan
   dat.data(bad) = nan
   dat.ddata(bad) = nan
   dat.angles(bad) = nan
   dat.energy(bad) = nan
   dat.valid = 1




;   add_str_element,dat


return
end
