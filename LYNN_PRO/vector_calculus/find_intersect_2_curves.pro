;*****************************************************************************************
;
;  FUNCTION :   seg_intersect.pro
;  PURPOSE  :   This routine tests whether two input line segments intersect.  It also
;                 determines if the lines are parallel and coincident.  The possible
;                 returned values are:
;                   0  :  no intersection
;                   1  :  1 intersection point
;                   2  :  segments are parallel
;                   3  :  segments are coincident
;
;  CALLED BY:   
;               find_intersect_2_curves.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               L1X  :  [2]-Element array of abscissa values marking the start and end
;                         points of the 1st line segment
;               L1Y  :  [2]-Element array of dependent variable values marking the start
;                         and end points of the 1st line segment
;               L2X  :  [2]-Element array of abscissa values marking the start and end
;                         points of the 2nd line segment
;               L2Y  :  [2]-Element array of dependent variable values marking the start
;                         and end points of the 2nd line segment
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               XY   :  A named variable that upon return contains the {X,Y}-coordinates
;                         of the intersection of the two input line segments, if an
;                         intersection exists.  If it does not exist, a [2]-element
;                         array of NaNs are returned.
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [09/09/2014   v1.0.0]
;
;   NOTES:      
;               Assume the input can be represented graphically like that shown below:
;
;                              F
;                 A           .
;                     .      .
;                        .  .
;                  .       ..
;                         .    .
;                        .        .
;                   .   .            .
;                      .                B
;                     .
;                    E
;
;               Then we can test for intersection by using a few simple tests described
;               in the following...
;
;               ;;=================================================================
;               ;;  Definitions:
;               ;;=================================================================
;                 A             =  { X1[j]  , Y1[j]   }
;                 B             =  { X1[j+1], Y1[j+1] }
;                 E             =  { X2[i]  , Y2[i]   }
;                 F             =  { X2[i+1], Y2[i+1] }
;                 AB            =  {(X1[j+1] - X1[j])  ,(Y1[j+1] - Y1[j])  }
;                 EA            =  {(X1[j]   - X2[i])  ,(Y1[j]   - Y2[i])  }
;                 EF            =  {(X2[i+1] - X2[i])  ,(Y2[i+1] - Y2[i])  }
;                 Angle(EF,EA)  =  å
;                 Angle(AB,EA)  =  ¥
;                 Angle(AB,EF)  =  ß
;               ;;  Cross products
;                 N_A           = EF x EA = sin(å)
;                 N_B           = AB x EA = sin(¥)
;                 D             = AB x EF = sin(ß)
;               ;;=================================================================
;               ;;  Tests:
;               ;;=================================================================
;                 (D = 0)                                  :  Lines are parallel
;                 (N_A = 0) & (N_A = 0)                    :  Lines are coincident
;                 (0 ≤ N_A ≤ 1) & (0 ≤ N_B ≤ 1) & (D ≠ 0)  :  Intersection!
;
;  REFERENCES:  
;               
;
;   CREATED:  09/06/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/09/2014   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION seg_intersect,l1x,l1y,l2x,l2y,XY=xy

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
bad_numin_msg  = 'Incorrect number of inputs!'
bad_l1__in_msg = 'LX1(LY1) must be an [2]-element array...'
bad_l2__in_msg = 'LX2(LY2) must be an [2]-element array...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 4)
IF (test) THEN BEGIN
  ;;  Must be 4 inputs supplied
  MESSAGE,bad_numin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
test1          = (N_ELEMENTS(l1x) NE 2L) OR (N_ELEMENTS(l1y) NE 2L)
test2          = (N_ELEMENTS(l2x) NE 2L) OR (N_ELEMENTS(l2y) NE 2L)
test           = test1[0] OR test2[0]
IF (test[0]) THEN BEGIN
  ;;  # of abscissa must match number of dependent values
  IF (test1[0]) THEN MESSAGE,bad_l1__in_msg[0],/INFORMATIONAL,/CONTINUE
  IF (test2[0]) THEN MESSAGE,bad_l2__in_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Calculate 2D cross-product
;;    Let u = {ux,uy} and v = {vx,vy}, then we have:
;;      (u x v) = ux*vy - uy*vx
;;----------------------------------------------------------------------------------------
;;  Define line segments:  AB, EA, and EF
lab            = [ (l1x[1] - l1x[0]), (l1y[1] - l1y[0]) ]
lea            = [ (l1x[0] - l2x[0]), (l1y[0] - l2y[0]) ]
lef            = [ (l2x[1] - l2x[0]), (l2y[1] - l2y[0]) ]
;;  Define:  N_A = EF x EA = sin(å)
numa           = lef[0]*lea[1] - lef[1]*lea[0]
;;  Define:  N_B = AB x EA = sin(¥)
numb           = lab[0]*lea[1] - lab[1]*lea[0]
;;  Define:  D   = AB x EF = sin(ß)
denom          = lab[0]*lef[1] - lab[1]*lef[0]

IF (denom[0] EQ 0) THEN BEGIN
  ;;  lines are //
  ;;    --> check if they are coincident as well
  code = ((numa[0] EQ 0) AND (numb[0] EQ 0)) + 2
ENDIF ELSE BEGIN
  ;;  lines are not //
  ;;    --> check if they intersect
  ua   = numa[0]/denom[0]
  ub   = numb[0]/denom[0]
  code = (ua[0] GE 0) AND (ua[0] LE 1) AND (ub[0] GE 0) AND (ub[0] LE 1)
  IF (code[0]) THEN BEGIN
    ;;  Intersection found
    ;;    --> return coordinates
    xy = [l1x[0] + ua[0]*(l1x[1] - l1x[0]),l1y[0] + ua[0]*(l1y[1] - l1y[0])]
  ENDIF
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;  code:
;;  0: no intersecting
;;  1: intersect in 1 point
;;  2: parallel
;;  3: coincident

RETURN,code
END


;+
;*****************************************************************************************
;
;  PROCEDURE:   find_intersect_2_curves.pro
;  PURPOSE  :   This routine finds the intersection(s) of two arbitrary lines, which
;                 can be curved or straight.  The user can show a plot illustrating
;                 where the routine found intersections as a test as well.  This routine
;                 should return all intersection points between two arbitrary curves,
;                 if multiple intersections occur.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               seg_intersect.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               XX1        :  [N]-Element array of abcissa values for YY1
;               YY1        :  [N]-Element array of dependent values associated with XX1
;               XX2        :  [M]-Element array of abcissa values for YY2
;               YY2        :  [M]-Element array of dependent values associated with XX2
;
;  EXAMPLES:    
;               ;;=================================================================
;               ;;  Example 1 [show plot too]
;               ;;=================================================================
;               x1             = [0.1,0.2,0.6,0.7]
;               x2             = [0.5,0.4,0.5,0.3]
;               y1             = [1,2,3,4]
;               y2             = y1
;               find_intersect_2_curves,x1,y1,x2,y2,XY=xy,/SHOW_PLOT
;               PRINT,';;',xy
;               ;;      0.46666664       2.6666665
;
;               ;;=================================================================
;               ;;  Example 2 [horizontal line and sine wave]
;               ;;=================================================================
;               n1             = 100L
;               n2             = 150L
;               x1             = DINDGEN(n1[0])*6d0*!DPI/(n1[0] - 1L)
;               y1             = SIN(x1)
;               x2             = DINDGEN(n2[0])*6d0*!DPI/(n2[0] - 1L)
;               y2             = REPLICATE(5d-1,n2[0])
;               find_intersect_2_curves,x1,y1,x2,y2,XY=xy,/SHOW_PLOT
;               HELP, xy
;               XY              DOUBLE    = Array[2, 6]
;               FOR j=0L, N_ELEMENTS(xy[0,*]) - 1L DO PRINT,';;',REFORM(xy[*,j])
;               ;;      0.52540586      0.50000000
;               ;;       2.6158625      0.50000000
;               ;;       6.8085912      0.50000000
;               ;;       8.8990478      0.50000000
;               ;;       13.091776      0.50000000
;               ;;       15.182233      0.50000000
;
;               ;;=================================================================
;               ;;  Example 3 [straight line and sine wave]
;               ;;=================================================================
;               n1             = 150L
;               n2             = 100L
;               x1             = DINDGEN(n1[0])*6d0*!DPI/(n1[0] - 1L)
;               y1             = SIN(x1)
;               x2             = DINDGEN(n2[0])*6d0*!DPI/(n2[0] - 1L)
;               y2             = x2/(3d0*!DPI) - 1d0
;               find_intersect_2_curves,x1,y1,x2,y2,XY=xy,/SHOW_PLOT
;               HELP, xy
;               XY              DOUBLE    = Array[2, 5]
;               FOR j=0L, N_ELEMENTS(xy[0,*]) - 1L DO PRINT,';;',REFORM(xy[*,j])
;               ;;       3.7837324     -0.59853353
;               ;;       5.8989870     -0.37409804
;               ;;       9.4247780   5.0306981e-17
;               ;;       12.950569      0.37409804
;               ;;       15.065824      0.59853353
;
;  KEYWORDS:    
;               XY         :  Set to a named variable to return the {X,Y}-coordinates of
;                               the intersections of the two input lines
;               SHOW_PLOT  :  If set, routine will create a new window and plot the
;                               results
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [09/09/2014   v1.0.0]
;             2)  Fixed an issue when the interval on 1st line extends beyond
;                   the last element
;                                                                   [01/25/2015   v1.0.1]
;
;   NOTES:      
;               0)  [Needs more testing...]
;               1)  Make sure abscissa ranges overlap otherwise the routine will be
;                     using INTERPOL.PRO to extrapolate beyond the bounds of the data
;
;  REFERENCES:  
;               
;
;   CREATED:  09/06/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/25/2015   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO find_intersect_2_curves,xx1,yy1,xx2,yy2,XY=xy,SHOW_PLOT=show_plot

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
bad_numin_msg  = 'Incorrect number of inputs!'
bad_xy1_in_msg = 'XX1(YY1) must be an [N]-element array...'
bad_xy2_in_msg = 'XX2(YY2) must be an [M]-element array...'
bad_n1n2___msg = 'XX1(YY1) and XX2(YY2) must have at least 4 elements...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 4)
IF (test) THEN BEGIN
  ;;  Must be 4 inputs supplied
  MESSAGE,bad_numin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF

nx1            = N_ELEMENTS(xx1)
nx2            = N_ELEMENTS(xx2)
ny1            = N_ELEMENTS(yy1)
ny2            = N_ELEMENTS(yy2)
test1          = (nx1[0] NE ny1[0])
test2          = (nx2[0] NE ny2[0])
test           = test1[0] OR test2[0]
IF (test[0]) THEN BEGIN
  ;;  # of abscissa must match number of dependent values
  IF (test1[0]) THEN MESSAGE,bad_xy1_in_msg[0],/INFORMATIONAL,/CONTINUE
  IF (test2[0]) THEN MESSAGE,bad_xy2_in_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF

test           = (nx1[0] LT 4L) OR (nx2[0] LT 4L)
IF (test[0]) THEN BEGIN
  ;;  Each input must have at least 4 elements
  MESSAGE,bad_n1n2___msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define relevant variables
;;----------------------------------------------------------------------------------------
;;  We want to upsample, so define the arrays with fewer points as line 1
;;    [order matters due to algorithm used for comparisons]
test           = (nx1[0] NE nx2[0])
IF (test[0]) THEN BEGIN
  ;;  Two sets of arrays have different #'s of elements
  CASE (nx1[0] LT nx2[0]) OF
    1  :  BEGIN
      ;;  Line 1 has fewer points
      x1             = REFORM(xx1)
      y1             = REFORM(yy1)
      x2             = REFORM(xx2)
      y2             = REFORM(yy2)
    END
    0  :  BEGIN
      ;;  Line 2 has fewer points
      x1             = REFORM(xx2)
      y1             = REFORM(yy2)
      x2             = REFORM(xx1)
      y2             = REFORM(yy1)
    END
  ENDCASE
ENDIF ELSE BEGIN
  ;;  Two sets of arrays have equal #'s of elements
  x1             = REFORM(xx1)
  y1             = REFORM(yy1)
  x2             = REFORM(xx2)
  y2             = REFORM(yy2)
ENDELSE
n              = N_ELEMENTS(x2)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
IF (KEYWORD_SET(show_plot)) THEN BEGIN
  WINDOW  ;;  Open new window and plot
  PLOT,x1,y1,PSYM=-2,/NODATA
    OPLOT,x1,y1,PSYM=-2,COLOR=250
    OPLOT,x2,y2,PSYM=-2,COLOR= 50
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define intervals with possible intersections
;;----------------------------------------------------------------------------------------
;;  Interpolate 1st line's Y-values to 2nd line's X-values
y1_at_x2       = INTERPOL(y1,x1,x2)
;;  Test where new Y-values are larger than 2nd line's Y-values
b              = (y1_at_x2 GT y2)
;;  Define intervals
diff_b         = b[0L:(n[0] - 2L)] - b[1L:*]
intervals      = WHERE(diff_b,ct)
IF (ct NE 0) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Possible intersections found --> test each
  ;;--------------------------------------------------------------------------------------
  ;;  Finite # of intervals to test
  xy = REPLICATE(d,2,ct)
  FOR i=0L, ct - 1L DO BEGIN
    ;;  Define index of interval
    j   = intervals[i]
    ;;  Define a 2-point segment of interval on 2nd line
    l2x = x2[j[0]:(j[0] + 1)]
    l2y = y2[j[0]:(j[0] + 1)]
    ;;  Find index of 1st line's X-value closest 2nd line's 2-point segment
    k   = VALUE_LOCATE(x1,l2x)
    m   = 0
    REPEAT BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Define {X[i],Y[i]} coordinates of intersection
      ;;----------------------------------------------------------------------------------
      ;;  LBW  01/25/2015   v1.0.1
      ;;  Check if k[m] = last element
      test = ((k[m] + 1L) GE N_ELEMENTS(x1))
      IF (test) THEN BEGIN
        ;;  Need to use k - 1 instead
        ;;    Define 2-point segment of interval on 1st line
        l1x  = x1[(k[m] - 1L):k[m]]
        l1y  = y1[(k[m] - 1L):k[m]]
      ENDIF ELSE BEGIN
        ;;  Check if k[m] = first element
        test = (k[m] LE 0)
        IF (test) THEN BEGIN
          ;;  Use first two elements
          l1x  = x1[0L:1L]
          l1y  = y1[0L:1L]
        ENDIF ELSE BEGIN
          ;;  Define 2-point segment of interval on 1st line
          l1x  = x1[k[m]:(k[m] + 1)]
          l1y  = y1[k[m]:(k[m] + 1)]
        ENDELSE
      ENDELSE
      ;;  Look for intersection in this interval
      code = seg_intersect(l1x,l1y,l2x,l2y,XY=tmp)
      b    = (code[0] EQ 1)
      IF (b[0]) THEN BEGIN
        xy[*,i] = tmp
        IF (KEYWORD_SET(show_plot)) THEN BEGIN
          ;;  Define bounds from currently shown plot
          xy_low = [!X.CRANGE[0],!Y.CRANGE[0]]
          ;;  Plot vertical line to intersection point
          PLOTS,[tmp[0],tmp[0]],[xy_low[1],tmp[1]],/DATA
          ;;  Plot horizontal line to intersection point
          PLOTS,[xy_low[0],tmp[0]],[tmp[1],tmp[1]],/DATA
        ENDIF
      ENDIF
      ;;  Increment index
      m++
    ENDREP UNTIL (b[0] OR (m[0] EQ 2))
  ENDFOR
ENDIF ELSE xy = REPLICATE(d,2)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END


