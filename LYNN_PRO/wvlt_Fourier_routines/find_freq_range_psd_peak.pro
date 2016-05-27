;+
;*****************************************************************************************
;
;  FUNCTION :   find_freq_range_psd_peak.pro
;  PURPOSE  :   This routine attempts to find the frequency range associated with the
;                 peak in an Fourier power spectrum of a single vector component
;                 timeseries of data.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               sample_rate.pro
;               fft_power_calc.pro
;               partition_data.pro
;               find_intersect_2_curves.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TIME    :  [N]-Element [double] array of time [s] abscissa points for
;                            each field vector component in FIELD
;               FIELD   :  [N]-Element [float/double] array of data points defining the
;                            vector field component for each timestamp in TIME
;
;  EXAMPLES:    
;               ;;  Find spectral peak frequency range between 1 Hz and 10 kHz
;               fran_peak = temp_find_wave_freq_peak(time,field,FREQRA=[1d0,1d4])
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               FREQRA       :  [2]-Element [float/double] array defining the range of
;                                 frequencies [Hz] to use when searching for the peak
;                                 of the power spectrum
;                                 [Default = [0,(Sample Rate)/2] ]
;               FPKMIN       :  Scalar [float/double] defining the minimum allowable
;                                 frequency [Hz] for the spectral peak (useful for
;                                 spectrums with enhanced power at lower frequencies
;                                 that are not part of the peak of interest)
;                                 [Default = FREQRA[0] ]
;               FPKMAX       :  Scalar [float/double] defining the maximum allowable
;                                 frequency [Hz] for the spectral peak (useful for
;                                 spectrums with enhanced power at higher frequencies
;                                 that are not part of the peak of interest)
;                                 [Default = FREQRA[0] ]
;               ALPHA        :  Scalar [float/double] defining the fraction of the
;                                 spectral peak to use when defining the frequency
;                                 range of the peak.  The routine will limit the
;                                 values to between 5% and 99%.
;                                 [Default = 50% ]
;               SYMMETRY     :  If set, routine will check to see if one of the bounds
;                                 of the frequency range of the peak is asymmetrically
;                                 "lopsided" due to "bad" bound finding.  If a bound
;                                 is "lopsided," then the routine will force a
;                                 symmetric ∆f on either side of the spectral peak.  We
;                                 define:
;                                   j          = lower (l) or upper (u)
;                                   i          = smoothed envelope (E) or PSD peak (S)
;                                   f_10       = Log_10 (f)
;                                   (∆f_ji)_10 = | (f_j)_10 - (fpk_i)_10 |
;                                   (∂f_j)_10  = | 1 - (∆f_jS)_10/(∆f_jE)_10 |
;                                   Test       = MAX((∂f_j)_10)/MIN((∂f_j)_10) > SYMM_THRESH
;                                 Thus, to be defined as "lopsided," Test = TRUE
;               SYMM_THRESH  :  Scalar [float/double] defining the fractional excess
;                                 ratio threshold to use when determining whether a
;                                 frequency bound has been incorrectly defined
;                                 [Default = 2.0]
;               *********************************************
;               ***  keywords used by partition_data.pro  ***
;               *********************************************
;               LENGTH       :  Scalar [long] defining the # of elements to use when
;                                 defining the frequency bins for partitioning the data
;                                 to find the envelope around the power spectra.
;                                 [Default = 4]
;               OFFSET       :  Scalar [long] defining the # of elements to shift from
;                                 the start of each frequency bin
;                                 [Default = 4]
;               **********************************
;               ***      INDIRECT OUTPUTS      ***
;               **********************************
;               OUTPUT       :  Set to a named variable that on return will be a
;                                 structure containing results from the analysis in
;                                 this routine, where the structure tags are
;                                 defined as:
;
;               PSD_ENVELOPE_XY               :  Envelope around the PSD vs frequency,
;                                                where data is binned by frequency and
;                                                then lower/upper bounds are found
;                                                (result returned by partition_data.pro)
;               PSD_STRUC                     :  PSD structure returned by the routine
;                                                fft_power_calc.pro
;               SAMPLE_RATE                   :  Sample rate of input timeseries (sps)
;               FREQ_AT_ENV_MAX_POWER         :  Frequency [Hz] at the peak power of the
;                                                smoothed upper bound of the PSD envelope
;               FREQ_RANGE_ENV_DPDF_MNMX      :  Frequency [Hz] range of PSD peak defined
;                                                by the minima/maxima of dP/df of both
;                                                the upper and lower bound of the
;                                                smoothed envelope as bounding limits
;               FREQ_RANGE_ENV_DPDF_PERC_PK   :  Frequency [Hz] range of PSD peak defined
;                                                by using a percentage (defined by ALPHA)
;                                                of the minima/maxima of dP/df of both
;                                                the upper and lower bound of the
;                                                smoothed envelope as bounding limits
;               FREQ_AT_SM_PSD_MAX_POWER      :  Frequency [Hz] at the peak power of the
;                                                smoothed PSD
;               FREQ_RANGE_PSD_PERC_PK        :  Frequency [Hz] range of PSD peak defined
;                                                by using a percentage (defined by ALPHA)
;                                                of the smoothed PSD as bounding limits
;                                                [initial guess for main return result
;                                                 of this routine]
;               FRAN_PSD_PERC_PK_IND_INITIAL  :  Initial indices of the FFT frequencies
;                                                closest to the values of
;                                                FREQ_RANGE_PSD_PERC_PK
;               FRAN_PSD_PERC_PK_IND_FINAL    :  Final indices of the FFT frequencies
;                                                used to define the returned frequency
;                                                range
;                                                [** May be the same as initial indices **]
;               XY_INT_FRAC_ENV_PK            :  All XY-intercepts between smoothed upper
;                                                bound of PSD envelope and percentage of
;                                                the peak in this envelope
;               XYINT_FRAC_ENV_L_MN           :  All XY-intercepts between smoothed lower
;                                                bound of PSD envelope and percentage of
;                                                the minima in dP/df of this envelope
;               XYINT_FRAC_ENV_L_MX           :  All XY-intercepts between smoothed lower
;                                                bound of PSD envelope and percentage of
;                                                the maxima in dP/df of this envelope
;               XYINT_FRAC_ENV_H_MN           :  All XY-intercepts between smoothed upper
;                                                bound of PSD envelope and percentage of
;                                                the minima in dP/df of this envelope
;               XYINT_FRAC_ENV_H_MX           :  All XY-intercepts between smoothed upper
;                                                bound of PSD envelope and percentage of
;                                                the maxima in dP/df of this envelope
;               XY_INT_FRAC_PK                :  All XY-intercepts between smoothed PSD
;                                                and a percentage of the peak of the
;                                                smoothed PSD
;               PSD_ENVELOPE_XX               :  Avg. frequency [Hz] of binned range for
;                                                envelope around the PSD vs frequency
;               PSD_ENVELOPE_YY               :  Lower/Upper bound PSD [units^2 Hz^(-1)]
;                                                in binned range for envelope around the
;                                                PSD vs frequency
;               PSD_ENVELOPE_SM               :  Smoothed version of PSD_ENVELOPE_YY
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [01/25/2015   v1.0.0]
;             2)  Continued to write routine
;                                                                   [01/26/2015   v1.0.0]
;             3)  Continued to write routine
;                                                                   [01/26/2015   v1.0.0]
;             4)  Continued to write routine
;                                                                   [01/26/2015   v1.0.0]
;             5)  Finished writing routine and renamed to
;                   find_freq_range_psd_peak.pro from temp_find_wave_freq_peak.pro
;                                                                   [01/27/2015   v1.0.0]
;             6)  Added more results to OUTPUT structure, tags:
;                   PSD_ENVELOPE --> PSD_ENVELOPE_XY
;                   PSD_ENVELOPE_XX
;                   PSD_ENVELOPE_YY
;                   PSD_ENVELOPE_SM
;                                                                   [01/28/2015   v1.0.1]
;             7)  Added keywords:  SYMM_THRESH and SYMMETRY
;                                                                   [01/28/2015   v1.0.2]
;             8)  Added keywords:  LENGTH and OFFSET
;                   and now calls is_a_number.pro
;                                                                   [04/28/2015   v1.1.0]
;
;   NOTES:      
;               1)  The routine requires that N ≥ 64, which would correspond to only
;                     32 frequencies in the resulting FFT
;
;  REFERENCES:  
;               1)  Harris, F.J. "On the Use of Windows for Harmonic Analysis with the
;                      Discrete Fourier Transform," Proc. IEEE Vol. 66, No. 1,
;                      pp. 51-83, (1978).
;
;   CREATED:  01/25/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/28/2015   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION find_freq_range_psd_peak,time,field,FREQRA=freqra,FPKMIN=fpkmin,FPKMAX=fpkmax, $
                                  ALPHA=alpha,SYMMETRY=symmetry,SYMM_THRESH=symm_thresh,$
                                  LENGTH=length,OFFSET=offset,OUTPUT=wav_struc

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, sample_rate, fft_power_calc, partition_data
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
min_n          = 64L                         ;;  Minimum # of elements for TIME and FIELD
min_n_str      = STRTRIM(STRING(min_n[0],FORMAT='(I)'),2L)
fftwin         = 2L                          ;;  Logic used for Hanning window in fft_power_calc.pro
sm_wd          = 32L                         ;;  Default smoothing window width for SMOOTH.PRO
;;  Define dummy array of zeros
ndumb          = 1000L
yy1            = REPLICATE(0d0,ndumb[0])
;;  Define allowed number types
;isnum          = [1,2,3,4,5,6,12,13,14,15]
;;  Dummy error messages
noinpt_msg     = 'User must supply dependent and independent data arrays'
badndm_msg     = 'Incorrect input format:  TIME and FIELD must be 1D arrays'
badnel_msg     = 'Incorrect input format:  TIME and FIELD must have the same # of elements'
badtyp_msg     = 'Incorrect input format:  TIME and FIELD must be numeric type arrays'
badinn_msg     = 'Incorrect input format:  TIME and FIELD must have at least '+min_n_str[0]+' elements'
badtim_msg     = 'TIME input must contain at least N finite and unique values'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN BEGIN
  MESSAGE,noinpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check input formats
sztn0          = SIZE(time,/N_DIMENSIONS)
szfn0          = SIZE(field,/N_DIMENSIONS)
;;  Check that both inputs have only one dimension
test           = (sztn0[0] NE 1) OR (szfn0[0] NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,badndm_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check that both inputs have matching # of elements
sztd0          = SIZE(time,/DIMENSIONS)
szfd0          = SIZE(field,/DIMENSIONS)
test           = (sztd0[0] NE szfd0[0])
IF (test[0]) THEN BEGIN
  MESSAGE,badnel_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check that both inputs are numeric
;sztt0          = SIZE(time,/TYPE)
;szft0          = SIZE(field,/TYPE)
;test           = (TOTAL(sztt0[0] EQ isnum) EQ 0) OR (TOTAL(szft0[0] EQ isnum) EQ 0)
;;    --> LBW III  04/28/2015   v1.1.0
test           = (is_a_number(time,/NOMSSG) EQ 0) OR (is_a_number(field,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,badtyp_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check that N ≥ MIN_N
test           = (sztd0[0] LE min_n[0]) OR ((TOTAL(FINITE(time),/NAN) LE min_n[0]) OR $
                 (TOTAL(FINITE(field),/NAN) LE min_n[0]))
IF (test[0]) THEN BEGIN
  MESSAGE,badinn_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check that TIME has at least MIN_N finite and unique values
unq            = UNIQ(time,SORT(time))
n_unq          = N_ELEMENTS(unq)
test           = (n_unq[0] LE min_n[0])
IF (test[0]) THEN BEGIN
  MESSAGE,badtim_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
nt             = sztd0[0]                 ;;  N = # of elements in each array
sp             = SORT(REFORM(time))       ;;  Make sure times in ascending order
tts            = (REFORM(time))[sp]       ;;  [N]-Element array of timestamps [s]
vec            = (REFORM(field))[sp]      ;;  [N]-Element array of vector component values [units]
;;  Determine sample rate [samples per second = sps]
dts            = ABS(SHIFT(tts,-1L) - tts)
dt_thrsh       = MEAN(dts[10L:20L],/NAN)  ;;  Avg. ∆t for TIME --> use as threshold for sample rate calculation
srate_str      = sample_rate(tts,GAP_THRESH=dt_thrsh[0],OUT_MED_AVG=medavg)
test           = (N_ELEMENTS(srate_str) EQ 1) OR (TOTAL(FINITE(medavg)) NE 2)
IF (test[0]) THEN BEGIN
  test           = (srate_str[0] EQ 0) OR (FINITE(srate_str[0]) EQ 0)
  IF (test[0]) THEN BEGIN
    ;;  No finite or good values in TIME
    MESSAGE,badtim_msg+': 2',/INFORMATIONAL,/CONTINUE
    RETURN,0b
  ENDIF
ENDIF
;;  Check that the median and average sample rates are within 10% of each other
;;    TRUE  --> use average
;;    FALSE --> use median
ratio          = ABS(1d0 - medavg[1]/medavg[0])
test           = (ratio[0] LE 1d-1)
srate          = medavg[test[0]]          ;;  Sample rate [sps]
fnyquist       = srate[0]/2d0             ;;  Nyquist frequency [Hz]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check FREQRA
test           = (N_ELEMENTS(freqra) NE 2)
IF (test[0]) THEN BEGIN
  ;;  FREQRA not set correctly --> use default
  fran           = [0d0,fnyquist[0]]
ENDIF ELSE BEGIN
  ;;  FREQRA has 2 elements --> check format
;  test           = (TOTAL(SIZE(freqra,/TYPE) EQ isnum) EQ 0) OR (freqra[1] EQ freqra[0])
;;    --> LBW III  04/28/2015   v1.1.0
  test           = (is_a_number(freqra,/NOMSSG) EQ 0) OR (freqra[1] EQ freqra[0])
  IF (test[0]) THEN BEGIN
    ;;  FREQRA not numeric or (FREQRA[1] = FREQRA[0]) --> use default
    fran           = [0d0,fnyquist[0]]
  ENDIF ELSE BEGIN
    ;;  FREQRA is numeric --> use FREQRA
    fran           = (freqra)[SORT(freqra)]
  ENDELSE
ENDELSE
;;  Check FPKMIN
fr_pk          = fran     ;;  Set initially to FRAN
;test           = (N_ELEMENTS(fpkmin) EQ 1) AND (TOTAL(SIZE(fpkmin,/TYPE) EQ isnum) EQ 1)
;;    --> LBW III  04/28/2015   v1.1.0
test           = (N_ELEMENTS(fpkmin) EQ 1) AND is_a_number(fpkmin,/NOMSSG)
IF (test[0]) THEN fr_pk[0] = fpkmin[0] > 0
;;  Check FPKMAX
;test           = (N_ELEMENTS(fpkmax) EQ 1) AND (TOTAL(SIZE(fpkmax,/TYPE) EQ isnum) EQ 1)
;;    --> LBW III  04/28/2015   v1.1.0
test           = (N_ELEMENTS(fpkmax) EQ 1) AND is_a_number(fpkmax,/NOMSSG)
IF (test[0]) THEN fr_pk[1] = fpkmax[0] > (fr_pk[0])
;;  Make sure FR_PK has unique elements
test           = (fr_pk[1] EQ fr_pk[0])
IF (test[0]) THEN fr_pk *= [8d-1,12d-1]  ;;  Expand by 20%
;;  Check ALPHA
;test           = (N_ELEMENTS(alpha) EQ 1) AND (TOTAL(SIZE(alpha,/TYPE) EQ isnum) EQ 1)
;;    --> LBW III  04/28/2015   v1.1.0
test           = (N_ELEMENTS(alpha) EQ 1) AND is_a_number(alpha,/NOMSSG)
IF (test[0]) THEN frac_pkpc = (alpha[0] < 99d-2) > 5d-2 ELSE frac_pkpc = 5d-1
;;  Check SYMMETRY
test           = (N_ELEMENTS(symmetry) EQ 1) AND KEYWORD_SET(symmetry)
IF (test[0]) THEN symmetrize = 1 ELSE symmetrize = 0
;;  Check SYMM_THRESH
;test           = (N_ELEMENTS(symm_thresh) GE 1) AND (TOTAL(SIZE(symm_thresh,/TYPE) EQ isnum) EQ 1)
;;    --> LBW III  04/28/2015   v1.1.0
test           = (N_ELEMENTS(symm_thresh) GE 1) AND (is_a_number(symm_thresh,/NOMSSG) EQ 1)
IF (test[0]) THEN s_thrsh = symm_thresh[0] > 1.5 ELSE s_thrsh = 2.0
;;  Check LENGTH
test           = (N_ELEMENTS(length) EQ 1) AND is_a_number(length,/NOMSSG)
IF (test[0]) THEN nlen = (length[0] < (nt[0]/4L)) ELSE nlen = 4L
nlen           = nlen[0] > 4L             ;;  Make sure LENGTH is at least 4
;;  Check OFFSET
test           = (N_ELEMENTS(offset) EQ 1) AND is_a_number(offset,/NOMSSG)
IF (test[0]) THEN nshft = (offset[0] < (nt[0]/4L)) ELSE nshft = 4L
nshft          = nshft[0] > nlen[0]       ;;  Make sure OFFSET is at least LENGTH
;;----------------------------------------------------------------------------------------
;;  Calculate power spectrum [use Hanning window]
;;----------------------------------------------------------------------------------------
powspec_str    = fft_power_calc(tts,vec,/READ_WIN,IWINDW=fftwin[0])
fft_freqs      = powspec_str.FREQ         ;;  Frequencies [Hz] associated with power spectrum
fft_power      = powspec_str.POWER_A      ;;  Power spectral density [units^2 Hz^(-1)]
nf             = N_ELEMENTS(fft_freqs)    ;;  # of frequency bins in FFT
;;  Redefine FRAN if FRAN[0] = 0
IF (fran[0] EQ 0) THEN fran[0] = fft_freqs[1]
IF (nf LT 160L) THEN wd = 4L ELSE wd = (nf[0]/sm_wd[0]) < 64L
;;  Smooth the power spectrum
sm_pow         = SMOOTH(fft_power,wd,/NAN)
;;  Define range of positive definite frequencies [Hz]
fmnmx          = [MIN(fft_freqs[1:*],/NAN),MAX(fft_freqs[1:*],/NAN)]
;;----------------------------------------------------------------------------------------
;;  Find envelope around power spectrum (i.e., high/low values for each frequency bin range)
;;
;;    Note:  return value has [NN, MM, LL]-Elements where
;;             NN = # of elements in LENGTH
;;             MM = # of divisions = K/NN, where K = # of points in input array
;;             LL = 2 => 0 = X, 1 = Y
;;----------------------------------------------------------------------------------------
;;    --> LBW III  04/28/2015   v1.1.0
;nlen           = 4L  ;;  --> LENGTH
;nshft          = 4L  ;;  --> Shift
envelope_x     = partition_data(fft_freqs,nlen[0],nshft[0],YY=fft_power)
n_envel        = N_ELEMENTS(envelope_x[0,*,0])
env_xx         = REPLICATE(d,n_envel[0])
env_yy         = REPLICATE(d,n_envel[0],2L)
FOR i=0L, n_envel[0] - 1L DO BEGIN
  tempx = REFORM(envelope_x[*,i,0])
  tempy = REFORM(envelope_x[*,i,1])
  env_xx[i]   = MEAN(tempx,/NAN)    ;;  Avg. frequency [Hz] of binned range
  env_yy[i,0] = MIN(tempy,/NAN)     ;;  Lower bound on PSD [units^2 Hz^(-1)] in binned range
  env_yy[i,1] = MAX(tempy,/NAN)     ;;  Upper bound on PSD [units^2 Hz^(-1)] in binned range
ENDFOR
;;  Smooth envelope
env_yy_sm      = env_yy
env_yy_sm[*,0] = SMOOTH(env_yy[*,0],3L,/NAN)
env_yy_sm[*,1] = SMOOTH(env_yy[*,1],3L,/NAN)
;;  Find good envelope frequencies [Hz]
good_env       = WHERE(env_xx GT fran[0] AND env_xx LE fran[1],gd_env)       ;;  frequencies between FRAN
IF (gd_env GT 0) THEN good_env = LINDGEN(n_envel)                            ;;  Use all elements if bad FRAN definition
;;  Find maximum of PSD from envelope
good_env_pk    = WHERE(env_xx GT fr_pk[0] AND env_xx LE fr_pk[1],gd_env_pk)  ;;  frequencies in allowable range for spectral peak
IF (gd_env_pk GT 0) THEN BEGIN
  max_env_pow        = MAX(env_yy_sm[good_env_pk,1],ind_env_mxpow0,/NAN)
  ind_env_mxpow      = good_env_pk[ind_env_mxpow0[0]]
ENDIF ELSE BEGIN
  ;;  Bad frequency range definition --> use all powers
  max_env_pow        = MAX(env_yy_sm[*,1],ind_env_mxpow,/NAN)
ENDELSE
;;  Frequency [Hz] at PSD envelope peak
f_at_env_mxpow = env_xx[ind_env_mxpow[0]]
;;  Define dummy array of frequencies
xx1            = DINDGEN(ndumb[0])*(fmnmx[1] - fmnmx[0])/(ndumb[0] - 1L) + fmnmx[0]
;;  Define fraction of PSD envelope peak [units^2 Hz^(-1)] to consider when finding frequency range
frac_env_pk    = frac_pkpc[0]*max_env_pow[0]
yy1b_env       = REPLICATE(frac_env_pk[0],ndumb[0])
;;  Find where P(f) = å P_pk in frequency range
xx2            = env_xx[good_env]
yy2            = env_yy_sm[good_env,1]
find_intersect_2_curves,xx1,yy1b_env,xx2,yy2,XY=xy_int_frac_env_pk
;;  Use Max(dP/df) and Min(dP/df) as well to aid in location of frequency peak
dPdf_env_l     = DERIV(env_xx*1d-3,env_yy_sm[*,0])
dPdf_env_h     = DERIV(env_xx*1d-3,env_yy_sm[*,1])
dPdf_env_l_sm  = SMOOTH(dPdf_env_l,3L,/NAN)
dPdf_env_h_sm  = SMOOTH(dPdf_env_h,3L,/NAN)
min_dpdf_env_l = MIN(dPdf_env_l_sm,indmn_env_l,/NAN)
max_dpdf_env_l = MAX(dPdf_env_l_sm,indmx_env_l,/NAN)
min_dpdf_env_h = MIN(dPdf_env_h_sm,indmn_env_h,/NAN)
max_dpdf_env_h = MAX(dPdf_env_h_sm,indmx_env_h,/NAN)
indx_env_l     = ([indmn_env_l[0],indmx_env_l[0]])[SORT([indmn_env_l[0],indmx_env_l[0]])]
indx_env_h     = ([indmn_env_h[0],indmx_env_h[0]])[SORT([indmn_env_h[0],indmx_env_h[0]])]
indx_env       = [MIN([indx_env_l,indx_env_h],/NAN),MAX([indx_env_l,indx_env_h],/NAN)]
g_fra_env_mnmx = env_xx[indx_env]     ;;  Range of frequencies [Hz] for peak
;;  Find where dP/df = å (dP/df)_pk in frequency range
yy1_env_l_mn   = REPLICATE(frac_pkpc[0]*min_dpdf_env_l[0],ndumb[0])
yy1_env_l_mx   = REPLICATE(frac_pkpc[0]*max_dpdf_env_l[0],ndumb[0])
yy1_env_h_mn   = REPLICATE(frac_pkpc[0]*min_dpdf_env_h[0],ndumb[0])
yy1_env_h_mx   = REPLICATE(frac_pkpc[0]*max_dpdf_env_h[0],ndumb[0])
xx2            = env_xx
yy2            = dPdf_env_l_sm
find_intersect_2_curves,xx1,yy1_env_l_mn,xx2,yy2,XY=xyint_frac_env_l_mn
find_intersect_2_curves,xx1,yy1_env_l_mx,xx2,yy2,XY=xyint_frac_env_l_mx
yy2            = dPdf_env_h_sm
find_intersect_2_curves,xx1,yy1_env_h_mn,xx2,yy2,XY=xyint_frac_env_h_mn
find_intersect_2_curves,xx1,yy1_env_h_mx,xx2,yy2,XY=xyint_frac_env_h_mx
;;  Should only be 2 intercepts for each
temp_frq_l_mn  = REFORM(xyint_frac_env_l_mn[0,*])
temp_frq_l_mx  = REFORM(xyint_frac_env_l_mx[0,*])
temp_frq_h_mn  = REFORM(xyint_frac_env_h_mn[0,*])
temp_frq_h_mx  = REFORM(xyint_frac_env_h_mx[0,*])
temp_fra_l     = [MIN([temp_frq_l_mn,temp_frq_l_mx],/NAN),MAX([temp_frq_l_mn,temp_frq_l_mx],/NAN)]
temp_fra_h     = [MIN([temp_frq_h_mn,temp_frq_h_mx],/NAN),MAX([temp_frq_h_mn,temp_frq_h_mx],/NAN)]
;;  Limit to within range defined by FRAN
temp_fra_l[0]  = temp_fra_l[0] > (fr_pk[0] > fran[0])
temp_fra_l[1]  = temp_fra_l[1] < (fr_pk[1] < fran[1])
temp_fra_h[0]  = temp_fra_h[0] > (fr_pk[0] > fran[0])
temp_fra_h[1]  = temp_fra_h[1] < (fr_pk[1] < fran[1])
g_fra_env_dpdf = [MIN([temp_fra_l,temp_fra_h],/NAN),MAX([temp_fra_l,temp_fra_h],/NAN)]     ;;  Range of frequencies [Hz] for peak
;;----------------------------------------------------------------------------------------
;;  Find spectral peak and associated frequency range
;;----------------------------------------------------------------------------------------
;;  Find maximum of power
good           = WHERE(fft_freqs GT fran[0] AND fft_freqs LE fran[1],gd)       ;;  frequencies between FRAN
IF (gd GT 0) THEN good = LINDGEN(nf)  ;;  Use all elements if bad FRAN definition
good_pk        = WHERE(fft_freqs GT fr_pk[0] AND fft_freqs LE fr_pk[1],gd_pk)  ;;  frequencies in allowable range for spectral peak
IF (gd_pk GT 0) THEN BEGIN
  max_pow        = MAX(sm_pow[good_pk],ind_mxpow0,/NAN)
  ind_mxpow      = good_pk[ind_mxpow0[0]]
ENDIF ELSE BEGIN
  ;;  Bad frequency range definition --> use all powers
  max_pow        = MAX(sm_pow,ind_mxpow,/NAN)
ENDELSE
;;  Frequency [Hz] at spectral peak power
f_at_mxpow     = fft_freqs[ind_mxpow[0]]
;;  Define fraction of peak [units^2 Hz^(-1)] to consider when finding frequency range
frac_pk        = frac_pkpc[0]*max_pow[0]
yy1b           = REPLICATE(frac_pk[0],ndumb[0])
;;  Find where P(f) = å P_pk in frequency range
xx2            = fft_freqs[good]
yy2            = sm_pow[good]
find_intersect_2_curves,xx1,yy1b,xx2,yy2,XY=xy_int_frac_pk
;;  Define associated frequency peak range
;;    Limit to within range defined by FRAN
frq_frac_pk_ra = REFORM(xy_int_frac_pk[0,*])
t_fra_frpk     = [MIN(frq_frac_pk_ra,/NAN),MAX(frq_frac_pk_ra,/NAN)]
t_fra_frpk[0]  = t_fra_frpk[0] > (fr_pk[0] > fran[0])
t_fra_frpk[1]  = t_fra_frpk[1] < (fr_pk[1] < fran[1])

good_fra_env   = t_fra_frpk     ;;  Range of frequencies [Hz] for peak
;;----------------------------------------------------------------------------------------
;;  Compare to range from envelope
;;----------------------------------------------------------------------------------------
fran_pk_f      = t_fra_frpk
fran_pk_f[0]   = (fran_pk_f[0] < g_fra_env_dpdf[0])
fran_pk_f[1]   = (fran_pk_f[1] > g_fra_env_dpdf[1])
;;  Find associated indices with frequency array
gind_fra_old   = VALUE_LOCATE(fft_freqs,fran_pk_f)
gind_fra       = gind_fra_old
;;----------------------------------------------------------------------------------------
;;  Make sure encloses peak
;;----------------------------------------------------------------------------------------
test           = (gind_fra[0] LT ind_mxpow[0]) AND (gind_fra[1] GT ind_mxpow[0])
i_posi         = [(TOTAL(gind_fra GE ind_mxpow[0]) EQ 2),test[0],$
                  (TOTAL(gind_fra LE ind_mxpow[0]) EQ 2)]
IF (test EQ 0) THEN BEGIN
  good_ipos = WHERE(i_posi,gdipos)
  CASE good_ipos[0] OF
    0L   : BEGIN
      ;;  Both are > index of peak
      ;;    --> Shift lower bound
      gind_fra[0] = (ind_mxpow[0] - 1L) > 0L
      If (gind_fra[1] - gind_fra[0] EQ 1) THEN gind_fra[1] += 1L
    END
    1L   :  ;;  Peak is between indices
    2L   : BEGIN
      ;;  Both are < index of peak
      ;;    --> Shift upper bound
      gind_fra[1] = (ind_mxpow[0] + 1L) < (nf[0] - 1L)
      If (gind_fra[1] - gind_fra[0] EQ 1) THEN gind_fra[0] -= 1L
    END
    ELSE : BEGIN
      ;;  Try centering on main peak
      gind_fra = ind_mxpow[0] + [-1L,1L]*2L
      If (gind_fra[0] LT 0) THEN gind_fra += ABS(gind_fra[0])
      If (gind_fra[1] GT (nf[0] - 1L)) THEN gind_fra -= ABS((nf[0] - 1L) - gind_fra[1])
    END
  ENDCASE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define the frequency range of the power spectral peak
;;----------------------------------------------------------------------------------------
test           = (TOTAL(gind_fra EQ gind_fra_old) NE 2L)
;;  Just use the range enclosing power peak
IF (test[0]) THEN fran_pk_f = fft_freqs[gind_fra]
;;----------------------------------------------------------------------------------------
;;  Check if user wants to test the frequency range of the power spectral peak
;;----------------------------------------------------------------------------------------
IF (symmetrize[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  User wishes to check frequency bounds and symmetrize if necessary
  ;;--------------------------------------------------------------------------------------
  ;;  Define log_10 space of frequencies
  franl10_lh     = ALOG10(fran_pk_f)
  fatpkl10_bth   = ALOG10([f_at_mxpow[0],f_at_env_mxpow[0]])
  ;;  Define |∆f| (between peaks and bounds) in log_10 space
  df_l_pk_both   = ABS(franl10_lh[0] - fatpkl10_bth)
  df_h_pk_both   = ABS(franl10_lh[1] - fatpkl10_bth)
  ;;  Define <|∆f|> in log_10 space
  dfl10_lh_avg   = [MEAN(df_l_pk_both,/NAN),MEAN(df_h_pk_both,/NAN)]
  ;;  Define Min and Max of <|∆f|> in log_10 space
  mnx_dfl10      = [MIN(dfl10_lh_avg,ind_mndf,/NAN),MAX(dfl10_lh_avg,ind_mxdf,/NAN)]
  ;;  Define % differences of ratios
  df_lh_pc_rat   = [ABS(1d0 - df_l_pk_both[0]/df_l_pk_both[1]),$
                    ABS(1d0 - df_h_pk_both[0]/df_h_pk_both[1]) ]
  test           = (MAX(df_lh_pc_rat)/MIN(df_lh_pc_rat) GT s_thrsh[0])
  IF (test[0]) THEN BEGIN
    new_fran_l10 = franl10_lh
    ;;------------------------------------------------------------------------------------
    ;;  Test = TRUE --> Symmetrize frequency bounds about mean peak
    ;;------------------------------------------------------------------------------------
    ;;  Define the <∆f> associated with the smaller of the two
    good_dfl10             = MEAN(franl10_lh[ind_mndf] - fatpkl10_bth,/NAN)
    ;;  Adjust "bad" side bound
    new_fran_l10[ind_mxdf] = franl10_lh[ind_mndf] - 2d0*good_dfl10[0]
    new_fran               = 1d1^(new_fran_l10)
  ENDIF ELSE new_fran = fran_pk_f
  test           = (TOTAL(new_fran EQ fran_pk_f) NE 2L)
  ;;  Check if anything changed, otherwise leave frequency range alone
  IF (test[0]) THEN fran_pk_f = new_fran
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define structure containing analysis results (e.g., FFT, envelope of PSD, etc.)
;;----------------------------------------------------------------------------------------
tags           = ['PSD_ENVELOPE_XY','PSD_STRUC','SAMPLE_RATE','FREQ_AT_ENV_MAX_POWER',  $
                  'FREQ_RANGE_ENV_DPDF_MNMX','FREQ_RANGE_ENV_DPDF_PERC_PK',             $
                  'FREQ_AT_SM_PSD_MAX_POWER','FREQ_RANGE_PSD_PERC_PK',                  $
                  'FRAN_PSD_PERC_PK_IND_INITIAL','FRAN_PSD_PERC_PK_IND_FINAL',          $
                  'XY_INT_FRAC_ENV_PK','XYINT_FRAC_ENV_L_MN','XYINT_FRAC_ENV_L_MX',     $
                  'XYINT_FRAC_ENV_H_MN','XYINT_FRAC_ENV_H_MX','XY_INT_FRAC_PK',         $
                  'PSD_ENVELOPE_XX','PSD_ENVELOPE_YY','PSD_ENVELOPE_SM']
wav_struc      = CREATE_STRUCT(tags,envelope_x,powspec_str,srate[0],f_at_env_mxpow[0], $
                               g_fra_env_mnmx,g_fra_env_dpdf,f_at_mxpow[0],            $
                               good_fra_env,gind_fra_old,gind_fra,xy_int_frac_env_pk,  $
                               xyint_frac_env_l_mn,xyint_frac_env_l_mx,                $
                               xyint_frac_env_h_mn,xyint_frac_env_h_mx,xy_int_frac_pk, $
                               env_xx,env_yy,env_yy_sm)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,fran_pk_f
END