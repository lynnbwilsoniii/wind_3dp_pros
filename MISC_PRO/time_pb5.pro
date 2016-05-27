;+
;NAME:
;  time_pb5
;PURPOSE:
;  Returns the PB5 time required by CDF files.
;USAGE:
;  pb5 = time_pb5(t)
;OUTPUT:
;  2 dimensional long integer array with dimensions:  (n,3)  Where n is the number
;  of elements in t
;Not fully TESTED!!!!
;
;CREATED BY:	Davin Larson  Oct 1996
;FILE:  time_pb5.pro
;VERSION:  1.3
;LAST MODIFICATION:  97/01/27
;-
function time_pb5,time,epoch=epoch
t = time_struct(time,epoch=epoch)
nd = n_elements(t)
res = lonarr(nd,3)
res(*,0) = t.year
res(*,1) = t.doy
res(*,2) = floor(t.sod *1000.d)
return,res
end

