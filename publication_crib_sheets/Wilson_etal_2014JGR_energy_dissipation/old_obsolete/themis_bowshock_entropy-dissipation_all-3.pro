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


















;;----------------------------------------------------------------------------------------
;; => Define jump conditions
;;----------------------------------------------------------------------------------------
tdate          = '2009-07-13'
;; => Avg. terms [2009-07-13:  1st Shock Crossing]
t_ramp_0713_0  = time_double(tdate[0]+'/'+['08:59:45.440','08:59:48.290'])
;;  Rankine-Hugoniot Solutions
Vsh__up_0713_0 = -52.769597d0
dVsh_up_0713_0 =  8.7314762d0
Ush__up_0713_0 = -271.85307d0
dUsh_up_0713_0 =  10.936048d0
Ush__dn_0713_0 = -41.225873d0
dUsh_dn_0713_0 =  5.2047397d0
nvec__0713_0   = [0.99012543d0,0.086580460d0,-0.0038282813d0]
dnvec_0713_0   = [0.0074044322d0,0.064699062d0,0.088898234d0]
;; => Upstream values
ni___up_0713_0 = [  7.07309,6.94231,7.24725,7.09166,7.57944,6.50510,6.56785,6.86059,6.80491,7.12088,6.63134,6.63572,6.76323,7.16061,7.17674,7.07219,6.94646,7.20353,7.19970,6.85925,7.19086,7.05820,7.32919,7.34909,7.33728,7.66464,8.24446,9.48765,8.25387]
Ti___up_0713_0 = [ 27.9521,29.0306,27.0957,27.5606,29.4961,28.2101,28.7773,30.0791,29.3048,30.6265,29.9438,32.8888,33.2325,32.2569,33.2552,33.2854,32.5035,32.7801,32.0462,32.7725,32.2295,32.3276,33.7334,29.8235,29.8371,26.6801,24.2807,25.9705,26.5252]
Te___up_0713_0 = [ 13.4200,13.8634,13.1068,13.3362,12.0094,12.2394,12.0810,11.9554,11.7059,11.2118,10.9941,10.5550,10.4803,10.7837,10.8060,10.5236,10.3936,10.1871,10.4057,10.1770,10.4710,10.5616,10.6896,10.6691,10.4963,10.8782,11.1172,10.5043,10.2576]
Pi___up_0713_0 = [24.9519,25.5243,24.9692,26.5250,27.6737,24.8841,23.5557,26.4150,26.2789,27.8357,30.7135,30.0801,29.6270,26.6200,31.0004,28.2859,28.4672,34.3540,34.5566,29.9499,31.9192,27.8907,30.3342,29.9957,31.2449,25.6382,34.2219,42.0453,25.4974]
Vswx_up_0713_0 = [-316.447,-319.870,-318.987,-320.648,-326.112,-321.746,-322.206,-322.740,-324.489,-327.459,-328.011,-330.537,-326.407,-328.028,-330.313,-331.141,-329.029,-334.743,-340.333,-334.648,-336.701,-334.982,-330.380,-332.186,-336.363,-327.660,-337.738,-337.917,-325.802]
Vswy_up_0713_0 = [  29.0735,19.9851,23.6322,22.5127,13.6763,20.6679,17.7925,16.5352,15.4735,11.1588,18.1249,-0.686537,0.431731,3.64825,-2.38933,-6.70178,5.13271,-1.68937,-26.8039,-8.24689,-9.09138,-14.1291,-11.9587,18.9613,18.4688,34.6628,38.0143,34.8041,34.1452]
Vswz_up_0713_0 = [  12.4615,15.1059,16.8155,17.6163,17.3923,17.0570,16.2849,15.0066,17.2698,16.9474,18.2318,16.0893,13.6373,14.5016,14.8361,14.3231,15.3637,18.4846,18.1510,17.2716,18.7987,16.6775,12.7282,18.5495,20.4625,15.9689,23.3047,22.7276,15.1724]
magx_up_0713_0 = [  -2.71921,-2.63767,-2.57030,-2.61222,-2.64007,-2.73514,-2.81840,-2.86072,-2.85699,-2.89828,-2.85913,-2.79519,-2.83627,-2.86735,-2.90454,-2.93435,-2.96339,-2.95289,-2.96248,-3.00701,-2.97521,-3.03407,-3.04655,-2.96712,-2.92469,-3.00907,-3.04743,-3.18937,-3.16468]
magy_up_0713_0 = [   2.76717, 2.61890, 2.51639, 2.43629, 2.25644, 2.21154, 2.21048, 2.15294, 2.02738, 1.88479, 1.83512, 1.93592, 1.94767, 1.86384, 1.73370, 1.64626, 1.49788, 1.39670, 1.31966, 1.25594, 1.33410, 1.37250, 1.38116, 1.37442, 1.47827, 1.41318, 1.40196, 1.34582, 1.30659]
magz_up_0713_0 = [  -1.33057,-1.24411,-1.23385,-1.33517,-1.47593,-1.34271,-1.26750,-1.26045,-1.24838,-1.21476,-1.26460,-1.31246,-1.37037,-1.44833,-1.50094,-1.49084,-1.51346,-1.52782,-1.42195,-1.43509,-1.48602,-1.49456,-1.48293,-1.53285,-1.42843,-1.35082,-1.42873,-1.28517,-1.28430]
Vsw__up_0713_0 = [[Vswx_up_0713_0],[Vswy_up_0713_0],[Vswz_up_0713_0]]
magf_up_0713_0 = [[magx_up_0713_0],[magy_up_0713_0],[magz_up_0713_0]]
;; => Downstream values
ni___dn_0713_0 = [  51.4770,48.6373,52.8328,53.0221,52.6641,49.2217,48.5648,47.0462,44.4818,44.9738,46.4381,47.5547,45.9673,47.9835,45.1012,46.5187,45.8831,50.0338,47.2762,49.9218,50.3316,47.0770,47.2242,47.2203,44.5792,47.8478,48.1071,46.9614,42.4192]
Ti___dn_0713_0 = [ 136.216,147.522,138.781,139.658,139.380,149.361,143.321,150.672,154.902,154.678,161.065,154.660,157.191,159.400,166.408,162.171,167.363,160.988,171.104,164.133,164.538,161.970,166.976,166.715,162.359,168.119,171.535,168.439,189.694]
Te___dn_0713_0 = [  35.4064,34.3931,33.8612,33.0007,32.6866,32.1967,31.4333,31.0074,29.6826,29.3683,29.0726,28.9296,28.6810,29.5491,29.5996,30.3012,29.3947,29.8207,30.3661,30.0133,28.9117,29.5370,29.6329,29.4599,28.8308,29.7145,31.6728,29.3668,28.6293]
Pi___dn_0713_0 = [2483.14,2422.35,2475.93,2440.48,2440.65,2459.62,2330.47,2429.88,2410.62,2461.01,2466.20,2342.30,2341.09,2445.06,2361.68,2339.19,2346.05,2395.36,2488.22,2562.57,2506.78,2325.97,2408.04,2536.46,2499.03,2747.57,2715.11,2865.94,2587.13]
Vswx_dn_0713_0 = [ -99.7757,-91.3455,-100.521,-91.3240,-85.1202,-87.6931,-89.5073,-90.3370,-89.0330,-92.7631,-94.4428,-93.7327,-89.0600,-91.1821,-88.3397,-87.0060,-97.8387,-96.7625,-97.6818,-98.5620,-110.408,-104.318,-113.354,-107.950,-105.255,-103.566,-109.812,-111.376,-95.9041]
Vswy_dn_0713_0 = [   1.29185,-2.67234,-1.56431,2.48126,17.3283,13.2345,13.0037,24.4695,21.2880,25.9305,29.1140,30.8326,30.1751,30.8178,32.1754,30.5344,24.6059,33.6962,35.4118,31.0414,40.9501,39.4945,31.6942,28.0520,19.8128,29.5090,25.8648,25.8563,20.5214]
Vswz_dn_0713_0 = [ -36.1378,-35.3487,-25.4118,-22.9297,-12.1057,-19.1379,-23.2724,-14.8829,-13.9791,-5.74354,-6.12225,-15.1837,-15.7466,-9.57345,-9.34075,-14.7443,-7.74867,-8.78665,-4.68833,4.37108,12.8612,-5.13128,0.589624,2.90983,2.14932,-0.220928,11.4042,6.61171,0.854871]
magx_dn_0713_0 = [  -2.85254,-4.38791,-5.25074,-5.71555,-5.09506,-5.07019,-3.50667,-2.03397,-0.559578,-1.03866,-1.69489,-2.30181,-3.04395,-3.78189,-3.79427,-3.02144,-2.55475,-1.68151,-1.56837,-1.88195,-2.53389,-3.19386,-4.38612,-3.68446,-3.01186,-6.66559,-8.29718,-10.2946,-8.94205]
magy_dn_0713_0 = [   9.10890, 8.98608, 9.75641, 10.9756, 12.0652, 11.9153, 11.2363, 11.0488, 10.5072, 10.8080, 10.6384, 11.7010, 11.9402, 12.2919, 11.4328, 10.6806, 9.79786, 8.81896, 9.05667, 10.4926, 12.3263, 12.6549, 10.5018, 10.0199, 10.3786, 11.5168, 10.7903, 11.5269, 10.7470]
magz_dn_0713_0 = [ -11.7891,-10.9465,-10.2212,-8.84202,-8.16173,-8.59907,-9.56875,-10.3676,-10.0322,-10.8820,-12.2061,-14.2414,-13.3400,-11.6500,-9.91840,-11.2097,-11.6609,-9.90315,-6.04828,-1.20433,-1.59500,-2.86089,-5.02634,-5.01501,-6.21976,-5.03831,-6.33364,-9.42352,-10.7958]
Vsw__dn_0713_0 = [[Vswx_dn_0713_0],[Vswy_dn_0713_0],[Vswz_dn_0713_0]]
magf_dn_0713_0 = [[magx_dn_0713_0],[magy_dn_0713_0],[magz_dn_0713_0]]

PRINT,';;', MEAN(ni___up_0713_0,/NAN), STDDEV(ni___up_0713_0,/NAN), $
            MEAN(Ti___up_0713_0,/NAN), STDDEV(Ti___up_0713_0,/NAN), $
            MEAN(Te___up_0713_0,/NAN), STDDEV(Te___up_0713_0,/NAN)
PRINT,';;', MEAN(Vswx_up_0713_0,/NAN), STDDEV(Vswx_up_0713_0,/NAN), $
            MEAN(Vswy_up_0713_0,/NAN), STDDEV(Vswy_up_0713_0,/NAN), $
            MEAN(Vswz_up_0713_0,/NAN), STDDEV(Vswz_up_0713_0,/NAN)
PRINT,';;', MEAN(magx_up_0713_0,/NAN), STDDEV(magx_up_0713_0,/NAN), $
            MEAN(magy_up_0713_0,/NAN), STDDEV(magy_up_0713_0,/NAN), $
            MEAN(magz_up_0713_0,/NAN), STDDEV(magz_up_0713_0,/NAN)

PRINT,';;', MEAN(ni___dn_0713_0,/NAN), STDDEV(ni___dn_0713_0,/NAN), $
            MEAN(Ti___dn_0713_0,/NAN), STDDEV(Ti___dn_0713_0,/NAN), $
            MEAN(Te___dn_0713_0,/NAN), STDDEV(Te___dn_0713_0,/NAN)
PRINT,';;', MEAN(Vswx_dn_0713_0,/NAN), STDDEV(Vswx_dn_0713_0,/NAN), $
            MEAN(Vswy_dn_0713_0,/NAN), STDDEV(Vswy_dn_0713_0,/NAN), $
            MEAN(Vswz_dn_0713_0,/NAN), STDDEV(Vswz_dn_0713_0,/NAN)
PRINT,';;', MEAN(magx_dn_0713_0,/NAN), STDDEV(magx_dn_0713_0,/NAN), $
            MEAN(magy_dn_0713_0,/NAN), STDDEV(magy_dn_0713_0,/NAN), $
            MEAN(magz_dn_0713_0,/NAN), STDDEV(magz_dn_0713_0,/NAN)

;;----------------------------------------------------------------------------------------
;;  Upstream
;;----------------------------------------------------------------------------------------
;;              Ni                        Ti                        Te
;;           [cm^(-3)]                   [eV]                      [eV]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;=====================================================================================
;;      7.21921     0.602077      30.1554      2.62020      11.2373      1.07062
;;----------------------------------------------------------------------------------------
;;              Vx                        Vy                        Vz
;;             [nT]                      [nT]                      [nT]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;=====================================================================================
;;     -328.746      6.31887      10.8691      16.7018      16.8013      2.52934
;;----------------------------------------------------------------------------------------
;;              Bx                        By                        Bz
;;             [nT]                      [nT]                      [nT]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;=====================================================================================
;;     -2.88930     0.155069      1.79045     0.452100     -1.37976     0.103940
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Downstream  => For 2009-07-13  1st Shock Crossing
;;----------------------------------------------------------------------------------------
;;              Ni                        Ti                        Te
;;           [cm^(-3)]                   [eV]                      [eV]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      47.8403      2.59123      158.597      12.0137      30.5007      1.83097
;;----------------------------------------------------------------------------------------
;;              Vx                        Vy                        Vz
;;            [km/s]                    [km/s]                    [km/s]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;     -97.0335      8.21710      23.6190      11.7156     -9.12016      12.3773
;;----------------------------------------------------------------------------------------
;;              Bx                        By                        Bz
;;             [nT]                      [nT]                      [nT]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;     -3.85673      2.34598      10.8180      1.05178     -8.72761      3.39877
;;----------------------------------------------------------------------------------------



;;--------------------------------------------------------------
;; => Avg. terms [2009-07-21:  1st Shock Crossing]
;;--------------------------------------------------------------
tdate          = '2009-07-21'
t_ramp_0721_0  = time_double(tdate[0]+'/'+['19:24:49.530','19:24:53.440'])
;;  Rankine-Hugoniot Solutions
Vsh__up_0721_0 = -31.373502d0
dVsh_up_0721_0 =  34.182527d0
Ush__up_0721_0 = -193.82300d0
dUsh_up_0721_0 =  37.862402d0
Ush__dn_0721_0 = -54.939813d0
dUsh_dn_0721_0 =  15.591312d0
nvec__0721_0   = [0.92298712d0,0.20655033d0,-0.25200810d0]
dnvec_0721_0   = [0.052442476d0,0.13195176d0,0.14752184d0]
;; => Upstream values
ni___up_0721_0 = [ 8.31645,8.67712,7.40630,7.18448,7.50452,7.88873,8.73496,7.81069,6.83547,6.25612,6.39171,7.14978,6.90453,6.71361,6.73797,6.82553,7.05625,8.30786,8.68102,7.58535,6.46467,6.49367]
Ti___up_0721_0 = [ 21.6582,21.2026,19.7488,14.1898,12.3766,14.7772,17.4932,15.2990,13.3706,13.7914,13.2749,13.4106,12.0070,11.4883,11.9794,13.4152,15.5948,16.5871,15.5264,18.7069,22.6503,26.0321]
Te___up_0721_0 = [ 9.78209,10.4590,9.57622,9.17588,9.79515,10.3753,10.8643,9.98958,9.00426,8.89945,8.89624,9.14434,9.63407,9.27669,8.86217,8.83323,8.73802,8.89814,8.67940,8.50978,8.47930,8.55423]
Pi___up_0721_0 = [ 5.39490,9.07063,11.9421,16.1574,13.4360,9.21660,5.79031,10.7462,13.6695,8.56959,9.19795,11.7775,11.3017,11.4303,12.8192,9.75800,11.9298,13.4080,12.4724,9.85321,8.37616,8.60284]
Vswx_up_0721_0 = [-252.029,-258.557,-263.490,-265.707,-252.372,-246.680,-261.175,-266.751,-252.098,-250.555,-239.089,-240.882,-239.284,-243.914,-252.223,-245.783,-242.810,-229.544,-250.140,-252.921,-250.559,-255.403]
Vswy_up_0721_0 = [ 44.8791,50.9423,50.6783,33.4196,36.2620,32.5607,36.8663,62.0836,53.0972,44.8767,32.2854,26.3158,29.3843,33.1976,32.5008,29.2365,16.1495,25.8645,35.0420,30.9212,26.6607,55.1723]
Vswz_up_0721_0 = [-58.0771,-55.6894,0.409801,11.7208,3.94720,9.53158,3.67480,0.906000,2.93620,36.4344,19.9558,17.2179,17.0687,18.2569,38.9549,41.9517,16.4924,5.85340,6.98320,-8.86640,10.5687,2.18210]
magx_up_0721_0 = [ 4.82229,4.63308,4.02932,3.44271,2.84037,2.64673,2.63529,2.76585,2.37972,1.98794,1.39738,1.21914,1.33689,1.94864,2.09786,2.16347,2.42387,2.92340,3.28983,3.20636,2.92434,2.70674]
magy_up_0721_0 = [ 7.16286,7.74798,7.88001,7.59663,7.83664,8.10129,7.93510,7.27559,6.48152,6.14867,6.44034,7.07130,7.35861,6.74107,6.36738,6.49178,6.70230,6.52154,6.29711,5.87689,6.14621,6.71707]
magz_up_0721_0 = [ 1.35085,2.30552,2.91280,2.22750,0.579289,-1.08373,-1.94435,-2.04222,-1.49848,-0.916376,-1.01088,-0.900823,-1.04221,-1.10592,-1.35002,-1.20860,-1.80506,-2.56793,-2.99469,-2.67470,-1.31379,-0.509691]
Vsw__up_0721_0 = [[Vswx_up_0721_0],[Vswy_up_0721_0],[Vswz_up_0721_0]]
magf_up_0721_0 = [[magx_up_0721_0],[magy_up_0721_0],[magz_up_0721_0]]
;; => Downstream values
ni___dn_0721_0 = [ 26.7586,28.4492,24.9637,25.1797,27.2801,27.8678,25.5643,26.0382,24.5717,26.4584,29.3981,26.9395,27.7959,26.8766,30.6361,28.4035,29.6536,25.9292,24.6204,24.9522,23.2756,21.3777]
Ti___dn_0721_0 = [ 100.548,93.5092,107.939,81.9885,76.8156,67.0779,76.0749,69.1720,97.6662,102.750,86.4698,63.3276,66.3187,81.6420,71.9752,77.4022,79.1747,76.6381,71.1612,59.8544,72.5566,80.3758]
Te___dn_0721_0 = [ 32.2174,34.4196,32.3686,32.1424,33.4272,34.2605,33.0202,32.8837,32.4011,32.9398,32.9646,30.0516,32.1823,31.8918,33.8783,33.9563,35.0123,33.5542,32.5527,32.2373,30.2736,28.1001]
Pi___dn_0721_0 = [ 825.650,706.367,655.767,619.270,556.276,609.732,693.746,582.394,746.231,754.591,1001.62,538.282,525.591,686.332,804.077,624.427,714.002,650.028,703.361,595.917,522.665,565.826]
Vswx_dn_0721_0 = [-83.1450,-81.0056,-91.9657,-111.816,-107.133,-92.8042,-82.6390,-84.6774,-83.4176,-103.078,-105.546,-98.1923,-113.415,-109.037,-132.620,-144.186,-142.760,-140.735,-121.504,-92.7459,-93.1047,-104.173]
Vswy_dn_0721_0 = [ 39.2251,58.7567,52.0019,37.2914,15.2087,15.0108,22.0988,38.6794,41.3678,41.7077,54.8207,50.9878,62.9462,83.8067,45.8108,83.3903,62.7107,78.7287,89.3931,102.433,83.8987,77.7204]
Vswz_dn_0721_0 = [-24.1412,-40.6965,-45.6281,-23.1093,-27.2375,-8.86086,-0.513803,16.2152,10.7205,16.7423,19.6179,35.5084,48.0457,18.4919,19.2179,9.19438,15.0469,5.77509,10.3818,8.77417,-6.88277,-2.90311]
magx_dn_0721_0 = [-1.62460,-1.10121,-0.230356,0.194179,-0.862003,-1.67913,-1.81271,-1.07904,0.506501,2.62755,5.04597,5.66349,6.70031,9.36364,9.98311,7.04585,3.14220,0.725262,-1.40031,-2.52478,-2.26054,0.166255]
magy_dn_0721_0 = [ 24.7313,24.1590,22.9509,20.8434,19.4439,17.9802,16.7569,15.9159,14.5874,13.1786,10.3931,7.94859,4.63129,5.20788,5.42506,5.63233,5.11448,5.30206,5.79441,6.61705,7.12949,4.11143]
magz_dn_0721_0 = [-1.37957,-4.92033,-8.74956,-11.3075,-13.3743,-14.2631,-14.8267,-14.0848,-15.0347,-17.7298,-22.1081,-22.8915,-21.9973,-21.0468,-21.6382,-22.4402,-22.8127,-22.8008,-21.8461,-21.8455,-21.5453,-21.1676]
Vsw__dn_0721_0 = [[Vswx_dn_0721_0],[Vswy_dn_0721_0],[Vswz_dn_0721_0]]
magf_dn_0721_0 = [[magx_dn_0721_0],[magy_dn_0721_0],[magz_dn_0721_0]]

PRINT,';;', MEAN(ni___up_0721_0,/NAN), STDDEV(ni___up_0721_0,/NAN), $
            MEAN(Ti___up_0721_0,/NAN), STDDEV(Ti___up_0721_0,/NAN), $
            MEAN(Te___up_0721_0,/NAN), STDDEV(Te___up_0721_0,/NAN)
PRINT,';;', MEAN(Vswx_up_0721_0,/NAN), STDDEV(Vswx_up_0721_0,/NAN), $
            MEAN(Vswy_up_0721_0,/NAN), STDDEV(Vswy_up_0721_0,/NAN), $
            MEAN(Vswz_up_0721_0,/NAN), STDDEV(Vswz_up_0721_0,/NAN)
PRINT,';;', MEAN(magx_up_0721_0,/NAN), STDDEV(magx_up_0721_0,/NAN), $
            MEAN(magy_up_0721_0,/NAN), STDDEV(magy_up_0721_0,/NAN), $
            MEAN(magz_up_0721_0,/NAN), STDDEV(magz_up_0721_0,/NAN)

PRINT,';;', MEAN(ni___dn_0721_0,/NAN), STDDEV(ni___dn_0721_0,/NAN), $
            MEAN(Ti___dn_0721_0,/NAN), STDDEV(Ti___dn_0721_0,/NAN), $
            MEAN(Te___dn_0721_0,/NAN), STDDEV(Te___dn_0721_0,/NAN)
PRINT,';;', MEAN(Vswx_dn_0721_0,/NAN), STDDEV(Vswx_dn_0721_0,/NAN), $
            MEAN(Vswy_dn_0721_0,/NAN), STDDEV(Vswy_dn_0721_0,/NAN), $
            MEAN(Vswz_dn_0721_0,/NAN), STDDEV(Vswz_dn_0721_0,/NAN)
PRINT,';;', MEAN(magx_dn_0721_0,/NAN), STDDEV(magx_dn_0721_0,/NAN), $
            MEAN(magy_dn_0721_0,/NAN), STDDEV(magy_dn_0721_0,/NAN), $
            MEAN(magz_dn_0721_0,/NAN), STDDEV(magz_dn_0721_0,/NAN)

;;----------------------------------------------------------------------------------------
;;  Upstream  => For 2009-07-21  1st Shock Crossing
;;----------------------------------------------------------------------------------------
;;              Ni                        Ti                        Te
;;           [cm^(-3)]                   [eV]                      [eV]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      7.36031     0.792484      16.1173      3.97285      9.29213     0.678357
;;----------------------------------------------------------------------------------------
;;              Vx                        Vy                        Vz
;;            [km/s]                    [km/s]                    [km/s]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;     -250.544      9.28732      37.1998      11.4479      6.47334      24.1953
;;----------------------------------------------------------------------------------------
;;              Bx                        By                        Bz
;;             [nT]                      [nT]                      [nT]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      2.71915     0.949583      6.94990     0.675149    -0.754250      1.63304
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Downstream  => For 2009-07-21  1st Shock Crossing
;;----------------------------------------------------------------------------------------
;;              Ni                        Ti                        Te
;;           [cm^(-3)]                   [eV]                      [eV]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      26.4995      2.17383      80.0199      13.2036      32.5789      1.55633
;;----------------------------------------------------------------------------------------
;;              Vx                        Vy                        Vz
;;            [km/s]                    [km/s]                    [km/s]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;     -105.441      20.1198      56.2725      24.5434      2.44359      23.3531
;;----------------------------------------------------------------------------------------
;;              Bx                        By                        Bz
;;             [nT]                      [nT]                      [nT]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      1.66317      3.91304      11.9934      7.21832     -17.2641      6.29739
;;----------------------------------------------------------------------------------------


;;--------------------------------------------------------------
;; => Avg. terms [2009-07-23:  1st Shock Crossing]
;;--------------------------------------------------------------
tdate          = '2009-07-23'
t_ramp_0723_0  = time_double(tdate[0]+'/'+['18:04:47.030','18:04:58.920'])
;;  Rankine-Hugoniot Solutions
Vsh__up_0723_0 = -62.207463d0
dVsh_up_0723_0 =  24.453869d0
Ush__up_0723_0 = -423.04605d0
dUsh_up_0723_0 =  25.719977d0
Ush__dn_0723_0 = -103.10106d0
dUsh_dn_0723_0 =  7.6974835d0
nvec__0723_0   = [0.99518093d0,0.021020125d0,0.011474467d0]
dnvec_0723_0   = [0.0033696292d0,0.025786150d0,0.091520592d0]
;; => Upstream values
ni___up_0723_0 = [3.97767,3.71400,3.67120,3.72781,3.64282,3.62596,3.72209,3.68114,3.62656,3.75548,3.73672,3.76154,3.86371,3.84768,3.69372]
Ti___up_0723_0 = [65.5496,66.5383,64.0601,65.4925,65.8209,64.6496,65.4988,66.0537,66.0473,67.9845,64.4572,65.8322,64.1350,63.7507,64.0134]
Te___up_0723_0 = [9.06374,9.06151,11.7931,9.29861,9.62223,9.14771,8.99538,9.02639,9.12409,9.01857,9.20982,9.22978,9.39782,9.93921,9.52153]
Pi___up_0723_0 = [16.5202,14.3821,15.0373,13.7814,13.1362,13.8643,14.4602,13.5135,13.4873,12.6477,16.4646,16.5847,14.9911,18.6817,14.9081]
Vswx_up_0723_0 = [-487.003,-491.221,-482.000,-489.754,-489.004,-488.383,-491.927,-491.405,-492.613,-496.530,-483.834,-490.901,-483.494,-479.404,-486.873]
Vswy_up_0723_0 = [ 82.7046,82.7534,82.2147,82.9912,83.2759,83.3102,83.8608,83.7969,83.3719,83.6011,81.7873,83.3698,81.7884,81.6210,83.0429]
Vswz_up_0723_0 = [-90.2416,-91.9541,-90.9088,-92.0312,-88.2150,-94.0726,-94.0077,-91.8656,-92.5525,-87.8669,-93.6643,-95.1515,-93.4061,-93.8795,-95.1282]
Vsw__up_0723_0 = [[Vswx_up_0723_0],[Vswy_up_0723_0],[Vswz_up_0723_0]]
magx_up_0723_0 = [-0.0105438,0.240829,0.335204,0.405830,0.0845831,-0.131994,-0.238947,-0.273008,-0.545304,-0.422076,-0.218986,-0.0632742,-0.111547,-0.104104,-0.201564]
magy_up_0723_0 = [-0.0170248,-0.0584700,-0.0335167,0.337760,0.222312,0.313244,0.290398,0.364247,0.253711,0.102740,-0.104149,-0.101017,-0.0151983,0.141721,-0.0126139]
magz_up_0723_0 = [  -5.83439,-5.89134,-5.78036,-5.62734,-5.73847,-5.82742,-5.88058,-5.89138,-5.98315,-6.14102,-6.09644,-6.18463,-6.57868,-6.61921,-6.55928]
magf_up_0723_0 = [[magx_up_0723_0],[magy_up_0723_0],[magz_up_0723_0]]
;; => Downstream values
ni___dn_0723_0 = [17.9649,15.0112,14.6180,15.7014,15.2841,15.6614,17.3150,15.3803,13.8548,13.9105,16.3824,14.5374,16.7691,14.8325,13.6442]
Ti___dn_0723_0 = [260.098,269.390,276.318,276.318,270.643,261.406,283.695,292.879,254.769,279.457,324.743,291.094,277.876,276.575,300.536]
Te___dn_0723_0 = [50.5250,49.0110,51.5541,52.4552,50.7236,48.8540,52.4923,50.7374,50.2526,50.7305,49.9982,56.3705,56.8171,54.3629,50.9233]
Pi___dn_0723_0 = [1561.58,1316.39,1553.81,1432.65,1475.60,1452.85,1834.08,1384.44,1202.48,1569.27,1795.81,1327.27,1742.55,1551.29,1469.19]
Vswx_dn_0723_0 = [-182.106,-154.076,-157.799,-162.897,-167.926,-133.983,-125.095,-154.407,-166.946,-214.533,-177.796,-173.203,-158.082,-191.475,-191.376]
Vswy_dn_0723_0 = [ 107.113,145.660,106.945,124.987,83.8093,116.913,81.1765,65.0305,111.839,131.283,99.3800,94.8911,99.5053,85.9613,88.6184]
Vswz_dn_0723_0 = [-83.5994,-66.1128,-69.3262,-68.2721,-91.5677,-78.5621,-52.7817,-77.4790,-82.4358,-79.4540,-79.4551,-60.5087,-54.3915,-75.7553,-66.9158]
Vsw__dn_0723_0 = [[Vswx_dn_0723_0],[Vswy_dn_0723_0],[Vswz_dn_0723_0]]
magx_dn_0723_0 = [-2.91669,-0.381075,-0.737598,-1.37121,-2.47889,-3.36334,-2.65815,-2.10047,-0.922715,-1.05123,0.648970,1.82977,1.72159,-0.734504,-3.08950]
magy_dn_0723_0 = [ 2.70848,4.45549,3.23752,3.18469,3.13658,3.36129,2.29248,2.53826,1.67842,0.156594,-0.255658,-0.200885,1.93085,1.66931,2.58318]
magz_dn_0723_0 = [-19.8145,-20.5926,-20.3435,-20.2276,-21.7872,-20.7436,-19.3119,-19.3776,-19.1816,-18.6223,-18.3615,-19.4741,-18.4206,-16.6863,-15.8009]
magf_dn_0723_0 = [[magx_dn_0723_0],[magy_dn_0723_0],[magz_dn_0723_0]]

PRINT,';;', MEAN(ni___up_0723_0,/NAN), STDDEV(ni___up_0723_0,/NAN), $
            MEAN(Ti___up_0723_0,/NAN), STDDEV(Ti___up_0723_0,/NAN), $
            MEAN(Te___up_0723_0,/NAN), STDDEV(Te___up_0723_0,/NAN)
PRINT,';;', MEAN(Vswx_up_0723_0,/NAN), STDDEV(Vswx_up_0723_0,/NAN), $
            MEAN(Vswy_up_0723_0,/NAN), STDDEV(Vswy_up_0723_0,/NAN), $
            MEAN(Vswz_up_0723_0,/NAN), STDDEV(Vswz_up_0723_0,/NAN)
PRINT,';;', MEAN(magx_up_0723_0,/NAN), STDDEV(magx_up_0723_0,/NAN), $
            MEAN(magy_up_0723_0,/NAN), STDDEV(magy_up_0723_0,/NAN), $
            MEAN(magz_up_0723_0,/NAN), STDDEV(magz_up_0723_0,/NAN)

PRINT,';;', MEAN(ni___dn_0723_0,/NAN), STDDEV(ni___dn_0723_0,/NAN), $
            MEAN(Ti___dn_0723_0,/NAN), STDDEV(Ti___dn_0723_0,/NAN), $
            MEAN(Te___dn_0723_0,/NAN), STDDEV(Te___dn_0723_0,/NAN)
PRINT,';;', MEAN(Vswx_dn_0723_0,/NAN), STDDEV(Vswx_dn_0723_0,/NAN), $
            MEAN(Vswy_dn_0723_0,/NAN), STDDEV(Vswy_dn_0723_0,/NAN), $
            MEAN(Vswz_dn_0723_0,/NAN), STDDEV(Vswz_dn_0723_0,/NAN)
PRINT,';;', MEAN(magx_dn_0723_0,/NAN), STDDEV(magx_dn_0723_0,/NAN), $
            MEAN(magy_dn_0723_0,/NAN), STDDEV(magy_dn_0723_0,/NAN), $
            MEAN(magz_dn_0723_0,/NAN), STDDEV(magz_dn_0723_0,/NAN)

;;----------------------------------------------------------------------------------------
;;  Upstream  => For 2009-07-23  1st Shock Crossing
;;----------------------------------------------------------------------------------------
;;              Ni                        Ti                        Te
;;           [cm^(-3)]                   [eV]                      [eV]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      3.73654    0.0966303      65.3256      1.15368      9.42997     0.705084
;;----------------------------------------------------------------------------------------
;;              Vx                        Vy                        Vz
;;            [km/s]                    [km/s]                    [km/s]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;     -488.290      4.57192      82.8993     0.738711     -92.3297      2.24739
;;----------------------------------------------------------------------------------------
;;              Bx                        By                        Bz
;;             [nT]                      [nT]                      [nT]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;   -0.0836601     0.264273     0.112276     0.171303     -6.04225     0.318306
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Downstream  => For 2009-07-23  1st Shock Crossing
;;----------------------------------------------------------------------------------------
;;              Ni                        Ti                        Te
;;           [cm^(-3)]                   [eV]                      [eV]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      15.3911      1.27546      279.720      17.6216      51.7205      2.41169
;;----------------------------------------------------------------------------------------
;;              Vx                        Vy                        Vz
;;            [km/s]                    [km/s]                    [km/s]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;     -167.447      22.6566      102.874      21.1822     -72.4411      11.0672
;;----------------------------------------------------------------------------------------
;;              Bx                        By                        Bz
;;             [nT]                      [nT]                      [nT]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;     -1.17367      1.65017      2.16511      1.37491     -19.2497      1.54356
;;----------------------------------------------------------------------------------------

;;--------------------------------------------------------------
;; => Avg. terms [2009-07-23:  2nd Shock Crossing]
;;--------------------------------------------------------------
tdate          = '2009-07-23'
t_ramp_0723_1  = time_double(tdate[0]+'/'+['18:07:07.340','18:07:08.100'])
;;  Rankine-Hugoniot Solutions
Vsh__up_0723_1 =  13.870709d0
dVsh_up_0723_1 =  22.547102d0
Ush__up_0723_1 = -506.46806d0
dUsh_up_0723_1 =  21.841831d0
Ush__dn_0723_1 = -138.10784d0
dUsh_dn_0723_1 =  10.702731d0
nvec__0723_1   = [0.99615338d0,-0.079060538d0,-0.0026399172d0]
dnvec_0723_1   = [0.0022296330d0,0.027727393d0,0.027471605d0]
;; => Upstream values
ni___up_0723_1 = [3.67120,3.72781,3.64282,3.62596,3.72209,3.68114,3.62656,3.75548,3.73672,3.76154,3.86371,3.84768,3.69372]
Ti___up_0723_1 = [64.0601,65.4925,65.8209,64.6496,65.4988,66.0537,66.0473,67.9845,64.4572,65.8322,64.1350,63.7507,64.0134]
Te___up_0723_1 = [11.7931,9.29861,9.62223,9.14771,8.99538,9.02639,9.12409,9.01857,9.20982,9.22978,9.39782,9.93921,9.52153]
Pi___up_0723_1 = [15.0373,13.7814,13.1362,13.8643,14.4602,13.5135,13.4873,12.6477,16.4646,16.5847,14.9911,18.6817,14.9081]
Vswx_up_0723_1 = [-482.000,-489.754,-489.004,-488.383,-491.927,-491.405,-492.613,-496.530,-483.834,-490.901,-483.494,-479.404,-486.873]
Vswy_up_0723_1 = [ 82.2147,82.9912,83.2759,83.3102,83.8608,83.7969,83.3719,83.6011,81.7873,83.3698,81.7884,81.6210,83.0429]
Vswz_up_0723_1 = [-90.9088,-92.0312,-88.2150,-94.0726,-94.0077,-91.8656,-92.5525,-87.8669,-93.6643,-95.1515,-93.4061,-93.8795,-95.1282]
Vsw__up_0723_1 = [[Vswx_up_0723_1],[Vswy_up_0723_1],[Vswz_up_0723_1]]
magx_up_0723_1 = [ 0.335204,0.405830,0.0845831,-0.131994,-0.238947,-0.273008,-0.545304,-0.422076,-0.218986,-0.0632742,-0.111547,-0.104104,-0.201564]
magy_up_0723_1 = [-0.0335167,0.337760,0.222312,0.313244,0.290398,0.364247,0.253711,0.102740,-0.104149,-0.101017,-0.0151983,0.141721,-0.0126139]
magz_up_0723_1 = [-5.78036,-5.62734,-5.73847,-5.82742,-5.88058,-5.89138,-5.98315,-6.14102,-6.09644,-6.18463,-6.57868,-6.61921,-6.55928]
magf_up_0723_1 = [[magx_up_0723_1],[magy_up_0723_1],[magz_up_0723_1]]
;; => Downstream values
ni___dn_0723_1 = [13.2894,13.6633,13.7414,13.6178,14.4607,13.2577,13.0477,13.7580,14.9694,14.3119,13.3839,12.6570,13.6572]
Ti___dn_0723_1 = [274.114,275.811,277.693,300.393,289.701,288.121,281.954,274.758,276.977,278.557,282.944,284.283,269.985]
Te___dn_0723_1 = [63.9186,65.5380,67.3512,67.2182,67.3051,67.2898,66.3465,65.8355,69.2972,68.1353,65.6077,66.4209,66.1748]
Pi___dn_0723_1 = [1071.78,1177.16,1139.29,1280.31,1257.76,1096.16,1181.50,1234.66,1281.25,1137.22,1157.43,1019.11,1139.81]
Vswx_dn_0723_1 = [-125.706,-112.693,-111.996,-128.721,-107.861,-95.8961,-143.758,-135.034,-119.948,-120.902,-91.1511,-118.182,-133.010]
Vswy_dn_0723_1 = [ 76.0840,63.2844,57.5193,80.8170,68.2826,91.5688,95.0344,65.2426,66.0857,73.0200,81.1880,91.4464,80.7675]
Vswz_dn_0723_1 = [-61.9742,-45.0366,-41.5559,-61.9839,-40.8061,-84.7842,-100.362,-48.9528,-50.3166,-66.2105,-58.4715,-78.5976,-67.7298]
Vsw__dn_0723_1 = [[Vswx_dn_0723_1],[Vswy_dn_0723_1],[Vswz_dn_0723_1]]
magx_dn_0723_1 = [ 2.31985,2.84931,2.91280,2.35022,1.66521,0.930442,0.418488,0.609328,0.0646042,-0.0506223,1.85531,1.98113,1.42087]
magy_dn_0723_1 = [-20.9550,-19.6662,-18.3171,-16.6167,-17.0777,-17.7718,-18.9824,-18.1475,-16.0553,-14.8431,-16.2384,-16.9300,-17.5406]
magz_dn_0723_1 = [-16.2034,-13.6225,-11.8529,-12.6840,-13.4321,-14.2577,-14.7117,-16.0638,-18.1507,-17.9198,-17.1805,-16.6652,-17.3524]
magf_dn_0723_1 = [[magx_dn_0723_1],[magy_dn_0723_1],[magz_dn_0723_1]]

PRINT,';;', MEAN(ni___up_0723_1,/NAN), STDDEV(ni___up_0723_1,/NAN), $
            MEAN(Ti___up_0723_1,/NAN), STDDEV(Ti___up_0723_1,/NAN), $
            MEAN(Te___up_0723_1,/NAN), STDDEV(Te___up_0723_1,/NAN)
PRINT,';;', MEAN(Vswx_up_0723_1,/NAN), STDDEV(Vswx_up_0723_1,/NAN), $
            MEAN(Vswy_up_0723_1,/NAN), STDDEV(Vswy_up_0723_1,/NAN), $
            MEAN(Vswz_up_0723_1,/NAN), STDDEV(Vswz_up_0723_1,/NAN)
PRINT,';;', MEAN(magx_up_0723_1,/NAN), STDDEV(magx_up_0723_1,/NAN), $
            MEAN(magy_up_0723_1,/NAN), STDDEV(magy_up_0723_1,/NAN), $
            MEAN(magz_up_0723_1,/NAN), STDDEV(magz_up_0723_1,/NAN)

PRINT,';;', MEAN(ni___dn_0723_1,/NAN), STDDEV(ni___dn_0723_1,/NAN), $
            MEAN(Ti___dn_0723_1,/NAN), STDDEV(Ti___dn_0723_1,/NAN), $
            MEAN(Te___dn_0723_1,/NAN), STDDEV(Te___dn_0723_1,/NAN)
PRINT,';;', MEAN(Vswx_dn_0723_1,/NAN), STDDEV(Vswx_dn_0723_1,/NAN), $
            MEAN(Vswy_dn_0723_1,/NAN), STDDEV(Vswy_dn_0723_1,/NAN), $
            MEAN(Vswz_dn_0723_1,/NAN), STDDEV(Vswz_dn_0723_1,/NAN)
PRINT,';;', MEAN(magx_dn_0723_1,/NAN), STDDEV(magx_dn_0723_1,/NAN), $
            MEAN(magy_dn_0723_1,/NAN), STDDEV(magy_dn_0723_1,/NAN), $
            MEAN(magz_dn_0723_1,/NAN), STDDEV(magz_dn_0723_1,/NAN)

;;----------------------------------------------------------------------------------------
;;  Upstream  => For 2009-07-23  2nd Shock Crossing
;;----------------------------------------------------------------------------------------
;;              Ni                        Ti                        Te
;;           [cm^(-3)]                   [eV]                      [eV]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      3.71973    0.0754965      65.2151      1.18863      9.48648     0.744345
;;----------------------------------------------------------------------------------------
;;              Vx                        Vy                        Vz
;;            [km/s]                    [km/s]                    [km/s]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;     -488.163      4.84921      82.9255     0.794332     -92.5192      2.34063
;;----------------------------------------------------------------------------------------
;;              Bx                        By                        Bz
;;             [nT]                      [nT]                      [nT]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;    -0.114245     0.266921     0.135357     0.172730     -6.06984     0.334488
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Downstream  => For 2009-07-23  2nd Shock Crossing
;;----------------------------------------------------------------------------------------
;;              Ni                        Ti                        Te
;;           [cm^(-3)]                   [eV]                      [eV]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      13.6781     0.615815      281.176      8.08957      66.6491      1.34425
;;----------------------------------------------------------------------------------------
;;              Vx                        Vy                        Vz
;;            [km/s]                    [km/s]                    [km/s]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;     -118.835      15.0911      76.1801      11.9073     -62.0601      17.7737
;;----------------------------------------------------------------------------------------
;;              Bx                        By                        Bz
;;             [nT]                      [nT]                      [nT]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      1.48669      1.01459     -17.6263      1.62797     -15.3921      2.08872
;;----------------------------------------------------------------------------------------

;;--------------------------------------------------------------
;; => Avg. terms [2009-07-23:  3rd Shock Crossing]
;;--------------------------------------------------------------
tdate          = '2009-07-23'
t_ramp_0723_2  = time_double(tdate[0]+'/'+['18:24:24.910','18:24:49.450'])
;;  Rankine-Hugoniot Solutions
Vsh__up_0723_2 = -33.929926d0
dVsh_up_0723_2 =  44.366165d0
Ush__up_0723_2 = -415.52490d0
dUsh_up_0723_2 =  42.829938d0
Ush__dn_0723_2 = -151.38092d0
dUsh_dn_0723_2 =  30.255039d0
nvec__0723_2   = [0.99282966d0,0.064151304d0,-0.0022364971d0]
dnvec_0723_2   = [0.0058436502d0,0.054022891d0,0.084956913d0]
;; => Upstream values
ni___up_0723_2 = [3.87978,4.02949,3.97400,4.02469,3.87947,3.82145,3.97892,3.86782,3.98627,3.74739,4.02029,3.89604,3.88569,3.67088,3.69350,3.68523,3.80416,4.22227,3.83394,3.92443,3.79381]
Ti___up_0723_2 = [53.0733,49.8847,53.6912,52.0637,53.6598,53.2007,54.0271,53.5525,52.9476,54.1991,50.4541,56.5445,56.4940,55.0889,54.1660,55.3461,53.7913,54.1387,52.6246,50.8885,52.6414]
Te___up_0723_2 = [13.9286,13.4895,13.7067,13.8220,13.4529,13.3576,13.5780,13.1160,12.6409,13.4283,13.8322,13.2141,14.0428,14.2817,14.5634,15.4813,15.4137,13.8568,15.4330,15.4635,15.5006]
Pi___up_0723_2 = [27.1307,27.9698,25.7457,30.1200,25.5771,27.5005,30.9568,27.3358,29.1494,26.1212,27.3030,24.2919,26.7611,23.7249,23.6632,22.6117,24.5500,24.6567,25.4853,24.6362,26.0832]
Vswx_up_0723_2 = [-457.390,-454.220,-456.068,-459.762,-455.623,-460.209,-464.107,-460.368,-458.292,-457.150,-454.088,-455.623,-459.200,-456.180,-455.331,-451.511,-453.297,-453.473,-452.444,-454.085,-456.378]
Vswy_up_0723_2 = [ 57.8830,60.7526,58.4751,57.1817,59.3558,57.2762,54.2417,55.4526,57.0741,57.1308,60.4539,55.0635,53.4701,55.6929,55.7119,56.6511,58.9375,59.6777,60.2901,62.9608,60.3403]
Vswz_up_0723_2 = [ 9.21621,10.7170,6.75681,12.8476,5.75498,11.3815,14.4844,11.8958,10.4295,8.03443,9.83993,3.49662,7.55206,6.65678,7.71321,2.72581,3.39370,2.31416,4.49266,5.94652,6.72869]
Vsw__up_0723_2 = [[Vswx_up_0723_2],[Vswy_up_0723_2],[Vswz_up_0723_2]]
magx_up_0723_2 = [ 3.68796,3.72186,3.69076,3.55824,3.50687,3.47899,3.43815,3.66072,3.85748,3.98805,4.07641,3.95551,3.81591,3.82316,4.01652,4.17722,4.25944,4.26528,4.25180,4.31157,4.12299]
magy_up_0723_2 = [-5.39062,-5.48992,-5.31667,-5.13549,-5.11102,-4.95301,-5.19379,-4.90067,-4.68617,-4.68304,-4.70102,-4.86403,-5.19892,-5.10300,-5.12620,-4.96838,-4.99549,-4.48578,-4.50716,-4.39669,-4.82380]
magz_up_0723_2 = [ 1.25301,0.999728,1.01717,1.13241,1.13094,1.68317,1.66111,1.47220,1.08976,1.06122,1.17932,1.11647,1.13662,1.38832,1.15572,1.03985,0.967024,0.953630,0.493382,0.683120,0.960400]
magf_up_0723_2 = [[magx_up_0723_2],[magy_up_0723_2],[magz_up_0723_2]]
;; => Downstream values
ni___dn_0723_2 = [9.28193,11.6102,9.54294,12.9192,12.1674,10.9958,11.7270,14.3654,10.5688,10.0051,9.86919,10.5606,11.1192,9.96580,9.48013,10.8892,12.8338,12.2765,11.4739,8.77951,8.73243]
Ti___dn_0723_2 = [371.217,339.322,374.439,280.702,311.467,295.543,248.818,315.631,320.660,307.128,277.508,426.758,287.702,303.414,346.943,308.321,277.596,276.881,297.313,287.266,277.411]
Te___dn_0723_2 = [52.3136,55.5987,57.9898,61.0277,59.3392,52.9494,61.1086,56.8372,55.2493,51.9238,58.3847,55.1813,55.1369,61.2118,55.6507,57.3593,59.6361,55.2512,60.0513,56.0318,54.3360]
Pi___dn_0723_2 = [1396.88,1484.79,1434.61,1509.75,1764.07,1505.02,1050.70,1940.56,1716.34,1463.09,1078.13,1775.94,1362.03,1273.29,814.869,1215.36,1512.20,1330.94,1348.34,1027.55,1052.81]
Vswx_dn_0723_2 = [-184.294,-169.251,-176.650,-165.316,-184.580,-244.271,-213.936,-216.950,-225.803,-176.844,-204.692,-193.965,-199.094,-201.013,-194.280,-181.057,-143.342,-140.175,-212.258,-187.314,-214.260]
Vswy_dn_0723_2 = [ 97.9446,69.2749,71.5579,65.7948,96.8973,75.3565,87.3190,97.8629,79.6041,48.6829,35.9421,82.2121,82.1494,92.0291,86.1183,98.9700,79.1636,55.8665,85.8108,120.943,82.8011]
Vswz_dn_0723_2 = [ 6.15394,-21.0360,-15.9439,-29.6636,-52.5194,-3.93785,-48.6716,27.8878,-12.5502,17.6192,25.6328,11.6890,-13.4597,-27.7108,-16.4757,6.79671,-0.724971,-29.6154,-21.9408,5.26594,31.3005]
Vsw__dn_0723_2 = [[Vswx_dn_0723_2],[Vswy_dn_0723_2],[Vswz_dn_0723_2]]
magx_dn_0723_2 = [ 3.90427,2.62785,1.80094,1.97481,3.50584,5.12203,5.78735,6.11337,5.28903,4.28592,3.35653,4.19374,5.54164,6.32142,6.70809,5.16462,1.52357,0.513950,2.69081,4.85474,5.49718]
magy_dn_0723_2 = [-14.8492,-13.8413,-14.1380,-14.5578,-14.3720,-15.7977,-16.0209,-16.7703,-16.2655,-15.6551,-14.4456,-14.7066,-14.7703,-16.4809,-18.6337,-17.9369,-15.9375,-14.4299,-15.2176,-15.7854,-15.8001]
magz_dn_0723_2 = [ 4.76063,4.83134,3.74214,3.38846,3.41878,3.17021,2.48103,3.15636,4.24912,4.08458,3.28272,2.27957,3.01599,2.38633,1.81811,2.36554,2.30287,2.17626,1.50555,1.56769,2.24034]
magf_dn_0723_2 = [[magx_dn_0723_2],[magy_dn_0723_2],[magz_dn_0723_2]]

PRINT,';;', MEAN(ni___up_0723_2,/NAN), STDDEV(ni___up_0723_2,/NAN), $
            MEAN(Ti___up_0723_2,/NAN), STDDEV(Ti___up_0723_2,/NAN), $
            MEAN(Te___up_0723_2,/NAN), STDDEV(Te___up_0723_2,/NAN)
PRINT,';;', MEAN(Vswx_up_0723_2,/NAN), STDDEV(Vswx_up_0723_2,/NAN), $
            MEAN(Vswy_up_0723_2,/NAN), STDDEV(Vswy_up_0723_2,/NAN), $
            MEAN(Vswz_up_0723_2,/NAN), STDDEV(Vswz_up_0723_2,/NAN)
PRINT,';;', MEAN(magx_up_0723_2,/NAN), STDDEV(magx_up_0723_2,/NAN), $
            MEAN(magy_up_0723_2,/NAN), STDDEV(magy_up_0723_2,/NAN), $
            MEAN(magz_up_0723_2,/NAN), STDDEV(magz_up_0723_2,/NAN)

PRINT,';;', MEAN(ni___dn_0723_2,/NAN), STDDEV(ni___dn_0723_2,/NAN), $
            MEAN(Ti___dn_0723_2,/NAN), STDDEV(Ti___dn_0723_2,/NAN), $
            MEAN(Te___dn_0723_2,/NAN), STDDEV(Te___dn_0723_2,/NAN)
PRINT,';;', MEAN(Vswx_dn_0723_2,/NAN), STDDEV(Vswx_dn_0723_2,/NAN), $
            MEAN(Vswy_dn_0723_2,/NAN), STDDEV(Vswy_dn_0723_2,/NAN), $
            MEAN(Vswz_dn_0723_2,/NAN), STDDEV(Vswz_dn_0723_2,/NAN)
PRINT,';;', MEAN(magx_dn_0723_2,/NAN), STDDEV(magx_dn_0723_2,/NAN), $
            MEAN(magy_dn_0723_2,/NAN), STDDEV(magy_dn_0723_2,/NAN), $
            MEAN(magz_dn_0723_2,/NAN), STDDEV(magz_dn_0723_2,/NAN)

;;----------------------------------------------------------------------------------------
;;  Upstream  => For 2009-07-23  3rd Shock Crossing
;;----------------------------------------------------------------------------------------
;;              Ni                        Ti                        Te
;;           [cm^(-3)]                   [eV]                      [eV]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      3.88664     0.134959      53.4513      1.72039      14.0764     0.889138
;;----------------------------------------------------------------------------------------
;;              Vx                        Vy                        Vz
;;            [km/s]                    [km/s]                    [km/s]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;     -456.419      3.07916      57.8130      2.43831      7.73230      3.44424
;;----------------------------------------------------------------------------------------
;;              Bx                        By                        Bz
;;             [nT]                      [nT]                      [nT]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      3.88880     0.281929     -4.95385     0.300397      1.12260     0.276117
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Downstream  => For 2009-07-23  3rd Shock Crossing
;;----------------------------------------------------------------------------------------
;;              Ni                        Ti                        Te
;;           [cm^(-3)]                   [eV]                      [eV]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      10.9126      1.47530      311.050      41.3437      56.7890      2.85963
;;----------------------------------------------------------------------------------------
;;              Vx                        Vy                        Vz
;;            [km/s]                    [km/s]                    [km/s]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;     -191.874      25.6810      80.5858      18.9172     -7.70972      23.6448
;;----------------------------------------------------------------------------------------
;;              Bx                        By                        Bz
;;             [nT]                      [nT]                      [nT]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      4.13227      1.74997     -15.5434      1.23118      2.96303     0.978853
;;----------------------------------------------------------------------------------------

;;--------------------------------------------------------------
;; => Avg. terms [2009-09-26:  1st Shock Crossing]
;;--------------------------------------------------------------
tdate          = '2009-09-26'
t_ramp_0926_0  = time_double(tdate[0]+'/'+['15:53:09.911','15:53:10.249'])
;;  Rankine-Hugoniot Solutions
Vsh__up_0926_0 =  26.234589d0
dVsh_up_0926_0 =  52.313493d0
Ush__up_0926_0 = -335.99324d0
dUsh_up_0926_0 =  52.654444d0
Ush__dn_0926_0 = -83.998692d0
dUsh_dn_0926_0 =  27.801075d0
nvec__0926_0   = [0.95576882d0,-0.18012919d0,-0.14100009d0]
dnvec_0926_0   = [0.036592179d0,0.14968821d0,0.10214679d0]
;; => Upstream values
ni___up_0926_0 = [10.1750, 10.2519, 10.6680, 10.2055, 9.89727, 9.99307, 10.2371, 10.1018, 9.97452, 10.8044, 10.9739, 10.7646, 10.2334, 10.2007, 9.79817, 9.64946, 9.68228, 9.71454, 9.54495, 9.34778, 9.52771, 9.50748, 9.46301, 9.41494, 9.56481, 9.27690, 9.46221, 9.44627, 9.37611, 9.29419, 9.31954, 9.36698, 9.25268, 9.35992, 9.25105, 9.27384, 9.28262, 9.25927, 9.33772, 9.32135, 9.31347, 9.18663, 9.23708, 9.13550, 9.30123, 9.24070, 9.35649]
Ti___up_0926_0 = [17.3031, 17.7837, 17.4467, 17.8108, 17.3261, 16.3385, 16.3229, 16.3565, 15.9304, 15.9644, 16.4148, 16.5065, 16.4434, 16.7638, 17.2751, 16.4693, 16.4833, 16.3718, 17.0711, 17.9523, 18.4387, 19.2641, 19.3064, 18.6624, 17.7173, 18.1263, 18.4729, 18.7454, 19.1002, 18.5600, 18.8654, 17.2574, 17.2682, 17.7783, 17.4605, 17.5560, 18.2365, 17.4367, 16.9279, 17.3284, 17.0259, 17.7970, 18.0815, 18.0111, 17.9549, 18.1054, 18.0018]
Te___up_0926_0 = [7.54220, 7.18316, 7.01901, 7.10218, 7.24217, 7.26266, 7.19197, 7.30242, 7.35943, 6.91630, 6.93237, 7.46398, 8.02054, 8.22043, 8.40589, 8.50220, 8.29327, 8.00057, 8.14369, 7.98348, 8.10905, 7.96816, 8.09334, 8.09133, 8.07516, 8.20751, 8.12963, 8.10384, 8.09978, 8.09482, 8.09001, 8.06044, 8.09918, 8.11355, 8.12675, 8.08080, 8.07775, 8.04926, 8.09689, 8.05681, 8.08357, 8.08696, 8.05225, 8.05078, 8.00139, 7.98805, 8.02376]
Pi___up_0926_0 = [41.2801,41.0838,44.0407,42.2054,37.6330,40.1492,39.8442,40.2163,38.3710,36.4940,43.4373,40.9162,37.3251,39.5442,41.8553,36.3296,38.0423,33.1364,35.9360,35.8962,36.7774,39.3493,38.8669,34.8362,36.6627,36.8638,34.5443,37.3070,37.3947,35.8063,41.5225,36.1383,33.3680,37.7984,36.4864,36.7463,45.6962,36.6921,33.7487,36.8639,36.2375,38.6628,37.5789,33.2816,40.6183,35.8652,34.9141]
Vswx_up_0926_0 = [-308.248,-308.331,-307.685,-308.383,-307.601,-307.439,-307.619,-307.304,-307.552,-308.255,-308.312,-308.038,-308.053,-309.373,-308.286,-309.036,-308.429,-309.183,-308.780,-309.237,-308.702,-307.427,-307.210,-307.812,-308.723,-307.266,-307.212,-306.402,-306.396,-306.978,-306.444,-306.668,-307.103,-306.672,-306.403,-306.423,-305.580,-306.131,-306.638,-306.005,-305.950,-305.801,-305.617,-306.348,-305.734,-306.023,-306.381]
Vswy_up_0926_0 = [ 65.0792, 64.4740, 64.0694, 65.1133, 65.0895, 64.9151, 64.9828, 64.7751, 65.0199, 64.0941, 64.2370, 64.2741, 64.6372, 64.4910, 64.5212, 64.6191, 65.1066, 65.4339, 66.0004, 66.0444, 66.1392, 65.8663, 65.8215, 65.8632, 65.5147, 65.1858, 65.6235, 65.1397, 65.0773, 64.9604, 64.7952, 64.8360, 65.2578, 65.2244, 65.0874, 64.9837, 64.9865, 65.1512, 65.2184, 65.1603, 65.2315, 65.2461, 64.9970, 65.1154, 65.1402, 65.3936, 65.3629]
Vswz_up_0926_0 = [ 30.9175, 31.0209, 30.8140, 30.9754, 30.9223, 30.8957, 31.1708, 30.6952, 30.8581, 30.4287, 30.4940, 30.6673, 30.9990, 31.1220, 30.7051, 31.0446, 30.8639, 30.8487, 30.3016, 30.2290, 29.7231, 29.8089, 29.9831, 29.9446, 30.5599, 29.8906, 29.7611, 29.9835, 29.6699, 29.9899, 29.9228, 30.1373, 30.0850, 30.0415, 30.0739, 29.9680, 30.1636, 29.9838, 30.2990, 30.3468, 30.2102, 30.4058, 29.9855, 29.9775, 30.1474, 30.3385, 30.3677]
Vsw__up_0926_0 = [[Vswx_up_0926_0],[Vswy_up_0926_0],[Vswz_up_0926_0]]
magx_up_0926_0 = [0.539030,0.451160,0.391541,0.472687,0.632789,0.723981,0.774325,0.768864,0.563162,0.260075,0.178430,0.412024,0.712158,0.961908, 1.17036, 1.38393, 1.53888, 1.66739, 1.75253, 1.82763, 1.91354, 2.02077, 2.06586, 1.95444, 1.84549, 1.81248, 1.93002, 1.98123, 1.99954, 2.00673, 2.01823, 2.03881, 2.02448, 2.05243, 2.09080, 2.12099, 2.11079, 2.11162, 2.10326, 2.11945, 2.12616, 2.15509, 2.18029, 2.19338, 2.19412, 2.17286, 2.20137]
magy_up_0926_0 = [0.376450,0.317214,0.318816,0.452200,0.513873,0.471051,0.468042,0.487927,0.406179,0.245129,0.150913,0.260497,0.441486,0.367694,0.186011,-0.0914053,-0.399943,-0.588198,-0.574804,-0.530085,-0.624922,-0.778180,-0.815810,-0.650044,-0.413276,-0.252649,-0.331172,-0.350610,-0.358032,-0.354325,-0.362827,-0.378941,-0.361666,-0.379539,-0.414130,-0.455942,-0.445730,-0.424583,-0.396928,-0.393605,-0.397243,-0.422042,-0.462380,-0.440814,-0.421097,-0.417044,-0.475778]
magz_up_0926_0 = [-2.12865,-1.61294,-1.52161,-2.12758,-2.70308,-2.71448,-2.64465,-2.56646,-1.90999,-0.992147,-0.667366,-1.33779,-2.08065,-2.41507,-2.49053,-2.44458,-2.39960,-2.39451,-2.47762,-2.55402,-2.55581,-2.55173,-2.55330,-2.62289,-2.84765,-3.07429,-3.19819,-3.19190,-3.17801,-3.17028,-3.21131,-3.23113,-3.21350,-3.17586,-3.15131,-3.14014,-3.14539,-3.17538,-3.18586,-3.17537,-3.15244,-3.15256,-3.16821,-3.17172,-3.16176,-3.13668,-3.11919]
magf_up_0926_0 = [[magx_up_0926_0],[magy_up_0926_0],[magz_up_0926_0]]
;; => Downstream values
ni___dn_0926_0 = [51.2807,  39.8521,  42.3309,  41.8088,  41.4283,  34.7453,  32.3157,  27.9335,  38.5888,  34.7293,  35.9572,  38.3306,  34.9899,  34.5030,  34.5102,  32.8494,  31.1677,  59.3049,  56.0503,  52.2954,  47.0918,  38.4232,  34.8014,  31.2356,  33.6516,  34.7316,  44.7045,  40.7481,  38.8098,  47.7669,  44.5358,  41.5392,  41.2920,  46.8744,  42.8679,  41.0134,  41.5094,  39.1047,  36.7082,  39.8633,  45.4496,  43.7456,  40.2756,  39.2106,  50.4380,  40.7411,  44.4163]
Ti___dn_0926_0 = [95.7072,  134.037,  161.849,  160.637,  142.532,  136.217,  110.494,  123.280,  105.296,  134.458,  149.748,  168.819,  176.089,  193.702,  183.337,  188.860,  198.404,  76.8404,  85.4134,  93.0411,  101.417,  118.737,  126.797,  150.903,  158.344,  159.788,  134.656,  138.295,  169.665,  160.161,  177.165,  176.592,  156.212,  127.959,  137.280,  140.414,  131.501,  131.148,  162.831,  159.025,  143.044,  161.959,  174.427,  168.548,  123.477,  162.399,  158.369]
Te___dn_0926_0 = [36.5180,  35.2009,  35.9544,  36.2169,  35.4092,  31.7854,  29.0767,  30.9599,  34.3411,  34.8840,  30.4523,  30.9078,  30.6028,  30.8194,  28.9409,  28.7399,  31.2331,  34.1736,  35.9484,  33.5409,  33.0489,  31.2693,  29.8900,  28.3571,  29.7205,  29.2051,  32.7504,  35.2441,  35.4527,  36.5012,  32.5789,  30.1712,  30.2689,  29.2071,  28.1554,  27.6365,  28.9796,  28.9122,  27.5209,  25.1513,  26.8687,  26.1318,  27.0416,  27.0398,  29.5822,  26.8995,  29.3162]
Pi___dn_0926_0 = [1690.27,1682.66,2056.93,2004.21,2007.66,1830.46,1104.01,948.671,949.616,1139.33,1528.05,1855.19,1902.96,2121.97,1895.67,1827.12,1959.59,415.216,800.526,609.486,604.507,546.433,1260.00,1457.46,1456.54,1422.85,1919.43,1678.44,2206.23,2327.19,2300.33,2001.67,1921.92,1697.46,1652.63,1564.15,1380.87,1401.02,1910.14,2051.85,1776.31,1995.80,1982.51,2166.34,1971.34,2117.13,2312.81]
Vswx_dn_0926_0 = [ -25.4994, -45.7480, -72.1865, -77.6769, -65.6743, -39.1723, -8.34684,  17.9678,  20.1265,  1.61087, -21.3947, -29.0281, -27.2127, -45.1444, -49.0774, -56.9544, -61.6982, -52.8742, -51.4495, -51.9390, -51.1274, -64.5989, -70.4701, -73.4811, -59.2671, -52.2505, -29.6874, -25.0420, -60.3114, -80.2285, -89.9489, -79.7766, -73.7767, -90.9597, -85.5819, -82.1049, -70.7076, -79.5781, -73.9472, -69.9785, -74.4217, -52.8274, -62.5313, -61.6290, -63.6716, -82.9721, -80.6074]
Vswy_dn_0926_0 = [  40.8973,  35.3533,  27.8411,  37.0950,  14.3749,  33.0941,  61.2519,  58.8875,  65.1205,  48.5454,  33.9583,  16.3115,  21.3317,  14.2371,  18.1893,  19.9961,  28.4073,  49.5290,  49.8326,  46.0163,  31.1847,  41.1102,  36.1862,  29.1360,  60.2971,  62.3892,  61.9627,  77.3767,  41.0058,  19.2727,  50.1258,  43.2972,  57.7139,  71.4168,  65.6601,  64.4855,  65.3104,  51.9035,  50.0763,  54.5534,  72.9928,  66.3091,  51.5509,  49.8943,  32.3212,  2.20119,  13.5236]
Vswz_dn_0926_0 = [ -83.6648, -74.7296, -42.3828, -16.3277, -17.0086, -22.1732, -36.3566, -53.5105, -76.1988, -62.9032, -40.3697, -5.08504, -7.43344, -31.4889, -47.8286, -47.5572, -32.0026,  6.52436,-0.997163,  1.39399,  5.39589,  5.10838,  13.2067,  19.3346, 0.280401, -16.9490, -36.0265, -36.5667, -9.93902, -2.54986, -28.3441, -31.6567, -41.7064, -20.7572, -8.11929,-0.0407284,  1.51577,  9.98874,  18.1715,  14.8673, -22.4462, -40.5534, -40.7049, -17.8107,  31.1629,  44.5896,  16.8196]
Vsw__dn_0926_0 = [[Vswx_dn_0926_0],[Vswy_dn_0926_0],[Vswz_dn_0926_0]]
magx_dn_0926_0 = [-3.46212, 0.277606,  1.50904,  3.81814,  2.39367, -5.47264, -12.9133, -17.0394, -16.0713, -11.1219, -4.61136,-0.737474, -2.76983, -2.03552,  2.67844,  6.26463,  2.00854, -2.41907,-0.661934,-0.737852,  2.20109,  5.63559,  9.56630,  10.4405,  6.62530, -2.80418, -12.1443, -18.0625, -14.3897, -7.71272, -2.08059, -3.93137, -3.24119, 0.321162,  6.75144,  8.07104,  8.25286,  9.11851,  5.24497,  1.02207, -3.41091, -2.55661, -2.59023, -4.72169, -5.61627, -3.60641, -4.93106]
magy_dn_0926_0 = [-17.2176, -14.2944, -15.1767, -12.3076, -12.1716, -13.5688, -16.6461, -17.3894, -15.6899, -12.5345, -10.0732, -11.7797, -12.8379, -10.7929, -6.19019, -5.72429, -10.7330, -18.9398, -15.6494, -12.9524, -11.4892, -9.93854, -9.00256, -10.0186, -14.0015, -15.3587, -11.5514, -4.86638, 0.876418,-0.347972, -6.52887, -13.9091, -18.8092, -22.8607, -24.6529, -23.0193, -20.7042, -22.5979, -28.3109, -28.7305, -23.7541, -17.1637, -15.4824, -13.9555, -11.7434, -10.5038, -16.4892]
magz_dn_0926_0 = [ 15.2252,  11.8528, 0.599781, -5.88957, -2.23424,  7.10765,  16.5026,  22.7687,  26.9863,  31.1050,  29.0421,  21.1216,  11.6038,  10.1390,  9.11810,  1.96387, -9.30237, -14.2561, -17.0360, -12.2422, -13.0613, -12.3308, -11.5765, -8.95790,  1.62489,  11.3131,  12.7343,  2.98079, -1.75576, -1.50255,  2.86077,  3.00969,  4.18200,  2.08599,-0.754477, -1.45570, -3.14523, -6.04861, -9.47255, -7.70862, -1.29381,  3.16446,  1.61843, -8.27763, -16.4440, -20.5350, -16.1966]
magf_dn_0926_0 = [[magx_dn_0926_0],[magy_dn_0926_0],[magz_dn_0926_0]]

PRINT,';;', MEAN(ni___up_0926_0,/NAN), STDDEV(ni___up_0926_0,/NAN), $
            MEAN(Ti___up_0926_0,/NAN), STDDEV(Ti___up_0926_0,/NAN), $
            MEAN(Te___up_0926_0,/NAN), STDDEV(Te___up_0926_0,/NAN)
PRINT,';;', MEAN(Vswx_up_0926_0,/NAN), STDDEV(Vswx_up_0926_0,/NAN), $
            MEAN(Vswy_up_0926_0,/NAN), STDDEV(Vswy_up_0926_0,/NAN), $
            MEAN(Vswz_up_0926_0,/NAN), STDDEV(Vswz_up_0926_0,/NAN)
PRINT,';;', MEAN(magx_up_0926_0,/NAN), STDDEV(magx_up_0926_0,/NAN), $
            MEAN(magy_up_0926_0,/NAN), STDDEV(magy_up_0926_0,/NAN), $
            MEAN(magz_up_0926_0,/NAN), STDDEV(magz_up_0926_0,/NAN)

PRINT,';;', MEAN(ni___dn_0926_0,/NAN), STDDEV(ni___dn_0926_0,/NAN), $
            MEAN(Ti___dn_0926_0,/NAN), STDDEV(Ti___dn_0926_0,/NAN), $
            MEAN(Te___dn_0926_0,/NAN), STDDEV(Te___dn_0926_0,/NAN)
PRINT,';;', MEAN(Vswx_dn_0926_0,/NAN), STDDEV(Vswx_dn_0926_0,/NAN), $
            MEAN(Vswy_dn_0926_0,/NAN), STDDEV(Vswy_dn_0926_0,/NAN), $
            MEAN(Vswz_dn_0926_0,/NAN), STDDEV(Vswz_dn_0926_0,/NAN)
PRINT,';;', MEAN(magx_dn_0926_0,/NAN), STDDEV(magx_dn_0926_0,/NAN), $
            MEAN(magy_dn_0926_0,/NAN), STDDEV(magy_dn_0926_0,/NAN), $
            MEAN(magz_dn_0926_0,/NAN), STDDEV(magz_dn_0926_0,/NAN)

;;----------------------------------------------------------------------------------------
;;  Upstream  => For 2009-09-26  1st Shock Crossing
;;----------------------------------------------------------------------------------------
;;              Ni                        Ti                        Te
;;           [cm^(-3)]                   [eV]                      [eV]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      9.66698     0.484926      17.5281     0.892424      7.87657     0.416909
;;----------------------------------------------------------------------------------------
;;              Vx                        Vy                        Vz
;;            [km/s]                    [km/s]                    [km/s]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;     -307.345      1.08234      65.0927     0.482694      30.3775     0.435846
;;----------------------------------------------------------------------------------------
;;              Bx                        By                        Bz
;;             [nT]                      [nT]                      [nT]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      1.54738     0.689430    -0.185112     0.402028     -2.65947     0.633227
;;----------------------------------------------------------------------------------------


;;----------------------------------------------------------------------------------------
;;  Downstream  => For 2009-09-26  1st Shock Crossing
;;----------------------------------------------------------------------------------------
;;              Ni                        Ti                        Te
;;           [cm^(-3)]                   [eV]                      [eV]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;      40.5643      6.55724      145.316      28.7393      31.0342      3.17635
;;----------------------------------------------------------------------------------------
;;              Vx                        Vy                        Vz
;;            [km/s]                    [km/s]                    [km/s]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;     -54.9544      26.6868      43.4793      18.6930     -18.3793      28.5566
;;----------------------------------------------------------------------------------------
;;              Bx                        By                        Bz
;;             [nT]                      [nT]                      [nT]
;;        Avg.     Std. Dev.        Avg.     Std. Dev.        Avg.     Std. Dev.
;;========================================================================================
;;     -1.69473      7.11051     -14.2039      6.30133      1.26029      12.6295
;;----------------------------------------------------------------------------------------



;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; => Determine specific entropy and enthalpy changes
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
psuffx         = '  => For '+tdate[0]+'  1st Shock Crossing'
tramp          = t_ramp_0713_0
ni1            = ni___up_0713_0
ni2            = ni___dn_0713_0
Te1            = Te___up_0713_0
Te2            = Te___dn_0713_0
Ti1            = Ti___up_0713_0
Ti2            = Ti___dn_0713_0
Bv1            = magf_up_0713_0
Pi1            = Pi___up_0713_0
Pi2            = Pi___dn_0713_0
nvec           = nvec__0713_0
dnvec          = dnvec_0713_0
ushn_up        = Ush__up_0713_0[0]
dushn_up       = dUsh_up_0713_0[0]
;;  Define ramp duration [s]
dt_ramp        = tramp[1] - tramp[0]
.compile shock_enthalpy_rate
test           = shock_enthalpy_rate(ni1,ni2,Te1,Ti1,Te2,Ti2,Bv1,ushn_up,dushn_up,$
                                     nvec,dnvec,dt_ramp)


n              = N_ELEMENTS(ni___up_0713_0)



PRINT,';;', n, psuffx[0]
;;          29  => For 2009-07-13

;;----------------------------------------------------
;;  Define polytrope index [ratio of specific heats]
;;----------------------------------------------------
eV_to_J        = kB[0]*K_eV[0]            ;; => Conversion from eV to J
press_fac      = eV_to_J[0]*1d6           ;; eV --> J, cm^(-3) --> m^(-3)

nfac           = [-1d0,0d0,1d0]
gam            = [4d0/3d0,5d0/3d0,7d0/5d0]
;;  Define ramp duration [s]
dt_ramp        = tramp[1] - tramp[0]
;;  Define upstream mass density [kg m^(-3)] and total temperature [K]
rho_up         = (me[0] + mp[0])*ni1*1d6  ;;  [kg m^(-3)]
rho_dn         = (me[0] + mp[0])*ni2*1d6  ;;  [kg m^(-3)]
diff_rho       = rho_dn - rho_up          ;;  mass density change [kg m^(-3)]
temp_up        = (Te1 + Ti1)*K_eV[0]      ;;  [deg K]
;;  Define upstream/downstream electron thermal pressures [J m^(-3)]
Pe1            = ni1*Te1*press_fac[0]
Pe2            = ni2*Te2*press_fac[0]
;;  Define upstream/downstream total thermal pressures [J m^(-3)]
Press_up       = Pe1 + Pi1*press_fac[0]
Press_dn       = Pe2 + Pi2*press_fac[0]
;;----------------------------------------------------
;;  Define empty arrays for later use
;;----------------------------------------------------
nsh            = DBLARR(3,3)              ;;  shock normal vectors
Ushn           = DBLARR(3)                ;;  shock normal speeds [km/s, SCF]
theta_Bn       = DBLARR(n,3)              ;;  shock normal angles [deg]
press_ratio    = DBLARR(n,3,3,3)          ;;  pressure ratio jump [unitless]
entropy        = DBLARR(n,3,3,3)          ;;  change in specific entropy, ∆s [J K^(-1) kg^(-1)]
entropy_obs    = DBLARR(n,3)              ;;  " " using observed pressure ratios
cs_up          = DBLARR(n,3)              ;;  upstream sound speed [m/s]
diss_rate      = DBLARR(n,3,3,3)          ;;  dissipation rate due to ∆s [µW m^(-3)]
diss_rate_obs  = DBLARR(n,3)              ;;  " " using observed pressure ratios
work_rate      = DBLARR(n,3)              ;;  rate of work done to displace/compress plasma [µW m^(-3)]
enthalpy       = DBLARR(n,3,3,3)          ;;  rate of change of specific enthalpy, ∆h [µW m^(-3)]
enthalpy_obs   = DBLARR(n,3)              ;;  " " using observed pressure ratios
;;----------------------------------------------------
;;  Define shock normal vector ranges = n ± ∂n
;;----------------------------------------------------
FOR j=0L, 2L DO nsh[j,*] = nvec + nfac[j]*dnvec
;;  Normalize n ± ∂n
FOR j=0L, 2L DO nsh[j,*] = nsh[j,*]/NORM(REFORM(nsh[j,*]))
;;----------------------------------------------------
;;  Define shock normal speed ranges = Un ± ∂Un
;;----------------------------------------------------
FOR j=0L, 2L DO Ushn[j] = ABS(ushn_up[0]) + nfac[j]*ABS(dushn_up[0])

;;  Normalize Bo
Bo1            = SQRT(TOTAL(Bv1^2,2L,/NAN))
Bo2d           = Bo1 # REPLICATE(1d0,3L)
bv1            = Bv1/Bo2d
;;----------------------------------------------------
;;  Calculate shock normal angles
;;----------------------------------------------------
FOR j=0L, 2L DO BEGIN                          $
  n00           = REFORM(nsh[j,*])           & $
  bdn_00        = my_dot_prod(bv1,n00,/NOM)  & $
  temp          = ACOS(bdn_00)*18d1/!DPI     & $
  theta_Bn[*,j] = temp < (18d1 - temp)

;;----------------------------------------------------------------------------------------
;;  Define density and pressure ratio jumps [measurements, unitless]
;;----------------------------------------------------------------------------------------
Press_rat_obs  = Press_dn/Press_up
dens_rat_obs   = ni2/ni1

x              = Press_rat_obs
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN), psuffx[0]
;;      29.9566      40.7080      35.8779      1.90577  => For 2009-07-13  1st Shock Crossing

;;----------------------------------------------------------------------------------------
;;  Define pressure ratio jump [shock adiabat Eq., unitless]
;;       [N,I,J,K]-Element array
;;         N  :  # of upstream/downstream plasma parameter values
;;         I  :  # of different shock normal speeds [km/s, SCF] to consider
;;         J  :  # of different shock normal angles [deg] due to J shock normal vectors
;;         K  :  # of polytrope indices used
;;----------------------------------------------------------------------------------------
FOR i=0L, 2L DO BEGIN                                                                  $
  FOR j=0L, 2L DO BEGIN                                                                $
    FOR k=0L, 2L DO BEGIN                                                              $
      un0  = REPLICATE(Ushn[i],n)                                                    & $
      temp = shock_pressure_ratio(ni1,ni2,Te1,Ti1,un0,Bo1,theta_Bn[*,j],gam[k])      & $
      press_ratio[*,i,j,k] = temp

x              = press_ratio
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN), psuffx[0]
;;       10.526425       19.114560       14.272340       1.7196885  => For 2009-07-13  1st Shock Crossing

;;----------------------------------------------------------------------------------------
;;  Define specific entropy change, ∆s [measurements, J K^(-1) kg^(-1)]
;;----------------------------------------------------------------------------------------
kB_mass        = kB[0]/(me[0] + mp[0])
FOR k=0L, 2L DO BEGIN                                                                  $
  kbfac = kB_mass[0]/(gam[k] - 1d0)                                                  & $
  term1 = ABS(Press_rat_obs/(dens_rat_obs^gam[k]))                                   & $
  entropy_obs[*,k] = kbfac[0]*ALOG(term1)

x              = entropy_obs
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN), psuffx[0]
;;       2362.4764       33626.306       16839.282       9001.9980  => For 2009-07-13  1st Shock Crossing

;;----------------------------------------------------------------------------------------
;;  Define specific entropy change, ∆s [shock adiabat Eq., J K^(-1) kg^(-1)]
;;       [N,I,J,K]-Element array
;;         N  :  # of upstream/downstream plasma parameter values
;;         I  :  # of different shock normal speeds [km/s, SCF] to consider
;;         J  :  # of different shock normal angles [deg] due to J shock normal vectors
;;         K  :  # of polytrope indices used
;;----------------------------------------------------------------------------------------
FOR i=0L, 2L DO BEGIN                                                                  $
  FOR j=0L, 2L DO BEGIN                                                                $
    FOR k=0L, 2L DO BEGIN                                                              $
      un0  = REPLICATE(Ushn[i],n)                                                    & $
      temp = shock_entropy_change(ni1,ni2,Te1,Ti1,un0,Bo1,theta_Bn[*,j],gam[k])      & $
      entropy[*,i,j,k] = temp

bad            = WHERE(entropy LT 0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
PRINT,';;', bd, gd
;;         462         321

bind           = ARRAY_INDICES(entropy,bad)  ;; [4,K]-Element array
;;  Set negative entropy changes to NaNs
entropy[bind[0,*],bind[1,*],bind[2,*],bind[3,*]] = d

x              = entropy
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN), psuffx[0]
;;      0.65556290       19453.271       4734.9851       4552.9087  => For 2009-07-13  1st Shock Crossing

;;----------------------------------------------------
;;  Define upstream sound speed [m/s]
;;----------------------------------------------------
FOR i=0L, 2L DO cs_up[*,i] = SQRT(gam[i]*Press_up/rho_up)
;FOR i=0L, 2L DO cs_up[*,i] = SQRT(gam[i]*kB[0]*temp_up/(me[0] + mp[0]))

x              = cs_up*1d-3
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN), psuffx[0]
;;       41.275765       52.902673       46.210947       2.6308369  => For 2009-07-13  1st Shock Crossing

;;----------------------------------------------------
;;  Define entropy dissipation rate [µW m^(-3)]
;;    ∆∑ = (ƒ T ∆s)/∆t [measurements]
;;----------------------------------------------------
term0          = (rho_up*temp_up/dt_ramp[0])*1d6
FOR k=0L, 2L DO BEGIN                                                                  $
  diss_rate_obs[*,k] = term0*entropy_obs[*,k]

x              = diss_rate_obs
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN), psuffx[0]
;;   4.6689717e-06   7.3963775e-05   3.4285814e-05   1.8647814e-05  => For 2009-07-13  1st Shock Crossing

;;----------------------------------------------------
;;  Define entropy dissipation rate [µW m^(-3)]
;;    ∆∑ = (ƒ T ∆s)/∆t [shock adiabat Eq.]
;;----------------------------------------------------
term0          = (rho_up*temp_up/dt_ramp[0])*1d6
FOR i=0L, n - 1L DO diss_rate[i,*,*,*] = term0[i]*entropy[i,*,*,*]

x              = diss_rate
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN), psuffx[0]
;;   1.3308790e-09   4.5873380e-05   9.9288819e-06   9.9326783e-06  => For 2009-07-13  1st Shock Crossing

;;----------------------------------------------------
;;  Define work done to displace plasma
;;    = Cs^(2) ∆ƒ/∆t  [µW m^(-3)]
;;----------------------------------------------------
FOR i=0L, 2L DO work_rate[*,i] = ABS(cs_up[*,i])^2*diff_rho/dt_ramp[0]*1d6

x              = work_rate
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN), psuffx[0]
;;   3.4179464e-05   7.3487584e-05   5.1225374e-05   7.7507197e-06  => For 2009-07-13  1st Shock Crossing

;;----------------------------------------------------
;;  Define specific enthalpy change per unit time
;;    ∆h/∆t = (ƒ T ∆s)/∆t  +  Cs^(2) ∆ƒ/∆t
;;    [µW m^(-3)]
;;----------------------------------------------------
FOR i=0L, 2L DO BEGIN                                                                  $
  FOR j=0L, 2L DO BEGIN                                                                $
    FOR k=0L, 2L DO BEGIN                                                              $
      enthalpy[*,i,j,k] = diss_rate[*,i,j,k] + work_rate[*,k]

x              = enthalpy
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN), psuffx[0]
;;   4.3211507e-05   8.7826310e-05   5.4983517e-05   8.4653955e-06  => For 2009-07-13  1st Shock Crossing

;;----------------------------------------------------
;;  Define specific enthalpy change per unit time
;;    [µW m^(-3)]
;;----------------------------------------------------
FOR k=0L, 2L DO BEGIN                                                                  $
  enthalpy_obs[*,k] = diss_rate_obs[*,k] + work_rate[*,k]

x              = enthalpy_obs
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN), psuffx[0]
;;   6.3538421e-05   0.00011591671   8.5511187e-05   1.3398373e-05  => For 2009-07-13  1st Shock Crossing


;;----------------------------------------------------
;;  Avg. ∆∑ over the N-plasma terms [µW m^(-3)]
;;----------------------------------------------------
sum            = TOTAL(diss_rate_obs,1,/NAN)    ;; [K]-Element array
num            = TOTAL(FINITE(diss_rate_obs),1,/NAN)
avgdissrate_ob = sum/num

x              = avgdissrate_ob
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN), psuffx[0]
;;   1.0738757e-05   5.3123459e-05   3.4285814e-05   2.1581234e-05  => For 2009-07-13  1st Shock Crossing

;;----------------------------------------------------
;;  Avg. ∆∑ over the N-plasma terms [µW m^(-3)]
;;----------------------------------------------------
sum            = TOTAL(diss_rate,1,/NAN)    ;; [I,J,K]-Element array
num            = TOTAL(FINITE(diss_rate),1,/NAN)
avg_diss_rate  = sum/num

x              = avg_diss_rate
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN), psuffx[0]
;;   1.5805751e-06   1.2804045e-05   7.8650362e-06   3.7019400e-06  => For 2009-07-13  1st Shock Crossing

;;----------------------------------------------------
;;  Avg. ∆h/∆t over the N-plasma terms [µW m^(-3)]
;;----------------------------------------------------
sum            = TOTAL(enthalpy_obs,1,/NAN)    ;; [I,J,K]-Element array
num            = TOTAL(FINITE(enthalpy_obs),1,/NAN)
avgenthalpy_ob = sum/num

x              = avgenthalpy_ob
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN), psuffx[0]
;;   6.8949409e-05   9.9691981e-05   8.5511187e-05   1.5508973e-05  => For 2009-07-13  1st Shock Crossing

;;----------------------------------------------------
;;  Avg. ∆h/∆t over the N-plasma terms [µW m^(-3)]
;;----------------------------------------------------
sum            = TOTAL(enthalpy,1,/NAN)    ;; [I,J,K]-Element array
num            = TOTAL(FINITE(enthalpy),1,/NAN)
avg_enthalpy   = sum/num

x              = avg_enthalpy
PRINT,';;', MIN(x,/NAN), MAX(x,/NAN), MEAN(x,/NAN), STDDEV(x,/NAN), psuffx[0]
;;   4.9163321e-05   5.8336842e-05   5.3779025e-05   2.4617560e-06  => For 2009-07-13  1st Shock Crossing



















