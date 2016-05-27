;+
;PROCEDURE:	get_padspec
;PURPOSE:
;  Creates "TPLOT" variable by summing 3D data over selected angle bins.
;
;INPUT:		data_str, a string(either 'eh','el','ph','pl','sf',or 'so' at
;		this point) telling which data to get.
;
;KEYWORDS:	bins: a keyword telling which bins to sum over
;		gap_time: time gap big enough to signify a data gap (def 200)
;		no_data: returns 1 if no_data else returns 0
;		units:	convert to these units if included
;               NAME:  New name of the Data Quantity
;               BKG:  A 3d data structure containing the background counts.
;               FLOOR:  Sets the minimum value of any data point to sqrt(bkg).
;               ETHRESH:
;               MISSING: value for bad data.
;
;CREATED BY:  Davin Larson
;FILE:  %M%
;VERSION:  %I%
;LAST MODIFICATION:  %E%
;
;NOTES:	  "LOAD_3DP_DATA" must be called first to load up WIND data.
;-

pro get_padspec,data_str,  $
  	bins=bins, $       
	gap_time=gap_time, $ 
	no_data=no_data, $
	units = units,  $
        name  = name, $
	bkg = bkg, $
        missing = missing, $
        bsource=bsource, $
        vsource=vsource, $
        ethresh=ethresh,  $
        trange=trange, $
        num_pa=num_pa,$
        floor = floor

ex_start = systime(1)

routine = 'get_'+data_str
dat = call_function(routine, t, index=0)

ytitle = data_str + '_pads'

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

if keyword_set(num_pa) eq 0 then num_pa = 8

data   = fltarr(max,nenergy,num_pa)
energy   = fltarr(max,nenergy)
pang   = fltarr(max,num_pa)

if not keyword_set(bsource) then message,'Please supply Magnetic field variable'

if not keyword_set(units) then units = 'flux'
dat=conv_units(dat,units)

count = dat.nbins
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
   if dat.valid ne 0 then begin
     if times(i) ne dat.time then print,time_to_str(dat.time),dat.time-times(i)
     if keyword_set(bkg) then   dat = sub3d(dat,bkg)
;     data(i,*) = total( dat.data(*,ind), 2)/norm
;     energy(i,*) = total( dat.energy(*,ind), 2)/count

     add_str_element,dat,'magf',reform(magf(i,*))
     if keyword_set(vsw) then begin
        add_str_element,dat,'vsw',reform(vsw(i,*))
        dat = convert_vframe(dat,/int,ethresh=ethresh)
     endif
     dat = conv_units(dat,units)
     bad = 0
     str_element,dat,'bad',value=bad
     if bad eq 0 then begin
        pad = pad(dat,NUM_PA=num_pa,BINS=bins)
        data(i,*,*) = pad.data
        pad = conv_units(pad,units)
     endif else begin
        data(i,*,*) = !values.f_nan
     endelse
     energy(i,*) = total( pad.energy, 2)/pad.nbins
     pang(i,*)   = total( pad.angles, 1)/pad.nenergy
   endif
endfor

nrgs = reform(energy(0,*))
labels = strtrim( round(nrgs) ,2)+' eV'

delta = energy - shift(energy,1,0)
w = where(delta,c)
if c eq 0 then energy = nrgs


datastr = {ytitle:ytitle,x:times,y:data,v1:energy,v2:pang,  $
    ylog:1,labels:labels,panel_size:2.}

store_data,name,data=datastr

ex_time = systime(1) - ex_start
message,string(ex_time)+' seconds execution time.',/cont,/info

return

end
