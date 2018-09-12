;;  @/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/print_wind_3dp_swe_onevar_stats_batch.pro
;;
;;  Note:  User must call the following prior to running this batch file
;;         @/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_batch.pro

test           = (N_ELEMENTS(Te_Tp_avg_aan) LT 2) OR (is_a_number(Te_Tp_avg_aan,/NOMSSG) EQ 0)
IF (test[0]) THEN STOP
;;----------------------------------------------------------------------------------------
;;  Print one-variable stats
;;----------------------------------------------------------------------------------------
line0          = ';;----------------------------------------------------------------------------------------'
line1          = ';;========================================================================================'
mform          = '(a44,6e10.2)'
;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ts/Te)_avg # of values
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  Number of Values'
PRINT,line0[0]
;;  Print # of values (Ts/Te)_avg ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_avg_aan                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [ALL, ALL, ALL]        :  ',stats                                                                   & $
x              = Te_Ta_avg_aan                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [ALL, ALL, ALL]        :  ',stats                                                                   & $
x              = Te_Tp_avg_aas                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [ALL, ALL, No Shocks]  :  ',stats                                                                   & $
x              = Te_Ta_avg_aas                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [ALL, ALL, No Shocks]  :  ',stats                                                                   & $
x              = Te_Tp_avg_aaio                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [ALL, ALL, Inside  MOs]:  ',stats                                                                   & $
x              = Te_Ta_avg_aaio                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [ALL, ALL, Inside  MOs]:  ',stats                                                                   & $
x              = Te_Tp_avg_aaoo                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [ALL, ALL, Outside MOs]:  ',stats                                                                   & $
x              = Te_Ta_avg_aaoo                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [ALL, ALL, Outside MOs]:  ',stats                                                                   & $
PRINT,';;'

;;  Print # of values (Ts/Te)_avg ratios [ALL SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_avg_a3n                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [ALL, 3DP, ALL]        :  ',stats                                                                   & $
x              = Te_Ta_avg_a3n                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [ALL, 3DP, ALL]        :  ',stats                                                                   & $
x              = Te_Tp_avg_a3s                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [ALL, 3DP, No Shocks]  :  ',stats                                                                   & $
x              = Te_Ta_avg_a3s                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [ALL, 3DP, No Shocks]  :  ',stats                                                                   & $
x              = Te_Tp_avg_a3io                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [ALL, 3DP, Inside  MOs]:  ',stats                                                                   & $
x              = Te_Ta_avg_a3io                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [ALL, 3DP, Inside  MOs]:  ',stats                                                                   & $
x              = Te_Tp_avg_a3oo                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [ALL, 3DP, Outside MOs]:  ',stats                                                                   & $
x              = Te_Ta_avg_a3oo                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [ALL, 3DP, Outside MOs]:  ',stats                                                                   & $
PRINT,';;'

;;  Print # of values (Ts/Te)_avg ratios [Only good SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_avg_san                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [SWE, ALL, ALL]        :  ',stats                                                                   & $
x              = Te_Ta_avg_san                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [SWE, ALL, ALL]        :  ',stats                                                                   & $
x              = Te_Tp_avg_sas                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [SWE, ALL, No Shocks]  :  ',stats                                                                   & $
x              = Te_Ta_avg_sas                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [SWE, ALL, No Shocks]  :  ',stats                                                                   & $
x              = Te_Tp_avg_saio                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [SWE, ALL, Inside  MOs]:  ',stats                                                                   & $
x              = Te_Ta_avg_saio                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [SWE, ALL, Inside  MOs]:  ',stats                                                                   & $
x              = Te_Tp_avg_saoo                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [SWE, ALL, Outside MOs]:  ',stats                                                                   & $
x              = Te_Ta_avg_saoo                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [SWE, ALL, Outside MOs]:  ',stats                                                                   & $
PRINT,';;'

;;  Print # of values (Ts/Te)_avg ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_avg_s3n                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [SWE, 3DP, ALL]        :  ',stats                                                                   & $
x              = Te_Ta_avg_s3n                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [SWE, 3DP, ALL]        :  ',stats                                                                   & $
x              = Te_Tp_avg_s3s                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [SWE, 3DP, No Shocks]  :  ',stats                                                                   & $
x              = Te_Ta_avg_s3s                                                                                              & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [SWE, 3DP, No Shocks]  :  ',stats                                                                   & $
x              = Te_Tp_avg_s3io                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [SWE, 3DP, Inside  MOs]:  ',stats                                                                   & $
x              = Te_Ta_avg_s3io                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [SWE, 3DP, Inside  MOs]:  ',stats                                                                   & $
x              = Te_Tp_avg_s3oo                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Tp) [SWE, 3DP, Outside MOs]:  ',stats                                                                   & $
x              = Te_Ta_avg_s3oo                                                                                             & $
stats          = (num2int_str(N_ELEMENTS(x),NUM_CHAR=10,/ZERO_PAD))[0]                                                      & $
PRINT,';;  # of (Te/Ta) [SWE, 3DP, Outside MOs]:  ',stats                                                                   & $
PRINT,line1[0]
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  beta_s_avg ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  beta_s_avg Ratio Stats'
PRINT,line0[0]
;;  Print beta_s_avg ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_eavg_all                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_avg [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pavg_all                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_all                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_eavg_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_avg [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pavg_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_eavg_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_avg [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pavg_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_eavg_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_avg [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pavg_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
PRINT,';;'
;;  Print beta_s_avg ratios [ALL SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_eavg_3dp                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_avg [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pavg_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_eavg_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_avg [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pavg_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_eavg_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_avg [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pavg_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_eavg_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_avg [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pavg_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
PRINT,';;'
;;  Print beta_s_avg ratios [Only good SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_pavg_gsp                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_gsp                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pavg_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pavg_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pavg_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
PRINT,';;'
;;  Print beta_s_avg ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_pavg_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pavg_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pavg_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pavg_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_avg [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aavg_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_avg [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
PRINT,line1[0]
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  beta_s_per ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  beta_s_per Ratio Stats'
PRINT,line0[0]
;;  Print beta_s_per ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_eper_all                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_per [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pper_all                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_all                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_eper_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_per [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pper_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_eper_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_per [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pper_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_eper_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_per [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pper_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
PRINT,';;'
;;  Print beta_s_per ratios [ALL SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_eper_3dp                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_per [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pper_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_eper_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_per [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pper_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_eper_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_per [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pper_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_eper_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_per [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pper_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
PRINT,';;'
;;  Print beta_s_per ratios [Only good SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_pper_gsp                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_gsp                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pper_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pper_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pper_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
PRINT,';;'
;;  Print beta_s_per ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_pper_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pper_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pper_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_pper_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_per [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_aper_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_per [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
PRINT,line1[0]
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  beta_s_par ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  beta_s_par Ratio Stats'
PRINT,line0[0]
;;  Print beta_s_par ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_epar_all                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_par [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_ppar_all                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_all                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_epar_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_par [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_ppar_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_epar_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_par [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_ppar_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_epar_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_par [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_ppar_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
PRINT,';;'
;;  Print beta_s_par ratios [ALL SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_epar_3dp                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_par [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_ppar_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_epar_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_par [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_ppar_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_epar_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_par [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_ppar_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_epar_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_e_par [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_ppar_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
PRINT,';;'
;;  Print beta_s_par ratios [Only good SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_ppar_gsp                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_gsp                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_ppar_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_ppar_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_ppar_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
PRINT,';;'
;;  Print beta_s_par ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_ppar_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_ppar_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_ppar_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_ppar_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_p_par [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
x              = beta_apar_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  beta_a_par [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                     & $
PRINT,line1[0]
PRINT,';;'


;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ts/Te)_avg ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ts/Te)_avg Ratio Stats'
PRINT,line0[0]
;;  Print (Ts/Te)_avg ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_avg_aan                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_aan                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ts/Te)_avg ratios [ALL SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_avg_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ts/Te)_avg ratios [Only good SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_avg_san                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_san                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ts/Te)_avg ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_avg_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,line1[0]
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ts/Te)_per ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ts/Te)_per Ratio Stats'
PRINT,line0[0]
;;  Print (Ts/Te)_per ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_per_aan                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_aan                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ts/Te)_per ratios [ALL SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_per_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ts/Te)_per ratios [Only good SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_per_san                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_san                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ts/Te)_per ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_per_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,line1[0]
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ts/Te)_par ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ts/Te)_par Ratio Stats'
PRINT,line0[0]
;;  Print (Ts/Te)_par ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_par_aan                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_aan                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ts/Te)_par ratios [ALL SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_par_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ts/Te)_par ratios [Only good SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_par_san                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_san                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ts/Te)_par ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_par_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,line1[0]
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ts/Te)_j ratios for only good SWE and 3DP
;;----------------------------------------------------------------------------------------
PRINT,''
PRINT,''
;;  Print (Ts/Te)_avg ratios [Only good SWE and only good 3DP times]
PRINT,line0[0]
PRINT,';;  (Ts/Te)_avg Ratio Stats [Only good SWE and only good 3DP times]'
PRINT,line0[0]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_avg_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_avg_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_avg_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,line1[0]
PRINT,';;'

;;  Print (Ts/Te)_per ratios [Only good SWE and only good 3DP times]
PRINT,line0[0]
PRINT,';;  (Ts/Te)_per Ratio Stats [Only good SWE and only good 3DP times]'
PRINT,line0[0]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_per_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_per_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_per_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,line1[0]
PRINT,';;'
;;  Print (Ts/Te)_par ratios [Only good SWE and only good 3DP times]
PRINT,line0[0]
PRINT,';;  (Ts/Te)_par Ratio Stats [Only good SWE and only good 3DP times]'
PRINT,line0[0]
PRINT,';;'                                                                                                                  & $
x              = Te_Tp_par_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Tp_par_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Te_Ta_par_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,line1[0]
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ta/Tp)_avg ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ta/Tp)_avg Ratio Stats'
PRINT,line0[0]
;;  Print (Ta/Tp)_avg ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Ta_Tp_avg_aan                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_avg_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_avg_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_avg_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ta/Tp)_avg ratios [ALL SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Ta_Tp_avg_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_avg_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_avg_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_avg_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ta/Tp)_avg ratios [Only good SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Ta_Tp_avg_san                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_avg_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_avg_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_avg_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ta/Tp)_avg ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Ta_Tp_avg_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_avg_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_avg_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_avg_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_avg [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,line1[0]
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ta/Tp)_per ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ta/Tp)_per Ratio Stats'
PRINT,line0[0]
;;  Print (Ta/Tp)_per ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Ta_Tp_per_aan                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_per_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_per_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_per_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ta/Tp)_per ratios [ALL SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Ta_Tp_per_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_per_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_per_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_per_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ta/Tp)_per ratios [Only good SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Ta_Tp_per_san                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_per_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_per_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_per_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ta/Tp)_per ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Ta_Tp_per_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_per_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_per_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_per_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_per [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,line1[0]
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ta/Tp)_par ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ta/Tp)_par Ratio Stats'
PRINT,line0[0]
;;  Print (Ta/Tp)_par ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Ta_Tp_par_aan                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_par_aas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_par_aaio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_par_aaoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ta/Tp)_par ratios [ALL SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Ta_Tp_par_a3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [ALL, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_par_a3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [ALL, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_par_a3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [ALL, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_par_a3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [ALL, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ta/Tp)_par ratios [Only good SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Ta_Tp_par_san                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [SWE, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_par_sas                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [SWE, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_par_saio                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [SWE, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_par_saoo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [SWE, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'

;;  Print (Ta/Tp)_par ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Ta_Tp_par_s3n                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_par_s3s                                                                                              & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_par_s3io                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Ta_Tp_par_s3oo                                                                                             & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]     & $
PRINT,';;  (Ta/Tp)_par [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,line1[0]
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Number of Values
;;----------------------------------------------------------------------------------------
;;
;;  # of (Te/Tp) [ALL, ALL, ALL]        :  0001962058
;;  # of (Te/Ta) [ALL, ALL, ALL]        :  0001962058
;;  # of (Te/Tp) [ALL, ALL, No Shocks]  :  0001797743
;;  # of (Te/Ta) [ALL, ALL, No Shocks]  :  0001797743
;;  # of (Te/Tp) [ALL, ALL, Inside  MOs]:  0000105806
;;  # of (Te/Ta) [ALL, ALL, Inside  MOs]:  0000105806
;;  # of (Te/Tp) [ALL, ALL, Outside MOs]:  0001856252
;;  # of (Te/Ta) [ALL, ALL, Outside MOs]:  0001856252
;;
;;
;;  # of (Te/Tp) [ALL, 3DP, ALL]        :  0001026886
;;  # of (Te/Ta) [ALL, 3DP, ALL]        :  0001026886
;;  # of (Te/Tp) [ALL, 3DP, No Shocks]  :  0000955087
;;  # of (Te/Ta) [ALL, 3DP, No Shocks]  :  0000955087
;;  # of (Te/Tp) [ALL, 3DP, Inside  MOs]:  0000037037
;;  # of (Te/Ta) [ALL, 3DP, Inside  MOs]:  0000037037
;;  # of (Te/Tp) [ALL, 3DP, Outside MOs]:  0000989849
;;  # of (Te/Ta) [ALL, 3DP, Outside MOs]:  0000989849
;;
;;
;;  # of (Te/Tp) [SWE, ALL, ALL]        :  0001962058
;;  # of (Te/Ta) [SWE, ALL, ALL]        :  0001962058
;;  # of (Te/Tp) [SWE, ALL, No Shocks]  :  0001797743
;;  # of (Te/Ta) [SWE, ALL, No Shocks]  :  0001797743
;;  # of (Te/Tp) [SWE, ALL, Inside  MOs]:  0000105806
;;  # of (Te/Ta) [SWE, ALL, Inside  MOs]:  0000105806
;;  # of (Te/Tp) [SWE, ALL, Outside MOs]:  0001856252
;;  # of (Te/Ta) [SWE, ALL, Outside MOs]:  0001856252
;;
;;
;;  # of (Te/Tp) [SWE, 3DP, ALL]        :  0001026886
;;  # of (Te/Ta) [SWE, 3DP, ALL]        :  0001026886
;;  # of (Te/Tp) [SWE, 3DP, No Shocks]  :  0000955087
;;  # of (Te/Ta) [SWE, 3DP, No Shocks]  :  0000955087
;;  # of (Te/Tp) [SWE, 3DP, Inside  MOs]:  0000037037
;;  # of (Te/Ta) [SWE, 3DP, Inside  MOs]:  0000037037
;;  # of (Te/Tp) [SWE, 3DP, Outside MOs]:  0000989849
;;  # of (Te/Ta) [SWE, 3DP, Outside MOs]:  0000989849
;;========================================================================================
;;
;;----------------------------------------------------------------------------------------
;;  beta_s_avg Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  beta_e_avg [ALL, ALL, ALL]        :    1.17e-03  4.02e+02  2.26e-01  1.45e-01  9.90e-01  7.07e-04
;;  beta_p_avg [ALL, ALL, ALL]        :    2.13e-04  2.61e+03  2.61e-01  1.57e-01  2.60e+00  1.51e-03
;;  beta_a_avg [ALL, ALL, ALL]        :    5.78e-04  5.16e+02  4.89e-01  1.91e-01  2.77e+00  1.61e-03
;;  beta_e_avg [ALL, ALL, No Shocks]  :    1.25e-03  4.02e+02  2.35e-01  1.51e-01  9.76e-01  7.28e-04
;;  beta_p_avg [ALL, ALL, No Shocks]  :    5.79e-04  7.96e+02  2.47e-01  1.57e-01  1.11e+00  8.26e-04
;;  beta_a_avg [ALL, ALL, No Shocks]  :    1.24e-03  4.31e+02  4.57e-01  1.94e-01  2.02e+00  1.51e-03
;;  beta_e_avg [ALL, ALL, Inside  MOs]:    1.19e-03  2.64e+01  6.56e-02  4.27e-02  1.34e-01  4.12e-04
;;  beta_p_avg [ALL, ALL, Inside  MOs]:    4.32e-04  6.36e+01  4.64e-02  2.21e-02  2.40e-01  7.37e-04
;;  beta_a_avg [ALL, ALL, Inside  MOs]:    7.38e-04  1.87e+01  7.15e-02  2.34e-02  1.93e-01  5.92e-04
;;  beta_e_avg [ALL, ALL, Outside MOs]:    1.17e-03  4.02e+02  2.35e-01  1.51e-01  1.02e+00  7.46e-04
;;  beta_p_avg [ALL, ALL, Outside MOs]:    7.63e-04  7.96e+02  2.50e-01  1.58e-01  1.21e+00  8.88e-04
;;  beta_a_avg [ALL, ALL, Outside MOs]:    1.08e-03  4.31e+02  4.72e-01  2.08e-01  2.06e+00  1.51e-03
;;
;;
;;  beta_e_avg [ALL, 3DP, ALL]        :    1.90e-03  4.02e+02  2.55e-01  1.60e-01  1.10e+00  1.09e-03
;;  beta_p_avg [ALL, 3DP, ALL]        :    7.29e-04  4.37e+02  2.43e-01  1.57e-01  9.11e-01  8.99e-04
;;  beta_a_avg [ALL, 3DP, ALL]        :    1.21e-03  4.31e+02  5.01e-01  2.21e-01  2.18e+00  2.15e-03
;;  beta_e_avg [ALL, 3DP, No Shocks]  :    2.31e-03  5.46e+02  2.83e-01  1.62e-01  1.51e+00  1.55e-03
;;  beta_p_avg [ALL, 3DP, No Shocks]  :    9.94e-04  4.37e+02  2.49e-01  1.62e-01  9.23e-01  9.44e-04
;;  beta_a_avg [ALL, 3DP, No Shocks]  :    1.25e-03  4.31e+02  5.17e-01  2.31e-01  2.22e+00  2.27e-03
;;  beta_e_avg [ALL, 3DP, Inside  MOs]:    1.53e-03  3.06e+00  7.07e-02  4.91e-02  7.83e-02  4.07e-04
;;  beta_p_avg [ALL, 3DP, Inside  MOs]:    7.29e-04  1.88e+01  4.94e-02  2.50e-02  1.38e-01  7.16e-04
;;  beta_a_avg [ALL, 3DP, Inside  MOs]:    1.21e-03  1.87e+01  8.04e-02  2.51e-02  2.62e-01  1.36e-03
;;  beta_e_avg [ALL, 3DP, Outside MOs]:    2.06e-03  5.46e+02  2.81e-01  1.61e-01  1.49e+00  1.50e-03
;;  beta_p_avg [ALL, 3DP, Outside MOs]:    1.15e-03  4.37e+02  2.50e-01  1.63e-01  9.26e-01  9.31e-04
;;  beta_a_avg [ALL, 3DP, Outside MOs]:    1.38e-03  4.31e+02  5.26e-01  2.41e-01  2.24e+00  2.25e-03
;;
;;
;;  beta_p_avg [SWE, ALL, ALL]        :    2.13e-04  2.61e+03  2.58e-01  1.56e-01  2.59e+00  1.56e-03
;;  beta_a_avg [SWE, ALL, ALL]        :    5.78e-04  5.16e+02  4.89e-01  1.91e-01  2.77e+00  3.56e-03
;;  beta_p_avg [SWE, ALL, No Shocks]  :    5.79e-04  7.96e+02  2.61e-01  1.64e-01  1.14e+00  8.49e-04
;;  beta_a_avg [SWE, ALL, No Shocks]  :    1.05e-03  3.54e+03  1.04e+00  6.24e-01  4.24e+00  3.16e-03
;;  beta_p_avg [SWE, ALL, Inside  MOs]:    4.32e-04  1.24e+02  5.86e-02  2.31e-02  5.06e-01  1.56e-03
;;  beta_a_avg [SWE, ALL, Inside  MOs]:    7.38e-04  2.51e+02  1.87e-01  6.64e-02  8.91e-01  2.74e-03
;;  beta_p_avg [SWE, ALL, Outside MOs]:    7.63e-04  7.96e+02  2.64e-01  1.65e-01  1.23e+00  9.04e-04
;;  beta_a_avg [SWE, ALL, Outside MOs]:    1.08e-03  3.54e+03  1.05e+00  6.29e-01  4.33e+00  3.18e-03
;;
;;
;;  beta_p_avg [SWE, 3DP, ALL]        :    7.29e-04  4.37e+02  2.53e-01  1.62e-01  9.77e-01  9.64e-04
;;  beta_a_avg [SWE, 3DP, ALL]        :    1.21e-03  9.77e+02  9.97e-01  6.08e-01  3.21e+00  3.17e-03
;;  beta_p_avg [SWE, 3DP, No Shocks]  :    9.94e-04  4.37e+02  2.60e-01  1.67e-01  9.92e-01  1.01e-03
;;  beta_a_avg [SWE, 3DP, No Shocks]  :    1.25e-03  9.77e+02  1.03e+00  6.40e-01  3.29e+00  3.36e-03
;;  beta_p_avg [SWE, 3DP, Inside  MOs]:    7.29e-04  1.88e+01  5.52e-02  2.57e-02  1.87e-01  9.70e-04
;;  beta_a_avg [SWE, 3DP, Inside  MOs]:    1.21e-03  4.03e+01  1.92e-01  7.38e-02  5.07e-01  2.64e-03
;;  beta_p_avg [SWE, 3DP, Outside MOs]:    1.15e-03  4.37e+02  2.61e-01  1.67e-01  9.94e-01  9.99e-04
;;  beta_a_avg [SWE, 3DP, Outside MOs]:    1.38e-03  9.77e+02  1.03e+00  6.39e-01  3.27e+00  3.28e-03
;;========================================================================================
;;
;;----------------------------------------------------------------------------------------
;;  beta_s_per Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  beta_e_per [ALL, ALL, ALL]        :    1.16e-03  4.05e+02  2.18e-01  1.35e-01  9.91e-01  7.07e-04
;;  beta_p_per [ALL, ALL, ALL]        :    3.14e-05  2.46e+03  2.69e-01  1.45e-01  2.61e+00  1.52e-03
;;  beta_a_per [ALL, ALL, ALL]        :    4.15e-04  3.06e+03  7.51e-01  3.71e-01  4.02e+00  2.34e-03
;;  beta_e_per [ALL, ALL, No Shocks]  :    1.28e-03  4.05e+02  2.27e-01  1.41e-01  9.77e-01  7.28e-04
;;  beta_p_per [ALL, ALL, No Shocks]  :    3.35e-04  8.01e+02  2.42e-01  1.44e-01  1.13e+00  8.41e-04
;;  beta_a_per [ALL, ALL, No Shocks]  :    8.85e-04  3.18e+03  7.16e-01  3.66e-01  4.32e+00  3.22e-03
;;  beta_e_per [ALL, ALL, Inside  MOs]:    1.18e-03  2.62e+01  6.06e-02  3.97e-02  1.30e-01  3.99e-04
;;  beta_p_per [ALL, ALL, Inside  MOs]:    8.33e-05  1.16e+02  4.95e-02  2.10e-02  4.58e-01  1.41e-03
;;  beta_a_per [ALL, ALL, Inside  MOs]:    5.12e-04  3.26e+02  1.29e-01  4.52e-02  1.35e+00  4.17e-03
;;  beta_e_per [ALL, ALL, Outside MOs]:    1.16e-03  4.05e+02  2.27e-01  1.42e-01  1.02e+00  7.46e-04
;;  beta_p_per [ALL, ALL, Outside MOs]:    4.39e-04  8.01e+02  2.44e-01  1.46e-01  1.20e+00  8.83e-04
;;  beta_a_per [ALL, ALL, Outside MOs]:    8.41e-04  3.18e+03  7.26e-01  3.79e-01  4.27e+00  3.14e-03
;;
;;
;;  beta_e_per [ALL, 3DP, ALL]        :    1.75e-03  4.05e+02  2.49e-01  1.53e-01  1.10e+00  1.09e-03
;;  beta_p_per [ALL, 3DP, ALL]        :    8.33e-05  4.38e+02  2.32e-01  1.41e-01  9.68e-01  9.56e-04
;;  beta_a_per [ALL, 3DP, ALL]        :    1.01e-03  1.56e+03  7.37e-01  3.90e-01  3.09e+00  3.05e-03
;;  beta_e_per [ALL, 3DP, No Shocks]  :    2.23e-03  5.50e+02  2.76e-01  1.57e-01  1.48e+00  1.52e-03
;;  beta_p_per [ALL, 3DP, No Shocks]  :    3.35e-04  4.38e+02  2.37e-01  1.46e-01  9.82e-01  1.01e-03
;;  beta_a_per [ALL, 3DP, No Shocks]  :    1.19e-03  1.56e+03  7.60e-01  4.11e-01  3.17e+00  3.24e-03
;;  beta_e_per [ALL, 3DP, Inside  MOs]:    1.40e-03  2.94e+00  6.85e-02  4.69e-02  7.69e-02  3.99e-04
;;  beta_p_per [ALL, 3DP, Inside  MOs]:    8.33e-05  1.75e+01  4.91e-02  2.33e-02  1.70e-01  8.82e-04
;;  beta_a_per [ALL, 3DP, Inside  MOs]:    1.01e-03  2.73e+01  1.40e-01  5.00e-02  3.92e-01  2.04e-03
;;  beta_e_per [ALL, 3DP, Outside MOs]:    1.97e-03  5.50e+02  2.74e-01  1.56e-01  1.46e+00  1.47e-03
;;  beta_p_per [ALL, 3DP, Outside MOs]:    4.39e-04  4.38e+02  2.38e-01  1.46e-01  9.85e-01  9.90e-04
;;  beta_a_per [ALL, 3DP, Outside MOs]:    1.18e-03  1.56e+03  7.63e-01  4.15e-01  3.15e+00  3.17e-03
;;
;;
;;  beta_p_per [SWE, ALL, ALL]        :    3.14e-05  2.46e+03  2.43e-01  1.39e-01  2.42e+00  1.46e-03
;;  beta_a_per [SWE, ALL, ALL]        :    4.15e-04  5.17e+02  4.50e-01  1.74e-01  2.66e+00  3.42e-03
;;  beta_p_per [SWE, ALL, No Shocks]  :    3.35e-04  8.01e+02  2.42e-01  1.44e-01  1.12e+00  8.35e-04
;;  beta_a_per [SWE, ALL, No Shocks]  :    8.85e-04  3.18e+03  9.57e-01  5.45e-01  3.97e+00  2.96e-03
;;  beta_p_per [SWE, ALL, Inside  MOs]:    7.43e-05  1.18e+02  5.19e-02  2.11e-02  4.57e-01  1.41e-03
;;  beta_a_per [SWE, ALL, Inside  MOs]:    5.12e-04  2.90e+02  1.90e-01  5.78e-02  1.01e+00  3.11e-03
;;  beta_p_per [SWE, ALL, Outside MOs]:    4.39e-04  8.01e+02  2.44e-01  1.46e-01  1.19e+00  8.77e-04
;;  beta_a_per [SWE, ALL, Outside MOs]:    5.27e-04  3.18e+03  9.66e-01  5.52e-01  4.04e+00  2.97e-03
;;
;;
;;  beta_p_per [SWE, 3DP, ALL]        :    8.33e-05  4.38e+02  2.31e-01  1.41e-01  9.54e-01  9.41e-04
;;  beta_a_per [SWE, 3DP, ALL]        :    1.01e-03  1.01e+03  9.16e-01  5.28e-01  3.09e+00  3.05e-03
;;  beta_p_per [SWE, 3DP, No Shocks]  :    3.35e-04  4.38e+02  2.37e-01  1.46e-01  9.70e-01  9.93e-04
;;  beta_a_per [SWE, 3DP, No Shocks]  :    1.17e-03  1.01e+03  9.40e-01  5.52e-01  3.15e+00  3.23e-03
;;  beta_p_per [SWE, 3DP, Inside  MOs]:    8.33e-05  1.75e+01  4.95e-02  2.33e-02  1.70e-01  8.83e-04
;;  beta_a_per [SWE, 3DP, Inside  MOs]:    1.01e-03  4.52e+01  1.94e-01  6.08e-02  5.59e-01  2.90e-03
;;  beta_p_per [SWE, 3DP, Outside MOs]:    4.39e-04  4.38e+02  2.38e-01  1.46e-01  9.70e-01  9.75e-04
;;  beta_a_per [SWE, 3DP, Outside MOs]:    1.18e-03  1.01e+03  9.43e-01  5.54e-01  3.14e+00  3.16e-03
;;========================================================================================
;;
;;----------------------------------------------------------------------------------------
;;  beta_s_par Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  beta_e_par [ALL, ALL, ALL]        :    1.18e-03  3.98e+02  2.43e-01  1.62e-01  9.91e-01  7.07e-04
;;  beta_p_par [ALL, ALL, ALL]        :    3.54e-05  3.55e+03  2.99e-01  1.73e-01  3.07e+00  1.79e-03
;;  beta_a_par [ALL, ALL, ALL]        :    2.67e-04  7.39e+03  8.00e-01  2.77e-01  9.54e+00  5.55e-03
;;  beta_e_par [ALL, ALL, No Shocks]  :    1.18e-03  3.98e+02  2.52e-01  1.69e-01  9.75e-01  7.27e-04
;;  beta_p_par [ALL, ALL, No Shocks]  :    2.07e-04  7.86e+02  2.85e-01  1.82e-01  1.14e+00  8.52e-04
;;  beta_a_par [ALL, ALL, No Shocks]  :    3.18e-04  1.01e+03  6.38e-01  2.44e-01  3.03e+00  2.26e-03
;;  beta_e_par [ALL, ALL, Inside  MOs]:    1.18e-03  2.68e+01  7.56e-02  4.81e-02  1.43e-01  4.41e-04
;;  beta_p_par [ALL, ALL, Inside  MOs]:    1.90e-04  6.90e+01  5.64e-02  2.40e-02  2.69e-01  8.28e-04
;;  beta_a_par [ALL, ALL, Inside  MOs]:    3.50e-04  2.04e+01  9.27e-02  2.51e-02  2.76e-01  8.47e-04
;;  beta_e_par [ALL, ALL, Outside MOs]:    1.20e-03  3.98e+02  2.52e-01  1.69e-01  1.02e+00  7.46e-04
;;  beta_p_par [ALL, ALL, Outside MOs]:    2.95e-04  8.04e+02  2.89e-01  1.85e-01  1.29e+00  9.48e-04
;;  beta_a_par [ALL, ALL, Outside MOs]:    3.18e-04  1.01e+03  6.54e-01  2.61e-01  3.04e+00  2.23e-03
;;
;;
;;  beta_e_par [ALL, 3DP, ALL]        :    2.13e-03  3.98e+02  2.67e-01  1.74e-01  1.10e+00  1.09e-03
;;  beta_p_par [ALL, 3DP, ALL]        :    2.07e-04  4.36e+02  2.86e-01  1.88e-01  9.60e-01  9.47e-04
;;  beta_a_par [ALL, 3DP, ALL]        :    3.18e-04  5.03e+02  6.92e-01  2.84e-01  2.74e+00  2.71e-03
;;  beta_e_par [ALL, 3DP, No Shocks]  :    2.35e-03  5.38e+02  2.99e-01  1.70e-01  1.57e+00  1.61e-03
;;  beta_p_par [ALL, 3DP, No Shocks]  :    2.07e-04  4.36e+02  2.93e-01  1.95e-01  9.68e-01  9.90e-04
;;  beta_a_par [ALL, 3DP, No Shocks]  :    3.18e-04  5.03e+02  7.18e-01  3.00e-01  2.81e+00  2.88e-03
;;  beta_e_par [ALL, 3DP, Inside  MOs]:    1.70e-03  3.28e+00  7.49e-02  5.27e-02  8.21e-02  4.26e-04
;;  beta_p_par [ALL, 3DP, Inside  MOs]:    2.07e-04  2.15e+01  6.08e-02  2.77e-02  1.75e-01  9.07e-04
;;  beta_a_par [ALL, 3DP, Inside  MOs]:    5.73e-04  2.04e+01  1.06e-01  2.78e-02  3.38e-01  1.76e-03
;;  beta_e_par [ALL, 3DP, Outside MOs]:    2.23e-03  5.38e+02  2.97e-01  1.69e-01  1.55e+00  1.56e-03
;;  beta_p_par [ALL, 3DP, Outside MOs]:    4.81e-04  4.36e+02  2.95e-01  1.95e-01  9.76e-01  9.81e-04
;;  beta_a_par [ALL, 3DP, Outside MOs]:    3.18e-04  5.03e+02  7.25e-01  3.11e-01  2.81e+00  2.83e-03
;;
;;
;;  beta_p_par [SWE, ALL, ALL]        :    3.54e-05  3.55e+03  2.88e-01  1.70e-01  3.04e+00  1.83e-03
;;  beta_a_par [SWE, ALL, ALL]        :    2.67e-04  7.40e+02  5.70e-01  2.04e-01  3.13e+00  4.03e-03
;;  beta_p_par [SWE, ALL, No Shocks]  :    2.07e-04  7.86e+02  3.00e-01  1.90e-01  1.19e+00  8.86e-04
;;  beta_a_par [SWE, ALL, No Shocks]  :    3.18e-04  4.25e+03  1.23e+00  7.31e-01  4.92e+00  3.67e-03
;;  beta_p_par [SWE, ALL, Inside  MOs]:    1.24e-04  1.36e+02  7.20e-02  2.48e-02  6.63e-01  2.04e-03
;;  beta_a_par [SWE, ALL, Inside  MOs]:    3.50e-04  1.75e+02  1.88e-01  7.07e-02  6.91e-01  2.12e-03
;;  beta_p_par [SWE, ALL, Outside MOs]:    2.95e-04  8.04e+02  3.03e-01  1.92e-01  1.33e+00  9.74e-04
;;  beta_a_par [SWE, ALL, Outside MOs]:    3.18e-04  4.25e+03  1.24e+00  7.36e-01  5.03e+00  3.69e-03
;;
;;
;;  beta_p_par [SWE, 3DP, ALL]        :    2.07e-04  4.36e+02  2.98e-01  1.93e-01  1.04e+00  1.02e-03
;;  beta_a_par [SWE, 3DP, ALL]        :    3.18e-04  1.18e+03  1.17e+00  7.15e-01  3.58e+00  3.54e-03
;;  beta_p_par [SWE, 3DP, No Shocks]  :    2.07e-04  4.36e+02  3.05e-01  2.00e-01  1.03e+00  1.06e-03
;;  beta_a_par [SWE, 3DP, No Shocks]  :    3.18e-04  1.18e+03  1.21e+00  7.59e-01  3.67e+00  3.76e-03
;;  beta_p_par [SWE, 3DP, Inside  MOs]:    2.07e-04  2.15e+01  6.71e-02  2.83e-02  2.27e-01  1.18e-03
;;  beta_a_par [SWE, 3DP, Inside  MOs]:    5.73e-04  3.05e+01  1.97e-01  8.40e-02  4.55e-01  2.37e-03
;;  beta_p_par [SWE, 3DP, Outside MOs]:    4.81e-04  4.36e+02  3.06e-01  2.01e-01  1.06e+00  1.06e-03
;;  beta_a_par [SWE, 3DP, Outside MOs]:    3.18e-04  1.18e+03  1.21e+00  7.55e-01  3.64e+00  3.66e-03
;;========================================================================================
;;
;;----------------------------------------------------------------------------------------
;;  (Ts/Te)_avg Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  (Te/Tp)_avg [ALL, ALL, ALL]        :    2.54e-03  3.87e+01  1.42e+00  1.03e+00  1.28e+00  9.10e-04
;;  (Te/Ta)_avg [ALL, ALL, ALL]        :    2.74e-02  4.07e+01  1.36e+00  9.63e-01  1.32e+00  9.41e-04
;;  (Te/Tp)_avg [ALL, ALL, No Shocks]  :    5.07e-03  3.87e+01  1.42e+00  1.03e+00  1.26e+00  9.42e-04
;;  (Te/Ta)_avg [ALL, ALL, No Shocks]  :    2.74e-02  4.07e+01  1.37e+00  9.76e-01  1.32e+00  9.86e-04
;;  (Te/Tp)_avg [ALL, ALL, Inside  MOs]:    2.54e-03  3.87e+01  2.55e+00  1.83e+00  2.38e+00  7.31e-03
;;  (Te/Ta)_avg [ALL, ALL, Inside  MOs]:    4.94e-02  4.07e+01  2.19e+00  1.61e+00  2.09e+00  6.41e-03
;;  (Te/Tp)_avg [ALL, ALL, Outside MOs]:    4.04e-03  2.79e+01  1.35e+00  1.00e+00  1.15e+00  8.46e-04
;;  (Te/Ta)_avg [ALL, ALL, Outside MOs]:    2.74e-02  1.61e+01  1.28e+00  9.17e-01  1.19e+00  8.75e-04
;;
;;
;;  (Te/Tp)_avg [ALL, 3DP, ALL]        :    3.85e-03  3.17e+01  1.41e+00  1.06e+00  1.13e+00  1.12e-03
;;  (Te/Ta)_avg [ALL, 3DP, ALL]        :    3.57e-02  1.60e+01  1.29e+00  9.25e-01  1.20e+00  1.18e-03
;;  (Te/Tp)_avg [ALL, 3DP, No Shocks]  :    8.08e-03  2.88e+01  1.51e+00  1.04e+00  1.42e+00  1.46e-03
;;  (Te/Ta)_avg [ALL, 3DP, No Shocks]  :    2.05e-02  1.57e+01  1.53e+00  1.08e+00  1.48e+00  1.51e-03
;;  (Te/Tp)_avg [ALL, 3DP, Inside  MOs]:    1.10e-02  2.88e+01  2.65e+00  2.11e+00  2.14e+00  1.11e-02
;;  (Te/Ta)_avg [ALL, 3DP, Inside  MOs]:    3.14e-02  1.57e+01  2.26e+00  1.76e+00  1.96e+00  1.02e-02
;;  (Te/Tp)_avg [ALL, 3DP, Outside MOs]:    7.77e-03  2.80e+01  1.46e+00  1.01e+00  1.37e+00  1.38e-03
;;  (Te/Ta)_avg [ALL, 3DP, Outside MOs]:    1.97e-02  1.38e+01  1.47e+00  1.02e+00  1.42e+00  1.43e-03
;;
;;
;;  (Te/Tp)_avg [SWE, ALL, ALL]        :    2.54e-03  3.87e+01  1.37e+00  9.79e-01  1.27e+00  9.06e-04
;;  (Te/Ta)_avg [SWE, ALL, ALL]        :    1.00e-03  4.07e+01  6.19e-01  2.39e-01  9.16e-01  6.54e-04
;;  (Te/Tp)_avg [SWE, ALL, No Shocks]  :    4.23e-03  3.87e+01  1.37e+00  9.81e-01  1.26e+00  9.39e-04
;;  (Te/Ta)_avg [SWE, ALL, No Shocks]  :    6.09e-03  4.07e+01  6.19e-01  2.36e-01  9.15e-01  6.82e-04
;;  (Te/Tp)_avg [SWE, ALL, Inside  MOs]:    2.54e-03  3.87e+01  2.47e+00  1.76e+00  2.38e+00  7.32e-03
;;  (Te/Ta)_avg [SWE, ALL, Inside  MOs]:    1.00e-03  4.07e+01  1.26e+00  6.62e-01  1.63e+00  5.00e-03
;;  (Te/Tp)_avg [SWE, ALL, Outside MOs]:    4.04e-03  2.79e+01  1.31e+00  9.51e-01  1.15e+00  8.41e-04
;;  (Te/Ta)_avg [SWE, ALL, Outside MOs]:    1.79e-02  1.61e+01  5.83e-01  2.28e-01  8.45e-01  6.20e-04
;;
;;
;;  (Te/Tp)_avg [SWE, 3DP, ALL]        :    3.85e-03  3.17e+01  1.38e+00  1.02e+00  1.13e+00  1.11e-03
;;  (Te/Ta)_avg [SWE, 3DP, ALL]        :    1.02e-03  1.71e+01  6.24e-01  2.54e-01  8.57e-01  8.45e-04
;;  (Te/Tp)_avg [SWE, 3DP, No Shocks]  :    7.65e-03  2.88e+01  1.47e+00  9.99e-01  1.42e+00  1.45e-03
;;  (Te/Ta)_avg [SWE, 3DP, No Shocks]  :    1.31e-02  1.57e+01  6.98e-01  2.46e-01  1.05e+00  1.08e-03
;;  (Te/Tp)_avg [SWE, 3DP, Inside  MOs]:    1.10e-02  2.88e+01  2.59e+00  2.05e+00  2.16e+00  1.12e-02
;;  (Te/Ta)_avg [SWE, 3DP, Inside  MOs]:    2.92e-03  1.57e+01  1.32e+00  8.23e-01  1.52e+00  7.89e-03
;;  (Te/Tp)_avg [SWE, 3DP, Outside MOs]:    7.65e-03  2.80e+01  1.42e+00  9.73e-01  1.36e+00  1.37e-03
;;  (Te/Ta)_avg [SWE, 3DP, Outside MOs]:    1.03e-02  1.41e+01  6.71e-01  2.39e-01  1.01e+00  1.02e-03
;;========================================================================================
;;
;;----------------------------------------------------------------------------------------
;;  (Ts/Te)_per Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  (Te/Tp)_per [ALL, ALL, ALL]        :    2.04e-03  7.37e+01  1.47e+00  1.07e+00  1.34e+00  9.59e-04
;;  (Te/Ta)_per [ALL, ALL, ALL]        :    8.16e-03  5.01e+01  9.01e-01  4.09e-01  1.13e+00  8.04e-04
;;  (Te/Tp)_per [ALL, ALL, No Shocks]  :    2.04e-03  7.37e+01  1.48e+00  1.08e+00  1.34e+00  9.97e-04
;;  (Te/Ta)_per [ALL, ALL, No Shocks]  :    8.16e-03  5.01e+01  9.06e-01  4.11e-01  1.13e+00  8.41e-04
;;  (Te/Tp)_per [ALL, ALL, Inside  MOs]:    2.04e-03  5.48e+01  2.48e+00  1.84e+00  2.32e+00  7.13e-03
;;  (Te/Ta)_per [ALL, ALL, Inside  MOs]:    8.16e-03  5.01e+01  1.51e+00  7.86e-01  1.83e+00  5.62e-03
;;  (Te/Tp)_per [ALL, ALL, Outside MOs]:    3.69e-03  7.37e+01  1.42e+00  1.04e+00  1.24e+00  9.13e-04
;;  (Te/Ta)_per [ALL, ALL, Outside MOs]:    9.12e-03  2.02e+01  8.59e-01  3.91e-01  1.05e+00  7.70e-04
;;
;;
;;  (Te/Tp)_per [ALL, 3DP, ALL]        :    2.04e-03  4.10e+01  1.51e+00  1.15e+00  1.23e+00  1.21e-03
;;  (Te/Ta)_per [ALL, 3DP, ALL]        :    9.12e-03  2.81e+01  8.90e-01  4.24e-01  1.06e+00  1.04e-03
;;  (Te/Tp)_per [ALL, 3DP, No Shocks]  :    9.35e-03  6.76e+01  1.60e+00  1.13e+00  1.48e+00  1.52e-03
;;  (Te/Ta)_per [ALL, 3DP, No Shocks]  :    1.08e-02  3.20e+01  1.02e+00  4.39e-01  1.28e+00  1.31e-03
;;  (Te/Tp)_per [ALL, 3DP, Inside  MOs]:    3.56e-02  6.76e+01  2.69e+00  2.13e+00  2.22e+00  1.15e-02
;;  (Te/Ta)_per [ALL, 3DP, Inside  MOs]:    2.65e-02  1.92e+01  1.67e+00  9.05e-01  1.90e+00  9.86e-03
;;  (Te/Tp)_per [ALL, 3DP, Outside MOs]:    8.48e-03  5.59e+01  1.55e+00  1.09e+00  1.43e+00  1.44e-03
;;  (Te/Ta)_per [ALL, 3DP, Outside MOs]:    1.08e-02  3.20e+01  9.88e-01  4.27e-01  1.24e+00  1.24e-03
;;
;;
;;  (Te/Tp)_per [SWE, ALL, ALL]        :    1.08e-02  7.37e+01  1.47e+00  1.07e+00  1.35e+00  9.64e-04
;;  (Te/Ta)_per [SWE, ALL, ALL]        :    4.47e-03  5.11e+01  6.69e-01  2.53e-01  9.87e-01  7.05e-04
;;  (Te/Tp)_per [SWE, ALL, No Shocks]  :    1.24e-02  7.37e+01  1.48e+00  1.08e+00  1.34e+00  1.00e-03
;;  (Te/Ta)_per [SWE, ALL, No Shocks]  :    4.47e-03  5.01e+01  6.71e-01  2.52e-01  9.84e-01  7.34e-04
;;  (Te/Tp)_per [SWE, ALL, Inside  MOs]:    1.24e-02  5.48e+01  2.50e+00  1.84e+00  2.37e+00  7.27e-03
;;  (Te/Ta)_per [SWE, ALL, Inside  MOs]:    4.47e-03  5.01e+01  1.29e+00  7.11e-01  1.72e+00  5.28e-03
;;  (Te/Tp)_per [SWE, ALL, Outside MOs]:    1.08e-02  7.37e+01  1.42e+00  1.04e+00  1.25e+00  9.14e-04
;;  (Te/Ta)_per [SWE, ALL, Outside MOs]:    1.37e-02  5.11e+01  6.34e-01  2.42e-01  9.17e-01  6.73e-04
;;
;;
;;  (Te/Tp)_per [SWE, 3DP, ALL]        :    1.55e-02  4.10e+01  1.51e+00  1.15e+00  1.23e+00  1.22e-03
;;  (Te/Ta)_per [SWE, 3DP, ALL]        :    1.37e-02  2.81e+01  6.89e-01  2.76e-01  9.40e-01  9.28e-04
;;  (Te/Tp)_per [SWE, 3DP, No Shocks]  :    2.05e-02  6.76e+01  1.60e+00  1.12e+00  1.49e+00  1.52e-03
;;  (Te/Ta)_per [SWE, 3DP, No Shocks]  :    1.22e-02  3.20e+01  7.60e-01  2.70e-01  1.12e+00  1.14e-03
;;  (Te/Tp)_per [SWE, 3DP, Inside  MOs]:    3.93e-02  6.76e+01  2.70e+00  2.13e+00  2.26e+00  1.18e-02
;;  (Te/Ta)_per [SWE, 3DP, Inside  MOs]:    1.99e-02  1.92e+01  1.48e+00  9.02e-01  1.72e+00  8.92e-03
;;  (Te/Tp)_per [SWE, 3DP, Outside MOs]:    2.05e-02  5.59e+01  1.55e+00  1.09e+00  1.43e+00  1.44e-03
;;  (Te/Ta)_per [SWE, 3DP, Outside MOs]:    8.82e-03  3.20e+01  7.28e-01  2.60e-01  1.07e+00  1.08e-03
;;========================================================================================
;;
;;----------------------------------------------------------------------------------------
;;  (Ts/Te)_par Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  (Te/Tp)_par [ALL, ALL, ALL]        :    8.85e-04  2.01e+02  1.41e+00  9.42e-01  1.48e+00  1.05e-03
;;  (Te/Ta)_par [ALL, ALL, ALL]        :    3.36e-04  5.65e+01  1.34e+00  8.29e-01  1.54e+00  1.10e-03
;;  (Te/Tp)_par [ALL, ALL, No Shocks]  :    1.87e-03  2.01e+02  1.40e+00  9.39e-01  1.46e+00  1.09e-03
;;  (Te/Ta)_par [ALL, ALL, No Shocks]  :    6.58e-03  5.65e+01  1.34e+00  8.30e-01  1.54e+00  1.15e-03
;;  (Te/Tp)_par [ALL, ALL, Inside  MOs]:    8.85e-04  2.01e+02  2.80e+00  1.88e+00  3.05e+00  9.38e-03
;;  (Te/Ta)_par [ALL, ALL, Inside  MOs]:    3.36e-04  5.65e+01  2.50e+00  1.69e+00  2.71e+00  8.34e-03
;;  (Te/Tp)_par [ALL, ALL, Outside MOs]:    1.26e-03  9.33e+01  1.33e+00  9.14e-01  1.29e+00  9.50e-04
;;  (Te/Ta)_par [ALL, ALL, Outside MOs]:    1.30e-03  3.41e+01  1.24e+00  7.73e-01  1.34e+00  9.82e-04
;;
;;
;;  (Te/Tp)_par [ALL, 3DP, ALL]        :    1.26e-03  8.75e+01  1.33e+00  9.33e-01  1.24e+00  1.22e-03
;;  (Te/Ta)_par [ALL, 3DP, ALL]        :    3.36e-04  3.41e+01  1.22e+00  7.59e-01  1.33e+00  1.32e-03
;;  (Te/Tp)_par [ALL, 3DP, No Shocks]  :    2.78e-03  1.22e+02  1.43e+00  9.03e-01  1.56e+00  1.59e-03
;;  (Te/Ta)_par [ALL, 3DP, No Shocks]  :    4.17e-03  2.97e+01  1.50e+00  9.05e-01  1.68e+00  1.72e-03
;;  (Te/Tp)_par [ALL, 3DP, Inside  MOs]:    3.50e-03  1.22e+02  2.70e+00  2.06e+00  2.51e+00  1.30e-02
;;  (Te/Ta)_par [ALL, 3DP, Inside  MOs]:    8.81e-04  1.89e+01  2.34e+00  1.77e+00  2.14e+00  1.11e-02
;;  (Te/Tp)_par [ALL, 3DP, Outside MOs]:    2.78e-03  8.09e+01  1.38e+00  8.83e-01  1.49e+00  1.49e-03
;;  (Te/Ta)_par [ALL, 3DP, Outside MOs]:    4.17e-03  2.97e+01  1.44e+00  8.55e-01  1.63e+00  1.64e-03
;;
;;
;;  (Te/Tp)_par [SWE, ALL, ALL]        :    8.85e-04  2.01e+02  1.37e+00  9.04e-01  1.49e+00  1.06e-03
;;  (Te/Ta)_par [SWE, ALL, ALL]        :    3.43e-04  5.65e+01  6.35e-01  2.25e-01  1.05e+00  7.52e-04
;;  (Te/Tp)_par [SWE, ALL, No Shocks]  :    1.62e-03  2.01e+02  1.36e+00  9.01e-01  1.46e+00  1.09e-03
;;  (Te/Ta)_par [SWE, ALL, No Shocks]  :    9.79e-03  5.65e+01  6.32e-01  2.20e-01  1.06e+00  7.89e-04
;;  (Te/Tp)_par [SWE, ALL, Inside  MOs]:    8.85e-04  2.01e+02  2.76e+00  1.82e+00  3.16e+00  9.73e-03
;;  (Te/Ta)_par [SWE, ALL, Inside  MOs]:    3.43e-04  5.65e+01  1.42e+00  6.97e-01  2.04e+00  6.28e-03
;;  (Te/Tp)_par [SWE, ALL, Outside MOs]:    1.26e-03  9.33e+01  1.29e+00  8.77e-01  1.30e+00  9.51e-04
;;  (Te/Ta)_par [SWE, ALL, Outside MOs]:    9.79e-03  3.74e+01  5.92e-01  2.15e-01  9.54e-01  7.00e-04
;;
;;
;;  (Te/Tp)_par [SWE, 3DP, ALL]        :    1.26e-03  8.75e+01  1.30e+00  9.05e-01  1.23e+00  1.22e-03
;;  (Te/Ta)_par [SWE, 3DP, ALL]        :    3.53e-04  3.74e+01  6.13e-01  2.33e-01  9.39e-01  9.27e-04
;;  (Te/Tp)_par [SWE, 3DP, No Shocks]  :    2.47e-03  1.22e+02  1.40e+00  8.73e-01  1.55e+00  1.58e-03
;;  (Te/Ta)_par [SWE, 3DP, No Shocks]  :    8.19e-03  3.74e+01  6.95e-01  2.23e-01  1.17e+00  1.20e-03
;;  (Te/Tp)_par [SWE, 3DP, Inside  MOs]:    3.50e-03  1.22e+02  2.65e+00  1.99e+00  2.52e+00  1.31e-02
;;  (Te/Ta)_par [SWE, 3DP, Inside  MOs]:    9.25e-04  2.68e+01  1.31e+00  7.14e-01  1.64e+00  8.52e-03
;;  (Te/Tp)_par [SWE, 3DP, Outside MOs]:    2.47e-03  8.09e+01  1.35e+00  8.53e-01  1.48e+00  1.48e-03
;;  (Te/Ta)_par [SWE, 3DP, Outside MOs]:    8.19e-03  3.74e+01  6.69e-01  2.17e-01  1.13e+00  1.14e-03
;;========================================================================================


;;----------------------------------------------------------------------------------------
;;  (Ts/Te)_avg Ratio Stats [Only good SWE and only good 3DP times]
;;----------------------------------------------------------------------------------------
;;
;;  (Te/Tp)_avg [SWE, 3DP, ALL]        :    3.85e-03  3.17e+01  1.38e+00  1.02e+00  1.13e+00  1.11e-03
;;  (Te/Ta)_avg [SWE, 3DP, ALL]        :    1.02e-03  1.71e+01  6.24e-01  2.54e-01  8.57e-01  8.45e-04
;;  (Te/Tp)_avg [SWE, 3DP, No Shocks]  :    7.65e-03  2.88e+01  1.47e+00  9.99e-01  1.42e+00  1.45e-03
;;  (Te/Ta)_avg [SWE, 3DP, No Shocks]  :    1.31e-02  1.57e+01  6.98e-01  2.46e-01  1.05e+00  1.08e-03
;;  (Te/Tp)_avg [SWE, 3DP, Inside  MOs]:    1.10e-02  2.88e+01  2.59e+00  2.05e+00  2.16e+00  1.12e-02
;;  (Te/Ta)_avg [SWE, 3DP, Inside  MOs]:    2.92e-03  1.57e+01  1.32e+00  8.23e-01  1.52e+00  7.89e-03
;;  (Te/Tp)_avg [SWE, 3DP, Outside MOs]:    7.65e-03  2.80e+01  1.42e+00  9.73e-01  1.36e+00  1.37e-03
;;  (Te/Ta)_avg [SWE, 3DP, Outside MOs]:    1.03e-02  1.41e+01  6.71e-01  2.39e-01  1.01e+00  1.02e-03
;;========================================================================================
;;
;;----------------------------------------------------------------------------------------
;;  (Ts/Te)_per Ratio Stats [Only good SWE and only good 3DP times]
;;----------------------------------------------------------------------------------------
;;
;;  (Te/Tp)_per [SWE, 3DP, ALL]        :    1.55e-02  4.10e+01  1.51e+00  1.15e+00  1.23e+00  1.22e-03
;;  (Te/Ta)_per [SWE, 3DP, ALL]        :    1.37e-02  2.81e+01  6.89e-01  2.76e-01  9.40e-01  9.28e-04
;;  (Te/Tp)_per [SWE, 3DP, No Shocks]  :    2.05e-02  6.76e+01  1.60e+00  1.12e+00  1.49e+00  1.52e-03
;;  (Te/Ta)_per [SWE, 3DP, No Shocks]  :    1.22e-02  3.20e+01  7.60e-01  2.70e-01  1.12e+00  1.14e-03
;;  (Te/Tp)_per [SWE, 3DP, Inside  MOs]:    3.93e-02  6.76e+01  2.70e+00  2.13e+00  2.26e+00  1.18e-02
;;  (Te/Ta)_per [SWE, 3DP, Inside  MOs]:    1.99e-02  1.92e+01  1.48e+00  9.02e-01  1.72e+00  8.92e-03
;;  (Te/Tp)_per [SWE, 3DP, Outside MOs]:    2.05e-02  5.59e+01  1.55e+00  1.09e+00  1.43e+00  1.44e-03
;;  (Te/Ta)_per [SWE, 3DP, Outside MOs]:    8.82e-03  3.20e+01  7.28e-01  2.60e-01  1.07e+00  1.08e-03
;;========================================================================================
;;
;;----------------------------------------------------------------------------------------
;;  (Ts/Te)_par Ratio Stats [Only good SWE and only good 3DP times]
;;----------------------------------------------------------------------------------------
;;
;;  (Te/Tp)_par [SWE, 3DP, ALL]        :    1.26e-03  8.75e+01  1.30e+00  9.05e-01  1.23e+00  1.22e-03
;;  (Te/Ta)_par [SWE, 3DP, ALL]        :    3.53e-04  3.74e+01  6.13e-01  2.33e-01  9.39e-01  9.27e-04
;;  (Te/Tp)_par [SWE, 3DP, No Shocks]  :    2.47e-03  1.22e+02  1.40e+00  8.73e-01  1.55e+00  1.58e-03
;;  (Te/Ta)_par [SWE, 3DP, No Shocks]  :    8.19e-03  3.74e+01  6.95e-01  2.23e-01  1.17e+00  1.20e-03
;;  (Te/Tp)_par [SWE, 3DP, Inside  MOs]:    3.50e-03  1.22e+02  2.65e+00  1.99e+00  2.52e+00  1.31e-02
;;  (Te/Ta)_par [SWE, 3DP, Inside  MOs]:    9.25e-04  2.68e+01  1.31e+00  7.14e-01  1.64e+00  8.52e-03
;;  (Te/Tp)_par [SWE, 3DP, Outside MOs]:    2.47e-03  8.09e+01  1.35e+00  8.53e-01  1.48e+00  1.48e-03
;;  (Te/Ta)_par [SWE, 3DP, Outside MOs]:    8.19e-03  3.74e+01  6.69e-01  2.17e-01  1.13e+00  1.14e-03
;;========================================================================================
;;
;;
;;----------------------------------------------------------------------------------------
;;  (Ta/Tp)_avg Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  (Ta/Tp)_avg [ALL, ALL, ALL]        :    1.01e-01  1.88e+01  2.44e+00  1.86e+00  1.37e+00  9.78e-04
;;  (Ta/Tp)_avg [ALL, ALL, No Shocks]  :    1.01e-01  1.88e+01  2.43e+00  1.85e+00  1.37e+00  1.02e-03
;;  (Ta/Tp)_avg [ALL, ALL, Inside  MOs]:    1.46e-01  1.08e+01  2.27e+00  1.78e+00  1.28e+00  3.95e-03
;;  (Ta/Tp)_avg [ALL, ALL, Outside MOs]:    1.01e-01  1.88e+01  2.45e+00  1.87e+00  1.38e+00  1.01e-03
;;
;;
;;  (Ta/Tp)_avg [ALL, 3DP, ALL]        :    1.46e-01  1.84e+01  2.50e+00  1.92e+00  1.38e+00  1.36e-03
;;  (Ta/Tp)_avg [ALL, 3DP, No Shocks]  :    1.46e-01  1.84e+01  2.50e+00  1.92e+00  1.39e+00  1.42e-03
;;  (Ta/Tp)_avg [ALL, 3DP, Inside  MOs]:    1.46e-01  1.08e+01  2.24e+00  1.73e+00  1.32e+00  6.88e-03
;;  (Ta/Tp)_avg [ALL, 3DP, Outside MOs]:    3.04e-01  1.84e+01  2.51e+00  1.94e+00  1.38e+00  1.39e-03
;;
;;
;;  (Ta/Tp)_avg [SWE, ALL, ALL]        :    3.77e-03  4.49e+02  4.08e+00  3.68e+00  3.21e+00  2.29e-03
;;  (Ta/Tp)_avg [SWE, ALL, No Shocks]  :    4.25e-03  4.49e+02  4.10e+00  3.72e+00  3.21e+00  2.39e-03
;;  (Ta/Tp)_avg [SWE, ALL, Inside  MOs]:    4.25e-03  1.12e+02  3.60e+00  2.64e+00  3.55e+00  1.09e-02
;;  (Ta/Tp)_avg [SWE, ALL, Outside MOs]:    3.77e-03  4.49e+02  4.11e+00  3.74e+00  3.19e+00  2.34e-03
;;
;;
;;  (Ta/Tp)_avg [SWE, 3DP, ALL]        :    3.77e-03  4.49e+02  3.98e+00  3.74e+00  2.82e+00  2.78e-03
;;  (Ta/Tp)_avg [SWE, 3DP, No Shocks]  :    8.91e-03  4.49e+02  4.00e+00  3.78e+00  2.83e+00  2.89e-03
;;  (Ta/Tp)_avg [SWE, 3DP, Inside  MOs]:    5.75e-03  6.15e+01  3.39e+00  2.59e+00  2.83e+00  1.47e-02
;;  (Ta/Tp)_avg [SWE, 3DP, Outside MOs]:    3.77e-03  4.49e+02  4.00e+00  3.78e+00  2.82e+00  2.83e-03
;;========================================================================================
;;
;;----------------------------------------------------------------------------------------
;;  (Ta/Tp)_per Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  (Ta/Tp)_per [ALL, ALL, ALL]        :    1.33e-01  1.10e+02  3.48e+00  3.70e+00  1.97e+00  1.41e-03
;;  (Ta/Tp)_per [ALL, ALL, No Shocks]  :    1.33e-01  1.10e+02  3.47e+00  3.70e+00  1.94e+00  1.45e-03
;;  (Ta/Tp)_per [ALL, ALL, Inside  MOs]:    1.67e-01  7.08e+01  3.36e+00  2.82e+00  2.43e+00  7.47e-03
;;  (Ta/Tp)_per [ALL, ALL, Outside MOs]:    1.33e-01  1.10e+02  3.49e+00  3.75e+00  1.93e+00  1.42e-03
;;
;;
;;  (Ta/Tp)_per [ALL, 3DP, ALL]        :    1.33e-01  1.01e+02  3.50e+00  3.73e+00  1.91e+00  1.89e-03
;;  (Ta/Tp)_per [ALL, 3DP, No Shocks]  :    1.33e-01  1.01e+02  3.50e+00  3.75e+00  1.90e+00  1.94e-03
;;  (Ta/Tp)_per [ALL, 3DP, Inside  MOs]:    2.87e-01  5.63e+01  3.20e+00  2.59e+00  2.21e+00  1.15e-02
;;  (Ta/Tp)_per [ALL, 3DP, Outside MOs]:    1.33e-01  1.01e+02  3.52e+00  3.77e+00  1.90e+00  1.91e-03
;;
;;
;;  (Ta/Tp)_per [SWE, ALL, ALL]        :    4.27e-03  3.59e+02  4.12e+00  3.62e+00  3.32e+00  2.37e-03
;;  (Ta/Tp)_per [SWE, ALL, No Shocks]  :    4.27e-03  3.59e+02  4.12e+00  3.64e+00  3.27e+00  2.44e-03
;;  (Ta/Tp)_per [SWE, ALL, Inside  MOs]:    4.27e-03  1.47e+02  3.84e+00  2.59e+00  4.18e+00  1.28e-02
;;  (Ta/Tp)_per [SWE, ALL, Outside MOs]:    1.03e-02  3.59e+02  4.13e+00  3.67e+00  3.26e+00  2.39e-03
;;
;;
;;  (Ta/Tp)_per [SWE, 3DP, ALL]        :    1.08e-02  1.71e+02  4.03e+00  3.69e+00  2.88e+00  2.84e-03
;;  (Ta/Tp)_per [SWE, 3DP, No Shocks]  :    4.51e-02  1.71e+02  4.04e+00  3.72e+00  2.85e+00  2.92e-03
;;  (Ta/Tp)_per [SWE, 3DP, Inside  MOs]:    1.06e-01  7.76e+01  3.58e+00  2.33e+00  3.67e+00  1.91e-02
;;  (Ta/Tp)_per [SWE, 3DP, Outside MOs]:    1.08e-02  1.71e+02  4.05e+00  3.73e+00  2.85e+00  2.86e-03
;;========================================================================================
;;
;;----------------------------------------------------------------------------------------
;;  (Ta/Tp)_par Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  (Ta/Tp)_par [ALL, ALL, ALL]        :    2.85e-02  7.99e+01  2.64e+00  1.96e+00  1.90e+00  1.36e-03
;;  (Ta/Tp)_par [ALL, ALL, No Shocks]  :    2.85e-02  7.99e+01  2.66e+00  1.95e+00  1.92e+00  1.44e-03
;;  (Ta/Tp)_par [ALL, ALL, Inside  MOs]:    2.85e-02  2.02e+01  2.26e+00  1.77e+00  1.57e+00  4.81e-03
;;  (Ta/Tp)_par [ALL, ALL, Outside MOs]:    2.97e-02  7.99e+01  2.67e+00  1.98e+00  1.93e+00  1.41e-03
;;
;;
;;  (Ta/Tp)_par [ALL, 3DP, ALL]        :    2.85e-02  5.73e+01  2.74e+00  2.07e+00  1.91e+00  1.88e-03
;;  (Ta/Tp)_par [ALL, 3DP, No Shocks]  :    2.85e-02  5.73e+01  2.76e+00  2.08e+00  1.93e+00  1.97e-03
;;  (Ta/Tp)_par [ALL, 3DP, Inside  MOs]:    2.85e-02  1.62e+01  2.31e+00  1.75e+00  1.67e+00  8.68e-03
;;  (Ta/Tp)_par [ALL, 3DP, Outside MOs]:    5.64e-02  5.73e+01  2.76e+00  2.10e+00  1.92e+00  1.93e-03
;;
;;
;;  (Ta/Tp)_par [SWE, ALL, ALL]        :    8.64e-04  1.14e+03  4.65e+00  3.51e+00  5.59e+00  3.99e-03
;;  (Ta/Tp)_par [SWE, ALL, No Shocks]  :    8.64e-04  9.04e+02  4.71e+00  3.58e+00  5.60e+00  4.18e-03
;;  (Ta/Tp)_par [SWE, ALL, Inside  MOs]:    8.64e-04  1.14e+03  3.82e+00  2.48e+00  6.46e+00  1.99e-02
;;  (Ta/Tp)_par [SWE, ALL, Outside MOs]:    1.60e-03  9.04e+02  4.69e+00  3.57e+00  5.53e+00  4.06e-03
;;
;;
;;  (Ta/Tp)_par [SWE, 3DP, ALL]        :    1.64e-03  7.17e+02  4.35e+00  3.53e+00  4.45e+00  4.39e-03
;;  (Ta/Tp)_par [SWE, 3DP, No Shocks]  :    1.78e-03  7.17e+02  4.40e+00  3.58e+00  4.50e+00  4.60e-03
;;  (Ta/Tp)_par [SWE, 3DP, Inside  MOs]:    3.43e-03  1.47e+02  3.48e+00  2.56e+00  3.51e+00  1.83e-02
;;  (Ta/Tp)_par [SWE, 3DP, Outside MOs]:    1.64e-03  7.17e+02  4.38e+00  3.56e+00  4.48e+00  4.50e-03
;;========================================================================================


























































































