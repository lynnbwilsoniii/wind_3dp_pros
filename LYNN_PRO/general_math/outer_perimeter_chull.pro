;+
;*****************************************************************************************
;
;  FUNCTION :   colinear_chull.pro
;  PURPOSE  :   In case of colinear data sets, this program will calculate the
;                 effective convex hull of the input.
;                 [though it is essentially meaningless for colinear data]
;
;  CALLED BY:   
;               outer_perimeter_chull.pro
;
;  CALLS:
;               sign.pro
;               array_where.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               XX        :  N-Element array of x-data
;               YY        :  N-Element array of y-data
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               CHULL     :  Set to a named variable to return the indices of the
;                              convex hull [counterclockwise order]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  User should not call this routine
;
;   CREATED:  04/20/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/20/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION colinear_chull,xx,yy,CHULL=chull

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f         = !VALUES.F_NAN
d         = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
xo        = REFORM(xx)
yo        = REFORM(yy)
nn        = N_ELEMENTS(xo)
;-----------------------------------------------------------------------------------------
; => Define the mean [X,Y]-position and the distance to all points from that mean
;-----------------------------------------------------------------------------------------
avgx      = MEAN(xo,/NAN)
avgy      = MEAN(yo,/NAN)
diffx     = (xo - avgx[0])
diffy     = (yo - avgy[0])
rad       = SQRT(diffx^2 + diffy^2)
; => Define the initial farthest point
mxrad0    = MAX(rad,/NAN,io)
;-----------------------------------------------------------------------------------------
; => Define convex hull
;-----------------------------------------------------------------------------------------
QHULL,xo,yo,chulls


chull0    = REFORM(chulls[0,*])
xh        = xo[chull0]
yh        = yo[chull0]
nh        = N_ELEMENTS(xh)
dfhx      = (xh - avgx[0])
dfhy      = (yh - avgy[0])
; => Calculate the clock angle of the convex hull points and sort in
;      counterclockwise fashion
clkang    = ATAN(dfhy,dfhx)*18d1/!DPI
chull     = chull0[SORT(clkang)]
xypts     = [[xh[SORT(clkang)]],[yh[SORT(clkang)]]]
;-----------------------------------------------------------------------------------------
; => Return the convex hull vertices
;-----------------------------------------------------------------------------------------
RETURN,xypts
END

;+
;*****************************************************************************************
;
;  FUNCTION :   outer_perimeter_chull.pro
;  PURPOSE  :   This routines calculates the convex hull of an input set of data in
;                 addition to determining only the outermost data points.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               colinear_chull.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               XX        :  N-Element array of x-data
;               YY        :  N-Element array of y-data
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               CHULL     :  Set to a named variable to return the indices of the
;                              convex hull [counterclockwise order]
;               OUTERPTS  :  Set to a named variable to return the indices of only the
;                              outermost points of the XY-scatter of data
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Assumptions:
;                     A)  The mean of the {x,y} set of positions [defined as:  <{x,y}>]
;                           is located inside the convex hull of the set of points
;                     B)  The positions {x_m[i],y_m[i]} correspond to the maximum magnitude
;                           distances from the <{x,y}>
;                           => r_m[i] = |{(<x> - x_m[i]), (<y> - y_m[i])}|
;                           which are assumed to exist on the convex hull
;                     C)  The data must be on an irregular grid to work
;
;   CREATED:  04/20/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/20/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION outer_perimeter_chull,xx,yy,CHULL=chull,OUTERPTS=outerpts

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f         = !VALUES.F_NAN
d         = !VALUES.D_NAN
badinmssg = 'Incorrect input:  XX and YY must have the same number of elements'

; => Define error handler
CATCH, error_status 

IF (error_status NE 0) THEN BEGIN 
  PRINT, 'Error index: ', error_status
  PRINT, 'Error message: ', !ERROR_STATE.MSG
  ; => Deal with error
  newtry   = colinear_chull(xo,yo,CHULL=chull)
  outerpts = newtry
  ; => cancel error handler and return data
  CATCH, /CANCEL
  RETURN,1
ENDIF
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
xo        = REFORM(xx)
yo        = REFORM(yy)
nx        = N_ELEMENTS(xo)
ny        = N_ELEMENTS(yo)
IF (nx NE ny) THEN BEGIN
  MESSAGE,badinmssg,/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
nn        = nx                ; => # of data points

; => Sort data by X-positions
;sp        = SORT(xo)
;xo        = xo[sp]
;yo        = yo[sp]
;-----------------------------------------------------------------------------------------
; => Define the mean [X,Y]-position and the distance to all points from that mean
;-----------------------------------------------------------------------------------------
avgx      = MEAN(xo,/NAN)
avgy      = MEAN(yo,/NAN)
diffx     = (xo - avgx[0])
diffy     = (yo - avgy[0])
rad       = SQRT(diffx^2 + diffy^2)
;-----------------------------------------------------------------------------------------
; => Calculate the convex hull of the data
;-----------------------------------------------------------------------------------------
good      = WHERE(FINITE(xo) AND FINITE(yo),gd)
IF (gd GT 0) THEN BEGIN
  x1       = xo[good]
  y1       = yo[good]
  TRIANGULATE,x1,y1,triangles,chull,TOLERANCE=1d-14*MAX([x1,y1],/NAN)
  ; => If program hasn't puked yet due to colinear data, then determine only the
  ;      outermost data points
  nh       = N_ELEMENTS(chull)
  xout     = x1[chull]
  yout     = y1[chull]
  outerpts = [[xout],[yout]]
  RETURN,1
ENDIF


END