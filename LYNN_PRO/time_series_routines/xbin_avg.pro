;+
;*****************************************************************************************
;
;  FUNCTION :   xbin_avg.pro
;  PURPOSE  :   This routine regrids data onto a user-defined, uniformly spaced grid
;                 array by averaging data within each X bin on the new grid.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               sample_rate.pro
;               test_plot_axis_range.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X_IN         :  [N]-Element [numeric] defining the input independent
;                                 variable for each value in Y_IN
;               Y_IN         :  [N,K,L,M]-Element [numeric] defining the input data array,
;                                 where K, L, and M can be unity (i.e., 1D array) or any
;                                 value greater than one
;
;  EXAMPLES:    
;               [calling sequence]
;               result = xbin_avg(t_in,y_in [,DXIN=dxin] [,TRANGE=trange] [,NAN_OUT=nan_out] $
;                                 [,NGRID_OUT=ngrid_out]                                     )
;
;  KEYWORDS:    
;               DXIN         :  Scalar [numeric] defining the new X-grid size for defining
;                                 the output, uniformly spaced X-grid points
;               XRANGE       :  [2]-Element [double] array specifying the X-range
;                                 on which to define the new uniform grid interval
;                                 [Default = [MIN(X_IN),MAX(X_IN)] ]
;               NGRID_OUT    :  Scalar [integer/long] defining the new number of
;                                 uniformly spaced grid points to define on output.  If
;                                 properly set, this keyword will supercede both DXIN
;                                 and XRANGE
;               NAN_OUT      :  If set, bins with no data are set to NaNs on output
;                                 [Default = FALSE]
;
;   CHANGED:  1)  Fixed a bug in the keyword testing
;                                                                   [09/09/2018   v1.0.1]
;             2)  Moved to ~/wind_3dp_pros/LYNN_PRO/time_series_routines/
;                                                                   [09/12/2018   v1.0.2]
;
;   NOTES:      
;               1)  See also:  tbin_avg.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/07/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/12/2018   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION xbin_avg,x_in,y_in,DXIN=dxin,XRANGE=xrange,NGRID_OUT=ngrid_out,NAN_OUT=nan_out

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
noinpt_msg     = 'No input supplied...'
badnum_msg     = 'X_IN and Y_IN must both be numeric inputs...'
badinp_msg     = 'X_IN and Y_IN must both be at least 1D [N]-element [numeric] arrays...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2)
IF (test[0]) THEN BEGIN
  ;;  No input
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_number(x_in[0],/NOMSSG) EQ 0) OR (is_a_number(y_in[0],/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  No input
  MESSAGE,badnum_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check format
szdt           = SIZE(x_in,/DIMENSIONS)
szdy           = SIZE(y_in,/DIMENSIONS)
test           = ((N_ELEMENTS(szdt) GT 1) OR (szdt[0] LT 5)) OR (szdt[0] NE szdy[0])
IF (test[0]) THEN BEGIN
  ;;  Bad input
  MESSAGE,badinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define data
xx             = REFORM(x_in)
yy             = REFORM(y_in)
n_in           = N_ELEMENTS(xx)
szdy           = SIZE(yy,/DIMENSIONS)
szny           = SIZE(yy,/N_DIMENSIONS)
def_xran       = [MIN(xx,/NAN),MAX(xx,/NAN)]
;;  Define sample rate and check input ∆t
srate0         = sample_rate(xx,/AVERAGE,OUT_MED_AVG=medavg)
speri          = 1d0/medavg[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check DXIN
test           = (is_a_number(dxin,/NOMSSG) EQ 0)
IF (test[0]) THEN dxin_on = 0b ELSE dxin_on = 1b
;;  Check XRANGE
test           = test_plot_axis_range(xrange,/NOMSSG)
IF (test[0]) THEN xran_on = 1b ELSE xran_on = 0b
IF (xran_on[0]) THEN xran0 = REFORM(xrange) ELSE xran0 = def_xran
;;  Check NAN_OUT
test           = (N_ELEMENTS(nan_out) GT 0) AND KEYWORD_SET(nan_out)
IF (test[0]) THEN nan_on = 1b ELSE nan_on = 0b
;;  Check NGRID_OUT
test           = (is_a_number(ngrid_out,/NOMSSG) EQ 0)
IF (test[0]) THEN grid_on = 0b ELSE grid_on = 1b
IF (grid_on[0]) THEN BEGIN
  ;;  Shut off DXIN
  dxin_on = 0b
  ngrid   = LONG(ABS(ngrid_out[0])) > 2L
  delx0   = ABS(xran0[1] - xran0[0])
  dx      = delx0[0]/(ngrid[0] - 1L)
ENDIF ELSE BEGIN
  IF (dxin_on[0]) THEN dx0 = ABS(dxin[0]) ELSE dx0 = speri[0]
  def_nx  = ROUND(ABS(xran0[1] - xran0[0])/dx0[0])
  test    = (def_nx[0] LT 2)
  IF (test[0]) THEN dx = speri[0] ELSE dx = dx0[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define bin parameters
;;----------------------------------------------------------------------------------------
mnmx_grid      = xran0 + [-1,1]*dx[0]                       ;;  expand by ±1 ∆x
delx           = ABS(mnmx_grid[1] - mnmx_grid[0])
;;  Define # of new grid points
IF (grid_on[0]) THEN nx = ngrid[0] ELSE nx = ROUND(delx[0]/dx[0])
binL           = LINDGEN(nx[0])
;;  Define output uniformly spaced grid points
binX           = binL*dx[0] + mnmx_grid[0] + 5d-1*dx[0]     ;;  Use midpoint of grid points
;;----------------------------------------------------------------------------------------
;;  Find nearest neighbor time stamps
;;    1)  Define a regular grid from Min to Max grid points
;;    2)  Find the fractional location of grid points in that grid
;;    3)  Use FLOOR to define bin value
;;----------------------------------------------------------------------------------------
fac            = nx[0]/delx[0]
;;  Compute fractional times
frac_xx        = fac[0]*(xx - mnmx_grid[0])
;;  Compute bin values [output time stamp bin value for each input time stamp]
bins_xx        = FLOOR(frac_xx)
;;----------------------------------------------------------------------------------------
;;  Regrid data to new bin times
;;----------------------------------------------------------------------------------------
;;  Define dummy arrays of # of points per bin
nbns_out       = LONARR(nx[0])
CASE szny[0] OF
  1    : yout = REPLICATE(0d0,nx[0])
  2    : yout = REPLICATE(0d0,nx[0],szdy[1])
  3    : yout = REPLICATE(0d0,nx[0],szdy[1],szdy[2])
  4    : yout = REPLICATE(0d0,nx[0],szdy[1],szdy[2],szdy[3])
  ELSE : STOP        ;;  >4 dimensions? --> Not compatible!
ENDCASE

FOR j=0L, n_in[0] - 1L DO BEGIN
  test           = (bins_xx[j] GE 0 AND bins_xx[j] LT nx[0])
  IF (~test[0]) THEN CONTINUE
  nbns_out[bins_xx[j]] += 1L   ;;  Add up number of points within each bin
  IF (szny[0] EQ 1) THEN BEGIN
    ;;  Use TOTAL.PRO to avoid changing all values in a bin to NaNs
    yout[bins_xx[j]] += TOTAL(yy[j],/NAN)
  ENDIF ELSE BEGIN
    CASE szny[0] OF
      2    : yout[bins_xx[j],*]     += TOTAL(yy[j,*],  1L,/NAN)
      3    : yout[bins_xx[j],*,*]   += TOTAL(yy[j,*,*],1L,/NAN)
      4    : yout[bins_xx[j],*,*,*] += TOTAL(yy[j,*,*,*],1L,/NAN)
    ENDCASE
  ENDELSE
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Compute average values per bin
;;----------------------------------------------------------------------------------------
good           = WHERE(nbns_out GT 0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
IF (gd[0] GT 0) THEN BEGIN
  gbins          = nbns_out[good]
  CASE szny[0] OF
    ;;------------------------------------------------------------------------------------
    1    : yout[good] /= gbins
    ;;------------------------------------------------------------------------------------
    2    : BEGIN
      gbin2d = gbins # REPLICATE(1,szdy[1])
      yout[good,*] /= gbin2d
    END
    ;;------------------------------------------------------------------------------------
    3    : BEGIN
      ;;  Determine the smallest dimension --> loop over this one to speed up
      smdim  = szdy[1] < szdy[2]
      lgdim  = szdy[1] > szdy[2]
      ;;  Define good bin array
      gbin2d = gbins # REPLICATE(1,lgdim[0])
      FOR k=0L, smdim[0] - 1L DO BEGIN
        IF (smdim[0] EQ szdy[1]) THEN BEGIN
          yout[good,k,*] /= REFORM(gbin2d,gd[0],1L,lgdim[0])
        ENDIF ELSE BEGIN
          yout[good,*,k] /= gbin2d
        ENDELSE
      ENDFOR
    END
    ;;------------------------------------------------------------------------------------
    4    : BEGIN
      ;;  Determine the smallest dimension --> loop over this one to speed up
      smdim  = MIN(szdy[1:3],sln)
      lgdim  = MAX(szdy[1:3],slg)
      CASE sln[0] OF
        0  :  IF (slg[0] EQ 1) THEN slm = 2L ELSE slm = 1L
        1  :  IF (slg[0] EQ 2) THEN slm = 0L ELSE slm = 2L
        2  :  IF (slg[0] EQ 0) THEN slm = 1L ELSE slm = 0L
      ENDCASE
      mddim  = (szdy[1:3])[slm[0]]
      ;;  Define good bin array
      gbin2d = gbins # REPLICATE(1,lgdim[0])
       FOR k=0L, smdim[0] - 1L DO BEGIN
        FOR j=0L, mddim[0] - 1L DO BEGIN
          CASE sln[0] OF
            0  :  BEGIN
              IF (slg[0] EQ 1) THEN BEGIN
                yout[good,k,*,j] /= REFORM(gbin2d,gd[0],1L,lgdim[0],1L)
              ENDIF ELSE BEGIN
                yout[good,k,j,*] /= REFORM(gbin2d,gd[0],1L,1L,lgdim[0])
              ENDELSE
            END
            1  :  BEGIN
              IF (slg[0] EQ 2) THEN BEGIN
                yout[good,j,k,*] /= REFORM(gbin2d,gd[0],1L,1L,lgdim[0])
              ENDIF ELSE BEGIN
                yout[good,*,k,j] /= REFORM(gbin2d,gd[0],lgdim[0],1L,1L)
              ENDELSE
            END
            2  :  BEGIN
              IF (slg[0] EQ 0) THEN BEGIN
                yout[good,*,j,k] /= REFORM(gbin2d,gd[0],lgdim[0],1L,1L)
              ENDIF ELSE BEGIN
                yout[good,j,*,k] /= REFORM(gbin2d,gd[0],1L,lgdim[0],1L)
              ENDELSE
            END
          ENDCASE
        ENDFOR
      ENDFOR
    END
    ;;------------------------------------------------------------------------------------
  ENDCASE
ENDIF ELSE BEGIN
  ;;  No data in any bin  -->  zero all?
  yout[*] *= 0
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Remove zeros if desired
;;----------------------------------------------------------------------------------------
IF (nan_on[0]) THEN BEGIN
  CASE szny[0] OF
    1    : yout[bad]       = f
    2    : yout[bad,*]     = f
    3    : yout[bad,*,*]   = f
    4    : yout[bad,*,*,*] = f
    ELSE : STOP  ;;  Should not get here  --> Debug
  ENDCASE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
struc          = {X:binX,Y:yout}
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END

