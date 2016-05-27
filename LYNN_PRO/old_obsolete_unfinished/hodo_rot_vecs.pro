;+
;*****************************************************************************************
;
;  FUNCTION :   hodo_rot_vecs.pro
;  PURPOSE  :   This program takes two input angles, a start and end angle, and creates
;                 an array of angles in between these two angles at the specified
;                 times given by the user.  The angle arrays are created by linear
;                 interpolation and the user is returned a structure with both
;                 interpolated data and rotated interpolated data.  The structure
;                 also contains the rotation matricies used.
;
;  CALLED BY:   
;               tds_bfield.pro
;
;  CALLS:
;               interp.pro
;               my_dot_prod.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               TDS_T   :  [N,V]-Element array of TDS event times (Unix)
;               TDS_SA  :  N-Element array of start angles to rotate VEC1 by (deg)
;               TDS_EA  :  N-Element array of end angles to rotate VEC1 by (deg)
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               VEC1    :  Structure of vector data with format:  
;                           {X:[M-Element Unix time],Y:[M,3]-Element vector array}
;
;   NOTES:
;               If keyword VEC1 is not set, program will return a structure that
;                 contains the rotation matricies one would use to rotate a vector
;                 by those specified angles.
;
;   CHANGED:  1)  Updated man page                             [08/03/2009   v1.0.1]
;             2)  Added program:  my_dot_prod.pro and fixed rotation matrix 
;                   multiplication algorithm [previous version produced the correct
;                   rotated fields for the first data point, but the rest were copies
;                   of the first... NOT slowly varying values as originally desired]
;                                                              [10/21/2009   v2.0.0]
;             3)  Added program:  eulermat.pro and changed rotation matrix calculation
;                                                              [03/11/2010   v2.1.0]
;             4)  Fixed syntax typo which affected ONLY single TDS_T event inputs
;                                                              [03/15/2009   v2.1.1]
;
;   CREATED:  08/02/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/15/2009   v2.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION hodo_rot_vecs,tds_t,tds_sa,tds_ea,VEC1=vec1

;-----------------------------------------------------------------------------------------
; -Define dummy variables
;-----------------------------------------------------------------------------------------
f         = !VALUES.F_NAN
d         = !VALUES.D_NAN
nn        = 10L
; => Define dummy variables for return structure
strtags   = ['ROT_MAT','ROT_VEC1','GVEC1','GTIME1']
rot_mats  = REPLICATE(d,nn,3L,3L) ; => Dummy array for rotation matricies
rot_vec1  = REPLICATE(d,nn,3L)    ; => Dummy array for rotated VEC1
g_vec1    = REPLICATE(d,nn,3L)    ; => Dummy array for interpolated VEC1
g_time1   = REPLICATE(d,nn)       ; => Dummy array for interpolated VEC1 times
dummy     = CREATE_STRUCT(strtags,rot_mats,rot_vec1,g_vec1,g_time1)
;-----------------------------------------------------------------------------------------
; => Check time inputs
;-----------------------------------------------------------------------------------------
t_type    = SIZE(REFORM(tds_t),/N_DIMENSIONS)
CASE t_type[0] OF
  2    : BEGIN
    utx = REFORM(tds_t)
    nn  = N_ELEMENTS(utx[*,0])             ; -# of different input times
    nv  = N_ELEMENTS(REFORM(utx[0,*]))     ; -# of times for each input time
  END
  1    : BEGIN
    nn  = 1L                       ; -# of input times
    nv  = N_ELEMENTS(tds_t)
    utx = REFORM(tds_t,nn,nv)
  END
  ELSE : BEGIN
    MESSAGE,'Incorrect input format:  tds_t',/INFORMATIONAL,/CONTINUE
    RETURN,dummy
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Check angle inputs
;-----------------------------------------------------------------------------------------
sang      = REFORM(tds_sa)   ; => Array of start angles (deg)
eang      = REFORM(tds_ea)   ; => Array of end angles (deg)
nst       = N_ELEMENTS(sang)
nen       = N_ELEMENTS(eang)
gin       = (nn NE nst) OR (nn NE nen)
IF (gin) THEN RETURN,dummy
;-----------------------------------------------------------------------------------------
; => Linearly interpolate angles to fill in angles
;-----------------------------------------------------------------------------------------
CASE t_type[0] OF
  2    : BEGIN
    t_angs    = DBLARR(nn,nv)    ; => Array of interpolated angles between sang and eang
    FOR j=0L, nn - 1L DO BEGIN
      stutx       = MIN(utx[j,*],/NAN)
      enutx       = MAX(utx[j,*],/NAN)
      temp_time   = [stutx,enutx]
      temp_angs   = [sang[j],eang[j]]
      t_angs[j,*] = interp(temp_angs,temp_time,utx[j,*],/NO_EXTRAP)
    ENDFOR
  END
  1    : BEGIN
    stutx     = MIN(utx,/NAN)    ; => Start time
    enutx     = MAX(utx,/NAN)    ; => End time
    temp_time = [stutx,enutx]
    temp_angs = [sang,eang]
    t_angs    = DBLARR(nn)       ; => Array of interpolated angles between sang and eang
    t_angs    = REFORM(interp(temp_angs,temp_time,utx,/NO_EXTRAP))
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Check for VEC inputs
;-----------------------------------------------------------------------------------------
v1type = SIZE(vec1,/TYPE)
; => Check VEC1 format
IF (v1type NE 8L) THEN BEGIN
  v1    = {X:g_time1,Y:g_vec1}
  gtn1  = 0
  gttg1 = 0
ENDIF ELSE BEGIN
  tns  = STRLOWCASE(TAG_NAMES(vec1))
  gtn1 = (N_ELEMENTS(tns) EQ 2L) 
  IF (gtn1) THEN gttg1 = (tns[0] EQ 'x') AND (tns[1] EQ 'y') ELSE gttg1 = 0
  IF (gttg1) THEN BEGIN
    v1 = vec1
  ENDIF ELSE BEGIN
    v1    = {X:g_time1,Y:g_vec1}
    gtn1  = 0
    gttg1 = 0
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Interpolate VEC inputs to input times
;-----------------------------------------------------------------------------------------
CASE gttg1 OF
  1    : BEGIN
    tv1     = v1.Y
    tt1     = REFORM(v1.X)
  END
  ELSE : BEGIN
    MESSAGE,'Incorrect keyword format:  VECs',/INFORMATIONAL,/CONTINUE
    tt1     = REPLICATE(d,1000)
    tv1     = REPLICATE(d,1000,3L)
  END
ENDCASE

CASE t_type[0] OF
  2    : BEGIN
    t_vecx    = DBLARR(nn,nv)    ; => Array of interpolated VEC1_x values
    t_vecy    = DBLARR(nn,nv)    ; => Array of interpolated VEC1_y values
    t_vecz    = DBLARR(nn,nv)    ; => Array of interpolated VEC1_z values
    FOR j=0L, nn - 1L DO BEGIN
      in_time     = REFORM(utx[j,*])
      t_vecx[j,*] = interp(tv1[*,0],tt1,in_time,/NO_EXTRAP)
      t_vecy[j,*] = interp(tv1[*,1],tt1,in_time,/NO_EXTRAP)
      t_vecz[j,*] = interp(tv1[*,2],tt1,in_time,/NO_EXTRAP)
    ENDFOR
    t_vec = [[[t_vecx]],[[t_vecy]],[[t_vecz]]] ; => [nn,nv,3L]-Element array
  END
  1    : BEGIN
    t_vecx    = DBLARR(nn)       ; => Array of interpolated VEC1_x values
    t_vecy    = DBLARR(nn)       ; => Array of interpolated VEC1_y values
    t_vecz    = DBLARR(nn)       ; => Array of interpolated VEC1_z values
    in_time   = REFORM(utx)
    t_vecx    = interp(tv1[*,0],tt1,in_time,/NO_EXTRAP)
    t_vecy    = interp(tv1[*,1],tt1,in_time,/NO_EXTRAP)
    t_vecz    = interp(tv1[*,2],tt1,in_time,/NO_EXTRAP)
    t_vec     = [[t_vecx],[t_vecy],[t_vecz]]         ; => [nv,3L]-Element array
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Define Euler Matricies
;-----------------------------------------------------------------------------------------
scang   = t_angs*!DPI/18d1  ; => Convert angles to radians
CASE t_type[0] OF
  2    : BEGIN
    szc   = SIZE(scang,/DIMENSIONS)
    zeros = REPLICATE(0d0,szc[0],szc[1])
    nn    = szc[0]  ; => # of diff input times
    nv    = szc[1]  ; => # of samples/input time
  END
  1    : BEGIN
    szc   = SIZE(scang,/DIMENSIONS)
    zeros = REPLICATE(0d0,szc[0])
    nn    = 1
    nv    = szc[0]
  END
ENDCASE
ones    = zeros + 1d0

CASE t_type[0] OF
  2 : BEGIN
    ; => Rotation Matricies [3L,3L,# of samples/input time,# of diff input times]
    rot1 = DBLARR(3L,3L,nv,nn)  
    FOR k=0L, nn - 1L DO BEGIN
      FOR j=0L, nv - 1L DO BEGIN
        t_angle       = REFORM(scang[k,j])
        rot1[*,*,j,k] = eulermat(0d0,t_angle,0d0,RAD=1)
      ENDFOR
    ENDFOR
  END
  1 : BEGIN
    ; => Rotation Matricies [3L,3L,# of samples/input time]
    rot1  = DBLARR(3L,3L,nv)
    FOR j=0L, nv - 1L DO BEGIN
      t_angle       = REFORM(scang[j])
      rot1[*,*,j]   = eulermat(0d0,t_angle,0d0,RAD=1)
    ENDFOR
  END
ENDCASE
;stop
;-----------------------------------------------------------------------------------------
; => Rotate vectors
;-----------------------------------------------------------------------------------------
CASE t_type[0] OF
  2    : BEGIN
    ; => [# of diff input times, # of samples/input time, 3L]
    t_rot_vec = DBLARR(nn,nv,3L)      ; => [nn,nv,3L]-Element array
    FOR k=0L, nn - 1L DO BEGIN
      FOR j=0L, nv - 1L DO BEGIN
        temp_t_vec        = REFORM(t_vec[k,j,*])
        t_rot_mag         = SQRT(TOTAL(temp_t_vec^2,/NAN))
        ; => Normalize vectors
        t_vec2            = temp_t_vec/t_rot_mag[0]
        t_rot_vec[k,j,*]  = REFORM(REFORM(rot1[*,*,j,k]) ## t_vec2)
        t_rot_vec[k,j,*] *= t_rot_mag[0]
      ENDFOR
    ENDFOR
  END
  1    : BEGIN
    t_rot_mag       = SQRT(TOTAL(t_vec^2,2,/NAN)) # REPLICATE(1d0,3L)
    ; => Normalize vectors
    t_vec2          = t_vec/t_rot_mag
    ; => [# of diff input times, # of samples/input time, 3L]
    t_rot_vec       = DBLARR(nv,3)             ; => [nv,3L]-Element array
    FOR j=0L, nv - 1L DO BEGIN
      t_rot_vec[j,*] = REFORM(REFORM(rot1[*,*,j]) ## t_vec2[j,*])
    ENDFOR
    t_rot_vec[*,*] *= t_rot_mag
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Return relevant parameters to user
;-----------------------------------------------------------------------------------------
rot_str = CREATE_STRUCT(strtags,rot1,t_rot_vec,t_vec,utx)

RETURN,rot_str
END