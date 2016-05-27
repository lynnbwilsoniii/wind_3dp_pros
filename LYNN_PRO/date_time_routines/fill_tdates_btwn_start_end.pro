;+
;*****************************************************************************************
;
;  FUNCTION :   fill_tdates_btwn_start_end.pro
;  PURPOSE  :   This routine returns an array of dates (of the form 'YYYY-MM-DD') that
;                 comprise all the dates between an input start and end date (including
;                 the start and end date).
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               test_tdate_format.pro
;               str_valid_num.pro
;               time_double.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TDATE_ST  :  Scalar [string] defining the start date of the form:
;                              'YYYY-MM-DD' [MM=month, DD=day, YYYY=year]
;               TDATE_EN  :  Scalar [string] defining the end date of the form:
;                              'YYYY-MM-DD' [MM=month, DD=day, YYYY=year]
;
;  EXAMPLES:    
;               [calling sequence]
;               tdates = fill_tdates_btwn_start_end( tdate_st, tdate_en)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The input dates must have the correct format and be valid, numeric
;                     string dates
;
;  REFERENCES:  
;               NA
;
;   CREATED:  04/20/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/20/2016   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION fill_tdates_btwn_start_end,tdate_st,tdate_en

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
start_of_day   = '00:00:00.000'
end___of_day   = '23:59:59.999'
ndy            = 31L                                         ;;  # of days to print
nmn            = 12L                                         ;;  # of months to print
mdt            = [[0, 31,  59,  90, 120, 151, 181, 212, 243, 273, 304, 334, 365], $
                  [0, 31,  60,  91, 121, 152, 182, 213, 244, 274, 305, 335, 366]]
dnel           = LINDGEN(N_ELEMENTS(mdt[*,0]) - 1L)
upel           = dnel + 1L
days_per_mon   = mdt[upel,*] - mdt[dnel,*]
;;  Error messages
noinput_mssg   = 'User must supply a start and end date...'
incorrf_mssg   = 'Incorrect input format:  TDATE_ST and TDATE_EN must be scalar strings...'
badform_mssg   = "Incorrect input format:  TDATE_ST and TDATE_EN must have the form 'YYYY-MM-DD'"
badnumb_mssg   = "Incorrect input format:  TDATE_ST and TDATE_EN must be numeric strings the form 'YYYY-MM-DD'"
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2)
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (SIZE(tdate_st,/TYPE) NE 7) OR (SIZE(tdate_en,/TYPE) NE 7)
IF (test[0]) THEN BEGIN
  MESSAGE,incorrf_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check TDATE format
test           = (test_tdate_format(tdate_st,/NOMSSG) EQ 0) OR $
                 (test_tdate_format(tdate_en,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,badform_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
yr_st_en       = STRMID([tdate_st[0],tdate_en[0]],0L,4L)
;;  Make sure inputs are numeric strings
test           = (str_valid_num(yr_st_en[0],/INTEGER) EQ 0) OR $
                 (str_valid_num(yr_st_en[1],/INTEGER) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,badnumb_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define all dates between
;;----------------------------------------------------------------------------------------
ymdb_st        = tdate_st[0]+'/'+start_of_day[0]
ymdb_en        = tdate_en[0]+'/'+end___of_day[0]
unix_sten      = time_double([ymdb_st[0],ymdb_en[0]])
yr_sten_l      = LONG(yr_st_en)
nyr            = yr_sten_l[1] - yr_sten_l[0] + 1L            ;;  # of years in range
;;  Create dummy arrays for days, months, and years
all_days       = LINDGEN(ndy[0]) + 1L                        ;;  day of month
all_months     = LINDGEN(nmn[0]) + 1L                        ;;  month of year
all_years      = LINDGEN(nyr[0]) + yr_sten_l[0]              ;;  years
;;  Convert to strings
all_dstr       = STRING(FORMAT='(I2.2)',all_days)
all_mstr       = STRING(FORMAT='(I2.2)',all_months)
all_ystr       = STRING(FORMAT='(I4.4)',all_years)
;;  Define whether leap year = TRUE
isleap         = ((all_years MOD 4)   EQ 0) - ((all_years MOD 100)  EQ 0) +  $
                 ((all_years MOD 400) EQ 0) - ((all_years MOD 4000) EQ 0)
;;  Define all TDATES
dfstring       = STRARR(nyr,nmn,ndy + 1L)  ;;  e.g. '1994-11-01'
FOR yy=0L, nyr[0] - 1L DO BEGIN      ;;  Years
  FOR mm=0L, nmn[0] - 1L DO BEGIN    ;;  Months
    max_dd = days_per_mon[mm[0],isleap[yy[0]]] - 1L
    FOR dd=0L, max_dd[0] DO BEGIN    ;;  Days
      dfstring[yy,mm,dd] = all_ystr[yy[0]]+'-'+all_mstr[mm[0]]+'-'+all_dstr[dd[0]]
    ENDFOR
  ENDFOR
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Keep only valid elements and sort
;;----------------------------------------------------------------------------------------
df_ymdb        = dfstring+'/'+start_of_day[0]
df_unix        = time_double(df_ymdb)
dfstr1d        = REFORM(dfstring,nyr[0]*nmn[0]*(ndy[0] + 1L))
dfunx1d        = REFORM(df_unix,nyr[0]*nmn[0]*(ndy[0] + 1L))
sp             = SORT(dfunx1d)
all_tdates_str = dfstr1d[sp]
all_unix_sort  = dfunx1d[sp]
good_td        = WHERE(all_tdates_str NE '',gd)
IF (gd GT 0) THEN BEGIN
  all_tdates_0   = all_tdates_str[good_td]
  all_unix_gd    = all_unix_sort[good_td]
  ;;  Keep only within time range of TDATE_ST and TDATE_EN
  test           = (all_unix_gd GE unix_sten[0]) AND (all_unix_gd LE unix_sten[1])
  good           = WHERE(test,gd)
  IF (gd GT 0) THEN BEGIN
    all_tdates_gd  = all_tdates_0[good]
  ENDIF ELSE BEGIN
    all_tdates_gd  = ''
  ENDELSE
ENDIF ELSE BEGIN
  all_tdates_gd  = ''
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Passed test --> Return to user
;;----------------------------------------------------------------------------------------

RETURN,all_tdates_gd
END
