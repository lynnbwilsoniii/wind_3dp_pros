;;----------------------------------------------------------------------------------------
;;  Compile relevant routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
GG             = 6.6740800000d-11         ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1), 2014 CODATA/NIST]
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
SB             = 5.6703670000d-08         ;;  Stefan-Boltzmann Constant [W m^(-2) K^(-4), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;  Electromagnetic
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;;  Atomic
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
ma_eV          = ma[0]*c[0]^2/qq[0]       ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
me_eV          = me[0]*c[0]^2/qq[0]       ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mn_eV          = mn[0]*c[0]^2/qq[0]       ;;  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c[0]^2/qq[0]       ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;  --> Define mass ratios [unitless]
mp_me          = 1.83615267389d+03        ;;  Proton-to-electron mass ratio [unitless, 2014 CODATA/NIST]
mp_mn          = 9.98623478440d-01        ;;  Proton-to-neutron mass ratio [unitless, 2014 CODATA/NIST]
ma_me          = 7.29429954136d+03        ;;  Alpha-to-electron mass ratio [unitless, 2014 CODATA/NIST]
ma_mn          = 3.97259968907d+00        ;;  Alpha-to-neutron mass ratio [unitless, 2014 CODATA/NIST]
;;  Physico-Chemical
avagadro       = 6.0221408570d+23         ;;  Avogadro's constant [# mol^(-1), 2014 CODATA/NIST]
amu            = 1.6605390400d-27         ;;  Atomic mass constant [kg, 2014 CODATA/NIST]
amu_eV         = amu[0]*c[0]^2/qq[0]      ;;  kg --> eV [931.4940954 MeV, 2014 CODATA/NIST]
;;  Astronomical
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
Ms_M_Ea        = 3.329460487d05           ;;  Ratio of sun-to-Earth's mass [unitless, 2015 AA values]
M_S__kg        = 1.9884000d30             ;;  Sun's mass [kg, 2015 AA values]
M_Ea_kg        = M_S__kg[0]/Ms_M_Ea[0]    ;;  Earth's mass [kg, 2015 AA values]
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
;;----------------------------------------------------------------------------------------
;;  Conversion Factors
;;----------------------------------------------------------------------------------------
;;  Energy and Temperature
f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
J_1eV          = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
K_eV           = qq[0]/kB[0]          ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
eV_K           = kB[0]/qq[0]          ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
;;  Frequency
wcefac         = qq[0]*1d-9/me[0]                  ;;  factor for electron cyclotron angular frequency [rad s^(-1) nT^(-1)]
wcpfac         = qq[0]*1d-9/mp[0]                  ;;  factor for proton cyclotron angular frequency [rad s^(-1) nT^(-1)]
wpefac         = SQRT(1d6*qq[0]^2/(me[0]*epo[0]))  ;;  factor for electron plasma angular frequency [rad s^(-1) cm^(+3/2)]
wppfac         = SQRT(1d6*qq[0]^2/(mp[0]*epo[0]))  ;;  factor for electron plasma angular frequency [rad s^(-1) cm^(+3/2)]
fcefac         = wcefac[0]/(2d0*!DPI)              ;;  factor for electron cyclotron frequency [Hz s^(-1) nT^(-1)]
fcpfac         = wcpfac[0]/(2d0*!DPI)              ;;  factor for proton cyclotron frequency [Hz s^(-1) nT^(-1)]
fpefac         = wpefac[0]/(2d0*!DPI)              ;;  factor for electron plasma frequency [Hz s^(-1) cm^(+3/2)]
fppfac         = wppfac[0]/(2d0*!DPI)              ;;  factor for electron plasma frequency [Hz s^(-1) cm^(+3/2)]
;;  Speeds
vte_mps_fac    = SQRT(2d0*K_eV[0]*kB[0]/me[0])     ;;  factor for electron thermal speed [m s^(-1) eV^(-1/2)] (most probable speed)
vtp_mps_fac    = SQRT(2d0*K_eV[0]*kB[0]/mp[0])     ;;  factor for proton thermal speed [m s^(-1) eV^(-1/2)] (most probable speed)
vte_rms_fac    = SQRT(K_eV[0]*kB[0]/me[0])         ;;  factor for electron thermal speed [m s^(-1) eV^(-1/2)] (rms speed)
vtp_rms_fac    = SQRT(K_eV[0]*kB[0]/mp[0])         ;;  factor for proton thermal speed [m s^(-1) eV^(-1/2)] (rms speed)
valfen__fac    = 1d-9/SQRT(muo[0]*mp[0]*1d6)       ;;  factor for (proton-only) Alfvén speed [m s^(-1) nT^(-1) cm^(-3/2)]
;;  Lengths
rhoe_mps_fac   = vte_mps_fac[0]/wcefac[0]          ;;  factor for electron (most probable speed) thermal Larmor radius [m eV^(-1/2) nT]
rhop_mps_fac   = vtp_mps_fac[0]/wcpfac[0]          ;;  factor for proton (most probable speed) thermal Larmor radius [m eV^(-1/2) nT]
rhoe_rms_fac   = vte_rms_fac[0]/wcefac[0]          ;;  factor for electron (rms speed) thermal Larmor radius [m eV^(-1/2) nT]
rhop_rms_fac   = vtp_rms_fac[0]/wcpfac[0]          ;;  factor for proton (rms speed) thermal Larmor radius [m eV^(-1/2) nT]
iner_Lee_fac   = c[0]/wpefac[0]                    ;;  factor for electron inertial length [m cm^(-3/2)]
iner_Lep_fac   = c[0]/wppfac[0]                    ;;  factor for proton inertial length [m cm^(-3/2)]
;;----------------------------------------------------------------------------------------
;;  Default and dummy variables
;;----------------------------------------------------------------------------------------
vec_str        = ['x','y','z']
fac_dir_str    = ['para','perp','anti']
vec_col        = [250,150,50]
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_fac      = 'fac'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])

def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}
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
tplot_options,'CHARSIZE',1.00
tplot_options, 'XMARGIN',[20,10]
tplot_options, 'YMARGIN',[4,4]

magf__tpn      = scpref[0]+['fgh_'+[coord_mag[0],coord_gse[0]],'fgl_'+coord_mag[0]]
vbulk_tpn      = scpref[0]+'peib_velocity_'+coord_gse[0]
densi_tpn      = scpref[0]+'peib_density'
eitem_tpn      = scpref[0]+['peib','peeb']+'_avgtemp'
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'b') THEN options,eitem_tpn[0],MAX_VALUE=500.
nna            = [magf__tpn,vbulk_tpn[0],densi_tpn[0],eitem_tpn]
tplot,nna

;;----------------------------------------------------------------------------------------
;;  Calculate the Alfvénic Mach number
;;----------------------------------------------------------------------------------------
get_data,magf__tpn[0],DATA=temp_bmag,DLIM=dlim_bmag,LIM=lim_bmag
get_data,densi_tpn[0],DATA=temp_iden,DLIM=dlim_iden,LIM=lim_iden
get_data,vbulk_tpn[0],DATA=temp_ivsw,DLIM=dlim_ivsw,LIM=lim_ivsw
get_data,eitem_tpn[0],DATA=temp_item,DLIM=dlim_item,LIM=lim_item
get_data,eitem_tpn[1],DATA=temp_etem,DLIM=dlim_etem,LIM=lim_etem
;;  Define parameters
bmag__t        = temp_bmag.X
bmag__v        = temp_bmag.Y
idens_t        = temp_iden.X
idens_v        = temp_iden.Y
vbulk_t        = temp_ivsw.X
vbulk_v        = temp_ivsw.Y
itemp_t        = temp_item.X
itemp_v        = temp_item.Y
etemp_t        = temp_etem.X
etemp_v        = temp_etem.Y
;;  Force to electron time stamps
bmag__v_et     = interp(bmag__v,bmag__t,etemp_t,/NO_EXTRAP)
idens_v_et     = interp(idens_v,idens_t,etemp_t,/NO_EXTRAP)
vbulk_v_et     = resample_2d_vec(vbulk_v,vbulk_t,etemp_t,/NO_EXTRAPOLATE)
itemp_v_et     = interp(itemp_v,itemp_t,etemp_t,/NO_EXTRAP)
;;  Calculate Alfvén speed
valfen         = valfen__fac[0]*bmag__v_et/SQRT(idens_v_et)
valfen        *= 1d-3        ;;  m --> km
;;  Calculate ion-acoustic sound speed
gamma_ei       = [1d0,2d0]
fac0           = K_eV[0]*kB[0]/(mp[0] + me[0])
fac_temp       = gamma_ei[0]*etemp_v + gamma_ei[1]*itemp_v_et
Cs_iaw         = SQRT(fac0[0]*fac_temp)
Cs_iaw        *= 1d-3        ;;  m --> km
;;  Calculate the Alfvénic and Sound Mach numbers
vbulk_m_et     = mag__vec(vbulk_v_et,/NAN)
Mach_Alfen     = vbulk_m_et/valfen
Mach_Sound     = vbulk_m_et/Cs_iaw
Mach_Magneto   = SQRT(Mach_Alfen^2 + Mach_Sound^2)
;;  Send to TPLOT
mach_tpn       = scpref[0]+'Malfven_Msound'
mach_struc     = {X:etemp_t,Y:[[Mach_Alfen],[Mach_Sound],[Mach_Magneto]]}
mach_yttle     = 'Mach Numbers'
mach_labs      = ['Alfven','Sound','Magnetosonic']
store_data,mach_tpn[0],DATA=mach_struc,DLIM=def_dlim,LIM=def__lim
;;  Alter options
symb          = 2
options,mach_tpn[0],LABELS=mach_labs,COLORS=vec_col,YTITLE=mach_yttle[0]
options,mach_tpn[0],PSYM=symb[0],YLOG=1,YMINOR=9

;;----------------------------------------------------------------------------------------
;;  Calculate the ∂B and ∂B/Bo
;;----------------------------------------------------------------------------------------
get_data,magf__tpn[0],DATA=temp_bmag,DLIM=dlim_bmag,LIM=lim_bmag
get_data,magf__tpn[1],DATA=temp_bgse,DLIM=dlim_bgse,LIM=lim_bgse
;;  Define parameters
bmag__t        = temp_bmag.X
bmag__v        = temp_bmag.Y
bgse__t        = temp_bgse.X
bgse__v        = temp_bgse.Y
;;  Define "smoothed" Bo
new_sr         = 1d0
srate          = sample_rate(bmag__t,/AVE)
speri          = 1d0/srate[0]               ;;  sampling period [s]
wd             = LONG(1d0/(new_sr[0]/srate[0]))
bmag_sm        = MEDIAN(bmag__v,wd[0])
tempx          = MEDIAN(bgse__v[*,0],wd[0])
tempy          = MEDIAN(bgse__v[*,1],wd[0])
tempz          = MEDIAN(bgse__v[*,2],wd[0])
bgse_sm        = [[tempx],[tempy],[tempz]]
;;  Detrend Bo
bmag_dt        = ABS(bmag__v - bmag_sm)
bgse_dt        = bgse__v - bgse_sm
;;  Define ∂B/Bo
bgse_sm_mag    = mag__vec(bgse_sm,/NAN,/TWO)
db_bov_gse     = bgse_dt/bgse__v
db_bom_gse     = bgse_dt/bgse_sm_mag
db_bom_mag     = bmag_dt/bmag__v
db_bom_mag_sm  = MEDIAN(db_bom_mag,wd[0]/4L)
db_bov_max     = 5d1
test           = (ABS(db_bov_gse[*,0]) GE db_bov_max[0]) OR (ABS(db_bov_gse[*,1]) GE db_bov_max[0]) OR $
                 (ABS(db_bov_gse[*,2]) GE db_bov_max[0])
bad            = WHERE(test,bd)
IF (bd GT 0) THEN db_bov_gse[bad,*] = d
;;  Send to TPLOT
db_bov_gse_tpn = 'dB_Bovec_'+coord_gse[0]
db_bom_gse_tpn = 'dB_Bomag_'+coord_gse[0]
db_bom_mag_tpn = 'dB_Bomag_'+coord_mag[0]
db_bov_gse_str = {X:bgse__t,Y:db_bov_gse}
db_bom_gse_str = {X:bgse__t,Y:db_bom_gse}
db_bom_mag_str = {X:bmag__t,Y:[[db_bom_mag],[db_bom_mag_sm]]}
wd_str         = STRTRIM(STRING(wd[0],FORMAT='(I3.3)'),2L)
ysubt          = '[Detrended:  '+wd_str[0]+' pts]'
db_bov_gse_ytt = 'dB_j/Bo_j'
db_bom_gse_ytt = 'dB_j/|Bo_j|'
db_bom_mag_ytt = '|dB|/|Bo|'

store_data,db_bov_gse_tpn[0],DATA=db_bov_gse_str,DLIM=def_dlim,LIM=def__lim
store_data,db_bom_gse_tpn[0],DATA=db_bom_gse_str,DLIM=def_dlim,LIM=def__lim
store_data,db_bom_mag_tpn[0],DATA=db_bom_mag_str,DLIM=def_dlim,LIM=def__lim
;;  Alter options
options,[db_bov_gse_tpn[0],db_bom_gse_tpn[0],db_bom_mag_tpn[0]],'LABELS'
options,[db_bov_gse_tpn[0],db_bom_gse_tpn[0],db_bom_mag_tpn[0]],'COLORS'
options,[db_bov_gse_tpn[0],db_bom_gse_tpn[0],db_bom_mag_tpn[0]],'YSUBTITLE'
options,[db_bov_gse_tpn[0],db_bom_gse_tpn[0],db_bom_mag_tpn[0]],'LABELS',/DEF
options,[db_bov_gse_tpn[0],db_bom_gse_tpn[0],db_bom_mag_tpn[0]],'YSUBTITLE',ysubt,/DEF
options,db_bom_mag_tpn[0],COLORS=vec_col[[2,1]],YTITLE=db_bom_mag_ytt[0],YLOG=1,YMINOR=9,YRANGE=[1e-4,2e1]
options,db_bov_gse_tpn[0],COLORS=vec_col,   YTITLE=db_bov_gse_ytt[0],LABELS=vec_str,YMINOR=4
options,db_bom_gse_tpn[0],COLORS=vec_col,   YTITLE=db_bom_gse_ytt[0],LABELS=vec_str,YMINOR=4

;;----------------------------------------------------------------------------------------
;;  Define file paths and names to fit results
;;----------------------------------------------------------------------------------------
eVDF_dir       = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'TPLOT_THEMIS_PLOTS'+slash[0]+'eVDF_Fits'+slash[0]
fpref_dir      = 'eVDF_'+scpref[0]+'Fits_'+tdate[0]
fpref          = 'THEMIS_EESA_*_'+sc[0]+'_SWF_SCF_Power_Law_Exponential_Fit-Results_'
fname          = fpref[0]+tdate[0]+'*.sav'
dir            = eVDF_dir[0]+fpref_dir[0]+slash[0]
file           = FILE_SEARCH(dir[0],fname[0])
RESTORE,file[0]

HELP, plexp_fit_pnt
gnne           = N_ELEMENTS(plexp_fit_pnt[*,1])
plexp_scf_ptr  = PTRARR(gnne[0],/ALLOCATE_HEAP)
plexp_swf_ptr  = PTRARR(gnne[0],/ALLOCATE_HEAP)
FOR j=0L, gnne[0] - 1L DO BEGIN                       $
  *plexp_scf_ptr[j] = *plexp_fit_pnt[j,1]           & $
  *plexp_swf_ptr[j] = *plexp_fit_pnt[j,0]

;;  Clean up
FOR frame=0L, 1L DO BEGIN                                            $
  FOR j=0L, gnne[0] - 1L DO BEGIN                                    $
    PTR_FREE,plexp_fit_pnt[j,frame]                                & $
    HEAP_FREE,plexp_fit_pnt[j,frame],/PTR
DELVAR,plexp_fit_pnt

;;----------------------------------------------------------------------------------------
;;  Define fit parameter results
;;----------------------------------------------------------------------------------------
;;------------------------------------------------
;;  (Power-Law + Exponential) Fits
;;    Y = A X^(B) e^(C X) + D
;;------------------------------------------------
n_fits         = N_ELEMENTS(plexp_swf_ptr)
unix_sten      = REPLICATE(d,n_fits[0],2L)
magf_vals      = REPLICATE(d,n_fits[0],3L)       ;;  GSE B-field vectors for each event [nT]
vsw__vals      = REPLICATE(d,n_fits[0],3L)       ;;  GSE bulk flow velocity vectors for each event [km/s]
fit_params     = REPLICATE(d,n_fits[0],4L,3L)    ;;  [N,4,3] --> 3 = Para, Perp, Anti
sig_params     = REPLICATE(d,n_fits[0],4L,3L)
fit_status     = REPLICATE(d,n_fits[0],3L)
dof__chisq     = REPLICATE(d,n_fits[0],2L,3L)

FOR j=0L, n_fits[0] - 1L DO BEGIN                                                        $
  st_unix   = (*plexp_swf_ptr[j]).INIT_STRUC.DATA.TIME[0]                              & $
  en_unix   = (*plexp_swf_ptr[j]).INIT_STRUC.DATA.END_TIME[0]                          & $
  temp_bgse = (*plexp_swf_ptr[j]).INIT_STRUC.DATA.MAGF                                 & $
  temp_vgse = (*plexp_swf_ptr[j]).INIT_STRUC.DATA.VSW                                  & $
  temp_par  = (*plexp_swf_ptr[j]).FIT_PARA_STRUC.FIT                                   & $
  temp_per  = (*plexp_swf_ptr[j]).FIT_PERP_STRUC.FIT                                   & $
  temp_ant  = (*plexp_swf_ptr[j]).FIT_ANTI_STRUC.FIT                                   & $
  temp_parm = [[temp_par.FIT_PARAMS],[temp_per.FIT_PARAMS],[temp_ant.FIT_PARAMS]]      & $
  temp_sigp = [[temp_par.SIG_PARAM],[temp_per.SIG_PARAM],[temp_ant.SIG_PARAM]]         & $
  temp_chi2 = [temp_par.CHISQ[0],temp_per.CHISQ[0],temp_ant.CHISQ[0]]                  & $
  temp_dof  = [temp_par.DOF[0],temp_per.DOF[0],temp_ant.DOF[0]]                        & $
  temp_stat = [temp_par.STATUS[0],temp_per.STATUS[0],temp_ant.STATUS[0]]               & $
  unix_sten[j,*] = [st_unix[0],en_unix[0]]                                             & $
  magf_vals[j,*] = temp_bgse                                                           & $
  vsw__vals[j,*] = temp_vgse                                                           & $
  fit_params[j,*,*] = temp_parm                                                        & $
  sig_params[j,*,*] = temp_sigp                                                        & $
  fit_status[j,*]   = temp_stat                                                        & $
  dof__chisq[j,0,*] = temp_dof                                                         & $
  dof__chisq[j,1,*] = temp_chi2

;;  Calculate the reduced chi-squared value
red_chisq      = REFORM(dof__chisq[*,1,*])/REFORM(dof__chisq[*,0,*])
;;----------------------------------------------------------------------------------------
;;  Define constraints to determine "quality"
;;----------------------------------------------------------------------------------------
;;  Find strahl direction
.compile $HOME/Desktop/temp_idl/temp_electron_fitting_routines/find_strahl_direction.pro
.compile $HOME/Desktop/temp_idl/get_power_of_ten_ticks.pro
strahl_dir     = find_strahl_direction(magf_vals)
;;  Define relevant time range
tra_eVDFs      = minmax(unix_sten)
;;  Define some constraints
min_Eo         = 75d0
max_B          = 1.5d0
max_rchi2      = 3d3
min_A          = 1d5

;;  Define tests to determine the "quality" of any given fit
bad_A_par_test = (fit_params[*,0,0] LT min_A[0]) OR (red_chisq[*,0] GT max_rchi2[0])
bad_A_per_test = (fit_params[*,0,1] LT min_A[0]) OR (red_chisq[*,1] GT max_rchi2[0])
bad_A_ant_test = (fit_params[*,0,2] LT min_A[0]) OR (red_chisq[*,1] GT max_rchi2[0])
bad_B_par_test = (fit_params[*,1,0] GT 0) OR (ABS(fit_params[*,1,0]) GT max_B[0])
bad_B_per_test = (fit_params[*,1,1] GT 0) OR (ABS(fit_params[*,1,1]) GT max_B[0])
bad_B_ant_test = (fit_params[*,1,2] GT 0) OR (ABS(fit_params[*,1,2]) GT max_B[0])
bad_C_par_test = (fit_params[*,2,0] GT 0) OR ((1d0/ABS(fit_params[*,2,0])) LT min_Eo[0])
bad_C_per_test = (fit_params[*,2,1] GT 0) OR ((1d0/ABS(fit_params[*,2,1])) LT min_Eo[0])
bad_C_ant_test = (fit_params[*,2,2] GT 0) OR ((1d0/ABS(fit_params[*,2,2])) LT min_Eo[0])

bad_par_test   = bad_A_par_test OR bad_B_par_test OR bad_C_par_test OR (strahl_dir GT 0d0)
bad_per_test   = bad_A_per_test OR bad_B_per_test OR bad_C_per_test
bad_ant_test   = bad_A_ant_test OR bad_B_ant_test OR bad_C_ant_test OR (strahl_dir LT 0d0)
bad_stats_test = (fit_status[*,0] LE 0) OR (fit_status[*,1] LE 0) OR (fit_status[*,2] LE 0)

bad_par        = WHERE(bad_par_test OR bad_stats_test,bd_par,COMPLEMENT=good_par,NCOMPLEMENT=gd_par)
bad_per        = WHERE(bad_per_test OR bad_stats_test,bd_per,COMPLEMENT=good_per,NCOMPLEMENT=gd_per)
bad_ant        = WHERE(bad_ant_test OR bad_stats_test,bd_ant,COMPLEMENT=good_ant,NCOMPLEMENT=gd_ant)
PRINT,';;',gd_par[0],gd_per[0],gd_ant[0],'  For '+tdate[0]+', Probe '+scu[0] & $
PRINT,';;',bd_par[0],bd_per[0],bd_ant[0],'  For '+tdate[0]+', Probe '+scu[0]
;;         617         915          88  For 2008-07-14, Probe B
;;         770         472        1299  For 2008-07-14, Probe B
;;         655         846          56  For 2008-07-14, Probe C
;;         323         132         922  For 2008-07-14, Probe C


;;  Define arrays for the power-law indices and energy cutoffs
powerlaws_gb   = REPLICATE(d,n_fits[0],3L,2L)
enercutof_gb   = REPLICATE(d,n_fits[0],3L,2L)
IF (gd_par GT 0) THEN powerlaws_gb[good_par,0L,0L] = fit_params[good_par,1,0]
IF (gd_per GT 0) THEN powerlaws_gb[good_per,1L,0L] = fit_params[good_per,1,1]
IF (gd_ant GT 0) THEN powerlaws_gb[good_ant,2L,0L] = fit_params[good_ant,1,2]
IF (bd_par GT 0) THEN powerlaws_gb[ bad_par,0L,1L] = fit_params[ bad_par,1,0]
IF (bd_per GT 0) THEN powerlaws_gb[ bad_per,1L,1L] = fit_params[ bad_per,1,1]
IF (bd_ant GT 0) THEN powerlaws_gb[ bad_ant,2L,1L] = fit_params[ bad_ant,1,2]

IF (gd_par GT 0) THEN enercutof_gb[good_par,0L,0L] = 1d0/ABS(fit_params[good_par,2,0])
IF (gd_per GT 0) THEN enercutof_gb[good_per,1L,0L] = 1d0/ABS(fit_params[good_per,2,1])
IF (gd_ant GT 0) THEN enercutof_gb[good_ant,2L,0L] = 1d0/ABS(fit_params[good_ant,2,2])
IF (bd_par GT 0) THEN enercutof_gb[ bad_par,0L,1L] = 1d0/ABS(fit_params[ bad_par,2,0])
IF (bd_per GT 0) THEN enercutof_gb[ bad_per,1L,1L] = 1d0/ABS(fit_params[ bad_per,2,1])
IF (bd_ant GT 0) THEN enercutof_gb[ bad_ant,2L,1L] = 1d0/ABS(fit_params[ bad_ant,2,2])
;;----------------------------------------------------------------------------------------
;;  Send results to TPLOT
;;----------------------------------------------------------------------------------------
;;  Define output structures
avg_unix       = (unix_sten[*,0] + unix_sten[*,1])/2d0
good_pl_str    = {X:avg_unix,Y:powerlaws_gb[*,*,0]}
bad__pl_str    = {X:avg_unix,Y:powerlaws_gb[*,*,1]}
good_Eo_str    = {X:avg_unix,Y:enercutof_gb[*,*,0]}
bad__Eo_str    = {X:avg_unix,Y:enercutof_gb[*,*,1]}

;;  Define TPLOT handles
tpn_suffx_pe   = ['powerlaws','ener_cutoffs']
tpn_suffx_gb   = ['good','bad']
good_pl_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[0]+'_'+tpn_suffx_gb[0]
bad__pl_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[0]+'_'+tpn_suffx_gb[1]
good_Eo_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[1]+'_'+tpn_suffx_gb[0]
bad__Eo_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[1]+'_'+tpn_suffx_gb[1]

;;  Define YTITLE's and YSUBTITLE's
good_pl_yttle  = 'Power Law Index'
good_pl_ysubt  = '[Good: Sat. Constraints]'
bad__pl_yttle  = good_pl_yttle[0]
bad__pl_ysubt  = '[Bad: Failed Constraints]'
good_Eo_yttle  = 'Energy Cutoff [eV]'
good_Eo_ysubt  = good_pl_ysubt[0]
bad__Eo_yttle  = good_Eo_yttle[0]
bad__Eo_ysubt  = bad__pl_ysubt[0]

;;  Define YRANGE's
good_pl_yran   = [-155e-2,0e00]
bad__pl_yran   = [MIN(bad__pl_str.Y,/NAN),MAX(bad__pl_str.Y,/NAN)]
good_Eo_yran   = [1e1,(MAX(good_Eo_str.Y,/NAN) > 1e2) < 1e6]
bad__Eo_yran   = [1e1,(MAX(bad__Eo_str.Y,/NAN) > 1e2) < 1e6]
good_Eo_ytick  = get_power_of_ten_ticks(good_Eo_yran)
bad__Eo_ytick  = get_power_of_ten_ticks(bad__Eo_yran)

;;  Send to TPLOT
store_data,good_pl_tpn[0],DATA=good_pl_str,DLIM=def_dlim,LIM=def__lim
store_data,bad__pl_tpn[0],DATA=bad__pl_str,DLIM=def_dlim,LIM=def__lim
store_data,good_Eo_tpn[0],DATA=good_Eo_str,DLIM=def_dlim,LIM=def__lim
store_data,bad__Eo_tpn[0],DATA=bad__Eo_str,DLIM=def_dlim,LIM=def__lim

;;  Alter options
symb          = 2
options,good_pl_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=good_pl_yttle[0],YLOG=0,YMINOR=4
options,bad__pl_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=bad__pl_yttle[0],YLOG=0,YMINOR=4
options,good_Eo_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=good_Eo_yttle[0],YLOG=1,YMINOR=9
options,bad__Eo_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=bad__Eo_yttle[0],YLOG=1,YMINOR=9
options,good_pl_tpn[0],YRANGE=good_pl_yran,YSUBTITLE=good_pl_ysubt[0],PSYM=symb[0]
options,bad__pl_tpn[0],YRANGE=bad__pl_yran,YSUBTITLE=bad__pl_ysubt[0],PSYM=symb[0]
options,good_Eo_tpn[0],YRANGE=good_Eo_yran,YSUBTITLE=good_Eo_ysubt[0],PSYM=symb[0]
options,bad__Eo_tpn[0],YRANGE=bad__Eo_yran,YSUBTITLE=bad__Eo_ysubt[0],PSYM=symb[0]
options,good_Eo_tpn[0],YTICKNAME=good_Eo_ytick.YTICKNAME,YTICKV=good_Eo_ytick.YTICKV,YTICKS=good_Eo_ytick.YTICKS
options,bad__Eo_tpn[0],YTICKNAME=bad__Eo_ytick.YTICKNAME,YTICKV=bad__Eo_ytick.YTICKV,YTICKS=bad__Eo_ytick.YTICKS


;;  Plot results
all_pl_tpns    = [good_pl_tpn[0],bad__pl_tpn[0]]
all_Eo_tpns    = [good_Eo_tpn[0],bad__Eo_tpn[0]]
nna            = [magf__tpn[0:1],densi_tpn[0],eitem_tpn,all_pl_tpns,all_Eo_tpns]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],eitem_tpn,all_pl_tpns,all_Eo_tpns]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],mach_tpn[0],all_pl_tpns,all_Eo_tpns]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],mach_tpn[0],all_pl_tpns[0],all_Eo_tpns[0]]
tplot,nna,TRANGE=tra_eVDFs

all_dB_Bo_tpns = [db_bov_gse_tpn[0],db_bom_gse_tpn[0],db_bom_mag_tpn[0]]
nna            = [magf__tpn[0:1],mach_tpn[0],all_pl_tpns[0],all_Eo_tpns[0],all_dB_Bo_tpns]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],mach_tpn[0],all_pl_tpns[0],all_Eo_tpns[0],all_dB_Bo_tpns[1:2]]
tplot,nna,TRANGE=tra_eVDFs

;;----------------------------------------------------------------------------------------
;;  Find the hardest power-laws satisfying constraints
;;----------------------------------------------------------------------------------------
test_hd_par_pl = (ABS(powerlaws_gb[*,0L,0L]) LT 0.5) AND FINITE(powerlaws_gb[*,0L,0L])
test_hd_per_pl = (ABS(powerlaws_gb[*,1L,0L]) LT 0.5) AND FINITE(powerlaws_gb[*,1L,0L])
test_hd_ant_pl = (ABS(powerlaws_gb[*,2L,0L]) LT 0.5) AND FINITE(powerlaws_gb[*,2L,0L])

good_hd_par_pl = WHERE(test_hd_par_pl,gd_hd_par_pl,COMPLEMENT=bad_hd_par_pl,NCOMPLEMENT=bd_hd_par_pl)
good_hd_per_pl = WHERE(test_hd_per_pl,gd_hd_per_pl,COMPLEMENT=bad_hd_per_pl,NCOMPLEMENT=bd_hd_per_pl)
good_hd_ant_pl = WHERE(test_hd_ant_pl,gd_hd_ant_pl,COMPLEMENT=bad_hd_ant_pl,NCOMPLEMENT=bd_hd_ant_pl)
PRINT,';;',gd_hd_par_pl[0],gd_hd_per_pl[0],gd_hd_ant_pl[0],'  For '+tdate[0]+', Probe '+scu[0] & $
PRINT,';;',bd_hd_par_pl[0],bd_hd_per_pl[0],bd_hd_ant_pl[0],'  For '+tdate[0]+', Probe '+scu[0]
;;         126           5           0  For 2008-07-14, Probe B
;;        1261        1382        1387  For 2008-07-14, Probe B
;;         303          88           6  For 2008-07-14, Probe C
;;         675         890         972  For 2008-07-14, Probe C

;;----------------------------------------------------------------------------------------
;;  Plot Eo and |¥| vs. Mach numbers
;;----------------------------------------------------------------------------------------
WINDOW,1,RETAIN=2
WINDOW,2,RETAIN=2
;;  Setup margins
xmargin        = [20,15]
ymargin        = [8,4]
chsz           = 1.75
;;  Define defaults
xttl           = 'M_'+['A','Cs','MS']+' [Mach Number = Vsw/V_j]'
yttl           = 'Eo [eV]'
gysubt         = '[Constraints Are Satisfied]'
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN xrange = [1e-2,5e1]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN yrange = [6e1,5e3]
pstr           = {XSTYLE:1,YSTYLE:1,XLOG:1,YLOG:1,YTITLE:yttl,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1,CHARSIZE:chsz}
IF (N_ELEMENTS(xrange) EQ 2) THEN str_element,pstr,'XRANGE',xrange,/ADD_REPLACE
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr,'YRANGE',yrange,/ADD_REPLACE

tt             = good_eo_str.X
sp             = SORT(tt)
tt             = TEMPORARY(tt[sp])
xdat           = resample_2d_vec(mach_struc.Y,mach_struc.X,tt,/NO_EXTRAPOLATE)
ydat           = ABS(good_eo_str.Y[sp,*])

WSET,1
WSHOW,1
!P.MULTI       = [0,1,3]
FOR mach=0L, 2L DO BEGIN                                                       $
  PLOT,xdat[*,mach],ydat[*,0],_EXTRA=pstr,SUBTITLE=gysubt,XTITLE=xttl[mach]  & $
    FOR k=0L, 2L DO OPLOT,xdat[*,mach],ydat[*,k],COLOR=vec_col[k],PSYM=2
!P.MULTI       = 0


xttl           = 'M_'+['A','Cs','MS']+' [Mach Number = Vsw/V_j]'
yttl           = '|gamma| [or |B| fit parameter]'
gysubt         = '[Constraints Are Satisfied]'
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN xrange = [1e-2,5e1]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN yrange = [0e0,2e0]
pstr           = {XSTYLE:1,YSTYLE:1,XLOG:1,YLOG:0,YTITLE:yttl,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1,CHARSIZE:chsz}
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr,'YRANGE',yrange,/ADD_REPLACE

tt             = good_pl_str.X
sp             = SORT(tt)
tt             = TEMPORARY(tt[sp])
xdat           = resample_2d_vec(mach_struc.Y,mach_struc.X,tt,/NO_EXTRAPOLATE)
ydat           = ABS(good_pl_str.Y[sp,*])

WSET,2
WSHOW,2
!P.MULTI       = [0,1,3]
FOR mach=0L, 2L DO BEGIN                                                       $
  PLOT,xdat[*,mach],ydat[*,0],_EXTRA=pstr,SUBTITLE=gysubt,XTITLE=xttl[mach]  & $
    FOR k=0L, 2L DO OPLOT,xdat[*,mach],ydat[*,k],COLOR=vec_col[k],PSYM=2
!P.MULTI       = 0


;;----------------------------------------------------------------------------------------
;;  Plot Eo vs. |¥|
;;----------------------------------------------------------------------------------------

;;  Define defaults
xttl           = '|gamma| [or |B| fit parameter]'
yttl           = 'Eo [eV]'
gysubt         = '[Constraints Are Satisfied]'
bysubt         = '[Constraints Not Satisfied]'

;IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN xrange = [1e-3,2e0]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN xrange = [0e0,2e0]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN yrange = [6e1,5e3]
pstr           = {XSTYLE:1,YSTYLE:1,XLOG:0,YLOG:1,XTITLE:xttl,YTITLE:yttl,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1}
IF (N_ELEMENTS(xrange) EQ 2) THEN str_element,pstr,'XRANGE',xrange,/ADD_REPLACE
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr,'YRANGE',yrange,/ADD_REPLACE

sp             = SORT(good_pl_str.X)
xdat           = ABS(good_pl_str.Y[sp,*])
sp             = SORT(good_eo_str.X)
ydat           = ABS(good_eo_str.Y[sp,*])

WSET,1
WSHOW,1
  PLOT,xdat[*,0],ydat[*,0],_EXTRA=pstr,SUBTITLE=gysubt
    FOR k=0L, 2L DO OPLOT,xdat[*,k],ydat[*,k],COLOR=vec_col[k],PSYM=2



xttl2          = 'gamma [or B fit parameter]'
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN xrang2 = [-4e0,1e0]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN yrang2 = [1e1,5e4]
pstr2          = {XSTYLE:1,YSTYLE:1,XLOG:0,YLOG:1,XTITLE:xttl2,YTITLE:yttl,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1}
IF (N_ELEMENTS(xrange) EQ 2) THEN str_element,pstr2,'XRANGE',xrang2,/ADD_REPLACE
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr2,'YRANGE',yrang2,/ADD_REPLACE

sp             = SORT(bad__pl_str.X)
xdat           =      bad__pl_str.Y[sp,*]
sp             = SORT(bad__Eo_str.X)
ydat           =  ABS(bad__Eo_str.Y[sp,*])

WSET,2
WSHOW,2
  PLOT,xdat[*,0],ydat[*,0],_EXTRA=pstr2,SUBTITLE=bysubt
    FOR k=0L, 2L DO OPLOT,xdat[*,k],ydat[*,k],COLOR=vec_col[k],PSYM=2






















