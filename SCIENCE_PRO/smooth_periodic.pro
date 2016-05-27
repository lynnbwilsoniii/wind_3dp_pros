;+
;*****************************************************************************************
;
;  FUNCTION :   enlarge_periodic.pro
;  PURPOSE  :   Enlarges a 2D matrix by N-elements on each side assuming spherical
;                 boundary conditions.
;
;  CALLED BY:   
;               smooth_periodic.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               ORIG_IMAGE  :  2-Dimensional Matrix on the surface of a sphere to be
;                                enlarged
;               N           :  Scalar defining the number of elements to enlarge
;                                ORIG_IMAGE by on each side
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Davin Larson changed something...             [10/04/1995   v1.0.5]
;             2)  Re-wrote and cleaned up
;                   and removed dependence on dimen.pro and data_type.pro
;                                                               [09/25/2009   v1.1.0]
;
;   NOTES:      
;               1)  This should not be called by user
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/25/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION enlarge_periodic, orig_image, n

;-----------------------------------------------------------------------------------------
; => Check input format
;-----------------------------------------------------------------------------------------
IF (n LE 0) THEN RETURN,orig_image
;-----------------------------------------------------------------------------------------
; => Define default parameters
;-----------------------------------------------------------------------------------------
image     = orig_image
dim       = SIZE(image,/DIMENSIONS)
itype     = SIZE(image,/TYPE)
nx        = dim[0]     ; must be even
ny        = dim[1]
new_image = MAKE_ARRAY(DIMENSION=dim+2*n,TYPE=itype)
FOR i=0L, nx + 2L*n - 1L DO BEGIN
   FOR j=n, ny + n - 1L DO BEGIN
      new_image[i,j] = image[((i + nx - n) MOD nx),((j + ny - n) MOD ny)]
   ENDFOR
ENDFOR
; => Shift data values accordingly
FOR i=0L, n - 1L DO BEGIN
   sind_0              = 2L*n - i - 1L
   sind_1              = ny + 2L*n - i - 1L
   sind_2              = ny + i
   new_image[*,i]      = SHIFT( new_image[*,sind_0], nx/2L )
   new_image[*,sind_1] = SHIFT( new_image[*,sind_2], nx/2L )
ENDFOR

RETURN,new_image
END


;+
;*****************************************************************************************
;
;  FUNCTION :   smooth_periodic.pro
;  PURPOSE  :   Uses box car smoothing of a surface with sperical periodic boundary
;                 conditions.
;
;  CALLED BY:   
;               plot3d.pro
;
;  CALLS:
;               enlarge_periodic.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               OLD_IMAGE   :  2-Dimensional Matrix on the surface of a sphere to be
;                                smoothed
;               N           :  Scalar defining the size of boxcar averaging window
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Davin Larson changed something...             [10/04/1995   v1.0.5]
;             2)  Re-wrote and cleaned up
;                   and removed dependence on dimen.pro
;                   and added NAN and EDGE_TRUNCATE keywords to SMOOTH.PRO call
;                                                               [09/25/2009   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/25/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION smooth_periodic, old_image, n

;-----------------------------------------------------------------------------------------
; => Check input format
;-----------------------------------------------------------------------------------------
IF (n LE 0) THEN RETURN,old_image
;-----------------------------------------------------------------------------------------
; => Define default parameters
;-----------------------------------------------------------------------------------------
image = old_image
dim   = SIZE(image,/DIMENSIONS)
itype = SIZE(image,/TYPE)
nx    = dim[0]     ; must be even
ny    = dim[1]
;-----------------------------------------------------------------------------------------
; => Enlarge array
;-----------------------------------------------------------------------------------------
image = enlarge_periodic(image,n)
image = SMOOTH(image,2*n+1,/NAN,/EDGE_TRUNCATE)
;image = SMOOTH(image,2*n+1)
image = image[n:(nx + n - 1L),n:(ny + n - 1L)]

RETURN,image
END

