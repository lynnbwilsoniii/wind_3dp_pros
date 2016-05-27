;+
;PROCEDURE: div_data, n1,n2
;PURPOSE:
;   Creates a tplot variable that is the ratio of two other tplot variables.
;INPUT: n1,n2  tplot variable names (strings)
;-
PRO div_data,n1,n2,newname=newname,interp_thresh=int_th
get_data,n1,data=d1
get_data,n2,data=d2
if not keyword_set(d1) or not keyword_set(d2) then begin
   message,/info,'data not defined!'
   return
endif
if not keyword_set(newname) then newname = n1+'/'+n2
y2 = interp(d2.y,d2.x,d1.x,interp_thresh=int_th)
ratio = d1.y
case ndimen(d1.y) of
 1: ratio = ratio/y2
 2: ratio = ratio/(y2 # replicate(1.,dimen2(d1.y)))
 endcase 
dat = {x:d1.x,y:ratio}
store_data,newname,data=dat,dlimit={comment:'Derived from: '+n1+' and '+n2}
return
end
