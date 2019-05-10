;+
;*****************************************************************************************
;
;  PROCEDURE:   log10_wrapper_fit_vdf_2_sumof3funcs.pro
;  PURPOSE  :   This is a wrapping routine that plots and fits input velocity
;                 distributions to the sum of two model functions and then replots the
;                 results.  The routine returns a structure to the user for later use,
;                 if so desired.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;  CALLS:
;               @load_constants_fund_em_atomic_c2014_batch.pro
;               is_a_number.pro
;               is_a_3_vector.pro
;               lbw_window.pro
;               log10_get_defaults_4_parinfo_struc4mpfit_4_vdfs.pro
;               sign.pro
;               unit_vec.pro
;               str_element.pro
;               test_ranges_4_mpfitparinfostruc.pro
;               general_vdf_contour_plot.pro
;               energy_to_vel.pro
;               fill_range.pro
;               mpfit2dfun.pro
;               lbw_diff.pro
;               lbw__add.pro
;               plot_vdfs_4_fitvdf2sumof3funcs.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VDF      :  [N]-Element [float/double] array defining particle velocity
;                             distribution function (VDF) in units of phase space density
;                             [e.g., # s^(+3) km^(-3) cm^(-3)]
;               VELXYZ   :  [N,3]-Element [float/double] array defining the particle
;                             velocity 3-vectors for each element of VDF [km/s]
;
;  EXAMPLES:    
;               [calling sequence]
;               log10_wrapper_fit_vdf_2_sumof3funcs,vdf,velxyz [,VFRAME=vframe] [,VEC1=vec1]                    $
;                                          [,VEC2=vec2] [,COREP=corep] [,HALOP=halop] [,BEAMP=beamp]            $
;                                          [,CFUNC=cfunc] [,HFUNC=hfunc] [,BFUNC=bfunc]                         $
;                                          [,RMSTRAHL=rmstrahl] [,V1ISB=v1isb]                                  $
;                                          [,ELECTRONS=electrons] [,IONS=ions]                                  $
;                                          [,SAVEF=savef] [,FILENAME=filename]                                  $
;                                          [,FIXED_C=fixed_c] [,FIXED_H=fixed_h] [,FIXED_B=fixed_b]             $
;                                          [,NCORE_RAN=ncore_ran] [,NHALO_RAN=nhalo_ran] [,NBEAM_RAN=nbeam_ran] $
;                                          [,TPACORERN=tpacorern] [,TPAHALORN=tpahalorn] [,TPABEAMRN=tpabeamrn] $
;                                          [,TPECORERN=tpecorern] [,TPEHALORN=tpehalorn] [,TPEBEAMRN=tpebeamrn] $
;                                          [,VOACORERN=voacorern] [,VOAHALORN=voahalorn] [,VOABEAMRN=voabeamrn] $
;                                          [,VOECORERN=voecorern] [,VOEHALORN=voehalorn] [,VOEBEAMRN=voebeamrn] $
;                                          [,EXPCORERN=expcorern] [,EXPHALORN=exphalorn] [,EXPBEAMRN=expbeamrn] $
;                                          [,ES2CORERN=es2corern] [,ES2HALORN=es2halorn] [,ES2BEAMRN=es2beamrn] $
;                                          [,EMIN_C=emin_c] [,EMIN_H=emin_h] [,EMIN_B=emin_b]                   $
;                                          [,EMAX_C=emax_c] [,EMAX_H=emax_h] [,EMAX_B=emax_b]                   $
;                                          [,FTOL=ftol] [,GTOL=gtol] [,XTOL=xtol] [,USE_MM=use_mm]              $
;                                          [,USE1C4WGHT=use1c4wght] [,NO_WGHT=no_wght]                          $
;                                          [,/ONLY_TOT] [,/PLOT_BOTH] [,CORE_THRSH=core_thrsh]                  $
;                                          [,POISSON=poisson] [,NB_LT_NH=nb_lt_nh] [,/NOUSECTAB]                $
;                                          [,SPTHRSHS=spthrshs] [,MAXFACS=maxfacs]                              $
;                                          [,OUTSTRC=out_struc] [,_EXTRA=extrakey]
;
;  KEYWORDS:    
;               ***  INPUTS  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all of the following have default settings]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               VFRAME      :  [3]-Element [float/double] array defining the 3-vector
;                                velocity of the K'-frame relative to the K-frame [km/s]
;                                to use to transform the velocity distribution into the
;                                bulk flow reference frame
;                                [ Default = [10,0,0] ]
;               VEC1        :  [3]-Element vector to be used for "parallel" direction in
;                                a 3D rotation of the input data
;                                [e.g. see rotate_3dp_structure.pro]
;                                [ Default = [1.,0.,0.] ]
;               VEC2        :  [3]--Element vector to be used with VEC1 to define a 3D
;                                rotation matrix.  The new basis will have the following:
;                                  X'  :  parallel to VEC1
;                                  Z'  :  parallel to (VEC1 x VEC2)
;                                  Y'  :  completes the right-handed set
;                                [ Default = [0.,1.,0.] ]
;               COREP       :  [6]-Element [numeric] array where each element is defined
;                                by the following quantities:
;                                PARAM[0]  = Core Number Density [cm^(-3)]
;                                PARAM[1]  = Core Parallel Thermal Speed [km/s]
;                                PARAM[2]  = Core Perpendicular Thermal Speed [km/s]
;                                PARAM[3]  = Core Parallel Drift Speed [km/s]
;                                PARAM[4]  = Core Perpendicular Drift Speed [km/s]
;                                PARAM[5]  = Core kappa, self-similar exponent, or not used
;                                [Default = See code for default values]
;               HALOP       :  [6]-Element [numeric] array where each element is defined
;                                by the following quantities:
;                                PARAM[6]  = Halo Number Density [cm^(-3)]
;                                PARAM[7]  = Halo Parallel Thermal Speed [km/s]
;                                PARAM[8]  = Halo Perpendicular Thermal Speed [km/s]
;                                PARAM[9]  = Halo Parallel Drift Speed [km/s]
;                                PARAM[10] = Halo Perpendicular Drift Speed [km/s]
;                                PARAM[11] = Halo kappa, self-similar exponent, or not used
;                                [Default = See code for default values]
;               BEAMP       :  [6]-Element [numeric] array where each element is defined
;                                by the following quantities:
;                                BPARM[0]  = Beam Number Density [cm^(-3)]
;                                BPARM[1]  = Beam Parallel Thermal Speed [km/s]
;                                BPARM[2]  = Beam Perpendicular Thermal Speed [km/s]
;                                BPARM[3]  = Beam Parallel Drift Speed [km/s]
;                                BPARM[4]  = Beam Perpendicular Drift Speed [km/s]
;                                BPARM[5]  = Beam kappa, self-similar exponent, or not used
;                                [Default = starts with similar values as halo]
;               CFUNC       :  Scalar [string] used to determine which model function to
;                                use for the core VDF
;                                  'MM'  :  bi-Maxwellian VDF
;                                  'KK'  :  bi-kappa VDF
;                                  'SS'  :  bi-self-similar VDF
;                                  'AS'  :  asymmetric bi-self-similar VDF
;                                [Default = 'MM']
;               HFUNC       :  Scalar [string] used to determine which model function to
;                                use for the halo VDF
;                                  'MM'  :  bi-Maxwellian VDF
;                                  'KK'  :  bi-kappa VDF
;                                  'SS'  :  bi-self-similar VDF
;                                  'AS'  :  asymmetric bi-self-similar VDF
;                                [Default = 'KK']
;               BFUNC       :  Scalar [string] used to determine which model function to
;                                use for the beam/strahl part of VDF
;                                  'MM'  :  bi-Maxwellian VDF
;                                  'KK'  :  bi-kappa VDF
;                                  'SS'  :  bi-self-similar VDF
;                                  'AS'  :  asymmetric bi-self-similar VDF
;                                [Default = 'KK']
;               RMSTRAHL    :  ***  Still Testing  ***
;                              Scalar [structure] definining the direction and angular
;                                range about defined direction to remove from data when
;                                considering which points that MPFIT.PRO will use in
;                                the fitting process.  The structure must have the
;                                following formatted tags:
;                                  'DIR'  :  [3]-Element [numeric] array defining the
;                                              direction of the strahl (e.g., either
;                                              parallel or anti-parallel to Bo in the
;                                              anti-sunward direction)
;                                              [Default = -1d0*VEC1]
;                                  'ANG'  :  Scalar [numeric] defining the angle [deg] about
;                                              DIR to ignore when fitting the data, i.e.,
;                                              this is the half-angle of the cone about
;                                              DIR that will be excluded
;                                              [Default = 45 degrees]
;                                  'S_L'  :  Scalar [numeric] defining the minimum cutoff
;                                              speed [km/s] below which the data will still
;                                              be included in the fit
;                                              [Default = 1000 km/s]
;               V1ISB       :  Set to a positive or negative unity to indicate whether
;                                the strahl/beam direction is parallel or anti-parallel,
;                                respectively, to the quasi-static magnetic field defined
;                                by VEC1.  If set, the routine will construct the RMSTRAHL
;                                structure with the default values for the tags ANG and
;                                E_L and the DIR tag will be set to V1ISB[0]*VEC1.
;                                [Default = FALSE]
;               _EXTRA      :  Other keywords accepted by general_vdf_contour_plot.pro
;               ELECTRONS   :  If set, routine uses parameters appropriate for non-
;                                relativistic electron velocity distributions
;                                [Default = TRUE]
;               IONS        :  If set, routine uses parameters appropriate for non-
;                                relativistic proton velocity distributions
;                                [Default = FALSE]
;               SAVEF       :  If set, routine will save the final plot to a PS file
;                                [Default = FALSE]
;               FILENAME    :  Scalar [string] defining the file name for the saved PS
;                                file.  Note that the format of the file name must be
;                                such that IDL_VALIDNAME.PRO returns a non-null string
;                                with at least the CONVERT_ALL keyword set.
;                                [Default = 'vdf_fit_plot_0']
;               ONLY_TOT    :  If set, routine will only plot the sum of all the model fit
;                                cuts instead of each individually
;                                [Default = FALSE]
;               PLOT_BOTH   :  If set, routine will plot both forms of output where one
;                                shows only the sum of all fits and the other shows each
;                                1D fit line cut individually.  Note that if set, this
;                                keyword will take precedence over the ONLY_TOT setting.
;                                [Default  :  FALSE]
;               FIXED_C     :  [6]-Element array containing ones for each element of
;                                COREP the user does NOT wish to vary (i.e., if FIXED_C[0]
;                                is = 1, then COREP[0] will not change when calling
;                                MPFITFUN.PRO).
;                                [Default  :  All elements = 0]
;               FIXED_H     :  [6]-Element array containing ones for each element of
;                                HALOP the user does NOT wish to vary (i.e., if FIXED_H[2]
;                                is = 1, then HALOP[2] will not change when calling
;                                MPFITFUN.PRO).
;                                [Default  :  All elements = 0]
;               FIXED_B     :  [6]-Element array containing ones for each element of
;                                BEAMP the user does NOT wish to vary (i.e., if FIXED_B[3]
;                                is = 1, then BEAMP[3] will not change when calling
;                                MPFITFUN.PRO).
;                                [Default  :  All elements = 0]
;               NCORE_RAN   :  [4]-Element [numeric] array defining the range of allowed
;                                values to use for the core number density or PARAM[0].
;                                Note, if this keyword is set, it is equivalent to telling
;                                the routine that N_core should be limited by these
;                                bounds.  Setting this keyword will define:
;                                  PARINFO[0].LIMITED[*] = BYTE(NCORE_RAN[0:1])
;                                  PARINFO[0].LIMITS[*]  = NCORE_RAN[2:3]
;               NHALO_RAN   :  Same as NCORE_RAN but for HARAM[0] and HARINFO[0].
;               NBEAM_RAN   :  Same as NCORE_RAN but for BPARM[0] and BARINFO[0].
;               TPACORERN   :  [4]-Element [numeric] array defining the range of allowed
;                                values to use for the core parallel temperature or
;                                PARAM[1].  Note, if this keyword is set, it is
;                                equivalent to telling the routine that Tcpara should be
;                                limited by these bounds.  Setting this keyword will
;                                define:
;                                  PARINFO[1].LIMITED[*] = BYTE(TPACORERN[0:1])
;                                  PARINFO[1].LIMITS[*]  = TPACORERN[2:3]
;               TPAHALORN   :  Same as TPACORERN but for HPARM[1] and HARINFO[1].
;               TPABEAMRN   :  Same as TPACORERN but for BPARM[1] and BARINFO[1].
;               TPECORERN   :  [4]-Element [numeric] array defining the range of allowed
;                                values to use for the core perpendicular temperature
;                                or PARAM[2].  Note, if this keyword is set, it is
;                                equivalent to telling the routine that Tcperp should be
;                                limited by these bounds.  Setting this keyword will
;                                define:
;                                  PARINFO[2].LIMITED[*] = BYTE(TPECORERN[0:1])
;                                  PARINFO[2].LIMITS[*]  = TPECORERN[2:3]
;               TPEHALORN   :  Same as TPECORERN but for HPARM[2] and HARINFO[2].
;               TPEBEAMRN   :  Same as TPECORERN but for BPARM[2] and BARINFO[2].
;               VOACORERN   :  [4]-Element [numeric] array defining the range of allowed
;                                values to use for the core parallel drift speed or
;                                PARAM[3].  Note, if this keyword is set, it is
;                                equivalent to telling the routine that V_ocpara should be
;                                limited by these bounds.  Setting this keyword will
;                                define:
;                                  PARINFO[3].LIMITED[*] = BYTE(VOACORERN[0:1])
;                                  PARINFO[3].LIMITS[*]  = VOACORERN[2:3]
;               VOAHALORN   :  Same as VOACORERN but for HPARM[3] and HARINFO[3].
;               VOABEAMRN   :  Same as VOACORERN but for BPARM[3] and BARINFO[3].
;               VOECORERN   :  [4]-Element [numeric] array defining the range of allowed
;                                values to use for the core perpendicular drift speed
;                                or PARAM[4].  Note, if this keyword is set, it is
;                                equivalent to telling the routine that V_ocperp should be
;                                limited by these bounds.  Setting this keyword will
;                                define:
;                                  PARINFO[4].LIMITED[*] = BYTE(VOECORERN[0:1])
;                                  PARINFO[4].LIMITS[*]  = VOECORERN[2:3]
;               VOEHALORN   :  Same as VOECORERN but for HPARM[4] and HARINFO[4].
;               VOEBEAMRN   :  Same as VOECORERN but for BPARM[4] and BARINFO[4].
;               EXPCORERN   :  [4]-Element [numeric] array defining the range of allowed
;                                values to use for the exponent parameter or PARAM[5].
;                                Note, if this keyword is set, it is equivalent to
;                                telling the routine that V_ocperp should be limited by
;                                these bounds.  Setting this keyword will define:
;                                  PARINFO[5].LIMITED[*] = BYTE(EXPCORERN[0:1])
;                                  PARINFO[5].LIMITS[*]  = EXPCORERN[2:3]
;               EXPHALORN   :  Same as EXPCORERN but for HPARM[5] and HARINFO[5].
;               EXPBEAMRN   :  Same as EXPCORERN but for BPARM[5] and BARINFO[5].
;               ES2CORERN   :  Same as EXPCORERN but only used when CFUNC = 'AS', which
;                                results in that VDF component no longer using a
;                                perpendicular drift velocity but replacing it with
;                                EXPCORERN.  Setting this keyword will define:
;                                  PARINFO[4].LIMITED[*] = BYTE(EXPCORERN[0:1])
;                                  PARINFO[4].LIMITS[*]  = EXPCORERN[2:3]
;                                  PARINFO[5].LIMITED[*] = BYTE(ES2CORERN[0:1])
;                                  PARINFO[5].LIMITS[*]  = ES2CORERN[2:3]
;               ES2HALORN   :  Same as ES2CORERN but for halo when HFUNC = 'AS'
;               ES2BEAMRN   :  Same as ES2CORERN but for beam when BFUNC = 'AS'
;               EMIN_C      :  Scalar [numeric] defining the minimum energy [eV] to
;                                consider during the fitting process (only alters the
;                                WEIGHTS parameter) for the core distribution
;                                [Default = 0]
;               EMIN_H      :  Scalar [numeric] defining the minimum energy [eV] to
;                                consider during the fitting process (only alters the
;                                WEIGHTS parameter) for the halo distribution
;                                [Default = 0]
;               EMIN_B      :  Scalar [numeric] defining the minimum energy [eV] to
;                                consider during the fitting process (only alters the
;                                WEIGHTS parameter) for the beam distribution
;                                [Default = 0]
;               EMAX_C      :  Scalar [numeric] defining the maximum energy [eV] to
;                                consider during the fitting process (only alters the
;                                WEIGHTS parameter) for the core distribution
;                                [Default = 10^30]
;               EMAX_H      :  Scalar [numeric] defining the maximum energy [eV] to
;                                consider during the fitting process (only alters the
;                                WEIGHTS parameter) for the halo distribution
;                                [Default = 10^30]
;               EMAX_B      :  Scalar [numeric] defining the maximum energy [eV] to
;                                consider during the fitting process (only alters the
;                                WEIGHTS parameter) for the beam distribution
;                                [Default = 10^30]
;               FTOL        :  Scalar [double] definining the maximum values in both
;                                the actual and predicted relative reductions in the sum
;                                squares are at most FTOL at termination.  Therefore, FTOL
;                                measures the relative error desired in the sum of
;                                squares.
;                                [Default  :  1d-14 ]
;               GTOL        :  Scalar [double] definining the value of the absolute cosine
;                                of the angle between fvec and any column of the jacobian
;                                allowed before terminating the fit calculation.
;                                Therefore, GTOL measures the orthogonality desired
;                                between the function vector and the columns of the
;                                jacobian.
;                                [Default  :  1d-14 ]
;               XTOL        :  Scalar [double] definining the maximum relative error
;                                between two consecutive iterates to allow before
;                                terminating the fit calculation.  Thus, XTOL measures
;                                the relative error desired in the approximate solution.
;                                [Default  :  1d-12 ]
;               USE1C4WGHT  :  If set, routine will use the one-count levels for weights
;                                instead of 1% of the data
;                                [Default  :  FALSE]
;               NO_WGHT     :  If set, routine will use a value of 1.0 for all weights
;                                instead of 1% of the data
;                                [Default  :  FALSE]
;               POISSON     :  [N]-Element [float/double] array defining the Poisson
;                                counting statistics of the input VDF in units of
;                                phase space density.  Note the units and size must
;                                match that of the VDF input for this to be meaningful.
;                                [e.g., # s^(+3) km^(-3) cm^(-3)]
;                                [Default  :  FALSE]
;               NB_LT_NH    :  If set, routine will redefine the LIMITS values of the
;                                PARINFO structure for the beam fit so as to keep the
;                                beam density at or below the halo density.  For the
;                                solar wind electrons, it is generally assumed that the
;                                strahl density is less than the halo at 1 AU, so one
;                                may find setting this keyword to be the physically
;                                significant approach.  It may also hinder a good fit
;                                and it should be noted that the strahl having a smaller
;                                density than the halo is largely an assumption that
;                                has been imposed upon the fitting routines in past
;                                studies, not necessarily a rigorous, physically
;                                consistent requirement.
;               NOUSECTAB   :  If set, routine will not force the use of its default
;                                color table setting of IDL's color table 33
;                                [Default  :  FALSE]
;               CORE_THRSH  :  Scalar [float/double] defining the fraction of the peak
;                                phase space density above which to consider for the
;                                core-only fit (value must be below 50%)
;                                [Default = 0.01]
;               SPTHRSHS    :  [3]-Element [float/double] array defining the fraction of
;                                the maximum speed of the input VDF to allow when looking
;                                for peaks exceeding MAXFACS for each component
;                                [ Default = [0.15, 0.20, 0.20] ]
;               MAXFACS     :  [3]-Element [float/double] array defining the maximum
;                                value of the ratio between the model and data for each
;                                component to allow.  Any component exceeding this value
;                                will be nullified and the status set to -20.
;                                [ Default = [9.00, 2.25, 2.25] ]
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               OUTSTRC     :  Set to a named variable to return all the relevant data
;                                used to create the contour plot and cuts of the VDF
;
;   CHANGED:  1)  Fixed how total chi-squared and reduced values are calculated and
;                   added total reduced chi-squared to output structure
;                                                                   [04/22/2019   v1.0.1]
;             2)  Now returns two forms of the total value and reduced chi-squared
;                                                                   [04/25/2019   v1.0.2]
;
;   NOTES:      
;               0)  ***  Do not directly set the RMSTRAHL keyword  ***
;               1)  AUTODERIVATIVE=0 overrides any setting of MPSIDE for all parameters
;               2)  To use explicit derivatives, set AUTODERIVATIVE=0 or set MPSIDE=3 for
;                     each parameter for which the user wishes to use explicit
;                     derivatives.
;               3)  **  Do NOT set PARINFO, let the routine set it up for you  **
;               ******************************************
;               ***  Do not set this keyword yourself  ***
;               ******************************************
;               PARINFO  :  [6]-Element array [structure] used by MPFIT.PRO
;                             where the i-th contains the following tags and
;                             definitions:
;                             VALUE    =  Scalar [float/double] value defined by
;                                           PARAM[i].  The user need not set this value.
;                                           [Default = PARAM[i] ]
;                             FIXED    =  Scalar [boolean] value defining whether to
;                                           allow MPFIT.PRO to vary PARAM[i] or not
;                                           TRUE   :  parameter constrained
;                                                     (i.e., no variation allowed)
;                                           FALSE  :  parameter unconstrained
;                             LIMITED  =  [2]-Element [boolean] array defining if the
;                                           lower/upper bounds defined by LIMITS
;                                           are imposed(TRUE) otherwise it has no effect
;                                           [Default = FALSE]
;                             LIMITS   =  [2]-Element [float/double] array defining the
;                                           [lower,upper] bounds on PARAM[i].  Both
;                                           LIMITED and LIMITS must be given together.
;                                           [Default = [0.,0.] ]
;                             TIED     =  Scalar [string] that mathematically defines
;                                           how PARAM[i] is forcibly constrained.  For
;                                           instance, assume that PARAM[0] is always
;                                           equal to 2 Pi times PARAM[1], then one would
;                                           define the following:
;                                             PARINFO[0].TIED = '2 * !DPI * P[1]'
;                                           [Default = '']
;                             MPSIDE   =  Scalar value with the following
;                                           consequences:
;                                            0 : 1-sided deriv. computed automatically
;                                            1 : 1-sided deriv. (f(x+h) - f(x)  )/h
;                                           -1 : 1-sided deriv. (f(x)   - f(x-h))/h
;                                            2 : 2-sided deriv. (f(x+h) - f(x-h))/(2*h)
;                                            3 : explicit deriv. used for this parameter
;                                           See MPFIT.PRO and MPFITFUN.PRO for more...
;                                           [Default = 3]
;               4)  Fit Status Interpretations
;                     > 0 = success
;                     -18 = a fatal execution error has occurred.  More information may
;                           be available in the ERRMSG string.
;                     -16 = a parameter or function value has become infinite or an
;                           undefined number.  This is usually a consequence of numerical
;                           overflow in the user's model function, which must be avoided.
;                     -15 to -1 = 
;                           these are error codes that either MYFUNCT or ITERPROC may
;                           return to terminate the fitting process (see description of
;                           MPFIT_ERROR common below).  If either MYFUNCT or ITERPROC
;                           set ERROR_CODE to a negative number, then that number is
;                           returned in STATUS.  Values from -15 to -1 are reserved for
;                           the user functions and will not clash with MPFIT.
;                     0 = improper input parameters.
;                     1 = both actual and predicted relative reductions in the sum of
;                           squares are at most FTOL.
;                     2 = relative error between two consecutive iterates is at most XTOL
;                     3 = conditions for STATUS = 1 and STATUS = 2 both hold.
;                     4 = the cosine of the angle between fvec and any column of the
;                           jacobian is at most GTOL in absolute value.
;                     5 = the maximum number of iterations has been reached
;                           (may indicate failure to converge)
;                     6 = FTOL is too small. no further reduction in the sum of squares
;                           is possible.
;                     7 = XTOL is too small. no further improvement in the approximate
;                           solution x is possible.
;                     8 = GTOL is too small. fvec is orthogonal to the columns of the
;                           jacobian to machine precision.
;               5)  MPFIT routines can be found at:
;                     http://cow.physics.wisc.edu/~craigm/idl/idl.html
;               6)  Definition of WEIGHTS keyword input for MPFIT routines
;                     Array of weights to be used in calculating the chi-squared
;                     value.  If WEIGHTS is specified then the ERR parameter is
;                     ignored.  The chi-squared value is computed as follows:
;
;                         CHISQ = TOTAL( ( Y - MYFUNCT(X,P) )^2 * ABS(WEIGHTS) )
;
;                     where ERR = the measurement error (yerr variable herein).
;
;                     Here are common values of WEIGHTS for standard weightings:
;                       1D/ERR^2 - Normal or Gaussian weighting
;                       1D/Y     - Poisson weighting (counting statistics)
;                       1D       - Unweighted
;
;                     NOTE: the following special cases apply:
;                       -- if WEIGHTS is zero, then the corresponding data point
;                            is ignored
;                       -- if WEIGHTS is NaN or Infinite, and the NAN keyword is set,
;                            then the corresponding data point is ignored
;                       -- if WEIGHTS is negative, then the absolute value of WEIGHTS
;                            is used
;               7)  See also:  log10_*_biselfsimilar_fit.pro, log10_*_bikappa_fit.pro, log10_*_bimaxwellian_fit.pro
;               8)  VDF = velocity distribution function
;               9)  There is an odd issue that occurs in some cases when MPSIDE=3 for
;                     all parameters except the densities and exponents.  The Jacobian
;                     fails to converge and the MPFIT routines return a status of -16.
;                     To mitigate this issue, we force MPSIDE=0 as a default instead of
;                     MPSIDE=3.
;              10)  Errors and weights are used in the following way in MPFIT2DFUN_EVAL.PRO
;                     result = (z_in - f_model)/error
;                   OR
;                     result = (z_in - f_model)*weights
;              11)  The best results occur when the user supplies Poisson counting
;                     statistics through the POISSON keyword (and gives decent guesses,
;                     of course).  The resulting reduced chi-squared values tend toward
;                     unity rather than hundreds or thousands with the other error
;                     estimates.
;              12)  If any of the function keywords are set to [C,H,B]FUNC = 'AS', then
;                     that VDF component will have input parameters as follows:
;                       PARAM[0]  = [C,H,B] Number Density [cm^(-3)]
;                       PARAM[1]  = [C,H,B] Parallel Thermal Speed [km/s]
;                       PARAM[2]  = [C,H,B] Perpendicular Thermal Speed [km/s]
;                       PARAM[3]  = [C,H,B] Parallel Drift Speed [km/s]
;                       PARAM[4]  = [C,H,B] Parallel self-similar exponent
;                       PARAM[5]  = [C,H,B] Perpendicular self-similar exponent
;
;  REFERENCES:  
;               0)  Barnes, A. "Collisionless Heating of the Solar-Wind Plasma I. Theory
;                      of the Heating of Collisionless Plasma by Hydromagnetic Waves,"
;                      Astrophys. J. 154, pp. 751--759, 1968.
;               1)  Mace, R.L. and R.D. Sydora "Parallel whistler instability in a plasma
;                      with an anisotropic bi-kappa distribution," J. Geophys. Res. 115,
;                      pp. A07206, doi:10.1029/2009JA015064, 2010.
;               2)  Livadiotis, G. "Introduction to special section on Origins and
;                      Properties of Kappa Distributions: Statistical Background and
;                      Properties of Kappa Distributions in Space Plasmas,"
;                      J. Geophys. Res. 120, pp. 1607--1619, doi:10.1002/2014JA020825,
;                      2015.
;               3)  Dum, C.T., et al., "Turbulent Heating and Quenching of the Ion Sound
;                      Instability," Phys. Rev. Lett. 32(22), pp. 1231--1234, 1974.
;               4)  Dum, C.T. "Strong-turbulence theory and the transition from Landau
;                      to collisional damping," Phys. Rev. Lett. 35(14), pp. 947--950,
;                      1975.
;               5)  Jain, H.C. and S.R. Sharma "Effect of flat top electron distribution
;                      on the turbulent heating of a plasma," Beitraega aus der
;                      Plasmaphysik 19, pp. 19--24, 1979.
;               6)  Goldman, M.V. "Strong turbulence of plasma waves," Rev. Modern Phys.
;                      56(4), pp. 709--735, 1984.
;               7)  Horton, W., et al., "Ion-acoustic heating from renormalized
;                      turbulence theory," Phys. Rev. A 14(1), pp. 424--433, 1976.
;               8)  Horton, W. and D.-I. Choi "Renormalized turbulence theory for the
;                      ion acoustic problem," Phys. Rep. 49(3), pp. 273--410, 1979.
;               9)  Livadiotis, G. "Statistical origin and properties of kappa
;                      distributions," J. Phys.: Conf. Ser. 900(1), pp. 012014, 2017.
;              10)  Livadiotis, G. "Derivation of the entropic formula for the
;                      statistical mechanics of space plasmas,"
;                      Nonlin. Proc. Geophys. 25(1), pp. 77-88, 2018.
;              11)  Livadiotis, G. "Modeling anisotropic Maxwell-Jüttner distributions:
;                      derivation and properties," Ann. Geophys. 34(1),
;                      pp. 1145-1158, 2016.
;              12) Markwardt, C. B. "Non-Linear Least Squares Fitting in IDL with
;                    MPFIT," in proc. Astronomical Data Analysis Software and Systems
;                    XVIII, Quebec, Canada, ASP Conference Series, Vol. 411,
;                    Editors: D. Bohlender, P. Dowler & D. Durand, (Astronomical
;                    Society of the Pacific: San Francisco), pp. 251-254,
;                    ISBN:978-1-58381-702-5, 2009.
;              13) Moré, J. 1978, "The Levenberg-Marquardt Algorithm: Implementation and
;                    Theory," in Numerical Analysis, Vol. 630, ed. G. A. Watson
;                    (Springer-Verlag: Berlin), pp. 105, doi:10.1007/BFb0067690, 1978.
;              14) Moré, J. and S. Wright "Optimization Software Guide," SIAM,
;                    Frontiers in Applied Mathematics, Number 14,
;                    ISBN:978-0-898713-22-0, 1993.
;              15)  The IDL MINPACK routines can be found on Craig B. Markwardt's site at:
;                     http://cow.physics.wisc.edu/~craigm/idl/fitting.html
;              16)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 1. Analysis Techniques and Methodology,"
;                      J. Geophys. Res. 119(8), pp. 6455--6474, 2014a.
;              17)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 2. Waves and Dissipation,"
;                      J. Geophys. Res. 119(8), pp. 6475--6495, 2014b.
;              18)  Wilson III, L.B., et al., "Relativistic electrons produced by
;                      foreshock disturbances observed upstream of the Earth’s bow
;                      shock," Phys. Rev. Lett. 117(21), pp. 215101, 2016.
;              19)  Wilson III, L.B., et al., "The Statistical Properties of Solar Wind
;                      Temperature Parameters Near 1 au," Astrophys. J. Suppl. 236(2),
;                      pp. 41, doi:10.3847/1538-4365/aab71c, 2018.
;              20)  L.B. Wilson III, et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      arXiv, eprint 1902.01476, 2019a.
;
;   ADAPTED FROM: wrapper_fit_vdf_2_sumof3funcs.pro    BY: Lynn B. Wilson III
;   CREATED:  04/03/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/25/2019   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO log10_wrapper_fit_vdf_2_sumof3funcs,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,          $
                                  COREP=corep,HALOP=halop,CFUNC=cfunc,HFUNC=hfunc,             $
                                  RMSTRAHL=rmstrahl,V1ISB=v1isb,                               $
                                  ELECTRONS=electrons,IONS=ions,                               $
                                  BEAMP=beamp,BFUNC=bfunc,ONLY_TOT=only_tot,                   $
                                  FIXED_C=fixed_c,FIXED_H=fixed_h,FIXED_B=fixed_b,             $
                                  NCORE_RAN=ncore_ran,NHALO_RAN=nhalo_ran,NBEAM_RAN=nbeam_ran, $
                                  TPACORERN=tpacorern,TPAHALORN=tpahalorn,TPABEAMRN=tpabeamrn, $
                                  TPECORERN=tpecorern,TPEHALORN=tpehalorn,TPEBEAMRN=tpebeamrn, $
                                  VOACORERN=voacorern,VOAHALORN=voahalorn,VOABEAMRN=voabeamrn, $
                                  VOECORERN=voecorern,VOEHALORN=voehalorn,VOEBEAMRN=voebeamrn, $
                                  EXPCORERN=expcorern,EXPHALORN=exphalorn,EXPBEAMRN=expbeamrn, $
                                  ES2CORERN=es2corern,ES2HALORN=es2halorn,ES2BEAMRN=es2beamrn, $
                                  EMIN_C=emin_c,EMIN_H=emin_h,EMIN_B=emin_b,                   $
                                  EMAX_C=emax_c,EMAX_H=emax_h,EMAX_B=emax_b,                   $
                                  FTOL=ftol,GTOL=gtol,XTOL=xtol,USE1C4WGHT=use1c4wght,         $
                                  NO_WGHT=no_wght,PLOT_BOTH=plot_both,POISSON=poisson,         $
                                  NB_LT_NH=nb_lt_nh,SAVEF=savef,FILENAME=filename,             $
                                  NOUSECTAB=nousectab,CORE_THRSH=core_thrsh,                   $
                                  SPTHRSHS=spthrshs,MAXFACS=maxfac0,                           $
                                  _EXTRA=extrakey,                                             $
                                  OUTSTRC=out_struc

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f                       = !VALUES.F_NAN
d                       = !VALUES.D_NAN
verns                   = !VERSION.RELEASE     ;;  e.g., '7.1.1'
vernn                   = LONG(STRMID(verns[0],0L,1L))
;;  Check IDL version
IF (vernn[0] LT 8) THEN nan_on = 0b ELSE nan_on = 1b
;;  Defaults
c__trial                = 1                  ;;  Counting value to let user know how many tries the routine used before exiting
h__trial                = 1                  ;;  Counting value to let user know how many tries the routine used before exiting
b__trial                = 1                  ;;  Counting value to let user know how many tries the routine used before exiting
pre_pre_str             = ';;  '
sform                   = '(e15.4)'
fitstat_mid             = ['Model Fit Status  ','# of Iterations   ','Deg. of Freedom   ',$
                           'Chi-Squared       ','Red. Chi-Squared  ']+'= '
c_cols                  = [225, 75]
h_cols                  = [200, 30]
b_cols                  = [110, 90]
t_cols                  = [200,100]
maxiter                 = 300L               ;;  Default maximum # of iterations to allow MPFIT.PRO to cycle through
def_ctab                = 39                 ;;  Default color table for lines
;;  Define popen structure
popen_str               = {PORT:1,UNITS:'inches',XSIZE:8e0,YSIZE:11e0,ASPECT:0}
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
;;    Speed and Frequency
vtefac         = SQRT(2d0*eV2J[0]/me[0])*1d-3
vtpfac         = SQRT(2d0*eV2J[0]/mp[0])*1d-3
;;-------------------------------------------------------
;;  Default fit parameter limits/ranges
;;-------------------------------------------------------
def_kapp_lim            = [3d0/2d0,10d1]  ;;  3/2 ≤ kappa ≤ 100
def_ssex_lim            = [2d0,1d1]       ;;  self-similar exponent:  2 ≤ p ≤ 10
def_voec_lim            = [-1d0,1d0]*1d3  ;;   -1000 km/s ≤ V_oecj ≤  +1000 km/s
def_voic_lim            = [-1d0,1d0]*2d3  ;;   -2000 km/s ≤ V_opcj ≤  +2000 km/s
;;  Check IONS
test           = (N_ELEMENTS(ions) GT 0) AND KEYWORD_SET(ions)
IF (test[0]) THEN ion__on = 1b ELSE ion__on = 0b
;;  Check ELECTRONS
test           = (N_ELEMENTS(electrons) GT 0) AND KEYWORD_SET(electrons)
IF (test[0]) THEN elec_on = 1b ELSE elec_on = ([0b,1b])[~ion__on[0]]
IF (elec_on[0] AND ion__on[0]) THEN ion__on[0] = 0b                    ;;  Make sure only one particle type is set
IF (elec_on[0]) THEN def_v_oc_lim = def_voec_lim ELSE def_v_oc_lim = def_voic_lim
;;  Redefine ELECTRONS and IONS keywords
electrons               = elec_on[0]
ions                    = ion__on[0]
IF (elec_on[0]) THEN vthfac = vtefac[0] ELSE vthfac = vtpfac[0]
;;  Check NOUSECTAB
IF ((N_ELEMENTS(nousectab) EQ 0) OR ~KEYWORD_SET(nousectab)) THEN BEGIN
  ;;  Force new color table that minimizes amount of green and yellow on output
  SET_PLOT,'X'
  LOADCT,def_ctab[0]
  SET_PLOT,'PS'
  LOADCT,def_ctab[0]
  SET_PLOT,'X'
ENDIF
;;-------------------------------------------------------
;;  Define default RMSTRAHL structure
;;-------------------------------------------------------
tags                    = ['DIR','ANG','S_L']
def_rmstrahl            = CREATE_STRUCT(tags,[-1d0,0d0,0d0],45d0,1d3)
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN RETURN          ;;  Don't bother if nothing is provided
;;  Check parameter
test                    = is_a_number(vdf,/NOMSSG) AND is_a_3_vector(velxyz,V_OUT=vv1,/NOMSSG)
IF (~test[0]) THEN RETURN                 ;;  Don't bother if input is bad
szdf                    = SIZE(vdf,/DIMENSIONS)
szdv                    = SIZE(vv1,/DIMENSIONS)
IF (szdf[0] NE szdv[0]) THEN RETURN       ;;  Don't bother if input is improperly formatted
nn_f                    = szdf[0]         ;;  # of VDF points in input array
vdf                     = REFORM(vdf,nn_f[0])
velxyz                  = vv1
vv1                     = 0
;;----------------------------------------------------------------------------------------
;;  Open 1 plot window
;;----------------------------------------------------------------------------------------
dev_name                = STRLOWCASE(!D[0].NAME[0])
os__name                = STRLOWCASE(!VERSION.OS_FAMILY)       ;;  'unix' or 'windows'
;;  Check device settings
test_xwin               = (dev_name[0] EQ 'x') OR (dev_name[0] EQ 'win')
IF (test_xwin[0]) THEN BEGIN
  ;;  Proper setting --> find out which windows are already open
  DEVICE,WINDOW_STATE=wstate
ENDIF ELSE BEGIN
  ;;  Switch to proper device
  IF (os__name[0] EQ 'windows') THEN SET_PLOT,'win' ELSE SET_PLOT,'x'
  ;;  Determine which windows are already open
  DEVICE,WINDOW_STATE=wstate
ENDELSE
DEVICE,GET_SCREEN_SIZE=s_size
wsz                     = LONG(MIN(s_size*7d-1))
xywsz                   = [wsz[0],LONG(wsz[0]*1.375d0)]
;;  Now that things are okay, check window status
good_w                  = WHERE(wstate,gd_w)
wind_ns                 = [4,5]
;;  Check if user specified window is already open
test_wopen0             = (TOTAL(good_w EQ wind_ns[0]) GT 0)     ;;  TRUE --> window already open
IF (test_wopen0[0]) THEN BEGIN
  ;;  Window 4 is open --> check if was opened by this routine
  WSET,wind_ns[0]
  cur_xywsz               = [!D.X_SIZE[0],!D.Y_SIZE[0]]
  new_w_0                 = (xywsz[0] NE cur_xywsz[0]) OR (xywsz[1] NE cur_xywsz[1])
ENDIF ELSE new_w_0 = 1b   ;;  Open new  window
;;  Temporarily change settings when cleaning windows
IF ((N_ELEMENTS(nousectab) EQ 0) OR ~KEYWORD_SET(nousectab)) THEN BEGIN
  LOADCT,def_ctab[0]
  !P.BACKGROUND = 'FFFFFF'x       ;;  Hex equivalent in RGB of white
  !P.COLOR      = '000000'x       ;;  Hex equivalent in RGB of black
ENDIF
win_ttl                 = 'VDF Initial Guess'
win_str                 = {RETAIN:2,XSIZE:xywsz[0],YSIZE:xywsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
lbw_window,WIND_N=wind_ns[0],NEW_W=new_w_0[0],_EXTRA=win_str,/CLEAN
IF ((N_ELEMENTS(nousectab) EQ 0) OR ~KEYWORD_SET(nousectab)) THEN LOADCT,def_ctab[0]
;;----------------------------------------------------------------------------------------
;;  Get default PARINFO structure
;;----------------------------------------------------------------------------------------
test                    = log10_get_defaults_4_parinfo_struc4mpfit_4_vdfs(CFUNC=cfunc,HFUNC=hfunc, $
                                      BFUNC=bfunc,ELECTRONS=electrons,IONS=ions,                   $
                                      FIXED_C=fixed_c,FIXED_H=fixed_h,FIXED_B=fixed_b,             $
                                      NCORE_RAN=ncore_ran,NHALO_RAN=nhalo_ran,NBEAM_RAN=nbeam_ran, $
                                      TPACORERN=tpacorern,TPAHALORN=tpahalorn,TPABEAMRN=tpabeamrn, $
                                      TPECORERN=tpecorern,TPEHALORN=tpehalorn,TPEBEAMRN=tpebeamrn, $
                                      VOACORERN=voacorern,VOAHALORN=voahalorn,VOABEAMRN=voabeamrn, $
                                      VOECORERN=voecorern,VOEHALORN=voehalorn,VOEBEAMRN=voebeamrn, $
                                      EXPCORERN=expcorern,EXPHALORN=exphalorn,EXPBEAMRN=expbeamrn, $
                                      ES2CORERN=es2corern,ES2HALORN=es2halorn,ES2BEAMRN=es2beamrn, $
                                      FTOL=ftol,GTOL=gtol,XTOL=xtol,                               $
                                      DEF_OFFST=def_offst,PARINFO=def_pinf,HARINFO=def_hinf,       $
                                      BARINFO=def_binf,FUNC_C=cfun,FUNC_H=hfun,FUNC_B=bfun,        $
                                      CORE_LABS=core_labs,HALO_LABS=halo_labs,BEAM_LABS=beam_labs, $
                                      XYLAB_PRE=xylabpre                                           )
IF (SIZE(def_pinf,/TYPE) NE 8) THEN STOP ;; Debug
def_param               = def_pinf.VALUE
def_haram               = def_hinf.VALUE
def_baram               = def_binf.VALUE
np                      = N_ELEMENTS(def_pinf)
cf                      = cfunc[0]
hf                      = hfunc[0]
bf                      = bfunc[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords with default options
;;----------------------------------------------------------------------------------------
vfac                    = 1d0
ffac                    = 1d0/vfac[0]^3d0                        ;;  km^(-3) --> Mm^(-3)
pfar                    = [1d0,REPLICATE(vfac[0],4L),1d0]        ;;  Array to multiply with parameters for general_vdf_contour_plot.pro input and use for inversing:  Mm --> km
pfar1                   = [1d0,REPLICATE(vfac[0],3L),1d0,1d0]
old_parm_cfac           = [1d0,REPLICATE(vthfac[0],2L),1d0,1d0,1d0]
;;------------------------------
;;  Check COREP
;;------------------------------
test                    = (N_ELEMENTS(corep) EQ 6) AND is_a_number(corep,/NOMSSG)
IF (test[0]) THEN BEGIN
  pcore        = DOUBLE(corep)
  ;;  Adjust parameters by velocity factor
  IF (cf[0] NE 'AS') THEN pcore[01:04] *= vfac[0] ELSE pcore[01:03] *= vfac[0]
  ;;  Check limits [*** Required to avoid conflicts in MPFIT.PRO ***]
  IF (def_pinf[00].LIMITED[0]) THEN pcore[0]  = pcore[0] > def_pinf[00].LIMITS[0]
  IF (def_pinf[00].LIMITED[1]) THEN pcore[0]  = pcore[0] < def_pinf[00].LIMITS[1]
  IF (def_pinf[01].LIMITED[0]) THEN pcore[1]  = pcore[1] > def_pinf[01].LIMITS[0]
  IF (def_pinf[01].LIMITED[1]) THEN pcore[1]  = pcore[1] < def_pinf[01].LIMITS[1]
  IF (def_pinf[01].LIMITED[0]) THEN pcore[2]  = pcore[2] > def_pinf[01].LIMITS[0]
  IF (def_pinf[01].LIMITED[1]) THEN pcore[2]  = pcore[2] < def_pinf[01].LIMITS[1]
  IF (def_pinf[03].LIMITED[0]) THEN pcore[3]  = pcore[3] > def_pinf[03].LIMITS[0]
  IF (def_pinf[03].LIMITED[1]) THEN pcore[3]  = pcore[3] < def_pinf[03].LIMITS[1]
  IF (def_pinf[04].LIMITED[0]) THEN pcore[4]  = pcore[4] > def_pinf[04].LIMITS[0]
  IF (def_pinf[04].LIMITED[1]) THEN pcore[4]  = pcore[4] < def_pinf[04].LIMITS[1]
  IF (cf[0] NE 'MM') THEN BEGIN
    IF (cf[0] NE 'AS') THEN BEGIN
      ;;  Limit kappa or self-similar exponent accordingly
      IF (def_pinf[05].LIMITED[0]) THEN pcore[5]  = pcore[5] > def_pinf[05].LIMITS[0]
      IF (def_pinf[05].LIMITED[1]) THEN pcore[5]  = pcore[5] < def_pinf[05].LIMITS[1]
    ENDIF ELSE BEGIN
      ;;  Limit asymmetric self-similar exponents accordingly
      IF (def_pinf[04].LIMITED[0]) THEN pcore[4]  = pcore[4] > def_pinf[04].LIMITS[0]
      IF (def_pinf[04].LIMITED[1]) THEN pcore[4]  = pcore[4] < def_pinf[04].LIMITS[1]
      IF (def_pinf[05].LIMITED[0]) THEN pcore[5]  = pcore[5] > def_pinf[05].LIMITS[0]
      IF (def_pinf[05].LIMITED[1]) THEN pcore[5]  = pcore[5] < def_pinf[05].LIMITS[1]
    ENDELSE
  ENDIF
ENDIF ELSE BEGIN
  ;;  Use defaults for core
  pcore        = def_param[0L:5L]
ENDELSE
;;------------------------------
;;  Check HALOP
;;------------------------------
test                    = (N_ELEMENTS(halop) EQ 6) AND is_a_number(halop,/NOMSSG)
IF (test[0]) THEN BEGIN
  phalo        = DOUBLE(halop)
  ;;  Adjust parameters by velocity factor
  IF (hf[0] NE 'AS') THEN phalo[01:04] *= vfac[0] ELSE phalo[01:03] *= vfac[0]
  ;;  Check limits [*** Required to avoid conflicts in MPFIT.PRO ***]
  IF (def_hinf[00].LIMITED[0]) THEN phalo[0]  = phalo[0] > def_hinf[00].LIMITS[0]
  IF (def_hinf[00].LIMITED[1]) THEN phalo[0]  = phalo[0] < def_hinf[00].LIMITS[1]
  IF (def_hinf[01].LIMITED[0]) THEN phalo[1]  = phalo[1] > def_hinf[01].LIMITS[0]
  IF (def_hinf[01].LIMITED[1]) THEN phalo[1]  = phalo[1] < def_hinf[01].LIMITS[1]
  IF (def_hinf[01].LIMITED[0]) THEN phalo[2]  = phalo[2] > def_hinf[01].LIMITS[0]
  IF (def_hinf[01].LIMITED[1]) THEN phalo[2]  = phalo[2] < def_hinf[01].LIMITS[1]
  IF (def_hinf[03].LIMITED[0]) THEN phalo[3]  = phalo[3] > def_hinf[03].LIMITS[0]
  IF (def_hinf[03].LIMITED[1]) THEN phalo[3]  = phalo[3] < def_hinf[03].LIMITS[1]
  IF (def_hinf[04].LIMITED[0]) THEN phalo[4]  = phalo[4] > def_hinf[04].LIMITS[0]
  IF (def_hinf[04].LIMITED[1]) THEN phalo[4]  = phalo[4] < def_hinf[04].LIMITS[1]
  IF (hf[0] NE 'MM') THEN BEGIN
    IF (hf[0] NE 'AS') THEN BEGIN
      ;;  Limit kappa or self-similar exponent accordingly
      IF (def_hinf[05].LIMITED[0]) THEN phalo[5]  = phalo[5] > def_hinf[05].LIMITS[0]
      IF (def_hinf[05].LIMITED[1]) THEN phalo[5]  = phalo[5] < def_hinf[05].LIMITS[1]
    ENDIF ELSE BEGIN
      ;;  Limit asymmetric self-similar exponents accordingly
      IF (def_hinf[04].LIMITED[0]) THEN phalo[4]  = phalo[4] > def_hinf[04].LIMITS[0]
      IF (def_hinf[04].LIMITED[1]) THEN phalo[4]  = phalo[4] < def_hinf[04].LIMITS[1]
      IF (def_hinf[05].LIMITED[0]) THEN phalo[5]  = phalo[5] > def_hinf[05].LIMITS[0]
      IF (def_hinf[05].LIMITED[1]) THEN phalo[5]  = phalo[5] < def_hinf[05].LIMITS[1]
    ENDELSE
  ENDIF
ENDIF ELSE BEGIN
  ;;  Use defaults for halo
  phalo        = def_haram[0L:5L]
ENDELSE
;;------------------------------
;;  Check BEAMP
;;------------------------------
test                    = (N_ELEMENTS(beamp) EQ 6) AND is_a_number(beamp,/NOMSSG)
IF (test[0]) THEN BEGIN
  pbeam        = DOUBLE(beamp)
  ;;  Adjust parameters by velocity factor
  IF (bf[0] NE 'AS') THEN pbeam[01:04] *= vfac[0] ELSE pbeam[01:03] *= vfac[0]
  ;;  Check limits [*** Required to avoid conflicts in MPFIT.PRO ***]
  IF (def_binf[00].LIMITED[0]) THEN pbeam[0]  = pbeam[0] > def_binf[00].LIMITS[0]
  IF (def_binf[00].LIMITED[1]) THEN pbeam[0]  = pbeam[0] < def_binf[00].LIMITS[1]
  IF (def_binf[01].LIMITED[0]) THEN pbeam[1]  = pbeam[1] > def_binf[01].LIMITS[0]
  IF (def_binf[01].LIMITED[1]) THEN pbeam[1]  = pbeam[1] < def_binf[01].LIMITS[1]
  IF (def_binf[01].LIMITED[0]) THEN pbeam[2]  = pbeam[2] > def_binf[02].LIMITS[0]
  IF (def_binf[01].LIMITED[1]) THEN pbeam[2]  = pbeam[2] < def_binf[02].LIMITS[1]
  IF (def_binf[03].LIMITED[0]) THEN pbeam[3]  = pbeam[3] > def_binf[03].LIMITS[0]
  IF (def_binf[03].LIMITED[1]) THEN pbeam[3]  = pbeam[3] < def_binf[03].LIMITS[1]
  IF (def_binf[04].LIMITED[0]) THEN pbeam[4]  = pbeam[4] > def_binf[04].LIMITS[0]
  IF (def_binf[04].LIMITED[1]) THEN pbeam[4]  = pbeam[4] < def_binf[04].LIMITS[1]
  IF (bf[0] NE 'MM') THEN BEGIN
    IF (bf[0] NE 'AS') THEN BEGIN
      ;;  Limit kappa or self-similar exponent accordingly
      IF (def_binf[05].LIMITED[0]) THEN pbeam[5]  = pbeam[5] > def_binf[05].LIMITS[0]
      IF (def_binf[05].LIMITED[1]) THEN pbeam[5]  = pbeam[5] < def_binf[05].LIMITS[1]
    ENDIF ELSE BEGIN
      ;;  Limit asymmetric self-similar exponents accordingly
      IF (def_binf[04].LIMITED[0]) THEN pbeam[4]  = pbeam[4] > def_binf[04].LIMITS[0]
      IF (def_binf[04].LIMITED[1]) THEN pbeam[4]  = pbeam[4] < def_binf[04].LIMITS[1]
      IF (def_binf[05].LIMITED[0]) THEN pbeam[5]  = pbeam[5] > def_binf[05].LIMITS[0]
      IF (def_binf[05].LIMITED[1]) THEN pbeam[5]  = pbeam[5] < def_binf[05].LIMITS[1]
    ENDELSE
  ENDIF
ENDIF ELSE BEGIN
  ;;  Use defaults for beam
  pbeam        = def_baram[0L:5L]
  ;;  Define beam PARINFO structure
  def_binf     = def_binf
ENDELSE
;;------------------------------
;;  Check V1ISB
;;------------------------------
test                    = (N_ELEMENTS(v1isb) EQ 1) AND is_a_number(v1isb,/NOMSSG)
IF (test[0]) THEN test = (ABS(v1isb[0]) GT 0)
IF (test[0]) THEN test = is_a_3_vector(vec1,V_OUT=vv1,/NOMSSG) ELSE vv1 = REPLICATE(d,3)
IF (test[0]) THEN BEGIN
  sb       = sign(v1isb[0])
  uv_st    = REFORM(sb[0]*unit_vec(vv1))
  v1isb_on = (TOTAL(FINITE(uv_st)) EQ 3)
ENDIF ELSE BEGIN
  v1isb_on = 0b
  uv_st    = REPLICATE(d,3)
ENDELSE
;;------------------------------
;;  Check RMSTRAHL
;;------------------------------
IF (v1isb_on[0]) THEN BEGIN
  ;;  Set --> define default
  strahl_str   = def_rmstrahl[0]
  str_element,strahl_str,tags[0],uv_st,/ADD_REPLACE
  rm_strahl_on = 1b
ENDIF ELSE BEGIN
  ;;  Not on --> do not remove anything
  rm_strahl_on = 0b
ENDELSE
;;------------------------------
;;  Check EMIN_[C,H,B]
;;------------------------------
test                    = (N_ELEMENTS(emin_c) GT 0) AND is_a_number(emin_c,/NOMSSG)
IF (test[0]) THEN c__emin = 1d0*ABS(emin_c[0]) ELSE c__emin = 0d0
test                    = (N_ELEMENTS(emin_h) GT 0) AND is_a_number(emin_h,/NOMSSG)
IF (test[0]) THEN h__emin = 1d0*ABS(emin_h[0]) ELSE h__emin = 0d0
test                    = (N_ELEMENTS(emin_b) GT 0) AND is_a_number(emin_b,/NOMSSG)
IF (test[0]) THEN b__emin = 1d0*ABS(emin_b[0]) ELSE b__emin = 0d0
;;------------------------------
;;  Check EMAX_[C,H,B]
;;------------------------------
test                    = (N_ELEMENTS(emax_c) GT 0) AND is_a_number(emax_c,/NOMSSG)
IF (test[0]) THEN c__emax = 1d0*ABS(emax_c[0]) ELSE c__emax = 1d30
test                    = (N_ELEMENTS(emax_h) GT 0) AND is_a_number(emax_h,/NOMSSG)
IF (test[0]) THEN h__emax = 1d0*ABS(emax_h[0]) ELSE h__emax = 1d30
test                    = (N_ELEMENTS(emax_b) GT 0) AND is_a_number(emax_b,/NOMSSG)
IF (test[0]) THEN b__emax = 1d0*ABS(emax_b[0]) ELSE b__emax = 1d30
;;------------------------------
;;  Check USE1C4WGHT
;;------------------------------
test           = (N_ELEMENTS(use1c4wght) GT 0) AND KEYWORD_SET(use1c4wght)
IF (test[0]) THEN use1c4w_on = 1b ELSE use1c4w_on = 0b
;;------------------------------
;;  Check NO_WGHT
;;------------------------------
test           = (N_ELEMENTS(no_wght) GT 0) AND KEYWORD_SET(no_wght)
IF (test[0]) THEN use_nowght_on = 1b ELSE use_nowght_on = 0b
;;------------------------------
;;  Check POISSON
;;------------------------------
test           = (N_ELEMENTS(poisson) GT 0) AND is_a_number(poisson,/NOMSSG)
IF (test[0]) THEN BEGIN
  poisson_on     = (N_ELEMENTS(poisson) EQ nn_f[0])
ENDIF ELSE BEGIN
  poisson_on     = 0b
ENDELSE
;;  Make sure only one weighting scheme is used
;;    Priority:  1 = Poisson, 2 = one-count, 3 = no weights, 4 = default
good_wts                = WHERE([use1c4w_on[0],use_nowght_on[0],poisson_on[0],1b],gd_wts)
CASE gd_wts[0] OF
  1    :  BEGIN
    ;;  No priority set --> use 10% of data
    tenperc_on    = 1b
    use1c4w_on    = 0b
    use_nowght_on = 0b
    poisson_on    = 0b
  END
  2    :  BEGIN
    ;;  At least one user-defined weighting scheme is set
    IF (good_wts[0] EQ 2) THEN BEGIN
      ;;  Use Poisson
      poisson_on    = 1b
      use_nowght_on = 0b
      use1c4w_on    = 0b
      tenperc_on    = 0b
    ENDIF ELSE BEGIN
      ;;  Check other two options
      IF (good_wts[0] EQ 1) THEN BEGIN
        ;;  No weighting
        poisson_on    = 0b
        use_nowght_on = 1b
        use1c4w_on    = 0b
        tenperc_on    = 0b
      ENDIF ELSE BEGIN
        ;;  Use one-count for errors
        poisson_on    = 0b
        use_nowght_on = 0b
        use1c4w_on    = 1b
        tenperc_on    = 0b
      ENDELSE
    ENDELSE
  END
  3    :  BEGIN
    ;;  At least two user-defined weighting schemes are set
    IF (good_wts[0] EQ 1) THEN BEGIN
      ;;  Give priority to Poisson
      poisson_on    = 1b
      use_nowght_on = 0b
      use1c4w_on    = 0b
      tenperc_on    = 0b
    ENDIF ELSE BEGIN
      ;;  Set Priority
      IF (good_wts[1] EQ 2) THEN BEGIN
        ;;  Give priority to Poisson
        poisson_on    = 1b
        use_nowght_on = 0b
        use1c4w_on    = 0b
        tenperc_on    = 0b
      ENDIF ELSE BEGIN
        ;;  Give priority to one-count
        poisson_on    = 0b
        use_nowght_on = 0b
        use1c4w_on    = 1b
        tenperc_on    = 0b
      ENDELSE
    ENDELSE
  END
  4    :  BEGIN
    ;;  At least three user-defined weighting schemes are set
    ;;    --> priority goes to Poisson
    poisson_on    = 1b
    use_nowght_on = 0b
    use1c4w_on    = 0b
    tenperc_on    = 0b
  END
  ELSE :  STOP  ;;  Should not be possible --> debug
ENDCASE
;;  Check CORE_THRSH
test                    = (N_ELEMENTS(core_thrsh) GE 1) AND is_a_number(core_thrsh,/NOMSSG)
IF (test[0]) THEN test = (ABS(core_thrsh[0]) LT 5d-1)
IF (test[0]) THEN cthrsh = ABS(core_thrsh[0]) ELSE cthrsh = 1d-2
;;----------------------------------------------------------------------------------------
;;  Plot 2D contour of VDF and return data
;;----------------------------------------------------------------------------------------
WSET,wind_ns[0]
WSHOW,wind_ns[0]
;;  Check if user wishes to ignore the strahl component
IF (rm_strahl_on[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Check if we need to alter PARINFO limits
  ;;--------------------------------------------------------------------------------------
  test                    = is_a_3_vector(vec1,V_OUT=vv1,/NOMSSG)
  IF (test[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  VEC1 is set --> determine side to ignore
    ;;------------------------------------------------------------------------------------
    uv_1                    = REFORM(unit_vec(vv1))
    uvst                    = REFORM(unit_vec(uv_st))
    v1_dot_uvst             = TOTAL(uv_1*uvst,/NAN)
    para_bo                 = (v1_dot_uvst[0] GE 0)
    ;;  Check if user is trying to override the default functionality
    test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=voacorern,  $
                                              DEF_RAN=def_v_oc_lim,LIMS_OUT=lims_v_oca,$
                                              LIMD_OUT=limd_v_oca,RKEY_ON=v_oca_on)
    IF (para_bo[0]) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  strahl is parallel to Bo
      ;;----------------------------------------------------------------------------------
      IF (~v_oca_on[0]) THEN BEGIN
        pcore[3]                = pcore[3] < 0
        def_pinf[3].LIMITS[1]   = def_pinf[3].LIMITS[1] < 0
      ENDIF
      phalo[3]                = phalo[3] < 0
      def_hinf[3].LIMITS[1]   = def_hinf[3].LIMITS[1] < 0
      ;;  Alter beam limits structure
      pbeam[3]                = pbeam[3] > 0
      def_binf[3].LIMITS[0]   = def_binf[3].LIMITS[0] > 0
      ;;  Check LIMITS
      test                    = (def_pinf[3].LIMITS[0] GT def_pinf[3].LIMITS[1]) AND def_pinf[3].LIMITED[1]
      IF (test[0]) THEN def_pinf[3].LIMITS[1] = -10*ABS(def_pinf[3].LIMITS[0])
      test                    = (def_hinf[3].LIMITS[0] GT def_hinf[3].LIMITS[1]) AND def_hinf[3].LIMITED[1]
      IF (test[0]) THEN def_hinf[3].LIMITS[1] = -10*ABS(def_hinf[3].LIMITS[0])
      test                    = (def_binf[3].LIMITS[0] GT def_binf[3].LIMITS[1]) AND def_binf[3].LIMITED[1]
      IF (test[0]) THEN BEGIN
        ;;  Adjust and sort
        def_binf[3].LIMITS[1] = 10*def_binf[3].LIMITS[0]
        temp                  = def_binf[3].LIMITS
        sp                    = SORT(temp)
        def_binf[3].LIMITS    = temp[sp]
        temp                  = def_binf[3].LIMITED
        def_binf[3].LIMITED   = temp[sp]
      ENDIF
    ENDIF ELSE BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  strahl is anti-parallel to Bo
      ;;----------------------------------------------------------------------------------
      IF (~v_oca_on[0]) THEN BEGIN
        pcore[3]                = pcore[3] > 0
        def_pinf[3].LIMITS[0]   = def_pinf[3].LIMITS[0] > 0
      ENDIF
      phalo[3]                = phalo[3] > 0
      def_hinf[3].LIMITS[0]   = def_hinf[3].LIMITS[0] > 0
      ;;  Alter beam limits structure
      pbeam[3]                = pbeam[3] < 0
      def_binf[3].LIMITS[1]   = def_binf[3].LIMITS[1] < 0
      ;;  Check LIMITS
      test                    = (def_pinf[3].LIMITS[0] GT def_pinf[3].LIMITS[1]) AND def_pinf[3].LIMITED[1]
      IF (test[0]) THEN def_pinf[3].LIMITS[1] = 10*def_pinf[3].LIMITS[0]
      test                    = (def_hinf[3].LIMITS[0] GT def_hinf[3].LIMITS[1]) AND def_hinf[3].LIMITED[1]
      IF (test[0]) THEN def_hinf[3].LIMITS[1] = 10*def_hinf[3].LIMITS[0]
      test                    = (def_binf[3].LIMITS[0] GT def_binf[3].LIMITS[1]) AND def_binf[3].LIMITED[1]
      IF (test[0]) THEN BEGIN
        ;;  Adjust and sort
        def_binf[3].LIMITS[1] = -10*ABS(def_binf[3].LIMITS[0])
        temp                  = def_binf[3].LIMITS
        sp                    = SORT(temp)
        def_binf[3].LIMITS    = temp[sp]
        temp                  = def_binf[3].LIMITED
        def_binf[3].LIMITED   = temp[sp]
      ENDIF
    ENDELSE
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  VEC1 is not set --> do not ignore either side
    ;;------------------------------------------------------------------------------------
    para_bo                 = -1
    IF (hf[0] NE 'AS') THEN def_hinf[03:04].LIMITED = 0b ELSE def_hinf[03].LIMITED = 0b       ;;  Shutoff drift velocity limits
    IF (bf[0] NE 'AS') THEN def_binf[03:04].LIMITED = 0b ELSE def_binf[03].LIMITED = 0b       ;;  Shutoff drift velocity limits
  ENDELSE
  ;;  Plot VDF
;  IF (cf[0] NE 'AS') THEN pcore0 = pcore/pfar ELSE pcore0 = pcore/pfar1
;  IF (hf[0] NE 'AS') THEN phalo0 = phalo/pfar ELSE phalo0 = phalo/pfar1
  pcore0       = pcore
  phalo0       = phalo
  pcore0[1:2]  = vthfac[0]*SQRT(pcore0[1:2])
  phalo0[1:2]  = vthfac[0]*SQRT(phalo0[1:2])
  general_vdf_contour_plot,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,_EXTRA=extrakey,  $
                           BIMAX=pcore0,BIKAP=phalo0,DAT_OUT=dat_out
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  VEC1 is not set --> do not ignore either side
  ;;--------------------------------------------------------------------------------------
  para_bo                 = -1
  IF (hf[0] NE 'AS') THEN def_hinf[03:04].LIMITED = 0b ELSE def_hinf[03].LIMITED = 0b        ;;  Shutoff drift velocity limits
  IF (bf[0] NE 'AS') THEN def_binf[03:04].LIMITED = 0b ELSE def_binf[03].LIMITED = 0b        ;;  Shutoff drift velocity limits
  ;;  Call normally without excluding any data
;  IF (cf[0] NE 'AS') THEN pcore0 = pcore/pfar ELSE pcore0 = pcore/pfar1
;  IF (hf[0] NE 'AS') THEN phalo0 = phalo/pfar ELSE phalo0 = phalo/pfar1
  pcore0       = pcore
  phalo0       = phalo
  pcore0[1:2]  = vthfac[0]*SQRT(pcore0[1:2])
  phalo0[1:2]  = vthfac[0]*SQRT(phalo0[1:2])
  general_vdf_contour_plot,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,_EXTRA=extrakey,  $
                           BIMAX=pcore0,BIKAP=phalo0,DAT_OUT=dat_out
ENDELSE
IF (SIZE(dat_out,/TYPE) NE 8) THEN BEGIN
  MESSAGE,'Failure at plot level output!',/INFORMATION,/CONTINUE
  RETURN        ;;  Failed to plot!!!
ENDIF
;;----------------------------------------------------------------------------------------
;;  Setup fit for VDFs
;;----------------------------------------------------------------------------------------
;;  Define gridded VDF parameters
vdf_2d                  = dat_out.CONT_DATA.VDF_2D          ;;  [# cm^(-3) km^(-3) s^(+3)]
vdf_2d                 *= ffac[0]                           ;;  km^(-3) --> Mm^(-3)
vpara                   = dat_out.CONT_DATA.VXGRID          ;;  [Mm/s]
vperp                   = dat_out.CONT_DATA.VXGRID          ;;  [Mm/s]
IF (vfac[0] LT 1d0) THEN BEGIN
  ;;  Use Mm
  vx_in                   = vpara
  vy_in                   = vperp
  vx_km                   = vpara/vfac[0]
  vy_km                   = vperp/vfac[0]
ENDIF ELSE BEGIN
  ;;  Use km
  vx_km                   = vpara*1d3
  vy_km                   = vperp*1d3
  vx_in                   = vx_km
  vy_in                   = vy_km
ENDELSE
good                    = WHERE(ABS(vdf_2d) GT 0,gd)
IF (gd[0] GT 0) THEN BEGIN
  ;;  Constant by which to offset data
  offset = 1d0/MIN(ABS(vdf_2d[good]),/NAN)
  medoff = 1d0/MEDIAN(ABS(vdf_2d[good]))
ENDIF ELSE BEGIN
  offset = d
  medoff = d
ENDELSE
n_vdf                   = N_ELEMENTS(vdf_2d)
n_par                   = N_ELEMENTS(vx_in)
n_per                   = N_ELEMENTS(vy_in)
;;  Check output so far
test                    = (FINITE(offset) EQ 0) OR (offset[0] LE 0) OR (n_vdf[0] LT 20)
IF (test[0]) THEN BEGIN
  MESSAGE,'Failure after plot level output [insufficient finite output]!',/INFORMATION,/CONTINUE
  RETURN        ;;  Failed to plot!!!
ENDIF
;;----------------------------------------------------------------------------------------
;;  Calculate energies corresponding to the regridded velocities
;;----------------------------------------------------------------------------------------
vpar2d                  = vx_km # REPLICATE(1d0,n_per[0])
vper2d                  = REPLICATE(1d0,n_par[0]) # vy_km
vel_2d                  = [[[vpar2d]],[[vper2d]]]             ;;  [N,M,2]-Element array
speed                   = SQRT(TOTAL(vel_2d^2,3,/NAN))        ;;  [N,M]-Element array of speeds [km/s]
;;  Convert to energies [eV]
eners                   = energy_to_vel(speed,ELECTRON=elec_on[0],PROTON=ion__on[0],/INVERSE)
good_e                  = WHERE(FINITE(eners) AND eners GT 0,gd_e)
IF (gd_e[0] EQ 0) THEN BEGIN
  MESSAGE,'Failure after energy calculations [insufficient finite output]!',/INFORMATION,/CONTINUE
  RETURN        ;;  Failed to fit!!!
ENDIF
ener_ran                = [MIN(eners[good_e],/NAN),MAX(eners[good_e],/NAN)]
;;----------------------------------------------------------------------------------------
;;  Get VDF for Poisson statistics if desired
;;----------------------------------------------------------------------------------------
IF (poisson_on[0]) THEN BEGIN
  general_vdf_contour_plot,poisson,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,_EXTRA=extrakey,  $
                           /GET_ROT,ROT_OUT=rot_out
  IF (SIZE(rot_out,/TYPE) EQ 8) THEN BEGIN
    ;;  Currently only allows XY-Plane --> get structure variables
    poisson_2d    = rot_out.PLANE_XY.DF2D_XY          ;;  [# cm^(-3) km^(-3) s^(+3)]
    ;;  Shutoff other weighting options (in case user has them on)
    use1c4w_on    = 0b
    use_nowght_on = 0b
    poisson_on    = 1b
    poisson_2ds   = SMOOTH(poisson_2d,3,/NAN,/EDGE_TRUNCATE,/EDGE_ZERO,MISSING=f)
    poisson_2dc   = poisson_2ds
    poisson_2dh   = poisson_2ds
    poisson_2db   = poisson_2ds
    good          = WHERE(ABS(poisson_2d) GT 0,gd)
    IF (gd[0] GT 0) THEN poffst = 1d0/MIN(ABS(poisson_2d[good]),/NAN) ELSE poffst = 0d0
  ENDIF ELSE BEGIN
    ;;  Something failed --> shutoff Poisson setting
    poisson_on    = 0b
  ENDELSE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Ignore some data for fitting
;;----------------------------------------------------------------------------------------
vdf_2ds                 = SMOOTH(vdf_2d,3,/NAN,/EDGE_TRUNCATE,/EDGE_ZERO,MISSING=d)
vdf_2dc                 = vdf_2ds               ;;  Data for core
vdf_2dh                 = vdf_2ds               ;;  Data for halo
vdf_2db                 = vdf_2ds               ;;  Data for beam
IF (use1c4w_on[0]) THEN BEGIN
  ;;  Use one-count for errors/weights
  onec_2dc = SMOOTH(dat_out.ONE_CUT.VDF_2D,3,/NAN,/EDGE_TRUNCATE,/EDGE_ZERO,MISSING=f)*ffac[0]
  onec_2dh = onec_2dc                           ;;  One-count for halo
  onec_2db = onec_2dc                           ;;  One-count for beam
ENDIF ELSE BEGIN
  onec_2dc = 0*vdf_2d
  onec_2dh = onec_2dc
  onec_2db = onec_2dc
ENDELSE
IF (rm_strahl_on[0]) THEN BEGIN
  ;;  Yes, ignore side with strahl/beam
  IF (para_bo[0] GE 0) THEN BEGIN
    IF (para_bo[0]) THEN BEGIN
      ;;  strahl is parallel to Bo
      s_low  = (n_par[0]/2L + 3L)
      s_upp  = (n_par[0] - 1L)
      b_low  = 0L
      b_upp  = (n_par[0]/2L + 3L) - 1L
    ENDIF ELSE BEGIN
      ;;  strahl is anti-parallel to Bo
      s_low  = 0L
      s_upp  = (n_par[0]/2L + 3L) - 1L
      b_low  = (n_par[0]/2L + 3L)
      b_upp  = (n_par[0] - 1L)
    ENDELSE
    ;;  Define bad index range
    s_ind  = fill_range(s_low[0],s_upp[0],DIND=1L)
    b_ind  = fill_range(b_low[0],b_upp[0],DIND=1L)
    ;;  Kill data in bad range
    vdf_2dh[s_ind,*] = f
    vdf_2db[b_ind,*] = f
    IF (use1c4w_on[0]) THEN BEGIN
      onec_2dh[s_ind,*] = f
      onec_2db[b_ind,*] = f
    ENDIF
    IF (poisson_on[0]) THEN BEGIN
      poisson_2dh[s_ind,*] = f
      poisson_2db[b_ind,*] = f
    ENDIF
  ENDIF
ENDIF
;;  Keep data ≥ 1% of max VDF phase space density
vdfc_max                = MAX(ABS(vdf_2dc),/NAN)
test_core               = (vdf_2dc GE cthrsh[0]*vdfc_max[0])
good_core               = WHERE(test_core,gd_core,COMPLEMENT=bad_core,NCOMPLEMENT=bd_core)
IF (bd_core[0] GT 0) THEN vdf_2dc[bad_core] = f
vdf_2dc0                = vdf_2dc
IF (gd_core[0] GT 0) THEN BEGIN
  ;;  Remove data from halo and beam arrays
  vdf_2dh[good_core]     = f
  vdf_2db[good_core]     = f
  poisson_2dh[good_core] = f
  poisson_2db[good_core] = f
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define error and weights
;;----------------------------------------------------------------------------------------
;;  Define error as 1% of data
log10_vdf_2dp           = ALOG10(vdf_2dc)
;vdf_2dp                 = vdf_2dc
;vdf_2dp                *= offset[0]                             ;;  Force values to > 1.0
good_wts                = WHERE([use1c4w_on[0],use_nowght_on[0],poisson_on[0],tenperc_on[0]],gd_wts)
CASE good_wts[0] OF
  0    : BEGIN       ;;  one-count
;    zerrc                   = onec_2dc*offset[0]
;    zerrh                   = onec_2dh*offset[0]
;    zerrb                   = onec_2db*offset[0]
    zerrc                   = ALOG10(onec_2dc)
    zerrh                   = ALOG10(onec_2dh)
    zerrb                   = ALOG10(onec_2db)
    weightc                 = 1d0/zerrc                         ;;  Poisson weights of one-count
    weighth                 = 1d0/zerrh                         ;;  Poisson weights of one-count
    weightb                 = 1d0/zerrb                         ;;  Poisson weights of one-count
    bad_zerr                = -50d0
    wwc10                   = 1d0/onec_2dc
    wwh10                   = 1d0/onec_2dh
    wwb10                   = 1d0/onec_2db
  END
  1    : BEGIN       ;;  no weighting
    ;;  Use 10% of data for errors
;    zerrc                   = 1d-2*vdf_2dp
    zerrc                   = 1d-2*ABS(log10_vdf_2dp)
    zerrh                   = zerrc
    zerrb                   = zerrc
    weightc                 = REPLICATE(1d0,n_par[0],n_per[0])
    weighth                 = weightc
    weightb                 = weightc
    bad_zerr                = -50d0
    wwc10                   = weightc
    wwh10                   = weighth
    wwb10                   = weightb
  END
  2    : BEGIN       ;;  Poisson
    ;;  Oddly, the use of Poisson counting statistics on input with Gaussian weights
    ;;   produces the best results
;    zerrc                   = poisson_2dc*poffst[0]
;    zerrh                   = poisson_2dh*poffst[0]
;    zerrb                   = poisson_2db*poffst[0]
    zerrc                   = ALOG10(poisson_2dc)
    zerrh                   = ALOG10(poisson_2dh)
    zerrb                   = ALOG10(poisson_2db)
    weightc                 = 1d0/zerrc^2d0
    weighth                 = 1d0/zerrh^2d0
    weightb                 = 1d0/zerrb^2d0
    bad_zerr                = -50d0
    ;;  Define base-10 weight equivalents
    wwc10                   = 1d0/poisson_2dc^2d0
    wwh10                   = 1d0/poisson_2dh^2d0
    wwb10                   = 1d0/poisson_2db^2d0
  END
  3    : BEGIN       ;;  10% of data
;    zerrc                   = 1d-2*vdf_2dp
    zerrc                   = 1d-2*log10_vdf_2dp
    zerrh                   = zerrc
    zerrb                   = zerrc
    weightc                 = 1d0/zerrc^2d0
    weighth                 = 1d0/zerrh^2d0
    weightb                 = 1d0/zerrb^2d0
    bad_zerr                = -50d0
    wwc10                   = 1d0/(1d-2*vdf_2dp)^2d0
    wwh10                   = wwc10
    wwb10                   = wwc10
  END
  ELSE : STOP        ;;  Should not be possible --> debug
ENDCASE
;;  Remove negatives and zeros
test                    = (FINITE(vdf_2dc) EQ 0) OR (vdf_2dc LE 0) OR   $
                          (FINITE(zerrc) EQ 0) OR (ABS(zerrc) LE 0) OR  $
                          (FINITE(weightc) EQ 0) OR (weightc LE 0)
bad                     = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
test                    = (1d0*bd[0] GT 98d-2*n_vdf[0])
IF (test[0]) THEN BEGIN
  ;;  Too many "bad" data points --> Failure!
  MESSAGE,'Failure (Core):  Too many bad data points!',/INFORMATION,/CONTINUE
  GOTO,JUMP_QUIT
ENDIF ELSE BEGIN
  IF (bd[0] GT 0) THEN BEGIN
    ;;  Success!
    vdf_2dc[bad]            = 0d0
    zerrc[bad]              = bad_zerr[0] ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
    weightc[bad]            = 0d0         ;;  Zero for weights will result in ignoring those points
    wwc10[bad]              = 0d0
;    wwh10[bad]              = 0d0
;    wwb10[bad]              = 0d0
  ENDIF ELSE BEGIN
    ;;  All "good" data points --> Success!
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check if user wants to exclude data below EMIN_[C,H,B]
;;----------------------------------------------------------------------------------------
IF (c__emin[0] GT 0) THEN BEGIN
  ;;  Exclude data below EMIN_C
  bad2c                   = WHERE(eners LE c__emin[0],bd2c)
  IF (bd2c[0] GT 0) THEN BEGIN
    ;;  Zero-out values of weights to tell MPFIT to ignore those points
    weightc[bad2c]           = 0d0
    zerrc[bad2c]             = bad_zerr[0] ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
    wwc10[bad2c]             = 0d0
  ENDIF
ENDIF
IF (h__emin[0] GT 0) THEN BEGIN
  ;;  Exclude data below EMIN_H
  bad2h                   = WHERE(eners LE h__emin[0],bd2h)
  IF (bd2h[0] GT 0) THEN BEGIN
    ;;  Zero-out values of weights to tell MPFIT to ignore those points
    weighth[bad2h]           = 0d0
    zerrh[bad2h]             = bad_zerr[0] ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
    wwh10[bad2h]             = 0d0
  ENDIF
ENDIF
IF (b__emin[0] GT 0) THEN BEGIN
  ;;  Exclude data below EMIN_B
  bad2b                   = WHERE(eners LE b__emin[0],bd2b)
  IF (bd2b[0] GT 0) THEN BEGIN
    ;;  Zero-out values of weights to tell MPFIT to ignore those points
    weightb[bad2b]           = 0d0
    zerrb[bad2b]             = bad_zerr[0] ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
    wwb10[bad2b]             = 0d0
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check if user wants to exclude data above EMAX_[C,H,B]
;;----------------------------------------------------------------------------------------
IF (c__emax[0] LT 1d30) THEN BEGIN
  ;;  Exclude data above EMAX_C
  bad3c                   = WHERE(eners GE c__emax[0],bd3c)
  IF (bd3c[0] GT 0) THEN BEGIN
    ;;  Zero-out values of weights to tell MPFIT to ignore those points
    weightc[bad3c]           = 0d0
    zerrc[bad3c]             = bad_zerr[0] ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
    wwc10[bad3c]             = 0d0
  ENDIF
ENDIF
IF (h__emax[0] LT 1d30) THEN BEGIN
  ;;  Exclude data above EMAX_H
  bad3h                   = WHERE(eners GE h__emax[0],bd3h)
  IF (bd3h[0] GT 0) THEN BEGIN
    ;;  Zero-out values of weights to tell MPFIT to ignore those points
    weighth[bad3h]           = 0d0
    zerrh[bad3h]             = bad_zerr[0] ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
    wwh10[bad3h]             = 0d0
  ENDIF
ENDIF
IF (b__emax[0] LT 1d30) THEN BEGIN
  ;;  Exclude data above EMAX_B
  bad3b                   = WHERE(eners GE b__emax[0],bd3b)
  IF (bd3b[0] GT 0) THEN BEGIN
    ;;  Zero-out values of weights to tell MPFIT to ignore those points
    weightb[bad3b]           = 0d0
    zerrb[bad3b]             = bad_zerr[0] ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
    wwb10[bad3b]             = 0d0
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Fit to model 2D function to core
;;----------------------------------------------------------------------------------------
;;  Define input fit parameters
caram                   = pcore
haram                   = phalo
;;  Define PARINFO structure
c_pinfo                 = def_pinf
h_pinfo                 = def_hinf
b_pinfo                 = def_binf
c_pinfo.VALUE           = caram
h_pinfo.VALUE           = haram
b_pinfo.VALUE           = pbeam                                             ;;  Redefine parameters
;;  Define xyz inputs
x                       = vx_in
y                       = vy_in
z                       = ALOG10(vdf_2dc)
goodz                   = WHERE(FINITE(z) AND z LT 0,gdz,COMPLEMENT=badz,NCOMPLEMENT=bdz)
IF (bdz[0] GT 0) THEN z[badz] = -290d0
func                    = cfun[0]
;;  Debug for now
log10_c_fit             = mpfit2dfun(func[0],x,y,z,zerrc,pcore,PARINFO=c_pinfo,PERROR=f_sigc,      $
                                     BESTNORM=log10_chisqc,DOF=dofc,STATUS=statc,NITER=iterc,      $
                                     YFIT=log10_corefit_out,QUIET=1,WEIGHTS=weightc,NAN=nan_on[0], $
                                     FTOL=ftol,GTOL=gtol,XTOL=xtol,ERRMSG=errmsg,                  $
                                     BEST_RESID=log10_zerrorc,PFREE_INDEX=cfree_ind,               $
                                     NPEGGED=cpegged,MAXITER=maxiter)
IF (statc[0] LE 0) THEN GOTO,JUMP_QUIT
;c_pinfo[*].MPSIDE       = 3
;c_pinfo[*].MPDERIV_DEBUG = 1
;log10_c_fit             = mpfit2dfun(func[0],x,y,z,zerrc,pcore,PARINFO=c_pinfo,PERROR=f_sigc,      $
;                                     BESTNORM=chisqc,DOF=dofc,STATUS=statc,NITER=iterc,            $
;                                     YFIT=log10_corefit_out,QUIET=0,WEIGHTS=weightc,NAN=nan_on[0], $
;                                     FTOL=ftol,GTOL=gtol,XTOL=xtol,ERRMSG=errmsg,                  $
;                                     BEST_RESID=log10_zerrorc,PFREE_INDEX=cfree_ind,               $
;                                     NPEGGED=cpegged,MAXITER=maxiter,AUTODERIVATIVE=0)
;;----------------------------------------------------------------------------------------
;;   Result      :  best fit parameter results
;;   PERROR      :  1-sigma uncertainties in fit results
;;   YFIT        :  best fit of model function for fit parameter output
;;   BEST_RESID  :  array of best fit deviates normalized by weights or errors
;;                  = (Y - F(X)) / ERR
;;   BESTNORM    :  chi-squared value
;;   PCERROR     :  scaled 1-sigma uncertainties
;;                  = PERROR * SQRT(BESTNORM / DOF) 
;;----------------------------------------------------------------------------------------
;;   STATUS : 
;;             > 0 = success
;;             -18 = a fatal execution error has occurred.  More information may be
;;                   available in the ERRMSG string.
;;             -16 = a parameter or function value has become infinite or an undefined
;;                   number.  This is usually a consequence of numerical overflow in the
;;                   user's model function, which must be avoided.
;;             -15 to -1 = 
;;                   these are error codes that either MYFUNCT or ITERPROC may return to
;;                   terminate the fitting process (see description of MPFIT_ERROR
;;                   common below).  If either MYFUNCT or ITERPROC set ERROR_CODE to a
;;                   negative number, then that number is returned in STATUS.  Values
;;                   from -15 to -1 are reserved for the user functions and will not
;;                   clash with MPFIT.
;;             0 = improper input parameters.
;;             1 = both actual and predicted relative reductions in the sum of squares
;;                   are at most FTOL.
;;             2 = relative error between two consecutive iterates is at most XTOL
;;             3 = conditions for STATUS = 1 and STATUS = 2 both hold.
;;             4 = the cosine of the angle between fvec and any column of the jacobian
;;                   is at most GTOL in absolute value.
;;             5 = the maximum number of iterations has been reached
;;                   (may indicate failure to converge)
;;             6 = FTOL is too small. no further reduction in the sum of squares is
;;                   possible.
;;             7 = XTOL is too small. no further improvement in the approximate
;;                   solution x is possible.
;;             8 = GTOL is too small. fvec is orthogonal to the columns of the
;;                   jacobian to machine precision.
;;----------------------------------------------------------------------------------------
;;  Re-base/Re-compute the output
c_fit                   = log10_c_fit
corefit_out             = 1d1^(log10_corefit_out)
zerrc_b10               = 1d1^(zerrc)
chisqc                  = TOTAL((1d1^(z) - corefit_out)^2d0*ABS(wwc10),/NAN)
zerrorc                 = (1d1^(z) - corefit_out)/zerrc_b10
;zerrorc                 = 1d1^(log10_zerrorc)
;;----------------------------------------------------------------------------------------
;;  Fit to model 2D function to halo
;;----------------------------------------------------------------------------------------
;;  Define residual between model core and data
residualh               = lbw_diff(vdf_2dh,corefit_out,/NAN) > 0             ;;  Force values to > 1.0
;;  Remove negatives and zeros
test                    = (FINITE(residualh) EQ 0) OR (residualh LE 0) OR $
                          (FINITE(zerrh) EQ 0) OR (ABS(zerrh) LE 0) OR    $
                          (FINITE(weighth) EQ 0) OR (weighth LE 0)
bad                     = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
test                    = (1d0*bd[0] GT 98d-2*n_vdf[0])
IF (test[0]) THEN BEGIN
  ;;  Too many "bad" data points --> Failure!
  MESSAGE,'Failure (Halo):  Too many bad data points!',/INFORMATION,/CONTINUE
  stath                     = -1
  GOTO,JUMP_QUIT
ENDIF ELSE BEGIN
  IF (bd[0] GT 0) THEN BEGIN
    ;;  Success!
    residualh[bad]          = 0d0
    zerrh[bad]              = bad_zerr[0] ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
    weighth[bad]            = 0d0         ;;  Zero for weights will result in ignoring those points
    wwh10[bad]              = 0d0
  ENDIF ELSE BEGIN
    ;;  All "good" data points --> Success!
  ENDELSE
ENDELSE
;;  Redefine input fit parameters, if necessary
phalo[0]                = phalo[0] < (35d-2*c_fit[0])
;;  Try to keep Nh < 30% of Nc
IF (h_pinfo[00].LIMITED[0]) THEN h_pinfo[00].LIMITS[0]  = (1d-2*phalo[0]) < (h_pinfo[00].LIMITS[0])
IF (h_pinfo[00].LIMITED[1]) THEN h_pinfo[00].LIMITS[1]  = (3d-1*c_fit[0]) < (h_pinfo[00].LIMITS[1])
;;  Define xyz inputs
x                       = vx_in
y                       = vy_in
z                       = ALOG10(residualh)
goodz                   = WHERE(FINITE(z) AND z LT 0,gdz,COMPLEMENT=badz,NCOMPLEMENT=bdz)
IF (bdz[0] GT 0) THEN z[badz] = -290d0
func                    = hfun[0]
log10_h_fit             = mpfit2dfun(func[0],x,y,z,zerrh,phalo,PARINFO=h_pinfo,PERROR=f_sigh,       $
                                     BESTNORM=log10_chisqh,DOF=dofh,STATUS=stath,NITER=iterh,       $
                                     YFIT=log10_halofit_out,QUIET=1,WEIGHTS=weighth,NAN=nan_on[0],  $
                                     FTOL=ftol,GTOL=gtol,XTOL=xtol,ERRMSG=errmsg,                   $
                                     BEST_RESID=log10_zerrorh,PFREE_INDEX=hfree_ind,                $
                                     NPEGGED=hpegged,MAXITER=maxiter                                )
IF (stath[0] LE 0) THEN GOTO,JUMP_QUIT
;;  Re-base/Re-compute the output
h_fit                   = log10_h_fit
halofit_out             = 1d1^(log10_halofit_out)
zerrh_b10               = 1d1^(zerrh)
chisqh                  = TOTAL((1d1^(z) - halofit_out)^2d0*ABS(wwh10),/NAN)
zerrorh                 = (1d1^(z) - halofit_out)/zerrh_b10
;zerrorh                 = 1d1^(log10_zerrorh)
;;----------------------------------------------------------------------------------------
;;  Fit to model 2D function to beam
;;----------------------------------------------------------------------------------------
IF (stath[0] LE 0) THEN ch_fit_out = corefit_out ELSE ch_fit_out = lbw__add(corefit_out,halofit_out,/NAN)
residualb               = lbw_diff(vdf_2db,ch_fit_out,/NAN) > 0             ;;  Force values to > 1.0
;;  Remove negatives and zeros
test                    = (FINITE(residualb) EQ 0) OR (residualb LE 0) OR $
                          (FINITE(zerrb) EQ 0) OR (ABS(zerrb) LE 0) OR    $
                          (FINITE(weightb) EQ 0) OR (weightb LE 0)
bad                     = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
test                    = (1d0*bd[0] GT 98d-2*n_vdf[0])
IF (test[0]) THEN BEGIN
  ;;  Too many "bad" data points --> Failure!
  MESSAGE,'Failure (Beam):  Too many bad data points!',/INFORMATION,/CONTINUE
  statb                     = -1
  GOTO,JUMP_QUIT
ENDIF ELSE BEGIN
  IF (bd[0] GT 0) THEN BEGIN
    ;;  Success!
    residualb[bad]          = 0d0
    zerrb[bad]              = bad_zerr[0] ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
    weightb[bad]            = 0d0         ;;  Zero for weights will result in ignoring those points
    wwb10[bad]              = 0d0
  ENDIF ELSE BEGIN
    ;;  All "good" data points --> Success!
  ENDELSE
ENDELSE
IF KEYWORD_SET(nb_lt_nh) THEN BEGIN
  ;;  Redefine input fit parameters, if necessary
  pbeam[0]                = pbeam[0] < (30d-2*h_fit[0])
  ;;  Try to keep Nb < Nh/2
  IF (b_pinfo[00].LIMITED[0]) THEN b_pinfo[00].LIMITS[0]  = (1d-2*pbeam[0]) < (b_pinfo[00].LIMITS[0])
  IF (b_pinfo[00].LIMITED[1]) THEN b_pinfo[00].LIMITS[1]  = (5d-1*h_fit[0]) < (b_pinfo[00].LIMITS[1])
ENDIF ELSE BEGIN
  ;;  Redefine input fit parameters, if necessary
  pbeam[0]                = pbeam[0] < (10d-2*c_fit[0])
  ;;  Try to keep Nb < 30% Nc
  IF (b_pinfo[00].LIMITED[0]) THEN b_pinfo[00].LIMITS[0]  = (1d-2*pbeam[0])  < (b_pinfo[00].LIMITS[0])
  IF (b_pinfo[00].LIMITED[1]) THEN b_pinfo[00].LIMITS[1]  = (30d-2*c_fit[0]) < (b_pinfo[00].LIMITS[1])
ENDELSE
;;  Define xyz inputs
x                       = vx_in
y                       = vy_in
z                       = ALOG10(residualb)
goodz                   = WHERE(FINITE(z) AND z LT 0,gdz,COMPLEMENT=badz,NCOMPLEMENT=bdz)
IF (bdz[0] GT 0) THEN z[badz] = -290d0
func                    = bfun[0]
log10_b_fit             = mpfit2dfun(func[0],x,y,z,zerrb,pbeam,PARINFO=b_pinfo,PERROR=f_sigb,       $
                                     BESTNORM=log10_chisqb,DOF=dofb,STATUS=statb,NITER=iterb,       $
                                     YFIT=log10_beamfit_out,QUIET=1,WEIGHTS=weightb,NAN=nan_on[0],  $
                                     FTOL=ftol,GTOL=gtol,XTOL=xtol,ERRMSG=errmsg,                   $
                                     BEST_RESID=log10_zerrorb,PFREE_INDEX=bfree_ind,                $
                                     NPEGGED=bpegged,MAXITER=maxiter                                )
IF (statb[0] LE 0) THEN GOTO,JUMP_QUIT
;;  Re-base/Re-compute the output
b_fit                   = log10_b_fit
beamfit_out             = 1d1^(log10_beamfit_out)
zerrb_b10               = 1d1^(zerrb)
chisqb                  = TOTAL((1d1^(z) - beamfit_out)^2d0*ABS(wwb10),/NAN)
zerrorb                 = (1d1^(z) - beamfit_out)/zerrb_b10
;IF (SIZE(log10_b_fit,/TYPE)       EQ 0) THEN b_fit        = REPLICATE(d,6) ELSE b_fit        = log10_b_fit
;IF (SIZE(log10_zerrorb,/TYPE)     EQ 0) THEN zerrorb      = dumb2d         ELSE zerrorb      = 1d1^(log10_zerrorb)
;IF (SIZE(log10_beamfit_out,/TYPE) EQ 0) THEN beamfit_out  = dumb2d         ELSE beamfit_out  = 1d1^(log10_beamfit_out)
;;========================================================================================
JUMP_QUIT:
;;========================================================================================
dumb2d                  = REPLICATE(d,n_par[0],n_per[0])
;;  Core Fit
IF (SIZE(statc,/TYPE)       EQ 0) THEN statc        = -1
IF (SIZE(corefit_out,/TYPE) EQ 0) THEN corefit_out  = dumb2d
IF (SIZE(c_fit,/TYPE)       EQ 0) THEN c_fit        = REPLICATE(d,6)
IF (SIZE(f_sigc,/TYPE)      EQ 0) THEN f_sigc       = REPLICATE(d,6)
IF (SIZE(weightc,/TYPE)     EQ 0) THEN weightc      = dumb2d
IF (SIZE(chisqc,/TYPE)      EQ 0) THEN chisqc       = d
IF (SIZE(dofc,/TYPE)        EQ 0) THEN dofc         = d
IF (SIZE(iterc,/TYPE)       EQ 0) THEN iterc        = -1
IF (SIZE(zerrorc,/TYPE)     EQ 0) THEN zerrorc      = dumb2d
IF (SIZE(c_pinfo,/TYPE)     EQ 0) THEN c_pinfo      = def_pinf
IF (SIZE(cfree_ind,/TYPE)   EQ 0) THEN cfree_ind    = -1
IF (SIZE(cpegged,/TYPE)     EQ 0) THEN cpegged      = -1
;;  Halo Fit
IF (SIZE(stath,/TYPE)       EQ 0) THEN stath        = -1
IF (SIZE(halofit_out,/TYPE) EQ 0) THEN halofit_out  = dumb2d
IF (SIZE(residualh,/TYPE)   EQ 0) THEN residualh    = dumb2d
IF (SIZE(h_fit,/TYPE)       EQ 0) THEN h_fit        = REPLICATE(d,6)
IF (SIZE(f_sigh,/TYPE)      EQ 0) THEN f_sigh       = REPLICATE(d,6)
IF (SIZE(weighth,/TYPE)     EQ 0) THEN weighth      = dumb2d
IF (SIZE(chisqh,/TYPE)      EQ 0) THEN chisqh       = d
IF (SIZE(dofh,/TYPE)        EQ 0) THEN dofh         = d
IF (SIZE(iterh,/TYPE)       EQ 0) THEN iterh        = -1
IF (SIZE(zerrorh,/TYPE)     EQ 0) THEN zerrorh      = dumb2d
IF (SIZE(h_pinfo,/TYPE)     EQ 0) THEN h_pinfo      = def_hinf
IF (SIZE(hfree_ind,/TYPE)   EQ 0) THEN hfree_ind    = -1
IF (SIZE(hpegged,/TYPE)     EQ 0) THEN hpegged      = -1
;;  Beam Fit
IF (SIZE(statb,/TYPE)       EQ 0) THEN statb        = -1
IF (SIZE(beamfit_out,/TYPE) EQ 0) THEN beamfit_out  = dumb2d
IF (SIZE(residualb,/TYPE)   EQ 0) THEN residualb    = dumb2d
IF (SIZE(b_fit,/TYPE)       EQ 0) THEN b_fit        = REPLICATE(d,6)
IF (SIZE(f_sigb,/TYPE)      EQ 0) THEN f_sigb       = REPLICATE(d,6)
IF (SIZE(weightb,/TYPE)     EQ 0) THEN weightb      = dumb2d
IF (SIZE(chisqb,/TYPE)      EQ 0) THEN chisqb       = d
IF (SIZE(dofb,/TYPE)        EQ 0) THEN dofb         = d
IF (SIZE(iterb,/TYPE)       EQ 0) THEN iterb        = -1
IF (SIZE(zerrorb,/TYPE)     EQ 0) THEN zerrorb      = dumb2d
IF (SIZE(b_pinfo,/TYPE)     EQ 0) THEN b_pinfo      = def_binf
IF (SIZE(bfree_ind,/TYPE)   EQ 0) THEN bfree_ind    = -1
IF (SIZE(bpegged,/TYPE)     EQ 0) THEN bpegged      = -1
;;  Convert fit results back to standard units
IF (cf[0] NE 'AS') THEN c_fit  /= pfar ELSE c_fit  /= pfar1
IF (hf[0] NE 'AS') THEN h_fit  /= pfar ELSE h_fit  /= pfar1
IF (bf[0] NE 'AS') THEN b_fit  /= pfar ELSE b_fit  /= pfar1
IF (cf[0] NE 'AS') THEN f_sigc /= pfar ELSE f_sigc /= pfar1
IF (hf[0] NE 'AS') THEN f_sigh /= pfar ELSE f_sigh /= pfar1
IF (bf[0] NE 'AS') THEN f_sigb /= pfar ELSE f_sigb /= pfar1
corefit_out            /= ffac[0]
halofit_out            /= ffac[0]
beamfit_out            /= ffac[0]
;;  Remove logarithm factor
CASE good_wts[0] OF
  0    : BEGIN       ;;  one-count
    wghtc                   = wwc10
    wghth                   = wwh10
    wghtb                   = wwb10
  END
  1    : BEGIN       ;;  no weighting
    wghtc                   = wwc10
    wghth                   = wwh10
    wghtb                   = wwb10
  END
  2    : BEGIN       ;;  Poisson
    wghtc                   = wwc10
    wghth                   = wwh10
    wghtb                   = wwb10
  END
  3    : BEGIN       ;;  10% of data
    wghtc                   = wwc10
    wghth                   = wwh10
    wghtb                   = wwb10
  END
  ELSE : STOP        ;;  Should not be possible --> debug
ENDCASE
;;  Compute total weights
weighttot               = lbw__add(wghtc,lbw__add(wghth,wghtb,/NAN),/NAN)
;;  Calculate total chi-squared
model_tot               = lbw__add(corefit_out,lbw__add(halofit_out,beamfit_out,/NAN),/NAN)
measr_tot               = lbw__add(vdf_2dc0,lbw__add(residualh,residualb,/NAN),/NAN)
;measr_tot               = vdf_2d
;weighttot               = lbw__add(weightc,lbw__add(weighth,weightb,/NAN),/NAN)
;weighttot               = 1d0/poisson_2d^2d0
test_tot                = (FINITE(measr_tot) EQ 0) OR (measr_tot LE 0) OR   $
                          (FINITE(weighttot) EQ 0) OR (weighttot LE 0)
bad_tot                 = WHERE(test_tot,bd_tot,COMPLEMENT=good_tot,NCOMPLEMENT=gd_tot)
IF (bd_tot[0] GT 0) THEN BEGIN
  measr_tot[bad]            = 0d0
  weighttot[bad]            = 0d0
ENDIF
dof0                    = ((dofc[0] > dofh[0]) > dofb[0])
doft                    = 3d0*dof0[0]
chisq_tot_a             = TOTAL((vdf_2d - model_tot)^2d0*ABS(weighttot),/NAN)
chisq_tot_f             = TOTAL((measr_tot - model_tot)^2d0*ABS(weighttot),/NAN)
red_chisq_tot_f         = chisq_tot_f[0]/doft[0]
red_chisq_tot_a         = chisq_tot_a[0]/doft[0]
chisq_tot               = [chisq_tot_a[0],chisq_tot_f[0]]
red_chisq_tot           = [red_chisq_tot_a[0],red_chisq_tot_f[0]]
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
out_tags                = ['X_IN','Y_IN','Z_IN','WEIGHTS','YFIT','FIT_PARAMS','SIG_PARAM',$
                           'CHISQ','DOF','N_ITER','STATUS','YERROR','FUNC','PARINFO',     $
                           'PFREE_INDEX','NPEGGED','Z_ORIG','ERR_ORIG','OFFSET','NTRIALS']
core_strc               = CREATE_STRUCT(out_tags,vx_in,vy_in,vdf_2dc,weightc,corefit_out,c_fit,  $
                                        f_sigc,chisqc[0],dofc[0],iterc[0],statc[0],zerrorc,      $
                                        cfun[0],c_pinfo,cfree_ind,cpegged,vdf_2d,poisson_2d,     $
                                        offset[0],c__trial[0])
halo_strc               = CREATE_STRUCT(out_tags,vx_in,vy_in,residualh,weighth,halofit_out,h_fit,$
                                        f_sigh,chisqh[0],dofh[0],iterh[0],stath[0],zerrorh,      $
                                        hfun[0],h_pinfo,hfree_ind,hpegged,vdf_2dh,poisson_2dh,   $
                                        offset[0],h__trial[0])
beam_strc               = CREATE_STRUCT(out_tags,vx_in,vy_in,residualb,weightb,beamfit_out,b_fit,$
                                        f_sigb,chisqb[0],dofb[0],iterb[0],statb[0],zerrorb,      $
                                        bfun[0],b_pinfo,bfree_ind,bpegged,vdf_2db,poisson_2db,   $
                                       offset[0], b__trial[0])
tags                    = ['CORE','HALO','BEAM','MODEL_TOT','VDF_FIT_TOT','WEIGHT_TOT','CHISQ_TOT','RED_CHISQ_TOT']
out_struc               = CREATE_STRUCT(tags,core_strc,halo_strc,beam_strc,model_tot,measr_tot,weighttot,chisq_tot,red_chisq_tot)
;;  Define new copy structure with thermal speeds instead of temperatures for plotting routine
out_strucp              = out_struc
out_strucp.CORE.FIT_PARAMS[1:2] = vthfac[0]*SQRT(out_strucp.CORE.FIT_PARAMS[1:2])
out_strucp.CORE.SIG_PARAM[1:2]  = vthfac[0]*SQRT(out_strucp.CORE.SIG_PARAM[1:2])
out_strucp.HALO.FIT_PARAMS[1:2] = vthfac[0]*SQRT(out_strucp.HALO.FIT_PARAMS[1:2])
out_strucp.HALO.SIG_PARAM[1:2]  = vthfac[0]*SQRT(out_strucp.HALO.SIG_PARAM[1:2])
out_strucp.BEAM.FIT_PARAMS[1:2] = vthfac[0]*SQRT(out_strucp.BEAM.FIT_PARAMS[1:2])
out_strucp.BEAM.SIG_PARAM[1:2]  = vthfac[0]*SQRT(out_strucp.BEAM.SIG_PARAM[1:2])
CASE cfunc[0] OF
  'MM'  :  out_strucp.CORE.FUNC = 'bimaxwellian_fit'
  'KK'  :  out_strucp.CORE.FUNC = 'bikappa_fit'
  'SS'  :  out_strucp.CORE.FUNC = 'biselfsimilar_fit'
  'AS'  :  out_strucp.CORE.FUNC = 'biselfsimilar_2exp_fit'
ENDCASE
CASE hfunc[0] OF
  'MM'  :  out_strucp.HALO.FUNC = 'bimaxwellian_fit'
  'KK'  :  out_strucp.HALO.FUNC = 'bikappa_fit'
  'SS'  :  out_strucp.HALO.FUNC = 'biselfsimilar_fit'
  'AS'  :  out_strucp.HALO.FUNC = 'biselfsimilar_2exp_fit'
ENDCASE
CASE bfunc[0] OF
  'MM'  :  out_strucp.BEAM.FUNC = 'bimaxwellian_fit'
  'KK'  :  out_strucp.BEAM.FUNC = 'bikappa_fit'
  'SS'  :  out_strucp.BEAM.FUNC = 'biselfsimilar_fit'
  'AS'  :  out_strucp.BEAM.FUNC = 'biselfsimilar_2exp_fit'
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Plot data with fits
;;----------------------------------------------------------------------------------------
plot_vdfs_4_fitvdf2sumof3funcs,vdf,velxyz,out_strucp,VFRAME=vframe,VEC1=vec1,VEC2=vec2,   $
                                   ONLY_TOT=only_tot,PLOT_BOTH=plot_both,                 $
                                   NOUSECTAB=nousectab,                                   $
                                   CORE_LABS=core_labs,HALO_LABS=halo_labs,               $
                                   BEAM_LABS=beam_labs,XYLAB_PRE=xylabpre,                $
                                   CFUNC=cfunc,HFUNC=hfunc,BFUNC=bfunc,                   $
                                   ELECTRONS=electrons,IONS=ions,                         $
                                   SPTHRSHS=spthrshs,MAXFACS=maxfac0,                     $
                                   SAVEF=savef,FILENAME=filename,                         $
                                   _EXTRA=extrakey
;;  Check status and change if necessary
IF (out_strucp.CORE.STATUS[0] NE out_struc.CORE.STATUS[0]) THEN out_struc.CORE.STATUS = out_strucp.CORE.STATUS[0]
IF (out_strucp.HALO.STATUS[0] NE out_struc.HALO.STATUS[0]) THEN out_struc.HALO.STATUS = out_strucp.HALO.STATUS[0]
IF (out_strucp.BEAM.STATUS[0] NE out_struc.BEAM.STATUS[0]) THEN out_struc.BEAM.STATUS = out_strucp.BEAM.STATUS[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
