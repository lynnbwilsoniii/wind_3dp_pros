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
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries and UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VPARA  :  [N]-Element array of velocities parallel to the quasi-static
;                           magnetic field direction [km/s]
;               VPERP  :  [N]-Element array of velocities perpendicular to the
;                           quasi-static magnetic field direction [km/s]
;               PARAM  :  [6]-Element array containing the following quantities:
;                           PARAM[0] = Number Density [cm^(-3)]
;                           PARAM[1] = Parallel Thermal Speed [km/s]
;                           PARAM[2] = Perpendicular Thermal Speed [km/s]
;                           PARAM[3] = Parallel Drift Speed [km/s]
;                           PARAM[4] = Perpendicular Drift Speed [km/s]
;                           PARAM[5] = Kappa Value
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Finished writing routine                          [05/31/2012   v1.0.0]
;             2)  Moved out of the ~/distribution_fit_LM_pro directory
;                                                                   [08/21/2012   v1.1.0]
;
;   NOTES:      
;               1)  The thermal speeds are the "most probable speeds" for each direction
;                     => V_tpara = SQRT(2*kB*T_para/m)
;               2)  User should not call this routine
;               3)  See also:  biselfsimilar.pro and bimaxwellian.pro
;
;  REFERENCES:  
;               1)  Mace, R.L. and R.D. Sydora (2010), "Parallel whistler instability in
;                      a plasma with an anisotropic bi-kappa distribution,"
;                      J. Geophys. Res. Vol. 115, doi:10.1029/2009JA015064.
;
;   CREATED:  05/30/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/21/2012   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION bikappa,vpara,vperp,param

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
me     = 9.10938291d-31    ; => Electron mass (kg) [2010 value]
mp     = 1.672621777d-27   ; => Proton mass (kg) [2010 value]
qq     = 1.602176565d-19   ; => Fundamental charge (C) [2010 value]
kB     = 1.3806488d-23     ; => Boltzmann Constant (J/K) [2010 value]
K_eV   = 1.1604519d4       ; => Factor [Kelvin/eV] [2010 value]
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 3) THEN BEGIN
  ; => no input???
  RETURN,0
ENDIF

np     = N_ELEMENTS(param)
IF (np LT 6) THEN BEGIN
  ; => bad input???
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;; => Calculate distribution
;;----------------------------------------------------------------------------------------
;; => Define parallel and perpendicular dimensions
nva        = N_ELEMENTS(vpara)
nve        = N_ELEMENTS(vperp)
kk         = param[5]          ;; kappa value
delta      = SQRT(2d0*(kk[0] - 3d0/2d0)/kk[0])
theta_para = delta[0]*param[1]/SQRT(2d0)        ;; [Eq. 2 in Mace and Sydora, (2010)]
theta_perp = delta[0]*param[2]/SQRT(2d0)        ;; [Eq. 2 in Mace and Sydora, (2010)]
gamma_rat  = GAMMA(kk[0] + 1d0)/GAMMA(kk[0] - 1d0/2d0)
factor     = param[0]/((!DPI*kk[0])^(3d0/2d0)*theta_para[0]*theta_perp[0]^2)
;;  Define the amplitude of the bi-Kappa
;;    [Note:  density has been added to amplitude for Eq. 1 in Mace and Sydora, (2010)]
amp        = factor[0]*gamma_rat[0]
velpa      = vpara - param[3]      ;;  Parallel velocity minus drift speed [km/s]
velpe      = vperp - param[4]      ;;  Parallel velocity minus drift speed [km/s]
power      = REPLICATE(d,nva,nve)  ;;  Power factor of bi-kappa
FOR j=0L, nva - 1L DO BEGIN
  vpar_rat   = (velpa[j]/(theta_para[0]*SQRT(kk[0])))^2
  vper_rat   = (velpe/(theta_perp[0]*SQRT(kk[0])))^2
  power[j,*] = (1d0 + vper_rat + vpar_rat[0])^(-1d0*(kk[0] + 1d0))
ENDFOR
;;  Define the bi-kappa [Eq. 1 in Mace and Sydora, (2010) with density added]
df         = amp[0]*power
;;----------------------------------------------------------------------------------------
;; => Return the total distribution
;;----------------------------------------------------------------------------------------

RETURN,df
END
