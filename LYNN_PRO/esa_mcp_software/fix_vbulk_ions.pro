;+
;*****************************************************************************************
;
;  FUNCTION :   fix_vbulk_ions.pro
;  PURPOSE  :   This routine attempts to find the "true" bulk flow velocity vector
;                 for a given ion velocity distribution by assuming the peak value
;                 of the data corresponds to the center of the main core component.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               energy_to_vel.pro
;               conv_units.pro
;               transform_vframe_3d.pro
;               rot_matrix_array_dfs.pro
;               rotate_and_triangulate_dfs.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA       :  Scalar [structure] associated with a known THEMIS ESA
;                               data structure [see get_th?_peib.pro, ? = a-f]
;                               or a Wind/3DP PESA High data structure
;                               [see get_phb.pro]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NSMOOTH    :  Scalar [integer] defining the # of points over which to
;                               smooth the ion velocity distribution prior to finding a
;                               central maximum => set to 0 for no smoothing
;                               [Default = 3]
;               DFMAX      :  Scalar [float/double] defining the peak value of the data
;                               [s^3 km^(-3) cm^(-3)] to consider when trying to find
;                               the bulk flow peak
;               VLIM       :  Scalar [float/double] speed [km/s] range limit
;                               [Default = max speed from energy bin values]
;               ERANGE     :  [2]-Element array defining the range of energies to allow
;                               in search for peak
;                               [ Default = full range of energies ]
;               NO_VTRANS  :  If set, the routine assumes the input structure is still
;                               in the spacecraft frame of reference
;
;   CHANGED:  1)  Continued writing routine
;                                                                  [08/09/2012   v1.0.0]
;             2)  Added keywords:  DFMAX and VLIM, and
;                   now rotates/triangulates prior to finding maximum to reduce errors
;                   due to spurious spikes/noise and
;                   now calls rot_matrix_array_dfs.pro and rotate_and_triangulate_dfs.pro
;                                                                  [10/11/2012   v1.1.0]
;             3)  Added keywords:  ERANGE and NO_VTRANS and
;                   updated Man. page and cleaned up a little
;                                                                  [12/10/2014   v1.2.0]
;             4)  Problem occurs when in NO_VTRANS is set causing V_NEW[0] = V_NEW[2]
;                   on output, for which there is no physical reason to believe
;                   --> call transform_vframe_3d.pro after removing energies instead
;                       of redefining V_BULK and V_NEW later
;                 ** Fixed issue and re-introduced smoothing option **
;                                                                  [12/10/2014   v1.2.1]
;
;   NOTES:      
;               1)  KEYWORD_SET(NO_VTRANS) = FALSE
;                     Then the routine assumes the distribution has already been
;                     transformed into the first guess at the bulk flow rest frame.  The
;                     [THETA,PHI]-angle bins must be in the same coordinate basis as
;                     the vectors associated with the structure tags VSW and MAGF.
;                     a)  The routine transform_vframe_3d.pro already did the following:
;                           V' = V - V_sw
;                         This routine finds the peak of the distribution and then the
;                         corresponding velocity, V_peak, that defines this peak, then
;                         defines:
;                             V" = V' - V_peak = V - (V_sw + V_peak)
;                         and then returns V_new = (V_sw + V_peak).
;
;  REFERENCES:  
;               1)  Carlson et al., (1983), "An instrument for rapidly measuring
;                      plasma distribution functions with high resolution,"
;                      Adv. Space Res. Vol. 2, pp. 67-70.
;               2)  Curtis et al., (1989), "On-board data analysis techniques for
;                      space plasma particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372.
;               3)  Lin et al., (1995), "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125.
;               4)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               5)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, (2008).
;               6)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, (2008).
;               7)  Auster, H.U., K.-H. Glassmeier, W. Magnes, O. Aydogar, W. Baumjohann,
;                      D. Constantinescu, D. Fischer, K.H. Fornacon, E. Georgescu,
;                      P. Harvey, O. Hillenmaier, R. Kroth, M. Ludlam, Y. Narita,
;                      R. Nakamura, K. Okrafka, F. Plaschke, I. Richter, H. Schwarzl,
;                      B. Stoll, A. Valavanoglou, and M. Wiedemann "The THEMIS Fluxgate
;                      Magnetometer," Space Sci. Rev. 141, pp. 235-264, (2008).
;               8)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;
;   CREATED:  08/08/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/10/2014   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION fix_vbulk_ions,data,NSMOOTH=nsmooth,DFMAX=dfmax,VLIM=vlim,$
                             ERANGE=erange,NO_VTRANS=no_vtrans

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
all_ntypes     = [1,2,3,4,5,12,13,14,15]
;;  Dummy error messages
notstr_msg     = 'Must be an IDL structure...'
notvdf_msg     = 'Must be an ion velocity distribution IDL structure...'
;;----------------------------------------------------------------------------------------
;;  Check input structure format
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 1) THEN RETURN,0b
str            = data[0]   ;;  in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,notstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test0      = test_wind_vs_themis_esa_struct(str,/NOM)
test       = (test0.(0) + test0.(1)) NE 1
IF (test) THEN BEGIN
  MESSAGE,notvdf_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NSMOOTH
test           = (N_ELEMENTS(nsmooth) EQ 0)
IF (test) THEN BEGIN
  ns     = 3L
  ns_log = 0
ENDIF ELSE BEGIN
  ns     = LONG(nsmooth[0])
  ns_log = 1
ENDELSE
;IF (test) THEN ns = 3L ELSE ns     = LONG(nsmooth[0])

;;  Check DFMAX
dfmxv          = 0
test           = (N_ELEMENTS(dfmax) EQ 1)
IF (test) THEN dfmxv = 1
test           = KEYWORD_SET(dfmxv) AND (TOTAL(SIZE(dfmax,/TYPE) EQ all_ntypes) EQ 1)
IF (test) THEN dfmxv = 1 ELSE dfmxv = 0

;;  Check VLIM
eran0          = [MIN(str[0].ENERGY,/NAN),MAX(str[0].ENERGY,/NAN)]
test           = (N_ELEMENTS(vlim) NE 1)
;IF NOT KEYWORD_SET(vlim) THEN BEGIN
;  vlim = MAX(SQRT(2*str[0].ENERGY/str[0].MASS),/NAN)
IF (test) THEN BEGIN
  vlim = energy_to_vel(eran0[1],str[0].MASS)
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)
ENDELSE

;;  Check ERANGE
test           = (N_ELEMENTS(erange) EQ 2)
IF (test) THEN BEGIN
  test = (TOTAL(SIZE(erange,/TYPE) EQ all_ntypes) EQ 1)
  IF (test) THEN BEGIN
    sp   = SORT(erange)
    era1 = erange[sp]
    ;;  Make sure ERANGE spans range of available energies
    test = (str[0].ENERGY GE era1[0]) AND (str[0].ENERGY LE era1[1])
    good = WHERE(test,gd)
    test = (gd GT 4)
    IF (test) THEN eran = era1
  ENDIF
ENDIF
test           = (N_ELEMENTS(eran) EQ 2)
IF (test) THEN BEGIN
  log_eran = 1
ENDIF ELSE BEGIN
  eran     = eran0
  log_eran = 0
ENDELSE
;;  Make sure VLIM < MAX(ERANGE)
eran_v         = energy_to_vel(eran,str[0].MASS)
vlim           = vlim[0] < MAX(eran_v,/NAN)

;;  Check NO_VTRANS
notran         = 0
test           = (N_ELEMENTS(no_vtrans) EQ 1)
IF (test) THEN BEGIN
  ;;  Check if input VDF is in the spacecraft or bulk flow frame
  test     = KEYWORD_SET(no_vtrans)
  IF (test) THEN notran = 1
ENDIF
;;----------------------------------------------------------------------------------------
;;  Convert to phase (velocity) space density
;;----------------------------------------------------------------------------------------
dat            = conv_units(str,'df')
;;  Check if ERANGE was set
;;    IF TRUE --> keep only those energies
IF KEYWORD_SET(log_eran) THEN BEGIN
  ener_0 = dat[0].ENERGY
  test   = (ener_0 GE eran[0]) AND (ener_0 LE eran[1])
  good_e = WHERE(test,gd_e,COMPLEMENT=bad_e,NCOMPLEMENT=bd_e)
  nup    = N_ELEMENTS(ener_0) - 4L
  test   = (bd_e GT 0) AND (bd_e LT nup)
  IF (test) THEN dat[0].DATA[bad_e] = f
ENDIF
;;  Check NO_VTRANS
IF KEYWORD_SET(notran) THEN BEGIN
  ;;  Convert into bulk flow frame
  transform_vframe_3d,dat,/EASY_TRAN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define DAT structure parameters
;;----------------------------------------------------------------------------------------
n_e            = dat.NENERGY             ;;  # of energy bins [ = E]
n_a            = dat.NBINS               ;;  # of angle bins  [ = A]
kk             = n_e*n_a
ind_2d         = INDGEN(n_e,n_a)         ;;  original indices of angle bins
energy         = dat.ENERGY              ;;  Energy bin values [eV]
df_dat         = dat.DATA                ;;  Data values [data.UNITS_NAME]
phi            = dat.PHI                 ;;  Azimuthal angle (from sun direction) [deg]
dphi           = dat.DPHI                ;;  Uncertainty in phi
theta          = dat.THETA               ;;  Poloidal angle (from ecliptic plane) [deg]
dtheta         = dat.DTHETA              ;;  Uncertainty in theta
tacc           = dat.DT                  ;;  Accumulation time [s] of each angle bin
t0             = dat.TIME[0]             ;;  Unix time at start of 3DP sample period
t1             = dat.END_TIME[0]         ;;  Unix time at end of 3DP sample period
del_t          = t1[0] - t0[0]           ;;  Total time of data sample
;;----------------------------------------------------------------------------------------
;;  Reform 2D arrays into 1D
;;      K = E * A
;;----------------------------------------------------------------------------------------
phi_1d         = REFORM(phi,kk)
the_1d         = REFORM(theta,kk)
;dat_1d    = SMOOTH(REFORM(df_dat,kk),ns[0],/EDGE_TRUNCATE,/NAN)
;dat_1d    = REFORM(SMOOTH(df_dat,ns[0],/EDGE_TRUNCATE,/NAN),kk)
;dat_1d         = REFORM(df_dat,kk)
IF KEYWORD_SET(notran) THEN BEGIN
  dat_1d = REFORM(SMOOTH(df_dat,ns[0],/EDGE_TRUNCATE,/NAN),kk)
;  dat_1d = SMOOTH(REFORM(df_dat,kk),ns[0],/EDGE_TRUNCATE,/NAN)
ENDIF ELSE BEGIN
  dat_1d = REFORM(df_dat,kk)
ENDELSE
ener_1d        = REFORM(energy,kk)
ind_1d         = REFORM(ind_2d,kk)
;;----------------------------------------------------------------------------------------
;;  Convert [Energies,Angles]  -->  Velocities
;;----------------------------------------------------------------------------------------
;;  Magnitude of velocities from energy (km/s)
nvmag          = energy_to_vel(ener_1d,dat[0].MASS[0])
coth           = COS(the_1d*!DPI/18d1)
sith           = SIN(the_1d*!DPI/18d1)
coph           = COS(phi_1d*!DPI/18d1)
siph           = SIN(phi_1d*!DPI/18d1)
;;  Define directions
swfv           = DBLARR(kk,3L)              ;;  [K,3]-Element array
swfv[*,0]      = nvmag*coth*coph            ;;  Define X-Velocity per energy per data bin
swfv[*,1]      = nvmag*coth*siph            ;;  Define Y-Velocity per energy per data bin
swfv[*,2]      = nvmag*sith                 ;;  Define Z-Velocity per energy per data bin
;;----------------------------------------------------------------------------------------
;;  Define rotation matrices
;;----------------------------------------------------------------------------------------
;;  Want identity matrix so we stay in GSE coordinates
v1             = REPLICATE(1d0,kk) # [1d0,0d0,0d0]  ;; [K,3]-Element array
v2             = REPLICATE(1d0,kk) # [0d0,1d0,0d0]  ;; [K,3]-Element array
;;  Define rotation matrices equivalent to cal_rot.pro
rotm           = rot_matrix_array_dfs(v1,v2,/CAL_ROT)  ;;  [K,3,3]-element array

v1             = REPLICATE(1d0,kk) # [0d0,0d0,1d0]  ;; [K,3]-Element array
v2             = REPLICATE(1d0,kk) # [1d0,0d0,0d0]  ;; [K,3]-Element array
;;  Define rotation matrices equivalent to rot_mat.pro
rotz           = rot_matrix_array_dfs(v1,v2)           ;;  [K,3,3]-element array
;;----------------------------------------------------------------------------------------
;;  Rotate velocities into new coordinate basis and triangulate
;;----------------------------------------------------------------------------------------
r_vels         = rotate_and_triangulate_dfs(swfv,dat_1d,rotm,rotz,VLIM=vlim)
;;  Define different structure planes
str_xy         = r_vels.PLANE_XY
str_xz         = r_vels.PLANE_XZ
str_yz         = r_vels.PLANE_YZ
;;  Regularly gridded velocities and phase space densities
;;  XY
v2dx_xy        = str_xy.VX_GRID_XY
v2dy_xy        = str_xy.VY_GRID_XY
df2d_xy        = str_xy.DF2D_XY
;;  XZ
v2dx_xz        = str_xz.VX_GRID_XZ
v2dy_xz        = str_xz.VY_GRID_XZ
df2d_xz        = str_xz.DF2D_XZ
;;  YZ
v2dx_yz        = str_yz.VX_GRID_YZ
v2dy_yz        = str_yz.VY_GRID_YZ
df2d_yz        = str_yz.DF2D_YZ
;;----------------------------------------------------------------------------------------
;;  Find peak in DAT
;;----------------------------------------------------------------------------------------
;;  Define original guess at bulk flow velocity [km/s]
vbulk          = dat[0].VSW
;IF KEYWORD_SET(notran) THEN BEGIN
;  ;;  Input VDF is in spacecraft frame
;  vbulk = REPLICATE(0e0,3L)
;ENDIF ELSE BEGIN
;  ;;  Input VDF is in 1st guess of bulk flow frame
;  vbulk = dat[0].VSW
;ENDELSE

;IF (N_ELEMENTS(dfmax) EQ 1) THEN BEGIN
IF KEYWORD_SET(dfmxv) THEN BEGIN
  good_xy   = WHERE(df2d_xy LT dfmax[0],gd_xy,COMPLEMENT=bad_xy,NCOMPLEMENT=bd_xy)
  good_xz   = WHERE(df2d_xz LT dfmax[0],gd_xz,COMPLEMENT=bad_xz,NCOMPLEMENT=bd_xz)
  good_yz   = WHERE(df2d_yz LT dfmax[0],gd_yz,COMPLEMENT=bad_yz,NCOMPLEMENT=bd_yz)
  IF (bd_xy GT 0) THEN df2d_xy[bad_xy] = f
  IF (bd_xz GT 0) THEN df2d_xz[bad_xz] = f
  IF (bd_yz GT 0) THEN df2d_yz[bad_yz] = f
  ;; Find max in each plane
  mx_df_xy  = MAX(df2d_xy,l_df_xy,/NAN)
  mx_df_xz  = MAX(df2d_xz,l_df_xz,/NAN)
  mx_df_yz  = MAX(df2d_yz,l_df_yz,/NAN)
ENDIF ELSE BEGIN
  ;; Find max in each plane
  mx_df_xy  = MAX(df2d_xy,l_df_xy,/NAN)
  mx_df_xz  = MAX(df2d_xz,l_df_xz,/NAN)
  mx_df_yz  = MAX(df2d_yz,l_df_yz,/NAN)
ENDELSE
;;  Define elements of DF peak in each plane
gind_xy        = ARRAY_INDICES(df2d_xy,l_df_xy)
gind_xz        = ARRAY_INDICES(df2d_xz,l_df_xz)
gind_yz        = ARRAY_INDICES(df2d_yz,l_df_yz)

;;  Define velocity at peak of DF in each plane
vpeak_xy       = [v2dx_xy[gind_xy[0]],v2dy_xy[gind_xy[1]]]    ;;  Velocity at XY-Plane peak [km/s]
vpeak_xz       = [v2dx_xz[gind_xz[0]],v2dy_xz[gind_xz[1]]]    ;;  Velocity at XZ-Plane peak [km/s]
vpeak_yz       = [v2dx_yz[gind_yz[0]],v2dy_yz[gind_yz[1]]]    ;;  Velocity at YZ-Plane peak [km/s]
;;  Average overlapping components
vpeak_x        = (vpeak_xy[0] + vpeak_xz[1])/2d0
vpeak_y        = (vpeak_xy[1] + vpeak_yz[1])/2d0
vpeak_z        = (vpeak_xz[1] + vpeak_yz[0])/2d0
vpeak          = [vpeak_x[0],vpeak_y[0],vpeak_z[0]]
;;  Define new guess at bulk flow velocity [km/s]
v_new          = vbulk + vpeak
;;----------------------------------------------------------------------------------------
;;  Create return structure
;;----------------------------------------------------------------------------------------
tags           = ['VSW_OLD','VSW_NEW']
struct         = CREATE_STRUCT(tags,vbulk,v_new)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END

