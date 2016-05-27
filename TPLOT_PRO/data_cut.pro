;+
;*****************************************************************************
;FUNCTION: A = data_cut(name, t)
;PURPOSE:  Interpolates data from a data structure.
;INPUT:
;  name:  Either a data structure or a string that can be associated with
;      a data structure.  (see "get_data" routine)
;      the data structure must contain the element tags:  "x" and "y"
;      the y array may be multi dimensional.
;  t:   (scalar or array)  x-values for interpolated quantities.
;RETURN VALUE:
;  a data array: the first dimension is the dimension of t
;                the second dimension is the dimension of name
;
; NOTE!!  keyword options have been temporarily removed!!!!
;
;KEYWORDS:
;  EXTRAPOLATE:  Controls interpolation of the ends of the data. Effects:
;                0:  Default action.  Set new y data to NAN or to MISSING.
;                1:  Extend the endpoints horizontally.
;                2:  Extrapolate the ends.  If the range of 't' is
;                    significantly larger than the old time range, the ends
;                    are likely to blow up.
;  INTERP_GAP:   Determines if points should be interpolated between data gaps,
;                together with the GAP_DIST.  IF the data gap > GAP_DIST, 
;                follow the action of INTERP_GAP
;                0:  Default action.  Set y data to MISSING.
;                1:  Interpolate gaps
;  GAP_DIST:     Determines the size of a data gap above which interpolation
;                is regulated by INTERP_GAP.
;                Default value is 5, in units of the average time interval:
;                delta_t = (t(end)-t(start)/number of data points)
;  MISSING:      Value to set the new y data to for data gaps.  Default is NAN.
;
;CREATED BY:	 Davin Larson
;LAST MODIFICATION:     @(#)data_cut.pro	1.19 02/04/17
;                Added the four keywords. (fvm 9/27/95)
;
;    LAST MODIFIED:  06/08/2008
;    MODIFIED BY: Lynn B. Wilson III
;
;    CHANGED        : added GTIMES keyword so data_cut.pro would return the times
;                      associated with the data it returned
;
;*****************************************************************************
;-
FUNCTION data_cut,name,t, $
   COUNT=count, $
   EXTRAPOLATE=EXTRAPOLATE,INTERP_GAP=INTERP_GAP,gap_thresh=gap_thresh,$
   GAP_DIST=GAP_DIST,MISSING=MISSING,GTIMES=gtimes

if data_type(name) eq 7 or data_type(name) eq 2 or data_type(name) eq 3 then begin
  get_data,name,data=dat,index=h
  if h eq 0 then begin
    count = 0
    return,0
  endif
endif
 

if data_type(name) eq 8 then dat=name  

if n_elements(MISSING) eq 0    then MISSING     = !values.f_nan 

if keyword_set(INTERP_GAP) then begin
   trange = minmax(dat.x)
   dt = (trange[1]-trange[0])  / n_elements(dat.x)
   gap_thresh = dt * (keyword_set(GAP_DIST) ? GAP_DIST : 5.0)
endif


nt = dimen1(t)
count = nt
nd1 = dimen1(dat.y)
nd2 = dimen2(dat.y)
y = fltarr(nt,nd2)
if n_elements(dat.x) le 1 then return,0

;do the interpolation, including the gaps and ends
for i=0,nd2-1 do begin 
  y[*,i] = interp(dat.y[*,i],dat.x,t,interp_thr = gap_thresh)
endfor

if not keyword_set(EXTRAPOLATE) then begin
  tlim = minmax(dat.x)
  dt = (tlim[1]-tlim[0]) / (n_elements(dat.x)-1)
  tlim = tlim + [-dt,dt]
  outside = where(t LT tlim[0] OR t GT tlim[1],c,COMPLEMENT=inside)
  if n_elements(inside) gt 0 and keyword_set(gtimes) then gtimes=t[inside]
  if c ne 0 then y[outside,*] = MISSING
endif

if (ndimen(t) eq 0) and (ndimen(dat.y) eq 1) then begin
  return,y[0]
endif else begin
  
  return,reform(y)
endelse

end
