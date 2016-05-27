;+
;FUNCTION:  omni3d
;PURPOSE:  produces an omnidirectional spectrum structure by summing
; over the non-zero bins in the keyword bins.
; this structure can be plotted with "spec3d"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)omni3d.pro	1.12 02/04/17
;
; WARNING:  This is a very crude structure; use at your own risk.
;-

function omni3d,inpdat,  $
   bins=bins            ;not finished !!!

dat = inpdat
units = dat.units_name
if data_type(dat) ne 8 then return,0
if dat.valid eq 0 then return,{valid:0}
tags = ['project_name','data_name','valid','units_name','units_procedure',  $
  'time','end_time', 'integ_t',  'nbins','nenergy',  $
    'mass', 'eff','geomfactor']
extract_tags,omni,dat,tags=tags
if keyword_set(bins) eq 0 then bins = replicate(1b,dat.nbins)
ind = where(bins,count)
if count eq 0 then return,omni

omni.nbins = 1

fluxindx = where(['FLUX','EFLUX','DF'] eq strupcase(units),fluxcnt)
if fluxcnt eq 0 then begin
	print,'Converting units to EFlux'
	dat=conv_units(dat,'EFlux')
endif

norm = count

str_element,dat,'feff',value=feff
if n_elements(feff) ne 0 then $
   str_element,/add,omni, 'feff',total(dat.feff(*,ind),2)/count

str_element,/add,omni, 'units_name', dat.units_name
str_element,/add,omni, 'denergy',total(dat.denergy(*,ind),2)/count
str_element,/add,omni, 'data'   ,total(dat.data(*,ind),2)/norm
str_element,/add,omni, 'energy' ,total(dat.energy(*,ind),2)/count
str_element,/add,omni, 'deadtime', total(dat.deadtime(*,ind))
str_element,/add,omni, 'domega' ,total(dat.domega(ind))

str_element,dat,'ddata',value=ddata
if n_elements(ddata) ne 0 then $
   str_element,/add,omni,'ddata', sqrt(total(ddata(*,ind)^2,2))/norm


;if units eq 'Counts' then $
;  str_element,/add,omni, 'ddata'  ,sqrt(omni.data > .7)/norm

omni.nbins = 1

return,omni
end

