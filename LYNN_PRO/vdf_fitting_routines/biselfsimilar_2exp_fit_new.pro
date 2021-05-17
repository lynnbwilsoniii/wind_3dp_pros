;+
;*****************************************************************************************
;
;  FUNCTION :   biselfsimilar_2exp_fit_new.pro
;  PURPOSE  :   Creates an anisotropic self-similar distribution function from a user
;                 defined amplitude, thermal speed, and array of velocities.  The only
;                 note to be careful of is to make sure the thermal speed and array
;                 of velocities have the same units.  This differs from the routine
;                 biselfsimilar_fit.pro in that the exponent for the parallel and
;                 perpendicular directions can vary and the perpendicular drift
;                 velocity is forced to zero.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               lbw_digamma.pro
;
;  REQUIRES:    
;               NA
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
;                           PARAM[4] = Self-Similar Exponent Value [only values ≥ 2] for
;                                       the parallel direction
;                                       [Default = 4]
;                                       {Note:  2 = bi-Maxwellian}
;                           PARAM[5] = Self-Similar Exponent Value [only values ≥ 2] for
;                                       the perpendicular direction
;                                       [Default = 4]
;                                       {Note:  2 = bi-Maxwellian}
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
;               biss2exp = biselfsimilar_2exp_fit_new(vpara, vperp, param, pder [,FF=ff])
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
;               3)  See also:  biselfsimilar.pro, bimaxwellian.pro, bikappa_fit.pro, and
;                     biselfsimilar_fit.pro
;               4)  VDF = velocity distribution function
;               5)  The digamma function is slow as it computes a 30 million element
;                     array to ensure at least 7 digits of accuracy.  Thus, to improve
;                     the speed, I created look-up tables of pre-computed values to
;                     which the routine can interpolate.
;               6)  If both PARAM[4] and PARAM[5] are set to 2, then the output will
;                     reduce to a bi-Maxwellian VDF
;               7)  Unlike the other *_fit.pro routines, this one does not allow the
;                     user to vary the perpendicular drift speed
;               8)  ***  This differs from biselfsimilar_2exp_fit.pro in the normalization
;                          constant of the model function, which in turn, affects the
;                          partial derivatives  ***
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
;               9)  http://mathworld.wolfram.com/GammaFunction.html
;              10)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      Astrophys. J. Suppl. 243(8), doi:10.3847/1538-4365/ab22bd, 2019a.
;              11)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: II.  Statistics," Astrophys. J. Suppl.
;                      245(24), doi:10.3847/1538-4365/ab5445, 2019b.
;              12)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: III. Analysis," Astrophys. J. 893(22),
;                      doi:10.3847/1538-4357/ab7d39, 2020.
;
;   CREATED:  05/13/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/13/2021   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION biselfsimilar_2exp_fit_new,vpara,vperp,param,pder,FF=ff

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
zran           = [1d-2,41d0]                 ;;  Currently allowed range in readable ASCII file of digamma results
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 3) THEN BEGIN
  ;;  no input???
  RETURN,0
ENDIF

np             = N_ELEMENTS(param)
nva            = N_ELEMENTS(vpara)
nve            = N_ELEMENTS(vperp)
test           = (np[0] NE 6)
IF (test[0]) THEN BEGIN
  ;;  bad input???
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Calculate distribution
;;----------------------------------------------------------------------------------------
;;  Define parallel and perpendicular exponents
pp             = ABS(param[4])*1d0          ;;  Parallel exponent value
qq             = ABS(param[5])*1d0          ;;  Perpendicular exponent value
pp             = pp[0] > 2                  ;;  Require  p ≥ 2
qq             = qq[0] > 2                  ;;  Require  q ≥ 2
;;  Define velocities offset by drift speeds:  U_j = V_j - V_oj  [km/s]
uelpa          = vpara - param[3]           ;;  Parallel velocity minus drift speed [km/s]
uelpe          = vperp                      ;;  Perpendicular velocity [km/s]
;;  Convert to 2D
uelpa2d        = uelpa # REPLICATE(1d0,nve[0])
uelpe2d        = REPLICATE(1d0,nva[0]) # uelpe
;;  Define:  W_j = U_j/V_Tj
welpa2d        = uelpa2d/param[1]
welpe2d        = uelpe2d/param[2]
;;  Check whether exponents are even
odd__p         = (pp[0] MOD 2) NE 0
IF (odd__p[0]) THEN BEGIN
  ;;  Odd exponent
  ;;   --> use |V|
  w_para         = (ABS(welpa2d))^pp[0]
ENDIF ELSE BEGIN
  ;;  Even exponent
  ;;   --> use (V)
  w_para         = (welpa2d)^pp[0]
ENDELSE
odd__q         = (qq[0] MOD 2) NE 0
IF (odd__q[0]) THEN BEGIN
  ;;  Odd exponent
  ;;   --> use |V|
  w_perp         = (ABS(welpe2d))^qq[0]
ENDIF ELSE BEGIN
  ;;  Even exponent
  ;;   --> use (V)
  w_perp         = (welpe2d)^qq[0]
ENDELSE
;;  Define normalization factor = (2π)^(-1) [Gamma{(1 + p)/p}]^(-1) [Gamma{(2 + q)/q}]^(-1)
factor         = 1d0/( 2d0*!DPI*GAMMA((1d0 + pp[0])/pp[0])*GAMMA((2d0 + qq[0])/qq[0]) )
;; Define amplitude = factor * [no/(V_tpara V_tperp^2)]  [# cm^(-3) km^(-3) s^(+3)]
amp            = factor[0]*param[0]/(param[1]*param[2]^2d0)
;;  Define exponent for bi-self-similar VDF
expon          = -1d0*(w_para + w_perp)
;;  Define the 2D bi-self-similar VDF [# cm^(-3) km^(-3) s^(+3)]
ff             = amp[0]*EXP(expon)
;;----------------------------------------------------------------------------------------
;;  Calculate partial derivatives of Z = H(A,B,C,E,F) EXP{-[((X-D)/B)^E + (Y/C)^F]}
;;    H(A,B,C,F) = A [GG(1 + 1/E)]^(-1) [GG(1 + 2/F)]^(-2)/[2π B C^(2)]
;;    GG(z)      = GAMMA(z)
;;    DG(z)      = GAMMA'(z)/GAMMA(z)  =  digamma function
;;    Let us define the following for brevity:
;;      U_j = V_j - V_oj  =  {X,Y} - {D,0}
;;      W_j = U_j/V_Tj    =  ({X,Y} - {D,0})/{B,C}
;;
;;
;;    dZ/dA = Z/A
;;    dZ/dB = Z [E W_par^(E) - 1]/B
;;    dZ/dC = Z [F W_per^(F) - 2]/C
;;    dZ/dD = Z [E W_par^(E-1)]/B
;;    dZ/dE = Z { [DG(1 + 1/E)/E^2] - W_par^(E) Ln|W_par| }
;;    dZ/dF = Z { [2 DG(1 + 2/F)/F^2] - W_per^(F) Ln|W_per|}
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() GT 3) THEN BEGIN
  ;;  Save original (input) partial derivative settings
  requested      = pder
  ;;  Redefine partial derivative array
  pder           = MAKE_ARRAY(nva,nve,np,VALUE=vpara[0]*0)
  FOR k=0L, np[0] - 1L DO BEGIN
    IF (requested[k] NE 0) THEN BEGIN
      CASE k[0] OF
        0     :  BEGIN
          ;;  dZ/dA = Z/A
          pder[*,*,k] = ff/param[0]
        END
        1     :  BEGIN
          ;;  dZ/dB = Z [E W_par^(E) - 1]/B
          pder[*,*,k] = ff*(pp[0]*w_para - 1d0)/param[1]
        END
        2     :  BEGIN
          ;;  dZ/dC = Z [F W_per^(F) - 2]/C
          pder[*,*,k] = ff*(qq[0]*w_perp - 2d0)/param[2]
        END
        3     :  BEGIN
          ;;  dZ/dD = Z [E W_par^(E-1)]/B
          even_t      = ((pp[0] - 1d0) MOD 2) EQ 0
          term0       = ABS(welpa2d)^(pp[0] - 1d0)
          pder[*,*,k] = ff*(pp[0]*term0)/param[1]
        END
        4     :  BEGIN
          ;;  dZ/dE = Z { [DG(1 + 1/E)/E^2] - W_par^(E) Ln|W_par| }
          ndg         = 30000000L
          zz          = (1d0 + pp[0])/pp[0]
          test        = (zz[0] GT zran[0]) AND (zz[0] LT zran[1])
          IF (test[0]) THEN dig = lbw_digamma(zz[0],/READ_DG) ELSE dig = lbw_digamma(zz[0],N=ndg[0])
          term0       = 1d0*dig[0]/pp[0]^2d0
          term1       = -1d0*w_para*ALOG(ABS(welpa2d))
          term2       = term0[0] + term1
          pder[*,*,k] = ff*term2
        END
        5     :  BEGIN
          ;;  dZ/dF = Z { [2 DG(1 + 2/F)/F^2] - W_per^(F) Ln|W_per|}
          ndg         = 30000000L
          zz          = (2d0 + qq[0])/qq[0]
          test        = (zz[0] GT zran[0]) AND (zz[0] LT zran[1])
          IF (test[0]) THEN dig = lbw_digamma(zz[0],/READ_DG) ELSE dig = lbw_digamma(zz[0],N=ndg[0])
          term0       = 2d0*dig[0]/qq[0]^2d0
          term1       = -1d0*w_perp*ALOG(ABS(welpe2d))
          term2       = term0[0] + term1
          pder[*,*,k] = ff*term2
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





























