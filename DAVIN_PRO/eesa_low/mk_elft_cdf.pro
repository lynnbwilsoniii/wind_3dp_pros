
;PROCEDURE:	mk_elft_cdf
;PURPOSE:
;
;  Creates "TPLOT" variable by summing 3D data over selected angle bins.
;   Version 1.5 is redesigned to accept the new code involving get_el
;  and convert_esa_units.
;INPUT:		data_str, a string(either 'eh','el','ph','pl','sf',or 'so' at
;		this point) telling which data to get.
;
;KEYWORDS:	bins: a keyword telling which bins to sum over
;		units:	convert to these units if included
;               NAME:  New name of the Data Quantity
;               BKG:  A 3d data structure containing the background counts.
;               FLOOR:  Sets the minimum value of any data point to sqrt(bkg).
;               ETHRESH:
;               MISSING: value for bad data.
;
;CREATED BY:  Davin Larson
;FILE:  mk_elpd_cdf.pro
;VERSION:  1.5
;LAST MODIFICATION:  97/02/26
;
;NOTES:	  "LOAD_3DP_DATA" must be called first to load up WIND data.
;	  also, fit must be run before use.
pro mk_elft_cdf ,date  ,data_str,  $
;  	bins=bins, $  
        alldat=alldat, $   
        olddat=olddat, $  
        stimes=stimes, $
	units = units,  $
        name  = name, $
	bkg = bkg, $
        bsource=bsource, $
        vsource=vsource, $
        ethresh=ethresh,  $
        elbins = elbins,  $
        noload = noload, $
        lim = lim, $
        trange=trange, $
        data=d, $
	no3s_mag = no3s_mag, $
        num_pa=num_pa, $
	debug2 = debug2, $
	chi_lim = chi_lim, $
	opts = opts, $
	silent = silent

ex_start = systime(1)

version = '_v04'
fileformat = 'wi_elft_3dp_'
if not keyword_set(units) then units = 'flux'
bsource = 'wi_B3'
vsource = 'Vp'
npsource ='PL.MOM.P.DENSITY'
data_str = 'el'
routine = 'get_'+data_str


if not keyword_set(opts)   then begin
  xlim,lim,4,2000,1
  units,lim,'rate' & ylim,lim,10,2e6,1
  units,lim,'df' & ylim,lim,1e-16,1e-7,1
  units,lim,'eflux' & ylim,lim,3e4,3e9,1
  units,alim,'df' & ylim,alim,1e-16,1e-7,1
  options,alim,'psym',1
  options,lim,'a_color' ,'theta'
  options,lim,'a_color' ,'pitchangle'
  options,lim,'a_color' ,'sundir'
  options,alim,'a_color' ,'sundir'
  options,alim,'a_color' ,'phi'
  bins2 = bytarr(15,88)
  bins2[*,[0,1,4,5,22,23,26,27,44,45,48,49,66,67,70,71]] = 1
  options,lim,'bins',bins2
  options,alim,'bins',bins2
  options,opts,'limits',lim
  options,opts,'alimits',alim
  options,opts,'emin' ,6.
  options,opts,'emax' ,2000.
  options,opts,'dfmin' ,0.
  options,opts,'bins' ,replicate(1b,15,88)
  
  options,opts,'names','core sc_pot e_shift
  options,opts,'names','core sc_pot
  options,opts,'names','core halo.n halo.vth halo.v sc_pot e_shift
  options,opts,'names','core sc_pot halo v_shift
  options,opts,'names','core sc_pot e_shift deadtime halo
  options,opts,'names','photo core sc_pot e_shift deadtime halo
;  options,opts,'noload',0
  options,opts,'display',1
  options,opts,'do_fit',1
  options,opts,'names','core sc_pot halo
  printdat,opts
  
endif


; ********* get magnetic field and particle data ************
str_element,opts,'noload',noload
if not keyword_set(noload) then begin
nodat = 0
if keyword_set(no3s_mag) then begin
   load_wi_mfi
   bsource = 'wi_B'
   nodat = 0
endif else load_wi_sp_mfi,name=bsource,nodat=nodat
load_wi_swe,/pol
get_pmom2
if nodat then return
endif
; ***********************************************************

times = call_function(routine,/times)
if ndimen(times) le 0 then begin
   message,/info,'No electron data to produce cdf file'
   return
endif
max = n_elements(times)
indices = lindgen(max)

message,/info,string(max) +' Time samples'

if keyword_set(trange) then begin
  w = where((times le trange[1]) and (times ge trange[0]),max)
  if max eq 0 then message,'No data in that time range'
  indices = indices[w]
  times = times[indices]
endif else trange = minmax_range(times)

if keyword_set(stimes) then begin
  indices = round(interp( findgen(max),times[indices],stimes) )
  times = times[indices]
endif
max = n_elements(times)

message,/info,string(max) +' Time samples'

if keyword_set(num_pa) eq 0 then num_pa = 8


if not keyword_set(bsource) then message,'Please supply Magnetic field variable'

magf = data_cut(bsource,times,count=count,/interp)
if count ne max  then   message,bsource+' does not work!',/info

if keyword_set(vsource) then begin
  vsw = data_cut(vsource,times,count=count,/interp)
  if count ne max  then   message,vsource+' does not work!',/info
endif

if keyword_set(npsource) then begin
  nproton=data_cut(npsource,times,count=count,/interp)
  if count ne max then message,npsource+' does not work!',/info
endif

nswe = data_cut('wi_swe_Np',times,/interp)
nwav = data_cut('wi_wav_Ne',times,/interp)


if not keyword_set(units) then units = 'flux'
ethresh = 500.


ind=n_elements(alldat)

if ind ge 2 then begin
   s = sort(alldat.time)
   olddat = alldat[s]
   old_inds = round( interp(findgen(ind),olddat.time,times) )
   old_inds = 0 > old_inds < (ind-1)
   w = where(abs(times-olddat[old_inds].time) gt 2.5,c)
   if c ne 0 then old_inds[w] = -1
   help,where(old_inds ne -1,c)
   print,c,'starting points'
   dat0 = alldat[0]
endif else begin
   old_inds = replicate(-1,n_elements(times))
   alldat=0
   ind = 0
endelse

fitnames = opts.names
fitnames = ['core sc_pot', $ 
            'core.t core.tdif sc_pot', $
            'core sc_pot', $
            'core', $
            'core halo sc_pot' ]
wait = 1
do_fit=1

for i=0l,max-1 do begin
   dat = call_function(routine,index=indices[i])
   print, '========================= ',time_string(dat.time),' ============',i,'/',max,'=================='
   if dat.valid eq 0 then goto,next
   if times(i) ne dat.time then print,time_string(dat.time),dat.time-times(i)
   if not keyword_set(evalues) then evalues = average(dat.energy,2)
timebar,dat.time 
   dat.vsw  = reform(vsw(i,*))
   dat.magf = reform(magf(i,*))
   np = nproton[i]

   old_i = old_inds[i]
   if old_i ge 0 then fit = olddat[old_i].fit
   if old_i ge 0 then em  = olddat[old_i].em
   
   pot = sc_pot(np)
   em = moments_3d(dat,format=em,sc_pot=pot)


if do_fit then begin
;  fit.sc_pot = em.sc_pot
;  fit.core.n = em.density ;-fit.halo.n
;  fit.core.t = em.avgtemp

  opts.names='core.n core.t'
  fit = fitel3d(dat,options=opts,guess=fit,fdat=fdat,chi2=chi2)

  opts.names='core'
  fit = fitel3d(dat,options=opts,guess=fit,fdat=fdat,chi2=chi2)

  opts.names='core halo.n halo.vth'
  fit = fitel3d(dat,options=opts,guess=fit,fdat=fdat,chi2=chi2)

  opts.names='core halo.n halo.vth halo.v'
  fit = fitel3d(dat,options=opts,guess=fit,fdat=fdat,chi2=chi2)

  opts.names='core halo sc_pot'
  fit = fitel3d(dat,options=opts,guess=fit,fdat=fdat,chi2=chi2)

endif
   
   if not keyword_set(fit0) then fit0=fit

   if wait then print,'Press key to continue'
   key = get_kbrd(wait)
   help,key,wait
   case key of
;     'q':   goto,quit
     's':   stop
     else:
   endcase
   ok=1

   dfi = convert_vframe(dat,/int,ethresh=ethresh,evalues=evalues)
   dfi = conv_units(dfi,units)
   pd = pad(dfi,NUM_PA=num_pa)
   
   d={time:dat.time  $
       ,valid:ok $
       ,flux:pd.data $
       ,energy:evalues,pangle:pd.angles $
       ,em:em  $
       ,vsw:dat.vsw,magf:dat.magf  $
       ,np:np ,nswe:nswe[i], nwav:nwav[i] $
       ,fit:fit,  chi2:chi2 }

if debug() eq 2 then stop

   if not keyword_set(dat0) then dat0 = d
   struct_assign,d,dat0
   
   if old_i ge 0 then alldat[old_i]= dat0 $
   else append_array,alldat,dat0,index=ind

   lastfit=fit
   
   next:
endfor
quit:
append_array,alldat,index=ind,/done

s = sort(alldat.time)
alldat = alldat[s]

t = average(alldat.time)
t = t - t mod 86400.d
datestr = time_string(t,/date,format=2)

save,alldat,file='elft_c'+datestr+'.sav'


store_data,'el2',data=alldat

;t = time_double(date)

;t = t - t mod 86400.d

;dates = strmid(time_string(t,f=2),0,8)
;filename = fileformat+dates+version
;w = where(d.time ge t and d.time lt (t+86400.),c)
;if c ne 0 then begin
;  d = d(w)
;  makecdf,d(w),file=filename,/overwrite
;  print,'file ',filename,'.cdf created'
;  print, ' '
;endif else print,'No data to produce file: ',filename+'.cdf' 



ex_time = systime(1) - ex_start
message,string(ex_time)+' seconds execution time.',/cont,/info

return

end

