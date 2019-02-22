;*****************************************************************************************
;
;  FUNCTION :   get_gradients_multifunc.pro
;  PURPOSE  :   This routine returns the numerical estimates of the partial derivatives
;                 with respect to the different variable parameters used in the model
;                 fit functions defined below.
;
;  CALLED BY:   
;               get_fitline_and_gradients_multifunc.pro
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
;               XX        :  [N]-Element array of independent variable values
;               PARAM     :  [4]-Element array containing the following initialization
;                              quantities for the model functions (see below):
;                                PARAM[0] = A
;                                PARAM[1] = B
;                                PARAM[2] = C
;                                PARAM[3] = D
;               PART      :  Scalar [integer] specifying which partial derivative to
;                              return to the user for F = F(A,B,C,D)
;                              [Default  :  1]
;                                1  :  dF/dA
;                                2  :  dF/dB
;                                3  :  dF/dC
;                                4  :  dF/dD
;               FIT_FUNC  :  Scalar [integer] specifying the type of function to use
;                              [Default  :  1]
;                                1  :  F(A,B,C,D,X) = A X^(B) + C
;                                2  :  F(A,B,C,D,X) = A e^(B X) + C
;                                3  :  F(A,B,C,D,X) = A + B Log_{e} |X^C|
;                                4  :  F(A,B,C,D,X) = A X^(B) e^(C X) + D
;                                5  :  F(A,B,C,D,X) = A B^(X) + C
;                                6  :  F(A,B,C,D,X) = A B^(C X) + D
;                                7  :  F(A,B,C,D,X) = ( A + B X )^(-1)
;                                8  :  F(A,B,C,D,X) = ( A B^(X) + C )^(-1)
;                                9  :  F(A,B,C,D,X) = A X^(B) ( e^(C X) + D )^(-1)
;                               10  :  F(A,B,C,D,X) = A + B Log_{10} |X| + C (Log_{10} |X|)^2
;                               11  :  F(A,B,C,D,X) = A X^(B) e^(C X) e^(D X)
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Changed name of calling routine from
;                   get_fitline_and_gradients_multifunc.pro to
;                   get_fitline_and_grad_multifunc.pro
;                                                                   [08/07/2015   v1.1.0]
;
;   NOTES:      
;               1)  User should not call this routine directly
;               2)  See also:  wrapper_multi_func_fit.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/31/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/07/2015   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION get_gradients_multifunc,xvals,param,part,fit_func

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
func_mnmx      = [1,11]
part_mnmx      = [1,4]
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (N_ELEMENTS(param) LT 4)
IF (test) THEN BEGIN
  ;;  no input???
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define new parameters
;;----------------------------------------------------------------------------------------
xx             = REFORM(xvals)
pp             = REFORM(param)

nx             = N_ELEMENTS(xx)
zeros          = REPLICATE(0d0,nx)
ones           = REPLICATE(1d0,nx)
;;----------------------------------------------------------------------------------------
;;  Check optional inputs
;;----------------------------------------------------------------------------------------
;;  Determine which partial to return
test           = (N_ELEMENTS(part) EQ 0) OR (is_a_number(part,/NOMSSG) EQ 0)
IF (test) THEN dfd_ = 1 ELSE dfd_ = (FIX(part[0]) > part_mnmx[0]) < part_mnmx[1]

;;  Check FIT_FUNC
test           = (N_ELEMENTS(fit_func) EQ 0) OR (is_a_number(fit_func,/NOMSSG) EQ 0)
IF (test) THEN fitf = 1 ELSE fitf = (FIX(fit_func[0]) > func_mnmx[0]) < func_mnmx[1]
;;----------------------------------------------------------------------------------------
;;  Calculate partial derivatives of F = F(A,B,C,D)
;;    dF/dA = ?
;;    dF/dB = ?
;;    dF/dC = ?
;;    dF/dD = ?
;;----------------------------------------------------------------------------------------
CASE fitf[0] OF
  1    : BEGIN
    ;;  Y = A X^(B) + C
    CASE dfd_[0] OF
      1    : pder = xx^(param[1])
      2    : pder = param[0]*xx^(param[1])*ALOG(xx)
      3    : pder = ones
      4    : pder = zeros
      ELSE : pder = xx^(param[1])
    ENDCASE
  END
  2    : BEGIN
    ;;  Y = A e^(B X) + C
    CASE dfd_[0] OF
      1    : pder = EXP(param[1]*xx)
      2    : pder = param[0]*xx*EXP(param[1]*xx)
      3    : pder = ones
      4    : pder = zeros
      ELSE : pder = EXP(param[1]*xx)
    ENDCASE
  END
  3    : BEGIN
    ;;  Y = A + B Log_{e} |X^C|
    CASE dfd_[0] OF
      1    : pder = ones
      2    : pder = ALOG(ABS(xx^param[2]))
      3    : pder = param[1]*ALOG(ABS(xx))
      4    : pder = zeros
      ELSE : pder = ones
    ENDCASE
  END
  4    : BEGIN
    ;;  Y = A X^(B) e^(C X) + D
    CASE dfd_[0] OF
      1    : pder = xx^(param[1])*EXP(param[2]*xx)
      2    : pder = param[0]*xx^(param[1])*EXP(param[2]*xx)*ALOG(xx)
      3    : pder = param[0]*xx^(param[1] + 1d0)*EXP(param[2]*xx)
      4    : pder = ones
      ELSE : pder = xx^(param[1])*EXP(param[2]*xx)
    ENDCASE
  END
  5    : BEGIN
    ;;  Y = A B^(X) + C
    CASE dfd_[0] OF
      1    : pder = param[1]^(xx)
      2    : pder = param[0]*xx*param[1]^(xx - 1d0)
      3    : pder = ones
      4    : pder = zeros
      ELSE : pder = param[1]^(xx)
    ENDCASE
  END
  6    : BEGIN
    ;;  Y = A B^(C X) + D
    CASE dfd_[0] OF
      1    : pder = param[1]^(param[2]*xx)
      2    : pder = param[0]*param[2]*xx*param[1]^(param[2]*xx - 1d0)
      3    : pder = param[0]*param[1]^(param[2]*xx)*xx*ALOG(param[1])
      4    : pder = ones
      ELSE : pder = param[1]^(param[2]*xx)
    ENDCASE
  END
  7    : BEGIN
    ;;  Y = ( A + B X )^(-1)
    CASE dfd_[0] OF
      1    : pder = -1d0/(param[0] + param[1]*xx)^2
      2    : pder = -1d0*xx/(param[0] + param[1]*xx)^2
      3    : pder = zeros
      4    : pder = zeros
      ELSE : pder = -1d0/(param[0] + param[1]*xx)^2
    ENDCASE
  END
  8    : BEGIN
    ;;  Y = ( A B^(X) + C )^(-1)
    CASE dfd_[0] OF
      1    : pder = -1d0*param[1]^(xx)/(param[0]*param[1]^(xx) + param[2])^2
      2    : pder = -1d0*param[0]*xx*param[1]^(xx - 1d0)/(param[0]*param[1]^(xx) + param[2])^2
      3    : pder = -1d0/(param[0]*param[1]^(xx) + param[2])^2
      4    : pder = zeros
      ELSE : pder = -1d0*param[1]^(xx)/(param[0]*param[1]^(xx) + param[2])^2
    ENDCASE
  END
  9    : BEGIN
    ;;  Y = A X^(B) ( e^(C X) + D )^(-1)
    CASE dfd_[0] OF
      1    : pder = xx^(param[1])/denom
      2    : pder = param[0]*xx^(param[1])*ALOG(xx)/denom
      3    : pder = -1d0*param[0]*xx^(param[1] + 1d0)*EXP(param[2]*xx)/denom^2
      4    : pder = -1d0*param[0]*xx^(param[1])/denom^2
      ELSE : pder = xx^(param[1])/denom
    ENDCASE
  END
  10   : BEGIN
    ;;  Y = A + B Log_{10} |X| + C (Log_{10} |X|)^2
    CASE dfd_[0] OF
      1    : pder = ones
      2    : pder = ALOG10(xx)
      3    : pder = ALOG10(xx)^2
      4    : pder = zeros
      ELSE : pder = ones
    ENDCASE
  END
  11   : BEGIN
    ;;  Y = A X^(B) e^(C X) e^(D X)
    CASE dfd_[0] OF
      1    : pder = xx^(param[1])*EXP((param[2] + param[3])*xx)
      2    : pder = param[0]*xx^(param[1])*EXP((param[2] + param[3])*xx)*ALOG(xx)
      3    : pder = param[0]*xx^(param[1] + 1d0)*EXP((param[2] + param[3])*xx)
      4    : pder = param[0]*xx^(param[1] + 1d0)*EXP((param[2] + param[3])*xx)
      ELSE : pder = xx^(param[1])*EXP(param[2]*xx)
    ENDCASE
  END
  ELSE : BEGIN
    ;;  Use default:  Y = A X^(B) + C
    CASE dfd_[0] OF
      1    : pder = xx^(param[1])
      2    : pder = param[0]*xx^(param[1])*ALOG(xx)
      3    : pder = ones
      4    : pder = zeros
      ELSE : pder = xx^(param[1])
    ENDCASE
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,pder
END


;+
;*****************************************************************************************
;
;  FUNCTION :   get_fitline_and_grad_multifunc.pro
;  PURPOSE  :   This routine takes an array of fit parameters and a model function
;                 specification and returns a structure containing the abscissa and
;                 associated fit function values, strings for output, and partial
;                 derivatives of F(A,B,C,D,X) with respect to [A,B,C,D].
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               get_gradients_multifunc.pro
;
;  CALLS:
;               is_a_number.pro
;               get_gradients_multifunc.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               PARAM     :  [4]-Element [float/double] array containing the following
;                              model fit parameters, {A,B,C,D}, for the model functions
;                              (see KEYWORDS section below) defined as:
;                                PARAM[0] = A
;                                PARAM[1] = B
;                                PARAM[2] = C
;                                PARAM[3] = D
;               FIT_FUNC  :  Scalar [integer] specifying the type of function to use
;                              [Default  :  1]
;                                1  :  F(A,B,C,D,X) = A X^(B) + C
;                                2  :  F(A,B,C,D,X) = A e^(B X) + C
;                                3  :  F(A,B,C,D,X) = A + B Log_{e} |X^C|
;                                4  :  F(A,B,C,D,X) = A X^(B) e^(C X) + D
;                                5  :  F(A,B,C,D,X) = A B^(X) + C
;                                6  :  F(A,B,C,D,X) = A B^(C X) + D
;                                7  :  F(A,B,C,D,X) = ( A + B X )^(-1)
;                                8  :  F(A,B,C,D,X) = ( A B^(X) + C )^(-1)
;                                9  :  F(A,B,C,D,X) = A X^(B) ( e^(C X) + D )^(-1)
;                               10  :  F(A,B,C,D,X) = A + B Log_{10} |X| + C (Log_{10} |X|)^2
;                               11  :  F(A,B,C,D,X) = A X^(B) e^(C X) e^(D X)
;
;  EXAMPLES:    
;               test = get_fitline_and_grad_multifunc(pp,fitf,XRAN=xran,XLOG=xlog,$
;                                                     NUMX=numx,XVALS=xvals)
;
;  KEYWORDS:    
;               XRAN      :  [2]-Element [float/double] array defining the range of
;                              independent variable values or abscissa,
;                              where F_j = F(X_j)
;               XLOG      :  If set, abscissa values are calculated in logarithmic space
;                              for the X_OUT values
;               NUMX      :  Scalar [integer/long] defining the number of evenly spaced
;                              abscissa values to use when calculating the fit line and
;                              partial derivatives
;               XVALS     :  [N]-Element [float/double] array defining the specific
;                              abscissa values to use when calculating the fit line and
;                              partial derivatives
;
;   CHANGED:  1)  Changed name from get_fitline_and_gradients_multifunc.pro to
;                   get_fitline_and_grad_multifunc.pro
;                                                                   [08/07/2015   v1.1.0]
;
;   NOTES:      
;               1)  See also:  wrapper_multi_func_fit.pro
;               2)  This routine may alter the values of inputs --> use copies if
;                     necessary
;               3)  If XVALS and XRAN are both set --> XVALS will be used to determine
;                     new XRAN
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/31/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/07/2015   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_fitline_and_grad_multifunc,param,fit_func,XRAN=xran,XLOG=xlog,$
                                             NUMX=numx,XVALS=xvals

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, get_gradients_multifunc
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define some constants, dummy variables, and defaults
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Dummy variables
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_nx         = 200L
min_nx         =  50L
func_mnmx      = [1,11]
part_mnmx      = [1,4]
diff_part      = MAX(part_mnmx) - MIN(part_mnmx)
part_ind       = LINDGEN(diff_part[0] + 1L) + MIN(part_mnmx)
test_xval      = 0b
test_xran      = 0b
;;  Dummy error messages
no_inpt_msg    = 'User must supply XRAN [numeric] (or XVALS), PARAM [numeric], PART [numeric], and FIT_FUNC [numeric] inputs...'
badxrin_msg    = 'XRAN must be a [2]-element array OR XVALS must be an [N]-element array...'
badpain_msg    = 'PARAM must be a [4]-element array...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
testxr         = ((is_a_number( xran,/NOMSSG) EQ 0) OR (N_ELEMENTS(xran)  LT 2))
testxv         = ((is_a_number(xvals,/NOMSSG) EQ 0) OR (N_ELEMENTS(xvals) LT 2))
testx          = testxr[0] AND testxv[0]
test           = ((N_PARAMS() LT 1) OR (is_a_number(param,/NOMSSG) EQ 0) OR $
                  (N_ELEMENTS(param) LT 4)) OR testx[0]
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  ;;  Check PARAM format
  test           = (N_ELEMENTS(param) LT 4)
  IF ( test[0]) THEN MESSAGE,badpain_msg[0],/INFORMATIONAL,/CONTINUE
  ;;  Check XRAN and XVALS format
  IF (testx[0]) THEN MESSAGE,badxrin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check optional inputs
;;----------------------------------------------------------------------------------------
;;  Check FIT_FUNC
test           = (N_ELEMENTS(fit_func) EQ 0) OR (is_a_number(fit_func,/NOMSSG) EQ 0)
IF (test) THEN fitf = 1 ELSE fitf = (FIX(fit_func[0]) > func_mnmx[0]) < func_mnmx[1]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check XLOG
test           = (N_ELEMENTS(xlog) EQ 0) OR ~KEYWORD_SET(xlog) OR (is_a_number(xlog,/NOMSSG) EQ 0)
IF (test) THEN x_lin = 1b ELSE x_lin = 0b
;;  Check NUMX
test           = (N_ELEMENTS(numx) EQ 0) OR (is_a_number(numx,/NOMSSG) EQ 0)
IF (test) THEN nx = def_nx[0] ELSE nx = ABS(numx[0]) > min_nx[0]
;;  Check XRAN
IF (testxr[0]) THEN test_xran = 0b ELSE test_xran = 1b
;;  Check XVALS
IF (testxv[0]) THEN test_xval = 0b ELSE test_xval = 1b

IF (test_xval[0] AND test_xran[0]) THEN BEGIN
  ;;  Both set --> use XVALS if good inputs
  tempxr         = [MIN(xvals,/NAN),MAX(xvals,/NAN)]
  testx          = ((tempxr[0] EQ tempxr[1]) OR (TOTAL(FINITE(tempxr)) NE 2))
  IF (testx[0]) THEN BEGIN
    tempxr         = [MIN(xran,/NAN),MAX(xran,/NAN)]
    ;;  Unset logic for XVALS
    test_xval      = 0b
  ENDIF
ENDIF ELSE BEGIN
  IF (test_xval[0]) THEN BEGIN
    ;;  XVALS set but maybe not XRAN
    tempxr         = [MIN(xvals,/NAN),MAX(xvals,/NAN)]
  ENDIF ELSE BEGIN
    ;;  XRAN set but not XVALS
    tempxr         = [MIN(xran,/NAN),MAX(xran,/NAN)]
  ENDELSE
ENDELSE
;;  Make sure range is okay
testx          = ((tempxr[0] EQ tempxr[1]) OR (TOTAL(FINITE(tempxr)) NE 2))
IF (testx[0]) THEN BEGIN
  ;;  XRAN and XVALS incorrect format
  MESSAGE,badxrin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define XRAN
xran           = tempxr
;;  Define XVALS
IF (test_xval[0]) THEN BEGIN
  ;;  Already defined --> sort
  xvals = TEMPORARY(xvals[SORT(xvals)])
ENDIF ELSE BEGIN
  ;;  Need to define
  IF (x_lin[0]) THEN BEGIN
    mnmx     = xran
  ENDIF ELSE BEGIN
    mnmx     = ALOG10(xran)
  ENDELSE
  fac_cons = [(mnmx[1] - mnmx[0])/(nx[0] - 1L),mnmx[0]]
  ;;  Define initial array of values
  tempx    = DINDGEN(nx[0])*fac_cons[0] + fac_cons[1]
  ;;  Define XVALS
  IF (x_lin[0]) THEN xvals = tempx ELSE xvals = 1d1^(tempx)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define new parameters
;;----------------------------------------------------------------------------------------
xx             = REFORM(xvals)
pp             = REFORM(param)
;;----------------------------------------------------------------------------------------
;;  Define strings for plot titles, output to screen, and fit lines
;;----------------------------------------------------------------------------------------
CASE fitf[0] OF
  1    : BEGIN
    ;;  Y = A X^(B) + C
    fitf_ysubttl   = 'Y = A X!UB!N + C'
    fitf_print     = 'Y = A X^(B) + C'
    yy             = pp[0]*xx^(pp[1]) + pp[2]
  END
  2    : BEGIN
    ;;  Y = A e^(B X) + C
    fitf_ysubttl   = 'Y = A e!UB X!N + C'
    fitf_print     = 'Y = A e^(B X) + C'
    yy             = pp[0]*EXP(xx*pp[1]) + pp[2]
  END
  3    : BEGIN
    ;;  Y = A + B Log_{e} |X^C|
    fitf_ysubttl   = 'Y = A + B log!De!N'+'|'+'X!UC!N'+'|'
    fitf_print     = 'Y = A + B Log_{e} |X^C|'
    yy             = pp[0] + pp[1]*ALOG(ABS(xx^(pp[2])))
  END
  4    : BEGIN
    ;;  Y = A X^(B) e^(C X) + D
    fitf_ysubttl   = 'Y = A X!UB!N e!UC X!N + D'
    fitf_print     = 'Y = A X^(B) e^(C X) + D'
    yy             = pp[0]*xx^(pp[1])*EXP(xx*pp[2]) + pp[3]
  END
  5    : BEGIN
    ;;  Y = A B^(X) + C
    fitf_ysubttl   = 'Y = A B!UX!N + C'
    fitf_print     = 'Y = A B^(X) + C'
    yy             = pp[0]*pp[1]^(xx) + pp[2]
  END
  6    : BEGIN
    ;;  Y = A B^(C X) + D
    fitf_ysubttl   = 'Y = A B!UC X!N + D'
    fitf_print     = 'Y = A B^(C X) + D'
    yy             = pp[0]*pp[1]^(pp[2]*xx) + pp[3]
  END
  7    : BEGIN
    ;;  Y = ( A + B X )^(-1)
    fitf_ysubttl   = 'Y = [A + B X]!U-1!N'
    fitf_print     = 'Y = [ A + B X ]^(-1)'
    yy             = (pp[0] + pp[1]*xx)^(-1d0)
  END
  8    : BEGIN
    ;;  Y = ( A B^(X) + C )^(-1)
    fitf_ysubttl   = 'Y = [A B!UX!N + C ]!U-1!N'
    fitf_print     = 'Y = [A B^(X) + C ]^(-1)'
    yy             = (pp[0]*pp[1]^(xx) + pp[2])^(-1d0)
  END
  9    : BEGIN
    ;;  Y = A X^(B) ( e^(C X) + D )^(-1)
    fitf_ysubttl   = 'Y = A X!UB!N [ e!UC X!N + D ]!U-1!N'
    fitf_print     = 'Y = A X^(B) [ e^(C X) + D ]^(-1)'
    yy             = pp[0]*xx^(pp[1])*(EXP(xx*pp[2]) + pp[3])^(-1d0)
  END
  10   : BEGIN
    ;;  Y = A + B Log_{10} |X| + C (Log_{10} |X|)^2
    fitf_ysubttl   = 'Y = A + B log!D10!N'+'|X| + C [ log!D10!N'+'|X| ]!U2!N'
    fitf_print     = 'Y = A + B Log_{10} |X| + C [ Log_{10} |X| ]^(2)'
    yy             = pp[0] + pp[1]*ALOG10(ABS(xx)) + pp[2]*(ALOG10(ABS(xx))^(2d0))
  END
  11   : BEGIN
    ;;  Y = A X^(B) e^(C X) e^(D X)
    fitf_ysubttl   = 'Y = A X!UB!N e!UC X!N e!U'+'D X'+'!N'
    fitf_print     = 'Y = A X^(B) e^(C X) e^(D X)'
    yy             = pp[0]*xx^(pp[1])*EXP(xx*pp[2])*EXP(xx*pp[3])
  END
  ELSE : BEGIN 
    ;;  Use default:  Y = A X^(B) + C
    fitf_ysubttl   = 'Y = A X!UB!N + C'
    fitf_print     = 'Y = A X^(B) + C'
    yy             = pp[0]*xx^(pp[1]) + pp[2]
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Get partial derivatives
;;----------------------------------------------------------------------------------------
n_part         = N_ELEMENTS(part_ind)
dF_d_          = REPLICATE(d,nx[0],n_part[0])
FOR j=0L, n_part[0] - 1L DO BEGIN
  ii         = part_ind[j]
  pder       = get_gradients_multifunc(xx,pp,ii[0],fitf[0])
  dF_d_[*,j] = pder
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
tags           = [['X','Y']+'_FIT','YSUBTITLE','F_PRINT','PARTIALS']
struc          = CREATE_STRUCT(tags,xx,yy,fitf_ysubttl[0],fitf_print[0],dF_d_)
;;----------------------------------------------------------------------------------------
;;  Return keywords back to user
;;----------------------------------------------------------------------------------------
IF (x_lin[0]) THEN xlog = 0b ELSE xlog = 1b
numx           = N_ELEMENTS(yy)
xvals          = xx
fit_func       = fitf[0]
param          = pp
xran           = [MIN(xx,/NAN),MAX(xx,/NAN)]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END




