;;  $HOME/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_sh_coll_rates_fixed.pro

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
;;  Print stats
;;----------------------------------------------------------------------------------------
line0          = ';;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
line1          = ';;========================================================================================'
line2          = ';;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #'
line3          = ';;======================================================================================================================================================================================'
mform          = '(a51,11e10.2,2I)'

;;  Print nuee_tot [# s^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuee_tot [# s^(-1)] Stats'                                                                                       & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = nuee_tot                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuee_tot [SWE, 3DP, ALL, # s^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = nuee_tot[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuee_tot [SWE, 3DP, No Shocks, # s^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = nuee_tot[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuee_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nuee_tot[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuee_tot [SWE, 3DP, Outside MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nuee_tot[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuee_tot [SWE, 3DP, Fast SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = nuee_tot[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuee_tot [SWE, 3DP, Slow SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nupp_tot [# s^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nupp_tot [# s^(-1)] Stats'                                                                                       & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = nupp_tot                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupp_tot [SWE, 3DP, ALL, # s^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = nupp_tot[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupp_tot [SWE, 3DP, No Shocks, # s^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = nupp_tot[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupp_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nupp_tot[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupp_tot [SWE, 3DP, Outside MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nupp_tot[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupp_tot [SWE, 3DP, Fast SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = nupp_tot[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupp_tot [SWE, 3DP, Slow SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuaa_tot [# s^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuaa_tot [# s^(-1)] Stats'                                                                                       & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = nuaa_tot                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuaa_tot [SWE, 3DP, ALL, # s^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = nuaa_tot[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuaa_tot [SWE, 3DP, No Shocks, # s^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = nuaa_tot[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuaa_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nuaa_tot[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuaa_tot [SWE, 3DP, Outside MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nuaa_tot[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuaa_tot [SWE, 3DP, Fast SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = nuaa_tot[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuaa_tot [SWE, 3DP, Slow SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuep_tot [# s^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuep_tot [# s^(-1)] Stats'                                                                                       & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = nuep_tot                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuep_tot [SWE, 3DP, ALL, # s^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = nuep_tot[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuep_tot [SWE, 3DP, No Shocks, # s^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = nuep_tot[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuep_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nuep_tot[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuep_tot [SWE, 3DP, Outside MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nuep_tot[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuep_tot [SWE, 3DP, Fast SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = nuep_tot[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuep_tot [SWE, 3DP, Slow SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuea_tot [# s^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuea_tot [# s^(-1)] Stats'                                                                                       & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = nuea_tot                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuea_tot [SWE, 3DP, ALL, # s^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = nuea_tot[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuea_tot [SWE, 3DP, No Shocks, # s^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = nuea_tot[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuea_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nuea_tot[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuea_tot [SWE, 3DP, Outside MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nuea_tot[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuea_tot [SWE, 3DP, Fast SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = nuea_tot[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuea_tot [SWE, 3DP, Slow SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nupa_tot [# s^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nupa_tot [# s^(-1)] Stats'                                                                                       & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = nupa_tot                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupa_tot [SWE, 3DP, ALL, # s^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = nupa_tot[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupa_tot [SWE, 3DP, No Shocks, # s^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = nupa_tot[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupa_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nupa_tot[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupa_tot [SWE, 3DP, Outside MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nupa_tot[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupa_tot [SWE, 3DP, Fast SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = nupa_tot[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupa_tot [SWE, 3DP, Slow SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuia_1mV [# s^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuia_1mV [# s^(-1)] Stats'                                                                                       & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = nuia_1mV                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV [SWE, 3DP, ALL, # s^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = nuia_1mV[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV [SWE, 3DP, No Shocks, # s^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = nuia_1mV[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV [SWE, 3DP, Inside  MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nuia_1mV[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV [SWE, 3DP, Outside MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nuia_1mV[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV [SWE, 3DP, Fast SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = nuia_1mV[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV [SWE, 3DP, Slow SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuia01mV [# s^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuia01mV [# s^(-1)] Stats'                                                                                       & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = nuia01mV                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV [SWE, 3DP, ALL, # s^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = nuia01mV[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV [SWE, 3DP, No Shocks, # s^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = nuia01mV[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV [SWE, 3DP, Inside  MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nuia01mV[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV [SWE, 3DP, Outside MOs, # s^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = nuia01mV[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV [SWE, 3DP, Fast SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = nuia01mV[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV [SWE, 3DP, Slow SW, # s^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuee_tot [# s^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuee_tot [SWE, 3DP, ALL, # s^(-1)]        :    9.67e-09  1.21e-04  3.78e-06  2.47e-06  3.81e-06  4.20e-09  3.75e+00  2.68e+01  1.59e-06  4.55e-06  2.65e-06     2630161      820057
;;  nuee_tot [SWE, 3DP, No Shocks, # s^(-1)]  :    9.67e-09  1.21e-04  3.64e-06  2.40e-06  3.62e-06  4.15e-09  3.81e+00  2.82e+01  1.58e-06  4.34e-06  2.57e-06     2435510      760815
;;  nuee_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:    9.67e-09  7.36e-05  5.06e-06  3.54e-06  4.90e-06  2.86e-08  3.09e+00  1.69e+01  1.95e-06  6.67e-06  3.79e-06      128109       29389
;;  nuee_tot [SWE, 3DP, Outside MOs, # s^(-1)]:    1.96e-08  1.21e-04  3.73e-06  2.44e-06  3.75e-06  4.22e-09  3.78e+00  2.74e+01  1.59e-06  4.47e-06  2.62e-06     2502052      790668
;;  nuee_tot [SWE, 3DP, Fast SW, # s^(-1)]    :    5.07e-08  6.31e-05  2.29e-06  1.63e-06  2.76e-06  1.12e-08  6.53e+00  6.35e+01  1.27e-06  2.23e-06  1.67e-06      194462       60700
;;  nuee_tot [SWE, 3DP, Slow SW, # s^(-1)]    :    4.63e-08  1.21e-04  5.07e-06  3.64e-06  4.51e-06  7.18e-09  3.22e+00  2.02e+01  2.19e-06  6.53e-06  3.87e-06      942027      394244
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nupp_tot [# s^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nupp_tot [SWE, 3DP, ALL, # s^(-1)]        :    5.50e-12  3.21e-05  2.57e-07  1.01e-07  4.25e-07  4.06e-10  7.48e+00  2.24e+02  2.94e-08  3.03e-07  1.20e-07     2630161     1095314
;;  nupp_tot [SWE, 3DP, No Shocks, # s^(-1)]  :    5.50e-12  3.21e-05  2.53e-07  9.71e-08  4.20e-07  4.20e-10  7.56e+00  2.35e+02  2.88e-08  2.97e-07  1.17e-07     2435510     1001957
;;  nupp_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:    5.50e-12  2.71e-05  4.54e-07  2.32e-07  8.23e-07  3.05e-09  9.61e+00  1.83e+02  9.15e-08  5.06e-07  2.52e-07      128109       72530
;;  nupp_tot [SWE, 3DP, Outside MOs, # s^(-1)]:    8.59e-12  3.21e-05  2.43e-07  9.36e-08  3.77e-07  3.73e-10  3.94e+00  7.52e+01  2.79e-08  2.86e-07  1.13e-07     2502052     1022784
;;  nupp_tot [SWE, 3DP, Fast SW, # s^(-1)]    :    8.59e-12  1.26e-05  5.06e-08  1.05e-08  2.20e-07  5.33e-10  1.80e+01  5.32e+02  6.03e-09  1.93e-08  1.10e-08      194462      170001
;;  nupp_tot [SWE, 3DP, Slow SW, # s^(-1)]    :    5.50e-12  3.21e-05  2.95e-07  1.33e-07  4.42e-07  4.60e-10  7.27e+00  2.18e+02  4.87e-08  3.58e-07  1.55e-07      942027      925313
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuaa_tot [# s^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuaa_tot [SWE, 3DP, ALL, # s^(-1)]        :    1.38e-11  7.61e-06  5.59e-08  1.75e-08  1.29e-07  1.86e-10  9.64e+00  1.81e+02  4.66e-09  5.57e-08  2.15e-08     2630161      476255
;;  nuaa_tot [SWE, 3DP, No Shocks, # s^(-1)]  :    1.38e-11  7.61e-06  5.47e-08  1.74e-08  1.26e-07  1.93e-10  1.00e+01  1.95e+02  4.61e-09  5.47e-08  2.12e-08     2435510      428536
;;  nuaa_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:    2.59e-11  7.61e-06  1.40e-07  4.58e-08  2.81e-07  1.35e-09  5.74e+00  5.47e+01  1.13e-08  1.50e-07  5.64e-08      128109       43343
;;  nuaa_tot [SWE, 3DP, Outside MOs, # s^(-1)]:    1.38e-11  4.39e-06  4.75e-08  1.61e-08  9.74e-08  1.48e-10  8.60e+00  1.63e+02  4.36e-09  5.04e-08  1.97e-08     2502052      432912
;;  nuaa_tot [SWE, 3DP, Fast SW, # s^(-1)]    :    1.38e-11  3.41e-06  4.60e-08  5.13e-09  1.42e-07  7.99e-10  8.48e+00  1.05e+02  1.18e-09  2.81e-08  7.91e-09      194462       31498
;;  nuaa_tot [SWE, 3DP, Slow SW, # s^(-1)]    :    1.63e-11  7.61e-06  5.66e-08  1.86e-08  1.28e-07  1.91e-10  9.75e+00  1.89e+02  5.10e-09  5.72e-08  2.26e-08      942027      444757
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuep_tot [# s^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuep_tot [SWE, 3DP, ALL, # s^(-1)]        :    4.18e-08  1.13e-04  4.53e-06  3.04e-06  4.33e-06  6.48e-09  3.35e+00  2.20e+01  1.81e-06  5.83e-06  3.30e-06     2630161      445801
;;  nuep_tot [SWE, 3DP, No Shocks, # s^(-1)]  :    5.30e-08  1.13e-04  4.37e-06  2.93e-06  4.16e-06  6.47e-09  3.39e+00  2.28e+01  1.78e-06  5.57e-06  3.18e-06     2435510      412947
;;  nuep_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:    4.18e-08  9.09e-05  5.39e-06  3.58e-06  5.25e-06  3.89e-08  3.05e+00  1.64e+01  2.14e-06  7.07e-06  3.94e-06      128109       18203
;;  nuep_tot [SWE, 3DP, Outside MOs, # s^(-1)]:    5.30e-08  1.13e-04  4.49e-06  3.01e-06  4.28e-06  6.54e-09  3.35e+00  2.23e+01  1.80e-06  5.79e-06  3.28e-06     2502052      427598
;;  nuep_tot [SWE, 3DP, Fast SW, # s^(-1)]    :    4.18e-08  5.90e-05  2.15e-06  1.51e-06  2.67e-06  1.14e-08  6.41e+00  6.04e+01  1.16e-06  2.10e-06  1.55e-06      194462       55111
;;  nuep_tot [SWE, 3DP, Slow SW, # s^(-1)]    :    5.67e-08  1.13e-04  4.86e-06  3.43e-06  4.41e-06  7.05e-09  3.28e+00  2.16e+01  2.05e-06  6.28e-06  3.67e-06      942027      390690
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuea_tot [# s^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuea_tot [SWE, 3DP, ALL, # s^(-1)]        :    2.42e-08  5.19e-05  6.99e-07  4.38e-07  9.59e-07  2.18e-09  7.83e+00  1.31e+02  2.78e-07  7.58e-07  4.62e-07     2630161      193704
;;  nuea_tot [SWE, 3DP, No Shocks, # s^(-1)]  :    2.42e-08  5.19e-05  6.69e-07  4.26e-07  9.29e-07  2.21e-09  8.53e+00  1.55e+02  2.72e-07  7.20e-07  4.47e-07     2435510      177265
;;  nuea_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:    4.05e-08  2.53e-05  1.06e-06  6.14e-07  1.55e-06  1.54e-08  5.71e+00  5.15e+01  3.52e-07  1.09e-06  6.46e-07      128109       10077
;;  nuea_tot [SWE, 3DP, Outside MOs, # s^(-1)]:    2.42e-08  5.19e-05  6.80e-07  4.31e-07  9.12e-07  2.13e-09  7.96e+00  1.44e+02  2.75e-07  7.40e-07  4.54e-07     2502052      183627
;;  nuea_tot [SWE, 3DP, Fast SW, # s^(-1)]    :    4.16e-08  1.74e-05  1.01e-06  4.86e-07  1.36e-06  1.44e-08  3.86e+00  2.34e+01  3.16e-07  1.10e-06  5.59e-07      194462        9002
;;  nuea_tot [SWE, 3DP, Slow SW, # s^(-1)]    :    2.42e-08  5.19e-05  6.84e-07  4.36e-07  9.33e-07  2.17e-09  8.30e+00  1.49e+02  2.76e-07  7.47e-07  4.59e-07      942027      184702
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nupa_tot [# s^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nupa_tot [SWE, 3DP, ALL, # s^(-1)]        :    2.82e-11  3.10e-06  3.35e-08  1.46e-08  7.37e-08  1.07e-10  1.20e+01  2.55e+02  6.45e-09  3.34e-08  1.62e-08     2630161      476255
;;  nupa_tot [SWE, 3DP, No Shocks, # s^(-1)]  :    2.82e-11  3.10e-06  3.24e-08  1.43e-08  7.18e-08  1.10e-10  1.26e+01  2.82e+02  6.37e-09  3.25e-08  1.59e-08     2435510      428536
;;  nupa_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:    5.70e-11  3.10e-06  8.80e-08  3.33e-08  1.79e-07  8.58e-10  6.36e+00  5.95e+01  1.24e-08  8.77e-08  3.85e-08      128109       43343
;;  nupa_tot [SWE, 3DP, Outside MOs, # s^(-1)]:    2.82e-11  2.22e-06  2.80e-08  1.37e-08  4.96e-08  7.53e-11  9.49e+00  1.97e+02  6.15e-09  3.03e-08  1.51e-08     2502052      432912
;;  nupa_tot [SWE, 3DP, Fast SW, # s^(-1)]    :    3.14e-11  2.45e-06  3.50e-08  6.95e-09  1.03e-07  5.82e-10  9.30e+00  1.24e+02  1.84e-09  2.56e-08  8.93e-09      194462       31498
;;  nupa_tot [SWE, 3DP, Slow SW, # s^(-1)]    :    2.82e-11  3.10e-06  3.34e-08  1.50e-08  7.12e-08  1.07e-10  1.23e+01  2.76e+02  6.84e-09  3.38e-08  1.66e-08      942027      444757
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuia_1mV [# s^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia_1mV [SWE, 3DP, ALL, # s^(-1)]        :    6.62e-03  3.38e-01  5.09e-02  4.82e-02  1.79e-02  1.98e-05  1.05e+00  2.59e+00  3.82e-02  6.08e-02  4.86e-02     2630161      820057
;;  nuia_1mV [SWE, 3DP, No Shocks, # s^(-1)]  :    6.62e-03  2.23e-01  5.15e-02  4.89e-02  1.76e-02  2.02e-05  1.02e+00  2.09e+00  3.89e-02  6.13e-02  4.92e-02     2435510      760815
;;  nuia_1mV [SWE, 3DP, Inside  MOs, # s^(-1)]:    8.78e-03  3.38e-01  5.70e-02  5.30e-02  2.42e-02  1.41e-04  1.86e+00  6.56e+00  4.04e-02  6.73e-02  5.32e-02      128109       29389
;;  nuia_1mV [SWE, 3DP, Outside MOs, # s^(-1)]:    6.62e-03  2.56e-01  5.06e-02  4.80e-02  1.76e-02  1.98e-05  9.37e-01  1.71e+00  3.81e-02  6.05e-02  4.84e-02     2502052      790668
;;  nuia_1mV [SWE, 3DP, Fast SW, # s^(-1)]    :    8.82e-03  2.23e-01  6.22e-02  6.12e-02  2.00e-02  8.12e-05  3.82e-01  5.42e-01  4.83e-02  7.47e-02  6.12e-02      194462       60700
;;  nuia_1mV [SWE, 3DP, Slow SW, # s^(-1)]    :    6.62e-03  3.38e-01  4.91e-02  4.67e-02  1.66e-02  2.64e-05  1.25e+00  4.18e+00  3.75e-02  5.80e-02  4.70e-02      942027      394244
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuia01mV [# s^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV [SWE, 3DP, ALL, # s^(-1)]        :    6.62e-05  3.38e-03  5.09e-04  4.82e-04  1.79e-04  1.98e-07  1.05e+00  2.59e+00  3.82e-04  6.08e-04  4.86e-04     2630161      820057
;;  nuia01mV [SWE, 3DP, No Shocks, # s^(-1)]  :    6.62e-05  2.23e-03  5.15e-04  4.89e-04  1.76e-04  2.02e-07  1.02e+00  2.09e+00  3.89e-04  6.13e-04  4.92e-04     2435510      760815
;;  nuia01mV [SWE, 3DP, Inside  MOs, # s^(-1)]:    8.78e-05  3.38e-03  5.70e-04  5.30e-04  2.42e-04  1.41e-06  1.86e+00  6.56e+00  4.04e-04  6.73e-04  5.32e-04      128109       29389
;;  nuia01mV [SWE, 3DP, Outside MOs, # s^(-1)]:    6.62e-05  2.56e-03  5.06e-04  4.80e-04  1.76e-04  1.98e-07  9.37e-01  1.71e+00  3.81e-04  6.05e-04  4.84e-04     2502052      790668
;;  nuia01mV [SWE, 3DP, Fast SW, # s^(-1)]    :    8.82e-05  2.23e-03  6.22e-04  6.12e-04  2.00e-04  8.12e-07  3.82e-01  5.42e-01  4.83e-04  7.47e-04  6.12e-04      194462       60700
;;  nuia01mV [SWE, 3DP, Slow SW, # s^(-1)]    :    6.62e-05  3.38e-03  4.91e-04  4.67e-04  1.66e-04  2.64e-07  1.25e+00  4.18e+00  3.75e-04  5.80e-04  4.70e-04      942027      394244
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



;;----------------------------------------------------------------------------------------
;;  Print ratio stats
;;----------------------------------------------------------------------------------------

;;  Print nuia_1mV/nuee_tot [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = nuia_1mV/nuee_tot                                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV/nuee_tot [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                              & $
x              = nuia_1mV/nupp_tot                                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV/nupp_tot [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                              & $
x              = nuia_1mV/nuaa_tot                                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV/nuaa_tot [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                              & $
x              = nuia_1mV/nuep_tot                                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV/nuep_tot [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                              & $
x              = nuia_1mV/nuea_tot                                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV/nuea_tot [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                              & $
x              = nuia_1mV/nupa_tot                                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV/nupa_tot [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                              & $
PRINT,';;'

;;  Print nuia01mV/nuee_tot [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = nuia01mV/nuee_tot                                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV/nuee_tot [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                              & $
x              = nuia01mV/nupp_tot                                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV/nupp_tot [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                              & $
x              = nuia01mV/nuaa_tot                                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV/nuaa_tot [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                              & $
x              = nuia01mV/nuep_tot                                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV/nuep_tot [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                              & $
x              = nuia01mV/nuea_tot                                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV/nuea_tot [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                              & $
x              = nuia01mV/nupa_tot                                                                                          & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV/nupa_tot [SWE, 3DP, ALL]        :  ',stats,FORMAT=mform[0]                                              & $
PRINT,';;'

;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia_1mV/nuee_tot [SWE, 3DP, ALL]        :    2.67e+02  1.44e+07  2.62e+04  1.85e+04  3.60e+04  3.98e+01  8.99e+01  3.14e+04  9.38e+03  3.45e+04  1.96e+04     2630161      820057
;;  nuia_1mV/nupp_tot [SWE, 3DP, ALL]        :    3.38e+03  8.96e+08  1.59e+06  4.37e+05  4.21e+06  6.30e+03  3.50e+01  5.22e+03  1.42e+05  1.43e+06  5.42e+05     2630161      445801
;;  nuia_1mV/nuaa_tot [SWE, 3DP, ALL]        :    1.05e+04  2.53e+09  1.00e+07  3.09e+06  2.03e+07  4.62e+04  2.11e+01  1.72e+03  9.61e+05  1.13e+07  4.03e+06     2630161      193704
;;  nuia_1mV/nuep_tot [SWE, 3DP, ALL]        :    3.93e+02  2.11e+06  2.17e+04  1.52e+04  2.34e+04  3.50e+01  9.12e+00  3.35e+02  7.52e+03  2.89e+04  1.61e+04     2630161      445801
;;  nuia_1mV/nuea_tot [SWE, 3DP, ALL]        :    1.06e+03  2.49e+06  1.31e+05  1.03e+05  1.12e+05  2.54e+02  2.75e+00  1.65e+01  5.62e+04  1.72e+05  1.06e+05     2630161      193704
;;  nuia_1mV/nupa_tot [SWE, 3DP, ALL]        :    2.36e+04  1.37e+09  6.87e+06  3.50e+06  1.12e+07  2.55e+04  1.92e+01  1.52e+03  1.52e+06  8.00e+06  3.89e+06     2630161      193704
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV/nuee_tot [SWE, 3DP, ALL]        :    2.67e+00  1.44e+05  2.62e+02  1.85e+02  3.60e+02  3.98e-01  8.99e+01  3.14e+04  9.38e+01  3.45e+02  1.96e+02     2630161      820057
;;  nuia01mV/nupp_tot [SWE, 3DP, ALL]        :    3.38e+01  8.96e+06  1.59e+04  4.37e+03  4.21e+04  6.30e+01  3.50e+01  5.22e+03  1.42e+03  1.43e+04  5.42e+03     2630161      445801
;;  nuia01mV/nuaa_tot [SWE, 3DP, ALL]        :    1.05e+02  2.53e+07  1.00e+05  3.09e+04  2.03e+05  4.62e+02  2.11e+01  1.72e+03  9.61e+03  1.13e+05  4.03e+04     2630161      193704
;;  nuia01mV/nuep_tot [SWE, 3DP, ALL]        :    3.93e+00  2.11e+04  2.17e+02  1.52e+02  2.34e+02  3.50e-01  9.12e+00  3.35e+02  7.52e+01  2.89e+02  1.61e+02     2630161      445801
;;  nuia01mV/nuea_tot [SWE, 3DP, ALL]        :    1.06e+01  2.49e+04  1.31e+03  1.03e+03  1.12e+03  2.54e+00  2.75e+00  1.65e+01  5.62e+02  1.72e+03  1.06e+03     2630161      193704
;;  nuia01mV/nupa_tot [SWE, 3DP, ALL]        :    2.36e+02  1.37e+07  6.87e+04  3.50e+04  1.12e+05  2.55e+02  1.92e+01  1.52e+03  1.52e+04  8.00e+04  3.89e+04     2630161      193704
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

xra01mV        = calc_1var_stats([nuia01mV/nuee_tot,nuia01mV/nupp_tot,nuia01mV/nuaa_tot,nuia01mV/nuep_tot,nuia01mV/nuea_tot,nuia01mV/nupa_tot],/NAN)
PRINT,';;  ',xra01mV
;;            Min            Max             Mean           Median          StdDev.         StDvMn.           Skew.          Kurt.            Q1              Q2              IQM          Tot.  #          Fin.  #
;;         2.6700380       25313213.       17611.964       439.64151       76719.783       50.667214       41.693634       8006.2910       152.07414       4683.6182       870.57279       15780966.       2292771.0


frate_iaw      = 0.124d0                    ;;  IAWs occur at a rate of ~12.4% assuming they occur when (Te/Tp)_tot ≥ 3
frate__cs      = 942d0/864d2                ;;  Occurrence rate of current sheets ~ 1.1%
frate_net      = frate__cs[0]*frate_iaw[0]  ;;  Net IAW occurrence rate ~ 0.14%

PRINT,';;  ',xra01mV[0:1]*frate_iaw[0]   & $
PRINT,';;  ',xra01mV[0:1]*frate_net[0]
;;        0.33108471       3138838.4
;;      0.0036097430       34222.057


PRINT,';;  ',SQRT(1d0/(xra01mV[0:1]*frate_iaw[0]))*0.1   & $
PRINT,';;  ',SQRT(1d0/(xra01mV[0:1]*frate_net[0]))*0.1
;;        0.17379227   5.6443707e-05
;;         1.6644159   0.00054056379

PRINT,';;  ',xra01mV[0:1]*frate_iaw[0]*1d3   & $
PRINT,';;  ',xra01mV[0:1]*frate_net[0]*1d3
;;         331.08471   3.1388384e+09
;;         3.6097430       34222057.


PRINT,';;  ',xra01mV[[0,1,3]]*frate_net[0]
;;      0.0036097430       34222.057      0.59437090


med01mV        = [1.85e2,4.37e3,3.09e4,1.52e2,1.03e3,3.50e4]   ;;  All Median values of ratios
PRINT,';;  ',med01mV*frate_net[0]
;;        0.25010972       5.9079972       41.775083      0.20549556       1.3925028       47.318056


min_cols       = FLOOR(xra01mV[0]*frate_net[0]*1d3)
stat_nuep      = calc_1var_stats(nuep_tot,/NAN)
stat_nupa      = calc_1var_stats(nupa_tot,/NAN)
PRINT,';;  ',(1d0/stat_nuep[[0,1,3]])*min_cols[0]/864d2  & $
PRINT,';;  ',(1d0/stat_nupa[[0,1,3]])*min_cols[0]/864d2
;;         830.32335      0.30646096       11.428486
;;         1230760.3       11.205297       2382.6538












