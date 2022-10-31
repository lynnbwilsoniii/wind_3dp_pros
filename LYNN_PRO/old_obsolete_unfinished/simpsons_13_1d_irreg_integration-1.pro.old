;+
;*****************************************************************************************
;
;  FUNCTION :   simpsons_13_1d_irreg_integration.pro
;  PURPOSE  :   This routine performs a 1D integration using Simpson's 1/3 Rule
;                 algorithm based upon user defined X and Y inputs.  This routine allows
;                 for an irregularly sampled X grid on input, unlike
;                 simpsons_13_1d_integration.pro, which requires a regular grid spacing.
;                 Note that if any additional factors are to be included, they should be
;                 done so prior to calling.
;
;                 The output result is given as follows:
;                   I = ∑_k H0[k]*(H1[k] + H2[k] + H3[k])
;                 where the Hj terms are given as follows:
;                   H0[k] =  (h[2k] + h[2k+1])/6
;                   H1[k] =  (2 - h[2k+1]/h[2k])*f[2k]
;                   H2[k] =  (h[2k] + h[2k+1])^2/(h[2k] * h[2k+1])*f[2k+1]
;                   H3[k] =  (2 - h[2k]/h[2k+1])*f[2k+2]
;                 where the h[k] terms are defined as:
;                   h[k]  = x[k+1] - x[k]
;                 and f[k] is the value of the function for the kth element.
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
;               X       :  [N]-Element [numeric] array of x-coordinate abscissa on an
;                            irregular grid.  If X is on a regular grid, then the
;                            simpsons_13_1d_integration.pro would be faster/better
;               Y       :  [N]-Element [numeric] array of y-function values for each
;                            X abscissa value
;
;  EXAMPLES:    
;               [calling sequence]
;               result = simpsons_13_1d_irreg_integration(x,y [,MAXERR=maxerr] [,/NOMSSG])
;
;               ;;  ***********************************************
;               ;;  Example comparison with IDL built-in QSIMP.PRO
;               ;;  ***********************************************
;               ;;  Integrate the function:
;               ;;    f(x) = (x^4 - 2 x^2) Sin(x)
;               ;;  on the interval [a,b] using IDL's built-in Simpson's 1/3 Rule
;               a     = 1d-3
;               b     = !DPI/2d0 + a[0]
;               lam1  = LAMBDA("X: (X^4d0 - 2d0 * X^2d0) * SIN(X)")         ;;  Generates an in-line function
;               testi = QSIMP(lam1,a,b,/DOUBLE,EPS=1d-12,JMAX=20)           ;;  Integrate using Simpson's 1/3 Rule
;               testi[0]
;                    -0.47800093006471039
;
;               ;;  Define exact value from integration by parts
;               ;;    ∫ dx f(x) = 4 x (x^2 - 7) Sin(x) - (28 + x^4 - 14 x^2) Cos(x)
;               ;;  Evaluate at end points and subtract to get exact result
;               fb    = 4d0*b[0]*(b[0]^2d0 - 7d0)*SIN(b[0]) - (b[0]^4d0 - 14d0*b[0]^2d0 + 28d0)*COS(b[0])
;               fa    = 4d0*a[0]*(a[0]^2d0 - 7d0)*SIN(a[0]) - (a[0]^4d0 - 14d0*a[0]^2d0 + 28d0)*COS(a[0])
;               exact = fb[0] - fa[0]
;               exact[0]
;                    -0.47800093006475208
;
;               ;;  Define percent difference between exact and numerical approximation
;               perc  = (testi[0] - exact[0])/exact[0]*1d2
;               perc[0]
;                 -8.7215049077472035e-12
;
;               ;;  Check irregular grid solutions
;               lneab = ALOG([a[0],b[0]])
;               nn    = 21L
;               lnexx = DINDGEN(nn[0])*(lneab[1] - lneab[0])/(nn[0] - 1L) + lneab[0]
;               xx    = EXP(lnexx)
;               yy    = (xx^4d0 - 2d0*xx^2d0)*SIN(xx)
;               .compile simpsons_13_1d_irreg_integration.pro
;               test  = simpsons_13_1d_irreg_integration(xx,yy,MAXERR=maxerr,/NOMSSG)
;               test[0], maxerr[0]
;                    -0.43960694803750966
;                   0.0016655923336171626
;
;               per0  = (test[0] - exact[0])/exact[0]*1d2
;               per0[0]
;                     -8.0321981846439936
;
;               ;;  Increase N to improve results
;               nn    = 121L
;               lnexx = DINDGEN(nn[0])*(lneab[1] - lneab[0])/(nn[0] - 1L) + lneab[0]
;               xx    = EXP(lnexx)
;               yy    = (xx^4d0 - 2d0*xx^2d0)*SIN(xx)
;               .compile simpsons_13_1d_irreg_integration.pro
;               test  = simpsons_13_1d_irreg_integration(xx,yy,MAXERR=maxerr,/NOMSSG)
;               test[0], maxerr[0]
;                    -0.47797643688062930
;                  1.1597214408514790e-05
;
;               per1  = (test[0] - exact[0])/exact[0]*1d2
;               per1[0]
;                  -0.0051240871266649921
;
;               ;;  Print improvement in accuracy
;               per0[0]/per1[0]
;                      1567.5373946796535
;
;               ;;  Note that (121d0/21d0)^4d0 ~ 1102.20988683
;               ;;    --> factor change in M ~ 1.42217686
;
;  KEYWORDS:    
;               LOG     :  If set and routine needs to regrid Z, then the interpolation
;                            will be done in logarithmic space
;                            [***  Obsolete  ***]
;               MAXERR  :  Set to a named variable to return the upper bound on the
;                            absolute error of the output integral result
;                            [Default = not calculated]
;               NOMSSG  :  If set, routine will not inform user of elapsed computational
;                            time
;                            [Default = FALSE]
;
;   CHANGED:  1)  Added keyword:  MAXERR and
;                   fixed a typo/bug in the H3[k] term so it now correctly uses the
;                   (2k + 2)-th element of f(x), not the (2k + 1)-th element
;                                                                   [01/19/2022   v1.0.1]
;
;   NOTES:      
;               0)  See also:  simpsons_13_2d_integration.pro and simpsons_13_3d_integration.pro
;               1)  N should be odd and must satisfy N > 6
;               2)  X and Y need NOT be on a regular grid for this routine, unlike
;                     simpsons_13_1d_integration.pro
;               3)  Primary differences from IDL built-in QSIMP.PRO is the user need not
;                     know the functional form of YY on input and the abscissa need not
;                     be regularly spaced
;
;  REFERENCES:  
;               http://mathfaculty.fullerton.edu/mathews/n2003/SimpsonsRule2DMod.html
;               http://www.physics.usyd.edu.au/teach_res/mp/doc/math_integration_2D.pdf
;               https://en.wikipedia.org/wiki/Simpson%27s_rule
;               https://openstax.org/books/calculus-volume-2/pages/3-6-numerical-integration
;
;   CREATED:  01/18/2022
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/19/2022   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION simpsons_13_1d_irreg_integration,x,y,LOG=log,MAXERR=maxerr,NOMSSG=nomssg

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
test           = (szdx[0] NE szdy[0]) OR (szdx[0] LT 6L)
IF (test[0]) THEN BEGIN
  MESSAGE,badddim__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check LOG  ***  Obsolete  ***
IF KEYWORD_SET(log) THEN log_on = 1b ELSE log_on = 0b
;;  Check MAXERR
IF (ARG_PRESENT(maxerr) NE 0) THEN calcerr = 1b ELSE calcerr = 0b
;;----------------------------------------------------------------------------------------
;;  Make sure N is odd so that # of intervals is even
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
nx             = N_ELEMENTS(xx)             ;;  # of elements in array
;;----------------------------------------------------------------------------------------
;;  Compute all h_k values (i.e., bin widths)
;;----------------------------------------------------------------------------------------
;;  Don't keep last element as that is negative
h_k            = (SHIFT(xx,-1) - xx)[0L:(nx[0] - 2L)]
nh             = N_ELEMENTS(h_k)            ;;  # of intervals
;;  Define 2i, 2i+1, and 2i+2 indices
ind            = LINDGEN(nh[0])
i2i            = ind[0L:*:2L]
i2ip1          = (i2i   + 1L) < (nx[0] - 1L)
i2ip2          = (i2ip1 + 1L) < (nx[0] - 1L)
;;  Define f_2i, f_2i+1, and f_2i+2 values
f_2i           = yy[i2i]
f_2ip1         = yy[i2ip1]
f_2ip2         = yy[i2ip2]
;;  Define h_2i and h_2i+1 values
h_2i           = h_k[i2i]
h_2ip1         = h_k[i2ip1]
;;----------------------------------------------------------------------------------------
;;  Compute all terms
;;----------------------------------------------------------------------------------------
;;  Define (h_2i + h_2i+1)/6
term0          = (h_2i + h_2ip1)/6d0
;;  Define (2 - h_2i+1/h_2i)*f_2i
term1          = (2d0 - h_2ip1/h_2i)*f_2i
;;  Define (h_2i + h_2i+1)^2/(h_2i * h_2i+1)*f_2i+1
term2          = (h_2i + h_2ip1)^2d0/(h_2i * h_2ip1)*f_2ip1
;;  Define (2 - h_2i/h_2i+1)*f_2i+2
term3          = (2d0 - h_2i/h_2ip1)*f_2ip2
;;  *** Clean up ***
delete_variable,h_2i,h_2ip1,f_2i,f_2ip1,f_2ip2,i2i,i2ip1,ind
;;----------------------------------------------------------------------------------------
;;  Sum over all terms
;;----------------------------------------------------------------------------------------
output         = TOTAL(term0*(term1 + term2 + term3),/NAN)
;;----------------------------------------------------------------------------------------
;;  Calculate error if user so wishes
;;----------------------------------------------------------------------------------------
IF (calcerr[0]) THEN BEGIN
  ;;  First, calculate d^4/dx^4 f(x)
  d4fdx4         = DERIV(xx,DERIV(xx,DERIV(xx,DERIV(xx,yy))))
  ;;  Check for "bad" outliers [be generous and allow for 100% differences]
  md_d4fdx4      = MEDIAN(ABS(d4fdx4))
  pc_d4fdx4      = (ABS(d4fdx4) - md_d4fdx4[0])/md_d4fdx4[0]*1d2
  bad_out        = WHERE(FINITE(pc_d4fdx4) EQ 0 OR ABS(pc_d4fdx4) GT 1d2,bd_out,COMPLEMENT=good_in,NCOMPLEMENT=gd_in)
  ;;  Compute maximum error:  M*(b - a)^5/(180*T^4)
  del_ab         = MAX(xx,/NAN) - MIN(xx,/NAN)
  IF (gd_in[0] GT 0) THEN BEGIN
    ;;  Use only the "good" elements for computing error
    mx_d4fdx4      = MAX(ABS(d4fdx4[good_in]),/NAN)
  ENDIF ELSE BEGIN
    ;;  Use all elements for computing error
    mx_d4fdx4      = MAX(ABS(d4fdx4),/NAN)
  ENDELSE
  maxerr         = mx_d4fdx4[0]*del_ab[0]^5d0/(18d1*nh[0]^4d0)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
ex_time        = SYSTIME(1) - ex_start[0]
IF ~KEYWORD_SET(nomssg) THEN MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL

RETURN,output[0]
END
















