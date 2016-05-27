;+
;FUNCTION:   get_el2(t)
;INPUT:
;    t: double,  seconds since 1970. If this time is a vector then the
;       routine will get all samples in between the two times in the 
;       vector
;KEYWORDS:
;       index:          select data by sample index instead of by time.
;       times:          if non-zero, return an array of data times 
;                       corresponding to data samples.
;PURPOSE:   returns a 3d structure containing all data pertinent to a single
;  eesa low or eesa low burst 3d sample.  See "3D_STRUCTURE" for a more complete 
;  description of the structure.
;
;CREATED BY:    Art Hull
;LAST MODIFIED: @(#)get_el2.pro	1.1 99/08/24
;
;NOTES: The procedure "load_3dp_data" must be 
;       called first.
;-

function get_el2,t,index=i,times=times,advance=adv

common get_el2_com, dtime,type,index,a,b,c

func=['get_el','get_elb']

if keyword_set(adv) then al=adv else al=0

if n_elements(i) eq 0 then begin
  t0 = gettime(t[0])
  if keyword_set(dtime) then begin
    if t0 lt dtime[0] or t0 gt dtime[n_elements(dtime)-1] then dtime=0
  endif
endif

if keyword_set(times) or not keyword_set(dtime) then begin
   eltimes =get_el(/time,advance=al)
   ebtimes = get_elb(/time,advance=al)
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
;stop

nt = n_elements(dtime)
if keyword_set(times) then return,dtime

if keyword_set(t0) then begin
   i = 0 > round(interp(dindgen(nt),dtime,t0)) < (nt-1)
;   i = round(interp(dindgen(nt),dtime,t0))
   print,i,'  ',time_string(dtime[i]),type[i],index[i]
endif

return, call_function(func[type[i]],index=index[i])

end
