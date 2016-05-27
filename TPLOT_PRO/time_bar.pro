;+
;*****************************************************************************************
;
;  FUNCTION :   time_bar.pro
;  PURPOSE  :   Plots vertical lines at specific times on an existing tplot panel.
;
;  CALLED BY:   NA
;
;  CALLS:
;               tplot_com.pro
;               time_double.pro
;               str_element.pro
;               time_string.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               T1         :  M-Element array of Unix times (seconds since Jan, 1st 1970)
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               COLOR      :  N-Element byte array of color values
;               LINESTYLE  :  N-Element integer array of line styles
;               THICK      :  N-Element integer array of line thickness values
;               VERBOSE    :  If set, print more error messages (??)
;               VARNAME    :  Set to TPLOT name for which vertical lines will be plotted
;                               else, lines plot over all plots
;               BETWEEN    :  2-Element string array of TPLOT names specifying the plots
;                               between which to plot a vertical line
;               TRANSIENT  :  Called once, plots a time bar, twice erases time bar
;                                Note:  1) all other keywords except VERBOSE
;                                be the same for both calls. 2) COLOR will most
;                                likely not come out what you ask for, but
;                                since it's transient anyway, shouldn't matter.
;
;   CHANGED:  1)  Created by Frank V. Marcoline   [??/??/????   v1.0.0]
;             2)  Modified by Frank V. Marcoline  [01/21/1999   v1.0.9]
;             3)  Rewrote Program (no functional changes, just cleaned up)
;                                                 [04/20/2009   v2.0.0]
;             4)  Fixed syntax error              [04/22/2009   v2.0.1]
;             5)  Changed to allow for multiple TPLOT names upon input with keyword
;                   VARNAME                       [06/02/2009   v2.0.2]
;             6)  Updated man page                [06/17/2009   v2.1.0]
;             7)  Fixed an issue regarding un-sorted VARNAME inputs
;                                                 [10/08/2008   v2.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Frank V. Marcoline
;    LAST MODIFIED:  10/08/2008   v2.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO time_bar,t1,COLOR=color,LINESTYLE=linestyle,THICK=thick,VERBOSE=verbose,$
                VARNAME=varname,BETWEEN=between,TRANSIENT=transient

;-----------------------------------------------------------------------------------------
; -Determine default parameters
;-----------------------------------------------------------------------------------------
@tplot_com
t  = time_double(t1)
nt = N_ELEMENTS(t)
IF NOT KEYWORD_SET(COLOR) THEN BEGIN
  IF (!P.BACKGROUND EQ 0) THEN color = !D.N_COLORS - 1 ELSE color = 0
ENDIF
IF (N_ELEMENTS(color) NE nt) THEN color = MAKE_ARRAY(nt,VALUE=color)
IF NOT KEYWORD_SET(linestyle) THEN linestyle = 0
IF (N_ELEMENTS(linestyle) NE nt) THEN linestyle = MAKE_ARRAY(nt,VALUE=linestyle)
IF NOT KEYWORD_SET(thick) THEN thick = 1
IF (N_ELEMENTS(thick) NE nt) THEN thick = MAKE_ARRAY(nt,VALUE=thick)
;-----------------------------------------------------------------------------------------
; -Determine X-Windows info
;-----------------------------------------------------------------------------------------
IF (!D.NAME EQ 'X' OR !D.NAME EQ 'WIN') THEN BEGIN
  IF (!D.WINDOW NE tplot_vars.SETTINGS.WINDOW[0]) THEN BEGIN
    IF (tplot_vars.SETTINGS.WINDOW[0] GE 0) THEN BEGIN
      current_window = tplot_vars.SETTINGS.WINDOW[0]
      WSET,tplot_vars.SETTINGS.WINDOW[0]
    ENDIF ELSE BEGIN
      current_window = !D.WINDOW > 0
      WSET,current_window
    ENDELSE
  ENDIF ELSE BEGIN
    current_window = !D.WINDOW > 0
    WSET,tplot_vars.SETTINGS.WINDOW[0]
  ENDELSE
ENDIF
str_element,tplot_vars,'SETTINGS.X.WINDOW',xp
str_element,tplot_vars,'SETTINGS.X.CRANGE',xr
nd1 = N_ELEMENTS(tplot_vars.SETTINGS.Y) - 1L
nd0 = 0
;-----------------------------------------------------------------------------------------
; => Determine if multiple or many plots to put vertical lines over
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(varname) THEN BEGIN
  vnames = tnames(varname,INDEX=ind)
;  vnames = REFORM(varname)
  ; => Check order of input names
  svp    = SORT(ind)
  vnames = vnames[svp]
ENDIF ELSE BEGIN
  vnames = tplot_vars.SETTINGS.VARNAMES
ENDELSE
IF KEYWORD_SET(vnames) THEN ntp = N_ELEMENTS(vnames) ELSE ntp = 1L

FOR j=0L, ntp - 1L DO BEGIN
  IF KEYWORD_SET(vnames) THEN BEGIN
    temp_names = tplot_vars.OPTIONS.VARNAMES
    nd         = (WHERE(vnames[j] EQ temp_names))[0]
    IF (nd[0] LT 0) THEN GOTO,JUMP_SKIP
    nd0        = nd
    nd1        = nd
  ENDIF
  nt = N_ELEMENTS(t)
  yp = FLTARR(2)
  ; => Check indecies...
  IF (nd0[0] LT 0 OR nd1[0] LT 0) THEN GOTO,JUMP_SKIP
  
  IF (KEYWORD_SET(between) EQ 0) THEN BEGIN
    yp[0] = tplot_vars.SETTINGS.Y[nd1].WINDOW[0]
    yp[1] = tplot_vars.SETTINGS.Y[nd0].WINDOW[1]
  ENDIF ELSE BEGIN
    nd0   = (WHERE(between[0] EQ tplot_vars.OPTIONS.VARNAMES))[0]
    nd1   = (WHERE(between[1] EQ tplot_vars.OPTIONS.VARNAMES))[0]
    yp[0] = tplot_vars.SETTINGS.Y[nd1].WINDOW[1]
    yp[1] = tplot_vars.SETTINGS.Y[nd0].WINDOW[0]
  ENDELSE

  IF KEYWORD_SET(transient) THEN BEGIN
    DEVICE, GET_GRAPHICS=ograph,SET_GRAPHICS=6
  ENDIF
  
  FOR i=0L, nt - 1L DO BEGIN
    tp = t[i] - tplot_vars.SETTINGS.TIME_OFFSET
    tp = xp[0] + (tp - xr[0])/(xr[1] - xr[0])*(xp[1] - xp[0])
    IF (tp GE xp[0] AND tp LE xp[1]) THEN BEGIN
      PLOTS,[tp,tp],yp,COLOR=color[i],LINESTYLE=linestyle[i],THICK=thick[i],/NORMAL
    ENDIF ELSE BEGIN
      IF KEYWORD_SET(verbose) THEN PRINT,'Time '+time_string(t(i))+' is out of trange.'
    ENDELSE
  ENDFOR
  
  IF KEYWORD_SET(transient) THEN DEVICE,SET_GRAPHICS=ograph
  ;=======================================================================================
  JUMP_SKIP:
  ;=======================================================================================
ENDFOR

IF (!D.NAME EQ 'X' OR !D.NAME EQ 'WIN') THEN BEGIN
  WSET,current_window
ENDIF

RETURN
END