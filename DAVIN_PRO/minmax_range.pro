;+
;FUNCTION:   minmax_range,array 
;PURPOSE:  returns a two element array of min, max values
;INPUT:  array
;KEYWORDS:
;  MAX_VALUE:  ignore all numbers greater than this value
;  MIN_VALUE:  ignore all numbers less than this value
;  POSITIVE:   forces MINVALUE to 0
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)minmax_range.pro	1.5 03/13/2008
;  MODIFIED BY:  Lynn B. Wilson III
;-
;  MXSUBSCRIPT:  Named variable in which maximum subscript is returned NOT WORKING

function minmax_range,tdata,  $
   MAX_VALUE = max_value,  $ ; ignore all numbers >= max_value
   MIN_VALUE = min_value,  $ ; ignore all numbers <= min_value
   POSITIVE = positive, $   ;  forces min_value to 0
   MXSUBSCRIPT=subs

IF KEYWORD_SET(positive) THEN min_value = 0

w = WHERE(FINITE(tdata),count)

IF count EQ 0 THEN BEGIN 
  return, [0.,0.]
ENDIF

data = tdata(w)

IF n_elements(max_value) THEN BEGIN
   w = WHERE(data LT max_value ,count)
   IF count EQ 0 THEN RETURN,[0.,0.]
   data = data(w)
ENDIF

IF n_elements(min_value) THEN BEGIN
   w = where(data GT min_value, count)
   IF count EQ 0 THEN RETURN,[0.,0.]
   data = data(w)
ENDIF

mx = MAX(data,MIN=mn,/nan)
RETURN, [mn,mx]
END

