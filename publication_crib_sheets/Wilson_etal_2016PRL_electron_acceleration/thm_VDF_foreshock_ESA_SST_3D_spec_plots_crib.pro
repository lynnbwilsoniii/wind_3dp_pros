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
no_load_vdfs   = 0b                    ;;  --> do load particle VDFs
;no_load_vdfs   = 1b                    ;;  --> do NOT load particle VDFs

ex_start       = SYSTIME(1)            ;;  Time the execution of all events within
@$HOME/Desktop/swidl-0.1/IDL_Stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_themis_foreshock_eVDFs_all_data_batch.pro
MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;;  Default to entire day
tr_00          = tdate[0]+'/'+['00:00:00.000','23:59:59.999']
;;  Define time range to use for foreshock overviews
IF (tdate[0] EQ '2008-07-14') THEN tr_bs_cal = time_double(tdate[0]+'/'+['11:52:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-08-19') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:00:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-09-08') THEN tr_bs_cal = time_double(tdate[0]+'/'+['16:30:00','21:32:00'])
IF (tdate[0] EQ '2008-09-16') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:20:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-07-14') THEN tra_overv = tr_bs_cal + [-1,1]*6d1*1d1                 ;;  expand by ±10 mins
IF (tdate[0] EQ '2008-08-19') THEN tra_overv = tr_bs_cal + [1,0e0]*4d1*6d1                ;;  shrink by 40 minutes at start
IF (tdate[0] EQ '2008-09-08') THEN tra_overv = tr_bs_cal
IF (tdate[0] EQ '2008-09-16') THEN tra_overv = tr_bs_cal
;;  Define time of last (i.e., crossing at largest distance from Earth) bow shock crossings
IF (tdate[0] EQ '2008-07-14') THEN t_bs_last = time_double(tdate[0]+'/'+'12:32:18')
IF (tdate[0] EQ '2008-08-19') THEN t_bs_last = time_double(tdate[0]+'/'+'22:43:42')
IF (tdate[0] EQ '2008-09-08') THEN t_bs_last = time_double(tdate[0]+'/'+'21:18:10')
IF (tdate[0] EQ '2008-09-16') THEN t_bs_last = time_double(tdate[0]+'/'+'18:08:50')
;;  Define center-times for specific TIFP
IF (tdate[0] EQ '2008-07-14') THEN t_slam_cent = tdate[0]+'/'+['13:16:26','13:19:30']
IF (tdate[0] EQ '2008-07-14') THEN t_hfa__cent = tdate[0]+'/'+['15:21:00','22:37:22']
IF (tdate[0] EQ '2008-07-14') THEN t_fb___cent = tdate[0]+'/'+['20:03:21','21:55:45','21:58:10']

IF (tdate[0] EQ '2008-08-19') THEN t_slam_cent = tdate[0]+'/'+['21:48:55','21:53:45','22:17:35','22:18:30','22:22:30','22:37:45','22:42:48']
IF (tdate[0] EQ '2008-08-19') THEN t_hfa__cent = tdate[0]+'/'+['12:50:57','21:46:17','22:41:00']
IF (tdate[0] EQ '2008-08-19') THEN t_fb___cent = tdate[0]+'/'+['20:43:35','21:51:45']

IF (tdate[0] EQ '2008-09-08') THEN t_slam_cent = tdate[0]+'/'+['17:28:23','20:24:50','20:36:11','21:12:24','21:15:33']
IF (tdate[0] EQ '2008-09-08') THEN t_hfa__cent = tdate[0]+'/'+['17:01:41','19:13:57','20:26:44']
IF (tdate[0] EQ '2008-09-08') THEN t_fb___cent = tdate[0]+'/'+['20:25:22']

IF (tdate[0] EQ '2008-09-16') THEN t_slam_cent = tdate[0]+'/'+['00:00:00']
IF (tdate[0] EQ '2008-09-16') THEN t_hfa__cent = tdate[0]+'/'+['17:26:45']
IF (tdate[0] EQ '2008-09-16') THEN t_fb___cent = tdate[0]+'/'+['17:46:13']

tlimit,tra_overv

;;  Plot FGM data
tplot,fgs_tpns,TRANGE=tra_overv
tplot,fgl_tpns,TRANGE=tra_overv
tplot,fgh_tpns,TRANGE=tra_overv
;;  Show location of SLAMS, HFAs, and FBs
time_bar,t_slam_cent,COLOR=250
time_bar,t_hfa__cent,COLOR=200
time_bar,t_fb___cent,COLOR= 30
time_bar,  t_bs_last,COLOR=100

;;----------------------------------------------------------------------------------------
;;  Define TIFP specific information
;;----------------------------------------------------------------------------------------
IF (tdate[0] EQ '2008-07-14') THEN eee_slam_yn = [0b,0b]
IF (tdate[0] EQ '2008-07-14') THEN eee_hfa__yn = [0b,0b]
IF (tdate[0] EQ '2008-07-14') THEN eee_fb___yn = [0b,1b,1b]

IF (tdate[0] EQ '2008-08-19') THEN eee_slam_yn = [1b,1b,0b,1b,1b,0b,0b]
IF (tdate[0] EQ '2008-08-19') THEN eee_hfa__yn = [1b,0b,0b]
IF (tdate[0] EQ '2008-08-19') THEN eee_fb___yn = [0b,1b]

IF (tdate[0] EQ '2008-09-08') THEN eee_slam_yn = [0b,1b,0b,0b,0b]
IF (tdate[0] EQ '2008-09-08') THEN eee_hfa__yn = [1b,0b,0b]
IF (tdate[0] EQ '2008-09-08') THEN eee_fb___yn = [1b]

IF (tdate[0] EQ '2008-09-16') THEN eee_slam_yn = [0b]
IF (tdate[0] EQ '2008-09-16') THEN eee_hfa__yn = [0b]
IF (tdate[0] EQ '2008-09-16') THEN eee_fb___yn = [0b]
;;----------------------------------------------------------------------------------------
;;  Define several time windows
;;----------------------------------------------------------------------------------------
FOR j=0L, N_ELEMENTS(t_slam_cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_slam_cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_slam_70  = unix_ra[0,*] ELSE tr_slam_70  = [tr_slam_70, unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_slam_140 = unix_ra[1,*] ELSE tr_slam_140 = [tr_slam_140,unix_ra[1,*]]  & $
  IF (j EQ 0) THEN tr_slam_200 = unix_ra[2,*] ELSE tr_slam_200 = [tr_slam_200,unix_ra[2,*]]  & $
  IF (j EQ 0) THEN tr_slam_250 = unix_ra[3,*] ELSE tr_slam_250 = [tr_slam_250,unix_ra[3,*]]  & $
  IF (j EQ 0) THEN tr_slam_400 = unix_ra[4,*] ELSE tr_slam_400 = [tr_slam_400,unix_ra[4,*]]

FOR j=0L, N_ELEMENTS(t_hfa__cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_hfa__cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_hfa__70  = unix_ra[0,*] ELSE tr_hfa__70  = [tr_hfa__70, unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_hfa__140 = unix_ra[1,*] ELSE tr_hfa__140 = [tr_hfa__140,unix_ra[1,*]]  & $
  IF (j EQ 0) THEN tr_hfa__200 = unix_ra[2,*] ELSE tr_hfa__200 = [tr_hfa__200,unix_ra[2,*]]  & $
  IF (j EQ 0) THEN tr_hfa__250 = unix_ra[3,*] ELSE tr_hfa__250 = [tr_hfa__250,unix_ra[3,*]]  & $
  IF (j EQ 0) THEN tr_hfa__400 = unix_ra[4,*] ELSE tr_hfa__400 = [tr_hfa__400,unix_ra[4,*]]

FOR j=0L, N_ELEMENTS(t_fb___cent) - 1L DO BEGIN                                                $
  unix_0   = time_double(t_fb___cent[j])                                                     & $
  unix_ras = unix_0[0] + [dt_70[0],dt_140[0],dt_200[0],dt_250[0],dt_400[0]]                  & $
  unix_rae = unix_0[0] + [dt_70[1],dt_140[1],dt_200[1],dt_250[1],dt_400[1]]                  & $
  unix_ra  = [[unix_ras],[unix_rae]]                                                         & $
  IF (j EQ 0) THEN tr_fb___70  = unix_ra[0,*] ELSE tr_fb___70  = [tr_fb___70, unix_ra[0,*]]  & $
  IF (j EQ 0) THEN tr_fb___140 = unix_ra[1,*] ELSE tr_fb___140 = [tr_fb___140,unix_ra[1,*]]  & $
  IF (j EQ 0) THEN tr_fb___200 = unix_ra[2,*] ELSE tr_fb___200 = [tr_fb___200,unix_ra[2,*]]  & $
  IF (j EQ 0) THEN tr_fb___250 = unix_ra[3,*] ELSE tr_fb___250 = [tr_fb___250,unix_ra[3,*]]  & $
  IF (j EQ 0) THEN tr_fb___400 = unix_ra[4,*] ELSE tr_fb___400 = [tr_fb___400,unix_ra[4,*]]
;;----------------------------------------------------------------------------------------
;;  Define relevant time ranges
;;----------------------------------------------------------------------------------------
;;  Get example structures
dat0           = dat_egse
dat1           = dat_seb
;;  Sort structures by time
sp             = SORT(dat0.TIME)
dat0           = TEMPORARY(dat0[sp])
sp             = SORT(dat1.TIME)
dat1           = TEMPORARY(dat1[sp])
;;  Define start/end times for EESA and SSTe VDFs
t_st_esa       = dat0.TIME
t_en_esa       = dat0.END_TIME
t_st_sst       = dat1.TIME
t_en_sst       = dat1.END_TIME
;;  1st, find intervals
srate_esa      = sample_rate(t_st_esa,GAP_THRESH=6d0,/AVE)
srate_sst      = sample_rate(t_st_sst,GAP_THRESH=6d0,/AVE)
se_int_esa     = t_interval_find(t_st_esa,GAP_THRESH=2d0/srate_esa[0],/NAN)
se_int_sst     = t_interval_find(t_st_sst,GAP_THRESH=2d0/srate_sst[0],/NAN)
;;  Keep only those structures that have matching times
st_esa_ft      = FLOOR((t_st_esa MOD 864d2))
st_sst_ft      = FLOOR((t_st_sst MOD 864d2))
st_esa_ct      = CEIL((t_st_esa MOD 864d2))
st_sst_ct      = CEIL((t_st_sst MOD 864d2))
g_esa_sst_ff   = VALUE_LOCATE(st_esa_ft,st_sst_ft)   ;;  matching elements in ESA at SST times
g_esa_sst_cc   = VALUE_LOCATE(st_esa_ct,st_sst_ct)   ;;  " "
g_esa_sst_fc   = VALUE_LOCATE(st_esa_ft,st_sst_ct)   ;;  " "
g_esa_sst_cf   = VALUE_LOCATE(st_esa_ct,st_sst_ft)   ;;  " "

diff_ff        = ABS(t_st_esa[g_esa_sst_ff] - t_st_sst)
diff_cc        = ABS(t_st_esa[g_esa_sst_cc] - t_st_sst)
diff_fc        = ABS(t_st_esa[g_esa_sst_fc] - t_st_sst)
diff_cf        = ABS(t_st_esa[g_esa_sst_cf] - t_st_sst)

bad_ff         = WHERE(diff_ff GE 1,bd_ff,COMPLEMENT=good_ff,NCOMPLEMENT=gd_ff)
bad_cc         = WHERE(diff_cc GE 1,bd_cc,COMPLEMENT=good_cc,NCOMPLEMENT=gd_cc)
bad_fc         = WHERE(diff_fc GE 1,bd_fc,COMPLEMENT=good_fc,NCOMPLEMENT=gd_fc)
bad_cf         = WHERE(diff_cf GE 1,bd_cf,COMPLEMENT=good_cf,NCOMPLEMENT=gd_cf)
PRINT,';;',bd_ff,gd_ff,bd_cc,gd_cc,bd_fc,gd_fc,bd_cf,gd_cf
;;          36        1302          36        1302          36        1302        1331           7

bad_3dt_ff     = WHERE(FLOOR(diff_ff) LE 3 AND FLOOR(diff_ff) GT 1,bd_3dt_ff,COMPLEMENT=good_3dt_ff,NCOMPLEMENT=gd_3dt_ff)
bad_3dt_cc     = WHERE(FLOOR(diff_cc) LE 3 AND FLOOR(diff_cc) GT 1,bd_3dt_cc,COMPLEMENT=good_3dt_cc,NCOMPLEMENT=gd_3dt_cc)
bad_3dt_fc     = WHERE(FLOOR(diff_fc) LE 3 AND FLOOR(diff_fc) GT 1,bd_3dt_fc,COMPLEMENT=good_3dt_fc,NCOMPLEMENT=gd_3dt_fc)
bad_3dt_cf     = WHERE(FLOOR(diff_cf) LE 3 AND FLOOR(diff_cf) GT 1,bd_3dt_cf,COMPLEMENT=good_3dt_cf,NCOMPLEMENT=gd_3dt_cf)
PRINT,';;',bd_3dt_ff,gd_3dt_ff,bd_3dt_cc,gd_3dt_cc,bd_3dt_fc,gd_3dt_fc,bd_3dt_cf,gd_3dt_cf
;;          12        1326          12        1326          12        1326        1304          34

;;  Define good indices
gind_e_at_s    = g_esa_sst_ff[good_ff]
gind_s_at_e    = good_ff
;;  Redefine data structures
dat00          = dat0[gind_e_at_s]
dat11          = dat1[gind_s_at_e]
;;  Redefine start/end times
t_st_esa       = dat00.TIME
t_en_esa       = dat00.END_TIME
t_st_sst       = dat11.TIME
t_en_sst       = dat11.END_TIME
;;  Define structure containing logic [TRUE = energetic electron enhancement observed]
e_enhanced_str = {T0:eee_slam_yn,T1:eee_hfa__yn,T2:eee_fb___yn}
;;  Define ±250 s window about each TIFP type
tz_250_str     = {T0:tr_slam_250,T1:tr_hfa__250,T2:tr_fb___250}
nt             = N_TAGS(tz_250_str)
tags           = TAG_NAMES(tz_250_str)
DELVAR,trans_by_tifp,gind_esa,gind_sst
;;  Define relevant TRANGEs
FOR j=0L, nt[0] - 1L DO BEGIN                                                 $
  tras0   = tz_250_str.(j)                                                  & $
  logic   = e_enhanced_str.(j)                                              & $
  good    = WHERE(logic,gd)                                                 & $
  IF (gd GT 0) THEN gtras = tras0[good,*] ELSE gtras = [-1d0,-1d0]          & $
  str_element,trans_by_tifp,tags[j],gtras,/ADD_REPLACE                      & $
  ginde   = -1                                                              & $
  ginds   = -1                                                              & $
  IF (gd EQ 0) THEN str_element,gind_esa,tags[j],ginde,/ADD_REPLACE         & $
  IF (gd EQ 0) THEN str_element,gind_sst,tags[j],ginds,/ADD_REPLACE         & $
  IF (gd EQ 0) THEN CONTINUE                                                & $
  FOR k=0L, gd - 1L DO BEGIN                                                  $
    kstr  = 'K'+STRTRIM(STRING(k[0],FORMAT='(I)'),2)                        & $
    tra1  = REFORM(gtras[k,*])                                              & $
    test0 = (t_st_esa GE tra1[0]) AND (t_en_esa LE tra1[1])                 & $
    test1 = (t_st_sst GE tra1[0]) AND (t_en_sst LE tra1[1])                 & $
    good0 = WHERE(test0,gd0)                                                & $
    good1 = WHERE(test1,gd1)                                                & $
    str_element,ginde,kstr[0],good0,/ADD_REPLACE                            & $
    str_element,ginds,kstr[0],good1,/ADD_REPLACE                            & $
  ENDFOR                                                                    & $
  str_element,gind_esa,tags[j],ginde,/ADD_REPLACE                           & $
  str_element,gind_sst,tags[j],ginds,/ADD_REPLACE

;;  Get only unique indices
DELVAR,gind_eall,gind_sall
FOR j=0L, nt[0] - 1L DO BEGIN                                                           $
  ginde   = gind_esa.(j)                                                              & $
  ginds   = gind_sst.(j)                                                              & $
  gd      = N_TAGS(ginde)                                                             & $
  FOR k=0L, gd - 1L DO BEGIN                                                            $
    testes = [(N_ELEMENTS(gind_eall) EQ 0),(N_ELEMENTS(gind_sall) EQ 0)]              & $
    IF (testes[0]) THEN gind_eall = ginde.(k) ELSE gind_eall = [gind_eall,ginde.(k)]  & $
    IF (testes[1]) THEN gind_sall = ginds.(k) ELSE gind_sall = [gind_sall,ginds.(k)]
HELP,gind_eall,gind_sall

;;  1st sort
sp             = SORT(gind_eall)
gind_eall      = TEMPORARY(gind_eall[sp])
sp             = SORT(gind_sall)
gind_sall      = TEMPORARY(gind_sall[sp])
;;  Keep only unique indices
unq            = UNIQ(gind_eall,SORT(gind_eall))
gind_eall      = TEMPORARY(gind_eall[unq])
unq            = UNIQ(gind_sall,SORT(gind_sall))
gind_sall      = TEMPORARY(gind_sall[unq])
HELP,gind_eall,gind_sall
;;----------------------------------------------------------------------------------------
;;  Setup for plotting individual spectra
;;----------------------------------------------------------------------------------------
;;  Define the units in which to plot data
;units          = 'flux'
;units          = 'eflux'
units          = 'df'
IF (units[0] EQ 'flux') THEN yran_esa = [1e-1,1e6]
IF (units[0] EQ 'flux') THEN yran_sst = [1e-4,2e-1]
IF (units[0] EQ   'df') THEN yran_esa = [1e-19,2e-12]
IF (units[0] EQ   'df') THEN yran_sst = [1e-26,1e-20]
xran_esa       = [5e1,2e4]                   ;;  0.05-20 keV
xran_sst       = [1e4,4e5]                   ;;  10-400 keV
;;  Setup options
lim0           = {XSTYLE:1,YSTYLE:1,XMINOR:9,YMINOR:9,XMARGIN:[10,10],YMARGIN:[5,5],$
                  XLOG:1,YLOG:1}
extract_tags,lime_str,lim0
extract_tags,lims_str,lim0
str_element,lime_str, 'XRANGE',     xran_esa,/ADD_REPLACE
str_element,lime_str, 'YRANGE',     yran_esa,/ADD_REPLACE
str_element,lims_str, 'XRANGE',     xran_sst,/ADD_REPLACE
str_element,lims_str, 'YRANGE',     yran_sst,/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Plot individual spectra
;;----------------------------------------------------------------------------------------
;;  Plot in FACs
sc_frame       = 0b
cut_ran        = 22.5d0
p_angle        = 1b
sundir         = 0b
vec            = 0b
exsuffx        = 'BVec'
leg_sffx       = '(Bo)'
.compile plot_esa_sst_combined_spec3d.pro
dat0_e         = dat00[gind_eall]
dat0_s         = dat11[gind_sall]
imax           = N_ELEMENTS(dat0_e) < N_ELEMENTS(dat0_s)
FOR ii=0L, imax[0] - 1L DO BEGIN                                                          $
  tdate_sw       = dat0_e[ii]                                                           & $
  tdats_sw       = dat0_s[ii]                                                           & $
  p_angle        = 1b                                                                   & $
  sundir         = 0b                                                                   & $
  vec            = 0b                                                                   & $
  plot_esa_sst_combined_spec3d,tdate_sw,tdats_sw,LIM_ESA=lime_str,LIM_SST=lims_str,       $
                               ESA_ERAN=xran_esa,SST_ERAN=xran_sst,                       $
                               SC_FRAME=sc_frame,CUT_RAN=cut_ran,P_ANGLE=p_angle,         $
                               SUNDIR=sundir,VECTOR=vec,UNITS=units,EX_SUFFX=exsuffx,     $
                               LEG_SFFX=leg_sffx


;;  Plot in earthward-aligned coordinates (EACs)
;;  Define Earth direction for each distribution
sc_frame       = 0b
cut_ran        = 22.5d0
p_angle        = 1b
sundir         = 0b
vec            = 0b
imax           = MIN([gd0[0],gd1[0]],/NAN)
exsuffx        = 'EarthDir'
leg_sffx       = '(Earth Dir.)'
.compile plot_esa_sst_combined_spec3d.pro
;;  Replace MAGF vector with SC-to-Earth vector in each VDF
evec_e         = REFORM(avg_eesa_earth[gind_e_at_s,*])
evec_s         = REFORM(avg_essb_earth[gind_s_at_e,*])
dat0_e         = dat00[gind_eall]
dat0_s         = dat11[gind_sall]
dat0_e.MAGF    = TRANSPOSE(evec_e[gind_eall,*])
dat0_s.MAGF    = TRANSPOSE(evec_s[gind_sall,*])
imax           = N_ELEMENTS(dat0_e) < N_ELEMENTS(dat0_s)
FOR ii=0L, imax[0] - 1L DO BEGIN                                                          $
  tdate_sw       = dat0_e[ii]                                                           & $
  tdats_sw       = dat0_s[ii]                                                           & $
  p_angle        = 1b                                                                   & $
  sundir         = 0b                                                                   & $
  vec            = 0b                                                                   & $
  plot_esa_sst_combined_spec3d,tdate_sw,tdats_sw,LIM_ESA=lime_str,LIM_SST=lims_str,       $
                               ESA_ERAN=xran_esa,SST_ERAN=xran_sst,                       $
                               SC_FRAME=sc_frame,CUT_RAN=cut_ran,P_ANGLE=p_angle,         $
                               SUNDIR=sundir,VECTOR=vec,UNITS=units,EX_SUFFX=exsuffx,     $
                               LEG_SFFX=leg_sffx




































;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot in FACs
sc_frame       = 0b
cut_ran        = 22.5d0
p_angle        = 1b
sundir         = 0b
vec            = 0b
exsuffx        = 'BVec'
leg_sffx       = '(Bo)'
.compile $HOME/Desktop/temp_idl/temp_plot_esa_sst_combined_spec3d.pro

FOR j=0L, nt[0] - 1L DO BEGIN                                                                 $
  logic   = e_enhanced_str.(j)                                                              & $
  good    = WHERE(logic,gd)                                                                 & $
  IF (gd EQ 0) THEN CONTINUE                                                                & $
  ginde   = gind_esa.(j)                                                                    & $
  ginds   = gind_sst.(j)                                                                    & $
  gd      = N_TAGS(ginde)                                                                   & $
  FOR k=0L, gd - 1L DO BEGIN                                                                  $
    dat0_e = dat00[ginde.(k)]                                                               & $
    dat0_s = dat11[ginds.(k)]                                                               & $
    imax   = N_ELEMENTS(dat0_e) < N_ELEMENTS(dat0_s)                                        & $
    FOR ii=0L, imax[0] - 1L DO BEGIN                                                          $
      tdate_sw       = dat0_e[ii]                                                           & $
      tdats_sw       = dat0_s[ii]                                                           & $
      p_angle        = 1b                                                                   & $
      sundir         = 0b                                                                   & $
      vec            = 0b                                                                   & $
      temp_plot_esa_sst_combined_spec3d,tdate_sw,tdats_sw,LIM_ESA=lime_str,LIM_SST=lims_str,  $
                                        ESA_ERAN=xran_esa,SST_ERAN=xran_sst,                  $
                                        SC_FRAME=sc_frame,CUT_RAN=cut_ran,P_ANGLE=p_angle,    $
                                        SUNDIR=sundir,VECTOR=vec,UNITS=units,EX_SUFFX=exsuffx,$
                                        LEG_SFFX=leg_sffx

st_esa_ft      = FLOOR((t_st_esa MOD 864d2)*1d1)
st_sst_ft      = FLOOR((t_st_sst MOD 864d2)*1d1)
st_esa_ct      = CEIL((t_st_esa MOD 864d2)*1d1)
st_sst_ct      = CEIL((t_st_sst MOD 864d2)*1d1)
g_esa_sst_ff   = VALUE_LOCATE(st_esa_ft,st_sst_ft)   ;;  matching elements in ESA at SST times
g_esa_sst_cc   = VALUE_LOCATE(st_esa_ct,st_sst_ct)   ;;  " "
g_esa_sst_fc   = VALUE_LOCATE(st_esa_ft,st_sst_ct)   ;;  " "
g_esa_sst_cf   = VALUE_LOCATE(st_esa_ct,st_sst_ft)   ;;  " "

diff_ff        = ABS(t_st_esa[g_esa_sst_ff] - t_st_sst)
diff_cc        = ABS(t_st_esa[g_esa_sst_cc] - t_st_sst)
diff_fc        = ABS(t_st_esa[g_esa_sst_fc] - t_st_sst)
diff_cf        = ABS(t_st_esa[g_esa_sst_cf] - t_st_sst)

bad_ff         = WHERE(diff_ff GE 1,bd_ff,COMPLEMENT=good_ff,NCOMPLEMENT=gd_ff)
bad_cc         = WHERE(diff_cc GE 1,bd_cc,COMPLEMENT=good_cc,NCOMPLEMENT=gd_cc)
bad_fc         = WHERE(diff_fc GE 1,bd_fc,COMPLEMENT=good_fc,NCOMPLEMENT=gd_fc)
bad_cf         = WHERE(diff_cf GE 1,bd_cf,COMPLEMENT=good_cf,NCOMPLEMENT=gd_cf)
PRINT,';;',bd_ff,gd_ff,bd_cc,gd_cc,bd_fc,gd_fc,bd_cf,gd_cf
;;         398         940         398         940         398         940        1289          49

bad_3dt_ff     = WHERE(FLOOR(diff_ff) LE 3 AND FLOOR(diff_ff) GT 1,bd_3dt_ff,COMPLEMENT=good_3dt_ff,NCOMPLEMENT=gd_3dt_ff)
bad_3dt_cc     = WHERE(FLOOR(diff_cc) LE 3 AND FLOOR(diff_cc) GT 1,bd_3dt_cc,COMPLEMENT=good_3dt_cc,NCOMPLEMENT=gd_3dt_cc)
bad_3dt_fc     = WHERE(FLOOR(diff_fc) LE 3 AND FLOOR(diff_fc) GT 1,bd_3dt_fc,COMPLEMENT=good_3dt_fc,NCOMPLEMENT=gd_3dt_fc)
bad_3dt_cf     = WHERE(FLOOR(diff_cf) LE 3 AND FLOOR(diff_cf) GT 1,bd_3dt_cf,COMPLEMENT=good_3dt_cf,NCOMPLEMENT=gd_3dt_cf)
PRINT,';;',bd_3dt_ff,gd_3dt_ff,bd_3dt_cc,gd_3dt_cc,bd_3dt_fc,gd_3dt_fc,bd_3dt_cf,gd_3dt_cf
;;          19        1319          19        1319          19        1319         895         443



st_esa_rt      = ROUND((t_st_esa MOD 864d2)*1d1)
st_sst_rt      = ROUND((t_st_sst MOD 864d2)*1d1)
g_esa_sst      = VALUE_LOCATE(st_esa_rt,st_sst_rt)   ;;  matching elements in ESA at SST times
diff           = ABS(t_st_esa[g_esa_sst] - t_st_sst)
bad            = WHERE(diff GE 1,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
bad_3dt        = WHERE(FLOOR(diff) LE 3 AND FLOOR(diff) GT 1,bd_3dt,COMPLEMENT=good_3dt,NCOMPLEMENT=gd_3dt)
PRINT,';;',N_ELEMENTS(g_esa_sst),bd,gd,bd_3dt,gd_3dt
;;        1338         398         940          19        1319


b_3_dt_ind     = VALUE_LOCATE(LINDGEN(N_ELEMENTS(g_esa_sst)),FLOOR(diff))
unq            = UNIQ(b_3_dt_ind,SORT(b_3_dt_ind))
bad_3dt        = WHERE(b_3_dt_ind[unq] GE 0,bd_3dt,COMPLEMENT=good_3dt,NCOMPLEMENT=gd_3dt)
PRINT,';;',N_ELEMENTS(g_esa_sst),bd,gd,bd_3dt,gd_3dt
;;        1338         398         940          32           0










;;  Below is an example for the THC 2008-07-14 foreshock pass
tra0           = (time_double(t_fb___cent[2]) + dt_250) + [-0.4,4]*5d1
;tra0           = REFORM(tr_fb___250[2,*]) + [-0.4,4]*5d1
nna            = [fgh_tpns,eeomni_fac[0],ieomni_fac[0],sebfomnifac[0],sifomnifac[0]]
  tplot,nna,TRANGE=tra0
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
;;  Get example structures
;dat0           = dat_e
dat0           = dat_egse
dat1           = dat_seb
;;  Limit to time range with enhancements
tra1           = MEAN(time_double(t_fb___cent[2]) + dt_70,/NAN) + [-1,1]*6d1  ;;  in this case, ±1 minute
;tra1           = MEAN(tr_fb___70[2,*],/NAN) + [-1,1]*6d1  ;;  in this case, ±1 minute
test0          = (dat0.TIME GE tra1[0]) AND (dat0.END_TIME LE tra1[1])
test1          = (dat1.TIME GE tra1[0]) AND (dat1.END_TIME LE tra1[1])
good0          = WHERE(test0,gd0)
good1          = WHERE(test1,gd1)
PRINT,';;',gd0,gd1,'  For Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0]
;;          38          38  For Probe:  THC on 2008-07-14


;;  Define the units in which to plot data
;units          = 'flux'
;units          = 'eflux'
units          = 'df'
IF (units[0] EQ 'flux') THEN yran_esa = [1e-1,1e6]
IF (units[0] EQ 'flux') THEN yran_sst = [1e-4,2e-1]
IF (units[0] EQ   'df') THEN yran_esa = [1e-19,2e-12]
IF (units[0] EQ   'df') THEN yran_sst = [1e-26,1e-20]
xran_esa       = [5e1,2e4]
xran_sst       = [1e4,2e5]
;;  Setup options
lim0           = {XSTYLE:1,YSTYLE:1,XMINOR:9,YMINOR:9,XMARGIN:[10,10],YMARGIN:[5,5],XLOG:1,YLOG:1}
extract_tags,lime_str,lim0
extract_tags,lims_str,lim0
str_element,lime_str, 'XRANGE',     xran_esa,/ADD_REPLACE
str_element,lime_str, 'YRANGE',     yran_esa,/ADD_REPLACE
str_element,lims_str, 'XRANGE',     xran_sst,/ADD_REPLACE
str_element,lims_str, 'YRANGE',     yran_sst,/ADD_REPLACE


sc_frame       = 0b
cut_ran        = 22.5d0
p_angle        = 1b
sundir         = 0b
vec            = 0b
imax           = MIN([gd0[0],gd1[0]],/NAN)
exsuffx        = 'BVec'
leg_sffx       = '(Bo)'
.compile $HOME/Desktop/temp_idl/temp_plot_esa_sst_combined_spec3d.pro
dat00          = dat0[good0]
dat11          = dat1[good1]
FOR ii=0L, imax[0] - 1L DO BEGIN                                                          $
  tdate_sw       = dat00[ii]                                                            & $
  tdats_sw       = dat11[ii]                                                            & $
  p_angle        = 1b                                                                   & $
  sundir         = 0b                                                                   & $
  vec            = 0b                                                                   & $
  temp_plot_esa_sst_combined_spec3d,tdate_sw,tdats_sw,LIM_ESA=lime_str,LIM_SST=lims_str,  $
                                    ESA_ERAN=xran_esa,SST_ERAN=xran_sst,                  $
                                    SC_FRAME=sc_frame,CUT_RAN=cut_ran,P_ANGLE=p_angle,    $
                                    SUNDIR=sundir,VECTOR=vec,UNITS=units,EX_SUFFX=exsuffx,$
                                    LEG_SFFX=leg_sffx

;;  Define Earth direction for each distribution
sc_frame       = 0b
cut_ran        = 22.5d0
p_angle        = 1b
sundir         = 0b
vec            = 0b
imax           = MIN([gd0[0],gd1[0]],/NAN)
exsuffx        = 'EarthDir'
leg_sffx       = '(Earth Dir.)'
.compile $HOME/Desktop/temp_idl/temp_plot_esa_sst_combined_spec3d.pro
dat00          = dat0[good0]
dat11          = dat1[good1]
dat00.MAGF     = TRANSPOSE(avg_eesa_earth[good0,*])
dat11.MAGF     = TRANSPOSE(avg_essb_earth[good1,*])
FOR ii=0L, imax[0] - 1L DO BEGIN                                                          $
  tdate_sw       = dat00[ii]                                                            & $
  tdats_sw       = dat11[ii]                                                            & $
  p_angle        = 1b                                                                   & $
  sundir         = 0b                                                                   & $
  vec            = 0b                                                                   & $
  temp_plot_esa_sst_combined_spec3d,tdate_sw,tdats_sw,LIM_ESA=lime_str,LIM_SST=lims_str,  $
                                    ESA_ERAN=xran_esa,SST_ERAN=xran_sst,                  $
                                    SC_FRAME=sc_frame,CUT_RAN=cut_ran,P_ANGLE=p_angle,    $
                                    SUNDIR=sundir,VECTOR=vec,UNITS=units,EX_SUFFX=exsuffx,$
                                    LEG_SFFX=leg_sffx


;;----------------------------------------------------------------------------------------
;;  Use FB shock normal [for 2008-07-14 THC FB at ~21:58:00 UT only]
;;    --> ~/Desktop/TPLOT_THEMIS_PLOTS/Results_produced_for_others/DrewTurner_Foreshock_Bubble/cribs/DTurner_foreshock_bubble_RH-Solns_crib.pro
;;----------------------------------------------------------------------------------------
;;  Avg. terms for 1st shock paramters
avg_magf_up    = [   3.59595d0,0.45215d0,-2.71916d0]
avg_vswi_up    = [-616.03000d0,68.28110d0,31.65950d0]
bmag_up        = NORM(avg_magf_up)
vmag_up        = NORM(avg_vswi_up)
avg_dens_up    =    2.10073d0
avg_Ti_up      =   89.6337d0
avg_Te_up      =   10.9142d0
ushn_up        =  -957.13082d0
vshn_up        =  409.98961d0
gnorm          = REFORM(unit_vec([0.90173977d0,0.27319347d0,-0.32522940d0]))
b_dot_n        = my_dot_prod(gnorm,avg_magf_up,/NOM)/(bmag_up[0]*NORM(gnorm))
theta_Bn       = ACOS(b_dot_n[0])*18d1/!DPI
theta_Bn       = theta_Bn[0] < (18d1 - theta_Bn[0])
nkT_up         = (avg_dens_up[0]*1d6)*(kB[0]*K_eV[0]*(avg_Te_up[0] + avg_Ti_up[0]))  ;; plasma pressure [J m^(-3)]
sound_up       = SQRT(5d0*nkT_up[0]/(3d0*(avg_dens_up[0]*1d6)*mp[0]))                ;; sound speed [m/s]
alfven_up      = (bmag_up[0]*1d-9)/SQRT(muo[0]*(avg_dens_up[0]*1d6)*mp[0])           ;; Alfven speed [m/s]
Vs_p_Va_2      = (sound_up[0]^2 + alfven_up[0]^2)
b2_4ac         = Vs_p_Va_2[0]^2 + 4d0*sound_up[0]^2*alfven_up[0]^2*SIN(theta_Bn[0]*!DPI/18d1)^2
fast_up        = SQRT((Vs_p_Va_2[0] + SQRT(b2_4ac[0]))/2d0)
;;  Mach numbers
Ma_up          = ABS(ushn_up[0]*1d3/alfven_up[0])
Ms_up          = ABS(ushn_up[0]*1d3/sound_up[0])
Mf_up          = ABS(ushn_up[0]*1d3/fast_up[0])
PRINT,';;', theta_Bn[0], Ma_up[0], Ms_up[0], Mf_up[0]
;;       19.754005       14.037022       7.5544720       6.5883032

;;  Downstream
avg_magf_dn    = [ 1.91813d0,-5.59941d0,-18.2852d0]
avg_vswi_dn    = [ 155.367d0,266.634d0,-247.306d0]
bmag_dn        = NORM(avg_magf_dn)
vmag_dn        = NORM(avg_vswi_dn)
avg_dens_dn    =   17.2654d0
avg_Ti_dn      =  280.707d0
avg_Te_dn      =  120.290d0
ushn_dn        =  -116.61474d0
nkT_dn         = (avg_dens_dn[0]*1d6)*(kB[0]*K_eV[0]*(avg_Te_dn[0] + avg_Ti_dn[0]))  ;; plasma pressure [J m^(-3)]
sound_dn       = SQRT(5d0*nkT_dn[0]/(3d0*(avg_dens_dn[0]*1d6)*mp[0]))
alfven_dn      = (bmag_dn[0]*1d-9)/SQRT(muo[0]*(avg_dens_dn[0]*1d6)*mp[0])           ;; Alfven speed [m/s]
Vs_p_Va_2      = (sound_dn[0]^2 + alfven_dn[0]^2)
b2_4ac         = Vs_p_Va_2[0]^2 + 4d0*sound_dn[0]^2*alfven_dn[0]^2*SIN(theta_Bn[0]*!DPI/18d1)^2
fast_dn        = SQRT((Vs_p_Va_2[0] + SQRT(b2_4ac[0]))/2d0)
;;  Mach numbers
Ma_dn          = ABS(ushn_dn[0]*1d3/alfven_dn[0])
Ms_dn          = ABS(ushn_dn[0]*1d3/sound_dn[0])
Mf_dn          = ABS(ushn_dn[0]*1d3/fast_dn[0])
PRINT,';;', theta_Bn[0], Ma_dn[0], Ms_dn[0], Mf_dn[0], avg_dens_dn[0]/avg_dens_up[0]
;;       19.754005       1.1558679      0.46089522      0.42528774       8.2187620

;;-----------------------------------------------------
;;  Calculate gyrospeeds of specular reflection
;;-----------------------------------------------------
;;  calculate unit vectors
bhat         = REFORM(unit_vec(avg_magf_up))
vhat         = REFORM(unit_vec(avg_vswi_up))
;;  calculate upstream inflow velocity
v_up         = avg_vswi_up - gnorm*ABS(vshn_up[0])
;;  Eq. 2 from Gosling et al., [1982]
;;      [specularly reflected ion velocity]
Vref_s       = v_up - gnorm*(2d0*my_dot_prod(v_up,gnorm,/NOM))
;;  Eq. 4 and 3 from Gosling et al., [1982]
;;      [guiding center velocity of a specularly reflected ion]
Vper_r       = v_up - bhat*my_dot_prod(v_up,bhat,/NOM)  ;;  Eq. 4
Vgc_r        = Vper_r + bhat*(my_dot_prod(Vref_s,bhat,/NOM))
;;  Eq. 6 from Gosling et al., [1982]
;;      [gyro-velocity of a specularly reflected ion]
Vgy_r        = Vref_s - Vgc_r
;;  Eq. 7 and 9 from Gosling et al., [1982]
;;      [guiding center velocity of a specularly reflected ion perp. to shock surface]
Vgcn_r       = my_dot_prod(Vgc_r,gnorm,/NOM)
;;      [guiding center velocity of a specularly reflected ion para. to B-field]
Vgcb_r       = my_dot_prod(Vgc_r,bhat,/NOM)
;;  gyrospeed and guiding center speed
Vgy_rs       = mag__vec(Vgy_r,/NAN)
Vgc_rs       = mag__vec(Vgc_r,/NAN)

PRINT,';;', Vgy_rs[0], Vgc_rs[0] & $
PRINT,';;', Vgcn_r[0], Vgcb_r[0]
;;       648.18687       1029.2529
;;       739.83011       917.99294

n_essb         = nseb[0]
tr_essb        = [[dat_seb.TIME],[dat_seb.END_TIME]]
avg_tessb      = (tr_essb[*,0] + tr_essb[*,1])/2d0
se_essb_norm   = REPLICATE(d,n_essb[0],3L)         ;;  [N,{X,Y,Z}]-Element array
FOR k=0L, 2L DO se_essb_norm[*,k] = gnorm[k]
struc          = {X:avg_tessb,Y:se_essb_norm}
coords         = [coord_dsl[0],coord_gse[0]]
store_data,scpref[0]+'fb_sh_norm_'+coords[0],DATA=struc

in__name       = scpref[0]+'fb_sh_norm_'+coords[0]
out_name       = scpref[0]+'fb_sh_norm_'+coords[1]
thm_cotrans,in__name[0],out_name[0],IN_COORD=coords[1],OUT_COORD=coords[0],VERBOSE=0

;;  Define FB shock normal direction for each distribution
get_data,out_name[0],DATA=struc
norm_dsl       = struc.Y
sc_frame       = 0b
cut_ran        = 22.5d0
p_angle        = 1b
sundir         = 0b
vec            = 0b
imax           = MIN([gd0[0],gd1[0]],/NAN)
exsuffx        = 'FB_nsh'
leg_sffx       = '(N_sh)'
.compile $HOME/Desktop/temp_idl/temp_plot_esa_sst_combined_spec3d.pro
dat00          = dat0[good0]
dat11          = dat1[good1]
FOR k=0L, 2L DO dat00.MAGF[k] = gnorm[k]
dat11.MAGF     = TRANSPOSE(norm_dsl[good1,*])
FOR ii=0L, imax[0] - 1L DO BEGIN                                                          $
  tdate_sw       = dat00[ii]                                                            & $
  tdats_sw       = dat11[ii]                                                            & $
  p_angle        = 1b                                                                   & $
  sundir         = 0b                                                                   & $
  vec            = 0b                                                                   & $
  temp_plot_esa_sst_combined_spec3d,tdate_sw,tdats_sw,LIM_ESA=lime_str,LIM_SST=lims_str,  $
                                    ESA_ERAN=xran_esa,SST_ERAN=xran_sst,                  $
                                    SC_FRAME=sc_frame,CUT_RAN=cut_ran,P_ANGLE=p_angle,    $
                                    SUNDIR=sundir,VECTOR=vec,UNITS=units,EX_SUFFX=exsuffx,$
                                    LEG_SFFX=leg_sffx
