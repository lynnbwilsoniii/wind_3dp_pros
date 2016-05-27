;+
;FUNCTION:  dimen_shift(x,shift)
;NAME:
;  dimen_shift
;PURPOSE:
;  Rotate dimensions of a multidimensional array.
;  This function is very similar to transpose but works on multi-dimensional
;  arrays to shift the dimensions around.
;  It has no effect on scalars and one dimensional arrays.
;INPUT:
;  x   multi-dimensional array of any type
;  shift:  1 or -1  direction of shift.
;CREATED BY: Davin Larson
;LAST MODIFICATION:	@(#)dimen_shift.pro	1.3 96/10/10
; 
;-
function dimen_shift,x,shft

s = size(x)

dim = s(0)
n = n_elements(x)

if dim le 1 then return,x
;if dim eq 2 then return,transpose(x)

dims = s(1:dim)

case shft of
   1:  t_dims = [n/dims(dim-1),dims(dim-1)]
  -1:  t_dims = [dims(0),n/dims(0)]
   0:  return,x
   else: message,'Unable to shift dimensions by more than one.'
endcase

new_x = reform(x,t_dims)
new_x = transpose(new_x)

new_dims = shift(dims,shft)
new_x = reform(new_x ,new_dims)

return,new_x
end
