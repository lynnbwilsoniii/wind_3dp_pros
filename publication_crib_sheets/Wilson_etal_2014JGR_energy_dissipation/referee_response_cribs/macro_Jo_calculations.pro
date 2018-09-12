;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;;  Electron mass [kg]
mp             = 1.6726217770d-27     ;;  Proton mass [kg]
ma             = 6.6446567500d-27     ;;  Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;;  Speed of light in vacuum [m/s]
epo            = 8.8541878170d-12     ;;  Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;;  Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;;  Fundamental charge [C]
kB             = 1.3806488000d-23     ;;  Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;;  Planck Constant [J s]
GG             = 6.6738400000d-11     ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [J]
;;  Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K
R_E            = 6.37814d3            ;;  Earth's Equitorial Radius [km]
;;  Constant factors for frequencies
wpefac         = SQRT(1d6*qq[0]^2/(epo[0]*me[0]))
wpifac         = SQRT(1d6*qq[0]^2/(epo[0]*mp[0]))
wcefac         = 1d-9*qq[0]/me[0]
wcifac         = 1d-9*qq[0]/mp[0]
;;  Constant factors for thermal pressures
prefac         = 1d6*J_1eV[0]
;;  Constant factors for current densities
jo_fac         = 1d-9/muo[0]
;;----------------------------------------------------------------------------------------
;;  Define range of upstream (up) and downstream (dn) parameters
;;----------------------------------------------------------------------------------------
ne_up          = [   2.5d0,  33.6d0]
ne_dn          = [  10.9d0, 101.3d0]
te_up          = [   7.9d0,  31.2d0]
te_dn          = [  30.5d0,  81.5d0]
ti_up          = [   7.5d0,  91.4d0]
ti_dn          = [  63.6d0, 311.1d0]
bo_up          = [   0.9d0,  18.2d0]
bo_dn          = [   6.7d0,  56.5d0]
vsw_up         = [ 254.7d0, 503.8d0]
vsw_dn         = [  82.4d0, 232.8d0]
vte_up         = [1664.5d0,3315.2d0]
vte_dn         = [3275.5d0,5353.1d0]
;;----------------------------------------------------------------------------------------
;;  Define range of frequencies
;;----------------------------------------------------------------------------------------
;;  Electron plasma frequency [rad/s]
wpe_up         = wpefac[0]*SQRT(ne_up)
wpe_dn         = wpefac[0]*SQRT(ne_dn)
;;  Ion (proton) plasma frequency [rad/s]
wpi_up         = wpifac[0]*SQRT(ne_up)
wpi_dn         = wpifac[0]*SQRT(ne_dn)
;;  Electron cyclotron frequency [rad/s]
wce_up         = wcefac[0]*bo_up
wce_dn         = wcefac[0]*bo_dn
;;  Ion (proton) cyclotron frequency [rad/s]
wci_up         = wcifac[0]*bo_up
wci_dn         = wcifac[0]*bo_dn
;;----------------------------------------------------------------------------------------
;;  Define range of lengths
;;----------------------------------------------------------------------------------------
;;  Electron inertial length [m]
Le_up          = (c[0]/wpe_up)
Le_dn          = (c[0]/wpe_dn)
;;  Ion (proton) inertial length [m]
Li_up          = (c[0]/wpi_up)
Li_dn          = (c[0]/wpi_dn)
;;----------------------------------------------------------------------------------------
;;  Define range of shock thicknesses [m]
;;----------------------------------------------------------------------------------------
;;  Mazelle et al., [2010]
;;    Lsh ~ 2 c/wpe to ~ 1 c/wpi
Lsh            = minmax([2d0*Le_up[SORT(Le_up)],Li_up[SORT(Li_up)]])

Lsh_obs        = [1.847d0,926.852d0]*1d3  ;;  from my observations
;;----------------------------------------------------------------------------------------
;;  Define range of thermal pressures [J m^(-3)]
;;----------------------------------------------------------------------------------------
Pe_up          = DBLARR(2,2)
Pe_dn          = DBLARR(2,2)
Pi_up          = DBLARR(2,2)
Pi_dn          = DBLARR(2,2)
FOR j=0L, 1L DO BEGIN                      $
  Pe_up[*,j] = prefac[0]*ne_up*te_up[j]  & $
  Pe_dn[*,j] = prefac[0]*ne_dn*te_dn[j]  & $
  Pi_up[*,j] = prefac[0]*ne_up*ti_up[j]  & $
  Pi_dn[*,j] = prefac[0]*ne_dn*ti_dn[j]
;;----------------------------------------------------------------------------------------
;;  Define range of values for grad(P)/(e n_up) ~ ∆P/(e n_up Lsh) [J m^(-3)]
;;----------------------------------------------------------------------------------------
gradP          = DBLARR(2,2)
denom          = DBLARR(2,2)
FOR j=0L, 1L DO BEGIN                             $
  gradP[*,j] = Pe_dn[*,j] - REFORM(Pe_up[j,*])  & $
  denom[*,j] = 1d6*qq[0]*ne_up*Lsh[j]

efluid         = DBLARR(2,2,2,2)
FOR j=0L, 1L DO BEGIN                             $
  FOR k=0L, 1L DO BEGIN                           $
    efluid[*,*,j,k] = gradP/denom[j,k]

PRINT,';;  < ∆(Pe)/(e ne_up) > [mV/m] = ', MEAN(efluid,/NAN)*1d3, '   ±', STDDEV(efluid,/NAN)*1d3
;;  < ∆(Pe)/(e ne_up) > [mV/m] =        165.49237   ±       408.71409

;;----------------------------------------------------------------------------------------
;;  Define range of values for jo ~ ∆B/(µ Lsh) [A m^(-2)]
;;----------------------------------------------------------------------------------------
del_B          = DBLARR(2,2)
jo_sh          = DBLARR(2,2,2)
FOR j=0L, 1L DO BEGIN del_B[*,j] = bo_dn - bo_up[j]
bad            = WHERE(del_B LE 0,bd)
IF (bd GT 0) THEN del_B[bad] = d

FOR j=0L, 1L DO BEGIN                             $
  FOR k=0L, 1L DO BEGIN                           $
    jo_sh[*,j,k] = jo_fac[0]*del_B[j,k]/Lsh
;;----------------------------------------------------------------------------------------
;;  Define range of values for *eta jo [V m^(-1)]
;;----------------------------------------------------------------------------------------
;;  Use values from Wilson et al., [2007]
eta_ql         = [1d0,856d0]  ;;  [Ω m]
eta_jo         = DBLARR(2,2,2,2)
FOR j=0L, 1L DO BEGIN                             $
  FOR k=0L, 1L DO BEGIN                           $
    eta_jo[*,*,j,k] = jo_sh[*,*,j]*eta_ql[k]

PRINT,';;  <*eta Jo> [mV m^(-1)] = ', MEAN(eta_jo,/NAN)*1d3, '   ±', STDDEV(eta_jo,/NAN)*1d3
;;  <*eta Jo> [mV m^(-1)] =        3.1296056   ±       6.8513627

;;----------------------------------------------------------------------------------------
;;  Print parameters
;;----------------------------------------------------------------------------------------
PRINT,';;  (c/wpe)_up [km] = ', minmax(Le_up)*1d-3
PRINT,';;  (c/wpi)_up [km] = ', minmax(Li_up)*1d-3
;;  (c/wpe)_up [km] =       0.91676818       3.3609277
;;  (c/wpi)_up [km] =        39.283839       144.01693

PRINT,';;  L_sh [km] = ', minmax(Lsh)*1d-3
;;  L_sh [km] =        1.8335364       144.01693

PRINT,';;  (Pe)_up [nPa] = ', minmax(Pe_up)*1d9
PRINT,';;  (Pe)_dn [nPa] = ', minmax(Pe_dn)*1d9
PRINT,';;  ∆(Pe)   [nPa] = ', minmax(gradP)*1d9
;;  (Pe)_up [nPa] =     0.0031642987      0.16795937
;;  (Pe)_dn [nPa] =      0.053264360       1.3227490
;;  ∆(Pe)   [nPa] =      0.050100061       1.1547896

PRINT,';;  ∆(Pe)/(e ne_up) [mV/m] = ', minmax(efluid)*1d3
;;  ∆(Pe)/(e ne_up) [mV/m] =      0.064621203       1572.3997

PRINT,';;  ∆(Bo)          [nT] = ', minmax(del_B)
PRINT,';;  Jo      [µA m^(-2)] = ', minmax(jo_sh)*1d6
PRINT,';;  *eta Jo [mV m^(-1)] = ', minmax(eta_jo)*1d3
;;  ∆(Bo)          [nT] =        5.8000000       55.600000
;;  Jo      [µA m^(-2)] =      0.032048268       24.131004
;;  *eta Jo [mV m^(-1)] =    3.2048268e-05       20.656140











;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------



;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;;  Electron mass [kg]
mp             = 1.6726217770d-27     ;;  Proton mass [kg]
ma             = 6.6446567500d-27     ;;  Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;;  Speed of light in vacuum [m/s]
epo            = 8.8541878170d-12     ;;  Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;;  Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;;  Fundamental charge [C]
kB             = 1.3806488000d-23     ;;  Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;;  Planck Constant [J s]
GG             = 6.6738400000d-11     ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [J]
;;  Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K
R_E            = 6.37814d3            ;;  Earth's Equitorial Radius [km]
;;  Constant factors for frequencies
wpefac         = SQRT(1d6*qq[0]^2/(epo[0]*me[0]))
wpifac         = SQRT(1d6*qq[0]^2/(epo[0]*mp[0]))
wcefac         = 1d-9*qq[0]/me[0]
wcifac         = 1d-9*qq[0]/mp[0]
;;  Constant factors for thermal pressures
prefac         = 1d6*J_1eV[0]
;;  Constant factors for current densities
jo_fac         = 1d-9/muo[0]
;;  Proton-to-Electron mass ratio
mrat           = mp[0]/me[0]
;;----------------------------------------------------------------------------------------
;;  Example shock current density calculation
;;----------------------------------------------------------------------------------------
dBo            = [1d1,3d1]                      ;;  ∆Bo [nT] across shock ramp
c_wpe_up       = 1d3                            ;;  upstream electron inertial length [m]
c_wpi_up       = SQRT(mrat[0])*c_wpe_up[0]      ;;  upstream ion (proton) inertial length [m]
Lsh_0          = [2d0*c_wpe_up[0],c_wpi_up[0]]  ;;  shock ramp thickness [m]
;;  Calculate Jo ~ ∆Bo/(µo Lsh)
jo_0           = jo_fac[0]*dBo/Lsh_0[0]
jo_1           = jo_fac[0]*dBo/Lsh_0[1]
jo_sh          = [[jo_0],[jo_1]]

PRINT,';;  L_sh [km]           = ', minmax(Lsh_0)*1d-3
;;  L_sh [km]           =        2.0000000       42.850352

PRINT,';;  Jo      [µA m^(-2)] = ', minmax(jo_sh)*1d6
;;  Jo      [µA m^(-2)] =       0.18571019       11.936621


;;----------------------------------------------------------------------------------------
;;  Example whistler current density calculation
;;----------------------------------------------------------------------------------------
dBww           = 1d0                            ;;  ∂B [nT] for whistler mode waves (WWs)
krhoce         = [2d-1,8d-1]                    ;;  (k rho_ce) for WWs
rhoce          = 1d3                            ;;  rho_ce [m]
;;  Calculate k [m^(-1)]
k_ww           = krhoce/rhoce[0]
;;  Calculate ∂J ~ (k ∂B)/µo
djww           = jo_fac[0]*k_ww*dBww[0]

PRINT,';;  K_ww [m^(-1)]  = ', minmax(k_ww)
PRINT,';;  ∂J [µA m^(-2)] = ', minmax(djww)*1d6
;;  K_ww [m^(-1)]  =    0.00020000000   0.00080000000
;;  ∂J [µA m^(-2)] =       0.15915494      0.63661977


;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------


;;----------------------------------------------------------------------------------------
;;  Print out shock ramp durations
;;----------------------------------------------------------------------------------------

;;  2009-07-13 [1 Crossing]
tdate          = '2009-07-13'
t_ramp_ra0     = time_double(tdate[0]+'/'+['08:59:45.440','08:59:48.290'])
dt_0713_b_0    = MAX(t_ramp_ra0,/NAN) - MIN(t_ramp_ra0,/NAN)

;;  2009-07-21 [1 Crossing]
tdate          = '2009-07-21'
t_ramp_ra0     = time_double(tdate[0]+'/'+['19:24:47.704','19:24:49.509'])
dt_0721_c_0    = MAX(t_ramp_ra0,/NAN) - MIN(t_ramp_ra0,/NAN)

;;  2009-07-23 [3 Crossings]
tdate          = '2009-07-23'
t_ramp_ra0     = time_double(tdate[0]+'/'+['18:04:47.030','18:04:58.920'])
t_ramp_ra1     = time_double(tdate[0]+'/'+['18:07:07.340','18:07:08.100'])
t_ramp_ra2     = time_double(tdate[0]+'/'+['18:24:24.910','18:24:49.450'])
dt_0723_c_0    = MAX(t_ramp_ra0,/NAN) - MIN(t_ramp_ra0,/NAN)
dt_0723_c_1    = MAX(t_ramp_ra1,/NAN) - MIN(t_ramp_ra1,/NAN)
dt_0723_c_2    = MAX(t_ramp_ra2,/NAN) - MIN(t_ramp_ra2,/NAN)

;;  2009-09-05 [3 Crossings]
tdate          = '2009-09-05'
t_ramp_ra0     = time_double(tdate[0]+'/'+['16:11:32.910','16:11:33.800'])
t_ramp_ra1     = time_double(tdate[0]+'/'+['16:37:58.272','16:37:59.000'])
t_ramp_ra2     = time_double(tdate[0]+'/'+['16:54:31.240','16:54:33.120'])
dt_0905_c_0    = MAX(t_ramp_ra0,/NAN) - MIN(t_ramp_ra0,/NAN)
dt_0905_c_1    = MAX(t_ramp_ra1,/NAN) - MIN(t_ramp_ra1,/NAN)
dt_0905_c_2    = MAX(t_ramp_ra2,/NAN) - MIN(t_ramp_ra2,/NAN)

;;  2009-09-26 [1 Crossing]
tdate          = '2009-09-26'
t_ramp_ra0     = time_double(tdate[0]+'/'+['15:53:09.911','15:53:10.249'])
dt_0926_a_0    = MAX(t_ramp_ra0,/NAN) - MIN(t_ramp_ra0,/NAN)

;;  2011-10-24 [2 Crossings]
tdate          = '2011-10-24'
t_ramp_ra0     = time_double(tdate[0]+'/'+['18:31:56.880','18:31:57.290'])
t_ramp_ra1     = time_double(tdate[0]+'/'+['23:28:14.596','23:28:16.086'])
dt_1024_e_0    = MAX(t_ramp_ra0,/NAN) - MIN(t_ramp_ra0,/NAN)
dt_1024_e_1    = MAX(t_ramp_ra1,/NAN) - MIN(t_ramp_ra1,/NAN)

;;  Collect into one array
all_dt_sh      = [dt_0713_b_0[0],dt_0721_c_0[0],dt_0723_c_0[0],dt_0723_c_1[0],dt_0723_c_2[0],$
                  dt_0905_c_0[0],dt_0905_c_1[0],dt_0905_c_2[0],dt_0926_a_0[0],$
                  dt_1024_e_0[0],dt_1024_e_1[0] ]
mform          = '(";;",11f12.5)'
PRINT,all_dt_sh,FORMAT=mform
;;----------------------------------------------------------------------------------------------------------------------------------------
;;  All Dates [YYYY-MM-DD]
;;========================================================================================================================================
;;  2009-07-13  2009-07-21  2009-07-23  2009-07-23  2009-07-23  2009-09-05  2009-09-05  2009-09-05  2009-09-26  2011-10-24  2011-10-24
;;----------------------------------------------------------------------------------------------------------------------------------------
;;     2.85000     1.80500    11.89000     0.76000    24.54000     0.89000     0.72800     1.88000     0.33800     0.41000     1.49000
;;----------------------------------------------------------------------------------------------------------------------------------------



;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;;  Electron mass [kg]
mp             = 1.6726217770d-27     ;;  Proton mass [kg]
ma             = 6.6446567500d-27     ;;  Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;;  Speed of light in vacuum [m/s]
epo            = 8.8541878170d-12     ;;  Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;;  Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;;  Fundamental charge [C]
kB             = 1.3806488000d-23     ;;  Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;;  Planck Constant [J s]
GG             = 6.6738400000d-11     ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [J]
;;  Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K
R_E            = 6.37814d3            ;;  Earth's Equitorial Radius [km]
;;  Constant factors for frequencies
wpefac         = SQRT(1d6*qq[0]^2/(epo[0]*me[0]))
wpifac         = SQRT(1d6*qq[0]^2/(epo[0]*mp[0]))
wcefac         = 1d-9*qq[0]/me[0]
wcifac         = 1d-9*qq[0]/mp[0]
;;  Constant factors for thermal pressures
prefac         = 1d6*J_1eV[0]
;;  Constant factors for current densities
jo_fac         = 1d-9/muo[0]

;;  Define shock ramp durations [s]
all_dt_sh      = [2.850d0,1.805d0,11.890d0,0.760d0,24.540d0,0.890d0,0.728d0,1.880d0,0.338d0,0.410d0,1.490d0]
;;----------------------------------------------------------------------------------------
;;  Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init

.compile shock_enthalpy_rate
.compile read_thm_j_E_S_corr
.compile thm_load_bowshock_rhsolns
.compile thm_load_bowshock_ascii
.compile find_j2_eta_k_from_h
.compile temp_calc_j2_eta_k_S_from_h

.compile get_thm_entropy_diss_data
.compile temp_thm_entropy_diss_plots

;;  Compile critical Mach number routines
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/genarr.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/zbrent.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/crit_mf.pro
;;----------------------------------------------------------------------------------------
;;  Get ASCII data
;;----------------------------------------------------------------------------------------
thm_load_bowshock_ascii,R_STRUCT=Jo_dE_DS_corr
thm_load_bowshock_ascii,R_STRUCT=Jo_dE_US_corr,/UPSAMPLE
dummy          = get_thm_entropy_diss_data(/UPSAMPLE,JES_STR=Jo_dE_US_corr)

;;----------------------------------------------------------------------------------------
;;  Calculate relevant parameters
;;----------------------------------------------------------------------------------------
;;  Define smooth width
srate          = 8192d0
low_sps        = 128d0
smwidth        = ROUND(srate[0]/low_sps[0])*2L


nn             = N_TAGS(Jo_dE_US_corr.DATA)
gtags          = TAG_NAMES(Jo_dE_US_corr.DATA)
;;  Clean up beforehand to avoid copies or overwriting
DELVAR,temp,eta_iaw,eta_avg,eta_min,eta_max,all_eta
FOR j=0L, nn - 1L DO BEGIN                             $
  temp = Jo_dE_US_corr.DATA.(j)                      & $
  eta_iaw = temp.ETA_NIF_GSE[*,0]                    & $
  IF (j EQ 0) THEN eta_avg = MEAN(eta_iaw,/NAN) ELSE eta_avg = [eta_avg, MEAN(eta_iaw,/NAN)]  & $
  IF (j EQ 0) THEN eta_min =  MIN(eta_iaw,/NAN) ELSE eta_min = [eta_min,  MIN(eta_iaw,/NAN)]  & $
  IF (j EQ 0) THEN eta_max =  MAX(eta_iaw,/NAN) ELSE eta_max = [eta_max,  MAX(eta_iaw,/NAN)]  & $
  str_element,all_eta,gtags[j],eta_iaw,/ADD_REPLACE

;;  Clean up beforehand to avoid copies or overwriting
DELVAR,temp,jmag,stats,all_jmag,all_jstat
FOR j=0L, nn - 1L DO BEGIN                                                         $
  temp  = Jo_dE_US_corr.DATA.(j).J_VEC_NIF_NCB_SM                                & $
  tempx = SMOOTH(temp[*,0],smwidth[0],/EDGE_TRUNCATE,/NAN)                       & $
  tempy = SMOOTH(temp[*,1],smwidth[0],/EDGE_TRUNCATE,/NAN)                       & $
  tempz = SMOOTH(temp[*,2],smwidth[0],/EDGE_TRUNCATE,/NAN)                       & $
  temps = [[tempx],[tempy],[tempz]]                                              & $
  jmag  = SQRT(TOTAL(temps^2,2L,/NAN))                                           & $
  nj    = 1d0*N_ELEMENTS(jmag)                                                   & $
  stdv  = STDDEV(jmag,/NAN)                                                      & $
  stats = [MIN(jmag,/NAN),MAX(jmag,/NAN),MEAN(jmag,/NAN),stdv,stdv/SQRT(nj[0])]  & $
  str_element,all_jmag,gtags[j],jmag,/ADD_REPLACE                                & $
  str_element,all_jstat,gtags[j],stats,/ADD_REPLACE

;;  Clean up beforehand to avoid copies or overwriting
DELVAR,temp,jmag,eta0,stats,all_ejstat,all_etajo
FOR j=0L, nn - 1L DO BEGIN                                                         $
  jmag  = all_jmag.(j)                                                           & $
  eta0  = all_eta.(j)                                                            & $
  temp  = 1d-6*jmag*eta0                                                         & $
  nj    = 1d0*N_ELEMENTS(temp)                                                   & $
  stdv  = STDDEV(temp,/NAN)                                                      & $
  stats = [MIN(temp,/NAN),MAX(temp,/NAN),MEAN(temp,/NAN),stdv,stdv/SQRT(nj[0])]  & $
  str_element,all_ejstat,gtags[j],stats,/ADD_REPLACE                             & $
  str_element,all_etajo,gtags[j],temp,/ADD_REPLACE

;;  Clean up beforehand to avoid copies or overwriting
DELVAR,temp,Edjm,stdv,stats,all_Edjstat,all_Edj
FOR j=0L, nn - 1L DO BEGIN                                                         $
  temp  = Jo_dE_US_corr.DATA.(j).NEG_E_DOT_J_SM                                  & $
  nj    = 1d0*N_ELEMENTS(temp)                                                   & $
  Edjm  = ABS(temp)                                                              & $
  stdv  = STDDEV(Edjm,/NAN)                                                      & $
  stats = [MIN(Edjm,/NAN),MAX(Edjm,/NAN),MEAN(Edjm,/NAN),stdv,stdv/SQRT(nj[0])]  & $
  str_element,all_Edjstat,gtags[j],stats,/ADD_REPLACE                            & $
  str_element,all_Edj,gtags[j],temp,/ADD_REPLACE

;;  Clean up beforehand to avoid copies or overwriting
DELVAR,temp,csEj,dcsEj,stdv,stats,all_EdjCSstat,all_EdjCS,all_d_EdjCS
FOR j=0L, nn - 1L DO BEGIN                                                         $
  temp  = Jo_dE_US_corr.DATA.(j).NEG_E_DOT_J_SM                                  & $
  csEj  = TOTAL(temp,/NAN,/CUMULATIVE)                                           & $
  nj    = 1d0*N_ELEMENTS(temp)                                                   & $
  dcsEj = ABS(MAX(csEj,/NAN) - MIN(csEj,/NAN))                                   & $
  stdv  = STDDEV(csEj,/NAN)                                                      & $
  stats = [MIN(csEj,/NAN),MAX(csEj,/NAN),MEAN(csEj,/NAN),stdv,stdv/SQRT(nj[0])]  & $
  str_element,all_EdjCSstat,gtags[j],stats,/ADD_REPLACE                          & $
  str_element,all_EdjCS,gtags[j],csEj,/ADD_REPLACE                               & $
  str_element,all_d_EdjCS,gtags[j],dcsEj,/ADD_REPLACE


;;----------------------------------------------------------------------------------------
;;  Print Results
;;----------------------------------------------------------------------------------------
mform          = '(a9,11e14.3)'
line0          = ';;-------------------------------------------------------------------------------------------------------------------------------------------------------------------'
line1          = ';;                                                                           All Dates [YYYY-MM-DD]'
line2          = ';;==================================================================================================================================================================='
line3          = ';;           2009-07-13    2009-07-21    2009-07-23    2009-07-23    2009-07-23    2009-09-05    2009-09-05    2009-09-05    2009-09-26    2011-10-24    2011-10-24'


line_lab       = [';;  *eta [Ω m]']
nll            = N_ELEMENTS(line_lab) - 1L
FOR j=0L, 0L DO BEGIN                                $
  PRINT,line0[0]                                   & $
  FOR k=0L, nll DO PRINT,line_lab[k]               & $
  PRINT,line0[0]                                   & $
  PRINT,line1[0]                                   & $
  PRINT,line0[0]                                   & $
  PRINT,line3[0]                                   & $
  PRINT,line2[0]                                   & $
  PRINT, ';; Min = ', eta_min, FORMAT=mform        & $
  PRINT, ';; Max = ', eta_max, FORMAT=mform        & $
  PRINT, ';; Avg = ', eta_avg, FORMAT=mform        & $
  PRINT,line0[0]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  *eta [Ω m]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                                           All Dates [YYYY-MM-DD]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;           2009-07-13    2009-07-21    2009-07-23    2009-07-23    2009-07-23    2009-09-05    2009-09-05    2009-09-05    2009-09-26    2011-10-24    2011-10-24
;;===================================================================================================================================================================
;; Min =      2.613e-04     1.635e-03     1.785e-03     1.067e-03     6.421e-04     3.119e-05     3.091e-04     2.204e-04     6.524e-05     2.828e-04     3.006e-04
;; Max =      4.025e+03     9.378e+03     1.974e+03     3.976e+03     6.515e+03     3.831e+03     4.737e+03     4.762e+03     6.436e+03     5.908e+01     3.016e+02
;; Avg =      1.061e+01     8.315e+01     3.376e+00     2.441e+01     2.887e+01     2.441e+00     2.060e+01     2.272e+01     2.315e+01     6.910e-02     9.622e-01
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------

line_lab       = [';;  Jo [µA m^(-2)]']
nll            = N_ELEMENTS(line_lab) - 1L
FOR k=0L, 0L DO BEGIN                                               $
  FOR j=0L, nn - 1L DO BEGIN                                        $
    jstat = all_jstat.(j)                                         & $
    IF (j EQ 0) THEN jmin = jstat[0] ELSE jmin = [jmin,jstat[0]]  & $
    IF (j EQ 0) THEN jmax = jstat[1] ELSE jmax = [jmax,jstat[1]]  & $
    IF (j EQ 0) THEN javg = jstat[2] ELSE javg = [javg,jstat[2]]  & $
  ENDFOR                                                          & $
  PRINT,line0[0]                                                  & $
  FOR k=0L, nll DO PRINT,line_lab[k]                              & $
  PRINT,line0[0]                                                  & $
  PRINT,line1[0]                                                  & $
  PRINT,line0[0]                                                  & $
  PRINT,line3[0]                                                  & $
  PRINT,line2[0]                                                  & $
  PRINT, ';; Min = ', jmin, FORMAT=mform                          & $
  PRINT, ';; Max = ', jmax, FORMAT=mform                          & $
  PRINT, ';; Avg = ', javg, FORMAT=mform                          & $
  PRINT,line0[0]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  Jo [µA m^(-2)]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                                           All Dates [YYYY-MM-DD]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;           2009-07-13    2009-07-21    2009-07-23    2009-07-23    2009-07-23    2009-09-05    2009-09-05    2009-09-05    2009-09-26    2011-10-24    2011-10-24
;;===================================================================================================================================================================
;; Min =      4.259e-04     5.352e-03     1.782e-03     2.176e-02     6.995e-03     6.000e-04     1.314e-03     1.521e-02     2.061e-03     2.435e-03     1.641e-02
;; Max =      2.935e+00     3.245e+00     4.486e+00     6.351e+01     6.098e+00     1.056e+00     6.288e-01     5.220e+01     1.388e+01     5.285e+00     4.255e+01
;; Avg =      4.773e-01     7.679e-01     1.126e+00     7.847e+00     1.467e+00     2.141e-01     1.451e-01     1.389e+01     1.259e+00     6.546e-01     5.207e+00
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------

line_lab       = [';;  *eta Jo [mV m^(-1)]']
nll            = N_ELEMENTS(line_lab) - 1L
FOR k=0L, 0L DO BEGIN                                               $
  FOR j=0L, nn - 1L DO BEGIN                                        $
    jstat = all_ejstat.(j)*1d3                                    & $
    IF (j EQ 0) THEN jmin = jstat[0] ELSE jmin = [jmin,jstat[0]]  & $
    IF (j EQ 0) THEN jmax = jstat[1] ELSE jmax = [jmax,jstat[1]]  & $
    IF (j EQ 0) THEN javg = jstat[2] ELSE javg = [javg,jstat[2]]  & $
  ENDFOR                                                          & $
  PRINT,line0[0]                                                  & $
  FOR k=0L, nll DO PRINT,line_lab[k]                              & $
  PRINT,line0[0]                                                  & $
  PRINT,line1[0]                                                  & $
  PRINT,line0[0]                                                  & $
  PRINT,line3[0]                                                  & $
  PRINT,line2[0]                                                  & $
  PRINT, ';; Min = ', jmin, FORMAT=mform                          & $
  PRINT, ';; Max = ', jmax, FORMAT=mform                          & $
  PRINT, ';; Avg = ', javg, FORMAT=mform                          & $
  PRINT,line0[0]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  *eta Jo [mV m^(-1)]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                                           All Dates [YYYY-MM-DD]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;           2009-07-13    2009-07-21    2009-07-23    2009-07-23    2009-07-23    2009-09-05    2009-09-05    2009-09-05    2009-09-26    2011-10-24    2011-10-24
;;===================================================================================================================================================================
;; Min =      2.234e-08     9.944e-07     1.239e-06     2.659e-06     2.378e-07     5.759e-09     1.140e-08     2.159e-06     1.583e-08     1.732e-08     8.251e-07
;; Max =      1.770e+00     1.266e+01     2.991e+00     3.902e+01     7.351e+00     2.045e+00     6.812e-01     1.068e+02     3.582e+01     6.573e-02     6.059e+00
;; Avg =      6.027e-03     8.339e-02     4.181e-03     2.823e-01     4.283e-02     6.154e-04     3.604e-03     3.388e-01     5.402e-02     5.598e-05     9.021e-03
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------


line_lab       = [';;  |Jo . ∂E| [µW m^(-3)]']
nll            = N_ELEMENTS(line_lab) - 1L
FOR k=0L, 0L DO BEGIN                                               $
  FOR j=0L, nn - 1L DO BEGIN                                        $
    jstat = all_Edjstat.(j)                                       & $
    IF (j EQ 0) THEN jmin = jstat[0] ELSE jmin = [jmin,jstat[0]]  & $
    IF (j EQ 0) THEN jmax = jstat[1] ELSE jmax = [jmax,jstat[1]]  & $
    IF (j EQ 0) THEN javg = jstat[2] ELSE javg = [javg,jstat[2]]  & $
  ENDFOR                                                          & $
  PRINT,line0[0]                                                  & $
  FOR k=0L, nll DO PRINT,line_lab[k]                              & $
  PRINT,line0[0]                                                  & $
  PRINT,line1[0]                                                  & $
  PRINT,line0[0]                                                  & $
  PRINT,line3[0]                                                  & $
  PRINT,line2[0]                                                  & $
  PRINT, ';; Min = ', jmin, FORMAT=mform                          & $
  PRINT, ';; Max = ', jmax, FORMAT=mform                          & $
  PRINT, ';; Avg = ', javg, FORMAT=mform                          & $
  PRINT,line0[0]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  |Jo . ∂E| [µW m^(-3)]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                                           All Dates [YYYY-MM-DD]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;           2009-07-13    2009-07-21    2009-07-23    2009-07-23    2009-07-23    2009-09-05    2009-09-05    2009-09-05    2009-09-26    2011-10-24    2011-10-24
;;===================================================================================================================================================================
;; Min =      4.881e-09     5.913e-08     9.187e-08     3.379e-07     4.605e-09    -0.000e+00    -0.000e+00    -0.000e+00     2.492e-09     2.098e-09     1.530e-07
;; Max =      4.056e-01     4.170e-01     1.978e-01     5.490e+00     6.631e-01     1.726e-01     4.773e-02     5.815e+00     2.622e+00     1.949e-01     1.079e+01
;; Avg =      3.936e-03     8.033e-03     6.103e-03     7.616e-02     1.030e-02     5.294e-04     5.987e-04     5.670e-02     1.409e-02     2.213e-03     7.843e-02
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------


line_lab       = [';;  ∑ [-(Jo . ∂E)] [µW m^(-3)]',';;  [cumulative sum of -(Jo . ∂E)]']
nll            = N_ELEMENTS(line_lab) - 1L
FOR k=0L, 0L DO BEGIN                                               $
  FOR j=0L, nn - 1L DO BEGIN                                        $
    jstat = all_EdjCSstat.(j)                                     & $
    IF (j EQ 0) THEN jmin = jstat[0] ELSE jmin = [jmin,jstat[0]]  & $
    IF (j EQ 0) THEN jmax = jstat[1] ELSE jmax = [jmax,jstat[1]]  & $
    IF (j EQ 0) THEN javg = jstat[2] ELSE javg = [javg,jstat[2]]  & $
  ENDFOR                                                          & $
  PRINT,line0[0]                                                  & $
  FOR k=0L, nll DO PRINT,line_lab[k]                              & $
  PRINT,line0[0]                                                  & $
  PRINT,line1[0]                                                  & $
  PRINT,line0[0]                                                  & $
  PRINT,line3[0]                                                  & $
  PRINT,line2[0]                                                  & $
  PRINT, ';; Min = ', jmin, FORMAT=mform                          & $
  PRINT, ';; Max = ', jmax, FORMAT=mform                          & $
  PRINT, ';; Avg = ', javg, FORMAT=mform                          & $
  PRINT,line0[0]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  ∑ [-(Jo . ∂E)] [µW m^(-3)]
;;  [cumulative sum of -(Jo . ∂E)]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                                           All Dates [YYYY-MM-DD]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;           2009-07-13    2009-07-21    2009-07-23    2009-07-23    2009-07-23    2009-09-05    2009-09-05    2009-09-05    2009-09-26    2011-10-24    2011-10-24
;;===================================================================================================================================================================
;; Min =     -3.178e+00    -8.180e-01     2.110e-03    -1.226e+03    -3.654e+01    -2.273e+00    -5.082e-01    -9.345e+01    -1.830e+02     2.373e-03    -8.447e+00
;; Max =      1.077e+01     1.902e+01     1.676e+02     3.005e+01     3.936e+01     1.478e+00     1.614e+00     2.860e+01     1.092e+01     3.217e+01     4.206e+03
;; Avg =      6.759e+00     9.196e+00     8.622e+01    -9.151e+02     2.101e+00    -3.957e-01     8.240e-01    -2.520e+01    -6.329e+01     1.056e+01     3.085e+03
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------


line_lab       = [';;  ∑ [-(Jo . ∂E)] [µW m^(-3)]',';;  [Max change in cumulative sum of -(Jo . ∂E)]']
nll            = N_ELEMENTS(line_lab) - 1L
FOR k=0L, 0L DO BEGIN                                               $
  FOR j=0L, nn - 1L DO BEGIN                                        $
    jstat = all_d_EdjCS.(j)                                       & $
    IF (j EQ 0) THEN jmin = jstat[0] ELSE jmin = [jmin,jstat[0]]  & $
  ENDFOR                                                          & $
  PRINT,line0[0]                                                  & $
  FOR k=0L, nll DO PRINT,line_lab[k]                              & $
  PRINT,line0[0]                                                  & $
  PRINT,line1[0]                                                  & $
  PRINT,line0[0]                                                  & $
  PRINT,line3[0]                                                  & $
  PRINT,line2[0]                                                  & $
  PRINT, ';; Dif = ', jmin, FORMAT=mform                          & $
  PRINT,line0[0]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;  ∑ [-(Jo . ∂E)] [µW m^(-3)]
;;  [Max change in cumulative sum of -(Jo . ∂E)]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;                                                                           All Dates [YYYY-MM-DD]
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;           2009-07-13    2009-07-21    2009-07-23    2009-07-23    2009-07-23    2009-09-05    2009-09-05    2009-09-05    2009-09-26    2011-10-24    2011-10-24
;;===================================================================================================================================================================
;; Dif =      1.395e+01     1.984e+01     1.676e+02     1.256e+03     7.591e+01     3.751e+00     2.122e+00     1.221e+02     1.939e+02     3.216e+01     4.215e+03
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------


;;  Define shock ramp durations [s]
all_dt_sh      = [2.850d0,1.805d0,11.890d0,0.760d0,24.540d0,0.890d0,0.728d0,1.880d0,0.338d0,0.410d0,1.490d0]

;;  Max. change in cumulative sum of -(Jo . ∂E), Max[∑-(Jo . ∂E)] [µW m^(-3)]
mx_diff_jdE_CS = [13.94552d0,19.83608d0,167.59275d0,1256.28367d0,75.90638d0,3.75141d0,2.12250d0,122.05268d0,193.87922d0,32.16489d0,4214.90726d0]

;;  Avg. change in the bulk flow kinetic energy density across the shock, ∆KE [µJ m^(-3)]
avg_dKE_obs    = [3.87173d-4,1.74273d-4,4.27273d-4,5.75035d-4,3.54634d-4,1.04612d-4,8.56756d-5,2.19918d-4,6.87590d-4,2.40040d-3,1.80037d-3]

;;  Define ∆KE/∆t [µW m^(-3)]
avg_dKE__dt    = avg_dKE_obs/all_dt_sh

;;  Define ratio of Max[∑-(Jo . ∂E)] to ∆KE/∆t [unitless]
rat_mxdf_dKdt  = mx_diff_jdE_CS/avg_dKE__dt




















































































mform          = '(";;",11e14.3)'
line0          = ';;------------------------------------------------------------------------------------------------------------------------------------------------------------'
line1          = ';;                                                                    All Dates [YYYY-MM-DD]'
line2          = ';;============================================================================================================================================================'
line3          = ';;    2009-07-13    2009-07-21    2009-07-23    2009-07-23    2009-07-23    2009-09-05    2009-09-05    2009-09-05    2009-09-26    2011-10-24    2011-10-24'


line_lab       = ';;  *eta [Ω m]'
FOR j=0L, 0L DO BEGIN                                $
  IF (j EQ 0) THEN PRINT,line0[0]                  & $
  IF (j EQ 0) THEN PRINT,line_lab[0]               & $
  IF (j EQ 0) THEN PRINT,line0[0]                  & $
  IF (j EQ 0) THEN PRINT,line1[0]                  & $
  IF (j EQ 0) THEN PRINT,line0[0]                  & $
  IF (j EQ 0) THEN PRINT,line3[0]                  & $
  IF (j EQ 0) THEN PRINT,line2[0]                  & $
  IF (j EQ 0) THEN PRINT, eta_min, FORMAT=mform    & $
  IF (j EQ 0) THEN PRINT, eta_max, FORMAT=mform    & $
  IF (j EQ 0) THEN PRINT, eta_avg, FORMAT=mform    & $
  IF (j EQ 0) THEN PRINT,line0[0]







