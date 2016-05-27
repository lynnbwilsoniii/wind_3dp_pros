;+
;*****************************************************************************************
;
;  FUNCTION :   no_label2.pro
;  PURPOSE  :   This function used to stop labeling of tick marks for plotting over a
;                 previous plot.
;
;*****************************************************************************************
;-

FUNCTION no_label2, axis, index, t

RETURN, " "
END


;+
;*****************************************************************************************
;
;  FUNCTION :   vector_3d_plot.pro
;  PURPOSE  :   This routine plots the 3D vector ray from an input of {x,y,z} components.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               plot_struct_format_test.pro
;               struct_new_el_add.pro
;               no_label2.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               [X,Y,Z]0   :  N-Element array of [X,Y,Z]-Component data for the
;                               vector {X,Y,Z}
;
;  EXAMPLES:    
;               kvec0       = [-0.37503, 0.18313, 0.90874]
;               min_vec0    = [-0.29717, 0.49649, 0.81559]
;               mid_vec0    = [ 0.95034, 0.23649,-0.20231]
;               max_vec0    = [ 0.09244,-0.83520, 0.54212]
;               xvec        = [kvec0[0],min_vec0[0],mid_vec0[0],max_vec0[0]] 
;               yvec        = [kvec0[1],min_vec0[1],mid_vec0[1],max_vec0[1]]
;               zvec        = [kvec0[2],min_vec0[2],mid_vec0[2],max_vec0[2]]
;               vecname     = ['k-Vector','MinVar','MidVar','MaxVar']
;               limit       = {TITLE:'MVA in GSE',XTITLE:'X-GSE',YTITLE:'Y-GSE',ZTITLE:'Z-GSE'}
;               vector_3d_plot,xvec,yvec,zvec,LIMIT=limit,VECNAME=vecname,CHANGECOL=45
;
;  KEYWORDS:    
;               LIMIT      :  IDL limit structure used with PLOT.PRO keyword _EXTRA
;                               [see IDL documentation for more details]
;               VECNAME    :  Scalar string defining the vector name(s)
;                               [Default = 'VEC-j', where j=0,1,...,N-1]
;               CHANGECOL  :  If set, program will change the color table to a new one
;                               [Scalar value ]
;               NO_PROJ    :  If set, program will not plot the XY-projections of the
;                               vectors
;               AXESROT    :  2-Element array of rotation angles [degrees] about the
;                               X-Axis and then the Z-Axis
;                               [e.g. axesrot=[20.,-120.]]
;
;   CHANGED:  1)  Added keyword:  NO_PROJ and fixed a typo in plotting routine
;                   so the program now plots normalized vectors     [03/10/2011   v1.1.0]
;             2)  Moved color table location search to inside IF statement in case
;                   user does not want program to waste time searching for a file
;                   they may not have                               [03/11/2011   v1.1.1]
;             3)  Program now calls struct_new_el_add.pro and no longer has one set
;                   of rotation angles, rather a set that depend on the input vector
;                   projections relative to each plane              [04/26/2011   v1.2.0]
;
;   NOTES:      
;               
;
;   CREATED:  03/09/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/26/2011   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO vector_3d_plot,x0,y0,z0,LIMIT=limit,VECNAME=vecname,CHANGECOL=changecol,$
                   NO_PROJ=no_proj,AXESROT=axesrot

;-----------------------------------------------------------------------------------------
;  ----DEFINE SOME USABLE COLORS----
;-----------------------------------------------------------------------------------------
; => Load current colors [*_orig] so they can be reset after done with routine
COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
r_orig0 = r_orig
g_orig0 = g_orig
b_orig0 = b_orig
IF KEYWORD_SET(changecol) THEN BEGIN
  mdir    = FILE_EXPAND_PATH('')
  file    = 'colors1.tbl'
  path    = FILEPATH(file[0],ROOT_DIR=mdir[0],SUBDIRECTORY='wind_3dp_pros')
  cfile   = FILE_SEARCH(path)
  IF (cfile[0] EQ '') THEN LOADCT ELSE LOADCT,changecol[0],FILE=cfile[0],/SILENT
ENDIF
;-----------------------------------------------------------------------------------------
; => Define dummy variables and check input
;-----------------------------------------------------------------------------------------
dummy = {TITLE:'XYZ-Vector Plots',XTITLE:'X-Dir',YTITLE:'Y-Dir',ZTITLE:'Z-Dir'}
; => Check user defined input structure to see if valid
IF NOT KEYWORD_SET(limit) THEN BEGIN
  lims = dummy
ENDIF ELSE BEGIN
  IF (SIZE(limit,/TYPE) NE 8) THEN lims = dummy ELSE lims = limit
  temp = plot_struct_format_test(lims,/SURFACE,/REMOVE_BAD)
  IF (SIZE(temp,/TYPE) NE 8) THEN BEGIN
    lims = dummy
  ENDIF ELSE lims = temp
ENDELSE
; => Check tags of LIMS
stna = STRLOWCASE(TAG_NAMES(lims))
ggst = WHERE(stna EQ 'title',gst)
IF (gst EQ 0) THEN struct_new_el_add,'TITLE',' ',lims,lims0 ELSE lims0 = lims
lims = lims0
;-----------------------------------------------------------------------------------------
; => Check input to make sure # of elements match up
;-----------------------------------------------------------------------------------------
xx   = REFORM(x0)
yy   = REFORM(y0)
zz   = REFORM(z0)
nx   = N_ELEMENTS(xx)             ; => # of input x-components
ny   = N_ELEMENTS(yy)             ; => # of input y-components
nz   = N_ELEMENTS(zz)             ; => # of input z-components
test = (nx NE ny) OR (nx NE nz) OR (ny NE nz)
IF (test) THEN BEGIN
  errmssg = 'Each input component must have the same number of data points...'
  MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF ELSE np = nx
; => Define a color for each vector [1st is red, last is purple {for color table 39}] 
cols    = REVERSE(LINDGEN(np)*(250L - 30L)/(np - 1L) + 30L)
; => Define default vector labels
deflabs = STRARR(np)
FOR j=0L, np - 1L DO deflabs[j] = 'VEC-'+STRTRIM(j,2)

IF NOT KEYWORD_SET(vecname) THEN BEGIN
  veclabs = deflabs
ENDIF ELSE BEGIN
  veclabs = REFORM(vecname)
  IF (N_ELEMENTS(veclabs) NE np) THEN veclabs = deflabs
ENDELSE
;-----------------------------------------------------------------------------------------
;  ----SET UP THE PLOT WINDOW----
;-----------------------------------------------------------------------------------------
xyzp_win    = {X:!X,Y:!Y,Z:!Z,P:!P}

charsize0   = !P.CHARSIZE
region0     = !P.REGION
margs       = [1,1]
IF (STRLOWCASE(!D.NAME) EQ 'x') THEN BEGIN
  WINDOW,8,TITLE=vcname,XSIZE=1000L,YSIZE=1000L,YPOS=100L,XPOS=100L,RETAIN=2
  chsz        = 3.0   ; => CHARSIZE
  thick0      = 2.0
  !X.MARGIN   = margs
  !Y.MARGIN   = margs
  !Z.MARGIN   = margs
ENDIF ELSE BEGIN
  chsz        = 2.5   ; => CHARSIZE
  thick0      = 3.5
  !X.MARGIN   = margs
  !Y.MARGIN   = margs
  !Z.MARGIN   = [0,0]
ENDELSE
!P.MULTI    = 0
!P.REGION   = [0.,0.,1.,1.]

omargs      = [0,0]
!X.OMARGIN  = omargs
!Y.OMARGIN  = omargs
!Z.OMARGIN  = omargs

;-----------------------------------------------------------------------------------------
; => Normalize data
;-----------------------------------------------------------------------------------------
magn  = SQRT(xx^2 + yy^2 + zz^2)
xxn   = xx/magn
yyn   = yy/magn
zzn   = zz/magn
;-----------------------------------------------------------------------------------------
; => Determine if vectors are nearly coplanar
;-----------------------------------------------------------------------------------------
xsum   = TOTAL(ABS(xxn),/NAN)
ysum   = TOTAL(ABS(yyn),/NAN)
zsum   = TOTAL(ABS(zzn),/NAN)
asums  = [xsum,ysum,zsum]
asums  = asums/NORM(asums)
sp     = REVERSE(SORT(asums))
; => Find the magnitude of the projection of the two largest components and test if
;      value > 65%
tplane = SQRT(asums[sp[0]]^2 + asums[sp[1]]^2) GT 0.65
testxy = ((sp[0] EQ 0) OR (sp[0] EQ 1)) AND ((sp[1] EQ 0) OR (sp[1] EQ 1))
testxz = ((sp[0] EQ 0) OR (sp[0] EQ 2)) AND ((sp[1] EQ 0) OR (sp[1] EQ 2))
testyz = ((sp[0] EQ 1) OR (sp[0] EQ 2)) AND ((sp[1] EQ 1) OR (sp[1] EQ 2))
test   = WHERE([testxy, testxz, testyz],tt)
; => Determine rotations for 3D axes
CASE test[0] OF
  0 : BEGIN
    ; => Vector mostly in XY-Plane
    axr =  15d0   ; => rotation [deg] about graphed X-axis
    azr = -11d1   ; => " " Z-axis
  END
  1 : BEGIN
    ; => Vector mostly in XZ-Plane
    axr =  20d0   ; => rotation [deg] about graphed X-axis
    azr = -12d1   ; => " " Z-axis
  END
  2 : BEGIN
    ; => Vector mostly in YZ-Plane
    axr =  20d0   ; => rotation [deg] about graphed X-axis
    azr = -14d1   ; => " " Z-axis
  END
ENDCASE
; => make sure user hasn't specified rotation angles to override defaults
IF KEYWORD_SET(axesrot) THEN BEGIN
  IF (N_ELEMENTS(axesrot) EQ 2) THEN BEGIN
    axr = axesrot[0]
    azr = axesrot[1]
  ENDIF ELSE BEGIN
    errmssg = 'Incorrect keyword usage [AXESROT]:  Must be 2-Element array!'
    MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
    PRINT,''
    PRINT,'Using default values...'
  ENDELSE
ENDIF
; => Define plot axis ranges
axra  = [-1d0,1d0]
;-----------------------------------------------------------------------------------------
; => Establish 3D coordinate mapping
;-----------------------------------------------------------------------------------------
po_00   = [0.00000001d0,0.99999999d0]
;SCALE3, XRANGE=po_00,YRANGE=po_00,ZRANGE=po_00,AX=30.,AZ=-120.
;SCALE3, XRANGE=axra,YRANGE=axra,ZRANGE=axra,AX=30.,AZ=-120.
SCALE3, XRANGE=axra,YRANGE=axra,ZRANGE=axra,AX=axr[0],AZ=azr[0]
; => Rescale area to unit cube
SCALE3D
;-----------------------------------------------------------------------------------------
; => Determine plot position
;-----------------------------------------------------------------------------------------
dposxyz = CONVERT_COORD(po_00,po_00,po_00,/NORMAL,/TO_DATA,/T3D)
nposxyz = CONVERT_COORD(axra,axra,axra,/DATA,/TO_NORMAL,/T3D)

t3xr    = REFORM(dposxyz[0,*])
t3yr    = REFORM(dposxyz[1,*])
t3zr    = REFORM(dposxyz[2,*])
; => Define plot position in normalized coordinates
;     Format = [(X_0,Y_0),(X_1,Y_1),(Z_0,Z_1)]
nposi   = [po_00[0],po_00[0],po_00[1],po_00[1],po_00]  
dposi   = [t3xr[0],t3yr[0],t3xr[1],t3yr[1],t3zr]
;-----------------------------------------------------------------------------------------
; => Set up plot limits
;-----------------------------------------------------------------------------------------
lim0  = {XRANGE:t3xr,YRANGE:t3yr,ZRANGE:t3zr,XSTYLE:5,YSTYLE:5,ZSTYLE:5,    $
         T3D:1,NODATA:1,POSITION:dposi,DATA:1,CHARSIZE:chsz,   $
         XMARGIN:margs,YMARGIN:margs,ZMARGIN:margs}

limx  = {XRANGE:axra,T3D:1,CHARSIZE:chsz,XAXIS:1,XSTYLE:1,DATA:1,XMARGIN:margs}
limx2 = {XAXIS:0,T3D:1,DATA:1,XSTYLE:1,CHARSIZE:chsz}
limy  = {YRANGE:axra,T3D:1,CHARSIZE:chsz,YAXIS:1,YSTYLE:1,DATA:1,YMARGIN:margs}
limy2 = {YAXIS:0,T3D:1,DATA:1,YSTYLE:1,CHARSIZE:chsz}
limz  = {ZRANGE:axra,T3D:1,CHARSIZE:chsz,ZAXIS:1,ZSTYLE:1,DATA:1,ZMARGIN:margs}
limz2 = {ZAXIS:0,T3D:1,DATA:1,ZSTYLE:1,CHARSIZE:chsz}
;-----------------------------------------------------------------------------------------
; => Create a set of blank 3D axes
;-----------------------------------------------------------------------------------------
SURFACE,FINDGEN(2,2),_EXTRA=lim0

; => Set up axes
; => X-Axis
AXIS,-1d0,0d0,0d0,_EXTRA=limx ,XTICKFORMAT='no_label2',XTICKLEN=0.5
AXIS,-1d0,0d0,0d0,_EXTRA=limx2,XTICKFORMAT='no_label2',XTICKLEN=0.5
; => Y-Axis
AXIS,0d0,-1d0,0d0,_EXTRA=limy ,YTICKFORMAT='no_label2',YTICKLEN=0.5
AXIS,0d0,-1d0,0d0,_EXTRA=limY2,YTICKFORMAT='no_label2',YTICKLEN=0.5
; => Z-Axis
AXIS,0d0,0d0,-1d0,_EXTRA=limz ,ZTICKFORMAT='no_label2'
AXIS,0d0,0d0,-1d0,_EXTRA=limz2,ZTICKFORMAT='no_label2'
;-----------------------------------------------------------------------------------------
; => Plot the vectors
;-----------------------------------------------------------------------------------------
lim_st  = {T3D:1,LINESTYLE:1,DATA:1}
lim_ray = {LINESTYLE:0,T3D:1,THICK:thick0,DATA:1}
lim_pro = {LINESTYLE:2,T3D:1,THICK:thick0,DATA:1}
lim_vec = {DATA:1,T3D:1,CHARSIZE:chsz,ALIGNMENT:0.5,TEXT_AXES:2}

FOR j=0L, np - 1L DO BEGIN
  IF (zz[j] LT 0.) THEN zend = zzn[j] - 0.15 ELSE zend = zzn[j] + 0.1
  xend   = xxn[j]*1.05
  yend   = yyn[j]*1.05
  ; => Define data from start to end
  xdat   = [0d0,xxn[j]]
  ydat   = [0d0,yyn[j]]
  zdat   = [0d0,zzn[j]]
  ; => Plot vector from [0,0,0] to [x,y,z]
  PLOTS,xdat,ydat,zdat,_EXTRA=lim_ray,COLOR=cols[j]
  IF NOT KEYWORD_SET(no_proj) THEN BEGIN
    ; => Plot XY-Projections too
    PLOTS,xdat,ydat,[0d0,0d0],_EXTRA=lim_pro,COLOR=cols[j]
    PLOTS,[xxn[j],xxn[j]],[yyn[j],yyn[j]],[0d0,zzn[j]],_EXTRA=lim_pro,COLOR=cols[j]
  ENDIF
  ; => Label each vector
  XYOUTS,xend,yend,Z=zend,veclabs[j],_EXTRA=lim_vec,COLOR=cols[j]
ENDFOR

; => Output Axes and Plot Titles
lim_xyo = {DATA:1,T3D:1,CHARSIZE:chsz,ALIGNMENT:0.5}
XYOUTS,1.2,0.0,Z=0.0,lims.XTITLE,_EXTRA=lim_xyo,TEXT_AXES=2
XYOUTS,0.0,1.2,Z=0.0,lims.YTITLE,_EXTRA=lim_xyo,TEXT_AXES=2
XYOUTS,0.0,0.0,Z=1.2,lims.ZTITLE,_EXTRA=lim_xyo,TEXT_AXES=2
; => Output a pseudo plot label/title
IF (STRLEN(lims.TITLE) GT 10) THEN BEGIN
  chsz2 = chsz*2d0/3d0
  xpos2 = 0.25
ENDIF ELSE BEGIN
  chsz2 = chsz
  xpos2 = 0.35
ENDELSE

XYOUTS,xpos2[0],0.9,lims.TITLE,/NORMAL,CHARSIZE=chsz2
;-----------------------------------------------------------------------------------------
; => Return plot window to original state
;-----------------------------------------------------------------------------------------
!X   = xyzp_win.X
!Y   = xyzp_win.Y
!Z   = xyzp_win.Z
!P   = xyzp_win.P
; => Reset color table if changed
IF KEYWORD_SET(changecol) THEN BEGIN
  TVLCT,r_orig0,g_orig0,b_orig0
ENDIF

RETURN
END

