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
;               RHO  :  [N,2]-Element array of mass densities [up,down]
;               V    :  [N,3,2]-Element array of velocities [up,down]
;               N    :  [3]-Element unit normal vectors
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Changed input and output format so that N-shock normal speeds
;                   are calculated for each shock normal vector     [09/07/2011   v1.1.0]
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
;    LAST MODIFIED:  09/07/2011   v1.1.0
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
szr   = SIZE(rho,/DIMENSIONS)
szv   = SIZE(v1,/DIMENSIONS)
szn   = SIZE(n1,/DIMENSIONS)
; => make sure V is a [N,3,2]-element arrays and RHO is a 2-element array
test  = ((szv[1] NE 3) OR (szv[2] NE 2)) OR (szv[0] NE szr[0]) OR (szn[0] NE 3)
; => LBW III 09/07/2011
;test  = ((szv[1] NE 3) OR (szn[1] NE 3)) OR (szv[0] NE 2) OR (nr NE 2)
IF (test) THEN RETURN,d
;-----------------------------------------------------------------------------------------
; => Define parameters
;-----------------------------------------------------------------------------------------

; => Assume n = normal unit vector, so renormalize just in case rounding errors have
;      made it so (|n| NE 1)
;nmag  = SQRT(TOTAL(n1^2,2L,/NAN)) # REPLICATE(1,3)  ; => [N,3]-Element array
nmag  = NORM(n1)         ; => scalar
n1    = n1/nmag[0]

vup   = REFORM(v1[*,*,0])  ; => Upstream   velocity
vdn   = REFORM(v1[*,*,1])  ; => Downstream velocity
rhoup = rho[*,0]           ; => Upstream   mass density
rhodn = rho[*,1]           ; => Downstream mass density
;-----------------------------------------------------------------------------------------
; => Calculate difference across discontinuity
;-----------------------------------------------------------------------------------------
delrv = DBLARR(szv[0],3L)
delrh = DBLARR(szv[0],3L)
ratio = DBLARR(szv[0],3L)
; => Numerator
delrv[*,0] = rhodn*vdn[*,0] - rhoup*vup[*,0]
delrv[*,1] = rhodn*vdn[*,1] - rhoup*vup[*,1]
delrv[*,2] = rhodn*vdn[*,2] - rhoup*vup[*,2]
; => Denominator
delrh[*,0] = rhodn          - rhoup
delrh[*,1] = rhodn          - rhoup
delrh[*,2] = rhodn          - rhoup
;delrv = rhodn[0]*vdn - rhoup[0]*vup
;delrh = rhodn[0]     - rhoup[0]
;ratio = delrv/delrh[0]
ratio[*,0] = delrv[*,0]/delrh[*,0]
ratio[*,1] = delrv[*,1]/delrh[*,0]
ratio[*,2] = delrv[*,2]/delrh[*,0]
;-----------------------------------------------------------------------------------------
; => calculate shock normal speed  [Eq. 7 of Koval and Szabo, [2008]]
;-----------------------------------------------------------------------------------------
vshn  = n1[0]*ratio[*,0] + n1[1]*ratio[*,1] + n1[2]*ratio[*,2]

RETURN,vshn
END
