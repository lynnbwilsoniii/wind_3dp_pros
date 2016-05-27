;+
;*****************************************************************************************
;
;  FUNCTION :   zero_crossings.pro
;  PURPOSE  :   This program attempts to count zero-crossings of an input array of DATA
;                 which is presumably some sort of semi-periodic function of input time
;                 array, TIMES.  The program returns the calculated/estimated frequency
;                 from the zero-crossings, the number of zero-crossings, and the 
;                 indices of those zero-crossings.
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
;               TIMES   :  N-Element array of times associated with DATA
;               DATA    :  N-Element array of data that presumably fluctuates about zero
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               THRESH  :  Scalar percentage of the maximum absolute value of the input
;                            DATA you wish to consider as a threshold deviation from
;                            zero before considering the change a "zero-crossing"
;               NOMSSG  :  If set, the program will NOT print out a message about the
;                            variables in the program.
;
;   CHANGED:  1)  Added keyword:  THRESH                          [09/17/2009   v1.0.1]
;             2)  Changed order of input so TIMES is first        [09/17/2009   v1.0.2]
;             3)  Changed a lot of things                         [09/17/2009   v1.1.0]
;             4)  Fixed typo                                      [09/18/2009   v1.1.1]
;             5)  Changed GOTO statement to avoid infinite loop if thresh = 0.25 wasn't
;                   large enough                                  [10/29/2009   v1.2.0]
;
;   NOTES:      
;               1)  This program is a direct adaptation of a subset of the routine
;                     thresh_lff.pro version 0.1.0 by K. Kersten.  The original
;                     program was embedded in a SWAVES TDS rountine.  This is an
;                     attempt to generalize the small zero-crossing counting aspect
;                     of that larger program for use outside of the SWAVES TDS
;                     routine, thresh_lff.pro.
;               2)  Though it is NOT necessary to have your TIMES input array in any
;                     particular set of units, one should be careful to note that the
;                     output frequency will change depending on the input units, of
;                     course.
;
;   CREATED:  09/16/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/29/2009   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION zero_crossings,times,data,THRESH=thresh,NOMSSG=nom

;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
tt         = REFORM(times)
mvc_temp   = REFORM(data)
npoints    = N_ELEMENTS(mvc_temp)

evlength   = MAX(tt,/NAN) - MIN(tt,/NAN)
timeseries = mvc_temp[0:(npoints - 1L)]   ; => Data
n_times    = SIZE(timeseries,/N_ELEMENTS)
;-----------------------------------------------------------------------------------------
; => Define variables
;-----------------------------------------------------------------------------------------
gtindex         = 0L      ; => Indices with TIMESERIES > MEANVAL + THRESHOLD
ltindex         = 0L      ; => Indices with TIMESERIES < MEANVAL - THRESHOLD
midindex        = 0L      ; => Indices with (MEANVAL - THRESHOLD) < TIMESERIES < (MEANVAL + THRESHOLD)
zerocrossings   = 0L      ; => Estimated # of zero crossings
keyarray        = 0L      ; => Logic array of values = [+1(for gtindex),-1(for ltindex),0(for midindex)]
zeroarray       = 0d0     ; => Array of mean values
zerotimes       = 0d0     ; => Array of times corresponding to desired zeroarray points
zc_index        = 0L      ; => Indices of the data that correspond to zero crossings
newseriesindex  = 0L      ; => Indices of data that correspond to points above or below threshold
zc_inner_spread = 0L      ; => Array of indices for zero crossings (excluding end points)
keycount        = 0L      ; => Index to use for KEYARRAY
keyend          = 0L      ; => Max indicie of KEYARRAY
zc_pairs        = 0L      ; => Pair of indices on either side of a zero crossing
zc_spread       = 0L      ; => # of points between zero crossings

meanval         = 0d0     ; => Average value of input DATA
peakval         = 0d0     ; => Max. Abs. value of input DATA

num_jumps       = 1.      ; => keep track of # of jumps
;-----------------------------------------------------------------------------------------
; => Determine mean, peak, and threshold values
;-----------------------------------------------------------------------------------------
meanval    = (MEAN(timeseries,/NAN))[0]
peakval    = (MAX([ABS(timeseries-meanval)],/NAN))[0]
;=========================================================================================
JUMP_TRY_AGAIN:
;=========================================================================================
IF NOT KEYWORD_SET(thresh) THEN BEGIN
  thfac = 25d-2
ENDIF ELSE BEGIN
  IF (DOUBLE(thresh) LT 1d0) THEN thfac = DOUBLE(thresh[0]) ELSE thfac = 25d-2
ENDELSE
threshold  = thfac[0]*peakval[0]

gtindex    = WHERE(timeseries GT meanval + threshold,gd)
ltindex    = WHERE(timeseries LT meanval - threshold,ld,COMPLEMENT=ltcomplement)
midindex   = WHERE(timeseries[ltcomplement] LT meanval + threshold,md)
keyarray   = INTARR(n_times)
; => Calculate the logic array where:
;     +1 = Indices with TIMESERIES > MEANVAL + THRESHOLD
;     -1 = Indices with TIMESERIES < MEANVAL - THRESHOLD
;      0 = Indices with (MEANVAL - THRESHOLD) < TIMESERIES < (MEANVAL + THRESHOLD)
IF (ld GT 0 AND md GT 0) THEN BEGIN
  gmidindex           = ltcomplement[midindex]
  keyarray[gmidindex] = 0
ENDIF ELSE gmidindex  = -1
IF (gd GT 0) THEN keyarray[gtindex] = 1
IF (ld GT 0) THEN keyarray[ltindex] = -1
; => Check to make sure threshold was not too big or too small
test          = (gtindex[0]      EQ -1) OR (ltindex[0]  EQ -1) OR $
                (ltcomplement[0] EQ -1) OR (midindex[0] EQ -1)
IF (test) THEN BEGIN
  MESSAGE,'Improper keyword format:  THRESH',/INFORMATION,/CONTINUE
  PRINT,'Threshold set too high or too low...'
  PRINT,'Using default value:  25%'
  thresh0    = 25d-2
  num_jumps += 2e-1
  IF (num_jumps LT 5L) THEN BEGIN
    thresh = num_jumps*thresh0
    GOTO,JUMP_TRY_AGAIN
  ENDIF ELSE BEGIN
    MESSAGE,'Not able to isolate zero-crossings...',/INFORMATION,/CONTINUE
    RETURN,0
  ENDELSE
ENDIF

zc_pairs      = INTARR(n_times,2)
keyend        = SIZE(keyarray,/N_ELEMENTS) - 1L ; => Max indicie of KEYARRAY
;-----------------------------------------------------------------------------------------
; => Count zero crossings
;-----------------------------------------------------------------------------------------
WHILE (keyarray[keycount] EQ 0) DO keycount += 1
lastgood      = keyarray[keycount]    ; => Last good value of KEYARRAY
lastgoodindex = keycount              ; => Last good index of data
keycount     += 1
WHILE (keycount LE keyend) DO BEGIN
  IF (lastgood*keyarray[keycount] EQ -1) THEN BEGIN
    zc_pairs[zerocrossings,*] = [lastgoodindex,keycount]
    zerocrossings            += 1
    lastgood                  = keyarray[keycount]
    lastgoodindex             = keycount
  ENDIF ELSE IF (keyarray[keycount] NE 0) THEN lastgoodindex = keycount
    keycount += 1
ENDWHILE

IF (zerocrossings EQ 0) THEN BEGIN
  quality              = 0
  zc_inner_spread      = [0]
  std_zc_inner_spread  = npoints
  mean_zc_inner_spread = 0
  zc_full_quality      = 0
  zc_index             = 0
  zc_spread            = 0
  zc_index0            = 0
  zc_pairs             = zc_pairs[0:(zerocrossings - 1L),*]
  zc_index0            = (zc_pairs[*,0] + zc_pairs[*,1])/2
ENDIF ELSE BEGIN
  zc_pairs        = zc_pairs[0:(zerocrossings - 1L),*]
  zc_index0       = (zc_pairs[*,0] + zc_pairs[*,1])/2
  zc_index        = [0,zc_index0,(npoints - 1L)]
  full_zc_index   = zc_index
  zc_spread       = [zc_index[0:(zerocrossings - 1L)],(npoints - 1L)] - $
                     [0,zc_index[0L:(zerocrossings - 1L)]]
  ; => Calc. Stats on ALL zero crossings spread
  std_zc_spread   = STDDEV(zc_spread,/NAN)
  mean_zc_spread  = MEAN(zc_spread,/NAN)
  ; prevent divide-by-zero
  IF (std_zc_spread EQ 0) THEN std_zc_spread = 0.1
  quality         = mean_zc_spread/std_zc_spread
  ; ignore endpoints if we have enough ZCs
  IF (zerocrossings GE 3) THEN BEGIN
    zc_inner_spread      = zc_spread[1L:(zerocrossings - 1L)]
    std_zc_inner_spread  = STDDEV(zc_inner_spread,/NAN)
    mean_zc_inner_spread = MEAN(zc_inner_spread,/NAN)
    ; prevent divide-by-zero
    IF (std_zc_inner_spread EQ 0) THEN std_zc_inner_spread = 0.1
  ENDIF ELSE BEGIN
    zc_inner_spread      = [0]
    std_zc_inner_spread  = npoints
    mean_zc_inner_spread = 0
  ENDELSE
  ; => Calc. Stats on inner zero crossings spread
  zc_inner_quality = mean_zc_inner_spread/std_zc_inner_spread
  zc_quality       = zc_inner_quality*quality
ENDELSE
;-----------------------------------------------------------------------------------------
; => Calculate frequency due to zero crossings
;-----------------------------------------------------------------------------------------
frequency = 0d0           ; => Estimate of frequency by zero crossings [units^(-1)]
zeroarray = 0d0           ; => Array of values = MEAN(data)
zerotimes = 0d0           ; => Times associated with zeroarray

frequency = DOUBLE(zerocrossings/2)/evlength
zeroarray = REPLICATE(meanval[0],SIZE(zc_index0,/N_ELEMENTS))
zerotimes = tt[zc_index0]
;-----------------------------------------------------------------------------------------
; => Print, out relevant quantities if desired
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(nom) THEN BEGIN
  PRINT,'Mean Value:  '+STRTRIM(STRING(meanval[0],FORMAT='(f15.2)'),2)
  PRINT,'# of ZCs:  '+STRTRIM(STRING(zerocrossings[0],FORMAT='(I)'),2)
;  PRINT,'ZC Spread:  '+
  PRINT,'ZC STDEV Spread:  '+STRTRIM(STRING(std_zc_spread[0],FORMAT='(f15.2)'),2)
  PRINT,'ZC Mean Spread:  '+STRTRIM(STRING(mean_zc_spread[0],FORMAT='(f15.2)'),2)
  PRINT,'ZC Full Quality:  '+STRTRIM(STRING(quality[0],FORMAT='(f15.2)'),2)
  PRINT,'ZC Inner STDEV Spread:  '+STRTRIM(STRING(std_zc_inner_spread[0],FORMAT='(f15.2)'),2)
  PRINT,'ZC Inner Mean Spread:  '+STRTRIM(STRING(mean_zc_inner_spread[0],FORMAT='(f15.2)'),2)
  PRINT,'ZC Inner Quality:  '+STRTRIM(STRING(zc_inner_quality[0],FORMAT='(f15.2)'),2)
ENDIF
;-----------------------------------------------------------------------------------------
; => Return structure
;-----------------------------------------------------------------------------------------
tags = ['FREQUENCY','NUM_ZERO_CROSSINGS','ZERO_CROSSING_POINTS','ZC_SPREAD',$
        'ZC_QUALITY','GTR_INDEX','MID_INDEX','LOW_INDEX','LOGIC_ARRAY',     $
        'ZERO_ARRAY','ZC_INNER_SPREAD']
stru = CREATE_STRUCT(tags,frequency,zerocrossings,zc_index,zc_spread,quality,     $
                     gtindex,gmidindex,ltindex,keyarray,{X:zerotimes,Y:zeroarray},$
                     zc_inner_spread)

RETURN,stru
END



