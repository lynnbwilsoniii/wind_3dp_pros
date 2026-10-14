;+
;*****************************************************************************************
;
;  FUNCTION :   my_windowf.pro
;  PURPOSE  :   Creates an array of data corresponding to a Hanning or Hamming window
;                 depending on user defined input (IWINDW) for FFT power spectrum
;                 analysis.
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
;               NSAMPLES   :  Scalar value defining the maximum element indices for
;                               WINDOWARR
;               IWINDW     :  Scalar defining the type of window to use
;                               0 = Rectangle [Dirichlet] Window {Default}
;                               1 = Hamming Window
;                               2 = Hanning Window
;                               3 = Triangle [Fejer, Bartlet] Window
;                               4 = Blackman-Harris Window [4-term]
;                               5 = Kaiser-Bessel Window [alpha = 3.0]
;               WINDOWARR  :  [N]-Element array to be filled by program with
;                               the corresponding Hanning(Hamming) window determined
;                               by the user
;
;  EXAMPLES:    
;               nfbins   = N_ELEMENTS(signal)
;               fft_win  = FLTARR(nfbins)
;               ; => Use a Hanning Window
;               my_windowf,nfbins - 1L,2,fft_win
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Vectorized a few calculations and changed syntax  [10/16/2008   v1.0.0]
;             2)  Cleaned up routine and updated man page           [06/15/2011   v1.1.0]
;
;   NOTES:      
;               1)  The routine normalizes the window so the user does not need to
;                     when determining the power spectral density (PSD)
;
;  REFERENCES:  
;               1)  Harris, F.J. (1978), "On the Use of Windows for Harmonic Analysis
;                      with the Discrete Fourier Transform," Proc. IEEE Vol. 66,
;                      No. 1, pp. 51-83
;               2)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;
;   ADAPTED FROM:  windowf.pro  BY:  Kris Kersten,  Sept. 2007
;   CREATED:  10/16/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/15/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO my_windowf,nsamples,iwindw,windowarr

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
twopi          = 2d0*!DPI

nw             = N_ELEMENTS(windowarr) - 1L
IF (nsamples[0] NE nw[0]) THEN nsamples[0] = nw[0]
;-----------------------------------------------------------------------------------------
; => Alpha parameter found in F.J. Harris, PROC. IEEE Vol. 66, (1978).
;   Hanning Window = 0.5
;   Hamming Window = 25/46
;-----------------------------------------------------------------------------------------
nw1            = nw[0] + 1L
nwd            = 1d0*nw1[0]
CASE iwindw[0] OF
  0    : BEGIN
    ; => Rectangle [Dirichlet] Window
    ; => Eq. 21b in Harris, (1978)
    windowarr  = REPLICATE(1,nw1)
  END
  1    : BEGIN
    ; => Hamming Window
    alpha      = 25d0/46d0
    al1        = 1d0 - alpha[0]
    n0         = 2d0*!DPI/nwd[0]*LINDGEN(nw1[0])
    ; => Eq. 30b in Harris, (1978)
    windowarr  = alpha[0] - al1[0]*COS(n0)
  END
  2    : BEGIN
    ; => Hanning Window
    n0         = 2d0*!DPI/nwd[0]*LINDGEN(nw1[0])
    ; => Eq. 27b in Harris, (1978)
    windowarr  = 5d-1*(1d0 - COS(n0))
  END
  3    : BEGIN
    ; => Triangle [Fejer, Bartlet] Window
    n0         = (2d0/nwd[0])*LINDGEN(nw1[0]/2L)
    n1         = nw1[0] - (LINDGEN(nw1[0]/2L) + nw1[0]/2L)
    n2         = 1d0 - (2d0/nwd[0])*ABS(n1)
    ; => Eq. 23b in Harris, (1978)
    windowarr  = [n0,n2]
  END
  4    : BEGIN
    ; => Blackman-Harris Window [coeffs in Table on page 65 of Harris, (1978)]
    nn         = LINDGEN(nw1[0])
    nfac       = 2d0*!DPI/nwd[0]
    n1         = nfac[0]*nn
    n2         = 2d0*n1
    n3         = 3d0*n1
    a0         = 0.35875d0
    a1         = 0.48829d0
    a2         = 0.14128d0
    a3         = 0.01168d0
    ; => Eq. 33 in Harris, (1978)
    windowarr  = a0[0] - a1[0]*COS(n1) + a2[0]*COS(n2) - a3[0]*COS(n3)
  END
  5    : BEGIN
    ; => Kaiser-Bessel Window [Eq. 46a in Harris, (1978) with n -> n + N/2]
    alpha      = 3d0*!DPI    ; => use alpha = 3 since it kills side lobes well [Fig. 52]
    denom      = BESELI(alpha[0],0,/DOUBLE)
    nwd2       = nwd[0]/2d0
    nn         = LINDGEN(nw1[0]) + nwd2
    argum      = alpha[0]*SQRT(1d0 - (nn/nwd2[0])^2)
    windowarr  = BESELI(argum,0,/DOUBLE)/denom[0]
  END
  ELSE : BEGIN
    windowarr  = FLTARR(nw1[0])
    my_windowf,nw[0],0,windowarr
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Normalize window
;-----------------------------------------------------------------------------------------
sumsq      = TOTAL(windowarr^2,/NAN)
sqsum      = TOTAL(windowarr  ,/NAN)^2
; => Calculate the processing gain [Eq. 15 in Harris, (1978)]
pg         = sqsum[0]/sumsq[0]
; => Calculate the equivalent noise bandwidth (ENBW) [Eq. 11 in Harris, (1978)]
enbw       = 1d0/pg[0]
; => Calculate the mean square value of window [Eq. 1.27 in Paschmann and Daly, (1998)]
rmsw       = sumsq[0]/nwd[0]
; => Normalize window
windowarr /= rmsw[0]

RETURN
END
