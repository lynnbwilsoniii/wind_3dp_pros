;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_dawson_int.pro
;  PURPOSE  :   This routine calculates the Dawson Integral, defined as:
;                     D±(z)   = e^(-/+ x^2) ∫ dt e^(± t^2)  [integrated from 0 to z]
;                     D+(z)   = π^(1/2)/2 e^(-z^2) erfi(z)
;                             = -i/2 π^(1/2) e^(-z^2) erf(i z)
;
;                     D-(z)   = π^(1/2)/2 e^(+z^2) erf(z)
;                             = 
;
;                     erf(z)  = 2/π ∫ dt e^(-t^2)  [integrated from 0 to z]
;                             = error function
;                     erfi(z) = -i erf(i z)
;
;                 *** This routine will focus solely on D+(z). ***
;
;                 We can also relate D+(z) to the complex error function, erfc(x), through:
;                     D+(z)   = i/2 π^(1/2) e^(-z^2) [1 - erfc(-i z)]
;                 which has a neat approximation [Rybicki, 1989] given by:
;                     D+(z)   = Lim_{h --> 0} π^(-1/2) ∑_{n odd} n^(-1) e^-(z - n h)^2
;                 The accuracy of this approximation increases exponentially as h --> 0.
;                 We need to shift the summation index so it is centered on roughly the
;                 maximum exponent term.  So we let:
;                     no      = even integer nearest to x/h
;                     xo      = no h
;                     x'      = x - xo
;                     n'      = n - no
;                 so that we can rewrite the above in approximation form as:
;                     D+(z)   ≈ π^(-1/2) ∑_{(n' odd) = -N}^N (n' + no)^(-1) e^-(x' - n' h)^2
;                 We can speed up our computations by noting that:
;                     e^-(x' - n' h)^2 = e^(-x'^2) e^-(n' h)^2 ( e^(2 x' h) )^(n')
;                 where the first factor, e^(-x'^2), is computed once, the second factor,
;                 e^-(n' h)^2, is an array of constants one stores for later, and the
;                 third factor, ( e^(2 x' h) )^(n'), can be computed recursively such that
;                 only two exponentials need be evaluated.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               sign.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X       :  Scalar [numeric] defining the argument of the Dawson integral
;
;  EXAMPLES:    
;               [calling sequence]
;               
;
;  KEYWORDS:    
;               NMAX    :  Scalar [long] defining the number of positive and negative
;                            elements to sum in the series approximation.  There is no
;                            need to exceed 20, so the input will be confined to 6--20
;                            [Default = 6]
;               H       :  Scalar [numeric] defining the small constant offset used to
;                            approximate the Dawson Integral.  This value will be
;                            confined to the range 10^(-4) to 0.8
;                            [Default = 4d-1]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               0)  Rybicki, G.B. "Dawson's Integral and the Sampling Theorem,"
;                     Computers in Physics 3(2), pp. 85, doi:10.1063/1.4822832, 1989.
;               1)  Cody, J.W., Paciorek, K.A., and Thatcher Jr., H.C. "Chebyshev
;                     Approximations for Dawson's Integral," Mathematics of Computation
;                     24(109), pp. 171--178, doi:10.2307/2004886, 1970.
;               2)  McCabe, J.H. "A continued fraction expansion, with a truncation error
;                     estimate, for Dawson’s integral," Mathematics of Computation 28,
;                     pp. 811--816, doi:10.1090/S0025-5718-1974-0371020-3, 1974.
;
;   CREATED:  06/05/2026
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/05/2026   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_dawson_int,x,NMAX=nmax0,H=h0

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_nmax       = 6L
def_hcon       = 4d-1
;;  Define series expansion coefficients for approximation below
aa1            = 2d0/3d0
aa2            = 2d0/5d0
aa3            = 2d0/7d0
aa4            = 4d0/63d0
aa5            = 8d0/693d0
;;  Dummy error messages
noinpt_msg     = 'User must supply the argument of the Dawson integral...'
notnum_msg     = 'The argument of the Dawson integral must be a scalar numeric value...'
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 1) THEN BEGIN
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
IF (is_a_number(x,/NOMSSG) EQ 0) THEN BEGIN
  MESSAGE,notnum_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define argument of the Dawson integral
xx             = x[0]
IF (SIZE(xx,/TYPE) EQ 6 OR SIZE(xx,/TYPE) EQ 9) THEN cmplx_on = 1b ELSE cmplx_on = 0b
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check NMAX
IF (is_a_number(nmax0,/NOMSSG) EQ 0) THEN nmax = def_nmax[0] ELSE nmax = ((LONG(nmax0))[0] > 6L) < 20L
;;  Check H
IF (is_a_number(nmax0,/NOMSSG) EQ 0) THEN hh   = def_hcon[0] ELSE hh   = ((DOUBLE(h0))[0] > 1d-4) < 8d-1
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Initialize constants
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
cc             = REPLICATE(d,nmax[0])
FOR j=0L, nmax[0] - 1L DO BEGIN
  cc[j]          = EXP(-1d0*( hh[0]*(2d0*j[0] + 1d0) )^2d0)
ENDFOR
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Compute Dawson integral
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
IF (ABS(xx[0]) LT 2d-1) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Use series expansion:
  ;;    D+(z) = ∑_{k=0}^{infty} [ (-1)^k k! 2^(2k) z^(2k + 1) ] / (2k + 1)!
  ;;          ≈ z - 2/3 z^3 + 4/15 z^5 - 8/105 z^7 + 16/945 z^9 - 32/10395 z^11 + O[z^12]
  ;;          = z [1 - 2/3 z^2 {1 - 2/5 z^2 + 4/35 z^4 - 8/315 z^7 + 16/3465 z^9 + ...}]
  ;;          = z [1 - 2/3 z^2 {1 - 2/5 z^2 (1 - 2/7 z^2 + 4/63 z^5 - 8/693 z^7 - ...) } ]
  ;;--------------------------------------------------------------------------------------
  x2             = xx[0]^2d0
  x5             = (xx[0]^5d0) > 0d0
  x7             = (xx[0]^7d0) > 0d0
  IF (FINITE(x5) EQ 0) THEN x5 = 0d0
  IF (FINITE(x7) EQ 0) THEN x7 = 0d0
  IF (cmplx_on[0]) THEN BEGIN
    ;;  Pre-define output to maintain type
    dawson         = DCOMPLEX(0d0,0d0)
    dawson         = xx[0]*( 1d0 - aa1[0]*x2[0]*( 1d0 - aa2[0]*x2[0]*( 1d0 - aa3[0]*x2[0] + aa4[0]*x5[0] - aa5[0]*x7[0] ) ) )
  ENDIF ELSE BEGIN
    ;;  Input is real, so no need to worry
    dawson         = xx[0]*( 1d0 - aa1[0]*x2[0]*( 1d0 - aa2[0]*x2[0]*( 1d0 - aa3[0]*x2[0] + aa4[0]*x5[0] - aa5[0]*x7[0] ) ) )
  ENDELSE
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Use sampling theorem representation
  ;;    Recreated from:
  ;;      NUMERICAL RECIPES IN FORTRAN 77: THE ART OF SCIENTIFIC COMPUTING
  ;;      (ISBN 0-521-43064-X)
  ;;--------------------------------------------------------------------------------------
  ;;  Define constants
  ax             = ABS(xx[0])
  no             = (2L*LONG(ax[0]/(2d0*hh[0]))) > 0L
  xp             = ax[0] - DOUBLE(no[0])*hh[0]
  e1             = EXP(2d0*xp[0]*hh[0])
  e2             = e1[0]^2d0
  d1             = DOUBLE(no[0] + 1d0)
  d2             = d1[0] - 2d0
  ;;  Initialize sum
  IF (cmplx_on[0]) THEN sum = DCOMPLEX(0d0,0d0) ELSE sum = 0d0
  FOR j=0L, nmax[0] - 1L DO BEGIN
    ;;  Update sum
    sum           += ( cc[j]*( e1[0]/d1[0] + 1d0/( d2[0]*e1[0] ) ) )
    ;;  Update parameters in sum
    d1            += 2d0
    d2            -= 2d0
    e1            *= e2[0]
  ENDFOR
  ;;  Define the Dawson integral result
  ss             = ABS(EXP(-xp[0]^2d0))*sign(xx[0])
  IF (cmplx_on[0]) THEN dawson = DCOMPLEX(0d0,0d0) ELSE dawson = 0d0
  dawson         = 1d0/SQRT(!DPI)*sum[0]*ss[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN,dawson[0]
END





























