WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100
;;----------------------------------------------------------------------------------------
;; => Load parameters
;;----------------------------------------------------------------------------------------
@load_tdss_lhw_stats.pro
;;----------------------------------------------------------------------------------------
;; => Define average parameters
;;----------------------------------------------------------------------------------------
;; Define ion plasma frequency [Hz]
wpp_s    = wpe_s*SQRT(me/mp)
wpp_e    = wpe_e*SQRT(me/mp)
wpp      = (wpp_s + wpp_e)/2d0
;; Define cyclotron frequency [Hz]
fce_s      = wce_s/(2d0*!DPI)
fce_e      = wce_e/(2d0*!DPI)
fce        = (fce_s + fce_e)/2d0
;; Define lower hybrid resonance frequency [Hz]
flh_s      = wlh_s/(2d0*!DPI)
flh_e      = wlh_e/(2d0*!DPI)
flh        = (flh_s + flh_e)/2d0
;; Define SC Frame frequency [Hz]
freqa      = (freql + freqh)/2d0
;; Define inertial lengths [km]
einer      = ckm[0]/wpe
iiner      = ckm[0]/wpp


;; => Get the lower hybrid wave elements
good_lhw   = array_where(evns,evns_lhw,/N_UNIQ)
good_lhw   = good_lhw[*,0]
PRINT,';  ', N_ELEMENTS(good_lhw)
;           118

;; => Get the whistler wave elements
good_whi   = array_where(evns,evns_whi,/N_UNIQ)
good_whi   = good_whi[*,0]
PRINT,';  ', N_ELEMENTS(good_whi)
;           138

;; => Get the mixed-mode wave [all  frequencies] elements
good_mix   = array_where(evns,evns_mix,/N_UNIQ)
good_mix   = good_mix[*,0]
PRINT,';  ', N_ELEMENTS(good_mix)
;           205

test_high  = (freql[good_mix] GT wlh[good_mix]/(2d0*!DPI)) AND $
             (freqh[good_mix] GT 40d0)
good_high  = WHERE(test_high,gdhg,COMPLEMENT=good_low,NCOMPLEMENT=gdlw)
PRINT,''
PRINT,';  MIXED [Low, High]'
PRINT,';  ', gdlw,  gdhg
;  MIXED [Low, High]
;            43         162

;; => Get the mixed-mode wave [low  frequencies] elements
good_mxl   = good_mix[good_low]

;; => Get the mixed-mode wave [high frequencies] elements
good_mxh   = good_mix[good_high]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; => Set up histograms
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
str_theta  = get_greek_letter('theta')
str_para   = get_font_symbol('parallel')
str_perp   = get_font_symbol('perpendicular')
defsuff    = '_histogram'

;; Histogram:  ø_kV  [deg]
xdat       = thkva < (18d1 - thkva)
xttl       = str_theta[0]+'!DkV!N [deg]'
fsuff      = 'Theta-kV'+defsuff[0]
xran       = [0d0,9d1]
nxt        = 10L
prec       = 3L
;; Histogram:  ø_kB  [deg]
xdat       = thkba < (18d1 - thkba)
xttl       = str_theta[0]+'!DkB!N [deg]'
fsuff      = 'Theta-kB'+defsuff[0]
xran       = [0d0,9d1]
nxt        = 10L
prec       = 3L
;; Histogram:  f_sc  [Hz]
xdat       = freqa
xttl       = 'f!Dsc!N [Hz, (Low + High)/2]'
fsuff      = 'fsc-Avg'+defsuff[0]
xran       = [0d0,3d2]
nxt        = 16L
prec       = 1L
;; Histogram:  f_sc/f_ce  [unitless]
xdat       = freqa/fce
xttl       = 'f!Dsc!N [unitless, (Low + High)/2f!Dce!N'+']'
fsuff      = 'fsc-Avg_fce'+defsuff[0]
xran       = [0d0,1d0]
nxt        = 11L
prec       = 3L
;; Histogram:  f_sc/f_lh  [unitless]
xdat       = freqa/flh
xttl       = 'f!Dsc!N [unitless, (Low + High)/2f!Dlh!N'+']'
fsuff      = 'fsc-Avg_flh'+defsuff[0]
xran       = [0d0,2d1]
nxt        = 11L
prec       = 3L
;; Histogram:  T_perph/T_parac  [unitless]
xdat       = tperh/tparc
xttl       = 'T!D'+str_perp[0]+'!N'+'/T!D'+str_para[0]+'!N [unitless, Halo-to-Core Ratio]'
fsuff      = 'Tperph_Tparac'+defsuff[0]
xran       = [3d0,1d1]
nxt        = 11L
prec       = 1L



ttles      = ['Whistler ','Lower Hybrid ','MIXED [All Freq.] ','MIXED [Low Freq.] ','MIXED [High Freq.] ']+'Waves'
fnames     = ['WW__','LHW_','MIX_','MXL_','MXH_']+fsuff[0]
xdat_whi   = xdat[good_whi]
xdat_lhw   = xdat[good_lhw]
xdat_mix   = xdat[good_mix]
xdat_mxl   = xdat[good_mxl]
xdat_mxh   = xdat[good_mxh]
tags       = ['WHI','LHW','MIX','MXL','MXH']
struc      = CREATE_STRUCT(tags,xdat_whi,xdat_lhw,xdat_mix,xdat_mxl,xdat_mxh)

FOR k=0L, N_ELEMENTS(tags) - 1L DO BEGIN                                                  $
    my_histogram_plot,struc.(k),NBINS=nxt,XTTL=xttl,TTLE=ttles[k],DRANGE=xran,PREC=prec & $
  popen,fnames[k],/LAND                                                                 & $
    my_histogram_plot,struc.(k),NBINS=nxt,XTTL=xttl,TTLE=ttles[k],DRANGE=xran,PREC=prec & $
  pclose
!P.MULTI   = 0




;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; => Set up plots
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

fpref      = 'All_Modes_'
;;----------------------------------------------------------------------------------------
;; Plot  [T_eh/T_ec vs. T_ec]
;;----------------------------------------------------------------------------------------
xdat       = tecavg
xdat_l     = tecavg_s < tecavg_e
xdat_h     = tecavg_s > tecavg_e
xttl       = 'T!Dec!N [eV]'
xran       = [1d1,6d1]

ydat       = tehc_avg
ydat_l     = tehc_avs < tehc_ave
ydat_h     = tehc_avs > tehc_ave
yttl       = 'T!Deh!N'+'/T!Dec!N [unitless]'
yran       = [3d0,9d0]
fname      = fpref[0]+'Teh-Tec_vs_Tec'

pstr       = {XTITLE:xttl,XRANGE:xran,XLOG:0,XSTYLE:1,XMINOR:10L,$
              YTITLE:yttl,YRANGE:yran,YLOG:0,YSTYLE:1,YMINOR:10L,$
              NODATA:1}
;;----------------------------------------------------------------------------------------
;; Plot  [T_eh/T_ec vs. T_eh]
;;----------------------------------------------------------------------------------------
xdat       = tehavg
xdat_l     = tehavg_s < tehavg_e
xdat_h     = tehavg_s > tehavg_e
xttl       = 'T!Deh!N [eV]'
xran       = [1d2,3d2]

ydat       = tehc_avg
ydat_l     = tehc_avs < tehc_ave
ydat_h     = tehc_avs > tehc_ave
yttl       = 'T!Deh!N'+'/T!Dec!N [unitless]'
yran       = [3d0,9d0]
fname      = fpref[0]+'Teh-Tec_vs_Teh'

pstr       = {XTITLE:xttl,XRANGE:xran,XLOG:0,XSTYLE:1,XMINOR:10L,$
              YTITLE:yttl,YRANGE:yran,YLOG:0,YSTYLE:1,YMINOR:10L,$
              NODATA:1}
;;----------------------------------------------------------------------------------------
;; Plot  [T_eh vs. T_ec]
;;----------------------------------------------------------------------------------------
xdat       = tecavg
xdat_l     = tecavg_s < tecavg_e
xdat_h     = tecavg_s > tecavg_e
xttl       = 'T!Dec!N [eV]'
xran       = [2d1,6d1]

ydat       = tehavg
ydat_l     = tehavg_s < tehavg_e
ydat_h     = tehavg_s > tehavg_e
yttl       = 'T!Deh!N [eV]'
yran       = [15d1,3d2]
fname      = fpref[0]+'Teh_vs_Tec_ylin'

pstr       = {XTITLE:xttl,XRANGE:xran,XLOG:0,XSTYLE:1,XMINOR:10L,$
              YTITLE:yttl,YRANGE:yran,YLOG:0,YSTYLE:1,YMINOR:10L,$
              NODATA:1}
;;----------------------------------------------------------------------------------------
;; Plot  [T_eh vs. T_ec]
;;----------------------------------------------------------------------------------------
xdat       = tecavg
xdat_l     = tecavg_s < tecavg_e
xdat_h     = tecavg_s > tecavg_e
xttl       = 'T!Dec!N [eV]'
xran       = [2d1,6d1]

ydat       = tehavg
ydat_l     = tehavg_s < tehavg_e
ydat_h     = tehavg_s > tehavg_e
yttl       = 'T!Deh!N [eV]'
yran       = [15d1,3d2]
ytickv     = [15d1,20d1,25d1,30d1]
ytickn     = STRTRIM(STRING(ytickv,FORMAT='(I3.3)'),2L)
yticks     = N_ELEMENTS(ytickn) - 1L
fname      = fpref[0]+'Teh_vs_Tec_ylog'

pstr       = {XTITLE:xttl,XRANGE:xran,XLOG:0,XSTYLE:1,XMINOR:10L,$
              YTITLE:yttl,YRANGE:yran,YLOG:1,YSTYLE:1,YMINOR:10L,$
              YTICKNAME:ytickn,YTICKV:ytickv,YTICKS:yticks,$
              NODATA:1}




;; Define X-Data
xdat_whi   = xdat[good_whi]
xdat_lhw   = xdat[good_lhw]
xdat_mxl   = xdat[good_mxl]
xdat_mxh   = xdat[good_mxh]
;; Define X-Errors
xerr_whi_l = ABS(xdat_l[good_whi] - xdat[good_whi])
xerr_lhw_l = ABS(xdat_l[good_lhw] - xdat[good_lhw])
xerr_mxl_l = ABS(xdat_l[good_mxl] - xdat[good_mxl])
xerr_mxh_l = ABS(xdat_l[good_mxh] - xdat[good_mxh])
xerr_whi_h = ABS(xdat_h[good_whi] - xdat[good_whi])
xerr_lhw_h = ABS(xdat_h[good_lhw] - xdat[good_lhw])
xerr_mxl_h = ABS(xdat_h[good_mxl] - xdat[good_mxl])
xerr_mxh_h = ABS(xdat_h[good_mxh] - xdat[good_mxh])
xerr_whi   = [[xerr_whi_l],[xerr_whi_h]]
xerr_lhw   = [[xerr_lhw_l],[xerr_lhw_h]]
xerr_mxl   = [[xerr_mxl_l],[xerr_mxl_h]]
xerr_mxh   = [[xerr_mxh_l],[xerr_mxh_h]]
;; Define Y-Data
ydat_whi   = ydat[good_whi]
ydat_lhw   = ydat[good_lhw]
ydat_mxl   = ydat[good_mxl]
ydat_mxh   = ydat[good_mxh]
;; Define Y-Errors
yerr_whi_l = ABS(ydat_l[good_whi] - ydat[good_whi])
yerr_lhw_l = ABS(ydat_l[good_lhw] - ydat[good_lhw])
yerr_mxl_l = ABS(ydat_l[good_mxl] - ydat[good_mxl])
yerr_mxh_l = ABS(ydat_l[good_mxh] - ydat[good_mxh])
yerr_whi_h = ABS(ydat_h[good_whi] - ydat[good_whi])
yerr_lhw_h = ABS(ydat_h[good_lhw] - ydat[good_lhw])
yerr_mxl_h = ABS(ydat_h[good_mxl] - ydat[good_mxl])
yerr_mxh_h = ABS(ydat_h[good_mxh] - ydat[good_mxh])
yerr_whi   = [[yerr_whi_l],[yerr_whi_h]]
yerr_lhw   = [[yerr_lhw_l],[yerr_lhw_h]]
yerr_mxl   = [[yerr_mxl_l],[yerr_mxl_h]]
yerr_mxh   = [[yerr_mxh_l],[yerr_mxh_h]]

;; => Create structures for plots
ttles      = ['Whistler ','Lower Hybrid ','MIXED [Low Freq.] ','MIXED [High Freq.] ']+'Waves'
tags       = ['WHI','LHW','MXL','MXH']
subtags    = ['X','Y','XERR','YERR']
strc_whi   = CREATE_STRUCT(subtags,xdat_whi,ydat_whi,xerr_whi,yerr_whi)
strc_lhw   = CREATE_STRUCT(subtags,xdat_lhw,ydat_lhw,xerr_lhw,yerr_lhw)
strc_mxl   = CREATE_STRUCT(subtags,xdat_mxl,ydat_mxl,xerr_mxl,yerr_mxl)
strc_mxh   = CREATE_STRUCT(subtags,xdat_mxh,ydat_mxh,xerr_mxh,yerr_mxh)
struc      = CREATE_STRUCT(tags,strc_whi,strc_lhw,strc_mxl,strc_mxh)

!P.MULTI   = [0,2,2]
FOR k=0L, N_ELEMENTS(tags) - 1L DO BEGIN                                 $
  PLOT,struc.(k).X,struc.(k).Y,_EXTRA=pstr,TITLE=ttles[k]              & $
    OPLOT,struc.(k).X,struc.(k).Y,PSYM=6,COLOR=250                     & $
    oploterrxy,struc.(k).X,struc.(k).Y,struc.(k).YERR,PSYM=6,COLOR=250
!P.MULTI   = 0


;; Save
!P.MULTI   = [0,2,2]
popen,fname[0],/LAND
FOR k=0L, N_ELEMENTS(tags) - 1L DO BEGIN                                 $
  PLOT,struc.(k).X,struc.(k).Y,_EXTRA=pstr,TITLE=ttles[k]              & $
    OPLOT,struc.(k).X,struc.(k).Y,PSYM=6,COLOR=250                     ;& $
;    oploterrxy,struc.(k).X,struc.(k).Y,struc.(k).YERR,PSYM=6,COLOR=250,SYMSIZ=0.50
pclose
!P.MULTI   = 0




;;----------------------------------------------------------------------------------------
;; Plot  [f_sc/f_ce vs. ø_kV]
;;----------------------------------------------------------------------------------------
ydat       = freqa/fce     ;; f_sc/f_ce
ydat_l     = freql/fce
ydat_h     = freqh/fce
yttl       = 'f!Dsc!N'+'/f!Dce!N [unitless]'
yran       = [1d-3,1d0]


ydat       = freqa
ydat_l     = freql
ydat_h     = freqh
yttl       = 'f!Dsc!N [Hz]'
yran       = [1d0,4d2]
;;----------------------------------------------------------------------------------------
;; Plot  [f_sc vs. ø_kV]
;;----------------------------------------------------------------------------------------
xdat       = thkva < (18d1 - thkva)
xttl       = get_greek_letter('theta')+'!DkV!N [deg]'
;;----------------------------------------------------------------------------------------
;; Plot  [f_sc vs. ø_kB]
;;----------------------------------------------------------------------------------------
xdat       = thkba < (18d1 - thkba)
xttl       = get_greek_letter('theta')+'!DkB!N [deg]'


xran       = [0d0,1d2]
nxt        = 11L
xtickv     = DINDGEN(nxt)*(xran[1] - xran[0])/(nxt - 1L)
xtickv     = xtickv[0L:(nxt - 2L)]
xtickn     = STRTRIM(STRING(xtickv,FORMAT='(I2.2)'),2L)
xticks     = N_ELEMENTS(xtickn) - 1L
pstr       = {XTITLE:xttl,XRANGE:xran,XLOG:0,XSTYLE:1,XTICKNAME:xtickn,XTICKV:xtickv,XTICKS:xticks,XMINOR:10L,$
              YTITLE:yttl,YRANGE:yran,YLOG:1,YSTYLE:1,$
              NODATA:1}
;; Define X-Data
xdat_whi   = xdat[good_whi]
xdat_lhw   = xdat[good_lhw]
xdat_mxl   = xdat[good_mxl]
xdat_mxh   = xdat[good_mxh]
;; Define X-Errors
xerr_whi_l = ABS(1d-1*xdat[good_whi])
xerr_whi_h = ABS(1d-1*xdat[good_whi])
xerr_lhw_l = ABS(1d-1*xdat[good_lhw])
xerr_lhw_h = ABS(1d-1*xdat[good_lhw])
xerr_mxl_l = ABS(1d-1*xdat[good_mxl])
xerr_mxl_h = ABS(1d-1*xdat[good_mxl])
xerr_mxh_l = ABS(1d-1*xdat[good_mxh])
xerr_mxh_h = ABS(1d-1*xdat[good_mxh])
xerr_whi   = [[xerr_whi_l],[xerr_whi_h]]
xerr_lhw   = [[xerr_lhw_l],[xerr_lhw_h]]
xerr_mxl   = [[xerr_mxl_l],[xerr_mxl_h]]
xerr_mxh   = [[xerr_mxh_l],[xerr_mxh_h]]
;; Define Y-Data
ydat_whi   = ydat[good_whi]
ydat_lhw   = ydat[good_lhw]
ydat_mxl   = ydat[good_mxl]
ydat_mxh   = ydat[good_mxh]
;; Define Y-Errors
yerr_whi_l = ABS(ydat_l[good_whi] - ydat[good_whi])
yerr_lhw_l = ABS(ydat_l[good_lhw] - ydat[good_lhw])
yerr_mxl_l = ABS(ydat_l[good_mxl] - ydat[good_mxl])
yerr_mxh_l = ABS(ydat_l[good_mxh] - ydat[good_mxh])
yerr_whi_h = ABS(ydat_h[good_whi] - ydat[good_whi])
yerr_lhw_h = ABS(ydat_h[good_lhw] - ydat[good_lhw])
yerr_mxl_h = ABS(ydat_h[good_mxl] - ydat[good_mxl])
yerr_mxh_h = ABS(ydat_h[good_mxh] - ydat[good_mxh])
yerr_whi   = [[yerr_whi_l],[yerr_whi_h]]
yerr_lhw   = [[yerr_lhw_l],[yerr_lhw_h]]
yerr_mxl   = [[yerr_mxl_l],[yerr_mxl_h]]
yerr_mxh   = [[yerr_mxh_l],[yerr_mxh_h]]

;; => Create structures for plots
ttles      = ['Whistler ','Lower Hybrid ','MIXED [Low Freq.] ','MIXED [High Freq.] ']+'Waves'
tags       = ['WHI','LHW','MXL','MXH']
subtags    = ['X','Y','XERR','YERR']
strc_whi   = CREATE_STRUCT(subtags,xdat_whi,ydat_whi,xerr_whi,yerr_whi)
strc_lhw   = CREATE_STRUCT(subtags,xdat_lhw,ydat_lhw,xerr_lhw,yerr_lhw)
strc_mxl   = CREATE_STRUCT(subtags,xdat_mxl,ydat_mxl,xerr_mxl,yerr_mxl)
strc_mxh   = CREATE_STRUCT(subtags,xdat_mxh,ydat_mxh,xerr_mxh,yerr_mxh)
struc      = CREATE_STRUCT(tags,strc_whi,strc_lhw,strc_mxl,strc_mxh)


!P.MULTI   = [0,2,2]
FOR k=0L, N_ELEMENTS(tags) - 1L DO BEGIN                                 $
  PLOT,struc.(k).X,struc.(k).Y,_EXTRA=pstr,TITLE=ttles[k]              & $
    OPLOT,struc.(k).X,struc.(k).Y,PSYM=6,COLOR=250                     & $
    oploterrxy,struc.(k).X,struc.(k).Y,struc.(k).YERR,PSYM=6,COLOR=250
!P.MULTI   = 0





;k          = 0L
;;;  Initialize Plot
;PLOT,struc.(k).X,struc.(k).Y,_EXTRA=pstr
;  ;;  Overplot Data
;  OPLOT,struc.(k).X,struc.(k).Y,PSYM=6,COLOR=250
;  ;;  Overplot Errors
;  oploterrxy,struc.(k).X,struc.(k).Y,struc.(k).YERR,PSYM=6,COLOR=250


















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

; => Define rest frame frequencies [Hz] (+ sign)
frest_low_pos = (wrest_low_pos*(wce_0 # REPLICATE(1d0,3)))/(2d0*!DPI)
frest_hig_pos = (wrest_hig_pos*(wce_0 # REPLICATE(1d0,3)))/(2d0*!DPI)
; => Define rest frame frequencies [Hz] (- sign)
frest_low_neg = (wrest_low_neg*(wce_0 # REPLICATE(1d0,3)))/(2d0*!DPI)
frest_hig_neg = (wrest_hig_neg*(wce_0 # REPLICATE(1d0,3)))/(2d0*!DPI)
;-----------------------------------------------------------------------------------------
; => Look at resonance energies
;-----------------------------------------------------------------------------------------
good_whi   = array_where(evns,evns_whi,/N_UNIQ)
good_whi   = good_whi[*,0]
PRINT,';  ', N_ELEMENTS(good_whi)
;           138

nfac       = SQRT(N_ELEMENTS(good_whi))
fce_whi    = wce[good_whi]/(2d0*!DPI)
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

;; Resonance for f_(sc,low) [- sign]
res_lm0    = cold_plasma_whistler_params_1d(bmaga,density,frest_lm[*,0],theta_kb)
res_lm1    = cold_plasma_whistler_params_1d(bmaga,density,frest_lm[*,1],theta_kb)
res_lm2    = cold_plasma_whistler_params_1d(bmaga,density,frest_lm[*,2],theta_kb)
;; => Landau Resonant Energies [eV]
Eresla_lm0 = res_lm0.ERES_LAND
Eresla_lm1 = res_lm1.ERES_LAND
Eresla_lm2 = res_lm2.ERES_LAND
;; => Normal Cyclotron Resonant Energies [eV]
Eresnc_lm0 = res_lm0.ERES_NCYC
Eresnc_lm1 = res_lm1.ERES_NCYC
Eresnc_lm2 = res_lm2.ERES_NCYC


;; Resonance for f_(sc,high) [- sign]
res_hm0    = cold_plasma_whistler_params_1d(bmaga,density,frest_hm[*,0],theta_kb)
res_hm1    = cold_plasma_whistler_params_1d(bmaga,density,frest_hm[*,1],theta_kb)
res_hm2    = cold_plasma_whistler_params_1d(bmaga,density,frest_hm[*,2],theta_kb)
;; => Landau Resonant Energies [eV]
Eresla_hm0 = res_hm0.ERES_LAND
Eresla_hm1 = res_hm1.ERES_LAND
Eresla_hm2 = res_hm2.ERES_LAND
;; => Normal Cyclotron Resonant Energies [eV]
Eresnc_hm0 = res_hm0.ERES_NCYC
Eresnc_hm1 = res_hm1.ERES_NCYC
Eresnc_hm2 = res_hm2.ERES_NCYC


;; Resonance for f_(sc,low) [+ sign]
res_lp0    = cold_plasma_whistler_params_1d(bmaga,density,frest_lp[*,0],theta_kb)
res_lp1    = cold_plasma_whistler_params_1d(bmaga,density,frest_lp[*,1],theta_kb)
res_lp2    = cold_plasma_whistler_params_1d(bmaga,density,frest_lp[*,2],theta_kb)
;; => Landau Resonant Energies [eV]
Eresla_lp0 = res_lp0.ERES_LAND
Eresla_lp1 = res_lp1.ERES_LAND
Eresla_lp2 = res_lp2.ERES_LAND
;; => Normal Cyclotron Resonant Energies [eV]
Eresnc_lp0 = res_lp0.ERES_NCYC
Eresnc_lp1 = res_lp1.ERES_NCYC
Eresnc_lp2 = res_lp2.ERES_NCYC


;; Resonance for f_(sc,high) [+ sign]
res_hp0    = cold_plasma_whistler_params_1d(bmaga,density,frest_hp[*,0],theta_kb)
res_hp1    = cold_plasma_whistler_params_1d(bmaga,density,frest_hp[*,1],theta_kb)
res_hp2    = cold_plasma_whistler_params_1d(bmaga,density,frest_hp[*,2],theta_kb)
;; => Landau Resonant Energies [eV]
Eresla_hp0 = res_hp0.ERES_LAND
Eresla_hp1 = res_hp1.ERES_LAND
Eresla_hp2 = res_hp2.ERES_LAND
;; => Normal Cyclotron Resonant Energies [eV]
Eresnc_hp0 = res_hp0.ERES_NCYC
Eresnc_hp1 = res_hp1.ERES_NCYC
Eresnc_hp2 = res_hp2.ERES_NCYC


;; => Symmetric results
;;
;;  Eresla_lm0  <-->  Eresla_lp2
;;  Eresla_lm1  <-->  Eresla_lp1
;;  Eresla_lm2  <-->  Eresla_lp0
;;
;;  Eresla_hm0  <-->  Eresla_hp2
;;  Eresla_hm1  <-->  Eresla_hp1
;;  Eresla_hm2  <-->  Eresla_hp0
;;

x          = [Eresla_lm0,Eresla_lm1,Eresla_lm2]
x          = x[WHERE(x GE 1.)]
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;         1.8099194       7.0522852       4.0521331       1.2973914      0.11044129

x          = [Eresla_hm0,Eresla_hm1,Eresla_hm2]
x          = x[WHERE(x GE 1.)]
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;         1.2989926       18.846259       13.125488       4.5116556      0.38405762


;; => Symmetric results
;;
;;  Eresnc_lm0  <-->  Eresnc_lp2
;;  Eresnc_lm1  <-->  Eresnc_lp1
;;  Eresnc_lm2  <-->  Eresnc_lp0
;;
;;  Eresnc_hm0  <-->  Eresnc_hp2
;;  Eresnc_hm1  <-->  Eresnc_hp1
;;  Eresnc_hm2  <-->  Eresnc_hp0
;;

x          = [Eresnc_lm0,Eresnc_lm1,Eresnc_lm2]
x          = x[WHERE(x GE 1.)]
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;         140.45240       2102.7641       930.60903       458.93172       39.066862

x          = [Eresnc_hm0,Eresnc_hm1,Eresnc_hm2]
x          = x[WHERE(x GE 1.)]
PRINT,';  ', [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),STDDEV(x,/NAN)/nfac[0]]
;         25.759805       187.06223       86.262118       47.606921       4.0525702









































































;;----------------------------------------------------------------------------------------
;; => Set up plots
;;----------------------------------------------------------------------------------------
xdat       = (freql + freqh)/2d0
xdat_l     = freql
xdat_h     = freqh

ydat       = thkva
ydat_l     = thkvs < thkve
ydat_h     = thkvs > thkve
;; Plot  [ø_kV vs. f_sc]
xttl       = 'f!Dsc!N [Hz]'
yttl       = get_greek_letter('theta')+'!DkV!N [deg]'
xran       = [1d0,4d2]
yran       = [0d0,9d1]
pstr       = {XTITLE:xttl,XRANGE:xran,XLOG:1,XSTYLE:1,$
              YTITLE:yttl,YRANGE:yran,YLOG:0,YSTYLE:1,$
              NODATA:1}

;; Define X-Data
xdat_whi   = xdat[good_whi]
xdat_lhw   = xdat[good_lhw]
xdat_mxl   = xdat[good_mxl]
xdat_mxh   = xdat[good_mxh]
;; Define X-Errors
xerr_whi_l = ABS(xdat_l[good_whi] - xdat[good_whi])
xerr_lhw_l = ABS(xdat_l[good_lhw] - xdat[good_lhw])
xerr_mxl_l = ABS(xdat_l[good_mxl] - xdat[good_mxl])
xerr_mxh_l = ABS(xdat_l[good_mxh] - xdat[good_mxh])
xerr_whi_h = ABS(xdat_h[good_whi] - xdat[good_whi])
xerr_lhw_h = ABS(xdat_h[good_lhw] - xdat[good_lhw])
xerr_mxl_h = ABS(xdat_h[good_mxl] - xdat[good_mxl])
xerr_mxh_h = ABS(xdat_h[good_mxh] - xdat[good_mxh])
xerr_whi   = [[xerr_whi_l],[xerr_whi_h]]
xerr_lhw   = [[xerr_lhw_l],[xerr_lhw_h]]
xerr_mxl   = [[xerr_mxl_l],[xerr_mxl_h]]
xerr_mxh   = [[xerr_mxh_l],[xerr_mxh_h]]

;; Define Y-Data
ydat_whi   = ydat[good_whi]
ydat_lhw   = ydat[good_lhw]
ydat_mxl   = ydat[good_mxl]
ydat_mxh   = ydat[good_mxh]
;; Define Y-Errors
yerr_whi_l = ABS(ydat_l[good_whi] - ydat[good_whi])
yerr_lhw_l = ABS(ydat_l[good_lhw] - ydat[good_lhw])
yerr_mxl_l = ABS(ydat_l[good_mxl] - ydat[good_mxl])
yerr_mxh_l = ABS(ydat_l[good_mxh] - ydat[good_mxh])
yerr_whi_h = ABS(ydat_h[good_whi] - ydat[good_whi])
yerr_lhw_h = ABS(ydat_h[good_lhw] - ydat[good_lhw])
yerr_mxl_h = ABS(ydat_h[good_mxl] - ydat[good_mxl])
yerr_mxh_h = ABS(ydat_h[good_mxh] - ydat[good_mxh])
yerr_whi   = [[yerr_whi_l],[yerr_whi_h]]
yerr_lhw   = [[yerr_lhw_l],[yerr_lhw_h]]
yerr_mxl   = [[yerr_mxl_l],[yerr_mxl_h]]
yerr_mxh   = [[yerr_mxh_l],[yerr_mxh_h]]


;; => Create structures for plots
tags       = ['WHI','LHW','MXL','MXH']
subtags    = ['X','Y','XERR','YERR']
strc_whi   = CREATE_STRUCT(subtags,xdat_whi,ydat_whi,xerr_whi,yerr_whi)
strc_lhw   = CREATE_STRUCT(subtags,xdat_lhw,ydat_lhw,xerr_lhw,yerr_lhw)
strc_mxl   = CREATE_STRUCT(subtags,xdat_mxl,ydat_mxl,xerr_mxl,yerr_mxl)
strc_mxh   = CREATE_STRUCT(subtags,xdat_mxh,ydat_mxh,xerr_mxh,yerr_mxh)
struc      = CREATE_STRUCT(tags,strc_whi,strc_lhw,strc_mxl,strc_mxh)


k          = 0L
;;  Initialize Plot
PLOT,struc.(k).X,struc.(k).Y,_EXTRA=pstr
  ;;  Overplot Data
  OPLOT,struc.(k).X,struc.(k).Y,PSYM=6,COLOR=250
  ;;  Overplot Errors
;  OPLOTERR,struc.(k).X,struc.(k).Y,struc.(k).YERR,6
  oploterrxy,struc.(k).X,struc.(k).Y,struc.(k).XERR,struc.(k).YERR,PSYM=6,COLOR=250













