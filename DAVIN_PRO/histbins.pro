;+
;FUNCTION:
;   H=histbins(R,XBINS)
;Purpose:
;   Returns the histogram (H) and bin locations (XBINS) for an array of numbers.
;Examples:
;   r = randomn(seed,10000)
;   plot,psym=10, xbins, histbins(r,xbins)             ;Use all defaults.
;   plot,psym=10, xbins, histbins(r,xbins ,/shift)     ;shift bin edges.
;   plot,psym=10, xbins, histbins(r,xbins, binsize=.2)
;   plot,psym=10, xbins, histbins(r,xbins, binsize=.2 ,/shift)
;   plot,psym=10, xbins, histbins(r,xbins, range=[-10,10])
;NOTE:
;   XBINS is an output, not an input!
;Keywords:  (All optional)  Defaults are based on the size and range of input.
;   BINSIZE:  Size of bins.
;   NBINS: force the output array to have this number of elements. (Use with RANGE)
;   RANGE: Limits of histogram
;   SHIFT :  Keyword that controls the location of bin edges. 
;      This has no effect if RANGE is defined.
;   NORMALIZE: Set keyword to return a normalized histogram (probability distribution).
;   REVERSE:  See REVERSE keyword for histogram
;   RETBINS:  If set then an array of bins (same size as r) is returned instead.
;See also: "average_hist", "histbins2d"
;   
;-
function histbins,x,xbins, shift=shift, range=range, binsize=binsize, log=log, $
    nbins=nbins, anbins=anbins, retbins=retbins, reverse=ri, normalize=normalize
 
  lg = keyword_set(log)
  bad  = where(finite(x) eq 0,nbad)
  range_defined = (n_elements(range) eq 2) 
  if range_defined then range_defined = (range[0] ne range[1])
  if range_defined then  rg = double(minmax(range)) else rg = double(minmax(x))
  if lg then rg = alog10(rg)
  

  if not keyword_set(binsize) then begin
     if not keyword_set(anbins) then anbins=round(n_elements(x)^(1/3.d)) > 5
     if range_defined then begin
        nbins =  keyword_set(nbins) ? nbins : anbins
        binsize=(rg[1]-rg[0])/nbins
     endif else begin
        binsize = float(rg[1]-rg[0])/anbins
        lsize = alog10(binsize)+.15
        esize = floor(lsize)
        msize = floor(3*(lsize-esize))
        binsize = 10.d^esize * ([1,2,5,10])[msize]
     endelse
  endif
  
  if not range_defined then begin
     if keyword_set(shift) then $
       nrange = (floor(rg/binsize) + [0,1])*binsize $
     else $
       nrange = (floor(rg/binsize + .5) + [-.5,.5])*binsize
  endif else nrange = (lg ? alog10(range) : range)
  
  if not keyword_set(nbins) then nbins = round(float(nrange[1]-nrange[0])/binsize)
  
  nrange[1] = nrange[0]+binsize*nbins

  bins = [double((lg ? alog10(x) : x)-nrange[0])/(nrange[1]-nrange[0])*nbins]
  if nbad ne 0 then bins[bad] = -1
  bins = floor(bins)
  xbins = (lindgen(nbins)+.5)*(nrange[1]-nrange[0])/nbins+nrange[0]
  if lg then xbins = 10.d^xbins
  
  if keyword_set(retbins) then return,bins
  
  h = histogram(bins,min=0,max=nbins-1,reverse=ri)
  
  if keyword_set(normalize) then h = h/total(h)/binsize
  
  return,h
end

