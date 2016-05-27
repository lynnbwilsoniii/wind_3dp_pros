;+
;*****************************************************************************************
;
;  FUNCTION :   rh_eqs_stds.pro
;  PURPOSE  :   Generates the standard deviations of the Rankine-Hugoniot equations
;                 from Koval and Szabo, [2008].
;
;  CALLED BY:   
;               
;
;  CALLS:
;               
;
;  REQUIRES:    
;               
;
;  INPUT:
;               RHO    :  [N,2]-Element [up,down] array corresponding to the number
;                           density [cm^(-3)]
;               VSW    :  [N,3,2]-Element [up,down] array corresponding to the solar wind
;                           velocity vectors [SC-frame, km/s]
;               MAG    :  [N,3,2]-Element [up,down] array corresponding to the ambient
;                           magnetic field vectors [nT]
;               TOT    :  [N,2]-Element [up,down] array corresponding to the total plasma
;                           temperature [eV]
;               PHI    :  Scalar value defining the azimuthal angle [deg] of the shock
;                           normal vector [0 < phi < 2 Pi]
;               THE    :  Scalar value defining the poloidal  angle [deg] of the shock
;                           normal vector [0 < the <   Pi]
;               VSH    :  Scalar shock normal velocity [km/s] in SC-frame
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               *************************************************************************
;               **Note:  the default is to take the standard deviation of the input
;                           data for each shock region and define each keyword element
;                           accordingly
;               *************************************************************************
;               SIGR   :  [N,2]-Element array of standard deviations corresponding to
;                           each number density data point [cm^(-3)]
;               SIGV   :  [N,3,2]-Element array of standard deviations corresponding to
;                           each solar wind velocity vector [SC-frame, km/s]
;               SIGB   :  [N,3,2]-Element array of standard deviations corresponding to
;                           each ambient magnetic field vector [nT]
;               SIGT   :  [N,2]-Element array of standard deviations corresponding to
;                           each total plasma temperature data point [eV]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;  REFERENCES:  
;               1)  Vinas, A.F. and J.D. Scudder (1986), "Fast and Optimal Solution to
;                      the 'Rankine-Hugoniot Problem'," J. Geophys. Res. 91, pp. 39-58.
;               2)  A. Szabo (1994), "An improved solution to the 'Rankine-Hugoniot'
;                      problem," J. Geophys. Res. 99, pp. 14,737-14,746.
;               3)  Koval, A. and A. Szabo (2008), "Modified 'Rankine-Hugoniot' shock
;                      fitting technique:  Simultaneous solution for shock normal and
;                      speed," J. Geophys. Res. 113, pp. A10110.
;
;   CREATED:  05/01/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/01/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_eqs_stds, rho, vsw, mag, tot, phi, the, vsh, $
                      SIGR=sigr, SIGV=sigv, SIGB=sigb, SIGT=sigt

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
K_eV       = 1.160474d4        ; => Conversion = degree Kelvin/eV
kB         = 1.3806504d-23     ; => Boltzmann Constant (J/K)
qq         = 1.60217733d-19    ; => Fundamental charge (C) [or = J/eV]
me         = 9.1093897d-31     ; => Electron mass [kg]
mp         = 1.6726231d-27     ; => Proton mass [kg]
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
ni         = REFORM(rho)
bo         = REFORM(mag)
vo         = REFORM(vsw)
vs         = REFORM(vsh[0])
te         = REFORM(tot)
sz         = SIZE(ni,/DIMENSIONS)
nd         = sz[0]                ; => # of data points
dumv       = REPLICATE(1d0,nd,3L,2L)
dums       = REPLICATE(1d0,nd,2L)

IF ~KEYWORD_SET(sigr) THEN sgr = dums ELSE sgr = sigr
IF ~KEYWORD_SET(sigv) THEN sgv = dumv ELSE sgv = sigv
IF ~KEYWORD_SET(sigb) THEN sgb = dumv ELSE sgb = sigb
IF ~KEYWORD_SET(sigt) THEN sgt = dums ELSE sgt = sigt
; => Do a test for now and let things get more complicated later








END