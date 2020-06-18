;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_calc_area_arb_polygon.pro
;  PURPOSE  :   This routine calculates the area of an arbitrary polygon using Gauss'
;                 shoelace formula, given N-cartesian vertex points.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X       :  [N]-Element [numeric] array of x-coordinate vertices
;               Y       :  [N]-Element [numeric] array of y-coordinate vertices
;
;  EXAMPLES:    
;               [calling sequence]
;               area = lbw_calc_area_arb_polygon(x,y [,/NOMSSG])
;
;               ;;  Example
;               x    = [3,5,12,9,5]*1d0
;               y    = [4,11,8,5,6]*1d0
;               area = lbw_calc_area_arb_polygon(x,y) 
;               PRINT,';;  ',area
;               ;;         30.000000
;
;  KEYWORDS:    
;               NOMSSG  :  If set, routine will not inform user of elapsed computational
;                            time
;                            [Default = FALSE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The routine assumes that the points provided are already sorted into
;                     a clockwise order around the outer boundary of the polygon
;
;  REFERENCES:  
;               https://en.wikipedia.org/wiki/Shoelace_formula
;
;   CREATED:  05/18/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/18/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_calc_area_arb_polygon,x,y,NOMSSG=nomssg

ex_start       = SYSTIME(1)
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
no_inpt__mssg  = 'User must supply X and Y as [N]-element [numeric] arrays...'
badndim__mssg  = 'Inputs X and Y must be one-dimensional [numeric] arrays...'
badddim__mssg  = 'Inputs X and Y must be [N]-element [numeric] arrays...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (is_a_number(x,/NOMSSG) EQ 0) OR $
                 (is_a_number(y,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
szdx           = SIZE(x,/DIMENSIONS)
sznx           = SIZE(x,/N_DIMENSIONS)
szdy           = SIZE(y,/DIMENSIONS)
szny           = SIZE(y,/N_DIMENSIONS)
test           = (sznx[0] NE 1) OR (szny[0] NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,badndim__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (szdx[0] NE szdy[0]) OR (szdx[0] LT 3L)
IF (test[0]) THEN BEGIN
  MESSAGE,badddim__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Construct arrays
;;----------------------------------------------------------------------------------------
xx             = [x,x[0]]
yy             = [y,y[0]]
nx             = N_ELEMENTS(xx)
ii             = LINDGEN(nx[0] - 1L)
jj             = ii + 1L
;;----------------------------------------------------------------------------------------
;;  Compute summations
;;----------------------------------------------------------------------------------------
;;   +∑_i=0^(n-2) x_i y_i+1
sum1           = TOTAL(xx[ii]*yy[jj],/NAN)
;;   -∑_i=0^(n-2) x_i+1 y_i
sum2           = -1d0*TOTAL(xx[jj]*yy[ii],/NAN)
;;  Compute extra terms
ext1           = xx[nx[0] - 1L]*yy[0]
ext2           = -1d0*xx[0]*yy[nx[0] - 1L]
;;----------------------------------------------------------------------------------------
;;  Compute area
;;----------------------------------------------------------------------------------------
area           = ABS(sum1[0] + sum2[0] + ext1[0] + ext2[0])/2d0
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
ex_time        = SYSTIME(1) - ex_start[0]
IF ~KEYWORD_SET(nomssg) THEN MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL

RETURN,area[0]
END
