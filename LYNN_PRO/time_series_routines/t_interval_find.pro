;*****************************************************************************************
;
;  FUNCTION :   merge_adjacent_int.pro
;  PURPOSE  :   This routine merges adjacent intervals that are separated by ≤ 1
;                 element.
;
;  CALLED BY:   
;               t_interval_find.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               SE_INT     :  [N,2]-Element [integer] array from t_interval_find.pro
;
;  EXAMPLES:    
;               [calling sequence]
;               se_mrg = merge_adjacent_int(se_int [,THR_MERGE=merge_thr])
;
;  KEYWORDS:    
;               THR_MERGE  :  Scalar [numeric] defining the gap threshold # of elements
;                               between intervals to allow before merging
;                                [Default = 1]
;
;   CHANGED:  1)  Added keyword:  THR_MERGE
;                                                                   [09/10/2013   v1.1.0]
;             2)  Updated Man. page and main routine
;                                                                   [11/28/2015   v1.1.1]
;
;   NOTES:      
;               1)  User should not call this routine
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/09/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/28/2015   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION merge_adjacent_int,se_int,THR_MERGE=merge_thr

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 1) THEN RETURN,-1
test           = (N_ELEMENTS(se_int) LE 2)
IF (test) THEN RETURN,se_int
;;----------------------------------------------------------------------------------------
;;  Define Parameters
;;----------------------------------------------------------------------------------------
start          = se_int[*,0]
stops          = se_int[*,1]
thick          = stops - start
wint           = N_ELEMENTS(start)

test           = (N_ELEMENTS(merge_thr) GT 0)
IF (test) THEN BEGIN
  ;;  THR_MERGE keyword set
  m_thresh = (merge_thr[0] > 1) < (wint[0]/10L)
ENDIF ELSE BEGIN
  ;;  Use default
  m_thresh = 1L
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check intervals
;;----------------------------------------------------------------------------------------
test           = (thick LE (m_thresh[0] - 1L))
badn           = WHERE(test,bdn)
test0          = (bdn GT 0) AND (badn[0] NE 0)
test1          = (bdn GT 0) AND (badn[0] EQ 0) AND (MAX(badn) NE wint)
test2          = (test0 OR test1)

test           = (bdn GT 0)
IF (test) THEN BEGIN
  ;;  adjacent intervals exist
  merge      = REPLICATE(0L,bdn,2)
  nmer       = bdn
  ;;  fill values
  IF (test0) THEN BEGIN
    merge = ([[badn - 1L],[badn]]) > 0L
  ENDIF ELSE BEGIN
    merge = ([[badn],[badn + 1L]]) < (wint - 1L)
  ENDELSE
ENDIF ELSE BEGIN
  ;;  all intervals are at least 2 elements long
  out_se     = se_int
  nmer       = 0
  merge      = 0
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Merge intervals if necessary
;;----------------------------------------------------------------------------------------
IF (nmer GT 0) THEN BEGIN
  se_nint = se_int
  FOR j=0L, nmer - 1L DO BEGIN
    bels            = REFORM(merge[j,*])
    lels            = se_nint[bels[0],0]
    hels            = se_nint[bels[1],1]
    se_nint[bels,0] = lels
    se_nint[bels,1] = hels
  ENDFOR
  ;;  Determine unique elements
  unql    = UNIQ(se_nint[*,0],SORT(se_nint[*,0]))
  sp      = SORT(unql)
  unql    = unql[sp]
  ;;  Redefine intervals
  out_se  = se_nint[unql,*]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,out_se
END


;+
;*****************************************************************************************
;
;  FUNCTION :   t_interval_find.pro
;  PURPOSE  :   Finds the start/end elements of the data gaps in a timeseries that
;                 contains data gaps or is composed of discontinuously sampled data
;                 [e.g. THEMIS EFI or SCM in Wave Burst mode].
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               merge_adjacent_int.pro
;
;  CALLS:
;               is_a_number.pro
;               sample_rate.pro
;               merge_adjacent_int.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TIME        :  [N]-Element [double] array of time stamps [s] associated
;                                with a time series that has gaps or is discontinuously
;                                sampled
;
;  EXAMPLES:    
;               [calling sequence]
;               se_int = t_interval_find(time [,GAP_THRESH=gap_thresh] [,NAN=nan] $)
;                                        [,MERGE=merge] [,THR_MERGE=merge_thr]
;
;  KEYWORDS:    
;               GAP_THRESH  :  Scalar [double/float] defining the maximum data gap [s]
;                                allowed in the calculation
;                                [Default = 4/Sr, Sr = sample rate (sampls/s)]
;               NAN         :  If set, routine will treat NaNs as data gaps
;                                [Default = 0]
;               MERGE       :  If set, routine will merge adjacent indices to avoid
;                                a return array where the difference between the
;                                start and end elements equals zero.  This keyword is
;                                useful when the NAN keyword is set.
;                                [Default = 0]
;               THR_MERGE   :  Scalar [numeric] defining the gap threshold # of elements
;                                between intervals to allow before merging
;                                [Default = 1]
;
;   CHANGED:  1)  Continued writing routine
;                   --> Fixed an issue with element definitions
;                                                                   [07/17/2012   v1.0.0]
;             2)  Added keywords:  NAN and MERGE and
;                   now calls merge_adjacent_int.pro
;                                                                   [09/09/2013   v1.1.0]
;             3)  Added keyword:  THR_MERGE
;                                                                   [09/10/2013   v1.2.0]
;             4)  Updated Man. page and now ensures that start and end points are
;                   part of the return array set and now calls is_a_number.pro
;                                                                   [11/28/2015   v1.3.0]
;
;   NOTES:      
;               1)  The output is a [K,2]-element array of [start,end] elements
;                     corresponding to the regions of uniformly sampled data
;               2)  Technically the units do not matter so long as they are consistent
;                     between TIME and GAP_THRESH
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/16/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/28/2015   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION t_interval_find,time,GAP_THRESH=gap_thresh,NAN=nan,$
                              MERGE=merge,THR_MERGE=merge_thr

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, sample_rate, merge_adjacent_int
;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 1) OR (is_a_number(time,/NOMSSG) EQ 0) OR $
                 (N_ELEMENTS(time) LT 4)
IF (test[0]) THEN RETURN,-1

tt             = REFORM(time)
nt             = N_ELEMENTS(tt)
;;  Define the total time between the first and last data point
trange         = MAX(tt,/NAN) - MIN(tt,/NAN)
;;  Define shifted difference, ∆t [s]
lower          = LINDGEN(nt - 1L)
upper          = lower + 1L
sh_diff        = [0d0,(tt[upper] - tt[lower])]
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;  Note:
;;          t[k]   =   kth element of timestamps
;;                {= [N]-element array}
;;         ∆t_ij   =   t[j] - t[i]
;;                {= [N]-element array of time differences between adjacent elements}
;;         ∂t      =   sample period
;;          S[k]   =   kth element of start elements
;;          E[k]   =   kth element of end   elements
;;
;;         ∆t[k]  ==   kth element of ∆t { <---> ∆t_ij }
;;            k   -->  upper[j]
;;
;;         1)  ∆t[0] = NaN
;;         2)   (S[0] = 0L) & (E[{last element}] = N - 1L)
;;         3)  IF (∆t_ij > a * ∂t) => (S[k] = j) & (E[k] = i)
;;               {a = some factor > 1}
;;
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
s0             = 0L       ;; 1st element of start element array
ee             = nt - 1L  ;; Last element of end element array
e_els          = [-1,upper]
s_els          = [lower,-1]
;;----------------------------------------------------------------------------------------
;;  Estimate the sample rate and gap threshold
;;----------------------------------------------------------------------------------------
srate          = DOUBLE(ROUND(sample_rate(tt,/AVERAGE)))
IF NOT KEYWORD_SET(gap_thresh) THEN BEGIN
  mx_gap = 4d0/srate[0]
ENDIF ELSE BEGIN
  mx_gap = gap_thresh[0]
  ;; check if finite
  test   = (FINITE(mx_gap[0]) EQ 0)
  IF (test) THEN BEGIN
    ;; use default
    mx_gap = 4d0/srate[0]
  ENDIF
ENDELSE

;;  Check if user wants to include NaNs as gaps
test           = (N_ELEMENTS(nan) EQ 0) OR ~KEYWORD_SET(nan)
IF (test) THEN use_nans = 0 ELSE use_nans = 1
;;----------------------------------------------------------------------------------------
;;  Find where time-shifts exceed gap threshold
;;----------------------------------------------------------------------------------------
IF (use_nans) THEN BEGIN
  find = WHERE(FINITE(sh_diff) EQ 0,fd)
  IF (fd GT 0) THEN sh_diff[find] = 1.01*mx_gap[0]
ENDIF
test           = (sh_diff GT mx_gap[0])
bad            = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0 AND bd LT nt) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  found data gaps
  ;;--------------------------------------------------------------------------------------
  ;;  Define START elements
  gel_sta = [s0[0],s_els[bad]]  ;; add first element
  ;;  Define END elements
  gel_end = [(e_els[bad] - 1L),ee[0]]  ;; add last element
ENDIF ELSE BEGIN
  IF (bd EQ nt) THEN RETURN,-1
  ;;  Define START elements
  gel_sta = [s0[0]]
  ;;  Define END elements
  gel_end = [ee[0]]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check if user wishes to merge adjacent intervals
;;----------------------------------------------------------------------------------------
se_int         = [[gel_sta],[gel_end]]
test           = (N_ELEMENTS(merge) NE 0)
IF (test) THEN test   = (merge[0] NE 0)
IF (test) THEN out_int = merge_adjacent_int(se_int,THR_MERGE=merge_thr) ELSE out_int = se_int
;;----------------------------------------------------------------------------------------
;;  Make sure intervals contain the 1st and last elements
;;----------------------------------------------------------------------------------------
n_int          = N_ELEMENTS(out_int[*,0])
test_low       = (out_int[0,0] GT s0[0])
IF (test_low[0]) THEN BEGIN
  ;;  Add a first interval onto beginning of current list
  s_i_add = s0[0]
  e_i_add = (out_int[0,0] - 1L) > s0[0]
  se_add  = REFORM([s_i_add[0],e_i_add[0]],1,2)
  out_int = [se_add,out_int]
ENDIF
test_upp       = (out_int[(n_int[0] - 1L),1] LT ee[0])
IF (test_upp[0]) THEN BEGIN
  ;;  Add a final interval onto end of current list
  s_i_add = (out_int[(n_int[0] - 1L),1] + 1L) < ee[0]
  e_i_add = ee[0]
  se_add  = REFORM([s_i_add[0],e_i_add[0]],1,2)
  out_int = [out_int,se_add]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check for negative values
;;----------------------------------------------------------------------------------------
s_int          = out_int[*,0] > 0
e_int          = out_int[*,1] < ee[0]
low            = LINDGEN(ee[0])
upp            = low + 1L
test_low       = s_int[upp] LT s_int[low]
test_upp       = s_int GT e_int
bad_low        = WHERE(test_low,bd_low)
bad_upp        = WHERE(test_upp,bd_upp)
IF (bd_low GT 0) THEN BEGIN
  ;;  There is a start element preceeding a previous end element --> fix
  bindl            = upp[bad_low]
  out_int[bindl,0] = out_int[bindl,1] < ee[0]
ENDIF
bindu          = bad_upp
IF (bd_upp GT 0) THEN out_int[bindu,0] = out_int[bindu,1] < ee[0]   ;;  The start element exceeds the end element --> fix
;;  Sort [just in case]
sp             = SORT(REFORM(out_int[*,0]))
out_int        = TEMPORARY(out_int[sp,*])
;;----------------------------------------------------------------------------------------
;;  Return start/end elements to user
;;----------------------------------------------------------------------------------------

RETURN,out_int
END