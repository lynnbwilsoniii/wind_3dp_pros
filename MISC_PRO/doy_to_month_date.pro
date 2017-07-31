;+
;*****************************************************************************************
;
;  PROCEDURE:   doy_to_month_date.pro
;  PURPOSE  :   Determines month and day of month given the year and day of year (DOY).
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               (common block)
;               doy_mon_date_com1.pro
;
;  CALLS:
;               (common block)
;               doy_mon_date_com1.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               YEAR    :  Scalar [numeric] (or [N]-element array) defining the year to
;                            convert to a full calendar date (e.g., YYYY-MM-DD).
;                            Input values should vary between 0 <= YEAR <= 14699.
;               DOY     :  Scalar [numeric] (or [N]-element array) defining the day of
;                            year (DOY) to convert to a full calendar date.
;                            Input values should vary between 1 <= DOY <= 366.
;
;  OUTPUT:
;               MONTH   :  Set to a named variable to return the integer month of year
;                            (1 <= MONTH <= 12)
;               DATE    :  Set to a named variable to return the integer day of month
;                            (1 <= DATE <=  31)
;
;  EXAMPLES:    
;               [calling sequence]
;               doy_to_month_date,year,doy,month,date
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Davin changed something
;                                                                   [01/27/1997   v1.2.0]
;             2)  Updated Man. page and
;                 converted ()'s to []'s and
;                 added error handling
;                                                                   [06/09/2017   v1.2.1]
;             3)  Fixed a bug in the error handling
;                                                                   [07/11/2017   v1.2.2]
;
;   NOTES:      
;               1)  This procedure is a fast, vector oriented routine that returns the
;                     month and date given year and day of year (1 <= doy <= 366)
;               2)  List of initialisms/acronyms in for time conventions:
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
;               3)  SI Second = duration of 9,192,631,770 periods of the radiation
;                     corresponding to the transition between two hyperfine levels of
;                     the ground state of the cesium-133 atom.
;               4)  Unix time = # of seconds elapsed since Jan. 1, 1970 00:00:00 UTC
;                     **********************************
;                     *** not including leap seconds ***
;                     **********************************
;
;  REFERENCES:  
;              1a)  Fränz, M. and D. Harper "Heliospheric Coordinate Systems," 
;                     Planetary and Space Science Vol. 50, pp. 217--233, 2002.
;              1b)  Corrections to Fränz and Harper [2002] show that the numerical
;                     example in Appendix B should have said 16:46:00 TT, NOT
;                     16:46:00 UTC
;               2)  Simon, J.L., et. al., "Numerical Expressions for precession
;                     formulae and mean elements for the Moon and the planets,"
;                     Astron. Astrophys. Vol. 282, pp. 663-683, 1994.
;               3)  Lieske, J.H., et. al., "Expressions for the Precession Quantities
;                     Based upon the IAU (1976) System of Astronomical Constants,"
;                     Astron. Astrophys. Vol. 58, pages 1--16, 1977.
;
;   CREATED:  10/??/1996
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  07/11/2017   v1.2.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO doy_to_month_date,year,doy,month,date

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
;;  Define allowed number types
all_num_type   = [1,2,3,4,5,6,9,12,13,14,15]
;;----------------------------------------------------------------------------------------
;;  Load common block (avoids repititious computation if later called)
;;----------------------------------------------------------------------------------------
COMMON doy_mon_date_com1,months,dates
;;  Compute arrays of possible months of year and days of months, depending on leap year
IF NOT KEYWORD_SET(months) THEN BEGIN
  ;;  Define DOYs for first day of each month
  mdt            = [[0, 31,  59,  90, 120, 151, 181, 212, 243, 273, 304, 334, 365], $
                    [0, 31,  60,  91, 121, 152, 182, 213, 244, 274, 305, 335, 366]]
  ;;  Define dummy array of DOYs for every day of year
  doys           = [[INDGEN(366)],[INDGEN(366)]]
  ;;  Define dummy array of logic tests for leap year calculations
  isleap         = [[REPLICATE(0,366)],[REPLICATE(1,366)]]
  ;;  Define initial months of year estimates (update/correct below)
  months         = doys/29
  ;;  Define initial days of month estimates (update/correct below)
  dates          = doys - mdt[months,isleap]
  w              = WHERE(dates LT 0,c)  ;;  Check for values needing corrections
  IF (c[0] NE 0) THEN BEGIN
     months[w]    -= 1L
     dates[w]      = doys[w] - mdt[months[w],isleap[w]]
;     months(w) = months(w) -1
;     dates(w)  = doys(w) - mdt(months(w),isleap(w))
  ENDIF
  ;;  Adjust output to account for zeroth element indexing used by IDL
  months        += 1L
  dates         += 1L
  ;;  Old method below is slow as it requires IDL to create a dummy copy of the variable
;  months = months+1
;  dates  = dates +1
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;test           = (N_PARAMS() NE 1) OR (N_ELEMENTS(year) EQ 0) OR (N_ELEMENTS(doy) EQ 0)
test           = (N_PARAMS() LT 2) OR (N_ELEMENTS(year) EQ 0) OR (N_ELEMENTS(doy) EQ 0)
IF (test[0]) THEN RETURN
yt             = SIZE(year,/TYPE)
dt             = SIZE( doy,/TYPE)
;;  Check type
test           = (TOTAL(yt[0] EQ all_num_type) EQ 0) OR (TOTAL(dt[0] EQ all_num_type) EQ 0)
IF (test[0]) THEN RETURN
;;----------------------------------------------------------------------------------------
;;  Compute month of year and day of month
;;----------------------------------------------------------------------------------------
;;  Define leap year test and adjust DOY to zero
isleap         = ((year MOD 4) EQ 0) - ((year MOD 100) EQ 0) + ((year MOD 400) EQ 0) - $
                 ((year MOD 4000) EQ 0)
doyzero        = (doy - 1L)
;;  Compute month of year
month          = months[doyzero,isleap]
;;  Compute day of month
date           =  dates[doyzero,isleap]
;date           = dates(doy-1,isleap)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END


