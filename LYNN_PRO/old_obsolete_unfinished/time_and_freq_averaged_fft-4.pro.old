;+
;*****************************************************************************************
;
;  FUNCTION :   time_and_freq_averaged_fft.pro
;  PURPOSE  :   Calculates the time and frequency averaged FFT of an input time series,
;                 either as the magnitude of a vector or the magnitude of a scalar.
;                 On output, the routine returns a structure containing the relevant
;                 parameters/results.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               is_a_number.pro
;               format_2d_vec.pro
;               sample_rate.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TIME   :  [N]-Element [double] array of time stamps, preferably with
;                           uniform spacing and in the units of seconds
;                             --> frequencies = Hz
;               DATA   :  [N,3]- or [N]-Element [float/double] array of dependent
;                           variable data corresponding to TIME
;
;  EXAMPLES:    
;               test = time_and_freq_averaged_fft(time,data,FLOW=flow,FHIGH=fhigh)
;
;  KEYWORDS:    
;               FLOW   :  Scalar [float/double] defining the low frequency [Hz]
;                           cutoff to use for the Poynting flux analysis
;                           [Default = 0.0]
;               FHIGH  :  Scalar [float/double] defining the high frequency [Hz]
;                           cutoff to use for the Poynting flux analysis
;                           [Default = sample rate of input]
;               NFFT   :  Scalar [long] defining the # of frequency bins in each FFT
;                           [Default = 128]
;               NSHFT  :  Scalar [long] defining the # of points to shift between
;                           each FFT
;                           [Default = 32]
;
;   CHANGED:  1)  Fixed Hanning window normalization
;                                                                   [05/07/2014   v1.0.1]
;             2)  Fixed FFT power spectrum normalization and
;                   changed output structure and
;                   added references to Man. page
;                                                                   [05/07/2014   v1.0.2]
;             3)  Cleaned up a little and moved to ~/LYNN_PRO/wvlt_Fourier_routines/
;                                                                   [05/15/2014   v1.0.3]
;             4)  Now routine only returns elements of time-windowed FFTs between
;                   FLOW and FHIGH (forgot to fix this earlier) and
;                   now calls FORWARD_FUNCTION.PRO and is_a_number.pro
;                                                                   [07/08/2015   v1.1.0]
;
;   NOTES:      
;               1)  If [TIME] = seconds, then the output frequencies will be in Hz.
;                     Technically, any unit of time on input is okay so long as the
;                     user stays consistent and is aware that the routine does not
;                     know the units of TIME or DATA.
;               2)  Make sure the units of FLOW and FHIGH are consistent with the
;                     inverse units of TIME.
;
;  REFERENCES:  
;               1)  Harris, F.J. "On the Use of Windows for Harmonic Analysis with the
;                      Discrete Fourier Transform," Proc. IEEE Vol. 66, No. 1,
;                      pp. 51-83, (1978).
;               2)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                      Data," ISSI Scientific Report, Noordwijk, The Netherlands.,
;                      Int. Space Sci. Inst, (1998).
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
;   CREATED:  05/06/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/08/2015   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION time_and_freq_averaged_fft,time,data,FLOW=flow,FHIGH=fhigh,NFFT=nfft,NSHFT=nshft

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, format_2d_vec, sample_rate
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_nfft       = 128L          ;;  Default # of frequency bins in each FFT
def_nsht       = 32L           ;;  " " points to shift between each FFT
;;  Dummy error messages
bad_nin_mssg   = 'Incorrect # of inputs'
badinp_msg     = 'Bad input formats:  TIME and DATA must be numeric inputs'
badtsp_msg     = 'Bad timestamp input format:  TIME must be an [N]-element array'
bad_fdin_mssg  = 'Incorrect input format:  DATA must be an [N]- or [N,3]-element array'
bad_Tin_mssg   = 'Timestamps must satisfy:  T[i+1] - T[i] > 0'
bad_NfNs_mssg  = 'Keywords must satisfy:  NFFT ≥ 2*NSHFT --> Using default values...'
bad_fran_mssg  = 'Bad frequency range defined --> Return all values'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  LBW III  07/08/2015   v1.1.0
;test           = (N_PARAMS() LT 2)
test           = (N_PARAMS() LT 2) OR (N_ELEMENTS(time) EQ 0) OR (N_ELEMENTS(data) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  no input???
  MESSAGE,bad_nin_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;  LBW III  07/08/2015   v1.1.0
test           = (is_a_number(time,/NOMSSG) EQ 0) OR (is_a_number(data,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  bad input format???
  MESSAGE,badinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check input formats
;;----------------------------------------------------------------------------------------
;;  Define new parameters
tt             = REFORM(time)
vv             = REFORM(data)
;;  Check input TIME format
szdt           = SIZE(tt,/DIMENSIONS)
sznt           = SIZE(tt,/N_DIMENSIONS)
szdd           = SIZE(vv,/DIMENSIONS)
sznd           = SIZE(vv,/N_DIMENSIONS)
test           = (sznt[0] NE 1)
IF (test[0]) THEN BEGIN
  ;;  incorrect timestamp input format
  MESSAGE,badtsp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;  Check input DATA format
is_1D          = (sznd[0] EQ 1)
is_2D          = (sznd[0] EQ 2)
IF (is_2D[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  2D input --> check format
  ;;--------------------------------------------------------------------------------------
;;  LBW III  07/08/2015   v1.1.0
;  test = (szdd[0] NE szdt[0]) AND (szdd[0] NE szdt[0])
  vv             = format_2d_vec(vv)
  szdd           = SIZE(vv,/DIMENSIONS)
  test           = (N_ELEMENTS(vv) LE 9) OR (szdd[0] NE szdt[0])
ENDIF ELSE BEGIN
  IF (is_1D[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  1D input
    ;;------------------------------------------------------------------------------------
    test = (szdd[0] NE szdt[0])
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  ?D input
    ;;------------------------------------------------------------------------------------
    test = 0b
;;  LBW III  07/08/2015   v1.1.0
;    MESSAGE,bad_fdin_mssg[0],/INFORMATIONAL,/CONTINUE
;    RETURN,0
  ENDELSE
ENDELSE

IF (test[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  # of timestamps do not match # of data points/vectors
  ;;--------------------------------------------------------------------------------------
  MESSAGE,bad_fdin_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Correct input format
  ;;--------------------------------------------------------------------------------------
;;  LBW III  07/08/2015   v1.1.0
;  IF (sznd[0] EQ 2) THEN BEGIN
;    vv   = 1d0*format_2d_vec(vv)
;    test = (N_ELEMENTS(vv) LT 3) AND (vv[0] EQ 0)
  IF (is_2D[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  2D input --> check format
    ;;------------------------------------------------------------------------------------
    test = (N_ELEMENTS(vv) LT 3)
    IF (test[0]) THEN RETURN,0
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  1D input --> force to [N,3]-element array
    ;;------------------------------------------------------------------------------------
    vv   = REFORM(vv) # REPLICATE(1d0,3L)
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Sort data by time (just in case)
;;----------------------------------------------------------------------------------------
nt             = N_ELEMENTS(tt)               ;;  # of time stamps
sp             = SORT(tt)
tt             = TEMPORARY(tt[sp])
vv             = TEMPORARY(vv[sp,*])
;;  LBW III  07/08/2015   v1.1.0
;tt             = tt[sp]
;vv             = vv[sp,*]
;;  Estimate average ∆t
i              = LINDGEN(nt[0] - 1L)
j              = i + 1L
dt_all         = [0d0,(tt[j] - tt[i])]
bad            = WHERE(dt_all LE 0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0) THEN dt_all[bad] = d
;;  Make sure time stamps are ascending and not the same value
IF (gd LT 2) THEN BEGIN
  ;;  timestamps were all equal --> BAD!
  MESSAGE,bad_Tin_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
dt_avg         = MEAN(dt_all,/NAN)
;;  Define sample rate
srate          = DOUBLE(sample_rate(tt,GAP_THRESH=2*dt_avg[0],/AVE))
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  LBW III  07/08/2015   v1.1.0
;IF (N_ELEMENTS(flow) NE 1)  THEN flow   = 0d0      ELSE flow   = DOUBLE(flow[0])
;IF (N_ELEMENTS(fhigh) NE 1) THEN fupp   = srate[0] ELSE fupp   = DOUBLE(fhigh[0])
;IF (N_ELEMENTS(nfft) NE 1)  THEN nfft   = 128L     ELSE nfft   = LONG(nfft[0])
;IF (N_ELEMENTS(nshft) NE 1) THEN nshft  = 32L      ELSE nshft  = LONG(nshft[0])

;;  Check FLOW
test           = ((is_a_number(flow,/NOMSSG) EQ 0) OR (N_ELEMENTS(flow) EQ 0))
IF (test[0]) THEN flow  = 0d0         ELSE flow  = DOUBLE(flow[0])
;;  Check FHIGH
test           = ((is_a_number(fhigh,/NOMSSG) EQ 0) OR (N_ELEMENTS(fhigh) EQ 0))
IF (test[0]) THEN fupp  = srate[0]    ELSE fupp  = DOUBLE(fhigh[0])
;;  Check NFFT
test           = ((is_a_number(nfft,/NOMSSG) EQ 0) OR (N_ELEMENTS(nfft) EQ 0))
IF (test[0]) THEN nfft  = def_nfft[0] ELSE nfft  = LONG(nfft[0])
;;  Check NSHFT
test           = ((is_a_number(nshft,/NOMSSG) EQ 0) OR (N_ELEMENTS(nshft) EQ 0))
IF (test[0]) THEN nshft = def_nsht[0] ELSE nshft = LONG(nshft[0])
;;  Make sure NFFT ≥ 2*NSHFT
test           = (nfft[0] LT 2*nshft[0])
IF (test[0]) THEN BEGIN
  ;;  Use default values
  MESSAGE,bad_NfNs_mssg[0],/INFORMATIONAL,/CONTINUE
;;  LBW III  07/08/2015   v1.1.0
;  nfft   = 128L
;  nshft  = 32L
  nfft   = def_nfft[0]
  nshft  = def_nsht[0]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define some dummy parameters
;;----------------------------------------------------------------------------------------
nt_a           = nt[0] - 1L                   ;;  # of total points less one
n_dft          = nt_a[0] - nfft[0]            ;;  # of time stamps to sum over per interval
bw             = srate[0]/nfft[0]             ;;  Bandwidth [ Hz or 1/[TIME] ] of each FFT frequency bin
n_ts           = nt[0]/nshft[0] + 1L          ;;  # of time-windowed FFTs
freq           = DINDGEN(nfft[0]/2d0)*bw[0]   ;;  FFT frequency bin values [ Hz or 1/[TIME] ]
;;  Determine which frequencies to use/keep
gind_f         = WHERE(freq GE flow[0] AND freq LE fupp[0],gdsf)
;;  Create a Hanning window
win            = HANNING(nfft[0],/DOUBLE)
win           /= MEAN(win^2,/NAN)             ;;  preserve energy
;;----------------------------------------------------------------------------------------
;;  Calculate floating FFTs
;;----------------------------------------------------------------------------------------
;;  Define a dummy array for the complex FFT of DATA
vv__fft        = DCOMPLEXARR(n_ts[0],nfft[0],3L)  ;;  [K,W,3]-Element array
tt__fft        = DBLARR(n_ts[0])                  ;;  [K]-Element array
i              = 0L
FOR j=0L, n_dft[0] - 1L, nshft[0] DO BEGIN
  upj       = j[0] + nfft[0] - 1L
  FOR k=0L, 2L DO vv__fft[i,*,k] = FFT(vv[j[0]:upj[0],k]*win,/DOUBLE)
  ;;  increment i
  i++
ENDFOR
;;  Keep only computed/calculated values
ind            = (i[0] - 1L)
;;  Remove extra/empty spectra on end of output array
vv__fft        = vv__fft[0L:(ind[0] - 1L),*,*]
;;  Define timestamps for FFTs
tt__fft        = tt[0] + (DINDGEN(ind[0])*nshft[0] + nfft[0]/2d0)/srate[0]
;;----------------------------------------------------------------------------------------
;;  Calculate FFT power
;;----------------------------------------------------------------------------------------
IF (gdsf GT 0) THEN BEGIN
  ;;  Good frequency range defined
  gind     = gind_f
ENDIF ELSE BEGIN
  ;;  Bad frequency range defined --> Return all
  gind     = LINDGEN(N_ELEMENTS(freq))
  MESSAGE,bad_fran_mssg[0],/INFORMATIONAL,/CONTINUE
ENDELSE
;;  Define output frequencies
g_freqs        = freq[gind]
amplt__f       = REPLICATE(d,N_ELEMENTS(tt__fft))        ;;  Dummy array for FFT amplitude   [units Hz^(-1/2)]
power__f       = REPLICATE(d,N_ELEMENTS(tt__fft))        ;;  Dummy array for FFT power       [units^2 Hz^(-1)]
;;  LBW III  07/08/2015   v1.1.0
;;  Define output data and (V.V*)
vv__fft        = TEMPORARY(vv__fft[*,gind,*])
vv_dot_vv      = vv__fft*CONJ(vv__fft)
IF (is_2D[0]) THEN BEGIN
  ;;  2D  -->  Sum over squared vector components
  vv_fft   = REFORM(vv__fft)
  temp0    = TOTAL(vv_dot_vv,3L,/NAN)
;;  LBW III  07/08/2015   v1.1.0
;  vv_fft   = REFORM(vv__fft[*,gind,*])
;  temp0    = TOTAL(vv_fft^2,3L,/NAN)
ENDIF ELSE BEGIN
  ;;  1D  -->  Square component
  vv_fft   = REFORM(vv__fft[*,*,0])
  temp0    = REFORM(vv_dot_vv[*,*,0])
;;  LBW III  07/08/2015   v1.1.0
;  vv_fft   = REFORM(vv__fft[*,gind,0])
;  temp0    = REFORM(vv__fft^2)
ENDELSE
;;    -->  Sum over frequency bins
temp1          = TOTAL(temp0,2L,/NAN)
;;  Define power = |A|*(2N/Sr)^(1/2)  [units Hz^(-1/2)]
afac           = SQRT(2d0*nfft[0]/srate[0])
amplt__f       = SQRT(temp1)*afac[0]
;;  Define power = (2N/Sr)*|A|^2  [units^2 Hz^(-1)]
pfac           = 2d0*nfft[0]/srate[0]
power__f       = ABS(temp1)*pfac[0]
;;  Remove negative or zero values
bad            = WHERE(power__f LE 0,bd)
IF (bd GT 0) THEN power__f[bad] = d
;;----------------------------------------------------------------------------------------
;;  Create return structure
;;----------------------------------------------------------------------------------------
tags           = ['TIME_FFT','VEC_FFT','FREQ_FFT','AMP_FFT','POWER_FFT']
struc          = CREATE_STRUCT(tags,tt__fft,vv__fft,g_freqs,amplt__f,power__f)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END





