;+
;FUNCTION:	p_3d(temp,ERANGE=erange,BINS=bins)
;INPUT:	
;	temp:	structure,	3d data structure filled by get_pl, get_el, etc.
;		e.g "get_el"
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;PURPOSE:
;	Returns the pressure tensor, [Pxx,Pyy,Pzz,Pxy,Pxz,Pyz], eV/cm^3 
;NOTES:	
;	Function normally called by "get_3dt" to generate 
;	time series data for "tplot,".
;
;CREATED BY:
;	J.McFadden
;LAST MODIFICATION:
;	95-7-27		J.McFadden
;-
function p_3d ,temp,DIAG=diag,ERANGE=er,BINS=bins

p3dxx = 0.
p3dyy = 0.
p3dzz = 0.
p3dxy = 0.
p3dxz = 0.
p3dyz = 0.

if temp.valid eq 0 then begin
  print,'Invalid Data'
  return, [p3dxx,p3dyy,p3dzz,p3dxy,p3dxz,p3dyz]
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
endif else begin
	bins=bytarr(temp.nbins)
	bins(*)=1
endelse

domega = data3d.domega
theta = data3d.theta(0,*)/!radeg
phi = data3d.phi(er(0):er(1),*)/!radeg
mass = data3d.mass * 1.6e-22
Const = (mass/(2.*1.6e-12))^(-.5)

;  Use the following lines until Davin gets "data.denergy" correct
nrg = data3d.energy(*,0)
denergy = data3d.denergy(*,0)
for a=0,na-1 do begin
	if a eq 0 then denergy(a) = abs(nrg(a)-nrg(a+1)) else $
	if a eq na-1 then denergy(a) = abs(nrg(a-1)-nrg(a)) else $
		denergy(a) = .5*abs(nrg(a-1)-nrg(a+1))
endfor
denergy = denergy*(nrg^(-.5))
denergy = Const*denergy(er(0):er(1))
;  Use the following lines after Davin gets "data.denergy" correct
; nrg = data3d.energy(er(0):er(1),0)
; denergy = data3d.denergy(er(0):er(1),0)
; denergy = Const*denergy*(nrg^(-.5))

cth = cos(theta)
sth = sin(theta)
cph = cos(phi)
sph = sin(phi)
cth2 = cth^2
cthsth = cth*sth
sumxx = (data*cph*cph)#(domega*cth2)
sumyy = (data*sph*sph)#(domega*cth2)
sumzz = data#(domega*sth*sth)
sumxy = (data*cph*sph)#(domega*cth2)
sumxz = (data*cph)#(domega*cthsth)
sumyz = (data*sph)#(domega*cthsth)

p3dxx = total(denergy*sumxx)
p3dyy = total(denergy*sumyy)
p3dzz = total(denergy*sumzz)
p3dxy = total(denergy*sumxy)
p3dxz = total(denergy*sumxz)
p3dyz = total(denergy*sumyz)


flux = j_3d(temp,ERANGE=er,BINS=bins)
density = n_3d(temp,ERANGE=er,BINS=bins)
if density eq 0. then begin
	vel=[0.,0.,0.]
endif else begin
	vel = flux/density
endelse
p3dxx = mass*(p3dxx-vel(0)*flux(0))/1.6e-12
p3dyy = mass*(p3dyy-vel(1)*flux(1))/1.6e-12
p3dzz = mass*(p3dzz-vel(2)*flux(2))/1.6e-12
p3dxy = mass*(p3dxy-vel(0)*flux(1))/1.6e-12
p3dxz = mass*(p3dxz-vel(0)*flux(2))/1.6e-12
p3dyz = mass*(p3dyz-vel(1)*flux(2))/1.6e-12

;	Pressure is in units of eV/cm**3

if keyword_set(diag) then begin
print, " This section not tested yet!!!!!"
if diag eq "diag" then begin

	p = [[p3dxx,p3dxy,p3dxz],[p3dxy,p3dyy,p3dyz],[p3dxz,p3dyz,p3dzz]]
	nr_tred2,p,d,e
	nr_tqli,d,e,p
	print,"d =",d
	print,"p =",p(0,0),p(1,1),p(2,2),p(0,1),p(0,2),p(1,2)

endif
endif

return, [p3dxx,p3dyy,p3dzz,p3dxy,p3dxz,p3dyz]
end

