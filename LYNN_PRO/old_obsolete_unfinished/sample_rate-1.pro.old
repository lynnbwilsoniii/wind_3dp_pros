;+
;*****************************************************************************************
;
;  FUNCTION :   sample_rate.pro
;  PURPOSE  :   Determines the sample rate of an input time series of data with the
;                 ability to set gap thresholds to avoid including them in the
;                 calculation.
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
;               TIME         :  [N]-Element array of time stamps [s] associated with
;                                 a time series for which one is interested in
;                                 determining the sample rate
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               GAP_THRESH   :  Scalar defining the maximum data gap [s] allowed in
;                                 the calculation
;                                 [Default = MAX(TIME) - MIN(TIME)]
;               AVERAGE      :  If set, routine returns the scalar average sample rate
;                                 [Default = 0, which returns an array of sample rates]
;               OUT_MED_AVG  :  Set to a named variable to return the median and average
;                                 values of the sample rate if the user wants all values
;                                 as well
;
;   CHANGED:  1)  Changed algorithm slightly to help avoid some special issues and
;                   added keyword:  OUT_MED_AVG
;                                                                  [07/26/2013   v1.1.0]
;
;   NOTES:      
;               1)  The output is the sample rate in [# samples per unit time]
;               2)  If GAP_THRESH is set too small, then the returned result is a 
;
;   CREATED:  03/28/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/26/2013   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION sample_rate,time,GAP_THRESH=gap_thresh,AVERAGE=average,OUT_MED_AVG=medavg

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f        = !VALUES.F_NAN
d        = !VALUES.D_NAN
medavg   = [d,d]
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 1) THEN RETURN,0

tt       = REFORM(time)
nt       = N_ELEMENTS(tt)
;;  Sort input just in case
sp       = SORT(tt)
tt       = tt[sp]
;;  Define the total time between the first and last data point
trange   = MAX(tt,/NAN) - MIN(tt,/NAN)
;;  Define shifted difference
lower    = LINDGEN(nt - 1L)
upper    = lower + 1L
sh_diff  = [d,(tt[upper] - tt[lower])]
;;----------------------------------------------------------------------------------------
;;  Determine the maximum allowable gap and remove "bad" values
;;----------------------------------------------------------------------------------------
;IF NOT KEYWORD_SET(gap_thresh) THEN mx_gap = trange ELSE mx_gap = gap_thresh[0]
IF (N_ELEMENTS(gap_thresh) EQ 0) THEN mx_gap = trange[0] ELSE mx_gap = gap_thresh[0]
bad      = WHERE(ABS(sh_diff) GT mx_gap[0] OR ABS(sh_diff) EQ 0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0 AND bd LT nt) THEN BEGIN
  sh_diff[bad] = d
ENDIF ELSE BEGIN
  IF (bd EQ nt) THEN RETURN,d
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check for outliers and remove if necessary
;;----------------------------------------------------------------------------------------
avg_dt   = MEAN(sh_diff,/NAN,/DOUBLE)
med_dt   = MEDIAN(sh_diff,/DOUBLE)
top      = ABS(avg_dt[0]) > ABS(med_dt[0])
bot      = ABS(avg_dt[0]) < ABS(med_dt[0])
;;  Make sure there is not a significant difference between Avg. and Med.
ratio    = ABS(top[0]/bot[0])*1d1
test     = (ratio[0] GE 1) AND (ABS(avg_dt[0]) NE ABS(med_dt[0]))  ;;  If true, then start loop to eliminate outliers
;test     = 1
jj       = 0L
IF (test) THEN BEGIN
  std_dt   = STDDEV(sh_diff,/NAN,/DOUBLE)
  tb       = avg_dt[0] + std_dt[0]*3d0*[-1d0,1d0]
  ;;  Check for outliers
  temp     = ((sh_diff GE tb[1]) OR (sh_diff LE tb[0]))
  bad      = WHERE(temp,bd)
  IF (bd GT 0 AND bd LT nt) THEN BEGIN
    sh_diff[bad] = d
    avg_dt       = MEAN(sh_diff,/NAN,/DOUBLE)
    med_dt       = MEDIAN(sh_diff,/DOUBLE)
  ENDIF
ENDIF
;WHILE (test) DO BEGIN
;  ;;  Calculate average and median ∆t
;  min_dt   = MIN(ABS(sh_diff),/NAN)
;  max_dt   = MAX(ABS(sh_diff),/NAN)
;  avg_dt   = MEAN(sh_diff,/NAN,/DOUBLE)
;  std_dt   = STDDEV(sh_diff,/NAN,/DOUBLE)
;  med_dt   = MEDIAN(sh_diff,/DOUBLE)
;  tb       = avg_dt[0] + std_dt[0]*3d0*[-1d0,1d0]
;  ;;  Make sure there is not a significant difference between Avg. and Med.
;  ratio    = ABS(avg_dt[0]/med_dt[0]*1d2)
;;  temp     = ((ABS(sh_diff) GE tb[1]) OR (ABS(sh_diff) LE tb[0]))
;  temp     = ((sh_diff GE tb[1]) OR (sh_diff LE tb[0]))
;  bad      = WHERE(temp,bd)
;  jj      += test
;  test     = (bd GT 0) AND (jj LT 10)  ;;  keep from iterating too long...
;  IF (test) THEN sh_diff[bad] = d
;  PRINT,';;  bd = ', bd
;  ration   = ABS(med_dt[0]/min_dt[0]*1d2)
;  ratiox   = ABS(max_dt[0]/med_dt[0]*1d2)
;  test     = ((ratiox[0] GE 1) OR (ration[0] GE 1)) AND (jj LT 100)  ;;  keep from iterating too long...
;  jj      += test
;  IF (test) THEN BEGIN
;    tb  = avg_dt[0] + std_dt[0]*3d0*[-1d0,1d0]
;    bad = WHERE(ABS(sh_diff) GE tb[1] OR ABS(sh_diff) LE tb[0],bd)
;    IF (bd GT 0) THEN sh_diff[bad] = d
;  ENDIF
;ENDWHILE
;;----------------------------------------------------------------------------------------
;;  Calculate the sample rate
;;----------------------------------------------------------------------------------------
samrates = 1d0/sh_diff
avgsmrt  = MEAN(samrates,/NAN,/DOUBLE)
medsmrt  = MEDIAN(samrates,/DOUBLE)
IF KEYWORD_SET(average) THEN sam_rate = avgsmrt[0] ELSE sam_rate = samrates
medavg   = [medsmrt[0],avgsmrt[0]]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,sam_rate
END