;+
;*****************************************************************************************
;
;  FUNCTION :   vec_2d_cross.pro
;  PURPOSE  :   This routine calculates the cross-product between two arrays of vectors.
;
;  CALLED BY:   
;               vec_cross.pro
;               vec_trans.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               V1  :  [N,3]-Element array of vectors
;               V2  :  [N,3]-Element array of vectors
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This routine should not be called by user
;
;   CREATED:  07/11/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/11/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION vec_2d_cross,v1,v2

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f     = !VALUES.F_NAN
d     = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Calculate Cross-Product
;-----------------------------------------------------------------------------------------
a     = REFORM(v1)
b     = REFORM(v2)

axb_x = a[*,1]*b[*,2] - a[*,2]*b[*,1]
axb_y = a[*,2]*b[*,0] - a[*,0]*b[*,2]
axb_z = a[*,0]*b[*,1] - a[*,1]*b[*,0]

axb   = [[axb_x],[axb_y],[axb_z]]
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,axb
END