;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_diff.pro
;  PURPOSE  :   Takes the difference between two input scalars or arrays.  The output
;                 is given by:
;                    RESULT = VAL1 - VAL2
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
;               VAL1  :  Scalar or [N,M]-element [numeric] array from which VAL2 is
;                          subtracted
;               VAL2  :  Scalar or [N,M]-element [numeric] array to subtract from VAL1
;
;  EXAMPLES:    
;               [calling sequence]
;               result = lbw_diff(val1, val2 [,/NAN])
;
;  KEYWORDS:    
;               NAN   :  If set, routine will ignore NaNs during the differencing
;                          [Default = FALSE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This routine uses the TOTAL.PRO function to avoid issues with NaNs
;                     during subtraction that would otherwise cause all values to become
;                     NaNs.  When the NAN keyword is set, any value that is a NaN will
;                     become a zero on output.
;               2)  Note that both inputs must be the same size in dimensions and number
;                     of elements, otherwise routine will quit with a return of FALSE
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

FUNCTION lbw_diff,val1,val2,NAN=nan

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Error messages
noinput_mssg   = 'User must supply two inputs from which the difference can be calculated...'
incorrf_mssg   = 'Incorrect input format:  VAL1 and VAL2 must be numeric scalars or arrays...'
badform_mssg   = "Incorrect input format:  VAL1 and VAL2 must have the same dimensions..."
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2)
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_number(val1,/NOMSSG) EQ 0) OR (is_a_number(val2,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,incorrf_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define paramters
szv1           = SIZE(val1,/DIMENSIONS)
szv2           = SIZE(val2,/DIMENSIONS)
test           = (N_ELEMENTS(szv1) NE N_ELEMENTS(szv2)) OR (N_ELEMENTS(val1) NE N_ELEMENTS(val2))
IF (test[0]) THEN BEGIN
  MESSAGE,badform_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Calculate difference
;;----------------------------------------------------------------------------------------
CASE N_ELEMENTS(szv1) OF
  1    : BEGIN
    ;;  Both are 1D arrays
    array = [[val1],[-1*val2]]
    temp  = TOTAL(array,2,NAN=nan)
    IF (szv1[0] EQ 0) THEN diff = temp[0] ELSE diff = temp     ;;  check for scalar input
  END
  2    : BEGIN
    ;;  Both are 2D arrays
    array = [[[val1]],[[-1*val2]]]
    diff  = TOTAL(array,3,NAN=nan)
  END
  ELSE : BEGIN
    ;;  Not currently handling higher dimensional arrays
    errmsg = 'Incorrect input format:  VAL1 and VAL2 cannot have more than two dimensions...'
    MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0b
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,diff
END
