;+
;*****************************************************************************************
;
;  FUNCTION :   create_v2_aligned_rmat.pro
;  PURPOSE  :   This routine creates a rotation matrix from two input 3-vectors, where
;                 the new orthonormal basis components are defined by the following
;                 unit vectors:
;                   z  :  V2
;                   y  :  (V2 x V1)       = (z x V1)
;                   x  :  (V2 x V1) x V2  = (y x z)
;
;  CALLED BY:   
;               rot_v1_2_v2_aligned_basis.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               format_2d_vec.pro
;               unit_vec.pro
;               my_crossp_2.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               V1      :  [N,3]-Element [numeric] array of 3-vectors to rotate into
;                            the new orthonormal basis
;               V2      :  [N,3]-Element [numeric] array of 3-vectors about which V1
;                            will be rotated
;
;  EXAMPLES:    
;               rmat = create_v2_aligned_rmat(v1,v2)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Finished writing routine
;                                                                   [10/06/2015   v1.0.0]
;
;   NOTES:      
;               1)  See also:  rot_mat.pro
;               2)  This routine is meant to be used with apply_v2_aligned_rmat.pro and
;                     called by rot_v1_2_v2_aligned_basis.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/26/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/06/2015   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION create_v2_aligned_rmat,v1,v2

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, format_2d_vec, unit_vec, my_crossp_2
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
no_inpt_msg    = 'User must supply two 3-vectors each as an array of vectors'
badvfor_msg    = 'Incorrect input format:  V1 and V2 must be [N,3]-element [numeric] arrays of 3-vectors'
baddim__msg    = 'V1 and V2 must both have the same dimensions, as [N,3]-element arrays'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (is_a_number(v1,/NOMSSG) EQ 0) OR  $
                 (is_a_number(v2,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check vector formats
v1_2d          = format_2d_vec(v1)    ;;  If a vector, routine will force to [N,3]-elements, even if N = 1
v2_2d          = format_2d_vec(v2)
test           = ((N_ELEMENTS(v1_2d) LT 3) OR ((N_ELEMENTS(v1_2d) MOD 3) NE 0)) OR $
                 ((N_ELEMENTS(v2_2d) LT 3) OR ((N_ELEMENTS(v2_2d) MOD 3) NE 0))
IF (test[0]) THEN BEGIN
  MESSAGE,badvfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Make sure dimensions match
szdv1          = SIZE(v1_2d,/DIMENSIONS)
szdv2          = SIZE(v2_2d,/DIMENSIONS)
test           = (szdv1[0] NE szdv2[0]) OR (szdv1[1] NE szdv2[1])
IF (test[0]) THEN BEGIN
  MESSAGE,baddim__msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Input is good --> define rows of rotation matrix
;;
;;  each matrix is composed of unit vectors and is defined as:
;;
;;  _            _
;;  | cx  cy  cz |
;;  | bx  by  bz |
;;  | ax  ay  az |
;;  _            _
;;
;;  where c = (V2 x V1) x V2, b = (V2 x V1), and a = V2
;;----------------------------------------------------------------------------------------
v1_uvec        = unit_vec(v1_2d)
;;  Define first (bottom) row
a_uvec         = unit_vec(v2_2d)
;;  Define second (middle) row
b_uvec         = unit_vec(my_crossp_2(a_uvec,v1_uvec,/NOM))
;;  Define third (top) row
c_uvec         = unit_vec(my_crossp_2(b_uvec,a_uvec,/NOM))
;;  Define rotation matrices  =  [N,3,3]-element array where:
;;      R_MATS[j,*,0] = c_uvec[j,*]
;;      R_MATS[j,*,1] = b_uvec[j,*]
;;      R_MATS[j,*,2] = a_uvec[j,*]
r_mats         = [[[c_uvec]],[[b_uvec]],[[a_uvec]]]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,r_mats
END