;+
;*****************************************************************************************
;
;  FUNCTION :   theta_bn_errors.pro
;  PURPOSE  :   Given a normal and magnetic field vector with associated uncertainties,
;                 this routine will calculate the angle between the two vectors and
;                 propagate the uncertainties appropriately.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_dot_prod.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               N   :  [3]-Element array of normal vector components
;               DN  :  [3]-Element array of normal vector component uncertainties
;               B   :  [3]-Element array of magnetic field components [nT]
;               DB  :  [3]-Element array of magnetic field component uncertainties [nT]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;  REFERENCES:  
;               1)  Taylor, J.R. (1997), "An Introduction to Error Analysis:  The
;                     Study of Uncertainties in Physical Measurements," University
;                     Science Books, 55D Gate Five Road, Sausalito, CA 94965, USA.
;
;   CREATED:  10/13/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/13/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION theta_bn_errors,n,dn,b,db

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
n_n        = N_ELEMENTS(REFORM(n))
n_dn       = N_ELEMENTS(REFORM(dn))
n_b        = N_ELEMENTS(REFORM(b))
n_db       = N_ELEMENTS(REFORM(db))
test       = (n_n NE 3) OR (n_dn NE 3) OR (n_b NE 3) OR (n_db NE 3)
IF (test) THEN BEGIN
  errmsg = 'Incorrect input format...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;-----------------------------------------------------------------------------------------
; => Calculate |B| and ∂(|B|)
;-----------------------------------------------------------------------------------------
nv         = REFORM(n)
dnv        = REFORM(dn)
bv         = REFORM(b)
dbv        = REFORM(db)

bo         = SQRT(TOTAL(bv^2,/NAN))     ; => Bo [nT]
dbov       = DBLARR(3)
FOR j=0L, 2L DO BEGIN
  dbov[j] = (bv[j]*dbv[j]/bo[0])^2
ENDFOR
dbo        = SQRT(TOTAL(dbov,/NAN))     ; => uncertainty in Bo [nT]
;-----------------------------------------------------------------------------------------
; => Calculate (n . B) and ∂(n . B)
;-----------------------------------------------------------------------------------------
n_dot_b    = my_dot_prod(nv,bv,/NOM)    ; => (n . B) [nT]
dwx        = DBLARR(3)                  ; => ∂(n . B)_j [nT]
FOR j=0L, 2L DO BEGIN
  dwx[j] = ABS(nv[j]*bv[j])*SQRT((dnv[j]/nv[j])^2 + (dbv[j]/bv[j])^2)
ENDFOR
d_n_dot_b  = SQRT(TOTAL(dwx^2,/NAN))    ; => ∂(n . B) [nT]
;-----------------------------------------------------------------------------------------
; => Calculate (n . B)/|B| and ∂{(n . B)/|B|}
;-----------------------------------------------------------------------------------------
u_n_dot_b  = n_dot_b[0]/bo[0]           ; => (n . B)/|B|
du_n_dot_b = 0d0                        ; => ∂{ (n . B)/|B| }
du_n_dot_b = ABS(u_n_dot_b)*SQRT((d_n_dot_b[0]/n_dot_b[0])^2 + (dbo[0]/bo[0])^2)
;-----------------------------------------------------------------------------------------
; => Define :  zeta = [1 - {(n . B)/|B|}^2]^(-1/2)
;-----------------------------------------------------------------------------------------
zeta       = 1d0/SQRT(1d0 - u_n_dot_b[0]^2)
;-----------------------------------------------------------------------------------------
; => Define :  theta_Bn = Cos^(-1){x}
;           :  x = (n . B)/|B|
;
;           :  ∂{ theta_Bn } = ∂{ Cos^(-1){x} } = | d/dx[ Cos^(-1){x} ] | ∂x
;
;           :  d/dx[ Cos^(-1){x} ] = -1/[1 - x^2]^(1/2)
;           :  ∂x                  = ∂{(n . B)/|B|}
;-----------------------------------------------------------------------------------------
theta      = ACOS(u_n_dot_b)            ; => theta_Bn [radians]
dcosx      = 0d0                        ; => d/dx[ Cos^(-1){x} ]
dtheta     = 0d0                        ; => uncertainty in theta_Bn [radians]

dcosx      = -1d0*zeta[0]
dtheta     = ABS(dcosx[0])*du_n_dot_b[0]
;-----------------------------------------------------------------------------------------
; => Define Return Structure
;-----------------------------------------------------------------------------------------
tags       = ['N_DOT_B','U_N_DOT_B','THETA']
val1       = [n_dot_b[0], d_n_dot_b[0]]
val2       = [u_n_dot_b[0], du_n_dot_b[0]]
val3       = [theta[0], dtheta[0]]
struct     = CREATE_STRUCT(tags,val1,val2,val3)
;-----------------------------------------------------------------------------------------
; => Return Structure
;-----------------------------------------------------------------------------------------

RETURN, struct
END