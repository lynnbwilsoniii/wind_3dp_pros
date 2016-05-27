;+
;*****************************************************************************************
;
;  FUNCTION :   vshn_calc.pro
;  PURPOSE  :   Calculates the shock normal velocity in SC-frame using Equation 7
;                 from Koval and Szabo, [2008].  The result is an [N,M]-element array
;                 of shock normal speeds in the SC-frame, where N = # of input data
;                 pairs and M = # of dummy shock normal vectors.
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
;               N    :  [M,3]-Element unit normal vectors
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Changed input and output format so that N-shock normal speeds
;                   are calculated for each shock normal vector     [09/07/2011   v1.1.0]
;             2)  Vectorized routine                                [09/09/2011   v1.2.0]
;             3)  Now calls rh_resize.pro                           [09/10/2011   v1.3.0]
;
;   NOTES:      
;               1)  User should not call this routine
;               2)  SC  :  Spacecraft
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
;    LAST MODIFIED:  09/10/2011   v1.3.0
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

ni       = rho
v1       = v
n1       = n
rh_resize,RHO=ni,NPTS=n_r                      ; => NI   :  [N,2]-Element array
rh_resize,VSW=v1,NPTS=n_v                      ; => V1   :  [N,3,2]-Element array
rh_resize,NOR=n1,MNOR=m_n                      ; => N1   :  [M,3]-Element array
test     = (TOTAL(FINITE([n_r,n_v,m_n]),/NAN) NE 3) OR (n_r NE n_v)
IF (test) THEN RETURN,d
;-----------------------------------------------------------------------------------------
; => Define parameters
;-----------------------------------------------------------------------------------------
vup   = REFORM(v1[*,*,0])           ; => [N,3]-Element array of upstream velocities
vdn   = REFORM(v1[*,*,1])           ; => [N,3]-Element array of downstream velocities
rhoup = ni[*,0] # REPLICATE(1d0,3)  ; => [N,3]-Element array of upstream mass densities
rhodn = ni[*,1] # REPLICATE(1d0,3)  ; => [N,3]-Element array of downstream mass densities
;-----------------------------------------------------------------------------------------
; => Calculate difference across discontinuity
;-----------------------------------------------------------------------------------------
; => Numerator
delrv = rhodn*vdn - rhoup*vup       ; => [N,3]-Element array
; => Denominator
delrh = rhodn     - rhoup           ; => [N,3]-Element array
; => Ratio
ratio = delrv/delrh                 ; => [N,3]-Element array
;-----------------------------------------------------------------------------------------
; => Calculate shock normal speed  [Eq. 7 of Koval and Szabo, [2008]]
;-----------------------------------------------------------------------------------------
term0 = ratio[*,0] # n1[*,0]
term1 = ratio[*,1] # n1[*,1]
term2 = ratio[*,2] # n1[*,2]
vshn  = term0 + term1 + term2        ; => [N,M]-Element array
;-----------------------------------------------------------------------------------------
; => Return
;-----------------------------------------------------------------------------------------

RETURN,vshn
END
