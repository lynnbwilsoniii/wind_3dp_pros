;;----------------------------------------------------------------------------------------
;;  Compile relevant routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;;  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  Probe A

;;  Probe B

;;  Probe C

probe          = 'c'
tdate          = '2008-07-14'
date           = '071408'

probe          = 'c'
tdate          = '2008-08-19'   ;;  tons of shocklets and SLAMS for this pass
date           = '081908'

probe          = 'c'
tdate          = '2008-09-08'
date           = '090808'

probe          = 'c'
tdate          = '2008-09-16'
date           = '091608'

;;  Probe D

;;  Probe E

;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
no_load_spec   = 0b                    ;;  --> do load particle spectra
no_load_spec   = 1b                    ;;  --> do NOT load particle spectra

ex_start       = SYSTIME(1)            ;;  Time the execution of all events within
@$HOME/Desktop/swidl-0.1/IDL_Stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_thm_FS_eVDFs_calc_sh_parms_batch.pro
MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;;  Define overview time range
IF (tdate[0] EQ '2008-07-14') THEN tra_overv = time_double(tr_jj) + [1,-6e0/4e0]*4d1*6d1  ;;  shrink by 40 minutes at start
IF (tdate[0] EQ '2008-08-19') THEN tra_overv = time_double(tr_jj) + [1,-4e0/4e0]*4d1*6d1  ;;  shrink by 40 minutes at start and end
IF (tdate[0] EQ '2008-09-08') THEN tra_overv = tr_bs_cal
IF (tdate[0] EQ '2008-09-16') THEN tra_overv = tr_bs_cal + [1,-1]*4d0*36d2                ;;  shrink by 4 hours at start and end

tlimit,tra_overv

;;  Plot FGM data
tplot,fgs_tpns,TRANGE=tra_overv
tplot,fgl_tpns,TRANGE=tra_overv
tplot,fgh_tpns,TRANGE=tra_overv
;;  Show location of SLAMS, HFAs, and FBs
time_bar,t_slam_cent,COLOR=250
time_bar,t_hfa__cent,COLOR=200
time_bar,t_fb___cent,COLOR= 30
;;----------------------------------------------------------------------------------------
;;  Plot individual spectra
;;----------------------------------------------------------------------------------------
;;  Below is an example for the THC 2008-07-14 foreshock pass
tra0           = REFORM(tr_fb___250[2,*]) + [-0.4,4]*5d1
nna            = [fgh_tpns,eeomni_fac[0],ieomni_fac[0],sebfomnifac[0],sifomnifac[0]]
  tplot,nna,TRANGE=tra0
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
;;  Get example structures
dat0           = dat_e
dat1           = dat_seb
;;  Limit to time range with enhancements
tra1           = MEAN(tr_fb___70[2,*],/NAN) + [-1,1]*6d1  ;;  in this case, ±1 minute
test0          = (dat0.TIME GE tra1[0]) AND (dat0.END_TIME LE tra1[1])
test1          = (dat1.TIME GE tra1[0]) AND (dat1.END_TIME LE tra1[1])
good0          = WHERE(test0,gd0)
good1          = WHERE(test1,gd1)
PRINT,';;',gd0,gd1,'  For Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0]
;;          38          38  For Probe:  THC on 2008-07-14

;;  Open windows
wi,1,xsize=800,ysize=800
wi,2,xsize=800,ysize=800
wi,3,xsize=800,ysize=800

;;  Setup options
str_element,lim0, 'XSTYLE',        1,/ADD_REPLACE
str_element,lim0, 'YSTYLE',        1,/ADD_REPLACE
str_element,lim0, 'XMINOR',        9,/ADD_REPLACE
str_element,lim0, 'YMINOR',        9,/ADD_REPLACE
str_element,lim0,'XMARGIN',  [10,10],/ADD_REPLACE
str_element,lim0,'YMARGIN',  [ 5, 5],/ADD_REPLACE

get_data,eeomni_fac[0],DATA=temp,DLIMIT=dlim,LIMIT=lim
extract_tags,lime_str,lim,TAGS=['YRANGE','YTICKNAME','YTICKV','YTICKS']
extract_tags,lime_str,lim0

get_data,sebfomnifac[0],DATA=temp,DLIMIT=dlim,LIMIT=lim
extract_tags,lims_str,lim,TAGS=['YRANGE','YTICKNAME','YTICKV','YTICKS']
extract_tags,lims_str,lim0

xran           = [5e1,2e4]
yran           = [1e-1,1e6]
str_element,lime_str, 'XRANGE',     xran,/ADD_REPLACE
str_element,lime_str, 'YRANGE',     yran,/ADD_REPLACE
xran           = [1e4,2e5]
yran           = [1e-4,2e-1]
str_element,lims_str, 'XRANGE',     xran,/ADD_REPLACE
str_element,lims_str, 'YRANGE',     yran,/ADD_REPLACE
;;  Define power-law lines
f_at_10keV     = yran[1]
a_o            = f_at_10keV[0]*(xran[0])^2
fplaw_2        = a_o[0]*xran^(-2d0)

;;  Plot examples
units          = 'flux'
jj             = good0[17]
tdate_sw       = dat0[jj]
kk             = good1[17]
tdats_sw       = dat1[kk]
transform_vframe_3d,tdate_sw,/EASY_TRAN
transform_vframe_3d,tdats_sw,/EASY_TRAN

WSET,1
DELVAR,xdat_eesa,ydat_eesa,pang_eesa
lbw_spec3d,tdate_sw,LIMITS=lime_str,/SUNDIR,/LABEL,XDAT=xdat_eesa,YDAT=ydat_eesa,PITCHANGLE=pang_eesa
  OPLOT,xran,fplaw_2,LINESTYLE=2,THICK=2

WSET,2
DELVAR,xdat_nf_sd,ydat_nf_sd,pang
lbw_spec3d,tdats_sw,LIMITS=lims_str,/SUNDIR,/LABEL,XDAT=xdat_nf_sd,YDAT=ydat_nf_sd,PITCHANGLE=pang
  OPLOT,xran,fplaw_2,LINESTYLE=2,THICK=2

;;  Check "bad" energy bins (i.e., where ∆E --> 0)
bad_eesa_en    = WHERE(tdate_sw.ENERGY[*,0] GE 2e4,bd_eesa_en,COMPLEMENT=good_eesa_en,NCOMPLEMENT=gd_eesa_en)
bad_ener       = WHERE(tdats_sw.DENERGY[*,0] LE 0,bd_ener,COMPLEMENT=good_ener,NCOMPLEMENT=gd_ener)
PRINT,';;',bd_eesa_en,gd_eesa_en,'  For EESA on Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0] & $
PRINT,';;',bd_ener,gd_ener,'  For SSTe on Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0]
;;           3          29  For EESA on Probe:  THC on 2008-07-14
;;           5          11  For SSTe on Probe:  THC on 2008-07-14

;;  Define range of pitch-angles to use
cut_aran       = 22.5d0
cut_mids       = [22.5d0,9d1,157.5d0]
cut_lows       = cut_mids - cut_aran[0]
cut_high       = cut_mids + cut_aran[0]

test_para      = (pang_eesa LE cut_high[0]) AND (pang_eesa GE cut_lows[0])
test_perp      = (pang_eesa LE cut_high[1]) AND (pang_eesa GE cut_lows[1])
test_anti      = (pang_eesa LE cut_high[2]) AND (pang_eesa GE cut_lows[2])
good_para      = WHERE(test_para,gd_para)
good_perp      = WHERE(test_perp,gd_perp)
good_anti      = WHERE(test_anti,gd_anti)
PRINT,';;',gd_para,gd_perp,gd_anti,'  For Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0]
;;          14          38           8  For Probe:  THC on 2008-07-14

;;  Redefine
good_para_eesa = good_para
good_perp_eesa = good_perp
good_anti_eesa = good_anti

;;  w/rt sun direction
test_para      = (pang LE cut_high[0]) AND (pang GE cut_lows[0])
test_perp      = (pang LE cut_high[1]) AND (pang GE cut_lows[1])
test_anti      = (pang LE cut_high[2]) AND (pang GE cut_lows[2])
good_para      = WHERE(test_para,gd_para)
good_perp      = WHERE(test_perp,gd_perp)
good_anti      = WHERE(test_anti,gd_anti)
PRINT,';;',gd_para,gd_perp,gd_anti,'  For Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0]
;;           8          24           8  For Probe:  THC on 2008-07-14

;;  Redefine
good_para_sste = good_para
good_perp_sste = good_perp
good_anti_sste = good_anti

;;  Define data over which to average
data_para_eesa = ydat_eesa[*,good_para_eesa]
data_perp_eesa = ydat_eesa[*,good_perp_eesa]
data_anti_eesa = ydat_eesa[*,good_anti_eesa]
ener_para_eesa = xdat_eesa[*,good_para_eesa]
ener_perp_eesa = xdat_eesa[*,good_perp_eesa]
ener_anti_eesa = xdat_eesa[*,good_anti_eesa]
pang_para_eesa =   pang_eesa[good_para_eesa]
pang_perp_eesa =   pang_eesa[good_perp_eesa]
pang_anti_eesa =   pang_eesa[good_anti_eesa]

data_para_sste = ydat_nf_sd[*,good_para_sste]
data_perp_sste = ydat_nf_sd[*,good_perp_sste]
data_anti_sste = ydat_nf_sd[*,good_anti_sste]
ener_para_sste = xdat_nf_sd[*,good_para_sste]
ener_perp_sste = xdat_nf_sd[*,good_perp_sste]
ener_anti_sste = xdat_nf_sd[*,good_anti_sste]
pang_para_sste =         pang[good_para_sste]
pang_perp_sste =         pang[good_perp_sste]
pang_anti_sste =         pang[good_anti_sste]

;;  Keep only good energies now
data_para_eesa = data_para_eesa[good_eesa_en,*]
data_perp_eesa = data_perp_eesa[good_eesa_en,*]
data_anti_eesa = data_anti_eesa[good_eesa_en,*]
ener_para_eesa = ener_para_eesa[good_eesa_en,*]
ener_perp_eesa = ener_perp_eesa[good_eesa_en,*]
ener_anti_eesa = ener_anti_eesa[good_eesa_en,*]

data_para_sste = data_para_sste[good_ener,*]
data_perp_sste = data_perp_sste[good_ener,*]
data_anti_sste = data_anti_sste[good_ener,*]
ener_para_sste = ener_para_sste[good_ener,*]
ener_perp_sste = ener_perp_sste[good_ener,*]
ener_anti_sste = ener_anti_sste[good_ener,*]

;;  Average data over each direction
Avgf_para_eesa = TOTAL(data_para_eesa,2L,/NAN)/TOTAL(FINITE(data_para_eesa),2L,/NAN)
AvgE_para_eesa = TOTAL(ener_para_eesa,2L,/NAN)/TOTAL(FINITE(ener_para_eesa),2L,/NAN)
Avgf_perp_eesa = TOTAL(data_perp_eesa,2L,/NAN)/TOTAL(FINITE(data_perp_eesa),2L,/NAN)
AvgE_perp_eesa = TOTAL(ener_perp_eesa,2L,/NAN)/TOTAL(FINITE(ener_perp_eesa),2L,/NAN)
Avgf_anti_eesa = TOTAL(data_anti_eesa,2L,/NAN)/TOTAL(FINITE(data_anti_eesa),2L,/NAN)
AvgE_anti_eesa = TOTAL(ener_anti_eesa,2L,/NAN)/TOTAL(FINITE(ener_anti_eesa),2L,/NAN)

Avgf_para_sste = TOTAL(data_para_sste,2L,/NAN)/TOTAL(FINITE(data_para_sste),2L,/NAN)
AvgE_para_sste = TOTAL(ener_para_sste,2L,/NAN)/TOTAL(FINITE(ener_para_sste),2L,/NAN)
Avgf_perp_sste = TOTAL(data_perp_sste,2L,/NAN)/TOTAL(FINITE(data_perp_sste),2L,/NAN)
AvgE_perp_sste = TOTAL(ener_perp_sste,2L,/NAN)/TOTAL(FINITE(ener_perp_sste),2L,/NAN)
Avgf_anti_sste = TOTAL(data_anti_sste,2L,/NAN)/TOTAL(FINITE(data_anti_sste),2L,/NAN)
AvgE_anti_sste = TOTAL(ener_anti_sste,2L,/NAN)/TOTAL(FINITE(ener_anti_sste),2L,/NAN)

yran           = [1e-4,1e6]
xran           = [5e1,2e5]
pstr           = lim0
str_element,pstr,  'YLOG',            1,/ADD_REPLACE
str_element,pstr,  'XLOG',            1,/ADD_REPLACE
str_element,pstr,'YTITLE',       'flux',/ADD_REPLACE
str_element,pstr,'XTITLE','Energy [eV]',/ADD_REPLACE
str_element,pstr, 'TITLE','SST-e Burst',/ADD_REPLACE
str_element,pstr,'XRANGE',         xran,/ADD_REPLACE
str_element,pstr,'YRANGE',         yran,/ADD_REPLACE
;;  Define power-law lines
f_at_50eV      = yran[1]
a_o            = f_at_50eV[0]*(xran[0])^2
fplaw_2        = a_o[0]*xran^(-2d0)
f_at_50eV      = yran[1]*10
a_o            = f_at_50eV[0]*(xran[0])^3
fplaw_3        = a_o[0]*xran^(-3d0)

WSET,3
PLOT,AvgE_para_eesa,Avgf_para_eesa,_EXTRA=pstr
  ;;  Plot EESA data
  OPLOT,AvgE_para_eesa,Avgf_para_eesa,COLOR=250
  OPLOT,AvgE_perp_eesa,Avgf_perp_eesa,COLOR=150
  OPLOT,AvgE_anti_eesa,Avgf_anti_eesa,COLOR= 50
  ;;  Plot SSTe data
  OPLOT,AvgE_para_sste,Avgf_para_sste,COLOR=250
  OPLOT,AvgE_perp_sste,Avgf_perp_sste,COLOR=150
  OPLOT,AvgE_anti_sste,Avgf_anti_sste,COLOR= 50
  OPLOT,xran,fplaw_2,LINESTYLE=2,THICK=2
  OPLOT,xran,fplaw_3,LINESTYLE=3,THICK=2

;;  Save plots
fname          = 'THC_EESA_SSTe_on_2008-07-14_at_2158x03_para-red_perp-green_anti-blue_wrt_sundir'
popen_str      = {PORT:1,UNITS:'inches',XSIZE:8.5,YSIZE:8.5,ASPECT:1}
popen,fname[0],_EXTRA=popen_str
  PLOT,AvgE_para_eesa,Avgf_para_eesa,_EXTRA=pstr
    ;;  Plot EESA data
    OPLOT,AvgE_para_eesa,Avgf_para_eesa,COLOR=250
    OPLOT,AvgE_perp_eesa,Avgf_perp_eesa,COLOR=150
    OPLOT,AvgE_anti_eesa,Avgf_anti_eesa,COLOR= 50
    ;;  Plot SSTe data
    OPLOT,AvgE_para_sste,Avgf_para_sste,COLOR=250
    OPLOT,AvgE_perp_sste,Avgf_perp_sste,COLOR=150
    OPLOT,AvgE_anti_sste,Avgf_anti_sste,COLOR= 50
    OPLOT,xran,fplaw_2,LINESTYLE=2,THICK=2
    OPLOT,xran,fplaw_3,LINESTYLE=3,THICK=2
pclose






