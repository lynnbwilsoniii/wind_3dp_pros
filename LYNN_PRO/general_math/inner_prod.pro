;+
;*****************************************************************************************
;
;  FUNCTION :   inner_prod.pro
;  PURPOSE  :   Calculates the inner product between two vectors.  The output will be
;                 either an [N]-element or (TWO = FALSE) [N,3]-element (TWO = TRUE)
;                 array.  The output will be give by:
;                    RESULT = VEC1 . VEC2*
;                 where V* is the complex conjugate of V (only applies if input is
;                 complex).
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_3_vector.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VEC1  :  [N,3]- or [3,N]-element [numeric] array of 3-vectors for which
;                          to compute the inner product with VEC2.
;               VEC2  :  [N,3]- or [3,N]-element [numeric] array of 3-vectors for which
;                          to compute the inner product with VEC1.
;
;  EXAMPLES:    
;               [calling sequence]
;               ip = inner_prod(vec1, vec2 [,/TWO] [,/NAN])
;
;  KEYWORDS:    
;               TWO     :  If set, routine returns |VEC| as an [N,3]--element array,
;                            where the magnitudes are copied in each of the second
;                            dimensions
;                            [Default = FALSE]
;               NAN     :  If set, routine will replace computed zeros with NaNs on
;                            output for non-finite input values
;                            [Default = FALSE]
;               NOMSSG  :  If set, routine will not print out warning or timing messages
;                            [Default = FALSE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This routine uses the TOTAL.PRO function to avoid issues with NaNs
;                     during addition that would otherwise cause all values to become
;                     NaNs.  When the NAN keyword is set, any value that is a NaN will
;                     become a zero on output.
;               2)  Note that both inputs must be the same size in dimensions and number
;                     of elements, otherwise routine will quit with a return of FALSE
;               3)  Unlike the dot-product routine, my_dot_prod.pro, this routine can
;                     handle complex inputs.
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

FUNCTION inner_prod,vec1,vec2,TWO=two,NAN=nan,NOMSSG=nomssg

ex_start       = SYSTIME(1)
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
dumb3r         = REPLICATE(1,3)
dumb3i         = REPLICATE(DCOMPLEX(1,1),3)
;;  Error messages
noinput_mssg   = 'No input was supplied...'
incorrf_mssg   = 'Incorrect input format:  VEC1 and VEC2 must be numeric 3-vectors...'
badform_mssg   = "Incorrect input format:  VEC1 and VEC2 must have the same dimensions..."
mssg_on        = ~KEYWORD_SET(nomssg)
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2)
IF (test[0]) THEN BEGIN
  IF (mssg_on[0]) THEN MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_3_vector(vec1,V_OUT=vv1,/NOMSSG) EQ 0) OR $
                 (is_a_3_vector(vec2,V_OUT=vv2,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  IF (mssg_on[0]) THEN MESSAGE,incorrf_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define paramters
szv1           = SIZE(vv1,/DIMENSIONS)
szv2           = SIZE(vv2,/DIMENSIONS)
test           = (N_ELEMENTS(szv1) NE N_ELEMENTS(szv2)) OR (N_ELEMENTS(vv1) NE N_ELEMENTS(vv2))
IF (test[0]) THEN BEGIN
  IF (mssg_on[0]) THEN MESSAGE,badform_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check TWO
test2d_off     = (N_ELEMENTS(two) EQ 0) OR ~KEYWORD_SET(two)
;;----------------------------------------------------------------------------------------
;;  Check for complex values
;;----------------------------------------------------------------------------------------
test_comp      = (TOTAL(IMAGINARY(vv1)) EQ 0) OR (TOTAL(IMAGINARY(vv2)) EQ 0)
IF (test_comp[0]) THEN BEGIN
  ;;  Input is real
  v12  = vv1*vv2
ENDIF ELSE BEGIN
  ;;  Input has finite imaginary parts
  v12  = vv1*CONJ(vv2)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Compute inner product
;;----------------------------------------------------------------------------------------
inprod0        = TOTAL(v12,2L,NAN=nan)
IF (test2d_off[0]) THEN inprod = inprod0 ELSE inprod = inprod0 # dumb3r
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
IF (mssg_on[0]) THEN MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE

RETURN, inprod
END