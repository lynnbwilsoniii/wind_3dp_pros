;-------------------------------------------------------------
;+
; NAME:
;       CONVEXHULL
; PURPOSE:
;       Return the convex hull of a polygon.
; CATEGORY:
; CALLING SEQUENCE:
;       convexhull, x, y, xh, yh
; INPUTS:
;       x,y = original polygon vertices.       in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       xh,yh = convex hull polygon vertices.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: The convex hull of a polygon is the minimum polygon
;         that circumscribes the original polygon.  It is the shape
;         a rubber band would take if placed around the original
;         polygon.
; MODIFICATION HISTORY:
;       R. Sterner, 2 Oct, 1990
;       R. Sterner, 26 Feb, 1991 --- renamed from convex_hull.pro
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function onhull, x1, y1, x2, y2, x, y
 
	;--- (x1,y1) and (x2,y2) are the two endpoints of a polygon side.
	;--- x,y are the arrays of the polygon vertices.
	ux = y2 - y1		  ; This is a vector perpendicular to
	uy = x1 - x2		  ; the polygon side.
	d = ux*(x-x2) + uy*(y-y2) ; Dot prod of U vect to all vertices.
	s = sign(d)		  ; Side of polygon side each vertex is on.
	r = max(s) - min(s)	  ; 1: one side, -1: other side, 0: bewteen.
	return, r eq 1		  ; Seg on C.H. if all pts on one side.
	end
 
 
;-------  Convexhull.pro = return the convex hull of a polygon  ------
;	R. Sterner, 3 Oct, 1990
 
	pro convexhull, x, y, xh, yh, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Return the convex hull of a polygon.'
	  print,' convexhull, x, y, xh, yh'
	  print,'   x,y = original polygon vertices.       in'
	  print,'   xh,yh = convex hull polygon vertices.  out'
	  print,' Notes: The convex hull of a polygon is the minimum polygon'
	  print,'   that circumscribes the original polygon.  It is the shape'
	  print,'   a rubber band would take if placed around the original'
	  print,'   polygon.'
	  return
	endif
 
;---  Conjecture: The mean of the polygon points is inside the convex hull ----
	xm = mean(x)
	ym = mean(y)
;---  Conjecture: The farthest point from any point inside the convex hull ----
	;                 is on the convex hull.
	d = (x-xm)^2 + (y-ym)^2		; Dist^2 from mean to all polygon pts.
	w = where(d eq max(d))		; Find farthest point.
	i0 = w(0)			; Index of farthest point.
	xs = shift(x,-i0)		; Shift arrays to put farthst pt first.
	ys = shift(y,-i0)
	n = n_elements(x)		; Size of polygon.
	xh = fltarr(1) + xs(0)		; Start convex hull array.
	yh = fltarr(1) + ys(0)
	l = 0				; Last convex hull point index.
 
	i0 = 1				; Search start index.
 
	;-----  Starting with a known convex hull point find the next  -------
loop:
	for i = i0, n-1 do begin
	  if onhull(xh(l),yh(l),xs(i),ys(i),xs,ys) then begin
	    xh = [xh,xs(i)]		; Add new point to hull.
	    yh = [yh,ys(i)]
	    l = l + 1			; Count hull point.
	    i0 = i + 1			; Start search at next point.
	    goto, loop
	  endif
	endfor
 
	return
 
	end