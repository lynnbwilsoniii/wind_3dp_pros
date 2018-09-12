;;  @/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/print_wind_3dp_swe_onevar_stats_new_3_batch.pro
;;
;;  Note:  User must call the following prior to running this batch file
;;         @/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_new_2_batch.pro

test           = (N_ELEMENTS(Tr_avg_epeaap) LT 2) OR (is_a_number(beta_per_epa,/NOMSSG) EQ 0)
IF (test[0]) THEN STOP
;;----------------------------------------------------------------------------------------
;;  Print one-variable stats
;;----------------------------------------------------------------------------------------
line0          = ';;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
line1          = ';;========================================================================================'
line2          = ';;                                       Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #'
line3          = ';;============================================================================================================================================================================'
mform          = '(a44,11e10.2,2I)'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ts)_avg [eV]
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ts)_avg [eV] Stats'
PRINT,line0[0]
;;  Print (Ts)_avg [eV] [Only good SWE and only good 3DP times]
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = gtavg_epa[*,0,1]                                                                                           & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_avg [SWE, 3DP, eV]        :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[*,1,1]                                                                                           & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_avg [SWE, 3DP, eV]        :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[*,2,1]                                                                                           & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_avg [SWE, 3DP, eV]        :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[out_ip_shock,0,1]                                                                                & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_avg [3DP, No Shocks, eV]  :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[out_ip_shock,1,1]                                                                                & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_avg [SWE, No Shocks, eV]  :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[out_ip_shock,2,1]                                                                                & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_avg [SWE, No Shocks, eV]  :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[in__mo_all,0,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_avg [3DP, Inside  MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[in__mo_all,1,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_avg [SWE, Inside  MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[in__mo_all,2,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_avg [SWE, Inside  MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[out_mo_all,0,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_avg [3DP, Outside MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[out_mo_all,1,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_avg [SWE, Outside MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[out_mo_all,2,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_avg [SWE, Outside MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[good_fast_swe,0,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_avg [3DP, Fast SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[good_fast_swe,1,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_avg [SWE, Fast SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[good_fast_swe,2,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_avg [SWE, Fast SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[good_slow_swe,0,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_avg [3DP, Slow SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[good_slow_swe,1,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_avg [SWE, Slow SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtavg_epa[good_slow_swe,2,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_avg [SWE, Slow SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ts)_per [eV]
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ts)_per [eV] Stats'
PRINT,line0[0]
;;  Print (Ts)_per [eV] [Only good SWE and only good 3DP times]
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = gtper_epa[*,0,1]                                                                                           & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_per [SWE, 3DP, eV]        :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[*,1,1]                                                                                           & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_per [SWE, 3DP, eV]        :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[*,2,1]                                                                                           & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_per [SWE, 3DP, eV]        :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[out_ip_shock,0,1]                                                                                & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_per [3DP, No Shocks, eV]  :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[out_ip_shock,1,1]                                                                                & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_per [SWE, No Shocks, eV]  :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[out_ip_shock,2,1]                                                                                & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_per [SWE, No Shocks, eV]  :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[in__mo_all,0,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_per [3DP, Inside  MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[in__mo_all,1,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_per [SWE, Inside  MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[in__mo_all,2,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_per [SWE, Inside  MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[out_mo_all,0,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_per [3DP, Outside MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[out_mo_all,1,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_per [SWE, Outside MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[out_mo_all,2,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_per [SWE, Outside MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[good_fast_swe,0,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_per [3DP, Fast SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[good_fast_swe,1,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_per [SWE, Fast SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[good_fast_swe,2,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_per [SWE, Fast SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[good_slow_swe,0,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_per [3DP, Slow SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[good_slow_swe,1,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_per [SWE, Slow SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtper_epa[good_slow_swe,2,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_per [SWE, Slow SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ts)_par [eV]
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ts)_par [eV] Stats'
PRINT,line0[0]
;;  Print (Ts)_par [eV] [Only good SWE and only good 3DP times]
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = gtpar_epa[*,0,1]                                                                                           & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_par [SWE, 3DP, eV]        :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[*,1,1]                                                                                           & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_par [SWE, 3DP, eV]        :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[*,2,1]                                                                                           & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_par [SWE, 3DP, eV]        :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[out_ip_shock,0,1]                                                                                & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_par [3DP, No Shocks, eV]  :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[out_ip_shock,1,1]                                                                                & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_par [SWE, No Shocks, eV]  :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[out_ip_shock,2,1]                                                                                & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_par [SWE, No Shocks, eV]  :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[in__mo_all,0,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_par [3DP, Inside  MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[in__mo_all,1,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_par [SWE, Inside  MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[in__mo_all,2,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_par [SWE, Inside  MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[out_mo_all,0,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_par [3DP, Outside MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[out_mo_all,1,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_par [SWE, Outside MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[out_mo_all,2,1]                                                                                  & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_par [SWE, Outside MOs, eV]:  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[good_fast_swe,0,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_par [3DP, Fast SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[good_fast_swe,1,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_par [SWE, Fast SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[good_fast_swe,2,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_par [SWE, Fast SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[good_slow_swe,0,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_e_par [3DP, Slow SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[good_slow_swe,1,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_p_par [SWE, Slow SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
x              = gtpar_epa[good_slow_swe,2,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  T_a_par [SWE, Slow SW, eV]    :  ',stats,FORMAT=mform[0]                                                         & $
PRINT,';;'


;;----------------------------------------------------------------------------------------
;;  Print stats:  beta_s_avg ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  beta_s_avg Ratio Stats'
PRINT,line0[0]
;;  Print beta_s_avg ratios [Only good SWE and only good 3DP times]
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = beta_avg_epa[*,0,1]                                                                                        & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_avg [SWE, 3DP]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[*,1,1]                                                                                        & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_avg [SWE, 3DP]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[*,2,1]                                                                                        & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_avg [SWE, 3DP]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_ip_shock,0,1]                                                                             & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_avg [3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_ip_shock,1,1]                                                                             & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_avg [SWE, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_ip_shock,2,1]                                                                             & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_avg [SWE, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[in__mo_all,0,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_avg [3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[in__mo_all,1,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_avg [SWE, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[in__mo_all,2,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_avg [SWE, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_mo_all,0,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_avg [3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_mo_all,1,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_avg [SWE, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_mo_all,2,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_avg [SWE, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[good_fast_swe,0,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_avg [3DP, Fast SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[good_fast_swe,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_avg [SWE, Fast SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[good_fast_swe,2,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_avg [SWE, Fast SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[good_slow_swe,0,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_avg [3DP, Slow SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[good_slow_swe,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_avg [SWE, Slow SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[good_slow_swe,2,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_avg [SWE, Slow SW]    :  ',stats,FORMAT=mform[0]                                                          & $
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  beta_s_per ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  beta_s_per Ratio Stats'
PRINT,line0[0]
;;  Print beta_s_per ratios [Only good SWE and only good 3DP times]
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = beta_per_epa[*,0,1]                                                                                        & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_per [SWE, 3DP]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[*,1,1]                                                                                        & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_per [SWE, 3DP]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[*,2,1]                                                                                        & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_per [SWE, 3DP]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_ip_shock,0,1]                                                                             & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_per [3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_ip_shock,1,1]                                                                             & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_per [SWE, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_ip_shock,2,1]                                                                             & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_per [SWE, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[in__mo_all,0,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_per [3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[in__mo_all,1,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_per [SWE, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[in__mo_all,2,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_per [SWE, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_mo_all,0,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_per [3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_mo_all,1,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_per [SWE, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_mo_all,2,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_per [SWE, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[good_fast_swe,0,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_per [3DP, Fast SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[good_fast_swe,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_per [SWE, Fast SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[good_fast_swe,2,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_per [SWE, Fast SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[good_slow_swe,0,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_per [3DP, Slow SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[good_slow_swe,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_per [SWE, Slow SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[good_slow_swe,2,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_per [SWE, Slow SW]    :  ',stats,FORMAT=mform[0]                                                          & $
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  beta_s_par ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  beta_s_par Ratio Stats'
PRINT,line0[0]
;;  Print beta_s_par ratios [Only good SWE and only good 3DP times]
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = beta_par_epa[*,0,1]                                                                                        & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_par [SWE, 3DP]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[*,1,1]                                                                                        & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_par [SWE, 3DP]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[*,2,1]                                                                                        & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_par [SWE, 3DP]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_ip_shock,0,1]                                                                             & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_par [3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_ip_shock,1,1]                                                                             & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_par [SWE, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_ip_shock,2,1]                                                                             & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_par [SWE, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[in__mo_all,0,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_par [3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[in__mo_all,1,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_par [SWE, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[in__mo_all,2,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_par [SWE, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_mo_all,0,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_par [3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_mo_all,1,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_par [SWE, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_mo_all,2,1]                                                                               & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_par [SWE, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[good_fast_swe,0,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_par [3DP, Fast SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[good_fast_swe,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_par [SWE, Fast SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[good_fast_swe,2,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_par [SWE, Fast SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[good_slow_swe,0,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_e_par [3DP, Slow SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[good_slow_swe,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_p_par [SWE, Slow SW]    :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[good_slow_swe,2,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  beta_a_par [SWE, Slow SW]    :  ',stats,FORMAT=mform[0]                                                          & $
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ts1/Ts2)_avg ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ts/Te)_avg Ratio Stats'
PRINT,line0[0]
;;  Print (Ts/Te)_avg ratios [Only good SWE and only good 3DP times]
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = Tr_avg_epeaap[*,0,1,1]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[*,1,1,1]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[*,2,1,1]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_avg [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_ip_shock,0,1,1]                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_ip_shock,1,1,1]                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_ip_shock,2,1,1]                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_avg [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[in__mo_all,0,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[in__mo_all,1,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[in__mo_all,2,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_avg [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_mo_all,0,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_mo_all,1,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_mo_all,2,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_avg [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[good_fast_swe,0,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, Fast SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[good_fast_swe,1,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, Fast SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[good_fast_swe,2,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_avg [SWE, 3DP, Fast SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[good_slow_swe,0,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, Slow SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[good_slow_swe,1,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, Slow SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[good_slow_swe,2,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_avg [SWE, 3DP, Slow SW]    :  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ts1/Ts2)_per ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ts/Te)_per Ratio Stats'
PRINT,line0[0]
;;  Print (Ts1/Ts2)_per ratios [ALL SWE and ALL 3DP times]
;;  Print (Ts/Te)_per ratios [Only good SWE and only good 3DP times]
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = Tr_per_epeaap[*,0,1,1]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[*,1,1,1]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[*,2,1,1]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_per [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_ip_shock,0,1,1]                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_ip_shock,1,1,1]                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_ip_shock,2,1,1]                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_per [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[in__mo_all,0,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[in__mo_all,1,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[in__mo_all,2,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_per [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_mo_all,0,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_mo_all,1,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_mo_all,2,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_per [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[good_fast_swe,0,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, Fast SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[good_fast_swe,1,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, Fast SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[good_fast_swe,2,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_per [SWE, 3DP, Fast SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[good_slow_swe,0,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, Slow SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[good_slow_swe,1,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, Slow SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[good_slow_swe,2,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_per [SWE, 3DP, Slow SW]    :  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ts1/Ts2)_par ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ts/Te)_par Ratio Stats'
PRINT,line0[0]
;;  Print (Ts/Te)_par ratios [Only good SWE and only good 3DP times]
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = Tr_par_epeaap[*,0,1,1]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[*,1,1,1]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[*,2,1,1]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_par [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_ip_shock,0,1,1]                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_ip_shock,1,1,1]                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_ip_shock,2,1,1]                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_par [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[in__mo_all,0,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[in__mo_all,1,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[in__mo_all,2,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_par [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_mo_all,0,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_mo_all,1,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_mo_all,2,1,1]                                                                            & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_par [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[good_fast_swe,0,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, Fast SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[good_fast_swe,1,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, Fast SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[good_fast_swe,2,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_par [SWE, 3DP, Fast SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[good_slow_swe,0,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, Slow SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[good_slow_swe,1,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, Slow SW]    :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[good_slow_swe,2,1,1]                                                                         & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  (Ta/Tp)_par [SWE, 3DP, Slow SW]    :  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Definitions
;;
;;    StdDev.    :  Standard Deviation
;;    StDvMn.    :  Standard Deviation of the Mean
;;    Skew.      :  Skewness (zero = symmetric about maximum)
;;    Kurt.      :  Kurtosis (zero = Gaussian)
;;                    --> degree to which a statistical frequency curve is peaked ("tailedness")
;;    Q1         :  Lower Quartile
;;    Q2         :  Upper Quartile
;;    IQM        :  Interquartile Mean
;;    Tot.  #    :  Total number of all elements sent to function
;;    Fin.  #    :  Total number of finite elements sent to function
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  (Ts)_avg [eV] Stats
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                       Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;============================================================================================================================================================================
;;  T_e_avg [SWE, 3DP, eV]        :    2.43e+00  5.88e+01  1.22e+01  1.19e+01  3.19e+00  3.53e-03  1.04e+00  4.76e+00  1.00e+01  1.40e+01  1.19e+01     2630161      820057
;;  T_p_avg [SWE, 3DP, eV]        :    1.57e-01  9.41e+02  1.27e+01  8.60e+00  1.41e+01  1.35e-02  6.30e+00  1.25e+02  4.67e+00  1.59e+01  9.13e+00     2630161     1095314
;;  T_a_avg [SWE, 3DP, eV]        :    4.49e-01  9.65e+02  2.39e+01  1.08e+01  3.17e+01  4.59e-02  3.76e+00  3.12e+01  4.91e+00  3.16e+01  1.33e+01     2630161      476255
;;  T_e_avg [3DP, No Shocks, eV]  :    2.71e+00  5.27e+01  1.21e+01  1.19e+01  3.00e+00  3.44e-03  6.31e-01  1.77e+00  1.00e+01  1.40e+01  1.19e+01     2435510      760815
;;  T_p_avg [SWE, No Shocks, eV]  :    1.57e-01  8.66e+02  1.24e+01  8.59e+00  1.31e+01  1.31e-02  5.83e+00  1.17e+02  4.66e+00  1.58e+01  9.11e+00     2435510     1001957
;;  T_a_avg [SWE, No Shocks, eV]  :    4.94e-01  9.23e+02  2.31e+01  1.05e+01  2.93e+01  4.48e-02  3.32e+00  2.73e+01  4.84e+00  3.11e+01  1.31e+01     2435510      428536
;;  T_e_avg [3DP, Inside  MOs, eV]:    2.43e+00  5.24e+01  1.11e+01  1.04e+01  4.26e+00  2.49e-02  1.67e+00  6.17e+00  8.18e+00  1.32e+01  1.04e+01      128109       29389
;;  T_p_avg [SWE, Inside  MOs, eV]:    3.93e-01  5.50e+02  7.73e+00  4.16e+00  1.35e+01  5.02e-02  8.22e+00  1.30e+02  2.46e+00  7.53e+00  4.40e+00      128109       72530
;;  T_a_avg [SWE, Inside  MOs, eV]:    4.94e-01  5.25e+02  1.39e+01  5.84e+00  2.23e+01  1.07e-01  4.80e+00  3.88e+01  3.05e+00  1.45e+01  6.73e+00      128109       43343
;;  T_e_avg [3DP, Outside MOs, eV]:    2.71e+00  5.88e+01  1.22e+01  1.19e+01  3.14e+00  3.53e-03  1.01e+00  4.57e+00  1.01e+01  1.40e+01  1.20e+01     2502052      790668
;;  T_p_avg [SWE, Outside MOs, eV]:    1.57e-01  9.41e+02  1.30e+01  8.99e+00  1.41e+01  1.39e-02  6.26e+00  1.27e+02  4.95e+00  1.64e+01  9.53e+00     2502052     1022784
;;  T_a_avg [SWE, Outside MOs, eV]:    4.49e-01  9.65e+02  2.49e+01  1.16e+01  3.23e+01  4.91e-02  3.70e+00  3.06e+01  5.15e+00  3.34e+01  1.43e+01     2502052      432912
;;  T_e_avg [3DP, Fast SW, eV]    :    3.16e+00  5.39e+01  1.22e+01  1.18e+01  3.13e+00  1.27e-02  1.91e+00  1.11e+01  1.03e+01  1.36e+01  1.18e+01      194462       60700
;;  T_p_avg [SWE, Fast SW, eV]    :    4.07e-01  9.41e+02  2.88e+01  2.43e+01  2.35e+01  5.71e-02  4.93e+00  7.30e+01  1.65e+01  3.51e+01  2.48e+01      194462      170001
;;  T_a_avg [SWE, Fast SW, eV]    :    7.20e-01  9.65e+02  5.54e+01  3.19e+01  6.54e+01  3.68e-01  2.48e+00  1.08e+01  8.72e+00  8.01e+01  3.64e+01      194462       31498
;;  T_e_avg [3DP, Slow SW, eV]    :    2.43e+00  5.27e+01  1.13e+01  1.10e+01  2.91e+00  4.64e-03  5.59e-01  8.24e-01  9.26e+00  1.31e+01  1.10e+01      942027      394244
;;  T_p_avg [SWE, Slow SW, eV]    :    1.57e-01  5.78e+02  9.72e+00  7.48e+00  8.75e+00  9.10e-03  6.03e+00  1.29e+02  4.30e+00  1.26e+01  7.75e+00      942027      925313
;;  T_a_avg [SWE, Slow SW, eV]    :    4.49e-01  9.23e+02  2.16e+01  1.02e+01  2.64e+01  3.96e-02  2.87e+00  2.07e+01  4.80e+00  2.93e+01  1.25e+01      942027      444757
;;
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  (Ts)_per [eV] Stats
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                       Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;============================================================================================================================================================================
;;  T_e_per [SWE, 3DP, eV]        :    2.29e+00  7.72e+01  1.32e+01  1.28e+01  3.91e+00  4.32e-03  1.17e+00  5.26e+00  1.05e+01  1.54e+01  1.28e+01     2630161      820057
;;  T_p_per [SWE, 3DP, eV]        :    4.92e-02  1.19e+03  1.25e+01  7.52e+00  1.69e+01  1.59e-02  9.02e+00  2.34e+02  4.23e+00  1.47e+01  8.14e+00     2630161     1124159
;;  T_a_per [SWE, 3DP, eV]        :    2.05e-01  1.20e+03  4.06e+01  2.14e+01  5.22e+01  5.55e-02  3.96e+00  3.68e+01  6.51e+00  5.80e+01  2.49e+01     2630161      883543
;;  T_e_per [3DP, No Shocks, eV]  :    2.59e+00  6.52e+01  1.31e+01  1.28e+01  3.72e+00  4.26e-03  8.71e-01  3.19e+00  1.05e+01  1.54e+01  1.28e+01     2435510      760815
;;  T_p_per [SWE, No Shocks, eV]  :    5.64e-02  1.19e+03  1.22e+01  7.47e+00  1.59e+01  1.57e-02  9.46e+00  2.76e+02  4.22e+00  1.46e+01  8.10e+00     2435510     1028552
;;  T_a_per [SWE, No Shocks, eV]  :    2.05e-01  1.20e+03  3.98e+01  2.13e+01  5.04e+01  5.62e-02  4.03e+00  4.01e+01  6.45e+00  5.75e+01  2.48e+01     2435510      804268
;;  T_e_per [3DP, Inside  MOs, eV]:    2.29e+00  7.72e+01  1.21e+01  1.11e+01  5.40e+00  3.15e-02  2.10e+00  9.26e+00  8.51e+00  1.45e+01  1.12e+01      128109       29389
;;  T_p_per [SWE, Inside  MOs, eV]:    6.19e-02  7.20e+02  7.62e+00  3.94e+00  1.51e+01  5.58e-02  1.05e+01  2.40e+02  2.35e+00  6.87e+00  4.11e+00      128109       73349
;;  T_a_per [SWE, Inside  MOs, eV]:    2.55e-01  1.17e+03  2.25e+01  8.37e+00  4.13e+01  1.64e-01  6.63e+00  8.41e+01  3.66e+00  2.38e+01  1.01e+01      128109       63344
;;  T_e_per [3DP, Outside MOs, eV]:    2.59e+00  6.52e+01  1.32e+01  1.29e+01  3.84e+00  4.32e-03  1.09e+00  4.61e+00  1.05e+01  1.55e+01  1.29e+01     2502052      790668
;;  T_p_per [SWE, Outside MOs, eV]:    4.92e-02  1.19e+03  1.29e+01  7.87e+00  1.69e+01  1.65e-02  9.01e+00  2.35e+02  4.43e+00  1.52e+01  8.50e+00     2502052     1050810
;;  T_a_per [SWE, Outside MOs, eV]:    2.05e-01  1.20e+03  4.20e+01  2.32e+01  5.27e+01  5.82e-02  3.87e+00  3.56e+01  6.90e+00  6.03e+01  2.66e+01     2502052      820199
;;  T_e_per [3DP, Fast SW, eV]    :    3.43e+00  6.05e+01  1.40e+01  1.35e+01  3.84e+00  1.56e-02  1.87e+00  1.04e+01  1.17e+01  1.58e+01  1.35e+01      194462       60700
;;  T_p_per [SWE, Fast SW, eV]    :    6.19e-02  1.19e+03  3.02e+01  2.41e+01  2.87e+01  6.59e-02  6.49e+00  1.16e+02  1.56e+01  3.63e+01  2.46e+01      194462      190139
;;  T_a_per [SWE, Fast SW, eV]    :    2.55e-01  1.19e+03  1.03e+02  9.01e+01  8.41e+01  2.57e-01  2.87e+00  1.85e+01  5.13e+01  1.34e+02  9.11e+01      194462      106751
;;  T_e_per [3DP, Slow SW, eV]    :    2.29e+00  6.42e+01  1.18e+01  1.14e+01  3.29e+00  5.24e-03  7.42e-01  1.42e+00  9.46e+00  1.37e+01  1.14e+01      942027      394244
;;  T_p_per [SWE, Slow SW, eV]    :    4.92e-02  9.11e+02  8.91e+00  6.38e+00  9.88e+00  1.02e-02  1.22e+01  4.40e+02  3.91e+00  1.10e+01  6.72e+00      942027      934011
;;  T_a_per [SWE, Slow SW, eV]    :    2.05e-01  1.20e+03  3.21e+01  1.71e+01  3.91e+01  4.44e-02  3.90e+00  4.55e+01  5.93e+00  4.62e+01  2.01e+01      942027      776792
;;
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  (Ts)_par [eV] Stats
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                       Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;============================================================================================================================================================================
;;  T_e_par [SWE, 3DP, eV]        :    2.49e+00  5.86e+01  1.17e+01  1.14e+01  2.99e+00  3.30e-03  1.05e+00  4.72e+00  9.66e+00  1.34e+01  1.14e+01     2630161      820057
;;  T_p_par [SWE, 3DP, eV]        :    4.74e-02  1.20e+03  1.54e+01  1.07e+01  1.80e+01  1.72e-02  1.01e+01  3.30e+02  5.19e+00  2.00e+01  1.13e+01     2630161     1103884
;;  T_a_par [SWE, 3DP, eV]        :    2.27e-01  1.19e+03  3.73e+01  1.48e+01  5.59e+01  7.44e-02  4.91e+00  4.84e+01  5.42e+00  5.07e+01  1.94e+01     2630161      564208
;;  T_e_par [3DP, No Shocks, eV]  :    2.74e+00  4.69e+01  1.16e+01  1.13e+01  2.80e+00  3.21e-03  6.15e-01  1.34e+00  9.67e+00  1.33e+01  1.14e+01     2435510      760815
;;  T_p_par [SWE, No Shocks, eV]  :    5.25e-02  1.17e+03  1.51e+01  1.08e+01  1.68e+01  1.67e-02  1.04e+01  3.71e+02  5.21e+00  1.99e+01  1.14e+01     2435510     1009757
;;  T_a_par [SWE, No Shocks, eV]  :    2.27e-01  1.19e+03  3.73e+01  1.49e+01  5.54e+01  7.75e-02  4.93e+00  4.93e+01  5.37e+00  5.13e+01  1.96e+01     2435510      512190
;;  T_e_par [3DP, Inside  MOs, eV]:    2.49e+00  5.20e+01  1.06e+01  9.98e+00  3.80e+00  2.22e-02  1.48e+00  5.14e+00  7.95e+00  1.24e+01  1.00e+01      128109       29389
;;  T_p_par [SWE, Inside  MOs, eV]:    4.74e-02  1.20e+03  9.74e+00  4.36e+00  2.13e+01  7.89e-02  1.59e+01  6.04e+02  2.54e+00  8.91e+00  4.77e+00      128109       73149
;;  T_a_par [SWE, Inside  MOs, eV]:    2.27e-01  1.14e+03  1.77e+01  5.83e+00  4.21e+01  1.97e-01  9.43e+00  1.48e+02  3.05e+00  1.42e+01  6.60e+00      128109       45878
;;  T_e_par [3DP, Outside MOs, eV]:    2.74e+00  5.86e+01  1.17e+01  1.14e+01  2.94e+00  3.31e-03  1.05e+00  4.71e+00  9.71e+00  1.34e+01  1.15e+01     2502052      790668
;;  T_p_par [SWE, Outside MOs, eV]:    5.25e-02  1.13e+03  1.58e+01  1.13e+01  1.77e+01  1.74e-02  9.45e+00  2.91e+02  5.60e+00  2.05e+01  1.19e+01     2502052     1030735
;;  T_a_par [SWE, Outside MOs, eV]:    2.28e-01  1.19e+03  3.90e+01  1.66e+01  5.66e+01  7.87e-02  4.76e+00  4.58e+01  5.79e+00  5.39e+01  2.12e+01     2502052      518330
;;  T_e_par [3DP, Fast SW, eV]    :    2.83e+00  5.06e+01  1.13e+01  1.09e+01  2.96e+00  1.20e-02  1.89e+00  1.06e+01  9.40e+00  1.26e+01  1.09e+01      194462       60700
;;  T_p_par [SWE, Fast SW, eV]    :    4.74e-02  1.20e+03  3.27e+01  2.75e+01  2.94e+01  7.05e-02  7.12e+00  1.46e+02  1.77e+01  3.95e+01  2.79e+01      194462      173564
;;  T_a_par [SWE, Fast SW, eV]    :    3.25e-01  1.19e+03  9.52e+01  6.53e+01  1.18e+02  5.50e-01  3.01e+00  1.40e+01  1.24e+01  1.31e+02  6.55e+01      194462       45993
;;  T_e_par [3DP, Slow SW, eV]    :    2.49e+00  4.69e+01  1.10e+01  1.08e+01  2.78e+00  4.43e-03  5.32e-01  7.39e-01  9.13e+00  1.27e+01  1.08e+01      942027      394244
;;  T_p_par [SWE, Slow SW, eV]    :    5.40e-02  1.17e+03  1.22e+01  9.22e+00  1.26e+01  1.31e-02  1.43e+01  7.37e+02  4.71e+00  1.62e+01  9.59e+00      942027      930320
;;  T_a_par [SWE, Slow SW, eV]    :    2.27e-01  1.17e+03  3.22e+01  1.34e+01  4.29e+01  5.96e-02  3.68e+00  3.55e+01  5.24e+00  4.52e+01  1.75e+01      942027      518215
;;
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  beta_s_avg Ratio Stats
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                      Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;============================================================================================================================================================================
;;  beta_e_avg [SWE, 3DP]        :    5.93e-03  8.87e+03  2.31e+00  1.09e+00  1.76e+01  1.94e-02  2.29e+02  9.16e+04  6.40e-01  1.99e+00  1.16e+00     2630161      820056
;;  beta_p_avg [SWE, 3DP]        :    9.51e-04  4.57e+03  1.79e+00  1.05e+00  1.14e+01  1.09e-02  1.82e+02  5.24e+04  5.39e-01  1.77e+00  1.08e+00     2630161     1095171
;;  beta_a_avg [SWE, 3DP]        :    4.88e-05  6.12e+02  1.68e-01  5.23e-02  1.35e+00  1.96e-03  2.52e+02  9.70e+04  1.68e-02  1.73e-01  6.62e-02     2630161      476129
;;  beta_e_avg [3DP, No Shocks]  :    5.93e-03  8.87e+03  2.35e+00  1.11e+00  1.82e+01  2.08e-02  2.24e+02  8.67e+04  6.54e-01  2.01e+00  1.18e+00     2435510      760814
;;  beta_p_avg [SWE, No Shocks]  :    1.38e-03  4.57e+03  1.81e+00  1.07e+00  1.16e+01  1.16e-02  1.85e+02  5.30e+04  5.66e-01  1.78e+00  1.10e+00     2435510     1001816
;;  beta_a_avg [SWE, No Shocks]  :    4.88e-05  2.95e+02  1.64e-01  5.33e-02  9.86e-01  1.51e-03  1.42e+02  3.13e+04  1.73e-02  1.76e-01  6.74e-02     2435510      428411
;;  beta_e_avg [3DP, Inside  MOs]:    5.93e-03  3.72e+01  5.22e-01  3.95e-01  6.48e-01  3.78e-03  1.33e+01  4.92e+02  2.32e-01  6.19e-01  4.03e-01      128109       29389
;;  beta_p_avg [SWE, Inside  MOs]:    9.51e-04  1.60e+02  2.92e-01  1.26e-01  1.11e+00  4.14e-03  7.20e+01  8.27e+03  4.58e-02  3.11e-01  1.42e-01      128109       72530
;;  beta_a_avg [SWE, Inside  MOs]:    4.88e-05  2.94e+01  2.88e-02  7.90e-03  1.73e-01  8.29e-04  1.19e+02  1.95e+04  3.45e-03  2.17e-02  9.30e-03      128109       43343
;;  beta_e_avg [3DP, Outside MOs]:    2.40e-02  8.87e+03  2.38e+00  1.13e+00  1.79e+01  2.01e-02  2.25e+02  8.84e+04  6.69e-01  2.04e+00  1.20e+00     2502052      790667
;;  beta_p_avg [SWE, Outside MOs]:    2.06e-03  4.57e+03  1.90e+00  1.11e+00  1.18e+01  1.16e-02  1.76e+02  4.91e+04  6.27e-01  1.85e+00  1.15e+00     2502052     1022641
;;  beta_a_avg [SWE, Outside MOs]:    1.75e-04  6.12e+02  1.82e-01  6.23e-02  1.42e+00  2.15e-03  2.41e+02  8.86e+04  2.09e-02  1.90e-01  7.65e-02     2502052      432786
;;  beta_e_avg [3DP, Fast SW]    :    1.68e-02  6.81e+02  1.05e+00  7.28e-01  3.90e+00  1.58e-02  1.05e+02  1.61e+04  5.11e-01  1.08e+00  7.48e-01      194462       60700
;;  beta_p_avg [SWE, Fast SW]    :    9.51e-04  2.35e+03  1.80e+00  1.25e+00  8.49e+00  2.06e-02  1.63e+02  3.87e+04  6.98e-01  1.95e+00  1.27e+00      194462      169997
;;  beta_a_avg [SWE, Fast SW]    :    1.90e-04  6.12e+02  3.10e-01  7.66e-02  4.01e+00  2.26e-02  1.23e+02  1.77e+04  1.58e-02  2.84e-01  1.02e-01      194462       31497
;;  beta_e_avg [3DP, Slow SW]    :    1.29e-02  4.33e+03  3.35e+00  1.61e+00  1.81e+01  2.87e-02  9.27e+01  1.49e+04  9.43e-01  2.88e+00  1.70e+00      942027      394244
;;  beta_p_avg [SWE, Slow SW]    :    1.38e-03  4.57e+03  1.79e+00  1.01e+00  1.18e+01  1.23e-02  1.80e+02  5.12e+04  5.19e-01  1.73e+00  1.04e+00      942027      925174
;;  beta_a_avg [SWE, Slow SW]    :    4.88e-05  2.95e+02  1.58e-01  5.14e-02  9.04e-01  1.36e-03  1.41e+02  3.34e+04  1.69e-02  1.67e-01  6.45e-02      942027      444632
;;
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  beta_s_per Ratio Stats
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                      Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;============================================================================================================================================================================
;;  beta_e_per [SWE, 3DP]        :    6.92e-03  8.91e+03  2.37e+00  1.17e+00  1.76e+01  1.94e-02  2.32e+02  9.33e+04  7.13e-01  2.06e+00  1.24e+00     2630161      820056
;;  beta_p_per [SWE, 3DP]        :    3.71e-05  4.39e+03  1.70e+00  9.22e-01  1.13e+01  1.07e-02  1.80e+02  5.14e+04  4.71e-01  1.62e+00  9.60e-01     2630161     1124001
;;  beta_a_per [SWE, 3DP]        :    5.14e-05  5.95e+02  1.93e-01  8.05e-02  1.23e+00  1.31e-03  2.31e+02  8.52e+04  2.11e-02  2.16e-01  9.27e-02     2630161      883409
;;  beta_e_per [3DP, No Shocks]  :    6.92e-03  8.91e+03  2.42e+00  1.19e+00  1.81e+01  2.08e-02  2.26e+02  8.83e+04  7.30e-01  2.07e+00  1.25e+00     2435510      760814
;;  beta_p_per [SWE, No Shocks]  :    8.47e-05  4.39e+03  1.71e+00  9.39e-01  1.16e+01  1.14e-02  1.83e+02  5.16e+04  4.93e-01  1.63e+00  9.76e-01     2435510     1028396
;;  beta_a_per [SWE, No Shocks]  :    7.58e-05  3.73e+02  1.91e-01  8.33e-02  1.04e+00  1.16e-03  1.74e+02  4.83e+04  2.18e-02  2.19e-01  9.51e-02     2435510      804136
;;  beta_e_per [3DP, Inside  MOs]:    6.92e-03  3.86e+01  5.58e-01  4.23e-01  6.77e-01  3.95e-03  1.28e+01  4.68e+02  2.51e-01  6.61e-01  4.34e-01      128109       29389
;;  beta_p_per [SWE, Inside  MOs]:    3.71e-05  1.58e+02  2.76e-01  1.21e-01  1.11e+00  4.09e-03  7.19e+01  8.18e+03  4.29e-02  2.91e-01  1.34e-01      128109       73349
;;  beta_a_per [SWE, Inside  MOs]:    5.16e-05  4.98e+01  3.54e-02  9.08e-03  2.53e-01  1.00e-03  1.44e+02  2.62e+04  3.35e-03  2.82e-02  1.10e-02      128109       63344
;;  beta_e_per [3DP, Outside MOs]:    2.76e-02  8.91e+03  2.44e+00  1.21e+00  1.79e+01  2.01e-02  2.28e+02  9.00e+04  7.44e-01  2.10e+00  1.27e+00     2502052      790667
;;  beta_p_per [SWE, Outside MOs]:    2.59e-04  4.39e+03  1.80e+00  9.85e-01  1.17e+01  1.14e-02  1.75e+02  4.83e+04  5.45e-01  1.69e+00  1.03e+00     2502052     1050652
;;  beta_a_per [SWE, Outside MOs]:    5.14e-05  5.95e+02  2.05e-01  9.24e-02  1.27e+00  1.41e-03  2.24e+02  7.98e+04  2.56e-02  2.29e-01  1.03e-01     2502052      820065
;;  beta_e_per [3DP, Fast SW]    :    1.70e-02  7.10e+02  1.16e+00  8.38e-01  4.01e+00  1.63e-02  1.09e+02  1.71e+04  6.06e-01  1.20e+00  8.59e-01      194462       60700
;;  beta_p_per [SWE, Fast SW]    :    3.71e-05  2.20e+03  1.79e+00  1.21e+00  8.91e+00  2.04e-02  1.42e+02  2.85e+04  6.83e-01  1.89e+00  1.23e+00      194462      190122
;;  beta_a_per [SWE, Fast SW]    :    5.16e-05  5.95e+02  3.39e-01  2.12e-01  2.23e+00  6.83e-03  1.95e+02  4.85e+04  9.86e-02  3.71e-01  2.19e-01      194462      106749
;;  beta_e_per [3DP, Slow SW]    :    1.39e-02  4.33e+03  3.41e+00  1.67e+00  1.80e+01  2.86e-02  9.29e+01  1.51e+04  1.00e+00  2.93e+00  1.76e+00      942027      394244
;;  beta_p_per [SWE, Slow SW]    :    6.14e-04  4.39e+03  1.68e+00  8.66e-01  1.18e+01  1.22e-02  1.81e+02  5.14e+04  4.47e-01  1.55e+00  9.06e-01      942027      933870
;;  beta_a_per [SWE, Slow SW]    :    5.14e-05  3.73e+02  1.73e-01  6.76e-02  1.02e+00  1.15e-03  1.81e+02  5.24e+04  1.90e-02  1.89e-01  7.94e-02      942027      776660
;;
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  beta_s_par Ratio Stats
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                      Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;============================================================================================================================================================================
;;  beta_e_par [SWE, 3DP]        :    5.44e-03  8.85e+03  2.28e+00  1.05e+00  1.76e+01  1.94e-02  2.28e+02  9.07e+04  6.01e-01  1.96e+00  1.12e+00     2630161      820056
;;  beta_p_par [SWE, 3DP]        :    5.66e-05  4.92e+03  2.05e+00  1.29e+00  1.16e+01  1.10e-02  1.79e+02  5.27e+04  6.19e-01  2.18e+00  1.33e+00     2630161     1103741
;;  beta_a_par [SWE, 3DP]        :    2.15e-05  6.48e+02  2.24e-01  7.18e-02  1.49e+00  1.99e-03  2.40e+02  8.36e+04  1.90e-02  2.66e-01  9.48e-02     2630161      564081
;;  beta_e_par [3DP, No Shocks]  :    5.44e-03  8.85e+03  2.32e+00  1.07e+00  1.82e+01  2.08e-02  2.23e+02  8.59e+04  6.14e-01  1.98e+00  1.14e+00     2435510      760814
;;  beta_p_par [SWE, No Shocks]  :    1.13e-04  4.92e+03  2.07e+00  1.32e+00  1.17e+01  1.17e-02  1.83e+02  5.38e+04  6.58e-01  2.20e+00  1.35e+00     2435510     1009616
;;  beta_a_par [SWE, No Shocks]  :    2.15e-05  4.15e+02  2.25e-01  7.50e-02  1.20e+00  1.68e-03  1.85e+02  5.26e+04  1.98e-02  2.76e-01  9.88e-02     2435510      512064
;;  beta_e_par [3DP, Inside  MOs]:    5.44e-03  3.65e+01  5.05e-01  3.80e-01  6.35e-01  3.70e-03  1.35e+01  5.01e+02  2.18e-01  5.96e-01  3.87e-01      128109       29389
;;  beta_p_par [SWE, Inside  MOs]:    5.66e-05  1.65e+02  3.44e-01  1.30e-01  1.18e+00  4.36e-03  6.32e+01  7.00e+03  4.74e-02  3.49e-01  1.52e-01      128109       73149
;;  beta_a_par [SWE, Inside  MOs]:    2.15e-05  3.21e+01  3.43e-02  7.45e-03  1.92e-01  8.98e-04  1.06e+02  1.70e+04  3.21e-03  2.18e-02  8.98e-03      128109       45878
;;  beta_e_par [3DP, Outside MOs]:    1.94e-02  8.85e+03  2.34e+00  1.09e+00  1.79e+01  2.01e-02  2.24e+02  8.75e+04  6.29e-01  2.01e+00  1.16e+00     2502052      790667
;;  beta_p_par [SWE, Outside MOs]:    1.44e-04  4.92e+03  2.17e+00  1.38e+00  1.20e+01  1.18e-02  1.74e+02  4.94e+04  7.35e-01  2.27e+00  1.42e+00     2502052     1030592
;;  beta_a_par [SWE, Outside MOs]:    5.87e-05  6.48e+02  2.41e-01  8.61e-02  1.56e+00  2.16e-03  2.31e+02  7.72e+04  2.38e-02  2.91e-01  1.10e-01     2502052      518203
;;  beta_e_par [3DP, Fast SW]    :    1.67e-02  6.66e+02  9.95e-01  6.73e-01  3.85e+00  1.56e-02  1.04e+02  1.57e+04  4.61e-01  1.02e+00  6.93e-01      194462       60700
;;  beta_p_par [SWE, Fast SW]    :    5.66e-05  2.65e+03  2.01e+00  1.40e+00  9.25e+00  2.22e-02  1.69e+02  4.21e+04  7.11e-01  2.28e+00  1.43e+00      194462      173560
;;  beta_a_par [SWE, Fast SW]    :    8.44e-05  6.48e+02  4.14e-01  1.72e-01  3.60e+00  1.68e-02  1.41e+02  2.36e+04  2.41e-02  5.00e-01  2.03e-01      194462       45991
;;  beta_e_par [3DP, Slow SW]    :    1.23e-02  4.33e+03  3.33e+00  1.58e+00  1.81e+01  2.88e-02  9.26e+01  1.48e+04  9.12e-01  2.85e+00  1.67e+00      942027      394244
;;  beta_p_par [SWE, Slow SW]    :    1.13e-04  4.92e+03  2.05e+00  1.27e+00  1.20e+01  1.24e-02  1.78e+02  5.21e+04  6.05e-01  2.17e+00  1.31e+00      942027      930181
;;  beta_a_par [SWE, Slow SW]    :    2.15e-05  4.15e+02  2.07e-01  6.78e-02  1.13e+00  1.57e-03  1.99e+02  6.18e+04  1.88e-02  2.48e-01  8.88e-02      942027      518090
;;
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  (Ts/Te)_avg Ratio Stats
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                            Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;============================================================================================================================================================================
;;  (Te/Tp)_avg [SWE, 3DP, ALL]        :    6.52e-02  2.53e+01  1.64e+00  1.27e+00  1.26e+00  1.88e-03  2.23e+00  1.05e+01  7.77e-01  2.14e+00  1.33e+00     2630161      445801
;;  (Te/Ta)_avg [SWE, 3DP, ALL]        :    2.24e-02  2.29e+01  1.24e+00  8.19e-01  1.25e+00  2.84e-03  2.08e+00  7.46e+00  3.23e-01  1.78e+00  8.97e-01     2630161      193704
;;  (Ta/Tp)_avg [SWE, 3DP, ALL]        :    2.44e-02  1.90e+01  2.50e+00  1.94e+00  1.45e+00  2.10e-03  1.02e+00  4.64e-01  1.35e+00  3.49e+00  2.10e+00     2630161      476255
;;  (Te/Tp)_avg [SWE, 3DP, No Shocks]  :    6.52e-02  2.53e+01  1.64e+00  1.27e+00  1.25e+00  1.95e-03  2.23e+00  1.07e+01  7.79e-01  2.14e+00  1.33e+00     2435510      412947
;;  (Te/Ta)_avg [SWE, 3DP, No Shocks]  :    2.29e-02  2.29e+01  1.26e+00  8.24e-01  1.26e+00  3.00e-03  2.08e+00  7.54e+00  3.23e-01  1.80e+00  9.04e-01     2435510      177265
;;  (Ta/Tp)_avg [SWE, 3DP, No Shocks]  :    2.44e-02  1.90e+01  2.49e+00  1.91e+00  1.45e+00  2.21e-03  1.01e+00  4.25e-01  1.33e+00  3.48e+00  2.08e+00     2435510      428536
;;  (Te/Tp)_avg [SWE, 3DP, Inside  MOs]:    9.38e-02  2.53e+01  2.55e+00  2.06e+00  1.93e+00  1.43e-02  2.77e+00  1.62e+01  1.27e+00  3.33e+00  2.15e+00      128109       18203
;;  (Te/Ta)_avg [SWE, 3DP, Inside  MOs]:    4.11e-02  2.29e+01  1.87e+00  1.45e+00  1.69e+00  1.68e-02  2.12e+00  9.34e+00  6.00e-01  2.65e+00  1.50e+00      128109       10077
;;  (Ta/Tp)_avg [SWE, 3DP, Inside  MOs]:    2.44e-02  1.83e+01  2.27e+00  1.78e+00  1.33e+00  6.38e-03  1.64e+00  3.65e+00  1.34e+00  2.80e+00  1.87e+00      128109       43343
;;  (Te/Tp)_avg [SWE, 3DP, Outside MOs]:    6.52e-02  2.32e+01  1.60e+00  1.25e+00  1.20e+00  1.84e-03  1.98e+00  6.66e+00  7.66e-01  2.09e+00  1.30e+00     2502052      427598
;;  (Te/Ta)_avg [SWE, 3DP, Outside MOs]:    2.24e-02  1.72e+01  1.21e+00  7.90e-01  1.21e+00  2.83e-03  2.00e+00  6.33e+00  3.16e-01  1.74e+00  8.70e-01     2502052      183627
;;  (Ta/Tp)_avg [SWE, 3DP, Outside MOs]:    1.79e-01  1.90e+01  2.52e+00  1.96e+00  1.46e+00  2.22e-03  9.64e-01  2.57e-01  1.35e+00  3.55e+00  2.13e+00     2502052      432912
;;  (Te/Tp)_avg [SWE, 3DP, Fast SW]    :    6.52e-02  1.73e+01  6.22e-01  4.86e-01  6.70e-01  2.85e-03  7.49e+00  8.54e+01  3.58e-01  6.58e-01  4.92e-01      194462       55111
;;  (Te/Ta)_avg [SWE, 3DP, Fast SW]    :    2.24e-02  9.51e+00  4.68e-01  1.91e-01  7.34e-01  7.74e-03  3.90e+00  2.06e+01  1.22e-01  4.50e-01  2.19e-01      194462        9002
;;  (Ta/Tp)_avg [SWE, 3DP, Fast SW]    :    2.99e-02  1.64e+01  3.31e+00  3.18e+00  1.51e+00  8.50e-03  4.51e-01 -1.80e-01  1.98e+00  4.49e+00  3.18e+00      194462       31498
;;  (Te/Tp)_avg [SWE, 3DP, Slow SW]    :    9.53e-02  2.53e+01  1.78e+00  1.42e+00  1.25e+00  2.00e-03  2.23e+00  1.08e+01  9.15e-01  2.28e+00  1.48e+00      942027      390690
;;  (Te/Ta)_avg [SWE, 3DP, Slow SW]    :    3.94e-02  2.29e+01  1.28e+00  8.69e-01  1.26e+00  2.92e-03  2.05e+00  7.37e+00  3.48e-01  1.83e+00  9.41e-01      942027      184702
;;  (Ta/Tp)_avg [SWE, 3DP, Slow SW]    :    2.44e-02  1.90e+01  2.44e+00  1.87e+00  1.43e+00  2.14e-03  1.07e+00  6.07e-01  1.33e+00  3.37e+00  2.04e+00      942027      444757
;;
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  (Ts/Te)_per Ratio Stats
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                            Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;============================================================================================================================================================================
;;  (Te/Tp)_per [SWE, 3DP, ALL]        :    2.95e-02  1.85e+02  1.89e+00  1.51e+00  1.49e+00  2.20e-03  1.24e+01  1.09e+03  9.03e-01  2.49e+00  1.57e+00     2630161      454588
;;  (Te/Ta)_per [SWE, 3DP, ALL]        :    1.16e-02  4.23e+01  9.94e-01  4.85e-01  1.20e+00  1.91e-03  3.12e+00  2.72e+01  2.11e-01  1.41e+00  5.98e-01     2630161      393745
;;  (Ta/Tp)_per [SWE, 3DP, ALL]        :    3.58e-03  2.00e+02  3.47e+00  3.16e+00  2.25e+00  2.39e-03  3.90e+00  1.15e+02  1.63e+00  4.79e+00  3.14e+00     2630161      883427
;;  (Te/Tp)_per [SWE, 3DP, No Shocks]  :    5.73e-02  1.85e+02  1.90e+00  1.52e+00  1.48e+00  2.28e-03  1.30e+01  1.18e+03  9.08e-01  2.51e+00  1.58e+00     2435510      421080
;;  (Te/Ta)_per [SWE, 3DP, No Shocks]  :    1.16e-02  4.23e+01  9.96e-01  4.83e-01  1.20e+00  1.99e-03  3.11e+00  2.80e+01  2.12e-01  1.42e+00  5.98e-01     2435510      363851
;;  (Ta/Tp)_per [SWE, 3DP, No Shocks]  :    1.10e-02  2.00e+02  3.45e+00  3.16e+00  2.21e+00  2.47e-03  3.98e+00  1.28e+02  1.62e+00  4.77e+00  3.14e+00     2435510      804166
;;  (Te/Tp)_per [SWE, 3DP, Inside  MOs]:    1.10e-01  7.94e+01  2.96e+00  2.35e+00  2.41e+00  1.78e-02  4.59e+00  7.24e+01  1.46e+00  3.76e+00  2.44e+00      128109       18356
;;  (Te/Ta)_per [SWE, 3DP, Inside  MOs]:    1.80e-02  4.23e+01  1.69e+00  1.02e+00  2.01e+00  1.56e-02  3.94e+00  3.82e+01  3.76e-01  2.35e+00  1.13e+00      128109       16643
;;  (Ta/Tp)_per [SWE, 3DP, Inside  MOs]:    3.58e-03  7.98e+01  3.20e+00  2.27e+00  2.69e+00  1.07e-02  4.28e+00  5.01e+01  1.46e+00  4.19e+00  2.47e+00      128109       63318
;;  (Te/Tp)_per [SWE, 3DP, Outside MOs]:    2.95e-02  1.85e+02  1.84e+00  1.49e+00  1.42e+00  2.14e-03  1.38e+01  1.35e+03  8.90e-01  2.45e+00  1.55e+00     2502052      436232
;;  (Te/Ta)_per [SWE, 3DP, Outside MOs]:    1.16e-02  3.76e+01  9.63e-01  4.69e-01  1.14e+00  1.86e-03  2.65e+00  1.56e+01  2.08e-01  1.37e+00  5.80e-01     2502052      377102
;;  (Ta/Tp)_per [SWE, 3DP, Outside MOs]:    1.10e-02  2.00e+02  3.49e+00  3.24e+00  2.21e+00  2.44e-03  3.84e+00  1.25e+02  1.65e+00  4.81e+00  3.20e+00     2502052      820109
;;  (Te/Tp)_per [SWE, 3DP, Fast SW]    :    2.95e-02  8.67e+01  7.59e-01  5.77e-01  1.02e+00  4.14e-03  2.81e+01  1.88e+03  4.13e-01  8.05e-01  5.86e-01      194462       60628
;;  (Te/Ta)_per [SWE, 3DP, Fast SW]    :    1.24e-02  4.21e+01  2.45e-01  1.40e-01  5.50e-01  2.74e-03  1.82e+01  9.19e+02  1.00e-01  2.00e-01  1.42e-01      194462       40295
;;  (Ta/Tp)_per [SWE, 3DP, Fast SW]    :    3.58e-03  2.00e+02  4.55e+00  4.45e+00  2.23e+00  6.82e-03  1.08e+01  6.29e+02  3.43e+00  5.40e+00  4.44e+00      194462      106725
;;  (Te/Tp)_per [SWE, 3DP, Slow SW]    :    1.14e-01  1.85e+02  2.06e+00  1.70e+00  1.47e+00  2.34e-03  1.32e+01  1.25e+03  1.08e+00  2.66e+00  1.76e+00      942027      393960
;;  (Te/Ta)_per [SWE, 3DP, Slow SW]    :    1.16e-02  4.23e+01  1.08e+00  5.89e-01  1.22e+00  2.06e-03  2.94e+00  2.33e+01  2.52e-01  1.55e+00  6.96e-01      942027      353450
;;  (Ta/Tp)_per [SWE, 3DP, Slow SW]    :    1.10e-02  1.34e+02  3.32e+00  2.84e+00  2.21e+00  2.51e-03  3.13e+00  4.89e+01  1.55e+00  4.64e+00  2.92e+00      942027      776702
;;
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  (Ts/Te)_par Ratio Stats
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                            Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;============================================================================================================================================================================
;;  (Te/Tp)_par [SWE, 3DP, ALL]        :    2.05e-02  1.61e+02  1.44e+00  1.01e+00  1.47e+00  2.20e-03  1.52e+01  8.79e+02  6.02e-01  1.83e+00  1.07e+00     2630161      445732
;;  (Te/Ta)_par [SWE, 3DP, ALL]        :    9.29e-03  4.58e+01  1.14e+00  6.42e-01  1.34e+00  2.94e-03  3.48e+00  3.89e+01  2.28e-01  1.62e+00  7.36e-01     2630161      207313
;;  (Ta/Tp)_par [SWE, 3DP, ALL]        :    1.66e-02  2.72e+02  2.86e+00  2.11e+00  2.40e+00  3.19e-03  7.29e+00  3.45e+02  1.33e+00  3.87e+00  2.29e+00     2630161      564072
;;  (Te/Tp)_par [SWE, 3DP, No Shocks]  :    2.05e-02  1.61e+02  1.43e+00  1.00e+00  1.46e+00  2.28e-03  1.55e+01  9.32e+02  6.03e-01  1.82e+00  1.07e+00     2435510      412917
;;  (Te/Ta)_par [SWE, 3DP, No Shocks]  :    9.29e-03  4.58e+01  1.14e+00  6.36e-01  1.34e+00  3.08e-03  3.42e+00  3.81e+01  2.25e-01  1.63e+00  7.34e-01     2435510      190413
;;  (Ta/Tp)_par [SWE, 3DP, No Shocks]  :    1.66e-02  2.72e+02  2.88e+00  2.12e+00  2.45e+00  3.42e-03  7.42e+00  3.50e+02  1.32e+00  3.92e+00  2.30e+00     2435510      512077
;;  (Te/Tp)_par [SWE, 3DP, Inside  MOs]:    3.17e-02  1.61e+02  2.38e+00  1.87e+00  2.60e+00  1.93e-02  2.02e+01  9.54e+02  1.09e+00  3.13e+00  1.95e+00      128109       18186
;;  (Te/Ta)_par [SWE, 3DP, Inside  MOs]:    1.84e-02  3.00e+01  1.82e+00  1.34e+00  1.82e+00  1.79e-02  3.16e+00  2.31e+01  5.75e-01  2.55e+00  1.41e+00      128109       10290
;;  (Ta/Tp)_par [SWE, 3DP, Inside  MOs]:    4.44e-02  4.03e+01  2.17e+00  1.66e+00  1.64e+00  7.68e-03  3.99e+00  3.76e+01  1.22e+00  2.58e+00  1.73e+00      128109       45837
;;  (Te/Tp)_par [SWE, 3DP, Outside MOs]:    2.05e-02  1.29e+02  1.40e+00  9.87e-01  1.39e+00  2.12e-03  1.30e+01  6.41e+02  5.94e-01  1.77e+00  1.05e+00     2502052      427546
;;  (Te/Ta)_par [SWE, 3DP, Outside MOs]:    9.29e-03  4.58e+01  1.10e+00  6.11e-01  1.30e+00  2.92e-03  3.47e+00  4.07e+01  2.22e-01  1.57e+00  7.07e-01     2502052      197023
;;  (Ta/Tp)_par [SWE, 3DP, Outside MOs]:    1.66e-02  2.72e+02  2.92e+00  2.18e+00  2.44e+00  3.39e-03  7.34e+00  3.47e+02  1.34e+00  3.97e+00  2.35e+00     2502052      518235
;;  (Te/Tp)_par [SWE, 3DP, Fast SW]    :    2.05e-02  6.84e+01  5.44e-01  3.93e-01  9.44e-01  4.02e-03  2.90e+01  1.47e+03  2.90e-01  5.39e-01  3.99e-01      194462       55125
;;  (Te/Ta)_par [SWE, 3DP, Fast SW]    :    9.29e-03  2.67e+01  4.34e-01  1.45e-01  9.17e-01  8.61e-03  9.08e+00  1.62e+02  8.58e-02  3.60e-01  1.65e-01      194462       11339
;;  (Ta/Tp)_par [SWE, 3DP, Fast SW]    :    4.44e-02  5.89e+01  4.12e+00  3.31e+00  4.19e+00  1.95e-02  4.64e+00  3.06e+01  1.89e+00  4.83e+00  3.31e+00      194462       45980
;;  (Te/Tp)_par [SWE, 3DP, Slow SW]    :    3.17e-02  1.61e+02  1.56e+00  1.13e+00  1.49e+00  2.38e-03  1.56e+01  9.21e+02  7.07e-01  1.98e+00  1.20e+00      942027      390607
;;  (Te/Ta)_par [SWE, 3DP, Slow SW]    :    1.65e-02  4.58e+01  1.18e+00  6.95e-01  1.35e+00  3.04e-03  3.41e+00  3.80e+01  2.49e-01  1.68e+00  7.83e-01      942027      195974
;;  (Ta/Tp)_par [SWE, 3DP, Slow SW]    :    1.66e-02  2.72e+02  2.75e+00  2.02e+00  2.13e+00  2.96e-03  7.68e+00  5.53e+02  1.30e+00  3.75e+00  2.20e+00      942027      518092
;;
;;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------






























