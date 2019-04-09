;+
;*****************************************************************************************
;
;  FUNCTION :   log10_get_defaults_4_parinfo_struc4mpfit_4_vdfs.pro
;  PURPOSE  :   This is a subroutine of ???.pro meant to return
;                 the PARINFO structure appropriate for the given input particle species.
;
;  CALLED BY:   
;               ???.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
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
;               test = log10_get_defaults_4_parinfo_struc4mpfit_4_vdfs(                                            $
;                                          [,CFUNC=cfunc] [,HFUNC=hfunc] [,BFUNC=bfunc]                            $
;                                          [,/ELECTRONS] [,/IONS]                                                  $
;                                          [,FIXED_C=fixed_c] [,FIXED_H=fixed_h] [,FIXED_B=fixed_b]                $
;                                          [,NCORE_RAN=ncore_ran] [,NHALO_RAN=nhalo_ran] [,NBEAM_RAN=nbeam_ran]    $
;                                          [,TPACORERN=tpacorern] [,TPAHALORN=tpahalorn] [,TPABEAMRN=tpabeamrn]    $
;                                          [,TPECORERN=tpecorern] [,TPEHALORN=tpehalorn] [,TPEBEAMRN=tpebeamrn]    $
;                                          [,VOACORERN=voacorern] [,VOAHALORN=voahalorn] [,VOABEAMRN=voabeamrn]    $
;                                          [,VOECORERN=voecorern] [,VOEHALORN=voehalorn] [,VOEBEAMRN=voebeamrn]    $
;                                          [,EXPCORERN=expcorern] [,EXPHALORN=exphalorn] [,EXPBEAMRN=expbeamrn]    $
;                                          [,ES2CORERN=es2corern] [,ES2HALORN=es2halorn] [,ES2BEAMRN=es2beamrn]    $
;                                          [,FTOL=ftol] [,GTOL=gtol] [,XTOL=xtol] [,USE_MM=use_mm]                 $
;                                          [,DEF_OFFST=def_offst] [,PARINFO=def_pinf] [,HARINFO=def_hinf]          $
;                                          [,BARINFO=def_binf] [,FUNC_C=func_c] [,FUNC_H=func_h] [,FUNC_B=func_b]  $
;                                          [,CORE_LABS=core_labs] [,HALO_LABS=halo_labs] [,BEAM_LABS=beam_labs]    $
;                                          [,XYLAB_PRE=xylabpre]                                                   )
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
;               TPACORERN  :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the core parallel temperature or
;                               PARAM[1].  Note, if this keyword is set, it is
;                               equivalent to telling the routine that Tcpara should be
;                               limited by these bounds.  Setting this keyword will
;                               define:
;                                 PARINFO[1].LIMITED[*] = BYTE(TPACORERN[0:1])
;                                 PARINFO[1].LIMITS[*]  = TPACORERN[2:3]
;               TPAHALORN  :  Same as TPACORERN but for HPARM[1] and HARINFO[1].
;               TPABEAMRN  :  Same as TPACORERN but for BPARM[1] and BARINFO[1].
;               TPECORERN  :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the core perpendicular temperature
;                               or PARAM[2].  Note, if this keyword is set, it is
;                               equivalent to telling the routine that Tcperp should be
;                               limited by these bounds.  Setting this keyword will
;                               define:
;                                 PARINFO[2].LIMITED[*] = BYTE(TPECORERN[0:1])
;                                 PARINFO[2].LIMITS[*]  = TPECORERN[2:3]
;               TPEHALORN  :  Same as TPECORERN but for HPARM[2] and HARINFO[2].
;               TPEBEAMRN  :  Same as TPECORERN but for BPARM[2] and BARINFO[2].
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
;                               element contains the following tags and definitions:
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
;                                 'MM'  -->  'bimaxwellian_fit'
;                                 'KK'  -->  'bikappa_fit'
;                                 'SS'  -->  'biselfsimilar_fit'
;                                 'AS'  -->  'biselfsimilar_2exp_fit'
;               FUNC_H     :  Set to a named variable to return the default model
;                               function name to use for the halo VDF
;                                 'MM'  -->  'bimaxwellian_fit'
;                                 'KK'  -->  'bikappa_fit'
;                                 'SS'  -->  'biselfsimilar_fit'
;                                 'AS'  -->  'biselfsimilar_2exp_fit'
;               FUNC_B     :  Set to a named variable to return the default model
;                               function name to use for the beam/strahl VDF
;                                 'MM'  -->  'bimaxwellian_fit'
;                                 'KK'  -->  'bikappa_fit'
;                                 'SS'  -->  'biselfsimilar_fit'
;                                 'AS'  -->  'biselfsimilar_2exp_fit'
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
;               4)  If USE_MM is set, still enter all speed/velocity parameters in km/s
;               5)  If any of the function keywords are set to [C,H,B]FUNC = 'AS', then
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
;   ADAPTED FROM: get_defaults_4_parinfo_struc4mpfit_4_vdfs.pro    BY: Lynn B. Wilson III
;   CREATED:  04/03/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/03/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION log10_get_defaults_4_parinfo_struc4mpfit_4_vdfs,CFUNC=cfunc,HFUNC=hfunc,BFUNC=bfunc,  $
                                  ELECTRONS=electrons,IONS=ions,                               $
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
def_vth_emks            = [20d2,50d2,50d2]                    ;;  Default electron thermal speeds [km/s]
def__T__emks            = [11d0,70d0,70d0]                    ;;  Default electron temperatures [eV]
def_v_o_emks            = [ 1d2, 1d3, 1d3]                    ;;  Default electron drift speeds [km/s]
def_vth_imks            = [20d0,50d0,50d0]                    ;;  Default proton thermal speeds [km/s]
def__T__imks            = [ 2d0,13d0,13d0]                    ;;  Default proton temperatures [eV]
def_v_o_imks            = [ 3d2, 5d2, 5d2]                    ;;  Default proton drift speeds [km/s]
def_ei_offst            = [1d18,1d10]                         ;;  Default offset to force data to be ≥ 1.0
def_ks                  = [3d0,5d0]                           ;;  Default kappa and self-similar exponent values
def_n_ch                = [5d0,3d-1]                          ;;  Default core/halo number densities [cm^(-3)]
;;-------------------------------------------------------
;;  Default fit parameter limits/ranges
;;-------------------------------------------------------
;;  Default limits/ranges:  Electrons
def_n_ec_lim            = [5d-2,2d2]      ;;  0.05 ≤ n_ec ≤ 200 cm^(-3)
def_n_eh_lim            = [1d-3,2d1]      ;;  0.001 ≤ n_eh ≤ 20 cm^(-3)
def_n_eb_lim            = [1d-4,1d1]      ;;  0.0001 ≤ n_eh ≤ 10 cm^(-3)
def_vtec_lim            = [5d0,1d4]       ;;  5 km/s ≤ V_Tecj ≤ 10000 km/s
def_vteh_lim            = [5d0,2d4]       ;;  5 km/s ≤ V_Tehj ≤ 20000 km/s
def__Tec_lim            = [1d-4,3d2]      ;;  0.0001 eV ≤ T_ecj ≤ 300 eV
def__Teh_lim            = [1d-4,12d2]     ;;  0.0001 eV ≤ T_ehj ≤ 1200 eV
def_voec_lim            = [-1d0,1d0]*1d3  ;;   -1000 km/s ≤ V_oecj ≤  +1000 km/s
def_voeh_lim            = [-1d0,1d0]*1d4  ;;  -10000 km/s ≤ V_oecj ≤ +10000 km/s
;;  Default limits/ranges:  Protons
def_n_ic_lim            = [5d-2,2d2]      ;;  0.05 ≤ n_ic ≤ 200 cm^(-3)
def_n_ih_lim            = [1d-3,2d1]      ;;  0.001 ≤ n_ih ≤ 20 cm^(-3)
def_n_ib_lim            = [1d-4,2d1]      ;;  0.0001 ≤ n_ih ≤ 20 cm^(-3)
def_vtic_lim            = [1d0,1d3]       ;;  1 km/s ≤ V_Tpcj ≤ 1000 km/s
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
def_bimax_ec            = [def_n_ch[0],def__T__emks[0],def__T__emks[0],def_v_o_emks[0],0d0,2d0]              ;;  Default bi-Maxwellian core electrons
def_bikap_ec            = [def_n_ch[0],def__T__emks[1],def__T__emks[1],def_v_o_emks[1],0d0,def_ks[0]]        ;;  Default bi-kappa " "
def_bi_ss_ec            = [def_n_ch[0],def__T__emks[2],def__T__emks[2],def_v_o_emks[2],0d0,def_ks[1]]        ;;  Default bi-self-similar " "
def_bi_as_ec            = [def_n_ch[0],def__T__emks[2],def__T__emks[2],def_v_o_emks[2],def_ks[0],def_ks[1]]  ;;  Default asymmetric bi-self-similar " "
def_bimax_eh            = [def_n_ch[1],def__T__emks[0],def__T__emks[0],def_v_o_emks[0],0d0,2d0]              ;;  Default bi-Maxwellian halo electrons
def_bikap_eh            = [def_n_ch[1],def__T__emks[1],def__T__emks[1],def_v_o_emks[1],0d0,def_ks[0]]        ;;  Default bi-kappa " "
def_bi_ss_eh            = [def_n_ch[1],def__T__emks[2],def__T__emks[2],def_v_o_emks[2],0d0,def_ks[1]]        ;;  Default bi-self-similar " "
def_bi_as_eh            = [def_n_ch[1],def__T__emks[2],def__T__emks[2],def_v_o_emks[2],def_ks[0],def_ks[1]]  ;;  Default asymmetric bi-self-similar " "
;;  Protons
def_bimax_ic            = [def_n_ch[0],def__T__imks[0],def__T__imks[0],def_v_o_imks[0],0d0,2d0]              ;;  Default bi-Maxwellian core protons
def_bikap_ic            = [def_n_ch[0],def__T__imks[1],def__T__imks[1],def_v_o_imks[1],0d0,def_ks[0]]        ;;  Default bi-kappa " "
def_bi_ss_ic            = [def_n_ch[0],def__T__imks[2],def__T__imks[2],def_v_o_imks[2],0d0,def_ks[1]]        ;;  Default bi-self-similar " "
def_bi_as_ic            = [def_n_ch[0],def__T__imks[2],def__T__imks[2],def_v_o_imks[2],def_ks[0],def_ks[1]]  ;;  Default asymmetric bi-self-similar " "
def_bimax_ih            = [def_n_ch[1],def__T__imks[0],def__T__imks[0],def_v_o_imks[0],0d0,2d0]              ;;  Default bi-Maxwellian core protons
def_bikap_ih            = [def_n_ch[1],def__T__imks[1],def__T__imks[1],def_v_o_imks[1],0d0,def_ks[0]]        ;;  Default bi-kappa " "
def_bi_ss_ih            = [def_n_ch[1],def__T__imks[2],def__T__imks[2],def_v_o_imks[2],0d0,def_ks[1]]        ;;  Default bi-self-similar " "
def_bi_as_ih            = [def_n_ch[1],def__T__imks[2],def__T__imks[2],def_v_o_imks[2],def_ks[0],def_ks[1]]  ;;  Default asymmetric bi-self-similar " "
;;  Define default parameter array
def_param               = def_bimax_ec
def_haram               = def_bikap_eh
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
;;  Check keywords with default options
;;----------------------------------------------------------------------------------------
;;  Check IONS
test           = (N_ELEMENTS(ions) GT 0) AND KEYWORD_SET(ions)
IF (test[0]) THEN ion__on = 1b ELSE ion__on = 0b
;;  Check ELECTRONS
test           = (N_ELEMENTS(electrons) GT 0) AND KEYWORD_SET(electrons)
IF (test[0]) THEN elec_on = 1b ELSE elec_on = ([0b,1b])[~ion__on[0]]
IF (elec_on[0] AND ion__on[0]) THEN ion__on[0] = 0b                    ;;  Make sure only one particle type is set
IF (elec_on[0]) THEN spc_string = e_p_lab_str[0] ELSE spc_string = e_p_lab_str[1]
;;  Check CFUNC
test                    = (SIZE(cfunc,/TYPE) EQ 7)
IF (test[0]) THEN cf = STRUPCASE(STRMID(cfunc[0],0,2)) ELSE cf = 'MM'
CASE cf[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  BEGIN
    cfunc       = 'MM'
    core_labs   = core_bm_lab
    xylabpre    = ['Bi-Max.']
    def_pinf[5].VALUE = 2d0
    def_pinf[5].FIXED = 1b
    func_c      = 'log10_'+spc_string[0]+'_biselfsimilar_fit'
  END
  'KK'  :  BEGIN
    cfunc       = 'KK'
    core_labs   = core_kk_lab
    xylabpre    = ['Bi-kappa']
    func_c      = 'log10_'+spc_string[0]+'_bikappa_fit'
  END
  'SS'  :  BEGIN
    cfunc       = 'SS'
    core_labs   = core_ss_lab
    xylabpre    = ['Bi-SS']
    func_c      = 'log10_'+spc_string[0]+'_biselfsimilar_fit'
  END
  'AS'  :  BEGIN
    cfunc       = 'AS'
    core_labs   = core_as_lab
    xylabpre    = ['Bi-AS']
    func_c      = 'log10_'+spc_string[0]+'_biselfsimilar_2exp_fit'
  END
  ELSE  :  BEGIN
    cfunc       = 'MM'     ;;  Default
    core_labs   = core_bm_lab
    xylabpre    = ['Bi-Max.']
    def_pinf[5].VALUE = 2d0
    def_pinf[5].FIXED = 1b
    func_c      = 'log10_'+spc_string[0]+'_biselfsimilar_fit'
  END
ENDCASE
;;  Check HFUNC
test                    = (SIZE(hfunc,/TYPE) EQ 7)
IF (test[0]) THEN hf = STRUPCASE(STRMID(hfunc[0],0,2)) ELSE hf = 'KK'
CASE hf[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  BEGIN
    hfunc       = 'MM'
    halo_labs   = halo_bm_lab
    xylabpre    = [xylabpre,'Bi-Max.']
    def_hinf[5].VALUE = 2d0
    def_hinf[5].FIXED = 1b
    func_h      = 'log10_'+spc_string[0]+'_biselfsimilar_fit'
  END
  'KK'  :  BEGIN
    hfunc       = 'KK'
    halo_labs   = halo_kk_lab
    xylabpre    = [xylabpre,'Bi-kappa']
    func_h      = 'log10_'+spc_string[0]+'_bikappa_fit'
  END
  'SS'  :  BEGIN
    hfunc       = 'SS'
    halo_labs   = halo_ss_lab
    xylabpre    = [xylabpre,'Bi-SS']
    func_h      = 'log10_'+spc_string[0]+'_biselfsimilar_fit'
  END
  'AS'  :  BEGIN
    hfunc       = 'AS'
    halo_labs   = halo_as_lab
    xylabpre    = [xylabpre,'Bi-AS']
    func_h      = 'log10_'+spc_string[0]+'_biselfsimilar_2exp_fit'
  END
  ELSE  :  BEGIN
    hfunc       = 'MM'     ;;  Default
    halo_labs   = halo_bm_lab
    xylabpre    = [xylabpre,'Bi-Max.']
    def_hinf[5].VALUE = 2d0
    def_hinf[5].FIXED = 1b
    func_h      = 'log10_'+spc_string[0]+'_biselfsimilar_fit'
  END
ENDCASE
;;  Check BFUNC
test                    = (SIZE(bfunc,/TYPE) EQ 7)
IF (test[0]) THEN bf = STRUPCASE(STRMID(bfunc[0],0,2)) ELSE bf = 'KK'
CASE bf[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  BEGIN
    bfunc       = 'MM'
    beam_labs   = beam_bm_lab
    xylabpre    = [xylabpre,'Bi-Max.']
    def_binf[5].VALUE = 2d0
    def_binf[5].FIXED = 1b
    func_b      = 'log10_'+spc_string[0]+'_biselfsimilar_fit'
  END
  'KK'  :  BEGIN
    bfunc       = 'KK'
    beam_labs   = beam_kk_lab
    xylabpre    = [xylabpre,'Bi-kappa']
    func_b      = 'log10_'+spc_string[0]+'_bikappa_fit'
  END
  'SS'  :  BEGIN
    bfunc       = 'SS'
    beam_labs   = beam_ss_lab
    xylabpre    = [xylabpre,'Bi-SS']
    func_b      = 'log10_'+spc_string[0]+'_biselfsimilar_fit'
  END
  'AS'  :  BEGIN
    bfunc       = 'AS'
    beam_labs   = beam_as_lab
    xylabpre    = [xylabpre,'Bi-AS']
    func_b      = 'log10_'+spc_string[0]+'_biselfsimilar_2exp_fit'
  END
  ELSE  :  BEGIN
    bfunc       = 'MM'     ;;  Default
    beam_labs   = beam_bm_lab
    xylabpre    = [xylabpre,'Bi-Max.']
    def_binf[5].VALUE = 2d0
    def_binf[5].FIXED = 1b
    func_b      = 'log10_'+spc_string[0]+'_biselfsimilar_fit'
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
;;  Define species-dependent limits
;;----------------------------------------------------------------------------------------
IF (elec_on[0]) THEN BEGIN
  ;;  Use electron values
  def_denc_lim = def_n_ec_lim
  def_denh_lim = def_n_eh_lim
  def_denb_lim = def_n_eb_lim
  def_vthc_lim = def_vtec_lim
  def_vthh_lim = def_vteh_lim
  def__Tc__lim = def__Tec_lim
  def__Th__lim = def__Teh_lim
  def_v_oc_lim = def_voec_lim
  def_v_oh_lim = def_voeh_lim
  def_offst    = def_ei_offst[0]
ENDIF ELSE BEGIN
  ;;  Use proton values
  def_denc_lim = def_n_ic_lim
  def_denh_lim = def_n_ih_lim
  def_denb_lim = def_n_ib_lim
  def_vthc_lim = def_vtic_lim
  def_vthh_lim = def_vtih_lim
  def__Tc__lim = def__Tic_lim
  def__Th__lim = def__Tih_lim
  def_v_oc_lim = def_voic_lim
  def_v_oh_lim = def_voih_lim
  def_offst    = def_ei_offst[1]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check PARINFO keywords
;;----------------------------------------------------------------------------------------
;;  Check FIXED_C
test                    = (N_ELEMENTS(fixed_c) EQ 6) AND is_a_number(fixed_c,/NOMSSG)
IF (test[0]) THEN fixc = (REFORM(fixed_c) EQ 1) ELSE fixc = REPLICATE(0b,6)
;;  Check FIXED_H
test                    = (N_ELEMENTS(fixed_h) EQ 6) AND is_a_number(fixed_h,/NOMSSG)
IF (test[0]) THEN fixh = (REFORM(fixed_h) EQ 1) ELSE fixh = REPLICATE(0b,6)
;;  Check FIXED_B
test                    = (N_ELEMENTS(fixed_b) EQ 6) AND is_a_number(fixed_b,/NOMSSG)
IF (test[0]) THEN fixb = (REFORM(fixed_b) EQ 1) ELSE fixb = REPLICATE(0b,6)
;;  Alter values if bi-Maxwellian function used
IF (hfunc[0] EQ 'MM') THEN fixh[5] = 1b
IF (bfunc[0] EQ 'MM') THEN fixb[5] = 1b
;;  Check N[CORE,HALO,BEAM]_RAN
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=ncore_ran,DEF_RAN=def_denc_lim,LIMS_OUT=lims_ncore,LIMD_OUT=limd_ncore,RKEY_ON=ncore_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=nhalo_ran,DEF_RAN=def_denh_lim,LIMS_OUT=lims_nhalo,LIMD_OUT=limd_nhalo,RKEY_ON=nhalo_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=nbeam_ran,DEF_RAN=def_denb_lim,LIMS_OUT=lims_nbeam,LIMD_OUT=limd_nbeam,RKEY_ON=nbeam_on)
;;  Check TPA[CORE,HALO,BEAM]RN
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=tpacorern,DEF_RAN=def__Tc__lim,LIMS_OUT=lims_Tpa_c,LIMD_OUT=limd_Tpa_c,RKEY_ON=Tpa_c_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=tpahalorn,DEF_RAN=def__Th__lim,LIMS_OUT=lims_Tpa_h,LIMD_OUT=limd_Tpa_h,RKEY_ON=Tpa_h_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=tpabeamrn,DEF_RAN=def__Th__lim,LIMS_OUT=lims_Tpa_b,LIMD_OUT=limd_Tpa_b,RKEY_ON=Tpa_b_on)
;;  Check TPE[CORE,HALO,BEAM]RN
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=tpecorern,DEF_RAN=def__Tc__lim,LIMS_OUT=lims_Tpe_c,LIMD_OUT=limd_Tpe_c,RKEY_ON=Tpe_c_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=tpehalorn,DEF_RAN=def__Th__lim,LIMS_OUT=lims_Tpe_h,LIMD_OUT=limd_Tpe_h,RKEY_ON=Tpe_h_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=tpebeamrn,DEF_RAN=def__Th__lim,LIMS_OUT=lims_Tpe_b,LIMD_OUT=limd_Tpe_b,RKEY_ON=Tpe_b_on)
;;  Check VOA[CORE,HALO,BEAM]RN
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=voacorern,DEF_RAN=def_v_oc_lim,LIMS_OUT=lims_v_oca,LIMD_OUT=limd_v_oca,RKEY_ON=v_oca_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=voahalorn,DEF_RAN=def_v_oh_lim,LIMS_OUT=lims_v_oha,LIMD_OUT=limd_v_oha,RKEY_ON=v_oha_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=voabeamrn,DEF_RAN=def_v_oh_lim,LIMS_OUT=lims_v_oba,LIMD_OUT=limd_v_oba,RKEY_ON=v_oba_on)
;;  Check VOE[CORE,HALO,BEAM]RN
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=voecorern,DEF_RAN=def_v_oc_lim,LIMS_OUT=lims_v_oce,LIMD_OUT=limd_v_oce,RKEY_ON=v_oce_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=voehalorn,DEF_RAN=def_v_oh_lim,LIMS_OUT=lims_v_ohe,LIMD_OUT=limd_v_ohe,RKEY_ON=v_ohe_on)
test                    = test_ranges_4_mpfitparinfostruc(RKEY_IN=voebeamrn,DEF_RAN=def_v_oh_lim,LIMS_OUT=lims_v_obe,LIMD_OUT=limd_v_obe,RKEY_ON=v_obe_on)
;;  Check EXP[CORE,HALO,BEAM]RN
IF (cfunc[0] NE 'MM') THEN BEGIN
  IF (cfunc[0] EQ 'KK') THEN def_expcran = def_kapp_lim ELSE def_expcran = def_ssex_lim
  test = test_ranges_4_mpfitparinfostruc(RKEY_IN=expcorern,DEF_RAN=def_expcran,LIMS_OUT=lims_exp_c,LIMD_OUT=limd_exp_c,RKEY_ON=exp_c_on)
ENDIF
IF (hfunc[0] NE 'MM') THEN BEGIN
  IF (hfunc[0] EQ 'KK') THEN def_exphran = def_kapp_lim ELSE def_exphran = def_ssex_lim
  test = test_ranges_4_mpfitparinfostruc(RKEY_IN=exphalorn,DEF_RAN=def_exphran,LIMS_OUT=lims_exp_h,LIMD_OUT=limd_exp_h,RKEY_ON=exp_h_on)
ENDIF
IF (bfunc[0] NE 'MM') THEN BEGIN
  IF (bfunc[0] EQ 'KK') THEN def_expbran = def_kapp_lim ELSE def_expbran = def_ssex_lim
  test = test_ranges_4_mpfitparinfostruc(RKEY_IN=expbeamrn,DEF_RAN=def_expbran,LIMS_OUT=lims_exp_b,LIMD_OUT=limd_exp_b,RKEY_ON=exp_b_on)
ENDIF
;;  Check ES2[CORE,HALO,BEAM]RN
IF (cfunc[0] EQ 'AS') THEN BEGIN
  def_es2cran = def_ssex_lim
  test        = test_ranges_4_mpfitparinfostruc(RKEY_IN=es2corern,DEF_RAN=def_es2cran,LIMS_OUT=lims_es2_c,LIMD_OUT=limd_es2_c,RKEY_ON=es2_c_on)
ENDIF
IF (hfunc[0] EQ 'AS') THEN BEGIN
  def_es2hran = def_ssex_lim
  test        = test_ranges_4_mpfitparinfostruc(RKEY_IN=es2halorn,DEF_RAN=def_es2hran,LIMS_OUT=lims_es2_h,LIMD_OUT=limd_es2_h,RKEY_ON=es2_h_on)
ENDIF
IF (bfunc[0] EQ 'AS') THEN BEGIN
  def_es2bran = def_ssex_lim
  test        = test_ranges_4_mpfitparinfostruc(RKEY_IN=es2beamrn,DEF_RAN=def_es2bran,LIMS_OUT=lims_es2_b,LIMD_OUT=limd_es2_b,RKEY_ON=es2_b_on)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Impose limits on default PARINFO structure
;;----------------------------------------------------------------------------------------
;;  Impose FIXED settings for PARINFO and BARINFO
def_pinf[*].FIXED       = fixc
def_hinf[*].FIXED       = fixh
def_binf[*].FIXED       = fixb
;;  Limit number densities [cm^(-3)]
IF (ncore_on[0]) THEN def_pinf[00].LIMITED[*] = limd_ncore ELSE def_pinf[00].LIMITED[*] = 1b
IF (ncore_on[0]) THEN def_pinf[00].LIMITS[*]  = lims_ncore ELSE def_pinf[00].LIMITS[*]  = def_denc_lim
IF (nhalo_on[0]) THEN def_hinf[00].LIMITED[*] = limd_nhalo ELSE def_hinf[00].LIMITED[*] = 1b
IF (nhalo_on[0]) THEN def_hinf[00].LIMITS[*]  = lims_nhalo ELSE def_hinf[00].LIMITS[*]  = def_denh_lim
IF (nbeam_on[0]) THEN def_binf[00].LIMITED[*] = limd_nbeam ELSE def_binf[00].LIMITED[*] = 1b
IF (nbeam_on[0]) THEN def_binf[00].LIMITS[*]  = lims_nbeam ELSE def_binf[00].LIMITS[*]  = def_denb_lim
;;  Limit parallel temperatures [eV]
IF (Tpa_c_on[0]) THEN def_pinf[01].LIMITED[*] = limd_Tpa_c ELSE def_pinf[01].LIMITED[*] = 1b
IF (Tpa_h_on[0]) THEN def_hinf[01].LIMITED[*] = limd_Tpa_h ELSE def_hinf[01].LIMITED[*] = 1b
IF (Tpa_b_on[0]) THEN def_binf[01].LIMITED[*] = limd_Tpa_b ELSE def_binf[01].LIMITED[*] = 1b
IF (Tpa_c_on[0]) THEN def_pinf[01].LIMITS[*]  = lims_Tpa_c ELSE def_pinf[01].LIMITS[*]  = def__Tc__lim
IF (Tpa_h_on[0]) THEN def_hinf[01].LIMITS[*]  = lims_Tpa_h ELSE def_hinf[01].LIMITS[*]  = def__Th__lim
IF (Tpa_b_on[0]) THEN def_binf[01].LIMITS[*]  = lims_Tpa_b ELSE def_binf[01].LIMITS[*]  = def__Th__lim
;;  Limit perpendicular temperatures [eV]
IF (Tpe_c_on[0]) THEN def_pinf[02].LIMITED[*] = limd_Tpe_c ELSE def_pinf[02].LIMITED[*] = 1b
IF (Tpe_h_on[0]) THEN def_hinf[02].LIMITED[*] = limd_Tpe_h ELSE def_hinf[02].LIMITED[*] = 1b
IF (Tpe_b_on[0]) THEN def_binf[02].LIMITED[*] = limd_Tpe_b ELSE def_binf[02].LIMITED[*] = 1b
IF (Tpe_c_on[0]) THEN def_pinf[02].LIMITS[*]  = lims_Tpe_c ELSE def_pinf[02].LIMITS[*]  = def__Tc__lim
IF (Tpe_h_on[0]) THEN def_hinf[02].LIMITS[*]  = lims_Tpe_h ELSE def_hinf[02].LIMITS[*]  = def__Th__lim
IF (Tpe_b_on[0]) THEN def_binf[02].LIMITS[*]  = lims_Tpe_b ELSE def_binf[02].LIMITS[*]  = def__Th__lim
;;  Limit parallel drift speeds [km/s]
IF (v_oca_on[0]) THEN def_pinf[03].LIMITED[*] = limd_v_oca ELSE def_pinf[03].LIMITED[*] = 1b
IF (v_oha_on[0]) THEN def_hinf[03].LIMITED[*] = limd_v_oha ELSE def_hinf[09].LIMITED[*] = 1b
IF (v_oba_on[0]) THEN def_binf[03].LIMITED[*] = limd_v_oba ELSE def_binf[03].LIMITED[*] = 1b
IF (v_oca_on[0]) THEN def_pinf[03].LIMITS[*]  = lims_v_oca ELSE def_pinf[03].LIMITS[*]  = def_v_oc_lim
IF (v_oha_on[0]) THEN def_hinf[03].LIMITS[*]  = lims_v_oha ELSE def_hinf[09].LIMITS[*]  = def_v_oh_lim
IF (v_oba_on[0]) THEN def_binf[03].LIMITS[*]  = lims_v_oba ELSE def_binf[03].LIMITS[*]  = def_v_oh_lim
;;  Limit perpendicular drift speeds [km/s]
IF (v_oce_on[0]) THEN def_pinf[04].LIMITED[*] = limd_v_oce ELSE def_pinf[04].LIMITED[*] = 1b
IF (v_ohe_on[0]) THEN def_hinf[04].LIMITED[*] = limd_v_ohe ELSE def_hinf[04].LIMITED[*] = 1b
IF (v_obe_on[0]) THEN def_binf[04].LIMITED[*] = limd_v_obe ELSE def_binf[04].LIMITED[*] = 1b
IF (v_oce_on[0]) THEN def_pinf[04].LIMITS[*]  = lims_v_oce ELSE def_pinf[04].LIMITS[*]  = def_v_oc_lim
IF (v_ohe_on[0]) THEN def_hinf[04].LIMITS[*]  = lims_v_ohe ELSE def_hinf[04].LIMITS[*]  = def_v_oh_lim
IF (v_obe_on[0]) THEN def_binf[04].LIMITS[*]  = lims_v_obe ELSE def_binf[04].LIMITS[*]  = def_v_oh_lim
;;----------------------------------------------------------------------------------------
;;  Define model- and species-dependent parameters
;;----------------------------------------------------------------------------------------
;;  CORE:
CASE cfunc[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  BEGIN
    ;;  bi-Maxwellian core
    IF (elec_on[0]) THEN def_c_param = def_bimax_ec ELSE def_c_param = def_bimax_ic
    ;;  Fix unused parameter
    def_pinf[05].FIXED      = 1b
    def_c_param[05]         = 2
    def_pinf[05].VALUE      = 2
  END
  'KK'  :  BEGIN
    ;;  bi-kappa core
    IF (elec_on[0]) THEN def_c_param = def_bikap_ec ELSE def_c_param = def_bikap_ic
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
    IF (elec_on[0]) THEN def_c_param = def_bi_ss_ec ELSE def_c_param = def_bi_ss_ic
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
    IF (elec_on[0]) THEN def_c_param = def_bi_as_ec ELSE def_c_param = def_bi_as_ic
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
ENDCASE
;;  HALO:
CASE hfunc[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  BEGIN
    ;;  bi-Maxwellian halo
    IF (elec_on[0]) THEN def_h_param = def_bimax_eh ELSE def_h_param = def_bimax_ih
    ;;  Fix unused parameter
    def_hinf[05].FIXED      = 1b
    def_h_param[05]         = 2
    def_hinf[05].VALUE      = 2
  END
  'KK'  :  BEGIN
    ;;  bi-kappa halo
    IF (elec_on[0]) THEN def_h_param = def_bikap_eh ELSE def_h_param = def_bikap_ih
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
    IF (elec_on[0]) THEN def_h_param = def_bi_ss_eh ELSE def_h_param = def_bi_ss_ih
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
    IF (elec_on[0]) THEN def_h_param = def_bi_as_eh ELSE def_h_param = def_bi_as_ih
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
ENDCASE
;;  BEAM:
CASE bfunc[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  BEGIN
    ;;  bi-Maxwellian beam
    IF (elec_on[0]) THEN def_b_param = def_bimax_eh ELSE def_b_param = def_bimax_ih
    ;;  Fix unused parameter
    def_binf[05].FIXED      = 1b
    def_b_param[05]         = 2
    def_binf[05].VALUE      = 2
  END
  'KK'  :  BEGIN
    ;;  bi-kappa beam
    IF (elec_on[0]) THEN def_b_param = def_bikap_eh ELSE def_b_param = def_bikap_ih
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
    IF (elec_on[0]) THEN def_b_param = def_bi_ss_eh ELSE def_b_param = def_bi_ss_ih
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
    IF (elec_on[0]) THEN def_b_param = def_bi_as_eh ELSE def_b_param = def_bi_as_ih
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
ENDCASE
;;  Redefine default parameter array
def_param               = def_c_param
def_haram               = def_h_param
def_bparm               = def_b_param
;;----------------------------------------------------------------------------------------
;;  Check limits against default values
;;----------------------------------------------------------------------------------------
FOR j=0L, np[0] - 1L DO BEGIN
  ;;  Core
  IF (def_pinf[j].LIMITED[0]) THEN def_param[j] = def_param[j] > def_pinf[j].LIMITS[0]
  IF (def_pinf[j].LIMITED[1]) THEN def_param[j] = def_param[j] < def_pinf[j].LIMITS[1]
  ;;  Halo
  IF (def_hinf[j].LIMITED[0]) THEN def_haram[j] = def_haram[j] > def_hinf[j].LIMITS[0]
  IF (def_hinf[j].LIMITED[1]) THEN def_haram[j] = def_haram[j] < def_hinf[j].LIMITS[1]
  ;;  Beam
  IF (def_binf[j].LIMITED[0]) THEN def_bparm[j] = def_bparm[j] > def_binf[j].LIMITS[0]
  IF (def_binf[j].LIMITED[1]) THEN def_bparm[j] = def_bparm[j] < def_binf[j].LIMITS[1]
ENDFOR
;;  Define VALUE tag for PARINFO, HARINFO, and BARINFO structures
def_pinf.VALUE          = def_param
def_hinf.VALUE          = def_haram
def_binf.VALUE          = def_bparm
;;  Redefine ELECTRONS and IONS keywords for wrapping routine
electrons               = elec_on[0]
ions                    = ion__on[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END




















































































