;+
;NAME:
;    distfunc
;FUNCTION: distfunc(vpar,vperp,param=dfpar) 
;  or      distfunc(energy,angle,mass=mass,param=dfpar)
;PURPOSE:
;   Interpolates distribution function in a smooth manner.
;USAGE:
;   dfpar = distfunc(vx0,vy0,df=df0)   ; Create structure dfpar using
;     values of df0 known at the positions of vx0,vy0
;   df_new = distfunc(vx_new,vy_new,par=dfpar)
;     return interpolated values of df at the new points.
;
;-

function distfunc,vpar,vperp,  df=df,param=dfpar,mass=mass , debug = debug

if data_type(vpar) eq 8 then begin
   return,distfunc(vpar.energy,vpar.angles,mass=vpar.mass,param=dfpar,df=df)
endif

if keyword_set(mass) then begin
   vx = velocity(vpar,mass) * cos(vperp*!dtor)
   vy = velocity(vpar,mass) * sin(vperp*!dtor)
end else begin
   vx = vpar
   vy = vperp
endelse


if keyword_set(df) then begin
   good = where(finite(vx) and finite(vy) and finite(df))   ; valid points only
   vx0 = double(vx(good))
   vy0 = double(vy(good))
   df0 = double(df(good))
;help,good,vx0,vy0,df0
   good = where(df0 gt 0.)        ; non zero only
   vx0 = vx0(good)
   vy0 = vy0(good)
   df0 = df0(good)
;help,good,vx0,vy0,df0
   n = n_elements(df0)

   m = n + 2			;# of eqns to solve
   a = dblarr(m, m)		;LHS

   for i=0, n-1 do for j=i,n-1 do begin
      d1 = ((vx0(i)-vx0(j))^2 + (vy0(i)-vy0(j))^2) > 1.0d-100
      d2 = ((vx0(i)-vx0(j))^2 + (vy0(i)+vy0(j))^2) > 1.0d-100
      d = (d1*alog(d1)+d2*alog(d2))/2.
      a(i,j) = d
      a(j,i) = d
   endfor

   a(n,0:n-1) = 1.		; fill rest of array
   a(n+1,0:n-1) = vx0

   a(0:n-1,n) = 1.
   a(0:n-1,n+1) = vx0

   b = dblarr(m)
   b(0:n-1) = reform(alog(df0),n)

   c = reform(b # invert(a))

   if keyword_set(debug) then stop
   return,{vx0:vx0,vy0:vy0,dfc:c}
endif

vx0=dfpar.vx0
vy0=dfpar.vy0
c = dfpar.dfc

n = n_elements(vx0)
s = c(n) + c(n+1) * vx 		;Last terms
for i=0, n-1 do begin
   d1 = ((vx0(i)-vx)^2 + (vy0(i)-vy)^2)
   wz = where(d1 eq 0,count) & if count ne 0 then d1(wz) = 1.0d-100  
   d2 = ((vx0(i)-vx)^2 + (vy0(i)+vy)^2)  
   wz = where(d2 eq 0,count) & if count ne 0 then d2(wz) = 1.0d-100  
   d = (d1*alog(d1)+d2*alog(d2))/2.
   s = s + d * c(i)
endfor

if keyword_set(debug) then stop

return,exp(s)


end
