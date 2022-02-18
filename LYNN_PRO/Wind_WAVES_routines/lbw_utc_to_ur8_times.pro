;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_utc_to_ur8_times.pro
;  PURPOSE  :   Routine converts an input UTC time to UR8 time.
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
;               time_struct.pro
;               time_double.pro
;               time_double.pro
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
;               test = lbw_utc_to_ur8_times(utc_in [,YEAR=year] [,MONTH=month] [,DAY=day]  $
;                                           [,HOUR=hour] [,MINUTE=minute] [,SECOND=second] $
;                                           [,MILSEC=milsec] [,JULIAN=julian] [,DOY=doy]   $
;                                           [,UR8OUT=ur8out])
;
;               ;;  Example
;               ymdb0       = ['1981-01-02','1981-12-20','1982-02-01','1994-01-01','2009-01-01','2020-01-01']+'/00:00:00.000'
;               temp           = lbw_utc_to_ur8_times(ymdb0,JULIAN=julin0,DOY=dy0,UR8OUT=ur8out0)
;               PRINT,';;  ',ur8out0
;               ;;        -364.00002      -12.000012       32.000000       4382.9999       9861.9999       13879.000
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT INTPUTS       ***
;               **********************************
;               NA
;               **********************************
;               ***     ALTERED ON OUTPUT      ***
;               **********************************
;               YEAR    :  Set to a named variable that will return an [N]-element array
;                            [numeric] of year values
;               MONTH   :  Set to a named variable that will return an [N]-element array
;                            [numeric] of month values
;               DAY     :  Set to a named variable that will return an [N]-element array
;                            [numeric] of day of month values
;               HOUR    :  Set to a named variable that will return an [N]-element array
;                            [numeric] of hour values
;               MINUTE  :  Set to a named variable that will return an [N]-element array
;                            [numeric] of minute values
;               SECOND  :  Set to a named variable that will return an [N]-element array
;                            [numeric] of second values
;               MILSEC  :  Set to a named variable that will return an [N]-element array
;                            [numeric] of millisecond values
;               JULIAN  :  Set to a named variable that will return an [N]-element array
;                            [numeric] of Julian day number values
;               DOY     :  Set to a named variable that will return an [N]-element array
;                            [numeric] of day of year values
;               UR8OUT  :  Set to a named variable that will return an [N]-element array
;                            [numeric] of UR8 times
;               
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  UR8 = Ulysses Real8 Format Time
;                       = # of 86,400 second days from 1982-01-01/00:00:00.000 UT
;
;  REFERENCES:  
;               1)  Bougeret, J.-L., M.L. Kaiser, P.J. Kellogg, R. Manning, K. Goetz,
;                      S.J. Monson, N. Monge, L. Friel, C.A. Meetre, C. Perche,
;                      L. Sitruk, and S. Hoang (1995) "WAVES:  The Radio and Plasma
;                      Wave Investigation on the Wind Spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 231-263, doi:10.1007/BF00751331.
;
;   CREATED:  10/28/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/28/2021   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_utc_to_ur8_times,ymdb_str,YEAR=year,MONTH=month,DAY=day,HOUR=hour,    $
                                       MINUTE=minute,SECOND=second,MILSEC=milsec,  $
                                       JULIAN=julian,DOY=doy,UR8OUT=ur8out

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
start_of_day_t = '00:00:00.000000000'
noon__of_day_t = '12:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
days_in_3_yrs  = 1096L
days_in_4_yrs  = 1461L
mins_in_day    = 24e0*6e1
secs_in_day    = mins_in_day[0]*6e1
msec_in_day    = secs_in_day[0]*1e3
i4ms_in_day    = 24L*60L*60L*1000L
jd_J1900       = 2415020d0               ;;  Julian Day number for Jan. 1st, 1900 at 12:00:00 TDB
jd_J1950       = 24332825d-1             ;;  " " Jan. 1st, 1950 at 00:00:00 TDB
jd_J2000       = 2451545d0               ;;  " " Jan. 1st, 2000 at 12:00:00 TDB
;;  Define some Unix times for typical Epoch times
j1900_unix     = time_double('1900-01-01/'+noon__of_day_t[0])   ;;  J2000.0 Epoch
j1950_unix     = time_double('1950-01-01/'+start_of_day_t[0])   ;;  J1950.0 Epoch
j2000_unix     = time_double('2000-01-01/'+noon__of_day_t[0])   ;;  J2000.0 Epoch
ur8___unix     = time_double('1982-01-01/'+start_of_day_t[0])   ;;  UR8 Epoch
jdepoch_u      = {T0:j1900_unix[0],T1:j1950_unix[0],T2:j2000_unix[0]}
jdepoch_d      = {T0:jd_J1900[0],T1:jd_J1950[0],T2:jd_J2000[0]}
jdepoch_l      = {T0:[1900L,1L],T1:[1950L,1L],T2:[2000L,1L]}    ;;  [Year,DoY]
hours2secs_12  = 12d0*36d2
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
IF (SIZE(ymdb_str,/TYPE) NE 7) THEN BEGIN
  MESSAGE,'Times array must be string type',/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define string array parts
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  YYYY-MM-DD/hh:mm:ss.xxx
yr_str         = STRMID(ymdb_str,0L,4L)
mo_str         = STRMID(ymdb_str,5L,2L)
dy_str         = STRMID(ymdb_str,8L,2L)
hr_str         = STRMID(ymdb_str,11L,2L)
mn_str         = STRMID(ymdb_str,14L,2L)
sc_str         = STRMID(ymdb_str,17L,2L)
ms_str         = STRMID(ymdb_str,20L)
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
;;  Calculate Julian Day Numbers, Day of Year, and UR8 Times
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define quasi-Unix times
;;    [quasi --> Not really Unix times since these still include leap seconds]
unix           = time_double(ymdb_str)
nn             = N_ELEMENTS(ymdb_str)
;;  Initialize dummy arrays
doy            = 0L*year
isleap         = BYTARR(nn[0])
julian         = year*0d0
ur8out         = year*0d0
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
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate UR8 Time
  ;;--------------------------------------------------------------------------------------
  checks         = [(year1 LT 1982),(year1 EQ 1982),(year1 GT 1982)]
  good           = WHERE(checks,gd)
  gleap          = WHERE(unix[jj] GT leap_s_unix,gl)
  CASE good[0] OF
    0  :  BEGIN
      ;;  Before UR8 Epoch --> check if we need to remove leap seconds
      IF (gl[0] GT 0) THEN qunix = unix[jj] - leap_del_bf[LONG(MAX(gleap))] ELSE qunix = unix[jj]
    END
    1  :  BEGIN
      ;;  Year of UR8 Epoch --> check if we need to remove one leap second
      IF (unix[jj] GT leap_1982un[0L]) THEN qunix = unix[jj] - 1d0 ELSE qunix = unix[jj]
    END
    2  :  BEGIN
      ;;  After UR8 Epoch --> check if we need to remove leap seconds
      IF (gl[0] GT 0) THEN qunix = unix[jj] - leap_del_af[LONG(MAX(gleap))] ELSE qunix = unix[jj]
    END
  ENDCASE
  ;;  Re-compute YYYY-MM-DD/hh:mm:ss.xxx
  t_struc        = time_struct(qunix,/NO_CLEAN)
  t_doy          = t_struc[0].DOY[0]
  t_year         = t_struc[0].YEAR[0]
  t_sod          = t_struc[0].SOD[0]
  yrdiff         = t_year[0] - 1982L
  IF (yrdiff[0] GT 0) THEN BEGIN
    ;;  Year after UR8 Epoch
    fyears         = fill_range(1982L,t_year[0],DIND=1)
    nfy            = N_ELEMENTS(fyears) - 1L
    afleap         = ((fyears MOD 4) EQ 0) - ((fyears MOD 100) EQ 0) + ((fyears MOD 400) EQ 0) $
                        - ((fyears MOD 4000) EQ 0)
    amdays         = mdt[*,afleap]
    mxamds         = MAX(amdays,DIMENSION=1)
    first_days     = TOTAL(LONG(mxamds[0L:(nfy[0] - 1L)]),/NAN)         ;;  Extra -1 to avoid counting year of input times
    ;;  Define UR8 Time
    ur8out[jj]     = (t_doy[0] + first_days[0] + t_sod[0]/864d2) - 1d0  ;;  Remove extra day unintentionally added in calculation
  ENDIF ELSE BEGIN
    IF (yrdiff[0] EQ 0) THEN BEGIN
      ;;  Year of UR8 Epoch
      ur8out[jj]     = t_doy[0] + t_sod[0]/864d2
    ENDIF ELSE BEGIN
      ;;  Year before UR8 Epoch
      fyears         = fill_range(t_year[0],1982L,DIND=1)
      nfy            = N_ELEMENTS(fyears) - 1L
      afleap         = ((fyears MOD 4) EQ 0) - ((fyears MOD 100) EQ 0) + ((fyears MOD 400) EQ 0) $
                          - ((fyears MOD 4000) EQ 0)
      amdays         = mdt[*,afleap]
      mxamds         = MAX(amdays,DIMENSION=1)
      IF ((nfy[0] - 1L) LE 1L) THEN first_days = 0L ELSE first_days = TOTAL(LONG(mxamds[1L:(nfy[0] - 1L)]),/NAN)          ;;  Extra +1 to avoid counting year of input times
;      first_days     = TOTAL(LONG(mxamds[1L:(nfy[0] - 1L)]),/NAN)          ;;  Extra +1 to avoid counting year of input times
      ;;  Define UR8 Time
      delta          = (mxamds[0] - t_doy[0] + 1L) + first_days[0]
      ur8out[jj]     = -1d0*delta[0] + t_sod[0]/864d2
    ENDELSE
  ENDELSE
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END

