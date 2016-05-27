;+
;*****************************************************************************************
;
;  FUNCTION :   my_str_date.pro
;  PURPOSE  :   Creates a structure of dates in different formats:
;                 S_DATE : 'MMDDYY'
;                 DATE   : 'YYYYMMDD'
;                 TDATE  : 'YYYY-MM-DD'
;                 L_YYYY : 'YYYY'
;                 YY     : 'YY'
;                 MM     : 'MM'
;                 DD     : 'DD'
;
;  CALLED BY:   
;               NA
;
;  CALLS:       
;               NA
;
;  REQUIRES:   
;                NA
;
;  INPUT:       
;               NA
;
;  EXAMPLES:
;               date   = '021096'
;               mydate = my_str_date(DATE=date)
;               mdate  = mydate.DATE    ; => '19960210'
;               or
;               year   = '96'
;               month  = '02'
;               day    = '10'
;               mydate = my_str_date(YEAR=year,MONTH=month,DAY=day)
;               mdate  = mydate.DATE    ; => '19960210'
;
;  KEYWORDS:  
;               YEAR    :  'YYYY'   [e.g. '1996']
;               MONTH   :  'MM'     [e.g. '04', for April]
;               DAY     :  'DD'     [e.g. '25', for the 25th]
;               DATE    :  N-Element array of dates 'MMDDYY' [MM=month, DD=day, YY=year]
;
;   CHANGED:  1)  Altered output slightly              [07/21/2008   v1.0.1]
;             2)  Updated man page and altered output:  Added new tag to structure
;                                                      [04/07/2009   v1.0.2]
;             3)  Now accepts arrays of dates          [05/01/2009   v2.0.0]
;             4)  Fixed issue when entering dates prior to 1990, though program will
;                   only be valid until 2060... at which point new software will be
;                   necessary                          [11/16/2010   v2.1.0]
;
;   CREATED:  06/05/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/16/2010   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION my_str_date,YEAR=yy,MONTH=mon,DAY=day,DATE=date

mdate  = ''   ; -String for date ('YYYYMMDD')
sdate  = ''   ; -String for short date ('MMDDYY')
tdate  = ''   ; -String for date ('YYYY-MM-DD')
IF KEYWORD_SET(date) THEN BEGIN ; => If multiple dates are sent in okay
  n_d   = N_ELEMENTS(date)
  myr1  = STRMID(date[*],4,1)
  myr2  = STRMID(date[*],4,2)
  IF (n_d GT 1L) THEN BEGIN
    years = [['19'+myr2],['20'+myr2]]
    yr    = STRARR(n_d)
    FOR j=0L, n_d - 1L DO BEGIN
      ; => Spacecraft have only flown between 1960's and present
      IF (myr1[j] LE '9' AND myr1[j] GE '6') THEN yr[j] = years[j,0] ELSE yr[j] = years[j,1]
    ENDFOR
  ENDIF ELSE BEGIN
    IF (myr1[0] LE '9' AND myr1[0] GE '6') THEN yr = '19'+myr2[0] ELSE yr = '20'+myr2[0]
  ENDELSE
ENDIF ELSE BEGIN ; => Here only 1 date returned
  IF KEYWORD_SET(yy) THEN BEGIN
    yearsh = STRING(FORMAT='(I2.2)',STRMID(yy,2,2))
    yr     = yy
  ENDIF ELSE BEGIN
    yearsh = 0   ; -Year as yy i.e. 97
    READ,PROMPT='Please enter year of interest (INT : YY): ',yearsh
    yearsh = STRING(FORMAT='(I2.2)',yearsh)
    myr1   = STRMID(yearsh,0,1)
    myr2   = yearsh
    CASE myr1 OF
      '9' : BEGIN
        yr = '19'+myr2
      END
      '0' : BEGIN
        yr = '20'+myr2
      END
    ENDCASE
  ENDELSE
  IF KEYWORD_SET(mon) THEN BEGIN
    mthsh = STRING(FORMAT='(I2.2)',mon)
  ENDIF ELSE BEGIN
    mthsh = 0    ; -Month  i.e. 10
    READ,PROMPT='Please enter month of interest (INT : MM): ',mthsh
    mthsh = STRING(FORMAT='(I2.2)',mthsh)
  ENDELSE
  IF KEYWORD_SET(day) THEN BEGIN
    daysh = STRING(FORMAT='(I2.2)',day)
  ENDIF ELSE BEGIN
    daysh = 0    ; -Day of month i.e. 25
    READ,PROMPT='Please enter day of event (INT : DD): ',daysh
    daysh = STRING(FORMAT='(I2.2)',daysh)
  ENDELSE
  date   = mthsh+daysh+yearsh
ENDELSE
sdate    = date
mdate    = yr+STRMID(date[*],0,2)+STRMID(date[*],2,2)
tdate    = yr+'-'+STRMID(date[*],0,2)+'-'+STRMID(date[*],2,2)
yearsh   = STRMID(date[*],4,2)
mthsh    = STRMID(date[*],0,2)
daysh    = STRMID(date[*],2,2)

date_str = CREATE_STRUCT('S_DATE',sdate,'DATE',mdate,'TDATE',tdate,'L_YYYY',yr,$
                         'YY',yearsh,'MM',mthsh,'DD',daysh)

RETURN,date_str
END