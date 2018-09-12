;;  @/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/plot_and_save_precusor_mva_multifreqfilt_batch.pro

;;  Compile necessary routines
.compile $HOME/Desktop/low_beta_Ma_whistlers/crib_sheets/load_ip_shocks_mfi_split_magvec.pro
.compile $HOME/Desktop/low_beta_Ma_whistlers/crib_sheets/load_ip_shocks_mfi_filter.pro
.compile adaptive_mva_interval_wrapper.pro
.compile extract_good_mva_from_adapint.pro
.compile calc_and_save_mva_res_by_int.pro
.compile keep_best_mva_from_adapint.pro
.compile $HOME/Desktop/low_beta_Ma_whistlers/crib_sheets/temp_plot_and_save_autoadapt_mva_results.pro
;;  Define frequency range way outside useful range to prevent adaptive MVA routines from
;;    filtering the filtered data
def_fran__low  = 0d0
def_fran_high  = 1d2
;;  Frequency factors and units
freq_facs      = [1d3,1d0]
freq_unit      = ['mHz','Hz']
freq_forms     = '('+['I','f8.2']+')'
;;  Reset variables
all___mva__res = 0             ;;  MVA_RESULTS output keyword
best_subin_res = 0             ;;  BEST_SUBINT " "
best__mva__res = 0             ;;  BEST_RESULTS " "
all_polwav_res = 0             ;;  POLARIZE_WAV " "
all_mva_date   = 0
bestsub_date   = 0
bestmva_date   = 0
all_pol_date   = 0
;;  Plot and save
ex_start       = SYSTIME(1)
;FOR kk=9L, 10L DO BEGIN                                                                   $
FOR kk=0L, nprec[0] - 1L DO BEGIN                                                                   $
  tr_load        = time_double(REFORM(tran_brsts[kk,*]))                                          & $   ;;  Define time range [Unix] to load into TPLOT
  tr_ww_pred     = time_double(REFORM(tran__subs[kk,*],1,2))                                      & $   ;;  Define precursor interval time ranges [string]
  fran_prec      = fran_mods.(kk)                                                                 & $
  nf             = N_TAGS(fran_prec)                                                              & $
  FOR ff=0L, nf[0] - 1L DO BEGIN                                                                    $
    flow_ww_str    = 0                                                                            & $   ;;  Reset variables
    fhig_ww_str    = 0                                                                            & $
    mva__results   = 0                                                                            & $
    best__subint   = 0                                                                            & $
    best_results   = 0                                                                            & $
    polarize_wav   = 0                                                                            & $
    output_tag     = freq_tags[ff[0]]                                                             & $
    freq__low      = STRARR(1,2)                                                                  & $
    freq_high      = STRARR(1,2)                                                                  & $
    fran_int       = fran_prec.(ff)                                                               & $
    load_ip_shocks_mfi_filter,TRANGE=tr_load,PRECISION=prec,FREQ_RANGE=fran_int,/NO_INS_NAN       & $   ;;  Load data into TPLOT
    dc_bfield_tpn  = tnames(mfi_filt_lp[0])                                                       & $   ;;  Define DC- and AC-Coupled field TPLOT handles
    ac_bfield_tpn  = tnames(mfi_filt_dettp[0])                                                    & $   ;;  Define DC- and AC-Coupled field TPLOT handles
    test           = (dc_bfield_tpn[0] EQ '') OR (ac_bfield_tpn[0] EQ '')                         & $
    IF (test[0]) THEN str_element,all_mva_date,output_tag[0],0,/ADD_REPLACE                       & $
    IF (test[0]) THEN str_element,bestsub_date,output_tag[0],0,/ADD_REPLACE                       & $
    IF (test[0]) THEN str_element,bestmva_date,output_tag[0],0,/ADD_REPLACE                       & $
    IF (test[0]) THEN str_element,all_pol_date,output_tag[0],0,/ADD_REPLACE                       & $
    IF (test[0]) THEN PRINT,''                                                                    & $
    IF (test[0]) THEN PRINT,date_mid_0[kk]+' --> No MVA performed...'                             & $
    IF (test[0]) THEN PRINT,''                                                                    & $
    IF (test[0]) THEN CONTINUE                                                                    & $   ;;  Add to structures for later to save
    str_element,flow_ww_str,prec_tags[0],def_fran__low[0],/ADD_REPLACE                            & $
    str_element,fhig_ww_str,prec_tags[0],def_fran_high[0],/ADD_REPLACE                            & $
    ff_facs        = freq_facs[(fran_int GE 1)]                                                   & $
    ff_unit        = freq_unit[(fran_int GE 1)]                                                   & $
    ff_form        = freq_forms[(fran_int GE 1)]                                                  & $
    freq__low0     = fran_int[0]*ff_facs[0]                                                       & $
    freq_high0     = fran_int[1]*ff_facs[1]                                                       & $
    freq__low[0,0] = STRTRIM(STRING(freq__low0[0],FORMAT=ff_form[0]),2)                           & $
    freq__low[0,1] = ff_unit[0]                                                                   & $
    freq_high[0,0] = STRTRIM(STRING(freq_high0[0],FORMAT=ff_form[1]),2)                           & $
    freq_high[0,1] = ff_unit[1]                                                                   & $
    temp_plot_and_save_autoadapt_mva_results,ac_bfield_tpn[0],dc_bfield_tpn[0],BRST_TRAN=tr_load,   $   ;;  Perform adaptive interval (AI) MVA, save results, plot results
                                     INTS_TRANGE=tr_ww_pred,FLOW_SUBINT=flow_ww_str,                $
                                     FHIGHSUBINT=fhig_ww_str,SCPREF=scpref0[0],                     $
                                     FPREF_MID=date_in_pre0[kk[0]],                                 $   ;;  Return "best" results to user
                                     BAVG_UP=bavg_up,SH_NORM=sh_norm,                               $
                                     FREQ__LOW=freq__low,FREQ_HIGH=freq_high,                       $
                                     POLARIZE_WAV=polarize_wav,BEST_SUBINT=best__subint,            $
                                     MVA_RESULTS=mva__results,BEST_RESULTS=best_results           & $
    test           = (SIZE(best__subint,/TYPE) NE 8) OR (SIZE(mva__results,/TYPE) NE 8) OR          $
                     (SIZE(best_results,/TYPE) NE 8) OR (SIZE(polarize_wav,/TYPE) NE 8)           & $   ;;  Make sure output is valid, if not --> save dummy values
    IF (test[0]) THEN str_element,all_mva_date,output_tag[0],0,/ADD_REPLACE                       & $
    IF (test[0]) THEN str_element,bestsub_date,output_tag[0],0,/ADD_REPLACE                       & $
    IF (test[0]) THEN str_element,bestmva_date,output_tag[0],0,/ADD_REPLACE                       & $
    IF (test[0]) THEN str_element,all_pol_date,output_tag[0],0,/ADD_REPLACE                       & $
    IF (test[0]) THEN PRINT,''                                                                    & $
    IF (test[0]) THEN PRINT,date_mid_0[kk]+' --> No MVA results returned...'                      & $
    IF (test[0]) THEN PRINT,''                                                                    & $
    IF (test[0]) THEN CONTINUE                                                                    & $   ;;  Add to structures for later to save
    temp0          = 0                                                                            & $
    IF (SIZE(mva__results.INT_000,/TYPE) EQ 8) THEN                                                 $
      IF (SIZE(mva__results.INT_000.FR_00,/TYPE) EQ 8) THEN                                         $
        extract_tags,temp0,mva__results.INT_000.FR_00                                             & $
;    extract_tags,temp0,mva__results.(0).(0)                                                       & $
    str_element,all_mva_date,output_tag[0],temp0,/ADD_REPLACE                                     & $
    temp1          = 0                                                                            & $
    IF (SIZE(best__subint.INT_000,/TYPE) EQ 8) THEN                                                 $
      IF (SIZE(best__subint.INT_000.FR_00,/TYPE) EQ 8) THEN                                         $
        extract_tags,temp1,best__subint.INT_000.FR_00                                             & $
;    extract_tags,temp1,best__subint.(0).(0)                                                       & $
    str_element,bestsub_date,output_tag[0],temp1,/ADD_REPLACE                                     & $
    temp2          = 0                                                                            & $
    extract_tags,temp2,best_results                                                               & $
;    extract_tags,temp2,best_results.(0).(0).(0)                                                   & $
    str_element,bestmva_date,output_tag[0],temp2,/ADD_REPLACE                                     & $
    temp3          = 0                                                                            & $
    IF (SIZE(polarize_wav.INT_000,/TYPE) EQ 8) THEN                                                 $
      IF (SIZE(polarize_wav.INT_000.FR_00,/TYPE) EQ 8) THEN                                         $
        extract_tags,temp3,polarize_wav.INT_000.FR_00                                             & $
;    extract_tags,temp3,polarize_wav.(0).(0)                                                       & $
    str_element,all_pol_date,output_tag[0],temp3,/ADD_REPLACE                                     & $
  ENDFOR                                                                                          & $
  output_tag     = date_tags[kk[0]]                                                               & $
  str_element,all___mva__res,output_tag[0],all_mva_date,/ADD_REPLACE                              & $
  str_element,best_subin_res,output_tag[0],bestsub_date,/ADD_REPLACE                              & $
  str_element,best__mva__res,output_tag[0],bestmva_date,/ADD_REPLACE                              & $
  str_element,all_polwav_res,output_tag[0],all_pol_date,/ADD_REPLACE                              & $
  all_mva_date   = 0                                                                              & $
  bestsub_date   = 0                                                                              & $
  bestmva_date   = 0                                                                              & $
  all_pol_date   = 0                                                                              & $
  PRINT,''                                                                                        & $
  PRINT,date_mid_0[kk]+' --> finished MVA and plotting...'                                        & $
  PRINT,''
ex_time        = SYSTIME(1) - ex_start[0]
PRINT,''  & $
MESSAGE,'Execution Time: '+STRING(ex_time)+' seconds',/INFORMATIONAL,/CONTINUE  & $
PRINT,''




;  fran_int       = REFORM(fran_mods[kk,*])                                                      & $
; 
; 
; 
;  IF (test[0]) THEN str_element,all___mva__res,date_tags[kk[0]],0,/ADD_REPLACE                    & $
;  IF (test[0]) THEN str_element,best_subin_res,date_tags[kk[0]],0,/ADD_REPLACE                    & $
;  IF (test[0]) THEN str_element,best__mva__res,date_tags[kk[0]],0,/ADD_REPLACE                    & $
;  IF (test[0]) THEN str_element,all_polwav_res,date_tags[kk[0]],0,/ADD_REPLACE                    & $
;  IF (test[0]) THEN PRINT,''                                                                      & $
;  IF (test[0]) THEN PRINT,date_mid_0[kk]+' --> No MVA results returned...'                        & $
;  IF (test[0]) THEN PRINT,''                                                                      & $
;  IF (test[0]) THEN CONTINUE                                                                      & $   ;;  Add to structures for later to save
;  bavg_up        = TRANSPOSE([bvecup[kk,*],d_bvecup[kk,*]])                                       & $
;  sh_norm        = TRANSPOSE([nvecup[kk,*],d_nvecup[kk,*]])                                       & $
;  str_element,flow_ww_str,prec_tags[0],def_fran__low[0],/ADD_REPLACE                              & $
;  str_element,fhig_ww_str,prec_tags[0],def_fran_high[0],/ADD_REPLACE                              & $
;  temp_plot_and_save_autoadapt_mva_results,ac_bfield_tpn[0],dc_bfield_tpn[0],BRST_TRAN=tr_load,     $   ;;  Perform adaptive interval (AI) MVA, save results, plot results
;                                   INTS_TRANGE=tr_ww_pred,FLOW_SUBINT=flow_ww_str,                  $
;                                   FHIGHSUBINT=fhig_ww_str,SCPREF=scpref0[0],                       $
;                                   FPREF_MID=date_in_pre0[kk[0]],BEST_RESULTS=best_results,         $   ;;  Return "best" results to user
;                                   BAVG_UP=bavg_up,SH_NORM=sh_norm,                                 $
;                                   POLARIZE_WAV=polarize_wav,BEST_SUBINT=best_subint,               $
;                                   MVA_RESULTS=mva_results                                        & $
;  test           = (SIZE(best_subint,/TYPE) NE 8) OR (SIZE(mva_results,/TYPE) NE 8) OR              $
;                   (SIZE(best_results,/TYPE) NE 8) OR (SIZE(polarize_wav,/TYPE) NE 8)             & $   ;;  Make sure output is valid, if not --> save dummy values
;  IF (test[0]) THEN str_element,all___mva__res,date_tags[kk[0]],0,/ADD_REPLACE                    & $
;  IF (test[0]) THEN str_element,best_subin_res,date_tags[kk[0]],0,/ADD_REPLACE                    & $
;  IF (test[0]) THEN str_element,best__mva__res,date_tags[kk[0]],0,/ADD_REPLACE                    & $
;  IF (test[0]) THEN str_element,all_polwav_res,date_tags[kk[0]],0,/ADD_REPLACE                    & $
;  IF (test[0]) THEN PRINT,''                                                                      & $
;  IF (test[0]) THEN PRINT,date_mid_0[kk]+' --> No MVA results returned...'                        & $
;  IF (test[0]) THEN PRINT,''                                                                      & $
;  IF (test[0]) THEN CONTINUE                                                                      & $   ;;  Add to structures for later to save
;  str_element,all___mva__res,date_tags[kk[0]], mva_results,/ADD_REPLACE                           & $
;  str_element,best_subin_res,date_tags[kk[0]], best_subint,/ADD_REPLACE                           & $
;  str_element,best__mva__res,date_tags[kk[0]],best_results,/ADD_REPLACE                           & $
;  str_element,all_polwav_res,date_tags[kk[0]],polarize_wav,/ADD_REPLACE                           & $
;  PRINT,''                                                                                        & $
;  PRINT,date_mid_0[kk]+' --> finished MVA and plotting...'                                        & $
;  PRINT,''



