;+
;*****************************************************************************************
;
;  FUNCTION :   roundsig.pro
;  PURPOSE  :   Returns values rounded to the user designated number of significant
;                 figures.
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
;               X            :  N-Element array of [float,double] values
;
;  EXAMPLES:    
;               rx = roundsig(10.2357,SIGFIG=2)
;               PRINT, rx
;                     10.2000
;               rx = roundsig(10.2357,SIGFIG=4)
;               PRINT, rx
;                     10.2360
;               rx = roundsig(10.2357d10,SIGFIG=2)
;               PRINT, rx
;                  1.0200000e+11
;
;  KEYWORDS:    
;               SIGFIG       :  Scalar defining the number of significant figures to
;                                 keep
;                                 [Default:  SIGFIG = 1]
;               UNCERTAINTY  :  
;
;   CHANGED:  1)  Re-wrote and cleaned up                    [10/01/2010   v1.1.0]
;
;   NOTES:      
;               1)  Program assumes input can be written as:
;                     x = a b^{c}
;                     where a is the mantissa (or significand), b is 10. here, and
;                     c is the scaled exponent.  The mantissa is defined as:
;                     a = x b^{-c}
;                     such that we have the following:
;                     
;                     Log_{b} |a| = Log_{b} |x| - c
;                     
;                     Thus, in the below calculations we have:
;                     
;                     c           <--> e        = FLOOR(logx - sig)
;                     Log_{b} |a| <--> f        = logx - e
;                     a           <--> mantissa = ROUND(10^f)
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  10/01/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


FUNCTION roundsig,x,SIGFIG=sig,UNCERTAINTY=unc

;-----------------------------------------------------------------------------------------
; => Calculate uncertainty
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(unc) THEN BEGIN
   RETURN, unc*ROUND(x/unc)
ENDIF
;-----------------------------------------------------------------------------------------
; => Check keyword input
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(sig) NE 1) THEN sig = 1
; => define new variable
lx = x

; => find negative values
neg = (lx LT 0)
wn  = WHERE(neg,nn)
; => remove zeros to avoid NaN's when taking the Log of X
wz  = WHERE(lx EQ 0,nz)
IF (nz NE 0) THEN lx[wz] = 1.

; => find the base-10 log of |X|
logx      = ALOG10(ABS(lx))
; => Calculate the scaled exponent of the result
e         = FLOOR(logx - sig)
f         = logx - e
; => Calculate the mantissa (or significand)
mantissa  = ROUND(10^f)

IF (SIZE(x,/TYPE) EQ 5) THEN ten = 1d1 ELSE ten = 1e1
; => Define the rounded values
rx   = mantissa * ten^e

IF (nn NE 0) THEN rx[wn] = -rx[wn]
IF (nz NE 0) THEN rx[wz] = 0

RETURN,rx
END

