;+
;FUNCTION average_hist(d,x [,STDEV=stdev])
;returns the average of d binned according to x
;USAGE:
;assuming:
;  x = randomu(seed,1000)*10
;  y = 10-.1*x^2 + randomn(seed,1000)
;  d = y
;   avg = average_hist(d,x,xbins=xc)
;   avg = average_hist(d,x,xbins=xc,range=[2,8],binsize=.25)
;  plot,x,y,psym=3
;  oplot,xc,avg,psym=-4
;NOTE:  d can be an array of structures:
;  d=replicate({x:0.,y:0.},1000)
;  d.x = x
;  d.y = y
;  plot,d.x,d.y,psym=3
;  avg = average_hist(d,d.x)
;  oplot,avg.x,avg.y,psym=-4
;-

function average_hist,a,x,stdev=std,log=log, $
  range=range,binsize=binsize,nbins=nbins,xbins=xbins,$
  binval=bins, minimum=minimum,shift=shft,nan=rnan,$
  histogram=h,reverse=ri
if keyword_set(x) then begin
  if n_elements(x) ne n_elements(a) then message,'Inputs must have same number of elements'
  bins = histbins(x,xbins,log=log,range=range,nbins=nbins,binsize=binsize,/retbins,shift=shft)
endif

if keyword_set(bins) then begin
  if n_elements(bins) ne n_elements(a) then message,'BINS must be same size as input array'
  if not keyword_set(nbins) then nbins = max(bins)+1
  h = histogram(bins,min=0,max=nbins-1,reverse=ri)
  if n_elements(h) ne nbins then message,'NBINS does not match h[]'
endif

nbins = n_elements(h)

nan = fill_nan(a[0])

;avg = replicate(nan,nbins)
minimum = replicate(nan,nbins)
avg = make_array(value=nan,dimen=size(h,/dimen))
std = avg

whn0 = where(h ne 0,count)

for j=0,count-1 do begin
  i = whn0[j]
  ind = ri[ ri[i]: ri[i+1]-1 ]
if n_elements(ind) ne h[i] then message,/info ,'Histogram error'
  avg[i] = average(a[ind],stdev=s,nan=rnan)
if data_type(a) lt 7 then  minimum[i] = min(a[ind])
  std[i] = s
endfor

return,avg

end
