pro tslope,handle

get_data,handle,data=d

energy = d.v
flux   = d.y
time   = d.x

nd = n_elements(time)
if ndimen(energy) ne 2 then energy =replicate(1.,nd) # energy
df = flux / energy

for i=0,nd-1 do begin
  f = reform(df(i,*))
  e = reform(energy(i,*))
  ddf = deriv(e,alog(f)) * e
  d.y(i,*) = ddf
endfor

  

store_data,'dlog_'+handle,data=d,dlim={spec:1,zlog:1,ystyle:1,ylog:1}
end
