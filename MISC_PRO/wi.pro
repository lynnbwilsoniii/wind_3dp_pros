;+
;*****************************************************************************************
;
;  FUNCTION :   wi.pro
;  PURPOSE  :   Switch or open windows in a slightly easier manner than using the IDL
;                 built-in WINDOW.PRO routine.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               dprint.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               WNUM       :  Scalar defining the number of the window to either switch
;                               to or open
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:  
;               LIMITS     :  TPLOT structure for plot options
;               WSIZE      :  [2]-Element array specifying the window size
;               WPOSITION  :  [2]-Element array specifying the window position
;               SHOW       :  If set, then routine calls WSHOW.PRO
;               _EXTRA     :  See IDL documentation on keyword inheritance
;
;   CHANGED:  1)  Created by REE                                   [10/23/1995   v1.0.6]
;             2)  I did something??                                [09/19/2007   v1.0.7]
;             3)  Re-wrote and cleaned up                          [06/10/2009   v1.1.0]
;             4)  Fixed typo in man page                           [06/19/2009   v1.1.1]
;             5)  Updated to be in accordance with newest version of box.pro
;                   in TDAS IDL libraries
;                   A)  Added keywords:  WSIZE, WPOSITION, SHOW, and _EXTRA
;                   B)  no longer calls data_type.pro or str_element.pro
;                   C)  now calls dprint.pro
;                                                                  [04/03/2012   v1.2.0]
;
;   CREATED:  10/23/1995
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/03/2012   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO wi,wnum,LIMITS=lim,WSIZE=wsize,WPOSITION=wposition,SHOW=show,_EXTRA=ex

;IF (data_type(lim) EQ 8) THEN BEGIN
;   str_element,lim,'WINDOW',VALUE=wnum
;   IF (N_ELEMENTS(wnum) EQ 0) THEN RETURN
;   IF (wnum LT 0) THEN RETURN
;ENDIF

IF (!D.FLAGS AND 256) EQ 0 THEN BEGIN          ; device has no windows!
  dprint,'Device has no windows!'
  RETURN
ENDIF

IF (N_ELEMENTS(wnum) EQ 0) THEN BEGIN
  wnum = !D.WINDOW
  dprint,'Current window is: ',wnum,FORMAT='(a,i0)'
ENDIF
; => get the window state
DEVICE,WINDOW_STATE=windows
s = windows[wnum > 0]

IF (s EQ 1) THEN BEGIN
  WSET,wnum
  IF NOT KEYWORD_SET(wsize) THEN wsize = [!D.X_SIZE,!D.Y_SIZE]
  IF (wsize[0] NE !D.X_SIZE OR wsize[1] NE !D.Y_SIZE) THEN s = 0
ENDIF

IF (s EQ 0) THEN BEGIN
  IF KEYWORD_SET(wposition) THEN BEGIN
    xpos = wposition[0]
    ypos = wposition[1]
  ENDIF
  IF KEYWORD_SET(wsize) THEN BEGIN
    WINDOW,wnum > 0,XSIZE=wsize[0],YSIZE=wsize[1],XPOS=xpos,YPOS=ypos,_EXTRA=ex
  ENDIF ELSE BEGIN
    WINDOW,wnum > 0,_EXTRA=ex
  ENDELSE
ENDIF

IF KEYWORD_SET(show) THEN WSHOW

;i = 0
;CATCH, no_window
;IF (no_window EQ 0) THEN BEGIN
;    IF (N_ELEMENTS(wnum) EQ 0) THEN BEGIN
;      WSHOW,ICONIC=0
;    ENDIF ELSE BEGIN
;       WSET, wnum
;       WSHOW,wnum, ICONIC=0
;    ENDELSE
;ENDIF ELSE BEGIN
;    IF (i) THEN BEGIN & PRINT, "WI: Can't change window." & RETURN & ENDIF
;    i = 1
;    WINDOW, wnum, RETAIN=2   ; => RETAIN keyword defines who/what keeps info on the window
;    WSHOW, wnum, ICONIC=0
;ENDELSE
;
;CATCH,/CANCEL

RETURN
END

