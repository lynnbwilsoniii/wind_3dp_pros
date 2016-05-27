function conv_temperature,dat
tdf = conv_units(dat,'df')
dlf = alog(tdf.data > 1e-20)
dlf = dlf-shift(dlf,1,0)
de = tdf.energy-shift(tdf.energy,1,0)
e = (tdf.energy+shift(tdf.energy,1,0))/2
t = -de/dlf
e[0,*] = !values.f_nan
t[0,*] = !values.f_nan
tdf.data = t
tdf.units_name='Temp'
return,tdf
end