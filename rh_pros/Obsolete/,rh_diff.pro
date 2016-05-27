;+
;*****************************************************************************************
;
;  FUNCTION :   rh_diff.pro
;  PURPOSE  :   Calculates the difference between two numbers.
;
;  CALLED BY:   
;               rh_eq_[j].pro  {j=1,2,...,6}
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               
;
;  INPUT:
;               XX  :  [N,2]-Element array of N-element upstream/downstream values to
;                        find the difference between
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
;               1)  This is specific to the Rankine-Hugoniot routines
;               2)  User should not call this routine
;
;   CREATED:  04/27/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/27/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_diff,xx

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
xo         = REFORM(xx)
sx         = SIZE(xo,/DIMENSIONS)
ngd        = sx EQ 2
IF (TOTAL(ngd,/NAN) NE 1) THEN RETURN,0
IF (ngd[1]) THEN xo = xo ELSE xo = TRANSPOSE(xo)
; => Find the difference between up and downstream
dx = xo[*,1] - xo[*,0]

RETURN,dx
END