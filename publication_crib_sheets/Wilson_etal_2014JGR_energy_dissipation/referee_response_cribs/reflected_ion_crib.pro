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

;;;----------------------------------------------------------------------------------------
;;;  Load Rankine-Hugoniot results
;;;----------------------------------------------------------------------------------------
;.compile thm_load_bowshock_rhsolns
;thm_load_bowshock_rhsolns,R_STRUCT=diss_rates
;;;  Define parameters for given shock
;rhparms        = diss_rates.(jj[0])
;Ni_up_0        = rhparms.UP.NI
;Ti_up_0        = rhparms.UP.TI
;Te_up_0        = rhparms.UP.TE
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
;;----------------------------------------------------------------------------------------
;;  Redefine plot time range
;;----------------------------------------------------------------------------------------
tra_sh         = [MIN([tr_up_s,tr_dn_s],/NAN),MAX([tr_up_s,tr_dn_s],/NAN)] + [-1d0,1d0]*1d1
tlimit,tra_sh

;;----------------------------------------------------------------------------------------
;;  Get "corrected" and level-2 ion densities
;;----------------------------------------------------------------------------------------
den_name       = tnames(Nic_tpn[0])
;;  Ni ["corrected"]
get_data,den_name[0],DATA=str__cdens,DLIM=dlim__cdens,LIM=lim__cdens
;;  Define parameters
ni_c__t        = str__cdens.X
ni_c__v        = str__cdens.Y
;;  Ni [level-2]
tpn_name       = tnames(pref[0]+'peib_density')
get_data,tpn_name[0],DATA=str_L2dens,DLIM=dlim_L2dens,LIM=lim_L2dens
;;  Define parameters
ni_L2_t        = str_L2dens.X
ni_L2_v        = str_L2dens.Y
;;  Force onto uniform time stamps
Ni_L2_tv       = interp(ni_L2_v,ni_L2_t,ni_c__t,/NO_EXTRAP)
;;----------------------------------------------------------------------------------------
;;  Define elements for downstream, ramp, foot, and upstream
;;----------------------------------------------------------------------------------------
FOR j=0L, 2L DO BEGIN                                                       $
  jstr = STRING(j[0],FORMAT='(I2.2)')                                     & $
  tru0 = REFORM(tr_up_s[*,j])                                             & $
  trd0 = REFORM(tr_dn_s[*,j])                                             & $
  trr0 = REFORM(tr_ra_s[*,j])                                             & $
  trf0 = REFORM(tr_ft_s[*,j])                                             & $
  testup = (ni_c__t GE tru0[0]) AND (ni_c__t LE tru0[1])                  & $
  testdn = (ni_c__t GE trd0[0]) AND (ni_c__t LE trd0[1])                  & $
  testra = (ni_c__t GE trr0[0]) AND (ni_c__t LE trr0[1])                  & $
  testft = (ni_c__t GE trf0[0]) AND (ni_c__t LE trf0[1])                  & $
  IF (test_sh[j]) THEN goodup = WHERE(testup) ELSE goodup = -1            & $
  IF (test_sh[j]) THEN gooddn = WHERE(testdn) ELSE gooddn = -1            & $
  IF (test_sh[j]) THEN goodra = WHERE(testra) ELSE goodra = -1            & $
  IF (test_sh[j]) THEN goodft = WHERE(testft) ELSE goodft = -1            & $
  IF (test_sh[j] AND j EQ 0) THEN good_up0 = goodup                       & $
  IF (test_sh[j] AND j EQ 0) THEN good_dn0 = gooddn                       & $
  IF (test_sh[j] AND j EQ 0) THEN good_ra0 = goodra                       & $
  IF (test_sh[j] AND j EQ 0) THEN good_ft0 = goodft                       & $
  IF (test_sh[j] AND j EQ 1) THEN good_up1 = goodup                       & $
  IF (test_sh[j] AND j EQ 1) THEN good_dn1 = gooddn                       & $
  IF (test_sh[j] AND j EQ 1) THEN good_ra1 = goodra                       & $
  IF (test_sh[j] AND j EQ 1) THEN good_ft1 = goodft                       & $
  IF (test_sh[j] AND j EQ 2) THEN good_up2 = goodup                       & $
  IF (test_sh[j] AND j EQ 2) THEN good_dn2 = gooddn                       & $
  IF (test_sh[j] AND j EQ 2) THEN good_ra2 = goodra                       & $
  IF (test_sh[j] AND j EQ 2) THEN good_ft2 = goodft

;;----------------------------------------------------------------------------------------
;;  Define ratios at each time stamp and Ni/<Nic>_up
;;----------------------------------------------------------------------------------------
n_ni           = N_ELEMENTS(ni_c__t)
del_Ni_all_t   = REPLICATE(d,n_ni[0])
del_Ni_avg_u   = REPLICATE(d,n_ni[0],3L)
Ni_rat_all_t   = REPLICATE(d,n_ni[0])
Ni_rat_avg_u   = REPLICATE(d,n_ni[0],3L)

;;  Define ∆Ni = (Ni_l2 - Ni_c) --> proxy for Ni_r
del_Ni_all_t   = (Ni_L2_tv - ni_c__v) > 0d0
FOR j=0L, 2L DO IF (test_sh[j]) THEN del_Ni_avg_u[*,j] = (Ni_L2_tv - Ni_up_s[j]) > 0d0

yran_perc      = [1d-3,1.5d0]
Ni_rat_all_t   = ABS(del_Ni_all_t)/Ni_L2_tv
Ni_rat_avg_u   = ABS(del_Ni_avg_u)/(Ni_L2_tv # REPLICATE(1d0,3L))

;;  Send |∆Ni| and |∆Ni|/Ni [All] to TPLOT
del_Ni_at_tpn  = 'NiL2_Nic_AbsDiff_'+shock_suffx
Ni_rat_at_tpn  = 'Nir_all__AbsDiff_'+shock_suffx

FOR j=0L, 2L DO BEGIN                                                       $
  tru0 = REFORM(tr_up_s[*,j])                                             & $
  trd0 = REFORM(tr_dn_s[*,j])                                             & $
  tr0  = [MIN([tru0,trd0],/NAN),MAX([tru0,trd0],/NAN)]                    & $
  IF (test_sh[j] EQ 0) THEN CONTINUE                                      & $
  test = (ni_c__t GE tr0[0]) AND (ni_c__t LE tr0[1])                      & $
  good = WHERE(test,gd)                                                   & $
  struc = {X:ni_c__t[good],Y:ABS(del_Ni_all_t[good])}                     & $
  store_data,del_Ni_at_tpn[j],DATA=struc,DLIM=dlim__cdens,LIM=lim__cdens  & $
  struc = {X:ni_c__t[good],Y:ABS(Ni_rat_all_t[good])}                     & $
  store_data,Ni_rat_at_tpn[j],DATA=struc,DLIM=dlim__cdens,LIM=lim__cdens
;;  Redefine options
options,tnames(del_Ni_at_tpn),'YTITLE'
options,tnames(del_Ni_at_tpn),  'YLOG'
options,tnames(del_Ni_at_tpn),'YTITLE','|dNi| [cm^(-3), All]',/DEF
options,tnames(del_Ni_at_tpn),  'YLOG',                     0,/DEF
options,tnames(Ni_rat_at_tpn),'YTITLE'
options,tnames(Ni_rat_at_tpn),  'YLOG'
options,tnames(Ni_rat_at_tpn),'YRANGE'
options,tnames(Ni_rat_at_tpn),'YTITLE',   '|dNi|/Ni [%, All]',/DEF
options,tnames(Ni_rat_at_tpn),  'YLOG',                     1,/DEF
options,tnames(Ni_rat_at_tpn),'YRANGE',             yran_perc,/DEF

;;  Send |∆Ni| [Avg. Up] to TPLOT
del_Ni_au_tpn  = 'NiL2_AvgNiup_AbsDiff_'+shock_suffx
Ni_rat_au_tpn  = 'Nir__AvgNiup_AbsDiff_'+shock_suffx
FOR j=0L, 2L DO BEGIN                                                       $
  tru0 = REFORM(tr_up_s[*,j])                                             & $
  trd0 = REFORM(tr_dn_s[*,j])                                             & $
  tr0  = [MIN([tru0,trd0],/NAN),MAX([tru0,trd0],/NAN)]                    & $
  IF (test_sh[j] EQ 0) THEN CONTINUE                                      & $
  test = (ni_c__t GE tr0[0]) AND (ni_c__t LE tr0[1])                      & $
  good = WHERE(test,gd)                                                   & $
  struc = {X:ni_c__t[good],Y:ABS(del_Ni_avg_u[good,j])}                   & $
  store_data,del_Ni_au_tpn[j],DATA=struc,DLIM=dlim__cdens,LIM=lim__cdens  & $
  struc = {X:ni_c__t[good],Y:ABS(Ni_rat_avg_u[good,j])}                   & $
  store_data,Ni_rat_au_tpn[j],DATA=struc,DLIM=dlim__cdens,LIM=lim__cdens
;;  Redefine options
options,tnames(del_Ni_au_tpn),'YTITLE'
options,tnames(del_Ni_au_tpn),  'YLOG'
options,tnames(del_Ni_au_tpn),'YTITLE','|dNi| [cm^(-3), <Ni>_up]',/DEF
options,tnames(del_Ni_au_tpn),  'YLOG',                         0,/DEF
options,tnames(Ni_rat_au_tpn),'YTITLE'
options,tnames(Ni_rat_au_tpn),  'YLOG'
options,tnames(Ni_rat_au_tpn),'YRANGE'
options,tnames(Ni_rat_au_tpn),'YTITLE',   '|dNi|/Ni [%, <Ni>_up]',/DEF
options,tnames(Ni_rat_au_tpn),  'YLOG',                         1,/DEF
options,tnames(Ni_rat_au_tpn),'YRANGE',                 yran_perc,/DEF

options,tnames([Ni_rat_at_tpn,Ni_rat_au_tpn]),'YTICKLEN'
options,tnames([Ni_rat_at_tpn,Ni_rat_au_tpn]),'YGRIDSTYLE'
options,tnames([Ni_rat_at_tpn,Ni_rat_au_tpn]),  'YTICKLEN',1.0,/DEF       ;;  use dotted lines
options,tnames([Ni_rat_at_tpn,Ni_rat_au_tpn]),'YGRIDSTYLE',  1,/DEF       ;;  use dotted lines


;;---------------------------------------------------------------------------------------------------------------------------------------
;;  All Dates [YYYY-MM-DD]
;;=======================================================================================================================================
;;  2009-07-13  2009-07-21  2009-07-23  2009-07-23  2009-07-23  2009-09-05  2009-09-05  2009-09-05  2009-09-26  2011-10-24  2011-10-24
;;---------------------------------------------------------------------------------------------------------------------------------------

fgm_tpn        = pref[0]+'fgh_'+['mag','gse']
Ne__tpn        = pref[0]+'peeb_density'
Nio_tpn        = pref[0]+'peib_density'
Nic_tpn        = den_name[0]
nna            = [fgm_tpn,Ne__tpn,Nio_tpn,Nic_tpn]
  tplot,nna,/NOM

kk             = 0L
nna            = [fgm_tpn,Ne__tpn,Nic_tpn,del_Ni_at_tpn,del_Ni_au_tpn]
  tplot,nna,/NOM
  time_bar,REFORM(tr_ft_s[*,kk[0]]),COLOR=250,VARNAME=nna
  time_bar,MEAN(REFORM(tr_ra_s[*,kk[0]]),/NAN),COLOR=150,VARNAME=nna

nna            = [fgm_tpn,del_Ni_at_tpn,del_Ni_au_tpn]
  tplot,nna,/NOM

nna            = [fgm_tpn,Ni_rat_at_tpn,Ni_rat_au_tpn]
  tplot,nna,/NOM


;;---------------------------------------------------------------------------------------------------------------------------------------
;;  Force uniform Y-Range for original and "corrected" densities
;;---------------------------------------------------------------------------------------------------------------------------------------

;;  Ne [level-2]
get_data,Ne__tpn[0],DATA=str_eodens,DLIM=dlim_eodens,LIM=lim_eodens
;;  Ni [level-2]
get_data,Nio_tpn[0],DATA=str_iodens,DLIM=dlim_iodens,LIM=lim_iodens
;;  Ni ["corrected"]
get_data,Nic_tpn[0],DATA=str_icdens,DLIM=dlim_icdens,LIM=lim_icdens

tra_sh         = [MIN([tr_up_s,tr_dn_s],/NAN),MAX([tr_up_s,tr_dn_s],/NAN)] + [-1d0,1d0]*1d1
test_eo        = (str_eodens.X GE tra_sh[0]) AND (str_eodens.X LE tra_sh[1])
test_io        = (str_iodens.X GE tra_sh[0]) AND (str_iodens.X LE tra_sh[1])
test_ic        = (str_icdens.X GE tra_sh[0]) AND (str_icdens.X LE tra_sh[1])

good_eo        = WHERE(test_eo,gd_eo)
good_io        = WHERE(test_io,gd_io)
good_ic        = WHERE(test_ic,gd_ic)
PRINT,';;',gd_eo[0],gd_io[0],gd_ic[0],'  -->  For  '+tdate[0]
;;          89          88          88  -->  For  2009-07-13
;;         254         254         254  -->  For  2009-07-21
;;         487         487         487  -->  For  2009-07-23
;;         513         513         513  -->  For  2009-09-05
;;         165         165         165  -->  For  2009-09-26
;;         394         395         395  -->  For  2011-10-24

mxn            = 0d0
first_last     = ';;========================================================================'
all_d_strs     = '  '+['Ne[L2]','Ni[L2]','Ni[Corr]']
all_dens       = {T0:str_eodens.Y,T1:str_iodens.Y,T2:str_icdens.Y}
FOR j=0L, 2L DO BEGIN                                                       $
  IF (j EQ 0) THEN x = good_eo                                            & $
  IF (j EQ 1) THEN x = good_io                                            & $
  IF (j EQ 2) THEN x = good_ic                                            & $
  mxn  = mxn[0] > MAX(ABS(all_dens.(j)[x]),/NAN)                          & $
  den0 = FLOAT(all_dens.(j)[x])                                           & $
  str0 = '  -->  For  '+tdate[0]+'  '+all_d_strs[j]                       & $
  IF (j EQ 0) THEN PRINT,';;'                                             & $
  IF (j EQ 0) THEN PRINT,first_last[0]                                    & $
  PRINT,';;',MIN(den0,/NAN),MAX(den0,/NAN),str0[0]                        & $
  IF (j EQ 2) THEN PRINT,first_last[0]
;;========================================================================
;;      12.1731      66.3186  -->  For  2009-07-13    Ne[L2]
;;      7.64778      66.7645  -->  For  2009-07-13    Ni[L2]
;;      6.50510      62.6787  -->  For  2009-07-13    Ni[Corr]
;;========================================================================
;;
;;========================================================================
;;      5.16527      53.2061  -->  For  2009-07-21    Ne[L2]
;;      3.68658      52.1360  -->  For  2009-07-21    Ni[L2]
;;      1.71317      51.5915  -->  For  2009-07-21    Ni[Corr]
;;========================================================================
;;
;;========================================================================
;;      3.69951      35.6198  -->  For  2009-07-23    Ne[L2]
;;      3.68053      35.6778  -->  For  2009-07-23    Ni[L2]
;;      3.62596      36.5492  -->  For  2009-07-23    Ni[Corr]
;;========================================================================
;;
;;========================================================================
;;     0.531349      27.5800  -->  For  2009-09-05    Ne[L2]
;;     0.885186      41.5584  -->  For  2009-09-05    Ni[L2]
;;     0.115461      40.2590  -->  For  2009-09-05    Ni[Corr]
;;========================================================================
;;
;;========================================================================
;;      11.2048      110.571  -->  For  2009-09-26    Ne[L2]
;;      9.09711      117.990  -->  For  2009-09-26    Ni[L2]
;;      8.45884      113.342  -->  For  2009-09-26    Ni[Corr]
;;========================================================================
;;
;;========================================================================
;;      20.1912      123.789  -->  For  2011-10-24    Ne[L2]
;;      17.7325      113.847  -->  For  2011-10-24    Ni[L2]
;;      17.5133      104.680  -->  For  2011-10-24    Ni[Corr]
;;========================================================================

yran_aden      = [0d0,1.05d0*mxn[0]]
options,[Ne__tpn[0],Nio_tpn[0],Nic_tpn[0],del_Ni_at_tpn[0],del_Ni_au_tpn[0]],'YRANGE'
options,[Ne__tpn[0],Nio_tpn[0],Nic_tpn[0],del_Ni_at_tpn[0],del_Ni_au_tpn[0]],'YTICKLEN'
options,[Ne__tpn[0],Nio_tpn[0],Nic_tpn[0],del_Ni_at_tpn[0],del_Ni_au_tpn[0]],'YGRIDSTYLE'
options,[Ne__tpn[0],Nio_tpn[0],Nic_tpn[0],del_Ni_at_tpn[0],del_Ni_au_tpn[0]],'YRANGE',yran_aden,/DEF
options,[Ne__tpn[0],Nio_tpn[0],Nic_tpn[0],del_Ni_at_tpn[0],del_Ni_au_tpn[0]],'YTICKLEN',1.0,/DEF
options,[Ne__tpn[0],Nio_tpn[0],Nic_tpn[0],del_Ni_at_tpn[0],del_Ni_au_tpn[0]],'YGRIDSTYLE',1,/DEF

nna            = [fgm_tpn,Ne__tpn[0],Nio_tpn[0],Nic_tpn[0]]
  tplot,nna,/NOM,TRANGE=tra_sh
;;---------------------------------------------------------------------------------------------------------------------------------------
;;  Plot on same plot
;;---------------------------------------------------------------------------------------------------------------------------------------
wi,1

nrat1          = del_Ni_all_t[good_ic]/Ni_L2_tv[good_ic]
nrat3          = Ni_L2_tv[good_ic]/MAX(Ni_L2_tv[good_ic],/NAN)
PLOT,t0,nrat1,/XSTYLE,/YSTYLE,YRANGE=[0.,1.1],/NODATA,YTICKLEN=1.,YGRIDSTYLE=1
  OPLOT,t0,nrat1,COLOR=250
  OPLOT,t0,nrat3,COLOR= 50

yran           = [0.,1.1]
nt             = 10L
ytickv         = DINDGEN(nt[0])*1d-1 + 1d-1
ytickn         = STRTRIM(STRING(ytickv,FORMAT='(f15.1)'),2L)
yticks         = nt[0] - 1L

thck           = 4.0
chsz           = 2.0
xyored         = 'N_ir/N_itot [All]'
xyoblu         = 'N_itot/MAX(N_itot)'
xpos           = 0.20
ypos           = [0.40,0.33]

fnames         = 'Percent_densities_Nir_Nitot_'+tdate[0]+'_'+shock_suffx
xttle          = 'Time [sec. from start of '+shock_suffx+']'
yttle          = '% N_is [Reflected=Red, Total=Blue]'
pttle          = 'Relative Densities for '+tdate[0]
pstr           = {XSTYLE:1,YSTYLE:1,YRANGE:yran,NODATA:1,YTICKLEN:1.,YGRIDSTYLE:1,$
                  YTITLE:yttle,THICK:thck[0],TITLE:pttle[0],YMINOR:10L,$
                  YTICKNAME:ytickn,YTICKV:ytickv,YTICKS:yticks}
xystr          = {CHARSIZE:chsz[0],NORMAL:1}

FOR j=0L, 2L DO BEGIN                                                        $
  tru0  = REFORM(tr_up_s[*,j])                                             & $
  trd0  = REFORM(tr_dn_s[*,j])                                             & $
  tr0   = [MIN([tru0,trd0],/NAN),MAX([tru0,trd0],/NAN)]                    & $
  IF (test_sh[j] EQ 0) THEN CONTINUE                                       & $
  test  = (ni_c__t GE tr0[0]) AND (ni_c__t LE tr0[1])                      & $
  good  = WHERE(test,gd)                                                   & $
  t0    = ni_c__t[good] - MIN(ni_c__t[good],/NAN)                          & $
  trra0 = REFORM(tr_ra_s[*,j]) - MIN(ni_c__t[good],/NAN)                   & $
  vbarx = [trra0[0],trra0[0],trra0[1],trra0[1]]                            & $
  vbary = [yran[0],yran[1],yran[0],yran[1]]                                & $
  nrat1 = del_Ni_all_t[good]/Ni_L2_tv[good]                                & $
  nrat3 = Ni_L2_tv[good]/MAX(Ni_L2_tv[good],/NAN)                          & $
  popen,fnames[j],/LAND                                                    & $
    PLOT,t0,nrat1,XTITLE=xttle[j],_EXTRA=pstr[0]                           & $
      OPLOT,t0,nrat1,COLOR=250,THICK=thck[0]                               & $
      OPLOT,t0,nrat3,COLOR= 50,THICK=thck[0]                               & $
      OPLOT,vbarx[0:1],vbary[0:1],COLOR=150,THICK=thck[0]                  & $
      OPLOT,vbarx[2:3],vbary[2:3],COLOR=150,THICK=thck[0]                  & $
      XYOUTS,xpos[0],ypos[0],xyoblu[0],COLOR= 50,_EXTRA=xystr[0]           & $
      XYOUTS,xpos[0],ypos[1],xyored[0],COLOR=250,_EXTRA=xystr[0]           & $
  pclose




