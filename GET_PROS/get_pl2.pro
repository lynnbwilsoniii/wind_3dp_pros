;+
;FUNCTION:   get_pl2(t)
;INPUT:
;    t: double,  seconds since 1970. If this time is a vector then the
;       routine will get all samples in between the two times in the 
;       vector
;KEYWORDS:
;       index:          select data by sample index instead of by time.
;       times:          if non-zero, return and array of data times 
;                       corresponding to data samples.
;PURPOSE:   returns a 3d structure containing all data pertinent to a single
;  pesa low or pesa low burst 3d sample.  See "3D_STRUCTURE" for a more complete 
;  description of the structure.
;
;CREATED BY:    Art Hull
;LAST MODIFICATION:  @(#)get_pl2.pro	1.1 99/08/24
;
;NOTES: The procedure "load_3dp_data" must be 
;       called first.
;-
function get_pl2,t,index=i,times=times

common get_pl2_com, dtime,type,index,a,b,c

func=['get_pl','get_plb']
if n_elements(i) eq 0 then begin
  t0 = gettime(t)
  if keyword_set(dtime) then begin
    if t0 lt dtime[0] or t0 gt dtime[n_elements(dtime)-1] then dtime=0
  endif
endif

if keyword_set(times) or not keyword_set(dtime) then begin
   pltimes =get_pl(/time)
   plbtimes = get_plb(/time)
   npl=n_elements(pltimes)
   nplb=n_elements(plbtimes)
   type =[replicate(0,npl),replicate(1,nplb)]
   index = [lindgen(npl),lindgen(nplb)]
   dtime = [pltimes,plbtimes]
   s = sort(dtime)
   type  = type[s]
   index = index[s]
   dtime = dtime[s]
endif
nt = n_elements(dtime)
if keyword_set(times) then return,dtime

if keyword_set(t0) then begin
   i = 0 > round(interp(dindgen(nt),dtime,t0)) < (nt-1)
   print,i,'  ',time_string(dtime[i]),type[i],index[i]
endif

return, call_function(func[type[i]],index=index[i])

end


