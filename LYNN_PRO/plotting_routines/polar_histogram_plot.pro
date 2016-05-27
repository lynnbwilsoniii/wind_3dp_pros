;+
;*****************************************************************************************
;
;  FUNCTION :   polar_histogram_plot.pro
;  PURPOSE  :   Creates a polar histogram plot from radial and azimuthal inputs.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               polar_histogram_bins.pro
;               bytescale.pro
;               draw_color_scale.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               RAD     :  An N-Element array of radii to be used for the histogram
;               THETA   :  " " of angles (deg)
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               XTTL     :  Set to a string defining the desired X-Axis Title
;               YTTL     :  Set to a string defining the desired Y-Axis Title
;               ZTTL     :  Set to a string defining the desired Z-Axis Title
;               TTLE     :  Set to a string defining the desired plot title
;               XRANGE   :  A 2-Element array used to define the x-range
;               YRANGE   :  A 2-Element array used to define the y-range
;               ZRANGE   :  A 2-Element array used to define the z-range
;               NBIN_R   :  A scalar used to define the number of bins in the radial
;                             direction [Default = 8]
;               NBIN_T   :  A scalar used to define the number of bins in the azimuthal
;                             direction [Default = 8]
;               NODATC   :  A scalar defining the color to use where no data is present
;                             [Default = 255B (white)]
;               BDDATC   :  A scalar defining the color to use where bad data is present
;                             [Default = 0B (black)]
;               LABELS   :  If set, program outputs histogram heights onto polar plot
;                             [Use if quantitative analysis is necessary...]
;               DATA     :  N-Element array of data at the polar coordinates of
;                             RAD and THETA
;               THETA_R  :  If set, program uses input thetas to determine the range
;                             of angles to consider
;                             [Default = 0 to 360 degrees]
;               POLAR    :  If set, XRANGE is assumed to be the range for radial 
;                             distance and YRANGE is assumed to be the range for
;                             the polar angles
;
;   CHANGED:  1)  Added keyword:  LABELS                            [05/18/2010   v1.1.0]
;             2)  Added keywords:  DATA, THETA_R, and POLAR         [05/23/2010   v1.2.0]
;
;   NOTES:      
;               
;
;   CREATED:  05/03/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/23/2010   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO polar_histogram_plot,rad,theta,XTTL=xttl,YTTL=yttl,ZTTL=zttl,TTLE=ttle, $
                         XRANGE=xra,YRANGE=yra,ZRANGE=zra,                  $
                         NBIN_R=nbin_r,NBIN_T=nbin_t,NODATC=ndatc,          $
                         BDDATC=bdatc,LABELS=labels,DATA=data,              $
                         THETA_R=theta_r,POLAR=polar

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN

IF KEYWORD_SET(nbin_r) THEN nb_r = nbin_r ELSE nb_r = 8L
IF KEYWORD_SET(nbin_t) THEN nb_t = nbin_t ELSE nb_t = 8L
IF KEYWORD_SET(ndatc)  THEN nd_c = ndatc  ELSE nd_c = 255b
IF KEYWORD_SET(bdatc)  THEN bd_c = bdatc  ELSE bd_c = 0b

IF NOT KEYWORD_SET(xttl) THEN xttl = ''
IF NOT KEYWORD_SET(yttl) THEN yttl = ''
IF NOT KEYWORD_SET(zttl) THEN zttl = ''
IF NOT KEYWORD_SET(ttle) THEN ttle = ''
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
r1     = REFORM(rad)
t1     = REFORM(theta)

gd     = 100
radius = REPLICATE(1d0,gd)                     ; => Dummy radius for circles
thetas = (DINDGEN(gd)*36d1/(gd - 1))*!DPI/18d1 ; => Dummy angles for circles
;-----------------------------------------------------------------------------------------
; => Determine bin boundaries
;-----------------------------------------------------------------------------------------
bins   = polar_histogram_bins(r1,t1,NBIN_R=nb_r,NBIN_T=nb_t,XRANGE=xra ,$
                              YRANGE=yra ,DATA=data,THETA_R=theta_r,    $
                              POLAR=polar)

num_bn = bins.COUNTS
xpt_A  = bins.XPT_A
xpt_B  = bins.XPT_B
xpt_C  = bins.XPT_C
xpt_D  = bins.XPT_D
ypt_A  = bins.YPT_A
ypt_B  = bins.YPT_B
ypt_C  = bins.YPT_C
ypt_D  = bins.YPT_D
;-----------------------------------------------------------------------------------------
; => Format bin values
;-----------------------------------------------------------------------------------------
zrange = [0d0,0d0]
IF KEYWORD_SET(zra) THEN BEGIN
  zrange = zra
ENDIF ELSE BEGIN
  zrange = minmax(num_bn,MAX=mx,MIN=mn)
ENDELSE
IF (zrange[0] EQ 0.) THEN zrange[0] = 1.
vals   = bytescale(num_bn,BOTTOM=bottom,TOP=top,RANGE=zrange)
; => Set bins without data to specified color [Default = white]
bad    = WHERE(num_bn EQ 0.,bd)
IF (bd GT 0) THEN BEGIN
  bind   = ARRAY_INDICES(num_bn,bad)
  vals[bind[0,*],bind[1,*]] = nd_c[0]
ENDIF
; => Set bins with bad data to specified color [Default = black]
; => Changed to white [05/23/2010   v1.2.0]
bad    = WHERE(FINITE(num_bn) EQ 0,bd)
IF (bd GT 0) THEN BEGIN
  bind   = ARRAY_INDICES(num_bn,bad)
  IF (STRLOWCASE(!D.NAME) NE 'x') THEN BEGIN
    vals[bind[0,*],bind[1,*]] = nd_c[0]
  ENDIF ELSE BEGIN
    vals[bind[0,*],bind[1,*]] = bd_c[0]
  ENDELSE
ENDIF
;-----------------------------------------------------------------------------------------
; => Define plot structure
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(xra) OR KEYWORD_SET(yra) THEN BEGIN
  IF KEYWORD_SET(xra) THEN xran = xra ELSE xran = yra
  IF KEYWORD_SET(yra) THEN yran = yra ELSE yran = xra
ENDIF ELSE BEGIN
  xran  = [-1e0*MAX(r1,/NAN),MAX(r1,/NAN)]
  ; => Force Aspect ratio to 1.0
  yran  = xran
ENDELSE

IF KEYWORD_SET(polar) THEN BEGIN
  ; => X-Range is assumed to be the range for the radial distances
  xran  = [-1e0*MAX(xran,/NAN),MAX(xran,/NAN)]
  ; => Force Aspect ratio to 1.0
  yran  = xran
ENDIF
mxra   = MAX([xran,yran],/NAN)

rstr  = STRTRIM(nb_r,2)
tstr  = STRTRIM(nb_t,2)
xttl  = xttl[0]+'!C'+'Number of R!Dbins!N = '+rstr[0]+', Number of Angle Bins = '+tstr[0]
yttl  = yttl[0]+'!C'+'White Bins = No Data'
pstr  = {POLAR:1,NODATA:1,XSTYLE:1,YSTYLE:1,XRANGE:xran,YRANGE:yran,XMINOR:5,YMINOR:5,$
         XTICKLEN:0.04,YTICKLEN:0.04,YMARGIN:[4.,2.],XMARGIN:[12.,15.],  $
         TITLE:ttle,XTITLE:xttl,YTITLE:yttl}

; => Set up plot area
PLOT,r1,t1*!DPI/18d1,_EXTRA=pstr
; => Plot polar histogram
FOR i=0L, nb_r - 1L DO BEGIN
  FOR j=0L, nb_t - 1L DO BEGIN
    cc    = vals[i,j]
    xlocs = [REFORM(xpt_A[i,j]),REFORM(xpt_B[i,j]),REFORM(xpt_C[i,j]),REFORM(xpt_D[i,j])]
    ylocs = [REFORM(ypt_A[i,j]),REFORM(ypt_B[i,j]),REFORM(ypt_C[i,j]),REFORM(ypt_D[i,j])]
    POLYFILL,xlocs,ylocs,COLOR=cc
  ENDFOR
ENDFOR

; => Plot labels on polar histogram if desired
cc = 0
IF KEYWORD_SET(labels) THEN BEGIN
  FOR i=0L, nb_r - 1L DO BEGIN
    FOR j=0L, nb_t - 1L DO BEGIN
      xlocs = [REFORM(xpt_A[i,j]),REFORM(xpt_B[i,j]),REFORM(xpt_C[i,j]),REFORM(xpt_D[i,j])]
      ylocs = [REFORM(ypt_A[i,j]),REFORM(ypt_B[i,j]),REFORM(ypt_C[i,j]),REFORM(ypt_D[i,j])]
;    IF KEYWORD_SET(labels) THEN BEGIN
      xminpos = MIN(xlocs,/NAN,lnx)
      yminpos = MIN(ylocs,/NAN,lny)
      ymaxpos = MAX(ylocs,/NAN,lxy)
      g_levn  = WHERE(ABS(ylocs)*1d3 LE 1d0,g_lvn,COMPLEMENT=b_levn,NCOMPLEMENT=b_lvn)
;      g_levx  = WHERE(ymaxpos EQ ylocs,g_lvx,COMPLEMENT=b_levx,NCOMPLEMENT=b_lvx)
      IF (g_lvn GT 1) THEN BEGIN
        ; => Attempt to avoid overlapping labels where flat sides of polygons have two
        ;      y-values that match
        xposi_0 = xlocs[lnx] + 0.05*ABS(xlocs[lnx])
      ENDIF ELSE BEGIN
        xposi_0 = xlocs[lnx] + 0.05*ABS(xlocs[lnx])
      ENDELSE
      xposi_0 = (MAX(xlocs,/NAN) + MIN(xlocs,/NAN))/2e0
      yposi_0 = (MAX(ylocs,/NAN) + MIN(ylocs,/NAN))/2e0
      num_str = 'N = '+STRTRIM(STRING(FORMAT='(f15.1)',num_bn[i,j]),2)
      XYOUTS,xposi_0[0],yposi_0[0],num_str[0],CHARSIZE=0.5,/DATA
      cc     += 1
;    ENDIF
    ENDFOR
  ENDFOR
  PRINT,STRTRIM(cc,2)+' bins were labeled'
ENDIF

str_element,pstr,'NOERASE',1,/ADD_REPLACE
PLOT,r1,t1*!DPI/18d1,_EXTRA=pstr
;-----------------------------------------------------------------------------------------
    ; => Plot lines at +/-45 deg and horizontal/vertical
    OPLOT,[-1e0*mxra,1e0*mxra],[-1e0*mxra,1e0*mxra]
    OPLOT,[-1e0*mxra,1e0*mxra],[1e0*mxra,-1e0*mxra]
    OPLOT,[-1e0*mxra,1e0*mxra],[0e0,0e0]
    OPLOT,[0e0,0e0],[1e0*mxra,-1e0*mxra]
    ; => Plot circles at 1/4, 1/2, 3/4 of max data range
    fac_0 = (1d0*mxra/4d0)
    fac_1 = (1d0*mxra/2d0)
    fac_2 = (3d0*mxra/4d0)
    fac_3 = (1d0*mxra)
    
    OPLOT,fac_0*radius,thetas,COLOR=50,/POLAR
    OPLOT,fac_1*radius,thetas,COLOR=50,/POLAR
    OPLOT,fac_2*radius,thetas,COLOR=50,/POLAR
    OPLOT,fac_3*radius,thetas,COLOR=50,/POLAR
    ; => If desired, plot radii labels
    dx_posi = [fac_0*COS(225d0*!DPI/18d1)-fac_3/1d1,fac_1*COS(225d0*!DPI/18d1)-fac_3/2d1,$
               fac_2*COS(225d0*!DPI/18d1)-fac_3/2d1,fac_3*COS(225d0*!DPI/18d1)-fac_3/2d1]
    dy_posi = [fac_0*SIN(225d0*!DPI/18d1)-fac_3/2d1,fac_1*SIN(225d0*!DPI/18d1),          $
               fac_2*SIN(225d0*!DPI/18d1),          fac_3*SIN(225d0*!DPI/18d1)]
    r_str   = ['R = 1/4 Total','R = 1/2 Total','R = 3/4 Total','R = 1 Total']
    
    XYOUTS,dx_posi[0],dy_posi[0],r_str[0],CHARSIZE=2.0,/DATA
    XYOUTS,dx_posi[1],dy_posi[1],r_str[1],CHARSIZE=2.0,/DATA
    XYOUTS,dx_posi[2],dy_posi[2],r_str[2],CHARSIZE=2.0,/DATA
    XYOUTS,dx_posi[3],dy_posi[3],r_str[3],CHARSIZE=2.0,/DATA
;-----------------------------------------------------------------------------------------
; => Draw in color scale
;-----------------------------------------------------------------------------------------
draw_color_scale,BRANGE=[bottom,top],RANGE=zrange,LOG=0,TITLE=zttl,      $
                 CHARSIZE=charsize,YTICKS=6,POSITION=zposition,          $
                 OFFSET=zoffset

RETURN
END