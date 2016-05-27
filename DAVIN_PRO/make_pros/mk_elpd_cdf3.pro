;+
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
;VERSION:  1.15
;LAST MODIFICATION:  99/10/18
;
;NOTES:	  "LOAD_3DP_DATA" must be called first to load up WIND data.
;-
pro mk_elpd_cdf3 ,date  ,data_str,  $
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
        num_pa=num_pa, $
        opts = opts

ex_start = systime(1)
forward_function elfit

do_fit=0
version = '_v03'
if keyword_set(do_fit) then version = '_v03'
fileformat = 'wi_elpd_3dp_'
units='flux'
bsource = 'wi_B3'
if not keyword_set(vsource) then vsource = 'pm.VELOCITY'
data_str = 'el'
routine = 'get_'+data_str

str_element,opts,'mfi',mfi

case (mfi) of
	2: begin
		load_hkp_mfi
		version = '_v00'
		nodat = 0
        end
        1: begin
                load_wi_mfi
                get_data,'wi_B',ptr=pdata
                store_data,'wi_B3',data=pdata
                version ='_v01'
                nodat = 0
        end
  else: begin
        load_wi_h0_mfi,name=bsource,nodat=nodat
        version ='_v02'
  end
endcase

if nodat then return

get_moment3d,/proton

times = call_function(routine,/times)
if ndimen(times) le 0 then begin
   message,/info,'No electron data to produce cdf file'
   return
endif
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

i=-1
repeat begin
	i = i+1
	dat = call_function(routine, t, index=i)
endrep until (dat.valid eq 1) or (i eq max-1)

nenergy = dat.nenergy
nredf = 32

if keyword_set(num_pa) eq 0 then num_pa = 15


dat0={time:0.d,flux:fltarr(nenergy,num_pa) $
  ,energy:fltarr(nenergy),pangle:fltarr(num_pa) $
  ,integ_t:0.  $
  ,edens:0.,temp:fltarr(5)  $
  ,qp:0.,qm:0.,qt:0. $
  ,redf:fltarr(nredf) $
  ,vsw:fltarr(3),magf:fltarr(3)}

if keyword_set(do_fit) then begin
   foo = elfit(par=p)
   pnames = ['DENS_CORE','TEMP_CORE','TDIF_CORE','VEL_CORE',  $
             'DENS_HALO','VTH_HALO','SC_POT']
   p.sc_pot = 4
   p.dens_halo = .1
   p0=p
   pnames = tag_names(p)
   for i=0,n_elements(pnames)-1 do add_str_element,dat0,pnames(i),0.
endif



dat_bad=dat0
for i=0,n_tags(dat_bad)-1 do  dat_bad.(i) = !values.f_nan

d = replicate(dat_bad,max)

max = n_elements(times)
if max lt 2 then return

magf = data_cut(bsource,times,count=count)
if count ne max  then   message,bsource+' does not work!',/info

if keyword_set(vsource) then begin
  vsw = data_cut(vsource,times,count=count)
  if count ne max  then   message,vsource+' does not work!',/info
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
   d(i).time = dat.time
;   print,i,' ',time_string(dat.time)
   if dat.valid ne 0 then begin
     if times(i) ne dat.time then print,time_string(dat.time),dat.time-times(i)
     if keyword_set(bkg) then   dat = sub3d(dat,bkg)
     v = reform(vsw(i,*))
     m = reform(magf(i,*))
     df = convert_vframe(dat,v,/int,ethresh=ethresh)
     df = conv_units(df,units)
     pd = pad(df,magf=m,NUM_PA=num_pa,BINS=bins)
;     d(i).time = df.time
     d(i).flux = pd.data
     d(i).energy = pd.energy(*,0)
     d(i).pangle = pd.angles(0,*)
     d(i).vsw = v
     d(i).magf = m
     if keyword_set(do_fit) then begin
        add_str_element,dat,'bins',bytarr(15,88)
        add_str_element,dat,'magf',m
        add_str_element,dat,'vsw',v
        dat.bins = dat.energy lt 300. and dat.energy gt 7.
        dt = dat.data(where(dat.bins))
        ddt = sqrt((.03*dt)^2+ (dt+2.))
print,time_string(dat.time)
        foo = fitfunc(dat,dt,dy=ddt,func='elfit',p_nam=pnames,/nod,par=p)
breakpt
        xfer_parameters,p,tag_names(p),parray,/struct_to_array
        temp_d = d(i)
        xfer_parameters,temp_d,tag_names(p),parray,/array_to_struct
        d(i) = temp_d
     endif
   endif
   
endfor


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
