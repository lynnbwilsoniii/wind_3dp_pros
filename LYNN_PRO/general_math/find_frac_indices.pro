;+
;*****************************************************************************************
;
;  FUNCTION :   find_frac_indices.pro
;  PURPOSE  :   This routine finds the fractional indices for an NxN array from
;                 an input set of coordinates.  The fractional indices are with
;                 respect to the regularly gridded inputs.
;
;  CALLED BY:   
;               find_1d_cuts_2d_dist.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               X__IN  :  [N]-Element array of regularly gridded coordinates
;                             corresponding to the 1st dimension in some function,
;                             f(x,y) [e.g., x-coordinate or independent coordinate]
;               Y__IN  :  [N]-Element array of regularly gridded coordinates
;                             corresponding to the 2nd dimension in some function,
;                             f(x,y) [e.g., y-coordinate or dependent coordinate]
;               X_OUT  :  [K]-Element array of coordinates for which to find the
;                             1st dimension indices of f(x,y)
;               Y_OUT  :  [K]-Element array of coordinates for which to find the
;                             2nd dimension indices of f(x,y)
;
;  EXAMPLES:    
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               ;;  Suppose you know the values of f @ {x_i,y_i}, where x_i and y_i are
;               ;;    the i-th values of the x- and y-coordinates which are evenly spaced
;               ;;    on a regular grid.  You wish to find the values of f @ {x_k,y_k}
;               ;;    where x_k and y_k are the k-th values of arbitrarily spaced
;               ;;    x- and y-coordinates.
;               ;;    
;               ;;    Below is an example to illustrate the above conundrum...
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               nr     = 10L         ;;  # of regularly gridded coordinates
;               ;;  Define the regularly spaced coordinates
;               xrg    = FINDGEN(nr)
;               yrg    = 2e0*xrg
;               ;;  Define the irregularly spaced coordinates on output
;               xir    = [1.5,2.7,3.8,4.2,7.3]
;               yir    = [0.8,3.1,5.6,6.9,8.7]
;               ;;  Find the fractional indices of these irregularly spaced coordinates
;               xyfind = find_frac_indices(xrg,yrg,xir,yir)
;               ;;  Print results
;               PRINT, xyfind.X_IND
;                     1.50000      2.70000      3.80000      4.20000      7.30000
;               PRINT, xyfind.Y_IND
;                    0.400000      1.55000      2.80000      3.45000      4.35000
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               ;;    Below is another example...
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               nr      = 50L
;               xrg     = FINDGEN(nr)
;               yrg     = xrg
;               ;;  Define 45 degree line through center
;               xir     = xrg*SIN(45d0*!DPI/18d1)
;               yir     = yrg*COS(45d0*!DPI/18d1)
;               ;;  Find slope and Y-intercept
;               ymxb    = find_yintc_slope_from_pts([MIN(xir,/NAN),MAX(xir,/NAN)],[MIN(yir,/NAN),MAX(yir,/NAN)])
;               ;;  Define new line from Y = m*X + b
;               xn      = 30L
;               xnew    = DINDGEN(xn)*(MAX(xrg,/NAN) - MIN(xrg,/NAN))/(xn - 1L)
;               ynew    = ymxb[0]*xnew + ymxb[1]
;               ;;  Find new indices
;               xyfind = find_frac_indices(xrg,yrg,xnew,ynew)
;               ;;  Print results
;               PRINT, xyfind.X_IND
;                      0.0000000       1.6896552       3.3793103       5.0689655
;                      6.7586207       8.4482759       10.137931       11.827586
;                      13.517241       15.206897       16.896552       18.586207
;                      20.275862       21.965517       23.655172       25.344828
;                      27.034483       28.724138       30.413793       32.103448
;                      33.793103       35.482759       37.172414       38.862069
;                      40.551724       42.241379       43.931034       45.620690
;                      47.310345       49.000000
;               PRINT, xyfind.Y_IND
;                      0.0000000       1.6896552       3.3793104       5.0689654
;                      6.7586207       8.4482756       10.137931       11.827586
;                      13.517241       15.206897       16.896551       18.586206
;                      20.275862       21.965517       23.655172       25.344828
;                      27.034483       28.724138       30.413794       32.103447
;                      33.793102       35.482758       37.172413       38.862068
;                      40.551723       42.241379       43.931034       45.620689
;                      47.310345       49.000000
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Changed location to ~/general_math directory and cleaned up
;                                                                   [05/15/2014   v1.0.1]
;
;   NOTES:      
;               1)  See also IDL's documentation of VALUE_LOCATE.PRO
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

FUNCTION find_frac_indices,x__in,y__in,x_out,y_out

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
bad_x__in_msg  = '[X,Y]__IN both must be [N]-element arrays, N=1,2,...'
bad_y_out_msg  = '[X,Y]_OUT both must be [K]-element arrays, K=1,2,...'
bad_numin_msg  = 'Incorrect number of inputs!'
;; => Create dummy return structure
tags           = ['X_IND','Y_IND']
dumb1d         = REPLICATE(d,10L)
dummy          = CREATE_STRUCT(tags,dumb1d,dumb1d)
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 4)
IF (test) THEN BEGIN
  ;;  Must be 4 inputs supplied
  MESSAGE,bad_numin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy
ENDIF
test           = (N_ELEMENTS(x__in)  EQ 0) OR (N_ELEMENTS(y__in)  EQ 0) OR $
                 (N_ELEMENTS(x__in)  NE N_ELEMENTS(y__in))
IF (test) THEN BEGIN
  ;;  X__IN and Y__IN must have the same number of elements
  MESSAGE,bad_x__in_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy
ENDIF
test           = (N_ELEMENTS(x_out) EQ 0) OR (N_ELEMENTS(y_out) EQ 0) OR $
                 (N_ELEMENTS(x_out)  NE N_ELEMENTS(y_out))
IF (test) THEN BEGIN
  ;;  X_OUT and Y_OUT must have the same number of elements
  MESSAGE,bad_y_out_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define new variables
;;----------------------------------------------------------------------------------------
x_i            = REFORM(x__in)
y_i            = REFORM(y__in)
x_o            = REFORM(x_out)
y_o            = REFORM(y_out)

nvx            = N_ELEMENTS(x_i)
nvy            = N_ELEMENTS(y_i)
;;  Define [X,Y] grid-spacing
dgsx           = (MAX(x_i,/NAN) - MIN(x_i,/NAN))/(nvx - 1L)
dgsy           = (MAX(y_i,/NAN) - MIN(y_i,/NAN))/(nvy - 1L)
;;----------------------------------------------------------------------------------------
;;  Find indices
;;----------------------------------------------------------------------------------------
;;  Find closest indices of original regularly gridded input velocities
testx          = VALUE_LOCATE(x_i,x_o)
testy          = VALUE_LOCATE(y_i,y_o)
;;  Calculate fraction of indices between indices
diffx          = (x_o - x_i[testx])/dgsx[0]
diffy          = (y_o - y_i[testy])/dgsy[0]
;;  Define fractional indices
index_x        = testx + diffx
index_y        = testy + diffy
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
tags           = ['X_IND','Y_IND']
struct         = CREATE_STRUCT(tags,index_x,index_y)
;;----------------------------------------------------------------------------------------
;;  Return structure to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END

