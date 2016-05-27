;+
;PROCEDURE makegap,dg,x,y
;PURPOSE:
;   Creates data gaps (by inserting NaN) when the time between data points is
;   larger than a value either passed in by the user or calculated to a
;   default.
;INPUT:
;   dg: If dg is positive, it is the maximum allowed time gap.  Any time gaps
;	greater than dg will be treated as data gaps.  If dg is negative,
;	the procedure will calculate a default value for dg of 20 times the
;	the smallest time gap in the time series.
;    x: The time array.
;    y: The data array.
;KEYWORDS:
;    v: Optional third dimension array.
;    dy: Optional uncertainty in y.
;CREATED BY: Peter Schroeder
;LAST MODIFIED:	@(#)makegap.pro	1.2 98/02/18
;-

pro makegap,dg,x,y,dy=dy,v=v

dty = data_type(y)
case dty of
	4: filly = !values.f_nan
	5: filly = !values.d_nan
else: return
endcase

diffarray = [x[1:*]-x[0:n_elements(x)-2]]

if dg lt 0 then begin
	posindx = where(diffarray gt 0,poscnt)
	if poscnt gt 0 then dg = 20d*min(diffarray(posindx)) else return
endif

gapindx = where(diffarray gt dg,gapcnt)

for i=gapcnt-1,0,-1 do begin
	indx = gapindx(i)
	x = [x[0:indx],x[indx]+dg,x[indx+1:*]]
	if ndimen(y) eq 1 then begin
		y = [y[0:indx],filly,y[indx+1:*]]
		if keyword_set(dy) then dy = [dy[0:indx],0.,dy[indx+1:*]]
	endif else begin
		y = [y[0:indx,*],replicate(filly,1,dimen2(y)),y[indx+1:*,*]]
		if keyword_set(dy) then dy = [dy[0:indx,*],$
			replicate(0.,1,dimen2(dy)),dy[indx+1:*,*]]
	endelse
	if keyword_set(v) then if ndimen(v) eq 1 then $
		v = [v[0:indx],v[indx],v[indx+1:*]] else $
		v = [v[0:indx,*],v[indx,*],v[indx+1:*,*]]
endfor

return
end
