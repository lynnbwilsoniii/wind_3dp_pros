;+
;*****************************************************************************************
;
;  FUNCTION :   eh_cont3d.pro
;  PURPOSE  :   Produces a contour plot of the distribution function (DF) with parallel
;                 and perpendicular cuts shown.  The program is specifically for Eesa
;                 High(Burst) data structures.  {Though I imagine it could be easily
;                 altered to accomodate such structures.}  The contour plot does NOT
;                 assume gyrotropy, so the features in the DF may illustrate 
;                 anisotropies more easily.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               time_string.pro
;               str_element.pro
;               extract_tags.pro
;               add_df2d_to_ph.pro
;               contour_3dp_plot_limits.pro
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
;               to      = time_double('1996-04-03/09:47:00')
;               dat     = get_eh(to)
;               str_element,dat,'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
;               add_magf2,dat,'wi_B3(GSE)'
;               ehm     = moments_3d(dat)
;               dat.VSW = ehm.VELOCITY
;               ..................................
;               :  Plot in electron rest frame   :
;               ..................................
;               eh_cont3d,dat,VLIM=6d4,NGRID=20,/SM_CUTS,NSMOOTH=5
;
;  KEYWORDS:    
;               VLIM       :  Limit for x-y velocity axes over which to plot data
;                               [Default = max vel. from energy bin values]
;               NGRID      :  # of isotropic velocity grids to use to triangulate the data
;                               [Default = 30L]
;               NNORM      :  3-Element unit vector for shock normal direction
;               EX_VEC     :  3-Element unit vector for another quantity like heat flux or 
;                               a wave vector
;               EX_VN      :  A string name associated with EX_VEC
;               SM_CUTS    :  If set, program plots the smoothed cuts of the DF
;                               [Note:  Smoothed to the minimum # of points]
;               DFMIN      :  Set to a scalar value defining the lower limit on the DF 
;                               you wish to plot (s^3/km^3/cm^3)
;                               [Default = 1e-14 (for PH)]
;               NSMOOTH    :  Scalar # of points over which to smooth the DF
;                               [Default = 3]
;               ONE_C      :  If set, program makes a copy of the input array, redefines
;                               the data points equal to 1.0, and then calculates the 
;                               parallel cut and overplots it as the One Count Level
;               DFRA       :  2-Element array specifying a DF range (s^3/km^3/cm^3) for the
;                               cuts of the contour plot
;               CUT_YLIM   :  2-Element array specifying the Y-Axis range for the
;                               parallel/perpendicular cuts plot
;               NDAT       :  Set to a named variable to return the altered data structure
;                               returned by add_df2d_to_ph.pro
;               MAGNETO    :  If set, tells contour_3dp_plot_limits.pro that the data
;                               was taken in the magnetosphere, thus to alter the upper
;                               and lower limits on the distributions
;               VXB_PLANE  :  If set, tells program to plot the DF in the plane defined
;                               by the (V x B) and B x (V x B) directions
;                               [Default:  plane defined by V and B directions set by
;                                           VSW and MAGF structure tags of DAT]
;               VCIRC      :  Scalar or array defining the value(s) to plot as a
;                               circle(s) of constant speed [km/s] on the contour
;                               plot [e.g. gyrospeed of specularly reflected ion]
;               NOKILL_PH  :  If set, data_velocity_transform.pro will not call
;                               pesa_high_bad_bins.pro
;               NO_REDF    :  If set, program will plot only cuts of the distribution,
;                               not quasi-reduced distributions
;                               [Default:  program plots quasi-reduced distributions]
;
;   CHANGED:  1)  Changed plot labels to 1000 km/s              [08/28/2009   v1.0.1]
;             2)  Changed size of usersym output                [08/31/2009   v1.0.2]
;             3)  Added keyword:  ONE_C                         [08/31/2009   v1.1.0]
;             4)  Added keyword:  DFRA and CUT_YLIM             [09/23/2009   v1.2.0]
;             5)  Added keyword:  NDAT                          [09/23/2009   v1.3.0]
;             6)  Updated man page                              [10/14/2009   v1.4.0]
;             7)  Added keyword:  MAGNETO                       [12/10/2009   v1.5.0]
;             8)  Added some error handling if bad data structure passed to program
;                                                               [02/25/2010   v1.6.0]
;             9)  Added keyword:  VXB_PLANE and VCIRC           [03/03/2010   v1.7.0]
;            10)  Changed usage of DFRA keyword                 [09/16/2010   v1.7.1]
;            11)  Changed order of plotting so that the small blue dots are below
;                   contours                                    [05/20/2011   v1.7.2]
;            12)  Changed color of the projection of shock plane onto the contour
;                   plot                                        [10/15/2011   v1.7.3]
;            13)  Added version number to output plot           [01/11/2012   v1.7.4]
;            14)  Added keyword:  NOKILL_PH                     [01/13/2012   v1.8.0]
;            15)  Added keyword:  NO_REDF                       [01/27/2012   v1.9.0]
;            16)  VCIRC keyword can now handle array inputs     [01/27/2012   v1.9.1]
;
;   NOTES:      
;               1)  Make sure that the structure tags MAGF and VSW have finite 
;                    values
;
;   CREATED:  08/27/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/27/2012   v1.9.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO eh_cont3d,dat,VLIM=vlim,NGRID=ngrid,NNORM=nnorm,EX_VEC=ex_vec,EX_VN=ex_vn,$
                  SM_CUTS=sm_cuts,DFMIN=dfmin,NSMOOTH=nsmooth,ONE_C=one_c,    $
                  DFRA=dfra,CUT_YLIM=cut_ylim,NDAT=ndat,MAGNETO=magneto,      $
                  VXB_PLANE=vxbplane,VCIRC=vcirc,NOKILL_PH=nokill_ph,         $
                  NO_REDF=no_redf

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
version  = 'eh_cont3d.pro :  01/27/2012 v1.9.1, output at: '
version  = version[0]+time_string(SYSTIME(1,/SECONDS),PREC=3)

f        = !VALUES.F_NAN
d        = !VALUES.D_NAN
dumbytr  = 'quasi-reduced df (sec!U3!N/km!U3!N/cm!U3!N)'
dumbytc  = 'cuts of df (sec!U3!N/km!U3!N/cm!U3!N)'
suffc    = [' Cut',' Reduced DF']

IF NOT KEYWORD_SET(ngrid) THEN ngrid = 30L ; => # of levels to use for contour.pro
IF NOT KEYWORD_SET(vlim) THEN BEGIN
  vlim = MAX(SQRT(2*dat.ENERGY/dat.MASS),/NAN)  ; => velocity limit (km/s)
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)  ; => velocity limit (km/s)
ENDELSE

IF KEYWORD_SET(one_c) THEN BEGIN
  onec      = dat
  IF (SIZE(onec,/TYPE) EQ 8) THEN BEGIN
    onec.DATA = 1.0
    add_df2d_to_ph,onec,VLIM=vlim,NGRID=ngrid,VBROT=test_n,NSMOOTH=ns,$
                        NOKILL_PH=nokill_ph,NO_REDF=no_redf
  ENDIF
ENDIF

IF KEYWORD_SET(vxbplane) THEN vxbp = 1 ELSE vxbp = 0
;-----------------------------------------------------------------------------------------
; => Get shock normal direction (if relevant)
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(nnorm) THEN gnorm = FLOAT(nnorm) ELSE gnorm = REPLICATE(f,3)
;-----------------------------------------------------------------------------------------
; => Calculate distribution function and convert into solar wind frame
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(nsmooth) THEN ns = 3 ELSE ns = LONG(nsmooth)
tad = dat
add_df2d_to_ph,tad,VLIM=vlim,NGRID=ngrid,VBROT=test_n,NSMOOTH=ns,$
                   VXB_PLANE=vxbp,NOKILL_PH=nokill_ph,NO_REDF=no_redf
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
; => Define plot parameters
;-----------------------------------------------------------------------------------------
def_lim   = contour_3dp_plot_limits(tad,VLIM=vlim,NGRID=ngrid,DFMIN=dfmin,$
                                    DFRA=dfra,MAGNETO=magneto)
lim1      = def_lim.PLOT_LIMS  ; => For initial empty plot
contstuff = def_lim.CONT       ; => For contour plot
lim2      = def_lim.CUTS       ; => For cuts of the DF

; => Define the 2D projection of the solar wind velocity for reference on contour
v_mfac = (vlim*95d-2)*1d-3
v_mag  = SQRT(TOTAL(tad.VSW^2,/NAN))
IF (FINITE(tad.VSW[0]) AND v_mag NE 0.0) THEN BEGIN
  vswname = '- - - : Solar Wind Direction'
  vsw2d   = [tad.VxB_2D[0L],tad.VxB_2D[1L]]/v_mag*v_mfac
ENDIF ELSE BEGIN
  vswname = ''
  vsw2d   = REPLICATE(f,2)
ENDELSE

; => Check axes titles
IF KEYWORD_SET(vxbplane) THEN BEGIN
  str_element,lim1,'XTITLE','(V x B)  [1000 km/sec]',/ADD_REPLACE
  str_element,lim1,'YTITLE','B x (V x B)  [1000 km/sec]',/ADD_REPLACE
ENDIF
; => Y-Title for Cuts
IF KEYWORD_SET(no_redf) THEN BEGIN
  ; => Cuts of DFs
  c_suff = suffc[0]
  str_element,lim2,'YTITLE',dumbytc[0],/ADD_REPLACE
ENDIF ELSE BEGIN
  ; => Quasi-Reduced DFs
  c_suff = suffc[1]
  str_element,lim2,'YTITLE',dumbytr[0],/ADD_REPLACE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define the 2D projection of the shock normal and other vectors if desired
;-----------------------------------------------------------------------------------------
ph_n   = REFORM(test_n ## gnorm)*(vlim*95d-2*1d-3)
ph_n  *= (vlim*95d-2*1d-3)/ SQRT(TOTAL(ph_n[0L:1L]^2,/NAN))
IF (FINITE(gnorm[0])) THEN BEGIN
  IF NOT KEYWORD_SET(gnorm) THEN shname = '' ELSE shname = '- - - : Shock Normal Direction'
ENDIF ELSE BEGIN
  shname = ''
ENDELSE

IF NOT KEYWORD_SET(ex_vec) THEN kvec = REPLICATE(f,3) ELSE kvec = FLOAT(REFORM(ex_vec))
ph_k   = REFORM(test_n ## kvec)*(vlim*95d-2*1d-3)
ph_k  *= (vlim*95d-2*1d-3)/ SQRT(TOTAL(ph_k[0L:1L]^2,/NAN))  ; => Renormalize XY Projection
IF (FINITE(kvec[0])) THEN BEGIN
  IF NOT KEYWORD_SET(ex_vn) THEN kname = '' ELSE kname = STRTRIM(ex_vn,2L)
ENDIF ELSE BEGIN
  kname = ''
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define DF cut parameters
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(sm_cuts) THEN BEGIN
  dfpara   = tad.DF_PARA                          ; => Parallel cut
  dfperp   = tad.DF_PERP                          ; => Perpendicular cut
ENDIF ELSE BEGIN
  dfpara   = SMOOTH(tad.DF_PARA,3L,/EDGE_TRUNCATE,/NAN)
  dfperp   = SMOOTH(tad.DF_PERP,3L,/EDGE_TRUNCATE,/NAN)
ENDELSE
g_para   = WHERE(dfpara GT 0d0,g_p,COMPLEMENT=b_para,NCOMPLEMENT=b_p)
n_para   = N_ELEMENTS(dfpara)
; => Check Y-Axis limits on cuts plot
IF KEYWORD_SET(cut_ylim) THEN str_element,lim2,'YRANGE',REFORM(cut_ylim),/ADD_REPLACE

!P.MULTI = [0,1,2]
; => Defined user symbol for outputing locations of data on contour
xxo = FINDGEN(17)*(!PI*2./16.)
USERSYM,0.25*COS(xxo),0.25*SIN(xxo),/FILL
;-----------------------------------------------------------------------------------------
; => Plot data
;-----------------------------------------------------------------------------------------
; => Plot Contour of 2D DF
PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim1
  ; => Project locations of actual data points onto contour
  OPLOT,tad.VX_PTS*1d-3,tad.VY_PTS*1d-3,PSYM=8,SYMSIZE=1.0,COLOR=100
  ; => Draw contours
  CONTOUR, tad.DF_SMOOTH,tad.VX2D*1d-3,tad.VY2D*1d-3,_EXTRA=contstuff
    ; => Project V_sw onto contour
    OPLOT,[0.0,vsw2d[0]],[0.0,vsw2d[1]],LINESTYLE=0
    ; => Project shock normal vector onto contour
    OPLOT,[0.0,ph_n[0]],[0.0,ph_n[1]],LINESTYLE=2,COLOR=250
    ; => Project shock plane onto contour
    ph_n2 = REFORM(eulermat(0d0,9d1,0d0,DEG=1) ## ph_n)
    OPLOT,[0.0,ph_n2[0]],[0.0,ph_n2[1]],COLOR= 30,THICK=2
    OPLOT,-1d0*[0.0,ph_n2[0]],-1d0*[0.0,ph_n2[1]],COLOR= 30,THICK=2
    ; => Project extra vector onto contour
    OPLOT,[0.0,ph_k[0]],[0.0,ph_k[1]],LINESTYLE=4,COLOR= 50,THICK=2
    xyposi = [-1d0*.94*vlim,0.94*vlim]*1d-3
    ; => Write out names of projected lines
    XYOUTS,xyposi[0],xyposi[1],shname,/DATA,COLOR=250
    xyposi[1] -= 0.08*vlim*1d-3
    XYOUTS,xyposi[0],xyposi[1],vswname,/DATA
    xyposi[1] -= 0.08*vlim*1d-3
    XYOUTS,xyposi[0],xyposi[1],kname,/DATA,COLOR= 50
    ; => Project circle of constant speed onto contour
    IF KEYWORD_SET(vcirc) THEN BEGIN
      n_circ = N_ELEMENTS(vcirc)
      thetas = DINDGEN(500)*2d0*!DPI/499L
      FOR j=0L, n_circ - 1L DO BEGIN
        vxcirc = vcirc[j]*1d-3*COS(thetas)
        vycirc = vcirc[j]*1d-3*SIN(thetas)
        OPLOT,vxcirc,vycirc,LINESTYLE=2,THICK=2
      ENDFOR
    ENDIF
; => Plot reduced DF (or cuts of the DF if NO_REDF set)
IF (b_p LT n_para) THEN BEGIN
  PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim2
    OPLOT,tad.VX2D*1d-3,dfpara,COLOR=250,PSYM=1
    OPLOT,tad.VY2D*1d-3,dfperp,COLOR=50,PSYM=2
    OPLOT,tad.VX2D*1d-3,dfpara,COLOR=250
    OPLOT,tad.VY2D*1d-3,dfperp,COLOR=50
    fmin = lim2.YRANGE[0]
    xyposi = [-1d0*4e-1*vlim*1d-3,fmin*4e0]
    XYOUTS,xyposi[0],xyposi[1],'+++ : Parallel'+c_suff[0],/DATA,COLOR=250
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],'*** : Perpendicular'+c_suff[0],COLOR=50,/DATA
    IF KEYWORD_SET(one_c) THEN BEGIN
      ocpara   = SMOOTH(onec.DF_PARA,3L,/EDGE_TRUNCATE,/NAN)
      OPLOT,onec.VX2D*1d-3,ocpara,COLOR=150,LINESTYLE=4
      xyposi[1] *= 0.7
      XYOUTS,xyposi[0],xyposi[1],'- - - : One-Count Level',COLOR=150,/DATA
    ENDIF
    IF KEYWORD_SET(vcirc) THEN BEGIN
      n_circ = N_ELEMENTS(vcirc)
      yras   = lim2.YRANGE
      FOR j=0L, n_circ - 1L DO BEGIN
        OPLOT,[vcirc[j]*1d-3,vcirc[j]*1d-3],yras,LINESTYLE=2,THICK=2
        OPLOT,-1d0*[vcirc[j]*1d-3,vcirc[j]*1d-3],yras,LINESTYLE=2,THICK=2
      ENDFOR
    ENDIF
ENDIF ELSE BEGIN
  PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim2
ENDELSE
;-----------------------------------------------------------------------------------------
; => Output version # and date produced
;-----------------------------------------------------------------------------------------
XYOUTS,0.785,0.06,version[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.

;-----------------------------------------------------------------------------------------
; => Return
;-----------------------------------------------------------------------------------------
!P.MULTI = 0
RETURN
END

