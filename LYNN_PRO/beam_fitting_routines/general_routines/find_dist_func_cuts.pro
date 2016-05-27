;+
;*****************************************************************************************
;
;  FUNCTION :   find_dist_func_cuts.pro
;  PURPOSE  :   This routine calculates the cuts of a regularly gridded velocity
;                 distribution function, f(Vx,Vy), along two orthogonal vectors
;                 centered on {V_ox, V_oy}.  The vector directions are defined by the
;                 optional keyword, ANGLE.  If this is not set, then the parallel
;                 output corresponds to the X-Axis offset by V_ox and the perpendicular
;                 output corresponds to the Y-Axis offset by V_oy.
;
;  CALLED BY:   
;               beam_fit_1df_plot_fit.pro
;               beam_fit_contour_plot.pro
;               beam_fit_fit_wrapper.pro
;
;  CALLS:
;               find_df_indices.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               FV       :  [N,N]-Element array of regularly gridded velocity
;                             distribution function, f(Vx,Vy), values
;               VELX     :  [N]-Element array of regularly gridded velocities [km/s]
;                             corresponding to the 1st dimension in FV
;                             [e.g. parallel velocities]
;               VELY     :  [N]-Element array of regularly gridded velocities [km/s]
;                             corresponding to the 2nd dimension in FV
;                             [e.g. perpendicular velocities]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               V_0X     :  Scalar defining the X-velocity-offset from zero to apply to
;                             VELX [e.g. parallel drift velocity]
;                             [Default = 0.0]
;               V_0Y     :  Scalar defining the Y-velocity-offset from zero to apply to
;                             VELY [e.g. perpendicular drift velocity]
;                             [Default = 0.0]
;               ANGLE    :  Scalar defining the angle [deg] from the Y-Axis by which
;                             to rotate the [X,Y]-cuts
;                             [Default = 0.0]
;               DF_GRID  :  If set, routine returns the cuts re-gridded after
;                             interpolation
;                             [Default = FALSE]
;
;   CHANGED:  1)  Continued to write routine                       [08/21/2012   v1.0.0]
;             2)  Continued to write routine                       [08/22/2012   v1.0.0]
;             3)  Continued to write routine                       [09/08/2012   v1.0.0]
;
;   NOTES:      
;               1)  The units of VEL[X,Y] AND V_0[X,Y] do not actually matter, just as
;                     long as they are all consistent
;               2)  VEL[X,Y] cannot have ANY elements = NaN
;               3)  *** The keyword ANGLE is not well tested yet ***
;
;   CREATED:  08/17/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/08/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION find_dist_func_cuts,fv,velx,vely,V_0X=v_0x,V_0Y=v_0y,ANGLE=angle,DF_GRID=df_grid

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
bad_fv_msg     = 'FV must be an [N,N]-element array...'
bad_in_msg     = 'Incorrect input format!'
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
testvi         = (N_ELEMENTS(velx)  EQ 0) OR (N_ELEMENTS(vely)  EQ 0)
testvo         = (N_ELEMENTS(fv) EQ 0) OR (N_ELEMENTS(fv) NE N_ELEMENTS(velx)*N_ELEMENTS(vely))
test           = testvi OR testvo OR (N_PARAMS() NE 3)
IF (test) THEN RETURN,0b

df             = REFORM(fv)
vx             = REFORM(velx)
vy             = REFORM(vely)

szv            = SIZE(df,/DIMENSIONS)
IF (N_ELEMENTS(szv) NE 2) THEN BEGIN
  MESSAGE,bad_fv_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

nvx            = N_ELEMENTS(vx)
nvy            = N_ELEMENTS(vy)
testv          = (nvx NE nvy)
test           = (szv[0] NE szv[1]) OR (szv[0] NE nvx) OR testv
IF (test) THEN BEGIN
  MESSAGE,notstr_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
dgsx           = (MAX(vx,/NAN) - MIN(vx,/NAN))/(nvx - 1L)
dgsy           = (MAX(vy,/NAN) - MIN(vy,/NAN))/(nvy - 1L)
;;   ``````````````````````````````````````````````````````````````````````````````````
;;   ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
;;   ´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
;;  IDL> temp   = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p',$
;;                 'q','r','s','t','u','v','w','x','y']
;;  IDL> temp2d = REFORM(temp,5,5)
;;  IDL> PRINT,temp2d
;;  a b c d e
;;  f g h i j
;;  k l m n o
;;  p q r s t
;;  u v w x y
;;
;;  ind[*,j] = [0-100] + (j * 101)
;;
;;  vy[0] --> Y-coordinate for ind[*,0]
;;  =>  vy[j] --> Y-coordinate for ind[*,j]
;;
;;  vx[0] --> X-coordinate for ind[0,*]
;;  =>  vx[k] --> X-coordinate for ind[k,*]
;;   ``````````````````````````````````````````````````````````````````````````````````
;;   ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
;;   ´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
;;----------------------------------------------------------------------------------------
;; => Define 2D gridded velocity corresponding to FV
;;----------------------------------------------------------------------------------------
vxy_2d         = DBLARR(nvx[0],nvx[0],2L)
FOR k=0L, nvx[0] - 1L DO BEGIN
  vxy_2d[k,*,0] = vx[k]
  vxy_2d[k,*,1] = vy[*]
ENDFOR
;;----------------------------------------------------------------------------------------
;; => Check keywords
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(v_0x)  NE 1) THEN vox  = 0d0 ELSE vox  = v_0x[0]
IF (N_ELEMENTS(v_0y)  NE 1) THEN voy  = 0d0 ELSE voy  = v_0y[0]
IF (N_ELEMENTS(angle) NE 2) THEN ang  = 0d0 ELSE ang  = angle[0]
;; Make sure offsets and angle are finite
IF (FINITE(vox)       NE 1) THEN vox  = 0d0
IF (FINITE(voy)       NE 1) THEN voy  = 0d0
IF (FINITE(ang)       NE 1) THEN ang  = 0d0
;;----------------------------------------------------------------------------------------
;; => Define velocity components parallel to {Vx Sin(ø), Vy Cos(ø)}
;;----------------------------------------------------------------------------------------
theta          = ang[0]*!DPI/18d1
;;  Components parallel to angled cut
;;    => perpendicular for angle = 0
vxn_per        = vx*SIN(theta[0]) + vox[0]
vyn_per        = vy*COS(theta[0]) + voy[0]
nuqx           = N_ELEMENTS(UNIQ(vxn_per,SORT(vxn_per)))
nuqy           = N_ELEMENTS(UNIQ(vyn_per,SORT(vyn_per)))
nuqs           = [nuqx,nuqy]
IF (nuqs[0] NE nvx) THEN BEGIN
  vy_cut = vyn_per
  vy_off = voy[0]
ENDIF ELSE BEGIN
  vy_cut = vxn_per
  vy_off = vox[0]
ENDELSE
;;  Find indices
inds           = find_df_indices(vx,vy,vxn_per,vyn_per)
testx_per      = inds.X_IND
testy_per      = inds.Y_IND
;;  Define [X,Y] projection velocities
vxy_proj_per   = [[vxn_per],[vyn_per]]
;;----------------------------------------------------------------------------------------
;; => Define velocity components perpendicular to {Vx Sin(ø), Vy Cos(ø)}
;;----------------------------------------------------------------------------------------
theta_p        = (ang[0] + 90d0)*!DPI/18d1
vxn_par        = vx*SIN(theta_p[0]) + vox[0]
vyn_par        = vy*COS(theta_p[0]) + voy[0]
nuqx           = N_ELEMENTS(UNIQ(vxn_par,SORT(vxn_par)))
nuqy           = N_ELEMENTS(UNIQ(vyn_par,SORT(vyn_par)))
nuqs           = [nuqx,nuqy]
IF (nuqs[0] NE nvx) THEN BEGIN
  vx_cut = vyn_par
  vx_off = voy[0]
ENDIF ELSE BEGIN
  vx_cut = vxn_par
  vx_off = vox[0]
ENDELSE
;;  Find indices
inds           = find_df_indices(vx,vy,vxn_par,vyn_par)
testx_par      = inds.X_IND
testy_par      = inds.Y_IND
;;  Define [X,Y] projection velocities
vxy_proj_par   = [[vxn_par],[vyn_par]]
;;----------------------------------------------------------------------------------------
;; => Calculate Cuts of f(Vx,Vy)
;;----------------------------------------------------------------------------------------
df_e           = ALOG(df)
dfpara_e       = INTERPOLATE(df_e,testx_par,testy_par,MISSING=d)
dfperp_e       = INTERPOLATE(df_e,testx_per,testy_per,MISSING=d)
;; => Remove extrapolated values that exploded
bad            = WHERE(dfpara_e GT 1e0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0) THEN dfpara_e[bad] = d
bad            = WHERE(dfperp_e GT 1e0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0) THEN dfperp_e[bad] = d

dfpara         = EXP(dfpara_e)    ;; => Para. Cut of DF
dfperp         = EXP(dfperp_e)    ;; => Perp. Cut of DF
;;  Define corresponding velocities
vpara          = INTERPOLATE(vxy_2d[*,*,0],testx_par,testy_par,MISSING=d)
vperp          = INTERPOLATE(vxy_2d[*,*,1],testx_per,testy_per,MISSING=d)
;;----------------------------------------------------------------------------------------
;; => Center Velocities on Cut peaks
;;----------------------------------------------------------------------------------------
mx_par         = MAX(dfpara,/NAN,lxpar)
mx_per         = MAX(dfperp,/NAN,lxper)
;;  Redefine XY-Offsets
vx_off         = vpara[lxpar[0]]
vy_off         = vperp[lxper[0]]
IF KEYWORD_SET(df_grid) THEN BEGIN
  ;; => Re-grid XY-Velocities and DF
  ;;  Find indices
  ind_v          = find_df_indices(vx,vy,vpara,vperp)
  testv_par      = ind_v.X_IND
  testv_per      = ind_v.Y_IND
  vpara          = INTERPOL(vpara,testv_par,DINDGEN(nvx[0]))
  vperp          = INTERPOL(vperp,testv_per,DINDGEN(nvx[0]))
  dfpar_grid     = INTERPOL(dfpara_e,testv_par,DINDGEN(nvx[0]))
  dfper_grid     = INTERPOL(dfperp_e,testv_per,DINDGEN(nvx[0]))
  ;; => Remove extrapolated values that exploded
  bad            = WHERE(dfpar_grid GT 1e0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
  IF (bd GT 0) THEN dfpar_grid[bad] = d
  bad            = WHERE(dfper_grid GT 1e0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
  IF (bd GT 0) THEN dfper_grid[bad] = d
  ;; => e^(df)
  dfpara         = EXP(dfpar_grid)
  dfperp         = EXP(dfper_grid)
ENDIF
;;----------------------------------------------------------------------------------------
;; => Create return structure
;;----------------------------------------------------------------------------------------
tag_suffx      = ['_PARA','_PERP']
tag_prefx      = ['DF','V_CUT','V_0','V_XY']
tags           = [tag_prefx+tag_suffx[0],tag_prefx+tag_suffx[1]]
struct         = CREATE_STRUCT(tags,dfpara,vpara,vx_off,vxy_proj_par,$
                                    dfperp,vperp,vy_off,vxy_proj_per)
;;----------------------------------------------------------------------------------------
;; => Return structure to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END
