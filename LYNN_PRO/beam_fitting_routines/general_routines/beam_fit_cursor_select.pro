;+
;*****************************************************************************************
;
;  FUNCTION :   beam_fit_cursor_select.pro
;  PURPOSE  :   This routine allows a user to select a single point that they wish to
;                 use to define a point in velocity space.  This is useful for finding
;                 the peak of a beam or core distribution.
;
;  CALLED BY:   
;               beam_fit_prompts.pro
;
;  CALLS:
;               beam_fit_gen_prompt.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ;;  If !D.WINDOW matches the window you want to select from, then:
;               test = beam_fit_cursor_select(XSCALE=!X.S,YSCALE=!Y.S)
;
;  KEYWORDS:    
;               XSCALE   :  [2]-Element array defining the scale factors for converting
;                             between X-NORMAL and X-DATA coordinates
;                             [Default = !X.S]
;               YSCALE   :  [2]-Element array defining the scale factors for converting
;                             between Y-NORMAL and Y-DATA coordinates
;                             [Default = !Y.S]
;               WINDN    :  Scalar defining the index of the window to use when
;                             selecting the region of interest
;                             [Default = !D.WINDOW]
;               XFACT    :  Scalar defining a scale factor that was used when plotting
;                             the data that defined XSCALE
;                             [e.g. if (plot,x*1d3,y) was used  => set XFACT=1d3]
;                             [Default = 1.0]
;               YFACT    :  Scalar defining a scale factor that was used when plotting
;                             the data that defined YSCALE
;                             [e.g. if (plot,x,y*1d3) was used  => set YFACT=1d3]
;                             [Default = 1.0]
;
;   CHANGED:  1)  Now routine outputs crosshairs as mouse moves and limits user to
;                   specific region on plot.  If the user clicks on the wrong plot,
;                   the routine will simply wait until the user clicks on the correct
;                   plot.
;                                                                  [10/09/2012   v1.1.0]
;
;   NOTES:      
;               1)  Make sure a window is open and in use prior to calling
;               2)  Make sure the window that is set is kept in front of anything else
;                     on the screen
;               3)  Do NOT click on window to move it prior to selecting a point
;
;   CREATED:  09/07/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/09/2012   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION beam_fit_cursor_select,XSCALE=xscale,YSCALE=yscale,WINDN=windn,$
                                XFACT=xfact,YFACT=yfact

;;----------------------------------------------------------------------------------------
;; => Define defaults
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
form_str       = '(g25.5)'
form_out       = '("( ",a," , ",a," )")'
tags           = ['XY_NORM','XY_DATA']

;; => Position of contour plot [square, normal coordinates]
;;                   Xo     Yo     X1    Y1
pos_0con       = [0.22941,0.515,0.77059,0.915]
;; => logic testing
read_out       = ''

def_win        = !D.WINDOW    ;; default window #
def_xsc        = !X.S         ;; default X-Coordinate scale
def_ysc        = !Y.S         ;; default Y-Coordinate scale
sleep          = 0.01
;;----------------------------------------------------------------------------------------
;; => Set graphics function, move cursor to screen, and plot original crosshairs
;;----------------------------------------------------------------------------------------
DEVICE,GET_GRAPHICS_FUNCTION=oldgraphics,SET_GRAPHICS_FUNCTION=6   ;Set xor graphics function

dummy          = REPLICATE(d,2)
dumb           = CREATE_STRUCT(tags,dummy,dummy)
; => Dummy error messages
nowind_msg     = 'There must be an active window display currently set and in use...'
;;----------------------------------------------------------------------------------------
;; => Check keywords
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(xscale) NE 2) THEN xsc  = def_xsc ELSE xsc  = xscale
IF (N_ELEMENTS(yscale) NE 2) THEN ysc  = def_ysc ELSE ysc  = yscale
IF (N_ELEMENTS(windn)  NE 1) THEN win  = def_win ELSE win  = windn[0]
IF (N_ELEMENTS(xfact)  NE 1) THEN xfac = 1e0     ELSE xfac = xfact[0]
IF (N_ELEMENTS(yfact)  NE 1) THEN yfac = 1e0     ELSE yfac = yfact[0]

test           = (win LT 0) OR (def_win LT 0) OR (STRLOWCASE(!D.NAME) NE 'x')
IF (test) THEN BEGIN
  MESSAGE,nowind_msg,/INFORMATIONAL,/CONTINUE
  RETURN,dumb
ENDIF
;;----------------------------------------------------------------------------------------
;; => Prompt user for point of interest
;;----------------------------------------------------------------------------------------
WHILE (read_out NE 'y') DO BEGIN
  ;; Set/Reset cursor outputs
  x_n_low        = 0e0              ;; X-Normal position of cursor point
  y_n_low        = 0e0              ;; Y-Normal position of cursor point
  x_d_low        = 0e0              ;; X-Data   position of cursor point
  y_d_low        = 0e0              ;; Y-Data   position of cursor point
  pro_out        = ['     Please use the cursor to select a single point that identifies',$
                    'the point of interest.  Make sure you press the mouse button only',$
                    'once and do not click on the window to try and move it prior to',$
                    'selecting this set of coordinates.']
  ;;--------------------------------------------------------------------------------------
  ;; Inform user of procedure
  ;;--------------------------------------------------------------------------------------
  info_out       = beam_fit_gen_prompt(PRO_OUT=pro_out,WINDN=win,FORM_OUT=7)
  ;;--------------------------------------------------------------------------------------
  ;; => Initialize cursor [put at middle of window]
  ;;--------------------------------------------------------------------------------------
  WSET,win[0]
  WSHOW,win[0]
  px             = (pos_0con[0] + pos_0con[2])/2d0
  py             = (pos_0con[1] + pos_0con[3])/2d0
  hx             = px
  hy             = py
  TVCRS,px,py,/NORM
  ;;--------------------------------------------------------------------------------------
  ;; => Plot crosshairs
  ;;--------------------------------------------------------------------------------------
  PLOTS,[0,1],[py,py],/NORM,/THICK,LINESTYLE=0
  PLOTS,[px,px],[0,1],/NORM,/THICK,LINESTYLE=0
  opx            = px                        ;; store values for later comparison
  opy            = py
  ohx            = hx                        ;; store values for later crossHairs deletion
  ohy            = hy
  n              = 0
  nmax           = 1L
  oldbutton      = 0                         ;; => record last button pressed
  ;;--------------------------------------------------------------------------------------
  ;; => Start loop
  ;;--------------------------------------------------------------------------------------
  WHILE (n LT nmax) DO BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Choose point
    ;;------------------------------------------------------------------------------------
    WSET,win[0]
    WSHOW,win[0]
    CURSOR,x_n_low,y_n_low,/NORMAL,/CHANGE
    ;;  constrain cursor positions to plot window range
    x_n_low   = (x_n_low < pos_0con[2]) > pos_0con[0]
    y_n_low   = (y_n_low < pos_0con[3]) > pos_0con[1]
;    CURSOR,x_n_low,y_n_low,/NORMAL,/WAIT,/CHANGE
    button    = !MOUSE.BUTTON        ;; => get the new button state
    hx        = x_n_low              ;; => correct   assignments in the case of (EXACT EQ 0)
    hy        = y_n_low              ;; => temporary assignments in the case of (EXACT NE 0)
    ;;  unplot old crosshairs
    PLOTS,[0,1],[ohy,ohy],/NORM,/THICK,LINESTYLE=0
    PLOTS,[ohx,ohx],[0,1],/NORM,/THICK,LINESTYLE=0
    ;;  plot new crosshairs
    PLOTS,[0,1],[hy,hy],/NORM,/THICK,LINESTYLE=0
    PLOTS,[hx,hx],[0,1],/NORM,/THICK,LINESTYLE=0
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
          dummy          = REPLICATE(0d0,2)  ;; use origin as default
          dumb           = CREATE_STRUCT(tags,dummy,dummy)
          ;; => Reset graphics function
          DEVICE,SET_GRAPHICS_FUNCTION=oldgraphics
          badmssg        = 'You did something wrong...'
          MESSAGE,badmssg,/INFORMATIONAL,/CONTINUE
          RETURN,dumb
        END
      ENDCASE
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;; store current information and pause
    ;;------------------------------------------------------------------------------------
    oldbutton = button
    opx       = x_n_low
    opy       = y_n_low
    ohx       = hx
    ohy       = hy
    WAIT, sleep                   ;; Be nice
  ENDWHILE
  ;;--------------------------------------------------------------------------------------
  ;; => Erase Crosshairs
  ;;--------------------------------------------------------------------------------------
  PLOTS,[0,1],[y_n_low,y_n_low],/NORM,/THICK,LINESTYLE=0
  PLOTS,[x_n_low,x_n_low],[0,1],/NORM,/THICK,LINESTYLE=0
  ;;--------------------------------------------------------------------------------------
  ;; => Convert to data coordinates on contour plot
  ;;--------------------------------------------------------------------------------------
  x_d_low        = (x_n_low[0] - xsc[0])/xsc[1]*xfac[0]
  y_d_low        = (y_n_low[0] - ysc[0])/ysc[1]*yfac[0]
  xd_low_str     = STRTRIM(STRING([x_d_low[0],y_d_low[0]],FORMAT=form_str),2L)
  xd_low_out     = STRING(xd_low_str,FORMAT=form_out)
  ;;--------------------------------------------------------------------------------------
  ;; => Prompt user to say whether they wish to try again
  ;;--------------------------------------------------------------------------------------
  ;; Reset inputs/outputs
  pro_out        = ['You selected the following point (x,y) in DATA coordinates:  '+xd_low_out,$
                    '',"     If you wish to try again, type 'n' at the following prompt,",$
                    "otherwise type 'y'.  [Type 'q' to quit at any time]"]
  str_out        = 'Are you satisfied with this coordinate? (y/n):  '
  read_out       = ''
  WHILE (read_out NE 'y' AND read_out NE 'n' AND read_out NE 'q') DO BEGIN
    read_out = beam_fit_gen_prompt(STR_OUT=str_out,PRO_OUT=pro_out,FORM_OUT=7)
    IF (read_out EQ 'debug') THEN STOP
  ENDWHILE
  IF (read_out EQ 'q' OR read_out EQ 'y') THEN BEGIN
    ;; => Reset graphics function
    DEVICE,SET_GRAPHICS_FUNCTION=oldgraphics
  ENDIF
  ;; => Check if user wishes to quit
  IF (read_out EQ 'q') THEN RETURN,dumb
ENDWHILE
;;----------------------------------------------------------------------------------------
;; => Create return structure
;;----------------------------------------------------------------------------------------
tags           = ['XY_NORM','XY_DATA']
xy_norm        = [x_n_low[0],y_n_low[0]]
xy_data        = [x_d_low[0],y_d_low[0]]
struct         = CREATE_STRUCT(tags,xy_norm,xy_data)
;; just in case, reset graphics function
DEVICE,SET_GRAPHICS_FUNCTION=oldgraphics
;;----------------------------------------------------------------------------------------
;; => Return coordinates to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END