;;  @/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/count_precusor_filter_stats_multifreq_batch.pro

;;  Define dummy arrays
all_flower     = REPLICATE(d,nprec[0],5L)
all_fupper     = REPLICATE(d,nprec[0],5L)
all_nfilt      = REPLICATE(d,nprec[0])
FOR kk=0L, nprec[0] - 1L DO BEGIN                                                                           $
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
  IF (test[0]) THEN CONTINUE                                                                              & $
  all_nfilt[kk]  = nf[0]                                                                                  & $
  flow_date      = REPLICATE(d,nf[0])                                                                     & $
  fupp_date      = REPLICATE(d,nf[0])                                                                     & $
  FOR ff=0L, nf[0] - 1L DO BEGIN                                                                            $
    best_results   = bestmva_date.(ff)                                                                    & $
    polarize_wav   = all_pol_date.(ff)                                                                    & $
    all_mva_str    = all_mva_date.(ff)                                                                    & $
    fran_int       = fran_prec.(ff)                                                                       & $
    test           = (SIZE(polarize_wav,/TYPE) NE 8) OR (SIZE(all_mva_str,/TYPE) NE 8)                    & $
    IF (test[0]) THEN all_nfilt[kk] -= 1L                                                                 & $
    IF (test[0]) THEN CONTINUE                                                                            & $
    flow_date[ff]  = fran_int[0]                                                                          & $
    fupp_date[ff]  = fran_int[1]                                                                          & $
  ENDFOR                                                                                                  & $
  low                          = 0L                                                                       & $
  upp                          = (nf[0] - 1L)                                                             & $
  all_flower[kk,low[0]:upp[0]] = flow_date                                                                & $
  all_fupper[kk,low[0]:upp[0]] = fupp_date





