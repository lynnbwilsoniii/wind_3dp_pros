;;  @/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/print_wind_3dp_swe_onevar_stats_new_batch.pro
;;
;;  Note:  User must call the following prior to running this batch file
;;         @/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_new_batch.pro

test           = (N_ELEMENTS(Tr_avg_epeaap) LT 2) OR (is_a_number(beta_per_epa,/NOMSSG) EQ 0)
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
PRINT,';;  Total Number of ALL Values'
PRINT,line0[0]
;;  Print # of values (Ts1/Ts2)_avg ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Tr_avg_epeaap[*,0,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Tp)_avg [ALL, ALL, ALL]        :  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[*,1,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Ta)_avg [ALL, ALL, ALL]        :  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[*,2,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Ta/Tp)_avg [ALL, ALL, ALL]        :  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[out_ip_shock,0,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Tp)_avg [ALL, ALL, No Shocks]  :  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[out_ip_shock,1,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Ta)_avg [ALL, ALL, No Shocks]  :  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[out_ip_shock,2,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Ta/Tp)_avg [ALL, ALL, No Shocks]  :  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[in__mo_all,0,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Tp)_avg [ALL, ALL, Inside  MOs]:  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[in__mo_all,1,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Ta)_avg [ALL, ALL, Inside  MOs]:  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[in__mo_all,2,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Ta/Tp)_avg [ALL, ALL, Inside  MOs]:  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[out_mo_all,0,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Tp)_avg [ALL, ALL, Outside MOs]:  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[out_mo_all,1,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Ta)_avg [ALL, ALL, Outside MOs]:  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[out_mo_all,2,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Ta/Tp)_avg [ALL, ALL, Outside MOs]:  ',stats[0]                                                     & $
PRINT,';;'

;;  Print Finite # of values (Ts1/Ts2)_avg ratios [ALL SWE and ALL 3DP times]
PRINT,line0[0]
PRINT,';;  Finite Number of ALL Values'
PRINT,line0[0]
PRINT,';;'                                                                                                                  & $
x              = Tr_avg_epeaap[*,0,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Tp)_avg [ALL, ALL, ALL]        :  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[*,1,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Ta)_avg [ALL, ALL, ALL]        :  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[*,2,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Ta/Tp)_avg [ALL, ALL, ALL]        :  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[out_ip_shock,0,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Tp)_avg [ALL, ALL, No Shocks]  :  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[out_ip_shock,1,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Ta)_avg [ALL, ALL, No Shocks]  :  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[out_ip_shock,2,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Ta/Tp)_avg [ALL, ALL, No Shocks]  :  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[in__mo_all,0,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Tp)_avg [ALL, ALL, Inside  MOs]:  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[in__mo_all,1,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Ta)_avg [ALL, ALL, Inside  MOs]:  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[in__mo_all,2,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Ta/Tp)_avg [ALL, ALL, Inside  MOs]:  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[out_mo_all,0,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Tp)_avg [ALL, ALL, Outside MOs]:  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[out_mo_all,1,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Ta)_avg [ALL, ALL, Outside MOs]:  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[out_mo_all,2,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Ta/Tp)_avg [ALL, ALL, Outside MOs]:  ',stats[1]                                                     & $
PRINT,';;'

;;  Print # of values (Ts1/Ts2)_avg ratios [Only good SWE and only good 3DP times]
PRINT,line0[0]
PRINT,';;  Total Number of Good Values'
PRINT,line0[0]
PRINT,';;'                                                                                                                  & $
x              = Tr_avg_epeaap[*,0,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Tp)_avg [SWE, 3DP, ALL]        :  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[*,1,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Ta)_avg [SWE, 3DP, ALL]        :  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[*,2,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Ta/Tp)_avg [SWE, 3DP, ALL]        :  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[out_ip_shock,0,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Tp)_avg [SWE, 3DP, No Shocks]  :  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[out_ip_shock,1,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Ta)_avg [SWE, 3DP, No Shocks]  :  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[out_ip_shock,2,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Ta/Tp)_avg [SWE, 3DP, No Shocks]  :  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[in__mo_all,0,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Tp)_avg [SWE, 3DP, Inside  MOs]:  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[in__mo_all,1,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Ta)_avg [SWE, 3DP, Inside  MOs]:  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[in__mo_all,2,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Ta/Tp)_avg [SWE, 3DP, Inside  MOs]:  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[out_mo_all,0,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Tp)_avg [SWE, 3DP, Outside MOs]:  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[out_mo_all,1,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Te/Ta)_avg [SWE, 3DP, Outside MOs]:  ',stats[0]                                                     & $
x              = Tr_avg_epeaap[out_mo_all,2,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Total  # of (Ta/Tp)_avg [SWE, 3DP, Outside MOs]:  ',stats[0]                                                     & $
PRINT,';;'

;;  Print Finite # of values (Ts1/Ts2)_avg ratios [Only good SWE and only good 3DP times]
PRINT,line0[0]
PRINT,';;  Finite Number of Good Values'
PRINT,line0[0]
PRINT,';;'                                                                                                                  & $
x              = Tr_avg_epeaap[*,0,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Tp)_avg [SWE, 3DP, ALL]        :  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[*,1,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Ta)_avg [SWE, 3DP, ALL]        :  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[*,2,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Ta/Tp)_avg [SWE, 3DP, ALL]        :  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[out_ip_shock,0,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Tp)_avg [SWE, 3DP, No Shocks]  :  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[out_ip_shock,1,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Ta)_avg [SWE, 3DP, No Shocks]  :  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[out_ip_shock,2,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Ta/Tp)_avg [SWE, 3DP, No Shocks]  :  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[in__mo_all,0,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Tp)_avg [SWE, 3DP, Inside  MOs]:  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[in__mo_all,1,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Ta)_avg [SWE, 3DP, Inside  MOs]:  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[in__mo_all,2,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Ta/Tp)_avg [SWE, 3DP, Inside  MOs]:  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[out_mo_all,0,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Tp)_avg [SWE, 3DP, Outside MOs]:  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[out_mo_all,1,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Te/Ta)_avg [SWE, 3DP, Outside MOs]:  ',stats[1]                                                     & $
x              = Tr_avg_epeaap[out_mo_all,2,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = (num2int_str([N_ELEMENTS(x),N_ELEMENTS(y)],NUM_CHAR=10,/ZERO_PAD))                                         & $
PRINT,';;  Finite # of (Ta/Tp)_avg [SWE, 3DP, Outside MOs]:  ',stats[1]                                                     & $
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  beta_s_avg ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  beta_s_avg Ratio Stats'
PRINT,line0[0]
;;  Print beta_s_avg ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_avg_epa[*,0,0]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_avg [ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[*,1,0]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_avg [ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[*,2,0]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_avg [ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_ip_shock,0,0]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_avg [ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_ip_shock,1,0]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_avg [ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_ip_shock,2,0]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_avg [ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[in__mo_all,0,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_avg [ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[in__mo_all,1,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_avg [ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[in__mo_all,2,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_avg [ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_mo_all,0,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_avg [ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_mo_all,1,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_avg [ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_mo_all,2,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_avg [ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
PRINT,';;'
;;  Print beta_s_avg ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_avg_epa[*,0,1]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_avg [3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[*,1,1]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_avg [SWE, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[*,2,1]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_avg [SWE, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_ip_shock,0,1]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_avg [3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_ip_shock,1,1]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_avg [SWE, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_ip_shock,2,1]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_avg [SWE, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[in__mo_all,0,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_avg [3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[in__mo_all,1,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_avg [SWE, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[in__mo_all,2,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_avg [SWE, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_mo_all,0,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_avg [3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_mo_all,1,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_avg [SWE, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_avg_epa[out_mo_all,2,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_avg [SWE, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  beta_s_per ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  beta_s_per Ratio Stats'
PRINT,line0[0]
;;  Print beta_s_per ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_per_epa[*,0,0]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_per [ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[*,1,0]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_per [ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[*,2,0]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_per [ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_ip_shock,0,0]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_per [ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_ip_shock,1,0]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_per [ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_ip_shock,2,0]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_per [ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[in__mo_all,0,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_per [ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[in__mo_all,1,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_per [ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[in__mo_all,2,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_per [ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_mo_all,0,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_per [ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_mo_all,1,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_per [ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_mo_all,2,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_per [ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
PRINT,';;'
;;  Print beta_s_per ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_per_epa[*,0,1]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_per [3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[*,1,1]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_per [SWE, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[*,2,1]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_per [SWE, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_ip_shock,0,1]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_per [3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_ip_shock,1,1]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_per [SWE, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_ip_shock,2,1]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_per [SWE, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[in__mo_all,0,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_per [3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[in__mo_all,1,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_per [SWE, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[in__mo_all,2,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_per [SWE, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_mo_all,0,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_per [3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_mo_all,1,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_per [SWE, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_per_epa[out_mo_all,2,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_per [SWE, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  beta_s_par ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  beta_s_par Ratio Stats'
PRINT,line0[0]
;;  Print beta_s_par ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_par_epa[*,0,0]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_par [ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[*,1,0]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_par [ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[*,2,0]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_par [ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_ip_shock,0,0]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_par [ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_ip_shock,1,0]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_par [ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_ip_shock,2,0]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_par [ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[in__mo_all,0,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_par [ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[in__mo_all,1,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_par [ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[in__mo_all,2,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_par [ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_mo_all,0,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_par [ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_mo_all,1,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_par [ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_mo_all,2,0]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_par [ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
PRINT,';;'
;;  Print beta_s_par ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = beta_par_epa[*,0,1]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_par [3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[*,1,1]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_par [SWE, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[*,2,1]                                                                                        & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_par [SWE, ALL]        :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_ip_shock,0,1]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_par [3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_ip_shock,1,1]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_par [SWE, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_ip_shock,2,1]                                                                             & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_par [SWE, No Shocks]  :  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[in__mo_all,0,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_par [3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[in__mo_all,1,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_par [SWE, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[in__mo_all,2,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_par [SWE, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_mo_all,0,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_e_par [3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_mo_all,1,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_p_par [SWE, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
x              = beta_par_epa[out_mo_all,2,1]                                                                               & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  beta_a_par [SWE, Outside MOs]:  ',stats,FORMAT=mform[0]                                                          & $
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ts1/Ts2)_avg ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ts/Te)_avg Ratio Stats'
PRINT,line0[0]
;;  Print (Ts1/Ts2)_avg ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Tr_avg_epeaap[*,0,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_avg [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[*,1,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_avg [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[*,2,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_avg [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_ip_shock,0,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_avg [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_ip_shock,1,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_avg [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_ip_shock,2,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_avg [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[in__mo_all,0,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_avg [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[in__mo_all,1,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_avg [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[in__mo_all,2,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_avg [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_mo_all,0,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_avg [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_mo_all,1,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_avg [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_mo_all,2,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_avg [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'
;;  Print (Ts/Te)_avg ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Tr_avg_epeaap[*,0,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[*,1,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[*,2,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_avg [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_ip_shock,0,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_ip_shock,1,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_ip_shock,2,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_avg [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[in__mo_all,0,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[in__mo_all,1,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[in__mo_all,2,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_avg [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_mo_all,0,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_avg [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_mo_all,1,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_avg [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_avg_epeaap[out_mo_all,2,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_avg [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,line1[0]
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ts1/Ts2)_per ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ts/Te)_per Ratio Stats'
PRINT,line0[0]
;;  Print (Ts1/Ts2)_per ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Tr_per_epeaap[*,0,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_per [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[*,1,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_per [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[*,2,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_per [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_ip_shock,0,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_per [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_ip_shock,1,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_per [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_ip_shock,2,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_per [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[in__mo_all,0,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_per [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[in__mo_all,1,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_per [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[in__mo_all,2,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_per [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_mo_all,0,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_per [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_mo_all,1,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_per [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_mo_all,2,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_per [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'
;;  Print (Ts/Te)_per ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Tr_per_epeaap[*,0,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[*,1,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[*,2,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_per [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_ip_shock,0,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_ip_shock,1,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_ip_shock,2,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_per [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[in__mo_all,0,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[in__mo_all,1,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[in__mo_all,2,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_per [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_mo_all,0,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_per [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_mo_all,1,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_per [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_per_epeaap[out_mo_all,2,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_per [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,line1[0]
PRINT,';;'

;;----------------------------------------------------------------------------------------
;;  Print stats:  (Ts1/Ts2)_par ratios
;;----------------------------------------------------------------------------------------
PRINT,line0[0]
PRINT,';;  (Ts/Te)_par Ratio Stats'
PRINT,line0[0]
;;  Print (Ts1/Ts2)_par ratios [ALL SWE and ALL 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Tr_par_epeaap[*,0,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_par [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[*,1,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_par [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[*,2,0,0]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_par [ALL, ALL, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_ip_shock,0,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_par [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_ip_shock,1,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_par [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_ip_shock,2,0,0]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_par [ALL, ALL, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[in__mo_all,0,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_par [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[in__mo_all,1,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_par [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[in__mo_all,2,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_par [ALL, ALL, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_mo_all,0,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_par [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_mo_all,1,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_par [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_mo_all,2,0,0]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_par [ALL, ALL, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,';;'
;;  Print (Ts/Te)_par ratios [Only good SWE and only good 3DP times]
PRINT,';;'                                                                                                                  & $
x              = Tr_par_epeaap[*,0,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[*,1,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[*,2,1,1]                                                                                     & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_par [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_ip_shock,0,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_ip_shock,1,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_ip_shock,2,1,1]                                                                          & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_par [SWE, 3DP, No Shocks]  :  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[in__mo_all,0,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[in__mo_all,1,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[in__mo_all,2,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_par [SWE, 3DP, Inside  MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_mo_all,0,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Tp)_par [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_mo_all,1,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Te/Ta)_par [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
x              = Tr_par_epeaap[out_mo_all,2,1,1]                                                                            & $
y              = WHERE(FINITE(x))                                                                                           & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(y))]     & $
PRINT,';;  (Ta/Tp)_par [SWE, 3DP, Outside MOs]:  ',stats,FORMAT=mform[0]                                                    & $
PRINT,line1[0]
PRINT,';;'


;;  in__ip_shock  :  During IP shocks
;;  out_ip_shock  :  Excluding IP shocks
;;
;;  in__mo_all    :  During Magnetic Obstacles (MOs)
;;  out_mo_all    :  Excluding MOs
;;----------------------------------------------------------------------------------------
;;  Total Number of ALL Values
;;----------------------------------------------------------------------------------------
;;
;;  Total  # of (Te/Tp)_avg [ALL, ALL, ALL]        :  0002630161
;;  Total  # of (Te/Ta)_avg [ALL, ALL, ALL]        :  0002630161
;;  Total  # of (Ta/Tp)_avg [ALL, ALL, ALL]        :  0002630161
;;  Total  # of (Te/Tp)_avg [ALL, ALL, No Shocks]  :  0002435510
;;  Total  # of (Te/Ta)_avg [ALL, ALL, No Shocks]  :  0002435510
;;  Total  # of (Ta/Tp)_avg [ALL, ALL, No Shocks]  :  0002435510
;;  Total  # of (Te/Tp)_avg [ALL, ALL, Inside  MOs]:  0000128109
;;  Total  # of (Te/Ta)_avg [ALL, ALL, Inside  MOs]:  0000128109
;;  Total  # of (Ta/Tp)_avg [ALL, ALL, Inside  MOs]:  0000128109
;;  Total  # of (Te/Tp)_avg [ALL, ALL, Outside MOs]:  0002502052
;;  Total  # of (Te/Ta)_avg [ALL, ALL, Outside MOs]:  0002502052
;;  Total  # of (Ta/Tp)_avg [ALL, ALL, Outside MOs]:  0002502052
;;
;;----------------------------------------------------------------------------------------
;;  Finite Number of ALL Values
;;----------------------------------------------------------------------------------------
;;
;;  Finite # of (Te/Tp)_avg [ALL, ALL, ALL]        :  0001202389
;;  Finite # of (Te/Ta)_avg [ALL, ALL, ALL]        :  0000293545
;;  Finite # of (Ta/Tp)_avg [ALL, ALL, ALL]        :  0000492444
;;  Finite # of (Te/Tp)_avg [ALL, ALL, No Shocks]  :  0001103970
;;  Finite # of (Te/Ta)_avg [ALL, ALL, No Shocks]  :  0000265101
;;  Finite # of (Ta/Tp)_avg [ALL, ALL, No Shocks]  :  0000443119
;;  Finite # of (Te/Tp)_avg [ALL, ALL, Inside  MOs]:  0000060170
;;  Finite # of (Te/Ta)_avg [ALL, ALL, Inside  MOs]:  0000023784
;;  Finite # of (Ta/Tp)_avg [ALL, ALL, Inside  MOs]:  0000045763
;;  Finite # of (Te/Tp)_avg [ALL, ALL, Outside MOs]:  0001142219
;;  Finite # of (Te/Ta)_avg [ALL, ALL, Outside MOs]:  0000269761
;;  Finite # of (Ta/Tp)_avg [ALL, ALL, Outside MOs]:  0000446681
;;
;;----------------------------------------------------------------------------------------
;;  Total Number of Good Values
;;----------------------------------------------------------------------------------------
;;
;;  Total  # of (Te/Tp)_avg [SWE, 3DP, ALL]        :  0002630161
;;  Total  # of (Te/Ta)_avg [SWE, 3DP, ALL]        :  0002630161
;;  Total  # of (Ta/Tp)_avg [SWE, 3DP, ALL]        :  0002630161
;;  Total  # of (Te/Tp)_avg [SWE, 3DP, No Shocks]  :  0002435510
;;  Total  # of (Te/Ta)_avg [SWE, 3DP, No Shocks]  :  0002435510
;;  Total  # of (Ta/Tp)_avg [SWE, 3DP, No Shocks]  :  0002435510
;;  Total  # of (Te/Tp)_avg [SWE, 3DP, Inside  MOs]:  0000128109
;;  Total  # of (Te/Ta)_avg [SWE, 3DP, Inside  MOs]:  0000128109
;;  Total  # of (Ta/Tp)_avg [SWE, 3DP, Inside  MOs]:  0000128109
;;  Total  # of (Te/Tp)_avg [SWE, 3DP, Outside MOs]:  0002502052
;;  Total  # of (Te/Ta)_avg [SWE, 3DP, Outside MOs]:  0002502052
;;  Total  # of (Ta/Tp)_avg [SWE, 3DP, Outside MOs]:  0002502052
;;
;;----------------------------------------------------------------------------------------
;;  Finite Number of Good Values
;;----------------------------------------------------------------------------------------
;;
;;  Finite # of (Te/Tp)_avg [SWE, 3DP, ALL]        :  0000445801
;;  Finite # of (Te/Ta)_avg [SWE, 3DP, ALL]        :  0000193704
;;  Finite # of (Ta/Tp)_avg [SWE, 3DP, ALL]        :  0000476255
;;  Finite # of (Te/Tp)_avg [SWE, 3DP, No Shocks]  :  0000412947
;;  Finite # of (Te/Ta)_avg [SWE, 3DP, No Shocks]  :  0000177265
;;  Finite # of (Ta/Tp)_avg [SWE, 3DP, No Shocks]  :  0000428536
;;  Finite # of (Te/Tp)_avg [SWE, 3DP, Inside  MOs]:  0000018203
;;  Finite # of (Te/Ta)_avg [SWE, 3DP, Inside  MOs]:  0000010077
;;  Finite # of (Ta/Tp)_avg [SWE, 3DP, Inside  MOs]:  0000043343
;;  Finite # of (Te/Tp)_avg [SWE, 3DP, Outside MOs]:  0000427598
;;  Finite # of (Te/Ta)_avg [SWE, 3DP, Outside MOs]:  0000183627
;;  Finite # of (Ta/Tp)_avg [SWE, 3DP, Outside MOs]:  0000432912
;;
;;----------------------------------------------------------------------------------------
;;  beta_s_avg Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  beta_e_avg [ALL, ALL]        :    1.26e-03  8.87e+03  1.73e+00  8.25e-01  1.42e+01  1.24e-02
;;  beta_p_avg [ALL, ALL]        :    3.47e-04  1.42e+04  1.48e+00  8.90e-01  1.54e+01  1.04e-02
;;  beta_a_avg [ALL, ALL]        :    4.88e-05  6.12e+02  1.62e-01  5.02e-02  1.33e+00  1.90e-03
;;  beta_e_avg [ALL, No Shocks]  :    3.42e-03  8.87e+03  1.77e+00  8.44e-01  1.47e+01  1.35e-02
;;  beta_p_avg [ALL, No Shocks]  :    3.47e-04  1.15e+04  1.48e+00  9.03e-01  1.24e+01  8.71e-03
;;  beta_a_avg [ALL, No Shocks]  :    4.88e-05  2.95e+02  1.59e-01  5.11e-02  9.71e-01  1.46e-03
;;  beta_e_avg [ALL, Inside  MOs]:    1.26e-03  5.06e+01  3.84e-01  2.75e-01  5.91e-01  2.28e-03
;;  beta_p_avg [ALL, Inside  MOs]:    3.47e-04  4.84e+02  3.04e-01  1.44e-01  1.78e+00  5.37e-03
;;  beta_a_avg [ALL, Inside  MOs]:    4.88e-05  2.94e+01  2.80e-02  7.88e-03  1.68e-01  7.84e-04
;;  beta_e_avg [ALL, Outside MOs]:    4.20e-03  8.87e+03  1.80e+00  8.66e-01  1.45e+01  1.31e-02
;;  beta_p_avg [ALL, Outside MOs]:    5.00e-04  1.42e+04  1.54e+00  9.34e-01  1.58e+01  1.09e-02
;;  beta_a_avg [ALL, Outside MOs]:    1.75e-04  6.12e+02  1.76e-01  5.99e-02  1.40e+00  2.09e-03
;;
;;
;;  beta_e_avg [3DP, ALL]        :    3.95e-03  8.87e+03  2.06e+00  9.74e-01  1.68e+01  1.85e-02
;;  beta_p_avg [SWE, ALL]        :    9.51e-04  4.57e+03  1.79e+00  1.05e+00  1.14e+01  1.09e-02
;;  beta_a_avg [SWE, ALL]        :    4.88e-05  6.12e+02  1.68e-01  5.23e-02  1.35e+00  1.96e-03
;;  beta_e_avg [3DP, No Shocks]  :    5.49e-03  8.87e+03  2.10e+00  9.91e-01  1.73e+01  1.99e-02
;;  beta_p_avg [SWE, No Shocks]  :    1.38e-03  4.57e+03  1.81e+00  1.07e+00  1.16e+01  1.16e-02
;;  beta_a_avg [SWE, No Shocks]  :    4.88e-05  2.95e+02  1.64e-01  5.33e-02  9.86e-01  1.51e-03
;;  beta_e_avg [3DP, Inside  MOs]:    3.95e-03  3.72e+01  4.64e-01  3.24e-01  6.39e-01  3.73e-03
;;  beta_p_avg [SWE, Inside  MOs]:    9.51e-04  1.60e+02  2.92e-01  1.26e-01  1.11e+00  4.14e-03
;;  beta_a_avg [SWE, Inside  MOs]:    4.88e-05  2.94e+01  2.88e-02  7.90e-03  1.73e-01  8.29e-04
;;  beta_e_avg [3DP, Outside MOs]:    1.21e-02  8.87e+03  2.12e+00  1.01e+00  1.71e+01  1.92e-02
;;  beta_p_avg [SWE, Outside MOs]:    2.06e-03  4.57e+03  1.90e+00  1.11e+00  1.18e+01  1.16e-02
;;  beta_a_avg [SWE, Outside MOs]:    1.75e-04  6.12e+02  1.82e-01  6.23e-02  1.42e+00  2.15e-03
;;
;;----------------------------------------------------------------------------------------
;;  beta_s_per Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  beta_e_per [ALL, ALL]        :    1.51e-03  8.91e+03  1.81e+00  9.18e-01  1.42e+01  1.24e-02
;;  beta_p_per [ALL, ALL]        :    3.71e-05  1.49e+04  1.44e+00  8.23e-01  1.64e+01  1.09e-02
;;  beta_a_per [ALL, ALL]        :    3.41e-05  5.95e+02  1.78e-01  7.74e-02  1.18e+00  1.10e-03
;;  beta_e_per [ALL, No Shocks]  :    3.90e-03  8.91e+03  1.85e+00  9.38e-01  1.47e+01  1.35e-02
;;  beta_p_per [ALL, No Shocks]  :    8.47e-05  1.38e+04  1.44e+00  8.36e-01  1.35e+01  9.33e-03
;;  beta_a_per [ALL, No Shocks]  :    3.41e-05  5.77e+02  1.77e-01  7.99e-02  1.04e+00  1.02e-03
;;  beta_e_per [ALL, Inside  MOs]:    1.51e-03  5.19e+01  4.28e-01  3.15e-01  6.23e-01  2.41e-03
;;  beta_p_per [ALL, Inside  MOs]:    3.71e-05  4.65e+02  2.92e-01  1.38e-01  2.14e+00  6.35e-03
;;  beta_a_per [ALL, Inside  MOs]:    3.41e-05  4.98e+01  3.43e-02  9.88e-03  2.28e-01  8.18e-04
;;  beta_e_per [ALL, Outside MOs]:    4.69e-03  8.91e+03  1.88e+00  9.59e-01  1.45e+01  1.31e-02
;;  beta_p_per [ALL, Outside MOs]:    2.59e-04  1.49e+04  1.50e+00  8.64e-01  1.68e+01  1.14e-02
;;  beta_a_per [ALL, Outside MOs]:    5.14e-05  5.95e+02  1.89e-01  8.69e-02  1.22e+00  1.17e-03
;;
;;
;;  beta_e_per [3DP, ALL]        :    4.77e-03  8.91e+03  2.12e+00  1.05e+00  1.68e+01  1.85e-02
;;  beta_p_per [SWE, ALL]        :    3.71e-05  4.39e+03  1.70e+00  9.22e-01  1.13e+01  1.07e-02
;;  beta_a_per [SWE, ALL]        :    5.14e-05  5.95e+02  1.93e-01  8.05e-02  1.23e+00  1.31e-03
;;  beta_e_per [3DP, No Shocks]  :    5.84e-03  8.91e+03  2.17e+00  1.07e+00  1.73e+01  1.99e-02
;;  beta_p_per [SWE, No Shocks]  :    8.47e-05  4.39e+03  1.71e+00  9.39e-01  1.16e+01  1.14e-02
;;  beta_a_per [SWE, No Shocks]  :    7.58e-05  3.73e+02  1.91e-01  8.33e-02  1.04e+00  1.16e-03
;;  beta_e_per [3DP, Inside  MOs]:    4.77e-03  3.86e+01  4.96e-01  3.50e-01  6.69e-01  3.90e-03
;;  beta_p_per [SWE, Inside  MOs]:    3.71e-05  1.58e+02  2.76e-01  1.21e-01  1.11e+00  4.09e-03
;;  beta_a_per [SWE, Inside  MOs]:    5.16e-05  4.98e+01  3.54e-02  9.08e-03  2.53e-01  1.00e-03
;;  beta_e_per [3DP, Outside MOs]:    1.58e-02  8.91e+03  2.19e+00  1.08e+00  1.71e+01  1.92e-02
;;  beta_p_per [SWE, Outside MOs]:    2.59e-04  4.39e+03  1.80e+00  9.85e-01  1.17e+01  1.14e-02
;;  beta_a_per [SWE, Outside MOs]:    5.14e-05  5.95e+02  2.05e-01  9.24e-02  1.27e+00  1.41e-03
;;
;;----------------------------------------------------------------------------------------
;;  beta_s_par Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  beta_e_par [ALL, ALL]        :    1.14e-03  8.85e+03  1.69e+00  7.80e-01  1.42e+01  1.24e-02
;;  beta_p_par [ALL, ALL]        :    1.68e-05  1.28e+04  1.66e+00  1.03e+00  1.36e+01  9.12e-03
;;  beta_a_par [ALL, ALL]        :    2.15e-05  6.48e+02  2.16e-01  6.95e-02  1.46e+00  1.90e-03
;;  beta_e_par [ALL, No Shocks]  :    3.10e-03  8.85e+03  1.73e+00  7.99e-01  1.47e+01  1.35e-02
;;  beta_p_par [ALL, No Shocks]  :    1.68e-05  6.96e+03  1.66e+00  1.04e+00  1.08e+01  7.52e-03
;;  beta_a_par [ALL, No Shocks]  :    2.15e-05  4.15e+02  2.16e-01  7.24e-02  1.17e+00  1.60e-03
;;  beta_e_par [ALL, Inside  MOs]:    1.14e-03  5.00e+01  3.62e-01  2.53e-01  5.77e-01  2.23e-03
;;  beta_p_par [ALL, Inside  MOs]:    5.66e-05  5.23e+02  3.57e-01  1.46e-01  1.91e+00  5.74e-03
;;  beta_a_par [ALL, Inside  MOs]:    2.15e-05  3.21e+01  3.37e-02  7.55e-03  1.87e-01  8.52e-04
;;  beta_e_par [ALL, Outside MOs]:    3.95e-03  8.85e+03  1.76e+00  8.22e-01  1.46e+01  1.31e-02
;;  beta_p_par [ALL, Outside MOs]:    1.68e-05  1.28e+04  1.73e+00  1.09e+00  1.40e+01  9.58e-03
;;  beta_a_par [ALL, Outside MOs]:    5.87e-05  6.48e+02  2.32e-01  8.32e-02  1.52e+00  2.07e-03
;;
;;
;;  beta_e_par [3DP, ALL]        :    3.55e-03  8.85e+03  2.03e+00  9.37e-01  1.68e+01  1.85e-02
;;  beta_p_par [SWE, ALL]        :    5.66e-05  4.92e+03  2.05e+00  1.29e+00  1.16e+01  1.10e-02
;;  beta_a_par [SWE, ALL]        :    2.15e-05  6.48e+02  2.24e-01  7.18e-02  1.49e+00  1.99e-03
;;  beta_e_par [3DP, No Shocks]  :    5.31e-03  8.85e+03  2.07e+00  9.53e-01  1.74e+01  1.99e-02
;;  beta_p_par [SWE, No Shocks]  :    1.13e-04  4.92e+03  2.07e+00  1.32e+00  1.17e+01  1.17e-02
;;  beta_a_par [SWE, No Shocks]  :    2.15e-05  4.15e+02  2.25e-01  7.50e-02  1.20e+00  1.68e-03
;;  beta_e_par [3DP, Inside  MOs]:    3.55e-03  3.65e+01  4.47e-01  3.11e-01  6.25e-01  3.65e-03
;;  beta_p_par [SWE, Inside  MOs]:    5.66e-05  1.65e+02  3.44e-01  1.30e-01  1.18e+00  4.36e-03
;;  beta_a_par [SWE, Inside  MOs]:    2.15e-05  3.21e+01  3.43e-02  7.45e-03  1.92e-01  8.98e-04
;;  beta_e_par [3DP, Outside MOs]:    9.72e-03  8.85e+03  2.09e+00  9.71e-01  1.71e+01  1.92e-02
;;  beta_p_par [SWE, Outside MOs]:    1.44e-04  4.92e+03  2.17e+00  1.38e+00  1.20e+01  1.18e-02
;;  beta_a_par [SWE, Outside MOs]:    5.87e-05  6.48e+02  2.41e-01  8.61e-02  1.56e+00  2.16e-03
;;
;;----------------------------------------------------------------------------------------
;;  (Ts/Te)_avg Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  (Te/Tp)_avg [ALL, ALL, ALL]        :    1.51e-02  1.66e+02  1.33e+00  9.51e-01  1.28e+00  1.17e-03
;;  (Te/Ta)_avg [ALL, ALL, ALL]        :    1.12e-02  4.15e+01  1.28e+00  8.15e-01  1.38e+00  2.55e-03
;;  (Ta/Tp)_avg [ALL, ALL, ALL]        :    2.35e-02  1.73e+03  2.48e+00  1.92e+00  2.97e+00  4.23e-03
;;  (Te/Tp)_avg [ALL, ALL, No Shocks]  :    1.51e-02  7.24e+01  1.33e+00  9.53e-01  1.26e+00  1.20e-03
;;  (Te/Ta)_avg [ALL, ALL, No Shocks]  :    1.12e-02  4.15e+01  1.30e+00  8.28e-01  1.38e+00  2.69e-03
;;  (Ta/Tp)_avg [ALL, ALL, No Shocks]  :    2.44e-02  1.73e+03  2.46e+00  1.90e+00  3.09e+00  4.65e-03
;;  (Te/Tp)_avg [ALL, ALL, Inside  MOs]:    1.51e-02  3.85e+01  2.53e+00  1.78e+00  2.52e+00  1.03e-02
;;  (Te/Ta)_avg [ALL, ALL, Inside  MOs]:    3.19e-02  4.15e+01  2.21e+00  1.54e+00  2.27e+00  1.47e-02
;;  (Ta/Tp)_avg [ALL, ALL, Inside  MOs]:    2.44e-02  1.64e+01  2.23e+00  1.74e+00  1.35e+00  6.32e-03
;;  (Te/Tp)_avg [ALL, ALL, Outside MOs]:    1.61e-02  1.66e+02  1.27e+00  9.26e-01  1.14e+00  1.07e-03
;;  (Te/Ta)_avg [ALL, ALL, Outside MOs]:    1.12e-02  3.16e+01  1.20e+00  7.73e-01  1.24e+00  2.39e-03
;;  (Ta/Tp)_avg [ALL, ALL, Outside MOs]:    2.35e-02  1.73e+03  2.50e+00  1.95e+00  3.09e+00  4.62e-03
;;
;;
;;  (Te/Tp)_avg [SWE, 3DP, ALL]        :    3.54e-02  2.53e+01  1.49e+00  1.13e+00  1.20e+00  1.79e-03
;;  (Te/Ta)_avg [SWE, 3DP, ALL]        :    1.12e-02  2.29e+01  1.12e+00  7.09e-01  1.17e+00  2.65e-03
;;  (Ta/Tp)_avg [SWE, 3DP, ALL]        :    2.44e-02  1.90e+01  2.50e+00  1.94e+00  1.45e+00  2.10e-03
;;  (Te/Tp)_avg [SWE, 3DP, No Shocks]  :    4.14e-02  2.53e+01  1.49e+00  1.14e+00  1.20e+00  1.86e-03
;;  (Te/Ta)_avg [SWE, 3DP, No Shocks]  :    1.12e-02  2.29e+01  1.13e+00  7.14e-01  1.18e+00  2.80e-03
;;  (Ta/Tp)_avg [SWE, 3DP, No Shocks]  :    2.44e-02  1.90e+01  2.49e+00  1.91e+00  1.45e+00  2.21e-03
;;  (Te/Tp)_avg [SWE, 3DP, Inside  MOs]:    4.76e-02  2.53e+01  2.26e+00  1.81e+00  1.91e+00  1.41e-02
;;  (Te/Ta)_avg [SWE, 3DP, Inside  MOs]:    2.41e-02  2.29e+01  1.70e+00  1.24e+00  1.65e+00  1.64e-02
;;  (Ta/Tp)_avg [SWE, 3DP, Inside  MOs]:    2.44e-02  1.83e+01  2.27e+00  1.78e+00  1.33e+00  6.38e-03
;;  (Te/Tp)_avg [SWE, 3DP, Outside MOs]:    3.54e-02  2.32e+01  1.45e+00  1.12e+00  1.15e+00  1.75e-03
;;  (Te/Ta)_avg [SWE, 3DP, Outside MOs]:    1.12e-02  1.72e+01  1.09e+00  6.87e-01  1.13e+00  2.63e-03
;;  (Ta/Tp)_avg [SWE, 3DP, Outside MOs]:    1.79e-01  1.90e+01  2.52e+00  1.96e+00  1.46e+00  2.22e-03
;;========================================================================================
;;
;;----------------------------------------------------------------------------------------
;;  (Ts/Te)_per Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  (Te/Tp)_per [ALL, ALL, ALL]        :    5.18e-03  2.43e+02  1.59e+00  1.13e+00  1.70e+00  1.52e-03
;;  (Te/Ta)_per [ALL, ALL, ALL]        :    5.38e-03  6.01e+01  8.76e-01  3.80e-01  1.27e+00  1.45e-03
;;  (Ta/Tp)_per [ALL, ALL, ALL]        :    3.58e-03  2.26e+03  3.50e+00  3.71e+00  3.69e+00  3.43e-03
;;  (Te/Tp)_per [ALL, ALL, No Shocks]  :    6.21e-03  2.43e+02  1.59e+00  1.14e+00  1.67e+00  1.56e-03
;;  (Te/Ta)_per [ALL, ALL, No Shocks]  :    5.38e-03  6.01e+01  8.78e-01  3.82e-01  1.25e+00  1.50e-03
;;  (Ta/Tp)_per [ALL, ALL, No Shocks]  :    1.10e-02  2.26e+03  3.48e+00  3.71e+00  3.79e+00  3.69e-03
;;  (Te/Tp)_per [ALL, ALL, Inside  MOs]:    6.79e-03  9.00e+01  3.15e+00  2.10e+00  3.54e+00  1.42e-02
;;  (Te/Ta)_per [ALL, ALL, Inside  MOs]:    9.92e-03  6.01e+01  1.84e+00  8.34e-01  2.67e+00  1.24e-02
;;  (Ta/Tp)_per [ALL, ALL, Inside  MOs]:    3.58e-03  1.72e+02  3.26e+00  2.55e+00  2.67e+00  9.58e-03
;;  (Te/Tp)_per [ALL, ALL, Outside MOs]:    5.18e-03  2.43e+02  1.51e+00  1.10e+00  1.50e+00  1.38e-03
;;  (Te/Ta)_per [ALL, ALL, Outside MOs]:    5.38e-03  3.76e+01  8.14e-01  3.64e-01  1.09e+00  1.29e-03
;;  (Ta/Tp)_per [ALL, ALL, Outside MOs]:    1.10e-02  2.26e+03  3.52e+00  3.79e+00  3.76e+00  3.61e-03
;;
;;
;;  (Te/Tp)_per [SWE, 3DP, ALL]        :    1.47e-02  1.24e+02  1.71e+00  1.34e+00  1.39e+00  2.07e-03
;;  (Te/Ta)_per [SWE, 3DP, ALL]        :    6.13e-03  4.23e+01  8.94e-01  4.34e-01  1.12e+00  1.78e-03
;;  (Ta/Tp)_per [SWE, 3DP, ALL]        :    3.58e-03  2.00e+02  3.47e+00  3.16e+00  2.25e+00  2.39e-03
;;  (Te/Tp)_per [SWE, 3DP, No Shocks]  :    3.11e-02  1.24e+02  1.72e+00  1.35e+00  1.39e+00  2.14e-03
;;  (Te/Ta)_per [SWE, 3DP, No Shocks]  :    6.13e-03  4.23e+01  8.98e-01  4.34e-01  1.12e+00  1.85e-03
;;  (Ta/Tp)_per [SWE, 3DP, No Shocks]  :    1.10e-02  2.00e+02  3.45e+00  3.16e+00  2.21e+00  2.47e-03
;;  (Te/Tp)_per [SWE, 3DP, Inside  MOs]:    6.00e-02  7.94e+01  2.62e+00  2.07e+00  2.35e+00  1.73e-02
;;  (Te/Ta)_per [SWE, 3DP, Inside  MOs]:    1.67e-02  4.23e+01  1.52e+00  8.68e-01  1.94e+00  1.50e-02
;;  (Ta/Tp)_per [SWE, 3DP, Inside  MOs]:    3.58e-03  7.98e+01  3.20e+00  2.27e+00  2.69e+00  1.07e-02
;;  (Te/Tp)_per [SWE, 3DP, Outside MOs]:    1.47e-02  1.24e+02  1.68e+00  1.32e+00  1.33e+00  2.01e-03
;;  (Te/Ta)_per [SWE, 3DP, Outside MOs]:    6.13e-03  3.76e+01  8.67e-01  4.22e-01  1.06e+00  1.72e-03
;;  (Ta/Tp)_per [SWE, 3DP, Outside MOs]:    1.10e-02  2.00e+02  3.49e+00  3.24e+00  2.21e+00  2.44e-03
;;========================================================================================
;;
;;----------------------------------------------------------------------------------------
;;  (Ts/Te)_par Ratio Stats
;;----------------------------------------------------------------------------------------
;;
;;  (Te/Tp)_par [ALL, ALL, ALL]        :    6.95e-03  1.87e+02  1.18e+00  7.79e-01  1.51e+00  1.37e-03
;;  (Te/Ta)_par [ALL, ALL, ALL]        :    2.64e-03  6.06e+01  1.17e+00  6.47e-01  1.50e+00  2.67e-03
;;  (Ta/Tp)_par [ALL, ALL, ALL]        :    9.87e-03  2.72e+02  2.89e+00  2.12e+00  2.60e+00  3.38e-03
;;  (Te/Tp)_par [ALL, ALL, No Shocks]  :    9.11e-03  1.87e+02  1.18e+00  7.77e-01  1.47e+00  1.39e-03
;;  (Te/Ta)_par [ALL, ALL, No Shocks]  :    6.28e-03  6.06e+01  1.18e+00  6.47e-01  1.50e+00  2.82e-03
;;  (Ta/Tp)_par [ALL, ALL, No Shocks]  :    1.30e-02  2.72e+02  2.92e+00  2.13e+00  2.66e+00  3.63e-03
;;  (Te/Tp)_par [ALL, ALL, Inside  MOs]:    6.95e-03  1.87e+02  2.29e+00  1.55e+00  3.19e+00  1.30e-02
;;  (Te/Ta)_par [ALL, ALL, Inside  MOs]:    2.64e-03  6.00e+01  2.09e+00  1.40e+00  2.49e+00  1.61e-02
;;  (Ta/Tp)_par [ALL, ALL, Inside  MOs]:    1.30e-02  4.49e+01  2.17e+00  1.64e+00  1.76e+00  8.00e-03
;;  (Te/Tp)_par [ALL, ALL, Outside MOs]:    1.11e-02  1.83e+02  1.12e+00  7.57e-01  1.34e+00  1.25e-03
;;  (Te/Ta)_par [ALL, ALL, Outside MOs]:    6.28e-03  6.06e+01  1.09e+00  6.01e-01  1.35e+00  2.52e-03
;;  (Ta/Tp)_par [ALL, ALL, Outside MOs]:    9.87e-03  2.72e+02  2.96e+00  2.19e+00  2.65e+00  3.60e-03
;;
;;
;;  (Te/Tp)_par [SWE, 3DP, ALL]        :    1.11e-02  1.61e+02  1.30e+00  9.05e-01  1.40e+00  2.09e-03
;;  (Te/Ta)_par [SWE, 3DP, ALL]        :    5.27e-03  4.58e+01  1.02e+00  5.58e-01  1.25e+00  2.74e-03
;;  (Ta/Tp)_par [SWE, 3DP, ALL]        :    1.66e-02  2.72e+02  2.86e+00  2.11e+00  2.40e+00  3.19e-03
;;  (Te/Tp)_par [SWE, 3DP, No Shocks]  :    1.59e-02  1.61e+02  1.30e+00  9.01e-01  1.39e+00  2.16e-03
;;  (Te/Ta)_par [SWE, 3DP, No Shocks]  :    5.27e-03  4.58e+01  1.03e+00  5.54e-01  1.25e+00  2.87e-03
;;  (Ta/Tp)_par [SWE, 3DP, No Shocks]  :    1.66e-02  2.72e+02  2.88e+00  2.12e+00  2.45e+00  3.42e-03
;;  (Te/Tp)_par [SWE, 3DP, Inside  MOs]:    1.59e-02  1.61e+02  2.11e+00  1.60e+00  2.53e+00  1.87e-02
;;  (Te/Ta)_par [SWE, 3DP, Inside  MOs]:    9.21e-03  3.00e+01  1.65e+00  1.16e+00  1.74e+00  1.72e-02
;;  (Ta/Tp)_par [SWE, 3DP, Inside  MOs]:    4.44e-02  4.03e+01  2.17e+00  1.66e+00  1.64e+00  7.68e-03
;;  (Te/Tp)_par [SWE, 3DP, Outside MOs]:    1.11e-02  1.29e+02  1.26e+00  8.87e-01  1.32e+00  2.01e-03
;;  (Te/Ta)_par [SWE, 3DP, Outside MOs]:    5.27e-03  4.58e+01  9.90e-01  5.34e-01  1.21e+00  2.72e-03
;;  (Ta/Tp)_par [SWE, 3DP, Outside MOs]:    1.66e-02  2.72e+02  2.92e+00  2.18e+00  2.44e+00  3.39e-03
;;========================================================================================


