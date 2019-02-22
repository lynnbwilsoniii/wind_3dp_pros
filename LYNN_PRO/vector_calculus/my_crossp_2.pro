;+
;*****************************************************************************************
;
;  FUNCTION :   my_crossp_2.pro
;  PURPOSE  :   Calculates the cross product of two vectors or arrays of vectors and 
;                 returns an array with the same dimensions as the larger of the two
;                 input vectors.  The IDL built-in, CROSSP.PRO, requires the user to
;                 use only single vectors whereas this program allows for [N,3] or
;                 [3,N]-element input arrays.
;
;  CALLED BY: 
;               field_rot.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:
;               NA
;
;  INPUT:
;               T1  :  [n,3] or [3,n] element array of vectors
;                        {where : n=1, or 2, or 3,...}
;               T2  :  [n,3] or [3,n] element array of vectors
;
;  EXAMPLES:
;               x = FINDGEN(3,n)
;               y = FINDGEN(n,3)
;               z = my_crossp_2(x,y)  ; -Returns a [n,3]-Element vector
;
;  KEYWORDS:
;               NOMSSG  :  If set, the program will NOT print out a message about the
;                            running time of the program.  This is particularly useful
;                            when calling the program multiple times in a loop.
;
;   CHANGED:  1)  Vectorized and changed indexing issue      [09/16/2008   v1.1.13]
;             2)  Updated man page                           [03/22/2009   v1.1.14]
;             3)  Added keyword:  NOMSSG                     [04/17/2009   v1.1.15]
;             4)  Changed some syntax and removed dependency on my_dimen_force.pro
;                                                            [09/17/2009   v1.2.0]
;             5)  Fixed a typo [no functional changes]       [12/04/2009   v1.2.1]
;
;   CREATED:  06/10/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/04/2009   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION my_crossp_2,t1,t2,NOMSSG=nom

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; => Create Dummy Array
;-----------------------------------------------------------------------------------------
f     = !VALUES.F_NAN
d     = !VALUES.D_NAN
fake1 = REPLICATE(d,10,3)
;-----------------------------------------------------------------------------------------
; => Check array sizes
;-----------------------------------------------------------------------------------------
d1  = REFORM(t1)  ; -Prevent [1,3] arrays
d2  = REFORM(t2)
ds1 = SIZE(d1,/DIMENSIONS)
ds2 = SIZE(d2,/DIMENSIONS)
bs1 = SIZE(ds1,/N_ELEMENTS)        ; -bs1 = 1 if d1 is 1D array, 2 if 2D
bs2 = SIZE(ds2,/N_ELEMENTS)
IF (SIZE(d1,/TYPE) LT 3L OR SIZE(d1,/TYPE) GT 6L OR $
    SIZE(d2,/TYPE) LT 3L OR SIZE(d2,/TYPE) GT 6L) THEN BEGIN
  MESSAGE,'Incorrect input format:  T1 or T2',/INFORMATIONAL,/CONTINUE
  RETURN,fake1
ENDIF

gs1 = WHERE(ds1 EQ 3L,g1,COMPLEMENT=bn1)
gs2 = WHERE(ds2 EQ 3L,g2,COMPLEMENT=bn2)
;-----------------------------------------------------------------------------------------
; => Reform input T1 array
;-----------------------------------------------------------------------------------------
CASE gs1[0] OF
  0L   : BEGIN
    IF (bs1[0] GT 1L) THEN BEGIN
      d3  = TRANSPOSE(d1)
    ENDIF ELSE BEGIN
      d3  = REFORM(d1)
    ENDELSE
  END
  1L   : BEGIN
    d3  = REFORM(d1)
  END
  ELSE : BEGIN
    MESSAGE,'Incorrect input format: V1 (Must be [N,3] or [3,N] element array)',/INFORMATIONAL,/CONTINUE
    RETURN,fake1
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Reform input T2 array
;-----------------------------------------------------------------------------------------
CASE gs2[0] OF
  0L   : BEGIN
    IF (bs2[0] GT 1L) THEN BEGIN
      d4  = TRANSPOSE(d2)
    ENDIF ELSE BEGIN
      d4  = REFORM(d2)
    ENDELSE
  END
  1L   : BEGIN
    d4  = REFORM(d2)
  END
  ELSE : BEGIN
    MESSAGE,'Incorrect input format: V1 (Must be [N,3] or [3,N] element array)',/INFORMATIONAL,/CONTINUE
    RETURN,fake1
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
    ENDIF ELSE BEGIN
      d3  = REPLICATE(1.0,ds2[0]) # d3
    ENDELSE
  END
  2L   :        ; => Both are 2D =>> don't change either
  0L   : BEGIN  ; => Both are 1D
    mycross = [ [d3[1]*d4[2] - d3[2]*d4[1]],[d3[2]*d4[0] - d3[0]*d4[2]],$
                [d3[0]*d4[1] - d3[1]*d4[0]] ]
    ;*************************************************************************************
    ex_time = SYSTIME(1) - ex_start
    IF NOT KEYWORD_SET(nom) THEN BEGIN
      MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
    ENDIF
    ;*************************************************************************************
    RETURN,REFORM(mycross)
  END
  ELSE : BEGIN
    MESSAGE,'Incorrect input format: V1 AND V2 (Must be [N,3] or [3,N] element arrays)',/INFORMATIONAL,/CONTINUE
    RETURN,fake1
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Both are 2D
;-----------------------------------------------------------------------------------------
mycross = [[d3[*,1]*d4[*,2] - d3[*,2]*d4[*,1]],[d3[*,2]*d4[*,0] - d3[*,0]*d4[*,2]],$
           [d3[*,0]*d4[*,1] - d3[*,1]*d4[*,0]] ]
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
IF NOT KEYWORD_SET(nom) THEN BEGIN
  MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
ENDIF
;*****************************************************************************************
RETURN,REFORM(mycross)
END
