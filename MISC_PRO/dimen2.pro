;+
;FUNCTION:   dimen2
;INPUT:  matrix
;RETURNS:  scaler int:  size of second dimension  (1 if dimension doesn't exist)
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION;	@(#)dimen2.pro	1.3 95/08/24
;-
function dimen2, matrx         
s = size(matrx)
if s(0) lt 2 then return,1   ; scalar or one dimensional
return, s(2)
end

