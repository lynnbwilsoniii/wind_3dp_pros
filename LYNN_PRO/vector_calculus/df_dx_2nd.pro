;+
;*****************************************************************************************
;
;  FUNCTION :   df_dx_2nd.pro
;  PURPOSE  :   Calculates the numerical derivative up to 4th order of an input
;                 function f = f(x) with respect to x.  The order of the
;                 approximation depends on the number of input points.  To get
;                 a 4th order approximation, there needs to be > 5 input points
;                 and ≥ 3 for 2nd order.
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
;               X       :  [N]-Element [float/double] array of independent values
;               FX      :  [N]-Element [float/double] array of dependent values
;
;  EXAMPLES:    
;               ;;  We know the derivative of sine is cosine, so test it
;               x      = DINDGEN(100)*2d0*!DPI/99 - !DPI
;               y      = SIN(x)
;               dy     = COS(x)
;               dy2s   = df_dx_2nd(x,y,/SECOND)
;               dy2l   = df_dx_2nd(x,y,/LINEND,/SECOND)
;               dy3    = DERIV(x,y)
;               dy4    = df_dx_2nd(x,y)
;               ddy2s  = ABS(dy2s - dy)
;               ddy2l  = ABS(dy2l - dy)
;               ddy3   = ABS(dy3 - dy)
;               ddy4   = ABS(dy4 - dy)
;               ;;  Calculate moments
;               mom2s  = [MIN(ddy2s,/NAN),MAX(ddy2s,/NAN),MEAN(ddy2s,/NAN),STDDEV(ddy2s,/NAN)]
;               mom2l  = [MIN(ddy2l,/NAN),MAX(ddy2l,/NAN),MEAN(ddy2l,/NAN),STDDEV(ddy2l,/NAN)]
;               mom3   = [MIN(ddy3,/NAN),MAX(ddy3,/NAN),MEAN(ddy3,/NAN),STDDEV(ddy3,/NAN)]
;               mom4   = [MIN(ddy4,/NAN),MAX(ddy4,/NAN),MEAN(ddy4,/NAN),STDDEV(ddy4,/NAN)]
;               ;;  Print results
;               PRINT, mom2s
;                  1.0649203e-05    0.0013407742   0.00044314617   0.00024219271
;               PRINT, mom2l
;                  1.0649203e-05   0.00067119796   0.00042975465   0.00020796472
;               PRINT, mom3
;                  1.0649203e-05    0.0013407742   0.00044314617   0.00024219271
;               PRINT, mom4
;                  8.1063603e-07    0.0080403333   0.00018786666    0.0010132585
;
;  KEYWORDS:    
;               LINEND  :  If set, use a one sided linear approximation for end points
;               SECOND  :  If set, routine uses 2nd order derivative instead of 4th order
;
;   CHANGED:  1)  Continued to write routine
;                                                                  [08/04/2013   v1.0.0]
;
;   NOTES:      
;               1)  This should be more accurate than the built-in DERIV.PRO
;               2)  Currently, LINEND only works for 2nd order derivative
;               3)  Currently, the end points for the 4th order derivative is kind of
;                     a kludge...
;
;   CREATED:  08/03/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/04/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION df_dx_2nd,x,fx,LINEND=linend,SECOND=second

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
bad_n_in_msg   = 'Incorrect number of inputs!'
bad_xfx_msg    = 'X and FX both must be [N]-element arrays, N=1,2,...'
bad_nxfx_msg   = 'N must be greater than or equal to 3!'
bad_n_xfx_msg  = 'The number of elements in X and F must match!'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 2)
IF (test) THEN BEGIN
  ;;  Must be 2 inputs supplied
  MESSAGE,bad_n_in_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF

nx0            = N_ELEMENTS(x)
nf0            = N_ELEMENTS(fx)
test           = (nx0[0] EQ 0) OR (nf0[0] EQ 0)
IF (test) THEN BEGIN
  ;;  Inputs must be [N]-element arrays
  MESSAGE,bad_xfx_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF

test           = (nx0[0] LT 3) OR (nf0[0] LT 3)
IF (test) THEN BEGIN
  ;;  N ≥ 3
  MESSAGE,bad_nxfx_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF

test           = (nx0[0] NE nf0[0])
IF (test) THEN BEGIN
  ;;  N[x] ≠ N[f(x)]
  MESSAGE,bad_n_xfx_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,d
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define new variables
;;----------------------------------------------------------------------------------------
yy0            = REFORM(fx)
xx0            = REFORM(x)
nf             = N_ELEMENTS(yy0)
;;  Define shifted (-) arrays
ym2            = SHIFT(yy0,2)
ym1            = SHIFT(yy0,1)
xm2            = SHIFT(xx0,2)
xm1            = SHIFT(xx0,1)
;;  Define shifted (+) arrays
yp2            = SHIFT(yy0,-2)
yp1            = SHIFT(yy0,-1)
xp2            = SHIFT(xx0,-2)
xp1            = SHIFT(xx0,-1)
;;----------------------------------------------------------------------------------------
;;  Approximate derivative
;;----------------------------------------------------------------------------------------
l_el1          = nf - 1L
l_el2          = nf - 2L
l_el3          = nf - 3L

test2nd        = (nf GT 5) AND ~KEYWORD_SET(second)
IF (test2nd) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Use 4th-order approximation
  ;;--------------------------------------------------------------------------------------
  ;;  Define X-terms
  axx            = xx0 - xm2
  bxx            = xx0 - xm1
  cxx            = xp1 - xm2
  dxx            = xp1 - xm1
  exx            = xp1 - xx0
  fxx            = xp2 - xm2
  gxx            = xp2 - xm1
  hxx            = xp2 - xx0
  ixx            = xp2 - xp1
  jxx            = xm1 + xm2
  kxx            = xm1 - xm2
;  lxx            = xx0 + xp1
;  mxx            = xm1*xm2
  ;;  Define Y-terms
  ayy            = yy0 - ym2
  byy            = yy0 - ym1
  cyy            = yp1 - ym2
  dyy            = yp1 - ym1
  eyy            = yp1 - yy0
  fyy            = yp2 - ym2
  gyy            = yp2 - ym1
  hyy            = yp2 - yy0
  iyy            = yp2 - yp1
  jyy            = ym1 + ym2
  kyy            = ym1 - ym2
;  lyy            = yy0 + yp1
;  myy            = ym1*ym2
  ;;  Define derivative factors
  f00            = kyy/kxx
  tau            = byy/bxx - f00
  gam            = eyy/exx - byy/bxx
  zet            = iyy/ixx - eyy/exx
  ;;  Define derivative terms
  f1a            = (gam/dxx - tau/axx)
  f11            = (axx*bxx*f1a)/cxx
  f22            = ((2d0*xx0 - jxx)*tau)/axx
  f3a            = (zet/hxx - gam/dxx)/gxx
  f3b            = (gam/dxx - tau/axx)/cxx
  f33            = (axx*bxx*exx*(f3a - f3b))/fxx
  ;;  Define derivative
  dydx           = f00 + f11 + f22 + f33
  ;;  Fix endpoints
  dydx[0:1]      = dydx[2]
  dydx[l_el1]    = dydx[l_el2]
;  f11            = ((2d0*xx0 - jxx)*(byy/bxx - f00))/axx
;  f2a            = (eyy/exx - byy/bxx)/dxx
;  f2b            = (byy/bxx - f00)/axx
;  f22            = (f2a - f2b)*axx*bxx/cxx
;  f3a            = (2d0*xx0^2 - 1d0)*(lxx + jxx)
;  f3b            = xx0*(2d0*xx0^2 + mxx + jxx*xp1)
;  f33            = (f3a + f3b - xp1*mxx)/fxx
;  f4a            = (iyy/ixx - eyy/exx)/hxx
;  f4b            = (eyy/exx - byy/bxx)/dxx
;  f44            = (f4a - f4b)/gxx
;  f5a            = (eyy/exx - byy/bxx)/dxx
;  f5b            = (byy/bxx - f00)/axx
;  f55            = (f5a - f5b)/cxx
;  ;;  Define derivative
;  dydx           = f00 + f11 + f22 + f33*(f44 - f55)
ENDIF ELSE BEGIN
  ;;  Use 2nd-order approximation
  denom          = (xx0 - xm1)*(xp1 - xm1)*(xp1 - xx0)
  denom[0]       = denom[1]
  denom[l_el1]   = denom[l_el2]
  ;;  calculate initial derivative without normalizing
  dydx           = yp1*(xx0 - xm1)^2 + yy0*(xp1 - xm1)*(xp1 + xm1 - 2d0*xx0) - ym1*(xp1 - xx0)^2
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Fix endpoints
;;----------------------------------------------------------------------------------------
test2nd        = (nf LE 5) OR KEYWORD_SET(second)
IF (test2nd) THEN BEGIN
  IF KEYWORD_SET(linend) THEN BEGIN
    dydx         /= denom
    dydx[0]       = (yy0[1] - yy0[0])/(xx0[1] - xx0[0])
    dydx[l_el1]   = (yy0[l_el1] - yy0[l_el2])/(xx0[l_el1] - xx0[l_el2])
  ENDIF ELSE BEGIN
    dydx[0]       =  -yy0[2]*(xx0[1] - xx0[0])^2 + yy0[1]*(xx0[2] - xx0[0])^2 $
                    - yy0[0]*(xx0[2] - xx0[1])*(xx0[1] + xx0[2] - 2d0*xx0[0])
    dydx[l_el1]   =   yy0[l_el1]*(xx0[l_el2] - xx0[l_el3])*(2*xx0[l_el1] - xx0[l_el2] - xx0[l_el3]) $
                    - yy0[l_el2]*(xx0[l_el1] - xx0[l_el3])^2 $
                    + yy0[l_el3]*(xx0[l_el1] - xx0[l_el2])^2
    dydx         /= denom
  ENDELSE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,dydx
END






















