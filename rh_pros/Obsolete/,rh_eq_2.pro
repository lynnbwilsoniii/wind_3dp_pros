;+
;*****************************************************************************************
;
;  FUNCTION :   rh_eq_2.pro
;  PURPOSE  :   Computes the normal B-field conservation relation for an input set
;                 of data points and the gradients with respect to the shock normal
;                 angles [azimuthal,poloidal] and the shock speed.  These three
;                 variables are free parameters in the minimization of the merit
;                 function defined by the Rankine-Hugoniot equations from
;                 Koval and Szabo, [2008].
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
;               RHO   :  [N,2]-Element [up,down] array corresponding to the mass/number
;                          density [kg cm^(-3)]
;               VSW   :  [N,2,3]-Element [up,down] array corresponding to the solar wind
;                          velocity vectors [SC-frame, km/s]
;               MAG   :  [N,2,3]-Element [up,down] array corresponding to the ambient
;                          magnetic field vectors [nT]
;               TOT   :  [N,2]-Element [up,down] array corresponding to the total plasma
;                          temperature [eV]
;               PHI   :  Scalar value defining the azimuthal angle [deg] of the shock
;                          normal vector [0 < phi < 2 Pi]
;               THE   :  Scalar value defining the poloidal  angle [deg] of the shock
;                          normal vector [0 < the <   Pi]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               SIGS  :  [N,4,3]-Element array of standard deviations corresponding to
;                          the [N,4]-element array of input data arrays/vectors
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
;   CREATED:  04/27/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/27/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_eq_2, rho, vsw, mag, tot, phi, the, SIGS=sigs

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN




END
