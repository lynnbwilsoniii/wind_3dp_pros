;+
;*****************************************************************************************
;
;  FUNCTION :   shock_entropy_change.pro
;  PURPOSE  :   This routine numerically solves the change in specific entropy across
;                 an oblique magnetosonic shock wave.  An analytic expression can be
;                 found in Gurnett and Bhattacharjee, [2005], Equation 7.3.56.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               shock_pressure_ratio.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               N[1,2]   :  [N]-Element array of [upstream,downstream] particle number
;                             densities [cm^(-3)]
;               T[e,i]1  :  [N]-Element array of [electron,ion] average upstream
;                             temperatures [eV]
;               UN1      :  [N]-Element array of upstream shock normal flow speed in
;                             the shock rest frame [km/s]
;               BO1      :  [N]-Element array of average upstream magnitude of the
;                             quasi-static magnetic field [nT]
;               THEBN1   :  [N]-Element array of angles [deg] between the average
;                             upstream quasi-static magnetic field and the shock
;                             normal vector
;               GAM1     :  Scalar defining the ratio of the specific heats, also known
;                             as the polytrope index
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  We use Equation 7.3.57 from Gurnett and Bhattacharjee, [2005] for the
;                     pressure ratio
;
;  REFERENCES:  
;               1)  Gurnett, D.A. and A. Bhattacharjee (2005), "Introduction to Plasma
;                      Physics:  With Space and Laboratory Applications," Cambridge
;                      University Press, Cambridge, UK, ISBN:0-521-36483-3.
;
;   CREATED:  12/10/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/10/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION shock_entropy_change,n1,n2,te1,ti1,un1,bo1,thebn1,gam1

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
epo            = 8.854187817d-12   ;; => Permittivity of free space (F/m)
muo            = 4d0*!DPI*1d-7     ;; => Permeability of free space (N/A^2 or H/m)
me             = 9.10938291d-31    ;; => Electron mass (kg) [2010 value]
mp             = 1.672621777d-27   ;; => Proton mass (kg) [2010 value]
qq             = 1.602176565d-19   ;; => Fundamental charge (C) [2010 value]
kB             = 1.3806488d-23     ;; => Boltzmann Constant (J/K) [2010 value]
K_eV           = 1.1604519d4       ;; => Factor [Kelvin/eV] [2010 value]
c              = 2.99792458d8      ;; => Speed of light in vacuum (m/s)
eV_to_J        = kB[0]*K_eV[0]     ;; => Conversion from eV to J
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 8) THEN RETURN,0
;;----------------------------------------------------------------------------------------
;; => Reform input
;;----------------------------------------------------------------------------------------
nou            = REFORM(n1)
nod            = REFORM(n2)
teu            = REFORM(te1)
tiu            = REFORM(ti1)
Unu            = REFORM(un1)
Bou            = REFORM(bo1)
the            = REFORM(thebn1)
gg             = gam1[0]
;;----------------------------------------------------------------------------------------
;; => Calculate pressure ratio
;;----------------------------------------------------------------------------------------
P2_P1          = shock_pressure_ratio(nou,nod,teu,tiu,Unu,Bou,the,gg[0])
;;----------------------------------------------------------------------------------------
;; => Define factors in equation
;;----------------------------------------------------------------------------------------
;;  Define the specific heat capacity at constant volume [J K^(-1) kg^(-1)]
fac0           = kB[0]/((me[0] + mp[0])*(gg[0] - 1d0))
;;  Define the ratio of densities to gamma power
dengam         = (nou/nod)^gg[0]
;;  Define term inside natural logarithm
term1          = ABS(P2_P1*dengam)
;;----------------------------------------------------------------------------------------
;; => Define specific entropy change [J K^(-1) kg^(-1)]
;;----------------------------------------------------------------------------------------
del_s          = fac0[0]*ALOG(term1)
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,del_s
END