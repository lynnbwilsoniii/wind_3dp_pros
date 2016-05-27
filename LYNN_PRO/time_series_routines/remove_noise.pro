;+
;*****************************************************************************************
;
;  FUNCTION :   remove_noise.pro
;  PURPOSE  :   Computes the backward moving average of an input array of data using
;                 autoregressive backcasting to extrapolate the data.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               DATA   :  [N]-Element array of either float or double precision data
;                           points to have the noise removed from
;
;  EXAMPLES:    
;               test = remove_noise(data,NBINS=10)
;
;  KEYWORDS:    
;               NBINS  :  Scalar value defining the number of values to compute in
;                           forecasting/backcasting the data
;                           [Default = 3]
;               ORDER  :  Scalar defining the number of data points to use in the
;                           forecast/backcast
;                                     { 10    :  10 < N < 220
;                           Default = {
;                                     { 5% N  :  N > 220
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See IDL's documentation for TS_SMOOTH and TS_FCAST
;
;   CREATED:  06/30/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/30/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION remove_noise,data,NBINS=nbins,ORDER=order

;-----------------------------------------------------------------------------------------
; => Define dummy/default variables and constants
;-----------------------------------------------------------------------------------------
f    = !VALUES.F_NAN
d    = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check inputs
;-----------------------------------------------------------------------------------------
x    = REFORM(data)
nx   = N_ELEMENTS(x)
tyx  = SIZE(x,/TYPE)
; => check input length
IF (nx LT 11) THEN BEGIN
  errmssg = 'Input must have more than 11 elements...'
  MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
  RETURN,x
ENDIF
;-----------------------------------------------------------------------------------------
; => Check keyword inputs
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(order) THEN points = order[0] ELSE points = MAX([10L,LONG(0.05*nx)])

IF KEYWORD_SET(nbins) THEN nvals  = nbins[0] ELSE nvals  = 3L
IF (nvals LT 3) THEN BEGIN
  errmssg = 'NBINS must be GE 3 => using default = 3L'
  MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
  nvals   = 3L
ENDIF
;-----------------------------------------------------------------------------------------
; => Calculate autoregressive backcasting
;-----------------------------------------------------------------------------------------
CASE tyx[0] OF
  4    : BEGIN
    ; => Float
    nan = f
    smx = REPLICATE(nan,nx)     ; => smoothed result
    x   = [TS_FCAST(x,points[0],nvals[0]-1L,/BACKCAST),x]
    FOR k=0L, nx - 1L DO BEGIN
      dnel   = k[0]
      upel   = nvals[0] + (k[0] - 1L)
      smx[k] = TOTAL(x[dnel:upel],/NAN)
    ENDFOR
  END
  5    : BEGIN
    ; => Double
    nan = d
    smx = REPLICATE(nan,nx)     ; => smoothed result
    x   = [TS_FCAST(x,points[0],nvals[0]-1L,/BACKCAST,/DOUBLE),x]
    FOR k=0L, nx - 1L DO BEGIN
      dnel   = k[0]
      upel   = nvals[0] + (k[0] - 1L)
      smx[k] = TOTAL(x[dnel:upel],/NAN,/DOUBLE)
    ENDFOR
  END
  ELSE : BEGIN
    errmssg = 'Input must be a float or double type...'
    MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
    RETURN,x
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Return smoothed result to user
;-----------------------------------------------------------------------------------------

RETURN, smx/nvals[0]
END