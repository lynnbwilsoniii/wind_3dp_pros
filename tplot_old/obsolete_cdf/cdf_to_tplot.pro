function cdf_pointers,filenames=filenames,varnames=varnames $
   ,resolution=resolution,trange=trange,verbose=verbose  $
   ,depend_0_default=depend_0_default

info = cdf_info(filenames[0])

if n_elements(varnames) eq 0 then begin
  w = where(info.vars.depend_0,nv)
  varnames = info.vars[w].name
endif
if size(/n_dimen,varnames) eq 0 then $
  vnames = strsplit(/extract,varnames,' ') else vnames=varnames
  
vnames = strfilter(info.vars.name,vnames)  
  
nv = n_elements(vnames) * keyword_set(vnames)

;print,'Variables: ',vnames
if keyword_set(verbose) then print,'Loading Variables: ',vnames 

if nv eq 0 then return,0

epoch0 = 719528.d * 24.* 3600. * 1000.  ;Jan 1, 1970
dp0 = {dataname:'', data:ptr_new(),  $
           timename:'', time:ptr_new(),  $
           valuname:'', value:ptr_new(), $
           attr:ptr_new() }

dp = replicate(dp0,nv)
if not keyword_set(depend_0_default) then depend_0_default = ''
if not keyword_set(depend_1_default) then depend_1_default = ''
;if where(info.vars.name eq 'Epoch') ge 0 then depend_0_default='Epoch'

if keyword_set(resolution) then begin

message,'Not working yet'
  tr = minmax(time_double(trange))
  dt = tr[1]-tr[0]
  n = floor(dt/resolution)
  ptrs0 = ptrarr(nv)
  ptrs1 = ptrarr(nv)
  ptrs2 = ptrarr(nv)
  

  for i=0,n_elements(filenames)-1 do  begin
    times = 0
    id = cdf_open(filenames[i])
    loadcdf2,id,'Epoch',times
    times = (times - epoch0)/1000.
    bins =  floor( (times-tr[0])/resolution )
    h = histogram(bins,min=0,max=n-1,reverse=ri)
    whn0 = where(h ne 0,count)
    for j=0,nv-1 do begin
      loadcdf2,id,vnames[j],data
      dim = size(data,/dimen)
      dim[0] = n
      if not keyword_set(ptrs0[j])  then $
        ptrs0[j] = ptr_new(make_array(value=0l,dimen=dim))
      if not keyword_set(ptrs1[j])  then $
        ptrs1[j] = ptr_new(make_array(value=0.d,dimen=dim))
      if not keyword_set(ptrs2[j]) then $
        ptrs2[j]= ptr_new(make_array(value=0.d,dimen=dim))
      for k=0,count-1 do begin
          l = whn0[k]
          ind = ri[ ri[l]: ri[l+1]-1 ]
          if n_elements(ind) ne h[l] then message ,'Histogram error'
          (*ptrs0[j])[l,*,*] = (*ptrs0[j])[l,*,*] + total(finite(data[ind,*,*]),1)
          (*ptrs1[j])[l,*,*] = (*ptrs1[j])[l,*,*] + total(data[ind,*,*],1,/nan)
          (*ptrs2[j])[l,*,*] = (*ptrs2[j])[l,*,*] + total(data[ind,*,*]^2,1,/nan)

      endfor
    endfor
    cdf_close,id
  endfor 

  for j=0,nv-1 do begin
    *ptrs1[j] = (*ptrs1[j]) / *ptrs0[j]
    *ptrs2[j] = (*ptrs2[j]) / *ptrs0[j]
    *ptrs2[j] = float( sqrt((*ptrs2[j]) - (*ptrs1[j])^2  ) )
    *ptrs1[j] = float( *ptrs1[j] )
    
  endfor
  
  timeptrs = ptrarr(n)
  timeptrs[*] = ptr_new((dindgen(n)+.5)*resolution+tr[0])
  stop

  ptr_free,ptrs0
  ptr_free,ptrs2
endif else begin
  for i=0,nv-1 do begin
  endfor
  for j=0,n_elements(filenames)-1 do  begin
    id = cdf_open(filenames[j])
    print,'Loading file: ',filenames[j]
    for i=0,nv-1 do begin
       if j eq 0 then begin
         dp[i].dataname = vnames[i]
         attr = cdf_var_atts(id,vnames[i])
         depend_0 = depend_0_default
         str_element,attr,'depend_0',depend_0
         dp[i].timename = depend_0
         dp[i].time = ptr_new(0)
         depend_1 = depend_1_default
         str_element,attr,'depend_1',depend_1
         if depend_1 eq 'cartesian' then depend_1 = ''  
         if depend_1 eq 'polar' then depend_1 = ''  
         dp[i].data = ptr_new(0)
         dp[i].valuname = depend_1
         dp[i].value = ptr_new(0)
         dp[i].attr =  ptr_new(attr)
       endif
        
       if keyword_set(dp[i].dataname) then loadcdf2,id,dp[i].dataname,*dp[i].data,/append
       if keyword_set(dp[i].timename) then loadcdf2,id,dp[i].timename,*dp[i].time,/append
       if keyword_set(dp[i].valuname) then loadcdf2,id,dp[i].valuname,*dp[i].value,/append
    endfor
    cdf_close,id
  endfor 

  for i=0,nv-1 do begin 
     if keyword_set(dp[i].timename) then $
         *(dp[i].time) = ( *(dp[i].time) - epoch0)/1000.
     attr = *dp[i].attr
     fillval = 0
     str_element,attr,'FILLVAL',fillval
     if keyword_set(fillval) then begin
        if keyword_set(verbose) then $
           print,'Nulling fill data for '+dp[i].dataname
        w = where( *dp[i].data eq fillval ,nw)
        if nw ne 0 then (*dp[i].data)[w] = !values.f_nan
     endif
  endfor
endelse

return,dp
end







function cdf_pointers2,filenames=filenames,varnames=varnames $
   ,resolution=resolution,trange=trange,verbose=verbose  $
   ,depend_0_default=depend_0_default

ts_ = systime(1)
info = cdf_info(filenames[0])

if n_elements(varnames) eq 0 then begin
  w = where(info.vars.depend_0,nv)
  varnames = info.vars[w].name
endif
if size(/n_dimen,varnames) eq 0 then $
  vnames = strsplit(/extract,varnames,' ') else vnames=varnames
  
vnames = strfilter(info.vars.name,vnames)  
  
nv = n_elements(vnames) * keyword_set(vnames)

;print,'Variables: ',vnames
if keyword_set(verbose) then print,'Loading Variables: ',vnames 

if nv eq 0 then return,0

epoch0 = 719528.d * 24.* 3600. * 1000.  ;Jan 1, 1970
dp0 = {dataname:'', n_0:-1, $
           data:ptr_new(), ddata:ptr_new(), temp:ptr_new(), count:ptr_new(), $
           depend_0:'', depend_1:'', depend_2:'', $
           attr:ptr_new() }

if not keyword_set(depend_0_default) then depend_0_default = ''
if not keyword_set(depend_1_default) then depend_1_default = ''
;if where(info.vars.name eq 'Epoch') ge 0 then depend_0_default='Epoch'

id = cdf_open(filenames[0])
depend_0 = strarr(nv)
depend_1 = strarr(nv)
for i=0,nv-1 do begin
   depend_0[i] = cdf_var_atts(id,vnames[i],'DEPEND_0',default=depend_0_default)
   depend_1[i] = cdf_var_atts(id,vnames[i],'DEPEND_1',default=depend_1_default)
   if depend_1[i] eq 'cartesian' then depend_1[i] = ''  
   if depend_1[i] eq 'polar' then depend_1[i] = ''  
endfor

dep0names = depend_0[uniq(depend_0,sort(depend_0))]

vnames2=[vnames,dep0names]
nv2 = n_elements(vnames2)
dp = replicate(dp0,nv2)
dp[0:nv-1].n_0=0

for i=0,nv2-1 do begin
   dp[i].dataname = vnames2[i]
   dp[i].data = ptr_new(0)
   dp[i].temp = ptr_new(0)
;   dp[i].count= ptr_new(0)
   attr = cdf_var_atts(id,vnames2[i])
   dp[i].attr =  ptr_new(attr)
   dp[i].depend_0 = cdf_var_atts(id,vnames2[i],'DEPEND_0',default=depend_0_default)
   dp[i].depend_1 = cdf_var_atts(id,vnames2[i],'DEPEND_1',default=depend_1_default)
   if dp[i].depend_1 eq 'cartesian' then dp[i].depend_1 = ''  
   if dp[i].depend_1 eq 'polar' then dp[i].depend_1 = ''  
endfor

cdf_close,id

wt = array_union(dp.depend_0,dp.dataname)
dp.n_0 = wt

if 0 and keyword_set(resolution) then begin
  message,'Not working yet'
endif else begin
  for j=0,n_elements(filenames)-1 do  begin
    id = cdf_open(filenames[j])
    print,'Loading file: ',filenames[j]
    for i=0,nv2-1 do begin
       loadcdf2,id,dp[i].dataname,*dp[i].temp
       fillval = cdf_var_atts(id,dp[i].dataname,'FILLVAL',default=0)
       if keyword_set(fillval) then begin
          w = where( *dp[i].temp eq fillval ,nw)
;          if keyword_set(verbose) then $
;             print,'Nulling ',nw,' data points for '+dp[i].dataname
          if nw ne 0 then (*dp[i].temp)[w] = !values.f_nan
       endif
       if strpos(strupcase(dp[i].dataname),strupcase('Epoch')) ge 0 then $
          *(dp[i].temp) = ( *(dp[i].temp) - epoch0)/1000.
       append_array,*dp[i].data,*dp[i].temp
    endfor
    cdf_close,id
  endfor   
  
endelse


ptr_free,dp.temp,dp.count,dp.ddata
dp.temp = ptr_new()
wt = dp.n_0
dp.temp = dp[wt].data
w = where(wt lt 0,nw)
if nw then dp[w].temp = ptr_new()

if keyword_set(verbose) then Message,/info,string(systime(1)-ts_)+' Seconds'

return,dp
end




pro cdf_to_tplot,format=format,filenames=filenames,finfo=finfo,  $
   trange=trange,varnames=varnames,  resolution=resolution, depend_0=depend_0, $ 
   tplot_names=tplot_names,prename=prename,verbose=verbose
   
if keyword_set(format) then $
   filenames=cdf_file_names(format,trange=trange,verbose=verbose,fileinfo=finfo)
   
printdat,filenames
   
dpall = cdf_pointers2(filenames=filenames,varnames=varnames,verbose=verbose, $
   resolution=resolution,trange=trange,depend_0=depend_0)
   
epvars = strpos(strupcase(dpall.dataname),strupcase('Epoch'))
w = where(epvars ge 0,nw)
for i=0,nw-1 do $


w = where(dpall.n_0 ge 0)

dp = dpall[w]

vnames = dp.dataname

if keyword_set(tplot_names) and (size(/n_dimen,tplot_names) eq 0) then $
  tn = strsplit(/extract,tplot_names,' ') else tn=vnames

if n_elements(tn) ne n_elements(vnames) then $
   tn = vnames

if size(prename,/type) ne 7 then prename=''

tn = prename+dp.dataname

n= n_elements(tn)

n = n_elements(dp)


for i=0,n-1 do $
      store_data,tn[i],data={x:dp[i].temp,y:dp[i].data,v:dp[i].ddata}, $
        dlim={cdf:{name:dp[i].dataname,attr:*(dp[i].attr)}}

ptr_free,dpall.attr

end

