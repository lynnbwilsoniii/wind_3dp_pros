@load_tdss_lhw_stats.pro

;-----------------------------------------------------------------------------------------
; => References:
;
;    Huba, J.D., N.T. Gladd, and K. Papadopoulos (1978), "Lower-hybrid-drift wave
;       turbulence in the distant magnetotail," J. Geophys. Res. Vol. 83,
;       pp. 5217-5226.
;
;    Shapiro, V.D., V.I. Shevchenko, G.I. Solov'ev, V.P. Kalinin, R. Bingham,
;       R.Z. Sagdeev, M. Ashour-Abdalla, J. Dawson, and J.J. Su (1993),
;       "Wave collapse at the lower-hybrid resonance," Phys. Fluids B: Plasma Phys.
;       Vol. 5, pp. 3148-3162.
;
;    Shapiro, V.D., V.I. Shevchenko, P.J. Cargill, and K. Papadopoulos (1994), 
;       "Modulational instability of lower hybrid waves at the magnetopause,"
;        J. Geophys. Res. Vol. 99, pp. 23,735-23,740.
;
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
; => Define elements
;-----------------------------------------------------------------------------------------
;; => Lower hybrid waves
good_lhw   = array_where(evns,evns_lhw,/N_UNIQ)
good_lhw   = good_lhw[*,0]
;; unique event #'s
unq_lhw    = UNIQ(evns[good_lhw],SORT(evns[good_lhw]))
ugel_lhw   = good_lhw[unq_lhw]


;; => MIXED mode waves
good_mix   = array_where(evns,evns_mix,/N_UNIQ)
good_mix   = good_mix[*,0]
;; unique event #'s
unq_mix    = UNIQ(evns[good_mix],SORT(evns[good_mix]))
ugel_mix   = good_mix[unq_mix]
;; => use the SC frame filter values to separate high from low
test_high  = (freql[good_mix] GT wlh[good_mix]/(2d0*!DPI)) AND $
             (freqh[good_mix] GT 40d0)
good_high  = WHERE(test_high,gdhg,COMPLEMENT=good_low,NCOMPLEMENT=gdlw)

good_mixlw = good_mix[good_low]
good_mixhg = good_mix[good_high]


;; => Whistler waves
good_whi   = array_where(evns,evns_whi,/N_UNIQ)
good_whi   = good_whi[*,0]
;; unique event #'s
unq_whi    = UNIQ(evns[good_whi],SORT(evns[good_whi]))
ugel_whi   = good_whi[unq_whi]

;-----------------------------------------------------------------------------------------
; => Look at the saturation amplitude of the modulational instability due to LHDI
;-----------------------------------------------------------------------------------------
;;  define Alfvèn speed [km/s]
valf       = (v_a_s + v_a_e)/2d0
wpi        = wpifac[0]*SQRT(dens)  ;; ion plasma frequency [rad/s]
;;  define the total thermal energy [J] of the plasma
E_therm    = (dens*1d6)*K_eV[0]*kB[0]*(teavg + tiavg)

;; Using Eqs 2, 6, and 7 [Shapiro et al., 1994]
;;   => Define normalized instability threshold amplitude for LHWs
Esat_norm  = (wcp/wpi)^2/2d0*(6d0*(teavg/tiavg)*(1d0/4d0 + tiavg/teavg))

;; Define this amplitude in physical units [mV/m]
Esat       = SQRT(2d0*E_therm*Esat_norm/epo[0])*1d3

x          = Esat
temp       = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(N_ELEMENTS(x))]
PRINT,';  ', temp
;-----------------------------------------------------------------------------------------
; => Results for ALL waves
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         2.0420502       12.535662       6.8268770       2.8219474      0.12087894
;-----------------------------------------------------------------------------------------


x          = Esat[ugel_lhw]
temp       = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(N_ELEMENTS(x))]
PRINT,';  ', temp
;-----------------------------------------------------------------------------------------
; => Results for LHWs
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         5.5505589       10.491336       7.1029122       1.4486902      0.30886179
;-----------------------------------------------------------------------------------------


x          = Esat[ugel_mix]
temp       = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(N_ELEMENTS(x))]
PRINT,';  ', temp
;-----------------------------------------------------------------------------------------
; => Results for MIXED
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         3.9612444       12.535662       8.7481695       3.3134617      0.99904627
;-----------------------------------------------------------------------------------------



;; Using Eq 42 [Shapiro et al., 1993]
;;   => Define modulational instability threshold amplitude [mV/m] for LHWs
ckm        = c[0]*1d-3  ;; speed of light [km/s]
E_thresh   = SQRT(8d0*(valf/ckm[0])^2*E_therm/epo[0])*1d3

x          = E_thresh
temp       = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(N_ELEMENTS(x))]
PRINT,';  ', temp
;-----------------------------------------------------------------------------------------
; => Results for ALL waves
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         1.8645733       13.500669       7.2362614       3.1481578      0.13485226
;-----------------------------------------------------------------------------------------


x          = E_thresh[ugel_lhw]
temp       = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(N_ELEMENTS(x))]
PRINT,';  ', temp
;-----------------------------------------------------------------------------------------
; => Results for LHWs
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         5.9907147       11.248669       7.5594559       1.5931714      0.33966527
;-----------------------------------------------------------------------------------------


x          = E_thresh[ugel_mix]
temp       = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(N_ELEMENTS(x))]
PRINT,';  ', temp
;-----------------------------------------------------------------------------------------
; => Results for MIXED
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;         3.8382932       13.500669       9.3594069       3.6967253       1.1146046
;-----------------------------------------------------------------------------------------



;; Relate E to B using Eq. 25 (not labeled) from Huba et al., [1978]
B_thresh   = ((vti/c[0]^2)*SQRT(mp[0]/me[0])*(wpe/wce)^2*(E_thresh*1d-3))*1d9

x          = B_thresh
temp       = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(N_ELEMENTS(x))]
PRINT,';  ', temp
;-----------------------------------------------------------------------------------------
; => Results for ALL waves
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.53177800       2.8473520       1.3338290      0.52984817     0.022696201
;-----------------------------------------------------------------------------------------


x          = B_thresh[ugel_lhw]
temp       = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(N_ELEMENTS(x))]
PRINT,';  ', temp
;-----------------------------------------------------------------------------------------
; => Results for LHWs
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.80021997       2.3796793       1.2839509      0.45295066     0.096569403
;-----------------------------------------------------------------------------------------


x          = B_thresh[ugel_mix]
temp       = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(N_ELEMENTS(x))]
PRINT,';  ', temp
;-----------------------------------------------------------------------------------------
; => Results for MIXED
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.98094253       2.8473520       1.3083271      0.57133263      0.17226326
;-----------------------------------------------------------------------------------------


;;  Check amplitude of waves w/rt threshold
dbpk_bth   = pkamps/B_thresh
dbft_bth   = filtamp/B_thresh

x          = dbpk_bth
y          = dbft_bth
tempx      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(N_ELEMENTS(x))]
tempy      = [MIN(y,/NAN),MAX(y,/NAN),MEAN(y,/NAN),STDDEV(y,/NAN),STDDEV(y,/NAN)/SQRT(N_ELEMENTS(y))]
PRINT,';  ', tempx
PRINT,';  ', tempy
;-----------------------------------------------------------------------------------------
; => Results for ALL waves
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.17400875       41.021312       3.6034574       5.5696884      0.23857923
;      0.0019227761       39.938350       1.1080712       2.8083997      0.12029862
;-----------------------------------------------------------------------------------------


x          = dbpk_bth[ugel_lhw]
y          = dbft_bth[good_lhw]
tempx      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(N_ELEMENTS(x))]
tempy      = [MIN(y,/NAN),MAX(y,/NAN),MEAN(y,/NAN),STDDEV(y,/NAN),STDDEV(y,/NAN)/SQRT(N_ELEMENTS(y))]
PRINT,';  ', tempx
PRINT,';  ', tempy
;-----------------------------------------------------------------------------------------
; => Results for LHWs
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.17400875       5.3502570       2.4567440       1.4239943      0.30359661
;        0.13896533       4.5459257       1.2341942      0.91812718     0.084520457
;-----------------------------------------------------------------------------------------
HELP, WHERE(x GE 1), x
HELP, WHERE(y GE 1), y
;<Expression>    LONG      = Array[18]
;X               DOUBLE    = Array[22]
;<Expression>    LONG      = Array[63]
;Y               DOUBLE    = Array[118]


x          = dbpk_bth[ugel_mix]
y          = dbft_bth[good_mix]
tempx      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(N_ELEMENTS(x))]
tempy      = [MIN(y,/NAN),MAX(y,/NAN),MEAN(y,/NAN),STDDEV(y,/NAN),STDDEV(y,/NAN)/SQRT(N_ELEMENTS(y))]
PRINT,';  ', tempx
PRINT,';  ', tempy
;-----------------------------------------------------------------------------------------
; => Results for MIXED
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.38786028       4.9207965       2.2655787       1.2120343      0.36544207
;      0.0019227761       6.2896740      0.53608719      0.66763540     0.046629678
;-----------------------------------------------------------------------------------------
HELP, WHERE(x GE 1), x
HELP, WHERE(y GE 1), y
;<Expression>    LONG      = Array[10]
;X               DOUBLE    = Array[11]
;<Expression>    LONG      = Array[27]
;Y               DOUBLE    = Array[205]


x          = dbft_bth[good_mixlw]
y          = dbft_bth[good_mixhg]
tempx      = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(N_ELEMENTS(x))]
tempy      = [MIN(y,/NAN),MAX(y,/NAN),MEAN(y,/NAN),STDDEV(y,/NAN),STDDEV(y,/NAN)/SQRT(N_ELEMENTS(y))]
PRINT,';  ', tempx
PRINT,';  ', tempy
;-----------------------------------------------------------------------------------------
; => Results for MIXED [f_low]
;-----------------------------------------------------------------------------------------
;            Min             Max            Mean          Std. Dev.       Std. Dev.
;                                                                          of Mean
;=========================================================================================
;        0.16509197       6.2896740       1.2224083       1.0477114      0.15977450
;      0.0019227761       1.5247614      0.35391554      0.34529848     0.027129210
;-----------------------------------------------------------------------------------------
HELP, WHERE(x GE 1), x
HELP, WHERE(y GE 1), y
;<Expression>    LONG      = Array[18]
;X               DOUBLE    = Array[43]
;<Expression>    LONG      = Array[9]
;Y               DOUBLE    = Array[162]




















