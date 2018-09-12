;;----------------------------------------------------------------------------------------
;;  Anomalous Resistivity Definitions
;;
;;  REFERENCES:  
;;               1)  Spitzer, L. and R. Harm (1953), "Transport Phenomena in a
;;                      Completely Ionized Gas," Phys. Rev., Vol. 89, pp. 977.
;;               2)  Labelle, J.W. and R.A. Treumann (1988), "Plasma Waves at the
;;                      Dayside Magnetopause," Space Sci. Rev., Vol. 47, pp. 175.
;;               3)  Coroniti, F.V. (1985), "Space Plasma Turbulent Dissipation:
;;                      Reality or Myth?," Space Sci. Rev., Vol. 42, pp. 399.
;;
;;      Definitions
;;          1)  IAW  = Ion-Acoustic Wave
;;          2)  LHD  = Lower-Hybrid Drift
;;          3)  LHDI = Lower-Hybrid Drift Instability
;;          4)  ECDI = Electron Cyclotron Drift Instability
;;
;;  --> 4 Resistivities were calculated
;;          1)  IAW  [Labelle and Treumann, (1988)] = [*,0]
;;          2)  LHDI [Coroniti, (1985)]             = [*,1]
;;          3)  LHDI [Labelle and Treumann, (1988)] = [*,2]
;;          4)  ECDI [Labelle and Treumann, (1988)] = [*,3]
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Thermodynamic Definitions
;;
;;    Let ∆∑ = (ƒ T ∆s)/∆t
;;           = change in specific entropy energy density with respect to time
;;           = energy density dissipation rate due to entropy change
;;
;;    Let ∆¥ = ∆h/∆t (= (ƒ T ∆s)/∆t  +  Cs^(2) ∆ƒ/∆t)
;;           = change in specific enthalpy density with respect to time
;;           = energy density dissipation rate due to enthalpy change
;;      {ƒ = mass density, Cs = sound speed, and ∆s = change in specific entropy}
;;      [∆¥] = [µW m^(-3)]
;;
;;    Let ∆s = kB/(M († - 1)) ln | (P2/P1)*(ƒ1/ƒ2)^† |
;;      {ƒ = mass density, P = total thermal plasma pressure, and † = polytrope index}
;;
;;    Let ∆K = 1/2 M ∆[Ni Un^2]
;;           = change in kinetic energy density across the shock
;;      [∆K] = [µJ m^(-3)]
;;
;;    Let ø  = (*eta* |j|^2)/(∆K/∆t)
;;           = energy dissipation relative to the change in kinetic energy density
;;
;;    Let Ω  = |Jo . ∂E|/(∆K/∆t)
;;           = energy dissipation relative to the change in kinetic energy density
;;
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;; => Electron mass [kg]
mp             = 1.6726217770d-27     ;; => Proton mass [kg]
ma             = 6.6446567500d-27     ;; => Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;; => Speed of light in vacuum [m/s]
epo            = 8.8541878170d-12     ;; => Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;; => Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;; => Fundamental charge [C]
kB             = 1.3806488000d-23     ;; => Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;; => Planck Constant [J s]
GG             = 6.6738400000d-11     ;; => Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;; => Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;; => Energy associated with 1 eV of energy [J]
;; => Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K
R_E            = 6.37814d3            ;; => Earth's Equitorial Radius [km]

wpefac         = SQRT(1d6*qq[0]^2/(epo[0]*me[0]))
wpifac         = SQRT(1d6*qq[0]^2/(epo[0]*mp[0]))
wcefac         = qq[0]*1d-9/me[0]
wcifac         = qq[0]*1d-9/mp[0]
ckm            = c[0]*1d-3            ;;  m --> km
;;  Setup margins
!X.MARGIN      = [15,5]
!Y.MARGIN      = [8,4]
;;----------------------------------------------------------------------------------------
;;  Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init

;;  Compile critical Mach number routines
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/genarr.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/zbrent.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/crit_mf.pro

.compile shock_enthalpy_rate
.compile read_thm_j_E_S_corr
.compile thm_load_bowshock_rhsolns
.compile thm_load_bowshock_ascii
.compile find_j2_eta_k_from_h
.compile temp_calc_j2_eta_k_S_from_h

.compile get_thm_entropy_diss_data
.compile temp_thm_entropy_diss_plots
;;----------------------------------------------------------------------------------------
;;  Get ASCII data
;;----------------------------------------------------------------------------------------
thm_load_bowshock_ascii,R_STRUCT=Jo_dE_DS_corr

thm_load_bowshock_ascii,R_STRUCT=Jo_dE_US_corr,/UPSAMPLE

dummy          = get_thm_entropy_diss_data(/UPSAMPLE,JES_STR=Jo_dE_US_corr)
;;----------------------------------------------------------------------------------------
;;  Define parameters
;;----------------------------------------------------------------------------------------
;;  Define structures
jes_corr       = dummy.J_E_S_CORR
macro_str      = dummy.MACRO_PARAMS
micro_str      = dummy.MICRO_PARAMS
diss_rate      = dummy.DISS_RATES
;;  Define relevant parameters
all_ns         = jes_corr.NUM              ;;  # of points in each crossing
n_cross        = N_TAGS(all_ns)            ;;  # of bow shock crossings
all_ind        = dummy.ALL_IND
dc_tags        = TAG_NAMES(all_ns)         ;;  e.g., 'THB_2009_07_13_1ST'
;;  Determine # of parameters used in RH calculations
nRH            = LONARR(n_cross[0])
FOR j=0L, n_cross[0] - 1L DO nRH[j] = N_ELEMENTS(diss_rate.(j).DISS_RATE.OBSERVED.(0))

;;  Define shock ramp durations, ∆Tsh [s]
all_dt_sh      = macro_str.ALL_DT_SH[*,0]
;;  Define macroscopic dissipation rates
avg_ds_dt      = macro_str.AVG_DISSRATE_OBS[*,0]           ;;  ∆∑ [for † = 5/3, µW m^(-3)]
avg_dKE_obs    = macro_str.AVG_DKE_OBS[*,0]                ;;  ∆K [µJ m^(-3)]
avg_dKE_dt     = avg_dKE_obs/all_dt_sh                     ;;  ∆K/∆Tsh [µW m^(-3)]
;;  Define *nu* [anomalous collision frequency, rad/s]
nu__nif_ncb    = micro_str.NU__NIF_GSE_JES
nu__iaw        = REFORM(nu__nif_ncb[*,0])
;;  Define *eta* [anomalous resistivity, Ω m]
eta_nif_ncb    = micro_str.ETA_NIF_GSE_JES
eta_iaw        = REFORM(eta_nif_ncb[*,0])
;;  Define (-Jo . ∂E)  [µW m^(-3), in NIF and NCB basis]
Jo_dot_dE      = micro_str.E_DOT_J_NIF_NCB_JES
;;  Define ∑ -(Jo . ∂E)  {cumulative sum of -(Jo . ∂E)}  [µW m^(-3), in NIF and NCB basis]
CS_Jo_dot_dE   = micro_str.EDJ_CS_NIF_NCB_JES





mform          = '(";;",a20,"  ",2e15.4,f15.1)'
FOR j=0L, n_cross[0] - 1L DO BEGIN                                               $
  PRINT,dc_tags[j],avg_ds_dt[j],avg_dKE_dt[j],nRH[j],FORMAT=mform[0]
;;----------------------------------------------------------------------------------------
;;  Stats for macroscopic dissipation rates  [µW m^(-3)]
;;----------------------------------------------------------------------------------------
;; Probe/Date/Crossing           ∆∑           ∆K/∆Tsh              #
;;========================================================================================
;;  THB_2009_07_13_1ST       6.5398e-06     1.3585e-04           29.0
;;  THC_2009_07_21_1ST       7.2639e-06     4.4571e-05           22.0
;;  THC_2009_07_23_1ST       3.0810e-06     3.5935e-05           15.0
;;  THC_2009_07_23_2ND       5.8900e-05     7.5663e-04           13.0
;;  THC_2009_07_23_3RD       2.5854e-06     1.4451e-05           21.0
;;  THC_2009_09_05_1ST       4.2692e-06     1.1754e-04           11.0
;;  THC_2009_09_05_2ND       1.8699e-05     1.1769e-04           15.0
;;  THC_2009_09_05_3RD       8.6953e-06     1.1698e-04           14.0
;;  THA_2009_09_26_1ST       1.7053e-04     2.0343e-03           47.0
;;  THE_2011_10_24_1ST       3.9117e-04     5.8546e-03           31.0
;;  THE_2011_10_24_2ND       3.1680e-05     1.2083e-03           28.0
;;----------------------------------------------------------------------------------------

x              = avg_ds_dt
y              = avg_dKE_dt
PRINT,MIN(x,/NAN),MAX(x,/NAN),MIN(y,/NAN),MAX(y,/NAN),FORMAT='(";;",4e15.4)'
;;     2.5854e-06     3.9117e-04     1.4451e-05     5.8546e-03




mform          = '(";;",5e15.4,f15.1)'
FOR j=0L, n_cross[0] - 1L DO BEGIN                                               $
  i   = all_ind.(j)                                                            & $
  ni  = DOUBLE(N_ELEMENTS(i))                                                  & $
  x   = ABS(Jo_dot_dE[i])                                                      & $
  good = WHERE(FINITE(x) AND x GT 0,gd)                                        & $
  IF (gd GT 0) THEN x  = x[good] ELSE x = REPLICATE(d,ni[0])                   & $
  IF (gd GT 0) THEN ni = DOUBLE(N_ELEMENTS(x))                                 & $
  z   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),MEDIAN(x),ni[0]]  & $
  PRINT,z,FORMAT=mform[0]
;;--------------------------------------------------------------------------------------------
;;  Stats for |(-Jo . ∂E)|  [µW m^(-3), in NIF and NCB basis]
;;--------------------------------------------------------------------------------------------
;;           Min            Max            Avg            Std            Med              #
;;============================================================================================
;;     4.8805e-09     4.0559e-01     3.9356e-03     1.2794e-02     7.3498e-04       104448.0
;;     5.9132e-08     4.1697e-01     8.0334e-03     1.7662e-02     2.4773e-03        51388.0
;;     9.1870e-08     1.9783e-01     6.1032e-03     1.1734e-02     2.7168e-03        52225.0
;;     3.3791e-07     5.4902e+00     7.6157e-02     2.4382e-01     1.8700e-02        51712.0
;;     4.6049e-09     6.6314e-01     1.0298e-02     2.3507e-02     3.0441e-03       104448.0
;;     3.6642e-09     1.7256e-01     6.4332e-04     1.8861e-03     1.7236e-04        86368.0
;;     3.4666e-09     4.7731e-02     7.1647e-04     1.9803e-03     1.7431e-04        43640.0
;;     5.8736e-07     5.8151e+00     6.4549e-02     1.4144e-01     1.9624e-02        46326.0
;;     2.4919e-09     2.6217e+00     1.4088e-02     5.6857e-02     1.8502e-03       104448.0
;;     2.0977e-09     1.9491e-01     2.2128e-03     4.2706e-03     1.0710e-03       131072.0
;;     1.5299e-07     1.0794e+01     7.8434e-02     2.2304e-01     2.0192e-02       131072.0
;;--------------------------------------------------------------------------------------------


mform          = '(";;",5e15.4,f15.1)'
FOR j=0L, n_cross[0] - 1L DO BEGIN                                               $
  i   = all_ind.(j)                                                            & $
  ni  = DOUBLE(N_ELEMENTS(i))                                                  & $
  x   = ABS(CS_Jo_dot_dE[i])                                                   & $
  good = WHERE(FINITE(x) AND x GT 0,gd)                                        & $
  IF (gd GT 0) THEN x  = x[good] ELSE x = REPLICATE(d,ni[0])                   & $
  IF (gd GT 0) THEN ni = DOUBLE(N_ELEMENTS(x))                                 & $
  z   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),MEDIAN(x),ni[0]]  & $
  PRINT,z,FORMAT=mform[0]
;;--------------------------------------------------------------------------------------------
;;  Stats for |∑ -(Jo . ∂E)|  [µW m^(-3), in NIF and NCB basis]
;;--------------------------------------------------------------------------------------------
;;           Min            Max            Avg            Std            Med              #
;;============================================================================================
;;     4.5424e-06     1.0768e+01     6.7731e+00     3.2056e+00     8.3787e+00       104448.0
;;     7.8663e-07     1.9018e+01     9.2290e+00     5.9197e+00     1.2922e+01        51388.0
;;     2.1099e-03     1.6759e+02     8.6221e+01     5.7051e+01     1.0640e+02        52225.0
;;     1.2072e-02     1.2262e+03     9.1528e+02     3.0859e+02     1.1074e+03        51712.0
;;     2.1241e-04     3.9362e+01     1.8486e+01     1.0491e+01     1.6512e+01       104448.0
;;     8.4085e-05     2.2731e+00     7.9117e-01     5.5865e-01     8.6996e-01       104960.0
;;     1.2693e-04     1.6143e+00     8.2505e-01     3.2851e-01     9.2324e-01        52225.0
;;     1.0152e-03     9.3450e+01     2.8548e+01     1.5057e+01     2.7388e+01        52635.0
;;     1.9239e-06     1.8296e+02     6.8772e+01     7.2660e+01     8.4222e+00       104448.0
;;     2.3731e-03     3.2167e+01     1.0565e+01     7.2121e+00     9.6739e+00       131072.0
;;     5.7519e-03     4.2065e+03     3.0851e+03     1.2065e+03     3.7190e+03       131072.0
;;--------------------------------------------------------------------------------------------















