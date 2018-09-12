@load_tdss_lhw_stats.pro

v_a   = (v_a_e + v_a_s)/2d0
wpi_s = wpifac[0]*SQRT(dens_s)
wpi_e = wpifac[0]*SQRT(dens_e)
wpi   = (wpi_s + wpi_e)/2d0
;-----------------------------------------------------------------------------------------
; => Look at only the mixed-mode waves [without precursors]
;-----------------------------------------------------------------------------------------
good_mix   = array_where(evns,evns_mix,/N_UNIQ)
good_mix   = good_mix[*,0]
PRINT,';  ', N_ELEMENTS(good_mix)
;           205

; => use the SC frame filter values to separate high from low
test_high  = (freql[good_mix] GT wlh[good_mix]/(2d0*!DPI)) AND $
             (freqh[good_mix] GT 40d0)
good_high  = WHERE(test_high,gdhg,COMPLEMENT=good_low,NCOMPLEMENT=gdlw)
PRINT,''
PRINT,'MIXED [Low, High]'
PRINT,';  ', gdlw,  gdhg
;            43         162
good_mixlw = good_mix[good_low]
good_mixhg = good_mix[good_high]

gels       = good_mixhg
nfac       = SQRT(gdhg)
db_bo      = filtamp[gels]/bmag_s[gels]
PRINT,';  ',  MIN(db_bo,/NAN),  MAX(db_bo,/NAN),  MEAN(db_bo,/NAN),  STDDEV(db_bo,/NAN),  STDDEV(db_bo,/NAN)/nfac[0]
;     8.4930966e-05     0.069054912     0.014520645     0.014062455    0.0011048507

db_bo      = pkamps[gels]/bmag_s[gels]
PRINT,';  ',  MIN(db_bo,/NAN),  MAX(db_bo,/NAN),  MEAN(db_bo,/NAN),  STDDEV(db_bo,/NAN),  STDDEV(db_bo,/NAN)/nfac[0]
;      0.0289238     0.316357    0.0934084    0.0796824   0.00626044


thkba0     = thkba < (18d1 - thkba)
thkva0     = thkva < (18d1 - thkva)
thkn80     = thkn8 < (18d1 - thkn8)
thkn90     = thkn9 < (18d1 - thkn9)
PRINT,';  ',  MIN(thkba0[gels],/NAN),  MAX(thkba0[gels],/NAN),  MEAN(thkba0[gels],/NAN),  STDDEV(thkba0[gels],/NAN)
PRINT,';  ',  MIN(thkva0[gels],/NAN),  MAX(thkva0[gels],/NAN),  MEAN(thkva0[gels],/NAN),  STDDEV(thkva0[gels],/NAN)
PRINT,';  ',  MIN(thkn80[gels],/NAN),  MAX(thkn80[gels],/NAN),  MEAN(thkn80[gels],/NAN),  STDDEV(thkn80[gels],/NAN)
PRINT,';  ',  MIN(thkn90[gels],/NAN),  MAX(thkn90[gels],/NAN),  MEAN(thkn90[gels],/NAN),  STDDEV(thkn90[gels],/NAN)
;---------------------------------------------------------------------
; => Theta_[kB, kV, kn08, kn09]
;---------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.
;=====================================================================
;         2.1900001       89.871506       37.375346       23.058138
;         10.375504       89.637001       61.320855       22.677564
;         7.7391048       89.426287       62.563290       20.559527
;         7.6778789       89.892955       62.829962       21.095328
;---------------------------------------------------------------------


unq_mix   = UNIQ(evns[good_mix],SORT(evns[good_mix]))
ugel_mix  = good_mix[unq_mix]
PRINT,';  ', N_ELEMENTS(ugel_mix)
;            11
mform     = '(";   ",a23,"   ",a23,"   ",I9.9)'
FOR j=0L, N_ELEMENTS(ugel_mix) - 1L DO PRINT,FORMAT=mform, scets[ugel_mix[j]], scete[ugel_mix[j]], evns[ugel_mix[j]]
;==================================================================
;   1998-09-24/23:22:24.983   1998-09-24/23:22:26.074   002011723
;   1998-09-24/23:22:46.502   1998-09-24/23:22:47.593   002011820
;   1998-09-24/23:30:46.893   1998-09-24/23:30:47.984   002013165
;   1998-09-24/23:45:50.535   1998-09-24/23:45:51.626   002015299
;   1998-09-24/23:45:51.730   1998-09-24/23:45:52.821   002015304
;   1998-09-24/23:48:40.482   1998-09-24/23:48:41.573   002015650
;   1998-09-25/00:05:21.783   1998-09-25/00:05:22.874   002017555
;   2000-02-11/23:33:56.703   2000-02-11/23:33:57.794   023145474
;   2000-02-11/23:33:59.082   2000-02-11/23:34:00.173   023145484
;   2000-04-06/16:33:08.622   2000-04-06/16:33:09.713   027126638
;   2000-04-06/18:30:59.901   2000-04-06/18:31:00.992   027134252
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
kbar_lp_mxh   = kbar_low_pos[good_mixhg,2]
kbar_hp_mxh   = kbar_hig_pos[good_mixhg,2]
kbar_ln_mxh0  = kbar_low_neg[good_mixhg,1]
kbar_hn_mxh0  = kbar_hig_neg[good_mixhg,1]
kbar_ln_mxh1  = kbar_low_neg[good_mixhg,2]
kbar_hn_mxh1  = kbar_hig_neg[good_mixhg,2]

x             = kbar_lp_mxh
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kbar_hp_mxh
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.14449221       3.1949453      0.48715422      0.41898868     0.032918859
;        0.36418123       29.722728       1.0745482       2.3234910      0.18255068
;-----------------------------------------------------------------------------------------

x             = kbar_ln_mxh0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kbar_hn_mxh0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0063050089       2.6417911      0.51960545      0.33981803     0.026698625
;      0.0013025604       2.2692405      0.84067173      0.43571199     0.034232766
;-----------------------------------------------------------------------------------------

x             = kbar_ln_mxh1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kbar_hn_mxh1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0063050089       1416.0915       60.129143       165.67162       13.016391
;      0.0013025604       1071.2897       45.671185       128.90269       10.127552
;-----------------------------------------------------------------------------------------

x   = [kbar_lp_mxh,kbar_hp_mxh,kbar_ln_mxh0,kbar_hn_mxh0]
bad = WHERE(x GT 5,bd)
IF (bd GT 0) THEN x[bad] = d
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0013025604       3.8656841      0.68568465      0.46997882     0.036925022
;-----------------------------------------------------------------------------------------


;;----------------------------------------------------------------------------------------
;; => Print out rest frame normalized wave numbers for WW only
;;----------------------------------------------------------------------------------------
k_re_lp_mxh   = k_km_low_pos[good_mixhg,2]*rhoe[good_mixhg]
k_re_hp_mxh   = k_km_hig_pos[good_mixhg,2]*rhoe[good_mixhg]
k_re_ln_mxh0  = k_km_low_neg[good_mixhg,1]*rhoe[good_mixhg]
k_re_hn_mxh0  = k_km_hig_neg[good_mixhg,1]*rhoe[good_mixhg]
k_re_ln_mxh1  = k_km_low_neg[good_mixhg,2]*rhoe[good_mixhg]
k_re_hn_mxh1  = k_km_hig_neg[good_mixhg,2]*rhoe[good_mixhg]

x             = k_re_lp_mxh
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = k_re_hp_mxh
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;       0.071889876       1.9445018      0.35562949      0.27074048     0.021271380
;        0.18331992       16.051103      0.79965092       1.2980186      0.10198197
;-----------------------------------------------------------------------------------------

x             = k_re_ln_mxh0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = k_re_hn_mxh0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0055384097       1.6078421      0.38971087      0.27284204     0.021436494
;      0.0013530564       2.7882682      0.65288788      0.47412077     0.037250445
;-----------------------------------------------------------------------------------------

x             = k_re_ln_mxh1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = k_re_hn_mxh1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0055384097       814.54684       46.684654       124.90138       9.8131791
;      0.0013530564       591.23121       34.342987       91.324215       7.1751078
;-----------------------------------------------------------------------------------------

x = [k_re_lp_mxh,k_re_hp_mxh,k_re_ln_mxh0,k_re_hn_mxh0]
bad = WHERE(x GT 5,bd)
IF (bd GT 0) THEN x[bad] = d
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0013530564       2.7882682      0.52551054      0.41760995     0.032810536
;-----------------------------------------------------------------------------------------





;;----------------------------------------------------------------------------------------
;; => Print out rest frame frequencies for WW only
;;----------------------------------------------------------------------------------------
;;  [2 index has positive k solutions]
x             = frest_low_pos[good_mixhg,2]
f_lp_out      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = frest_hig_pos[good_mixhg,2]
f_hp_out      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
PRINT,';  ', f_lp_out
PRINT,';  ', f_hp_out
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.21899806       226.88127       88.343874       63.253416       4.9696575
;         1.1306719       382.44500       200.93832       92.509441       7.2682279
;-----------------------------------------------------------------------------------------

;;  [1 and 2 indices have positive k solutions]
x             = frest_low_neg[good_mixhg,1]
f_ln_out      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = frest_hig_neg[good_mixhg,1]
f_hn_out      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
PRINT,';  ', f_ln_out
PRINT,';  ', f_hn_out
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;     5.4382423e-05       325.65309       113.79032       81.753489       6.4231605
;     2.3211296e-06       491.77611       234.74539       131.32253       10.317672
;-----------------------------------------------------------------------------------------

x             = frest_low_neg[good_mixhg,2]
f_ln_out      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = frest_hig_neg[good_mixhg,2]
f_hn_out      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
PRINT,';  ', f_ln_out
PRINT,';  ', f_hn_out
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;     5.4382423e-05       1174.5524       577.51747       312.31393       24.537699
;     2.3211296e-06       1174.4531       567.00526       321.24520       25.239406
;-----------------------------------------------------------------------------------------

x = [frest_low_pos[good_mixhg,2],frest_hig_pos[good_mixhg,2],frest_low_neg[good_mixhg,1],frest_hig_neg[good_mixhg,1]]
bad = WHERE(x LT 1,bd)
IF (bd GT 0) THEN x[bad] = d
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x = [wrest_low_pos[good_mixhg,2],wrest_hig_pos[good_mixhg,2],wrest_low_neg[good_mixhg,1],wrest_hig_neg[good_mixhg,1]]
bad = WHERE(x LT 1d-3,bd)
IF (bd GT 0) THEN x[bad] = d
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         1.1306719       491.77611       163.74427       111.17054       8.7343819
;      0.0013822675      0.60709575      0.21372734      0.14264862     0.011207533
;-----------------------------------------------------------------------------------------



kpar_lp_mxh   = kpar_low_pos[good_mixhg,2]*rhoe[good_mixhg]
kpar_hp_mxh   = kpar_hig_pos[good_mixhg,2]*rhoe[good_mixhg]
kpar_ln_mxh0  = kpar_low_neg[good_mixhg,1]*rhoe[good_mixhg]
kpar_hn_mxh0  = kpar_hig_neg[good_mixhg,1]*rhoe[good_mixhg]
kpar_ln_mxh1  = kpar_low_neg[good_mixhg,2]*rhoe[good_mixhg]
kpar_hn_mxh1  = kpar_hig_neg[good_mixhg,2]*rhoe[good_mixhg]

x             = kpar_lp_mxh
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kpar_hp_mxh
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0010170157      0.73132346      0.23547166      0.14914094     0.011717619
;      0.0050841661       3.1211110      0.47056387      0.36128008     0.028384843
;-----------------------------------------------------------------------------------------

x             = kpar_ln_mxh0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kpar_hn_mxh0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;     1.4688062e-05      0.90702970      0.28201555      0.18651525     0.014654021
;     3.0344267e-06       1.9018968      0.52017309      0.40146940     0.031542414
;-----------------------------------------------------------------------------------------

x             = kpar_ln_mxh1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kpar_hn_mxh1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;     1.4688062e-05       762.45934       43.318785       118.40998       9.3031661
;     3.0344267e-06       581.53212       32.016352       86.830026       6.8220109
;-----------------------------------------------------------------------------------------

x = [kpar_lp_mxh,kpar_hp_mxh,kpar_ln_mxh0,kpar_hn_mxh0]
bad = WHERE(x GT 5 OR x LT 1d-3,bd)
IF (bd GT 0) THEN x[bad] = d
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0010170157       3.1211110      0.38116970      0.31767495     0.024958901
;-----------------------------------------------------------------------------------------



kper_lp_mxh   = kper_low_pos[good_mixhg,2]*rhoe[good_mixhg]
kper_hp_mxh   = kper_hig_pos[good_mixhg,2]*rhoe[good_mixhg]
kper_ln_mxh0  = kper_low_neg[good_mixhg,1]*rhoe[good_mixhg]
kper_hn_mxh0  = kper_hig_neg[good_mixhg,1]*rhoe[good_mixhg]
kper_ln_mxh1  = kper_low_neg[good_mixhg,2]*rhoe[good_mixhg]
kper_hn_mxh1  = kper_hig_neg[good_mixhg,2]*rhoe[good_mixhg]

x             = kper_lp_mxh
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kper_hp_mxh
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0057770825       1.9439916      0.21802246      0.27330375     0.021472770
;       0.014036073       15.744731      0.52781420       1.3017751      0.10227711
;-----------------------------------------------------------------------------------------

x             = kper_ln_mxh0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kper_hn_mxh0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0055369566       1.3381410      0.22875168      0.24452732     0.019211880
;      0.0013530530       2.0389282      0.33665535      0.32591650     0.025606418
;-----------------------------------------------------------------------------------------

x             = kper_ln_mxh1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = kper_hn_mxh1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0055369566       286.60481       15.233925       40.629304       3.1921395
;      0.0013530530       215.93783       10.890413       28.925319       2.2725876
;-----------------------------------------------------------------------------------------

x = [kper_lp_mxh,kper_hp_mxh,kper_ln_mxh0,kper_hn_mxh0]
bad = WHERE(x GT 5 OR x LT 1d-3,bd)
IF (bd GT 0) THEN x[bad] = d
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0013530530       2.3521083      0.30398261      0.35968323     0.028259382
;-----------------------------------------------------------------------------------------



;;----------------------------------------------------------------------------------------
;; => Look at real frequency at maximum growth
;;----------------------------------------------------------------------------------------
;; Temp. Anisotropy [Gary and Wang, 1996]

;; real frequency [Hz]
fr_lp_mxh     = 24d0*kpar_lp_mxh*v_a[good_mixhg]/(2d0*!DPI)
fr_hp_mxh     = 24d0*kpar_hp_mxh*v_a[good_mixhg]/(2d0*!DPI)
fr_ln_mxh0    = 24d0*kpar_ln_mxh0*v_a[good_mixhg]/(2d0*!DPI)
fr_hn_mxh0    = 24d0*kpar_hn_mxh0*v_a[good_mixhg]/(2d0*!DPI)
fr_ln_mxh1    = 24d0*kpar_ln_mxh1*v_a[good_mixhg]/(2d0*!DPI)
fr_hn_mxh1    = 24d0*kpar_hn_mxh1*v_a[good_mixhg]/(2d0*!DPI)

x             = fr_lp_mxh
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = fr_hp_mxh
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.39542307       239.64339       106.75619       51.776391       4.0679373
;         1.9767607       2060.7377       212.30125       167.58062       13.166376
;-----------------------------------------------------------------------------------------

x             = fr_ln_mxh0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = fr_hn_mxh0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0057108251       425.29600       128.19029       68.640704       5.3929228
;      0.0011798071       623.22217       230.83118       125.61767       9.8694559
;-----------------------------------------------------------------------------------------

x             = fr_ln_mxh1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = fr_hn_mxh1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0057108251       468427.16       19410.261       54636.157       4292.6217
;      0.0011798071       354370.60       14723.878       42111.431       3308.5864
;-----------------------------------------------------------------------------------------


;; Whistler heat flux [Gary et al., 1994]
kpar_lp_mxh   = kpar_low_pos[good_mixhg,2]
kpar_hp_mxh   = kpar_hig_pos[good_mixhg,2]
kpar_ln_mxh0  = kpar_low_neg[good_mixhg,1]
kpar_hn_mxh0  = kpar_hig_neg[good_mixhg,1]
kpar_ln_mxh1  = kpar_low_neg[good_mixhg,2]
kpar_hn_mxh1  = kpar_hig_neg[good_mixhg,2]

;; real frequency [Hz]
betapac       = (betapacs + betapace)/2d0
fr_lp_mxh     = 9.52d0*kpar_lp_mxh*v_a[good_mixhg]/(2d0*!DPI*betapac[good_mixhg]^(0.35d0))
fr_hp_mxh     = 9.52d0*kpar_hp_mxh*v_a[good_mixhg]/(2d0*!DPI*betapac[good_mixhg]^(0.35d0))
fr_ln_mxh0    = 9.52d0*kpar_ln_mxh0*v_a[good_mixhg]/(2d0*!DPI*betapac[good_mixhg]^(0.35d0))
fr_hn_mxh0    = 9.52d0*kpar_hn_mxh0*v_a[good_mixhg]/(2d0*!DPI*betapac[good_mixhg]^(0.35d0))
fr_ln_mxh1    = 9.52d0*kpar_ln_mxh1*v_a[good_mixhg]/(2d0*!DPI*betapac[good_mixhg]^(0.35d0))
fr_hn_mxh1    = 9.52d0*kpar_hn_mxh1*v_a[good_mixhg]/(2d0*!DPI*betapac[good_mixhg]^(0.35d0))

x             = fr_lp_mxh
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = fr_hp_mxh
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.14367922       172.92505       79.621187       50.193782       3.9435958
;        0.71826725       2006.9936       153.88420       164.45876       12.921100
;-----------------------------------------------------------------------------------------

x             = fr_ln_mxh0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = fr_hn_mxh0
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0020750608       341.31084       95.183490       65.364293       5.1355037
;     0.00042868964       396.70603       164.97122       104.37719       8.2006462
;-----------------------------------------------------------------------------------------

x             = fr_ln_mxh1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
x             = fr_hn_mxh1
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;      0.0020750608       456210.56       14393.455       48948.837       3845.7837
;     0.00042868964       345128.60       11431.603       39697.486       3118.9290
;-----------------------------------------------------------------------------------------




