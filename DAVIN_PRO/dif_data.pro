;+
;PROCEDURE: dif_data, n1,n2
;PURPOSE:
;   Creates a tplot variable that is the difference of two tplot variables.
;INPUT: n1,n2  tplot variable names (strings)
;-
PRO dif_data,n1,n2,newname=newname
get_data,n1,data=d1
get_data,n2,data=d2
if not keyword_set(d1) or not keyword_set(d2) then begin
   message,/info,'data not defined!'
   return
endif
if not keyword_set(newname) then newname = n1+'-'+n2
y2 = data_cut(d2,d1.x)
dif = d1.y-y2
dat = {x:d1.x,y:dif}
store_data,newname,data=dat
return
end
