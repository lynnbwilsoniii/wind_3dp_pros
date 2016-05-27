;+
;*****************************************************************************************
;
;  FUNCTION :   rot_matrix_array_dfs.pro
;  PURPOSE  :   Creates an array of rotation matrices using two arrays of input
;                 vectors.  The rotation matrices can be consistent with the output
;                 of either cal_rot.pro or rot_mat.pro depending upon the user-
;                 specified keyword.
;
;  CALLED BY:   
;               rotate_esa_htr_structure.pro
;               rotate_3dp_htr_structure.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_3_vector.pro
;               unit_vec.pro
;               my_crossp_2.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VEC1      :  [N,3]-Element array of vectors defining the
;                              X-axis (cal_rot.pro) or Z-axis (rot_mat.pro) of
;                              the new coordinate basis
;               VEC2      :  [N,3]-Element array of vectors used to create the
;                              right-handed orthogonal basis
;
;  EXAMPLES:    
;               [calling sequence]
;               rotmat  = rot_matrix_array_dfs(v1, v2 [,/CAL_ROT])
;
;  KEYWORDS:    
;               CAL_ROT   :  If set, routine returns rotation matrices consistent with
;                              those returned by cal_rot.pro, otherwise the matrices
;                              are consistent with those returned by rot_mat.pro
;
;   CHANGED:  1)  Continued writing routine
;                                                                  [08/08/2012   v1.0.0]
;             2)  Cleaned up, added more documentation, and
;                   now calls is_a_3_vector.pro, and unit_vec.pro
;                                                                  [11/24/2015   v1.1.0]
;
;   NOTES:      
;               1)  User should not call this routine
;               2)  See also:  cal_rot.pro, rot_mat.pro
;               3)  The definition of the new coordinate basis is given below in within
;                     the routine
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/07/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/24/2015   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rot_matrix_array_dfs,vec1,vec2,CAL_ROT=calrot

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_3_vector, unit_vec, my_crossp_2
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
no_inpt_msg    = 'User must supply two 3-vectors each as an array of vectors'
badvfor_msg    = 'Incorrect input format:  VEC1 and VEC2 must be [N,3]-element [numeric] arrays of 3-vectors'
baddim__msg    = 'VEC1 and VEC2 must both have the same dimensions, as [N,3]-element arrays'
;;----------------------------------------------------------------------------------------
;;  Check input structure format
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN RETURN,0b

;;  Make sure inputs are both 3-vectors
test1          = is_a_3_vector(vec1,V_OUT=v10,/NOMSSG)
test2          = is_a_3_vector(vec2,V_OUT=v20,/NOMSSG)
test           = (test1[0] EQ 0) OR (test2[0] EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Make sure dimensions match
szdv1          = SIZE(v10,/DIMENSIONS)
szdv2          = SIZE(v20,/DIMENSIONS)
test           = (szdv1[0] NE szdv2[0]) OR (szdv1[1] NE szdv2[1])
IF (test[0]) THEN BEGIN
  MESSAGE,baddim__msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Input is good --> define parameters
;;----------------------------------------------------------------------------------------
szv            = SIZE(v10,/DIMENSIONS)
kk             = szv[0]                      ;; # of vectors
;;  Normalize vectors
v1             = unit_vec(v10)
v2             = unit_vec(v20)
;v1             = v1/(SQRT(TOTAL(v1^2,2L,/NAN)) # REPLICATE(1d0,3L))
;v2             = v2/(SQRT(TOTAL(v2^2,2L,/NAN)) # REPLICATE(1d0,3L))
;;----------------------------------------------------------------------------------------
;;  Define rotation to plane containing V1 and V2
;;----------------------------------------------------------------------------------------
v1xv2          = unit_vec(my_crossp_2(v1,v2,/NOM))     ;;  (V1 x V2)
v1xv2xv1       = unit_vec(my_crossp_2(v1xv2,v1,/NOM))  ;;  (V1 x V2) x V1
;v1xv2          = my_crossp_2(v1,v2,/NOM)     ;;  (V1 x V2)
;v1xv2          = v1xv2/(SQRT(TOTAL(v1xv2^2,2L,/NAN)) # REPLICATE(1d0,3L))        ;; renormalize
;v1xv2xv1       = my_crossp_2(v1xv2,v1,/NOM)  ;;  (V1 x V2) x V1
;v1xv2xv1       = v1xv2xv1/(SQRT(TOTAL(v1xv2xv1^2,2L,/NAN)) # REPLICATE(1d0,3L))  ;; renormalize
;;----------------------------------------------------------------------------------------
;;  Define rotation matrices
;;    -->  rotate vectors in input coordinate basis to new primed coordinate basis
;;
;;              Z'
;;              |
;;              |
;;              |
;;              |
;;              |
;;              |
;;              |
;;              |
;;              O --------------- Y'
;;             /
;;           /
;;         /
;;       /
;;     /
;;    X'
;;
;;            CAL_ROT = FALSE  --> Primed unit vectors are given by:
;;                   Z'  :  V1
;;                   Y'  :  (V1 x V2)       = (Z x V2)
;;                   X'  :  (V1 x V2) x V1  = (Y x Z)
;;
;;            CAL_ROT = TRUE  --> Primed unit vectors are given by:
;;                   X'  :  V1
;;                   Z'  :  (V1 x V2)       = (X x V2)
;;                   Y'  :  (V1 x V2) x V1  = (Z x X)
;;
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(calrot) THEN BEGIN
  ;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ;;  Define rotation matrices equivalent to cal_rot.pro
  ;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  rotm           = DBLARR(kk,3L,3L)            ;;  Rotation matrices
  rot_inv        = DBLARR(kk,3L,3L)            ;;  [K,3,3]-element array
  row1_inv       = v1                          ;;  [K,3]-Element array
  row2_inv       = v1xv2xv1                    ;;  [K,3]-Element array
  row3_inv       = v1xv2                       ;;  [K,3]-Element array
  rot_inv[*,0,*] = row1_inv
  rot_inv[*,1,*] = row2_inv
  rot_inv[*,2,*] = row3_inv
  ;; -> invert these
  FOR j=0L, kk - 1L DO BEGIN
    temp = LA_INVERT(REFORM(rot_inv[j,*,*]),/DOUBLE,STATUS=stat)
    IF (stat EQ 0) THEN rotm[j,*,*] = temp
  ENDFOR
  ;; Define output
  rotmat         = rotm
ENDIF ELSE BEGIN
  ;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ;;  Define rotation matrices equivalent to rot_mat.pro
  ;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  rotz           = DBLARR(kk,3L,3L)            ;;  Rotation matrices
  row1_inv       = v1xv2xv1                    ;;  [K,3]-Element array
  row2_inv       = v1xv2                       ;;  [K,3]-Element array
  row3_inv       = v1                          ;;  [K,3]-Element array
  rotz[*,*,0]    = row1_inv
  rotz[*,*,1]    = row2_inv
  rotz[*,*,2]    = row3_inv
  ;; Define output
  rotmat         = rotz
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return matrices to user
;;----------------------------------------------------------------------------------------

RETURN,rotmat
END
