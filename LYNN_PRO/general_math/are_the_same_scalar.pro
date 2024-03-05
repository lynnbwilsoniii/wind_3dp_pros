;+
;*****************************************************************************************
;
;  FUNCTION :   are_the_same_scalar.pro
;  PURPOSE  :   Checks whether two input scalars are the same to within some user-defined
;                 threshold value.
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
;               VAL[1-2]     :  Scalar [numeric] value to be compared
;
;  EXAMPLES:    
;               [calling sequence]
;               test = are_the_same_scalar(val1,val2 [,PERTHSH=perthsh] [,ABSTHSH=absthsh])
;
;               ;;  Test examples
;               PRINT, are_the_same_scalar(1d0,1.1d0)
;                  1
;
;               PRINT, are_the_same_scalar(1d0,1.1d0,PERTHSH=9d-2)
;                  0
;
;               PRINT, are_the_same_scalar(1d0,1.2d0,ABSTHSH=2d-1)
;                  1
;
;               PRINT, are_the_same_scalar(1000L,1091L,PERTHSH=9d-2)
;                  0
;
;               PRINT, are_the_same_scalar(1000L,1091L,PERTHSH=9.1d-2)
;                  1
;
;               PRINT, are_the_same_scalar(1000L,1091L,ABSTHSH=90.5)
;                  0
;
;  KEYWORDS:    
;               PERTHSH      :  Scalar [numeric] value definine the percent threshold
;                                 within which the two input scalars would be defined
;                                 as the same number.  Note that you input this as the
;                                 fractional value, not the percent.  For instance, a
;                                 15% threshold would be input as 0.15.
;                                 [Default = 0.1]
;               ABSTHSH      :  Scalar [numeric] value definine the absolute number
;                                 distance between the two input scalars allowed to
;                                 define both as the same number.  That is, if
;                                 |VAL1 - VAL2| ≤ ABSTHSH
;                                 then the values are considered the same.
;                                 [Default = FALSE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Both PERTHSH and ABSTHSH will be based off of VAL1 input
;               2)  PERTHSH must be less than unity else the default value will be applied
;               3)  The comparison is actually done in single-precision floating point
;                     values regardless of input value type to avoid rounding error issues.
;                     If I do not impose this, the following would give an output of FALSE:
;                       IDL> PRINT,are_the_same_scalar(1d0,1.1d0)
;                     because the difference between VAL1 and VAL2 rounds to
;                       0.10000000000000009
;                     in double-precision while the value of VAL1[0]*PERTHSH[0] goes to
;                       0.10000000000000001
;                     so that |VAL1 - VAL2| > (VAL1*PERTHSH).
;
;  REFERENCES:  
;               NA
;
;   CREATED:  11/15/2023
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/15/2023   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION are_the_same_scalar,val1,val2,PERTHSH=perthsh,ABSTHSH=absthsh

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Error messages
noinput_mssg   = 'No input was supplied...'
badinpt_mssg   = 'Incorrect input format was supplied:  VAL[1-2] must be scalar [numeric] values'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = ((is_a_number(val1[0],/NOMSSG) EQ 0) OR (is_a_number(val2[0],/NOMSSG) EQ 0))
IF (test[0]) THEN BEGIN
  MESSAGE,badinpt_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check PERTHSH
IF (is_a_number(perthsh,/NOMSSG)) THEN BEGIN
  perc           = ABS(1d0*perthsh[0])
  IF (perc[0] GE 1d0 OR perc[0] LE 0d0 OR FINITE(perc[0]) EQ 0) THEN perc = 1d-1
ENDIF ELSE BEGIN
  perc           = 1d-1
ENDELSE
;;  Check ABSTHSH
IF (is_a_number(absthsh,/NOMSSG)) THEN BEGIN
  absv           = ABS(1d0*absthsh[0])
  IF (absv[0] LE 0d0 OR FINITE(absv[0]) EQ 0) THEN abs_on = 0b ELSE abs_on = 1b
ENDIF ELSE BEGIN
  abs_on         = 0b
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check distance
;;----------------------------------------------------------------------------------------
diff           = ABS(1d0*val1[0] - 1d0*val2[0])
IF (abs_on[0]) THEN BEGIN
  ;;  Use absolute threshold
  test           = (FLOAT(diff[0]) LE FLOAT(absv[0]))
ENDIF ELSE BEGIN
  ;;  Use percent threshold
  prc1           = ABS(val1[0]*perc[0])
  test           = (FLOAT(diff[0]) LE FLOAT(prc1[0]))
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,test[0]
END

