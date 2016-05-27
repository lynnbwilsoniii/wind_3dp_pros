forward_function average_str_1
forward_function fill_str_zeroes

function fill_str_zeroes,d0
  dtype = data_type(d0,/struct)
  avable = [0,0,1,1,1,1,0,0,0,0,0,0,0]
  for i = 0,n_elements(dtype)-1 do begin
    if (dtype(i) ne 8) then begin
      if avable(dtype(i)) then d0.(i) = !values.f_nan else d0.(i) = 0
    endif else d0.(i) = fill_str_zeroes(d0.(i))
  endfor
return,d0
end
  
function average_str_1,data,nan=nan,median=med
   nt = n_tags(data)
   d = data(0)
   dtype = data_type(d,/struct)
   for i=0,nt-1 do begin
      if (dtype(i) ne 8) then begin
        ndim = ndimen(data.(i))
        d.(i) = average(data.(i),ndim,nan=nan,ret_median=med)
      endif else d.(i) = average_str_1(data.(i),nan=nan,median=med)
   endfor
   return,d
end

;+
;FUNCTION:	average_str(data, res)
;PURPOSE:
;	Average data in res second time segments.
;INPUTS:
;	DATA:	array of structures.  One element of structure must be TIME.
;	RES:	resolution in seconds.
;KEYWORDS:
;	NAN:	If set, treat the IEEE NAN value as missing data.
;CREATED BY:	Davin Larson
;LAST MODIFIED:	%W% %E%
;-
function average_str, data, res, nan=nan, median=med

n = n_elements(data)
d = data(0)

ind = floor(data.time / res)
start = ind(0)

ind = ind - ind(0)

max = ind(n-1)+1
d0 = data(0)

d0 = fill_str_zeroes(d0)

d = replicate(d0,max)

if max gt 1 then d.time = (dindgen(max)+5d-1+double(start))*double(res)  $
else d.time = (double(start)+5d-1)*double(res)

for i=0,max-1 do begin
   w = where(ind eq i,c)
   if c eq 1 then d(i) = data(w)
   if c gt 1 then d(i) = average_str_1(data(w),nan=nan,median=med)
endfor

report

return,d
end
