;+
;*****************************************************************************************
;
;  FUNCTION :   print_1var_stats.pro
;  PURPOSE  :   This routine prints out the one-variable statistics for an input array
;                 of data.
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
;               X        :  [N]-Element array [float/double] of data
;
;  EXAMPLES:    
;               test = print_1var_stats(x,/NAN)
;
;  KEYWORDS:    
;               NAN          :  If set, routine will ignore non-finite values
;                                 [Default = FALSE]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The return value, if successful, is a six element array composed of:
;                     A[0]  =             Min. value of X
;                     A[1]  =             Max. value of X
;                     A[2]  =             Avg. value of X
;                     A[3]  =           Median value of X
;                     A[4]  =     Standard Deviation of X
;                     A[5]  =  Std. Dev. of the Mean of X
;
;  REFERENCES:  
;               NA
;
;   CREATED:  01/28/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/28/2014   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION print_1var_stats,xx,NAN=nan

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 1) THEN BEGIN
  ;;  no input???
  RETURN,0
ENDIF
x              = REFORM(xx)
nx             = N_ELEMENTS(x)
test           = (nx LT 3)
IF (test) THEN BEGIN
  ;;  bad input!
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Calculate stats
;;----------------------------------------------------------------------------------------
minx           =    MIN(x,NAN=nan)           ;;  Min. value of X
maxx           =    MAX(x,NAN=nan)           ;;  Max. value of X
avgx           =   MEAN(x,NAN=nan)           ;;  Avg. value of X
medx           = MEDIAN(x)                   ;;  Median value of X
stdx           = STDDEV(x,NAN=nan)           ;;  Standard Deviation of X
somx           = stdx[0]/SQRT(1d0*nx[0])     ;;  Std. Dev. of the Mean of X
;;----------------------------------------------------------------------------------------
;;  Print stats
;;----------------------------------------------------------------------------------------
PRINT,';;'
PRINT,';;             Min. value of X  =  ',minx[0]
PRINT,';;             Max. value of X  =  ',maxx[0]
PRINT,';;             Avg. value of X  =  ',avgx[0]
PRINT,';;           Median value of X  =  ',medx[0]
PRINT,';;     Standard Deviation of X  =  ',stdx[0]
PRINT,';;  Std. Dev. of the Mean of X  =  ',somx[0]
PRINT,';;'
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,[minx[0],maxx[0],avgx[0],medx[0],stdx[0],somx[0]]
END

