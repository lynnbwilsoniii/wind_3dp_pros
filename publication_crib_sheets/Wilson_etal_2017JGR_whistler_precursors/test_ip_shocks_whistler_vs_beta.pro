;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;;  Electron mass [kg]
mp             = 1.6726217770d-27     ;;  Proton mass [kg]
ma             = 6.6446567500d-27     ;;  Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;;  Speed of light in vacuum [m/s]
ckm            = c[0]*1d-3            ;;  m --> km
epo            = 8.8541878170d-12     ;;  Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;;  Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;;  Fundamental charge [C]
kB             = 1.3806488000d-23     ;;  Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;;  Planck Constant [J s]
GG             = 6.6738400000d-11     ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [J]
;;  Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K/eV
R_E            = 6.37814d3            ;;  Earth's Equitorial Radius [km]
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows

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
;;           175         145

;;----------------------------------------------------------------------------------------
;;  Define array specifying whether whistlers were observed
;;----------------------------------------------------------------------------------------
;;  1st Letter
;;  Y   =  Yes
;;  N   =  No
;;  M   =  Maybe or Unclear
;;
;;  2nd Letter
;;  S   =  resolved or sampled well enough
;;  U   =  fluctuation present but undersampled (e.g., looks like triangle wave)
;;  G   =  data gap or missing data (but still well resolved)
;;  M   =  data gap or missing data (and undersampled)
;;  N   =  nothing
whpre_yn       = ['MU','YU','YS','YG','YS','MU','YU','YU','YU','YS','YS','MU','NN','YS',$
                  'YU','NU','NN','MU','NU','NU','NU','MU','YS','YS','YU','YU','YU','YS',$
                  'YM','YU','YU','YU','YU','YU','YU','YU','NN','YS','YM','YS','YS','NN',$
                  'NU','YM','YS','YU','YS','YS','YS','YU','YU','YM','YU','YU','NU','NN',$
                  'NN','YM','NU','YS','NN','YM','NN','YU','YS','YM','YU','YU','YU','YU',$
                  'NM','NN','NU','YU','YS','YS','YM','YU','YU','YU','MU','YS','YS','YU',$
                  'YM','MU','MU','YU','YS','MS','YS','MU','YM','YS','NN','NM','YM','YU',$
                  'NS','NN','YS','NN','NU','NU','YS','YU','YU','YU','YU','YU','YU','YS',$
                  'YS','YU','NN','YU','YU','YU','NU','NU','YU','YU','YU','YS','NN','NU',$
                  'YU','MU','YU','YS','YS','YS','YU','YU','NU','YU','YS','YS','YU','YU',$
                  'NU','YS','YM','NN','NU']
whpre_1l       = STRMID(whpre_yn,0L,1L)
whpre_2l       = STRMID(whpre_yn,1L,1L)
n_all          = N_ELEMENTS(whpre_yn)
;;----------------------------------------------------------------------------------------
;;  Define requirements/tests to parse each of the letter combinations
;;----------------------------------------------------------------------------------------
test_y_all0    = (whpre_1l EQ 'Y')
test_n_all0    = (whpre_1l EQ 'N')
test_m_all0    = (whpre_1l EQ 'M')
test_2_aum0    = (whpre_2l EQ 'U') OR (whpre_2l EQ 'M')
test_2_asg0    = (whpre_2l EQ 'S') OR (whpre_2l EQ 'G')
test_y_aum0    = test_2_aum0 AND test_y_all0
test_y_asg0    = test_2_asg0 AND test_y_all0
test_n_aum0    = test_2_aum0 AND test_n_all0
test_n_asg0    = test_2_asg0 AND test_n_all0

good_y_all0    = WHERE(test_y_all0,gd_y_all)
good_n_all0    = WHERE(test_n_all0,gd_n_all)
good_m_all0    = WHERE(test_m_all0,gd_m_all)
good_2_aum0    = WHERE(test_2_aum0,gd_2_aum)
good_2_asg0    = WHERE(test_2_asg0,gd_2_asg)
good_y_aum0    = WHERE(test_y_aum0,gd_y_aum)
good_y_asg0    = WHERE(test_y_asg0,gd_y_asg)
good_n_aum0    = WHERE(test_n_aum0,gd_n_aum)
good_n_asg0    = WHERE(test_n_asg0,gd_n_asg)

PRINT,';;  ',n_all_cfa,n_all             & $
PRINT,';;  ',gd_y_all,gd_n_all,gd_m_all  & $
PRINT,';;  ',gd_2_aum,gd_2_asg           & $
PRINT,';;  ',gd_y_aum,gd_y_asg           & $
PRINT,';;  ',gd_n_aum,gd_n_asg
;;           429         145
;;           100          34          11
;;            92          38
;;            64          36
;;            18           1

PRINT,';;  ',1d2*n_all[0]/(1d0*n_all_cfa[0])                           & $
PRINT,';;  ',1d2*[gd_y_all[0],gd_n_all[0],gd_m_all[0]]/(1d0*n_all[0])  & $
PRINT,';;  ',1d2*[gd_2_aum[0],gd_2_asg[0]]/(1d0*n_all[0])              & $
PRINT,';;  ',1d2*[gd_y_aum[0],gd_y_asg[0]]/(1d0*n_all[0])              & $
PRINT,';;  ',1d2*[gd_n_aum[0],gd_n_asg[0]]/(1d0*n_all[0])
;;         33.799534
;;         68.965517       23.448276       7.5862069
;;         63.448276       26.206897
;;         44.137931       24.827586
;;         12.413793      0.68965517

;;  Summary:
;;    Of the 429 FF IP shocks in the CfA database between Jan. 1, 1995 and Mar. 15, 2016,
;;    there were 145 satisfying:
;;      (M_f ≥ 1) && (ø_Bn ≥ 45) && (1 ≤ M_A ≤ 3) && (1 ≤ N2/N1 ≤ 3) && (ß_1 ≤ 1)
;;
;;    Of the 145 meeting these requirements:
;;      --  100(~68.97%) show clear whistler precursors, 34(~23.45%) show no evidence
;;          of whistler precursors, and 11(~7.59%) have ambiguous features that may be
;;          or may not be whistler precursors;
;;      --  92(~63.45%) were observed as undersampled and/or under resolved and
;;          only 38(~26.21%) appeared to be fully resolved (i.e., no spiky-discontinuous
;;          features or triangle-like fluctuations); and
;;      --  thus, only 36(~24.83%) of the 100 shocks with whistlers were fully resolved.


;;  Ramírez Vélez et al.  [2012] JGR  :  looked at beta vs. wave occurrence for STEREO shocks
;;  Matsukiyo & Scholer,  [2003] JGR  :  PIC with beta ~ 0.1 with upstream waves (2 MTSI)
;;  Hellinger et al.,     [2007] GRL  :  Hybrid showing whistler occurrence vs. upstream beta and M_A
;;  Hellinger & Mangeney, [1997] ESA  :  Hybrid with beta ~ 0.5 and M_A ~ 2.6 with upstream whistlers


;;  Re-define indices in terms of entire input arrays
good_y_all     = good_A[good_y_all0]
good_n_all     = good_A[good_n_all0]
good_m_all     = good_A[good_m_all0]
good_2_aum     = good_A[good_2_aum0]
good_2_asg     = good_A[good_2_asg0]
good_y_aum     = good_A[good_y_aum0]
good_y_asg     = good_A[good_y_asg0]
good_n_aum     = good_A[good_n_aum0]
good_n_asg     = good_A[good_n_asg0]

;;----------------------------------------------------------------------------------------
;;  Plot results
;;----------------------------------------------------------------------------------------
thck           = 2e0
chsz           = 2e0
sysz           = 2
vec_cols       = [250,200,30]
psy_vals       = [4,5,6]

lbw_window,WIND_N=1,SC_FRAC=0.50
lbw_window,WIND_N=2,SC_FRAC=0.50

pstr_lin       = {XSTYLE:1,YSTYLE:1,THICK:thck[0],CHARSIZE:chsz[0],XMINOR:5L,YMINOR:5L,$
                  XLOG:0,YLOG:0,NODATA:1}
pstr_log       = {XSTYLE:1,YSTYLE:1,THICK:thck[0],CHARSIZE:chsz[0],XMINOR:9L,YMINOR:9L,$
                  XLOG:1,YLOG:1,NODATA:1}


xdat_0         = M_VA___up[good_y_asg]
xdat_1         = M_VA___up[good_y_aum]
xdat_2         = M_VA___up[good_n_all]
ydat_0         = vshn___up[good_y_asg]
ydat_1         = vshn___up[good_y_aum]
ydat_2         = vshn___up[good_n_all]
xran1          = [1e0,3.1e0]
yran1          = [1e0,1e3]
xttl1          = 'M_A [upstream]'
yttl1          = 'Vshn [km/s, upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])


ydat_0         = ushn___up[good_y_asg]
ydat_1         = ushn___up[good_y_aum]
ydat_2         = ushn___up[good_n_all]
yran1          = [1e1,3e2]
yttl1          = 'Ushn [km/s, upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])


ydat_0         = thetbn_up[good_y_asg]
ydat_1         = thetbn_up[good_y_aum]
ydat_2         = thetbn_up[good_n_all]
yran1          = [45e0,9e1]
yttl1          = 'theta_Bn [deg, upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])


ydat_0         = beta_t_up[good_y_asg]
ydat_1         = beta_t_up[good_y_aum]
ydat_2         = beta_t_up[good_n_all]
yran1          = [1e-2,1e0]
yttl1          = 'beta [upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])


ydat_0         = vinup_ang[good_y_asg]
ydat_1         = vinup_ang[good_y_aum]
ydat_2         = vinup_ang[good_n_all]
yran1          = [0e0,18e1]
yttl1          = 'Angle(Viup . nsh) [deg, upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])


ydat_0         = COS(thetbn_up[good_y_asg]*!DPI/18d1)
ydat_1         = COS(thetbn_up[good_y_aum]*!DPI/18d1)
ydat_2         = COS(thetbn_up[good_n_all]*!DPI/18d1)
yran1          = [0,1e0]
yttl1          = 'Cos(theta_Bn) [upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])


ydat_0         = 1d0/COS(thetbn_up[good_y_asg]*!DPI/18d1)
ydat_1         = 1d0/COS(thetbn_up[good_y_aum]*!DPI/18d1)
ydat_2         = 1d0/COS(thetbn_up[good_n_all]*!DPI/18d1)
yran1          = [1e0,35e0]
yttl1          = 'Cos^(-1)[theta_Bn] [upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])


ydat_0         = vshn___up[good_y_asg]/COS(thetbn_up[good_y_asg]*!DPI/18d1)
ydat_1         = vshn___up[good_y_aum]/COS(thetbn_up[good_y_aum]*!DPI/18d1)
ydat_2         = vshn___up[good_n_all]/COS(thetbn_up[good_n_all]*!DPI/18d1)
yran1          = [1e1,15e3]
yttl1          = 'Vshn Cos^(-1)[theta_Bn] [km/s, upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])


ydat_0         = ushn___up[good_y_asg]/COS(thetbn_up[good_y_asg]*!DPI/18d1)
ydat_1         = ushn___up[good_y_aum]/COS(thetbn_up[good_y_aum]*!DPI/18d1)
ydat_2         = ushn___up[good_n_all]/COS(thetbn_up[good_n_all]*!DPI/18d1)
yran1          = [1e1,4e3]
yttl1          = 'Ushn Cos^(-1)[theta_Bn] [km/s, upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])


WSET,1
WSHOW,1
PLOT,xdat_0,ydat_0,_EXTRA=pstr_lin,XRANGE=xran1,YRANGE=yran1,XTITLE=xttl1[0],YTITLE=yttl1[0]
  OPLOT,xdat_0,ydat_0,COLOR=vec_cols[0],PSYM=psy_vals[0],SYMSIZE=sysz[0]
  OPLOT,xdat_1,ydat_1,COLOR=vec_cols[1],PSYM=psy_vals[1],SYMSIZE=sysz[0]
  OPLOT,xdat_2,ydat_2,COLOR=vec_cols[2],PSYM=psy_vals[2],SYMSIZE=sysz[0]


WSET,1
WSHOW,1
PLOT,xdat_0,ydat_0,_EXTRA=pstr_log,XRANGE=xran1,YRANGE=yran1,XTITLE=xttl1[0],YTITLE=yttl1[0]
  OPLOT,xdat_0,ydat_0,COLOR=vec_cols[0],PSYM=psy_vals[0],SYMSIZE=sysz[0]
  OPLOT,xdat_1,ydat_1,COLOR=vec_cols[1],PSYM=psy_vals[1],SYMSIZE=sysz[0]
  OPLOT,xdat_2,ydat_2,COLOR=vec_cols[2],PSYM=psy_vals[2],SYMSIZE=sysz[0]




xdat_0         = M_VA___up[good_y_aum]
xdat_1         = M_VA___up[good_n_aum]
xdat_2         = M_VA___up[good_n_asg]
ydat_0         = vshn___up[good_y_aum]
ydat_1         = vshn___up[good_n_aum]
ydat_2         = vshn___up[good_n_asg]
xran1          = [1e0,3.1e0]
yran1          = [1e0,1e3]
xttl1          = 'M_A [upstream]'
yttl1          = 'Vshn [km/s, upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])

WSET,1
WSHOW,1
PLOT,xdat_0,ydat_0,_EXTRA=pstr_lin,XRANGE=xran1,YRANGE=yran1,XTITLE=xttl1[0],YTITLE=yttl1[0]
  OPLOT,xdat_0,ydat_0,COLOR=vec_cols[0],PSYM=psy_vals[0],SYMSIZE=sysz[0]
  OPLOT,xdat_1,ydat_1,COLOR=vec_cols[1],PSYM=psy_vals[1],SYMSIZE=sysz[0]
  OPLOT,xdat_2,ydat_2,COLOR=vec_cols[2],PSYM=psy_vals[2],SYMSIZE=sysz[0]


ydat_0         = ushn___up[good_y_aum]
ydat_1         = ushn___up[good_n_aum]
ydat_2         = ushn___up[good_n_asg]
yran1          = [1e1,3e2]
yttl1          = 'Ushn [km/s, upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])

WSET,1
WSHOW,1
PLOT,xdat_0,ydat_0,_EXTRA=pstr_lin,XRANGE=xran1,YRANGE=yran1,XTITLE=xttl1[0],YTITLE=yttl1[0]
  OPLOT,xdat_0,ydat_0,COLOR=vec_cols[0],PSYM=psy_vals[0],SYMSIZE=sysz[0]
  OPLOT,xdat_1,ydat_1,COLOR=vec_cols[1],PSYM=psy_vals[1],SYMSIZE=sysz[0]
  OPLOT,xdat_2,ydat_2,COLOR=vec_cols[2],PSYM=psy_vals[2],SYMSIZE=sysz[0]


ydat_0         = vi_mag_up[good_y_aum]
ydat_1         = vi_mag_up[good_n_aum]
ydat_2         = vi_mag_up[good_n_asg]
yran1          = [1e2,7e2]
yttl1          = '|Vsw| [km/s, upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])

WSET,1
WSHOW,1
PLOT,xdat_0,ydat_0,_EXTRA=pstr_lin,XRANGE=xran1,YRANGE=yran1,XTITLE=xttl1[0],YTITLE=yttl1[0]
  OPLOT,xdat_0,ydat_0,COLOR=vec_cols[0],PSYM=psy_vals[0],SYMSIZE=sysz[0]
  OPLOT,xdat_1,ydat_1,COLOR=vec_cols[1],PSYM=psy_vals[1],SYMSIZE=sysz[0]
  OPLOT,xdat_2,ydat_2,COLOR=vec_cols[2],PSYM=psy_vals[2],SYMSIZE=sysz[0]



xdat_0         = M_VA___up[good_y_all]
xdat_1         = M_VA___up[good_n_all]
xdat_2         = M_VA___up[good_m_all]
ydat_0         = vshn___up[good_y_all]
ydat_1         = vshn___up[good_n_all]
ydat_2         = vshn___up[good_m_all]
xran1          = [1e0,3.1e0]
yran1          = [1e0,1e3]
xttl1          = 'M_A [upstream]'
yttl1          = 'Vshn [km/s, upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])

WSET,1
WSHOW,1
PLOT,xdat_0,ydat_0,_EXTRA=pstr_lin,XRANGE=xran1,YRANGE=yran1,XTITLE=xttl1[0],YTITLE=yttl1[0]
  OPLOT,xdat_0,ydat_0,COLOR=vec_cols[0],PSYM=psy_vals[0],SYMSIZE=sysz[0]
  OPLOT,xdat_1,ydat_1,COLOR=vec_cols[1],PSYM=psy_vals[1],SYMSIZE=sysz[0]
  OPLOT,xdat_2,ydat_2,COLOR=vec_cols[2],PSYM=psy_vals[2],SYMSIZE=sysz[0]

ydat_0         = thetbn_up[good_y_all]
ydat_1         = thetbn_up[good_n_all]
ydat_2         = thetbn_up[good_m_all]
yran1          = [45e0,9e1]
xttl1          = 'M_A [upstream]'
yttl1          = 'theta_Bn [deg, upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])

WSET,1
WSHOW,1
PLOT,xdat_0,ydat_0,_EXTRA=pstr_lin,XRANGE=xran1,YRANGE=yran1,XTITLE=xttl1[0],YTITLE=yttl1[0]
  OPLOT,xdat_0,ydat_0,COLOR=vec_cols[0],PSYM=psy_vals[0],SYMSIZE=sysz[0]
  OPLOT,xdat_1,ydat_1,COLOR=vec_cols[1],PSYM=psy_vals[1],SYMSIZE=sysz[0]
  OPLOT,xdat_2,ydat_2,COLOR=vec_cols[2],PSYM=psy_vals[2],SYMSIZE=sysz[0]



ydat_0         = beta_t_up[good_y_all]
ydat_1         = beta_t_up[good_n_all]
ydat_2         = beta_t_up[good_m_all]
xran2          = xran1
yran2          = [1e-2,1e0]
xttl2          = 'M_A [upstream]'
yttl2          = 'beta [upstream]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])

WSET,2
WSHOW,2
PLOT,xdat_0,ydat_0,_EXTRA=pstr_lin,XRANGE=xran2,YRANGE=yran2,XTITLE=xttl2[0],YTITLE=yttl2[0]
  OPLOT,xdat_0,ydat_0,COLOR=vec_cols[0],PSYM=psy_vals[0],SYMSIZE=sysz[0]
  OPLOT,xdat_1,ydat_1,COLOR=vec_cols[1],PSYM=psy_vals[1],SYMSIZE=sysz[0]
  OPLOT,xdat_2,ydat_2,COLOR=vec_cols[2],PSYM=psy_vals[2],SYMSIZE=sysz[0]

ydat_0         = N2_N1__up[good_y_all]
ydat_1         = N2_N1__up[good_n_all]
ydat_2         = N2_N1__up[good_m_all]
xran2          = xran1
yran2          = [1e0,3e0]
xttl2          = 'M_A [upstream]'
yttl2          = 'N2/N1 [shock compr. ratio]'
PRINT, minmax([ydat_0,ydat_1,ydat_2])

WSET,2
WSHOW,2
PLOT,xdat_0,ydat_0,_EXTRA=pstr_lin,XRANGE=xran2,YRANGE=yran2,XTITLE=xttl2[0],YTITLE=yttl2[0]
  OPLOT,xdat_0,ydat_0,COLOR=vec_cols[0],PSYM=psy_vals[0],SYMSIZE=sysz[0]
  OPLOT,xdat_1,ydat_1,COLOR=vec_cols[1],PSYM=psy_vals[1],SYMSIZE=sysz[0]
  OPLOT,xdat_2,ydat_2,COLOR=vec_cols[2],PSYM=psy_vals[2],SYMSIZE=sysz[0]


xran2          = [1e0,1e1]
yran2          = [1e-2,1e0]
xttl2          = 'M_A [upstream]'
yttl2          = 'beta [upstream]'

WSET,2
WSHOW,2
PLOT,xdat_0,ydat_0,_EXTRA=pstr_log,XRANGE=xran2,YRANGE=yran2,XTITLE=xttl2[0],YTITLE=yttl2[0]
  OPLOT,xdat_0,ydat_0,COLOR=vec_cols[0],PSYM=psy_vals[0],SYMSIZE=sysz[0]
  OPLOT,xdat_1,ydat_1,COLOR=vec_cols[1],PSYM=psy_vals[1],SYMSIZE=sysz[0]
  OPLOT,xdat_2,ydat_2,COLOR=vec_cols[2],PSYM=psy_vals[2],SYMSIZE=sysz[0]



;;----------------------------------------------------------------------------------------
;;  Print results
;;----------------------------------------------------------------------------------------
;test_f         = (ABS(beta_t_up) LE 1e0) AND (ABS(Mfast__up) LE 3e0) AND (ABS(thetbn_up) GE 45e0)
;test_A         = (ABS(beta_t_up) LE 1e0) AND (ABS(M_VA___up) LE 3e0) AND (ABS(thetbn_up) GE 45e0)
;good_f         = WHERE(test_f,gd_f)
;good_A         = WHERE(test_A,gd_A)

mform          = '(";;  ",2a26,a8,6f10.1)'
FOR k=0L, gd_A[0] - 1L DO BEGIN                                                              $
  j    = good_A[k]                                                                         & $
  dds  = REFORM(updn_ymdb[j,*])                                                            & $
  meth = rhmeth_bst[j]                                                                     & $
  data = [vshn___up[j],thetbn_up[j],beta_t_up[j],N2_N1__up[j],M_VA___up[j],Mfast__up[j]]   & $
  PRINT,dds,meth[0],data,FORMAT=mform[0]

;;-----------------------------------------------------------------------------------------------------------------------------
;;             Start                      End              Method     Vshn     Theta     beta_T     N2/N1      M_A       M_f
;;=============================================================================================================================
;;     1995-03-04/00:36:54.500   1995-03-04/00:37:02.500    RH08     380.2      86.1       0.5       1.9       2.6       2.0
;;     1995-04-17/23:33:00.500   1995-04-17/23:33:08.500    RH08     389.2      80.0       0.2       1.8       1.3       1.1
;;     1995-07-22/05:35:39.500   1995-07-22/05:35:47.500    RH08       9.3      52.1       0.2       2.0       1.4       1.2
;;     1995-08-22/12:56:42.500   1995-08-22/12:56:50.500    RH08     381.0      66.1       0.7       2.6       2.6       1.8
;;     1995-08-24/22:11:00.500   1995-08-24/22:11:08.500    RH08     387.7      73.7       0.3       1.5       2.5       2.0
;;     1995-09-14/21:24:51.500   1995-09-14/21:24:59.500    RH08     328.4      81.3       0.5       1.6       2.0       1.5
;;     1995-10-22/21:20:12.500   1995-10-22/21:20:20.500    RH08     333.0      65.7       0.5       1.8       2.7       2.1
;;     1995-12-24/05:57:30.500   1995-12-24/05:57:38.500    RH08     422.8      58.4       0.3       2.6       2.9       2.5
;;     1996-02-06/19:14:18.500   1996-02-06/19:14:26.500    RH08     383.4      48.4       0.4       1.7       1.7       1.4
;;     1996-04-03/09:47:12.500   1996-04-03/09:47:20.500    RH08     379.2      75.7       0.4       1.5       2.0       1.6
;;     1996-04-08/02:41:06.500   1996-04-08/02:41:14.500    RH08     182.3      73.3       0.2       1.7       2.4       2.1
;;     1996-06-18/22:35:51.500   1996-06-18/22:35:59.500    RH08     460.8      49.9       0.3       1.5       1.7       1.4
;;     1997-01-05/03:20:42.500   1997-01-05/03:20:50.500    RH09     384.2      64.3       0.3       1.6       1.4       1.2
;;     1997-03-15/22:30:27.500   1997-03-15/22:30:35.500     MX3     386.1      49.9       0.5       1.5       1.4       1.1
;;     1997-04-10/12:58:30.500   1997-04-10/12:58:38.500    RH08     371.4      58.5       0.3       1.5       1.5       1.2
;;     1997-04-16/12:21:21.500   1997-04-16/12:21:29.500    RH08     401.3      67.7       0.9       1.6       2.2       1.4
;;     1997-05-20/05:10:45.500   1997-05-20/05:10:53.500    RH08     349.6      46.0       0.5       2.5       1.9       1.5
;;     1997-05-25/13:49:51.500   1997-05-25/13:49:59.500    RH08     374.1      85.5       0.6       1.5       2.6       1.8
;;     1997-05-26/09:09:03.500   1997-05-26/09:09:11.500    RH08     335.2      50.3       0.6       1.8       3.0       2.3
;;     1997-08-05/04:59:00.500   1997-08-05/04:59:08.500    RH08     392.4      56.5       0.8       1.5       1.5       1.0
;;     1997-09-03/08:38:36.500   1997-09-03/08:38:44.500     MX3     477.3      78.2       0.3       1.5       1.3       1.1
;;     1997-10-10/15:57:03.500   1997-10-10/15:57:11.500    RH08     477.3      87.7       0.1       1.6       1.6       1.5
;;     1997-10-24/11:18:03.500   1997-10-24/11:18:11.500    RH08     490.9      68.3       0.2       2.5       1.9       1.7
;;     1997-11-01/06:14:39.500   1997-11-01/06:14:47.500    RH08     309.2      77.3       0.4       1.5       2.4       1.8
;;     1997-12-10/04:33:09.500   1997-12-10/04:33:17.500    RH08     391.2      70.9       0.3       2.5       2.7       2.3
;;     1997-12-30/01:13:39.500   1997-12-30/01:13:47.500    RH08     423.4      87.4       0.4       2.0       2.5       1.9
;;     1998-01-06/13:28:57.500   1998-01-06/13:29:05.500    RH08     408.4      82.3       0.3       2.8       2.4       2.0
;;     1998-02-18/07:48:39.500   1998-02-18/07:48:47.500    RH08     463.4      48.7       0.1       1.5       1.2       1.1
;;     1998-05-29/15:12:00.500   1998-05-29/15:12:08.500    RH08     692.5      64.5       0.6       2.1       1.8       1.4
;;     1998-08-06/07:16:03.500   1998-08-06/07:16:11.500    RH08     478.8      80.8       0.1       1.9       1.7       1.6
;;     1998-08-19/18:40:36.500   1998-08-19/18:40:44.500    RH08     334.7      45.5       0.4       2.3       2.8       2.3
;;     1998-11-08/04:41:12.500   1998-11-08/04:41:20.500    RH08     644.5      54.6       0.0       2.2       1.5       1.5
;;     1998-12-26/09:56:33.500   1998-12-26/09:56:41.500    RH09     483.7      78.6       0.4       1.5       1.4       1.1
;;     1998-12-28/18:20:12.500   1998-12-28/18:20:20.500    RH08     465.2      60.7       0.4       1.8       1.8       1.4
;;     1999-01-13/10:47:54.500   1999-01-13/10:48:02.500    RH08     433.1      70.9       0.5       2.1       2.5       1.9
;;     1999-02-17/07:12:09.500   1999-02-17/07:12:17.500    RH08     560.2      86.6       0.2       1.6       1.6       1.4
;;     1999-03-10/01:32:57.500   1999-03-10/01:33:05.500    RH08     509.3      84.7       0.9       1.8       2.8       1.7
;;     1999-04-16/11:13:57.500   1999-04-16/11:14:05.500    RH09     479.8      62.3       0.1       2.1       1.6       1.5
;;     1999-06-26/19:30:54.500   1999-06-26/19:31:02.500    RH08     467.2      59.4       0.3       2.2       2.2       1.8
;;     1999-08-04/01:44:33.500   1999-08-04/01:44:41.500    RH08     418.1      54.1       0.1       1.9       2.1       2.0
;;     1999-08-23/12:11:09.500   1999-08-23/12:11:17.500    RH08     491.2      60.7       0.0       1.6       1.5       1.4
;;     1999-09-15/07:43:42.500   1999-09-15/07:43:50.500    RH08     665.5      73.6       0.7       2.0       2.0       1.4
;;     1999-09-22/12:09:21.500   1999-09-22/12:09:29.500    RH08     510.7      70.8       0.4       2.6       2.4       1.9
;;     1999-10-21/02:20:48.500   1999-10-21/02:20:56.500    RH08     477.3      69.4       0.2       2.3       2.5       2.2
;;     1999-11-05/20:03:06.500   1999-11-05/20:03:14.500    RH08     392.6      52.7       0.3       1.5       1.5       1.2
;;     1999-11-13/12:48:54.500   1999-11-13/12:49:02.500    RH08     470.3      69.1       0.0       1.9       1.4       1.3
;;     2000-02-05/15:26:24.500   2000-02-05/15:26:32.500    RH08     444.0      68.1       0.2       1.9       1.3       1.1
;;     2000-02-14/07:12:57.500   2000-02-14/07:13:05.500    RH08     700.7      56.3       0.4       1.8       1.8       1.5
;;     2000-06-23/12:57:54.500   2000-06-23/12:58:02.500    RH08     527.6      56.1       0.5       2.6       2.8       2.2
;;     2000-07-13/09:43:45.500   2000-07-13/09:43:53.500    RH08     641.4      51.9       0.7       2.4       2.1       1.5
;;     2000-07-26/19:00:09.500   2000-07-26/19:00:17.500    RH08     425.0      86.0       0.6       1.8       2.0       1.4
;;     2000-07-28/06:38:42.500   2000-07-28/06:38:50.500    RH08     491.4      56.2       0.0       2.8       1.9       1.8
;;     2000-08-10/05:13:18.500   2000-08-10/05:13:26.500    RH08     379.9      67.0       0.2       1.7       1.3       1.1
;;     2000-08-11/18:49:30.500   2000-08-11/18:49:38.500    RH08     605.1      78.2       0.0       2.7       1.3       1.3
;;     2000-10-03/01:02:21.500   2000-10-03/01:02:29.500    RH08     457.2      51.5       0.6       1.9       2.2       1.7
;;     2000-10-28/06:38:45.500   2000-10-28/06:38:53.500    RH08     413.6      59.1       0.3       2.1       2.0       1.7
;;     2000-10-28/09:30:39.500   2000-10-28/09:30:47.500    RH08     441.1      51.6       0.7       2.5       2.1       1.5
;;     2000-10-31/17:09:54.500   2000-10-31/17:10:02.500    RH08     475.3      71.1       0.2       2.6       1.8       1.6
;;     2000-11-04/02:25:42.500   2000-11-04/02:25:50.500    RH08     450.1      66.4       0.3       2.3       2.3       1.9
;;     2000-11-06/09:30:00.500   2000-11-06/09:30:08.500    RH08     626.0      70.4       0.3       2.3       2.0       1.7
;;     2000-11-11/04:12:30.500   2000-11-11/04:12:38.500    RH08     975.6      56.7       0.3       2.1       1.8       1.5
;;     2000-11-26/11:43:24.500   2000-11-26/11:43:32.500    RH08     509.7      64.9       0.7       2.5       2.5       1.8
;;     2000-11-28/05:25:54.500   2000-11-28/05:26:02.500    RH08     603.8      58.3       0.3       2.1       1.6       1.4
;;     2001-01-17/04:07:48.500   2001-01-17/04:07:56.500    RH08     379.2      69.7       0.4       1.5       1.7       1.3
;;     2001-03-03/11:29:12.500   2001-03-03/11:29:20.500    RH08     553.6      45.5       0.5       2.2       2.4       1.9
;;     2001-03-22/13:59:03.500   2001-03-22/13:59:11.500    RH08     382.0      73.5       0.2       2.3       1.4       1.3
;;     2001-03-27/18:07:45.500   2001-03-27/18:07:53.500    RH08     552.1      57.2       0.4       2.0       2.1       1.8
;;     2001-04-21/15:29:09.500   2001-04-21/15:29:17.500    RH08     395.4      81.0       0.5       1.7       2.5       1.8
;;     2001-05-06/09:06:03.500   2001-05-06/09:06:11.500    RH08     365.6      45.8       0.4       1.5       1.6       1.3
;;     2001-05-12/10:03:09.500   2001-05-12/10:03:17.500    RH08     574.7      68.2       0.1       1.4       1.2       1.1
;;     2001-08-12/16:12:42.500   2001-08-12/16:12:50.500    RH08     340.2      72.4       0.2       1.7       2.2       1.9
;;     2001-08-31/01:25:00.500   2001-08-31/01:25:08.500    RH08     475.3      82.5       0.3       1.4       1.5       1.2
;;     2001-09-13/02:31:24.500   2001-09-13/02:31:32.500    RH08     454.5      72.1       0.3       1.5       1.3       1.1
;;     2001-10-28/03:13:42.500   2001-10-28/03:13:50.500    RH08     591.8      60.3       0.0       2.9       2.3       2.3
;;     2001-11-30/18:15:42.500   2001-11-30/18:15:50.500    RH08     417.9      59.7       0.4       1.4       2.0       1.6
;;     2001-12-21/14:10:12.500   2001-12-21/14:10:20.500    RH08     565.8      65.1       0.1       1.5       2.2       2.0
;;     2001-12-30/20:05:03.500   2001-12-30/20:05:11.500    RH08     669.0      63.0       0.6       2.3       2.5       1.8
;;     2002-01-17/05:26:51.500   2002-01-17/05:26:59.500    RH09     404.3      51.2       0.2       1.4       1.3       1.1
;;     2002-01-31/21:38:06.500   2002-01-31/21:38:14.500    RH08     363.9      67.9       0.1       2.1       2.4       2.1
;;     2002-03-23/11:24:03.500   2002-03-23/11:24:11.500    RH08     520.1      68.0       0.5       2.6       2.8       2.1
;;     2002-03-29/22:15:09.500   2002-03-29/22:15:17.500    RH08     398.7      82.9       0.7       2.7       2.9       2.0
;;     2002-05-21/21:14:12.500   2002-05-21/21:14:20.500    RH09     257.3      49.5       0.5       2.2       1.9       1.5
;;     2002-06-29/21:10:21.500   2002-06-29/21:10:29.500    RH08     385.4      61.1       0.3       1.4       1.4       1.2
;;     2002-08-01/23:09:03.500   2002-08-01/23:09:11.500    RH08     497.4      70.1       0.1       2.0       1.5       1.4
;;     2002-09-30/07:54:21.500   2002-09-30/07:54:29.500    RH08     326.5      78.8       0.2       2.1       1.4       1.2
;;     2002-10-02/22:41:00.500   2002-10-02/22:41:08.500    RH08     527.2      78.4       0.4       2.1       2.0       1.6
;;     2002-11-09/18:27:45.500   2002-11-09/18:27:53.500    RH08     425.0      70.0       0.1       2.0       1.8       1.7
;;     2003-05-29/18:31:03.500   2003-05-29/18:31:11.500    RH08     907.8      73.0       0.1       2.0       2.0       1.9
;;     2003-06-18/04:42:00.500   2003-06-18/04:42:08.500    RH08     618.7      86.8       0.2       1.5       1.8       1.5
;;     2004-04-12/18:27:45.000   2004-04-12/18:27:53.000    RH08     558.6      60.2       0.5       1.9       2.7       2.0
;;     2005-05-06/12:08:33.500   2005-05-06/12:08:41.500    RH08     416.8      48.6       0.4       1.6       2.4       1.9
;;     2005-05-07/18:26:12.500   2005-05-07/18:26:20.500    RH08     437.9      61.6       0.2       1.5       1.1       1.0
;;     2005-06-16/08:09:06.500   2005-06-16/08:09:14.500    RH08     620.6      66.0       0.0       2.0       1.3       1.3
;;     2005-07-10/02:42:27.500   2005-07-10/02:42:35.500    RH08     540.5      80.7       0.1       1.7       2.3       2.1
;;     2005-07-16/01:40:54.500   2005-07-16/01:41:02.500    RH08     421.8      84.0       0.6       1.7       2.0       1.5
;;     2005-08-01/06:00:48.500   2005-08-01/06:00:56.500    RH08     479.6      84.2       0.2       1.8       1.8       1.6
;;     2005-08-24/05:35:18.500   2005-08-24/05:35:26.500    RH08     579.1      86.9       0.3       2.5       2.0       1.6
;;     2005-09-02/13:50:09.500   2005-09-02/13:50:17.500    RH08     587.0      53.0       0.5       2.2       2.6       2.0
;;     2005-09-15/08:36:27.500   2005-09-15/08:36:35.500    RH08     683.7      54.8       0.4       2.8       2.5       2.1
;;     2005-12-30/23:45:15.500   2005-12-30/23:45:23.500    RH08     619.0      71.7       0.5       1.5       1.6       1.2
;;     2006-08-19/09:38:45.500   2006-08-19/09:38:53.500    RH08     373.3      46.9       0.4       1.5       1.2       1.0
;;     2006-11-03/09:37:12.500   2006-11-03/09:37:20.500    RH08     397.5      87.8       0.4       1.5       2.0       1.6
;;     2007-07-20/03:27:15.500   2007-07-20/03:27:23.500    RH08     357.2      66.3       0.6       1.7       2.0       1.4
;;     2007-08-22/04:33:57.500   2007-08-22/04:34:05.500    RH08     356.9      62.0       0.6       1.5       2.1       1.5
;;     2007-12-17/01:53:15.500   2007-12-17/01:53:23.500    RH08     289.3      53.8       0.6       2.3       2.3       1.7
;;     2008-05-28/01:17:33.500   2008-05-28/01:17:41.500    RH08     402.4      75.1       0.6       2.2       2.9       2.0
;;     2008-06-24/19:10:36.500   2008-06-24/19:10:44.500    RH08     354.8      49.7       0.4       1.6       2.0       1.7
;;     2009-02-03/19:20:57.500   2009-02-03/19:21:05.500    RH08     407.7      85.2       0.1       1.8       1.7       1.6
;;     2009-06-24/09:52:15.500   2009-06-24/09:52:23.500    RH08     350.4      88.1       0.6       1.7       2.8       2.0
;;     2009-06-27/11:04:12.500   2009-06-27/11:04:20.500    RH08     426.1      87.5       0.3       1.5       1.6       1.3
;;     2009-10-21/23:15:06.500   2009-10-21/23:15:14.500    RH08     307.7      66.0       0.6       2.1       2.4       1.7
;;     2010-04-11/12:20:51.500   2010-04-11/12:20:59.500    RH08     465.2      60.3       0.3       2.0       2.5       2.2
;;     2011-02-04/01:50:51.500   2011-02-04/01:50:59.500    RH10     285.1      73.2       0.3       2.1       2.0       1.6
;;     2011-07-11/08:27:21.500   2011-07-11/08:27:29.500    RH08     601.4      78.4       0.6       1.9       2.8       2.0
;;     2011-09-16/18:57:03.500   2011-09-16/18:57:11.500    RH08     291.1      71.2       0.1       2.4       1.3       1.3
;;     2011-09-25/10:46:27.500   2011-09-25/10:46:35.500    RH08      85.6      83.8       0.3       2.4       1.1       1.1
;;     2012-01-21/04:01:57.500   2012-01-21/04:02:05.500    RH08     326.8      83.2       0.1       1.5       1.8       1.7
;;     2012-01-30/15:43:09.500   2012-01-30/15:43:17.500    RH08     411.1      53.2       0.2       2.9       2.8       2.5
;;     2012-03-07/03:28:33.500   2012-03-07/03:28:41.500    RH08     479.0      82.4       0.2       1.9       2.1       1.9
;;     2012-04-19/17:13:27.500   2012-04-19/17:13:35.500    RH08     410.1      84.2       0.6       1.4       2.5       1.7
;;     2012-06-16/19:34:33.500   2012-06-16/19:34:41.500    RH08     486.9      70.2       0.5       1.7       2.4       1.8
;;     2012-10-08/04:12:09.500   2012-10-08/04:12:17.500    RH08     465.4      74.4       0.2       1.9       2.3       2.0
;;     2012-11-12/22:12:36.500   2012-11-12/22:12:44.500    RH08     377.1      65.4       0.3       2.0       2.5       2.1
;;     2012-11-26/04:32:45.500   2012-11-26/04:32:53.500    RH08     586.4      71.0       0.4       2.1       2.2       1.8
;;     2012-12-14/19:06:09.500   2012-12-14/19:06:17.500    RH08     384.3      61.6       0.3       1.5       2.1       1.8
;;     2013-01-17/00:23:39.500   2013-01-17/00:23:47.500    RH08     424.9      78.7       0.7       1.4       1.8       1.3
;;     2013-02-13/00:47:42.500   2013-02-13/00:47:50.500    RH08     447.8      75.7       0.5       1.7       2.6       2.0
;;     2013-04-30/08:52:42.500   2013-04-30/08:52:50.500    RH08     461.4      64.9       0.3       1.5       2.2       1.8
;;     2013-06-10/02:51:57.500   2013-06-10/02:52:05.500    RH08     387.7      72.6       0.6       1.9       1.6       1.2
;;     2013-07-12/16:43:21.500   2013-07-12/16:43:29.500    RH08     499.3      56.8       0.4       2.0       2.3       1.9
;;     2013-09-02/01:56:48.500   2013-09-02/01:56:56.500    RH08     524.7      60.1       0.5       1.6       2.2       1.7
;;     2013-10-26/21:25:57.500   2013-10-26/21:26:05.500    RH08     336.5      46.9       0.1       1.6       1.6       1.5
;;     2014-02-13/08:55:24.500   2014-02-13/08:55:32.500    RH08     465.6      68.3       0.0       1.6       1.7       1.7
;;     2014-02-15/12:46:30.500   2014-02-15/12:46:38.500    RH08     499.6      78.3       0.4       2.1       2.7       2.1
;;     2014-02-19/03:09:33.500   2014-02-19/03:09:41.500    RH08     632.4      72.0       0.0       1.6       2.1       2.0
;;     2014-04-19/17:48:18.500   2014-04-19/17:48:26.500    RH08     549.2      50.5       0.1       1.8       1.6       1.5
;;     2014-05-07/21:19:30.500   2014-05-07/21:19:38.500    RH08     386.4      69.4       0.1       1.6       1.2       1.1
;;     2014-05-29/08:26:24.500   2014-05-29/08:26:32.500    RH08     381.7      64.2       0.2       1.8       1.3       1.1
;;     2014-07-14/13:38:06.500   2014-07-14/13:38:14.500    RH08     278.1      70.2       0.3       1.3       1.3       1.1
;;     2015-05-06/00:55:45.500   2015-05-06/00:55:53.500    RH08     527.5      87.5       0.2       2.2       2.6       2.3
;;     2015-06-05/08:31:03.500   2015-06-05/08:31:11.500    RH08     326.9      84.5       0.8       1.4       2.4       1.6
;;     2015-06-24/13:07:09.500   2015-06-24/13:07:17.500    RH08     591.7      85.5       0.1       1.9       2.1       2.0
;;     2015-08-15/07:43:36.500   2015-08-15/07:43:44.500    RH08     477.4      56.8       0.1       2.3       2.4       2.3
;;     2016-03-11/04:29:09.500   2016-03-11/04:29:17.500    RH08     363.1      53.1       0.7       2.2       2.0       1.5
;;     2016-03-14/16:16:27.500   2016-03-14/16:16:35.500    RH08     412.5      61.4       0.8       1.7       2.3       1.5



;;  1st Letter
;;  Y   =  Yes
;;  N   =  No
;;  M   =  Maybe or Unclear

;;  2nd Letter
;;  S   =  resolved or sampled well enough
;;  U   =  fluctuation present but undersampled (e.g., looks like triangle wave)
;;  G   =  data gap or missing data (but still well resolved)
;;  M   =  data gap or missing data (and undersampled)
;;  N   =  nothing

;;-------------------------------------------------------------------------------------------------------------------------------------------
;;             Start                      End              Method     Vshn     Theta     beta_T     N2/N1      M_A       M_f      Whistler
;;===========================================================================================================================================
;;     1995/03/04 00:36:54.500   1995/03/04 00:37:02.500    RH08     380.2      86.1       0.5       1.9       2.6       2.0         MU
;;     1995/04/17 23:33:00.500   1995/04/17 23:33:10.500    RH08     389.2      80.0       0.2       1.8       1.3       1.1         YU
;;     1995/07/22 05:35:39.500   1995/07/22 05:35:47.500    RH08       9.3      52.1       0.2       2.0       1.4       1.2         YS
;;     1995/08/22 12:56:42.500   1995/08/22 12:56:55.500    RH08     381.0      66.1       0.7       2.6       2.6       1.8         YG
;;     1995/08/24 22:11:00.500   1995/08/24 22:11:08.500    RH08     387.7      73.7       0.3       1.5       2.5       2.0         YS
;;     1995/09/14 21:24:51.500   1995/09/14 21:25:05.500    RH08     328.4      81.3       0.5       1.6       2.0       1.5         MU
;;     1995/10/22 21:20:12.500   1995/10/22 21:20:20.500    RH08     333.0      65.7       0.5       1.8       2.7       2.1         YU
;;     1995/12/24 05:57:30.500   1995/12/24 05:57:38.500    RH08     422.8      58.4       0.3       2.6       2.9       2.5         YU
;;     1996/02/06 19:14:18.500   1996/02/06 19:14:30.500    RH08     383.4      48.4       0.4       1.7       1.7       1.4         YU
;;     1996/04/03 09:47:12.500   1996/04/03 09:47:20.500    RH08     379.2      75.7       0.4       1.5       2.0       1.6         YS
;;     1996/04/08 02:41:06.500   1996/04/08 02:41:14.500    RH08     182.3      73.3       0.2       1.7       2.4       2.1         YS
;;     1996/06/18 22:35:51.500   1996/06/18 22:35:59.500    RH08     460.8      49.9       0.3       1.5       1.7       1.4         MU
;;     1997/01/05 03:20:42.500   1997/01/05 03:20:50.500    RH09     384.2      64.3       0.3       1.6       1.4       1.2         NN
;;     1997/03/15 22:30:27.500   1997/03/15 22:30:35.500     MX3     386.1      49.9       0.5       1.5       1.4       1.1         YS
;;     1997/04/10 12:58:30.500   1997/04/10 12:58:38.500    RH08     371.4      58.5       0.3       1.5       1.5       1.2         YU
;;     1997/04/16 12:21:21.500   1997/04/16 12:21:29.500    RH08     401.3      67.7       0.9       1.6       2.2       1.4         NU
;;     1997/05/20 05:10:43.500   1997/05/20 05:10:53.500    RH08     349.6      46.0       0.5       2.5       1.9       1.5         NN
;;     1997/05/25 13:49:51.500   1997/05/25 13:49:59.500    RH08     374.1      85.5       0.6       1.5       2.6       1.8         MU
;;     1997/05/26 09:09:03.500   1997/05/26 09:09:11.500    RH08     335.2      50.3       0.6       1.8       3.0       2.3         NU
;;     1997/08/05 04:59:00.500   1997/08/05 04:59:08.500    RH08     392.4      56.5       0.8       1.5       1.5       1.0         NU
;;     1997/09/03 08:38:36.500   1997/09/03 08:38:44.500     MX3     477.3      78.2       0.3       1.5       1.3       1.1         NU
;;     1997/10/10 15:57:03.500   1997/10/10 15:57:11.500    RH08     477.3      87.7       0.1       1.6       1.6       1.5         MU
;;     1997/10/24 11:18:03.500   1997/10/24 11:18:11.500    RH08     490.9      68.3       0.2       2.5       1.9       1.7         YS
;;     1997/11/01 06:14:39.500   1997/11/01 06:14:47.500    RH08     309.2      77.3       0.4       1.5       2.4       1.8         YS
;;     1997/12/10 04:33:09.500   1997/12/10 04:33:17.500    RH08     391.2      70.9       0.3       2.5       2.7       2.3         YU
;;     1997/12/30 01:13:39.500   1997/12/30 01:13:47.500    RH08     423.4      87.4       0.4       2.0       2.5       1.9         YU
;;     1998/01/06 13:28:57.500   1998/01/06 13:29:05.500    RH08     408.4      82.3       0.3       2.8       2.4       2.0         YU
;;     1998/02/18 07:48:35.500   1998/02/18 07:48:50.500    RH08     463.4      48.7       0.1       1.5       1.2       1.1         YS
;;     1998/05/29 15:12:00.500   1998/05/29 15:12:08.500    RH08     692.5      64.5       0.6       2.1       1.8       1.4         YM
;;     1998/08/06 07:16:03.500   1998/08/06 07:16:11.500    RH08     478.8      80.8       0.1       1.9       1.7       1.6         YU
;;     1998/08/19 18:40:36.500   1998/08/19 18:40:44.500    RH08     334.7      45.5       0.4       2.3       2.8       2.3         YU
;;     1998/11/08 04:41:12.500   1998/11/08 04:41:20.500    RH08     644.5      54.6       0.0       2.2       1.5       1.5         YU
;;     1998/12/26 09:56:15.500   1998/12/26 09:56:50.500    RH09     483.7      78.6       0.4       1.5       1.4       1.1         YU
;;     1998/12/28 18:20:12.500   1998/12/28 18:20:20.500    RH08     465.2      60.7       0.4       1.8       1.8       1.4         YU
;;     1999/01/13 10:47:30.500   1999/01/13 10:48:00.500    RH08     433.1      70.9       0.5       2.1       2.5       1.9         YU
;;     1999/02/17 07:12:09.500   1999/02/17 07:12:17.500    RH08     560.2      86.6       0.2       1.6       1.6       1.4         YU
;;     1999/03/10 01:32:57.500   1999/03/10 01:33:05.500    RH08     509.3      84.7       0.9       1.8       2.8       1.7         NN
;;     1999/04/16 11:13:45.500   1999/04/16 11:14:25.500    RH09     479.8      62.3       0.1       2.1       1.6       1.5         YS
;;     1999/06/26 19:30:54.500   1999/06/26 19:31:02.500    RH08     467.2      59.4       0.3       2.2       2.2       1.8         YM
;;     1999/08/04 01:44:25.500   1999/08/04 01:44:41.500    RH08     418.1      54.1       0.1       1.9       2.1       2.0         YS
;;     1999/08/23 12:11:09.500   1999/08/23 12:11:17.500    RH08     491.2      60.7       0.0       1.6       1.5       1.4         YS
;;     1999/09/15 07:43:35.500   1999/09/15 07:44:00.500    RH08     665.5      73.6       0.7       2.0       2.0       1.4         NN
;;     1999/09/22 12:09:21.500   1999/09/22 12:09:29.500    RH08     510.7      70.8       0.4       2.6       2.4       1.9         NU
;;     1999/10/21 02:20:48.500   1999/10/21 02:20:56.500    RH08     477.3      69.4       0.2       2.3       2.5       2.2         YM
;;     1999/11/05 20:02:50.500   1999/11/05 20:03:20.500    RH08     392.6      52.7       0.3       1.5       1.5       1.2         YS
;;     1999/11/13 12:48:54.500   1999/11/13 12:49:02.500    RH08     470.3      69.1       0.0       1.9       1.4       1.3         YU
;;     2000/02/05 15:26:24.500   2000/02/05 15:26:32.500    RH08     444.0      68.1       0.2       1.9       1.3       1.1         YS
;;     2000/02/14 07:12:50.500   2000/02/14 07:13:10.500    RH08     700.7      56.3       0.4       1.8       1.8       1.5         YS
;;     2000/06/23 12:57:50.500   2000/06/23 12:58:05.500    RH08     527.6      56.1       0.5       2.6       2.8       2.2         YS
;;     2000/07/13 09:43:30.500   2000/07/13 09:43:55.500    RH08     641.4      51.9       0.7       2.4       2.1       1.5         YU
;;     2000/07/26 19:00:09.500   2000/07/26 19:00:17.500    RH08     425.0      86.0       0.6       1.8       2.0       1.4         YU
;;     2000/07/28 06:38:42.500   2000/07/28 06:38:50.500    RH08     491.4      56.2       0.0       2.8       1.9       1.8         YM
;;     2000/08/10 05:13:10.500   2000/08/10 05:13:30.500    RH08     379.9      67.0       0.2       1.7       1.3       1.1         YU
;;     2000/08/11 18:49:30.500   2000/08/11 18:49:38.500    RH08     605.1      78.2       0.0       2.7       1.3       1.3         YU
;;     2000/10/03 01:02:10.500   2000/10/03 01:02:30.500    RH08     457.2      51.5       0.6       1.9       2.2       1.7         NU
;;     2000/10/28 06:38:30.500   2000/10/28 06:39:10.500    RH08     413.6      59.1       0.3       2.1       2.0       1.7         NN  (nice transverse wave upstream)
;;     2000/10/28 09:30:20.500   2000/10/28 09:30:55.500    RH08     441.1      51.6       0.7       2.5       2.1       1.5         NN
;;     2000/10/31 17:09:54.500   2000/10/31 17:10:02.500    RH08     475.3      71.1       0.2       2.6       1.8       1.6         YM
;;     2000/11/04 02:25:42.500   2000/11/04 02:25:50.500    RH08     450.1      66.4       0.3       2.3       2.3       1.9         NU
;;     2000/11/06 09:29:40.500   2000/11/06 09:30:15.500    RH08     626.0      70.4       0.3       2.3       2.0       1.7         YS
;;     2000/11/11 04:12:10.500   2000/11/11 04:12:50.500    RH08     975.6      56.7       0.3       2.1       1.8       1.5         NN
;;     2000/11/26 11:43:24.500   2000/11/26 11:43:32.500    RH08     509.7      64.9       0.7       2.5       2.5       1.8         YM
;;     2000/11/28 05:25:45.500   2000/11/28 05:26:10.500    RH08     603.8      58.3       0.3       2.1       1.6       1.4         NN
;;     2001/01/17 04:07:48.500   2001/01/17 04:07:56.500    RH08     379.2      69.7       0.4       1.5       1.7       1.3         YU
;;     2001/03/03 11:29:05.500   2001/03/03 11:29:20.500    RH08     553.6      45.5       0.5       2.2       2.4       1.9         YS
;;     2001/03/22 13:59:03.500   2001/03/22 13:59:11.500    RH08     382.0      73.5       0.2       2.3       1.4       1.3         YM
;;     2001/03/27 18:07:45.500   2001/03/27 18:07:53.500    RH08     552.1      57.2       0.4       2.0       2.1       1.8         YU
;;     2001/04/21 15:29:09.500   2001/04/21 15:29:17.500    RH08     395.4      81.0       0.5       1.7       2.5       1.8         YU
;;     2001/05/06 09:06:03.500   2001/05/06 09:06:11.500    RH08     365.6      45.8       0.4       1.5       1.6       1.3         YU
;;     2001/05/12 10:03:09.500   2001/05/12 10:03:17.500    RH08     574.7      68.2       0.1       1.4       1.2       1.1         YU
;;     2001/08/12 16:12:42.500   2001/08/12 16:12:50.500    RH08     340.2      72.4       0.2       1.7       2.2       1.9         NM
;;     2001/08/31 01:25:00.500   2001/08/31 01:25:08.500    RH08     475.3      82.5       0.3       1.4       1.5       1.2         NN
;;     2001/09/13 02:31:20.500   2001/09/13 02:31:35.500    RH08     454.5      72.1       0.3       1.5       1.3       1.1         NU
;;     2001/10/28 03:13:42.500   2001/10/28 03:13:50.500    RH08     591.8      60.3       0.0       2.9       2.3       2.3         YU
;;     2001/11/30 18:15:35.500   2001/11/30 18:15:55.500    RH08     417.9      59.7       0.4       1.4       2.0       1.6         YS
;;     2001/12/21 14:10:05.500   2001/12/21 14:10:25.500    RH08     565.8      65.1       0.1       1.5       2.2       2.0         YS
;;     2001/12/30 20:05:00.500   2001/12/30 20:05:15.500    RH08     669.0      63.0       0.6       2.3       2.5       1.8         YM
;;     2002/01/17 05:26:51.500   2002/01/17 05:26:59.500    RH09     404.3      51.2       0.2       1.4       1.3       1.1         YU
;;     2002/01/31 21:38:06.500   2002/01/31 21:38:14.500    RH08     363.9      67.9       0.1       2.1       2.4       2.1         YU
;;     2002/03/23 11:24:03.500   2002/03/23 11:24:11.500    RH08     520.1      68.0       0.5       2.6       2.8       2.1         YU
;;     2002/03/29 22:15:09.500   2002/03/29 22:15:17.500    RH08     398.7      82.9       0.7       2.7       2.9       2.0         MU
;;     2002/05/21 21:14:10.500   2002/05/21 21:14:20.500    RH09     257.3      49.5       0.5       2.2       1.9       1.5         YS
;;     2002/06/29 21:10:15.500   2002/06/29 21:10:29.500    RH08     385.4      61.1       0.3       1.4       1.4       1.2         YS
;;     2002/08/01 23:09:03.500   2002/08/01 23:09:11.500    RH08     497.4      70.1       0.1       2.0       1.5       1.4         YU
;;     2002/09/30 07:54:21.500   2002/09/30 07:54:29.500    RH08     326.5      78.8       0.2       2.1       1.4       1.2         YM
;;     2002/10/02 22:41:00.500   2002/10/02 22:41:08.500    RH08     527.2      78.4       0.4       2.1       2.0       1.6         MU
;;     2002/11/09 18:27:45.500   2002/11/09 18:27:53.500    RH08     425.0      70.0       0.1       2.0       1.8       1.7         MU
;;     2003/05/29 18:31:03.500   2003/05/29 18:31:11.500    RH08     907.8      73.0       0.1       2.0       2.0       1.9         YU
;;     2003/06/18 04:42:00.500   2003/06/18 04:42:08.500    RH08     618.7      86.8       0.2       1.5       1.8       1.5         YS
;;     2004/04/12 18:27:25.000   2004/04/12 18:28:10.000    RH08     558.6      60.2       0.5       1.9       2.7       2.0         MS
;;     2005/05/06 12:08:30.500   2005/05/06 12:08:45.500    RH08     416.8      48.6       0.4       1.6       2.4       1.9         YS
;;     2005/05/07 18:26:12.500   2005/05/07 18:26:20.500    RH08     437.9      61.6       0.2       1.5       1.1       1.0         MU
;;     2005/06/16 08:09:06.500   2005/06/16 08:09:14.500    RH08     620.6      66.0       0.0       2.0       1.3       1.3         YM
;;     2005/07/10 02:42:27.500   2005/07/10 02:42:35.500    RH08     540.5      80.7       0.1       1.7       2.3       2.1         YS
;;     2005/07/16 01:40:54.500   2005/07/16 01:41:02.500    RH08     421.8      84.0       0.6       1.7       2.0       1.5         NN
;;     2005/08/01 06:00:48.500   2005/08/01 06:00:56.500    RH08     479.6      84.2       0.2       1.8       1.8       1.6         NM
;;     2005/08/24 05:35:18.500   2005/08/24 05:35:26.500    RH08     579.1      86.9       0.3       2.5       2.0       1.6         YM
;;     2005/09/02 13:50:09.500   2005/09/02 13:50:20.500    RH08     587.0      53.0       0.5       2.2       2.6       2.0         YU
;;     2005/09/15 08:36:15.500   2005/09/15 08:36:45.500    RH08     683.7      54.8       0.4       2.8       2.5       2.1         NS
;;     2005/12/30 23:45:15.500   2005/12/30 23:45:30.500    RH08     619.0      71.7       0.5       1.5       1.6       1.2         NN
;;     2006/08/19 09:38:40.500   2006/08/19 09:38:55.500    RH08     373.3      46.9       0.4       1.5       1.2       1.0         YS
;;     2006/11/03 09:37:12.500   2006/11/03 09:37:20.500    RH08     397.5      87.8       0.4       1.5       2.0       1.6         NN
;;     2007/07/20 03:27:10.500   2007/07/20 03:27:23.500    RH08     357.2      66.3       0.6       1.7       2.0       1.4         NU
;;     2007/08/22 04:33:55.500   2007/08/22 04:34:10.500    RH08     356.9      62.0       0.6       1.5       2.1       1.5         NU  (nice transverse wave upstream)
;;     2007/12/17 01:53:12.500   2007/12/17 01:53:23.500    RH08     289.3      53.8       0.6       2.3       2.3       1.7         YS
;;     2008/05/28 01:17:33.500   2008/05/28 01:17:41.500    RH08     402.4      75.1       0.6       2.2       2.9       2.0         YU
;;     2008/06/24 19:10:36.500   2008/06/24 19:10:44.500    RH08     354.8      49.7       0.4       1.6       2.0       1.7         YU
;;     2009/02/03 19:20:57.500   2009/02/03 19:21:05.500    RH08     407.7      85.2       0.1       1.8       1.7       1.6         YU
;;     2009/06/24 09:52:15.500   2009/06/24 09:52:23.500    RH08     350.4      88.1       0.6       1.7       2.8       2.0         YU
;;     2009/06/27 11:04:12.500   2009/06/27 11:04:20.500    RH08     426.1      87.5       0.3       1.5       1.6       1.3         YU
;;     2009/10/21 23:15:06.500   2009/10/21 23:15:14.500    RH08     307.7      66.0       0.6       2.1       2.4       1.7         YU
;;     2010/04/11 12:20:51.500   2010/04/11 12:20:59.500    RH08     465.2      60.3       0.3       2.0       2.5       2.2         YS
;;     2011/02/04 01:50:45.500   2011/02/04 01:50:59.500    RH10     285.1      73.2       0.3       2.1       2.0       1.6         YS
;;     2011/07/11 08:27:21.500   2011/07/11 08:27:29.500    RH08     601.4      78.4       0.6       1.9       2.8       2.0         YU
;;     2011/09/16 18:56:50.500   2011/09/16 18:57:20.500    RH08     291.1      71.2       0.1       2.4       1.3       1.3         NN
;;     2011/09/25 10:46:27.500   2011/09/25 10:46:35.500    RH08      85.6      83.8       0.3       2.4       1.1       1.1         YU
;;     2012/01/21 04:01:57.500   2012/01/21 04:02:05.500    RH08     326.8      83.2       0.1       1.5       1.8       1.7         YU
;;     2012/01/30 15:43:09.500   2012/01/30 15:43:17.500    RH08     411.1      53.2       0.2       2.9       2.8       2.5         YU
;;     2012/03/07 03:28:33.500   2012/03/07 03:28:45.500    RH08     479.0      82.4       0.2       1.9       2.1       1.9         NU
;;     2012/04/19 17:13:27.500   2012/04/19 17:13:35.500    RH08     410.1      84.2       0.6       1.4       2.5       1.7         NU
;;     2012/06/16 19:34:33.500   2012/06/16 19:34:41.500    RH08     486.9      70.2       0.5       1.7       2.4       1.8         YU
;;     2012/10/08 04:12:09.500   2012/10/08 04:12:17.500    RH08     465.4      74.4       0.2       1.9       2.3       2.0         YU
;;     2012/11/12 22:12:36.500   2012/11/12 22:12:44.500    RH08     377.1      65.4       0.3       2.0       2.5       2.1         YU
;;     2012/11/26 04:32:45.500   2012/11/26 04:32:53.500    RH08     586.4      71.0       0.4       2.1       2.2       1.8         YS
;;     2012/12/14 19:06:09.500   2012/12/14 19:06:17.500    RH08     384.3      61.6       0.3       1.5       2.1       1.8         NN
;;     2013/01/17 00:23:39.500   2013/01/17 00:23:47.500    RH08     424.9      78.7       0.7       1.4       1.8       1.3         NU
;;     2013/02/13 00:47:40.500   2013/02/13 00:47:50.500    RH08     447.8      75.7       0.5       1.7       2.6       2.0         YU
;;     2013/04/30 08:52:42.500   2013/04/30 08:52:50.500    RH08     461.4      64.9       0.3       1.5       2.2       1.8         MU
;;     2013/06/10 02:51:57.500   2013/06/10 02:52:05.500    RH08     387.7      72.6       0.6       1.9       1.6       1.2         YU
;;     2013/07/12 16:43:21.500   2013/07/12 16:43:29.500    RH08     499.3      56.8       0.4       2.0       2.3       1.9         YS
;;     2013/09/02 01:56:40.500   2013/09/02 01:56:56.500    RH08     524.7      60.1       0.5       1.6       2.2       1.7         YS
;;     2013/10/26 21:25:57.500   2013/10/26 21:26:05.500    RH08     336.5      46.9       0.1       1.6       1.6       1.5         YS
;;     2014/02/13 08:55:24.500   2014/02/13 08:55:32.500    RH08     465.6      68.3       0.0       1.6       1.7       1.7         YU
;;     2014/02/15 12:46:30.500   2014/02/15 12:46:40.500    RH08     499.6      78.3       0.4       2.1       2.7       2.1         YU
;;     2014/02/19 03:09:33.500   2014/02/19 03:09:41.500    RH08     632.4      72.0       0.0       1.6       2.1       2.0         NU
;;     2014/04/19 17:48:15.500   2014/04/19 17:48:30.500    RH08     549.2      50.5       0.1       1.8       1.6       1.5         YU
;;     2014/05/07 21:19:30.500   2014/05/07 21:19:45.500    RH08     386.4      69.4       0.1       1.6       1.2       1.1         YS
;;     2014/05/29 08:26:24.500   2014/05/29 08:26:32.500    RH08     381.7      64.2       0.2       1.8       1.3       1.1         YS
;;     2014/07/14 13:38:06.500   2014/07/14 13:38:14.500    RH08     278.1      70.2       0.3       1.3       1.3       1.1         YU
;;     2015/05/06 00:55:45.500   2015/05/06 00:55:53.500    RH08     527.5      87.5       0.2       2.2       2.6       2.3         YU
;;     2015/06/05 08:30:30.500   2015/06/05 08:31:25.500    RH08     326.9      84.5       0.8       1.4       2.4       1.6         NU
;;     2015/06/24 13:07:05.500   2015/06/24 13:07:20.500    RH08     591.7      85.5       0.1       1.9       2.1       2.0         YS
;;     2015/08/15 07:43:36.500   2015/08/15 07:43:44.500    RH08     477.4      56.8       0.1       2.3       2.4       2.3         YM
;;     2016/03/11 04:29:05.500   2016/03/11 04:29:20.500    RH08     363.1      53.1       0.7       2.2       2.0       1.5         NN
;;     2016/03/14 16:16:27.500   2016/03/14 16:16:35.500    RH08     412.5      61.4       0.8       1.7       2.3       1.5         NU



























































;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;             Start                      End              Method     Vshn     Theta     beta_T     N2/N1      M_A       M_f
;;=============================================================================================================================
;;     1995-03-23/09:37:18.500   1995-03-23/09:37:26.500    RH09     230.2      88.9       0.4       2.0       2.0       1.5
;;     1995-04-17/23:33:00.500   1995-04-17/23:33:08.500    RH08     389.2      80.0       0.2       1.8       1.3       1.1
;;     1995-08-22/12:56:42.500   1995-08-22/12:56:50.500    RH08     381.0      66.1       0.7       2.6       2.6       1.8
;;     1995-10-22/21:20:12.500   1995-10-22/21:20:20.500      MC     428.7      73.4       0.5       1.8       1.5       1.1
;;     1995-12-24/05:57:30.500   1995-12-24/05:57:38.500    RH09     428.7      47.7       0.3       2.6       2.8       2.4
;;     1996-02-06/19:14:18.500   1996-02-06/19:14:26.500    RH08     383.4      48.4       0.4       1.7       1.7       1.4
;;     1997-01-05/03:20:42.500   1997-01-05/03:20:50.500    RH09     384.2      64.3       0.3       1.6       1.4       1.2
;;     1997-04-16/12:21:21.500   1997-04-16/12:21:29.500      MC     286.2      57.1       0.9       1.6       1.9       1.2
;;     1997-05-20/05:10:45.500   1997-05-20/05:10:53.500    RH08     349.6      46.0       0.5       2.5       1.9       1.5
;;     1997-08-05/04:59:00.500   1997-08-05/04:59:08.500    RH08     392.4      56.5       0.8       1.5       1.5       1.0
;;     1997-11-01/06:14:39.500   1997-11-01/06:14:47.500      MC     177.2      62.1       0.4       1.5       1.5       1.2
;;     1997-11-09/10:03:48.500   1997-11-09/10:03:56.500      MC     198.4      46.1       0.3       1.9       1.9       1.6
;;     1998-01-06/13:28:57.500   1998-01-06/13:29:05.500    RH08     408.4      82.3       0.3       2.8       2.4       2.0
;;     1998-05-01/21:21:21.500   1998-05-01/21:21:29.500      VC     596.6      64.3       0.4       2.8       2.6       2.1
;;     1998-05-03/17:02:15.500   1998-05-03/17:02:23.500    RH08     499.6      52.3       0.1       3.2       1.9       1.9
;;     1998-05-15/13:53:42.500   1998-05-15/13:53:50.500    RH09     134.2      55.8       0.6       2.1       2.9       2.1
;;     1998-06-13/19:18:06.500   1998-06-13/19:18:14.500      VC     308.4      52.9       0.1       3.5       2.1       2.0
;;     1998-08-19/18:40:36.500   1998-08-19/18:40:44.500    RH08     334.7      45.5       0.4       2.3       2.8       2.3
;;     1998-09-24/23:20:33.500   1998-09-24/23:20:41.500      MC     476.9      62.4       0.2       2.2       2.2       2.0
;;     1999-03-10/01:32:57.500   1999-03-10/01:33:05.500      MC     467.3      77.1       0.9       1.8       2.5       1.6
;;     1999-04-16/11:13:57.500   1999-04-16/11:14:05.500    RH08     487.7      68.9       0.1       2.1       1.5       1.4
;;     1999-06-26/02:31:39.500   1999-06-26/02:31:47.500    RH09     329.8      86.6       0.9       1.9       2.5       1.5
;;     1999-06-26/19:30:54.500   1999-06-26/19:31:02.500    RH08     467.2      59.4       0.3       2.2       2.2       1.8
;;     1999-09-15/07:43:42.500   1999-09-15/07:43:50.500    RH08     665.5      73.6       0.7       2.0       2.0       1.4
;;     1999-09-15/20:08:36.500   1999-09-15/20:08:44.500    RH10     619.3      57.3       1.0       2.0       2.8       1.8
;;     1999-09-22/12:09:21.500   1999-09-22/12:09:29.500     MX3     412.8      88.6       0.4       2.6       2.3       1.7
;;     1999-10-21/02:20:48.500   1999-10-21/02:20:56.500      MC     405.7      53.8       0.2       2.3       1.9       1.8
;;     1999-12-12/15:54:24.500   1999-12-12/15:54:32.500    RH08     564.0      48.7       0.0       3.4       1.5       1.5
;;     2000-02-11/23:34:09.500   2000-02-11/23:34:17.500      MC     364.1      65.6       0.3       3.3       2.0       1.6
;;     2000-02-14/07:12:57.500   2000-02-14/07:13:05.500    RH08     700.7      56.3       0.4       1.8       1.8       1.5
;;     2000-05-23/23:42:15.500   2000-05-23/23:42:23.500      VC     631.2      56.5       0.6       2.1       1.4       1.0
;;     2000-06-23/12:57:54.500   2000-06-23/12:58:02.500    RH08     527.6      56.1       0.5       2.6       2.8       2.2
;;     2000-07-13/09:43:45.500   2000-07-13/09:43:53.500    RH08     641.4      51.9       0.7       2.4       2.1       1.5
;;     2000-07-19/15:30:18.500   2000-07-19/15:30:26.500    RH08     643.3      55.8       0.2       3.2       2.9       2.5
;;     2000-07-26/19:00:09.500   2000-07-26/19:00:17.500    RH08     425.0      86.0       0.6       1.8       2.0       1.4
;;     2000-07-28/06:38:42.500   2000-07-28/06:38:50.500      MC     398.6      45.2       0.0       2.8       1.6       1.6
;;     2000-08-10/05:13:18.500   2000-08-10/05:13:26.500    RH08     379.9      67.0       0.2       1.7       1.3       1.1
;;     2000-08-11/18:49:30.500   2000-08-11/18:49:38.500      MC     482.8      59.3       0.0       2.7       1.2       1.2
;;     2000-10-03/01:02:21.500   2000-10-03/01:02:29.500    RH08     457.2      51.5       0.6       1.9       2.2       1.7
;;     2000-10-28/06:38:45.500   2000-10-28/06:38:53.500      MC     316.8      46.2       0.3       2.1       1.7       1.5
;;     2000-10-28/09:30:39.500   2000-10-28/09:30:47.500    RH08     441.1      51.6       0.7       2.5       2.1       1.5
;;     2000-10-31/17:09:54.500   2000-10-31/17:10:02.500    RH08     475.3      71.1       0.2       2.6       1.8       1.6
;;     2000-11-04/02:25:42.500   2000-11-04/02:25:50.500    RH09     452.5      54.1       0.3       2.3       2.1       1.8
;;     2000-11-06/09:30:00.500   2000-11-06/09:30:08.500    RH08     626.0      70.4       0.3       2.3       2.0       1.7
;;     2000-11-10/06:19:27.500   2000-11-10/06:19:35.500    RH09     488.7      73.1       0.6       2.1       1.5       1.1
;;     2000-11-11/04:12:30.500   2000-11-11/04:12:38.500    RH08     975.6      56.7       0.3       2.1       1.8       1.5
;;     2000-11-28/05:25:54.500   2000-11-28/05:26:02.500    RH08     603.8      58.3       0.3       2.1       1.6       1.4
;;     2001-01-10/16:09:06.500   2001-01-10/16:09:14.500      VC     387.7      51.8       0.3       1.9       1.6       1.4
;;     2001-03-03/11:29:12.500   2001-03-03/11:29:20.500    RH08     553.6      45.5       0.5       2.2       2.4       1.9
;;     2001-03-22/13:59:03.500   2001-03-22/13:59:11.500      VC     374.1      88.8       0.2       2.3       1.5       1.4
;;     2001-04-07/17:56:54.500   2001-04-07/17:57:02.500    RH08     553.9      89.6       0.4       3.2       2.7       2.1
;;     2001-04-21/15:29:09.500   2001-04-21/15:29:17.500    RH10     172.6      74.3       0.5       1.7       1.7       1.3
;;     2001-12-29/05:16:57.500   2001-12-29/05:17:05.500    RH08     528.8      49.9       0.1       3.6       2.5       2.4
;;     2001-12-30/20:05:03.500   2001-12-30/20:05:11.500    RH08     669.0      63.0       0.6       2.3       2.5       1.8
;;     2002-03-29/22:15:09.500   2002-03-29/22:15:17.500    RH08     398.7      82.9       0.7       2.7       2.9       2.0
;;     2002-05-21/21:14:12.500   2002-05-21/21:14:20.500    RH08     246.0      51.4       0.5       2.2       1.9       1.5
;;     2002-09-30/07:54:21.500   2002-09-30/07:54:29.500    RH08     326.5      78.8       0.2       2.1       1.4       1.2
;;     2002-10-02/22:41:00.500   2002-10-02/22:41:08.500    RH08     527.2      78.4       0.4       2.1       2.0       1.6
;;     2004-11-09/09:25:28.500   2004-11-09/09:25:36.500    RH08     784.8      47.7       0.1       6.7       1.9       1.9
;;     2005-01-16/09:27:18.500   2005-01-16/09:27:26.500      VC     448.1      59.1       0.3       2.2       1.4       1.1
;;     2005-07-16/01:40:54.500   2005-07-16/01:41:02.500    RH09     451.5      71.5       0.6       1.7       1.9       1.4
;;     2005-07-16/16:10:00.500   2005-07-16/16:10:08.500    RH09     470.1      79.1       0.8       1.6       1.7       1.1
;;     2005-08-24/05:35:18.500   2005-08-24/05:35:26.500    RH08     579.1      86.9       0.3       2.5       2.0       1.6
;;     2005-09-02/13:50:09.500   2005-09-02/13:50:17.500    RH09     586.9      52.1       0.5       2.2       2.6       2.0
;;     2005-09-15/08:36:27.500   2005-09-15/08:36:35.500    RH08     683.7      54.8       0.4       2.8       2.5       2.1
;;     2005-12-30/23:45:15.500   2005-12-30/23:45:23.500    RH08     619.0      71.7       0.5       1.5       1.6       1.2
;;     2006-07-09/20:40:06.500   2006-07-09/20:40:14.500    RH09     186.5      74.4       0.2       2.3       2.3       1.9
;;     2006-08-19/09:38:45.500   2006-08-19/09:38:53.500    RH08     373.3      46.9       0.4       1.5       1.2       1.0
;;     2007-05-07/07:02:39.500   2007-05-07/07:02:47.500    RH09     194.8      62.2       0.9       2.0       2.2       1.4
;;     2008-05-28/01:17:33.500   2008-05-28/01:17:41.500     MX1     343.3      82.1       0.6       2.2       2.8       2.0
;;     2008-11-24/22:29:03.500   2008-11-24/22:29:11.500    RH09     122.3      83.2       0.6       2.4       2.3       1.6
;;     2009-03-03/05:04:39.500   2009-03-03/05:04:47.500    RH09      68.7      72.8       0.6       1.8       1.9       1.4
;;     2009-05-28/04:04:54.500   2009-05-28/04:05:02.500    RH09     136.9      72.3       0.4       2.9       2.8       2.2
;;     2009-06-24/09:52:15.500   2009-06-24/09:52:23.500    RH09     256.2      83.3       0.6       1.7       1.8       1.3
;;     2009-09-03/14:58:15.500   2009-09-03/14:58:23.500    RH09     173.8      56.1       0.9       2.2       2.1       1.4
;;     2009-10-10/22:50:18.500   2009-10-10/22:50:26.500    RH09     152.2      84.0       0.8       1.8       1.7       1.1
;;     2009-10-21/23:15:06.500   2009-10-21/23:15:14.500    RH09     324.5      51.1       0.6       2.1       2.2       1.6
;;     2010-08-03/17:04:57.500   2010-08-03/17:05:05.500    RH09     164.5      63.6       0.2       2.3       2.3       2.1
;;     2011-02-04/01:50:51.500   2011-02-04/01:50:59.500    RH09     258.8      74.2       0.3       2.1       1.8       1.5
;;     2011-02-14/15:06:45.500   2011-02-14/15:06:53.500    RH09      90.2      79.6       0.9       2.6       3.0       1.9
;;     2011-02-18/00:49:00.500   2011-02-18/00:49:08.500    RH08     150.2      87.6       0.3       4.2       1.2       1.0
;;     2011-07-11/08:27:21.500   2011-07-11/08:27:29.500    RH09     601.8      65.4       0.6       1.9       2.5       1.8
;;     2011-08-05/17:32:12.500   2011-08-05/17:32:20.500      MC     476.8      89.5       0.4       2.3       1.5       1.2
;;     2011-08-05/18:40:39.500   2011-08-05/18:40:47.500    RH10     160.7      60.9       0.6       1.5       1.6       1.2
;;     2011-11-28/21:00:03.500   2011-11-28/21:00:11.500      MC     504.5      60.5       0.3       2.1       2.0       1.7
;;     2012-01-24/14:40:00.500   2012-01-24/14:40:08.500    RH08     166.8      81.3       0.0       4.1       1.3       1.4
;;     2012-01-30/15:43:09.500   2012-01-30/15:43:17.500      MC     386.8      47.9       0.2       2.9       1.9       1.7
;;     2012-08-10/04:11:03.500   2012-08-10/04:11:11.500    RH09     163.0      89.9       0.3       1.6       1.4       1.1
;;     2012-09-30/22:18:33.500   2012-09-30/22:18:41.500    RH09     387.0      82.9       0.6       2.1       2.7       1.9
;;     2012-10-31/14:28:18.500   2012-10-31/14:28:26.500    RH09     279.5      71.0       0.9       2.3       2.9       1.9
;;     2012-11-23/20:51:18.500   2012-11-23/20:51:26.500    RH09     206.7      76.4       0.2       2.1       2.2       1.9
;;     2013-02-16/11:23:03.500   2013-02-16/11:23:11.500    RH09     315.5      76.4       0.1       1.9       1.4       1.2
;;     2013-06-10/02:51:57.500   2013-06-10/02:52:05.500    RH08     387.7      72.6       0.6       1.9       1.6       1.2
;;     2013-06-27/13:51:15.500   2013-06-27/13:51:23.500    RH09     263.6      60.7       0.5       2.4       2.3       1.8
;;     2013-07-12/16:43:21.500   2013-07-12/16:43:29.500    RH08     499.3      56.8       0.4       2.0       2.3       1.9
;;     2013-12-13/12:32:00.500   2013-12-13/12:32:08.500    RH09     164.8      63.0       0.9       2.4       2.6       1.6
;;     2014-01-07/14:34:48.500   2014-01-07/14:34:56.500    RH10      58.3      64.1       0.9       2.0       1.5       1.0
;;     2014-02-27/15:50:09.500   2014-02-27/15:50:17.500    RH09     169.4      71.4       0.6       2.5       2.5       1.8
;;     2014-04-20/10:20:30.500   2014-04-20/10:20:38.500    RH08     605.6      80.1       0.1       3.3       1.7       1.6










;;  1st Letter
;;  Y   =  Yes
;;  N   =  No
;;  M   =  Maybe or Unclear

;;  2nd Letter
;;  S   =  resolved or sampled well enough
;;  U   =  fluctuation present but undersampled (e.g., looks like triangle wave)
;;  G   =  data gap or missing data (but still well resolved)
;;  M   =  data gap or missing data (and undersampled)
;;  N   =  nothing


;;             Start                      End              Method     Vshn      Theta    beta_T      N2/N1      M_A       M_f      Whistler
;;===========================================================================================================================================
;;     1995/03/23 09:37:18.500   1995/03/23 09:37:26.500    RH09     230.2      88.9       0.4        2.0       2.0       1.5         YS
;;     1995/04/17 23:33:00.500   1995/04/17 23:33:10.500    RH08     389.2      80.0       0.2        1.8       1.3       1.1         YU
;;     1995/08/22 12:56:42.500   1995/08/22 12:56:50.500    RH08     381.0      66.1       0.7        2.6       2.6       1.8         YS
;;     1995/10/22 21:20:12.500   1995/10/22 21:20:20.500      MC     428.7      73.4       0.5        1.8       1.5       1.1         YU
;;     1995/12/24 05:57:30.500   1995/12/24 05:57:38.500    RH09     428.7      47.7       0.3        2.6       2.8       2.4         YU
;;     1996/02/06 19:14:18.500   1996/02/06 19:14:26.500    RH08     383.4      48.4       0.4        1.7       1.7       1.4         YU
;;     1997/01/05 03:20:42.500   1997/01/05 03:20:50.500    RH09     384.2      64.3       0.3        1.6       1.4       1.2         NN
;;     1997/04/16 12:21:21.500   1997/04/16 12:21:29.500      MC     286.2      57.1       0.9        1.6       1.9       1.2         NU
;;     1997/05/20 05:10:43.500   1997/05/20 05:10:53.500    RH08     349.6      46.0       0.5        2.5       1.9       1.5         NN
;;     1997/08/05 04:59:00.500   1997/08/05 04:59:08.500    RH08     392.4      56.5       0.8        1.5       1.5       1.0         NU
;;     1997/11/01 06:14:39.500   1997/11/01 06:14:47.500      MC     177.2      62.1       0.4        1.5       1.5       1.2         YS
;;     1997/11/09 10:03:48.500   1997/11/09 10:03:56.500      MC     198.4      46.1       0.3        1.9       1.9       1.6         YU
;;     1998/01/06 13:28:57.500   1998/01/06 13:29:05.500    RH08     408.4      82.3       0.3        2.8       2.4       2.0         YU
;;     1998/05/01 21:21:21.500   1998/05/01 21:21:29.500      VC     596.6      64.3       0.4        2.8       2.6       2.1         YU
;;     1998/05/03 17:02:15.500   1998/05/03 17:02:23.500    RH08     499.6      52.3       0.1        3.2       1.9       1.9         YS
;;     1998/05/15 13:53:42.500   1998/05/15 13:53:50.500    RH09     134.2      55.8       0.6        2.1       2.9       2.1         NN
;;     1998/06/13 19:18:06.500   1998/06/13 19:18:14.500      VC     308.4      52.9       0.1        3.5       2.1       2.0         YU
;;     1998/08/19 18:40:36.500   1998/08/19 18:40:44.500    RH08     334.7      45.5       0.4        2.3       2.8       2.3         YU
;;     1999/03/10 01:32:57.500   1999/03/10 01:33:05.500      MC     467.3      77.1       0.9        1.8       2.5       1.6         NN
;;     1999/04/16 11:13:45.500   1999/04/16 11:14:25.500    RH08     487.7      68.9       0.1        2.1       1.5       1.4         YS
;;     1999/06/26 02:31:30.500   1999/06/26 02:31:45.500    RH09     329.8      86.6       0.9        1.9       2.5       1.5         YU
;;     1999/06/26 19:30:54.500   1999/06/26 19:31:02.500    RH08     467.2      59.4       0.3        2.2       2.2       1.8         YM
;;     1999/09/15 07:43:42.500   1999/09/15 07:43:50.500    RH08     665.5      73.6       0.7        2.0       2.0       1.4         NN
;;     1999/09/15 20:08:36.500   1999/09/15 20:08:44.500    RH10     619.3      57.3       1.0        2.0       2.8       1.8         MS
;;     1999/09/22 12:09:21.500   1999/09/22 12:09:29.500     MX3     412.8      88.6       0.4        2.6       2.3       1.7         NU
;;     1999/10/21 02:20:48.500   1999/10/21 02:20:56.500      MC     405.7      53.8       0.2        2.3       1.9       1.8         YM
;;     1999/12/12 15:54:10.500   1999/12/12 15:54:40.500    RH08     564.0      48.7       0.0        3.4       1.5       1.5         MS
;;     2000/02/14 07:12:57.500   2000/02/14 07:13:05.500    RH08     700.7      56.3       0.4        1.8       1.8       1.5
;;     2000/05/23 23:42:15.500   2000/05/23 23:42:23.500      VC     631.2      56.5       0.6        2.1       1.4       1.0
;;     2000/06/23 12:57:54.500   2000/06/23 12:58:02.500    RH08     527.6      56.1       0.5        2.6       2.8       2.2
;;     2000/07/13 09:43:45.500   2000/07/13 09:43:53.500    RH08     641.4      51.9       0.7        2.4       2.1       1.5
;;     2000/07/19 15:30:18.500   2000/07/19 15:30:26.500    RH08     643.3      55.8       0.2        3.2       2.9       2.5
;;     2000/07/26 19:00:09.500   2000/07/26 19:00:17.500    RH08     425.0      86.0       0.6        1.8       2.0       1.4
;;     2000/07/28 06:38:42.500   2000/07/28 06:38:50.500      MC     398.6      45.2       0.0        2.8       1.6       1.6
;;     2000/08/10 05:13:18.500   2000/08/10 05:13:26.500    RH08     379.9      67.0       0.2        1.7       1.3       1.1
;;     2000/08/11 18:49:30.500   2000/08/11 18:49:38.500      MC     482.8      59.3       0.0        2.7       1.2       1.2
;;     2000/10/03 01:02:21.500   2000/10/03 01:02:29.500    RH08     457.2      51.5       0.6        1.9       2.2       1.7
;;     2000/10/28 06:38:45.500   2000/10/28 06:38:53.500      MC     316.8      46.2       0.3        2.1       1.7       1.5
;;     2000/10/28 09:30:39.500   2000/10/28 09:30:47.500    RH08     441.1      51.6       0.7        2.5       2.1       1.5
;;     2000/10/31 17:09:54.500   2000/10/31 17:10:02.500    RH08     475.3      71.1       0.2        2.6       1.8       1.6
;;     2000/11/04 02:25:42.500   2000/11/04 02:25:50.500    RH09     452.5      54.1       0.3        2.3       2.1       1.8
;;     2000/11/06 09:30:00.500   2000/11/06 09:30:08.500    RH08     626.0      70.4       0.3        2.3       2.0       1.7
;;     2000/11/10 06:19:27.500   2000/11/10 06:19:35.500    RH09     488.7      73.1       0.6        2.1       1.5       1.1
;;     2000/11/11 04:12:30.500   2000/11/11 04:12:38.500    RH08     975.6      56.7       0.3        2.1       1.8       1.5
;;     2000/11/28 05:25:54.500   2000/11/28 05:26:02.500    RH08     603.8      58.3       0.3        2.1       1.6       1.4
;;     2001/01/10 16:09:06.500   2001/01/10 16:09:14.500      VC     387.7      51.8       0.3        1.9       1.6       1.4
;;     2001/03/03 11:29:12.500   2001/03/03 11:29:20.500    RH08     553.6      45.5       0.5        2.2       2.4       1.9
;;     2001/03/22 13:59:03.500   2001/03/22 13:59:11.500      VC     374.1      88.8       0.2        2.3       1.5       1.4
;;     2001/04/07 17:56:54.500   2001/04/07 17:57:02.500    RH08     553.9      89.6       0.4        3.2       2.7       2.1
;;     2001/04/21 15:29:09.500   2001/04/21 15:29:17.500    RH10     172.6      74.3       0.5        1.7       1.7       1.3
;;     2001/12/29 05:16:57.500   2001/12/29 05:17:05.500    RH08     528.8      49.9       0.1        3.6       2.5       2.4
;;     2001/12/30 20:05:03.500   2001/12/30 20:05:11.500    RH08     669.0      63.0       0.6        2.3       2.5       1.8
;;     2002/03/29 22:15:09.500   2002/03/29 22:15:17.500    RH08     398.7      82.9       0.7        2.7       2.9       2.0
;;     2002/05/21 21:14:12.500   2002/05/21 21:14:20.500    RH08     246.0      51.4       0.5        2.2       1.9       1.5
;;     2002/09/30 07:54:21.500   2002/09/30 07:54:29.500    RH08     326.5      78.8       0.2        2.1       1.4       1.2
;;     2002/10/02 22:41:00.500   2002/10/02 22:41:08.500    RH08     527.2      78.4       0.4        2.1       2.0       1.6
;;     2004/11/09 09:25:28.500   2004/11/09 09:25:36.500    RH08     784.8      47.7       0.1        6.7       1.9       1.9
;;     2005/01/16 09:27:18.500   2005/01/16 09:27:26.500      VC     448.1      59.1       0.3        2.2       1.4       1.1
;;     2005/07/16 01:40:54.500   2005/07/16 01:41:02.500    RH09     451.5      71.5       0.6        1.7       1.9       1.4
;;     2005/07/16 16:10:00.500   2005/07/16 16:10:08.500    RH09     470.1      79.1       0.8        1.6       1.7       1.1
;;     2005/08/24 05:35:18.500   2005/08/24 05:35:26.500    RH08     579.1      86.9       0.3        2.5       2.0       1.6
;;     2005/09/02 13:50:09.500   2005/09/02 13:50:17.500    RH09     586.9      52.1       0.5        2.2       2.6       2.0
;;     2005/09/15 08:36:27.500   2005/09/15 08:36:35.500    RH08     683.7      54.8       0.4        2.8       2.5       2.1
;;     2005/12/30 23:45:15.500   2005/12/30 23:45:23.500    RH08     619.0      71.7       0.5        1.5       1.6       1.2
;;     2006/07/09 20:40:06.500   2006/07/09 20:40:14.500    RH09     186.5      74.4       0.2        2.3       2.3       1.9
;;     2006/08/19 09:38:45.500   2006/08/19 09:38:53.500    RH08     373.3      46.9       0.4        1.5       1.2       1.0
;;     2007/05/07 07:02:39.500   2007/05/07 07:02:47.500    RH09     194.8      62.2       0.9        2.0       2.2       1.4
;;     2008/05/28 01:17:33.500   2008/05/28 01:17:41.500     MX1     343.3      82.1       0.6        2.2       2.8       2.0
;;     2008/11/24 22:29:03.500   2008/11/24 22:29:11.500    RH09     122.3      83.2       0.6        2.4       2.3       1.6
;;     2009/03/03 05:04:39.500   2009/03/03 05:04:47.500    RH09      68.7      72.8       0.6        1.8       1.9       1.4
;;     2009/05/28 04:04:54.500   2009/05/28 04:05:02.500    RH09     136.9      72.3       0.4        2.9       2.8       2.2
;;     2009/06/24 09:52:15.500   2009/06/24 09:52:23.500    RH09     256.2      83.3       0.6        1.7       1.8       1.3
;;     2009/09/03 14:58:15.500   2009/09/03 14:58:23.500    RH09     173.8      56.1       0.9        2.2       2.1       1.4
;;     2009/10/10 22:50:18.500   2009/10/10 22:50:26.500    RH09     152.2      84.0       0.8        1.8       1.7       1.1
;;     2009/10/21 23:15:06.500   2009/10/21 23:15:14.500    RH09     324.5      51.1       0.6        2.1       2.2       1.6
;;     2010/08/03 17:04:57.500   2010/08/03 17:05:05.500    RH09     164.5      63.6       0.2        2.3       2.3       2.1
;;     2011/02/04 01:50:51.500   2011/02/04 01:50:59.500    RH09     258.8      74.2       0.3        2.1       1.8       1.5
;;     2011/02/14 15:06:45.500   2011/02/14 15:06:53.500    RH09      90.2      79.6       0.9        2.6       3.0       1.9
;;     2011/02/18 00:49:00.500   2011/02/18 00:49:08.500    RH08     150.2      87.6       0.3        4.2       1.2       1.0
;;     2011/07/11 08:27:21.500   2011/07/11 08:27:29.500    RH09     601.8      65.4       0.6        1.9       2.5       1.8
;;     2011/08/05 17:32:12.500   2011/08/05 17:32:20.500      MC     476.8      89.5       0.4        2.3       1.5       1.2
;;     2011/08/05 18:40:39.500   2011/08/05 18:40:47.500    RH10     160.7      60.9       0.6        1.5       1.6       1.2
;;     2011/11/28 21:00:03.500   2011/11/28 21:00:11.500      MC     504.5      60.5       0.3        2.1       2.0       1.7
;;     2012/01/24 14:40:00.500   2012/01/24 14:40:08.500    RH08     166.8      81.3       0.0        4.1       1.3       1.4
;;     2012/01/30 15:43:09.500   2012/01/30 15:43:17.500      MC     386.8      47.9       0.2        2.9       1.9       1.7
;;     2012/08/10 04:11:03.500   2012/08/10 04:11:11.500    RH09     163.0      89.9       0.3        1.6       1.4       1.1
;;     2012/09/30 22:18:33.500   2012/09/30 22:18:41.500    RH09     387.0      82.9       0.6        2.1       2.7       1.9
;;     2012/10/31 14:28:18.500   2012/10/31 14:28:26.500    RH09     279.5      71.0       0.9        2.3       2.9       1.9
;;     2012/11/23 20:51:18.500   2012/11/23 20:51:26.500    RH09     206.7      76.4       0.2        2.1       2.2       1.9
;;     2013/02/16 11:23:03.500   2013/02/16 11:23:11.500    RH09     315.5      76.4       0.1        1.9       1.4       1.2
;;     2013/06/10 02:51:57.500   2013/06/10 02:52:05.500    RH08     387.7      72.6       0.6        1.9       1.6       1.2
;;     2013/06/27 13:51:15.500   2013/06/27 13:51:23.500    RH09     263.6      60.7       0.5        2.4       2.3       1.8
;;     2013/07/12 16:43:21.500   2013/07/12 16:43:29.500    RH08     499.3      56.8       0.4        2.0       2.3       1.9
;;     2013/12/13 12:32:00.500   2013/12/13 12:32:08.500    RH09     164.8      63.0       0.9        2.4       2.6       1.6
;;     2014/01/07 14:34:48.500   2014/01/07 14:34:56.500    RH10      58.3      64.1       0.9        2.0       1.5       1.0
;;     2014/02/27 15:50:09.500   2014/02/27 15:50:17.500    RH09     169.4      71.4       0.6        2.5       2.5       1.8
;;     2014/04/20 10:20:30.500   2014/04/20 10:20:38.500    RH08     605.6      80.1       0.1        3.3       1.7       1.6






PRINT,TRANSPOSE(tdates_bst[good_A])
PRINT,TRANSPOSE(ymdb_all[good_A])
1995-03-23/09:37:22.500
1995-04-17/23:33:04.500
1995-08-22/12:56:46.500
1995-10-22/21:20:16.500
1995-12-24/05:57:34.500
1996-02-06/19:14:22.500
1997-01-05/03:20:46.500
1997-04-16/12:21:25.500
1997-05-20/05:10:49.500
1997-08-05/04:59:04.500
1997-11-01/06:14:43.500
1997-11-09/10:03:52.500
1998-01-06/13:29:01.500
1998-05-01/21:21:25.500
1998-05-03/17:02:19.500
1998-05-15/13:53:46.500
1998-06-13/19:18:10.500
1998-08-19/18:40:40.500
1998-09-24/23:20:37.500
1999-03-10/01:33:01.500
1999-04-16/11:14:01.500
1999-06-26/02:31:43.500
1999-06-26/19:30:58.500
1999-09-15/07:43:46.500
1999-09-15/20:08:40.500
1999-09-22/12:09:25.500
1999-10-21/02:20:52.500
1999-12-12/15:54:28.500
2000-02-11/23:34:13.500
2000-02-14/07:13:01.500
2000-05-23/23:42:19.500
2000-06-23/12:57:58.500
2000-07-13/09:43:49.500
2000-07-19/15:30:22.500
2000-07-26/19:00:13.500
2000-07-28/06:38:46.500
2000-08-10/05:13:22.500
2000-08-11/18:49:34.500
2000-10-03/01:02:25.500
2000-10-28/06:38:49.500
2000-10-28/09:30:43.500
2000-10-31/17:09:58.500
2000-11-04/02:25:46.500
2000-11-06/09:30:04.500
2000-11-10/06:19:31.500
2000-11-11/04:12:34.500
2000-11-28/05:25:58.500
2001-01-10/16:09:10.500
2001-03-03/11:29:16.500
2001-03-22/13:59:07.500
2001-04-07/17:56:58.500
2001-04-21/15:29:13.500
2001-12-29/05:17:01.500
2001-12-30/20:05:07.500
2002-03-29/22:15:13.500
2002-05-21/21:14:16.500
2002-09-30/07:54:25.500
2002-10-02/22:41:04.500
2004-11-09/09:25:32.500
2005-01-16/09:27:22.500
2005-07-16/01:40:58.500
2005-07-16/16:10:04.500
2005-08-24/05:35:22.500
2005-09-02/13:50:13.500
2005-09-15/08:36:31.500
2005-12-30/23:45:19.500
2006-07-09/20:40:10.500
2006-08-19/09:38:49.500
2007-05-07/07:02:43.500
2008-05-28/01:17:37.500
2008-11-24/22:29:07.500
2009-03-03/05:04:43.500
2009-05-28/04:04:58.500
2009-06-24/09:52:19.500
2009-09-03/14:58:19.500
2009-10-10/22:50:22.500
2009-10-21/23:15:10.500
2010-08-03/17:05:01.500
2011-02-04/01:50:55.500
2011-02-14/15:06:49.500
2011-02-18/00:49:04.500
2011-07-11/08:27:25.500
2011-08-05/17:32:16.500
2011-08-05/18:40:43.500
2011-11-28/21:00:07.500
2012-01-24/14:40:04.500
2012-01-30/15:43:13.500
2012-08-10/04:11:07.500
2012-09-30/22:18:37.500
2012-10-31/14:28:22.500
2012-11-23/20:51:22.500
2013-02-16/11:23:07.500
2013-06-10/02:52:01.500
2013-06-27/13:51:19.500
2013-07-12/16:43:25.500
2013-12-13/12:32:04.500
2014-01-07/14:34:52.500
2014-02-27/15:50:13.500
2014-04-20/10:20:34.500



