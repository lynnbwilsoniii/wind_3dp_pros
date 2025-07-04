;+
;*****************************************************************************************
;
;  FUNCTION :   wrapper_onesc_calc_mva_adaptinv_time_freq.pro
;  PURPOSE  :   This is a wrapping routine for the adaptive interval minimum variance
;                 analysis (MVA) software written by Lynn B. Wilson III.  This routine
;                 chops up a wide frequency range into smaller bandpass filter ranges
;                 then calls the adaptive interval MVA software.  This is the same as
;                 wrapper_calc_mva_adaptinv_time_freq.pro but only meant for one
;                 spacecraft input, not four.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               test_plot_axis_range.pro
;               get_data.pro
;               t_get_struc_unix.pro
;               sample_rate.pro
;               trange_clip_data.pro
;               calc_and_save_mva_res_by_int.pro
;               keep_best_mva_from_adapint.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TPN_MAGF     :  Scalar [string] defining a set and valid TPLOT
;                                 handle associated with magnetic field data [nT, ICB]
;               TRAN_SE      :  [2]-Element [double] array defining the time range of
;                                 interest to use for calculating the MVA unit vectors
;                                 (e.g., a wave packet interval)
;               FILT_FRQ     :  [2]-Element [numeric] array defining the total range of
;                                 frequencies to use to define the frequency filters to
;                                 apply to the data before performing MVA
;
;  EXAMPLES:    
;               [calling sequence]
;               mva_str = wrapper_onesc_calc_mva_adaptinv_time_freq(tpn_magf,tran_se,filt_frq $
;                                                                  [,TRAN_CLIP=tran_clip]     $
;                                                                  [,MAX_NFILT=max_nfilt])
;
;  KEYWORDS:    
;               TRAN_CLIP    :  [2]-Element [numeric] array defining the time range over
;                                 which to clip the magnetic field data to remove
;                                 unnecessary time periods [e.g., to isolate a burst
;                                 interval or reduce total number of points]
;                                 [Default = FALSE --> routine uses all input data]
;               MAX_NFILT    :  Scalar [numeric] defining the maximum number of frequency
;                                 filters the routine can use to avoid making the bin
;                                 widths too small
;                                 [Default = 1000L]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
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
;               2)  See also:
;                     adaptive_mva_interval_wrapper.pro
;                     extract_good_mva_from_adapint.pro
;                     keep_best_mva_from_adapint.pro
;                     wrapper_calc_mva_adaptinv_time_freq.pro
;               3)  Definitions
;                     ICB   = input coordinate basis
;                     MVA   = minimum variance analysis coordinate basis
;
;  REFERENCES:  
;               0)  H. Kawano and T. Higuchi "The bootstrap method in space physics:
;                     Error estimation for the minimum variance analysis," Geophys.
;                     Res. Lett. 22(3), pp. 307-310, 1995.
;               1)  A.V. Khrabrov and B.U.Ö Sonnerup "Error estimates for minimum
;                     variance analysis," J. Geophys. Res. 103(A4), pp. 6641-6651,
;                     1998.
;               2)  L.B. Wilson III, et al., "Revisiting the structure of low-Mach
;                     number, low-beta, quasi-perpendicular shocks," J. Geophys. Res.
;                     122(9), pp. 9115--9133, doi:10.1002/2017JA024352, 2017.
;               3)  Harris, F.J. (1978), "On the Use of Windows for Harmonic Analysis
;                      with the Discrete Fourier Transform," Proc. IEEE Vol. 66,
;                      No. 1, pp. 51-83
;               4)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report 1, Noordwijk,
;                      The Netherlands., Int. Space Sci. Inst.
;               5)  J.C. Samson and J.V. Olson, "Some Comments on the Descriptions of
;                      the Polarization States of Waves," Geophys. J. Astr. Soc. 61,
;                      pp. 115-129, 1980.
;               6)  J.D. Means, "Use of the Three-Dimensional Covariance Matrix in
;                      Analyzing the Polarization Properties of Plane Waves,"
;                      J. Geophys. Res. 77(28), pg 5551-5559, 1972.
;
;   CREATED:  01/02/2025
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/02/2025   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION wrapper_onesc_calc_mva_adaptinv_time_freq,tpn_magf,tran_se,filt_frq,              $
                                                   TRAN_CLIP=tran_clip,MAX_NFILT=max_nfilt

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define global defaults for MVA analysis
min_thrsh      = 5d-2                ;;  use 50 pT as the minimum threshold allowed for MVA
d__nw          = 2L                  ;;  # of time stamps btwn size of each time window within in subinterval
d__ns          = 4L                  ;;  # of time stamps to shift btwn each subinterval
mxovr          = 55d-2               ;;  require 55% overlap for two subintervals to be considered the "same"
def_min_nint   = 10L
def_max_nfil   = 1000L               ;;  Maximum default number of frequency bins to use for MVA
scpref_all     = 'SC'+['1','2','3','4']
;;  Error messages
noinput_mssg   = 'No input was supplied...'
ntoosml_mssg   = 'The input interval is too short to properly filter and analyze, returning without computation...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = ((N_PARAMS() LT 3) OR (SIZE(tpn_magf,/TYPE) NE 7) OR                  $
                  (is_a_number(tran_se,/NOMSSG) EQ 0) OR                               $
                  (is_a_number(filt_frq,/NOMSSG) EQ 0))
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters from input
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Get Bo [nT, GSE]
get_data,tpn_magf[0],DATA=temp_magfv_1
;;  Determine sample rate [sps]
bunix_1        = t_get_struc_unix(temp_magfv_1)
srate_1        = sample_rate(bunix_1,/AVE)
IF (srate_1[0] GT 1) THEN sr_1 = 1d0*ROUND(srate_1[0]) ELSE sr_1 = srate_1[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check TRAN_CLIP
IF (test_plot_axis_range(tran_clip,/NOMSSG)) THEN BEGIN
  tran_brst      = 1d0*tran_clip[SORT(tran_clip)]
ENDIF ELSE BEGIN
  tran_brst      = [0d0,1d30]
ENDELSE
;;  Check FILT_FRQ format/input
def_freq_filt    = [0d0,sr_1[0]/2d0]
IF (test_plot_axis_range(filt_frq,/NOMSSG)) THEN BEGIN
  ;;  Set properly
  freq_filt      = 1d0*filt_frq[SORT(filt_frq)]
  filt___on      = 1b
ENDIF ELSE BEGIN
  freq_filt      = def_freq_filt
  filt___on      = 0b
ENDELSE
;;  Check MAX_NFILT
IF (is_a_number(max_nfilt,/NOMSSG) EQ 0) THEN mxnfilt = def_max_nfil[0] ELSE mxnfilt = LONG(max_nfilt[0])

;;----------------------------------------------------------------------------------------
;;  Clip B-field data
;;----------------------------------------------------------------------------------------
bgse_clip_1    = trange_clip_data(temp_magfv_1,TRANGE=tran_brst,PRECISION=3)
IF (SIZE(bgse_clip_1,/TYPE) NE 8) THEN RETURN,0b                             ;;  Return to user
;;----------------------------------------------------------------------------------------
;;  Define interval durations
;;----------------------------------------------------------------------------------------
bunix_1        = t_get_struc_unix(bgse_clip_1)
trmva_se       = tran_se
int_durat      = ABS(trmva_se[1] - trmva_se[0])              ;;  Total interval duration [s] for each SC
int_npts       = int_durat[0]*sr_1[0]                        ;;  Corresponding # of 3-vector time stamps
min_int_npts   = int_npts[0]                                 ;;  Minimum # of 3-vectors in any given interval
min_int_dura   = int_durat[0]
min_tint_npt   = N_ELEMENTS(bunix_1)
;;  Define FFT frequency bin width based upon input points for MVA interval (i.e., not the total input time)
n_fft0         = min_int_npts[0]/2L
delfft         = sr_1[0]/(2L*n_fft0[0] - 1L)
;;  Define frequency range [Hz]
fran           = MAX(freq_filt,/NAN) - MIN(freq_filt,/NAN)
;;  Define upper bound on number of frequency bins user should allow
fbinmax        = CEIL(fran[0]/delfft[0]) < mxnfilt[0]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Chop up frequency range
;;
;;  Send in a broad frequency range (i.e., original one);  {fl, fu}, ∆fa = fu - fl
;;    Chop up into smaller ∆fs < ∆fa, options include:
;;      i)    uniformly in linear space
;;      ii)   "zoom-in" approach
;;      iii)  one-sided zoom --> fix fl(fu) and decrease(increase) fu(fl)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define min frequency bin width based on FFT frequencies
min_frq_fft    = (sr_1[0]/(min_tint_npt[0] - 1L))*1.05d0
;;  Check FILT_FRQ
IF (fran[0] LE 2d0*min_frq_fft[0]) THEN BEGIN
  ;;  ∆fa is too small --> make sure N is not too small too
  IF (~filt___on[0]) THEN BEGIN
    ;;  N is too small --> Return 0 to user
    MESSAGE,ntoosml_mssg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0b
  ENDIF ELSE BEGIN
    ;;  User screwed up and set too-narrow a frequency bin for filtering --> redefine as full range
    freq_filt      = def_freq_filt
    fran           = MAX(freq_filt,/NAN) - MIN(freq_filt,/NAN)
  ENDELSE
ENDIF ELSE BEGIN
  ;;  ∆fa is large enough --> go forth and chop up
ENDELSE
;;  Define the # of frequency bins for bandpass using option i
nfr___i        = (FLOOR(fran[0]/min_frq_fft[0]/5d0) > 2L) < fbinmax[0]
;;  Define frequency bins [Hz]
freq__i        = DINDGEN(nfr___i[0])*fran[0]/(nfr___i[0] - 1L) + MIN(freq_filt,/NAN)
;;  Define lower/upper frequency bin values [Hz]
flow__i        = freq__i[0L:(nfr___i[0] - 2L)]
fupp__i        = freq__i[1L:(nfr___i[0] - 1L)]
nlu___i        = (nfr___i[0] - 1L)
;;----------------------------------------------------------------------------------------
;;  Chop up frequency range:  Option ii
;;----------------------------------------------------------------------------------------
;;  Initialize lower/upper frequency bin values [Hz]
flow_ii        = [MIN(freq_filt,/NAN)]
fupp_ii        = [MAX(freq_filt,/NAN)]
true           = 0b
fact           = 5d-2*fran[0]/2d0
jj             = 0L
REPEAT BEGIN
  ;;  Iteratively shrink ∆f until < 2*f_fft
  flowupp        = [flow_ii[jj],fupp_ii[jj]] + [1,-1]*fact[0]
  flu_ran        = MAX(flowupp,/NAN) - MIN(flowupp,/NAN)
  true           = flu_ran[0] LT (2d0*min_frq_fft[0])
  IF (~true[0]) THEN BEGIN
    ;;  Add to arrays
    flow_ii        = [flow_ii,MIN(flowupp,/NAN)]
    fupp_ii        = [fupp_ii,MAX(flowupp,/NAN)]
    jj            += 1L
  ENDIF
ENDREP UNTIL true[0]
nlu__ii        = N_ELEMENTS(flow_ii)
;;----------------------------------------------------------------------------------------
;;  Chop up frequency range:  Option iii
;;----------------------------------------------------------------------------------------
;;  Initialize lower/upper frequency bin values [Hz]
floliii        = [MIN(freq_filt,/NAN)]                ;;  fix fl
fupliii        = [MAX(freq_filt,/NAN)]
flouiii        = floliii                              ;;  fix fu
fupuiii        = fupliii
fact           = 5d-2*fran[0]
;;  Fix f_lower
true           = 0b
jj             = 0L
REPEAT BEGIN
  ;;  Iteratively shrink ∆f (one-sided) until < 2*f_fft
  flowupp        = [floliii[jj],fupliii[jj]] + [0,-1]*fact[0]
  flu_ran        = MAX(flowupp,/NAN) - MIN(flowupp,/NAN)
  true           = flu_ran[0] LT (2d0*min_frq_fft[0])
  IF (~true[0]) THEN BEGIN
    ;;  Add to arrays
    floliii        = [floliii,MIN(flowupp,/NAN)]
    fupliii        = [fupliii,MAX(flowupp,/NAN)]
    jj            += 1L
  ENDIF
ENDREP UNTIL true[0]
nluliii        = N_ELEMENTS(floliii)
;;  Fix f_upper
true           = 0b
jj             = 0L
REPEAT BEGIN
  ;;  Iteratively shrink ∆f (one-sided) until < 2*f_fft
  flowupp        = [flouiii[jj],fupuiii[jj]] + [1,0]*fact[0]
  flu_ran        = MAX(flowupp,/NAN) - MIN(flowupp,/NAN)
  true           = flu_ran[0] LT (2d0*min_frq_fft[0])
  IF (~true[0]) THEN BEGIN
    ;;  Add to arrays
    flouiii        = [flouiii,MIN(flowupp,/NAN)]
    fupuiii        = [fupuiii,MAX(flowupp,/NAN)]
    jj            += 1L
  ENDIF
ENDREP UNTIL true[0]
nluuiii        = N_ELEMENTS(flouiii)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define defaults and parameters for MVA
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
n_l_wins       = [2L,20L,40L,60L,80L,100L,200L,200L]
n_u_wins       = [2L,REPLICATE((min_int_npts[0]/5L),6L),200L]
test_min       = [(min_int_npts[0] GE   10L AND min_int_npts[0] LE   20L),      $
                  (min_int_npts[0] GT   20L AND min_int_npts[0] LE  100L),      $
                  (min_int_npts[0] GT  100L AND min_int_npts[0] LE  200L),      $
                  (min_int_npts[0] GT  200L AND min_int_npts[0] LE  300L),      $
                  (min_int_npts[0] GT  300L AND min_int_npts[0] LE  400L),      $
                  (min_int_npts[0] GT  400L AND min_int_npts[0] LE  500L),      $
                  (min_int_npts[0] GT  500L AND min_int_npts[0] LE 1000L),      $
                  (min_int_npts[0] GT 1000L)]
good_nwin      = WHERE(test_min,gd_nwin)
;;  Define the number of subinterval time windows
n_win          = n_l_wins[good_nwin[0]] < n_u_wins[good_nwin[0]]
;;  Define structures and arrays for relevant inputs/outputs
bgse_clip_a    = {SC1:bgse_clip_1}
bunx_clip_a    = {SC1:bunix_1}
n_scp          = N_TAGS(bgse_clip_a)              ;;  # of spacecraft
;;  Define frequency bin structures
flow_struc     = {I:flow__i,II:flow_ii,III_L:floliii,III_U:flouiii}
fupp_struc     = {I:fupp__i,II:fupp_ii,III_L:fupliii,III_U:fupuiii}
n_filt         = N_TAGS(flow_struc)               ;;  # of different filter arrays
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Perform MVA
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
nf_all_nn      = [nlu___i[0],nlu__ii[0],nluliii[0],nluuiii[0]]
nf_max_nn      = LONG(MAX(nf_all_nn))
;;  The following index definitions hold:
;;    S  :  Spacecraft (SC) index (just 1 here)
;;    W  :  # of frequency filter types
;;    F  :  Max # of frequency ranges within all frequency filter types
;;    V  :  # of 3-vector elements (i.e., 3)
;;    U  :  [val,uncertainty] of any given parameter
;;    K  :  # of unique values relative to each parameter
eigen_val      = REPLICATE(d,n_scp[0],n_filt[0],nf_max_nn[0],3L,2L)        ;;  {S,W,F,K,U} eigenvalues
eigen_vec      = REPLICATE(d,n_scp[0],n_filt[0],nf_max_nn[0],3L,3L)        ;;  {S,W,F,V,V} eigenvectors
khat_best      = REPLICATE(d,n_scp[0],n_filt[0],nf_max_nn[0],3L,2L)        ;;  {S,W,F,V,U} minimum variance direction
eigenvrat      = REPLICATE(d,n_scp[0],n_filt[0],nf_max_nn[0],2L)           ;;  {S,W,F,K}   eigenvalue ratios [Max/Mid,Mid/Min]
st_cl_int      = REPLICATE(d,n_scp[0],n_filt[0],nf_max_nn[0])              ;;  {S,W,F}     Unix start time of best/selected interval
en_cl_int      = REPLICATE(d,n_scp[0],n_filt[0],nf_max_nn[0])              ;;  {S,W,F}     Unix end   time of best/selected interval
n_mva_int      = REPLICATE(-1L,n_scp[0],n_filt[0],nf_max_nn[0])            ;;  {S,W,F}     Record number of intervals from which best were selected
frlu_best      = REPLICATE(d,n_scp[0],n_filt[0],nf_max_nn[0],2L)           ;;  {S,W,F,K}   [flow,fupp] of of best/selected interval
;;----------------------------------------------------------------------------------------
;;  Loop over spacecraft, then filter type, then filter values
;;----------------------------------------------------------------------------------------
FOR k=0L, n_scp[0] - 1L DO BEGIN
  ;;kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
  ;;kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
  bclip          = bgse_clip_a.(k[0])
  bunix          = bunx_clip_a.(k[0])
  inttr          = REFORM(trmva_se,1L,2L)
  scpref         = scpref_all[k[0]]
  FOR j=0L, n_filt[0] - 1L DO BEGIN
    ;;jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
    ;;jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
    flow_arr       = flow_struc.(j)
    fupp_arr       = fupp_struc.(j)
    nfl            = N_ELEMENTS(flow_arr)
    FOR i=0L, nfl[0] - 1L DO BEGIN
      ;;iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
      ;;iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
      IF (k[0] NE 0 OR j[0] NE 0 OR i[0] NE 0) THEN BEGIN
        ;;  Reset variables
        dumb           = TEMPORARY(best_subint)
        dumb           = TEMPORARY(mva_results)
        dumb           = TEMPORARY(best_res)
      ENDIF
      ;;----------------------------------------------------------------------------------
      ;;  Define eigenvalue ratio thresholds
      ;;----------------------------------------------------------------------------------
      rmid2min_thsh  = 1d2                              ;;  Require Lmid/Lmin ≥ 100
      rmax2mid_thsh  = 4d0                              ;;  Require Lmax/Lmid < 4
      rd2n_x2d_thsh  = 1d1                              ;;  Require (Lmid/Lmin)/(Lmax/Lmid) > 10
      ;;  Define frequency range [Hz]
      flow_subint    = {SC1:flow_arr[i]}
      fhighsubint    = {SC1:fupp_arr[i]}
      ;;----------------------------------------------------------------------------------
      ;;  Perform adaptive MVA
      ;;----------------------------------------------------------------------------------
      saved          = calc_and_save_mva_res_by_int(bclip,INTS_TRANGE=inttr,                   $
                                                    FLOW_SUBINT=flow_subint,FHIGHSUBINT=fhighsubint,    $
                                                    BAD_INTS=bad_ints,BAD_FLOW=bad_flow,                $
                                                    SCPREF=scpref[0],D__NW=d__nw[0],D__NS=d__ns[0],     $
                                                    N_WIN=n_win[0],MIN_THRSH=min_thrsh[0],              $
                                                    MAX_OVERL=mxovr[0],FPREF_MID=fpref_mid0,            $
                                                    MIN_NUM_INT=def_min_nint[0],                        $
                                                    N_INT_ARR=n_int_all,FRAN_FNM_STR=freq_str_str,      $
                                                    FRAN_YSB_STR=freq_ysub_str,N_MIN_STR=nmin_filt_str, $
                                                    MID2MIN_THRSH=rmid2min_thsh,                        $
                                                    MAX2MID_THRSH=rmax2mid_thsh,                        $
                                                    D2N_X2D_THRSH=rd2n_x2d_thsh,/NOMSSG,                $
                                                    BEST_SUBINT=best_subint,MVA_RESULTS=mva_results     )
      ;;----------------------------------------------------------------------------------
      ;;  Keep only the best
      ;;----------------------------------------------------------------------------------
      best_res       = keep_best_mva_from_adapint(best_subint,mva_results)
      ;;----------------------------------------------------------------------------------
      ;;  Check output
      ;;----------------------------------------------------------------------------------
      IF (SIZE(best_res,/TYPE) NE 8) THEN CONTINUE
      IF (SIZE(best_res.INDICES_STRUC,/TYPE) NE 8) THEN CONTINUE
      IF (SIZE(best_res.INDICES_STRUC.(0),/TYPE) NE 8) THEN CONTINUE
      IF (SIZE(best_res.INDICES_STRUC.(0).(0),/TYPE) NE 8) THEN CONTINUE
      ;;----------------------------------------------------------------------------------
      ;;  Define results
      ;;----------------------------------------------------------------------------------
      eigval_str     = best_res.EIGVALS_STRUC.(0).(0)
      eigvec_str     = best_res.EIGVECS_STRUC.(0).(0)
      index__str     = best_res.INDICES_STRUC.(0).(0)
      ;;  Define eigenvalues and eigenvectors
      eigvals        = [[eigval_str.(0)],[eigval_str.(1)],[eigval_str.(2)]]            ;;  [N,3]  [Min,Mid,Max]
      khat___sc1     = eigvec_str.MIN_EIGVECS                                          ;;  [N,3]  [x,y,z]
      eigvecs        = [[[eigvec_str.(0)]],[[eigvec_str.(1)]],[[eigvec_str.(2)]]]      ;;  [N,3,3]
      ;;  Define statistical uncertainty of wave unit vector
      term0          = SQRT(eigvals[*,0]/(eigvals[*,2] - eigvals[*,0]))
      term1          = SQRT(eigvals[*,0]/(eigvals[*,1] - eigvals[*,0]))
      vect0          = (term0 # REPLICATE(1d0,3L))*eigvecs[*,*,2]
      vect1          = (term1 # REPLICATE(1d0,3L))*eigvecs[*,*,1]
      dkhat__sc1     = ABS(vect0 + vect1)
      ;;  Define indices relative to clipped magnetic field
      st_clip_i1     = index__str.ST_R2ALL
      en_clip_i1     = index__str.EN_R2ALL
      n_vec_mva      = en_clip_i1 - st_clip_i1 + 1L
      ;;  Define Unix time range of MVA interval(s)
      tran_mva_s     = bunix[st_clip_i1]
      tran_mva_e     = bunix[en_clip_i1]
      tran_mva_1     = [[tran_mva_s],[tran_mva_e]]                                     ;;  [N,2]  [start,end]
      ;;  Use eigenvalue ratios to decide best intervals
      md2mn_rats     = eigvals[*,1L]/eigvals[*,0L]
      mx2md_rats     = eigvals[*,2L]/eigvals[*,1L]
      nint           = N_ELEMENTS(eigvals[*,0])
      n_mva_int[k,j,i] = nint[0]
      ;;----------------------------------------------------------------------------------
      ;;  Define output
      ;;----------------------------------------------------------------------------------
      IF (nint[0] GT 1) THEN BEGIN
        ;;  Need to determine best from multiple
        test_ratio     = md2mn_rats/mx2md_rats
        max_ratio      = MAX(test_ratio,/NAN,lx)
      ENDIF ELSE BEGIN
        ;;  No need to determine best as there can be only one
        lx             = 0L
      ENDELSE
      ;;----------------------------------------------------------------------------------
      ;;  Define best wave unit vector [ICB]
      ;;----------------------------------------------------------------------------------
      khat_best[k,j,i,*,0] = REFORM(unit_vec(khat___sc1[lx[0],*],/NAN))
      khat_best[k,j,i,*,1] = dkhat__sc1[lx[0],*]
      ;;  Define start/end Unix times
      st_cl_int[k,j,i]     = tran_mva_1[lx[0],0]
      en_cl_int[k,j,i]     = tran_mva_1[lx[0],1]
      ;;  Define frequency bounds [Hz]
      frlu_best[k,j,i,*]   = [flow_arr[i],fupp_arr[i]]
      ;;----------------------------------------------------------------------------------
      ;;  Define best eigenvalues and ratios
      ;;----------------------------------------------------------------------------------
      evals                = eigvals[lx[0],*]
      eigen_val[k,j,i,*,0] = evals
      eigen_val[k,j,i,0,0] = evals[0]*SQRT(2d0/(n_vec_mva[0] - 1L))
      eigen_val[k,j,i,1,0] = SQRT(2d0*evals[0]*(2d0*evals[1] - evals[0])/(n_vec_mva[0] - 1L))
      eigen_val[k,j,i,2,0] = SQRT(2d0*evals[0]*(2d0*evals[2] - evals[0])/(n_vec_mva[0] - 1L))
      ;;  Define best eigenvalue ratios
      eigenvrat[k,j,i,0]   = mx2md_rats[lx[0]]
      eigenvrat[k,j,i,1]   = md2mn_rats[lx[0]]
      ;;----------------------------------------------------------------------------------
      ;;  Define best eigen vectors
      ;;----------------------------------------------------------------------------------
      eigen_vec[k,j,i,*,*] = eigvecs[lx[0],*,*]
      ;;iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
      ;;iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
    ENDFOR
    ;;jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
    ;;jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
  ENDFOR
  ;;kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
  ;;kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
ENDFOR
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Select only best
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  First keep only those filters where all 4 SC have finite MVA results
good_ff        = REPLICATE(  d,n_scp[0],n_filt[0],nf_max_nn[0],2L)
FOR j=0L, n_filt[0] - 1L DO BEGIN
  nfl            = N_ELEMENTS(flow_struc.(j))
  FOR i=0L, nfl[0] - 1L DO IF ((FINITE(eigenvrat[0,j,i,1]))[0] EQ 1) THEN good_ff[*,j,i,*] = 1
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Now nullify eigenvalue ratio array
;;----------------------------------------------------------------------------------------
eigenvrcp      = eigenvrat                       ;;  Make a copy (keep original for record-keeping)
eigenvrcp     *= good_ff                         ;;  Kills "bad" or overlapping values
;;  Determine which frequency ranges are still valid
good_fr        = REPLICATE(  d,n_scp[0],n_filt[0],nf_max_nn[0],3L,3L)
FOR j=0L, n_filt[0] - 1L DO BEGIN
  ;;  No need to index all SC since all should be on/off simultaneously, due to above operations
  evrat          = REFORM(eigenvrcp[0L,j[0],*,1])
  good           = WHERE(FINITE(evrat) AND evrat GT 0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
  IF (gd[0] GT 0) THEN good_fr[*,j[0],good,*,*] = 1
ENDFOR
;;  Create copies of the rest for later use
eigenvacp      = eigen_val
eigenvecp      = eigen_vec
khatbstcp      = khat_best
eigenvrcp      = eigenvrat
stclintcp      = st_cl_int
enclintcp      = en_cl_int
nmvaintcp      = n_mva_int
frlubstcp      = frlu_best
;;  Eliminate "bad" elements
eigenvacp     *= good_fr[*,*,*,*,0:1]
eigenvecp     *= good_fr
khatbstcp     *= good_fr[*,*,*,*,0:1]
eigenvrcp     *= good_fr[*,*,*,0:1,0]
stclintcp     *= good_fr[*,*,*,0,0]
enclintcp     *= good_fr[*,*,*,0,0]
nmvaintcp     *= good_fr[*,*,*,0,0]
frlubstcp     *= good_fr[*,*,*,0:1,0]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define output structures
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define structure tag definitions for user
notes          = ['These notes describe the output array dimensions and meaning for the user.               ',$
                  ';;  The uncertainties are statistical, from Khrabrov and Sonnerup [1998].                ',$
                  ';;  The following index definitions hold:                                                ',$
                  ';;    ICB  :  input coordinate basis                                                     ',$
                  ';;    S    :  Spacecraft (SC) index (should only be one here)                            ',$
                  ';;    W    :  # of frequency filter types                                                ',$
                  ';;    F    :  Max # of frequency ranges within all frequency filter types                ',$
                  ';;    V    :  # of 3-vector elements (i.e., 3)                                           ',$
                  ';;    U    :  [val,uncertainty] of any given parameter                                   ',$
                  ';;    K    :  # of unique values relative to each parameter                              ',$
                  ';;    EIGVALS      :  {S,W,F,K,U}-element array of eigenvalues, K = {Min,Mid,Max}        ',$
                  ';;    EIGVECS      :  {S,W,F,V,V}-" " eigenvectors                                       ',$
                  ';;    KHAT_VALUNC  :  {S,W,F,V,U}-" " minimum variance directions                        ',$
                  ';;    EIGVALRAT    :  {S,W,F,K}-" " eigenvalue ratios, K = {Max/Mid,Mid/Min}             ',$
                  ';;    START_UNIX   :  {S,W,F}-" " Unix start time of corresponding interval              ',$
                  ';;    END___UNIX   :  {S,W,F}-" " Unix end time " "                                      ',$
                  ';;    N_MVA_INT    :  {S,W,F}-" " # of intervals from which best were selected           ',$
                  ';;    FRAN_LU      :  {S,W,F,K}-" " frequency ranges [Hz] of intervals, K = {flow,fupp}  ' ]
;;  Define substructures
tags           = ['EIGVALS','EIGVECS','KHAT_VALUNC','EIGVALRAT','START_UNIX','END___UNIX','N_MVA_INT','FRAN_LU']
all_struc      = CREATE_STRUCT(tags,eigen_val,eigen_vec,khat_best,eigenvrat,st_cl_int,en_cl_int,n_mva_int,frlu_best)
sel_struc      = CREATE_STRUCT(tags,eigenvacp,eigenvecp,khatbstcp,eigenvrcp,stclintcp,enclintcp,nmvaintcp,frlubstcp)
;;  Define output structure
tags           = ['ALL_BEST_VALS','BEST_VALUES','DESCRIPTION']
out_struc      = CREATE_STRUCT(tags,all_struc,sel_struc,notes)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN,out_struc
END











