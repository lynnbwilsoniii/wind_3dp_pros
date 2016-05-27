function get_sf2,t,index=i,times=times

common get_sf2_com, dtime,type,index,a,b,c

func=['get_sf','get_sfb']
if n_elements(i) eq 0 then begin
  t0 = gettime(t)
  if keyword_set(dtime) then begin
    if t0 lt dtime[0] or t0 gt dtime[n_elements(dtime)-1] then dtime=0
  endif
endif

if keyword_set(times) or not keyword_set(dtime) then begin
   eltimes =get_sf(/time)
   ebtimes = get_sfb(/time)
   nel=n_elements(eltimes)
   neb=n_elements(ebtimes)
   type =[replicate(0,nel),replicate(1,neb)]
   index = [lindgen(nel),lindgen(neb)]
   dtime = [eltimes,ebtimes]
   s = sort(dtime)
   type  = type[s]
   index = index[s]
   dtime = dtime[s]
endif
nt = n_elements(dtime)
if keyword_set(times) then return,dtime

if keyword_set(t0) then begin
   i = round(interp(dindgen(nt),dtime,t0))
   print,i,'  ',time_string(dtime[i]),type[i],index[i]
endif

return, call_function(func[type[i]],index=index[i])

end


