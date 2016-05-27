

function pl_fit4, dat,  $
    parameters=par ,set=set

if not keyword_set(par) then $
   par = pl_param2(dat)

if data_type(dat) eq 8 then begin
   m = 4
   nnrg = (dat.nenergy +4-1)*m +1
   nb   = round(sqrt(dat.nbins))
   nphi = (nb + 4 -1)*m +1
   
   nth  = nphi
   t_s = dat.t_s
   dth = 5.625/m
   theta = (findgen(nth)+(t_s-9.5)*m)*dth
   
   p_s = dat.p_s
   dphi = 5.625 / m
   phi = 225. - (findgen(nphi) +(p_s -2 -.5)*m)*dphi
   
   nrg = dat.volts(1,*)*6.25
   e0 = nrg(0)
   n = 13
   l = n/alog(nrg(0)/nrg(n))
   x = findgen(nnrg)-2*m
   nrg = e0 * exp(- x/(l*m) )
   
   k= alog(nrg(0)/nrg(nnrg-1))/(nnrg-1)
   
   dnrg = k * nrg
   
   
   
help,nrg,phi,theta   

   theta_v = reform(replicate(1.,nnrg*nphi) # theta,nnrg,nphi,nth)
   nrg_v = reform(nrg # replicate(1.,nphi*nth),nnrg,nphi,nth)
   phi_v = reform(replicate(1.,nnrg) # phi,nnrg*nphi)
   phi_v = reform(phi_v  # replicate(1.,nth) ,nnrg,nphi,nth)
   
   dv_v =  reform(dnrg # replicate(dth*dphi,nth*nphi),nnrg,nphi,nth)
   
endif 



e=1
p=1
t=1
f = 1.
intgrl = integrate_resp_ept(f*dv_v,g,m,e,p,t)

resp = pl_response2(nrg_v,phi_v,theta_v,e,p,t,par=dat)

flux = pl_flux(nrg_v,phi_v,theta_v,par=par.p)
flux = flux+pl_flux(nrg_v,phi_v,theta_v,par=par.a)

deadtime = dat.deadtime
crate = flux * gf
rate = crate/(1+crate*deadtime)
counts = rate*dt

case strlowcase(units) of
'flux'   :  data = flux
'crate'  :  data = crate
'rate'   :  data = rate
'counts' :  data = counts
endcase

if data_type(dat) eq 8 and keyword_set(set) then begin
   dat.data = data
   str_element,dat,'bins',value = bins
   if n_elements(bins) gt 0 then begin
      ind = where(bins)
      data = data(ind)
   endif else data = reform(data,n_elements(data),/overwrite)
endif

return,data
end
