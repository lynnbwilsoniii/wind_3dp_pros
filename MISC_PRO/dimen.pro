;+
;FUNCTION:   dimen(x)
;PURPOSE:
;  Returns the dimensions of an array as an array of integers.
;INPUT:  matrix
;RETURNS:  vector of dimensions of matrix.
;   If the input is undefined then 0 is returned.
;   if the input is a scaler then 1 is returned.
;
;SEE ALSO:  "dimen", "data_type", "dimen1", "dimen2"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)dimen.pro	1.6 96/12/16
;-
function dimen, matrx          
s = size(matrx)
n = s(0)
if n ne 0 then return, s(1:n) else $
  if data_type(matrx) eq 0l then return,0l else $
  return,1l
end
