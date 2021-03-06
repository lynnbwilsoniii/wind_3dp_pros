;+
;*****************************************************************************************
;
;  PROCEDURE:   day_to_year_doy.pro
;  PURPOSE  :   Converts a Julian day (i.e., day since 0000 AD) to a day of year (DOY)
;                 and year since 0 AD.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               DAYNUM  :  Scalar [numeric] (or [N]-element array) defining the Julian day
;                            number(s) to be converted to year and day of year values.
;                            Input should be a long-integer form.
;
;  OUTPUT:
;               YEAR    :  Set to a named variable to return the integer year
;                            (0 <= year <= 14699 AD)
;               DOY     :  Set to a named variable to return the integer day of year
;                            (1 <= doy  <=  366)
;
;  EXAMPLES:    
;               [calling sequence]
;               day_to_year_doy,daynum,year,doy
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
;               1)  This procedure is reasonably fast, it works on arrays and works from
;                     0 AD to 14699 AD
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

PRO day_to_year_doy,daynum,y,d

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
;;  Define allowed number types
all_num_type   = [1,2,3,4,5,6,9,12,13,14,15]
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (N_ELEMENTS(daynum) EQ 0)
;test           = (N_PARAMS() NE 1) OR (N_ELEMENTS(daynum) EQ 0)
IF (test[0]) THEN RETURN
xt             = SIZE(daynum,/TYPE)
;;  Check type
test           = (TOTAL(xt[0] EQ all_num_type) EQ 0)
IF (test[0]) THEN RETURN
;;  Make sure input is integer
day            = FLOOR(daynum)
;;----------------------------------------------------------------------------------------
;;  Convert to year and day of year (DOY)
;;----------------------------------------------------------------------------------------
;;  Get year correctly to within one year
y              = (day*400L)/(365L*400L + 100L - 4L + 1L)
;;  Get DOY based on the year
d              = day - (y*365L + y/4L - y/100L + y/400L - y/4000L)
;;  Fix any issues with leap years or large values
w              = WHERE(d GE 365,c)  ;;  check if corrections are necessary
IF (c[0] NE 0) THEN BEGIN
  y[w]         += 1L
  d[w]          = day[w] - (y[w]*365L + y[w]/4L - y[w]/100L + y[w]/400L - y[w]/4000L)
;   y(w) = y(w) +1
;   d(w) = day(w) - (y(w)*365 + y(w)/4 - y(w)/100 + y(w)/400 - y(w)/4000)
ENDIF
;;  Check if more corrections are necessary
w              = WHERE(d LT 0,c)
IF (c[0] NE 0) THEN BEGIN
  y[w]         -= 1L
  d[w]          = day[w] - (y[w]*365L + y[w]/4L - y[w]/100L + y[w]/400L - y[w]/4000L)
;   y(w) = y(w) -1 
;   d(w) = day(w) - (y(w)*365 + y(w)/4 - y(w)/100 + y(w)/400 - y(w)/4000)
ENDIF
;;  Adjust output to account for zeroth element indexing used by IDL
y             += 1L
d             += 1L
;;  Old method below is slow as it requires IDL to create a dummy copy of the variable
;y = y+1
;d = d+1
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END


