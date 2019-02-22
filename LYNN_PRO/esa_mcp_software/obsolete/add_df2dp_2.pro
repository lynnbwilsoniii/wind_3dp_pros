;+
;*****************************************************************************************
;
;  FUNCTION :   add_df2dp_2.pro
;  PURPOSE  :   Adds 2D pitch angle distribution (df2d, vx2d, vy2d) to a 3d structure
;                 and it also adds dat.df2dz, dat.vx2dz, dat.vy2dz to dat structure.
;                 
;                 Definitions:
;                 1)  df2d, vx2d and vy2d are the interpolated two dimensional 
;                       distribution function and velocity in the x-y plane.
;                 2)  df2d is generated from df by folding pitch angles with vy > 0
;                       and vy < 0 to opposite sides of vy in df2d to allow some
;                       measure of non-gyrotropic distributions.
;                 3)  df2dz, vx2dz and vy2dz are interpolated to the x-z plane.
;                 4)  "x" is along the magnetic field, the "x-y" plane is defined
;                       to contain the magnetic field and the drift velocity,
;                       and the reference frame is transformed to the drift frame.
;
;  CALLED BY: 
;               my_cont2d.pro
;               my_cont3d.pro
;
;  CALLS:
;               conv_units.pro
;               str_element.pro
;               velocity.pro
;               sphere_to_cart.pro
;               rot_mat.pro
;               cart_to_sphere.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT     :  3DP data structure either from spec plots 
;                            (i.e. get_padspec.pro) or from pad.pro, get_el.pro, 
;                            get_sf.pro, etc.
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               VLIM    :  Limit for x-y velocity axes over which to plot data
;                            [Default = max vel. from energy bin values]
;               NGRID   :  # of isotropic velocity grids to use to triangulate the data
;                            [Default = 50L]
;               MINCNT  :  If present, this min count level gets added to all angle
;                            bins to smooth out noisy contour plots
;                            [Default = 0]
;
;   CHANGED:  1)  Original program created by Davin         [08/10/1995   v1.0.0]
;             2)  Modified by J.P. McFadden                 [09/15/1995   v1.1.0]
;             3)  Changed minor syntax and indexing issues  [12/31/2007   v1.1.1]
;             4)  Rewrote entire program                    [03/22/2009   v1.2.0]
;             5)  Changed program my_velocity.pro to velocity.pro
;                                                           [08/05/2009   v1.3.0]
;
;   ADAPTED FROM:   add_df2dp.pro  BY:  Davin Larson
;   CREATED:  10/08/1995
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2009   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO add_df2dp_2,dat,VLIM=vlim,NGRID=ngrid,MINCNT=mincnt

;*****************************************************************************************
; -Determine default parameters
;*****************************************************************************************
f     = !VALUES.F_NAN
d     = !VALUES.D_NAN
IF NOT KEYWORD_SET(ngrid) THEN ngrid = 50L
IF NOT KEYWORD_SET(mincnt) THEN mincnt = 0.
IF NOT KEYWORD_SET(vlim) THEN BEGIN
  vlim = MAX(SQRT(2*dat.ENERGY/dat.MASS))
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)
ENDELSE

magfield = dat.MAGF
vsw      = dat.VSW
nbins    = dat.NBINS
nenergy  = dat.NENERGY
ind      = INDGEN(nenergy*nbins)
ndat     = conv_units(dat,'df')   ; -Convert to Dist. Func. units
gind     = ARRAY_INDICES(ndat.DATA,ind)
;*****************************************************************************************
; -Determine indices to use
;*****************************************************************************************
temp_dat = FINITE(ndat.DATA[gind[0,*],gind[1,*]])
temp_enr = FINITE(ndat.ENERGY[gind[0,*],gind[1,*]])
temp_the = FINITE(ndat.THETA[gind[0,*],gind[1,*]])
temp_phi = FINITE(ndat.PHI[gind[0,*],gind[1,*]])
gdf      = WHERE(temp_dat AND temp_enr AND temp_the AND temp_phi,nd)
IF (nd LE 1L) THEN BEGIN
  MESSAGE,'There is no valid data for this sample.',/INFORMATIONAL,/CONTINUE
  df2d    = REPLICATE(0.0,1)
  vpar2d  = REPLICATE(0.0,1)
  vperp2d = REPLICATE(0.0,1)
  str_element,dat,'DF2D',df2d,/ADD_REPLACE
  str_element,dat,'VPAR2D',vpar2d,/ADD_REPLACE
  str_element,dat,'VPERP2D',vperp2d,/ADD_REPLACE
  RETURN
ENDIF

gind2  = ARRAY_INDICES(ndat.DATA,gdf)
df_dat = REFORM(ndat.DATA[gind2[0,*],gind2[1,*]])
vmag   = velocity(REFORM(ndat.ENERGY[gind2[0,*],gind2[1,*]]),ndat.MASS,/TRUE)
theta  = REFORM(ndat.THETA[gind2[0,*],gind2[1,*]])
phi    = REFORM(ndat.PHI[gind2[0,*],gind2[1,*]])
;*****************************************************************************************
; -Convert to spherical coordinates
;*****************************************************************************************
sphere_to_cart,vmag,theta,phi,vx,vy,vz ;  [theta and phi do NOT change here]
mvel = DBLARR(nd,3L)

mvel = [[vx],[vy],[vz]]   ; -[nd,3] element array of velocities
;*****************************************************************************************
; => mrot will rotate B-field to new Z'-Axis and Vsw to X'-Z' Plane
;*****************************************************************************************
mrot = rot_mat(magfield,vsw)
vd2d = REFORM(vsw # mrot)  ; => Vsw in X'-Z' Plane [perpendicular,NAN,parallel]
nvel = mvel # mrot         ; => Velocities of data in X'-Z' Plane

; -Rotate data from Cartesian to spherical coordinates [theta and phi change here]
cart_to_sphere,nvel[*,0],nvel[*,1],nvel[*,2],vmag,theta,phi
nphi = 0. ; -Dummy variable used to represent X'-Z' Plane
sphere_to_cart,vmag,theta,nphi,vperp_dat,dummy,vpar_dat ;[theta and phi don't change here]

str_element,dat,'VSW2D',vd2d,/ADD_REPLACE
str_element,dat,'DF_DAT',df_dat,/ADD_REPLACE
str_element,dat,'VPERP_DAT',vperp_dat,/ADD_REPLACE
str_element,dat,'VPAR_DAT',vpar_dat,/ADD_REPLACE
str_element,dat,'PHI_DAT',phi,/ADD_REPLACE
;*****************************************************************************************
; -Look at DF
;*****************************************************************************************
vperp_dat = [vperp_dat,-vperp_dat]
vpar_dat  = [vpar_dat,vpar_dat]
df_dat    = [df_dat,df_dat]
nve       = N_ELEMENTS(vperp_dat)
nva       = N_ELEMENTS(vpar_dat)
ndf       = N_ELEMENTS(df_dat)
gvperp    = LONARR(nve)
gvpara    = LONARR(nva)
gdfdat    = LONARR(ndf)

gvperp    = WHERE(FINITE(vperp_dat),gvpe)
gvpara    = WHERE(FINITE(vpar_dat),gvpa)
gdfdat    = WHERE(FINITE(df_dat),gdff)
IF (gvpe EQ 0L OR gvpa EQ 0L OR gdff EQ 0L) THEN BEGIN
  MESSAGE,'There is no valid data for this sample.',/INFORMATIONAL,/CONTINUE
  df2d    = REPLICATE(0.0,1)
  vpar2d  = REPLICATE(0.0,1)
  vperp2d = REPLICATE(0.0,1)
  str_element,dat,'DF2D',df2d,/ADD_REPLACE
  str_element,dat,'VPAR2D',vpar2d,/ADD_REPLACE
  str_element,dat,'VPERP2D',vperp2d,/ADD_REPLACE
  RETURN
ENDIF ELSE BEGIN
  IF (gvpe GT 0L) THEN vperp_dat = vperp_dat[gvperp] ELSE vperp_dat = 0d0
  IF (gvpa GT 0L) THEN vpar_dat = vpar_dat[gvpara] ELSE vpar_dat = 0d0
  IF (gdff GT 0L) THEN df_dat = df_dat[gdfdat] ELSE df_dat = 0d0
ENDELSE

IF (gvpe GT 0L AND gvpa GT 0L AND gdff GT 0L) THEN BEGIN
  TRIANGULATE,vpar_dat,vperp_dat,tr
ENDIF ELSE BEGIN
  MESSAGE,'There is no valid data for this sample.',/INFORMATIONAL,/CONTINUE
  df2d    = REPLICATE(0.0,1)
  vpar2d  = REPLICATE(0.0,1)
  vperp2d = REPLICATE(0.0,1)
  str_element,dat,'DF2D',df2d,/ADD_REPLACE
  str_element,dat,'VPAR2D',vpar2d,/ADD_REPLACE
  str_element,dat,'VPERP2D',vperp2d,/ADD_REPLACE
  RETURN
ENDELSE
;*****************************************************************************************
; -Determine limits and DF in new projection
;*****************************************************************************************
gs    = [vlim,vlim]/ngrid
xylim = [-1.*vlim,-1.*vlim,vlim,vlim]
bad   = WHERE(df_dat LE mincnt,cnt)
IF (cnt GT 0L) THEN df_dat[bad] = f
; -Convert to Log-Scale
df_dat = ALOG(df_dat)
trg    = TRIGRID(vpar_dat,vperp_dat,df_dat,tr,gs,xylim,MISSING=f)
df2d   = EXP(trg)
;*****************************************************************************************
; -Define velocities in new plane
;*****************************************************************************************
vpar2d  = -1.*vlim+gs[0]*FINDGEN(FIX((2.*vlim)/gs[0]) + 1)
vperp2d = -1.*vlim+gs[1]*FINDGEN(FIX((2.*vlim)/gs[1]) + 1)
myn1    = N_ELEMENTS(df2d[*,0])
myn2    = N_ELEMENTS(vpar2d)
myn3    = N_ELEMENTS(vperp2d)
IF (myn1 NE myn2 AND myn1 NE myn3) THEN BEGIN  ; -Resize arrays to avoid conflicting issues
  vpar2d  = CONGRID(vpar2d,myn1,0,0,/interp)
  vperp2d = CONGRID(vperp2d,myn1,0,0,/interp)
ENDIF ELSE BEGIN
  vpar2d  = vpar2d
  vperp2d = vperp2d
ENDELSE
str_element,dat,'DF2D',df2d,/ADD_REPLACE
str_element,dat,'VPAR2D',vpar2d,/ADD_REPLACE
str_element,dat,'VPERP2D',vperp2d,/ADD_REPLACE
;*****************************************************************************************
; -Compute Reduced Distribution Function (RDF)
;*****************************************************************************************
df2d = TRIGRID(vpar_dat,vperp_dat,df_dat,tr,gs,xylim)
rdf  = !DPI*gs[1]*(df2d # ABS(vperp2d))
str_element,dat,'RDF',rdf,/ADD_REPLACE
RETURN
END