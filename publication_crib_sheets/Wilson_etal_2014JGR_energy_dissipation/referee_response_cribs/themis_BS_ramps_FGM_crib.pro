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

;;  Coordinate strings
coord_gse      = 'gse'

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

t_ramp0        = d                         ;;  [1st Shock]  Unix time at center of ramp
t_ramp1        = d                         ;;  [2nd Shock]  Unix time at center of ramp
t_ramp2        = d                         ;;  [3rd Shock]  Unix time at center of ramp

;;  Dummy Y-Ranges for |Bo|
yra_bmag_0     = REPLICATE(d,2L)
yra_bmag_1     = REPLICATE(d,2L)
yra_bmag_2     = REPLICATE(d,2L)

;;  Dummy upstream averages for Bo per GSE component
xyz_bavg_0     = REPLICATE(d,3L)
xyz_bavg_1     = REPLICATE(d,3L)
xyz_bavg_2     = REPLICATE(d,3L)

;;  Dummy Y-Ranges for |Bo|/<|Bo|>_up
yr_bmag_bup_0  = REPLICATE(d,2L)
yr_bmag_bup_1  = REPLICATE(d,2L)
yr_bmag_bup_2  = REPLICATE(d,2L)

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
t_ramp0        = MEAN(tr_ra_0,/NAN)
t_ramp1        = d
t_ramp2        = d
yra_bmag_0     = [0d0,35d0]

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
t_ramp0        = MEAN(tr_ra_0,/NAN)
t_ramp1        = d
t_ramp2        = d
yra_bmag_0     = [0d0,35d0]

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
t_ramp0        = MEAN(tr_ra_0,/NAN)
t_ramp1        = MEAN(tr_ra_1,/NAN)
t_ramp2        = MEAN(tr_ra_2,/NAN)
yra_bmag_0     = [0d0,50d0]
yra_bmag_1     = [0d0,45d0]
yra_bmag_2     = [0d0,45d0]

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
t_ramp0        = MEAN(tr_ra_0,/NAN)
t_ramp1        = MEAN(tr_ra_1,/NAN)
t_ramp2        = MEAN(tr_ra_2,/NAN)
yra_bmag_0     = [0d0,25d0]
yra_bmag_1     = [0d0,20d0]
yra_bmag_2     = [0d0,25d0]
;;  Define upstream Avgs for Bo per GSE component
xyz_bavg_0     = ABS([ 50d-2,-50d-2,-25d-2])
xyz_bavg_1     = ABS([-80d-2,-80d-2,-20d-2])
xyz_bavg_2     = ABS([-25d-2,-10d-1,-25d-2])
yr_bmag_bup_0  = [0d0,20d0]
yr_bmag_bup_1  = [0d0,15d0]
yr_bmag_bup_2  = [0d0,20d0]

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
t_ramp0        = MEAN(tr_ra_0,/NAN)
yra_bmag_0     = [0d0,50d0]

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
t_ramp0        = MEAN(tr_ra_0,/NAN)
t_ramp1        = MEAN(tr_ra_1,/NAN)
yra_bmag_0     = [0d0,70d0]
yra_bmag_1     = [0d0,11d1]

;;----------------------------------------------------------------------------------------
;;  Clean up
;;----------------------------------------------------------------------------------------
store_data,DELETE=tnames(pref[0]+'efw*')
store_data,DELETE=tnames(pref[0]+'efp*')
store_data,DELETE=tnames(pref[0]+'scw*')
store_data,DELETE=tnames(pref[0]+'scp*')

DELVAR,dat_igse,dat_egse
;;----------------------------------------------------------------------------------------
;;  Define time zooms around ramp
;;----------------------------------------------------------------------------------------
tz_facs        = [2.5d0,5d0,7.5d0,1d1,15d0,22.5d0,3d1,45d0,6d1,75d0,1d2]
ntz            = N_ELEMENTS(tz_facs)
tz_strs        = '_'+STRTRIM(STRING(2d0*tz_facs,FORMAT='(I3.3)'),2)+'-sec-window'
tzoom0         = DBLARR(ntz,2L)
tzoom1         = DBLARR(ntz,2L)
tzoom2         = DBLARR(ntz,2L)

tzoom0[*,0]    = t_ramp0[0] - tz_facs
tzoom0[*,1]    = t_ramp0[0] + tz_facs
tzoom1[*,0]    = t_ramp1[0] - tz_facs
tzoom1[*,1]    = t_ramp1[0] + tz_facs
tzoom2[*,0]    = t_ramp2[0] - tz_facs
tzoom2[*,1]    = t_ramp2[0] + tz_facs
fnm_s0         = file_name_times(tzoom0[*,0],PREC=4)
fnm_e0         = file_name_times(tzoom0[*,1],PREC=4)
fnm_s1         = file_name_times(tzoom1[*,0],PREC=4)
fnm_e1         = file_name_times(tzoom1[*,1],PREC=4)
fnm_s2         = file_name_times(tzoom2[*,0],PREC=4)
fnm_e2         = file_name_times(tzoom2[*,1],PREC=4)

ftimes0        = fnm_s0.F_TIME+'-'+STRMID(fnm_e0.F_TIME,11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
ftimes1        = fnm_s1.F_TIME+'-'+STRMID(fnm_e1.F_TIME,11L)
ftimes2        = fnm_s2.F_TIME+'-'+STRMID(fnm_e2.F_TIME,11L)
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
f_suffx0       = '_1st-BS-Crossing'
f_suffx1       = '_2nd-BS-Crossing'
f_suffx2       = '_3rd-BS-Crossing'
f_suffxs       = [f_suffx0[0],f_suffx1[0],f_suffx2[0]]
tr_ra_s        = [[tr_ra_0],[tr_ra_1],[tr_ra_2]]
tr_ra_c        = [t_ramp0[0],t_ramp1[0],t_ramp2[0]]
fnm_times      = [[ftimes0],[ftimes1],[ftimes2]]
yra_bmags      = [[yra_bmag_0],[yra_bmag_1],[yra_bmag_2]]
yr_bmag_up     = [[yr_bmag_bup_0],[yr_bmag_bup_1],[yr_bmag_bup_0]]
xyz_bavg_up    = [[xyz_bavg_0],[xyz_bavg_1],[xyz_bavg_2]]

tzooms         = [[[tzoom0]],[[tzoom1]],[[tzoom2]]]
;;----------------------------------------------------------------------------------------
;;  Define FGM TPLOT handles and setup plot names
;;----------------------------------------------------------------------------------------
scpref         = pref[0]
mode_fgm       = ['fgs','fgl','fgh']
tpnm_fgm_bmag  = tnames(scpref[0]+mode_fgm+'_mag')
options,tpnm_fgm_bmag,'YRANGE'
options,tpnm_fgm_bmag,'YRANGE',/DEF

prefu          = STRUPCASE(pref[0])
f_pref         = prefu[0]+'fgs-fgl-fgh_mag_compare_'
filenames      = REPLICATE('',ntz[0],3L)
FOR k=0L, 2L DO filenames[*,k] = f_pref[0]+fnm_times[*,k]+tz_strs+f_suffxs[k]

FOR k=0L, 2L DO BEGIN                                           $
  options,tpnm_fgm_bmag,'YRANGE',REFORM(yra_bmags[*,k]),/DEF  & $
  tzs = REFORM(tzooms[*,*,k])                                 & $
  trc = tr_ra_c[k]                                            & $
  tra = REFORM(tr_ra_s[*,k])                                  & $
  FOR i=0L, ntz[0] - 1L DO BEGIN                                $
    fname = filenames[i,k]                                    & $
      tplot,tpnm_fgm_bmag,TRANGE=REFORM(tzs[i,*]),/NOM        & $
      time_bar,trc[0],VARNAME=tpnm_fgm_bmag,COLOR=150         & $
      time_bar,tra[0],VARNAME=tpnm_fgm_bmag,COLOR=250         & $
      time_bar,tra[1],VARNAME=tpnm_fgm_bmag,COLOR= 50         & $
    popen,fname[0],/LAND                                      & $
      tplot,tpnm_fgm_bmag,TRANGE=REFORM(tzs[i,*]),/NOM        & $
      time_bar,trc[0],VARNAME=tpnm_fgm_bmag,COLOR=150         & $
      time_bar,tra[0],VARNAME=tpnm_fgm_bmag,COLOR=250         & $
      time_bar,tra[1],VARNAME=tpnm_fgm_bmag,COLOR= 50         & $
    pclose

;;----------------------------------------------------------------------------------------
;;  Define normalized FGM TPLOT handles
;;----------------------------------------------------------------------------------------
tpn_fgh_bgse   = tnames(scpref[0]+mode_fgm[2]+'_'+coord_gse[0])
tpn_fgh_bmagup = tnames(scpref[0]+mode_fgm[2]+'_dBmag_Bo_up')
tpn_fgh_bvecup = tnames(scpref[0]+mode_fgm[2]+'_dBvec_B__up')

options,[tpn_fgh_bmagup,tpn_fgh_bvecup],'YRANGE'
options,[tpn_fgh_bmagup,tpn_fgh_bvecup],'YRANGE',/DEF
;;  Define new YSUBTITLEs for vectors
get_data,  tpn_fgh_bgse[0],    DATA=t_Bgse, DLIM=dlim_B,LIM=lim_B
bgse_t         = t_Bgse.X
bgse_v         = t_Bgse.Y
ones           = REPLICATE(1d0,N_ELEMENTS(bgse_t))

get_data,tpn_fgh_bvecup[0],DATA=t_Bgse_nor,DLIM=dlim_Bn,LIM=lim_Bn
ysubt          = '['+'th'+sc[0]+' 128 sps, L2]'
str_element,dlim_Bn,'YSUBTITLE',ysubt[0],/ADD_REPLACE
newname        = tpn_fgh_bvecup[0]+'_2'
store_data,newname[0],DATA=t_Bgse_nor,DLIM=dlim_Bn,LIM=lim_Bn

nna            = [tpn_fgh_bmagup[0],newname[0]]
f_pref         = prefu[0]+'fgh_Bmag-Bgse_Normalized_to_AvgUp_'
filenames      = REPLICATE('',ntz[0],3L)
FOR k=0L, 2L DO filenames[*,k] = f_pref[0]+fnm_times[*,k]+tz_strs+f_suffxs[k]

FOR k=0L, 2L DO BEGIN                                             $
  options,tpn_fgh_bmagup,'YRANGE',REFORM(yr_bmag_up[*,k]),/DEF  & $
  nbgsev = bgse_v/(ones # REFORM(xyz_bavg_up[*,k]))             & $
  nstruc = {X:bgse_t,Y:nbgsev}                                  & $
  store_data,newname[0],DATA=nstruc,DLIM=dlim_Bn,LIM=lim_Bn     & $
  tzs = REFORM(tzooms[*,*,k])                                   & $
  trc = tr_ra_c[k]                                              & $
  tra = REFORM(tr_ra_s[*,k])                                    & $
  FOR i=0L, ntz[0] - 1L DO BEGIN                                  $
    fname = filenames[i,k]                                      & $
      tplot,nna,TRANGE=REFORM(tzs[i,*]),/NOM                    & $
      time_bar,trc[0],VARNAME=nna,COLOR=150                     & $
      time_bar,tra[0],VARNAME=nna,COLOR=250                     & $
      time_bar,tra[1],VARNAME=nna,COLOR= 50                     & $
    popen,fname[0],/LAND                                        & $
      tplot,nna,TRANGE=REFORM(tzs[i,*]),/NOM                    & $
      time_bar,trc[0],VARNAME=nna,COLOR=150                     & $
      time_bar,tra[0],VARNAME=nna,COLOR=250                     & $
      time_bar,tra[1],VARNAME=nna,COLOR= 50                     & $
    pclose





































