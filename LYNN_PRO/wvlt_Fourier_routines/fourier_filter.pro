;+
;*****************************************************************************************
;
;  FUNCTION :   fourier_filter.pro
;  PURPOSE  :   Performs a Fourier filter where the return result is a low-pass filter
;                 with NKEEP-Fourier modes.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               power_of_2.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               XX      :  N-Element array of data to be filtered
;               NKEEP   :  Scalar defining the number of Fourier frequency bins to keep
;                            when performing the low-pass filter
;
;  EXAMPLES:    
;               ; => keep lowest 10 frequencies and pad with zeros
;               test = fourier_filter(xx,10L,/PAD)
;
;  KEYWORDS:    
;               PAD     :  If set, program pads the input array with zeros
;
;   CHANGED:  1)  Fixed an issue that occurred when N was an odd # [04/20/2011   v1.0.1]
;
;   NOTES:      
;               
;
;   CREATED:  04/19/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/20/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION fourier_filter,xx,nkeep,PAD=pad

;-----------------------------------------------------------------------------------------
; => Define dummy variables and check keywords
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
badinmssg      = 'Incorrect input:  NKEEP must be << XX number of elements.'
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
xo     = REFORM(xx)
nx     = N_ELEMENTS(xo)
nk     = nkeep[0]
IF (nk GE nx/2L) THEN BEGIN
  MESSAGE,badinmssg,/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;-----------------------------------------------------------------------------------------
; => Get rid of any NaN's so FFT can actually work
;-----------------------------------------------------------------------------------------
bbx = WHERE(FINITE(xo) EQ 0,bx,COMPLEMENT=ggx,NCOMPLEMENT=gx)
IF (bx GT 0L) THEN xo[bbx] = 0d0
IF KEYWORD_SET(pad) THEN x2 = power_of_2(xo) ELSE x2 = xo
nd     = N_ELEMENTS(x2)
IF (nd MOD 2L) THEN nd += 1L   ; => make sure nd is even
n_m    = nd/2L + 1L  ; -mid point element
;-----------------------------------------------------------------------------------------
; => Calc FFT frequencies
;-----------------------------------------------------------------------------------------
sr             = 1d0    ; => Dummy sample rate
frn            = nd - n_m
frel           = LINDGEN(frn) + n_m   ; -Elements for negative frequencies
fft_freq       = LINDGEN(nd)
fft_freq[frel] = (n_m - nd) + DINDGEN(n_m - 2L)
fft_freq       = fft_freq*(sr/nd)
;-----------------------------------------------------------------------------------------
; => Determine relevant elements of FFT array
;-----------------------------------------------------------------------------------------
hfc1   = ABS(fft_freq[nk - 1L])     ; => Top frequency to keep
test   = (ABS(fft_freq) LE hfc1[0]) AND (ABS(fft_freq) GT 0d0)
lowf1  = WHERE(test,lf1,COMPLEMENT=other,NCOMPLEMENT=nother)
;-----------------------------------------------------------------------------------------
; => Calc FFT
;-----------------------------------------------------------------------------------------
tempx = FFT(x2,/DOUBLE)
; => Get rid of unwanted frequencies [mid and high]
IF (nother GT 0) THEN tempx[other]  = DCOMPLEX(0d0)
; => Calc Inverse FFT
rplx  = REAL_PART(FFT(tempx,1,/DOUBLE))
;-----------------------------------------------------------------------------------------
; => Keep only useful data [i.e. get rid of the zero-padded elements]
;-----------------------------------------------------------------------------------------
filt  = rplx[0L:(nx - 1L)]
;-----------------------------------------------------------------------------------------
; => Return NaN's to their rightful places
;-----------------------------------------------------------------------------------------
IF (bx GT 0) THEN filt[bbx] = d

RETURN,filt
END