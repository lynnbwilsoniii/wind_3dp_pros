; + 
;FUNCTION array_union(A,B)
;PURPOSE:
;   Returns an array of indices of B that have elements common to A
;   The dimensions of the returned array are the same as A.
;   if an element of A is not found in B then the corresponding index is -1
; -
function  array_union,a,b
ind = replicate(-1,n_elements(a))
for i=0,n_elements(a)-1 do begin
   x = where(a(i) eq b,count)
   if count gt 0 then ind(i) = x(0)
endfor
return,ind
end

