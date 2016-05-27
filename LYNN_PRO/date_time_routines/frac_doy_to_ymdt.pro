;+
;*****************************************************************************************
;
;  FUNCTION :   frac_doy_to_ymdt.pro
;  PURPOSE  :   This routine converts an input array of fractional day of year (DOY)
;                 values to dates and times of the form YYYY-MM-DD/hh:mm:ss.xxxxxx.
;
;  CALLED BY:   
;               read_Wind_SWE_FC_2ps_MLSSpec.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               IYEAR   :  [N]-Element (long) array of integer years associated with
;                            the FDOY array
;               FDOY    :  [N]-Element (float/double) array of fractional day of year
;                            (DOY) values to be converted to strings of the form
;                            YYYY-MM-DD/hh:mm:ss.xxxxxx, where:
;                              YYYY    :  four-digit integer year       (0 - 20??)
;                              MM      :  integer month of year         (1 - 12)
;                              DD      :  integer day of month          (1 - 31)
;                              hh      :  integer hour of day           (0 - 23)
;                              mm      :  integer minute of hour        (0 - 59)
;                              ss      :  integer second of minute      (0 - 59)
;                              xxxxxx  :  fractional seconds of second  (0 - 0.999999)
;
;  EXAMPLES:    
;               IDL> fdoy  = [309.0018d0,309.0030d0,309.0041d0,309.0052d0,309.0064d0]
;               IDL> nf    = N_ELEMENTS(fdoy)
;               IDL> iyear = REPLICATE(2008L,nf)
;               IDL> test  = frac_doy_to_ymdt(iyear,fdoy)
;               IDL> FOR j=0L, 1L DO PRINT,';;  ', test[j]
;               ;;  2008-11-04/00:02:35.520000
;               ;;  2008-11-04/00:04:19.200000
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  1 Day = 86,400 seconds
;                         = 24 hours
;
;  REFERENCES:  
;               NA
;
;   CREATED:  11/08/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/08/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION frac_doy_to_ymdt,iyear,fdoy

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
bad_numin_msg  = 'I_YEAR and FDOY must be an [N]-element arrays...'
;;  Define # of days at beginning of each month of year
mdt            = [[0, 31,  59,  90, 120, 151, 181, 212, 243, 273, 304, 334, 365], $
                  [0, 31,  60,  91, 121, 152, 182, 213, 244, 274, 305, 335, 366]]
doys           = [[INDGEN(366)],[INDGEN(366)]]            ;;  logic for days of year
isleap         = [[REPLICATE(0,366)],[REPLICATE(1,366)]]  ;;  logic for leap years
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 2) OR (N_ELEMENTS(iyear) NE N_ELEMENTS(fdoy))
IF (test) THEN BEGIN
  ;;  Must be 3 inputs supplied
  MESSAGE,bad_numin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
f_doy          = DOUBLE(fdoy)        ;;  fractional DOY
i_doy          = FLOOR(f_doy)        ;;  integer DOY
i_year         = FLOOR(iyear)        ;;  integer year
nf             = N_ELEMENTS(fdoy)
;;----------------------------------------------------------------------------------------
;;  Convert integer DOY to date [e.g., YYYY-MM-DD]
;;----------------------------------------------------------------------------------------
;;  Define logic defining whether year is a leap year or not
leap           = ((i_year MOD 4)   EQ 0) - ((i_year MOD 100)  EQ 0) + $
                 ((i_year MOD 400) EQ 0) - ((i_year MOD 4000) EQ 0)
months         = doys/29                                  ;;  logic for month of year
dates          = doys - mdt[months,isleap]                ;;  logic for dates
neg            = WHERE(dates LT 0,ng)
IF (ng GT 0) THEN BEGIN
  months[neg] = months[neg] - 1
  dates[neg]  = doys[neg] - mdt[months[neg],isleap[neg]]
ENDIF
;;  Shift logic values
months        += 1
dates         += 1
;;  Define months of year and days of month
i_month        = months[i_doy - 1L, leap]
i_day          = dates[i_doy - 1L, leap]
;;----------------------------------------------------------------------------------------
;;  Convert fractional DOY to integer DOY and seconds of day (SOD)
;;----------------------------------------------------------------------------------------
f_day          = f_doy - 1d0*i_doy   ;;  fractional days of DOY
sod            = f_day*864d2         ;;  SOD [86400 seconds/day]
i_hours        = FLOOR(sod/36d2)     ;;  integer hours of day
fsec           = sod - 36d2*i_hours  ;;  fractional seconds of hour
i_minutes      = FLOOR(fsec/6d1)     ;;  integer minutes of hour
fsec          -= 6d1*i_minutes       ;;  fractional seconds of minute
i_seconds      = FLOOR(fsec)         ;;  integer seconds of minute
fsec          -= i_seconds           ;;  fractional seconds of second
;;----------------------------------------------------------------------------------------
;;  Define date/time strings
;;----------------------------------------------------------------------------------------
s_year         = STRING(i_year,FORMAT='(I4.4)')
s_month        = STRING(i_month,FORMAT='(I2.2)')
s_day          = STRING(i_day,FORMAT='(I2.2)')
s_hour         = STRING(i_hours,FORMAT='(I2.2)')
s_minute       = STRING(i_minutes,FORMAT='(I2.2)')
s_second       = STRING(i_seconds,FORMAT='(I2.2)')
s_fsec         = STRMID(STRTRIM(STRING(fsec,FORMAT='(f20.6)'),2L),1L)
;;  Format:  'YYYY-MM-DD/hh:mm:ss.xxxxxx'
s_date         = s_year+'-'+s_month+'-'+s_day
s_time         = s_hour+':'+s_minute+':'+s_second+s_fsec
ymdt           = s_date+'/'+s_time
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,ymdt
END
