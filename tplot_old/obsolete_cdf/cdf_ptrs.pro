pro cdf_vatt_put,id,var,atts,prefix=prefix
  if not keyword_set(prefix) then prefix=''
  if size(/type,atts) ne 8 then return
  tags = tag_names(atts)
  ntags = n_elements(tags)
  for i=0,ntags-1 do begin
     attvalue = atts.(i)
     if size(/type,attvalue) eq 8 then $
        cdf_vatt_put,id,var,attvalue,prefix=tags[i]+'.'  $
     else  begin
       if cdf_attexists(id,prefix+tags[i]) eq 0 then $
          result = cdf_attcreate(id,prefix+tags[i],/variable)
       if size(/type,attvalue) eq 7 and size(/n_dime,attvalue) ge 1 then $
           attvalue = strjoin(attvalue,'>$<',/single)
       cdf_attput,id,prefix+tags[i],var,attvalue
     endelse
  endfor
end





function cdf_datatype,type
vartypes = 'CDF_'+strsplit('Null UCHAR INT2 INT4 FLOAT DOUBLE',' ',/extract)
vtype = vartypes[type]
return,vtype
end




pro cdf_varcreate_put,id,name,data,vtype=vtype,shift=shft, $
  rec_novary=rec_novary,numelem=numelem

nd = size(/n_dimen,data)
;if nd eq 0 then return
dim = size(/dimen,data)
if keyword_set(shft) and nd ge 2 and not keyword_set(rec_novary) then begin
   sv = shift(indgen(nd),-shft)
;printdat,sv,'sv'
   cdf_varcreate_put,id,name,transpose(data,sv),vtype=vtype, $
      rec_novary=rec_novary,numelem=numelem
   return
endif

if not keyword_set(vtype) then vtype = cdf_datatype( size(/type,data) )
vstruct = create_struct( vtype ,1)

if nd eq 0 then begin
   zid = cdf_varcreate(id,name,/zvar,/rec_novary)
   cdf_varput,id,name,data
   return
endif

nrecs =  dim[nd-1]
;help,name,data,nrecs,rec_novary,dim
;printdat,dim,'dim'

dim2 = dim[0:nd-1]
;printdat,dim2,'dim2'
if keyword_set(rec_novary) then $
  zid = cdf_varcreate(id,name,dim2,dim=dim2,_extra=vstruct,/zvar,/rec_novary,numelem=numelem) $
else begin
  if nd ge 2 then begin
     dim2 = dim[0:nd-2]
     zid = cdf_varcreate(id,name,dim2,dim=dim2,_extra=vstruct,$
        /zvar,alloc=nrecs,rec_novary=rec_novary)
  endif else begin
     zid = cdf_varcreate(id,name,_extra=vstruct,$
        /zvar,alloc=nrecs,rec_novary=rec_novary)
  endelse
endelse

cdf_varput,id,name,data
end





pro cdf_write_ptrs,dp,filename,globalatts=globalatts,overwrite=overwrite

if not keyword_set(filename) then begin
    message, "filename must be given"
    return
endif
if keyword_set(overwrite) then begin
    if file_test(filename+'.cdf',/regular) then file_delete,filename+'.cdf'
endif
id = cdf_create(filename, /single)
epoch0 = 719528.d * 24.* 3600. * 1000.  ;Jan 1, 1970

nv = n_elements(dp) * keyword_set(dp)
for i=0,nv-1 do begin
   d = dp[i]
   if d.numelem eq 1 then begin
   print,d.name,d.numelem,' ',d.datatype
;   kwds = struct(d.vartype:1,numelem:d.numelem
;   cdf_varcreate,id,d.name.d.recvar,_extra=s
   data = *d.dataptr
   if d.datatype eq 'CDF_EPOCH' then data = data*1000 + epoch0
   if not keyword_set(d.datatype) then d.datatype = cdf_vartype( size(/type,data) )
   cdf_varcreate_put,id,d.name,data,vtype=d.datatype,$
      rec_novary=d.recvar eq 0,/shift,numelem=d.numelem
   if keyword_set(d.attrptr) then  $
       cdf_vatt_put,id,d.name,*d.attrptr
   endif
endfor

cdf_close,id

end




function cdf_ptrs,filenames=filenames,varnames=varnames $
   ,resolution=resolution,trange=trange,verbose=verbose  $
   ,format=format  $
   ,depend_0_default=depend_0_default

ts_ = systime(1)
if keyword_set(format) then $
   filenames=cdf_file_names(format,trange=trange,verbose=verbose)

info = cdf_info(filenames[0])

;if n_elements(varnames) eq 0 then begin
;  w = where(info.vars.depend_0,nv)
;  varnames = info.vars[w].name
;endif
;if size(/n_dimen,varnames) eq 0 then $
;  vnames = strsplit(/extract,varnames,' ') else vnames=varnames

;nv = n_elements(vnames) * keyword_set(vnames)

;if keyword_set(verbose) then print,'Loading Variables: ',vnames

;if nv eq 0 then return,0
epoch0 = 719528.d * 24.* 3600. * 1000.  ;Jan 1, 1970


nfiles = n_elements(filenames)

if 0 and keyword_set(resolution) then begin
  message,'Not working yet'
endif else begin
  for j=0,nfiles-1 do  begin
    print,'Loading file: ',filenames[j]
    id = cdf_open(filenames[j])
;    inq = cdf_inquire(id)
    info = cdf_info(id)
    if info.nv gt 0 then begin
     if not keyword_set(dp) then begin
        w = where(info.vars.recvar)
        dp = info.vars[w]
        nv = n_elements(dp)
        if keyword_set(verbose) then print,'Loading Variables: ',dp.name
     endif
     last_depend = ''
     nv2 = nv < info.nv
     for i=0,nv2-1 do begin
       cdfname = dp[i].varname
;       if keyword_set(verbose) and j eq 0 then print,'Loading ',cdfname

       if not keyword_set(dp[i].attrptr) then $
          dp[i].attrptr = ptr_new(cdf_var_atts(id,cdfname) )

       loadcdf3,id,cdfname,temp,numrec=numrec

       fillval = cdf_var_atts(id,cdfname,'FILLVAL',default=0)
       if keyword_set(fillval) then begin
          w = where( temp eq fillval ,nw)
          if keyword_set(verbose) and nw ne 0 then $
             print,'Nulling ',nw,' data points for '+cdfname
          if nw ne 0 then temp[w] = !values.f_nan
       endif
       if dp[i].datatype eq 'CDF_EPOCH' then $
          temp = (temp - epoch0)/1000.
       if keyword_set(resolution) and dp[i].recvar then begin
          depend = struct_value(*dp[i].attrptr,'depend_0',def='Epoch')
          if depend ne last_depend then begin
             loadcdf3,id,depend,time
             time = (time - epoch0)/1000.
             last_depend=depend
          endif
          temp = time_average(time,temp,resolution=resolution,trange=trvalid)
          numrec = dimen1(temp)
 ;print
 ;help,cdfname,depend,time,numrec,temp

       endif
       if keyword_set(dp[i].dataptr) then begin
           if  dp[i].recvar then begin
              dp[i].numrec = dp[i].numrec + numrec
              *dp[i].dataptr = [*dp[i].dataptr,temp]
           endif else if array_equal( *dp[i].dataptr, temp ) eq 0 then begin
              message,/info,'data mismatch'
              printdat,*dp[i].dataptr
              printdat,temp
           endif
       endif else dp[i].dataptr = ptr_new(temp,/no_copy)
       if j eq nfiles-1 then $
          if dp[i].recvar then dp[i].d = size(/dimen,*dp[i].dataptr)
     endfor
    endif
    cdf_close,id
  endfor

endelse


if keyword_set(verbose) then Message,/info,string(systime(1)-ts_)+' Seconds'

return,dp
end



