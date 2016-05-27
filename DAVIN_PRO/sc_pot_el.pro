function sc_pot_el,elef

nrg = [1112.99, 689.161, 426.769, 264.837, 164.957, 103.320, 65.2431, 41.7663, 27.2489, 18.2895, 12.8144, 9.41315, 7.25627, 5.92896, 5.18234]
efph = [118.573, 535.125, 2771.57, 13780.8, 77791.3, 469253., 2.43850e+06, 1.00494e+07, 2.43219e+07, 4.05564e+07, 8.78649e+07, 1.45688e+08, 1.91214e+08, 2.66451e+08, 3.37626e+08]

  if elef.units_name ne 'eflux' then $
      return,sc_pot_el( conv_units(elef,'eflux') )
   
  omnidf = average(elef.data/elef.energy^2,2)
  e  = reverse(average(elef.energy,2))
  y = reverse(alog(omnidf))
  ddy = (shift(y,1)+shift(y,-1)-2*y)[1:13]
  dde = e[1:13]
  photodf = interp(alog(efph/nrg^2),nrg,dde)
  es = dgen(40,range=[4,300],/log)
  ddys = spline(dde,ddy-(y[1:13]-photodf),es)
  dummy = max(ddys,bin)
  sc_pot = es[bin]

return,sc_pot

end

; pot1 = sc_pot_el(dat)
; oplot,pot1*[1,1], !y.type ? 10^!y.crange : !y.crange
; np = data_cut('Np',dat.time)
; pot2 = sc_pot(np)
; oplot,pot2*[1,1], !y.type ? 10^!y.crange : !y.crange
; 
