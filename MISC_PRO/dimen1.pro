;+
;FUNCTION:   dimen1
;INPUT:  matrix
;RETURNS:  scaler int:  size of first dimension  (1 if dimension doesn't exist)
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION;	@(#)dimen1.pro	1.3 95/08/24
;-
function dimen1, matrx         
s = size(matrx)
if s(0) lt 1 then return,1   ; scalar
return, s(1)
end



