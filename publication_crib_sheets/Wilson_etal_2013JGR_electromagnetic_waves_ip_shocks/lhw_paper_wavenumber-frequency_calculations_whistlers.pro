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
;; => Spacecraft frame frequencies [Hz]
fsc_low     = freql                                ; => (Hz) low  freq. end of bandpass
fsc_high    = freqh                                ; => (Hz) high freq. end of bandpass
;; => Define plasma parameters
vsw_0       = vsw                                  ; => PL solar wind velocity (km/s) [GSE]
vmag_0      = SQRT(TOTAL(vsw_0^2,2L,/NAN))
wce_0       = wce                                  ; => Electron cyclotron frequency (rad/s)
fce_0       = wce_0/(2d0*!DPI)
wpe_0       = wpe                                  ; => Electron plasma frequency (rad/s)
dens_0      = dens                                 ; => Electron density [cm^(-3)] from TNR
magf_0      = magf
bmag_0      = SQRT(TOTAL(magf_0^2,2L,/NAN))
e_iner_0    = ckm[0]/wpe_0                         ; => Electron inertial length [km]
;; => Angle between Vsw and Bo
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


;;  0 = a x^3 + b x^2 + c x + d
;;
;;  a = [|Vsw| Cos(the_kV)/V_Ae]
;;  b = Cos(the_kB) - w_sc/w_ce
;;  c = a
;;  d = -(w_sc/w_ce)
;; => Define coefficients
b_low        = COS(th_kB_avs*!DPI/18d1) - wsc_wce_low
b_hig        = COS(th_kB_avs*!DPI/18d1) - wsc_wce_hig
d_low        = -1d0*wsc_wce_low
d_hig        = -1d0*wsc_wce_hig
;;  + Doppler shift -> (the_kV < 90)
a_pos        = Vk_Vae_pos
c_pos        = Vk_Vae_pos
;;  - Doppler shift -> (the_kV > 90)
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

;; => Calculate rest-frame frequencies [units of w_ce]
cthkb_3d      = COS(th_kB_avs*!DPI/18d1) # REPLICATE(1d0,3L)
sthkb_3d      = SIN(th_kB_avs*!DPI/18d1) # REPLICATE(1d0,3L)
wrest_low_pos = kbar_low_pos^2*cthkb_3d/(1d0 + kbar_low_pos^2)
wrest_hig_pos = kbar_hig_pos^2*cthkb_3d/(1d0 + kbar_hig_pos^2)
wrest_low_neg = kbar_low_neg^2*cthkb_3d/(1d0 + kbar_low_neg^2)
wrest_hig_neg = kbar_hig_neg^2*cthkb_3d/(1d0 + kbar_hig_neg^2)

;; => Define wave number magnitudes [km^(-1)] (+ sign)
k_km_low_pos = kbar_low_pos*(wpe # REPLICATE(1d0,3L))/ckm[0]
k_km_hig_pos = kbar_hig_pos*(wpe # REPLICATE(1d0,3L))/ckm[0]
;; => Define wave number magnitudes [km^(-1)] (- sign)
k_km_low_neg = kbar_low_neg*(wpe # REPLICATE(1d0,3L))/ckm[0]
k_km_hig_neg = kbar_hig_neg*(wpe # REPLICATE(1d0,3L))/ckm[0]

;; => Define parallel wave number magnitudes [km^(-1)] (+ sign)
kpar_low_pos = k_km_low_pos*(COS(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))
kpar_hig_pos = k_km_hig_pos*(COS(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))
;; => Define parallel wave number magnitudes [km^(-1)] (- sign)
kpar_low_neg = k_km_low_neg*(COS(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))
kpar_hig_neg = k_km_hig_neg*(COS(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))
;; => Define perpendicular wave number magnitudes [km^(-1)] (+ sign)
kper_low_pos = k_km_low_pos*(SIN(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))
kper_hig_pos = k_km_hig_pos*(SIN(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))
;; => Define perpendicular wave number magnitudes [km^(-1)] (- sign)
kper_low_neg = k_km_low_neg*(SIN(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))
kper_hig_neg = k_km_hig_neg*(SIN(thkba0*!DPI/18d1) # REPLICATE(1d0,3L))


;; => Define rest frame frequencies [Hz] (+ sign)
frest_low_pos = (wrest_low_pos*(wce_0 # REPLICATE(1d0,3)))/(2d0*!DPI)
frest_hig_pos = (wrest_hig_pos*(wce_0 # REPLICATE(1d0,3)))/(2d0*!DPI)
;; => Define rest frame frequencies [Hz] (- sign)
frest_low_neg = (wrest_low_neg*(wce_0 # REPLICATE(1d0,3)))/(2d0*!DPI)
frest_hig_neg = (wrest_hig_neg*(wce_0 # REPLICATE(1d0,3)))/(2d0*!DPI)


x             = kbar_low_pos
good          = WHERE(x gt 0)
gind          = ARRAY_INDICES(x,good)
PRINT,';  ', minmax(gind[1,*])
;             2           2

x             = kbar_hig_pos
good          = WHERE(x gt 0)
gind          = ARRAY_INDICES(x,good)
PRINT,';  ', minmax(gind[1,*])
;             2           2

x             = kbar_low_neg
good          = WHERE(x gt 0)
gind          = ARRAY_INDICES(x,good)
PRINT,';  ', minmax(gind[1,*])
;             1           2

x             = kbar_hig_neg
good          = WHERE(x gt 0)
gind          = ARRAY_INDICES(x,good)
PRINT,';  ', minmax(gind[1,*])
;             1           2

;;----------------------------------------------------------------------------------------
;; => Print out rest frame normalized wave numbers for WW only
;;----------------------------------------------------------------------------------------
kbar_lp_whi   = kbar_low_pos[good_whi,2]
kbar_hp_whi   = kbar_hig_pos[good_whi,2]
kbar_ln_whi0  = kbar_low_neg[good_whi,1]
kbar_hn_whi0  = kbar_hig_neg[good_whi,1]
kbar_ln_whi1  = kbar_low_neg[good_whi,2]
kbar_hn_whi1  = kbar_hig_neg[good_whi,2]

x             = kbar_lp_whi
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kbar_hp_whi
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.18542959      0.36138797      0.25425330     0.045295582    0.0038558160
;        0.48932924      0.87258313      0.64227530      0.12632595     0.010753579
;-----------------------------------------------------------------------------------------

x             = kbar_ln_whi0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kbar_hn_whi0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.24817494      0.43829898      0.30633327     0.048174074    0.0041008495
;        0.55708426       1.0209724      0.73617040      0.11960649     0.010181580
;-----------------------------------------------------------------------------------------

x             = kbar_ln_whi1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kbar_hn_whi1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         9.7201886       1756.9430       50.851724       163.33799       13.904253
;         6.7567720       1127.4035       34.465780       104.63094       8.9067772
;-----------------------------------------------------------------------------------------

x = [kbar_lp_whi,kbar_hp_whi,kbar_ln_whi0,kbar_hn_whi0]
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.18542959       1.0209724      0.48475807      0.22789770     0.019399941
;-----------------------------------------------------------------------------------------


;;----------------------------------------------------------------------------------------
;; => Print out rest frame normalized wave numbers for WW only
;;----------------------------------------------------------------------------------------
k_re_lp_whi   = k_km_low_pos[good_whi,2]*rhoe[good_whi]
k_re_hp_whi   = k_km_hig_pos[good_whi,2]*rhoe[good_whi]
k_re_ln_whi0  = k_km_low_neg[good_whi,1]*rhoe[good_whi]
k_re_hn_whi0  = k_km_hig_neg[good_whi,1]*rhoe[good_whi]
k_re_ln_whi1  = k_km_low_neg[good_whi,2]*rhoe[good_whi]
k_re_hn_whi1  = k_km_hig_neg[good_whi,2]*rhoe[good_whi]

x             = k_re_lp_whi
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = k_re_hp_whi
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.17424728      0.32267889      0.22994417     0.038934179    0.0033142974
;        0.47005745      0.72468954      0.57455807     0.058744207    0.0050006390
;-----------------------------------------------------------------------------------------

x             = k_re_ln_whi0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = k_re_hn_whi0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.20743700      0.39968440      0.27887858     0.051515182    0.0043852635
;        0.56703192      0.83019194      0.66157606     0.062516595    0.0053217659
;-----------------------------------------------------------------------------------------

x             = k_re_ln_whi1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = k_re_hn_whi1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         9.2360405       1343.7649       42.063173       124.66545       10.612228
;         6.4202272       862.27347       28.815109       79.863233       6.7984098
;-----------------------------------------------------------------------------------------

x = [k_re_lp_whi,k_re_hp_whi,k_re_ln_whi0,k_re_hn_whi0]
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.17424728      0.83019194      0.43623922      0.19296631     0.016426383
;-----------------------------------------------------------------------------------------





;;----------------------------------------------------------------------------------------
;; => Print out rest frame frequencies for WW only
;;----------------------------------------------------------------------------------------
;;  [2 index has positive k solutions]
x             = frest_low_pos[good_whi,2]
f_lp_out      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = frest_hig_pos[good_whi,2]
f_hp_out      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
PRINT,';  ', f_lp_out
PRINT,';  ', f_hp_out
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         20.783803       56.293269       33.479053       10.415913      0.88666139
;         82.777903       249.73482       160.75166       52.852843       4.4991328
;-----------------------------------------------------------------------------------------


;;  [1 and 2 indices have positive k solutions]
x             = frest_low_neg[good_whi,1]
f_ln_out      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = frest_hig_neg[good_whi,1]
f_hn_out      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
PRINT,';  ', f_ln_out
PRINT,';  ', f_hn_out
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         32.864804       76.882881       46.646605       10.811587      0.92034339
;         109.54895       272.58288       192.22546       49.430630       4.2078147
;-----------------------------------------------------------------------------------------


x             = frest_low_neg[good_whi,2]
f_ln_out      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = frest_hig_neg[good_whi,2]
f_hn_out      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
PRINT,';  ', f_ln_out
PRINT,';  ', f_hn_out
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         333.52566       630.42683       549.44129       80.156459       6.8233709
;         331.18040       629.76986       548.28548       80.242558       6.8307001
;-----------------------------------------------------------------------------------------

x   = [frest_low_pos[good_whi,2],frest_hig_pos[good_whi,2],frest_low_neg[good_whi,1],frest_hig_neg[good_whi,1]]
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x = [wrest_low_pos[good_whi,2],wrest_hig_pos[good_whi,2],wrest_low_neg[good_whi,1],wrest_hig_neg[good_whi,1]]
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         20.783803       272.58288       108.27570       78.519519       6.6840253
;       0.032882188      0.43098696      0.18236688      0.12636099     0.010756562
;-----------------------------------------------------------------------------------------



kpar_lp_whi   = kpar_low_pos[good_whi,2]*rhoe[good_whi]
kpar_hp_whi   = kpar_hig_pos[good_whi,2]*rhoe[good_whi]
kpar_ln_whi0  = kpar_low_neg[good_whi,1]*rhoe[good_whi]
kpar_hn_whi0  = kpar_hig_neg[good_whi,1]*rhoe[good_whi]
kpar_ln_whi1  = kpar_low_neg[good_whi,2]*rhoe[good_whi]
kpar_hn_whi1  = kpar_hig_neg[good_whi,2]*rhoe[good_whi]

x             = kpar_lp_whi
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kpar_hp_whi
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.16616489      0.31327019      0.21268446     0.035391064    0.0030126874
;        0.45488533      0.64046896      0.53137440     0.048501885    0.0041287546
;-----------------------------------------------------------------------------------------

x             = kpar_ln_whi0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kpar_hn_whi0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.19637359      0.36804268      0.25802190     0.046411295    0.0039507918
;        0.50952238      0.80295351      0.61171743     0.047951952    0.0040819412
;-----------------------------------------------------------------------------------------

x             = kpar_ln_whi1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kpar_hn_whi1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         8.1521257       1293.9134       39.491429       120.03416       10.217986
;         6.2090686       830.28453       27.031457       76.868573       6.5434874
;-----------------------------------------------------------------------------------------

x = [kpar_lp_whi,kpar_hp_whi,kpar_ln_whi0,kpar_hn_whi0]
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.16616489      0.80295351      0.40344955      0.17713563     0.015078786
;-----------------------------------------------------------------------------------------



kper_lp_whi   = kper_low_pos[good_whi,2]*rhoe[good_whi]
kper_hp_whi   = kper_hig_pos[good_whi,2]*rhoe[good_whi]
kper_ln_whi0  = kper_low_neg[good_whi,1]*rhoe[good_whi]
kper_hn_whi0  = kper_hig_neg[good_whi,1]*rhoe[good_whi]
kper_ln_whi1  = kper_low_neg[good_whi,2]*rhoe[good_whi]
kper_hn_whi1  = kper_hig_neg[good_whi,2]*rhoe[good_whi]

x             = kper_lp_whi
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kper_hp_whi
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0077176113      0.21232799     0.077201605     0.044217152    0.0037640139
;       0.020526095      0.52469945      0.19312449      0.10787013    0.0091825154
;-----------------------------------------------------------------------------------------

x             = kper_ln_whi0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kper_hn_whi0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;       0.010652112      0.23318802     0.093183126     0.055072959    0.0046881215
;       0.025137455      0.55653645      0.22233779      0.12554709     0.010687278
;-----------------------------------------------------------------------------------------

x             = kper_ln_whi1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kper_hn_whi1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.56691458       362.61856       13.040785       34.252598       2.9157747
;        0.45101992       232.68680       8.9579074       22.110328       1.8821561
;-----------------------------------------------------------------------------------------

x = [kper_lp_whi,kper_hp_whi,kper_ln_whi0,kper_hn_whi0]
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0077176113      0.55653645      0.14646175      0.10932556    0.0093064099
;-----------------------------------------------------------------------------------------



;;----------------------------------------------------------------------------------------
;; => Look at real frequency at maximum growth
;;----------------------------------------------------------------------------------------
;; Temp. Anisotropy [Gary and Wang, 1996]

;; real frequency [Hz]
fr_lp_whi     = 24d0*kpar_lp_whi*v_a[good_whi]/(2d0*!DPI)
fr_hp_whi     = 24d0*kpar_hp_whi*v_a[good_whi]/(2d0*!DPI)
fr_ln_whi0    = 24d0*kpar_ln_whi0*v_a[good_whi]/(2d0*!DPI)
fr_hn_whi0    = 24d0*kpar_hn_whi0*v_a[good_whi]/(2d0*!DPI)
fr_ln_whi1    = 24d0*kpar_ln_whi1*v_a[good_whi]/(2d0*!DPI)
fr_hn_whi1    = 24d0*kpar_hn_whi1*v_a[good_whi]/(2d0*!DPI)

x             = fr_lp_whi
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = fr_hp_whi
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         49.894369       101.92040       77.558973       14.067424       1.1974987
;         107.68609       284.32559       198.86383       51.578466       4.3906506
;-----------------------------------------------------------------------------------------

x             = fr_ln_whi0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = fr_hn_whi0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         67.906000       119.02822       93.187768       12.751261       1.0854594
;         135.62860       305.40667       227.15900       49.994600       4.2558229
;-----------------------------------------------------------------------------------------

x             = fr_ln_whi1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = fr_hn_whi1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         1897.8811       598464.78       16593.076       55740.766       4744.9691
;         1445.5216       384025.73       11200.116       35707.484       3039.6229
;-----------------------------------------------------------------------------------------


;; Whistler heat flux [Gary et al., 1994]
kpar_lp_whi   = kpar_low_pos[good_whi,2]
kpar_hp_whi   = kpar_hig_pos[good_whi,2]
kpar_ln_whi0  = kpar_low_neg[good_whi,1]
kpar_hn_whi0  = kpar_hig_neg[good_whi,1]
kpar_ln_whi1  = kpar_low_neg[good_whi,2]
kpar_hn_whi1  = kpar_hig_neg[good_whi,2]

;; real frequency [Hz]
betapac       = (betapacs + betapace)/2d0
fr_lp_whi     = 9.52d0*kpar_lp_whi*v_a[good_whi]/(2d0*!DPI*betapac[good_whi]^(0.35d0))
fr_hp_whi     = 9.52d0*kpar_hp_whi*v_a[good_whi]/(2d0*!DPI*betapac[good_whi]^(0.35d0))
fr_ln_whi0    = 9.52d0*kpar_ln_whi0*v_a[good_whi]/(2d0*!DPI*betapac[good_whi]^(0.35d0))
fr_hn_whi0    = 9.52d0*kpar_hn_whi0*v_a[good_whi]/(2d0*!DPI*betapac[good_whi]^(0.35d0))
fr_ln_whi1    = 9.52d0*kpar_ln_whi1*v_a[good_whi]/(2d0*!DPI*betapac[good_whi]^(0.35d0))
fr_hn_whi1    = 9.52d0*kpar_hn_whi1*v_a[good_whi]/(2d0*!DPI*betapac[good_whi]^(0.35d0))

x             = fr_lp_whi
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = fr_hp_whi
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         20.188971       57.732395       37.242997       10.616871      0.90376804
;         43.573481       161.05508       96.811179       37.381076       3.1820885
;-----------------------------------------------------------------------------------------

x             = fr_ln_whi0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = fr_hn_whi0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         27.477094       61.866413       44.370105       9.5662005      0.81432906
;         55.104273       173.79352       109.92926       37.177721       3.1647778
;-----------------------------------------------------------------------------------------

x             = fr_ln_whi1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = fr_hn_whi1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         767.94770       338997.94       8819.3606       31660.126       2695.0889
;         584.90755       217529.81       5895.3867       20287.584       1726.9938
;-----------------------------------------------------------------------------------------




