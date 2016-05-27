;PROCEDURE:	mk_elpd_cdf
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
;FILE:  mk_elpd_cdf.pro
;VERSION:  1.1
;LAST MODIFICATION:  98/02/23
;
;NOTES:	  "LOAD_3DP_DATA" must be called first to load up WIND data.
pro mk_elpd_cdf ,date  ,data_str,  $
  	bins=bins, $       
	no_data=no_data, $
	units = units,  $
        name  = name, $
	bkg = bkg, $
        missing = missing, $
        bsource=bsource, $
        vsource=vsource, $
        ethresh=ethresh,  $
        trange=trange, $
        data=d, $
        num_pa=num_pa

ex_start = systime(1)

version = '_v01'
fileformat = 'wi_elpd_3dp_'
units='flux'
bsource = 'B3'
vsource = 'Vp'
data_str = 'el'
routine = 'get_'+data_str

load_wi_sp_mfi,name=bsource,nodat=nodat

if nodat then return

get_pmom2
dat = call_function(routine, t, index=0)

nenergy =15
nenergy = dat.nenergy
nredf = 32


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

if keyword_set(num_pa) eq 0 then num_pa = 8


dat0={time:0.d,flux:fltarr(nenergy,num_pa) $
  ,energy:fltarr(nenergy),pangle:fltarr(num_pa) $
  ,integ_t:0.  $
  ,edens:0.,temp:fltarr(5)  $
  ,qp:0.,qm:0.,qt:0. $
  ,redf:fltarr(nredf) $
  ,vsw:fltarr(3),magf:fltarr(3)}

dat_bad=dat0
for i=0,n_tags(dat_bad)-1 do  dat_bad.(i) = !values.f_nan

d = replicate(dat_bad,max)

max = n_elements(times)
if max lt 2 then return

magf = data_cut(bsource,times,count=count)
if count ne max  then   message,bsource+' does not work!'

if keyword_set(vsource) then begin
  vsw = data_cut(vsource,times,count=count)
  if count ne max  then   message,vsource+' does not work!'
endif



if not keyword_set(bsource) then message,'Please supply Magnetic field variable'

if not keyword_set(units) then units = 'flux'
dat=conv_units(dat,units)

count = dat.nbins
ytitle = data_str+'pd'
if not keyword_set(bins) then ind=indgen(dat.nbins) else ind=where(bins,count)
if count ne dat.nbins then ytitle = ytitle+'_'+strtrim(count,2)
if keyword_set(name) eq 0 then name=ytitle else ytitle = name
ytitle = ytitle+' ('+units+')'

if not keyword_set(units) then units = 'counts'
if units eq 'Counts' then norm = 1 else norm = count

if not keyword_set(missing) then missing = !values.f_nan


magf = data_cut(bsource,times,count=count)
if count ne max  then   message,bsource+' does not work!'

if keyword_set(vsource) then begin
  vsw = data_cut(vsource,times,count=count)
  if count ne max  then   message,vsource+' does not work!'
endif


for i=0,max-1 do begin
   dat = call_function(routine,index=i+istart)
;   print,i,' ',time_string(dat.time)
   if dat.valid ne 0 then begin
     if times(i) ne dat.time then print,time_to_str(dat.time),dat.time-times(i)
     if keyword_set(bkg) then   dat = sub3d(dat,bkg)
     v = reform(vsw(i,*))
     m = reform(magf(i,*))
     dat = convert_vframe(dat,v,/int,ethresh=ethresh)
     dat = conv_units(dat,units)
     pd = pad(dat,magf=m,NUM_PA=num_pa,BINS=bins)
     d(i).time = dat.time
     d(i).flux = pd.data
     d(i).energy = pd.energy(*,0)
     d(i).pangles = pd.angles(0,*)
     d(i).vsw = vsw(i)
     d(i).magf = magf(i)
   endif
endfor

;nrgs = reform(energy(0,*))
;labels = strtrim( round(nrgs) ,2)+' eV'
;delta = energy - shift(energy,1,0)
;w = where(delta,c)
;if c eq 0 then energy = nrgs
;datastr = {ytitle:ytitle,x:times,y:data,v1:energy,v2:pang,  $
;    ylog:1,labels:labels,panel_size:2.}
;store_data,name,data=datastr


if not keyword_set(date) then date=d(0).time +3600. 
t = time_double(date)
t = t - t mod 86400.d
dates = strmid(time_string(t,f=2),0,8)
filename = fileformat+dates+version
w = where(d.time ge t and d.time lt (t+86400.),c)
if c ne 0 then begin
  d = d(w)
  makecdf,d,file=filename,/overwrite
  print,'file ',filename,'.cdf created'
endif else print,'No data to produce file: ',filename+'.cdf' 



ex_time = systime(1) - ex_start
message,string(ex_time)+' seconds execution time.',/cont,/info


return

end
