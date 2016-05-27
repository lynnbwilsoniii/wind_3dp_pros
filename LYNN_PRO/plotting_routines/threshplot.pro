;+
;*****************************************************************************************
;
;  FUNCTION :   threshplot.pro
;  PURPOSE  :   This program plots the results of zero_crossings.pro in an easily
;                 viewable format.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               zero_crossings.pro
;               minmax.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               TIMES   :  N-Element array of times associated with DATA
;               DATA    :  N-Element array of data that presumably fluctuates about zero
;
;  EXAMPLES:    
;               threshplot,times,data,THRESH=0.25
;
;  KEYWORDS:    
;               THRESH  :  Scalar percentage of the maximum absolute value of the input
;                            DATA you wish to consider as a threshold deviation from
;                            zero before considering the change a "zero-crossing"
;
;   CHANGED:  1)  Fixed typo                                        [09/18/2009   v1.0.1]
;             2)  Added keywords:  TITLE, YTITLE, YRANGE0, YRANGE1  [09/18/2009   v1.1.0]
;             3)  Changed some syntax and cleaned up a few things   [10/01/2009   v1.1.1]
;
;   NOTES:      
;               1)  This program is a direct adaptation of a routine by K. Kersten,
;                     threshplot.pro version ?.?.?.  
;               2)  Though it is NOT necessary to have your TIMES input array in any
;                     particular set of units, one should be careful to note that the
;                     output frequency will change depending on the input units, of
;                     course.
;
;   CREATED:  09/17/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/01/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO threshplot,times,data,THRESH=thresh,TITLE=title,YTITLE=ytitle,YRANGE0=yrange0,$
                          YRANGE1=yrange1

;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
time       = REFORM(times)
npoints    = N_ELEMENTS(REFORM(data))
data_2     = REFORM(data)
mv_temp    = data_2
;mv_temp    = SMOOTH(REFORM(data),npoints/16L,/NAN,/EDGE_TRUNCATE)

evlength   = MAX(time,/NAN) - MIN(time,/NAN)
nsps       = (npoints - 1L)/evlength
timeseries = mv_temp[0:(npoints - 1L)]   ; => Data
;-----------------------------------------------------------------------------------------
; => zero crossings
;=========================================================================================
JUMP_TRY_AGAIN:
;=========================================================================================
; => Determine mean, peak, and threshold values
;-----------------------------------------------------------------------------------------
meanval    = (MEAN(timeseries,/NAN))[0]
peakval    = (MAX([ABS(timeseries-meanval)],/NAN))[0]
IF NOT KEYWORD_SET(thresh) THEN BEGIN
  thfac = 25d-2
ENDIF ELSE BEGIN
  IF (DOUBLE(thresh) LT 1d0) THEN thfac = DOUBLE(thresh[0]) ELSE thfac = 25d-2
ENDELSE
;-----------------------------------------------------------------------------------------
; => Calculate zero crossings and stats
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
gttimes         = 0d0     ; => Array of times where data is above the positive threshold
midtimes        = 0d0     ; => Array of times where data is between the two thresholds
lttimes         = 0d0     ; => Array of times where data is below the negative threshold
gtseries        = 0d0     ; => Array of data where data is above the positive threshold
midseries       = 0d0     ; => Array of data where data is above the positive threshold
ltseries        = 0d0     ; => Array of data where data is above the positive threshold

zcs             = zero_crossings(time,timeseries,THRESH=thfac)

gtindex         = zcs.GTR_INDEX
ltindex         = zcs.LOW_INDEX
midindex        = zcs.MID_INDEX
zerocrossings   = zcs.NUM_ZERO_CROSSINGS
keyarray        = zcs.LOGIC_ARRAY
zeroarray       = zcs.ZERO_ARRAY.Y
zerotimes       = zcs.ZERO_ARRAY.X
zc_index        = zcs.ZERO_CROSSING_POINTS
zc_inner_spread = zcs.ZC_INNER_SPREAD
newseriesindex  = [gtindex,ltindex]
newseriesindex  = newseriesindex[SORT(newseriesindex)]

; => Calculate slope of 1/zc_inner_spread ( ~ frequency vs. time)
dummyarray = LINDGEN(SIZE(zc_inner_spread,/N_ELEMENTS))
; => cubic fit...
freq_time  = 1d0/zc_inner_spread*(nsps/2d0)
;freq_time  = 1d0/time[zc_inner_spread]
spreadfit  = POLY_FIT(dummyarray,freq_time,3,CHISQ=zcchisq,/DOUBLE,YFIT=spfitv)


gttimes   = REPLICATE(d,npoints)
midtimes  = REPLICATE(d,npoints)
lttimes   = REPLICATE(d,npoints)
gtseries  = REPLICATE(f,npoints)
midseries = REPLICATE(f,npoints)
ltseries  = REPLICATE(f,npoints)
; => Data above threshold
gttimes[gtindex]   = time[gtindex]
gtseries[gtindex]  = timeseries[gtindex]
; => Data below threshold
lttimes[ltindex]   = time[ltindex]
ltseries[ltindex]  = timeseries[ltindex]
; => Data with ABS() < threshold
midtimes[midindex]  = time[midindex]
midseries[midindex] = timeseries[midindex]
; => Data on either side of threshold but NOT in between
new_times  = REPLICATE(d,npoints)
new_series = REPLICATE(f,npoints)
new_times[newseriesindex]  = time[newseriesindex]
new_series[newseriesindex] = timeseries[newseriesindex]



; => Calculate X and Y-Axis range for plots
myXRANGE  = minmax(time)
myYRANGE  = [-1d0,1d0]*11d-1*peakval[0]
;-----------------------------------------------------------------------------------------
; => Set up plots
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(title)   THEN ttle = 'Zero Crossings vs. Time' ELSE ttle = title
IF NOT KEYWORD_SET(ytitle)  THEN yttl = ''                        ELSE yttl = ytitle
IF NOT KEYWORD_SET(yrange0) THEN yra0 = myYRANGE                  ELSE yra0 = yrange0
IF NOT KEYWORD_SET(yrange1) THEN BEGIN
  yrmx1 = MAX(ABS([freq_time,spfitv]),/NAN)*11d-1
  yrmn1 = MIN(ABS([freq_time,spfitv]),/NAN)/11d-1
  yra1  = [yrmn1,yrmx1]
ENDIF ELSE BEGIN
  yra1 = yrange1
ENDELSE

!P.CHARSIZE     = 1.5
!P.MULTI        = [0,1,3]

xxo = FINDGEN(17)*(!PI*2./16.)
USERSYM,0.2*COS(xxo),0.2*SIN(xxo),/FILL

lim0            = {XRANGE:myxrange,YRANGE:yra0,XSTYLE:1,YSTYLE:1,NODATA:1,$
                   TITLE:ttle,YTITLE:yttl}

scaled_mean_log = 5d-1*peakval*keyarray + meanval
;-----------------------------------------------------------------------------------------
; => Plot data
;-----------------------------------------------------------------------------------------
PLOT,time,timeseries,_EXTRA=lim0
  OPLOT,gttimes,gtseries,LINESTYLE=4,COLOR=250
  OPLOT,lttimes,ltseries,LINESTYLE=4,COLOR=250
  OPLOT,midtimes,midseries,LINESTYLE=4,COLOR=50
;  OPLOT,gttimes,gtseries,PSYM=8,SYMSIZE=2.0,COLOR=250
;  OPLOT,lttimes,ltseries,PSYM=8,SYMSIZE=2.0,COLOR=250
;  OPLOT,midtimes,midseries,PSYM=8,SYMSIZE=2.0,COLOR=50
  USERSYM,0.10*COS(xxo),0.10*SIN(xxo),/FILL
  OPLOT,time,scaled_mean_log,PSYM=8,SYMSIZE=2.0

USERSYM,0.2*COS(xxo),0.2*SIN(xxo),/FILL
lim1            = {XRANGE:myxrange,YRANGE:yra0,XSTYLE:1,YSTYLE:1,$
                   NODATA:1,TITLE:ttle,YTITLE:yttl}
PLOT,new_times,new_series,_EXTRA=lim1
  OPLOT,new_times,new_series,LINESTYLE=4
;  OPLOT,time[newseriesindex],timeseries[newseriesindex],PSYM=8,SYMSIZE=2.0,COLOR=50
  USERSYM,0.10*COS(xxo),0.10*SIN(xxo),/FILL
  OPLOT,time,scaled_mean_log,PSYM=8,SYMSIZE=2.0
;  OPLOT,time,scaled_mean_log,PSYM=3,SYMSIZE=2.0
  OPLOT,zerotimes,zeroarray,PSYM=2

lim2 = {XSTYLE:1,YSTYLE:1,NODATA:1,MIN_VALUE:1e2,YLOG:1,$
        YTITLE:'Frequency',YRANGE:yra1}
PLOT,dummyarray,freq_time,PSYM=2,_EXTRA=lim2
  OPLOT,dummyarray,freq_time,LINESTYLE=4,COLOR=50
  OPLOT,dummyarray,freq_time,PSYM=2
  OPLOT,dummyarray,spfitv,LINESTYLE=4

END

