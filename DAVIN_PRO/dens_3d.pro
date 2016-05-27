


function dens_3d, data, sc_pot ,pardens=pardens

if n_elements(sc_pot) eq 0 then sc_pot = 0.

if data.valid eq 0 then begin
  print,'Invalid Data'
  return, !values.f_nan
endif

data3d = conv_units(data,"eflux")		; Use Energy Flux

e = data3d.energy
de = data3d.denergy
domega = replicate(1.,data3d.nenergy) # data3d.domega

dvolume =  de / e * domega

e_inf = (e - sc_pot) > 0.
dweight = sqrt(data3d.mass * 1e-10 * e_inf/2. )/e

pardens = data3d.data * dweight * dvolume

density = total(pardens)

return, density
end
