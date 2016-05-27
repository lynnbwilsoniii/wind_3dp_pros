;+
;FUNCTION get_3d_struct, time
;INPUTS:
;    t:    double  (seconds since 1970.,  >1990)
; or t:    string  (format: YY-MM-DD/HH:MM:SS)
; or t:    numeric (hours from reference date. < )
; or t:    string  (format: HH:MM:SS hours from reference date)
; options: intarray  (only first element is considered to determine instrument)
;KEYWORDS: advance:	if set, advance to the next time 
;OUTPUT:  A structure that contains all pertinent information for a single
;   3D sample.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)get_3d_struct.pro	1.32 98/10/02
;
;NOTE: This routine should NOT be called by users.  Should only be called by one
; of the routines:  get_el, get_eh, get_ph, get_pl, get_sf, get_so
; e.g. "get_el"
;
;-

function get_3d_struct,t,options,advance=advance,index=index
@wind_com.pro

if n_elements(refdate) eq 0 then begin
  print, 'You must first load the data'
  return, {data_name:'null',valid:0}
endif
if n_elements(t) eq 0 then t = str_to_time(refdate)    $
else t = gettime(t)
time = dblarr(4)
time(0) = t(0)    ;time(1) will contain integration time
options = long(options)


if not keyword_set(advance) then advance=0 
if advance ne 0 and n_elements(t) eq 1 then reset_time=1 else reset_time=0
if n_elements(index) gt 0 then options(1)=long(index) else options(1)=-1L

if (n_elements(t) gt 1) then begin
	time2 = t(1) - t(0) + time(0) ; get end time
endif else begin
	time2=t
end

names = ['Eesa High','Eesa Low','Pesa High','Pesa Low','SST Foil','SST Open' $
         ,'Invalid','Pesa Low Burst','Foil+Thick','Open+Thick','Foil spectra'$
         ,'Open spectra','F+T & O+T spectra', 'Eesa Low Burst'              $ 
	 , 'Eesa High Slice', 'Pesa High Burst', 'Easa Low Cuts'           $
         , 'Foil burst spectra','Open burst spectra'			$
	 , 'Foil 3D burst','Open 3D burst','2 spin rates','16 spin rates']

count = 0L
repeat  begin
	ptmap = intarr(32*64) 
	pt_limits = fltarr(4)
	data = fltarr(32*256)
	energy = fltarr(32*256)
	theta= fltarr(32*256)         ; theta values for each bin
	phi  = fltarr(32*256)         ; phi values for each bin
	sizes = intarr(4)   ; [np,nt,ne,nbins]
	geom  = fltarr(256)         ; geometric values of each bin
	denergy  =  fltarr(32*256)
	dtheta  = fltarr(256)         ; theta range of each bin
	dphi    = fltarr(256)         ; phi range of each bin
	domega  = fltarr(256)         ; geometric values of each bin
	options = long(options)      ; 0: data_type, 1: index
	eff = fltarr(32)
	feff = fltarr(32,256)
	spin = 0L
	magel = 0
	magaz = 0

	if count eq 0L then begin
		ok=call_external(wind_lib,'get_3dbins_idl',options,time,sizes, $
		ptmap,pt_limits, data,energy,geom,theta,phi,denergy,dtheta, $
		dphi,domega,eff,feff, spin, magel, magaz, advance)
		if(ok eq 0) then return, {data_name:'Invalid', valid: 0 }
	endif else begin
		ok=call_external(wind_lib,'get_3dbins_idl',options,time,sizes, $
		ptmap,pt_limits, data,energy,geom,theta,phi,denergy,dtheta, $
		dphi,domega,eff,feff, spin, magel, magaz, 1)
;		if(ok eq 0) then return, retdata
	endelse

	if ok ne 0 then begin
		np = sizes(0)
		nt = sizes(1)
		nenergy = sizes(2)
		nbins=sizes(3)
		dname = names(options(0))
		dunit = 'Counts'
		ptmap = reform(ptmap(0:np*nt-1),np,nt)
		data  = reform(data(0:nenergy*nbins-1),nenergy,nbins)
		energy  = reform(energy(0:nenergy*nbins-1),nenergy,nbins)
		denergy  = reform(denergy(0:nenergy*nbins-1),nenergy,nbins)
		phi  = reform(phi(0:nenergy*nbins-1),nenergy,nbins)
		theta  = reform(theta(0:nenergy*nbins-1),nenergy,nbins)
		geom  = geom(0:nbins-1)
		dtheta = dtheta(0:nbins-1)
		dphi   = dphi(0:nbins-1)
		domega = domega(0:nbins-1)
		feff = reform(feff(0:nenergy*nbins-1),nenergy,nbins) 
		eff = eff(0:nenergy-1) 
	
		bindata = {project_name:project_name,data_name:dname, units_name:dunit,  $
		    time:time(0),end_time:time(0)+time(1),integ_t:time(1), index:options(1), $
		    nbins:nbins, nenergy:nenergy, $
		    map:ptmap, data:data, $
		    energy:energy, theta:theta, phi:phi, $
		    geom:geom, denergy:denergy, dtheta:dtheta,  dphi:dphi,  domega:domega, $
		    eff:eff,feff:feff,mass:time(2),geomfactor:time(3),  valid:ok, $
		    spin: spin, magel: magel, magaz: magaz}

		if count eq 0L then retdata = bindata $
		else retdata = sum3d(retdata, bindata)

		count = count + 1L
	endif
endrep until (time(0) ge time2) or (n_elements(t) lt 2) 

if reset_time then t = time(0)

;check for zeros:
;temp = total(retdata.data,1)
;w = where(temp eq 0,c)
;if c gt 0 then retdata.valid = 0

return,retdata

end

