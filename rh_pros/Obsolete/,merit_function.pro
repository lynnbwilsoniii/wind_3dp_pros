;+
;*****************************************************************************************
;
;  FUNCTION :   merit_function.pro
;  PURPOSE  :   Calculates the merit function of a set of K-Equations with N-data pairs.
;                 This routine is specific to the Rankine-Hugoniot solvers.
;
;  CALLED BY:   
;               rh_eq_solve.pro
;
;  CALLS:
;               
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               EQS   :  Structure with K-tags defining K-equations with N-data pairs
;               STDS  :  Structure with K-tags defining K-Std. Devs. with N-data pairs
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  04/27/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/27/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION merit_function,eqs,stds

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
test = (N_PARAMS() LT 2) OR (SIZE(eqs,/TYPE) NE 8) OR (SIZE(stds,/TYPE) NE 8)
IF (test) THEN RETURN,0      ; => Must be structures

tag_eq     = STRLOWCASE(TAG_NAMES(eqs))
kke        = N_TAGS(eqs)
tag_st     = STRLOWCASE(TAG_NAMES(stds))
kks        = N_TAGS(stds)
IF (kke NE kks) THEN RETURN,0      ; => Must have same # of elements
;-----------------------------------------------------------------------------------------
; => Define parameters
;-----------------------------------------------------------------------------------------
sz0        = SIZE(eqs.(0),/DIMENSIONS)
kk         = kke                   ; => # of equations
; => know that result should be [NN,MM]-element array, where:
;       NN = # of azimuthal angles [0 < phi   < 2 Pi]
;       MM = # of poloidal  angles [0 < theta <   Pi]
; => Also know that we should have ND-Data points
nd         = sz0[0]                ; => # of data pairs
nn         = sz0[1]                ; => # of azimuthal angles [0 < phi   < 2 Pi]
mm         = sz0[1]                ; => # of poloidal  angles [0 < theta <   Pi]




END