pro convert_ph_units, data, units, deadtime = deadt,scale=scale
;+
;NAME:      convert_ph_units
;PURPOSE:            
;           Converts the units of the data array of ph data structures.
;CALLING SEQUENCE:      convert_ph_units,data,units
;INPUTS:    data:  a ph data structure returned by "get_ph1.pro" or "get_ph2.pro"
;                  data.data is rescaled in the requested units, and
;                  data.units is set to the name of the new units
;           units: a string.  One of: 'COUNTS','RATE','EFLUX','FLUX','DF'
;
;KEYWORD PARAMETERS:    
;           DEADTIME: (double) specifies a deadtime: the interval during which 
;                     a channel plate detector is turned off to record an event.
;                     data.deadtime defaults to 1e-6 
;		      (and has precedence over deadtime)
;COMMON BLOCKS:   get_ph_com: contains one element: deadtime
;
;LAST MODIFICATION:     @(#)convert_ph_units.pro	1.1 97/04/21
;CREATED BY:            Frank Marcoline.  Patterened after other convert_*_units.pro procedures.
;-
common get_ph1_com, deadtime

if strupcase(units) eq strupcase(data.units_name) then return

energy = data.energy               ;in eV                       float(ne,nbins)
n_e    = data.nenergy              ;number of energies          float
nbins  = data.nbins                ;number of bins              float
dt     = data.dt                   ;integration time            double(ne,nbins)
gf     = data.gf * data.geomfactor ;geometric factor            float(ne,nbins)
mass   = data.mass                 ;proton mass                 double

if strupcase(data.units_name) ne 'COUNTS' then message , 'bad units'

if n_elements(deadtime) eq 0 then deadtime = 0d
if n_elements(deadt) ne 0 then deadtime = double(deadt)
str_element,data,'deadtime',value=deadtime

rate = data.data/dt
dt   = dt * (1.-rate*deadtime)     ;effective integration time double(ne,nbins)

if not keyword_set(scale) then scale = 1
case strupcase(units) of 
'COUNTS' :  scale = 1.
'RATE'   :  scale = 1. / dt
'EFLUX'  :  scale = 1. / (dt * gf)
'FLUX'   :  scale = 1. / (dt * gf * energy)
'DF'     :  scale = 1. / (dt * gf * energy^2 * (2./mass/mass*1e5) )
else: begin
        print,'Undefined units: ',units
	return
      end
endcase


case strupcase(data.units_name) of 
'COUNTS' :  scale = scale * 1.
'RATE'   :  scale = scale * dt
'EFLUX'  :  scale = scale * (dt * gf)
'FLUX'   :  scale = scale * (dt * gf * energy)
'DF'     :  scale = scale * (dt * gf * energy^2 * 2./mass/mass*1e5)
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
