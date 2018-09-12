;;  @/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/print_wind_mfi_srate_and_2char_table_stats_crib.pro

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
vec_str        = ['x','y','z']
vec_col        = [250,150,50]
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}
;;  Define save/setup stuff for TPLOT
popen_str      = {PORT:1,LANDSCAPE:0,UNITS:'inches',YSIZE:11,XSIZE:8.5}
;;  Define save directory
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'idl_save_files'+slash[0]
inst_pref      = 'mfi_'
mfi_gse_tpn    = 'Wind_B_htr_gse'
mfi_mag_tpn    = 'Wind_B_htr_mag'
;;----------------------------------------------------------------------------------------
;;  Initialize and setup
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/print_ip_shocks_whistler_stats_batch.pro
;;  Convert zoom times to Unix
start_unix     = time_double(start_times)
end___unix     = time_double(end___times)
midt__unix     = (start_unix + end___unix)/2d0
;;----------------------------------------------------------------------------------------
;;  Get precursor and ramp time ranges
;;----------------------------------------------------------------------------------------
delt           = [-1,1]*1d0*36d2        ;;  load ±1 hour about ramp
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/get_ip_shocks_whistler_ramp_times_batch.pro

;;----------------------------------------------------------------------------------------
;;  Define time ranges to load into TPLOT
;;----------------------------------------------------------------------------------------
all_midt       = midt__unix
;;  Correct midpoint times using those defined from precursor analysis
all_midt[good_y_all0] = tura_mid
;;  Define time ranges ±1 hour about midpoint times
delt           = [-1,1]*1d0*36d2        ;;  load ±1 hour about ramp
n_gdA          = N_ELEMENTS(good_A)
all_midt_2d    = all_midt # REPLICATE(1d0,2L)
FOR k=0L, 1L DO all_midt_2d[*,k] += delt[k]
;;  Define TPLOT time ranges [Unix]
all__trans     = all_midt_2d
;;----------------------------------------------------------------------------------------
;;  Determine MFI sample rates for each event
;;----------------------------------------------------------------------------------------
.compile $HOME/Desktop/low_beta_Ma_whistlers/crib_sheets/load_ip_shocks_mfi_split_magvec.pro
srate_avg      = REPLICATE(d,n_gdA[0])      ;;  Avgerage sample rate [sps]
srate_med      = REPLICATE(d,n_gdA[0])      ;;  Median sample rate [sps]
FOR k=0L, n_gdA[0] - 1L DO BEGIN                                           $
  temp   = 0                                                             & $
  medavg = 0                                                             & $
  tran0  = REFORM(all__trans[k,*])                                       & $
  load_ip_shocks_mfi_split_magvec,TRANGE=tran0,PRECISION=3               & $
  get_data,mfi_gse_tpn[0],DATA=temp,DLIM=dlim,LIM=lim                    & $
  IF (SIZE(temp,/TYPE) NE 8) THEN CONTINUE                               & $
  unix   = t_get_struc_unix(temp,TSHFT_ON=tshft_on)                      & $
  srate  = sample_rate(unix,/AVERAGE,OUT_MED_AVG=medavg)                 & $
  IF (N_ELEMENTS(medavg) NE 2) THEN CONTINUE                             & $
  srate_avg[k] = srate[0]                                                & $
  srate_med[k] = medavg[0]

;;----------------------------------------------------------------------------------------
;;  Print out # of shocks for each 2 letter code
;;----------------------------------------------------------------------------------------
HELP, WHERE(whpre_yn EQ 'YS'), WHERE(whpre_yn EQ 'YP'), WHERE(whpre_yn EQ 'YU'), WHERE(whpre_yn EQ 'YG'), WHERE(whpre_yn EQ 'YM'), WHERE(whpre_yn EQ 'YN')
;;  <Expression>    LONG      = Array[11]
;;  <Expression>    LONG      = Array[33]
;;  <Expression>    LONG      = Array[59]
;;  <Expression>    LONG      = Array[2]
;;  <Expression>    LONG      = Array[8]
;;  <Expression>    LONG      =           -1
HELP, WHERE(whpre_yn EQ 'NS'), WHERE(whpre_yn EQ 'NP'), WHERE(whpre_yn EQ 'NU'), WHERE(whpre_yn EQ 'NG'), WHERE(whpre_yn EQ 'NM'), WHERE(whpre_yn EQ 'NN')
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      = Array[1]
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      = Array[16]
HELP, WHERE(whpre_yn EQ 'MS'), WHERE(whpre_yn EQ 'MP'), WHERE(whpre_yn EQ 'MU'), WHERE(whpre_yn EQ 'MG'), WHERE(whpre_yn EQ 'MM'), WHERE(whpre_yn EQ 'MN')
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      = Array[15]
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1

;;  Print unique sample rates
PRINT,';;  ', srate_med[UNIQ(srate_med,SORT(srate_med))]
;;         5.4348385       10.869226       21.740255

good_sr05      = WHERE(srate_med GT  0 AND srate_med LT 10,gd_sr05)
good_sr11      = WHERE(srate_med GT 10 AND srate_med LT 20,gd_sr11)
good_sr22      = WHERE(srate_med GT 20 AND srate_med LT 30,gd_sr22)
PRINT,';;  ', gd_sr05[0], gd_sr11[0], gd_sr22[0]
;;             1         132          12

PRINT,';;  ',whpre_yn[good_sr05]
;;   YU

x              = whpre_yn[good_sr11]
y              = whpre_2l[good_sr11]
unq_2l_sr11    = UNIQ(x,SORT(x))
PRINT,';;  ',x[unq_2l_sr11]
;;   MU NN NU YG YM YP YS YU

HELP, WHERE(x EQ 'YS'), WHERE(x EQ 'YP'), WHERE(x EQ 'YU'), WHERE(x EQ 'YG'), WHERE(x EQ 'YM'), WHERE(x EQ 'YN')
;;  <Expression>    LONG      = Array[11]
;;  <Expression>    LONG      = Array[29]
;;  <Expression>    LONG      = Array[56]
;;  <Expression>    LONG      = Array[1]
;;  <Expression>    LONG      = Array[8]
;;  <Expression>    LONG      =           -1
HELP, WHERE(x EQ 'NS'), WHERE(x EQ 'NP'), WHERE(x EQ 'NU'), WHERE(x EQ 'NG'), WHERE(x EQ 'NM'), WHERE(x EQ 'NN')
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      = Array[1]
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      = Array[13]
HELP, WHERE(x EQ 'MS'), WHERE(x EQ 'MP'), WHERE(x EQ 'MU'), WHERE(x EQ 'MG'), WHERE(x EQ 'MM'), WHERE(x EQ 'MN')
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      = Array[13]
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1

good_sr11_2u   = WHERE(y EQ 'U',gd_sr11_2u)
good_sr11_2n   = WHERE(y EQ 'N',gd_sr11_2n)
good_sr11_2g   = WHERE(y EQ 'G',gd_sr11_2g)
good_sr11_2m   = WHERE(y EQ 'M',gd_sr11_2m)
good_sr11_2p   = WHERE(y EQ 'P',gd_sr11_2p)
good_sr11_2s   = WHERE(y EQ 'S',gd_sr11_2s)
PRINT,';;  ', gd_sr11_2u[0], gd_sr11_2n[0], gd_sr11_2g[0], gd_sr11_2m[0], gd_sr11_2p[0], gd_sr11_2s[0]
;;            70          13           1           8          29          11

x              = whpre_yn[good_sr22]
y              = whpre_2l[good_sr22]
unq_2l_sr22    = UNIQ(x,SORT(x))
PRINT,';;  ',x[unq_2l_sr22]
;;   MU NN YG YP YU

HELP, WHERE(x EQ 'YS'), WHERE(x EQ 'YP'), WHERE(x EQ 'YU'), WHERE(x EQ 'YG'), WHERE(x EQ 'YM'), WHERE(x EQ 'YN')
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      = Array[4]
;;  <Expression>    LONG      = Array[2]
;;  <Expression>    LONG      = Array[1]
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
HELP, WHERE(x EQ 'NS'), WHERE(x EQ 'NP'), WHERE(x EQ 'NU'), WHERE(x EQ 'NG'), WHERE(x EQ 'NM'), WHERE(x EQ 'NN')
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      = Array[3]
HELP, WHERE(x EQ 'MS'), WHERE(x EQ 'MP'), WHERE(x EQ 'MU'), WHERE(x EQ 'MG'), WHERE(x EQ 'MM'), WHERE(x EQ 'MN')
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      = Array[2]
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1
;;  <Expression>    LONG      =           -1

good_sr22_2u   = WHERE(y EQ 'U',gd_sr22_2u)
good_sr22_2n   = WHERE(y EQ 'N',gd_sr22_2n)
good_sr22_2g   = WHERE(y EQ 'G',gd_sr22_2g)
good_sr22_2m   = WHERE(y EQ 'M',gd_sr22_2m)
good_sr22_2p   = WHERE(y EQ 'P',gd_sr22_2p)
good_sr22_2s   = WHERE(y EQ 'S',gd_sr22_2s)
PRINT,';;  ', gd_sr22_2u[0], gd_sr22_2n[0], gd_sr22_2g[0], gd_sr22_2m[0], gd_sr22_2p[0], gd_sr22_2s[0]
;;             4           3           1           0           4           0







;;----------------------------------------------------------------------------------------
;;  Print results
;;----------------------------------------------------------------------------------------
all_tdates     = STRMID(time_string(all_midt,PREC=3),0L,10L)
mform          = '(";;  ",a10,"  ",2f10.2,a8)'
FOR k=0L, n_gdA[0] - 1L DO BEGIN                                           $
  PRINT,all_tdates[k],srate_avg[k],srate_med[k],whpre_yn[k],FORMAT=mform[0]

;;  1st Letter
;;  Y   =  Yes
;;  N   =  No
;;  M   =  Maybe or Unclear
;;
;;  2nd Letter
;;  S   =  resolved or sampled well enough
;;  U   =  fluctuation present but under-resolved (e.g., looks like triangle wave)
;;  P   =  mostly resolved but still a little spiky
;;  G   =  data gap or missing data but still well resolved
;;  M   =  data gap or missing data and under-resolved
;;  N   =  nothing
;;-----------------------------------------------
;;     Date           Avg.    Median    2 Char.
;;  YYYY-MM-DD       [sps]     [sps]     Code
;;===============================================
;;  1995-03-04       10.87     10.87      MU
;;  1995-04-17       10.86     10.87      YU
;;  1995-07-22       10.86     10.87      YP
;;  1995-08-22       21.70     21.74      YG
;;  1995-08-24       21.71     21.74      YU
;;  1995-09-14       21.71     21.74      NN
;;  1995-10-22       10.86     10.87      YU
;;  1995-12-24       21.72     21.74      YU
;;  1996-02-06       10.85     10.87      YU
;;  1996-04-03       21.70     21.74      YP
;;  1996-04-08       21.69     21.74      YP
;;  1996-06-18       10.86     10.87      NN
;;  1997-01-05       21.70     21.74      MU
;;  1997-03-15       10.85     10.87      YS
;;  1997-04-10       10.87     10.87      YU
;;  1997-04-16       10.85     10.87      MU
;;  1997-05-20       10.86     10.87      NN
;;  1997-05-25       10.86     10.87      MU
;;  1997-05-26       10.86     10.87      NN
;;  1997-08-05       21.72     21.74      NN
;;  1997-09-03       21.71     21.74      NN
;;  1997-10-10       21.72     21.74      MU
;;  1997-10-24       21.74     21.74      YP
;;  1997-11-01       21.71     21.74      YP
;;  1997-12-10       10.86     10.87      YU
;;  1997-12-30       10.86     10.87      YU
;;  1998-01-06       10.86     10.87      YU
;;  1998-02-18       10.86     10.87      YS
;;  1998-05-29       10.87     10.87      YU
;;  1998-08-06       10.87     10.87      YU
;;  1998-08-19       10.87     10.87      YU
;;  1998-11-08       10.87     10.87      YU
;;  1998-12-26       10.86     10.87      MU
;;  1998-12-28       10.87     10.87      YP
;;  1999-01-13       10.86     10.87      YP
;;  1999-02-17       10.87     10.87      YU
;;  1999-03-10       10.86     10.87      NN
;;  1999-04-16       10.87     10.87      YP
;;  1999-06-26       10.87     10.87      YM
;;  1999-08-04       10.87     10.87      YP
;;  1999-08-23       10.86     10.87      YP
;;  1999-09-15       10.87     10.87      NN
;;  1999-09-22       10.87     10.87      YU
;;  1999-10-21       10.86     10.87      YM
;;  1999-11-05       10.87     10.87      YP
;;  1999-11-13       10.87     10.87      YU
;;  2000-02-05       10.87     10.87      YU
;;  2000-02-14       10.87     10.87      YP
;;  2000-06-23       10.87     10.87      YP
;;  2000-07-13       10.87     10.87      YU
;;  2000-07-26       10.86     10.87      YU
;;  2000-07-28       10.87     10.87      YU
;;  2000-08-10       10.87     10.87      YU
;;  2000-08-11       10.87     10.87      YM
;;  2000-10-03       10.87     10.87      NN
;;  2000-10-28       10.86     10.87      MU
;;  2000-10-28       10.87     10.87      YU
;;  2000-10-31       10.86     10.87      YU
;;  2000-11-04       10.86     10.87      NN
;;  2000-11-06       10.87     10.87      YP
;;  2000-11-11       10.87     10.87      MU
;;  2000-11-26       10.87     10.87      YM
;;  2000-11-28       10.87     10.87      YP
;;  2001-01-17       10.87     10.87      YP
;;  2001-03-03       10.87     10.87      YS
;;  2001-03-22       10.87     10.87      YU
;;  2001-03-27       10.86     10.87      YU
;;  2001-04-21       10.87     10.87      YU
;;  2001-05-06       10.87     10.87      YP
;;  2001-05-12       10.87     10.87      YP
;;  2001-08-12       10.86     10.87      MU
;;  2001-08-31       10.87     10.87      NN
;;  2001-09-13       10.87     10.87      YU
;;  2001-10-28       10.87     10.87      YU
;;  2001-11-30       10.87     10.87      YP
;;  2001-12-21       10.87     10.87      YP
;;  2001-12-30       10.87     10.87      YM
;;  2002-01-17       10.86     10.87      YP
;;  2002-01-31        5.43      5.43      YU
;;  2002-03-23       10.87     10.87      YU
;;  2002-03-29       10.86     10.87      YU
;;  2002-05-21       10.86     10.87      YP
;;  2002-06-29       10.87     10.87      YS
;;  2002-08-01       10.86     10.87      YU
;;  2002-09-30       10.87     10.87      YM
;;  2002-10-02       10.87     10.87      MU
;;  2002-11-09       10.86     10.87      YU
;;  2003-05-29       10.86     10.87      YU
;;  2003-06-18       10.87     10.87      YP
;;  2004-04-12       10.87     10.87      YU
;;  2005-05-06       10.86     10.87      YS
;;  2005-05-07       10.87     10.87      YU
;;  2005-06-16       10.86     10.87      YU
;;  2005-07-10       10.86     10.87      YU
;;  2005-07-16       10.86     10.87      NN
;;  2005-08-01       10.86     10.87      MU
;;  2005-08-24       10.87     10.87      YM
;;  2005-09-02       10.87     10.87      YU
;;  2005-09-15       10.86     10.87      MU
;;  2005-12-30       10.87     10.87      NN
;;  2006-08-19       10.87     10.87      YS
;;  2006-11-03       10.86     10.87      NN
;;  2007-07-20       10.87     10.87      NU
;;  2007-08-22       10.87     10.87      YU
;;  2007-12-17       10.87     10.87      YP
;;  2008-05-28       10.86     10.87      YU
;;  2008-06-24       10.86     10.87      YP
;;  2009-02-03       10.86     10.87      YU
;;  2009-06-24       10.87     10.87      YP
;;  2009-06-27       10.86     10.87      YU
;;  2009-10-21       10.87     10.87      YU
;;  2010-04-11       10.86     10.87      YP
;;  2011-02-04       10.85     10.87      YS
;;  2011-07-11       10.87     10.87      YU
;;  2011-09-16       10.85     10.87      YP
;;  2011-09-25       10.87     10.87      YU
;;  2012-01-21       10.87     10.87      YU
;;  2012-01-30       10.87     10.87      YU
;;  2012-03-07       10.87     10.87      NN
;;  2012-04-19       10.87     10.87      MU
;;  2012-06-16       10.87     10.87      YU
;;  2012-10-08       10.87     10.87      YU
;;  2012-11-12       10.87     10.87      YU
;;  2012-11-26       10.87     10.87      YP
;;  2012-12-14       10.87     10.87      NN
;;  2013-01-17       10.87     10.87      MU
;;  2013-02-13       10.87     10.87      YP
;;  2013-04-30       10.87     10.87      YU
;;  2013-06-10       10.87     10.87      YP
;;  2013-07-12       10.87     10.87      YP
;;  2013-09-02       10.87     10.87      YG
;;  2013-10-26       10.87     10.87      YS
;;  2014-02-13       10.87     10.87      YU
;;  2014-02-15       10.87     10.87      YU
;;  2014-02-19       10.87     10.87      YU
;;  2014-04-19       10.87     10.87      YP
;;  2014-05-07       10.87     10.87      YS
;;  2014-05-29       10.87     10.87      YS
;;  2014-07-14       10.87     10.87      YU
;;  2015-05-06       10.87     10.87      YU
;;  2015-06-05       10.87     10.87      MU
;;  2015-06-24       10.87     10.87      YS
;;  2015-08-15       10.87     10.87      YM
;;  2016-03-11       10.87     10.87      YU
;;  2016-03-14       10.87     10.87      YU


