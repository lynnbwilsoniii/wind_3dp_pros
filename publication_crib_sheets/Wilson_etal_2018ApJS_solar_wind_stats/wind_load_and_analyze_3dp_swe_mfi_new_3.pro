;;  $HOME/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_new_3.pro

;;----------------------------------------------------------------------------------------
;;  Load batch file
;;----------------------------------------------------------------------------------------
ex_start       = SYSTIME(1)            ;;  Time the execution of all events within
@/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_new_2_batch.pro
MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE

HELP, in__ip_shock, out_ip_shock, in__mo_all, out_mo_all, good_fast_swe, good_slow_swe
;;  IN__IP_SHOCK    LONG      = Array[194651]
;;  OUT_IP_SHOCK    LONG      = Array[2435510]
;;  IN__MO_ALL      LONG      = Array[128109]
;;  OUT_MO_ALL      LONG      = Array[2502052]
;;  GOOD_FAST_SWE   LONG      = Array[194462]
;;  GOOD_SLOW_SWE   LONG      = Array[942027]

HELP,mo_tran,bad_tra     ;;  # of ICMEs and IP shocks
;;  MO_TRAN         DOUBLE    = Array[170, 2]
;;  BAD_TRA         DOUBLE    = Array[239, 2]

;;----------------------------------------------------------------------------------------
;;  Print one-variable stats
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/print_wind_3dp_swe_onevar_stats_new_2_batch.pro

;;----------------------------------------------------------------------------------------
;;  Print one-variable stats (with extras)
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/print_wind_3dp_swe_onevar_stats_new_3_batch.pro

;;----------------------------------------------------------------------------------------
;;  Print one-variable stats [LaTeX format]
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/print_latex_wind_3dp_swe_onevar_stats_new_2_batch.pro

;;----------------------------------------------------------------------------------------
;;  Print one-variable stats (quartiles) [LaTeX format]
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/print_latex_wind_3dp_swe_onevar_stats_new_3_batch.pro


;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot cumulative distribution functions (CDFs)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Plot beta_s_j ratios
;;----------------------------------------------------------------------------------------
xran           = [1d-3,1d2]
yran           = [0d0,1d0]
deltax         = 1.1d0
yttl0          = 'Number of Events'

ttle0          = 'beta_s_avg Ratios'
xttls          = ['beta_e_avg [3DP, ALL]','beta_p_avg [SWE, ALL]','beta_a_avg [SWE, ALL]','beta_e_avg [3DP, No Shocks]','beta_p_avg [SWE, No Shocks]','beta_a_avg [SWE, No Shocks]','beta_e_avg [3DP, Inside  MOs]','beta_p_avg [SWE, Inside  MOs]','beta_a_avg [SWE, Inside  MOs]','beta_e_avg [3DP, Outside MOs]','beta_p_avg [SWE, Outside MOs]','beta_a_avg [SWE, Outside MOs]','beta_e_avg [3DP, Vp > 500 km/s]','beta_p_avg [SWE, Vp > 500 km/s]','beta_a_avg [SWE, Vp > 500 km/s]','beta_e_avg [3DP, Vp <= 500 km/s]','beta_p_avg [SWE, Vp <= 500 km/s]','beta_a_avg [SWE, Vp <= 500 km/s]']
fnames         = ['beta_e_avg_3DP_ALL','beta_p_avg_SWE_ALL','beta_a_avg_SWE_ALL','beta_e_avg_3DP_No_Shocks','beta_p_avg_SWE_No_Shocks','beta_a_avg_SWE_No_Shocks','beta_e_avg_3DP_Inside__MOs','beta_p_avg_SWE_Inside__MOs','beta_a_avg_SWE_Inside__MOs','beta_e_avg_3DP_Outside_MOs','beta_p_avg_SWE_3DP_Outside_MOs','beta_a_avg_SWE_Outside_MOs','beta_e_avg_3DP_Fast_SW','beta_p_avg_SWE_Fast_SW','beta_a_avg_SWE_Fast_SW','beta_e_avg_3DP_Slow_SW','beta_p_avg_SWE_Slow_SW','beta_a_avg_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,beta_avg_epa[*,0,1],beta_avg_epa[*,1,1],beta_avg_epa[*,2,1],beta_avg_epa[out_ip_shock,0,1],beta_avg_epa[out_ip_shock,1,1],beta_avg_epa[out_ip_shock,2,1],beta_avg_epa[in__mo_all,0,1],beta_avg_epa[in__mo_all,1,1],beta_avg_epa[in__mo_all,2,1],beta_avg_epa[out_mo_all,0,1],beta_avg_epa[out_mo_all,1,1],beta_avg_epa[out_mo_all,2,1],beta_avg_epa[good_fast_swe,0,1],beta_avg_epa[good_fast_swe,1,1],beta_avg_epa[good_fast_swe,2,1],beta_avg_epa[good_slow_swe,0,1],beta_avg_epa[good_slow_swe,1,1],beta_avg_epa[good_slow_swe,2,1])

ttle0          = 'beta_s_per Ratios'
xttls          = ['beta_e_per [3DP, ALL]','beta_p_per [SWE, ALL]','beta_a_per [SWE, ALL]','beta_e_per [3DP, No Shocks]','beta_p_per [SWE, No Shocks]','beta_a_per [SWE, No Shocks]','beta_e_per [3DP, Inside  MOs]','beta_p_per [SWE, Inside  MOs]','beta_a_per [SWE, Inside  MOs]','beta_e_per [3DP, Outside MOs]','beta_p_per [SWE, Outside MOs]','beta_a_per [SWE, Outside MOs]','beta_e_per [3DP, Vp > 500 km/s]','beta_p_per [SWE, Vp > 500 km/s]','beta_a_per [SWE, Vp > 500 km/s]','beta_e_per [3DP, Vp <= 500 km/s]','beta_p_per [SWE, Vp <= 500 km/s]','beta_a_per [SWE, Vp <= 500 km/s]']
fnames         = ['beta_e_per_3DP_ALL','beta_p_per_SWE_ALL','beta_a_per_SWE_ALL','beta_e_per_3DP_No_Shocks','beta_p_per_SWE_No_Shocks','beta_a_per_SWE_No_Shocks','beta_e_per_3DP_Inside__MOs','beta_p_per_SWE_Inside__MOs','beta_a_per_SWE_Inside__MOs','beta_e_per_3DP_Outside_MOs','beta_p_per_SWE_3DP_Outside_MOs','beta_a_per_SWE_Outside_MOs','beta_e_per_3DP_Fast_SW','beta_p_per_SWE_Fast_SW','beta_a_per_SWE_Fast_SW','beta_e_per_3DP_Slow_SW','beta_p_per_SWE_Slow_SW','beta_a_per_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,beta_per_epa[*,0,1],beta_per_epa[*,1,1],beta_per_epa[*,2,1],beta_per_epa[out_ip_shock,0,1],beta_per_epa[out_ip_shock,1,1],beta_per_epa[out_ip_shock,2,1],beta_per_epa[in__mo_all,0,1],beta_per_epa[in__mo_all,1,1],beta_per_epa[in__mo_all,2,1],beta_per_epa[out_mo_all,0,1],beta_per_epa[out_mo_all,1,1],beta_per_epa[out_mo_all,2,1],beta_per_epa[good_fast_swe,0,1],beta_per_epa[good_fast_swe,1,1],beta_per_epa[good_fast_swe,2,1],beta_per_epa[good_slow_swe,0,1],beta_per_epa[good_slow_swe,1,1],beta_per_epa[good_slow_swe,2,1])

ttle0          = 'beta_s_par Ratios'
xttls          = ['beta_e_par [3DP, ALL]','beta_p_par [SWE, ALL]','beta_a_par [SWE, ALL]','beta_e_par [3DP, No Shocks]','beta_p_par [SWE, No Shocks]','beta_a_par [SWE, No Shocks]','beta_e_par [3DP, Inside  MOs]','beta_p_par [SWE, Inside  MOs]','beta_a_par [SWE, Inside  MOs]','beta_e_par [3DP, Outside MOs]','beta_p_par [SWE, Outside MOs]','beta_a_par [SWE, Outside MOs]','beta_e_par [3DP, Vp > 500 km/s]','beta_p_par [SWE, Vp > 500 km/s]','beta_a_par [SWE, Vp > 500 km/s]','beta_e_par [3DP, Vp <= 500 km/s]','beta_p_par [SWE, Vp <= 500 km/s]','beta_a_par [SWE, Vp <= 500 km/s]']
fnames         = ['beta_e_par_3DP_ALL','beta_p_par_SWE_ALL','beta_a_par_SWE_ALL','beta_e_par_3DP_No_Shocks','beta_p_par_SWE_No_Shocks','beta_a_par_SWE_No_Shocks','beta_e_par_3DP_Inside__MOs','beta_p_par_SWE_Inside__MOs','beta_a_par_SWE_Inside__MOs','beta_e_par_3DP_Outside_MOs','beta_p_par_SWE_3DP_Outside_MOs','beta_a_par_SWE_Outside_MOs','beta_e_par_3DP_Fast_SW','beta_p_par_SWE_Fast_SW','beta_a_par_SWE_Fast_SW','beta_e_par_3DP_Slow_SW','beta_p_par_SWE_Slow_SW','beta_a_par_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,beta_par_epa[*,0,1],beta_par_epa[*,1,1],beta_par_epa[*,2,1],beta_par_epa[out_ip_shock,0,1],beta_par_epa[out_ip_shock,1,1],beta_par_epa[out_ip_shock,2,1],beta_par_epa[in__mo_all,0,1],beta_par_epa[in__mo_all,1,1],beta_par_epa[in__mo_all,2,1],beta_par_epa[out_mo_all,0,1],beta_par_epa[out_mo_all,1,1],beta_par_epa[out_mo_all,2,1],beta_par_epa[good_fast_swe,0,1],beta_par_epa[good_fast_swe,1,1],beta_par_epa[good_fast_swe,2,1],beta_par_epa[good_slow_swe,0,1],beta_par_epa[good_slow_swe,1,1],beta_par_epa[good_slow_swe,2,1])

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_cdf_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]+'_grid_times_3'                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_cdf_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                     $
                            TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                          $
                            WIND_N=1

;;----------------------------------------------------------------------------------------
;;  Plot (Ts1/Ts2)_j ratios [2nd XRANGE]
;;----------------------------------------------------------------------------------------
xran           = [1d-2,1d2]
yran           = [0d0,1d0]
deltax         = 1.1d0
yttl0          = 'Number of Events'

ttle0          = '(Ts1/Ts2)_avg Ratios'
xttls          = ['(Te/Tp)_avg [SWE, 3DP, ALL]','(Te/Ta)_avg [SWE, 3DP, ALL]','(Ta/Tp)_avg [SWE, ALL]','(Te/Tp)_avg [SWE, 3DP, No Shocks]','(Te/Ta)_avg [SWE, 3DP, No Shocks]','(Ta/Tp)_avg [SWE, No Shocks]','(Te/Tp)_avg [SWE, 3DP, Inside  MOs]','(Te/Ta)_avg [SWE, 3DP, Inside  MOs]','(Ta/Tp)_avg [SWE, Inside  MOs]','(Te/Tp)_avg [SWE, 3DP, Outside MOs]','(Te/Ta)_avg [SWE, 3DP, Outside MOs]','(Ta/Tp)_avg [SWE, Outside MOs]','(Te/Tp)_avg [SWE, 3DP, Vp > 500 km/s]','(Te/Ta)_avg [SWE, 3DP, Vp > 500 km/s]','(Ta/Tp)_avg [SWE, Vp > 500 km/s]','(Te/Tp)_avg [SWE, 3DP, Vp <= 500 km/s]','(Te/Ta)_avg [SWE, 3DP, Vp <= 500 km/s]','(Ta/Tp)_avg [SWE, Vp <= 500 km/s]']
fnames         = ['Te_Tp_avg_SWE_3DP_ALL','Te_Ta_avg_SWE_3DP_ALL','Ta_Tp_avg_SWE_ALL','Te_Tp_avg_SWE_3DP_No_Shocks','Te_Ta_avg_SWE_3DP_No_Shocks','Ta_Tp_avg_SWE_No_Shocks','Te_Tp_avg_SWE_3DP_Inside__MOs','Te_Ta_avg_SWE_3DP_Inside__MOs','Ta_Tp_avg_SWE_Inside__MOs','Te_Tp_avg_SWE_3DP_Outside_MOs','Te_Ta_avg_SWE_3DP_Outside_MOs','Ta_Tp_avg_SWE_Outside_MOs','Te_Tp_avg_SWE_3DP_Fast_SW','Te_Ta_avg_SWE_3DP_Fast_SW','Ta_Tp_avg_SWE_Fast_SW','Te_Tp_avg_SWE_3DP_Slow_SW','Te_Ta_avg_SWE_3DP_Slow_SW','Ta_Tp_avg_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,Tr_avg_epeaap[*,0,1,1],Tr_avg_epeaap[*,1,1,1],Tr_avg_epeaap[*,2,1,1],Tr_avg_epeaap[out_ip_shock,0,1,1],Tr_avg_epeaap[out_ip_shock,1,1,1],Tr_avg_epeaap[out_ip_shock,2,1,1],Tr_avg_epeaap[in__mo_all,0,1,1],Tr_avg_epeaap[in__mo_all,1,1,1],Tr_avg_epeaap[in__mo_all,2,1,1],Tr_avg_epeaap[out_mo_all,0,1,1],Tr_avg_epeaap[out_mo_all,1,1,1],Tr_avg_epeaap[out_mo_all,2,1,1],Tr_avg_epeaap[good_fast_swe,0,1,1],Tr_avg_epeaap[good_fast_swe,1,1,1],Tr_avg_epeaap[good_fast_swe,2,1,1],Tr_avg_epeaap[good_slow_swe,0,1,1],Tr_avg_epeaap[good_slow_swe,1,1,1],Tr_avg_epeaap[good_slow_swe,2,1,1])

ttle0          = '(Ts1/Ts2)_per Ratios'
xttls          = ['(Te/Tp)_per [SWE, 3DP, ALL]','(Te/Ta)_per [SWE, 3DP, ALL]','(Ta/Tp)_per [SWE, ALL]','(Te/Tp)_per [SWE, 3DP, No Shocks]','(Te/Ta)_per [SWE, 3DP, No Shocks]','(Ta/Tp)_per [SWE, No Shocks]','(Te/Tp)_per [SWE, 3DP, Inside  MOs]','(Te/Ta)_per [SWE, 3DP, Inside  MOs]','(Ta/Tp)_per [SWE, Inside  MOs]','(Te/Tp)_per [SWE, 3DP, Outside MOs]','(Te/Ta)_per [SWE, 3DP, Outside MOs]','(Ta/Tp)_per [SWE, Outside MOs]','(Te/Tp)_per [SWE, 3DP, Vp > 500 km/s]','(Te/Ta)_per [SWE, 3DP, Vp > 500 km/s]','(Ta/Tp)_per [SWE, Vp > 500 km/s]','(Te/Tp)_per [SWE, 3DP, Vp <= 500 km/s]','(Te/Ta)_per [SWE, 3DP, Vp <= 500 km/s]','(Ta/Tp)_per [SWE, Vp <= 500 km/s]']
fnames         = ['Te_Tp_per_SWE_3DP_ALL','Te_Ta_per_SWE_3DP_ALL','Ta_Tp_per_SWE_ALL','Te_Tp_per_SWE_3DP_No_Shocks','Te_Ta_per_SWE_3DP_No_Shocks','Ta_Tp_per_SWE_No_Shocks','Te_Tp_per_SWE_3DP_Inside__MOs','Te_Ta_per_SWE_3DP_Inside__MOs','Ta_Tp_per_SWE_Inside__MOs','Te_Tp_per_SWE_3DP_Outside_MOs','Te_Ta_per_SWE_3DP_Outside_MOs','Ta_Tp_per_SWE_Outside_MOs','Te_Tp_per_SWE_3DP_Fast_SW','Te_Ta_per_SWE_3DP_Fast_SW','Ta_Tp_per_SWE_Fast_SW','Te_Tp_per_SWE_3DP_Slow_SW','Te_Ta_per_SWE_3DP_Slow_SW','Ta_Tp_per_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,Tr_per_epeaap[*,0,1,1],Tr_per_epeaap[*,1,1,1],Tr_per_epeaap[*,2,1,1],Tr_per_epeaap[out_ip_shock,0,1,1],Tr_per_epeaap[out_ip_shock,1,1,1],Tr_per_epeaap[out_ip_shock,2,1,1],Tr_per_epeaap[in__mo_all,0,1,1],Tr_per_epeaap[in__mo_all,1,1,1],Tr_per_epeaap[in__mo_all,2,1,1],Tr_per_epeaap[out_mo_all,0,1,1],Tr_per_epeaap[out_mo_all,1,1,1],Tr_per_epeaap[out_mo_all,2,1,1],Tr_per_epeaap[good_fast_swe,0,1,1],Tr_per_epeaap[good_fast_swe,1,1,1],Tr_per_epeaap[good_fast_swe,2,1,1],Tr_per_epeaap[good_slow_swe,0,1,1],Tr_per_epeaap[good_slow_swe,1,1,1],Tr_per_epeaap[good_slow_swe,2,1,1])

ttle0          = '(Ts1/Ts2)_par Ratios'
xttls          = ['(Te/Tp)_par [SWE, 3DP, ALL]','(Te/Ta)_par [SWE, 3DP, ALL]','(Ta/Tp)_par [SWE, ALL]','(Te/Tp)_par [SWE, 3DP, No Shocks]','(Te/Ta)_par [SWE, 3DP, No Shocks]','(Ta/Tp)_par [SWE, No Shocks]','(Te/Tp)_par [SWE, 3DP, Inside  MOs]','(Te/Ta)_par [SWE, 3DP, Inside  MOs]','(Ta/Tp)_par [SWE, Inside  MOs]','(Te/Tp)_par [SWE, 3DP, Outside MOs]','(Te/Ta)_par [SWE, 3DP, Outside MOs]','(Ta/Tp)_par [SWE, Outside MOs]','(Te/Tp)_par [SWE, 3DP, Vp > 500 km/s]','(Te/Ta)_par [SWE, 3DP, Vp > 500 km/s]','(Ta/Tp)_par [SWE, Vp > 500 km/s]','(Te/Tp)_par [SWE, 3DP, Vp <= 500 km/s]','(Te/Ta)_par [SWE, 3DP, Vp <= 500 km/s]','(Ta/Tp)_par [SWE, Vp <= 500 km/s]']
fnames         = ['Te_Tp_par_SWE_3DP_ALL','Te_Ta_par_SWE_3DP_ALL','Ta_Tp_par_SWE_ALL','Te_Tp_par_SWE_3DP_No_Shocks','Te_Ta_par_SWE_3DP_No_Shocks','Ta_Tp_par_SWE_No_Shocks','Te_Tp_par_SWE_3DP_Inside__MOs','Te_Ta_par_SWE_3DP_Inside__MOs','Ta_Tp_par_SWE_Inside__MOs','Te_Tp_par_SWE_3DP_Outside_MOs','Te_Ta_par_SWE_3DP_Outside_MOs','Ta_Tp_par_SWE_Outside_MOs','Te_Tp_par_SWE_3DP_Fast_SW','Te_Ta_par_SWE_3DP_Fast_SW','Ta_Tp_par_SWE_Fast_SW','Te_Tp_par_SWE_3DP_Slow_SW','Te_Ta_par_SWE_3DP_Slow_SW','Ta_Tp_par_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,Tr_par_epeaap[*,0,1,1],Tr_par_epeaap[*,1,1,1],Tr_par_epeaap[*,2,1,1],Tr_par_epeaap[out_ip_shock,0,1,1],Tr_par_epeaap[out_ip_shock,1,1,1],Tr_par_epeaap[out_ip_shock,2,1,1],Tr_par_epeaap[in__mo_all,0,1,1],Tr_par_epeaap[in__mo_all,1,1,1],Tr_par_epeaap[in__mo_all,2,1,1],Tr_par_epeaap[out_mo_all,0,1,1],Tr_par_epeaap[out_mo_all,1,1,1],Tr_par_epeaap[out_mo_all,2,1,1],Tr_par_epeaap[good_fast_swe,0,1,1],Tr_par_epeaap[good_fast_swe,1,1,1],Tr_par_epeaap[good_fast_swe,2,1,1],Tr_par_epeaap[good_slow_swe,0,1,1],Tr_par_epeaap[good_slow_swe,1,1,1],Tr_par_epeaap[good_slow_swe,2,1,1])

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_cdf_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]+'_grid_times_3_2nd-xrange'                                                 & $
  xttle = xttls[j]                                                                                     & $
  temp_cdf_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                     $
                            TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                          $
                            WIND_N=1

;;----------------------------------------------------------------------------------------
;;  Plot (Ts)_j [eV]
;;----------------------------------------------------------------------------------------
xran           = [1d-1,5d2]
yran           = [0d0,1d0]
deltax         = 1.1d0
yttl0          = 'Number of Events'

ttle0          = 'T_s,avg Histograms'
xttls          = ['Te_avg [SWE, 3DP, ALL, eV]','Tp_avg [SWE, 3DP, ALL, eV]','Ta_avg [SWE, 3DP, ALL, eV]','Te_avg [SWE, 3DP, No Shocks, eV]','Tp_avg [SWE, 3DP, No Shocks, eV]','Ta_avg [SWE, 3DP, No Shocks, eV]','Te_avg [SWE, 3DP, Inside  MOs, eV]','Tp_avg [SWE, 3DP, Inside  MOs, eV]','Ta_avg [SWE, 3DP, Inside  MOs, eV]','Te_avg [SWE, 3DP, Outside MOs, eV]','Tp_avg [SWE, 3DP, Outside MOs, eV]','Ta_avg [SWE, 3DP, Outside MOs, eV]','Te_avg [SWE, 3DP, Vp > 500 km/s, eV]','Tp_avg [SWE, 3DP, Vp > 500 km/s, eV]','Ta_avg [SWE, 3DP, Vp > 500 km/s, eV]','Te_avg [SWE, 3DP, Vp <= 500 km/s, eV]','Tp_avg [SWE, 3DP, Vp <= 500 km/s, eV]','Ta_avg [SWE, 3DP, Vp <= 500 km/s, eV]']
fnames         = ['Te_avg_SWE_3DP_ALL','Tp_avg_SWE_3DP_ALL','Ta_avg_SWE_3DP_ALL','Te_avg_SWE_3DP_No_Shocks','Tp_avg_SWE_3DP_No_Shocks','Ta_avg_SWE_3DP_No_Shocks','Te_avg_SWE_3DP_Inside__MOs','Tp_avg_SWE_3DP_Inside__MOs','Ta_avg_SWE_3DP_Inside__MOs','Te_avg_SWE_3DP_Outside_MOs','Tp_avg_SWE_3DP_Outside_MOs','Ta_avg_SWE_3DP_Outside_MOs','Te_avg_SWE_3DP_Fast_SW','Tp_avg_SWE_3DP_Fast_SW','Ta_avg_SWE_3DP_Fast_SW','Te_avg_SWE_3DP_Slow_SW','Tp_avg_SWE_3DP_Slow_SW','Ta_avg_SWE_3DP_Slow_SW']
xdat           = CREATE_STRUCT(fnames,gtavg_epa[*,0,1],gtavg_epa[*,1,1],gtavg_epa[*,2,1],gtavg_epa[out_ip_shock,0,1],gtavg_epa[out_ip_shock,1,1],gtavg_epa[out_ip_shock,2,1],gtavg_epa[in__mo_all,0,1],gtavg_epa[in__mo_all,1,1],gtavg_epa[in__mo_all,2,1],gtavg_epa[out_mo_all,0,1],gtavg_epa[out_mo_all,1,1],gtavg_epa[out_mo_all,2,1],gtavg_epa[good_fast_swe,0,1],gtavg_epa[good_fast_swe,1,1],gtavg_epa[good_fast_swe,2,1],gtavg_epa[good_slow_swe,0,1],gtavg_epa[good_slow_swe,1,1],gtavg_epa[good_slow_swe,2,1])

ttle0          = 'T_s,per Histograms'
xttls          = ['Te_per [SWE, 3DP, ALL, eV]','Tp_per [SWE, 3DP, ALL, eV]','Ta_per [SWE, 3DP, ALL, eV]','Te_per [SWE, 3DP, No Shocks, eV]','Tp_per [SWE, 3DP, No Shocks, eV]','Ta_per [SWE, 3DP, No Shocks, eV]','Te_per [SWE, 3DP, Inside  MOs, eV]','Tp_per [SWE, 3DP, Inside  MOs, eV]','Ta_per [SWE, 3DP, Inside  MOs, eV]','Te_per [SWE, 3DP, Outside MOs, eV]','Tp_per [SWE, 3DP, Outside MOs, eV]','Ta_per [SWE, 3DP, Outside MOs, eV]','Te_per [SWE, 3DP, Vp > 500 km/s, eV]','Tp_per [SWE, 3DP, Vp > 500 km/s, eV]','Ta_per [SWE, 3DP, Vp > 500 km/s, eV]','Te_per [SWE, 3DP, Vp <= 500 km/s, eV]','Tp_per [SWE, 3DP, Vp <= 500 km/s, eV]','Ta_per [SWE, 3DP, Vp <= 500 km/s, eV]']
fnames         = ['Te_per_SWE_3DP_ALL','Tp_per_SWE_3DP_ALL','Ta_per_SWE_3DP_ALL','Te_per_SWE_3DP_No_Shocks','Tp_per_SWE_3DP_No_Shocks','Ta_per_SWE_3DP_No_Shocks','Te_per_SWE_3DP_Inside__MOs','Tp_per_SWE_3DP_Inside__MOs','Ta_per_SWE_3DP_Inside__MOs','Te_per_SWE_3DP_Outside_MOs','Tp_per_SWE_3DP_Outside_MOs','Ta_per_SWE_3DP_Outside_MOs','Te_per_SWE_3DP_Fast_SW','Tp_per_SWE_3DP_Fast_SW','Ta_per_SWE_3DP_Fast_SW','Te_per_SWE_3DP_Slow_SW','Tp_per_SWE_3DP_Slow_SW','Ta_per_SWE_3DP_Slow_SW']
xdat           = CREATE_STRUCT(fnames,gtper_epa[*,0,1],gtper_epa[*,1,1],gtper_epa[*,2,1],gtper_epa[out_ip_shock,0,1],gtper_epa[out_ip_shock,1,1],gtper_epa[out_ip_shock,2,1],gtper_epa[in__mo_all,0,1],gtper_epa[in__mo_all,1,1],gtper_epa[in__mo_all,2,1],gtper_epa[out_mo_all,0,1],gtper_epa[out_mo_all,1,1],gtper_epa[out_mo_all,2,1],gtper_epa[good_fast_swe,0,1],gtper_epa[good_fast_swe,1,1],gtper_epa[good_fast_swe,2,1],gtper_epa[good_slow_swe,0,1],gtper_epa[good_slow_swe,1,1],gtper_epa[good_slow_swe,2,1])

ttle0          = 'T_s,par Histograms'
xttls          = ['Te_par [SWE, 3DP, ALL, eV]','Tp_par [SWE, 3DP, ALL, eV]','Ta_par [SWE, 3DP, ALL, eV]','Te_par [SWE, 3DP, No Shocks, eV]','Tp_par [SWE, 3DP, No Shocks, eV]','Ta_par [SWE, 3DP, No Shocks, eV]','Te_par [SWE, 3DP, Inside  MOs, eV]','Tp_par [SWE, 3DP, Inside  MOs, eV]','Ta_par [SWE, 3DP, Inside  MOs, eV]','Te_par [SWE, 3DP, Outside MOs, eV]','Tp_par [SWE, 3DP, Outside MOs, eV]','Ta_par [SWE, 3DP, Outside MOs, eV]','Te_par [SWE, 3DP, Vp > 500 km/s, eV]','Tp_par [SWE, 3DP, Vp > 500 km/s, eV]','Ta_par [SWE, 3DP, Vp > 500 km/s, eV]','Te_par [SWE, 3DP, Vp <= 500 km/s, eV]','Tp_par [SWE, 3DP, Vp <= 500 km/s, eV]','Ta_par [SWE, 3DP, Vp <= 500 km/s, eV]']
fnames         = ['Te_par_SWE_3DP_ALL','Tp_par_SWE_3DP_ALL','Ta_par_SWE_3DP_ALL','Te_par_SWE_3DP_No_Shocks','Tp_par_SWE_3DP_No_Shocks','Ta_par_SWE_3DP_No_Shocks','Te_par_SWE_3DP_Inside__MOs','Tp_par_SWE_3DP_Inside__MOs','Ta_par_SWE_3DP_Inside__MOs','Te_par_SWE_3DP_Outside_MOs','Tp_par_SWE_3DP_Outside_MOs','Ta_par_SWE_3DP_Outside_MOs','Te_par_SWE_3DP_Fast_SW','Tp_par_SWE_3DP_Fast_SW','Ta_par_SWE_3DP_Fast_SW','Te_par_SWE_3DP_Slow_SW','Tp_par_SWE_3DP_Slow_SW','Ta_par_SWE_3DP_Slow_SW']
xdat           = CREATE_STRUCT(fnames,gtpar_epa[*,0,1],gtpar_epa[*,1,1],gtpar_epa[*,2,1],gtpar_epa[out_ip_shock,0,1],gtpar_epa[out_ip_shock,1,1],gtpar_epa[out_ip_shock,2,1],gtpar_epa[in__mo_all,0,1],gtpar_epa[in__mo_all,1,1],gtpar_epa[in__mo_all,2,1],gtpar_epa[out_mo_all,0,1],gtpar_epa[out_mo_all,1,1],gtpar_epa[out_mo_all,2,1],gtpar_epa[good_fast_swe,0,1],gtpar_epa[good_fast_swe,1,1],gtpar_epa[good_fast_swe,2,1],gtpar_epa[good_slow_swe,0,1],gtpar_epa[good_slow_swe,1,1],gtpar_epa[good_slow_swe,2,1])

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_cdf_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]+'_grid_times_3'                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_cdf_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                     $
                            TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                          $
                            WIND_N=1


;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot histograms
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Plot beta_s_j ratios
;;----------------------------------------------------------------------------------------
xran           = [1d-3,1d2]
yran           = [1d0,1d5]
deltax         = 1.1d0
yttl0          = 'Number of Events'

ttle0          = 'beta_s_avg Ratios'
xttls          = ['beta_e_avg [3DP, ALL]','beta_p_avg [SWE, ALL]','beta_a_avg [SWE, ALL]','beta_e_avg [3DP, No Shocks]','beta_p_avg [SWE, No Shocks]','beta_a_avg [SWE, No Shocks]','beta_e_avg [3DP, Inside  MOs]','beta_p_avg [SWE, Inside  MOs]','beta_a_avg [SWE, Inside  MOs]','beta_e_avg [3DP, Outside MOs]','beta_p_avg [SWE, Outside MOs]','beta_a_avg [SWE, Outside MOs]','beta_e_avg [3DP, Vp > 500 km/s]','beta_p_avg [SWE, Vp > 500 km/s]','beta_a_avg [SWE, Vp > 500 km/s]','beta_e_avg [3DP, Vp <= 500 km/s]','beta_p_avg [SWE, Vp <= 500 km/s]','beta_a_avg [SWE, Vp <= 500 km/s]']
fnames         = ['beta_e_avg_3DP_ALL','beta_p_avg_SWE_ALL','beta_a_avg_SWE_ALL','beta_e_avg_3DP_No_Shocks','beta_p_avg_SWE_No_Shocks','beta_a_avg_SWE_No_Shocks','beta_e_avg_3DP_Inside__MOs','beta_p_avg_SWE_Inside__MOs','beta_a_avg_SWE_Inside__MOs','beta_e_avg_3DP_Outside_MOs','beta_p_avg_SWE_3DP_Outside_MOs','beta_a_avg_SWE_Outside_MOs','beta_e_avg_3DP_Fast_SW','beta_p_avg_SWE_Fast_SW','beta_a_avg_SWE_Fast_SW','beta_e_avg_3DP_Slow_SW','beta_p_avg_SWE_Slow_SW','beta_a_avg_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,beta_avg_epa[*,0,1],beta_avg_epa[*,1,1],beta_avg_epa[*,2,1],beta_avg_epa[out_ip_shock,0,1],beta_avg_epa[out_ip_shock,1,1],beta_avg_epa[out_ip_shock,2,1],beta_avg_epa[in__mo_all,0,1],beta_avg_epa[in__mo_all,1,1],beta_avg_epa[in__mo_all,2,1],beta_avg_epa[out_mo_all,0,1],beta_avg_epa[out_mo_all,1,1],beta_avg_epa[out_mo_all,2,1],beta_avg_epa[good_fast_swe,0,1],beta_avg_epa[good_fast_swe,1,1],beta_avg_epa[good_fast_swe,2,1],beta_avg_epa[good_slow_swe,0,1],beta_avg_epa[good_slow_swe,1,1],beta_avg_epa[good_slow_swe,2,1])

ttle0          = 'beta_s_per Ratios'
xttls          = ['beta_e_per [3DP, ALL]','beta_p_per [SWE, ALL]','beta_a_per [SWE, ALL]','beta_e_per [3DP, No Shocks]','beta_p_per [SWE, No Shocks]','beta_a_per [SWE, No Shocks]','beta_e_per [3DP, Inside  MOs]','beta_p_per [SWE, Inside  MOs]','beta_a_per [SWE, Inside  MOs]','beta_e_per [3DP, Outside MOs]','beta_p_per [SWE, Outside MOs]','beta_a_per [SWE, Outside MOs]','beta_e_per [3DP, Vp > 500 km/s]','beta_p_per [SWE, Vp > 500 km/s]','beta_a_per [SWE, Vp > 500 km/s]','beta_e_per [3DP, Vp <= 500 km/s]','beta_p_per [SWE, Vp <= 500 km/s]','beta_a_per [SWE, Vp <= 500 km/s]']
fnames         = ['beta_e_per_3DP_ALL','beta_p_per_SWE_ALL','beta_a_per_SWE_ALL','beta_e_per_3DP_No_Shocks','beta_p_per_SWE_No_Shocks','beta_a_per_SWE_No_Shocks','beta_e_per_3DP_Inside__MOs','beta_p_per_SWE_Inside__MOs','beta_a_per_SWE_Inside__MOs','beta_e_per_3DP_Outside_MOs','beta_p_per_SWE_3DP_Outside_MOs','beta_a_per_SWE_Outside_MOs','beta_e_per_3DP_Fast_SW','beta_p_per_SWE_Fast_SW','beta_a_per_SWE_Fast_SW','beta_e_per_3DP_Slow_SW','beta_p_per_SWE_Slow_SW','beta_a_per_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,beta_per_epa[*,0,1],beta_per_epa[*,1,1],beta_per_epa[*,2,1],beta_per_epa[out_ip_shock,0,1],beta_per_epa[out_ip_shock,1,1],beta_per_epa[out_ip_shock,2,1],beta_per_epa[in__mo_all,0,1],beta_per_epa[in__mo_all,1,1],beta_per_epa[in__mo_all,2,1],beta_per_epa[out_mo_all,0,1],beta_per_epa[out_mo_all,1,1],beta_per_epa[out_mo_all,2,1],beta_per_epa[good_fast_swe,0,1],beta_per_epa[good_fast_swe,1,1],beta_per_epa[good_fast_swe,2,1],beta_per_epa[good_slow_swe,0,1],beta_per_epa[good_slow_swe,1,1],beta_per_epa[good_slow_swe,2,1])

ttle0          = 'beta_s_par Ratios'
xttls          = ['beta_e_par [3DP, ALL]','beta_p_par [SWE, ALL]','beta_a_par [SWE, ALL]','beta_e_par [3DP, No Shocks]','beta_p_par [SWE, No Shocks]','beta_a_par [SWE, No Shocks]','beta_e_par [3DP, Inside  MOs]','beta_p_par [SWE, Inside  MOs]','beta_a_par [SWE, Inside  MOs]','beta_e_par [3DP, Outside MOs]','beta_p_par [SWE, Outside MOs]','beta_a_par [SWE, Outside MOs]','beta_e_par [3DP, Vp > 500 km/s]','beta_p_par [SWE, Vp > 500 km/s]','beta_a_par [SWE, Vp > 500 km/s]','beta_e_par [3DP, Vp <= 500 km/s]','beta_p_par [SWE, Vp <= 500 km/s]','beta_a_par [SWE, Vp <= 500 km/s]']
fnames         = ['beta_e_par_3DP_ALL','beta_p_par_SWE_ALL','beta_a_par_SWE_ALL','beta_e_par_3DP_No_Shocks','beta_p_par_SWE_No_Shocks','beta_a_par_SWE_No_Shocks','beta_e_par_3DP_Inside__MOs','beta_p_par_SWE_Inside__MOs','beta_a_par_SWE_Inside__MOs','beta_e_par_3DP_Outside_MOs','beta_p_par_SWE_3DP_Outside_MOs','beta_a_par_SWE_Outside_MOs','beta_e_par_3DP_Fast_SW','beta_p_par_SWE_Fast_SW','beta_a_par_SWE_Fast_SW','beta_e_par_3DP_Slow_SW','beta_p_par_SWE_Slow_SW','beta_a_par_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,beta_par_epa[*,0,1],beta_par_epa[*,1,1],beta_par_epa[*,2,1],beta_par_epa[out_ip_shock,0,1],beta_par_epa[out_ip_shock,1,1],beta_par_epa[out_ip_shock,2,1],beta_par_epa[in__mo_all,0,1],beta_par_epa[in__mo_all,1,1],beta_par_epa[in__mo_all,2,1],beta_par_epa[out_mo_all,0,1],beta_par_epa[out_mo_all,1,1],beta_par_epa[out_mo_all,2,1],beta_par_epa[good_fast_swe,0,1],beta_par_epa[good_fast_swe,1,1],beta_par_epa[good_fast_swe,2,1],beta_par_epa[good_slow_swe,0,1],beta_par_epa[good_slow_swe,1,1],beta_par_epa[good_slow_swe,2,1])

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]+'_grid_times_3'                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1

;;----------------------------------------------------------------------------------------
;;  Plot (Ts1/Ts2)_j ratios [2nd XRANGE]
;;----------------------------------------------------------------------------------------
xran           = [1d-2,1d2]
yran           = [1d0,1d5]
deltax         = 1.1d0
yttl0          = 'Number of Events'

ttle0          = '(Ts1/Ts2)_avg Ratios'
xttls          = ['(Te/Tp)_avg [SWE, 3DP, ALL]','(Te/Ta)_avg [SWE, 3DP, ALL]','(Ta/Tp)_avg [SWE, ALL]','(Te/Tp)_avg [SWE, 3DP, No Shocks]','(Te/Ta)_avg [SWE, 3DP, No Shocks]','(Ta/Tp)_avg [SWE, No Shocks]','(Te/Tp)_avg [SWE, 3DP, Inside  MOs]','(Te/Ta)_avg [SWE, 3DP, Inside  MOs]','(Ta/Tp)_avg [SWE, Inside  MOs]','(Te/Tp)_avg [SWE, 3DP, Outside MOs]','(Te/Ta)_avg [SWE, 3DP, Outside MOs]','(Ta/Tp)_avg [SWE, Outside MOs]','(Te/Tp)_avg [SWE, 3DP, Vp > 500 km/s]','(Te/Ta)_avg [SWE, 3DP, Vp > 500 km/s]','(Ta/Tp)_avg [SWE, Vp > 500 km/s]','(Te/Tp)_avg [SWE, 3DP, Vp <= 500 km/s]','(Te/Ta)_avg [SWE, 3DP, Vp <= 500 km/s]','(Ta/Tp)_avg [SWE, Vp <= 500 km/s]']
fnames         = ['Te_Tp_avg_SWE_3DP_ALL','Te_Ta_avg_SWE_3DP_ALL','Ta_Tp_avg_SWE_ALL','Te_Tp_avg_SWE_3DP_No_Shocks','Te_Ta_avg_SWE_3DP_No_Shocks','Ta_Tp_avg_SWE_No_Shocks','Te_Tp_avg_SWE_3DP_Inside__MOs','Te_Ta_avg_SWE_3DP_Inside__MOs','Ta_Tp_avg_SWE_Inside__MOs','Te_Tp_avg_SWE_3DP_Outside_MOs','Te_Ta_avg_SWE_3DP_Outside_MOs','Ta_Tp_avg_SWE_Outside_MOs','Te_Tp_avg_SWE_3DP_Fast_SW','Te_Ta_avg_SWE_3DP_Fast_SW','Ta_Tp_avg_SWE_Fast_SW','Te_Tp_avg_SWE_3DP_Slow_SW','Te_Ta_avg_SWE_3DP_Slow_SW','Ta_Tp_avg_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,Tr_avg_epeaap[*,0,1,1],Tr_avg_epeaap[*,1,1,1],Tr_avg_epeaap[*,2,1,1],Tr_avg_epeaap[out_ip_shock,0,1,1],Tr_avg_epeaap[out_ip_shock,1,1,1],Tr_avg_epeaap[out_ip_shock,2,1,1],Tr_avg_epeaap[in__mo_all,0,1,1],Tr_avg_epeaap[in__mo_all,1,1,1],Tr_avg_epeaap[in__mo_all,2,1,1],Tr_avg_epeaap[out_mo_all,0,1,1],Tr_avg_epeaap[out_mo_all,1,1,1],Tr_avg_epeaap[out_mo_all,2,1,1],Tr_avg_epeaap[good_fast_swe,0,1,1],Tr_avg_epeaap[good_fast_swe,1,1,1],Tr_avg_epeaap[good_fast_swe,2,1,1],Tr_avg_epeaap[good_slow_swe,0,1,1],Tr_avg_epeaap[good_slow_swe,1,1,1],Tr_avg_epeaap[good_slow_swe,2,1,1])

ttle0          = '(Ts1/Ts2)_per Ratios'
xttls          = ['(Te/Tp)_per [SWE, 3DP, ALL]','(Te/Ta)_per [SWE, 3DP, ALL]','(Ta/Tp)_per [SWE, ALL]','(Te/Tp)_per [SWE, 3DP, No Shocks]','(Te/Ta)_per [SWE, 3DP, No Shocks]','(Ta/Tp)_per [SWE, No Shocks]','(Te/Tp)_per [SWE, 3DP, Inside  MOs]','(Te/Ta)_per [SWE, 3DP, Inside  MOs]','(Ta/Tp)_per [SWE, Inside  MOs]','(Te/Tp)_per [SWE, 3DP, Outside MOs]','(Te/Ta)_per [SWE, 3DP, Outside MOs]','(Ta/Tp)_per [SWE, Outside MOs]','(Te/Tp)_per [SWE, 3DP, Vp > 500 km/s]','(Te/Ta)_per [SWE, 3DP, Vp > 500 km/s]','(Ta/Tp)_per [SWE, Vp > 500 km/s]','(Te/Tp)_per [SWE, 3DP, Vp <= 500 km/s]','(Te/Ta)_per [SWE, 3DP, Vp <= 500 km/s]','(Ta/Tp)_per [SWE, Vp <= 500 km/s]']
fnames         = ['Te_Tp_per_SWE_3DP_ALL','Te_Ta_per_SWE_3DP_ALL','Ta_Tp_per_SWE_ALL','Te_Tp_per_SWE_3DP_No_Shocks','Te_Ta_per_SWE_3DP_No_Shocks','Ta_Tp_per_SWE_No_Shocks','Te_Tp_per_SWE_3DP_Inside__MOs','Te_Ta_per_SWE_3DP_Inside__MOs','Ta_Tp_per_SWE_Inside__MOs','Te_Tp_per_SWE_3DP_Outside_MOs','Te_Ta_per_SWE_3DP_Outside_MOs','Ta_Tp_per_SWE_Outside_MOs','Te_Tp_per_SWE_3DP_Fast_SW','Te_Ta_per_SWE_3DP_Fast_SW','Ta_Tp_per_SWE_Fast_SW','Te_Tp_per_SWE_3DP_Slow_SW','Te_Ta_per_SWE_3DP_Slow_SW','Ta_Tp_per_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,Tr_per_epeaap[*,0,1,1],Tr_per_epeaap[*,1,1,1],Tr_per_epeaap[*,2,1,1],Tr_per_epeaap[out_ip_shock,0,1,1],Tr_per_epeaap[out_ip_shock,1,1,1],Tr_per_epeaap[out_ip_shock,2,1,1],Tr_per_epeaap[in__mo_all,0,1,1],Tr_per_epeaap[in__mo_all,1,1,1],Tr_per_epeaap[in__mo_all,2,1,1],Tr_per_epeaap[out_mo_all,0,1,1],Tr_per_epeaap[out_mo_all,1,1,1],Tr_per_epeaap[out_mo_all,2,1,1],Tr_per_epeaap[good_fast_swe,0,1,1],Tr_per_epeaap[good_fast_swe,1,1,1],Tr_per_epeaap[good_fast_swe,2,1,1],Tr_per_epeaap[good_slow_swe,0,1,1],Tr_per_epeaap[good_slow_swe,1,1,1],Tr_per_epeaap[good_slow_swe,2,1,1])

ttle0          = '(Ts1/Ts2)_par Ratios'
xttls          = ['(Te/Tp)_par [SWE, 3DP, ALL]','(Te/Ta)_par [SWE, 3DP, ALL]','(Ta/Tp)_par [SWE, ALL]','(Te/Tp)_par [SWE, 3DP, No Shocks]','(Te/Ta)_par [SWE, 3DP, No Shocks]','(Ta/Tp)_par [SWE, No Shocks]','(Te/Tp)_par [SWE, 3DP, Inside  MOs]','(Te/Ta)_par [SWE, 3DP, Inside  MOs]','(Ta/Tp)_par [SWE, Inside  MOs]','(Te/Tp)_par [SWE, 3DP, Outside MOs]','(Te/Ta)_par [SWE, 3DP, Outside MOs]','(Ta/Tp)_par [SWE, Outside MOs]','(Te/Tp)_par [SWE, 3DP, Vp > 500 km/s]','(Te/Ta)_par [SWE, 3DP, Vp > 500 km/s]','(Ta/Tp)_par [SWE, Vp > 500 km/s]','(Te/Tp)_par [SWE, 3DP, Vp <= 500 km/s]','(Te/Ta)_par [SWE, 3DP, Vp <= 500 km/s]','(Ta/Tp)_par [SWE, Vp <= 500 km/s]']
fnames         = ['Te_Tp_par_SWE_3DP_ALL','Te_Ta_par_SWE_3DP_ALL','Ta_Tp_par_SWE_ALL','Te_Tp_par_SWE_3DP_No_Shocks','Te_Ta_par_SWE_3DP_No_Shocks','Ta_Tp_par_SWE_No_Shocks','Te_Tp_par_SWE_3DP_Inside__MOs','Te_Ta_par_SWE_3DP_Inside__MOs','Ta_Tp_par_SWE_Inside__MOs','Te_Tp_par_SWE_3DP_Outside_MOs','Te_Ta_par_SWE_3DP_Outside_MOs','Ta_Tp_par_SWE_Outside_MOs','Te_Tp_par_SWE_3DP_Fast_SW','Te_Ta_par_SWE_3DP_Fast_SW','Ta_Tp_par_SWE_Fast_SW','Te_Tp_par_SWE_3DP_Slow_SW','Te_Ta_par_SWE_3DP_Slow_SW','Ta_Tp_par_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,Tr_par_epeaap[*,0,1,1],Tr_par_epeaap[*,1,1,1],Tr_par_epeaap[*,2,1,1],Tr_par_epeaap[out_ip_shock,0,1,1],Tr_par_epeaap[out_ip_shock,1,1,1],Tr_par_epeaap[out_ip_shock,2,1,1],Tr_par_epeaap[in__mo_all,0,1,1],Tr_par_epeaap[in__mo_all,1,1,1],Tr_par_epeaap[in__mo_all,2,1,1],Tr_par_epeaap[out_mo_all,0,1,1],Tr_par_epeaap[out_mo_all,1,1,1],Tr_par_epeaap[out_mo_all,2,1,1],Tr_par_epeaap[good_fast_swe,0,1,1],Tr_par_epeaap[good_fast_swe,1,1,1],Tr_par_epeaap[good_fast_swe,2,1,1],Tr_par_epeaap[good_slow_swe,0,1,1],Tr_par_epeaap[good_slow_swe,1,1,1],Tr_par_epeaap[good_slow_swe,2,1,1])

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]+'_grid_times_3_2nd-xrange'                                                 & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1

;;----------------------------------------------------------------------------------------
;;  Plot (Ts)_j [eV]
;;----------------------------------------------------------------------------------------
xran           = [1d-1,5d2]
yran           = [1d0,2d5]
deltax         = 1.1d0
yttl0          = 'Number of Events'

ttle0          = 'T_s,avg Histograms'
xttls          = ['Te_avg [SWE, 3DP, ALL, eV]','Tp_avg [SWE, 3DP, ALL, eV]','Ta_avg [SWE, 3DP, ALL, eV]','Te_avg [SWE, 3DP, No Shocks, eV]','Tp_avg [SWE, 3DP, No Shocks, eV]','Ta_avg [SWE, 3DP, No Shocks, eV]','Te_avg [SWE, 3DP, Inside  MOs, eV]','Tp_avg [SWE, 3DP, Inside  MOs, eV]','Ta_avg [SWE, 3DP, Inside  MOs, eV]','Te_avg [SWE, 3DP, Outside MOs, eV]','Tp_avg [SWE, 3DP, Outside MOs, eV]','Ta_avg [SWE, 3DP, Outside MOs, eV]','Te_avg [SWE, 3DP, Vp > 500 km/s, eV]','Tp_avg [SWE, 3DP, Vp > 500 km/s, eV]','Ta_avg [SWE, 3DP, Vp > 500 km/s, eV]','Te_avg [SWE, 3DP, Vp <= 500 km/s, eV]','Tp_avg [SWE, 3DP, Vp <= 500 km/s, eV]','Ta_avg [SWE, 3DP, Vp <= 500 km/s, eV]']
fnames         = ['Te_avg_SWE_3DP_ALL','Tp_avg_SWE_3DP_ALL','Ta_avg_SWE_3DP_ALL','Te_avg_SWE_3DP_No_Shocks','Tp_avg_SWE_3DP_No_Shocks','Ta_avg_SWE_3DP_No_Shocks','Te_avg_SWE_3DP_Inside__MOs','Tp_avg_SWE_3DP_Inside__MOs','Ta_avg_SWE_3DP_Inside__MOs','Te_avg_SWE_3DP_Outside_MOs','Tp_avg_SWE_3DP_Outside_MOs','Ta_avg_SWE_3DP_Outside_MOs','Te_avg_SWE_3DP_Fast_SW','Tp_avg_SWE_3DP_Fast_SW','Ta_avg_SWE_3DP_Fast_SW','Te_avg_SWE_3DP_Slow_SW','Tp_avg_SWE_3DP_Slow_SW','Ta_avg_SWE_3DP_Slow_SW']
xdat           = CREATE_STRUCT(fnames,gtavg_epa[*,0,1],gtavg_epa[*,1,1],gtavg_epa[*,2,1],gtavg_epa[out_ip_shock,0,1],gtavg_epa[out_ip_shock,1,1],gtavg_epa[out_ip_shock,2,1],gtavg_epa[in__mo_all,0,1],gtavg_epa[in__mo_all,1,1],gtavg_epa[in__mo_all,2,1],gtavg_epa[out_mo_all,0,1],gtavg_epa[out_mo_all,1,1],gtavg_epa[out_mo_all,2,1],gtavg_epa[good_fast_swe,0,1],gtavg_epa[good_fast_swe,1,1],gtavg_epa[good_fast_swe,2,1],gtavg_epa[good_slow_swe,0,1],gtavg_epa[good_slow_swe,1,1],gtavg_epa[good_slow_swe,2,1])

ttle0          = 'T_s,per Histograms'
xttls          = ['Te_per [SWE, 3DP, ALL, eV]','Tp_per [SWE, 3DP, ALL, eV]','Ta_per [SWE, 3DP, ALL, eV]','Te_per [SWE, 3DP, No Shocks, eV]','Tp_per [SWE, 3DP, No Shocks, eV]','Ta_per [SWE, 3DP, No Shocks, eV]','Te_per [SWE, 3DP, Inside  MOs, eV]','Tp_per [SWE, 3DP, Inside  MOs, eV]','Ta_per [SWE, 3DP, Inside  MOs, eV]','Te_per [SWE, 3DP, Outside MOs, eV]','Tp_per [SWE, 3DP, Outside MOs, eV]','Ta_per [SWE, 3DP, Outside MOs, eV]','Te_per [SWE, 3DP, Vp > 500 km/s, eV]','Tp_per [SWE, 3DP, Vp > 500 km/s, eV]','Ta_per [SWE, 3DP, Vp > 500 km/s, eV]','Te_per [SWE, 3DP, Vp <= 500 km/s, eV]','Tp_per [SWE, 3DP, Vp <= 500 km/s, eV]','Ta_per [SWE, 3DP, Vp <= 500 km/s, eV]']
fnames         = ['Te_per_SWE_3DP_ALL','Tp_per_SWE_3DP_ALL','Ta_per_SWE_3DP_ALL','Te_per_SWE_3DP_No_Shocks','Tp_per_SWE_3DP_No_Shocks','Ta_per_SWE_3DP_No_Shocks','Te_per_SWE_3DP_Inside__MOs','Tp_per_SWE_3DP_Inside__MOs','Ta_per_SWE_3DP_Inside__MOs','Te_per_SWE_3DP_Outside_MOs','Tp_per_SWE_3DP_Outside_MOs','Ta_per_SWE_3DP_Outside_MOs','Te_per_SWE_3DP_Fast_SW','Tp_per_SWE_3DP_Fast_SW','Ta_per_SWE_3DP_Fast_SW','Te_per_SWE_3DP_Slow_SW','Tp_per_SWE_3DP_Slow_SW','Ta_per_SWE_3DP_Slow_SW']
xdat           = CREATE_STRUCT(fnames,gtper_epa[*,0,1],gtper_epa[*,1,1],gtper_epa[*,2,1],gtper_epa[out_ip_shock,0,1],gtper_epa[out_ip_shock,1,1],gtper_epa[out_ip_shock,2,1],gtper_epa[in__mo_all,0,1],gtper_epa[in__mo_all,1,1],gtper_epa[in__mo_all,2,1],gtper_epa[out_mo_all,0,1],gtper_epa[out_mo_all,1,1],gtper_epa[out_mo_all,2,1],gtper_epa[good_fast_swe,0,1],gtper_epa[good_fast_swe,1,1],gtper_epa[good_fast_swe,2,1],gtper_epa[good_slow_swe,0,1],gtper_epa[good_slow_swe,1,1],gtper_epa[good_slow_swe,2,1])

ttle0          = 'T_s,par Histograms'
xttls          = ['Te_par [SWE, 3DP, ALL, eV]','Tp_par [SWE, 3DP, ALL, eV]','Ta_par [SWE, 3DP, ALL, eV]','Te_par [SWE, 3DP, No Shocks, eV]','Tp_par [SWE, 3DP, No Shocks, eV]','Ta_par [SWE, 3DP, No Shocks, eV]','Te_par [SWE, 3DP, Inside  MOs, eV]','Tp_par [SWE, 3DP, Inside  MOs, eV]','Ta_par [SWE, 3DP, Inside  MOs, eV]','Te_par [SWE, 3DP, Outside MOs, eV]','Tp_par [SWE, 3DP, Outside MOs, eV]','Ta_par [SWE, 3DP, Outside MOs, eV]','Te_par [SWE, 3DP, Vp > 500 km/s, eV]','Tp_par [SWE, 3DP, Vp > 500 km/s, eV]','Ta_par [SWE, 3DP, Vp > 500 km/s, eV]','Te_par [SWE, 3DP, Vp <= 500 km/s, eV]','Tp_par [SWE, 3DP, Vp <= 500 km/s, eV]','Ta_par [SWE, 3DP, Vp <= 500 km/s, eV]']
fnames         = ['Te_par_SWE_3DP_ALL','Tp_par_SWE_3DP_ALL','Ta_par_SWE_3DP_ALL','Te_par_SWE_3DP_No_Shocks','Tp_par_SWE_3DP_No_Shocks','Ta_par_SWE_3DP_No_Shocks','Te_par_SWE_3DP_Inside__MOs','Tp_par_SWE_3DP_Inside__MOs','Ta_par_SWE_3DP_Inside__MOs','Te_par_SWE_3DP_Outside_MOs','Tp_par_SWE_3DP_Outside_MOs','Ta_par_SWE_3DP_Outside_MOs','Te_par_SWE_3DP_Fast_SW','Tp_par_SWE_3DP_Fast_SW','Ta_par_SWE_3DP_Fast_SW','Te_par_SWE_3DP_Slow_SW','Tp_par_SWE_3DP_Slow_SW','Ta_par_SWE_3DP_Slow_SW']
xdat           = CREATE_STRUCT(fnames,gtpar_epa[*,0,1],gtpar_epa[*,1,1],gtpar_epa[*,2,1],gtpar_epa[out_ip_shock,0,1],gtpar_epa[out_ip_shock,1,1],gtpar_epa[out_ip_shock,2,1],gtpar_epa[in__mo_all,0,1],gtpar_epa[in__mo_all,1,1],gtpar_epa[in__mo_all,2,1],gtpar_epa[out_mo_all,0,1],gtpar_epa[out_mo_all,1,1],gtpar_epa[out_mo_all,2,1],gtpar_epa[good_fast_swe,0,1],gtpar_epa[good_fast_swe,1,1],gtpar_epa[good_fast_swe,2,1],gtpar_epa[good_slow_swe,0,1],gtpar_epa[good_slow_swe,1,1],gtpar_epa[good_slow_swe,2,1])

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]+'_grid_times_3'                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1


;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot 2D scatter with contours
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Setup log-scale tick marks
tickpows       = DINDGEN(51) - 25d0
ticksigns      = sign(tickpows)
signs_str      = ['-','+']
xytns_str      = STRARR(N_ELEMENTS(ticksigns))
good_plus      = WHERE(ticksigns GE 0,gdpl,COMPLEMENT=good__neg,NCOMPLEMENT=gdng)
IF (gdng GT 0) THEN xytns_str[good__neg] = signs_str[0]
IF (gdpl GT 0) THEN xytns_str[good_plus] = signs_str[1]
xytv           = 1d1^tickpows
tickpow_str    = xytns_str+STRTRIM(STRING(ABS(tickpows),FORMAT='(I2.2)'),2)
xytn           = '10!U'+tickpow_str+'!N'
;;  Setup Plot Stuff
symb           = 3
n_sum          = 1L      ;;  Reduce resolution of data to avoid overflow
nsum_str       = num2int_str(n_sum[0],NUM_CHAR=3L,/ZERO_PAD)
nlev           = 5L      ;;  Default Levels:  20%, 35%, 50%, 65%, 80%
ccols          = LINDGEN(nlev)*(250L - 30L)/(nlev - 1L) + 30L
con_lim        = {NLEVELS:nlev,C_COLORS:ccols}
;;  Define plot position
plotposi       = [0.1,0.1,0.9,0.9]
syms           = 2.0
thck           = 2.0
lsty           = 2
nxsm           = 30L
;;  Define plot ranges
bran           = [1d-3,1d2]         ;;  beta_s,j range
trrn           = [1d-2,1d2]         ;;  (Ts1/Ts2)_j range
tran           = [1d-1,5d2]         ;;  (Ts)_j [eV] range
;;  Determine XY-tick marks
good_tb        = WHERE(xytv GE bran[0] AND xytv LE bran[1],gdtb)
bbtv_0         = xytv[good_tb]
bbtn_0         = xytn[good_tb]
bbts_0         = gdtb[0] - 1L
good_tr        = WHERE(xytv GE trrn[0] AND xytv LE trrn[1],gdtr)
trtv_0         = xytv[good_tr]
trtn_0         = xytn[good_tr]
trts_0         = gdtr[0] - 1L
good_tt        = WHERE(xytv GE tran[0] AND xytv LE tran[1],gdtt)
tttv_0         = xytv[good_tt]
tttn_0         = xytn[good_tt]
ttts_0         = gdtt[0] - 1L
;;-------------------------------------------------
;;  Plot (Te/Tp)_tot vs. beta_p_tot
;;-------------------------------------------------
;;  Define X- and Y-data
xdat           = beta_avg_epa[*,1,1]
ydat           = Tr_avg_epeaap[*,0,1,1]

x_t_prefx      = 'beta_p_tot'
y_t_prefx      = '(Te/Tp)_tot'
file_pref      = 'Wind_Te-Tp-tot_vs_beta_p_tot_SWE_3DP_ALL'
xyt_suffx      = ' [Only good SWE and 3DP, ALL Conditions]'
;;  Sort by x
sp             = SORT(xdat)
ydat           = TEMPORARY(ydat[sp])
xdat           = TEMPORARY(xdat[sp])
;;  Define plot titles
pttle          = y_t_prefx[0]+' vs. '+x_t_prefx[0]
xttle          = x_t_prefx[0]+xyt_suffx[0]
yttle          = y_t_prefx[0]+xyt_suffx[0]
;;  Define plot structure
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,    $
                  YMINOR:9L,XMINOR:9L,XRANGE:bran,YRANGE:tran,YSTYLE:1,XSTYLE:1,   $
                  XTICKNAME:bbtn_0,XTICKV:bbtv_0,XTICKS:bbts_0,                    $
                  YTICKNAME:trtn_0,YTICKV:trtv_0,YTICKS:trts_0,                    $
                  POSITION:plotposi}
;;  Define file name and Plot [N_SUM = 1]
n_sum          = 1L      ;;  Reduce resolution of data to avoid overflow
nsum_str       = num2int_str(n_sum[0],NUM_CHAR=3L,/ZERO_PAD)
file_name      = file_pref[0]+'_NSUM-'+nsum_str[0]
density_contour_plot_wrapper,xdat,ydat,                                          $
                             PLIMITS=pstr,WIND_N=1,FILE_NAME=file_name,          $
                             XTITLE=xttle,YTITLE=yttle,/YLOG,/XLOG,              $
                             XMIN=bran[0],XMAX=bran[1],NX=nxsm[0],               $
                             YMIN=trrn[0],YMAX=trrn[1],NY=nxsm[0],               $
                             CLIMITS=con_lim,/SMCONT,N_SUM=n_sum[0],             $
                             CPATH_OUT=cpath_out,HIST2D_OUT=hist2d_out,          $  ;; outputs
                             _EXTRA=ex_str


;;-------------------------------------------------
;;  Plot beta_e_tot vs. beta_p_tot
;;-------------------------------------------------
;;  Define X- and Y-data
xdat           = beta_avg_epa[*,1,1]
ydat           = beta_avg_epa[*,0,1]
x_t_prefx      = 'beta_p_tot'
y_t_prefx      = 'beta_e_tot'
file_pref      = 'Wind_beta_e_tot_vs_beta_p_tot_SWE_3DP_ALL'
xyt_suffx      = ' [Only good SWE and 3DP, ALL Conditions]'
;;  Sort by x
sp             = SORT(xdat)
ydat           = TEMPORARY(ydat[sp])
xdat           = TEMPORARY(xdat[sp])
;;  Define plot titles
pttle          = y_t_prefx[0]+' vs. '+x_t_prefx[0]
xttle          = x_t_prefx[0]+xyt_suffx[0]
yttle          = y_t_prefx[0]+xyt_suffx[0]
;;  Define plot structure
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,    $
                  YMINOR:9L,XMINOR:9L,XRANGE:bran,YRANGE:bran,YSTYLE:1,XSTYLE:1,   $
                  XTICKNAME:bbtn_0,XTICKV:bbtv_0,XTICKS:bbts_0,                    $
                  YTICKNAME:bbtn_0,YTICKV:bbtv_0,YTICKS:bbts_0,                    $
                  POSITION:plotposi}
;;  Define file name and Plot [N_SUM = 1]
n_sum          = 1L      ;;  Reduce resolution of data to avoid overflow
nsum_str       = num2int_str(n_sum[0],NUM_CHAR=3L,/ZERO_PAD)
file_name      = file_pref[0]+'_NSUM-'+nsum_str[0]
density_contour_plot_wrapper,xdat,ydat,                                          $
                             PLIMITS=pstr,WIND_N=1,FILE_NAME=file_name,          $
                             XTITLE=xttle,YTITLE=yttle,/YLOG,/XLOG,              $
                             XMIN=bran[0],XMAX=bran[1],NX=nxsm[0],               $
                             YMIN=trrn[0],YMAX=trrn[1],NY=nxsm[0],               $
                             CLIMITS=con_lim,/SMCONT,N_SUM=n_sum[0],             $
                             CPATH_OUT=cpath_out,HIST2D_OUT=hist2d_out,          $  ;; outputs
                             _EXTRA=ex_str






















