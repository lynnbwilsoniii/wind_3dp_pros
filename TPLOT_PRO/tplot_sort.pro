;+
;PROCEDURE:  tplot_sort,name
;PURPOSE: 
;   Sorts tplot data by time (or x).
;INPUT:
;   name: name of tplot variable to be sorted.
;KEYWORDS:  
;
;CREATED BY:    Peter Schroeder
;LAST MODIFICATION:     %W% %E%
;
;-



pro tplot_sort,name

indx = find_handle(name)

sepname = str_sep(name,'.')

if n_elements(sepname) eq 1 then begin
	get_data,name,ptr=pdata
	str_element,pdata,'X',foo,success=ok
	if ok then begin
		newind = sort(*(pdata.x))
		*(pdata.x) = (*(pdata.x))(newind)
		if ndimen(*(pdata.y)) eq 1 then $
			*(pdata.y) = (*(pdata.y))(newind) else $
			*(pdata.y) = (*(pdata.y))(newind,*)
		str_element,pdata,'V',foo,success=vok
		if vok then if ndimen(*(pdata.v)) eq 2 then $
			*(pdata.v) = (*(pdata.v))(newind,*)
	endif else begin
		newind = sort(*(pdata.time))
		tags = tag_names_r(pdata)
		for i = 0,n_elements(tags)-1 do begin
			str_element,pdata,tags(i),thisfoo
			if ndimen(*(thisfoo)) eq 1 then $
				*(thisfoo) = (*(thisfoo))(newind) else $
				*(thisfoo) = (*(thisfoo))(newind,*)
		endfor
	endelse
endif else tplot_sort,sepname(0)

return
end