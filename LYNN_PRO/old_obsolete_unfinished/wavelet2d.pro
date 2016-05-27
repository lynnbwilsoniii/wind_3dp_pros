;+
;*****************************************************************************************
;
;  FUNCTION :   morlet2d.pro
;  PURPOSE  :   Calculates the Morlet wavelet transform.
;
;  CALLED BY:   
;               wavelet2d.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               K0         :  Scalar defining the k0 (wavenumber) [Default is 6]
;               SCALE      :  M-Element array of wavelet time scales
;               K          :  N-Element array of wavelet wavenumbers
;               PERIOD     :  Set to a named variable to the vector of "Fourier" 
;                               periods (in time units) that corresponds to the SCALEs.
;               COI        :  Set to a named variable to return the Cone-of-Influence
;                               e-folding parameter
;               DOFMIN     :  Set to a named variable to return the minimum degrees
;                               of freedom
;               CDELTA     :  Set to a named variable to return reconstruction factor
;               PSI0       :  Set to a named variable to return a constant equal to
;                               1/Pi^(0.25) for normalization
;
;  EXAMPLES:    
;               morletw = morlet2d(6d0,scales,kk,period1,coifac,dof,Cdel,psi00)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  The new calculations are vectorized eliminating the
;                   the FOR loop, thus speeding up the calculation for 
;                   large input time series arrays              [12/07/2009   v1.1.0]
;
;   NOTES:      
;               1)  User should not call this function directly
;
;   CREATED:  12/07/2009
;   CREATED BY:  Dr. Christopher Torrence and Dr. Gilbert P. Compo
;    LAST MODIFIED:  12/07/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION morlet2d,k0,scale,k,period,coi,dofmin,Cdelta,psi0

;-----------------------------------------------------------------------------------------
; => Define relevant input variables
;-----------------------------------------------------------------------------------------
IF (k0 EQ -1) THEN k0 = 6d
n       = N_ELEMENTS(k)
na      = N_ELEMENTS(scale)
;-----------------------------------------------------------------------------------------
; => Convert scales and wavenumbers to 2D arrays
;-----------------------------------------------------------------------------------------
scale2d = REPLICATE(1d0,n) # scale
kk2d    = k # REPLICATE(1d0,na)
;-----------------------------------------------------------------------------------------
; => Define 2D Gaussian exponent
;-----------------------------------------------------------------------------------------
expnt   = -(scale2d*kk2d - k0[0])^2/2d0*(kk2d GT 0.)
; => Define sample period
dt      = 2*!DPI/(n*k[1])
; => Define normalization factor for admissibility {total energy = N   [Eqn(7)]}
norm2d  = SQRT(2*!DPI*scale2d/dt[0])*(!PI^(-0.25))
; => Calculate the Morlet wavelet basis function
morlet  = norm2d*EXP(expnt > (-1d2))
morlet *= (expnt GT -1d2)     ; => avoid underflow errors
morlet *= (kk2d GT 0.)        ; => Heaviside step function (Morlet is complex)
;-----------------------------------------------------------------------------------------
; => Define Scale-->Fourier [Sec.3h]
;-----------------------------------------------------------------------------------------
fourier_factor = (4*!PI)/(k0 + SQRT(2+k0^2))
period         = scale*fourier_factor
coi            = fourier_factor/SQRT(2)      ; Cone-of-influence [Sec.3g]
dofmin         = 2                           ; Degrees of freedom with no smoothing
Cdelta         = -1
IF (k0 EQ 6) THEN Cdelta = 0.776             ; reconstruction factor
psi0 = !PI^(-0.25)
RETURN,morlet
END


;+
;*****************************************************************************************
;
;  FUNCTION :   wavelet2d.pro
;  PURPOSE  :   This program computes the wavelet transform of a 1D time series.  The
;                 2D in the name is specifically referring to the vectorization done
;                 in order to speed up the calculation when using large arrays of data.
;
;  CALLED BY:   
;               wavelet_to_tplot.pro
;
;  CALLS:
;               morlet2d.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Software produced by Dr. Christopher Torrence and 
;                     Dr. Gilbert P. Compo.
;
; OUTPUTS:
;               WAVE is the WAVELET transform of Y. This is a complex array
;               of dimensions (N,J+1). FLOAT(WAVE) gives the WAVELET amplitude,
;               ATAN(IMAGINARY(WAVE),FLOAT(WAVE)) gives the WAVELET phase.
;               The WAVELET power spectrum is ABS(WAVE)^2.
;
;  INPUT:
;               Y          :  N-Element array of data (time series)
;               DT         :  Scalar defining the sample period
;
;  EXAMPLES:    
;
;    IDL> ntime = 256
;    IDL> y = RANDOMN(s,ntime)       ;*** create a random time series
;    IDL> dt = 0.25
;    IDL> time = FINDGEN(ntime)*dt   ;*** create the time index
;    IDL>
;    IDL> wave = WAVELET2D(y,dt,PERIOD=period,COI=coi,/PAD,SIGNIF=signif)
;    IDL> nscale = N_ELEMENTS(period)
;    IDL> LOADCT,39
;    IDL> CONTOUR,ABS(wave)^2,time,period, $
;       XSTYLE=1,XTITLE='Time',YTITLE='Period',TITLE='Noise Wavelet', $
;       YRANGE=[MAX(period),MIN(period)], $   ;*** Large-->Small period
;       /YTYPE, $                             ;*** make y-axis logarithmic
;       NLEVELS=25,/FILL
;    IDL>
;    IDL> signif = REBIN(TRANSPOSE(signif),ntime,nscale)
;    IDL> CONTOUR,ABS(wave)^2/signif,time,period, $
;           /OVERPLOT,LEVEL=1.0,C_ANNOT='95%'
;    IDL> PLOTS,time,coi,NOCLIP=0   ;*** anything "below" this line is dubious
;
;    ; => To plot the cone of influence, do the following...
;    IDL>  CONTOUR,wavelet,time,period
;    IDL>  PLOTS,time,coi,NOCLIP=0
;               
;
;  KEYWORDS:    
;               S0         :  Scalar defining the smallest scale of the wavelet.  
;                               [Default is 2*DT]
;               DJ         :  Scalar defining the spacing between discrete scales. 
;                               [Default is 0.125]  
;                               A smaller # will give better scale resolution, but be 
;                               slower to plot.
;               J          :  Scalar defining the # of scales minus one. Scales range 
;                               from S0 up to S0*2^(J*DJ), to give a total of (J+1) 
;                               scales. Default is J = (LOG2(N DT/S0))/DJ.
;               MOTHER     :  Scalar string giving the mother wavelet to use.
;                               Currently, 'Morlet','Paul','DOG' (derivative of Gaussian)
;                               are available. Default is 'Morlet'.
;               PARAM      :  Optional mother wavelet parameter.
;                               'Morlet' : this is k0 (wavenumber), default is 6.
;                               'Paul'   : this is m (order), default is 4.
;                               'DOG'    : this is m (m-th derivative), default is 2.
;               PAD        :  If set, then pad the time series with enough zeroes 
;                               to get N up to the next higher power of 2. This 
;                               prevents wrap around from the end of the time series 
;                               to the beginning, and also speeds up the FFT's used 
;                               to do the wavelet transform.  This will not eliminate 
;                               all edge effects (see COI below).
;               LAG1       :  LAG 1 Autocorrelation, used for SIGNIF levels. 
;                               [Default is 0.0]
;               SIGLVL     :  Significance level to use. [Default is 0.95]
;               VERBOSE    :  If set, then print out info for each analyzed scale.
;               RECON      :  If set, then reconstruct the time series, and store in Y.  
;                               Note that this will destroy the original time series, 
;                               so be sure to input a dummy copy of Y.
;               FFT_THEOR  :  Set to the theoretical background spectrum as a function 
;                               of Fourier frequency. This will be smoothed by the 
;                               wavelet function and returned as a function of PERIOD.
;
; OPTIONAL KEYWORD OUTPUTS:
;               PERIOD     :  Set to a named variable to the vector of "Fourier" 
;                               periods (in time units) that corresponds to the SCALEs.
;               SCALE      :  Set to a named variable to the vector of scale indices, 
;                               given by S0*2^(j*DJ), j=0...J where J+1 is the 
;                               total # of scales.
;               COI        :  Set to a named variable to return the Cone-of-Influence, 
;                               which is a vector of N points that contains the 
;                               maximum period of useful information at that 
;                               particular time.  Periods greater than this are 
;                               subject to edge effects.
;               YPAD       :  Set to a named variable to return the padded time 
;                               series that was actually used in the wavelet 
;                               transform.
;               DAUGHTER   :  Set to a named variable to 
;               SIGNIF     :  Set to a named variable to output significance levels 
;                               as a function of PERIOD
;               FFT_THEOR  :  Set to a named variable to output theoretical background 
;                               spectrum (smoothed by the wavelet function), as a 
;                               function of PERIOD.
;               
;
;   CHANGED:  1)  The new calculations are vectorized eliminating the
;                   the FOR loop, thus speeding up the calculation for 
;                   large input time series arrays              [12/07/2009   v1.1.0]
;
;   NOTES:      
;
; [ Defunct INPUTS:
; [   OCT = the # of octaves to analyze over.           ]
; [         Largest scale will be S0*2^OCT.             ]
; [         Default is (LOG2(N) - 1).                   ]
; [   VOICE = # of voices in each octave. Default is 8. ]
; [          Higher # gives better scale resolution,    ]
; [          but is slower to plot.                     ]
; ]
;
;=========================================================================================
; Copyright (C) 1995-1998, Christopher Torrence and Gilbert P. Compo,
; University of Colorado, Program in Atmospheric and Oceanic Sciences.
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties whatsoever.
;
; Notice: Please acknowledge the use of the above software in any publications:
;    ``Wavelet software was provided by C. Torrence and G. Compo,
;      and is available at URL: http://paos.colorado.edu/research/wavelets/''.
;
; Reference: Torrence, C. and G. P. Compo, 1998: A Practical Guide to
;            Wavelet Analysis. <I>Bull. Amer. Meteor. Soc.</I>, 79, 61-78.
;
; Please send a copy of such publications to either C. Torrence or G. Compo:
;  Dr. Christopher Torrence               Dr. Gilbert P. Compo
;  Advanced Study Program                 NOAA/CIRES Climate Diagnostics Center
;  National Center for Atmos. Research    Campus Box 216
;  P.O. Box 3000                          University of Colorado
;  Boulder CO 80307--3000, USA.           Boulder CO 80309-0216, USA.
;  E-mail: torrence@ucar.edu              E-mail: gpc@cdc.noaa.gov
;=========================================================================================
;
;   CREATED:  12/07/2009
;   CREATED BY:  Dr. Christopher Torrence and Dr. Gilbert P. Compo
;    LAST MODIFIED:  12/07/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION wavelet2d,y1,dt,S0=s0,DJ=dj,J=j,PAD=pad,MOTHER=mother,PARAM=param,        $
                         WAVENUMBER=k,VERBOSE=verbose,NO_WAVE=no_wave,RECON=recon, $
                         LAG1=lag1,SIGLVL=siglvl,DOF=dof,GLOBAL=global,            $
                         SCALE=scale,PERIOD=period,YPAD=ypad,DAUGHTER=daughter,    $
                         COI=coi,SIGNIF=signif,FFT_THEOR=fft_theor,                $
                         OCT=oct,VOICE=voice   ;*** defunct inputs

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; => Define relevant variables
;-----------------------------------------------------------------------------------------
ON_ERROR,2
r  = CHECK_MATH(0,1)
n  = N_ELEMENTS(y1)
n1 = n

;-----------------------------------------------------------------------------------------
; => Check keywords & optional inputs
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(s0) LT 1) THEN s0 = 2*dt
IF (N_ELEMENTS(voice) EQ 1) THEN dj = 1./voice
IF (N_ELEMENTS(dj) LT 1) THEN dj = 1./8
IF (N_ELEMENTS(oct) EQ 1) THEN J = oct/dj
IF (N_ELEMENTS(J) LT 1) THEN J = FIX((ALOG(n*dt/s0)/ALOG(2))/dj)  ; [Eqn(10)]
IF (N_ELEMENTS(mother) LT 1) THEN mother = 'MORLET2D'
IF (N_ELEMENTS(param) LT 1) THEN param = -1
IF (N_ELEMENTS(siglvl) LT 1) THEN siglvl = 0.95
IF (N_ELEMENTS(lag1) LT 1) THEN lag1 = 0.0
lag1        = lag1[0]
verbose     = KEYWORD_SET(verbose)
do_daughter = KEYWORD_SET(daughter)
do_wave     = NOT KEYWORD_SET(no_wave)
recon       = KEYWORD_SET(recon)
IF KEYWORD_SET(global) THEN BEGIN
  MESSAGE, 'Please use WAVE_SIGNIF for global significance tests'
ENDIF
;-----------------------------------------------------------------------------------------
; => Construct time series to analyze, pad if necessary
;-----------------------------------------------------------------------------------------
ypad = y1 - TOTAL(y1,/NAN)/n     ; => Remove mean
IF KEYWORD_SET(pad) THEN BEGIN   ; pad with extra zeroes, up to power of 2
  IF (pad EQ 1) THEN base2 = FIX(ALOG(n)/ALOG(2) + 0.4999)   ; power of 2 nearest to N
  IF (pad EQ 2) THEN base2 = FIX(ALOG(DOUBLE(n))/ALOG(2d))   ; next highest power of 2base2-1
  ypad = [ypad,FLTARR(2L^(base2 + 1) - n)]
  n    = N_ELEMENTS(ypad)
ENDIF
;-----------------------------------------------------------------------------------------
; => Construct SCALE array & empty PERIOD & WAVE arrays
;-----------------------------------------------------------------------------------------
na     = J + 1                          ; => # of scales
period = FLTARR(na,/NOZERO)             ; => empty period array (filled in below)
wave   = COMPLEXARR(n,na,/NOZERO)       ; => empty wavelet array

scale  = DINDGEN(na)*dj                 ; => array of j-values
scale  = 2d0^(scale)*s0                 ; => array of scales  2^j   [Eqn(9)]
IF (do_daughter) THEN daughter = wave   ; => empty daughter array
;-----------------------------------------------------------------------------------------
; => Construct wavenumber array used in transform [Eqn(5)]
;-----------------------------------------------------------------------------------------
k = (DINDGEN(n/2) + 1)*(2*!PI)/(n*dt)
k = [0d0,k,-REVERSE(k[0:(n - 1L)/2 - 1L])]
;-----------------------------------------------------------------------------------------
; => Compute FFT of the (padded) time series
;-----------------------------------------------------------------------------------------
yfft = FFT(ypad,-1,/DOUBLE)  ; [Eqn(3)]
IF (verbose) THEN BEGIN  ;verbose
  PRINT
  PRINT,mother
  PRINT,'#points=',n1,'   s0=',s0,'   dj=',dj,'   J=',FIX(J)
  IF (n1 NE n) THEN PRINT,'(padded with ',n-n1,' zeroes)'
  PRINT,['j','scale','period','variance','mathflag'],FORMAT='(/,A3,3A11,A10)'
ENDIF  ;verbose

IF (N_ELEMENTS(fft_theor) EQ n) THEN BEGIN
  fft_theor_k = fft_theor 
ENDIF ELSE BEGIN
  fft_theor_k = (1 - lag1^2)/(1 - 2*lag1*COS(k*dt) + lag1^2)  ; [Eqn(16)]
ENDELSE
fft_theor = FLTARR(na)
;-----------------------------------------------------------------------------------------
; => Compute wavelet at different scales
;-----------------------------------------------------------------------------------------
psi_fft = CALL_FUNCTION(mother,param,scale,k,period1,coi,dofmin,Cdelta,psi0)
period        = REFORM(period1[*])
fft_theor_2d  = fft_theor_k # REPLICATE(1d0,na)
fft_theor     = TOTAL((ABS(psi_fft)^2)*fft_theor_2d,1,/NAN)/n
IF (do_wave OR do_daughter) THEN BEGIN
  FOR a1=0L,na - 1L DO BEGIN
    IF (do_wave)     THEN wave[*,a1]     = FFT(yfft*psi_fft[*,a1],1,/DOUBLE)  ; wavelet transform[Eqn(4)]
    IF (do_daughter) THEN daughter[*,a1] = FFT(psi_fft[*,a1],1,/DOUBLE)       ; save daughter
  ENDFOR
ENDIF
; => Compute the cone of influence
coi = coi*[FINDGEN((n1+1)/2),REVERSE(FINDGEN(n1/2))]*dt   ; COI [Sec.3g]
; => Shift so DAUGHTERs are in middle of array
IF (do_daughter) THEN $   
  daughter = [daughter[(n - n1/2):*,*],daughter[0:(n1/2 - 1L),*]]
;-----------------------------------------------------------------------------------------
; => Compute significance levels [Sec.4]
;-----------------------------------------------------------------------------------------
sdev      = (MOMENT(y1))[1]
fft_theor = sdev*fft_theor  ; include time-series variance
dof = dofmin
signif = fft_theor*CHISQR_CVF(1. - siglvl,dof)/dof   ; [Eqn(18)]


IF (recon) THEN BEGIN  ; Reconstruction [Eqn(11)]
  IF (Cdelta EQ -1) THEN BEGIN
    y1 = -1
    MESSAGE,/INFO,'Cdelta undefined, cannot reconstruct with this wavelet'
  ENDIF ELSE BEGIN
    y1 = dj*SQRT(dt)/(Cdelta*psi0)*(FLOAT(wave) # (1./SQRT(scale)))
    y1 = y1[0:(n1 - 1L)]
  ENDELSE
ENDIF
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/cont,/info
;*****************************************************************************************
RETURN,wave[0:(n1 - 1L),*]    ; get rid of padding before returning
END
