FUNCTION t3array,xx

ON_ERROR,1
x = xx
sx = size(x)
sa = sx(1:(n_elements(sx)-3))
if (sx(0) eq 3 or sx(0) eq 2) then begin
 x = transpose(reform(x,[marray(sa(0:n_elements(sa)-2)),sa(n_elements(sa)-1)]))
 sa = shift(sa,1)
 if (sx(0) eq 3) then begin
  x = reform(x,[marray(sa(0:n_elements(sa)-2)),sa(n_elements(sa)-1)])
 endif else begin
  x = reform(x,marray(sa(0:n_elements(sa)-1)))
 endelse
endif else begin
 print,' Input array does not have 2 or 3 elements: ',n_elements(sa)
endelse
return,x
end

