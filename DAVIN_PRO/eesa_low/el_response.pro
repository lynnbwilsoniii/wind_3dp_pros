function el_response,volts,energy,denergy,nsteps=nsteps

common el_response_com,resp0,volts0,energy0,denergy0,nsteps0

if keyword_set(nsteps0) then begin
  if nsteps eq nsteps0 and total(volts ne volts0) eq 0 then begin
     energy=energy0
     denergy=denergy0
     return,resp0
  endif
endif
message,/info,'Computing instrument response.'


k_an = 6.42
;fwhm = .1
fwhm = .22

if keyword_set(nsteps) then begin
  erange = k_an*minmax_range(volts)*[1-fwhm,1+fwhm]^2
  energy = dgen(nsteps,/log,range=erange)
  i = lindgen(nsteps)
  denergy = abs(energy[i+1]-energy[i-1])/2
endif

nn = n_elements(energy)
nv = n_elements(volts)

dim = dimen(volts)
es = replicate(1.,nv) # energy
kvs = reform(k_an*volts,nv) # replicate(1.,nn) 
sigma = fwhm/(2*sqrt(2*alog(2))) * kvs
resp = exp( -((es-kvs)/sigma)^2 /2) / sqrt(2*!pi) / sigma
resp = resp * (replicate(1.,nv) # denergy)

if ndimen(volts) eq 2 then begin
  resp = reform(resp,dim[0],dim[1],nn)
  resp = total(resp,1)/dim[0]
endif

volts0=volts
resp0=resp
energy0=energy
denergy0=denergy
nsteps0=nsteps

;plot,energy,resp(14,*),/xl
;for i=0,dimen1(resp)-1 do oplot,energy,resp(i,*)
return,resp
end
