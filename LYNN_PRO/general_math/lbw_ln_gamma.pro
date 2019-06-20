;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_ln_gamma.pro
;  PURPOSE  :   Calculates the natural log of the gamma function for non-complex
;                 input and automatically determines if the Stirling approximation is
;                 required.
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
;               X     :  Scalar or [K]-element [numeric] array of reals
;
;  EXAMPLES:    
;               [calling sequence]
;               lngam = lbw_ln_gamma(x)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Stirling approximation:
;                 ln|Gamma(n)| ~ 1/2 ln|2πn| + n ln|n| - n + 1/(12 n) + 1/(360 n^3) + 
;                                1/(1260 n^5) - 1/(1680 n^7) + O[n^(-7)]
;               2)  If n ≤ 84 then numbers are computed directly
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

FUNCTION lbw_ln_gamma,x

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
large          = (TOTAL(x GT 84) GT 0)      ;;  Check if Stirling approximation is necessary
;;----------------------------------------------------------------------------------------
;;  Compute ln|Gamma(n)|
;;----------------------------------------------------------------------------------------
nn             = N_ELEMENTS(x)
x0             = DOUBLE(x)
IF (large[0]) THEN BEGIN
  ;;  N is large --> approximate
  IF (nn[0] GT 1) THEN BEGIN
    large          = WHERE(x0 GT 120 AND FINITE(x0),glg,COMPLEMENT=small,NCOMPLEMENT=gsm)
    lngam          = REPLICATE(0d0,nn[0])
    IF (gsm[0] GT 0) THEN lngam[small] = ALOG(GAMMA(x0[small]))
    IF (glg[0] GT 0) THEN BEGIN
      xx           = x0[large]
      lngam[large] = ALOG(2d0*!DPI*xx)/2d0 + xx*ALOG(xx) - xx + 1d0/(12d0*xx) + 1d0/(36d1*xx^3d0) + 1d0/(126d1*xx^5d0) - 1d0/(168d1*xx^7d0)
    ENDIF
  ENDIF ELSE BEGIN
    xx    = x0[0]
    lngam = ALOG(2d0*!DPI*xx)/2d0 + xx*ALOG(xx) - xx + 1d0/(12d0*xx) + 1d0/(36d1*xx^3d0) + 1d0/(126d1*xx^5d0) - 1d0/(168d1*xx^7d0)
  ENDELSE
ENDIF ELSE BEGIN
  ;;  N is small enough to compute directly
  lngam = ALOG(GAMMA(x0))
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,lngam
END



