;+
;*****************************************************************************************
;
;  FUNCTION :   grid_data_contour.pro
;  PURPOSE  :   Takes three arrays of irregularly gridded data and produces a contour
;                 plot of the results.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               roundsig.pro
;               popen.pro
;               pclose.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X        :  N-Element array of abscissa values of X-coordinate for 
;                             F(x,y) [i.e. x data]
;               Y        :  N-Element array of abscissa values of Y-coordinate for 
;                             F(x,y) [i.e. y data]
;               F        :  N-Element array of the values of the function at points 
;                             (x[i],y[i])  [i.e. z data]
;
;  EXAMPLES:    
;               grid_data_contour,x,y,f,NLEVELS=10,TITLE='Contour Plot'
;
;  KEYWORDS:    
;               NLEVELS  :  Scalar long/integer defining the number of contour levels
;               TITLE    :  Scalar string defining the plot title
;               XTITLE   :  Scalar string defining X-Axis plot title
;               YTITLE   :  Scalar string defining Y-Axis plot title
;               FNAME    :  If set, defines file name of PS file (if FSAVE set)
;               FSAVE    :  If set, program saves plot to PS file
;               XRANGE   :  2-Element array defining X-Axis data range to plot
;               YRANGE   :  2-Element array defining Y-Axis data range to plot
;               XLOG     :  If set, X-Axis is plotted on a log-scale
;               YLOG     :  If set, Y-Axis is plotted on a log-scale
;
;   CHANGED:  1)  Fixed typo in NLEVELS keyword               [04/18/2010   v1.0.1]
;
;   NOTES:      
;               
;
;   CREATED:  04/15/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/18/2010   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO grid_data_contour,x,y,f,NLEVELS=nlev,TITLE=tttl,XTITLE=xttl,YTITLE=yttl,$
                            FNAME=fname,FSAVE=fsave,XRANGE=xran,YRANGE=yran,$
                            XLOG=xlg,YLOG=ylg

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(nlev)    THEN nlevels   = 15L ELSE nlevels   = nlev[0]
IF NOT KEYWORD_SET(tttl)    THEN tttl_delf = ''  ELSE tttl_delf = tttl[0]
IF NOT KEYWORD_SET(xttl)    THEN xttl_delf = 'x' ELSE xttl_delf = xttl[0]
IF NOT KEYWORD_SET(yttl)    THEN yttl_delf = 'y' ELSE yttl_delf = yttl[0]
IF NOT KEYWORD_SET(fname)   THEN fname     = 'contour_plot' ELSE fname = fname[0]
IF NOT KEYWORD_SET(fsave)   THEN ffg       = 0   ELSE ffg       = 1

xd = REFORM(x)
yd = REFORM(y)
fd = REFORM(f)
IF NOT KEYWORD_SET(xran)    THEN xra = [MIN(xd,/NAN),MAX(xd,/NAN)] ELSE xra = xran
IF NOT KEYWORD_SET(yran)    THEN yra = [MIN(yd,/NAN),MAX(yd,/NAN)] ELSE yra = yran

IF NOT KEYWORD_SET(xlg)     THEN xlog = 0 ELSE xlog = 1
IF NOT KEYWORD_SET(ylg)     THEN ylog = 0 ELSE ylog = 1
;-----------------------------------------------------------------------------------------
; => Define grids and remove repeated values
;-----------------------------------------------------------------------------------------
GRID_INPUT,x,y,f,xSorted,ySorted,dataSorted

nsort     = N_ELEMENTS(xSorted)
gridsize  = [nsort,nsort]
; => Determine X-Data grid points
slope     = (MAX(xSorted,/NAN) - MIN(xSorted,/NAN))/(gridSize[0] - 1)
intercept = MIN(xSorted,/NAN)
xGrid     = (slope*FINDGEN(gridSize[0])) + intercept
; => Determine Y-Data grid points
slope     = (MAX(ySorted,/NAN) - MIN(ySorted,/NAN))/(gridSize[1] - 1)
intercept = MIN(ySorted,/NAN)
yGrid     = (slope*FINDGEN(gridSize[1])) + intercept
; => Re-Grid data to desired size
result    = GRIDDATA(xSorted,ySorted,dataSorted,DIMENSION=gridsize)

;-----------------------------------------------------------------------------------------
; => Determine plot structure
;-----------------------------------------------------------------------------------------
range     = [MIN(result,/NAN),MAX(result,/NAN)]
IF KEYWORD_SET(cpd) THEN BEGIN
  cpd0 = cpd
ENDIF ELSE BEGIN
  cpd0 = FLOOR(nlevels/(range[1] - range[0])) > 1.
ENDELSE 
IF N_ELEMENTS(cpd) EQ 0 THEN BEGIN
   cpd = FIX(nlevels/(range[1] - range[0])) > 1
ENDIF
nn2       = nlevels - 1L
mxres     = CEIL(MAX(result,/NAN))
levels    = FINDGEN(nlevels)*(mxres[0] - range[0])/nn2 + range[0]
levels    = roundsig(levels,SIG=2)
;levels    = (FINDGEN(nlevels) - nn2)/cpd0 + CEIL(MAX(result,/NAN))
;levels    = BYTSCL(INDGEN(nlevels),TOP=!D.TABLE_SIZE-4) + 1B
color     = LONARR(nlevels)
color     = LINDGEN(nlevels)*(254L - 15L)/(nlevels - 1L) + 15L
color     = ROUND((color*1e3)^(2e0/3e0)/16e0)
c_colors  = BYTE(color)

IF (nlevels GT 3) THEN BEGIN
  good_lbs           = INDGEN(nlevels/3L)*3L + 2L
  c_labels           = REPLICATE(0,nlevels)
  c_labels[good_lbs] = 1
  flll               = 0
ENDIF ELSE BEGIN
  c_labels           = REPLICATE(1,nlevels)
  flll               = 1
ENDELSE 

pstr      = {NLEVELS:nlevels,TITLE:tttl_delf,XTITLE:xttl_delf,YTITLE:yttl_delf,$
             XSTYLE:1,YSTYLE:1,ZSTYLE:1,C_LABELS:c_labels,C_COLORS:c_colors,   $
             XRANGE:xra,YRANGE:yra,XLOG:xlog,YLOG:ylog,FILL:flll}
IF (ffg) THEN BEGIN
  popen,fname,/LAND
    CONTOUR,result,xGrid,YGrid,_EXTRA=pstr
  pclose
ENDIF ELSE BEGIN
  CONTOUR,result,xGrid,YGrid,_EXTRA=pstr
ENDELSE

RETURN
END