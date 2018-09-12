@load_tdss_lhw_stats.pro

v_a   = (v_a_e + v_a_s)/2d0
wpi_s = wpifac[0]*SQRT(dens_s)
wpi_e = wpifac[0]*SQRT(dens_e)
wpi   = (wpi_s + wpi_e)/2d0
;-----------------------------------------------------------------------------------------
; => Look at only the whistlers
;-----------------------------------------------------------------------------------------
good_whi   = array_where(evns,evns_whi,/N_UNIQ)
good_whi   = good_whi[*,0]
PRINT,';  ', N_ELEMENTS(good_whi)
;           138

gels        = good_whi
nfac        = SQRT(N_ELEMENTS(good_whi))
db_bo       = filtamp[gels]/bmag_s[gels]
PRINT,';  ',  MIN(db_bo,/NAN),  MAX(db_bo,/NAN),  MEAN(db_bo,/NAN),  STDDEV(db_bo,/NAN),  STDDEV(db_bo,/NAN)/nfac[0]
;      0.0022017288      0.16611758     0.038534344     0.027017236    0.0022998598

db_bo       = pkamps[gels]/bmag_s[gels]
PRINT,';  ',  MIN(db_bo,/NAN),  MAX(db_bo,/NAN),  MEAN(db_bo,/NAN),  STDDEV(db_bo,/NAN),  STDDEV(db_bo,/NAN)/nfac[0]
;      0.0148066     0.157022    0.0718858    0.0396382   0.00337422

db_fil      = filtamp[gels]
PRINT,';  ',  MIN(db_fil,/NAN),  MAX(db_fil,/NAN),  MEAN(db_fil,/NAN),  STDDEV(db_fil,/NAN),  STDDEV(db_fil,/NAN)/nfac[0]
;       0.039999999       3.7440000      0.83081159      0.60978707     0.051908522


thkba0     = thkba < (18d1 - thkba)
thkva0     = thkva < (18d1 - thkva)
thkn80     = thkn8 < (18d1 - thkn8)
thkn90     = thkn9 < (18d1 - thkn9)
PRINT,';  ',  MIN(thkba0[good_whi],/NAN),  MAX(thkba0[good_whi],/NAN),  MEAN(thkba0[good_whi],/NAN),  STDDEV(thkba0[good_whi],/NAN)
PRINT,';  ',  MIN(thkva0[good_whi],/NAN),  MAX(thkva0[good_whi],/NAN),  MEAN(thkva0[good_whi],/NAN),  STDDEV(thkva0[good_whi],/NAN)
PRINT,';  ',  MIN(thkn80[good_whi],/NAN),  MAX(thkn80[good_whi],/NAN),  MEAN(thkn80[good_whi],/NAN),  STDDEV(thkn80[good_whi],/NAN)
PRINT,';  ',  MIN(thkn90[good_whi],/NAN),  MAX(thkn90[good_whi],/NAN),  MEAN(thkn90[good_whi],/NAN),  STDDEV(thkn90[good_whi],/NAN)
;---------------------------------------------------------------------
; => Theta_[kB, kV, kn08, kn09]
;---------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.
;=====================================================================
;         2.4700000       47.053497       19.406446       10.258901
;         48.713501       89.763000       72.543471       9.0129049
;         44.651578       89.889000       74.749534       11.113583
;         49.249140       89.912612       74.523256       10.512801
;---------------------------------------------------------------------

unq_whi   = UNIQ(evns[good_whi],SORT(evns[good_whi]))
ugel_whi  = good_whi[unq_whi]
PRINT,';  ', N_ELEMENTS(ugel_whi)
mform     = '(";   ",a23,"   ",a23,"   ",I9.9)'
FOR j=0L, N_ELEMENTS(ugel_whi) - 1L DO PRINT,FORMAT=mform, scets[ugel_whi[j]], scete[ugel_whi[j]], evns[ugel_whi[j]]
;==================================================================
;   1998-08-26/06:41:35.975   1998-08-26/06:41:37.066   000010807
;   1998-08-26/06:41:42.365   1998-08-26/06:41:43.456   000010832
;   1998-08-26/06:41:51.600   1998-08-26/06:41:52.691   000010868
;   1998-08-26/06:41:54.666   1998-08-26/06:41:55.757   000010881
;   1998-08-26/06:41:56.261   1998-08-26/06:41:57.352   000010888
;   1998-08-26/06:41:57.584   1998-08-26/06:41:58.675   000010895
;   1998-08-26/06:42:04.115   1998-08-26/06:42:05.206   000010923
;   1998-08-26/06:42:07.483   1998-08-26/06:42:08.575   000010937
;   2000-02-11/23:34:25.854   2000-02-11/23:34:26.945   023145603
;   2000-02-11/23:34:27.416   2000-02-11/23:34:28.507   023145610
;   2000-02-12/00:14:20.060   2000-02-12/00:14:21.151   023153276
;   2000-02-12/00:26:15.569   2000-02-12/00:26:16.660   023154909
;   2000-02-12/00:27:17.494   2000-02-12/00:27:18.585   023155087
;==================================================================

;-----------------------------------------------------------------------------------------
; => Calculate correct Doppler shift for full whistler dispersion relation
;-----------------------------------------------------------------------------------------
ckm         = c[0]*1d-3
nwhi        = N_ELEMENTS(thkva)
th_kV_av    = thkva                                ; => Theta_kV (deg) [Avg.]
th_kB_av    = thkba                                ; => Theta_kB (deg) [Avg.]
th_kB_avs   = th_kB_av < (18d1 - th_kB_av)
; => Spacecraft frame frequencies [Hz]
fsc_low     = freql                                ; => (Hz) low  freq. end of bandpass
fsc_high    = freqh                                ; => (Hz) high freq. end of bandpass
; => Define plasma parameters
vsw_0       = vsw                                  ; => PL solar wind velocity (km/s) [GSE]
vmag_0      = SQRT(TOTAL(vsw_0^2,2L,/NAN))
wce_0       = wce                                  ; => Electron cyclotron frequency (rad/s)
fce_0       = wce_0/(2d0*!DPI)
wpe_0       = wpe                                  ; => Electron plasma frequency (rad/s)
dens_0      = dens                                 ; => Electron density [cm^(-3)] from TNR
magf_0      = magf
bmag_0      = SQRT(TOTAL(magf_0^2,2L,/NAN))
e_iner_0    = ckm[0]/wpe_0                         ; => Electron inertial length [km]
; => Angle between Vsw and Bo
V_dot_B     = my_dot_prod(vsw_0,magf_0,/NOM)/(vmag_0*bmag_0)

vae_fac2    = (1d-9^2)/(me[0]*muo[0]*1d6)
vae_02      = vae_fac2[0]*(bmag_0^2)/dens_0
vae_0       = SQRT(vae_02)*1d-3                    ; => Electron Alfven speed (km/s)

th_kV_pos   = th_kV_av < (18d1 - th_kV_av)     ;  + Doppler shift -> (the_kV < 90)
th_kV_neg   = th_kV_av > (18d1 - th_kV_av)     ;  - Doppler shift -> (the_kV > 90)
V_dot_k_pos = vmag_0*COS(th_kV_pos*!DPI/18d1)  ;  |Vsw| Cos(the_kV+)
V_dot_k_neg = vmag_0*COS(th_kV_neg*!DPI/18d1)  ;  |Vsw| Cos(the_kV-)
Vk_Vae_pos  = V_dot_k_pos/vae_0
Vk_Vae_neg  = V_dot_k_neg/vae_0
wsc_wce_low = (2d0*!DPI*fsc_low)/wce_0         ;  (w_sc/w_ce)  [low  end]
wsc_wce_hig = (2d0*!DPI*fsc_high)/wce_0        ;  (w_sc/w_ce)  [high end]


;  0 = a x^3 + b x^2 + c x + d
;
;  a = [|Vsw| Cos(the_kV)/V_Ae]
;  b = Cos(the_kB) - w_sc/w_ce
;  c = a
;  d = -(w_sc/w_ce)
; => Define coefficients
b_low        = COS(th_kB_avs*!DPI/18d1) - wsc_wce_low
b_hig        = COS(th_kB_avs*!DPI/18d1) - wsc_wce_hig
d_low        = -1d0*wsc_wce_low
d_hig        = -1d0*wsc_wce_hig
;  + Doppler shift -> (the_kV < 90)
a_pos        = Vk_Vae_pos
c_pos        = Vk_Vae_pos
;  - Doppler shift -> (the_kV > 90)
a_neg        = Vk_Vae_neg
c_neg        = Vk_Vae_neg

coef_low_pos = [[d_low],[c_pos],[b_low],[a_pos]]
coef_hig_pos = [[d_hig],[c_pos],[b_hig],[a_pos]]
coef_low_neg = [[d_low],[c_neg],[b_low],[a_neg]]
coef_hig_neg = [[d_hig],[c_neg],[b_hig],[a_neg]]

kbar_low_pos = DBLARR(nwhi,3L)   ; dummy array of (k c)/w_pe solutions to cubic equation
kbar_hig_pos = DBLARR(nwhi,3L)
kbar_low_neg = DBLARR(nwhi,3L)
kbar_hig_neg = DBLARR(nwhi,3L)

FOR j=0L, nwhi - 1L DO BEGIN                    $
  cofs0 = REFORM(coef_low_pos[j,*])           & $
  cofs1 = REFORM(coef_hig_pos[j,*])           & $
  cofs3 = REFORM(coef_low_neg[j,*])           & $
  cofs4 = REFORM(coef_hig_neg[j,*])           & $
  rts00 = FZ_ROOTS(cofs0,/DOUBLE,/NO_POLISH)  & $
  rts01 = FZ_ROOTS(cofs1,/DOUBLE,/NO_POLISH)  & $
  rts03 = FZ_ROOTS(cofs3,/DOUBLE,/NO_POLISH)  & $
  rts04 = FZ_ROOTS(cofs4,/DOUBLE,/NO_POLISH)  & $
  kbar_low_pos[j,*] = REAL_PART(rts00)        & $
  kbar_hig_pos[j,*] = REAL_PART(rts01)        & $
  kbar_low_neg[j,*] = REAL_PART(rts03)        & $
  kbar_hig_neg[j,*] = REAL_PART(rts04)

; => Calculate rest-frame frequencies [units of w_ce]
cthkb_3d      = COS(th_kB_avs*!DPI/18d1) # REPLICATE(1d0,3L)
sthkb_3d      = SIN(th_kB_avs*!DPI/18d1) # REPLICATE(1d0,3L)
wrest_low_pos = kbar_low_pos^2*cthkb_3d/(1d0 + kbar_low_pos^2)
wrest_hig_pos = kbar_hig_pos^2*cthkb_3d/(1d0 + kbar_hig_pos^2)
wrest_low_neg = kbar_low_neg^2*cthkb_3d/(1d0 + kbar_low_neg^2)
wrest_hig_neg = kbar_hig_neg^2*cthkb_3d/(1d0 + kbar_hig_neg^2)

; => Define wave number magnitudes [km^(-1)] (+ sign)
k_km_low_pos = kbar_low_pos*(wpe # REPLICATE(1d0,3L))/ckm[0]
k_km_hig_pos = kbar_hig_pos*(wpe # REPLICATE(1d0,3L))/ckm[0]
; => Define wave number magnitudes [km^(-1)] (- sign)
k_km_low_neg = kbar_low_neg*(wpe # REPLICATE(1d0,3L))/ckm[0]
k_km_hig_neg = kbar_hig_neg*(wpe # REPLICATE(1d0,3L))/ckm[0]

; => Define parallel wave number magnitudes [km^(-1)] (+ sign)
kpar_low_pos = k_km_low_pos*(COS(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))
kpar_hig_pos = k_km_hig_pos*(COS(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))
; => Define parallel wave number magnitudes [km^(-1)] (- sign)
kpar_low_neg = k_km_low_neg*(COS(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))
kpar_hig_neg = k_km_hig_neg*(COS(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))
; => Define perpendicular wave number magnitudes [km^(-1)] (+ sign)
kper_low_pos = k_km_low_pos*(SIN(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))
kper_hig_pos = k_km_hig_pos*(SIN(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))
; => Define perpendicular wave number magnitudes [km^(-1)] (- sign)
kper_low_neg = k_km_low_neg*(SIN(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))
kper_hig_neg = k_km_hig_neg*(SIN(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))


; => Define rest frame frequencies [Hz] (+ sign)
frest_low_pos = (wrest_low_pos*(wce_0 # REPLICATE(1d0,3)))/(2d0*!DPI)
frest_hig_pos = (wrest_hig_pos*(wce_0 # REPLICATE(1d0,3)))/(2d0*!DPI)
; => Define rest frame frequencies [Hz] (- sign)
frest_low_neg = (wrest_low_neg*(wce_0 # REPLICATE(1d0,3)))/(2d0*!DPI)
frest_hig_neg = (wrest_hig_neg*(wce_0 # REPLICATE(1d0,3)))/(2d0*!DPI)


;-----------------------------------------------------------------------------------------
; => Look at temperature anisotropy factors
;-----------------------------------------------------------------------------------------
tanis_el      = tpere/tpare
KP66_A_el     = tanis_el - 1d0      ;;  Anisotropy factor for Bulk
KP66_A_ce     = tanis_c  - 1d0      ;;  Anisotropy factor for Core
KP66_A_he     = tanis_h  - 1d0      ;;  Anisotropy factor for Halo

KP66_Th_el    = KP66_A_el/(KP66_A_el + 1d0)
KP66_Th_ce    = KP66_A_ce/(KP66_A_ce + 1d0)
KP66_Th_he    = KP66_A_he/(KP66_A_he + 1d0)
;; check stability conditions for Bulk
KP66_test_flm_el = wrest_low_neg LT (KP66_Th_el # REPLICATE(1d0,3))
KP66_test_flp_el = wrest_low_pos LT (KP66_Th_el # REPLICATE(1d0,3))
KP66_test_fhm_el = wrest_hig_neg LT (KP66_Th_el # REPLICATE(1d0,3))
KP66_test_fhp_el = wrest_hig_pos LT (KP66_Th_el # REPLICATE(1d0,3))
;; check stability conditions for Core
KP66_test_flm_ce = wrest_low_neg LT (KP66_Th_ce # REPLICATE(1d0,3))
KP66_test_flp_ce = wrest_low_pos LT (KP66_Th_ce # REPLICATE(1d0,3))
KP66_test_fhm_ce = wrest_hig_neg LT (KP66_Th_ce # REPLICATE(1d0,3))
KP66_test_fhp_ce = wrest_hig_pos LT (KP66_Th_ce # REPLICATE(1d0,3))
;; check stability conditions for Halo
KP66_test_flm_he = wrest_low_neg LT (KP66_Th_he # REPLICATE(1d0,3))
KP66_test_flp_he = wrest_low_pos LT (KP66_Th_he # REPLICATE(1d0,3))
KP66_test_fhm_he = wrest_hig_neg LT (KP66_Th_he # REPLICATE(1d0,3))
KP66_test_fhp_he = wrest_hig_pos LT (KP66_Th_he # REPLICATE(1d0,3))


;; Examine Specific Examples
evn_whi          = evns[good_whi]
;;   => 1998-08-26/06:41:35.975   000010807
evn_0            = 000010807L
good_0           = WHERE(evn_whi EQ evn_0[0],gd_0)
gels             = good_whi[good_0]

x                = [wrest_low_neg[gels,*],wrest_hig_neg[gels,*]]
PRINT,';  ', MIN(x[*,0],/NAN), MAX(x[*,0],/NAN)
PRINT,';  ', MIN(x[*,1],/NAN), MAX(x[*,1],/NAN)
PRINT,';  ', MIN(x[*,2],/NAN), MAX(x[*,2],/NAN)
;------------------------------------
;            Min             Max
;====================================
;       0.038675658      0.20580551
;       0.059246984      0.25939900
;        0.94735451      0.98687064
;------------------------------------

x                = [wrest_low_pos[gels,*],wrest_hig_pos[gels,*]]
PRINT,';  ', MIN(x[*,0],/NAN), MAX(x[*,0],/NAN)
PRINT,';  ', MIN(x[*,1],/NAN), MAX(x[*,1],/NAN)
PRINT,';  ', MIN(x[*,2],/NAN), MAX(x[*,2],/NAN)
;------------------------------------
;            Min             Max
;====================================
;        0.94735451      0.98687064
;       0.059246984      0.25939900
;       0.038675658      0.20580551
;------------------------------------

x                = [KP66_test_flm_el[gels,*],KP66_test_fhm_el[gels,*]]
y                = [KP66_test_flm_ce[gels,*],KP66_test_fhm_ce[gels,*]]
z                = [KP66_test_flm_he[gels,*],KP66_test_fhm_he[gels,*]]
PRINT,';  ', TOTAL(x[*,0],/NAN)/gd_0, TOTAL(x[*,1],/NAN)/gd_0, TOTAL(x[*,2],/NAN)/gd_0
PRINT,';  ', TOTAL(y[*,0],/NAN)/gd_0, TOTAL(y[*,1],/NAN)/gd_0, TOTAL(y[*,2],/NAN)/gd_0
PRINT,';  ', TOTAL(z[*,0],/NAN)/gd_0, TOTAL(z[*,1],/NAN)/gd_0, TOTAL(z[*,2],/NAN)/gd_0
;        1.00000      1.00000      0.00000
;        1.00000      0.00000      0.00000
;        2.00000      1.00000      0.00000



;;   => 1998-08-26/06:42:04.115   000010923
evn_0            = 000010923L
good_0           = WHERE(evn_whi EQ evn_0[0],gd_0)
gels             = good_whi[good_0]

x                = [wrest_low_neg[gels,*],wrest_hig_neg[gels,*]]
PRINT,';  ', MIN(x[*,0],/NAN), MAX(x[*,0],/NAN)
PRINT,';  ', MIN(x[*,1],/NAN), MAX(x[*,1],/NAN)
PRINT,';  ', MIN(x[*,2],/NAN), MAX(x[*,2],/NAN)
;------------------------------------
;            Min             Max
;====================================
;       0.047797063      0.29167270
;       0.071848826      0.36479223
;        0.80900316      0.90989863
;------------------------------------

x                = [KP66_test_flm_el[gels,*],KP66_test_fhm_el[gels,*]]
y                = [KP66_test_flm_ce[gels,*],KP66_test_fhm_ce[gels,*]]
z                = [KP66_test_flm_he[gels,*],KP66_test_fhm_he[gels,*]]
PRINT,';  ', TOTAL(x[*,0],/NAN)/gd_0, TOTAL(x[*,1],/NAN)/gd_0, TOTAL(x[*,2],/NAN)/gd_0
PRINT,';  ', TOTAL(y[*,0],/NAN)/gd_0, TOTAL(y[*,1],/NAN)/gd_0, TOTAL(y[*,2],/NAN)/gd_0
PRINT,';  ', TOTAL(z[*,0],/NAN)/gd_0, TOTAL(z[*,1],/NAN)/gd_0, TOTAL(z[*,2],/NAN)/gd_0
;        0.00000      0.00000      0.00000
;        0.00000      0.00000      0.00000
;        1.00000      1.00000      0.00000

;-----------------------------------------------------------------------------------------
; => Look at resonance energies
;-----------------------------------------------------------------------------------------
; => Define rest frame frequencies (- sign)
frest_lm   = frest_low_neg[good_whi,*]
frest_hm   = frest_hig_neg[good_whi,*]
; => Define rest frame frequencies (+ sign)
frest_lp   = frest_low_pos[good_whi,*]
frest_hp   = frest_hig_pos[good_whi,*]
; => Define wave normal angles [deg]
theta_kb   = thkba0[good_whi]
; => Define number density [cm^(-3)]
density    = dens[good_whi]
; => Define magnetic field magnitude [nT]
bmaga      = bmag[good_whi]


;; structures returned by cold_plasma_whistler_params_1d.pro
;;
;;** Structure <4d25668>, 5 tags, length=5520, data length=5520, refs=1:
;;   WAVE_LENGTH     DOUBLE    Array[138]
;;   V_PHASE         DOUBLE    Array[138]
;;   ERES_LAND       DOUBLE    Array[138]
;;   ERES_NCYC       DOUBLE    Array[138]
;;   ERES_ACYC       DOUBLE    Array[138]



;; Resonance for f_(sc,low) [- sign]
res_lm0    = cold_plasma_whistler_params_1d(bmaga,density,frest_lm[*,0],theta_kb)
res_lm1    = cold_plasma_whistler_params_1d(bmaga,density,frest_lm[*,1],theta_kb)
res_lm2    = cold_plasma_whistler_params_1d(bmaga,density,frest_lm[*,2],theta_kb)

res_lm     = res_lm0
res_lm     = res_lm1
res_lm     = res_lm2
x          = res_lm.WAVE_LENGTH  ;; wavelength [km]
wavel_lm   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_lm.V_PHASE      ;; phase speed [km/s]
vph_lm     = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_lm.ERES_LAND    ;; Landau resonant energy [eV]
Eresla_lm  = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_lm.ERES_NCYC    ;; Normal cyclotron resonant energy [eV]
Eresnc_lm  = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_lm.ERES_ACYC    ;; Anomalous cyclotron resonant energy [eV]
Eresac_lm  = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
PRINT,';  ', wavel_lm
PRINT,';  ', vph_lm
PRINT,';  ', Eresla_lm
PRINT,';  ', Eresnc_lm
PRINT,';  ', Eresac_lm
;-----------------------------------------------------------------------------------------
;  1st solution of cubic Eq.
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         18.625981       42.701152       31.616041       6.0830214      0.51782117
;         632.19481       1361.7276       1008.0006       186.27256       15.856573
;         1.8099194       5.7005431       3.4518845       1.1778623      0.10026629
;         213.18848       2102.7641       1129.1448       501.95455       42.729208
;         331.95779       2480.1679       1380.7498       553.99003       47.158762
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;  2nd solution of cubic Eq.
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         15.357566       31.485286       26.013254       4.2242013      0.35958789
;         833.69450       1523.3597       1179.4376       168.41367       14.336323
;         2.5322712       7.0522852       4.6523817       1.1249528     0.095762344
;         140.45240       1456.0971       732.07328       302.33645       25.736587
;         258.66512       1824.6002       977.60826       365.09364       31.078835
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;  3rd solution of cubic Eq.
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;     0.00095584360      0.84053648      0.37126719      0.18765135     0.015973943
;        0.58131397       472.75565       199.52128       101.38121       8.6301415
;     1.0361113e-06      0.67920109      0.16110371      0.13459418     0.011457417
;     1.5379872e-09     0.028045722    0.0020346780    0.0044362960   0.00037764260
;     4.3056590e-06       2.8400624      0.69643351      0.56822928     0.048370888
;-----------------------------------------------------------------------------------------


;; Resonance for f_(sc,high) [- sign]
res_hm0    = cold_plasma_whistler_params_1d(bmaga,density,frest_hm[*,0],theta_kb)
res_hm1    = cold_plasma_whistler_params_1d(bmaga,density,frest_hm[*,1],theta_kb)
res_hm2    = cold_plasma_whistler_params_1d(bmaga,density,frest_hm[*,2],theta_kb)

res_hm     = res_hm0
res_hm     = res_hm1
res_hm     = res_hm2
x          = res_hm.WAVE_LENGTH  ;; wavelength [km]
wavel_hm   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_hm.V_PHASE      ;; phase speed [km/s]
vph_hm     = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_hm.ERES_LAND    ;; Landau resonant energy [eV]
Eresla_hm  = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_hm.ERES_NCYC    ;; Normal cyclotron resonant energy [eV]
Eresnc_hm  = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_hm.ERES_ACYC    ;; Anomalous cyclotron resonant energy [eV]
Eresac_hm  = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
PRINT,';  ', wavel_hm
PRINT,';  ', vph_hm
PRINT,';  ', Eresla_hm
PRINT,';  ', Eresnc_hm
PRINT,';  ', Eresac_hm
;-----------------------------------------------------------------------------------------
;  1st solution of cubic Eq.
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         9.3248049       15.829043       12.483202       2.1148057      0.18002422
;         1101.1105       2488.9076       1919.6924       386.80280       32.926841
;         4.9763277       18.454511       12.575563       4.4683472      0.38037097
;         42.550744       187.06223       105.17094       51.871162       4.4155665
;         139.63520       455.72288       292.29468       87.485219       7.4472363
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;  2nd solution of cubic Eq.
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         7.9647569       13.410658       10.786760       1.5628446      0.13303817
;         1225.2874       2534.0569       2023.1542       372.90550       31.743824
;         5.5853599       18.846259       13.846263       4.2816970      0.36448225
;         25.759805       138.07714       67.353294       33.741025       2.8722268
;         113.56665       378.13932       239.51048       70.222000       5.9776936
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;  3rd solution of cubic Eq.
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0056215354       1.2091921      0.49839809      0.24192341     0.020593888
;         3.4188392       672.57055       267.51374       129.80882       11.050061
;     3.5837872e-05       1.3746768      0.28709549      0.24130011     0.020540830
;     5.3198501e-08     0.058905498    0.0041308822    0.0087798258   0.00074738840
;     0.00014892776       5.8141650       1.2520699       1.0414242     0.088651913
;-----------------------------------------------------------------------------------------


;; Resonance for f_(sc,low) [+ sign]
res_lp0    = cold_plasma_whistler_params_1d(bmaga,density,frest_lp[*,0],theta_kb)
res_lp1    = cold_plasma_whistler_params_1d(bmaga,density,frest_lp[*,1],theta_kb)
res_lp2    = cold_plasma_whistler_params_1d(bmaga,density,frest_lp[*,2],theta_kb)

res_lp     = res_lp0
res_lp     = res_lp1
res_lp     = res_lp2
x          = res_lp.WAVE_LENGTH  ;; wavelength [km]
wavel_lp   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_lp.V_PHASE      ;; phase speed [km/s]
vph_lp     = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_lp.ERES_LAND > 0    ;; Landau resonant energy [eV]
bad        = WHERE(x LE 0,bd)
IF (bd GT 0) THEN x[bad] = !VALUES.F_NAN
Eresla_lp  = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_lp.ERES_NCYC > 0    ;; Normal cyclotron resonant energy [eV]
bad        = WHERE(x LE 0,bd)
IF (bd GT 0) THEN x[bad] = !VALUES.F_NAN
Eresnc_lp  = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_lp.ERES_ACYC > 0    ;; Anomalous cyclotron resonant energy [eV]
bad        = WHERE(x LE 0,bd)
IF (bd GT 0) THEN x[bad] = !VALUES.F_NAN
Eresac_lp  = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
PRINT,';  ', wavel_lp
PRINT,';  ', vph_lp
PRINT,';  ', Eresla_lp
PRINT,';  ', Eresnc_lp
PRINT,';  ', Eresac_lp
;-----------------------------------------------------------------------------------------
;  1st solution of cubic Eq.
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;     0.00095584360      0.84053648      0.37126719      0.18765135     0.015973943
;        0.58131397       472.75565       199.52128       101.38121       8.6301415
;     1.0361113e-06      0.67920109      0.16110371      0.13459418     0.011457417
;     1.5379872e-09     0.028045722    0.0020346780    0.0044362960   0.00037764260
;     4.3056590e-06       2.8400624      0.69643351      0.56822928     0.048370888
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;  2nd solution of cubic Eq.
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         15.357566       31.485286       26.013254       4.2242013      0.35958789
;         833.69450       1523.3597       1179.4376       168.41367       14.336323
;         2.5322712       7.0522852       4.6523817       1.1249528     0.095762344
;         140.45240       1456.0971       732.07328       302.33645       25.736587
;         258.66512       1824.6002       977.60826       365.09364       31.078835
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;  3rd solution of cubic Eq.
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         18.625981       42.701152       31.616041       6.0830214      0.51782117
;         632.19481       1361.7276       1008.0006       186.27256       15.856573
;         1.8099194       5.7005431       3.4518845       1.1778623      0.10026629
;         213.18848       2102.7641       1129.1448       501.95455       42.729208
;         331.95779       2480.1679       1380.7498       553.99003       47.158762
;-----------------------------------------------------------------------------------------

;; Resonance for f_(sc,high) [+ sign]
res_hp0    = cold_plasma_whistler_params_1d(bmaga,density,frest_hp[*,0],theta_kb)
res_hp1    = cold_plasma_whistler_params_1d(bmaga,density,frest_hp[*,1],theta_kb)
res_hp2    = cold_plasma_whistler_params_1d(bmaga,density,frest_hp[*,2],theta_kb)

res_hp     = res_hp0
res_hp     = res_hp1
res_hp     = res_hp2
x          = res_hp.WAVE_LENGTH  ;; wavelength [km]
wavel_hp   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_hp.V_PHASE      ;; phase speed [km/s]
vph_hp     = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_hp.ERES_LAND > 0    ;; Landau resonant energy [eV]
bad        = WHERE(x LE 0,bd)
IF (bd GT 0) THEN x[bad] = !VALUES.F_NAN
Eresla_hp  = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_hp.ERES_NCYC > 0    ;; Normal cyclotron resonant energy [eV]
bad        = WHERE(x LE 0,bd)
IF (bd GT 0) THEN x[bad] = !VALUES.F_NAN
Eresnc_hp  = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x          = res_hp.ERES_ACYC > 0    ;; Anomalous cyclotron resonant energy [eV]
bad        = WHERE(x LE 0,bd)
IF (bd GT 0) THEN x[bad] = !VALUES.F_NAN
Eresac_hp  = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
PRINT,';  ', wavel_hp
PRINT,';  ', vph_hp
PRINT,';  ', Eresla_hp
PRINT,';  ', Eresnc_hp
PRINT,';  ', Eresac_hp
;-----------------------------------------------------------------------------------------
;  1st solution of cubic Eq.
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0056215354       1.2091921      0.49839809      0.24192341     0.020593888
;         3.4188392       672.57055       267.51374       129.80882       11.050061
;     3.5837872e-05       1.3746768      0.28709549      0.24130011     0.020540830
;     5.3198501e-08     0.058905498    0.0041308822    0.0087798258   0.00074738840
;     0.00014892776       5.8141650       1.2520699       1.0414242     0.088651913
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;  2nd solution of cubic Eq.
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         7.9647569       13.410658       10.786760       1.5628446      0.13303817
;         1225.2874       2534.0569       2023.1542       372.90550       31.743824
;         5.5853599       18.846259       13.846263       4.2816970      0.36448225
;         25.759805       138.07714       67.353294       33.741025       2.8722268
;         113.56665       378.13932       239.51048       70.222000       5.9776936
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;  3rd solution of cubic Eq.
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         9.3248049       15.829043       12.483202       2.1148057      0.18002422
;         1101.1105       2488.9076       1919.6924       386.80280       32.926841
;         4.9763277       18.454511       12.575563       4.4683472      0.38037097
;         42.550744       187.06223       105.17094       51.871162       4.4155665
;         139.63520       455.72288       292.29468       87.485219       7.4472363
;-----------------------------------------------------------------------------------------





