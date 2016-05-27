;+
;*****************************************************************************************
;
;  FUNCTION :   tplot_positions.pro
;  PURPOSE  :   
;                    Return a set of plot positions for TPLOT.
;                    Given the number of plots, the margins, and the relative 
;                    sizes of the plot panels, determine the plot coordinates.
;                    The positions are the device coordinates of the plot, not
;                    of the plot region. (See IDL User's Guide Chapter 14.10)
;
;                    If the margins are not specifically set, first the limit
;                    structures are checked, then ![X,Y].MARGIN are checked,
;                    then some defaults are used.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               str_element.pro
;               get_data.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               PANELS   :  Scalar defining the number of plot windows [N]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               [X,Y]M   :  2-Element arrays defining the [X,Y] inner margin
;                             [Default:  ![X,Y].MARGIN]
;               [X,Y]OM  :  2-Element arrays defining the [X,Y] outer margin
;                             [Default:  ![X,Y].OMARGIN]
;               SIZES    :  N-Element array containing the relative plot sizes
;
;   CHANGED:  1)  ?? Davin changed something                       [05/30/1997   v1.0.2]
;             2)  Re-wrote and cleaned up                          [12/07/2010   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  12/07/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION tplot_positions,panels,XM=xm,XOM=xom,YM=ym,YOM=yom,SIZES=sizes

;-----------------------------------------------------------------------------------------
; => Load common blocks
;-----------------------------------------------------------------------------------------
@tplot_com

str_element,tplot_vars,'NAMES',tplot_var
;-----------------------------------------------------------------------------------------
; => see if tplot_var is useful
;-----------------------------------------------------------------------------------------
n_t_var = N_ELEMENTS(tplot_var)
;-----------------------------------------------------------------------------------------
; => check input values and set defaults
;-----------------------------------------------------------------------------------------
IF (SIZE(panels,/TYPE) EQ 0) THEN panels = N_ELEMENTS(tplot_var) > 1 $
  ELSE panels = FIX(panels)
IF NOT KEYWORD_SET(xm)       THEN xm     = !X.MARGIN
IF NOT KEYWORD_SET(xom)      THEN xom    = !X.OMARGIN
IF NOT KEYWORD_SET(ym)       THEN ym     = !Y.MARGIN
IF NOT KEYWORD_SET(yom)      THEN yom    = !Y.OMARGIN
IF NOT KEYWORD_SET(sizes)    THEN sizes  = MAKE_ARRAY(panels,/FLOAT,VALUE=1.0) $
  ELSE sizes  = REVERSE(sizes)
;-----------------------------------------------------------------------------------------
; => get character scale factors to margins
;-----------------------------------------------------------------------------------------
IF (!P.CHARSIZE EQ 0) THEN pc = 1.0 ELSE pc = !P.CHARSIZE
IF (!X.CHARSIZE EQ 0) THEN xc = 1.0 ELSE xc = !X.CHARSIZE
IF (!Y.CHARSIZE EQ 0) THEN yc = 1.0 ELSE yc = !Y.CHARSIZE
;-----------------------------------------------------------------------------------------
; => create arrays to hold margins and scale factors for each panel
;-----------------------------------------------------------------------------------------
t_pc = MAKE_ARRAY(panels,  /FLOAT,VALUE=0) ;charsize
; t_ps = make_array(4,panels,/float,VALUE=0) ;position ;for now, i ignore this
t_xc = MAKE_ARRAY(panels,  /FLOAT,VALUE=0) ;xcharsize
t_xm = MAKE_ARRAY(2,panels,/FLOAT,VALUE=0) ;xmargin
t_yc = MAKE_ARRAY(panels,  /FLOAT,VALUE=0) ;ycharsize
t_ym = MAKE_ARRAY(2,panels,/FLOAT,VALUE=0) ;ymargin
;-----------------------------------------------------------------------------------------
; => check the limit structures for tags that affect plot positioning
;      if the tags do not exist, use the input values, or default values
;-----------------------------------------------------------------------------------------
IF (n_t_var GT 0) THEN vars = REVERSE(tplot_var) ;get handle names, bottom up

FOR i=0L, panels - 1L DO BEGIN
  t_pc[i]   = pc                           ;set defaults
;   t_ps(*,i) = [0,0,0,0]
  t_xc[i]   = xc
  t_xm[*,i] = xm
  t_yc[i]   = yc
  t_ym[*,i] = ym
  IF (n_t_var GT 0) THEN BEGIN 
    get_data,vars[i],LIM=t_lm              ;get limit structure
    IF (SIZE(t_lm,/TYPE) EQ 8) THEN BEGIN
      str_element,t_lm,'CHARSIZE', VALUE=val,INDEX=ind
      IF ((ind GE 0) AND (SIZE(val,/TYPE) GT 0)) THEN t_pc[*,i] = val
;       str_element,t_lm,'position', VALUE=val,INDEX=ind ;again, ignoring this
;       IF (ind GE 0) and (SIZE(val,/TYPE) GT 0) THEN t_ps(*,i) = val
      str_element,t_lm,'XCHARSIZE',VALUE=val,INDEX=ind
      IF ((ind GE 0) AND (SIZE(val,/TYPE) GT 0)) THEN t_xc[*,i] = val
      str_element,t_lm,'XMARGIN',  VALUE=val,INDEX=ind
      IF ((ind GE 0) AND (SIZE(val,/TYPE) GT 0)) THEN t_xm[*,i] = val
      str_element,t_lm,'YCHARSIZE',VALUE=val,INDEX=ind
      IF ((ind GE 0) AND (SIZE(val,/TYPE) GT 0)) THEN t_yc[*,i] = val
      str_element,t_lm,'YMARGIN',  VALUE=val,INDEX=ind
      IF ((ind GE 0) AND (SIZE(val,/TYPE) GT 0)) THEN t_ym[*,i] = val
    ENDIF
  ENDIF 
ENDFOR 
;-----------------------------------------------------------------------------------------
; => change the margins variables from character units to device units
;-----------------------------------------------------------------------------------------
FOR i=0,panels-1 DO BEGIN
  t_xm[*,i] = t_xm[*,i] * t_xc[i] * t_pc[i] * !D.X_CH_SIZE
  t_ym[*,i] = t_ym[*,i] * t_yc[i] * t_pc[i] * !D.Y_CH_SIZE
ENDFOR 
xom = xom * xc * pc * !D.X_CH_SIZE
yom = yom * yc * pc * !D.Y_CH_SIZE
;-----------------------------------------------------------------------------------------
; => set plot area to total window
;-----------------------------------------------------------------------------------------
xtotpltlen = !D.X_SIZE
ytotpltlen = !D.Y_SIZE
;-----------------------------------------------------------------------------------------
; => remove outter margins
;-----------------------------------------------------------------------------------------
xtotpltlen = xtotpltlen - TOTAL(xom)
ytotpltlen = ytotpltlen - TOTAL(yom)
;-----------------------------------------------------------------------------------------
; => remove inner margins
;-----------------------------------------------------------------------------------------
; xtotpltlen = xtotpltlen - total(t_xm)
ytotpltlen = ytotpltlen - TOTAL(t_ym)
;-----------------------------------------------------------------------------------------
; => divide up the plot space
;-----------------------------------------------------------------------------------------
xpltlen = MAKE_ARRAY(panels,/FLOAT,VALUE=xtotpltlen) - t_xm[0,*] - t_xm[1,*]
ypltlen = ytotpltlen*sizes/TOTAL(sizes)
;-----------------------------------------------------------------------------------------
; => create y position arrays
;-----------------------------------------------------------------------------------------
y0 = FLTARR(panels)
y1 = y0
;-----------------------------------------------------------------------------------------
; => determine the x plot positions for all of the plots
;-----------------------------------------------------------------------------------------
x0 = xom[0] + t_xm[0,*]
x1 = x0     + xpltlen
;-----------------------------------------------------------------------------------------
; => determine the y plot positions for the base plot
;-----------------------------------------------------------------------------------------
y0[0] = yom[0] + t_ym[0,0]
y1[0] = y0[0]  + ypltlen[0]
;-----------------------------------------------------------------------------------------
; => Determine the y plot positions of the rest of the plots
;-----------------------------------------------------------------------------------------
FOR i=1,panels-1 DO BEGIN 
  y0[i] = y1[i - 1L] + t_ym[1,i - 1L]   ; => start at top margin of previous plot
  y0[i] = y0[i]   + t_ym[0,i]           ; => add margin for current (ith) plot
  y1[i] = y0[i]   + ypltlen[i]          ; => add ith plot height to ith plot base    
ENDFOR
;-----------------------------------------------------------------------------------------
; => create a 2d array of positions
;-----------------------------------------------------------------------------------------
positions      = MAKE_ARRAY(4,panels,VALUE=0,/FLOAT)
positions[0,*] = x0
positions[1,*] = y0
positions[2,*] = x1
positions[3,*] = y1
;-----------------------------------------------------------------------------------------
; => return the positions, reversing the order to top-to-bottom 
;-----------------------------------------------------------------------------------------
RETURN,TRANSPOSE(REVERSE(TRANSPOSE(positions)))
END





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;!D
;n_colors
;name
;origin:        pan/scroll offset
;table_size:    number of color table indicies
;unit:          file unit open for writing from graphics device
;window:        current window, or -1
;[x,y]_
;      ch_size: normal width and height of a character in device units
;      px_cm:   approx # of pixels/cm
;      size:    total display size in device units
;      vsize:   size of visible area of display in device units
;zoom:          [xzoom,yzoom]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;!P
;background	bg color index
;channel:	default source or destination channel
;charsize:	default=1
;charthick:	default=1
;clip:          clipping window, two opposite corners of a cube
;font:
;linestyle:	0:______ 1:...... 2:_ _ _ 3: _._._. 4:_..._... 5:__  __  __ 
;multi:         [# plts remaining, cols, rows, stacks, col/row major]
;noclip:
;noerase:
;nsum:
;position:	norm coords of plot window (x0,y0,x1,y1)
;psym:		1:+ 2:* 3:. 4:diamond 5:triangle 6:square 7:X 
;		8:user-defined (see usersym) 9:undefined 10:histogram mode
;region:	norm coords rectangle enclosing plot region
;subtitle;	subtitle
;t:		homogeneous 4x4 transformation matrix
;t3d:	
;thick:		default=1
;title:		title
;ticklen:	fraction of plot size, default=0.02
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;![X,Y,Z]
;charsize:	scale to global scale !p.charsize
;crange:	output axis range (setting has no effect)
;gridstyle:	same indicies as !p.linestyle
;margin:	[left (bottom), right (top)] margins in character size units
;minor:		number of minor ticks
;omargin:	determines area around entire plot area
;range:		axis range
;region:	norm coords of plot region (read, don't set) (use !p.region)
;s:		s(1)*data+s(0)=norm, scale factor for data to norm
;               if log scaled then s(1)*log10(data)+s(0)=norm
;style:		bitwise flag: bits: 0:rounded/exact 1:/extend5% 
;		2:/axis&annotation not drawn 3:box/nobox 4:yzero/ynozero
;thick		default=1
;tickformat:	[axis,index,value]
;ticklen:	norm coord tick lengths
;tickname:	max 20 element string array
;ticks:		# major tick intervals
;tickv:		tick values
;title:		axis title
;type:		0: linear 1: log
;window:	contains norm coords of the axis end points, the plot window
;               setting has no effect. use !p.position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
