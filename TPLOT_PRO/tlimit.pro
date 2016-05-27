;+
;*****************************************************************************************
;
;  FUNCTION :   tlimit.pro
;  PURPOSE  :   This routine defines time range for TPLOT either dynamically using the
;                 cursor location from a mouse input or a user specifying the
;                 appropriate values correctly.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               str_element.pro
;               ctime.pro
;               time_double.pro
;               wi.pro
;               tplot.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               D1  :  Scalar defining the start time in formats accepted by 
;                        time_struct.pro
;               D2  :  Scalar defining the end time in formats accepted by 
;                        time_struct.pro
;               ** both inputs are optional if TPLOT window open **
;
;  EXAMPLES:    
;               tlimit                     ; Use the cursor
;               tlimit,'12:30','14:30'
;               tlimit, 12.5, 14.5
;               tlimit,'1995-04-05/12:30:00','1995-04-07/14:30:00'
;               tlimit,['1995-04-05/12:30:00','1995-04-07/14:30:00']
;               tlimit,t,t+3600            ; t must be set previously
;               tlimit,/FULL               ; full limits
;               tlimit,/LAST               ; previous limits
;
;  KEYWORDS:    
;               DAYS       :  If set, the resolution is in # of days
;               HOURS      :  " " hours
;               MINUTES    :  " " minutes
;               SECONDS    :  " " seconds
;               FULL       :  If set, program resets current TPLOT window to the full
;                               time range stored in the TPLOT common blocks
;               LAST       :  If set, program resets current TPLOT window to the last
;                               time range stored in the TPLOT common blocks
;               ZOOM       :  Scalar fraction defining the fractional width of the
;                               current time range to use for new window
;               REFDATE    :  String reference date for time series ['YYYY-MM-DD']
;               OLD_TVARS  :  Use this to pass an existing tplot_vars structure to
;                               override the one in the tplot_com common block.
;               NEW_TVARS  :  Returns the tplot_vars structure for the plot created.
;                               Set aside the structure so that it may be restored
;                               using the OLD_TVARS keyword later. This structure
;                               includes information about various TPLOT options and
;                               settings and can be used to recreates a plot.
;               WINDOW     :  Window to be used for all time plots.  If set to
;                               -1, then the current window is used.
;               SILENT     :  If set, prompt will not print out X/Y values associated
;                               with location of cursor on window.
;                               [Default = 1 for Windows, 0 for all others]
;
;   CHANGED:  1)  ?? Davin changed something                       [08/06/1998   v1.0.26]
;             2)  Re-wrote and cleaned up                          [12/07/2010   v1.1.0]
;             3)  Updated to be in accordance with newest version of tlimit.pro
;                   in TDAS IDL libraries
;                   A)  no longer calls gettime.pro [now calls time_double.pro]
;                   B)  no longer uses () for arrays
;                   C)  new keyword:  SILENT
;                                                                  [03/27/2012   v1.2.0]
;
;   NOTES:      
;               1)  tplot must be called first
;               2)  See also time_struct.pro, time_double.pro, or time_string.pro
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  12/07/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO tlimit,d1,d2,                          $
                 DAYS      = days,      $
                 HOURS     = hours,     $
                 MINUTES   = minutes,   $
                 SECONDS   = seconds,   $
                 FULL      = full,      $
                 LAST      = last,      $
                 ZOOM      = zoom,      $
                 REFDATE   = refdate,   $
                 OLD_TVARS = old_tvars, $
                 NEW_TVARS = new_tvars, $
                 WINDOW    = window,    $
                 SILENT    = silent

;-----------------------------------------------------------------------------------------
; => Load common blocks
;-----------------------------------------------------------------------------------------
@tplot_com.pro
common times_dats, t
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(old_tvars) THEN tplot_vars = old_tvars
IF (SIZE(refdate,/TYPE) EQ 7) THEN str_element,tplot_vars,'OPTIONS.REFDATE',refdate,/ADD_REPLACE
; if silent keyword is not explicitly set or set to zero, default behavior
; is silent for windows, not silent for others.
IF (SIZE(silent,/TYPE) EQ 0) THEN silent = (!VERSION.OS_FAMILY EQ 'Windows')

n = N_PARAMS()
; => Determine current settings
str_element,tplot_vars,'OPTIONS.TRANGE',trange
str_element,tplot_vars,'OPTIONS.TRANGE_FULL',trange_full
str_element,tplot_vars,'SETTINGS.TRANGE_OLD',trange_old
str_element,tplot_vars,'SETTINGS.TIME_SCALE',time_scale
str_element,tplot_vars,'SETTINGS.TIME_OFFSET',time_offset

temp         = trange
;   TDAS update
;tr         = tplot_vars.SETTINGS.X.CRANGE * time_scale + time_offset
tpv_set_tags = TAG_NAMES(tplot_vars.SETTINGS)
idx = WHERE(tpv_set_tags EQ 'X',icnt)
IF (icnt GT 0) THEN BEGIN
  ; => define time range
  tr = tplot_vars.SETTINGS.X.CRANGE * time_scale + time_offset
ENDIF ELSE BEGIN
  RETURN
ENDELSE
;-----------------------------------------------------------------------------------------
; => Check keywords which affect time range without input or cursors
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(zoom) THEN BEGIN
  tmid   = (tr[0] + tr[1])/2
  tdif   = (tr[1] - tr[0])/2
  trange = tmid + zoom*[-tdif,tdif]
  n = -1
ENDIF

IF KEYWORD_SET(full) THEN BEGIN
  trange = trange_full
  n = -1
ENDIF

IF KEYWORD_SET(last) THEN BEGIN
  trange = trange_old
  n = -1
ENDIF
;-----------------------------------------------------------------------------------------
; => Check keywords which affect time range with cursors or input
;-----------------------------------------------------------------------------------------
IF (n EQ 0) THEN BEGIN
  ctime,t,NPOINTS=2,PROMPT="Use cursor to select a begin time and an end time",$
    HOURS=hours,MINUTES=minutes,SECONDS=seconds,DAYS=days,SILENT=silent
  IF (N_ELEMENTS(t) NE 2) THEN RETURN
  t1 = t[0]
  t2 = t[1]
  delta = tr[1] - tr[0]
  CASE 1 OF
    (t1 LT tr[0]) AND (t2 GT tr[1]) : trange = trange_full      ; full range
    (t1 GT tr[1]) AND (t2 GT tr[1]) : trange = tr + delta       ; pan right
    (t1 LT tr[0]) AND (t2 LT tr[0]) : trange = tr - delta       ; pan left
    (t2 LT t1   )                   : trange = trange_old       ; last limits
;    t2 gt tr(1):                      trange = tr + (t1-tr(0))  ; pan right
;    t1 lt tr(0):                      trange = tr + (tr(1)-t2)  ; pan left
    ELSE                            : trange = [t1,t2]          ; new range
  ENDCASE
ENDIF
;-----------------------------------------------------------------------------------------
; => Redefine time range
;-----------------------------------------------------------------------------------------
IF (n EQ 1) THEN BEGIN
  ; => One input supplied
  IF (N_ELEMENTS(d1) EQ 2) THEN BEGIN
    ; => Input is 2-element array
    trange = time_double(d1)
;   TDAS update
;    trange = gettime(d1)
  ENDIF ELSE BEGIN
    ; => Input is 2-element array
    ;   => Create 2nd element
    trange = [time_double(d1), time_double(d1) + (tr[1] - tr[0])]
;   TDAS update
;    trange = [gettime(d1), gettime(d1) + (tr[1] - tr[0])]
  ENDELSE
ENDIF
IF (n EQ 2) THEN trange = time_double([d1,d2])
;   TDAS update
;IF (n EQ 2) THEN trange = gettime([d1,d2])
;-----------------------------------------------------------------------------------------
; => Redefine common block TPLOT plotting parameters/options
;-----------------------------------------------------------------------------------------
str_element,tplot_vars,'OPTIONS.TRANGE',trange,/ADD_REPLACE
str_element,tplot_vars,'OPTIONS.TRANGE_FULL',trange_full,/ADD_REPLACE
str_element,tplot_vars,'SETTINGS.TRANGE_OLD',trange_full,/ADD_REPLACE
str_element,tplot_vars,'SETTINGS.WINDOW',old_window
;-----------------------------------------------------------------------------------------
; => If WINDOW is set, plot new time range in new window otherwise just replot data
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(window) THEN wi,window
tplot,WINDOW=window
str_element,tplot_vars,'SETTINGS.TRANGE_OLD',temp,/ADD_REPLACE
new_tvars = tplot_vars

RETURN
END

