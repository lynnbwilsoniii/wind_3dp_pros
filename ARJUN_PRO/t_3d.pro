;+
;FUNCTION:	t_3d(temp,ERANGE=erange,BINS=bins)
;INPUT:	
;	temp:	structure,	3d data structure filled by get_pl, get_el, etc.
;		e.g "get_el"
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;PURPOSE:
;	Returns the temperature, [Tx,Ty,Tz,Tavg], eV 
;NOTES:	
;	Function normally called by "get_3dt" to generate 
;	time series data for "tplot,".
;
;CREATED BY:
;	J.McFadden
;LAST MODIFICATION:
;	95-7-27		J.McFadden
;-
function t_3d ,temp,DIAG=diag,ERANGE=er,BINS=bins

Tavg = 0.
Tx = 0.
Ty = 0.
Tz = 0.

if temp.valid eq 0 then begin
	print,'Invalid Data'
	return, [Tx,Ty,Tz,Tavg]
endif

if not keyword_set(er) then er=[0,-1]
if (not keyword_set(bins) and temp.valid eq 1) then begin
	bins=bytarr(temp.nbins)
	bins(*)=1
endif

press = p_3d(temp,DIAG=diag,ERANGE=er,BINS=bins)
density = n_3d(temp,ERANGE=er,BINS=bins)
if density ne 0. then begin
	Tavg = (press(0)+press(1)+press(2))/(density*6.)
	Tx = press(0)/(density*2.)
	Ty = press(1)/(density*2.)
	Tz = press(2)/(density*2.)
endif

return, [Tx,Ty,Tz,Tavg]

end

