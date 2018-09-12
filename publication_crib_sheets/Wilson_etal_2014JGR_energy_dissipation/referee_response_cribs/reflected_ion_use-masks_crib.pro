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

wpefac         = SQRT(1d6*qq[0]^2/(epo[0]*me[0]))
wpifac         = SQRT(1d6*qq[0]^2/(epo[0]*mp[0]))
wcefac         = qq[0]*1d-9/me[0]
wcifac         = qq[0]*1d-9/mp[0]
ckm            = c[0]*1d-3            ;;  m --> km
;;  Setup margins
!X.MARGIN      = [15,5]
!Y.MARGIN      = [8,4]
;;----------------------------------------------------------------------------------------
;;  Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;;  Define dummy parameters to fill with "good" values below
;;----------------------------------------------------------------------------------------
Ni_up_0        = d
d_Ni_up_0      = d
Ni_up_1        = d
d_Ni_up_1      = d
Ni_up_2        = d
d_Ni_up_2      = d
tr_ft_0        = REPLICATE(d,2L)           ;;  [1st Shock]  Foot start/end times
tr_ft_1        = REPLICATE(d,2L)           ;;  [2nd Shock]  Foot start/end times
tr_ft_2        = REPLICATE(d,2L)           ;;  [3rd Shock]  Foot start/end times
tr_ra_0        = REPLICATE(d,2L)           ;;  [1st Shock]  Ramp start/end times
tr_ra_1        = REPLICATE(d,2L)           ;;  [2nd Shock]  Ramp start/end times
tr_ra_2        = REPLICATE(d,2L)           ;;  [3rd Shock]  Ramp start/end times
tr_up_0        = REPLICATE(d,2L)           ;;  [1st Shock]  Upstream start/end times
tr_dn_0        = REPLICATE(d,2L)           ;;  [1st Shock]  Downstream start/end times
tr_up_1        = REPLICATE(d,2L)           ;;  [2nd Shock]  Upstream start/end times
tr_dn_1        = REPLICATE(d,2L)           ;;  [2nd Shock]  Downstream start/end times
tr_up_2        = REPLICATE(d,2L)           ;;  [3rd Shock]  Upstream start/end times
tr_dn_2        = REPLICATE(d,2L)           ;;  [3rd Shock]  Downstream start/end times
shock_suff0    = ''
shock_suff1    = ''
shock_suff2    = ''
good_up0       = -1                        ;;  [1st Shock]  Upstream IESA elements
good_up1       = -1                        ;;  [2nd Shock]  Upstream IESA elements
good_up2       = -1                        ;;  [3rd Shock]  Upstream IESA elements
good_dn0       = -1                        ;;  [1st Shock]  Downstream IESA elements
good_dn1       = -1                        ;;  [2nd Shock]  Downstream IESA elements
good_dn2       = -1                        ;;  [3rd Shock]  Downstream IESA elements
good_ra0       = -1                        ;;  [1st Shock]  Ramp IESA elements
good_ra1       = -1                        ;;  [2nd Shock]  Ramp IESA elements
good_ra2       = -1                        ;;  [3rd Shock]  Ramp IESA elements
good_ft0       = -1                        ;;  [1st Shock]  Foot IESA elements
good_ft1       = -1                        ;;  [2nd Shock]  Foot IESA elements
good_ft2       = -1                        ;;  [3rd Shock]  Foot IESA elements

;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
;;  2009-07-13 [1 Crossing]
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_b_data_2009-07-13_batch.pro
jj             = 0L
tdate          = '2009-07-13'
sc             = 'b'
pref           = 'th'+sc[0]+'_'
Nic_tpn        = pref[0]+'N_peib_no_GIs_UV'
shock_suff0    = '1st_Shock'
;;  Avg. terms [1st Shock]
Ni_up_0        =  7.21921d0
d_Ni_up_0      =  0.60208d0
tr_up_0        = time_double(tdate[0]+'/'+['09:00:08.700','09:01:38.800'])
tr_dn_0        = time_double(tdate[0]+'/'+['08:57:35.000','08:59:00.000'])
tr_ra_0        = time_double(tdate[0]+'/'+['08:59:45.440','08:59:48.290'])
tr_ft_0        = time_double(tdate[0]+'/'+['08:59:48.291','09:00:08.699'])
;;  Define mask and "UV" speeds
v_thresh       = [35e1,35e1,35e1,35e1,35e1]
v_uv           = 50e1
i_time0        = dat_igse.TIME
i_time1        = dat_igse.END_TIME
tr_bi0         = time_double(tdate[0]+'/'+['08:59:42','09:02:41'])
tr_bi1         = time_double(tdate[0]+'/'+['09:18:03','09:18:31'])
tr_bi2         = time_double(tdate[0]+'/'+['09:19:23','09:19:39'])
tr_bi3         = time_double(tdate[0]+'/'+['09:23:50','09:24:18'])
tr_bi4         = time_double(tdate[0]+'/'+['09:24:47','09:40:31'])
bad00          = WHERE(i_time0 GE tr_bi0[0] AND i_time1 LE tr_bi0[1],bd0)
bad01          = WHERE(i_time0 GE tr_bi1[0] AND i_time1 LE tr_bi1[1],bd1)
bad02          = WHERE(i_time0 GE tr_bi2[0] AND i_time1 LE tr_bi2[1],bd2)
bad03          = WHERE(i_time0 GE tr_bi3[0] AND i_time1 LE tr_bi3[1],bd3)
bad04          = WHERE(i_time0 GE tr_bi4[0] AND i_time1 LE tr_bi4[1],bd4)
;IF (bd0 GT 0) THEN dummy[bad0] = dummk[bad0]
;IF (bd1 GT 0) THEN dummy[bad1] = dummk[bad1]
;IF (bd2 GT 0) THEN dummy[bad2] = dummk[bad2]
;IF (bd3 GT 0) THEN dummy[bad3] = dummk[bad3]
;IF (bd4 GT 0) THEN dummy[bad4] = dummk[bad4]

;;-------------------------------------
;;  2009-07-21 [1 Crossing]
;;-------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_c_data_2009-07-21_batch.pro
jj             = 1L
tdate          = '2009-07-21'
sc             = 'c'
pref           = 'th'+sc[0]+'_'
;Nic_tpn        = pref[0]+'peeb_density'    ;;  --> Ions were "bad" for this event...
Nic_tpn        = pref[0]+'N_peib_no_GIs_UV'
shock_suff0    = '1st_Shock'
;;  Avg. terms [1st Shock]
Ni_up_0        =  7.36031d0
d_Ni_up_0      =  0.79248d0
tr_up_0        = time_double(tdate[0]+'/'+['19:27:54.000','19:29:00.000'])
tr_dn_0        = time_double(tdate[0]+'/'+['19:16:42.000','19:17:48.000'])
tr_ra_0        = time_double(tdate[0]+'/'+['19:24:47.720','19:24:49.530'])
tr_ft_0        = time_double(tdate[0]+'/'+['19:24:49.530','19:24:53.440'])
;;  Define mask and "UV" speeds
v_uv           = 60e1                             ;;  = V_uv     [estimated by plotting contours with sun dir.]
v_thresh       = [20e1,20e1,20e1,20e1,25e1,25e1,25e1,25e1,30e1,30e1,30e1,30e1,35e1,40e1,40e1]
i_time0        = dat_igse.TIME
tr_bi0         = time_double(tdate[0]+'/'+['19:19:58','19:19:59'])
tr_bi1         = time_double(tdate[0]+'/'+['19:20:16','19:20:59'])
tr_bi2         = time_double(tdate[0]+'/'+['19:21:01','19:21:38'])
tr_bi3         = time_double(tdate[0]+'/'+['19:21:40','19:21:47'])
tr_bi4         = time_double(tdate[0]+'/'+['19:21:49','19:21:53'])
tr_bi5         = time_double(tdate[0]+'/'+['19:21:55','19:22:26'])
tr_bi6         = time_double(tdate[0]+'/'+['19:22:37','19:23:01'])
tr_bi7         = time_double(tdate[0]+'/'+['19:23:03','19:23:10'])
tr_bi8         = time_double(tdate[0]+'/'+['19:23:12','19:23:16'])
tr_bi9         = time_double(tdate[0]+'/'+['19:23:18','19:23:34'])
tr_bi10        = time_double(tdate[0]+'/'+['19:23:36','19:23:49'])
tr_bi11        = time_double(tdate[0]+'/'+['19:23:51','19:24:04'])
tr_bi12        = time_double(tdate[0]+'/'+['19:24:06','19:24:13'])
tr_bi13        = time_double(tdate[0]+'/'+['19:24:18','19:24:58'])
tr_bi14        = time_double(tdate[0]+'/'+['19:25:00','19:29:11'])
bad00          = WHERE(i_time0 GE  tr_bi0[0] AND i_time0 LE  tr_bi0[1], bd0)
bad01          = WHERE(i_time0 GE  tr_bi1[0] AND i_time0 LE  tr_bi1[1], bd1)
bad02          = WHERE(i_time0 GE  tr_bi2[0] AND i_time0 LE  tr_bi2[1], bd2)
bad03          = WHERE(i_time0 GE  tr_bi3[0] AND i_time0 LE  tr_bi3[1], bd3)
bad04          = WHERE(i_time0 GE  tr_bi4[0] AND i_time0 LE  tr_bi4[1], bd4)
bad05          = WHERE(i_time0 GE  tr_bi5[0] AND i_time0 LE  tr_bi5[1], bd5)
bad06          = WHERE(i_time0 GE  tr_bi6[0] AND i_time0 LE  tr_bi6[1], bd6)
bad07          = WHERE(i_time0 GE  tr_bi7[0] AND i_time0 LE  tr_bi7[1], bd7)
bad08          = WHERE(i_time0 GE  tr_bi8[0] AND i_time0 LE  tr_bi8[1], bd8)
bad09          = WHERE(i_time0 GE  tr_bi9[0] AND i_time0 LE  tr_bi9[1], bd9)
bad10          = WHERE(i_time0 GE tr_bi10[0] AND i_time0 LE tr_bi10[1],bd10)
bad11          = WHERE(i_time0 GE tr_bi11[0] AND i_time0 LE tr_bi11[1],bd11)
bad12          = WHERE(i_time0 GE tr_bi12[0] AND i_time0 LE tr_bi12[1],bd12)
bad13          = WHERE(i_time0 GE tr_bi13[0] AND i_time0 LE tr_bi13[1],bd13)
bad14          = WHERE(i_time0 GE tr_bi14[0] AND i_time0 LE tr_bi14[1],bd14)

;IF ( bd9 GT 0) THEN dummy[bad9]  = dumm_200[bad9]
;IF ( bd7 GT 0) THEN dummy[bad7]  = dumm_200[bad7]
;IF (bd11 GT 0) THEN dummy[bad11] = dumm_200[bad11]
;IF (bd13 GT 0) THEN dummy[bad13] = dumm_200[bad13]
;
;IF ( bd1 GT 0) THEN dummy[bad1]  = dumm_250[bad1]
;IF ( bd5 GT 0) THEN dummy[bad5]  = dumm_250[bad5]
;IF ( bd6 GT 0) THEN dummy[bad6]  = dumm_250[bad6]
;IF (bd14 GT 0) THEN dummy[bad14] = dumm_250[bad14]
;
;IF ( bd2 GT 0) THEN dummy[bad2]  = dumm_300[bad2]
;IF ( bd4 GT 0) THEN dummy[bad4]  = dumm_300[bad4]
;IF ( bd8 GT 0) THEN dummy[bad8]  = dumm_300[bad8]
;IF (bd12 GT 0) THEN dummy[bad12] = dumm_300[bad12]
;
;IF ( bd3 GT 0) THEN dummy[bad3]  = dumm_350[bad3]
;
;IF ( bd0 GT 0) THEN dummy[bad0]  = dumm_400[bad0]
;IF (bd10 GT 0) THEN dummy[bad10] = dumm_400[bad10]

;;-------------------------------------
;;  2009-07-23 [3 Crossings]
;;-------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_c_data_2009-07-23_batch.pro
jj             = [2L,3L,4L]
tdate          = '2009-07-23'
sc             = 'c'
pref           = 'th'+sc[0]+'_'
Nic_tpn        = pref[0]+'N_peib_no_GIs_UV'
shock_suff0    = '1st_Shock'
shock_suff1    = '2nd_Shock'
shock_suff2    = '3rd_Shock'
;;  Avg. terms [1st Shock]
Ni_up_0        =  3.73654d0
d_Ni_up_0      =  0.09663d0
tr_up_0        = time_double(tdate[0]+'/'+['18:05:52.200','18:06:37.200'])
tr_dn_0        = time_double(tdate[0]+'/'+['18:02:25.800','18:03:10.800'])
tr_ra_0        = time_double(tdate[0]+'/'+['18:04:47.030','18:04:58.920'])
tr_ft_0        = time_double(tdate[0]+'/'+['18:04:58.921','18:05:52.199'])       ;;  I did not record this, so there must not be a noticeable foot
;;  Avg. terms [2nd Shock]
Ni_up_1        =  3.71973d0
d_Ni_up_1      =  0.07550d0
tr_up_1        = time_double(tdate[0]+'/'+['18:05:57.300','18:06:38.300'])
tr_dn_1        = time_double(tdate[0]+'/'+['18:10:05.400','18:10:46.400'])
tr_ra_1        = time_double(tdate[0]+'/'+['18:07:07.340','18:07:08.100'])
tr_ft_1        = time_double(tdate[0]+'/'+['18:06:46.780','18:07:07.340'])
;;  Avg. terms [3rd Shock]
Ni_up_2        =  3.88664d0
d_Ni_up_2      =  0.13496d0
tr_up_2        = time_double(tdate[0]+'/'+['18:27:23.800','18:28:28.800'])
tr_dn_2        = time_double(tdate[0]+'/'+['18:21:40.700','18:22:45.700'])
tr_ra_2        = time_double(tdate[0]+'/'+['18:24:24.910','18:24:49.450'])
tr_ft_2        = time_double(tdate[0]+'/'+['18:24:49.451','18:27:23.799'])       ;;  I did not record this, so there must not be a noticeable foot
;;  Define mask and "UV" speeds
v_uv           = 60e1
v_thresh       = [25e1,30e1,30e1,40e1]
i_time0        = dat_igse.TIME
tr_bi0         = time_double(tdate[0]+'/'+['18:04:37','18:04:59'])
tr_bi1         = time_double(tdate[0]+'/'+['18:05:04','18:07:05'])
tr_bi2         = time_double(tdate[0]+'/'+['18:24:34','18:24:44'])
tr_bi3         = time_double(tdate[0]+'/'+['18:24:46','18:29:42'])
bad00          = WHERE(i_time0 GE tr_bi0[0] AND i_time0 LE tr_bi0[1],bd0)
bad01          = WHERE(i_time0 GE tr_bi1[0] AND i_time0 LE tr_bi1[1],bd1)
bad02          = WHERE(i_time0 GE tr_bi2[0] AND i_time0 LE tr_bi2[1],bd2)
bad03          = WHERE(i_time0 GE tr_bi3[0] AND i_time0 LE tr_bi3[1],bd3)
;IF (bd2 GT 0) THEN dummy[bad2] = dumm_250[bad2]
;
;IF (bd0 GT 0) THEN dummy[bad0] = dumm_300[bad0]
;IF (bd3 GT 0) THEN dummy[bad3] = dumm_300[bad3]
;
;IF (bd1 GT 0) THEN dummy[bad1] = dumm_400[bad1]

;;-------------------------------------
;;  2009-09-05 [3 Crossings]
;;-------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_c_data_2009-09-05_batch.pro
jj             = [5L,6L,7L]
tdate          = '2009-09-05'
sc             = 'c'
pref           = 'th'+sc[0]+'_'
Nic_tpn        = pref[0]+'N_peib_no_GIs_UV'
shock_suff0    = '1st_Shock'
shock_suff1    = '2nd_Shock'
shock_suff2    = '3rd_Shock'
;;  Avg. terms [1st Shock]
Ni_up_0        =  2.61508d0
d_Ni_up_0      =  0.09517d0
tr_up_0        = time_double(tdate[0]+'/'+['16:15:00.000','16:15:34.000'])
tr_dn_0        = time_double(tdate[0]+'/'+['16:10:54.900','16:11:28.900'])
tr_ra_0        = time_double(tdate[0]+'/'+['16:11:32.910','16:11:33.800'])
tr_ft_0        = time_double(tdate[0]+'/'+['16:11:33.800','16:12:11.660'])
;;  Avg. terms [2nd Shock]
Ni_up_1        =  2.65507d0
d_Ni_up_1      =  0.19349d0
tr_up_1        = time_double(tdate[0]+'/'+['16:39:50.000','16:40:36.000'])
tr_dn_1        = time_double(tdate[0]+'/'+['16:36:42.300','16:37:28.300'])
tr_ra_1        = time_double(tdate[0]+'/'+['16:37:58.272','16:37:59.000'])
tr_ft_1        = time_double(tdate[0]+'/'+['16:37:59.000','16:38:11.680'])
;;  Avg. terms [3rd Shock]
Ni_up_2        =  2.56415d0
d_Ni_up_2      =  0.09981d0
tr_up_2        = time_double(tdate[0]+'/'+['16:51:50.000','16:52:33.000'])
tr_dn_2        = time_double(tdate[0]+'/'+['16:55:01.500','16:55:44.500'])
tr_ra_2        = time_double(tdate[0]+'/'+['16:54:31.240','16:54:33.120'])
tr_ft_2        = time_double(tdate[0]+'/'+['16:52:55.970','16:54:31.240'])
;;  Define mask and "UV" speeds
v_uv           = 60e1
v_thresh       = [25e1,25e1,25e1,25e1,30e1,50e1,50e1,50e1,50e1,50e1,75e1,75e1,75e1,75e1,75e1,75e1,75e1]
i_time0        = dat_copy.TIME
tr__bi0        = time_double(tdate[0]+'/'+['16:07:10','16:10:50'])
tr__bi1        = time_double(tdate[0]+'/'+['16:10:51','16:11:21'])
tr__bi2        = time_double(tdate[0]+'/'+['16:11:22','16:11:33'])
tr__bi3        = time_double(tdate[0]+'/'+['16:11:34','16:17:12'])
tr__bi4        = time_double(tdate[0]+'/'+['16:31:02','16:31:20'])
tr__bi5        = time_double(tdate[0]+'/'+['16:31:21','16:32:28'])
tr__bi6        = time_double(tdate[0]+'/'+['16:32:29','16:33:21'])
tr__bi7        = time_double(tdate[0]+'/'+['16:33:22','16:33:33'])
tr__bi8        = time_double(tdate[0]+'/'+['16:33:35','16:37:54'])
tr__bi9        = time_double(tdate[0]+'/'+['16:37:56','16:47:45'])
tr_bi10        = time_double(tdate[0]+'/'+['16:47:46','16:48:50'])
tr_bi11        = time_double(tdate[0]+'/'+['16:48:51','16:48:59'])
tr_bi12        = time_double(tdate[0]+'/'+['16:49:00','16:49:49'])
tr_bi13        = time_double(tdate[0]+'/'+['16:49:50','16:50:32'])
tr_bi14        = time_double(tdate[0]+'/'+['16:50:33','16:54:28'])
tr_bi15        = time_double(tdate[0]+'/'+['16:54:30','16:54:47'])
tr_bi16        = time_double(tdate[0]+'/'+['16:54:48','16:55:50'])
bad00          = WHERE(i_time0 GE  tr__bi0[0] AND i_time0 LE  tr__bi0[1], bd0)
bad01          = WHERE(i_time0 GE  tr__bi1[0] AND i_time0 LE  tr__bi1[1], bd1)
bad02          = WHERE(i_time0 GE  tr__bi2[0] AND i_time0 LE  tr__bi2[1], bd2)
bad03          = WHERE(i_time0 GE  tr__bi3[0] AND i_time0 LE  tr__bi3[1], bd3)
bad04          = WHERE(i_time0 GE  tr__bi4[0] AND i_time0 LE  tr__bi4[1], bd4)
bad05          = WHERE(i_time0 GE  tr__bi5[0] AND i_time0 LE  tr__bi5[1], bd5)
bad06          = WHERE(i_time0 GE  tr__bi6[0] AND i_time0 LE  tr__bi6[1], bd6)
bad07          = WHERE(i_time0 GE  tr__bi7[0] AND i_time0 LE  tr__bi7[1], bd7)
bad08          = WHERE(i_time0 GE  tr__bi8[0] AND i_time0 LE  tr__bi8[1], bd8)
bad09          = WHERE(i_time0 GE  tr__bi9[0] AND i_time0 LE  tr__bi9[1], bd9)
bad10          = WHERE(i_time0 GE  tr_bi10[0] AND i_time0 LE  tr_bi10[1], bd10)
bad11          = WHERE(i_time0 GE  tr_bi11[0] AND i_time0 LE  tr_bi11[1], bd11)
bad12          = WHERE(i_time0 GE  tr_bi12[0] AND i_time0 LE  tr_bi12[1], bd12)
bad13          = WHERE(i_time0 GE  tr_bi13[0] AND i_time0 LE  tr_bi13[1], bd13)
bad14          = WHERE(i_time0 GE  tr_bi14[0] AND i_time0 LE  tr_bi14[1], bd14)
bad15          = WHERE(i_time0 GE  tr_bi15[0] AND i_time0 LE  tr_bi15[1], bd15)
bad16          = WHERE(i_time0 GE  tr_bi16[0] AND i_time0 LE  tr_bi16[1], bd16)


;IF ( bd0  GT 0) THEN dummy[bad0]  = dumm_250[bad0]
;IF ( bd3  GT 0) THEN dummy[bad3]  = dumm_250[bad3]
;IF ( bd9  GT 0) THEN dummy[bad9]  = dumm_250[bad9]
;IF ( bd14 GT 0) THEN dummy[bad14] = dumm_250[bad14]
;
;IF ( bd12 GT 0) THEN dummy[bad12] = dumm_300[bad12]
;
;IF ( bd2  GT 0) THEN dummy[bad2]  = dumm_500[bad2]
;IF ( bd5  GT 0) THEN dummy[bad5]  = dumm_500[bad5]
;IF ( bd7  GT 0) THEN dummy[bad7]  = dumm_500[bad7]
;IF ( bd11 GT 0) THEN dummy[bad11] = dumm_500[bad11]
;IF ( bd15 GT 0) THEN dummy[bad15] = dumm_500[bad15]
;
;IF ( bd1  GT 0) THEN dummy[bad1]  = dumm_750[bad1]
;IF ( bd4  GT 0) THEN dummy[bad4]  = dumm_750[bad4]
;IF ( bd6  GT 0) THEN dummy[bad6]  = dumm_750[bad6]
;IF ( bd8  GT 0) THEN dummy[bad8]  = dumm_750[bad8]
;IF ( bd10 GT 0) THEN dummy[bad10] = dumm_750[bad10]
;IF ( bd13 GT 0) THEN dummy[bad13] = dumm_750[bad13]
;IF ( bd16 GT 0) THEN dummy[bad16] = dumm_750[bad16]

;;-------------------------------------
;;  2009-09-26 [1 Crossing]
;;-------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_a_data_2009-09-26_batch.pro
jj             = 8L
tdate          = '2009-09-26'
sc             = 'a'
pref           = 'th'+sc[0]+'_'
Nic_tpn        = pref[0]+'N_peib_no_GIs_UV'
shock_suff0    = '1st_Shock'
;;  Avg. terms [1st Shock]
Ni_up_0        =  9.66698d0
d_Ni_up_0      =  0.48493d0
tr_up_0        = time_double(tdate[0]+'/'+['15:55:05','15:57:30'])
tr_dn_0        = time_double(tdate[0]+'/'+['15:49:30','15:51:55'])
tr_ra_0        = time_double(tdate[0]+'/'+['15:53:09.911','15:53:10.249'])
tr_ft_0        = time_double(tdate[0]+'/'+['15:53:10.249','15:53:16.603'])
;;  Define mask and "UV" speeds
v_uv           = 60e1
v_thresh       = [20e1,25e1,25e1,25e1,50e1]
i_time0        = dat_igse.TIME
tr_bi0         = time_double(tdate[0]+'/'+['15:50:21','15:50:36'])
tr_bi1         = time_double(tdate[0]+'/'+['15:51:52','15:52:09'])
tr_bi2         = time_double(tdate[0]+'/'+['15:52:10','15:52:45'])
tr_bi3         = time_double(tdate[0]+'/'+['15:52:46','15:53:31'])
tr_bi4         = time_double(tdate[0]+'/'+['15:53:32','15:54:56'])
bad00          = WHERE(i_time0 GE tr_bi0[0] AND i_time0 LE tr_bi0[1],bd0)
bad01          = WHERE(i_time0 GE tr_bi1[0] AND i_time0 LE tr_bi1[1],bd1)
bad02          = WHERE(i_time0 GE tr_bi2[0] AND i_time0 LE tr_bi2[1],bd2)
bad03          = WHERE(i_time0 GE tr_bi3[0] AND i_time0 LE tr_bi3[1],bd3)
bad04          = WHERE(i_time0 GE tr_bi4[0] AND i_time0 LE tr_bi4[1],bd4)

;IF (bd3 GT 0) THEN dummy[bad3] = dumm_200[bad3]
;
;IF (bd0 GT 0) THEN dummy[bad0] = dumm_250[bad0]
;IF (bd1 GT 0) THEN dummy[bad1] = dumm_250[bad1]
;IF (bd4 GT 0) THEN dummy[bad4] = dumm_250[bad4]
;
;IF (bd2 GT 0) THEN dummy[bad2] = dumm_500[bad2]

;;-------------------------------------
;;  2011-10-24 [2 Crossings]
;;-------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_e_data_2011-10-24_batch.pro
jj             = [9L,10L]
tdate          = '2011-10-24'
sc             = 'e'
pref           = 'th'+sc[0]+'_'
;Nic_tpn        = pref[0]+'peeb_density'    ;;  --> Ions were "bad" for this event...
Nic_tpn        = pref[0]+'N_peib_no_GIs_UV'
shock_suff0    = '1st_Shock'
shock_suff1    = '2nd_Shock'
;;  Avg. terms [1st Shock]
Ni_up_0        = 33.55473d0
d_Ni_up_0      =  1.17835d0
tr_up_0        = time_double(tdate[0]+'/'+['18:32:42.300','18:35:08.400'])
tr_dn_0        = time_double(tdate[0]+'/'+['18:26:17.900','18:29:05.200'])
tr_ra_0        = time_double(tdate[0]+'/'+['18:31:56.880','18:31:57.290'])
tr_ft_0        = time_double(tdate[0]+'/'+['18:31:57.290','18:31:58.000'])

;;  Avg. terms [2nd Shock]
Ni_up_1        = 20.44722d0
d_Ni_up_1      =  0.18888d0
tr_up_1        = time_double(tdate[0]+'/'+['23:25:59.100','23:27:24.100'])
tr_dn_1        = time_double(tdate[0]+'/'+['23:32:17.700','23:33:42.700'])
tr_ra_1        = time_double(tdate[0]+'/'+['23:28:14.596','23:28:16.086'])
tr_ft_1        = time_double(tdate[0]+'/'+['23:27:57.200','23:28:14.596'])
;;  Define mask and "UV" speeds
v_uv           = 60e1
v_thresh       = [30e1,35e1,35e1,50e1,50e1]
i_time0        = dat_igse.TIME
tr_bi0         = time_double(tdate[0]+'/'+['18:31:50','18:32:00'])
tr_bi1         = time_double(tdate[0]+'/'+['18:32:02','18:36:32'])
tr_bi2         = time_double(tdate[0]+'/'+['23:24:23','23:28:14'])
tr_bi3         = time_double(tdate[0]+'/'+['23:28:16','23:28:42'])
tr_bi4         = time_double(tdate[0]+'/'+['23:28:44','23:34:18'])
bad00          = WHERE(i_time0 GE  tr_bi0[0] AND i_time0 LE  tr_bi0[1], bd0)
bad01          = WHERE(i_time0 GE  tr_bi1[0] AND i_time0 LE  tr_bi1[1], bd1)
bad02          = WHERE(i_time0 GE  tr_bi2[0] AND i_time0 LE  tr_bi2[1], bd2)
bad03          = WHERE(i_time0 GE  tr_bi3[0] AND i_time0 LE  tr_bi3[1], bd3)
bad04          = WHERE(i_time0 GE  tr_bi4[0] AND i_time0 LE  tr_bi4[1], bd4)

;IF ( bd2 GT 0) THEN dummy[bad2]  = dumm_300[bad2]
;
;IF ( bd1 GT 0) THEN dummy[bad1]  = dumm_350[bad1]
;IF ( bd3 GT 0) THEN dummy[bad3]  = dumm_350[bad3]
;
;IF ( bd0 GT 0) THEN dummy[bad0]  = dumm_500[bad0]
;IF ( bd4 GT 0) THEN dummy[bad4]  = dumm_500[bad4]

;;----------------------------------------------------------------------------------------
;;  Clean up
;;----------------------------------------------------------------------------------------
store_data,DELETE=tnames(pref[0]+'efw*')
store_data,DELETE=tnames(pref[0]+'efp*')
store_data,DELETE=tnames(pref[0]+'scw*')
store_data,DELETE=tnames(pref[0]+'scp*')

;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
shock_suffx    = [shock_suff0[0],shock_suff1[0],shock_suff2[0]]
Ni_up_s        = [Ni_up_0[0],Ni_up_1[0],Ni_up_2[0]]
tr_up_s        = [[tr_up_0],[tr_up_1],[tr_up_2]]
tr_dn_s        = [[tr_dn_0],[tr_dn_1],[tr_dn_2]]
tr_ra_s        = [[tr_ra_0],[tr_ra_1],[tr_ra_2]]
tr_ft_s        = [[tr_ft_0],[tr_ft_1],[tr_ft_2]]
test_sh        = FINITE(Ni_up_s)

testbad        = [N_ELEMENTS(bad00),N_ELEMENTS(bad01),N_ELEMENTS(bad02),$
                  N_ELEMENTS(bad03),N_ELEMENTS(bad04),N_ELEMENTS(bad05),$
                  N_ELEMENTS(bad06),N_ELEMENTS(bad07),N_ELEMENTS(bad08),$
                  N_ELEMENTS(bad09),N_ELEMENTS(bad10),N_ELEMENTS(bad11),$
                  N_ELEMENTS(bad12),N_ELEMENTS(bad13),N_ELEMENTS(bad14),$
                  N_ELEMENTS(bad15),N_ELEMENTS(bad16),N_ELEMENTS(bad17),$
                  N_ELEMENTS(bad18),N_ELEMENTS(bad19),N_ELEMENTS(bad20),$
                  N_ELEMENTS(bad21),N_ELEMENTS(bad22),N_ELEMENTS(bad23),$
                  N_ELEMENTS(bad24),N_ELEMENTS(bad25),N_ELEMENTS(bad26),$
                  N_ELEMENTS(bad27),N_ELEMENTS(bad28),N_ELEMENTS(bad29)] GT 0
nm             = LONG(TOTAL(testbad))
vth_strs       = STRING(v_thresh,FORMAT='(I3.3)')
ex_str_pref    = 'str_element,all_bad_els,'

FOR j=0L, nm[0] - 1L DO BEGIN                                                            $
  jbstr                 = STRING(j[0],FORMAT='(I2.2)')                                 & $
  jstr                  = 'VTH_'+jbstr[0]+'_'+vth_strs[j]                              & $
  ex_string    = ex_str_pref[0]+"'"+jstr[0]+"',bad"+jbstr[0]+',/ADD_REPLACE'           & $
  result       = EXECUTE(ex_string[0])

;;  Make sure it worked
HELP,all_bad_els,/STRUC

;bind_all       = -1
;FOR j=0L, nm[0] - 1L DO BEGIN                                           $
;  bind     = all_bad_els.(j)                                          & $
;  bind_all = [bind_all,bind]
;
;goodb          = WHERE(bind_all GE 0,gdb)
;bind_all       = bind_all[goodb]
;unq            = UNIQ(bind_all,SORT(bind_all))
;bind_all       = bind_all[unq]

;;----------------------------------------------------------------------------------------
;;  Redefine plot time range
;;----------------------------------------------------------------------------------------
tra_sh         = [MIN([tr_up_s,tr_dn_s],/NAN),MAX([tr_up_s,tr_dn_s],/NAN)] + [-1d0,1d0]*1d1
tlimit,tra_sh
;;----------------------------------------------------------------------------------------
;;  Define masks
;;----------------------------------------------------------------------------------------
dat_copy       = dat_igse

FOR j=0L, nm[0] - 1L DO BEGIN                                                  $
  bind    = all_bad_els.(j)                                                  & $
  jbstr   = STRING(j[0],FORMAT='(I2.2)')                                     & $
  jstr    = 'VTH_'+jbstr[0]+'_'+vth_strs[j]                                  & $
  v_th    = v_thresh[j]                                                      & $
  dat     = dat_copy[bind]                                                   & $
  mask0   = remove_uv_and_beam_ions(dat,V_THRESH=v_th[0],V_UV=v_uv[0])       & $
  str_element,all_masks,jstr[0],mask0,/ADD_REPLACE                           & $
  masked  = dat.DATA*mask0                                                   & $
  submask = dat.DATA - masked                                                & $
  str_element,masked_data,jstr[0],masked,/ADD_REPLACE                        & $
  str_element,subtra_mask,jstr[0],submask,/ADD_REPLACE

;;  Make sure it worked
HELP,all_masks,masked_data,subtra_mask,/STRUC

;;----------------------------------------------------------------------------------------
;;  Apply masks
;;----------------------------------------------------------------------------------------
dumm_m         = dat_igse        ;;  core solar wind beam only
dumm_s         = dat_igse        ;;  without " "

FOR j=0L, nm[0] - 1L DO BEGIN                                          $
  bind    = all_bad_els.(j)                                          & $
  masked  = masked_data.(j)                                          & $
  submask = subtra_mask.(j)                                          & $
  dumm_m[bind].DATA = masked                                         & $
  dumm_s[bind].DATA = submask
;;----------------------------------------------------------------------------------------
;;  Calculate moments [both core and "residue"]
;;----------------------------------------------------------------------------------------
coord_gse      = 'gse'
tp_hand0       = ['T_avg','V_Therm','N','Velocity','Tpara','Tperp','Tanisotropy','Pressure']
xsuff          = ''
tp_coor0       = REPLICATE(xsuff[0],N_ELEMENTS(tp_hand0))
good_coor0     = WHERE(tp_hand0 EQ 'Velocity' OR tp_hand0 EQ 'Pressure',gdcr0)
IF (gdcr0 GT 0) THEN tp_coor0[good_coor0] = '_'+STRLOWCASE(coord_gse[0])
v_units        = ' [km/s]'
t_units        = ' [eV]'
p_units        = ' [eV/cm!U3!N'+']'
d_units        = ' [#/cm!U3!N'+']'
t_pref         = ['T!D','!N'+t_units]
v_pref         = ['V!D','!N'+v_units]
p_pref         = ['P!D','!N'+p_units]
d_pref         = ['N!D','!N'+d_units]
t_ttle         = t_pref[0]+xsuff+t_pref[1]
vv_ttle        = v_pref[0]+xsuff+v_pref[1]
vt_ttle        = v_pref[0]+'T'+xsuff+v_pref[1]
den_ttle       = d_pref[0]+xsuff+d_pref[1]
tpa_ttle       = t_pref[0]+'!9#!3'+xsuff+t_pref[1]
tpe_ttle       = t_pref[0]+'!9x!3'+xsuff+t_pref[1]
pre_ttle       = p_pref[0]+xsuff+p_pref[1]
tan_ttle       = t_pref[0]+'!9x!3'+xsuff+'!N'+'/'+t_pref[0]+'!9#!3'+xsuff+'!N'
tp_ttles       = [t_ttle,vt_ttle,den_ttle,vv_ttle,tpa_ttle,tpe_ttle,tan_ttle,pre_ttle]
;;----------------------------------------------------
;;----------------------------------------------------
sform          = moments_3d_new()
n_i            = N_ELEMENTS(dumm_m)
str_element,sform,'END_TIME',0d0,/ADD_REPLACE
momb_m         = REPLICATE(sform[0],n_i)
momb_s         = REPLICATE(sform[0],n_i)
true_vbulk     = REFORM(dumm_s.VSW)
true_magf      = REFORM(dumm_s.MAGF)
true_scpot     = REFORM(dumm_s.SC_POT[0])
FOR j=0L, n_i - 1L DO BEGIN                                                        $
  tmomm   = 0                                                                    & $
  tmoms   = 0                                                                    & $
  delm    = dumm_m[j]                                                            & $
  dels    = dumm_s[j]                                                            & $
  pot     = true_scpot[j]                                                        & $
  tmagf   = REFORM(true_magf[*,j])                                               & $
  tvsw    = REFORM(true_vbulk[*,j])                                              & $
  ex_str  = {FORMAT:sform,DOMEGA_WEIGHTS:1,TRUE_VBULK:tvsw,MAGDIR:tmagf}         & $
  tmomm   = moments_3d_new(delm,SC_POT=pot[0],_EXTRA=ex_str)                     & $
  tmoms   = moments_3d_new(dels,SC_POT=pot[0],_EXTRA=ex_str)                     & $
  str_element,tmomm,'END_TIME',delm[0].END_TIME,/ADD_REPLACE                     & $
  str_element,tmoms,'END_TIME',dels[0].END_TIME,/ADD_REPLACE                     & $
  momb_m[j] = tmomm[0]                                                           & $
  momb_s[j] = tmoms[0]

times          = (momb_m.TIME + momb_m.END_TIME)/2d0
;;  Define relevant quantities
p_els          = [0L,4L,8L]                   ;;  Diagonal elements of a 3x3 matrix
avgtemp_m      = REFORM(momb_m.AVGTEMP)       ;;  Avg. Particle Temp (eV)
v_therm_m      = REFORM(momb_m.VTHERMAL)      ;;  Avg. Particle Thermal Speed (km/s)
tempvec_m      = TRANSPOSE(momb_m.MAGT3)      ;;  Vector Temp [perp1,perp2,para] (eV)
velocity_m     = TRANSPOSE(momb_m.VELOCITY)   ;;  Velocity vectors (km/s)
p_tensor_m     = TRANSPOSE(momb_m.PTENS)      ;;  Pressure tensor [eV cm^(-3)]
density_m      = REFORM(momb_m.DENSITY)       ;;  Particle density [# cm^(-3)]

t_perp_m       = 5e-1*(tempvec_m[*,0] + tempvec_m[*,1])
t_para_m       = REFORM(tempvec_m[*,2])
tanis_m        = t_perp_m/t_para_m
pressure_m     = TOTAL(p_tensor_m[*,p_els],2,/NAN)/3.

avgtemp_s      = REFORM(momb_s.AVGTEMP)       ;;  Avg. Particle Temp (eV)
v_therm_s      = REFORM(momb_s.VTHERMAL)      ;;  Avg. Particle Thermal Speed (km/s)
tempvec_s      = TRANSPOSE(momb_s.MAGT3)      ;;  Vector Temp [perp1,perp2,para] (eV)
velocity_s     = TRANSPOSE(momb_s.VELOCITY)   ;;  Velocity vectors (km/s)
p_tensor_s     = TRANSPOSE(momb_s.PTENS)      ;;  Pressure tensor [eV cm^(-3)]
density_s      = REFORM(momb_s.DENSITY)       ;;  Particle density [# cm^(-3)]

t_perp_s       = 5e-1*(tempvec_s[*,0] + tempvec_s[*,1])
t_para_s       = REFORM(tempvec_s[*,2])
tanis_s        = t_perp_s/t_para_s
pressure_s     = TOTAL(p_tensor_s[*,p_els],2,/NAN)/3.



;;  Define TPLOT specific quantities
tp_hand_m      = pref[0]+tp_hand0+tp_coor0+'_peib_no_GIs_UV_w__core'
tp_hand_s      = pref[0]+tp_hand0+tp_coor0+'_peib_no_GIs_UV_wo_core'
scup           = STRUPCASE(sc[0])
ysub_m         = '[TH-'+scup[0]+', IESA Burst]'+'!C'+'[Only Core]'
ysub_s         = '[TH-'+scup[0]+', IESA Burst]'+'!C'+'[Removed Core]'

dstr_m         = CREATE_STRUCT(tp_hand_m,avgtemp_m,v_therm_m,density_m,velocity_m,$
                               t_para_m,t_perp_m,tanis_m,pressure_m)

dstr_s         = CREATE_STRUCT(tp_hand_s,avgtemp_s,v_therm_s,density_s,velocity_s,$
                               t_para_s,t_perp_s,tanis_s,pressure_s)

FOR j=0L, N_ELEMENTS(tp_hand_m) - 1L DO BEGIN                                $
  dat_0  = dstr_m.(j)                                                      & $
  store_data,tp_hand_m[j],DATA={X:times,Y:dat_0}                           & $
  options,tp_hand_m[j],'YTITLE',tp_ttles[j],/DEF                           & $
  options,tp_hand_m[j],'YSUBTITLE',ysub_m[0],/DEF                          & $
  IF (tp_hand0[j] EQ 'Velocity') THEN gcols = 1 ELSE gcols = 0             & $
  IF (gcols) THEN options,tp_hand_m[j],'COLORS',[250L,150L,50L],/DEF

FOR j=0L, N_ELEMENTS(tp_hand_s) - 1L DO BEGIN                                $
  dat_0  = dstr_s.(j)                                                      & $
  store_data,tp_hand_s[j],DATA={X:times,Y:dat_0}                           & $
  options,tp_hand_s[j],'YTITLE',tp_ttles[j],/DEF                           & $
  options,tp_hand_s[j],'YSUBTITLE',ysub_s[0],/DEF                          & $
  IF (tp_hand0[j] EQ 'Velocity') THEN gcols = 1 ELSE gcols = 0             & $
  IF (gcols) THEN options,tp_hand_s[j],'COLORS',[250L,150L,50L],/DEF

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01



;;  Plot and compare
fgm_tpn        = pref[0]+'fgh_'+['mag','gse']
Ne__tpn        = pref[0]+'peeb_density'
Nio_tpn        = pref[0]+'peib_density'
Nic_tpn        = tnames(Nic_tpn[0])
Ni_w__c_tpn    = tp_hand_m[2]
Ni_wo_c_tpn    = tp_hand_s[2]

all_den_tpn    = [Ne__tpn,Nio_tpn,Nic_tpn,Ni_w__c_tpn,Ni_wo_c_tpn]
IF (tdate[0] EQ '2009-07-13') THEN den_ran = [0d0,70d0]
IF (tdate[0] EQ '2009-07-21') THEN den_ran = [0d0,55d0]
IF (tdate[0] EQ '2009-07-23') THEN den_ran = [0d0,40d0]
IF (tdate[0] EQ '2009-09-05') THEN den_ran = [0d0,45d0]
IF (tdate[0] EQ '2009-09-26') THEN den_ran = [0d0,12d1]
IF (tdate[0] EQ '2011-10-24') THEN den_ran = [0d0,13d1]
options,all_den_tpn,'YRANGE'
options,all_den_tpn,'YTICKLEN'
options,all_den_tpn,'YGRIDSTYLE'
options,all_den_tpn,'YRANGE',den_ran,/DEF
options,all_den_tpn,'YTICKLEN',1.0,/DEF
options,all_den_tpn,'YGRIDSTYLE',1,/DEF

options,[Ni_w__c_tpn,Ni_wo_c_tpn],'YLOG'
options,[Ni_w__c_tpn,Ni_wo_c_tpn],'YLOG',0,/DEF
options,[Ni_w__c_tpn,Ni_wo_c_tpn],'YRANGE',[1d-1,MAX(den_ran)],/DEF

nna            = [fgm_tpn,Ne__tpn,Nio_tpn,Nic_tpn,Ni_w__c_tpn,Ni_wo_c_tpn]
  tplot,nna,/NOM


;;  Ni [level-2]
get_data,Nio_tpn[0],DATA=str_iodens,DLIM=dlim_iodens,LIM=lim_iodens
Ni_L2_t        = str_iodens.X
Ni_L2_v        = str_iodens.Y

;;  Force onto a uniform timestep
Ni_L2_v_t2     = interp(Ni_L2_v,Ni_L2_t,times,/NO_EXTRAP)

;;  Define ratios
r_c_2_L2       = density_m/Ni_L2_v_t2         ;;  Core Only to L2
r_h_2_L2       = density_s/Ni_L2_v_t2         ;;  Halo Only to L2

bad            = WHERE(r_c_2_L2 GT 1)
IF (bad[0] GE 0) THEN r_c_2_L2[bad] = d
bad            = WHERE(r_h_2_L2 GT 1)
IF (bad[0] GE 0) THEN r_h_2_L2[bad] = d


PLOT,r_c_2_L2,YRANGE=[0d0,1.2d0],/XSTYLE,/YSTYLE,/NODATA
  OPLOT,r_c_2_L2,PSYM=1,COLOR=250
  OPLOT,r_h_2_L2,PSYM=6,COLOR= 50



yran           = [0.,1.1]
nt             = 10L
ytickv         = DINDGEN(nt[0])*1d-1 + 1d-1
ytickn         = STRTRIM(STRING(ytickv,FORMAT='(f15.1)'),2L)
yticks         = nt[0] - 1L

thck           = 4.0
chsz           = 2.0
xyored         = 'N_ir/N_itot [All]'
xyogre         = 'N_ic/N_itot [All]'
xyoblu         = 'N_itot/MAX(N_itot)'
xpos           = 0.20
ypos           = [0.40,0.33,0.26]
fnames         = 'Percent_densities_Nir_Nic_Nitot_'+tdate[0]+'_'+shock_suffx
xttle          = 'Time [sec. from start of '+shock_suffx+']'
yttle          = '% N_is [Reflected=Red, Corrected=Green, Total=Blue]'
pttle          = 'Relative Densities for '+tdate[0]
pstr           = {XSTYLE:1,YSTYLE:1,YRANGE:yran,NODATA:1,YTICKLEN:1.,YGRIDSTYLE:1,$
                  YTITLE:yttle,THICK:thck[0],TITLE:pttle[0],YMINOR:10L,$
                  YTICKNAME:ytickn,YTICKV:ytickv,YTICKS:yticks}
xystr          = {CHARSIZE:chsz[0],NORMAL:1}
ni_c__t        = times
c              = [250L,200L, 50L]

FOR j=0L, 2L DO BEGIN                                                        $
  tru0  = REFORM(tr_up_s[*,j])                                             & $
  trd0  = REFORM(tr_dn_s[*,j])                                             & $
  trr0  = REFORM(tr_ra_s[*,j])                                             & $
  tr0   = [MIN([tru0,trd0],/NAN),MAX([tru0,trd0],/NAN)]                    & $
  tr1   = [MIN([tru0,trr0],/NAN),MAX([tru0,trr0],/NAN)]                    & $
  IF (test_sh[j] EQ 0) THEN CONTINUE                                       & $
  test  = (ni_c__t GE tr1[0]) AND (ni_c__t LE tr1[1])                      & $
  gind  = WHERE(test,gd)                                                   & $
  nrat1 = r_h_2_L2[gind]                                                   & $
  test  = (ni_c__t GE tr0[0]) AND (ni_c__t LE tr0[1])                      & $
  good  = WHERE(test,gd)                                                   & $
  t0    = ni_c__t[good] - MIN(ni_c__t[good],/NAN)                          & $
  t0c   = ni_c__t[gind] - MIN(ni_c__t[good],/NAN)                          & $
  trra0 = REFORM(tr_ra_s[*,j]) - MIN(ni_c__t[good],/NAN)                   & $
  vbarx = [trra0[0],trra0[0],trra0[1],trra0[1]]                            & $
  vbary = [yran[0],yran[1],yran[0],yran[1]]                                & $
  nrat2 = r_c_2_L2[good]                                                   & $
  nrat3 = Ni_L2_v_t2[good]/MAX(Ni_L2_v_t2[good],/NAN)                      & $
  popen,fnames[j],/LAND                                                    & $
    PLOT,t0,nrat1,XTITLE=xttle[j],_EXTRA=pstr[0]                           & $
      OPLOT,t0c,nrat1,COLOR=c[0],THICK=thck[0]                             & $
      OPLOT,t0,nrat2,COLOR=c[1],THICK=thck[0],LINESTYLE=2                  & $
      OPLOT,t0,nrat3,COLOR=c[2],THICK=thck[0]                              & $
      OPLOT,vbarx[0:1],vbary[0:1],COLOR=150,THICK=thck[0]                  & $
      OPLOT,vbarx[2:3],vbary[2:3],COLOR=150,THICK=thck[0]                  & $
      XYOUTS,xpos[0],ypos[2],xyored[0],COLOR=c[0],_EXTRA=xystr[0]          & $
      XYOUTS,xpos[0],ypos[1],xyogre[0],COLOR=c[1],_EXTRA=xystr[0]          & $
      XYOUTS,xpos[0],ypos[0],xyoblu[0],COLOR=c[2],_EXTRA=xystr[0]          & $
  pclose
















