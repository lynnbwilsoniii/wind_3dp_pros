;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_get_dxdy_ranges_from_fits.pro
;  PURPOSE  :   This routine takes an input set of fit parameters and associated
;                 uncertainties the perturbs the resulting fit line using the range
;                 of abscissa values to find ranges of the resulting user defined
;                 function at those abscissa values.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               is_a_number.pro
;               lbw_perturb_model_func.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X         :  [N,2]-Element [float/double] array of independent variable
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
;               test = lbw_get_dxdy_ranges_from_fits(xx,param,dparm,FUNC=func)
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
;               XLOG      :  If set, averages values are calculated in logarithmic space
;                              for the X_OUT values
;               YLOG      :  If set, averages values are calculated in logarithmic space
;                              for the Y_OUT values
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [07/27/2015   v1.0.0]
;             2)  Changed name from temp_lbw_get_dxdy_ranges_from_fits.pro to
;                   lbw_get_dxdy_ranges_from_fits.pro
;                                                                   [08/07/2015   v1.1.0]
;
;   NOTES:      
;               1)  Use results returned by temp_plot_dE_vs_Jo_w_const.pro to create
;                     a simplified plot with single points with ranges of values acting
;                     as uncertainties for regional conditions, i.e., use range of Jo
;                     values at bow shock for X input to determine a range for dE, then
;                     i-th output will be:
;                       X_OUT  :  MEAN(X[i,*],/NAN)
;                       DXOUT  :  ABS(X_OUT - [MIN(X[i,*],/NAN),MAX(X[i,*],/NAN)])
;                       Y_OUT  :  MEAN(F(X[i,*]),/NAN)
;                       DYOUT  :  ABS(Y_OUT - [MIN(F(X[i,*]),/NAN),MAX(F(X[i,*]),/NAN)])
;               2)  The array of potential model functions are the same as those in the
;                     routine wrapper_multi_func_fit.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/25/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/07/2015   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_get_dxdy_ranges_from_fits,x,param,dparm,FUNC=func,XLOG=xlog,YLOG=ylog

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, lbw_perturb_model_func
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
badxinp_msg    = 'X must be an [N,2]-element array of abscissa for F(X)...'
badinpt_msg    = 'PARAM and DPARM must be [4]-element arrays...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 3) OR (is_a_number(x,/NOMSSG) EQ 0) OR                 $
                 (is_a_number(param,/NOMSSG) EQ 0) OR (is_a_number(dparm,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check format:  X
test           = ((N_ELEMENTS(param) MOD 2) NE 0) OR (SIZE(x,/N_DIMENSIONS) NE 2)
IF (test[0]) THEN BEGIN
  MESSAGE,'0:  '+badxinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
szx            = SIZE(x,/DIMENSIONS)
goodx          = WHERE(szx EQ 2,gdx)
test           = (gdx[0] EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,'1:  '+badxinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check format:  PARAM and DPARM
test           = ((N_ELEMENTS(param) LT 4) OR (N_ELEMENTS(dparm) LT 4)) OR $
                  (N_ELEMENTS(param) NE N_ELEMENTS(dparm))
IF (test[0]) THEN BEGIN
  MESSAGE,badinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define new parameters
;;----------------------------------------------------------------------------------------
test           = (gdx[0] EQ 2)
IF (test[0]) THEN BEGIN
  ;;  [2,2]-Element array --> leave alone and assume okay
  xx             = REFORM(x)
ENDIF ELSE BEGIN
  ;;  [N,2]- or [2,N]-element array
  test           = (goodx[0] EQ 0)
  IF (test[0]) THEN xx = TRANSPOSE(x) ELSE xx = REFORM(x)
ENDELSE
pp             = REFORM(param)
dp             = REFORM(dparm)
nx             = N_ELEMENTS(xx[*,0])
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check FUNC
test           = (N_ELEMENTS(func) EQ 0)
IF (test) THEN fitf = def_func[0] ELSE fitf = (FIX(func[0]) > func_mnmx[0]) < func_mnmx[1]
;;  Check XLOG
test           = (N_ELEMENTS(xlog) EQ 0) OR ~KEYWORD_SET(xlog)
IF (test) THEN x_lin = 1b ELSE x_lin = 0b
;;  Check YLOG
test           = (N_ELEMENTS(ylog) EQ 0) OR ~KEYWORD_SET(ylog)
IF (test) THEN y_lin = 1b ELSE y_lin = 0b
;;----------------------------------------------------------------------------------------
;;  Calculate variation of F(X)
;;----------------------------------------------------------------------------------------
IF (x_lin[0]) THEN BEGIN
  x_avg          = (xx[*,0] + xx[*,1])/2d0
ENDIF ELSE BEGIN
  lg10x          = ALOG10(xx)
  lg10_xavg      = (lg10x[*,0] + lg10x[*,1])/2d0
  x_avg          = 1d1^(lg10_xavg)
ENDELSE

ff             = DBLARR(nx[0],3L,3L,3L,3L,3L)     ;;  [N,X_VARY,A_VARY,B_VARY,C_VARY,D_VARY]
FOR n=0, nx[0] - 1L DO BEGIN
  x_n             = [xx[n,0],x_avg[n],xx[n,1]]
  term0           = lbw_perturb_model_func(x_n,pp,dp,FUNC=fitf[0])
  ff[n,*,*,*,*,*] = term0  ;;  [3,3,3,3,3]-Element array
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define averages and lower/upper bounds
;;----------------------------------------------------------------------------------------
x_lower        = xx[*,0]
x_upper        = xx[*,1]

n_f            = TOTAL(FINITE(ff),2,/NAN)
IF (y_lin[0]) THEN BEGIN
  f_sum          = TOTAL(ff,2,/NAN)
ENDIF ELSE BEGIN
  f_sum_l10      = ALOG10(TOTAL(ff,2,/NAN))
  f_sum          = 1d1^(f_sum_l10)
ENDELSE
f_avg          = f_sum/n_f                        ;;  [N,3,3,3,3]-Element array

f_min          = MIN(ff,/NAN,DIMENSION=2)         ;;  [N,3,3,3,3]-Element array
f_max          = MAX(ff,/NAN,DIMENSION=2)         ;;  [N,3,3,3,3]-Element array
;;----------------------------------------------------------------------------------------
;;  Define outputs
;;----------------------------------------------------------------------------------------
;;  Define outputs for X
x_out          = x_avg                            ;;  [N]-Element array
x2d            = x_out # REPLICATE(1,2L)
x_err          = ABS(x2d - [[x_lower],[x_upper]]) ;;  [N,2]-Element array
;;  Define outputs for F(X)
n_fo           = TOTAL(TOTAL(TOTAL(TOTAL(FINITE(f_avg),2,/NAN),2L,/NAN),2L,/NAN),2L,/NAN)
IF (y_lin[0]) THEN BEGIN
  term0          = TOTAL(TOTAL(TOTAL(TOTAL(f_avg,5L,/NAN),4L,/NAN),3L,/NAN),2L,/NAN)
ENDIF ELSE BEGIN
  termf          = ALOG10(TOTAL(TOTAL(TOTAL(TOTAL(f_avg,5L,/NAN),4L,/NAN),3L,/NAN),2L,/NAN))
  term0          = 1d1^(termf)
ENDELSE
f_out          = term0/n_fo                       ;;  [N]-Element array
f_lowupp       = DBLARR(nx[0],2L)                 ;;  [N,2]-Element array
FOR n=0, nx[0] - 1L DO BEGIN
  lowupp        = [MIN(f_min[n,*,*,*,*],/NAN),MAX(f_max[n,*,*,*,*],/NAN)]
  f_lowupp[n,*] = lowupp
ENDFOR
f2d            = f_out # REPLICATE(1,2L)
f_err          = ABS(f2d - f_lowupp)              ;;  [N,2]-Element array
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
xytags         = ['X','Y']
suff_tags      = '_'+['VAL','ERR']
tags           = [xytags[0]+suff_tags,xytags[1]+suff_tags]
struc          = CREATE_STRUCT(tags,x_out,x_err,f_out,f_err)
;;----------------------------------------------------------------------------------------
;;  Return keywords back to user
;;----------------------------------------------------------------------------------------
IF (x_lin[0]) THEN xlog = 0b ELSE xlog = 1b
IF (y_lin[0]) THEN ylog = 0b ELSE ylog = 1b
func           = fitf[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END
