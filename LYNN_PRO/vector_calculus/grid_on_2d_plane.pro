;+
;*****************************************************************************************
;
;  FUNCTION :   grid_on_2d_plane.pro
;  PURPOSE  :   This routine takes an input function, ƒ(x,y), [where x,y are the the
;                 coordinates in a 2D plane] of irregularly or regularly gridded data
;                 and re-grids the data onto a 2D plane with uniform spacing.  The
;                 routine is a wrapper for GRID_INPUT.PRO and GRIDDATA.PRO using the
;                 "Inverse Distance" method for gridding.
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
;               X           :  [N]-Element [long/float/double] array of X-coordinates
;                                defining the function at F = F[X[i],Y[j]]
;               Y           :  [M]-Element [long/float/double] array of Y-coordinates
;                                defining the function at F = F[X[i],Y[j]]
;               F           :  [N,M]- or [N]-Element [float/double] array of functional
;                                values at the coordinates {X[i],Y[j]}.  If 1D input,
;                                then M = N, thus all inputs must have the same number
;                                of elements.
;
;  EXAMPLES:    
;               [See examples in GRID_INPUT.PRO and GRIDDATA.PRO documentation]
;
;  KEYWORDS:    
;               XOUT        :  [K]-Element [long/float/double] array of X-coordinates to
;                                use as the final grid points returned by GRIDDATA.PRO
;               YOUT        :  [L]-Element [long/float/double] array of Y-coordinates to
;                                use as the final grid points returned by GRIDDATA.PRO
;               NX          :  Scalar [long] defining the # of X-grid points to be
;                                returned by GRIDDATA.PRO
;               NY          :  Scalar [long] defining the # of Y-grid points to be
;                                returned by GRIDDATA.PRO
;               XLOG        :  Scalar [long] defining whether to use the base-10 log of
;                                X when defining a grid and gridding data.  If XOUT is
;                                set, then it is assumed that XOUT is still on a linear
;                                scale so the base-10 log of XOUT is used in the
;                                gridding process.
;                                [Default = FALSE]
;               YLOG        :  Scalar [long] defining whether to use the base-10 log of
;                                Y when defining a grid and gridding data.  If YOUT is
;                                set, then it is assumed that YOUT is still on a linear
;                                scale so the base-10 log of YOUT is used in the
;                                gridding process.
;                                [Default = FALSE]
;               DUPLICATES  :  Scalar [string] defining how routine will handle duplicate
;                                values of F[i,j] at duplicate coordinates {X[i],Y[j]}.
;                                Accepted inputs include:
;                                [Default = "First"]
;                                  "First"     :  Retain only the first encounter of the
;                                                   duplicate locations.
;                                  "Last"      :  Retain only the last encounter of the
;                                                   duplicate locations.
;                                  "All"       :  Retains all locations, which is invalid
;                                                   for any gridding technique that
;                                                   requires a TRIANGULATION.  Some
;                                                   methods, such as Inverse Distance
;                                                   or Polynomial Regression with no
;                                                   search criteria can handle
;                                                   duplicates.
;                                  "Avg"       :  Retain the average F value of the
;                                                   duplicate locations.
;                                  "Midrange"  :  Retain the average of the minimum and
;                                                   maximum duplicate locations
;                                                   (Max(F) + Min (F))/2 .
;                                  "Min"       :  Retain the minimum of the duplicate
;                                                   locations Min(F).
;                                  "Max"       :  Retain the maximum of the duplicate
;                                                   locations Max(F).
;                                  "Sum"       :  Sum the values of F at the duplicate
;                                                   locations, TOTAL(F).
;               METHOD      :  Scalar [string] defining which method to use to grid
;                                input.  Currently accepted methods include:
;                                [Default = "invdist"]
;                                  "invdist"   :  "InverseDistance"
;                                                   Data points closer to the grid points
;                                                   have more effect than those which are
;                                                   further away.
;                                  "triangle"  :  Use TRIANGULATE.PRO and TRIGRID.PRO
;                                                   Data points are re-gridded using
;                                                   Delaunay triangulation
;                                  "kriging"   :  "Kriging"
;                                                   Data points and their spatial variance
;                                                   are used to determine trends which are
;                                                   applied to the grid points.
;                                  "polyregr"  :  "PolynomialRegression"
;                                                   Each interpolant is a least-squares
;                                                   fit of a polynomial in X and Y of the
;                                                   specified power to the specified data
;                                                   points.
;                                  "radfunc"   :  "RadialBasisFunction"
;                                                   The effects of data points are
;                                                   weighted by a function of their radial
;                                                   distance from a grid point.
;                                                   [currently defaulted to a thin plate
;                                                    spline basis function]
;               POWER       :  Scalar [long] defining the polynomial order for "polyregr"
;                                or the weighting power for "invdist".  This is
;                                equivalent to the POWER keyword in GRIDDATA.PRO.
;                                [Default = 3 for "radfunc", = 2 for "invdist"]
;               SMOOTHING   :  Scalar [float/double] defining smoothing radius.  This is
;                                equivalent to the SMOOTHING keyword in GRIDDATA.PRO.
;                                [Default = 0 for "invdist", 8*(∆X + ∆Y)/2 for "radfunc"]
;               MIN_POINTS  :  Scalar [long] defining the minimum # of points to use
;                                if ELLIPSE keyword is not set.  Otherwise, it is the
;                                minimum # of points allowed in all sectors before a
;                                grid point is set to a NaN.  This is equivalent to the
;                                MIN_POINTS keyword in GRIDDATA.PRO.
;                                [Default = {not set}]
;               ELLIPSE     :  [2]-Element [float/double] array defining the elliptical
;                                region to search for data points relative to the center
;                                defined at each grid point (e.g., [XOUT[i],YOUT[i]]).
;                                This is equivalent to the SEARCH_ELLIPSE keyword in
;                                GRIDDATA.PRO.
;                                [Default = {not set}]
;               VARIOGRAM   :  [4]-Element array defining the variogram type and
;                                parameters for the Kriging method, where each element
;                                is defined:  [ Type, Range, Nugget, Scale]
;                                  Type   = defines covariance equation, with inputs of:
;                                       1 = Linear      : S (1 - d/R)
;                                       2 = Exponential : S e^(-3 d/R)
;                                       3 = Gaussian    : S e^(-3 d^2/R^2)
;                                       4 = Spherical   : S [1 - 3/2 (d/2) + 1/2 (d/2)^2]
;                                  Range  = R in covariance equations above
;                                  Nugget = nugget value defining covariance
;                                             weighting ( = N + S @ d=0)
;                                  Scale  = S in covariance equations above
;                                  d      = distance from a point in the input array to
;                                             a point in the result
;                                This is equivalent to the VARIOGRAM keyword in
;                                GRIDDATA.PRO.
;                                [Default = [3, 8*(∆X + ∆Y)/2, 0, 1] ]
;               NG_ISUM     :  If set, routine will not use the gridded result returned
;                                by GRIDDATA.PRO, only the results returned by
;                                GRID_INPUT.PRO.
;                                **  Useful for checking results  **
;                                [Default = FALSE]
;
;   CHANGED:  1)  Added keywords:  METHOD, XLOG, YLOG
;                                                                   [05/12/2014   v1.1.0]
;             2)  Added keywords:  POWER, SMOOTH, MIN_POINTS, ELLIPSE, VARIOGRAM, and
;                   NG_ISUM and
;                   methods:  "RadialBasisFunction", "Kriging", and 
;                   "PolynomialRegression" and
;                   added associated error handling to deal with new keywords and methods
;                                                                   [05/12/2014   v1.2.0]
;             3)  Now uses _EXTRA keyword in calls to GRIDDATA.PRO and
;                   now calls extract_tags.pro
;                                                                   [05/15/2014   v1.3.0]
;
;   NOTES:      
;               1)  To avoid a crash, make sure X and Y are not colinear on input
;               2)  If using MIN_POINTS and METHOD="polyregr", then:
;                     MIN_POINTS > 2  for  POWER=1
;                     MIN_POINTS > 5  for  POWER=2
;                     MIN_POINTS > 9  for  POWER=3
;               3)  Only XOUT and YOUT account for the use of XLOG or YLOG
;                     -->  SMOOTHING and ELLIPSE should be scaled before calling if user
;                            sets XLOG and/or YLOG
;               F)  Future plans:
;                     a)  incorporate more options for GRIDDATA.PRO
;
;  REFERENCES:  
;               1)  See reference list for IDL's documentation of GRIDDATA.PRO
;
;   CREATED:  05/10/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/15/2014   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION grid_on_2d_plane,x,y,f,XOUT=xout,YOUT=yout,NX=nx0,NY=ny0,XLOG=xlog,YLOG=ylog, $
                          DUPLICATES=duplicates,METHOD=grid_meth,POWER=power,          $
                          SMOOTHING=smoothing,MIN_POINTS=min_points,ELLIPSE=ellipse,   $
                          VARIOGRAM=variogram,NG_ISUM=ng_isum,_EXTRA=extra

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
;f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Error messages
noinput_mssg   = 'Incorrect input was supplied... See Man. page for details.'
no_fin_dat_msg = 'No finite data input...'
bad_f__nd_msg  = 'F must be a 1- or 2-dimensional array...'
bad_x__dm_msg  = 'X must be an [N]-element array...'
bad_y__dm_msg  = 'Y must be an [M]-element array...'
bad_f__2d_msg  = 'F must be an [N,M]-element array...'
bad_kdupl_msg  = 'Incorrect keyword format:  DUPLICATES... Using Default = "First"'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1)
IF (test[0]) THEN BEGIN
  ;;  no input???
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check input format
;;----------------------------------------------------------------------------------------
szd_x          = SIZE(REFORM(x),/DIMENSIONS)
szd_y          = SIZE(REFORM(y),/DIMENSIONS)
;;  First make sure X and Y are 1D arrays
test           = (N_ELEMENTS(szd_x) NE 1) OR (N_ELEMENTS(szd_y) NE 1)
IF (test[0]) THEN BEGIN
  ;;  bad X(Y) input???
  IF (N_ELEMENTS(szd_x) NE 1) THEN MESSAGE,'0: '+bad_x__dm_msg[0],/INFORMATIONAL,/CONTINUE
  IF (N_ELEMENTS(szd_y) NE 1) THEN MESSAGE,'0: '+bad_y__dm_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
szd_f          = SIZE(REFORM(f),/DIMENSIONS)
szn_f          = SIZE(REFORM(f),/N_DIMENSIONS)
is_1D          = (szn_f[0] EQ 1)
is_2D          = (szn_f[0] EQ 2)
IF (is_1D[0]) THEN BEGIN
  ;;  F is 1D
  test           = (szd_x[0] NE szd_f[0]) OR (szd_y[0] NE szd_f[0])
  IF (test[0]) THEN BEGIN
    ;;  Incorrect input formats
    MESSAGE,'1: '+bad_x__dm_msg[0],/INFORMATIONAL,/CONTINUE
    MESSAGE,'1: '+bad_y__dm_msg[0],/INFORMATIONAL,/CONTINUE
    MESSAGE,'1: '+bad_f__2d_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0
  ENDIF ELSE BEGIN
    ;;  Good --> Define parameters
    ff  = REFORM(f)
    xx  = REFORM(x)
    yy  = REFORM(y)
  ENDELSE
ENDIF ELSE BEGIN
  ;;  F is NOT 1D
  IF (is_2D[0]) THEN BEGIN
    ;;  F is 2D
    testx          = (szd_x[0] EQ szd_f[0]) OR (szd_x[0] EQ szd_f[1])
    testy          = (szd_y[0] EQ szd_f[0]) OR (szd_y[0] EQ szd_f[1])
    test           = testx AND testy
    IF (test[0]) THEN BEGIN
      ;;  Make sure F = [N,M]-element array
      test           = (szd_x[0] EQ szd_f[0]) AND (szd_y[0] EQ szd_f[1])
      IF (test[0]) THEN BEGIN
        ;;  Good --> Define parameters
        ff  = REFORM(f)
        xx  = REFORM(x) # REPLICATE(1d0,szd_y[0])
        yy  = REPLICATE(1d0,szd_x[0]) # REFORM(y)
      ENDIF ELSE BEGIN
        ;;  Transpose?
        test           = (szd_x[0] EQ szd_f[1]) AND (szd_y[0] EQ szd_f[0])
        IF (test[0]) THEN BEGIN
          ;;  Good --> Define parameters
          ff  = TRANSPOSE(f)
          xx  = REFORM(x) # REPLICATE(1d0,szd_y[0])
          yy  = REPLICATE(1d0,szd_x[0]) # REFORM(y)
        ENDIF ELSE BEGIN
          ;;  Something is wrong...
          STOP
        ENDELSE
      ENDELSE
    ENDIF ELSE BEGIN
      ;;  Incorrect input formats
      MESSAGE,'2: '+bad_x__dm_msg[0],/INFORMATIONAL,/CONTINUE
      MESSAGE,'2: '+bad_y__dm_msg[0],/INFORMATIONAL,/CONTINUE
      MESSAGE,'2: '+bad_f__2d_msg[0],/INFORMATIONAL,/CONTINUE
      RETURN,0
    ENDELSE
  ENDIF ELSE BEGIN
    ;;  Incorrect dimensions:  F
    MESSAGE,bad_f__nd_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0
  ENDELSE
ENDELSE
;;  If 2D input, reform into 1D arrays
IF (is_2D[0]) THEN BEGIN
  xx_1d = REFORM(xx,szd_x[0]*szd_y[0])
  yy_1d = REFORM(yy,szd_x[0]*szd_y[0])
  ff_1d = REFORM(ff,szd_x[0]*szd_y[0])
ENDIF ELSE BEGIN
  xx_1d = xx
  yy_1d = yy
  ff_1d = ff
ENDELSE
;;  Sort by X-component
sp             = SORT(xx_1d)
xx_1d          = xx_1d[sp]
yy_1d          = yy_1d[sp]
ff_1d          = ff_1d[sp]
;;  Use only finite data
test           = FINITE(xx_1d) AND FINITE(yy_1d) AND FINITE(ff_1d)
good           = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
IF (gd[0] EQ 0) THEN BEGIN
  MESSAGE,no_fin_dat_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;  Keep only finite data
xx_1d          = xx_1d[good]
yy_1d          = yy_1d[good]
ff_1d          = ff_1d[good]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check DUPLICATES
test           = (N_ELEMENTS(duplicates) NE 1) OR (SIZE(duplicates,/TYPE) NE 7)
IF (test[0]) THEN dups = "First" ELSE dups = duplicates[0]
allowed        = ['first','last','all','avg','midrange','min','max','sum']
test           = TOTAL(STRLOWCASE(dups[0]) EQ allowed) NE 1
IF (test[0]) THEN BEGIN
  ;;  Incorrect keyword format:  DUPLICATES
  MESSAGE,bad_kdupl_msg[0],/INFORMATIONAL,/CONTINUE
  dups = "First"
ENDIF
;;  Check XLOG
test           = (N_ELEMENTS(xlog) EQ 0) OR ~KEYWORD_SET(xlog)
IF (test[0]) THEN logx = 0 ELSE logx = 1
;;  Check YLOG
test           = (N_ELEMENTS(ylog) EQ 0) OR ~KEYWORD_SET(ylog)
IF (test[0]) THEN logy = 0 ELSE logy = 1
;;  Check METHOD
IF (N_ELEMENTS(grid_meth) EQ 0) THEN gmeth = 0   ELSE gmeth = 1
IF (gmeth) THEN g_meth = STRLOWCASE(grid_meth[0]) ELSE g_meth = "invdist"
;;----------------------------------------------------------------------------------------
;;  Grid input
;;----------------------------------------------------------------------------------------
CASE STRLOWCASE(dups[0]) OF
  'sum'  :  BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Sum the duplicates
    ;;------------------------------------------------------------------------------------
    ;;  First find unique X and Y values
    GRID_INPUT,xx_1d,yy_1d,ff_1d,x_s0,y_s0,f_s0,DUPLICATES="First"
    nuqx   = N_ELEMENTS(x_s0)
    x_s    = x_s0
    y_s    = y_s0
    f_s    = REPLICATE(d,nuqx[0])
    cs     = 0
    FOR j=0L, nuqx[0] - 1L DO BEGIN
      jstr     = 'J'+STRING(j[0],FORMAT='(I4.4)')
      test     = (xx_1d EQ x_s0[j]) AND (yy_1d EQ y_s0[j])
      good     = WHERE(test,gd)
      IF (gd GT 1) THEN BEGIN
        ;;  Duplicates found!  --> Sum
        f_s[j] = TOTAL(ff_1d[good],/NAN)
        ;;  Count # of points that were summed
        cs++
      ENDIF ELSE BEGIN
        ;;  No duplicates
        f_s[j] = f_s0[j]
      ENDELSE
    ENDFOR
    PRINT,'Used SUM method...'
  END
  ELSE   :  BEGIN
    ;;  Use one of the standard settings for DUPLICATES
    GRID_INPUT,xx_1d,yy_1d,ff_1d,x_s,y_s,f_s,DUPLICATES=dups[0]
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check XOUT and NX
IF (logx[0]) THEN l_x_s = ALOG10(x_s) ELSE l_x_s = x_s
test0          = (N_ELEMENTS(xout) EQ 0) AND (N_ELEMENTS(nx0) EQ 0)
test1          = WHERE([(N_ELEMENTS(xout) NE 0),(N_ELEMENTS(nx0) NE 0)])
logic_xo_nx    = [0,0]
IF (test0[0]) THEN BEGIN
;  IF (logx[0]) THEN l_x_s = ALOG10(x_s) ELSE l_x_s = x_s
  ;;  Neither XOUT nor NX were set --> define
  unq_x          = UNIQ(l_x_s,SORT(l_x_s))
  nx             = N_ELEMENTS(unq_x)
  dx             = (MAX(l_x_s,/NAN) - MIN(l_x_s,/NAN))/(nx[0] - 1)
  intercept      = MIN(l_x_s,/NAN)
  xGrid          = dx[0]*FINDGEN(nx[0]) + intercept[0]
ENDIF ELSE BEGIN
  IF (N_ELEMENTS(test1) EQ 2) THEN logic_xo_nx[*] = 1
  CASE test1[0] OF
    0 : BEGIN
      IF (logx[0]) THEN l_xout = ALOG10(xout) ELSE l_xout = xout
      ;;  User set XOUT
;      l_x_s          = x_s
      nx             = N_ELEMENTS(l_xout)
      dx             = (MAX(l_xout,/NAN) - MIN(l_xout,/NAN))/(nx[0] - 1)
      xGrid          = l_xout
      logic_xo_nx[0] = 1
    END
    1 : BEGIN
;      IF (logx[0]) THEN l_x_s = ALOG10(x_s) ELSE l_x_s = x_s
      ;;  User set NX
      nx             = nx0[0]
      dx             = (MAX(l_x_s,/NAN) - MIN(l_x_s,/NAN))/(nx[0] - 1)
      intercept      = MIN(l_x_s,/NAN)
      xGrid          = dx[0]*FINDGEN(nx[0]) + intercept[0]
      logic_xo_nx[1] = 1
    END
    ELSE : BEGIN
;      IF (logx[0]) THEN l_x_s = ALOG10(x_s) ELSE l_x_s = x_s
      ;;  How did this happen?  --> use defaults
      unq_x          = UNIQ(l_x_s,SORT(l_x_s))
      nx             = N_ELEMENTS(unq_x)
      dx             = (MAX(l_x_s,/NAN) - MIN(l_x_s,/NAN))/(nx[0] - 1)
      intercept      = MIN(l_x_s,/NAN)
      xGrid          = dx[0]*FINDGEN(nx[0]) + intercept[0]
      logic_xo_nx[*] = 0
    END
  ENDCASE
ENDELSE
;;  Check YOUT and NY
IF (logy[0]) THEN l_y_s = ALOG10(y_s) ELSE l_y_s = y_s
test0          = (N_ELEMENTS(yout) EQ 0) AND (N_ELEMENTS(ny0) EQ 0)
test1          = WHERE([(N_ELEMENTS(yout) NE 0),(N_ELEMENTS(ny0) NE 0)])
logic_yo_ny    = [0,0]
IF (test0[0]) THEN BEGIN
  IF (logy[0]) THEN l_y_s = ALOG10(y_s) ELSE l_y_s = y_s
  ;;  Neither YOUT nor NY were set --> define
  unq_y          = UNIQ(l_y_s,SORT(l_y_s))
  ny             = N_ELEMENTS(unq_y)
  dy             = (MAX(l_y_s,/NAN) - MIN(l_y_s,/NAN))/(ny[0] - 1)
  intercept      = MIN(l_y_s,/NAN)
  yGrid          = dy[0]*FINDGEN(ny[0]) + intercept[0]
ENDIF ELSE BEGIN
  IF (N_ELEMENTS(test1) EQ 2) THEN logic_yo_ny[*] = 1
  CASE test1[0] OF
    0 : BEGIN
      ;;  User set YOUT
;      l_y_s          = y_s
      IF (logy[0]) THEN l_yout = ALOG10(yout) ELSE l_yout = yout
      ny             = N_ELEMENTS(l_yout)
      dy             = (MAX(l_yout,/NAN) - MIN(l_yout,/NAN))/(ny[0] - 1)
      yGrid          = l_yout
      logic_yo_ny[0] = 1
    END
    1 : BEGIN
;      IF (logy[0]) THEN l_y_s = ALOG10(y_s) ELSE l_y_s = y_s
      ;;  User set NY
      ny             = ny0[0]
      dy             = (MAX(l_y_s,/NAN) - MIN(l_y_s,/NAN))/(ny[0] - 1)
      intercept      = MIN(l_y_s,/NAN)
      yGrid          = dy[0]*FINDGEN(ny[0]) + intercept[0]
      logic_yo_ny[1] = 1
    END
    ELSE : BEGIN
;      IF (logy[0]) THEN l_y_s = ALOG10(y_s) ELSE l_y_s = y_s
      ;;  How did this happen?  --> use defaults
      unq_y          = UNIQ(l_y_s,SORT(l_y_s))
      ny             = N_ELEMENTS(unq_y)
      dy             = (MAX(l_y_s,/NAN) - MIN(l_y_s,/NAN))/(ny[0] - 1)
      intercept      = MIN(l_y_s,/NAN)
      yGrid          = dy[0]*FINDGEN(ny[0]) + intercept[0]
      logic_yo_ny[*] = 0
    END
  ENDCASE
ENDELSE
;;  Define grid dimensions and spacing
gs             = [nx[0],ny[0]]
gsout          = [dx[0],dy[0]]
;;----------------------------------------------------------------------------------------
;;  Re-grid data
;;----------------------------------------------------------------------------------------
;IF (N_ELEMENTS(min_points) EQ 1) THEN STOP
;;  Check if MIN_POINTS or ELLIPSE keywords were set --> need TRIANGLES
test           = (N_ELEMENTS(min_points) EQ 1) OR (N_ELEMENTS(ellipse) GT 0) OR $
                 (g_meth[0] EQ "triangle")
IF (test[0]) THEN BEGIN
  need_tr = 1
  ;;  At least one of them was set --> call TRIANGULATE.PRO
  TRIANGULATE,l_x_s,l_y_s,tr_s,i_b
ENDIF ELSE need_tr = 0
;;  Check if POWER keyword was set
IF (N_ELEMENTS(power) EQ 0) THEN gpow = 3 ELSE gpow = (power[0] > 1) < 3

;;  Set up default structure containing common tags
miss           = d
IF (need_tr[0]) THEN BEGIN
  grid_str = {MISSING:miss[0],DIMENSION:gs,DELTA:gsout,GRID:1,SPHERE:0,TRIANGLES:tr_s}
ENDIF ELSE BEGIN
  grid_str = {MISSING:miss[0],DIMENSION:gs,DELTA:gsout,GRID:1,SPHERE:0}
ENDELSE
;;  Check if _EXTRA keyword was set
IF (SIZE(extra,/TYPE) EQ 8) THEN extract_tags,grid_str,extra,/PRESERVE

avg_dxdy       = (dx[0] + dy[0])/2d0
IF KEYWORD_SET(ng_isum) THEN BEGIN
  method         = "No Gridding --> Output dimensions may not match [NX,NY]"
  ;;--------------------------------------------------------------------------------------
  ;;  Create return structure
  ;;--------------------------------------------------------------------------------------
  tags           = ['XG_IN','YG_IN','F_G_IN','XGRID','YGRID']
  struc0         = CREATE_STRUCT(tags,x_s,y_s,f_s,xGrid,yGrid)
  tags           = ['XGRID','YGRID','F_GRID','METHOD','GRID_IN']
  struc          = CREATE_STRUCT(tags,l_x_s,l_y_s,f_s,method[0],struc0)
  ;;--------------------------------------------------------------------------------------
  ;;  Return to user
  ;;--------------------------------------------------------------------------------------
;  STOP
  RETURN,struc
ENDIF ELSE BEGIN
  CASE g_meth[0] OF
    "invdist"   : BEGIN
      ;;  Inverse Distance method
      method = "InverseDistance"
      meth   = "InverseDistance"
      result = GRIDDATA(l_x_s,l_y_s,f_s,_EXTRA=grid_str[0],METHOD=meth[0],POWER=gpow[0],$
                        /INVERSE_DISTANCE,XOUT=xGrid,YOUT=yGrid,SMOOTHING=smoothing,    $
                        MIN_POINTS=min_points,SEARCH_ELLIPSE=ellipse)
    END
    "polyregr"  :  BEGIN
      ;;  Polynomial Regression method [cubic spline]
      method = 'Polynomial Regression [cubic spline]'
      meth   = "PolynomialRegression"
      ;;  Grid the data
      result = GRIDDATA(l_x_s,l_y_s,f_s,_EXTRA=grid_str[0],METHOD=meth[0],POWER=gpow[0],  $
                        /POLYNOMIAL_REGRESSION,XOUT=xGrid,YOUT=yGrid,SMOOTHING=smoothing, $
                        MIN_POINTS=min_points,SEARCH_ELLIPSE=ellipse)
    END
    "kriging"   :  BEGIN
      ;;  Kriging method with Gaussian variogram
      method = 'Kriging [with Gaussian variogram]'
      meth   = "Kriging"
      vran   = 8d0*avg_dxdy[0]
      ;;  Check if VARIOGRAM was set
      IF (N_ELEMENTS(variogram) NE 4) THEN vari = [3,vran[0],0,1] ELSE vari = variogram
      result = GRIDDATA(l_x_s,l_y_s,f_s,_EXTRA=grid_str[0],METHOD=meth[0],/KRIGING,     $
                        XOUT=xGrid,YOUT=yGrid,SMOOTHING=smoothing,MIN_POINTS=min_points,$
                        SEARCH_ELLIPSE=ellipse,VARIOGRAM=vari)
    END
    "radfunc"   :  BEGIN
      ;;  Radial Basis Function method [Thin Plate Spline]
      method = 'Radial Basis Function [Thin Plate Spline]'
      meth   = "RadialBasisFunction"
      ;;  Grid the data
      result = GRIDDATA(l_x_s,l_y_s,f_s,_EXTRA=grid_str[0],METHOD=meth[0],                $
                        /RADIAL_BASIS_FUNCTION,XOUT=xGrid,YOUT=yGrid,SMOOTHING=smoothing, $
                        MIN_POINTS=min_points,SEARCH_ELLIPSE=ellipse,FUNCTION_TYPE=4)
    END
    "triangle"  : BEGIN
      ;;  Use TRIANGULATE.PRO and TRIGRID.PRO
      method = "Triangulate"
      xylim  = [MIN(l_x_s,/NAN),MIN(l_y_s,/NAN),MAX(l_x_s,/NAN),MAX(l_y_s,/NAN)]
      result = TRIGRID(l_x_s,l_y_s,f_s,tr_s,gsout,xylim,MISSING=d,XGRID=xGrid,YGRID=yGrid)
    END
    ELSE        :  BEGIN  ;;  Use default
      ;;  Inverse Distance method
      method = "InverseDistance"
      meth   = "InverseDistance"
      result = GRIDDATA(l_x_s,l_y_s,f_s,_EXTRA=grid_str[0],METHOD=meth[0],POWER=gpow[0],$
                        /INVERSE_DISTANCE,XOUT=xGrid,YOUT=yGrid,SMOOTHING=smoothing,    $
                        MIN_POINTS=min_points,SEARCH_ELLIPSE=ellipse)
    END
  ENDCASE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Create return structure
;;----------------------------------------------------------------------------------------
tags           = ['XGRID','YGRID','F_GRID']
struc0         = CREATE_STRUCT(tags,x_s,y_s,f_s)
tags           = ['XGRID','YGRID','F_GRID','METHOD','GRID_IN']
struc          = CREATE_STRUCT(tags,xGrid,yGrid,result,method[0],struc0)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END




;    cells  = LONARR(nuqx)
;      cells[j] = gd[0]
;      str_element,gels,jstr[0],good,/ADD_REPLACE
    ;;  Determine which grid points are duplicates and can be summed
;    good   = WHERE(cells GT 1,gd)
;    IF (gd GT 0) THEN BEGIN
;      ;;  Duplicates found
;      f_s  = REPLICATE(d,nuqx[0])
;      FOR j=0L, nuqx[0] - 1L DO BEGIN
;        
;      ENDFOR
;    ENDIF ELSE BEGIN
;      ;;  No duplicates, define new outputs
;      x_s  = x_s0
;      y_s  = y_s0
;      f_s  = f_s0
;    ENDELSE
;    
;    unq_x  = UNIQ(xx_1d,SORT(xx_1d))
;;    unq_y  = UNIQ(yy_1d,SORT(yy_1d))
;    nuqx   = N_ELEMENTS(unq_x)
;;    nuqy   = N_ELEMENTS(unq_y)
;    x_unqx = xx_1d[unq_x]
;    y_unqx = yy_1d[unq_x]
;    f_unqx = REPLICATE(d,nuqx)
;    y_unqy = yy_1d[unq_y]
;    FOR j=0L, nuqx[0] - 1L DO BEGIN
;      test = (xx_1d EQ x_unqx[j])
;      good = WHERE(test,gd)
;      IF (gd GT 0) THEN BEGIN
;        ;;  Define Y-values associated with this X-value
;        g_yy   = yy_1d[good]
;        g_ff   = ff_1d[good]
;        unq_y  = UNIQ(g_yy,SORT(g_yy))
;        y_unqy = g_yy[unq_y]
;        nuqy   = N_ELEMENTS(unq_y)
;        test   = (nuqy[0] NE gd[0])
;        IF (test[0]) THEN BEGIN
;          ;;  Duplicate Y-values found --> Sum over duplicates
;          FOR k=0L, nuqy[0] - 1L DO BEGIN
;            
;          ENDFOR
;        ENDIF ELSE BEGIN
;          ;;  No duplicate Y-values found --> define values of F
;          
;        ENDELSE
;      ENDIF
;    ENDFOR
;    ;;  Grid input
;    GRID_INPUT,xx_1d,yy_1d,ff_1d,x_s,y_s,f_s,DUPLICATES="First"


;unq_y          = UNIQ(y_s,SORT(y_s))
;ny             = N_ELEMENTS(unq_y)
;gs             = [nx[0],ny[0]]
;dx             = (MAX(x_s,/NAN) - MIN(x_s,/NAN))/(gs[0] - 1)
;intercept      = MIN(x_s,/NAN)
;xGrid          = (dx[0]*FINDGEN(gs[0])) + intercept[0]
;dy             = (MAX(y_s,/NAN) - MIN(y_s,/NAN))/(gs[1] - 1)
;intercept      = MIN(y_s,/NAN)
;yGrid          = (dy[0]*FINDGEN(gs[1])) + intercept[0]
;;  Re-grid data
;ex_str         = {MISSING:miss[0],DIMENSION:gs,DELTA:gsout,METHOD:"InverseDistance",$
;                  INVERSE_DISTANCE:1,SPHERE:0}
