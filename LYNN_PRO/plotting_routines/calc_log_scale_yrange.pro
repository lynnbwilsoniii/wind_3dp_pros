;+
;*****************************************************************************************
;
;  FUNCTION :   calc_log_scale_yrange.pro
;  PURPOSE  :   This routine tries to improve upon IDL's attempt to automatically choose
;                 appropriate Y-Axis range when plotting data on a logarithmic scale.
;                 This is particularly useful when the data does not span more than one
;                 power of ten causing IDL to output a plot with minor tick marks, but
;                 no major tick marks or corresponding labels.
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
;               DATA  :  [N]-Element [integer/long/float/double] array of values for
;                          which the user wishes to determine appropriate tick mark
;                          values to show on a logarithmic scale
;
;  EXAMPLES:    
;               ;;------------------------------------------------------
;               ;;  Try numerous examples and then print the results
;               ;;------------------------------------------------------
;               ;;  Define dummy data arrays
;               n              = 20L
;               xra            = [0.35d0,0.85d0]      ;;  Test Case A
;               x_a            = DINDGEN(n)*(xra[1] - xra[0])/(n - 1) + xra[0]
;               xra            = [0.35d0,1.20d0]      ;;  Test Case B i)
;               x_b10          = DINDGEN(n)*(xra[1] - xra[0])/(n - 1) + xra[0]
;               xra            = [0.75d0,1.20d0]      ;;  Test Case B i)
;               x_b11          = DINDGEN(n)*(xra[1] - xra[0])/(n - 1) + xra[0]
;               xra            = [0.85d0,1.10d0]      ;;  Test Case B i)
;               x_b12          = DINDGEN(n)*(xra[1] - xra[0])/(n - 1) + xra[0]
;               xra            = [0.95d0,1.85d0]      ;;  Test Case B ii)
;               x_b20          = DINDGEN(n)*(xra[1] - xra[0])/(n - 1) + xra[0]
;               xra            = [0.25d0,1.85d0]      ;;  Test Case B ii)
;               x_b21          = DINDGEN(n)*(xra[1] - xra[0])/(n - 1) + xra[0]
;               xra            = [0.15d0,1.95d0]      ;;  Test Case B ii)
;               x_b22          = DINDGEN(n)*(xra[1] - xra[0])/(n - 1) + xra[0]
;               xra            = [0.35d0,0.35d0]      ;;  Test Case C
;               x_c            = DINDGEN(n)*(xra[1] - xra[0])/(n - 1) + xra[0]
;               xra            = [0.05d0,1.20d0]      ;;  Test Case D
;               x_d            = DINDGEN(n)*(xra[1] - xra[0])/(n - 1) + xra[0]
;               ;;  Estimate new Y-Ranges
;               xran_a         = calc_log_scale_yrange(x_a)
;               xran_b10       = calc_log_scale_yrange(x_b10)
;               xran_b11       = calc_log_scale_yrange(x_b11)
;               xran_b12       = calc_log_scale_yrange(x_b12)
;               xran_b20       = calc_log_scale_yrange(x_b20)
;               xran_b21       = calc_log_scale_yrange(x_b21)
;               xran_b22       = calc_log_scale_yrange(x_b22)
;               xran_c         = calc_log_scale_yrange(x_c)
;               xran_d         = calc_log_scale_yrange(x_d)
;               ;;  Print results
;               FOR j=0L, 8L DO BEGIN                      $
;                 IF (j EQ 0) THEN PRINT,';; ',xran_a    & $
;                 IF (j EQ 1) THEN PRINT,';; ',xran_b10  & $
;                 IF (j EQ 2) THEN PRINT,';; ',xran_b11  & $
;                 IF (j EQ 3) THEN PRINT,';; ',xran_b12  & $
;                 IF (j EQ 4) THEN PRINT,';; ',xran_b20  & $
;                 IF (j EQ 5) THEN PRINT,';; ',xran_b21  & $
;                 IF (j EQ 6) THEN PRINT,';; ',xran_b22  & $
;                 IF (j EQ 7) THEN PRINT,';; ',xran_c    & $
;                 IF (j EQ 8) THEN PRINT,';; ',xran_d
;                 ;;       0.10000000       1.0000000
;                 ;;       0.10000000       1.5000000
;                 ;;       0.50000000       1.5000000
;                 ;;       0.50000000       1.5000000
;                 ;;       0.50000000       2.0000000
;                 ;;       0.10000000       2.0350000
;                 ;;       0.10000000       2.1450000
;                 ;;       0.10000000       1.0000000
;                 ;;      0.045000000       1.3200000
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Finished writing and renamed from calc_log_scale_tickv.pro to
;                   calc_log_scale_yrange.pro
;                                                                   [11/13/2013   v1.0.0]
;             2)  Fixed typo in Man. page
;                                                                   [11/14/2013   v1.0.1]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   CREATED:  11/13/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/14/2013   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION calc_log_scale_yrange,data

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
bad_numin_msg  = 'DAT must be an [N]-element (integer/long/float/double) array...'
bad_ndims_msg  = 'DAT must be a one-dimensional array...'
bad_a_neg_msg  = 'DAT must contain more than 3 elments that are > 0...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 1) OR (N_ELEMENTS(data) EQ 0)
IF (test) THEN BEGIN
  ;;  Must be 1 input supplied
  MESSAGE,bad_numin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF

test           = (SIZE(REFORM(data),/N_DIMENSIONS) NE 1)
IF (test) THEN BEGIN
  ;;  Input must be 1-D
  MESSAGE,bad_ndims_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Eliminate negative values which cannot be shown on logarithmic plots
;;----------------------------------------------------------------------------------------
dat            = REFORM(data)                     ;;  Change [1,N]- to a [N]-element array
nn             = N_ELEMENTS(dat)
bad            = WHERE(dat LE 0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
test           = (gd LE 3)
IF (test) THEN BEGIN
  ;;  Input must be > 0
  MESSAGE,bad_a_neg_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;  Ignore negative values
dat            = dat[good]
;;----------------------------------------------------------------------------------------
;;  Determine data range and relevant parameters
;;----------------------------------------------------------------------------------------
dat_min        = MIN(dat,MAX=dat_max,/NAN)
dat_aran       = ABS(dat_max[0] - dat_min[0])     ;;  Abs. range of data
dat_10per      = 1d-1*dat_aran[0]                 ;;  10% of Abs. range
min_10per      = 1d-1*dat_min[0]                  ;;  10% of Min.
max_10per      = 1d-1*dat_max[0]                  ;;  10% of Max.
min_20per      = 2d-1*dat_min[0]                  ;;  20% of Min.
max_20per      = 2d-1*dat_max[0]                  ;;  20% of Max.
;;  Expand range by ±10% and ±20%
mnmx_10        = [dat_min[0],dat_max[0]] + [-1d0,1d0]*[min_10per[0],max_10per[0]]
mnmx_20        = [dat_min[0],dat_max[0]] + [-1d0,1d0]*[min_20per[0],max_20per[0]]
l_ex_mnmx      = ALOG10([MIN(mnmx_10,/NAN),MAX(mnmx_10,/NAN)])
l_20_mnmx      = ALOG10([MIN(mnmx_20,/NAN),MAX(mnmx_20,/NAN)])
;;  Convert to base-10 log-scale and define as L_j
l_mnmx         = ALOG10([dat_min[0],dat_max[0]])
fl_l_mnmx      = FLOOR(l_mnmx)
ce_l_mnmx      = CEIL(l_mnmx)
;;  Find the adjacent power of 10 and define as £_j
l_mnmx_adj     = [FLOOR(MIN(l_mnmx,/NAN)),CEIL(MAX(l_mnmx,/NAN))]
;;----------------------------------------------------------------------------------------
;;  Determine whether or not to expand range
;;----------------------------------------------------------------------------------------
test_a         = (fl_l_mnmx[0] EQ fl_l_mnmx[1]) OR (ce_l_mnmx[0] EQ ce_l_mnmx[1])
test_b         = (ce_l_mnmx[0] EQ fl_l_mnmx[1])
test_c         = (dat_min[0] EQ dat_max[0])
check          = WHERE([test_a[0],test_b[0],test_c[0]],ch)
CASE check[0] OF
  0L   : BEGIN                                          ;;  Case A
    ;;------------------------------------------------------------------------------------
    ;;  £_(j-1)     £_j     £_(j+1)
    ;;  ---|---------|---------|---
    ;;                  y0  y1
    ;;------------------------------------------------------------------------------------
    logy0  = fl_l_mnmx[0] < l_ex_mnmx[0]                ;;  ∆Y_0 = £_j
    logy1  = ce_l_mnmx[1] > l_ex_mnmx[1]                ;;  ∆Y_1 = £_(j+1)
  END
  1L   : BEGIN                                          ;;  Case B
    L_j            = ce_l_mnmx[0]                       ;;  = 100% of £_j
    Lj__50         = ALOG10(5d-1*1d1^L_j[0])            ;;  =  50% of £_j
    Lj_150         = ALOG10(15d-1*1d1^L_j[0])           ;;  = 150% of £_j
    Lj_200         = ALOG10(20d-1*1d1^L_j[0])           ;;  = 200% of £_j
    L_jm1          = L_j[0] - 1d0                       ;;  = £_(j-1)
    L_jp1          = L_j[0] + 1d0                       ;;  = £_(j+1)
    diff01         = ABS([(ce_l_mnmx[0] - l_mnmx[0]),(ce_l_mnmx[0] - l_mnmx[1])])
    test_up        = (diff01[0] GE diff01[1])
    test0          = (l_mnmx[0] GE Lj__50[0])           ;;  TRUE  :  ∆Y_0 ≥  50% of £_j
    test1          = (l_mnmx[1] LT Lj_150[0])           ;;  TRUE  :  ∆Y_1 < 150% of £_j
    test2          = (l_mnmx[1] LT Lj_200[0])           ;;  TRUE  :  ∆Y_1 < 200% of £_j
    test200        = (test2[0] AND (test1[0] EQ 0))     ;;  TRUE  :  150% < ∆Y_1 < 200% of £_j
    test50         = (test0[0] OR test1[0])
    IF (test_up) THEN BEGIN                             ;;  Case B i)
      ;;----------------------------------------------------------------------------------
      ;;  £_(j-1)     £_j     £_(j+1)
      ;;  ---|---------|---------|---
      ;;       y0        y1
      ;;----------------------------------------------------------------------------------
      IF (test50) THEN BEGIN
        ;;  At least one bound within 50% of £_j
        test   = (test0[0] AND test1[0])
        IF (test) THEN BEGIN
          ;;  Both values are within 50% of £_j
          ;;    => use (Y_j ± 50%) instead
          logy0  = Lj__50[0]
          logy1  = Lj_150[0]
        ENDIF ELSE BEGIN
          ;;    => ∆Y_j = Y_j ± 50%
          low_00 = ([Lj__50[0],fl_l_mnmx[0]]) < l_ex_mnmx[0]
          upp_00 = [l_ex_mnmx[1] < ce_l_mnmx[1], Lj_150[0] > l_ex_mnmx[1]]
          IF (test0) THEN BEGIN
            logy0 = low_00[0]
            logy1 = upp_00[0]
          ENDIF ELSE BEGIN
            logy0 = low_00[1]
            logy1 = upp_00[1]
          ENDELSE
        ENDELSE
      ENDIF ELSE BEGIN
        ;;  Neither bound within 50% of £_j
        logy0  = fl_l_mnmx[0] < l_ex_mnmx[0]            ;;  ∆Y_0 = £_(j-1) < (Y_0 - 10%)
        logy1  = l_ex_mnmx[1] < ce_l_mnmx[1]            ;;  ∆Y_1 = (Y_1 + 10%) < £_j
      ENDELSE
    ENDIF ELSE BEGIN                                    ;;  Case B ii)
      ;;----------------------------------------------------------------------------------
      ;;  £_(j-1)     £_j     £_(j+1)
      ;;  ---|---------|---------|---
      ;;            y0        y1
      ;;----------------------------------------------------------------------------------
      IF (test50) THEN BEGIN
        ;;  At least one bound within 50% of £_j
        test   = (test0[0] AND test1[0])
        IF (test) THEN BEGIN
          ;;  Both values are within 50% of £_j
          ;;    => use (Y_j ± 50%) instead
          logy0  = Lj__50[0]
          logy1  = Lj_150[0]
        ENDIF ELSE BEGIN
          ;;    => ∆Y_j = Y_j ± 50%
          low_00 = ([Lj__50[0],fl_l_mnmx[0]]) < l_ex_mnmx[0]
          upp_00 = ([ce_l_mnmx[1],Lj_150[0]]) > l_ex_mnmx[1]
          IF (test0) THEN BEGIN
            ;;  ∆Y_0 ≥  50% of £_j
            logy0 = low_00[0]
            IF (test200) THEN logy1 = Lj_200[0] ELSE logy1 = upp_00[0]
          ENDIF ELSE BEGIN
            ;;  ∆Y_1 < 150% of £_j
            logy0 = low_00[1]
            logy1 = upp_00[1]
          ENDELSE
        ENDELSE
      ENDIF ELSE BEGIN
        ;;  Neither bound within 50% of £_j
        logy0  = l_ex_mnmx[0] > fl_l_mnmx[0]            ;;  ∆Y_0 = (Y_0 - 10%) > £_(j-1)
        ;;  ∆Y_1 = [£_(j+1) > (Y_1 + 10%)] OR [200% of £_j]
        IF (test200) THEN logy1 = Lj_200[0] ELSE logy1  = ce_l_mnmx[1] > l_ex_mnmx[1]
      ENDELSE
    ENDELSE
  END
  2L   : BEGIN                                          ;;  Case C
    ;;------------------------------------------------------------------------------------
    ;;  £_(j-1)     £_j     £_(j+1)
    ;;  ---|---------|---------|---
    ;;                   y0
    ;;                   y1
    ;;------------------------------------------------------------------------------------
    logy0  = fl_l_mnmx[0] < l_ex_mnmx[0]                ;;  ∆Y_0 = £_j
    logy1  = ce_l_mnmx[1] > l_ex_mnmx[1]                ;;  ∆Y_1 = £_(j+1)
  END
  ELSE : BEGIN                                          ;;  Case D
    ;;  Do not need to expand more than 10%
    logy0  = l_ex_mnmx[0]                               ;;  ∆Y_0 = (Y_0 - 10%)
    logy1  = l_ex_mnmx[1]                               ;;  ∆Y_1 = (Y_1 + 10%)
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Define logarithmic Y-Range
;;----------------------------------------------------------------------------------------
log_ran        = [logy0[0],logy1[0]]
;;  Define data range
dat_ran        = 1d1^(log_ran)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,dat_ran
END



