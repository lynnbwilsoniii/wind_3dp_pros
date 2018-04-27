;+
;*****************************************************************************************
;
;  FUNCTION :   core_bm_halo_bm_fit.pro
;  PURPOSE  :   Creates a velocity distribution function (VDF) that is constructed from
;                 the superposition of two VDFs, one for the cold, core (bi-Maxwellian)
;                 and one for the hot, halo (bi-Maxwellian) particles.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               core_halo_superpos_fit.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VPARA  :  [N]-Element [numeric] array of velocities parallel to the
;                           quasi-static magnetic field direction [km/s]
;               VPERP  :  [M]-Element [numeric] array of velocities orthogonal to the
;                           quasi-static magnetic field direction [km/s]
;               PARAM  :  [12]-Element [numeric] array where each element is defined by
;                           the following quantities:
;                           CORE:
;                             PARAM[0]  = Core Number Density [cm^(-3)]
;                             PARAM[1]  = Core Parallel Thermal Speed [km/s]
;                             PARAM[2]  = Core Perpendicular Thermal Speed [km/s]
;                             PARAM[3]  = Core Parallel Drift Speed [km/s]
;                             PARAM[4]  = Core Perpendicular Drift Speed [km/s]
;                             PARAM[5]  = *** Not Used Here ***
;                           HALO:
;                             PARAM[6]  = Halo Number Density [cm^(-3)]
;                             PARAM[7]  = Halo Parallel Thermal Speed [km/s]
;                             PARAM[8]  = Halo Perpendicular Thermal Speed [km/s]
;                             PARAM[9]  = Halo Parallel Drift Speed [km/s]
;                             PARAM[10] = Halo Perpendicular Drift Speed [km/s]
;                             PARAM[11] = *** Not Used Here ***
;               PDER   :  [12]-Element [numeric] array defining which partial derivatives
;                           of the 12 variable coefficients in PARAM to compute.  For
;                           instance, to take the partial derivative with respect to
;                           only the first and third coefficients, then do:
;                           PDER = [1,0,1,0,0,0,0,0,0,0,0,0]
;                           [Default = REPLICATE(1,12)]
;
;  OUTPUT:
;               PDER   :  On output, the routine returns an [N,M,12]-element [numeric]
;                           array containing the partial derivatives of Y with respect
;                           to each element of PARAM that were not set to zero in
;                           PDER on input.
;
;  EXAMPLES:    
;               [calling sequence]
;               cmmhmm = core_bm_halo_bm_fit(vpara, vperp, param, pder [,FF=ff] )
;
;  KEYWORDS:    
;               FF     :  Set to a named variable to return an [N,M]-element array of
;                           values corresponding to the evaluated function
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The thermal speeds are the "most probable speeds" for each direction
;                     --> V_tpara = SQRT(2*kB*T_para/m)
;               2)  User should not call this routine
;               3)  See also:  biselfsimilar_fit.pro, bikappa_fit.pro, bimaxwellian_fit.pro
;               4)  VDF = velocity distribution function
;               5)  The digamma function is slow as it computes a 30 million element
;                     array to ensure at least 7 digits of accuracy
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
;
;   CREATED:  04/06/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/06/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION core_bm_halo_bm_fit,vpara,vperp,param,pder,FF=ff

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_funcs      = ['MM','KK','SS']
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 3) THEN BEGIN
  ;;  no input???
  RETURN,0b
ENDIF

np             = N_ELEMENTS(param)
nva            = N_ELEMENTS(vpara)
nve            = N_ELEMENTS(vperp)
test           = (np[0] NE 12) OR (nva[0] LT 1) OR (nve[0] LT 1)
IF (test[0]) THEN BEGIN
  ;;  bad input???
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check PDER
IF (N_PARAMS() LT 3 OR N_ELEMENTS(pder) NE 12) THEN pder = REPLICATE(1,np)
;;----------------------------------------------------------------------------------------
;;  Calculate distribution
;;----------------------------------------------------------------------------------------
ff             = core_halo_superpos_fit(vpara,vperp,param,pder,FF=ff,CFUNC='MM',HFUNC='MM')
;;----------------------------------------------------------------------------------------
;;  Return the total distribution
;;----------------------------------------------------------------------------------------

RETURN,ff
END

