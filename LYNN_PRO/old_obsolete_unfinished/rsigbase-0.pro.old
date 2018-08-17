;+
;*****************************************************************************************
;
;  FUNCTION :   rsigbase.pro
;  PURPOSE  :   Takes a [numeric] scalar or array input and rounds to the nearest
;                 user defined significant figure in the user defined base.
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
;               XX      :  Scalar [numeric] or [N]-element array of values to round
;
;  EXAMPLES:    
;               [calling sequence]
;               truncated = rsigbase(xx [,BASE=base] [,SIGFIG=sigfig])
;
;  KEYWORDS:    
;               BASE    :  Scalar [numeric] defining the base in which to round XX
;                            [Default: 10]
;               SIGFIG  :  Scalar [long/integer] defining the number of significant
;                            figures at which to truncate/round
;                            [Default: 1]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Program assumes input can be written as:
;                     x = a b^{c}
;                     where a is the mantissa (or significand), b is BASE here, and
;                     c is the scaled exponent.  The mantissa is defined as:
;                     a = x b^{-c}
;                     such that we have the following:
;                       Log_{b} |a| = Log_{b} |x| - c
;                     Thus, in the below calculations we have:
;                                                   l10_new  = ALOG10(BASE)
;                                                   l10___x  = ALOG10(ABS(XX))
;                                                   lnew_x   = l10___x/l10_new[0]
;                       c           <--> e        = sc_expon = FLOOR(lnew_x - SIGFIG)
;                       Log_{b} |a| <--> f        = residual = lnew_x - sc_expon
;                       a           <--> mantissa = mantissa = ROUND(1d1^residual)
;               2)  The value of SIGFIG should not exceed 64-bit limit and must be ≥ 1.0
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/23/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/23/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rsigbase,xx,BASE=base,SIGFIG=sigfig

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_base       = 10d0
def_sigf       = 1d0
;;  Error messages
noinput_mssg   = 'User must supply an input from which the rounded value can be calculated...'
incorrf_mssg   = 'Incorrect input format:  XX must be a numeric scalar or array...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Make sure input is present
IF (N_PARAMS() LT 1) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Make sure input is numeric
IF (is_a_number(xx,/NOMSSG) EQ 0) THEN BEGIN
  MESSAGE,incorrf_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define parameters
x              = 1d0*xx       ;;  Make sure of double type
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check BASE
IF (is_a_number(base,/NOMSSG)   EQ 0) THEN lbase = def_base[0] ELSE lbase = DOUBLE(ABS(base[0])) > 2d0
;;  Check SIGFIG
IF (is_a_number(sigfig,/NOMSSG) EQ 0) THEN gsigs = def_sigf[0] ELSE gsigs = DOUBLE(ABS(sigfig[0])) > 1d0
;;----------------------------------------------------------------------------------------
;;  Remove zeros and find negative values from input (if present)
;;----------------------------------------------------------------------------------------
good_neg       = WHERE(x LT 0,gd_neg)
bad            = WHERE(x EQ 0,bd)
IF (bd[0] GT 0) THEN x[bad] = 1d0
;;----------------------------------------------------------------------------------------
;;  Find the log_BASE of XX
;;
;;    Base conversion with logarithms
;;      log_new |X|  =  ( log_old |X| )/( log_old |new| )
;;----------------------------------------------------------------------------------------
l10_new        = ALOG10(lbase[0])
l10___x        = ALOG10(ABS(x))
lnew_x         = l10___x/l10_new[0]
;;----------------------------------------------------------------------------------------
;;  Need to convert SIGFIG to new base as well
;;----------------------------------------------------------------------------------------
lsigs          = ALOG10(gsigs[0])/l10_new[0]
sigexp         = FLOOR(lsigs[0] - 1d1,/L64)
sigres         = lsigs[0] - sigexp[0]
sigman         = ROUND(1d1^sigres[0],/L64)
lbsigs         = sigman[0]*lbase[0]^sigexp[0]
;;----------------------------------------------------------------------------------------
;;  Calculate the scaled exponent and mantissa (or significand)
;;----------------------------------------------------------------------------------------
sc_expon       = FLOOR(lnew_x - lbsigs[0],/L64)
;sc_expon       = FLOOR(lnew_x - lsigs[0],/L64)
;sc_expon       = FLOOR(lnew_x - gsigs[0],/L64)
residual       = lnew_x - sc_expon
mantissa       = ROUND(1d1^residual,/L64)
;;----------------------------------------------------------------------------------------
;;  Calculate the rounded/truncated values
;;----------------------------------------------------------------------------------------
output         = mantissa*lbase[0]^sc_expon
;;----------------------------------------------------------------------------------------
;;  Return negative values (if present)
;;----------------------------------------------------------------------------------------
IF (gd_neg[0] GT 0) THEN output[good_neg] *= -1d0
IF (bd[0]     GT 0) THEN output[bad]       = 0d0
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END
