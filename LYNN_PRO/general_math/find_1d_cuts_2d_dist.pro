;+
;*****************************************************************************************
;
;  FUNCTION :   find_1d_cuts_2d_dist.pro
;  PURPOSE  :   This routine calculates the cuts of a regularly gridded distribution
;                 function, f(x,y), along two orthogonal vectors with intersection at
;                 {X_0, Y_0}.  The vector directions are defined by the optional
;                 keyword, ANGLE.  If this is not set, then the x-coordinate output
;                 corresponds to a line along the horizontal axis offset by X_0 and the
;                 y-coordinate output corresponds to a line along the vertical axis
;                 offset by Y_0.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               eulermat.pro
;               find_frac_indices.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               FXY      :  [N,N]-Element array defining the regularly gridded
;                             distribution function, f(x,y)
;               X__IN    :  [N]-Element array of regularly gridded coordinates
;                               corresponding to the 1st dimension in some function,
;                               f(x,y) [e.g., x-coordinate or independent coordinate]
;               Y__IN    :  [N]-Element array of regularly gridded coordinates
;                               corresponding to the 2nd dimension in some function,
;                               f(x,y) [e.g., y-coordinate or dependent coordinate]
;
;  EXAMPLES:    
;               [calling sequence]
;               test = find_1d_cuts_2d_dist(fxy, x__in, y__in [,X_0=x_0] [,Y_0=y_0]  $
;                                            [,ANGLE=angle] [,/FLOG] [,NX=nx] [,NY=ny])
;
;               ;;  Example usage
;               test = find_1d_cuts_2d_dist(fxy,x__in,y__in,/FLOG)
;
;  KEYWORDS:    
;               X_0      :  Scalar [numeric] defining the X-offset from zero for the
;                             center of the X-vector cut [e.g., parallel drift velocity]
;                             [Default = 0.0]
;               Y_0      :  Scalar [numeric] defining the Y-offset from zero for the
;                             center of the Y-vector cut [e.g., perpendicular drift
;                             velocity]
;                             [Default = 0.0]
;               ANGLE    :  Scalar [numeric] defining the angle [deg] from the Y-Axis by
;                             which to rotate the [X,Y]-cuts
;                             [Default = 0.0]
;               FLOG     :  If set, routine will use the natural log of FXY before
;                             interpolating to the locations defined by the cuts
;                             [Default = FALSE]
;               NX       :  Scalar [long] defining the # of elements along the
;                             x-coordinate to use for the output cut
;                             [Default = N_ELEMENTS(X__IN)]
;               NY       :  Scalar [long] defining the # of elements along the
;                             y-coordinate to use for the output cut
;                             [Default = N_ELEMENTS(Y__IN)]
;
;   CHANGED:  1)  Changed location to ~/general_math directory and cleaned up
;                                                                   [05/15/2014   v1.0.1]
;             2)  Added keyword:  FLOG
;                                                                   [06/21/2014   v1.1.0]
;             3)  Added keywords:  NX, NY and
;                   changed how cut abscissa are determined and
;                   now calls eulermat.pro
;                                                                   [06/23/2014   v1.2.0]
;             4)  Updated Man. page and cleaned up and
;                   now calls is_a_number.pro
;                                                                   [12/11/2015   v1.3.0]
;
;   NOTES:      
;               1)  See also IDL's documentation of INTERPOLATE.PRO and
;                     find_frac_indices.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/16/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/11/2015   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION find_1d_cuts_2d_dist,fxy,x__in,y__in,X_0=x_0,Y_0=y_0,ANGLE=angle,FLOG=flog,$
                              NX=nx,NY=ny

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, eulermat, find_frac_indices
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
bad_numin_msg  = 'Incorrect number of inputs!'
bad_xyf_formsg = '[X,Y]__IN and FXY all must be numeric arrays...'
bad_x__in_msg  = '[X,Y]__IN both must be [N]-element arrays, N=1,2,...'
bad_fxy_msg    = 'FXY must be an [N,N]-element array, N=1,2,...'
;;  Create dummy return structure
tag_prefx      = ['X_','Y_']
tag_suffx      = ['1D_FXY','CUT_COORD','0','XY_COORD']
tags           = [tag_prefx[0]+tag_suffx,tag_prefx[1]+tag_suffx]
dumb1d         = REPLICATE(d,10L)
dumb2d         = [[dumb1d],[dumb1d]]
dummy          = CREATE_STRUCT(tags,dumb1d,dumb1d,d,dumb2d,dumb1d,dumb1d,d,dumb2d)
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 3)
IF (test[0]) THEN BEGIN
  ;;  Must be 3 inputs supplied
  MESSAGE,bad_numin_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy
ENDIF
test           = (N_ELEMENTS(x__in)  EQ 0) OR (N_ELEMENTS(y__in)  EQ 0) OR $
                 (N_ELEMENTS(fxy)  EQ 0) OR (is_a_number(x__in,/NOMSSG) EQ 0) OR $
                 (is_a_number(y__in,/NOMSSG) EQ 0) OR (is_a_number(fxy,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  Bad input format(s)
  MESSAGE,bad_xyf_formsg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy
ENDIF
;test           = (N_ELEMENTS(x__in)  EQ 0) OR (N_ELEMENTS(y__in)  EQ 0) OR $
;                 (N_ELEMENTS(x__in)  NE N_ELEMENTS(y__in))
szf            = SIZE(fxy,/DIMENSIONS)
test           = (N_ELEMENTS(x__in)  NE N_ELEMENTS(y__in)) OR (N_ELEMENTS(szf) NE 2)
IF (test[0]) THEN BEGIN
  IF (N_ELEMENTS(szf) NE 2) THEN BEGIN
    ;;  FXY must be a 2D array
    MESSAGE,bad_fxy_msg[0],/INFORMATIONAL,/CONTINUE
  ENDIF ELSE BEGIN
    ;;  X__IN and Y__IN must have the same number of elements
    MESSAGE,bad_x__in_msg[0],/INFORMATIONAL,/CONTINUE
  ENDELSE
  RETURN,dummy
ENDIF
x_i            = REFORM(x__in)
y_i            = REFORM(y__in)
nvx            = N_ELEMENTS(x_i)
nvy            = N_ELEMENTS(y_i)
test           = (N_ELEMENTS(fxy) EQ 0) OR $
                 (szf[0] NE N_ELEMENTS(x__in)) OR (szf[1] NE N_ELEMENTS(y__in))
IF (test[0]) THEN BEGIN
  ;;  FXY must be an [N,N]-element array
  MESSAGE,bad_fxy_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dummy
ENDIF
fv             = REFORM(fxy)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check X_0 and Y_0
test           = (N_ELEMENTS(x_0) LT 1) OR (is_a_number(x_0,/NOMSSG) EQ 0)
IF (test[0]) THEN x_o  = 0d0 ELSE x_o  = x_0[0]
test           = (N_ELEMENTS(y_0) LT 1) OR (is_a_number(y_0,/NOMSSG) EQ 0)
IF (test[0]) THEN y_o  = 0d0 ELSE y_o  = y_0[0]
;;  Check ANGLE
test           = (N_ELEMENTS(angle) LT 1) OR (is_a_number(angle,/NOMSSG) EQ 0)
IF (test[0]) THEN ang  = 0d0 ELSE ang  = angle[0]
;;  Check FLOG
test           = (N_ELEMENTS(flog) EQ 0) OR ~KEYWORD_SET(flog)
IF (test[0])                THEN lnf  = 0b  ELSE lnf  = 1b
;; Make sure offsets and angle are finite
IF (FINITE(x_o) EQ 0) THEN x_o  = 0d0
IF (FINITE(y_o) EQ 0) THEN y_o  = 0d0
IF (FINITE(ang) EQ 0) THEN ang  = 0d0
;;  Check NX and NY
test           = (N_ELEMENTS(nx) LT 1) OR (is_a_number(nx,/NOMSSG) EQ 0)
IF (test[0]) THEN xn   = nvx[0] ELSE xn   = nx[0]
test           = (N_ELEMENTS(ny) LT 1) OR (is_a_number(ny,/NOMSSG) EQ 0)
IF (test[0]) THEN yn   = nvy[0] ELSE yn   = ny[0]
;;----------------------------------------------------------------------------------------
;;  Define XY ranges
;;----------------------------------------------------------------------------------------
xzeros         = REPLICATE(0d0,xn[0])
yzeros         = REPLICATE(0d0,yn[0])
xran           = [MIN(x_i,/NAN),MAX(x_i,/NAN)]*1.05
yran           = [MIN(y_i,/NAN),MAX(y_i,/NAN)]*1.05
;;----------------------------------------------------------------------------------------
;;  Define XY crosshairs
;;----------------------------------------------------------------------------------------
;;  Define dummy X-crosshairs at origin parallel to XY-axes
xxdum          = DINDGEN(xn[0])*(xran[1] - xran[0])/(xn[0] - 1L) + xran[0]
xydum          = DINDGEN(xn[0])*(yran[1] - yran[0])/(xn[0] - 1L) + yran[0]
xyzxdum        = [[xxdum],[xzeros],[xzeros]]
;;  Define dummy Y-crosshairs at origin parallel to XY-axes
yxdum          = DINDGEN(yn[0])*(xran[1] - xran[0])/(yn[0] - 1L) + xran[0]
yydum          = DINDGEN(yn[0])*(yran[1] - yran[0])/(yn[0] - 1L) + yran[0]
xyzydum        = [[yzeros],[yydum],[yzeros]]
;;  Rotate crosshair lines by angle ø
rmat           = eulermat(0d0,ang[0],0d0,/DEG)
xyzxrot        = REFORM(rmat ## xyzxdum)
xyzyrot        = REFORM(rmat ## xyzydum)
;;  Offset crosshairs by {X_0, Y_0}
xyzxproj       = xyzxrot
xyzyproj       = xyzyrot
xyzxproj[*,0] += x_o[0]
xyzxproj[*,1] += y_o[0]
xyzyproj[*,0] += x_o[0]
xyzyproj[*,1] += y_o[0]
;;----------------------------------------------------------------------------------------
;;  Find corresponding indices of f(x,y) corresponding to crosshairs
;;----------------------------------------------------------------------------------------
xyfindx        = find_frac_indices(x_i,y_i,xyzxproj[*,0],xyzxproj[*,1])
xyfindy        = find_frac_indices(x_i,y_i,xyzyproj[*,0],xyzyproj[*,1])
test           = (SIZE(xyfindx,/TYPE) NE 8) OR (SIZE(xyfindy,/TYPE) NE 8)
IF (test[0]) THEN RETURN,dummy    ;;  output was bad --> return dummy structure
;;  Check output
test0          = (TOTAL(FINITE(xyfindx.X_IND)) EQ 0) OR (TOTAL(FINITE(xyfindx.Y_IND)) EQ 0)
test1          = (TOTAL(FINITE(xyfindy.X_IND)) EQ 0) OR (TOTAL(FINITE(xyfindy.Y_IND)) EQ 0)
IF (test0[0] OR test1[0]) THEN RETURN,dummy    ;;  output was bad --> return dummy structure
;;----------------------------------------------------------------------------------------
;;  Define cut through f(x,y) at angle ø and offset {X_0, Y_0}
;;----------------------------------------------------------------------------------------
;;  Convert to log-space if necessary
IF (lnf[0]) THEN df_e = ALOG(fv) ELSE df_e = fv
;;  Calculate values of f(x,y) along cut lines
df_ran         = [MIN(df_e,/NAN),MAX(df_e,/NAN)]
dfcut_x        = INTERPOLATE(df_e,xyfindx.X_IND,xyfindx.Y_IND,MISSING=d)
dfcut_y        = INTERPOLATE(df_e,xyfindy.X_IND,xyfindy.Y_IND,MISSING=d)
;;  Remove "bad" points due to extrapolation
testx          = (dfcut_x GT df_ran[1]) OR (dfcut_x LT df_ran[0])
testy          = (dfcut_y GT df_ran[1]) OR (dfcut_y LT df_ran[0])
badx           = WHERE(testx,bdx,COMPLEMENT=goodx,NCOMPLEMENT=gdx)
bady           = WHERE(testy,bdy,COMPLEMENT=goody,NCOMPLEMENT=gdy)
IF (bdx GT 0) THEN dfcut_x[badx] = d
IF (bdy GT 0) THEN dfcut_y[bady] = d
;;  Return to regular if in log-space
IF (lnf[0])   THEN dfcut_x = EXP(dfcut_x)
IF (lnf[0])   THEN dfcut_y = EXP(dfcut_y)
;;----------------------------------------------------------------------------------------
;;  Define new coordinates for output
;;----------------------------------------------------------------------------------------
;;  Define [X,Y] projection coordinates
xy_proj_x      = [[xyzxproj[*,0]],[xyzxproj[*,1]]]
xy_proj_y      = [[xyzyproj[*,0]],[xyzyproj[*,1]]]
;;  Define x-cut projection coordinates
x_proj         = xyzxproj[*,0]
;;  Define y-cut projection coordinates
y_proj         = xyzyproj[*,1]
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
tag_prefx      = ['X_','Y_']
tag_suffx      = ['1D_FXY','CUT_COORD','0','XY_COORD','XY_INDS']
tags           = [tag_prefx[0]+tag_suffx,tag_prefx[1]+tag_suffx]
struct         = CREATE_STRUCT(tags,dfcut_x,x_proj,x_o,xy_proj_x,xyfindx,$
                                    dfcut_y,y_proj,y_o,xy_proj_y,xyfindy)
;;----------------------------------------------------------------------------------------
;;  Return structure to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END








;IF (N_ELEMENTS(x_0)   NE 1) THEN x_o  = 0d0 ELSE x_o  = x_0[0]
;IF (N_ELEMENTS(y_0)   NE 1) THEN y_o  = 0d0 ELSE y_o  = y_0[0]
;IF (N_ELEMENTS(angle) NE 1) THEN ang  = 0d0 ELSE ang  = angle[0]
;;;  Check FLOG
;test           = (N_ELEMENTS(flog) EQ 0) OR ~KEYWORD_SET(flog)
;IF (test[0])                THEN lnf  = 0b  ELSE lnf  = 1b
;;; Make sure offsets and angle are finite
;IF (FINITE(x_o)       NE 1) THEN x_o  = 0d0
;IF (FINITE(y_o)       NE 1) THEN y_o  = 0d0
;IF (FINITE(ang)       NE 1) THEN ang  = 0d0
;;;  Check NX and NY
;IF (N_ELEMENTS(nx)    NE 1) THEN xn   = nvx[0] ELSE xn   = nx[0]
;IF (N_ELEMENTS(ny)    NE 1) THEN yn   = nvy[0] ELSE yn   = ny[0]
