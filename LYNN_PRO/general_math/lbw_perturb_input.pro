;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_perturb_input.pro
;  PURPOSE  :   This routine perturbs the input array, where the output is given by:
;                              { -1 * din
;                  out = inp + {  0 * din
;                              { +1 * din
;
;  CALLED BY:   
;               lbw_calc_perturbed_muldivaddsub.pro
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
;               IN1   :  [I,J,K,...N]-Element [numeric] array of input-1 values to be
;                          perturbed and then operated on
;               DI1   :  [I,J,K,...N]-Element [numeric] array of uncertainty-1 values to
;                          use to perturb IN1
;
;  EXAMPLES:    
;               [calling sequence]
;               pin = lbw_perturb_input(in1,di1 [,NSIG=nsig])
;
;               ;;  Examples
;               xx             = dindgen(5) + 1d0
;               dx             = 1d-1*xx
;               xx_p           = lbw_perturb_input(xx,dx,NSIG=1)
;               PRINT, TRANSPOSE(xx_p)
;                     0.90000000       1.8000000       2.7000000       3.6000000       4.5000000
;                      1.0000000       2.0000000       3.0000000       4.0000000       5.0000000
;                      1.1000000       2.2000000       3.3000000       4.4000000       5.5000000
;               
;               xx             = dindgen(5) + 1d0
;               dx             = 1d-1*xx
;               xx_p           = lbw_perturb_input(xx,dx,NSIG=3)
;               PRINT, TRANSPOSE(xx_p)
;                     0.70000000       1.4000000       2.1000000       2.8000000       3.5000000
;                     0.80000000       1.6000000       2.4000000       3.2000000       4.0000000
;                     0.90000000       1.8000000       2.7000000       3.6000000       4.5000000
;                      1.0000000       2.0000000       3.0000000       4.0000000       5.0000000
;                      1.1000000       2.2000000       3.3000000       4.4000000       5.5000000
;                      1.2000000       2.4000000       3.6000000       4.8000000       6.0000000
;                      1.3000000       2.6000000       3.9000000       5.2000000       6.5000000
;
;  KEYWORDS:    
;               NSIG  :  Scalar [integer/long] defining the number of sigma by which to
;                          perturb input.  The output result will have an extra dimension
;                          prepended to the input array with (2*NSIG + 1) elements.
;                          Values between 1 and 6 are allow.
;                          [Default = 1]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               0)  User should not call this routine in isolation
;               1)  Inputs should have the same dimensions
;               2)  Inputs should not have more than 6 dimensions
;
;  REFERENCES:  
;               NA
;
;   CREATED:  02/17/2022
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/17/2022   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_perturb_input,in1,di1,NSIG=nsig

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_pert       = [-1d0,0d0,1d0]
dim_max        = 6L
dim_mxs        = '6'
;;  Dummy error messages
no_inpt__mssg  = 'User must supply IN1 and DI1 as [I,J,K,...N]-element [numeric] arrays...'
badndim__mssg  = 'Inputs IN1 and DI1 must have the same dimensions...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (is_a_number(in1,/NOMSSG) EQ 0) OR $
                 (is_a_number(di1,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check dimensions
szdx           = SIZE(in1,/DIMENSIONS)
sznx           = SIZE(in1,/N_DIMENSIONS)
szdy           = SIZE(di1,/DIMENSIONS)
szny           = SIZE(di1,/N_DIMENSIONS)
test           = (sznx[0] NE szny[0]) OR (TOTAL(szdx) NE TOTAL(szdy))
IF (test[0]) THEN BEGIN
  MESSAGE,badndim__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
IF (sznx[0] GT dim_max[0] OR szny[0] GT dim_max[0]) THEN BEGIN
  MESSAGE,"Cannot handle >"+dim_mxs[0]+" dimensional arrays!!!",/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NSIG
IF (is_a_number(nsig,/NOMSSG) EQ 0) THEN BEGIN
  ;;  Use default
  pert           = def_pert
  ns             = (2L*1L + 1L)
ENDIF ELSE BEGIN
  ;;  Keyword is set --> Check format
  nns            = (LONG(ABS(nsig[0])) > 1L) < 6L
  ns             = (2L*nns[0] + 1L)
  pert           = DINDGEN(ns[0]) - (1d0*nns[0])
ENDELSE

;;----------------------------------------------------------------------------------------
;;  Perturb the result
;;----------------------------------------------------------------------------------------
;;  Dummy array of perturbed values
dumb           = MAKE_ARRAY([ns[0],szdx],VALUE=d)
nt             = N_ELEMENTS(in1)
rin1p          = REFORM(dumb,ns[0],nt[0])
r_in1          = REFORM(in1,nt[0])
r_di1          = REFORM(di1,nt[0])
FOR j=0L, ns[0] - 1L DO BEGIN
  rin1p[j,*] = r_in1 + pert[j]*r_di1
ENDFOR
;;  "Unwind" the array to original dimensions
in1_p          = REFORM(rin1p,[ns[0],szdx])
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,in1_p
END


