;+
;*****************************************************************************************
;
;  FUNCTION :   vec_cross.pro
;  PURPOSE  :   Returns the cross-product of an input vector, V, with another vector,
;                 n, given by:  n_x_V = (n x V)
;
;  CALLED BY:   
;               rh_eq_gen.pro
;
;  CALLS:
;               vec_2d_cross.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               N  :  [M,3]-Element unit normal vector
;               V  :  [N,3]-Element vector to find the transverse component of...
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  No longer calls my_crossp_2.pro, now calls vec_2d_cross.pro
;                                                                [07/11/2012   v1.1.0]
;
;   NOTES:      
;               1)  This routine should not be called by user
;
;   CREATED:  09/10/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/11/2012   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION vec_cross,n,v

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
  n_x_v = REPLICATE(d,nv,mm,3L)      ; => [N,M,3]-Element array
  IF (mm GT nv) THEN BEGIN
    ; => loop through nv
    FOR j=0L, nv - 1L DO BEGIN
      nn0          = REFORM(n1mn[j,*,*])      ; => [M,3]-Element array
      vv0          = REFORM(v1mn[j,*,*])      ; => [M,3]-Element array
      ; => v_tt = (n x V)
      n_x_v[j,*,*] = vec_2d_cross(nn0,vv0)
    ENDFOR
  ENDIF ELSE BEGIN
    ; => loop through mm
    FOR j=0L, mm - 1L DO BEGIN
      nn0          = REFORM(n1mn[*,j,*])      ; => [N,3]-Element array
      vv0          = REFORM(v1mn[*,j,*])      ; => [N,3]-Element array
      ; => v_tt = (n x V)
      n_x_v[*,j,*] = vec_2d_cross(nn0,vv0)
    ENDFOR
  ENDELSE
ENDIF ELSE BEGIN
  ; => M = N
  ; => v_tt = (n x V)
  n_x_v = vec_2d_cross(n1,v1)
ENDELSE
;-----------------------------------------------------------------------------------------
; => Return cross product
;-----------------------------------------------------------------------------------------

RETURN,n_x_v
END
