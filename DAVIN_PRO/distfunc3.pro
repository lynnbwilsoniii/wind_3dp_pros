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
;KEYWORDS:
;   template :  used to create a template of what data structure should look like
;                if sending in an array of structures with possible bad data
;
;
; LAST MODIFIED: 11/28/2007
; MODIFIED BY:  Lynn B. Wilson III  {error handling}
;
;*****************************************************************************
;3dp> help, dfpar,/str
;** Structure <e26fe8>, 21 tags, length=8272, data length=8262, refs=1:
;   PROJECT_NAME    STRING    'Wind 3D Plasma'
;   DATA_NAME       STRING    'Eesa Low PAD'
;   VALID           INT              1
;   UNITS_NAME      STRING    'df'
;   TIME            DOUBLE       8.2363067e+08
;   END_TIME        DOUBLE       8.2363067e+08
;   INTEG_T         DOUBLE           3.0690110
;   NBINS           INT              8
;   NENERGY         INT             15
;   DATA            FLOAT     Array[15, 8]
;   ENERGY          FLOAT     Array[15, 8]
;   ANGLES          FLOAT     Array[15, 8]
;   DENERGY         FLOAT     Array[15, 88]
;   BTH             FLOAT           22.8193
;   BPH             FLOAT           20.0945
;   GF              FLOAT     Array[15, 8]
;   DT              FLOAT     Array[15, 8]
;   GEOMFACTOR      DOUBLE       0.00039375000
;   MASS            DOUBLE       5.6856591e-06
;   UNITS_PROCEDURE STRING    'convert_esa_units'
;   DEADTIME        FLOAT     Array[15, 8]
;*****************************************************************************
;-



function distfunc3,vpar,vperp, df=df,param=dfpar,mass=mass ,debug=debug,template=mytemp

if data_type(vpar) eq 8 then begin
   return,distfunc(vpar.energy,vpar.angles,mass=vpar.mass,param=dfpar,df=df)
endif

IF KEYWORD_SET(mass) THEN BEGIN
   vx = velocity(vpar,mass) * cos(vperp*!dtor)
   vy = velocity(vpar,mass) * sin(vperp*!dtor)
ENDIF ELSE BEGIN
   vx = vpar
   vy = vperp
ENDELSE

 IF KEYWORD_SET(df) THEN BEGIN
   good = where(finite(vx) and finite(vy) and finite(df))   ; valid points only
   
   IF (good[0] NE -1) THEN BEGIN   
     vx0 = double(vx(good))
     vy0 = double(vy(good))
     df0 = double(df(good))
   ENDIF ELSE BEGIN
     print,'No Data!'
     return,mytemp
   ENDELSE
   
;help,good,vx0,vy0,df0

   good = where(df0 gt 0.)        ; non zero only

   IF (good[0] NE -1) THEN BEGIN   
     vx0 = vx0(good)
     vy0 = vy0(good)
     df0 = df0(good)
   ENDIF ELSE BEGIN
     print,'No Data!'
     return,mytemp
   ENDELSE



;help,good,vx0,vy0,df0

   n = n_elements(df0)

   m = n + 2			;# of eqns to solve
   a = dblarr(m, m)		;LHS

   FOR i=0, n-1 DO FOR j=i,n-1 DO BEGIN
      d1 = ((vx0(i)-vx0(j))^2 + (vy0(i)-vy0(j))^2) > 1.0d-100
      d2 = ((vx0(i)-vx0(j))^2 + (vy0(i)+vy0(j))^2) > 1.0d-100
      d = (d1*alog(d1)+d2*alog(d2))/2.
      a(i,j) = d
      a(j,i) = d
   ENDFOR

   a(n,0:n-1) = 1.		; fill rest of array
   a(n+1,0:n-1) = vx0

   a(0:n-1,n) = 1.
   a(0:n-1,n+1) = vx0

   b = dblarr(m)
   b(0:n-1) = reform(alog(df0),n)

   c = reform(b # invert(a))

   IF KEYWORD_SET(debug) THEN STOP
   mystr = CREATE_STRUCT('vx0',vx0,'vy0',vy0,'dfc',c)
   return, mystr

 ENDIF

vx0=dfpar.vx0
vy0=dfpar.vy0
c = dfpar.dfc

n = n_elements(vx0)
s = c(n) + c(n+1) * vx 		;Last terms
FOR i=0, n-1 DO BEGIN
   d1 = ((vx0(i)-vx)^2 + (vy0(i)-vy)^2)
   wz = where(d1 eq 0,count) & if count ne 0 then d1(wz) = 1.0d-100  
   d2 = ((vx0(i)-vx)^2 + (vy0(i)+vy)^2)  
   wz = where(d2 eq 0,count) & if count ne 0 then d2(wz) = 1.0d-100  
   d = (d1*alog(d1)+d2*alog(d2))/2.
   s = s + d * c(i)
ENDFOR

IF KEYWORD_SET(debug) THEN STOP

return,exp(s)


END
