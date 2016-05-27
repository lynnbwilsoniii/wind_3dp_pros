;+
;*****************************************************************************************
;
;  FUNCTION :   contours_4planes.pro
;  PURPOSE  :   Plots contours of constant phase space density in four different planes
;                 with relevant parameters projected onto each plane.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               dat_3dp_str_names.pro
;               my_crossp_2.pro
;               cal_rot.pro
;               data_velocity_transform.pro
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
;               NA
;
;  KEYWORDS:    
;               VLIM       :  Limit for x-y velocity axes over which to plot data
;                               [Default = max vel. from energy bin values]
;               NGRID      :  # of isotropic velocity grids to use to triangulate the
;                               data [Default = 30L]
;               NNORM      :  3-Element unit vector for shock normal direction
;                               [Default = anti-sun direction]
;               DFRA       :  2-Element array specifying a DF range (s^3/km^3/cm^3) for
;                               the cuts of the contour plot
;               VCIRC      :  Scalar value to plot as a circle of constant speed on the
;                               contour plot (km/s) [gyrospeed is useful]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The planes are defined as:
;                     Plane #  :  {      X   ,      Y    }
;                    ======================================
;                     Plane 1  :  {      B   , (Esw x B) }
;                     Plane 2  :  { (Vsw x B), (Esw x B) }
;                     Plane 3  :  { (Vsw x B),      B    }
;                     Plane 4  :  {  (n x B) , (Esw x n) }
;
;                     Esw = -(Vsw x B) = (B x Vsw)
;                      n  = shock normal vector
;                      B  = magnetic field vector
;                     Vsw = solar wind velocity vector
;
;   CREATED:  09/26/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/26/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO contours_4planes,dat,VLIM=vlim,NGRID=ngrid,NNORM=nnorm,DFRA=dfra,VCIRC=vcirc

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
f        = !VALUES.F_NAN
d        = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (SIZE(dat,/TYPE) NE 8) THEN RETURN
; => Make sure MAGF and VSW tag values are finite
vsw      = dat.VSW    ; => Vsw [km/s]
magf     = dat.MAGF   ; => B-field [nT]
check    = (TOTAL(FINITE(vsw)) NE 3) OR (TOTAL(FINITE(magf)) NE 3)
IF (check) THEN RETURN

strnms   = dat_3dp_str_names(dat)
sn_0     = strnms.SN              ; => e.g. 'phb'
lc_0     = strnms.LC              ; => e.g. 'Pesa High Burst'
;-----------------------------------------------------------------------------------------
; => Check keywords
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(ngrid) THEN ngrid = 30L ; => # of levels to use for contour.pro
IF NOT KEYWORD_SET(vlim) THEN BEGIN
  vlim = MAX(SQRT(2*dat.ENERGY/dat.MASS),/NAN)  ; => velocity limit (km/s)
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)  ; => velocity limit (km/s)
ENDELSE

IF KEYWORD_SET(nnorm) THEN gnorm = DOUBLE(nnorm) ELSE gnorm = [-1d0,0d0,0d0]
gnorm = gnorm/NORM(gnorm)
;-----------------------------------------------------------------------------------------
; => Calculate relevant vectors
;-----------------------------------------------------------------------------------------
vmag    = NORM(vsw)
bmag    = NORM(magf)
; => Calculate (Vsw x B)
v_x_b   = my_crossp_2(vsw,magf,/NOMSSG)/(vmag[0]*bmag[0])
v_x_b   = v_x_b/NORM(v_x_b)      ; => renormalize
; => Calculate B x (Vsw x B)
b_x_vxb = my_crossp_2(magf/bmag[0],v_x_b,/NOMSSG)
b_x_vxb = b_x_vxb/NORM(b_x_vxb)  ; => renormalize
; => Calculate (n x B)
n_x_b   = my_crossp_2(gnorm,magf/bmag[0],/NOMSSG)
n_x_b   = n_x_b/NORM(n_x_b)      ; => renormalize
; => Calculate n x (Vsw x B)
n_x_vxb = my_crossp_2(gnorm,v_x_b,/NOMSSG)
n_x_vxb = n_x_vxb/NORM(n_x_vxb)  ; => renormalize
;-----------------------------------------------------------------------------------------
; => Calculate relevant rotation matrices
;-----------------------------------------------------------------------------------------
; => Plane 1
mrot_1  = cal_rot(magf,vsw)
; => Plane 2
mrot_2  = cal_rot(v_x_b,b_x_vxb)
; => Plane 3
mrot_3  = cal_rot(v_x_b,magf/bmag[0])
; => Plane 4
mrot_4  = cal_rot(n_x_b,n_x_vxb)
;-----------------------------------------------------------------------------------------
; => Calculate projections of relevant vectors
;-----------------------------------------------------------------------------------------
v_mfac  = (vlim*95d-2)*1d-3

vsw_pr1 = REFORM(mrot_1 ## vsw)*v_mfac[0]/vmag[0]
vsw_pr2 = REFORM(mrot_2 ## vsw)*v_mfac[0]/vmag[0]
vsw_pr3 = REFORM(mrot_3 ## vsw)*v_mfac[0]/vmag[0]
vsw_pr4 = REFORM(mrot_4 ## vsw)*v_mfac[0]/vmag[0]
vswname = '----- : Solar Wind Direction'

magfpr3 = REFORM(mrot_3 ## magf)*v_mfac[0]/bmag[0]
magfpr4 = REFORM(mrot_4 ## magf)*v_mfac[0]/bmag[0]

nor_pr1 = REFORM(mrot_1 ## gnorm)
nor_pr1 = nor_pr1*v_mfac[0]/SQRT(TOTAL(nor_pr1[0:1]^2,/NAN))
nor_pr2 = REFORM(mrot_2 ## gnorm)
nor_pr2 = nor_pr2*v_mfac[0]/SQRT(TOTAL(nor_pr2[0:1]^2,/NAN))
nor_pr3 = REFORM(mrot_3 ## gnorm)
nor_pr3 = nor_pr3*v_mfac[0]/SQRT(TOTAL(nor_pr3[0:1]^2,/NAN))
nor_pr4 = REFORM(mrot_4 ## gnorm)
nor_pr4 = nor_pr4*v_mfac[0]/SQRT(TOTAL(nor_pr4[0:1]^2,/NAN))
shname  = '- - - : Shock Normal Direction'
;-----------------------------------------------------------------------------------------
; => Calculate distribution function and convert into solar wind frame
;-----------------------------------------------------------------------------------------
tad_1   = dat
plane1  = data_velocity_transform(tad_1,VLIM=vlim,NGRID=ngrid,ROT_MAT=mrot_1,NSMOOTH=3L)

tad_2   = dat
plane2  = data_velocity_transform(tad_2,VLIM=vlim,NGRID=ngrid,ROT_MAT=mrot_2,NSMOOTH=3L)

tad_3   = dat
plane3  = data_velocity_transform(tad_3,VLIM=vlim,NGRID=ngrid,ROT_MAT=mrot_3,NSMOOTH=3L)

tad_4   = dat
plane4  = data_velocity_transform(tad_4,VLIM=vlim,NGRID=ngrid,ROT_MAT=mrot_4,NSMOOTH=3L)
;-----------------------------------------------------------------------------------------
; => Define plot parameters
;-----------------------------------------------------------------------------------------
def_l1   = contour_3dp_plot_limits(plane1,VLIM=vlim,NGRID=ngrid,DFRA=dfra)
def_l2   = contour_3dp_plot_limits(plane2,VLIM=vlim,NGRID=ngrid,DFRA=dfra)
def_l3   = contour_3dp_plot_limits(plane3,VLIM=vlim,NGRID=ngrid,DFRA=dfra)
def_l4   = contour_3dp_plot_limits(plane4,VLIM=vlim,NGRID=ngrid,DFRA=dfra)

lim1     = def_l1.PLOT_LIMS  ; => For initial empty plot
contlim1 = def_l1.CONT       ; => For contour plot
lim2     = def_l2.PLOT_LIMS  ; => For initial empty plot
contlim2 = def_l2.CONT       ; => For contour plot
lim3     = def_l3.PLOT_LIMS  ; => For initial empty plot
contlim3 = def_l3.CONT       ; => For contour plot
lim4     = def_l4.PLOT_LIMS  ; => For initial empty plot
contlim4 = def_l4.CONT       ; => For contour plot
; => Define new plot titles
ttle     = lim1.TITLE
gposi    = STRPOS(ttle,'!C')
ttln     = STRMID(ttle,gposi[0]+2L)     ; => e.g. '1998-08-26/06:40:24 - 06:40:27'

; => force all to be on the same contour range
mxc1     = MAX(ABS(contlim1.LEVELS),/NAN)
mxc2     = MAX(ABS(contlim2.LEVELS),/NAN)
mxc3     = MAX(ABS(contlim3.LEVELS),/NAN)
mxc4     = MAX(ABS(contlim4.LEVELS),/NAN)
mxcs     = MAX([mxc1,mxc2,mxc3,mxc4],/NAN,lx)
CASE lx OF
  0 : BEGIN
    gcont = contlim1
    glevs = gcont.LEVELS
    gcols = gcont.C_COLORS
    str_element,contlim2,'LEVELS',glevs,/ADD_REPLACE
    str_element,contlim3,'LEVELS',glevs,/ADD_REPLACE
    str_element,contlim4,'LEVELS',glevs,/ADD_REPLACE
    str_element,contlim2,'C_COLORS',gcols,/ADD_REPLACE
    str_element,contlim3,'C_COLORS',gcols,/ADD_REPLACE
    str_element,contlim4,'C_COLORS',gcols,/ADD_REPLACE
  END
  1 : BEGIN
    gcont = contlim2
    glevs = gcont.LEVELS
    gcols = gcont.C_COLORS
    str_element,contlim1,'LEVELS',glevs,/ADD_REPLACE
    str_element,contlim3,'LEVELS',glevs,/ADD_REPLACE
    str_element,contlim4,'LEVELS',glevs,/ADD_REPLACE
    str_element,contlim1,'C_COLORS',gcols,/ADD_REPLACE
    str_element,contlim3,'C_COLORS',gcols,/ADD_REPLACE
    str_element,contlim4,'C_COLORS',gcols,/ADD_REPLACE
  END
  2 : BEGIN
    gcont = contlim3
    glevs = gcont.LEVELS
    gcols = gcont.C_COLORS
    str_element,contlim1,'LEVELS',glevs,/ADD_REPLACE
    str_element,contlim2,'LEVELS',glevs,/ADD_REPLACE
    str_element,contlim4,'LEVELS',glevs,/ADD_REPLACE
    str_element,contlim1,'C_COLORS',gcols,/ADD_REPLACE
    str_element,contlim2,'C_COLORS',gcols,/ADD_REPLACE
    str_element,contlim4,'C_COLORS',gcols,/ADD_REPLACE
  END
  3 : BEGIN
    gcont = contlim4
    glevs = gcont.LEVELS
    gcols = gcont.C_COLORS
    str_element,contlim1,'LEVELS',glevs,/ADD_REPLACE
    str_element,contlim2,'LEVELS',glevs,/ADD_REPLACE
    str_element,contlim3,'LEVELS',glevs,/ADD_REPLACE
    str_element,contlim1,'C_COLORS',gcols,/ADD_REPLACE
    str_element,contlim2,'C_COLORS',gcols,/ADD_REPLACE
    str_element,contlim3,'C_COLORS',gcols,/ADD_REPLACE
  END
  ELSE : 
ENDCASE
;-----------------------------------------------------------------------------------------
; => Define XY-Titles
;-----------------------------------------------------------------------------------------
str_element,lim1,'XTITLE','//-B [1000 km/sec]',/ADD_REPLACE
str_element,lim1,'YTITLE','//-[B x (Vsw x B)]  [1000 km/sec]',/ADD_REPLACE
str_element,lim2,'XTITLE','//-(Vsw x B) [1000 km/sec]',/ADD_REPLACE
str_element,lim2,'YTITLE','//-[B x (Vsw x B)]  [1000 km/sec]',/ADD_REPLACE
str_element,lim3,'XTITLE','//-(Vsw x B) [1000 km/sec]',/ADD_REPLACE
str_element,lim3,'YTITLE','//-B [1000 km/sec]',/ADD_REPLACE
str_element,lim4,'XTITLE','//-(n x B) [1000 km/sec]',/ADD_REPLACE
str_element,lim4,'YTITLE','//-[n x (Vsw x B)]  [1000 km/sec]',/ADD_REPLACE

; => Remove plot titles from structures
str_element,lim1,'TITLE',/DELETE
str_element,lim2,'TITLE',/DELETE
str_element,lim3,'TITLE',/DELETE
str_element,lim4,'TITLE',/DELETE
; => Remove position from structures
str_element,lim1,'POSITION',/DELETE
str_element,lim2,'POSITION',/DELETE
str_element,lim3,'POSITION',/DELETE
str_element,lim4,'POSITION',/DELETE
str_element,contlim1,'POSITION',/DELETE
str_element,contlim2,'POSITION',/DELETE
str_element,contlim3,'POSITION',/DELETE
str_element,contlim4,'POSITION',/DELETE
;-----------------------------------------------------------------------------------------
; => Define plot structures
;-----------------------------------------------------------------------------------------
tags     = 'T'+STRING(LINDGEN(4L) + 1L,FORMAT='(I1.1)')
dat_str  = CREATE_STRUCT(tags,plane1,plane2,plane3,plane4)
lim_str  = CREATE_STRUCT(tags,lim1,lim2,lim3,lim4)
con_str  = CREATE_STRUCT(tags,contlim1,contlim2,contlim3,contlim4)

vswp_str = CREATE_STRUCT(tags,vsw_pr1,vsw_pr2,vsw_pr3,vsw_pr4)
norp_str = CREATE_STRUCT(tags,nor_pr1,nor_pr2,nor_pr3,nor_pr4)
magp_str = CREATE_STRUCT(tags,magfpr4,magfpr4,magfpr3,magfpr4)
;-----------------------------------------------------------------------------------------
; => Set up plot
;-----------------------------------------------------------------------------------------
WINDOW,4,RETAIN=2,XSIZE=800L,YSIZE=800L

!P.MULTI = [0,2,2]
; => Defined user symbol for outputing locations of data on contour
xxo = FINDGEN(17)*(!PI*2./16.)
USERSYM,0.25*COS(xxo),0.25*SIN(xxo),/FILL
;-----------------------------------------------------------------------------------------
; => Plot data
;-----------------------------------------------------------------------------------------
FOR j=0L, 3L DO BEGIN
  lim_0 = lim_str.(j)   ; => plot limit structure
  con_0 = con_str.(j)   ; => contour structure
  dat_0 = dat_str.(j)   ; => 3DP data structure
  vsw_0 = vswp_str.(j)  ; => Vsw projection onto j-th plane
  mag_0 = magp_str.(j)  ; => B projection onto j-th plane
  nor_0 = norp_str.(j)  ; => n projection onto j-th plane
  CASE j OF
    0 : ttle  = lc_0[0]+':  Plane 1'
    1 : ttle  = ttln[0]+':  Plane 2'
    2 : ttle  = 'Plane 3'
    3 : ttle  = 'Plane 4'
  ENDCASE
  ;---------------------------------------------------------------------------------------
  ; => Plot Contour of jth-Plane
  ;---------------------------------------------------------------------------------------
  PLOT,[0.0,1.0],[0.0,1.0],/NODATA,_EXTRA=lim_0,TITLE=ttle[0]
  ; => Project locations of actual data points onto contour
  OPLOT,dat_0.VX_PTS*1d-3,dat_0.VY_PTS*1d-3,PSYM=8,SYMSIZE=1.0,COLOR=100
  ; => Draw contours
  CONTOUR,dat_0.DF_SMOOTH,dat_0.VX2D*1d-3,dat_0.VY2D*1d-3,_EXTRA=con_0
    ;-------------------------------------------------------------------------------------
    ; => Project V_sw onto contour
    ;-------------------------------------------------------------------------------------
    OPLOT,[0.0,vsw_0[0]],[0.0,vsw_0[1]],LINESTYLE=0
    ;-------------------------------------------------------------------------------------
    ; => Project shock normal vector onto contour
    ;-------------------------------------------------------------------------------------
    OPLOT,[0.0,nor_0[0]],[0.0,nor_0[1]],LINESTYLE=2,COLOR=250
    ;-------------------------------------------------------------------------------------
    ; => Project shock plane onto contour
    ;-------------------------------------------------------------------------------------
    ph_n2 = REFORM(eulermat(0d0,9d1,0d0,DEG=1) ## nor_0)
    OPLOT,[0.0,ph_n2[0]],[0.0,ph_n2[1]],COLOR=250,THICK=2
    OPLOT,-1d0*[0.0,ph_n2[0]],-1d0*[0.0,ph_n2[1]],COLOR=250,THICK=2
    ;-------------------------------------------------------------------------------------
    ; => Write out names of projected lines
    ;-------------------------------------------------------------------------------------
    xyposi     = [-1d0*.94*vlim,0.94*vlim]*1d-3
    XYOUTS,xyposi[0],xyposi[1],shname[0],/DATA,COLOR=250
    xyposi[1] -= 0.08*vlim*1d-3
    XYOUTS,xyposi[0],xyposi[1],vswname[0],/DATA
    ;-------------------------------------------------------------------------------------
    ; => Project circle of constant speed onto contour
    ;-------------------------------------------------------------------------------------
    IF KEYWORD_SET(vcirc) THEN BEGIN
      thetas = DINDGEN(1000)*2d0*!DPI/999L
      vxcirc = vcirc[0]*1d-3*COS(thetas)
      vycirc = vcirc[0]*1d-3*SIN(thetas)
      OPLOT,vxcirc,vycirc,LINESTYLE=2,THICK=2
    ENDIF
    ;-------------------------------------------------------------------------------------
    ; => Project B onto contour if j = 3
    ;-------------------------------------------------------------------------------------
    IF (j GE 2) THEN BEGIN
      OPLOT,[0.0,mag_0[0]],[0.0,mag_0[1]],LINESTYLE=4,COLOR=50,THICK=2
      xyposi[1] -= 0.08*vlim*1d-3
      XYOUTS,xyposi[0],xyposi[1],'B [GSE]',/DATA,COLOR=50
    ENDIF
ENDFOR
;-----------------------------------------------------------------------------------------
; => Return
;-----------------------------------------------------------------------------------------

!P.MULTI = 0
RETURN
END