;+
;*****************************************************************************************
;
;  PROCEDURE:   t_tr_nplfz.pro
;  PURPOSE  :   This routine is a wrapping routine for tlimit.pro and other TPLOT-based
;                 routines meant to make it easier to quickly change the current time
;                 range to:  the next (n) of equal length to the current;  to the
;                 previous (p) range of equal length to the current;  to the last (l)
;                 time range used (i.e., tlimit,/LAST); to the full (f) time range
;                 available for the currently plotted data  (i.e., tlimit,/FULL); and
;                 to zoom in/out by some fraction of unity to be multiplied by the
;                 current time range.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               t_get_current_trange.pro
;               tnames.pro
;               is_a_number.pro
;               tlimit.pro
;               t_print_current_trange.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ;;  Zoom to next time window
;               t_tr_nplfz,/NEXT
;               ;;  Zoom to previous time window
;               t_tr_nplfz,/PREVIOUS
;               ;;  Zoom to the last plotted time window
;               t_tr_nplfz,/LAST
;               ;;  Zoom to the full allowed time window
;               t_tr_nplfz,/FULL
;               ;;  Zoom in to a window 1/2 current time duration
;               t_tr_nplfz,T_ZOOM=0.5
;               ;;  Zoom out to a window 4 times current time duration
;               t_tr_nplfz,T_ZOOM=4e0
;               ;;  Pan to the right by 4 seconds, keeping the same time duration
;               t_tr_nplfz,DT_PAN=4e0
;               ;;  Pan to the left by 40 milliseconds, keeping the same time duration
;               t_tr_nplfz,DT_PAN=-40e-3
;
;  KEYWORDS:    
;               NEXT      :  If set, routine will shift the TPLOT time range such that
;                              the new range will be of equal length to the current, but
;                              it will start at the end of the current.  In other words,
;                              this keyword shifts the time window to the right one
;                              full unit.
;                              [Default = FALSE]
;               PREVIOUS  :  If set, routine will shift the TPLOT time range such that
;                              the new range will be of equal length to the current, but
;                              it will end at the start of the current.  Similar to the
;                              effect of NEXT, but PREVIOUS will shift the time window
;                              to the left.
;                              [Default = FALSE]
;               LAST      :  If set, routine will call tlimit,/LAST, which will set the
;                              time range to the previously plotted time range set in
;                              the TPLOT common block defined by tplot_com.pro
;                              [Default = FALSE]
;               FULL      :  If set, routine will call tlimit,/FULL, which will set the
;                              time range to the full time range of the loaded data sets
;                              for the current TPLOT session, stored in the TPLOT common
;                              block defined by tplot_com.pro
;                              [Default = FALSE]
;               T_ZOOM    :  Scalar [float/double] defining the zoom factor to apply to
;                              the current time range.  For instance, to reduce the time
;                              range to 1/2 its current value, set T_ZOOM=0.5.
;                              [Default = 1.0]
;               DT_PAN    :  Scalar [float/double] defining the number of seconds to in
;                              which to shift the time window, keeping the current time
;                              duration, to the left (values < 0) or right (values > 0).
;                              The value should be in fractional seconds since the time
;                              stamps in TPLOT are Unix times.
;                              [Default = 0.0]
;               PRINT_NT  :  If set, routine will print new time range to the screen if
;                              successful
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The order of priority in keywords is the following:
;                     1  :  NEXT
;                     2  :  PREVIOUS
;                     3  :  LAST
;                     4  :  FULL
;                     5  :  T_ZOOM
;                     6  :  DT_PAN
;               2)  See also:  t_get_current_trange.pro, tlimit.pro, ctime.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/14/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/14/2015   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO t_tr_nplfz,NEXT=next,PREVIOUS=previous,LAST=last,FULL=full,T_ZOOM=t_zoom,$
               DT_PAN=dt_pan,PRINT_NT=print_nt

;;  Let IDL know that the following are functions
FORWARD_FUNCTION t_get_current_trange, tnames, is_a_number
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
log_key_on     = REPLICATE(0b,6)
;;  Dummy error messages
no_inpt_msg    = 'User did not set any keywords  -->  returning without affecting time range'
no_tplot       = 'You must first load some data into TPLOT!'
no_plot        = 'You must first plot something in TPLOT!'
;;----------------------------------------------------------------------------------------
;;  Check to see if TPLOT has started
;;----------------------------------------------------------------------------------------
cur_tr         = t_get_current_trange()
test           = (TOTAL(tnames() NE '') LT 1) OR (TOTAL(FINITE(cur_tr)) LT 2)
IF (test[0]) THEN BEGIN
  MESSAGE,no_tplot[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Define current time duration
cur_dur        = MAX(cur_tr,/NAN) - MIN(cur_tr,/NAN)
test           = (cur_dur[0] LE 0) OR (FINITE(cur_dur[0]) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_plot[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NEXT
test           = (N_ELEMENTS(next) GT 0) AND KEYWORD_SET(next)
IF (test[0]) THEN log_key_on[0] = 1b
;;  Check PREVIOUS
test           = (N_ELEMENTS(previous) GT 0) AND KEYWORD_SET(previous)
IF (test[0]) THEN log_key_on[1] = 1b
;;  Check LAST
test           = (N_ELEMENTS(last) GT 0) AND KEYWORD_SET(last)
IF (test[0]) THEN log_key_on[2] = 1b
;;  Check FULL
test           = (N_ELEMENTS(full) GT 0) AND KEYWORD_SET(full)
IF (test[0]) THEN log_key_on[3] = 1b
;;  Check T_ZOOM
test           = (N_ELEMENTS(t_zoom) GT 0) AND is_a_number(t_zoom,/NOMSSG)
IF (test[0]) THEN log_key_on[4] = 1b
;;  Check DT_PAN
test           = (N_ELEMENTS(dt_pan) GT 0) AND is_a_number(dt_pan,/NOMSSG)
IF (test[0]) THEN log_key_on[5] = 1b
;;  Check PRINT_NT
test           = (N_ELEMENTS(print_nt) GT 0) AND KEYWORD_SET(print_nt)
IF (test[0]) THEN output_nt = 1b ELSE output_nt = 0b
;;----------------------------------------------------------------------------------------
;;  Determine new time range
;;----------------------------------------------------------------------------------------
good           = WHERE(log_key_on,gd)
CASE good[0] OF
  0L    :  BEGIN
    ;;  Switch to NEXT time range
    new_tr = MAX(cur_tr,/NAN) + [0d0,1d0]*cur_dur[0]
  END
  1L    :  BEGIN
    ;;  Switch to PREVIOUS time range
    new_tr = MIN(cur_tr,/NAN) - [1d0,0d0]*cur_dur[0]
  END
  2L    :  BEGIN
    ;;  Switch to LAST plotted time range
    tlimit,/LAST
    IF (output_nt[0]) THEN t_print_current_trange
    RETURN
  END
  3L    :  BEGIN
    ;;  Switch to FULL available time range
    tlimit,/FULL
    IF (output_nt[0]) THEN t_print_current_trange
    RETURN
  END
  4L    :  BEGIN
    ;;  Zoom in/out to T_ZOOM factor of current time range
    cur_mid = MEAN(cur_tr,/NAN)      ;;  current time window center
    new_dur = cur_dur[0]*ABS(t_zoom[0])
    new_tr  = cur_mid[0] + [-1d0,1d0]*new_dur[0]/2d0
  END
  5L    :  BEGIN
    ;;  Pan to the left or right by DT_PAN
    new_tr  = cur_tr + REAL_PART(dt_pan[0])
  END
  ELSE  :  BEGIN
    ;;  Nothing set --> do nothing
    MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
    RETURN
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Apply results
;;----------------------------------------------------------------------------------------
tlimit,new_tr
IF (output_nt[0]) THEN t_print_current_trange
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END


