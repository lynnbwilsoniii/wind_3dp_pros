;+
;*****************************************************************************************
;
;  FUNCTION :   isleft2d.pro
;  PURPOSE  :   This routine tests if an array of points are Left|On|Right of an
;                 infinite 2D line.  The i-th output is as follows:
;                   > 0  :  {PX[i],PY[i]} left of the line through P0 to P1
;                   = 0  :  {PX[i],PY[i]} on the line through P0 to P1
;                   < 0  :  {PX[i],PY[i]} right of the line through P0 to P1
;
;  CALLED BY:   
;               poly_winding_number2d.pro
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
;               PX  :  [N]-Element [float/double] array defining the X-component of the
;                        points to test whether they lay to the right or left of the
;                        infinite 2D line passing through P0 to P1
;               PY  :  [N]-Element [float/double] array defining the Y-component of the
;                        points to test whether they lay to the right or left of the
;                        infinite 2D line passing through P0 to P1
;
;  EXAMPLES:    
;               ;;  Check for points to left of line
;               p0  = [-1.,1.]
;               p1  = [1.,-1.]
;               px  = RANDOMN(seed,5)
;               py  = RANDOMN(seed,5)
;               px *= (2d0/MAX(ABS(px),/NAN))
;               py *= (2d0/MAX(ABS(py),/NAN))
;               PRINT, FLOAT(px), FLOAT(py)
;                    -2.00000     0.183481     0.441949     -1.64878   -0.0838685
;                     1.20652      2.00000     -1.76505      1.79967      1.07329
;               PRINT, isleft2d(p0,p1,px,py) GT 0
;                  1   0   1   0   0
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Changed name so all letters are lower-case and updated Man. page
;                                                                   [05/15/2014   v1.1.0]
;             2)  Changed name to all lower case letters
;                   [I guess original edit was not implemented?]
;                   and fixed sign of of cross-product
;                                                                   [05/31/2016   v1.2.0]
;
;   NOTES:      
;               1)  This routine just calculates the cross-product between the lines
;                     from (P0 --> {PX,PY}) and (P0 --> P1), taking only the Z-component.
;
;  REFERENCES:  
;               1)  http://geomalgorithms.com/a03-_inclusion.html
;               2)  Numerical Recipes, 3rd Edition
;
;   CREATED:  04/22/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/31/2016   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION isleft2d,p0,p1,px,py

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
bad_p01_in_msg = 'P[0,1] must be [2]-element arrays...'
bad_pxy_in_msg = 'P[X,Y] must be [N]-element arrays...'
bad_numin_msg  = 'Incorrect number of inputs!'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 4)
IF (test) THEN BEGIN
  ;;  Must be 4 inputs supplied
  MESSAGE,bad_numin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF

test           = (N_ELEMENTS(p0)  NE 2) OR (N_ELEMENTS(p1)  NE 2)
IF (test) THEN BEGIN
  ;;  P[0,1] BOTH must have [2]-elements
  MESSAGE,bad_p01_in_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF

test           = (N_ELEMENTS(px) NE N_ELEMENTS(py)) OR (SIZE(px,/N_DIMENSIONS) GT 1) $
                 OR (SIZE(px,/N_DIMENSIONS) GT 1)
IF (test) THEN BEGIN
  ;;  P[X,Y] BOTH must have [N]-elements
  MESSAGE,bad_pxy_in_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define new variables
;;----------------------------------------------------------------------------------------
;;  Vector from P0 to P1
r10            = [(p1[0] - p0[0]),(p1[1] - p0[1])]
;;  Vector(s) from P0 to {PX[i],PY[i]}
np             = N_ELEMENTS(px)
ri0            = REPLICATE(d,np,2L)
ri0[*,0]       = REFORM(px) - p0[0]
ri0[*,1]       = REFORM(py) - p0[1]
;;----------------------------------------------------------------------------------------
;;  Calculate Z-component of cross-product
;;----------------------------------------------------------------------------------------
zcomp          = ri0[*,1]*r10[0] - ri0[*,0]*r10[1]
;zcomp          = ri0[*,0]*r10[1] - ri0[*,1]*r10[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,zcomp
END



