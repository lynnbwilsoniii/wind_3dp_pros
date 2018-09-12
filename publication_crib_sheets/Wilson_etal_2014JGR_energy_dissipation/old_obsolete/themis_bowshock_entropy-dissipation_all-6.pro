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
ckm            = c[0]*1d-3            ;;  m --> km
;;  Setup margins
!X.MARGIN      = [15,5]
!Y.MARGIN      = [8,4]
;;----------------------------------------------------------------------------------------
;; => Compile necessary routines
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
;;  Plot relevant data
;;----------------------------------------------------------------------------------------
temp_thm_entropy_diss_plots



;;----------------------------------------------------------------------------------------
;;  Print RH solutions
;;----------------------------------------------------------------------------------------
.compile temp_thm_print_rh_soln
temp_thm_print_rh_soln



;;---------------------------------------------------------------------------------------------------------------------------------
;;  All Dates [YYYY-MM-DD]
;;=================================================================================================================================
;;  2009-09-26  2009-07-13  2009-07-21  2009-07-23  2009-07-23  2009-07-23  2011-10-24  2011-10-24
;;---------------------------------------------------------------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------------------------------------
;;  Vshn [SCF, Upstream, km/s]
;;=================================================================================================================================
;;      -52.770     -31.374     -62.207      13.871     -33.930      26.235     -58.924     -37.142
;;        8.731      34.183      24.454      22.547      44.366      52.313      47.055      22.200
;;---------------------------------------------------------------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------------------------------------
;;  Ushn [SHF, Upstream, km/s]
;;=================================================================================================================================
;;     -271.853    -193.823    -423.046    -506.468    -415.525    -335.993    -358.124    -367.712
;;       10.936      37.862      25.720      21.842      42.830      52.654      53.587      26.191
;;---------------------------------------------------------------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------------------------------------
;;  Ushn [SHF, Downstream, km/s]
;;=================================================================================================================================
;;      -41.226     -54.940    -103.101    -138.108    -151.381     -83.999    -120.805     -77.372
;;        5.205      15.591       7.697      10.703      30.255      27.801      27.525       6.538
;;---------------------------------------------------------------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------------------------------------
;;  Mf [SHF, Upstream, unitless]
;;=================================================================================================================================
;;      3.06729     2.03583     3.03343     3.62412     3.10535     4.83688     2.21798     2.32672
;;      0.15615     0.41922     0.18992     0.16500     0.32570     0.79405     0.33438     0.16610
;;---------------------------------------------------------------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------------------------------------
;;  Ni2/Ni1 [Compression Ratio, unitless]
;;=================================================================================================================================
;;      6.62680     3.60033     4.11909     3.67718     2.80771     4.19617     3.01825     4.76260
;;      0.65900     0.48734     0.35758     0.18160     0.39190     0.71022     0.37793     0.24146
;;---------------------------------------------------------------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------------------------------------
;;  theta_Bn [Shock Normal Angles, deg]
;;=================================================================================================================================
;;     42.27223    56.64812    87.54214    87.74427    56.18872    53.93460    85.01427    87.64858
;;      5.68806     5.39487     1.45156     1.50778     3.52866    10.15629     2.91617     1.32218
;;---------------------------------------------------------------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------------------------------------
;;  Mcr [Edmiston&Kennel, 1984]
;;=================================================================================================================================
;;      2.31224     2.52822     2.76046     2.76064     2.52468     2.48020     2.75505     2.76063
;;      0.09370     0.07084     0.00194     0.00177     0.04727     0.12809     0.00772     0.00141
;;---------------------------------------------------------------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------------------------------------
;;  Mw  [Krasnoselskikh et al., 2002]
;;=================================================================================================================================
;;     15.77948    11.72916     0.91850     0.84299    11.90051    12.43196     1.85936     0.87882
;;      1.46444     1.67580     0.54192     0.56311     1.08817     3.19082     1.08363     0.49390
;;---------------------------------------------------------------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------------------------------------
;;  Mgr [Krasnoselskikh et al., 2002]
;;=================================================================================================================================
;;     20.49815    15.23663     1.19316     1.09508    15.45921    16.14959     2.41538     1.14161
;;      1.90236     2.17692     0.70398     0.73150     1.41357     4.14499     1.40767     0.64160
;;---------------------------------------------------------------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------------------------------------
;;  Mnw [Krasnoselskikh et al., 2002]
;;=================================================================================================================================
;;     22.31556    16.58754     1.29895     1.19217    16.82986    17.58145     2.62953     1.24283
;;      2.07103     2.36993     0.76640     0.79635     1.53890     4.51250     1.53248     0.69848
;;---------------------------------------------------------------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------------------------------------
;;  Mf/Mcr [SHF, Upstream, unitless]
;;=================================================================================================================================
;;      1.32655     0.80524     1.09889     1.31278     1.23000     1.95019     0.80506     0.84282
;;      0.08632     0.16734     0.06880     0.05978     0.13105     0.33562     0.12139     0.06017
;;---------------------------------------------------------------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------------------------------------
;;  Mf/Mw  [SHF, Upstream, unitless]
;;=================================================================================================================================
;;      0.19439     0.17357     3.30260     4.29912     0.26094     0.38907     1.19287     2.64756
;;      0.02058     0.04350     1.95952     2.87842     0.03631     0.11854     0.71808     1.49991
;;---------------------------------------------------------------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------------------------------------
;;  Mf/Mgr [SHF, Upstream, unitless]
;;=================================================================================================================================
;;      0.14964     0.13361     2.54235     3.30946     0.20087     0.29950     0.91827     2.03810
;;      0.01584     0.03349     1.50844     2.21581     0.02795     0.09125     0.55278     1.15463
;;---------------------------------------------------------------------------------------------------------------------------------

;;---------------------------------------------------------------------------------------------------------------------------------
;;  Mf/Mnw [SHF, Upstream, unitless]
;;=================================================================================================================================
;;      0.13745     0.12273     2.33529     3.03994     0.18451     0.27511     0.84349     1.87211
;;      0.01455     0.03076     1.38559     2.03535     0.02567     0.08382     0.50776     1.06060
;;---------------------------------------------------------------------------------------------------------------------------------





























;;----------------------------------------------------------------------------------------
;;  Get relevant data
;;----------------------------------------------------------------------------------------
thm_load_bowshock_rhsolns,R_STRUCT=diss_rates
thm_load_bowshock_ascii,R_STRUCT=j_E_S_corr
j_E_S_data     = j_E_S_corr.DATA

out_diss_all   = temp_calc_j2_eta_k_S_from_h()

WINDOW,1,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Energy Dissipation 1'



all_ns         = j_E_S_corr.NUM
n_cross        = N_TAGS(all_ns)
nind           = LINDGEN(n_cross)
xyout_cols     = nind*(250L - 30L)/(n_cross - 1L) + 30L   ;; colors for XYOUTS

FOR j=0L, n_cross - 1L DO PRINT,';; ', all_ns.(j)
;;         1648
;;         3376
;;          816
;;          816
;;         1648
;;         1648

n_pts          = 0L
FOR j=0L, n_cross - 1L DO n_pts += all_ns.(j)
PRINT,';; ', n_cross, n_pts
;;            6        9952


;;----------------------------------------------------------------------------------------
;;  Define Rankine-Hugoniot relation solutions
;;----------------------------------------------------------------------------------------
shockRH_0713_0 = diss_rates.(0).SHOCK
shockRH_0721_0 = diss_rates.(1).SHOCK
shockRH_0723_0 = diss_rates.(2).SHOCK
shockRH_0723_1 = diss_rates.(3).SHOCK
shockRH_0723_2 = diss_rates.(4).SHOCK
shockRH_0926_0 = diss_rates.(5).SHOCK
;;  Define shock normal speed, Vshn [SCF, km/s]
vshn____0713_0 = shockRH_0713_0.VSHN[0]
vshn____0721_0 = shockRH_0721_0.VSHN[0]
vshn____0723_0 = shockRH_0723_0.VSHN[0]
vshn____0723_1 = shockRH_0723_1.VSHN[0]
vshn____0723_2 = shockRH_0723_2.VSHN[0]
vshn____0926_0 = shockRH_0926_0.VSHN[0]
;;  Define upstream average number density, <Ni>_{up} [SCF, cm^(-3)]
ni_up___0713_0 = MEAN(diss_rates.(0).UP.NI,/NAN)
ni_up___0721_0 = MEAN(diss_rates.(1).UP.NI,/NAN)
ni_up___0723_0 = MEAN(diss_rates.(2).UP.NI,/NAN)
ni_up___0723_1 = MEAN(diss_rates.(3).UP.NI,/NAN)
ni_up___0723_2 = MEAN(diss_rates.(4).UP.NI,/NAN)
ni_up___0926_0 = MEAN(diss_rates.(5).UP.NI,/NAN)
;;  Define upstream average ion inertial length, <Li>_{up} [SCF, km]
Li_up___0713_0 = ckm[0]/(wpifac[0]*SQRT(ni_up___0713_0[0]))
Li_up___0721_0 = ckm[0]/(wpifac[0]*SQRT(ni_up___0721_0[0]))
Li_up___0723_0 = ckm[0]/(wpifac[0]*SQRT(ni_up___0723_0[0]))
Li_up___0723_1 = ckm[0]/(wpifac[0]*SQRT(ni_up___0723_1[0]))
Li_up___0723_2 = ckm[0]/(wpifac[0]*SQRT(ni_up___0723_2[0]))
Li_up___0926_0 = ckm[0]/(wpifac[0]*SQRT(ni_up___0926_0[0]))
;;  Define ramp time center, t_o (Unix)
trampcn_0713_0 = MEAN(shockRH_0713_0.TRAMP,/NAN)
trampcn_0721_0 = MEAN(shockRH_0721_0.TRAMP,/NAN)
trampcn_0723_0 = MEAN(shockRH_0723_0.TRAMP,/NAN)
trampcn_0723_1 = MEAN(shockRH_0723_1.TRAMP,/NAN)
trampcn_0723_2 = MEAN(shockRH_0723_2.TRAMP,/NAN)
trampcn_0926_0 = MEAN(shockRH_0926_0.TRAMP,/NAN)
;;  Define timestamps, t_j, for |j|^2, |S(w,k)|, etc. (Unix)
unix____0713_0 = j_E_S_data.(0).UNIX
unix____0721_0 = j_E_S_data.(1).UNIX
unix____0723_0 = j_E_S_data.(2).UNIX
unix____0723_1 = j_E_S_data.(3).UNIX
unix____0723_2 = j_E_S_data.(4).UNIX
unix____0926_0 = j_E_S_data.(5).UNIX
;;  Define ∆t_j = t_j - t_o [s]
delta_t_0713_0 = unix____0713_0 - trampcn_0713_0[0]
delta_t_0721_0 = unix____0721_0 - trampcn_0721_0[0]
delta_t_0723_0 = unix____0723_0 - trampcn_0723_0[0]
delta_t_0723_1 = unix____0723_1 - trampcn_0723_1[0]
delta_t_0723_2 = unix____0723_2 - trampcn_0723_2[0]
delta_t_0926_0 = unix____0926_0 - trampcn_0926_0[0]
;;  Define ∆xn_j = |Vshn| * ∆t_j [km]
del_xn_0713_0  = delta_t_0713_0*ABS(vshn____0713_0[0])
del_xn_0721_0  = delta_t_0721_0*ABS(vshn____0721_0[0])
del_xn_0723_0  = delta_t_0723_0*ABS(vshn____0723_0[0])
del_xn_0723_1  = delta_t_0723_1*ABS(vshn____0723_1[0])
del_xn_0723_2  = delta_t_0723_2*ABS(vshn____0723_2[0])
del_xn_0926_0  = delta_t_0926_0*ABS(vshn____0926_0[0])
;;  Define j  [µA m^(-2)]
jnifncb_0713_0 = j_E_S_data.(0).J_VEC_NIF_NCB_SM
jnifncb_0721_0 = j_E_S_data.(1).J_VEC_NIF_NCB_SM
jnifncb_0723_0 = j_E_S_data.(2).J_VEC_NIF_NCB_SM
jnifncb_0723_1 = j_E_S_data.(3).J_VEC_NIF_NCB_SM
jnifncb_0723_2 = j_E_S_data.(4).J_VEC_NIF_NCB_SM
jnifncb_0926_0 = j_E_S_data.(5).J_VEC_NIF_NCB_SM
;;  Define (*eta* |j|^2)  [IAWs, µW m^(-3)]
etajsqn_0713_0 = j_E_S_data.(0).ETA_JSQ_NIF[*,0]
etajsqn_0721_0 = j_E_S_data.(1).ETA_JSQ_NIF[*,0]
etajsqn_0723_0 = j_E_S_data.(2).ETA_JSQ_NIF[*,0]
etajsqn_0723_1 = j_E_S_data.(3).ETA_JSQ_NIF[*,0]
etajsqn_0723_2 = j_E_S_data.(4).ETA_JSQ_NIF[*,0]
etajsqn_0926_0 = j_E_S_data.(5).ETA_JSQ_NIF[*,0]
;;  Define |S(w,k)|  [µW m^(-2)]
Spow_0713_0    = j_E_S_data.(0).S_POW_NIF_GSE_JT
Spow_0721_0    = j_E_S_data.(1).S_POW_NIF_GSE_JT
Spow_0723_0    = j_E_S_data.(2).S_POW_NIF_GSE_JT
Spow_0723_1    = j_E_S_data.(3).S_POW_NIF_GSE_JT
Spow_0723_2    = j_E_S_data.(4).S_POW_NIF_GSE_JT
Spow_0926_0    = j_E_S_data.(5).S_POW_NIF_GSE_JT
;;  Define Sn  [µW m^(-2)]
Sn___0713_0    = j_E_S_data.(0).S_DOT_N_N_NIF_GSE  ;;  [N,3]-Element array
Sn___0721_0    = j_E_S_data.(1).S_DOT_N_N_NIF_GSE  ;;  [N,3]-Element array
Sn___0723_0    = j_E_S_data.(2).S_DOT_N_N_NIF_GSE  ;;  [N,3]-Element array
Sn___0723_1    = j_E_S_data.(3).S_DOT_N_N_NIF_GSE  ;;  [N,3]-Element array
Sn___0723_2    = j_E_S_data.(4).S_DOT_N_N_NIF_GSE  ;;  [N,3]-Element array
Sn___0926_0    = j_E_S_data.(5).S_DOT_N_N_NIF_GSE  ;;  [N,3]-Element array
;;  Define St  [µW m^(-2)]
St___0713_0    = j_E_S_data.(0).N_X_S_X_N_NIF_GSE  ;;  [N,3]-Element array
St___0721_0    = j_E_S_data.(1).N_X_S_X_N_NIF_GSE  ;;  [N,3]-Element array
St___0723_0    = j_E_S_data.(2).N_X_S_X_N_NIF_GSE  ;;  [N,3]-Element array
St___0723_1    = j_E_S_data.(3).N_X_S_X_N_NIF_GSE  ;;  [N,3]-Element array
St___0723_2    = j_E_S_data.(4).N_X_S_X_N_NIF_GSE  ;;  [N,3]-Element array
St___0926_0    = j_E_S_data.(5).N_X_S_X_N_NIF_GSE  ;;  [N,3]-Element array
;;  Define ∂B  [SCF in GSE basis, nT]
Bscfgse_0713_0 = j_E_S_data.(0).B_VEC_SCF_GSE_JT
Bscfgse_0721_0 = j_E_S_data.(1).B_VEC_SCF_GSE_JT
Bscfgse_0723_0 = j_E_S_data.(2).B_VEC_SCF_GSE_JT
Bscfgse_0723_1 = j_E_S_data.(3).B_VEC_SCF_GSE_JT
Bscfgse_0723_2 = j_E_S_data.(4).B_VEC_SCF_GSE_JT
Bscfgse_0926_0 = j_E_S_data.(5).B_VEC_SCF_GSE_JT
;;  Define ∂E  [NIF in GSE basis, mV/m]
Enifgse_0713_0 = j_E_S_data.(0).E_VEC_NIF_GSE_JT
Enifgse_0721_0 = j_E_S_data.(1).E_VEC_NIF_GSE_JT
Enifgse_0723_0 = j_E_S_data.(2).E_VEC_NIF_GSE_JT
Enifgse_0723_1 = j_E_S_data.(3).E_VEC_NIF_GSE_JT
Enifgse_0723_2 = j_E_S_data.(4).E_VEC_NIF_GSE_JT
Enifgse_0926_0 = j_E_S_data.(5).E_VEC_NIF_GSE_JT
;;----------------------------------------------------------------------------------------
;;  Calculate parameters from definitions
;;----------------------------------------------------------------------------------------
;;  Calculate |j|^2  [A^(2) m^(-4)]
jsqrnif_0713_0 = TOTAL((jnifncb_0713_0*1d-6)^2,2L,/NAN)
jsqrnif_0721_0 = TOTAL((jnifncb_0721_0*1d-6)^2,2L,/NAN)
jsqrnif_0723_0 = TOTAL((jnifncb_0723_0*1d-6)^2,2L,/NAN)
jsqrnif_0723_1 = TOTAL((jnifncb_0723_1*1d-6)^2,2L,/NAN)
jsqrnif_0723_2 = TOTAL((jnifncb_0723_2*1d-6)^2,2L,/NAN)
jsqrnif_0926_0 = TOTAL((jnifncb_0926_0*1d-6)^2,2L,/NAN)
;;  Define *eta*  [IAWs, Ω m]
etanif__0713_0 = (etajsqn_0713_0*1d-6)/jsqrnif_0713_0
etanif__0721_0 = (etajsqn_0721_0*1d-6)/jsqrnif_0721_0
etanif__0723_0 = (etajsqn_0723_0*1d-6)/jsqrnif_0723_0
etanif__0723_1 = (etajsqn_0723_1*1d-6)/jsqrnif_0723_1
etanif__0723_2 = (etajsqn_0723_2*1d-6)/jsqrnif_0723_2
etanif__0926_0 = (etajsqn_0926_0*1d-6)/jsqrnif_0926_0
;;  Calculate |Sn|  [µW m^(-2)]
Sn_mag_0713_0  = SQRT(TOTAL(Sn___0713_0^2,2L,/NAN))
Sn_mag_0721_0  = SQRT(TOTAL(Sn___0721_0^2,2L,/NAN))
Sn_mag_0723_0  = SQRT(TOTAL(Sn___0723_0^2,2L,/NAN))
Sn_mag_0723_1  = SQRT(TOTAL(Sn___0723_1^2,2L,/NAN))
Sn_mag_0723_2  = SQRT(TOTAL(Sn___0723_2^2,2L,/NAN))
Sn_mag_0926_0  = SQRT(TOTAL(Sn___0926_0^2,2L,/NAN))
;;  Calculate |St|  [µW m^(-2)]
St_mag_0713_0  = SQRT(TOTAL(St___0713_0^2,2L,/NAN))
St_mag_0721_0  = SQRT(TOTAL(St___0721_0^2,2L,/NAN))
St_mag_0723_0  = SQRT(TOTAL(St___0723_0^2,2L,/NAN))
St_mag_0723_1  = SQRT(TOTAL(St___0723_1^2,2L,/NAN))
St_mag_0723_2  = SQRT(TOTAL(St___0723_2^2,2L,/NAN))
St_mag_0926_0  = SQRT(TOTAL(St___0926_0^2,2L,/NAN))
;;  Calculate |∂B|^2/(2 µ_o)  [µW m^(-3)]
B_E_fac        = (1d-9)^2*1d6/(2d0*muo[0])
B_E_gse_0713_0 = TOTAL(Bscfgse_0713_0^2,2L,/NAN)*B_E_fac[0]
B_E_gse_0721_0 = TOTAL(Bscfgse_0721_0^2,2L,/NAN)*B_E_fac[0]
B_E_gse_0723_0 = TOTAL(Bscfgse_0723_0^2,2L,/NAN)*B_E_fac[0]
B_E_gse_0723_1 = TOTAL(Bscfgse_0723_1^2,2L,/NAN)*B_E_fac[0]
B_E_gse_0723_2 = TOTAL(Bscfgse_0723_2^2,2L,/NAN)*B_E_fac[0]
B_E_gse_0926_0 = TOTAL(Bscfgse_0926_0^2,2L,/NAN)*B_E_fac[0]
;;  Calculate ∑_o |∂E|^2/2    [µW m^(-3)]
E_E_fac        = (1d-3)^2*1d6*epo[0]/2d0
E_E_gse_0713_0 = TOTAL(Enifgse_0713_0^2,2L,/NAN)*E_E_fac[0]
E_E_gse_0721_0 = TOTAL(Enifgse_0721_0^2,2L,/NAN)*E_E_fac[0]
E_E_gse_0723_0 = TOTAL(Enifgse_0723_0^2,2L,/NAN)*E_E_fac[0]
E_E_gse_0723_1 = TOTAL(Enifgse_0723_1^2,2L,/NAN)*E_E_fac[0]
E_E_gse_0723_2 = TOTAL(Enifgse_0723_2^2,2L,/NAN)*E_E_fac[0]
E_E_gse_0926_0 = TOTAL(Enifgse_0926_0^2,2L,/NAN)*E_E_fac[0]
;;----------------------------------------------------------------------------------------
;;  Look at ratio R = ∆¥/(*eta* |j|^2)
;;    = ratio of enthalpy change to ohmic dissipation rate estimate
;;    If R < 1 => waves provide more energy dissipation than necessary to maintain shock
;;----------------------------------------------------------------------------------------
outdiss_0713_0 = out_diss_all.(0)
outdiss_0721_0 = out_diss_all.(1)
outdiss_0723_0 = out_diss_all.(2)
outdiss_0723_1 = out_diss_all.(3)
outdiss_0723_2 = out_diss_all.(4)
outdiss_0926_0 = out_diss_all.(5)
;;  use specific enthalpy density change
dhdtstr_0713_0 = outdiss_0713_0.DH_DT
dhdtstr_0721_0 = outdiss_0721_0.DH_DT
dhdtstr_0723_0 = outdiss_0723_0.DH_DT
dhdtstr_0723_1 = outdiss_0723_1.DH_DT
dhdtstr_0723_2 = outdiss_0723_2.DH_DT
dhdtstr_0926_0 = outdiss_0926_0.DH_DT
;;  Define |j|^2 = ∆¥/*eta*  [A^(2) m^(-4)]
;;    => Compare to measured/estimated value
jsq_eta_0713_0 = dhdtstr_0713_0.J_SQR_FROM_ETA
jsq_eta_0721_0 = dhdtstr_0721_0.J_SQR_FROM_ETA
jsq_eta_0723_0 = dhdtstr_0723_0.J_SQR_FROM_ETA
jsq_eta_0723_1 = dhdtstr_0723_1.J_SQR_FROM_ETA
jsq_eta_0723_2 = dhdtstr_0723_2.J_SQR_FROM_ETA
jsq_eta_0926_0 = dhdtstr_0926_0.J_SQR_FROM_ETA
;;  Define *eta* = ∆¥/|j|^2  [Ω m]
;;    => Compare to measured/estimated value
etafjsq_0713_0 = dhdtstr_0713_0.ETA_FROM_JSQR
etafjsq_0721_0 = dhdtstr_0721_0.ETA_FROM_JSQR
etafjsq_0723_0 = dhdtstr_0723_0.ETA_FROM_JSQR
etafjsq_0723_1 = dhdtstr_0723_1.ETA_FROM_JSQR
etafjsq_0723_2 = dhdtstr_0723_2.ETA_FROM_JSQR
etafjsq_0926_0 = dhdtstr_0926_0.ETA_FROM_JSQR
;;  Define |k| = ∆¥/|S(w,k)|  [km]
kmag_S__0713_0 = dhdtstr_0713_0.KMAG_FROM_SPOW
kmag_S__0721_0 = dhdtstr_0721_0.KMAG_FROM_SPOW
kmag_S__0723_0 = dhdtstr_0723_0.KMAG_FROM_SPOW
kmag_S__0723_1 = dhdtstr_0723_1.KMAG_FROM_SPOW
kmag_S__0723_2 = dhdtstr_0723_2.KMAG_FROM_SPOW
kmag_S__0926_0 = dhdtstr_0926_0.KMAG_FROM_SPOW
;;  Define R = ∆¥/(*eta* |j|^2)
;;    [use IAW *eta* from E-field in NIF in GSE basis]
r_dhdt_0713_0  = dhdtstr_0713_0.RATIO_DISS_ETAJSQR_NIF[*,0]
r_dhdt_0721_0  = dhdtstr_0721_0.RATIO_DISS_ETAJSQR_NIF[*,0]
r_dhdt_0723_0  = dhdtstr_0723_0.RATIO_DISS_ETAJSQR_NIF[*,0]
r_dhdt_0723_1  = dhdtstr_0723_1.RATIO_DISS_ETAJSQR_NIF[*,0]
r_dhdt_0723_2  = dhdtstr_0723_2.RATIO_DISS_ETAJSQR_NIF[*,0]
r_dhdt_0926_0  = dhdtstr_0926_0.RATIO_DISS_ETAJSQR_NIF[*,0]

good_r_0713_0  = WHERE(r_dhdt_0713_0 LE 1.,gd_0713_0)
good_r_0721_0  = WHERE(r_dhdt_0721_0 LE 1.,gd_0721_0)
good_r_0723_0  = WHERE(r_dhdt_0723_0 LE 1.,gd_0723_0)
good_r_0723_1  = WHERE(r_dhdt_0723_1 LE 1.,gd_0723_1)
good_r_0723_2  = WHERE(r_dhdt_0723_2 LE 1.,gd_0723_2)
good_r_0926_0  = WHERE(r_dhdt_0926_0 LE 1.,gd_0926_0)
PRINT,';; ', gd_0713_0, gd_0721_0, gd_0723_0, gd_0723_1, gd_0723_2, gd_0926_0
;;            8          80          42         146         541          73

FOR j=0L, n_cross - 1L DO PRINT,';; ', all_ns.(j)
;;         1648
;;         3376
;;          816
;;          816
;;         1648
;;         1648


x              = Spow_0713_0[good_r_0713_0]
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN)
;;       1.8384000       37.217200       14.576880       13.291306

x              = Spow_0721_0[good_r_0721_0]
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN)
;;      0.17365900       22.635300       4.1946081       4.4876218

x              = Spow_0723_0[good_r_0723_0]
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN)
;;       7.8375400       326.30100       45.988773       57.144630

x              = Spow_0723_1[good_r_0723_1]
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN)
;;      0.25462600       420.57400       24.835506       45.736230

x              = Spow_0723_2[good_r_0723_2]
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN)
;;      0.19213200       171.48200       13.749901       16.488098

x              = Spow_0926_0[good_r_0926_0]
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN)
;;      0.78519900       887.83300       48.272860       119.60731



x              = [[Sn_mag_0713_0[good_r_0713_0]],[St_mag_0713_0[good_r_0713_0]]]
FOR j=0L, 1L DO PRINT,';;', MIN(x[*,j],/NAN), MAX(x[*,j],/NAN), MEAN(x[*,j],/NAN), STDDEV(x[*,j],/NAN)
;;      0.47476429       6.8730081       3.8484649       2.2499117
;;      0.27803585       1.4398339      0.81112723      0.44010281

x              = [[Sn_mag_0721_0[good_r_0721_0]],[St_mag_0721_0[good_r_0721_0]]]
FOR j=0L, 1L DO PRINT,';;', MIN(x[*,j],/NAN), MAX(x[*,j],/NAN), MEAN(x[*,j],/NAN), STDDEV(x[*,j],/NAN)
;;    0.0034490459       5.1912228      0.82691985       1.0094012
;;    0.0088233856       5.5518464       1.3162114       1.3562368

x              = [[Sn_mag_0723_0[good_r_0723_0]],[St_mag_0723_0[good_r_0723_0]]]
FOR j=0L, 1L DO PRINT,';;', MIN(x[*,j],/NAN), MAX(x[*,j],/NAN), MEAN(x[*,j],/NAN), STDDEV(x[*,j],/NAN)
;;     0.024724756       33.677547       3.7108085       6.5070028
;;      0.75457358       20.802675       4.7075766       4.2254099

x              = [[Sn_mag_0723_1[good_r_0723_1]],[St_mag_0723_1[good_r_0723_1]]]
FOR j=0L, 1L DO PRINT,';;', MIN(x[*,j],/NAN), MAX(x[*,j],/NAN), MEAN(x[*,j],/NAN), STDDEV(x[*,j],/NAN)
;;   0.00022308106       47.315784       2.4915736       4.9160181
;;     0.033320525       46.429484       3.0401131       5.0504686

x              = [[Sn_mag_0723_2[good_r_0723_2]],[St_mag_0723_2[good_r_0723_2]]]
FOR j=0L, 1L DO PRINT,';;', MIN(x[*,j],/NAN), MAX(x[*,j],/NAN), MEAN(x[*,j],/NAN), STDDEV(x[*,j],/NAN)
;;       0.0000000       17.891678       1.6004603       2.4718314
;;       0.0000000       26.672159       2.2733474       2.9843906

x              = [[Sn_mag_0926_0[good_r_0926_0]],[St_mag_0926_0[good_r_0926_0]]]
FOR j=0L, 1L DO PRINT,';;', MIN(x[*,j],/NAN), MAX(x[*,j],/NAN), MEAN(x[*,j],/NAN), STDDEV(x[*,j],/NAN)
;;     0.082221476       70.530051       6.0790059       11.861068
;;      0.26379067       100.04371       6.8314372       14.595701



;;----------------------------------------------------------------------------------------
;;  Use all data where ∆xn ≤ 1 [c/wpi]
;;----------------------------------------------------------------------------------------
Delta_str      = STRUPCASE(get_greek_letter('delta'))
mu__str        = get_greek_letter('mu')
muo_str        = mu__str[0]+'!Do!N'
eta_str        = get_greek_letter('eta')
epsilon_str    = get_greek_letter('epsilon')
omega_str      = get_greek_letter('omega')
dhdt_ypref     = '('+Delta_str[0]+'h/'+Delta_str[0]+'t)'
Li_ypref       = omega_str[0]+'!Dpi!N'

xmax           = 1d0
good_r_0713_0  = WHERE(ABS(del_xn_0713_0)/Li_up___0713_0[0] LE xmax[0],gd_0713_0)
good_r_0721_0  = WHERE(ABS(del_xn_0721_0)/Li_up___0721_0[0] LE xmax[0],gd_0721_0)
good_r_0723_0  = WHERE(ABS(del_xn_0723_0)/Li_up___0723_0[0] LE xmax[0],gd_0723_0)
good_r_0723_1  = WHERE(ABS(del_xn_0723_1)/Li_up___0723_1[0] LE xmax[0],gd_0723_1)
good_r_0723_2  = WHERE(ABS(del_xn_0723_2)/Li_up___0723_2[0] LE xmax[0],gd_0723_2)
good_r_0926_0  = WHERE(ABS(del_xn_0926_0)/Li_up___0926_0[0] LE xmax[0],gd_0926_0)
PRINT,';; ', gd_0713_0, gd_0721_0, gd_0723_0, gd_0723_1, gd_0723_2, gd_0926_0
;;          412         685         485         816         234         715


WINDOW,1,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Energy Dissipation 1'
WINDOW,2,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Energy Dissipation 2'
WINDOW,3,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Energy Dissipation 3'
WINDOW,4,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Energy Dissipation 4'
;;----------------------------------------------------------------------------------------
;;  Plot |j|^2 (from ∆¥/*eta*) vs. |j|^2 (measured)
;;----------------------------------------------------------------------------------------
x0             = jsqrnif_0713_0[good_r_0713_0]*1d6
x1             = jsqrnif_0721_0[good_r_0721_0]*1d6
x2             = jsqrnif_0723_0[good_r_0723_0]*1d6
x3             = jsqrnif_0723_1[good_r_0723_1]*1d6
x4             = jsqrnif_0723_2[good_r_0723_2]*1d6
x5             = jsqrnif_0926_0[good_r_0926_0]*1d6

y0             = jsq_eta_0713_0[good_r_0713_0]*1d6
y1             = jsq_eta_0721_0[good_r_0721_0]*1d6
y2             = jsq_eta_0723_0[good_r_0723_0]*1d6
y3             = jsq_eta_0723_1[good_r_0723_1]*1d6
y4             = jsq_eta_0723_2[good_r_0723_2]*1d6
y5             = jsq_eta_0926_0[good_r_0926_0]*1d6

PRINT, ';;', MIN([x0,x1,x2,x3,x4,x5],/NAN), MAX([x0,x1,x2,x3,x4,x5],/NAN)
PRINT, ';;', MIN([y0,y1,y2,y3,y4,y5],/NAN), MAX([y0,y1,y2,y3,y4,y5],/NAN)
;;   1.4460842e-11    0.0027556463
;;   1.3643109e-08      0.61859695


ttle_pref      = '|j|!U2!N ['
xttle          = ttle_pref[0]+'Observed, '+mu__str[0]+'A!U2!N m!U-4!N'+']'
yttle          = ttle_pref[0]+dhdt_ypref[0]+'/'+eta_str[0]+', '+mu__str[0]+'A!U2!N m!U-4!N'+']'
pttle          = '|j|^2 [from (dh/dt)/*eta*] vs. |j|^2 [Observed]'
xra            = [1d-8,1d-1]
yra            = xra
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}

n_sum          = 1L
symb           = 2
WSET,1
WSHOW,1
  PLOT,x0,y0,_EXTRA=pstr
    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]
    ;;  Overplot y = x line
    OPLOT,xra,xra,LINESTYLE=2,THICK=2

;;----------------------------------------------------------------------------------------
;;  Plot *eta* (from ∆¥/|j|^2) vs. *eta* (measured)
;;----------------------------------------------------------------------------------------
x0             = etanif__0713_0[good_r_0713_0]
x1             = etanif__0721_0[good_r_0721_0]
x2             = etanif__0723_0[good_r_0723_0]
x3             = etanif__0723_1[good_r_0723_1]
x4             = etanif__0723_2[good_r_0723_2]
x5             = etanif__0926_0[good_r_0926_0]

y0             = etafjsq_0713_0[good_r_0713_0]
y1             = etafjsq_0721_0[good_r_0721_0]
y2             = etafjsq_0723_0[good_r_0723_0]
y3             = etafjsq_0723_1[good_r_0723_1]
y4             = etafjsq_0723_2[good_r_0723_2]
y5             = etafjsq_0926_0[good_r_0926_0]

PRINT, ';;', MIN([x0,x1,x2,x3,x4,x5],/NAN), MAX([x0,x1,x2,x3,x4,x5],/NAN)
PRINT, ';;', MIN([y0,y1,y2,y3,y4,y5],/NAN), MAX([y0,y1,y2,y3,y4,y5],/NAN)
;;    0.0012805913       1319.4727
;;      0.11622296       2772751.0


ttle_pref      = eta_str[0]+' ['
xttle          = ttle_pref[0]+'Observed, '+STRUPCASE(omega_str[0])+' m]'
yttle          = ttle_pref[0]+dhdt_ypref[0]+'/|j|!U2!N'+', '+STRUPCASE(omega_str[0])+' m]'
pttle          = '*eta* [from (dh/dt)/|j|^2] vs. *eta* [Observed]'
xra            = [1d-2,1d4]
yra            = xra
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}

n_sum          = 1L
symb           = 2
WSET,2
WSHOW,2
  PLOT,x0,y0,_EXTRA=pstr
    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]
    ;;  Overplot y = x line
    OPLOT,xra,xra,LINESTYLE=2,THICK=2


;;----------------------------------------------------------------------------------------
;;  Find ∆t ranges where R ≤ 1
;;----------------------------------------------------------------------------------------
ymax           = 1d0
good_r_0713_0  = WHERE(r_dhdt_0713_0 LE ymax[0],gd_0713_0)
good_r_0721_0  = WHERE(r_dhdt_0721_0 LE ymax[0],gd_0721_0)
good_r_0723_0  = WHERE(r_dhdt_0723_0 LE ymax[0],gd_0723_0)
good_r_0723_1  = WHERE(r_dhdt_0723_1 LE ymax[0],gd_0723_1)
good_r_0723_2  = WHERE(r_dhdt_0723_2 LE ymax[0],gd_0723_2)
good_r_0926_0  = WHERE(r_dhdt_0926_0 LE ymax[0],gd_0926_0)
PRINT,';; ', gd_0713_0, gd_0721_0, gd_0723_0, gd_0723_1, gd_0723_2, gd_0926_0
;;            8          80          42         146         541          73


dt0            = ABS(delta_t_0713_0[good_r_0713_0])
dt1            = ABS(delta_t_0721_0[good_r_0721_0])
dt2            = ABS(delta_t_0723_0[good_r_0723_0])
dt3            = ABS(delta_t_0723_1[good_r_0723_1])
dt4            = ABS(delta_t_0723_2[good_r_0723_2])
dt5            = ABS(delta_t_0926_0[good_r_0926_0])
PRINT, ';;', MIN([dt0,dt1,dt2,dt3,dt4,dt5],/NAN), MAX([dt0,dt1,dt2,dt3,dt4,dt5],/NAN)
;;  ∆t [s] range
;;    0.0019998550       14.445000

tags           = 'T'+STRING(LINDGEN(6),FORMAT='(I2.2)')
x              = CREATE_STRUCT(tags,dt0,dt1,dt2,dt3,dt4,dt5)
FOR j=0L, 5L DO PRINT,';;', MIN(x.(j),/NAN), MAX(x.(j),/NAN), MEAN(x.(j),/NAN), STDDEV(x.(j),/NAN)
;;---------------------------------------------------------------------
;;  ∆t [s] stats
;;---------------------------------------------------------------------
;;          Min             Max             Avg           Std Dev
;;=====================================================================
;;      0.29999995       1.3169999      0.70774999      0.48633608
;;       1.3130002       4.1330001       2.7094626      0.53395889
;;     0.036999941       3.3690002       1.4065952       1.0952833
;;     0.061000109       2.8999999       1.6254246      0.89876112
;;       1.6719999       14.445000       6.9981127       3.5403586
;;    0.0019998550       7.2279999       1.9890274       2.1233713
;;---------------------------------------------------------------------


dx0            = ABS(del_xn_0713_0[good_r_0713_0])/Li_up___0713_0[0]
dx1            = ABS(del_xn_0721_0[good_r_0721_0])/Li_up___0721_0[0]
dx2            = ABS(del_xn_0723_0[good_r_0723_0])/Li_up___0723_0[0]
dx3            = ABS(del_xn_0723_1[good_r_0723_1])/Li_up___0723_1[0]
dx4            = ABS(del_xn_0723_2[good_r_0723_2])/Li_up___0723_2[0]
dx5            = ABS(del_xn_0926_0[good_r_0926_0])/Li_up___0926_0[0]
PRINT, ';;', MIN([dx0,dx1,dx2,dx3,dx4,dx5],/NAN), MAX([dx0,dx1,dx2,dx3,dx4,dx5],/NAN)
;;  ∆xn [c/wpi] range
;;   0.00071636542       4.2433050

tags           = 'T'+STRING(LINDGEN(6),FORMAT='(I2.2)')
x              = CREATE_STRUCT(tags,dx0,dx1,dx2,dx3,dx4,dx5)
FOR j=0L, 5L DO PRINT,';;', MIN(x.(j),/NAN), MAX(x.(j),/NAN), MEAN(x.(j),/NAN), STDDEV(x.(j),/NAN)
;;---------------------------------------------------------------------
;;  ∆xn [c/wpi] stats
;;---------------------------------------------------------------------
;;          Min             Max             Avg           Std Dev
;;=====================================================================
;;      0.18679543      0.82003203      0.44068163      0.30281791
;;      0.49078608       1.5448733       1.0127695      0.19958838
;;     0.019538660       1.7790771      0.74278460      0.57838927
;;    0.0071664016      0.34069716      0.19095778      0.10558806
;;      0.49115997       4.2433050       2.0557374       1.0400015
;;   0.00071636542       2.5891322      0.71248687      0.76061001
;;---------------------------------------------------------------------


;;----------------------------------------------------------------------------------------
;;  Use only data where R ≤ 1 and ∆xn ≤ 1 [c/wpi]
;;----------------------------------------------------------------------------------------
xmax           = 1d0
ymax           = 1d0
good_r_0713_0  = WHERE(r_dhdt_0713_0 LE ymax[0] AND ABS(del_xn_0713_0)/Li_up___0713_0[0] LE xmax[0],gd_0713_0)
good_r_0721_0  = WHERE(r_dhdt_0721_0 LE ymax[0] AND ABS(del_xn_0721_0)/Li_up___0721_0[0] LE xmax[0],gd_0721_0)
good_r_0723_0  = WHERE(r_dhdt_0723_0 LE ymax[0] AND ABS(del_xn_0723_0)/Li_up___0723_0[0] LE xmax[0],gd_0723_0)
good_r_0723_1  = WHERE(r_dhdt_0723_1 LE ymax[0] AND ABS(del_xn_0723_1)/Li_up___0723_1[0] LE xmax[0],gd_0723_1)
good_r_0723_2  = WHERE(r_dhdt_0723_2 LE ymax[0] AND ABS(del_xn_0723_2)/Li_up___0723_2[0] LE xmax[0],gd_0723_2)
good_r_0926_0  = WHERE(r_dhdt_0926_0 LE ymax[0] AND ABS(del_xn_0926_0)/Li_up___0926_0[0] LE xmax[0],gd_0926_0)
PRINT,';; ', gd_0713_0, gd_0721_0, gd_0723_0, gd_0723_1, gd_0723_2, gd_0926_0
;;            8          43          28         146         107          55

;;----------------------------------------------------------------------------------------
;;  Plot |k| (from ∆¥/|S(w,k)|) vs. |St| (measured)
;;----------------------------------------------------------------------------------------
x0             = St_mag_0713_0[good_r_0713_0]
x1             = St_mag_0721_0[good_r_0721_0]
x2             = St_mag_0723_0[good_r_0723_0]
x3             = St_mag_0723_1[good_r_0723_1]
x4             = St_mag_0723_2[good_r_0723_2]
x5             = St_mag_0926_0[good_r_0926_0]

y0             = kmag_S__0713_0[good_r_0713_0]
y1             = kmag_S__0721_0[good_r_0721_0]
y2             = kmag_S__0723_0[good_r_0723_0]
y3             = kmag_S__0723_1[good_r_0723_1]
y4             = kmag_S__0723_2[good_r_0723_2]
y5             = kmag_S__0926_0[good_r_0926_0]

PRINT, ';;', MIN([x0,x1,x2,x3,x4,x5],/NAN), MAX([x0,x1,x2,x3,x4,x5],/NAN)
PRINT, ';;', MIN([y0,y1,y2,y3,y4,y5],/NAN), MAX([y0,y1,y2,y3,y4,y5],/NAN)
;;     0.028303543       100.04371
;;   6.2719516e-05       1.2578031

xttle          = '|n x (S x n)| ['+mu__str[0]+'W m!U-2!N'+']'
yttle          = '|k| [from '+dhdt_ypref[0]+'/|S('+omega_str[0]+',k)|, km!U-1!N'+']'
pttle          = '|j|^2 [from (dh/dt)/*eta*] vs. |j|^2 [Observed]'
xra            = [1d-2,1d2]
yra            = [1d-5,1d1]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}

n_sum          = 1L
symb           = 2
WSET,3
WSHOW,3
  PLOT,x0,y0,_EXTRA=pstr
    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]
    ;;  Overplot y = x line
    OPLOT,xra,xra,LINESTYLE=2,THICK=2


;;----------------------------------------------------------------------------------------
;;  Plot R vs. ∆xn
;;    = ratio of enthalpy change to ohmic dissipation rate estimate
;;    If R < 1 => waves provide more energy dissipation than necessary to maintain shock
;;----------------------------------------------------------------------------------------
x0             = ABS(del_xn_0713_0[good_r_0713_0])/Li_up___0713_0[0]
x1             = ABS(del_xn_0721_0[good_r_0721_0])/Li_up___0721_0[0]
x2             = ABS(del_xn_0723_0[good_r_0723_0])/Li_up___0723_0[0]
x3             = ABS(del_xn_0723_1[good_r_0723_1])/Li_up___0723_1[0]
x4             = ABS(del_xn_0723_2[good_r_0723_2])/Li_up___0723_2[0]
x5             = ABS(del_xn_0926_0[good_r_0926_0])/Li_up___0926_0[0]

y0             = r_dhdt_0713_0[good_r_0713_0]
y1             = r_dhdt_0721_0[good_r_0721_0]
y2             = r_dhdt_0723_0[good_r_0723_0]
y3             = r_dhdt_0723_1[good_r_0723_1]
y4             = r_dhdt_0723_2[good_r_0723_2]
y5             = r_dhdt_0926_0[good_r_0926_0]


yttle          = dhdt_ypref[0]+'/('+eta_str[0]+'|j|!U2!N'+') [Dissipation Ratio]'
xttle          = Delta_str[0]+'X!Dn!N [<c/'+Li_ypref[0]+'>!Dup!N'+']'
pttle          = 'Ratio of (dh/dt)/(*eta* |j|^2) vs. Shock Normal Displacement'
xra            = [1d-4,xmax[0]]
yra            = [1d-4,ymax[0]*2d0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}

n_sum          = 1L
symb           = 2
WSET,1
WSHOW,1
  PLOT,x0,y0,_EXTRA=pstr
    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]

;;----------------------------------------------------------------------------------------
;;  Plot R vs. |Sn| and R vs. |St|
;;----------------------------------------------------------------------------------------
;;  R vs. |St|
x0             = St_mag_0713_0[good_r_0713_0]
x1             = St_mag_0721_0[good_r_0721_0]
x2             = St_mag_0723_0[good_r_0723_0]
x3             = St_mag_0723_1[good_r_0723_1]
x4             = St_mag_0723_2[good_r_0723_2]
x5             = St_mag_0926_0[good_r_0926_0]

y0             = r_dhdt_0713_0[good_r_0713_0]
y1             = r_dhdt_0721_0[good_r_0721_0]
y2             = r_dhdt_0723_0[good_r_0723_0]
y3             = r_dhdt_0723_1[good_r_0723_1]
y4             = r_dhdt_0723_2[good_r_0723_2]
y5             = r_dhdt_0926_0[good_r_0926_0]

PRINT, ';;', MIN([x0,x1,x2,x3,x4,x5],/NAN), MAX([x0,x1,x2,x3,x4,x5],/NAN)
PRINT, ';;', MIN([y0,y1,y2,y3,y4,y5],/NAN), MAX([y0,y1,y2,y3,y4,y5],/NAN)
;;     0.028303543       100.04371
;;   0.00080362476      0.99765243

dhdt_ypref     = '('+Delta_str[0]+'h/'+Delta_str[0]+'t)'
yttle          = dhdt_ypref[0]+'/('+eta_str[0]+'|j|!U2!N'+') [Dissipation Ratio]'
xttle          = '|n x (S x n)| ['+mu__str[0]+'W m!U-2!N'+']'
pttle          = 'Ratio of (dh/dt)/(*eta* |j|^2) vs. |St|'
xra            = [1d-3,2d2]
yra            = [1d-4,2d0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}

n_sum          = 1L
symb           = 2
WSET,1
WSHOW,1
  PLOT,x0,y0,_EXTRA=pstr
    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]


;;  R vs. |Sn|
x0             = Sn_mag_0713_0[good_r_0713_0]
x1             = Sn_mag_0721_0[good_r_0721_0]
x2             = Sn_mag_0723_0[good_r_0723_0]
x3             = Sn_mag_0723_1[good_r_0723_1]
x4             = Sn_mag_0723_2[good_r_0723_2]
x5             = Sn_mag_0926_0[good_r_0926_0]

y0             = r_dhdt_0713_0[good_r_0713_0]
y1             = r_dhdt_0721_0[good_r_0721_0]
y2             = r_dhdt_0723_0[good_r_0723_0]
y3             = r_dhdt_0723_1[good_r_0723_1]
y4             = r_dhdt_0723_2[good_r_0723_2]
y5             = r_dhdt_0926_0[good_r_0926_0]

PRINT, ';;', MIN([x0,x1,x2,x3,x4,x5],/NAN), MAX([x0,x1,x2,x3,x4,x5],/NAN)
PRINT, ';;', MIN([y0,y1,y2,y3,y4,y5],/NAN), MAX([y0,y1,y2,y3,y4,y5],/NAN)
;;   1.9577290e-05       70.530051
;;   0.00080362476      0.99765243

dhdt_ypref     = '('+Delta_str[0]+'h/'+Delta_str[0]+'t)'
yttle          = dhdt_ypref[0]+'/('+eta_str[0]+'|j|!U2!N'+') [Dissipation Ratio]'
xttle          = '|(n . S) n| ['+mu__str[0]+'W m!U-2!N'+']'
pttle          = 'Ratio of (dh/dt)/(*eta* |j|^2) vs. |Sn|'
xra            = [1d-3,2d2]
yra            = [1d-4,2d0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}

n_sum          = 1L
symb           = 2
WSET,2
WSHOW,2
  PLOT,x0,y0,_EXTRA=pstr
    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]


;;  R vs. |S(w,k)|
x0             = Spow_0713_0[good_r_0713_0]
x1             = Spow_0721_0[good_r_0721_0]
x2             = Spow_0723_0[good_r_0723_0]
x3             = Spow_0723_1[good_r_0723_1]
x4             = Spow_0723_2[good_r_0723_2]
x5             = Spow_0926_0[good_r_0926_0]

y0             = r_dhdt_0713_0[good_r_0713_0]
y1             = r_dhdt_0721_0[good_r_0721_0]
y2             = r_dhdt_0723_0[good_r_0723_0]
y3             = r_dhdt_0723_1[good_r_0723_1]
y4             = r_dhdt_0723_2[good_r_0723_2]
y5             = r_dhdt_0926_0[good_r_0926_0]

PRINT, ';;', MIN([x0,x1,x2,x3,x4,x5],/NAN), MAX([x0,x1,x2,x3,x4,x5],/NAN)
PRINT, ';;', MIN([y0,y1,y2,y3,y4,y5],/NAN), MAX([y0,y1,y2,y3,y4,y5],/NAN)
;;      0.17365900       887.83300
;;   0.00080362476      0.99765243

xttle          = '|S| [FFT Power, '+mu__str[0]+'W m!U-2!N'+']'
dhdt_ypref     = '('+Delta_str[0]+'h/'+Delta_str[0]+'t)'
yttle          = dhdt_ypref[0]+'/('+eta_str[0]+'|j|!U2!N'+') [Dissipation Ratio]'
pttle          = 'Ratio of (dh/dt)/(*eta* |j|^2) vs. Integrated FFT Poynting Flux'
xra            = [1d-1,1d3]
yra            = [1d-4,2d0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}

n_sum          = 1L
symb           = 2
WSET,3
WSHOW,3
  PLOT,x0,y0,_EXTRA=pstr
    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]
;;----------------------------------------------------------------------------------------
;;  Use all data
;;----------------------------------------------------------------------------------------
good_r_0713_0  = WHERE(FINITE(r_dhdt_0713_0) AND r_dhdt_0713_0 GT 0d0,gd_0713_0)
good_r_0721_0  = WHERE(FINITE(r_dhdt_0721_0) AND r_dhdt_0721_0 GT 0d0,gd_0721_0)
good_r_0723_0  = WHERE(FINITE(r_dhdt_0723_0) AND r_dhdt_0723_0 GT 0d0,gd_0723_0)
good_r_0723_1  = WHERE(FINITE(r_dhdt_0723_1) AND r_dhdt_0723_1 GT 0d0,gd_0723_1)
good_r_0723_2  = WHERE(FINITE(r_dhdt_0723_2) AND r_dhdt_0723_2 GT 0d0,gd_0723_2)
good_r_0926_0  = WHERE(FINITE(r_dhdt_0926_0) AND r_dhdt_0926_0 GT 0d0,gd_0926_0)
PRINT,';; ', gd_0713_0, gd_0721_0, gd_0723_0, gd_0723_1, gd_0723_2, gd_0926_0
;;         1648         811         816         816        1648        1648


;;--------------------------------------------------
;;  Plot R vs. |Sn| and R vs. |St|
;;--------------------------------------------------
dhdt_ypref     = '('+Delta_str[0]+'h/'+Delta_str[0]+'t)'
yttle          = '('+eta_str[0]+'|j|!U2!N'+')/'+dhdt_ypref[0]+' [Dissipation Ratio]'
y0             = 1d0/r_dhdt_0713_0[good_r_0713_0]
y1             = 1d0/r_dhdt_0721_0[good_r_0721_0]
y2             = 1d0/r_dhdt_0723_0[good_r_0723_0]
y3             = 1d0/r_dhdt_0723_1[good_r_0723_1]
y4             = 1d0/r_dhdt_0723_2[good_r_0723_2]
y5             = 1d0/r_dhdt_0926_0[good_r_0926_0]
PRINT, ';;', MIN([y0,y1,y2,y3,y4,y5],/NAN), MAX([y0,y1,y2,y3,y4,y5],/NAN)
;;   5.2675050e-08       1244.3619
yra            = [1d-8,2d3]


;;  1/R vs. |St|
x0             = St_mag_0713_0[good_r_0713_0]
x1             = St_mag_0721_0[good_r_0721_0]
x2             = St_mag_0723_0[good_r_0723_0]
x3             = St_mag_0723_1[good_r_0723_1]
x4             = St_mag_0723_2[good_r_0723_2]
x5             = St_mag_0926_0[good_r_0926_0]

PRINT, ';;', MIN([x0,x1,x2,x3,x4,x5],/NAN), MAX([x0,x1,x2,x3,x4,x5],/NAN)
;;       0.0000000       100.04371

xttle          = '|n x (S x n)| ['+mu__str[0]+'W m!U-2!N'+']'
pttle          = 'Ratio of (*eta* |j|^2)/(dh/dt) vs. |St|'
xra            = [1d-4,2d2]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}

n_sum          = 1L
symb           = 2
WSET,1
WSHOW,1
  PLOT,x0,y0,_EXTRA=pstr
    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]
    ;;  Overplot y = 1.0 line
    OPLOT,xra,[1d0,1d0],LINESTYLE=2,THICK=2


;;  1/R vs. |Sn|
x0             = Sn_mag_0713_0[good_r_0713_0]
x1             = Sn_mag_0721_0[good_r_0721_0]
x2             = Sn_mag_0723_0[good_r_0723_0]
x3             = Sn_mag_0723_1[good_r_0723_1]
x4             = Sn_mag_0723_2[good_r_0723_2]
x5             = Sn_mag_0926_0[good_r_0926_0]

PRINT, ';;', MIN([x0,x1,x2,x3,x4,x5],/NAN), MAX([x0,x1,x2,x3,x4,x5],/NAN)
;;       0.0000000       70.530051

xttle          = '|(n . S) n| ['+mu__str[0]+'W m!U-2!N'+']'
pttle          = 'Ratio of (*eta* |j|^2)/(dh/dt) vs. |Sn|'
xra            = [1d-4,2d2]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}

n_sum          = 1L
symb           = 2
WSET,2
WSHOW,2
  PLOT,x0,y0,_EXTRA=pstr
    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]
    ;;  Overplot y = 1.0 line
    OPLOT,xra,[1d0,1d0],LINESTYLE=2,THICK=2


;;  1/R vs. |S(w,k)|
x0             = Spow_0713_0[good_r_0713_0]
x1             = Spow_0721_0[good_r_0721_0]
x2             = Spow_0723_0[good_r_0723_0]
x3             = Spow_0723_1[good_r_0723_1]
x4             = Spow_0723_2[good_r_0723_2]
x5             = Spow_0926_0[good_r_0926_0]

PRINT, ';;', MIN([x0,x1,x2,x3,x4,x5],/NAN), MAX([x0,x1,x2,x3,x4,x5],/NAN)
;;     0.012327300       887.83300

xttle          = '|S| [FFT Power, '+mu__str[0]+'W m!U-2!N'+']'
pttle          = 'Ratio of (*eta* |j|^2)/(dh/dt) vs. Integrated FFT Poynting Flux'
xra            = [1d-4,2d2]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}

n_sum          = 1L
symb           = 2
WSET,3
WSHOW,3
  PLOT,x0,y0,_EXTRA=pstr
    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]
    ;;  Overplot y = 1.0 line
    OPLOT,xra,[1d0,1d0],LINESTYLE=2,THICK=2



;;----------------------------------------------------------------------------------------
;;  Plot R vs. W_B and R vs. W_E
;;----------------------------------------------------------------------------------------
n_sum          = 2L
symb           = 6

dhdt_ypref     = '('+Delta_str[0]+'h/'+Delta_str[0]+'t)'
yttle          = '('+eta_str[0]+'|j|!U2!N'+')/'+dhdt_ypref[0]+' [Dissipation Ratio]'
y0             = 1d0/r_dhdt_0713_0[good_r_0713_0]
y1             = 1d0/r_dhdt_0721_0[good_r_0721_0]
y2             = 1d0/r_dhdt_0723_0[good_r_0723_0]
y3             = 1d0/r_dhdt_0723_1[good_r_0723_1]
y4             = 1d0/r_dhdt_0723_2[good_r_0723_2]
y5             = 1d0/r_dhdt_0926_0[good_r_0926_0]
PRINT, ';;', MIN([y0,y1,y2,y3,y4,y5],/NAN), MAX([y0,y1,y2,y3,y4,y5],/NAN)
;;   5.2675050e-08       1244.3619
yra            = [1d-8,2d3]


;;  1/R vs. W_B
x0             = B_E_gse_0713_0[good_r_0713_0]
x1             = B_E_gse_0721_0[good_r_0721_0]
x2             = B_E_gse_0723_0[good_r_0723_0]
x3             = B_E_gse_0723_1[good_r_0723_1]
x4             = B_E_gse_0723_2[good_r_0723_2]
x5             = B_E_gse_0926_0[good_r_0926_0]

PRINT, ';;', MIN([x0,x1,x2,x3,x4,x5],/NAN), MAX([x0,x1,x2,x3,x4,x5],/NAN)
;;       0.0000000   1.9229424e-06

low_delta      = STRLOWCASE(Delta_str[0])
xttle          = '|'+low_delta[0]+'B|!U2!N'+'/2'+mu__str[0]+'!Do!N ['+mu__str[0]+'W m!U-3!N'+']'
pttle          = 'Ratio of (*eta* |j|^2)/(dh/dt) vs. W!DB!N'
xra            = [1d-13,1d-6]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}

WSET,1
WSHOW,1
  PLOT,x0,y0,_EXTRA=pstr
    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]
    ;;  Overplot y = 1.0 line
    OPLOT,xra,[1d0,1d0],LINESTYLE=2,THICK=2


;;  1/R vs. W_E
x0             = E_E_gse_0713_0[good_r_0713_0]
x1             = E_E_gse_0721_0[good_r_0721_0]
x2             = E_E_gse_0723_0[good_r_0723_0]
x3             = E_E_gse_0723_1[good_r_0723_1]
x4             = E_E_gse_0723_2[good_r_0723_2]
x5             = E_E_gse_0926_0[good_r_0926_0]

PRINT, ';;', MIN([x0,x1,x2,x3,x4,x5],/NAN), MAX([x0,x1,x2,x3,x4,x5],/NAN)
;;   7.9088915e-14   3.0121502e-07

low_delta      = STRLOWCASE(Delta_str[0])
xttle          = epsilon_str[0]+'!Do!N |'+low_delta[0]+'E|!U2!N'+'/2 ['+mu__str[0]+'W m!U-3!N'+']'
pttle          = 'Ratio of (*eta* |j|^2)/(dh/dt) vs. W!DE!N'
xra            = [1d-13,1d-6]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}

WSET,2
WSHOW,2
  PLOT,x0,y0,_EXTRA=pstr
    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]
    ;;  Overplot y = 1.0 line
    OPLOT,xra,[1d0,1d0],LINESTYLE=2,THICK=2


;;  1/R vs. (W_E + W_B)
x0             = E_E_gse_0713_0[good_r_0713_0] + B_E_gse_0713_0[good_r_0713_0]
x1             = E_E_gse_0721_0[good_r_0721_0] + B_E_gse_0721_0[good_r_0721_0]
x2             = E_E_gse_0723_0[good_r_0723_0] + B_E_gse_0723_0[good_r_0723_0]
x3             = E_E_gse_0723_1[good_r_0723_1] + B_E_gse_0723_1[good_r_0723_1]
x4             = E_E_gse_0723_2[good_r_0723_2] + B_E_gse_0723_2[good_r_0723_2]
x5             = E_E_gse_0926_0[good_r_0926_0] + B_E_gse_0926_0[good_r_0926_0]

PRINT, ';;', MIN([x0,x1,x2,x3,x4,x5],/NAN), MAX([x0,x1,x2,x3,x4,x5],/NAN)
;;   2.1922414e-12   1.9230959e-06

low_delta      = STRLOWCASE(Delta_str[0])
x_epref        = '('+epsilon_str[0]+'!Do!N |'+low_delta[0]+'E|!U2!N'+'/2 + '
x_bpref        = '|'+low_delta[0]+'B|!U2!N'+'/2'+mu__str[0]+'!Do!N'+') '
xttle          = x_epref[0]+x_bpref[0]+'['+mu__str[0]+'W m!U-3!N'+']'
pttle          = 'Ratio of (*eta* |j|^2)/(dh/dt) vs. (W!DE!N + W!DB!N'+')'
xra            = [1d-13,1d-6]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}

WSET,3
WSHOW,3
  PLOT,x0,y0,_EXTRA=pstr
    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]
    ;;  Overplot y = 1.0 line
    OPLOT,xra,[1d0,1d0],LINESTYLE=2,THICK=2


;;  1/R vs. (W_E/W_B)
x0             = E_E_gse_0713_0[good_r_0713_0]/B_E_gse_0713_0[good_r_0713_0]
x1             = E_E_gse_0721_0[good_r_0721_0]/B_E_gse_0721_0[good_r_0721_0]
x2             = E_E_gse_0723_0[good_r_0723_0]/B_E_gse_0723_0[good_r_0723_0]
x3             = E_E_gse_0723_1[good_r_0723_1]/B_E_gse_0723_1[good_r_0723_1]
x4             = E_E_gse_0723_2[good_r_0723_2]/B_E_gse_0723_2[good_r_0723_2]
x5             = E_E_gse_0926_0[good_r_0926_0]/B_E_gse_0926_0[good_r_0926_0]

PRINT, ';;', MIN([x0,x1,x2,x3,x4,x5],/NAN), MAX([x0,x1,x2,x3,x4,x5],/NAN)
;;   1.9075353e-05       1317.9706

low_delta      = STRLOWCASE(Delta_str[0])
x_epref        = '('+epsilon_str[0]+'!Do!N |'+low_delta[0]+'E|!U2!N'+'/2)/('
x_bpref        = '|'+low_delta[0]+'B|!U2!N'+'/2'+mu__str[0]+'!Do!N'+') '
xttle          = x_epref[0]+x_bpref[0]+'[unitless]'
pttle          = 'Ratio of (*eta* |j|^2)/(dh/dt) vs. W!DE!N'
xra            = [1d-8,2d3]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}

WSET,4
WSHOW,4
  PLOT,x0,y0,_EXTRA=pstr
    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]
    ;;  Overplot y = 1.0 line
    OPLOT,xra,[1d0,1d0],LINESTYLE=2,THICK=2
    ;;  Overplot x = 1.0 line
    OPLOT,[1d0,1d0],yra,LINESTYLE=2,THICK=2



;;  W_E vs. W_B
;x0             = B_E_gse_0713_0[good_r_0713_0]
;x1             = B_E_gse_0721_0[good_r_0721_0]
;x2             = B_E_gse_0723_0[good_r_0723_0]
;x3             = B_E_gse_0723_1[good_r_0723_1]
;x4             = B_E_gse_0723_2[good_r_0723_2]
;x5             = B_E_gse_0926_0[good_r_0926_0]
;
;y0             = E_E_gse_0713_0[good_r_0713_0]
;y1             = E_E_gse_0721_0[good_r_0721_0]
;y2             = E_E_gse_0723_0[good_r_0723_0]
;y3             = E_E_gse_0723_1[good_r_0723_1]
;y4             = E_E_gse_0723_2[good_r_0723_2]
;y5             = E_E_gse_0926_0[good_r_0926_0]
;
;low_delta      = STRLOWCASE(Delta_str[0])
;xttle          = '|'+low_delta[0]+'B|!U2!N'+'/2'+mu__str[0]+'!Do!N ['+mu__str[0]+'W m!U-3!N'+']'
;yttle          = epsilon_str[0]+'!Do!N |'+low_delta[0]+'E|!U2!N'+'/2 ['+mu__str[0]+'W m!U-3!N'+']'
;pttle          = 'W!DE!N vs. W!DB!N'
;xra            = [1d-13,1d-6]
;yra            = xra
;pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
;                  YMINOR:9L,XMINOR:10L,XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}
;
;symb           = 2
;WSET,3
;WSHOW,3
;  PLOT,x0,y0,_EXTRA=pstr
;    OPLOT,x0,y0,PSYM=symb[0],COLOR=xyout_cols[0],NSUM=n_sum[0]
;    OPLOT,x1,y1,PSYM=symb[0],COLOR=xyout_cols[1],NSUM=n_sum[0]
;    OPLOT,x2,y2,PSYM=symb[0],COLOR=xyout_cols[2],NSUM=n_sum[0]
;    OPLOT,x3,y3,PSYM=symb[0],COLOR=xyout_cols[3],NSUM=n_sum[0]
;    OPLOT,x4,y4,PSYM=symb[0],COLOR=xyout_cols[4],NSUM=n_sum[0]
;    OPLOT,x5,y5,PSYM=symb[0],COLOR=xyout_cols[5],NSUM=n_sum[0]
;    ;;  Overplot y = x line
;    OPLOT,xra,xra,LINESTYLE=2,THICK=2


















































.compile thm_load_bowshock_rhsolns
thm_load_bowshock_rhsolns,R_STRUCT=diss_rates

HELP, diss_rates, /STRUC
;;** Structure <1a20e08>, 6 tags, length=170960, data length=170940, refs=1:
;;   THB_2009_07_13_0
;;                   STRUCT    -> <Anonymous> Array[1]
;;   THC_2009_07_21_0
;;                   STRUCT    -> <Anonymous> Array[1]
;;   THC_2009_07_23_0
;;                   STRUCT    -> <Anonymous> Array[1]
;;   THC_2009_07_23_1
;;                   STRUCT    -> <Anonymous> Array[1]
;;   THC_2009_07_23_2
;;                   STRUCT    -> <Anonymous> Array[1]
;;   THA_2009_09_26_0
;;                   STRUCT    -> <Anonymous> Array[1]
;;

HELP, diss_rates.THB_2009_07_13_0, /STRUC
;;** Structure <155fc38>, 4 tags, length=33552, data length=33548, refs=2:
;;   UP              STRUCT    -> <Anonymous> Array[1]
;;   DOWN            STRUCT    -> <Anonymous> Array[1]
;;   SHOCK           STRUCT    -> <Anonymous> Array[1]
;;   DISS_RATE       STRUCT    -> <Anonymous> Array[1]


HELP, diss_rates.THB_2009_07_13_0.UP, /STRUC
HELP, diss_rates.THB_2009_07_13_0.DOWN, /STRUC
;;** Structure <19f7e08>, 6 tags, length=1160, data length=1160, refs=2:
;;   NI              FLOAT     Array[29]
;;   TI              FLOAT     Array[29]
;;   TE              FLOAT     Array[29]
;;   PI              FLOAT     Array[29]
;;   VSW             FLOAT     Array[29, 3]
;;   BO              FLOAT     Array[29, 3]

HELP, diss_rates.THB_2009_07_13_0.SHOCK, /STRUC
;;** Structure <154f428>, 5 tags, length=112, data length=112, refs=2:
;;   VSHN            DOUBLE    Array[2]
;;   USHN_UP         DOUBLE    Array[2]
;;   USHN_DOWN       DOUBLE    Array[2]
;;   NVEC            DOUBLE    Array[3, 2]
;;   TRAMP           DOUBLE    Array[2]

HELP, diss_rates.THB_2009_07_13_0.DISS_RATE, /STRUC
;;** Structure <15620d8>, 3 tags, length=31120, data length=31116, refs=2:
;;   SH_PARAM        STRUCT    -> <Anonymous> Array[1]
;;   OBSERVED        STRUCT    -> <Anonymous> Array[1]
;;   THEORIES        STRUCT    -> <Anonymous> Array[1]

HELP, diss_rates.THB_2009_07_13_0.DISS_RATE.SH_PARAM, /STRUC
;;** Structure <1562388>, 3 tags, length=792, data length=792, refs=2:
;;   NVEC            DOUBLE    Array[3, 3]
;;   USHN            DOUBLE    Array[3]
;;   THETA_BN        DOUBLE    Array[29, 3]

HELP, diss_rates.THB_2009_07_13_0.DISS_RATE.OBSERVED, /STRUC
;;** Structure <1a1fe08>, 14 tags, length=4624, data length=4620, refs=2:
;;   DELTA_RHO       DOUBLE    Array[29]
;;   RHO_RATIO       FLOAT     Array[29]
;;   PRESS_T_UP      DOUBLE    Array[29]
;;   PRESS_T_DN      DOUBLE    Array[29]
;;   PRESS_RATIO     DOUBLE    Array[29]
;;   CS_UP           DOUBLE    Array[29, 3]
;;   WORK_RATE       DOUBLE    Array[29, 3]
;;   DELTA_ENTROPY   DOUBLE    Array[29, 3]
;;   DISS_RATE       DOUBLE    Array[29, 3]
;;   DELTA_ENTHALPY  DOUBLE    Array[29, 3]
;;   AVG_WORK_RATE   DOUBLE    Array[3]
;;   AVG_D_ENTROPY   DOUBLE    Array[3]
;;   AVG_DISS_RATE   DOUBLE    Array[3]
;;   AVG_D_ENTHALPY  DOUBLE    Array[3]

HELP, diss_rates.THB_2009_07_13_0.DISS_RATE.THEORIES, /STRUC
;;** Structure <1a20808>, 7 tags, length=25704, data length=25704, refs=2:
;;   PRESS_RATIO     DOUBLE    Array[29, 3, 3, 3]
;;   DELTA_ENTROPY   DOUBLE    Array[29, 3, 3, 3]
;;   DISS_RATE       DOUBLE    Array[29, 3, 3, 3]
;;   DELTA_ENTHALPY  DOUBLE    Array[29, 3, 3, 3]
;;   AVG_D_ENTROPY   DOUBLE    Array[3, 3, 3]
;;   AVG_DISS_RATE   DOUBLE    Array[3, 3, 3]
;;   AVG_D_ENTHALPY  DOUBLE    Array[3, 3, 3]





.compile thm_load_bowshock_ascii
thm_load_bowshock_ascii,R_STRUCT=j_E_S_corr

HELP, j_E_S_corr.DATA, /STRUC
;;** Structure <1a61c08>, 6 tags, length=2547712, data length=2547712, refs=2:
;;   THB_2009_07_13_1ST
;;                   STRUCT    -> <Anonymous> Array[1]
;;   THC_2009_07_21_1ST
;;                   STRUCT    -> <Anonymous> Array[1]
;;   THC_2009_07_23_1ST
;;                   STRUCT    -> <Anonymous> Array[1]
;;   THC_2009_07_23_2ND
;;                   STRUCT    -> <Anonymous> Array[1]
;;   THC_2009_07_23_3RD
;;                   STRUCT    -> <Anonymous> Array[1]
;;   THA_2009_09_26_1ST
;;                   STRUCT    -> <Anonymous> Array[1]
;;

HELP, j_E_S_corr.DATA.THB_2009_07_13_1ST, /STRUC
;;** Structure <1a62408>, 13 tags, length=421888, data length=421888, refs=2:
;;   SCETS           STRING    Array[1648]
;;   UNIX            DOUBLE    Array[1648]
;;   J_MAG_SM        DOUBLE    Array[1648]
;;   J_VEC_NIF_NCB_SM
;;                   DOUBLE    Array[1648, 3]
;;   E_VEC_NIF_GSE_JT
;;                   DOUBLE    Array[1648, 3]
;;   B_VEC_SCF_GSE_JT
;;                   DOUBLE    Array[1648, 3]
;;   S_VEC_NIF_GSE_JT
;;                   DOUBLE    Array[1648, 3]
;;   S_POW_NIF_GSE_JT
;;                   DOUBLE    Array[1648]
;;   S_DOT_N_N_NIF_GSE
;;                   DOUBLE    Array[1648, 3]
;;   N_X_S_X_N_NIF_GSE
;;                   DOUBLE    Array[1648, 3]
;;   NEG_E_DOT_J_SM  DOUBLE    Array[1648]
;;   ETA_JSQ_GSE     DOUBLE    Array[1648, 4]
;;   ETA_JSQ_NIF     DOUBLE    Array[1648, 4]






WINDOW,1,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Energy Dissipation 1'



all_data       = j_E_S_corr.DATA
all_ns         = j_E_S_corr.NUM
n_cross        = N_TAGS(all_ns)
FOR j=0L, n_cross - 1L DO PRINT,';; ', all_ns.(j)
;;         1648
;;         3376
;;          816
;;          816
;;         1648
;;         1648

n_pts          = 0L
FOR j=0L, n_cross - 1L DO n_pts += all_ns.(j)
PRINT,';; ', n_cross, n_pts
;;            6        9952






























