;+
;PROCEDURE:	get_sdotb
;PURPOSE:	
;INPUT:		none
;KEYWORDS:	none
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)get_sdotb.pro	1.3 95/08/24
;-

pro get_sdotb

get_data,'Bexp',data=bexp
get_data,'Sexp',data=sexp

if n_elements(bexp) eq 0 or n_elements(sexp) eq 0 then begin
   print, 'Please run get_mfi and get_symm first'
   return
endif


s = sexp.y
b = data_cut(bexp,sexp.x)

sdb = total(s*b,2)
b2 = total(b*b,2)
angle = acos(sdb/sqrt(b2)) * (180./!dpi)

store_data,'s&b',data={ytitle:'Angle S & B',x:sexp.x,y:angle}

return
end


