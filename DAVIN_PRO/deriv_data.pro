;+
;PROCEDURE: deriv_data, n1,n2
;PURPOSE:
;   Creates a tplot variable that is the derivative of a tplot variable.
;INPUT: n1  tplot variable names (strings)
;-
PRO deriv_data,n1,newname=newname
get_data,n1,data=d
if not keyword_set(d)  then begin
   message,/info,'data not defined!'
   return
endif
if not keyword_set(newname) then newname = 'd_'+n1

if ndimen(d.y) eq 1 then d.y = deriv(d.x,d.y)
if ndimen(d.y) eq 2 then $
   for i=0,dimen2(d.y)-1 do d.y(*,i) = deriv(d.x,d.y(*,i))

store_data,newname,data=d
return
end
