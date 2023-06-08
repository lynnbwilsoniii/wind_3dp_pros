;+
;*****************************************************************************************
;
;  FUNCTION :   calc_and_save_mva_res_by_int.pro
;  PURPOSE  :   This is a wrapping routine for extract_good_mva_from_adapint.pro meant
;                 to be used once a user has defined several intervals, within a given
;                 burst interval, and associated frequency ranges for bandpass filters.
;                 The routine will loop through each interval and then through each
;                 frequency range to perform adaptive interval (AI) minimum variance
;                 analysis (MVA).  The user may define several parameters that are used
;                 by the AIMVA software and the routine can return several parameters
;                 that may be useful for plotting.  An IDL save file will be created on
;                 output, from the output of the AIMVA software, in the event that the
;                 user did not define BEST_SUBINT and MVA_RESULTS on input.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               tplot_struct_format_test.pro
;               t_get_struc_unix.pro
;               sample_rate.pro
;               is_a_number.pro
;               num2int_str.pro
;               minmax.pro
;               file_name_times.pro
;               str_element.pro
;               extract_good_mva_from_adapint.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STRUC         :  Scalar [structure] defining a valid TPLOT structure
;                                  of magnetic field [nT] data upon which the user wishes
;                                  to perform minimum variance analysis (MVA).  The data
;                                  structure should be clipped to contain only data from
;                                  a single burst interval (i.e., no significant data
;                                  gaps).
;
;                                  The required structure tags for STRUC are:
;                                    X  :  [N]-Element array of Unix times
;                                    Y  :  [N,3]-Element array of 3-vectors
;
;                                  If the TSHIFT tag is present, the routine will assume
;                                  that STRUC.X is seconds from STRUC.TSHIFT[0].
;
;  EXAMPLES:    
;               [calling sequence]
;               saved = calc_and_save_mva_res_by_int(struc, INTS_TRANGE=ints_trange,    $
;                                  FLOW_SUBINT=flow_subint,FHIGHSUBINT=fhighsubint      $
;                                  [,BAD_INTS=bad_ints] [,BAD_FLOW=bad_flow]            $
;                                  [,SCPREF=scpref] [,D__NW=d__nw] [,D__NS=d__ns]       $
;                                  [,N_WIN=n_win] [,MIN_THRSH=min_thrsh]                $
;                                  [,MAX_OVERL=max_overl] [,N_INT_ARR=n_int_arr]        $
;                                  [,FRAN_FNM_STR=fran_fnm_str] [,N_MIN_STR=n_min_str]  $
;                                  [,FRAN_YSB_STR=fran_ysb_str] [,FPREF_MID=fpref_mid0] $
;                                  [,BEST_SUBINT=best_subint] [,MVA_RESULTS=mva_results])
;
;  KEYWORDS:    
;               **********************************
;               ***      REQUIRED  INPUTS      ***
;               **********************************
;               INTS_TRANGE   :  [I,2]-Element [numeric] array defining the Unix start/end
;                                  times of each interval within STRUC
;               FLOW_SUBINT   :  Scalar [structure] containing I-tags with arrays of the
;                                  lower bound frequencies [Hz] for the bandpass filters,
;                                  where the i-th tag corresponds to i-th interval in
;                                  INTS_TRANGE
;               FHIGHSUBINT   :  Scalar [structure] containing I-tags with arrays of the
;                                  upper bound frequencies [Hz] for the bandpass filters,
;                                  where the i-th tag corresponds to i-th interval in
;                                  INTS_TRANGE
;               **********************************
;               ***      OPTIONAL  INPUTS      ***
;               **********************************
;               BAD_INTS      :  [K]-Element [numeric] array defining the intervals within
;                                  the time range of STRUC to avoid performing MVA.
;                                  [Default = -1]
;               BAD_FLOW      :  [K]-Element [numeric] array defining the low frequency
;                                  bound corresponding to the BAD_INTS in the event that
;                                  the same interval has good frequency ranges on which to
;                                  perform MVA.
;                                  [Default = NaN]
;               BEST_SUBINT   :  Scalar [structure] containing multiple tags corresponding
;                                  to analysis on multiple intervals from the output of
;                                  the BEST_NO_OVRLP keyword in the routine
;                                  extract_good_mva_from_adapint.pro
;                                  [Default = (defined on output)]
;               MVA_RESULTS   :  Scalar [structure] containing multiple tags corresponding
;                                  to analysis on multiple intervals from the output of
;                                  the routine extract_good_mva_from_adapint.pro
;                                  [Default = (defined on output)]
;               SCPREF        :  Scalar [string] defining the name of the spacecraft (or
;                                  whatever name the user wishes to use) to use in the
;                                  output file name
;                                  [Default = 'sc']
;               D__NW         :  Scalar [numeric] defining the # of indices between each
;                                  each time window (TW).  This value is passed as the
;                                  DNWINDS keyword to the routine:
;                                  extract_good_mva_from_adapint.pro
;                                  [Default = 2]
;               D__NS         :  Scalar [numeric] defining the # of indices by which to
;                                  shift between each subinterval (SI) within each
;                                  interval.  This value is passed as the NSHIFT keyword
;                                  to the routine:
;                                  extract_good_mva_from_adapint.pro
;                                  [Default = 8]
;               N_WIN         :  Scalar [numeric] defining the # of TWs within each SI.
;                                  This value is passed as the NTWINDS keyword to the
;                                  routine:
;                                  extract_good_mva_from_adapint.pro
;                                  [Default = 200]
;               MIN_THRSH     :  Scalar [numeric] defining the minimum (positive) allowed
;                                  amplitude threshold below which MVA will not be
;                                  performed on any given TW within any SI within any
;                                  interval.  This value is passed as the MIN_AMP_THRSH
;                                  keyword to the routine:
;                                  extract_good_mva_from_adapint.pro
;                                  [Default = 0.004]
;               MAX_OVERL     :  Scalar [numeric] defining the maximum allowable SI
;                                  overlap before two SIs are considered to be the "same"
;                                  and thus only including the "better" of the two.  This
;                                  value is passed as the MX_OVRLP_THSH keyword to the
;                                  routine:
;                                  extract_good_mva_from_adapint.pro
;                                  [Default = 0.75]
;               FPREF_MID     :  Scalar [string] to insert into the output file name
;                                  after the SCPREF[0]+'_' initial prefix.  For instance,
;                                  this is a useful way to label each burst interval or
;                                  some other defining trait of a given input STRUC.
;                                  [Default = '']
;               **********************************
;               ***           OUTPUTS          ***
;               **********************************
;               N_INT_ARR     :  Set to a named variable to return an [I]-element
;                                  [numeric] array containing the # of vectors within
;                                  each interval to be sent to the MVA routines
;               N_MIN_STR     :  Set to a named variable to return a scalar [structure]
;                                  containing I-tags with numeric arrays defining the
;                                  N_MIN values to use for each filter range for each
;                                  interval sent to the following routine under the
;                                  keyword NTMIN:  extract_good_mva_from_adapint.pro
;               FRAN_FNM_STR  :  Set to a named variable to return a scalar [structure]
;                                  containing I-tags with string arrays defining the
;                                  frequency ranges of each bandpass filter to be used
;                                  for file names by other routines
;                                  (e.g., 'Filt_10-100Hz')
;               FRAN_YSB_STR  :  Set to a named variable to return a scalar [structure]
;                                  containing I-tags with string arrays defining the
;                                  frequency ranges of each bandpass filter to be used
;                                  for plot subtitles by other routines
;                                  (e.g., '[Filt: 10-100 Hz]')
;               BEST_SUBINT   :  Set to a named variable to return a scalar [structure]
;                                  containing multiple tags corresponding to analysis on
;                                  multiple intervals from the output of the BEST_NO_OVRLP
;                                  keyword in the routine extract_good_mva_from_adapint.pro
;               MVA_RESULTS   :  Set to a named variable to return a scalar [structure]
;                                  containing multiple tags corresponding to analysis on
;                                  multiple intervals from the output of the routine
;                                  extract_good_mva_from_adapint.pro
;               MIN_NUM_INT   :  Scalar [long] defining the minimum integer # of time
;                                  steps required in the input interval for performing
;                                  the adaptive interval analysis
;                                  [Default = 50]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [08/01/2016   v1.0.0]
;             2)  Continued to write routine
;                                                                   [08/01/2016   v1.0.0]
;             3)  Continued to write routine
;                                                                   [08/01/2016   v1.0.0]
;             4)  Renamed to calc_and_save_mva_res_by_int.pro from
;                   temp_save_scm_mva_results.pro and cleaned up a little
;                                                                   [08/01/2016   v1.0.0]
;             5)  Fixed a typo in SCPREF keyword usage and cleaned up a little
;                                                                   [08/02/2016   v1.0.1]
;             6)  Added keyword:  MIN_NUM_INT
;                                                                   [04/07/2017   v1.0.2]
;
;   NOTES:      
;               1)  This is primarily a wrapping routine for the AIMVA software
;                     extract_good_mva_from_adapint.pro
;               2)  See also:
;                     adaptive_mva_interval_wrapper.pro
;                     extract_good_mva_from_adapint.pro
;                     keep_best_mva_from_adapint.pro
;               3)  Do not add a '_' after SCPREF or FPREF_MID inputs, as the routine
;                     will do that automatically
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
;   CREATED:  08/01/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/07/2017   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION calc_and_save_mva_res_by_int,struc,                                            $  ;;  Input
                                      INTS_TRANGE=ints_trange,                          $  ;;  Required input keywords
                                      FLOW_SUBINT=flow_subint,FHIGHSUBINT=fhighsubint,  $
                                      BAD_INTS=bad_ints,BAD_FLOW=bad_flow,              $  ;;  Optional input keywords
                                      SCPREF=scpref0,D__NW=d__nw0,D__NS=d__ns0,         $
                                      N_WIN=n_win0,MIN_THRSH=min_thrsh0,                $
                                      MAX_OVERL=max_overl,FPREF_MID=fpref_mid0,         $
                                      MIN_NUM_INT=min_num_int,                          $
                                      N_INT_ARR=n_int_arr,FRAN_FNM_STR=fran_fnm_str,    $  ;;  Output keywords
                                      FRAN_YSB_STR=fran_ysb_str,N_MIN_STR=n_min_str,    $
                                      BEST_SUBINT=best_subint,MVA_RESULTS=mva_results

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Factors and units
mult_facts     = [1d12,1d9,1d6,1d3,1d0,1d-3,1d-6,1d-9,1d-12]
si_prefixes    = ['p','n','mu','m','','k','M','G','T']
mult_units     = si_prefixes+'(nT)'
fran_units     = si_prefixes+'Hz'
;;  Dummy error messages
no_inpt_msg    = 'User must supply at least one valid TPLOT structure...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (tplot_struct_format_test(struc,/YVECT,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Calculate sample rates [sps] and periods [s]
unix           = t_get_struc_unix(struc)
srate_db0      = sample_rate(unix,/AVERAGE)
srate_db       = DOUBLE(ROUND(srate_db0[0]))       ;;  Sample rate [sps]
speri_db       = 1d0/srate_db[0]                   ;;  Sample period [s]
n_tot          = N_ELEMENTS(unix)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check BAD_INTS and BAD_FLOW
test           = (N_ELEMENTS(bad_ints) EQ 0) OR (N_ELEMENTS(bad_flow) EQ 0)
IF (test[0]) THEN bad_ints = [-1L]
IF (test[0]) THEN bad_flow = [f]
;;  Check INTS_TRANGE
test           = (N_ELEMENTS(ints_trange) LT 2) OR (is_a_number(ints_trange,/NOMSSG) EQ 0)
IF (test[0]) THEN RETURN,0b     ;;  Required input keyword missing --> exit
st_td          = REFORM(ints_trange[*,0])
en_td          = REFORM(ints_trange[*,1])
nt             = N_ELEMENTS(st_td)         ;;  # of intervals within burst time range
;;  Check FLOW_SUBINT and FHIGHSUBINT
test           = (SIZE(flow_subint,/TYPE) NE 8) OR (SIZE(fhighsubint,/TYPE) NE 8)
IF (test[0]) THEN RETURN,0b     ;;  Required input keyword missing --> exit
test           = (N_TAGS(flow_subint) NE nt[0]) OR (N_TAGS(fhighsubint) NE nt[0])
IF (test[0]) THEN RETURN,0b     ;;  Required input keyword missing --> exit
flow_ww_str    = flow_subint
fhig_ww_str    = fhighsubint
;;  Check SCPREF
test           = (SIZE(scpref0,/TYPE) NE 7)
IF (test[0]) THEN scpref = 'sc_' ELSE scpref = scpref0[0]+'_'
;;  Check D__NW
test           = (is_a_number(d__nw0,/NOMSSG) EQ 0)
IF (test[0]) THEN d__nw = 2L ELSE d__nw = (LONG(d__nw0[0]) > 1L) < n_tot[0]
;;  Check D__NS
test           = (is_a_number(d__ns0,/NOMSSG) EQ 0)
IF (test[0]) THEN d__ns = 2L ELSE d__ns = (LONG(d__ns0[0]) > 1L) < n_tot[0]
;;  Check N_WIN
test           = (is_a_number(n_win0,/NOMSSG) EQ 0)
IF (test[0]) THEN n_win = 200L ELSE n_win = (LONG(n_win0[0]) > 1L) < (n_tot[0]/64L)
;;  Check MIN_THRSH [assumes input is in nT --> default is 4 pT]
test           = (is_a_number(min_thrsh0,/NOMSSG) EQ 0)
IF (test[0]) THEN min_thrsh = 4d-3 ELSE min_thrsh = (DOUBLE(min_thrsh0[0]) > 0d0) < MAX(ABS(struc.Y),/NAN)
;;  Check MAX_OVERL [assumes input is percentage of 1.0]
test           = (is_a_number(max_overl,/NOMSSG) EQ 0)
IF (test[0]) THEN mxovr = 75d-2 ELSE mxovr = (DOUBLE(max_overl[0]) > 0d0) < 1d0
;;  Check FPREF_MID
test           = (SIZE(fpref_mid0,/TYPE) NE 7)
IF (test[0]) THEN fpref_mid = '' ELSE fpref_mid = fpref_mid0[0]+'_'
;;----------------------------------------------------------------------------------------
;;  Define interval stuff
;;----------------------------------------------------------------------------------------
;;  stuff related to INTS_TRANGE keyword
int_strs       = num2int_str(LINDGEN(nt[0]),NUM_CHAR=3,/ZERO_PAD)
tags           = 'INT_'+int_strs
;;----------------------------------------------------------------------------------------
;;  Define file name prefix
;;----------------------------------------------------------------------------------------
tr_brst_int    = minmax(unix)
fnm            = file_name_times(tr_brst_int,PREC=3L)
fn_suffx       = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)
fname_pref     = STRUPCASE(scpref[0])+fpref_mid[0]+fn_suffx[0]+'_'             ;;  e.g., 'MMS3_2015-10-16_1305x23.799-1307x47.598_'
;;----------------------------------------------------------------------------------------
;;  Define N_INT values for each interval within the burst interval
;;----------------------------------------------------------------------------------------
FOR k=0L, nt[0] - 1L DO BEGIN
  trange    = [st_td[k[0]],en_td[k[0]]]             ;;  [start,end] time [Unix] of interval
  dt_int    = MAX(trange,/NAN) - MIN(trange,/NAN)   ;;  duration of interval [s]
  n_int     = ROUND(dt_int[0]*srate_db[0])          ;;  # of time steps within each interval
  PRINT,';;  Int: ',k[0],', N_int  = ',n_int[0],', ∆t_int  = ',dt_int[0]
  IF (k EQ 0) THEN n_int_all = n_int ELSE n_int_all = [n_int_all,n_int]
ENDFOR
;;  Define N_INT_ARR keyword output
n_int_arr      = n_int_all
;;----------------------------------------------------------------------------------------
;;  Determine N_min parameters
;;----------------------------------------------------------------------------------------
;;  stuff related to FLOW_SUBINT and FHIGHSUBINT keywords
l10f_facts     = ALOG10(1d0/mult_facts)
dumb           = TEMPORARY(freq_str_str)
dumb           = TEMPORARY(freq_ysub_str)
dumb           = TEMPORARY(nmin_filt_str)
FOR k=0L, nt[0] - 1L DO BEGIN  ;;  Iterate over intervals
  ;;--------------------------------------------------------------------------------------
  ;;  Reset dummy variables
  ;;--------------------------------------------------------------------------------------
  freq_mid0 = ''
  dumb      = [d]
  ;;--------------------------------------------------------------------------------------
  ;;  Define interval-specific parameters
  ;;--------------------------------------------------------------------------------------
  n_int     = n_int_all[k[0]]
  flow_ww   = flow_ww_str.(k)     ;;  Array of lower frequency bounds for bandpass filters
  fhig_ww   = fhig_ww_str.(k)     ;;  Array of upper frequency bounds for bandpass filters
  test      = (TOTAL(FINITE(flow_ww)) EQ 0) OR (TOTAL(FINITE(fhig_ww)) EQ 0)
  IF (test[0]) THEN BEGIN
    ;;  No finite frequency ranges for this interval
    str_element, freq_str_str,tags[k],freq_mid0,/ADD_REPLACE
    str_element,freq_ysub_str,tags[k],freq_mid0,/ADD_REPLACE
    str_element,nmin_filt_str,tags[k],     dumb,/ADD_REPLACE
    ;;  Jump to next interval
    CONTINUE
  ENDIF
  l10flow   = ALOG10(flow_ww)
  l10fhig   = ALOG10(fhig_ww)
  badf      = WHERE(flow_ww LE 0,bdf)
  IF (bdf GT 0) THEN l10flow[badf] = -30d0
  badf      = WHERE(fhig_ww LE 0,bdf)
  IF (bdf GT 0) THEN l10fhig[badf] =  30d0
  nf        = N_ELEMENTS(flow_ww)
  funits    = STRARR(nf[0])       ;;  UNITS used for file names and plot titles
  f_fact    = DBLARR(nf[0])       ;;  Multiplication factor from Hz to UNITS
  FOR ff=0L, nf[0] - 1L DO BEGIN  ;;  Iterate over filter frequencies
    test       = (l10flow[ff] GE l10f_facts) OR (l10fhig[ff] LT l10f_facts)
    badf       = WHERE(test,bdf,COMPLEMENT=goodf,NCOMPLEMENT=gdf)
    IF (gdf GT 0) THEN funits0 = fran_units[MAX(goodf)] ELSE funits0 = 'Hz'
    IF (gdf GT 0) THEN f_fact0 = mult_facts[MAX(goodf)] ELSE f_fact0 = 1d0 
    funits[ff] = funits0[0]
    f_fact[ff] = f_fact0[0]
  ENDFOR
  ;;--------------------------------------------------------------------------------------
  ;;  Define file name suffixes
  ;;--------------------------------------------------------------------------------------
  lowf_str  = STRTRIM(STRING(flow_ww*f_fact,FORMAT='(f15.3)'),2L)
  higf_str  = STRTRIM(STRING(fhig_ww*f_fact,FORMAT='(f15.3)'),2L)
  freq_mid0 = 'Filt_'+lowf_str+'-'+higf_str+funits
  str_element,freq_str_str,tags[k],freq_mid0,/ADD_REPLACE
  ;;--------------------------------------------------------------------------------------
  ;;  Define YSUBTITLEs for plots
  ;;--------------------------------------------------------------------------------------
  freq_mid0 = '[Filt: '+lowf_str+'-'+higf_str+' '+funits+']'
  str_element,freq_ysub_str,tags[k],freq_mid0,/ADD_REPLACE
  dumb      = REPLICATE(d,nf[0])
  favg      = (fhig_ww + flow_ww)/2d0
  fdiff     = (fhig_ww - flow_ww)
  frat      = fdiff/favg
  dtlow     = 2d0/fhig_ww
  dthig     = 2d0/flow_ww
  nminl     = ROUND(dtlow*srate_db[0])
  nminh     = ROUND(dthig*srate_db[0])
  nminarr   = [[nminl],[nminh]]
  goodmx    = WHERE(frat GE 8d-1,gdmx,COMPLEMENT=goodmn,NCOMPLEMENT=gdmn)
  IF (gdmx GT 0) THEN dumb[goodmx] = MAX(nminarr[goodmx,*],/NAN,DIMENSION=2)
  IF (gdmn GT 0) THEN dumb[goodmn] = MIN(nminarr[goodmn,*]*3/2,/NAN,DIMENSION=2)
  dumb      = dumb < (n_int[0]/6L)
  PRINT,';;  Int: ',k[0],', N_min  = ',LONG(dumb)
  ;;  Create structure of N_MIN values for each interval and frequency filter
  str_element,nmin_filt_str,tags[k],dumb,/ADD_REPLACE
ENDFOR
;;  Define FRAN_FNM_STR, FRAN_YSB_STR, and N_MIN_STR keywords output
fran_fnm_str   = freq_str_str
fran_ysb_str   = freq_ysub_str
n_min_str      = nmin_filt_str
;;----------------------------------------------------------------------------------------
;;  Define MVA interval stuff
;;----------------------------------------------------------------------------------------
;;  Perform MVA on each subinterval and time window
test_struc     = (SIZE(best_subint,/TYPE) NE 8) OR (SIZE(mva_results,/TYPE) NE 8)
IF (test_struc[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  User did not supply MVA results structures --> create now
  ;;--------------------------------------------------------------------------------------
  FOR int=0L, nt[0] - 1L DO BEGIN  ;;  Iterate over intervals
    ;;------------------------------------------------------------------------------------
    ;;  Reset dummy variables
    ;;------------------------------------------------------------------------------------
    mva_0          = 0
    bind0          = 0
    ;;------------------------------------------------------------------------------------
    ;;  Define interval time range
    ;;------------------------------------------------------------------------------------
    trange         = [st_td[int[0]],en_td[int[0]]]
    low_freqs      = flow_ww_str.(int[0])
    hig_freqs      = fhig_ww_str.(int[0])
    test           = (TOTAL(FINITE(low_freqs)) EQ 0) OR (TOTAL(FINITE(hig_freqs)) EQ 0)
    IF (test[0]) THEN BEGIN
      ;;  No finite frequency ranges for this interval
      str_element,best_subint,tags[int[0]],bind0,/ADD_REPLACE
      str_element,mva_results,tags[int[0]],mva_0,/ADD_REPLACE
      ;;  Jump to next interval
      CONTINUE
    ENDIF
    nfrq           = N_ELEMENTS(low_freqs)
    n_min_int      = nmin_filt_str.(int[0])
    ;;------------------------------------------------------------------------------------
    ;;  Define structure tags for frequency filters
    ;;------------------------------------------------------------------------------------
    ftags          = 'FR_'+num2int_str(LINDGEN(nfrq[0]),NUM_CHAR=2,/ZERO_PAD)
    b_int          = (TOTAL(int[0] EQ bad_ints) GT 0)
    FOR ff=0L, nfrq[0] - 1L DO BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Reset dummy variables
      ;;----------------------------------------------------------------------------------
      bindovr        = 1            ;;  Dummy value that will be replaced on output by a structure
      fwws_mva       = 0            ;;  Dummy value that will be replaced on output by a structure
      ;;----------------------------------------------------------------------------------
      ;;  Define filter range and N_MIN value
      ;;----------------------------------------------------------------------------------
      low_f          = low_freqs[ff]
      highf          = hig_freqs[ff]
      n_min          = n_min_int[ff]
      ratio          = (low_f[0]/bad_flow) - 1d0
      b_flow         = (TOTAL(ABS(ratio) LE 1e-6) GT 0) AND b_int[0]
      testf          = (FINITE(low_f[0]) EQ 0) OR (FINITE(highf[0]) EQ 0) OR $
                       (low_f[0] LT 0) OR (highf[0] LT 0)
      test           = b_flow[0] OR testf[0]
      IF (test[0]) THEN BEGIN
        ;;  User defined "bad" interval or frequency filter --> skip
        str_element,mva_0,ftags[ff],fwws_mva,/ADD_REPLACE
        str_element,bind0,ftags[ff], bindovr,/ADD_REPLACE
        ;;  Jump to next frequency range
        CONTINUE
      ENDIF
      fwws_mva       = extract_good_mva_from_adapint(struc,TRANGE=trange,DNWINDS=d__nw[0],          $
                                                     NSHIFT=d__ns[0],NTMIN=n_min[0],NTWINDS=n_win,  $
                                                     LOW_FREQ=low_f[0],HIGHFREQ=highf[0],           $
                                                     /CONS_NSHFNMIN,MIN_AMP_THRSH=min_thrsh[0],     $
                                                     /GOOD_10_3,BEST_NO_OVRLP=bindovr,              $
                                                     MX_OVRLP_THSH=mxovr[0],MIN_NUM_INT=min_num_int)
      ;;----------------------------------------------------------------------------------
      ;;  Add results to dummy structures
      ;;----------------------------------------------------------------------------------
      str_element,mva_0,ftags[ff[0]],fwws_mva,/ADD_REPLACE
      str_element,bind0,ftags[ff[0]], bindovr,/ADD_REPLACE
    ENDFOR
    ;;------------------------------------------------------------------------------------
    ;;  Add to output structures BEST_SUBINT and MVA_RESULTS
    ;;------------------------------------------------------------------------------------
    str_element,mva_results,tags[int[0]],mva_0,/ADD_REPLACE
    str_element,best_subint,tags[int[0]],bind0,/ADD_REPLACE
  ENDFOR
ENDIF
;;----------------------------------------------------------------------------------------
;;  Save MVA results [if user did not define beforehand]
;;----------------------------------------------------------------------------------------
IF (test_struc[0]) THEN BEGIN
  ;;  structures not defined on input --> create save file on output
  fname          = fname_pref[0]+'Filtered_SCM_MVA_Results.sav'
  PRINT,''
  PRINT,'Saving IDL save file named:  '+fname[0]
  PRINT,''
  SAVE,best_subint,mva_results,FILENAME=fname[0]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END
