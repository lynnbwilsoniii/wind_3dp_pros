;+
;FUNCTION: sum3d
;PURPOSE: Takes two 3D structures and returns a single 3D structure
;  whose data is the sum of the two
;INPUTS: d1,d2  each must be 3D structures obtained from the get_?? routines
;	e.g. "get_el"
;RETURNS: single 3D structure
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)sum3d.pro	1.8 02/04/17
;
;Notes: This is a very crude subroutine. Use at your own risk.
;-


function  sum3d, d1,d2
if data_type(d1) ne 8 then return,d2
if d2.valid eq 0 then return,d1
if d1.valid eq 0 then return,d2
if d1.data_name ne d2.data_name then begin
  print,'Incompatible data types'
  return,d2
endif
sum = d1
sum.data = sum.data+d2.data
sum.integ_t =  d1.integ_t + d2.integ_t
sum.dt   = sum.dt + d2.dt
sum.end_time = d1.end_time > d2.end_time
sum.time     = d1.time     < d2.time
sum.trange   = minmax([d1.trange,d2.trange])
sum.valid  = d1.valid and d2.valid
return, sum
end


