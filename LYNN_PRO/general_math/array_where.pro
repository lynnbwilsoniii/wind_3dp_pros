;+
;*****************************************************************************************
;
;  FUNCTION :  array_where.pro
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
;               NA
;
;  CALLS:       
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               ARR1      :  N-Element array of type S
;               ARR2      :  M-Element array of type S(+/-1,0)
;                              [Note:  S = the type code and can be 2-5 or 7]
;
;  EXAMPLES:
;               x = findgen(20)
;               y = [1.,5.,7.,35.]
;               gtest = array_where(x,y)
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
;             8)  Vectorized with help from program where_array.pro written by
;                   Stephen Strebel 07/30/1994 and changed name to array_where.pro
;                                                          [10/22/2010   v4.0.0]
;             9)  Added default definitions for NCOMP1 and NCOMP2 when no overlapping
;                   elements exist                         [03/25/2011   v4.1.0]
;
;   NOTES:      
;               1)  It is rarely the case that you don't want to set the keyword N_UNIQ
;
;   CREATED:  04/27/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/25/2011   v4.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION array_where,arr1,arr2,NGOOD=ngd,N_UNIQ=n_uq,NCOMP1=ncomp1,NCOMP2=ncomp2, $
                                  NO_UNIQ1=no_uq1,NO_UNIQ2=no_uq2

;-----------------------------------------------------------------------------------------
; => Define some dummy parameters
;-----------------------------------------------------------------------------------------
badmssg = 'Inproper parameters'
usemssg = 'Usage: result = my_array_where(A,B,[NGOOD=ngd,N_UNIQ=n_uq,NCOMP1=ncomp1,NCOMP2=ncomp2])'
typmssg = 'Parameters cannot be of type Structure'
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
ar1  = REFORM(arr1)
ar2  = REFORM(arr2)
nd1  = SIZE(ar1,/N_DIMENSIONS)
nd2  = SIZE(ar2,/N_DIMENSIONS)
nr1  = N_ELEMENTS(ar1)                 ; => # of elements in array 1
nr2  = N_ELEMENTS(ar2)                 ; => # of elements in array 2
test = (N_PARAMS() NE 2 OR nd1 NE 1 OR nd2 NE 1 OR nr1 EQ 0 OR nr2 EQ 0)

IF (test) THEN BEGIN 
  MESSAGE,badmssg,/INFORMATIONAL,/CONTINUE 
  MESSAGE,usemssg,/INFORMATIONAL,/CONTINUE 
  RETURN,-1
ENDIF 
;-----------------------------------------------------------------------------------------
; => Check input type
;-----------------------------------------------------------------------------------------
ty1  = SIZE(ar1,/TYPE)
ty2  = SIZE(ar2,/TYPE)
test = (ty1 EQ 8) OR (ty2 EQ 8)
IF (test) THEN BEGIN 
  MESSAGE,badmssg,/INFORMATIONAL,/CONTINUE 
  MESSAGE,typmssg,/INFORMATIONAL,/CONTINUE 
  RETURN,-1
ENDIF 
;-----------------------------------------------------------------------------------------
; => Create two matrices to compare 
;-----------------------------------------------------------------------------------------
l    = LINDGEN(nr1,nr2) 
a1a  = ar1[l MOD nr1]
a2a  = ar2[l/nr1]
;-----------------------------------------------------------------------------------------
; => Now compare two matrices
;-----------------------------------------------------------------------------------------
good = WHERE(a1a EQ a2a)
ind1 = good MOD nr1
ind2 = good/nr1

IF NOT KEYWORD_SET(n_uq) THEN BEGIN
  ; => Find the unique elements only
  un1  = UNIQ(ind1,SORT(ind1))
  un2  = UNIQ(ind2,SORT(ind2))
  IF (N_ELEMENTS(un1) NE N_ELEMENTS(un2)) THEN BEGIN
    ; => Ignore non-use of no unique keyword
    ind1 = ind1
    ind2 = ind2
  ENDIF ELSE BEGIN
    ind1 = ind1[un1]
    ind2 = ind2[un2]
  ENDELSE
ENDIF
;-----------------------------------------------------------------------------------------
; => Check results
;-----------------------------------------------------------------------------------------
IF (ind1[0] EQ -1 OR ind2[0] EQ -1) THEN BEGIN
  ; => Set default values of complementary elements
  ncomp1   = LINDGEN(nr1)
  ncomp2   = LINDGEN(nr2)
  RETURN,-1 
ENDIF
;-----------------------------------------------------------------------------------------
; => Find complement indices
;-----------------------------------------------------------------------------------------
l1       = REPLICATE(1,nr1)
l2       = REPLICATE(1,nr2)
l1[ind1] = 0
l2[ind2] = 0
ncomp1   = WHERE(l1 GT 0)
ncomp2   = WHERE(l2 GT 0)
;-----------------------------------------------------------------------------------------
; => Return values to user
;-----------------------------------------------------------------------------------------
good_elements = [[ind1],[ind2]]
RETURN,good_elements
END 
