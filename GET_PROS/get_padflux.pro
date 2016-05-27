;+
;PROCEDURE:	get_padflux,source,symm_dir
;PURPOSE:	Calculates flux from eesa_L and mfi data.  You are expected to 
;		have loaded these already using 
;		"GET_MFI".
;INPUT:
;	source:	(string) source of 3d data (ie. 'el')
;       symm_dir: (string) handle of symmetry direction data (ie. 'Bexp')
;KEYWORDS:
;	units:	units to convert to
;	bins:	bins to sum over
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)get_padflux.pro	1.9 02/04/17
;-


pro get_padflux,data_str,bsource=bsource,tsource=tsource,vswsource=vswsource,$
  BKG = bkg,  $
  num_pa = num_pa, $
  UNITS = units,  $
  BINS = bins        ;  array of flags (size=nbins) specifying bins to sum over

if data_type(data_str) ne 7 then data_str = 'el'
if data_type(bsource) ne 7 then bsource = 'Bexp'

if keyword_set(tsource) then begin
   get_data,tsource,data=d
   ttags = d.x
endif else  ttags = get_data_time(data_str)

max = dimen1(ttags)
print,max, ' time tags'

function_name = 'get_'+data_str

if data_type(units) ne 7 then units = 'Flux'

bexp = data_cut(bsource,ttags,count=count,/interp_gap)
if count ne max  then begin
  print, 'Please supply the symmetry direction handle'
  return
endif

if keyword_set(vswsource) then  $
   vsw = data_cut(vswsource,ttags,count=count,/interp)


padname = data_str+'_pad'

symname = padname+'_sym' 
store_data,symname,data={ytitle:symname,x:ttags,y:bexp}


;help,bexp
;cart_to_sphere,bexp(*,0),bexp(*,1),bexp(*,2),bmag,bth,bph
;help,bmag,bth,bph
;print,minmax_range(bmag)
;print,minmax_range(bth)
;print,minmax_range(bph)



n = 0

t = 0             ; get first sample
dat = call_function(function_name,t)
ytitle = strupcase(data_str+' PAD')

nenergy = dat.nenergy
if not keyword_set(num_pa) then num_pa = 10

time    = dblarr(max)
flux    = fltarr(max,nenergy,num_pa)
energy  = fltarr(max,nenergy)
pang    = fltarr(max,num_pa)

nbins = dat.nbins
if n_elements(bins) eq 0 then ind=indgen(dat.nbins) else ind=where(bins,nbins)
if nbins ne dat.nbins then ytitle = ytitle+'  ('+strtrim(nbins,2)+'bins)'

while (dat.valid ne 0) and (n lt max)  do begin
   str_element,/add,dat,'magf',reform(bexp(n,*))
   if keyword_set(vsw) then begin
      str_element,/add,dat,'vsw',reform(vsw(n,*))
      dat = convert_vframe(dat,/int)
   endif
   dat = conv_units(dat,units)
bad = 0
str_element,dat,'bad',value=bad
if bad eq 0 then begin
   pad = pad(dat,NUM_PA=num_pa,BINS=bins)
   flux(n,*,*) = pad.data
   pad = conv_units(pad,units)
endif else begin
   flux(n,*,*) = !values.f_nan
endelse
   energy(n,*) = total( pad.energy, 2)/pad.nbins
   time(n)     = pad.time
   pang(n,*)   = total( pad.angles, 1)/pad.nenergy

 print,time_to_str(time(n)),ttags(n)-time(n)
   n=n+1
   dat = call_function(function_name,t,/advance)
end
flux = flux(0:n-1,*,*)
energy = energy(0,*)
pang = pang(0,*)
time = time(0:n-1)

tit = ytitle+' '+units

store_data,padname,data={ytitle:tit,x:time,y:flux,v1:energy,v2:pang,ytype:1}


return

end


