;+
;*****************************************************************************************
;
;  FUNCTION :   my_ph_cont2d.pro
;  PURPOSE  :   Produces a contour plot of the distribution function (DF) with parallel
;                 and perpendicular cuts shown.  The program is specifically for Pesa
;                 High(Burst) data structures, NOT Eesa data.  {Though I imagine it
;                 could be easily altered to accomodate such structures.}
;
;  CALLED BY:   NA
;
;  CALLS:
;               str_element.pro
;               extract_tags.pro
;               add_df2d_to_ph.pro
;               contour_3dp_plot_limits.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT      :  3DP data structure either from spec plots 
;                             (i.e. get_padspec.pro) or from pad.pro, get_el.pro, 
;                             get_sf.pro, etc.
;
;  EXAMPLES:
;               to  = time_double('1996-04-03/09:47:00')
;               dat = get_phb(to)
;               str_element,dat,'VSW',REPLICATE(!VALUES.F_NAN,3),/ADD_REPLACE
;               add_magf2,dat,'wi_B3(GSE)'
;               add_vsw2,dat,'V_sw2'
;               ....................................
;               :  Plot in solar wind rest frame   :
;               ....................................
;               my_ph_cont2d,dat,VLIM=6d4,NGRID=20,/SM_CUTS,NSMOOTH=5
;
;  KEYWORDS:  
;               VLIM     :  Limit for x-y velocity axes over which to plot data
;                             [Default = max vel. from energy bin values]
;               NGRID    :  # of isotropic velocity grids to use to triangulate the data
;                             [Default = 20L]
;               NNORM    :  3-Element unit vector for shock normal direction
;               EX_VEC   :  3-Element unit vector for another quantity like heat flux or 
;                             a wave vector
;               EX_VN    :  A string name associated with EX_VEC
;               SM_CUTS  :  If set, program plots the smoothed cuts of the DF
;                             [Note:  Smoothed to the minimum # of points]
;               DFMIN    :  Set to a scalar value defining the lower limit on the DF 
;                             you wish to plot (s^3/km^3/cm^3)
;                             [Default = 1e-14 (for PH)]
;
;   CHANGED:  1)  Changed plot output slightly               [04/14/2009   v1.0.1]
;             2)  Added keywords:  EX_VEC and EX_VN          [04/14/2009   v1.0.2]
;             3)  Changed plot range for cuts                [04/16/2009   v1.0.3]
;             4)  Fixed issue when null distribution cuts occur
;                                                            [05/27/2009   v1.0.4]
;             5)  Changed plot range for cuts                [06/21/2009   v1.0.5]
;             6)  Added program:  contour_3dp_plot_limits.pro
;                                                            [06/24/2009   v1.1.0]
;             7)  Added keyword:  SM_CUTS                    [06/24/2009   v1.1.1]
;             8)  Fixed syntax error                         [07/13/2009   v1.1.2]
;             9)  Added keyword:  DFMIN                      [07/13/2009   v1.1.3]
;            10)  Added a commented out section to alter the distributions if the UV
;                   contamination is too strong to observe useful aspects of the
;                   distribution cuts                        [08/07/2009   v1.1.4]
;            11)  Updated man page and Added keyword:  NSMOOTH
;                                                            [08/27/2009   v1.2.0]
;            12)  Changed plot labels to 1000 km/s           [08/28/2009   v1.2.1]
;
;   CREATED:  04/08/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/28/2009   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO my_ph_cont2d,dat,VLIM=vlim,NGRID=ngrid,NNORM=nnorm,EX_VEC=ex_vec,EX_VN=ex_vn,$
                     SM_CUTS=sm_cuts,DFMIN=dfmin

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
f        = !VALUES.F_NAN
d        = !VALUES.D_NAN

IF NOT KEYWORD_SET(ngrid) THEN ngrid = 20L ; => # of levels to use for contour.pro
IF NOT KEYWORD_SET(vlim) THEN BEGIN
  vlim = MAX(SQRT(2*dat.ENERGY/dat.MASS),/NAN)  ; => velocity limit (km/s)
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)  ; => velocity limit (km/s)
ENDELSE
;-----------------------------------------------------------------------------------------
; => Get shock normal direction
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(nnorm) THEN gnorm = FLOAT(nnorm) ELSE gnorm = REPLICATE(f,3)
;-----------------------------------------------------------------------------------------
; => Calculate distribution function and convert into solar wind frame
;-----------------------------------------------------------------------------------------
add_df2d_to_ph,dat,VLIM=vlim,NGRID=ngrid,VBROT=test_n
;-----------------------------------------------------------------------------------------
; => Define plot parameters
;-----------------------------------------------------------------------------------------
def_lim   = contour_3dp_plot_limits(dat,VLIM=vlim,NGRID=ngrid,DFMIN=dfmin)
lim1      = def_lim.PLOT_LIMS  ; => For initial empty plot
contstuff = def_lim.CONT       ; => For contour plot
lim2      = def_lim.CUTS       ; => For cuts of the DF


; => Define the 2D projection of the solar wind velocity for reference on contour
vsw2d = [dat.VxB_2D[0L],dat.VxB_2D[1L]]/(SQRT(TOTAL(dat.VxB_2D^2,/NAN)))*(vlim*95d-2*1d-3)
; => Define the 2D projection of the shock normal " "
ph_n   = REFORM(test_n ## gnorm)*(vlim*95d-2*1d-3)
ph_n  *= (vlim*95d-2*1d-3)/ SQRT(TOTAL(ph_n[0L:1L]^2,/NAN))

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
  dfpara   = dat.DF_PARA                          ; => Parallel cut
  dfperp   = dat.DF_PERP                          ; => Perpendicular cut
ENDIF ELSE BEGIN
  dfpara   = SMOOTH(dat.DF_PARA,3L,/EDGE_TRUNCATE,/NAN)
  dfperp   = SMOOTH(dat.DF_PERP,3L,/EDGE_TRUNCATE,/NAN)
ENDELSE
;-----------------------------------------------------------------------------------------
;bad =  WHERE(dfpara GE 1e-10,bd)
;IF (bd GT 0L) THEN dfpara[bad] = f
;bad =  WHERE(dfperp GE 1e-10,bd)
;IF (bd GT 0L) THEN dfperp[bad] = f
;dfpara   = SMOOTH(dat.DF_PARA,3L,/EDGE_TRUNCATE,/NAN)
;dfperp   = SMOOTH(dat.DF_PERP,3L,/EDGE_TRUNCATE,/NAN)
;gdfmax   = MAX(ABS([dfpara,dfperp]),/NAN)
;yra      = [1e-13,gdfmax]
;str_element,lim2,'YRANGE',yra,/ADD_REPLACE
;-----------------------------------------------------------------------------------------
g_para   = WHERE(dfpara GT 0d0,g_p,COMPLEMENT=b_para,NCOMPLEMENT=b_p)
n_para   = N_ELEMENTS(dfpara)

!P.MULTI = [0,1,2]
; => Defined user symbol for outputing locations of data on contour
xxo = FINDGEN(17)*(!PI*2./16.)
USERSYM,0.2*COS(xxo),0.2*SIN(xxo),/FILL
;-----------------------------------------------------------------------------------------
; => Plot data
;-----------------------------------------------------------------------------------------
; => Plot Contour of 2D DF
PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim1
  CONTOUR, dat.DF_SMOOTH,dat.VX2D*1d-3,dat.VY2D*1d-3,_EXTRA=contstuff
    OPLOT,[0.0,vsw2d[0]],[0.0,vsw2d[1]],LINESTYLE=0
    OPLOT,[0.0,ph_n[0]],[0.0,ph_n[1]],LINESTYLE=2,COLOR=250
    OPLOT,[0.0,ph_k[0]],[0.0,ph_k[1]],LINESTYLE=4,COLOR=50,THICK=2
    OPLOT,dat.VX_PTS*1d-3,dat.VY_PTS*1d-3,PSYM=8,SYMSIZE=1.0,COLOR=100
    XYOUTS,-24d-1,23.5d-1,'- - - : Shock Normal Direction',/DATA,COLOR=250
    XYOUTS,-24d-1,21.5d-1,'- - - : Solar Wind Direction',/DATA
    XYOUTS,-24d-1,19.5d-1,kname,/DATA,COLOR=50
; => Plot cuts of DF
IF (b_p LT n_para) THEN BEGIN
  PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim2
    OPLOT,dat.VX2D*1d-3,dfpara,COLOR=250,PSYM=1
    OPLOT,dat.VY2D*1d-3,dfperp,COLOR=50,PSYM=2
    OPLOT,dat.VX2D*1d-3,dfpara,COLOR=250
    OPLOT,dat.VY2D*1d-3,dfperp,COLOR=50
    fmin = lim2.YRANGE[0]
    XYOUTS,-1.,fmin*2e0,'+++ : Parallel Cut',/DATA,COLOR=250
    XYOUTS,-1.,fmin*1.5e0,'*** : Perpendicular Cut',COLOR=50,/DATA
ENDIF ELSE BEGIN
  PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim2
ENDELSE

RETURN
END