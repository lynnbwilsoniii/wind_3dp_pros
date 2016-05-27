;+
;*****************************************************************************************
;
;  FUNCTION :   fft_movie_psd.pro
;  PURPOSE  :   Calculates the power spectral density (PSD) for fft_movie.pro.
;
;  CALLED BY:   
;               fft_movie.pro
;
;  CALLS:
;               sample_rate.pro
;               remove_noise.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TIME        :  N-Element array of times [seconds]
;               DATA        :  N-Element array of data [units]
;               WLEN        :  Scalar defining the # of elements to use in each
;                                snapshot/(time window) of the shifting FFT
;               WSHIFT      :  Scalar defining the # points to shift the 
;                                snapshot/(time window) after each FFT is calculated
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               READ_WIN    :   If set, program uses windowing for FFT calculation
;               FORCE_N     :  Set to a scalar (best if power of 2) to force the program
;                                power_of_2.pro return an array with this desired
;                                number of elements [e.g.  FORCE_N = 2L^12]
;               FRANGE      :  2-Element float array defining the freq. range
;                                to use when plotting the power spec (Hz)
;                                [min, max]
;               PRANGE      :  2-Element float array defining the power spectrum
;                                Y-Axis range to use [min, max]
;
;   CHANGED:  1)  Now calls remove_noise.pro instead of vector_bandpass.pro for
;                   smoothing the power spectrum                    [09/26/2011   v1.1.0]
;             2)  Fixed order of applying window and zero-padding   [04/27/2012   v1.2.0]
;             3)  Now correctly uses the PRANGE keyword preventing the routine
;                   remove_noise.pro from running (which can be very slow)
;                                                                   [07/10/2012   v1.3.0]
;             4)  Now calls sample_rate.pro and fft_power_calc.pro and
;                   no longer calls power_of_2.pro or my_windowf.pro
;                                                                   [07/10/2012   v1.4.0]
;
;   NOTES:      
;               1)  This routine should not be called by user.
;
;  REFERENCES:  
;               1)  Harris, F.J. (1978), "On the Use of Windows for Harmonic Analysis
;                      with the Discrete Fourier Transform," Proc. IEEE Vol. 66,
;                      No. 1, pp. 51-83
;               2)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;
;   CREATED:  06/15/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/10/2012   v1.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION fft_movie_psd,time,data,wlen,wshift,READ_WIN=read_win,FORCE_N=force_n,$
                       FRANGE=frange,PRANGE=prange

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
tags           = ['START_END_0','FREQS','POWER_SPEC','FRANGE','PRANGE']
;-----------------------------------------------------------------------------------------
; => Define # of FFTs to perform
;-----------------------------------------------------------------------------------------
np             = N_ELEMENTS(time)
nsteps         = (np[0] - wlen[0])/wshift[0]
; => Determine the average timestep [delay time between data points]
tt             = time
x              = LINDGEN(np - 1L)
y              = x + 1L
del_t          = tt[y] - tt[x]
timestep       = MEAN(del_t,/NAN)
srate          = sample_rate(tt,/AVERAGE,GAP_THRESH=2d0*timestep[0])

timestep       = 1d0/srate[0]
;-----------------------------------------------------------------------------------------
; => initialize the sub series variables
;-----------------------------------------------------------------------------------------
subseries     = FLTARR(wlen[0])                                ; => Sub-array of data points
subtimes      = FLTARR(wlen[0])                                ; => Sub-array of times
; => set up the start and end points for the sub timeseries
startpoint    = 0L                                                  ; => Start Element
endpoint      = LONG(startpoint[0] + wlen[0] - 1L)                  ; => End   Element
nsub          = (endpoint[0] - startpoint[0]) + 1L                  ; => # of elements in subarray
gels          = LINDGEN(nsub) + startpoint[0]
subseries     = data[gels]
subtimes      = time[gels]
IF KEYWORD_SET(force_n) THEN BEGIN
  focn = force_n[0]  ; => # of elements after zero padding
ENDIF ELSE BEGIN
  focn = 2*wlen[0]
ENDELSE

t_pow         = fft_power_calc(subtimes,subseries,READ_WIN=read_win,FORCE_N=focn)
nfreqbins     = t_pow.FREQ            ; => Freq. bin values [Hz]
nfbins2       = N_ELEMENTS(nfreqbins)
npowers       = nfbins2[0]/2L - 1L
; => First Power Spectrum Calculation
temp          = t_pow.POWER_A         ; [Units^2 Hz^(-1)]
;-----------------------------------------------------------------------------------------
; => Define Dummy Power Spectrum Array
;-----------------------------------------------------------------------------------------
;subpower      = DBLARR(nsteps,npowers+1L)
subpower      = DBLARR(nsteps,nfbins2)
subpower[0,*] = temp
; => Shift start/end elements
startpoint   += wshift[0]
endpoint     += wshift[0]
; => Define Dummy min/max power values
powermin      = 1d0
powermax      = 1d-30
skip          = 0
;-----------------------------------------------------------------------------------------
; => Calculate power spectrum for the rest of the intervals
;-----------------------------------------------------------------------------------------
FOR j=1L, nsteps - 1L DO BEGIN
  gels          = LINDGEN(nsub) + startpoint[0]
  ; => Check elements of gels to make sure we do not go beyond time series
  IF (MAX(gels,/NAN) GE np) THEN BEGIN
    bad = WHERE(gels GE np,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
    IF (gd GT 0) THEN gels  = gels[good] ELSE gels  = -1
  ENDIF
  ;; check elements
  IF (gels[0] GE 0) THEN BEGIN
    wsign = data[gels]
    wtime = time[gels]
  ENDIF ELSE BEGIN
    wsign = REPLICATE(0d0,nsub)
    wtime = time[startpoint[0]] + DINDGEN(nsub)*timestep[0]/(nsub - 1L)
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;; => Calculate power spectrum [units^2/Hz]
  ;;--------------------------------------------------------------------------------------
  t_pow         = fft_power_calc(wtime,wsign,READ_WIN=read_win,FORCE_N=focn)
  temp          = t_pow.POWER_A
  subpower[j,*] = temp
  ;-----------------------------------------------------------------------------------------
  ; => determine Y-range
  ;-----------------------------------------------------------------------------------------
  IF (skip) THEN GOTO,JUMP_SKIP
  IF (KEYWORD_SET(prange) AND N_ELEMENTS(prange) EQ 2) THEN BEGIN
    powermin = MIN(prange,/NAN)
    powermax = MAX(prange,/NAN)
    skip     = 1
  ENDIF ELSE BEGIN
    smpt          = remove_noise(temp,NBINS=20L)
    bad           = WHERE(smpt LE 0.,bd)
    IF (bd GT 0) THEN smpt[bad] = f
    powermin      = powermin < (MIN(smpt,/NAN) - 3.5d-1*ABS(MIN(smpt,/NAN)))
    powermax      = powermax > (MAX(smpt,/NAN) + 3.5d-1*ABS(MAX(smpt,/NAN)))
  ENDELSE
  ;;======================================================================================
  JUMP_SKIP:
  ;;======================================================================================
  ;-----------------------------------------------------------------------------------------
  ; => now move to the next interval
  ;-----------------------------------------------------------------------------------------
  startpoint   += wshift[0]
  endpoint     += wshift[0]
  ;-----------------------------------------------------------------------------------------
  ; => spit out a little status update so we know how fast we're moving through the ffts/
  ;-----------------------------------------------------------------------------------------
  IF (j MOD 100 EQ 0) THEN PRINT,'FFT PSD Count:',j
ENDFOR
;-----------------------------------------------------------------------------------------
; => Smooth out spikes to get a better estimate of plot ranges by making up a sample rate
;      and performing a bandpass filter to remove high frequencies...
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(frange) THEN BEGIN
  fra_0 = REFORM(frange)
ENDIF ELSE BEGIN
  fra_0 = [fmin,MAX(nfreqbins,/NAN)]
ENDELSE
pra_0 = [powermin,powermax]
;-----------------------------------------------------------------------------------------
; => return structure to user
;-----------------------------------------------------------------------------------------
s0     = 0L                                          ; => Initial Start Element
e0     = LONG(s0[0] + wlen[0] - 1L)                  ; => Initial End   Element
tags   = ['START_END_0','FREQS','POWER_SPEC','FRANGE','PRANGE']
struct = CREATE_STRUCT(tags,[s0,e0],nfreqbins,subpower,fra_0,pra_0)

RETURN,struct
END
