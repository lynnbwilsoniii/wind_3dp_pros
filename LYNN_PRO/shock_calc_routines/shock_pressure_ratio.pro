;+
;*****************************************************************************************
;
;  FUNCTION :   shock_pressure_ratio.pro
;  PURPOSE  :   This routine numerically solves the shock pressure ratio for a magneto-
;                 sonic shock wave propagating at an oblique angle to the upstream
;                 average magnetic field.  An analytic expression can be found in
;                 Gurnett and Bhattacharjee, [2005], Equation 7.3.57.
;
;  CALLED BY:   
;               shock_entropy_change.pro
;
;  CALLS:
;               NA
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
;   CHANGED:  1)  Cleaned up a bit, but no major changes            [02/04/2013   v1.0.1]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               1)  Gurnett, D.A. and A. Bhattacharjee (2005), "Introduction to Plasma
;                      Physics:  With Space and Laboratory Applications," Cambridge
;                      University Press, Cambridge, UK, ISBN:0-521-36483-3.
;
;   CREATED:  12/10/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/04/2013   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION shock_pressure_ratio,n1,n2,te1,ti1,un1,bo1,thebn1,gam1

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

test1          = (N_ELEMENTS(n1) NE N_ELEMENTS(n2)) OR (N_ELEMENTS(te1) NE N_ELEMENTS(ti1))
test2          = (N_ELEMENTS(un1) NE N_ELEMENTS(bo1)) OR (N_ELEMENTS(thebn1) NE N_ELEMENTS(n1))
test3          = (N_ELEMENTS(n1) NE N_ELEMENTS(te1)) OR (N_ELEMENTS(n2) NE N_ELEMENTS(ti1))
test4          = (N_ELEMENTS(n1) NE N_ELEMENTS(bo1)) OR (N_ELEMENTS(n2) NE N_ELEMENTS(thebn1))
test5          = test1 OR test2 OR test3 OR test4

IF (test5) THEN RETURN,0
;;----------------------------------------------------------------------------------------
;; => Reform input
;;----------------------------------------------------------------------------------------
nou            = REFORM(n1)*1d6
nod            = REFORM(n2)*1d6
teu            = REFORM(te1)
tiu            = REFORM(ti1)
Unu            = REFORM(un1)
Bou            = REFORM(bo1)
the            = REFORM(thebn1)*!DPI/18d1
gg             = gam1[0]

cth            = COS(the)
sth            = SIN(the)
cth2           = cth^2
sth2           = sth^2
;;----------------------------------------------------------------------------------------
;; => Define factors in equation
;;----------------------------------------------------------------------------------------
dd             = nod/nou                               ;; shock strength or n2/n1
tt             = eV_to_J[0]*(teu + tiu)                ;; total upstream temperature [J]
rhou           = ((me[0] + mp[0])*nou)                 ;; upstream mass density [kg m^(-3)]
;vsu2           = tt*nou/rhou*(1d-3)^2            ;; upstream sound speed squared [(km/s)^2]
vsu2           = gg[0]*tt*nou/rhou*(1d-3)^2            ;; upstream sound speed squared [(km/s)^2]
vsu            = SQRT(vsu2)
vau            = ABS(Bou*1d-9)/SQRT(muo[0]*rhou)*1d-3  ;; upstream Alfven speed [km/s]
dva2           = dd*ABS(vau)^2

fac0           = gg[0]*(dd - 1d0)*Unu^2/(dd*vsu2)      ;; term multiplied by brackets
denom          = 2d0*(Unu^2 - dva2*cth2)^2             ;; denominator
numf1          = (dd + 1d0)*Unu^2 - 2d0*dva2*cth2      ;; numerator inside brackets
numf2          = dva2*sth2                             ;; rest of numerator
numer          = numf1*numf2                           ;; complete numerator
;;  Define term inside brackets
term1          = 1d0 - numer/denom
;;----------------------------------------------------------------------------------------
;; => Calculate pressure ratio
;;----------------------------------------------------------------------------------------
press_ratio    = 1d0 + fac0*term1
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,press_ratio
END