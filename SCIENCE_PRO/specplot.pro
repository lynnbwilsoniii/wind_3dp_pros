;+
;*****************************************************************************************
;
;  FUNCTION :   specplot.pro
;  PURPOSE  :   Creates a spectrogram plot from given input.  User defines axes
;                 labels and positions in the keyword LIMITS.
;
;  CALLED BY:   
;               tplot.pro
;
;  CALLS:
;               str_element.pro
;               struct_value.pro
;               extract_tags.pro
;               dprint.pro
;               specplot.pro
;               minmax.pro
;               interp.pro
;               bytescale.pro
;               box.pro
;               draw_color_scale.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X             :  X-axis values => Dimension N.
;               Y             :  Y-axis values => Dimension M. or (N,M)
;               Z             :  Color axis values:  Dimension (N,M).
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               LIMITS        :  A structure that may contain any combination of the 
;                                  following elements:
;=========================================================================================
;                                  ALL plot keywords such as:
;                                  XLOG,   YLOG,   ZLOG,
;                                  XRANGE, YRANGE, ZRANGE,
;                                  XTITLE, YTITLE,
;                                  TITLE, POSITION, REGION  etc. (see IDL
;                                    documentation for a description)
;                                  The following elements can be included in 
;                                    LIMITS to effect DRAW_COLOR_SCALE:
;                                      ZTICKS, ZRANGE, ZTITLE, ZPOSITION, ZOFFSET
; **[Note: Program deals with these by itself, so just set them if necessary and let 
;           it do the rest.  Meaning, if you know what the tick marks should be on 
;           your color bar, define them under the ZTICK[V,NAME,S] keywords in the 
;           structure ahead of time.]**
;=========================================================================================
;               DATE          :  [string] 'MMDDYY'
;               TIME          :  [string] ['HH:MM:SS.xxx'] associated with time of 
;                                  TDS event
;               PS_RESOLUTION :  Post Script resolution.  Default is 60.
;               COLOR_POS     :  Same as output of plot positions, but this specifies
;                                  the position(s) of the color bar(s) [normalized
;                                  coords.] => Define as a named variable to be
;                                  returned by program {see: my_plot_positions.pro}
;               NO_INTERP     :  If set, do no x or y interpolation.
;               X_NO_INTERP   :  Prevents interpolation along the x-axis.
;               Y_NO_INTERP   :  Prevents interpolation along the y-axis.
;               OVERPLOT      :  If non-zero, then data is plotted over last plot.
;               OVERLAY       :  If non-zero, then data is plotted on top of data 
;                                  from last plot.
;               IGNORE_NAN    :  If non-zero, ignore data points that are not finite.
;               DATA          :  A structure that provides an alternate means of
;                                   supplying the data and options.  This is the 
;                                   method used by "TPLOT".
;               DX_GAP_SIZE   :  Maximum time gap over which to interpolate the plot.
;                                   Use this keyword when overlaying spectra plots,
;                                   allowing the underlying spectra to be shown in the
;                                   data gaps of the overlying spectra.  Overrides
;                                   value set by DATAGAP in dlimits.  Note: if either
;                                   DX_GAP_SIZE or DATAGAP is set to less than zero,
;                                   then the 20 times the smallest delta x is used.
;
;   CHANGED:  1)  Davin Larson changed something...
;                                                                  [11/01/2002   v1.0.?]
;             2)  Patrick Cruce added DX_GAP_SIZE keyword and some comments
;                                                                  [01/25/2011   v1.0.?]
;             3)  Re-wrote and cleaned up
;                                                                  [06/10/2009   v1.1.0]
;             4)  Changed some minor syntax stuff
;                                                                  [06/11/2009   v1.1.1]
;             5)  Fixed a typo which occured when Y input had 2-Dimensions
;                                                                  [09/14/2009   v1.1.2]
;             6)  Updated to be in accordance with newest version of mplot.pro
;                   in TDAS IDL libraries
;                   A)  no longer calls dimen.pro, dimen2.pro, or makegap.pro
;                   B)  no longer uses () for arrays
;                   C)  now calls struct_value.pro, dprint.pro
;                   D)  now uses ZTICKNAME and ZTICKV when calling draw_color_scale.pro
;                                                                  [03/24/2012   v2.1.0]
;             7)  Updated to be in accordance with newest version of specplot.pro
;                   in TDAS IDL libraries [thmsw_r10908_2012-09-10]
;                   A)  new plotting options
;                   B)  new functionalities
;                                                                  [09/12/2012   v2.2.0]
;             8)  Updated to be in accordance with newest version of specplot.pro
;                   in TDAS IDL libraries [tdas_8_00]
;                   A)  new error handling to avoid bugs
;                                                                  [07/30/2013   v2.3.0]
;             9)  Fixed a unique bug that occurs if there are several data gaps which
;                   causes the routine to shutoff the color scale if the last time
;                   segment happens to be part of a data gap
;                                                                  [12/10/2014   v2.3.1]
;            10)  Fixed a typo in the indexing part where the routine resizes the Y data
;                                                                  [12/01/2015   v2.3.2]
;            11)  Cleaned up a little
;                                                                  [12/01/2015   v2.3.3]
;
;   NOTES:      
;               1)  The arrays x and y MUST be monotonic!  (increasing or decreasing)
;               2)  The default is to interpolate in both the x and y dimensions.
;               3)  Data gaps can be included by setting the z values to !VALUES.F_NAN.
;               4)  If ZLOG is set then non-positive zvalues are treated as missing data.
;
;  SEE ALSO:
;               xlim.pro
;               ylim.pro
;               zlim.pro
;               options.pro
;               tplot.pro
;               draw_color_scale.pro
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  12/01/2015   v2.3.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO specplot,x,y,z,LIMITS=lim,DATA=data,OVERPLOT=overplot,OVERLAY=overlay,$
                   PS_RESOLUTION=ps_res,X_NO_INTERP=x_no_interp,          $
                   Y_NO_INTERP=y_no_interp,NO_INTERP=no_interp,           $
                   IGNORE_NAN=ignore_nan,DX_GAP_SIZE=dx_gap_size

;;----------------------------------------------------------------------------------------
;;  Constants/Dummy variables
;;----------------------------------------------------------------------------------------
;;  Turn into an array to keep track of color scale setting to avoid routine shutting
;;    off the color scale because the last data gap happens to be void of data
;;    --> LBW III  12/10/2014   v2.3.1
no_CS_per_gap  = 0
;;----------------------------------------------------------------------------------------
;; Set defaults:
;;----------------------------------------------------------------------------------------
opt = {XRANGE:[0.,0.],YRANGE:[0.,0.],ZRANGE:[1.,1.]}

IF KEYWORD_SET(dx_gap_size) THEN dg = dx_gap_size ELSE str_element,lim,'DATAGAP',dg

IF KEYWORD_SET(data) THEN BEGIN
  x = struct_value(data,'x')
  y = struct_value(data,'v')
  z = struct_value(data,'y')
  IF NOT KEYWORD_SET(y) THEN BEGIN
    ;;  Y structure tag not found
    y = struct_value(data,'v2')  ;  bp
    z = TOTAL(z,2,/NAN)
  ENDIF
  extract_tags,opt,data,EXCEPT=['X','Y','V']
  ;  TDAS addition 2011-01-25
  IF KEYWORD_SET(dx_gap_size) THEN dg = dx_gap_size ELSE str_element,lim,'datagap',dg
;  str_element,lim,'DATAGAP',dg
;  IF KEYWORD_SET(dg) THEN makegap,dg,x,z,V=y
ENDIF

IF KEYWORD_SET(no_interp) THEN BEGIN
  x_no_interp = 1
  y_no_interp = 1
ENDIF
;;----------------------------------------------------------------------------------------
;;  Find where gaps are
;;----------------------------------------------------------------------------------------
;  TDAS addition
IF KEYWORD_SET(dg) THEN BEGIN
  ;dg = max_gap_interp
  ;dt = median(x[1:*]-x)
  tdif = [x[1L:*] - x[0L:(N_ELEMENTS(x) - 2L)]]
  ;;--------------------------------------------------------------------------------------
  ;;  set minimum gap interp to twice median sampling rate in current trange
  ;;--------------------------------------------------------------------------------------
  ;if dg lt 2*dt then dg = 2*dt
  IF (dg LT 0) THEN BEGIN
    ;;  set dg to 20 times the smallest dx if datagap and/or dx_gap_size is negative
    posindx = WHERE(tdif GT 0,poscnt)
    dg      = 20d*MIN(tdif[posindx],/NAN)
  ENDIF
;  TDAS Update
;  dprint,VERBOSE=verbose,'No plot interpolation for data gaps longer than ', $
;         STRCOMPRESS(dg,/REMOVE_ALL),' seconds.'
  ;;  print out information
  dprint,'No plot interpolation for data gaps longer than ', $
         STRCOMPRESS(dg,/REMOVE_ALL),' seconds.',DLEVEL=3,VERBOSE=verbose
  gapindx = WHERE(tdif GT dg,gapcnt)
  IF (gapcnt GT 0) THEN BEGIN
    ;;   create separate vars
    seg0 = LONARR(gapcnt + 1L) ; index numbers of start of each data segment 
    seg1 = seg0                ; index numbers of end of each data segment
    seg1[gapcnt] =  N_ELEMENTS(x) - 1L
    FOR i=0L, gapcnt - 1L DO BEGIN
      ;  TODO: Need to account for "consecutive gaps" to reduce # of segments
      ;          (gapcnt) and speed up the main loop for time windows with lots of
      ;          data with sample intervals greater than DATAGAP flag and/or
      ;          DX_GAP_SIZE.
      seg0[i + 1L] = gapindx[i] + 1L
      seg1[i]      = gapindx[i]
    ENDFOR
  ENDIF ELSE BEGIN
    ;;   prepare for only single iteration in for loop
    seg0 = 0L
    seg1 = N_ELEMENTS(x) - 1L
  ENDELSE
ENDIF ELSE BEGIN
  ;;   prepare for only single iteration in for loop
  gapcnt = 0
  seg0   = 0L
  seg1   = N_ELEMENTS(x) - 1L
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Copy temp variables
;;----------------------------------------------------------------------------------------
xtemp = x
ytemp = y
ztemp = z
;;----------------------------------------------------------------------------------------
;;  Copy settings from the OPT structure
;;----------------------------------------------------------------------------------------
extract_tags,opt,lim
;;  Read settings from the OPT structure
str_element,opt,'XLOG',VALUE=xlog
str_element,opt,'YLOG',VALUE=ylog
str_element,opt,'ZLOG',VALUE=zlog
;;----------------------------------------------------------------------------------------
;;  If autoscaling is on, make sure to autoscale outside the gap segment loop.
;;  Otherwise each gap segment will autoscale to a different range when datagap is set.
;;  (task# 4724)
;;  pcruce 2012-10-10
;;----------------------------------------------------------------------------------------
;;  LBW III added the following error handling to make sure structure tag exists
;;  [07/30/2013   v2.3.0]
zrange         = struct_value(opt,'zrange')
test           = (N_ELEMENTS(zrange) NE 2)
IF (test) THEN zrange = [0,0]
IF (zrange[0] EQ zrange[1]) THEN BEGIN
  IF KEYWORD_SET(zlog) THEN BEGIN
    good = WHERE(FINITE(ALOG(z)),goodcnt)
    IF (goodcnt GT 0) THEN BEGIN
      zrange = minmax(z[good])
    ENDIF ELSE BEGIN
      zrange = [0,0]
    ENDELSE
  ENDIF ELSE BEGIN
    zrange = minmax(z,/nan)
  ENDELSE
ENDIF ELSE BEGIN
  zrange = opt.ZRANGE
ENDELSE

;IF (gapcnt GT 0) THEN cs_gapcnt = gapcnt + 1L ELSE cs_gapcnt = 1L
;;    --> LBW III  12/10/2014   v2.3.1
cs_gapcnt      = gapcnt[0] + 1L
no_CS_per_gap  = INTARR(cs_gapcnt[0])
;;----------------------------------------------------------------------------------------
;;  Loop
;;----------------------------------------------------------------------------------------
ydim = SIZE(y,/N_DIMENSIONS)
FOR j=0L, gapcnt DO BEGIN
  x = xtemp[seg0[j]:seg1[j]]
  IF (ydim EQ 1) THEN y = ytemp ELSE y = ytemp[seg0[j]:seg1[j],*]
  z = ztemp[seg0[j]:seg1[j],*]
  ;;--------------------------------------------------------------------------------------
  ;;  Recall program
  ;;--------------------------------------------------------------------------------------
  IF (N_PARAMS() EQ 1) THEN BEGIN
    szx = SIZE(x)
    IF (szx[0] NE 0) THEN BEGIN
      dim = SIZE(x,/DIMENSIONS)
    ENDIF ELSE BEGIN
      IF (SIZE(x,/TYPE) EQ 0L) THEN dim = 0L ELSE dim = 1L
    ENDELSE
    specplot,FINDGEN(dim[0]),FINDGEN(dim[1]),x,LIMITS=lim,OVERPLOT=overplot,$
             OVERLAY=overlay,PS_RESOLUTION=ps_res, $
             X_NO_INTERP=x_no_interp,Y_NO_INTERP=y_no_interp
    RETURN
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Set more defaults:
  ;;--------------------------------------------------------------------------------------
;  extract_tags,opt,lim
  IF (opt.XRANGE[0] EQ opt.XRANGE[1]) THEN opt.XRANGE = minmax(x)
  IF (opt.YRANGE[0] EQ opt.YRANGE[1]) THEN opt.YRANGE = minmax(y)
  ;str_element,opt,'ytype',VALUE=ylog   ; obsolete keywords
  ;str_element,opt,'xtype',VALUE=xlog
  ;str_element,opt,'ztype',VALUE=zlog
;  str_element,opt,'XLOG',VALUE=xlog
;  str_element,opt,'YLOG',VALUE=ylog
;  str_element,opt,'ZLOG',VALUE=zlog
  str_element,opt,'GIFPLOT',VALUE=gifplot
  IF KEYWORD_SET(gifplot) THEN BEGIN
    x_no_interp    = 1
    y_no_interp    = 1
    no_color_scale = 1
  ENDIF
  str_element,opt,'X_NO_INTERP',VALUE=x_no_interp
  str_element,opt,'Y_NO_INTERP',VALUE=y_no_interp
  str_element,opt,'NO_INTERP',VALUE=no_interp
  IF KEYWORD_SET(no_interp) THEN BEGIN
    ;;  override individual interpolation options for each axis
    x_no_interp = 1
    y_no_interp = 1
  ENDIF
  str_element,opt,'MAX_VALUE',VALUE=mx
  str_element,opt,'MIN_VALUE',VALUE=mn
  ;if keyword_set(mx) then print,'max_value= ', mx
  str_element,opt,'ZTITLE',   VALUE=ztitle  ;; in case user wants new title
  str_element,opt,'BOTTOM',   VALUE=bottom
  str_element,opt,'TOP',      VALUE=top
  IF NOT KEYWORD_SET(overplot) THEN box,opt     ; Sets plot parameters.
  ;;--------------------------------------------------------------------------------------
  ;;  Determine data ranges and alter if log-scale
  ;;--------------------------------------------------------------------------------------
;  moved this line outside this loop to fix the zrange bug
;  zrange = opt.ZRANGE
  y1     = y
  ;;  Y-Range
  IF KEYWORD_SET(ylog) THEN BEGIN
    ;;  Remove zeros and negatives for log-scale
    bad = WHERE(FINITE(y1) EQ 0,c)
    IF (c NE 0) THEN y1[bad] = 0.
    bad = WHERE(y1 LE 0,c)
    IF (c NE 0) THEN y1[bad] = !VALUES.F_NAN
    y1 = ALOG10(y1)
  ENDIF
  IF KEYWORD_SET(xlog) THEN x1 = ALOG10(x) ELSE x1 = x
  str_element,opt,'minzlog',VALUE=minzlog  ;;  TDAS addition
  ;;  Z-Range
  z1 = z
  IF KEYWORD_SET(zlog) THEN BEGIN
    ;;  Remove zeros and negatives for log-scale
    bad = WHERE(FINITE(z1) EQ 0,cbad)
    IF (cbad NE 0) THEN z1[bad] = !VALUES.F_NAN
    neg = WHERE(z1 LE 0,cneg)
    IF KEYWORD_SET(minzlog) THEN BEGIN
      posrange = minmax(z1,/POSITIVE)
      negvals  = posrange[0]/10.
    ENDIF ELSE BEGIN
;      negvals = !VALUES.F_NAN
      negvals = 0
    ENDELSE
    IF (cneg NE 0) THEN z1[neg] = negvals
    ;;  Redefine z-values and range
    z1         = ALOG10(z1)
    ;;  so that we don't mess up the original zrange, make a copy
    zrange_new = ALOG10(zrange)
    IF KEYWORD_SET(mn) THEN mn = ALOG10(mn)
    IF KEYWORD_SET(mx) THEN mx = ALOG10(mx)
  ENDIF ELSE BEGIN
    ;;  copy zrange even if it isn't modified in this case so that it is defined for following code, no matter what
    zrange_new = zrange
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  Define window parameters
  ;;--------------------------------------------------------------------------------------
  xwindow = !X.WINDOW
  ywindow = !Y.WINDOW
  xcrange = !X.CRANGE
  ycrange = !Y.CRANGE
;  str_element,opt,'OVERLAY',VALUE=overlay
  overlay = struct_value(opt,'overlay',DEFAULT=1)
  ;;  need to be in overlay mode if stitching multiple segments together
  IF (gapcnt GT 0) THEN overlay = 1
  IF KEYWORD_SET(overlay) THEN BEGIN
    winpos     = CONVERT_COORD(minmax(x),minmax(y),/DATA,/TO_NORM)
    xwr        = minmax(winpos[0,*])
    ywr        = minmax(winpos[1,*])
   ;   xwindow(0) = xwindow(0) > xwr(0)
   ;   xwindow(1) = xwindow(1) < xwr(1)
    xwindow    = xwindow > xwr[0]
    xwindow    = xwindow < xwr[1]
    ywindow[0] = ywindow[0] > ywr[0]
    ywindow[1] = ywindow[1] < ywr[1]
    datpos     = CONVERT_COORD(xwindow,ywindow,/NORM,/TO_DATA)
    xcrange    = REFORM(datpos[0,*])
    ycrange    = REFORM(datpos[1,*])
    IF !X.TYPE THEN xcrange = ALOG10(xcrange)
    IF !Y.TYPE THEN ycrange = ALOG10(ycrange)
  ENDIF
  pixpos         = ROUND(CONVERT_COORD(xwindow,ywindow,/NORM,/TO_DEVICE))
  npx            = pixpos[0,1] - pixpos[0,0] + 1
  npy            = pixpos[1,1] - pixpos[1,0] + 1
  xposition      = pixpos[0,0]
  yposition      = pixpos[1,0]
  
  no_color_scale = 1  ;;  Default to no color scale
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  IF (npx GT 0 AND npy GT 0) THEN BEGIN
    str_element,opt,'ignore_nan',ignore_nan
    IF KEYWORD_SET(ignore_nan) THEN BEGIN
      wg = WHERE(FINITE(TOTAL(z1,2)),c)
      IF (c GT 0) THEN BEGIN
        z1 = z1[wg,*]
        y1 = y1[wg,*]
        x1 = x1[wg]
      ENDIF
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  Scalable pixels (postscript)
    ;;      Postscript defaults to 150 dpi => adjust if user desires
    ;;------------------------------------------------------------------------------------
    IF (!D.FLAGS AND 1) THEN BEGIN
      ;;  Set Postscript defaults to 150 dpi
      IF KEYWORD_SET(ps_res) THEN ps_resolution = ps_res ELSE ps_resolution = 150.
      str_element,opt,'PS_RESOLUTION',VALUE=ps_resolution
      dprint,DLEVEL=4,ps_resolution
      scale = ps_resolution/!D.X_PX_CM/2.54
    ENDIF ELSE BEGIN
      scale = 1.
    ENDELSE
    yd  = SIZE(y1,/N_DIMENSIONS)
    ;*************************************************************************************
    ;*************************************************************************************
    ;*************************************************************************************
    IF (yd EQ 1) THEN BEGIN            ; Typical, y does not vary with time
      ;;----------------------------------------------------------------------------------
      ;;  Rescale Y-Data
      ;;----------------------------------------------------------------------------------
      nypix = ROUND(scale[0]*npy)
      ny    = N_ELEMENTS(y1)
      yp    = FINDGEN(nypix)*(ycrange[1] - ycrange[0])/(nypix - 1L) + ycrange[0]
;      ys    = interp(FINDGEN(ny),y1,yp)
      ys    = interp(FINDGEN(ny),y1,yp,/NO_CHECK_MONOTONIC)
      IF KEYWORD_SET(y_no_interp) THEN ys = ROUND(ys)
      ;;----------------------------------------------------------------------------------
      ;;  Rescale X-Data and interpolate
      ;;----------------------------------------------------------------------------------
      nxpix = ROUND(scale[0]*npx)
      IF (nxpix LE 1) THEN BEGIN  ; changed from nxpix ne 0 to le 1, since nxpix=1 causes xp=NaN and no plot, jmm, 13-oct-2010
;  TDAS Update
;        dprint,VERBOSE=verbose,DLEVEL=2,'WARNING: Data segment ',STRCOMPRESS(j,/REMOVE_ALL),$
;        ' is too small along the  x-axis',STRING(13B),$
;        '   for the given time window or is not within the given window.  Nothing will be',STRING(13B),$
;        '   plotted.  Try making the x-axis window smaller, or if creating a postscript',STRING(13B),$
;        "   file, try increasing the 'ps_resolution' value using the OPTIONS command."
        dprint,'WARNING: Data segment ',STRCOMPRESS(j,/REMOVE_ALL),' is too small along the  x-axis',VERBOSE=verbose,DLEVEL=4
;        dprint,'WARNING: Data segment ',STRCOMPRESS(j,/REMOVE_ALL),' is too small along the  x-axis',VERBOSE=verbose,DLEVEL=2
        no_color_scale   = 1
;;    --> LBW III  12/10/2014   v2.3.1
        no_CS_per_gap[j] = no_color_scale[0]
        CONTINUE
      ENDIF ELSE BEGIN
        no_color_scale = 0  ;;  turn on color scale
      ENDELSE
      nx    = N_ELEMENTS(x1)
      xp    = FINDGEN(nxpix)*(xcrange[1] - xcrange[0])/(nxpix - 1L) + xcrange[0]
      xs    = interp(FINDGEN(nx),x1,xp,/NO_CHECK_MONOTONIC)
;      xs    = interp(FINDGEN(nx),x1,xp)
      IF KEYWORD_SET(x_no_interp) THEN xs = ROUND(xs)
      image = INTERPOLATE(FLOAT(z1),xs,ys,MISSING=!VALUES.F_NAN,/GRID)  ; using float( ) to fix IDL bug.
    ENDIF ELSE BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Rescale Y-Data
      ;;----------------------------------------------------------------------------------
      nypiy = ROUND(scale[0]*npy)
      szy   = SIZE(y1)
      IF (szy[0] LT 1) THEN ny1 = 1 ELSE ny1 = szy[1]
      IF (szy[0] LT 2) THEN ny  = 1 ELSE ny  = szy[2]
      yp    = FINDGEN(nypiy)*(ycrange[1] - ycrange[0])/(nypiy - 1L) + ycrange[0]
      ;;----------------------------------------------------------------------------------
      ;;  Rescale X-Data and interpolate
      ;;----------------------------------------------------------------------------------
      nxpix = ROUND(scale[0]*npx)
      IF (nxpix LE 1) THEN BEGIN  ; changed from nxpix ne 0 to le 1, since nxpix=1 causes xp=NaN and no plot, jmm, 13-oct-2010
;  TDAS Update
;        dprint,VERBOSE=verbose,DLEVEL=2,'WARNING: Data segment ',STRCOMPRESS(j,/REMOVE_ALL),$
;        ' is too small along the x-axis',STRING(13B),$
;        '   for the given time window or is not within the given window.  Nothing will be',STRING(13B),$
;        '   plotted.  Try making the x-axis window smaller, or if creating a postscript',STRING(13B),$
;        "   file, try increasing the 'ps_resolution' value using the OPTIONS command."
        dprint,'WARNING: Data segment ',STRCOMPRESS(j,/REMOVE_ALL),' is too small along the  x-axis',VERBOSE=verbose,DLEVEL=4
;        dprint,'WARNING: Data segment ',STRCOMPRESS(j,/REMOVE_ALL),' is too small along the  x-axis',VERBOSE=verbose,DLEVEL=2
        no_color_scale   = 1
;;    --> LBW III  12/10/2014   v2.3.1
        no_CS_per_gap[j] = no_color_scale[0]
        CONTINUE
      ENDIF ELSE BEGIN
        no_color_scale = 0  ;;  turn on color scale
      ENDELSE
      nx    = N_ELEMENTS(x1)
      xp    = FINDGEN(nxpix)*(xcrange[1] - xcrange[0])/(nxpix - 1L) + xcrange[0]
      xs    = interp(FINDGEN(nx),x1,xp,/NO_CHECK_MONOTONIC)
;      xs    = interp(FINDGEN(nx),x1,xp)
      xs    = xs # REPLICATE(1.,nypiy)  ;;  make a 2D array
      bad   = WHERE(FINITE(xs) eq 0,c)
      IF (c NE 0) THEN xs[bad] = -1
      IF KEYWORD_SET(x_no_interp) THEN xs = ROUND(xs)
      ;;----------------------------------------------------------------------------------
      ;;  Resize Y-Data
      ;;----------------------------------------------------------------------------------
      ys    = REPLICATE(-1.,nxpix,nypiy)
      y_ind = FINDGEN(ny)
      xi    = ROUND(xs)
      FOR i=0L, nxpix - 1L DO BEGIN
        ;;  in this line it will generate a - 1 which gets turned into 0
        m       = (xi[i] > 0) < (ny1 - 1L)
        yt1     = REFORM(y1[m,*])
;        ys[i,*] = interp(y_ind,yt1,yp)
        ys[i,*] = interp(y_ind,yt1,yp,/NO_CHECK_MONOTONIC)
      ENDFOR
      ;dtime = systime(1)-starttime
      ;message,string(dtime)+' seconds.',/info
      ;;----------------------------------------------------------------------------------
      ;;  Interpolate data
      ;;----------------------------------------------------------------------------------
      bad   = WHERE(FINITE(ys) EQ 0,c)
      IF (c NE 0) THEN ys[bad] = -1
      IF KEYWORD_SET(y_no_interp) THEN  ys = ROUND(ys)
      image = INTERPOLATE(FLOAT(z1),xs,ys,MISSING=!VALUES.F_NAN)  ; using float( ) to fix IDL bug.
    ENDELSE
    ;*************************************************************************************
    ;*************************************************************************************
    ;*************************************************************************************
    ;;------------------------------------------------------------------------------------
    ;;  Convert image to byte-scale
    ;;------------------------------------------------------------------------------------
    IF NOT KEYWORD_SET(gifplot) THEN BEGIN
;      IF (zrange[0] EQ zrange[1]) THEN zrange = minmax(image,MAX=mx,MIN=mn)
;      image = bytescale(image,BOTTOM=bottom,TOP=top,RANGE=zrange)
      IF (zrange_new[0] EQ zrange_new[1]) THEN zrange_new = minmax(image,MAX=mx,MIN=mn)
      image = bytescale(image,BOTTOM=bottom,TOP=top,RANGE=zrange_new)
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  fill color code provided by Tomo Hori (E-mail: horit@stelab.nagoya-u.ac.jp)
    ;;  installed by pcruce on Jan,25,2011
    ;;  if fill_color defined, fill all pixels with the same color specified by fill_color
    ;;------------------------------------------------------------------------------------
    str_element,opt,'FILL_COLOR',VALUE=fill_color
    IF ~KEYWORD_SET(fill_color) THEN fill_color = -1
    IF (fill_color GE 0) THEN BEGIN
      idx = WHERE(image LT 255) & IF (idx[0] NE -1) THEN image[idx] = fill_color
      no_color_scale = 1
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  Plot image
    ;;------------------------------------------------------------------------------------
    ;printdat,image,xposition,yposition
    IF (xposition GE 0 AND yposition GE 0 AND xposition LT !D.X_SIZE and yposition LT !D.Y_SIZE) THEN BEGIN
      IF (fill_color LT 0) THEN BEGIN
        TV,image,xposition,yposition,XSIZE=npx,YSIZE=npy
      ENDIF ELSE BEGIN
        idx = WHERE(image EQ fill_color)
        IF (idx[0] NE -1) THEN BEGIN
          FOR i=0L, N_ELEMENTS(idx) - 1L DO BEGIN
            ind = ARRAY_INDICES(image,idx[i])
            POLYFILL,xposition + ROUND( (ind[0] + [0,1,1,0])/scale[0] ), $
                     yposition + ROUND( (ind[1] + [0,0,1,1])/scale[0] ), $
                     COLOR=fill_color,/DEVICE
          ENDFOR
        ENDIF
      ENDELSE
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  Redraw the axes
    ;;------------------------------------------------------------------------------------
    str_element,/ADD_REPLACE,opt,'NOERASE',1
    str_element,/ADD_REPLACE,opt,'OVERPLOT',/DELETE
    str_element,/ADD_REPLACE,opt,'YTITLE',/DELETE
    str_element,/ADD_REPLACE,opt,'POSITION',REFORM(TRANSPOSE([[!X.WINDOW],[!Y.WINDOW]]),4)
    ;HELP,opt,/str
    box,opt
;  TDAS Update
;  ENDIF ELSE dprint,DLEVEL=0,'Out of range error'
;;    --> LBW III  12/10/2014   v2.3.1
    no_CS_per_gap[j] = no_color_scale[0]
  ENDIF ELSE BEGIN
;;    --> LBW III  12/10/2014   v2.3.1
    no_CS_per_gap[j] = no_color_scale[0]
    msg = (npx LE 0 AND npy LE 0) ?  'x/y' : (npx LE 0) ? 'x':'y'
    dprint,'Warning, data is outside the current '+msg+' axis range.',DLEVEL=0
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Set up color bar
;;----------------------------------------------------------------------------------------
;  TDAS Update
str_element,opt,'CONSTANT',constant
IF (N_ELEMENTS(constant) NE 0) THEN BEGIN
  str_element,opt,'CONST_COLOR',const_color
  IF (N_ELEMENTS(const_color) NE 0) THEN ccols = get_colors(const_color) ELSE ccols = !P.COLOR
  ncc = N_ELEMENTS(constant)
  FOR i=0L, ncc - 1L DO BEGIN
    OPLOT,opt.XRANGE,constant[i]*[1,1],COLOR=ccols[i MOD N_ELEMENTS(ccols)],/LINESTYLE
  ENDFOR
ENDIF
;;  Redefine Z-range if log-scale set
;;    no longer necessary with new variable zrange_new
;IF KEYWORD_SET(zlog) THEN zrange = 10.0^zrange

;  TDAS Update
;charsize = !P.CHARSIZE
;str_element,opt,'CHARSIZE',VALUE=charsize
;;----------------------------------------------------------------------------------------
;;  Get color bar settings
;;----------------------------------------------------------------------------------------
;;    --> LBW III  12/10/2014   v2.3.1
test           = (no_color_scale GT 0) AND (TOTAL(no_CS_per_gap) NE cs_gapcnt[0])
IF (test) THEN BEGIN
  ;;  Turn color bar back on since there is finite data in at least one interval
  ;;    within current time window
  no_color_scale = 0
ENDIF
zcharsize      = !P.CHARSIZE
str_element,opt,'CHARSIZE'      ,VALUE=zcharsize
str_element,opt,'ZCHARSIZE'     ,VALUE=zcharsize ;; specific setting overrides general/global setting
IF NOT KEYWORD_SET(zcharsize) THEN zcharsize = 1.
;  TDAS Update
str_element,opt,'FONT'          ,zfont
str_element,opt,'ZFONT'         ,zfont
str_element,opt,'NO_COLOR_SCALE',no_color_scale
;  TDAS Update
str_element,opt,'CHARTHICK'     ,zcharthick
str_element,opt,'ZCHARTHICK'    ,zcharthick
;;  Get color bar plot keyword values
;  TDAS Update
str_element,opt,'ZPOSITION'    ,zposition
str_element,opt,'ZOFFSET'      ,zoffset
str_element,opt,'ZMINOR'       ,zminor
str_element,opt,'ZGRIDSTYLE'   ,zgridstyle
str_element,opt,'ZTHICK'       ,zthick
str_element,opt,'ZTICKFORMAT'  ,ztickformat
str_element,opt,'ZTICKINTERVAL',ztickinterval
str_element,opt,'ZTICKLAYOUT'  ,zticklayout
str_element,opt,'ZTICKLEN'     ,zticklen
str_element,opt,'ZTICKNAME'    ,ztickname
str_element,opt,'ZTICKS'       ,zticks
str_element,opt,'ZTICKUNITS'   ,ztickunits
str_element,opt,'ZTICKV'       ,ztickv
str_element,opt,'ZTITLE'       ,ztitle
;;  Get color bar plot keyword values
;str_element,opt,'NO_COLOR_SCALE',VALUE=no_color_scale
;str_element,opt,'ZPOSITION',zposition
;str_element,opt,'ZOFFSET',zoffset
;str_element,opt,'ZTICKS',zticks
;str_element,opt,'ZTICKV',ztickv
;str_element,opt,'ZTICKNAME',ztickname
;;----------------------------------------------------------------------------------------
;;  Draw color bar if desired
;;----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(no_color_scale) THEN BEGIN
;  TDAS Update
;  draw_color_scale,BRANGE=[bottom,top],RANGE=zrange,LOG=zlog,TITLE=ztitle, $
;                   CHARSIZE=charsize,POSITION=zposition,OFFSET=zoffset,    $
;                   YTICKS=zticks,YTICKNAME=ztickname,YTICKV=ztickv
  IF (KEYWORD_SET(bottom) AND KEYWORD_SET(top)) THEN BEGIN
    draw_color_scale,BRANGE=[bottom,top],RANGE=zrange,LOG=zlog,TITLE=ztitle,            $
                     CHARSIZE=zcharsize,YTICKS=zticks,POSITION=zposition,OFFSET=zoffset,$
                     YGRIDSTYLE=zgridstyle,YMINOR=zminor,YTHICK=zthick,                 $
                     YTICKFORMAT=ztickformat,YTICKINTERVAL=ztickinterval,               $
                     YTICKLAYOUT=zticklayout,YTICKLEN=zticklen,YTICKNAME=ztickname,     $
                     YTICKUNITS=ztickunits,YTICKV=ztickv,YTITLE=ztitle,FONT=zfont,      $
                     CHARTHICK=zcharthick
  ENDIF ELSE BEGIN
    dprint,DLEVEL=0,'Cannot draw color scale.  Either the data is out of '+ $
                    'range or top/bottom options must be set in tplot.'
  ENDELSE
ENDIF
;;----------------------------------------------------------------------------------------
;;  copy from temp variable back to input variables
;;----------------------------------------------------------------------------------------
x = xtemp
y = ytemp
z = ztemp
;;----------------------------------------------------------------------------------------
;;  Return
;;----------------------------------------------------------------------------------------

RETURN
END

