;+
;*****************************************************************************************
;
;  FUNCTION :   time_range_find.pro
;  PURPOSE  :   Routine prompts user to specify either a date or a time range.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               time_double.pro
;               time_struct.pro
;               time_string.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               test = time_range_find(/YDATE)
;
;  KEYWORDS:    
;               YDATE   :  If set, program prompts user for a date of interest and then
;                            defines a time range: 
;                            [YYYY-MM-DD/00:00:00,YYYY-MM-DD/23:59:59]
;               YTRAN   :  If set, program prompts user for a time range with the
;                            input format of:  'YYYY-MM-DD/hh:mm:ss'
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Default is to use YDATE
;               2)  ** Still working on this **
;
;   CREATED:  06/23/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/23/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION time_range_find,YDATE=ydate,YTRAN=ytran

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
tdate  = ''              ; => Date 'YYYY-MM-DD'
sdate  = ''              ; => Date 'MMDDYY'
st_st  = ''              ; => Time 'YYYY-MM-DD/hh:mm:ss'
st_et  = ''              ; => Time 'YYYY-MM-DD/hh:mm:ss'
tr_str = ''              ; => Time Range 'YYYY-MM-DD/hh:mm:ss'
trange = 0d0             ; => Time Range as Unix times
tags   = ['S_DATE_SE','TDATE_SE','TR_STRING','TR_UNIX']


IF KEYWORD_SET(ydate) THEN yd = 1 ELSE yd = 0
IF KEYWORD_SET(ytran) THEN yt = 1 ELSE yt = 0
test  = (yd AND yt) OR ((yd EQ 0) AND (yt EQ 0))
IF (test) THEN BEGIN
  ; => can't use both at the same time
  yd = 1
  yt = 0
ENDIF

good  = WHERE([yd,yt],gd)

CASE good[0] OF
  0L   : BEGIN
    ; => Date
    mydate   = my_str_date()
    sdate    = mydate.S_DATE[0]      ; => 'MMDDYY'
    tdate    = mydate.TDATE[0]       ; => 'YYYY-MM-DD'
    tr_str   = tdate[0]+'/'+['00:00:00.0000','23:59:59.9999']
    trange   = time_double(tr_str)
    tdate    = [tdate[0],tdate[0]]
    sdate    = [sdate[0],sdate[0]]
  END
  1L   : BEGIN
    ; => Time Range
    
    ; => NEED:  **routine to check format of input**
    READ,st_st,PROMPT='Enter a start time [YYYY-MM-DD/hh:mm:ss]: '
    READ,st_et,PROMPT='Enter an end  time [YYYY-MM-DD/hh:mm:ss]: '
    temp     = [st_st[0],st_et[0]]+'.0000'
    temp2    = time_struct(temp)
    tdate    = STRING(FORMAT='(I4.4)',temp2.YEAR)+'-'+$
               STRING(FORMAT='(I2.2)',temp2.MONTH)+'-'+$
               STRING(FORMAT='(I2.2)',temp2.DATE)
    sdate    = STRMID(tdate[*],5L,2L)+STRMID(tdate[*],8L,2L)+STRMID(tdate[*],0L,2L)
    tr_str   = time_string(temp2,PREC=4)
    trange   = time_double(tr_str)
  END
  ELSE : BEGIN
    ; => do not know how you managed this
    tdate    = ['','']
    sdate    = ['','']
    tr_str   = ['','']
    trange   = REPLICATE(0d0,2L)
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Define return structure
;-----------------------------------------------------------------------------------------
struc    = CREATE_STRUCT(tags,sdate,tdate,tr_str,trange)

RETURN,struc
END