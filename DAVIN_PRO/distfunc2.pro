function distfunc2,vx,vy,  df=df , debug = debug
common distfunc_com, vx0,vy0,c

if keyword_set(df) then begin
   n = n_elements(vx)
   vx0 = double(reform(vx,n))
   vy0 = double(reform(vy,n))

   m = n + 2			;# of eqns to solve
   a = dblarr(m, m)		;LHS

   for i=0, n-1 do for j=i,n-1 do begin
      d1 = ((vx0(i)-vx0(j))^2 + (vy0(i)-vy0(j))^2) > 1.0d-100
      d2 = ((vx0(i)-vx0(j))^2 + (vy0(i)+vy0(j))^2) > 1.0d-100
      d = (d1*alog(d1)+d2*alog(d2))/2.
      a(i+2,j) = d
      a(j+2,i) = d
   endfor

   a(0,0:n-1) = 1.		; fill rest of array
   a(1,0:n-1) = vx0

   a(2:*,n) = 1.
   a(2:*,n+1) = vx0

   b = dblarr(m)
   b(0:n-1) = reform(alog(df),n)

   c = reform(b # invert(a))

   if keyword_set(debug) then stop
   return,0
endif


n = n_elements(vx0)
s = c(0) + c(1) * vx 		;First terms
for i=0, n-1 do begin
   d1 = ((vx0(i)-vx)^2 + (vy0(i)-vy)^2) > 1.0d-100  
   d2 = ((vx0(i)-vx)^2 + (vy0(i)+vy)^2) > 1.0d-100  
   d = (d1*alog(d1)+d2*alog(d2))/2.
   s = s + d * c(i+2)
endfor

if keyword_set(debug) then stop

return,exp(s)


end
