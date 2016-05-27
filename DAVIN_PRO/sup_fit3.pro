
function sup_fit3, energy,detector,  parameters=p 

if not keyword_set(p) then begin
;   maxw = {n:.5d,t:60d}
;   kappa= {n: .10d,vh:4000.0d,k:6.0d}
;   pow  = {h:.05d,p:-2.d}
;   p = {halo:maxw, suph:pow, bkg:0d, units:'flux'}
;   p = {halo:kappa, suph:pow, bkg:400d, units:'flux'}
    est = [2., 2.33, 2.67, 3.0, 3.33, 3.67, 4.167, 4.67, 5.0, 5.33, 5.67]
    if not keyword_set(energy) then energy = 10.^est
    p = {func:'sup_fit3',bkg:650.d , spl:splfunc(energy,1e10/energy^3,/xlog,/ylog), units:'flux'}
    return,p
endif



if n_elements(detector) eq 0 then detector = energy lt 28000.
bkg = p.bkg / energy * (detector ne 0)

flux =  splfunc(energy,param=p.spl) + bkg

case strlowcase(p.units) of
'df'   :  conv = 1/ (energy * a)
'flux' :  conv = 1
'eflux':  conv = energy
else   : message,"Units not recognized!"
endcase

f = conv * flux

return,f
end


