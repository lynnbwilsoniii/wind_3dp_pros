;PROCEDURE:	mk_el3d_cdf
;PURPOSE:
;
;  Creates "TPLOT" variable by summing 3D data over selected angle bins.
;
;INPUT:		data_str, a string(either 'eh','el','ph','pl','sf',or 'so' at
;		this point) telling which data to get.
;
;KEYWORDS:	bins: a keyword telling which bins to sum over
;		no_data: returns 1 if no_data else returns 0
;		units:	convert to these units if included
;               NAME:  New name of the Data Quantity
;               BKG:  A 3d data structure containing the background counts.
;               FLOOR:  Sets the minimum value of any data point to sqrt(bkg).
;               ETHRESH:
;               MISSING: value for bad data.
;
;CREATED BY:  Davin Larson
;FILE:  mk_el3d_cdf.pro
;VERSION:  1.1
;LAST MODIFICATION:  98/02/23
;
;NOTES:	  "LOAD_3DP_DATA" must be called first to load up WIND data.
pro mk_el3d_cdf ,date  ,data_str,  $
  	bins=bins, $       
	no_data=no_data, $
	units = units,  $
        name  = name, $
	bkg = bkg, $
	filename=filename, $
        missing = missing, $
        bsource=bsource, $
        vsource=vsource, $
        ethresh=ethresh,  $
        trange=trange, $
        data=d, $
        nbins=nbins

ex_start = systime(1)

version = '_v01'
fileformat = 'wi_el3d_3dp_'
units='df'
bsource = 'wi_B3'
vsource = 'Vp'
data_str = 'el'
routine = 'get_'+data_str

;load_wi_sp_mfi,name=bsource,nodat=nodat
;if nodat then return

;get_pmom2

dat = call_function(routine, t, index=0)

nenergy =15
nenergy = dat.nenergy


times = call_function(routine,/times)
max = n_elements(times)
istart = 0
if keyword_set(trange) then begin
   irange = fix(interp(findgen(max),times,gettime(trange)))
   print,irange
   irange = (irange < (max-1)) > 0
   irange = minmax_range(irange)
   istart = irange(0)
   times = times(istart:irange(1))
   print,'Index range: ',irange
   max = n_elements(times)
endif

nbins = dat.nbins

nan = !values.f_nan
dat0={time:0.d,data:replicate(nan,nenergy,nbins) $
  ,energy:replicate(nan,nenergy) $
  ,vsw:replicate(nan,3),magf:replicate(nan,3),quality:0}

novar={theta:dat.theta,  phi:dat.phi} 

d = replicate(dat0,max)


max = n_elements(times)
if max lt 2 then return

magf = data_cut(bsource,times,count=count)
if count ne max  then   message,bsource+' does not work!'

if keyword_set(vsource) then begin
  vsw = data_cut(vsource,times,count=count)
  if count ne max  then   message,vsource+' does not work!'
endif



for i=0,max-1 do begin
   dat = call_function(routine,index=i+istart)
;   print,i,' ',time_string(dat.time)
   if times(i) ne dat.time then print,i,' ',time_to_str(dat.time),dat.time-times(i)
;     if keyword_set(bkg) then   dat = sub3d(dat,bkg)
   dat = conv_units(dat,units)
   d(i).time = dat.time
   d(i).data = dat.data
   d(i).energy = dat.energy(*,0)
   d(i).vsw = reform(vsw(i,*))
   d(i).magf = reform(magf(i,*))
   d[i].quality = dat.valid
endfor

if not keyword_set(filename) then begin 
  if not keyword_set(date) then date=d(0).time +3600. 
  t = time_double(date)
  t = t - t mod 86400.d
  dates = time_string(t,f=2,/date)
  filename = fileformat+dates+version
endif

if keyword_set(date) then begin
  w = where(d.time ge t and d.time lt (t+86400.),c)
  if c ne 0 then  d = d(w)
endif


makecdf,d,file=filename,/overwrite,datanovar=novar
print,'file ',filename,'.cdf created'


ex_time = systime(1) - ex_start
message,string(ex_time)+' seconds execution time.',/cont,/info


return

end
