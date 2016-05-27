;+
;*****************************************************************************************
;
;  FUNCTION :   my_box.pro
;  PURPOSE  :   Attempts to generate the axes one desires for plotting in IDL.
;
;  CALLED BY: 
;               mplot.pro
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
;               NA
;
;  INPUT:
;               X         :  X-axis data array
;               Y         :  Y-axis data array
;               LIMITS    :  A structure containing plot information with
;                             tags defined by the allowable tags found in
;                             the IDL plot.pro etc. routines.
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:  
;               MPOSI     :  Set to a named variable to receive back the
;                             position coords. of the plot region.
;               COL_SCALE :  If set, the position of the entire graph is 
;                             adjusted to accommodate a color scale on the
;                             right side
;               RE_DRAW   :  Used to keep track of which plot we're using in 
;                              the plot region
;
;   CHANGED:  1)  Fixed some syntax issues                  [08/29/2008   v1.0.4]
;             2)  Updated man page                          [06/03/2009   v1.0.5]
;             3)  Changed program my_plot_scale.pro to plot_vector_hodo_scale.pro
;                   and my_plot_positions.pro to plot_positions.pro
;                                                           [09/10/2009   v2.0.0]
;             4)  Changed program plot_vector_hodo_scale.pro to minmax.pro
;                                                           [09/16/2009   v2.1.0]
;
;   ADAPTED FROM: box.pro  BY:  ?
;   CREATED:  08/28/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/16/2009   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO my_box,limits,x,y,MPOSI=mposi,COL_SCALE=col_scale,RE_DRAW=re_draw

;*****************************************************************************
; -
;*****************************************************************************
str_element,limits,'OVERPLOT',VALUE = overplot
IF KEYWORD_SET(overplot) THEN RETURN
xlog    = 0
ylog    = 0
xr      = !x.range
yr      = !y.range
xmargin = !x.margin - [7.0,0.0]
ymargin = !y.margin - [2.0,0.0]


str_element,limits,'XLOG',     VALUE = xlog    ; -Define xlog as value from structure opt
str_element,limits,'YLOG',     VALUE = ylog
str_element,limits,'XRANGE',   VALUE = xr
str_element,limits,'YRANGE',   VALUE = yr
str_element,limits,'XMARGIN',xmargin
str_element,limits,'YMARGIN',ymargin
str_element,limits,'ASP_RATIO',VALUE = asp_ratio
str_element,limits,'ASPECT',   VALUE = aspect
str_element,limits,'TOP',      VALUE = top     ; -Define top " "
str_element,limits,'METRIC',   VALUE = metric
str_element,limits,'NOERASE',  VALUE = noerase
IF (N_ELEMENTS(x) ne 0) AND (xr[0] EQ xr[1]) THEN BEGIN
  xr = minmax(x)
;  xra = plot_vector_hodo_scale(x)
;  lt0 = WHERE(x LT 0.0,l0)
;  IF (l0 GT 0L) THEN BEGIN
;    xr = [-1.*xra.PLOT_RANGE,xra.PLOT_RANGE]
;  ENDIF ELSE BEGIN
;    xr = [0.,xra.PLOT_RANGE]
;  ENDELSE
ENDIF
IF (N_ELEMENTS(y) ne 0) AND (yr[0] EQ yr[1]) THEN BEGIN 
  yr = minmax(y)
ENDIF
;IF KEYWORD_SET(xlog) THEN xr[0] = xr[1]*1d-3   ; -forces x_min = x_max/1000
;IF KEYWORD_SET(ylog) THEN yr[0] = yr[1]*1d-3   ; -forces y_min = y_max/1000

extract_tags,plotstuff,limits,/PLOT
region = !P.REGION    ; -Bounding box of plotting area [x_o,y_o,x_1,y_1] normalized coords.
pos    = !P.POSITION  ; -[x_o,y_o,x_1,y_1] normalized coords., (x_o,y_o) = lower left corner

str_element,limits,'REGION',region
str_element,limits,'POSITION',pos
IF (region[0] EQ region[2]) THEN region = [0.,0.,1.,1.]
;*****************************************************************************
; -Adjust the postion of the plot
;*****************************************************************************
IF (pos[0] EQ pos[2]) THEN BEGIN
  IF (!P.MULTI[1] NE 0) THEN BEGIN
    xsize = REPLICATE(1,!p.multi[1])
    xgap  = TOTAL(xmargin,/NAN)
  ENDIF
  IF (!P.MULTI[2] NE 0) THEN BEGIN
    ysize = REPLICATE(1,!p.multi[2])
    ygap  = TOTAL(ymargin,/NAN)
  ENDIF
  p  = !P.MULTI[0]
  np = !P.MULTI[1]*!P.MULTI[2] > 1

  IF (!P.MULTI[0] NE 0) THEN str_element,/ADD_REPLACE,plotstuff,'NOERASE',1
  ; -get position in normalized coordinates [x_o,y_o,x_1,y_1]
  pos = plot_positions(OPTION=plotstuff,REGION=region,XSIZES=xsize, $
                       YSIZES=ysize,XGAP=xgap,YGAP=ygap)
  IF KEYWORD_SET(col_scale) THEN BEGIN
    IF (!P.MULTI[2] GT 1) THEN BEGIN
      xsca     = 7d-1
      xlen     = pos[2,*] - pos[0,*]    ; -size of x-axis in normalized coords.
      pos[2,*] = pos[2,*] - xlen/1d1*xsca
      pos[0,*] = pos[0,*] + xlen/3d1*xsca
    ENDIF ELSE BEGIN
      xsca   = 5d-1
      xlen   = pos[2] - pos[0]    ; -size of x-axis in normalized coords.
      pos[2] = pos[2] - xlen/1d1*xsca
      pos[0] = pos[0] + xlen/2d1*xsca
    ENDELSE
  ENDIF
  str_element,/ADD_REPLACE,plotstuff,'POSITION',pos[*,(np-p) MOD np]
  IF (!P.MULTI[0] NE 0) THEN !P.MULTI[0] = !P.MULTI[0] - 1
ENDIF ELSE BEGIN
  IF (!P.MULTI[0] NE 0) THEN str_element,/ADD_REPLACE,plotstuff,'NOERASE',1
  IF NOT KEYWORD_SET(re_draw) THEN BEGIN
    IF (!P.MULTI[0] NE 0) THEN !P.MULTI[0] = !P.MULTI[0] - 1
  ENDIF
ENDELSE
;*****************************************************************************
; -Adjust the aspect ratio => rescale axes
;*****************************************************************************
IF KEYWORD_SET(aspect) THEN BEGIN
   dx = ABS(xr[1] - xr[0])
   dy = ABS(yr[1] - yr[0])
   IF (dx NE 0 AND dy NE 0) THEN  asp_ratio = dy/dx ELSE asp_ratio = 1.
   p_size = [!D.X_SIZE,!D.Y_SIZE]
   tpos   = pos * [p_size,p_size]
   dtpos  = [tpos[2]-tpos[0],tpos[3]-tpos[1]]
   dtpos2 = [1.0,asp_ratio] * (dtpos[0] < dtpos[1]/asp_ratio)
   dts    = dtpos - dtpos2
   IF KEYWORD_SET(top) THEN r =1. ELSE r = .5
   ds     = [r*dts, (r - 1)*dts]
   tpos2  = tpos + ds
   pos    = (tpos2/[p_size,p_size]) - 0.5*[0.9,0.05,0.01,0.1]  ; -changes plot position   
   str_element,/ADD_REPLACE,plotstuff,'POSITION',pos
ENDIF
;*****************************************************************************
; -Error handling
;*****************************************************************************
IF KEYWORD_SET(metric) THEN BEGIN
  message,/info,'METRIC is an obsolete keyword...'
  pos  = plotstuff.POSITION
  arat = (pos[3] - pos[1])/(pos[2] - pos[0])*!D.X_SIZE/!D.Y_SIZE
  dxr  = ABS(xr[1] - xr[0])*1.1
  mxr  = (xr[1] + xr[0])/2
  dyr  = ABS(yr[1] - yr[0])*1.1
  myr  = (yr[1] + yr[0])/2
  IF (arat GT dyr/dxr) THEN dyr = dxr*arat ELSE dxr = dyr/arat
  xr   = mxr - dxr * [-.5,.5]
  yr   = myr - dyr * [-.5,.5]
  xlim,plotstuff,xr[0],xr[1]
  ylim,plotstuff,yr[0],yr[1]
ENDIF

PLOT,xr,yr,/NODATA,_EXTRA=plotstuff
mposi = plotstuff.POSITION
RETURN
END