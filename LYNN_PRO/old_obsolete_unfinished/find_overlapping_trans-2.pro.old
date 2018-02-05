;+
;*****************************************************************************************
;
;  FUNCTION :   find_overlapping_trans.pro
;  PURPOSE  :   Finds the indices of two input arrays of time ranges the correspond to
;                 the overlapping intervals between a min and max overlap threshold.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               time_double.pro
;               time_string.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               SE_T0      :  [N,2]-Element [numeric] array of start/end times defining
;                               the intervals for the 1st set of time ranges to compare
;                               with the 2nd set of time ranges.  The times should be
;                               input as seconds from some epoch.
;               SE_T1      :  [K,2]-Element [numeric] array of start/end times defining
;                               the intervals for the 2nd set of time ranges to compare
;                               with the 1st set of time ranges.  The times should be
;                               input as seconds from some epoch.
;
;  EXAMPLES:    
;               [calling sequence]
;               ginds = find_overlapping_trans(se_t0, se_t1 [,MIN_OVR=min_ovr]          $
;                                              [,MAX_OVR=max_ovr] [,PRECISION=precision])
;
;               ;;  Assume N < K in the following example
;               ginds = find_overlapping_trans(se_t0,se_t1,MIN_OVR=2d-1,MAX_OVR=1d0,PREC=3)
;               good0 = WHERE(ginds[*,0] GE 0)
;               good1 = WHERE(ginds[*,1] GE 0)
;               gind0 = ginds[good0,0]
;               gind1 = ginds[good1,1]
;               diff  = se_t0[gind0,0] - se_t1[gind1,0]
;               PRINT,';;  ',MIN(diff,/NAN),MAX(diff,/NAN)
;               ;;         0.0000000       0.0000000
;
;  KEYWORDS:    
;               MIN_OVR    :  Scalar [numeric] defining the minimum overlap (percentage)
;                               to allow when considering two time ranges as overlapping.
;                               The value entered should be a double/float that is a
;                               fraction of unity, not an integer percentage.  For
;                               instance, to use 10% one would enter MIN_OVR=0.1.
;                               [Default = 0.01]
;               MAX_OVR    :  Scalar [numeric] defining the maximum overlap (percentage)
;                               to allow when considering two time ranges as overlapping.
;                               The value entered should be a double/float that is a
;                               fraction of unity, not an integer percentage.  For
;                               instance, to use 10% one would enter MIN_OVR=0.1.
;                               [Default = infinite]
;               PRECISION  :  Scalar [numeric] defining the precision with which to
;                               compare the input times SE_T0 and SE_T1.  The numeric
;                               value defines the number of decimal places to include
;                               in the evaluation of the overlaps between the two
;                               inputs.  For instance, here are some example PRECISION
;                               settings:
;                                -5  :  years
;                                -4  :  months
;                                -3  :  days
;                                -2  :  hours
;                                -1  :  minutes
;                                 0  :  seconds
;                                 3  :  milliseconds
;                                 6  :  microseconds
;                                 9  :  nanoseconds
;                                12  :  picoseconds
;                                15  :  femtoseconds
;                               [Default = 0 (i.e., second resolution)]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [06/01/2017   v1.0.0]
;             2)  Continued to write routine
;                                                                   [07/31/2017   v1.0.0]
;
;   NOTES:      
;               1)  The PRECISION has the same setting results as that given by
;                     time_string.pro and/or time_struct.pro
;               2)  The MIN_OVR and MAX_OVR are percentages of the smaller array
;                     interval lengths
;               3)  MIN_OVR defines the smallest fraction that will define two intervals
;                     as the overlapping
;               4)  MAX_OVR defines the largest fraction that will define two intervals
;                     as the overlapping
;               5)  The output will be a [M,2]-element array, where M = (N > K) and those
;                     elements that do not have overlapping ranges will be set to -1
;               6)  See also:  merge_overlap_int.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  06/01/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/31/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION find_overlapping_trans,se_t0,se_t1,MIN_OVR=min_ovr,MAX_OVR=max_ovr,$
                                PRECISION=precision

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
noinpt_msg     = 'User must supply two, two-dimensional numeric arrays, SE_T0 and SE_T1, on input...'
badfin_msg0    = 'Bad input:  SE_T0 must be an [N,2]-element numeric array...'
badfin_msg1    = 'Bad input:  SE_T1 must be an [K,2]-element numeric array...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (is_a_number(se_t0,/NOMSSG) EQ 0) OR    $
                 (is_a_number(se_t1,/NOMSSG) EQ 0) OR                         $
                 ((N_ELEMENTS(se_t0) EQ 0) OR (N_ELEMENTS(se_t1) EQ 0))
IF (test[0]) THEN BEGIN
  ;;  No input
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check format
szdt0          = SIZE(se_t0,/DIMENSIONS)
szdt1          = SIZE(se_t1,/DIMENSIONS)
test0          = (TOTAL(szdt0 EQ 2) EQ 0) OR (N_ELEMENTS(szdt0) NE 2)
test1          = (TOTAL(szdt1 EQ 2) EQ 0) OR (N_ELEMENTS(szdt1) NE 2)
IF (test0[0] OR test1[0]) THEN BEGIN
  ;;  Bad input
  IF (test0[0]) THEN MESSAGE,badfin_msg0[0],/INFORMATIONAL,/CONTINUE ELSE $
                     MESSAGE,badfin_msg1[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define parameters
test           = (szdt0[1] EQ 2)
IF (test[0]) THEN new_se0 = se_t0 ELSE new_se0 = TRANSPOSE(se_t0)
test           = (szdt1[1] EQ 2)
IF (test[0]) THEN new_se1 = se_t1 ELSE new_se1 = TRANSPOSE(se_t1)
n_tr0          = N_ELEMENTS(new_se0[*,0])          ;;  # of time range intervals in SE_T0
k_tr1          = N_ELEMENTS(new_se1[*,0])          ;;  # of time range intervals in SE_T1
n__larger      = (n_tr0[0] > k_tr1[0])             ;;  # of elements in larger array
n_smaller      = (n_tr0[0] < k_tr1[0])             ;;  # of elements in smaller array
n_extra        = n__larger[0] - n_smaller[0]       ;;  Difference in # of elements between larger and smaller arrays
IF (n_extra[0] GT 0) THEN add_ex = 1b ELSE add_ex = 0b
;;  Make sure to sort input as well
sp             = SORT(new_se0[*,0])
new_se0        = TEMPORARY(new_se0[sp,*])
sp             = SORT(new_se1[*,0])
new_se1        = TEMPORARY(new_se1[sp,*])
;;  Create dummy arrays
dumbi          = REPLICATE(-1L,n__larger[0],2L)    ;;  Indices of overlapping arrays
IF (add_ex[0]) THEN ex_vals = REPLICATE(-1,n_extra[0]) ELSE ex_vals = -1
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check PRECISION
test           = (N_ELEMENTS(precision) GE 1) AND is_a_number(precision,/NOMSSG)
IF (test[0]) THEN prec = ((LONG(precision[0]))[0] < 15L) > (-5L) ELSE prec = 0L
;;  Check MIN_OVR
test           = (N_ELEMENTS(min_ovr) EQ 0) OR (is_a_number(min_ovr,/NOMSSG) EQ 0)
IF (test[0]) THEN minthrsh = 1d-2 ELSE minthrsh = (min_ovr[0] > 0d0) < 99d-2
;;  Check MAX_OVR
test           = (N_ELEMENTS(max_ovr) EQ 0) AND (is_a_number(max_ovr,/NOMSSG) EQ 0)
IF (test[0]) THEN max_on = 0b ELSE max_on = 1b
;;----------------------------------------------------------------------------------------
;;  Define interval lengths, overlaps, etc.
;;----------------------------------------------------------------------------------------
;;  Define structures orderd by larger/smaller arrays
IF (n__larger[0] EQ n_tr0[0]) THEN BEGIN
  new_sm         = new_se1
  new_lg         = new_se0
  revers         = 1b          ;;  Switch order of indices
ENDIF ELSE BEGIN
  new_sm         = new_se0
  new_lg         = new_se1
  revers         = 0b
ENDELSE
;;  Define interval lengths
delt_sm        = new_sm[*,1] - new_sm[*,0]
delt_lg        = new_lg[*,1] - new_lg[*,0]
;;  Define Max(overlap) threshold
min_dt         = MIN([MIN(ABS(delt_sm),/NAN),MIN(ABS(delt_lg),/NAN)],/NAN)
max_dt         = MAX([MAX(ABS(delt_sm),/NAN),MAX(ABS(delt_lg),/NAN)],/NAN)
upper          = max_dt[0]/min_dt[0]*1.05
IF (max_on[0]) THEN BEGIN
  maxthrsh = (max_ovr[0] > min_ovr[0]) < upper[0]
ENDIF ELSE BEGIN
  maxthrsh = upper[0]
ENDELSE
;;  Define and remove smallest offset
t_off          = MIN([MIN(new_sm,/NAN),MIN(new_lg,/NAN)],/NAN)
;;  Define start/end times with new precision
st_sm          = time_double(time_string(new_sm[*,0] - t_off[0],PREC=prec[0]))
en_sm          = time_double(time_string(new_sm[*,1] - t_off[0],PREC=prec[0]))
st_lg          = time_double(time_string(new_lg[*,0] - t_off[0],PREC=prec[0]))
en_lg          = time_double(time_string(new_lg[*,1] - t_off[0],PREC=prec[0]))
IF (add_ex[0]) THEN BEGIN
  st_sm = [st_sm,ex_vals]
  en_sm = [en_sm,ex_vals]
ENDIF ELSE BEGIN
  st_sm = st_sm
;  st_sm = st_t1
  en_sm = en_sm
ENDELSE
st_ls          = {LARGE:st_lg,SMALL:st_sm}
en_ls          = {LARGE:en_lg,SMALL:en_sm}
;;  Re-define interval lengths
delt_sm        = en_sm - st_sm
delt_lg        = en_lg - st_lg
bad            = WHERE(st_sm LT 0,bd)
IF (bd GT 0) THEN BEGIN
  delt_sm[bad]   = f
ENDIF
;;----------------------------------------------------------------------------------------
;;  Find overlaps
;;----------------------------------------------------------------------------------------
ginds          = dumbi
frac_out       = 1d0*dumbi
FOR j=0L, n__larger[0] - 1L DO BEGIN
  test    = (st_lg[j] GE st_sm) AND (st_lg[j] LE en_sm)
  good    = WHERE(test,gd)
  IF (gd[0] GT 0) THEN BEGIN
    ;;  Check fractional overlap
    gind           = good[0]
    d_elss         = ABS(en_sm[gind[0]] - st_lg[j])
    IF (FINITE(delt_sm[gind[0]])) THEN frac = d_elss[0]/ABS(delt_sm[gind[0]]) ELSE frac = -1e0
    frac_out[j,0]  = frac[0]
    test           = (frac[0] GE minthrsh[0]) AND (frac[0] LE maxthrsh[0])
    IF (test[0]) THEN BEGIN
      ginds[j,0] = gind[0]
      ginds[j,1] = j[0]
    ENDIF
  ENDIF
ENDFOR
IF (revers[0]) THEN BEGIN
  ;;  Switch so ARRAY_OUT[*,(0,1)] corresponds to indices of SE_T(0,1)
  array_out      = dumbi
  array_out[*,0] = ginds[*,1]
  array_out[*,1] = ginds[*,0]
ENDIF ELSE BEGIN
  ;;  Already in correct order
  array_out      = ginds
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,array_out
END
