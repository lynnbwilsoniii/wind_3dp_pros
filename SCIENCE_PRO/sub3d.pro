;+
;FUNCTION: sub3d
;PURPOSE: Takes two 3D structures and returns a single 3D structure
;  whose data is the difference of the two.
;  This routine is useful for subtracting background counts.
;  Integration period is considered if units are in counts.
;INPUTS: d1,d2  each must be 3D structures obtained from the get_?? routines
;	e.g. "get_el"
;RETURNS: single 3D structure
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:  04/04/2008  v1.11
;    MODIFIED BY: Lynn B. Wilson III
;
;Notes: This is a very crude subroutine. Use at your own risk.
;-



function  sub3d, d1,d2,siglevel=siglevel

IF data_type(d1) NE 8 THEN RETURN,d2

IF d1.data_name NE d2.data_name THEN BEGIN
  message,/info,'Incompatible data types'
  RETURN,d1
ENDIF

IF (d1.units_name NE d2.units_name) THEN BEGIN
  message,/info,'Different Units'
  RETURN,d1
ENDIF

dif = d1

IF strlowcase(d1.units_name) EQ 'counts' THEN  trat = d1.integ_t/d2.integ_t  ELSE trat = 1

dif.data = (d1.data - trat * d2.data)

;IF find_str_element(dif,'ddata') GE 0 AND find_str_element(d2,'ddata') GE 0 $
;	THEN BEGIN
;   print, "Computing Errors... "
   dif.ddata = sqrt( d1.ddata^2 + (trat * d2.ddata)^2 )
;ENDIF

IF n_elements(siglevel) NE 0 THEN BEGIN
   sig = dif.data/dif.ddata
   w = WHERE(sig LT siglevel, nw)
   IF (nw GT 0) THEN dif.bins[w] = 0
;   IF (nw GT 0) THEN dif.data[w] = 0
ENDIF

RETURN, dif
end


