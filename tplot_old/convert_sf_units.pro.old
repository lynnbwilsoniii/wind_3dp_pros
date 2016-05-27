pro convert_sf_units, data, units, scale=scale
if n_params() eq 0 then return

if strupcase(units) eq strupcase(data.units_name) then return

fluxindx = where(['FLUX','EFLUX','DF'] eq strupcase(data.units_name),fluxcnt)
if fluxcnt gt 0 then begin
	convert_flux_units,data,units,scale=scale
	return
endif

energy = data.energy           ; in eV                (ne,nbins)
denergy = data.denergy
n_e = data.nenergy             ; number of energies   
nbins=data.nbins               ; number of bins       
dt = data.dt                   ; 
gf = data.geomfactor * data.gf
deadtime = data.deadtime
feff = data.feff

mass = data.mass               ; scaler

rate = data.data/dt


dtc = (1.-rate*deadtime) > .1


scale = 0
case strupcase(units) of 
'COUNTS' :  scale = 1.
'RATE'   :  scale = 1 / dt
'CRATE'  :  scale = 1 /dtc / dt
'EFLUX'  :  scale = 1 /dtc / (dt *gf * denergy * feff) * energy
'UFLUX'  :  scale = 1 /dtc / (dt * gf * denergy)
'FLUX'   :  scale = 1 /dtc / (dt * gf * denergy * feff)
'DF'     :  scale = 1 /dtc / (dt * gf * feff * denergy * energy * (2./mass/mass*1e5) )
else: begin
        message,'Undefined units: '+units
	return
      end
endcase


case strupcase(data.units_name) of 
'COUNTS' :  scale = scale * 1.
;'RATE'   :  scale = scale * dt
;'CRATE'  :  scale = scale * dtc * dt
;'EFLUX'  :  scale = scale * dtc * (dt * gf)
;'FLUX'   :  scale = scale * dtc * (dt * gf * energy)
;'DF'     :  scale = scale * dtc * (dt * gf * energy^2 * 2./mass/mass*1e5)
else: begin
        print,'Unknown starting units: ',data.units_name
	return
      end
endcase

data.units_name = units

if find_str_element(data,'ddata') ge 0 then data.ddata = data.ddata*scale
data.data = data.data * scale 
return
end
