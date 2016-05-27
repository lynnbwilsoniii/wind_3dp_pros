;+
;*****************************************************************************************
;
;  FUNCTION :   density_hist_2d_wrapper.pro
;  PURPOSE  :   This routine is a wrapping routine for HIST_2D.PRO that allows the user
;                 to define the number of bins and specify a logarithmic scale.  The
;                 routine will then determine the appropriate bin width.
;
;  CALLED BY:   
;               density_contour_plot.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               XDATA       :  [N]-Element array [float/double] of independent data points
;               YDATA       :  [N]-Element array [float/double] of   dependent data points
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               [X,Y]MIN    :  Scalar [float/double] defining the Min. [X,Y]-Axis plot
;                                value and the corresponding Min. value to consider when
;                                constructing the 2D histogram.
;                                { Default = MIN([X,Y]DATA) }
;               [X,Y]MAX    :  Scalar [float/double] defining the Max. [X,Y]-Axis plot
;                                value and the corresponding Max. value to consider when
;                                constructing the 2D histogram.
;                                { Default = MAX([X,Y]DATA) }
;               N[X,Y]      :  Scalar [long] defining the # of [X,Y]-Axis bins to use
;                                [Default = 100L]
;               [X,Y]_LOG   :  Scalar [long] defining whether the [X,Y]-Axis should be
;                                put on a log-scale
;                                [Default = FALSE]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  05/01/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/01/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION density_hist_2d_wrapper,xdata,ydata,XMIN=xmin,XMAX=xmax,NX=nx,X_LOG=x_log,$
                                             YMIN=ymin,YMAX=ymax,NY=ny,Y_LOG=y_log

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
noinpt_msg     = 'No input supplied...'
nofint_msg     = 'No finite data...'
badinp_msg     = 'XDATA and YDATA must have the same number of elements...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN BEGIN
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test_xy        = ((N_ELEMENTS(xdata) EQ 0) OR (N_ELEMENTS(ydata) EQ 0)) OR $
                 (N_ELEMENTS(xdata) NE N_ELEMENTS(ydata))
IF (test_xy) THEN BEGIN
  MESSAGE,badinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

xx             = REFORM(xdata)
yy             = REFORM(ydata)
;;  Define default [X,Y]-Range
test_x         = FINITE(xx)
test_y         = FINITE(yy)
good_xra       = WHERE(test_x,gdx)
good_yra       = WHERE(test_y,gdy)
mnmx_x         = [MIN(xx[good_xra],/NAN),MAX(xx[good_xra],/NAN)]
mnmx_y         = [MIN(yy[good_yra],/NAN),MAX(yy[good_yra],/NAN)]
IF (mnmx_x[1] LT mnmx_x[0]) THEN mnmx_x = REVERSE(mnmx_x)
IF (mnmx_y[1] LT mnmx_y[0]) THEN mnmx_y = REVERSE(mnmx_y)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------

;;-----------------------------------------
;;  X-Axis Keywords
;;-----------------------------------------
test__nx       = (N_ELEMENTS(nx)   EQ 0)
IF (N_ELEMENTS(xmin) EQ 0) THEN xmn = mnmx_x[0] ELSE xmn = xmin[0]
IF (N_ELEMENTS(xmax) EQ 0) THEN xmx = mnmx_x[1] ELSE xmx = xmax[0]
IF (test__nx)              THEN nnx = 100L      ELSE nnx = nx[0]
xran_def       = [xmn[0],xmx[0]]        ;;  Linear-scale
log_xr_def     = ALOG10(xran_def)       ;;  Log-scale

;;-----------------------------------------
;;  Y-Axis Keywords
;;-----------------------------------------
test__ny       = (N_ELEMENTS(ny)   EQ 0)
IF (N_ELEMENTS(ymin) EQ 0) THEN ymn = mnmx_y[0] ELSE ymn = ymin[0]
IF (N_ELEMENTS(ymax) EQ 0) THEN ymx = mnmx_y[1] ELSE ymx = ymax[0]
IF (test__ny)              THEN nny = 100L      ELSE nny = ny[0]
yran_def       = [ymn[0],ymx[0]]        ;;  Linear-scale
log_yr_def     = ALOG10(yran_def)       ;;  Log-scale
;;----------------------------------------------------------------------------------------
;;  Define bin width
;;----------------------------------------------------------------------------------------
;;  X-Axis bin width
IF KEYWORD_SET(x_log) THEN BEGIN
  ;;  Log-scale
;  diffx  = 1d1^(log_xr_def[1] - log_xr_def[0])
;  diffx  = (log_xr_def[1] - log_xr_def[0])
  xlog   = 1
  xran   = log_xr_def
  xx_h2d = ALOG10(xx)
ENDIF ELSE BEGIN
  ;;  Linear-scale
;  diffx  = (xran_def[1] - xran_def[0])
  xlog   = 0
  xran   = xran_def
  xx_h2d = xx
ENDELSE
diffx          = (xran[1] - xran[0])
widthx         = diffx[0]/(1d0*(nnx[0] - 1L))

;;  Y-Axis bin width
IF KEYWORD_SET(y_log) THEN BEGIN
  ;;  Log-scale
;  diffy  = 1d1^(log_yr_def[1] - log_yr_def[0])
;  diffy  = (log_yr_def[1] - log_yr_def[0])
  ylog   = 1
  yran   = log_yr_def
  yy_h2d = ALOG10(yy)
ENDIF ELSE BEGIN
  ;;  Linear-scale
;  diffy  = (yran_def[1] - yran_def[0])
  ylog   = 0
  yran   = yran_def
  yy_h2d = yy
ENDELSE
diffy          = (yran[1] - yran[0])
widthy         = diffy[0]/(1d0*(nny[0] - 1L))
;;----------------------------------------------------------------------------------------
;;  Create 2D Histogram
;;----------------------------------------------------------------------------------------
;;  Define 2D Histogram structure
exstr          = {MIN1:xran[0],MAX1:xran[1],BIN1:widthx[0],$
                  MIN2:yran[0],MAX2:yran[1],BIN2:widthy[0]}
;;  Construct 2D histogram
hist2d         = HIST_2D(xx_h2d,yy_h2d,_EXTRA=exstr)
;;  Check output
IF (SIZE(hist2d,/N_DIMENSIONS) NE 2) THEN hist2d = REPLICATE(d,nnx[0],nny[0])
;;  Determine size
szh2d          = SIZE(hist2d,/DIMENSIONS)
;;  Redefine NX and NY if necessary
nnx            = szh2d[0]
nny            = szh2d[1]
;;----------------------------------------------------------------------------------------
;;  Define corresponding [X,Y]-grid
;;----------------------------------------------------------------------------------------
x_locs         = DINDGEN(nnx[0])*(xran[1] - xran[0])/(1d0*(nnx[0] - 1L)) + xran[0]
y_locs         = DINDGEN(nny[0])*(yran[1] - yran[0])/(1d0*(nny[0] - 1L)) + yran[0]
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
exstr_out      = {MINX:xran[0],MAXX:xran[1],BINX:widthx[0],NX:nnx[0],XLOG:xlog,$
                  MINY:yran[0],MAXY:yran[1],BINY:widthy[0],NY:nny[0],YLOG:ylog}
h2d_input      = {V1:xx_h2d,V2:yy_h2d}
tags           = ['HIST2D','X_LOCS','Y_LOCS','HIST_2D_STR','HIST_2D_IN']
struc          = CREATE_STRUCT(tags,hist2d,x_locs,y_locs,exstr_out,h2d_input)
;;----------------------------------------------------------------------------------------
;;  Return structure to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END

