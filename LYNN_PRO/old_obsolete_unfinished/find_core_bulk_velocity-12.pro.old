;+
;*****************************************************************************************
;
;  FUNCTION :   find_core_bulk_velocity.pro
;  PURPOSE  :   This routine attempts to determine the bulk flow velocity of the core
;                 of a particle distribution.  First the distribution is gridded and
;                 triangulated, then the calculation proceeds.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               energy_to_vel.pro
;               grid_mcp_esa_data_sphere.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA       :  Scalar structure associated with a known THEMIS ESA Burst
;                               data structure [see get_th?_peib.pro, ? = a-f]
;                               or a Wind/3DP PESA High Burst data structure
;                               [see get_phb.pro]
;
;  EXAMPLES:    
;               temp = find_core_bulk_velocity(data,NLON=nlon,NLAT=nlat,NPNT=npnt)
;
;  KEYWORDS:    
;               NLON         :  Scalar [long] defining the # of longitude bins to use,
;                                 which define the # L used in the comments throughout
;                                 [Default = 30]
;               NLAT         :  Scalar [long] defining the # of poloidal bins to use,
;                                 which define the # T used in the comments throughout
;                                 [Default = 30]
;               NPNT         :  Scalar [long] defining the # of points to use when
;                                 finding the peak of the distribution
;                                 [Default = 15]
;               LON_RAN      :  [2]-Element [float] array defining the range of
;                                 longitudes [0 < ø < 360] that most likely contain the
;                                 peak of the distribution
;                                 [ Default = [165.,195.] ]
;               LAT_RAN      :  [2]-Element [float] array defining the range of latitudes
;                                 [ -90 < ∑ < +90 ] that most likely contain the peak
;                                 of the distribution
;                                 [ Default = [-1.,1.]*20 ]
;               VLIMR        :  Scalar [float] speed range limit to consider for all
;                                 velocity components [km/s]
;                                 [Default = max speed from energy bin values]
;               VLIM[X,Y,Z]  :  Scalar [float] speed range limit to consider for the
;                                 [X,Y,Z]-component of the velocity [km/s]
;                                 [Default = VLIM]
;               UNITS        :  Scalar [string] defining the units to convert to prior to
;                                 gridding the data.  The allowed units names are:
;                                   1)  'counts'  ;  # of counts
;                                                      [#]
;                                   2)  'rate'    ;  count rate
;                                                      [s^(-1)]
;                                   3)  'crate'   ;  scaled count rate
;                                                      [s^(-1)]
;                                   4)  'flux'    ;  number flux
;                                                      [# cm^(-2) s^(-1) eV^(-1)]
;                                   5)  'eflux'   ;  energy flux
;                                                      [eV cm^(-2) s^(-1) eV^(-1)]
;                                   6)  'df'      ;  phase space density
;                                                      [s^(+3) km^(-3) cm^(-3)]
;               GRID_METH    :  Scalar [string] defining the gridding method to use
;                                 in GRIDDATA.PRO.  The allowed methods are:
;                                   "invdist"   :  "InverseDistance"
;                                                    Data points closer to the grid
;                                                    points have more effect than those
;                                                    which are further away.
;                                                    [Default]
;                                   "kriging"   :  "Kriging"
;                                                    Data points and their spatial
;                                                    variance are used to determine
;                                                    trends which are applied to the
;                                                    grid points.
;                                   "mincurve"  :  "MinimumCurvature"
;                                                    A plane of grid points is conformed
;                                                    to the data points while trying to
;                                                    minimize the amount of bending in
;                                                    the plane.
;                                   "polyregr"  :  "PolynomialRegression"
;                                                    Each interpolant is a least-squares
;                                                    fit of a polynomial in X and Y of
;                                                    the specified power to the specified
;                                                    data points.
;                                   "radfunc"   :  "RadialBasisFunction"
;                                                    The effects of data points are
;                                                    weighted by a function of their
;                                                    radial distance from a grid point.
;
;   CHANGED:  1)  Continued to work on routine                     [04/19/2013   v1.0.0]
;             2)  Continued to work on routine                     [04/22/2013   v1.0.0]
;             3)  Continued to work on routine                     [04/22/2013   v1.0.0]
;             4)  Continued to work on routine                     [04/22/2013   v1.0.0]
;             5)  Continued to work on routine                     [04/22/2013   v1.0.0]
;             6)  Added VLIM keyword
;                                                                  [04/22/2013   v1.1.0]
;             7)  Added keywords:  VLIM[X,Y,Z] and changed VLIM to VLIMR
;                                                                  [04/22/2013   v1.2.0]
;             8)  Now returns all velocities, including the average and median values
;                                                                  [04/22/2013   v1.3.0]
;             9)  Now removes "bad" values above VLIM[X,Y,Z] or VLIMR prior to finding
;                   the peak value
;                                                                  [04/22/2013   v1.4.0]
;            10)  Cleaned up and fixed indexing issues
;                                                                  [04/22/2013   v1.5.0]
;            11)  Now calls grid_mcp_esa_data_sphere.pro and no longer calls
;                   sphere_grid_esa_data.pro and
;                   added keywords:  UNITS and GRID_METH and
;                   now outputs gridded results
;                                                                  [04/23/2013   v2.0.0]
;
;   NOTES:      
;               1)  A significant part of the success/failure of this routine will
;                     depend upon an accurate guess for LON_RAN and LAT_RAN
;               2)  For some reason, TRIANGULATE would get stuck in computation for
;                     very long periods of time.  Therefore, I switched to using
;                     GRID_INPUT and GRIDDATA to re-grid the results.  As a consequence,
;                     the outputs from MEDIAN seem to give better results for the
;                     bulk flow velocity estimates.
;                     [compared to "corrected" results using beam fitting routines]
;               3)  The user should specify the LON_RAN and LAT_RAN when the spacecraft
;                     is not in the solar wind.  For instance, in the magnetosheath the
;                     bulk flow velocity can have significantly deflected directions
;                     from the more typical -Xgse direction seen in the solar wind
;                     [used for default ranges].
;               4)  The values for VLIM[X,Y,Z] should be the magnitudes of these
;                     components, not the signed speed.  Meaning, if you expect Vx to
;                     be between -400 < Vx < -300 km/s, then set VLIMX=400.
;
;   CREATED:  04/19/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/23/2013   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION find_core_bulk_velocity,data,NLON=nlon0,NLAT=nlat0,NPNT=npnt0,LON_RAN=lon_ran, $
                                 LAT_RAN=lat_ran,VLIMR=vlimr,VLIMX=vlimx,VLIMY=vlimy,   $
                                 VLIMZ=vlimz,UNITS=units,GRID_METH=grid_meth

;;----------------------------------------------------------------------------------------
;; => Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
miss           = !VALUES.D_NAN
;;  Define allowed units
all_units      = ['counts','rate','crate','flux','eflux','df']
;;  Define default longitude/latitude range
deflon_ra      = 18d1 + [-1d0,1d0]*15d0
deflat_ra      =  0d0 + [-1d0,1d0]*20d0
;;  Dummy error messages
notstr_msg     = 'Must be an IDL structure...'
notvdf_msg     = 'Must be an ion velocity distribution IDL structure...'
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
dat            = str[0]
;;----------------------------------------------------------------------------------------
;; => Get structure values
;;----------------------------------------------------------------------------------------
;;  Define DAT structure parameters
n_e            = dat[0].NENERGY                           ;;  # of energy bins [ = E]
n_a            = dat[0].NBINS                             ;;  # of angle bins  [ = A]
mass           = dat[0].MASS[0]                           ;;  M [eV/c^2, with c in km/s]
energy         = dat[0].ENERGY                            ;;  E [Energy bin values, eV]  [E,A]-Element Array
;;----------------------------------------------------------------------------------------
;; => Check keywords
;;----------------------------------------------------------------------------------------
ener_max       = MAX(energy,/NAN)
v_max          = SQRT(2e0*ener_max[0]/mass[0])            ;;  Speed [km/s] corresponding to Max. energy

;;  Define longitude/latitude keywords
IF (N_ELEMENTS(nlon0)   EQ 0) THEN nlon     = 30L       ELSE nlon     = LONG(nlon0[0])
IF (N_ELEMENTS(nlat0)   EQ 0) THEN nlat     = 30L       ELSE nlat     = LONG(nlat0[0])
IF (N_ELEMENTS(npnt0)   EQ 0) THEN npnt     = 15L       ELSE npnt     = LONG(npnt0[0])
IF (N_ELEMENTS(lon_ran) EQ 0) THEN mnmx_lon = deflon_ra ELSE mnmx_lon = FLOAT(lon_ran)
IF (N_ELEMENTS(lat_ran) EQ 0) THEN mnmx_lat = deflat_ra ELSE mnmx_lat = FLOAT(lat_ran)
;;  Define velocity components range
IF (N_ELEMENTS(vlimx)   EQ 0) THEN vel_x    = v_max[0]  ELSE vel_x    = ABS(FLOAT(vlimx[0]))
IF (N_ELEMENTS(vlimy)   EQ 0) THEN vel_y    = v_max[0]  ELSE vel_y    = ABS(FLOAT(vlimy[0]))
IF (N_ELEMENTS(vlimz)   EQ 0) THEN vel_z    = v_max[0]  ELSE vel_z    = ABS(FLOAT(vlimz[0]))
;;  Define VLIM
IF (N_ELEMENTS(vlimr) EQ 0) THEN BEGIN
  vlim  = SQRT(vel_x[0]^2 + vel_y[0]^2 + vel_z[0]^2) < v_max[0]
ENDIF ELSE BEGIN
  vlim = FLOAT(vlimr[0])
ENDELSE
;;  Check UNITS result
IF (N_ELEMENTS(units)   EQ 0) THEN unit = 'flux' ELSE unit = STRLOWCASE(units[0])
test           = TOTAL(all_units EQ unit[0]) NE 1
IF (test) THEN BEGIN
  MESSAGE,badunit_msg,/INFORMATIONAL,/CONTINUE
  unit = 'flux'
ENDIF

;;  Check GRID_METH result
IF (N_ELEMENTS(grid_meth) EQ 0) THEN gmeth = 0   ELSE gmeth = 1
IF (gmeth) THEN g_meth = STRLOWCASE(grid_meth[0]) ELSE g_meth = "invdist"
CASE g_meth[0] OF
  "invdist"   : BEGIN
    ;;  Inverse Distance method
    method = "InverseDistance"
    grmeth = "invdist"
  END
  "kriging"   :  BEGIN
    ;;  Kriging method with Gaussian variogram
    method = "Kriging"
    grmeth = "kriging"
  END
  "mincurve"  :  BEGIN
    ;;  Minimum Curvature method
    method = "MinimumCurvature"
    grmeth = "mincurve"
  END
  "polyregr"  :  BEGIN
    ;;  Polynomial Regression method [cubic spline]
    method = "PolynomialRegression"
    grmeth = "polyregr"
  END
  "radfunc"   :  BEGIN
    ;;  Radial Basis Function method [Thin Plate Spline]
    method = "RadialBasisFunction"
    grmeth = "radfunc"
  END
  ELSE        :  BEGIN
    ;;  Inverse Distance method
    method = "InverseDistance"
    grmeth = "invdist"
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Define allowable energy bins
;;----------------------------------------------------------------------------------------
;;  Convert VLIM to eV
vlim_eV        = energy_to_vel(vlim[0],mass[0],/INVERSE)
;;  Avg. energy bin values [eV]
eners          = TOTAL(energy,2,/NAN)/TOTAL(FINITE(energy),2)
Vmag_all       = energy_to_vel(eners,mass[0])  ;;  Corresponding speeds [km/s]
good_ener      = WHERE(eners LE vlim_eV[0],gd_ener,COMPLEMENT=bad_ener,NCOMPLEMENT=bd_ener)
;;----------------------------------------------------------------------------------------
;; => Create a spherical grid on a surface at E[i]  {i-th energy}
;;----------------------------------------------------------------------------------------
sph_struc      = grid_mcp_esa_data_sphere(dat[0],NLON=nlon[0],NLAT=nlat[0],UNITS=unit[0],$
                                          GRID_METH=grmeth[0])
;;  Define return parameters
f_grid_out     = sph_struc.F_SPH_GRID  ;;  Triangulated and gridded ∆f   {E,L,T}-Element array
sph_lon        = sph_struc.SPH_LON     ;;  Gridded ø [deg]   {E,L}-Element array
sph_lat        = sph_struc.SPH_LAT     ;;  Gridded ∑ [deg]   {E,T}-Element array
dat_df         = sph_struc.DAT_DF      ;;  DATA structure converted to UNITS
;;----------------------------------------------------------------------------------------
;;  Convert to cartesian coordinates
;;----------------------------------------------------------------------------------------
lon_all        = REPLICATE(miss[0],n_e[0],nlon[0],nlat[0])
lat_all        = REPLICATE(miss[0],n_e[0],nlon[0],nlat[0])
;;  Define speeds and velocities of gridded results [km/s]
Vmag_alls      = REPLICATE(miss[0],n_e[0],nlon[0],nlat[0])        ;;  {E,L,T}-Element array
V_all          = REPLICATE(miss[0],n_e[0],nlon[0],nlat[0],3L)     ;;  {E,L,T,3}-Element array
FOR i=0L, nlon[0] - 1L DO lat_all[*,i,*]   = sph_lat
FOR i=0L, nlat[0] - 1L DO lon_all[*,*,i]   = sph_lon
FOR j=0L, n_e[0]  - 1L DO Vmag_alls[j,*,*] = Vmag_all[j]

clon_clat      = COS(lon_all*!DPI/18d1) * COS(lat_all*!DPI/18d1)  ;;  Cos(ø) Cos(∑) = x
slon_clat      = SIN(lon_all*!DPI/18d1) * COS(lat_all*!DPI/18d1)  ;;  Sin(ø) Cos(∑) = y
slat           = SIN(lat_all*!DPI/18d1)                           ;;  Sin(∑)        = z
V_all[*,*,*,0] = Vmag_alls*clon_clat
V_all[*,*,*,1] = Vmag_alls*slon_clat
V_all[*,*,*,2] = Vmag_alls*slat
;;----------------------------------------------------------------------------------------
;;  Remove "bad" velocities [just in case]
;;----------------------------------------------------------------------------------------
f_copy         = f_grid_out
IF (bd_ener GT 0) THEN BEGIN
  f_copy[bad_ener,*,*]  = !VALUES.D_NAN
  V_all[bad_ener,*,*,*] = !VALUES.D_NAN
ENDIF

test_vel       = [(vel_x[0] NE v_max[0]),(vel_y[0] NE v_max[0]),(vel_z[0] NE v_max[0])]
vlimxyz        = [vel_x[0],vel_y[0],vel_z[0]]
FOR k=0L, 2L DO BEGIN
  IF (test_vel[k]) THEN v_lim = vlimxyz[k] ELSE v_lim = vlim[0]
  testvx  = (ABS(V_all[*,*,*,k]) GT v_lim[0]) OR (FINITE(V_all[*,*,*,k]) EQ 0)
  bad_vx  = WHERE(testvx,bd_vx,COMPLEMENT=good_vx,NCOMPLEMENT=gd_vx)
  ;;  If values are too large -> remove
  IF (bd_vx GT 0) THEN BEGIN
    V_all[bad_vx,*] = !VALUES.D_NAN
    f_copy[bad_vx]  = !VALUES.D_NAN
  ENDIF
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Try calculating bulk flow velocity
;;----------------------------------------------------------------------------------------
;;  Define peak df arrays
ind_all        = REPLICATE(miss[0],npnt,3L)      ;;  Indices of peak ∆f
max_all        = REPLICATE(miss[0],npnt)         ;;  Magnitudes of peak ∆f
;;  Define bulk flow velocity arrays
Vbulk_vec      = REPLICATE(miss[0],npnt,3L)      ;;  Velocities at peak ∆f
;;----------------------------------------------------------------------------------------
;;  Limit results to the following angles [deg]
;;    -20 < ∑ < +20  [Default latitude range]
;;    165 < ø < 195  [Default latitude range]
;;----------------------------------------------------------------------------------------
lon_copy       = sph_lon
lat_copy       = sph_lat
IF (MAX(lon_copy,/NAN) GT 37d1) THEN lon_copy -= 36d1  ;; force:  0 < ø < 360

FOR j=0L, n_e - 1L DO BEGIN
  lon0     = REFORM(lon_copy[j,*])
  lon1     = ABS(REFORM(lon_copy[j,*]))
  lat0     = REFORM(lat_copy[j,*])
  f_copy0  = REFORM(f_copy[j,*,*])
  ;;  Define tests
  test_lon = ( lon1 GE mnmx_lon[0]) AND ( lon1 LE mnmx_lon[1])
  test_lat = ( lat0 GE mnmx_lat[0]) AND ( lat0 LE mnmx_lat[1])
  good_lon = WHERE(test_lon,gdlon,COMPLEMENT=bad_lon,NCOMPLEMENT=bd_lon)
  good_lat = WHERE(test_lat,gdlat,COMPLEMENT=bad_lat,NCOMPLEMENT=bd_lat)
  ;;--------------------------------------------------------------------------------------
  ;;  Remove unwanted data
  ;;--------------------------------------------------------------------------------------
  IF (bd_lon GT 0) THEN f_copy[j,bad_lon,*] = !VALUES.D_NAN
  IF (bd_lat GT 0) THEN f_copy[j,*,bad_lat] = !VALUES.D_NAN
  IF (bd_lon GT 0) THEN V_all[j,bad_lon,*,*] = !VALUES.D_NAN
  IF (bd_lat GT 0) THEN V_all[j,*,bad_lat,*] = !VALUES.D_NAN
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Find N highest points
;;----------------------------------------------------------------------------------------
FOR j=0L, npnt - 1L DO BEGIN
  mx_f_sph       = MAX(f_copy,lfx,/NAN)
  inds           = ARRAY_INDICES(f_copy,lfx)
  ;;  Add to arrays
  ind_all[j,*]   = inds
  max_all[j]     = mx_f_sph[0]
  ;;  Remove previous point
  f_copy[inds[0],inds[1],inds[2]]  = !VALUES.D_NAN
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define corresponding velocities
;;----------------------------------------------------------------------------------------
FOR j=0L, npnt - 1L DO BEGIN
  Vbulk_vec[j,0]  = V_all[ind_all[j,0],ind_all[j,1],ind_all[j,2],0]
  Vbulk_vec[j,1]  = V_all[ind_all[j,0],ind_all[j,1],ind_all[j,2],1]
  Vbulk_vec[j,2]  = V_all[ind_all[j,0],ind_all[j,1],ind_all[j,2],2]
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define average and median values
;;----------------------------------------------------------------------------------------
avg_vbulk      = REPLICATE(miss[0],3L)
med_vbulk      = REPLICATE(miss[0],3L)
FOR k=0L, 2L DO BEGIN
  avg_vbulk[k] = MEAN(Vbulk_vec[*,k],/NAN)
  med_vbulk[k] = MEDIAN(Vbulk_vec[*,k])
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
tags           = ['F_SPH_GRID','SPH_LON','SPH_LAT','METHOD','UNITS']
grid_struc     = CREATE_STRUCT(tags,f_grid_out,sph_lon,sph_lat,method[0],unit[0])
tags           = ['AVG','MED','ALL','GRID_RESULTS','DAT_DF']
struc          = CREATE_STRUCT(tags,avg_vbulk,med_vbulk,Vbulk_vec,grid_struc,dat_df)
;;----------------------------------------------------------------------------------------
;;  Return structure to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END



