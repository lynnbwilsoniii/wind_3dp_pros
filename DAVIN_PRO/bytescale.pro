;+
;FUNCTION:  bytescale(array)
;PURPOSE:   Takes an array or image and scales it to bytes
;INPUT:     array of numeric values.
;KEYWORDS:
;   RANGE:  Two element vector specifying the range of array to be used.
;        Defaults to the min and max values in the array.
;   ZERO:   Forces range(0) to zero
;   TOP:    Maximum byte value  (default is !d.table_size-2)
;   BOTTOM: Minimum byte value  (default is 1)
;   MIN_VALUE: autoranging ignores all numbers below this value
;   MAX_VALUE: autoranging ignores all numbers above this value
;   MISSING:  Byte value for missing data. (values outside of MIN_VALUE,
;     MAX_VALUE range)  If the value is less than 0 then !p.background is used.
;   LOG:    sets logrithmic scaling
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)bytescale.pro	1.22 02/04/17
;-
function bytescale, array,  $
   RANGE = range,          $
   ZERO = zero,            $
   TOP = top,             $
   BOTTOM = bottom,       $
   MIN_VALUE = min_val,  $
   MAX_VALUE = max_val,   $
   MISSING = missing,   $
   pure_color = pure, $
   LOG=log

;@colors_com

if keyword_set(pure) then begin
   cls = get_colors(/array)
   ndata = cls((indgen(pure) mod 6) +1)
   return,ndata
endif

if n_elements(top_c) eq 0 then top_c = !d.table_size-2
if n_elements(top) eq 0 then top = top_c
if n_elements(bottom_c) eq 0 then bottom_c = 7
if n_elements(bottom) eq 0 then bottom = bottom_c

if (keyword_set(range) eq 0) then  $
  range = minmax(array,MIN_V=min_val,MAX_V=max_val,POS=log) 
if keyword_set(range) and range(0) eq 0. and range(1) eq 0. then $
  range = minmax(array,MIN_V=min_val,MAX_V=max_val,POS=log) 

if n_elements(missing) eq 0 then missing = !p.background

if range(0) eq range(1) then begin
   ndata = byte(array)
   ndata(*) = !p.color
   return,ndata
endif

nrange = range
ndata  = array

bad = where(finite(array) eq 0, count)
if count ne 0 then ndata(bad) = nrange(0)

if keyword_set(log) then begin
   ndata = alog(ndata > nrange(0)/3.)
   nrange = alog(nrange)
endif else if keyword_set(zero) then nrange(0)=0

ndata = ndata < nrange(1)
ndata = ndata > nrange(0)
ndata = double(ndata-nrange(0))/(nrange(1)-nrange(0))*(top-bottom)+bottom
ndata = byte(ndata)
if count ne 0 then ndata(bad) = missing


if (n_elements(min_val) ne 0) then begin
   ind = where(array lt min_val,count)
   if count ne 0 then ndata(ind) = missing
endif

if (n_elements(max_val) ne 0) then begin
   ind = where(array gt max_val,count)
   if count ne 0 then ndata(ind) = missing
endif

return, ndata
end

