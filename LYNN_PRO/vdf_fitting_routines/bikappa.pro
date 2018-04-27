;+
;*****************************************************************************************
;
;  FUNCTION :   bikappa.pro
;  PURPOSE  :   Creates a Bi-Kappa Distribution Function (KDF) from a user
;                 defined amplitude, thermal speed, and array of velocities to define
;                 the KDF at.  The only note to be careful of is to make sure the
;                 thermal speed and array of velocities have the same units.
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
;                           PARAM[5] = Kappa Value
;
;  EXAMPLES:    
;               [calling sequence]
;               bikap = bikappa(vpara, vperp, param)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Finished writing routine
;                                                                   [05/31/2012   v1.0.0]
;             2)  Moved out of the ~/distribution_fit_LM_pro directory
;                                                                   [08/21/2012   v1.1.0]
;             3)  Updated Man. page, cleaned up, and optimized a little
;                                                                   [04/03/2018   v1.1.1]
;             4)  Cleaned up and vectorized
;                                                                   [04/04/2018   v1.1.2]
;
;   NOTES:      
;               1)  The thermal speeds are the "most probable speeds" for each direction
;                     => V_tpara = SQRT(2*kB*T_para/m)
;               2)  User should not call this routine
;               3)  See also:  biselfsimilar.pro and bimaxwellian.pro
;               4)  VDF = velocity distribution function
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
;
;   CREATED:  05/30/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/04/2018   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION bikappa,vpara,vperp,param

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
kk             = param[5]              ;;  kappa value
;;  Ensure k ≥ 3/2
kk             = kk[0] > 3d0/2d0
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
df             = factors[0]*(1d0 + velfact)^(-1d0*kp_1[0])     ;;  [# cm^(-3) km^(-3) s^(+3)]
;;----------------------------------------------------------------------------------------
;;  Return the total distribution
;;----------------------------------------------------------------------------------------

RETURN,df
END
