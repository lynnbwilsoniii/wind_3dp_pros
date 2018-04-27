;+
;*****************************************************************************************
;
;  FUNCTION :   bimaxwellian_fit.pro
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
;               NA
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
;                           PARAM[4] = Perpendicular Drift Speed [km/s]
;                           PARAM[5] = *** Not Used Here ***
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
;               bimax = bimaxwellian_fit(vpara, vperp, param, pder [,FF=ff])
;
;  KEYWORDS:    
;               FF     :  Set to a named variable to return an [N,M]-element array of
;                           values corresponding to the evaluated function
;
;   CHANGED:  1)  Fixed Man. page and cleaned up
;                                                                   [04/05/2018   v1.0.1]
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
;               3)  Livadiotis, G. "Statistical origin and properties of kappa
;                      distributions," J. Phys.: Conf. Ser. 900(1), pp. 012014, 2017.
;               4)  Livadiotis, G. "Derivation of the entropic formula for the
;                      statistical mechanics of space plasmas,"
;                      Nonlin. Proc. Geophys. 25(1), pp. 77-88, 2018.
;               5)  Livadiotis, G. "Modeling anisotropic Maxwell-Jüttner distributions:
;                      derivation and properties," Ann. Geophys. 34(1),
;                      pp. 1145-1158, 2016.
;
;   CREATED:  04/04/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/05/2018   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION bimaxwellian_fit,vpara,vperp,param,pder,FF=ff

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
test           = (np[0] NE 6) OR (nva[0] LT 1) OR (nve[0] LT 1)
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
ff             = amp[0]*EXP(expon)
;;----------------------------------------------------------------------------------------
;;  Calculate partial derivatives of Z = A B^(-1) C^(-2) e^[-((X-D)/B)^2 - ((Y-E)/C)^2]
;;    dZ/dA = Z/A
;;    dZ/dB = Z {2 [((X-D)/B)^2 - 1]/B}
;;    dZ/dC = Z {2 [((Y-E)/C)^2 - 1]/C}
;;    dZ/dD = Z {2 [(X-D)/B^2]}
;;    dZ/dE = Z {2 [(Y-E)/C^2]}
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
          ;;  dZ/dB = Z {2 [((X-D)/B)^2 - 1]/B}
          pder[*,*,k] = ff*2d0*(welpa2d^2d0 - 1d0)/param[1]
        END
        2     :  BEGIN
          ;;  dZ/dC = Z {2 [((Y-E)/C)^2 - 1]/C}
          pder[*,*,k] = ff*2d0*(welpe2d^2d0 - 1d0)/param[2]
        END
        3     :  BEGIN
          ;;  dZ/dD = Z {2 [(X-D)/B^2]}
          pder[*,*,k] = ff*2d0*welpa2d/param[1]
        END
        4     :  BEGIN
          ;;  dZ/dE = Z {2 [(Y-E)/C^2]}
          pder[*,*,k] = ff*2d0*welpe2d/param[2]
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


















