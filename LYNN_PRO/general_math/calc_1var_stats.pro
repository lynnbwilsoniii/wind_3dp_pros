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
;               stats = calc_1var_stats(xx [,/NAN] [,/PRINTOUT] [,RANGE=range]        $
;                                          [,/POSITIVE] [,/NEGATIVE] [,CONLIM=conlim] $
;                                          [,PERCENTILES=percentiles] [,/NOMSSG])
;
;               ;;  Define dummy array of values for later use
;               xx             = [-45.12d3,-25.2d1,-72.88,-2.31738,300.95313,5.15287331e5,$
;                                 4.988237385d0,15.135343e0,158.113,295.884,64.912d2,     $
;                                 !VALUES.D_NAN]
;               ;;  Output WITHOUT any keywords
;               PRINT,';;',calc_1var_stats(xx)
;               ;;      -45120.000       515287.34             NaN       15.135343             NaN             NaN             NaN             NaN      -2.3173800       300.95312       99.982334       12.000000       11.000000
;
;               ;;  Output with NAN keyword set
;               PRINT,';;',calc_1var_stats(xx,/NAN)
;               ;;           Min            Max             Mean           Median         StdDev.         StDvMn.          Skew.           Kurt.            Q1              Q2              IQM           Tot.  #         Fin.  #
;               ;;      -45120.000       515287.34       43373.311       15.135343       157132.30       47377.170       2.4299814       4.4096244      -2.3173800       300.95312       99.982334       12.000000       11.000000
;
;               ;;  Output with RANGE keyword set
;               range          = [0e0,5e2]
;               PRINT,';;',calc_1var_stats(xx,/NAN,RANGE=range)
;               ;;           Min            Max             Mean           Median         StdDev.         StDvMn.          Skew.           Kurt.            Q1              Q2              IQM           Tot.  #         Fin.  #
;               ;;       4.9882374       300.95312       155.01474       158.11301       144.24455       64.508123    -0.013997410      -2.1975970       15.135343       300.95312       155.01474       5.0000000       5.0000000
;
;               ;;  Output with POSITIVE keyword set
;               PRINT,';;',calc_1var_stats(xx,/NAN,/POSITIVE)
;               ;;           Min            Max             Mean           Median         StdDev.         StDvMn.          Skew.           Kurt.            Q1              Q2              IQM           Tot.  #         Fin.  #
;               ;;       4.9882374       515287.34       74650.517       295.88400       194316.96       73444.908       1.6193469      0.79489923       158.11301       6491.2000       1452.2571       7.0000000       7.0000000
;
;               ;;  Output with NEGATIVE keyword set
;               PRINT,';;',calc_1var_stats(xx,/NAN,/NEGATIVE)
;               ;;           Min            Max             Mean           Median         StdDev.         StDvMn.          Skew.           Kurt.            Q1              Q2              IQM           Tot.  #         Fin.  #
;               ;;      -45120.000      -2.3173800      -11361.799      -72.879997       22505.712       11252.856     -0.74995097      -1.6875328      -252.00000      -2.3173800      -11361.799       4.0000000       4.0000000
;
;               ;;  Output with bad RANGE setting
;               range          = [0e0,5e0]
;               PRINT,';;',calc_1var_stats(xx,/NAN,RANGE=range)
;               % CALC_1VAR_STATS: No input supplied...
;               ;;   0
;
;  KEYWORDS:    
;               ****************
;               ***  INPUTS  ***
;               ****************
;               NAN          :  If set, routine will ignore non-finite values
;                                 by passing the argument to functions like MIN.PRO
;                                 [Default = FALSE]
;               PRINTOUT     :  If set, routine will print out the results
;                                 [Default = FALSE]
;               RANGE        :  [2]-Element [numeric] array defining the range of
;                                 values to allow in the analysis.
;               POSITIVE     :  If set, routine will ignore all non-positive values
;                                 including zeros
;                                 [Default = FALSE]
;               NEGATIVE     :  If set, routine will ignore all non-negative values
;                                 including zeros
;                                 [Default = FALSE]
;               CONLIM       :  Scalar [numeric] define the percent confidence limit
;                                 for which to calculate the percentiles.  For example,
;                                 a one-sigma value for a Gaussian distribution would
;                                 be 0.68.
;                                 [Default = 0.68]
;               NOMSSG       :  If set, routine will not output messages to inform user
;                                 of failures or status
;                                 [Default = FALSE]
;               ****************
;               ***  OUTPUT  ***
;               ****************
;               PERCENTILES  :  Set to a named variable to return the lower and upper
;                                 percentiles at the boundaries of the confidence
;                                 limit defined by CONLIM.  For instance, if CONLIM=0.68,
;                                 then the output for this would be the value of X at
;                                 the 16th and 85th percentiles
;
;   CHANGED:  1)  Added error handling and updated Man. page
;                                                                   [01/18/2018   v1.0.1]
;             2)  Added keywords:  RANGE, POSITIVE, and NEGATIVE
;                                                                   [02/20/2019   v1.0.2]
;             3)  Added keywords:  CONLIM and PERCENTILES
;                                                                   [04/04/2019   v1.0.3]
;             4)  Now calculates fractional indices of Q25 and Q75 if not available
;                                                                   [05/22/2019   v1.0.4]
;             5)  Added keyword:  NOMSSG
;                                                                   [11/06/2019   v1.0.5]
;             6)  Fixed an issue where the 25% and 75% values were wrong in special
;                   cases where there are a lot of repeated values in the input array
;                                                                   [03/15/2024   v1.0.6]
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
;               2)  RANGE supercedes both POSITIVE and NEGATIVE and
;                     POSITIVE supercedes NEGATIVE
;
;  REFERENCES:  
;               NA
;
;   CREATED:  01/17/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/15/2024   v1.0.6
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION calc_1var_stats,xx,NAN=nan,PRINTOUT=printout,RANGE=range,POSITIVE=positive, $
                            NEGATIVE=negative,CONLIM=conlim,PERCENTILES=percentiles, $
                            NOMSSG=nomssg

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
  IF ~KEYWORD_SET(nomssg) THEN MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_number(xx,/NOMSSG) EQ 0) OR (N_ELEMENTS(xx) EQ 0)
IF (test[0]) THEN BEGIN
  IF ~KEYWORD_SET(nomssg) THEN MESSAGE,notnum_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define params
nx             = N_ELEMENTS(xx)
x              = REFORM(xx,nx[0])      ;;  Force to 1D
sp             = SORT(x)
x              = TEMPORARY(x[sp])      ;;  Sort array
good           = WHERE(FINITE(x),gdx)
IF (nx[0] LT 3) THEN BEGIN
  ;;  not enough elements!
  IF ~KEYWORD_SET(nomssg) THEN MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
IF (gdx[0] LT 1) THEN BEGIN
  ;;  not enough elements!
  IF ~KEYWORD_SET(nomssg) THEN MESSAGE,nofint_msg[0],/INFORMATIONAL,/CONTINUE
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
;;  Check POSITIVE
test           = (is_a_number(positive,/NOMSSG) EQ 0) OR ~KEYWORD_SET(positive)
IF (test[0]) THEN pos_on = 0b ELSE pos_on = 1b
;;  Check NEGATIVE
test           = (is_a_number(negative,/NOMSSG) EQ 0) OR ~KEYWORD_SET(negative)
IF (test[0]) THEN neg_on = 0b ELSE neg_on = 1b
;;  Check RANGE
test           = is_a_number(range,/NOMSSG) AND (N_ELEMENTS(range) EQ 2)
IF (test[0]) THEN test = test_plot_axis_range(range,/NOMSSG)
IF (test[0]) THEN BEGIN
  ran_on = 1b
  gran   = range[SORT(range)]
  ;;  Shut off other keywords
  pos_on = 0b
  neg_on = 0b
ENDIF ELSE ran_on = 0b
IF (pos_on[0] AND neg_on[0]) THEN neg_on[0] = 0b
;;  Check CONLIM
test           = (is_a_number(conlim,/NOMSSG) EQ 0)
IF (test[0]) THEN conflim = 68d-1 ELSE conflim = (ABS(conlim[0]) > 1d-4) < 0.9999d0
;;----------------------------------------------------------------------------------------
;;  Redefine good elements array, if necessary
;;----------------------------------------------------------------------------------------
IF (ran_on[0] OR pos_on[0] OR neg_on[0]) THEN BEGIN
  check = [ran_on[0],pos_on[0],neg_on[0]]
  CASE 1 OF
    check[0]  :  BEGIN
      ;;  RANGE set
      gind = WHERE(x GE gran[0] AND x LE gran[1],gin)
      IF (gin[0] GT 0) THEN BEGIN
        ;;  Good setting --> Redefine input and re-call
        x2 = x[gind]
        RETURN,calc_1var_stats(x2,NAN=nan,PRINTOUT=printout,CONLIM=conlim,PERCENTILES=percentiles,NOMSSG=nomssg)
      ENDIF ELSE BEGIN
        ;;  Bad range setting --> Inform user and return 0
        IF ~KEYWORD_SET(nomssg) THEN MESSAGE,'No data within RANGE boundaries...',/INFORMATIONAL,/CONTINUE
        RETURN,0b
      ENDELSE
    END
    check[1]  :  BEGIN
      ;;  POSITIVE set
      x2 = get_posneg_els_arr(x)
      IF (N_ELEMENTS(x2) LE 1) THEN BEGIN
        ;;  Bad result --> Inform user and return 0
        IF ~KEYWORD_SET(nomssg) THEN MESSAGE,'No positive-only data provided...',/INFORMATIONAL,/CONTINUE
        RETURN,0b
      ENDIF ELSE BEGIN
        ;;  Good setting --> Re-call with new input
        RETURN,calc_1var_stats(x2,NAN=nan,PRINTOUT=printout,CONLIM=conlim,PERCENTILES=percentiles,NOMSSG=nomssg)
      ENDELSE
    END
    check[2]  :  BEGIN
      ;;  NEGATIVE set
      x2 = get_posneg_els_arr(x,/NEGATIVE)
      IF (N_ELEMENTS(x2) LE 1) THEN BEGIN
        ;;  Bad result --> Inform user and return 0
        IF ~KEYWORD_SET(nomssg) THEN MESSAGE,'No positive-only data provided...',/INFORMATIONAL,/CONTINUE
        RETURN,0b
      ENDIF ELSE BEGIN
        ;;  Good setting --> Re-call with new input
        RETURN,calc_1var_stats(x2,NAN=nan,PRINTOUT=printout,CONLIM=conlim,PERCENTILES=percentiles,NOMSSG=nomssg)
      ENDELSE
    END
    ELSE      : STOP  ;;  should not happen!
  ENDCASE
ENDIF
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
sp             = SORT(y)
y              = TEMPORARY(y[sp])
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
;;  Calculate the 25th and 75th percentiles (i.e., lower and upper quartiles)
;;----------------------------------------------------------------------------------------
ind25          = WHERE(y LE medx[0],cntlow)
ind75          = WHERE(y GT medx[0],cntupp)
test           = (cntlow[0] EQ 0) OR (cntupp[0] EQ 0)
IF (test[0]) THEN BEGIN
  ;;  First try to fix the issue with fractional indices
  q75lim         = 75d-2
  low_qind       = LONG(((1d0 - q75lim[0])/2L)*ny[0]) > 0L
  upp_qind       = ny[0] - low_qind[0] - 1L
  qtr25          = y[low_qind[0]]
  qtr75          = y[upp_qind[0]]
  IF (low_qind[0] NE upp_qind[0]) THEN BEGIN
    iqmx           = MEAN(y[low_qind[0]:upp_qind[0]],NAN=nan_on,/DOUBLE)
  ENDIF ELSE BEGIN
    ;;  Bad  -->  NaN quartiles and IQM
    qtr25          = f[0]
    qtr75          = f[0]
    iqmx           = f[0]
  ENDELSE
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Good --> calc quartiles
  ;;--------------------------------------------------------------------------------------
  ;;  Make sure there are a significant number of unique values
  unq            = UNIQ(y,SORT(y))
  IF (N_ELEMENTS(unq) GE 95d-2*ny[0]) THEN BEGIN
    ;;  Good number of unique points --> use usual method
    qtr25          = MEDIAN(y[ind25],/DOUBLE)
    qtr75          = MEDIAN(y[ind75],/DOUBLE)
  ENDIF ELSE BEGIN
    ;;  Too many overlapping points --> use usual sorting method
    q75lim         = 75d-2
    low_qind       = LONG(((1d0 - q75lim[0])/2L)*ny[0]) > 0L
    upp_qind       = ny[0] - low_qind[0] - 1L
    qtr25          = y[low_qind[0]]
    qtr75          = y[upp_qind[0]]
  ENDELSE
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
;;  Calculate the percentiles
;;----------------------------------------------------------------------------------------
low_pind       = LONG(((1d0 - conflim[0])/2L)*ny[0]) > 0L
upp_pind       = ny[0] - low_pind[0] - 1L
percentiles    = [y[low_pind[0]],y[upp_pind[0]]]
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

