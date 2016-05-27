;+
;FUNCTION average(array,d [,STDEV=stdev] [,/NAN])
;PURPOSE:
;   Returns the average value of an array.
;   The input array can be an array of structures
;   Similar to TOTAL, but returns the average over the given dimension.
;   Also returns standard deviation via an optional keyword argument.
;   Works with structures only if d eq 0
;-
function average,x,d,nan=nan,stdev=s,do_stdev=do_stdev $
    ,double=double,total=tot,weight=weight,ret_median=ret_median $
    ,ret_total=ret_total,ret_min=ret_min,nsamples=norm

if n_params() eq 1 then d=0
if n_elements(do_stdev) eq 0 then do_stdev = arg_present(s)
nan1=keyword_set(nan)
if d gt ndimen(x) then begin
   s = !values.f_nan
   return,x
endif

type = size(/type,x)

case type of
7:  a=x[0]               ; strings
8:  begin                  ; structures
   if d ne 0 then message,'warning! Dimension must be 0 for input structures',/info
   a=x[0]
   if n_elements(x) eq 1 then begin
     s=fill_nan(a)
     return,a
   endif
   nt = n_tags(a)
   if do_stdev then  s=a
   for i=0,nt-1 do begin
      val = x.(i)
      a.(i) = average(val,ndimen(val),nan=nan,stdev=sd,do_stdev=do_stdev, $
         total=tot,/double,weight=weight,ret_median=ret_median,ret_total=ret_total, $
         ret_min=ret_min)
      if do_stdev then  s.(i) = sd
   endfor
end

else:    begin            ;numbers
   dim = dimen(x)
   if keyword_set(ret_min) then begin
      if d eq 0 then a = min(x,nan=nan1) else begin
        a= total(x,d)
        if d eq 1 then for i = 0,n_elements(a)-1 do a[i] = min(x[*,i],nan=nan1)
        if d eq 2 then for i = 0,n_elements(a)-1 do a[i] = min(x[i,*],nan=nan1)
        if d ge 3 then message,'Incomplete code'
      endelse
   endif else $
   if keyword_set(ret_median) then begin
;      printdat,x,'med'
      if d eq 0 then a = median(x,/even) else begin
        a= total(x,d)
        if d eq 1 then for i = 0,n_elements(a)-1 do a[i] = median(x[*,i],/even)
        if d eq 2 then for i = 0,n_elements(a)-1 do a[i] = median(x[i,*],/even)
        if d ge 3 then message,'Incomplete code'
      endelse
   endif else begin
     if not keyword_set(weight) then weight=1.
     norm = total(weight*finite(x),d)

;     if (d ne 0) and (not nan1) then norm = dim[d-1] else norm = total(finite(weight*x),d)

     tot = total(weight*x,d,nan=nan1,double=double)
     a = tot / norm
     if do_stdev then begin
        if d eq 0 then s = sqrt(total(weight*(x-a)^2,nan=nan1,double=double) / norm ) $
        else begin
          a2 = total(weight*x^2,d,nan=nan1,double=double) / norm
          s = sqrt(a2-a^2)
        endelse
     endif
   endelse
end

endcase

return,keyword_set(ret_total) ? tot : a
end
