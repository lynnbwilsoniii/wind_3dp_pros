;+
;*****************************************************************************************
;
;  FUNCTION :   calc_1var_stats.pro
;  PURPOSE  :   Calculates the one-variable statistics for an input array and prints
;                 to screen if user so desires.
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
;               X        :  [N]-Element [numeric] array on which to perform one-variable
;                             statistical analysis
;
;  EXAMPLES:    
;               [calling sequence]
;               stats = calc_1var_stats(xx [,/NAN] [,/PRINTOUT])
;
;  KEYWORDS:    
;               NAN          :  If set, routine will ignore non-finite values
;                                 by passing the argument to functions like MIN.PRO
;                                 [Default = FALSE]
;               PRINTOUT     :  If set, routine will print out the results
;                                 [Default = FALSE]
;
;   CHANGED:  1)  Added error handling and updated Man. page
;                                                                   [01/18/2018   v1.0.1]
;
;   NOTES:      
;               1)  The return value, if successful, is a thirteen element array with:
;                     A[0]  =             Min. value of X
;                     A[1]  =             Max. value of X
;                     A[2]  =             Avg. value of X
;                     A[3]  =           Median value of X
;                     A[4]  =     Standard Deviation of X
;                     A[5]  =  Std. Dev. of the Mean of X
;                     A[6]  =               Skewness of X
;                     A[7]  =               Kurtosis of X
;                     A[8]  =         Lower Quartile of X
;                     A[9]  =         Upper Quartile of X
;                    A[10]  =     Interquartile Mean of X
;                    A[11]  =    Total # of Elements in X
;                    A[12]  =   Finite # of Elements in X
;
;  REFERENCES:  
;               NA
;
;   CREATED:  01/17/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/18/2018   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION calc_1var_stats,xx,NAN=nan,PRINTOUT=printout

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
noinpt_msg     = 'No input supplied...'
notnum_msg     = 'Input must be of numeric type...'
toofew_msg     = 'Not enough elements in input X...'
nofint_msg     = 'No finite data...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 1) THEN BEGIN
  ;;  no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_number(xx,/NOMSSG) EQ 0) OR (N_ELEMENTS(xx) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,notnum_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define params
x              = REFORM(xx)
sp             = SORT(x)
x              = TEMPORARY(x[sp])      ;;  Sort array
nx             = N_ELEMENTS(x)
good           = WHERE(FINITE(x),gdx)
IF (nx[0] LT 3) THEN BEGIN
  ;;  not enough elements!
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
IF (gdx[0] LT 1) THEN BEGIN
  ;;  not enough elements!
  MESSAGE,nofint_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NAN
test           = (is_a_number(nan,/NOMSSG) EQ 0) OR ~KEYWORD_SET(nan)
IF (test[0]) THEN nan_on = 0b ELSE nan_on = 1b
;;  Check PRINTOUT
test           = (is_a_number(printout,/NOMSSG) EQ 0) OR ~KEYWORD_SET(printout)
IF (test[0]) THEN print_on = 0b ELSE print_on = 1b
;;----------------------------------------------------------------------------------------
;;  Calculate simple stats
;;----------------------------------------------------------------------------------------
IF (nan_on[0]) THEN BEGIN
  ;;  Ignore and/or remove NaNs
  ny      = gdx[0]
  y       = x[good]
ENDIF ELSE BEGIN
  ;;  Do not ignore and/or remove NaNs
  ny      = nx[0]
  y       = x
ENDELSE
sdomfac        = SQRT(1d0*ny[0])
minx           =    MIN(y,NAN=nan_on)                      ;;  Min. value of X
maxx           =    MAX(y,NAN=nan_on)                      ;;  Max. value of X
avgx           =   MEAN(y,NAN=nan_on,/DOUBLE)              ;;  Avg. value of X
medx           = MEDIAN(y,/DOUBLE)                         ;;  Median value of X
stdx           = STDDEV(y,NAN=nan_on,/DOUBLE)              ;;  Standard Deviation of X
somx           = stdx[0]/sdomfac[0]                        ;;  Std. Dev. of the Mean of X
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;  Note:  Positive skewness indicates the distribution is skewed to the right, with a
;;          longer tail to the right of the distribution maximum. Negative skewness
;;          indicates the distribution is skewed to the left, with a longer tail to
;;          the left of the distribution maximum.
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
skew           = SKEWNESS(y,NAN=nan_on,/DOUBLE)            ;;  Skewness of X
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;  Note: KURTOSIS subtracts 3 from the raw kurtosis value since 3 is the kurtosis for a
;;          Gaussian (normal) distribution. For resulting values, positive values of the
;;          kurtosis (leptokurtic) indicate pointed or peaked distributions. Negative
;;          values (platykurtic) indicate flattened or non-peaked distributions.
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
kurt           = KURTOSIS(y,NAN=nan_on,/DOUBLE)            ;;  Kurtosis of X
;;----------------------------------------------------------------------------------------
;;  Calculate the quartiles
;;----------------------------------------------------------------------------------------
ind25          = WHERE(y LE medx[0],cntlow)
ind75          = WHERE(y GT medx[0],cntupp)
test           = (cntlow[0] EQ 0) OR (cntupp[0] EQ 0)
IF (test[0]) THEN BEGIN
  ;;  Bad  -->  NaN quartiles and IQM
  qtr25          = f[0]
  qtr75          = f[0]
  iqmx           = f[0]
ENDIF ELSE BEGIN
  ;;  Good --> calc quartiles
  qtr25          = MEDIAN(y[ind25],/DOUBLE)
  qtr75          = MEDIAN(y[ind75],/DOUBLE)
  voidl          = WHERE(y LT qtr25[0],cnlwqt)       ;;  cnlwqt  :  # of points in the 1st quartile
  voidh          = WHERE(y GE qtr75[0],cnupqt)       ;;  cnupqt  :  # of points in the 4th quartile
  cn2nqt         = cntlow[0] - cnlwqt[0]             ;;  cn2nqt  :  # of points in the 2nd quartile
  cn3rqt         = cntupp[0] - cnupqt[0]             ;;  cn3rqt  :  # of points in the 3rd quartile
  lh_iqm_i       = [MAX(voidl),MIN(voidh)]
  test           = (cnlwqt[0] EQ 0) OR (cnupqt[0] EQ 0)
  IF (test[0]) THEN BEGIN
    ;;  Bad  -->  NaN interquartile mean (IQM)
    iqmx           = f[0]
  ENDIF ELSE BEGIN
    ;;  Good -->  calc interquartile mean (IQM)
    iy             = y[lh_iqm_i[0]:lh_iqm_i[1]]
    iqmx           = MEAN(iy,NAN=nan_on,/DOUBLE)
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Print stats, if user wants to
;;----------------------------------------------------------------------------------------
IF (print_on[0]) THEN BEGIN
  PRINT,';;'
  PRINT,';;             Min. value of X  =  ',minx[0]
  PRINT,';;             Max. value of X  =  ',maxx[0]
  PRINT,';;             Avg. value of X  =  ',avgx[0]
  PRINT,';;           Median value of X  =  ',medx[0]
  PRINT,';;     Standard Deviation of X  =  ',stdx[0]
  PRINT,';;  Std. Dev. of the Mean of X  =  ',somx[0]
  PRINT,';;               Skewness of X  =  ',skew[0]
  PRINT,';;               Kurtosis of X  =  ',kurt[0]
  PRINT,';;         Lower Quartile of X  =  ',qtr25[0]
  PRINT,';;         Upper Quartile of X  =  ',qtr75[0]
  PRINT,';;     Interquartile Mean of X  =  ',iqmx[0]
  PRINT,';;    Total # of Elements in X  =  ',nx[0]
  PRINT,';;   Finite # of Elements in X  =  ',gdx[0]
  PRINT,';;'
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
outarr         = [minx[0],maxx[0],avgx[0],medx[0],stdx[0],somx[0],skew[0],kurt[0],$
                  qtr25[0],qtr75[0],iqmx[0],nx[0],gdx[0]]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,outarr
END

