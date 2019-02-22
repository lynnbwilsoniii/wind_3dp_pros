;+
;*****************************************************************************************
;
;  FUNCTION :   rot_v1_2_v2_aligned_basis.pro
;  PURPOSE  :   This routine creates an orthonormal basis from two input 3-vectors and
;                 then rotates V1 into the new basis, where the unit vector
;                 components are defined by:
;                   z  :  V2
;                   y  :  (V2 x V3)
;                   x  :  (V2 x V3) x V2
;                 where V3 is a single additional unit vector used to construct the
;                 orthogonal basis.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               format_2d_vec.pro
;               create_v2_aligned_rmat.pro
;               apply_v2_aligned_rmat.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               V1      :  [3]- or [N,3]-element [numeric] array of 3-vectors to rotate
;                            into the new orthonormal basis
;               V2      :  [3]- or [N,3]-element [numeric] array of 3-vectors about
;                            which V1 will be rotated
;
;  EXAMPLES:    
;               v1_v2_aligned = rot_v1_2_v2_aligned_basis(v1,v2,AVG_V2=avg_v2,NAN=nan)
;
;  KEYWORDS:    
;               AVG_V2  :  If set, routine uses the average of V2 over the interval of V1
;                            to create only one rotation instead of N rotations [faster]
;                            [Default = FALSE]
;               NAN     :  If set, the rotated V1 on output will contain zeros instead of
;                            NaNs on account of the results returned by the TOTAL.PRO
;                            function when the NAN keyword is set.
;                            [Default = FALSE]
;               DV3     :  Set to an indice of one of the three principal axes to use
;                            as the second vector to use in constructing the rotation
;                            matrices, which correspond to:
;                              1  :  { 1, 0, 0 }
;                              2  :  { 0, 1, 0 }
;                              3  :  { 0, 0, 1 }
;                            [Default = 1]
;               VEC3    :  [3]-Element [numeric] array defining a 3-vector to use instead
;                            of the default values for V3 as the 2nd vector in
;                            constructing the rotation matrices
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [09/27/2015   v1.0.0]
;             2)  Continued to write routine
;                                                                   [09/27/2015   v1.0.0]
;             3)  Finished writing routine
;                                                                   [10/06/2015   v1.0.0]
;
;   NOTES:      
;               1)  Rules:
;                     - If V1 is a [3]-element array --> then V2 must be the same
;                     - If V2 is a [3]-element array --> AVG_V2 = TRUE
;                     - If both V1 and V2 are arrays of 3-vectors
;                                                    --> must both be [N,3]-element arrays
;               3)  If both DV3 and VEC3 are set correctly, then VEC3 trumps DV3 in
;                     priority
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

FUNCTION rot_v1_2_v2_aligned_basis,v1,v2,AVG_V2=avg_v2,NAN=nan,DV3=dv3,VEC3=vec3

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, format_2d_vec, create_v2_aligned_rmat, $
                 apply_v2_aligned_rmat
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_v3_1       = [1d0,0d0,0d0]
def_v3_2       = [0d0,1d0,0d0]
def_v3_3       = [0d0,0d0,1d0]
test_v3        = [1,2,3]
;;  Dummy error messages
no_inpt_msg    = 'User must supply two 3-vectors either as single or arrays of vectors'
badvfor_msg    = 'Incorrect input format:  V1 and V2 must be [N,3]-element [numeric] arrays of 3-vectors'
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
;;----------------------------------------------------------------------------------------
;;  Determine if either or both are [N,3]-element arrays
;;----------------------------------------------------------------------------------------
szdv1          = SIZE(v1_2d,/DIMENSIONS)
szdv2          = SIZE(v2_2d,/DIMENSIONS)
test           = (N_ELEMENTS(v1_2d) EQ 3) OR (N_ELEMENTS(v2_2d) EQ 3)
IF (test[0]) THEN BEGIN
  ;;  At least one of them is only a [3]-element array
  test           = (N_ELEMENTS(v1_2d) EQ 3) AND (N_ELEMENTS(v2_2d) EQ 3)
  ;;  Regardless, set AVG_V2 keyword = TRUE
  avg_v2         = 1b
  IF (test[0]) THEN BEGIN
    ;;  Both are [3]-element arrays --> Leave as is...(?)
    v1_sz          = 1
    v2_sz          = 1
  ENDIF ELSE BEGIN
    ;;  Only one is a [3]-element array
    CASE 1 OF
      (N_ELEMENTS(v1_2d) EQ 3) : BEGIN  ;;  V1 is a [3]-element array
        v1_sz          = 1
        v2_sz          = 2
      END
      (N_ELEMENTS(v2_2d) EQ 3) : BEGIN  ;;  V2 is a [3]-element array
        v1_sz          = 2
        v2_sz          = 1
      END
    ENDCASE
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Both are 2D --> check number of elements
  test_n         = (szdv1[0] NE szdv2[0])
  IF (test[0]) THEN BEGIN       ;;  Force AVG_V2 = TRUE
    avg_v2 = 1b
    v2_sz  = N_ELEMENTS(szdv2)
  ENDIF ELSE v2_sz = 2
  v1_sz          = 2
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check AVG_V2
test           = (N_ELEMENTS(avg_v2) GT 0) AND KEYWORD_SET(avg_v2)
IF (test[0]) THEN avg_v2 = 1b ELSE avg_v2 = 0b
;;  Check DV3
test           = (N_ELEMENTS(dv3) EQ 1) AND is_a_number(dv3,/NOMSSG)
IF (test[0]) THEN test = (TOTAL(dv3[0] EQ test_v3) GT 0)
IF (test[0]) THEN BEGIN
  vv3            = REPLICATE(0d0,szdv1[0],3L)
  goodv3         = WHERE(dv3[0] EQ test_v3,gdv3)
  IF (gdv3 GT 0) THEN vv3[*,goodv3[0]] = 1d0 ELSE vv3[*,0] = 1d0
ENDIF ELSE vv3 = REPLICATE(1d0,szdv1[0]) # def_v3_1
;;  Check VEC3
test           = (N_ELEMENTS(vec3) EQ 3) AND is_a_number(vec3,/NOMSSG)
IF (test[0]) THEN vv3 = REPLICATE(1d0,szdv1[0]) # REFORM(vec3)
;;  Determine how to re-define V2
vv2            = REPLICATE(d,szdv1[0],3L)
CASE v2_sz[0] OF
  1     :  BEGIN                           ;;  V2 is 1D  -->  Does not matter
    tv2 = REFORM(v2_2d)
    FOR k=0L, 2L DO vv2[*,k] = tv2[k]
  END
  2     :  BEGIN                           ;;  V2 is 2D  -->  check if AVG_V2 = TRUE
    IF (avg_v2[0]) THEN BEGIN
      ;;  Average over 1st dimension
      tv2 = TOTAL(v2_2d,1,/NAN)/TOTAL(FINITE(v2_2d),1,/NAN)
      FOR k=0L, 2L DO vv2[*,k] = tv2[k]
    ENDIF ELSE BEGIN
      ;;  Use the input version of V2
      vv2 = v2_2d
    ENDELSE
  END
  ELSE  :  STOP                            ;;  should not happen --> debug
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Get rotation matrices
;;----------------------------------------------------------------------------------------
rmats          = create_v2_aligned_rmat(vv3,vv2)
IF (N_ELEMENTS(rmats) LT 9) THEN RETURN,0b     ;;  Failed!
;;----------------------------------------------------------------------------------------
;;  Apply rotation matrices [vectorized --> should be very fast]
;;----------------------------------------------------------------------------------------
v1_rot         = apply_v2_aligned_rmat(v1_2d,rmats,NAN=nan)
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
tags           = ['rot_matrices','rot_vectors']
struct         = CREATE_STRUCT(tags,rmats,v1_rot)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END
