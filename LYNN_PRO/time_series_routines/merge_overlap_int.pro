;+
;*****************************************************************************************
;
;  FUNCTION :   merge_overlap_int.pro
;  PURPOSE  :   Merges and/or combines intervals satisfying various keyword-dependent
;                 tests, from gap thresholds to minimum/maximum interval length
;                 requirements.
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
;               SE_I       :  [N,2]-Element [numeric] array of start/end points, indices,
;                               times, etc. of intervals to merge/coalesce into a smaller
;                               array if there are overlaps (smaller than GAP_THRSH) or
;                               intervals too small (smaller than MIN_INT) or too large
;                               (larger than MAX_INT)
;
;  EXAMPLES:    
;               [calling sequence]
;               new_se = merge_overlap_int(se_i [,GAP_THRSH=gap_thrsh] [,MIN_INT=min_int] $
;                                          [,MAX_INT=max_int] [,COUNT=count])
;
;  KEYWORDS:    
;               ****************
;               ***  INPUTS  ***
;               ****************
;               GAP_THRSH  :  Scalar [numeric] defining the maximum gap threshold below
;                               which intervals are merged
;                               [Default = 0]
;               MIN_INT    :  Scalar [numeric] defining the minimum interval length below
;                               which intervals are removed
;                               [Default = 0]
;               MAX_INT    :  Scalar [numeric] defining the maximum interval length above
;                               which intervals are broken into smaller ones
;                               [Default = (N - 1)]
;               *****************
;               ***  OUTPUTS  ***
;               *****************
;               COUNT      :  Set to a named variable that returns a scalar defining the
;                               number of intervals on output
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [07/25/2016   v1.0.0]
;             2)  Continued to write routine
;                                                                   [07/25/2016   v1.0.0]
;             3)  Finished writing routine
;                                                                   [07/26/2016   v1.0.0]
;
;   NOTES:      
;               1)  Be sure to play around with the routine before employing so as to
;                     fully understand its functionality.
;
;  REFERENCES:  
;               0)  Adapted from Craig B. Markwardt's routine, gtitrim.pro, found at:
;                     http://cow.physics.wisc.edu/~craigm/idl/idl.html
;
;   CREATED:  07/24/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/26/2016   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION merge_overlap_int,se_i,GAP_THRSH=gap_thrsh,MIN_INT=min_int,MAX_INT=max_int,$
                                COUNT=count

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
noinpt_msg     = 'User must supply an [N,2]-element numeric array, SE_I, on input...'
badfin_msg     = 'Bad input:  SE_I must be an [N,2]-element numeric array...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (is_a_number(se_i,/NOMSSG) EQ 0) OR $
                 ((N_ELEMENTS(se_i) EQ 0) OR ((N_ELEMENTS(se_i) MOD 2) NE 0))
IF (test[0]) THEN BEGIN
  ;;  No input
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
szdi           = SIZE(se_i,/DIMENSIONS)
test           = (TOTAL(szdi EQ 2) EQ 0) OR (N_ELEMENTS(szdi) NE 2)
IF (test[0]) THEN BEGIN
  ;;  No input
  MESSAGE,badfin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define parameters
test           = (szdi[1] EQ 2)
IF (test[0]) THEN new_se = se_i ELSE new_se = TRANSPOSE(se_i)
n_int          = N_ELEMENTS(new_se[*,0])          ;;  # of intervals
n_max          = (n_int[0] - 1L)
;;  Make sure to sort input as well
sp             = SORT(new_se[*,0])
new_se         = TEMPORARY(new_se[sp,*])
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check GAP_THRSH
test_gth       = is_a_number(gap_thrsh,/NOMSSG)
IF (test_gth[0]) THEN BEGIN
  test_gth = (gap_thrsh[0] LE n_max[0])
  IF (test_gth[0]) THEN g_thrsh = DOUBLE(gap_thrsh[0]) ELSE g_thrsh = 0d0
ENDIF ELSE BEGIN
  ;;  Not set or incorrectly set --> use default
  g_thrsh        = 0d0
ENDELSE
;;  Check MIN_INT
test_min       = is_a_number(min_int,/NOMSSG)
IF (test_min[0]) THEN BEGIN
  test_min = (min_int[0] GE 0)
  IF (test_min[0]) THEN min_i = DOUBLE(min_int[0]) ELSE min_i = 0d0
ENDIF ELSE BEGIN
  ;;  Not set or incorrectly set --> use default
  min_i        = 0d0
ENDELSE
;;  Check MAX_INT
test_max       = is_a_number(max_int,/NOMSSG)
IF (test_max[0]) THEN BEGIN
  test_max = (max_int[0] GE 0)
  IF (test_max[0]) THEN max_i = DOUBLE(max_int[0]) ELSE max_i = 1d0*n_max[0]
ENDIF ELSE BEGIN
  ;;  Not set or incorrectly set --> use default
  max_i        = 1d0*n_max[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check for "large" gaps
;;----------------------------------------------------------------------------------------
;;  Check for gaps larger than GAP_THRSH
diff           = new_se[1:*,0] - new_se[*,1]
bad            = WHERE(diff GT g_thrsh[0],bd,COMPLEMENT=good,NCOMPLEMENT=gd)
test           = (bd[0] GT 0) AND (bd[0] LT n_max[0])
IF (test[0]) THEN BEGIN
  ;;  Bad overlaps or gaps exist --> merge
  ngl                = bd[0] - 1L
  ngu                = bd[0] + 1L
  badl               = bad
  badu               = bad + 1L
  ;;  Create dummy array
  val_se             = REFORM(MAKE_ARRAY(ngu[0],2L,VALUE=new_se[0]),ngu[0],2L,/OVERWRITE)
  ;;  Fill array first and last elements
  val_se[0,0]        = MIN(new_se)
  val_se[bd[0],1]    = MAX(new_se)
  ;;  Fill middle:  end elements satisfying test
  val_se[0:ngl[0],1] = new_se[badl,1]
  ;;  Fill middle:  start elements satisfying test
  val_se[1:bd[0],0]  = new_se[badu,0]
  ;;  Redefine new start/end elements array
  new_se             = TEMPORARY(val_se)
ENDIF ELSE BEGIN
  ;;  All elements overlap or all gaps are too small --> one set of start/end elements
  new_se             = REFORM([MIN(new_se),MAX(new_se)],1,2)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check for "small" intervals
;;----------------------------------------------------------------------------------------
;;  Check for intervals smaller than MIN_INT
diffn          = new_se[*,1] - new_se[*,0]
goodn          = WHERE(diffn GE min_i[0],gdn,COMPLEMENT=badn,NCOMPLEMENT=bdn)
test           = (gdn[0] GT 0)
;;  Define count output
count          = gdn[0]
IF (test[0]) THEN BEGIN
  ;;  Keep only the elements that satisfy test
  new_se         = TEMPORARY(new_se[goodn,*])
  new_se         = REFORM(new_se,gdn[0],2,/OVERWRITE)
ENDIF ELSE BEGIN
  ;;  No elements satisfy test --> kill array
  new_se         = 0
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check for "large" intervals
;;----------------------------------------------------------------------------------------
;;  Check for intervals larger than MAX_INT
test           = (count[0] GT 0) AND test_max[0]
IF (test[0]) THEN BEGIN
  ;;  Check if any intervals are too large
  mx_thsh        = 1d0*max_i[0]
  diff_per       = (new_se[*,1] - new_se[*,0])/mx_thsh[0]
  int_per        = CEIL(diff_per)
  sum_iper       = TOTAL(int_per)
  test           = (mx_thsh[0] GT 0) AND (sum_iper[0] GT count[0])
  IF (test[0]) THEN BEGIN
    ;;  break up intervals that are too large
    vzero    = new_se[0]
    vzero[0] = 0            ;;  maintains type of input array
    new_se2  = MAKE_ARRAY(sum_iper[0],2L,VALUE=vzero[0])
    j        = 0L
    FOR i=0L, count[0] - 1L DO BEGIN
      test = (int_per[i] EQ 1)
      IF (test[0]) THEN BEGIN
        ;;  Interval size okay
        new_se2[j,*] = new_se[i,*]
      ENDIF ELSE BEGIN
        ;;  Break up "large" intervals
        FOR k=0L, int_per[i] - 1L DO BEGIN
          l            = j[0] + k[0]
          upp0         = k[0]*mx_thsh[0]
          upp1         = (k[0] + 1)*mx_thsh[0]
          new_se2[l,*] = [(new_se[i,0] + upp0[0]),(new_se[i,1] < (new_se[i,0] + upp1[0]))]
        ENDFOR
      ENDELSE
      ;;  Increment new array index
      j += int_per[i]
    ENDFOR
    ;;  Redefine COUNT output and output array
    count          = sum_iper[0]
    new_se         = REFORM(new_se2,count[0],2)
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,new_se
END


