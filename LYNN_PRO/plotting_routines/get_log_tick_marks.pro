;+
;*****************************************************************************************
;
;  FUNCTION :   get_log_tick_marks.pro
;  PURPOSE  :   This routine returns the tick mark structure tags and values for
;                 plotting data on a logarithmic scale to correct for some of the
;                 issues that arise from IDL's automated tick mark generation.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               num2int_str.pro
;               is_a_number.pro
;               test_plot_axis_range.pro
;               fill_range.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               limits = get_log_tick_marks([,DATA=data] [,RANGE=range]            $
;                                       [,MIN_VAL=min_val] [,MAX_VAL=max_val]      )
;
;               ;;*************************************************
;               ;;  Example usage
;               ;;*************************************************
;               range          = [8.6743d0,14.19826d0]
;               test           = get_log_tick_marks(RANGE=range)
;               PRINT,';;  ', test.RANGE     & $
;               PRINT,';;  ', test.TICKV     & $
;               PRINT,';;  ', test.TICKNAME  & $
;               PRINT,';;  ', test.TICKS     & $
;               PRINT,';;  ', test.MINOR
;               ;;         8.0000000       20.000000
;               ;;         8.0000000       10.000000       20.000000
;               ;;   8 10 20
;               ;;             2
;               ;;            10
;               
;               range          = [0.6743d0,90.19826d0]
;               test           = get_log_tick_marks(RANGE=range)
;               PRINT,';;  ', test.RANGE     & $
;               PRINT,';;  ', test.TICKV     & $
;               PRINT,';;  ', test.TICKNAME  & $
;               PRINT,';;  ', test.TICKS     & $
;               PRINT,';;  ', test.MINOR
;               ;;        0.60000000       90.198260
;               ;;        0.60000000       2.0000000       7.0000000       30.000000       90.000000
;               ;;   0.6 2 7 30 90
;               ;;             4
;               ;;            10
;               
;               range          = [6.743d-4,5.314d3]
;               test           = get_log_tick_marks(RANGE=range)
;               PRINT,';;  ', test.RANGE     & $
;               PRINT,';;  ', test.TICKV     & $
;               PRINT,';;  ', test.TICKNAME  & $
;               PRINT,';;  ', test.TICKS     & $
;               PRINT,';;  ', test.MINOR
;               ;;     0.00010000000       10000.000
;               ;;     0.00010000000    0.0010000000     0.010000000      0.10000000       1.0000000       10.000000       100.00000       1000.0000       10000.000
;               ;;   10!U-4!N 10!U-3!N 10!U-2!N 10!U-1!N 10!U0!N 10!U1!N 10!U2!N 10!U3!N 10!U4!N
;               ;;             8
;               ;;             9
;
;  KEYWORDS:    
;               DATA      :  [N]-Element [numeric] array of values for which the user
;                              wishes to determine appropriate tick mark values to show
;                              on a logarithmic scale
;                              [Default = FALSE]
;               RANGE     :  [2]-Element [numeric] array defining the range of values to
;                              use when defining the appropriate tick marks
;                              [Default = calc_log_scale_yrange(data)]
;               MIN_VAL   :  Scalar [numeric] defining the minimum value to consider
;                              before determining the data range.  If set, then all
;                              values < MIN_VAL will be ignored.  This keyword is
;                              overridden if RANGE keyword is set properly.
;                              [Default = MIN(DATA,/NAN) OR 0]
;               MAX_VAL   :  Scalar [numeric] defining the maximum value to consider
;                              before determining the data range.  If set, then all
;                              values > MAX_VAL will be ignored.  This keyword is
;                              overridden if RANGE keyword is set properly.
;                              [Default = MAX(DATA,/NAN) OR 10^300]
;               FORCE_RA  :  If set, then the bounds set by RANGE, MIN_VAL, or MAX_VAL
;                              are considered absolute and tick marks will not be defined
;                              outside of any of these boundaries
;                              [Default = FALSE]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [08/10/2018   v1.0.0]
;             2)  Continued to write routine
;                                                                   [08/10/2018   v1.0.0]
;             3)  Continued to write routine
;                                                                   [08/10/2018   v1.0.0]
;
;   NOTES:      
;               ***  Still testing  ***
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/09/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_log_tick_marks,DATA=data,RANGE=range,MIN_VAL=min_val,MAX_VAL=max_val

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
tickv_fac      = [1,2,3,4,5,6,7,8,9]
ticks_fac      = num2int_str(tickv_fac)
;;  Error messages
noinput_mssg   = 'No input was supplied...'
bad_ran_mssg   = 'Bad keyword setting(s) leading to invalid plot RANGE...'
;;----------------------------------------------------------------------------------------
;;  Check for input
;;----------------------------------------------------------------------------------------
testd          = is_a_number(data,/NOMSSG)
testr          = test_plot_axis_range(range,/NOMSSG)
testn          = is_a_number(min_val,/NOMSSG)
testx          = is_a_number(max_val,/NOMSSG)
test           = ~testd[0] AND ~testr[0] AND (~testn[0] OR ~testx[0])
IF (test[0]) THEN BEGIN
  ;;  no input???
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check MIN_VAL
IF (testn[0]) THEN mnv = min_val[0] > 0d0 ELSE mnv = 0d0
;;  Check MAX_VAL
IF (testx[0]) THEN mxv = max_val[0] < 1d300 ELSE mxv = 1d300
;;  Check for range settings
IF (testd[0] OR testr[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  DATA or RANGE is set --> test
  ;;--------------------------------------------------------------------------------------
  IF (testd[0] AND testr[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Both are set
    ;;------------------------------------------------------------------------------------
    ran        = REFORM(range[SORT(range)])
    mnv        = ran[0]
    mxv        = ran[1]
    xx         = REFORM(data,N_ELEMENTS(data))      ;;  force to a 1D array
    good       = WHERE(xx GT 0,gd)
    IF (gd[0] GT 0) THEN BEGIN
      dat_ran    = [MIN(xx[good],/NAN),MAX(xx[good],/NAN)]
    ENDIF ELSE BEGIN
      ;;  DATA is set but negative values are not allowed --> use only RANGE
      dat_ran    = ran
    ENDELSE
    ;;  Limit to within RANGE
    dat_ran[0] = dat_ran[0] > ran[0]
    dat_ran[1] = dat_ran[1] < ran[1]
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Only one is set
    ;;------------------------------------------------------------------------------------
    IF (testd[0]) THEN BEGIN
      ;;  DATA is set --> test
      ran        = [mnv[0],mxv[0]]
      xx         = REFORM(data,N_ELEMENTS(data))      ;;  force to a 1D array
      good       = WHERE(xx GT 0,gd)
      IF (gd[0] GT 0) THEN BEGIN
        dat_ran    = [MIN(xx[good],/NAN),MAX(xx[good],/NAN)]
      ENDIF ELSE BEGIN
        dat_ran    = ran
      ENDELSE
      ;;  Limit to within RANGE
      dat_ran[0] = dat_ran[0] > ran[0]
      dat_ran[1] = dat_ran[1] < ran[1]
    ENDIF ELSE BEGIN
      ;;  RANGE is set --> test
      ran        = REFORM(range[SORT(range)])
      mnv        = ran[0]
      mxv        = ran[1]
      dat_ran    = ran
    ENDELSE
  ENDELSE
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  MIN_VAL and MAX_VAL are set --> test
  ;;--------------------------------------------------------------------------------------
  ran        = [mnv[0],mxv[0]]
  dat_ran    = ran
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Make sure range is still okay
;;----------------------------------------------------------------------------------------
testr      = test_plot_axis_range(dat_ran,/NOMSSG)
IF (~testr[0]) THEN BEGIN
  ;;  Bad DATA, RANGE, or M[IN,AX]_VAL setting
  MESSAGE,bad_ran_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Create dummy array for later
;;----------------------------------------------------------------------------------------
l10_ran        = ALOG10(dat_ran)
l10_rex        = [FLOOR(l10_ran),CEIL(l10_ran)]
exp_ran        = [MIN(l10_rex,/NAN) - 1,MAX(l10_rex,/NAN) + 1]
int_exp        = fill_range(exp_ran[0],exp_ran[1],DIND=1)
str_exp        = num2int_str(int_exp)
FOR j=0L, N_ELEMENTS(int_exp) - 1L DO BEGIN
  CASE int_exp[j] OF
    -1   : BEGIN
      str_pref = '0.'
      str_suff = ''
    END
     0   : BEGIN
      str_pref = ''
      str_suff = ''
    END
     1   : BEGIN
      str_pref = ''
      str_suff = '0'
    END
    ELSE : BEGIN
      str_pref = ''
      str_suff = ' x 10!U'+str_exp[j]+'!N'
    END
  ENDCASE
  IF (j EQ 0) THEN BEGIN
    dumb_tickv     = tickv_fac*1d1^int_exp[j]
    dumb_ticks     = str_pref[0]+ticks_fac+str_suff[0]
  ENDIF ELSE BEGIN
    dumb_tickv     = [dumb_tickv,tickv_fac*1d1^int_exp[j]]
    dumb_ticks     = [dumb_ticks,str_pref[0]+ticks_fac+str_suff[0]]
  ENDELSE
ENDFOR
n_dumb         = N_ELEMENTS(dumb_tickv)
id             = LINDGEN(n_dumb[0])
good_dumb      = WHERE(dumb_tickv GE dat_ran[0] AND dumb_tickv LE dat_ran[1],gd_dumb)
;;  Determine which bound is closer to an integer power of 10
temp           = dumb_tickv[good_dumb]
l10t           = ALOG10(temp)
lower          = FLOOR(MIN(l10t,/NAN))       ;;  Lower integer exponent
upper          = CEIL(MAX(l10t,/NAN))        ;;  Upper integer exponent
ld_10          = VALUE_LOCATE(dumb_tickv,1d1^(lower[0]))
ud_10          = VALUE_LOCATE(dumb_tickv,1d1^(upper[0]))
lu_dd          = VALUE_LOCATE(dumb_tickv,dat_ran)
diff           = ABS(lu_dd - [ld_10[0],ud_10[0]])
;diff           = [ABS(MIN(l10t,/NAN) - lower[0]),ABS(MAX(l10t,/NAN) - upper[0])]
;diff           = [ABS(MIN(1d1^l10t,/NAN) - 1d1^lower[0]),ABS(MAX(1d1^l10t,/NAN) - 1d1^upper[0])]
mndiff         = MIN(diff,/NAN,lndf)
IF (lndf[0] EQ 0) THEN BEGIN
  ;;  Closer to lower bound --> expand to lower integer power of 10
  ld             = VALUE_LOCATE(dumb_tickv,1d1^(lower[0]))
;  ud             = MAX(good_dumb)
  ud             = MAX([MAX(good_dumb),lu_dd[1]])
  IF (dumb_tickv[ld[0]] GE dat_ran[0]) THEN ld = (ld[0] - 1L) > 0L
ENDIF ELSE BEGIN
  ;;  Closer to upper bound --> expand to upper integer power of 10
  ud             = VALUE_LOCATE(dumb_tickv,1d1^(upper[0]))
  ld             = MIN([MIN(good_dumb),lu_dd[0]])
;  ld             = MIN(good_dumb)
  IF (dumb_tickv[ud[0]] LE dat_ran[1]) THEN ud = (ud[0] + 1L) < (n_dumb[0] - 1L)
ENDELSE
tickv_all      = dumb_tickv[ld[0]:ud[0]]
ticks_all      = dumb_ticks[ld[0]:ud[0]]
;;  Define new, slightly expanded range
new_ran        = [MIN(tickv_all),MAX(tickv_all)]
new_ran[0]     = new_ran[0] < dat_ran[0]
new_ran[1]     = new_ran[1] > dat_ran[1]
;;----------------------------------------------------------------------------------------
;;  Check if range falls between 1 and 100
;;----------------------------------------------------------------------------------------
check          = (dat_ran[0] GT 1e-1) AND (dat_ran[1] LT 1e2)
IF (check[0]) THEN BEGIN
  CASE 1 OF
    (dat_ran[1] LE 2e1) : BEGIN
      ;;  Data range is tiny --> decrease ticks
      ntmin          = 2L                    ;;  Default minimum number of major tick marks
      ntmax          = 3L                    ;;  Default maximum number of major tick marks
      minor          = 10L                   ;;  # of minor tick marks
    END
    (dat_ran[0] GT 2e1) : BEGIN
      ntmin          = 2L                    ;;  Default minimum number of major tick marks
      ntmax          = 3L                    ;;  Default maximum number of major tick marks
      minor          = 10L                   ;;  # of minor tick marks
    END
    ELSE                : BEGIN
      ntmin          = 3L                    ;;  Default minimum number of major tick marks
      ntmax          = 5L                    ;;  Default maximum number of major tick marks
      minor          = 10L                   ;;  # of minor tick marks
    END
  ENDCASE
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Define tick marks
  ;;--------------------------------------------------------------------------------------
  dumb           = TEMPORARY(tickv_all)
  dumb           = TEMPORARY(ticks_all)
  ;;  Define associated tick mark values
  l10_exp        = [FLOOR(MIN(l10_ran,/NAN)),CEIL(MAX(l10_ran,/NAN))]
  int_exp        = fill_range(l10_exp[0],l10_exp[1],DIND=1)
  temp_arr       = 1d1^(int_exp)
  new_ran        = [MIN(temp_arr,/NAN),MAX(temp_arr,/NAN)]
  str_exp        = num2int_str(int_exp)
  test_2orders   = (MAX(ALOG10(new_ran)) - MIN(ALOG10(new_ran))) GE 3
  IF (test_2orders[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  RANGE spans at least 3 orders of magnitude --> limit tick marks to powers of 10
    ;;------------------------------------------------------------------------------------
    ntmax          = 15L                   ;;  Default maximum number of major tick marks
    ntmin          = 1L                    ;;  Default minimum number of major tick marks
    minor          = 9L                    ;;  # of minor tick marks
    FOR j=0L, N_ELEMENTS(int_exp) - 1L DO BEGIN
      IF (j EQ 0) THEN BEGIN
        tickv_all = 1d1^int_exp[j]
        ticks_all = '10!U'+str_exp[j]+'!N'
      ENDIF ELSE BEGIN
        tickv_all = [tickv_all,1d1^int_exp[j]]
        ticks_all = [ticks_all,'10!U'+str_exp[j]+'!N']
      ENDELSE
    ENDFOR
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  RANGE spans less than 3 orders of magnitude --> include minor tick marks
    ;;------------------------------------------------------------------------------------
    ntmax          = 5L                    ;;  Default maximum number of major tick marks
    FOR j=0L, N_ELEMENTS(int_exp) - 1L DO BEGIN
      test_zero  = (int_exp[j] EQ 0)
      test__one  = (int_exp[j] EQ 1)
      CASE int_exp[j] OF
        -1   : BEGIN
          str_pref = '0.'
          str_suff = ''
        END
         0   : BEGIN
          str_pref = ''
          str_suff = ''
        END
         1   : BEGIN
          str_pref = ''
          str_suff = '0'
        END
        ELSE : BEGIN
          str_pref = ''
          str_suff = ' x 10!U'+str_exp[j]+'!N'
        END
      ENDCASE
      IF (test_zero[0] OR test__one[0]) THEN BEGIN
        minor          = 10L                   ;;  # of minor tick marks
        ntmin          = 3L                    ;;  Default minimum number of major tick marks
      ENDIF ELSE BEGIN
        minor          = 9L                    ;;  # of minor tick marks
        ntmin          = 1L                    ;;  Default minimum number of major tick marks
      ENDELSE
      IF (j EQ 0) THEN BEGIN
        tickv_all = tickv_fac*1d1^int_exp[j]
        ticks_all = str_pref[0]+ticks_fac+str_suff[0]
      ENDIF ELSE BEGIN
        tickv_all = [tickv_all,tickv_fac*1d1^int_exp[j]]
        ticks_all = [ticks_all,str_pref[0]+ticks_fac+str_suff[0]]
      ENDELSE
    ENDFOR
  ENDELSE
ENDELSE
;;  Sort
sp             = SORT(tickv_all)
tickv_all      = TEMPORARY(tickv_all[sp])
ticks_all      = TEMPORARY(ticks_all[sp])
nt             = N_ELEMENTS(tickv_all)
;;  Check if there multiple tick marks beyond relevant data range
bad_oldrnl     = WHERE(tickv_all LT dat_ran[0],bd_oldranl)
bad_newrnl     = WHERE(tickv_all LT new_ran[0],bd_newranl)
bad_oldrnu     = WHERE(tickv_all GT dat_ran[1],bd_oldranu)
bad_newrnu     = WHERE(tickv_all GT new_ran[1],bd_newranu)
IF (bd_oldranl[0] GT 1) THEN BEGIN
  ;;  Extra tick marks beyond the last one below the data range
  low            = MAX(bad_oldrnl)
ENDIF ELSE low = 0L
IF (bd_oldranu[0] GT 1) THEN BEGIN
  ;;  Extra tick marks beyond the last one above the data range
  upp            = MIN(bad_oldrnu)
ENDIF ELSE upp = nt[0] - 1L
IF (low[0] GT upp[0]) THEN upp = (upp[0] + 1L) < (nt[0] - 1L)
IF (low[0] GT upp[0]) THEN low = (low[0] - 1L) > 0L
tickv_all      = TEMPORARY(tickv_all[low[0]:upp[0]])
ticks_all      = TEMPORARY(ticks_all[low[0]:upp[0]])
;;----------------------------------------------------------------------------------------
;;  Check if we need to limit or expand the number of tick marks
;;----------------------------------------------------------------------------------------
tick_val       = tickv_all
tick_str       = ticks_all
nt             = N_ELEMENTS(tick_val)
kk             = LINDGEN(nt[0])
;;  Check if limitation is necessary
IF (nt[0] GT ntmax[0]) THEN BEGIN
  ;;  Need to limit
  n_ex           = nt[0] - ntmax[0]          ;;  # of excessive tick marks to remove
  even_t         = (n_ex[0] MOD 2) EQ 0      ;;  TRUE --> even # of extra ticks
  n_subex        = n_ex[0]/2L                ;;  # to remove on each side
  ;;  keep lowest and highest
  low            = 0L
  upp            = (nt[0] - 1L) - even_t[0]  ;;  keep last if odd, last minus one if even
  del            = tick_val - SHIFT(tick_val,1)
  dmn            = MIN(del[1:*],/NAN,ldn)
  dmx            = MAX(del[1:*],/NAN,ldx)
  IF (ntmax[0] EQ 3L) THEN BEGIN
    gind = [0L,ldx[0],(nt[0] - 1L)]     ;;  Only 1 possible choice
  ENDIF ELSE BEGIN
    in             = upp[0] - low[0] + 1L
    denom          = (ntmax[0] - (2L - even_t[0])) > 2L
    fac            = FLOOR(1d0*nt[0]/denom[0]) > 1L
    IF (n_ex[0] EQ 1) THEN BEGIN
      gind           = [low[0],ldx[0],upp[0]]
    ENDIF ELSE BEGIN
      IF (even_t[0]) THEN BEGIN
        t_g            = LINDGEN(ntmax[0] - 2L)*fac[0] + fac[0]
        gind           = [low[0],t_g,upp[0]]
      ENDIF ELSE BEGIN
        gind           = fill_range(low[0],upp[0],DIND=fac[0])
      ENDELSE
    ENDELSE
  ENDELSE
  unq            = UNIQ(gind,SORT(gind))
  IF (N_ELEMENTS(unq) NE N_ELEMENTS(gind)) THEN gind = TEMPORARY(gind[unq])
  ;;  Redefine ticks
  tick_val       = TEMPORARY(tick_val[gind])
  tick_str       = TEMPORARY(tick_str[gind])
ENDIF ELSE BEGIN
  ;;  Check if expansion is necessary
  IF (nt[0] LT ntmin[0]) THEN BEGIN
    ;;  Need to expand
    n_ex           = ntmin[0] - nt[0]         ;;  # of additional tick marks needed
    even_t         = (n_ex[0] MOD 2) EQ 0     ;;  TRUE --> even # of extra ticks
    n_subex        = n_ex[0]/2L               ;;  # to add on each side
    IF (even_t[0]) THEN BEGIN
      ;;  Add even number of ticks
      low            = MIN(good_dumb) - n_subex[0]
      upp            = MAX(good_dumb) + n_subex[0]
    ENDIF ELSE BEGIN
      low            = MIN(good_dumb) - n_subex[0]
      upp            = MAX(good_dumb) + n_subex[0] + 1L
    ENDELSE
    gind           = fill_range(low[0],upp[0],DIND=1)
    tick_val       = dumb_tickv[gind]
    tick_str       = dumb_ticks[gind]
  ENDIF
ENDELSE
;;  Sort
sp             = SORT(tick_val)
tick_val       = TEMPORARY(tick_val[sp])
tick_str       = TEMPORARY(tick_str[sp])
;;  Define the [X,Y,Z]TICKS keyword value
tick_nnn       = N_ELEMENTS(tick_val) - 1L
;;  Redefine range for output to match tick mark values
dat_ran[0]     = dat_ran[0] < MIN(tick_val,/NAN)
dat_ran[1]     = dat_ran[1] > MAX(tick_val,/NAN)
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
tags           = ['RANGE','TICKV','TICKNAME','TICKS','MINOR']
struct         = CREATE_STRUCT(tags,dat_ran,tick_val,tick_str,tick_nnn[0],minor[0])
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END

