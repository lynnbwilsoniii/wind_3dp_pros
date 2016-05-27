;+
; PROCECURE:	pmplot
;
; PURPOSE:	Used for making log y-axis plots.  Preformats data for
;		use with "mplot".  Plots negative data in red and positive
;		data in green.
;
; KEYWORDS:
;    DATA:     A structure that contains the elements 'x', 'y' ['dy'].  This 
;       is an alternative way of inputing the data  (used by "TPLOT").
;    LIMITS:   Structure containing any combination of the following elements:
;          ALL PLOT/OPLOT keywords  (ie. PSYM,SYMSIZE,LINESTYLE,COLOR,etc.)
;          ALL PMPLOT keywords
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
;LAST MODIFIED: @(#)pmplot.pro	1.4 02/04/17
;
;-
pro pmplot, $
	DATA=dat, $
	LIMITS=lim, $
	OPLOT=oplot, $
	OVERPLOT=overplot, $
	LABELS = labels, $
	LABPOS = labpos, $
	LABFLAG = labflag, $
	NOXLAB = noxlab, $
	NOCOLOR = nocolor, $
	BINS = bins

extract_tags, pmdata, dat, except=['y']
pmy = [[dat.y], [-dat.y]]
str_element,/add, pmdata, 'y', pmy
opts = {colors:[4,6]}
extract_tags,opts,lim
mplot,	data=pmdata, $
	limits=opts, $
	oplot=oplot, $
	overplot=overplot, $
	labels=labels, $
	labpos=labpos, $
	labflag=labflag, $
	noxlab=noxlab, $
	nocolor=nocolor, $
	bins=bins

end
