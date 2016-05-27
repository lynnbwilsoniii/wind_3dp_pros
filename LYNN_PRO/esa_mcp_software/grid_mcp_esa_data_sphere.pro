;+
;*****************************************************************************************
;
;  FUNCTION :   grid_mcp_esa_data_sphere.pro
;  PURPOSE  :   This routine grids data from a multi-channel plate (MCP) electrostatic
;                 analyzer onto a spherical surface of constant energy.  This routine
;                 is mostly a wrapping routine for grid_on_spherical_shells.pro,
;                 specific to input from a MCP electrostatic analyzer.
;
;  CALLED BY:   
;               find_core_bulk_velocity.pro
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               conv_units.pro
;               grid_on_spherical_shells.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA       :  Scalar [structure] associated with a known THEMIS ESA Burst
;                               data structure (e.g., see get_th?_peib.pro, where ? = a-f)
;                               or a Wind/3DP data structure
;                               (e.g., see get_phb.pro)
;
;  EXAMPLES:    
;               test = grid_mcp_esa_data_sphere(data,NLON=nlon,NLAT=nlat,UNITS='eflux',$
;                                               GRID_METH="invdist")
;
;  KEYWORDS:    
;               NLON       :  Scalar [long] defining the # of longitude bins to use,
;                               which define the # L used in the comments throughout
;                               [Default = 30]
;               NLAT       :  Scalar [long] defining the # of poloidal bins to use,
;                               which define the # T used in the comments throughout
;                               [Default = 30]
;               UNITS      :  Scalar [string] defining the units to convert to prior to
;                               gridding the data.  The allowed units names are:
;                                 1)  'counts'  ;  # of counts
;                                                    [#]
;                                 2)  'rate'    ;  count rate
;                                                    [s^(-1)]
;                                 3)  'crate'   ;  scaled count rate
;                                                    [s^(-1)]
;                                 4)  'flux'    ;  number flux
;                                                    [# cm^(-2) s^(-1) eV^(-1)]
;                                 5)  'eflux'   ;  energy flux
;                                                    [eV cm^(-2) s^(-1) eV^(-1)]
;                                 6)  'df'      ;  phase space density
;                                                    [s^(+3) km^(-3) cm^(-3)]
;               GRID_METH  :  Scalar [string] defining the gridding method to use
;                               in GRIDDATA.PRO.  The allowed methods are:
;                                 "invdist"   :  "InverseDistance"
;                                                  Data points closer to the grid points
;                                                  have more effect than those which are
;                                                  further away.
;                                                  [Default]
;                                 "kriging"   :  "Kriging"
;                                                  Data points and their spatial variance
;                                                  are used to determine trends which are
;                                                  applied to the grid points.
;                                 "mincurve"  :  "MinimumCurvature"
;                                                  A plane of grid points is conformed to
;                                                  the data points while trying to
;                                                  minimize the amount of bending in the
;                                                  plane.
;                                 "polyregr"  :  "PolynomialRegression"
;                                                  Each interpolant is a least-squares
;                                                  fit of a polynomial in X and Y of the
;                                                  specified power to the specified data
;                                                  points.
;                                 "radfunc"   :  "RadialBasisFunction"
;                                                  The effects of data points are
;                                                  weighted by a function of their radial
;                                                  distance from a grid point.
;
;   CHANGED:  1)  Continued to work on routine                     [04/19/2013   v1.0.0]
;             2)  Continued to work on routine                     [04/22/2013   v1.0.0]
;             3)  Continued to work on routine                     [04/22/2013   v1.0.0]
;             4)  Continued to work on routine                     [04/22/2013   v1.0.0]
;             5)  Continued to work on routine                     [04/22/2013   v1.0.0]
;             6)  Now an independent routine and renamed from sphere_grid_esa_data.pro
;                   to grid_mcp_esa_data_sphere.pro
;                                                                  [04/23/2013   v2.0.0]
;
;   NOTES:      
;               1)  This routine will fail if all the points are co-linear
;               2)  For some reason, TRIANGULATE would get stuck in computation for
;                     very long periods of time.  Therefore, I switched to using
;                     GRID_INPUT and GRIDDATA to re-grid the results.  As a consequence,
;                     the outputs from MEDIAN seem to give better results in
;                     find_core_bulk_velocity.pro.
;
;   CREATED:  04/19/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/22/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION grid_mcp_esa_data_sphere,data,NLON=nlon0,NLAT=nlat0,UNITS=units,$
                                  GRID_METH=grid_meth

;;----------------------------------------------------------------------------------------
;; => Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
miss           = !VALUES.D_NAN
;;  Define allowed units
all_units      = ['counts','rate','crate','flux','eflux','df']
;;  Dummy error messages
notstr_msg     = 'Must be an IDL structure...'
notvdf_msg     = 'Must be an ion velocity distribution IDL structure...'
badunit_msg    = 'The units name used could not be found -> using default...'
;;----------------------------------------------------------------------------------------
;; => Check input structure format
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 1) THEN RETURN,0b
str       = data[0]   ;; => in case it is an array of structures of the same format
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
;; => Check keywords
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(nlon0)   EQ 0) THEN nlon = 30L    ELSE nlon = LONG(nlon0[0])
IF (N_ELEMENTS(nlat0)   EQ 0) THEN nlat = 30L    ELSE nlat = LONG(nlat0[0])

IF (N_ELEMENTS(units)   EQ 0) THEN unit = 'flux' ELSE unit = STRLOWCASE(units[0])
;;  Check UNITS result
test           = TOTAL(all_units EQ unit[0]) NE 1
IF (test) THEN BEGIN
  MESSAGE,badunit_msg,/INFORMATIONAL,/CONTINUE
  unit = 'flux'
ENDIF
;;----------------------------------------------------------------------------------------
;; => Convert to UNITS
;;----------------------------------------------------------------------------------------
dat_df         = conv_units(str,unit[0],SCALE=scale)
;;----------------------------------------------------------------------------------------
;; => Get structure values
;;----------------------------------------------------------------------------------------
;;  Define DAT structure parameters
n_e            = dat_df.NENERGY                           ;;  # of energy bins [ = E]
n_a            = dat_df.NBINS                             ;;  # of angle bins  [ = A]
mass           = dat_df.MASS[0]                           ;;  M [eV/c^2, with c in km/s]
kk             = n_e*n_a
ind_2d         = INDGEN(n_e,n_a)                          ;;  original indices of angle bins

energy         = dat_df.ENERGY                            ;;  E [Energy bin values, eV]  [E,A]-Element Array
ef_dat         = dat_df.DATA                              ;;  ƒ(E,∑,ø) [UNITS]
;;  Define angle-related parameters
phi            = dat_df.PHI                               ;;  Azimuthal angle, ø [deg]
dphi           = dat_df.DPHI                              ;;  Uncertainty in ø
theta          = dat_df.THETA                             ;;  Poloidal angle, ∑ [deg]
dtheta         = dat_df.DTHETA                            ;;  Uncertainty in ∑
;;----------------------------------------------------------------------------------------
;;  Grid the data
;;----------------------------------------------------------------------------------------
grid_struc     = grid_on_spherical_shells(ef_dat,phi,theta,NLON=nlon[0],NLAT=nlat[0],$
                                          GRID_METH=grid_meth)
;;  Check output
IF (SIZE(grid_struc,/TYPE) NE 8L) THEN RETURN,0b
;;----------------------------------------------------------------------------------------
;;  Define output variables
;;----------------------------------------------------------------------------------------
f_grid_out     = REPLICATE(miss[0],n_e[0],nlon[0],nlat[0])  ;;  Triangulated and gridded ∆ƒ
sph_lon        = REPLICATE(miss[0],n_e[0],nlon[0])          ;;  Gridded ø [deg]
sph_lat        = REPLICATE(miss[0],n_e[0],nlat[0])          ;;  Gridded ∑ [deg]

f_grid_out     = grid_struc.F_SPH_GRID                      ;;  [E,L,T]-Element array
sph_lon        = grid_struc.SPH_LON                         ;;  [E,L]-Element array
sph_lat        = grid_struc.SPH_LAT                         ;;  [E,T]-Element array
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
tags           = ['F_SPH_GRID','SPH_LON','SPH_LAT','DAT_DF']
struc          = CREATE_STRUCT(tags,f_grid_out,sph_lon,sph_lat,dat_df)
;;----------------------------------------------------------------------------------------
;;  Return structure to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END

