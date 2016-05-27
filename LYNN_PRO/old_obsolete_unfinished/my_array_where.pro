;+
;*****************************************************************************************
;
;  FUNCTION :  my_array_where.pro
;  PURPOSE  :  This program finds the good elements of two different arrays which do not
;                 share the same number of elements but have overlapping values (i.e.
;                 x = findgen(20), y = [1.,5.,7.,35.], => find which elements of 
;                 each match... x_el = [1,6,8], y_el = [0,1,2]).  This is good when
;                 the WHERE.PRO function doesn't work well (e.g. two different 
;                 arrays with different numbers of elements but containing
;                 overlapping values of interest).  The program will also return the
;                 complementary elements for each array if desired.
;
;  CALLED BY:   
;               my_dpu_ur8_shift.pro
;               wind_fix_scet.pro
;               eesa_pesa_low_to_tplot.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               ARR1      :  N-Element array of type S
;               ARR2      :  M-Element array of type S(+/-1,0)
;                              [Note:  S = the type code and can be 2-5 or 7]
;
;  EXAMPLES:
;               x = findgen(20)
;               y = [1.,5.,7.,35.]
;               gtest = my_array_where(x,y)
;               print, gtest
;                    1           5           7
;                    0           1           2
;
;  KEYWORDS:  
;               NGOOD     :  Set to a named variable to return the number of 
;                              matching values
;               N_UNIQ    :  If set, program will NOT find just the unique elements of
;                              the arrays in question
;               NCOMP1    :  Set to a named variable to return the complementary 
;                              elements to that of the (my_array_where(x,y))[*,0]
;               NCOMP2    :  Set to a named variable to return the complementary 
;                              elements to that of the (my_array_where(x,y))[*,1]
; **Obselete**  NO_UNIQ1  :  If set, program will not find ONLY the unique elements of
;                              the first array in question
; **Obselete**  NO_UNIQ1  :  If set, program will not find ONLY the unique elements of
;                              the second array in question
;
;   CHANGED:  1)  Added keywords:  NO_UNIQ[1,2]            [04/27/2009   v1.0.1]
;             2)  Rewrote and removed cludgy code          [04/28/2009   v2.0.0]
;             3)  Fixed syntax issue for strings           [04/29/2009   v2.0.1]
;             4)  Got rid of separate unique keyword calling reducing to only one
;                   keyword:  NO_UNIQ                      [06/15/2009   v3.0.0]
;             5)  Added keywords:  NCOMP1 and NCOMP2       [09/29/2009   v3.1.0]
;             6)  Changed place where unique elements are determined... alters results
;                                                          [10/22/2009   v3.2.0]
;             7)  Fixed a rare indexing issue (only occurred once in over 100
;                   different runs on varying input)       [02/19/2010   v3.2.1]
;
;   NOTES:      
;               1)  It is rarely the case that you don't want to set the keyword N_UNIQ
;
;   CREATED:  04/27/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/19/2010   v3.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION my_array_where,arr1,arr2,NGOOD=ngd,N_UNIQ=n_uq,NCOMP1=ncomp1,NCOMP2=ncomp2, $
                                  NO_UNIQ1=no_uq1,NO_UNIQ2=no_uq2

;-----------------------------------------------------------------------------------------
; => Define some basic parameters
;-----------------------------------------------------------------------------------------
bigarr = 0                              ; => Dummy array for array with more elements
smlarr = 0                              ; => Dummy array for array with less elements
nn     = 0                              ; => # of elements in larger array
nnl    = 0                              ; => # of elements in smaller array
;-----------------------------------------------------------------------------------------
; => Define some basic parameters
;-----------------------------------------------------------------------------------------
nr1  = N_ELEMENTS(arr1)                 ; => # of elements in array 1
nr2  = N_ELEMENTS(arr2)                 ; => # of elements in array 2
ra1  = [MIN(arr1,/NAN),MAX(arr1,/NAN)]
ra2  = [MIN(arr2,/NAN),MAX(arr2,/NAN)]
nn   = nr1 > nr2
nnl  = nr1 < nr2
tp1  = SIZE(arr1,/TYPE)
tp2  = SIZE(arr2,/TYPE)
IF (nr1 GT nr2) THEN BEGIN
  bigarr = arr1
  smlarr = arr2
ENDIF ELSE BEGIN
  bigarr = arr2
  smlarr = arr1
ENDELSE


test1 = ((tp1 LT 2) OR (tp1 GT 7)) OR (tp1 EQ 6)
test2 = ((tp2 LT 2) OR (tp2 GT 7)) OR (tp2 EQ 6)
IF (test1 OR test2) THEN BEGIN
  MESSAGE,"Incorrect input format!",/INFORMATIONAL,/CONTINUE
  RETURN,-1
ENDIF
;-----------------------------------------------------------------------------------------
; => Determine the type of array to use
;-----------------------------------------------------------------------------------------
tpcds = [2L,3L,4L,5L,7L]
chck1 = WHERE(tpcds EQ tp1,ck1)
chck2 = WHERE(tpcds EQ tp2,ck2)
test  = ((chck2[0] - chck1[0]) LE 1)
IF (test) THEN BEGIN
  chck = chck2[0] > chck1[0]
  ;-------------------------------------------------------------------------------------
  CASE chck[0] OF
    0   : BEGIN   ; => Intarr
      zero = -1
    END
    1   : BEGIN   ; => Lonarr
      zero = -1L
    END
    2   : BEGIN   ; => Fltarr
      zero = -1.0
    END
    3   : BEGIN   ; => Dblarr
      zero = -1d0
    END
    4   : BEGIN   ; => Strarr
      zero = ''
    END
  ENDCASE
ENDIF ELSE BEGIN
  MESSAGE,"Incorrect input format!",/INFORMATIONAL,/CONTINUE
  RETURN,-1
ENDELSE
;-----------------------------------------------------------------------------------------
; => Now get good elements of big array
;-----------------------------------------------------------------------------------------
gar1  = bigarr
ggr1  = LONARR(nnl)         ; => # of matched terms for each indexed value
gdif1 = REPLICATE(-1L,nn)   ; => Elements of bigarr array that are "good"
gdif2 = REPLICATE(-1L,nn)   ; => Elements of smlarr array that are "good"
cc    = 0L
FOR j=0L, nnl - 1L DO BEGIN
  temp = smlarr[j]
  test = (gar1 EQ temp)
  ggar = WHERE(test,gg,COMPLEMENT=bbar,NCOMPLEMENT=bb)
  IF (gg GT 0) THEN BEGIN
    upel           = gg - 1L + cc
;    gdif1[cc:upel] = ggar
;    cc            += gg
    IF (upel LE nn - 1L) THEN BEGIN
      gdif1[cc:upel] = ggar
      cc            += gg
    ENDIF ELSE BEGIN
      upel2   = nn - 1L
      gardiff = ((upel - upel2) GE gg) OR (upel GE upel2)
      IF (gardiff) THEN BREAK
      gardiff = (gg - 1L) - (upel - upel2)
      gdif1[cc:upel] = ggar[0:gardiff]
      ggr1[j] = gardiff + 1L
      BREAK
    ENDELSE
  ENDIF
  ggr1[j] = gg
ENDFOR
;-----------------------------------------------------------------------------------------
; => Now get good elements of small array
;-----------------------------------------------------------------------------------------
ggr2  = LONARR(nn)
gar2  = smlarr
cc    = 0L
FOR j=0L, nn - 1L DO BEGIN
  temp = bigarr[j]
  test = (gar2 EQ temp)
  ggar = WHERE(test,gg,COMPLEMENT=bbar,NCOMPLEMENT=bb)
  IF (gg GT 0) THEN BEGIN
    upel           = gg - 1L + cc
;    gdif2[cc:upel] = ggar
;    cc            += gg
    IF (upel LE nn - 1L) THEN BEGIN
      gdif2[cc:upel] = ggar
      cc            += gg
    ENDIF ELSE BEGIN
      upel2   = nn - 1L
      gardiff = ((upel - upel2) GE gg) OR (upel GE upel2)
;      gardiff = (upel - upel2) GE gg
      IF (gardiff) THEN BREAK
      gardiff = (gg - 1L) - (upel - upel2)
      gdif2[cc:upel] = ggar[0:gardiff]
      ggr2[j] = gardiff + 1L
      BREAK
    ENDELSE
  ENDIF
  ggr2[j] = gg
ENDFOR
;-----------------------------------------------------------------------------------------
; => Now get rid of possibly non-unique elements
;-----------------------------------------------------------------------------------------
uqgf1  = 0                ; => Elements of gdif1 to use for return value
uqgf2  = 0                ; => Elements of gdif2 to use for return value
uqgf1  = LINDGEN(N_ELEMENTS(gdif1))
uqgf2  = LINDGEN(N_ELEMENTS(gdif2))
gdif1  = gdif1[uqgf1]
gdif2  = gdif2[uqgf2]
;-----------------------------------------------------------------------------------------
; => Now get rid of unnecessary elements
;-----------------------------------------------------------------------------------------
mytest = (gdif2 NE -1) AND (gdif1 NE -1)
gdiffa = WHERE(mytest,gdfa,COMPLEMENT=bdiffa,NCOMPLEMENT=bdfa)
IF (gdfa GT 0) THEN BEGIN
  ggdif1 = gdif1[gdiffa]
  ggdif2 = gdif2[gdiffa]
ENDIF ELSE BEGIN
  MESSAGE,"No finite elements match!",/INFORMATIONAL,/CONTINUE
  RETURN,-1
ENDELSE
tempbig = bigarr[ggdif1]
tempsml = smlarr[ggdif2]
; => Surprisingly, this next part is remarkably important (well, at least it surprised me)
sg      = SORT(tempbig)
sm      = SORT(tempsml)
tempbig = tempbig[sg]
tempsml = tempsml[sm]
ggdif1  = ggdif1[sg]
ggdif2  = ggdif2[sm]
;-----------------------------------------------------------------------------------------
; => Check one last time that the elements are the same (if not string arrays)
;-----------------------------------------------------------------------------------------
IF (chck[0] NE 4L) THEN BEGIN
  ; => First check the overlapping array elements
  mytest2 = ((tempbig - tempsml) EQ 0)
  gdiffa2 = WHERE(mytest2,gdfa2,COMPLEMENT=bdiffa2,NCOMPLEMENT=bdfa2)
  IF (gdfa2 GT 0) THEN BEGIN
    ggdif1 = ggdif1[gdiffa2]
    ggdif2 = ggdif2[gdiffa2]
  ENDIF ELSE BEGIN
    MESSAGE,"No finite elements match!",/INFORMATIONAL,/CONTINUE
    RETURN,-1
  ENDELSE
ENDIF

IF (KEYWORD_SET(no_uq1) OR KEYWORD_SET(no_uq2)) THEN n_uq = 1
IF KEYWORD_SET(n_uq) THEN BEGIN
  ggdif1 = ggdif1
  ggdif2 = ggdif2
ENDIF ELSE BEGIN
  unqgf1 = UNIQ(ggdif1,SORT(ggdif1))
  unqgf2 = UNIQ(ggdif2,SORT(ggdif2))
  nnnq1  = N_ELEMENTS(unqgf1)
  nnnq2  = N_ELEMENTS(unqgf2)
  IF (nnnq1 NE nnnq2) THEN BEGIN  ; => Ignore non-use of no unique keyword
    ggdif1 = ggdif1
    ggdif2 = ggdif2
  ENDIF ELSE BEGIN
    ggdif1 = ggdif1[unqgf1]
    ggdif2 = ggdif2[unqgf2]
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Check to make sure the arrays are the same size
;-----------------------------------------------------------------------------------------
ngar1     = N_ELEMENTS(ggdif1)
ngar2     = N_ELEMENTS(ggdif2)
inds_bgar = REPLICATE(1,N_ELEMENTS(bigarr))
inds_smar = REPLICATE(1,N_ELEMENTS(smlarr))

IF (ngar1 NE ngar2) THEN BEGIN
  MESSAGE,'How did this happen?...',/INFORMATIONAL,/CONTINUE
  RETURN,-1
ENDIF
;-----------------------------------------------------------------------------------------
; => Determine the order of the return values
;-----------------------------------------------------------------------------------------
ngd           = ngar1
IF (nr1 GT nr2) THEN BEGIN
  good_elements     = [[ggdif1],[ggdif2]]
  inds_bgar[ggdif1] = 0
  inds_smar[ggdif2] = 0
  ch_inds_bgar      = WHERE(inds_bgar GT 0)
  ch_inds_smar      = WHERE(inds_smar GT 0)
  ncomp1            = ch_inds_bgar
  ncomp2            = ch_inds_smar
ENDIF ELSE BEGIN
  good_elements     = [[ggdif2],[ggdif1]]
  inds_bgar[ggdif2] = 0
  inds_smar[ggdif1] = 0
  ch_inds_bgar      = WHERE(inds_bgar GT 0)
  ch_inds_smar      = WHERE(inds_smar GT 0)
  ncomp2            = ch_inds_bgar
  ncomp1            = ch_inds_smar
ENDELSE

RETURN,good_elements
END