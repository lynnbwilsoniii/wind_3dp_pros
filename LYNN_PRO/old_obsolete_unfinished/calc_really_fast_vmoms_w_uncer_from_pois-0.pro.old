;*****************************************************************************************
;
;  FUNCTION :   sub_fast_short_ninteg_3d_vdf.pro
;  PURPOSE  :   Performs a numerical integration of a 3D velocity distribution function
;                 (VDF), using Simpson's 1/3 Rule, to find the velocity moments up to
;                 the heat flux vector.  The results are assumed to be in a cartesian
;                 coordinate basis.
;
;  CALLED BY:   
;               calc_really_fast_vmoms_w_uncer_from_pois.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               @load_constants_fund_em_atomic_c2014_batch.pro
;               @load_constants_extra_part_co2014_ci2015_batch.pro
;               is_a_3_vector.pro
;               mag__vec.pro
;               unit_vec.pro
;               is_a_number.pro
;               rel_lorentz_trans_3vec.pro
;               delete_variable.pro
;               rot_mat.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VELS       :  [K,3]-Element [numeric] array of particle velocities
;                               [i.e., km/s]
;               DATM       :  [K]-Element [numeric] array of phase (velocity) space
;                               densities for f(v) - df(v) [e.g., s^(3) cm^(-3) km^(-3)]
;               DATA       :  [K]-Element [numeric] array of phase (velocity) space
;                               densities for f(v) [e.g., s^(3) cm^(-3) km^(-3)]
;               DATP       :  [K]-Element [numeric] array of phase (velocity) space
;                               densities for f(v) + df(v) [e.g., s^(3) cm^(-3) km^(-3)]
;
;  EXAMPLES:    
;               [calling sequence]
;               sub_fast_short_ninteg_3d_vdf,vel1,dat1m,dat1f,dat1p [,VLIM=vlim]         $
;                        [,NGRID=ngrid] [,VFRAME=vframe] [,ELECTRON=electron]            $
;                        [,PROTON=proton] [,ALPHA_P=alpha_p] [,MAG_DIR=mag_dir]          $
;                        [,VEC1=vec1] [,VEC2=vec2] [,F3DMQH=fxyzm3d] [,F3DAQH=fxyza3d]   $
;                        [,F3DPQH=fxyzp3d] [,V1DGRID=v1dgrid]
;
;  KEYWORDS:    
;               ***  INPUTS  ***
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
;               ELECTRON   :  If set, use electron mass [eV/(km/sec)^2]
;                                [Default = TRUE if MASS = FALSE]
;               PROTON     :  If set, use proton mass [eV/(km/sec)^2]
;                                [Default = FALSE]
;               ALPHA_P    :  If set, use alpha-particle mass [eV/(km/sec)^2]
;                               [Default = FALSE]
;               MAG_DIR    :  [3]-Element vector to be used to define the magnetic field
;                               direction to which the cartesian data will be rotated
;                               [ Default = [1,0,0] ]
;               ***  Pre-Set INPUTS  ***
;               VEC1       :  [3]-Element vector to be used for X-direction in
;                               a 3D rotation of the input data
;                               [e.g., see rotate_3dp_structure.pro]
;                               [ Default = [1.,0.,0.] ]
;               VEC2       :  [3]--Element vector to be used with VEC1 to define a 3D
;                               rotation matrix.  The new basis will have the following:
;                                 X'  :  parallel to VEC1
;                                 Z'  :  parallel to (VEC1 x VEC2)
;                                 Y'  :  completes the right-handed set
;                               [ Default = [0.,1.,0.] ]
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               F3DMQH     :  Set to a named variable to return the 3D array of phase
;                               space densities triangulated onto a regular grid
;                               for f(v) - df(v) [e.g., s^(3) cm^(-3) km^(-3)]
;               F3DAQH     :  Set to a named variable to return the 3D array of phase
;                               space densities triangulated onto a regular grid
;                               for f(v) [e.g., s^(3) cm^(-3) km^(-3)]
;               F3DPQH     :  Set to a named variable to return the 3D array of phase
;                               space densities triangulated onto a regular grid
;                               for f(v) + df(v) [e.g., s^(3) cm^(-3) km^(-3)]
;               V1DGRID    :  Set to a named variable to return the 1D array of regularly
;                               gridded velocities [km/s]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [04/14/2025   v1.0.0]
;             2)  Continued to write routine
;                                                                   [04/15/2025   v1.0.0]
;
;   NOTES:      0)  Adapted from lbw_fast_short_ninteg_3d_vdf.pro
;                     to increase computation speed when calling 1000s of times in a row
;
;               Velocity moments:
;                 Note:  d^3v --> v_perp dv_perp dv_para dphi --> π |v_perp| dv_perp dv_para
;                             --> dvx dvy dvz  {for cartesian coordinates}
;
;                 Definitions:
;                   ms        :  particle mass [eV km^(-2) s^(+2)] of species s
;                   h         :  Simpson's 1/3 Rule integration factor [km^(+3) s^(-3)]
;                                = ∆vx*∆vy*∆vz/[3 (N - 1)]^3
;                   S_ijk     :  Simpson's 1/3 Rule coefficients [N/A]
;                   K_ijk     :  common integration factor [km^(+3) s^(-3) sr]
;                                = (h S_ijk)
;                   f_ijk     :  total velocity distribution function (VDF)
;                                [# cm^(-3) km^(-3) s^(+3)]
;                   qmax      :  free-streaming heat flux [eV km s^(-1) cm^(-3)]
;                                = 3/2 me Ne (V_Tec,//)^3
;
;                 Velocity Moments:
;                   Ns        :  Total particle density [cm^(-3)] of species s
;                                = ∑_i ∑_j ∑_k [ K_ijk f_ijk ]
;                   Vos_x     :  X-Component drift velocity [km/s] of species s
;                                = Ns^(-1) ∑_i ∑_j ∑_k [ K_ijk vx_i f_ijk ]
;                   Vos_y     :  Y-Component drift velocity [km/s] of species s
;                                = Ns^(-1) ∑_i ∑_j ∑_k [ K_ijk vy_j f_ijk ]
;                   Vos_z     :  Z-Component drift velocity [km/s] of species s
;                                = Ns^(-1) ∑_i ∑_j ∑_k [ K_ijk vz_k f_ijk ]
;                   Ps_xx     :  XX-Component pressure tensor component [eV cm^(-3)] of
;                                species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vx_i vx_i f_ijk ]
;                   Ps_yy     :  YY-Component pressure tensor component [eV cm^(-3)] of
;                                species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vy_j vy_j f_ijk ]
;                   Ps_zz     :  ZZ-Component pressure tensor component [eV cm^(-3)] of
;                                species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vz_k vz_k f_ijk ]
;                   Ps_xy     :  XY-Component pressure tensor component [eV cm^(-3)] of
;                                species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vx_i vy_j f_ijk ]
;                   Ps_xz     :  XZ-Component pressure tensor component [eV cm^(-3)] of
;                                species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vx_i vz_k f_ijk ]
;                   Ps_yz     :  YZ-Component pressure tensor component [eV cm^(-3)] of
;                                species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vy_j vz_k f_ijk ]
;                   Qs_vec    :  3-Vector version of heat flux tensor [eV km s^(-1) cm^(-3)]
;                                of species s
;                                Qs_x = ms ∑_i ∑_j ∑_k [ K_ijk v^2 vx_i f_ijk ]
;                                Qs_y = ms ∑_i ∑_j ∑_k [ K_ijk v^2 vy_i f_ijk ]
;                                Qs_z = ms ∑_i ∑_j ∑_k [ K_ijk v^2 vz_i f_ijk ]
;
;  REFERENCES:  
;               0)  Simpson's 1/3 Rule References:
;                 http://mathfaculty.fullerton.edu/mathews/n2003/SimpsonsRule2DMod.html
;                 http://www.physics.usyd.edu.au/teach_res/mp/doc/math_integration_2D.pdf
;                 https://en.wikipedia.org/wiki/Simpson%27s_rule
;               1)  See IDL's documentation for:
;                     QHULL.PRO:        https://harrisgeospatial.com/docs/qhull.html
;                     QGRID3.PRO:       https://harrisgeospatial.com/docs/QGRID3.html
;                     TRIANGULATE.PRO:  https://harrisgeospatial.com/docs/TRIANGULATE.html
;                     TRIGRID.PRO:      https://harrisgeospatial.com/docs/TRIGRID.html
;               2)  Carlson et al., "An instrument for rapidly measuring plasma
;                      distribution functions with high resolution,"
;                      Adv. Space Res. 2, pp. 67--70, 1983.
;               3)  Curtis et al., "On-board data analysis techniques for space plasma
;                      particle instruments," Rev. Sci. Inst. 60, pp. 372, 1989.
;               4)  Lin et al., "A Three-dimensional plasma and energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125, 1995.
;               5)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                      Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst., 1998.
;               6)  Wilson III, L.B., et al., "The Statistical Properties of Solar Wind
;                      Temperature Parameters Near 1 au," Astrophys. J. Suppl. 236(2),
;                      pp. 41, doi:10.3847/1538-4365/aab71c, 2018.
;               7)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      Astrophys. J. Suppl. 243(8), doi:10.3847/1538-4365/ab22bd, 2019a.
;               8)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: II. Statistics,"
;                      Astrophys. J. Suppl. 245(24), doi:10.3847/1538-4365/ab5445, 2019b.
;               9)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: III. Analysis,"
;                      Astrophys. J., Accepted Mar. 4, 2020.
;              10)  Wilson III, L.B., et al., "A Quarter Century of Wind Spacecraft
;                      Discoveries," Rev. Geophys. 59(2), pp. e2020RG000714,
;                      doi:10.1029/2020RG000714, 2021.
;              11)  Wilson III, L.B., et al., "The need for accurate measurements of
;                      thermal velocity distribution functions in the solar wind,"
;                      Front. Astron. Space Sci. 9, pp. 1063841,
;                      doi:10.3389/fspas.2022.1063841, 2022.
;              12)  Wilson III, L.B., et al., "Spacecraft floating potential measurements
;                      for the Wind spacecraft," Astrophys. J. Suppl. 269(52), pp. 10,
;                      doi:10.3847/1538-4365/ad0633, 2023.
;              13)  Gary, S.P., et al., "The whistler heat flux instability: Threshold
;                      conditions in the solar wind," J. Geophys. Res. 99(A12),
;                      pp. 23,391--23,400, doi:10.1029/94JA02067, 1994.
;              14)  Gary, S.P., et al., "Electron heat flux constraints in the solar wind,"
;                      Phys. Plasmas 6(6), pp. 2607--2612, doi:10.1063/1.873532, 1999a.
;              15)  Gary, S.P., et al., "Solar wind electrons: Parametric constraints,"
;                      J. Geophys. Res. 104(A9), pp. 19,843--19,850,
;                      doi:10.1029/1999JA900244, 1999b.
;
;   CREATED:  04/11/2025
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/15/2025   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION sub_fast_short_ninteg_3d_vdf,vel1,dat1m,dat1f,dat1p,VLIM=vlim,NGRID=ngrid,        $
                                      VFRAME=vframe,ELECTRON=electron,PROTON=proton,       $
                                      ALPHA_P=alpha_p,MAG_DIR=mag_dir,VEC1=vec1,VEC2=vec2, $
                                      F3DMQH=fxyzm3d,F3DAQH=fxyza3d,F3DPQH=fxyzp3d,        $
                                      V1DGRID=v1dgrid

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Get fundamental and astronomical
@load_constants_fund_em_atomic_c2014_batch.pro
@load_constants_extra_part_co2014_ci2015_batch.pro
c2             = c[0]^2d0                 ;;  (m/s)^2
ckm            = c[0]*1d-3                ;;  m --> km
ckm2           = ckm[0]^2d0               ;;  (km/s)^2
;;  Conversion factors
;;    Energy and Temperature
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> eV2K*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> K2eV*Temp{K} = energy{eV}]
;;  Define factor for plasma beta
beta_fac       = 2d0*muo[0]*1d6*eV2J[0]/(1d-9^2)
;;  Define default
def_mass       = me_esa[0]
def_vframe     = [0d0,0d0,0d0]            ;;  Assumes km/s units on input
def_ngrid      = 121L                                     ;;  Define # of grid points for Delaunay triangulation
def_vlim       = 15d3                                     ;;  Default speed limit = 15,000 km/s
min_vlim       = 10d3                                     ;;  Minimum speed limit = 10,000 km/s
toler          = 1d-6
;;----------------------------------------------------------------------------------------
;;  Define dummy output structure
;;----------------------------------------------------------------------------------------
tags           = ['N_S','VOS_XYZ','PRESS_TENXYZ','PRESS_TENFAC','PRESS_SCALAR',    $
                  'TEMP_3XYZ','TAVG','VTHERMAL','TEMP_3FAC','TANISOTROPY',         $
                  'QFLUX_3VEC_XYZ','QFLUX_3VEC_FAC','QFLUX_3VEC_NOR','UNITS']
units          = ['cm^(-3)','km/s','eV cm^(-3)','eV cm^(-3)','eV','eV','km/s',     $
                  'eV','N/A','eV km s^(-1) cm^(-3)','eV km s^(-1) cm^(-3)','N/A']
dumb3          = REPLICATE(d,3L)
dumb33         = REPLICATE(d,3L,3L)
dumb333        = REPLICATE(d,3L,3L,3L)
dumb_one       = CREATE_STRUCT(tags,d,dumb3,dumb33,dumb33,d,dumb3,d,d,dumb3,d,dumb3,dumb3,dumb3,units)
dumb_out       = CREATE_STRUCT(tags,dumb3,dumb33,dumb333,dumb333,dumb3,dumb33,dumb3,dumb3,dumb33,dumb3,dumb33,dumb33,dumb33,units)
;;----------------------------------------------------------------------------------------
;;  Define some tensor maps
;;----------------------------------------------------------------------------------------
;;  Rank-2 tensors
map_r2         = [[0,3,4],[3,1,5],[4,5,2]]       ;;  Rank-2 tensor map
map_v2         = [0,4,8,1,2,5]                   ;;  Symmetry elements of rank-2 tensor
diagr2         = [0,4,8]                         ;;  Diagonal " "
;;  Rank-3 tensors
map_r3         = [[[3,5,2],[5,6,9],[2,9,7]],[[5,6,9],[6,4,1],[9,1,8]],[[2,9,7],[9,1,8],[7,8,0]]]
map_v3         = [26,14,2,0,13,1,4,8,17,5]
ind_r3         = [[0,4,8],[9,13,17],[18,22,26]]
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 4) THEN RETURN,0b
vels           = vel1
datm           = REFORM(dat1m)
data           = REFORM(dat1f)
datp           = REFORM(dat1p)
nnd            = N_ELEMENTS(data)
kk             = nnd[0]
;;  Define jittered velocities (avoids colinear problems)
jitter         = REPLICATE(d,nnd[0],3L)
FOR j=0L, 2L DO jitter[*,j] = 2d0*(RANDOMU(seed,kk[0],/DOUBLE) - 5d-1)*toler[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check SLICE2D
;IF ((N_ELEMENTS(slice2d) EQ 1) AND ~KEYWORD_SET(slice2d)) THEN slice_on = 0b ELSE slice_on = 1b
;;  Check ELECTRON
IF ((N_ELEMENTS(electron) EQ 1) AND KEYWORD_SET(electron)) THEN elec_on = 1b ELSE elec_on = 0b
;;  Check PROTON
IF ((N_ELEMENTS(proton) EQ 1) AND KEYWORD_SET(proton)) THEN prot_on = 1b ELSE prot_on = 0b
;;  Check ALPHA_P
IF ((N_ELEMENTS(alpha_p) EQ 1) AND KEYWORD_SET(alpha_p)) THEN alph_on = 1b ELSE alph_on = 0b
;;  Check mass factors
checks         = [elec_on[0],prot_on[0],alph_on[0]]
IF (TOTAL(checks) GT 1) THEN BEGIN
  ;;  More than one particle type set --> default to electrons
  elec_on        = 1b
  prot_on        = 0b
  alph_on        = 0b
  ;;  Redefine variable
  checks         = [elec_on[0],prot_on[0],alph_on[0]]
ENDIF
good           = WHERE(checks,gd)
CASE good[0] OF
  0L    :  mass = me_esa[0]                           ;;  me [eV km^(-2) s^(+2)]
  1L    :  mass = mp_esa[0]                           ;;  mp [eV km^(-2) s^(+2)]
  2L    :  mass = ma_esa[0]                           ;;  ma [eV km^(-2) s^(+2)]
  ELSE  :  BEGIN
    ;;  Nothing was set --> Default to electrons
    elec_on        = 1b
    prot_on        = 0b
    alph_on        = 0b
    ;;  Redefine variable
    checks         = [elec_on[0],prot_on[0],alph_on[0]]
    ;;  Define mass
    mass           = me_esa[0]                           ;;  me [eV km^(-2) s^(+2)]
  END
ENDCASE
mass_eV        = mass[0]*ckm2[0]                      ;;  [eV km^(-2) s^(+2)] --> [eV]
mass_kg        = mass_eV[0]*qq[0]/c2[0]               ;;  eV --> kg
vtsfac         = SQRT(2d0*eV2J[0]/mass_kg[0])*1d-3    ;;  Conversion factor:  Convert T [eV] to thermal speed [km/s]
;;  Check MAG_DIR
test           = (is_a_3_vector(mag_dir,V_OUT=bdir,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  brot_on = 0b
  bdir    = [1d0,0d0,0d0]
  bmag    = 1d0
ENDIF ELSE BEGIN
  brot_on = 1b
  bmag    = (mag__vec(bdir,/NAN))[0]
  bdir    = REFORM(unit_vec(bdir,/NAN))
ENDELSE
;;  Check N_S_ONLY
;IF KEYWORD_SET(n_s_only) THEN n_s_stop_on = 1b ELSE n_s_stop_on = 0b
;;  Check VFRAME
test           = (is_a_3_vector(vframe,V_OUT=vtrans,/NOMSSG) EQ 0)
IF (test[0]) THEN vframe = def_vframe ELSE vframe = vtrans
;;  Check VLIM
IF (is_a_number(vlim,/NOMSSG) EQ 0) THEN vlim = def_vlim[0] ELSE vlim = ABS(vlim[0])
IF (vlim[0] LE min_vlim[0]) THEN vlim = def_vlim[0]
;;  Check NGRID
IF (is_a_number(ngrid,/NOMSSG) EQ 0) THEN ngrid = def_ngrid[0] ELSE ngrid = (LONG(ngrid[0]) > 30L) < 300L
;;----------------------------------------------------------------------------------------
;;  Define Lorentz-transform velocities (if necessary) and add jitter
;;----------------------------------------------------------------------------------------
;;  Force VEC1 and VEC2 [cartesian coordinates --> no rotation necessary]
vec1           = [1d0,0d0,0d0]
vec2           = [0d0,1d0,0d0]
;;;  Define rotation matrices equivalent to cal_rot.pro
;;;    CAL_ROT = TRUE  --> Primed unit basis vectors are given by:
;;;           X'  :  V1
;;;           Z'  :  (V1 x V2)       = (X x V2)
;;;           Y'  :  (V1 x V2) x V1  = (Z x X)
;;  Transform VDF into VFRAME
vel_ltr        = rel_lorentz_trans_3vec(vels,vframe)
;;  Add jitter to avoid colinear errors --> Needs to be a [3,N]-element array too
vel_inp        = TRANSPOSE(vel_ltr + jitter)
;;  Define finite values (QGRID3.PRO cannot handle NaNs)
test_vdf       = FINITE(data)
test           = FINITE(vel_inp[0,*]) AND FINITE(vel_inp[1,*]) AND $
                 FINITE(vel_inp[2,*]) AND test_vdf
good_in        = WHERE(test,gd_in,COMPLEMENT=bad_in,NCOMPLEMENT=bd_in)
IF (gd_in[0] EQ 0) THEN RETURN,dumb_out
vel_inp        = TEMPORARY(vel_inp[*,good_in])
datm           = TEMPORARY(datm[good_in])
data           = TEMPORARY(data[good_in])
datp           = TEMPORARY(datp[good_in])
;;----------------------------------------------------------------------------------------
;;  Define velocity grid
;;----------------------------------------------------------------------------------------
nm             = ngrid[0]
nc             = nm[0]/2L
smax           = DOUBLE(vlim[0])
delv           = smax[0]/nc[0]
v_st           = -1d0*smax[0]
v1dgrid        = DINDGEN(nm[0])*delv[0] + v_st[0]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Perform 3D tetrahedralization
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Use convex-hull with Delaunay tetrahedralization
QHULL,vel_inp,tetra,/DELAUNAY
;;  Generate 3D f(vx,vy,vz)
fxyzm3d        = QGRID3(vel_inp,datm,tetra,DELTA=delv[0],DIMENSION=nm[0],MISSING=d,START=v_st[0])
fxyza3d        = QGRID3(vel_inp,data,tetra,DELTA=delv[0],DIMENSION=nm[0],MISSING=d,START=v_st[0])
fxyzp3d        = QGRID3(vel_inp,datp,tetra,DELTA=delv[0],DIMENSION=nm[0],MISSING=d,START=v_st[0])
;;  Check output
szfm           = SIZE(fxyzm3d,/DIMENSIONS)
szfa           = SIZE(fxyza3d,/DIMENSIONS)
szfp           = SIZE(fxyzp3d,/DIMENSIONS)
test           = (N_ELEMENTS(szfm) NE 3) OR (N_ELEMENTS(szfa) NE 3) OR (N_ELEMENTS(szfp) NE 3)
IF (test[0]) THEN BEGIN
  MESSAGE,'0:  Failed tetrahedralization: returning without integration...',/INFORMATIONAL,/CONTINUE
  RETURN,dumb_out[0]
ENDIF
testm          = (szfm[0] NE szfm[1]) OR (szfm[0] NE szfm[2])
testa          = (szfa[0] NE szfa[1]) OR (szfa[0] NE szfa[2])
testp          = (szfp[0] NE szfp[1]) OR (szfp[0] NE szfp[2])
test           = testm[0] OR testa[0] OR testp[0]
IF (test[0]) THEN BEGIN
  MESSAGE,'1:  Failed tetrahedralization: returning without integration...',/INFORMATIONAL,/CONTINUE
  RETURN,dumb_out[0]
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Construct factors for Simpson's 1/3 Rule
;;
;;    Definitions:
;;      h         :  Simpson's 1/3 Rule integration factor [km^(+3) s^(-3)]
;;                   = ∆vx*∆vy*∆vz/[3 (N - 1)]^3
;;      S_ijk     :  Simpson's 1/3 Rule coefficients [N/A]
;;      K_ijk     :  common integration factor [km^(+3) s^(-3) sr]
;;                   = (h S_ijk)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
x              = v1dgrid
y              = v1dgrid
z              = v1dgrid
;;  Define range and increment
nx             = N_ELEMENTS(x)
xran           = [MIN(x,/NAN),MAX(x,/NAN)]
yran           = xran
zran           = xran
dx             = (xran[1] - xran[0])/(nx[0] - 1L)
dy             = dx[0]
dz             = dx[0]
;;  Construct Simpson's 1/3 Rule coefficients for 1D array
sc             = REPLICATE(1d0,nx[0])
sc[1L:(nx[0] - 2L):2L] *= 4d0              ;;  Start at 2nd element and every other element should be 4
sc[2L:(nx[0] - 3L):2L] *= 2d0              ;;  Start at 3rd element and every other element should be 2
sc[(nx[0] - 1L)]        = 1d0              ;;  Make sure last element is 1
;;  Construct Simpson's 1/3 Rule 2D coefficients
scx            = sc # REPLICATE(1d0,nx[0])
;;  Convert 1D coefficients to 3D
scx3d          = REBIN(scx,nx[0],nx[0],nx[0])
scy3d          = TRANSPOSE(scx3d,[2,0,1])
scz3d          = TRANSPOSE(scy3d,[0,2,1])
scxyz          = scx3d*scy3d*scz3d
;;  Define h-factors for 3D Simpson's 1/3 Rule [assumes regular, uniform grid spacing]
hfac           = dx[0]*dy[0]*dz[0]/(3d0*3d0*3d0)
;;  Convert VGRID to 2D
v2dgrid        = v1dgrid # REPLICATE(1d0,nx[0])
;;  Convert to 3D
v3dx           = REBIN(v2dgrid,nx[0],nx[0],nx[0])
v3dy           = TRANSPOSE(v3dx,[2,0,1])
v3dz           = TRANSPOSE(v3dy,[0,2,1])
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Integrate to find velocity moments
;;
;;    Definitions:
;;      ms        :  particle mass [eV km^(-2) s^(+2)] of species s
;;      f_ijk     :  total velocity distribution function (VDF)
;;                   [# cm^(-3) km^(-3) s^(+3)]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate number density [cm^(-3)]
;;      Ns        :  Total particle density [cm^(-3)] of species s
;;                   = ∑_i ∑_j ∑_k [ K_ijk f_ijk ]
;;----------------------------------------------------------------------------------------
fm             = fxyzm3d
ff             = fxyza3d
fp             = fxyzp3d
;;  Compute 3D integral of input
n_smtot        = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*fm,3,/NAN),2,/NAN),/NAN)
n_satot        = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
n_sptot        = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*fp,3,/NAN),2,/NAN),/NAN)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate w-component of the drift velocity [km/s] in VFRAME rest frame
;;      Vos_w     :  w-Component drift velocity [km/s] of species s
;;                   = Ns^(-1) ∑_i ∑_j ∑_k [ K_ijk vw_i f_ijk ]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate X-component of the drift velocity [km/s] in VFRAME rest frame
fm             = v3dx*fxyzm3d/n_smtot[0]
ff             = v3dx*fxyza3d/n_satot[0]
fp             = v3dx*fxyzp3d/n_sptot[0]
Vosmx          = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*fm,3,/NAN),2,/NAN),/NAN)
Vosax          = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
Vospx          = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*fp,3,/NAN),2,/NAN),/NAN)
;;  Calculate Y-component of the drift velocity [km/s] in VFRAME rest frame
fm             = v3dy*fxyzm3d/n_smtot[0]
ff             = v3dy*fxyza3d/n_satot[0]
fp             = v3dy*fxyzp3d/n_sptot[0]
Vosmy          = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*fm,3,/NAN),2,/NAN),/NAN)
Vosay          = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
Vospy          = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*fp,3,/NAN),2,/NAN),/NAN)
;;  Calculate Z-component of the drift velocity [km/s] in VFRAME rest frame
fm             = v3dz*fxyzm3d/n_smtot[0]
ff             = v3dz*fxyza3d/n_satot[0]
fp             = v3dz*fxyzp3d/n_sptot[0]
Vosmz          = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*fm,3,/NAN),2,/NAN),/NAN)
Vosaz          = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
Vospz          = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*fp,3,/NAN),2,/NAN),/NAN)
;;  Define output 3-vector bulk velocity [1st moment]
Vosmxyz        = [Vosmx[0],Vosmy[0],Vosmz[0]]
Vosaxyz        = [Vosax[0],Vosay[0],Vosaz[0]]
Vospxyz        = [Vospx[0],Vospy[0],Vospz[0]]
;;  *** Clean up ***
delete_variable,v2dgrid,v3dx,v3dy,v3dz,fm,ff,fp
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  To avoid repetition, define structure for looping
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
tags           = ['MIN','NOM','PLU']
zero__mom      = CREATE_STRUCT(tags,n_smtot[0],n_satot[0],n_sptot[0])
first_mom      = CREATE_STRUCT(tags,Vosmxyz,Vosaxyz,Vospxyz)
f_of_v_st      = CREATE_STRUCT(tags,fxyzm3d,fxyza3d,fxyzp3d)
;;  Define dummy structures to fill later
Ptens__r2      = CREATE_STRUCT(tags,dumb33,dumb33,dumb33)
Ptfac__r2      = Ptens__r2
Qflinv_r1      = CREATE_STRUCT(tags,dumb3,dumb3,dumb3)
Qflfac_r1      = Qflinv_r1
Qflnor_r1      = Qflinv_r1
T3inp__r1      = Qflinv_r1
T_fac__r1      = Qflinv_r1
Pscalar_s      = CREATE_STRUCT(tags,d,d,d)
Tscalar_s      = Pscalar_s
VTscalr_s      = Pscalar_s
Taniscl_s      = Pscalar_s
;;  Loop through to define moments
FOR j=0L, 2L DO BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Define subscript-dependent parameters
  ;;--------------------------------------------------------------------------------------
  n_s_0          = zero__mom.(j)
  Vos_0          = first_mom.(j)
  fxyz_3d        = f_of_v_st.(j)
  ;;--------------------------------------------------------------------------------------
  ;;  Define peculiar velocities (w_i = v - Vos_i)
  ;;--------------------------------------------------------------------------------------
  x              = v1dgrid - Vos_0[0]
  y              = v1dgrid - Vos_0[1]
  z              = v1dgrid - Vos_0[2]
  ;;--------------------------------------------------------------------------------------
  ;;  Convert 1D random velocity variables to 3D
  ;;--------------------------------------------------------------------------------------
  ;;  X
  v2dx           = x # REPLICATE(1d0,nx[0])
  v3dx           = REBIN(v2dx,nx[0],nx[0],nx[0])          ;;  3rd dimension is just a copy of 2nd
  ;;  Y
  v2dy           = y # REPLICATE(1d0,nx[0])
  v3d0           = REBIN(v2dy,nx[0],nx[0],nx[0])
  v3dy           = TRANSPOSE(v3d0,[2,0,1])
  ;;  Z
  v2dz           = z # REPLICATE(1d0,nx[0])
  v3d0           = REBIN(v2dz,nx[0],nx[0],nx[0])
  v3dz           = TRANSPOSE(v3d0,[1,2,0])
  ;;  *** Clean up ***
  delete_variable,v2dgrid,v2dx,v2dy,v2dz,v3d0
  ;;--------------------------------------------------------------------------------------
  ;;  Update ranges and increments for h factor in Simpson's 1/3 Rule
  ;;--------------------------------------------------------------------------------------
  xran           = [MIN(x,/NAN),MAX(x,/NAN)]
  yran           = [MIN(y,/NAN),MAX(y,/NAN)]
  zran           = [MIN(z,/NAN),MAX(z,/NAN)]
  dx             = (xran[1] - xran[0])/(nx[0] - 1L)
  dy             = (yran[1] - yran[0])/(nx[0] - 1L)
  dz             = (zran[1] - zran[0])/(nx[0] - 1L)
  hfac           = dx[0]*dy[0]*dz[0]/(3d0*3d0*3d0)
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate ab-component pressure tensor component [eV cm^(-3)] in species rest frame
  ;;      Ps_ab     :  ab-Component pressure tensor component [eV cm^(-3)] of
  ;;                   species s
  ;;                   = ms ∑_i ∑_j ∑_k [ K_ijk wa_i wb_i f_ijk ]
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate XX-component pressure tensor component [eV cm^(-3)] in species rest frame
  ff             = mass[0]*v3dx*v3dx*fxyz_3d
  Press_xx       = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
  ;;  Calculate YY-component pressure tensor component [eV cm^(-3)] in species rest frame
  ff             = mass[0]*v3dy*v3dy*fxyz_3d
  Press_yy       = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
  ;;  Calculate ZZ-component pressure tensor component [eV cm^(-3)] in species rest frame
  ff             = mass[0]*v3dz*v3dz*fxyz_3d
  Press_zz       = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
  ;;  Calculate XY-component pressure tensor component [eV cm^(-3)] in species rest frame
  ff             = mass[0]*v3dx*v3dy*fxyz_3d
  Press_xy       = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
  ;;  Calculate XZ-component pressure tensor component [eV cm^(-3)] in species rest frame
  ff             = mass[0]*v3dx*v3dz*fxyz_3d
  Press_xz       = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
  ;;  Calculate YZ-component pressure tensor component [eV cm^(-3)] in species rest frame
  ff             = mass[0]*v3dy*v3dz*fxyz_3d
  Press_yz       = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate 3-vector version of heat flux tensor in species rest frame
  ;;    [eV km s^(-1) cm^(-3)]
  ;;      Qs_vec    :  abc-Component of heat flux tensor [eV km s^(-1) cm^(-3)]
  ;;                   of species s
  ;;                   Qs_x = ms/2 ∑_i ∑_j ∑_k [ K_ijk w^2 wx_i f_ijk ]
  ;;                   Qs_y = ms/2 ∑_i ∑_j ∑_k [ K_ijk w^2 wy_i f_ijk ]
  ;;                   Qs_z = ms/2 ∑_i ∑_j ∑_k [ K_ijk w^2 wz_i f_ijk ]
  ;;    *** Factor of 1/2 in Qflux to account for double-counting or difference in thermal speed definitions???  ***
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate 3D speed
;  sp3d           = SQRT(v3dx^2d0 + v3dy^2d0 + v3dz^2d0)
  sp3d2          = (v3dx^2d0 + v3dy^2d0 + v3dz^2d0)
  ;;  Calculate X-component of heat flux vector [eV km s^(-1) cm^(-3)] in species rest frame
;  ff             = mass[0]*sp3d^2d0*v3dx/2d0*fxyz_3d
  ff             = mass[0]*sp3d2*v3dx/2d0*fxyz_3d
  Qflux_x        = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
  ;;  Calculate Y-component of heat flux vector [eV km s^(-1) cm^(-3)] in species rest frame
;  ff             = mass[0]*sp3d^2d0*v3dy/2d0*fxyz_3d
  ff             = mass[0]*sp3d2*v3dy/2d0*fxyz_3d
  Qflux_y        = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
  ;;  Calculate Z-component of heat flux vector [eV km s^(-1) cm^(-3)] in species rest frame
;  ff             = mass[0]*sp3d^2d0*v3dz/2d0*fxyz_3d
  ff             = mass[0]*sp3d2*v3dz/2d0*fxyz_3d
  Qflux_z        = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*ff,3,/NAN),2,/NAN),/NAN)
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;  Define tensors
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;  Define symmetry components
  ;;    [xx,yy,zz,xy,xz,yz]
  Press_sym_v2   = [Press_xx[0],Press_yy[0],Press_zz[0],Press_xy[0],Press_xz[0],Press_yz[0]]
  ;;  Define tensors
  Press_ten_r2   = Press_sym_v2[map_r2]
  Qflux_ten_r1   = REFORM([Qflux_x[0],Qflux_y[0],Qflux_z[0]])
  ;;  Define temperature pseudotensor [eV]
  Temp__ten_r2   = Press_ten_r2/n_s_0[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Define scalar parameters
  ;;--------------------------------------------------------------------------------------
  ;;  Scalar/Avg temperature [eV]
  Temp__avg_sc   = TOTAL(Temp__ten_r2[diagr2],/NAN)/3d0
  ;;  Scalar/Avg pressure [eV cm^(-3)]
  Press_avg_sc   = TOTAL(Press_ten_r2[diagr2],/NAN)/3d0
  ;;  Scalar/Avg thermal speed [km/s]
  Vthms_avg_sc   = vtsfac[0]*SQRT(Temp__avg_sc[0])
  ;;--------------------------------------------------------------------------------------
  ;;  Diagonalize temperature pseudotensor
  ;;--------------------------------------------------------------------------------------
  T3_eigvec      = Temp__ten_r2
  LA_TRIRED,T3_eigvec,T3,dumb,/DOUBLE
  ;;  T3    -->  [3]-element array of diagonal elements of T3_EIGVEC
  ;;  DUMB  -->  [3]-element array of off-diagonal " "
  LA_TRIQL,T3,dumb,T3_eigvec,/DOUBLE,STATUS=status
  ;;  T3         -->  [3]-element array of eigenvalues
  ;;  DUMB       -->  destroyed on output
  ;;  T3_EIGVEC  -->  [3,3]-element array of eigen vectors
  IF (status[0] NE 0) THEN T3_eigvec = REPLICATE(d,3L,3L)     ;;  Failed --> fill with NaNs
  ;;  Sort the output
  sp             = SORT(T3)
  IF (T3[sp[1]] LT (T3[sp[0]] + T3[sp[2]])/2d0) THEN num = sp[2] ELSE num = sp[0]
  ;;  Shift the eigenvalues and vectors from smallest to largest
  shft           = ([-1,1,0])[num[0]]
  T3             = SHIFT(T3,shft)
  T3_eigvec      = SHIFT(T3_eigvec,0,shft)
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;  Rotate into field-aligned coordinates (FACs) [if user desires]
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  IF (brot_on[0]) THEN BEGIN
    b_dot_s        = TOTAL((bdir # [1,1,1])*T3_eigvec,1,/NAN)
    dummy          = MAX(ABS(b_dot_s),numx,/NAN)
    mrot           = rot_mat(bdir)
    ;;  Rotate pressure tensor  [xx,yy,zz,xy,xz,yz] --> [perp1,perp2,para,p1p2,p1a,p2a]
;    Press_fac_r2   = rotate_tensor(Press_ten_r2,mrot)
    Press_fac_r2   = (mrot ## Press_ten_r2)
    Press_fac_v2   = Press_fac_r2[map_v2]
    ;;  Define temperature [eV] components in FACs  [perp1,perp2,para]
    T3FAC          = Press_fac_v2[0:2]/n_s_0[0]
    ;;  Define temperature anisotropy Tperp/Tpara
    Tanis          = (T3FAC[0] + T3FAC[1])/T3FAC[2]/2d0
    ;;  Rotate heat flux tensor [eV km s^(-1) cm^(-3)]
    Qflux_fac_r1   = TRANSPOSE(mrot ## Qflux_ten_r1)
;    Qflux_fac_r1   = rotate_tensor(Qflux_ten_r1,mrot)
    ;;  Define field-aligned heat flux vector [eV km s^(-1) cm^(-3)]
    Qflux_fac_v3   = Qflux_fac_r1
    ;;  Define free-streaming heat flux [eV km s^(-1) cm^(-3)]
    ;;    q_s,tot = 3/2 ms Ns (V_Ts,//)^3
    ;;        where V_Tj is the 1D rms thermal speed here so it differs by a factor of
    ;;        two from the 1D most probable speed, thus the 2^(-3/2) below
    ;;    [e.g., Gary et al., 1999 Phys. Plasmas Vol. 6(6)]
    vts_para       = vtsfac[0]*SQRT(T3FAC[2])
    qet_norm       = 3d0*mass[0]*n_s_0[0]*vts_para[0]^3d0/2d0/(2d0^(3d0/2d0))
    ;;  Define normalized heat flux vector [perp1,perp2,para]
    Qflux_fac_n3   = Qflux_fac_v3/qet_norm[0]
  ENDIF ELSE BEGIN
    Press_fac_r2   = d*Press_ten_v2
    T3FAC          = d*T3
    Tanis          = d
    Qflux_fac_v3   = REPLICATE(d,3L)
    Qflux_fac_n3   = Qflux_fac_v3
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;  Fill output structures
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  Ptens__r2.(j)  = Press_ten_r2
  Qflinv_r1.(j)  = Qflux_ten_r1
  Pscalar_s.(j)  = Temp__avg_sc[0]
  Tscalar_s.(j)  = Press_avg_sc[0]
  VTscalr_s.(j)  = Vthms_avg_sc[0]
  T3inp__r1.(j)  = T3
  Ptfac__r2.(j)  = Press_fac_r2
  T_fac__r1.(j)  = T3FAC
  Qflfac_r1.(j)  = Qflux_fac_v3
  Qflnor_r1.(j)  = Qflux_fac_n3
  Taniscl_s.(j)  = Tanis[0]
ENDFOR
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define terms in output structure
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Scalars
dumb_out.N_S          = [n_smtot[0],n_satot[0],n_sptot[0]]
dumb_out.PRESS_SCALAR = [Pscalar_s.(0L),Pscalar_s.(1L),Pscalar_s.(2L)]
dumb_out.TAVG         = [Tscalar_s.(0L),Tscalar_s.(1L),Tscalar_s.(2L)]
dumb_out.VTHERMAL     = [VTscalr_s.(0L),VTscalr_s.(1L),VTscalr_s.(2L)]
dumb_out.TANISOTROPY  = [Taniscl_s.(0L),Taniscl_s.(1L),Taniscl_s.(2L)]
;;  3-vectors
FOR k=0L, 2L DO BEGIN
 dumb_out.VOS_XYZ[*,k]        = first_mom.(k)
 dumb_out.TEMP_3XYZ[*,k]      = T3inp__r1.(k)
 dumb_out.TEMP_3FAC[*,k]      = T_fac__r1.(k)
 dumb_out.QFLUX_3VEC_XYZ[*,k] = Qflinv_r1.(k)
 dumb_out.QFLUX_3VEC_FAC[*,k] = Qflfac_r1.(k)
 dumb_out.QFLUX_3VEC_NOR[*,k] = Qflnor_r1.(k)
ENDFOR
;;  rank-2 tensors
dumb_out.PRESS_TENXYZ[*,*,0L] = Ptens__r2.(0L)
dumb_out.PRESS_TENXYZ[*,*,1L] = Ptens__r2.(1L)
dumb_out.PRESS_TENXYZ[*,*,2L] = Ptens__r2.(2L)
dumb_out.PRESS_TENFAC[*,*,0L] = Ptfac__r2.(0L)
dumb_out.PRESS_TENFAC[*,*,1L] = Ptfac__r2.(1L)
dumb_out.PRESS_TENFAC[*,*,2L] = Ptfac__r2.(2L)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN,dumb_out[0]
END


;+
;*****************************************************************************************
;
;  FUNCTION :   calc_really_fast_vmoms_w_uncer_from_pois.pro
;  PURPOSE  :   This routine calculates the standard velocity moments of f(v) but includes
;                 uncertainties by calculating f(v) ± ∂f(v).  The outputs for each
;                 structure tag are given as [f(v) - ∂f, f(v), f(v) + ∂f], e.g., the
;                 VOS_XYZ tag is a [3,3]-element [numeric] array where the 3-vector
;                 from the (f(v) - ∂f) contribution is given by outstr.VOS_XYZ[*,0]
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               sub_fast_short_ninteg_3d_vdf.pro
;
;  CALLS:
;               sub_fast_short_ninteg_3d_vdf.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VELS       :  [K,3]-Element [numeric] array of particle velocities [km/s]
;               DATA       :  [K]-Element [numeric] array of phase (velocity) space
;                               densities
;                               [e.g., s^(3) cm^(-3) km^(-3)]
;               POIS       :  [K]-Element [numeric] array of phase space densities for
;                               the Poisson statistics of the values in DATA
;                               [e.g., s^(3) cm^(-3) km^(-3)]
;
;  EXAMPLES:    
;               [calling sequence]
;               calc_really_fast_vmoms_w_uncer_from_pois,vels,data,pois [,VLIM=vlim]    $
;                          [,NGRID=ngrid] [,VFRAME=vframe] [,ELECTRON=electron]         $
;                          [,PROTON=proton] [,ALPHA_P=alpha_p] [,MAG_DIR=mag_dir]       $
;                          [,VEC1=vec1] [,VEC2=vec2]
;
;  KEYWORDS:    
;               ***  INPUTS  ***
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
;               ELECTRON   :  If set, use electron mass [eV/(km/sec)^2]
;                                [Default = TRUE if MASS = FALSE]
;               PROTON     :  If set, use proton mass [eV/(km/sec)^2]
;                                [Default = FALSE]
;               ALPHA_P    :  If set, use alpha-particle mass [eV/(km/sec)^2]
;                               [Default = FALSE]
;               MAG_DIR    :  [3]-Element vector to be used to define the magnetic field
;                               direction to which the cartesian data will be rotated
;                               [ Default = [1,0,0] ]
;               N_S_ONLY   :  If set, routine will return the velocity moment structure
;                               but only with the number density value calculated
;               ***  Pre-Set INPUTS  ***
;               VEC1       :  [3]-Element vector to be used for X-direction in
;                               a 3D rotation of the input data
;                               [e.g., see rotate_3dp_structure.pro]
;                               [ Default = [1.,0.,0.] ]
;               VEC2       :  [3]--Element vector to be used with VEC1 to define a 3D
;                               rotation matrix.  The new basis will have the following:
;                                 X'  :  parallel to VEC1
;                                 Z'  :  parallel to (VEC1 x VEC2)
;                                 Y'  :  completes the right-handed set
;                               [ Default = [0.,1.,0.] ]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [04/14/2025   v1.0.0]
;             2)  Continued to write routine
;                                                                   [04/15/2025   v1.0.0]
;
;   NOTES:      0)  Adapted from calc_fast_velmoms_with_uncer_from_pois.pro to increase
;                     computation speed when calling 1000s of times in a row
;               Velocity moments:
;                 Note:  d^3v --> v_perp dv_perp dv_para dphi --> π |v_perp| dv_perp dv_para
;                             --> dvx dvy dvz  {for cartesian coordinates}
;
;                 Definitions:
;                   ms        :  particle mass [eV km^(-2) s^(+2)] of species s
;                   h         :  Simpson's 1/3 Rule integration factor [km^(+3) s^(-3)]
;                                = ∆vx*∆vy*∆vz/[3 (N - 1)]^3
;                   S_ijk     :  Simpson's 1/3 Rule coefficients [N/A]
;                   K_ijk     :  common integration factor [km^(+3) s^(-3) sr]
;                                = (h S_ijk)
;                   f_ijk     :  total velocity distribution function (VDF)
;                                [# cm^(-3) km^(-3) s^(+3)]
;                   qmax      :  free-streaming heat flux [eV km s^(-1) cm^(-3)]
;                                = 3/2 me Ne (V_Tec,//)^3
;
;                 Velocity Moments:
;                   Ns        :  Total particle density [cm^(-3)] of species s
;                                = ∑_i ∑_j ∑_k [ K_ijk f_ijk ]
;                   Vos_x     :  X-Component drift velocity [km/s] of species s
;                                = Ns^(-1) ∑_i ∑_j ∑_k [ K_ijk vx_i f_ijk ]
;                   Vos_y     :  Y-Component drift velocity [km/s] of species s
;                                = Ns^(-1) ∑_i ∑_j ∑_k [ K_ijk vy_j f_ijk ]
;                   Vos_z     :  Z-Component drift velocity [km/s] of species s
;                                = Ns^(-1) ∑_i ∑_j ∑_k [ K_ijk vz_k f_ijk ]
;                   Ps_xx     :  XX-Component pressure tensor component [eV cm^(-3)] of
;                                species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vx_i vx_i f_ijk ]
;                   Ps_yy     :  YY-Component pressure tensor component [eV cm^(-3)] of
;                                species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vy_j vy_j f_ijk ]
;                   Ps_zz     :  ZZ-Component pressure tensor component [eV cm^(-3)] of
;                                species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vz_k vz_k f_ijk ]
;                   Ps_xy     :  XY-Component pressure tensor component [eV cm^(-3)] of
;                                species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vx_i vy_j f_ijk ]
;                   Ps_xz     :  XZ-Component pressure tensor component [eV cm^(-3)] of
;                                species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vx_i vz_k f_ijk ]
;                   Ps_yz     :  YZ-Component pressure tensor component [eV cm^(-3)] of
;                                species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vy_j vz_k f_ijk ]
;                   Qs_xxx    :  XXX-Component of heat flux tensor [eV km s^(-1) cm^(-3)]
;                                of species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vx_i vx_i vx_i f_ijk ]
;                   Qs_yyy    :  YYY-Component of heat flux tensor [eV km s^(-1) cm^(-3)]
;                                of species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vy_j vy_j vy_j f_ijk ]
;                   Qs_zzz    :  ZZZ-Component of heat flux tensor [eV km s^(-1) cm^(-3)]
;                                of species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vz_k vz_k vz_k f_ijk ]
;                   Qs_xxy    :  XXY-Component of heat flux tensor [eV km s^(-1) cm^(-3)]
;                                of species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vx_i vx_i vy_j f_ijk ]
;                   Qs_xxz    :  XXZ-Component of heat flux tensor [eV km s^(-1) cm^(-3)]
;                                of species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vx_i vx_i vz_k f_ijk ]
;                   Qs_yyz    :  YYZ-Component of heat flux tensor [eV km s^(-1) cm^(-3)]
;                                of species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vy_j vy_j vz_k f_ijk ]
;                   Qs_xyy    :  XYY-Component of heat flux tensor [eV km s^(-1) cm^(-3)]
;                                of species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vx_i vy_j vy_j f_ijk ]
;                   Qs_xzz    :  XZZ-Component of heat flux tensor [eV km s^(-1) cm^(-3)]
;                                of species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vx_i vz_k vz_k f_ijk ]
;                   Qs_yzz    :  YZZ-Component of heat flux tensor [eV km s^(-1) cm^(-3)]
;                                of species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vy_j vz_k vz_k f_ijk ]
;                   Qs_xyz    :  XYZ-Component of heat flux tensor [eV km s^(-1) cm^(-3)]
;                                of species s
;                                = ms ∑_i ∑_j ∑_k [ K_ijk vx_i vy_j vz_k f_ijk ]
;
;  REFERENCES:  
;               0)  Simpson's 1/3 Rule References:
;                 http://mathfaculty.fullerton.edu/mathews/n2003/SimpsonsRule2DMod.html
;                 http://www.physics.usyd.edu.au/teach_res/mp/doc/math_integration_2D.pdf
;                 https://en.wikipedia.org/wiki/Simpson%27s_rule
;               1)  See IDL's documentation for:
;                     QHULL.PRO:        https://harrisgeospatial.com/docs/qhull.html
;                     QGRID3.PRO:       https://harrisgeospatial.com/docs/QGRID3.html
;                     TRIANGULATE.PRO:  https://harrisgeospatial.com/docs/TRIANGULATE.html
;                     TRIGRID.PRO:      https://harrisgeospatial.com/docs/TRIGRID.html
;               2)  Carlson et al., (1983), "An instrument for rapidly measuring
;                      plasma distribution functions with high resolution,"
;                      Adv. Space Res. Vol. 2, pp. 67-70.
;               3)  Curtis et al., (1989), "On-board data analysis techniques for
;                      space plasma particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372.
;               4)  Lin et al., (1995), "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125.
;               5)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               6)  Wilson III, L.B., et al., "The Statistical Properties of Solar Wind
;                      Temperature Parameters Near 1 au," Astrophys. J. Suppl. 236(2),
;                      pp. 41, doi:10.3847/1538-4365/aab71c, 2018.
;               7)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      Astrophys. J. Suppl. 243(8), doi:10.3847/1538-4365/ab22bd, 2019a.
;               8)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: II. Statistics,"
;                      Astrophys. J. Suppl. 245(24), doi:10.3847/1538-4365/ab5445, 2019b.
;               9)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: III. Analysis,"
;                      Astrophys. J., Accepted Mar. 4, 2020.
;
;   CREATED:  04/11/2025
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/15/2025   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION calc_really_fast_vmoms_w_uncer_from_pois,vels,data,pois,VLIM=vlim,NGRID=ngrid,    $
                                                  VFRAME=vframe,ELECTRON=electron,         $
                                                  PROTON=proton,ALPHA_P=alpha_p,           $
                                                  MAG_DIR=mag_dir,VEC1=vec1,VEC2=vec2

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
toler          = 1d-6                                     ;;  Tolerance for jitter
;;  Dummy error messages
no_inpt__mssg  = 'User must supply VELS, DATA, and POIS as [numeric] arrays...'
badndim__mssg  = 'Inputs DATA and POIS must be one-dimensional [numeric] arrays and VELS must be a two-dimensional [numeric] array...'
badddim__mssg  = 'Inputs DATA and POIS must be [K]-element [numeric] arrays and VELS must be a [K,3]-element [numeric] array...'
;;----------------------------------------------------------------------------------------
;;  Define dummy output structure
;;----------------------------------------------------------------------------------------
tags           = ['N_S','VOS_XYZ','PRESS_TENXYZ','PRESS_TENFAC','PRESS_SCALAR',    $
                  'TEMP_3XYZ','TAVG','VTHERMAL','TEMP_3FAC','TANISOTROPY',         $
                  'QFLUX_3VEC_XYZ','QFLUX_3VEC_FAC','QFLUX_3VEC_NOR','UNITS']
units          = ['cm^(-3)','km/s','eV cm^(-3)','eV cm^(-3)','eV','eV','km/s',     $
                  'eV','N/A','eV km s^(-1) cm^(-3)','eV km s^(-1) cm^(-3)','N/A']
dumb3          = REPLICATE(d,3L)
dumb33         = REPLICATE(d,3L,3L)
dumb333        = REPLICATE(d,3L,3L,3L)
;dumb_out       = CREATE_STRUCT(tags,d,dumb3,dumb33,dumb33,d,dumb3,d,d,dumb3,d,dumb3,dumb3,dumb3,units)
dumb_one       = CREATE_STRUCT(tags,d,dumb3,dumb33,dumb33,d,dumb3,d,d,dumb3,d,dumb333,dumb3,dumb3,units)
dumb_out       = CREATE_STRUCT(tags,dumb3,dumb33,dumb333,dumb333,dumb3,dumb33,dumb3,dumb3,dumb33,dumb3,dumb33,dumb33,dumb33,units)
;;----------------------------------------------------------------------------------------
;;  Assume input is good and skip error handling for speed
;;----------------------------------------------------------------------------------------
;;  Define f(v) ± ∂f(v)
vxyz           = vels
f_of_v         = REFORM(data)
nnd            = N_ELEMENTS(f_of_v)
f_p_df         = f_of_v + REFORM(pois)
f_m_df         = (f_of_v - REFORM(pois)) > 0d0
;;----------------------------------------------------------------------------------------
;;  Integrate f(v) ± ∂f(v)
;;----------------------------------------------------------------------------------------
fopm_moms      = sub_fast_short_ninteg_3d_vdf(vxyz,f_m_df,f_of_v,f_p_df,VLIM=vlim,NGRID=ngrid,  $
                                              VFRAME=vframe,ELECTRON=electron,PROTON=proton,    $
                                              ALPHA_P=alpha_p,MAG_DIR=mag_dir,                  $
                                              VEC1=vec1,VEC2=vec2)

IF (SIZE(fopm_moms,/TYPE) NE 8) THEN out_struc = dumb_out ELSE out_struc = fopm_moms
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,out_struc[0]
END










