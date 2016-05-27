;+
;*****************************************************************************************
;
;  FUNCTION :   vec_trans.pro
;  PURPOSE  :   Returns the transverse component of an input vector, V, with respect to
;                 a normal vector, n, given by:  v_t = (n x V) x n
;
;  CALLED BY:   
;               rh_eq_gen.pro
;
;  CALLS:
;               my_crossp_2.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               V  :  [N,3]-Element vector to find the transverse component of...
;               N  :  [N,3]-Element unit normal vector
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Removed renormalization of n                   [09/09/2011   v1.0.1]
;
;   NOTES:      
;               
;
;  REFERENCES:  
;               1)  Jackson, John David (1999), "Classical Electrodynamics,"
;                      Third Edition, John Wiley & Sons, Inc., New York, NY.,
;                      ISBN 0-471-30932-X
;
;   CREATED:  06/21/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/09/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION vec_trans,v,n

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f     = !VALUES.F_NAN
d     = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN RETURN,REPLICATE(d,3)

;-----------------------------------------------------------------------------------------
; => Define transverse component
;-----------------------------------------------------------------------------------------
v1    = REFORM(v)
n1    = REFORM(n)

; => v_tt = (n x V)
nxv   = my_crossp_2(n1,v1,/NOM)
; =>  v_t = (n x V) x n        [page 357 Eq. 8.22 of Jackson E&M 3rd Edition]
vt    = my_crossp_2(nxv,n1,/NOM)
RETURN,vt
END
