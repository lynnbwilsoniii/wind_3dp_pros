;+
;*****************************************************************************************
;
;  FUNCTION :   simpsons_13_1d_integration.pro
;  PURPOSE  :   This routine performs a 1D integration using Simpson's 1/3 Rule
;                 algorithm based upon user defined X and Y inputs.  Note that if
;                 any additional factors are to be included, they should be done so
;                 prior to calling.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               delete_variable.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X       :  [N]-Element [numeric] array of x-coordinate abscissa
;               Y       :  [N]-Element [numeric] array of y-function values for each
;                            X abscissa value
;
;  EXAMPLES:    
;               [calling sequence]
;               result = simpsons_13_1d_integration(x,y [,/LOG] [,/NOMSSG])
;
;  KEYWORDS:    
;               LOG     :  If set and routine needs to regrid Z, then the interpolation
;                            will be done in logarithmic space
;                            [Default = FALSE]
;               NOMSSG  :  If set, routine will not inform user of elapsed computational
;                            time
;                            [Default = FALSE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               0)  See also:  simpsons_13_2d_integration.pro and simpsons_13_3d_integration.pro
;               1)  N should be odd and must satisfy N > 9
;               2)  If X and Y are not on a regular, uniform grid then the routine
;                     will regrid the results before interpolation as the algorithm
;                     assumes a regular grid
;
;  REFERENCES:  
;               http://mathfaculty.fullerton.edu/mathews/n2003/SimpsonsRule2DMod.html
;               http://www.physics.usyd.edu.au/teach_res/mp/doc/math_integration_2D.pdf
;               https://en.wikipedia.org/wiki/Simpson%27s_rule
;
;   CREATED:  08/05/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION simpsons_13_1d_integration,x,y,LOG=log,NOMSSG=nomssg

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
test           = (N_PARAMS() LT 2) OR (is_a_number(x,/NOMSSG) EQ 0) OR $
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
test           = (szdx[0] NE szdy[0]) OR (szdx[0] LT 9L)
IF (test[0]) THEN BEGIN
  MESSAGE,badddim__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(log) THEN log_on = 1b ELSE log_on = 0b
;;----------------------------------------------------------------------------------------
;;  Make sure N is odd
;;----------------------------------------------------------------------------------------
nx             = N_ELEMENTS(x)
IF ((nx[0] MOD 2) EQ 0) THEN BEGIN
  ;;  N is currently even --> make odd
  xx             = x[0L:(nx[0] - 2L)]
  yy             = y[0L:(nx[0] - 2L)]
ENDIF ELSE BEGIN
  xx             = REFORM(x)
  yy             = REFORM(y)
ENDELSE
xran           = [MIN(xx,/NAN),MAX(xx,/NAN)]
yran           = [MIN(yy,/NAN),MAX(yy,/NAN)]
nx             = N_ELEMENTS(xx)
;;----------------------------------------------------------------------------------------
;;  Regardless, make sure on uniform grid
;;----------------------------------------------------------------------------------------
dx             = (xran[1] - xran[0])/(nx[0] - 1L)
xg             = DINDGEN(nx[0])*dx[0] + xran[0]
;;  Find closest indices of original regularly gridded input velocities
ii             = LINDGEN(nx[0])
testx          = VALUE_LOCATE(xx,xg)
dfx            = testx - ii
test           = (TOTAL(dfx NE 0) GT 0)
IF (test[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Need to regrid input
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate fraction of indices between indices
  diffx          = (xg - xx[testx])/dx[0]
  ;;  Define fractional indices
  index_x        = testx + diffx
  ;;  Regrid F
  IF (log_on[0]) THEN BEGIN
    fg             = 1d1^(INTERPOLATE(ALOG10(yy),index_x,MISSING=d,/DOUBLE,/GRID))
  ENDIF ELSE BEGIN
    fg             = INTERPOLATE(yy,index_x,MISSING=d,/DOUBLE,/GRID)
  ENDELSE
  ;;  Clean up
  delete_variable,diffx,index_x
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  No need to regrid input
  ;;--------------------------------------------------------------------------------------
  fg             = yy
ENDELSE
nx             = N_ELEMENTS(xg)
;;  Should not have changed, but just in case...
xran           = [MIN(xg,/NAN),MAX(xg,/NAN)]
yran           = [MIN(fg,/NAN),MAX(fg,/NAN)]
;;  *** Clean up ***
delete_variable,xx,yy,testx,dfx,ii
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  1D Simpson's 1/3 Rule
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Construct Simpson's 1/3 Rule 1D coefficients
sc             = REPLICATE(1d0,nx[0])
sc[1:(nx[0] - 2L):2] *= 4d0              ;;  Start at 2nd element and every other element should be 4
sc[2:(nx[0] - 3L):2] *= 2d0              ;;  Start at 3rd element and every other element should be 2
sc[(nx[0] - 1L)]      = 1d0              ;;  Make sure last element is 1
;;  Define h-factors for 1D Simpson's 1/3 Rule
hfac           = dx[0]/3d0
;;----------------------------------------------------------------------------------------
;;  Compute 1D integral of input
;;----------------------------------------------------------------------------------------
output         = TOTAL(hfac[0]*sc*fg,/NAN)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
ex_time        = SYSTIME(1) - ex_start[0]
IF ~KEYWORD_SET(nomssg) THEN MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL

RETURN,output[0]
END



