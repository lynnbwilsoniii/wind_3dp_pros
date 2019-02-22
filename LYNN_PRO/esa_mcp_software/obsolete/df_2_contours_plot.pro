;+
;*****************************************************************************************
;
;  FUNCTION :   df_2_contours_plot.pro
;  PURPOSE  :   Produces 2 contour plots of the distribution function (DF) with parallel
;                 and perpendicular cuts shown for each projection.  The plot on the left
;                 shows the plane containing the vectors associated with the VSW and MAGF
;                 IDL structure tags.  The plot on the right contains the vector
;                 associated with the MAGF IDL structure tag and the vector orthogonal to
;                 the plane on the left (e.g. - Vsw x Bo).
;
;  CALLED BY:   
;               df_htr_contours_3d.pro
;
;  CALLS:
;               test_3dp_struc_format.pro
;               dat_3dp_str_names.pro
;               extract_tags.pro
;               str_element.pro
;               add_df2d_to_ph.pro
;               read_gen_ascii.pro
;               contour_3dp_plot_limits.pro
;               cal_rot.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT1       :  3DP data structure either from get_??.pro
;                               with data transformed and rotated into Plane 1
;               DAT2       :  3DP data structure either from get_??.pro
;                               with data transformed and rotated into Plane 2
;                               ** [Must be from the same instrument as DAT1] **
;
;  EXAMPLES:    
;               NA
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
;               VERSION    :  Scalar string defining the name and version of the
;                               routine calling this routine
;
;   CHANGED:  1)  Added a null string output to prevent Vsw label from 
;                   attaching itself to the 2nd contour axes [for Adobe Illustrator]
;                                                                  [02/02/2012   v1.0.1]
;
;   NOTES:      
;               1)  Both DAT1 and DAT2 must contain the extra structure tags added by
;                     the program data_velocity_transform.pro, though one does not need
;                     to use this routine to add said structure tags [e.g. when called
;                     by df_htr_contours_3d.pro]
;               2)  DAT1 and DAT2 must be from the same instrument
;               3)  See also:
;                    eh_cont3d.pro
;
;   CREATED:  02/01/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/02/2012   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO df_2_contours_plot,dat1,dat2,VLIM=vlim,NGRID=ngrid,BNAME=bname,VNAME=vname,    $
                       SM_CUTS=sm_cuts,NSMOOTH=nsmooth,ONE_C=one_c,DFRA=dfra,      $
                       VCIRC=vcirc,EX_VEC0=ex_vec0,EX_VN0=ex_vn0,EX_VEC1=ex_vec1,  $
                       EX_VN1=ex_vn1,NOKILL_PH=nokill_ph,NO_REDF=no_redf,          $
                       VERSION=vers0

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN

dumbytr        = 'quasi-reduced df (sec!U3!N/km!U3!N/cm!U3!N)'
dumbytc        = 'cuts of df (sec!U3!N/km!U3!N/cm!U3!N)'
suffc          = [' Cut',' Reduced DF']
dname          = STRLOWCASE(!D.NAME)

; => Position of 1st contour [square]
;             Xo    Yo    X1    Y1
pos_0con       = [0.100,0.515,0.495,0.910]
; => Position of 2nd contour [square]
pos_1con       = [0.500,0.515,0.895,0.910]
; => Position of 1st DF cuts [square]
pos_0cut       = [0.100,0.050,0.495,0.445]
; => Position of 2nd DF cuts [square]
pos_1cut       = [0.500,0.050,0.895,0.445]
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN RETURN
tad_1          = dat1[0]
tad_2          = dat2[0]
; => Check DAT1 structure format
test           = test_3dp_struc_format(tad_1)
IF (NOT test) THEN BEGIN
  notstr_mssg = 'DAT1 must be an IDL structure...'
  MESSAGE,notstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
; => Check DAT2 structure format
test           = test_3dp_struc_format(tad_2)
IF (NOT test) THEN BEGIN
  notstr_mssg = 'DAT2 must be an IDL structure...'
  MESSAGE,notstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF

strns_1        = dat_3dp_str_names(tad_1[0])
IF (SIZE(strns_1,/TYPE) NE 8L) THEN BEGIN
  badstr_mssg    = 'DAT1 is not an appropriate 3DP structure...'
  MESSAGE,badstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF

strns_2        = dat_3dp_str_names(tad_2[0])
IF (SIZE(strns_2,/TYPE) NE 8L) THEN BEGIN
  badstr_mssg    = 'DAT2 is not an appropriate 3DP structure...'
  MESSAGE,badstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
; => Check that DAT1 is from the same instrument as DAT2
test_inst      = STRMID(strns_1.SN,0L,2L) NE STRMID(strns_2.SN,0L,2L)
IF (test_inst) THEN BEGIN
  badstr_mssg    = 'DAT2 must be from the same instrument as DAT1!'
  MESSAGE,badstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Check keywords
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(ngrid) THEN ngrid = 30L ; => # of levels to use for contour.pro
IF NOT KEYWORD_SET(vlim) THEN BEGIN
  vlim = MAX(SQRT(2*tad_1[0].ENERGY/tad_1[0].MASS),/NAN)  ; => velocity limit (km/s)
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)  ; => velocity limit (km/s)
ENDELSE

IF KEYWORD_SET(one_c) THEN BEGIN
  badtags   = ['DF2D','VX2D','VY2D','VX_PTS','VY_PTS','VZ_PTS','DF2DZ','VX2DZ','VY2DZ']
  extract_tags,onec,dat1[0],EXCEPT_TAGS=badtags
  ; => Remove the added keywords
  str_element,onec,'DF_SMOOTH',/DELETE
  str_element,onec,'DF_PARA',/DELETE
  str_element,onec,'DF_PERP',/DELETE
  IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
    onec[0].DATA = 1.0
    add_df2d_to_ph,onec,VLIM=vlim,NGRID=ngrid,NSMOOTH=ns,NO_REDF=no_redf
  ENDIF
ENDIF

IF NOT KEYWORD_SET(bname) THEN bname = 'B!Do!N' ELSE bname = bname[0]
IF NOT KEYWORD_SET(vname) THEN vname = 'V!Dsw!N' ELSE vname = vname[0]
; => Define X- and Y-Axis Contour Plot Titles for 1st Contour
xttl00         = '(V dot '+bname[0]+') [1000 km/s]'
yttl00         = bname[0]+' x ('+vname[0]+' x '+bname[0]+') [1000 km/s]'
; => Define X- and Y-Axis Contour Plot Titles for 2nd Contour
xttl01         = '(V dot '+bname[0]+') [1000 km/s]'
yttl01         = '- ('+vname[0]+' x '+bname[0]+') [1000 km/s]'
;;########################################################################################
;; => Define version for output
;;########################################################################################
IF NOT KEYWORD_SET(vers0) THEN version = '' ELSE version = vers0[0]+', '

mdir           = FILE_EXPAND_PATH('wind_3dp_pros/LYNN_PRO/')+'/'
file           = FILE_SEARCH(mdir,'df_2_contours_plot.pro')
fstring        = read_gen_ascii(file[0])
test           = STRPOS(fstring,';    LAST MODIFIED:  ') GE 0
gposi          = WHERE(test,gpf)
shifts         = STRLEN(';    LAST MODIFIED:  ')
vers           = STRMID(fstring[gposi[0]],shifts[0])
vers1          = vers0[0]+'df_2_contours_plot.pro : '+vers[0]+', output at: '
version        = vers1[0]+time_string(SYSTIME(1,/SECONDS),PREC=3)
;-----------------------------------------------------------------------------------------
; => Define default DF range of values
;-----------------------------------------------------------------------------------------
lower_limit    = 1e-18  ; => Lowest expected value for EESA Low
upper_limit    = 1e-4   ; => Highest expected value for EESA Low
df_par_all     = [tad_1[0].DF_PARA,tad_2[0].DF_PARA]
df_per_all     = [tad_1[0].DF_PERP,tad_2[0].DF_PERP]
ve_par_all     = [tad_1[0].VX2D   ,tad_2[0].VX2D   ]
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
def_lim_1      = contour_3dp_plot_limits(tad_1,VLIM=vlim,NGRID=ngrid,DFRA=dfra)
def_lim_2      = contour_3dp_plot_limits(tad_2,VLIM=vlim,NGRID=ngrid,DFRA=dfra)
;------------------------------------
; => For contour plot
;------------------------------------
contstuf_1     = def_lim_1.CONT
contstuf_2     = def_lim_2.CONT
; => Change POSITION for each
str_element,contstuf_1,'POSITION',pos_0con,/ADD_REPLACE
str_element,contstuf_2,'POSITION',pos_1con,/ADD_REPLACE
; => Delete Axes Titles for each
str_element,contstuf_1,'XTITLE',/DELETE
str_element,contstuf_1,'YTITLE',/DELETE
str_element,contstuf_2,'XTITLE',/DELETE
str_element,contstuf_2,'YTITLE',/DELETE
;------------------------------------
; => For initial empty contour plot
;------------------------------------
lim_10         = def_lim_1.PLOT_LIMS
lim_20         = def_lim_2.PLOT_LIMS
; => Change XY-Titles for each
str_element,lim_10,'XTITLE',xttl00[0],/ADD_REPLACE
str_element,lim_10,'YTITLE',yttl00[0],/ADD_REPLACE
str_element,lim_20,'XTITLE',xttl01[0],/ADD_REPLACE
str_element,lim_20,'YTITLE',yttl01[0],/ADD_REPLACE
; => Suppress left-side Y-Axis labels
str_element,lim_20,'YSTYLE',5,/ADD_REPLACE
; => Change POSITION for each
str_element,lim_10,'POSITION',pos_0con,/ADD_REPLACE
str_element,lim_20,'POSITION',pos_1con,/ADD_REPLACE
;------------------------------------
; => For cuts of the DF
;------------------------------------
lim_11         = def_lim_1.CUTS
lim_21         = def_lim_2.CUTS
; => Change POSITION for each
str_element,lim_11,'POSITION',pos_0cut,/ADD_REPLACE
str_element,lim_21,'POSITION',pos_1cut,/ADD_REPLACE
; => Suppress left-side Y-Axis labels
str_element,lim_21,'YSTYLE',5,/ADD_REPLACE

; => Y-Title for Cuts
IF KEYWORD_SET(no_redf) THEN BEGIN
  ; => Cuts of DFs
  c_suff = suffc[0]
  str_element,lim_11,'YTITLE',dumbytc[0],/ADD_REPLACE
  str_element,lim_21,'YTITLE',dumbytc[0],/ADD_REPLACE
ENDIF ELSE BEGIN
  ; => Quasi-Reduced DFs
  c_suff = suffc[1]
  str_element,lim_11,'YTITLE',dumbytr[0],/ADD_REPLACE
  str_element,lim_21,'YTITLE',dumbytr[0],/ADD_REPLACE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define rotation matrices for extra vectors
;-----------------------------------------------------------------------------------------
v_vsws      = REFORM(tad_1[0].VSW)
v_magf      = REFORM(tad_1[0].MAGF)
rot_m0      = cal_rot(v_magf,v_vsws)       ; => Rotation for 1st Contour
esw0        = -1d0*CROSSP(v_vsws,v_magf)   ; => -(Vsw x Bo) direction
nesw0       = esw0/NORM(esw0)              ; => Normalized
nvmagf      = v_magf/NORM(v_magf)          ; => Normalized
nvvsws      = v_vsws/NORM(v_vsws)          ; => Normalized
v3          = CROSSP(nvmagf,nesw0)
rot_m1      = DBLARR(3,3)                  ; => Rotation for 2nd Contour
v1          = nvmagf
v2          = nesw0
v3          = v3/NORM(v3)
; => Define new basis vectors
rot_m1[*,0] = v1
rot_m1[*,1] = v2
rot_m1[*,2] = v3
;-----------------------------------------------------------------------------------------
; => Define the 2D projection of the VSW IDL structure tag in DAT and other vectors
;-----------------------------------------------------------------------------------------
v_mfac      = (vlim[0]*95d-2)*1d-3
v_mag       = SQRT(TOTAL(tad_1.VSW^2,/NAN))
IF (FINITE(tad_1.VSW[0]) AND v_mag NE 0.0) THEN BEGIN
  vswname = '- - - : '+vname[0]+' Projection'
  vxy_pro = REFORM(rot_m0 ## v_vsws)/v_mag[0]
  vxz_pro = REFORM(rot_m1 ## v_vsws)/v_mag[0]
  vsw2d_0 = vxy_pro[0L:1L]/SQRT(TOTAL(vxy_pro[0L:1L]^2,/NAN))*v_mfac[0]
  vsw2d_1 = vxz_pro[0L:1L]/SQRT(TOTAL(vxz_pro[0L:1L]^2,/NAN))*v_mfac[0]
ENDIF ELSE BEGIN
  vswname = ''
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
vc1_col     = 250L
vc2_col     =  75L
;-----------------------------------------------------------------------------------------
; => Rotate extra vectors
;-----------------------------------------------------------------------------------------
; => 1st Contour
rot_v00     = REFORM(rot_m0 ## vec0)/NORM(vec0)
rot_v10     = REFORM(rot_m0 ## vec1)/NORM(vec1)
; => Renormalize to XY-Plane Projection
rot_v00     = rot_v00/SQRT(TOTAL(rot_v00[0L:1L]^2,/NAN))*v_mfac[0]
rot_v10     = rot_v10/SQRT(TOTAL(rot_v10[0L:1L]^2,/NAN))*v_mfac[0]
; => 2nd Contour
rot_v01     = REFORM(rot_m1 ## vec0)*v_mfac[0]
rot_v11     = REFORM(rot_m1 ## vec1)*v_mfac[0]
; => Renormalize to XY-Plane Projection
rot_v01     = rot_v01/SQRT(TOTAL(rot_v01[0L:1L]^2,/NAN))*v_mfac[0]
rot_v11     = rot_v11/SQRT(TOTAL(rot_v11[0L:1L]^2,/NAN))*v_mfac[0]
;-----------------------------------------------------------------------------------------
; => Define DFs, cut parameters, and velocity-space locations
;-----------------------------------------------------------------------------------------

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; => 1st Contour Cuts
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
df2d        = tad_1.DF2D         ; => 1st Contour Data
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
vx_grid0    = tad_1.VX2D*1d-3    ; => Gridded X-Velocities [1000 km/s]
vy_grid0    = tad_1.VY2D*1d-3    ; => Gridded Y-Velocities [1000 km/s]
vx_data0    = tad_1.VX_PTS*1d-3  ; => X-Velocities of actual data points
vy_data0    = tad_1.VY_PTS*1d-3  ; => Y-Velocities of actual data points
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; => 2nd Contour Cuts
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
df2dz       = tad_2.DF2D         ; => 2nd Contour Data
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
vx_grid1    = tad_2.VX2D*1d-3    ; => Gridded X-Velocities [1000 km/s]
vy_grid1    = tad_2.VY2D*1d-3    ; => Gridded Y-Velocities [1000 km/s]
vx_data1    = tad_2.VX_PTS*1d-3  ; => X-Velocities of actual data points
vy_data1    = tad_2.VY_PTS*1d-3  ; => Z-Velocities of actual data points

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
df2ds    = tad_1.DF_SMOOTH
df2dsz   = tad_2.DF_SMOOTH

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
PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim_10,YTICK_GET=ytick_cont1
  ; => Project locations of actual data points onto contour
  OPLOT,vx_data0,vy_data0,PSYM=8,SYMSIZE=1.0,COLOR=100
  ;---------------------------------------------------------------------------------------
  ; => Draw contours
  ;---------------------------------------------------------------------------------------
  CONTOUR,df2ds,vx_grid0,vy_grid0,_EXTRA=contstuf_1
    ; => Put a + at origin of plot
    OPLOT,[0.0,0.0],[0.0,0.0],PSYM=1,SYMSIZE=2.0
    ;-------------------------------------------------------------------------------------
    ; => Project V_sw onto contour
    ;-------------------------------------------------------------------------------------
    OPLOT,[0.0,vsw2d_0[0]],[0.0,vsw2d_0[1]],LINESTYLE=0,THICK=2
    xyposi = [-1d0*.90*vlim[0],0.90*vlim[0]]*1d-3
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
PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim_11,YTICK_GET=ytick_cut1
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
  fmin       = lim_11.YRANGE[0]
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
    yras   = lim_11.YRANGE
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
PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim_20
  ;---------------------------------------------------------------------------------------
  ; => Plot Y-Axes with labels on right-hand side
  ;---------------------------------------------------------------------------------------
  AXIS,YAXIS=0,YTICKNAME=REPLICATE(' ',N_ELEMENTS(ytick_cont1)),YSTYLE=1,$
       YMINOR=lim_20.YMINOR,YRANGE=lim_20.YRANGE,YLOG=lim_20.YLOG
    ; => Put labels on right-hand side
  AXIS,YAXIS=1,YTICKV=ytick_cont1,YSTYLE=1,YTITLE=lim_20.YTITLE,$
       YMINOR=lim_20.YMINOR,YRANGE=lim_20.YRANGE,YLOG=lim_20.YLOG
  ; => Project locations of actual data points onto contour
  OPLOT,vx_data1,vy_data1,PSYM=8,SYMSIZE=1.0,COLOR=100
  ;---------------------------------------------------------------------------------------
  ; => Draw contours
  ;---------------------------------------------------------------------------------------
  CONTOUR,df2dsz,vx_grid1,vy_grid1,_EXTRA=contstuf_2
    ; => Put a + at origin of plot
    OPLOT,[0.0,0.0],[0.0,0.0],PSYM=1,SYMSIZE=2.0
    ;-------------------------------------------------------------------------------------
    ; => Project V_sw onto contour
    ;-------------------------------------------------------------------------------------
    IF (dname[0] EQ 'x') THEN vsw_col = 255 ELSE vsw_col = 0
    OPLOT,[0.0,vsw2d_1[0]],[0.0,vsw2d_1[1]],LINESTYLE=0,COLOR=vsw_col[0]
    xyposi = [-1d0*.90*vlim[0],0.90*vlim[0]]*1d-3
    IF (TOTAL(FINITE(v_vsws)) EQ 3) THEN BEGIN
      ; => Prevent Vsw Label from attaching itself to axes
      OPLOT,[0.0,0.0],[0.0,0.0],PSYM=3,COLOR=vsw_col[0]
;      XYOUTS,xyposi[0],xyposi[1],'-',/DATA,COLOR=vsw_col[0]
      ; => Output Vsw Label
      XYOUTS,xyposi[0],xyposi[1],vswname[0],/DATA,COLOR=vsw_col[0]
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
lim_33    = lim_21
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
  AXIS,YAXIS=1,YTICKV=ytick_cut1,YSTYLE=1,YTITLE=lim_21.YTITLE,$
       YMINOR=lim_21.YMINOR,YRANGE=lim_21.YRANGE,YLOG=lim_21.YLOG
  ;---------------------------------------------------------------------------------------
  ; => Determine where to put labels
  ;---------------------------------------------------------------------------------------
  fmin       = lim_21.YRANGE[0]
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
    yras   = lim_21.YRANGE
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
IF (dname[0] EQ 'x') THEN xpos = 0.950 ELSE xpos = 0.990
XYOUTS,xpos[0],0.06,version[0],CHARSIZE=.55,/NORMAL,ORIENTATION=90.

;-----------------------------------------------------------------------------------------
; => Return
;-----------------------------------------------------------------------------------------

RETURN
END