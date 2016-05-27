;+
;*****************************************************************************************
;
;  FUNCTION :   field_rot.pro
;  PURPOSE  :   Calculates a rotation matrix used to rotate into field-aligned
;                 coordinates.  The first vector will be rotated to the new
;                 z'-axis and the second vector will rotate to the x'z'-plane
;
;  CALLED BY:   NA
;
;  CALLS:
;               my_crossp_2.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               T1  :  [n,3] or [3,n] element array of vectors
;                        {where : n=1, or 2, or 3,...}
;               T2  :  [n,3] or [3,n] element array of vectors
;
;  EXAMPLES:
;               x      = FLTARR(3,5)
;               x[0,*] = FINDGEN(5)*1.28*!PI - 34.2*(FINDGEN(5)+12.2)
;               x[1,*] = FINDGEN(5)*12.28*!PI - 3.2*(FINDGEN(5)+1.2)
;               x[2,*] = FINDGEN(5)*120.28*!PI - 78.2*(FINDGEN(5)+0.2)
;               x2     = [2.4,-33.11,29.8]
;               y2     = REPLICATE(1.,5) # x2
;               z      = field_rot(x,y2)
;
;  KEYWORDS:
;               NOMSSG  :  If set, the program will NOT print out a message about the
;                            running time of the program.  This is particularly useful
;                            when calling the program multiple times in a loop.
;
;   CHANGED:  1)  Eliminated dependence on my_magnitudes.pro [09/11/2008   v1.1.11]
;             2)  Changed normalization and rotation method [same functionality]
;                                                            [09/11/2008   v1.2.0]
;             3)  Fixed an error in my math                  [09/19/2008   v1.2.1]
;             4)  Updated man page                           [03/22/2009   v1.2.2]
;             5)  Added keyword:  NOMSSG                     [04/17/2009   v1.2.3]
;             6)  Changed some syntax and removed dependency on my_dimen_force.pro
;                                                            [09/17/2009   v1.3.0]
;
;   CREATED:  06/10/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/17/2009   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION field_rot,t1,t2,NOMSSG=nom


;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************

;-----------------------------------------------------------------------------------------
; => Create Dummy Structures
;-----------------------------------------------------------------------------------------
f     = !VALUES.F_NAN
d     = !VALUES.D_NAN
fake1 = REPLICATE(d,10,3)
dum   = CREATE_STRUCT('FA',fake1,'PERP',fake1)
;-----------------------------------------------------------------------------------------
; => Check array sizes
;-----------------------------------------------------------------------------------------
d1  = REFORM(t1)  ; -Prevent [1,3] arrays
d2  = REFORM(t2)

ds1 = SIZE(d1,/DIMENSIONS)          ; -# of elements in each dimension
ds2 = SIZE(d2,/DIMENSIONS)
bs1 = SIZE(d1,/N_DIMENSIONS)        ; -bs1 = 1 if d1 is 1D array, 2 if 2D
bs2 = SIZE(d2,/N_DIMENSIONS)
gs1 = WHERE(ds1 EQ 3L,g1,COMPLEMENT=bn1)
gs2 = WHERE(ds2 EQ 3L,g2,COMPLEMENT=bn2)
;-----------------------------------------------------------------------------------------
; => Reform input T1 array
;-----------------------------------------------------------------------------------------
CASE gs1[0] OF
  0L   : BEGIN
    IF (bs1[0] GT 1L) THEN BEGIN
      d3  = TRANSPOSE(d1)
      md3 = SQRT(TOTAL(d3^2,2L,/NAN))                   ; => Magnitude of vector
    ENDIF ELSE BEGIN
      d3  = REFORM(d1)
      md3 = SQRT(TOTAL(d3^2,/NAN))                      ; => Magnitude of vector
    ENDELSE
  END
  1L   : BEGIN
    d3  = REFORM(d1)
    IF (bs1[0] GT 1L) THEN BEGIN
      md3 = SQRT(TOTAL(d3^2,2L,/NAN))                   ; => Magnitude of vector
    ENDIF ELSE BEGIN
      md3 = SQRT(TOTAL(d3^2,/NAN))                      ; => Magnitude of vector
    ENDELSE
  END
  ELSE : BEGIN
    MESSAGE,'Incorrect input format: V1 (Must be [N,3] or [3,N] element array)',/INFORMATIONAL,/CONTINUE
    RETURN,dum
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Reform input T2 array
;-----------------------------------------------------------------------------------------
CASE gs2[0] OF
  0L   : BEGIN
    IF (bs2[0] GT 1L) THEN BEGIN
      d4  = TRANSPOSE(d2)
      md4 = SQRT(TOTAL(d4^2,2L,/NAN))                   ; => Magnitude of vector
    ENDIF ELSE BEGIN
      d4  = REFORM(d2)
      md4 = SQRT(TOTAL(d4^2,/NAN))                      ; => Magnitude of vector
    ENDELSE
  END
  1L   : BEGIN
    d4  = REFORM(d2)
    IF (bs2[0] GT 1L) THEN BEGIN
      md4 = SQRT(TOTAL(d4^2,2L,/NAN))                   ; => Magnitude of vector
    ENDIF ELSE BEGIN
      md4 = SQRT(TOTAL(d4^2,/NAN))                      ; => Magnitude of vector
    ENDELSE
  END
  ELSE : BEGIN
    MESSAGE,'Incorrect input format: V1 (Must be [N,3] or [3,N] element array)',/INFORMATIONAL,/CONTINUE
    RETURN,dum
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Check dimensions of input and rotate if both inputs are 1D arrays
;-----------------------------------------------------------------------------------------
ds1 = SIZE(d3,/DIMENSIONS)          ; -# of elements in each dimension
ds2 = SIZE(d4,/DIMENSIONS)
bs1 = SIZE(d3,/N_DIMENSIONS)        ; -bs1 = 1 if d1 is 1D array, 2 if 2D
bs2 = SIZE(d4,/N_DIMENSIONS)

test  = [(bs1[0] GT 1L),(bs2[0] GT 1L)]
gtest = WHERE(test,gst)
CASE gst OF
  1L   : BEGIN  ; => One is 2D
    IF (gtest[0] EQ 0L) THEN BEGIN
      d4  = REPLICATE(1.0,ds1[0]) # d4
      md4 = SQRT(TOTAL(d4^2,2L,/NAN))                   ; => Magnitude of vector
    ENDIF ELSE BEGIN
      d3  = REPLICATE(1.0,ds2[0]) # d3
      md3 = SQRT(TOTAL(d3^2,2L,/NAN))                   ; => Magnitude of vector
    ENDELSE
  END
  2L   :        ; => Both are 2D =>> don't change either
  0L   : BEGIN  ; => Both are 1D
    d5    = d3/md3[0]
    d6    = d4/md4[0]
    mrot  = rot_mat(d5,d6)
    f1    = REFORM(mrot ## d5)
    f2    = REFORM(mrot ## d6)
    ;-------------------------------------------------------------------------------------
    ; => Eliminate rounding errors (e.g. f1 should be // to Z'-Component) and Renormalize
    ;-------------------------------------------------------------------------------------
    ftest = f1*1d3
    badt  = WHERE(ABS(ftest) LT 1d-1,bd)
    IF (bd GT 0) THEN BEGIN
      f1[badt] = 0d0
      f1       = f1/ SQRT(f1[0]^2 + f1[1]^2 + f1[2]^2)  ; -Renormalize
    ENDIF
    ftest = f2*1d3
    badt  = WHERE(ABS(ftest) LT 1d-1,bd)
    IF (bd GT 0) THEN BEGIN
      f2[badt] = 0d0
      f2       = f2/ SQRT(f2[0]^2 + f2[1]^2 + f2[2]^2)
    ENDIF
    f1     *= md3[0]
    f2     *= md4[0]
    rot_str = CREATE_STRUCT('FA',f1,'PERP',f2)
    ;*************************************************************************************
    ex_time = SYSTIME(1) - ex_start
    IF NOT KEYWORD_SET(nom) THEN BEGIN
      MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
    ENDIF
    ;*************************************************************************************
    RETURN,rot_str
  END
  ELSE : BEGIN
    MESSAGE,'Incorrect input format: V1 AND V2 (Must be [N,3] or [3,N] element arrays)',/INFORMATIONAL,/CONTINUE
    RETURN,dum
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Both are 2D
;-----------------------------------------------------------------------------------------
d5    = [[d3[*,0]/md3],[d3[*,1]/md3],[d3[*,2]/md3]]
d6    = [[d4[*,0]/md4],[d4[*,1]/md4],[d4[*,2]/md4]]

ds1   = SIZE(d5,/DIMENSIONS)          ; -# of elements in each dimension
ds2   = SIZE(d6,/DIMENSIONS)
bs1   = SIZE(d5,/N_DIMENSIONS)        ; -bs1 = 1 if d1 is 1D array, 2 if 2D
bs2   = SIZE(d6,/N_DIMENSIONS)
; => Calculate rotation matrix
v1    = my_crossp_2(d5,d6,/NOMSSG)
; => Renormalize v1
v1mag = SQRT(TOTAL(v1^2,2L,/NAN))
v1    = REFORM([[v1[*,0]/v1mag],[v1[*,1]/v1mag],[v1[*,2]/v1mag]])
v2    = my_crossp_2(v1,d5,/NOMSSG)
; => Renormalize v2
v2mag = SQRT(TOTAL(v2^2,2L,/NAN))
v2    = REFORM([[v2[*,0]/v2mag],[v2[*,1]/v2mag],[v2[*,2]/v2mag]])
mrot  = [[[v2]],[[v1]],[[d5]]]
; => Rotate vectors
f1    = DBLARR(ds1[0],ds1[1])
f2    = DBLARR(ds2[0],ds2[1])
FOR j=0L, ds1[0] - 1L DO BEGIN
  f1[j,*] = REFORM(REFORM(mrot[j,*,*]) ## d5[j,*])
  f2[j,*] = REFORM(REFORM(mrot[j,*,*]) ## d6[j,*])
ENDFOR
;-----------------------------------------------------------------------------------------
; => Eliminate rounding errors (e.g. f1 should be // to Z'-Component) and Renormalize
;-----------------------------------------------------------------------------------------
ftest = f1*1d4
bad0  = WHERE(ABS(ftest[*,0]) LT 1d0,bd0,COMPLEMENT=good0)
bad1  = WHERE(ABS(ftest[*,1]) LT 1d0,bd1,COMPLEMENT=good1)
bad2  = WHERE(ABS(ftest[*,2]) LT 1d0,bd2,COMPLEMENT=good2)
IF (bad0[0] NE -1L) THEN f1[bad0,0] = 0d0
IF (bad1[0] NE -1L) THEN f1[bad1,1] = 0d0
IF (bad2[0] NE -1L) THEN f1[bad2,2] = 0d0

ftest = f2*1d4
bad0  = WHERE(ABS(ftest[*,0]) LT 1d0,bd0,COMPLEMENT=good0)
bad1  = WHERE(ABS(ftest[*,1]) LT 1d0,bd1,COMPLEMENT=good1)
bad2  = WHERE(ABS(ftest[*,2]) LT 1d0,bd2,COMPLEMENT=good2)
IF (bad0[0] NE -1L) THEN f2[bad0,0] = 0d0
IF (bad1[0] NE -1L) THEN f2[bad1,1] = 0d0
IF (bad2[0] NE -1L) THEN f2[bad2,2] = 0d0
; => Calculate magnitudes of "fixed" arrays
f1mag = SQRT(TOTAL(f1^2,2L,/NAN))
f2mag = SQRT(TOTAL(f2^2,2L,/NAN))
; => Renormalize the arrays
f1    = REFORM([[f1[*,0]/f1mag],[f1[*,1]/f1mag],[f1[*,2]/f1mag]])
f2    = REFORM([[f2[*,0]/f2mag],[f2[*,1]/f2mag],[f2[*,2]/f2mag]])

; => Multiply by original magnitudes
f1 = REFORM([[f1[*,0]*md3],[f1[*,1]*md3],[f1[*,2]*md3]])
f2 = REFORM([[f2[*,0]*md4],[f2[*,1]*md4],[f2[*,2]*md4]])
;-----------------------------------------------------------------------------------------
; => Return to user
;-----------------------------------------------------------------------------------------
rot_str = CREATE_STRUCT('FA',f1,'PERP',f2)
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
IF NOT KEYWORD_SET(nom) THEN BEGIN
  MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
ENDIF
;*****************************************************************************************
RETURN,rot_str
END
