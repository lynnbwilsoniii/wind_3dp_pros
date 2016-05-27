;+
;*****************************************************************************************
;
;  FUNCTION :   vector_bandpass.pro
;  PURPOSE  :   This program does a bandpass filter on the input data using IDL's
;                 built-in FFT.PRO routine.  The data is first padded with zeroes
;                 to ensure the number of elements remains an integer power of 2.
;                 The user defines the input vector array of data, the sample rate, 
;                 and frequency range(s) before running the program, then tells the 
;                 program whether a low-pass (i.e. only return low frequency 
;                 signals), high-pass, or middle frequency bandpass filter.  The 
;                 program eliminates the postitive AND negative frequency bins in 
;                 frequency space to ensure symmetry before performing the inverse 
;                 FFT on the data.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               is_a_3_vector.pro
;               power_of_2.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT    :  [N,3]-Element [numeric] array defining the 3-vectors on which
;                           the Fourier filter is to be applied
;               SR     :  Scalar [numeric] defining the sample rate [(unit time)^(-1)]
;               LF     :  Scalar [numeric] defining the low frequency cutoff
;                          [Default = 0]
;               HF     :  Scalar [numeric] defining the high frequency cutoff
;                          [Default = SR[0]/2]
;
;  EXAMPLES:    
;               [calling sequence]
;               filt = vector_bandpass(dat, sr [,lf] [,hf] [,LOWF=lowf] [,MIDF=midf] $
;                                                  [,HIGHF=highf])
;
;               ;;-------------------------------------------------------------------
;               ;;  Apply a low-pass filter
;               ;;    --> frequencies above LF are filtered/removed
;               ;;-------------------------------------------------------------------
;               get_data,'magnetic_field_TPLOT_handle',DATA=mag
;               mag_vec = mag.Y
;               tt      = mag.X                        ;;  Unix time (s since 01/01/1970)
;               sr      = sample_rate(tt,/AVERAGE)     ;;  Avg. sample rate [Hz]
;               lf      = 15d-2                        ;;  Upper bound = 0.15 Hz
;               hf      = 15d-1                        ;;  doesn't matter here
;               lpass   = vector_bandpass(mag_vec,sr,lf,hf,/LOWF)
;
;               ;;-------------------------------------------------------------------
;               ;;  Apply a bandpass filter
;               ;;    --> frequencies below LF and above HF are filtered/removed
;               ;;-------------------------------------------------------------------
;               get_data,'magnetic_field_TPLOT_handle',DATA=mag
;               mag_vec = mag.Y
;               tt      = mag.X                        ;;  Unix time (s since 01/01/1970)
;               sr      = sample_rate(tt,/AVERAGE)     ;;  Avg. sample rate [Hz]
;               lf      = 15d-2                        ;;  Lower bound = 0.15 Hz
;               hf      = 15d-1                        ;;  Upper bound = 1.50 Hz
;               bpass   = vector_bandpass(mag_vec,sr,lf,hf,/MIDF)
;
;               ;;-------------------------------------------------------------------
;               ;;  Apply a high-pass filter
;               ;;    --> frequencies below HF are filtered/removed
;               ;;-------------------------------------------------------------------
;               get_data,'magnetic_field_TPLOT_handle',DATA=mag
;               mag_vec = mag.Y
;               tt      = mag.X                        ;;  Unix time (s since 01/01/1970)
;               sr      = sample_rate(tt,/AVERAGE)     ;;  Avg. sample rate [Hz]
;               lf      = 15d-2                        ;;  doesn't matter here
;               hf      = 15d-1                        ;;  Lower bound = 1.50 Hz
;               lpass   = vector_bandpass(mag_vec,sr,lf,hf,/HIGHF)
;
;  KEYWORDS:    
;               LOWF   :  If set, program returns low-pass filtered data where
;                           frequencies above LF are filtered/removed
;                           [Default = FALSE]
;               MIDF   :  If set, program returns bandpass filtered data where
;                           frequencies below LF and above HF are filtered/removed
;                           [Default = TRUE]
;               HIGHF  :  If set, program returns high-pass filtered data where
;                           frequencies below HF are filtered/removed
;                           [Default = FALSE]
;
;   CHANGED:  1)  Fixed Low Freq. bandpass to get rid of artificial
;                   zero frequency bin created by FFT calc.
;                                                                   [01/14/2009   v1.0.1]
;             2)  Fixed case where NaN's are in data
;                                                                   [01/18/2009   v1.0.2]
;             3)  Changed program my_power_of_2.pro to power_of_2.pro
;                   and renamed
;                                                                   [08/10/2009   v2.0.0]
;             4)  Updated Man. page and cleaned up and
;                   now calls is_a_number.pro, is_a_3_vector.pro
;                                                                   [12/04/2015   v3.0.0]
;
;   NOTES:      
;               1)  The input units for SR, LF, and HF do not matter so long as they are
;                     consistent (e.g., all are in Hz)
;               2)  The definition/use of LF and HF change depending on the keyword set
;                     LOWF  = TRUE
;                       --> frequencies above LF are filtered/removed
;                     MIDF  = TRUE
;                       --> frequencies below LF and above HF are filtered/removed
;                     HIGHF = TRUE
;                       --> frequencies below HF are filtered/removed
;
;  REFERENCES:  
;               1)  Harris, F.J. (1978), "On the Use of Windows for Harmonic Analysis
;                      with the Discrete Fourier Transform," Proc. IEEE Vol. 66,
;                      No. 1, pp. 51-83
;               2)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               3)  Torrence, C. and G.P. Compo "A Practical Guide to Wavelet Analysis,"
;                      Bull. Amer. Meteor. Soc. 79, pp. 61-78, (1998).
;               4)  Donnelly, D. and B. Rust "The Fast Fourier Transform for
;                      Experimentalists, Part I:  Concepts," Comput. Sci. & Eng. 7(2),
;                      pp. 80-88, (2005).
;               5)  Donnelly, D. and B. Rust "The Fast Fourier Transform for
;                      Experimentalists, Part II:  Convolutions," Comput. Sci.
;                      & Eng. 7(4), pp. 92-95, (2005).
;               6)  Rust, B. and D. Donnelly "The Fast Fourier Transform for
;                      Experimentalists, Part III:  Classical Spectral Analysis,"
;                      Comput. Sci. & Eng. 7(5), pp. 74-78, (2005).
;               7)  Rust, B. and D. Donnelly "The Fast Fourier Transform for
;                      Experimentalists, Part IV:  Autoregressive Spectral Analysis,"
;                      Comput. Sci. & Eng. 7(6), pp. 85-90, (2005).
;               8)  Donnelly, D. "The Fast Fourier Transform for Experimentalists,
;                      Part V:  Filters," Comput. Sci. & Eng. 8(1), pp. 92-95, (2006).
;
;   CREATED:  12/30/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/04/2015   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION vector_bandpass,dat,srt,lf,hf,LOWF=lowf,MIDF=midf,HIGHF=highf

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, is_a_3_vector, power_of_2
;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
def_lf         = 0e0
def_hf         = 0e0
;;  Dummy error messages
no_inpt_msg    = 'User must supply an [N,3]-element array of 3-vectors and a scalar sample rate [at minimum]...'
badvfor_msg    = 'Incorrect input format:  DAT must be a [N,3]-element [numeric] array of 3-vectors'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (is_a_number(dat,/NOMSSG) EQ 0) OR  $
                 (is_a_number(srt,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_3_vector(dat,V_OUT=d,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,badvfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define relevant/necessary parameters
;;----------------------------------------------------------------------------------------
;;  Define the number of vectors and sample rate
no             = N_ELEMENTS(d[*,0])     ;;  # of 3-vectors
sr             = 1d0*srt[0]             ;;  input sample rate [(unit time)^(-1)]
def_hf         = sr[0]/2d0              ;;  Default high frequency limit = Nyquist frequency
;;  Define defaults
IF (N_PARAMS() LT 4) THEN BEGIN
  ;;  User supplied less than 4 parameters
  IF (N_PARAMS() LT 3) THEN BEGIN
    ;;  User only supplied DAT and SR --> Define LF and/or HF
    lf  = def_lf[0]
    hf  = def_hf[0]
  ENDIF ELSE BEGIN
    ;;  User supplied DAT, SR, and LF --> Define HF
    IF (is_a_number(lf,/NOMSSG) EQ 0) THEN lf = def_lf[0]
    hf  = def_hf[0]
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Make sure LF and HF are numeric
  IF (is_a_number(lf,/NOMSSG) EQ 0) THEN lf = def_lf[0]
  IF (is_a_number(hf,/NOMSSG) EQ 0) THEN hf = def_hf[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Replace NaNs with zeros so FFT will return finite values
;;----------------------------------------------------------------------------------------
bbx            = WHERE(FINITE(d[*,0]) EQ 0,bx,COMPLEMENT=ggx)
bby            = WHERE(FINITE(d[*,1]) EQ 0,by,COMPLEMENT=ggy)
bbz            = WHERE(FINITE(d[*,2]) EQ 0,bz,COMPLEMENT=ggz)
IF (bx GT 0L) THEN d[bbx,0] = 0d0
IF (by GT 0L) THEN d[bby,1] = 0d0
IF (bz GT 0L) THEN d[bbz,2] = 0d0
;;----------------------------------------------------------------------------------------
;;  Pad data with zeros to change # of elements --> 2^m  {m = integer}
;;----------------------------------------------------------------------------------------
d2x            = power_of_2(d[*,0])
d2y            = power_of_2(d[*,1])
d2z            = power_of_2(d[*,2])
d2             = [[d2x],[d2y],[d2z]]
nd             = N_ELEMENTS(d2x)
n_m            = nd[0]/2L + 1L           ;;  mid point element (i.e., where frequencies go negative in FFT)
;;----------------------------------------------------------------------------------------
;;  Define FFT frequencies
;;----------------------------------------------------------------------------------------
frn            = nd[0] - n_m[0]
frel           = LINDGEN(frn) + n_m[0]   ;;  Elements for negative frequencies
fft_freq       = LINDGEN(nd)
fft_freq[frel] = (n_m[0] - nd[0]) + DINDGEN(n_m[0] - 2L)
fft_freq       = fft_freq*(sr[0]/nd[0])
;;----------------------------------------------------------------------------------------
;;  Determine relevant elements of FFT arrays
;;----------------------------------------------------------------------------------------
lfc1           = 1d0*lf[0]
hfc1           = 1d0*hf[0]
lowf1          = WHERE(ABS(fft_freq) LE lfc1[0] AND ABS(fft_freq) GT 0d0,lf1,COMPLEMENT=other_mh)
midf1          = WHERE(ABS(fft_freq) GT lfc1[0] AND ABS(fft_freq) LE hfc1[0],mf1,COMPLEMENT=other_lh)
highf1         = WHERE(ABS(fft_freq) GT hfc1[0],hf1,COMPLEMENT=other_lm)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(lowf)  THEN lowf1  = 1 ELSE lowf1  = 0
IF KEYWORD_SET(midf)  THEN midf1  = 1 ELSE midf1  = 0
IF KEYWORD_SET(highf) THEN highf1 = 1 ELSE highf1 = 0
check          = [KEYWORD_SET(lowf1),KEYWORD_SET(midf1),KEYWORD_SET(highf1)]
gcheck         = WHERE(check GT 0,gch,COMPLEMENT=bcheck,NCOMPLEMENT=bch)
;;  Determine which filter to use
gelems         = {T0:other_mh,T1:other_lh,T2:other_lm}
IF (gch EQ 1L) THEN BEGIN
  ;;  Define elements to eliminate in frequency space
  other = gelems.(gcheck[0])
ENDIF ELSE BEGIN ;;  Default setting b/c user entered too many keywords
  ;;  Default = bandpass
  other = other_lh
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Calculate FFT
;;----------------------------------------------------------------------------------------
tempx          = FFT(d2x,/DOUBLE)
tempy          = FFT(d2y,/DOUBLE)
tempz          = FFT(d2z,/DOUBLE)
;;  Create dummy copy of FFTs
templx         = tempx
temply         = tempy
templz         = tempz
;;----------------------------------------------------------------------------------------
;;  Get rid of unwanted frequencies
;;----------------------------------------------------------------------------------------
templx[other]  = DCOMPLEX(0d0)  ;;  Get rid of unwanted frequencies [mid and high]
temply[other]  = DCOMPLEX(0d0)
templz[other]  = DCOMPLEX(0d0)
;;----------------------------------------------------------------------------------------
;;  Calculate Inverse FFT
;;    Note:  Inverse will still be complex --> keep only the real part
;;----------------------------------------------------------------------------------------
rplx           = REAL_PART(FFT(templx,1,/DOUBLE))
rply           = REAL_PART(FFT(temply,1,/DOUBLE))
rplz           = REAL_PART(FFT(templz,1,/DOUBLE))
;;----------------------------------------------------------------------------------------
;;  Keep only useful data [i.e. get rid of the zero-padded elements]
;;----------------------------------------------------------------------------------------
lower          = 0L
upper          = (no[0] - 1L)
filtered       = [[rplx[lower[0]:upper[0]]],[rply[lower[0]:upper[0]]],[rplz[lower[0]:upper[0]]]]
;filtered       = [[rplx[0:(no-1L)]],[rply[0:(no-1L)]],[rplz[0:(no-1L)]]]
;;----------------------------------------------------------------------------------------
;;  Return NaNs to arrays if they were present on input
;;----------------------------------------------------------------------------------------
IF (bx GT 0L) THEN filtered[bbx,0] = !VALUES.D_NAN
IF (by GT 0L) THEN filtered[bby,1] = !VALUES.D_NAN
IF (bz GT 0L) THEN filtered[bbz,2] = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,filtered
END










