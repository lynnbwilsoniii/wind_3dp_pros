;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_permute_ind_xxx.pro
;  PURPOSE  :   This routine takes two input arrays and performs a user defined operation
;                 on all permuted combinations of each.  The user can choose the
;                 following operators:
;                   SUB   :  OUTPUT[i,j] = X_i - Y_j
;                   ADD   :  OUTPUT[i,j] = X_i + Y_j
;                   MUL   :  OUTPUT[i,j] = X_i * Y_j
;                   DIV   :  OUTPUT[i,j] = X_i / Y_j
;                 The returned array will be an [N,M]-element [numeric] array, where
;                 N is the number of elements in X and M is the number in Y.
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
;               XX    :  [N]-Element [numeric] array of values for first dimension index
;                          of output
;               YY    :  [M]-Element [numeric] array of values for second dimension index
;                          of output
;
;  EXAMPLES:    
;               [calling sequence]
;               test = lbw_permute_ind_xxx(xx, yy [,/SUB] [,/ADD] [,/MUL] [,/DIV] [,/NAN])
;
;               ;;  Example
;               x    = DINDGEN(14983L)
;               y    = DINDGEN(13541L)
;               tstart             = SYSTIME(1)
;               test = lbw_permute_ind_xxx(x,y,/ADD)
;               PRINT,';;  Routine execution time [s]  :  '+STRING((SYSTIME(1) - tstart[0]))
;               ;;  Routine execution time [s]  :         3.1082199
;               HELP,test
;               TEST            DOUBLE    = Array[14983, 13541]
;               PRINT,';;  ',minmax(test,/POS)
;               ;;         1.0000000       28522.000
;               PRINT,';;  ',N_ELEMENTS(test)
;               ;;     202884803
;
;               ;;  Keyword Examples
;               x    = DINDGEN(175L)
;               y    = DINDGEN(236L)
;               tstart             = SYSTIME(1)
;               test               = lbw_permute_ind_xxx(x,y,/SUB,/MUL)
;               PRINT,';;  Routine execution time [s]  :  '+STRING((SYSTIME(1) - tstart[0]))
;               ;;  Routine execution time [s]  :      0.0012230873
;               PRINT,';;  ',MIN(test),MAX(test)
;               ;;        -235.00000       174.00000
;               
;               tstart             = SYSTIME(1)
;               test               = lbw_permute_ind_xxx(x,y,/DIV,/MUL)
;               PRINT,';;  Routine execution time [s]  :  '+STRING((SYSTIME(1) - tstart[0]))
;               ;;  Routine execution time [s]  :      0.0011959076
;               PRINT,';;  ',MIN(test),MAX(test)
;               ;;         1.0000000       40890.000
;               
;               tstart             = SYSTIME(1)
;               test               = lbw_permute_ind_xxx(x,y,/DIV,/ADD,/MUL)
;               PRINT,';;  Routine execution time [s]  :  '+STRING((SYSTIME(1) - tstart[0]))
;               ;;  Routine execution time [s]  :      0.0012879372
;               PRINT,';;  ',MIN(test),MAX(test)
;               ;;         1.0000000       409.00000
;               
;               bi                 = [0L,25L,37L,42L,97L,105L]
;               x                  = DINDGEN(175L)
;               y                  = DINDGEN(236L)
;               x[bi]              = !VALUES.D_NAN
;               tstart             = SYSTIME(1)
;               test               = lbw_permute_ind_xxx(x,y,/NAN)
;               PRINT,';;  Routine execution time [s]  :  '+STRING((SYSTIME(1) - tstart[0]))
;               ;;  Routine execution time [s]  :      0.0014808178
;               PRINT,';;  ',MIN(test),MAX(test)
;               ;;        -235.00000       174.00000
;               
;               tstart             = SYSTIME(1)
;               test               = lbw_permute_ind_xxx(x,y,/NAN,/MUL)
;               PRINT,';;  Routine execution time [s]  :  '+STRING((SYSTIME(1) - tstart[0]))
;               ;;  Routine execution time [s]  :      0.0013949871
;               PRINT,';;  ',MIN(test),MAX(test)
;               ;;         0.0000000       40890.000
;               
;               tstart             = SYSTIME(1)
;               test               = lbw_permute_ind_xxx(x,y,/MUL)
;               PRINT,';;  Routine execution time [s]  :  '+STRING((SYSTIME(1) - tstart[0]))
;               ;;  Routine execution time [s]  :      0.0012171268
;               PRINT,';;  ',MIN(test),MAX(test)
;               ;;         0.0000000       40890.000
;
;  KEYWORDS:    
;               SUB   :  If set, routine will calculate the difference between XX and YY
;                          [Default = TRUE]
;               ADD   :  If set, routine will calculate the sum of XX and YY
;                          [Default = FALSE]
;               MUL   :  If set, routine will calculate the product of XX and YY
;                          [Default = FALSE]
;               DIV   :  If set, routine will calculate the ratio of XX to YY
;                          [Default = FALSE]
;               NAN   :  If set, operations apply the standard rules about NaNs
;                          [Default = FALSE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               0)  Try not to kill your computer by providing arrays that ar too large
;                     --> Try to satisfy:  N*M ≤ 400,000,000
;               1)  XXX operator priority order (in case multiple are set)
;                     1  :  SUB
;                     2  :  ADD
;                     3  :  MUL
;                     4  :  DIV
;
;  REFERENCES:  
;               NA
;
;   CREATED:  10/30/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/30/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_permute_ind_xxx,xx,yy,SUB=sub,ADD=add,MUL=mul,DIV=div,NAN=nan

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define defaults
def_sub_on     = 1b
def_add_on     = 0b
def_mul_on     = 0b
def_div_on     = 0b
def_nan_on     = 0b
;;  Dummy error messages
noinpt_msg     = 'Incorrect number of inputs supplied...'
notnum_msg     = 'Both XX and YY inputs must be of numeric type...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN BEGIN
  ;;  no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = ((is_a_number(xx[0],/NOMSSG) EQ 0) OR (N_ELEMENTS(xx) LT 1)) OR $
                 ((is_a_number(yy[0],/NOMSSG) EQ 0) OR (N_ELEMENTS(yy) LT 1))
IF (test[0]) THEN BEGIN
  MESSAGE,notnum_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define params
nx             = N_ELEMENTS(xx)
ny             = N_ELEMENTS(yy)
xin            = 1d0*REFORM(xx,nx[0])
yin            = 1d0*REFORM(yy,ny[0])
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check SUB
IF ~KEYWORD_SET(sub) THEN sub_on = 0b ELSE sub_on = def_sub_on[0]
;;  Check ADD
IF  KEYWORD_SET(add) THEN add_on = 1b ELSE add_on = def_add_on[0]
;;  Check MUL
IF  KEYWORD_SET(mul) THEN mul_on = 1b ELSE mul_on = def_mul_on[0]
;;  Check DIV
IF  KEYWORD_SET(div) THEN div_on = 1b ELSE div_on = def_div_on[0]
;;  Check NAN
IF  KEYWORD_SET(nan) THEN nan_on = 1b ELSE nan_on = def_nan_on[0]
;;  Make sure only one of the XXX operators is on
check_on       = [sub_on[0],add_on[0],mul_on[0],div_on[0]]
goodx_on       = WHERE(check_on,gdx_on,COMPLEMENT=badx_on,NCOMPLEMENT=bdx_on)
check_on[*]    = 0b
CASE gdx_on[0] OF
  1     :  BEGIN
    check_on[goodx_on[0]] = 1b
  END
  2     :  BEGIN
    ;;  2 are set --> check priority
    check_on[goodx_on[0]] = 1b
  END
  3     :  BEGIN
    ;;  2 are set --> check priority
    check_on[goodx_on[0]] = 1b
  END
  ELSE  :  BEGIN
    ;;  Either none are on or all are on --> Use default [SUB]
    check_on              = [def_sub_on[0],def_add_on[0],def_mul_on[0],def_div_on[0]]
  END
ENDCASE
;;  Redefine logic variables
sub_on         = check_on[0]
add_on         = check_on[1]
mul_on         = check_on[2]
div_on         = check_on[3]
;;----------------------------------------------------------------------------------------
;;  Permute the operation
;;----------------------------------------------------------------------------------------
;;  First determine which input, X or Y, is smaller
nn             = (nx[0] < ny[0])
isx            = (nn[0] EQ nx[0])
CASE 1 OF
  sub_on[0]  :  BEGIN
    yin           *= -1d0
  END
  div_on[0]  :  BEGIN
    yin            = 1d0/TEMPORARY(yin)
  END
  ELSE       :  ;;  Do nothing
ENDCASE
plus_on        = (sub_on[0] OR add_on[0])
nn             = N_ELEMENTS(xin)
;;  Define dummy output array
output         = REPLICATE(d,nx[0],ny[0])
IF (isx[0]) THEN BEGIN
  ;;  Loop over X
  FOR i=0L, nx[0] - 1L DO BEGIN
    IF (plus_on[0]) THEN output[i,*] = xin[i[0]] + yin ELSE output[i,*] = xin[i[0]] * yin
  ENDFOR
ENDIF ELSE BEGIN
  ;;  Loop over Y
  FOR j=0L, ny[0] - 1L DO BEGIN
    IF (plus_on[0]) THEN output[*,j] = xin + yin[j[0]] ELSE output[*,j] = xin * yin[j[0]]
  ENDFOR
ENDELSE
;;  Replace NaNs if necessary
IF (nan_on[0]) THEN BEGIN
  badx           = WHERE(FINITE(xin) EQ 0,bdx)
  bady           = WHERE(FINITE(yin) EQ 0,bdy)
  IF (bdx[0] GT 0) THEN IF (plus_on[0]) THEN output[badx,*] = (REPLICATE(1d0,bdx[0]) # yin) ELSE output[badx,*] = d
  IF (bdy[0] GT 0) THEN IF (plus_on[0]) THEN output[*,bady] = (xin # REPLICATE(1d0,bdy[0])) ELSE output[*,bady] = d
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END

;  add_on[0]  :  BEGIN
;    func           = 'TOTAL'
;  END
;  mul_on[0]  :  BEGIN
;    func           = 'PRODUCT'
;  END
;    func           = 'TOTAL'
;    func           = 'PRODUCT'

;IF (nx[0] NE ny[0]) THEN BEGIN
;  IF (isx[0]) THEN BEGIN
;    ;;  Add NaNs or Zeros to X to make it the same size as Y
;;    dn             = ny[0] - nx[0]
;    xin            = x
;;    xin            = [x,REPLICATE(null[0],dn[0])]
;    yin            = y
;  ENDIF ELSE BEGIN
;    ;;  Add NaNs or Zeros to Y to make it the same size as X
;;    dn             = nx[0] - ny[0]
;    xin            = x
;    yin            = y
;;    yin            = [y,REPLICATE(null[0],dn[0])]
;  ENDELSE
;ENDIF ELSE BEGIN
;  ;;  Already the same size
;  xin            = x
;  yin            = y
;ENDELSE
;;;  Clean up before moving on
;dumb           = TEMPORARY(x)
;dumb           = TEMPORARY(y)
;output         = REPLICATE(d,nn[0],nn[0])
;;;  Loop over X
;FOR i=0L, nn[0] - 1L DO BEGIN
;  ;;  Define dummy input array
;  in_put         = [[REPLICATE(xin[i[0]],nn[0])],[yin]]
;  output[i,*]    = CALL_FUNCTION(func[0],in_put,2L,NAN=nan_on[0],/DOUBLE)
;ENDFOR
;STOP
;;;----------------------------------------------------------------------------------------
;;;  Define return value
;;;----------------------------------------------------------------------------------------
;out0           = REFORM(output[0L:(nx[0] - 1L),*])
;output         = REFORM(out0[*,0L:(ny[0] - 1L)])

;;    array          = [[x],[-1d0*y]]

