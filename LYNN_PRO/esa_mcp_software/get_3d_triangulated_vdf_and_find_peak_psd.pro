;+
;*****************************************************************************************
;
;  FUNCTION :   get_3d_triangulated_vdf_and_find_peak_psd.pro
;  PURPOSE  :   Attempts to find the true phase space density peak of an input velocity
;                 distribution function (VDF) assuming that at least 50% of the
;                 surrounding data points in the 3D array are valid/finite.  Generally,
;                 isolated noise/artificial peaks have no or less than 50% of the
;                 surrounding points being valid.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               get_rotated_and_triangulated_vdf.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VELS       :  [K,3]-Element [numeric] array of particle velocities [km/s]
;               DATA       :  [K]-Element [numeric] array of phase (velocity) space
;                               densities [e.g., s^(3) cm^(-3) km^(-3)]
;
;  EXAMPLES:    
;               [calling sequence]
;               vpeak = get_3d_triangulated_vdf_and_find_peak_psd(vels, data [,VLIM=vlim] $
;                                            [,NGRID=ngrid] [,VFRAME=vframe] [,VEC1=vec1] $
;                                            [,VEC2=vec2] [,F3D_QH=f3d_qh]                $
;                                            [,ROT_STR=r_struc])
;
;  KEYWORDS:    
;               VLIM       :  Scalar [numeric] defining the speed limit for the velocity
;                               grids over which to triangulate the data [km/s]
;                               [Default = max vel. magnitude]
;               NGRID      :  Scalar [numeric] defining the number of grid points in each
;                               direction to use when triangulating the data.  The input
;                               will be limited to values between 30 and 300.
;                               [Default = 101]
;               VFRAME     :  [3]-Element [float/double] array defining the 3-vector
;                               velocity of the K'-frame relative to the K-frame [km/s]
;                               to use to transform the velocity distribution into the
;                               bulk flow reference frame
;                               [ Default = [0,0,0] ]
;               VEC1       :  [3]-Element vector to be used for "parallel" direction in
;                               a 3D rotation of the input data
;                               [e.g. see rotate_3dp_structure.pro]
;                               [ Default = [1.,0.,0.] ]
;               VEC2       :  [3]--Element vector to be used with VEC1 to define a 3D
;                               rotation matrix.  The new basis will have the following:
;                                 X'  :  parallel to VEC1
;                                 Z'  :  parallel to (VEC1 x VEC2)
;                                 Y'  :  completes the right-handed set
;                               [ Default = [0.,1.,0.] ]
;               INFORM     :  If set, routine will inform the user of the number of
;                               iterations necessary to find the peak, the indices of
;                               the peak, the peak phase space density, and the velocity
;                               at the peak
;                               [Default = FALSE]
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               F3D_QH     :  Set to a named variable to return the 3D array of phase
;                               space densities triangulated onto a regular grid
;               ROT_STR    :  Set to a named variable to return the IDL structure
;                               returned by get_rotated_and_triangulated_vdf.pro
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               1)  See IDL's documentation for:
;                     QHULL.PRO:        https://harrisgeospatial.com/docs/qhull.html
;                     QGRID3.PRO:       https://harrisgeospatial.com/docs/QGRID3.html
;                     TRIANGULATE.PRO:  https://harrisgeospatial.com/docs/TRIANGULATE.html
;                     TRIGRID.PRO:      https://harrisgeospatial.com/docs/TRIGRID.html
;
;   CREATED:  05/02/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/02/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_3d_triangulated_vdf_and_find_peak_psd,vels,data,VLIM=vlim,NGRID=ngrid,   $
                                                   VFRAME=vframe,VEC1=vec1,VEC2=vec2, $
                                                   F3D_QH=f3d_qh,ROT_STR=r_struc,     $
                                                   INFORM=inform

tstart             = SYSTIME(1)
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
pert           = [-2L,-1L,0L,1L,2L]
np             = N_ELEMENTS(pert)
dumb3          = REPLICATE(d,3L)
info_on        = 0b
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NGRID
test           = (N_ELEMENTS(ngrid) EQ 0) OR (is_a_number(ngrid,/NOMSSG) EQ 0)
IF (test[0]) THEN nm = 101L ELSE nm = (LONG(ngrid[0]) > 30L) < 300L
;;  Check INFORM
IF KEYWORD_SET(inform) THEN info_on = 1b
;;----------------------------------------------------------------------------------------
;;  Get rotated and triangulated results
;;----------------------------------------------------------------------------------------
r_struc        = get_rotated_and_triangulated_vdf(vels,data,VLIM=vlim,NGRID=nm,        $
                                                  VFRAME=vframe,VEC1=vec1,VEC2=vec2,   $
                                                  F3D_QH=f3d_qh,/SLICE2D)
IF (SIZE(r_struc,/TYPE) NE 8) THEN RETURN,dumb3
def_ind        = LINDGEN(nm[0])
vx2d           = r_struc.VX2D
vy2d           = r_struc.VY2D
nx             = N_ELEMENTS(vx2d)
IF (nx[0] NE nm[0]) THEN ind = LINDGEN(nx[0]) ELSE ind = def_ind
vxyz_out       = REPLICATE(d,nx[0],nx[0],nx[0],3L)
vxx2d          = vx2d # REPLICATE(1d0,nx[0])
vyy2d          = REPLICATE(1d0,nx[0]) # vy2d
vxy2d          = [[[vxx2d]],[[vyy2d]]]
FOR j=0L, nx[0] - 1L DO BEGIN
  ;;  Define X- and Y-components
  vxyz_out[ind,ind,j,0:1] = vxy2d
  ;;  Define Z-component
  vxyz_out[ind,ind,j,2]   = vx2d[j]
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Try finding peak
;;----------------------------------------------------------------------------------------
vdf_copy       = f3d_qh                      ;;  [X,Y,Z]-coordinates of output phase space densities [e.g., s^(3) cm^(-3) km^(-3)]
test           = 0b
lln            = -1L
low            = 0L
upp            = nx[0] - 1L
REPEAT BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Loop until valid peak is found
  ;;--------------------------------------------------------------------------------------
  lln           += 1L
  mx_vdf         = MAX(ABS(vdf_copy),/NAN,lx1d)
  lx3d           = ARRAY_INDICES(vdf_copy,lx1d)
  xirn           = REFORM(lx3d[0] + pert)
  yirn           = REFORM(lx3d[1] + pert)
  zirn           = REFORM(lx3d[2] + pert)
  goodx          = WHERE(xirn GE low[0] AND xirn LE upp[0],gdx)
  goody          = WHERE(yirn GE low[0] AND yirn LE upp[0],gdy)
  goodz          = WHERE(zirn GE low[0] AND zirn LE upp[0],gdz)
  IF (gdx[0] EQ 0 OR gdy[0] EQ 0 OR gdz[0] EQ 0) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Bad point!!!  -->  Exit without index
    ;;------------------------------------------------------------------------------------
    test           = 1b
    lx3d           = REPLICATE(-1L,3L)
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Check for index edges
    ;;------------------------------------------------------------------------------------
    IF (gdx[0] NE np[0]) THEN xirn           = xirn[goodx]
    IF (gdy[0] NE np[0]) THEN yirn           = yirn[goody]
    IF (gdz[0] NE np[0]) THEN zirn           = zirn[goodz]
    lux            = [0L,(N_ELEMENTS(xirn) - 1L)]
    luy            = [0L,(N_ELEMENTS(yirn) - 1L)]
    luz            = [0L,(N_ELEMENTS(zirn) - 1L)]
    ;;------------------------------------------------------------------------------------
    ;;  Define all values of neighborhood of the current peak
    ;;------------------------------------------------------------------------------------
    vdf_neigh      = REFORM(vdf_copy[xirn[lux[0]]:xirn[lux[1]],yirn[luy[0]]:yirn[luy[1]],zirn[luz[0]]:zirn[luz[1]]])
    good_neigh     = WHERE(FINITE(vdf_neigh) AND vdf_neigh GT 0,gd_neigh)
    n_neigh        = N_ELEMENTS(vdf_neigh)
    frac_good      = 1d2*gd_neigh[0]/(1d0*n_neigh[0])
    ;;  If NGOOD < 50%  -->  Anomalous spike to remove
    IF (frac_good[0] LT 50d0) THEN vdf_copy[lx1d] = d ELSE test = 1b
    ;;  Make sure looping hasn't gone on too long...
    IF (lln[0] GT 50L AND ~test[0]) THEN BEGIN
      ;;  Too many iterations --> exit but do not keep indices
      test           = 1b
      lx3d           = REPLICATE(-1L,3L)
    ENDIF
  ENDELSE
ENDREP UNTIL test[0]
;;----------------------------------------------------------------------------------------
;;  Define velocity coordinate of peak
;;----------------------------------------------------------------------------------------
IF (TOTAL(lx3d LT 0) GT 0) THEN RETURN,dumb3         ;;  Point not found!
vpeak_out      = REFORM(vxyz_out[lx3d[0],lx3d[1],lx3d[2],*])
IF (info_on[0]) THEN BEGIN
  PRINT,';;  Peak finding information'
  PRINT,';;'
  PRINT,';;  Number of Iterations        :  ',lln[0]
  PRINT,';;  [X,Y,Z]-Indices of Peak     :  ',lx3d[0], lx3d[1], lx3d[2]
  PRINT,';;  PSD [input units] at peak   :  ',f3d_qh[lx3d[0],lx3d[1],lx3d[2]]
  PRINT,';;  Velocity [X,Y,Z] at peak    :  ',vpeak_out[0], vpeak_out[1], vpeak_out[2]
  delta_t        = (SYSTIME(1) - tstart[0]) + 1d-6   ;;  Add 1 µs to account for printing and return
  PRINT,';;  Routine execution time [s]  :  '+STRING(delta_t[0])
  PRINT,';;'
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,vpeak_out
END

