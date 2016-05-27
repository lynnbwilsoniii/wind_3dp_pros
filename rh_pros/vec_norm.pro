;+
;*****************************************************************************************
;
;  FUNCTION :   vec_norm.pro
;  PURPOSE  :   Returns the normal component of an input vector, V, with respect to
;                 a normal vector, n, given by:  v_n = V . n
;
;  CALLED BY:   
;               rh_eq_gen.pro
;
;  CALLS:
;               vec_2d_dot.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               V  :  [N,3]-Element vector to find the normal component of...
;               N  :  [N,3]-Element unit normal vector
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Removed renormalization of n                   [09/09/2011   v1.0.1]
;             2)  Changed input                                  [09/10/2011   v1.1.0]
;             3)  No longer calls my_dot_prod.pro, now calls vec_2d_dot.pro
;                                                                [07/11/2012   v1.2.0]
;
;   NOTES:      
;               1)  This routine should not be called by user
;
;  REFERENCES:  
;               1)  Jackson, John David (1999), "Classical Electrodynamics,"
;                      Third Edition, John Wiley & Sons, Inc., New York, NY.,
;                      ISBN 0-471-30932-X
;
;   CREATED:  06/21/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/10/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION vec_norm,v,n

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN RETURN,REPLICATE(d,3)

;-----------------------------------------------------------------------------------------
; => Define normal component
;-----------------------------------------------------------------------------------------
v1    = v                    ; => [N,3]-Element array
n1    = n                    ; => [M,3]-Element array
mm    = N_ELEMENTS(n1[*,0])
nv    = N_ELEMENTS(v1[*,0])
test  = (mm NE nv)
IF (test) THEN BEGIN
  dm    = REPLICATE(1d0,mm)
  dv    = REPLICATE(1d0,nv)
  v1x   = v1[*,0] # dm               ; => [N,M]-Element array
  v1y   = v1[*,1] # dm               ; => [N,M]-Element array
  v1z   = v1[*,2] # dm               ; => [N,M]-Element array
  v1mn  = [[[v1x]],[[v1y]],[[v1z]]]  ; => [N,M,3]-Element array
  n1x   = dv # n1[*,0]               ; => [N,M]-Element array
  n1y   = dv # n1[*,1]               ; => [N,M]-Element array
  n1z   = dv # n1[*,2]               ; => [N,M]-Element array
  n1mn  = [[[n1x]],[[n1y]],[[n1z]]]  ; => [N,M,3]-Element array
  vn    = REPLICATE(d,nv,mm)         ; => [N,M]-Element array
  IF (mm GT nv) THEN BEGIN
    ; => loop through nv
    FOR j=0L, nv - 1L DO BEGIN
      nn0       = REFORM(n1mn[j,*,*])        ; => [M,3]-Element array
      vv0       = REFORM(v1mn[j,*,*])        ; => [M,3]-Element array
      ; =>  v_n = V . n        [page 357 Eq. 8.22 {n = z here} of Jackson E&M 3rd Edition]
      vn[j,*]   = vec_2d_dot(vv0,nn0)        ; => [M]-Element array
    ENDFOR
  ENDIF ELSE BEGIN
    ; => loop through mm
    FOR j=0L, mm - 1L DO BEGIN
      nn0       = REFORM(n1mn[*,j,*])        ; => [N,3]-Element array
      vv0       = REFORM(v1mn[*,j,*])        ; => [N,3]-Element array
      ; =>  v_n = V . n        [page 357 Eq. 8.22 {n = z here} of Jackson E&M 3rd Edition]
      vn[*,j]   = vec_2d_dot(vv0,nn0)        ; => [N]-Element array
    ENDFOR
  ENDELSE
ENDIF ELSE BEGIN
  ; => M = N
  ; =>  v_n = V . n        [page 357 Eq. 8.22 {n = z here} of Jackson E&M 3rd Edition]
  vn    = vec_2d_dot(v1,n1)
ENDELSE
;-----------------------------------------------------------------------------------------
; => Return normal vector
;-----------------------------------------------------------------------------------------

RETURN,vn
END
