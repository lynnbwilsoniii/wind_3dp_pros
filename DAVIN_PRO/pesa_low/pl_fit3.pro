

function pl_fit3, x,  $
    parameters=p ,set=set

if not keyword_set(p) then $
   p = pl_momparam(x)

if data_type(x) eq 8 then begin
   energy = x.energy
   theta = x.theta
   phi = x.phi
   mass = x.mass
   units = x.units_name
   gf = x.geomfactor * energy
   dt = replicate(x.integ_t/64/16,x.nenergy,x.nbins)
endif else begin
   mass = 5.6856593e-06 *1836.
   energy = .5 * mass * total(x*x,2)
   vx = x(*,0)
   vy = x(*,1)
   vz = x(*,2)
   units = 'eflux'
endelse

flux = pl_flux(energy,theta,phi,par=p.p)
flux = flux+pl_flux(energy,theta,phi,par=p.a)

deadtime = x.deadtime
crate = flux * gf
rate = crate/(1+crate*deadtime)
counts = rate*dt

case strlowcase(units) of
'flux'   :  data = flux
'crate'  :  data = crate
'rate'   :  data = rate
'counts' :  data = counts
endcase

if data_type(x) eq 8 and keyword_set(set) then begin
   x.data = data
   str_element,x,'bins',value = bins
   if n_elements(bins) gt 0 then begin
      ind = where(bins)
      data = data(ind)
   endif else data = reform(data,n_elements(data),/overwrite)
endif

return,data
end










