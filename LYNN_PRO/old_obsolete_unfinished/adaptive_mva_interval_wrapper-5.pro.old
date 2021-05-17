;*****************************************************************************************
;
;  PROCEDURE:   adaptive_mva_interval_get_def_keywords.pro
;  PURPOSE  :   This routine tests and constrains the interval and subinterval keywords
;                 to prevent code breaking and conflicts/issues.
;
;  CALLED BY:   
;               adaptive_mva_interval_get_sub_inds.pro
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
;               UNIXT          :  [N]-Element [double] array of Unix times defined by
;                                   the calling/wrapping routine
;
;  EXAMPLES:    
;               [calling sequence]
;               adaptive_mva_interval_get_def_keywords, unix [,TRANGE=trange]         $   ;;  Inputs
;                                      [,PRECISION=prec]                              $   ;;  Inputs
;                                      [,LOW_FREQ=low_freq] [,HIGHFREQ=highfreq]      $   ;;  Inputs
;                                      [,NSHIFT=nshift] [,NSUBINT=nsubint]            $   ;;  Inputs
;                                      [,NTWINDS=ntwinds] [,DNWINDS=dnwinds]          $   ;;  Inputs
;                                      [,NTMIN=ntmin] [,NTMAX=ntmax]                  $   ;;  Inputs
;                                      [,N_MIN=n_min] [,N_MAX=n_max] [,N_SUB=n_sub]   $   ;;  Outputs
;                                      [,N_SFT=n_sft] [,N_WIN=n_win] [,D__NW=d__nw]   $   ;;  Outputs
;                                      [,N_INT=n_int] [,GIND_SE=gind_se]              $   ;;  Outputs
;                                      [,FRANGE=frange] [,LOGIC_OUT=logic_out]
;
;  KEYWORDS:    
;               ****************
;               ***  INPUTS  ***
;               ****************
;               TRANGE         :  [2]-Element [double] array specifying the Unix time
;                                   range for which to limit the data in STRUC
;                                   [Default = prompted by get_valid_trange.pro]
;               PRECISION      :  Scalar [long] defining precision of the string output:
;                                   = -5  :  Year only
;                                   = -4  :  Year, month
;                                   = -3  :  Year, month, date
;                                   = -2  :  Year, month, date, hour
;                                   = -1  :  Year, month, date, hour, minute
;                                   = 0   :  Year, month, date, hour, minute, sec
;                                   = >0  :  fractional seconds
;                                   [Default = 0]
;               LOW_FREQ       :  Scalar [numeric] defining the lower frequency bound for
;                                   a bandpass filter to be applied to the entire time
;                                   series in STRUC prior to clipping and performing MVA
;                                   [Default = 0.0]
;               HIGHFREQ       :  Scalar [numeric] defining the upper frequency bound for
;                                   a bandpass filter to be applied to the entire time
;                                   series in STRUC prior to clipping and performing MVA
;                                   [Default = (sample rate)]
;               NSHIFT         :  Scalar [long] defining the index shift for each new
;                                   time window set (i.e., each subinterval) such that
;                                   the following constraint is met:
;                                     ((Nmax + NSUBINT*NSHIFT) MOD Nint) = 0
;                                   where Nmax is the maximum # of time steps in each
;                                   subinterval and Nint is the # of time steps within
;                                   the range defined by TRANGE
;                                   [Default = 1]
;               NSUBINT        :  Scalar [long] defining the number of subintervals that
;                                   each contain NTWINDS time windows
;                                   [Default = 5]
;               NTWINDS        :  Scalar [long] defining the number of time windows to
;                                   use between Nmin and Nmax (i.e., each subinterval)
;                                   before shifting by NSHIFT
;                                   [Default = 4]
;               DNWINDS        :  Scalar [long] defining the integer # of time steps by
;                                   which to increase each time window such that there
;                                   are an integer number of window, NTWINDS, within the
;                                   range between Nmin and Nmax such that:
;                                     N_MAX = N_MIN + (NTWINDS - 1)*DNWINDS
;                                   [Default = 1]
;               NTMIN          :  Scalar [long] defining the minimum integer # of time
;                                   steps to use when defining the time windows within
;                                   each subinterval
;                                   [Default = 7 > (Sr*Co/HIGHFREQ)]
;               NTMAX          :  Scalar [long] defining the maximum integer # of time
;                                   steps to use when defining the time windows within
;                                   each subinterval
;                                   [Default = N_MIN + (NTWINDS - 1)*DNWINDS]
;               CONS_NSHFNMIN  :  If set, routine will force NSHIFT ≥ N_MIN/2
;                                   (idea is to prevent too much overlap)
;                                   [Default = FALSE]
;               MIN_AMP_THRSH  :  Scalar [numeric] defining the minimum vector component
;                                   peak-to-peak amplitude necessary for an interval
;                                   to undergo minimum variance analysis.  The input must
;                                   be positive definite.
;                                   [Default = 0]
;               *****************
;               ***  OUTPUTS  ***
;               *****************
;               TRANGE         :  On output, routine returns the validated unix time
;                                   range as a [2]-element [double] array
;               N_MIN          :  Set to a named variable to return the minimum # of
;                                   time steps in each subinterval
;                                   (output for NTMIN)
;                                   [integer/long]
;               N_MAX          :  Set to a named variable to return the maximum # of
;                                   time steps in each subinterval
;                                   (output for NTMAX)
;                                   [integer/long]
;               N_SUB          :  Set to a named variable to return the # of subintervals
;                                   within the interval defined by TRANGE
;                                   (output for NSUBINT)
;                                   [integer/long]
;               N_SFT          :  Set to a named variable to return the # of time
;                                   steps by which to shift after each subinterval
;                                   (output for NSHIFT)
;                                   [integer/long]
;               N_WIN          :  Set to a named variable to return the # of time
;                                   windows within each subinterval
;                                   (output for NTWINDS)
;                                   [integer/long]
;               D__NW          :  Set to a named variable to return the # of time steps
;                                   between each time window within each subinterval
;                                   (output for DNWINDS)
;                                   [integer/long]
;               N_INT          :  Set to a named variable to return the # of time steps
;                                   within the interval defined by TRANGE
;                                   [integer/long]
;               GIND_SE        :  Set to a named variable to return the start and end
;                                   indices corresponding to the interval defined by
;                                   TRANGE
;                                   [integer/long]
;               FRANGE         :  Set to a named variable to return the frequency [Hz]
;                                   range as a [2]-element [double] array
;               LOGIC_OUT      :  Set to a named variable to return an array of TRUE or
;                                   FALSE values for informational purposes regarding
;                                   whether the user correctly set input keywords.  The
;                                   output indices correspond to the following inputs:
;                                     0  :  LOW_FREQ
;                                     1  :  HIGHFREQ
;                                     2  :  NTMIN
;                                     3  :  NTMAX
;                                     4  :  NSUBINT
;                                     5  :  NSHIFT
;                                     6  :  NTWINDS
;                                     7  :  DNWINDS
;                                   If LOGIC_OUT[j] = TRUE, then the corresponding input
;                                   keyword was set correctly and the routine did not
;                                   need to redefine in order to satisfy the constraints
;                                   defined in the NOTES section below.  The output for
;                                   this keyword is purely informational.
;               MIN_NUM_INT    :  Scalar [long] defining the minimum integer # of time
;                                   steps required in the input interval for performing
;                                   the adaptive interval analysis
;                                   [Default = 50]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/25/2016   v1.0.0]
;             2)  Continued to write routine
;                                                                   [05/26/2016   v1.0.0]
;             3)  Continued to write routine
;                                                                   [05/26/2016   v1.0.0]
;             4)  Continued to write routine
;                                                                   [05/26/2016   v1.0.0]
;             5)  Now included as a subroutine to the main wrapping routine
;                   temp_iterate_mva_over_interval.pro
;                                                                   [05/27/2016   v1.0.0]
;             6)  Finished writing routine and renamed from
;                   temp_get_def_keywords_iterate_mva.pro to
;                   adaptive_mva_interval_get_def_keywords.pro
;                                                                   [05/27/2016   v1.0.0]
;             7)  Changed default N_MIN setting
;                                                                   [05/31/2016   v1.0.1]
;             8)  Added keyword:  CONS_NSHFNMIN
;                                                                   [05/31/2016   v1.1.0]
;             9)  Added keyword:  MIN_AMP_THRSH
;                                                                   [06/02/2016   v1.2.0]
;            10)  Fixed typo in FFT frequency bin calculation
;                                                                   [06/08/2016   v1.2.1]
;            11)  Added keyword:  MIN_NUM_INT
;                                                                   [04/07/2017   v1.2.2]
;
;   NOTES:      
;               1)  We define the following constraints for the subinterval and windows:
;                     a) N_INT ≥ 50
;                     b) N_SUB ≥ 1  &  N_WIN ≥ 1
;                     c) D__NW ≥ 0  &  N_SFT ≥ 0
;                     d) N_MIN ≥ 7
;                     e) N_MIN ≤ N_MAX ≤ N_INT
;                     f) IF ( N_MAX = N_MIN || N_SFT = 0 ) THEN
;                          N_SUB = 1
;                        ENDIF ELSE
;                          IF ( N_WIN = 1 || N_MAX = N_MIN || D__NW = 0 ) THEN
;                            N_SUB = 1 + (N_INT - N_MIN)/N_SFT
;                          ENDIF ELSE
;                            N_SUB = 1 + (N_INT - N_MAX)/N_SFT
;                          ENDELSE
;                        ENDELSE
;                     g) IF ( N_MAX = N_MIN || D__NW = 0 ) THEN
;                          N_WIN = 1
;                        ENDIF ELSE
;                          IF ( N_SUB = 1 || N_MAX = N_MIN || N_SFT = 0 ) THEN
;                            N_WIN = 1 + (N_INT - N_MIN)/D__NW
;                          ENDIF ELSE
;                            N_WIN = 1 + (N_MAX - N_MIN)/D__NW
;                          ENDELSE
;                        ENDELSE
;                     h) N_MAX = N_MIN + (N_WIN - 1)*D__NW
;                     i) N_INT = N_MIN + (N_WIN - 1)*D__NW + (N_SUB - 1)*N_SUB
;                              = N_MAX + (N_SUB - 1)*N_SUB
;
;                   which results in the following possible cases:
;
;                     N_MIN = N_MAX = N_INT
;                     =====================
;                       N_SUB = 1  &  N_WIN = 1
;                       N_SFT = 0  &  D__NW = 0
;
;                     (7 ≤ N_MIN < N_INT)
;                     ===================
;
;                       (N_MIN = N_MAX)  &  (N_SUB ≥ 2) :
;                           N_WIN = 1  &  D__NW = 0
;                           N_SFT = (N_INT - N_MIN)/(N_SUB - 1)
;
;                       (N_MIN < N_MAX < N_INT)  &  (N_SUB ≥ 2)  &  (N_WIN ≥ 2) :
;                           N_SFT = (N_INT - N_MAX)/(N_SUB - 1)
;                           D__NW = (N_MAX - N_MIN)/(N_WIN - 1)
;
;                       ((N_MAX = N_INT)  ||  (N_SUB = 1))  &  (N_WIN ≥ 2) :
;                           N_SFT = 0
;                           D__NW = (N_INT - N_MIN)/(N_WIN - 1)
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/25/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/07/2017   v1.2.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

PRO adaptive_mva_interval_get_def_keywords,unixt,TRANGE=trange,PRECISION=prec,         $   ;;  Inputs
                                            LOW_FREQ=low_freq,HIGHFREQ=highfreq,       $
                                            NSHIFT=nshift,NSUBINT=nsubint,             $
                                            NTWINDS=ntwinds,DNWINDS=dnwinds,           $
                                            NTMIN=ntmin,NTMAX=ntmax,                   $
                                            CONS_NSHFNMIN=cons_nshfnmin,               $
                                            MIN_AMP_THRSH=min_amp_thrsh,               $
                                            N_MIN=n_min,N_MAX=n_max,N_SUB=n_sub,       $   ;;  Outputs
                                            N_SFT=n_sft,N_WIN=n_win,D__NW=d__nw,       $
                                            N_INT=n_int,GIND_SE=gind_se,FRANGE=frange, $
                                            LOGIC_OUT=logic_out,                       $
                                            MIN_NUM_INT=min_num_int

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_min_nint   = 50L
;;  Dummy error messages
no_inpt_msg    = 'User must supply an array of Unix times...'
baddfor_msg    = 'Incorrect input format:  STRUC must be an IDL TPLOT structure'
bad_tra_msg    = 'Could not define proper time range... Using entire data interval...'
nod_tra_msg    = 'No data within user specified TRANGE... Exiting without computation...'
notenpt_msg    = 'Not enough time steps in entire time series.  Must supply at least 100 time steps...'
notenit_msg    = 'Not enough time steps in interval defined by TRANGE.  Must contain at least 50 time steps...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (is_a_number(unixt,/NOMSSG) EQ 0) OR $
                 (N_ELEMENTS(unixt) LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define some parameters
;;----------------------------------------------------------------------------------------
unix           = REFORM(unixt)
n_tot          = N_ELEMENTS(unix)            ;;  Total # of time steps in input
;;  Determine sample rate [sps]
srate          = sample_rate(unix,/AVERAGE,OUT_MED_AVG=medavg)
;;  Define positive FFT frequencies [Hz]
n_fft          = n_tot[0]/2L                 ;;  # of frequency bins in FFT
fft_fbins      = DINDGEN(n_fft[0])*srate[0]/(2L*n_fft[0] - 1L)
;fft_fbins      = DINDGEN(n_fft[0])*srate[0]/(n_fft[0] - 1L)
;;----------------------------------------------------------------------------------------
;;  Define # of time steps in interval
;;----------------------------------------------------------------------------------------
;;  Check TRANGE and PRECISION
tra_struc      = get_valid_trange(TRANGE=trange,PRECISION=prec)
tran           = tra_struc.UNIX_TRANGE
test           = (TOTAL(FINITE(tran)) LT 2)
IF (test[0]) THEN BEGIN
  MESSAGE,bad_tra_msg,/INFORMATIONAL,/CONTINUE
  ;;  Define entire data interval
  tran           = [MIN(unix,/NAN),MAX(unix,/NAN)]
ENDIF
test           = (unix LE tran[1]) AND (unix GE tran[0])
good           = WHERE(test,gd)
IF (gd EQ 0) THEN BEGIN
  ;;  No data between specified time range limits
  MESSAGE,nod_tra_msg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check MIN_NUM_INT
test          = (N_ELEMENTS(min_num_int) GE 1) AND is_a_number(min_num_int,/NOMSSG)
IF (test[0]) THEN min_nint = LONG(min_num_int[0]) > 10 ELSE min_nint = def_min_nint[0]
;;  Define interval parameters
n_int          = gd[0]                       ;;  # of time steps in time interval defined by TRANGE
dt_int         = (tran[1] - tran[0])         ;;  duration [s] of time interval defined by TRANGE
test           = (n_int[0] LT min_nint[0])
;test           = (n_int[0] LT 50)
IF (test[0]) THEN BEGIN
  ;;  Not enough time steps in interval defined by TRANGE
  notenit_msg    = 'Not enough time steps in interval defined by TRANGE.  Must contain at least '+STRTRIM(STRING(min_nint[0],FORMAT='(I)'),2L)+' time steps...'
  MESSAGE,notenit_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Define TRANGE output
trange         = tran
;;  Define GIND_SE output
gind_se        = [MIN(good,/NAN),MAX(good,/NAN)]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check HIGHFREQ
test_hf0       = (N_ELEMENTS(highfreq) EQ 1) AND is_a_number(highfreq,/NOMSSG)
IF (test_hf0[0]) THEN highf = (highfreq[0] < srate[0]) ELSE highf = srate[0]
good_hf        = WHERE(fft_fbins LT highf[0],gd_hf)
test_hf        = (gd_hf[0] GT 3) AND test_hf0[0]          ;;  TRUE --> User set keyword correctly
IF (gd_hf[0] LE 3) THEN BEGIN
  ;;  resort to default in event of negative input
  highf          = srate[0]
  good_hf        = WHERE(fft_fbins LT highf[0],gd_hf)
ENDIF
def_lf_ind     = (MAX(good_hf) - 3L) > 0L
def_lf_upp     = fft_fbins[def_lf_ind[0]]                 ;;  Upper bound on LOW_FREQ in case improperly set
;;  Check LOW_FREQ
test_lf0       = (N_ELEMENTS(low_freq) EQ 1) AND is_a_number(low_freq,/NOMSSG)
IF (test_lf0[0]) THEN lowf = (low_freq[0] < def_lf_upp[0]) ELSE lowf = 0d0
good_lf        = WHERE(fft_fbins GT lowf[0],gd_lf)
test_lf        = (gd_lf[0] GT 3) AND test_lf0[0]          ;;  TRUE --> User set keyword correctly
IF (gd_lf[0] LE 3) THEN BEGIN
  ;;  resort to default in event of negative input
  lowf           = 0d0
  good_lf        = WHERE(fft_fbins GT lowf[0],gd_lf)
ENDIF
;;  Define subinterval time ranges allowed for later
IF (highf[0] GE srate[0]/2d0) THEN uppf = highf[0]/4d0 ELSE uppf = highf[0]
dt_min         = 2.00d0/uppf[0]                           ;;  lower bound --> window width ≥ 200% of shortest periods
;dt_min         = 1.25d0/uppf[0]                           ;;  lower bound --> window width ≥ 125% of shortest periods
IF (lowf[0] EQ 0) THEN BEGIN
  dt_max         = dt_int[0]
ENDIF ELSE BEGIN
  dt_max         = 1d0/lowf[0]
ENDELSE
;;  Define FRANGE output
frange         = [lowf[0],highf[0]]
;;  Check MIN_AMP_THRSH
test_mat       = (N_ELEMENTS(min_amp_thrsh) GE 1) AND is_a_number(min_amp_thrsh,/NOMSSG)
IF (test_mat[0]) THEN minamp = (DOUBLE(ABS(min_amp_thrsh[0])) > 0d0) ELSE minamp = 0d0
;;  Define MIN_AMP_THRSH output
min_amp_thrsh  = minamp[0]
;;----------------------------------------------------------------------------------------
;;  Check subinterval keywords
;;    --> Define initial settings and/or defaults
;;----------------------------------------------------------------------------------------
;;  Check NSUBINT
test_ns        = (N_ELEMENTS(nsubint) EQ 1) AND is_a_number(nsubint,/NOMSSG)
IF (test_ns[0]) THEN test_ns = (LONG(nsubint[0]) GE 1L) AND (LONG(nsubint[0]) LT FLOOR(9d-1*n_int[0]))
IF (test_ns[0]) THEN ns = LONG(nsubint[0]) ELSE ns = 5L
IF (ns[0] EQ 1) THEN sfac = 1L ELSE sfac = (ns[0] - 1L)
;;  Check NSHIFT
test_nshft     = (N_ELEMENTS(nshift) EQ 1) AND is_a_number(nshift,/NOMSSG)
IF (test_nshft[0]) THEN test_nshft = (LONG(nshift[0])*sfac[0] LT FLOOR(75d-1*n_int[0])) AND (LONG(nshift[0]) GE 0L)
IF (test_nshft[0]) THEN nshft = LONG(nshift[0]) ELSE nshft = 1L
;;  Check NTMIN
test_nmin      = (N_ELEMENTS(ntmin) EQ 1) AND is_a_number(ntmin,/NOMSSG)
IF (test_nmin[0]) THEN test_nmin = (LONG(ntmin[0]) GE 7L) AND (LONG(ntmin[0]) LE n_int[0])  ;;  Check constrains --> turn on/off logic accordingly
IF (test_nmin[0]) THEN nf_min = LONG(ntmin[0]) ELSE nf_min = CEIL(srate[0]*dt_min[0]) > 7L
test_nmin      = (nf_min[0] GE CEIL(srate[0]*dt_min[0]))
IF (~test_nmin[0]) THEN nf_min = CEIL(srate[0]*dt_min[0])    ;;  Prevent user from setting N_MIN too small
;;  Check CONS_NSHFNMIN
test_c_nshnmin = KEYWORD_SET(cons_nshfnmin)
IF (test_c_nshnmin[0]) THEN BEGIN
  IF (test_nshft[0]) THEN test_nshft = (nshft[0] GE nf_min[0])
  IF (~test_nshft[0]) THEN BEGIN
    nshft      = (nshft[0] > (nf_min[0]/2L))
;    test_nshft = 1b
  ENDIF
;  IF (~test_nshft[0]) THEN nshft = (nshft[0] > (nf_min[0]/2L))
;  IF (~test_nshft[0]) THEN nshft = (nshft[0] > nf_min[0])
ENDIF
;;  Check NTWINDS
test_nw        = (N_ELEMENTS(ntwinds) EQ 1) AND is_a_number(ntwinds,/NOMSSG)
IF (test_nw[0])  THEN test_nw = (LONG(ntwinds[0]) GE 1L) AND (LONG(ntwinds[0]) LT FLOOR(9d-1*(n_int[0] - nshft[0]*sfac[0])))
IF (test_nw[0])  THEN ntw = LONG(ntwinds[0]) ELSE ntw = 4L
IF (ntw[0] EQ 1) THEN wfac = 1L ELSE wfac = (ntw[0] - 1L)
;;  Check DNWINDS
test_dnw       = (N_ELEMENTS(dnwinds) EQ 1) AND is_a_number(dnwinds,/NOMSSG)
IF (test_dnw[0]) THEN test_dnw = (LONG(dnwinds[0]) GE 0L) AND (LONG(dnwinds[0])*wfac[0] LE FLOOR(n_int[0] - nshft[0]*sfac[0]))
IF (test_dnw[0]) THEN dntw = LONG(dnwinds[0]) ELSE dntw = 1L
;;  Check NTMAX
test_nmax      = (N_ELEMENTS(ntmax) EQ 1) AND is_a_number(ntmax,/NOMSSG)
IF (test_nmax[0]) THEN BEGIN
  IF (test_nmin[0]) THEN BEGIN
    test_nmax = (LONG(ntmin[0]) LE LONG(ntmax[0])) AND (LONG(ntmax[0]) LE n_int[0])
  ENDIF ELSE BEGIN
    test_nmax = (LONG(ntmax[0]) LE n_int[0])
  ENDELSE
ENDIF
IF (test_nmax[0]) THEN nf_max = LONG(ntmax[0]) $
                  ELSE nf_max = (nf_min[0] + (ntw[0] - 1L)*dntw[0]) < n_int[0]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define tests for constraints
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
test_mneqmx    = (nf_min[0] EQ nf_max[0])
test_mxeqni    = (nf_max[0] EQ n_int[0])
test_lev1_a    = (test_mneqmx[0] AND test_mxeqni[0])
test_lev1_b    = (nf_min[0] GE 7L) AND (nf_min[0] LT n_int[0])
test_ieqnxi    = (nf_min[0] LT nf_max[0]) AND (nf_max[0] LT n_int[0])
test_nwge2     = (ntw[0] GE 2L)
test_nsge2     = ( ns[0] GE 2L)
test_wsge2     = ( test_nwge2[0] AND  test_nsge2[0])    ;;  (N_SUB ≥ 2)  &  (N_WIN ≥ 2)
test_case1     = (test_mneqmx[0] AND  test_nsge2[0])    ;;  (N_MIN = N_MAX)  &  (N_SUB ≥ 2)
test_case2     = (test_ieqnxi[0] AND  test_wsge2[0])    ;;  (N_MIN < N_MAX < N_INT)  &  (N_SUB ≥ 2)  &  (N_WIN ≥ 2)
test____03     = (test_mxeqni[0]  OR  (ns[0] EQ 1) )    ;;  (N_MAX = N_INT)  ||  (N_SUB = 1)
test_ns_03     = (test_mxeqni[0] AND  (ns[0] NE 1) )    ;;  (N_MAX = N_INT)  &  (N_SUB ≠ 1)
test_ne_03     = (~test_mxeqni[0] AND (ns[0] EQ 1) )    ;;  (N_MAX ≠ N_INT)  &  (N_SUB = 1)
test_case3     = ( test____03[0] AND  test_nwge2[0])    ;;  ((N_MAX = N_INT)  ||  (N_SUB = 1))  &  (N_WIN ≥ 2)
const_lev1     = WHERE([test_lev1_a[0],test_lev1_b[0]],cst_lv1)
const_lev2     = WHERE([test_case1[0],test_case2[0],test_case3[0]],cst_lv2)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Constrain parameters
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
CASE const_lev1[0] OF
  0L    :  BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  N_MIN = N_MAX = N_INT
    ;;------------------------------------------------------------------------------------
    n_min = nf_min[0]
    n_max = nf_max[0]
    IF (   test_ns[0]) THEN IF (   ns[0] NE 1) THEN test_ns    = 0b  ;;  shut off logic
    IF (test_nshft[0]) THEN IF (nshft[0] NE 0) THEN test_nshft = 0b  ;;  shut off logic
    IF (   test_nw[0]) THEN IF (  ntw[0] NE 1) THEN test_nw    = 0b  ;;  shut off logic
    IF (  test_dnw[0]) THEN IF ( dntw[0] NE 0) THEN test_dnw   = 0b  ;;  shut off logic
    n_sub = 1L
    n_sft = 0L
    n_win = 1L
    d__nw = 0L
  END
  1L    :  BEGIN
    ;;####################################################################################
    ;;  (7 ≤ N_MIN < N_INT)
    ;;####################################################################################
    CASE const_lev2[0] OF
      0L    :  BEGIN
        ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        ;;  (N_MIN = N_MAX)  &  (N_SUB ≥ 2)
        ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        IF (   test_nw[0]) THEN IF (  ntw[0] NE 1) THEN test_nw    = 0b  ;;  shut off logic
        IF (  test_dnw[0]) THEN IF ( dntw[0] NE 0) THEN test_dnw   = 0b  ;;  shut off logic
        n_min = nf_min[0]
        n_max = nf_min[0]
;        IF (test_nshft[0]) THEN BEGIN
;          ;;  User defined N_SFT
        IF (test_nshft[0] OR test_c_nshnmin[0]) THEN BEGIN
          ;;  User defined N_SFT or set CONS_NSHFNMIN keyword
          n_sft = nshft[0]
          IF (test_ns[0]) THEN BEGIN
            ;;  Constrain user defined value (N_SUB)
            upper = 1L + (n_int[0] - n_min[0])/n_sft[0]
            ;;  2 ≤ N_SUB ≤ 1 + (N_INT - N_MIN)/N_SFT
            n_sub = (ns[0] > 2L) < upper[0]
          ENDIF ELSE BEGIN
            ;;  N_SUB = 1 + (N_INT - N_MIN)/N_SFT
            n_sub = FLOOR(1d0 + 1d0*(n_int[0] - n_min[0])/n_sft[0])
          ENDELSE
        ENDIF ELSE BEGIN
          ;;  N_SFT = (N_INT - N_MIN)/(N_SUB - 1)
          n_sub = ns[0]
          n_sft = (n_int[0] - n_min[0])/(n_sub[0] - 1L)
        ENDELSE
        n_win = 1L
        d__nw = 0L
        ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      END
      1L    :  BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  (N_MIN < N_MAX < N_INT)  &  (N_SUB ≥ 2)  &  (N_WIN ≥ 2)
        ;;--------------------------------------------------------------------------------
        n_min = nf_min[0]
        n_max = nf_max[0]
;        IF (test_nshft[0]) THEN BEGIN
;          ;;  User defined N_SFT
        IF (test_nshft[0] OR test_c_nshnmin[0]) THEN BEGIN
          ;;  User defined N_SFT or set CONS_NSHFNMIN keyword
          n_sft = nshft[0]
          IF (test_ns[0]) THEN BEGIN
            ;;  Constrain user defined value (N_SUB)
            upper = 1L + (n_int[0] - n_max[0])/n_sft[0]
            ;;  2 ≤ N_SUB ≤ 1 + (N_INT - N_MAX)/N_SFT
            n_sub = (ns[0] > 2L) < upper[0]
          ENDIF ELSE BEGIN
            ;;  N_SUB = 1 + (N_INT - N_MAX)/N_SFT
            n_sub = FLOOR(1d0 + 1d0*(n_int[0] - n_max[0])/n_sft[0])
          ENDELSE
        ENDIF ELSE BEGIN
          ;;  N_SFT = (N_INT - N_MAX)/(N_SUB - 1)
          n_sub = ns[0]
          n_sft = (n_int[0] - n_max[0])/(n_sub[0] - 1L)
        ENDELSE
        IF (test_dnw[0]) THEN BEGIN
          ;;  User defined D__NW
          d__nw = dntw[0]
          IF (test_nw[0]) THEN BEGIN
            ;;  Constrain user defined value (N_WIN)
            upper = 1L + (n_max[0] - n_min[0])/d__nw[0]
            ;;  2 ≤ N_WIN ≤ 1 + (N_MAX - N_MIN)/D__NW
            n_win = (ntw[0] > 2L) < upper[0]
          ENDIF ELSE BEGIN
            ;;  N_WIN = 1 + (N_MAX - N_MIN)/D__NW
            n_win = FLOOR(1d0 + 1d0*(n_max[0] - n_min[0])/d__nw[0])
          ENDELSE
        ENDIF ELSE BEGIN
          ;;  D__NW = (N_MAX - N_MIN)/(N_WIN - 1)
          n_win = ntw[0]
          d__nw = (n_int[0] - n_max[0])/(n_win[0] - 1L)
        ENDELSE
        ;;--------------------------------------------------------------------------------
        ;;--------------------------------------------------------------------------------
      END
      2L    :  BEGIN
        ;;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;;  ((N_MAX = N_INT)  ||  (N_SUB = 1))  &  (N_WIN ≥ 2)
        ;;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        n_min = nf_min[0]
        n_max = nf_max[0]
        n_sub = 1L
        n_sft = 0L
        IF (test_nshft[0]) THEN IF (nshft[0] NE 0) THEN test_nshft = 0b  ;;  shut off logic
        IF (test_ns_03[0]) THEN BEGIN
          ;;  (N_MAX = N_INT)  &  (N_SUB ≠ 1)
          IF (   test_ns[0]) THEN test_ns    = 0b  ;;  shut off logic (user set incorrectly)
        ENDIF ELSE BEGIN
          IF (test_ne_03[0]) THEN BEGIN
            ;;  (N_MAX ≠ N_INT)  &  (N_SUB = 1)
            IF (test_nmin[0]) THEN test_nmin = 0b  ;;  shut off logic (user set incorrectly)
            IF (test_nmax[0]) THEN test_nmax = 0b  ;;  shut off logic (user set incorrectly)
            n_max = n_int[0]
            n_min = n_max[0]
          ENDIF;; ELSE --> do nothing
               ;;  (N_MAX = N_INT)  &  (N_SUB = 1)
        ENDELSE
        ;;  Check D__NW and N_WIN
        IF (test_dnw[0]) THEN BEGIN
          ;;  User defined D__NW
          d__nw = dntw[0]
          IF (test_nw[0]) THEN BEGIN
            ;;  Constrain user defined value (N_WIN)
            upper = 1L + (n_int[0] - n_min[0])/d__nw[0]
            ;;  2 ≤ N_WIN ≤ 1 + (N_INT - N_MIN)/D__NW
            n_win = (ntw[0] > 2L) < upper[0]
          ENDIF ELSE BEGIN
            ;;  N_WIN = 1 + (N_INT - N_MIN)/D__NW
            n_win = FLOOR(1d0 + 1d0*(n_int[0] - n_min[0])/d__nw[0])
          ENDELSE
        ENDIF ELSE BEGIN
          ;;  User did not define D__NW
          n_win = ntw[0]
          ;;  D__NW = (N_INT - N_MIN)/(N_WIN - 1)
          d__nw = (n_int[0] - n_min[0])/(n_win[0] - 1L)
        ENDELSE
        ;;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ;;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      END
      ELSE  :  BEGIN
        ;;  Something is wrong!!!  -->  Debug
        MESSAGE,'Something is wrong!!!  -->  Debug [Level 2]',/INFORMATIONAL,/CONTINUE
        STOP
      END
    ENDCASE
    ;;####################################################################################
    ;;  (7 ≤ N_MIN < N_INT)
    ;;####################################################################################
  END
  ELSE  :  BEGIN
    ;;  Something is wrong!!!  -->  Debug
    MESSAGE,'Something is wrong!!!  -->  Debug [Level 1]',/INFORMATIONAL,/CONTINUE
    STOP
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Define output for logic [informational]
;;----------------------------------------------------------------------------------------
test_nsub      = test_ns[0] & test_nsft = test_nshft[0] & test_nwin = test_nw[0]
test_d_nw      = test_dnw[0]
logic_out      = [  test_lf[0],  test_hf[0],test_nmin[0],test_nmax[0],test_nsub[0],$
                  test_nsft[0],test_nwin[0],test_d_nw[0]]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END


;*****************************************************************************************
;
;  FUNCTION :   adaptive_mva_interval_get_sub_inds.pro
;  PURPOSE  :   This is a wrapping routine for adaptive_mva_interval_get_def_keywords.pro
;                 and it defines the start/end indices for the MVA subintervals.
;
;  CALLED BY:   
;               adaptive_mva_interval_wrapper.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               adaptive_mva_interval_get_def_keywords.pro
;               fill_range.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               UNIXT          :  [N]-Element [double] array of Unix times defined by
;                                   the calling/wrapping routine
;
;  EXAMPLES:    
;               [calling sequence]
;               struc = adaptive_mva_interval_get_sub_inds( unixt [,TRANGE=trange]      $
;                                     [,PRECISION=prec] [,LOW_FREQ=low_freq]            $
;                                     [,HIGHFREQ=highfreq] [,NSHIFT=nshift]             $
;                                     [,NSUBINT=nsubint] [,NTWINDS=ntwinds]             $
;                                     [,DNWINDS=dnwinds] [,NTMIN=ntmin]                 $
;                                     [,NTMAX=ntmax] )
;
;  KEYWORDS:    
;               ****************
;               ***  INPUTS  ***
;               ****************
;               TRANGE         :  [2]-Element [double] array specifying the Unix time
;                                   range for which to limit the data in STRUC
;                                   [Default = prompted by get_valid_trange.pro]
;               PRECISION      :  Scalar [long] defining precision of the string output:
;                                   = -5  :  Year only
;                                   = -4  :  Year, month
;                                   = -3  :  Year, month, date
;                                   = -2  :  Year, month, date, hour
;                                   = -1  :  Year, month, date, hour, minute
;                                   = 0   :  Year, month, date, hour, minute, sec
;                                   = >0  :  fractional seconds
;                                   [Default = 0]
;               LOW_FREQ       :  Scalar [numeric] defining the lower frequency bound for
;                                   a bandpass filter to be applied to the entire time
;                                   series in STRUC prior to clipping and performing MVA
;                                   [Default = 0.0]
;               HIGHFREQ       :  Scalar [numeric] defining the upper frequency bound for
;                                   a bandpass filter to be applied to the entire time
;                                   series in STRUC prior to clipping and performing MVA
;                                   [Default = (sample rate)]
;               NSHIFT         :  Scalar [long] defining the index shift for each new
;                                   time window set (i.e., each subinterval) such that
;                                   the following constraint is met:
;                                     ((Nmax + NSUBINT*NSHIFT) MOD Nint) = 0
;                                   where Nmax is the maximum # of time steps in each
;                                   subinterval and Nint is the # of time steps within
;                                   the range defined by TRANGE
;                                   [Default = 1]
;               NSUBINT        :  Scalar [long] defining the number of subintervals that
;                                   each contain NTWINDS time windows
;                                   [Default = 5]
;               NTWINDS        :  Scalar [long] defining the number of time windows to
;                                   use between Nmin and Nmax (i.e., each subinterval)
;                                   before shifting by NSHIFT
;                                   [Default = 4]
;               DNWINDS        :  Scalar [long] defining the integer # of time steps by
;                                   which to increase each time window such that there
;                                   are an integer number of window, NTWINDS, within the
;                                   range between Nmin and Nmax such that:
;                                     Nmax = Nmin + (NTWINDS - 1)*DNWINDS
;                                   [Default = (Nmax - Nmin)/(NTWINDS - 1)]
;               NTMIN          :  Scalar [long] defining the minimum integer # of time
;                                   steps to use when defining the time windows within
;                                   each subinterval
;                                   [Default = 7 > (Sr*Co/HIGHFREQ)]
;               NTMAX          :  Scalar [long] defining the maximum integer # of time
;                                   steps to use when defining the time windows within
;                                   each subinterval
;                                   [Default = N_MIN + (NTWINDS - 1)*DNWINDS]
;               CONS_NSHFNMIN  :  If set, routine will force NSHIFT ≥ N_MIN/2
;                                   (idea is to prevent too much overlap)
;                                   [Default = FALSE]
;               MIN_AMP_THRSH  :  Scalar [numeric] defining the minimum vector component
;                                   peak-to-peak amplitude necessary for an interval
;                                   to undergo minimum variance analysis.  The input must
;                                   be positive definite.
;                                   [Default = 0]
;               MIN_NUM_INT    :  Scalar [long] defining the minimum integer # of time
;                                   steps required in the input interval for performing
;                                   the adaptive interval analysis
;                                   [Default = 50]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/26/2016   v1.0.0]
;             2)  Continued to write routine
;                                                                   [05/26/2016   v1.0.0]
;             3)  Continued to write routine
;                                                                   [05/26/2016   v1.0.0]
;             4)  Now included as a subroutine to the main wrapping routine
;                   temp_iterate_mva_over_interval.pro
;                                                                   [05/27/2016   v1.0.0]
;             6)  Finished writing routine and renamed from
;                   temp_get_mva_inds_iterate_mva.pro to
;                   adaptive_mva_interval_get_sub_inds.pro
;                                                                   [05/27/2016   v1.0.0]
;             7)  Changed default N_MIN setting in
;                   adaptive_mva_interval_get_def_keywords.pro
;                                                                   [05/31/2016   v1.0.1]
;             8)  Added keyword:  CONS_NSHFNMIN
;                                                                   [05/31/2016   v1.1.0]
;             9)  Added keyword:  MIN_AMP_THRSH
;                                                                   [06/02/2016   v1.2.0]
;            10)  Now calls fill_range.pro
;                                                                   [06/08/2016   v1.2.1]
;            11)  Added keyword:  MIN_NUM_INT
;                                                                   [04/07/2017   v1.2.2]
;
;   NOTES:      
;               1)  The routine uses the following picture:
;
;        i_s                                   N_INT                                  i_e
;         |<-------------------------------------------------------------------------->|
;              ∂N                                  N_MAX                               
;         |<------->|<---------------------------------------------------------------->|
;                         N_MIN         ∆N
;                   |<-------------->|<---->|                                          |
;                  l_s             U_0,s  U_1,s                                   U_(Nw-1),s
;
;               where the variables are defined as:
;                     l_s   = s * ∂N                     = start index of s-th subinterval
;                     U_w,w = l_s + w * ∆N + (N_MIN - 1) = end " "
;                     i_s   = start index of interval defined by TRANGE keyword
;                     i_e   = end   index of interval defined by TRANGE keyword
;                     [U_(Nw-1),s      - l_s] = (N_MAX - 1)
;                     [U_0,s           - l_s] = (N_MIN - 1)
;                     [U_(Nw-1),(Ns-1) - l_0] = (N_INT - 1)
;
;                     N_INT = # of time steps in interval defined by TRANGE keyword
;                     ∆N    = value of DNWINDS keyword
;                     ∂N    = value of NSHIFT keyword
;                     N_MIN = value of NTMIN keyword
;                     N_MAX = value of NTMAX keyword
;                     Ns    = value of NSUBINT keyword
;                     Nw    = value of NTWINDS keyword
;
;               and we have defined the following constraints:
;                     a) N_INT ≥ 50
;                     b) Ns ≥ 1  &  Nw ≥ 1
;                     c) ∆N ≥ 0  &  ∂N ≥ 0
;                     d) N_MIN ≥ 7
;                     e) N_MIN ≤ N_MAX ≤ N_INT
;                     f) IF ( N_MAX = N_MIN || ∂N = 0 ) THEN
;                          Ns = 1
;                        ENDIF ELSE
;                          IF ( Nw = 1 || N_MAX = N_MIN || ∆N = 0 ) THEN
;                            Ns = 1 + (N_INT - N_MIN)/∂N
;                          ENDIF ELSE
;                            Ns = 1 + (N_INT - N_MAX)/∂N
;                          ENDELSE
;                        ENDELSE
;                     g) IF ( N_MAX = N_MIN || ∆N = 0 ) THEN
;                          Nw = 1
;                        ENDIF ELSE
;                          IF ( Ns = 1 || N_MAX = N_MIN || ∂N = 0 ) THEN
;                            Nw = 1 + (N_INT - N_MIN)/∆N
;                          ENDIF ELSE
;                            Nw = 1 + (N_MAX - N_MIN)/∆N
;                          ENDELSE
;                        ENDELSE
;                     h) N_MAX = N_MIN + (Nw - 1)*∆N
;                     i) N_INT = N_MIN + (Nw - 1)*∆N + (Ns - 1)*∂N
;                              = N_MAX + (Ns - 1)*∂N
;               2)  See NOTES section in adaptive_mva_interval_get_def_keywords.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/26/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/07/2017   v1.2.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION adaptive_mva_interval_get_sub_inds,unixt,TRANGE=trange,PRECISION=prec,        $   ;;  Inputs
                                                  LOW_FREQ=low_freq,HIGHFREQ=highfreq, $
                                                  NSHIFT=nshift,NSUBINT=nsubint,       $
                                                  NTWINDS=ntwinds,DNWINDS=dnwinds,     $
                                                  NTMIN=ntmin,NTMAX=ntmax,             $
                                                  CONS_NSHFNMIN=cons_nshfnmin,         $
                                                  MIN_AMP_THRSH=min_amp_thrsh,         $
                                                  MIN_NUM_INT=min_num_int

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
no_inpt_msg    = 'User must supply an array of Unix times...'
baddfor_msg    = 'Incorrect input format:  STRUC must be an IDL TPLOT structure'
bad_tra_msg    = 'Could not define proper time range... Using entire data interval...'
nod_tra_msg    = 'No data within user specified TRANGE... Exiting without computation...'
notenpt_msg    = 'Not enough time steps in entire time series.  Must supply at least 100 time steps...'
notenit_msg    = 'Not enough time steps in interval defined by TRANGE.  Must contain at least 50 time steps...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (is_a_number(unixt,/NOMSSG) EQ 0) OR $
                 (N_ELEMENTS(unixt) LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define some parameters
;;----------------------------------------------------------------------------------------
unix           = REFORM(unixt)
n_tot          = N_ELEMENTS(unix)            ;;  Total # of time steps in input
;;----------------------------------------------------------------------------------------
;;  Get keyword values
;;----------------------------------------------------------------------------------------
adaptive_mva_interval_get_def_keywords,unix,TRANGE=trange,PRECISION=prec,              $   ;;  Inputs
                                            LOW_FREQ=low_freq,HIGHFREQ=highfreq,       $
                                            NSHIFT=nshift,NSUBINT=nsubint,             $
                                            NTWINDS=ntwinds,DNWINDS=dnwinds,           $
                                            NTMIN=ntmin,NTMAX=ntmax,                   $
                                            CONS_NSHFNMIN=cons_nshfnmin,               $
                                            MIN_AMP_THRSH=min_amp_thrsh,               $
                                            N_MIN=n_min,N_MAX=n_max,N_SUB=n_sub,       $   ;;  Outputs
                                            N_SFT=n_sft,N_WIN=n_win,D__NW=d__nw,       $
                                            N_INT=n_int,GIND_SE=gind_se,FRANGE=frange, $
                                            LOGIC_OUT=logic_out,                       $
                                            MIN_NUM_INT=min_num_int
;;  Make sure valid outputs were returned
test           = (N_ELEMENTS(n_min) EQ 0)   OR (N_ELEMENTS(n_max) EQ 0)  OR $
                 (N_ELEMENTS(n_sub) EQ 0)   OR (N_ELEMENTS(n_sft) EQ 0)  OR $
                 (N_ELEMENTS(n_win) EQ 0)   OR (N_ELEMENTS(d__nw) EQ 0)  OR $
                 (N_ELEMENTS(n_int) EQ 0)                                OR $
                 (N_ELEMENTS(gind_se) LT 2) OR (N_ELEMENTS(frange) LT 2) OR $
                 (N_ELEMENTS(logic_out) LT 8)
IF (test[0]) THEN BEGIN
  ;;  Not enough time steps in entire input time series
  MESSAGE,"Exiting without computation...",/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define start/end indices of intervals
;;----------------------------------------------------------------------------------------
ind_max        = (n_int[0] - 1L)
;;  Start of subintervals
se             = [0L,(n_sub[0] - 1L)*n_sft[0]]
ind_off        = fill_range(se[0],se[1],DIND=n_sft[0])
;ind_off        = LINDGEN(n_sub[0])*n_sft[0]
IF (N_ELEMENTS(ind_off) NE n_sub[0]) THEN STOP      ;;  something is goofy --> debug
;;  Width of time windows within subintervals
se             = [0L,(n_win[0] - 1L)*d__nw[0]] + n_min[0]
wind_width     = fill_range(se[0],se[1],DIND=d__nw[0])
;wind_width     = LINDGEN(n_win[0])*d__nw[0] + n_min[0]
IF (N_ELEMENTS(wind_width) NE n_win[0]) THEN STOP      ;;  something is goofy --> debug
;;  Start/End elements of every window
ind_st         = LONARR(n_sub[0],n_win[0])
ind_en         = LONARR(n_sub[0],n_win[0])
FOR j=0L, n_win[0] - 1L DO BEGIN
  ind_st[*,j] = ind_off > 0L
  ind_en[*,j] = (ind_off + wind_width[j]) < ind_max[0]
  bad         = WHERE((ind_off + wind_width[j]) GT ind_max[0],bd)
  IF (bd[0] GT 1) THEN BEGIN
    ;;  There were multiple intervals that are too long
    bind = bad[1L:(bd[0] - 1L)]
    ;;  Prevent multiple overlaps
    ind_st[bind,j] = -1L
    ind_en[bind,j] = -1L
  ENDIF
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
n_vals         = [n_min[0],n_max[0],n_sub[0],n_sft[0],n_win[0],d__nw[0],n_int[0]]
tags           = ['INDW_START','INDW___END','TW_IND_SE','FREQ_RANGE','N_VALS','TRANGE',$
                  'LOGIC_INFO']
struc          = CREATE_STRUCT(tags,ind_st,ind_en,gind_se,frange,n_vals,trange,logic_out)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END


;+
;*****************************************************************************************
;
;  FUNCTION :   adaptive_mva_interval_wrapper.pro
;  PURPOSE  :   This is the main wrapping routine that performs the adaptive minimum
;                 variance analysis (MVA) on the input time series defined by STRUC and
;                 returns a structure containing all the relevant MVA information like
;                 eigenvalues and eigenvectors for each subinterval analyzed.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               adaptive_mva_interval_get_def_keywords.pro
;               adaptive_mva_interval_get_sub_inds.pro
;
;  CALLS:
;               tplot_struct_format_test.pro
;               t_get_struc_unix.pro
;               sample_rate.pro
;               adaptive_mva_interval_get_sub_inds.pro
;               vector_bandpass.pro
;               lbw_minvar.pro
;               tplot_struct_format_test.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STRUC          :  Scalar [structure] defining a valid TPLOT structure
;                                   the the user wishes to clip (in time) in order to
;                                   examine only data between the limits defined by the
;                                   TRANGE keyword and then perform MVA on subintervals.
;
;                                   The required structure tags for STRUC are:
;                                     X  :  [N]-Element array of Unix times
;                                     Y  :  [N,3]-Element array of 3-vectors
;
;                                   If the TSHIFT tag is present, the routine will assume
;                                   that STRUC.X is seconds from STRUC.TSHIFT[0].
;
;  EXAMPLES:    
;               [calling sequence]
;               mva_out = adaptive_mva_interval_wrapper(struc [,TRANGE=trange]         $
;                                       [,PRECISION=prec] [,LOW_FREQ=low_freq]         $
;                                       [,HIGHFREQ=highfreq] [,NSHIFT=nshift]          $
;                                       [,NSUBINT=nsubint] [,NTWINDS=ntwinds]          $
;                                       [,DNWINDS=dnwinds] [,NTMIN=ntmin]              $
;                                       [,NTMAX=ntmax] )
;
;  KEYWORDS:    
;               TRANGE         :  [2]-Element [double] array specifying the Unix time
;                                   range for which to limit the data in STRUC
;                                   [Default = prompted by get_valid_trange.pro]
;               PRECISION      :  Scalar [long] defining precision of the string output:
;                                   = -5  :  Year only
;                                   = -4  :  Year, month
;                                   = -3  :  Year, month, date
;                                   = -2  :  Year, month, date, hour
;                                   = -1  :  Year, month, date, hour, minute
;                                   = 0   :  Year, month, date, hour, minute, sec
;                                   = >0  :  fractional seconds
;                                   [Default = 0]
;               LOW_FREQ       :  Scalar [numeric] defining the lower frequency bound for
;                                   a bandpass filter to be applied to the entire time
;                                   series in STRUC prior to clipping and performing MVA
;                                   [Default = 0.0]
;               HIGHFREQ       :  Scalar [numeric] defining the upper frequency bound for
;                                   a bandpass filter to be applied to the entire time
;                                   series in STRUC prior to clipping and performing MVA
;                                   [Default = (sample rate)]
;               NSHIFT         :  Scalar [long] defining the index shift for each new
;                                   time window set (i.e., each subinterval) such that
;                                   the following constraint is met:
;                                     ((Nmax + NSUBINT*NSHIFT) MOD Nint) = 0
;                                   where Nmax is the maximum # of time steps in each
;                                   subinterval and Nint is the # of time steps within
;                                   the range defined by TRANGE
;                                   [Default = 1]
;               NSUBINT        :  Scalar [long] defining the number of subintervals that
;                                   each contain NTWINDS time windows
;                                   [Default = 5]
;               NTWINDS        :  Scalar [long] defining the number of time windows to
;                                   use between Nmin and Nmax (i.e., each subinterval)
;                                   before shifting by NSHIFT
;                                   [Default = 4]
;               DNWINDS        :  Scalar [long] defining the integer # of time steps by
;                                   which to increase each time window such that there
;                                   are an integer number of window, NTWINDS, within the
;                                   range between Nmin and Nmax such that:
;                                     Nmax = Nmin + (NTWINDS - 1)*DNWINDS
;                                   [Default = (Nmax - Nmin)/(NTWINDS - 1)]
;               NTMIN          :  Scalar [long] defining the minimum integer # of time
;                                   steps to use when defining the time windows within
;                                   each subinterval
;                                   [Default = 7 > (Sr*Co/HIGHFREQ)]
;               NTMAX          :  Scalar [long] defining the maximum integer # of time
;                                   steps to use when defining the time windows within
;                                   each subinterval
;                                   [Default = N_MIN + (NTWINDS - 1)*DNWINDS]
;               CONS_NSHFNMIN  :  If set, routine will force NSHIFT ≥ N_MIN/2
;                                   (idea is to prevent too much overlap)
;                                   [Default = FALSE]
;               MIN_AMP_THRSH  :  Scalar [numeric] defining the minimum vector component
;                                   peak-to-peak amplitude necessary for an interval
;                                   to undergo minimum variance analysis.  The input must
;                                   be positive definite.
;                                   [Default = 0]
;               MIN_NUM_INT    :  Scalar [long] defining the minimum integer # of time
;                                   steps required in the input interval for performing
;                                   the adaptive interval analysis
;                                   [Default = 50]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/25/2016   v1.0.0]
;             2)  Continued to write routine
;                                                                   [05/25/2016   v1.0.0]
;             3)  Continued to write routine
;                                                                   [05/25/2016   v1.0.0]
;             4)  Continued to write routine
;                                                                   [05/25/2016   v1.0.0]
;             5)  Continued to write routine
;                                                                   [05/26/2016   v1.0.0]
;             6)  Continued to write routine
;                                                                   [05/26/2016   v1.0.0]
;             7)  Continued to write routine
;                                                                   [05/26/2016   v1.0.0]
;             8)  Added/Included the two subroutines to this file
;                                                                   [05/27/2016   v1.0.0]
;             9)  Finished writing routine and renamed from
;                   temp_iterate_mva_over_interval.pro to
;                   adaptive_mva_interval_wrapper.pro
;                                                                   [05/27/2016   v1.0.0]
;            10)  Changed default N_MIN setting in
;                   adaptive_mva_interval_get_def_keywords.pro
;                                                                   [05/31/2016   v1.0.1]
;            11)  Added keyword:  CONS_NSHFNMIN
;                                                                   [05/31/2016   v1.1.0]
;            12)  Added keyword:  MIN_AMP_THRSH
;                                                                   [06/02/2016   v1.2.0]
;            13)  Cleaned up and altered dependent subroutines
;                                                                   [06/08/2016   v1.2.1]
;            14)  Added keyword:  MIN_NUM_INT and
;                 now calls t_get_struc_unix.pro
;                                                                   [04/07/2017   v1.2.2]
;
;   NOTES:      
;               0)  ***  STILL TESTING  ***
;               1)  General notes for TPLOT structures:
;                       The minimum required structure tags for a TPLOT structure are
;                       as follows:
;                         X  :  [N]-Element array of Unix times
;                         Y  :  [N,?]-Element array of data, where ? can be
;                                 up to two additional dimensions
;                                 [e.g., pitch-angle and energy bins]
;                       additional potential tags are:
;                         V  :  [N,E]-Element array of Y-Axis values
;                                 [e.g., energy bin values]
;                       or in the special case of particle data:
;                         V1 :  [N,E]-Element array of energy bin values
;                         V2 :  [N,A]-Element array of pitch-angle bins
;                       If V1 AND V2 are present, then Y must be an [N,E,A]-element
;                       array.  If only V is present, then Y must be an [N,E]-element
;                       array, where E is either the 1st dimension of V [if 1D array]
;                       or the 2nd dimension of V [if 2D array].
;
;                       If the TSHIFT tag is present, the routine will assume
;                       that NEW_T is a Unix time and STRUC.X is seconds from
;                       STRUC.TSHIFT[0].
;               2)  For details of interval definitions, see NOTES section in
;                     adaptive_mva_interval_get_sub_inds.pro
;                     adaptive_mva_interval_get_def_keywords.pro
;
;  REFERENCES:  
;               1)  G. Paschmann and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                     Data," ISSI Scientific Report, Noordwijk, The Netherlands.,
;                     Int. Space Sci. Inst., 1998.
;               2)  J.C. Samson and J.V. Olson, "Some Comments on the Descriptions of
;                      the Polarization States of Waves," Geophys. J. Astr. Soc. 61,
;                      pp. 115-129, 1980.
;               3)  J.D. Means, "Use of the Three-Dimensional Covariance Matrix in
;                      Analyzing the Polarization Properties of Plane Waves,"
;                      J. Geophys. Res. 77(28), pg 5551-5559, 1972.
;               4)  H. Kawano and T. Higuchi "The bootstrap method in space physics:
;                     Error estimation for the minimum variance analysis," Geophys.
;                     Res. Lett. 22(3), pp. 307-310, 1995.
;               5)  A.V. Khrabrov and B.U.Ö Sonnerup "Error estimates for minimum
;                     variance analysis," J. Geophys. Res. 103(A4), pp. 6641-6651,
;                     1998.
;
;   CREATED:  05/24/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/07/2017   v1.2.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION adaptive_mva_interval_wrapper,struc,TRANGE=trange,PRECISION=prec,            $
                                             LOW_FREQ=low_freq,HIGHFREQ=highfreq,     $
                                             NSHIFT=nshift,NSUBINT=nsubint,           $
                                             NTWINDS=ntwinds,DNWINDS=dnwinds,         $
                                             NTMIN=ntmin,NTMAX=ntmax,                 $
                                             CONS_NSHFNMIN=cons_nshfnmin,             $
                                             MIN_AMP_THRSH=min_amp_thrsh,             $
                                             MIN_NUM_INT=min_num_int

;;****************************************************************************************
ex_start = SYSTIME(1)
;;****************************************************************************************
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
no_inpt_msg    = 'User must supply an IDL structure...'
baddfor_msg    = 'Incorrect input format:  STRUC must be an IDL TPLOT structure'
bad_tra_msg    = 'Could not define proper time range... Using entire data interval...'
nod_tra_msg    = 'No data within user specified TRANGE... Exiting without computation...'
notenpt_msg    = 'Not enough time steps in entire time series.  Must supply at least 100 time steps...'
notenit_msg    = 'Not enough time steps in interval defined by TRANGE.  Must contain at least 50 time steps...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (SIZE(struc,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check if TPLOT structure
test           = tplot_struct_format_test(struc,/YVECT,/NOMSSG)
IF (test[0] EQ 0) THEN BEGIN
  MESSAGE,baddfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define some parameters
;;----------------------------------------------------------------------------------------
;time           = struc.X                     ;;  [N]-Element array of Unix times
;t_offset       = struct_value(struc,'TSHIFT',DEFAULT=0d0)
;unix           = time + t_offset[0]
;n_tot          = N_ELEMENTS(struc.X)         ;;  Total # of time steps in input
unix           = t_get_struc_unix(struc,TSHFT_ON=tshft_on)
n_tot          = N_ELEMENTS(unix)         ;;  Total # of time steps in input
test           = (n_tot[0] LT 100)
IF (test[0]) THEN BEGIN
  ;;  Not enough time steps in entire input time series
  MESSAGE,notenpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Determine sample rate [sps]
srate          = sample_rate(unix,/AVERAGE,OUT_MED_AVG=medavg)
;;----------------------------------------------------------------------------------------
;;  Get MVA intervals and other parameters
;;----------------------------------------------------------------------------------------
mva_struc      = adaptive_mva_interval_get_sub_inds(unix,TRANGE=trange,PRECISION=prec,   $   ;;  Inputs
                                                    LOW_FREQ=low_freq,HIGHFREQ=highfreq, $
                                                    NSHIFT=nshift,NSUBINT=nsubint,       $
                                                    NTWINDS=ntwinds,DNWINDS=dnwinds,     $
                                                    NTMIN=ntmin,NTMAX=ntmax,             $
                                                    CONS_NSHFNMIN=cons_nshfnmin,         $
                                                    MIN_AMP_THRSH=min_amp_thrsh,         $
                                                    MIN_NUM_INT=min_num_int              )
;;  Make sure valid outputs were returned
test           = (SIZE(mva_struc,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  ;;  Not enough time steps in entire input time series
  MESSAGE,"Subroutine failure:  Exiting without computation...",/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
;;  Define start/end indices of subintervals
ind_st         = mva_struc.INDW_START
ind_en         = mva_struc.INDW___END
;;  Define start/end indices of time interval defined by TRANGE
gind_se        = mva_struc.TW_IND_SE
;;  Define Fourier bandpass frequency range [Hz]
freq_ran       = mva_struc.FREQ_RANGE
;;  Define relevant parameters used to construct subintervals
n_vals         = mva_struc.N_VALS
;;  Define Unix time range
tran           = mva_struc.TRANGE
;;  Define logic information (TRUE/FALSE informing user of status of keyword settings)
logic_out      = mva_struc.LOGIC_INFO
;;  Define the minimum vector component pk-pk amplitude
minamp         = min_amp_thrsh[0]
;;----------------------------------------------------------------------------------------
;;  Perform simple box Fourier bandpass
;;    --> use entire time series to reduce edge effects and leakage
;;----------------------------------------------------------------------------------------
vec__raw       = struc.Y
vec_filt       = vector_bandpass(vec__raw,srate[0],freq_ran[0],freq_ran[1],/MIDF)
;;  Clean up (in case input arrays are very large)
dumb           = TEMPORARY(vec__raw)
;;----------------------------------------------------------------------------------------
;;  Define filtered data interval
;;----------------------------------------------------------------------------------------
vec_fint       = REFORM(vec_filt[gind_se[0]:gind_se[1],*])
;;----------------------------------------------------------------------------------------
;;  Perform MVA
;;----------------------------------------------------------------------------------------
n_sub          = N_ELEMENTS(REFORM(ind_st[*,0]))    ;;  # of different subintervals
n_win          = N_ELEMENTS(REFORM(ind_st[0,*]))    ;;  # of time windows within each subinterval
dumb_win1      = REPLICATE(d,n_win[0])
dumb_win3      = REPLICATE(d,n_win[0],3)
min_eigvals    = REPLICATE(d,n_sub[0],n_win[0])     ;;  Array for Min.   Var. eigenvalue
mid_eigvals    = REPLICATE(d,n_sub[0],n_win[0])     ;;  Array for Inter. Var. eigenvalue
max_eigvals    = REPLICATE(d,n_sub[0],n_win[0])     ;;  Array for Max.   Var. eigenvalue
min_eigvecs    = REPLICATE(d,n_sub[0],n_win[0],3L)  ;;  Array for Min.   Var. eigenvector
mid_eigvecs    = REPLICATE(d,n_sub[0],n_win[0],3L)  ;;  Array for Inter. Var. eigenvector
max_eigvecs    = REPLICATE(d,n_sub[0],n_win[0],3L)  ;;  Array for Max.   Var. eigenvector
;;  Keep only unique ranges
;;    --> Define the time window indices that contain the best MVA results
best_wind      = REPLICATE(-1L,n_sub[0])
FOR s=0L, n_sub[0] - 1L DO BEGIN
  ;;  Reset dummy variables
  dumb_mnval = dumb_win1                            ;;  Dummy array for Min.   Var. eigenvalue
  dumb_mdval = dumb_win1                            ;;  Dummy array for Inter. Var. eigenvalue
  dumb_mxval = dumb_win1                            ;;  Dummy array for Max.   Var. eigenvalue
  dumb_mnvec = dumb_win3                            ;;  Dummy array for Min.   Var. eigenvector
  dumb_mdvec = dumb_win3                            ;;  Dummy array for Inter. Var. eigenvector
  dumb_mxvec = dumb_win3                            ;;  Dummy array for Max.   Var. eigenvector
  ;;  Define start/end indices
  st         = REFORM(ind_st[s,*])
  en         = REFORM(ind_en[s,*])
  FOR w=0L, n_win[0] - 1L DO BEGIN
    se        = [st[w],en[w]]
    test      = (TOTAL(se LT 0) GT 0)               ;;  Check for negative indices
    IF (test[0]) THEN CONTINUE                      ;;  Jump to next iteration
    t_vec     = REFORM(vec_fint[se[0]:se[1],*])
    ;;  First check amplitude
    pkpk_x    = DOUBLE(ABS(MAX(t_vec[*,0],/NAN) - MIN(t_vec[*,0],/NAN)))
    pkpk_y    = DOUBLE(ABS(MAX(t_vec[*,1],/NAN) - MIN(t_vec[*,1],/NAN)))
    pkpk_z    = DOUBLE(ABS(MAX(t_vec[*,2],/NAN) - MIN(t_vec[*,2],/NAN)))
    test      = (pkpk_x[0] LE minamp[0]) AND (pkpk_y[0] LE minamp[0]) AND (pkpk_z[0] LE minamp[0])
    IF (test[0]) THEN CONTINUE                      ;;  Jump to next iteration
    eigvecs   = lbw_minvar(t_vec[*,0],t_vec[*,1],t_vec[*,2],EIG_VALS=eigvals)
    test      = (N_ELEMENTS(eigvecs) LT 9)
    IF (test[0]) THEN CONTINUE                      ;;  Jump to next iteration
    ;;  Fill dummy arrays
    dumb_mnval[w]   = eigvals[0]
    dumb_mdval[w]   = eigvals[1]
    dumb_mxval[w]   = eigvals[2]
    dumb_mnvec[w,*] = REFORM(eigvecs[*,0])
    dumb_mdvec[w,*] = REFORM(eigvecs[*,1])
    dumb_mxvec[w,*] = REFORM(eigvecs[*,2])
  ENDFOR
  ;;  Fill eigenvalue and eigenvector arrays
  min_eigvals[s,*]    = dumb_mnval
  mid_eigvals[s,*]    = dumb_mdval
  max_eigvals[s,*]    = dumb_mxval
  min_eigvecs[s,*,*]  = dumb_mnvec
  mid_eigvecs[s,*,*]  = dumb_mdvec
  max_eigvecs[s,*,*]  = dumb_mxvec
  ;;  Define eigenvalue ratios
  d2nrat   = REFORM(mid_eigvals[s,*]/min_eigvals[s,*])
  x2drat   = REFORM(max_eigvals[s,*]/mid_eigvals[s,*])
  ;;  Find "best" results for this sub interval
  ;;    Maximize  :  |L_mid/L_min - L_max/L_mid| && L_mid/L_min
  ;;    Minimize  :  L_max/L_mid
  diff     = (d2nrat - x2drat)
  ratio    = diff*d2nrat/x2drat
  good     = WHERE(ratio GT 0 AND FINITE(ratio),gd)
  IF (gd[0] GT 0) THEN BEGIN
    best = MAX(ratio[good],indmx,/NAN)
    IF (best LE 0) THEN bind = -1L ELSE bind = good[indmx[0]]
  ENDIF ELSE bind = -1L
  best_wind[s] = bind[0]
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Calculate eigenvalue ratios
;;----------------------------------------------------------------------------------------
mid2min_rat    = mid_eigvals/min_eigvals
max2mid_rat    = max_eigvals/mid_eigvals
;;  Define tests for well defined minimum variance directions
;;    a)  (L_mid/L_min ≥ 10)  &  (L_max/L_mid < 3)
;;    b)  (L_mid/L_min)/(L_max/L_mid) > 3
test_dn        = (mid2min_rat GE 1d1) AND FINITE(mid2min_rat)
test_xd        = (max2mid_rat LT 3d0) AND FINITE(max2mid_rat)
test_rt        = (mid2min_rat/max2mid_rat GT 3d0)
test_gd        = (test_dn AND test_xd) OR test_rt
good_mva       = WHERE(test_gd,gd_mva,COMPLEMENT=bad_mva,NCOMPLEMENT=bd_mva)
;;----------------------------------------------------------------------------------------
;;  Define output structures
;;----------------------------------------------------------------------------------------
tags           = ['MIN_VAR','MID_VAR','MAX_VAR']
eigval_struc   = CREATE_STRUCT(tags,min_eigvals,mid_eigvals,max_eigvals)
eigvec_struc   = CREATE_STRUCT(tags,min_eigvecs,mid_eigvecs,max_eigvecs)
tags           = ['ALL_EIGVALS','ALL_EIGVECS','GOOD_MVA_INDS','BEST_UNQ_INDS','MVA_INT_STR']
out_struc      = CREATE_STRUCT(tags,eigval_struc,eigvec_struc,good_mva,best_wind,mva_struc)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;****************************************************************************************
ex_time        = SYSTIME(1) - ex_start[0]
MESSAGE,'Execution Time: '+STRING(ex_time)+' seconds',/INFORMATIONAL,/CONTINUE
;;****************************************************************************************

RETURN,out_struc
END





