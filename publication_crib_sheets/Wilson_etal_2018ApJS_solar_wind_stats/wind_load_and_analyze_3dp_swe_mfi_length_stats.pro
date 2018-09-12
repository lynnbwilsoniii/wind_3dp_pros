;;  $HOME/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_length_stats.pro

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
;;  Define frequencies
;;----------------------------------------------------------------------------------------
dens_e         = 1d6*REFORM(gdens_epa[*,0,1])         ;;  ne [# cm^(-3)]
dens_p         = 1d6*REFORM(gdens_epa[*,1,1])         ;;  np [# cm^(-3)]
dens_a         = 1d6*REFORM(gdens_epa[*,2,1])         ;;  na [# cm^(-3)]

;;  Calculate frequencies [rad/s]
wpefac         = SQRT(1d0*qq[0]^2d0/(me[0]*epo[0]))
wppfac         = SQRT(1d0*qq[0]^2d0/(mp[0]*epo[0]))
wpafac         = SQRT(4d0*qq[0]^2d0/(ma[0]*epo[0]))
wcefac         = qq[0]*1d-9/me[0]
wcpfac         = qq[0]*1d-9/mp[0]
wcafac         = qq[0]*1d-9/ma[0]
wpe            = wpefac[0]*SQRT(dens_e)               ;;  wpe [rad/s]
wpp            = wppfac[0]*SQRT(dens_p)               ;;  wpe [rad/s]
wpa            = wpafac[0]*SQRT(dens_a)               ;;  wpe [rad/s]
wce            = wcefac[0]*ABS(gbmag_mfi)             ;;  wce [rad/s]
wcp            = wcpfac[0]*ABS(gbmag_mfi)             ;;  wce [rad/s]
wca            = wcafac[0]*ABS(gbmag_mfi)             ;;  wce [rad/s]
;;----------------------------------------------------------------------------------------
;;  Calculate Debye length [m]
;;----------------------------------------------------------------------------------------
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

;;----------------------------------------------------------------------------------------
;;  Calculate gyroradii [km]
;;----------------------------------------------------------------------------------------
rho_ce         = 1d-3*vtetot/wce                      ;;  rho_ce [km]
rho_cp         = 1d-3*vtptot/wcp                      ;;  rho_cp [km]
rho_ca         = 1d-3*vtatot/wca                      ;;  rho_ca [km]

results        = calc_1var_stats(rho_ce,/NAN,/PRINT)
;;
;;             Min. value of X  =        0.23176557
;;             Max. value of X  =         164.36923
;;             Avg. value of X  =         2.3166700
;;           Median value of X  =         2.1078981
;;     Standard Deviation of X  =         1.3145836
;;  Std. Dev. of the Mean of X  =      0.0014516652
;;               Skewness of X  =         11.014780
;;               Kurtosis of X  =         582.85620
;;         Lower Quartile of X  =         1.6079403
;;         Upper Quartile of X  =         2.7234886
;;     Interquartile Mean of X  =         2.1261072
;;    Total # of Elements in X  =       2630161
;;   Finite # of Elements in X  =        820056
;;

results        = calc_1var_stats(rho_cp,/NAN,/PRINT)
results        = calc_1var_stats(rho_ca,/NAN,/PRINT)

;;----------------------------------------------------------------------------------------
;;  Calculate gyroradii-to-Debye length ratio [unitless]
;;----------------------------------------------------------------------------------------
ratio_rce_LDe  = (1d3*rho_ce)/lambda_De
results        = calc_1var_stats(ratio_rce_LDe,/NAN,/PRINT)
;;
;;             Min. value of X  =         6.9459029
;;             Max. value of X  =         13967.744
;;             Avg. value of X  =         186.10716
;;           Median value of X  =         152.25383
;;     Standard Deviation of X  =         146.28108
;;  Std. Dev. of the Mean of X  =        0.16153492
;;               Skewness of X  =         10.953001
;;               Kurtosis of X  =         394.96918
;;         Lower Quartile of X  =         115.74877
;;         Upper Quartile of X  =         210.64810
;;     Interquartile Mean of X  =         155.71598
;;    Total # of Elements in X  =       2630161
;;   Finite # of Elements in X  =        820056
;;





