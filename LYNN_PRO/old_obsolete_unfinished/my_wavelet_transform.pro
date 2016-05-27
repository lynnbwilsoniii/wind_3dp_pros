;+
;*****************************************************************************************
;
;  FUNCTION :   my_morlet_wavelet.pro
;  PURPOSE  :   This is an adaptation of the Morlet wavelet software produced by
;                 Dr. Christopher Torrence and Dr. Gilbert P. Compo.  The routine
;                 returns the daughter wavelet functions for an input array.
;
;  CALLED BY:   
;               my_wavelet_transform.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               K0      :  Scalar defining the Morlet non-dimensional wavenumber
;               SCALE   :  Scalar value defining the wavelet scale
;               K       :  [N]-Element array of wavelet wavenumbers
;               PERIOD  :  Set to a named variable to return the Fourier period
;                            associated with each wavelet scale [seconds]
;               COI     :  Set to a named variable to return the cone of influence.
;                            COI is an [N]-Element array of periods marking the
;                            maximum period of useful information at any given time
;                            index.  Periods greater than this are subject to edge
;                            effects.
;               DOFMIN  :  Set to a named variable to return the degrees of freedom with no smoothing
;               CDELTA  :  Set to a named variable to return the reconstruction factor
;               PSI0    :  Set to a named variable to return the 0th wavelet function
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Routine forces the Morlet wavelet parameter to be 6 for
;                     admissibility
;               2)  This routine should only be called by my_wavelet_transform.pro
;
;  REFERENCES:  
;               1)  Harris, F.J. (1978), "On the Use of Windows for Harmonic Analysis
;                      with the Discrete Fourier Transform," Proc. IEEE Vol. 66,
;                      No. 1, pp. 51-83
;                      [H1978]
;               2)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;                      [PD1998]
;               3)  Torrence, C. and G.P. Compo (1998), "A Practical Guide to Wavelet
;                      Analysis," Bull. Amer. Meteor. Soc. Vol. 79, pp. 61-78.
;                      [TC1998]
;
;   CREATED:  06/29/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/29/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION my_morlet_wavelet,k0,scale,k,period,coi,dofmin,Cdelta,psi0

;-----------------------------------------------------------------------------------------
; => Define dummy/default variables and constants
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
IF (k0 EQ -1) THEN k0 = 6d0
n          = N_ELEMENTS(k)
dt         = 2d0*!DPI/(n*k[1])
;-----------------------------------------------------------------------------------------
; => Define wavelet functions
;-----------------------------------------------------------------------------------------
expnt          = -1d0*(scale[0]*k - k0[0])^2/2d0*(k GT 0.)
morlet         = SQRT(2d0*!DPI*scale[0]/dt[0])*(!DPI^(-0.25))  ; => [Eq. 7 from TC1998]
morlet        *= EXP(expnt > (-1d2))
morlet        *= (expnt GT -1d2)                               ; => avoid underflow errors
; => Apply Heaviside step function (Morlet is complex)
morlet        *= (k GT 0.)
; => Define conversion from wavelet scales to Fourier periods [Sec. 3h from TC1998]
fourier_factor = (4*!PI)/(k0 + SQRT(2+k0^2))
period         = scale[0]*fourier_factor[0]
; => Define Cone-of-influence [Sec. 3g from TC1998]
coi            = fourier_factor[0]/SQRT(2d0)
dofmin         = 2                          ; Degrees of freedom with no smoothing
Cdelta         = -1
IF (k0 EQ 6) THEN Cdelta = 0.776            ; reconstruction factor
psi0           = !PI^(-0.25)

RETURN,morlet
END

;*****************************************************************************************
;    IF (k0 EQ -1) THEN k0 = 6d
;    n = N_ELEMENTS(k)
;    expnt = -(scale*k - k0)^2/2d*(k GT 0.)
;    dt = 2*!PI/(n*k(1))
;    norm = SQRT(2*!PI*scale/dt)*(!PI^(-0.25))   ; total energy=N   [Eqn(7)]
;    morlet = norm*EXP(expnt > (-100d))
;    morlet = morlet*(expnt GT -100)  ; avoid underflow errors
;    morlet = morlet*(k GT 0.)  ; Heaviside step function (Morlet is complex)
;    fourier_factor = (4*!PI)/(k0 + SQRT(2+k0^2)) ; Scale-->Fourier [Sec.3h]
;    period = scale*fourier_factor
;    coi = fourier_factor/SQRT(2)   ; Cone-of-influence [Sec.3g]
;    dofmin = 2   ; Degrees of freedom with no smoothing
;    Cdelta = -1
;    IF (k0 EQ 6) THEN Cdelta = 0.776 ; reconstruction factor
;    psi0 = !PI^(-0.25)
;   PRINT,scale,n,SQRT(TOTAL(ABS(morlet)^2,/DOUBLE))
;*****************************************************************************************


;+
;*****************************************************************************************
;
;  FUNCTION :   my_wavelet_transform.pro
;  PURPOSE  :   This is an adaptation of the Morlet wavelet software produced by
;                 Dr. Christopher Torrence and Dr. Gilbert P. Compo.  The routine
;                 returns the Morlet wavelet transform of an input array.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_morlet_wavelet.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               Y1          :  [N]-Element array of equally time-spaced/sampled data
;               DT          :  Scalar defining the sample period (seconds)
;
;  EXAMPLES:    
;               IDL> nsams   = 2048L
;               IDL> srate   = 7.5d3          ; => Dummy sample rate [Hz]
;               IDL> speriod = 1d0/srate[0]   ; => Dummy sample period [s]
;               IDL> dscale  = 1d0/8d0        ; => Default scale spacing
;               IDL> s0      = 2d0*speriod[0] ; => Smallest wavelet scale to use
;               ; => Define the # of scales to use
;               IDL> jscale  = (ALOG10(nsams/2)/ ALOG10(2))/dscale[0]
;               IDL> kk0     = 6d0            ; => Default Morlet Parameter #
;               ;-------------------------------------------------------------------------
;               ; => Create a triangle wave
;               ;-------------------------------------------------------------------------
;               IDL> a0      = 27d-3          ; => Dummy triangle wave period
;               ; => Define time steps
;               IDL> tt      = DINDGEN(nsams)*(speriod[0]*4d0*!DPI)
;               ; => Define triangle wave
;               IDL> yy      = 2d0/a[0]*(-1d0)^(FLOOR(tt/a[0] - 5d-1))
;               IDL> yy     *= (tt - a[0]*FLOOR(tt/a[0] + 5d-1))
;               IDL> wave    = my_wavelet_transform(yy,speriod[0],S0=s0[0],DJ=dscale[0],$
;                                         J=jscale[0],/PAD,PERIOD=period1,PARAM=kk0[0], $
;                                         COI=cone1,SIGNIF=signif1,FFT_THEOR=fft_theor1)
;               ;-------------------------------------------------------------------------
;               ; => Define power spectral density (PSD) [(units)^2/Hz]
;               ;-------------------------------------------------------------------------
;               IDL> psd     = (2d0*nsams/srate[0])*ABS(wave)^2
;               ; => Define Fourier frequencies
;               IDL> fourier = 1d0/period1
;               ;-------------------------------------------------------------------------
;               ; => Plot the results
;               ;-------------------------------------------------------------------------
;               IDL> !P.MULTI = [0,1,2]
;               ; => Plot the time series
;               IDL> PLOT,tt,yy,/NODATA,/XSTYLE,/YSTYLE
;               IDL>   OPLOT,tt,yy,COLOR=50   ; => Blue for color table 39
;               ; => Plot the PSD
;               IDL> CONTOUR,psd,tt,fourier,/XSTYLE,/YSTYLE,/YLOG,XTITLE='Time (s)',$
;                            YTITLE='Frequency (Hz)',TITLE='Morlet Wavelet PSD',    $
;                            NLEVELS=25,/FILL
;
;  KEYWORDS:    
;               S0          :  Scalar defining the smallest wavelet scale
;                                [Default = 2*DT]
;               DJ          :  Scalar defining the wavelet logarithmic scale spacing
;                                smaller => better frequency resolution, smaller
;                                             frequency range, and slower
;                                [Default = 0.125]
;               PAD         :  If set, routine will pad array with zeros to make it an
;                                even power of 2
;               PARAM       :  Scalar defining the Morlet non-dimensional wavenumber
;                                [Default = 6, {omega_o in TC1998}
;               WAVENUMBER  :  Set to a named variable to return the wave numbers
;                                used to construct the wavelets
;               VERBOSE     :  If set, routine prints out information for each analyzed
;                                scale
;               NO_WAVE     :  If set, routine will not calculate the wavelet transform
;               RECON       :  If set, routine will reconstruct the time series Y1 and
;                                overwrite the original
;               LAG1        :  Lag 1-Autocorrelation used for significance levels
;                                [Default = 0.0]
;               SIGLVL      :  Scalar defining the significance level to use when
;                                calculating the wavelet significance
;                                [Default = 0.95]
;               DOF         :  Parameter used by my_morlet_wavelet.pro to return the
;                                degrees of freedom [with no smoothing] of the
;                                transform
;               SCALE       :  Set to a named variable to return the wavelet scales used
;                                to define the wavelet functions [Eqs 9 & 10 in TC1998]
;               PERIOD      :  Set to a named variable to return the Fourier period
;                                associated with each wavelet scale [seconds]
;               YPAD        :  Set to a named variable to return the padded time series
;                                used to construct the transform
;               DAUGHTER    :  If set, routine will return the daughter wavelets which
;                                have the same dimensions as the normal output.  At each
;                                scale, the daughter wavelet is located in the center
;                                of the array.
;               COI         :  Set to a named variable to return the cone of influence.
;                                COI is an [N]-Element array of periods marking the
;                                maximum period of useful information at any given time
;                                index.  Periods greater than this are subject to edge
;                                effects.
;               SIGNIF      :  Set to a named variable to output significance levels as
;                                a function of wavelet period
;               FFT_THEOR   :  Set to a named variable to output the background spectrum
;                                (smoothed by wavelet function) as a function of
;                                wavelet period
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This routine is nearly identical to WAVELET.PRO written by
;                     Dr. Christopher Torrence and Dr. Gilbert P. Compo.  The only
;                     significant changes are that I removed the options for wavelets
;                     other than the Morlet and the obsolete keywords.
;
;  REFERENCES:  
;               1)  Harris, F.J. (1978), "On the Use of Windows for Harmonic Analysis
;                      with the Discrete Fourier Transform," Proc. IEEE Vol. 66,
;                      No. 1, pp. 51-83
;                      [H1978]
;               2)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;                      [PD1998]
;               3)  Torrence, C. and G.P. Compo (1998), "A Practical Guide to Wavelet
;                      Analysis," Bull. Amer. Meteor. Soc. Vol. 79, pp. 61-78.
;                      [TC1998]
;
;   CREATED:  06/29/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/29/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION my_wavelet_transform,y1,dt,S0=s0,DJ=dj,J=j,PAD=pad,PARAM=param,WAVENUMBER=k,   $
                              VERBOSE=verbose,NO_WAVE=no_wave,RECON=recon,LAG1=lag1,    $
                              SIGLVL=siglvl,DOF=dof,SCALE=scale,PERIOD=period,YPAD=ypad,$
                              DAUGHTER=daughter,COI=coi,SIGNIF=signif,FFT_THEOR=fft_theor

;-----------------------------------------------------------------------------------------
; => Define dummy/default variables and constants
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Set up error handling
;-----------------------------------------------------------------------------------------
ON_ERROR,2
r          = CHECK_MATH(0,1)
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
n          = N_ELEMENTS(y1)
n1         = n

IF (N_ELEMENTS(s0) LT 1)     THEN s0     = 2d0*dt[0]
IF (N_ELEMENTS(dj) LT 1)     THEN dj     = 1d0/8d0
IF (N_ELEMENTS(J) LT 1)      THEN J      = FIX((ALOG(n*dt[0]/s0[0])/ALOG(2))/dj[0])  ; [Eq. 10 from TC1998]
IF (N_ELEMENTS(mother) LT 1) THEN mother = 'my_morlet_wavelet'
IF (N_ELEMENTS(param) LT 1)  THEN param  = -1
IF (N_ELEMENTS(siglvl) LT 1) THEN siglvl = 0.95
IF (N_ELEMENTS(lag1) LT 1)   THEN lag1   = 0.0

lag1        = lag1[0]
verbose     = KEYWORD_SET(verbose)
do_daughter = KEYWORD_SET(daughter)
do_wave     = NOT KEYWORD_SET(no_wave)
recon       = KEYWORD_SET(recon)

;-----------------------------------------------------------------------------------------
; => Construct time series to analyze, pad if necessary
;-----------------------------------------------------------------------------------------
ypad = y1 - TOTAL(y1,/NAN)/TOTAL(FINITE(y1))    ; remove mean
IF KEYWORD_SET(pad) THEN BEGIN
  ; => Pad with extra zeroes, up to power of 2
  CASE pad[0] OF
    1    : BEGIN
      ; => power of 2 nearest to N
      base2 = FIX(ALOG(DOUBLE(n))/ALOG(2d0) + 0.4999)
      ypad  = [ypad,FLTARR(2L^(base2 + 1) - n)]
    END
    2    : BEGIN
      ; => next highest power of 2*base2 - 1
      base2 = FIX(ALOG(DOUBLE(n))/ALOG(2d0))
      ypad  = [ypad,FLTARR(2L^(base2 + 1) - n)]
    END
    ELSE : BEGIN
      ypad  = ypad
    END
  ENDCASE
  n    = N_ELEMENTS(ypad)
ENDIF
;-----------------------------------------------------------------------------------------
; => Construct SCALE array & empty PERIOD & WAVE arrays
;-----------------------------------------------------------------------------------------
na     = J + 1                          ; => # of scales
scale  = s0[0]*2d0^(DINDGEN(na)*dj[0])  ; => Wavelet scales [Eq. 9 from TC1998]
period = FLTARR(na,/NOZERO)             ; => Fourier periods
wave   = COMPLEXARR(n,na,/NOZERO)       ; => Wavelet array
IF (do_daughter) THEN daughter = wave   ; => Daughter wavelet array
;-----------------------------------------------------------------------------------------
; => Construct wavenumber array used in transform [Eq. 5 from TC1998]
;-----------------------------------------------------------------------------------------
k    = (2*!DPI)/(n*dt[0])*(DINDGEN(n/2L) + 1L)
k    = [0d,k,-REVERSE(k[0L:((n - 1L)/2L - 1L)])]
;-----------------------------------------------------------------------------------------
; => Compute FFT of the (padded) time series [Eq. 3 from TC1998]
;-----------------------------------------------------------------------------------------
yfft = FFT(ypad,-1,/DOUBLE)

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
  temp        = (1d0 - lag1[0]^2)
  tcos        = COS(k*dt[0])
  temp2       = (1d0 - 2d0*lag1[0]*tcos + lag1[0]^2)
  fft_theor_k = temp[0]/temp2                   ; => [Eq. 16 from TC1998]
ENDELSE
fft_theor = FLTARR(na)
;-----------------------------------------------------------------------------------------
; => Loop through each scale
;-----------------------------------------------------------------------------------------
FOR a1=0L, na - 1L DO BEGIN
  ; => Get the Fourier Transform of the wavelet function
  psi_fft = CALL_FUNCTION(mother,param,scale[a1],k,period1,coi,dofmin,Cdelta,psi0)
  IF (do_wave) THEN BEGIN
    ; => Calculate the wavelet transform [Eq. 4 from TC1998]
    wave[*,a1] = FFT(yfft*psi_fft,1,/DOUBLE)
  ENDIF
  ; => Define Fourier period for this scale
  period[a1]    = period1
  fft_theor[a1] = TOTAL((ABS(psi_fft)^2)*fft_theor_k,/NAN)/n
  IF (do_daughter) THEN BEGIN
    ; => Save daughter wavelet
    daughter[*,a1] = FFT(psi_fft,1,/DOUBLE)
  ENDIF
  IF (verbose) THEN BEGIN
    ; => Print out information
    PRINT,a1,scale[a1],period[a1],TOTAL(ABS(wave[*,a1])^2),CHECK_MATH(0), $
          FORMAT='(I3,3F11.3,I6)'
  ENDIF
ENDFOR
;-----------------------------------------------------------------------------------------
; => Define Cone of influence [Sec. 3g from TC1998]
;-----------------------------------------------------------------------------------------
coi = coi*[FINDGEN((n1 + 1L)/2L),REVERSE(FINDGEN(n1/2L))]*dt[0]

IF (do_daughter) THEN BEGIN
  ; => shift so DAUGHTERs are in middle of array
  daughter = [daughter[(n - n1/2L):*,*],daughter[0:(n1/2L - 1L),*]]
ENDIF
;-----------------------------------------------------------------------------------------
; => Compute significance levels [Sec. 4 from TC1998]
;-----------------------------------------------------------------------------------------
sdev      = (MOMENT(y1))[1]    ; => Variance of time series
fft_theor = sdev*fft_theor
dof       = dofmin
; => [Eq. 18 from TC1998]
signif    = fft_theor*CHISQR_CVF(1. - siglvl,dof)/dof
;-----------------------------------------------------------------------------------------
; => Reconstruction [Eq. 11 from TC1998]
;-----------------------------------------------------------------------------------------
IF (recon) THEN BEGIN
  IF (Cdelta EQ -1) THEN BEGIN
    y1      = -1
    errmssg = 'Cdelta undefined, cannot reconstruct with this wavelet'
    MESSAGE,errmssg[0],/INFO
  ENDIF ELSE BEGIN
    fac0 = dj[0]*SQRT(dt[0])/(Cdelta[0]*psi0[0])
    y1   = fac0[0]*(DOUBLE(wave) # (1d0/SQRT(scale)))
    y1   = y1[0L:(n1 - 1L)]
  ENDELSE
ENDIF
;-----------------------------------------------------------------------------------------
; => Return result to user
;-----------------------------------------------------------------------------------------

RETURN,wave[0L:(n1 - 1L),*]
END