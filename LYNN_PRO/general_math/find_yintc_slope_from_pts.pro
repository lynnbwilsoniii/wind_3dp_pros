;+
;*****************************************************************************************
;
;  FUNCTION :   find_yintc_slope_from_pts.pro
;  PURPOSE  :   This routine finds the Y-intercept and slope of a straight line from
;                 two input coordinates.
;                   Y = m*X + b
;                   => Find [ m, b ]
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
;               X__IN  :  [2]-Element array of x-coordinates for the start and end
;                             points of a straight line
;               Y__IN  :  [2]-Element array of y-coordinates for the start and end
;                             points of a straight line
;
;  EXAMPLES:    
;               ;;  Define two points on line
;               xir    = [1.5,2.7]
;               yir    = [0.8,3.1]
;               ;;  Calculate the slope and Y-intercept
;               ymxb   = find_yintc_slope_from_pts(xir,yir)
;               ;;  Print results
;               PRINT, '  slope       = ', ymxb[0]
;                 slope       =       1.91667
;               PRINT, '  Y-intercept = ', ymxb[1]
;                 Y-intercept =      -2.07500
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Changed location to ~/general_math directory and cleaned up
;                                                                   [05/15/2014   v1.0.1]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               
;
;   CREATED:  07/16/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/15/2014   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION find_yintc_slope_from_pts,x__in,y__in

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
bad_xy_in_msg  = '[X,Y]__IN both must be [2]-element arrays...'
bad_numin_msg  = 'Incorrect number of inputs!'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 2)
IF (test) THEN BEGIN
  ;;  Must be 4 inputs supplied
  MESSAGE,bad_numin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy
ENDIF
test           = (N_ELEMENTS(x__in)  NE 2) OR (N_ELEMENTS(y__in)  NE 2)
IF (test) THEN BEGIN
  ;;  X__IN and Y__IN must have [2]-elements
  MESSAGE,bad_xy_in_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define new variables
;;----------------------------------------------------------------------------------------
x_i            = REFORM(x__in)
y_i            = REFORM(y__in)
nvx            = N_ELEMENTS(x_i)
nvy            = N_ELEMENTS(y_i)
;;  Define [X,Y] grid-spacing
dgsx           = (MAX(x_i,/NAN) - MIN(x_i,/NAN))/(nvx - 1L)
dgsy           = (MAX(y_i,/NAN) - MIN(y_i,/NAN))/(nvy - 1L)
;;----------------------------------------------------------------------------------------
;;  Define the slope and Y-intercept
;;----------------------------------------------------------------------------------------
;;  Calculate the slope
slope          = dgsy[0]/dgsx[0]
;;  Calculate the Y-intercept
y_intc_0       = y_i - slope[0]*x_i
y_intercept    = y_intc_0[0]
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,[slope[0],y_intercept[0]]
END
