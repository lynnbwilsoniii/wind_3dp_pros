pro get_elhres,trange=trange

times = get_el2(/times)

if keyword_set(trange) then $
   wi = where(times le trange[1] and times ge trange[0],n) $
else wi = where(finite(times),n)


el = get_el2(index=wi[0])

period = 3.0
;tshift = (360-el.phi-45.) mod 360. *period

b0 = [11, 12, 15, 16, 33, 34, 37, 38, 55, 56, 59, 60, 77, 78, 81, 82]
b1 = [0, 1, 4, 5, 22, 23, 26, 27, 44, 45, 48, 49, 66, 67, 70, 71]
estep = 10
b2 = [61,62,84,83,79,80,36,35,39,40,18,17,13,14,58,57]
b3 = [59,60,82,81,77,78,34,33,37,38,16,15,11,12,56,55]
b4 = [48,49,71,70,66,67,23,22,26,27, 5, 4, 0, 1,45,44]
b5 = [50,51,73,72,68,69,25,24,28,29, 7, 6, 2, 3,47,46]
b = b4
ph = reform(el.phi[estep,b])
tshift = (360-ph)/360 *period
tshift = findgen(16)/16 * period

allds2 = fltarr(n*16,15)
allds3 = fltarr(n*16,15)
allds4 = fltarr(n*16,15)
allds5 = fltarr(n*16,15)
allts = dblarr(n*16)
units = 'df'

for i=0l,n-1 do begin
  el = get_el2(index=wi[i])
  el = conv_units(el,units)
    
  allds2[i*16:i*16+15,*] = transpose(el.data[*,b2])
  allds3[i*16:i*16+15,*] = transpose(el.data[*,b3])
  allds4[i*16:i*16+15,*] = transpose(el.data[*,b4])
  allds5[i*16:i*16+15,*] = transpose(el.data[*,b5])
  allts[i*16:i*16+15] = el.time + tshift

endfor

store_data,'el_hres2',data={x:allts,y:allds2}
store_data,'el_hres3',data={x:allts,y:allds3}
store_data,'el_hres4',data={x:allts,y:allds4}
store_data,'el_hres5',data={x:allts,y:allds5}


end





