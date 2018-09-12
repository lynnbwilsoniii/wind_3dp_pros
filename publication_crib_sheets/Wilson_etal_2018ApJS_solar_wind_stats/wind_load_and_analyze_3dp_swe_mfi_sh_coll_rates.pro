;;  $HOME/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_sh_coll_rates.pro

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
;wpe            = wpefac[0]*SQRT(gdens_epa[*,0,1])     ;;  wpe [rad/s]
;wpp            = wppfac[0]*SQRT(gdens_epa[*,1,1])     ;;  wpe [rad/s]
;wpa            = wpafac[0]*SQRT(gdens_epa[*,2,1])     ;;  wpe [rad/s]
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
;lambda_0       = 12d0*!DPI*1d6*REFORM(gdens_epa[*,1,1])*lambda_De^3d0
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
;;  Calculate Spitzer-Härm collision rates [# s^(-1)]
;;----------------------------------------------------------------------------------------
;;  Calculate the reduced mass
mu_ee          = me[0]/2d0
mu_pp          = mp[0]/2d0
mu_aa          = ma[0]/2d0
mu_ep          = me[0]*mp[0]/(me[0] + mp[0])
mu_ea          = me[0]*ma[0]/(me[0] + ma[0])
mu_pa          = ma[0]*mp[0]/(ma[0] + mp[0])
;;  Calculate Coulomb logarithm parameter
lamb_fac0      = (4d0*!DPI*epo[0])/(4d0*qq[0]^2d0)
lamb_fac1      = (4d0*!DPI*epo[0])/(SQRT(2d0)*qq[0]^2d0)
lamb_ee        = lamb_fac0[0]*mu_ee[0]*vtetot^3d0/wpe
lamb_pp        = lamb_fac0[0]*mu_pp[0]*vtptot^3d0/wpp
lamb_aa        = lamb_fac0[0]*mu_aa[0]*vtatot^3d0/wpa
lamb_ep        = lamb_fac1[0]*mu_ep[0]*(vtetot^2d0 + vtptot^2d0)*SQRT((wpe/vtetot)^2d0 + (wpp/vtptot)^2d0)
lamb_ea        = lamb_fac1[0]*mu_ea[0]*(vtetot^2d0 + vtatot^2d0)*SQRT((wpe/vtetot)^2d0 + (wpa/vtatot)^2d0)/2d0
lamb_pa        = lamb_fac1[0]*mu_pa[0]*(vtptot^2d0 + vtatot^2d0)*SQRT((wpp/vtptot)^2d0 + (wpa/vtatot)^2d0)/2d0
;lamb_ep        = lamb_fac1[0]*mu_ep[0]*(vtetot^2d0 + vtptot^2d0)*SQRT((vtetot/wpe)^2d0 + (vtptot/wpp)^2d0)
;lamb_ea        = lamb_fac1[0]*mu_ea[0]*(vtetot^2d0 + vtatot^2d0)*SQRT((vtetot/wpe)^2d0 + (vtatot/wpa)^2d0)/2d0
;lamb_pa        = lamb_fac1[0]*mu_pa[0]*(vtptot^2d0 + vtatot^2d0)*SQRT((vtptot/wpe)^2d0 + (vtptot/wpa)^2d0)/2d0
;;  Calculate electron-electron collision rates [# s^(-1)]
term0          = 8d0*SQRT(2d0*!DPI)*qq[0]^4d0
term1          = 3d0*(4d0*!DPI*epo[0])^2d0*me[0]^2d0
nuee_fac       = term0[0]/term1[0]
;nuee_tot       = nuee_fac[0]*REFORM(gdens_epa[*,0,1])*ALOG(lamb_ee)/vtetot^3d0
nuee_tot       = nuee_fac[0]*dens_e*ALOG(lamb_ee)/vtetot^3d0
;;  Calculate proton-proton collision rates [# s^(-1)]
term0          = 8d0*SQRT(2d0*!DPI)*qq[0]^4d0
term1          = 3d0*(4d0*!DPI*epo[0])^2d0*mp[0]^2d0
nupp_fac       = term0[0]/term1[0]
;nupp_tot       = nupp_fac[0]*REFORM(gdens_epa[*,1,1])*ALOG(lamb_pp)/vtptot^3d0
nupp_tot       = nupp_fac[0]*dens_p*ALOG(lamb_pp)/vtptot^3d0
;;  Calculate alpha-alpha collision rates [# s^(-1)]
term0          = 8d0*SQRT(2d0*!DPI)*(2d0*qq[0])^4d0
term1          = 3d0*(4d0*!DPI*epo[0])^2d0*ma[0]^2d0
nuaa_fac       = term0[0]/term1[0]
;nuaa_tot       = nuaa_fac[0]*REFORM(gdens_epa[*,2,1])*ALOG(lamb_aa)/vtatot^3d0
nuaa_tot       = nuaa_fac[0]*dens_a*ALOG(lamb_aa)/vtatot^3d0
;;  Calculate electron-proton collision rates [# s^(-1)]
term0          = 8d0*SQRT(4d0*!DPI)*qq[0]^4d0
term1          = 3d0*(4d0*!DPI*epo[0])^2d0*me[0]^2d0
nuep_fac       = term0[0]/term1[0]
;nuep_tot       = nuep_fac[0]*REFORM(gdens_epa[*,0,1])*ALOG(lamb_ep)/vtetot^3d0
nuep_tot       = nuep_fac[0]*dens_e*ALOG(lamb_ep)/vtetot^3d0
;;  Calculate electron-alpha collision rates [# s^(-1)]
nuea_tot       = 2d0^2d0*nuep_tot*ALOG(lamb_ea)/ALOG(lamb_ep)
;;  Calculate proton-alpha collision rates [# s^(-1)]
term0          = 32d0*SQRT(2d0*!DPI)*qq[0]^4d0
term1          = 3d0*(4d0*!DPI*epo[0])^2d0*mp[0]^2d0
nupa_fac       = term0[0]/term1[0]
;nupa_tot       = nupa_fac[0]*REFORM(gdens_epa[*,1,1])*ALOG(lamb_pa)/vtptot^3d0
nupa_tot       = nupa_fac[0]*dens_p*ALOG(lamb_pa)/vtptot^3d0
;;----------------------------------------------------------------------------------------
;;  Calculate ion-acoustic collision rates [# s^(-1)]
;;----------------------------------------------------------------------------------------
de_mag         = 1d-3                                  ;;  Try a 1 mV/m electric field amplitude
;nuia_fac       = epo[0]*(1d-3^2d0)/(2d0*1d6*eV2J[0])
nuia_fac       = epo[0]/(2d0*1d0*eV2J[0])
;nuia_1mV       = nuia_fac[0]*wpe*de_mag[0]^2d0/(REFORM(gdens_epa[*,0,1])*REFORM(gtavg_epa[*,0,1]))
nuia_1mV       = nuia_fac[0]*wpe*de_mag[0]^2d0/(dens_e*REFORM(gtavg_epa[*,0,1]))
de_mag         = 1d-4                                  ;;  Try a 0.1 mV/m electric field amplitude
;nuia01mV       = nuia_fac[0]*wpe*de_mag[0]^2d0/(REFORM(gdens_epa[*,0,1])*REFORM(gtavg_epa[*,0,1]))
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
;;  nuee_tot [SWE, 3DP, ALL, # s^(-1)]        :    4.10e-08  3.61e-04  1.26e-05  8.45e-06  1.20e-05  1.32e-08  3.53e+00  2.34e+01  5.55e-06  1.52e-05  9.02e-06     2630161      820057
;;  nuee_tot [SWE, 3DP, No Shocks, # s^(-1)]  :    4.10e-08  3.61e-04  1.21e-05  8.23e-06  1.14e-05  1.31e-08  3.58e+00  2.46e+01  5.50e-06  1.45e-05  8.76e-06     2435510      760815
;;  nuee_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:    4.10e-08  2.25e-04  1.67e-05  1.20e-05  1.54e-05  8.98e-08  2.89e+00  1.48e+01  6.75e-06  2.21e-05  1.28e-05      128109       29389
;;  nuee_tot [SWE, 3DP, Outside MOs, # s^(-1)]:    7.98e-08  3.61e-04  1.24e-05  8.35e-06  1.18e-05  1.33e-08  3.55e+00  2.39e+01  5.53e-06  1.50e-05  8.92e-06     2502052      790668
;;  nuee_tot [SWE, 3DP, Fast SW, # s^(-1)]    :    1.99e-07  1.91e-04  7.78e-06  5.71e-06  8.72e-06  3.54e-08  6.22e+00  5.72e+01  4.48e-06  7.67e-06  5.82e-06      194462       60700
;;  nuee_tot [SWE, 3DP, Slow SW, # s^(-1)]    :    1.86e-07  3.61e-04  1.67e-05  1.23e-05  1.41e-05  2.25e-08  3.02e+00  1.77e+01  7.53e-06  2.15e-05  1.30e-05      942027      394244
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nupp_tot [# s^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nupp_tot [SWE, 3DP, ALL, # s^(-1)]        :    2.45e-11  9.04e-05  8.18e-07  3.39e-07  1.29e-06  1.23e-09  6.37e+00  1.60e+02  1.03e-07  9.86e-07  4.01e-07     2630161     1095314
;;  nupp_tot [SWE, 3DP, No Shocks, # s^(-1)]  :    2.45e-11  9.04e-05  8.07e-07  3.28e-07  1.28e-06  1.28e-09  6.41e+00  1.66e+02  1.01e-07  9.69e-07  3.90e-07     2435510     1001957
;;  nupp_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:    2.45e-11  7.41e-05  1.43e-06  7.68e-07  2.41e-06  8.93e-09  8.53e+00  1.47e+02  3.12e-07  1.64e-06  8.30e-07      128109       72530
;;  nupp_tot [SWE, 3DP, Outside MOs, # s^(-1)]:    3.72e-11  9.04e-05  7.75e-07  3.16e-07  1.16e-06  1.15e-09  3.61e+00  5.64e+01  9.77e-08  9.34e-07  3.76e-07     2502052     1022784
;;  nupp_tot [SWE, 3DP, Fast SW, # s^(-1)]    :    3.72e-11  3.54e-05  1.66e-07  3.78e-08  6.65e-07  1.61e-09  1.62e+01  4.38e+02  2.21e-08  6.87e-08  3.98e-08      194462      170001
;;  nupp_tot [SWE, 3DP, Slow SW, # s^(-1)]    :    2.45e-11  9.04e-05  9.38e-07  4.45e-07  1.34e-06  1.39e-09  6.18e+00  1.56e+02  1.68e-07  1.16e-06  5.14e-07      942027      925313
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuaa_tot [# s^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuaa_tot [SWE, 3DP, ALL, # s^(-1)]        :    6.14e-11  2.29e-05  1.95e-07  6.57e-08  4.19e-07  6.08e-10  8.63e+00  1.46e+02  1.79e-08  2.03e-07  7.97e-08     2630161      476255
;;  nuaa_tot [SWE, 3DP, No Shocks, # s^(-1)]  :    6.14e-11  2.29e-05  1.91e-07  6.52e-08  4.11e-07  6.28e-10  8.91e+00  1.56e+02  1.77e-08  1.99e-07  7.89e-08     2435510      428536
;;  nuaa_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:    1.15e-10  2.29e-05  4.75e-07  1.68e-07  8.99e-07  4.32e-09  5.31e+00  4.68e+01  4.29e-08  5.27e-07  2.03e-07      128109       43343
;;  nuaa_tot [SWE, 3DP, Outside MOs, # s^(-1)]:    6.14e-11  1.31e-05  1.67e-07  6.04e-08  3.22e-07  4.90e-10  7.53e+00  1.25e+02  1.67e-08  1.84e-07  7.31e-08     2502052      432912
;;  nuaa_tot [SWE, 3DP, Fast SW, # s^(-1)]    :    6.14e-11  1.04e-05  1.58e-07  1.95e-08  4.60e-07  2.59e-09  7.85e+00  9.08e+01  4.65e-09  1.03e-07  2.97e-08      194462       31498
;;  nuaa_tot [SWE, 3DP, Slow SW, # s^(-1)]    :    7.19e-11  2.29e-05  1.98e-07  6.98e-08  4.16e-07  6.24e-10  8.70e+00  1.52e+02  1.95e-08  2.08e-07  8.36e-08      942027      444757
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuep_tot [# s^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuep_tot [SWE, 3DP, ALL, # s^(-1)]        :    2.15e-07  5.11e-04  2.01e-05  1.38e-05  1.87e-05  2.80e-08  3.25e+00  2.03e+01  8.24e-06  2.59e-05  1.49e-05     2630161      445801
;;  nuep_tot [SWE, 3DP, No Shocks, # s^(-1)]  :    2.64e-07  5.11e-04  1.94e-05  1.32e-05  1.80e-05  2.80e-08  3.31e+00  2.15e+01  8.09e-06  2.48e-05  1.43e-05     2435510      412947
;;  nuep_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:    2.15e-07  3.12e-04  2.41e-05  1.67e-05  2.27e-05  1.68e-07  3.06e+00  1.57e+01  1.00e-05  3.13e-05  1.80e-05      128109       18203
;;  nuep_tot [SWE, 3DP, Outside MOs, # s^(-1)]:    2.64e-07  5.11e-04  1.99e-05  1.36e-05  1.85e-05  2.83e-08  3.25e+00  2.05e+01  8.19e-06  2.57e-05  1.48e-05     2502052      427598
;;  nuep_tot [SWE, 3DP, Fast SW, # s^(-1)]    :    2.15e-07  2.64e-04  9.88e-06  6.92e-06  1.20e-05  5.12e-08  6.27e+00  5.84e+01  5.39e-06  9.56e-06  7.07e-06      194462       55111
;;  nuep_tot [SWE, 3DP, Slow SW, # s^(-1)]    :    4.45e-07  5.11e-04  2.15e-05  1.55e-05  1.91e-05  3.05e-08  3.18e+00  1.98e+01  9.30e-06  2.78e-05  1.65e-05      942027      390690
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nuea_tot [# s^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuea_tot [SWE, 3DP, ALL, # s^(-1)]        :    2.06e-06  1.96e-03  1.01e-04  7.61e-05  8.56e-05  1.94e-07  3.01e+00  1.66e+01  4.48e-05  1.29e-04  7.96e-05     2630161      193704
;;  nuea_tot [SWE, 3DP, No Shocks, # s^(-1)]  :    2.06e-06  1.96e-03  9.78e-05  7.34e-05  8.31e-05  1.97e-07  3.03e+00  1.72e+01  4.38e-05  1.26e-04  7.71e-05     2435510      177265
;;  nuea_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:    6.72e-06  1.18e-03  1.00e-04  6.76e-05  9.94e-05  9.90e-07  3.11e+00  1.42e+01  4.18e-05  1.21e-04  7.17e-05      128109       10077
;;  nuea_tot [SWE, 3DP, Outside MOs, # s^(-1)]:    2.06e-06  1.96e-03  1.01e-04  7.67e-05  8.48e-05  1.98e-07  2.99e+00  1.67e+01  4.50e-05  1.29e-04  8.01e-05     2502052      183627
;;  nuea_tot [SWE, 3DP, Fast SW, # s^(-1)]    :    2.06e-06  1.01e-03  8.18e-05  4.53e-05  9.24e-05  9.74e-07  2.92e+00  1.23e+01  2.74e-05  9.95e-05  5.11e-05      194462        9002
;;  nuea_tot [SWE, 3DP, Slow SW, # s^(-1)]    :    3.93e-06  1.96e-03  1.02e-04  7.75e-05  8.51e-05  1.98e-07  3.03e+00  1.70e+01  4.59e-05  1.30e-04  8.09e-05      942027      184702
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  nupa_tot [# s^(-1)] Stats
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nupa_tot [SWE, 3DP, ALL, # s^(-1)]        :    2.36e-09  3.10e-04  4.58e-06  2.65e-06  5.94e-06  8.60e-09  7.03e+00  1.72e+02  1.15e-06  5.86e-06  2.91e-06     2630161      476255
;;  nupa_tot [SWE, 3DP, No Shocks, # s^(-1)]  :    2.36e-09  3.10e-04  4.56e-06  2.62e-06  5.89e-06  8.99e-09  7.06e+00  1.77e+02  1.13e-06  5.85e-06  2.89e-06     2435510      428536
;;  nupa_tot [SWE, 3DP, Inside  MOs, # s^(-1)]:    6.53e-09  3.10e-04  6.87e-06  3.77e-06  1.13e-05  5.44e-08  8.31e+00  1.29e+02  1.78e-06  7.75e-06  4.08e-06      128109       43343
;;  nupa_tot [SWE, 3DP, Outside MOs, # s^(-1)]:    2.36e-09  1.44e-04  4.35e-06  2.55e-06  5.03e-06  7.65e-09  2.66e+00  1.38e+01  1.10e-06  5.67e-06  2.80e-06     2502052      432912
;;  nupa_tot [SWE, 3DP, Fast SW, # s^(-1)]    :    3.34e-09  1.45e-04  2.34e-06  8.01e-07  5.40e-06  3.04e-08  8.75e+00  1.22e+02  2.42e-07  2.24e-06  9.28e-07      194462       31498
;;  nupa_tot [SWE, 3DP, Slow SW, # s^(-1)]    :    2.36e-09  3.10e-04  4.74e-06  2.82e-06  5.94e-06  8.91e-09  7.04e+00  1.78e+02  1.26e-06  6.08e-06  3.07e-06      942027      444757
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
;;  nuia_1mV/nuee_tot [SWE, 3DP, ALL]        :    8.94e+01  3.39e+06  7.50e+03  5.41e+03  9.44e+03  1.04e+01  6.76e+01  2.07e+04  2.80e+03  9.90e+03  5.71e+03     2630161      820057
;;  nuia_1mV/nupp_tot [SWE, 3DP, ALL]        :    1.14e+03  2.14e+08  4.42e+05  1.30e+05  1.10e+06  1.65e+03  2.85e+01  3.67e+03  4.38e+04  4.11e+05  1.59e+05     2630161      445801
;;  nuia_1mV/nuaa_tot [SWE, 3DP, ALL]        :    3.43e+03  5.88e+08  2.56e+06  8.20e+05  5.00e+06  1.14e+04  1.85e+01  1.38e+03  2.62e+05  2.93e+06  1.06e+06     2630161      193704
;;  nuia_1mV/nuep_tot [SWE, 3DP, ALL]        :    8.45e+01  2.35e+05  4.76e+03  3.37e+03  4.81e+03  7.20e+00  6.11e+00  1.27e+02  1.69e+03  6.37e+03  3.57e+03     2630161      445801
;;  nuia_1mV/nuea_tot [SWE, 3DP, ALL]        :    2.19e+01  3.78e+04  8.11e+02  5.86e+02  7.32e+02  1.66e+00  3.58e+00  5.48e+01  3.25e+02  1.07e+03  6.20e+02     2630161      193704
;;  nuia_1mV/nupa_tot [SWE, 3DP, ALL]        :    2.98e+02  1.04e+07  4.08e+04  1.79e+04  8.19e+04  1.86e+02  2.41e+01  2.05e+03  7.58e+03  4.36e+04  2.03e+04     2630161      193704
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                   Min       Max       Mean     Median    StdDev.   StDvMn.    Skew.     Kurt.      Q1        Q2       IQM        Tot.  #     Fin.  #
;;======================================================================================================================================================================================
;;  nuia01mV/nuee_tot [SWE, 3DP, ALL]        :    8.94e-01  3.39e+04  7.50e+01  5.41e+01  9.44e+01  1.04e-01  6.76e+01  2.07e+04  2.80e+01  9.90e+01  5.71e+01     2630161      820057
;;  nuia01mV/nupp_tot [SWE, 3DP, ALL]        :    1.14e+01  2.14e+06  4.42e+03  1.30e+03  1.10e+04  1.65e+01  2.85e+01  3.67e+03  4.38e+02  4.11e+03  1.59e+03     2630161      445801
;;  nuia01mV/nuaa_tot [SWE, 3DP, ALL]        :    3.43e+01  5.88e+06  2.56e+04  8.20e+03  5.00e+04  1.14e+02  1.85e+01  1.38e+03  2.62e+03  2.93e+04  1.06e+04     2630161      193704
;;  nuia01mV/nuep_tot [SWE, 3DP, ALL]        :    8.45e-01  2.35e+03  4.76e+01  3.37e+01  4.81e+01  7.20e-02  6.11e+00  1.27e+02  1.69e+01  6.37e+01  3.57e+01     2630161      445801
;;  nuia01mV/nuea_tot [SWE, 3DP, ALL]        :    2.19e-01  3.78e+02  8.11e+00  5.86e+00  7.32e+00  1.66e-02  3.58e+00  5.48e+01  3.25e+00  1.07e+01  6.20e+00     2630161      193704
;;  nuia01mV/nupa_tot [SWE, 3DP, ALL]        :    2.98e+00  1.04e+05  4.08e+02  1.79e+02  8.19e+02  1.86e+00  2.41e+01  2.05e+03  7.58e+01  4.36e+02  2.03e+02     2630161      193704
;;
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------








