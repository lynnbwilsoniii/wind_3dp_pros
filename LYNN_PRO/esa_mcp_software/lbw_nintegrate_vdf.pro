;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_nintegrate_vdf.pro
;  PURPOSE  :   Performs a numerical integration of a 3D velocity distribution function
;                 (VDF), using Simpson's 1/3 Rule, to find the velocity moments up to
;                 the heat flux.  The results are assumed to be in a field-aligned
;                 coordinate basis defined by keywords VEC1 (parallel) and VEC2
;                 [perp. = (VEC1 x VEC2) x VEC1].
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               load_constants_fund_em_atomic_c2014_batch.pro
;               load_constants_extra_part_co2014_ci2015_batch.pro
;               get_rotated_and_triangulated_vdf.pro
;               simpsons_13_2d_integration.pro
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
;               vmom_str = lbw_nintegrate_vdf(vels, data [,VLIM=vlim] [,NGRID=ngrid]    $
;                                             [,/SLICE2D] [,VFRAME=vframe] [,VEC1=vec1] $
;                                             [,VEC2=vec2] [,/ELECTRON] [,/PROTON]      $
;                                             [,/ALPHA_P])
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
;               SLICE2D    :  If set, routine will return a 2D slice instead of a 3D
;                               projection
;                               [Default = TRUE]
;               VFRAME     :  [3]-Element [float/double] array defining the 3-vector
;                               velocity of the K'-frame relative to the K-frame [km/s]
;                               to use to transform the velocity distribution into the
;                               bulk flow reference frame
;                               [ Default = [10,0,0] ]
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
;               ELECTRON   :  If set, use electron mass [eV/(km/sec)^2]
;                                [Default = TRUE if MASS = FALSE]
;               PROTON     :  If set, use proton mass [eV/(km/sec)^2]
;                                [Default = FALSE]
;               ALPHA_P    :  If set, use alpha-particle mass [eV/(km/sec)^2]
;                               [Default = FALSE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               Velocity moments:
;                 Note:  d^3v --> v_perp dv_perp dv_para dphi --> π |v_perp| dv_perp dv_para
;
;                 Definitions:
;                   ms        :  particle mass [eV km^(-2) s^(+2)] of species s
;                   I0_ij     :  gyrotropic VDF integration factor [km s^(-1) sr]
;                                = π |v_perp_ij|
;                   S_ij      :  Simpson's 1/3 Rule coefficients [N/A]
;                   h         :  Simpson's 1/3 Rule integration factor [km^(+2) s^(-2)]
;                                = ∆(v_para)*∆(v_perp)/[3 (N - 1)]^2
;                   K_ij      :  common integration factor [km^(+3) s^(-3) sr]
;                                = (h I0_ij S_ij)
;                   f_ij      :  total velocity distribution function (VDF)
;                                [# cm^(-3) km^(-3) s^(+3)]
;                   Vsq_ij    :  inner product of velocity coordinates with itself
;                                [km^(+2) s^(-2)]
;                                = |V_ij . V_ij|
;                   qmax      :  free-streaming heat flux [eV km s^(-1) cm^(-3)]
;                                = 3/2 me Ne (V_Tec,//)^3
;
;                 Velocity Moments:
;                   Ns        :  Total particle density [cm^(-3)] of species s
;                                = ∑_i ∑_j [ K_ij f_ij ]
;                   Vos_par   :  Parallel drift velocity [km/s] of species s
;                                = Ns^(-1) ∑_i ∑_j [ K_ij v_para_ij f_ij ]
;                   Vos_per   :  Perpendicular drift velocity [km/s] of species s
;                                = Ns^(-1) ∑_i ∑_j [ K_ij v_perp_ij f_ij ]
;                   Ps_para   :  Parallel pressure tensor component [eV cm^(-3)] of
;                                species s
;                                = ms ∑_i ∑_j [ K_ij v_para_ij v_para_ij f_ij ]
;                   Ps_perp   :  Perpendicular pressure tensor component [eV cm^(-3)] of
;                                species s
;                                = ms/2 ∑_i ∑_j [ K_ij v_perp_ij v_perp_ij f_ij ]
;                   Q_s_xxx   :  Parallel-only element of heat flux tensor
;                                [eV km s^(-1) cm^(-3)] of species s
;                                = ms/2 ∑_i ∑_j [ K_ij v_para_ij v_para_ij v_para_ij f_ij ]
;                   Q_s_yyy   :  Perpendicular-only element of heat flux tensor
;                                [eV km s^(-1) cm^(-3)] of species s
;                                = ms/2 ∑_i ∑_j [ K_ij v_perp_ij v_perp_ij v_perp_ij f_ij ]
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
;   CREATED:  03/24/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/24/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_nintegrate_vdf,vels,data,VLIM=vlim,NGRID=ngrid,SLICE2D=slice2d,VFRAME=vframe,$
                                      VEC1=vec1,VEC2=vec2,ELECTRON=electron,PROTON=proton,$
                                      ALPHA_P=alpha_p

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
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN RETURN,0b
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check SLICE2D
IF ((N_ELEMENTS(slice2d) EQ 1) AND ~KEYWORD_SET(slice2d)) THEN slice_on = 0b ELSE slice_on = 1b
;;  Check ELECTRON
IF ((N_ELEMENTS(electron) EQ 1) AND ~KEYWORD_SET(electron)) THEN elec_on = 0b ELSE elec_on = 1b
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
  0L    :  mass = me_esa[0]          ;;  me [eV km^(-2) s^(+2)]
  1L    :  mass = mp_esa[0]          ;;  mp [eV km^(-2) s^(+2)]
  2L    :  mass = ma_esa[0]          ;;  ma [eV km^(-2) s^(+2)]
  ELSE  :  STOP     ;;  Shouldn't happen --> debug
ENDCASE
mass_eV        = mass[0]*ckm2[0]         ;;  [eV km^(-2) s^(+2)] --> [eV]
mass_kg        = mass_eV[0]*qq[0]/c2[0]  ;;  eV --> kg
;;----------------------------------------------------------------------------------------
;;  Get rotated and triangulated structures
;;----------------------------------------------------------------------------------------
rt_struc       = get_rotated_and_triangulated_vdf(vels,data,VLIM=vlim,NGRID=ngrid,  $
                                                  SLICE2D=slice_on[0],VFRAME=vframe,$
                                                  VEC1=vec1,VEC2=vec2)
;;  Check output
IF (SIZE(rt_struc,/TYPE) NE 8) THEN STOP
;;  Define relevant parameters
v1dgrid        = rt_struc[0].VX2D
f2dgrid        = rt_struc[0].PLANE_XY[0].DF2D_XY
nx             = N_ELEMENTS(v1dgrid)
;;  Define 2D velocities and speed squared
vpar2d         = (v1dgrid # REPLICATE(1d0,nx[0]))
vper2d         = (REPLICATE(1d0,nx[0]) # v1dgrid)
vsqr2d         = ABS(v1dgrid # v1dgrid)
;;  Define integration factor common to all moments
ifact          = !DPI*ABS(vper2d)
ones           = REPLICATE(1d0,nx[0])
;;----------------------------------------------------------------------------------------
;;  Integrate to find velocity moments
;;----------------------------------------------------------------------------------------
;;  Velocity moments:
;;    Note:  d^3v --> v_perp dv_perp dv_para dphi --> π |v_perp| dv_perp dv_para
;;
;;    Definitions:
;;      ms        :  particle mass [eV km^(-2) s^(+2)] of species s
;;      I0_ij     :  gyrotropic VDF integration factor [km s^(-1) sr]
;;                   = π |v_perp_ij|
;;      S_ij      :  Simpson's 1/3 Rule coefficients [N/A]
;;      h         :  Simpson's 1/3 Rule integration factor [km^(+2) s^(-2)]
;;                   = ∆(v_para)*∆(v_perp)/[3 (N - 1)]^2
;;      K_ij      :  common integration factor [km^(+3) s^(-3) sr]
;;                   = (h I0_ij S_ij)
;;      f_ij      :  total velocity distribution function (VDF) [# cm^(-3) km^(-3) s^(+3)]
;;      Vsq_ij    :  inner product of velocity coordinates with itself [km^(+2) s^(-2)]
;;                   = |V_ij . V_ij|
;;      qmax      :  free-streaming heat flux [eV km s^(-1) cm^(-3)]
;;                   = 3/2 me Ne (V_Tec,//)^3
;;
;;    Velocity Moments:
;;      Ns        :  Total particle density [cm^(-3)] of species s
;;                   = ∑_i ∑_j [ K_ij f_ij ]
;;      Vos_par   :  Parallel drift velocity [km/s] of species s
;;                   = Ns^(-1) ∑_i ∑_j [ K_ij v_para_ij f_ij ]
;;      Vos_per   :  Perpendicular drift velocity [km/s] of species s
;;                   = Ns^(-1) ∑_i ∑_j [ K_ij v_perp_ij f_ij ]
;;      Ps_para   :  Parallel pressure tensor component [eV cm^(-3)] of species s
;;                   = ms ∑_i ∑_j [ K_ij v_para_ij v_para_ij f_ij ]
;;      Ps_perp   :  Perpendicular pressure tensor component [eV cm^(-3)] of species s
;;                   = ms/2 ∑_i ∑_j [ K_ij v_perp_ij v_perp_ij f_ij ]
;;      Q_s_xxx   :  Parallel-only element of heat flux tensor [eV km s^(-1) cm^(-3)] of species s
;;                   = ms/2 ∑_i ∑_j [ K_ij v_para_ij v_para_ij v_para_ij f_ij ]
;;      Q_s_yyy   :  Perpendicular-only element of heat flux tensor [eV km s^(-1) cm^(-3)] of species s
;;                   = ms/2 ∑_i ∑_j [ K_ij v_perp_ij v_perp_ij v_perp_ij f_ij ]
;;----------------------------------------------------------------------------------------
;;  Calculate number density [cm^(-3)]
x              = v1dgrid
y              = v1dgrid
z              = ifact*f2dgrid
n_s_tot        = simpsons_13_2d_integration(x,y,z,/LOG,/NOMSSG)
IF (FINITE(n_s_tot[0]) EQ 0) THEN STOP
;;  Calculate parallel drift velocity [km/s] in VFRAME rest frame
z              = ifact*vpar2d*f2dgrid/n_s_tot[0]
Vos_par        = simpsons_13_2d_integration(x,y,z,/LOG,/NOMSSG)
;;  Calculate perpendicular drift velocity [km/s] in VFRAME rest frame
z              = ifact*vper2d*f2dgrid/n_s_tot[0]
Vos_per        = simpsons_13_2d_integration(x,y,z,/LOG,/NOMSSG)
;;  Refine 2D velocities and speed squared
x              = v1dgrid - Vos_par[0]
y              = v1dgrid - Vos_per[0]
vpar2d        = (x # ones)
vper2d        = (ones # y)
vsqr2d         = ABS(x # y)
;;  Redefine integration factor common to all moments
ifact          = !DPI*ABS(vper2d)
;;  Calculate parallel pressure tensor component [eV cm^(-3)] in species rest frame
z              = ifact*mass[0]*vpar2d*vpar2d*f2dgrid
Pres_par       = simpsons_13_2d_integration(x,y,z,/LOG,/NOMSSG)
;;  Calculate perpendicular pressure tensor component [eV cm^(-3)] in species rest frame
z              = ifact*mass[0]*vper2d*vper2d*f2dgrid/2d0
Pres_per       = simpsons_13_2d_integration(x,y,z,/LOG,/NOMSSG)
;;  Calculate parallel-only element of heat flux tensor [eV km s^(-1) cm^(-3)] in species rest frame
z              = ifact*mass[0]*vpar2d*vpar2d*vpar2d*f2dgrid/2d0
Qflx_par       = simpsons_13_2d_integration(x,y,z,/LOG,/NOMSSG)
;;  Calculate perpendicular-only element of heat flux tensor [eV km s^(-1) cm^(-3)] in species rest frame
z              = ifact*mass[0]*vper2d*vper2d*vper2d*f2dgrid/2d0
Qflx_per       = simpsons_13_2d_integration(x,y,z,/LOG,/NOMSSG)
;;  Convert heat flux to µW m^(-2)
qfact          = 1d6*1d3*qq[0]*1d6      ;;  cm^(-3) --> m^(-3), km --> m, eV --> J, W --> µW
Qflx_par2      = qfact[0]*Qflx_par[0]
Qflx_per2      = qfact[0]*Qflx_per[0]
;;  Calculate temperatures [eV] from pressures
Temp_par       = Pres_par[0]/n_s_tot[0]
Temp_per       = Pres_per[0]/n_s_tot[0]
Temp_tot       = (Temp_par[0] + 2d0*Temp_per[0])/3d0
Temp_all       = [Temp_par[0],Temp_per[0],Temp_tot[0]]
;;  Calculate temperature anisotropy [N/A] from temperatures
Tani___s       = Temp_per[0]/Temp_par[0]
;;  Define thermal speeds [km/s]
vtsfac         = SQRT(2d0*eV2J[0]/mass_kg[0])*1d-3
vts_all        = vtsfac[0]*SQRT(Temp_all)
;;   Define free-streaming heat flux [eV km s^(-1) cm^(-3)]
;;     q_s,tot = 3/2 ms Ns (V_Ts,//)^3
;;     [e.g., Gary et al., 1999 Phys. Plasmas Vol. 6(6)]
qet_norm       = 3d0*mass[0]*n_s_tot[0]*vts_all[0]^3d0/2d0/(2d0^(3d0/2d0))
;;  Define normalized heat fluxes
Qflx_parn      = Qflx_par[0]/qet_norm[0]
Qflx_pern      = Qflx_per[0]/qet_norm[0]
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
tags           = ['n_s','vos_par_per','Press_par_per','Temp_par_per_tot','Tanisotropy',$
                  'Vthermal_par_per_tot','Qflux_par_per','Qflux_par_per_muW_m2',       $
                  'Qflux_max','Qflux_norm_par_per','units']
units          = ['cm^(-3)','km/s','eV cm^(-3)','eV','N/A','km/s','eV km s^(-1) cm^(-3)',$
                  'µW m^(-2)','eV km s^(-1) cm^(-3)','N/A']
struc          = CREATE_STRUCT(tags,n_s_tot[0],[Vos_par[0],Vos_per[0]],[Pres_par[0],Pres_per[0]],$
                                    Temp_all,Tani___s[0],vts_all,[Qflx_par[0],Qflx_per[0]],      $
                                    [Qflx_par2[0],Qflx_per2[0]],qet_norm[0],                     $
                                    [Qflx_parn[0],Qflx_pern[0]],units)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc[0]
END








