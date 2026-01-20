;+
;*****************************************************************************************
;
;  FUNCTION :   remove_nans.pro
;  PURPOSE  :   This routine interpolates the gaps in an input array that are NaNs.
;                 The routine allows the user to interpolate using a linear, quadratic,
;                 least-squares quadratic, or cubic spline fit to fill in for the
;                 NaNs.  Given F(X) = Y and X, the routine will output G(X) which has
;                 replaced the NaNs in F(X) with the interpolated values.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               IN__X           :  [N]-Element [float/double] array of input
;                                    abscissa values [Xo in F(Xo)]
;               IN__Y           :  [N]-Element [float/double] array of input
;                                    ordinate values [Y = F(Xo)]
;
;  EXAMPLES:    
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               ;;  Test example
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               IDL> x  = DINDGEN(30)*2d0*!DPI/29
;               IDL> y  = COS(x)
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               ;;  Insert some NaNs to remove as a test case
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               IDL> y[[0,5,7,15,22,25,28]] = !VALUES.D_NAN
;               IDL> HELP, WHERE(FINITE(y))
;               <Expression>    LONG      = Array[23]
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               ;;  Use linear interpolation to remove NaNs
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               IDL> z = remove_nans(x,y)
;               IDL> HELP, WHERE(FINITE(z))
;               <Expression>    LONG      = Array[30]
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               ;;  Or, use linear interpolation to remove NaNs and end points
;               ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               IDL> z = remove_nans(x,y,/NO_EXTRAPOLATE)
;               IDL> HELP, WHERE(FINITE(z))
;               <Expression>    LONG      = Array[29]
;
;  KEYWORDS:    
;               LSQUADRATIC     :  If set, routine will use a least squares quadratic
;                                    fit to the equation y = a + bx + cx^2, for each
;                                    4 point neighborhood
;                                    [Default = FALSE]
;               QUADRATIC       :  If set, routine will use a least squares quadratic
;                                    fit to the equation y = a + bx + cx^2, for each
;                                    3 point neighborhood
;                                    [Default = FALSE]
;               SPLINE          :  If set, routine will use a cubic spline for each
;                                    4 point neighborhood
;                                    [Default = FALSE]
;               NO_EXTRAPOLATE  :  If set, program will not extrapolate end points
;                                    [Default = FALSE]
;
;   CHANGED:  1)  Updated routine to include new error handling functions/checks and
;                   and now calls is_a_number.pro and
;                   cleaned up a little
;                                                                   [11/10/2015   v1.1.0]
;
;   NOTES:      
;               1)  Unless the data is roughly linear, it is wise to set the keyword
;                     NO_EXTRAPOLATE
;
;   CREATED:  08/31/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/10/2015   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION remove_nans,in__x,in__y,LSQUADRATIC=lsquadratic,QUADRATIC=quadratic,$
                                 SPLINE=spline,NO_EXTRAPOLATE=no_extrapolate

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Error messages
noinput_mssg   = 'No input was supplied...'
incorrd_mssg   = 'Incorrect number of dimensions.  IN__X must have same dimensions as IN__Y.'
toofew__mssg   = 'Input does not have enough points to use for interpolation'
nofinit_mssg   = 'No finite data in IN__Y...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 2) OR $
                 (N_ELEMENTS(in__x) EQ 0) OR (N_ELEMENTS(in__y) EQ 0) OR $
                 (is_a_number(in__x,/NOMSSG) EQ 0) OR (is_a_number(in__y,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
xx             = REFORM(in__x)
yy             = REFORM(in__y)
szdx           = SIZE(xx,/DIMENSIONS)
szdy           = SIZE(yy,/DIMENSIONS)
sznx           = SIZE(xx,/N_DIMENSIONS)
szny           = SIZE(yy,/N_DIMENSIONS)
test           = (szdx[0] NE szdy[0]) OR (sznx GT 1) OR (szny GT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,incorrd_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (szdx[0] LT 3) OR (szdy[0] LT 3)
IF (test[0]) THEN BEGIN
  MESSAGE,toofew__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Redefine input and determine location of NaNs
;;----------------------------------------------------------------------------------------
test           = FINITE(yy)
good           = WHERE(test,gd)
IF (gd EQ 0) THEN BEGIN
  MESSAGE,nofinit_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
u_out          = xx
u__in          = xx[good]
v__in          = yy[good]
;;----------------------------------------------------------------------------------------
;;  Determine type of interpolation to use
;;----------------------------------------------------------------------------------------
i_type         = [KEYWORD_SET(lsquadratic),KEYWORD_SET(quadratic),KEYWORD_SET(spline)]
good_it        = WHERE(i_type,gdit)
IF (gdit GT 1) THEN BEGIN
  ;;  More than one option is set => Default to first
  i_type = good_it[0] + 1L
ENDIF ELSE BEGIN
  ;;  One or fewer options are set
  IF (gdit GT 0) THEN BEGIN
    ;;  One option is set
    i_type = good_it[0] + 1L
  ENDIF ELSE BEGIN
    ;;  No options were set => Use linear interpolation
    i_type = 0
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Interpolate
;;----------------------------------------------------------------------------------------
;;  Define type of interpolation to use
lsquad         = 0b & quad = 0b & ispl = 0b
CASE i_type[0] OF
  0L   :                ;;  Linearly interpolate
  1L   :  lsquad = 1b   ;;  Least-squares quadratic interpolation
  2L   :  quad   = 1b   ;;  Quadratic interpolation
  3L   :  ispl   = 1b   ;;  Cubic spline interpolation
  ELSE :  BEGIN
    ;;  Incorrect choice of interpolation type
    weird_mssg = 'I am not sure how this happened... Using linear interpolation'
    MESSAGE,weird_mssg[0],/INFORMATIONAL,/CONTINUE
  END
ENDCASE
int_str        = {LSQUADRATIC:lsquad,QUADRATIC:quad,SPLINE:ispl}
;;  Remove NaNs
out_y          = INTERPOL(v__in,u__in,u_out,_EXTRA=int_str)
;;----------------------------------------------------------------------------------------
;;  Remove end points if they were extrapolated
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(no_extrapolate) NE 0) AND KEYWORD_SET(no_extrapolate)
IF (test) THEN BEGIN
  ;;  First, find Min/Max elements of input that were finite
  good  = WHERE(FINITE(v__in),gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
  IF (gd GT 0) THEN BEGIN
    ;;  Remove end points
    mnmx  = [MIN(u__in[good],/NAN),MAX(u__in[good],/NAN)]
    test  = (u_out LT mnmx[0]) OR (u_out GT mnmx[1])
    bad   = WHERE(test,bd)
  ENDIF
  IF (bd GT 0) THEN out_y[bad] = f
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,out_y
END
