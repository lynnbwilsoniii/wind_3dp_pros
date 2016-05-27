;+
;PROGRAM:	get_3dt(funct,get_dat,ERANGE=erange,BINS=bins,NAME=name)
;INPUT:	
;	funct:	function,	function that operates on structures generated 
;					by get_pl, get_el, etc.
;				e.g. "get_el"
;
;				funct   = 'n_3d','j_3d','v_3d','p_3d','t_3d',
;					  'vth_3d', or 'c_3d'
;				"n_3d"
;				"j_3d"
;				"v_3d"
;				"p_3d"
;				"t_3d"
;				"vth_3d"
;				"c_3d"
;	get_dat:function,	function that returns 3d data structures
;				function name must be "get_"+"get_dat"  
;				get_dat = 'pl' for get_pl, 
;				get_dat = 'el' for get_el, etc.
;KEYWORDS:
;	erange:	fltarr(2),	optional, min,max energy bin numbers for integration
;	bins:	bytarr(nbins),	optional, angle bins for integration, see edit3dbins.pro
;				0,1=exclude,include,  nbins = temp.nbins
;	name:	string		New name of the Data Quantity
;				Default: funct+'_'+get_dat
;       times:  dblarr(1or2)or  Specifies start time (and end time)
;               strarr(1or2)   
;       index:  lonarr(1 or 2)  Specifies starting index (and ending index)
;                               keyword time overrides keyword index
;PURPOSE:
;	To generate time series data for "tplot" 
;NOTES:	
;	Program names time series data to funct+"_"+get_dat.
;		See "tplot_names".
;
;CREATED BY:    J.McFadden
;LAST MODIFICATION:  01/05/09
;FILE:   @(#)get_3dt.pro	1.13
;-
;
; 
;LAST MODIFICATION: 06/18/2007
;  BY: Lynn B. Wilson III
;
;
function get_3dt,funct,get_dat,ERANGE=er,BINS=bins,NAME=name,SILENT=silent,$
       INDEX=index,TIMES=time,_extra=e

  if n_params() lt 2 then begin
    return,1
  endif 
  
  get_raw = 'get_'+get_dat
  times = call_function(get_raw,/times,_extra=e)
  ntimes = n_elements(times)
  if ntimes lt 1 then begin 
    print,'No data loaded'
    return,1
  endif 

;stop

  if keyword_set(index) then ind = index ;don't change keyword value
  if keyword_set(time)  then begin 
    nt = n_elements(time)
    if nt ne 1 and nt ne 2 then begin 
      message,'Keyword TIME must have (zero,) one or two elements.',/info
      return,1
    endif 
    tim = time_double(time)         ;don't change keyword value
    ind  = nn(times,tim)
    if nt eq 1 then ind = [ind,ntimes-1] 
  endif 
  maxi = long(ntimes-1)
  CASE n_elements(ind) OF 
    2: ind =  0>ind<maxi
    1: ind = [0>ind<maxi,maxi]
    0: ind = [0         ,maxi]
    else: begin 
      message,'Keyword TIME must have (zero,) one or two elements.',/info
      return,1
    end 
  endcase 

  i   = ind(0)
  raw = {valid:0}
  while raw.valid eq 0 and i lt ind(1) do begin 
    raw = call_function(get_raw,ind=i,_extra=e) ;find the first valid spec
    i = i+1
  endwhile 
  ind(0) = i                      ;the next spec we'll get

  if not keyword_set(er) then er=[0,-1]
  if (not keyword_set(bins) and raw.valid eq 1) then begin
    bins=bytarr(raw.nbins)
    bins(*)=1
  endif
  
  if (raw.valid eq 1) then begin
    sum   = call_function(funct,raw,ERANGE=er,BINS=bins)
    nargs = n_elements(sum)
    time  = dblarr(ntimes)
    data  = fltarr(ntimes,nargs)
    data(0,*) = sum
    time(0)   = (raw.time + raw.end_time)/2.
  endif else begin
    print," No Data! "
    return,1
  endelse

  
  n = 1                           ;1 because 0 was done above
  for i=ind(0),ind(1) do begin 
    raw = call_function(get_raw,index=i,_extra=e)
    if raw.valid ne 0 then begin 
      sum       = call_function(funct,raw,ERANGE=er,BINS=bins)
      data(n,*) = sum
      time(n)   = (raw.time + raw.end_time)/2.
      n = n+1
    endif 
  endfor 

      
  data = data(0:n-1,*)
  time = time(0:n-1)

  if not keyword_set(silent) then print," number of data points = ",n
  
  ytitle = funct+"_"+get_dat
  if not keyword_set(name) then name=ytitle else ytitle=name
  store_data,name,data={x:time,y:data}
  
  return,raw
end

