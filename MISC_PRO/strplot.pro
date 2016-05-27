;+
;PROCEDURE:  strplot, x, y
;INPUT:
;            x:  array of x values.
;            y:  array of y strings.
;PURPOSE:
;    Procedure used to print strings in a "TPLOT" style plot.
;	   
;KEYWORDS:
;    DATA:     A structure that contains the elements 'x', 'y.'  This 
;       is an alternative way of inputing the data.
;    LIMITS:   The limits structure including PLOT and XYOUTS keywords.
;    OVERPLOT: If set, then data is plotted over last plot.
;    DI:       Not used. Exists for backward compatibility.
;
;LAST MODIFIED: @(#)strplot.pro	1.2 98/08/03
;-
pro strplot,x,y,overplot=overplot,di=di,limits=lim,data=data
if keyword_set(data) then begin
  x = data.x
  y = data.y
  extract_tags,stuff,data,except=['x','y']
endif

extract_tags,stuff,lim
extract_tags,plotstuff,stuff,/plot
extract_tags,xyoutstuff,stuff,/xyout
str_element,stuff,'labels',val=labels
labsize = 1.
str_element,stuff,'labsize',val=labsize
chsize = !p.charsize
if not keyword_set(chsize) then chsize = 1.

n = n_elements(x)
if not keyword_set(overplot) then $
   plot,/nodata,x,findgen(n)/n,yrange=[0,1],/ystyle,_extra=plotstuff

z = fltarr(n)

xyouts,x,z,y,charsize=chsize,orien=90.,noclip=0,_extra=xyoutstuff


end
