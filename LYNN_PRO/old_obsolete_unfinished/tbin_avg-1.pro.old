;+
;*****************************************************************************************
;
;  FUNCTION :   tbin_avg.pro
;  PURPOSE  :   This routine regrids data onto a user-defined, uniformly spaced time
;                 array by averaging data within each time bin on the new grid.
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
;               get_valid_trange.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               T_IN         :  [N]-Element [numeric] defining the input time stamps for
;                                 each value in Y_IN
;               Y_IN         :  [N,K,L]-Element [numeric] defining the input data array,
;                                 where K and L can be unity (i.e., 1D array) or any
;                                 value greater than one
;               DTIN         :  Scalar [numeric] defining the new sample period [s] for
;                                 defining the output, uniformly spaced time stamps
;
;  EXAMPLES:    
;               [calling sequence]
;               result = tbin_avg(t_in,y_in,dtin [,TRANGE=trange] [,NAN_OUT=nan_out])
;
;  KEYWORDS:    
;               TRANGE       :  [2]-Element [double] array specifying the Unix time range
;                                 on which to define the new uniform time interval
;                                 [Default = [MIN(T_IN),MAX(T_IN)] ]
;               NAN_OUT      :  If set, bins with no data are set to NaNs on output
;                                 [Default = FALSE]
;
;   CHANGED:  1)  Optimize a little to reduce wasted computations
;                                                                   [12/01/2017   v1.0.1]
;
;   NOTES:      
;               1)  N > 5 at minimum
;
;  REFERENCES:  
;               NA
;
;   CREATED:  11/29/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/01/2017   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION tbin_avg,t_in,y_in,dtin,TRANGE=trange,NAN_OUT=nan_out

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
noinpt_msg     = 'No input supplied...'
badnum_msg     = 'T_IN, Y_IN, and DTIN must all be numeric inputs...'
badinp_msg     = 'T_IN and Y_IN must both be at least 1D [N]-element [numeric] arrays...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 3)
IF (test[0]) THEN BEGIN
  ;;  No input
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_number(t_in[0],/NOMSSG) EQ 0) OR    $
                 (is_a_number(y_in[0],/NOMSSG) EQ 0) OR (is_a_number(dtin[0],/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  No input
  MESSAGE,badnum_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check format
szdt           = SIZE(t_in,/DIMENSIONS)
szdy           = SIZE(y_in,/DIMENSIONS)
test           = ((N_ELEMENTS(szdt) GT 1) OR (szdt[0] LT 5)) OR (szdt[0] NE szdy[0])
IF (test[0]) THEN BEGIN
  ;;  Bad input
  MESSAGE,badinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define data
tt             = REFORM(t_in)
yy             = REFORM(y_in)
n_in           = N_ELEMENTS(tt)
szdy           = SIZE(yy,/DIMENSIONS)
szny           = SIZE(yy,/N_DIMENSIONS)
def_tran       = [MIN(tt,/NAN),MAX(tt,/NAN)]
;;  Define sample rate and check input ∆t
srate0         = sample_rate(tt,/AVERAGE,OUT_MED_AVG=medavg)
speri          = 1d0/medavg[0]
dt0            = ABS(dtin[0])
def_nx         = ROUND(ABS(def_tran[1] - def_tran[0])/dt0[0])
test           = (def_nx[0] LT 2) OR (dt0[0] LT speri[0])
IF (test[0]) THEN dt = speri[0] ELSE dt = dt0[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check TRANGE
test           = ((N_ELEMENTS(trange) EQ 2) AND is_a_number(trange,/NOMSSG))
IF (test[0]) THEN tran0 = REFORM(trange) ELSE tran0 = def_tran
;;  Check format
time_ra        = get_valid_trange(TRANGE=tran0)
IF (SIZE(time_ra,/TYPE) NE 8) THEN STOP
;;  Define dates and time ranges
tran           = time_ra.UNIX_TRANGE
;;  Check NAN_OUT
test           = (N_ELEMENTS(nan_out) GT 0) AND KEYWORD_SET(nan_out)
IF (test[0]) THEN nan_on = 1b ELSE nan_on = 0b
;;----------------------------------------------------------------------------------------
;;  Define bin parameters
;;----------------------------------------------------------------------------------------
mnmx_unix      = tran + [-1,1]*dt[0]                        ;;  expand by ±1 ∆t
delt           = ABS(mnmx_unix[1] - mnmx_unix[0])
nx             = ROUND(delt[0]/dt[0])                       ;;  # of new time stamps
binL           = LINDGEN(nx[0])
;;  Define output uniformly spaced time stamps
binT           = binL*dt[0] + mnmx_unix[0] + 5d-1*dt[0]     ;;  Use midpoint time of bins
;;----------------------------------------------------------------------------------------
;;  Find nearest neighbor time stamps
;;    1)  Define a regular grid from Min to Max Unix times
;;    2)  Find the fractional location of time stamps in that grid
;;    3)  Use FLOOR to define bin value
;;----------------------------------------------------------------------------------------
fac            = nx[0]/delt[0]
;;  Compute fractional times
frac_tt        = fac[0]*(tt - mnmx_unix[0])
;;  Compute bin values [output time stamp bin value for each input time stamp]
bins_tt        = FLOOR(frac_tt)
;;----------------------------------------------------------------------------------------
;;  Regrid data to new bin times
;;----------------------------------------------------------------------------------------
;;  Define dummy arrays of # of points per bin
nbns_out       = LONARR(nx[0])
CASE szny[0] OF
  1    : yout = REPLICATE(0d0,nx[0])
  2    : yout = REPLICATE(0d0,nx[0],szdy[1])
  3    : yout = REPLICATE(0d0,nx[0],szdy[1],szdy[2])
  ELSE : STOP        ;;  >3 dimensions? --> Not compatible!
ENDCASE

FOR j=0L, n_in[0] - 1L DO BEGIN
  test           = (bins_tt[j] GE 0 AND bins_tt[j] LT nx[0])
  IF (~test[0]) THEN CONTINUE
  nbns_out[bins_tt[j]] += 1L   ;;  Add up number of points within each bin
  IF (szny[0] EQ 1) THEN BEGIN
    ;;  Use TOTAL.PRO to avoid changing all values in a bin to NaNs
    yout[bins_tt[j]] += TOTAL(yy[j],/NAN)
  ENDIF ELSE BEGIN
    CASE szny[0] OF
      2    : yout[bins_tt[j],*]   += TOTAL(yy[j,*],  1L,/NAN)
      3    : yout[bins_tt[j],*,*] += TOTAL(yy[j,*,*],1L,/NAN)
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
    1    : yout[good] /= gbins
    2    : BEGIN
      gbin2d = gbins # REPLICATE(1,szdy[1])
      yout[good,*] /= gbin2d
    END
    3    : BEGIN
      smdim  = szdy[1] < szdy[2]
      lgdim  = szdy[1] > szdy[2]
      gbin2d = gbins # REPLICATE(1,lgdim[0])
      FOR k=0L, smdim[0] - 1L DO BEGIN
        IF (smdim[0] EQ szdy[1]) THEN BEGIN
          yout[good,k,*] /= REFORM(gbin2d,gd[0],1L,lgdim[0])
        ENDIF ELSE BEGIN
          yout[good,*,k] /= gbin2d
        ENDELSE
      ENDFOR
    END
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
    1    : yout[bad]     = f
    2    : yout[bad,*]   = f
    3    : yout[bad,*,*] = f
  ENDCASE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
struc          = {X:binT,Y:yout}
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END














