;+
;*****************************************************************************************
;
;  FUNCTION :   simpsons_13_1d_integration.pro
;  PURPOSE  :   This routine performs a 1D integration using Simpson's 1/3 Rule
;                 algorithm based upon user defined X and Y inputs.  Note that if
;                 any additional factors are to be included, they should be done so
;                 prior to calling.
;
;                 The output result is given as follows:
;                   I = ∆x/3*(∑_k s[k] f[k])
;                 for N input values, where the terms are defined as follows:
;                   a(b)    =  start(end) value of abscissa, x
;                   T       = # of intervals (= N - 1)
;                   ∆x      =  (b - a)/T
;                   s[0]    = 1
;                   s[T]    = 1
;                   s[2k+1] = 4
;                   s[2k+2] = 2
;                 In other words, I can be abbreviated as:
;                   I = ∆x/3*(f[0] + 4*f[1] + 2*f[2] + 4*f[3] + 2*f[4] + ... + 4*f[T-1] + f[T])
;
;                 The error of the output is define as an upper bound on the error,
;                 given by the following inequality:
;                   E ≤ M*(b - a)^5/(180*T^4)
;                 where the terms are defined as follows:
;                   a(b)  =  start(end) value of abscissa, x
;                   M     = Max(| d^4/dx^4 f(x) |)
;                   T     = # of intervals (= N - 1)
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
;               result = simpsons_13_1d_integration(x,y [,/LOG] [,MAXERR=maxerr] [,/NOMSSG])
;
;               ;;  ***********************************************
;               ;;  Example comparison with IDL built-in QSIMP.PRO
;               ;;  ***********************************************
;               ;;  Integrate the function:
;               ;;    f(x) = (x^4 - 2 x^2) Sin(x)
;               ;;  on the interval [a,b] using IDL's built-in Simpson's 1/3 Rule
;               a     = 0d0
;               b     = !DPI/2d0
;               lam1  = LAMBDA("X: (X^4d0 - 2d0 * X^2d0) * SIN(X)")         ;;  Generates an in-line function
;               testi = QSIMP(lam1,a,b,/DOUBLE,EPS=1d-12,JMAX=20)           ;;  Integrate using Simpson's 1/3 Rule
;               testi[0]
;                    -0.47915881010723943
;
;               ;;  Define exact value from integration by parts
;               ;;    ∫ dx f(x) = 4 x (x^2 - 7) Sin(x) - (28 + x^4 - 14 x^2) Cos(x)
;               ;;  Evaluate at end points and subtract to get exact result
;               fb    = 4d0*b[0]*(b[0]^2d0 - 7d0)*SIN(b[0]) - (b[0]^4d0 - 14d0*b[0]^2d0 + 28d0)*COS(b[0])
;               fa    = 4d0*a[0]*(a[0]^2d0 - 7d0)*SIN(a[0]) - (a[0]^4d0 - 14d0*a[0]^2d0 + 28d0)*COS(a[0])
;               exact = fb[0] - fa[0]
;               exact[0]
;                    -0.47915881010719374
;
;               ;;  Define percent difference between exact and numerical approximation
;               perc  = (testi[0] - exact[0])/exact[0]*1d2
;               perc[0]
;                  9.5345585846798361e-12
;
;               nn    = 21L
;               xx    = DINDGEN(nn[0])*(b[0] - a[0])/(nn[0] - 1L) + a[0]
;               yy    = (xx^4d0 - 2d0*xx^2d0)*SIN(xx)
;               .compile simpsons_13_1d_integration.pro
;               test  = simpsons_13_1d_integration(xx,yy,MAXERR=maxerr,/NOMSSG)
;               test[0], maxerr[0]
;                    -0.47915407477924593
;                  3.3027859454524992e-05
;
;               perm  = (test[0] - exact[0])/exact[0]*1d2
;               perm[0]
;                 -0.00098825855810814683
;
;               ;;  Increase N to improve results
;               nn    = 121L
;               xx    = DINDGEN(nn[0])*(b[0] - a[0])/(nn[0] - 1L) + a[0]
;               yy    = (xx^4d0 - 2d0*xx^2d0)*SIN(xx)
;               .compile simpsons_13_1d_integration.pro
;               test  = simpsons_13_1d_integration(xx,yy,MAXERR=maxerr,/NOMSSG)
;               test[0], maxerr[0]
;                    -0.47915880651072734
;                  7.2568756213602116e-08
;
;               perm  = (test[0] - exact[0])/exact[0]*1d2
;               perm[0]
;                 -7.5057920810476773e-07
;
;  KEYWORDS:    
;               LOG     :  If set and routine needs to regrid Y, then the interpolation
;                            will be done in logarithmic space
;                            [Default = FALSE]
;               MAXERR  :  Set to a named variable to return the upper bound on the
;                            absolute error of the output integral result
;                            [Default = not calculated]
;               NOMSSG  :  If set, routine will not inform user of elapsed computational
;                            time
;                            [Default = FALSE]
;
;   CHANGED:  1)  Added keyword:  MAXERR
;                                                                   [01/19/2022   v1.0.1]
;
;   NOTES:      
;               0)  See also:  simpsons_13_2d_integration.pro and simpsons_13_3d_integration.pro
;               1)  N should be odd and must satisfy N > 7
;               2)  If X and Y are not on a regular, uniform grid then the routine
;                     will regrid the results before interpolation as the algorithm
;                     assumes a regular grid
;               3)  Primary difference from IDL built-in QSIMP.PRO is the user need not
;                     know the functional form of YY on input
;
;  REFERENCES:  
;               http://mathfaculty.fullerton.edu/mathews/n2003/SimpsonsRule2DMod.html
;               http://www.physics.usyd.edu.au/teach_res/mp/doc/math_integration_2D.pdf
;               https://en.wikipedia.org/wiki/Simpson%27s_rule
;               https://openstax.org/books/calculus-volume-2/pages/3-6-numerical-integration
;
;   CREATED:  08/05/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION simpsons_13_1d_integration,x,y,LOG=log,MAXERR=maxerr,NOMSSG=nomssg

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
test           = (szdx[0] NE szdy[0]) OR (szdx[0] LT 8L)
IF (test[0]) THEN BEGIN
  MESSAGE,badddim__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check LOG
IF KEYWORD_SET(log) THEN log_on = 1b ELSE log_on = 0b
;;  Check MAXERR
IF (ARG_PRESENT(maxerr) NE 0) THEN calcerr = 1b ELSE calcerr = 0b
;;----------------------------------------------------------------------------------------
;;  Make sure N is odd
;;----------------------------------------------------------------------------------------
nx             = N_ELEMENTS(x)
IF ((nx[0] MOD 2) EQ 0) THEN BEGIN
  ;;  N is currently even --> make odd
  xx             = x[0L:(nx[0] - 2L)]
  yy             = y[0L:(nx[0] - 2L)]
ENDIF ELSE BEGIN
  ;;  N is currently odd --> leave alone
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
;;  Calculate error if user so wishes
;;----------------------------------------------------------------------------------------
IF (calcerr[0]) THEN BEGIN
  ;;  First, calculate d^4/dx^4 f(x)
  d4fdx4         = DERIV(xg,DERIV(xg,DERIV(xg,DERIV(xg,fg))))
  ;;  Check for "bad" outliers [be generous and allow for 100% differences]
  md_d4fdx4      = MEDIAN(ABS(d4fdx4))
  pc_d4fdx4      = (ABS(d4fdx4) - md_d4fdx4[0])/md_d4fdx4[0]*1d2
  bad_out        = WHERE(FINITE(pc_d4fdx4) EQ 0 OR ABS(pc_d4fdx4) GT 1d2,bd_out,COMPLEMENT=good_in,NCOMPLEMENT=gd_in)
  ;;  Compute maximum error:  M*(b - a)^5/(180*T^4)
  del_ab         = MAX(xg,/NAN) - MIN(xg,/NAN)
  IF (gd_in[0] GT 0) THEN BEGIN
    ;;  Use only the "good" elements for computing error
    mx_d4fdx4      = MAX(ABS(d4fdx4[good_in]),/NAN)
  ENDIF ELSE BEGIN
    ;;  Use all elements for computing error
    mx_d4fdx4      = MAX(ABS(d4fdx4),/NAN)
  ENDELSE
  maxerr         = mx_d4fdx4[0]*del_ab[0]^5d0/(18d1*(nx[0] - 1d0)^4d0)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
ex_time        = SYSTIME(1) - ex_start[0]
IF ~KEYWORD_SET(nomssg) THEN MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL

RETURN,output[0]
END



