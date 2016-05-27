;+
;*****************************************************************************************
;
;  FUNCTION :   draw_color_scale.pro
;  PURPOSE  :   Creates a color bar for plotting spectra or other images.
;
;  CALLED BY:   
;               specplot.pro
;
;  CALLS:
;               bytescale.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               RANGE      :  2-Element array defining the range of the data values
;               BRANGE     :  2-Element array defining the color map values that the
;                               data scale spans
;               LOG        :  If set, scale is logarithmic
;               CHARSIZE   :  Character size to be used for scale
;               YTICKS     :  Scalar defining the one less than the # of tick marks
;                               [Default = 1]
;                               [same functionality as keyword used by PLOT.PRO]
;               POSITION   :  4-Element Float array of color bar position [x0,y0,x1,y1]
;                               [same functionality as keyword used by PLOT.PRO]
;               OFFSET     :  2-Element array giving the offsets from the right side of
;                               the current plot for calculating the x0 and x1 positions
;                               of the color scale. In device units. Ignored if
;                               POSITION keyword is set.
;               TITLE      :  String title for color bar
;               YTICKNAME  :  String array of tick names for color bar
;                               [Default = strings associated with calculated values]
;                               [same functionality as keyword used by PLOT.PRO]
;               YTICKV     :  Float array of tick values for color bar
;                               [same functionality as keyword used by PLOT.PRO]
;               _EXTRA     :  Same keyword as used by AXIS.PRO
;                               [passed directly to AXIS.PRO]
;
;   CHANGED:  1)  Davin's last modification                        [06/25/2001   v1.1.16]
;             2)  Patrick Cruce added YTICKNAME keyword and some comments
;                                                                  [06/21/2009   v1.2.0]
;             3)  Updated man page and rewrote                     [06/21/2009   v1.2.0]
;             4)  Fixed tick label issue                           [08/13/2009   v1.2.1]
;             5)  Fixed Y-Axis issue                               [10/22/2009   v1.2.2]
;             6)  Updated to be in accordance with newest version of draw_color_scale.pro
;                   in TDAS IDL libraries
;                   A)  added keywords:  YTICKNAME and YTICKV
;                   B)  no longer uses () for arrays
;                                                                  [03/24/2012   v1.3.0]
;             6)  Updated to be in accordance with newest version of draw_color_scale.pro
;                   in TDAS IDL libraries [thmsw_r10908_2012-09-10]
;                   A)  new keywords:  _EXTRA
;                   B)  new functionalities
;                                                                  [09/12/2012   v1.4.0]
;
;   NOTES:      
;               1)  User should not call this routine...
;               2)  This version has some error handling for tick marks that the TDAS
;                     version does not
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/12/2012   v1.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO draw_color_scale,RANGE=range,BRANGE=brange,LOG=log,YTICKS=yticks, $
                     POSITION=pos,OFFSET=offset,CHARSIZE=charsize,    $
                     TITLE=title,YTICKNAME=ytickname,YTICKV=ytickv,   $
                     _EXTRA=ex

;;----------------------------------------------------------------------------------------
;; => Determine some default parameters
;;----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(brange) THEN brange = [7,!D.TABLE_SIZE-2]

IF NOT KEYWORD_SET(charsize) THEN charsize = !P.CHARSIZE
IF (charsize EQ 0.) THEN charsize = 1.0
IF NOT KEYWORD_SET(title)    THEN title = ''
IF NOT KEYWORD_SET(log) THEN ylog = 0 ELSE ylog = 1
;;----------------------------------------------------------------------------------------
;; => Determine the window size
;;----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(pos) THEN BEGIN
  IF NOT KEYWORD_SET(offset) THEN offset = [1.,2]
  space = charsize * !D.X_CH_SIZE/!D.X_SIZE   
  IF (!P.MULTI[1]*!P.MULTI[2] GT 4) THEN space = space/2
  xw = !X.WINDOW[1] + offset * space
  yw = !Y.WINDOW  
  pos = [xw[0],yw[0],xw[1],yw[1]]
ENDIF ELSE BEGIN
  xw = pos[[0,2]]
  yw = pos[[1,3]]
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Set up plot area but no data yet
;;----------------------------------------------------------------------------------------
;; color scale is generated using a plot
;;   thus plot parameters for this sub-plot could change the overall plot
xt    = !X    ; save previous plot parameters
yt    = !Y
clipt = !P.CLIP
;;----------------------------------------------------------------------------------------
;; => Check plot range in case it's "bad"
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(range) THEN BEGIN
  n_ran = N_ELEMENTS(range) EQ 2
  IF (n_ran) THEN range = range[SORT(range)] ELSE range = [0.,1.]
  PLOT,[0,1],range,YRANGE=range,/NODATA,/NOERASE,POS=pos,XSTYLE=1+4,YSTYLE=1+4,YLOG=log
ENDIF ELSE BEGIN
  PLOT,[0,1],[0,1],/NODATA,/NOERASE,POS=pos,XSTYLE=1+4,YSTYLE=1+4,YLOG=log
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Determine positions
;;----------------------------------------------------------------------------------------
pixpos    = ROUND(CONVERT_COORD(!X.WINDOW,!Y.WINDOW,/NORM,/TO_DEVICE))
npx       = pixpos[0,1] - pixpos[0,0]
npy       = pixpos[1,1] - pixpos[1,0]
xposition = pixpos[0,0]
yposition = pixpos[1,0]
;;----------------------------------------------------------------------------------------
;; => Determine whether to scale data or not
;;----------------------------------------------------------------------------------------
IF (!D.NAME EQ 'PS') THEN scale = 40./1000. else scale = 1.
nypix = ROUND(scale*npy)
y     = FINDGEN(nypix)*(!Y.CRANGE[1] - !Y.CRANGE[0])/(nypix - 1L) + !Y.CRANGE[0]
IF KEYWORD_SET(log) THEN y = 10.^y
;;----------------------------------------------------------------------------------------
;; => Convert data to byte-scale and plot
;;----------------------------------------------------------------------------------------
y = bytescale(y,BOTTOM=brange[0],TOP=brange[1],RANGE=range,LOG=ylog)
image = REPLICATE(1b,npx) # y

TV,image,xposition,yposition,XSIZE=npx,YSIZE=npy
;;----------------------------------------------------------------------------------------
;; => Define tick values, labels, and # of tick marks
;;----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(yticks) THEN yticks = 1

IF KEYWORD_SET(ytickv) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;; => YTICKV set
  ;;--------------------------------------------------------------------------------------
  nv_check = (N_ELEMENTS(ytickv) - 1L) EQ yticks[0]
  IF (nv_check) THEN BEGIN
    ; => YTICKV set correctly
    ytv = REFORM(ytickv)
  ENDIF ELSE BEGIN
    ; => YTICKV NOT set correctly
    IF (ylog) THEN BEGIN
      log_range = [MIN(ALOG10(range),/NAN),MAX(ALOG10(range),/NAN)]
      ytv_log   = FINDGEN(yticks + 1L)*(log_range[1] - log_range[0])/yticks + log_range[0]
      ytv       = 1e1^(ytv_log)
    ENDIF ELSE BEGIN
      ytv    = FINDGEN(yticks + 1L)*(range[1] - range[0])/(yticks) + range[0]
    ENDELSE
  ENDELSE
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;; => YTICKV NOT set
  ;;--------------------------------------------------------------------------------------
  IF (ylog) THEN BEGIN
    log_range = [MIN(ALOG10(range),/NAN),MAX(ALOG10(range),/NAN)]
    ytv_log   = FINDGEN(yticks + 1L)*(log_range[1] - log_range[0])/yticks + log_range[0]
    ytv       = 1e1^(ytv_log)
  ENDIF ELSE BEGIN
    ytv    = FINDGEN(yticks + 1L)*(range[1] - range[0])/(yticks) + range[0]
  ENDELSE
ENDELSE

IF KEYWORD_SET(ytickname) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;; => YTICKNAME set
  ;;--------------------------------------------------------------------------------------
  nv_check = (N_ELEMENTS(ytickname) - 1L) EQ yticks[0]
  IF (nv_check) THEN BEGIN
    ; => YTICKNAME set correctly
    ytn = REFORM(ytickname)
  ENDIF ELSE BEGIN
    ; => YTICKNAME NOT set correctly
    myform = '(G15.3)'
    ytn0   = STRTRIM(STRING(FORMAT=myform,ytv),2L)
    ytn    = STRARR(yticks + 1L)
    eposi  = STRPOS(ytn0,'E')
    gposi  = WHERE(eposi GE 0,ep,COMPLEMENT=bposi,NCOMPLEMENT=bp)
    IF (ep GT 0) THEN BEGIN
      e_strp     = eposi[gposi]
      FOR j=0L, ep - 1L DO BEGIN
        ind           = gposi[j]
        t_str         = e_strp[j]
        ytn[ind]      = STRMID(ytn0[ind],0L,t_str)+'x10!U'+STRMID(ytn0[ind],t_str+1L)+'!N'
      ENDFOR
      IF (bp GT 0) THEN ytn[bposi] = STRTRIM(ytn0[bposi],2)
    ENDIF ELSE BEGIN
      ytn = STRTRIM(ytn0,2)
    ENDELSE
  ENDELSE
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;; => YTICKNAME NOT set
  ;;--------------------------------------------------------------------------------------
  myform = '(G15.3)'
  ytn0   = STRTRIM(STRING(FORMAT=myform,ytv),2L)
  ytn    = STRARR(yticks + 1L)
  eposi  = STRPOS(ytn0,'E')
  gposi  = WHERE(eposi GE 0,ep,COMPLEMENT=bposi,NCOMPLEMENT=bp)
  IF (ep GT 0) THEN BEGIN
    e_strp     = eposi[gposi]
    FOR j=0L, ep - 1L DO BEGIN
      ind           = gposi[j]
      t_str         = e_strp[j]
      ytn[ind]      = STRMID(ytn0[ind],0L,t_str)+'x10!U'+STRMID(ytn0[ind],t_str+1L)+'!N'
    ENDFOR
    IF (bp GT 0) THEN ytn[bposi] = STRTRIM(ytn0[bposi],2)
  ENDIF ELSE BEGIN
    ytn = STRTRIM(ytn0,2)
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Outline the color bar
;;----------------------------------------------------------------------------------------
IF (NOT KEYWORD_SET(title) OR title EQ '') THEN BEGIN
  IF (ylog) THEN title = 'Log' ELSE title = 'Lin'
ENDIF

IF (npy LT 50) THEN BEGIN
  ; => Don't use ticks because of small plot size
  AXIS,YAXIS=1,YSTYLE=1,YRANGE=range,YLOG=ylog,YTITLE=title,CHARSIZE=charsize,$
       YTICKS=1
ENDIF ELSE BEGIN
;  TDAS Update
;  AXIS,YAXIS=1,YSTYLE=1,YRANGE=range,YLOG=ylog,YTITLE=title,CHARSIZE=charsize,$
;       YTICKS=yticks,YTICKV=ytv,YTICKNAME=ytn
  ; => Use the user defined ticks
  AXIS,YAXIS=1,YSTYLE=1,YRANGE=range,YLOG=ylog,YTITLE=title,CHARSIZE=charsize,$
       YTICKS=yticks,YTICKV=ytv,YTICKNAME=ytn,_EXTRA=ex
ENDELSE

xbox = [xw[0],xw[1],xw[1],xw[0],xw[0]]
ybox = [yw[0],yw[0],yw[1],yw[1],yw[0]]
PLOTS,xbox,ybox,/NORMAL,/NOCLIP
;;----------------------------------------------------------------------------------------
;; => Restore previous plot parameters
;;----------------------------------------------------------------------------------------
!X      = xt
!Y      = yt
!P.CLIP = clipt
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
