;;----------------------------------------------------------------------------------------
;;  Compile relevant routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Astronomical
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2016 AA values]
M_E            = 5.9722000d24             ;;  Earth's mass [kg, 2015 AA values]
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km

coord_ssl      = 'ssl'
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_mag      = 'mag'
start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
;;  Define dummy time range arrays for later use
dt_70          = [-1,1]*7d1
dt_140         = [-1,1]*14d1
dt_200         = [-1,1]*20d1
dt_250         = [-1,1]*25d1
dt_400         = [-1,1]*40d1
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
@$HOME/Desktop/swidl-0.1/IDL_Stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_themis_foreshock_eVDFs_batch.pro
MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE

;;  Plot FGM data
fgs_tpns       = scpref[0]+'fgs_'+[coord_mag[0],coord_gse[0]]
fgl_tpns       = scpref[0]+'fgl_'+[coord_mag[0],coord_gse[0]]
fgh_tpns       = scpref[0]+'fgh_'+[coord_mag[0],coord_gse[0]]
tra_all        = time_double(tr_00)
tplot,fgs_tpns,TRANGE=tra_all
tplot,fgl_tpns,TRANGE=tra_all
tplot,fgh_tpns,TRANGE=tra_all
;;  Insert NaNs at intervals for FGM data
all_fgs_tpns   = tnames(scpref[0]+'fgl_*')
all_fgl_tpns   = tnames(scpref[0]+'fgl_*')
all_fgh_tpns   = tnames(scpref[0]+'fgh_*')
t_insert_nan_at_interval_se,all_fgs_tpns,GAP_THRESH=4d0
t_insert_nan_at_interval_se,all_fgl_tpns,GAP_THRESH=1d0/3d0
t_insert_nan_at_interval_se,all_fgh_tpns,GAP_THRESH=1d0/100d0
;;  Insert NaNs at intervals for ESA Reduced data
esasuffx       = ['density','avgtemp','velocity_*','magt3','ptens']
t_insert_nan_at_interval_se,tnames(scpref[0]+'pe*r_'+esasuffx),GAP_THRESH=3.5d0
;;  Insert NaNs at intervals for ESA Burst data
esasuffx       = ['density','avgtemp','velocity_*','magt3','ptens']
t_insert_nan_at_interval_se,tnames(scpref[0]+'pe*b_'+esasuffx),GAP_THRESH=3.5d0
;;  Set defaults
lbw_tplot_set_defaults
tplot_options, 'XMARGIN',[20,15]      ;;  Change X-Margins slightly
;;  Determine fgh time intervals
get_data,fgh_tpns[0],DATA=temp,DLIM=dlim,LIM=lim
gap_thsh       = 1d-2
srate          = sample_rate(temp.X,GAP_THRESH=gap_thsh[0],/AVE,OUT_MED_AVG=sr_medavg)
med_sr         = sr_medavg[0]                     ;;  Median sample rate [sps]
med_dt         = 1d0/med_sr[0]                    ;;  Median sample period [s]
se_int         = t_interval_find(temp.X,GAP_THRESH=2d0*med_dt[0],/NAN)
sint_fgh       = temp.X[REFORM(se_int[*,0])]
eint_fgh       = temp.X[REFORM(se_int[*,1])]
;;  Some gaps on 2008-08-19 --> Merge intervals
IF (tdate[0] EQ '2008-08-19') THEN sint_fgh = TEMPORARY([sint_fgh[0],sint_fgh[3:6],sint_fgh[10]])
IF (tdate[0] EQ '2008-08-19') THEN eint_fgh = TEMPORARY([eint_fgh[2],eint_fgh[3:5],eint_fgh[9],eint_fgh[13]])
;;----------------------------------------------------------------------------------------
;;  Define times of TIFP
;;----------------------------------------------------------------------------------------
;;  Define center-times for specific TIFP
IF (tdate[0] EQ '2008-07-14') THEN t_slam_cent = tdate[0]+'/'+['13:16:26','13:19:30']
IF (tdate[0] EQ '2008-07-14') THEN t_hfa__cent = tdate[0]+'/'+['15:21:00','22:37:22']
IF (tdate[0] EQ '2008-07-14') THEN t_fb___cent = tdate[0]+'/'+['20:03:21','21:55:45','21:58:10']

IF (tdate[0] EQ '2008-08-19') THEN t_slam_cent = tdate[0]+'/'+['21:48:55','21:53:45','22:17:35','22:18:30','22:22:30','22:37:45','22:42:48']
IF (tdate[0] EQ '2008-08-19') THEN t_hfa__cent = tdate[0]+'/'+['12:50:57','21:46:17','22:41:00']
IF (tdate[0] EQ '2008-08-19') THEN t_fb___cent = tdate[0]+'/'+['20:43:35','21:51:45']

IF (tdate[0] EQ '2008-09-08') THEN t_slam_cent = tdate[0]+'/'+['17:28:23','20:24:50','20:36:11','21:12:24','21:15:33']
IF (tdate[0] EQ '2008-09-08') THEN t_hfa__cent = tdate[0]+'/'+['17:01:41','19:13:57','20:26:44']
IF (tdate[0] EQ '2008-09-08') THEN t_fb___cent = tdate[0]+'/20:25:22'

;;  Show location of SLAMS, HFAs, and FBs
time_bar,t_slam_cent,COLOR=250
time_bar,t_hfa__cent,COLOR=200
time_bar,t_fb___cent,COLOR= 30

;;  Define several time windows
FOR j=0L, N_ELEMENTS(t_slam_cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_slam_cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_slam_70  = unix_ra[0,*] ELSE tr_slam_70  = [tr_slam_70, unix_ra[0,*]]

FOR j=0L, N_ELEMENTS(t_hfa__cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_hfa__cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_hfa__70  = unix_ra[0,*] ELSE tr_hfa__70  = [tr_hfa__70, unix_ra[0,*]]

FOR j=0L, N_ELEMENTS(t_fb___cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_fb___cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_fb___70  = unix_ra[0,*] ELSE tr_fb___70  = [tr_fb___70, unix_ra[0,*]]

;;----------------------------------------------------------------------------------------
;;  Define relevant time ranges
;;----------------------------------------------------------------------------------------
;;  Define time range to use for foreshock overviews
IF (tdate[0] EQ '2008-07-14') THEN tr_bs_cal = time_double(tdate[0]+'/'+['11:52:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-08-19') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:00:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-09-08') THEN tr_bs_cal = time_double(tdate[0]+'/'+['16:30:00','21:32:00'])
IF (tdate[0] EQ '2008-07-14') THEN tra_overv = tr_bs_cal + [-1,1]*6d1*1d1                 ;;  expand by ±10 mins
IF (tdate[0] EQ '2008-08-19') THEN tra_overv = tr_bs_cal + [1,0e0]*4d1*6d1                ;;  shrink by 40 minutes at start
IF (tdate[0] EQ '2008-09-08') THEN tra_overv = tr_bs_cal
;;  Plot parameters to average
thm__magf_tpn  = fgl_tpns[1]
thm_vbulk_tpn  = scpref[0]+'peir_velocity_'+coord_gse[0]
thm_idens_tpn  = scpref[0]+'peir_density'
thm_itemp_tpn  = scpref[0]+'peir_avgtemp'
thm_etemp_tpn  = scpref[0]+'peer_avgtemp'
nna            = [fgl_tpns,thm_idens_tpn[0],thm_vbulk_tpn[0],thm_itemp_tpn[0],thm_etemp_tpn[0]]
  tplot,nna,TRANGE=tra_overv
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
;;----------------------------------------------------------------------------------------
;;  Calculate relativistic gyroradii
;;----------------------------------------------------------------------------------------
thm__magf_tpn  = fgl_tpns[0]
;;  Get Bo [nT, MAG]
get_data,thm__magf_tpn[0],DATA=t_bmag
;;  Define parameters
bo__t          = t_bmag.X
bo__v          = t_bmag.Y

;;  Define SST energies [eV] to use for relativistic gyroradii
IF (tdate[0] EQ '2008-07-14') THEN sste_ener = [31d0,41d0,52d0,66d0,93d0,139d0]*1d3
IF (tdate[0] EQ '2008-08-19') THEN sste_ener = [31d0,41d0,52d0,66d0,93d0,139d0,204d0,293d0]*1d3
IF (tdate[0] EQ '2008-09-08') THEN sste_ener = [31d0,41d0,52d0,66d0,93d0,139d0,204d0]*1d3

IF (tdate[0] EQ '2008-07-14') THEN ssti_ener = [38d0,49d0,63d0,75d0,103d0,152d0,214d0,303d0,427d0]*1d3
IF (tdate[0] EQ '2008-08-19') THEN ssti_ener = [38d0,49d0,62d0,75d0,102d0,152d0,213d0,302d0,427d0,659d0]*1d3
IF (tdate[0] EQ '2008-09-08') THEN ssti_ener = [37d0,48d0,62d0,74d0,102d0,151d0,213d0,302d0,426d0]*1d3

ne_sste        = N_ELEMENTS(sste_ener)
ne_ssti        = N_ELEMENTS(ssti_ener)
nv_bmag        = N_ELEMENTS(bo__t)
;;  Define dummy arrays to fill
elec_eners     = REPLICATE(d,nv_bmag[0],ne_sste[0])          ;;  Electron energies [eV]
prot_eners     = REPLICATE(d,nv_bmag[0],ne_ssti[0])          ;;  Proton energies [eV]
;;  Fill arrays
FOR j=0L, ne_sste[0] - 1L DO elec_eners[*,j] = sste_ener[j]
FOR j=0L, ne_ssti[0] - 1L DO prot_eners[*,j] = ssti_ener[j]
;;  Define dummy arrays to fill
elec_gyror     = REPLICATE(d,nv_bmag[0],ne_sste[0])          ;;  Electron gyroradii [km]
prot_gyror     = REPLICATE(d,nv_bmag[0],ne_ssti[0])          ;;  Proton gyroradii [km]
;;  Fill arrays
bo             = bo__v
FOR j=0L, ne_sste[0] - 1L DO BEGIN                                $
  eners = REFORM(elec_eners[*,j])                               & $
  rhocs = lbw_gyroradius(bo,eners,/ELECTRON)                    & $
  elec_gyror[*,j] = rhocs

FOR j=0L, ne_ssti[0] - 1L DO BEGIN                                $
  eners = REFORM(prot_eners[*,j])                               & $
  rhocs = lbw_gyroradius(bo,eners,/PROTON)                      & $
  prot_gyror[*,j] = rhocs

;;  Define TPLOT structures
e_struc        = {X:bo__t,Y:elec_gyror,V:elec_eners}
p_struc        = {X:bo__t,Y:prot_gyror,V:prot_eners}
;;  Define TPLOT labels and colors
sste_labs      = STRTRIM(STRING(LONG(sste_ener*1d-3),FORMAT='(I)'),2L)+' keV'
ssti_labs      = STRTRIM(STRING(LONG(ssti_ener*1d-3),FORMAT='(I)'),2L)+' keV'
sste_cols      = LINDGEN(ne_sste[0])*(250L - 30L)/(ne_sste[0] - 1L) + 30L
ssti_cols      = LINDGEN(ne_ssti[0])*(250L - 30L)/(ne_ssti[0] - 1L) + 30L
;;  Define TPLOT names and YTITLEs
rho_ce_tpn     = scpref[0]+'fgl_sste_gyrorad'
rho_cp_tpn     = scpref[0]+'fgl_ssti_gyrorad'
rho_ce_yttl    = 'Rce [km]'
rho_cp_yttl    = 'Rcp [km]'
rho_ce_ysub    = '[fgl, SSTe]'
rho_cp_ysub    = '[fgl, SSTi]'
;;  Send to TPLOT
store_data,rho_ce_tpn[0],DATA=e_struc,LIM=def__lim
store_data,rho_cp_tpn[0],DATA=p_struc,LIM=def__lim
;;  Alter options
options,rho_ce_tpn[0],YTITLE=rho_ce_yttl[0],YSUBTITLE=rho_ce_ysub[0],YLOG=1,SPEC=0,LABELS=sste_labs,COLORS=sste_cols,/DEF
options,rho_cp_tpn[0],YTITLE=rho_cp_yttl[0],YSUBTITLE=rho_cp_ysub[0],YLOG=1,SPEC=0,LABELS=ssti_labs,COLORS=ssti_cols,/DEF
;;----------------------------------------------------------------------------------------
;;  Plot stacked gyroradii [zooms of TIFP]
;;----------------------------------------------------------------------------------------
popen_str      = {PORT:1,UNITS:'inches',XSIZE:8.5,YSIZE:11.}
scu            = STRUPCASE(sc[0])
;;  Plot fgh zooms of TIFP [OMNI fluxes]
fpref          = 'THM-'+scu[0]+'_Bo-fgl_psebf-psif-gyroradii_'
fmid           = 'TIFP-centers_red-SLAMS_orange-HFA_purple-FB_fgh-zooms_'
fnms_time      = file_name_times(sint_fgh,PREC=3)
fnme_time      = file_name_times(eint_fgh,PREC=3)
f_times        = fnms_time.F_TIME+'-'+STRMID(fnme_time.F_TIME,11L)
fnames         = fpref[0]+fmid[0]+f_times
nf             = N_ELEMENTS(fnames)
nna            = [fgl_tpns,rho_ce_tpn[0],rho_cp_tpn[0]]
IF (tdate[0] EQ '2008-07-14') THEN tz_70_str = {T0:tr_slam_70, T1:tr_hfa__70, T2:tr_fb___70}
IF (tdate[0] EQ '2008-08-19') THEN tz_70_str = {T0:tr_slam_70, T1:tr_hfa__70, T2:tr_fb___70}
IF (tdate[0] EQ '2008-09-08') THEN tz_70_str = {T0:tr_slam_70, T1:tr_hfa__70, T2:tr_fb___70}
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



;;  Plot ±70s zooms of TIFP [OMNI fluxes]
fpref          = 'THM-'+scu[0]+'_Bo-fgl-fgh_psebf-psif-gyroradii_'
fmid           = 'TIFP-centers_red-SLAMS_orange-HFA_purple-FB_70s-zooms_'
nf             = N_ELEMENTS(fnames)
nna            = [fgl_tpns[0],fgh_tpns,rho_ce_tpn[0],rho_cp_tpn[0]]
IF (tdate[0] EQ '2008-07-14') THEN tz_70_str = {T0:tr_slam_70, T1:tr_hfa__70, T2:tr_fb___70}
IF (tdate[0] EQ '2008-08-19') THEN tz_70_str = {T0:tr_slam_70, T1:tr_hfa__70, T2:tr_fb___70}
IF (tdate[0] EQ '2008-09-08') THEN tz_70_str = {T0:tr_slam_70, T1:tr_hfa__70, T2:tr_fb___70}
nt             = N_TAGS(tz_70_str)
tags           = TAG_NAMES(tz_70_str)
tz_cols        = [250,200, 30]
;;  Define file names
DELVAR,fnames
FOR j=0L, nt[0] - 1L DO BEGIN                                                                $
  tras0   = tz_70_str.(j)                                                                  & $
  tra_st  = REFORM(tras0[*,0])                                                             & $
  tra_en  = REFORM(tras0[*,1])                                                             & $
  fn_st   = file_name_times(tra_st,PREC=3)                                                 & $
  fn_en   = file_name_times(tra_en,PREC=3)                                                 & $
  f_times = fn_st.F_TIME+'-'+STRMID(fn_en.F_TIME,11L)                                      & $
  fname0  = fpref[0]+fmid[0]+f_times                                                       & $
  str_element,fnames,tags[j],fname0,/ADD_REPLACE

;;  Plot zooms
FOR j=0L, nt[0] - 1L DO BEGIN                                                                $
  tras0   = tz_70_str.(j)                                                                  & $
  ntr     = N_ELEMENTS(tras0[*,0])                                                         & $
  fname0  = fnames.(j)                                                                     & $
  FOR k=0L, ntr[0] - 1L DO BEGIN                                                             $
    fnam0        = fname0[k]                                                               & $
    tra0         = REFORM(tras0[k,*])                                                      & $
    tplot,nna,TRANGE=tra0                                                                  & $
    time_bar,t_slam_cent,COLOR=250                                                         & $
    time_bar,t_hfa__cent,COLOR=200                                                         & $
    time_bar,t_fb___cent,COLOR= 30                                                         & $
    popen,fnam0[0],_EXTRA=popen_str                                                        & $
      tplot,nna,TRANGE=tra0                                                                & $
      time_bar,t_slam_cent,COLOR=250                                                       & $
      time_bar,t_hfa__cent,COLOR=200                                                       & $
      time_bar,t_fb___cent,COLOR= 30                                                       & $
    pclose























