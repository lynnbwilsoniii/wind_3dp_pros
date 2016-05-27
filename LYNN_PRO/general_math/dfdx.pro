;+
;*****************************************************************************************
;
;  FUNCTION :   dfdx.pro
;  PURPOSE  :   Calculates the numerical derivative to 2nd order of an input function
;                 f = f(x) with respect to x.
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
;               X       :  N-Element array of independent variable
;               FX      :  N-Element array of dependent variable
;
;  EXAMPLES:    
;               x   = DINDGEN(100)*2d0*!DPI/99 - !DPI
;               y   = SIN(x)
;               dy  = COS(x)
;               dy2 = dfdx(x,y)
;               dy3 = dfdx(x,y,/LINEND)
;               PRINT, MAX(ABS(dy2 - dy),/NAN), MAX(ABS(dy3 - dy),/NAN)
;                   0.0013407742   0.00067119796
;
;  KEYWORDS:    
;               LINEND  :  If set, use a one sided linear approximation for end points
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This should be more accurate than the built-in DERIV.PRO
;
;   CREATED:  02/16/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/16/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION dfdx, x, fx, LINEND=linend

;-----------------------------------------------------------------------------------------
; => Define dummy variables and constants
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
bdmssg = 'The number of elements in X and F must match!'

;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
yy     = REFORM(fx)
xx     = REFORM(x)

nf     = N_ELEMENTS(yy)
nx     = N_ELEMENTS(xx)
IF (nx NE nf) THEN BEGIN
  MESSAGE,bdmssg,/INFORMATIONAL,/CONTINUE
  RETURN,REPLICATE(d,nf)
ENDIF
; => Define some dummy variables for elements of the arrays
l_el1  = nf - 1L
l_el2  = nf - 2L
l_el3  = nf - 3L


ym = SHIFT(yy,1)
yp = SHIFT(yy,-1)
xm = SHIFT(xx,1)
xp = SHIFT(xx,-1)
;-----------------------------------------------------------------------------------------
; => Calculate the derivative to 2nd order
;-----------------------------------------------------------------------------------------
; => Calculate the denominator
denom          = (xx - xm)*(xp - xm)*(xp - xx)
denom[0]       = denom[1]
denom[nf - 1L] = denom[l_el2]
; => calculate initial derivative without normalizing
dydx           = yp*(xx - xm)^2 + yy*(xp - xm)*(xp + xm - 2d0*xx) - ym*(xp - xx)^2
IF KEYWORD_SET(linend) THEN BEGIN
  dydx         /= denom
  dydx[0]       = (yy[1] - yy[0])/(xx[1] - xx[0])
  dydx[l_el1]   = (yy[l_el1] - yy[l_el2])/(xx[l_el1] - xx[l_el2])
ENDIF ELSE BEGIN
  dydx[0]       =  -yy[2]*(xx[1] - xx[0])^2 + yy[1]*(xx[2] - xx[0])^2 $
                  - yy[0]*(xx[2] - xx[1])*(xx[1] + xx[2] - 2d0*xx[0])
  dydx[l_el1]   =   yy[l_el1]*(xx[l_el2] - xx[l_el3])*(2*xx[l_el1] - xx[l_el2] - xx[l_el3]) $
                  - yy[l_el2]*(xx[l_el1] - xx[l_el3])^2 $
                  + yy[l_el3]*(xx[l_el1] - xx[l_el2])^2
  dydx         /= denom
ENDELSE

RETURN,dydx
END