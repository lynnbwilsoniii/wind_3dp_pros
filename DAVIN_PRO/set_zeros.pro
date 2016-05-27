
function set_zeros,a,epsilon
if not keyword_set(epsilon) then epsilon = 1e-12
w = where(abs(a) lt epsilon,n)
if n gt 0 then a[w] = 0
return,a
end
