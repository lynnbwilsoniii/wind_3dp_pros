;+
;*****************************************************************************************
;
;  FUNCTION :   utc_to_julian_day.pro
;  PURPOSE  :   This routine calculates the Julian day number from UTC times.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               time_double.pro
;               str_valid_num.pro
;               fill_range.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               UTC_IN  :  [N]-Element [string] array of UTC times with format:
;                            'YYYY-MM-DD/hh:mm:ss.xxx'
;                            where the fraction of seconds is optional
;
;  EXAMPLES:    
;               [calling sequence]
;               time           = '1996-08-28/16:44:57.8160'
;               temp           = utc_to_julian_day(time)
;               temp[0]
;                      2450324.1986111109
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  List of initialisms/acronyms in for time conventions:
;                 JD   :  Julian Day Number = # of 86400 second days since 12:00:00
;                           (Greenwich mean noon) on Jan. 1, 4713 B.C.
;                           {1 Julian century = 36525 days, each 86400 seconds long}
;                 TAI  :  International Atomic Time
;                           --> measures time according to a number of atomic clocks.
;                           There are exactly 86400 TAI seconds in a TAI day.  The TAI
;                           second is based on the Earth's average rotation rate between
;                           1750 and 1892.  A UT1 day is now a couple of milliseconds
;                           longer (on average) than is a TAI day thanks to the slowing
;                           of the Earth's rotation rate.
;                           TAI = UTC + ∆A
;                 ∆A   :  total algebraic sum of leap seconds to the date/time of interest
;                 UT1  :  Universal Time, defined by mean solar day
;                           --> measures the Earth's rotation with respect to the distant
;                           stars (quasars, nowadays), scaled by a factor of
;                           (one mean solar day)/(one sidereal day), with small adjustments
;                           for polar motion. There are exactly 86400 UT1 seconds in a
;                           UT1 day.
;                           --> UT1 is not really a time but a way to express Earth's
;                           rotation angle
;                 UTC  :  Coordinated Universal Time
;                           UTC  =  TAI - ∆A
;                                =  TT - ∆A - 32.184(s)
;                 TDT  :  Terrestrial Dynamical Time
;                           --> coordinate systems centered at Earth, or the proper time
;                           in general relativity parlance
;                 TDB  :  Barycentric Dynamical Time
;                           --> coordinate systems centered at solar system center, or
;                           the coordinate time in general relativity parlance
;                           TDB = UTC + 32.184 + ∆A
;                           TDB = TT + 0.001658"*sin(g) + 0.000014"*sin(2g)
;                                {where: g = Earth's mean orbital anomaly}
;                 TT   :  Terrestrial Time {SI Second}
;                           TT  =  TAI + 32.184(s)  =  (UTC + ∆A) + 32.184(s)
;                           [also known as TDT or Terrestrial Dynamical Time]
;               2)  SI Second = duration of 9,192,631,770 periods of the radiation
;                     corresponding to the transition between two hyperfine levels of
;                     the ground state of the cesium-133 atom.
;               3)  Unix time = # of seconds elapsed since Jan. 1, 1970 00:00:00 UTC
;                     **********************************
;                     *** not including leap seconds ***
;                     **********************************
;               4)  The difference between ephemeris time, TBD, and TT is < 2 ms
;               5)  The difference between UTC and UT1 is < 0.9 s.  That is:
;                     dUT = UT1 - UTC
;                     -0.9 s < dUT < 0.9 s
;               6)  The UTC_IN expects there to be leap seconds included
;               7)  Examples from https://aa.usno.navy.mil/data/JulianDate
;                     JD 2450324.197976  =  1996-08-28/16:45:05.200 UT1
;                     1996-08-28/16:44:57.800 UT1  =  JD 2450324.197891
;                     dUT = 119.5808 ms for 1996-08-28
;                     JD 2450324.19861111  =  1996-08-28/16:46:00.000 UT1
;
;  REFERENCES:  
;               1)  M. Fränz and D. Harper, "Heliospheric Coordinate Systems,"
;                     Planetary and Space Science Vol. 50, 217-233, (2002).
;               2)  2017 Erratum to Fränz and Harper [2002]
;               3)  https://aa.usno.navy.mil/data/JulianDate
;               4)  https://www.cnmoc.usff.navy.mil/Our-Commands/United-States-Naval-Observatory/Precise-Time-Department/Global-Positioning-System/USNO-GPS-Time-Transfer/Leap-Seconds/
;
;   CREATED:  06/12/2025
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/12/2025   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION utc_to_julian_day,utc_in

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
start_of_day_t = '00:00:00.000000000'
noon__of_day_t = '12:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
days_in_3_yrs  = 1096L
days_in_4_yrs  = 1461L
mins_in_day    = 24e0*6e1
secs_in_day    = mins_in_day[0]*6e1
msec_in_day    = secs_in_day[0]*1e3
i4ms_in_day    = 24L*60L*60L*1000L
hours2secs_12  = 12d0*36d2
;;  Define some Julian day epochs
jd_J1900       = 2415020d0               ;;  Julian Day number for Jan. 1st, 1900 at 12:00:00 TDB
jd_J1950       = 24332825d-1             ;;  " " Jan. 1st, 1950 at 00:00:00 TDB
jd_J2000       = 2451545d0               ;;  " " Jan. 1st, 2000 at 12:00:00 TDB
;;  Define some quasi-Unix times for typical Epoch times
j1900_unix     = time_double('1900-01-01/'+noon__of_day_t[0])   ;;  J2000.0 Epoch
j1950_unix     = time_double('1950-01-01/'+start_of_day_t[0])   ;;  J1950.0 Epoch
j2000_unix     = time_double('2000-01-01/'+noon__of_day_t[0])   ;;  J2000.0 Epoch
jdepoch_u      = {T0:j1900_unix[0],T1:j1950_unix[0],T2:j2000_unix[0]}
jdepoch_d      = {T0:jd_J1900[0],T1:jd_J1950[0],T2:jd_J2000[0]}
jdepoch_l      = {T0:[1900L,1L],T1:[1950L,1L],T2:[2000L,1L]}    ;;  [Year,DoY]
;;  # of leap seconds at Epoch times defined by the International Earth Rotation
;;    Service (IERS) at http://www.iers.org/
leap_s_secs    = [1d1,11d0,12d0,13d0,14d0,15d0,16d0,17d0,18d0,19d0,2d1,21d0,22d0, $
                  23d0,24d0,25d0,26d0,27d0,28d0,29d0,3d1,31d0,32d0,33d0,34d0,35d0,$
                  36d0,37d0]
leap_s_dates   = ['1972-01-01','1972-07-01','1973-01-01','1974-01-01','1975-01-01',$
                  '1976-01-01','1977-01-01','1978-01-01','1979-01-01','1980-01-01',$
                  '1981-07-01','1982-07-01','1983-07-01','1985-07-01','1988-01-01',$
                  '1990-01-01','1991-01-01','1992-07-01','1993-07-01','1994-07-01',$
                  '1996-01-01','1997-07-01','1999-01-01','2006-01-01','2009-01-01',$
                  '2012-07-01','2015-07-01','2017-01-01']
leap_s_unix    = time_double(leap_s_dates+start_of_day_t[0])
leap_1982un    = time_double(leap_s_dates[11L]+start_of_day_t[0])
leap_del_af    = leap_s_secs - leap_s_secs[11L]                     ;;  Leap seconds to remove after 1982
leap_del_bf    = leap_s_secs[11L] - leap_s_secs
;;  Define days of year for non-leap years and leap years
mdt            = LONARR(13,2)  ;;  # of days after each month [[not leap year],[leap year]]
mdt            = [[0, 31,  59,  90, 120, 151, 181, 212, 243, 273, 304, 334, 365], $
                  [0, 31,  60,  91, 121, 152, 182, 213, 244, 274, 305, 335, 366]]
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 1) THEN BEGIN
  MESSAGE,'User must supply an array of "YYYY-MM-DD/hh:mm:ss.xxx" times',/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
IF (SIZE(utc_in,/TYPE) NE 7) THEN BEGIN
  MESSAGE,'Times array must be string type',/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Convert to TT before calculating JD
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define quasi-Unix times
;;    [quasi --> Not really Unix times since these still include leap seconds]
unix           = time_double(utc_in)
nn             = N_ELEMENTS(utc_in)
tt_as_unix     = REPLICATE(d,nn[0])
FOR jj=0L, nn[0] - 1L DO BEGIN
  bleap          = WHERE(leap_s_unix LT unix[jj],bl)
  IF (bl[0] GT 0) THEN dA = leap_s_secs[(LONG(MAX(bleap,/NAN)))[0]] ELSE dA = 0d0
  ;;--------------------------------------------------------------------------------------
  ;;  TT  =  TAI + 32.184(s)  =  (UTC + ∆A) + 32.184(s)
  ;;--------------------------------------------------------------------------------------
  tt_as_unix[jj] = unix[jj] + dA[0] + 32.184d0
ENDFOR
tt_as_ymdb     = time_string(tt_as_unix,PREC=9)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define string array parts
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  YYYY-MM-DD/hh:mm:ss.xxx
yr_str         = STRMID(tt_as_ymdb,0L,4L)
mo_str         = STRMID(tt_as_ymdb,5L,2L)
dy_str         = STRMID(tt_as_ymdb,8L,2L)
hr_str         = STRMID(tt_as_ymdb,11L,2L)
mn_str         = STRMID(tt_as_ymdb,14L,2L)
sc_str         = STRMID(tt_as_ymdb,17L,2L)
ms_str         = STRMID(tt_as_ymdb,20L)
bad_ms         = WHERE(ms_str EQ '',bd_ms)
IF (bd_ms[0] GT 0) THEN ms_str[bad_ms] = '000'
testyr         = str_valid_num(yr_str,  year,/INTEGER)
testmo         = str_valid_num(mo_str, month,/INTEGER)
testdy         = str_valid_num(dy_str,   day,/INTEGER)
testhr         = str_valid_num(hr_str,  hour,/INTEGER)
testmn         = str_valid_num(mn_str,minute,/INTEGER)
testsc         = str_valid_num(sc_str,second,/INTEGER)
testms         = str_valid_num(ms_str,milsec,/INTEGER)
test0          = (~testyr[0] OR ~testmo[0] OR ~testdy[0] OR ~testhr[0] OR ~testmn[0] OR ~testsc[0] OR ~testms[0])
nyr            = N_ELEMENTS(year)
test1          = (N_ELEMENTS( month) NE nyr[0]) OR (N_ELEMENTS(   day) NE nyr[0]) OR (N_ELEMENTS(  hour) NE nyr[0]) OR (N_ELEMENTS(minute) NE nyr[0]) OR (N_ELEMENTS(second) NE nyr[0]) OR (N_ELEMENTS(milsec) NE nyr[0])
IF (test0[0] OR test1[0]) THEN STOP
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate Julian Day Numbers
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Initialize dummy arrays
doy            = 0L*year
isleap         = BYTARR(nn[0])
julian         = year*0d0
sod            = year*0d0
;;  Loop through dates
FOR jj=0L, nn[0] - 1L DO BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Determine date and whether it falls in a leap year or not
  ;;--------------------------------------------------------------------------------------
  year1          = LONG(year[jj])
  leap           = ((year1 MOD 4) EQ 0) - ((year1 MOD 100) EQ 0) + ((year1 MOD 400) EQ 0) $
                      - ((year1 MOD 4000) EQ 0)
  isleap[jj]     = leap[0]
  cumdoy         = mdt[*,leap[0]]     ;;  cumulative day of year at end of each month
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate day of year
  ;;--------------------------------------------------------------------------------------
  doy0           = cumdoy[month[jj] - 1L]
  doy[jj]        = doy0[0] + day[jj]
  ;;--------------------------------------------------------------------------------------
  ;;  Convert to TT before calculating JD
  ;;--------------------------------------------------------------------------------------
  ;;  TT  =  TAI + 32.184(s)  =  (UTC + ∆A) + 32.184(s)
  
  
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate Julian day number
  ;;--------------------------------------------------------------------------------------
  checks         = [(year1 GE 1900 AND year1 LT 1950),(year1 GE 1950 AND year1 LT 2000),$
                    (year1 GE 2000)]
  good           = WHERE(checks,gd)
  twelve_hour_on = 1b
  IF (gd[0] GT 0) THEN BEGIN
    jepochd  = jdepoch_d.(good[0])
    jepochl  = jdepoch_l.(good[0])
    yrdiff   = year1[0] - jepochl[0]
    IF (good[0] EQ 1) THEN twelve_hour_on = 0b ELSE twelve_hour_on = 1b
    IF (yrdiff[0] GT 0) THEN BEGIN
      ;;  Find cumulative days in intervening years
      fyears         = fill_range(jepochl[0],year1[0],DIND=1)
      nfy            = N_ELEMENTS(fyears) - 1L
      afleap         = ((fyears MOD 4) EQ 0) - ((fyears MOD 100) EQ 0) + ((fyears MOD 400) EQ 0) $
                          - ((fyears MOD 4000) EQ 0)
      amdays         = mdt[*,afleap]
      mxamds         = MAX(amdays,DIMENSION=1)
      first_days     = TOTAL(LONG(mxamds[0L:(nfy[0] - 1L)]),/NAN)     ;;  Extra -1 to avoid counting year of input times
      julian[jj]     = jepochd[0] + doy[jj] + first_days[0]
    ENDIF ELSE BEGIN
      ;;  Same year as epoch --> just add DoY
      julian[jj]     = jepochd[0] + doy[jj]
    ENDELSE
    ;;  For some reason, all of my Julian day #'s were off by +1 after the J2000 epoch
    IF (good[0] EQ 2) THEN julian[jj] -= 1L
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Adjust Julian day number if necessary
  ;;--------------------------------------------------------------------------------------
  sod[jj]        = hour[jj]*36d2 + minute[jj]*6d1 + 1d0*second[jj] + 1d-3*milsec[jj]
  IF (twelve_hour_on[0]) THEN delta = (sod[jj] - hours2secs_12[0])/864d2 ELSE delta = (sod[jj] - 864d2)/864d2
  julian[jj]    += delta[0]
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,julian
END
















