;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_zbrent.pro
;  PURPOSE  :   Find the zero of a 1-D function up to specified tolerance.
;                 This routine assumes that the function is known to have a zero.
;                 Adapted from procedure of the same name in "Numerical Recipes" by
;                 Press et al. (1992), Section 9.3
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               X1[2]           :  Scalar [numeric] that defines the lower[upper] bracket
;                                    location of function zero, i.e., F(x1) < 0 < F(x2).
;
;  EXAMPLES:    
;               [calling sequence]
;               xzero = lbw_zbrent(x1, x2, FUNC_NAME=func_name [,MAX_ITERATIONS=maxit] [,TOLERANCE=tol])
;
;               ;;  Example:  Find the root of the COSINE function between 1 and 2 radians
;               PRINT, lbw_zbrent(1e0,2e0,FUNC_NAME='COS')
;                     1.57080
;
;  KEYWORDS:    
;               FUNC_NAME       :  Scalar [string] defining the function name to call when
;                                    calculating the zeros.  The calling mechanism should
;                                    be:  f = func_name(px)
;                                    where:  px = scalar abscissa value
;                                             f = scalar value of function output
;               MAX_ITERATIONS  :  Scalar [string] defining the maximum number of iterations
;                                    [Default = 100]
;               TOLERANCE       :  Scalar [string] defining the desired accuracy of the
;                                    minimum location
;                                    [Default = 1e-3]
;
;   CHANGED:  1)  FV.1994, mod to check for single/double prec. and set zeps accordingly.
;                                                                   [??/??/1994   v1.0.?]
;             2)  Converted to IDL V5.0   W. Landsman
;                                                                   [09/??/1997   v1.0.?]
;             3)  Use MACHAR() to define machine precision   W. Landsman
;                                                                   [09/??/2002   v1.0.?]
;             4)  Cleaned up a little and renamed to lbw_zbrent.pro from zbrent.pro
;                                                                   [02/18/2019   v1.1.0]
;
;   NOTES:      
;               1)  Returns the location of zero, with accuracy of specified tolerance.
;               2)  Brent's method to find zero of a function by using bracketing,
;                     bisection, and inverse quadratic interpolation.
;
;  REFERENCES:  
;               "Numerical Recipes" by Press et al. (1992), Section 9.3
;
;   ADAPTED FROM: zbrent.pro    BY: Frank Varosi
;   CREATED:  ??/??/1992
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/18/2019   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_zbrent,x1,x2,FUNC_NAME=func_name,MAX_ITERATIONS=maxit,TOLERANCE=tol

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
def_mxiter     = 100L
def__toler     = 1e-3
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN BEGIN
  PRINT,'Syntax - result = ZBRENT( x1, x2, FUNC_NAME = ,'
  PRINT,'                  [ MAX_ITER = , TOLERANCE = ])'
  RETURN, -1
ENDIF
IF (SIZE(func_name,/TYPE) NE 7) THEN RETURN,-1
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(tol)   NE 1) THEN toler = def__toler[0] ELSE toler = tol[0]
IF (N_ELEMENTS(maxit) NE 1) THEN maxnn = def_mxiter[0] ELSE maxnn = LONG(maxit[0])
;;  Format input
IF (SIZE(x1,/TNAME) EQ 'DOUBLE' OR SIZE(x2,/TNAME) EQ 'DOUBLE') THEN BEGIN
  xa    = DOUBLE(x1)
  xb    = DOUBLE(x2)
  zeps  = (MACHAR(/DOUBLE)).EPS   ;;  machine epsilon in double.
ENDIF ELSE BEGIN
  xa    = x1
  xb    = x2
  zeps  = (MACHAR(/DOUBLE)).EPS   ;;  machine epsilon, in single 
ENDELSE
;;  Get function results
fa             = CALL_FUNCTION(func_name[0],xa)
fb             = CALL_FUNCTION(func_name[0],xb)
fc             = fb
;;  Check function outputs
IF (fb*fa GT 0) THEN BEGIN
  MESSAGE,"root must be bracketed by the 2 inputs",/INFORMATIONAL
  RETURN, xa
ENDIF
;;----------------------------------------------------------------------------------------
;;  Iterate to find zeros/minimum
;;----------------------------------------------------------------------------------------
FOR iter=1L, LONG(maxnn[0]) DO BEGIN
  IF (fb*fc GT 0) THEN BEGIN
    xc    = xa
    fc    = fa
    din   = xb - xa
    dold  = din
  ENDIF
  IF (ABS( fc ) LT ABS( fb )) THEN BEGIN
    xa = xb & xb = xc & xc = xa
    fa = fb & fb = fc & fc = fa
  ENDIF
  ;;  Check for convergence
  tol1  = 5e-1*toler[0] + 2*ABS(xb)*zeps[0]
  xm    = (xc - xb)/2e0
  IF (ABS(xm) LE tol1[0]) OR (fb EQ 0) THEN RETURN,xb      ;;  If converged --> Return to user
  ;;--------------------------------------------------------------------------------------
  ;;  Did not converge --> recalculate
  ;;--------------------------------------------------------------------------------------
  IF (ABS(dold) GE tol1[0]) AND (ABS(fa) GT ABS(fb)) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  attempt inverse quadratic interpolation
    ;;------------------------------------------------------------------------------------
    s    = fb/fa
    IF (xa EQ xc) THEN BEGIN
      p  =  2 * xm * s
      q  =  1 - s
    ENDIF ELSE BEGIN
      t  =  fa/fc
      r  =  fb/fc
      p  =  s * (2*xm*t*(t - r) - (xb - xa)*(r - 1) )
      q  =  (t - 1)*(r - 1)*(s - 1)
    ENDELSE
;    IF (p GT 0) THEN q = -q
    IF (p GT 0) THEN q *= -1
    p  = ABS(p)
    test = (3*xm*q - ABS(q*tol1[0])) < ABS(dold*q)
    IF (2*p LT test) THEN BEGIN
      ;;  accept interpolation
      dold = din
      din  = p/q
    ENDIF ELSE BEGIN
      ;;  use bisection instead
      din  = xm
      dold = xm
    ENDELSE
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Bounds decreasing to slowly, use bisection
    ;;------------------------------------------------------------------------------------
    din  = xm
    dold = xm
  ENDELSE
  ;;  evaluate new trial root
  xa = xb
  fa = fb
  ;;  Check result
  IF (ABS(din) GT tol1[0]) THEN xb = xb + din ELSE xb = xb + tol1[0]*(1 - 2*(xm LT 0))
  fb = CALL_FUNCTION(func_name[0],xb)
ENDFOR
;;  Failed to converge --> Inform user
MESSAGE,"exceeded maximum number of iterations: "+strtrim(iter,2),/INFORMATIONAL
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,xb
END