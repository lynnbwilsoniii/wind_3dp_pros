;;  @/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/plot_ip_shocks_whistler_vs_beta_batch.pro

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
ckm            = c[0]*1d-3                ;;  m --> km
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
GG             = 6.6740800000d-11         ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1), 2014 CODATA/NIST]

f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
J_1eV          = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
;;  Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km
slash          = get_os_slash()           ;;  '/' for Unix, '\' for Windows

;;  Cs^2  = [kB ( Zi ¥e Te + ¥i Ti )/Mi]
;;        = (5/3)*Wi^2 [for CfA database results]
;;  We^2  = kB Te/me = (Mi/me)
;;  Wi^2  = kB Ti/Mi
;;  ß     = (3/5)*Cs^2/V_A^2
;;----------------------------------------------------------------------------------------
;;  Get Rankine-Hugoniot results, if available
;;----------------------------------------------------------------------------------------
;test_bst       = read_shocks_jck_database_new(/FINDBEST_METH,GIND_3D=gind_3d_bst)
test_bst       = read_shocks_jck_database_new(/CFA_METH_ONLY,GIND_3D=gind_3d_bst)

;;  Define internal structures
gen_info_str   = test_bst.GEN_INFO
asy_info_str   = test_bst.ASY_INFO
bvn_info_str   = test_bst.BVN_INFO
key_info_str   = test_bst.KEY_INFO
ups_info_str   = test_bst.UPS_INFO
dns_info_str   = test_bst.DNS_INFO

;;  Define general info
tdates_bst     = gen_info_str.TDATES
rhmeth_bst     = gen_info_str.RH_METHOD
tura_all       = gen_info_str.ARRT_UNIX.Y
ymdb_all       = time_string(tura_all,PREC=3)
n_all_cfa      = N_ELEMENTS(tura_all)

updn_tura      = tura_all # REPLICATE(1d0,2L)
updn_tura[*,0] -= 4d0
updn_tura[*,1] += 4d0
updn_ymdb      = time_string(updn_tura,PREC=3)

PRINT,';;  ',time_string(minmax(tura_all),PREC=3)
;;   1995-01-01/19:36:01.500 2016-03-14/16:16:31.500

;;  Define upstream/downstream plasma parameters
vi_gse_up      = asy_info_str.VBULK_GSE.Y[*,*,0]
bo_gse_up      = asy_info_str.MAGF_GSE.Y[*,*,0]
wi_rms_up      = asy_info_str.VTH_ION.Y[*,0]
ni_avg_up      = asy_info_str.DENS_ION.Y[*,0]
beta_t_up      = asy_info_str.PLASMA_BETA.Y[*,0]      ;;  Total plasma beta
Cs_avg_up      = asy_info_str.SOUND_SPEED.Y[*,0]      ;;  ion-acoustic sound speed
VA_avg_up      = asy_info_str.ALFVEN_SPEED.Y[*,0]     ;;  Alfvén speed
vi_gse_dn      = asy_info_str.VBULK_GSE.Y[*,*,1]
bo_gse_dn      = asy_info_str.MAGF_GSE.Y[*,*,1]
wi_rms_dn      = asy_info_str.VTH_ION.Y[*,1]
ni_avg_dn      = asy_info_str.DENS_ION.Y[*,1]
beta_t_dn      = asy_info_str.PLASMA_BETA.Y[*,1]      ;;  Total plasma beta
Cs_avg_dn      = asy_info_str.SOUND_SPEED.Y[*,1]      ;;  ion-acoustic sound speed
VA_avg_dn      = asy_info_str.ALFVEN_SPEED.Y[*,1]     ;;  Alfvén speed

;;  Define magnitudes for vectors
vi_mag_up      = mag__vec(vi_gse_up)
bo_mag_up      = mag__vec(bo_gse_up)
vi_mag_dn      = mag__vec(vi_gse_dn)
bo_mag_dn      = mag__vec(bo_gse_dn)

;;  Define unit vectors and angle between upstream/downstream Avg.s
vi_uvc_up      = unit_vec(vi_gse_up)
bo_uvc_up      = unit_vec(bo_gse_up)
vi_uvc_dn      = unit_vec(vi_gse_dn)
bo_uvc_dn      = unit_vec(bo_gse_dn)
vi_ang_ud      = dot_prod_angle(vi_uvc_up,vi_uvc_dn,/NAN)
bo_ang_ud      = dot_prod_angle(bo_uvc_up,bo_uvc_dn,/NAN)

;;  Define Key Shock Analysis parameters
thetbn_up      = key_info_str.THETA_BN.Y
vshn___up      = ABS(key_info_str.VSHN_UP.Y)
N2_N1__up      = ABS(key_info_str.NIDN_NIUP.Y)
n_gse__up      = bvn_info_str.SH_N_GSE.Y
;;  Define angle between shock normal and upstream bulk flow velocity [deg]
n_ugse_up      = unit_vec(n_gse__up)
vinup_ang      = dot_prod_angle(vi_uvc_up,n_ugse_up,/NAN)

;;  Define Upstream Shock Analysis results
ushn___up      = ABS(ups_info_str.USHN.Y)
Vslow__up      = ABS(ups_info_str.V_SLOW.Y)
Vint___up      = ABS(ups_info_str.V_INTM.Y)
Vfast__up      = ABS(ups_info_str.V_FAST.Y)
Mslow__up      = ABS(ups_info_str.M_SLOW.Y)
Mfast__up      = ABS(ups_info_str.M_FAST.Y)
M_Cs___up      = ABS(ups_info_str.M_CS.Y)
M_VA___up      = ABS(ups_info_str.M_VA.Y)

;;  Define Downstream Shock Analysis results
ushn___dn      = ABS(dns_info_str.USHN.Y)
Vslow__dn      = ABS(dns_info_str.V_SLOW.Y)
Vint___dn      = ABS(dns_info_str.V_INTM.Y)
Vfast__dn      = ABS(dns_info_str.V_FAST.Y)
Mslow__dn      = ABS(dns_info_str.M_SLOW.Y)
Mfast__dn      = ABS(dns_info_str.M_FAST.Y)
M_Cs___dn      = ABS(dns_info_str.M_CS.Y)
M_VA___dn      = ABS(dns_info_str.M_VA.Y)

;;----------------------------------------------------------------------------------------
;;  Define requirements/tests for low-Mach number and beta quasi-perp. shocks
;;----------------------------------------------------------------------------------------
test_0         = (ABS(Mfast__up) GE 1e0) AND (ABS(M_VA___up) GE 1e0) AND (ABS(N2_N1__up) GE 1e0)
test_1         = (ABS(N2_N1__up) LE 3e0) AND (ABS(thetbn_up) GE 45e0)
test_f         = (ABS(beta_t_up) LE 1e0) AND (ABS(Mfast__up) LE 3e0) AND test_1
test_A         = (ABS(beta_t_up) LE 1e0) AND (ABS(M_VA___up) LE 3e0) AND test_1
good_f         = WHERE(test_f AND test_0,gd_f)
good_A         = WHERE(test_A AND test_0,gd_A)
PRINT,';;  ',gd_f,gd_A
;;           176         145

;;----------------------------------------------------------------------------------------
;;  Define start/end times for plot ranges
;;----------------------------------------------------------------------------------------
start_times    = ['1995-03-04/00:36:54.500','1995-04-17/23:33:00.500','1995-07-22/05:35:39.500','1995-08-22/12:56:42.500','1995-08-24/22:11:00.500','1995-09-14/21:23:50.200','1995-10-22/21:20:12.500','1995-12-24/05:57:30.500','1996-02-06/19:14:18.500','1996-04-03/09:47:12.500','1996-04-08/02:41:06.500','1996-06-18/22:35:51.500','1997-01-05/03:20:42.500','1997-03-15/22:30:27.500','1997-04-10/12:58:30.500','1997-04-16/12:21:21.500','1997-05-20/05:10:43.500','1997-05-25/13:49:51.500','1997-05-26/09:09:03.500','1997-08-05/04:59:00.500','1997-09-03/08:38:36.500','1997-10-10/15:57:03.500','1997-10-24/11:18:03.500','1997-11-01/06:14:39.500','1997-12-10/04:33:09.500','1997-12-30/01:13:39.500','1998-01-06/13:28:57.500','1998-02-18/07:48:35.500','1998-05-29/15:12:00.500','1998-08-06/07:16:03.500','1998-08-19/18:40:36.500','1998-11-08/04:41:12.500','1998-12-26/09:54:13.600','1998-12-28/18:20:12.500','1999-01-13/10:47:30.500','1999-02-17/07:12:09.500','1999-03-10/01:32:57.500','1999-04-16/11:12:30.399','1999-06-26/19:30:54.500','1999-08-04/01:44:25.500','1999-08-23/12:11:09.500','1999-09-15/07:43:35.500','1999-09-22/12:09:21.500','1999-10-21/02:20:48.500','1999-11-05/20:01:45.399','1999-11-13/12:48:54.500','2000-02-05/15:26:24.500','2000-02-14/07:12:50.500','2000-06-23/12:57:24.100','2000-07-13/09:43:30.500','2000-07-26/19:00:09.500','2000-07-28/06:38:42.500','2000-08-10/05:13:10.500','2000-08-11/18:49:30.500','2000-10-03/01:02:10.500','2000-10-28/06:35:58.500','2000-10-28/09:30:20.500','2000-10-31/17:09:54.500','2000-11-04/02:25:42.500','2000-11-06/09:29:40.500','2000-11-11/04:06:26.000','2000-11-26/11:43:24.500','2000-11-28/05:25:40.000','2001-01-17/04:07:48.500','2001-03-03/11:29:05.500','2001-03-22/13:59:03.500','2001-03-27/18:07:45.500','2001-04-21/15:29:09.500','2001-05-06/09:06:03.500','2001-05-12/10:03:09.500','2001-08-12/16:12:42.500','2001-08-31/01:25:00.500','2001-09-13/02:31:20.500','2001-10-28/03:13:42.500','2001-11-30/18:15:35.500','2001-12-21/14:10:05.500','2001-12-30/20:05:00.500','2002-01-17/05:26:51.500','2002-01-31/21:38:06.500','2002-03-23/11:24:03.500','2002-03-29/22:15:09.500','2002-05-21/21:14:10.500','2002-06-29/21:10:15.500','2002-08-01/23:09:03.500','2002-09-30/07:54:21.500','2002-10-02/22:41:00.500','2002-11-09/18:27:45.500','2003-05-29/18:31:03.500','2003-06-18/04:42:00.500','2004-04-12/18:29:32.099','2005-05-06/12:08:30.500','2005-05-07/18:26:12.500','2005-06-16/08:09:06.500','2005-07-10/02:42:27.500','2005-07-16/01:40:54.500','2005-08-01/06:00:48.500','2005-08-24/05:35:18.500','2005-09-02/13:50:09.500','2005-09-15/08:36:15.500','2005-12-30/23:45:15.500','2006-08-19/09:38:40.500','2006-11-03/09:37:12.500','2007-07-20/03:27:10.500','2007-08-22/04:33:55.500','2007-12-17/01:53:12.500','2008-05-28/01:17:33.500','2008-06-24/19:10:36.500','2009-02-03/19:20:57.500','2009-06-24/09:52:15.500','2009-06-27/11:04:12.500','2009-10-21/23:15:06.500','2010-04-11/12:20:51.500','2011-02-04/01:50:45.500','2011-07-11/08:27:21.500','2011-09-16/18:54:26.099','2011-09-25/10:46:27.500','2012-01-21/04:01:57.500','2012-01-30/15:43:09.500','2012-03-07/03:28:33.500','2012-04-19/17:13:27.500','2012-06-16/19:34:33.500','2012-10-08/04:12:09.500','2012-11-12/22:12:36.500','2012-11-26/04:32:45.500','2012-12-14/19:06:09.500','2013-01-17/00:23:39.500','2013-02-13/00:47:40.500','2013-04-30/08:52:42.500','2013-06-10/02:51:57.500','2013-07-12/16:43:21.500','2013-09-02/01:56:40.500','2013-10-26/21:25:57.500','2014-02-13/08:55:24.500','2014-02-15/12:46:30.500','2014-02-19/03:09:33.500','2014-04-19/17:48:15.500','2014-05-07/21:19:30.500','2014-05-29/08:26:34.500','2014-07-14/13:38:06.500','2015-05-06/00:55:45.500','2015-06-05/08:29:38.900','2015-06-24/13:07:05.500','2015-08-15/07:43:36.500','2016-03-11/04:26:46.700','2016-03-14/16:16:27.500']
end___times    = ['1995-03-04/00:37:02.500','1995-04-17/23:33:10.500','1995-07-22/05:35:47.500','1995-08-22/12:56:55.500','1995-08-24/22:11:08.500','1995-09-14/21:26:00.899','1995-10-22/21:20:20.500','1995-12-24/05:57:38.500','1996-02-06/19:14:30.500','1996-04-03/09:47:20.500','1996-04-08/02:41:14.500','1996-06-18/22:35:59.500','1997-01-05/03:20:50.500','1997-03-15/22:30:35.500','1997-04-10/12:58:38.500','1997-04-16/12:21:29.500','1997-05-20/05:10:53.500','1997-05-25/13:49:59.500','1997-05-26/09:09:11.500','1997-08-05/04:59:08.500','1997-09-03/08:38:44.500','1997-10-10/15:57:11.500','1997-10-24/11:18:11.500','1997-11-01/06:14:47.500','1997-12-10/04:33:17.500','1997-12-30/01:13:47.500','1998-01-06/13:29:05.500','1998-02-18/07:48:50.500','1998-05-29/15:12:08.500','1998-08-06/07:16:11.500','1998-08-19/18:40:44.500','1998-11-08/04:41:20.500','1998-12-26/09:57:59.299','1998-12-28/18:20:20.500','1999-01-13/10:48:00.500','1999-02-17/07:12:17.500','1999-03-10/01:33:05.500','1999-04-16/11:14:42.100','1999-06-26/19:31:02.500','1999-08-04/01:44:41.500','1999-08-23/12:11:17.500','1999-09-15/07:44:00.500','1999-09-22/12:09:29.500','1999-10-21/02:20:56.500','1999-11-05/20:03:37.700','1999-11-13/12:49:02.500','2000-02-05/15:26:32.500','2000-02-14/07:13:10.500','2000-06-23/12:58:24.500','2000-07-13/09:43:55.500','2000-07-26/19:00:17.500','2000-07-28/06:38:50.500','2000-08-10/05:13:30.500','2000-08-11/18:49:38.500','2000-10-03/01:02:30.500','2000-10-28/06:41:05.299','2000-10-28/09:30:55.500','2000-10-31/17:10:02.500','2000-11-04/02:25:50.500','2000-11-06/09:30:15.500','2000-11-11/04:15:13.000','2000-11-26/11:43:32.500','2000-11-28/05:27:51.899','2001-01-17/04:07:56.500','2001-03-03/11:29:20.500','2001-03-22/13:59:11.500','2001-03-27/18:07:53.500','2001-04-21/15:29:17.500','2001-05-06/09:06:11.500','2001-05-12/10:03:17.500','2001-08-12/16:12:50.500','2001-08-31/01:25:08.500','2001-09-13/02:31:35.500','2001-10-28/03:13:50.500','2001-11-30/18:15:55.500','2001-12-21/14:10:25.500','2001-12-30/20:05:15.500','2002-01-17/05:26:59.500','2002-01-31/21:38:14.500','2002-03-23/11:24:11.500','2002-03-29/22:15:17.500','2002-05-21/21:14:20.500','2002-06-29/21:10:29.500','2002-08-01/23:09:11.500','2002-09-30/07:54:29.500','2002-10-02/22:41:08.500','2002-11-09/18:27:53.500','2003-05-29/18:31:11.500','2003-06-18/04:42:08.500','2004-04-12/18:29:56.700','2005-05-06/12:08:45.500','2005-05-07/18:26:20.500','2005-06-16/08:09:14.500','2005-07-10/02:42:35.500','2005-07-16/01:41:02.500','2005-08-01/06:00:56.500','2005-08-24/05:35:26.500','2005-09-02/13:50:20.500','2005-09-15/08:36:45.500','2005-12-30/23:45:30.500','2006-08-19/09:38:55.500','2006-11-03/09:37:20.500','2007-07-20/03:27:23.500','2007-08-22/04:34:10.500','2007-12-17/01:53:23.500','2008-05-28/01:17:41.500','2008-06-24/19:10:44.500','2009-02-03/19:21:05.500','2009-06-24/09:52:23.500','2009-06-27/11:04:20.500','2009-10-21/23:15:14.500','2010-04-11/12:20:59.500','2011-02-04/01:50:59.500','2011-07-11/08:27:29.500','2011-09-16/18:58:49.200','2011-09-25/10:46:35.500','2012-01-21/04:02:05.500','2012-01-30/15:43:17.500','2012-03-07/03:28:45.500','2012-04-19/17:13:35.500','2012-06-16/19:34:41.500','2012-10-08/04:12:17.500','2012-11-12/22:12:44.500','2012-11-26/04:32:53.500','2012-12-14/19:06:17.500','2013-01-17/00:23:47.500','2013-02-13/00:47:50.500','2013-04-30/08:52:50.500','2013-06-10/02:52:05.500','2013-07-12/16:43:29.500','2013-09-02/01:56:56.500','2013-10-26/21:26:05.500','2014-02-13/08:55:32.500','2014-02-15/12:46:40.500','2014-02-19/03:09:41.500','2014-04-19/17:48:30.500','2014-05-07/21:19:45.500','2014-05-29/08:26:46.500','2014-07-14/13:38:14.500','2015-05-06/00:55:53.500','2015-06-05/08:32:15.900','2015-06-24/13:07:20.500','2015-08-15/07:43:44.500','2016-03-11/04:31:27.700','2016-03-14/16:16:35.500']
;;  Convert to Unix
start_unix     = time_double(start_times)
end___unix     = time_double(end___times)
midt__unix     = (start_unix + end___unix)/2d0
;;  Define a zoom-out range
n_gdA          = N_ELEMENTS(midt__unix)
delt           = [0d0,5d-1,1d0,2d0,5d0,1d1,2d1]
nzoom          = N_ELEMENTS(delt)
zoom_st        = REPLICATE(d,n_gdA[0],nzoom[0])
zoom_en        = REPLICATE(d,n_gdA[0],nzoom[0])
FOR k=0L, nzoom[0] - 1L DO BEGIN                                                 $
  zoom_st[*,k] = start_unix - delt[k]                                          & $
  zoom_en[*,k] = end___unix + delt[k]

IF KEYWORD_SET(no_plot) THEN STOP
;;----------------------------------------------------------------------------------------
;;  Define time ranges to load into TPLOT
;;----------------------------------------------------------------------------------------
delt           = [-1,1]*1d0*36d2        ;;  load ±1 hour about ramp
all_stunix     = midt__unix + delt[0]
all_enunix     = midt__unix + delt[1]
all__trans     = [[all_stunix],[all_enunix]]
;;----------------------------------------------------------------------------------------
;;  Define save/setup stuff for TPLOT
;;----------------------------------------------------------------------------------------
popen_str      = {PORT:1,LANDSCAPE:0,UNITS:'inches',YSIZE:11,XSIZE:8.5}
;;  Define save directory
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'zoom_plots'+slash[0]
inst_pref      = 'mfi_'
zsuff          = 'zoom_'+num2int_str(LINDGEN(nzoom[0]))
FILE_MKDIR,sav_dir[0]
FOR k=0L, nzoom[0] - 1L DO FILE_MKDIR,sav_dir[0]+zsuff[k]
fpref          = sav_dir[0]+zsuff+slash[0]+'Wind_'+inst_pref[0]+'_'
fsuff          = '_Bo_dBdt_d2Bdt2'
;;  Define file name times
ftimes         = STRARR(n_gdA[0],nzoom[0])    ;; e.g., '2000-06-08_0705x58.886-0706x01.992'
FOR k=0L, nzoom[0] - 1L DO BEGIN                                                      $
  fnm_st         = file_name_times(zoom_st[*,k],PREC=3)                             & $
  fnm_en         = file_name_times(zoom_en[*,k],PREC=3)                             & $
  ftimes[*,k]    = fnm_st.F_TIME+'-'+STRMID(fnm_en.F_TIME,11L)    ;; e.g., '2000-06-08_0705x58.886-0706x01.992'

;fnm_st         = file_name_times(zoom_st,PREC=3)
;fnm_en         = file_name_times(zoom_en,PREC=3)
;ftimes         = fnm_st.F_TIME+'-'+STRMID(fnm_en.F_TIME,11L)    ;; e.g., '2000-06-08_0705x58.886-0706x01.992'
yttl_dbdt      = '( dBo/dt )/Bo [nT/s, GSE]'
yttl_d2bdt2    = 'd/dt(( dBo/dt )/Bo) [nT/s, GSE]'
wdth           = 512L
thck           = 2e0
;chsz           = 2
chsz           = 1.25
;;----------------------------------------------------------------------------------------
;;  Plot and save
;;----------------------------------------------------------------------------------------
;bind           = [5L, 32L, 37L, 44L, 48L, 55L, 60L, 62L, 89L, 114L, 140L, 143L]
;bind           = [53L, 137L]
;n_gdA          = N_ELEMENTS(bind)
;FOR i=0L, n_gdA[0] - 1L DO BEGIN                                                          $
;  j              = bind[i]                                                              & $
tshft_on       = 0b
unix           = 0d0
vecs           = 0d0
FOR j=0L, n_gdA[0] - 1L DO BEGIN                                                          $
  dumb           = TEMPORARY(tshft_on)                                                  & $
  dumb           = TEMPORARY(unix)                                                      & $
  dumb           = TEMPORARY(vecs)                                                      & $
  tran           = REFORM(all__trans[j[0],*])                                           & $
  nna            = tnames()                                                             & $
  IF (nna[0] NE '') THEN store_data,DELETE=nna                                          & $
  f_times        = REFORM(ftimes[j,*])                                                  & $
  f_names        = fpref+f_times+fsuff[0]+'_'+zsuff                                     & $
  wind_h2_mfi_2_tplot,/LOAD_GSE,TRANGE=tran                                             & $
  get_data,1,DATA=temp,DLIM=dlim,LIM=lim                                                & $
  IF (SIZE(temp,/TYPE) NE 8) THEN CONTINUE                                              & $
  unix           = t_get_struc_unix(temp,TSHFT_ON=tshft_on)                             & $
  vecs           = temp.Y                                                               & $
  srate          = sample_rate(unix,/AVERAGE)                                           & $
  gapthsh        = 2d0/srate[0]                                                         & $
  IF KEYWORD_SET(tshft_on) THEN tshft = temp.TSHIFT[0] ELSE tshft = 0d0                 & $
  nulls          = REPLICATE(d,N_ELEMENTS(unix),4L)                                     & $
  dydx           = nulls                                                                & $
  d2ydx2         = nulls                                                                & $
  smbx           = SMOOTH(vecs[*,0],wdth[0],/NAN,/EDGE_TRUNCATE)                        & $
  smby           = SMOOTH(vecs[*,1],wdth[0],/NAN,/EDGE_TRUNCATE)                        & $
  smbz           = SMOOTH(vecs[*,2],wdth[0],/NAN,/EDGE_TRUNCATE)                        & $
  smbm           = SMOOTH(vecs[*,3],wdth[0],/NAN,/EDGE_TRUNCATE)                        & $
  smbf           = [[smbx],[smby],[smbz],[smbm]]                                        & $
  FOR k=0L, 3L DO dydx[*,k]   = DERIV(unix,vecs[*,k])/smbf[*,3]                         & $
  FOR k=0L, 3L DO d2ydx2[*,k] = DERIV(unix,dydx[*,k])                                   & $
  struc_db1      = {X:unix,Y:dydx,TSHIFT:tshft[0]}                                      & $
  struc_db2      = {X:unix,Y:d2ydx2,TSHIFT:tshft[0]}                                    & $
  outer_tran     = [MIN(zoom_st[j,*],/NAN),MAX(zoom_en[j,*],/NAN)]                      & $
  clip__bo       = trange_clip_data(temp,TRANGE=outer_tran,PREC=3)                      & $
  clip_db1       = trange_clip_data(struc_db1,TRANGE=outer_tran,PREC=3)                 & $
  clip_db2       = trange_clip_data(struc_db2,TRANGE=outer_tran,PREC=3)                 & $
  yran_bo        = 1.1*MAX(ABS(clip__bo.Y),/NAN)*[-1,1]                                 & $
  yran_db1       = 1.1*MAX(ABS(clip_db1.Y),/NAN)*[-1,1]                                 & $
  yran_db2       = 1.1*MAX(ABS(clip_db2.Y),/NAN)*[-1,1]                                 & $
  store_data,'dBdt',  DATA=struc_db1,DLIM=dlim,LIM=lim                                  & $
  store_data,'d2Bdt2',DATA=struc_db2,DLIM=dlim,LIM=lim                                  & $
  options,1,YRANGE=yran_bo,/DEF                                                         & $
  options,['dBdt','d2Bdt2'],'YTITLE'                                                    & $
  options,'dBdt',YTITLE=yttl_dbdt[0],YRANGE=yran_db1,/DEF                               & $
  options,'d2Bdt2',YTITLE=yttl_d2bdt2[0],YRANGE=yran_db2,/DEF                           & $
  options,tnames(),'THICK'                                                              & $
  options,tnames(),'CHARSIZE'                                                           & $
  options,tnames(),THICK=thck[0],CHARSIZE=chsz[0],/DEF                                  & $
  t_insert_nan_at_interval_se,tnames(),GAP_THRESH=gapthsh[0]                            & $
  FOR k=0L, nzoom[0] - 1L DO BEGIN                                                        $
    fname        = f_names[k]                                                           & $
    tzoom        = [zoom_st[j,k],zoom_en[j,k]]                                          & $
      tplot,[1,2,3],TRANGE=tzoom                                                        & $
    popen,fname[0],_EXTRA=popen_str                                                     & $
      tplot,[1,2,3],TRANGE=tzoom                                                        & $
    pclose                                                                              & $
  ENDFOR                                                                                & $
  struc_db1      = 0                                                                    & $
  struc_db2      = 0                                                                    & $
  clip__bo       = 0                                                                    & $
  clip_db1       = 0                                                                    & $
  clip_db2       = 0                                                                    & $
  dlim           = 0                                                                    & $
  lim            = 0                                                                    & $
  temp           = 0






