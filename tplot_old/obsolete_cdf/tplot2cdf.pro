;+
;PROCEDURE: tplot2cdf
;This procedure is not yet working.
;-

pro tplot2cdf,varnames,filename=filename,trange=trange,overwrite=overwrite


if not keyword_set(filename) then begin
    message, "keyword 'filename' must be set"
    return
endif

vn=tnames(varnames,/all)
n = n_elements(vn) * keyword_set(vn)
if n eq 0 then begin
  message,/info,'No data!'
;  return
endif

printdat,vn

dp0 = {name:'', datatype:'', numelem:1, recvar:1, depend_0:'', depend_1:'', $
     dataptr:ptr_new(), attrptr:ptr_new()  }

;defattr = {depend_0:'Epoch'}
defattr = 0

for i=0,n-1 do begin
   dp1 = dp0
   data=0
   lim=0
   get_data,vn[i],ptr = data,alim=lim
   dp1.name = struct_value(lim,'cdfname',default=vn[i])
   cdfattr = struct_value(lim,'cdfattr',default=defattr)
   depend_0 = struct_value(cdfattr,'depend_0',default='Epoch')
   dp1.datatype = cdf_datatype( size(/type, *data.y ) )
   dp1.dataptr = data.y
   dp1.depend_0 = depend_0
   str_element,/add,cdfattr,'depend_0',depend_0
   if not keyword_set(tp1) then begin
      tp1 = dp0
      tp1.name = dp1.depend_0
      tp1.datatype = 'CDF_EPOCH'
      tp1.dataptr = data.x
      dp = tp1
   endif else begin
      if tp1.dataptr ne data.x then begin
         if array_equal(*tp1.dataptr,*data.x) eq 0 then $
             message,/info,'Time arrays are not equal!'
             page,'Time error ',+filename
      endif
   endelse
   val = struct_value(data,'v',default=0)
   if keyword_set(val) then begin
      depend_1 = struct_value(cdfattr,'depend_1',default='val_'+dp1.name)
      str_element,/add,cdfattr,'depend_1',depend_1
      dp1.depend_1 = depend_1
      vp1 = dp0
      vp1.name = dp1.depend_1
      vp1.datatype = cdf_datatype( size(/type, *data.v ) )
      vp1.recvar = array_equal( size(/dimen,*data.v) , size(/dimen,*data.y) )
      vp1.dataptr = data.v
      vp1.depend_0 = dp1.depend_0
      vp1.attrptr = ptr_new({depend_0:depend_0})
      dp = [dp,vp1]
   endif
   dp1.attrptr = ptr_new(cdfattr)
   dp = [dp,dp1]

endfor

;if !debug then stop
;printdat,dp

if keyword_set(dp) then begin
pt = ptrarr(n_elements(dp))
if keyword_set(trange) then begin
;   printdat,dp.name
;   printdat,dp.depend_0
   au = array_union( dp.depend_0,dp.name)
   for i= 0,n_elements(pt)-1 do begin
       if dp[i].recvar then begin
         if dp[i].datatype eq 'CDF_EPOCH' then begin
            data = *dp[i].dataptr
            pt[i] = ptr_new( where( data ge trange[0] and data lt trange[1]) )
         endif
         if au[i] ge 0 then   pt[i] = ptr_new( *pt[ au[i] ] )
       endif
   endfor
;   printdat,pt
   for i= 0,n_elements(pt)-1 do begin
       if keyword_set(pt[i]) then begin
          data = *dp[i].dataptr
          data = data[ *pt[i] , * , * ]
          *pt[i] = data
          dp[i].dataptr = pt[i]
       endif
   endfor
endif
;if !debug then stop
endif

cdf_write_ptrs,dp,filename,overwrite=overwrite

if keyword_set(dp) then ptr_free,dp.attrptr,pt

end
