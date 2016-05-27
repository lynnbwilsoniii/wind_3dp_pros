;+
;FUNCTION:
;  w = enclosed(x,y [cx,cy],NCIRCS=NCIRCS,COUNT=COUNT)
;PURPOSE:
; Returns the indices of a set of x,y points that are inside a contour.
;INPUT:  x,y:    data set of points.  (x and y must be the same dimension)
;        cx,cy:  vector of x,y pairs that describe a closed contour. 
;        if cx,cy are not provided then the cursor is used to obtain it.
;OUTPUT:
;    W:  Array of indices of x (& y) that are within the contour cx,cy.
;    NCIRCS: Same dimension as x (& y); integer array giving the number
;        of times each point is encircled.
;    COUNT:  Size of array W
;-

function enclosed,x,y,cx,cy  $
  ,xlog=xlog, ylog=ylog $
  ,count = count,ncircs=inside,limits=lim
n = n_elements(x)

if keyword_set(lim) then   plot,x,y,_extra= lim

if n_params() lt 4 or keyword_set(cx) eq 0 then begin
   getxy,cx,cy,/continue,psym=0
   plots,cx[0],cy[0],/continue,psym=0
   xlog = !x.type
   ylog = !y.type
endif

cx1 = keyword_set(xlog) ? alog(cx) : cx
cy1 = keyword_set(ylog) ? alog(cy) : cy

;time = systime(1)

inside = make_array(/long,dim=dimen(x))

xrange = minmax(cx)
yrange = minmax(cy)
w = where((x le xrange[1]) and (x ge xrange[0]) and (y le yrange[1]) and (y ge yrange[0]),count)
if count eq 0 then return,-1

wx= keyword_set(xlog) ? alog(x[w]) : x[w]
wy= keyword_set(ylog) ? alog(y[w]) : y[w]

cross = 0
nc = n_elements(cx1)
for i0=0l, nc-1 do begin
  i1 = (i0+1) mod nc
  dx = (cx1[i1]-cx1[i0])
  if dx ne 0 then begin
    ym = double(cy1[i1]-cy1[i0])/dx*(wx-cx1[i0]) + cy1[i0]
    cross = cross +  (fix(cx1[i0] lt wx) - fix(cx1[i1] le wx)) * (ym lt wy)
  endif
endfor

bad = where(finite(wx + wy) eq 0,c)
if c ne 0 then cross[bad] = 0

inside[w] = cross


; Old method (slower by factor of 2 or 3)
;nc = n_elements(cx1)
;i = nc-1
;lastphi = atan(cy1[i] - wy,cx1[i] -wx)
;tdphi = 0.d
;for i=0l,nc-1 do begin
;   phi = atan(cy1[i] - wy,cx1[i] -wx)
;   dphi = phi - lastphi
;   lastphi = phi
;   tdphi = tdphi + dphi +2*!dpi*( fix(dphi lt -!dpi) - fix(dphi gt !dpi) )
;endfor
;bad = where(finite(tdphi) eq 0,c)
;if c ne 0 then tdphi[bad] = 0
;inside[w] = round(tdphi/2/!dpi)

;print,systime(1)-time,' Seconds'

return, where(inside ne 0,count)
end


;Very old method:
;inside = make_array(/long,dim=dimen(x))
;for i=0l,n-1 do begin
;   phi = atan(cy-y(i),cx-x(i))
;   phi = phi - shift(phi,1)
;   phi = phi +2*!dpi*( fix(phi lt -!dpi) - fix(phi gt !dpi) )
;   tphi = total(phi)
;   inside(i) = round(tphi/2/!dpi)
;;print,i,tphi,inside(i)
;endfor
