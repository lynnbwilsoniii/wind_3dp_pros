;+
;*****************************************************************************************
;
;  FUNCTION :   generate_nvec.pro
;  PURPOSE  :   Generates an [N,N,3]-element array of possible normal vectors.
;
;  CALLED BY:   
;               rh_eq_solve.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NDAT  :  Scalar value defining the number of angles to use to
;                          generate the dummy array of possible normal vectors
;                          [Default = 100L]
;
;  EXAMPLES:    
;               test = generate_nvec(100)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  04/26/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/26/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION generate_nvec,ndat

;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() EQ 0) THEN ndat = 100L

nn        = ndat[0]
phi       = DINDGEN(nn)*(2d0*!DPI)/(nn - 1L)
theta     = DINDGEN(nn)*(1d0*!DPI)/(nn - 1L)
cth       = COS(theta)
sth       = SIN(theta)
cph       = COS(phi)
sph       = SIN(phi)
; => Generate dummy array of normals
gnorm     = DBLARR(nn,nn,3L)
FOR j=0L, nn - 1L DO BEGIN
  gnorm[j,*,*] = [[cth],[cph[j]*sth],[sph[j]*sth]]
ENDFOR

RETURN,gnorm
END