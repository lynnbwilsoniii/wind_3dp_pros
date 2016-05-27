;+
;*****************************************************************************************
;
;  FUNCTION :   rotate_tensor.pro
;  PURPOSE  :   This program attempts to rotate an N-th rank tensor in 3-Dimensions.
;
;  CALLED BY: 
;               mom_rotate.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               TENS  :  An N-th Rank Tensor
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

FUNCTION rotate_tensor,tens,mrot

rtens = tens
rank  = SIZE(tens,/N_DIMENSIONS)  ; => # of dimensions of tensor array
dim   = SIZE(tens,/DIMENSIONS)    ; => All elements should be the same size
                                  ;     typically 3 (3 dimensions)
IF (rank LE 0) THEN RETURN,rtens
IF (rank EQ 1) THEN RETURN,TRANSPOSE(mrot ## rtens)

d   = dim[0]
ns  = d^(rank-1)
ind = SHIFT(INDGEN(rank),1)

FOR i = 0L, rank - 1L DO BEGIN
   rtens = REFORM(mrot ## REFORM(rtens,ns,d),dim)
   rtens = TRANSPOSE(rtens,ind)
ENDFOR

RETURN,rtens
END
