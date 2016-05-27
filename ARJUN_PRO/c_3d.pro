;+
;FUNCTION:	c_3d(temp,ERANGE=erange,BINS=bins)
;INPUT:	
;	temp:	structure,	3d data structure filled by get_pl, get_el, etc.
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;PURPOSE:
;	Returns the sum of the counts in temp.data
;NOTES:	
;	Function normally called by "get_3dt" to generate 
;	time series data for "tplot".
;
;CREATED BY:
;	J.McFadden
;LAST MODIFICATION:
;	95-7-27		J.McFadden
;-
function c_3d,temp,ERANGE=er,BINS=bins

count = 0.

if temp.valid eq 0 then begin
  print,'Invalid Data'
  return, count
endif

na = temp.nenergy
nb = temp.nbins

if keyword_set(er) then begin
	if er(0) gt er(1) then er=[0,na-1]
	if er(0) lt 0 then er(0)=0
	if er(1) gt na-1 then er(1)=na-1
endif else begin
	er=[0,na-1]
endelse

data = temp.data(er(0):er(1),*)
wdnf = where(finite(data) eq 0,nwdnf) ;wdnf: where data not finite
if nwdnf gt 0 then data(wdnf) = 0 ;set non-finite data to zero
 
if keyword_set(bins) then begin
	if n_elements(bins) eq nb then begin
		data = data*(replicate(1,er(1)-er(0)+1)#bins)
	endif else begin
		print,"ERROR: bins has wrong array size"
	endelse
endif

count = total(data)

return, count
end

