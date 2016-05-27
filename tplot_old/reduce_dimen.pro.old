;+
;PROCEDURE: reduce_dimen,name,d,n1,n2,deflim=deflim,newname=newname
;PURPOSE:  reduces dimension of tplot variable for plotting.
;INPUT:
;  name:  tplot handle of 3 dimensional data
;  d:  dimension to sum over.  (1 or 2)
;  n1: starting index
;  n2: ending index
;
;Caution:  This procedure is still in development.
;Created by: Davin Larson,  Sept 1995
;File:  reduce_dimen.pro
;Version:  1.1
;Last Modified:  02/04/12
;-
pro reduce_dimen, name,d, n1, n2, deflim=options,newname=newname,data=data $
  ,vrange = vrange,nan=nan

get_data,name,data=data
if not keyword_set(data) then return

if not keyword_set(newname) then $
  newname = string(name,d,n1,n2,format='(a0,"-",i0,"-",i0,":",i0)')

dim = dimen(data.y)

range = [n1,n2]

if d eq 1 then begin
   v = reform(data.v2)
   vrange= reform(data.v1)
   if n_elements(range) eq 0 then range = [0,dim(1)-1] 
   y = data.y(*,range(0):range(1),*)
endif else begin
   v = reform(data.v1)
   vrange= reform(data.v2)
   if n_elements(range) eq 0 then range = [0,dim(2)-1]
   y = data.y(*,*,range(0):range(1))
endelse

if ndimen(vrange) eq 2 then vrange = total(vrange,1,/nan)/total(finite(vrange),1)

vrange = vrange(range)

if ndimen(y) eq 3 then begin
  if keyword_set(nan) then y= total(y,d+1,/nan)/total(finite(y),d+1) $
  else  y = total(y,d+1)/dim(d)
endif
data = {x:data.x,y:y,v:v}
extract_tags,data,options

;help,data,options,/st

store_data,newname,data=data
;message,/info,'Data quantity '+newname+' created.'
end

