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
R_E            = 6.37814d3            ;;  Earth's Equatorial Radius [km]
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
all_scs        = ['a','b','c','d','e']
coord_ssl      = 'ssl'
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
;;----------------------------------------------------------------------------------------
;;  Potential Interesting VDFs:  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  Probe A

;;  Probe B

probe          = 'b'
tdate          = '2008-07-14'
date           = '071408'

probe          = 'b'
tdate          = '2008-07-22'
date           = '072208'

probe          = 'b'
tdate          = '2008-07-26'
date           = '072608'

probe          = 'b'
tdate          = '2008-07-30'
date           = '073008'

probe          = 'b'
tdate          = '2008-08-07'
date           = '080708'

probe          = 'b'
tdate          = '2008-08-11'
date           = '081108'

probe          = 'b'
tdate          = '2008-08-23'
date           = '082308'

probe          = 'b'
tdate          = '2009-07-13'
date           = '071309'

;;  Probe C

probe          = 'c'
tdate          = '2008-07-14'
date           = '071408'

probe          = 'c'
tdate          = '2008-08-12'
date           = '081208'

probe          = 'c'
tdate          = '2008-08-19'
date           = '081908'

probe          = 'c'
tdate          = '2008-09-08'
date           = '090808'

probe          = 'c'
tdate          = '2008-09-16'
date           = '091608'

probe          = 'c'
tdate          = '2008-10-03'
date           = '100308'

probe          = 'c'
tdate          = '2008-10-09'
date           = '100908'

probe          = 'c'
tdate          = '2008-10-12'
date           = '101208'

probe          = 'c'
tdate          = '2008-10-29'
date           = '102908'

probe          = 'c'
tdate          = '2009-07-25'
date           = '072509'

;;  Probe D

;;  Probe E

;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
;@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_foreshock_eVDFs_batch.pro
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_themis_foreshock_eVDFs_batch.pro
n_e            = N_ELEMENTS(dat_egse)

tplot_options,   'THICK',1.5
tplot_options,'CHARSIZE',1.25
;;----------------------------------------------------------------------------------------
;;  Find relevant time ranges for example plots
;;----------------------------------------------------------------------------------------
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN start_t = time_double(tdate[0]+'/'+'21:53:00.000')
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN end___t = time_double(tdate[0]+'/'+'22:14:00.000')
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN esa___t = time_double(tdate[0]+'/'+['21:57:00','21:58:10']+'.000')
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN all_e_t = time_double(tdate[0]+'/'+['21:56:51','21:56:54','21:57:06','21:57:09','21:57:18']+'.000')

IF (tdate[0] EQ '2008-09-16' AND sc[0] EQ 'c') THEN start_t = time_double(tdate[0]+'/'+'17:24:00.000')
IF (tdate[0] EQ '2008-09-16' AND sc[0] EQ 'c') THEN end___t = time_double(tdate[0]+'/'+'17:50:00.000')
IF (tdate[0] EQ '2008-09-16' AND sc[0] EQ 'c') THEN esa___t = time_double(tdate[0]+'/'+['17:25:35','17:27:06','17:46:10']+'.000')
IF (tdate[0] EQ '2008-09-16' AND sc[0] EQ 'c') THEN all_e_t = time_double(tdate[0]+'/'+['17:24:55','17:25:35','17:25:56','17:43:10','17:43:19','17:43:31','17:44:10','17:44:28','17:45:17','17:45:35','17:46:14','17:46:17','17:46:23','17:46:59','17:47:20','17:47:48','17:47:57']+'.000')
;;  Define time range
tra_good       = [start_t[0],end___t[0]]


bgse_tpn       = tnames(scpref[0]+'fgh_'+coord_gse[0])
fgh_maggse_tpn = scpref[0]+'fgh_'+['mag',coord_gse[0]]
vbulk_gse_tpn  = tnames(scpref[0]+'peib_velocity_'+coord_gse[0])
edens_peeb_tpn = tnames(scpref[0]+'peeb_density')
idens_peib_tpn = tnames(scpref[0]+'peib_density')
etemp_peeb_tpn = tnames(scpref[0]+'peeb_avgtemp')
itemp_peib_tpn = tnames(scpref[0]+'peib_avgtemp')
;;  Change options for density and temperature
den_temp       = [idens_peib_tpn[0],edens_peeb_tpn[0],etemp_peeb_tpn[0],itemp_peib_tpn[0]]
options,den_temp,      'YLOG',/DEF
options,den_temp,  'YTICKLEN',/DEF
options,den_temp,    'YRANGE',/DEF
options,den_temp,'YGRIDSTYLE',/DEF
options,den_temp,      'YLOG',1
options,den_temp,  'YTICKLEN',1.0
options,den_temp,'YGRIDSTYLE',2
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN options,idens_peib_tpn[0],    'YRANGE',[1d-1,17d0]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN options,edens_peeb_tpn[0],    'YRANGE',[1d-1,13d0]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN options,etemp_peeb_tpn[0],    'YRANGE',[5d0,21d1]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN options,itemp_peib_tpn[0],    'YRANGE',[5d1,2d3]
;IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN options,idens_peib_tpn[0],    'YRANGE',[0d0,17d0]
;IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN options,edens_peeb_tpn[0],    'YRANGE',[0d0,13d0]
;IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN options,idens_peib_tpn[0],      'YLOG',0
;IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN options,edens_peeb_tpn[0],      'YLOG',0

IF (tdate[0] EQ '2008-09-16' AND sc[0] EQ 'c') THEN options,idens_peib_tpn[0],    'YRANGE',[0d0,8d0]
IF (tdate[0] EQ '2008-09-16' AND sc[0] EQ 'c') THEN options,edens_peeb_tpn[0],    'YRANGE',[0d0,8d0]
IF (tdate[0] EQ '2008-09-16' AND sc[0] EQ 'c') THEN options,etemp_peeb_tpn[0],    'YRANGE',[0d0,5d1]
IF (tdate[0] EQ '2008-09-16' AND sc[0] EQ 'c') THEN options,itemp_peib_tpn[0],    'YRANGE',[1d1,1.3d3]
IF (tdate[0] EQ '2008-09-16' AND sc[0] EQ 'c') THEN options,idens_peib_tpn[0],      'YLOG',0
IF (tdate[0] EQ '2008-09-16' AND sc[0] EQ 'c') THEN options,edens_peeb_tpn[0],      'YLOG',0
IF (tdate[0] EQ '2008-09-16' AND sc[0] EQ 'c') THEN options,etemp_peeb_tpn[0],      'YLOG',0


nna            = [fgh_maggse_tpn,idens_peib_tpn[0],edens_peeb_tpn[0],vbulk_gse_tpn[0],$
                  etemp_peeb_tpn[0],itemp_peib_tpn[0]]
  tplot,nna,TRANGE=tra_good
  time_bar,all_e_t,VARNAME=nna,COLOR=250



;;  Define zoom times and corresponding formats for files
tzooms         = [2d1,3d1,4d1,5d1,6d1,1d2,2d2,3d2,6d2]
nz             = N_ELEMENTS(tzooms)
n_esa          = N_ELEMENTS(esa___t)
tra_zms        = DBLARR(n_esa,nz,2L)
tra_zms_str    = STRARR(n_esa,nz)
FOR j=0L, n_esa[0] - 1L DO BEGIN                          $
  templ = esa___t[j] - tzooms                           & $
  temph = esa___t[j] + tzooms                           & $
  tra_zms[j,*,0] = templ                                & $
  tra_zms[j,*,1] = temph                                & $
  fnm_tl = file_name_times(templ,PREC=4)                & $
  fnm_th = file_name_times(temph,PREC=4)                & $
  ftimes = fnm_tl.F_TIME+'-'+STRMID(fnm_th.F_TIME,11L)  & $
  tra_zms_str[j,*] = ftimes


scu            = STRUPCASE(sc[0])
fpref          = 'THEMIS-'+scu[0]+'_Bo_Ni_Ne_Vbulk_Te_Ti_'
fmid           = 'with_ESA_times_'
fnames         = fpref[0]+fmid[0]+tra_zms_str
popen_str      = {PORTRAIT:1,UNITS:'inches',XSIZE:8.5,YSIZE:11.}
nna            = [fgh_maggse_tpn,idens_peib_tpn[0],edens_peeb_tpn[0],vbulk_gse_tpn[0],$
                  etemp_peeb_tpn[0],itemp_peib_tpn[0]]

FOR j=0L, n_esa[0] - 1L DO BEGIN                            $
  FOR k=0L, nz[0] - 1L DO BEGIN                             $
    tra_0 = REFORM(tra_zms[j,k,*])                        & $
    fname = fnames[j,k]                                   & $
    popen,fname[0],_EXTRA=popen_str                       & $
      tplot,nna,TRANGE=tra_0,/NOM                         & $
      time_bar,all_e_t,VARNAME=nna,COLOR=250              & $
    pclose


















