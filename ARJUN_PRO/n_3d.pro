;+
;FUNCTION:	n_3d(temp,ERANGE=erange,BINS=bins)
;INPUT:	
;	temp:	structure,	3d data structure filled by get_pl, get_el, etc.
;		e.g "get_el"
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;PURPOSE:
;	Returns the density, N, 1/(cm^3) 
;NOTES:	
;	Function normally called by "get_3dt" to generate 
;	time series data for "tplot,".
;
;CREATED BY:
;	J.McFadden
;LAST MODIFICATION:
;	95-7-27		J.McFadden
;-
function n_3d,temp,ERANGE=er,BINS=bins

density = 0.

if temp.valid eq 0 then begin
  print,'Invalid Data'
  return, density
endif

data3d = conv_units(temp,"eflux")		; Use Energy Flux
na = data3d.nenergy
nb = data3d.nbins

if keyword_set(er) then begin
	if er(0) gt er(1) then er=[0,na-1]
	if er(0) lt 0 then er(0)=0
	if er(1) gt na-1 then er(1)=na-1
endif else begin
	er=[0,na-1]
endelse

data = data3d.data(er(0):er(1),*)
wdnf = where(finite(data) eq 0,nwdnf) ;wdnf: where data not finite
if nwdnf gt 0 then data(wdnf) = 0

if keyword_set(bins) then begin
	if n_elements(bins) eq nb then begin
		data = data*(replicate(1,er(1)-er(0)+1)#bins)
	endif else begin
		print,"ERROR: bins has wrong array size"
	endelse
endif

domega = data3d.domega
mass = data3d.mass * 1.6e-22
Const = (mass/(2.*1.6e-12))^(.5)
sumdata = Const*data#domega

;  Use the following lines until Davin gets "data.denergy" correct
nrg = data3d.energy(*,0)
denergy = data3d.denergy(*,0)
for a=0,na-1 do begin
	if a eq 0 then denergy(a) = abs(nrg(a)-nrg(a+1)) else $
	if a eq na-1 then denergy(a) = abs(nrg(a-1)-nrg(a)) else $
		denergy(a) = .5*abs(nrg(a-1)-nrg(a+1))
endfor
denergy = denergy(er(0):er(1))
nrg = nrg(er(0):er(1))
;  Use the following lines after Davin gets "data.denergy" correct
; nrg = data3d.energy(er(0):er(1),0)
; denergy = data3d.denergy(er(0):er(1),0)
denergy = denergy*(nrg^(-1.5))

density = total(denergy*sumdata)

return, density
end

