;+
;*****************************************************************************************
;
;  FUNCTION :   df_contours_3d.pro
;  PURPOSE  :   Produces a contour plot of the distribution function (DF) with parallel
;                 and perpendicular cuts shown for each projection.  The plot on the left
;                 shows the plane containing the vectors associated with the VSW and MAGF
;                 IDL structure tags.  The plot on the right contains the vector
;                 associated with the MAGF IDL structure tag and the vector orthogonal to
;                 the plane on the left (e.g. - Vsw x Bo).
;
;  CALLED BY:   
;               
;
;  CALLS:
;               add_df2d_to_ph.pro
;               cal_rot.pro
;               contour_3dp_plot_limits.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  3DP data structure either from get_??.pro
;                               with defined structure tag quantities for VSW and
;                               MAGF
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
;               ; => Plot in ion rest frame
;               ;....................................................................
;               df_contours_3d,dat,VLIM=6d4,NGRID=20,/SM_CUTS,NSMOOTH=5
;
;  KEYWORDS:    
;               VLIM       :  Limit for x-y velocity axes over which to plot data
;                               [Default = max vel. from energy bin values]
;               NGRID      :  # of isotropic velocity grids to use to triangulate the data
;                               [Default = 30L]
;               BNAME      :  Scalar string defining the name of vector associated with
;                               the MAGF IDL structure tag in DAT
;                               [Default = 'Bo']
;               VNAME      :  Scalar string defining the name of vector associated with
;                               the VSW IDL structure tag in DAT
;                               [Default = 'Vsw']
;               SM_CUTS    :  If set, program plots the smoothed cuts of the DF
;                               [Note:  Smoothed to the minimum # of points]
;               NSMOOTH    :  Scalar # of points over which to smooth the DF
;                               [Default = 3]
;               ONE_C      :  If set, program makes a copy of the input array, redefines
;                               the data points equal to 1.0, and then calculates the 
;                               parallel cut and overplots it as the One Count Level
;               DFRA       :  2-Element array specifying a DF range (s^3/km^3/cm^3) for the
;                               cuts of the contour plot
;               VCIRC      :  Scalar or array defining the value(s) to plot as a
;                               circle(s) of constant speed [km/s] on the contour
;                               plot [e.g. gyrospeed of specularly reflected ion]
;               EX_VEC0    :  3-Element unit vector for another quantity like heat flux or 
;                               a wave vector
;               EX_VN0     :  A string name associated with EX_VEC0
;                               [Default = 'Vec 1']
;               EX_VEC1    :  3-Element unit vector for another quantity like heat flux or 
;                               a wave vector
;               EX_VN1     :  A string name associated with EX_VEC1
;                               [Default = 'Vec 2']
;               NOKILL_PH  :  If set, data_velocity_transform.pro will not call
;                               pesa_high_bad_bins.pro
;               NO_REDF    :  If set, program will plot only cuts of the distribution,
;                               not quasi-reduced distributions
;                               [Default:  program plots quasi-reduced distributions]
;
;   CHANGED:  1)  Added version number to output plot           [01/11/2012   v1.0.1]
;             2)  Added keywords:  NOKILL_PH and NO_REDF        [01/27/2012   v1.1.0]
;             3)  VCIRC keyword can now handle array inputs     [01/27/2012   v1.1.1]
;             4)  Fixed a typo that occurred when using VCIRC keyword
;                                                               [02/01/2012   v1.1.2]
;
;   NOTES:      
;               1)  Make sure that the structure tags MAGF and VSW have finite
;                    values
;               2)  DAT does not need to be from the Wind 3DP experiment so long as it
;                    contains similar structure tags
;               3)  See also:
;                    eh_cont3d.pro
;
;   CREATED:  12/15/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/01/2012   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO df_contours_3d,dat,VLIM=vlim,NGRID=ngrid,BNAME=bname,VNAME=vname,SM_CUTS=sm_cuts,$
                       NSMOOTH=nsmooth,ONE_C=one_c,DFRA=dfra,VCIRC=vcirc,            $
                       EX_VEC0=ex_vec0,EX_VN0=ex_vn0,EX_VEC1=ex_vec1,EX_VN1=ex_vn1,  $
                       NOKILL_PH=nokill_ph,NO_REDF=no_redf

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
version  = 'df_contours_3d.pro : 02/01/2012 v1.1.2, output at: '
version  = version[0]+time_string(SYSTIME(1,/SECONDS),PREC=3)

f        = !VALUES.F_NAN
d        = !VALUES.D_NAN
dumbytr  = 'quasi-reduced df (sec!U3!N/km!U3!N/cm!U3!N)'
dumbytc  = 'cuts of df (sec!U3!N/km!U3!N/cm!U3!N)'
suffc    = [' Cut',' Reduced DF']

IF NOT KEYWORD_SET(ngrid) THEN ngrid = 30L ; => # of levels to use for contour.pro
IF NOT KEYWORD_SET(vlim) THEN BEGIN
  vlim = MAX(SQRT(2*dat[0].ENERGY/dat[0].MASS),/NAN)  ; => velocity limit (km/s)
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)  ; => velocity limit (km/s)
ENDELSE

IF KEYWORD_SET(one_c) THEN BEGIN
  onec      = dat[0]
  IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
    onec[0].DATA = 1.0
    add_df2d_to_ph,onec,VLIM=vlim,NGRID=ngrid,VBROT=test_n,NSMOOTH=ns,$
                        NOKILL_PH=nokill_ph,NO_REDF=no_redf
  ENDIF
ENDIF

; => Position of 1st contour [square]
;             Xo    Yo    X1    Y1
pos_0con = [0.100,0.515,0.495,0.910]
; => Position of 2nd contour [square]
pos_1con = [0.500,0.515,0.895,0.910]
; => Position of 1st DF cuts [square]
pos_0cut = [0.100,0.050,0.495,0.445]
; => Position of 2nd DF cuts [square]
pos_1cut = [0.500,0.050,0.895,0.445]
;-----------------------------------------------------------------------------------------
; => Check for finite vectors in VSW and MAGF IDL structure tags
;-----------------------------------------------------------------------------------------
v_vsws   = REFORM(dat[0].VSW)
v_magf   = REFORM(dat[0].MAGF)
test_v   = TOTAL(FINITE(v_vsws)) NE 3
test_b   = TOTAL(FINITE(v_magf)) NE 3
; => If only test_v = TRUE, then use Sun Direction
IF (test_v) THEN BEGIN
  v_vsws     = [1.,0.,0.]
  dat[0].VSW = v_vsws
  vname      = 'X!DGSE!N'
ENDIF

IF (test_b) THEN BEGIN
  errmsg = 'DAT must have finite values in VSW and MAGF tags!'
  MESSAGE,errmsg[0],/INFORMATION,/CONTINUE
  !P.MULTI = 0
  PLOT,[0.0,1.0],[0.0,1.0],/NODATA
  RETURN
ENDIF

IF NOT KEYWORD_SET(bname) THEN bname = 'B!Do!N' ELSE bname = bname[0]
IF NOT KEYWORD_SET(vname) THEN vname = 'V!Dsw!N' ELSE vname = vname[0]

; => Define X- and Y-Axis Contour Plot Titles for 1st Contour
xttl00 = '(V dot '+bname[0]+') [1000 km/s]'
yttl00 = bname[0]+' x ('+vname[0]+' x '+bname[0]+') [1000 km/s]'
; => Define X- and Y-Axis Contour Plot Titles for 2nd Contour
xttl01 = '(V dot '+bname[0]+') [1000 km/s]'
yttl01 = '- ('+vname[0]+' x '+bname[0]+') [1000 km/s]'
;-----------------------------------------------------------------------------------------
; => Define rotation matrices
;-----------------------------------------------------------------------------------------
rot_m0 = cal_rot(v_magf,v_vsws)       ; => Rotation for 1st Contour
esw0   = -1d0*CROSSP(v_vsws,v_magf)   ; => -(Vsw x Bo) direction
nesw0  = esw0/NORM(esw0)              ; => Normalized
nvmagf = v_magf/NORM(v_magf)          ; => Normalized
nvvsws = v_vsws/NORM(v_vsws)          ; => Normalized
v3     = CROSSP(nvmagf,nesw0)
rot_m1 = DBLARR(3,3)                  ; => Rotation for 2nd Contour
v1     = nvmagf
v2     = nesw0
v3     = v3/NORM(v3)
; => Define new basis vectors
rot_m1[*,0] = v1
rot_m1[*,1] = v2
rot_m1[*,2] = v3
;-----------------------------------------------------------------------------------------
; => Calculate distribution function and convert into solar wind frame
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(nsmooth) THEN ns = 3 ELSE ns = LONG(nsmooth)
tad = dat
add_df2d_to_ph,tad,VLIM=vlim,NGRID=ngrid,VBROT=test_n,NSMOOTH=ns,$
                   NOKILL_PH=nokill_ph,NO_REDF=no_redf
; => Make sure the structure has correct tags
tad_tags = STRLOWCASE(TAG_NAMES(tad))
gtest    = (tad_tags EQ 'df_para') OR (tad_tags EQ 'df_perp')
good     = WHERE(gtest,gd)
IF (gd EQ 0) THEN BEGIN
  ; => Bad data structure!
  MESSAGE,'No finite data...',/INFORMATION,/CONTINUE
  !P.MULTI = 0
  PLOT,[0.0,1.0],[0.0,1.0],/NODATA
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Define default DF range of values
;-----------------------------------------------------------------------------------------
lower_limit    = 1e-18  ; => Lowest expected value for EESA Low
upper_limit    = 1e-4   ; => Highest expected value for EESA Low
df_par_all     = tad[0].DF_PARA
df_per_all     = tad[0].DF_PERP
ve_par_all     = tad[0].VX2D
gpara          = WHERE(ABS(ve_par_all) LE 875e-3*vlim[0],gpa)
IF (gpa GT 0) THEN BEGIN
  def_low  = MIN([df_par_all[gpara],df_per_all[gpara]],/NAN)/1.05 > lower_limit[0]
  def_high = MAX([df_par_all[gpara],df_per_all[gpara]],/NAN)*1.05 < upper_limit[0]
ENDIF ELSE BEGIN
  def_low  = lower_limit[0]
  def_high = upper_limit[0]
ENDELSE

IF (N_ELEMENTS(dfra) NE 2) THEN dfra = [def_low,def_high]
;-----------------------------------------------------------------------------------------
; => Define plot parameters
;-----------------------------------------------------------------------------------------
def_lim   = contour_3dp_plot_limits(tad,VLIM=vlim,NGRID=ngrid,DFRA=dfra)
;------------------------------------
; => For contour plot
;------------------------------------
contstuf0 = def_lim.CONT
contstuf1 = contstuf0
; => Change POSITION for each
str_element,contstuf0,'POSITION',pos_0con,/ADD_REPLACE
str_element,contstuf1,'POSITION',pos_1con,/ADD_REPLACE
; => Delete Axes Titles for each
str_element,contstuf0,'XTITLE',/DELETE
str_element,contstuf0,'YTITLE',/DELETE
str_element,contstuf1,'XTITLE',/DELETE
str_element,contstuf1,'YTITLE',/DELETE
;------------------------------------
; => For initial empty contour plot
;------------------------------------
lim10     = def_lim.PLOT_LIMS
lim20     = lim10
; => Change XY-Titles for each
str_element,lim10,'XTITLE',xttl00[0],/ADD_REPLACE
str_element,lim10,'YTITLE',yttl00[0],/ADD_REPLACE
str_element,lim20,'XTITLE',xttl01[0],/ADD_REPLACE
str_element,lim20,'YTITLE',yttl01[0],/ADD_REPLACE
;str_element,lim20,'XSTYLE',4,/ADD_REPLACE
str_element,lim20,'YSTYLE',5,/ADD_REPLACE          ; => Suppress left-side Y-Axis labels
; => Change POSITION for each
str_element,lim10,'POSITION',pos_0con,/ADD_REPLACE
str_element,lim20,'POSITION',pos_1con,/ADD_REPLACE
;------------------------------------
; => For cuts of the DF
;------------------------------------
lim11     = def_lim.CUTS
lim21     = lim11
; => Change POSITION for each
str_element,lim11,'POSITION',pos_0cut,/ADD_REPLACE
str_element,lim21,'POSITION',pos_1cut,/ADD_REPLACE
str_element,lim21,'YSTYLE',5,/ADD_REPLACE          ; => Suppress left-side Y-Axis labels
; => Y-Title for Cuts
IF KEYWORD_SET(no_redf) THEN BEGIN
  ; => Cuts of DFs
  c_suff = suffc[0]
  str_element,lim11,'YTITLE',dumbytc[0],/ADD_REPLACE
  str_element,lim21,'YTITLE',dumbytc[0],/ADD_REPLACE
ENDIF ELSE BEGIN
  ; => Quasi-Reduced DFs
  c_suff = suffc[1]
  str_element,lim11,'YTITLE',dumbytr[0],/ADD_REPLACE
  str_element,lim21,'YTITLE',dumbytr[0],/ADD_REPLACE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define the 2D projection of the VSW IDL structure tag in DAT and other vectors
;-----------------------------------------------------------------------------------------
v_mfac    = (vlim[0]*95d-2)*1d-3
v_mag     = SQRT(TOTAL(tad.VSW^2,/NAN))
IF (FINITE(tad.VSW[0]) AND v_mag NE 0.0) THEN BEGIN
  vswname = '- - - : '+vname[0]+' Projection'
  vxy_pro = REFORM(rot_m0 ## v_vsws)/v_mag[0]
  vxz_pro = REFORM(rot_m1 ## v_vsws)/v_mag[0]
  vsw2d_0 = vxy_pro[0L:1L]/SQRT(TOTAL(vxy_pro[0L:1L]^2,/NAN))*v_mfac[0]
  vsw2d_1 = vxz_pro[0L:1L]/SQRT(TOTAL(vxz_pro[0L:1L]^2,/NAN))*v_mfac[0]
;  vxymag  = SQRT(TOTAL(tad[0L].VxB_2D[0L:1L]^2,/NAN))
;  vsw2d   = [tad.VxB_2D[0L],tad.VxB_2D[1L]]/v_mag[0]*v_mfac[0]
ENDIF ELSE BEGIN
  vswname = ''
;  vsw2d   = REPLICATE(f,2)
  vsw2d_0 = REPLICATE(f,2)
  vsw2d_1 = REPLICATE(f,2)
ENDELSE

; => Check for EX_VEC0 and EX_VEC1
IF NOT KEYWORD_SET(ex_vec0) THEN vec0 = REPLICATE(f,3) ELSE vec0 = FLOAT(REFORM(ex_vec0))
IF NOT KEYWORD_SET(ex_vec1) THEN vec1 = REPLICATE(f,3) ELSE vec1 = FLOAT(REFORM(ex_vec1))
; => Define logic variables for output later
IF (TOTAL(FINITE(vec0)) NE 3) THEN out_v0 = 0 ELSE out_v0 = 1
IF (TOTAL(FINITE(vec1)) NE 3) THEN out_v1 = 0 ELSE out_v1 = 1

IF NOT KEYWORD_SET(ex_vn0) THEN vec0n = 'Vec 1' ELSE vec0n = ex_vn0[0]
IF NOT KEYWORD_SET(ex_vn1) THEN vec1n = 'Vec 2' ELSE vec1n = ex_vn1[0]
vc1_col = 250L
vc2_col =  75L
;-----------------------------------------------------------------------------------------
; => Rotate extra vectors
;-----------------------------------------------------------------------------------------
; => 1st Contour
rot_v00 = REFORM(rot_m0 ## vec0)/NORM(vec0)
rot_v10 = REFORM(rot_m0 ## vec1)/NORM(vec1)
; => Renormalize to XY-Plane Projection
rot_v00 = rot_v00/SQRT(TOTAL(rot_v00[0L:1L]^2,/NAN))*v_mfac[0]
rot_v10 = rot_v10/SQRT(TOTAL(rot_v10[0L:1L]^2,/NAN))*v_mfac[0]
; => 2nd Contour
rot_v01 = REFORM(rot_m1 ## vec0)*v_mfac[0]
rot_v11 = REFORM(rot_m1 ## vec1)*v_mfac[0]
; => Renormalize to XY-Plane Projection
rot_v01 = rot_v01/SQRT(TOTAL(rot_v01[0L:1L]^2,/NAN))*v_mfac[0]
rot_v11 = rot_v11/SQRT(TOTAL(rot_v11[0L:1L]^2,/NAN))*v_mfac[0]
;-----------------------------------------------------------------------------------------
; => Define DFs, cut parameters, and velocity-space locations
;-----------------------------------------------------------------------------------------

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; => 1st Contour Cuts
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
df2d     = tad.DF2D         ; => 1st Contour Data
; => LBW III 01/27/2012
IF KEYWORD_SET(no_redf) THEN BEGIN
  ndf     = (SIZE(df2d,/DIMENSIONS))[0]/2L + 1L
  ; => Calculate Cuts of DFs
  dfpara0 = REFORM(df2d[*,ndf[0]])                                  ; => Para. Cut of DF
  dfperp0 = REFORM(df2d[ndf[0],*])                                  ; => Perp. Cut of DF
ENDIF ELSE BEGIN
  ; => Calculate Quasi-Reduced DFs
  dfpara0 = TOTAL(df2d,2L,/NAN)/SQRT(TOTAL(FINITE(df2d),2L,/NAN))   ; => Para. Cut of DF
  dfperp0 = TOTAL(df2d,1L,/NAN)/SQRT(TOTAL(FINITE(df2d),1L,/NAN))   ; => Perp. Cut of DF
ENDELSE
vx_grid0 = tad.VX2D*1d-3    ; => Gridded X-Velocities [1000 km/s]
vy_grid0 = tad.VY2D*1d-3    ; => Gridded Y-Velocities [1000 km/s]
vx_data0 = tad.VX_PTS*1d-3  ; => X-Velocities of actual data points
vy_data0 = tad.VY_PTS*1d-3  ; => Y-Velocities of actual data points
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; => 2nd Contour Cuts
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
df2dz    = tad.DF2DZ        ; => 2nd Contour Data
; => LBW III 01/27/2012
IF KEYWORD_SET(no_redf) THEN BEGIN
  ndf     = (SIZE(df2dz,/DIMENSIONS))[0]/2L + 1L
  ; => Calculate Cuts of DFs
  dfpara1 = REFORM(df2dz[*,ndf[0]])                                  ; => Para. Cut of DF
  dfperp1 = REFORM(df2dz[ndf[0],*])                                  ; => Perp. Cut of DF
ENDIF ELSE BEGIN
  ; => Calculate Quasi-Reduced DFs
  ; => LBW III 06/15/2011
  dfpara1 = TOTAL(df2dz,2L,/NAN)/SQRT(TOTAL(FINITE(df2dz),2L,/NAN))   ; => Para. Cut of DF
  dfperp1 = TOTAL(df2dz,1L,/NAN)/SQRT(TOTAL(FINITE(df2dz),1L,/NAN))   ; => Perp. Cut of DF
ENDELSE
vx_grid1 = vx_grid0         ; => Gridded X-Velocities [1000 km/s]
vy_grid1 = vy_grid0         ; => Gridded Z-Velocities [1000 km/s]
vx_data1 = tad.VX_PTS*1d-3  ; => X-Velocities of actual data points
vy_data1 = tad.VZ_PTS*1d-3  ; => Z-Velocities of actual data points

IF (SIZE(onec[0],/TYPE) EQ 8) THEN BEGIN
  ; => Define 1-Count level cuts
  vx_onc0  = onec[0].VX2D*1d-3
  df2d_oc  = onec[0].DF2D
  df2dz_oc = onec[0].DF2DZ
  one_par0 = TOTAL(df2d_oc,2L,/NAN)/SQRT(TOTAL(FINITE(df2d_oc),2L,/NAN))
  one_par1 = TOTAL(df2dz_oc,2L,/NAN)/SQRT(TOTAL(FINITE(df2dz_oc),2L,/NAN))
  ; => smooth the 1-count parallel cuts
  one_par0 = SMOOTH(one_par0,3L,/EDGE_TRUNCATE,/NAN)
  one_par1 = SMOOTH(one_par1,3L,/EDGE_TRUNCATE,/NAN)
ENDIF
;-----------------------------------------------------------------------------------------
; => Smooth the data to replace NaNs etc.
;-----------------------------------------------------------------------------------------
df2ds    = SMOOTH(df2d,ns[0],/EDGE_TRUNCATE,/NAN)
df2dsz   = SMOOTH(df2dz,ns[0],/EDGE_TRUNCATE,/NAN)

IF KEYWORD_SET(sm_cuts) THEN BEGIN
  ; => Smooth over 3 points to fill in possible gaps
  dfpara0  = SMOOTH(dfpara0,3L,/EDGE_TRUNCATE,/NAN)
  dfperp0  = SMOOTH(dfperp0,3L,/EDGE_TRUNCATE,/NAN)
  dfpara1  = SMOOTH(dfpara1,3L,/EDGE_TRUNCATE,/NAN)
  dfperp1  = SMOOTH(dfperp1,3L,/EDGE_TRUNCATE,/NAN)
ENDIF
;-----------------------------------------------------------------------------------------
; => Set up plots for IDL
;-----------------------------------------------------------------------------------------
!P.MULTI = [0,2,2,0,1]    ; => Top-to-Bottom, Left-to-Right
; => Defined user symbol for outputing locations of data on contour
xxo = FINDGEN(17)*(!PI*2./16.)
USERSYM,0.25*COS(xxo),0.25*SIN(xxo),/FILL

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;-----------------------------------------------------------------------------------------
; => Plot 1st Contour of 2D DF
;-----------------------------------------------------------------------------------------
PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim10,YTICK_GET=ytick_cont1
  ; => Project locations of actual data points onto contour
  OPLOT,vx_data0,vy_data0,PSYM=8,SYMSIZE=1.0,COLOR=100
  ;---------------------------------------------------------------------------------------
  ; => Draw contours
  ;---------------------------------------------------------------------------------------
  CONTOUR,df2ds,vx_grid0,vy_grid0,_EXTRA=contstuf0
    ;-------------------------------------------------------------------------------------
    ; => Project V_sw onto contour
    ;-------------------------------------------------------------------------------------
    OPLOT,[0.0,vsw2d_0[0]],[0.0,vsw2d_0[1]],LINESTYLE=0,THICK=2
    xyposi = [-1d0*.94*vlim[0],0.94*vlim[0]]*1d-3
    IF (TOTAL(FINITE(v_vsws)) EQ 3) THEN BEGIN
      XYOUTS,xyposi[0],xyposi[1],vswname[0],/DATA
      ; => Shift in negative Y-Direction
      xyposi[1] -= 0.08*vlim*1d-3
    ENDIF
    ;-------------------------------------------------------------------------------------
    ; => Project 1st extra vector onto contour
    ;-------------------------------------------------------------------------------------
    OPLOT,[0.0,rot_v00[0]],[0.0,rot_v00[1]],LINESTYLE=2,COLOR=vc1_col[0],THICK=2
    IF (out_v0) THEN BEGIN
      XYOUTS,xyposi[0],xyposi[1],vec0n[0],/DATA,COLOR=vc1_col[0]
      ; => Shift in negative Y-Direction
      xyposi[1] -= 0.08*vlim*1d-3
    ENDIF
    ;-------------------------------------------------------------------------------------
    ; => Project 2nd extra vector onto contour
    ;-------------------------------------------------------------------------------------
    OPLOT,[0.0,rot_v10[0]],[0.0,rot_v10[1]],LINESTYLE=2,COLOR=vc2_col[0],THICK=2
    IF (out_v1) THEN BEGIN
      XYOUTS,xyposi[0],xyposi[1],vec1n[0],/DATA,COLOR=vc2_col[0]
      ; => Shift in negative Y-Direction
      xyposi[1] -= 0.08*vlim*1d-3
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
; => Plot cuts of 1st DF
;-----------------------------------------------------------------------------------------
PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim11,YTICK_GET=ytick_cut1
  empty_str = REPLICATE(' ',N_ELEMENTS(ytick_cut1))
  ; => Plot point-by-point
  OPLOT,vx_grid0,dfpara0,COLOR=250,PSYM=1
  OPLOT,vy_grid0,dfperp0,COLOR= 50,PSYM=2
  ; => Plot lines
  OPLOT,vx_grid0,dfpara0,COLOR=250,LINESTYLE=0
  OPLOT,vy_grid0,dfperp0,COLOR= 50,LINESTYLE=2
  ;---------------------------------------------------------------------------------------
  ; => Determine where to put labels
  ;---------------------------------------------------------------------------------------
  fmin       = lim11.YRANGE[0]
  xyposi     = [-1d0*4e-1*vlim[0]*1d-3,fmin[0]*4e0]
  ; => Output label for para
  XYOUTS,xyposi[0],xyposi[1],'+++ : Parallel Cut',/DATA,COLOR=250
  ; => Shift in negative Y-Direction
  xyposi[1] *= 0.7
  ; => Output label for perp
  XYOUTS,xyposi[0],xyposi[1],'*** : Perpendicular Cut',COLOR=50,/DATA
  ;---------------------------------------------------------------------------------------
  ; => Plot 1-Count Level if desired
  ;---------------------------------------------------------------------------------------
  IF KEYWORD_SET(one_c) THEN BEGIN
    OPLOT,vx_onc0,one_par0,COLOR=150,LINESTYLE=4
    ; => Shift in negative Y-Direction
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],'- - - : One-Count Level',COLOR=150,/DATA
  ENDIF
  ;---------------------------------------------------------------------------------------
  ; => Plot vertical lines for circle of constant speed if desired
  ;---------------------------------------------------------------------------------------
  IF KEYWORD_SET(vcirc) THEN BEGIN
    n_circ = N_ELEMENTS(vcirc)
    yras   = lim11.YRANGE
    FOR j=0L, n_circ - 1L DO BEGIN
      OPLOT,[vcirc[j]*1d-3,vcirc[j]*1d-3],yras,LINESTYLE=2,THICK=2
      OPLOT,-1d0*[vcirc[j]*1d-3,vcirc[j]*1d-3],yras,LINESTYLE=2,THICK=2
    ENDFOR
  ENDIF

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;-----------------------------------------------------------------------------------------
; => Plot 2nd Contour of 2D DF
;-----------------------------------------------------------------------------------------
PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim20
  ; => Project locations of actual data points onto contour
  OPLOT,vx_data1,vy_data1,PSYM=8,SYMSIZE=1.0,COLOR=100
  ;---------------------------------------------------------------------------------------
  ; => Draw contours
  ;---------------------------------------------------------------------------------------
  CONTOUR,df2dsz,vx_grid1,vy_grid1,_EXTRA=contstuf1
    ;-------------------------------------------------------------------------------------
    ; => Plot Y-Axes with labels on right-hand side
    ;-------------------------------------------------------------------------------------
    AXIS,YAXIS=0,YTICKNAME=REPLICATE(' ',N_ELEMENTS(ytick_cont1)),YSTYLE=1,$
         YMINOR=lim20.YMINOR,YRANGE=lim20.YRANGE,YLOG=lim20.YLOG
    ; => Put labels on right-hand side
    AXIS,YAXIS=1,YTICKV=ytick_cont1,YSTYLE=1,YTITLE=lim20.YTITLE,$
         YMINOR=lim20.YMINOR,YRANGE=lim20.YRANGE,YLOG=lim20.YLOG
    ;-------------------------------------------------------------------------------------
    ; => Project V_sw onto contour
    ;-------------------------------------------------------------------------------------
    OPLOT,[0.0,vsw2d_1[0]],[0.0,vsw2d_1[1]],LINESTYLE=0
    xyposi = [-1d0*.94*vlim[0],0.94*vlim[0]]*1d-3
    IF (TOTAL(FINITE(v_vsws)) EQ 3) THEN BEGIN
      XYOUTS,xyposi[0],xyposi[1],vswname[0],/DATA
      ; => Shift in negative Y-Direction
      xyposi[1] -= 0.08*vlim*1d-3
    ENDIF
    ;-------------------------------------------------------------------------------------
    ; => Project 1st extra vector onto contour
    ;-------------------------------------------------------------------------------------
    OPLOT,[0.0,rot_v01[0]],[0.0,rot_v01[1]],LINESTYLE=2,COLOR=vc1_col[0],THICK=2
    IF (out_v0) THEN BEGIN
      XYOUTS,xyposi[0],xyposi[1],vec0n[0],/DATA,COLOR=vc1_col[0]
      ; => Shift in negative Y-Direction
      xyposi[1] -= 0.08*vlim*1d-3
    ENDIF
    ;-------------------------------------------------------------------------------------
    ; => Project 2nd extra vector onto contour
    ;-------------------------------------------------------------------------------------
    OPLOT,[0.0,rot_v11[0]],[0.0,rot_v11[1]],LINESTYLE=2,COLOR=vc2_col[0],THICK=2
    IF (out_v1) THEN BEGIN
      XYOUTS,xyposi[0],xyposi[1],vec1n[0],/DATA,COLOR=vc2_col[0]
      ; => Shift in negative Y-Direction
      xyposi[1] -= 0.08*vlim*1d-3
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
; => Plot cuts of 2nd DF
;-----------------------------------------------------------------------------------------
empty_str = REPLICATE(' ',N_ELEMENTS(ytick_cut1))
lim_33    = lim21
str_element,lim_33,'YTICKNAME',empty_str,/ADD_REPLACE
str_element,lim_33,'YSTYLE',1,/ADD_REPLACE
str_element,lim_33,'YTITLE','',/ADD_REPLACE
PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim_33
  ; => Plot point-by-point
  OPLOT,vx_grid1,dfpara1,COLOR=250,PSYM=1
  OPLOT,vy_grid1,dfperp1,COLOR= 50,PSYM=2
  ; => Plot lines
  OPLOT,vx_grid1,dfpara1,COLOR=250,LINESTYLE=0
  OPLOT,vy_grid1,dfperp1,COLOR= 50,LINESTYLE=2
  ;---------------------------------------------------------------------------------------
  ; => Plot Y-Axes with labels on right-hand side
  ;---------------------------------------------------------------------------------------
  ; => Put labels on right-hand side
  AXIS,YAXIS=1,YTICKV=ytick_cut1,YSTYLE=1,YTITLE=lim21.YTITLE,$
       YMINOR=lim21.YMINOR,YRANGE=lim21.YRANGE,YLOG=lim21.YLOG
  ;---------------------------------------------------------------------------------------
  ; => Determine where to put labels
  ;---------------------------------------------------------------------------------------
  fmin       = lim21.YRANGE[0]
  xyposi     = [-1d0*4e-1*vlim[0]*1d-3,fmin[0]*4e0]
  ; => Output label for para
  XYOUTS,xyposi[0],xyposi[1],'+++ : Parallel'+c_suff[0],/DATA,COLOR=250
  ; => Shift in negative Y-Direction
  xyposi[1] *= 0.7
  ; => Output label for perp
  XYOUTS,xyposi[0],xyposi[1],'*** : Perpendicular'+c_suff[0],COLOR=50,/DATA
  ;---------------------------------------------------------------------------------------
  ; => Plot 1-Count Level if desired
  ;---------------------------------------------------------------------------------------
  IF KEYWORD_SET(one_c) THEN BEGIN
    OPLOT,vx_onc0,one_par1,COLOR=150,LINESTYLE=4
    ; => Shift in negative Y-Direction
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],'- - - : One-Count Level',COLOR=150,/DATA
  ENDIF
  ;---------------------------------------------------------------------------------------
  ; => Plot vertical lines for circle of constant speed if desired
  ;---------------------------------------------------------------------------------------
  IF KEYWORD_SET(vcirc) THEN BEGIN
    n_circ = N_ELEMENTS(vcirc)
    yras   = lim21.YRANGE
    FOR j=0L, n_circ - 1L DO BEGIN
      OPLOT,[vcirc[j]*1d-3,vcirc[j]*1d-3],yras,LINESTYLE=2,THICK=2
      OPLOT,-1d0*[vcirc[j]*1d-3,vcirc[j]*1d-3],yras,LINESTYLE=2,THICK=2
    ENDFOR
  ENDIF
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;-----------------------------------------------------------------------------------------
; => Output version # and date produced
;-----------------------------------------------------------------------------------------
XYOUTS,0.950,0.06,version[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.

;-----------------------------------------------------------------------------------------
; => Return
;-----------------------------------------------------------------------------------------
!P.MULTI = 0

RETURN
END