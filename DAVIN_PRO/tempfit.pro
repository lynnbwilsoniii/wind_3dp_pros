

function tempfit, energy,  $
    parameters=p,  p_names = p_names, pder_values= pder_values

if not keyword_set(p) then $
   p = {tempfit_param,n1:10.0d, t1:10.0d, n2:.1d, t2:70.0d, $
   n3:.005d, t3:1000.d,units:'df'}

mass = 5.6856593e-06
k = (mass/2/!dpi)^1.5 
a = 2./mass^2*1e5

case strlowcase(p.units) of
'df'   :  conv = k
'flux' :  conv = k * energy * a
'eflux':  conv = k * energy^2 * a
else   : message,"Units not recognized!"
endcase

e1 = p.t1 ^ (-1.5) * exp(- energy/p.t1)
e2 = p.t2 ^ (-1.5) * exp(- energy/p.t2)
e3 = p.t3 ^ (-1.5) * exp(- energy/p.t3)

f = conv * (p.n1 * e1 + p.n2 * e2 + p.n3 * e3 )

if keyword_set(p_names) then begin
   np = n_elements(p_names)
   nd = n_elements(f)
   pder_values = dblarr(nd,np)
   for i=0,np-1 do begin
      case strlowcase(p_names[i]) of
          'n1': pder_values(*,i) = conv * e1
          'n2': pder_values(*,i) = conv * e2
          'n3': pder_values(*,i) = conv * e3
          't1': pder_values(*,i) = conv*p.n1*(energy/p.t1 -1.5)*e1/p.t1
          't2': pder_values(*,i) = conv*p.n2*(energy/p.t2 -1.5)*e2/p.t2
          't3': pder_values(*,i) = conv*p.n3*(energy/p.t3 -1.5)*e3/p.t3
      endcase
   endfor
endif

return,f
end


