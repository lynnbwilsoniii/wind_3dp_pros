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
;                           PARAM[5] = Self-Similar Exponent Value [only values ≥ 2]
;                                       [Default = 4]
;                                       {Note:  2 = bi-Maxwellian}
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Moved out of the ~/distribution_fit_LM_pro directory
;                                                                   [08/21/2012   v1.1.0]
;
;   NOTES:      
;               1)  The thermal speeds are the "most probable speeds" for each direction
;                     => V_tpara = SQRT(2*kB*T_para/m)
;               2)  User should not call this routine
;
;  REFERENCES:  
;               1)  Dum, C.T., R. Chodura, and D. Biskamp (1974), "Turbulent Heating and
;                      Quenching of the Ion Sound Instability," Phys. Rev. Lett. Vol. 32,
;                      doi:10.1103/PhysRevLett.32.1231.
;               2)  Dum, C.T. (1975), "Strong-turbulence theory and the transition from
;                      Landau to collisional damping," Phys. Rev. Lett. Vol. 35,
;                      doi:10.1103/PhysRevLett.35.947.
;
;   CREATED:  05/31/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/21/2012   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION biselfsimilar,vpara,vperp,param

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
pp         = param[5]*1d0          ;;  Exponent value
velpa      = vpara - param[3]      ;;  Parallel velocity minus drift speed [km/s]
velpe      = vperp - param[4]      ;;  Parallel velocity minus drift speed [km/s]
;; => Check whether exponent is even
test   = (pp[0] MOD 2) NE 0
IF (test) THEN BEGIN
  ;; => odd exponent
  ;;   => use |V|
  v_para = (ABS(velpa)/param[1])^pp[0]
  v_perp = (ABS(velpe)/param[2])^pp[0]
ENDIF ELSE BEGIN
  ;; => odd exponent
  ;;   => use (V)
  v_para = (velpa/param[1])^pp[0]
  v_perp = (velpa/param[2])^pp[0]
ENDELSE

;; factor = [2 Gamma{(1 + p)/p}]^(-3)
factor     = (2d0*GAMMA((1d0 + pp[0])/pp[0]))^(-3d0)
;; amp    = factor * [no/(V_tpara V_tperp^2)]
amp        = factor[0]*param[0]/(param[1]*param[2]^2)
expon      = REPLICATE(d,nva,nve)  ;;  Exponential factor of self-similar DF
FOR j=0L, nva - 1L DO BEGIN
  expon[j,*] = -1d0*(v_para[j] + v_perp)
;  expon[j,*] = -1d0*((velpa[j]/param[1])^pp[0] + (velpe/param[2])^pp[0])
ENDFOR
;;  Define the self-similar DF
df         = amp[0]*EXP(expon)
;;----------------------------------------------------------------------------------------
;; => Return the total distribution
;;----------------------------------------------------------------------------------------

RETURN,df
END
