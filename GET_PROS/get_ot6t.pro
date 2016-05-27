;+
;FUNCTION:   get_ot6t
;INPUT:
;    t: double,  seconds since 1970. If this time is a vector than the
;   routine will get all samples in between the two times in the 
;   vector
;KEYWORDS:
;   advance:
;PURPOSE:  
;	 for omniazimuuth average flux if electrons, for survey plots
;	from SST open+thick 3d data 
;	data from 402x packets
;	produces array (OT6) for tplot
;
;CREATED BY:    Robert D. Campbell
;FILENAME:  get_ot6t.pro
;VERSION:   1.2
;LAST MODIFICATION: 95/10/06
;
;NOTES: The procedure "load_3dp_data" must be 
;   called first.
;-
pro get_ot6t

n = 0
max = 14400
units='flux'
t = 1
dat = get_sot(t)
   dat=conv_units(dat,units)
   last_time = dat.time
ti = dat.integ_t
ytitle = 'Open+Thick flux'
ytitle = ytitle+'!C'+string(dat.energy(0,8)-dat.denergy(0,8)/2)+' -'+ $ 
                string(dat.energy(8,8)+dat.denergy(8,8)/2)+' eV'
nenergy = dat.nenergy

time   = dblarr(max)
data   = fltarr(max,9)
energy   = fltarr(max,nenergy)

count = dat.nbins
if n_elements(bins) eq 0 then ind=indgen(dat.nbins) else ind=where(bins,count)
if count ne dat.nbins then ytitle = ytitle+'  ('+strtrim(count,2)+'bins)'


while (dat.valid ne 0) and (n lt max)  do begin
   if abs(dat.time-last_time) ge 200 then begin
      time(n) = (dat.time < last_time) + 1.
      data(n,*) = 2e20
      energy(n,*) = energy(n-1,*)
      n=n+1
   endif

	dat.data(0:8,0:7) = 0. 	; zero ot2
   data(n,0:8) = total( dat.data(*,ind), 2) / 8

   energy(n,*) = total( dat.energy(*,ind), 2)/count  ; average energy
   last_time = dat.time
   time(n)   = dat.time
   t = dat.time
   reftime = t
   n=n+1
   dat = get_sot(t,/adv)
 if dat.valid then dat =conv_units(dat,units)
end

data = data(0:n-1,0:8)
energy = energy(0:n-1,0:nenergy-1)
time = time(0:n-1)
smoothspikes,time
data_str = {ytitle:ytitle,xtitle:"Time",x:time,y:data,v:energy,ytype:1,max_value:1e20}
if keyword_set(bins) eq 0 then name='otspecf' else name='otspecf*'
store_data,name,data=data_str

print_options,/land

return
end
