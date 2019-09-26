;+
;*****************************************************************************************
;
;  FUNCTION :   setup_def_4_parinfo_struc4mpfit_4_vdfs.pro
;  PURPOSE  :   This routine sets up the default options and parameters for calling the
;                 MPFIT software to fit model functions to observed velocity distribution
;                 functions (VDFs) of electrons or ions.
;
;  CALLED BY:   
;               wrapper_model_fit_vdf_2_so3fs.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               load_constants_fund_em_atomic_c2014_batch.pro
;               is_a_number.pro
;               test_ranges_4_mpfitparinfostruc.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               test = setup_def_4_parinfo_struc4mpfit_4_vdfs(                                                     $
;                                          [,CFUNC=cfunc] [,HFUNC=hfunc] [,BFUNC=bfunc]                            $
;                                          [,CPARM=cparm] [,HPARM=hparm] [,BPARM=bparm]                            $
;                                          [,/ELECTRONS] [,/IONS]                                                  $
;                                          [,FIXED_C=fixed_c] [,FIXED_H=fixed_h] [,FIXED_B=fixed_b]                $
;                                          [,NCORE_RAN=ncore_ran] [,NHALO_RAN=nhalo_ran] [,NBEAM_RAN=nbeam_ran]    $
;                                          [,VTACORERN=vtacorern] [,VTAHALORN=vtahalorn] [,VTABEAMRN=vtabeamrn]    $
;                                          [,VTECORERN=vtecorern] [,VTEHALORN=vtehalorn] [,VTEBEAMRN=vtebeamrn]    $
;                                          [,VOACORERN=voacorern] [,VOAHALORN=voahalorn] [,VOABEAMRN=voabeamrn]    $
;                                          [,VOECORERN=voecorern] [,VOEHALORN=voehalorn] [,VOEBEAMRN=voebeamrn]    $
;                                          [,EXPCORERN=expcorern] [,EXPHALORN=exphalorn] [,EXPBEAMRN=expbeamrn]    $
;                                          [,ES2CORERN=es2corern] [,ES2HALORN=es2halorn] [,ES2BEAMRN=es2beamrn]    $
;                                          [,CFACT=cfact] [,HFACT=hfact] [,BFACT=bfact]                            $
;                                          [,FTOL=ftol] [,GTOL=gtol] [,XTOL=xtol] [,USE_MM=use_mm]                 $
;                                          [,DEF_OFFST=def_offst] [,PARINFO=def_pinf] [,HARINFO=def_hinf]          $
;                                          [,BARINFO=def_binf] [,FUNC_C=func_c] [,FUNC_H=func_h] [,FUNC_B=func_b]  $
;                                          [,CORE_LABS=core_labs] [,HALO_LABS=halo_labs] [,BEAM_LABS=beam_labs]    $
;                                          [,XYLAB_PRE=xylabpre]                                                   )
;
;               ;;  ************************************************************
;               ;;  Example usage
;               ;;  ************************************************************
;               cfunc = 'SS' & hfunc = 'KK' & bfunc = 'KK'
;               ;;  Don't worry about sign of drift speeds yet
;               cparm = [5d0,18d2,20d2,1d1,1d1,3d0] & hparm = [5d-1,45d2,5d3,1d3,0d0,3d0] & bparm = [1d-1,4d3,45d2,3d3,0d0,4d0]
;               ncore_ran = [1,1,2d0,8d0]   & nhalo_ran = [1,1,1d-2,1d0]  & nbeam_ran = [1,1,1d-3,1d0]
;               vtacorern = [1,1,15d2,15d3] & vtahalorn = [1,1,25d2,15d3] & vtabeamrn = [1,1,25d2,15d3]
;               vtecorern = [1,1,15d2,15d3] & vtehalorn = [1,1,25d2,15d3] & vtebeamrn = [1,1,25d2,15d3]
;               voacorern = [1,1,-1d3,1d3]  & voahalorn = [1,1,0d0,1d4]   & voabeamrn = [1,1,25d2,1d4]
;               expcorern = [1,1,2d0,1d1]   & exphalorn = [1,1,2d0,2d1]   & expbeamrn = [1,1,2d0,2d1]
;
;               .compile setup_def_4_parinfo_struc4mpfit_4_vdfs.pro
;               test = setup_def_4_parinfo_struc4mpfit_4_vdfs(CFUNC=cfunc,HFUNC=hfunc,BFUNC=bfunc,             $
;                                                 CPARM=cparm,HPARM=hparm,BPARM=bparm,/ELECTRONS,              $
;                                                 FIXED_C=fixed_c,FIXED_H=fixed_h,FIXED_B=fixed_b,             $
;                                                 NCORE_RAN=ncore_ran,NHALO_RAN=nhalo_ran,NBEAM_RAN=nbeam_ran, $
;                                                 VTACORERN=vtacorern,VTAHALORN=vtahalorn,VTABEAMRN=vtabeamrn, $
;                                                 VTECORERN=vtecorern,VTEHALORN=vtehalorn,VTEBEAMRN=vtebeamrn, $
;                                                 VOACORERN=voacorern,VOAHALORN=voahalorn,VOABEAMRN=voabeamrn, $
;                                                 VOECORERN=voecorern,VOEHALORN=voehalorn,VOEBEAMRN=voebeamrn, $
;                                                 EXPCORERN=expcorern,EXPHALORN=exphalorn,EXPBEAMRN=expbeamrn, $
;                                                 ES2CORERN=es2corern,ES2HALORN=es2halorn,ES2BEAMRN=es2beamrn, $
;                                                 CFACT=cfact,HFACT=hfact,BFACT=bfact,                         $
;                                                 FTOL=ftol,GTOL=gtol,XTOL=xtol,                               $
;                                                 PARINFO=def_pinf,HARINFO=def_hinf,BARINFO=def_binf,          $
;                                                 FUNC_C=func_c,FUNC_H=func_h,FUNC_B=func_b,                   $
;                                                 CORE_LABS=core_labs,HALO_LABS=halo_labs,BEAM_LABS=beam_labs, $
;                                                 XYLAB_PRE=xylabpre                                           )
;               ;;  Check output
;               HELP,cfact,hfact,bfact,ftol,gtol,xtol,func_c,func_h,func_b
;               CFACT           DOUBLE    = Array[6]
;               HFACT           DOUBLE    = Array[6]
;               BFACT           DOUBLE    = Array[6]
;               FTOL            DOUBLE    =    1.0000000e-14
;               GTOL            DOUBLE    =    1.0000000e-14
;               XTOL            DOUBLE    =    1.0000000e-12
;               FUNC_C          STRING    = 'model_ss_fit'
;               FUNC_H          STRING    = 'model_kk_fit'
;               FUNC_B          STRING    = 'model_kk_fit'
;
;               HELP,def_pinf,def_hinf,def_binf
;               DEF_PINF        STRUCT    = -> <Anonymous> Array[6]
;               DEF_HINF        STRUCT    = -> <Anonymous> Array[6]
;               DEF_BINF        STRUCT    = -> <Anonymous> Array[6]
;
;               HELP,def_pinf[0],/STRUCT
;               ** Structure <1a11538>, 10 tags, length=88, data length=71, refs=6:
;                  VALUE           DOUBLE           1.0000000
;                  FIXED           BYTE         0
;                  LIMITED         BYTE      Array[2]
;                  LIMITS          DOUBLE    Array[2]
;                  TIED            STRING    ''
;                  MPSIDE          INT              0
;                  RELSTEP         DOUBLE         0.020000000
;                  MPDERIV_DEBUG   INT              0
;                  MPDERIV_RELTOL  DOUBLE          0.10000000
;                  MPDERIV_ABSTOL  DOUBLE       0.00010000000
;
;               PRINT,';;  ',cfact                 & $
;               PRINT,';;  ',cparm                 & $
;               PRINT,';;  ',def_pinf[*].VALUE[0]  & $
;               PRINT,';;  ',def_pinf[*].LIMITS[0] & $
;               PRINT,';;  ',def_pinf[*].LIMITS[1]
;               ;;         5.0000000       1800.0000       2000.0000       10.000000       10.000000       1.0000000
;               ;;         1.0000000       1.0000000       1.0000000       1.0000000       1.0000000       3.0000000
;               ;;         1.0000000       1.0000000       1.0000000       1.0000000       1.0000000       3.0000000
;               ;;        0.40000000      0.83333333      0.75000000      -100.00000      -100.00000       2.0000000
;               ;;         1.6000000       8.3333333       7.5000000       100.00000       100.00000       10.000000
;
;               PRINT,';;  ',hfact                 & $
;               PRINT,';;  ',hparm                 & $
;               PRINT,';;  ',def_hinf[*].VALUE[0]  & $
;               PRINT,';;  ',def_hinf[*].LIMITS[0] & $
;               PRINT,';;  ',def_hinf[*].LIMITS[1]
;               ;;        0.50000000       4500.0000       5000.0000       1000.0000       10000.000       1.0000000
;               ;;         1.0000000       1.0000000       1.0000000       1.0000000       0.0000000       3.0000000
;               ;;         1.0000000       1.0000000       1.0000000       1.0000000       0.0000000       3.0000000
;               ;;       0.020000000      0.55555556      0.50000000       0.0000000      -1.0000000       2.0000000
;               ;;         2.0000000       3.3333333       3.0000000       10.000000       1.0000000       20.000000
;
;               PRINT,';;  ',bfact                 & $
;               PRINT,';;  ',bparm                 & $
;               PRINT,';;  ',def_binf[*].VALUE[0]  & $
;               PRINT,';;  ',def_binf[*].LIMITS[0] & $
;               PRINT,';;  ',def_binf[*].LIMITS[1]
;               ;;        0.10000000       4000.0000       4500.0000       3000.0000       10000.000       1.0000000
;               ;;         1.0000000       1.0000000       1.0000000       1.0000000       0.0000000       4.0000000
;               ;;         1.0000000       1.0000000       1.0000000       1.0000000       0.0000000       4.0000000
;               ;;       0.010000000      0.62500000      0.55555556      0.83333333      -1.0000000       2.0000000
;               ;;         10.000000       3.7500000       3.3333333       3.3333333       1.0000000       20.000000
;
;  KEYWORDS:    
;               ****************
;               ***  INPUTS  ***
;               ****************
;               CFUNC      :  Scalar [string] used to determine which model function to
;                               use for the core VDF
;                                 'MM'  :  bi-Maxwellian VDF
;                                 'KK'  :  bi-kappa VDF
;                                 'SS'  :  bi-self-similar VDF
;                                 'AS'  :  asymmetric bi-self-similar VDF
;                               [Default = 'MM']
;               HFUNC      :  Scalar [string] used to determine which model function to
;                               use for the halo VDF
;                                 'MM'  :  bi-Maxwellian VDF
;                                 'KK'  :  bi-kappa VDF
;                                 'SS'  :  bi-self-similar VDF
;                                 'AS'  :  asymmetric bi-self-similar VDF
;                               [Default = 'KK']
;               BFUNC      :  Scalar [string] used to determine which model function to
;                               use for the beam/strahl part of VDF
;                                 'MM'  :  bi-Maxwellian VDF
;                                 'KK'  :  bi-kappa VDF
;                                 'SS'  :  bi-self-similar VDF
;                                 'AS'  :  asymmetric bi-self-similar VDF
;                               [Default = 'KK']
;               CPARM       :  [6]-Element [numeric] array where each element is defined
;                                by the following quantities:
;                                PARAM[0]  = Core Number Density [cm^(-3)]
;                                PARAM[1]  = Core Parallel Thermal Speed [km/s]
;                                PARAM[2]  = Core Perpendicular Thermal Speed [km/s]
;                                PARAM[3]  = Core Parallel Drift Speed [km/s]
;                                PARAM[4]  = Core Perpendicular Drift Speed [km/s]
;                                PARAM[5]  = Core kappa, self-similar exponent, or not used
;                                [Default = See code for default values]
;               HPARM       :  [6]-Element [numeric] array where each element is defined
;                                by the following quantities:
;                                PARAM[6]  = Halo Number Density [cm^(-3)]
;                                PARAM[7]  = Halo Parallel Thermal Speed [km/s]
;                                PARAM[8]  = Halo Perpendicular Thermal Speed [km/s]
;                                PARAM[9]  = Halo Parallel Drift Speed [km/s]
;                                PARAM[10] = Halo Perpendicular Drift Speed [km/s]
;                                PARAM[11] = Halo kappa, self-similar exponent, or not used
;                                [Default = See code for default values]
;               BPARM       :  [6]-Element [numeric] array where each element is defined
;                                by the following quantities:
;                                BPARM[0]  = Beam Number Density [cm^(-3)]
;                                BPARM[1]  = Beam Parallel Thermal Speed [km/s]
;                                BPARM[2]  = Beam Perpendicular Thermal Speed [km/s]
;                                BPARM[3]  = Beam Parallel Drift Speed [km/s]
;                                BPARM[4]  = Beam Perpendicular Drift Speed [km/s]
;                                BPARM[5]  = Beam kappa, self-similar exponent, or not used
;                                [Default = starts with similar values as halo]
;               ELECTRONS  :  If set, routine uses parameters appropriate for non-
;                               relativistic electron velocity distributions
;                               [Default = TRUE]
;               IONS       :  If set, routine uses parameters appropriate for non-
;                               relativistic proton velocity distributions
;                               [Default = FALSE]
;               FIXED_C    :  [6]-Element array containing ones for each element of
;                               COREP the user does NOT wish to vary (i.e., if FIXED_C[0]
;                               is = 1, then COREP[0] will not change when calling
;                               MPFITFUN.PRO).
;                               [Default  :  All elements = 0]
;               FIXED_H    :  [6]-Element array containing ones for each element of
;                               HALOP the user does NOT wish to vary (i.e., if FIXED_H[2]
;                               is = 1, then HALOP[2] will not change when calling
;                               MPFITFUN.PRO).
;                               [Default  :  All elements = 0]
;               FIXED_B    :  [6]-Element array containing ones for each element of
;                               BEAMP the user does NOT wish to vary (i.e., if FIXED_B[3]
;                               is = 1, then BEAMP[3] will not change when calling
;                               MPFITFUN.PRO).
;                               [Default  :  All elements = 0]
;               NCORE_RAN  :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the core number density or PARAM[0].
;                               Note, if this keyword is set, it is equivalent to telling
;                               the routine that N_core should be limited by these
;                               bounds.  Setting this keyword will define:
;                                 PARINFO[0].LIMITED[*] = BYTE(NCORE_RAN[0:1])
;                                 PARINFO[0].LIMITS[*]  = NCORE_RAN[2:3]
;               NHALO_RAN  :  Same as NCORE_RAN but for HARAM[0] and HARINFO[0].
;               NBEAM_RAN  :  Same as NCORE_RAN but for BPARM[0] and BARINFO[0].
;               VTACORERN  :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the core parallel thermal speed or
;                               PARAM[1].  Note, if this keyword is set, it is
;                               equivalent to telling the routine that V_Tcpara should be
;                               limited by these bounds.  Setting this keyword will
;                               define:
;                                 PARINFO[1].LIMITED[*] = BYTE(VTACORERN[0:1])
;                                 PARINFO[1].LIMITS[*]  = VTACORERN[2:3]
;               VTAHALORN  :  Same as VTACORERN but for PARAM[7] and PARINFO[7].
;               VTABEAMRN  :  Same as VTACORERN but for BPARM[1] and BARINFO[1].
;               VTECORERN  :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the core perpendicular thermal speed
;                               or PARAM[2].  Note, if this keyword is set, it is
;                               equivalent to telling the routine that V_Tcperp should be
;                               limited by these bounds.  Setting this keyword will
;                               define:
;                                 PARINFO[2].LIMITED[*] = BYTE(VTECORERN[0:1])
;                                 PARINFO[2].LIMITS[*]  = VTECORERN[2:3]
;               VTEHALORN  :  Same as VTECORERN but for PARAM[8] and PARINFO[8].
;               VTEBEAMRN  :  Same as VTECORERN but for BPARM[2] and BARINFO[2].
;               VOACORERN  :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the core parallel drift speed or
;                               PARAM[3].  Note, if this keyword is set, it is
;                               equivalent to telling the routine that V_ocpara should be
;                               limited by these bounds.  Setting this keyword will
;                               define:
;                                 PARINFO[3].LIMITED[*] = BYTE(VOACORERN[0:1])
;                                 PARINFO[3].LIMITS[*]  = VOACORERN[2:3]
;               VOAHALORN  :  Same as VOACORERN but for HPARM[3] and HARINFO[3].
;               VOABEAMRN  :  Same as VOACORERN but for BPARM[3] and BARINFO[3].
;               VOECORERN  :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the core perpendicular drift speed
;                               or PARAM[4].  Note, if this keyword is set, it is
;                               equivalent to telling the routine that V_ocperp should be
;                               limited by these bounds.  Setting this keyword will
;                               define:
;                                 PARINFO[4].LIMITED[*] = BYTE(VOECORERN[0:1])
;                                 PARINFO[4].LIMITS[*]  = VOECORERN[2:3]
;               VOEHALORN  :  Same as VOECORERN but for HPARM[4] and HARINFO[4].
;               VOEBEAMRN  :  Same as VOECORERN but for BPARM[4] and BARINFO[4].
;               EXPCORERN  :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the exponent parameter or PARAM[5].
;                               Note, if this keyword is set, it is equivalent to
;                               telling the routine that V_ocperp should be limited by
;                               these bounds.  Setting this keyword will define:
;                                 PARINFO[5].LIMITED[*] = BYTE(EXPCORERN[0:1])
;                                 PARINFO[5].LIMITS[*]  = EXPCORERN[2:3]
;               EXPHALORN  :  Same as EXPCORERN but for halo
;               EXPBEAMRN  :  Same as EXPCORERN but for beam
;               ES2CORERN  :  Same as EXPCORERN but only used when CFUNC = 'AS', which
;                               results in that VDF component no longer using a
;                               perpendicular drift velocity but replacing it with
;                               EXPCORERN.  Setting this keyword will define:
;                                 PARINFO[4].LIMITED[*] = BYTE(EXPCORERN[0:1])
;                                 PARINFO[4].LIMITS[*]  = EXPCORERN[2:3]
;                                 PARINFO[5].LIMITED[*] = BYTE(ES2CORERN[0:1])
;                                 PARINFO[5].LIMITS[*]  = ES2CORERN[2:3]
;               ES2HALORN  :  Same as ES2CORERN but for halo when HFUNC = 'AS'
;               ES2BEAMRN  :  Same as ES2CORERN but for beam when BFUNC = 'AS'
;               FTOL       :  Scalar [double] definining the maximum values in both
;                               the actual and predicted relative reductions in the sum
;                               squares are at most FTOL at termination.  Therefore, FTOL
;                               measures the relative error desired in the sum of
;                               squares.
;                               [Default  :  1d-14 ]
;               GTOL       :  Scalar [double] definining the value of the absolute cosine
;                               of the angle between fvec and any column of the jacobian
;                               allowed before terminating the fit calculation.
;                               Therefore, GTOL measures the orthogonality desired
;                               between the function vector and the columns of the
;                               jacobian.
;                               [Default  :  1d-14 ]
;               XTOL       :  Scalar [double] definining the maximum relative error
;                               between two consecutive iterates to allow before
;                               terminating the fit calculation.  Thus, XTOL measures
;                               the relative error desired in the approximate solution.
;                               [Default  :  1d-12 ]
;               ****************
;               ***  OUTPUT  ***
;               ****************
;               ELECTRONS  :  Scalar [boolean] defining whether the default parameters
;                               assume electron (TRUE) or ions (FALSE)
;                               [Default = TRUE]
;               IONS       :  Scalar [boolean] defining whether the default parameters
;                               assume electron (FALSE) or ions (TRUE)
;                               [Default = FALSE]
;               CFUNC      :  Scalar [string] limited to one of the proper model functions
;                               to use for the core VDF (see allowed values above)
;               HFUNC      :  Scalar [string] limited to one of the proper model functions
;                               to use for the halo VDF (see allowed values above)
;               BFUNC      :  Scalar [string] limited to one of the proper model functions
;                               to use for the beam/strahl VDF (see allowed values above)
;               CPARM      :  [6]-Element [numeric] array of initial guess fit values for
;                               the core component, which will be normalized by the
;                               values in CFACT on return
;               HPARM      :  [6]-Element [numeric] array of initial guess fit values for
;                               the halo component, which will be normalized by the
;                               values in HFACT on return
;               BPARM      :  [6]-Element [numeric] array of initial guess fit values for
;                               the beam component, which will be normalized by the
;                               values in BFACT on return
;               CFACT      :  [6]-Element [numeric] array of multiplicative factors to
;                               use to ensure that the core fit parameters are near unity
;                               when called by MPFIT software
;               HFACT      :  [6]-Element [numeric] array of multiplicative factors to
;                               use to ensure that the halo fit parameters are near unity
;                               when called by MPFIT software
;               BFACT      :  [6]-Element [numeric] array of multiplicative factors to
;                               use to ensure that the beam fit parameters are near unity
;                               when called by MPFIT software
;               FTOL       :  Set to a named variable to return the maximum values in both
;                               the actual and predicted relative reductions in the sum
;                               squares
;               GTOL       :  Set to a named variable to return the value of the
;                               absolute cosine  of the angle between fvec and any
;                               column of the jacobian allowed
;               XTOL       :  Set to a named variable to return the maximum relative
;                               error between two consecutive iterates to allow
;               PARINFO    :  Set to a named variable to return the default core parameter
;                               structure to be passed to MPFIT.PRO.  The output will
;                               be a [6]-element array [structure] where the i-th
;                               element contains the following tags and definitions
;                               (Note values in LIMITS and VALUE tags will be normalized
;                                to the values in CFACT)
;                               VALUE    =  Scalar [float/double] value defined by
;                                             PARAM[i].  The user need not set this value.
;                                             [Default = PARAM[i] ]
;                               FIXED    =  Scalar [boolean] value defining whether to
;                                             allow MPFIT.PRO to vary PARAM[i] or not
;                                             TRUE   :  parameter constrained
;                                                       (i.e., no variation allowed)
;                                             FALSE  :  parameter unconstrained
;                               LIMITED  =  [2]-Element [boolean] array defining if the
;                                             lower/upper bounds defined by LIMITS
;                                             are imposed(TRUE) otherwise it has no effect
;                                             [Default = FALSE]
;                               LIMITS   =  [2]-Element [float/double] array defining the
;                                             [lower,upper] bounds on PARAM[i].  Both
;                                             LIMITED and LIMITS must be given together.
;                                             [Default = [0.,0.] ]
;                               TIED     =  Scalar [string] that mathematically defines
;                                             how PARAM[i] is forcibly constrained.  For
;                                             instance, assume that PARAM[0] is always
;                                             equal to 2 Pi times PARAM[1], then one would
;                                             define the following:
;                                               PARINFO[0].TIED = '2 * !DPI * P[1]'
;                                             [Default = '']
;                               MPSIDE   =  Scalar value with the following
;                                             consequences:
;                                              0 : 1-sided deriv. computed automatically
;                                              1 : 1-sided deriv. (f(x+h) - f(x)  )/h
;                                             -1 : 1-sided deriv. (f(x)   - f(x-h))/h
;                                              2 : 2-sided deriv. (f(x+h) - f(x-h))/(2*h)
;                                              3 : explicit deriv. used for this parameter
;                                             See MPFIT.PRO and MPFITFUN.PRO for more...
;                                             [Default = 3]
;               HARINFO    :  Set to a named variable to return the default parameter
;                               structure to be passed to MPFIT.PRO for the halo.  The
;                               output will be a [6]-element array [structure] with the
;                               same format as PARINFO.
;               BARINFO    :  Set to a named variable to return the default parameter
;                               structure to be passed to MPFIT.PRO for the beam.  The
;                               output will be a [6]-element array [structure] with the
;                               same format as PARINFO.
;               FUNC_C     :  Set to a named variable to return the default model
;                               function name to use for the core VDF
;                                 'MM'  -->  'model_mm_fit'
;                                 'KK'  -->  'model_kk_fit'
;                                 'SS'  -->  'model_ss_fit'
;                                 'AS'  -->  'model_as_fit'
;               FUNC_H     :  Set to a named variable to return the default model
;                               function name to use for the halo VDF
;                                 'MM'  -->  'model_mm_fit'
;                                 'KK'  -->  'model_kk_fit'
;                                 'SS'  -->  'model_ss_fit'
;                                 'AS'  -->  'model_as_fit'
;               FUNC_B     :  Set to a named variable to return the default model
;                               function name to use for the beam/strahl VDF
;                                 'MM'  -->  'model_mm_fit'
;                                 'KK'  -->  'model_kk_fit'
;                                 'SS'  -->  'model_ss_fit'
;                                 'AS'  -->  'model_as_fit'
;               CORE_LABS  :  Set to a named variable to return the default labels for
;                               the core fits outputs and plot legends
;               HALO_LABS  :  Set to a named variable to return the default labels for
;                               the halo fits outputs and plot legends
;               BEAM_LABS  :  Set to a named variable to return the default labels for
;                               the beam/strahl fits outputs and plot legends
;               XYLAB_PRE  :  Set to a named variable to return the default label
;                               prefixes for XYOUTS output
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  VDF = velocity distribution function
;               2)  Routine will not force or check if combination of CFUNC and HFUNC
;                     is an allowed pair, that is done elsewhere
;               3)  There is an odd issue that occurs in some cases when MPSIDE=3 for
;                     all parameters except the densities and exponents.  The Jacobian
;                     fails to converge and the MPFIT routines return a status of -16.
;                     To mitigate this issue, we force MPSIDE=0 as a default instead of
;                     MPSIDE=3.
;               4)  If any of the function keywords are set to [C,H,B]FUNC = 'AS', then
;                     that VDF component will have input parameters as follows:
;                       PARAM[0]  = [C,H,B] Number Density [cm^(-3)]
;                       PARAM[1]  = [C,H,B] Parallel Temperature [eV]
;                       PARAM[2]  = [C,H,B] Perpendicular Temperature [eV]
;                       PARAM[3]  = [C,H,B] Parallel Drift Speed [km/s]
;                       PARAM[4]  = [C,H,B] Parallel self-similar exponent
;                       PARAM[5]  = [C,H,B] Perpendicular self-similar exponent
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: log10_get_defaults_4_parinfo_struc4mpfit_4_vdfs.pro  and
;                 get_defaults_4_parinfo_struc4mpfit_4_vdfs.pro    BY: Lynn B. Wilson III
;   CREATED:  09/17/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/17/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION setup_def_4_parinfo_struc4mpfit_4_vdfs,CFUNC=cfunc,HFUNC=hfunc,BFUNC=bfunc,           $
                                  CPARM=cparm,HPARM=hparm,BPARM=bparm,                         $
                                  ELECTRONS=electrons,IONS=ions,                               $
                                  FIXED_C=fixed_c,FIXED_H=fixed_h,FIXED_B=fixed_b,             $
                                  NCORE_RAN=ncore_ran,NHALO_RAN=nhalo_ran,NBEAM_RAN=nbeam_ran, $
                                  VTACORERN=vtacorern,VTAHALORN=vtahalorn,VTABEAMRN=vtabeamrn, $
                                  VTECORERN=vtecorern,VTEHALORN=vtehalorn,VTEBEAMRN=vtebeamrn, $
                                  VOACORERN=voacorern,VOAHALORN=voahalorn,VOABEAMRN=voabeamrn, $
                                  VOECORERN=voecorern,VOEHALORN=voehalorn,VOEBEAMRN=voebeamrn, $
                                  EXPCORERN=expcorern,EXPHALORN=exphalorn,EXPBEAMRN=expbeamrn, $
                                  ES2CORERN=es2corern,ES2HALORN=es2halorn,ES2BEAMRN=es2beamrn, $
                                  CFACT=cfact,HFACT=hfact,BFACT=bfact,                         $
                                  FTOL=ftol,GTOL=gtol,XTOL=xtol,                               $
                                  DEF_OFFST=def_offst,PARINFO=def_pinf,HARINFO=def_hinf,       $
                                  BARINFO=def_binf,FUNC_C=func_c,FUNC_H=func_h,FUNC_B=func_b,  $
                                  CORE_LABS=core_labs,HALO_LABS=halo_labs,BEAM_LABS=beam_labs, $
                                  XYLAB_PRE=xylabpre

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f                       = !VALUES.F_NAN
d                       = !VALUES.D_NAN
relstep                 = 2d-2                                ;;  Relative/Fractional step for numerical derivatives
dumbd2                  = REPLICATE(d,2)
def_fact                = REPLICATE(1d0,6)                    ;;  Default factors for each parameter set
;;----------------------------------------------------------------------------------------
;;  Define fundamental, electromagnetic, and atomic constants
;;----------------------------------------------------------------------------------------
@load_constants_fund_em_atomic_c2014_batch.pro
;;  Conversion factors
;;    Energy and Temperature
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> eV2K*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> K2eV*Temp{K} = energy{eV}]
;;    Temperature --> Thermal Speed:  Converts square root of temperature [eV] into thermal speed [km/s]
vtefac         = SQRT(2d0*eV2J[0]/me[0])*1d-3
vtpfac         = SQRT(2d0*eV2J[0]/mp[0])*1d-3
;;    Thermal Speed --> Temperature:  Converts thermal speed [km/s] squared to temperature [eV]
vte2te         = 1d0/vtefac[0]^2d0
vtp2tp         = 1d0/vtpfac[0]^2d0
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
;;  Default output strings when printing fit results
pre_pre_str             = ';;  '
e_p_lab_str             = ['e','p']
chb_lab_str             = ['c','h','b']
c___lab_str             = [REPLICATE(chb_lab_str[0],5L),'']
h___lab_str             = [REPLICATE(chb_lab_str[1],5L),'']
b___lab_str             = [REPLICATE(chb_lab_str[2],5L),'']
fac_lab_st0             = ['par','per']
fac_lab_str             = ['',fac_lab_st0,fac_lab_st0,'']
pre_lab_str             = ['N_o','V_T','V_T','V_o','V_o','']
suf_lab_str             = [['     ','  ','  ','  ','  ']+'=  ','']
exp_lab_str             = ['MM exp','kappa','SS exp','AS exp_'+fac_lab_st0]
;;-------------------------------------------------------
;;  Define default labels
;;-------------------------------------------------------
;;  bi-Maxwellian core labels
core_bm_lab             = pre_pre_str[0]+pre_lab_str+c___lab_str+fac_lab_str+suf_lab_str
core_bm_lab[5]          = core_bm_lab[5]+exp_lab_str[0]+chb_lab_str[0]+'   =  '
;;  bi-kappa core labels
core_kk_lab             = pre_pre_str[0]+pre_lab_str+c___lab_str+fac_lab_str+suf_lab_str
core_kk_lab[5]          = core_kk_lab[5]+exp_lab_str[1]+chb_lab_str[0]+'   =  '
;;  bi-self-similar core labels
core_ss_lab             = pre_pre_str[0]+pre_lab_str+c___lab_str+fac_lab_str+suf_lab_str
core_ss_lab[5]          = core_ss_lab[5]+exp_lab_str[2]+chb_lab_str[0]+'  =  '
;;  asymmetric bi-self-similar core labels
core_as_lab             = pre_pre_str[0]+pre_lab_str+c___lab_str+fac_lab_str+suf_lab_str
core_as_lab[4]          = pre_pre_str[0]+exp_lab_str[3]+chb_lab_str[0]+'  =  '
core_as_lab[5]          = core_as_lab[5]+exp_lab_str[4]+chb_lab_str[0]+'  =  '
;;  bi-Maxwellian halo labels
halo_bm_lab             = pre_pre_str[0]+pre_lab_str+h___lab_str+fac_lab_str+suf_lab_str
halo_bm_lab[5]          = halo_bm_lab[5]+exp_lab_str[0]+chb_lab_str[1]+'   =  '
;;  bi-kappa halo labels
halo_kk_lab             = pre_pre_str[0]+pre_lab_str+h___lab_str+fac_lab_str+suf_lab_str
halo_kk_lab[5]          = halo_kk_lab[5]+exp_lab_str[1]+chb_lab_str[1]+'   =  '
;;  bi-self-similar halo labels
halo_ss_lab             = pre_pre_str[0]+pre_lab_str+h___lab_str+fac_lab_str+suf_lab_str
halo_ss_lab[5]          = halo_ss_lab[5]+exp_lab_str[2]+chb_lab_str[1]+'  =  '
;;  asymmetric bi-self-similar halo labels
halo_as_lab             = pre_pre_str[0]+pre_lab_str+h___lab_str+fac_lab_str+suf_lab_str
halo_as_lab[4]          = pre_pre_str[0]+exp_lab_str[3]+chb_lab_str[1]+'  =  '
halo_as_lab[5]          = halo_as_lab[5]+exp_lab_str[4]+chb_lab_str[1]+'  =  '
;;  bi-Maxwellian beam labels
beam_bm_lab             = pre_pre_str[0]+pre_lab_str+b___lab_str+fac_lab_str+suf_lab_str
beam_bm_lab[5]          = beam_bm_lab[5]+exp_lab_str[0]+chb_lab_str[2]+'   =  '
;;  bi-kappa beam labels
beam_kk_lab             = pre_pre_str[0]+pre_lab_str+b___lab_str+fac_lab_str+suf_lab_str
beam_kk_lab[5]          = beam_kk_lab[5]+exp_lab_str[1]+chb_lab_str[2]+'   =  '
;;  bi-self-similar beam labels
beam_ss_lab             = pre_pre_str[0]+pre_lab_str+b___lab_str+fac_lab_str+suf_lab_str
beam_ss_lab[5]          = beam_ss_lab[5]+exp_lab_str[2]+chb_lab_str[2]+'  =  '
;;  asymmetric bi-self-similar beam labels
beam_as_lab             = pre_pre_str[0]+pre_lab_str+b___lab_str+fac_lab_str+suf_lab_str
beam_as_lab[4]          = pre_pre_str[0]+exp_lab_str[3]+chb_lab_str[2]+'  =  '
beam_as_lab[5]          = beam_as_lab[5]+exp_lab_str[4]+chb_lab_str[2]+'  =  '
;;-------------------------------------------------------
;;  Default fit parameter estimates
;;-------------------------------------------------------
def_vth_emks            = [19d2,50d2,45d2]                    ;;  Default electron thermal speeds [km/s]
def__T__emks            = [11d0,70d0,70d0]                    ;;  Default electron temperatures [eV]
def_v_o_emks            = [ 1d2, 1d3, 1d3]                    ;;  Default electron drift speeds [km/s]
def_vth_imks            = [20d0,50d0,50d0]                    ;;  Default proton thermal speeds [km/s]
def__T__imks            = [ 2d0,13d0,13d0]                    ;;  Default proton temperatures [eV]
def_v_o_imks            = [ 3d2, 5d2, 5d2]                    ;;  Default proton drift speeds [km/s]
def_ei_offst            = [1d18,1d10]                         ;;  Default offset to force data to be ≥ 1.0
def_ks                  = [3d0,4d0]                           ;;  Default kappa and self-similar exponent values
def_n_ch                = [5d0,3d-1]                          ;;  Default core/halo number densities [cm^(-3)]
;;-------------------------------------------------------
;;  Default fit parameter limits/ranges
;;-------------------------------------------------------
;;  Default limits/ranges:  Electrons
def_n_ec_lim            = [5d-2,2d2]      ;;  0.05 ≤ n_ec ≤ 200 cm^(-3)
def_n_eh_lim            = [1d-3,2d1]      ;;  0.001 ≤ n_eh ≤ 20 cm^(-3)
def_n_eb_lim            = [1d-4,1d1]      ;;  0.0001 ≤ n_eh ≤ 10 cm^(-3)
def_vtec_lim            = [5d0,15d3]      ;;  5 km/s ≤ V_Tecj ≤ 15000 km/s
def_vteh_lim            = [5d0,2d4]       ;;  5 km/s ≤ V_Tehj ≤ 20000 km/s
def__Tec_lim            = [1d-4,3d2]      ;;  0.0001 eV ≤ T_ecj ≤ 300 eV
def__Teh_lim            = [1d-4,12d2]     ;;  0.0001 eV ≤ T_ehj ≤ 1200 eV
def_voec_lim            = [-1d0,1d0]*1d3  ;;   -1000 km/s ≤ V_oecj ≤  +1000 km/s
def_voeh_lim            = [-1d0,1d0]*1d4  ;;  -10000 km/s ≤ V_oecj ≤ +10000 km/s
;;  Default limits/ranges:  Protons
def_n_ic_lim            = [5d-2,2d2]      ;;  0.05 ≤ n_ic ≤ 200 cm^(-3)
def_n_ih_lim            = [1d-3,2d1]      ;;  0.001 ≤ n_ih ≤ 20 cm^(-3)
def_n_ib_lim            = [1d-4,2d1]      ;;  0.0001 ≤ n_ih ≤ 20 cm^(-3)
def_vtic_lim            = [1d0,15d2]      ;;  1 km/s ≤ V_Tpcj ≤ 1500 km/s
def_vtih_lim            = [1d0,2d3]       ;;  1 km/s ≤ V_Tphj ≤ 2000 km/s
def__Tic_lim            = [5d-3,52d2]     ;;  0.005 eV ≤ T_icj ≤ 5200 eV
def__Tih_lim            = [5d-3,20d3]     ;;  0.005 eV ≤ T_ihj ≤ 20000 eV
def_voic_lim            = [-1d0,1d0]*2d3  ;;   -2000 km/s ≤ V_opcj ≤  +2000 km/s
def_voih_lim            = [-1d0,1d0]*25d2 ;;   -2500 km/s ≤ V_opcj ≤  +2500 km/s
;;  Default limits/ranges:  kappa and self-similar exponent values
def_kapp_lim            = [3d0/2d0,10d1]  ;;  3/2 ≤ kappa ≤ 100
def_ssex_lim            = [2d0,1d1]       ;;  self-similar exponent:  2 ≤ p ≤ 10
;;-------------------------------------------------------
;;  Default fit parameter arrays
;;-------------------------------------------------------
;;  Electrons
def_bimax_ec            = [def_n_ch[0],def_vth_emks[0],def_vth_emks[0],def_v_o_emks[0],1d1,2d0]              ;;  Default bi-Maxwellian core electrons
def_bikap_ec            = [def_n_ch[0],def_vth_emks[1],def_vth_emks[1],def_v_o_emks[1],1d1,def_ks[0]]        ;;  Default bi-kappa " "
def_bi_ss_ec            = [def_n_ch[0],def_vth_emks[2],def_vth_emks[2],def_v_o_emks[2],1d1,def_ks[1]]        ;;  Default bi-self-similar " "
def_bi_as_ec            = [def_n_ch[0],def_vth_emks[2],def_vth_emks[2],def_v_o_emks[2],def_ks[1],def_ks[0]]  ;;  Default asymmetric bi-self-similar " "
def_bimax_eh            = [def_n_ch[1],def_vth_emks[0],def_vth_emks[0],def_v_o_emks[0],0d0,2d0]              ;;  Default bi-Maxwellian halo electrons
def_bikap_eh            = [def_n_ch[1],def_vth_emks[1],def_vth_emks[1],def_v_o_emks[1],0d0,def_ks[0]]        ;;  Default bi-kappa " "
def_bi_ss_eh            = [def_n_ch[1],def_vth_emks[2],def_vth_emks[2],def_v_o_emks[2],0d0,def_ks[1]]        ;;  Default bi-self-similar " "
def_bi_as_eh            = [def_n_ch[1],def_vth_emks[2],def_vth_emks[2],def_v_o_emks[2],def_ks[0],def_ks[1]]  ;;  Default asymmetric bi-self-similar " "
;;  Protons
def_bimax_ic            = [def_n_ch[0],def_vth_imks[0],def_vth_imks[0],def_v_o_imks[0],1d0,2d0]              ;;  Default bi-Maxwellian core protons
def_bikap_ic            = [def_n_ch[0],def_vth_imks[1],def_vth_imks[1],def_v_o_imks[1],1d0,def_ks[0]]        ;;  Default bi-kappa " "
def_bi_ss_ic            = [def_n_ch[0],def_vth_imks[2],def_vth_imks[2],def_v_o_imks[2],1d0,def_ks[1]]        ;;  Default bi-self-similar " "
def_bi_as_ic            = [def_n_ch[0],def_vth_imks[2],def_vth_imks[2],def_v_o_imks[2],def_ks[1],def_ks[0]]  ;;  Default asymmetric bi-self-similar " "
def_bimax_ih            = [def_n_ch[1],def_vth_imks[0],def_vth_imks[0],def_v_o_imks[0],0d0,2d0]              ;;  Default bi-Maxwellian core protons
def_bikap_ih            = [def_n_ch[1],def_vth_imks[1],def_vth_imks[1],def_v_o_imks[1],0d0,def_ks[0]]        ;;  Default bi-kappa " "
def_bi_ss_ih            = [def_n_ch[1],def_vth_imks[2],def_vth_imks[2],def_v_o_imks[2],0d0,def_ks[1]]        ;;  Default bi-self-similar " "
def_bi_as_ih            = [def_n_ch[1],def_vth_imks[2],def_vth_imks[2],def_v_o_imks[2],def_ks[0],def_ks[1]]  ;;  Default asymmetric bi-self-similar " "
;;  Define default parameter array
;;    [ns,Vts_para,Vts_perp,Vos_para,Vos_perp,Exp_s]
def_param               = def_bimax_ec
def_haram               = def_bikap_eh
def_baram               = def_bikap_eh
np                      = N_ELEMENTS(def_param)
;;-------------------------------------------------------
;;  Define default PARINFO structure
;;-------------------------------------------------------
tags                    = ['VALUE','FIXED','LIMITED','LIMITS','TIED','MPSIDE','RELSTEP']
tags                    = [tags,'MPDERIV_DEBUG','MPDERIV_RELTOL','MPDERIV_ABSTOL']
def_pinfo0              = CREATE_STRUCT(tags,d,0b,[0b,0b],[0d0,0d0],'',3,relstep[0],0,1d-1,1d-4)
def_pinf                = REPLICATE(def_pinfo0[0],np)
;;  The following are necessary to avoid an oddity whereby the original MPFIT routines
;;    would return a status of -16 (i.e., something went infinite) when debugging was off
;;    but the routines run through just fine if debugging is on.  It's not entirely clear
;;    why debugging would allow the routine to work to the end.  Though it may have to
;;    do with explicit vs. numerical derivatives, where the former may have unexpected
;;    poles at relevant locations while the latter may not.  Again, I am not sure what
;;    is causing the issue.
def_pinf[*].MPSIDE[0]   = 0
def_hinf                = def_pinf
;;  Limit kappa values [default is bi-Maxwellian plus kappa]
def_hinf[5].LIMITED[*]  = 1b
def_hinf[5].LIMITS[0]   = def_kapp_lim[0]
def_hinf[5].LIMITS[1]   = def_kapp_lim[1]
def_binf                = def_hinf
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check keywords with default options
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check IONS
test           = (N_ELEMENTS(ions) GT 0) AND KEYWORD_SET(ions)
IF (test[0]) THEN ion__on = 1b ELSE ion__on = 0b
;;  Check ELECTRONS
test           = (N_ELEMENTS(electrons) GT 0) AND KEYWORD_SET(electrons)
IF (test[0]) THEN elec_on = 1b ELSE elec_on = ([0b,1b])[~ion__on[0]]
IF (elec_on[0] AND ion__on[0]) THEN ion__on[0] = 0b                    ;;  Make sure only one particle type is set
IF (elec_on[0]) THEN BEGIN
  ;;  Electrons
  spc_string   = e_p_lab_str[0]
  T2Vtfac      = vtefac[0]
  Vt2Tfac      = vte2te[0]
  ;;  Define default parameter values
  def_mod_mm_c = def_bimax_ec
  def_mod_mm_h = def_bimax_eh
  def_mod_kk_c = def_bikap_ec
  def_mod_kk_h = def_bikap_eh
  def_mod_ss_c = def_bi_ss_ec
  def_mod_ss_h = def_bi_ss_eh
  def_mod_as_c = def_bi_as_ec
  def_mod_as_h = def_bi_as_eh
  ;;  Define default limits
  def_denc_lim = def_n_ec_lim
  def_denh_lim = def_n_eh_lim
  def_denb_lim = def_n_eb_lim
  def_vthc_lim = def_vtec_lim
  def_vthh_lim = def_vteh_lim
  def_v_oc_lim = def_voec_lim
  def_v_oh_lim = def_voeh_lim
ENDIF ELSE BEGIN
  ;;  Ions
  spc_string   = e_p_lab_str[1]
  T2Vtfac      = vtpfac[0]
  Vt2Tfac      = vtp2tp[0]
  ;;  Define default parameter values
  def_mod_mm_c = def_bimax_ic
  def_mod_mm_h = def_bimax_ih
  def_mod_kk_c = def_bikap_ic
  def_mod_kk_h = def_bikap_ih
  def_mod_ss_c = def_bi_ss_ic
  def_mod_ss_h = def_bi_ss_ih
  def_mod_as_c = def_bi_as_ic
  def_mod_as_h = def_bi_as_ih
  ;;  Define default limits
  def_denc_lim = def_n_ic_lim
  def_denh_lim = def_n_ih_lim
  def_denb_lim = def_n_ib_lim
  def_vthc_lim = def_vtic_lim
  def_vthh_lim = def_vtih_lim
  def_v_oc_lim = def_voic_lim
  def_v_oh_lim = def_voih_lim
ENDELSE
;;  Check [C,H,B]FUNC
test                    = (SIZE(cfunc,/TYPE) EQ 7)
IF (test[0]) THEN cf = STRUPCASE(STRMID(cfunc[0],0,2)) ELSE cf = 'MM'
;;  Check HFUNC
test                    = (SIZE(hfunc,/TYPE) EQ 7)
IF (test[0]) THEN hf = STRUPCASE(STRMID(hfunc[0],0,2)) ELSE hf = 'KK'
;;  Check BFUNC
test                    = (SIZE(bfunc,/TYPE) EQ 7)
IF (test[0]) THEN bf = STRUPCASE(STRMID(bfunc[0],0,2)) ELSE bf = 'KK'
;;------------------------------
;;  Check [C,H,B]PARM
;;------------------------------
cparm_on                = (N_ELEMENTS(cparm) EQ 6) AND is_a_number(cparm,/NOMSSG)
hparm_on                = (N_ELEMENTS(hparm) EQ 6) AND is_a_number(hparm,/NOMSSG)
bparm_on                = (N_ELEMENTS(bparm) EQ 6) AND is_a_number(bparm,/NOMSSG)
;;  Check FIXED_[C,H,B]
test                    = (N_ELEMENTS(fixed_c) EQ 6) AND is_a_number(fixed_c,/NOMSSG)
IF (test[0]) THEN fixc = (REFORM(fixed_c) EQ 1) ELSE fixc = REPLICATE(0b,6)
test                    = (N_ELEMENTS(fixed_h) EQ 6) AND is_a_number(fixed_h,/NOMSSG)
IF (test[0]) THEN fixh = (REFORM(fixed_h) EQ 1) ELSE fixh = REPLICATE(0b,6)
fixch                   = [fixc,fixh]
test                    = (N_ELEMENTS(fixed_b) EQ 6) AND is_a_number(fixed_b,/NOMSSG)
IF (test[0]) THEN fixb = (REFORM(fixed_b) EQ 1) ELSE fixb = REPLICATE(0b,6)
;;----------------------------------------------------------------------------------------
;;  Define function-specific options/values
;;----------------------------------------------------------------------------------------
;;  CFUNC
CASE cf[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  BEGIN
    cfunc       = 'MM'
    core_labs   = core_bm_lab
    xylabpre    = ['Bi-Max.']
    def_pinf[5].VALUE = 2d0
    def_pinf[5].FIXED = 1b
    fixc[5]     = 1b
    func_c      = 'model_ss_fit'
    def_param   = def_mod_mm_c
    IF (cparm_on[0]) THEN cparm = DOUBLE(cparm) ELSE cparm = def_mod_mm_c
    cparm[5]    = 2d0
  END
  'KK'  :  BEGIN
    cfunc       = 'KK'
    core_labs   = core_kk_lab
    xylabpre    = ['Bi-kappa']
    func_c      = 'model_kk_fit'
    def_param   = def_mod_kk_c
    IF (cparm_on[0]) THEN cparm = DOUBLE(cparm) ELSE cparm = def_mod_kk_c
    def_expcran = def_kapp_lim
  END
  'SS'  :  BEGIN
    cfunc       = 'SS'
    core_labs   = core_ss_lab
    xylabpre    = ['Bi-SS']
    func_c      = 'model_ss_fit'
    def_param   = def_mod_ss_c
    IF (cparm_on[0]) THEN cparm = DOUBLE(cparm) ELSE cparm = def_mod_ss_c
    cparm[5]    = cparm[5] > 2d0
    def_expcran = def_ssex_lim
  END
  'AS'  :  BEGIN
    cfunc       = 'AS'
    core_labs   = core_as_lab
    xylabpre    = ['Bi-AS']
    func_c      = 'model_as_fit'
    def_param   = def_mod_as_c
    IF (cparm_on[0]) THEN cparm = DOUBLE(cparm) ELSE cparm = def_mod_as_c
    cparm[4]    = cparm[4] > 2d0
    cparm[5]    = cparm[5] > 2d0
    def_expcran = def_ssex_lim
    def_es2cran = def_ssex_lim
  END
  ELSE  :  BEGIN
    cfunc        = 'MM'     ;;  Default
    core_labs    = core_bm_lab
    xylabpre     = ['Bi-Max.']
    def_pinf[5].VALUE = 2d0
    def_pinf[5].FIXED = 1b
    fixc[5]      = 1b
    func_c       = 'model_ss_fit'
    def_param    = def_mod_mm_c
    IF (cparm_on[0]) THEN cparm = DOUBLE(cparm) ELSE cparm = def_mod_ss_c
    cparm[5]     = 2d0
  END
ENDCASE
;;  HFUNC
CASE hf[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  BEGIN
    hfunc       = 'MM'
    halo_labs   = halo_bm_lab
    xylabpre    = [xylabpre,'Bi-Max.']
    def_hinf[5].VALUE = 2d0
    def_hinf[5].FIXED = 1b
    fixh[5]     = 1b
    func_h      = 'model_ss_fit'
    def_haram   = def_mod_mm_c
    IF (hparm_on[0]) THEN hparm = DOUBLE(hparm) ELSE hparm = def_mod_mm_h
    hparm[5]    = 2d0
  END
  'KK'  :  BEGIN
    hfunc       = 'KK'
    halo_labs   = halo_kk_lab
    xylabpre    = [xylabpre,'Bi-kappa']
    func_h      = 'model_kk_fit'
    def_haram   = def_mod_kk_c
    IF (hparm_on[0]) THEN hparm = DOUBLE(hparm) ELSE hparm = def_mod_kk_h
    hparm[5]    = hparm[5] > (3d0/2d0 + 1d-5)
    def_exphran = def_kapp_lim
  END
  'SS'  :  BEGIN
    hfunc       = 'SS'
    halo_labs   = halo_ss_lab
    xylabpre    = [xylabpre,'Bi-SS']
    func_h      = 'model_ss_fit'
    def_haram   = def_mod_ss_c
    IF (hparm_on[0]) THEN hparm = DOUBLE(hparm) ELSE hparm = def_mod_ss_h
    hparm[5]    = hparm[5] > 2d0
    def_exphran = def_ssex_lim
  END
  'AS'  :  BEGIN
    hfunc       = 'AS'
    halo_labs   = halo_as_lab
    xylabpre    = [xylabpre,'Bi-AS']
    func_h      = 'model_as_fit'
    def_haram   = def_mod_as_c
    IF (hparm_on[0]) THEN hparm = DOUBLE(hparm) ELSE hparm = def_mod_as_h
    hparm[4]    = hparm[4] > 2d0
    hparm[5]    = hparm[5] > 2d0
    def_exphran = def_ssex_lim
    def_es2hran = def_ssex_lim
  END
  ELSE  :  BEGIN
    ;;  Default
    hfunc       = 'KK'
    halo_labs   = halo_kk_lab
    xylabpre    = [xylabpre,'Bi-kappa']
    func_h      = 'model_kk_fit'
    def_haram   = def_mod_kk_c
    IF (hparm_on[0]) THEN hparm = DOUBLE(hparm) ELSE hparm = def_mod_kk_h
    hparm[5]    = hparm[5] > (3d0/2d0 + 1d-5)
    def_exphran = def_kapp_lim
  END
ENDCASE
;;  BFUNC
CASE bf[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  BEGIN
    bfunc       = 'MM'
    beam_labs   = beam_bm_lab
    xylabpre    = [xylabpre,'Bi-Max.']
    def_binf[5].VALUE = 2d0
    def_binf[5].FIXED = 1b
    fixb[5]     = 1b
    func_b      = 'model_ss_fit'
    def_bparm   = def_mod_mm_c
    IF (bparm_on[0]) THEN bparm = DOUBLE(bparm) ELSE bparm = def_mod_mm_h
    bparm[5]    = 2d0
  END
  'KK'  :  BEGIN
    bfunc       = 'KK'
    beam_labs   = beam_kk_lab
    xylabpre    = [xylabpre,'Bi-kappa']
    func_b      = 'model_kk_fit'
    def_bparm   = def_mod_kk_c
    IF (bparm_on[0]) THEN bparm = DOUBLE(bparm) ELSE bparm = def_mod_kk_h
    bparm[5]    = bparm[5] > (3d0/2d0 + 1d-5)
    def_expbran = def_kapp_lim
  END
  'SS'  :  BEGIN
    bfunc       = 'SS'
    beam_labs   = beam_ss_lab
    xylabpre    = [xylabpre,'Bi-SS']
    func_b      = 'model_ss_fit'
    def_bparm   = def_mod_ss_c
    IF (bparm_on[0]) THEN bparm = DOUBLE(bparm) ELSE bparm = def_mod_ss_h
    bparm[5]    = bparm[5] > 2d0
    def_expbran = def_ssex_lim
  END
  'AS'  :  BEGIN
    bfunc       = 'AS'
    beam_labs   = beam_as_lab
    xylabpre    = [xylabpre,'Bi-AS']
    func_b      = 'model_as_fit'
    def_bparm   = def_mod_as_c
    IF (bparm_on[0]) THEN bparm = DOUBLE(bparm) ELSE bparm = def_mod_as_h
    bparm[4]    = bparm[4] > 2d0
    bparm[5]    = bparm[5] > 2d0
    def_expbran = def_ssex_lim
    def_es2bran = def_ssex_lim
  END
  ELSE  :  BEGIN
    ;;  Default
    bfunc       = 'KK'
    beam_labs   = beam_kk_lab
    xylabpre    = [xylabpre,'Bi-kappa']
    func_b      = 'model_kk_fit'
    def_bparm   = def_mod_kk_c
    IF (bparm_on[0]) THEN bparm = DOUBLE(bparm) ELSE bparm = def_mod_kk_h
    bparm[5]    = bparm[5] > (3d0/2d0 + 1d-5)
    def_expbran = def_kapp_lim
  END
ENDCASE
;;  Check FTOL, GTOL, and XTOL
test                    = (N_ELEMENTS(ftol) GT 0) AND is_a_number(ftol,/NOMSSG)
IF (test[0]) THEN ftol = DOUBLE(ftol[0]) ELSE ftol = 1d-14
test                    = (N_ELEMENTS(gtol) GT 0) AND is_a_number(gtol,/NOMSSG)
IF (test[0]) THEN gtol = DOUBLE(gtol[0]) ELSE gtol = 1d-14
test                    = (N_ELEMENTS(xtol) GT 0) AND is_a_number(xtol,/NOMSSG)
IF (test[0]) THEN xtol = DOUBLE(xtol[0]) ELSE xtol = 1d-12
;;----------------------------------------------------------------------------------------
;;  Check PARINFO keywords
;;----------------------------------------------------------------------------------------
;;  Check N[CORE,HALO,BEAM]_RAN
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=ncore_ran,DEF_RAN=def_denc_lim,LIMS_OUT=lims_ncore,LIMD_OUT=limd_ncore,RKEY_ON=ncore_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=nhalo_ran,DEF_RAN=def_denh_lim,LIMS_OUT=lims_nhalo,LIMD_OUT=limd_nhalo,RKEY_ON=nhalo_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=nbeam_ran,DEF_RAN=def_denb_lim,LIMS_OUT=lims_nbeam,LIMD_OUT=limd_nbeam,RKEY_ON=nbeam_on)
;;  Check VTA[CORE,HALO,BEAM]RN
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=vtacorern,DEF_RAN=def_vthc_lim,LIMS_OUT=lims_v_tca,LIMD_OUT=limd_v_tca,RKEY_ON=v_tca_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=vtahalorn,DEF_RAN=def_vthh_lim,LIMS_OUT=lims_v_tha,LIMD_OUT=limd_v_tha,RKEY_ON=v_tha_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=vtabeamrn,DEF_RAN=def_vthh_lim,LIMS_OUT=lims_v_tba,LIMD_OUT=limd_v_tba,RKEY_ON=v_tba_on)
;;  Check VTE[CORE,HALO,BEAM]RN
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=vtecorern,DEF_RAN=def_vthc_lim,LIMS_OUT=lims_v_tce,LIMD_OUT=limd_v_tce,RKEY_ON=v_tce_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=vtehalorn,DEF_RAN=def_vthh_lim,LIMS_OUT=lims_v_the,LIMD_OUT=limd_v_the,RKEY_ON=v_the_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=vtebeamrn,DEF_RAN=def_vthh_lim,LIMS_OUT=lims_v_tbe,LIMD_OUT=limd_v_tbe,RKEY_ON=v_tbe_on)
;;  Check VOA[CORE,HALO,BEAM]RN
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=voacorern,DEF_RAN=def_v_oc_lim,LIMS_OUT=lims_v_oca,LIMD_OUT=limd_v_oca,RKEY_ON=v_oca_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=voahalorn,DEF_RAN=def_v_oh_lim,LIMS_OUT=lims_v_oha,LIMD_OUT=limd_v_oha,RKEY_ON=v_oha_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=voabeamrn,DEF_RAN=def_v_oh_lim,LIMS_OUT=lims_v_oba,LIMD_OUT=limd_v_oba,RKEY_ON=v_oba_on)
;;  Check VOE[CORE,HALO,BEAM]RN
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=voecorern,DEF_RAN=def_v_oc_lim,LIMS_OUT=lims_v_oce,LIMD_OUT=limd_v_oce,RKEY_ON=v_oce_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=voehalorn,DEF_RAN=def_v_oh_lim,LIMS_OUT=lims_v_ohe,LIMD_OUT=limd_v_ohe,RKEY_ON=v_ohe_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=voebeamrn,DEF_RAN=def_v_oh_lim,LIMS_OUT=lims_v_obe,LIMD_OUT=limd_v_obe,RKEY_ON=v_obe_on)
;;  Check EXP[CORE,HALO,BEAM]RN
IF (cfunc[0] NE 'MM') THEN test = test_ranges_4_mpfitparinfostruc(RKEY_IN=expcorern,DEF_RAN=def_expcran,LIMS_OUT=lims_exp_c,LIMD_OUT=limd_exp_c,RKEY_ON=exp_c_on)
IF (hfunc[0] NE 'MM') THEN test = test_ranges_4_mpfitparinfostruc(RKEY_IN=exphalorn,DEF_RAN=def_exphran,LIMS_OUT=lims_exp_h,LIMD_OUT=limd_exp_h,RKEY_ON=exp_h_on)
IF (bfunc[0] NE 'MM') THEN test = test_ranges_4_mpfitparinfostruc(RKEY_IN=expbeamrn,DEF_RAN=def_expbran,LIMS_OUT=lims_exp_b,LIMD_OUT=limd_exp_b,RKEY_ON=exp_b_on)
;;  Check ES2[CORE,HALO,BEAM]RN
IF (cfunc[0] EQ 'AS') THEN test = test_ranges_4_mpfitparinfostruc(RKEY_IN=es2corern,DEF_RAN=def_es2cran,LIMS_OUT=lims_es2_c,LIMD_OUT=limd_es2_c,RKEY_ON=es2_c_on)
IF (hfunc[0] EQ 'AS') THEN test = test_ranges_4_mpfitparinfostruc(RKEY_IN=es2halorn,DEF_RAN=def_es2hran,LIMS_OUT=lims_es2_h,LIMD_OUT=limd_es2_h,RKEY_ON=es2_h_on)
IF (bfunc[0] EQ 'AS') THEN test = test_ranges_4_mpfitparinfostruc(RKEY_IN=es2beamrn,DEF_RAN=def_es2bran,LIMS_OUT=lims_es2_b,LIMD_OUT=limd_es2_b,RKEY_ON=es2_b_on)
;;----------------------------------------------------------------------------------------
;;  Define multiplicative factors to keep initial guesses near unity
;;    --> Keep exponent factors at unity, just alter others
;;----------------------------------------------------------------------------------------
;;  Define CFACT
cfact          = ABS(cparm)
IF (cfunc[0] EQ 'AS') THEN cfact[4:5]     = 1d0 ELSE cfact[5]       = 1d0
;;  Define HFACT
hfact          = ABS(hparm)
IF (hfunc[0] EQ 'AS') THEN hfact[4:5]     = 1d0 ELSE hfact[5]       = 1d0
;;  Define BFACT
bfact          = ABS(bparm)
IF (bfunc[0] EQ 'AS') THEN bfact[4:5]     = 1d0 ELSE bfact[5]       = 1d0
;;  Make sure no zeros remain in factors
bad            = WHERE(cfact EQ 0 OR FINITE(cfact) EQ 0,bd)
IF (bd[0] GT 0) THEN cfact[bad] = 1d0
bad            = WHERE(hfact EQ 0 OR FINITE(hfact) EQ 0,bd)
IF (bd[0] GT 0) THEN hfact[bad] = 1d0
bad            = WHERE(bfact EQ 0 OR FINITE(bfact) EQ 0,bd)
IF (bd[0] GT 0) THEN bfact[bad] = 1d0
;;----------------------------------------------------------------------------------------
;;  Impose limits on default PARINFO structures
;;----------------------------------------------------------------------------------------
;;  Impose FIXED settings for PARINFO and BARINFO
def_pinf[*].FIXED       = fixc
def_hinf[*].FIXED       = fixh
def_binf[*].FIXED       = fixb
;;  Limit number densities [cm^(-3)]
IF (ncore_on[0]) THEN def_pinf[00].LIMITED[*] = limd_ncore ELSE def_pinf[00].LIMITED[*] = 1b
IF (nhalo_on[0]) THEN def_hinf[00].LIMITED[*] = limd_nhalo ELSE def_hinf[00].LIMITED[*] = 1b
IF (nbeam_on[0]) THEN def_binf[00].LIMITED[*] = limd_nbeam ELSE def_binf[00].LIMITED[*] = 1b
IF (ncore_on[0]) THEN def_pinf[00].LIMITS[*]  = lims_ncore ELSE def_pinf[00].LIMITS[*]  = def_denc_lim
IF (nhalo_on[0]) THEN def_hinf[00].LIMITS[*]  = lims_nhalo ELSE def_hinf[00].LIMITS[*]  = def_denh_lim
IF (nbeam_on[0]) THEN def_binf[00].LIMITS[*]  = lims_nbeam ELSE def_binf[00].LIMITS[*]  = def_denb_lim
;;  Limit parallel thermal speeds [km/s]
IF (v_tca_on[0]) THEN def_pinf[01].LIMITED[*] = limd_v_tca ELSE def_pinf[01].LIMITED[*] = 1b
IF (v_tha_on[0]) THEN def_hinf[01].LIMITED[*] = limd_v_tha ELSE def_hinf[01].LIMITED[*] = 1b
IF (v_tba_on[0]) THEN def_binf[01].LIMITED[*] = limd_v_tba ELSE def_binf[01].LIMITED[*] = 1b
IF (v_tca_on[0]) THEN def_pinf[01].LIMITS[*]  = lims_v_tca ELSE def_pinf[01].LIMITS[*]  = def_vthc_lim
IF (v_tha_on[0]) THEN def_hinf[01].LIMITS[*]  = lims_v_tha ELSE def_hinf[01].LIMITS[*]  = def_vthh_lim
IF (v_tba_on[0]) THEN def_binf[01].LIMITS[*]  = lims_v_tba ELSE def_binf[01].LIMITS[*]  = def_vthh_lim
;;  Limit perpendicular thermal speeds [km/s]
IF (v_tce_on[0]) THEN def_pinf[02].LIMITED[*] = limd_v_tce ELSE def_pinf[02].LIMITED[*] = 1b
IF (v_the_on[0]) THEN def_hinf[02].LIMITED[*] = limd_v_the ELSE def_hinf[02].LIMITED[*] = 1b
IF (v_tbe_on[0]) THEN def_binf[02].LIMITED[*] = limd_v_tbe ELSE def_binf[02].LIMITED[*] = 1b
IF (v_tce_on[0]) THEN def_pinf[02].LIMITS[*]  = lims_v_tce ELSE def_pinf[02].LIMITS[*]  = def_vthc_lim
IF (v_the_on[0]) THEN def_hinf[02].LIMITS[*]  = lims_v_the ELSE def_hinf[02].LIMITS[*]  = def_vthh_lim
IF (v_tbe_on[0]) THEN def_binf[02].LIMITS[*]  = lims_v_tbe ELSE def_binf[02].LIMITS[*]  = def_vthh_lim
;;  Limit parallel drift speeds [km/s]
IF (v_oca_on[0]) THEN def_pinf[03].LIMITED[*] = limd_v_oca ELSE def_pinf[03].LIMITED[*] = 1b
IF (v_oha_on[0]) THEN def_hinf[03].LIMITED[*] = limd_v_oha ELSE def_hinf[03].LIMITED[*] = 1b
IF (v_oba_on[0]) THEN def_binf[03].LIMITED[*] = limd_v_oba ELSE def_binf[03].LIMITED[*] = 1b
IF (v_oca_on[0]) THEN def_pinf[03].LIMITS[*]  = lims_v_oca ELSE def_pinf[03].LIMITS[*]  = def_v_oc_lim
IF (v_oha_on[0]) THEN def_hinf[03].LIMITS[*]  = lims_v_oha ELSE def_hinf[03].LIMITS[*]  = def_v_oh_lim
IF (v_oba_on[0]) THEN def_binf[03].LIMITS[*]  = lims_v_oba ELSE def_binf[03].LIMITS[*]  = def_v_oh_lim
;;  Limit perpendicular drift speeds [km/s]
IF (v_oce_on[0]) THEN def_pinf[04].LIMITED[*] = limd_v_oce ELSE def_pinf[04].LIMITED[*] = 1b
IF (v_ohe_on[0]) THEN def_hinf[04].LIMITED[*] = limd_v_ohe ELSE def_hinf[04].LIMITED[*] = 1b
IF (v_obe_on[0]) THEN def_binf[04].LIMITED[*] = limd_v_obe ELSE def_binf[04].LIMITED[*] = 1b
IF (v_oce_on[0]) THEN def_pinf[04].LIMITS[*]  = lims_v_oce ELSE def_pinf[04].LIMITS[*]  = def_v_oc_lim
IF (v_ohe_on[0]) THEN def_hinf[04].LIMITS[*]  = lims_v_ohe ELSE def_hinf[04].LIMITS[*]  = def_v_oh_lim
IF (v_obe_on[0]) THEN def_binf[04].LIMITS[*]  = lims_v_obe ELSE def_binf[04].LIMITS[*]  = def_v_oh_lim
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define model- and species-dependent parameters
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  CORE:
def_pinf[*].VALUE       = cparm
CASE cfunc[0] OF               ;;  Redefine output to proper/allowed format
  'KK'  :  BEGIN
    ;;  bi-kappa core
    IF (exp_c_on[0]) THEN BEGIN
      ;;  Limit kappa values
      def_pinf[05].LIMITED[*] = limd_exp_c
      def_pinf[05].LIMITS[*]  = lims_exp_c
    ENDIF ELSE BEGIN
      ;;  Limit kappa values [use defaults]
      def_pinf[05].LIMITED[*] = 1b
      def_pinf[05].LIMITS[0]  = def_kapp_lim[0]
      def_pinf[05].LIMITS[1]  = def_kapp_lim[1]
    ENDELSE
  END
  'SS'  :  BEGIN
    ;;  bi-self-similar core
    IF (exp_c_on[0]) THEN BEGIN
      ;;  Limit self-similar exponent values
      def_pinf[05].LIMITED[*] = limd_exp_c
      def_pinf[05].LIMITS[*]  = lims_exp_c
    ENDIF ELSE BEGIN
      ;;  Limit self-similar exponent values [use defaults]
      def_pinf[05].LIMITED[*] = 1b
      def_pinf[05].LIMITS[*]  = def_ssex_lim
    ENDELSE
  END
  'AS'  :  BEGIN
    ;;  asymmetric bi-self-similar core
    IF (exp_c_on[0]) THEN BEGIN
      ;;  Limit asymmetric self-similar parallel exponent values
      def_pinf[04].LIMITED[*] = limd_exp_c
      def_pinf[04].LIMITS[*]  = lims_exp_c
    ENDIF ELSE BEGIN
      ;;  Limit asymmetric self-similar parallel exponent values [use defaults]
      def_pinf[04].LIMITED[*] = 1b
      def_pinf[04].LIMITS[*]  = def_ssex_lim
    ENDELSE
    IF (es2_c_on[0]) THEN BEGIN
      ;;  Limit asymmetric self-similar perpendicular exponent values
      def_pinf[05].LIMITED[*] = limd_es2_c
      def_pinf[05].LIMITS[*]  = lims_es2_c
    ENDIF ELSE BEGIN
      ;;  Limit asymmetric self-similar perpendicular exponent values [use defaults]
      def_pinf[05].LIMITED[*] = 1b
      def_pinf[05].LIMITS[*]  = def_ssex_lim
    ENDELSE
  END
  ELSE :  ;;  MM already handled above
ENDCASE
;;----------------------------------------------------------------------------------------
;;  HALO:
;;----------------------------------------------------------------------------------------
def_hinf[*].VALUE       = hparm
CASE hfunc[0] OF               ;;  Redefine output to proper/allowed format
  'KK'  :  BEGIN
    ;;  bi-kappa halo
    IF (exp_h_on[0]) THEN BEGIN
      ;;  Limit kappa values
      def_hinf[05].LIMITED[*] = limd_exp_h
      def_hinf[05].LIMITS[*]  = lims_exp_h
    ENDIF ELSE BEGIN
      ;;  Limit kappa values [use defaults]
      def_hinf[05].LIMITED[*] = 1b
      def_hinf[05].LIMITS[*]  = def_kapp_lim
    ENDELSE
  END
  'SS'  :  BEGIN
    ;;  bi-self-similar halo
    IF (exp_h_on[0]) THEN BEGIN
      ;;  Limit self-similar exponent values
      def_hinf[05].LIMITED[*] = limd_exp_h
      def_hinf[05].LIMITS[*]  = lims_exp_h
    ENDIF ELSE BEGIN
      ;;  Limit self-similar exponent values [use defaults]
      def_hinf[05].LIMITED[*] = 1b
      def_hinf[05].LIMITS[*]  = def_ssex_lim
    ENDELSE
  END
  'AS'  :  BEGIN
    ;;  asymmetric bi-self-similar halo
    IF (exp_h_on[0]) THEN BEGIN
      ;;  Limit asymmetric self-similar parallel exponent values
      def_hinf[04].LIMITED[*] = limd_exp_h
      def_hinf[04].LIMITS[*]  = lims_exp_h
    ENDIF ELSE BEGIN
      ;;  Limit asymmetric self-similar parallel exponent values [use defaults]
      def_hinf[04].LIMITED[*] = 1b
      def_hinf[04].LIMITS[*]  = def_ssex_lim
    ENDELSE
    IF (es2_h_on[0]) THEN BEGIN
      ;;  Limit asymmetric self-similar perpendicular exponent values
      def_hinf[05].LIMITED[*] = limd_es2_h
      def_hinf[05].LIMITS[*]  = lims_es2_h
    ENDIF ELSE BEGIN
      ;;  Limit asymmetric self-similar perpendicular exponent values [use defaults]
      def_hinf[05].LIMITED[*] = 1b
      def_hinf[05].LIMITS[*]  = def_ssex_lim
    ENDELSE
  END
  ELSE :  ;;  MM already handled above
ENDCASE
;;----------------------------------------------------------------------------------------
;;  BEAM:
;;----------------------------------------------------------------------------------------
def_binf[*].VALUE       = bparm
CASE bfunc[0] OF               ;;  Redefine output to proper/allowed format
  'KK'  :  BEGIN
    ;;  bi-kappa beam
    IF (exp_b_on[0]) THEN BEGIN
      ;;  Limit kappa values
      def_binf[05].LIMITED[*] = limd_exp_b
      def_binf[05].LIMITS[*]  = lims_exp_b
    ENDIF ELSE BEGIN
      ;;  Limit kappa values [use defaults]
      def_binf[05].LIMITED[*] = 1b
      def_binf[05].LIMITS[*]  = def_kapp_lim
    ENDELSE
  END
  'SS'  :  BEGIN
    ;;  bi-self-similar beam
    IF (exp_b_on[0]) THEN BEGIN
      ;;  Limit self-similar exponent values
      def_binf[05].LIMITED[*] = limd_exp_b
      def_binf[05].LIMITS[*]  = lims_exp_b
    ENDIF ELSE BEGIN
      ;;  Limit self-similar exponent values [use defaults]
      def_binf[05].LIMITED[*] = 1b
      def_binf[05].LIMITS[*]  = def_ssex_lim
    ENDELSE
  END
  'AS'  :  BEGIN
    ;;  asymmetric bi-self-similar beam
    IF (exp_b_on[0]) THEN BEGIN
      ;;  Limit asymmetric self-similar parallel exponent values
      def_binf[04].LIMITED[*] = limd_exp_b
      def_binf[04].LIMITS[*]  = lims_exp_b
    ENDIF ELSE BEGIN
      ;;  Limit asymmetric self-similar parallel exponent values [use defaults]
      def_binf[04].LIMITED[*] = 1b
      def_binf[04].LIMITS[*]  = def_ssex_lim
    ENDELSE
    IF (es2_b_on[0]) THEN BEGIN
      ;;  Limit asymmetric self-similar perpendicular exponent values
      def_binf[05].LIMITED[*] = limd_es2_b
      def_binf[05].LIMITS[*]  = lims_es2_b
    ENDIF ELSE BEGIN
      ;;  Limit asymmetric self-similar perpendicular exponent values [use defaults]
      def_binf[05].LIMITED[*] = 1b
      def_binf[05].LIMITS[*]  = def_ssex_lim
    ENDELSE
  END
  ELSE :  ;;  MM already handled above
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Check parameter values against limits
;;----------------------------------------------------------------------------------------
FOR j=0L, np[0] - 1L DO BEGIN
  ;;  Core
  IF (def_pinf[j].LIMITED[0]) THEN cparm[j] = def_pinf[j].VALUE > def_pinf[j].LIMITS[0]
  IF (def_pinf[j].LIMITED[1]) THEN cparm[j] = def_pinf[j].VALUE < def_pinf[j].LIMITS[1]
  ;;  Halo
  IF (def_hinf[j].LIMITED[0]) THEN hparm[j] = def_hinf[j].VALUE > def_hinf[j].LIMITS[0]
  IF (def_hinf[j].LIMITED[1]) THEN hparm[j] = def_hinf[j].VALUE < def_hinf[j].LIMITS[1]
  ;;  Beam
  IF (def_binf[j].LIMITED[0]) THEN bparm[j] = def_binf[j].VALUE > def_binf[j].LIMITS[0]
  IF (def_binf[j].LIMITED[1]) THEN bparm[j] = def_binf[j].VALUE < def_binf[j].LIMITS[1]
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Renormalize values, limits, and parameters by [C,H,B]FACT
;;----------------------------------------------------------------------------------------
;;  Core
IF (cfunc[0] NE 'AS' AND cfact[4] EQ 1) THEN cfact[4] = (cfact[4] > MAX(ABS(def_pinf[4].LIMITS),/NAN)) > 1d0
cparm                  = cparm/cfact
def_pinf[*].VALUE      = def_pinf[*].VALUE/cfact
def_pinf[*].LIMITS[0]  = def_pinf[*].LIMITS[0]/cfact
def_pinf[*].LIMITS[1]  = def_pinf[*].LIMITS[1]/cfact
;;  Halo
IF (hfunc[0] NE 'AS' AND hfact[4] EQ 1) THEN hfact[4] = (hfact[4] > MAX(ABS(def_hinf[4].LIMITS),/NAN)) > 1d0
hparm                  = hparm/hfact
def_hinf[*].VALUE      = def_hinf[*].VALUE/hfact
def_hinf[*].LIMITS[0]  = def_hinf[*].LIMITS[0]/hfact
def_hinf[*].LIMITS[1]  = def_hinf[*].LIMITS[1]/hfact
;;  Beam
IF (bfunc[0] NE 'AS' AND bfact[4] EQ 1) THEN bfact[4] = (bfact[4] > MAX(ABS(def_binf[4].LIMITS),/NAN)) > 1d0
bparm                  = bparm/bfact
def_binf[*].VALUE      = def_binf[*].VALUE/bfact
def_binf[*].LIMITS[0]  = def_binf[*].LIMITS[0]/bfact
def_binf[*].LIMITS[1]  = def_binf[*].LIMITS[1]/bfact
;;  Redefine ELECTRONS and IONS keywords for wrapping routine
electrons               = elec_on[0]
ions                    = ion__on[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END








