;+
;Procedure:	interpolate, a, b, str_out
;INPUT:	
;	a:	a string containing a structure (e.g. a.x(1000), a.y(1000,3))
;	b:	the other string. a.x and b.x are not the same. The resulting
;		array size is the size of a.
;OUTPUT:
;	str_out: a string which contains the interpolate version of b. 	
;PURPOSE:
;	To make vectors of the same size by interpolation.
;	
;
;CREATED BY:
;	Tai Phan	96-10-16
;LAST MODIFICATION:
;	96-10-16		Tai Phan
;-

pro interpolate, a, b, str_out

get_data, a, data=vec1
get_data, b, data=vec2


size_info=size(vec2.y)


if (size_info(0) eq 1) then begin

vec2_i= interpol(vec2.y,vec2.x,vec1.x)

endif else begin

vec2_i= fltarr(n_elements(vec1.x),size_info(2))
for i=0,size_info(2)-1 do begin
vec2_i(*,i)= interpol(reform(vec2.y(*,i)),vec2.x,vec1.x)
endfor

endelse

store_data,str_out,data={ytitle:str_out,xtitle:'Time',x:vec1.x,y:vec2_i}

end



