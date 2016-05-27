;+
;FUNCTION:	v_3d(temp,ERANGE=erange,BINS=bins)
;INPUT:	
;	temp:	structure,	3d data structure filled by get_pl, get_el, etc.
;		e.g. "get_el"
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;PURPOSE:
;	Returns the velocity, [Vx,Vy,Vz], km/s 
;NOTES:	
;	Function normally called by "get_3dt" to generate 
;	time series data for "tplot".
;
;CREATED BY:
;	J.McFadden
;LAST MODIFICATION:
;	95-7-27		J.McFadden
;-
function v_3d ,temp,ERANGE=er,BINS=bins

vel = [0.,0.,0.]

if temp.valid ne 1 then begin
	print,'Invalid Data'
	return, vel
endif

if not keyword_set(er) then er=[0,-1]
if (not keyword_set(bins) and temp.valid eq 1) then begin
	bins=bytarr(temp.nbins)
	bins(*)=1
endif

flux = j_3d(temp,ERANGE=er,BINS=bins)
density = n_3d(temp,ERANGE=er,BINS=bins)
if density ne 0. then vel = 1.e-5*flux/density

return, vel

end

