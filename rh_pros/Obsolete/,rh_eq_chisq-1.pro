;+
;*****************************************************************************************
;
;  FUNCTION :   rh_eq_chisq.pro
;  PURPOSE  :   Calculates the merit function from a given set of inputs.
;
;  CALLED BY:   
;               rh_solve_lmq.pro
;
;  CALLS:
;               vshn_calc.pro
;               rh_eq_gen.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               RHO     :  [N,2]-Element [up,down] array corresponding to the number
;                            density [cm^(-3)]
;               VSW     :  [N,3,2]-Element [up,down] array corresponding to the solar wind
;                            velocity vectors [SC-frame, km/s]
;               MAG     :  [N,3,2]-Element [up,down] array corresponding to the ambient
;                            magnetic field vectors [nT]
;               TOT     :  [N,2]-Element [up,down] array corresponding to the total plasma
;                            temperature [eV]
;               NOR     :  [3]-Element unit shock normal vectors
;               VSHN    :  [N]-Element array defining the shock normal velocities
;                            [km/s] in SC-frame
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               POLYT   :  Scalar value defining the polytrope index
;                            [Default = 5/3]
;               VSHOCK  :  Set to a named variable to return the shock normal speeds
;               SIGX    :  Set to a named variable to return the standard
;                            deviations of the solved equations
;
;   CHANGED:  1)  Changed input and output format so that N RH Eqs
;                   are calculated for each shock normal vector     [09/07/2011   v1.1.0]
;
;   NOTES:      
;               1)  Either M = 1 or N = 1
;               2)  User should not call this routine
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
;   CREATED:  06/21/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/07/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_eq_chisq,rho,vsw,mag,tot,nor,vshn,POLYT=polyt,VSHOCK=vshock,SIGX=sigx

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
ni         = REFORM(rho)          ; => [N,2]-Element array
bo         = REFORM(mag)          ; => [N,3,2]-Element array
vo         = REFORM(vsw)          ; => [N,3,2]-Element array
te         = REFORM(tot)          ; => [N,2]-Element array
sz         = SIZE(ni,/DIMENSIONS)
szv        = SIZE(vo,/DIMENSIONS)
szb        = SIZE(bo,/DIMENSIONS)
szt        = SIZE(te,/DIMENSIONS)
nd         = sz[0]                ; => should = N
test       = ((nd NE szv[0]) OR (nd NE szb[0]) OR (nd NE szt[0])) OR $
             ((szv[1] NE 3) OR (szb[1] NE 3))  OR ((szv[2] NE 2) OR (szb[2] NE 2))
;test       = (nd NE 2) OR (nd NE szv[1]) OR (nd NE szb[1])
IF (test) THEN RETURN,d

;-----------------------------------------------------------------------------------------
; => Calc. the Rankine-Hugoniot equations for given input
;-----------------------------------------------------------------------------------------
eq2    = rh_eq_gen(ni,vo,bo,te,nor,vshn,EQNUM=2,POLYT=polyt)  ; => Bn equation [Eq. 2 from Koval and Szabo, 2008]
eq3    = rh_eq_gen(ni,vo,bo,te,nor,vshn,EQNUM=3,POLYT=polyt)  ; => transverse momentum flux equation [Eq. 3 from Koval and Szabo, 2008]
eq4    = rh_eq_gen(ni,vo,bo,te,nor,vshn,EQNUM=4,POLYT=polyt)  ; => transverse electric field equation [Eq. 4 from Koval and Szabo, 2008]
eq5    = rh_eq_gen(ni,vo,bo,te,nor,vshn,EQNUM=5,POLYT=polyt)  ; => normal momentum flux equation [Eq. 5 from Koval and Szabo, 2008]
eq6    = rh_eq_gen(ni,vo,bo,te,nor,vshn,EQNUM=6,POLYT=polyt)  ; => energy flux equation [Eq. 6 from Koval and Szabo, 2008]
; => Define Std. Dev.
std    = DBLARR(9)      ; => STDDEV(eq[n])
std[0] = STDDEV(eq2[*,0],/NAN,/DOUBLE)
std[1] = STDDEV(eq3[*,0],/NAN,/DOUBLE)
std[2] = STDDEV(eq3[*,1],/NAN,/DOUBLE)
std[3] = STDDEV(eq3[*,2],/NAN,/DOUBLE)
std[4] = STDDEV(eq4[*,0],/NAN,/DOUBLE)
std[5] = STDDEV(eq4[*,1],/NAN,/DOUBLE)
std[6] = STDDEV(eq4[*,2],/NAN,/DOUBLE)
std[7] = STDDEV(eq5[*,0],/NAN,/DOUBLE)
std[8] = STDDEV(eq6[*,0],/NAN,/DOUBLE)
; => Return Std. Dev. to user
sigx   = std
;-----------------------------------------------------------------------------------------
; => Add up equation results for each set of points
;-----------------------------------------------------------------------------------------
n     = N_ELEMENTS(REFORM(vshn))
sum   = DBLARR(n)      ; =>  sum_{j=1}^{K} (Y_{j}(x_{i},a)/std[j]_{i})^{2}
; => Remember that eq3 and eq4 are vectors
sum   = (eq2[*,0]/std[0])^2 + $
        ((eq3[*,0]/std[1])^2 + (eq3[*,1]/std[2])^2 + (eq3[*,2]/std[3])^2) + $
        ((eq4[*,0]/std[4])^2 + (eq4[*,1]/std[5])^2 + (eq4[*,2]/std[6])^2) + $
        (eq5[*,0]/std[7])^2 + (eq6[*,0]/std[8])^2
;FOR j=0L, n - 1L DO BEGIN
;  sum[j] = (eq2[j,0]/std[0])^2 + $
;           ((eq3[j,0]/std[1])^2 + (eq3[j,1]/std[2])^2 + (eq3[j,2]/std[3])^2) + $
;           ((eq4[j,0]/std[4])^2 + (eq4[j,1]/std[5])^2 + (eq4[j,2]/std[6])^2) + $
;           (eq5[j,0]/std[7])^2 + (eq6[j,0]/std[8])^2
;ENDFOR
;-----------------------------------------------------------------------------------------
; => Return Chi-Squared to user
;-----------------------------------------------------------------------------------------
chisq = sum

RETURN,chisq
END
