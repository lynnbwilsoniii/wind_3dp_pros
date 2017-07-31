;+
;*****************************************************************************************
;
;  FUNCTION :   vbulk_change_test_windn.pro
;  PURPOSE  :   This routine tests the user defined device window number against all
;                 open and active device windows to ensure plotting and cursor-
;                 selection can be used by other routines.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Vbulk Change IDL Libraries
;
;  INPUT:
;               WINDN    :  Scalar [numeric] defining the currently set device window
;                             to use when plotting or selecting the region of interest
;                             with the cursor
;                             [Default = !D.WINDOW]
;
;  EXAMPLES:    
;               [calling sequence]
;               test = vbulk_change_test_windn(windn [,DAT_OUT=dat_out])
;
;  KEYWORDS:    
;               DAT_OUT    :  Set to a named variable to return the actual device
;                               window to use
;                               (should only vary from WINDN if user makes a mistake0
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This is meant to be called by other routines within the
;                     Vbulk Change library of routines
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/17/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/17/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION vbulk_change_test_windn,windn,DAT_OUT=dat_out

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define allowed plot device names
good_dname     = ['x','win']
;;  Define some device settings
def_win        = !D.WINDOW[0]            ;;  default/current device window #
dev_nme        = !D.NAME[0]              ;;  current device name (e.g., 'X')
;;  Initialize outputs
dat_out        = -1
;;  Dummy error messages
badplt_msg     = "The plot device must be set to 'X' or 'WIN'..."
badinp_msg     = 'WINDN must be a scalar [numeric] value defining the currently used/active device window...'
nowind_msg     = 'There must be an active window display currently set and in use...'
badwin_msg     = 'WINDN must match an active device window ...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  First check device settings
test           = (TOTAL(STRLOWCASE(dev_nme[0]) EQ good_dname) LT 1)
IF (test[0]) THEN BEGIN
  ;;  User is currently using 'PS' or some other non-plotting-to-screen setting
  MESSAGE,badplt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check WINDN
test           = (is_a_number(windn,/NOMSSG) EQ 0) OR (N_ELEMENTS(windn) NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,badinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Find all open device windows
DEVICE,WINDOW_STATE=wstate
n_state        = N_ELEMENTS(wstate)        ;;  # of potential windows
n_win_open     = LONG(TOTAL(wstate))       ;;  # of currently open windows
good_w         = WHERE(wstate,gd_w)        ;;  Indices of open windows from window array
test           = (n_win_open[0] LT 1) OR (gd_w[0] EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,nowind_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check if WINDN matches open windows
IF (N_ELEMENTS(windn)  NE 1) THEN win  = def_win[0] ELSE win  = windn[0]
test           = (win[0] LT 0) OR (def_win[0] LT 0) OR (TOTAL(good_w EQ win[0]) LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,badwin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define output keyword DAT_OUT
;;----------------------------------------------------------------------------------------
dat_out        = windn[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END
