pro convert_flux_units, data, units, scale=scale

energy = data.energy
mass = data.mass

case strupcase(units) of
'FLUX' : scale = 1.
'EFLUX': scale = energy
'DF'   : scale = 1./(energy * (2./mass/mass*1e5))
else: begin
	message,'Cannot convert to units of '+units
	return
      end
endcase

case strupcase(data.units_name) of
'FLUX' : scale = scale
'EFLUX': scale = scale/energy
'DF'   : scale = scale * energy * 2./mass/mass*1e5
endcase

data.units_name = units

if find_str_element(data,'ddata') ge 0 then data.ddata = data.ddata*scale
data.data = data.data * scale 
return
end
