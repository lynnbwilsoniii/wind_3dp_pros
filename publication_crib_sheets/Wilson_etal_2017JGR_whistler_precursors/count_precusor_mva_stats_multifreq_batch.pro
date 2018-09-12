;;  @/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/count_precusor_mva_stats_multifreq_batch.pro

;;  Define upstream average vectors
bvecup         = bo_gse_up[ind2,*]
d_bvecup       = ABS(asy_info_str.MAGF_GSE.DY[ind2,*,0])
nvecup         = n_gse__up[ind2,*]
d_nvecup       = ABS(bvn_info_str.SH_N_GSE.DY[ind2,*])
;;  Define dummy variables
DELVAR,theta_kb,theta_kn,wave_amp,kvecs,righthand,bvec_up,dbvecup,nvec_up,dnvecup,f_lower,f_upper
cnt_by_date    = REPLICATE(0L,nprec[0])
cnt_by_brst    = 0L
cnt_by_freq    = 0L
tot_cnt        = 0L
all_mva_cnt    = 0L

FOR kk=0L, nprec[0] - 1L DO BEGIN                                                                           $
  cnt_by_brst    = 0L                                                                                     & $
  cmva_by_freq   = 0L                                                                                     & $
  tr_load        = time_double(REFORM(tran_brsts[kk,*]))                                                  & $   ;;  Define time range [Unix] to load into TPLOT
  tr_ww_ints     = tran__subs[kk,*]                                                                       & $   ;;  Define array of lion roar interval time ranges [string]
  tr_ww_pred     = time_double(REFORM(tran__subs[kk,*],1,2))                                              & $   ;;  Define precursor interval time ranges [string]
  fran_prec      = fran_mods.(kk)                                                                         & $
  nf             = N_TAGS(fran_prec)                                                                      & $
  n_ww_ints      = N_ELEMENTS(tr_ww_pred[*,0])                                                            & $
  bestmva_date   = best__mva__res.(kk[0])                                                                 & $
  all_pol_date   = all_polwav_res.(kk[0])                                                                 & $
  all_mva_date   = all___mva__res.(kk[0])                                                                 & $
  test0          = (SIZE(bestmva_date,/TYPE) NE 8) OR (SIZE(all_pol_date,/TYPE) NE 8)                     & $
  test1          = (TOTAL(tr_ww_ints[*,0] EQ '') EQ n_ww_ints[0])                                         & $
  test           = test0[0] OR test1[0]                                                                   & $   ;;  Make sure valid variables before going forward
  cnt_str        = (num2int_str(cnt_by_brst[0],NUM_CHAR=6,/ZERO_PAD))[0]                                  & $
  IF (test[0]) THEN CONTINUE                                                                              & $
  cnt_by__int    = 0L                                                                                     & $
  cmva_by_int    = 0L                                                                                     & $
  cnt_by_freq    = 0L                                                                                     & $
  FOR ff=0L, nf[0] - 1L DO BEGIN                                                                            $
    best_results   = bestmva_date.(ff)                                                                    & $
    polarize_wav   = all_pol_date.(ff)                                                                    & $
    all_mva_str    = all_mva_date.(ff)                                                                    & $
    fran_int       = fran_prec.(ff)                                                                       & $
    test           = (SIZE(polarize_wav,/TYPE) NE 8) AND (SIZE(all_mva_str,/TYPE) NE 8)                   & $
    IF (test[0]) THEN CONTINUE                                                                            & $
    test           = (SIZE(polarize_wav,/TYPE) NE 8)                                                      & $
    IF (test[0]) THEN nsubs     = 1L ELSE nsubs     = N_TAGS(polarize_wav.GIND)                           & $
    IF (test[0]) THEN theta_kb0 = d  ELSE theta_kb0 = polarize_wav.THETA_KB                               & $
    IF (test[0]) THEN theta_kn0 = d  ELSE theta_kn0 = polarize_wav.THETA_KN                               & $
    IF (test[0]) THEN wave_amp0 = d  ELSE wave_amp0 = polarize_wav.WAV_AMP                                & $
    IF (test[0]) THEN rhanded   = 0L ELSE rhanded   = LONG(polarize_wav.LOGIC)                            & $
    test           = (N_ELEMENTS(wave_amp0) LT 5)                                                         & $
    IF (test[0]) THEN wave_amp0 = REPLICATE(d,1,5L)                                                       & $
    amin_eigval    = all_mva_str.GOOD_EIGVALS.MIN_VAR                                                     & $
    temp_evec      = best_results.EIGVECS_STRUC.(0)                                                       & $
    test           = (SIZE(temp_evec,/TYPE) NE 8)                                                         & $
    IF (test[0]) THEN kvec_00 = REPLICATE(d,1,3L) ELSE kvec_00 = temp_evec.(0).MIN_EIGVECS                & $
    temp           = REPLICATE(-1,nsubs[0])                                                               & $
    FOR jj=0L, nsubs[0] - 1L DO temp[jj] = ([-1,jj])[polarize_wav.GIND.(jj)]                              & $
    good_int     = WHERE(temp GE 0,gd_int,COMPLEMENT=bad_int,NCOMPLEMENT=bd_int)                          & $
    cnt_by_freq += gd_int[0]                                                                              & $
    cmva_by_int += N_ELEMENTS(amin_eigval)                                                                & $
    flow_00      = REPLICATE(fran_int[0],nsubs[0])                                                        & $
    fupp_00      = REPLICATE(fran_int[1],nsubs[0])                                                        & $
    cfapreind0   = REPLICATE(ind2[kk[0]],nsubs[0])                                                        & $
    bvec_00      = REPLICATE(d,nsubs[0],3L)                                                               & $
    dbvec00      = REPLICATE(d,nsubs[0],3L)                                                               & $
    nvec_00      = REPLICATE(d,nsubs[0],3L)                                                               & $
    dnvec00      = REPLICATE(d,nsubs[0],3L)                                                               & $
    FOR jj=0L, 2L DO BEGIN                                                                                  $
      bvec_00[*,jj] = bvecup[kk,jj]                                                                       & $
      dbvec00[*,jj] = d_bvecup[kk,jj]                                                                     & $
      nvec_00[*,jj] = nvecup[kk,jj]                                                                       & $
      dnvec00[*,jj] = d_nvecup[kk,jj]                                                                     & $
    ENDFOR                                                                                                & $
    IF (bd_int[0] GT 0) THEN flow_00[bad_int]    = d                                                      & $
    IF (bd_int[0] GT 0) THEN fupp_00[bad_int]    = d                                                      & $
    IF (bd_int[0] GT 0) THEN theta_kb0[bad_int]  = d                                                      & $
    IF (bd_int[0] GT 0) THEN theta_kn0[bad_int]  = d                                                      & $
    IF (bd_int[0] GT 0) THEN rhanded[bad_int]    = -1                                                     & $
    IF (bd_int[0] GT 0) THEN wave_amp0[bad_int,*] = d                                                     & $
    IF (bd_int[0] GT 0) THEN kvec_00[bad_int,*]  = d                                                      & $
    IF (bd_int[0] GT 0) THEN cfapreind0[bad_int] = -1L                                                    & $
    test         = (N_ELEMENTS(f_lower) EQ 0)                                                             & $
    IF (test[0]) THEN f_lower = flow_00 ELSE f_lower = [f_lower,flow_00]                                  & $
    test         = (N_ELEMENTS(f_upper) EQ 0)                                                             & $
    IF (test[0]) THEN f_upper = fupp_00 ELSE f_upper = [f_upper,fupp_00]                                  & $
    test         = (N_ELEMENTS(theta_kb) EQ 0)                                                            & $
    IF (test[0]) THEN theta_kb = theta_kb0 ELSE theta_kb = [theta_kb,theta_kb0]                           & $
    test         = (N_ELEMENTS(theta_kn) EQ 0)                                                            & $
    IF (test[0]) THEN theta_kn = theta_kn0 ELSE theta_kn = [theta_kn,theta_kn0]                           & $
    test         = (N_ELEMENTS(righthand) EQ 0)                                                           & $
    IF (test[0]) THEN righthand = rhanded ELSE righthand = [righthand,rhanded]                            & $
    test         = (N_ELEMENTS(wave_amp) EQ 0)                                                            & $
    IF (test[0]) THEN wave_amp = wave_amp0 ELSE wave_amp = [wave_amp,wave_amp0]                           & $
    test         = (N_ELEMENTS(kvecs) EQ 0)                                                               & $
    IF (test[0]) THEN kvecs = kvec_00 ELSE kvecs = [kvecs,kvec_00]                                        & $
    test         = (N_ELEMENTS(bvec_up) EQ 0)                                                             & $
    IF (test[0]) THEN bvec_up = bvec_00 ELSE bvec_up = [bvec_up,bvec_00]                                  & $
    IF (test[0]) THEN dbvecup = dbvec00 ELSE dbvecup = [dbvecup,dbvec00]                                  & $
    test         = (N_ELEMENTS(nvec_up) EQ 0)                                                             & $
    IF (test[0]) THEN nvec_up = nvec_00 ELSE nvec_up = [nvec_up,nvec_00]                                  & $
    IF (test[0]) THEN dnvecup = dnvec00 ELSE dnvecup = [dnvecup,dnvec00]                                  & $
    test         = (N_ELEMENTS(cfapreind) EQ 0)                                                           & $
    IF (test[0]) THEN cfapreind = cfapreind0 ELSE cfapreind = [cfapreind,cfapreind0]                      & $
  ENDFOR                                                                                                  & $
  cmva_by_freq   += cmva_by_int[0]                                                                        & $
  cnt_by_date[kk] = cnt_by_freq[0]                                                                        & $
  all_mva_cnt    += cmva_by_freq[0]                                                                       & $
  tot_cnt        += cnt_by_freq[0]






;    test           = (SIZE(polarize_wav,/TYPE) NE 8) AND (SIZE(all_mva_str,/TYPE) NE 8) OR                  $
;                     (MAX(fran_int,/NAN) LE 1d-1)                                                         & $
;    kvec_00        = best_results.EIGVECS_STRUC.(0).(0).MIN_EIGVECS                                       & $
;  cnt_by_brst  += cnt_by_freq[0]                                                                          & $

