;+
;*****************************************************************************************
;
;  FUNCTION :   poly_winding_number2d.pro
;  PURPOSE  :   This routine calculates the winding number for an array of points inside
;                 or outside of a polygon.  The i-th output is as follows:
;                   = 0  :  {PX[i],PY[i]} is outside of polygon
;                   > 0  :  {PX[i],PY[i]} is inside of polygon
;                   < 0  :  {PX[i],PY[i]} is inside of polygon
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               isLeft2d.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               PX            :  [N]-Element [float/double] array defining the
;                                  X-component of the test points to determine if inside
;                                  polygon defined by vertices, VT
;               PY            :  [N]-Element [float/double] array defining the
;                                  Y-component of the test points to determine if inside
;                                  polygon defined by vertices, VT
;               VT            :  [K,2]-Element [float/double] array defining the vertices
;                                  of an arbitrary polygon
;                                  { Note:  VT[N-1,*] = VT[0,*] }
;
;  EXAMPLES:    
;               ;;  Test whether a series of points are inside/outside an irregular
;               ;;    polygon (e.g., use PATH_* keywords output from CONTOUR.PRO as
;               ;;    example polygon and coordinates used to define contours as the
;               ;;    list of points, PX and PY)
;               point_in_polygon = poly_winding_number2d(px,py,vt) EQ 1
;
;  KEYWORDS:    
;               INCLUDE_EDGE  :  If set, routine will keep points that lie on the edge
;                                  as well as those within the polygon
;               NOMSSG        :  If set, routine will not output time taken for routine
;                                  to return result to user
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [04/22/2014   v1.0.0]
;             2)  Continued to write routine
;                                                                   [04/22/2014   v1.0.0]
;             3)  Changed name so all letters are lower-case and updated Man. page and
;                   updated name of isLeft2d.pro accordingly
;                                                                   [05/15/2014   v1.1.0]
;
;   NOTES:      
;               1)  The winding number is essentially checking the sign of the cross-
;                     product and the "left-of-ray"ness or "right-of-ray"ness for
;                     each data point with respect to each ray defined by two adjacent
;                     coordinates on the edge of the irregular polygon.
;
;  REFERENCES:  
;               1)  http://geomalgorithms.com/a03-_inclusion.html
;               2)  Numerical Recipes, 3rd Edition
;
;   CREATED:  04/22/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/15/2014   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION poly_winding_number2d,px0,py0,vt,INCLUDE_EDGE=include_edge,NOMSSG=nom

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
bad_pxy_in_msg = 'P[X,Y] must be [N]-element arrays...'
bad_numin_msg  = 'Incorrect number of inputs!'
bad_vt_nd_msg  = 'VT must be a 2-dimensional array...'
bad_vt_dm_msg  = 'VT must be an [N,2]-element array...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 3)
IF (test) THEN BEGIN
  ;;  Must be 3 inputs supplied
  MESSAGE,bad_numin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF
;;  Check P[X,Y] format
test           = (N_ELEMENTS(px0) NE N_ELEMENTS(py0)) $
                  OR (SIZE(px0,/N_DIMENSIONS) GT 1)   $
                  OR (SIZE(px0,/N_DIMENSIONS) GT 1)
IF (test) THEN BEGIN
  ;;  P[X,Y] BOTH must have [N]-elements
  MESSAGE,bad_pxy_in_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF ELSE BEGIN
  ;;  Good input --> define new variables
  px = REFORM(px0)
  py = REFORM(py0)
ENDELSE
;;  Check VT format
sznvt          = SIZE(vt,/N_DIMENSIONS)
szdvt          = SIZE(vt,/DIMENSIONS)
test           = (sznvt[0] NE 2)
IF (test) THEN BEGIN
  ;;  VT must have 2-dimensions
  MESSAGE,bad_vt_nd_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF ELSE BEGIN
  test = ((szdvt[0] NE 2) OR (szdvt[1] NE 2)) AND ((szdvt[0]*szdvt[1]) LT 8)
  IF (test) THEN BEGIN
    ;;  VT must be an [N,2]-element array
    MESSAGE,bad_vt_dm_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN,d
  ENDIF ELSE BEGIN
    ;;  Good
    test = (szdvt[1] NE 2)
    IF (test) THEN BEGIN
      ;;  VT = [2,N]-element array
      vtx  = REFORM(vt[0,*])
      vty  = REFORM(vt[1,*])
    ENDIF ELSE BEGIN
      ;;  VT = [N,2]-element array
      vtx  = REFORM(vt[*,0])
      vty  = REFORM(vt[*,1])
    ENDELSE
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check that start/end vertices match
;;----------------------------------------------------------------------------------------
nvl            = N_ELEMENTS(vtx) - 1L
test           = (vtx[nvl] NE vtx[0]) OR (vty[nvl] NE vty[0])
IF (test) THEN BEGIN
  ;;  Force VT[n-1] = VT[0]  --> start = end
  vtx = [vtx,vtx[0]]
  vty = [vty,vty[0]]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
test           = KEYWORD_SET(include_edge)
IF (test) THEN inedge = 1 ELSE inedge = 0
;;----------------------------------------------------------------------------------------
;;  Calculate winding number
;;----------------------------------------------------------------------------------------
nv             = N_ELEMENTS(vtx)
np             = N_ELEMENTS(px)
wn             = REPLICATE(0,np)                  ;;  initialize winding number
;;  Loop through all edges of polygon
FOR j=0L, nv - 2L DO BEGIN
  k  = j + 1L
  ;;  Edge from VT[j] --> VT[j+1]
  v1 = [vtx[j],vty[j]]
  v2 = [vtx[k],vty[k]]
  ;;  Check for points above/below current edge
  good_low1y = WHERE(v1[1] LE py,gdl1y,COMPLEMENT=bad_low1y,NCOMPLEMENT=bdl1y)
  ;;  Check to make sure at least one of the index arrays have elements
  IF (gdl1y EQ 0 AND bdl1y EQ 0) THEN CONTINUE
  ;;  Check both
  IF (gdl1y GT 0 AND bdl1y GT 0) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Need to deal with points above and below 1st vertex separately
    ;;------------------------------------------------------------------------------------
    ;;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ;;  Points above 1st vertex
    ;;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    gpxl1       = px[good_low1y]
    gpyl1       = py[good_low1y]
    good_hig2y  = WHERE(v2[1] GT gpyl1,gdh2y,COMPLEMENT=bad_hig2y,NCOMPLEMENT=bdh2y)
    ;;  Edge from VT[j] --> VT[j+1]
    IF (gdh2y GT 0) THEN BEGIN
      ind        = good_low1y[good_hig2y]     ;;  keep track of indices relative to ALL
      px2        = gpxl1[good_hig2y]          ;;  Use only points satisfying inequality
      py2        = gpyl1[good_hig2y]
      ;;  test for an upward crossing
      ;;    TRUE -->  P left of line from V1 to V2
      IF KEYWORD_SET(inedge) THEN test = isLeft2d(v1,v2,px2,py2) GE 0 $
                             ELSE test = isLeft2d(v1,v2,px2,py2) GT 0
      good = WHERE(test,gd)
      IF (gd GT 0) THEN BEGIN
        gind      = ind[good]
        wn[gind] += 1
      ENDIF
    ENDIF
    ;;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ;;  Points below 1st vertex
    ;;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bpxl1       = px[bad_low1y]
    bpyl1       = py[bad_low1y]
    good_low2y  = WHERE(v2[1] LE bpyl1,gdl2y,COMPLEMENT=bad_low2y,NCOMPLEMENT=bdl2y)
    IF (gdl2y GT 0) THEN BEGIN
      ;;  start with (V[j].Y > P.Y) AND (VT[j+1].Y < P.Y)
      ind        = bad_low1y[good_low2y]       ;;  keep track of indices relative to ALL
      px2        = bpxl1[good_low2y]           ;;  Use only points satisfying inequality
      py2        = bpyl1[good_low2y]
      ;;  test for a downward crossing
      ;;    TRUE -->  P right of line from V1 to V2
      IF KEYWORD_SET(inedge) THEN test = isLeft2d(v1,v2,px2,py2) LE 0 $
                             ELSE test = isLeft2d(v1,v2,px2,py2) LT 0
      good = WHERE(test,gd)
      IF (gd GT 0) THEN BEGIN
        gind      = ind[good]
        wn[gind] -= 1
      ENDIF
    ENDIF
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  All points above or below 1st vertex
    ;;------------------------------------------------------------------------------------
    IF (gdl1y GT 0) THEN BEGIN
      ;;  All points above
      px1        = px[good_low1y]
      py1        = py[good_low1y]             ;;  Use only points satisfying inequality
      good_hig2y = WHERE(v2[1] GT py1,gdh2y,COMPLEMENT=bad_hig2y,NCOMPLEMENT=bdh2y)
      IF (gdh2y GT 0) THEN BEGIN
        ind        = good_low1y[good_hig2y]   ;;  keep track of indices relative to ALL
        px2        = px1[good_hig2y]          ;;  Use only points satisfying inequality
        py2        = py1[good_hig2y]
        ;;  test for an upward crossing
        ;;    TRUE -->  P left of line from V1 to V2
        IF KEYWORD_SET(inedge) THEN test = isLeft2d(v1,v2,px2,py2) GE 0 $
                               ELSE test = isLeft2d(v1,v2,px2,py2) GT 0
        good = WHERE(test,gd)
        IF (gd GT 0) THEN BEGIN
          gind      = ind[good]
          wn[gind] += 1
        ENDIF
      ENDIF
    ENDIF ELSE BEGIN
      ;;  All points below
      px1        = px[bad_low1y]
      py1        = py[bad_low1y]             ;;  Use only points satisfying inequality
      good_low2y = WHERE(v2[1] LE py1,gdl2y,COMPLEMENT=bad_low2y,NCOMPLEMENT=bdl2y)
      IF (gdl2y GT 0) THEN BEGIN
        ;;  start with (V[j].Y > P.Y) AND (VT[j+1].Y < P.Y)
        ind        = bad_low1y[good_low2y]    ;;  keep track of indices relative to ALL
        px2        = px1[good_low2y]          ;;  Use only points satisfying inequality
        py2        = py1[good_low2y]
        ;;  test for a downward crossing
        ;;    TRUE -->  P right of line from V1 to V2
        IF KEYWORD_SET(inedge) THEN test = isLeft2d(v1,v2,px2,py2) LE 0 $
                               ELSE test = isLeft2d(v1,v2,px2,py2) LT 0
        good = WHERE(test,gd)
        IF (gd GT 0) THEN BEGIN
          gind      = ind[good]
          wn[gind] -= 1
        ENDIF
      ENDIF
    ENDELSE
  ENDELSE
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
IF NOT KEYWORD_SET(nom) THEN BEGIN
  MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
ENDIF
;*****************************************************************************************

RETURN,wn
END


