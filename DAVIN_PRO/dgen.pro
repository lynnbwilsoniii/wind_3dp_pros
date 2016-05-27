;+
;FUNCTION:   dgen(n)
;PURPOSE:  returns an array of n doubles that are scaled between two limits.
;INPUT:   n:  number of data points.   (uses 100 if no value is passed)
;KEYWORDS:  one of the next 3 keywords should be set:
;   XRANGE:  uses !x.crange (current x limits) for the scaling.
;   YRANGE:  uses !y.crange (current y limits) for the scaling.
;   RANGE:   user selectable range.
;   LOG:     user selectable log scale (Used with RANGE)
;EXAMPLES:
;  x = dgen(/x)  ; Returns 100 element array of points evenly distributed along
;                ; the x-axis.
;-

function dgen,n,range,  $
   LOG  = log,    $
   RESOLUTION  = res,     $
   pixel_res = pixels, $
   RANGE = krange ,  $
   XRANGE = xrange,  $
   YRANGE = yrange

if keyword_set(krange) then range=krange

if keyword_set(xrange) eq 0 and keyword_set(yrange) eq 0  $
    and keyword_set(range) eq 0 then xrange = 1

if keyword_set(xrange) then begin
   r = !x.crange
   log = !x.type
   pixval = !x.window * !d.x_vsize
   if keyword_set(pixels) then n = round((pixval[1]-pixval[0])/pixels+1) 
endif

if keyword_set(yrange) then begin
   r = !y.crange
   log = !y.type
   pixval = !y.window * !d.y_vsize
   if keyword_set(pixels) then n = round((pixval[1]-pixval[0])/pixels+1) 
endif

nr = n_elements(range)
if nr ne 0 then begin
    r = range[[0,nr-1]]
    if keyword_set(log) then r = alog10(r)
endif

if keyword_set(res) then   n = (round(abs((r[1]-r[0])/res)) > 1)+1

if n_elements(n) le 0 then n = 100


if n eq 1 then x = [(r[1]+r[0])/2] $
else x = dindgen(n)*(r(1) - r(0))/(n-1) + r(0)

if keyword_set(log) then x = 10d^x

return, x
end

