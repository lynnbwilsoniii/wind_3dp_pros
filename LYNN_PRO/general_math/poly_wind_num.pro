;+
;*****************************************************************************************
;
;  FUNCTION :   poly_wind_num.pro
;  PURPOSE  :   This routine calculates the winding number for a point inside a polygon.
;                 The outputs are as follows:
;                   = 0  :  P0 is outside of polygon
;                   > 0  :  P0 is inside of polygon
;                   < 0  :  P0 is inside of polygon
;
;  CALLED BY:   
;               
;
;  CALLS:
;               isLeft.pro
;
;  REQUIRES:    
;               
;
;  INPUT:
;               P0            :  [2]-Element [float/double] array defining the test point
;                                  to determine if inside polygon defined by vertices, VT
;                                  { P0[0] --> X-component, P0[1] --> Y-component }
;               VT            :  [N,2]-Element [float/double] array defining the vertices
;                                  of an arbitrary polygon
;                                  { Note:  VT[N-1,*] = VT[0,*] }
;
;  EXAMPLES:    
;               ;;  Start easy with a square and P0 inside at {1,1}
;               vt = DBLARR(4,2)
;               vt[0,*] = 0d0  ;; start at origin
;               vt[1,0] = 0d0
;               vt[1,1] = 2d0
;               vt[2,0] = 2d0
;               vt[2,1] = 2d0
;               vt[3,0] = 2d0
;               vt[3,1] = 0d0
;               p0      = [1d0,1d0]
;               PRINT,poly_wind_num(p0,vt)
;                      1
;
;               ;;  Use the same square but P0 outside at {1,3}
;               p0      = [1d0,3d0]
;               PRINT,poly_wind_num(p0,vt)
;                      0
;
;               ;;  Use the same square but P0 outside at {3,1}
;               p0      = [3d0,1d0]
;               PRINT,poly_wind_num(p0,vt)
;                      0
;
;               ;;  Use the same square but P0 outside at {1,-1}
;               p0      = [1d0,-1d0]
;               PRINT,poly_wind_num(p0,vt)
;                      0
;
;               ;;  Use the same square but P0 outside at {-1,1}
;               p0      = [-1d0,1d0]
;               PRINT,poly_wind_num(p0,vt)
;                      0
;
;               ;;  Use the same square but P0 on edge at {0,1}
;               p0      = [0d0,1d0]
;               PRINT,poly_wind_num(p0,vt)
;                      0
;
;               ;;  Use the same square but P0 on edge at {0,1} but set INCLUDE_EDGE
;               p0      = [0d0,1d0]
;               PRINT,poly_wind_num(p0,vt,/INCLUDE_EDGE)
;                      1
;
;  KEYWORDS:    
;               INCLUDE_EDGE  :  If set, routine will keep points that lie on the edge
;                                  as well as those within the polygon
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;  REFERENCES:  
;               1)  http://geomalgorithms.com/a03-_inclusion.html
;               2)  Numerical Recipes, 3rd Edition
;
;   CREATED:  04/21/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/21/2014   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION poly_wind_num,p0,vt,INCLUDE_EDGE=include_edge

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
bad_p0_in_msg  = 'P0 must be an [2]-element array...'
bad_vt_nd_msg  = 'VT must be a 2-dimensional array...'
bad_vt_dm_msg  = 'VT must be an [N,2]-element array...'
bad_numin_msg  = 'Incorrect number of inputs!'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 2)
IF (test) THEN BEGIN
  ;;  Must be 4 inputs supplied
  MESSAGE,bad_numin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF

test           = (N_ELEMENTS(p0)  NE 2)
IF (test) THEN BEGIN
  ;;  P0 must have [2]-elements
  MESSAGE,bad_p0_in_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF

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
wn             = 0                  ;;  initialize winding number
pp             = REFORM(p0)
;;  Loop through all edges of polygon
FOR j=0L, nv - 2L DO BEGIN
  k  = j + 1L
  v1 = [vtx[j],vty[j]]
  v2 = [vtx[k],vty[k]]
  ;;  Edge from VT[j] --> VT[j+1]
  IF (v1[1] LE pp[1]) THEN BEGIN
    IF (v2[1] GT pp[1]) THEN BEGIN
      ;;  an upward crossing
      test = isLeft(v1,v2,pp) GT 0  ;;  TRUE -->  P left of line from V1 to V2
      IF KEYWORD_SET(inedge) THEN test = isLeft(v1,v2,pp) GE 0
      IF (test) THEN wn += 1
    ENDIF
  ENDIF ELSE BEGIN
    ;;  start with V[j].Y > P.Y
    IF (v2[1] LE pp[1]) THEN BEGIN
      ;;  a downward crossing
      test = isLeft(v1,v2,pp) LT 0  ;;  TRUE -->  P right of line from V1 to V2
      IF KEYWORD_SET(inedge) THEN test = isLeft(v1,v2,pp) LE 0
      IF (test) THEN wn -= 1
    ENDIF
  ENDELSE
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,wn[0]
END
















