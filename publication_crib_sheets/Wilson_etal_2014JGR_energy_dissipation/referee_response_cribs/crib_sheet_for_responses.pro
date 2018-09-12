;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
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
;; => Compile necessary routines
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
all_ns         = dummy.J_E_S_CORR.NUM      ;;  # of points in each crossing
n_cross        = N_TAGS(all_ns)            ;;  # of bow shock crossings
all_ind        = dummy.ALL_IND

all_Vshn       = dummy.MACRO_PARAMS.ALL_VSHN            ;;  shock normal speeds [SCF, km/s]
all_Ushn_up    = dummy.MACRO_PARAMS.ALL_USHN_UP         ;;  upstream shock normal speeds [shock frame, km/s]
all_Lsh        = dummy.MACRO_PARAMS.ALL_LI_UP           ;;  shock ramp thickness, Lsh [km]

all_Bo_up      = dummy.MACRO_PARAMS.ALL_BO_UP           ;;  upstream average B-field vector [nT]
all_Vi_up      = dummy.MACRO_PARAMS.ALL_VI_UP           ;;  upstream average ion core bulk flow velocity [km/s]

bmag_up        = SQRT(TOTAL(all_Bo_up[*,*,0]^2,2L,/NAN))
vmag_up        = SQRT(TOTAL(all_Vi_up[*,*,0]^2,2L,/NAN))
wci_up         = wcifac[0]*bmag_up
;;  Define *nu* [anomalous collision frequency, rad/s]
nu__nif_gse    = dummy.MICRO_PARAMS.NU__NIF_GSE_JES         ;;  *nu*  [rad/s, in NIF and NCB basis]
nu_iaw         = REFORM(nu__nif_gse[*,0])

;;  Shock thickness [km]
L_sh           = REFORM(all_Lsh[*,0])
;;  Foot thickness [km]
L_foot         = REFORM(ABS(all_Ushn_up[*,0]))/wci_up
;;  Define Collisional thickness, L_wp [km]
FOR j=0L, n_cross[0] - 1L DO BEGIN                  $
  jstr = STRING(j[0],FORMAT='(I2.2)')             & $
  ind = all_ind.(j)                               & $
  x   = nu_iaw[ind]                               & $
  y   = ABS(all_Ushn_up[j,0])/x                   & $
  str_element,nu_iaw_str,jstr[0],x,/ADD_REPLACE   & $
  str_element,L_wp_str,jstr[0],y,/ADD_REPLACE


PRINT,';;',minmax(L_sh)
PRINT,';;',minmax(L_foot)
;;       39.328413       142.27903
;;       208.80411       3161.8836

FOR j=0L, n_cross[0] - 1L DO BEGIN                  $
  x   = nu_iaw_str.(j)                            & $
  z   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),MEDIAN(x),1d0*N_ELEMENTS(x)]  & $
  PRINT,z,FORMAT='(";;",5e15.4,f15.1)'
;;--------------------------------------------------------------------------------------------
;;  *nu* [anomalous collision frequency, rad/s, for IAWs]
;;--------------------------------------------------------------------------------------------
;;         Min            Max            Avg            Std            Med              #
;;============================================================================================
;;     8.6849e-05     1.6137e+03     6.2543e+00     3.5116e+01     3.5496e-01       104448.0
;;     3.5807e-04     2.4839e+03     2.1637e+01     7.4470e+01     2.3784e+00        51388.0
;;     7.9808e-04     8.0404e+02     1.2735e+00     6.9230e+00     4.6968e-01        52225.0
;;     4.1972e-04     1.2210e+03     7.5249e+00     3.3541e+01     7.9802e-01        51712.0
;;     1.1371e-04     1.0433e+03     5.6558e+00     3.1116e+01     5.2090e-01       104448.0
;;     2.3155e-06     2.0275e+03     1.0384e+00     1.2470e+01     5.9265e-02       104960.0
;;     2.9325e-05     9.5885e+02     5.1541e+00     2.6467e+01     1.2172e-01        52225.0
;;     4.3808e-05     7.2696e+02     3.5243e+00     1.4784e+01     2.3176e-01        52736.0
;;     3.7202e-05     3.8838e+03     1.1531e+01     5.4126e+01     8.7609e-01       104448.0
;;     6.6817e-04     1.3844e+02     1.6276e-01     1.0791e+00     5.3688e-02       131072.0
;;     6.3183e-04     3.7561e+02     1.7821e+00     5.8068e+00     4.7855e-01       131072.0
;;--------------------------------------------------------------------------------------------


FOR j=0L, n_cross[0] - 1L DO BEGIN                  $
  x   = L_wp_str.(j)                              & $
  z   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),MEDIAN(x),1d0*N_ELEMENTS(x)]  & $
  PRINT,z,FORMAT='(";;",5e15.4,f15.1)'
;;--------------------------------------------------------------------------------------------
;;  Collisional thickness, L_wp = Ushn/*nu* [km]
;;--------------------------------------------------------------------------------------------
;;         Min            Max            Avg            Std            Med              #
;;============================================================================================
;;     1.7045e-01     3.1670e+06     4.7432e+03     2.2945e+04     7.7492e+02       104448.0
;;     8.0360e-02     5.5746e+05     4.0855e+02     3.3750e+03     8.3931e+01        51388.0
;;     5.2916e-01     5.3311e+05     2.4640e+03     9.0101e+03     9.0587e+02        52225.0
;;     4.1310e-01     1.2017e+06     4.9064e+03     2.5053e+04     6.3207e+02        51712.0
;;     3.9965e-01     3.6668e+06     4.2068e+03     2.4353e+04     8.0044e+02       104448.0
;;     1.3300e-01     1.1645e+08     2.2451e+04     4.9215e+05     4.5501e+03       104960.0
;;     2.2935e-01     7.4991e+06     6.2069e+03     7.8787e+04     1.8068e+03        52225.0
;;     4.9169e-01     8.1592e+06     1.3134e+04     7.4444e+04     1.5429e+03        52736.0
;;     8.7402e-02     9.1248e+06     9.0905e+03     7.0632e+04     3.8747e+02       104448.0
;;     2.6070e+00     5.4016e+05     7.7003e+03     7.7841e+03     6.7226e+03       131072.0
;;     9.7246e-01     5.7810e+05     1.3885e+03     4.8875e+03     7.6329e+02       131072.0
;;--------------------------------------------------------------------------------------------


FOR j=0L, n_cross[0] - 1L DO BEGIN                  $
  x   = L_wp_str.(j)/L_foot[j]                    & $
  z   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),MEDIAN(x),1d0*N_ELEMENTS(x)]  & $
  PRINT,z,FORMAT='(";;",5e15.4,f15.1)'
;;--------------------------------------------------------------------------------------------
;;  Collisional thickness, L_wp/L_foot
;;--------------------------------------------------------------------------------------------
;;         Min            Max            Avg            Std            Med              #
;;============================================================================================
;;     2.1616e-04     4.0164e+03     6.0152e+00     2.9098e+01     9.8274e-01       104448.0
;;     3.2807e-04     2.2758e+03     1.6679e+00     1.3778e+01     3.4264e-01        51388.0
;;     6.8309e-04     6.8819e+02     3.1808e+00     1.1631e+01     1.1694e+00        52225.0
;;     5.0333e-04     1.4642e+03     5.9779e+00     3.0525e+01     7.7012e-01        51712.0
;;     5.9028e-04     5.4159e+03     6.2136e+00     3.5970e+01     1.1823e+00       104448.0
;;     4.2063e-05     3.6831e+04     7.1004e+00     1.5565e+02     1.4391e+00       104960.0
;;     1.5266e-04     4.9916e+03     4.1314e+00     5.2442e+01     1.2026e+00        52225.0
;;     1.7568e-04     2.9153e+03     4.6928e+00     2.6599e+01     5.5128e-01        52736.0
;;     7.4629e-05     7.7912e+03     7.7620e+00     6.0310e+01     3.3084e-01       104448.0
;;     8.1602e-03     1.6908e+03     2.4103e+01     2.4365e+01     2.1043e+01       131072.0
;;     4.6573e-03     2.7686e+03     6.6497e+00     2.3407e+01     3.6555e+00       131072.0
;;--------------------------------------------------------------------------------------------


FOR j=0L, n_cross[0] - 1L DO BEGIN                  $
  x   = L_wp_str.(j)/L_sh[j]                      & $
  z   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),MEDIAN(x),1d0*N_ELEMENTS(x)]  & $
  PRINT,z,FORMAT='(";;",5e15.4,f15.1)'
;;--------------------------------------------------------------------------------------------
;;  Collisional thickness, L_wp/L_sh
;;--------------------------------------------------------------------------------------------
;;         Min            Max            Avg            Std            Med              #
;;============================================================================================
;;     2.0068e-03     3.7286e+04     5.5842e+01     2.7013e+02     9.1232e+00       104448.0
;;     9.5357e-04     6.6149e+03     4.8480e+00     4.0048e+01     9.9594e-01        51388.0
;;     4.4909e-03     4.5245e+03     2.0912e+01     7.6469e+01     7.6880e+00        52225.0
;;     3.4984e-03     1.0177e+04     4.1550e+01     2.1216e+02     5.3527e+00        51712.0
;;     3.4586e-03     3.1732e+04     3.6406e+01     2.1075e+02     6.9270e+00       104448.0
;;     9.4407e-04     8.2664e+05     1.5936e+02     3.4935e+03     3.2299e+01       104960.0
;;     1.6380e-03     5.3558e+04     4.4329e+01     5.6269e+02     1.2904e+01        52225.0
;;     3.4558e-03     5.7346e+04     9.2311e+01     5.2322e+02     1.0844e+01        52736.0
;;     1.1923e-03     1.2448e+05     1.2401e+02     9.6357e+02     5.2859e+00       104448.0
;;     6.6287e-02     1.3735e+04     1.9580e+02     1.9793e+02     1.7093e+02       131072.0
;;     1.9310e-02     1.1479e+04     2.7572e+01     9.7053e+01     1.5157e+01       131072.0
;;--------------------------------------------------------------------------------------------




FOR j=0L, n_cross[0] - 1L DO BEGIN                      $
  x   = L_wp_str.(j)/L_foot[j]                        & $
  z   = [N_ELEMENTS(WHERE(x LT 1d0)), N_ELEMENTS(x)]  & $
  PRINT,';;', 1d0*z[0], 1d0*z[1], 1d2*z[0]/(1d0*z[1])
;;       52492.000       104448.00       50.256587
;;       36247.000       51388.000       70.535923
;;       23201.000       52225.000       44.425084
;;       28294.000       51712.000       54.714573
;;       48144.000       104448.00       46.093750
;;       36133.000       104960.00       34.425495
;;       20517.000       52225.000       39.285783
;;       27095.000       52736.000       51.378565
;;       68181.000       104448.00       65.277459
;;       2581.0000       131072.00       1.9691467
;;       23164.000       131072.00       17.672729


FOR j=0L, n_cross[0] - 1L DO BEGIN                  $
  x   = L_wp_str.(j)/L_sh[j]                      & $
  z   = [N_ELEMENTS(WHERE(x LT 1d0)), N_ELEMENTS(x)]  & $
  PRINT,';;', 1d0*z[0], 1d0*z[1], 1d2*z[0]/(1d0*z[1])
;;       21011.000       104448.00       20.116230
;;       25746.000       51388.000       50.101191
;;       2962.0000       52225.000       5.6716132
;;       11383.000       51712.000       22.012299
;;       17456.000       104448.00       16.712623
;;       5670.0000       104960.00       5.4020579
;;       9531.0000       52225.000       18.249880
;;       8910.0000       52736.000       16.895479
;;       25223.000       104448.00       24.148859
;;       143.00000       131072.00      0.10910034
;;       6327.0000       131072.00       4.8271179
















