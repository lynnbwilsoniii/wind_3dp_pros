	
;+
;PROCEDURE: padplot,pad
;   Plots pad data vs pitch angle.
;INPUTS:
;   pad   - structure containing pitch angle distribution (PAD) data. 
;           (Obtained from "pad()" routine)
;KEYWORDS:
;   LIMITS - limit structure. (see "xlim" , "YLIM" or "OPTIONS")
;      The limit structure can have the following elements:
;      UNITS:  units to be plotted in.
;      ALL PLOT and OPLOT keywords.
;   UNITS  - convert to given data units before plotting
;   MULTI  - Set to the number of plots desired across the page.
;   OPLOT  - Overplots last plot if set.
;   LABEL  - set to print labels for each energy step.
;
;SEE ALSO:	"spec3d"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)padplot.pro	1.18 09/19/2007
;  Modified By: Lynn B. Wilson III
;
;-
;   COLOR  - array of colors to be used for each bin
pro padplot,tempdat,   $
  NOCOLOR = nocolor, $
  LIMITS = limits, $
  UNITS = units,   $
  COLOR = shades,     $
  LABEL = labels,   $
  EBINS = ebins,     $
;  MULTI = multi,  $
  OVERPLOT = oplot, $
  WINDOW = wins


if data_type(tempdat) ne 8 or tempdat.valid eq 0 then begin
  print,'Invalid Data'
  return
endif

str_element,limits,'units',value=units
dat = conv_units(tempdat,units)


nb = dat.nbins

title = dat.project_name+'!C'+dat.data_name
title = title+'!C'+trange_str(dat.time,dat.end_time)

ytitle = units_string(dat.units_name)
xtitle = 'Pitch Angle  (degrees)'

ydat = transpose(dat.data)
xdat = transpose(dat.angles)

str_element,dat,'ddata',value=dydat
if n_elements(dydat) ne 0 then dydat = transpose(dydat)


plot={title:title, $
     xtitle:xtitle,x:xdat,xmargin:[11,11],xstyle:1,xrange:[0.,180.], $
     xtickv:[0.,90.,180.], xticks:3, xminor:9 ,$
     ytitle:ytitle,y:ydat,ymargin:[4,5] ,ylog:1 }

;if n_elements(dydat) ne 0 then  str_element,/add,plot,'dy',dydat
str_element,/add,plot,'dy',dydat

if ndimen(labels) ne 0 then begin
  str_element,limits,'velocity',value=vel
  x = total(dat.energy,2,/nan)
  x = x/total(finite(dat.energy),2)
  f = '(f8.1," eV")'
  if keyword_set(vel) then  begin 
    x = velocity(x,dat.mass) 
    f='(f8.0," km/s")'
  end
  labels= strtrim(string(x,format=f),2)
endif

;print,ebins

IF NOT KEYWORD_SET(wins) THEN wins = 1

;wi,wins,lim=limits

mplot,data=plot,bins=ebins,COLORS=shades,limits = limits,$
   LABELS=labels,overplot=oplot,nocolor=nocolor


end
