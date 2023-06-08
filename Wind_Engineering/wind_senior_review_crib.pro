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
;;  Defined user symbol
xxo            = FINDGEN(17)*(!PI*2./16.)
USERSYM,0.27*COS(xxo),0.27*SIN(xxo),/FILL
;; Define X-Axis ticks for plots
xtn            = ['1994','1995','1996','1997','1998','1999','2000','2001','2002','2003',$
                  '2004','2005','2006','2007','2008','2009','2010','2011','2012','2013',$
                  '2014','2015','2016','2017','2018','2019','2020','2021','2022','2023']
xtn_dates      = xtn+'-01-01/00:00:00.000'
xtv            = time_double(xtn_dates)
xts            = N_ELEMENTS(xtv) - 1L
xttl           = 'Years'
;; Define X-Axis tick names for saved plots
xttl_ps        = '!C'+'Years'
xtn_ps         = ['1994','!C'+'1995','1996','!C'+'1997','1998','!C'+'1999',$
                  '2000','!C'+'2001','2002','!C'+'2003','2004','!C'+'2005',$
                  '2006','!C'+'2007','2008','!C'+'2009','2010','!C'+'2011',$
                  '2012','!C'+'2013','2014','!C'+'2015','2016','!C'+'2017',$
                  '2018','!C'+'2019','2020','!C'+'2021','2022','!C'+'2023']
ft_suffx       = 'Jan-'+xtn[0]+'_to_Jan-'+xtn[xts[0]]
yttl_sfx       = ' [Jan. '+xtn[0]+' to Jan. '+xtn[xts[0]]+']'
;; compile reading functions
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Wind_Engineering/read_wind_sr_data.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Wind_Engineering/read_wind_regbusvolt_daily.pro

;;  Define current 1st undervoltage loadshed setting
ls_volt_val    = 19.1d0             ;;  current loadshed [V] setting (i.e., if batteries get this low, SC completely restarts in safe mode)
ls_volt_str    = STRTRIM(STRING(ls_volt_val[0],FORMAT='(f20.1)'),2L)
;;  As of Jan. 17, 2020 the 2nd undervoltage loadshed is set to 18.2 V

;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
wind_scdat     = read_wind_sr_data()
wind_regbusv   = read_wind_regbusvolt_daily()

;;  Solar array and regulated bus currents have been filtered to remove shadow intervals
unix           = wind_scdat.UNIX              ;;  Unix timestamps
sa__avg        = wind_scdat.SOLARR_AVG        ;;  [Daily] Solar array current output [Avg., A]
sa__min        = wind_scdat.SOLARR_MIN        ;;  [Daily] Solar array current output [Min., A]
sa__max        = wind_scdat.SOLARR_MAX        ;;  [Daily] Solar array current output [Max., A]
rb__avg        = wind_scdat.REGBUS_AVG        ;;  [Daily] Regulated bus current output [Avg., A]
rb__min        = wind_scdat.REGBUS_MIN        ;;  [Daily] Regulated bus current output [Min., A]
rb__max        = wind_scdat.REGBUS_MAX        ;;  [Daily] Regulated bus current output [Max., A]
bv1_avg        = wind_scdat.BV1_AVG           ;;  [Daily] Battery-1 bias voltage output [Avg., V]
bv2_avg        = wind_scdat.BV2_AVG           ;;  [Daily] Battery-2 bias voltage output [Avg., V]
bv3_avg        = wind_scdat.BV3_AVG           ;;  [Daily] Battery-3 bias voltage output [Avg., V]
cc1_max        = wind_scdat.CC1_MAX           ;;  [Daily] Charge current on Battery-1 [Max., A]
cc2_max        = wind_scdat.CC2_MAX           ;;  [Daily] Charge current on Battery-2 [Max., A]
cc3_max        = wind_scdat.CC3_MAX           ;;  [Daily] Charge current on Battery-3 [Max., A]
bt1_avg        = wind_scdat.BT1_AVG           ;;  [Daily] Battery-1 temperature [Avg., deg. C]
bt2_avg        = wind_scdat.BT2_AVG           ;;  [Daily] Battery-2 temperature [Avg., deg. C]
bt3_avg        = wind_scdat.BT3_AVG           ;;  [Daily] Battery-3 temperature [Avg., deg. C]


;;  Define regulated bus voltage outputs
unix_v         = wind_regbusv.UNIX
rb_v_avg       = wind_regbusv.REGBUS_V_AVG    ;;  Regulated bus voltage output [Avg., V]
rb_v_min       = wind_regbusv.REGBUS_V_MIN    ;;  Regulated bus voltage output [Min., V]
rb_v_max       = wind_regbusv.REGBUS_V_MAX    ;;  Regulated bus voltage output [Max., V]
;;----------------------------------------------------------------------------------------
;;  Open window
;;----------------------------------------------------------------------------------------
windn          = 0L
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*85d-2
win_str        = {RETAIN:2,XSIZE:(wsz[0] < wsz[1]),YSIZE:(wsz[0] < wsz[1]),XPOS:20,YPOS:20}
lbw_window,WIND_N=windn[0],/NEW_W,/CLEAN,_EXTRA=win_str
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot solar array output
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; Define Y-Axis range
yra            = [5d0,19d0]           ;; range of currents
;; Define axes labels
yttl           = 'Current Output [Amps]'
pttl           = 'Wind Solar Array Output'+yttl_sfx[0]
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;; Define plot structure for PS plot
pstr_ps        = {YRANGE:yra,XTICKNAME:xtn_ps,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,$
                  XTITLE:xttl_ps,TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L, $
                  XTICKLEN:1.0,XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;  Plot data
symsz          = 2.00
WSET,0
WSHOW,0
  PLOT,unix,sa__min,_EXTRA=pstr
    ;; Min
    OPLOT,unix,sa__min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Max
    OPLOT,unix,sa__max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Max RBO [A]
    OPLOT,unix,rb__max,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Explain Max/Min
    XYOUTS,0.50,0.85,'Max = Non-Shadowed Output',COLOR=250,/NORMAL
    XYOUTS,0.50,0.80,'Min = Mag. Boom Shadowed Output',COLOR= 50,/NORMAL

;; Define output file name
symsz          = 1.25
fname          = 'Wind_Solar-Array-Current-Output_vs_Time_'+ft_suffx[0]
popen,fname[0],/LAND
  PLOT,unix,sa__min,_EXTRA=pstr_ps
    ;; Min
    OPLOT,unix,sa__min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Max
    OPLOT,unix,sa__max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.50,0.85,'Max = Non-Shadowed Output',COLOR=250,/NORMAL
    XYOUTS,0.50,0.80,'Min = Mag. Boom Shadowed Output',COLOR= 50,/NORMAL
pclose

;;----------------------------------------------------------------------------------------
;;  Open window
;;----------------------------------------------------------------------------------------
windn          = 1L
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*85d-2
win_str        = {RETAIN:2,XSIZE:(wsz[0] < wsz[1]),YSIZE:(wsz[0] < wsz[1]),XPOS:20,YPOS:20}
lbw_window,WIND_N=windn[0],/NEW_W,/CLEAN,_EXTRA=win_str
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot battery voltage output
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; Define Y-Axis range
yra            = [21d0,24d0]           ;; range of bias voltages
;; Define axes labels
yttl           = 'Battery Voltage Output [Volts]'
xttl           = 'Years'
pttl           = 'Wind Avg Battery Bias Voltage Output'+yttl_sfx[0]
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:6L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;; Define plot structure for PS plot
pstr_ps        = {YRANGE:yra,XTICKNAME:xtn_ps,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,$
                  XTITLE:xttl_ps,TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:6L, $
                  XTICKLEN:1.0,XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;  Plot data
symsz          = 2.00
WSET,1
WSHOW,1
  PLOT,unix,bv1_avg,_EXTRA=pstr
    ;; Battery 1
    OPLOT,unix,bv1_avg,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Battery 2
    OPLOT,unix,bv2_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Battery 3
    OPLOT,unix,bv3_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Output current load shed setting
    OPLOT,!X.CRANGE,[ls_volt_val[0],ls_volt_val[0]],LINESTYLE=2,COLOR=200
;;    OPLOT,!X.CRANGE,[21.1,21.1],LINESTYLE=2,COLOR=200
    XYOUTS,0.25,0.30,ls_volt_str[0]+' V = current load shed setting',COLOR=200,/NORMAL
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.50,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.50,0.80,'Battery 3',COLOR=250,/NORMAL

;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
;; Define output file name
symsz          = 1.25
fname          = 'Wind_Avg-Battery-Bias-Voltage-Output_vs_Time_'+ft_suffx[0]
popen,fname[0],/LAND
  PLOT,unix,bv1_avg,_EXTRA=pstr_ps
    ;; Battery 1
    OPLOT,unix,bv1_avg,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Battery 2
    OPLOT,unix,bv2_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Battery 3
    OPLOT,unix,bv3_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Output current load shed setting
    OPLOT,!X.CRANGE,[ls_volt_val[0],ls_volt_val[0]],LINESTYLE=2,COLOR=200
;;    OPLOT,!X.CRANGE,[21.1,21.1],LINESTYLE=2,COLOR=200
    XYOUTS,0.25,0.30,ls_volt_str[0]+' V = current load shed setting',COLOR=200,/NORMAL
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.50,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.50,0.80,'Battery 3',COLOR=250,/NORMAL
pclose

;;----------------------------------------------------------------------------------------
;;  Open window
;;----------------------------------------------------------------------------------------
windn          = 2L
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*85d-2
win_str        = {RETAIN:2,XSIZE:(wsz[0] < wsz[1]),YSIZE:(wsz[0] < wsz[1]),XPOS:20,YPOS:20}
lbw_window,WIND_N=windn[0],/NEW_W,/CLEAN,_EXTRA=win_str
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot regulated bus current output
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; Define Y-Axis range
yra            = [5d0,19d0]           ;; range of currents
;; Define axes labels
yttl           = 'Regulated Bus Current Output [Amps]'
xttl           = 'Years'
pttl           = 'Wind Regulated Bus Current Output'+yttl_sfx[0]
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;; Define plot structure for PS plot
pstr_ps        = {YRANGE:yra,XTICKNAME:xtn_ps,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,$
                  XTITLE:xttl_ps,TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L, $
                  XTICKLEN:1.0,XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;  Plot data
symsz          = 2.00
WSET,2
WSHOW,2
  PLOT,unix,rb__min,_EXTRA=pstr
    ;; Min
    OPLOT,unix,rb__min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Avg
    OPLOT,unix,rb__avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Max
    OPLOT,unix,rb__max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Min RBC = Transmitter Off',COLOR= 50,/NORMAL
    XYOUTS,0.50,0.85,'Avg Regulated Bus Current [RBC]',COLOR=150,/NORMAL
    XYOUTS,0.50,0.80,'Max RBC = Transmitter On',COLOR=250,/NORMAL

;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
;; Define output file name
symsz          = 1.25
fname          = 'Wind_Regulated-Bus-Current-Output_vs_Time_'+ft_suffx[0]
popen,fname[0],/LAND
  PLOT,unix,rb__min,_EXTRA=pstr_ps
    ;; Min
    OPLOT,unix,rb__min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Avg
    OPLOT,unix,rb__avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Max
    OPLOT,unix,rb__max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Min RBC = Transmitter Off',COLOR= 50,/NORMAL
    XYOUTS,0.50,0.85,'Avg Regulated Bus Current [RBC]',COLOR=150,/NORMAL
    XYOUTS,0.50,0.80,'Max RBC = Transmitter On',COLOR=250,/NORMAL
pclose

;;----------------------------------------------------------------------------------------
;;  Open window
;;----------------------------------------------------------------------------------------
windn          = 3L
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*85d-2
win_str        = {RETAIN:2,XSIZE:(wsz[0] < wsz[1]),YSIZE:(wsz[0] < wsz[1]),XPOS:20,YPOS:20}
lbw_window,WIND_N=windn[0],/NEW_W,/CLEAN,_EXTRA=win_str
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot avg battery temperature
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; Define Y-Axis range
yra            = [0d0,18d0]           ;; range of currents
;; Define axes labels
yttl           = 'Battery Temperature [!Uo!N'+'C]'
xttl           = 'Years'
pttl           = 'Wind Avg Battery Temperature'+yttl_sfx[0]
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:9L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;; Define plot structure for PS plot
pstr_ps        = {YRANGE:yra,XTICKNAME:xtn_ps,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,$
                  XTITLE:xttl_ps,TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:9L, $
                  XTICKLEN:1.0,XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;  Plot data
symsz          = 2.00
WSET,3
WSHOW,3
  PLOT,unix,bt1_avg,_EXTRA=pstr
    ;; Battery 1 [Max Temp]
    OPLOT,unix,bt1_avg,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Battery 2 [Max Temp]
    OPLOT,unix,bt2_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Battery 3 [Max Temp]
    OPLOT,unix,bt3_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.25,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.25,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.25,0.80,'Battery 3',COLOR=250,/NORMAL

;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
;; Define output file name
symsz          = 1.25
fname          = 'Wind_Avg-Battery-Temperature_vs_Time_'+ft_suffx[0]
popen,fname[0],/LAND
  PLOT,unix,bt1_avg,_EXTRA=pstr_ps
    ;; Battery 1 [Max Temp]
    OPLOT,unix,bt1_avg,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Battery 2 [Max Temp]
    OPLOT,unix,bt2_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Battery 3 [Max Temp]
    OPLOT,unix,bt3_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.25,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.25,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.25,0.80,'Battery 3',COLOR=250,/NORMAL
pclose



;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Find trend lines
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Smooth over ~1 year time range
wd             = 365L
sa__min_sm     = SMOOTH(sa__min,wd[0],/NAN,/EDGE_TRUNCATE)  ;;  Smoothed [Daily] Solar array current output [Min., A]
sa__avg_sm     = SMOOTH(sa__avg,wd[0],/NAN,/EDGE_TRUNCATE)  ;;  Smoothed [Daily] Solar array current output [Avg., A]
sa__max_sm     = SMOOTH(sa__max,wd[0],/NAN,/EDGE_TRUNCATE)  ;;  Smoothed [Daily] Solar array current output [Max., A]
bv1_avg_sm     = SMOOTH(bv1_avg,wd[0],/NAN,/EDGE_TRUNCATE)  ;;  Smoothed [Daily] Battery-1 bias voltage output [Avg., V]
bv2_avg_sm     = SMOOTH(bv2_avg,wd[0],/NAN,/EDGE_TRUNCATE)  ;;  Smoothed [Daily] Battery-2 bias voltage output [Avg., V]
bv3_avg_sm     = SMOOTH(bv3_avg,wd[0],/NAN,/EDGE_TRUNCATE)  ;;  Smoothed [Daily] Battery-3 bias voltage output [Avg., V]
bt1_avg_sm     = SMOOTH(bt1_avg,wd[0],/NAN,/EDGE_TRUNCATE)  ;;  Smoothed [Daily] Battery-1 temperature [Avg., deg. C]
bt2_avg_sm     = SMOOTH(bt2_avg,wd[0],/NAN,/EDGE_TRUNCATE)  ;;  Smoothed [Daily] Battery-2 temperature [Avg., deg. C]
bt3_avg_sm     = SMOOTH(bt3_avg,wd[0],/NAN,/EDGE_TRUNCATE)  ;;  Smoothed [Daily] Battery-3 temperature [Avg., deg. C]

;;  Trends [use] (*** 2020 Senior Review ***)
;;    Solar Arrays --> after Jan. 1, 2005 to Jan. 1, 2020
;;    Battery Temp --> after Jul. 1, 2017 to Jan. 1, 2020
;;    Battery Volt --> after Jan. 1, 2013 to Jan. 1, 2020 [Battery 1]
;;    Battery Volt --> after Jan. 1, 2013 to Jan. 1, 2020 [Battery 2]
;;    Battery Volt --> after Jan. 1, 2013 to Jan. 1, 2020 [Battery 3]
;;
;;  Trends [use] (*** 2023 Senior Review ***)
;;    Solar Arrays --> after Jan. 1, 2016 to Apr. 1, 2023
;;    Battery Temp --> after Jul. 1, 2018 to Apr. 1, 2023
;;    Battery Volt --> after Aug. 1, 2018 to Apr. 1, 2023 [Battery 1]
;;    Battery Volt --> after Jun. 1, 2018 to Apr. 1, 2023 [Battery 2]
;;    Battery Volt --> after Jun. 1, 2018 to Apr. 1, 2023 [Battery 3]

zero_t         = '00:00:00.000'
tyear_max      = '2023'
tra__sa        = time_double(['2016-01',tyear_max[0]+'-04']+'-01/'+zero_t[0])
tra_bt1        = time_double(['2018-01',tyear_max[0]+'-04']+'-01/'+zero_t[0])
tra_bv1        = time_double(['2018-08',tyear_max[0]+'-04']+'-01/'+zero_t[0])
tra_bv2        = time_double(['2018-07',tyear_max[0]+'-04']+'-01/'+zero_t[0])
tra_bv3        = time_double(['2018-07',tyear_max[0]+'-04']+'-01/'+zero_t[0])
good__sa       = WHERE(unix GE tra__sa[0] AND unix LE tra__sa[1],gd__sa)
good_bv1       = WHERE(unix GE tra_bv1[0] AND unix LE tra_bv1[1],gd_bv1)
good_bv2       = WHERE(unix GE tra_bv2[0] AND unix LE tra_bv2[1],gd_bv2)
good_bv3       = WHERE(unix GE tra_bv3[0] AND unix LE tra_bv3[1],gd_bv3)
good_bt1       = WHERE(unix GE tra_bt1[0] AND unix LE tra_bt1[1],gd_bt1)
good_bt2       = WHERE(unix GE tra_bt1[0] AND unix LE tra_bt1[1],gd_bt2)
good_bt3       = WHERE(unix GE tra_bt1[0] AND unix LE tra_bt1[1],gd_bt3)

tra_rbc        = time_double(['2016-01','2023-04']+'-01/'+zero_t[0])
good_rbc       = WHERE(unix GE tra_rbc[0] AND unix LE tra_rbc[1],gd_rbc)
PRINT,';;', MIN(rb__max[good_rbc],/NAN), MAX(rb__max[good_rbc],/NAN), MEAN(rb__max[good_rbc],/NAN), MEDIAN(rb__max[good_rbc])
;;  (*** 2020 Senior Review ***)
;;       9.5413000       10.105800       9.8773744       9.8800000
;;  (*** 2023 Senior Review ***)
;;       7.5092000       28.507800       10.005189       9.8800000

rbc_max_v0     = MEDIAN(rb__max[good_rbc])
avg_rbc_xxx    = time_double(['1994','2150']+'-01-01/'+zero_t[0])
avg_rbc_yyy    = [1d0,1d0]*MEAN(rb__max[good_rbc],/NAN)

med_rbc_xxx    = avg_rbc_xxx
med_rbc_yyy    = [1d0,1d0]*MEDIAN(rb__max[good_rbc])

;;  *** Old ***
;;  Trends [1st guess]
;;    Solar Arrays --> after Jan. 1, 2005 to Mar. 1, 2014
;;    Battery Temp --> after Sep. 1, 2012
;;    Battery Volt --> after Jan. 1, 2005
;;    Battery Volt --> after Jan. 1, 2013 to Jan. 1, 2017 [Battery 1]
;;    Battery Volt --> after Jan. 1, 2005 to Jan. 1, 2017 [Battery 2]
;;    Battery Volt --> after Jan. 1, 2008 to Jan. 1, 2017 [Battery 3]
;tra_bv1        = time_double(['2013',tyear_max[0]]+'-01-01/'+zero_t[0])
;tra_bv2        = time_double(['2005',tyear_max[0]]+'-01-01/'+zero_t[0])
;tra_bv3        = time_double(['2008',tyear_max[0]]+'-01-01/'+zero_t[0])
;;  *** Old ***

;;----------------------------------------------------------------------------------------
;;  Calculate linear fits [Y = A + B X]
;;----------------------------------------------------------------------------------------
;;  Create dummy abscissa values for each
nx             = 100L
dx             = DINDGEN(nx[0])
xr0            = time_double(['2005','2150']+'-01-01/'+zero_t[0])
facs           = [(xr0[1] - xr0[0])/(nx[0] - 1L),xr0[0]]
dumbx          = dx*facs[0] + facs[1]
;;  Linear fit [Y = A + B X] to Solar Array trend
xx1            = unix[good__sa]
xx2            = unix[good__sa]
xx3            = unix[good__sa]
yy1            = sa__min_sm[good__sa]
yy2            = sa__avg_sm[good__sa]
yy3            = sa__max_sm[good__sa]
fit__sa_sm_1   = LADFIT(xx1,yy1)
fit__sa_sm_2   = LADFIT(xx2,yy2)
fit__sa_sm_3   = LADFIT(xx3,yy3)
;;  Linear fit [Y = A + B X] to Battery Bias Voltages trends
xx1            = unix[good_bv1]
xx2            = unix[good_bv2]
xx3            = unix[good_bv3]
yy1            = bv1_avg_sm[good_bv1]
yy2            = bv2_avg_sm[good_bv2]
yy3            = bv3_avg_sm[good_bv3]
fit_bv1_sm_1   = LADFIT(xx1,yy1)
fit_bv2_sm_2   = LADFIT(xx2,yy2)
fit_bv3_sm_3   = LADFIT(xx3,yy3)
;;  Linear fit [Y = A + B X] to Battery Bias Temps trends
xx1            = unix[good_bt1]
xx2            = unix[good_bt2]
xx3            = unix[good_bt3]
yy1            = bt1_avg_sm[good_bt1]
yy2            = bt2_avg_sm[good_bt2]
yy3            = bt3_avg_sm[good_bt3]
fit_bt1_sm_1   = LADFIT(xx1,yy1)
fit_bt2_sm_2   = LADFIT(xx2,yy2)
fit_bt3_sm_3   = LADFIT(xx3,yy3)
;;  Create dummy fit lines for each
dumb__sa_sm_1  = fit__sa_sm_1[0] + fit__sa_sm_1[1]*dumbx
dumb__sa_sm_2  = fit__sa_sm_2[0] + fit__sa_sm_2[1]*dumbx
dumb__sa_sm_3  = fit__sa_sm_3[0] + fit__sa_sm_3[1]*dumbx
dumb_bv1_sm_1  = fit_bv1_sm_1[0] + fit_bv1_sm_1[1]*dumbx
dumb_bv2_sm_2  = fit_bv2_sm_2[0] + fit_bv2_sm_2[1]*dumbx
dumb_bv3_sm_3  = fit_bv3_sm_3[0] + fit_bv3_sm_3[1]*dumbx
dumb_bt1_sm_1  = fit_bt1_sm_1[0] + fit_bt1_sm_1[1]*dumbx
dumb_bt2_sm_2  = fit_bt2_sm_2[0] + fit_bt2_sm_2[1]*dumbx
dumb_bt3_sm_3  = fit_bt3_sm_3[0] + fit_bt3_sm_3[1]*dumbx
;;----------------------------------------------------------------------------------------
;;  Calculate intersection of linear fits with some critical value
;;----------------------------------------------------------------------------------------
xx1            = dumbx
xx2            = dumbx
sa_ints_val    = rbc_max_v0[0]      ;;  10 A   = Max regulated bus current [transmitter and heater on]
;;ls_volt_val    = 21.1d0             ;;  21.1 V = current load shed setting (i.e., if batteries get this low, SC completely restarts in safe mode)
bt_cent_val    = 17d0               ;;  17 C   = temperature [degrees C] that is probably "bad" for the batters (VT levels have been changed prior to reaching 16 C in past)
sa_ints_yvs    = REPLICATE(sa_ints_val[0],nx[0])
ls_volt_yvs    = REPLICATE(ls_volt_val[0],nx[0])
bt_cent_yvs    = REPLICATE(bt_cent_val[0],nx[0])
;;------------------------------------
;;  Find intersections
;;------------------------------------
;;  Solar Arrays
yy1            = sa_ints_yvs
yy2            = dumb__sa_sm_1
find_intersect_2_curves,xx1,yy1,xx2,yy2,XY=xy_int__sa_sm_1
yy2            = dumb__sa_sm_2
find_intersect_2_curves,xx1,yy1,xx2,yy2,XY=xy_int__sa_sm_2
yy2            = dumb__sa_sm_3
find_intersect_2_curves,xx1,yy1,xx2,yy2,XY=xy_int__sa_sm_3
PRINT,';;  ', time_string([xy_int__sa_sm_1[0],xy_int__sa_sm_2[0],xy_int__sa_sm_3[0]],PREC=3)
;;  *** Old ***   2018-05-29/18:46:21.082 2042-09-06/08:42:29.514 2055-06-25/09:38:26.444
;;  *** Old ***   2017-12-06/21:04:35.645 2041-12-02/03:03:51.806 2059-07-07/16:30:55.441
;;  *** Old ***   2017-11-26/15:21:11.407 2044-01-30/16:33:18.414 2058-08-26/19:35:49.868
;;   2014-07-17/17:11:24.351 2059-03-16/15:00:15.572 2088-12-07/00:04:13.123

;;  Battery Voltages
yy1            = ls_volt_yvs
yy2            = dumb_bv1_sm_1
find_intersect_2_curves,xx1,yy1,xx2,yy2,XY=xy_int_bv1_sm_1
yy2            = dumb_bv2_sm_2
find_intersect_2_curves,xx1,yy1,xx2,yy2,XY=xy_int_bv2_sm_2
yy2            = dumb_bv3_sm_3
find_intersect_2_curves,xx1,yy1,xx2,yy2,XY=xy_int_bv3_sm_3
PRINT,';;  ', time_string([xy_int_bv1_sm_1[0],xy_int_bv2_sm_2[0],xy_int_bv3_sm_3[0]],PREC=3)
;;  *** Old ***   2025-04-05/19:53:32.713 2025-06-02/14:39:00.790 2020-09-18/00:23:03.579
;;  *** Old ***   2027-04-26/02:46:17.187 2025-11-02/14:53:47.881 2021-12-18/09:21:41.164
;;  *** Old ***   2030-04-03/16:40:45.351 2029-07-11/21:00:00.564 2029-01-17/14:35:13.804
;;  *** Old ***   2056-08-26/03:10:09.182 2061-04-27/07:49:10.824 2064-09-06/09:43:15.082
;;   2078-01-13/10:06:09.585 2112-10-25/07:28:35.624 2096-12-31/22:03:30.196

;;  Battery Temperatures
yy1            = bt_cent_yvs
yy2            = dumb_bt1_sm_1
find_intersect_2_curves,xx1,yy1,xx2,yy2,XY=xy_int_bt1_sm_1
yy2            = dumb_bt2_sm_2
find_intersect_2_curves,xx1,yy1,xx2,yy2,XY=xy_int_bt2_sm_2
yy2            = dumb_bt3_sm_3
find_intersect_2_curves,xx1,yy1,xx2,yy2,XY=xy_int_bt3_sm_3
PRINT,';;  ', time_string([xy_int_bt1_sm_1[0],xy_int_bt2_sm_2[0],xy_int_bt3_sm_3[0]],PREC=3)
;;  *** Old ***   2017-04-21/00:39:01.349 2017-04-13/20:16:53.985 2015-07-09/21:14:31.626
;;  *** Old ***   2023-02-07/00:22:24.315 2022-02-20/03:27:05.576 2020-11-01/10:26:32.179
;;  *** Old ***   2100-01-01/00:00:00     2100-01-01/00:00:00     2100-01-01/00:00:00
;;   1970-01-01/00:00:00     1970-01-01/00:00:00     1970-01-01/00:00:00    




;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot Extrapolation Results
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; Define extended X-Axis ticks for plots
xtn_exw        = ['1994','1996','1998','2000','2002','2004','2006','2008','2010','2012',$
                  '2014','2016','2018','2020','2022','2024','2026','2028','2030','2032',$
                  '2034','2036','2038','2040','2042','2044','2046','2048','2050']
xtn_dates_ex   = xtn_exw+'-01-01/00:00:00.000'
xtv_ex         = time_double(xtn_dates_ex)
xts_ex         = N_ELEMENTS(xtn_exw) - 1L
ft_suffx       = 'Jan-'+xtn_exw[0]+'_to_Jan-'+xtn_exw[xts_ex[0]]+'_with_Fits-to-Trends'
yttl_sfx       = ' [Jan. '+xtn_exw[0]+' to Jan. '+xtn_exw[xts_ex[0]]+']'
;; Define Y-Axis range
yra            = [5d0,19d0]           ;; range of currents
;; Define axes labels
yttl           = 'Current Output [Amps]'
pttl           = 'Wind Solar Array Output'+yttl_sfx[0]
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn_exw,XTICKV:xtv_ex,XTICKS:xts_ex,YTITLE:yttl,$
                  XTITLE:xttl,TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L,       $
                  XTICKLEN:1.0,XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;----------------------------------------------------------------------------------------
;;  Plot Solar Array Extrapolation
;;----------------------------------------------------------------------------------------
symsz          = 2.00
thck           = 2.0
WSET,0
WSHOW,0
  PLOT,unix,sa__min,_EXTRA=pstr
    ;;  Current Avg. of Max Regulated Bus Current [A]
    OPLOT,avg_rbc_xxx,avg_rbc_yyy,LINESTYLE=0,THICK=thck[0],COLOR=150
    ;;  Solar Array Min [A]
    OPLOT,unix,sa__min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;;  Solar Array Max [A]
    OPLOT,unix,sa__max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;;  Fit to Smoothed Solar Array Min and Max [A]
    OPLOT,dumbx,dumb__sa_sm_1,LINESTYLE=0,THICK=thck[0],COLOR= 30
    OPLOT,dumbx,dumb__sa_sm_3,LINESTYLE=0,THICK=thck[0],COLOR=200
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Max = Non-Shadowed Output',COLOR=250,/NORMAL
    XYOUTS,0.50,0.85,'Min = Mag. Boom Shadowed Output',COLOR= 50,/NORMAL
    ;; Explain lines
    XYOUTS,0.50,0.80,'Smoothed [Yearly Avg.] Max',COLOR=200,/NORMAL
    XYOUTS,0.50,0.75,'Smoothed [Yearly Avg.] Min',COLOR=100,/NORMAL
;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
symsz          = 1.25
thck           = 2.0
fname          = 'Wind_Solar-Array-Current-Output_vs_Time_'+ft_suffx[0]+'_with_fit_extrapolations'
popen,fname[0],/LAND
  PLOT,unix,sa__min,_EXTRA=pstr
    ;;  Current Avg. of Max Regulated Bus Current [A]
    OPLOT,avg_rbc_xxx,avg_rbc_yyy,LINESTYLE=0,THICK=thck[0],COLOR=150
    ;;  Solar Array Min [A]
    OPLOT,unix,sa__min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;;  Solar Array Max [A]
    OPLOT,unix,sa__max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;;  Fit to Smoothed Solar Array Min and Max [A]
    OPLOT,dumbx,dumb__sa_sm_1,LINESTYLE=0,THICK=thck[0],COLOR= 30
    OPLOT,dumbx,dumb__sa_sm_3,LINESTYLE=0,THICK=thck[0],COLOR=200
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Max = Non-Shadowed Output',COLOR=250,/NORMAL
    XYOUTS,0.50,0.85,'Min = Mag. Boom Shadowed Output',COLOR= 50,/NORMAL
    ;; Explain lines
    XYOUTS,0.50,0.80,'Smoothed [Yearly Avg.] Max',COLOR=200,/NORMAL
    XYOUTS,0.50,0.75,'Smoothed [Yearly Avg.] Min',COLOR=100,/NORMAL
pclose

;;----------------------------------------------------------------------------------------
;;  Plot Battery Voltage Extrapolation
;;----------------------------------------------------------------------------------------
;; Define Y-Axis range
yra            = [18d0,24d0]           ;; range of bias voltages
;; Define axes labels
yttl           = 'Battery Voltage Output [Volts]'
xttl           = 'Years'
pttl           = 'Wind Avg Battery Bias Voltage Output'+yttl_sfx[0]
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn_exw,XTICKV:xtv_ex,XTICKS:xts_ex,YTITLE:yttl,$
                  XTITLE:xttl,TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:10,YTICKS:6L,       $
                  XTICKLEN:1.0,XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;  Plot data
symsz          = 2.00
thck           = 2.0
WSET,1
WSHOW,1
  PLOT,unix,bv1_avg,_EXTRA=pstr
    ;; Battery 1
    OPLOT,unix,bv1_avg,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Battery 2
    OPLOT,unix,bv2_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Battery 3
    OPLOT,unix,bv3_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;;  Fit to Smoothed Battery Bias Voltages [V]
    OPLOT,dumbx,dumb_bv1_sm_1,LINESTYLE=0,THICK=thck[0],COLOR=100
    OPLOT,dumbx,dumb_bv2_sm_2,LINESTYLE=0,THICK=thck[0],COLOR= 30
    OPLOT,dumbx,dumb_bv3_sm_3,LINESTYLE=0,THICK=thck[0],COLOR=200
    ;; Output current load shed setting
    OPLOT,!X.CRANGE,[ls_volt_val[0],ls_volt_val[0]],LINESTYLE=2,COLOR=200
;;    OPLOT,!X.CRANGE,[21.1,21.1],LINESTYLE=2,COLOR=200
    XYOUTS,0.25,0.30,ls_volt_str[0]+' V = current load shed setting',COLOR=200,/NORMAL
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.50,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.50,0.80,'Battery 3',COLOR=250,/NORMAL

;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
symsz          = 1.25
thck           = 2.0
fname          = 'Wind_Avg-Battery-Bias-Voltage-Output_vs_Time_'+ft_suffx[0]+'_with_fit_extrapolations'
popen,fname[0],/LAND
  PLOT,unix,bv1_avg,_EXTRA=pstr
    ;; Battery 1
    OPLOT,unix,bv1_avg,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Battery 2
    OPLOT,unix,bv2_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Battery 3
    OPLOT,unix,bv3_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;;  Fit to Smoothed Battery Bias Voltages [V]
    OPLOT,dumbx,dumb_bv1_sm_1,LINESTYLE=0,THICK=thck[0],COLOR=100
    OPLOT,dumbx,dumb_bv2_sm_2,LINESTYLE=0,THICK=thck[0],COLOR= 30
    OPLOT,dumbx,dumb_bv3_sm_3,LINESTYLE=0,THICK=thck[0],COLOR=200
    ;; Output current load shed setting
    OPLOT,!X.CRANGE,[ls_volt_val[0],ls_volt_val[0]],LINESTYLE=2,COLOR=200
;;    OPLOT,!X.CRANGE,[21.1,21.1],LINESTYLE=2,COLOR=200
    XYOUTS,0.25,0.30,ls_volt_str[0]+' V = current load shed setting',COLOR=200,/NORMAL
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.50,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.50,0.80,'Battery 3',COLOR=250,/NORMAL
pclose

;;----------------------------------------------------------------------------------------
;;  Plot Battery Temperature Extrapolation
;;----------------------------------------------------------------------------------------
;; Define Y-Axis range
yra            = [0d0,18d0]           ;; range of currents
;; Define axes labels
yttl           = 'Battery Temperature [!Uo!N'+'C]'
xttl           = 'Years'
pttl           = 'Wind Avg Battery Temperature'+yttl_sfx[0]
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn_exw,XTICKV:xtv_ex,XTICKS:xts_ex,YTITLE:yttl,$
                  XTITLE:xttl,TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L,       $
                  XTICKLEN:1.0,XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;  Plot data
symsz          = 2.00
WSET,2
WSHOW,2
  PLOT,unix,bt1_avg,_EXTRA=pstr
    ;;  Output assumed "bad" temperature for batteries
    OPLOT,avg_rbc_xxx,[1d0,1d0]*bt_cent_val[0],LINESTYLE=0,THICK=thck[0],COLOR=175
    ;; Battery 1 [Max Temp]
    OPLOT,unix,bt1_avg,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Battery 2 [Max Temp]
    OPLOT,unix,bt2_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Battery 3 [Max Temp]
    OPLOT,unix,bt3_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;;  Fit to Smoothed Battery Temps [deg C]
    OPLOT,dumbx,dumb_bt1_sm_1,LINESTYLE=0,THICK=thck[0],COLOR=100
    OPLOT,dumbx,dumb_bt2_sm_2,LINESTYLE=0,THICK=thck[0],COLOR= 30
    OPLOT,dumbx,dumb_bt3_sm_3,LINESTYLE=0,THICK=thck[0],COLOR=200
    ;; Explain Max/Min
    XYOUTS,0.25,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.25,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.25,0.80,'Battery 3',COLOR=250,/NORMAL

;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
symsz          = 1.25
thck           = 2.0
fname          = 'Wind_Avg-Battery-Temperature_vs_Time_'+ft_suffx[0]+'_with_fit_extrapolations'
popen,fname[0],/LAND
  PLOT,unix,bt1_avg,_EXTRA=pstr
    ;;  Output assumed "bad" temperature for batteries
    OPLOT,avg_rbc_xxx,[1d0,1d0]*bt_cent_val[0],LINESTYLE=0,THICK=thck[0],COLOR=175
    ;; Battery 1 [Max Temp]
    OPLOT,unix,bt1_avg,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Battery 2 [Max Temp]
    OPLOT,unix,bt2_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Battery 3 [Max Temp]
    OPLOT,unix,bt3_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;;  Fit to Smoothed Battery Temps [deg C]
    OPLOT,dumbx,dumb_bt1_sm_1,LINESTYLE=0,THICK=thck[0],COLOR=100
    OPLOT,dumbx,dumb_bt2_sm_2,LINESTYLE=0,THICK=thck[0],COLOR= 30
    OPLOT,dumbx,dumb_bt3_sm_3,LINESTYLE=0,THICK=thck[0],COLOR=200
    ;; Explain Max/Min
    XYOUTS,0.25,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.25,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.25,0.80,'Battery 3',COLOR=250,/NORMAL
pclose





;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Extend time range for solar array and battery voltages
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
dt_1yr         = 864d2*365d0                                     ;;  seconds in Julian year with 365 days
t_suffx0       = '-01-01/'+zero_t[0]
yr_ran         = [1994L,2060L]
xran           = time_double(STRING(yr_ran,FORMAT='(I4.4)')+t_suffx0[0])
xtvo           = xran[0]
nyr            = (yr_ran[1] - yr_ran[0]) + 1L
yrs_all        = LINDGEN(nyr[0]) + yr_ran[0]
yrs_all_str    = STRING(yrs_all,FORMAT='(I4.4)')
yrs_all_scp    = yrs_all_str
;; Define extended X-Axis ticks for plots [1 tick every 2 years]
xtn_exv        = yrs_all_str
ft_suffx       = 'Jan-'+xtn_exv[0]+'_to_Jan-'+xtn_exv[nyr[0] - 1L]+'_with_Fits-to-Trends'
yttl_sfx       = ' [Jan. '+xtn_exv[0]+' to Jan. '+xtn_exv[nyr[0] - 1L]+']'
xtn_ex         = yrs_all_str[0L:(nyr[0] - 1L):2L]
xtn_dates_ex   = xtn_ex+'-01-01/00:00:00.000'
xtv_ex         = time_double(xtn_dates_ex)
xts_ex         = N_ELEMENTS(xtv_ex) - 1L
;;  For PS output, put every-other tick mark one line below the normal
xtn_ex_ps      = xtn_ex
xtn_ex_ps[0L:xts_ex[0]:2L] = '!C'+xtn_ex_ps[0L:xts_ex[0]:2L]

;; Define Y-Axis range
yra            = [5d0,19d0]           ;; range of currents
;; Define axes labels
yttl           = 'Current Output [Amps]'
pttl           = 'Wind Solar Array Output'+yttl_sfx[0]
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn_ex,XTICKV:xtv_ex,XTICKS:xts_ex,YTITLE:yttl,$
                  XTITLE:xttl,TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L,       $
                  XTICKLEN:1.0,XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
pstr_ps        = {YRANGE:yra,XTICKNAME:xtn_ex_ps,XTICKV:xtv_ex,XTICKS:xts_ex,         $
                  YTITLE:yttl,XTITLE:xttl_ps,TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,  $
                  YTICKS:7L,XTICKLEN:1.0,XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;  Plot data
symsz          = 2.00
thck           = 2.0
WSET,0
WSHOW,0
  PLOT,unix,sa__min,_EXTRA=pstr
    ;;  Current Avg. of Max Regulated Bus Current [A]
    OPLOT,avg_rbc_xxx,avg_rbc_yyy,LINESTYLE=0,THICK=thck[0],COLOR=150
    ;;  Solar Array Min [A]
    OPLOT,unix,sa__min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;;  Solar Array Max [A]
    OPLOT,unix,sa__max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;;  Fit to Smoothed Solar Array Min and Max [A]
    OPLOT,dumbx,dumb__sa_sm_1,LINESTYLE=0,THICK=thck[0],COLOR= 30
    OPLOT,dumbx,dumb__sa_sm_3,LINESTYLE=0,THICK=thck[0],COLOR=200
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Max = Non-Shadowed Output',COLOR=250,/NORMAL
    XYOUTS,0.50,0.85,'Min = Mag. Boom Shadowed Output',COLOR= 50,/NORMAL
    ;; Explain lines
    XYOUTS,0.50,0.80,'Smoothed [Yearly Avg.] Max',COLOR=200,/NORMAL
    XYOUTS,0.50,0.75,'Smoothed [Yearly Avg.] Min',COLOR=100,/NORMAL
;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
symsz          = 1.25
thck           = 2.0
fname          = 'Wind_Solar-Array-Current-Output_vs_Time_'+ft_suffx[0]+'_with_fit_extrapolations_long'
popen,fname[0],/LAND
  PLOT,unix,sa__min,_EXTRA=pstr_ps
    ;;  Current Avg. of Max Regulated Bus Current [A]
    OPLOT,avg_rbc_xxx,avg_rbc_yyy,LINESTYLE=0,THICK=thck[0],COLOR=150
    ;;  Solar Array Min [A]
    OPLOT,unix,sa__min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;;  Solar Array Max [A]
    OPLOT,unix,sa__max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;;  Fit to Smoothed Solar Array Min and Max [A]
    OPLOT,dumbx,dumb__sa_sm_1,LINESTYLE=0,THICK=thck[0],COLOR= 30
    OPLOT,dumbx,dumb__sa_sm_3,LINESTYLE=0,THICK=thck[0],COLOR=200
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Max = Non-Shadowed Output',COLOR=250,/NORMAL
    XYOUTS,0.50,0.85,'Min = Mag. Boom Shadowed Output',COLOR= 50,/NORMAL
    ;; Explain lines
    XYOUTS,0.50,0.80,'Smoothed [Yearly Avg.] Max',COLOR=200,/NORMAL
    XYOUTS,0.50,0.75,'Smoothed [Yearly Avg.] Min',COLOR=100,/NORMAL
pclose


;; Define Y-Axis range
yra            = [19d0,24d0]           ;; range of bias voltages
;; Define axes labels
yttl           = 'Battery Voltage Output [Volts]'
xttl           = 'Years'
pttl           = 'Wind Avg Battery Bias Voltage Output'+yttl_sfx[0]
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn_ex,XTICKV:xtv_ex,XTICKS:xts_ex,YTITLE:yttl,$
                  XTITLE:xttl,TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:10L,$
                  XTICKLEN:1.0,XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
pstr_ps        = {YRANGE:yra,XTICKNAME:xtn_ex_ps,XTICKV:xtv_ex,XTICKS:xts_ex,         $
                  YTITLE:yttl,XTITLE:xttl_ps,TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,  $
                  YTICKS:10L,XTICKLEN:1.0,XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;  Plot data
symsz          = 2.00
WSET,1
WSHOW,1
  PLOT,unix,bv1_avg,_EXTRA=pstr
    ;; Battery 1
    OPLOT,unix,bv1_avg,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Battery 2
    OPLOT,unix,bv2_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Battery 3
    OPLOT,unix,bv3_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;;  Fit to Smoothed Battery Bias Voltages [V]
    OPLOT,dumbx,dumb_bv1_sm_1,LINESTYLE=0,THICK=thck[0],COLOR=100
    OPLOT,dumbx,dumb_bv2_sm_2,LINESTYLE=0,THICK=thck[0],COLOR= 30
    OPLOT,dumbx,dumb_bv3_sm_3,LINESTYLE=0,THICK=thck[0],COLOR=200
    ;; Output current load shed setting
    OPLOT,!X.CRANGE,[ls_volt_val[0],ls_volt_val[0]],LINESTYLE=2,COLOR=200
;;    OPLOT,!X.CRANGE,[21.1,21.1],LINESTYLE=2,COLOR=200
    XYOUTS,0.25,0.30,ls_volt_str[0]+' V = current load shed setting',COLOR=200,/NORMAL
    ;; Explain Max/Min
    XYOUTS,0.65,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.65,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.65,0.80,'Battery 3',COLOR=250,/NORMAL

;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
symsz          = 1.25
thck           = 2.0
fname          = 'Wind_Avg-Battery-Bias-Voltage-Output_vs_Time_'+ft_suffx[0]+'_with_fit_extrapolations_long'
popen,fname[0],/LAND
  PLOT,unix,bv1_avg,_EXTRA=pstr_ps
    ;; Battery 1
    OPLOT,unix,bv1_avg,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Battery 2
    OPLOT,unix,bv2_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Battery 3
    OPLOT,unix,bv3_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;;  Fit to Smoothed Battery Bias Voltages [V]
    OPLOT,dumbx,dumb_bv1_sm_1,LINESTYLE=0,THICK=thck[0],COLOR=100
    OPLOT,dumbx,dumb_bv2_sm_2,LINESTYLE=0,THICK=thck[0],COLOR= 30
    OPLOT,dumbx,dumb_bv3_sm_3,LINESTYLE=0,THICK=thck[0],COLOR=200
    ;; Output current load shed setting
    OPLOT,!X.CRANGE,[ls_volt_val[0],ls_volt_val[0]],LINESTYLE=2,COLOR=200
;;    OPLOT,!X.CRANGE,[21.1,21.1],LINESTYLE=2,COLOR=200
    XYOUTS,0.25,0.30,ls_volt_str[0]+' V = current load shed setting',COLOR=200,/NORMAL
    ;; Explain Max/Min
    XYOUTS,0.65,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.65,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.65,0.80,'Battery 3',COLOR=250,/NORMAL
pclose









;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------


del_5yr        = 5L
yrs_all_scp[0L:(nyr[0] - 1L):del_5yr[0]] = ''
;; Define extended X-Axis ticks for plots [1 tick every 2 years]
;;  Use every year for TICKV, but only provide string value every 5(?) years
xtn_exv        = yrs_all_str
xtn_dates_ex   = xtn_exv+'-01-01/00:00:00.000'
xtv_ex         = time_double(xtn_dates_ex)
xts_ex         = N_ELEMENTS(xtv_ex) - 1L
xtn_ex         = yrs_all_scp

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot solar array output
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
WINDOW,0,RETAIN=2,XSIZE=1200,YSIZE=775

;; Define Y-Axis range
yra            = [5d0,19d0]           ;; range of currents
;yra            = [8d0,18d0]           ;; range of currents
;; Define axes labels
yttl           = 'Current Output [Amps]'
xttl           = 'Years'
pttl           = 'Wind Solar Array Output'
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
;                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:10L,XTICKLEN:1.0,$
;                  XGRIDSTYLE:1}
;;  Plot data
symsz          = 2.00
WSET,0
  PLOT,unix,sa__min,_EXTRA=pstr
    ;; Min
    OPLOT,unix,sa__min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Max
    OPLOT,unix,sa__max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Max RBO [A]
    OPLOT,unix,rb__max,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Explain Max/Min
    XYOUTS,0.50,0.85,'Max = Non-Shadowed Output',COLOR=250,/NORMAL
    XYOUTS,0.50,0.80,'Min = Mag. Boom Shadowed Output',COLOR= 50,/NORMAL


;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
;; Define Y-Axis range
yra            = [5d0,19d0]           ;; range of currents
;; Define axes labels
yttl           = 'Current Output [Amps]'
xttl           = 'Years'
pttl           = 'Wind Solar Array Output'
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;; Define output file name
symsz          = 1.25
fname          = 'Wind_Solar-Array-Current-Output_vs_Time_Nov-1994_to_Nov-2012'
popen,fname[0],/LAND
  PLOT,unix,sa__min,_EXTRA=pstr
    ;; Min
    OPLOT,unix,sa__min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Max
    OPLOT,unix,sa__max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.50,0.85,'Max = Non-Shadowed Output',COLOR=250,/NORMAL
    XYOUTS,0.50,0.80,'Min = Mag. Boom Shadowed Output',COLOR= 50,/NORMAL
pclose



;;-----------------------------------------
;;  Expand time range
;;-----------------------------------------
;; Define Y-Axis range
yra            = [5d0,19d0]           ;; range of currents
;; Define X-Axis ticks
xtn            = ['1994','1995','1996','1997','1998','1999','2000','2001','2002','2003',$
                  '2004','2005','2006','2007','2008','2009','2010','2011','2012','2013',$
                  '2014','2015','2016','2017','2018']
xtn_dates      = xtn+'-01-01/00:00:00.000'
xtv            = time_double(xtn_dates)
xts            = N_ELEMENTS(xtv) - 1L
;; Define axes labels
yttl           = 'Current Output [Amps]'
xttl           = 'Years'
pttl           = 'Wind Solar Array Output [Jan. 1994 to Jan. 2018]'
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;  Plot data
symsz          = 2.00
WSET,0
  PLOT,unix,sa__min,_EXTRA=pstr
    ;; Min
    OPLOT,unix,sa__min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Max
    OPLOT,unix,sa__max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.50,0.85,'Max = Non-Shadowed Output',COLOR=250,/NORMAL
    XYOUTS,0.50,0.80,'Min = Mag. Boom Shadowed Output',COLOR= 50,/NORMAL

;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
;; Define Y-Axis range
yra            = [5d0,19d0]           ;; range of currents
;; Define X-Axis ticks
xtn            = ['1994','1996','1998','2000','2002','2004','2006','2008','2010','2012',$
                  '2014','2016','2018']
xtn_dates      = xtn+'-01-01/00:00:00.000'
xtv            = time_double(xtn_dates)
xts            = N_ELEMENTS(xtv) - 1L
;; Define axes labels
yttl           = 'Current Output [Amps]'
xttl           = 'Years'
pttl           = 'Wind Solar Array Output [Jan. 1994 to Jan. 2018]'
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;; Define output file name
symsz          = 1.25
fname          = 'Wind_Solar-Array-Current-Output_vs_Time_Jan-1994_to_Jan-2018'
popen,fname[0],/LAND
  PLOT,unix,sa__min,_EXTRA=pstr
    ;; Min
    OPLOT,unix,sa__min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Max
    OPLOT,unix,sa__max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.50,0.85,'Max = Non-Shadowed Output',COLOR=250,/NORMAL
    XYOUTS,0.50,0.80,'Min = Mag. Boom Shadowed Output',COLOR= 50,/NORMAL
pclose


;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot battery voltage output
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
WINDOW,1,RETAIN=2,XSIZE=1200,YSIZE=775

;; Define Y-Axis range
yra            = [21d0,24d0]           ;; range of bias voltages
;; Define X-Axis ticks
xtn            = ['1994','1995','1996','1997','1998','1999','2000','2001','2002','2003',$
                  '2004','2005','2006','2007','2008','2009','2010','2011','2012','2013',$
                  '2014','2015','2016','2017','2018']
xtn_dates      = xtn+'-01-01/00:00:00.000'
xtv            = time_double(xtn_dates)
xts            = N_ELEMENTS(xtv) - 1L
;; Define axes labels
yttl           = 'Battery Voltage Output [Volts]'
xttl           = 'Years'
pttl           = 'Wind Avg Battery Bias Voltage Output [Jan. 1994 to Jan. 2018]'
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:6L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;  Plot data
symsz          = 2.00
WSET,1
  PLOT,unix,bv1_avg,_EXTRA=pstr
    ;; Battery 1
    OPLOT,unix,bv1_avg,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Battery 2
    OPLOT,unix,bv2_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Battery 3
    OPLOT,unix,bv3_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Output current load shed setting
    OPLOT,!X.CRANGE,[21.1,21.1],LINESTYLE=2,COLOR=200
    XYOUTS,0.25,0.30,'21.1 V = current load shed setting',COLOR=200,/NORMAL
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.50,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.50,0.80,'Battery 3',COLOR=250,/NORMAL

;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
;; Define Y-Axis range
yra            = [21d0,24d0]           ;; range of bias voltages
;; Define X-Axis ticks
xtn            = ['1994','1996','1998','2000','2002','2004','2006','2008','2010','2012',$
                  '2014','2016','2018']
xtn_dates      = xtn+'-01-01/00:00:00.000'
xtv            = time_double(xtn_dates)
xts            = N_ELEMENTS(xtv) - 1L
;; Define axes labels
yttl           = 'Battery Voltage Output [Volts]'
xttl           = 'Years'
pttl           = 'Wind Avg Battery Bias Voltage Output [Jan. 1994 to Jan. 2018]'
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:6L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;; Define output file name
symsz          = 1.25
fname          = 'Wind_Avg-Battery-Bias-Voltage-Output_vs_Time_Jan-1994_to_Jan-2018'
popen,fname[0],/LAND
  PLOT,unix,bv1_avg,_EXTRA=pstr
    ;; Battery 1
    OPLOT,unix,bv1_avg,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Battery 2
    OPLOT,unix,bv2_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Battery 3
    OPLOT,unix,bv3_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Output current load shed setting
    OPLOT,!X.CRANGE,[21.1,21.1],LINESTYLE=2,COLOR=200
    XYOUTS,0.25,0.30,'21.1 V = current load shed setting',COLOR=200,/NORMAL
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.50,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.50,0.80,'Battery 3',COLOR=250,/NORMAL
pclose
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot regulated bus current output
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
WINDOW,2,RETAIN=2,XSIZE=1200,YSIZE=775

;; Define Y-Axis range
yra            = [5d0,19d0]           ;; range of currents
;; Define X-Axis ticks
xtn            = ['1994','1995','1996','1997','1998','1999','2000','2001','2002','2003',$
                  '2004','2005','2006','2007','2008','2009','2010','2011','2012','2013',$
                  '2014','2015','2016','2017','2018']
xtn_dates      = xtn+'-01-01/00:00:00.000'
xtv            = time_double(xtn_dates)
xts            = N_ELEMENTS(xtv) - 1L
;; Define axes labels
yttl           = 'Regulated Bus Current Output [Amps]'
xttl           = 'Years'
pttl           = 'Wind Regulated Bus Current Output [Jan. 1994 to Jan. 2018]'
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;  Plot data
symsz          = 2.00
WSET,2
  PLOT,unix,rb__min,_EXTRA=pstr
    ;; Min
    OPLOT,unix,rb__min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Avg
    OPLOT,unix,rb__avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Max
    OPLOT,unix,rb__max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Min RBC = Transmitter Off',COLOR= 50,/NORMAL
    XYOUTS,0.50,0.85,'Avg Regulated Bus Current [RBC]',COLOR=150,/NORMAL
    XYOUTS,0.50,0.80,'Max RBC = Transmitter On',COLOR=250,/NORMAL

;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
;; Define Y-Axis range
yra            = [5d0,19d0]           ;; range of currents
;; Define X-Axis ticks
xtn            = ['1994','1996','1998','2000','2002','2004','2006','2008','2010','2012',$
                  '2014','2016','2018']
xtn_dates      = xtn+'-01-01/00:00:00.000'
xtv            = time_double(xtn_dates)
xts            = N_ELEMENTS(xtv) - 1L
;; Define axes labels
yttl           = 'Regulated Bus Current Output [Amps]'
xttl           = 'Years'
pttl           = 'Wind Regulated Bus Current Output [Jan. 1994 to Jan. 2018]'
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;; Define output file name
symsz          = 1.25
fname          = 'Wind_Regulated-Bus-Current-Output_vs_Time_Jan-1994_to_Jan-2018'
popen,fname[0],/LAND
  PLOT,unix,rb__min,_EXTRA=pstr
    ;; Min
    OPLOT,unix,rb__min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Avg
    OPLOT,unix,rb__avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Max
    OPLOT,unix,rb__max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Min RBC = Transmitter Off',COLOR= 50,/NORMAL
    XYOUTS,0.50,0.85,'Avg Regulated Bus Current [RBC]',COLOR=150,/NORMAL
    XYOUTS,0.50,0.80,'Max RBC = Transmitter On',COLOR=250,/NORMAL
pclose
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot regulated bus voltage output
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
WINDOW,2,RETAIN=2,XSIZE=1200,YSIZE=775

;; Define data
dat_t          = unix_v
dat_min        = rb_v_min
dat_avg        = rb_v_avg
dat_max        = rb_v_max
;; Define Y-Axis range
yra            = [28d0,28.2d0]           ;; range of bus voltages
;; Define X-Axis ticks
xtn            = ['1994','1995','1996','1997','1998','1999','2000','2001','2002','2003',$
                  '2004','2005','2006','2007','2008','2009','2010','2011','2012','2013',$
                  '2014','2015','2016','2017','2018']
xtn_dates      = xtn+'-01-01/00:00:00.000'
xtv            = time_double(xtn_dates)
xts            = N_ELEMENTS(xtv) - 1L
;; Define axes labels
yttl           = 'Regulated Bus Voltage Output [Volts]'
xttl           = 'Years'
pttl           = 'Wind Regulated Bus Voltage Output [Jan. 1994 to Jan. 2018]'
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;  Plot data
symsz          = 2.00
WSET,2
  PLOT,dat_t,dat_min,_EXTRA=pstr
    ;; Min
    OPLOT,dat_t,dat_min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Avg
    OPLOT,dat_t,dat_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Max
    OPLOT,dat_t,dat_max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Min RBV',COLOR= 50,/NORMAL
    XYOUTS,0.50,0.85,'Avg Regulated Bus Voltage [RBC]',COLOR=150,/NORMAL
    XYOUTS,0.50,0.80,'Max RBV',COLOR=250,/NORMAL

;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
;; Define Y-Axis range
yra            = [28d0,28.2d0]           ;; range of bus voltages
;; Define X-Axis ticks
xtn            = ['1994','1996','1998','2000','2002','2004','2006','2008','2010','2012',$
                  '2014','2016','2018']
xtn_dates      = xtn+'-01-01/00:00:00.000'
xtv            = time_double(xtn_dates)
xts            = N_ELEMENTS(xtv) - 1L
;; Define axes labels
yttl           = 'Regulated Bus Voltage Output [Volts]'
xttl           = 'Years'
pttl           = 'Wind Regulated Bus Voltage Output [Jan. 1994 to Jan. 2018]'
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:7L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;; Define output file name
symsz          = 1.25
fname          = 'Wind_Regulated-Bus-Voltage-Output_vs_Time_Jan-1994_to_Jan-2018'
popen,fname[0],/LAND
  PLOT,dat_t,dat_min,_EXTRA=pstr
    ;; Min
    OPLOT,dat_t,dat_min,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Avg
    OPLOT,dat_t,dat_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Max
    OPLOT,dat_t,dat_max,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.50,0.90,'Min RBV',COLOR= 50,/NORMAL
    XYOUTS,0.50,0.85,'Avg Regulated Bus Voltage [RBC]',COLOR=150,/NORMAL
    XYOUTS,0.50,0.80,'Max RBV',COLOR=250,/NORMAL
pclose


;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot avg battery temperature
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
WINDOW,2,RETAIN=2,XSIZE=1200,YSIZE=775

;; Define Y-Axis range
yra            = [0d0,18d0]           ;; range of currents
;; Define X-Axis ticks
xtn            = ['1994','1995','1996','1997','1998','1999','2000','2001','2002','2003',$
                  '2004','2005','2006','2007','2008','2009','2010','2011','2012','2013',$
                  '2014','2015','2016','2017','2018']
xtn_dates      = xtn+'-01-01/00:00:00.000'
xtv            = time_double(xtn_dates)
xts            = N_ELEMENTS(xtv) - 1L
;; Define axes labels
yttl           = 'Battery Temperature [!Uo!N'+'C]'
xttl           = 'Years'
pttl           = 'Wind Avg Battery Temperature [Jan. 1994 to Jan. 2018]'
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:9L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;  Plot data
symsz          = 2.00
WSET,2
  PLOT,unix,bt1_avg,_EXTRA=pstr
    ;; Battery 1 [Max Temp]
    OPLOT,unix,bt1_avg,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Battery 2 [Max Temp]
    OPLOT,unix,bt2_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Battery 3 [Max Temp]
    OPLOT,unix,bt3_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.25,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.25,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.25,0.80,'Battery 3',COLOR=250,/NORMAL

;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
;; Define Y-Axis range
yra            = [0d0,18d0]           ;; range of currents
;; Define X-Axis ticks
xtn            = ['1994','1995','1996','1997','1998','1999','2000','2001','2002','2003',$
                  '2004','2005','2006','2007','2008','2009','2010','2011','2012','2013',$
                  '2014','2015','2016','2017','2018']
xtn_dates      = xtn+'-01-01/00:00:00.000'
xtv            = time_double(xtn_dates)
xts            = N_ELEMENTS(xtv) - 1L
;; Define axes labels
yttl           = 'Battery Temperature [!Uo!N'+'C]'
xttl           = 'Years'
pttl           = 'Wind Avg Battery Temperature [Jan. 1994 to Jan. 2018]'
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:9L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;; Define output file name
symsz          = 1.25
fname          = 'Wind_Avg-Battery-Temperature_vs_Time_Jan-1994_to_Jan-2018'
popen,fname[0],/LAND
  PLOT,unix,bt1_avg,_EXTRA=pstr
    ;; Battery 1 [Max Temp]
    OPLOT,unix,bt1_avg,PSYM=8,SYMSIZE=symsz[0],COLOR= 50
    ;; Battery 2 [Max Temp]
    OPLOT,unix,bt2_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=150
    ;; Battery 3 [Max Temp]
    OPLOT,unix,bt3_avg,PSYM=8,SYMSIZE=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.25,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.25,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.25,0.80,'Battery 3',COLOR=250,/NORMAL
pclose
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot max charge current
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
WINDOW,2,RETAIN=2,XSIZE=1200,YSIZE=775

;; Define Y-Axis range
yra            = [3d-1,6d-1]           ;; range of currents
;; Remove values outside range
smcc1_max      = cc1_max
smcc2_max      = cc2_max
smcc3_max      = cc3_max
good1          = WHERE(cc1_max GT yra[0] AND cc1_max LT yra[1],gd1,COMPLEMENT=bad1,NCOMPLEMENT=bd1)
good2          = WHERE(cc2_max GT yra[0] AND cc2_max LT yra[1],gd2,COMPLEMENT=bad2,NCOMPLEMENT=bd2)
good3          = WHERE(cc3_max GT yra[0] AND cc3_max LT yra[1],gd3,COMPLEMENT=bad3,NCOMPLEMENT=bd3)
IF (bd1 GT 0) THEN smcc1_max[bad1] = d
IF (bd2 GT 0) THEN smcc2_max[bad2] = d
IF (bd3 GT 0) THEN smcc3_max[bad3] = d
nsm            = 15L
nsms           = STRING(FORMAT='(I3.3)',nsm[0])
suffx          = '_sm'+nsms[0]+'pts'
smcc1_max      = SMOOTH(smcc1_max,nsm[0],/NAN,/EDGE_TRUNCATE)
smcc2_max      = SMOOTH(smcc2_max,nsm[0],/NAN,/EDGE_TRUNCATE)
smcc3_max      = SMOOTH(smcc3_max,nsm[0],/NAN,/EDGE_TRUNCATE)
;; Define X-Axis ticks
xtn            = ['1994','1995','1996','1997','1998','1999','2000','2001','2002','2003',$
                  '2004','2005','2006','2007','2008','2009','2010','2011','2012','2013',$
                  '2014','2015','2016','2017','2018']
xtn_dates      = xtn+'-01-01/00:00:00.000'
xtv            = time_double(xtn_dates)
xts            = N_ELEMENTS(xtv) - 1L
;; Define axes labels
yttl           = 'Battery Charge Current [Amps]'
xttl           = 'Years'
pttl           = 'Wind Max Battery Charge Current [Jan. 1994 to Jan. 2018]'
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:6L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;;  Plot data
symsz          = 2.00
WSET,2
  PLOT,unix,smcc1_max,_EXTRA=pstr
    ;; Max Battery 1
    OPLOT,unix,smcc1_max,LINESTYLE=0,THICK=symsz[0],COLOR= 50
    ;; Max Battery 2
    OPLOT,unix,smcc2_max,LINESTYLE=0,THICK=symsz[0],COLOR=150
    ;; Max Battery 3
    OPLOT,unix,smcc3_max,LINESTYLE=0,THICK=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.25,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.25,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.25,0.80,'Battery 3',COLOR=250,/NORMAL

;;-----------------------------------------
;;  Save Plot
;;-----------------------------------------
;; Define Y-Axis range
yra            = [3d-1,6d-1]           ;; range of currents
;; Define X-Axis ticks
xtn            = ['1994','1996','1998','2000','2002','2004','2006','2008','2010','2012',$
                  '2014','2016','2018']
xtn_dates      = xtn+'-01-01/00:00:00.000'
xtv            = time_double(xtn_dates)
xts            = N_ELEMENTS(xtv) - 1L
;; Define axes labels
yttl           = 'Battery Charge Current [Amps]'
xttl           = 'Years'
pttl           = 'Wind Max Battery Charge Current [Jan. 1994 to Jan. 2018]'
;; Define plot structure
pstr           = {YRANGE:yra,XTICKNAME:xtn,XTICKV:xtv,XTICKS:xts,YTITLE:yttl,XTITLE:xttl,$
                  TITLE:pttl,NODATA:1,XMINOR:12,YMINOR:4,YTICKS:6L,XTICKLEN:1.0,$
                  XGRIDSTYLE:1,XSTYLE:1,YSTYLE:1}
;; Define output file name
symsz          = 1.25
fname          = 'Wind_Max-Battery-Charge-Current'+suffx[0]+'_vs_Time_Jan-1994_to_Jan-2018'
popen,fname[0],/LAND
  PLOT,unix,smcc1_max,_EXTRA=pstr
    ;; Max Battery 1
    OPLOT,unix,smcc1_max,LINESTYLE=0,THICK=symsz[0],COLOR= 50
    ;; Max Battery 2
    OPLOT,unix,smcc2_max,LINESTYLE=0,THICK=symsz[0],COLOR=150
    ;; Max Battery 3
    OPLOT,unix,smcc3_max,LINESTYLE=0,THICK=symsz[0],COLOR=250
    ;; Explain Max/Min
    XYOUTS,0.25,0.90,'Battery 1',COLOR= 50,/NORMAL
    XYOUTS,0.25,0.85,'Battery 2',COLOR=150,/NORMAL
    XYOUTS,0.25,0.80,'Battery 3',COLOR=250,/NORMAL
pclose































































































































