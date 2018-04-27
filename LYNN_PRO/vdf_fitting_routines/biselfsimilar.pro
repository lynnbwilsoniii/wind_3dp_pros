;+
;*****************************************************************************************
;
;  FUNCTION :   biselfsimilar.pro
;  PURPOSE  :   Creates an anisotropic self-similar distribution function from a user
;                 defined amplitude, thermal speed, and array of velocities.  The only
;                 note to be careful of is to make sure the thermal speed and array
;                 of velocities have the same units.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               VPARA  :  [N]-Element [numeric] array of velocities parallel to the
;                           quasi-static magnetic field direction [km/s]
;               VPERP  :  [N]-Element [numeric] array of velocities orthogonal to the
;                           quasi-static magnetic field direction [km/s]
;               PARAM  :  [6]-Element [numeric] array where each element is defined by
;                           the following quantities:
;                           PARAM[0] = Number Density [cm^(-3)]
;                           PARAM[1] = Parallel Thermal Speed [km/s]
;                           PARAM[2] = Perpendicular Thermal Speed [km/s]
;                           PARAM[3] = Parallel Drift Speed [km/s]
;                           PARAM[4] = Perpendicular Drift Speed [km/s]
;                           PARAM[5] = Self-Similar Exponent Value [only values ≥ 2]
;                                       [Default = 4]
;                                       {Note:  2 = bi-Maxwellian}
;
;  EXAMPLES:    
;               [calling sequence]
;               biself = biselfsimilar(vpara, vperp, param)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Moved out of the ~/distribution_fit_LM_pro directory
;                                                                   [08/21/2012   v1.1.0]
;             2)  Updated Man. page, cleaned up, and optimized a little
;                                                                   [04/03/2018   v1.1.1]
;             3)  Cleaned up and vectorized
;                                                                   [04/04/2018   v1.1.2]
;             4)  Fixed a mistake in the velocity normalizations
;                                                                   [04/05/2018   v1.1.3]
;
;   NOTES:      
;               1)  The thermal speeds are the "most probable speeds" of a 1D Gaussian
;                     --> V_tpara = SQRT(2*kB*T_para/m)
;               2)  User should not call this routine
;               3)  See also:  bimaxwellian.pro and bikappa.pro
;               4)  VDF = velocity distribution function
;
;  REFERENCES:  
;               0)  Dum, C.T., R. Chodura, and D. Biskamp "Turbulent Heating and
;                      Quenching of the Ion Sound Instability," Phys. Rev. Lett. 32,
;                      doi:10.1103/PhysRevLett.32.1231, 1974.
;               1)  Dum, C.T. "Strong-turbulence theory and the transition from Landau
;                      to collisional damping," Phys. Rev. Lett. 35,
;                      doi:10.1103/PhysRevLett.35.947, 1975.
;               2)  Barnes, A. "Collisionless Heating of the Solar-Wind Plasma I. Theory
;                      of the Heating of Collisionless Plasma by Hydromagnetic Waves,"
;                      Astrophys. J. 154, pp. 751--759, 1968.
;               3)  Mace, R.L. and R.D. Sydora "Parallel whistler instability in a plasma
;                      with an anisotropic bi-kappa distribution," J. Geophys. Res. 115,
;                      pp. A07206, doi:10.1029/2009JA015064, 2010.
;               4)  Livadiotis, G. "Introduction to special section on Origins and
;                      Properties of Kappa Distributions: Statistical Background and
;                      Properties of Kappa Distributions in Space Plasmas,"
;                      J. Geophys. Res. 120, pp. 1607--1619, doi:10.1002/2014JA020825,
;                      2015.
;               5)  Jain, H.C. and S.R. Sharma "Effect of flat top electron distribution
;                      on the turbulent heating of a plasma," Beitraega aus der
;                      Plasmaphysik 19, pp. 19--24, 1979.
;               6)  Goldman, M.V. "Strong turbulence of plasma waves," Rev. Modern Phys.
;                      56(4), pp. 709--735, 1984.
;               7)  Horton, W., et al., "Ion-acoustic heating from renormalized
;                      turbulence theory," Phys. Rev. A 14(1), pp. 424--433, 1976.
;               8)  Horton, W. and D.-I. Choi "Renormalized turbulence theory for the
;                      ion acoustic problem," Phys. Rep. 49(3), pp. 273--410, 1979.
;
;   CREATED:  05/31/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/05/2018   v1.1.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION biselfsimilar,vpara,vperp,param

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
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
test           = (np[0] LT 6) OR (nva[0] LT 1) OR (nve[0] LT 1)
IF (test[0]) THEN BEGIN
  ;;  bad input???
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Calculate distribution
;;----------------------------------------------------------------------------------------
;;  Define parallel and perpendicular dimensions
pp             = param[5]*1d0          ;;  Exponent value
;;  Define velocities offset by drift speeds:  U_j = V_j - V_oj  [km/s]
uelpa          = vpara - param[3]      ;;  Parallel velocity minus drift speed [km/s]
uelpe          = vperp - param[4]      ;;  Perpendicular velocity minus drift speed [km/s]
;;  Convert to 2D
uelpa2d        = uelpa # REPLICATE(1d0,nve[0])
uelpe2d        = REPLICATE(1d0,nva[0]) # uelpe
;;  Define:  W_j = U_j/V_Tj
welpa2d        = uelpa2d/param[1]
welpe2d        = uelpe2d/param[2]
;;  Check whether exponent is even
test           = (pp[0] MOD 2) NE 0
IF (test[0]) THEN BEGIN
  ;;  Odd exponent
  ;;   --> use |V|
  w_para         = (ABS(welpa2d))^pp[0]
  w_perp         = (ABS(welpe2d))^pp[0]
ENDIF ELSE BEGIN
  ;;  Even exponent
  ;;   --> use (V)
  w_para         = (welpa2d)^pp[0]
  w_perp         = (welpe2d)^pp[0]
ENDELSE
;;  Define normalization factor = [2 Gamma{(1 + p)/p}]^(-3)
factor         = (2d0*GAMMA((1d0 + pp[0])/pp[0]))^(-3d0)
;; Define amplitude = factor * [no/(V_tpara V_tperp^2)]  [# cm^(-3) km^(-3) s^(+3)]
amp            = factor[0]*param[0]/(param[1]*param[2]^2d0)
;;  Define exponent for bi-self-similar VDF
expon          = -1d0*(w_para + w_perp)
;;  Define the 2D bi-self-similar VDF [# cm^(-3) km^(-3) s^(+3)]
df             = amp[0]*EXP(expon)
;;----------------------------------------------------------------------------------------
;;  Return the total distribution
;;----------------------------------------------------------------------------------------

RETURN,df
END
