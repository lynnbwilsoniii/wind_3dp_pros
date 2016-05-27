;+
;*****************************************************************************************
;
;  FUNCTION :   time_ticks.pro
;  PURPOSE  :   Returns a structure that can be used to create time ticks for a plot.
;
;  CALLED BY:   
;               tplot.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               dtime.pro
;               time_string.pro
;               minmax.pro
;               time_double.pro
;               time_struct.pro
;
;  REQUIRES:    
;               1)  SPEDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TIMERANGE     :  [2]-Element [numeric] array specifying the time range
;                                  of the plot.  This input can be obtained from:
;                                  "time_double", "time_struct", or "time_string"
;               OFFSET        :  Set to a named variable to return the time offset
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               HELP          :  If set, program stops (doesn't help)
;               TICKINTERVAL  :  Time between X-Axis major tick marks
;               SIDE_LABEL    :  Label used to define the X-Axis times shown
;               LOCAL_TIME    :  If set, then local time is displayed
;               XTITLE        :  Scalar [string] defining the X-Axis title
;               NUM_LAB_MIN   :  Scalar [long] defining the minimum number of labels for
;                                  bottom axis
;
;   CHANGED:  1)  Davin Larson changed something...
;                                                                   [04/17/2002   v1.0.16]
;             2)  Re-wrote and cleaned up
;                                                                   [04/20/2009   v1.1.0]
;             3)  Updated man page
;                                                                   [06/17/2009   v1.1.1]
;             4)  Changed program my_time_struct.pro to time_struct.pro
;
;                                                                   [09/17/2009   v1.2.0]
;             5)  Fixed typo which seemed to only affect long (> 1 month) time
;                   ranges
;                                                                   [03/16/2010   v1.3.0]
;             6)  Updated to be in accordance with newest version of time_ticks.pro
;                   in TDAS IDL libraries [thmsw_r10908_2012-09-10]
;                   A)  Cleaned up and added some comments
;                   B)  new keyword:  LOCAL_TIME
;                   C)  no longer uses () for arrays
;                                                                   [04/04/2012   v1.4.0]
;             7)  Cleaned up a little
;                                                                   [09/12/2012   v1.4.1]
;             8)  Updated Man. page and updated to be in accordance with SPEDAS version
;                   last modified on Jan. 8, 2016
;                                                                   [02/04/2016   v1.4.2]
;
;   NOTES:      
;               1)  **WARNING!**
;                     This routine does not yet work on very small time scales.
;               2)  The returned time_tk_str has tags named so that it can be used
;                     with the special _EXTRA keyword in the call to PLOT or OPLOT.
;               3)  The offset value that is returned from timetick must be
;                     subtracted from the time-axis data values before plotting.
;                     This is to maintain resolution in the PLOT routines, which use
;                     single precision floating point internally.  Remember that if
;                     the CURSOR routine is used to read a cursor position from the
;                     plot, this offset will need to be added back to the time-axis
;                     value to get seconds since  1970-01-01/00:00:00.
;
;  REFERENCES:  
;               NA
;
;   CREATED:  Oct, 1996
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  02/04/2016   v1.4.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION time_ticks,timerange,offset,HELP=help,TICKINTERVAL=tickinterval,$
                       SIDE_LABEL=side_string,LOCAL_TIME=local_time,     $
                       XTITLE=xtitle,NUM_LAB_MIN=num_lab_min

;;----------------------------------------------------------------------------------------
;;  Define default parameters
;;----------------------------------------------------------------------------------------
units          = ['YEAR','MONTH','DATE','HOUR','MINUTE','SECOND','MILLISECOND',$
                  'MICROSECOND','NANOSECOND']
labels         = ['Year','Year','Month','Date','hhmm','Seconds','Seconds','Date',$ 
                  'Seconds','!4l!Xs','ns']

d              = 36d2 * 24d0  ;;  seconds/day
;;                  sec/year    /month  /day  /hour  /min /sec ... etc.
dtime          = [36525d-2*d,  3d1*d,   d,    36d2,  6d1, 1d0,1d-3,1d-6,1d-9]
pos            = [0, 0, 5, 9, 12, 17, 19, 5, 19, 23, 26]
width          = [0, 4, 3, 2,  4,  2,  4, 6,  4, 3, 3]

yyyy           = 1
mmm            = 2
dd             = 3
hhmm           = 4
ss             = 5
iii            = 8
jjj            = 9
kkk            = 10
mmm_dd         = 7
;;  Define a dummy tick format
tick_format = {tick_info,DT:0d0,UNIT:0,INC:1,NMINOR:0,FLD1:0,UNIT2:0,FLD2:0}
;;----------------------------------------------------------------------------------------
;;  Determine default parameters
;;----------------------------------------------------------------------------------------
;;                    DT  Unit Inc NMin  Fld1  Unit2  Fld2
setup = [ $
         {tick_info, 0d0,  0,1000, 10, yyyy   , 0,  0     }, $
         {tick_info, 0d0,  0, 500,  5, yyyy   , 0,  0     }, $
         {tick_info, 0d0,  0, 200,  2, yyyy   , 0,  0     }, $
         {tick_info, 0d0,  0, 100, 10, yyyy   , 0,  0     }, $
         {tick_info, 0d0,  0,  50,  5, yyyy   , 0,  0     }, $
         {tick_info, 0d0,  0,  20,  2, yyyy   , 0,  0     }, $
         {tick_info, 0d0,  0,  10, 10, yyyy   , 0,  0     }, $
         {tick_info, 0d0,  0,   5,  5, yyyy   , 0,  0     }, $
         {tick_info, 0d0,  0,   2,  2, yyyy   , 0,  0     }, $
         {tick_info, 0d0,  0,   1, 12, yyyy   , 0,  0     }, $
         {tick_info, 0d0,  1,   6,  6, mmm    , 0,  yyyy  }, $
         {tick_info, 0d0,  1,   4,  4, mmm    , 0,  yyyy  }, $
         {tick_info, 0d0,  1,   3,  3, mmm    , 0,  yyyy  }, $
         {tick_info, 0d0,  1,   2,  2, mmm    , 0,  yyyy  }, $
         {tick_info, 0d0,  1,   1,  2, mmm    , 0,  yyyy  }, $
         {tick_info, 0d0,  2,  20, 20, mmm_dd , 0,  yyyy  }, $
         {tick_info, 0d0,  2,  10, 10, mmm_dd , 0,  yyyy  }, $
         {tick_info, 0d0,  2,   5,  5, dd     , 1,  mmm   }, $
         {tick_info, 0d0,  2,   2,  2, dd     , 1,  mmm   }, $
         {tick_info, 0d0,  2,   1,  4, dd     , 1,  mmm   }, $
         {tick_info, 0d0,  3,  12, 12, hhmm   , 2,  mmm_dd}, $
         {tick_info, 0d0,  3,   8,  8, hhmm   , 2,  mmm_dd}, $
         {tick_info, 0d0,  3,   4,  4, hhmm   , 2,  mmm_dd}, $
         {tick_info, 0d0,  3,   2,  2, hhmm   , 2,  mmm_dd}, $
         {tick_info, 0d0,  3,   1,  6, hhmm   , 2,  mmm_dd}, $
         {tick_info, 0d0,  4,  30,  3, hhmm   , 2,  mmm_dd}, $
         {tick_info, 0d0,  4,  20,  2, hhmm   , 2,  mmm_dd}, $
         {tick_info, 0d0,  4,  10, 10, hhmm   , 2,  mmm_dd}, $
         {tick_info, 0d0,  4,   5,  5, hhmm   , 2,  mmm_dd}, $
         {tick_info, 0d0,  4,   2,  2, hhmm   , 2,  mmm_dd}, $
         {tick_info, 0d0,  4,   1,  6, hhmm   , 2,  mmm_dd}, $
         {tick_info, 0d0,  5,  30,  6, ss     , 4,  hhmm  }, $
         {tick_info, 0d0,  5,  20,  4, ss     , 4,  hhmm  }, $
         {tick_info, 0d0,  5,  10, 10, ss     , 4,  hhmm  }, $
         {tick_info, 0d0,  5,   5,  5, ss     , 4,  hhmm  }, $
         {tick_info, 0d0,  5,   2,  2, ss     , 4,  hhmm  }, $
         {tick_info, 0d0,  5,   1, 10, ss     , 4,  hhmm  }, $
         {tick_info, 0d0,  6, 200,  2, iii    , 5,  ss    }, $
         {tick_info, 0d0,  6, 100, 10, iii    , 5,  ss    }, $
         {tick_info, 0d0,  6,  50,  5, iii    , 5,  ss    }, $
         {tick_info, 0d0,  6,  20,  2, iii    , 5,  ss    }, $
         {tick_info, 0d0,  6,  10, 10, iii    , 5,  ss    }, $
         {tick_info, 0d0,  6,   5,  5, iii    , 5,  ss    }, $
         {tick_info, 0d0,  6,   2,  2, iii    , 5,  ss    }, $
         {tick_info, 0d0,  6,   1, 10, iii    , 5,  ss    }, $
         {tick_info, 0d0,  7, 200,  2, jjj    , 5,  ss    }, $
         {tick_info, 0d0,  7, 100, 10, jjj    , 5,  ss    }, $
         {tick_info, 0d0,  7,  50,  5, jjj    , 5,  ss    }, $
         {tick_info, 0d0,  7,  20,  2, jjj    , 5,  ss    }, $
         {tick_info, 0d0,  7,  10, 10, jjj    , 5,  ss    }, $
         {tick_info, 0d0,  7,   5,  5, jjj    , 5,  ss    }, $
         {tick_info, 0d0,  7,   2,  2, jjj    , 5,  ss    }, $
         {tick_info, 0d0,  7,   1,  2, jjj    , 5,  ss    }  $
]
n              = N_ELEMENTS(setup)
setup.DT       = dtime[setup.UNIT] * setup.INC
;setup.DT       = dtime(setup.UNIT) * setup.INC
;;----------------------------------------------------------------------------------------
;;  Define tick marks
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(help) THEN BEGIN
;  s = time_string(8.3d8,/format)
  s = time_string(8.3d8,/FORMAT)
  PRINT,s
  FOR I=0L, N_ELEMENTS(pos) - 1L DO PRINT,';',i,'  <',STRMID(s,pos[i],width[i]),'>'
  RETURN,setup.DT
ENDIF
;;  Find the time range
range          = minmax( time_double(timerange) )
;;  Determine the number of tick labels
IF NOT KEYWORD_SET(num_lab_min) THEN  num_lab_min = 3.

IF KEYWORD_SET(tickinterval) THEN BEGIN
  ;;  User defined time [s] between tick marks
  deltatime = tickinterval[0]
;  deltatime = tickinterval
ENDIF ELSE BEGIN
  ;;  Defined time [s] between tick marks
;  deltatime = (range[1] - range[0])/num_lab_min
  deltatime = (range[1] - range[0])/num_lab_min[0]
ENDELSE

;w = WHERE(setup.DT LE deltatime,count)
;IF (count EQ 0L) THEN BEGIN
w              = WHERE(setup.DT LE deltatime[0],count)
IF (count[0] EQ 0L) THEN BEGIN
  MESSAGE,'Time range too small',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;  Define index to use for time ticks
i              = w[0]

IF (i LT 0L) THEN BEGIN
  ;;  something wrong --> debug
  x  = ALOG10(deltatime)
  e  = FLOOR(x)
  n  = [1,2,5]
  n  = n[FIX((x - e)*3)]
  dt = n * 10d0^e
  HELP,deltatime,n,e,dt
  STOP
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define parameters from structure
;;----------------------------------------------------------------------------------------
set            = setup[i]
unit           = set.UNIT[0]                                      ;;  defines resolution to use in ticks
inc            = set.INC
fld1           = set.FLD1
fld2           = set.FLD2

;;  TDAS Update
;st   = time_struct(range[0])
st             = time_struct(range[0],LOCAL_TIME=local_time)      ;;  start time
;;  SPEDAS Update
;st   = {YEAR:st.YEAR, MONTH:st.MONTH,DATE:st.DATE,HOUR:st.HOUR, $
;        MIN:st.MIN,SEC:st.SEC,MS:0,MIS:0,NS:0,FSEC:st.FSEC,     $
;        DAYNUM:st.DAYNUM,DOY:st.DOY,DOW:st.DOW,SOD:st.SOD}
st             = {YEAR:st.YEAR,MONTH:st.MONTH,DATE:st.DATE,HOUR:st.HOUR,$
                  MIN:st.MIN,SEC:st.SEC,MS:0,MIS:0,NS:0,FSEC:st.FSEC,   $
                  DAYNUM:st.DAYNUM,DOY:st.DOY,DOW:st.DOW,SOD:st.SOD,    $
                  DST:st.DST,TZONE:st.TZONE,TDIFF:st.TDIFF}
;; Define ms, µs, and ns
st.MS          = FIX(st.FSEC*1000)                                          ;;  Milliseconds
st.MIS         = FIX(st.FSEC*1d6 - 1d3*DOUBLE(st.MS))                       ;;  Microseconds
st.NS          = FIX(st.FSEC*1d9 - 1d6*DOUBLE(st.MS) - 1d3*DOUBLE(st.MIS))  ;;  Nanoseconds

clear          = [0,1,1,0,0,0,0,0,0,0,0,0,0,0,0]
st.(unit)      = FLOOR((st.(unit) - clear[unit])/inc)*inc + clear[unit]
FOR i=unit[0] + 1L, 9L DO st.(i) = clear[i]


;;  TDAS Update
;nst        = 30
nst            = 60
sts            = REPLICATE(st,nst)
;;  SPEDAS Update
;sts.(unit) = sts.(unit) + INDGEN(nst)*inc
sts.(unit)     = sts.(unit) + LINDGEN(nst)*inc
sts.FSEC       = 0d
FOR i=6L, 8L DO sts.FSEC += sts.(i)*10d0^(-(i-5)*3)
;;----------------------------------------------------------------------------------------
;;  Define Unix time and offset from zero
;;----------------------------------------------------------------------------------------
times          = time_double(sts)
offset         = times[0]
;;  Check for XTITLE
IF (SIZE(xtitle,/TYPE) NE 7) THEN xtitle = ''
xtitle = '!C'+xtitle

;;  Determine times within time range
w              = WHERE(times GE range[0] AND times LE range[1],nlabs)
IF (nlabs LE 1) THEN STOP
times          = times[w]
;  TDAS Update
;struct      = time_struct(times)
;strings     = time_string(struct,/FORMAT,PREC=10)
struct         = time_struct(times,LOCAL_TIME=local_time)
strings        = time_string(struct,/FORMAT,PREC=10,LOCAL_TIME=local_time)

strings1       = STRMID(strings,pos[fld1],width[fld1])
strings2       = STRMID(strings,pos[fld2],width[fld2])
side_string    = ''

IF (fld2 NE 0) THEN BEGIN
  ;;  Determine 2nd level string outputs
  u   = set.UNIT2
  ch  = struct.(u)
  dch = ch - SHIFT(ch,1)
  w = WHERE(dch EQ 0,count0)
  IF (count0 NE 0) THEN  strings2[w] = ''
  w = WHERE(dch NE 0,count1)
  IF (count1 EQ 0) THEN BEGIN
    ;;  high level does change
    side_string = STRMID(strings[0],0,pos[fld1])
  ENDIF ELSE BEGIN
    ;;  high level does not change (full string)
    side_string = STRMID(strings[0],0,pos[fld2])
  ENDELSE
ENDIF
str            = strings1+'!C'+strings2
side_string    = labels[fld1]+'!C'+side_string
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
tick_str       = {XTICKNAME:str,XTICKV:times-offset[0],XTICKS:N_ELEMENTS(times)-1L, $
                  XMINOR:set.NMINOR,XRANGE:range-offset[0],XSTYLE:1,XTITLE:xtitle}
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,tick_str
END
