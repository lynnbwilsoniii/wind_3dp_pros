;+
;*****************************************************************************************
;
;  FUNCTION :   bimaxwellian.pro
;  PURPOSE  :   Creates a Bi-Maxwellian Distribution Function (MDF) from a user
;                 defined amplitude, thermal speed, and array of velocities to define
;                 the MDF at.  The only note to be careful of is to make sure the
;                 thermal speed and array of velocities have the same units.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               bimaxwellian.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
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
;                           PARAM[5] = *** Not Used Here ***
;
;  EXAMPLES:    
;               [calling sequence]
;               bimax = bimaxwellian(vpara, vperp, param)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Finished writing routine
;                                                                   [05/31/2012   v1.0.0]
;             2)  Moved out of the ~/distribution_fit_LM_pro directory and
;                   changed format of PARAM input
;                                                                   [08/21/2012   v1.1.0]
;             3)  Updated Man. page, cleaned up, and optimized a little
;                                                                   [04/02/2018   v1.1.1]
;             4)  Cleaned up and vectorized
;                                                                   [04/04/2018   v1.1.2]
;
;   NOTES:      
;               1)  The thermal speeds are the "most probable speeds" of a 1D Gaussian
;                     --> V_tpara = SQRT(2*kB*T_para/m)
;               2)  User should not call this routine
;               3)  See also:  biselfsimilar.pro and bikappa.pro
;               4)  VDF = velocity distribution function
;               5)  The use of 6 elements in PARAM is for consistency with other model
;                     VDF routines (e.g., bikappa.pro)
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
;   CREATED:  05/29/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/04/2018   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION bimaxwellian,vpara,vperp,param

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
  RETURN,0b
ENDIF

np             = N_ELEMENTS(param)
nva            = N_ELEMENTS(vpara)
nve            = N_ELEMENTS(vperp)
test           = (np[0] LT 6) OR (nva[0] LT 1) OR (nve[0] LT 1)
IF (test[0]) THEN BEGIN
  ;;  bad input???
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Calculate distribution
;;----------------------------------------------------------------------------------------
;;  Define the amplitude of the bi-Maxwellian [# cm^(-3) km^(-3) s^(+3)]
amp            = param[0]/(!DPI^(3d0/2d0)*param[1]*param[2]^2d0)
;;  Define velocities offset by drift speeds:  U_j = V_j - V_oj  [km/s]
uelpa          = vpara - param[3]      ;;  Parallel velocity minus drift speed [km/s]
uelpe          = vperp - param[4]      ;;  Perpendicular velocity minus drift speed [km/s]
;;  Convert to 2D
uelpa2d        = uelpa # REPLICATE(1d0,nve[0])
uelpe2d        = REPLICATE(1d0,nva[0]) # uelpe
;;  Define:  W_j = U_j/V_Tj
welpa2d        = uelpa2d/param[1]
welpe2d        = uelpe2d/param[2]
;;  Define exponent for bi-Maxwellian
expon          = -1d0*(welpa2d^2d0 + welpe2d^2d0)
;;  Define the 2D bi-Maxwellian VDF [# cm^(-3) km^(-3) s^(+3)]
df             = amp[0]*EXP(expon)
;;----------------------------------------------------------------------------------------
;;  Return the total distribution
;;----------------------------------------------------------------------------------------

RETURN,df
END
