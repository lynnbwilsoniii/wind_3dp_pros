;;  $HOME/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_sh_coll_rates_fixed_2nd_units.pro

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
;;  Calculate relevant frequencies [Hz]
;;----------------------------------------------------------------------------------------
wpefac         = SQRT(1d0*qq[0]^2d0/(me[0]*epo[0]))
wppfac         = SQRT(1d0*qq[0]^2d0/(mp[0]*epo[0]))
wpafac         = SQRT(4d0*qq[0]^2d0/(ma[0]*epo[0]))
wcefac         = 1d-9*qq[0]/me[0]
wcpfac         = 1d-9*qq[0]/mp[0]
wcafac         = 1d-9*qq[0]/ma[0]
;;  Define densities
dens_e         = 1d6*REFORM(gdens_epa[*,0,1])         ;;  ne [# m^(-3)]
dens_p         = 1d6*REFORM(gdens_epa[*,1,1])         ;;  np [# m^(-3)]
dens_a         = 1d6*REFORM(gdens_epa[*,2,1])         ;;  na [# m^(-3)]
;;  Define plasma frequencies
wpe            = wpefac[0]*SQRT(dens_e)               ;;  wpe [rad/s]
wpp            = wppfac[0]*SQRT(dens_p)               ;;  wpp [rad/s]
wpa            = wpafac[0]*SQRT(dens_a)               ;;  wpa [rad/s]
fpe            = wpe/(2d0*!DPI)                       ;;  fpe [Hz]
fpp            = wpp/(2d0*!DPI)                       ;;  fpp [Hz]
fpa            = wpa/(2d0*!DPI)                       ;;  fpa [Hz]
;;  Define cyclotron frequencies
wce            = wcefac[0]*gbmag_mfi                  ;;  wce [rad/s]
wcp            = wcpfac[0]*gbmag_mfi                  ;;  wcp [rad/s]
wca            = wcafac[0]*gbmag_mfi                  ;;  wca [rad/s]
fce            = wce/(2d0*!DPI)                       ;;  fce [Hz]
fcp            = wcp/(2d0*!DPI)                       ;;  fcp [Hz]
fca            = wca/(2d0*!DPI)                       ;;  fca [Hz]


;;----------------------------------------------------------------------------------------
;;  Calculate Debye length [m]
;;----------------------------------------------------------------------------------------
lambda_De      = vtetot/wpe/SQRT(2d0)                 ;;  L_De [m]

results        = calc_1var_stats(lambda_De,/NAN,/PRINT)
;;
;;             Min. value of X  =         1.9611947
;;             Max. value of X  =         116.60464
;;             Avg. value of X  =         9.7656831
;;           Median value of X  =         9.5856905
;;     Standard Deviation of X  =         3.3008603
;;  Std. Dev. of the Mean of X  =      0.0036450637
;;               Skewness of X  =         1.1461755
;;               Kurtosis of X  =         7.3867263
;;         Lower Quartile of X  =         7.3484105
;;         Upper Quartile of X  =         11.793476
;;     Interquartile Mean of X  =         9.5800669
;;    Total # of Elements in X  =       2630161
;;   Finite # of Elements in X  =        820057
;;

;;  Calculate lowest order Lambda ~ 12π ne L_De^3
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
;;  Print stats (collisions per day)
;;----------------------------------------------------------------------------------------
line0          = ';;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
line1          = ';;========================================================================================'
line2          = ';;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #'
line3          = ';;======================================================================================================================================================================================'
mform          = '(a51,11e10.2,2I)'

;;  Print nuee_tot [# day^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuee_tot [# day^(-1)] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nuee_tot*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuee_tot [SWE, 3DP, ALL, # d^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuee_tot [SWE, 3DP, No Shocks, # d^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuee_tot [SWE, 3DP, Inside  MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuee_tot [SWE, 3DP, Outside MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuee_tot [SWE, 3DP, Fast SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuee_tot [SWE, 3DP, Slow SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nupp_tot [# day^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nupp_tot [# day^(-1)] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nupp_tot*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupp_tot [SWE, 3DP, ALL, # d^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupp_tot [SWE, 3DP, No Shocks, # d^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupp_tot [SWE, 3DP, Inside  MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupp_tot [SWE, 3DP, Outside MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupp_tot [SWE, 3DP, Fast SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupp_tot [SWE, 3DP, Slow SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuaa_tot [# day^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuaa_tot [# day^(-1)] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nuaa_tot*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuaa_tot [SWE, 3DP, ALL, # d^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuaa_tot [SWE, 3DP, No Shocks, # d^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuaa_tot [SWE, 3DP, Inside  MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuaa_tot [SWE, 3DP, Outside MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuaa_tot [SWE, 3DP, Fast SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuaa_tot [SWE, 3DP, Slow SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuep_tot [# day^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuep_tot [# day^(-1)] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nuep_tot*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuep_tot [SWE, 3DP, ALL, # d^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuep_tot [SWE, 3DP, No Shocks, # d^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuep_tot [SWE, 3DP, Inside  MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuep_tot [SWE, 3DP, Outside MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuep_tot [SWE, 3DP, Fast SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuep_tot [SWE, 3DP, Slow SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuea_tot [# day^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuea_tot [# day^(-1)] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nuea_tot*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuea_tot [SWE, 3DP, ALL, # d^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuea_tot [SWE, 3DP, No Shocks, # d^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuea_tot [SWE, 3DP, Inside  MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuea_tot [SWE, 3DP, Outside MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuea_tot [SWE, 3DP, Fast SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuea_tot [SWE, 3DP, Slow SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nupa_tot [# day^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nupa_tot [# day^(-1)] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nupa_tot*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupa_tot [SWE, 3DP, ALL, # d^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupa_tot [SWE, 3DP, No Shocks, # d^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupa_tot [SWE, 3DP, Inside  MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupa_tot [SWE, 3DP, Outside MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupa_tot [SWE, 3DP, Fast SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nupa_tot [SWE, 3DP, Slow SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuia_1mV [# day^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuia_1mV [# day^(-1)] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nuia_1mV*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV [SWE, 3DP, ALL, # d^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV [SWE, 3DP, No Shocks, # d^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV [SWE, 3DP, Inside  MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV [SWE, 3DP, Outside MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV [SWE, 3DP, Fast SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV [SWE, 3DP, Slow SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuia01mV [# day^(-1)] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuia01mV [# day^(-1)] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nuia01mV*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV [SWE, 3DP, ALL, # d^(-1)]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV [SWE, 3DP, No Shocks, # d^(-1)]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV [SWE, 3DP, Inside  MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV [SWE, 3DP, Outside MOs, # d^(-1)]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV [SWE, 3DP, Fast SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV [SWE, 3DP, Slow SW, # d^(-1)]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuee_tot [# day^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuee_tot [SWE, 3DP, ALL, # d^(-1)]        :    8.36e-04  1.05e+01  3.26e-01  2.13e-01  3.29e-01  3.63e-04  3.75e+00  2.68e+01  1.38e-01  3.93e-01  2.29e-01     2630161      820057
;;  nuee_tot [SWE, 3DP, No Shocks, # d^(-1)]  :    8.36e-04  1.05e+01  3.14e-01  2.08e-01  3.12e-01  3.58e-04  3.81e+00  2.82e+01  1.36e-01  3.75e-01  2.22e-01     2435510      760815
;;  nuee_tot [SWE, 3DP, Inside  MOs, # d^(-1)]:    8.36e-04  6.36e+00  4.38e-01  3.06e-01  4.23e-01  2.47e-03  3.09e+00  1.69e+01  1.69e-01  5.76e-01  3.28e-01      128109       29389
;;  nuee_tot [SWE, 3DP, Outside MOs, # d^(-1)]:    1.69e-03  1.05e+01  3.22e-01  2.11e-01  3.24e-01  3.64e-04  3.78e+00  2.74e+01  1.37e-01  3.86e-01  2.26e-01     2502052      790668
;;  nuee_tot [SWE, 3DP, Fast SW, # d^(-1)]    :    4.38e-03  5.45e+00  1.98e-01  1.41e-01  2.39e-01  9.69e-04  6.53e+00  6.35e+01  1.10e-01  1.92e-01  1.44e-01      194462       60700
;;  nuee_tot [SWE, 3DP, Slow SW, # d^(-1)]    :    4.00e-03  1.05e+01  4.38e-01  3.15e-01  3.90e-01  6.21e-04  3.22e+00  2.02e+01  1.89e-01  5.64e-01  3.35e-01      942027      394244
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nupp_tot [# day^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nupp_tot [SWE, 3DP, ALL, # d^(-1)]        :    4.75e-07  2.77e+00  2.22e-02  8.69e-03  3.67e-02  3.51e-05  7.48e+00  2.24e+02  2.54e-03  2.61e-02  1.04e-02     2630161     1095314
;;  nupp_tot [SWE, 3DP, No Shocks, # d^(-1)]  :    4.75e-07  2.77e+00  2.19e-02  8.39e-03  3.63e-02  3.63e-05  7.56e+00  2.35e+02  2.49e-03  2.57e-02  1.01e-02     2435510     1001957
;;  nupp_tot [SWE, 3DP, Inside  MOs, # d^(-1)]:    4.75e-07  2.34e+00  3.92e-02  2.00e-02  7.11e-02  2.64e-04  9.61e+00  1.83e+02  7.91e-03  4.38e-02  2.18e-02      128109       72530
;;  nupp_tot [SWE, 3DP, Outside MOs, # d^(-1)]:    7.42e-07  2.77e+00  2.10e-02  8.08e-03  3.26e-02  3.22e-05  3.94e+00  7.52e+01  2.41e-03  2.47e-02  9.72e-03     2502052     1022784
;;  nupp_tot [SWE, 3DP, Fast SW, # d^(-1)]    :    7.42e-07  1.09e+00  4.37e-03  9.03e-04  1.90e-02  4.60e-05  1.80e+01  5.32e+02  5.21e-04  1.67e-03  9.53e-04      194462      170001
;;  nupp_tot [SWE, 3DP, Slow SW, # d^(-1)]    :    4.75e-07  2.77e+00  2.54e-02  1.15e-02  3.82e-02  3.97e-05  7.27e+00  2.18e+02  4.21e-03  3.09e-02  1.34e-02      942027      925313
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuaa_tot [# day^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuaa_tot [SWE, 3DP, ALL, # d^(-1)]        :    1.19e-06  6.58e-01  4.83e-03  1.51e-03  1.11e-02  1.61e-05  9.64e+00  1.81e+02  4.03e-04  4.81e-03  1.86e-03     2630161      476255
;;  nuaa_tot [SWE, 3DP, No Shocks, # d^(-1)]  :    1.19e-06  6.58e-01  4.72e-03  1.50e-03  1.09e-02  1.67e-05  1.00e+01  1.95e+02  3.99e-04  4.73e-03  1.83e-03     2435510      428536
;;  nuaa_tot [SWE, 3DP, Inside  MOs, # d^(-1)]:    2.24e-06  6.58e-01  1.21e-02  3.95e-03  2.43e-02  1.17e-04  5.74e+00  5.47e+01  9.75e-04  1.29e-02  4.87e-03      128109       43343
;;  nuaa_tot [SWE, 3DP, Outside MOs, # d^(-1)]:    1.19e-06  3.79e-01  4.10e-03  1.39e-03  8.42e-03  1.28e-05  8.60e+00  1.63e+02  3.76e-04  4.36e-03  1.70e-03     2502052      432912
;;  nuaa_tot [SWE, 3DP, Fast SW, # d^(-1)]    :    1.19e-06  2.95e-01  3.97e-03  4.43e-04  1.23e-02  6.90e-05  8.48e+00  1.05e+02  1.02e-04  2.43e-03  6.84e-04      194462       31498
;;  nuaa_tot [SWE, 3DP, Slow SW, # d^(-1)]    :    1.41e-06  6.58e-01  4.89e-03  1.61e-03  1.10e-02  1.65e-05  9.75e+00  1.89e+02  4.40e-04  4.94e-03  1.95e-03      942027      444757
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuep_tot [# day^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuep_tot [SWE, 3DP, ALL, # d^(-1)]        :    3.61e-03  9.79e+00  3.91e-01  2.63e-01  3.74e-01  5.60e-04  3.35e+00  2.20e+01  1.57e-01  5.04e-01  2.86e-01     2630161      445801
;;  nuep_tot [SWE, 3DP, No Shocks, # d^(-1)]  :    4.58e-03  9.79e+00  3.77e-01  2.53e-01  3.59e-01  5.59e-04  3.39e+00  2.28e+01  1.54e-01  4.81e-01  2.75e-01     2435510      412947
;;  nuep_tot [SWE, 3DP, Inside  MOs, # d^(-1)]:    3.61e-03  7.85e+00  4.66e-01  3.10e-01  4.54e-01  3.36e-03  3.05e+00  1.64e+01  1.85e-01  6.11e-01  3.40e-01      128109       18203
;;  nuep_tot [SWE, 3DP, Outside MOs, # d^(-1)]:    4.58e-03  9.79e+00  3.88e-01  2.60e-01  3.70e-01  5.65e-04  3.35e+00  2.23e+01  1.56e-01  5.00e-01  2.83e-01     2502052      427598
;;  nuep_tot [SWE, 3DP, Fast SW, # d^(-1)]    :    3.61e-03  5.10e+00  1.86e-01  1.30e-01  2.31e-01  9.83e-04  6.41e+00  6.04e+01  1.00e-01  1.82e-01  1.34e-01      194462       55111
;;  nuep_tot [SWE, 3DP, Slow SW, # d^(-1)]    :    4.90e-03  9.79e+00  4.20e-01  2.96e-01  3.81e-01  6.09e-04  3.28e+00  2.16e+01  1.77e-01  5.43e-01  3.17e-01      942027      390690
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuea_tot [# day^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuea_tot [SWE, 3DP, ALL, # d^(-1)]        :    2.09e-03  4.48e+00  6.04e-02  3.78e-02  8.29e-02  1.88e-04  7.83e+00  1.31e+02  2.40e-02  6.55e-02  3.99e-02     2630161      193704
;;  nuea_tot [SWE, 3DP, No Shocks, # d^(-1)]  :    2.09e-03  4.48e+00  5.78e-02  3.68e-02  8.03e-02  1.91e-04  8.53e+00  1.55e+02  2.35e-02  6.22e-02  3.86e-02     2435510      177265
;;  nuea_tot [SWE, 3DP, Inside  MOs, # d^(-1)]:    3.50e-03  2.19e+00  9.14e-02  5.31e-02  1.34e-01  1.33e-03  5.71e+00  5.15e+01  3.04e-02  9.40e-02  5.58e-02      128109       10077
;;  nuea_tot [SWE, 3DP, Outside MOs, # d^(-1)]:    2.09e-03  4.48e+00  5.87e-02  3.73e-02  7.88e-02  1.84e-04  7.96e+00  1.44e+02  2.38e-02  6.39e-02  3.93e-02     2502052      183627
;;  nuea_tot [SWE, 3DP, Fast SW, # d^(-1)]    :    3.59e-03  1.51e+00  8.77e-02  4.20e-02  1.18e-01  1.24e-03  3.86e+00  2.34e+01  2.73e-02  9.46e-02  4.83e-02      194462        9002
;;  nuea_tot [SWE, 3DP, Slow SW, # d^(-1)]    :    2.09e-03  4.48e+00  5.91e-02  3.77e-02  8.06e-02  1.87e-04  8.30e+00  1.49e+02  2.38e-02  6.45e-02  3.97e-02      942027      184702
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nupa_tot [# day^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nupa_tot [SWE, 3DP, ALL, # d^(-1)]        :    2.44e-06  2.68e-01  2.89e-03  1.26e-03  6.37e-03  9.23e-06  1.20e+01  2.55e+02  5.57e-04  2.89e-03  1.40e-03     2630161      476255
;;  nupa_tot [SWE, 3DP, No Shocks, # d^(-1)]  :    2.44e-06  2.68e-01  2.80e-03  1.24e-03  6.20e-03  9.48e-06  1.26e+01  2.82e+02  5.50e-04  2.81e-03  1.37e-03     2435510      428536
;;  nupa_tot [SWE, 3DP, Inside  MOs, # d^(-1)]:    4.93e-06  2.68e-01  7.61e-03  2.88e-03  1.54e-02  7.41e-05  6.36e+00  5.95e+01  1.07e-03  7.58e-03  3.32e-03      128109       43343
;;  nupa_tot [SWE, 3DP, Outside MOs, # d^(-1)]:    2.44e-06  1.92e-01  2.42e-03  1.18e-03  4.28e-03  6.51e-06  9.49e+00  1.97e+02  5.31e-04  2.62e-03  1.30e-03     2502052      432912
;;  nupa_tot [SWE, 3DP, Fast SW, # d^(-1)]    :    2.72e-06  2.11e-01  3.03e-03  6.01e-04  8.93e-03  5.03e-05  9.30e+00  1.24e+02  1.59e-04  2.21e-03  7.72e-04      194462       31498
;;  nupa_tot [SWE, 3DP, Slow SW, # d^(-1)]    :    2.44e-06  2.68e-01  2.88e-03  1.30e-03  6.15e-03  9.22e-06  1.23e+01  2.76e+02  5.91e-04  2.92e-03  1.44e-03      942027      444757
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuia_1mV [# day^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia_1mV [SWE, 3DP, ALL, # d^(-1)]        :    5.72e+02  2.92e+04  4.39e+03  4.16e+03  1.55e+03  1.71e+00  1.05e+00  2.59e+00  3.30e+03  5.25e+03  4.20e+03     2630161      820057
;;  nuia_1mV [SWE, 3DP, No Shocks, # d^(-1)]  :    5.72e+02  1.93e+04  4.45e+03  4.22e+03  1.52e+03  1.74e+00  1.02e+00  2.09e+00  3.36e+03  5.29e+03  4.25e+03     2435510      760815
;;  nuia_1mV [SWE, 3DP, Inside  MOs, # d^(-1)]:    7.58e+02  2.92e+04  4.93e+03  4.58e+03  2.09e+03  1.22e+01  1.86e+00  6.56e+00  3.49e+03  5.82e+03  4.59e+03      128109       29389
;;  nuia_1mV [SWE, 3DP, Outside MOs, # d^(-1)]:    5.72e+02  2.21e+04  4.37e+03  4.15e+03  1.52e+03  1.71e+00  9.37e-01  1.71e+00  3.29e+03  5.23e+03  4.18e+03     2502052      790668
;;  nuia_1mV [SWE, 3DP, Fast SW, # d^(-1)]    :    7.62e+02  1.92e+04  5.37e+03  5.29e+03  1.73e+03  7.01e+00  3.82e-01  5.42e-01  4.18e+03  6.45e+03  5.29e+03      194462       60700
;;  nuia_1mV [SWE, 3DP, Slow SW, # d^(-1)]    :    5.72e+02  2.92e+04  4.24e+03  4.04e+03  1.43e+03  2.28e+00  1.25e+00  4.18e+00  3.24e+03  5.01e+03  4.06e+03      942027      394244
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuia01mV [# day^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV [SWE, 3DP, ALL, # d^(-1)]        :    5.72e+00  2.92e+02  4.39e+01  4.16e+01  1.55e+01  1.71e-02  1.05e+00  2.59e+00  3.30e+01  5.25e+01  4.20e+01     2630161      820057
;;  nuia01mV [SWE, 3DP, No Shocks, # d^(-1)]  :    5.72e+00  1.93e+02  4.45e+01  4.22e+01  1.52e+01  1.74e-02  1.02e+00  2.09e+00  3.36e+01  5.29e+01  4.25e+01     2435510      760815
;;  nuia01mV [SWE, 3DP, Inside  MOs, # d^(-1)]:    7.58e+00  2.92e+02  4.93e+01  4.58e+01  2.09e+01  1.22e-01  1.86e+00  6.56e+00  3.49e+01  5.82e+01  4.59e+01      128109       29389
;;  nuia01mV [SWE, 3DP, Outside MOs, # d^(-1)]:    5.72e+00  2.21e+02  4.37e+01  4.15e+01  1.52e+01  1.71e-02  9.37e-01  1.71e+00  3.29e+01  5.23e+01  4.18e+01     2502052      790668
;;  nuia01mV [SWE, 3DP, Fast SW, # d^(-1)]    :    7.62e+00  1.92e+02  5.37e+01  5.29e+01  1.73e+01  7.01e-02  3.82e-01  5.42e-01  4.18e+01  6.45e+01  5.29e+01      194462       60700
;;  nuia01mV [SWE, 3DP, Slow SW, # d^(-1)]    :    5.72e+00  2.92e+02  4.24e+01  4.04e+01  1.43e+01  2.28e-02  1.25e+00  4.18e+00  3.24e+01  5.01e+01  4.06e+01      942027      394244
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



;;----------------------------------------------------------------------------------------
;;  Print stats (days per collision)
;;----------------------------------------------------------------------------------------
line0          = ';;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
line1          = ';;========================================================================================'
line2          = ';;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #'
line3          = ';;======================================================================================================================================================================================'
mform          = '(a51,11e10.2,2I)'

;;  Print nuee_tot [days/coll.] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuee_tot [days/coll.] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nuee_tot*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuee_tot [SWE, 3DP, ALL, day/coll]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuee_tot [SWE, 3DP, No Shocks, day/coll]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuee_tot [SWE, 3DP, Inside  MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuee_tot [SWE, 3DP, Outside MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuee_tot [SWE, 3DP, Fast SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuee_tot [SWE, 3DP, Slow SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nupp_tot [days/coll.] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nupp_tot [days/coll.] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nupp_tot*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nupp_tot [SWE, 3DP, ALL, day/coll]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nupp_tot [SWE, 3DP, No Shocks, day/coll]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nupp_tot [SWE, 3DP, Inside  MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nupp_tot [SWE, 3DP, Outside MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nupp_tot [SWE, 3DP, Fast SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nupp_tot [SWE, 3DP, Slow SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuaa_tot [days/coll.] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuaa_tot [days/coll.] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nuaa_tot*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuaa_tot [SWE, 3DP, ALL, day/coll]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuaa_tot [SWE, 3DP, No Shocks, day/coll]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuaa_tot [SWE, 3DP, Inside  MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuaa_tot [SWE, 3DP, Outside MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuaa_tot [SWE, 3DP, Fast SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuaa_tot [SWE, 3DP, Slow SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuep_tot [days/coll.] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuep_tot [days/coll.] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nuep_tot*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuep_tot [SWE, 3DP, ALL, day/coll]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuep_tot [SWE, 3DP, No Shocks, day/coll]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuep_tot [SWE, 3DP, Inside  MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuep_tot [SWE, 3DP, Outside MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuep_tot [SWE, 3DP, Fast SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuep_tot [SWE, 3DP, Slow SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuea_tot [days/coll.] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuea_tot [days/coll.] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nuea_tot*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuea_tot [SWE, 3DP, ALL, day/coll]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuea_tot [SWE, 3DP, No Shocks, day/coll]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuea_tot [SWE, 3DP, Inside  MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuea_tot [SWE, 3DP, Outside MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuea_tot [SWE, 3DP, Fast SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuea_tot [SWE, 3DP, Slow SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nupa_tot [days/coll.] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nupa_tot [days/coll.] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nupa_tot*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nupa_tot [SWE, 3DP, ALL, day/coll]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nupa_tot [SWE, 3DP, No Shocks, day/coll]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nupa_tot [SWE, 3DP, Inside  MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nupa_tot [SWE, 3DP, Outside MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nupa_tot [SWE, 3DP, Fast SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nupa_tot [SWE, 3DP, Slow SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuia_1mV [days/coll.] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuia_1mV [days/coll.] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nuia_1mV*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuia_1mV [SWE, 3DP, ALL, day/coll]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuia_1mV [SWE, 3DP, No Shocks, day/coll]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuia_1mV [SWE, 3DP, Inside  MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuia_1mV [SWE, 3DP, Outside MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuia_1mV [SWE, 3DP, Fast SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuia_1mV [SWE, 3DP, Slow SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;  Print nuia01mV [days/coll.] [Only good SWE and only good 3DP times]
PRINT,line0[0]                                                                                                              & $
PRINT,';;  nuia01mV [days/coll.] Stats'                                                                                     & $
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x_alldat       = nuia01mV*864d2                                                                                             & $
x              = x_alldat                                                                                                   & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuia01mV [SWE, 3DP, ALL, day/coll]        :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_ip_shock]                                                                                     & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuia01mV [SWE, 3DP, No Shocks, day/coll]  :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[in__mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuia01mV [SWE, 3DP, Inside  MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[out_mo_all]                                                                                       & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuia01mV [SWE, 3DP, Outside MOs, day/coll]:  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_fast_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuia01mV [SWE, 3DP, Fast SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
x              = x_alldat[good_slow_swe]                                                                                    & $
stats          = calc_1var_stats(1d0/x,/NAN)                                                                                & $
PRINT,';;  nuia01mV [SWE, 3DP, Slow SW, day/coll]    :  ',stats,FORMAT=mform[0]                                             & $
PRINT,';;'

;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuee_tot [days/coll.] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuee_tot [SWE, 3DP, ALL, day/coll]        :    9.53e-02  1.20e+03  5.60e+00  4.69e+00  5.55e+00  6.13e-03  2.93e+01  3.97e+03  2.54e+00  7.26e+00  4.76e+00     2630161      820057
;;  nuee_tot [SWE, 3DP, No Shocks, day/coll]  :    9.53e-02  1.20e+03  5.66e+00  4.81e+00  5.31e+00  6.09e-03  2.56e+01  3.77e+03  2.67e+00  7.34e+00  4.87e+00     2435510      760815
;;  nuee_tot [SWE, 3DP, Inside  MOs, day/coll]:    1.57e-01  1.20e+03  5.33e+00  3.27e+00  1.29e+01  7.53e-02  4.62e+01  3.48e+03  1.73e+00  5.93e+00  3.43e+00      128109       29389
;;  nuee_tot [SWE, 3DP, Outside MOs, day/coll]:    9.53e-02  5.91e+02  5.61e+00  4.74e+00  5.08e+00  5.71e-03  1.15e+01  4.92e+02  2.59e+00  7.30e+00  4.80e+00     2502052      790668
;;  nuee_tot [SWE, 3DP, Fast SW, day/coll]    :    1.83e-01  2.28e+02  7.74e+00  7.08e+00  5.69e+00  2.31e-02  1.02e+01  2.30e+02  5.20e+00  9.09e+00  7.10e+00      194462       60700
;;  nuee_tot [SWE, 3DP, Slow SW, day/coll]    :    9.53e-02  2.50e+02  3.94e+00  3.18e+00  3.12e+00  4.97e-03  6.30e+00  2.63e+02  1.77e+00  5.28e+00  3.30e+00      942027      394244
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nupp_tot [days/coll.] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nupp_tot [SWE, 3DP, ALL, day/coll]        :    3.61e-01  2.10e+06  4.87e+02  1.15e+02  3.67e+03  3.51e+00  2.53e+02  1.19e+05  3.83e+01  3.94e+02  1.46e+02     2630161     1095314
;;  nupp_tot [SWE, 3DP, No Shocks, day/coll]  :    3.61e-01  2.10e+06  4.87e+02  1.19e+02  3.74e+03  3.73e+00  2.59e+02  1.21e+05  3.90e+01  4.02e+02  1.50e+02     2435510     1001957
;;  nupp_tot [SWE, 3DP, Inside  MOs, day/coll]:    4.27e-01  2.10e+06  4.08e+02  4.99e+01  8.27e+03  3.07e+01  2.28e+02  5.77e+04  2.29e+01  1.26e+02  5.73e+01      128109       72530
;;  nupp_tot [SWE, 3DP, Outside MOs, day/coll]:    3.61e-01  1.35e+06  4.92e+02  1.24e+02  3.09e+03  3.06e+00  1.44e+02  4.40e+04  4.04e+01  4.16e+02  1.56e+02     2502052     1022784
;;  nupp_tot [SWE, 3DP, Fast SW, day/coll]    :    9.19e-01  1.35e+06  1.84e+03  1.11e+03  6.46e+03  1.57e+01  8.06e+01  1.30e+04  5.98e+02  1.92e+03  1.15e+03      194462      170001
;;  nupp_tot [SWE, 3DP, Slow SW, day/coll]    :    3.61e-01  2.10e+06  2.39e+02  8.71e+01  2.81e+03  2.92e+00  4.88e+02  3.46e+05  3.23e+01  2.38e+02  1.01e+02      942027      925313
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuaa_tot [days/coll.] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuaa_tot [SWE, 3DP, ALL, day/coll]        :    1.52e+00  8.37e+05  2.24e+03  6.61e+02  5.04e+03  7.30e+00  3.47e+01  3.70e+03  2.08e+02  2.48e+03  8.75e+02     2630161      476255
;;  nuaa_tot [SWE, 3DP, No Shocks, day/coll]  :    1.52e+00  8.37e+05  2.24e+03  6.67e+02  5.07e+03  7.75e+00  3.70e+01  3.99e+03  2.11e+02  2.51e+03  8.85e+02     2435510      428536
;;  nuaa_tot [SWE, 3DP, Inside  MOs, day/coll]:    1.52e+00  4.46e+05  1.19e+03  2.53e+02  4.19e+03  2.01e+01  4.71e+01  4.05e+03  7.74e+01  1.03e+03  3.47e+02      128109       43343
;;  nuaa_tot [SWE, 3DP, Outside MOs, day/coll]:    2.64e+00  8.37e+05  2.34e+03  7.19e+02  5.10e+03  7.76e+00  3.41e+01  3.68e+03  2.30e+02  2.66e+03  9.48e+02     2502052      432912
;;  nuaa_tot [SWE, 3DP, Fast SW, day/coll]    :    3.39e+00  8.37e+05  6.83e+03  2.26e+03  1.37e+04  7.73e+01  1.75e+01  7.03e+02  4.13e+02  9.83e+03  3.20e+03      194462       31498
;;  nuaa_tot [SWE, 3DP, Slow SW, day/coll]    :    1.52e+00  7.08e+05  1.91e+03  6.21e+02  3.50e+03  5.25e+00  3.23e+01  4.82e+03  2.02e+02  2.27e+03  8.13e+02      942027      444757
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuep_tot [days/coll.] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuep_tot [SWE, 3DP, ALL, day/coll]        :    1.02e-01  2.77e+02  4.72e+00  3.81e+00  4.06e+00  6.08e-03  6.52e+00  1.84e+02  1.99e+00  6.38e+00  3.92e+00     2630161      445801
;;  nuep_tot [SWE, 3DP, No Shocks, day/coll]  :    1.02e-01  2.18e+02  4.81e+00  3.96e+00  3.99e+00  6.21e-03  6.09e+00  1.54e+02  2.08e+00  6.49e+00  4.05e+00     2435510      412947
;;  nuep_tot [SWE, 3DP, Inside  MOs, day/coll]:    1.27e-01  2.77e+02  4.47e+00  3.23e+00  5.53e+00  4.10e-02  1.13e+01  3.75e+02  1.64e+00  5.40e+00  3.28e+00      128109       18203
;;  nuep_tot [SWE, 3DP, Outside MOs, day/coll]:    1.02e-01  2.18e+02  4.74e+00  3.84e+00  3.98e+00  6.09e-03  5.91e+00  1.47e+02  2.00e+00  6.42e+00  3.95e+00     2502052      427598
;;  nuep_tot [SWE, 3DP, Fast SW, day/coll]    :    1.96e-01  2.77e+02  8.45e+00  7.67e+00  6.03e+00  2.57e-02  8.69e+00  2.05e+02  5.51e+00  9.98e+00  7.68e+00      194462       55111
;;  nuep_tot [SWE, 3DP, Slow SW, day/coll]    :    1.02e-01  2.04e+02  4.20e+00  3.38e+00  3.38e+00  5.41e-03  4.69e+00  1.11e+02  1.84e+00  5.66e+00  3.50e+00      942027      390690
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuea_tot [days/coll.] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuea_tot [SWE, 3DP, ALL, day/coll]        :    2.23e-01  4.78e+02  3.28e+01  2.64e+01  2.67e+01  6.06e-02  2.49e+00  1.13e+01  1.53e+01  4.17e+01  2.70e+01     2630161      193704
;;  nuea_tot [SWE, 3DP, No Shocks, day/coll]  :    2.23e-01  4.78e+02  3.36e+01  2.72e+01  2.70e+01  6.42e-02  2.50e+00  1.13e+01  1.61e+01  4.25e+01  2.78e+01     2435510      177265
;;  nuea_tot [SWE, 3DP, Inside  MOs, day/coll]:    4.57e-01  2.86e+02  2.64e+01  1.88e+01  2.70e+01  2.69e-01  3.23e+00  1.56e+01  1.06e+01  3.29e+01  1.97e+01      128109       10077
;;  nuea_tot [SWE, 3DP, Outside MOs, day/coll]:    2.23e-01  4.78e+02  3.31e+01  2.68e+01  2.66e+01  6.21e-02  2.46e+00  1.11e+01  1.56e+01  4.21e+01  2.74e+01     2502052      183627
;;  nuea_tot [SWE, 3DP, Fast SW, day/coll]    :    6.64e-01  2.78e+02  2.76e+01  2.38e+01  2.39e+01  2.52e-01  2.55e+00  1.22e+01  1.06e+01  3.66e+01  2.34e+01      194462        9002
;;  nuea_tot [SWE, 3DP, Slow SW, day/coll]    :    2.23e-01  4.78e+02  3.30e+01  2.66e+01  2.68e+01  6.23e-02  2.49e+00  1.12e+01  1.55e+01  4.20e+01  2.72e+01      942027      184702
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nupa_tot [days/coll.] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nupa_tot [SWE, 3DP, ALL, day/coll]        :    3.74e+00  4.10e+05  1.55e+03  7.94e+02  2.80e+03  4.05e+00  3.11e+01  2.90e+03  3.47e+02  1.80e+03  8.80e+02     2630161      476255
;;  nupa_tot [SWE, 3DP, No Shocks, day/coll]  :    3.74e+00  4.10e+05  1.55e+03  8.08e+02  2.77e+03  4.24e+00  3.33e+01  3.23e+03  3.56e+02  1.82e+03  8.95e+02     2435510      428536
;;  nupa_tot [SWE, 3DP, Inside  MOs, day/coll]:    3.74e+00  2.03e+05  8.67e+02  3.47e+02  2.39e+03  1.15e+01  3.78e+01  2.53e+03  1.32e+02  9.37e+02  4.06e+02      128109       43343
;;  nupa_tot [SWE, 3DP, Outside MOs, day/coll]:    5.22e+00  4.10e+05  1.61e+03  8.45e+02  2.83e+03  4.29e+00  3.09e+01  2.93e+03  3.82e+02  1.88e+03  9.35e+02     2502052      432912
;;  nupa_tot [SWE, 3DP, Fast SW, day/coll]    :    4.73e+00  3.68e+05  4.28e+03  1.66e+03  7.72e+03  4.35e+01  1.40e+01  4.36e+02  4.53e+02  6.30e+03  2.26e+03      194462       31498
;;  nupa_tot [SWE, 3DP, Slow SW, day/coll]    :    3.74e+00  4.10e+05  1.35e+03  7.69e+02  1.89e+03  2.84e+00  3.49e+01  5.78e+03  3.43e+02  1.69e+03  8.47e+02      942027      444757
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuia_1mV [days/coll.] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia_1mV [SWE, 3DP, ALL, day/coll]        :    3.42e-05  1.75e-03  2.57e-04  2.40e-04  9.84e-05  1.09e-07  1.86e+00  7.97e+00  1.91e-04  3.03e-04  2.42e-04     2630161      820057
;;  nuia_1mV [SWE, 3DP, No Shocks, day/coll]  :    5.18e-05  1.75e-03  2.52e-04  2.37e-04  8.97e-05  1.03e-07  1.44e+00  4.76e+00  1.89e-04  2.97e-04  2.39e-04     2435510      760815
;;  nuia_1mV [SWE, 3DP, Inside  MOs, day/coll]:    3.42e-05  1.32e-03  2.36e-04  2.18e-04  9.52e-05  5.55e-07  1.49e+00  4.63e+00  1.72e-04  2.87e-04  2.22e-04      128109       29389
;;  nuia_1mV [SWE, 3DP, Outside MOs, day/coll]:    4.53e-05  1.75e-03  2.58e-04  2.41e-04  9.84e-05  1.11e-07  1.88e+00  8.09e+00  1.91e-04  3.04e-04  2.43e-04     2502052      790668
;;  nuia_1mV [SWE, 3DP, Fast SW, day/coll]    :    5.20e-05  1.31e-03  2.11e-04  1.89e-04  9.20e-05  3.73e-07  2.89e+00  1.49e+01  1.55e-04  2.39e-04  1.92e-04      194462       60700
;;  nuia_1mV [SWE, 3DP, Slow SW, day/coll]    :    3.42e-05  1.75e-03  2.63e-04  2.48e-04  9.14e-05  1.46e-07  1.46e+00  5.00e+00  2.00e-04  3.09e-04  2.50e-04      942027      394244
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuia01mV [days/coll.] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV [SWE, 3DP, ALL, day/coll]        :    3.42e-03  1.75e-01  2.57e-02  2.40e-02  9.84e-03  1.09e-05  1.86e+00  7.97e+00  1.91e-02  3.03e-02  2.42e-02     2630161      820057
;;  nuia01mV [SWE, 3DP, No Shocks, day/coll]  :    5.18e-03  1.75e-01  2.52e-02  2.37e-02  8.97e-03  1.03e-05  1.44e+00  4.76e+00  1.89e-02  2.97e-02  2.39e-02     2435510      760815
;;  nuia01mV [SWE, 3DP, Inside  MOs, day/coll]:    3.42e-03  1.32e-01  2.36e-02  2.18e-02  9.52e-03  5.55e-05  1.49e+00  4.63e+00  1.72e-02  2.87e-02  2.22e-02      128109       29389
;;  nuia01mV [SWE, 3DP, Outside MOs, day/coll]:    4.53e-03  1.75e-01  2.58e-02  2.41e-02  9.84e-03  1.11e-05  1.88e+00  8.09e+00  1.91e-02  3.04e-02  2.43e-02     2502052      790668
;;  nuia01mV [SWE, 3DP, Fast SW, day/coll]    :    5.20e-03  1.31e-01  2.11e-02  1.89e-02  9.20e-03  3.73e-05  2.89e+00  1.49e+01  1.55e-02  2.39e-02  1.92e-02      194462       60700
;;  nuia01mV [SWE, 3DP, Slow SW, day/coll]    :    3.42e-03  1.75e-01  2.63e-02  2.48e-02  9.14e-03  1.46e-05  1.46e+00  5.00e+00  2.00e-02  3.09e-02  2.50e-02      942027      394244
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


;;----------------------------------------------------------------------------------------
;;  Print ratio stats
;;----------------------------------------------------------------------------------------
line0          = ';;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
line1          = ';;========================================================================================'
line2          = ';;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #'
line3          = ';;======================================================================================================================================================================================'
mform          = '(a51,11e10.2,2I)'
;;  R0 = 100% occurrence rate of IAWs
frate_iaw      = 0.124d0                    ;;  R1 = IAWs occur at a rate of ~12.4% assuming they occur when (Te/Tp)_tot ≥ 3
frate__cs      = 942d0/864d2                ;;  R2 = Occurrence rate of current sheets ~ 1.1%
frate_net      = frate__cs[0]*frate_iaw[0]  ;;  R3 = Net IAW occurrence rate ~ 0.14%

y              = nuia_1mV
str___suffix   = '[SWE, 3DP, ALL, R0]'

y              = nuia_1mV*frate_iaw[0]
str___suffix   = '[SWE, 3DP, ALL, R1]'

y              = nuia_1mV*frate__cs[0]
str___suffix   = '[SWE, 3DP, ALL, R2]'

y              = nuia_1mV*frate_net[0]
str___suffix   = '[SWE, 3DP, ALL, R3]'
;;  Print nuia_1mV/nuee_tot [Only good SWE and only good 3DP times, R0, ∂E ~ 1.0 mV/m]
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = y/nuee_tot                                                                                                 & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV/nuee_tot '+str___suffix[0]+'    :  ',stats,FORMAT=mform[0]                                              & $
x              = y/nupp_tot                                                                                                 & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV/nupp_tot '+str___suffix[0]+'    :  ',stats,FORMAT=mform[0]                                              & $
x              = y/nuaa_tot                                                                                                 & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV/nuaa_tot '+str___suffix[0]+'    :  ',stats,FORMAT=mform[0]                                              & $
x              = y/nuep_tot                                                                                                 & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV/nuep_tot '+str___suffix[0]+'    :  ',stats,FORMAT=mform[0]                                              & $
x              = y/nuea_tot                                                                                                 & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV/nuea_tot '+str___suffix[0]+'    :  ',stats,FORMAT=mform[0]                                              & $
x              = y/nupa_tot                                                                                                 & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia_1mV/nupa_tot '+str___suffix[0]+'    :  ',stats,FORMAT=mform[0]                                              & $
PRINT,';;'
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia_1mV/nuee_tot [SWE, 3DP, ALL, R0]    :    2.67e+02  1.44e+07  2.62e+04  1.85e+04  3.60e+04  3.98e+01  8.99e+01  3.14e+04  9.38e+03  3.45e+04  1.96e+04     2630161      820057
;;  nuia_1mV/nupp_tot [SWE, 3DP, ALL, R0]    :    3.38e+03  8.96e+08  1.59e+06  4.37e+05  4.21e+06  6.30e+03  3.50e+01  5.22e+03  1.42e+05  1.43e+06  5.42e+05     2630161      445801
;;  nuia_1mV/nuaa_tot [SWE, 3DP, ALL, R0]    :    1.05e+04  2.53e+09  1.00e+07  3.09e+06  2.03e+07  4.62e+04  2.11e+01  1.72e+03  9.61e+05  1.13e+07  4.03e+06     2630161      193704
;;  nuia_1mV/nuep_tot [SWE, 3DP, ALL, R0]    :    3.93e+02  2.11e+06  2.17e+04  1.52e+04  2.34e+04  3.50e+01  9.12e+00  3.35e+02  7.52e+03  2.89e+04  1.61e+04     2630161      445801
;;  nuia_1mV/nuea_tot [SWE, 3DP, ALL, R0]    :    1.06e+03  2.49e+06  1.31e+05  1.03e+05  1.12e+05  2.54e+02  2.75e+00  1.65e+01  5.62e+04  1.72e+05  1.06e+05     2630161      193704
;;  nuia_1mV/nupa_tot [SWE, 3DP, ALL, R0]    :    2.36e+04  1.37e+09  6.87e+06  3.50e+06  1.12e+07  2.55e+04  1.92e+01  1.52e+03  1.52e+06  8.00e+06  3.89e+06     2630161      193704
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia_1mV/nuee_tot [SWE, 3DP, ALL, R1]    :    3.31e+01  1.78e+06  3.25e+03  2.29e+03  4.47e+03  4.93e+00  8.99e+01  3.14e+04  1.16e+03  4.28e+03  2.43e+03     2630161      820057
;;  nuia_1mV/nupp_tot [SWE, 3DP, ALL, R1]    :    4.19e+02  1.11e+08  1.97e+05  5.42e+04  5.22e+05  7.81e+02  3.50e+01  5.22e+03  1.77e+04  1.78e+05  6.72e+04     2630161      445801
;;  nuia_1mV/nuaa_tot [SWE, 3DP, ALL, R1]    :    1.30e+03  3.14e+08  1.24e+06  3.83e+05  2.52e+06  5.73e+03  2.11e+01  1.72e+03  1.19e+05  1.40e+06  5.00e+05     2630161      193704
;;  nuia_1mV/nuep_tot [SWE, 3DP, ALL, R1]    :    4.87e+01  2.62e+05  2.70e+03  1.89e+03  2.90e+03  4.34e+00  9.12e+00  3.35e+02  9.32e+02  3.58e+03  2.00e+03     2630161      445801
;;  nuia_1mV/nuea_tot [SWE, 3DP, ALL, R1]    :    1.32e+02  3.09e+05  1.62e+04  1.27e+04  1.38e+04  3.15e+01  2.75e+00  1.65e+01  6.97e+03  2.13e+04  1.32e+04     2630161      193704
;;  nuia_1mV/nupa_tot [SWE, 3DP, ALL, R1]    :    2.92e+03  1.70e+08  8.52e+05  4.34e+05  1.39e+06  3.16e+03  1.92e+01  1.52e+03  1.89e+05  9.92e+05  4.83e+05     2630161      193704
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia_1mV/nuee_tot [SWE, 3DP, ALL, R2]    :    2.91e+00  1.57e+05  2.86e+02  2.02e+02  3.93e+02  4.34e-01  8.99e+01  3.14e+04  1.02e+02  3.76e+02  2.14e+02     2630161      820057
;;  nuia_1mV/nupp_tot [SWE, 3DP, ALL, R2]    :    3.69e+01  9.77e+06  1.73e+04  4.76e+03  4.59e+04  6.87e+01  3.50e+01  5.22e+03  1.55e+03  1.56e+04  5.91e+03     2630161      445801
;;  nuia_1mV/nuaa_tot [SWE, 3DP, ALL, R2]    :    1.14e+02  2.76e+07  1.09e+05  3.37e+04  2.22e+05  5.04e+02  2.11e+01  1.72e+03  1.05e+04  1.23e+05  4.40e+04     2630161      193704
;;  nuia_1mV/nuep_tot [SWE, 3DP, ALL, R2]    :    4.28e+00  2.30e+04  2.37e+02  1.66e+02  2.55e+02  3.82e-01  9.12e+00  3.35e+02  8.20e+01  3.15e+02  1.76e+02     2630161      445801
;;  nuia_1mV/nuea_tot [SWE, 3DP, ALL, R2]    :    1.16e+01  2.72e+04  1.43e+03  1.12e+03  1.22e+03  2.77e+00  2.75e+00  1.65e+01  6.13e+02  1.87e+03  1.16e+03     2630161      193704
;;  nuia_1mV/nupa_tot [SWE, 3DP, ALL, R2]    :    2.57e+02  1.49e+07  7.49e+04  3.82e+04  1.22e+05  2.78e+02  1.92e+01  1.52e+03  1.66e+04  8.73e+04  4.24e+04     2630161      193704
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia_1mV/nuee_tot [SWE, 3DP, ALL, R3]    :    3.61e-01  1.94e+04  3.55e+01  2.50e+01  4.87e+01  5.38e-02  8.99e+01  3.14e+04  1.27e+01  4.67e+01  2.65e+01     2630161      820057
;;  nuia_1mV/nupp_tot [SWE, 3DP, ALL, R3]    :    4.57e+00  1.21e+06  2.14e+03  5.91e+02  5.69e+03  8.52e+00  3.50e+01  5.22e+03  1.93e+02  1.94e+03  7.32e+02     2630161      445801
;;  nuia_1mV/nuaa_tot [SWE, 3DP, ALL, R3]    :    1.42e+01  3.42e+06  1.36e+04  4.17e+03  2.75e+04  6.24e+01  2.11e+01  1.72e+03  1.30e+03  1.52e+04  5.45e+03     2630161      193704
;;  nuia_1mV/nuep_tot [SWE, 3DP, ALL, R3]    :    5.31e-01  2.85e+03  2.94e+01  2.06e+01  3.16e+01  4.74e-02  9.12e+00  3.35e+02  1.02e+01  3.90e+01  2.18e+01     2630161      445801
;;  nuia_1mV/nuea_tot [SWE, 3DP, ALL, R3]    :    1.44e+00  3.37e+03  1.77e+02  1.39e+02  1.51e+02  3.43e-01  2.75e+00  1.65e+01  7.60e+01  2.32e+02  1.44e+02     2630161      193704
;;  nuia_1mV/nupa_tot [SWE, 3DP, ALL, R3]    :    3.18e+01  1.85e+06  9.29e+03  4.73e+03  1.52e+04  3.44e+01  1.92e+01  1.52e+03  2.06e+03  1.08e+04  5.26e+03     2630161      193704
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


y              = nuia01mV
str___suffix   = '[SWE, 3DP, ALL, R0]'

y              = nuia01mV*frate_iaw[0]
str___suffix   = '[SWE, 3DP, ALL, R1]'

y              = nuia01mV*frate__cs[0]
str___suffix   = '[SWE, 3DP, ALL, R2]'

y              = nuia01mV*frate_net[0]
str___suffix   = '[SWE, 3DP, ALL, R3]'
;;  Print nuia01mV/nuee_tot [Only good SWE and only good 3DP times, R0, ∂E ~ 0.1 mV/m]
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
x              = y/nuee_tot                                                                                                 & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV/nuee_tot '+str___suffix[0]+'    :  ',stats,FORMAT=mform[0]                                              & $
x              = y/nupp_tot                                                                                                 & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV/nupp_tot '+str___suffix[0]+'    :  ',stats,FORMAT=mform[0]                                              & $
x              = y/nuaa_tot                                                                                                 & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV/nuaa_tot '+str___suffix[0]+'    :  ',stats,FORMAT=mform[0]                                              & $
x              = y/nuep_tot                                                                                                 & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV/nuep_tot '+str___suffix[0]+'    :  ',stats,FORMAT=mform[0]                                              & $
x              = y/nuea_tot                                                                                                 & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV/nuea_tot '+str___suffix[0]+'    :  ',stats,FORMAT=mform[0]                                              & $
x              = y/nupa_tot                                                                                                 & $
stats          = calc_1var_stats(x,/NAN)                                                                                    & $
PRINT,';;  nuia01mV/nupa_tot '+str___suffix[0]+'    :  ',stats,FORMAT=mform[0]                                              & $
PRINT,';;'
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV/nuee_tot [SWE, 3DP, ALL, R0]    :    2.67e+00  1.44e+05  2.62e+02  1.85e+02  3.60e+02  3.98e-01  8.99e+01  3.14e+04  9.38e+01  3.45e+02  1.96e+02     2630161      820057
;;  nuia01mV/nupp_tot [SWE, 3DP, ALL, R0]    :    3.38e+01  8.96e+06  1.59e+04  4.37e+03  4.21e+04  6.30e+01  3.50e+01  5.22e+03  1.42e+03  1.43e+04  5.42e+03     2630161      445801
;;  nuia01mV/nuaa_tot [SWE, 3DP, ALL, R0]    :    1.05e+02  2.53e+07  1.00e+05  3.09e+04  2.03e+05  4.62e+02  2.11e+01  1.72e+03  9.61e+03  1.13e+05  4.03e+04     2630161      193704
;;  nuia01mV/nuep_tot [SWE, 3DP, ALL, R0]    :    3.93e+00  2.11e+04  2.17e+02  1.52e+02  2.34e+02  3.50e-01  9.12e+00  3.35e+02  7.52e+01  2.89e+02  1.61e+02     2630161      445801
;;  nuia01mV/nuea_tot [SWE, 3DP, ALL, R0]    :    1.06e+01  2.49e+04  1.31e+03  1.03e+03  1.12e+03  2.54e+00  2.75e+00  1.65e+01  5.62e+02  1.72e+03  1.06e+03     2630161      193704
;;  nuia01mV/nupa_tot [SWE, 3DP, ALL, R0]    :    2.36e+02  1.37e+07  6.87e+04  3.50e+04  1.12e+05  2.55e+02  1.92e+01  1.52e+03  1.52e+04  8.00e+04  3.89e+04     2630161      193704
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV/nuee_tot [SWE, 3DP, ALL, R1]    :    3.31e-01  1.78e+04  3.25e+01  2.29e+01  4.47e+01  4.93e-02  8.99e+01  3.14e+04  1.16e+01  4.28e+01  2.43e+01     2630161      820057
;;  nuia01mV/nupp_tot [SWE, 3DP, ALL, R1]    :    4.19e+00  1.11e+06  1.97e+03  5.42e+02  5.22e+03  7.81e+00  3.50e+01  5.22e+03  1.77e+02  1.78e+03  6.72e+02     2630161      445801
;;  nuia01mV/nuaa_tot [SWE, 3DP, ALL, R1]    :    1.30e+01  3.14e+06  1.24e+04  3.83e+03  2.52e+04  5.73e+01  2.11e+01  1.72e+03  1.19e+03  1.40e+04  5.00e+03     2630161      193704
;;  nuia01mV/nuep_tot [SWE, 3DP, ALL, R1]    :    4.87e-01  2.62e+03  2.70e+01  1.89e+01  2.90e+01  4.34e-02  9.12e+00  3.35e+02  9.32e+00  3.58e+01  2.00e+01     2630161      445801
;;  nuia01mV/nuea_tot [SWE, 3DP, ALL, R1]    :    1.32e+00  3.09e+03  1.62e+02  1.27e+02  1.38e+02  3.15e-01  2.75e+00  1.65e+01  6.97e+01  2.13e+02  1.32e+02     2630161      193704
;;  nuia01mV/nupa_tot [SWE, 3DP, ALL, R1]    :    2.92e+01  1.70e+06  8.52e+03  4.34e+03  1.39e+04  3.16e+01  1.92e+01  1.52e+03  1.89e+03  9.92e+03  4.83e+03     2630161      193704
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV/nuee_tot [SWE, 3DP, ALL, R2]    :    2.91e-02  1.57e+03  2.86e+00  2.02e+00  3.93e+00  4.34e-03  8.99e+01  3.14e+04  1.02e+00  3.76e+00  2.14e+00     2630161      820057
;;  nuia01mV/nupp_tot [SWE, 3DP, ALL, R2]    :    3.69e-01  9.77e+04  1.73e+02  4.76e+01  4.59e+02  6.87e-01  3.50e+01  5.22e+03  1.55e+01  1.56e+02  5.91e+01     2630161      445801
;;  nuia01mV/nuaa_tot [SWE, 3DP, ALL, R2]    :    1.14e+00  2.76e+05  1.09e+03  3.37e+02  2.22e+03  5.04e+00  2.11e+01  1.72e+03  1.05e+02  1.23e+03  4.40e+02     2630161      193704
;;  nuia01mV/nuep_tot [SWE, 3DP, ALL, R2]    :    4.28e-02  2.30e+02  2.37e+00  1.66e+00  2.55e+00  3.82e-03  9.12e+00  3.35e+02  8.20e-01  3.15e+00  1.76e+00     2630161      445801
;;  nuia01mV/nuea_tot [SWE, 3DP, ALL, R2]    :    1.16e-01  2.72e+02  1.43e+01  1.12e+01  1.22e+01  2.77e-02  2.75e+00  1.65e+01  6.13e+00  1.87e+01  1.16e+01     2630161      193704
;;  nuia01mV/nupa_tot [SWE, 3DP, ALL, R2]    :    2.57e+00  1.49e+05  7.49e+02  3.82e+02  1.22e+03  2.78e+00  1.92e+01  1.52e+03  1.66e+02  8.73e+02  4.24e+02     2630161      193704
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV/nuee_tot [SWE, 3DP, ALL, R3]    :    3.61e-03  1.94e+02  3.55e-01  2.50e-01  4.87e-01  5.38e-04  8.99e+01  3.14e+04  1.27e-01  4.67e-01  2.65e-01     2630161      820057
;;  nuia01mV/nupp_tot [SWE, 3DP, ALL, R3]    :    4.57e-02  1.21e+04  2.14e+01  5.91e+00  5.69e+01  8.52e-02  3.50e+01  5.22e+03  1.93e+00  1.94e+01  7.32e+00     2630161      445801
;;  nuia01mV/nuaa_tot [SWE, 3DP, ALL, R3]    :    1.42e-01  3.42e+04  1.36e+02  4.17e+01  2.75e+02  6.24e-01  2.11e+01  1.72e+03  1.30e+01  1.52e+02  5.45e+01     2630161      193704
;;  nuia01mV/nuep_tot [SWE, 3DP, ALL, R3]    :    5.31e-03  2.85e+01  2.94e-01  2.06e-01  3.16e-01  4.74e-04  9.12e+00  3.35e+02  1.02e-01  3.90e-01  2.18e-01     2630161      445801
;;  nuia01mV/nuea_tot [SWE, 3DP, ALL, R3]    :    1.44e-02  3.37e+01  1.77e+00  1.39e+00  1.51e+00  3.43e-03  2.75e+00  1.65e+01  7.60e-01  2.32e+00  1.44e+00     2630161      193704
;;  nuia01mV/nupa_tot [SWE, 3DP, ALL, R3]    :    3.18e-01  1.85e+04  9.29e+01  4.73e+01  1.52e+02  3.44e-01  1.92e+01  1.52e+03  2.06e+01  1.08e+02  5.26e+01     2630161      193704
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------







;;----------------------------------------------------------------------------------------
;;  Print ratio stats for all types
;;----------------------------------------------------------------------------------------
line0          = ';;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
line1          = ';;========================================================================================'
line2          = ';;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #'
line3          = ';;======================================================================================================================================================================================'
mform          = '(a51,11e10.2,2I)'
;;  R0 = 100% occurrence rate of IAWs
frate_iaw      = 0.124d0                    ;;  R1 = IAWs occur at a rate of ~12.4% assuming they occur when (Te/Tp)_tot ≥ 3
frate__cs      = 942d0/864d2                ;;  R2 = Occurrence rate of current sheets ~ 1.1%
frate_net      = frate__cs[0]*frate_iaw[0]  ;;  R3 = Net IAW occurrence rate ~ 0.14%

str_pre        = ';;  nuia01mV/nuss_tot '
str___suffix   = '[SWE, 3DP, ALL, R0]'
x              = [nuia01mV/nuee_tot,nuia01mV/nupp_tot,nuia01mV/nuaa_tot,nuia01mV/nuep_tot,nuia01mV/nuea_tot,nuia01mV/nupa_tot]
xra01mV_R0     = calc_1var_stats(x,/NAN)
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
PRINT,str_pre[0]+str___suffix[0]+'    :  ',xra01mV_R0,FORMAT=mform[0]                                                       & $
PRINT,line0[0]
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV/nuss_tot [SWE, 3DP, ALL, R0]    :    2.67e+00  2.53e+07  1.76e+04  4.40e+02  7.67e+04  5.07e+01  4.17e+01  8.01e+03  1.52e+02  4.68e+03  8.71e+02    15780966     2292771
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

str_pre        = ';;  nuia01mV/nuss_tot '
str___suffix   = '[SWE, 3DP, ALL, R1]'
x              = [nuia01mV/nuee_tot,nuia01mV/nupp_tot,nuia01mV/nuaa_tot,nuia01mV/nuep_tot,nuia01mV/nuea_tot,nuia01mV/nupa_tot]*frate_iaw[0]
xra01mV_R1     = calc_1var_stats(x,/NAN)
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
PRINT,str_pre[0]+str___suffix[0]+'    :  ',xra01mV_R1,FORMAT=mform[0]                                                       & $
PRINT,line0[0]
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV/nuss_tot [SWE, 3DP, ALL, R1]    :    3.31e-01  3.14e+06  2.18e+03  5.45e+01  9.51e+03  6.28e+00  4.17e+01  8.01e+03  1.89e+01  5.81e+02  1.08e+02    15780966     2292771
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

str_pre        = ';;  nuia01mV/nuss_tot '
str___suffix   = '[SWE, 3DP, ALL, R2]'
x              = [nuia01mV/nuee_tot,nuia01mV/nupp_tot,nuia01mV/nuaa_tot,nuia01mV/nuep_tot,nuia01mV/nuea_tot,nuia01mV/nupa_tot]*frate__cs[0]
xra01mV_R2     = calc_1var_stats(x,/NAN)
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
PRINT,str_pre[0]+str___suffix[0]+'    :  ',xra01mV_R2,FORMAT=mform[0]                                                       & $
PRINT,line0[0]
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV/nuss_tot [SWE, 3DP, ALL, R2]    :    2.91e-02  2.76e+05  1.92e+02  4.79e+00  8.36e+02  5.52e-01  4.17e+01  8.01e+03  1.66e+00  5.11e+01  9.49e+00    15780966     2292771
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

str_pre        = ';;  nuia01mV/nuss_tot '
str___suffix   = '[SWE, 3DP, ALL, R3]'
x              = [nuia01mV/nuee_tot,nuia01mV/nupp_tot,nuia01mV/nuaa_tot,nuia01mV/nuep_tot,nuia01mV/nuea_tot,nuia01mV/nupa_tot]*frate_net[0]
xra01mV_R3     = calc_1var_stats(x,/NAN)
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
PRINT,str_pre[0]+str___suffix[0]+'    :  ',xra01mV_R3,FORMAT=mform[0]                                                       & $
PRINT,line0[0]
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV/nuss_tot [SWE, 3DP, ALL, R3]    :    3.61e-03  3.42e+04  2.38e+01  5.94e-01  1.04e+02  6.85e-02  4.17e+01  8.01e+03  2.06e-01  6.33e+00  1.18e+00    15780966     2292771
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






str_pre        = ';;  nuss_tot '
str___suffix   = '[SWE, 3DP, Fast SW, # s^(-1)]'
x              = [nuee_tot,nupp_tot,nuaa_tot,nuep_tot,nuea_tot,nupa_tot]
xra_tot_nu     = calc_1var_stats(x,/NAN)
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
PRINT,str_pre[0]+str___suffix[0]+'    :  ',xra_tot_nu,FORMAT=mform[0]                                                       & $
PRINT,line0[0]
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuss_tot [SWE, 3DP, Fast SW, # s^(-1)]    :    5.50e-12  1.21e-04  1.59e-06  2.58e-07  3.06e-06  1.63e-09  4.56e+00  3.88e+01  2.76e-08  1.90e-06  5.32e-07    15780966     3507386
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

str_pre        = ';;  nuss_tot '
str___suffix   = '[SWE, 3DP, Fast SW, # d^(-1)]'
x              = [nuee_tot,nupp_tot,nuaa_tot,nuep_tot,nuea_tot,nupa_tot]*864d2
xra_tot_nu     = calc_1var_stats(x,/NAN)
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
PRINT,str_pre[0]+str___suffix[0]+'    :  ',xra_tot_nu,FORMAT=mform[0]                                                       & $
PRINT,line0[0]
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuss_tot [SWE, 3DP, Fast SW, # d^(-1)]    :    4.75e-07  1.05e+01  1.37e-01  2.23e-02  2.64e-01  1.41e-04  4.56e+00  3.88e+01  2.38e-03  1.64e-01  4.60e-02    15780966     3507386
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

str_pre        = ';;  nuss_tot '
str___suffix   = '[SWE, 3DP, Fast SW, day/coll]'
x              = [nuee_tot,nupp_tot,nuaa_tot,nuep_tot,nuea_tot,nupa_tot]*864d2
xra_tot_nu     = calc_1var_stats(1d0/x,/NAN)
PRINT,line0[0]                                                                                                              & $
PRINT,line2[0]                                                                                                              & $
PRINT,line3[0]                                                                                                              & $
PRINT,str_pre[0]+str___suffix[0]+'    :  ',xra_tot_nu,FORMAT=mform[0]                                                       & $
PRINT,line0[0]
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuss_tot [SWE, 3DP, Fast SW, day/coll]    :    9.53e-02  2.10e+06  6.69e+02  4.49e+01  3.06e+03  1.63e+00  1.62e+02  8.14e+04  6.09e+00  4.20e+02  9.56e+01    15780966     3507386
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


;;            Min            Max             Mean           Median          StdDev.         StDvMn.           Skew.          Kurt.            Q1              Q2              IQM          Tot.  #          Fin.  #
;;      0.0036097430       34222.057       23.810397      0.59437090       103.72088     0.068499258       41.693634       8006.2910      0.20559578       6.3319916       1.1769660       15780966.       2292771.0







;;----------------------------------------------------------------------------------------
;;  Print parameter stats for all types
;;----------------------------------------------------------------------------------------
qform          = '(a4,11e16.3,2I)'
;;  Print thermal speeds (most probable speeds) [km/s]
resulte        = calc_1var_stats(vtetot*1d-3,/NAN)
resultp        = calc_1var_stats(vtptot*1d-3,/NAN)
resulta        = calc_1var_stats(vtatot*1d-3,/NAN)
PRINT,';;  ',resulte,FORMAT=qform[0]   & $
PRINT,';;  ',resultp,FORMAT=qform[0]   & $
PRINT,';;  ',resulta,FORMAT=qform[0]
;;            Min             Max             Mean           Median         StdDev.         StDvMn.          Skew.           Kurt.             Q1              Q2             IQM         Tot. #      Fin. #
;;         9.238e+02       4.548e+03       2.053e+03       2.045e+03       2.662e+02       2.939e-01       3.330e-01       1.431e+00       1.877e+03       2.221e+03       2.046e+03     2630161      820057
;;         5.478e+00       4.245e+02       4.483e+01       4.058e+01       2.049e+01       1.958e-02       1.641e+00       5.841e+00       2.990e+01       5.519e+01       4.121e+01     2630161     1095314
;;         4.652e+00       2.157e+02       2.897e+01       2.283e+01       1.765e+01       2.558e-02       1.366e+00       2.316e+00       1.538e+01       3.902e+01       2.440e+01     2630161      476255

;;  Print plasma frequencies [Hz]
resulte        = calc_1var_stats(fpe,/NAN)
resultp        = calc_1var_stats(fpp,/NAN)
resulta        = calc_1var_stats(fpa,/NAN)
PRINT,';;  ',resulte,FORMAT=qform[0]   & $
PRINT,';;  ',resultp,FORMAT=qform[0]   & $
PRINT,';;  ',resulta,FORMAT=qform[0]
;;            Min             Max             Mean           Median         StdDev.         StDvMn.          Skew.           Kurt.             Q1              Q2             IQM         Tot. #      Fin. #
;;         3.208e+03       9.392e+04       2.591e+04       2.456e+04       7.901e+03       8.725e+00       1.108e+00       2.129e+00       2.003e+04       3.027e+04       2.471e+04     2630161      820057
;;         3.219e+01       2.445e+03       5.814e+02       5.488e+02       2.002e+02       1.878e-01       1.083e+00       2.329e+00       4.378e+02       6.917e+02       5.536e+02     2630161     1137073
;;         6.297e+00       7.394e+02       1.030e+02       9.545e+01       4.235e+01       4.048e-02       1.907e+00       8.194e+00       7.549e+01       1.207e+02       9.621e+01     2630161     1094487

;;  Print cyclotron frequencies [Hz]
resulte        = calc_1var_stats(fce,/NAN)
resultp        = calc_1var_stats(fcp,/NAN)
resulta        = calc_1var_stats(fca,/NAN)
PRINT,';;  ',resulte,FORMAT=qform[0]   & $
PRINT,';;  ',resultp,FORMAT=qform[0]   & $
PRINT,';;  ',resulta,FORMAT=qform[0]
;;            Min             Max             Mean           Median         StdDev.         StDvMn.          Skew.           Kurt.             Q1              Q2             IQM         Tot. #      Fin. #
;;         1.451e+00       5.034e+03       1.989e+02       1.622e+02       1.700e+02       1.055e-01       7.909e+00       1.095e+02       1.251e+02       2.204e+02       1.654e+02     2630161     2597020
;;         7.905e-04       2.742e+00       1.083e-01       8.833e-02       9.259e-02       5.746e-05       7.909e+00       1.095e+02       6.813e-02       1.200e-01       9.008e-02     2630161     2597020
;;         1.990e-04       6.902e-01       2.727e-02       2.224e-02       2.331e-02       1.446e-05       7.909e+00       1.095e+02       1.715e-02       3.021e-02       2.268e-02     2630161     2597020

;;  Print magnetic fields [nT]
resultm        = calc_1var_stats(gbmag_mfi,/NAN)
resultx        = calc_1var_stats(gbvec_mfi[*,0],/NAN)
resulty        = calc_1var_stats(gbvec_mfi[*,1],/NAN)
resultz        = calc_1var_stats(gbvec_mfi[*,2],/NAN)
PRINT,';;  ',resultm,FORMAT=qform[0]   & $
PRINT,';;  ',resultx,FORMAT=qform[0]   & $
PRINT,';;  ',resulty,FORMAT=qform[0]   & $
PRINT,';;  ',resultz,FORMAT=qform[0]
;;            Min             Max             Mean           Median         StdDev.         StDvMn.          Skew.           Kurt.             Q1              Q2             IQM         Tot. #      Fin. #
;;         5.185e-02       1.798e+02       7.107e+00       5.794e+00       6.074e+00       3.769e-03       7.909e+00       1.095e+02       4.469e+00       7.873e+00       5.909e+00     2630161     2597020
;;        -1.197e+02       1.197e+02      -6.778e-02      -9.034e-02       5.748e+00       3.567e-03      -9.470e-01       3.480e+01      -3.223e+00       3.194e+00      -5.712e-02     2630161     2597020
;;        -1.195e+02       1.190e+02       1.916e-01       1.556e-01       5.506e+00       3.416e-03       4.541e-01       3.591e+01      -2.994e+00       3.233e+00       1.472e-01     2630161     2597020
;;        -7.405e+01       1.197e+02       1.264e-01       2.308e-03       4.897e+00       3.039e-03       3.625e+00       6.630e+01      -1.958e+00       1.934e+00      -2.447e-03     2630161     2597020

;;  Print absolute value of magnetic fields [nT]
resultm        = calc_1var_stats(gbmag_mfi,/NAN)
resultx        = calc_1var_stats(ABS(gbvec_mfi[*,0]),/NAN)
resulty        = calc_1var_stats(ABS(gbvec_mfi[*,1]),/NAN)
resultz        = calc_1var_stats(ABS(gbvec_mfi[*,2]),/NAN)
PRINT,';;  ',resultm,FORMAT=qform[0]   & $
PRINT,';;  ',resultx,FORMAT=qform[0]   & $
PRINT,';;  ',resulty,FORMAT=qform[0]   & $
PRINT,';;  ',resultz,FORMAT=qform[0]
;;            Min             Max             Mean           Median         StdDev.         StDvMn.          Skew.           Kurt.             Q1              Q2             IQM         Tot. #      Fin. #
;;         5.185e-02       1.798e+02       7.107e+00       5.794e+00       6.074e+00       3.769e-03       7.909e+00       1.095e+02       4.469e+00       7.873e+00       5.909e+00     2630161     2597020
;;         4.426e-06       1.197e+02       3.876e+00       3.209e+00       4.245e+00       2.634e-03       7.059e+00       9.274e+01       1.728e+00       4.826e+00       3.226e+00     2630161     2597020
;;         1.866e-06       1.195e+02       3.834e+00       3.117e+00       3.956e+00       2.455e-03       6.945e+00       1.098e+02       1.559e+00       4.994e+00       3.161e+00     2630161     2597020
;;         2.604e-06       1.197e+02       2.895e+00       1.946e+00       3.952e+00       2.452e-03       8.239e+00       1.336e+02       8.608e-01       3.666e+00       2.046e+00     2630161     2597020

;;  Print proton velocity [km/s]
good_v         = WHERE(ABS(REFORM(gvmag_epa[*,1,1])) GE 1e2,gd_v)
resultm        = calc_1var_stats(REFORM(gvmag_epa[good_v,1,1]),/NAN)
resultx        = calc_1var_stats(REFORM(gvelp_xyz[good_v,0,1]),/NAN)
resulty        = calc_1var_stats(REFORM(gvelp_xyz[good_v,1,1]),/NAN)
resultz        = calc_1var_stats(REFORM(gvelp_xyz[good_v,2,1]),/NAN)
PRINT,';;  ',resultm,FORMAT=qform[0]   & $
PRINT,';;  ',resultx,FORMAT=qform[0]   & $
PRINT,';;  ',resulty,FORMAT=qform[0]   & $
PRINT,';;  ',resultz,FORMAT=qform[0]
;;            Min             Max             Mean           Median         StdDev.         StDvMn.          Skew.           Kurt.             Q1              Q2             IQM         Tot. #      Fin. #
;;         1.142e+02       1.263e+03       4.183e+02       3.956e+02       9.650e+01       9.052e-02       1.360e+00       2.380e+00       3.489e+02       4.617e+02       3.984e+02     1136472     1136472
;;        -1.263e+03      -1.142e+02      -4.173e+02      -3.948e+02       9.620e+01       9.023e-02      -1.358e+00       2.375e+00      -4.607e+02      -3.482e+02      -3.976e+02     1136472     1136472
;;        -2.853e+02       3.270e+02      -2.179e+00      -3.217e+00       2.098e+01       1.968e-02       6.297e-01       6.213e+00      -1.387e+01       7.517e+00      -3.261e+00     1136472     1136472
;;        -2.085e+02       2.486e+02      -5.512e+00      -5.301e+00       1.928e+01       1.808e-02      -5.869e-02       3.189e+00      -1.595e+01       5.060e+00      -5.370e+00     1136472     1136472

;;  Print electron velocity [km/s]
good_v         = WHERE(ABS(REFORM(gvmag_epa[*,0,1])) GE 1e2,gd_v)
resultm        = calc_1var_stats(REFORM(gvmag_epa[good_v,0,1]),/NAN)
resultx        = calc_1var_stats(REFORM(gvele_xyz[good_v,0,1]),/NAN)
resulty        = calc_1var_stats(REFORM(gvele_xyz[good_v,1,1]),/NAN)
resultz        = calc_1var_stats(REFORM(gvele_xyz[good_v,2,1]),/NAN)
PRINT,';;  ',resultm,FORMAT=qform[0]   & $
PRINT,';;  ',resultx,FORMAT=qform[0]   & $
PRINT,';;  ',resulty,FORMAT=qform[0]   & $
PRINT,';;  ',resultz,FORMAT=qform[0]
;;            Min             Max             Mean           Median         StdDev.         StDvMn.          Skew.           Kurt.             Q1              Q2             IQM         Tot. #      Fin. #
;;         1.009e+02       1.421e+03       4.281e+02       4.066e+02       9.948e+01       1.100e-01       1.204e+00       2.101e+00       3.568e+02       4.781e+02       4.098e+02      818512      818512
;;        -1.366e+03       3.166e+02      -4.239e+02      -4.031e+02       9.834e+01       1.087e-01      -1.125e+00       1.820e+00      -4.735e+02      -3.537e+02      -4.062e+02      818512      818512
;;        -8.330e+02       7.451e+02       1.547e+01       1.410e+01       4.540e+01       5.018e-02       9.302e-01       1.390e+01      -7.500e+00       3.618e+01       1.418e+01      818512      818512
;;        -5.914e+02       7.265e+02      -5.811e+00      -4.035e+00       3.893e+01       4.303e-02      -2.611e-01       1.521e+01      -2.209e+01       1.171e+01      -4.429e+00      818512      818512

;;  Print Avg. plasma betas [unitless]
resulte        = calc_1var_stats(REFORM(beta_avg_epa[*,0,1]),/NAN)
resultp        = calc_1var_stats(REFORM(beta_avg_epa[*,1,1]),/NAN)
resulta        = calc_1var_stats(REFORM(beta_avg_epa[*,2,1]),/NAN)
PRINT,';;  ',resulte,FORMAT=qform[0]   & $
PRINT,';;  ',resultp,FORMAT=qform[0]   & $
PRINT,';;  ',resulta,FORMAT=qform[0]
;;            Min             Max             Mean           Median         StdDev.         StDvMn.          Skew.           Kurt.             Q1              Q2             IQM         Tot. #      Fin. #
;;         5.930e-03       8.870e+03       2.309e+00       1.093e+00       1.757e+01       1.940e-02       2.294e+02       9.159e+04       6.395e-01       1.993e+00       1.161e+00     2630161      820056
;;         9.515e-04       4.569e+03       1.795e+00       1.046e+00       1.137e+01       1.087e-02       1.817e+02       5.245e+04       5.392e-01       1.773e+00       1.079e+00     2630161     1095171
;;         4.879e-05       6.124e+02       1.676e-01       5.234e-02       1.353e+00       1.960e-03       2.519e+02       9.700e+04       1.682e-02       1.728e-01       6.621e-02     2630161      476129

;;  Print Par. plasma betas [unitless]
resulte        = calc_1var_stats(REFORM(beta_par_epa[*,0,1]),/NAN)
resultp        = calc_1var_stats(REFORM(beta_par_epa[*,1,1]),/NAN)
resulta        = calc_1var_stats(REFORM(beta_par_epa[*,2,1]),/NAN)
PRINT,';;  ',resulte,FORMAT=qform[0]   & $
PRINT,';;  ',resultp,FORMAT=qform[0]   & $
PRINT,';;  ',resulta,FORMAT=qform[0]
;;            Min             Max             Mean           Median         StdDev.         StDvMn.          Skew.           Kurt.             Q1              Q2             IQM         Tot. #      Fin. #
;;         5.436e-03       8.848e+03       2.276e+00       1.054e+00       1.758e+01       1.941e-02       2.283e+02       9.073e+04       6.011e-01       1.963e+00       1.124e+00     2630161      820056
;;         5.659e-05       4.924e+03       2.047e+00       1.294e+00       1.157e+01       1.101e-02       1.791e+02       5.272e+04       6.193e-01       2.184e+00       1.326e+00     2630161     1103741
;;         2.150e-05       6.476e+02       2.238e-01       7.182e-02       1.494e+00       1.989e-03       2.396e+02       8.356e+04       1.902e-02       2.661e-01       9.477e-02     2630161      564081

;;  Print Per. plasma betas [unitless]
resulte        = calc_1var_stats(REFORM(beta_per_epa[*,0,1]),/NAN)
resultp        = calc_1var_stats(REFORM(beta_per_epa[*,1,1]),/NAN)
resulta        = calc_1var_stats(REFORM(beta_per_epa[*,2,1]),/NAN)
PRINT,';;  ',resulte,FORMAT=qform[0]   & $
PRINT,';;  ',resultp,FORMAT=qform[0]   & $
PRINT,';;  ',resulta,FORMAT=qform[0]
;;            Min             Max             Mean           Median         StdDev.         StDvMn.          Skew.           Kurt.             Q1              Q2             IQM         Tot. #      Fin. #
;;         6.920e-03       8.914e+03       2.375e+00       1.170e+00       1.756e+01       1.939e-02       2.316e+02       9.329e+04       7.130e-01       2.055e+00       1.236e+00     2630161      820056
;;         3.715e-05       4.391e+03       1.699e+00       9.223e-01       1.134e+01       1.070e-02       1.803e+02       5.145e+04       4.713e-01       1.624e+00       9.601e-01     2630161     1124001
;;         5.139e-05       5.947e+02       1.927e-01       8.048e-02       1.229e+00       1.308e-03       2.307e+02       8.522e+04       2.110e-02       2.158e-01       9.271e-02     2630161      883409

































































































