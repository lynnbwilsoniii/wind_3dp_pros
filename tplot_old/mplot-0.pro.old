;+
;PROCEDURE:  mplot, x, y, [,dy]
;INPUT:
;            x:  1 or 2 dimensional array of x values.
;            y:  1 or 2 dimensional array of y values.
;           dy;  error bars for y;  same dimensions as y. (optional)
;PURPOSE:
;    General purpose procedure used to make multi-line plots.
;	   
;KEYWORDS:
;    DATA:     A structure that contains the elements 'x', 'y' ['dy'].  This 
;       is an alternative way of inputing the data  (used by "TPLOT").
;    LIMITS:   Structure containing any combination of the following elements:
;          ALL PLOT/OPLOT keywords  (ie. PSYM,SYMSIZE,LINESTYLE,COLOR,etc.)
;          ALL MPLOT keywords
;          NSUMS:   array of NSUM keywords.
;          LINESTYLES:  array of linestyles.
;    LABELS:  array of text labels.
;    LABPOS:  array of positions for LABELS.
;    LABFLAG: integer, flag that controls label positioning.
;             -1: labels placed in reverse order.
;              0: No labels.
;              1: labels spaced equally.
;              2: labels placed according to data.
;              3: labels placed according to LABPOS.
;    BINS:    flag array specifying which channels to plot.
;    OVERPLOT: If non-zero then data is plotted over last plot.
;    NOXLAB:   if non-zero then xlabel tick marks are supressed.
;    COLORS:   array of colors used for each curve.
;    NOCOLOR:  do not use color when creating plot.
;NOTES: 
;    The values of all the keywords can also be put in the limits structure or
;    in the data structure using the full keyword as the tag name.
;    The structure value will overide the keyword value.
;
;CREATED BY:	Davin Larson
;FILE:  mplot.pro
;VERSION  1.43
;LAST MODIFICATION: 02/11/01
;
;-
pro mplot,xt,yt,dy,      $
   OVERPLOT = overplot,$
   OPLOT    = oplot,   $
   LABELS   = labels,  $ ;(array of) label(s) for the curve(s)
   LABPOS   = labpos,  $
   LABFLAG  = labflag, $
   COLORS   = colors,  $ ;(array of) color(s) for the curve(s)
   BINS     = bins,    $
   DATA     = data,    $
   NOERRORBARS = noerrorbars,  $
   ERRORTHRESH = errorthresh,  $
   NOXLAB   = noxlab,  $ ;No xlabels are printed if set
   NOCOLOR  = nocolor, $ ;Colors not automatically generated if set
   LIMITS   = limits     ;structure containing miscellaneous keyword tags:values

if keyword_set(data) then begin
  x = data.x
  y = data.y
  str_element,data,'dy',value=dy
  extract_tags,stuff,data,except=['x','y','dy','v']
  str_element,limits,'datagap',dg
  if keyword_set(dg) then makegap,dg,x,y,dy=dy
endif else begin
  x = xt
  y = yt
endelse


if keyword_set(overplot) then oplot=overplot
overplot = 1
str_element,limits,'overplot',value=oplot
str_element,limits,'noerrorbars',noerrorbars
str_element,limits,'errorthresh',errorthresh


xrange=[0.,0.]
yrange=[0.,0.]
charsize = !p.charsize
if charsize eq 0 then charsize = 1.

extract_tags,stuff,limits

;printdat,stuff

str_element,stuff,'nocolor',value=nocolor
str_element,stuff,'colors',value=colors
str_element,stuff,'nsums',value=nsums & n_nsums = n_elements(nsums) & nsum=1
str_element,stuff,'linestyles',value=linestyles
n_linestyles = n_elements(linestyles) & linestyle=0
str_element,stuff,'labflag',value=labflag
str_element,stuff,'labels',value=labels
str_element,stuff,'labpos',value=labpos
str_element,stuff,'labsize',value=lbsize
str_element,stuff,'bins',value=bins
str_element,stuff,'charsize',value=charsize
str_element,stuff,'axis',value=axis
 
;extract_tags,plotstuff,stuff,/plot
plotstuff = stuff
extract_tags,oplotstuff,stuff,/oplot
extract_tags,xyoutsstuff,stuff,/xyouts

str_element,plotstuff,'xrange',value=xrange
str_element,plotstuff,'xtype',value=xtype
str_element,plotstuff,'xlog',value=xtype
str_element,plotstuff,'yrange',value=yrange
str_element,plotstuff,'ytype',value=ytype
str_element,plotstuff,'ylog',value=ytype
str_element,plotstuff,'max_value',value=max_value
str_element,plotstuff,'min_value',value=min_value

d1 = dimen1(y)
d2 = dimen2(y)
ndx = ndimen(x)
nx = n_elements(x)



;if n_elements(bins) eq 0 then bins = replicate(1b,d2)
;if n_elements(bins) eq 1 then if bins[0] eq 1 then bins = replicate(1b,d2)
if ndimen(bins) eq 1 then begin
   w = where(bins eq 0,count)
   if count ne 0 then   y[*,w] = !values.f_nan
endif

if ndimen(bins) eq 2 then begin
   w= where(bins eq 0,count)
   if count ne 0 then   y[w] = !values.f_nan
endif

if xrange(0) eq xrange(1) then xrange = minmax(x,positive=xtype)

turbo = 1
if keyword_set(turbo) and ndx eq 1 and xrange[0] ne xrange[1]  and nx gt 1000 then begin
;   print,'turbo'
   mm = minmax(xrange)
   w = where(x ge mm[0] and x lt mm[1],count)
   if count eq 0 then w = n_elements(x)/2
   mm = minmax(w) + [-1,1]
   mm = 0 > mm < (n_elements(x)-1)
   x = x[mm[0]:mm[1]]
   y = y[mm[0]:mm[1],*]
   if keyword_set(dy) then    dy = dy[mm[0]:mm[1],*]

   
endif

if n_elements(errorthresh) eq 1 and keyword_set(dy) then begin
  w = where(y/dy lt errorthresh,count)
  if count gt 0 then y[w] = !values.f_nan

endif




good = where(finite(x),count) 
if count eq 0 then begin
   message,'No valid X data.',/info
   return
endif

ind = where(x(good) ge xrange(0) and x(good) le xrange(1),count)

psym_lim = 0
psym= -1
str_element,stuff,'psym',value=psym
str_element,stuff,'psym_lim',value=psym_lim
if count lt psym_lim then str_element,/add,plotstuff,'psym',psym
if count lt psym_lim then str_element,/add,oplotstuff,'psym',psym

if count eq 0 then ind = indgen(n_elements(x))  else ind = good(ind)
if yrange(0) eq yrange(1) then begin
    if ndx eq 1 then $
      yrange = minmax(y(ind,*),posi=ytype,max=max_value,min=min_value) $
    else $
      yrange = minmax(y(ind),posi=ytype,max=max_value,min=min_value)
endif

if keyword_set(noxlab) then $
    str_element,/add,plotstuff,'xtickname',replicate(' ',22)

if n_elements(colors) ne 0 then col = get_colors(colors)  $
;else if d2 gt 1 then col=bytescale(pure_col=d2) $
else if d2 gt 1 then col=bytescale(findgen(d2)) $
else col = !p.color

if keyword_set(nocolor) then if nocolor ne 2 or !d.name eq 'PS' then $
   col = !p.color

nc = n_elements(col)

if keyword_set(oplot) eq 0 then $
   box,plotstuff,xrange,yrange
;   plot,/nodata,xrange,yrange,_EXTRA = plotstuff


str_element,stuff,'constant',constant
if n_elements(constant) ne 0 then begin
  str_element,stuff,'const_color',const_color
  if n_elements(const_color) ne 0 then ccols = get_colors(const_color) else ccols=!p.color
  ncc = n_elements(constant)
  for i=0,ncc-1 do $
    oplot,xrange,constant[i]*[1,1],color=ccols[i mod n_elements(ccols)],/linestyle
endif

labbins = replicate(1,d2)
if keyword_set(labels) then begin
  nlab = n_elements(labels)
  if nlab ne d2 then message,'Incorrect number of labels',/cont
  labbins = replicate(1,nlab)
  if ndimen(bins) eq 1 then labbins=bins  
  yw = !y.window
  xw = !x.window
  if not keyword_set(lbsize) then $
    lbsize = charsize < (yw(1)-yw(0))/(nlab+1) *!d.y_size/!d.y_ch_size $
  else lbsize = lbsize*charsize
  if n_elements(labflag) eq 0 then begin
     if keyword_set(labpos) then labflag = 3 else labflag = 2
  endif
  if labflag eq 1 or labflag eq -1 then $
     nlabpos = (findgen(nlab)+0.5)*(yw(1)-yw(0))/nlab + yw(0)
  if labflag eq -1 then nlabpos = reverse(nlabpos)
  if labflag eq 3 then begin
     foo = convert_coord(/data,/to_norm,findgen(nlab),labpos)
     nlabpos = foo(1,*)
  endif
  xpos = !x.window(1)
endif else labflag=0

for n=0,d2-1 do begin
;  if bins(n) ne 0 then begin
    if ndx eq 1 then i=0 else i=n
    c = col(n mod nc)
    if n_nsums ne 0 then nsum = nsums(n mod n_nsums)
    if n_linestyles ne 0 then linestyle = linestyles(n mod n_linestyles)
    xt = x(*,i)
    yt = y(*,n)
    oplot,xt,yt,color=c,nsum=nsum,linest=linestyle,_EXTRA = oplotstuff
    if keyword_set(axis) then $
      for axisind = 0,n_elements(axis)-1 do axis,_extra=axis[axisind]
    if not keyword_set(noerrorbars) and n_elements(dy) ne 0 then begin
      tempc = !p.color
      !p.color = c
      upper = yt+dy(*,n)
      lower = yt-dy(*,n)
      
      if keyword_set(ytype) then lower = lower > yrange(0)/2.
      oplot_err,xt,lower,upper
;          oploterr,xt,yt,dy(*,n),0
      !p.color = tempc
    endif
    if keyword_set(labels) and keyword_set(labflag) and labbins[n] then begin
      ypos  = 0.
      if keyword_set(nlabpos) then ypos = nlabpos(n) else begin
        fooind = where(finite(yt),count)
        if count ne 0 then begin
          foo = convert_coord(xt(fooind),yt(fooind),/data,/to_norm)
          fooind = where( foo(0,*) le xw(1),count)
          if count ne 0 then mx = max(foo(0,fooind),ms)
          if count ne 0 then ypos = foo(1,fooind(ms))
        endif
      endelse
      if ypos le yw(1) and ypos ge yw(0) then $
        xyouts,xpos,ypos,'  '+labels(n),color=c,/norm,charsize=lbsize
    endif
;  endif
endfor

return
end



