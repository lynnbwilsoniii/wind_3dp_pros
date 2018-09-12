;;  $HOME/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_sh_coll_rates_plot.pro

;;----------------------------------------------------------------------------------------
;;  Load batch file
;;----------------------------------------------------------------------------------------
ex_start       = SYSTIME(1)            ;;  Time the execution of all events within
@/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_new_2_batch.pro
MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE

;;----------------------------------------------------------------------------------------
;;  Calculate thermal speeds (most probable speeds) [m/s]
;;----------------------------------------------------------------------------------------
vtefac         = SQRT(2d0*eV2J[0]/me[0])
vtpfac         = SQRT(2d0*eV2J[0]/mp[0])
vtafac         = SQRT(2d0*eV2J[0]/ma[0])
vtetot         = vtefac[0]*SQRT(gtavg_epa[*,0,1])     ;;  Vte_tot [m/s]
vtptot         = vtpfac[0]*SQRT(gtavg_epa[*,1,1])     ;;  Vtp_tot [m/s]
vtatot         = vtafac[0]*SQRT(gtavg_epa[*,2,1])     ;;  Vta_tot [m/s]
;;----------------------------------------------------------------------------------------
;;  Calculate Debye length [m]
;;----------------------------------------------------------------------------------------
dens_e         = 1d6*REFORM(gdens_epa[*,0,1])         ;;  ne [# cm^(-3)]
dens_p         = 1d6*REFORM(gdens_epa[*,1,1])         ;;  np [# cm^(-3)]
dens_a         = 1d6*REFORM(gdens_epa[*,2,1])         ;;  na [# cm^(-3)]

wpefac         = SQRT(1d0*qq[0]^2d0/(me[0]*epo[0]))
wppfac         = SQRT(1d0*qq[0]^2d0/(mp[0]*epo[0]))
wpafac         = SQRT(4d0*qq[0]^2d0/(ma[0]*epo[0]))
wpe            = wpefac[0]*SQRT(dens_e)               ;;  wpe [rad/s]
wpp            = wppfac[0]*SQRT(dens_p)               ;;  wpe [rad/s]
wpa            = wpafac[0]*SQRT(dens_a)               ;;  wpe [rad/s]
lambda_De      = vtetot/wpe                           ;;  L_De [m]

results        = calc_1var_stats(lambda_De,/NAN,/PRINT)
;;
;;             Min. value of X  =         2.7735482
;;             Max. value of X  =         164.90387
;;             Avg. value of X  =         13.810762
;;           Median value of X  =         13.556213
;;     Standard Deviation of X  =         4.6681214
;;  Std. Dev. of the Mean of X  =      0.0051548985
;;               Skewness of X  =         1.1461755
;;               Kurtosis of X  =         7.3867263
;;         Lower Quartile of X  =         10.392222
;;         Upper Quartile of X  =         16.678493
;;     Interquartile Mean of X  =         13.548260
;;    Total # of Elements in X  =       2630161
;;   Finite # of Elements in X  =        820057
;;

;;  Calculate lowest order Lambda ~ 12π ne L_De
lambda_0       = 12d0*!DPI*dens_e*lambda_De^3d0
results        = calc_1var_stats(lambda_0,/NAN,/PRINT)
;;
;;             Min. value of X  =     3.4418104e+10
;;             Max. value of X  =     2.6764462e+13
;;             Avg. value of X  =     7.3192485e+11
;;           Median value of X  =     6.8945424e+11
;;     Standard Deviation of X  =     4.0475081e+11
;;  Std. Dev. of the Mean of X  =     4.4695696e+08
;;               Skewness of X  =         4.4409938
;;               Kurtosis of X  =         97.579419
;;         Lower Quartile of X  =     4.5736713e+11
;;         Upper Quartile of X  =     9.2106723e+11
;;     Interquartile Mean of X  =     6.8912784e+11
;;    Total # of Elements in X  =       2630161
;;   Finite # of Elements in X  =        820057
;;

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate Spitzer-Härm collision rates [# s^(-1)]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate the reduced masses
;;        mu_ab = m_a m_b/(m_a + m_b)
mu_ee          = me[0]/2d0
mu_pp          = mp[0]/2d0
mu_aa          = ma[0]/2d0
mu_ep          = me[0]*mp[0]/(me[0] + mp[0])
mu_ea          = me[0]*ma[0]/(me[0] + ma[0])
mu_pa          = ma[0]*mp[0]/(ma[0] + mp[0])
;;  Calculate effective thermal speeds [km s^(-1)]
;;        V_Tab = [ V_Ta^2 + V_Tb^2 ]^(1/2)
vt_ee          = SQRT(2d0)*vtetot
vt_pp          = SQRT(2d0)*vtptot
vt_aa          = SQRT(2d0)*vtatot
vt_ep          = SQRT(vtetot^2d0 + vtptot^2d0)
vt_ea          = SQRT(vtetot^2d0 + vtatot^2d0)
vt_pa          = SQRT(vtptot^2d0 + vtatot^2d0)
;;----------------------------------------------------------------------------------------
;;  Calculate Coulomb logarithm parameter
;;----------------------------------------------------------------------------------------
;;    Lambda_ab = A_ab/B_ab * [ (wpa/Vta)^2 + (wpb/Vtb)^2 ]^(-1/2)
;;         A_ab = (4π eps_o)*mu_ab*V_Tab^2
;;         B_ab = 2^(1/2) Z_a Z_b e^2
;;        V_Tab = [ V_Ta^2 + V_Tb^2 ]^(1/2)
lamb_fac0      = (4d0*!DPI*epo[0])/(4d0*qq[0]^2d0)
lamb_fac1      = (4d0*!DPI*epo[0])/(SQRT(2d0)*qq[0]^2d0)
lamb_ee        = lamb_fac0[0]*mu_ee[0]*(vt_ee^2d0)*SQRT(2d0)*(wpe/vtetot)
lamb_pp        = lamb_fac0[0]*mu_pp[0]*(vt_pp^2d0)*SQRT(2d0)*(wpp/vtptot)
lamb_aa        = lamb_fac0[0]*mu_aa[0]*(vt_aa^2d0)*SQRT(2d0)*(wpa/vtatot)
lamb_ep        = lamb_fac1[0]*mu_ep[0]*(vt_ep^2d0)*SQRT((wpe/vtetot)^2d0 + (wpp/vtptot)^2d0)
lamb_ea        = lamb_fac1[0]*mu_ea[0]*(vt_ea^2d0)*SQRT((wpe/vtetot)^2d0 + (wpa/vtatot)^2d0)/2d0
lamb_pa        = lamb_fac1[0]*mu_pa[0]*(vt_pa^2d0)*SQRT((wpp/vtptot)^2d0 + (wpa/vtatot)^2d0)/2d0
;;----------------------------------------------------------------------------------------
;;  Calculate like-particle collision rates
;;----------------------------------------------------------------------------------------
;;  Calculate electron-electron collision rates [# s^(-1)]
;;         A_aa = 8*(2π)^(1/2)*n_a*Z_a^4*e^4
;;         B_aa = 3 (4π eps_o)^2*m_a^2*V_Taa^3
;;        V_Taa = 2^(1/2)*V_Ta
;;        nu_aa = A_aa/B_aa * ln| Lambda_aa |
;;              = [4*π^(1/2)*n_a*Z_a^4*e^4]/[3 (4π eps_o)^2*m_a^2*V_Ta^3] * ln| Lambda_aa |
term0          = 4d0*SQRT(!DPI)*qq[0]^4d0
term1          = 3d0*(4d0*!DPI*epo[0])^2d0*me[0]^2d0
nuee_fac       = term0[0]/term1[0]
nuee_tot       = nuee_fac[0]*dens_e*ALOG(lamb_ee)/vtetot^3d0
;;  Calculate proton-proton collision rates [# s^(-1)]
term0          = 4d0*SQRT(!DPI)*qq[0]^4d0
term1          = 3d0*(4d0*!DPI*epo[0])^2d0*mp[0]^2d0
nupp_fac       = term0[0]/term1[0]
nupp_tot       = nupp_fac[0]*dens_p*ALOG(lamb_pp)/vtptot^3d0
;;  Calculate alpha-alpha collision rates [# s^(-1)]
term0          = 4d0*SQRT(!DPI)*(2d0*qq[0])^4d0
term1          = 3d0*(4d0*!DPI*epo[0])^2d0*ma[0]^2d0
nuaa_fac       = term0[0]/term1[0]
nuaa_tot       = nuaa_fac[0]*dens_a*ALOG(lamb_aa)/vtatot^3d0
;;----------------------------------------------------------------------------------------
;;  Calculate electron-ion collision rates
;;         A_ej = 2*(4π)^(1/2)*(n_j*Z_j^2)*(n_e*G_ej*Z_eff)
;;         B_ej = 3 (4π eps_o)^2*∑_s (n_j*Z_j^2)*V_Tej^3
;;         G_ej = Z_e^2*e^4/[(4π eps_o)^2*mu_ej^2]
;;        Z_eff = [∑_s (n_j*Z_j^2)]/[∑_s (n_j*Z_j)]  {s = p, a}
;;              = (n_p + 4*n_a)/n_e
;;        V_Tab = [ V_Ta^2 + V_Tb^2 ]^(1/2)
;;        nu_ej = A_ej/B_ej * ln| Lambda_ej |
;;              = [2*(4π)^(1/2)*(n_j*Z_j^2)*e^4]/[3 (4π eps_o)^2*mu_ej^2*V_Tej^3] ln| Lambda_ej |
;;----------------------------------------------------------------------------------------
;;  Calculate electron-proton collision rates [# s^(-1)]
term0          = 2d0*SQRT(4d0*!DPI)*qq[0]^4d0
term1          = 3d0*(4d0*!DPI*epo[0])^2d0*mu_ep[0]^2d0
nuep_fac       = term0[0]/term1[0]
nuep_tot       = nuep_fac[0]*dens_p*ALOG(lamb_ep)/vt_ep^3d0
;;  Calculate electron-alpha collision rates [# s^(-1)]
term0          = 8d0*SQRT(4d0*!DPI)*qq[0]^4d0
term1          = 3d0*(4d0*!DPI*epo[0])^2d0*mu_ea[0]^2d0
nuea_fac       = term0[0]/term1[0]
nuea_tot       = nuea_fac*dens_a*ALOG(lamb_ea)/vt_ea^3d0
;;----------------------------------------------------------------------------------------
;;  Calculate ion-ion collision rates
;;         A_ij = 2*(2π)^(1/2)*(n_j*Z_j^2*Z_i^2)*e^4
;;         B_ij = 3 (4π eps_o)^2*mu_ij^2*V_Tij^3
;;        nu_ij = A_ij/B_ij * ln| Lambda_ij |
;;----------------------------------------------------------------------------------------
;;  Calculate proton-alpha collision rates [# s^(-1)]
term0          = 2d0*SQRT(2d0*!DPI)*(2d0*qq[0])^2d0*qq[0]^2d0
term1          = 3d0*(4d0*!DPI*epo[0])^2d0*mu_pa[0]^2d0
nupa_fac       = term0[0]/term1[0]
nupa_tot       = nupa_fac[0]*dens_a*ALOG(lamb_pa)/vt_pa^3d0
;;----------------------------------------------------------------------------------------
;;  Calculate ion-acoustic collision rates [# s^(-1)]
;;----------------------------------------------------------------------------------------
de_mag         = 1d-3                                  ;;  Try a 1 mV/m electric field amplitude
nuia_fac       = epo[0]/(2d0*1d0*eV2J[0])
nuia_1mV       = nuia_fac[0]*wpe*de_mag[0]^2d0/(dens_e*REFORM(gtavg_epa[*,0,1]))
de_mag         = 1d-4                                  ;;  Try a 0.1 mV/m electric field amplitude
nuia01mV       = nuia_fac[0]*wpe*de_mag[0]^2d0/(dens_e*REFORM(gtavg_epa[*,0,1]))

;;----------------------------------------------------------------------------------------
;;  Plot nu_ss' rates [# s^(-1)]
;;----------------------------------------------------------------------------------------
xran           = [1d-10,1d-1]
yran           = [1d0,1d5]
deltax         = 1.1d0
yttl0          = 'Number of Events'
ttle0          = "nu_ss' Rates"

xttls          = ['nu_ee [3DP, SWE, ALL, # s^(-1)]','nu_ee [3DP, SWE, No Shocks, # s^(-1)]','nu_ee [3DP, SWE, Inside  MOs, # s^(-1)]','nu_ee [3DP, SWE, Outside MOs, # s^(-1)]','nu_ee [3DP, SWE, Vp > 500 km/s, # s^(-1)]','nu_ee [3DP, SWE, Vp <= 500 km/s, # s^(-1)]']
fnames         = ['nu_ee_3DP_SWE_ALL','nu_ee_3DP_SWE_No_Shocks','nu_ee_3DP_SWE_Inside__MOs','nu_ee_3DP_SWE_Outside_MOs','nu_ee_3DP_SWE_Fast_SW','nu_ee_3DP_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,nuee_tot,nuee_tot[out_ip_shock],nuee_tot[in__mo_all],nuee_tot[out_mo_all],nuee_tot[good_fast_swe],nuee_tot[good_slow_swe])

xttls          = ['nu_ep [3DP, SWE, ALL, # s^(-1)]','nu_ep [3DP, SWE, No Shocks, # s^(-1)]','nu_ep [3DP, SWE, Inside  MOs, # s^(-1)]','nu_ep [3DP, SWE, Outside MOs, # s^(-1)]','nu_ep [3DP, SWE, Vp > 500 km/s, # s^(-1)]','nu_ep [3DP, SWE, Vp <= 500 km/s, # s^(-1)]']
fnames         = ['nu_ep_3DP_SWE_ALL','nu_ep_3DP_SWE_No_Shocks','nu_ep_3DP_SWE_Inside__MOs','nu_ep_3DP_SWE_Outside_MOs','nu_ep_3DP_SWE_Fast_SW','nu_ep_3DP_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,nuep_tot,nuep_tot[out_ip_shock],nuep_tot[in__mo_all],nuep_tot[out_mo_all],nuep_tot[good_fast_swe],nuep_tot[good_slow_swe])

xttls          = ['nu_ea [3DP, SWE, ALL, # s^(-1)]','nu_ea [3DP, SWE, No Shocks, # s^(-1)]','nu_ea [3DP, SWE, Inside  MOs, # s^(-1)]','nu_ea [3DP, SWE, Outside MOs, # s^(-1)]','nu_ea [3DP, SWE, Vp > 500 km/s, # s^(-1)]','nu_ea [3DP, SWE, Vp <= 500 km/s, # s^(-1)]']
fnames         = ['nu_ea_3DP_SWE_ALL','nu_ea_3DP_SWE_No_Shocks','nu_ea_3DP_SWE_Inside__MOs','nu_ea_3DP_SWE_Outside_MOs','nu_ea_3DP_SWE_Fast_SW','nu_ea_3DP_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,nuea_tot,nuea_tot[out_ip_shock],nuea_tot[in__mo_all],nuea_tot[out_mo_all],nuea_tot[good_fast_swe],nuea_tot[good_slow_swe])

xttls          = ['nu_pp [3DP, SWE, ALL, # s^(-1)]','nu_pp [3DP, SWE, No Shocks, # s^(-1)]','nu_pp [3DP, SWE, Inside  MOs, # s^(-1)]','nu_pp [3DP, SWE, Outside MOs, # s^(-1)]','nu_pp [3DP, SWE, Vp > 500 km/s, # s^(-1)]','nu_pp [3DP, SWE, Vp <= 500 km/s, # s^(-1)]']
fnames         = ['nu_pp_3DP_SWE_ALL','nu_pp_3DP_SWE_No_Shocks','nu_pp_3DP_SWE_Inside__MOs','nu_pp_3DP_SWE_Outside_MOs','nu_pp_3DP_SWE_Fast_SW','nu_pp_3DP_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,nupp_tot,nupp_tot[out_ip_shock],nupp_tot[in__mo_all],nupp_tot[out_mo_all],nupp_tot[good_fast_swe],nupp_tot[good_slow_swe])

xttls          = ['nu_pa [3DP, SWE, ALL, # s^(-1)]','nu_pa [3DP, SWE, No Shocks, # s^(-1)]','nu_pa [3DP, SWE, Inside  MOs, # s^(-1)]','nu_pa [3DP, SWE, Outside MOs, # s^(-1)]','nu_pa [3DP, SWE, Vp > 500 km/s, # s^(-1)]','nu_pa [3DP, SWE, Vp <= 500 km/s, # s^(-1)]']
fnames         = ['nu_pa_3DP_SWE_ALL','nu_pa_3DP_SWE_No_Shocks','nu_pa_3DP_SWE_Inside__MOs','nu_pa_3DP_SWE_Outside_MOs','nu_pa_3DP_SWE_Fast_SW','nu_pa_3DP_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,nupa_tot,nupa_tot[out_ip_shock],nupa_tot[in__mo_all],nupa_tot[out_mo_all],nupa_tot[good_fast_swe],nupa_tot[good_slow_swe])

xttls          = ['nu_aa [3DP, SWE, ALL, # s^(-1)]','nu_aa [3DP, SWE, No Shocks, # s^(-1)]','nu_aa [3DP, SWE, Inside  MOs, # s^(-1)]','nu_aa [3DP, SWE, Outside MOs, # s^(-1)]','nu_aa [3DP, SWE, Vp > 500 km/s, # s^(-1)]','nu_aa [3DP, SWE, Vp <= 500 km/s, # s^(-1)]']
fnames         = ['nu_aa_3DP_SWE_ALL','nu_aa_3DP_SWE_No_Shocks','nu_aa_3DP_SWE_Inside__MOs','nu_aa_3DP_SWE_Outside_MOs','nu_aa_3DP_SWE_Fast_SW','nu_aa_3DP_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,nuaa_tot,nuaa_tot[out_ip_shock],nuaa_tot[in__mo_all],nuaa_tot[out_mo_all],nuaa_tot[good_fast_swe],nuaa_tot[good_slow_swe])


ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]+'_grid_times_3'                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1




;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuee_tot [SWE, 3DP, ALL, # s^(-1)]        :    9.67e-09  1.21e-04  3.78e-06  2.47e-06  3.81e-06  4.20e-09  3.75e+00  2.68e+01  1.59e-06  4.55e-06  2.65e-06     2630161      820057
;;  nuep_tot [SWE, 3DP, ALL, # s^(-1)]        :    4.18e-08  1.13e-04  4.53e-06  3.04e-06  4.33e-06  6.48e-09  3.35e+00  2.20e+01  1.81e-06  5.83e-06  3.30e-06     2630161      445801
;;  nuea_tot [SWE, 3DP, ALL, # s^(-1)]        :    2.42e-08  5.19e-05  6.99e-07  4.38e-07  9.59e-07  2.18e-09  7.83e+00  1.31e+02  2.78e-07  7.58e-07  4.62e-07     2630161      193704
;;  nupp_tot [SWE, 3DP, ALL, # s^(-1)]        :    5.50e-12  3.21e-05  2.57e-07  1.01e-07  4.25e-07  4.06e-10  7.48e+00  2.24e+02  2.94e-08  3.03e-07  1.20e-07     2630161     1095314
;;  nupa_tot [SWE, 3DP, ALL, # s^(-1)]        :    2.82e-11  3.10e-06  3.35e-08  1.46e-08  7.37e-08  1.07e-10  1.20e+01  2.55e+02  6.45e-09  3.34e-08  1.62e-08     2630161      476255
;;  nuaa_tot [SWE, 3DP, ALL, # s^(-1)]        :    1.38e-11  7.61e-06  5.59e-08  1.75e-08  1.29e-07  1.86e-10  9.64e+00  1.81e+02  4.66e-09  5.57e-08  2.15e-08     2630161      476255

;;----------------------------------------------------------------------------------------
;;  Plot nu_iaw rates [# s^(-1)]
;;----------------------------------------------------------------------------------------
xran           = [1d-10,1d-1]
yran           = [1d0,1d5]
deltax         = 1.1d0
yttl0          = 'Number of Events'
ttle0          = "nu_ss' Rates"

xttls          = ['nu_iaw [3DP, SWE, ALL, # s^(-1), dE ~ 1 mV/m]','nu_iaw [3DP, SWE, No Shocks, # s^(-1), dE ~ 1 mV/m]','nu_iaw [3DP, SWE, Inside  MOs, # s^(-1), dE ~ 1 mV/m]','nu_iaw [3DP, SWE, Outside MOs, # s^(-1), dE ~ 1 mV/m]','nu_iaw [3DP, SWE, Vp > 500 km/s, # s^(-1), dE ~ 1 mV/m]','nu_iaw [3DP, SWE, Vp <= 500 km/s, # s^(-1), dE ~ 1 mV/m]']
fnames         = ['nu_iaw_1mVm_3DP_SWE_ALL','nu_iaw_1mVm_3DP_SWE_No_Shocks','nu_iaw_1mVm_3DP_SWE_Inside__MOs','nu_iaw_1mVm_3DP_SWE_Outside_MOs','nu_iaw_1mVm_3DP_SWE_Fast_SW','nu_iaw_1mVm_3DP_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,nuia_1mV,nuia_1mV[out_ip_shock],nuia_1mV[in__mo_all],nuia_1mV[out_mo_all],nuia_1mV[good_fast_swe],nuia_1mV[good_slow_swe])

xttls          = ['nu_iaw [3DP, SWE, ALL, # s^(-1), dE ~ 0.1 mV/m]','nu_iaw [3DP, SWE, No Shocks, # s^(-1), dE ~ 0.1 mV/m]','nu_iaw [3DP, SWE, Inside  MOs, # s^(-1), dE ~ 0.1 mV/m]','nu_iaw [3DP, SWE, Outside MOs, # s^(-1), dE ~ 0.1 mV/m]','nu_iaw [3DP, SWE, Vp > 500 km/s, # s^(-1), dE ~ 0.1 mV/m]','nu_iaw [3DP, SWE, Vp <= 500 km/s, # s^(-1), dE ~ 0.1 mV/m]']
fnames         = ['nu_iaw_01mVm_3DP_SWE_ALL','nu_iaw_01mVm_3DP_SWE_No_Shocks','nu_iaw_01mVm_3DP_SWE_Inside__MOs','nu_iaw_01mVm_3DP_SWE_Outside_MOs','nu_iaw_01mVm_3DP_SWE_Fast_SW','nu_iaw_01mVm_3DP_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,nuia01mV,nuia01mV[out_ip_shock],nuia01mV[in__mo_all],nuia01mV[out_mo_all],nuia01mV[good_fast_swe],nuia01mV[good_slow_swe])

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]+'_grid_times_3'                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1

;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV [SWE, 3DP, ALL, # s^(-1)]        :    6.62e-05  3.38e-03  5.09e-04  4.82e-04  1.79e-04  1.98e-07  1.05e+00  2.59e+00  3.82e-04  6.08e-04  4.86e-04     2630161      820057
;;  nuia_1mV [SWE, 3DP, ALL, # s^(-1)]        :    6.62e-03  3.38e-01  5.09e-02  4.82e-02  1.79e-02  1.98e-05  1.05e+00  2.59e+00  3.82e-02  6.08e-02  4.86e-02     2630161      820057

;;----------------------------------------------------------------------------------------
;;  Plot nu_iaw/nu_ss' ratios [N/A, for ∂E ~ 0.1 mV/m]
;;----------------------------------------------------------------------------------------
xran           = [1d0,1d6]
yran           = [1d0,1d5]
deltax         = 1.1d0
yttl0          = 'Number of Events'
ttle0          = "nu_iaw/nu_ss' Rates [for dE ~ 0.1 mV/m]"

xttls          = ['nu_iaw/nu_ee [3DP, SWE, ALL]','nu_iaw/nu_ee [3DP, SWE, No Shocks]','nu_iaw/nu_ee [3DP, SWE, Inside  MOs]','nu_iaw/nu_ee [3DP, SWE, Outside MOs]','nu_iaw/nu_ee [3DP, SWE, Vp > 500 km/s]','nu_iaw/nu_ee [3DP, SWE, Vp <= 500 km/s]']
fnames         = ['nu_iaw_to_nu_ee_3DP_SWE_ALL','nu_iaw_to_nu_ee_3DP_SWE_No_Shocks','nu_iaw_to_nu_ee_3DP_SWE_Inside__MOs','nu_iaw_to_nu_ee_3DP_SWE_Outside_MOs','nu_iaw_to_nu_ee_3DP_SWE_Fast_SW','nu_iaw_to_nu_ee_3DP_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,nuia01mV/nuee_tot,nuia01mV[out_ip_shock]/nuee_tot[out_ip_shock],nuia01mV[in__mo_all]/nuee_tot[in__mo_all],nuia01mV[out_mo_all]/nuee_tot[out_mo_all],nuia01mV[good_fast_swe]/nuee_tot[good_fast_swe],nuia01mV[good_slow_swe]/nuee_tot[good_slow_swe])

xttls          = ['nu_iaw/nu_ep [3DP, SWE, ALL]','nu_iaw/nu_ep [3DP, SWE, No Shocks]','nu_iaw/nu_ep [3DP, SWE, Inside  MOs]','nu_iaw/nu_ep [3DP, SWE, Outside MOs]','nu_iaw/nu_ep [3DP, SWE, Vp > 500 km/s]','nu_iaw/nu_ep [3DP, SWE, Vp <= 500 km/s]']
fnames         = ['nu_iaw_to_nu_ep_3DP_SWE_ALL','nu_iaw_to_nu_ep_3DP_SWE_No_Shocks','nu_iaw_to_nu_ep_3DP_SWE_Inside__MOs','nu_iaw_to_nu_ep_3DP_SWE_Outside_MOs','nu_iaw_to_nu_ep_3DP_SWE_Fast_SW','nu_iaw_to_nu_ep_3DP_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,nuia01mV/nuep_tot,nuia01mV[out_ip_shock]/nuep_tot[out_ip_shock],nuia01mV[in__mo_all]/nuep_tot[in__mo_all],nuia01mV[out_mo_all]/nuep_tot[out_mo_all],nuia01mV[good_fast_swe]/nuep_tot[good_fast_swe],nuia01mV[good_slow_swe]/nuep_tot[good_slow_swe])

xttls          = ['nu_iaw/nu_ea [3DP, SWE, ALL]','nu_iaw/nu_ea [3DP, SWE, No Shocks]','nu_iaw/nu_ea [3DP, SWE, Inside  MOs]','nu_iaw/nu_ea [3DP, SWE, Outside MOs]','nu_iaw/nu_ea [3DP, SWE, Vp > 500 km/s]','nu_iaw/nu_ea [3DP, SWE, Vp <= 500 km/s]']
fnames         = ['nu_iaw_to_nu_ea_3DP_SWE_ALL','nu_iaw_to_nu_ea_3DP_SWE_No_Shocks','nu_iaw_to_nu_ea_3DP_SWE_Inside__MOs','nu_iaw_to_nu_ea_3DP_SWE_Outside_MOs','nu_iaw_to_nu_ea_3DP_SWE_Fast_SW','nu_iaw_to_nu_ea_3DP_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,nuia01mV/nuea_tot,nuia01mV[out_ip_shock]/nuea_tot[out_ip_shock],nuia01mV[in__mo_all]/nuea_tot[in__mo_all],nuia01mV[out_mo_all]/nuea_tot[out_mo_all],nuia01mV[good_fast_swe]/nuea_tot[good_fast_swe],nuia01mV[good_slow_swe]/nuea_tot[good_slow_swe])

xttls          = ['nu_iaw/nu_pp [3DP, SWE, ALL]','nu_iaw/nu_pp [3DP, SWE, No Shocks]','nu_iaw/nu_pp [3DP, SWE, Inside  MOs]','nu_iaw/nu_pp [3DP, SWE, Outside MOs]','nu_iaw/nu_pp [3DP, SWE, Vp > 500 km/s]','nu_iaw/nu_pp [3DP, SWE, Vp <= 500 km/s]']
fnames         = ['nu_iaw_to_nu_pp_3DP_SWE_ALL','nu_iaw_to_nu_pp_3DP_SWE_No_Shocks','nu_iaw_to_nu_pp_3DP_SWE_Inside__MOs','nu_iaw_to_nu_pp_3DP_SWE_Outside_MOs','nu_iaw_to_nu_pp_3DP_SWE_Fast_SW','nu_iaw_to_nu_pp_3DP_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,nuia01mV/nupp_tot,nuia01mV[out_ip_shock]/nupp_tot[out_ip_shock],nuia01mV[in__mo_all]/nupp_tot[in__mo_all],nuia01mV[out_mo_all]/nupp_tot[out_mo_all],nuia01mV[good_fast_swe]/nupp_tot[good_fast_swe],nuia01mV[good_slow_swe]/nupp_tot[good_slow_swe])

xttls          = ['nu_iaw/nu_pa [3DP, SWE, ALL]','nu_iaw/nu_pa [3DP, SWE, No Shocks]','nu_iaw/nu_pa [3DP, SWE, Inside  MOs]','nu_iaw/nu_pa [3DP, SWE, Outside MOs]','nu_iaw/nu_pa [3DP, SWE, Vp > 500 km/s]','nu_iaw/nu_pa [3DP, SWE, Vp <= 500 km/s]']
fnames         = ['nu_iaw_to_nu_pa_3DP_SWE_ALL','nu_iaw_to_nu_pa_3DP_SWE_No_Shocks','nu_iaw_to_nu_pa_3DP_SWE_Inside__MOs','nu_iaw_to_nu_pa_3DP_SWE_Outside_MOs','nu_iaw_to_nu_pa_3DP_SWE_Fast_SW','nu_iaw_to_nu_pa_3DP_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,nuia01mV/nupa_tot,nuia01mV[out_ip_shock]/nupa_tot[out_ip_shock],nuia01mV[in__mo_all]/nupa_tot[in__mo_all],nuia01mV[out_mo_all]/nupa_tot[out_mo_all],nuia01mV[good_fast_swe]/nupa_tot[good_fast_swe],nuia01mV[good_slow_swe]/nupa_tot[good_slow_swe])

xttls          = ['nu_iaw/nu_aa [3DP, SWE, ALL]','nu_iaw/nu_aa [3DP, SWE, No Shocks]','nu_iaw/nu_aa [3DP, SWE, Inside  MOs]','nu_iaw/nu_aa [3DP, SWE, Outside MOs]','nu_iaw/nu_aa [3DP, SWE, Vp > 500 km/s]','nu_iaw/nu_aa [3DP, SWE, Vp <= 500 km/s]']
fnames         = ['nu_iaw_to_nu_aa_3DP_SWE_ALL','nu_iaw_to_nu_aa_3DP_SWE_No_Shocks','nu_iaw_to_nu_aa_3DP_SWE_Inside__MOs','nu_iaw_to_nu_aa_3DP_SWE_Outside_MOs','nu_iaw_to_nu_aa_3DP_SWE_Fast_SW','nu_iaw_to_nu_aa_3DP_SWE_Slow_SW']
xdat           = CREATE_STRUCT(fnames,nuia01mV/nuaa_tot,nuia01mV[out_ip_shock]/nuaa_tot[out_ip_shock],nuia01mV[in__mo_all]/nuaa_tot[in__mo_all],nuia01mV[out_mo_all]/nuaa_tot[out_mo_all],nuia01mV[good_fast_swe]/nuaa_tot[good_fast_swe],nuia01mV[good_slow_swe]/nuaa_tot[good_slow_swe])


ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]+'_grid_times_3'                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1








;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV/nuee_tot [SWE, 3DP, ALL]        :    2.67e+00  1.44e+05  2.62e+02  1.85e+02  3.60e+02  3.98e-01  8.99e+01  3.14e+04  9.38e+01  3.45e+02  1.96e+02     2630161      820057
;;  nuia01mV/nupp_tot [SWE, 3DP, ALL]        :    3.38e+01  8.96e+06  1.59e+04  4.37e+03  4.21e+04  6.30e+01  3.50e+01  5.22e+03  1.42e+03  1.43e+04  5.42e+03     2630161      445801
;;  nuia01mV/nuaa_tot [SWE, 3DP, ALL]        :    1.05e+02  2.53e+07  1.00e+05  3.09e+04  2.03e+05  4.62e+02  2.11e+01  1.72e+03  9.61e+03  1.13e+05  4.03e+04     2630161      193704
;;  nuia01mV/nuep_tot [SWE, 3DP, ALL]        :    3.93e+00  2.11e+04  2.17e+02  1.52e+02  2.34e+02  3.50e-01  9.12e+00  3.35e+02  7.52e+01  2.89e+02  1.61e+02     2630161      445801
;;  nuia01mV/nuea_tot [SWE, 3DP, ALL]        :    1.06e+01  2.49e+04  1.31e+03  1.03e+03  1.12e+03  2.54e+00  2.75e+00  1.65e+01  5.62e+02  1.72e+03  1.06e+03     2630161      193704
;;  nuia01mV/nupa_tot [SWE, 3DP, ALL]        :    2.36e+02  1.37e+07  6.87e+04  3.50e+04  1.12e+05  2.55e+02  1.92e+01  1.52e+03  1.52e+04  8.00e+04  3.89e+04     2630161      193704




























