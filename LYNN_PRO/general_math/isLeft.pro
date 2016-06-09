;+
;*****************************************************************************************
;
;  FUNCTION :   isleft.pro
;  PURPOSE  :   This routine tests if a point is Left|On|Right of an infinite 2D line.
;                 The outputs are as follows:
;                   > 0  :  P2 left of the line through P0 to P1
;                   = 0  :  P2 on the line through P0 to P1
;                   < 0  :  P2 right of the line through P0 to P1
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               P0  :  [2]-Element [float/double] array defining the start point of a
;                        ray used to define the infinite 2D line
;                        { P0[0] --> X-component, P0[1] --> Y-component }
;               P1  :  [2]-Element [float/double] array defining the end point of a
;                        ray used to define the infinite 2D line
;               P2  :  [2]-Element [float/double] array defining the point to test
;                        whether it lay to the right or left of the infinite 2D line
;                        passing through P0 to P1
;
;  EXAMPLES:    
;               ;;  Check for point to right of line
;               p0 = [1.,4.]
;               p1 = [2.,1.]
;               p2 = [3.,3.]
;               PRINT, isLeft(p0,p1,p2)
;                    -5.00000
;
;               ;;  Check for point to left of line
;               p0 = [1.,4.]
;               p1 = [2.,1.]
;               p2 = [0.,0.]
;               PRINT, isLeft(p0,p1,p2)
;                     7.00000
;
;               ;;  Check for point on line
;               p0 = [1.,1.]
;               p1 = [4.,4.]
;               p2 = [3.,3.]
;               PRINT, isLeft(p0,p1,p2)
;                     0.00000
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Changed name to all lower case letters and fixed sign of
;                   of cross-product
;                                                                   [05/31/2016   v1.1.0]
;
;   NOTES:      
;               1)  This routine just calculates the cross-product between the lines
;                     from (P0 --> P2) and (P0 --> P1), taking only the z-component.
;
;  REFERENCES:  
;               See Numerical Recipes on "winding number"
;
;   CREATED:  04/21/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/31/2016   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION isleft,p0,p1,p2

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
bad_xy_in_msg  = 'P[0,1,2] must be [2]-element arrays...'
bad_numin_msg  = 'Incorrect number of inputs!'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 3)
IF (test) THEN BEGIN
  ;;  Must be 4 inputs supplied
  MESSAGE,bad_numin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF

test           = (N_ELEMENTS(p0)  NE 2) OR (N_ELEMENTS(p1)  NE 2) OR (N_ELEMENTS(p2)  NE 2)
IF (test) THEN BEGIN
  ;;  P[0,1,2] ALL must have [2]-elements
  MESSAGE,bad_xy_in_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define new variables
;;----------------------------------------------------------------------------------------
;;  ∆X_10  =  P1[0] - P0[0]
dx_10          = p1[0] - p0[0]
;;  ∆Y_10  =  P1[0] - P0[0]
dy_10          = p1[1] - p0[1]
;;  ∆X_20  =  P2[0] - P0[0]
dx_20          = p2[0] - p0[0]
;;  ∆Y_20  =  P2[1] - P0[1]
dy_20          = p2[1] - p0[1]
;;----------------------------------------------------------------------------------------
;;  Test point P2 (just Z-component of cross product)
;;----------------------------------------------------------------------------------------
test           = dx_10[0]*dy_20[0] - dx_20[0]*dy_10[0]
;test           = dx_20[0]*dy_10[0] - dx_10[0]*dy_20[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,test[0]
END




























