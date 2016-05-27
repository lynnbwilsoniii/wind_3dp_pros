;+
;FUNCTION:	j_3d(temp,ERANGE=erange,BINS=bins)
;INPUT:	
;	temp:	structure,	3d data structure filled by get_pl, get_el, etc.
;		e.g "get_el"
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;PURPOSE:
;	Returns the flux, [Jx,Jy,Jz], 1/(cm^2-s) 
;NOTES:	
;	Function normally called by "get_3dt" to generate 
;	time series data for "tplot,".
;
;CREATED BY:
;	J.McFadden
;LAST MODIFICATION:
;	95-7-27		J.McFadden
;-
function j_3d ,temp,ERANGE=er,BINS=bins

flux3dx = 0.
flux3dy = 0.
flux3dz = 0.

if temp.valid eq 0 then begin
  print,'Invalid Data'
  return, [flux3dx,flux3dy,flux3dz]
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
if nwdnf gt 0 then data(wdnf) = 0 ;set non-finite data to zero
 
if keyword_set(bins) then begin
	if n_elements(bins) eq nb then begin
		data = data*(replicate(1,er(1)-er(0)+1)#bins)
	endif else begin
		print,"ERROR: bins has wrong array size"
	endelse
endif

domega = data3d.domega
theta = data3d.theta(0,*)/!radeg
phi = data3d.phi(er(0):er(1),*)/!radeg
mass = data3d.mass * 1.6e-22

;print,er
;stop

;  Use the following lines until Davin gets "data.denergy" correct
nrg = data3d.energy(*,0)
denergy = data3d.denergy(*,0)
for a=0,na-1 do begin
	if a eq 0 then denergy(a) = abs(nrg(a)-nrg(a+1)) else $
	if a eq na-1 then denergy(a) = abs(nrg(a-1)-nrg(a)) else $
		denergy(a) = .5*abs(nrg(a-1)-nrg(a+1))
endfor
denergy = denergy*(nrg^(-1))
denergy = denergy(er(0):er(1))
;  Use the following lines after Davin gets "data.denergy" correct
; nrg = data3d.energy(er(0):er(1),0)
; denergy = data3d.denergy(er(0):er(1),0)
; denergy = denergy*(nrg^(-1))

sumdatax = (data*cos(phi))#(domega*cos(theta))
sumdatay = (data*sin(phi))#(domega*cos(theta))
sumdataz = data#(domega*sin(theta))

flux3dx = total(denergy*sumdatax)
flux3dy = total(denergy*sumdatay)
flux3dz = total(denergy*sumdataz)
;stop
return, [flux3dx,flux3dy,flux3dz]
end

