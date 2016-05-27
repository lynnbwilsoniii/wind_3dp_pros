;+
;*****************************************************************************************
;
;  FUNCTION :   t_get_current_trange.pro
;  PURPOSE  :   This routine returns the current time range (Unix) in the active
;                 IDL window with TPLOT data shown.  This is useful for quickly finding
;                 the time range of the plotted data if you wish to keep track of that
;                 for later (e.g., use in a saved file name of the plot).
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tnames.pro
;               tplot_com.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ;;  ...assume you have loaded data into TPLOT...
;               ;;  Plot some of the variables
;               tplot,[1,2]
;               ;;  Now get the time range for the current plot
;               trange = t_get_current_trange()
;               ;;  Make sure it worked [bad returns are NaNs
;               test   = FINITE(TOTAL(trange))
;               IF (test EQ 0) THEN PRINT,'Something went wrong...'
;               ;;  If you see this message printed to the screen, then it failed...
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  TPLOT data must be loaded and at least one variable must be plotted
;                     prior to calling this routine
;               2)  See also:  tlimit.pro, ctime.pro, set_tplot_times.pro, etc.
;
;  REFERENCES:  
;               
;
;   CREATED:  08/23/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/23/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION t_get_current_trange

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
no_tplot       = 'You must first load some data into TPLOT!'
no_plot        = 'You must first plot something in TPLOT!'
;;----------------------------------------------------------------------------------------
;;  Make sure TPLOT variables exist
;;----------------------------------------------------------------------------------------
tpn_all        = tnames()
IF (tpn_all[0] EQ '') THEN BEGIN
  MESSAGE,no_tplot[0],/INFORMATIONAL,/CONTINUE
  RETURN,[d,d]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Load common block
;;----------------------------------------------------------------------------------------
@tplot_com.pro
;; => Determine current settings
str_element,tplot_vars, 'OPTIONS',opts
str_element,tplot_vars,'SETTINGS',sets
test           = (SIZE(opts,/TYPE) NE 8) OR (SIZE(sets,/TYPE) NE 8)
IF (test) THEN BEGIN
  MESSAGE,no_tplot[0],/INFORMATIONAL,/CONTINUE
  RETURN,[d,d]
ENDIF
;;  Get info from OPTIONS structure
str_element,opts,     'TRANGE',trange
str_element,opts,'TRANGE_FULL',trange_full
;;  Get info from SETTINGS structure
str_element,sets, 'TRANGE_OLD',trange_old
str_element,sets, 'TIME_SCALE',time_scale
str_element,sets,'TIME_OFFSET',time_offset
str_element,sets,          'X',data_test

;;----------------------------------------------------------------------------------------
;;  Check set values
;;----------------------------------------------------------------------------------------
test0          = (N_ELEMENTS(trange) EQ 0)
test1          = (SIZE(data_test,/TYPE) NE 8)
test           = [test0,test1,test0 AND test1]
good           = WHERE(test,gd)
IF (test[2]) THEN BEGIN
  ;;  no TPLOT data plotted
  MESSAGE,no_plot[0],/INFORMATIONAL,/CONTINUE
  RETURN,[d,d]
ENDIF ELSE BEGIN
  ;;  TPLOT data plotted
  IF (gd EQ 1) THEN BEGIN
    ;;  One or the other is not set
    CASE good[0] OF
      0L  :  BEGIN
        test2 = (N_ELEMENTS(time_scale) NE 0) AND (N_ELEMENTS(time_offset) NE 0)
        IF (test2) THEN BEGIN
          ;;  Use the plot to define time range
          tr = data_test.CRANGE*time_scale[0] + time_offset[0]
        ENDIF ELSE BEGIN
          ;;  Cannot determine time range
          badtr_mssg = 'Cannot determine time range... time scale and offset are undefined!'
          MESSAGE,badtr_mssg[0],/INFORMATIONAL,/CONTINUE
          RETURN,[d,d]
        ENDELSE
      END
      1L  :  tr = trange
    ENDCASE
  ENDIF ELSE BEGIN
    ;;  Both are set
    test2 = (N_ELEMENTS(time_scale) NE 0) AND (N_ELEMENTS(time_offset) NE 0)
    IF (test2) THEN BEGIN
      ;;  Use the plot to define time range and compare to TRANGE
      tr0   = data_test.CRANGE*time_scale[0] + time_offset[0]
      tr1   = trange
      test3 = TOTAL(tr1 - tr0) NE 0
      IF (test3) THEN BEGIN
        ;;  Something is wrong with either plot settings or set time range...
        badtr_mssg = 'Something is wrong, either with !X.CRANGE, TIME_SCALE, TIME_OFFSET, or TRANGE...'
        MESSAGE,badtr_mssg[0],/INFORMATIONAL,/CONTINUE
        RETURN,[d,d]
      ENDIF ELSE BEGIN
        ;;  Things check out, so define time range
        tr = trange
      ENDELSE
    ENDIF ELSE BEGIN
      ;;  Just use TRANGE
      tr = trange
    ENDELSE
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return time range
;;----------------------------------------------------------------------------------------

RETURN,tr
END

