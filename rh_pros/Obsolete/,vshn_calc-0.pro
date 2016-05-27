;+
;*****************************************************************************************
;
;  FUNCTION :   vshn_calc.pro
;  PURPOSE  :   Calculates the shock normal velocity in SC-frame using Equation 7
;                 from Koval and Szabo, [2008].
;
;  CALLED BY:   
;               rh_eq_chisq.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               RHO  :  2-Element array of mass densities [up,down]
;               V    :  [2,3]-Element array of velocities [up,down]
;               N    :  [N,3]-Element unit normal vectors
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
;               1)  User should not call this routine
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
;    LAST MODIFIED:  06/21/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION vshn_calc,rho,v,n

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 3) THEN RETURN,d

v1    = REFORM(v)        ; => Input velocity
n1    = REFORM(n)        ; => Input normal vector
nr    = N_ELEMENTS(REFORM(rho))
szv   = SIZE(v1,/DIMENSIONS)
szn   = SIZE(n1,/DIMENSIONS)
; => make sure V and N are [2,3]-element arrays and RHO is a 2-element array
test  = ((szv[1] NE 3) OR (szn[1] NE 3)) OR (szv[0] NE 2) OR (nr NE 2)
IF (test) THEN RETURN,d
;-----------------------------------------------------------------------------------------
; => Define parameters
;-----------------------------------------------------------------------------------------

; => Assume n = normal unit vector, so renormalize just in case rounding errors have
;      made it so (|n| NE 1)
nmag  = SQRT(TOTAL(n1^2,2L,/NAN)) # REPLICATE(1,3)  ; => [N,3]-Element array
n1    = n1/nmag

vup   = REFORM(v1[0,*])  ; => Upstream   velocity
vdn   = REFORM(v1[1,*])  ; => Downstream velocity
rhoup = rho[0]           ; => Upstream   mass density
rhodn = rho[1]           ; => Downstream mass density
;-----------------------------------------------------------------------------------------
; => Calculate difference across discontinuity
;-----------------------------------------------------------------------------------------
delrv = rhodn[0]*vdn - rhoup[0]*vup
delrh = rhodn[0]     - rhoup[0]
ratio = delrv/delrh[0]
; => calculate shock normal speed  [Eq. 7 of Koval and Szabo, [2008]]
vshn  = n1[*,0]*ratio[0] + n1[*,1]*ratio[1] + n1[*,2]*ratio[2]

RETURN,vshn
END
