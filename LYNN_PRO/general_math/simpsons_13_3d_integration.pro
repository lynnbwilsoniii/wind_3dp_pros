;+
;*****************************************************************************************
;
;  FUNCTION :   simpsons_13_3d_integration.pro
;  PURPOSE  :   This routine performs a 2D integration using Simpson's 1/3 Rule
;                 algorithm based upon user defined X, Y, Z, and F inputs.  Note that if
;                 any additional multiplication factors are to be included, they should
;                 be done so prior to calling.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               delete_variable.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X       :  [N]-Element [numeric] array of x-coordinate abscissa
;               Y       :  [N]-Element [numeric] array of y-coordinate abscissa
;               Z       :  [N]-Element [numeric] array of z-coordinate abscissa
;               F       :  [N,N,N]-Element [numeric] array of function values for each
;                            X, Y, and Z abscissa value
;
;  EXAMPLES:    
;               [calling sequence]
;               int = simpsons_13_3d_integration(x,y,z,f [,/LOG] [,/NOMSSG])
;
;  KEYWORDS:    
;               LOG     :  If set and routine needs to regrid Z, then the interpolation
;                            will be done in logarithmic space
;                            [Default = FALSE]
;               NOMSSG  :  If set, routine will not inform user of elapsed computational
;                            time
;                            [Default = FALSE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               0)  See also:  simpsons_13_2d_integration.pro
;               1)  N should be odd and must satisfy N > 9
;               2)  If X, Y, Z, and F are not on a regular, uniform grid then the routine
;                     will regrid the results before interpolation as the algorithm
;                     assumes a regular grid
;
;  REFERENCES:  
;               http://mathfaculty.fullerton.edu/mathews/n2003/SimpsonsRule2DMod.html
;               http://www.physics.usyd.edu.au/teach_res/mp/doc/math_integration_2D.pdf
;               https://en.wikipedia.org/wiki/Simpson%27s_rule
;
;   CREATED:  04/08/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/08/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION simpsons_13_3d_integration,x,y,z,f3,LOG=log,NOMSSG=nomssg

ex_start       = SYSTIME(1)
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
no_inpt__mssg  = 'User must supply X, Y, and Z as [N]-element [numeric] arrays...'
badndim__mssg  = 'Inputs X, Y, and Z must be one-dimensional [numeric] arrays and F must be a three-dimensional [numeric] array...'
badddim__mssg  = 'Inputs X, Y, and Z must be [N]-element [numeric] arrays and F must be a [N,N,N]-element [numeric] array...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (is_a_number(x,/NOMSSG) EQ 0) OR $
                 (is_a_number(y,/NOMSSG) EQ 0) OR (is_a_number(z,/NOMSSG) EQ 0) OR $
                 (is_a_number(f3,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
szdx           = SIZE(x,/DIMENSIONS)
sznx           = SIZE(x,/N_DIMENSIONS)
szdy           = SIZE(y,/DIMENSIONS)
szny           = SIZE(y,/N_DIMENSIONS)
szdz           = SIZE(z,/DIMENSIONS)
sznz           = SIZE(z,/N_DIMENSIONS)
szdf           = SIZE(f3,/DIMENSIONS)
sznf           = SIZE(f3,/N_DIMENSIONS)
test           = (sznx[0] NE 1) OR (szny[0] NE 1) OR (sznz[0] NE 1) OR (sznf[0] NE 3)
IF (test[0]) THEN BEGIN
  MESSAGE,badndim__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = ((szdx[0] NE szdy[0]) OR (szdx[0] NE szdz[0])) OR $
                 ((szdf[0] NE szdf[1]) OR (szdf[0] NE szdf[2])) OR $
                 (szdx[0] LT 9L)
IF (test[0]) THEN BEGIN
  MESSAGE,badddim__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(log) THEN log_on = 1b ELSE log_on = 0b
;;----------------------------------------------------------------------------------------
;;  Make sure N is odd
;;----------------------------------------------------------------------------------------
nx             = N_ELEMENTS(x)
IF ((nx[0] MOD 2) EQ 0) THEN BEGIN
  ;;  N is currently even --> make odd
  xx             = x[0L:(nx[0] - 2L)]
  yy             = y[0L:(nx[0] - 2L)]
  zz             = z[0L:(nx[0] - 2L)]
  ff             = f3[0L:(nx[0] - 2L),0L:(nx[0] - 2L),0L:(nx[0] - 2L)]
ENDIF ELSE BEGIN
  xx             = REFORM(x)
  yy             = REFORM(y)
  zz             = REFORM(z)
  ff             = REFORM(f3)
ENDELSE
xran           = [MIN(xx,/NAN),MAX(xx,/NAN)]
yran           = [MIN(yy,/NAN),MAX(yy,/NAN)]
zran           = [MIN(zz,/NAN),MAX(zz,/NAN)]
nx             = N_ELEMENTS(xx)
;;----------------------------------------------------------------------------------------
;;  Regardless, make sure on uniform grid
;;----------------------------------------------------------------------------------------
dx             = (xran[1] - xran[0])/(nx[0] - 1L)
dy             = (yran[1] - yran[0])/(nx[0] - 1L)
dz             = (zran[1] - zran[0])/(nx[0] - 1L)
xg             = DINDGEN(nx[0])*dx[0] + xran[0]
yg             = DINDGEN(nx[0])*dy[0] + yran[0]
zg             = DINDGEN(nx[0])*dz[0] + zran[0]
;;  Find closest indices of original regularly gridded input velocities
ii             = LINDGEN(nx[0])
testx          = VALUE_LOCATE(xx,xg)
testy          = VALUE_LOCATE(yy,yg)
testz          = VALUE_LOCATE(zz,zg)
dfx            = testx - ii
dfy            = testy - ii
dfz            = testz - ii
test           = (TOTAL(dfx NE 0) GT 0) OR (TOTAL(dfy NE 0) GT 0) OR (TOTAL(dfz NE 0) GT 0)
IF (test[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Need to regrid input
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate fraction of indices between indices
  diffx          = (xg - xx[testx])/dx[0]
  diffy          = (yg - yy[testy])/dy[0]
  diffz          = (zg - zz[testz])/dz[0]
  ;;  Define fractional indices
  index_x        = testx + diffx
  index_y        = testy + diffy
  index_z        = testz + diffz
  ;;  Regrid F
  IF (log_on[0]) THEN BEGIN
    fg             = 1d1^(INTERPOLATE(ALOG10(ff),index_x,index_y,index_z,MISSING=d,/DOUBLE,/GRID))
  ENDIF ELSE BEGIN
    fg             = INTERPOLATE(ff,index_x,index_y,index_z,MISSING=d,/DOUBLE,/GRID)
  ENDELSE
  ;;  Clean up
  delete_variable,diffx,diffy,index_x,index_y,diffz,index_z
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  No need to regrid input
  ;;--------------------------------------------------------------------------------------
  fg             = ff
ENDELSE
;;  Should not have changed, but just in case...
xran           = [MIN(xg,/NAN),MAX(xg,/NAN)]
yran           = [MIN(yg,/NAN),MAX(yg,/NAN)]
zran           = [MIN(zg,/NAN),MAX(zg,/NAN)]
;;  *** Clean up ***
delete_variable,xx,yy,zz,ff,testx,testy,testz
delete_variable,dfx,dfy,dfz,ii
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  3D Simpson's 1/3 Rule
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Construct Simpson's 1/3 Rule 1D coefficients
sc             = REPLICATE(1d0,nx[0])
sc[1:(nx[0] - 2L):2] *= 4d0              ;;  Start at 2nd element and every other element should be 4
sc[2:(nx[0] - 3L):2] *= 2d0              ;;  Start at 3rd element and every other element should be 2
sc[(nx[0] - 1L)]      = 1d0              ;;  Make sure last element is 1
;;  Construct Simpson's 1/3 Rule 2D coefficients
scx            = sc # REPLICATE(1d0,nx[0])
scy            = REPLICATE(1d0,nx[0]) # sc
;;  Convert to 3D
scx3d          = REBIN(scx,nx[0],nx[0],nx[0])
scy3d          = TRANSPOSE(scx3d,[2,0,1])      ;;  equivalent to   scy3d = REBIN(scy,nx[0],nx[0],nx[0])
scz3d          = TRANSPOSE(scy3d,[0,2,1])
scxyz          = scx3d*scy3d*scz3d
;;  Define h-factors for 3D Simpson's 1/3 Rule
hfac           = dx[0]*dy[0]*dz[0]/(3d0*3d0*3d0)
;;  *** Clean up ***
delete_variable,sc,scx,scy,scx3d,scy3d,scz3d
;;----------------------------------------------------------------------------------------
;;  Compute 3D integral of input
;;----------------------------------------------------------------------------------------
output         = TOTAL(hfac[0]*TOTAL(TOTAL(scxyz*fg,3,/NAN),2,/NAN),/NAN)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
ex_time        = SYSTIME(1) - ex_start[0]
IF ~KEYWORD_SET(nomssg) THEN MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL

RETURN,output[0]
END
























