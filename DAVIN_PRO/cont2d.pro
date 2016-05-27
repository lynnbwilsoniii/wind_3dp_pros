;+
;*****************************************************************************************
;
;  FUNCTION :   cont2d.pro
;  PURPOSE  :   Produces a contour plot of the distribution function with parallel and 
;                 perpendicular cuts shown.  One can also, with appropriate keywords,
;                 output thermal velocities, temperatures, heat flux vectors, and 
;                 temperature anisotropies.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               read_gen_ascii.pro
;               time_string.pro
;               str_element.pro
;               minmax.pro
;               extract_tags.pro
;               add_df2dp_2.pro
;               distfunc.pro
;               get_colors.pro
;               dat_3dp_str_names.pro
;               trange_str.pro
;               cal_rot.pro
;               read_shocks_jck_database.pro
;               mom_sum.pro
;               mom_translate.pro
;               get_plot_state.pro
;               one_count_level.pro
;               moments_3d.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DFPAR    :  3D data structure retrieved from get_??(el,elb,eh,pl, etc.)
;
;  EXAMPLES:    
;               ;....................................................................
;               ; => Define a time of interest
;               ;....................................................................
;               to      = time_double('1996-04-03/09:47:00')
;               ;....................................................................
;               ; => Get a Wind 3DP EESA Low data structure from level zero files
;               ;....................................................................
;               dat     = get_el(to)
;               ;....................................................................
;               ; => in the following lines, the strings correspond to TPLOT handles
;               ;      and thus may be different for each user's preference
;               ;....................................................................
;               add_vsw2,dat,'V_sw2'          ; => Add solar wind velocity to struct.
;               add_magf2,dat,'wi_B3(GSE)'    ; => Add magnetic field to struct.
;               add_scpot,dat,'sc_pot_3'      ; => Add spacecraft potential to struct.
;               ;....................................................................
;               ; => Convert to solar wind frame [assuming VSW tag values or set]
;               ;....................................................................
;               del     = convert_vframe(dat,/INTERP)
;               ;....................................................................
;               ; => Calculate pitch-angle distribution (PAD)
;               ;....................................................................
;               num_pa  = 17L            ; => # of pitch-angle bins
;               pd      = pad(del,NUM_PA=num_pa[0])
;               ;....................................................................
;               ; => Calculate corresponding velocity distribution function (DF)
;               ;....................................................................
;               df      = distfunc(pd.ENERGY,pd.ANGLES,MASS=pd.MASS,DF=pd.DATA)
;               extract_tags,del,df      ; => Put DF structure tags in DEL structure
;               ;....................................................................
;               ; => Plot DF assuming gyrotropy with one-count cut and the
;               ;      heat flux and Vsw vectors projected onto contour and
;               ;      estimates of the thermal speed and temperature anisotropy
;               ;      output
;               ;....................................................................
;               ngrid   = 30L            ; => # of grids in contour
;               vlim    = 2d4            ; => velocity limit (km/s)
;               cont2d,tad,NGRID=ngrid,VLIM=vlim,/HEAT_F,/V_TH,/ANI_TEMP,MYONEC=dat
;
;  KEYWORDS:    
;               VLIM     :  Velocity limit for x-y axes over which to plot data [km/s]
;               NGRID    :  # of isotropic velocity grids to use to triangulate the data
;                             [Default = 30L]
;               REDF     :  Option to plot red line for reduced dist. funct. on cut plot
;               CPD      :  Set to a scalar to define contours per decade
;               LIM      :  Set to plot limit structure [i.e. _EXTRA=lim in PLOT.PRO etc.]
;               NOCOLOR  :  If set, contour plot is output in gray-scale
;               VOUT     :  Set to a named variable to be returned on output specifying
;                             the velocities used to calculate the DFs
;               FILL     :  If set, contours are filled in with colors
;               CCOLORS  :  Obselete?
;               PLOT1    :  Set to a named variable to return the plot state structure
;               MYONEC   :  Allows one to print the data point in 'df' units
;                             corresponding to one count (thus below this, data can
;                             not be trusted).  The input should be the data structure
;                             corresponding to the desired structure being plotted, BUT
;                             it should be the un-manipulated version (i.e. in the
;                             spacecraft frame).  cont2d.pro will use the routine
;                             one_count_level.pro and return the parallel cut of the
;                             1-Count Level for that distribution.
;               V_TH     :  If set, program calculates and outputs the thermal speed
;                             for the input distribution [km/s]
;               MYDIST   :  Structure with format of returned structure from 
;                             distfunc.pro
;               ANI_TEMP :  If set, program calculates and outputs the Temperature 
;                             anisotropy for the input distribution
;               HEAT_F   :  If set, program calculates and outputs the projection of
;                             the heat flux vector to be overplotted on the 2D contour
;                             DF plot
;               GNORM    :  Set to a 3-element unit vector corresponding to the shock
;                             normal vector in GSE coordinates
;               DFRA     :  2-Element array specifying a DF range (s^3/km^3/cm^3) for the
;                             cuts of the distribution function
;               VCIRC    :  Scalar or array defining the value(s) to plot as a
;                             circle(s) of constant speed [km/s] on the contour
;                             plot [e.g. gyrospeed of specularly reflected ion]
;               EX_VEC0  :  3-Element unit vector for another quantity like heat flux or
;                             a wave vector
;                             [Default = undefined]
;               EX_VN0   :  A string name associated with EX_VEC0
;                             [Default = 'Vec 1']
;
;  CHANGED:  1)  Changed vlim to a keyword                 [04/10/2007   v1.1.?]
;            2)  Added keywords: VLIM, MYONEC, V_TH
;            3)  Improved error handling to prevent code breaking or segmentation faults
;            4)  Added the projection of the Solar Wind velocity on contour plots
;            5)  Changed color scale/scheme  {best results when ngrid=24}
;            6)  Changed plot positions and labels
;            7)  No longer calls distfunc.pro, now calls my_distfunc.pro
;            8)  Forced aspect ratio=1 for PS files
;            9)  Plotting options and output were altered to make parallel and
;                  perpendicular cuts of the contours an automatic result
;           10)  Added keywords: MYDIST, ANI_TEMP, HEAT_F  [08/11/2008   v1.1.48]
;           11)  Changed one count calculation             [02/25/2009   v1.1.49]
;           12)  Updated man page                          [02/25/2009   v1.1.50]
;           13)  Changed color calculation                 [02/25/2009   v1.1.51]
;           14)  Changed one count to allow for structures [02/26/2009   v1.1.52]
;           15)  Made some minor alterations, no functionality effects though
;                                                          [03/20/2009   v1.1.53]
;           16)  Added program add_df2dp.pro back to pro   [03/20/2009   v1.1.54]
;           17)  Changed contour levels calculation        [03/20/2009   v1.1.55]
;           18)  Changed add_df2dp.pro to add_df2dp_2.pro  [03/22/2009   v1.1.56]
;           19)  Changed calling of field_rot.pro          [04/17/2009   v1.1.57]
;           20)  Changed Y-Axis labels for cut-plot        [05/15/2009   v1.1.58]
;           21)  Added keyword: GNORM                      [05/15/2009   v1.1.59]
;           22)  Added programs: my_all_shocks_read.pro, my_time_string.pro, and 
;                  rot_mat.pro                             [05/15/2009   v1.2.0]
;           23)  Changed usage of HEAT_F keyword           [05/20/2009   v1.2.1]
;           24)  Added program:  my_mom3d.pro              [05/20/2009   v1.2.1]
;           25)  Added programs :  my_mom_sum.pro and my_mom_translate.pro
;                  Removed program:  my_mom3d.pro          [05/20/2009   v1.2.2]
;           26)  Fixed minor syntax error when GNORM set   [06/17/2009   v1.2.3]
;           27)  Added color-coded output definitions for GNORM and HEAT_F keywords
;                                                          [06/17/2009   v1.2.4]
;           28)  Changed plot labels and colors            [07/30/2009   v1.2.5]
;           29)  Changed treatment of one count level      [07/30/2009   v1.3.0]
;           30)  Fixed plot label on DF cut plot           [07/31/2009   v1.3.1]
;           31)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                  and my_distfunc.pro to distfunc.pro
;                  and my_convert_vframe.pro to convert_vframe.pro
;                  and my_pad_dist.pro to pad.pro
;                                                          [08/05/2009   v2.0.0]
;           32)  Changed functionality of GNORM keyword slightly by allowing one to
;                  enter a 3-element vector to avoid calling my_all_shocks_read.pro
;                  multiple times                          [08/10/2009   v2.0.1]
;           33)  Changed functionality of MYONEC keyword:  Now enter the original
;                  particle structure after adding 'VSW', 'MAGF', and 'SC_POT'
;                  before transferring into any other reference frame
;                  [Now calls one_count_level.pro]         [08/10/2009   v2.1.0]
;           34)  Fixed syntax error in MYONEC calculation  [08/11/2009   v2.1.1]
;           35)  Changed some minor message outputs        [08/13/2009   v2.1.2]
;           36)  Changed programs:
;                  and my_all_shocks_read.pro to read_shocks_jck_database.pro
;                                                          [09/16/2009   v2.1.3]
;           37)  Altered comments regarding the use of MYONEC keyword
;                                                          [12/02/2009   v2.1.4]
;           38)  Altered comments and functionality regarding the keywords
;                  V_TH, ANI_TEMP, HEAT_F, and GNORM       [02/17/2010   v2.1.5]
;           39)  Fixed a typo with Y-Axis labels for the parallel/perpendicular cuts
;                                                          [02/21/2010   v2.2.0]
;           40)  Changed color of parallel cut output and added keyword:  DFRA
;                                                          [06/21/2010   v2.3.0]
;           41)  Changed contour levels calculation slightly to depend upon
;                  DFRA keyword                            [10/01/2010   v2.4.0]
;           42)  Removed dependence on field_rot.pro       [02/15/2011   v2.5.0]
;           43)  Now plots contour lines over the blue dots marking locations of
;                  actual data points                      [10/15/2011   v2.5.1]
;           44)  Changed contour levels calculation so that DFRA keyword controls
;                  the contours                            [11/28/2011   v2.5.2]
;           45)  Added keywords:  VCIRC, EX_VEC0, and EX_VN0 and cleaned up
;                                                          [02/01/2012   v2.6.0]
;           46)  Implemented a number of superficial changes that only affect how
;                  output is manipulated in Adobe Illustrator and updated man page
;                                                          [02/02/2012   v2.6.1]
;
;   NOTES:      
;               **[changed plotting so that the plots will be automatically square]**
;               1)  Make sure structures are formatted correctly prior to calling
;                     [see Eesa_contour-plot-commands.txt crib for examples]
;
;  ADAPTED FROM: cont2d.pro  BY:  Davin Larson
;  CREATED:  04/10/2007
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/02/2012   v2.6.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO cont2d,dfpar,VLIM=vlim,NGRID=n,REDF=redf,CPD=cpd,LIM=lim,NOCOLOR=nocolor,VOUT=vout, $
           FILL=fill,CCOLORS=ccolors,PLOT1=plot1,MYONEC=myonec,V_TH=v_th,MYDIST=mydist, $
           ANI_TEMP=ani_temp,HEAT_F=heat_f,GNORM=gnorm,DFRA=dfra,VCIRC=vcirc,           $
           EX_VEC0=ex_vec0,EX_VN0=ex_vn0

;-----------------------------------------------------------------------------------------
; => Check distribution to see if it's worth going any further
;-----------------------------------------------------------------------------------------
f       = !VALUES.F_NAN
dat3d   = dfpar
IF (dat3d.VALID EQ 0) THEN BEGIN
  MESSAGE,'There is no valid data for this 3D moment sample.',/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;########################################################################################
;; => Define version for output
;;########################################################################################
mdir           = FILE_EXPAND_PATH('wind_3dp_pros/DAVIN_PRO/')+'/'
file           = FILE_SEARCH(mdir,'cont2d.pro')
fstring        = read_gen_ascii(file[0])
test           = STRPOS(fstring,';    LAST MODIFIED:  ') GE 0
gposi          = WHERE(test,gpf)
shifts         = STRLEN(';    LAST MODIFIED:  ')
vers           = STRMID(fstring[gposi[0]],shifts[0])
vers1          = 'cont2d.pro : '+vers[0]+', output at: '
version        = vers1[0]+time_string(SYSTIME(1,/SECONDS),PREC=3)
;-----------------------------------------------------------------------------------------
; => Define some dummy and relevant parameters
;-----------------------------------------------------------------------------------------
!P.MULTI = 0
IF KEYWORD_SET(n) EQ 0 THEN n = 30
IF KEYWORD_SET(vlim) EQ 0 THEN vlim = 20000.
str_element,lim,'XRANGE',xrange
str_element,lim,'CPD',cpd
IF KEYWORD_SET(xrange) THEN vlim = MAX(xrange,/NAN)

temp_ra = minmax(dfpar.DATA,/POSITIVE)
IF KEYWORD_SET(mydist) THEN BEGIN  ; => if distribution function add but not part of dfpar
  dfpar2 = mydist
  extract_tags,dat3d,dfpar2
  add_df2dp_2,dat3d,VLIM=vlim,MINCNT=temp_ra[0]
ENDIF ELSE BEGIN
  dfpar2 = dfpar
  add_df2dp_2,dat3d,VLIM=vlim,MINCNT=temp_ra[0]
ENDELSE
;-----------------------------------------------------------------------------------------
; => Get rid of non-finite data
;-----------------------------------------------------------------------------------------
dfdata = dat3d.DF2D
;-----------------------------------------------------------------------------------------
;  => Recalculate distribution function for designated # of contours
;-----------------------------------------------------------------------------------------
vout     = (DINDGEN(2L*n + 1L)/n - 1L) * vlim
vx       = vout # REPLICATE(1.,2L*n + 1L)
vy       = REPLICATE(1.,2L*n + 1L) # vout

df       = distfunc(vx,vy,PARAM=dfpar2)
df_range = ALOG10(minmax(df))
;  => LBW 10/01/2010
;df_range = ALOG(minmax(df))/ALOG(10.)

gdfr = WHERE(FINITE(df_range) EQ 0,gdf)
IF (gdf GT 1) THEN BEGIN
  MESSAGE,'Infinite data range!',/INFORMATION,/CONTINUE
  RETURN
ENDIF
blow = WHERE(ABS(df_range) LT 1d-40 OR ABS(df_range) GT 1d40,blo)
IF (blo GT 0) THEN BEGIN
  MESSAGE,'Bad data range!',/INFORMATION,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Calculate # of levels and colors for contour
;-----------------------------------------------------------------------------------------
df10     = ALOG10(df)
;  => LBW 11/28/2011
IF KEYWORD_SET(dfra) THEN BEGIN
  dfra    = REFORM(dfra)
  dfra_p  = dfra[SORT(dfra)]
ENDIF ELSE BEGIN
  dfra_p  = 1e1^df_range
ENDELSE
; => Determine the contours per decade
IF KEYWORD_SET(cpd) THEN BEGIN
  cpd0 = cpd
ENDIF ELSE BEGIN
  cpd0 = FLOOR(n/(ALOG10(dfra_p[1]) - ALOG10(dfra_p[0]))) > 1.
;  => LBW 10/01/2010
ENDELSE 
; => Define initial range
range    = minmax(dfdata,/POSITIVE)   ; get min positive values
dfdata   = ALOG10(dfdata)
;  => LBW 10/01/2010
IF KEYWORD_SET(dfra) THEN range = ALOG10(dfra_p) ELSE range = ALOG10(range)
; => set labels of levels so that they are even powers of 10
nlevels  = CEIL((range[1] - range[0] + 1)*cpd0)
nlevels  = (nlevels > 2) < n
levels   = REVERSE((FIX(FLOOR(range[1]*cpd0)) - FINDGEN(nlevels))/cpd0)
;-----------------------------------------------------------------------------------------
; => Get color scales
;-----------------------------------------------------------------------------------------
cc1      = get_colors()
color    = LONARR(nlevels)
color    = LINDGEN(nlevels)*(250L - 10L)/(nlevels - 1L) + 10L
color    = ROUND((color*1e3)^(2e0/3e0)/16e0)
c_colors = BYTE(color)

c_labels = levels EQ FLOOR(levels)
v2  = SQRT(vx^2 + vy^2)
v02 = SQRT(dfpar2.VX0^2 + dfpar2.VY0^2)
mn  = MIN(v02,/NAN)/1.1
mn  = 0.
mx  = MAX(v02,/NAN)*1.1
bad = WHERE((v2 LT mn) OR (v2 GT mx),count)
IF (count NE 0) THEN df10[bad] = !VALUES.F_NAN
;-----------------------------------------------------------------------------------------
; => Define some plot structure variables
;-----------------------------------------------------------------------------------------
str_element,dfpar2,'TIME',VALUE=t
str_element,dfpar2,'END_TIME',VALUE=t2
strn  = dat_3dp_str_names(dfpar2)
title = ''  ; title of plot

!P.MULTI = [0,1,2]
ndec     = 4
title    = dat3d.PROJECT_NAME+'  '+dat3d.DATA_NAME
title   += '!C'+trange_str(dat3d.TIME,dat3d.END_TIME)
ytitle   = 'V perpendicular  (1000 km/sec)'
xtitle   = 'V parallel  (1000 km/sec)'
str_element,contstuff,'TITLE',title,/ADD_REPLACE
str_element,contstuff,'XTITLE',xtitle,/ADD_REPLACE
str_element,contstuff,'YTITLE',ytitle,/ADD_REPLACE
;-----------------------------------------------------------------------------------------
; => Define color scheme
;-----------------------------------------------------------------------------------------
col = FLOOR(levels) + 3
col = col - 6*FLOOR(col/6.) + 1
;-----------------------------------------------------------------------------------------
; => Define plot structure options
;-----------------------------------------------------------------------------------------
overplot= KEYWORD_SET(fill)
IF overplot THEN BEGIN
  str_element,contstuff,'FILL',1,/ADD_REPLACE
ENDIF ELSE BEGIN
  str_element,contstuff,'C_COLORS',c_colors,/ADD_REPLACE
ENDELSE

lim1 = {XRANGE:[-vlim,vlim]*1e-3,XSTYLE:1,XLOG:0,XTITLE:xtitle, $
        YRANGE:[-vlim,vlim]*1e-3,YSTYLE:1,YLOG:0,YTITLE:ytitle, $
        TITLE:title,TOP:1,ASPECT:1}

str_element,contstuff,'LEVELS',levels,/ADD_REPLACE
str_element,contstuff,'C_LABELS',c_labels,/ADD_REPLACE
str_element,contstuff,'OVERPLOT',1,/ADD_REPLACE
str_element,contstuff,'ISOTR',1,/ADD_REPLACE
extract_tags,contstuff,lim1,/CONTOUR

extract_tags,lim1,lim
lim1.YRANGE = lim1.XRANGE
lim1.XLOG   = 0
lim1.YLOG   = 0

mypos3 = [0.22941,0.515,0.77059,0.915]
str_element,lim1,'POSITION',mypos3,/ADD_REPLACE
;-----------------------------------------------------------------------------------------
; => Plot axes for contour overplot
;-----------------------------------------------------------------------------------------
PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim1
;-----------------------------------------------------------------------------------------
; => Create a symbol for plotting the "actual" calculated DF data points
;-----------------------------------------------------------------------------------------
xxo = FINDGEN(17)*(!PI*2./16.)
USERSYM,0.20*COS(xxo),0.20*SIN(xxo),/FILL  ; => LBW III 10/15/2011   v2.5.1

; => LBW III   02/15/2011
;OPLOT,dat3d.VPAR_DAT*1e-3,dat3d.VPERP_DAT*1e-3,PSYM=8,SYMSIZE=1.5,COLOR=cc1.CYAN  ; => Plot DF points
; => LBW III 10/15/2011   v2.5.1
OPLOT,dfpar2.VX0*1e-3,dfpar2.VY0*1e-3,PSYM=8,SYMSIZE=1.5,COLOR=cc1.CYAN  ; => Plot DF points
;-----------------------------------------------------------------------------------------
; => Plot contours
;-----------------------------------------------------------------------------------------
CONTOUR,df10,vout*1e-3,-1e-3*vout,_EXTRA=contstuff
;-----------------------------------------------------------------------------------------
; => Draw a line to mark the SW velocity direction
;-----------------------------------------------------------------------------------------
xyposi  = [-1d0*.94*vlim[0],0.92*vlim[0]]*1d-3  ; => location of Vsw label
v_mfac  = (vlim[0]*95d-2)*1d-3                  ; => normalization factor for projected vectors
v_vsws  = REFORM(dat3d[0].VSW)
v_magf  = REFORM(dat3d[0].MAGF)
vswmg   = SQRT(TOTAL(v_vsws^2,/NAN))
mrot    = cal_rot(v_magf,v_vsws)
; => Rotate Vsw
vswr    = REFORM(mrot ## v_vsws)/vswmg[0]
; => Renormalize to XY-Plane Projection
vswr    = (vswr*v_mfac[0])/SQRT(TOTAL(vswr[0L:1L]^2,/NAN))
vdpara  = vswr[0]
vdperp  = vswr[1]

; => Draw a black line for projection of Vsw
OPLOT,[0.0,vdpara[0]],[0.0,vdperp[0]],THICK=2.0,LINESTYLE=0
OPLOT,[0.0,0.0],[0.0,0.0],PSYM=1                    ; => Put a + at origin of plot
XYOUTS,xyposi[0],xyposi[1],'V!Dsw!N',CHARSIZE=1.5,CHARTHICK=2.0,/DATA
; => Shift in negative Y-Direction
xyposi[1] -= 0.08*vlim*1d-3
;-----------------------------------------------------------------------------------------
; => Draw a line to mark the shock normal direction
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(gnorm) THEN BEGIN            ; => Add shock normal projection if desired
  IF (REFORM(N_ELEMENTS(gnorm)) NE 3) THEN BEGIN
    sh_mit     = read_shocks_jck_database()
    mit_dates  = sh_mit.SDATES
    anorms     = sh_mit.SHOCK.SH_NORM
    ymdb       = time_string([dat3d.TIME,dat3d.END_TIME],PREC=3)
    date       = ''                           ; => 'MMDDYY'
    date       = STRMID(ymdb[0],5L,2L)+STRMID(ymdb[0],8L,2L)+STRMID(ymdb[0],2L,2L)
    gshock     = WHERE(mit_dates EQ date,gsh)
    IF (gsh GT 0L) THEN nnorm = REFORM(anorms[gshock[0],*]) ELSE nnorm = REPLICATE(f,3)
  ENDIF ELSE BEGIN
    nnorm = REFORM(gnorm)
  ENDELSE
  ; => Rotate Vector
  nnmag      = SQRT(TOTAL(nnorm^2,/NAN))
  rnorm      = REFORM(mrot ## nnorm)/nnmag[0]
  ; => Renormalize to XY-Plane Projection
  rnorm      = (rnorm*v_mfac[0])/SQRT(TOTAL(rnorm[0L:1L]^2,/NAN))
  rnpar      = rnorm[0]
  rnper      = rnorm[1]
  rn0_col    = 250L
  OPLOT,[0.0,rnpar[0]],[0.0,rnper[0]],LINESTYLE=2,THICK=2.0,COLOR=rn0_col[0]
  XYOUTS,xyposi[0],xyposi[1],'Shock Normal',COLOR=rn0_col[0],CHARTHICK=2.0,/DATA
  ; => Shift in negative Y-Direction
  xyposi[1] -= 0.08*vlim*1d-3
ENDIF
;-----------------------------------------------------------------------------------------
; => If set, plot extra vector direction on contour plot
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(ex_vec0) THEN vec0 = REPLICATE(f,3) ELSE vec0 = FLOAT(REFORM(ex_vec0))
IF (TOTAL(FINITE(vec0)) NE 3) THEN out_v0 = 0 ELSE out_v0 = 1
IF NOT KEYWORD_SET(ex_vn0) THEN vec0n = 'Vec 1' ELSE vec0n = ex_vn0[0]
; => Rotate extra vectors
rot_v00 = REFORM(mrot ## vec0)/NORM(vec0)
; => Renormalize to XY-Plane Projection
rot_v00 = (rot_v00*v_mfac[0])/SQRT(TOTAL(rot_v00[0L:1L]^2,/NAN))
; => Project onto XY-Plane Projection
rv0_col = 220L
OPLOT,[0.0,rot_v00[0]],[0.0,rot_v00[1]],LINESTYLE=2,COLOR=rv0_col[0],THICK=2
IF (out_v0) THEN BEGIN
  XYOUTS,xyposi[0],xyposi[1],vec0n[0],/DATA,COLOR=rv0_col[0]
  ; => Shift in negative Y-Direction
  xyposi[1] -= 0.08*vlim*1d-3
ENDIF
;-----------------------------------------------------------------------------------------
; => If set, plot heat flux direction on contour plot
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(heat_f) THEN BEGIN
  sum     = mom_sum(dat3d,SC_POT=dat3d.SC_POT)
  sumt    = mom_translate(sum)
  charge  = sumt.CHARGE
  mass    = sumt.MASS
  nnorm   = SQRT(ABS(2*charge/mass))          ; => [(km/s) eV^(-1/2)]
  i3      = [[0,4,8],[9,13,17],[18,22,26]]
  qtens   = (mass*nnorm^2)*sumt.NVVV          ; => Heat flux tensor
  qqqs    = (sumt.NVVV[sumt.MAP_R3])[i3]
  qvec    = TOTAL(qqqs,1L,/NAN)               ; => Q_vec [eV km/s cm^(-3), GSE]
  qmag    = SQRT(TOTAL(qvec^2,/NAN))          ; => Magnitude of Heat flux [eV km/s cm^(-3)]
  qvec    = qvec/qmag[0]
  bmag    = SQRT(TOTAL(dat3d.MAGF^2,/NAN))
  umag    = dat3d.MAGF/bmag[0]
  ; => Rotate Vector
  rqvec   = REFORM(mrot ## qvec)
  ; => Renormalize to XY-Plane Projection
  rqvec   = (rqvec*v_mfac[0])/SQRT(TOTAL(rqvec[0L:1L]^2,/NAN))
  qpara   = rqvec[0]
  qperp   = rqvec[1]
  rq0_col =  50L
  OPLOT,[0.0,qpara[0]],[0.0,qperp[0]],LINESTYLE=4,THICK=2.0,COLOR=rq0_col[0]
  XYOUTS,xyposi[0],xyposi[1],'Heat Flux',COLOR=rq0_col[0],CHARTHICK=2.0,/DATA
ENDIF
;-------------------------------------------------------------------------------------
; => Project circle of constant speed onto contour
;-------------------------------------------------------------------------------------
IF KEYWORD_SET(vcirc) THEN BEGIN
  n_circ = N_ELEMENTS(vcirc)
  thetas = DINDGEN(500)*2d0*!DPI/499L
  FOR j=0L, n_circ - 1L DO BEGIN
    vxcirc = vcirc[j]*1d-3*COS(thetas)
    vycirc = vcirc[j]*1d-3*SIN(thetas)
    OPLOT,vxcirc,vycirc,LINESTYLE=2,THICK=2
  ENDFOR
ENDIF
;-----------------------------------------------------------------------------------------
; => Get parallel and perpendicular dist. func. cuts
;-----------------------------------------------------------------------------------------
plot1  = get_plot_state()
dfpara = distfunc(vout,0.,PARAM=dfpar2)    ; => vparallel cut (black line)
dfperp = distfunc(0.,vout,PARAM=dfpar2)    ; => vperp cut (blue line)
;-----------------------------------------------------------------------------------------
; => Make sure y-limits are not determined by "zeroed" data or NAN's
;-----------------------------------------------------------------------------------------
gy11   = WHERE(dfpara NE 0.0 AND FINITE(dfpara),g11)
gy22   = WHERE(dfperp NE 0.0 AND FINITE(dfperp),g22)
IF (g11 GT 0) THEN BEGIN
  tempdfa = dfpara[gy11]
ENDIF ELSE BEGIN
  tempdfa = dfpara
ENDELSE
IF (g22 GT 0) THEN BEGIN
  tempdfp = dfperp[gy22]
ENDIF ELSE BEGIN
  tempdfp = dfperp
ENDELSE
;-----------------------------------------------------------------------------------------
; => Determine Y-Limits
;-----------------------------------------------------------------------------------------
ytnpw   = ['10!U-24!N','10!U-23!N','10!U-22!N','10!U-21!N','10!U-20!N','10!U-19!N',$
           '10!U-18!N','10!U-17!N','10!U-16!N','10!U-15!N','10!U-14!N','10!U-13!N',$
           '10!U-12!N','10!U-11!N','10!U-10!N','10!U-9!N','10!U-8!N','10!U-7!N',   $
           '10!U-6!N']
ytvpw   = [1e-24,1e-23,1e-22,1e-21,1e-20,1e-19,1e-18,1e-17,1e-16,1e-15,1e-14,1e-13,$
           1e-12,1e-11,1e-10,1e-9,1e-8,1e-7,1e-6]

y1min = MIN([tempdfa,tempdfp],/NAN)/1.05
y1max = MAX([tempdfa,tempdfp],/NAN)*1.5
IF KEYWORD_SET(dfra) THEN BEGIN
  dfra  = REFORM(dfra)
  dfra  = dfra[SORT(dfra)]
  gynam = WHERE(ytvpw LE dfra[1] AND ytvpw GE dfra[0],gyn)
  IF (gyn EQ 0) THEN BEGIN
    ; => Bad DF data range...
    gynam   = WHERE(ytvpw LE y1max AND ytvpw GE y1min,gyn)
    cut_yra = [y1min,y1max]
  ENDIF ELSE BEGIN
    cut_yra = dfra
  ENDELSE
ENDIF ELSE BEGIN
  gynam   = WHERE(ytvpw LE y1max AND ytvpw GE y1min,gyn)
  cut_yra = [y1min,y1max]
ENDELSE

dflim = {NOERASE:1,YLOG:1,XSTYLE:1,TITLE:'',YTITLE:'df (sec!u3!n/km!u3!n/cm!u3!n)', $
         XTITLE:'Velocity (1000 km/s)',ASPECT:1}
extract_tags,dflim,lim1
extract_tags,plotstuff,dflim,/PLOT

plotstuff.TITLE  = ''
plotstuff.YLOG   = 1
str_element,plotstuff,'ASPECT',1,/ADD_REPLACE
IF (gyn GT 0L) THEN BEGIN
  str_element,plotstuff,'YTICKNAME',ytnpw[gynam],/ADD_REPLACE
  str_element,plotstuff,'YTICKV',ytvpw[gynam],/ADD_REPLACE
  str_element,plotstuff,'YTICKS',gyn - 1L,/ADD_REPLACE
  str_element,plotstuff,'YRANGE',cut_yra,/ADD_REPLACE
ENDIF ELSE BEGIN
  str_element,plotstuff,'YRANGE',cut_yra,/ADD_REPLACE
ENDELSE
str_element,plotstuff,'YSTYLE',1,/ADD_REPLACE
str_element,plotstuff,'YTITLE','df (sec!u3!n/km!u3!n/cm!u3!n)',/ADD_REPLACE
str_element,plotstuff,'XTITLE','Velocity (1000 km/s)',/ADD_REPLACE
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; => DO NOT CHANGE VALUES of MYPOS2!!
;-----------------------------------------------------------------------------------------
;*****************************************************************************************
mypos2 = FLTARR(4)
mypos2 = [0.22941,0.05,0.77059,0.45]  ; => position of second plot
str_element,plotstuff,'POSITION',mypos2,/ADD_REPLACE
;-----------------------------------------------------------------------------------------
; => Plot parallel and perpendicular cuts
;-----------------------------------------------------------------------------------------
PLOT,vout*1e-3,dfpara,_EXTRA=plotstuff,YMINOR=9,/NODATA
  ; => Plot point-by-point 1st
  OPLOT,vout*1e-3,dfpara,PSYM=4,SYMSIZE=0.9,COLOR=250L
  OPLOT,vout*1e-3,dfperp,PSYM=2,SYMSIZE=0.9,COLOR= 50L
  ; => Prevent points from attaching to lines
  XYOUTS,0e0,EXP(ALOG(plotstuff.YRANGE[1])/2e0),' ',/DATA
  ; => Plot lines 2nd
  OPLOT,vout*1e-3,dfpara,LINESTYLE=0,COLOR=250L
  OPLOT,vout*1e-3,dfperp,LINESTYLE=2,COLOR= 50L
  ; => Prevent lines from attaching to labels
  XYOUTS,0e0,EXP(ALOG(plotstuff.YRANGE[1])/2e0),' ',/DATA
  ; => Output labels
  XYOUTS,.60,.420,'--- : Parallel Cut'       ,/NORMAL,COLOR=250L
  XYOUTS,.60,.400,'- - - : Perpendicular Cut',/NORMAL,COLOR= 50L
  ;---------------------------------------------------------------------------------------
  ; => Plot vertical lines for circle of constant speed if desired
  ;---------------------------------------------------------------------------------------
  IF KEYWORD_SET(vcirc) THEN BEGIN
    n_circ = N_ELEMENTS(vcirc)
    yras   = plotstuff.YRANGE
    FOR j=0L, n_circ - 1L DO BEGIN
      OPLOT,[vcirc[j]*1d-3,vcirc[j]*1d-3],yras,LINESTYLE=2,THICK=2
      OPLOT,-1d0*[vcirc[j]*1d-3,vcirc[j]*1d-3],yras,LINESTYLE=2,THICK=2
    ENDFOR
  ENDIF
;-----------------------------------------------------------------------------------------
; =>  Make dist. for 1 count plot
; =>  prior use of distfunc.pro may have produced extra array elements with
;    values of -0.0145 which was a unique value chosen to mark "empty" 
;    data elements for later removal to avoid "Conflicting Data Structures"
;    errors
; =>  It is also important to remove non-finite quantities to avoid 
;    "Infinite Plot Range" errors in the calculation of a new distribution
;    function
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(myonec) THEN BEGIN
  o_type = SIZE(myonec,/TYPE)
  CASE o_type[0] OF
    8    : BEGIN
      dfonec = one_count_level(myonec,VLIM=vlim,NGRID=n,NUM_PA=17L)  ; => LBW III 10/15/2011   v2.5.1
    END
    ELSE : BEGIN
      MESSAGE,'Incorrect keyword format: MYONEC (Must be a structure)',/INFORMATIONAL,/CONTINUE
      dfonec = REPLICATE(f,2L*n + 1L)
    END
  ENDCASE
  OPLOT,vout*1e-3,dfonec,LINESTYLE=4,COLOR=150L
  XYOUTS,.60,.380,'- - - : One-Count Level',/NORMAL,COLOR=150L
ENDIF
;-----------------------------------------------------------------------------------------
; => Reduced distribution function
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(redf) THEN BEGIN
  redf2 = !PI*TOTAL(df*ABS(vy),2,/NAN)*vlim/(n*redf)
  OPLOT,vout*1e-3,redf2/1e7,COLOR=250L
  OPLOT,vout*1e-3,redf2/1e7,COLOR=250L,PSYM=5,SYMSIZE=0.9
  XYOUTS,.60,.380,'--- : Reduced Dist. Function',COLOR=250L,/NORMAL
ENDIF
;-----------------------------------------------------------------------------------------
; => If set, output the temperature anisotropy on the plot
;-----------------------------------------------------------------------------------------
!P.CHARSIZE = 0.85
IF (KEYWORD_SET(ani_temp) OR KEYWORD_SET(v_th)) THEN BEGIN
  temp  = moments_3d(dat3d,SC_POT=dat3d.SC_POT,MAGDIR=dat3d.MAGF)
  IF KEYWORD_SET(ani_temp) THEN BEGIN
    tperp = 5e-1*(temp.MAGT3[0] + temp.MAGT3[1])
    tpara = temp.MAGT3[2]
    tanis = tperp/tpara
    anit  = 'T!D!9x!3e!N/T!D!9#!3e!N'
    XYOUTS,.41,.12,anit+': '+STRTRIM(STRING(FORMAT='(f10.2)',tanis[0]),2),/NORMAL
  ENDIF
  IF KEYWORD_SET(v_th) THEN BEGIN
    vtherm   = temp.VTHERMAL
    vpref    = 'Thermal Speed: '
    XYOUTS,.41,.10,vpref[0]+STRTRIM(STRING(FORMAT='(f10.2)',vtherm[0]),2)+' km/s',/NORMAL
  ENDIF
ENDIF
;-----------------------------------------------------------------------------------------
; => Print SC Potential on plot
;-----------------------------------------------------------------------------------------
sc_pot_str  = STRTRIM(STRING(FORMAT='(f10.2)',dfpar2.SC_POT),2)
XYOUTS,.41,.08,'SC Potential : '+sc_pot_str+' eV',/NORMAL
; => Output version # and date produced
XYOUTS,0.785,0.06,version[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.

;-----------------------------------------------------------------------------------------
; => Return
;-----------------------------------------------------------------------------------------
!P.MULTI    = 0
!P.CHARSIZE = 1.0

RETURN
END
