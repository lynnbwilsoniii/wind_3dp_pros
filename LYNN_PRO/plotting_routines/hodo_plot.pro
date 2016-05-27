;+
;*****************************************************************************************
;
;  FUNCTION :   hodo_plot.pro
;  PURPOSE  :   Takes two arrays of data which represent two components of a 3D vector
;                 and plots 9 hodograms, evenly distributing the number of points on
;                 each.
;
;  CALLED BY:   
;               wi_tdss_hodo.pro
;               etc.
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               V1       :  N-Element array for one component of a vector array of data
;               V2       :  N-Element array for one component of a vector array of data
;                             (obviously not the same as V1)
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               XYSCALE  :  Scalar value used to force the XY-Axes to a specified
;                             scale that may depend on another component not
;                             used in this specific plot. 
;                             [Default = MAX(ABS([V1,V2]),/NAN)]
;               FNAME    :  Scalar string used to define the file name one wishes to
;                             name the file when saving
;               XTTL     :  Scalar string defining the X-Axis Title
;                             [Default = 'Component-X']
;               YTTL     :  Scalar string defining the Y-Axis Title
;               VECNAME  :  Scalar string defining the vector name
;                             [Default = 'Component']
;               VNAMES   :  3-Element string array used to define the vector components
;                             to use when labeling plots/axes
;                             [Default = ('x','y','z')]
;               UNITS    :  Scalar string defining the units, if relevant, for the
;                             data being plotted
;                             [Default = '']
;               CHAN1    :  ['x','y','z'] for Channel [1,2,3] respectively, corresponding
;                             to the data being plotted on the X-Axis AND the first 
;                             necessary data input
;               CHAN2    :  ['x','y','z'] for Channel [1,2,3] respectively, corresponding
;                             to the data being plotted on the Y-Axis AND the second
;                             necessary data input
;                             **[CHAN1 Default = 'x', CHAN2 Default = 'y']**
;               TITLES   :  9-Element string array defining the plot titles to use
;                             [Default = string array specifying which elements
;                              are being plotted]
;               FSAVE    :  If set, the device is set to 'ps' thus saving file as a 
;                             *.ps file.  If NOT set, then the device is left as 'x'
;                             making it possible to plot to the screen for checking and
;                             user manipulation.
;
;   CHANGED:  1)  Updated man page                            [08/10/2009   v1.0.1]
;             2)  Forgot to include use of UNITS keyword      [08/28/2009   v1.0.2]
;
;   CREATED:  08/04/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/28/2009   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO hodo_plot,v1,v2,XYSCALE=xyscale,FNAME=fname,XTTL=xttl,YTTL=yttl,VECNAME=vecname,$
                    VNAMES=vnames,UNITS=units,CHAN1=chan1,CHAN2=chan2,TITLES=titles,$
                    FSAVE=fsave

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f         = !VALUES.F_NAN
d         = !VALUES.D_NAN
dvecs     = ['x','y','z']
nplts     = 9L               ; -# of plots

IF NOT KEYWORD_SET(units) THEN gunits = '' ELSE gunits = STRTRIM(units,2L)
IF NOT KEYWORD_SET(vecname) THEN prefvec = 'Component' ELSE prefvec = STRTRIM(vecname,2L)
IF NOT KEYWORD_SET(vnames) THEN BEGIN
  IF NOT KEYWORD_SET(chan1) THEN chan1 = 'x'
  IF NOT KEYWORD_SET(chan2) THEN chan2 = 'y'
  IF KEYWORD_SET(chan1) THEN xx = STRLOWCASE(chan1) ELSE xx = 'x'
  IF KEYWORD_SET(chan2) THEN yy = STRLOWCASE(chan2) ELSE yy = 'y'
ENDIF ELSE BEGIN
  IF NOT KEYWORD_SET(chan1) THEN chan1 = vnames[0]
  IF NOT KEYWORD_SET(chan2) THEN chan2 = vnames[1]
  IF KEYWORD_SET(chan1) THEN xx = STRLOWCASE(chan1) ELSE xx = vnames[0]
  IF KEYWORD_SET(chan2) THEN yy = STRLOWCASE(chan2) ELSE yy = vnames[1]
ENDELSE
; => Define X and Y Axis Titles
IF NOT KEYWORD_SET(xttl) THEN BEGIN
  x_title = prefvec+'-'+STRUPCASE(xx)+gunits
ENDIF ELSE BEGIN
  x_title = (REFORM(xttl))[0]
ENDELSE
IF NOT KEYWORD_SET(yttl) THEN BEGIN
  y_title = prefvec+'-'+STRUPCASE(yy)+gunits
ENDIF ELSE BEGIN
  y_title = (REFORM(yttl))[0]
ENDELSE

IF NOT KEYWORD_SET(fname) THEN BEGIN
  plot_name = 'Components_'+xx+yy+'_HODO.ps'
ENDIF ELSE BEGIN
  plot_name = fname[0]
ENDELSE
;-----------------------------------------------------------------------------------------
; => Make sure we're not overwriting an already existing file
;-----------------------------------------------------------------------------------------
check  = FILE_SEARCH(plot_name)
IF (check[0] NE '') THEN BEGIN
  p_leng    = STRLEN(plot_name[0])
  plot_name = STRMID(plot_name[0],0L,p_leng - 3L)+'_2.ps'
ENDIF
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
vx        = REFORM(v1)
vy        = REFORM(v2)
nx        = N_ELEMENTS(vx)
ny        = N_ELEMENTS(vy)
IF (nx NE ny) THEN $
MESSAGE,'Incorrect Elements: V1 and V2 MUST have equal number of elements!',/INFORMATIONAL

IF NOT KEYWORD_SET(xyscale) THEN hdlm = MAX(ABS([vx,vy]),/NAN) ELSE hdlm = xyscale[0]
;-----------------------------------------------------------------------------------------
; => Define plot titles
;-----------------------------------------------------------------------------------------
nepts     = (nx - 1L)/nplts      ; => # of points on each plot
def_ttls  = STRARR(9)
FOR j=0L, 8L DO BEGIN
  nump        = j*nepts       ; -Start element of data
  nump1       = nump + nepts  ; -End element of data
  def_ttls[j] = 'Points : '+STRTRIM(nump,2)+'-'+STRTRIM(nump1,2)
ENDFOR
IF NOT KEYWORD_SET(titles) THEN p_titles = def_ttls ELSE p_titles = titles
;-----------------------------------------------------------------------------------------
; => Define plot structure and relevant parameters
;-----------------------------------------------------------------------------------------
plot_str     = {XTITLE:x_title,YTITLE:y_title,XRANGE:[-hdlm,hdlm],$
                YRANGE:[-hdlm,hdlm],YSTYLE:1,XSTYLE:1,NODATA:1}

!P.CHARSIZE  = 1.2
!P.CHARTHICK = 2.5
!P.MULTI     = [0,3,3]
ppm          = !P.MULTI
ppm[0]       = nplts
;-----------------------------------------------------------------------------------------
; => Determine system plotting information
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(fsave) THEN BEGIN
  IF (STRLOWCASE(!D.NAME) NE 'ps') THEN BEGIN ; -Higher level .PRO didn't set device yet
    SET_PLOT,'ps'
    DEVICE,/LANDSCAPE,ENCAPSULATED=1,XSIZE=8.0,YSIZE=8.0,YOFFSET=8.0,/INCHES
    DEVICE,FILENAME=plot_name,/COLOR
  ENDIF ELSE BEGIN                            ; -Higher level .PRO already set device
    DEVICE,/LANDSCAPE,ENCAPSULATED=1,XSIZE=8.0,YSIZE=8.0,YOFFSET=8.0,/INCHES
    DEVICE,FILENAME=plot_name,/COLOR
    fsave = 0
  ENDELSE
ENDIF ELSE BEGIN
  IF (STRLOWCASE(!D.NAME) NE 'ps') THEN BEGIN
    CASE !VERSION.OS_NAME OF
      'Mac OS X' : BEGIN                      ; => If Mac, then force color table = 39
        LOADCT,39
        DEVICE,DECOMPOSED=0
      END
      ELSE : BEGIN
        DEVICE,DECOMPOSED=0
      END
    ENDCASE
    IF (!D.WINDOW EQ -1) THEN BEGIN           ; => No windows are open yet
      WINDOW, 4,RETAIN=2,XSIZE=1000,YSIZE=1000
      WSET,4
      WSHOW,4
    ENDIF ELSE BEGIN
      wind = !D.WINDOW
      lind = LINDGEN(32)
      gind = WHERE(lind NE wind,gd)
      nwin = lind[gind[0]]                    ; => New window index
      IF (ppm[0] EQ 0) THEN BEGIN
        WINDOW, nwin,RETAIN=2,XSIZE=1000,YSIZE=1000
        WSET,nwin
        WSHOW,nwin
      ENDIF
    ENDELSE
  ENDIF
ENDELSE
;-----------------------------------------------------------------------------------------
; -Plot the data
;-----------------------------------------------------------------------------------------
j         = 0L
nump      = j*nepts       ; -Start element of data
nump1     = nump + nepts  ; -End element of data
searching = 1
WHILE(searching) DO BEGIN
  !P.MULTI = ppm
  tttl     = p_titles[j]
  ; -Plot Data
  PLOT,vx[nump:nump1],vy[nump:nump1],_EXTRA=plot_str,TITLE=tttl
    OPLOT,vx[nump:nump1],vy[nump:nump1],COLOR=50
    OPLOT,[0.0],[0.0],PSYM=1,COLOR=250    ; -Put a + at origin of plot
    ;-------------------------------------------------------------------------------------
    ; -Check plot conditions before plotting again
    ;-------------------------------------------------------------------------------------
    ppm[0] = ppm[0] - 1L
    IF (j LT nplts - 1L)  THEN searching = 1 ELSE searching = 0
    IF (searching) THEN j += 1L
    nump  = j*nepts
    nump1 = nump + nepts
ENDWHILE

IF KEYWORD_SET(fsave) THEN BEGIN
  DEVICE,/CLOSE
  SET_PLOT,'X'
  !P.MULTI = 0
ENDIF
RETURN
END