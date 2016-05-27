;+
;FUNCTION:   get_ph2(t)
;PURPOSE:
;  Returns a 3d structure containing all data pertinent to a single pesa high
;  or pesa high burst 3d sample.  
;  See "3D_STRUCTURE" for a more complete 
;  description of the structure.
;
;INPUT:
;    t: double,  seconds since 1970. If this time is a vector then the
;       routine will get all samples in between the two times in the 
;       vector
;KEYWORDS:
;       index:          select data by sample index instead of by time.
;       times:          if non-zero, return and array of data times 
;                       corresponding to data samples.
;CREATED BY:    Art Hull
;LAST MODIFICATION:       @(#)get_ph2.pro	1.1 99/08/24
;
;NOTES: The procedure "load_3dp_data" must be 
;       called first.
;-
function get_ph2,t,index=i,times=times

common get_ph2_com, dtime,type,index,a,b,c

func=['get_ph','get_phb']
if n_elements(i) eq 0 then begin
  t0 = gettime(t)
  if keyword_set(dtime) then begin
    if t0 lt dtime[0] or t0 gt dtime[n_elements(dtime)-1] then dtime=0
  endif
endif

if keyword_set(times) or not keyword_set(dtime) then begin
   phtimes =get_ph(/time)
   phbtimes = get_phb(/time)
   nph=n_elements(phtimes)
   nphb=n_elements(phbtimes)
   type =[replicate(0,nph),replicate(1,nphb)]
   index = [lindgen(nph),lindgen(nphb)]
   dtime = [phtimes,phbtimes]
   s = sort(dtime)
   type  = type[s]
   index = index[s]
   dtime = dtime[s]
ENDIF

nt = n_elements(dtime)
if keyword_set(times) then return,dtime

if keyword_set(t0) then begin
   i = 0 > round(interp(dindgen(nt),dtime,t0)) < (nt-1)
   print,i,'  ',time_string(dtime[i]),type[i],index[i]
ENDIF


return, call_function(func[type[i]],index=index[i])

end


