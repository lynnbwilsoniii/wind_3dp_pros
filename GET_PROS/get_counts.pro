;+
;NAME:		get_counts
;PURPOSE:	used to get counts for 0, 90, 180 degrees
;
;		This function is called by get_en_pa_spec and the like
;CREATED BY:	Arjun Raj (8-15-97)
;-




function get_counts,thedata, therange

n_energies = n_elements(thedata.energy)

outdata = {ninety:fltarr(n_energies),oneeighty:fltarr(n_energies),zero:fltarr(n_energies)}

index = where(thedata.ang ge (180-therange) and thedata.ang ne 180, count)
if count eq 0 then begin 
	index = max(where(thedata.ang ne -1))
	count = 1
endif
if count eq 1 then outdata.oneeighty(*) = thedata.n(*,index)
if count gt 1 then outdata.oneeighty(*) = total(thedata.n(*,index),2)/float(count)

index = where(thedata.ang le (90+therange/2) and thedata.ang ge (90-therange/2), count)
if count eq 0 then outdata.ninety = 0
if count eq 1 then outdata.ninety(*) = thedata.n(*,index)
if count gt 1 then outdata.ninety(*) = total(thedata.n(*,index),2)/float(count)

index = where(thedata.ang le (therange) and thedata.ang ne 0, count)
if count eq 0 then begin 
	index = min(where(thedata.ang ne -1))
	count = 1
endif
if count eq 1 then outdata.zero(*) = thedata.n(*,index)
if count gt 1 then outdata.zero(*) = total(thedata.n(*,index),2)/float(count)

return,outdata
end



