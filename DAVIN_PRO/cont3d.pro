;+
;*****************************************************************************************
;
;  FUNCTION :   cont3d.pro
;  PURPOSE  :   Produces a contour plot of the distribution function with parallel and 
;                 perpendicular cuts shown.  One can also, with appropriate keywords,
;                 output contours of constant speed. 
;
;  CALLED BY:   NA
;
;  CALLS:
;               get_colors.pro
;               add_df2dp.pro
;               distfunc.pro
;               str_element.pro
;               trange_str.pro
;               minmax_range.pro
;               minmax.pro
;               extract_tags.pro
;               draw_color_scale.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT  :  3D data structure retrieved from get_??(el,elb,eh,pl, etc.)
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               NEWDAT    :  Set to a named variable to return the new structure created
;                              by add_df2dp.pro
;               OPTIONS   :  Set to plot limit structure [i.e. _EXTRA=lim in PLOT.PRO etc.]
;               DPOINTS   :  Obselete?
;               CIRCLES   :  Set to an array defining circles of constant velocity
;               NCIRCLES  :  Set to a scalar defining the # of constant velocity 
;                              circles you wish to output on the DF contours
;               VLIM      :  Limit for x-y axes over which to plot data
;                              [Default = max vel. from energy bin values]
;               NGRID     :  # of isotropic velocity grids to use to triangulate the data
;                              [Default = 30L]
;               CPD       :  Set to a scalar to define contours per decade
;               UNITS     :  [String] Units to be plotted in [convert to given data units
;                              before plotting]
;               XR        :  Obselete?
;               YR        :  Obselete?
;
;   CHANGED:  1)  Davin Larson changed something...       [??/??/????   v1.0.?]
;             2)  Re-wrote and cleaned up                 [06/21/2009   v1.1.0]
;             3)  Changed program my_distfunc.pro to distfunc.pro
;                                                         [08/05/2009   v1.2.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/05/2009   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO cont3d,dat,NEWDAT=dat3d,OPTIONS=opt,                                $
           DPOINTS=dpoints,CIRCLES=circles,NCIRCLES=ncircles,VLIM=vlim, $
           NGRID=ngrid,CPD=cpd,UNITS=units,XR=xr,YR=yr

;*****************************************************************************************
;*****************************************************************************************
dat3d = dat
myname = ''
myname = dat3d.DATA_NAME
IF (KEYWORD_SET(ngrid) EQ 0) THEN ngrid = 30
;*****************************************************************************************
; -Get color scales
;color = [0,10,20,30,40,50,60,70,80,90,110,130,140,150,210,215,220,225,230,235,240,245,250,254]
;*****************************************************************************************
cc1   = get_colors()
color = BYTARR(8)
color = [cc1.RED,cc1.GREEN,cc1.MAGENTA,cc1.BLUE,cc1.RED,cc1.GREEN,cc1.MAGENTA,cc1.BLUE]
;*****************************************************************************************
; => calculate the velocity projections in B-field plane
;*****************************************************************************************
TRUE      = 1
FALSE     = 0
searching = TRUE
temp_ra   = minmax(dat.DATA,/POSITIVE)
WHILE(searching) DO BEGIN
  IF (dat.valid EQ 0) THEN BEGIN
    PRINT, 'There is no valid data for this sample.'
    searching = FALSE
    RETURN
  ENDIF ELSE BEGIN
    add_df2dp,dat3d,VLIM=vlim,MINCNT=temp_ra[0]
    red = 200
    ;   set default options:
    title  = dat3d.PROJECT_NAME+'  '+dat3d.DATA_NAME
    title  = title+'!C'+trange_str(dat3d.TIME,dat3d.END_TIME)
    ytitle = 'V perpendicular  (km/sec)'
    xtitle = 'V parallel  (km/sec)'
    str_element,contstuff,'TITLE',title,/ADD_REPLACE
    str_element,contstuff,'XTITLE',xtitle,/ADD_REPLACE
    str_element,contstuff,'YTITLE',ytitle,/ADD_REPLACE
    nddt = N_ELEMENTS(dat3d.df2d) 
    IF (nddt LT 2) THEN BEGIN
      PRINT,'Invalid Data'
      searching = FALSE
      RETURN
    ENDIF ELSE BEGIN
      dfdata = dat3d.df2d
      searching = FALSE
    ENDELSE  
  ENDELSE
ENDWHILE
bdf = WHERE(FINITE(dfdata) EQ 0 OR dfdata LE 0d0,bdf1)  ; => Check for nonfinite data
IF (bdf1 GT 0) THEN BEGIN
  bfind = ARRAY_INDICES(dfdata,bdf)
  dfdata[bfind[0,*],bfind[1,*]] = !VALUES.F_NAN
ENDIF ELSE BEGIN
  dfdata = dfdata
ENDELSE
;*****************************************************************************************
;vout = [(dindgen(2*ngrid+1)/ngrid-1)*vlim,(dindgen(2*ngrid+1)/ngrid-1)*vlim*(-1.)]
vout = (DINDGEN(2*ngrid + 1L)/ngrid - 1L) * vlim
vx   = vout # REPLICATE(1.,2*ngrid+1)
vy   = REPLICATE(1.,2*ngrid+1) # vout

df       = distfunc(vx,vy,PARAM=dat)
df_range = ALOG(minmax(df))/ ALOG(10.)

IF KEYWORD_SET(cpd) THEN BEGIN
  cpd0 = cpd
ENDIF ELSE BEGIN
  cpd0 = FLOOR(15./(df_range[1]-df_range[0])) > 1.
ENDELSE

df10     = ALOG(df)/ ALOG(10.)
nn2      = ngrid - 1L
mylevels = (FINDGEN(ngrid) - nn2)/cpd0 + CEIL(MAX(df10,/NAN))
c_labels = (mylevels EQ FLOOR(mylevels))
v2       = SQRT(vx^2+vy^2)
v02      = SQRT(dat.VX0^2 + dat.VY0^2)
mymn     = MIN(v02,/nan)/1.1
mymx     = MAX(v02,/nan)*1.1
IF (mymn LT 0.0) THEN BEGIN
  mymn = 0.0
ENDIF ELSE BEGIN
  mymn = mymn
ENDELSE

bad = WHERE(v2 LT mymn OR v2 GT mymx,bc)
IF (bc NE 0) THEN df10[bad] = !VALUES.F_NAN
range = minmax_range(dfdata,/POS)   ; get min positive values
;*****************************************************************************************
;print,range
;   4.5839236e-27   4.3582718e-10
;*****************************************************************************************
dfdata = ALOG(dfdata)/ ALOG(10.) 
range  = ALOG(range)/ ALOG(10.)
;*****************************************************************************************
;print,range
; -26.338762      -9.3606856
;*****************************************************************************************
IF N_ELEMENTS(cpd) EQ 0 THEN BEGIN
   cpd = FIX(ngrid/(range[1] - range[0])) > 1
ENDIF
nlevels = FIX((range[1] - range[0] + 1)*cpd)
nlevels = (nlevels > 2) < 30
levels  = REVERSE((FIX(FLOOR(range[1]*cpd)) - FINDGEN(nlevels))/cpd)
;*****************************************************************************************
;print,nlevels,cpd
;       1 contours per decade
;      17       1
;*****************************************************************************************
c_colors = BYTSCL(FINDGEN(nlevels))
str_element,contstuff,'LEVELS',levels,/ADD_REPLACE
str_element,contstuff,'C_COLORS',c_colors,/ADD_REPLACE
str_element,contstuff,'ZRANGE',range,/ADD_REPLACE
IF KEYWORD_SET(vlim) THEN BEGIN
  str_element,contstuff,'XRANGE',[-vlim,vlim],/ADD_REPLACE
  str_element,contstuff,'YRANGE',[-vlim,vlim],/ADD_REPLACE
  str_element,contstuff,'XSTYLE',1,/ADD_REPLACE
  str_element,contstuff,'YSTYLE',1,/ADD_REPLACE
ENDIF
; over write with user choices passed in by the option structure:
extract_tags,contstuff,opt,/CONTOUR
;*****************************************************************************************
;help,contstuff,/st
;
;** Structure <f18030>, 9 tags, length=148, data length=141, refs=1:
;   TITLE           STRING    'Wind 3D Plasma  Eesa Low!C1997-10-10/15:11:16 - 15:11:1'...
;   XTITLE          STRING    'V parallel  (km/sec)'
;   YTITLE          STRING    'V perpendicular  (km/sec)'
;   LEVELS          FLOAT     Array[17]
;   C_COLORS        BYTE      Array[17]
;   XRANGE          FLOAT     Array[2]
;   XSTYLE          INT              1
;   YRANGE          FLOAT     Array[2]
;   YSTYLE          INT              1
;*****************************************************************************************
x_size  = !D.X_SIZE & y_size = !D.Y_SIZE
xsize   = .77
yoffset = 0.
d       = 1.
IF (y_size LE x_size) THEN BEGIN
  position = [.10*d+.05,.13*d+yoffset,.05+.13*d + xsize * y_size/x_size, $
              .10*d + xsize + yoffset] 
ENDIF ELSE BEGIN
  position = [.10*d+.05,.13*d+yoffset,.05+.13*d + xsize, $
              .10*d + xsize *x_size/y_size + yoffset]
ENDELSE
mypos3 = [0.22941,0.515,0.77059,0.915]
mypos2 = [0.22941,0.05,0.77059,0.45]  ; -position of second plot
mypos  = [0.12941,0.15,0.77059,0.791180]

cnnl = N_ELEMENTS(contstuff.LEVELS)
CONTOUR, dfdata, dat3d.VPAR2D, dat3d.VPERP2D,_EXTRA=contstuff,$
          XSTYLE=1,YSTYLE=1,NLEVELS=nlevels,$
          POSITION=mypos
OPLOT,dat.VX0,dat.VY0,PSYM=3,COLOR=cc1.CYAN

vdpar  = -dat3d.VSW2D[2]
vdperp = -dat3d.VSW2D[0]
;*****************************************************************************************
;  Draw a line to mark the SW velocity direction
;*****************************************************************************************
OPLOT,[0.0,100*vdpar],[0.0,100*vdperp],LINESTYLE=0
OPLOT,[0.0],[0.0],PSYM=1

maximum = MAX(dfdata,/NAN)
minimum = MIN(dfdata(WHERE(dfdata NE 0.)),/NAN)

thetitle = 'Log '+dat3d.UNITS_NAME+' (s!U3!N km!U-3!N cm!U-3!N)'
draw_color_scale,RANGE=[minimum,maximum],YTICKS=10,TITLE=thetitle

dfpara = distfunc(vout,0.,PARAM=dat)    ;  vparallel cut
dfperp = distfunc(0.,vout,PARAM=dat)    ;  vperp cut (blue line)

dflim = {NOERASE:1,YLOG:1,XSTYLE:1,TITLE:'',YTITLE:'df (sec!u3!n/km!u3!n/cm!u3!n)', $
         XTITLE:'Velocity (km/s)'}

lim1 = {XRANGE:[-vlim,vlim],XSTYLE:1,XLOG:0,XTITLE:'V parallel (km/s)',      $
        YRANGE:[-vlim,vlim],YSTYLE:1,YLOG:0,YTITLE:'V perpendicular (km/s)', $
        TITLE:title,top:1}

extract_tags,lim1,lim
lim1.YRANGE = lim1.XRANGE
lim1.XLOG   = 0
lim1.YLOG   = 0
extract_tags,dflim,lim
extract_tags,plotstuff,dflim,/PLOT
plotstuff.TITLE = ''
;*****************************************************************************************
;plot,vout,dfpara,_extra=plotstuff  ; makes the black line for //-cut
;oplot,vout,dfperp,color=cc1.blue,lines=2
;*****************************************************************************
;contour,df10,vout,vout,/isotropic,nlevels=7,c_labels=c_labels,c_color=color
;*****************************************************************************
;contour, dfdata, dat3d.vpar2d, dat3d.vperp2d,/overplot,nlevels=cnnl
;*****************************************************************************
;if keyword_set(dpoints) then  $
;    oplot,dat3d.vpar_dat,dat3d.vperp_dat,psym=3
;*****************************************************************************
;oplot,[-2.*plim,2.*plim],[0,0],linestyle=1
;oplot,[0,0],[-2.*plim,2.*plim],linestyle=1
;		oplot,[1000,1000],[-2.*plim,2.*plim],linestyle=1
;		oplot,[-1000,-1000],[-2.*plim,2.*plim],linestyle=1
;		oplot,[-2.*plim,2.*plim],[1000,1000],linestyle=1
;		oplot,[-2.*plim,2.*plim],[-1000,-1000],linestyle=1
;*****************************************************************************************
IF KEYWORD_SET(ncircles) THEN BEGIN
   IF NOT KEYWORD_SET(vlim) then vlim = MAX(!X.CRANGE,/NAN)
   circles = (FINDGEN(ncircles) + 1)*vlim/ncircles
ENDIF
IF KEYWORD_SET(circles) THEN BEGIN
   angles = FINDGEN(181)*!DPI/9d1
   FOR c = 0, N_ELEMENTS(circles) - 1 DO BEGIN
      r = circles[c]
      OPLOT,r*COS(angles),r*SIN(angles),LINESTYLE=2,COLOR=250,THICK=1.05
   ENDFOR
ENDIF
RETURN
END
