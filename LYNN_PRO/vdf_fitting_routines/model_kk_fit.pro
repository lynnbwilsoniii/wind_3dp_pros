;+
;*****************************************************************************************
;
;  FUNCTION :   model_kk_fit.pro
;  PURPOSE  :   Creates a bi-kappa distribution function (KDF) from a user
;                 defined amplitude, thermal speed, and array of velocities.  The only
;                 note to be careful of is to make sure the thermal speed and array of
;                 velocities have the same units.  This function is symmetric in the
;                 exponent but not necessarily thermal speeds.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               fit_parm_fact_get_common.pro
;               lbw_digamma.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VPARA  :  [N]-Element [numeric] array of velocities parallel to the
;                           quasi-static magnetic field direction [km/s]
;               VPERP  :  [M]-Element [numeric] array of velocities orthogonal to the
;                           quasi-static magnetic field direction [km/s]
;               PARAM  :  [6]-Element [numeric] array where each element is defined by
;                           the following quantities:
;                           PARAM[0] = Number Density [cm^(-3)]
;                           PARAM[1] = Parallel Thermal Speed [km/s]
;                           PARAM[2] = Perpendicular Thermal Speed [km/s]
;                           PARAM[3] = Parallel Drift Speed [km/s]
;                           PARAM[4] = Perpendicular Drift Speed [km/s]
;                           PARAM[5] = Kappa Value
;               PDER   :  [6]-Element [numeric] array defining which partial derivatives
;                           of the 6 variable coefficients in PARAM to compute.  For
;                           instance, to take the partial derivative with respect to
;                           only the first and third coefficients, then do:
;                           PDER = [1,0,1,0,0,0]
;
;  OUTPUT:
;               PDER   :  On output, the routine returns an [N,M,6]-element [numeric]
;                           array containing the partial derivatives of Y with respect
;                           to each element of PARAM that were not set to zero in
;                           PDER on input.
;
;  EXAMPLES:    
;               [calling sequence]
;               bikap = model_kk_fit(vpara, vperp, param, pder [,FF=ff])
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
;               3)  See also:  biselfsimilar.pro, bimaxwellian.pro, and bikappa_fit.pro
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
;              12)  Markwardt, C. B. "Non-Linear Least Squares Fitting in IDL with
;                     MPFIT," in proc. Astronomical Data Analysis Software and Systems
;                     XVIII, Quebec, Canada, ASP Conference Series, Vol. 411,
;                     Editors: D. Bohlender, P. Dowler & D. Durand, (Astronomical
;                     Society of the Pacific: San Francisco), pp. 251-254,
;                     ISBN:978-1-58381-702-5, 2009.
;              13)  Moré, J. 1978, "The Levenberg-Marquardt Algorithm: Implementation and
;                     Theory," in Numerical Analysis, Vol. 630, ed. G. A. Watson
;                     (Springer-Verlag: Berlin), pp. 105, doi:10.1007/BFb0067690, 1978.
;              14)  Moré, J. and S. Wright "Optimization Software Guide," SIAM,
;                     Frontiers in Applied Mathematics, Number 14,
;                     ISBN:978-0-898713-22-0, 1993.
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
;              20)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      Astrophys. J. Suppl. 243(8), doi:10.3847/1538-4365/ab22bd, 2019.
;              21)  Wilson III, L.B., et al., "Supplement to: Electron energy partition
;                      across interplanetary shocks," Zenodo (data product),
;                      doi:10.5281/zenodo.2875806, 2019.
;
;   CREATED:  09/16/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/16/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION model_kk_fit,vpara,vperp,parm0,pder,FF=ff

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
zran           = [1d-2,101d0]                 ;;  Currently allowed range in readable ASCII file of digamma results
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 3) THEN BEGIN
  ;;  no input???
  RETURN,0
ENDIF

np             = N_ELEMENTS(parm0)
nva            = N_ELEMENTS(vpara)
nve            = N_ELEMENTS(vperp)
test           = (np[0] NE 6)
IF (test[0]) THEN BEGIN
  ;;  bad input???
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Load Common Block
;;----------------------------------------------------------------------------------------
par_facs       = fit_parm_fact_get_common(/GET_KK,STATUS=status,INITYES=inityes)
IF (status[0] AND inityes[0]) THEN param = par_facs*parm0 ELSE param = parm0
;;----------------------------------------------------------------------------------------
;;  Calculate distribution
;;----------------------------------------------------------------------------------------
kk             = param[5]              ;;  kappa value
;;  Ensure k ≥ 3/2
kk             = kk[0] > 3d0/2d0
;;  Define some kappa-dependent parameters
km32           = kk[0] - 3d0/2d0       ;;  k - 3/2
km12           = kk[0] - 1d0/2d0       ;;  k - 1/2
kp_1           = kk[0] + 1d0           ;;  k + 1
;;  Define velocities offset by drift speeds:  U_j = V_j - V_oj  [km/s]
uelpa          = vpara - param[3]      ;;  Parallel velocity minus drift speed [km/s]
uelpe          = vperp - param[4]      ;;  Perpendicular velocity minus drift speed [km/s]
;;  Convert to 2D
uelpa2d        = uelpa # REPLICATE(1d0,nve[0])
uelpe2d        = REPLICATE(1d0,nva[0]) # uelpe
;;  Define:  W_j = U_j/V_Tj
welpa2d        = uelpa2d/param[1]
welpe2d        = uelpe2d/param[2]
;;  Define factors for kappa VDF
factor0        = (1d0/(!DPI*km32[0]))^(3d0/2d0)
factor1        = GAMMA(kp_1[0])/GAMMA(km12[0])
factor2        = param[0]/(param[1]*param[2]^2d0)
factors        = factor0[0]*factor1[0]*factor2[0]
;;  Define velocity term:  (W_par^2 + W_per^2)/K32
velfact        = (welpa2d^2d0 + welpe2d^2d0)/km32[0]
;;  Define the 2D bi-kappa [Eq. 1 in Mace and Sydora, (2010) with density added]
ff             = factors[0]*(1d0 + velfact)^(-1d0*kp_1[0])
;;----------------------------------------------------------------------------------------
;;  Calculate partial derivatives of Z = H(A,B,C,F) {1 + (F-3/2)^(-1) [((X-D)/B)^2 + ((Y-E)/C)^2]}^(-(F-1))
;;    H(A,B,C,F) = [F/π(F-3/2)]^(3/2) A GG(F+1)/[F^(3/2) B C^2 GG(F-1/2)]
;;    GG(z)      = GAMMA(z)
;;    DG(z)      = GAMMA'(z)/GAMMA(z)  =  digamma function
;;    Let us define the following for brevity:
;;      K32 = F - 3/2
;;      K1m = F - 1/2
;;      K1p = F + 1/2
;;      K_1 = F + 1
;;      U_j = V_j - V_oj  =  {X,Y} - {D,E}
;;      W_j = U_j/V_Tj    =  ({X,Y} - {D,E})/{B,C}
;;      DEN = W_par^2 + W_per^2 + K32
;;
;;
;;    dZ/dA = Z/A
;;    dZ/dB = Z [2 K1p W_par^2 - W_per^2 - K32]/[B * DEN]
;;    dZ/dC = Z 2*[F W_per^2 - W_par^2 - K32]/[C * DEN]
;;    dZ/dD = Z 2*[W_par K_1]/[B * DEN]
;;    dZ/dE = Z 2*[W_per K_1]/[C * DEN]
;;    dZ/dF = Z { [(W_par^2 + W_per^2) K1m - K32*3/2]/[K32 * DEN] -
;;               ln| 1 + (W_par^2 + W_per^2)/K32 | + DG(K_1) - DG(K1m) }
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() GT 3) THEN BEGIN
  ;;  Save original (input) partial derivative settings
  requested      = pder
  ;;  Redefine partial derivative array
  pder           = MAKE_ARRAY(nva,nve,np,VALUE=vpara[0]*0)
  ;;  Define: DEN = W_par^2 + W_per^2 + K32
  denom          = (welpa2d^2d0 + welpe2d^2d0 + km32[0])
  FOR k=0L, np[0] - 1L DO BEGIN
    IF (requested[k] NE 0) THEN BEGIN
      CASE k[0] OF
        0     :  BEGIN
          ;;  dZ/dA = Z/A
          pder[*,*,k] = ff/param[0]
        END
        1     :  BEGIN
          ;;  dZ/dB = Z [2 K1p W_par^2 - W_per^2 - K32]/[B * DEN]
          pder[*,*,k] = ff*(2d0*kp_1[0]*welpa2d^2d0 - welpe2d^2d0 - km32[0])/(param[1]*denom)
        END
        2     :  BEGIN
          ;;  dZ/dC = Z 2*[F W_per^2 - W_par^2 - K32]/[C * DEN]
          pder[*,*,k] = ff*2d0*(kk[0]*welpe2d^2d0 - welpa2d^2d0 - km32[0])/(param[2]*denom)
        END
        3     :  BEGIN
          ;;  dZ/dD = Z 2*[W_par K_1]/[B * DEN]
          pder[*,*,k] = ff*2d0*welpa2d*kp_1[0]/(param[1]*denom)
        END
        4     :  BEGIN
          ;;  dZ/dE = Z 2*[W_per K_1]/[C * DEN]
          pder[*,*,k] = ff*2d0*welpe2d*kp_1[0]/(param[2]*denom)
        END
        5     :  BEGIN
          ;;  dZ/dF = Z { [(W_par^2 + W_per^2) K1m - K32*3/2]/[K32 * DEN] -
          ;;             ln| 1 + (W_par^2 + W_per^2)/K32 | + DG(K_1) - DG(K1m) }
          term0       = (welpa2d^2d0 + welpe2d^2d0)*km12[0] - 3d0*km32[0]/2d0
          term1       = term0/(km32[0]*denom)
          term2       = ALOG(ABS(1d0 + (welpa2d^2d0 + welpe2d^2d0)/km32[0]))
          ndg         = 30000000L
          test        = (kp_1[0] GT zran[0]) AND (kp_1[0] LT zran[1])
          IF (test[0]) THEN digkp_1 = lbw_digamma(kp_1[0],/READ_DG) ELSE digkp_1 = lbw_digamma(kp_1[0],N=ndg[0])
          test        = (km12[0] GT zran[0]) AND (km12[0] LT zran[1])
          IF (test[0]) THEN digkm12 = lbw_digamma(km12[0],/READ_DG) ELSE digkm12 = lbw_digamma(km12[0],N=ndg[0])
          term3       = digkp_1[0] - digkm12[0]
          term4       = term1 - term2 + term3[0]
          pder[*,*,k] = ff*term4
        END
        ELSE  :  ;;  Do nothing as this parameter is not used
      ENDCASE
    ENDIF
  ENDFOR
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return the total distribution
;;----------------------------------------------------------------------------------------

RETURN,ff
END



