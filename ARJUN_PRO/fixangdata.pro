;+
;NAME:		fixangdata
;PURPOSE:	rebins the angle data to make the data look better
;
;		This function is called by get_v_spec, get_en_pa_spec,
;		and their related programs.
;CREATED BY:	Arjun Raj (8-15-97)
;-






function fixangdata,dataset,numsteps,nodiscard = nodiscard,noextra = noextra

outdata = {ang:fltarr(numsteps+2),energy:dataset.energy,n:fltarr(n_elements(dataset.energy),numsteps+2)}

for i = 0,numsteps-1 do begin
	outdata.ang(i+1) = (i+.5)*180/numsteps

	index = where(dataset.ang ge i*180/numsteps and dataset.ang lt (i+1)*180/numsteps)
	if index(0) eq -1 then outdata.n(*,i+1)=1e30 else $
	if n_elements(index) eq 1 then outdata.n(*,i+1)= dataset.n(*,index) else $   ;if there's 1 element, it 
											;becomes the value
	outdata.n(*,i+1) = total(dataset.n(*,index),2)/n_elements(index)      ;otherwise, make it an average
endfor

outdata.ang(0) = 0
outdata.ang(numsteps+1) = 180
if not keyword_set(noextra) then begin
	outdata.n(*,0) = outdata.n(*,1)
	outdata.n(*,numsteps+1) = outdata.n(*,numsteps)
endif else begin
	outdata.n(*,0) = 1e30
	outdata.n(*,numsteps+1) = 1e30
endelse

if not keyword_set(nodiscard) then begin
	index = where(outdata.n(0,*) ne 1e30)
	;here, all the parts which were marked 1e30 due to no data
	;have been excluded from the final data returned.
	finaldata = {ang:outdata.ang(index),energy:outdata.energy,n:outdata.n(*,index)}
endif else finaldata = outdata

return,finaldata

end
	
