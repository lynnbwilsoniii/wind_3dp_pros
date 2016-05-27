;+
;FUNCTION:
;  dat = tsample([var,trange],[times=t])
;PURPOSE:
;  Returns a vector (or array) of tplot data values.
;USAGE:
;  dat = tsample()               ;Use cursor to select a subset of data.
;  dat = tsample('Np',[t0,t1])   ;extract all 'Np' data in the given time range
;KEYWORDS:
;  times:  time values returned through this keyword.
;  values: values returned through this keyword.
;  dy :  dy values
;
;-
function tsample2,var,t,times=times,values=vals,noshow=noshow,index=w $
   ,average=aver,nan=nan,dy=dy,stdev=stdev,silent=silent

if n_elements(nan) eq 0 then nan=1

if n_elements(t) eq 0 then ctime,t,np=np,vnam=vars,noshow=noshow,silent=silent
if not keyword_set(var) then var=vars[0] else var=(tnames(var,/all))[0]
get_data,var,data=d
c = 1
w = -1
val = !values.f_nan
if not keyword_set(t) then return,val
if n_elements(t) eq 2 then w = where(d.x ge t(0) and d.x lt t(1),c)
if n_elements(t) eq 1 then begin
    dt = d.x-t[0]
    w = where(finite(dt) eq 0,nw)
    if nw ne 0 then dt[w] = 1e13
    dummy = min(abs(dt),w)
endif
if c ne 0 then begin
   val=d.y(w,*)
   times=d.x(w)
   str_element,d,'v',vals
   if ndimen(vals) eq 2 then vals= vals(w,*)
   str_element,d,'dy',dy
   if keyword_set(dy) then dy = dy[w,*]
endif
if keyword_set(aver) then begin
  val = average(val,1,nan=nan,stdev=stdev)
  if ndimen(vals) eq 2 then vals= average(vals,1,nan=nan)
  if keyword_set(dy) then dy = average(dy,1,nan=nan)
endif
return,val
end

