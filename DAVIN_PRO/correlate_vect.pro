;+
;*****************************************************************************************
;
;  PROCEDURE:   correlate_vect.pro
;  PURPOSE  :   Finds correlation between two input vectors.
;
;  CALLED BY:   
;               fix_spin_time.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               average.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries or SPEDAS libraries
;
;  INPUT:
;               X       :  [N]-Element [numeric] array to correlate with Y
;               Y       :  [N]-Element [numeric] array to correlate with X
;               N1      :  Scalar [long/integer] defining the smoothing/averaging
;                            width to use to define < Q > terms
;
;  EXAMPLES:    
;               [calling sequence]
;               correlate_vect, x, y, n1 [,A=a] [,B=b] [,R=r] [,C=c] [,SINGLE=single]
;
;  KEYWORDS:    
;               A       :  Set to a named variable to return the following:
;                             A = (< Y >*< X^2 > - < X >*< Y^2 >)/var(X)
;               B       :  Set to a named variable to return the following:
;                             B = cov(x,y)/var(x)
;               C       :  Set to a named variable to return the following:
;                             C = cov(x,y)/< x^2 >
;               R       :  Set to a named variable to return the correlation defined as:
;                             cor(x,y) = cov(x,y)*[var(x)*var(y)]^(-1/2)
;               SINGLE  :  *** Obsolete/Not Used ***
;
;   CHANGED:  1)  Davin created or last modified routine
;                                                                   [06/23/2008   v1.0.?]
;             2)  Added Man. page, comments, cleaned up, and fixed bug with /EDGE*
;                   keywords in SMOOTH.PRO after IDL version 8
;                                                                   [02/15/2017   v1.1.0]
;
;   NOTES:      
;               1)  Definitions:
;                     < x >    = arithmetic mean or expectation value or average or mean
;                              = N^(-1) ∑_{i=1}^{N} x_i
;                     var(x)   = variance
;                              = < x^2 > - < x >^2
;                              = < [ x - < x > ]^2 >
;                     cov(x,y) = covariance between x and y
;                              = < x*y > - < x >*< y >
;                              = < [ x - < x > ]*[ y - < y > ] >
;                     cor(x,y) = correlation between x and y
;                              = cov(x,y)*[var(x)*var(y)]^(-1/2)
;
;  REFERENCES:  
;               NA
;
;   CREATED:  06/23/2008
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  02/15/2017   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO correlate_vect,x,y,n1,A=a,B=b,R=r,C=c,SINGLE=single

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
nan            = !VALUES.F_NAN
;;----------------------------------------------------------------------------------------
;;  Calculate < Q > and < Q^2 > terms
;;----------------------------------------------------------------------------------------
;;  Check input
IF KEYWORD_SET(n1) THEN BEGIN
  wdth           = LONG(n1[0])
  ;;  User defined smoothing width --> correlate
  ok             = FINITE(X) AND FINITE(y)
  w              = WHERE(SMOOTH(ok,wdth[0]) EQ 0,nw)
  xavg           = SMOOTH(x,wdth[0],/NAN,/EDGE_TRUNCATE)      ;;  < x >
  x2avg          = SMOOTH(x^2,wdth[0],/NAN,/EDGE_TRUNCATE)    ;;  < x^2 >
  yavg           = SMOOTH(y,wdth[0],/NAN,/EDGE_TRUNCATE)      ;;  < y >
  y2avg          = SMOOTH(y^2,wdth[0],/NAN,/EDGE_TRUNCATE)    ;;  < y^2 >
  xyavg          = SMOOTH(x*y,wdth[0],/NAN,/EDGE_TRUNCATE)    ;;  < x*y >
  IF (nw NE 0) THEN BEGIN
    ;;  Remove now finite values that were previously NaNs
    xavg[w]        = nan[0]
    x2avg[w]       = nan[0]
    yavg[w]        = nan[0]
    y2avg[w]       = nan[0]
    xyavg[w]       = nan[0]
  ENDIF
ENDIF ELSE BEGIN
  ;;  User did not define smoothing width --> directly average results
  xavg           = average(x,/NAN)                            ;;  < x >
  x2avg          = average(x^2,/NAN)                          ;;  < x^2 >
  yavg           = average(y,/NAN)                            ;;  < y >
  y2avg          = average(y^2,/NAN)                          ;;  < y^2 >
  xyavg          = average(x*y,/NAN)                          ;;  < x*y >
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define return keyword values
;;----------------------------------------------------------------------------------------
;;  Calculate the variance of x:  var(x) = < x^2 > - < x >^2
sx2            = x2avg - xavg^2                               ;;  varx = < x^2 > - < x >^2
;;  Calculate the variance of y:  var(y) = < y^2 > - < y >^2
sy2            = y2avg - yavg^2                               ;;  vary = < y^2 > - < y >^2
;;  Calculate the covariance of x and y:  cov(x,y) = < x*y > - < x >*< y >
sxy            = (xyavg - xavg*yavg)                          ;;  vxy  = < x*y > - < x >*< y >
;;  Calculate the correlation between x and y:  cor(x,y) = cov(x,y)*[var(x)*var(y)]^(-1/2)
r              = sxy/SQRT(sx2*sy2)                            ;;  R    = vxy*[varx*vary]^(-1/2)
;;  Calculate A parameter:  A = (< y >*< x^2 > - < x >*< y^2 >)/var(x)
a              = (yavg*x2avg - xavg*xyavg)/sx2                ;;  A    = (< y >*< x^2 > - < x >*< y^2 >)/varx
;;  Calculate B parameter:  B = cov(x,y)/var(x)
b              = sxy/sx2                                      ;;  B    = vxy/varx
;;  Calculate C parameter:  C = cov(x,y)/< x^2 >
c              = sxy/x2avg                                    ;;  C    = vxy/< x^2 >
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
