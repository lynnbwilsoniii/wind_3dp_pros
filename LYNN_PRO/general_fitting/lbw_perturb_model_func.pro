;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_perturb_model_func.pro
;  PURPOSE  :   This routine takes the model fit results from a routine like
;                 wrapper_multi_func_fit.pro and then perturbs the fit parameters,
;                 PARAM, using the uncertainties in those parameters, DPARM, to create
;                 a range of possible fit lines evaluated at abscissa values, XX.  Thus,
;                 A --> { A - ∂A, A, A + ∂A } and so on, providing 3^4 (or 81) possible
;                 parameter values to evaluate.  This is useful for creating ranges for
;                 predictive or constraint purposes.
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
;               X         :  [N]-Element [float/double] array of independent variable
;                              values or abscissa, where F_j = F(X_j)
;               PARAM     :  [4]-Element [float/double] array containing the following
;                              model fit parameters, {A,B,C,D}, for the model functions
;                              (see KEYWORDS section below) defined as:
;                                PARAM[0] = A
;                                PARAM[1] = B
;                                PARAM[2] = C
;                                PARAM[3] = D
;               DPARM     :  [4]-Element [float/double] array defining the uncertainties
;                              for each fit element in PARAM
;
;  EXAMPLES:    
;               [calling sequence]
;               test = lbw_perturb_model_func(xx, param, dparm [,FUNC=func])
;
;               ;;  Example usage
;               xx             = [1d-2,1d0,1d1,1d2,1d4,1d7]
;               param          = [3.972d0,0.536d0,1.859d0,0d0]
;               dparm          = [0.055d0,0.007d0,0.047d0,0d0]
;               func           = 1
;               test           = lbw_perturb_model_func(xx,param,dparm,FUNC=func)
;               HELP, test
;                 TEST            DOUBLE    = Array[6, 3, 3, 3, 3]
;
;  KEYWORDS:    
;               FUNC      :  Scalar [integer] specifying the type of function to use
;                              [Default  :  1]
;                              1  :  F(X) = A X^(B) + C
;                              2  :  F(X) = A e^(B X) + C
;                              3  :  F(X) = A + B Log_{e} |X^C|
;                              4  :  F(X) = A X^(B) e^(C X) + D
;                              5  :  F(X) = A B^(X) + C
;                              6  :  F(X) = A B^(C X) + D
;                              7  :  F(X) = ( A + B X )^(-1)
;                              8  :  F(X) = ( A B^(X) + C )^(-1)
;                              9  :  F(X) = A X^(B) ( e^(C X) + D )^(-1)
;                             10  :  F(X) = A + B Log_{10} |X| + C (Log_{10} |X|)^2
;                             11  :  F(X) = A X^(B) e^(C X) e^(D X)
;
;   CHANGED:  1)  Fixed a bug where the number of elements of the input X exceeded the
;                   signed integer limit for the FOR loops in the definitions of the
;                   outputs
;                                                                  [12/11/2015   v1.0.1]
;             2)  Removed the FOR loop over the N elements of X and changed CASE
;                   statement [testing version]
;                                                                  [12/11/2015   v1.0.2]
;             3)  Cleaned up significantly
;                                                                  [12/11/2015   v1.1.0]
;
;   NOTES:      
;               1)  Follow input specifications above...
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/25/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/11/2015   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_perturb_model_func,x,param,dparm,FUNC=func

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number
;;----------------------------------------------------------------------------------------
;;  Define some constant, dummy, and default variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_func       = 1
func_mnmx      = [1,11]
ones           = [-1,0,1]
;;  Dummy error messages
no_inpt_msg    = 'User must supply X [numeric], PARAM [numeric], and DPARM [numeric] inputs...'
badinpt_msg    = 'PARAM and DPARM must be [4]-element arrays...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 3) OR (is_a_number(x,/NOMSSG) EQ 0) OR                 $
                 (is_a_number(param,/NOMSSG) EQ 0) OR (is_a_number(dparm,/NOMSSG) EQ 0)
IF (test) THEN BEGIN
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check format
test           = ((N_ELEMENTS(param) LT 4) OR (N_ELEMENTS(dparm) LT 4)) OR $
                  (N_ELEMENTS(param) NE N_ELEMENTS(dparm))
IF (test) THEN BEGIN
  MESSAGE,badinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define new parameters
;;----------------------------------------------------------------------------------------
xx             = REFORM(x)
pp             = REFORM(param)
dp             = REFORM(dparm)
nx             = N_ELEMENTS(xx)
nones          = REPLICATE(1d0,nx[0])
a_vary         = pp[0] + ones*dp[0]     ;;  i.e., [A - ∂A, A, A + ∂A]
b_vary         = pp[1] + ones*dp[1]
c_vary         = pp[2] + ones*dp[2]
d_vary         = pp[3] + ones*dp[3]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check FUNC
test           = (N_ELEMENTS(func) EQ 0) OR (is_a_number(func,/NOMSSG) EQ 0)
IF (test) THEN fitf = def_func[0] ELSE fitf = (FIX(func[0]) > func_mnmx[0]) < func_mnmx[1]
;;----------------------------------------------------------------------------------------
;;  Calculate result
;;----------------------------------------------------------------------------------------
ff             = DBLARR(nx[0],3L,3L,3L,3L)
CASE fitf[0] OF
  1    : BEGIN
    ;;  Y = A X^(B) + C
    FOR i=0, 2 DO BEGIN              ;;  A index
      a_o                 = a_vary[i]
      FOR j=0, 2 DO BEGIN            ;;  B index
        b_o                 = b_vary[j]
        FOR k=0, 2 DO BEGIN          ;;  C index
          c_o                 = c_vary[k]
            temp                  = a_o[0]*(xx^(b_o[0])) + c_o[0]
            ff[*,i,j,k,0]         = temp
            ff[*,i,j,k,1]         = temp
            ff[*,i,j,k,2]         = temp
        ENDFOR
      ENDFOR
    ENDFOR
  END
  2    : BEGIN
    ;;  Y = A e^(B X) + C
    FOR i=0, 2 DO BEGIN              ;;  A index
      a_o                 = a_vary[i]
      FOR j=0, 2 DO BEGIN            ;;  B index
        b_o                 = b_vary[j]
        FOR k=0, 2 DO BEGIN          ;;  C index
          c_o                 = c_vary[k]
            temp                  = a_o[0]*EXP(b_o[0]*xx) + c_o[0]
            ff[*,i,j,k,0]         = temp
            ff[*,i,j,k,1]         = temp
            ff[*,i,j,k,2]         = temp
        ENDFOR
      ENDFOR
    ENDFOR
  END
  3    : BEGIN
    ;;  Y = A + B Log_{e} |X^C|
    FOR i=0, 2 DO BEGIN              ;;  A index
      a_o                 = a_vary[i]
      FOR j=0, 2 DO BEGIN            ;;  B index
        b_o                 = b_vary[j]
        FOR k=0, 2 DO BEGIN          ;;  C index
          c_o                 = c_vary[k]
            temp                  = a_o[0] + b_o[0]*ALOG(ABS(xx^(c_o[0])))
            ff[*,i,j,k,0]         = temp
            ff[*,i,j,k,1]         = temp
            ff[*,i,j,k,2]         = temp
        ENDFOR
      ENDFOR
    ENDFOR
  END
  4    : BEGIN
    ;;  Y = A X^(B) e^(C X) + D
    FOR i=0, 2 DO BEGIN              ;;  A index
      a_o                 = a_vary[i]
      FOR j=0, 2 DO BEGIN            ;;  B index
        b_o                 = b_vary[j]
        FOR k=0, 2 DO BEGIN          ;;  C index
          c_o                 = c_vary[k]
          FOR l=0, 2 DO BEGIN        ;;  D index
            d_o                   = d_vary[l]
            ff[*,i,j,k,l]         = a_o[0]*(xx^(b_o[0]))*EXP(c_o[0]*xx) + d_o[0]
          ENDFOR
        ENDFOR
      ENDFOR
    ENDFOR
  END
  5    : BEGIN
    ;;  Y = A B^(X) + C
    FOR i=0, 2 DO BEGIN              ;;  A index
      a_o                 = a_vary[i]
      FOR j=0, 2 DO BEGIN            ;;  B index
        b_o                 = b_vary[j]
        FOR k=0, 2 DO BEGIN          ;;  C index
          c_o                 = c_vary[k]
            temp                  = a_o[0]*(b_o[0]^(xx)) + c_o[0]
            ff[*,i,j,k,0]         = temp
            ff[*,i,j,k,1]         = temp
            ff[*,i,j,k,2]         = temp
        ENDFOR
      ENDFOR
    ENDFOR
  END
  6    : BEGIN
    ;;  Y = A B^(C X) + D
    FOR i=0, 2 DO BEGIN              ;;  A index
      a_o                 = a_vary[i]
      FOR j=0, 2 DO BEGIN            ;;  B index
        b_o                 = b_vary[j]
        FOR k=0, 2 DO BEGIN          ;;  C index
          c_o                 = c_vary[k]
          FOR l=0, 2 DO BEGIN        ;;  D index
            d_o                   = d_vary[l]
            ff[*,i,j,k,l]         = a_o[0]*(b_o[0]^(c_o[0]*xx)) + d_o[0]
          ENDFOR
        ENDFOR
      ENDFOR
    ENDFOR
  END
  7    : BEGIN
    ;;  Y = ( A + B X )^(-1)
    FOR i=0, 2 DO BEGIN              ;;  A index
      a_o                 = a_vary[i]
      FOR j=0, 2 DO BEGIN            ;;  B index
        b_o                 = b_vary[j]
        FOR k=0, 2 DO BEGIN          ;;  C index
          c_o                 = c_vary[k]
            temp                  = 1d0/(a_o[0] + b_o[0]*xx)
            ff[*,i,j,k,0]         = temp
            ff[*,i,j,k,1]         = temp
            ff[*,i,j,k,2]         = temp
        ENDFOR
      ENDFOR
    ENDFOR
  END
  8    : BEGIN
    ;;  Y = ( A B^(X) + C )^(-1)
    FOR i=0, 2 DO BEGIN              ;;  A index
      a_o                 = a_vary[i]
      FOR j=0, 2 DO BEGIN            ;;  B index
        b_o                 = b_vary[j]
        FOR k=0, 2 DO BEGIN          ;;  C index
          c_o                 = c_vary[k]
            temp                  = 1d0/( a_o[0]*(b_o[0]^(xx)) + c_o[0] )
            ff[*,i,j,k,0]         = temp
            ff[*,i,j,k,1]         = temp
            ff[*,i,j,k,2]         = temp
        ENDFOR
      ENDFOR
    ENDFOR
  END
  9    : BEGIN
    ;;  Y = A X^(B) ( e^(C X) + D )^(-1)
    FOR i=0, 2 DO BEGIN              ;;  A index
      a_o                 = a_vary[i]
      FOR j=0, 2 DO BEGIN            ;;  B index
        b_o                 = b_vary[j]
        FOR k=0, 2 DO BEGIN          ;;  C index
          c_o                 = c_vary[k]
          FOR l=0, 2 DO BEGIN        ;;  D index
            d_o                   = d_vary[l]
            ff[*,i,j,k,l]         = a_o[0]*(xx^(b_o[0]))/( EXP(c_o[0]*xx) + d_o[0] )
          ENDFOR
        ENDFOR
      ENDFOR
    ENDFOR
  END
  10   : BEGIN
    ;;  Y = A + B Log_{10} |X| + C (Log_{10} |X|)^2
    FOR i=0, 2 DO BEGIN              ;;  A index
      a_o                 = a_vary[i]
      FOR j=0, 2 DO BEGIN            ;;  B index
        b_o                 = b_vary[j]
        FOR k=0, 2 DO BEGIN          ;;  C index
          c_o                 = c_vary[k]
            temp                  = a_o[0] + b_o[0]*ALOG10(ABS(xx)) + c_o[0]*(ALOG10(ABS(xx))^2)
            ff[*,i,j,k,0]         = temp
            ff[*,i,j,k,1]         = temp
            ff[*,i,j,k,2]         = temp
        ENDFOR
      ENDFOR
    ENDFOR
  END
  11   : BEGIN
    ;;  Y = A X^(B) e^(C X) e^(D X)
    FOR i=0, 2 DO BEGIN              ;;  A index
      a_o                 = a_vary[i]
      FOR j=0, 2 DO BEGIN            ;;  B index
        b_o                 = b_vary[j]
        FOR k=0, 2 DO BEGIN          ;;  C index
          c_o                 = c_vary[k]
          FOR l=0, 2 DO BEGIN        ;;  D index
            d_o                   = d_vary[l]
            ff[*,i,j,k,l]         = a_o[0]*(xx^(b_o[0]))*EXP(c_o[0]*xx)*EXP(d_o[0]*xx)
          ENDFOR
        ENDFOR
      ENDFOR
    ENDFOR
  END
  ELSE : BEGIN
    ;;  Use default:  Y = A X^(B) + C
    FOR i=0, 2 DO BEGIN              ;;  A index
      a_o                 = a_vary[i]
      FOR j=0, 2 DO BEGIN            ;;  B index
        b_o                 = b_vary[j]
        FOR k=0, 2 DO BEGIN          ;;  C index
          c_o                 = c_vary[k]
            temp                  = a_o[0]*(xx^(b_o[0])) + c_o[0]
            ff[*,i,j,k,0]         = temp
            ff[*,i,j,k,1]         = temp
            ff[*,i,j,k,2]         = temp
        ENDFOR
      ENDFOR
    ENDFOR
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,ff
END
