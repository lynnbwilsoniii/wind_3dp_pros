;+
;FUNCTION:	vth_3d(temp,ERANGE=erange,BINS=bins)
;INPUT:	
;	temp:	structure,	3d data structure filled by get_pl, get_el, etc.
;		e.g "get_el"
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;PURPOSE:
;	Returns the thermal velocity, [Vthx,Vthy,Vthz,Vthavg], km/s 
;NOTES:	
;	Function normally called by "get_3dt" to generate 
;	time series data for "tplot,".
;
;CREATED BY:
;	J.McFadden
;LAST MODIFICATION:
;	95-7-27		J.McFadden
;-
function vth_3d ,temp,DIAG=diag,ERANGE=er,BINS=bins

vth = 0.
vthx = 0.
vthy = 0.
vthz = 0.

if temp.valid eq 0 then begin
	print,'Invalid Data'
	return, [vthx,vthy,vthz,vth]
endif

if not keyword_set(er) then er=[0,-1]
if (not keyword_set(bins) and temp.valid eq 1) then begin
	bins=bytarr(temp.nbins)
	bins(*)=1
endif

mass = temp.mass * 1.6e-22
press = p_3d(temp,DIAG=diag,ERANGE=er,BINS=bins)
density = n_3d(temp,ERANGE=er,BINS=bins)
if density ne 0. then begin
	Tavg = (press(0)+press(1)+press(2))/(density*6.)
	Tx = press(0)/(density*2.)
	Ty = press(1)/(density*2.)
	Tz = press(2)/(density*2.)
	vth = 1.e-5*(2.*Tavg*1.6e-12/mass)^.5
	vthx = 1.e-5*(2.*Tx*1.6e-12/mass)^.5
	vthy = 1.e-5*(2.*Ty*1.6e-12/mass)^.5
	vthz = 1.e-5*(2.*Tz*1.6e-12/mass)^.5
endif

return, [vthx,vthy,vthz,vth]

end

