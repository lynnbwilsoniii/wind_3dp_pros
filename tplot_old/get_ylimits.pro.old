;+
;PROCEDURE:  get_ylimits, datastr, limits, trg
;PURPOSE:
;   Calculates appropriate ylimits for a string array of "TPLOT" variables
;   to be plotted in the same panel.
;INPUT:  datastr	string array of TPLOT variables
;	 limits		limits structure to be modified (usually the limits
;			structure of the TPLOT variable whose data
;			field is a string array of TPLOT variables)
;	 trg		time range over which to calculate the limits;
;			double[2]
;CREATED BY:	Peter Schroeder
;LAST MODIFIED:	%W% %E%
;-
pro get_ylimits,datastr,limits,trg

miny = 0.
maxy = 0.
str_element,limits,'min_value',min_value
str_element,limits,'max_value',max_value
str_element,limits,'ytype',ytype

for i=0,n_elements(datastr)-1 do begin
	get_data,datastr(i),data=data,dtype=dtype
	if (dtype eq 1) and keyword_set(data) then begin
		good = where(finite(data.x),count)
		if count eq 0 then message,'No valid X data'
	
		ind = where(data.x(good) ge trg(0) and data.x(good) le trg(1),count)
		if count eq 0 then ind = indgen(n_elements(data.x)) else ind = good(ind)

		ndx = ndimen(data.x)
	
		if ndx eq 1 then $
			yrange = minmax(data.y(ind,*),posi=ytype,$
			max=max_value,min=min_value) $
		else $
			yrange = minmax(data.y(ind),posi=ytype,$
			max=max_value,min=min_value)
		if miny ne maxy then begin
			if yrange(0) lt miny then miny = yrange(0)
			if yrange(1) gt maxy then maxy = yrange(1)
		endif else begin
			miny = yrange(0)
			maxy = yrange(1)
		endelse
	endif
endfor

str_element,limits,'yrange',[miny, maxy],/add

return
end
