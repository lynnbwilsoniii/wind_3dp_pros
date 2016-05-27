;+
;*****************************************************************************************
;
;  FUNCTION :   mom_rotate.pro
;  PURPOSE  :   This program rotates a set of moment tensors due to the input rotation
;                 tensor, mrot.
;
;  CALLED BY: 
;               mom3d.pro
;
;  CALLS:
;               rotate_tensor.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               MOM   :  A 3D moment structure created by my_mom3d.pro
;               MROT  :  A 3x3 rotation matrix
;
;  EXAMPLES:    NA
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  Davin Larson created                    [??/??/????   v1.0.0]
;             2)  Re-wrote and cleaned up                 [04/13/2009   v1.1.0]
;             3)  Updated man page                        [06/17/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/17/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION mom_rotate, mom, mrot

mxm  = mom.MAXMOMENT
momr = mom
IF (mxm LE 0) THEN RETURN,momr
;-----------------------------------------------------------------------------------------
; => Rotate the 1st moment  [km/s cm^(-3)]
;-----------------------------------------------------------------------------------------
momr.NV = rotate_tensor(mom.NV,mrot)
IF (mxm LE 1) THEN RETURN,momr
;-----------------------------------------------------------------------------------------
; => Rotate the 2nd moment  [eV^(1/2) km/s cm^(-3)]
;-----------------------------------------------------------------------------------------
t2       = mom.NVV[mom.MAP_R2]
t2       = rotate_tensor(t2,mrot)
momr.NVV = t2[mom.MAP_V2]
IF (mxm LE 2) THEN RETURN,momr
;-----------------------------------------------------------------------------------------
; => Rotate the 3rd moment [eV km/s cm^(-3)]
;-----------------------------------------------------------------------------------------
t3        = mom.NVVV[mom.MAP_R3]
t3        = rotate_tensor(t3,mrot)
momr.NVVV = t3[mom.MAP_V3]
IF (mxm LE 3) THEN RETURN,momr
;-----------------------------------------------------------------------------------------
; => Rotate the 4th moment  [eV^(3/2) km/s cm^(-3)]
;-----------------------------------------------------------------------------------------
t4         = mom.NVVVV[mom.MAP_R4]
t4         = rotate_tensor(t4,mrot)
momr.NVVVV = t4[mom.MAP_V4]
IF (mxm LE 4) THEN RETURN,momr

RETURN,momr
END

