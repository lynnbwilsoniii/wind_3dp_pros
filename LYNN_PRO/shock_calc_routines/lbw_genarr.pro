;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_genarr.pro
;  PURPOSE  :   Creates an evenly spaced array of numbers.  Input can be of INTEGER,
;                 LONG, FLOAT, or DOUBLE types.  Output is the same type as input.
;                 Note that for INTEGER and LONG types, this may mean that the output is
;                 not spaced exactly evenly, since there is a minimum increment for the
;                 output array.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               lbw_genarr.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               N     :  Scalar [numeric] number of points to use in output array
;               MN    :  Scalar [numeric] value defining the minimum value of output array
;               MX    :  Scalar [numeric] value defining the maximum value of output array
;
;  EXAMPLES:    
;               [calling sequence]
;               arr = lbw_genarr(n, mn, mx [,/LOG])
;
;               x = lbw_genarr(7,4.,10.)
;               PRINT,x
;                     4.00000      5.00000      6.00000      7.00000      8.00000      9.00000      10.0000
;
;  KEYWORDS:    
;               LOG   :  If set, output will be a logarithmically spaced array from
;                          MN to MX
;
;   CHANGED:  1)  Cleaned up a little and renamed to lbw_genarr.pro from genarr.pro
;                                                                   [02/18/2019   v1.0.1]
;
;   NOTES:      
;               1)  If LOG=TRUE and the number type is INTEGER/LONG, a FLOAT/DOUBLE array
;                     is returned.
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: genarr.pro    BY: Marc Pulupa
;   CREATED:  02/13/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/18/2019   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_genarr,n,mn,mx,LOG=log

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
dim_check      = 1b
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 3) THEN RETURN,0
n_dim          = N_ELEMENTS(n)
IF (N_ELEMENTS(mn) NE n_dim[0]) THEN dim_check = 0b
IF (N_ELEMENTS(mx) NE n_dim[0]) THEN dim_check = 0b
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check LOG
IF KEYWORD_SET(log) THEN IF (N_ELEMENTS(log) NE n_dim[0]) THEN dim_check = 0b
;;  Error handling
IF NOT(dim_check[0]) THEN BEGIN
  PRINT, 'All inputs must have the same dimension!'
  RETURN, 0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Construct evenly spaced array
;;----------------------------------------------------------------------------------------
IF (n_dim[0] EQ 1) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  1D input
  ;;--------------------------------------------------------------------------------------
  arr            = -1
  smin           = SIZE(mn[0])
  smax           = SIZE(mx[0])
  type           = MAX([smin[1],smax[1]])
  IF (n[0] GT 1) THEN BEGIN
    IF NOT(KEYWORD_SET(log)) THEN BEGIN
      CASE type[0] OF
        2    : arr = FIX((mx[0] - mn[0])*INDGEN(n[0])/(n[0] - 1) + mn[0])
        3    : arr = FIX((mx[0] - mn[0])*LINDGEN(n[0])/(n[0] - 1L) + mn[0])
        4    : arr = (mx[0] - mn[0])*FINDGEN(n[0])/(n[0] - 1L) + mn[0]
        5    : arr = (mx[0] - mn[0])*DINDGEN(n[0])/(n[0] - 1L) + mn[0]
        ELSE :  RETURN,0
      ENDCASE
    ENDIF ELSE BEGIN
      IF (type[0] EQ 2) THEN type = 4
      IF (type[0] EQ 3) THEN type = 5
      CASE type[0] OF
        4    : arr = mn[0]*(mx[0]/mn[0])^(FINDGEN(n[0])/(n[0] - 1L)) 
        5    : arr = mn[0]*(mx[0]/mn[0])^(DINDGEN(n[0])/(n[0] - 1L))
        ELSE :  RETURN,0
      ENDCASE
    ENDELSE
  ENDIF ELSE BEGIN
    arr = [mn[0]]
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  Return to user
  ;;--------------------------------------------------------------------------------------
  RETURN,arr
ENDIF ELSE IF (n_dim[0] EQ 2) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  2D input
  ;;--------------------------------------------------------------------------------------
  n0             = n[0]
  min0           = mn[0]
  max0           = mx[0]
  n1             = n[1]
  min1           = mn[1]
  max1           = mx[1]
  IF KEYWORD_SET(log) THEN BEGIN
    log0 = log[0]
    log1 = log[1]
  ENDIF ELSE BEGIN
    log0 = 0
    log1 = 0
  ENDELSE
  ;;  Define 2 output arrays
  arr0           = lbw_genarr(n0[0],min0[0],max0[0],LOG=log0[0])
  arr1           = lbw_genarr(n1[0],min1[0],max1[0],LOG=log1[0])
  ;;  Reform/transpose arrays
  arr            = [[[REFORM(REBIN(arr0,n0[0],n1[0]),n0[0],n1[0],1)]],          $
                    [[REFORM(TRANSPOSE(REBIN(arr1,n1[0],n0[0])),n0[0],n1[0],1)]]]
  ;;--------------------------------------------------------------------------------------
  ;;  Return to user
  ;;--------------------------------------------------------------------------------------
  RETURN,arr
ENDIF
;;  End routine

END