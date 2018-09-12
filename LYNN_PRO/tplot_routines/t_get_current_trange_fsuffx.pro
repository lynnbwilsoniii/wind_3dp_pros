;+
;*****************************************************************************************
;
;  FUNCTION :   t_get_current_trange_fsuffx.pro
;  PURPOSE  :   This is a shorthand routine that acts as a wrapper for both
;                 file_name_times.pro and t_get_current_trange.pro to output a
;                 string time range to use as a suffix for a file name when saving
;                 a plot.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               t_get_current_trange.pro
;               file_name_times.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               fsuffx = t_get_current_trange_fsuffx([,PREC=prec] [,FORMFN=formfn] [,/KEEPDATE])
;
;  KEYWORDS:    
;               KEEPDATE  :  If set, routine will ignore a repeated date and keep both
;                              dates before UTC times in the output string.  If the time
;                              range spans more than one date, this keyword is irrelevant.
;                              [Default = FALSE]
;               ;;  **************************************
;               ;;  Keywords for file_name_times.pro
;               ;;  **************************************
;               PREC      :  Scalar [numeric] defining the number of decimal places to
;                              use for the fractional seconds
;                              [Default = 3]
;               FORMFN    :  Scalar [integer] defining the output form of the F_TIME tag
;                              Example:  For PREC = 3 and the following SCET:
;                                        '2000-04-10/15:10:33.013'
;                              1 = '2000-04-10_1510x33.013'  [Default]
;                              2 = '2000-04-10_1510-33x013'
;                              3 = '20000410_1510-33x013'
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See also:  file_name_times.pro and t_get_current_trange.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/04/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/04/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION t_get_current_trange_fsuffx,PREC=prec,FORMFN=formfn,KEEPDATE=keepdate

;;----------------------------------------------------------------------------------------
;;  Define some defaults
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
no_inpt_msg    = 'User must have loaded and plotted some data in TPLOT...'
;;----------------------------------------------------------------------------------------
;;  Get current time range
;;----------------------------------------------------------------------------------------
tran           = t_get_current_trange()
;;  Check results
IF (TOTAL(FINITE(tran)) NE 2) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check KEEPDATE
IF KEYWORD_SET(keepdate) THEN dropdate = 0b ELSE dropdate = 1b
;;----------------------------------------------------------------------------------------
;;  Get file name formatted output
;;----------------------------------------------------------------------------------------
fnm            = file_name_times(tran,PREC=prec,FORMFN=formfn)
ftimes         = fnm.F_TIME              ;;  e.g., '1998-08-09_0801x09.494'
tdates         = STRMID(ftimes,0L,10L)   ;;  e.g., '1998-08-09'
out1day        = ftimes[0]+'_to_'+STRMID(ftimes[1],11L)
out2day        = ftimes[0]+'_to_'+ftimes[1]
;;  Define output
oneday         = (tdates[0] EQ tdates[1])
IF (oneday[0]) THEN BEGIN
  ;;  Only one unique day --> do not repeat date
  IF (dropdate[0]) THEN tsuffx = out1day[0] ELSE tsuffx = out2day[0]
ENDIF ELSE BEGIN
  ;;  Multiple unique days --> keep each date
  tsuffx         = out2day[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,tsuffx
END





