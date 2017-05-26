;+
;*****************************************************************************************
;
;  FUNCTION :   general_cursor_select.pro
;  PURPOSE  :   This routine allows a user to select a single point that they wish to
;                 use to define a point in the plot for output.  For instance,
;                 one could use this to define a new velocity coordinate for the
;                 peak of a velocity distribution.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               general_prompt_routine.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               pos_str = general_cursor_select( [XSCALE=xscale] [,YSCALE=yscale]      $
;                                                [,WINDN=windn] [,XFACT=xfact]         $
;                                                [,YFACT=yfact] [,XSYS=xsys]           $
;                                                [,YSYS=ysys])
;
;  KEYWORDS:    
;               XSCALE   :  [2]-Element [numeric] array defining the scale factors for
;                             converting between X-NORMAL and X-DATA coordinates
;                             [Default = !X.S]
;               YSCALE   :  [2]-Element [numeric] array defining the scale factors for
;                             converting between Y-NORMAL and Y-DATA coordinates
;                             [Default = !Y.S]
;               WINDN    :  Scalar [numeric] defining the index of the window to use
;                             when selecting the region of interest
;                             [Default = !D.WINDOW]
;               XFACT    :  Scalar [numeric] defining a scale factor that was used
;                             when plotting the data that defined XSCALE
;                             [e.g. if (plot,x*1d3,y) was used  => set XFACT=1d3]
;                             [Default = 1.0]
;               YFACT    :  Scalar [numeric] defining a scale factor that was used
;                             when plotting the data that defined YSCALE
;                             [e.g. if (plot,x,y*1d3) was used  => set YFACT=1d3]
;                             [Default = 1.0]
;               XSYS     :  Scalar [structure] defining the !X system variable associated
;                             with the plot from which the user wishes to select data
;                             [Default = !X]
;               YSYS     :  Scalar [structure] defining the !Y system variable associated
;                             with the plot from which the user wishes to select data
;                             [Default = !Y]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/17/2017   v1.0.0]
;             2)  Continued to write routine
;                                                                   [05/19/2017   v1.0.0]
;             3)  Finished writing routine
;                                                                   [05/19/2017   v1.0.0]
;
;   NOTES:      
;               1)  Make sure a window is open and in use prior to calling
;               2)  See also:  ctime.pro, tlimit.pro
;               3)  The XSYS and YSYS keywords are useful when user wants to select
;                     data from one of several plots shown in a single device window
;               4)  There is an odd bug(?) that is introduced by running thm_init.pro
;                     whereby TVCRS.PRO and PLOTS.PRO did not behave correctly unless
;                     I added a preliminary call to CURSOR.PRO.  I could not trace it
;                     down to a specific setting but did notice the issue did not occur
;                     when I started IDL without running thm_init.pro or any SPEDAS
;                     initialization software.
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM:  beam_fit_cursor_select.pro [UMN 3DP library, beam fitting routines]
;   CREATED:  05/16/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/19/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION general_cursor_select,XSCALE=xscale,YSCALE=yscale,WINDN=windn,$
                               XFACT=xfact,YFACT=yfact,XSYS=xsys,YSYS=ysys

;;----------------------------------------------------------------------------------------
;;  Define defaults
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
form_str       = '(g25.5)'
form_out       = '("( ",a," , ",a," )")'
;;  Position of contour plot [square, normal coordinates]
;;                   Xo     Yo     X1    Y1
pos_0con       = [0.22941,0.515,0.77059,0.915]
;;  logic testing
read_out       = ''
;;  Define some device settings
def_win        = !D.WINDOW[0]            ;;  default/current device window #
dev_nme        = !D.NAME[0]              ;;  current device name (e.g., 'X')
;;  Define !X and !Y tags to be used
xysys_tags     = ['range','crange','s','window','region']
;;  Define delay time for WAIT.PRO
sleep          = 0.01
;;  Define allowed plot device names
good_dname     = ['x','win']
;;  Define dummy variables
dummy          = REPLICATE(d,2)
tags           = ['XY_NORM','XY_DATA']
dumb           = CREATE_STRUCT(tags,dummy,dummy)
;; Define separators for window reference
str_win        = "<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>"
;;  Dummy error messages
badplt_msg     = "The plot device must be set to 'X' or 'WIN'..."
nowind_msg     = 'There must be an active window display currently set and in use...'
badinp_msg     = 'User did something wrong...'
;;----------------------------------------------------------------------------------------
;;  First check device settings
;;----------------------------------------------------------------------------------------
test           = (TOTAL(STRLOWCASE(dev_nme[0]) EQ good_dname) LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,badplt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dumb
ENDIF
;;----------------------------------------------------------------------------------------
;;  Set graphics function, move cursor to screen, and plot original crosshairs
;;----------------------------------------------------------------------------------------
;;  Set "source XOR destination" graphics function
;;    the graphics function is set to (bitwise) "xor" rather than standard "copy"
;;    ((a xor b) xor b) = a,  lets call your plot "a" and the crosshairs "b"
;;    plot "a", set the graphics function to "xor", and plot "b" twice and you get "a"
;;    this way we don't damage your plot
DEVICE,GET_GRAPHICS_FUNCTION=oldgraphics,SET_GRAPHICS_FUNCTION=6,WINDOW_STATE=wstate
n_state        = N_ELEMENTS(wstate)        ;;  # of potential windows
n_win_open     = LONG(TOTAL(wstate))       ;;  # of currently open windows
good_w         = WHERE(wstate,gd_w)        ;;  Indices of open windows from window array
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check WINDN
test           = (is_a_number(windn,/NOMSSG) EQ 0) OR (N_ELEMENTS(windn) LT 1)
IF (test[0]) THEN win  = def_win ELSE win  = LONG(windn[0])
;;  Make sure a device window is open
test           = (win[0] LT 0) OR (def_win[0] LT 0) OR (TOTAL(good_w EQ win[0]) LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,nowind_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dumb
ENDIF
;;  Set and show window (in case user changed top-window prior to calling)
WSET,win[0]
WSHOW,win[0]
;;  Check for XSYS and YSYS
test           = (SIZE(xsys,/TYPE) NE 8)
IF (test[0]) THEN x_sys = !X ELSE x_sys = xsys
test           = (SIZE(ysys,/TYPE) NE 8)
IF (test[0]) THEN y_sys = !Y ELSE y_sys = ysys
;;  Check format of XSYS and YSYS
x_stags        = STRLOWCASE(TAG_NAMES(x_sys))
y_stags        = STRLOWCASE(TAG_NAMES(y_sys))
test           = 0b
FOR k=0L, N_ELEMENTS(xysys_tags) - 1L DO test += (TOTAL(x_stags EQ xysys_tags[k]) LT 1)
IF (test[0] GT 0) THEN x_sys = !X     ;;  Bad input --> Use default
test           = 0b
FOR k=0L, N_ELEMENTS(xysys_tags) - 1L DO test += (TOTAL(y_stags EQ xysys_tags[k]) LT 1)
IF (test[0] GT 0) THEN y_sys = !Y     ;;  Bad input --> Use default
;;  Define default device settings
def_xsc        = x_sys.S             ;;  default X-Coordinate conversion factor from NORMAL to DATA
def_nxp        = x_sys.WINDOW        ;;  default X-Coordinates [NORMAL] of plot
def_ysc        = y_sys.S             ;;  default Y-Coordinate " "
def_nyp        = y_sys.WINDOW        ;;  default Y-Coordinates [NORMAL] of plot
;;  Check XSCALE and YSCALE
test           = (is_a_number(xscale,/NOMSSG) EQ 0) OR (N_ELEMENTS(xscale) NE 2)
IF (test[0]) THEN xsc  = def_xsc ELSE xsc  = 1d0*xscale
test           = (is_a_number(yscale,/NOMSSG) EQ 0) OR (N_ELEMENTS(yscale) NE 2)
IF (test[0]) THEN ysc  = def_ysc ELSE ysc  = 1d0*yscale
;;  Check XFACT and YFACT
test           = (is_a_number(xfact,/NOMSSG) EQ 0) OR (N_ELEMENTS(xfact) LT 1)
IF (test[0]) THEN xfac = 1d0     ELSE xfac =  1d0*xfact[0]
test           = (is_a_number(yfact,/NOMSSG) EQ 0) OR (N_ELEMENTS(yfact) LT 1)
IF (test[0]) THEN yfac = 1d0     ELSE yfac =  1d0*yfact[0]
;;----------------------------------------------------------------------------------------
;;  Prompt user for point of interest
;;----------------------------------------------------------------------------------------
cross_col      = !D.N_COLORS[0] - 1L   ;;  Set the crosshair line color (necessary when backgrounds and color tables change)
WHILE (read_out NE 'y') DO BEGIN
  ;;  Set/Reset cursor outputs
  x_n_low        = 0e0              ;;  X-Normal position of cursor point
  y_n_low        = 0e0              ;;  Y-Normal position of cursor point
  x_d_low        = 0e0              ;;  X-Data   position of cursor point
  y_d_low        = 0e0              ;;  Y-Data   position of cursor point
  ;;  Define window information
  win_out        = "Working in Window #:  "+STRING(win[0],FORMAT='(I2.2)')
  PRINT, ""
  PRINT, str_win[0]
  PRINT, win_out[0]
  PRINT, str_win[0]
  PRINT, ""
  ;;  Define instructions for using the cursor
  pro_out        = ["     Please use the cursor to select a single point that identifies",$
                    "the point of interest.  Make sure you press the mouse button only"  ,$
                    "once and do not click on the window to try and move it prior to"    ,$
                    "selecting this set of coordinates."]
  ;;--------------------------------------------------------------------------------------
  ;; Inform user of procedure
  ;;--------------------------------------------------------------------------------------
  info_out       = general_prompt_routine(PRO_OUT=pro_out,FORM_OUT=7)
  ;;--------------------------------------------------------------------------------------
  ;;  Initialize cursor [put at middle of window]
  ;;--------------------------------------------------------------------------------------
  WSET,win[0]
  WSHOW,win[0]
  px             = (def_nxp[0] + def_nxp[1])/2d0
  py             = (def_nyp[0] + def_nyp[1])/2d0
  hx             = px
  hy             = py
  ;;  Start cursor routine and test if cursor is on device window
  CURSOR,testx,testy,/DEVICE,/NOWAIT               ;;  Initialize and find current cursor location
  ;;  When in SPEDAS, TVCRS.PRO must be called otherwise PLOTS.PRO leaves a remnant
  ;;    horizontal line from the first call to PLOTS.PRO without erasing it on update
  ;;    later in the WHILE loop below.
  TVCRS,px,py,/NORMAL
  ;;--------------------------------------------------------------------------------------
  ;;  Plot crosshairs
  ;;--------------------------------------------------------------------------------------
  PLOTS,[0,1],[py,py],/NORMAL,THICK=1,LINESTYLE=0,COLOR=cross_col[0]
  PLOTS,[px,px],[0,1],/NORMAL,THICK=1,LINESTYLE=0,COLOR=cross_col[0]
  opx            = px                        ;; store values for later comparison
  opy            = py
  ohx            = hx                        ;; store values for later crossHairs deletion
  ohy            = hy
  n              = 0
  nmax           = 1L
  oldbutton      = 0                         ;;  record last button pressed
  ;;--------------------------------------------------------------------------------------
  ;;  Start loop
  ;;--------------------------------------------------------------------------------------
  WHILE (n LT nmax) DO BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Choose point
    ;;------------------------------------------------------------------------------------
    WSET,win[0]
    WSHOW,win[0]
    CURSOR,x_n_low,y_n_low,/NORMAL,/CHANGE
    ;;  constrain cursor positions to plot window range
    x_n_low   = (x_n_low < def_nxp[1]) > def_nxp[0]
    y_n_low   = (y_n_low < def_nyp[1]) > def_nyp[0]
    button    = !MOUSE.BUTTON        ;;  get the new button state
    hx        = x_n_low              ;;  correct   assignments in the case of (EXACT EQ 0)
    hy        = y_n_low              ;;  temporary assignments in the case of (EXACT NE 0)
    ;;  unplot old crosshairs
    PLOTS,[0,1],[ohy,ohy],/NORMAL,THICK=1,LINESTYLE=0,COLOR=cross_col[0]
    PLOTS,[ohx,ohx],[0,1],/NORMAL,THICK=1,LINESTYLE=0,COLOR=cross_col[0]
    ;;  plot new crosshairs
    PLOTS,[0,1],[hy,hy],/NORMAL,THICK=1,LINESTYLE=0,COLOR=cross_col[0]
    PLOTS,[hx,hx],[0,1],/NORMAL,THICK=1,LINESTYLE=0,COLOR=cross_col[0]
    ;;------------------------------------------------------------------------------------
    ;; Check if button changed
    ;;------------------------------------------------------------------------------------
    IF (button NE oldbutton) THEN BEGIN
      CASE button OF
        1    : BEGIN
          ;;  Record values
          n += 1
        END
        ELSE : BEGIN
          dummy          = REPLICATE(0d0,2)  ;;  use origin as default
          dumb           = CREATE_STRUCT(tags,dummy,dummy)
          ;;  Reset graphics function
          DEVICE,SET_GRAPHICS_FUNCTION=oldgraphics
          ;;  Inform user of mistake
          MESSAGE,badinp_msg[0],/INFORMATIONAL,/CONTINUE
          ;;  Return to user
          RETURN,dumb
        END
      ENDCASE
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  store current information and pause
    ;;------------------------------------------------------------------------------------
    oldbutton = button
    opx       = x_n_low
    opy       = y_n_low
    ohx       = hx
    ohy       = hy
    WAIT, sleep                   ;;  Be nice
  ENDWHILE
  ;;--------------------------------------------------------------------------------------
  ;;  Erase Crosshairs
  ;;--------------------------------------------------------------------------------------
  PLOTS,[0,1],[y_n_low,y_n_low],/NORMAL,THICK=1,LINESTYLE=0,COLOR=cross_col[0]
  PLOTS,[x_n_low,x_n_low],[0,1],/NORMAL,THICK=1,LINESTYLE=0,COLOR=cross_col[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Convert to DATA from NORMAL coordinates on plot
  ;;--------------------------------------------------------------------------------------
  x_d_low        = (x_n_low[0] - xsc[0])/xsc[1]*xfac[0]
  y_d_low        = (y_n_low[0] - ysc[0])/ysc[1]*yfac[0]
  xd_low_str     = STRTRIM(STRING([x_d_low[0],y_d_low[0]],FORMAT=form_str),2L)
  xd_low_out     = STRING(xd_low_str,FORMAT=form_out)
  ;;--------------------------------------------------------------------------------------
  ;;  Prompt user to say whether they wish to try again
  ;;--------------------------------------------------------------------------------------
  ;; Reset inputs/outputs
  pro_out        = ['You selected the following point (x,y) in DATA coordinates:  '+xd_low_out,$
                    '',"     If you wish to try again, type 'n' at the following prompt,",$
                    "otherwise type 'y'.  [Type 'q' to quit at any time]"]
  str_out        = 'Are you satisfied with this coordinate? (y/n):  '
  read_out       = ''
  WHILE (read_out NE 'y' AND read_out NE 'n' AND read_out NE 'q') DO BEGIN
    read_out = general_prompt_routine(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
    IF (read_out EQ 'debug') THEN STOP
  ENDWHILE
  IF (read_out EQ 'q' OR read_out EQ 'y') THEN BEGIN
    ;;  Reset graphics function
    DEVICE,SET_GRAPHICS_FUNCTION=oldgraphics
  ENDIF
  ;;  Check if user wishes to quit
  IF (read_out EQ 'q') THEN RETURN,dumb
ENDWHILE
;;----------------------------------------------------------------------------------------
;;  Create return structure
;;----------------------------------------------------------------------------------------
tags           = ['XY_NORM','XY_DATA']
xy_norm        = [x_n_low[0],y_n_low[0]]
xy_data        = [x_d_low[0],y_d_low[0]]
struct         = CREATE_STRUCT(tags,xy_norm,xy_data)
;;  just in case, reset graphics function
DEVICE,SET_GRAPHICS_FUNCTION=oldgraphics
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END
