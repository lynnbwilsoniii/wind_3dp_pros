;+
;FUNCTION: ndimen
;PURPOSE:
;  Returns the number of dimensions in an array.
;INPUT:  array
;RETURNS number of dimensions  (0 for scalers,-1 for undefined)
;
;SEE ALSO:  "dimen", "data_type"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)ndimen.pro	1.6 97/03/10
;-
function ndimen,matrx            ;returns number of dimensions in a variable
if n_elements(matrx) eq 0 then return ,-1l
n = size(matrx)
return, n(0)
end

