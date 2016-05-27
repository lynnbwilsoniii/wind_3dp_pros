;+
;Function:
; h = histbins2d(x,y,xval,yval)
;Input:
;   x, y, random variables to bin.
;Output:
;   h  number of events within bin
;   xval, yval,  center locations of the bins.
;
;-

function histbins2d,x,y,xval,yval,xrange=xrange,yrange=yrange,xnbins=xnbins,ynbins=ynbins, $
  reverse=ri,nbins=nbins,xbinsize=xbinsize,ybinsize=ybinsize, $
  xlog = xlog, ylog=ylog, $
  retbins=retbins,shift=shift,normalize=normal

xbins = histbins(x,xval,/retbins,range=xrange,nbins=xnbins,binsize=xbinsize,log=xlog,shift=shift)
ybins = histbins(y,yval,/retbins,range=yrange,nbins=ynbins,binsize=ybinsize,log=ylog,shift=shift)

wx = where(xbins ge xnbins or xbins lt 0,cx)
wy = where(ybins ge ynbins or ybins lt 0,cy)

bins = ybins*xnbins+xbins
if cx ne 0 then bins[wx]=-1
if cy ne 0 then bins[wy]=-1

nbins = xnbins * ynbins

if keyword_set(retbins) then return,bins


h = histogram(bins,min=0,max=nbins-1,reverse=ri)

h = reform(h,xnbins,ynbins,/over)

if keyword_set(normal) then h=h/total(h)/xbinsize/ybinsize

return,h
end



