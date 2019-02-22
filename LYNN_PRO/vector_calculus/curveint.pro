;*****************************************************************************************
;
;  FUNCTION :   spread.pro
;  PURPOSE  :   Spread out a vector into a matrix along, treating vector as a column
;                 unless the row keyword is used. 
;                 [Based on the F90 intrinsic SPREAD]
;
;  CALLED BY:   
;               curveint.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               VEC  :  [M]-Element array of points to spread out into a matrix
;               N    :  Scalar defining the number of points to use in column/row
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               ROW  :  If set, the program uses row-major formating
;
;   CHANGED:  1)  Added man page and vectorized
;                                                                   [10/25/2010   v1.0.1]
;             2)  Updated man page and cleaned up routine
;                                                                   [09/05/2014   v1.1.0]
;
;   NOTES:      
;               1)  Should not be called by user
;
;   CREATED:  10/22/2010
;   CREATED BY:  J.R. Woodroffe
;    LAST MODIFIED:  09/05/2014   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION spread, vec, n, ROW=row

;;----------------------------------------------------------------------------------------
;;  expand arrays
;;----------------------------------------------------------------------------------------
npts = N_ELEMENTS(vec)

IF (KEYWORD_SET(row)) THEN BEGIN
  res = FLTARR(n,npts)
  res = REFORM(REPLICATE(1,n) ## vec)
;;  LBW 10/25/2010
;  FOR i=0L, n - 1L DO res[i,*] = vec
ENDIF ELSE BEGIN
  res = FLTARR(npts,n)
  res = REFORM(vec ## REPLICATE(1,n))
;;  LBW 10/25/2010
;  FOR i=0L, n - 1L DO res[*,i] = vec
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to wrapping routine
;;----------------------------------------------------------------------------------------

RETURN, res
END

;+
;*****************************************************************************************
;
;  FUNCTION :   curveint.pro
;  PURPOSE  :   Find the intersection of two arbitrary curves.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               spread.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               XX0  :  [N]-Element array of abcissa values for YY0
;               YY0  :  [N]-Element array of dependent values associated with XX0
;               XX1  :  [M]-Element array of abcissa values for YY1
;               YY1  :  [M]-Element array of dependent values associated with XX1
;
;  EXAMPLES:    
;               xa  = 2d0*!DPI*DINDGEN(50L)/49L
;               xb  = 4d0*DINDGEN(100L)/99L
;               ya  = SIN(xa)
;               zb  = -1d-1 + 5d-1*xb - 5d-2*xb^2 + 25d-4*xb^3
;               res = curveint(xa,ya,xb,zb)
;               PRINT, res[0]
;                      2.2270945
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Added man page
;                                                                   [10/25/2010   v1.0.1]
;             2)  Updated man page and added error handling
;                                                                   [09/05/2014   v1.1.0]
;
;   NOTES:      
;               1)  J.R. Woodroffe originally stated that the result of this routine
;                     for the example was 2.22709 and that the analytical result should
;                     be 2.22611, thus a relative error of 0.04 percent.  I receive
;                     the value 2.2270945 which confirms J.R. Woodroffe's result.
;
;   CREATED:  10/22/2010
;   CREATED BY:  J.R. Woodroffe
;    LAST MODIFIED:  09/05/2014   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION curveint,xx0,yy0,xx1,yy1

;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
n0             = N_ELEMENTS(xx0)
n1             = N_ELEMENTS(xx1)
;;----------------------------------------------------------------------------------------
;;  Reform into matricies
;;----------------------------------------------------------------------------------------
x0             = spread(xx0,n1)
y0             = spread(yy0,n1)
x1             = spread(xx1,n0,/ROW)
y1             = spread(yy1,n0,/ROW)
;;----------------------------------------------------------------------------------------
;;  Calculate the minimum distance between the two lines
;;----------------------------------------------------------------------------------------
ds             = (x1 - x0)^2 + (y1 - y0)^2
mval           = MIN(ABS(ds),mdex,/NAN)
;;  LBW  09/05/2014   v1.1.0
;mval           = MIN(ds,mdex,/NAN)

x0min          = x0[mdex]
x1min          = x1[mdex]
y0min          = y0[mdex]
y1min          = y1[mdex]
;;----------------------------------------------------------------------------------------
;;  Determine the relevant abscissa indices
;;----------------------------------------------------------------------------------------
x0min          = MIN(ABS(xx0 - x0min[0]),x0dex,/NAN)
x1min          = MIN(ABS(xx1 - x1min[0]),x1dex,/NAN)
;;----------------------------------------------------------------------------------------
;;  Points for linear slope interpolation (centered difference approximation)
;;----------------------------------------------------------------------------------------
;x0next          = x0dex + 1L
;x1next          = x1dex + 1L
;;  LBW  09/05/2014   v1.1.0
upp0            = (n0[0] - 1L)
upp1            = (n1[0] - 1L)
IF (x0dex[0] LT upp0[0]) THEN BEGIN
  x0next = (x0dex[0] + 1L)
ENDIF ELSE BEGIN
  x0next = x0dex[0]
ENDELSE
IF (x1dex[0] LT upp1[0]) THEN BEGIN
  x1next = (x1dex[0] + 1L)
ENDIF ELSE BEGIN
  x1next = x1dex[0]
ENDELSE
IF (x0dex NE 0) THEN x0last = x0dex[0] - 1L ELSE x0last = x0dex[0]
IF (x1dex NE 0) THEN x1last = x1dex[0] - 1L ELSE x1last = x1dex[0]
;x1last = x1dex - 1L
;;----------------------------------------------------------------------------------------
;;  Get slopes
;;----------------------------------------------------------------------------------------
a              = (yy0[x0next[0]] - yy0[x0last[0]])/(xx0[x0next[0]] - xx0[x0last[0]])
b              = (yy1[x1next[0]] - yy1[x1last[0]])/(xx1[x1next[0]] - xx1[x1last[0]])
dab            = (a[0] - b[0])
;;----------------------------------------------------------------------------------------
;;  Calculate the abcissa point at which curves interesect
;;----------------------------------------------------------------------------------------
termy          = (yy1[x1dex[0]] - yy0[x0dex[0]])
termx          = (a[0]*xx0[x0dex[0]] - b[0]*xx1[x1dex[0]])
xint           = (termy[0] + termx[0])/dab[0]
;;  In case of multi-valued functions, only interpolate in range around indices for
;;      XINT
IF (n0 LT 20 OR n1 LT 20) THEN BEGIN
  ind_0 = LINDGEN(n0)
  ind_1 = LINDGEN(n1)
ENDIF ELSE BEGIN
  x     = LINDGEN(20)
  IF (x0dex NE 0) THEN BEGIN
    zero_10 = x0dex - 10L GE 0
    IF (zero_10) THEN BEGIN
      ind_0 = x + (x0dex - 10L)
    ENDIF ELSE BEGIN
      ind_0 = x
    ENDELSE
  ENDIF ELSE ind_0 = x
  IF (x1dex NE 0) THEN BEGIN
    zero_10 = x1dex - 10L GE 0
    IF (zero_10) THEN BEGIN
      ind_1 = x + (x1dex - 10L)
    ENDIF ELSE BEGIN
      ind_1 = x
    ENDELSE
  ENDIF ELSE ind_1 = x
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Calculate the function points at which curves interesect
;;----------------------------------------------------------------------------------------
yint0  = INTERPOL(yy0[ind_0],xx0[ind_0],xint[0],/SPLINE)
yint1  = INTERPOL(yy1[ind_1],xx1[ind_1],xint[0],/SPLINE)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN, [[xint[0],yint0[0]],[xint[0],yint1[0]]]
END

