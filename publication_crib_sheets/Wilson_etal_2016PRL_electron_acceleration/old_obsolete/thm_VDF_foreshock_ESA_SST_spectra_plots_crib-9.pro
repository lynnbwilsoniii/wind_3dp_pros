;;----------------------------------------------------------------------------------------
;;  Papers relevant to energetic electrons at shocks:
;;
;;    -  Kronberg et al. [2011] JGR [BS, ~37-125 keV at up to 8500 Re upstream; attribute to magnetospheric activity]
;;    -  Masters et al. [2013] Nature Phys. [Saturn up to ~1 MeV]
;;    -  Masters et al. [2013] Plasma Phys. Control. Fusion [in situ Obs. of high M shocks]
;;    -  Sarris et al. [1976] JGR [p+ (≥290 keV) and e- (≥220 keV) bursts; Assoc. w/ weak ∂B --> suggest waves, e- PADs = FA upstream, most intense upstream p+ bursts Assoc. w/ e- bursts --> suggest common Accel. Mech.]
;;
;;
;;    -  Vandas et al. [1986] ASR [Qperp bow shocks to ≥30 keV]
;;    -  Anderson, K.A. [1968] JGR [bow shocks to >40 keV]
;;    -  Anderson, K.A. [1969] JGR [bow shocks to >40 keV, Eo ~ 14 keV for BS, ~16 keV for US, ¥ ~ 2.1(BS), 1.8(US)]
;;    -  Anderson et al. [1979] JGR [bow shocks to >16 keV --> nearly continuous feature of electron foreshock]
;;    -  Anderson, K.A. [1981] JGR [bow shocks to ~2-100 keV at up to ~240 Re upstream]
;;    -  Gosling et al. [1989] JGR [bow shocks to >20 keV downstream Qperp only]
;;
;;
;;    -  Burgess [2006] ApJ [Qperp shocks (simulations) to >few to ~10 keV]
;;    -  Guo and Giacalone [2010] ApJ [IP shocks (simulations) to >few to ~10 keV]
;;    -  Ho et al. [2003] ICRC [IP shocks to >38 keV --> ESP cause]
;;    -  Lopate, C. [1989] JGR [IP shocks to ~2-7 MeV between ~7-28 AU]
;;    -  Sarris and Krimigis [1985] ApJ [IP shock to >2 MeV at ~1.9 AU]
;;    -  Tsurutani and Lin [1985] JGR [IP shocks to >2 keV]
;;
;;
;;    -  Krauss-Varban, D. [1994] JGR [Qperp bow shocks (simulations) to >few to ~10 keV]
;;    -  Yuan et al. [2007] ApJ [Qperp shocks (simulations) up to < 25 Vtherm, reformation]
;;    -  Yuan et al. [2007] JGR [Qperp shocks (simulations) up to < 10 Vtherm, overshoots]
;;    -  Yuan et al. [2008a] JGR A08109 [Qperp shocks (simulations) up to < 10 Vtherm]
;;    -  Yuan et al. [2008b] JGR A09106 [Qperp shocks (simulations) up to ≤ 25 Vtherm or E/Eo ≤ 800]
;;
;;
;;    -  Lin, R.P. [1985] Solar Phys. [review of suprathermal electrons in IPM]
;;    -  
;;    -  
;;    -  
;;----------------------------------------------------------------------------------------


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
ex_start       = SYSTIME(1)            ;;  Time the execution of all events within
@$HOME/Desktop/swidl-0.1/IDL_Stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_thm_FS_eVDFs_calc_sh_parms_batch.pro
MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE

;;  Remove "bad" smoothed anisotropy ratios by hand
kill_data_tr,NAMES=tnames(scpref[0]+'*_pseb_psef_spec_*'+nsmpt_suffx[0])
kill_data_tr,NAMES=tnames(scpref[0]+'magf_pseb_psef_spec_*'+nsmpt_suffx[0])
kill_data_tr,NAMES=tnames(scpref[0]+'earthvec_pseb_psef_spec_*'+nsmpt_suffx[0])

kill_data_tr,NAMES=tnames(scpref[0]+'magf_pseb_psef_spec_*'+nsmpt_suffx[0]),IND_2D=[5]
kill_data_tr,NAMES=tnames(scpref[0]+'earthvec_pseb_psef_spec_*'+nsmpt_suffx[0]),IND_2D=[3]


;;  Plot FGM data
tplot,fgs_tpns,TRANGE=tra_sst
tplot,fgl_tpns,TRANGE=tra_sst
tplot,fgh_tpns,TRANGE=tra_sst
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
dat0           = dat_seb
dat1           = dat_sef
;;  Limit to time range with enhancements
tra1           = MEAN(tr_fb___70[2,*],/NAN) + [-1,1]*6d1  ;;  in this case, ±1 minute
test0          = (dat0.TIME GE tra1[0]) AND (dat0.END_TIME LE tra1[1])
test1          = (dat1.TIME GE tra1[0]) AND (dat1.END_TIME LE tra1[1])
good0          = WHERE(test0,gd0)
good1          = WHERE(test1,gd1)
PRINT,';;',gd0,gd1,'  For Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0]
;;          38           1  For Probe:  THC on 2008-07-14

;;  Open windows
wi,1,xsize=800,ysize=800
wi,2,xsize=800,ysize=800

;;  Setup options
get_data,sebfomnifac[0],DATA=temp,DLIMIT=dlim,LIMIT=lim
extract_tags,lim_str,lim,TAGS=['YRANGE','YTICKNAME','YTICKV','YTICKS']
xran           = [1e4,2e5]
str_element,lim_str, 'XRANGE',     xran,/ADD_REPLACE
str_element,lim_str, 'XSTYLE',        1,/ADD_REPLACE
str_element,lim_str, 'YSTYLE',        1,/ADD_REPLACE
str_element,lim_str, 'XMINOR',        9,/ADD_REPLACE
str_element,lim_str, 'YMINOR',        9,/ADD_REPLACE
str_element,lim_str,'XMARGIN',  [10,10],/ADD_REPLACE
str_element,lim_str,'YMARGIN',  [ 5, 5],/ADD_REPLACE
;;  Define power-law lines
f_at_10keV     = 2e0
a_o            = f_at_10keV[0]*(1e4)^2
fplaw_2        = a_o[0]*xran^(-2d0)

;;  Plot examples
units          = 'flux'
jj             = good0[17]
tdata_sc       = dat0[jj]
;tdata_sc.UNITS_PROCEDURE = 'thm_sst_convert_units2'
tdata_sw       = tdata_sc[0]
transform_vframe_3d,tdata_sw,/EASY_TRAN

WSET,1
lbw_spec3d,tdata_sc,LIMITS=lim_str,/SUNDIR,/LABEL,XDAT=xdat_nf_sd,YDAT=ydat_nf_sd
  OPLOT,xran,fplaw_2,LINESTYLE=2,THICK=2

WSET,2
lbw_spec3d,tdata_sw,LIMITS=lim_str,/SUNDIR,/LABEL,XDAT=xdat_nf_sd,YDAT=ydat_nf_sd
  OPLOT,xran,fplaw_2,LINESTYLE=2,THICK=2

;;----------------------------------------------------------------------------------------
;;  Plot bow shock parameters
;;----------------------------------------------------------------------------------------
;;  Plot overview and save
nna            = [fgs_tpns,thm_vsw_tpn[0],thm_lsn_tpn[0],thm_bsntpn2[0]]
  tplot,nna,TRANGE=tr_bs_cal
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30

popen_str      = {PORT:1,UNITS:'inches',XSIZE:8.5,YSIZE:11.}
scu            = STRUPCASE(sc[0])
fpref          = 'THM-'+scu[0]+'_Bo-fgs_Vi-Reduced_Lsh-n_ThetaBn_'
fmid           = 'red-SLAMS_orange-HFA_purple-FB_'
fnm_times      = file_name_times(t_get_current_trange(),PREC=0)
f_times        = fnm_times.F_TIME[0]+'-'+STRMID(fnm_times.F_TIME[1],11L)
fname          = fpref[0]+fmid[0]+f_times[0]

  tplot,nna,TRANGE=tr_bs_cal
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
popen,fname[0],_EXTRA=popen_str
  tplot,nna
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
pclose
;;----------------------------------------------------------------------------------------
;;  Plot orbit for reference
;;    -->  Below is example for 2008-07-14
;;----------------------------------------------------------------------------------------
;;  Get GSE position [km]
get_data,scpref[0]+'state_pos_'+coord_gse[0],DATA=thm_gse_pos
;;  Open a window
wi,1,xsize=800,ysize=800
wi,2,xsize=800,ysize=800
;;  Zoom to an interesting period and then define time range
tlimit
tr             = t_get_current_trange()
tr_ttl0        = time_string(tr,PREC=3)
tr_ttl1        = tr_ttl0[0]+' - '+STRMID(tr_ttl0[1],11)
;;  Clip structure data to current time range
temp2          = trange_clip_data(thm_gse_pos,TRANGE=tr,PREC=3)
;;  Convert to Re from km
xdata          = temp2.Y[*,0]/R_E[0]
ydata          = temp2.Y[*,1]/R_E[0]
zdata          = temp2.Y[*,2]/R_E[0]
xyzrange       = [-1,1]*20e0
norb           = N_ELEMENTS(xdata)
se             = [0L,norb[0] - 1L]
;;  Define some circles for reference
nc             = 10L
circs          = DINDGEN(nc[0])*5d0 + 5d0
the            = DINDGEN(20)*2d0*!DPI/(19)
circx          = REPLICATE(d,nc,20)
circy          = REPLICATE(d,nc,20)
FOR j=0L, nc - 1L DO BEGIN             $
  circx[j,*] = circs[j]*COS(the)     & $
  circy[j,*] = circs[j]*SIN(the)

;;  Define model bow shock location for reference
n2             = 2000L
themx          = 11d1*!DPI/18d1
theta          = DINDGEN(n2)*2d0*themx[0]/((n2 - 1L)) - themx[0]  ; => radians
rad            = Lsemi[0]/(1d0 + ecc[0]*COS(theta))      ; => Distance from focus [Re]
rad_sh         = xo[0] + rad
the_sh         = theta

thck           = 2e0
pttl           = 'TH'+scu[0]+': '+tr_ttl1[0]
xttl           = 'Xgse [Re] (start = Triangle, end = square)'
yttl           = 'Ygse [Re]'
pstr_yx        = {XRANGE:xyzrange,YRANGE:xyzrange,XSTYLE:1,YSTYLE:1,NODATA:1,TITLE:pttl[0],$
                  XTITLE:xttl[0],YTITLE:yttl[0]}
;;  Initialize plot
WSET,1
WSHOW,1
PLOT,xdata,ydata,_EXTRA=pstr_yx
  ;;  Output crosshairs to show origin
  OPLOT,xyzrange,[0,0],COLOR=50,THICK=thck[0]
  OPLOT,[0,0],xyzrange,COLOR=50,THICK=thck[0]
  ;;  Output circles of constant radii
  FOR j=0L, nc - 1L DO OPLOT,REFORM(circx[j,*]),REFORM(circy[j,*]),LINESTYLE=2
  ;;  Output Model Bow Shock Location [Slavin and Holzer, [1990,1991]]
  OPLOT,rad_sh,the_sh,/POLAR,COLOR=200L
  ;;  Output spacecraft position
  OPLOT,xdata,ydata,COLOR=250,PSYM=3
  ;;  Output start/end location spacecraft position
  OPLOT,[xdata[se[0]]],[ydata[se[0]]],COLOR= 30,PSYM=5,SYMSIZE=2
  OPLOT,[xdata[se[1]]],[ydata[se[1]]],COLOR= 30,PSYM=6,SYMSIZE=2


yttl           = 'Zgse [Re]'
pstr_zx        = {XRANGE:xyzrange,YRANGE:xyzrange,XSTYLE:1,YSTYLE:1,NODATA:1,TITLE:pttl[0],$
                  XTITLE:xttl[0],YTITLE:yttl[0]}
;;  Initialize plot
WSET,2
WSHOW,2
PLOT,xdata,zdata,_EXTRA=pstr_zx
  ;;  Output crosshairs to show origin
  OPLOT,xyzrange,[0,0],COLOR=50,THICK=thck[0]
  OPLOT,[0,0],xyzrange,COLOR=50,THICK=thck[0]
  ;;  Output circles of constant radii
  FOR j=0L, nc - 1L DO OPLOT,REFORM(circx[j,*]),REFORM(circy[j,*]),LINESTYLE=2
  ;;  Output Model Bow Shock Location [Slavin and Holzer, [1990,1991]]
  OPLOT,rad_sh,the_sh,/POLAR,COLOR=200L
  ;;  Output spacecraft position
  OPLOT,xdata,zdata,COLOR=250,PSYM=3
  ;;  Output start/end location spacecraft position
  OPLOT,[xdata[se[0]]],[zdata[se[0]]],COLOR= 30,PSYM=5,SYMSIZE=2
  OPLOT,[xdata[se[1]]],[zdata[se[1]]],COLOR= 30,PSYM=6,SYMSIZE=2



;;----------------------------------------------------------------------------------------
;;  Plot bow shock Mach numbers (assuming shock is stationary in Earth frame)
;;----------------------------------------------------------------------------------------
IF (tdate[0] EQ '2008-07-14') THEN machran  = [0e0,25e0]
IF (tdate[0] EQ '2008-08-19') THEN machran  = [0e0,25e0]
IF (tdate[0] EQ '2008-09-08') THEN machran  = [0e0,30e0]
mach_tvn       = (machran[1] - machran[0])/5e0 + 1
mach_tv        = LINDGEN(LONG(mach_tvn[0]))*5e0
mach_ts        = LONG(mach_tvn[0]) - 1L
options,thm_Machs_tpn[0],YRANGE=machran,YTICKV=mach_tv,YTICKS=mach_ts, $
                         YMINOR=4,/DEF
;;  Plot overview and save
nna            = [fgs_tpns,thm_Machs_tpn[0],thm_bsntpn2[0]]
  tplot,nna,TRANGE=tr_bs_cal
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30

popen_str      = {PORT:1,UNITS:'inches',XSIZE:8.5,YSIZE:11.}
scu            = STRUPCASE(sc[0])
fpref          = 'THM-'+scu[0]+'_Bo-fgs_MA_Ms_Mf_ThetaBn_'
fmid           = 'red-SLAMS_orange-HFA_purple-FB_'
fnm_times      = file_name_times(t_get_current_trange(),PREC=0)
f_times        = fnm_times.F_TIME[0]+'-'+STRMID(fnm_times.F_TIME[1],11L)
fname          = fpref[0]+fmid[0]+f_times[0]

  tplot,nna,TRANGE=tr_bs_cal
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
popen,fname[0],_EXTRA=popen_str
  tplot,nna
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
pclose
;;----------------------------------------------------------------------------------------
;;  Plot stacked spectra [overviews of foreshock]
;;----------------------------------------------------------------------------------------
br_str         = ['b','r']
lh_str         = ['l','h']
fglnm          = scpref[0]+'fg'+lh_str[0]+'_'+[coord_mag[0],coord_gse[0]]
fghnm          = scpref[0]+'fg'+lh_str[1]+'_'+[coord_mag[0],coord_gse[0]]
ni_tpns        = scpref[0]+'pei'+br_str+'_density'
Ti_tpns        = scpref[0]+'pei'+br_str+'_avgtemp'
Vi_tpns        = scpref[0]+'pei'+br_str+'_velocity_'+coord_gse[0]
Te_tpns        = scpref[0]+'pee'+br_str+'_avgtemp'
esasuffx       = ['density','avgtemp','velocity_*','magt3','ptens']
;;  Define overview time range
get_data,sifomni_tp[0],DATA=temp,DLIM=dlim,LIM=lim
IF (tdate[0] EQ '2008-07-14') THEN tra_overv = time_double(tr_jj) + [1,-6e0/4e0]*4d1*6d1  ;;  shrink by 40 minutes at start
IF (tdate[0] EQ '2008-08-19') THEN tra_overv = time_double(tr_jj) + [1,-6e0/4e0]*4d1*6d1  ;;  shrink by 40 minutes at start
IF (tdate[0] EQ '2008-09-08') THEN tra_overv = tr_bs_cal
;temp2          = trange_clip_data(temp,TRANGE=tra_overv,PREC=3)
;;  Define default ranges for Ni, Ti, and Te [i.e., change after plotting]
ni_yran        = [1e-2,10e1]
Ti_yran        = [1e-1,15e2]
Te_yran        = [1e-1,10e1]
IF (tdate[0] EQ '2008-07-14') THEN ni_yran = [1e-1,20e0]
IF (tdate[0] EQ '2008-07-14') THEN Ti_yran = [ 5e1,15e2]
IF (tdate[0] EQ '2008-07-14') THEN Te_yran = [ 5e0,30e1]
IF (tdate[0] EQ '2008-08-19') THEN ni_yran = [1e-1,20e0]
IF (tdate[0] EQ '2008-08-19') THEN Ti_yran = [ 5e1,15e2]
IF (tdate[0] EQ '2008-08-19') THEN Te_yran = [ 5e0,20e1]
IF (tdate[0] EQ '2008-09-08') THEN ni_yran = [1e-1,40e0]
IF (tdate[0] EQ '2008-09-08') THEN Ti_yran = [ 3e1,30e2]
IF (tdate[0] EQ '2008-09-08') THEN Te_yran = [ 5e0,30e1]
options,ni_tpns,YRANGE=ni_yran,YLOG=1,COLORS= 50,/DEF
options,Ti_tpns,YRANGE=Ti_yran,YLOG=1,COLORS= 50,/DEF
options,Te_tpns,YRANGE=Te_yran,YLOG=1,COLORS= 50,/DEF
options,ni_tpns[1],LABELS='N_ir',/DEF
options,Ti_tpns[1],LABELS='T_ir',/DEF
options,Te_tpns[1],LABELS='T_er',/DEF
options,ni_tpns[1],LABELS='N_ib',/DEF
options,Ti_tpns[1],LABELS='T_ib',/DEF
options,Te_tpns[1],LABELS='T_eb',/DEF
options,ni_tpns[1],YRANGE=ni_yran,YLOG=1,LABELS='N_ir',/DEF
options,Ti_tpns[1],YRANGE=Ti_yran,YLOG=1,LABELS='T_ir',/DEF
options,Te_tpns[1],YRANGE=Te_yran,YLOG=1,LABELS='T_er',/DEF
options,Ti_tpns,MAX_VALUE=15e2,/DEF                ;;  Ti > 1500 eV  -->  Questionable at best! [in foreshock]
options,Te_tpns,MAX_VALUE=50e1,/DEF                ;;  Te >  500 eV  -->  Questionable at best! [in foreshock]
options,[ni_tpns,Ti_tpns,Te_tpns],YGRIDSTYLE=2,YTICKLEN=1e0
options,[ni_tpns,Ti_tpns,Te_tpns],'YGRIDSTYLE',/DEF
options,[ni_tpns,Ti_tpns,Te_tpns],  'YTICKLEN',/DEF
options,[ni_tpns,Ti_tpns,Te_tpns], 'MAX_VALUE'
options,[ni_tpns,Ti_tpns,Te_tpns],    'YRANGE'
options,[ni_tpns,Ti_tpns,Te_tpns],      'YLOG'
options,[ni_tpns,Ti_tpns,Te_tpns],    'LABELS'
options,[ni_tpns,Ti_tpns,Te_tpns],    'COLORS'

;;  Plot overview of foreshock [moments]
popen_str      = {PORT:1,UNITS:'inches',XSIZE:8.5,YSIZE:11.}
scu            = STRUPCASE(sc[0])
;fpref          = 'THM-'+scu[0]+'_Bo-fgl_Nir_Vir_Tir_Ter_'
;fpref          = 'THM-'+scu[0]+'_Bo-fgl_Nib_Vib_Tib_Teb_'
fpref          = 'THM-'+scu[0]+'_Bo-fgl_Nibr_Vibr_Tibr_Tebr_'
fnm_times      = file_name_times(tra_overv,PREC=0)
f_times        = fnm_times.F_TIME[0]+'-'+STRMID(fnm_times.F_TIME[1],11L)
fmid           = 'with_fgh_zooms_'
fnames         = fpref[0]+fmid[0]+f_times[0]

;nna            = [fglnm,ni_tpns[1],Vi_tpns[1],Ti_tpns[1],Te_tpns[1]]
;nna            = [fglnm,ni_tpns[0],Vi_tpns[0],Ti_tpns[0],Te_tpns[0]]
nna            = [fglnm,ni_tpns,Vi_tpns,Ti_tpns,Te_tpns]
  tplot,nna,TRANGE=tra_overv
  time_bar,sint_fgh,COLOR=250,VARNAME=nna
  time_bar,eint_fgh,COLOR= 50,VARNAME=nna
popen,fnames[0],_EXTRA=popen_str
  tplot,nna,TRANGE=tra_overv
  time_bar,sint_fgh,COLOR=250,VARNAME=nna
  time_bar,eint_fgh,COLOR= 50,VARNAME=nna
pclose

;;  Plot overview of foreshock [OMNI fluxes]
fpref          = 'THM-'+scu[0]+'_Bo-fgl_OMNI_'+units[0]+'_peeb_peib_psebf_psif_'
fnm_times      = file_name_times(tra_overv,PREC=0)
f_times        = fnm_times.F_TIME[0]+'-'+STRMID(fnm_times.F_TIME[1],11L)
fmid           = 'with_fgh_zooms_'
fnames         = fpref[0]+fmid[0]+f_times[0]

nna            = [fglnm,eeomni_tpn[0],ieomni_tpn[0],sebfomni_tp[0],sifomni_tp[0]]
  tplot,nna,TRANGE=tra_overv
  time_bar,sint_fgh,COLOR=250,VARNAME=nna
  time_bar,eint_fgh,COLOR= 50,VARNAME=nna
popen,fnames[0],_EXTRA=popen_str
  tplot,nna,TRANGE=tra_overv
  time_bar,sint_fgh,COLOR=250,VARNAME=nna
  time_bar,eint_fgh,COLOR= 50,VARNAME=nna
pclose
;;----------------------------------------------------------------------------------------
;;  Plot stacked spectra [zooms of TIFP]
;;----------------------------------------------------------------------------------------
;;  Plot fgh zooms of TIFP [OMNI fluxes]
fpref          = 'THM-'+scu[0]+'_Bo-fgl_OMNI_'+units[0]+'_peeb_peib_psebf_psif_'
fnms_time      = file_name_times(sint_fgh,PREC=3)
fnme_time      = file_name_times(eint_fgh,PREC=3)
f_times        = fnms_time.F_TIME+'-'+STRMID(fnme_time.F_TIME,11L)
fmid           = 'TIFP-centers_red-SLAMS_orange-HFA_purple-FB_'
fnames         = fpref[0]+fmid[0]+f_times
nf             = N_ELEMENTS(fnames)
nna            = [fglnm,eeomni_fac[0],ieomni_fac[0],sebfomnifac[0],sifomnifac[0]]
IF (tdate[0] EQ '2008-07-14') THEN tz_70_str = {T0:tr_slam_70, T1:tr_hfa__70, T2:tr_fb___70}
IF (tdate[0] EQ '2008-08-19') THEN tz_70_str = {T0:tr_slam_70, T1:tr_hfa__70, T2:tr_fb___70}
IF (tdate[0] EQ '2008-09-08') THEN tz_70_str = {T0:tr_slam_70,T1:tr_hfa__70,T2:tr_fb___70}
ntz            = N_TAGS(tz_70_str)
tz_cols        = [250,200, 30]

FOR j=0L, nf[0] - 1L DO BEGIN                                                                $
  tra0   = [sint_fgh[j],eint_fgh[j]]                                                       & $
  fname0 = fnames[j]                                                                       & $
  tplot,nna,TRANGE=tra0                                                                    & $
  FOR k=0L, ntz[0] - 1L DO BEGIN                                                             $
    tz_70          = tz_70_str.(k)                                                         & $
    nz             = N_ELEMENTS(tz_70[*,0])                                                & $
    FOR l=0L, nz[0] - 1L DO time_bar,MEAN(tz_70[l,*],/NAN),COLOR=tz_cols[k],VARNAME=nna    & $
  ENDFOR                                                                                   & $
  popen,fname0[0],_EXTRA=popen_str                                                         & $
    tplot,nna,TRANGE=tra0                                                                  & $
    FOR k=0L, ntz[0] - 1L DO BEGIN                                                           $
      tz_70          = tz_70_str.(k)                                                       & $
      nz             = N_ELEMENTS(tz_70[*,0])                                              & $
      FOR l=0L, nz[0] - 1L DO time_bar,MEAN(tz_70[l,*],/NAN),COLOR=tz_cols[k],VARNAME=nna  & $
    ENDFOR                                                                                 & $
  pclose

;;  Plot fgh zooms of TIFP [FAC-{para,perp,anti} fluxes]
dir_inds       = [0L,3L,6L]
dir_midnms     = ['para','perp','anti']
fprefs         = 'THM-'+scu[0]+'_Bo-fgl_FAC-'+dir_midnms+'_'+units[0]+'_peeb_peib_psebf_psif_'
fnms_time      = file_name_times(sint_fgh,PREC=3)
fnme_time      = file_name_times(eint_fgh,PREC=3)
f_times        = fnms_time.F_TIME+'-'+STRMID(fnme_time.F_TIME,11L)
fmid           = 'TIFP_red-SLAMS_orange-HFA_purple-FB_'
nt             = N_ELEMENTS(f_times)
nd             = N_ELEMENTS(fprefs)
IF (tdate[0] EQ '2008-07-14') THEN tz_70_str = {T0:tr_slam_70, T1:tr_hfa__70, T2:tr_fb___70}
IF (tdate[0] EQ '2008-08-19') THEN tz_70_str = {T0:tr_slam_70, T1:tr_hfa__70, T2:tr_fb___70}
IF (tdate[0] EQ '2008-09-08') THEN tz_70_str = {T0:tr_slam_70,T1:tr_hfa__70,T2:tr_fb___70}
ntz            = N_TAGS(tz_70_str)
tz_cols        = [250,200, 30]
all_tpns       = [[eepad_spec_fac[dir_inds]],[iepad_spec_fac[dir_inds]],[sebfpd_specfac[dir_inds]],[sifpad_specfac[dir_inds]]]
fnames         = STRARR(nt,nd)
FOR k=0L, nd[0] - 1L DO fnames[*,k] = fprefs[k]+fmid[0]+f_times

FOR j=0L, nt[0] - 1L DO BEGIN                                                                $
  tra0   = [sint_fgh[j],eint_fgh[j]]                                                       & $
  IF (ABS(tra0[1] - tra0[0]) LT 10e1) THEN CONTINUE                                        & $
  FOR i=0L, nd[0] - 1L DO BEGIN                                                              $
    fname0         = fnames[j,i]                                                           & $
    nna            = [fglnm,REFORM(all_tpns[i,*])]                                         & $
    tplot,nna,TRANGE=tra0                                                                  & $
    FOR k=0L, ntz[0] - 1L DO BEGIN                                                           $
      tz_70          = tz_70_str.(k)                                                       & $
      nz             = N_ELEMENTS(tz_70[*,0])                                              & $
      FOR l=0L, nz[0] - 1L DO time_bar,REFORM(tz_70[l,*]),COLOR=tz_cols[k],VARNAME=nna     & $
    ENDFOR                                                                                 & $
    popen,fname0[0],_EXTRA=popen_str                                                       & $
      tplot,nna,TRANGE=tra0                                                                & $
      FOR k=0L, ntz[0] - 1L DO BEGIN                                                         $
        tz_70          = tz_70_str.(k)                                                     & $
        nz             = N_ELEMENTS(tz_70[*,0])                                            & $
        FOR l=0L, nz[0] - 1L DO time_bar,REFORM(tz_70[l,*]),COLOR=tz_cols[k],VARNAME=nna   & $
      ENDFOR                                                                               & $
    pclose


;;  Plot fgh zooms of TIFP [earthward-{para,perp,anti} fluxes]
dir_inds       = [0L,3L,6L]
dir_midnms     = ['para','perp','anti']
fprefs         = 'THM-'+scu[0]+'_Bo-fgl_earthward-'+dir_midnms+'_'+units[0]+'_peeb_peib_psebf_psif_'
fnms_time      = file_name_times(sint_fgh,PREC=3)
fnme_time      = file_name_times(eint_fgh,PREC=3)
f_times        = fnms_time.F_TIME+'-'+STRMID(fnme_time.F_TIME,11L)
fmid           = 'TIFP_examples_'
nt             = N_ELEMENTS(f_times)
nd             = N_ELEMENTS(fprefs)
tz_70_str      = {T0:tr_slam_70,T1:tr_hfa__70,T2:tr_fb___70}
all_tpns       = [[eepad_spec_tpn[dir_inds]],[iepad_spec_tpn[dir_inds]],[sebfpd_spec_tp[dir_inds]],[sifpad_spec_tp[dir_inds]]]
fnames         = STRARR(nt,nd)
FOR k=0L, nd[0] - 1L DO fnames[*,k] = fprefs[k]+fmid[0]+f_times

FOR j=0L, nt[0] - 1L DO BEGIN                                                                $
  tra0   = [sint_fgh[j],eint_fgh[j]]                                                       & $
  IF (ABS(tra0[1] - tra0[0]) LT 10e1) THEN CONTINUE                                        & $
  FOR i=0L, nd[0] - 1L DO BEGIN                                                              $
    fname0         = fnames[j,i]                                                           & $
    nna            = [fglnm,REFORM(all_tpns[i,*])]                                         & $
    tplot,nna,TRANGE=tra0                                                                  & $
    FOR k=0L, ntz[0] - 1L DO BEGIN                                                           $
      tz_70          = tz_70_str.(k)                                                       & $
      nz             = N_ELEMENTS(tz_70[*,0])                                              & $
      FOR l=0L, nz[0] - 1L DO time_bar,REFORM(tz_70[l,*]),COLOR=tz_cols[k],VARNAME=nna     & $
    ENDFOR                                                                                 & $
    popen,fname0[0],_EXTRA=popen_str                                                       & $
      tplot,nna,TRANGE=tra0                                                                & $
      FOR k=0L, ntz[0] - 1L DO BEGIN                                                         $
        tz_70          = tz_70_str.(k)                                                     & $
        nz             = N_ELEMENTS(tz_70[*,0])                                            & $
        FOR l=0L, nz[0] - 1L DO time_bar,REFORM(tz_70[l,*]),COLOR=tz_cols[k],VARNAME=nna   & $
      ENDFOR                                                                               & $
    pclose


;;  Plot ±70s zooms of TIFP [earthward-{para,perp,anti} fluxes]
dir_inds       = [0L,3L,6L]
dir_midnms     = ['para','perp','anti']
fprefs         = 'THM-'+scu[0]+'_Bo-fgl_earthward-'+dir_midnms+'_'+units[0]+'_peeb_peib_psebf_psif_'
fmid           = 'TIFP_examples_'
nd             = N_ELEMENTS(fprefs)
tz_70_str      = {T0:tr_slam_70,T1:tr_hfa__70,T2:tr_fb___70}
nt             = N_TAGS(tz_70_str)
tags           = TAG_NAMES(tz_70_str)
all_tpns       = [[eepad_spec_tpn[dir_inds]],[iepad_spec_tpn[dir_inds]],[sebfpd_spec_tp[dir_inds]],[sifpad_spec_tp[dir_inds]]]
DELVAR,fnames
;;  Define file names
FOR j=0L, nt[0] - 1L DO BEGIN                                                                $
  tras0   = tz_70_str.(j)                                                                  & $
  tra_st  = REFORM(tras0[*,0])                                                             & $
  tra_en  = REFORM(tras0[*,1])                                                             & $
  fn_st   = file_name_times(tra_st,PREC=3)                                                 & $
  fn_en   = file_name_times(tra_en,PREC=3)                                                 & $
  f_times = fn_st.F_TIME+'-'+STRMID(fn_en.F_TIME,11L)                                      & $
  fname0  = STRARR(N_ELEMENTS(f_times),nd)                                                 & $
  FOR k=0L, nd[0] - 1L DO fname0[*,k] = fprefs[k]+fmid[0]+f_times                          & $
  str_element,fnames,tags[j],fname0,/ADD_REPLACE

;;  Plot zooms
FOR j=0L, nt[0] - 1L DO BEGIN                                                                $
  tras0   = tz_70_str.(j)                                                                  & $
  ntr     = N_ELEMENTS(tras0[*,0])                                                         & $
  fname0  = fnames.(j)                                                                     & $
  FOR i=0L, nd[0] - 1L DO BEGIN                                                              $
    nna            = [fglnm,REFORM(all_tpns[i,*])]                                         & $
    FOR k=0L, ntr[0] - 1L DO BEGIN                                                           $
      fnam0        = fname0[k,i]                                                           & $
      tra0         = REFORM(tras0[k,*])                                                    & $
      tplot,nna,TRANGE=tra0                                                                & $
      popen,fnam0[0],_EXTRA=popen_str                                                      & $
        tplot,nna,TRANGE=tra0                                                              & $
      pclose




























