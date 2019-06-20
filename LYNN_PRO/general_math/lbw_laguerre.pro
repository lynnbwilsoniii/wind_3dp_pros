;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_laguerre.pro
;  PURPOSE  :   Computes the Laguerre polynomial value of order N with constant A
;                 at input point(s) X.  This differs from the built-in version in
;                 that it attempts to compute the coefficients even for N > 120,
;                 which begin to fail at large N in LAGUERRE.PRO because it does
;                 not use the Stirling approximation.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               lbw_ln_gamma.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X       :  Scalar or [K]-element [numeric] array of reals
;               N       :  Scalar [integer] defining the order of the Laguerre polynomial
;                            [Default = 0]
;               A       :  Scalar [integer] defining the constant of the generalized
;                            Laguerre polynomial
;                            [Default = 0]
;
;  EXAMPLES:    
;               [calling sequence]
;               lpoly = lbw_laguerre(x [,n] [,a] [,LCOEFF=lcoeff])
;
;  KEYWORDS:    
;               LCOEFF  :  Set to a named variable to return the coefficients of the
;                            terms in the sum used to construct the Laguerre polynomial
;                            Lpoly = C[0] + C[1]*X + C[2]*X^2 + ... + C[N]*x^N
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Stirling approximation:
;                 ln|Gamma(n)| ~ 1/2 ln|2πn| + n ln|n| - n + 1/(12 n) + 1/(360 n^3) + 
;                                1/(1260 n^5) - 1/(1680 n^7) + O[n^(-7)]
;                 From the following Mathematica v11.3.0.0 on 2019-06-16
;                   Series[Log[Gamma[z + 1]], {z, Infinity, 7}]
;                   Simplify[Normal[%]]
;               2)  If n ≤ 84 then numbers are computed directly
;               3)  This routine defines solutions to the ODE
;                     x y" + (A + 1 - x) y' + N y = 0
;               4)  The coefficients are formally defined as:
;                     LCOEFF(N,A,k) = (-1)^k Gamma(N + A + 1)/[ Gamma(N - k + 1) Gamma(k + A + 1) Gamma(k + 1) ]
;                   However, for large N the coefficients are first computed in log-space:
;                     Ln|(-1)^(-k) C_N,A,k| ~ ln|Gamma(N + A + 1)| - ln|Gamma(N - k + 1)| - ln|Gamma(k + A + 1)| - ln|Gamma(k + 1)|
;
;  REFERENCES:  
;               https://en.wikipedia.org/wiki/Gamma_function
;               https://en.wikipedia.org/wiki/Stirling%27s_approximation
;               https://en.wikipedia.org/wiki/Laguerre_polynomials
;
;   CREATED:  06/16/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/16/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_laguerre,x,n,a,LCOEFF=lcoeff

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
no_inpt__mssg  = 'User must supply X as a scalar or [K]-element [numeric] array...'
notreal__mssg  = 'Input X must be element of Reals...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (is_a_number(x,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (SIZE(x,/TYPE) EQ 6) OR (SIZE(x,/TYPE) EQ 9)
IF (test[0]) THEN BEGIN
  MESSAGE,notreal__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
CASE N_PARAMS() OF
  1    : BEGIN
    ;;  User only supplied X --> Use default for A and N
    n              = 0L
    a              = 0d0
  END
  2    : BEGIN
    ;;  User only supplied X and N --> Use default for A
    a              = 0d0
    n              = LONG(n[0]) > 0L
  END
  3    : BEGIN
    ;;  User only supplied X, N, and A --> Check them
    a              = DOUBLE(LONG(a[0])) > 0d0
    n              = LONG(n[0]) > 0L
  END
  ELSE : BEGIN
    ;;  What is the user doing???
    STOP
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Compute Laguerre polynomial
;;----------------------------------------------------------------------------------------
xx             = DOUBLE(REFORM(x))
nx             = N_ELEMENTS(xx)
IF (n[0] EQ 0) THEN BEGIN
  lpoly = 1d0 + 0d0*xx
ENDIF ELSE BEGIN
  ;;  Compute Laguerre polynomial from recursion relation
  lg0   = 1d0
  lg1   = 1d0 - xx + a[0]
  IF (n[0] EQ 1) THEN BEGIN
    lpoly = lg1
  ENDIF ELSE BEGIN
    ;;  Initialize
    lpoly = lg1
    ;;  Loop until up to order N
    FOR ii=2L, n[0] DO BEGIN
      ;;  Start by saving previous results for next iteration
      IF (ii EQ 2) THEN Lg_min2 = REPLICATE(lg0[0],nx[0]) ELSE Lg_min2 = Lg_min1    ;;  L[N-2,A](X)
      Lg_min1 = lpoly
      ;;  L[k+1,A](X) = ( (2k + 1 + A - X) L[k,A](X) - (k + A) L[k-1,A](X) )/(k + 1)
      ;;
      ;;  Let N = (k - 1)
      ;;
      ;;  -->  L[N,A](X) = ( (2N - 1 + A - X) L[N-1,A](X) - (N + A - 1) L[N-2,A](X) )/N
      lpoly   = ((2d0*ii[0] - 1d0 + a[0] - xx)*Lg_min1 - (ii[0] - 1d0 + a[0])*Lg_min2)/(1d0*ii[0])
    ENDFOR
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Compute Laguerre polynomial coefficients
;;----------------------------------------------------------------------------------------
large          = (n[0] GT 84)      ;;  Check if Stirling approximation is necessary
kk             = DINDGEN(n[0] + 1L)
IF (large[0]) THEN BEGIN
  ;;  N is large --> approximate
  ;;    Ln|(-1)^(-k) C_N,A,k| ~ ln|Gamma(N + A + 1)| - ln|Gamma(N - k + 1)| - ln|Gamma(k + A + 1)| - ln|Gamma(k + 1)|
  term0     = lbw_ln_gamma(n[0] + a[0] + 1d0)
  term1     = -1d0*lbw_ln_gamma(n[0] - kk + 1d0)
  term2     = -1d0*lbw_ln_gamma(kk + a[0] + 1d0)
  term3     = -1d0*lbw_ln_gamma(kk + 1d0)
  lncof     = term0 + term1 + term2 + term3
  lcoeff    = (-1d0)^(kk)*EXP(lncof)
  lcoeff[0] = 1d0     ;;  In case of infinities
ENDIF ELSE BEGIN
  ;;  N is small enough to compute directly
  ;;    LCOEFF(N,A,k) = (-1)^k Gamma(N + A + 1)/[ Gamma(N - k + 1) Gamma(k + A + 1) Gamma(k + 1) ]
  term0   = (-1d0)^(kk)*GAMMA(n[0] + a[0] + 1d0)
  term1   = GAMMA(n[0] - kk + 1d0)*GAMMA(kk + a[0] + 1d0)*GAMMA(kk + 1d0)
  lcoeff  = term0/term1
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,lpoly
END
