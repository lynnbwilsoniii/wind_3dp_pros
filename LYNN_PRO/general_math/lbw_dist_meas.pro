;*****************************************************************************************
;
;  PROCEDURE:   lbw_dist_meas_ind.pro
;  PURPOSE  :   Helper routine for main function.  Given the number of items M, construct
;                 index arrays Index1 and Index2 to allow the distance measure to be
;                 computed all at once.  Index1 and Index2 are vectors of length
;                 M*(M-1)/2 which match every item in an array up with every other item.
;
;  CALLED BY:   
;               lbw_dist_meas.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               fill_range.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               M       :  Scalar [numeric] defining the number of items in ARRAY
;
;  OUTPUT:
;               INDEX1  :  Set to a named variable to return the indices
;               INDEX2  :  Set to a named variable to return the indices
;
;  EXAMPLES:    
;               [calling sequence]
;               lbw_dist_meas_ind, m, index1, index2
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This now allows for L64 format integers and calls fill_range.pro
;                     to speed up the indexing of such large arrays
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: DISTANCE_MEASURE_INDICES.PRO    BY: CT, RSI, Sept 2003
;   CREATED:  07/17/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/17/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

PRO lbw_dist_meas_ind,m,index1,index2

;;  Set compiling options
COMPILE_OPT idl2, hidden
;;  Define dummy fill arrays
n              = m[0]*(m[0] - 1L)/2L
IF (n[0] LT 0) THEN BEGIN
  ;;  Need L64
  n              = m[0]*(m[0] - 1LL)/2LL
  ii             = 0LL
  index0         = L64INDGEN(m[0] - 1LL) + 1LL   ;;  work array
  index1         = LON64ARR(n[0], /NOZERO)
  index2         = LON64ARR(n[0], /NOZERO)
  ;;  Define indices
  FOR i=0LL, m[0] - 2LL DO BEGIN
    n1              = m[0] - (i[0] + 1LL)
    ;;  Indices into first pair and second pair
    i0              = fill_range(ii[0],(ii[0] + n1[0] - 1LL),DIND=1LL)
    i1              = fill_range(0LL,(n1[0] - 1LL),DIND=1LL)
    index1[i0]      = i[0]
    index2[ii[0]]   = index0[i1] + i[0]
    ;;  Iterate index
    ii                                 += n1[0]
  ENDFOR
ENDIF ELSE BEGIN
  ii             = 0L
  index0         = LINDGEN(m[0] - 1L) + 1L   ;;  work array
  index1         = LONARR(n[0], /NOZERO)
  index2         = LONARR(n[0], /NOZERO)
  ;;  Define indices
  FOR i=0L, m[0] - 2L DO BEGIN
    n1              = m[0] - (i[0] + 1L)
    ;;  Indices into first pair and second pair.
    i0              = fill_range(ii[0],(ii[0] + n1[0] - 1L),DIND=1L)
    i1              = fill_range(0L,(n1[0] - 1L),DIND=1L)
    index1[i0]      = i[0]
    index2[ii[0]]   = index0[i1] + i[0]
    ;;  Iterate index
    ii             += n1[0]
  ENDFOR
ENDELSE
;;  Return to main routine

RETURN
END


;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_dist_meas.pro
;  PURPOSE  :   Compute the pairwise distance between a set of items.  The Result is a
;                 vector of m*(m-1)/2 elements containing the distance matrix in compact
;                 form.  Given a distance between two items, D(i,j), the distances within
;                 Result are returned in the order:
;                 [D(0, 1),  D(0, 2), ..., D(0, m-1), D(1, 2), ..., D(m-2, m)].
;
;               If keyword MATRIX is set then the distance matrix is not returned in
;                 compact form, but is instead returned as an m-by-m symmetric array
;                 with zeroes along the diagonal.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               lbw_dist_meas_ind.pro
;
;  CALLS:
;               lbw_dist_meas_ind.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               ARRAY          :  [N,M]-Element [numeric] array defining the coordinates
;                                   of M items.  For example, in a 2D cartesian space,
;                                   ARRAY would have [2,M]-elements.
;
;  EXAMPLES:    
;               [calling sequence]
;               distm = lbw_dist_meas(array [,/DOUBLE] [,/MATRIX] [,MEASURE=measure] $
;                                     [,POWER_MEASURE=power_measure])
;
;  KEYWORDS:    
;               DOUBLE         :  If set, routine will compute output in double-precision
;                                   [Default = FALSE]
;               MATRIX         :  If set, the returned array is an [M,M]-element
;                                   symmetric matrix array with diagonal set to zero
;                                   [Default = FALSE]
;               MEASURE        :  Scalar [numeric] with the following allowed values:
;                                   0  :  Euclidean distance
;                                         = Sqrt(Total((Xi - Yi)^2))
;                                   1  :  CityBlock (Manhattan) distance
;                                         = Total(Abs(Xi - Yi))
;                                   2  :  Chebyshev distance
;                                         = Max(Abs(Xi - Yi))
;                                   3  :  Correlative distance
;                                         = Sqrt((1-r)/2)
;                                         [r is the correlation coefficient between two items]
;                                   4  :  Percent disagreement
;                                         = (Number of Xi ne Yi)/n
;                                   *** This keyword is ignored if POWER_MEASURE is set. ***
;               POWER_MEASURE  :  Scalar or [2]-element [numeric] array defining the
;                                   parameters p and r to be used in the power distance,
;                                   defined as (Total(Abs(Xi - Yi)^p)^(1/r).
;                                   If POWER_MEASURE is a scalar then the same value is
;                                   used for both p and r (this is also known as the
;                                   Minkowski distance). Note that POWER_MEASURE=1 is the
;                                   same as the CityBlock distance, while POWER_MEASURE=2
;                                   is the same as Euclidean distance.
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The original routine used integer values instead of long integer
;                     for indexing arrays, which led to the M value passed to the
;                     helper routine being zero, thus breaking the routine.
;
;  REFERENCES:  
;               https://www.harrisgeospatial.com/docs/DISTANCE_MEASURE.html
;
;   ADAPTED FROM: DISTANCE_MEASURE.PRO    BY: CT, RSI, Sept 2003
;   CREATED:  07/17/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/17/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_dist_meas,array,DOUBLE=double,MATRIX=matrix,MEASURE=measureIn,POWER_MEASURE=powerIn

;;----------------------------------------------------------------------------------------
;;  Set compiling options
;;----------------------------------------------------------------------------------------
COMPILE_OPT idl2
ON_ERROR, 2
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 1) THEN MESSAGE,'Incorrect number of arguments.'
dims           = SIZE(array,/DIMENSIONS)
IF (N_ELEMENTS(dims) NE 2 || dims[0] LT 2 || dims[1] LT 2) THEN MESSAGE,'Array must have two dimensions.'
m              = dims[1]
type           = SIZE(array, /TYPE)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check DOUBLE
dbl            = (N_ELEMENTS(double) GT 0) ? KEYWORD_SET(double) : $
                 ((type[0] EQ 5) || (type[0] EQ 9))
;;  Check MEASURE
measure        = (N_ELEMENTS(measureIn) EQ 1) ? measureIn : 0
;;----------------------------------------------------------------------------------------
;;  Compute correlative distance (if MEASURE=3)
;;----------------------------------------------------------------------------------------
IF (measure[0] EQ 3 && ~N_ELEMENTS(powerIn)) THEN BEGIN
  IF (dims[0] LE 2) THEN MESSAGE,'First dimension must be greater than 2 for Correlative distance.'
  ;;  Correlate performs the cross-correlation between columns,
  ;;  so take the transpose
  cor       = CORRELATE(TRANSPOSE(array),DOUBLE=dbl[0])
  ;;  This will give us an m-by-m symmetric matrix
  symresult = SQRT(0.5*(1e0 - cor))
  ;;  We're done if MATRIX is set
  IF (KEYWORD_SET(matrix)) THEN RETURN,symresult
  ;;  Otherwise convert to compact form
  result    = dbl[0] ? DBLARR(m[0]*(m[0] - 1L)/2L) : FLTARR(m[0]*(m[0] - 1L)/2L)
  IF (m[0] EQ 2) THEN result = result[0]   ;;  convert to scalar
  ii        = 0L
  n1        = m[0] - 1L
  FOR i=0L, m[0] - 2L DO BEGIN
    result[ii[0]] = symresult[(i[0] + 1L):*, i[0]]
    ;;  Iterate indices
    ii += n1[0]
    n1--
  ENDFOR
  ;;  Return to user
  RETURN,result
ENDIF
;;----------------------------------------------------------------------------------------
;;  Compute other distance form
;;----------------------------------------------------------------------------------------
;;  Construct indices to compute all of the distances at once.
lbw_dist_meas_ind,m[0],idx1,idx2
;;----------------------------------------------------------------------------------------
;;  Compute Abs. difference (if MEASURE<=2)
;;----------------------------------------------------------------------------------------
IF (measure[0] LE 2 || N_ELEMENTS(powerIn)) THEN BEGIN
  ;;  Convert to float/double if necessary.
  newtype = (type[0] EQ 6 || type[0] EQ 9) ? (dbl[0] ? 9 : 6) : (dbl[0] ? 5 : 4)
  IF (newtype[0] NE type[0]) THEN BEGIN
    ;;  For speed, convert to new type before indexing.
    arr  = FIX(array,TYPE=newtype[0])
    arr1 = arr[*,TEMPORARY(idx1)]
    arr2 = arr[*,TEMPORARY(idx2)]
  ENDIF ELSE BEGIN
    ;;  Use existing type
    arr1 = array[*,TEMPORARY(idx1)]
    arr2 = array[*,TEMPORARY(idx2)]
  ENDELSE
  ;;  Compute absolute differerence
  diff    = ABS(TEMPORARY(arr1) - TEMPORARY(arr2))
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check POWER_MEASURE
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(powerIn) GT 0) THEN BEGIN
  ;;  POWER_MEASURE is set
  power  = (N_ELEMENTS(powerIn) EQ 1) ? [powerIn[0],powerIn[0]] : powerIn
  power  = dbl[0] ? DOUBLE(power) : FLOAT(power)
  result = TOTAL(TEMPORARY(diff)^power[0],1,DOUBLE=dbl[0])^(1e0/power[1])
ENDIF ELSE BEGIN
  ;;  POWER_MEASURE is not set
  CASE measure[0] OF
    0   : result = SQRT(TOTAL(TEMPORARY(diff)^2,1,DOUBLE=dbl[0]))                ;;  Euclidean
    1   : result = TOTAL(TEMPORARY(diff),1,DOUBLE=dbl[0])                        ;;  CityBlock
    2   : result = MAX(TEMPORARY(diff),DIMENSION=1)                              ;;  Chebyshev
    4   : result = TOTAL(array[*,idx1] NE array[*,idx2],1,DOUBLE=dbl[0])/dims[0] ;;  Percent disagreement
    ELSE: MESSAGE, 'Illegal keyword value for MEASURE.'
  ENDCASE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Expand from vector to symmetric m-by-m array
;;----------------------------------------------------------------------------------------
;;  Check MATRIX
if (KEYWORD_SET(matrix)) THEN BEGIN
  pairdistance = TEMPORARY(result)
  result       = dbl[0] ? DBLARR(m[0],m[0]) : FLTARR(m[0],m[0])
  ii           = 0L
  ;;  Define the upper half
  FOR j=0L, m[0] - 2L DO BEGIN
    nn                         = m[0] - j[0] - 1L
    result[j[0],(j[0] + 1L):*] = pairdistance[ii[0]:(ii[0] + nn[0] - 1L)]
    ;;  Iterate index
    ii                        += nn[0]
  ENDFOR
  ;;  Create the symmetric half
  result += TRANSPOSE(result)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,result
END

