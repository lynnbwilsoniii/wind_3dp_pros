;+
;*****************************************************************************************
;
;  FUNCTION :   doy_convert.pro
;  PURPOSE  :   Converts different types of input into:
;                   1) day-of-year (DOY)
;                   2) year-month-day
;                   3) year ['YYYY'], month ['MM'], day['DD'] separated
;                   4) Julian Day
;                   5) Unix Time for both UT1 and TBD
;                   6) etc.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               date = '082696'
;               utc  = '16:44:57.8160'
;               doy  = doy_convert(DATE=date,UT_TIME=utc,JULIAN=jjd)
;               PRINT,jjd[0],FORMAT='(f25.8)'
;                        2450322.19861111
;
;  KEYWORDS:    
;               YEAR       :  Scalar [string] defining the year with the format 'YYYY'
;                               [e.g. '1996']
;               MONTH      :  Scalar [string] defining the month with the format 'MM'
;                               [e.g. '04', for April]
;               DAY        :  Scalar [string] defining the month with the format 'DD'
;                               [e.g. '25']
;               DATE       :  Scalar [string] defining the date with the format 'MMDDYY'
;                               [e.g. '040396', for April 3rd, 1996]
;               DOY        :  Scalar [string,long,float,dbl] defining the day of year
;               JULIAN     :  Set to a named variable to return the Julian Day #
;               UT_TIME    :  String defining the UT1 of interest for determining the
;                               Julian Day with the format
;                               'hh:mm:ss.xxx', where
;                                  hh  =  hour of day
;                                  mm  =  minute of hour
;                                  ss  =  second of minute
;                                  xxx =  fraction of seconds
;                                         (up to nanosecond precision)
;                               [Default = '00:00:00.000000000']
;               UNIX_TIME  :  Scalar [double] defining the Unix time of interest
;
;   CHANGED:  1)  Altered manner in which program calcs DOY
;                                                                   [09/23/2008   v1.0.2]
;             2)  Updated man page
;                                                                   [07/20/2009   v1.0.3]
;             3)  Added keyword:  UT_TIME and UNIX_TIME
;                                                                   [07/22/2009   v1.1.0]
;             4)  Changed output to include:  UTC, TBD, and leap seconds in Unix time
;                   and just seconds and UTC and TBD as strings
;                   and changed program time_string.pro to my_time_string.pro
;                                                                   [09/15/2009   v1.2.0]
;             5)  Removed time messages returned by my_time_string.pro
;                                                                   [04/28/2010   v1.2.1]
;             6)  Changed determination of date/time using UNIX_TIME keyword
;                                                                   [08/03/2010   v1.3.0]
;             7)  Added correction to TDT time to calculate the real TDB times
;                                                                   [02/01/2011   v1.4.0]
;             8)  Fixed a typo in DOY calculation
;                                                                   [02/02/2011   v1.5.0]
;             9)  Updated Man. page and cleaned up routine and
;                   updated leap second tables and removed dependence on
;                   my_time_string.pro
;                                                                   [07/10/2015   v1.6.0]
;
;   DEFINITIONS:
;               1)  List of initialisms/acronyms in for time conventions:
;                 JD   :  Julian Day Number = # of 86400 second days since 12:00:00
;                           (Greenwich mean noon) on Jan. 1, 4713 B.C.
;                           {1 Julian century = 36525 days, each 86400 seconds long}
;                 TAI  :  International Atomic Time
;                           {defined by SI seconds}
;                 UT1  :  Universal Time, defined by mean solar day
;                 ∆A   :  leap seconds elapsed to date {∆A = TAI - UTC}
;                 UTC  :  Coordinated Universal Time [UTC = TAI - (leap seconds)]
;                 TT   :  Terrestrial Time [TT = TAI + 32.184(s)]
;                           [also known as TDT or Terrestrial Dynamical Time]
;                 TDB  :  Barycentric Dynamical Time
;                           Defined as:  TDB = UTC + 32.184 + ∆A
;                                     or TDB = TT + 0.001658"*sin(g) + 0.000014"*sin(2g)
;                                {where: g = Earth's mean orbital anomaly}
;               2)  SI Second = duration of 9,192,631,770 periods of the radiation
;                     corresponding to the transition between two hyperfine levels of
;                     the ground state of the cesium-133 atom.
;               3)  Unix time = # of seconds elapsed since Jan. 1, 1970 00:00:00 UTC
;                     **********************************
;                     *** not including leap seconds ***
;                     **********************************
;
;   NOTES:      
;               1)  The difference between ephemeris time, TBD, and TT is < 2 ms
;               2)  The difference between UTC and UT1 is < 0.1 s
;               3)  The UT_TIME expects there to be leap seconds included
;               
;
;  REFERENCES:  
;               1)  M. Fränz and D. Harper, "Heliospheric Coordinate Systems,"
;                     Planetary and Space Science Vol. 50, 217-233, (2002).
;               
;
;   CREATED:  07/21/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/10/2015   v1.6.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION doy_convert,YEAR=yy,MONTH=mon,DAY=day,DATE=date,DOY=doy,JULIAN=julian,$
                     UT_TIME=uttime,UNIX_TIME=unix_time

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
;;  LBW III  07/10/2015   v1.6.0
;leap_s_secs    = [1d1,11d0,12d0,13d0,14d0,15d0,16d0,17d0,18d0,19d0,2d1,21d0,22d0,$
;                  23d0,24d0,25d0,26d0,27d0,28d0,29d0,3d1,31d0,32d0]
;leap_s_dates   = ['1972-01-01','1972-07-01','1973-01-01','1974-01-01','1975-01-01',$
;                  '1976-01-01','1977-01-01','1978-01-01','1979-01-01','1980-01-01',$
;                  '1981-07-01','1982-07-01','1983-07-01','1985-07-01','1988-01-01',$
;                  '1990-01-01','1991-01-01','1992-07-01','1993-07-01','1994-07-01',$
;                  '1996-01-01','1997-07-01','1999-01-01']
;leap_s_unix    = time_double(leap_s_dates+'/00:00:00')

;;  LBW III  07/10/2015   v1.6.0
;;  Need at least 9 digit precision for TT2000 time formats
start_of_day_t = '00:00:00.000000000'
noon__of_day_t = '12:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
in_with_leaps  = 0b
;;  # of leap seconds at Epoch times defined by the International Earth Rotation
;;    Service (IERS) at http://www.iers.org/
leap_s_secs    = [1d1,11d0,12d0,13d0,14d0,15d0,16d0,17d0,18d0,19d0,2d1,21d0,22d0, $
                  23d0,24d0,25d0,26d0,27d0,28d0,29d0,3d1,31d0,32d0,33d0,34d0,35d0,$
                  36d0]
leap_s_dates   = ['1972-01-01','1972-07-01','1973-01-01','1974-01-01','1975-01-01',$
                  '1976-01-01','1977-01-01','1978-01-01','1979-01-01','1980-01-01',$
                  '1981-07-01','1982-07-01','1983-07-01','1985-07-01','1988-01-01',$
                  '1990-01-01','1991-01-01','1992-07-01','1993-07-01','1994-07-01',$
                  '1996-01-01','1997-07-01','1999-01-01','2006-01-01','2009-01-01',$
                  '2012-07-01','2015-07-01']
leap_s_unix    = time_double(leap_s_dates+start_of_day_t[0])

;;  Define days of year for non-leap years and leap years
mdt            = LONARR(13,2)  ;;  # of days after each month [[not leap year],[leap year]]
mdt            = [[0, 31,  59,  90, 120, 151, 181, 212, 243, 273, 304, 334, 365], $
                  [0, 31,  60,  91, 121, 152, 182, 213, 244, 274, 305, 335, 366]]

mdate          = ''                 ;;  ['YYYYMMDD']
ldate          = ''                 ;;  ['YYYY-MM-DD']
year1          = 0L                 ;;  LONG(yy)
leap           = 0                  ;;  Logic test for determining whether a date is in a leap year
dmth           = LINDGEN(31L) + 1L  ;;  31 max possible days in a month
tmon           = 0L                 ;;  Days before month of interest in respective year
dymon          = 0L                 ;;  The corresponding days of year in respective month
tday           = 0L                 ;;  Respective day of interest
tdt            = 0d0                ;;  Terrestrial Dynamical Time = TDT or TT
tbd            = 0d0                ;;  Barycentric Dynamical Time = TDB
;;  Define some Unix times for typical Epoch times
j1900_unix     = time_double('1900-01-01/'+noon__of_day_t[0])   ;;  J2000.0 Epoch
j1950_unix     = time_double('1950-01-01/'+start_of_day_t[0])   ;;  J1950.0 Epoch
j2000_unix     = time_double('2000-01-01/'+noon__of_day_t[0])   ;;  J2000.0 Epoch
                ;;  Note:  j1950_unix < 0.0 since it is seconds since Jan. 1st, 1970
jd_J1900       = 2415020d0          ;;  Julian Day number for Jan. 1st, 1900 at 12:00:00 TDB
jd_J1950       = 24332825d-1        ;;  " " Jan. 1st, 1950 at 00:00:00 TDB
jd_J2000       = 2451545d0          ;;  " " Jan. 1st, 2000 at 12:00:00 TDB
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(unix_time) THEN BEGIN
  date_struct = time_struct(REFORM(unix_time))
  yy          = STRTRIM(STRING(FORMAT='(I4.4)',date_struct[*].YEAR),2)    ;;  'YYYY'
  mon         = STRTRIM(STRING(FORMAT='(I2.2)',date_struct[*].MONTH),2)   ;;  'MM'
  day         = STRTRIM(STRING(FORMAT='(I2.2)',date_struct[*].DATE),2)    ;;  'DD'
  IF NOT KEYWORD_SET(date) THEN date = mon[*]+day[*]+STRMID(yy[*],2L,2L)  ;;  'MMDDYY'
  date_time   = time_string(date_struct,PREC=5)
  IF NOT KEYWORD_SET(uttime) THEN uttime = STRMID(date_time[*],11L)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Determine date
;;----------------------------------------------------------------------------------------
mydate         = my_str_date(DATE=date,YEAR=yy,MONTH=mon,DAY=day)
date           = mydate.S_DATE                     ;;  ['MMDDYY']
mdate          = mydate.DATE                       ;;  ['YYYYMMDD']
ldate          = mydate.TDATE                      ;;  ['YYYY-MM-DD']
yy             = STRMID(mdate[*],0L,4L)            ;;  'YYYYY'
mon            = STRMID(date[*],0L,2L)             ;;  'MM'
day            = STRMID(date[*],2L,2L)             ;;  'DD'

test           = (KEYWORD_SET(uttime) OR KEYWORD_SET(unix_time))
wtest          = [KEYWORD_SET(uttime),KEYWORD_SET(unix_time)] GT 0
IF (test) THEN BEGIN
  good = WHERE(wtest,gd)
  ;;  Check to make sure input time has the correct format [Assumes 'HH:MM:SS.ssss']
  CASE good[0] OF
    0    : BEGIN  ;;  Entered a UT1 Time
      unix_time     = REFORM(time_double(ldate+'/'+uttime))
;;  LBW III  07/10/2015   v1.6.0
      in_with_leaps = 0b       ;;  Assume input has leap seconds included
;      in_with_leaps = 1b       ;;  Assume input has leap seconds included
    END
    1    : BEGIN  ;;  Entered a Unix time
;;  LBW III  07/10/2015   v1.6.0
;      mts       = my_time_string(unix_time,UNIX=1,/NOMSSG)
;      uttime    = STRMID(mts.DATE_TIME[*],11L)
      uttimef   = time_string(unix_time,PRECISION=9)  ;;  up to nanosecond precision
      uttime    = STRMID(uttimef[*],11L)              ;;  e.g., 'hh:mm:ss.xxxxxxxxx'
    END
    ELSE : BEGIN
      MESSAGE,'How did you managed to do this?',/INFORMATIONAL,/CONTINUE
;;  LBW III  07/10/2015   v1.6.0
;      unix_time = REFORM(time_double(ldate+'/00:00:00'))
;      uttime    = '00:00:00'
      unix_time = REFORM(time_double(ldate+'/'+start_of_day_t[0]))
      uttime    = start_of_day_t[0]
    END
  ENDCASE
ENDIF ELSE BEGIN
;;  LBW III  07/10/2015   v1.6.0
;  unix_time = REFORM(time_double(ldate+'/00:00:00'))
  unix_time = REFORM(time_double(ldate+'/'+start_of_day_t[0]))
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Determine Terrestrial Dynamical Time (TDT)
;;----------------------------------------------------------------------------------------
nun            = N_ELEMENTS(unix_time)
delta          = DBLARR(nun)         ;;  Difference of leap seconds between TAI and UTC
deltau         = DBLARR(nun)         ;;  leap seconds in Unix time
FOR j=0L, nun - 1L DO BEGIN
  bl    = 0L
  bleap = WHERE(leap_s_unix LT unix_time[j],bl)
;;  LBW III  07/10/2015   v1.6.0
;  IF (bl GT 0L) THEN delta[j]  = leap_s_secs[MAX(bleap,/NAN)]
;  IF (bl GT 0L) THEN deltau[j] = leap_s_unix[MAX(bleap,/NAN)]
  IF (bl GT 0L) THEN BEGIN
    delta[j]  = leap_s_secs[MAX(bleap,/NAN)]
    deltau[j] = leap_s_unix[MAX(bleap,/NAN)]
  ENDIF
ENDFOR
;;  LBW III  07/10/2015   v1.6.0
;tdt            = DBLARR(nun)          ;;  Terrestrial Dynamical Time as a Unix time
;tdt            = unix_time + 32.184d0 + delta
IF (in_with_leaps) THEN BEGIN
  ;;  leap seconds were included --> remove them from Unix time
  UTC_as_Unix    = unix_time
  TAI_as_Unix    = UTC_as_Unix - delta
  TT__as_Unix    = TAI_as_Unix + 32.184d0
  TDT_as_Unix    = UTC_as_Unix + 32.184d0 + delta
ENDIF ELSE BEGIN
  ;;  leap seconds were not included --> add them here
  tdt            = unix_time + 32.184d0 + delta
ENDELSE

;;  LBW III  07/10/2015   v1.6.0
;mts            = my_time_string(unix_time,UNIX=1,/NOMSSG)
;utc_date_time  = mts.DATE_TIME
;mts            = my_time_string(tdt,UNIX=1,/NOMSSG)
;tdt_date_time  = mts.DATE_TIME
;mts            = my_time_string(unix_time,UNIX=1,/NOMSSG)
utc_date_time  = time_string(unix_time,PRECISION=9)
tdt_date_time  = time_string(tdt,PRECISION=9)
;tbd = unix_time            ;;  Just use Unix for now...
;;----------------------------------------------------------------------------------------
;;  Determine date and whether it falls in a leap year or not
;;----------------------------------------------------------------------------------------
year1          = LONG(yy)
leap           = ((year1 MOD 4) EQ 0) - ((year1 MOD 100) EQ 0) + ((year1 MOD 400) EQ 0) $
                    - ((year1 MOD 4000) EQ 0)
;;  LBW III  07/10/2015   v1.6.0
;CASE leap OF
;  1    : BEGIN
;    glp = 1L
;  END
;  0    : BEGIN
;    glp = 0L
;  END
;  ELSE : BEGIN
;    MESSAGE,'Something is wrong with your input...',/INFORMATIONAL,/CONTINUE
;    RETURN,0
;  END
;ENDCASE
;tmon           = LONG(mon) - 1L        ;;  Days before month of interest in respective year
;tday           = LONG(day) - 1L        ;;  Respective day of interest
;dymon          = day + mdt[tmon,glp]   ;;  The corresponding days of year in respective month
tmon           = LONG(mon) - 1L        ;;  Days before month of interest in respective year
tday           = LONG(day) - 1L        ;;  Respective day of interest
dymon          = day + mdt[tmon,leap]  ;;  The corresponding days of year in respective month
doy            = dymon                 ;;  Day of year
;;----------------------------------------------------------------------------------------
;;  Determine Julian Day (from J2000.0) if desired
;;----------------------------------------------------------------------------------------
test_1900      = WHERE(year1 GE 1900 AND year1 LT 1950,gd1900)
test_1950      = WHERE(year1 GE 1950 AND year1 LT 2000,gd1950)
test_2000      = WHERE(year1 GE 2000,gd2000)
jepochux       = DBLARR(nun)
jepochd        = DBLARR(nun)
;;  LBW III  07/10/2015   v1.6.0
;IF (gd1900 GT 0) THEN jepochux[test_1900] = j1900_unix[0]
;IF (gd1900 GT 0) THEN jepochd[test_1900]  = jd_J1900[0]
;IF (gd1950 GT 0) THEN jepochux[test_1950] = j1950_unix[0]
;IF (gd1950 GT 0) THEN jepochd[test_1950]  = jd_J1950[0]
;IF (gd2000 GT 0) THEN jepochux[test_2000] = j2000_unix[0]
;IF (gd2000 GT 0) THEN jepochd[test_2000]  = jd_J2000[0]
tests          = {T0:test_1900,T1:test_1950,T2:test_2000}
jdepoch_u      = {T0:j1900_unix[0],T1:j1950_unix[0],T2:j2000_unix[0]}
jdepoch_d      = {T0:jd_J1900[0],T1:jd_J1950[0],T2:jd_J2000[0]}
FOR j=0L, 2L DO BEGIN
  jd_inds = tests.(j)
  jd_unix = jdepoch_u.(j)
  jd_days = jdepoch_d.(j)
  IF (jd_inds[0] GE 0) THEN BEGIN
    jepochux[jd_inds] = jd_unix[0]
    jepochd[jd_inds]  = jd_days[0]
  ENDIF
ENDFOR
;;  Define difference between Unix epochs and TDT
del_tdt        = tdt - jepochux
;;  Define Julian Day Number
julian         = jepochd + del_tdt/864d2
;;----------------------------------------------------------------------------------------
;;  Determine barycentric dynamical time (TDB)
;;----------------------------------------------------------------------------------------
tbd            = DBLARR(nun)          ;;  Barycentric Dynamical Time as a Unix time
;;  Calculate corrections due to variations in gravitational potential around 
;      Earth's orbit
ggE            = 0d0                  ;;  Mean anomaly of Earth in its orbit around sun
;;  LBW III  07/10/2015   v1.6.0
;ggE  = 357.53d0 + 0.98560028d0*(julian - jd_J2000[0])
dg_0           = (100.4664568d0 - 102.9373481d0)
dg_1           = (35999.3728565d0 - 0.3225654d0)/36525d0
ggE            = dg_0[0] + dg_1[0]*(julian - jd_J2000[0])
ggE           *= (!DPI/18d1)
;;  LBW III  07/10/2015   v1.6.0
;fac0           = 0.001658d0*36d1/864d2
;fac1           = 0.000014d0*36d1/864d2
;tbd            = tdt + (fac0[0])*SIN(ggE*dtor) + (fac1[0])*SIN(2d0*ggE*dtor)
;mts           = my_time_string(tbd,UNIX=1,/NOMSSG)
;tbd_date_time = mts.DATE_TIME

;;  Two correction factors to TDT from 'The Astronomical Almanac', [1997] {page B5}
fac0           = 0.001658d0
fac1           = 0.000014d0
tbd            = tdt + fac0[0]*SIN(ggE) + fac1[0]*SIN(2d0*ggE)
;;  Convert to a string
tbd_date_time  = time_string(tbd,PRECISION=9)
;;----------------------------------------------------------------------------------------
;;  Define return data structure
;;----------------------------------------------------------------------------------------
dtags          = ['DOY','YEAR','MONTH','DAY','DATE','L_DATE','TPLOT_DATE','JULIAN_DAY', $
                  'UNIX_TIME_UTC','UNIX_TIME_TDT','UNIX_TIME_TBD','UNIX_TIME_LEAP_S',   $
                  'LEAP_SEC','TIME_UTC','TIME_TDT','TIME_TBD']

d_str          = CREATE_STRUCT(dtags,doy,yy,mon,day,date,mdate,ldate,julian,     $
                               unix_time,tdt,tbd,deltau,delta,                   $
                               utc_date_time,tdt_date_time,tbd_date_time)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,d_str
END