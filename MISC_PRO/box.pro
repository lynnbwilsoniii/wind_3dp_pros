;+
;*****************************************************************************************
;
;  FUNCTION :   box.pro
;  PURPOSE  :   Generalized routine to produce plot outlines for TPLOT routines.
;
;  CALLED BY:   
;               mplot.pro
;               specplot.pro
;
;  CALLS:
;               str_element.pro
;               minmax.pro
;               extract_tags.pro
;               plot_positions.pro
;               xlim.pro
;               ylim.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               LIMITS  :  Plot structure compatible with PLOT.PRO keywords
;               X       :  N-Element array of X-Axis data (semi-optional)
;               Y       :  N-Element array of Y-Axis data (semi-optional)
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               DATA    :  Obselete keyword
;               MPOSI   :  Set to a named variable to return the plot position
;
;   CHANGED:  1)  I modified something...                          [03/18/2008   v1.0.?]
;             2)  Re-wrote and cleaned up                          [08/11/2009   v1.1.0]
;             3)  Updated to be in accordance with newest version of box.pro
;                   in TDAS IDL libraries
;                   A)  Added keyword:  MPOSI
;                   B)  no longer uses () for arrays
;                                                                  [03/24/2012   v1.2.0]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  ???
;    LAST MODIFIED:  03/24/2012   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO box,limits,x,y,DATA=d,MPOSI=mposi

;-----------------------------------------------------------------------------------------
; => Check to see if overplot is set
;-----------------------------------------------------------------------------------------
str_element,limits,'OVERPLOT',VALUE=overplot
IF KEYWORD_SET(overplot) THEN RETURN

xlog    = 0
ylog    = 0
xr      = !X.RANGE
yr      = !Y.RANGE
;-----------------------------------------------------
; => LBW III 03/24/2012   v1.2.0
;-----------------------------------------------------
xmargin = !X.MARGIN; - [7.0,0.0]
ymargin = !Y.MARGIN; - [2.0,0.0]
;-----------------------------------------------------------------------------------------
; => Get relevant plot information
;-----------------------------------------------------------------------------------------
str_element,limits,'XLOG',     VALUE = xlog    ; -Define xlog as value from structure opt
str_element,limits,'YLOG',     VALUE = ylog
str_element,limits,'XRANGE',   VALUE = xr
str_element,limits,'YRANGE',   VALUE = yr
str_element,limits,'XMARGIN',          xmargin
str_element,limits,'YMARGIN',          ymargin
str_element,limits,'ASP_RATIO',VALUE = asp_ratio
str_element,limits,'ASPECT',   VALUE = aspect
str_element,limits,'TOP',      VALUE = top     ; -Define top " "
str_element,limits,'METRIC',   VALUE = metric
str_element,limits,'NOERASE',  VALUE = noerase
;-----------------------------------------------------------------------------------------
; => Determine XY-Ranges
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(x) NE 0) AND (xr[0] EQ xr[1]) THEN BEGIN
  xr = minmax(x,POSITIVE=xlog)
ENDIF

IF (N_ELEMENTS(y) NE 0) AND (yr[0] EQ yr[1]) THEN BEGIN 
  yr = minmax(y,POSITIVE=ylog)
ENDIF
;-----------------------------------------------------------------------------------------
; => Determine plot region and position
;-----------------------------------------------------------------------------------------
extract_tags,plotstuff,limits,/PLOT

region = !P.REGION
str_element,limits,'REGION',region

pos    = !P.POSITION
str_element,limits,'POSITION',pos

IF (region[0] EQ region[2]) THEN region = [0.,0.,1.,1.]
;-----------------------------------------------------------------------------------------
; => Fix position if necessary
;-----------------------------------------------------------------------------------------
IF  (pos[0] EQ pos[2]) THEN BEGIN
  ;---------------------------------------------------------------------------------------
  ;---------------------------------------------------------------------------------------
  IF (!P.MULTI[1] NE 0) THEN BEGIN  ;  check # of columns
    xsize = REPLICATE(1,!P.MULTI[1])
    xgap  = TOTAL(xmargin,/NAN)
  ENDIF
  IF (!P.MULTI[2] NE 0) THEN BEGIN  ;  check # of rows
    ysize = REPLICATE(1,!P.MULTI[2])
    ygap  = TOTAL(ymargin,/NAN)
  ENDIF
  p  = !P.MULTI[0]                  ;  # of plots remain on page
  np = !P.MULTI[1]*!P.MULTI[2] > 1
  IF (!P.MULTI[0] NE 0) THEN str_element,plotstuff,'NOERASE',1,/ADD_REPLACE
  ;---------------------------------------------------------------------------------------
  ; => Determine plot position
  ;---------------------------------------------------------------------------------------
  pos = plot_positions(OPTION=plotstuff,REGION=region,XSIZE=xsize,YSIZE=ysize, $
                       XGAP=xgap,YGAP=ygap)
  ;---------------------------
  ;  TDAS update 2007-10-22
  ;---------------------------
  IF (!P.MULTI[4] NE 0) THEN BEGIN
    ; => Plotting top-to-bottom, left-to-right
    pos = REFORM(pos,4,!P.MULTI[1],!P.MULTI[2])
    pos = TRANSPOSE(pos,[0,2,1])
    pos = REFORM(pos,4,!P.MULTI[2]*!P.MULTI[1])
  ENDIF
  ; => Add position to plotstuff structure
  gel = (np - p) MOD np
  str_element,plotstuff,'POSITION',pos[*,gel],/ADD_REPLACE
  IF (!P.MULTI[0] NE 0) THEN !P.MULTI[0] -= 1
ENDIF
;-----------------------------------------------------------------------------------------
; => Determine Aspect Ratio
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(aspect) THEN BEGIN
  dx = ABS(xr[1] - xr[0])
  dy = ABS(yr[1] - yr[0])
  IF (dx NE 0 AND dy NE 0) THEN  asp_ratio = dy/dx ELSE asp_ratio = 1.
  p_size = [!D.X_SIZE,!D.Y_SIZE]
  tpos   = pos * [p_size,p_size]
  dtpos  = [tpos[2] - tpos[0], tpos[3] - tpos[1]]
  dtpos2 = [1.,asp_ratio] * (dtpos[0] < dtpos[1]/asp_ratio)
  dts    = dtpos - dtpos2
  IF KEYWORD_SET(top) THEN r = 1. ELSE r = 5e-1
  ds     = [r*dts,(r - 1)*dts]
  tpos2  = tpos + ds
  pos    = tpos2/[p_size,p_size]
;-----------------------------------------------------
; => LBW III 03/24/2012   v1.2.0
;-----------------------------------------------------
;  pos    = tpos2/[p_size,p_size] - 5e-1*[0.9,0.05,0.01,0.1]  ; => Shifts plot position
  str_element,plotstuff,'POSITION',pos,/ADD_REPLACE
ENDIF
;-----------------------------------------------------------------------------------------
;if keyword_set(aspect) or keyword_set(asp_ratio) then begin
;   charsize = !p.charsize
;   str_element,plotstuff,'charsize',value=charsize
;   if charsize le 0 then charsize=1.
;   str_element,lim,'xmargin',value=xmargin
;   str_element,lim,'ymargin',value=ymargin
;   if not keyword_set(xmargin) then xmargin = !x.margin
;   if not keyword_set(ymargin) then ymargin = !y.margin
;   if not keyword_set(asp_ratio) then begin
;      dx = abs(xr(1)-xr(0))
;      dy = abs(yr(1)-yr(0))
;      if dx ne 0 and dy ne 0 then  asp_ratio = dy/dx else asp_ratio = 1.
;   endif
;   xm = !x.margin * !d.x_ch_size * charsize
;   ym = !y.margin * !d.y_ch_size * charsize
;   p_size = [!d.x_size,!d.y_size]
;   m0 = [xm(0),ym(0)]
;   m1 = [xm(1),ym(1)]
;   bs = p_size-(m0+m1)
;   s = [1.,asp_ratio] * (bs(0) < bs(1)/asp_ratio)
;   bsp = m0 + (bs-s)/2
;   if keyword_set(top) then bsp(1) = m0(1) - s(1) + bs(1)
;   pos = [bsp,bsp+s] / [p_size,p_size]
;   str_element,/add,plotstuff,'position',pos
;   str_element,/add,plotstuff,'normal',1
;endif
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(metric) THEN BEGIN
  MESSAGE,'Obsolete keyword:  METRIC',/INFORMATION,/CONTINUE
  pos  = plotstuff.POSITION
  arat = (pos[3] - pos[1])/(pos[2] - pos[0])*!D.Y_SIZE/!D.X_SIZE
  dxr  = ABS(xr[1] - xr[0])* 1.1
  mxr  = (xr[1] + xr[0])/2
  dyr  = ABS(yr[1] - yr[0]) * 1.1
  myr  = (yr[1] + yr[0])/2
  IF (arat GT dyr/dxr) THEN dyr = dxr*arat ELSE dxr = dyr/arat
  xr   = mxr + dxr * [-.5,.5]
  yr   = myr + dyr * [-.5,.5]
;-----------------------------------------------------
; => LBW III 03/24/2012   v1.2.0
;-----------------------------------------------------
;  xr   = mxr - dxr * [-.5,.5]
;  yr   = myr - dyr * [-.5,.5]
  xlim,plotstuff,xr[0],xr[1]
  ylim,plotstuff,yr[0],yr[1]
ENDIF
;-----------------------------------------------------------------------------------------
; => Plot outline
;-----------------------------------------------------------------------------------------
PLOT,xr,yr,/NODATA,_EXTRA=plotstuff
mposi = plotstuff.POSITION

RETURN
END
