function eesal_counts, dat,  $
    set=set, $
    energy=energy, $
    parameters=p 


if not keyword_set(p) then begin
   if not keyword_set(model_name) then model_name = 'eldf'
   dummy = call_function(model_name,param=mp)
   p = {model_name:model_name,mp:mp,v_shift:.31d,deadtime:0.6d-6,expand:16  }
endif

;if p.dflag then p.core.n = p.ntot-p.halo.n else p.ntot=p.core.n+p.halo.n
if n_params() eq 0 then return,p

theta = dat.theta
phi = dat.phi


expand=p.expand

if keyword_set(expand) then begin
  nn = dat.nenergy
  resp = el_response(dat.volts+p.v_shift,nrg2,nsteps=expand*nn)
  nb = dat.nbins
  i = replicate(1.,expand)
  nn2 = nn*expand
  energy = nrg2[*] # replicate(1.,nb)
  phi = reform(i # phi[*],nn2,nb)
  theta = reform(i # theta[*],nn2,nb)
  esteps = resp # nrg2
endif else begin
  energy = dat.energy
endelse


mass = dat.mass

a = 2./mass^2*1e5

f= eldf(energy,theta,phi,param=p.mp)

eflux = f* energy^2 * a

if keyword_set(expand) then begin          ; integrate
  eflux  = resp # eflux
  energy = resp # energy
  theta  = resp # theta
  phi    = resp # phi
endif


units = dat.units_name

case strlowcase(units) of
'df'     :  data = eflux/energy^2/a
'flux'   :  data = eflux/energy
'eflux'  :  data = eflux
else     : begin
    crate =  dat.geomfactor *dat.gf * eflux
    anode = byte((90 - dat.theta)/22.5)
    deadtime = (p.deadtime/[1.,1.,2.,4.,4.,2.,1.,1.])(anode)
    rate = crate/(1+ deadtime * crate)
    bkgrate = 0
    str_element,p,'bkgrate',bkgrate
    rate = rate + bkgrate
    case strlowcase(units) of
       'crate'  :  data = crate
       'rate'   :  data = rate
       'counts' :  data = rate * dat.dt
    endcase
    end
endcase



if keyword_set(set) then begin
  dat.data = data
  dat.energy = energy
;  dat.e_shift = p.e_shift
  dat.sc_pot = p.mp.sc_pot
  dat.vsw = p.mp.vsw
  dat.magf = p.magf
;  str_element,/add,dat,'deadtime', deadtime
endif

str_element,dat,'bins',value = bins
if n_elements(bins) gt 0 then begin
   ind = where(bins)
   data = data(ind)
endif else data = reform(data,n_elements(data),/overwrite)
if keyword_set(set) and keyword_set(bins) then begin
   w = where(bins eq 0,c)
   if (c ne 0)  and (set eq 2) then x.data[w] = !values.f_nan
endif

return,data
end

