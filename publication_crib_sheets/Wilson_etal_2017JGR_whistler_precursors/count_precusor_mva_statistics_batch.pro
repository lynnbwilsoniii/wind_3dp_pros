;;  @/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/count_precusor_mva_statistics_batch.pro

;;  Define upstream average vectors
bvecup         = bo_gse_up[ind2,*]
d_bvecup       = ABS(asy_info_str.MAGF_GSE.DY[ind2,*,0])
nvecup         = n_gse__up[ind2,*]
d_nvecup       = ABS(bvn_info_str.SH_N_GSE.DY[ind2,*])
;;  Define dummy variables
DELVAR,theta_kb,theta_kn,wave_amp,kvecs,righthand,bvec_up,dbvecup,nvec_up,dnvecup
cnt_by_date    = REPLICATE(0L,nprec[0])
cnt_by_brst    = 0L
tot_cnt        = 0L
all_mva_cnt    = 0L
FOR kk=0L, nprec[0] - 1L DO BEGIN                                                                           $
  cnt_by_brst    = 0L                                                                                     & $
  cmva_by_brst   = 0L                                                                                     & $
  tr_load        = time_double(REFORM(tran_brsts[kk,*]))                                                  & $   ;;  Define time range [Unix] to load into TPLOT
  tr_ww_ints     = tran__subs[kk,*]                                                                       & $   ;;  Define array of lion roar interval time ranges [string]
  tr_ww_pred     = time_double(REFORM(tr_ww_ints,1,2))                                                    & $   ;;  Define precursor interval time ranges [string]
  fran_int       = REFORM(fran_mods[kk,*])                                                                & $
  n_ww_ints      = N_ELEMENTS(tr_ww_pred[*,0])                                                            & $
  int_mid        = 'Int: '+num2int_str(LINDGEN(n_ww_ints[0]),NUM_CHAR=3,/ZERO_PAD)                        & $
  s_suffxb       = ';  For '+date_mid_0[kk[0]]+suffxs[kk[0]]                                              & $
  s_suffxi       = ';  For '+date_mid_1[kk[0]]+', '+int_mid+suffxs[kk[0]]                                 & $
  best_results   = best__mva__res.(kk[0])                                                                 & $
  polarize_wav   = all_polwav_res.(kk[0])                                                                 & $
  all_mva_str    = all___mva__res.(kk[0])                                                                 & $
  test0          = (SIZE(best_results,/TYPE) NE 8) OR (SIZE(polarize_wav,/TYPE) NE 8)                     & $
  test1          = (TOTAL(tr_ww_ints[*,0] EQ '') EQ n_ww_ints[0])                                         & $
  test           = test0[0] OR test1[0]                                                                   & $   ;;  Make sure valid variables before going forward
  cnt_str        = (num2int_str(cnt_by_brst[0],NUM_CHAR=6,/ZERO_PAD))[0]                                  & $
  IF (test[0]) THEN CONTINUE                                                                              & $
  FOR ii=0L, n_ww_ints[0] - 1L DO BEGIN                                                                     $   ;;  Loop through and separate low/high frequency [Hz] into 2 structures
    cnt_by__int  = 0L                                                                                     & $
    cmva_by_int  = 0L                                                                                     & $
    ff_ind_struc = best_results.INDICES_STRUC.(ii[0])                                                     & $
    ff_sitw_strc = best_results.SI_TW_STRUC.(ii[0])                                                       & $
    ff_eval_strc = best_results.EIGVALS_STRUC.(ii[0])                                                     & $
    ff_evec_strc = best_results.EIGVECS_STRUC.(ii[0])                                                     & $
    ff_amva_strc = all_mva_str.(ii[0])                                                                    & $
    polz_wav     = polarize_wav.(ii[0])                                                                   & $
    test         = (SIZE(ff_ind_struc,/TYPE) NE 8) OR (SIZE(ff_sitw_strc,/TYPE) NE 8) OR                    $
                   (SIZE(ff_eval_strc,/TYPE) NE 8) OR (SIZE(ff_evec_strc,/TYPE) NE 8) OR                    $
                   (SIZE(polz_wav,/TYPE) NE 8)                                                            & $
    IF (test[0]) THEN CONTINUE                                                                            & $
    nfrq         = MIN([N_TAGS(ff_ind_struc),N_TAGS(ff_sitw_strc),N_TAGS(ff_eval_strc),                     $
                        N_TAGS(ff_evec_strc),N_TAGS(polz_wav)])                                           & $
    FOR ff=0L, nfrq[0] - 1L DO BEGIN                                                                        $
      test         = (SIZE(ff_ind_struc.(ff[0]),/TYPE) NE 8) OR (SIZE(ff_sitw_strc.(ff[0]),/TYPE) NE 8) OR  $
                     (SIZE(ff_eval_strc.(ff[0]),/TYPE) NE 8) OR (SIZE(ff_evec_strc.(ff[0]),/TYPE) NE 8) OR  $
                     (SIZE(polz_wav.(ff[0]),/TYPE) NE 8)                                                  & $
      IF (test[0]) THEN CONTINUE                                                                          & $
      theta_kb0    = polz_wav.(ff[0]).THETA_KB                                                            & $
      theta_kn0    = polz_wav.(ff[0]).THETA_KN                                                            & $
      wave_amp0    = polz_wav.(ff[0]).WAV_AMP                                                             & $
      kvec_00      = ff_evec_strc.(ff[0]).MIN_EIGVECS                                                     & $
      amin_eigval  = ff_amva_strc.(ff[0]).GOOD_EIGVALS.MIN_VAR                                            & $
      rhanded      = LONG(polz_wav.(ff[0]).LOGIC)                                                         & $
      nsubs        = N_TAGS(polz_wav.(ff[0]).GIND)                                                        & $
      temp         = REPLICATE(-1,nsubs[0])                                                               & $
      FOR jj=0L, nsubs[0] - 1L DO temp[jj] = ([-1,jj])[polz_wav.(ff[0]).GIND.(jj)]                        & $
      good_int     = WHERE(temp GE 0,gd_int,COMPLEMENT=bad_int,NCOMPLEMENT=bd_int)                        & $
      cnt_by__int += gd_int[0]                                                                            & $
      cmva_by_int += N_ELEMENTS(amin_eigval)                                                              & $
      bvec_00      = REPLICATE(d,nsubs[0],3L)                                                             & $
      dbvec00      = REPLICATE(d,nsubs[0],3L)                                                             & $
      nvec_00      = REPLICATE(d,nsubs[0],3L)                                                             & $
      dnvec00      = REPLICATE(d,nsubs[0],3L)                                                             & $
      FOR jj=0L, 2L DO BEGIN                                                                                $
        bvec_00[*,jj] = bvecup[kk,jj]                                                                     & $
        dbvec00[*,jj] = d_bvecup[kk,jj]                                                                   & $
        nvec_00[*,jj] = nvecup[kk,jj]                                                                     & $
        dnvec00[*,jj] = d_nvecup[kk,jj]                                                                   & $
      ENDFOR                                                                                              & $
      IF (bd_int[0] GT 0) THEN theta_kb0[bad_int]  = d                                                    & $
      IF (bd_int[0] GT 0) THEN theta_kn0[bad_int]  = d                                                    & $
      IF (bd_int[0] GT 0) THEN rhanded[bad_int]    = -1                                                   & $
      IF (bd_int[0] GT 0) THEN wave_amp[bad_int,*] = d                                                    & $
      IF (bd_int[0] GT 0) THEN kvecs[bad_int,*]    = d                                                    & $
      test         = (N_ELEMENTS(theta_kb) EQ 0)                                                          & $
      IF (test[0]) THEN theta_kb = theta_kb0 ELSE theta_kb = [theta_kb,theta_kb0]                         & $
      test         = (N_ELEMENTS(theta_kn) EQ 0)                                                          & $
      IF (test[0]) THEN theta_kn = theta_kn0 ELSE theta_kn = [theta_kn,theta_kn0]                         & $
      test         = (N_ELEMENTS(righthand) EQ 0)                                                         & $
      IF (test[0]) THEN righthand = rhanded ELSE righthand = [righthand,rhanded]                          & $
      test         = (N_ELEMENTS(wave_amp) EQ 0)                                                          & $
      IF (test[0]) THEN wave_amp = wave_amp0 ELSE wave_amp = [wave_amp,wave_amp0]                         & $
      test         = (N_ELEMENTS(kvecs) EQ 0)                                                             & $
      IF (test[0]) THEN kvecs = kvec_00 ELSE kvecs = [kvecs,kvec_00]                                      & $
      test         = (N_ELEMENTS(bvec_up) EQ 0)                                                           & $
      IF (test[0]) THEN bvec_up = bvec_00 ELSE bvec_up = [bvec_up,bvec_00]                                & $
      IF (test[0]) THEN dbvecup = dbvec00 ELSE dbvecup = [dbvecup,dbvec00]                                & $
      test         = (N_ELEMENTS(nvec_up) EQ 0)                                                           & $
      IF (test[0]) THEN nvec_up = nvec_00 ELSE nvec_up = [nvec_up,nvec_00]                                & $
      IF (test[0]) THEN dnvecup = dnvec00 ELSE dnvecup = [dnvecup,dnvec00]                                & $
    ENDFOR                                                                                                & $
    cnt_by_brst  += cnt_by__int[0]                                                                        & $
    cmva_by_brst += cmva_by_int[0]                                                                        & $
  ENDFOR                                                                                                  & $
  cnt_by_date[kk] = cnt_by_brst[0]                                                                        & $
  all_mva_cnt    += cmva_by_brst[0]                                                                       & $
  tot_cnt        += cnt_by_brst[0]

;      g_int_0      = polz_wav.(ff[0]).GIND                                                                & $
;      nsubs        = N_TAGS(g_int_0)                                                                      & $
;  sout           = ';;  '+cnt_str[0]+' Good MVA Results'+s_suffxb[0]                                      & $
;  IF (test[0]) THEN PRINT,sout[0]                                                                         & $
;      FOR jj=0L, nsubs[0] - 1L DO BEGIN                                                                     $
;        IF (jj EQ 0) THEN temp = LONG(g_int_0.(jj)) ELSE temp += LONG(g_int_0.(jj))                       & $
;      ENDFOR                                                                                              & $
;      cnt_by__int += temp[0]                                                                              & $
;      nsubs        = N_ELEMENTS(theta_kb0)                                                      & $
;      nsubs        = LONG(TOTAL(FINITE(theta_kb0)))                                             & $
;      cnt_by__int += nsubs[0]                                                                   & $
;    cnt_str      = (num2int_str(cnt_by__int[0],NUM_CHAR=6,/ZERO_PAD))[0]                        & $
;    sout         = cnt_str[0]+' Good MVA Results'+s_suffxi[ii[0]]                               & $
;  cnt_str        = (num2int_str(cnt_by_brst[0],NUM_CHAR=6,/ZERO_PAD))[0]                        & $
;  sout           = ';;  '+cnt_str[0]+' Good MVA Results'+s_suffxb[0]                            & $
;  PRINT,sout[0]                                                                                 & $
