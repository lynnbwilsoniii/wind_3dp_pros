pro cdf_vatt_put_tplot_to_cdf,id,var,atts,prefix=prefix
  if not keyword_set(prefix) then prefix=''
  if size(/type,atts) ne 8 then return
  tags = tag_names(atts)
  ntags = n_elements(tags)
  for i=0,ntags-1 do begin
     if size(/type,atts.(i)) eq 8 then $
        cdf_vatt_put_tplot_to_cdf,id,var,atts.(i),prefix=tags[i]+'.'  $
     else  begin
       if cdf_attexists(id,prefix+tags[i]) eq 0 then $
          result = cdf_attcreate(id,prefix+tags[i],/variable)
       cdf_attput,id,prefix+tags[i],var,atts.(i)
     endelse
  endfor
end

pro cdf_varcreate_put_tplot_to_cdf,id,name,data,vtype=vtype,shift=shft,rec_novary=rec_novary

nd = size(/n_dimen,data)
if nd eq 0 then return
dim = size(/dimen,data)
if keyword_set(shft) and nd ge 2 and not keyword_set(rec_novary) then begin
   sv = shift(indgen(nd),-shft)
;printdat,sv,'sv'
   cdf_varcreate_put_tplot_to_cdf,id,name,transpose(data,sv),vtype=vtype,rec_novary=rec_novary
   return
endif

vartypes = 'CDF_'+strsplit('Null UCHAR INT2 INT4 FLOAT DOUBLE',' ',/extract)
if not keyword_set(vtype) then vtype = vartypes[size(/type,data)]
vstruct = create_struct(vtype,1)
nrecs = dim[nd-1]
;help,name,data,nrecs,rec_novary,dim
;printdat,dim,'dim'

dim2 = dim[0:nd-1]
;printdat,dim2,'dim2'
if keyword_set(rec_novary) then $
  zid = cdf_varcreate(id,name,dim2,dim=dim2,_extra=vstruct,/zvar,/rec_novary) $
else begin
  if nd ge 2 then begin
     dim2 = dim[0:nd-2]
     zid = cdf_varcreate(id,name,dim2,dim=dim2,_extra=vstruct,/zvar,alloc=nrecs,rec_novary=rec_novary)
  endif else begin
     zid = cdf_varcreate(id,name,_extra=vstruct,/zvar,alloc=nrecs,rec_novary=rec_novary)
  endelse
endelse

cdf_varput,id,name,data
end




;write_cdf_ptrs,filename=filename,




pro tplot_to_cdf,vars,filename=filename, trange=trange, resolution=res, $
    overwrite=overwrite,verbose=verbose,days=day
    
if not keyword_set(filename) then begin
    message, "keyword 'filename' must be set"
    return
endif

fname=filename


if keyword_set(overwrite) then begin
  on_ioerror, create
  id = cdf_open(fname)
  cdf_delete,id
  create:
  on_ioerror,null
endif

;if keyword_set(trange) then print,time_string(trange)
if keyword_set(resolution) then print,'resolution=',res

names=tnames(vars,/all)
ntags = n_elements(names)
if ntags eq 0 then begin
  message,/info,'No data!'
  return
endif

if not keyword_set(noclobber) and file_test(fname) then  file_delete,fname
id = cdf_create(fname, /single, /clobber)

att0 = {depend_0: 'Epoch'}


printdat,names
for n=0,ntags-1 do begin
   name = names[n]
   if keyword_set(verbose) then print,name
   att = 0
   get_data,name,time,data,values,dlim=dlim
   if not keyword_set(time) or not keyword_set(data) then begin
      message,/info,"No data found for: '"+name+"'"
      continue
   endif
   cdf = struct_value(dlim,'cdf')
   val_vary = size(/n_dimen,data) eq size(/n_dimen,values)
   if not keyword_set(cdf) then begin    ; Define minimum requirements.
       cdfname = name
       atts ={depend_0:'Epoch'}
       if keyword_set(values) then str_element,/add,atts,'depend_1',cdfname+'_v'
       cdf = {name:cdfname,atts:atts}
   endif
print,name,val_vary,att
   if keyword_set(day) and not keyword_set(trange) then $
      trange=(round(average(time,/nan)/86400d -day/2.)+[0,day])*86400d
   ndata=time_average(time,data,newtime=ntime,trange=trange,resolu=res)
   if val_vary then $
        nvalues= time_average(time,values,trange=trange,resolu=res) $
   else nvalues=values
      
   if not keyword_set(time0) then begin
      time0=ntime
      cdf_varcreate_put_tplot_to_cdf,id,'unix_time',time0
      epoch0 = 719528.d * 24.* 3600. * 1000.      ;Jan 1, 1970
      epoch = time0  * 1000. + epoch0
      cdf_varcreate_put_tplot_to_cdf,id,cdf.atts.depend_0,epoch,vtype='CDF_EPOCH'
   endif else begin
      if array_equal(time0,ntime,/no_type) eq 0 then begin
         message,/info,name+": size does not match"
         goto,cont
      endif
   endelse
;   if (total(ntime ne time0) ne 0) then begin
;      message,/info,'Warning! Times for '+name+' do not match times for '+names[0]
;   endif
   
   cdf_varcreate_put_tplot_to_cdf,id,cdf.name,ndata,/shift
   cdf_vatt_put_tplot_to_cdf,id,name,cdf.atts
   if keyword_set(nvalues) then begin
       cdf_varcreate_put_tplot_to_cdf,id,cdf.atts.depend_1,nvalues,/shift,rec_novary=val_vary eq 0
   endif  
   cont:
endfor

cdf_close,id
print,'file ',fname,'.cdf created'

end





