;;  @/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_batch.pro

;;  Compile Coyote software
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgerrormsg.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgreverseindices.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgsetunion.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgsetdifference.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgsetintersection.pro
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;  Electromagnetic
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;;  Atomic
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
ma_eV          = ma[0]*c[0]^2/qq[0]       ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
me_eV          = me[0]*c[0]^2/qq[0]       ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mn_eV          = mn[0]*c[0]^2/qq[0]       ;;  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c[0]^2/qq[0]       ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;  Conversion factors
;;    Energy and Temperature
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> eV2K*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> K2eV*Temp{K} = energy{eV}]
;;    Speeds
valf_fac       = 1d-9/SQRT(muo[0]*1d6*mp[0])*1d-3
cs_fac         = SQRT(5d0/3d0)*1d-3
;;  Astronomical
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
aukm           = au[0]*1d-3               ;;  m --> km
;;----------------------------------------------------------------------------------------
;;  Coordinates and vectors
;;----------------------------------------------------------------------------------------
coord_gse      = 'gse'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
vec_str        = ['x','y','z']
vec_col        = [250,200,75]
xyz_str        = vec_str
xyz_col        = vec_col
;;  Define spacecraft name
sc             = 'Wind'
probe          = 'wind'
probeu         = 'Wind'
scpref         = probe[0]+'_'
scprefu        = probeu[0]+'_'
;;  Date/Time stuff
start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
;;----------------------------------------------------------------------------------------
;;  Find and restore TPLOT files
;;----------------------------------------------------------------------------------------
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'temp_idl'+slash[0]+'solar_wind_stats'+slash[0]+'sav_files'+slash[0]
fname_in       = scpref[0]+'EarthPosi_SCPosi_SWE_MFI_3dp_emfits_*.tplot'
gfile          = FILE_SEARCH(sav_dir[0],fname_in[0])
IF (gfile[0] NE '') THEN tplot_restore,FILENAME=gfile[0],/APPEND,/SORT
;;----------------------------------------------------------------------------------------
;;  Define relevant TPLOT handles
;;----------------------------------------------------------------------------------------
t_3dp_tpns     = ['Ne_3dp','Te_pape_3dp','Te_anis_3dp','Te_totl_3dp','Qe_para_3dp',     $
                  'Ve_3dp_gse','Quality_Flag_3dp']
t_swep_tpn     = scprefu[0]+['Vbulk_p_'+['mag',vec_str+coord_gse[0]],'VTh_p_'+          $
                 ['_avg','perp','para'],'Np']+'_SWE_nonlin'
t_swea_tpn     = scprefu[0]+['Vbulk_a_'+['mag',vec_str+coord_gse[0]],'VTh_a_'+          $
                 ['_avg','perp','para'],'Na']+'_SWE_nonlin'
t_swep_sig_tpn = t_swep_tpn+'_sigma'
t_swea_sig_tpn = t_swea_tpn+'_sigma'
t_mfi_tpn      = scprefu[0]+'B_1min_'+coord_gse[0]
;;----------------------------------------------------------------------------------------
;;  Get relevant TPLOT data
;;----------------------------------------------------------------------------------------
;;  Ns [# cm^(-3)]
get_data,t_3dp_tpns[0],DATA=temp_ne,DLIMIT=dlim_ne,LIMIT=lim_ne
get_data,t_swep_tpn[7],DATA=temp_np,DLIMIT=dlim_np,LIMIT=lim_np
get_data,t_swea_tpn[7],DATA=temp_na,DLIMIT=dlim_na,LIMIT=lim_na
;;  Vs [km s^(-1)]
get_data,t_3dp_tpns[5],DATA=temp_Ve,DLIMIT=dlim_Ve,LIMIT=lim_Ve
get_data,t_swep_tpn[1],DATA=temp_Vpx,DLIMIT=dlim_Vpx,LIMIT=lim_Vpx
get_data,t_swep_tpn[2],DATA=temp_Vpy,DLIMIT=dlim_Vpy,LIMIT=lim_Vpy
get_data,t_swep_tpn[3],DATA=temp_Vpz,DLIMIT=dlim_Vpz,LIMIT=lim_Vpz
get_data,t_swea_tpn[1],DATA=temp_Vax,DLIMIT=dlim_Vax,LIMIT=lim_Vax
get_data,t_swea_tpn[2],DATA=temp_Vay,DLIMIT=dlim_Vay,LIMIT=lim_Vay
get_data,t_swea_tpn[3],DATA=temp_Vaz,DLIMIT=dlim_Vaz,LIMIT=lim_Vaz
;;  Te_j [eV]
get_data,t_3dp_tpns[1],DATA=temp_Teb,DLIMIT=dlim_Teb,LIMIT=lim_Teb
get_data,t_3dp_tpns[3],DATA=temp_Tet,DLIMIT=dlim_Tet,LIMIT=lim_Tet
;;  VTs [km s^(-1)]
get_data,t_swep_tpn[4],DATA=temp_VTpav,DLIMIT=dlim_VTpav,LIMIT=lim_VTpav
get_data,t_swep_tpn[5],DATA=temp_VTper,DLIMIT=dlim_VTper,LIMIT=lim_VTper
get_data,t_swep_tpn[6],DATA=temp_VTpar,DLIMIT=dlim_VTpar,LIMIT=lim_VTpar
get_data,t_swea_tpn[4],DATA=temp_VTaav,DLIMIT=dlim_VTaav,LIMIT=lim_VTaav
get_data,t_swea_tpn[5],DATA=temp_VTaer,DLIMIT=dlim_VTaer,LIMIT=lim_VTaer
get_data,t_swea_tpn[6],DATA=temp_VTaar,DLIMIT=dlim_VTaar,LIMIT=lim_VTaar
;;  Bo [nT]
get_data,t_mfi_tpn[0],DATA=temp_Bo,DLIMIT=dlim_Bo,LIMIT=lim_Bo
;;  3DP Quality Flag
get_data,t_3dp_tpns[6],DATA=temp_QF,DLIMIT=dlim_QF,LIMIT=lim_QF
;;  SWE one-sigma uncertainties
;;    dNs [# cm^(-3)]
get_data,t_swep_sig_tpn[7],DATA=temp_dnp,DLIMIT=dlim_dnp,LIMIT=lim_dnp
get_data,t_swea_sig_tpn[7],DATA=temp_dna,DLIMIT=dlim_dna,LIMIT=lim_dna
;;    dVTs [km s^(-1)]
get_data,t_swep_sig_tpn[4],DATA=temp_dVTpav,DLIMIT=dlim_dVTpav,LIMIT=lim_dVTpav
get_data,t_swea_sig_tpn[4],DATA=temp_dVTaav,DLIMIT=dlim_dVTaav,LIMIT=lim_dVTaav
;;----------------------------------------------------------------------------------------
;;  Define relevant TPLOT data
;;----------------------------------------------------------------------------------------
;;  Ts = ms VTs^2/kB  [K]
Tp_fac         = 1e6*mp[0]/kB[0]*K2eV[0]
Ta_fac         = 1e6*ma[0]/kB[0]*K2eV[0]
Tp_avg         = Tp_fac[0]*(temp_VTpav.Y)^2      ;;   Tp [eV]
Tp_per         = Tp_fac[0]*(temp_VTper.Y)^2      ;;   Tp_perp [eV]
Tp_par         = Tp_fac[0]*(temp_VTpar.Y)^2      ;;   Tp_para [eV]
Ta_avg         = Ta_fac[0]*(temp_VTaav.Y)^2      ;;   Ta [eV]
Ta_per         = Ta_fac[0]*(temp_VTaer.Y)^2      ;;   Ta_perp [eV]
Ta_par         = Ta_fac[0]*(temp_VTaar.Y)^2      ;;   Ta_para [eV]
;;  Combine SWE temps
unix           = t_get_struc_unix(temp_VTpav)
Tp_all         = [[Tp_avg],[Tp_per],[Tp_par]]
Ta_all         = [[Ta_avg],[Ta_per],[Ta_par]]
temp_Tp_all    = {X:unix,Y:Tp_all}
temp_Ta_all    = {X:unix,Y:Ta_all}
;;  Combine SWE velocities
unix           = t_get_struc_unix(temp_Vpx)
vel_p          = [[temp_Vpx.Y],[temp_Vpy.Y],[temp_Vpz.Y]]
vel_a          = [[temp_Vax.Y],[temp_Vay.Y],[temp_Vaz.Y]]
temp_Vp        = {X:unix,Y:vel_p}
temp_Va        = {X:unix,Y:vel_a}
;;  Clean up
dumb           = TEMPORARY(Tp_avg)
dumb           = TEMPORARY(Tp_per)
dumb           = TEMPORARY(Tp_par)
dumb           = TEMPORARY(Ta_avg)
dumb           = TEMPORARY(Ta_per)
dumb           = TEMPORARY(Ta_par)
dumb           = TEMPORARY(Tp_all)
dumb           = TEMPORARY(Ta_all)
dumb           = TEMPORARY(vel_p)
dumb           = TEMPORARY(vel_a)
dumb           = TEMPORARY(unix)
;;----------------------------------------------------------------------------------------
;;  Define "bad" SWE times
;;----------------------------------------------------------------------------------------
;;  Assign "bad" to:
;;    Protons:  (dN/N > 30%) OR (dVT/VT > 40%)
;;    Alphas :  (dN/N > 40%) OR (dVT/VT > 50%)
thrsh_p        = [3e-1,4e-1]
thrsh_a        = [4e-1,5e-1]
dn_n_p         = temp_dnp.Y/temp_np.Y
dn_n_a         = temp_dna.Y/temp_na.Y
dVT_VT_p       = temp_dVTpav.Y/temp_VTpav.Y
dVT_VT_a       = temp_dVTaav.Y/temp_VTaav.Y
;;  Find "bad" elements
testp          = (dn_n_p GT thrsh_p[0]) OR (dVT_VT_p GT thrsh_p[1]) OR $
                 (FINITE(temp_np.Y) EQ 0) OR (FINITE(temp_VTpav.Y) EQ 0)
testa          = (dn_n_a GT thrsh_a[0]) OR (dVT_VT_a GT thrsh_a[1]) OR $
                 (FINITE(temp_na.Y) EQ 0) OR (FINITE(temp_VTaav.Y) EQ 0)
bad_swe_p      = WHERE(testp,bd_swe_p,COMPLEMENT=good_swe_p,NCOMPLEMENT=gd_swe_p)
bad_swe_a      = WHERE(testa,bd_swe_a,COMPLEMENT=good_swe_a,NCOMPLEMENT=gd_swe_a)
;;  Clean up
dumb           = TEMPORARY(testp)
dumb           = TEMPORARY(testa)
dumb           = TEMPORARY(dn_n_p)
dumb           = TEMPORARY(dn_n_a)
dumb           = TEMPORARY(dVT_VT_p)
dumb           = TEMPORARY(dVT_VT_a)
;;----------------------------------------------------------------------------------------
;;  Define "good" SWE structures
;;----------------------------------------------------------------------------------------
unix           = t_get_struc_unix(temp_Vp)
punx           = unix[good_swe_p]
aunx           = unix[good_swe_a]
gstr_Tp_all    = {X:punx,Y:temp_Tp_all.Y[good_swe_p,*]}
gstr_Ta_all    = {X:aunx,Y:temp_Ta_all.Y[good_swe_a,*]}
gstr_Vp        = {X:punx,Y:    temp_Vp.Y[good_swe_p,*]}
gstr_Va        = {X:aunx,Y:    temp_Va.Y[good_swe_a,*]}
gstr_Np        = {X:punx,Y:    temp_np.Y[good_swe_p]}
gstr_Na        = {X:aunx,Y:    temp_na.Y[good_swe_a]}
;;----------------------------------------------------------------------------------------
;;  Define "bad" 3DP times
;;----------------------------------------------------------------------------------------
;;  Assign "bad" to:
;;    QF < 5
test           = (temp_QF.Y LT 5) OR (FINITE(temp_QF.Y) EQ 0)
bad_3dp        = WHERE(test,bd_3dp,COMPLEMENT=good_3dp,NCOMPLEMENT=gd_3dp)
IF (gd_3dp[0] EQ 0) THEN STOP
;;----------------------------------------------------------------------------------------
;;  Get Rankine-Hugoniot results, if available
;;----------------------------------------------------------------------------------------
test_bst       = read_shocks_jck_database_new(/CFA_METH_ONLY,GIND_3D=gind_3d_bst)
;;  Define internal structures
gen_info_str   = test_bst.GEN_INFO
;;  Define general info
tdates_bst     = gen_info_str.TDATES
tura_all       = gen_info_str.ARRT_UNIX.Y

;;  Define 3DP Unix times
new_t          = t_get_struc_unix(temp_ne)
new_t1         = new_t[good_3dp]
;;  Limit array to data interval
bad_sh         = WHERE(tura_all GT MAX(new_t,/NAN),bd_sh,COMPLEMENT=good_sh,NCOMPLEMENT=gd_sh)
IF (gd_sh[0] EQ 0) THEN STOP
good_tura      = tura_all[good_sh]
;;  Define "bad" time ranges as:
;;    Start:  Shock Arrival - 5 hours
;;    End  :  Shock Arrival + 1 day
tfacs          = [-5d0*36d2,864d2]
bad_tst        = good_tura + tfacs[0]
bad_ten        = good_tura + tfacs[1]
bad_tra        = [[bad_tst],[bad_ten]]
;;  Clean up
DELVAR,temp_all,temp_3dp
;;  Determine "bad" time elements
n_bad          = N_ELEMENTS(bad_tst)
FOR j=0L, n_bad[0] - 1L DO BEGIN                                                                          $
  test_new_all   = (new_t GE bad_tra[j,0]) AND (new_t LE bad_tra[j,1])                                  & $
  test_new_3dp   = (new_t1 GE bad_tra[j,0]) AND (new_t1 LE bad_tra[j,1])                                & $
  bad_all0       = WHERE(test_new_all,bd_all0,COMPLEMENT=good_all0,NCOMPLEMENT=gd_all0)                 & $
  bad_3dp0       = WHERE(test_new_3dp,bd_3dp0,COMPLEMENT=good_3dp0,NCOMPLEMENT=gd_3dp0)                 & $
  IF (bd_all0[0] GT 0) THEN IF (j EQ 0) THEN temp_all = bad_all0 ELSE temp_all = [temp_all,bad_all0]    & $
  IF (bd_3dp0[0] GT 0) THEN IF (j EQ 0) THEN temp_3dp = bad_3dp0 ELSE temp_3dp = [temp_3dp,bad_3dp0]

DELVAR,bad_all0,bad_3dp0
l0             = LINDGEN(N_ELEMENTS(new_t))
l1             = LINDGEN(N_ELEMENTS(new_t1))
IF (N_ELEMENTS(temp_all) GT 0) THEN unqa = UNIQ(temp_all,SORT(temp_all))
IF (N_ELEMENTS(temp_3dp) GT 0) THEN unq3 = UNIQ(temp_3dp,SORT(temp_3dp))
IF (N_ELEMENTS(temp_all) GT 0) THEN bad_all0 = temp_all[unqa]
IF (N_ELEMENTS(temp_3dp) GT 0) THEN bad_3dp0 = temp_3dp[unq3]
IF (N_ELEMENTS(bad_all0) GT 0) THEN good_all0 = cgsetdifference(l0,bad_all0,SUCCESS=success)   ;;  Find elements in L0 that are NOT in TEMP_ALL
IF (N_ELEMENTS(bad_3dp0) GT 0) THEN good_3dp0 = cgsetdifference(l1,bad_3dp0,SUCCESS=success)   ;;  Find elements in L1 that are NOT in TEMP_3DP
IF (N_ELEMENTS(bad_all0) GT 0) THEN good_new_all = good_all0
IF (N_ELEMENTS(bad_3dp0) GT 0) THEN good_new_3dp = good_3dp0
;;  Clean up
DELVAR,temp_all,temp_3dp,bad_all0,bad_3dp0,good_all0,good_3dp0
;;----------------------------------------------------------------------------------------
;;  Get Magnetic Obstacle (MO) start/end times
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/wind_mo_start_times_and_durations_batch.pro

;;  Limit array to data interval
bad_mo         = WHERE(mo_tstart_unix GT MAX(new_t,/NAN),bd_mo,COMPLEMENT=good_mo,NCOMPLEMENT=gd_mo)
IF (gd_mo[0] EQ 0) THEN STOP
good_mo_sunix  = mo_tstart_unix[good_mo]
good_mo_eunix  = mo_t__end_unix[good_mo]
mo_tran        = [[good_mo_sunix],[good_mo_eunix]]
;;  Clean up
DELVAR,temp_all,temp_3dp
;;  Determine "bad" time elements
n_mo           = N_ELEMENTS(good_mo_sunix)
FOR j=0L, n_mo[0] - 1L DO BEGIN                                                                          $
  test_new_all   = (new_t GE mo_tran[j,0]) AND (new_t LE mo_tran[j,1])                                  & $
  test_new_3dp   = (new_t1 GE mo_tran[j,0]) AND (new_t1 LE mo_tran[j,1])                                & $
  bad_all0       = WHERE(test_new_all,bd_all0,COMPLEMENT=good_all0,NCOMPLEMENT=gd_all0)                 & $
  bad_3dp0       = WHERE(test_new_3dp,bd_3dp0,COMPLEMENT=good_3dp0,NCOMPLEMENT=gd_3dp0)                 & $
  IF (bd_all0[0] GT 0) THEN IF (j EQ 0) THEN temp_all = bad_all0 ELSE temp_all = [temp_all,bad_all0]    & $
  IF (bd_3dp0[0] GT 0) THEN IF (j EQ 0) THEN temp_3dp = bad_3dp0 ELSE temp_3dp = [temp_3dp,bad_3dp0]
;;  Clean up
DELVAR,bad_all0,bad_3dp0
l0             = LINDGEN(N_ELEMENTS(new_t))
l1             = LINDGEN(N_ELEMENTS(new_t1))
IF (N_ELEMENTS(temp_all) GT 0) THEN unqa = UNIQ(temp_all,SORT(temp_all))
IF (N_ELEMENTS(temp_3dp) GT 0) THEN unq3 = UNIQ(temp_3dp,SORT(temp_3dp))
IF (N_ELEMENTS(temp_all) GT 0) THEN in__mo_all = temp_all[unqa]
IF (N_ELEMENTS(temp_3dp) GT 0) THEN in__mo_3dp = temp_3dp[unq3]
IF (N_ELEMENTS(in__mo_all) GT 0) THEN good_all0  = cgsetdifference(l0,in__mo_all,SUCCESS=success)   ;;  Find elements in L0 that are NOT in OUT_MO_ALL
IF (N_ELEMENTS(in__mo_3dp) GT 0) THEN good_3dp0  = cgsetdifference(l1,in__mo_3dp,SUCCESS=success)   ;;  Find elements in L1 that are NOT in OUT_MO_3DP
IF (N_ELEMENTS(good_all0) GT 0) THEN out_mo_all = good_all0
IF (N_ELEMENTS(good_3dp0) GT 0) THEN out_mo_3dp = good_3dp0
;;  Clean up
DELVAR,temp_all,temp_3dp,bad_all0,bad_3dp0,good_all0,good_3dp0
;;----------------------------------------------------------------------------------------
;;  Resample MFI to SWE and 3DP times
;;----------------------------------------------------------------------------------------
;;  Interpolate to 3DP times
new_t          = t_get_struc_unix(temp_ne)
new_t1         = new_t[good_3dp]
t_bo_all_3dp   = t_resample_tplot_struc(temp_Bo,    new_t,/NO_EXTRAPOLATE,/IGNORE_INT)
t_bo__gd_3dp   = t_resample_tplot_struc(temp_Bo,    new_t1,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Interpolate to SWE times
swe_t          = t_get_struc_unix(temp_Vp)
t_bo_all_swe   = t_resample_tplot_struc(temp_Bo,    swe_t,/NO_EXTRAPOLATE,/IGNORE_INT)
t_bo_gd_swep   = t_resample_tplot_struc(temp_Bo,    punx ,/NO_EXTRAPOLATE,/IGNORE_INT)
t_bo_gd_swea   = t_resample_tplot_struc(temp_Bo,    aunx ,/NO_EXTRAPOLATE,/IGNORE_INT)
;;----------------------------------------------------------------------------------------
;;  Resample SWE to 3DP times
;;----------------------------------------------------------------------------------------
;;  Interpolate ALL SWE to ALL 3DP times
new_t          = t_get_struc_unix(temp_ne)
t_np_all_all   = t_resample_tplot_struc(temp_np,    new_t,/NO_EXTRAPOLATE,/IGNORE_INT)
t_na_all_all   = t_resample_tplot_struc(temp_na,    new_t,/NO_EXTRAPOLATE,/IGNORE_INT)
t_Tp_all_all   = t_resample_tplot_struc(temp_Tp_all,new_t,/NO_EXTRAPOLATE,/IGNORE_INT)
t_Ta_all_all   = t_resample_tplot_struc(temp_Ta_all,new_t,/NO_EXTRAPOLATE,/IGNORE_INT)
t_Vp_all_all   = t_resample_tplot_struc(temp_Vp,    new_t,/NO_EXTRAPOLATE,/IGNORE_INT)
t_Va_all_all   = t_resample_tplot_struc(temp_Va,    new_t,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Interpolate to only good 3DP times
new_t1         = new_t[good_3dp]
f_np_all_3dp   = t_resample_tplot_struc(temp_np,    new_t1,/NO_EXTRAPOLATE,/IGNORE_INT)
f_na_all_3dp   = t_resample_tplot_struc(temp_na,    new_t1,/NO_EXTRAPOLATE,/IGNORE_INT)
f_Tp_all_3dp   = t_resample_tplot_struc(temp_Tp_all,new_t1,/NO_EXTRAPOLATE,/IGNORE_INT)
f_Ta_all_3dp   = t_resample_tplot_struc(temp_Ta_all,new_t1,/NO_EXTRAPOLATE,/IGNORE_INT)
f_Vp_all_3dp   = t_resample_tplot_struc(temp_Vp,    new_t1,/NO_EXTRAPOLATE,/IGNORE_INT)
f_Va_all_3dp   = t_resample_tplot_struc(temp_Va,    new_t1,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Interpolate only good SWE to ALL 3DP times
f_np_swe_all   = t_resample_tplot_struc(gstr_np,    new_t,/NO_EXTRAPOLATE,/IGNORE_INT)
f_na_swe_all   = t_resample_tplot_struc(gstr_na,    new_t,/NO_EXTRAPOLATE,/IGNORE_INT)
f_Tp_swe_all   = t_resample_tplot_struc(gstr_Tp_all,new_t,/NO_EXTRAPOLATE,/IGNORE_INT)
f_Ta_swe_all   = t_resample_tplot_struc(gstr_Ta_all,new_t,/NO_EXTRAPOLATE,/IGNORE_INT)
f_Vp_swe_all   = t_resample_tplot_struc(gstr_Vp,    new_t,/NO_EXTRAPOLATE,/IGNORE_INT)
f_Va_swe_all   = t_resample_tplot_struc(gstr_Va,    new_t,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Interpolate only good SWE to only good 3DP times
f_np_swe_3dp   = t_resample_tplot_struc(gstr_np,    new_t1,/NO_EXTRAPOLATE,/IGNORE_INT)
f_na_swe_3dp   = t_resample_tplot_struc(gstr_na,    new_t1,/NO_EXTRAPOLATE,/IGNORE_INT)
f_Tp_swe_3dp   = t_resample_tplot_struc(gstr_Tp_all,new_t1,/NO_EXTRAPOLATE,/IGNORE_INT)
f_Ta_swe_3dp   = t_resample_tplot_struc(gstr_Ta_all,new_t1,/NO_EXTRAPOLATE,/IGNORE_INT)
f_Vp_swe_3dp   = t_resample_tplot_struc(gstr_Vp,    new_t1,/NO_EXTRAPOLATE,/IGNORE_INT)
f_Va_swe_3dp   = t_resample_tplot_struc(gstr_Va,    new_t1,/NO_EXTRAPOLATE,/IGNORE_INT)
;;----------------------------------------------------------------------------------------
;;  Resample SWE to 3DP times
;;----------------------------------------------------------------------------------------
;;  Interpolate ALL SWE to ALL 3DP times [without IP shocks]
new_t_sh       = new_t[good_new_all]
sh_np_all_all  = t_resample_tplot_struc(temp_np,    new_t_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_na_all_all  = t_resample_tplot_struc(temp_na,    new_t_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Tp_all_all  = t_resample_tplot_struc(temp_Tp_all,new_t_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Ta_all_all  = t_resample_tplot_struc(temp_Ta_all,new_t_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Vp_all_all  = t_resample_tplot_struc(temp_Vp,    new_t_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Va_all_all  = t_resample_tplot_struc(temp_Va,    new_t_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Interpolate to only good 3DP times [without IP shocks]
new_t1_sh      = new_t1[good_new_3dp]
sh_np_all_3dp  = t_resample_tplot_struc(temp_np,    new_t1_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_na_all_3dp  = t_resample_tplot_struc(temp_na,    new_t1_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Tp_all_3dp  = t_resample_tplot_struc(temp_Tp_all,new_t1_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Ta_all_3dp  = t_resample_tplot_struc(temp_Ta_all,new_t1_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Vp_all_3dp  = t_resample_tplot_struc(temp_Vp,    new_t1_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Va_all_3dp  = t_resample_tplot_struc(temp_Va,    new_t1_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Interpolate only good SWE to ALL 3DP times [without IP shocks]
sh_np_swe_all  = t_resample_tplot_struc(gstr_np,    new_t_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_na_swe_all  = t_resample_tplot_struc(gstr_na,    new_t_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Tp_swe_all  = t_resample_tplot_struc(gstr_Tp_all,new_t_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Ta_swe_all  = t_resample_tplot_struc(gstr_Ta_all,new_t_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Vp_swe_all  = t_resample_tplot_struc(gstr_Vp,    new_t_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Va_swe_all  = t_resample_tplot_struc(gstr_Va,    new_t_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Interpolate only good SWE to only good 3DP times [without IP shocks]
sh_np_swe_3dp  = t_resample_tplot_struc(gstr_np,    new_t1_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_na_swe_3dp  = t_resample_tplot_struc(gstr_na,    new_t1_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Tp_swe_3dp  = t_resample_tplot_struc(gstr_Tp_all,new_t1_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Ta_swe_3dp  = t_resample_tplot_struc(gstr_Ta_all,new_t1_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Vp_swe_3dp  = t_resample_tplot_struc(gstr_Vp,    new_t1_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_Va_swe_3dp  = t_resample_tplot_struc(gstr_Va,    new_t1_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Interpolate MFI to 3DP times
sh_bo_all_3dp  = t_resample_tplot_struc(temp_Bo,    new_t_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
sh_bo__gd_3dp  = t_resample_tplot_struc(temp_Bo,    new_t1_sh,/NO_EXTRAPOLATE,/IGNORE_INT)
;;----------------------------------------------------------------------------------------
;;  Resample SWE to 3DP times
;;----------------------------------------------------------------------------------------
;;  Define time stamps for inside/outside of MO
new_t_in       = new_t[in__mo_all]
new_t_ot       = new_t[out_mo_all]
new_t1_in      = new_t1[in__mo_3dp]
new_t1_ot      = new_t1[out_mo_3dp]
;;  Interpolate MFI to 3DP times
in_bo_all_3dp  = t_resample_tplot_struc(temp_Bo,    new_t_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_bo__gd_3dp  = t_resample_tplot_struc(temp_Bo,    new_t1_in,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_bo_all_3dp  = t_resample_tplot_struc(temp_Bo,    new_t_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_bo__gd_3dp  = t_resample_tplot_struc(temp_Bo,    new_t1_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Interpolate ALL SWE to ALL 3DP times [inside/outside of MO]
in_np_all_all  = t_resample_tplot_struc(temp_np,    new_t_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_na_all_all  = t_resample_tplot_struc(temp_na,    new_t_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Tp_all_all  = t_resample_tplot_struc(temp_Tp_all,new_t_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Ta_all_all  = t_resample_tplot_struc(temp_Ta_all,new_t_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Vp_all_all  = t_resample_tplot_struc(temp_Vp,    new_t_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Va_all_all  = t_resample_tplot_struc(temp_Va,    new_t_in,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_np_all_all  = t_resample_tplot_struc(temp_np,    new_t_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_na_all_all  = t_resample_tplot_struc(temp_na,    new_t_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Tp_all_all  = t_resample_tplot_struc(temp_Tp_all,new_t_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Ta_all_all  = t_resample_tplot_struc(temp_Ta_all,new_t_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Vp_all_all  = t_resample_tplot_struc(temp_Vp,    new_t_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Va_all_all  = t_resample_tplot_struc(temp_Va,    new_t_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Interpolate only good SWE to ALL 3DP times [inside/outside of MO]
in_np_swe_all  = t_resample_tplot_struc(gstr_np,    new_t_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_na_swe_all  = t_resample_tplot_struc(gstr_na,    new_t_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Tp_swe_all  = t_resample_tplot_struc(gstr_Tp_all,new_t_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Ta_swe_all  = t_resample_tplot_struc(gstr_Ta_all,new_t_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Vp_swe_all  = t_resample_tplot_struc(gstr_Vp,    new_t_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Va_swe_all  = t_resample_tplot_struc(gstr_Va,    new_t_in,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_np_swe_all  = t_resample_tplot_struc(gstr_np,    new_t_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_na_swe_all  = t_resample_tplot_struc(gstr_na,    new_t_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Tp_swe_all  = t_resample_tplot_struc(gstr_Tp_all,new_t_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Ta_swe_all  = t_resample_tplot_struc(gstr_Ta_all,new_t_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Vp_swe_all  = t_resample_tplot_struc(gstr_Vp,    new_t_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Va_swe_all  = t_resample_tplot_struc(gstr_Va,    new_t_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Interpolate to only good 3DP times [inside/outside of MO]
in_np_all_3dp  = t_resample_tplot_struc(temp_np,    new_t1_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_na_all_3dp  = t_resample_tplot_struc(temp_na,    new_t1_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Tp_all_3dp  = t_resample_tplot_struc(temp_Tp_all,new_t1_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Ta_all_3dp  = t_resample_tplot_struc(temp_Ta_all,new_t1_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Vp_all_3dp  = t_resample_tplot_struc(temp_Vp,    new_t1_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Va_all_3dp  = t_resample_tplot_struc(temp_Va,    new_t1_in,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_np_all_3dp  = t_resample_tplot_struc(temp_np,    new_t1_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_na_all_3dp  = t_resample_tplot_struc(temp_na,    new_t1_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Tp_all_3dp  = t_resample_tplot_struc(temp_Tp_all,new_t1_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Ta_all_3dp  = t_resample_tplot_struc(temp_Ta_all,new_t1_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Vp_all_3dp  = t_resample_tplot_struc(temp_Vp,    new_t1_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Va_all_3dp  = t_resample_tplot_struc(temp_Va,    new_t1_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Interpolate only good SWE to only good 3DP times [without IP shocks]
in_np_swe_3dp  = t_resample_tplot_struc(gstr_np,    new_t1_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_na_swe_3dp  = t_resample_tplot_struc(gstr_na,    new_t1_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Tp_swe_3dp  = t_resample_tplot_struc(gstr_Tp_all,new_t1_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Ta_swe_3dp  = t_resample_tplot_struc(gstr_Ta_all,new_t1_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Vp_swe_3dp  = t_resample_tplot_struc(gstr_Vp,    new_t1_in,/NO_EXTRAPOLATE,/IGNORE_INT)
in_Va_swe_3dp  = t_resample_tplot_struc(gstr_Va,    new_t1_in,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_np_swe_3dp  = t_resample_tplot_struc(gstr_np,    new_t1_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_na_swe_3dp  = t_resample_tplot_struc(gstr_na,    new_t1_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Tp_swe_3dp  = t_resample_tplot_struc(gstr_Tp_all,new_t1_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Ta_swe_3dp  = t_resample_tplot_struc(gstr_Ta_all,new_t1_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Vp_swe_3dp  = t_resample_tplot_struc(gstr_Vp,    new_t1_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
ot_Va_swe_3dp  = t_resample_tplot_struc(gstr_Va,    new_t1_ot,/NO_EXTRAPOLATE,/IGNORE_INT)
;;----------------------------------------------------------------------------------------
;;  Define beta_s
;;----------------------------------------------------------------------------------------
beta_fac       = 2d0*muo[0]*1d6*eV2J[0]/(1d-9^2)
bmag_all_3dp   = mag__vec(t_bo_all_3dp.Y[*,0:2],/NAN)
bmag__gd_3dp   = mag__vec(t_bo__gd_3dp.Y[*,0:2],/NAN)
bmag_all_swe   = mag__vec(t_bo_all_swe.Y[*,0:2],/NAN)
bmag_gd_swep   = mag__vec(t_bo_gd_swep.Y[*,0:2],/NAN)
bmag_gd_swea   = mag__vec(t_bo_gd_swea.Y[*,0:2],/NAN)
bmag__sh_aas   = mag__vec(sh_bo_all_3dp.Y[*,0:2],/NAN)
bmag__sh_a3s   = mag__vec(sh_bo__gd_3dp.Y[*,0:2],/NAN)
bmag__in_all   = mag__vec(in_bo_all_3dp.Y[*,0:2],/NAN)
bmag__ot_all   = mag__vec(ot_bo_all_3dp.Y[*,0:2],/NAN)
bmag__in_3dp   = mag__vec(in_bo__gd_3dp.Y[*,0:2],/NAN)
bmag__ot_3dp   = mag__vec(ot_bo__gd_3dp.Y[*,0:2],/NAN)
;;  ALL 3DP
beta_eavg_all  = beta_fac[0]*temp_Tet.Y     /bmag_all_3dp^2d0
beta_eper_all  = beta_fac[0]*temp_Teb.Y[*,1]/bmag_all_3dp^2d0
beta_epar_all  = beta_fac[0]*temp_Teb.Y[*,0]/bmag_all_3dp^2d0
;;  Only good 3DP
good           = good_3dp
beta_eavg_3dp  = beta_fac[0]*temp_Tet.Y[good]  /bmag__gd_3dp^2d0
beta_eper_3dp  = beta_fac[0]*temp_Teb.Y[good,1]/bmag__gd_3dp^2d0
beta_epar_3dp  = beta_fac[0]*temp_Teb.Y[good,0]/bmag__gd_3dp^2d0
;;  With and without shocks
good           = good_new_all
beta_eavg_aas  = beta_fac[0]*temp_Tet.Y[good]  /bmag__sh_aas^2d0
beta_eper_aas  = beta_fac[0]*temp_Teb.Y[good,1]/bmag__sh_aas^2d0
beta_epar_aas  = beta_fac[0]*temp_Teb.Y[good,0]/bmag__sh_aas^2d0
good           = good_new_3dp
beta_eavg_a3s  = beta_fac[0]*temp_Tet.Y[good]  /bmag__sh_a3s^2d0
beta_eper_a3s  = beta_fac[0]*temp_Teb.Y[good,1]/bmag__sh_a3s^2d0
beta_epar_a3s  = beta_fac[0]*temp_Teb.Y[good,0]/bmag__sh_a3s^2d0
;;  Inside/Outside of MOs
good0          = in__mo_all
good1          = in__mo_3dp
beta_eavg_aaio = beta_fac[0]*temp_Tet.Y[good0]  /bmag__in_all^2d0
beta_eper_aaio = beta_fac[0]*temp_Teb.Y[good0,1]/bmag__in_all^2d0
beta_epar_aaio = beta_fac[0]*temp_Teb.Y[good0,0]/bmag__in_all^2d0
beta_eavg_a3io = beta_fac[0]*temp_Tet.Y[good1]  /bmag__in_3dp^2d0
beta_eper_a3io = beta_fac[0]*temp_Teb.Y[good1,1]/bmag__in_3dp^2d0
beta_epar_a3io = beta_fac[0]*temp_Teb.Y[good1,0]/bmag__in_3dp^2d0
good0          = out_mo_all
good1          = out_mo_3dp
beta_eavg_aaoo = beta_fac[0]*temp_Tet.Y[good0]  /bmag__ot_all^2d0
beta_eper_aaoo = beta_fac[0]*temp_Teb.Y[good0,1]/bmag__ot_all^2d0
beta_epar_aaoo = beta_fac[0]*temp_Teb.Y[good0,0]/bmag__ot_all^2d0
beta_eavg_a3oo = beta_fac[0]*temp_Tet.Y[good1]  /bmag__ot_3dp^2d0
beta_eper_a3oo = beta_fac[0]*temp_Teb.Y[good1,1]/bmag__ot_3dp^2d0
beta_epar_a3oo = beta_fac[0]*temp_Teb.Y[good1,0]/bmag__ot_3dp^2d0
;;  ALL SWE
beta_pavg_all  = beta_fac[0]*temp_Tp_all.Y[*,0]/bmag_all_swe^2d0
beta_pper_all  = beta_fac[0]*temp_Tp_all.Y[*,1]/bmag_all_swe^2d0
beta_ppar_all  = beta_fac[0]*temp_Tp_all.Y[*,2]/bmag_all_swe^2d0
beta_aavg_all  = beta_fac[0]*temp_Ta_all.Y[*,0]/bmag_all_swe^2d0
beta_aper_all  = beta_fac[0]*temp_Ta_all.Y[*,1]/bmag_all_swe^2d0
beta_apar_all  = beta_fac[0]*temp_Ta_all.Y[*,2]/bmag_all_swe^2d0
;;  ALL SWE and only good 3DP [including shocks]
beta_pavg_a3n  = beta_fac[0]*f_Tp_all_3dp.Y[*,0]/bmag__gd_3dp^2d0
beta_pper_a3n  = beta_fac[0]*f_Tp_all_3dp.Y[*,1]/bmag__gd_3dp^2d0
beta_ppar_a3n  = beta_fac[0]*f_Tp_all_3dp.Y[*,2]/bmag__gd_3dp^2d0
beta_aavg_a3n  = beta_fac[0]*f_Ta_all_3dp.Y[*,0]/bmag__gd_3dp^2d0
beta_aper_a3n  = beta_fac[0]*f_Ta_all_3dp.Y[*,1]/bmag__gd_3dp^2d0
beta_apar_a3n  = beta_fac[0]*f_Ta_all_3dp.Y[*,2]/bmag__gd_3dp^2d0
;;  Only good SWE
beta_pavg_gsp  = beta_fac[0]*gstr_Tp_all.Y[*,0]/bmag_gd_swep^2d0
beta_pper_gsp  = beta_fac[0]*gstr_Tp_all.Y[*,1]/bmag_gd_swep^2d0
beta_ppar_gsp  = beta_fac[0]*gstr_Tp_all.Y[*,2]/bmag_gd_swep^2d0
beta_aavg_gsp  = beta_fac[0]*gstr_Ta_all.Y[*,0]/bmag_gd_swea^2d0
beta_aper_gsp  = beta_fac[0]*gstr_Ta_all.Y[*,1]/bmag_gd_swea^2d0
beta_apar_gsp  = beta_fac[0]*gstr_Ta_all.Y[*,2]/bmag_gd_swea^2d0
;;  Only good SWE and only good 3DP [including shocks]
beta_pavg_s3n  = beta_fac[0]*f_Tp_swe_3dp.Y[*,0]/bmag__gd_3dp^2d0
beta_pper_s3n  = beta_fac[0]*f_Tp_swe_3dp.Y[*,1]/bmag__gd_3dp^2d0
beta_ppar_s3n  = beta_fac[0]*f_Tp_swe_3dp.Y[*,2]/bmag__gd_3dp^2d0
beta_aavg_s3n  = beta_fac[0]*f_Ta_swe_3dp.Y[*,0]/bmag__gd_3dp^2d0
beta_aper_s3n  = beta_fac[0]*f_Ta_swe_3dp.Y[*,1]/bmag__gd_3dp^2d0
beta_apar_s3n  = beta_fac[0]*f_Ta_swe_3dp.Y[*,2]/bmag__gd_3dp^2d0
;;  ALL SWE and ALL 3DP without shocks
beta_pavg_aas  = beta_fac[0]*sh_Tp_all_all.Y[*,0]/bmag__sh_aas^2d0
beta_pper_aas  = beta_fac[0]*sh_Tp_all_all.Y[*,1]/bmag__sh_aas^2d0
beta_ppar_aas  = beta_fac[0]*sh_Tp_all_all.Y[*,2]/bmag__sh_aas^2d0
beta_aavg_aas  = beta_fac[0]*sh_Ta_all_all.Y[*,0]/bmag__sh_aas^2d0
beta_aper_aas  = beta_fac[0]*sh_Ta_all_all.Y[*,1]/bmag__sh_aas^2d0
beta_apar_aas  = beta_fac[0]*sh_Ta_all_all.Y[*,2]/bmag__sh_aas^2d0
beta_pavg_a3s  = beta_fac[0]*sh_Tp_all_3dp.Y[*,0]/bmag__sh_a3s^2d0
beta_pper_a3s  = beta_fac[0]*sh_Tp_all_3dp.Y[*,1]/bmag__sh_a3s^2d0
beta_ppar_a3s  = beta_fac[0]*sh_Tp_all_3dp.Y[*,2]/bmag__sh_a3s^2d0
beta_aavg_a3s  = beta_fac[0]*sh_Ta_all_3dp.Y[*,0]/bmag__sh_a3s^2d0
beta_aper_a3s  = beta_fac[0]*sh_Ta_all_3dp.Y[*,1]/bmag__sh_a3s^2d0
beta_apar_a3s  = beta_fac[0]*sh_Ta_all_3dp.Y[*,2]/bmag__sh_a3s^2d0
;;  Only good SWE and ALL 3DP without shocks
beta_pavg_sas  = beta_fac[0]*sh_Tp_swe_all.Y[*,0]/bmag__sh_aas^2d0
beta_pper_sas  = beta_fac[0]*sh_Tp_swe_all.Y[*,1]/bmag__sh_aas^2d0
beta_ppar_sas  = beta_fac[0]*sh_Tp_swe_all.Y[*,2]/bmag__sh_aas^2d0
beta_aavg_sas  = beta_fac[0]*sh_Ta_swe_all.Y[*,0]/bmag__sh_aas^2d0
beta_aper_sas  = beta_fac[0]*sh_Ta_swe_all.Y[*,1]/bmag__sh_aas^2d0
beta_apar_sas  = beta_fac[0]*sh_Ta_swe_all.Y[*,2]/bmag__sh_aas^2d0
;;  Only good SWE and only good 3DP without shocks
beta_pavg_s3s  = beta_fac[0]*sh_Tp_swe_3dp.Y[*,0]/bmag__sh_a3s^2d0
beta_pper_s3s  = beta_fac[0]*sh_Tp_swe_3dp.Y[*,1]/bmag__sh_a3s^2d0
beta_ppar_s3s  = beta_fac[0]*sh_Tp_swe_3dp.Y[*,2]/bmag__sh_a3s^2d0
beta_aavg_s3s  = beta_fac[0]*sh_Ta_swe_3dp.Y[*,0]/bmag__sh_a3s^2d0
beta_aper_s3s  = beta_fac[0]*sh_Ta_swe_3dp.Y[*,1]/bmag__sh_a3s^2d0
beta_apar_s3s  = beta_fac[0]*sh_Ta_swe_3dp.Y[*,2]/bmag__sh_a3s^2d0
;;  ALL SWE and only good 3DP [without shocks]
beta_pavg_a3s  = beta_fac[0]*sh_Tp_all_3dp.Y[*,0]/bmag__sh_a3s^2d0
beta_pper_a3s  = beta_fac[0]*sh_Tp_all_3dp.Y[*,1]/bmag__sh_a3s^2d0
beta_ppar_a3s  = beta_fac[0]*sh_Tp_all_3dp.Y[*,2]/bmag__sh_a3s^2d0
beta_aavg_a3s  = beta_fac[0]*sh_Ta_all_3dp.Y[*,0]/bmag__sh_a3s^2d0
beta_aper_a3s  = beta_fac[0]*sh_Ta_all_3dp.Y[*,1]/bmag__sh_a3s^2d0
beta_apar_a3s  = beta_fac[0]*sh_Ta_all_3dp.Y[*,2]/bmag__sh_a3s^2d0
;;  ALL SWE and ALL 3DP betas for inside of MOs
beta_pavg_aaio = beta_fac[0]*in_Tp_all_all.Y[*,0]/bmag__in_all^2d0
beta_pper_aaio = beta_fac[0]*in_Tp_all_all.Y[*,1]/bmag__in_all^2d0
beta_ppar_aaio = beta_fac[0]*in_Tp_all_all.Y[*,2]/bmag__in_all^2d0
beta_aavg_aaio = beta_fac[0]*in_Ta_all_all.Y[*,0]/bmag__in_all^2d0
beta_aper_aaio = beta_fac[0]*in_Ta_all_all.Y[*,1]/bmag__in_all^2d0
beta_apar_aaio = beta_fac[0]*in_Ta_all_all.Y[*,2]/bmag__in_all^2d0
;;  Only good SWE and ALL 3DP betas for inside of MOs
beta_pavg_saio = beta_fac[0]*in_Tp_swe_all.Y[*,0]/bmag__in_all^2d0
beta_pper_saio = beta_fac[0]*in_Tp_swe_all.Y[*,1]/bmag__in_all^2d0
beta_ppar_saio = beta_fac[0]*in_Tp_swe_all.Y[*,2]/bmag__in_all^2d0
beta_aavg_saio = beta_fac[0]*in_Ta_swe_all.Y[*,0]/bmag__in_all^2d0
beta_aper_saio = beta_fac[0]*in_Ta_swe_all.Y[*,1]/bmag__in_all^2d0
beta_apar_saio = beta_fac[0]*in_Ta_swe_all.Y[*,2]/bmag__in_all^2d0
;;  ALL SWE and only good 3DP betas for inside of MOs
beta_pavg_a3io = beta_fac[0]*in_Tp_all_3dp.Y[*,0]/bmag__in_3dp^2d0
beta_pper_a3io = beta_fac[0]*in_Tp_all_3dp.Y[*,1]/bmag__in_3dp^2d0
beta_ppar_a3io = beta_fac[0]*in_Tp_all_3dp.Y[*,2]/bmag__in_3dp^2d0
beta_aavg_a3io = beta_fac[0]*in_Ta_all_3dp.Y[*,0]/bmag__in_3dp^2d0
beta_aper_a3io = beta_fac[0]*in_Ta_all_3dp.Y[*,1]/bmag__in_3dp^2d0
beta_apar_a3io = beta_fac[0]*in_Ta_all_3dp.Y[*,2]/bmag__in_3dp^2d0
;;  Only good SWE and only good 3DP betas for inside of MOs
beta_pavg_s3io = beta_fac[0]*in_Tp_swe_3dp.Y[*,0]/bmag__in_3dp^2d0
beta_pper_s3io = beta_fac[0]*in_Tp_swe_3dp.Y[*,1]/bmag__in_3dp^2d0
beta_ppar_s3io = beta_fac[0]*in_Tp_swe_3dp.Y[*,2]/bmag__in_3dp^2d0
beta_aavg_s3io = beta_fac[0]*in_Ta_swe_3dp.Y[*,0]/bmag__in_3dp^2d0
beta_aper_s3io = beta_fac[0]*in_Ta_swe_3dp.Y[*,1]/bmag__in_3dp^2d0
beta_apar_s3io = beta_fac[0]*in_Ta_swe_3dp.Y[*,2]/bmag__in_3dp^2d0
;;  ALL SWE and ALL 3DP betas for outside of MOs
beta_pavg_aaoo = beta_fac[0]*ot_Tp_all_all.Y[*,0]/bmag__ot_all^2d0
beta_pper_aaoo = beta_fac[0]*ot_Tp_all_all.Y[*,1]/bmag__ot_all^2d0
beta_ppar_aaoo = beta_fac[0]*ot_Tp_all_all.Y[*,2]/bmag__ot_all^2d0
beta_aavg_aaoo = beta_fac[0]*ot_Ta_all_all.Y[*,0]/bmag__ot_all^2d0
beta_aper_aaoo = beta_fac[0]*ot_Ta_all_all.Y[*,1]/bmag__ot_all^2d0
beta_apar_aaoo = beta_fac[0]*ot_Ta_all_all.Y[*,2]/bmag__ot_all^2d0
;;  ALL SWE and only good 3DP betas for outside of MOs
beta_pavg_a3oo = beta_fac[0]*ot_Tp_all_3dp.Y[*,0]/bmag__ot_3dp^2d0
beta_pper_a3oo = beta_fac[0]*ot_Tp_all_3dp.Y[*,1]/bmag__ot_3dp^2d0
beta_ppar_a3oo = beta_fac[0]*ot_Tp_all_3dp.Y[*,2]/bmag__ot_3dp^2d0
beta_aavg_a3oo = beta_fac[0]*ot_Ta_all_3dp.Y[*,0]/bmag__ot_3dp^2d0
beta_aper_a3oo = beta_fac[0]*ot_Ta_all_3dp.Y[*,1]/bmag__ot_3dp^2d0
beta_apar_a3oo = beta_fac[0]*ot_Ta_all_3dp.Y[*,2]/bmag__ot_3dp^2d0
;;  Only good SWE and ALL 3DP betas for outside of MOs
beta_pavg_saoo = beta_fac[0]*ot_Tp_swe_all.Y[*,0]/bmag__ot_all^2d0
beta_pper_saoo = beta_fac[0]*ot_Tp_swe_all.Y[*,1]/bmag__ot_all^2d0
beta_ppar_saoo = beta_fac[0]*ot_Tp_swe_all.Y[*,2]/bmag__ot_all^2d0
beta_aavg_saoo = beta_fac[0]*ot_Ta_swe_all.Y[*,0]/bmag__ot_all^2d0
beta_aper_saoo = beta_fac[0]*ot_Ta_swe_all.Y[*,1]/bmag__ot_all^2d0
beta_apar_saoo = beta_fac[0]*ot_Ta_swe_all.Y[*,2]/bmag__ot_all^2d0
;;  Only good SWE and only good 3DP betas for outside of MOs
beta_pavg_s3oo = beta_fac[0]*ot_Tp_swe_3dp.Y[*,0]/bmag__ot_3dp^2d0
beta_pper_s3oo = beta_fac[0]*ot_Tp_swe_3dp.Y[*,1]/bmag__ot_3dp^2d0
beta_ppar_s3oo = beta_fac[0]*ot_Tp_swe_3dp.Y[*,2]/bmag__ot_3dp^2d0
beta_aavg_s3oo = beta_fac[0]*ot_Ta_swe_3dp.Y[*,0]/bmag__ot_3dp^2d0
beta_aper_s3oo = beta_fac[0]*ot_Ta_swe_3dp.Y[*,1]/bmag__ot_3dp^2d0
beta_apar_s3oo = beta_fac[0]*ot_Ta_swe_3dp.Y[*,2]/bmag__ot_3dp^2d0
;;  Clean up
DELVAR,bmag_all_3dp,bmag__gd_3dp,bmag_all_swe,bmag_gd_swep,bmag_gd_swea,bmag__sh_aas,bmag__sh_a3s,bmag__in_all,bmag__ot_all,bmag__in_3dp,bmag__ot_3dp
;;----------------------------------------------------------------------------------------
;;  Define (Ts/Te)_tot, (Ts/Te)_perp, and (Ts/Te)_para ratios
;;----------------------------------------------------------------------------------------
good           = good_3dp
;;  ALL SWE and ALL 3DP times including shocks
Te_Tp_avg_aan  = temp_Tet.Y     /t_Tp_all_all.Y[*,0]
Te_Tp_per_aan  = temp_Teb.Y[*,1]/t_Tp_all_all.Y[*,1]
Te_Tp_par_aan  = temp_Teb.Y[*,0]/t_Tp_all_all.Y[*,2]
Te_Ta_avg_aan  = temp_Tet.Y     /t_Ta_all_all.Y[*,0]
Te_Ta_per_aan  = temp_Teb.Y[*,1]/t_Ta_all_all.Y[*,1]
Te_Ta_par_aan  = temp_Teb.Y[*,0]/t_Ta_all_all.Y[*,2]
;;  ALL SWE and only good 3DP times including shocks
Te_Tp_avg_a3n  = temp_Tet.Y[good]  /f_Tp_all_3dp.Y[*,0]
Te_Tp_per_a3n  = temp_Teb.Y[good,1]/f_Tp_all_3dp.Y[*,1]
Te_Tp_par_a3n  = temp_Teb.Y[good,0]/f_Tp_all_3dp.Y[*,2]
Te_Ta_avg_a3n  = temp_Tet.Y[good]  /f_Ta_all_3dp.Y[*,0]
Te_Ta_per_a3n  = temp_Teb.Y[good,1]/f_Ta_all_3dp.Y[*,1]
Te_Ta_par_a3n  = temp_Teb.Y[good,0]/f_Ta_all_3dp.Y[*,2]
;;  Only good SWE and ALL 3DP times including shocks
Te_Tp_avg_san  = temp_Tet.Y     /f_Tp_swe_all.Y[*,0]
Te_Tp_per_san  = temp_Teb.Y[*,1]/f_Tp_swe_all.Y[*,1]
Te_Tp_par_san  = temp_Teb.Y[*,0]/f_Tp_swe_all.Y[*,2]
Te_Ta_avg_san  = temp_Tet.Y     /f_Ta_swe_all.Y[*,0]
Te_Ta_per_san  = temp_Teb.Y[*,1]/f_Ta_swe_all.Y[*,1]
Te_Ta_par_san  = temp_Teb.Y[*,0]/f_Ta_swe_all.Y[*,2]
;;  Only good SWE and only good 3DP times including shocks
Te_Tp_avg_s3n  = temp_Tet.Y[good]  /f_Tp_swe_3dp.Y[*,0]
Te_Tp_per_s3n  = temp_Teb.Y[good,1]/f_Tp_swe_3dp.Y[*,1]
Te_Tp_par_s3n  = temp_Teb.Y[good,0]/f_Tp_swe_3dp.Y[*,2]
Te_Ta_avg_s3n  = temp_Tet.Y[good]  /f_Ta_swe_3dp.Y[*,0]
Te_Ta_per_s3n  = temp_Teb.Y[good,1]/f_Ta_swe_3dp.Y[*,1]
Te_Ta_par_s3n  = temp_Teb.Y[good,0]/f_Ta_swe_3dp.Y[*,2]
;;  **********************
;;  ***  No IP Shocks  ***
;;  **********************
good0          = good_new_all
good1          = good_new_3dp
;;  ALL SWE and ALL 3DP times without shocks
Te_Tp_avg_aas  = temp_Tet.Y[good0]  /sh_Tp_all_all.Y[*,0]
Te_Tp_per_aas  = temp_Teb.Y[good0,1]/sh_Tp_all_all.Y[*,1]
Te_Tp_par_aas  = temp_Teb.Y[good0,0]/sh_Tp_all_all.Y[*,2]
Te_Ta_avg_aas  = temp_Tet.Y[good0]  /sh_Ta_all_all.Y[*,0]
Te_Ta_per_aas  = temp_Teb.Y[good0,1]/sh_Ta_all_all.Y[*,1]
Te_Ta_par_aas  = temp_Teb.Y[good0,0]/sh_Ta_all_all.Y[*,2]
;;  ALL SWE and only good 3DP times without shocks
Te_Tp_avg_a3s  = temp_Tet.Y[good1]  /sh_Tp_all_3dp.Y[*,0]
Te_Tp_per_a3s  = temp_Teb.Y[good1,1]/sh_Tp_all_3dp.Y[*,1]
Te_Tp_par_a3s  = temp_Teb.Y[good1,0]/sh_Tp_all_3dp.Y[*,2]
Te_Ta_avg_a3s  = temp_Tet.Y[good1]  /sh_Ta_all_3dp.Y[*,0]
Te_Ta_per_a3s  = temp_Teb.Y[good1,1]/sh_Ta_all_3dp.Y[*,1]
Te_Ta_par_a3s  = temp_Teb.Y[good1,0]/sh_Ta_all_3dp.Y[*,2]
;;  Only good SWE and ALL 3DP times without shocks
Te_Tp_avg_sas  = temp_Tet.Y[good0]  /sh_Tp_swe_all.Y[*,0]
Te_Tp_per_sas  = temp_Teb.Y[good0,1]/sh_Tp_swe_all.Y[*,1]
Te_Tp_par_sas  = temp_Teb.Y[good0,0]/sh_Tp_swe_all.Y[*,2]
Te_Ta_avg_sas  = temp_Tet.Y[good0]  /sh_Ta_swe_all.Y[*,0]
Te_Ta_per_sas  = temp_Teb.Y[good0,1]/sh_Ta_swe_all.Y[*,1]
Te_Ta_par_sas  = temp_Teb.Y[good0,0]/sh_Ta_swe_all.Y[*,2]
;;  Only good SWE and only good 3DP times without shocks
Te_Tp_avg_s3s  = temp_Tet.Y[good1]  /sh_Tp_swe_3dp.Y[*,0]
Te_Tp_per_s3s  = temp_Teb.Y[good1,1]/sh_Tp_swe_3dp.Y[*,1]
Te_Tp_par_s3s  = temp_Teb.Y[good1,0]/sh_Tp_swe_3dp.Y[*,2]
Te_Ta_avg_s3s  = temp_Tet.Y[good1]  /sh_Ta_swe_3dp.Y[*,0]
Te_Ta_per_s3s  = temp_Teb.Y[good1,1]/sh_Ta_swe_3dp.Y[*,1]
Te_Ta_par_s3s  = temp_Teb.Y[good1,0]/sh_Ta_swe_3dp.Y[*,2]
;;  *********************
;;  ***  Inside  MOs  ***
;;  *********************
good0          = in__mo_all
good1          = in__mo_3dp
;;  ALL SWE and ALL 3DP times inside of MO
Te_Tp_avg_aaio = temp_Tet.Y[good0]  /in_Tp_all_all.Y[*,0]
Te_Tp_per_aaio = temp_Teb.Y[good0,1]/in_Tp_all_all.Y[*,1]
Te_Tp_par_aaio = temp_Teb.Y[good0,0]/in_Tp_all_all.Y[*,2]
Te_Ta_avg_aaio = temp_Tet.Y[good0]  /in_Ta_all_all.Y[*,0]
Te_Ta_per_aaio = temp_Teb.Y[good0,1]/in_Ta_all_all.Y[*,1]
Te_Ta_par_aaio = temp_Teb.Y[good0,0]/in_Ta_all_all.Y[*,2]
;;  ALL SWE and only good 3DP times inside of MO
Te_Tp_avg_a3io = temp_Tet.Y[good1]  /in_Tp_all_3dp.Y[*,0]
Te_Tp_per_a3io = temp_Teb.Y[good1,1]/in_Tp_all_3dp.Y[*,1]
Te_Tp_par_a3io = temp_Teb.Y[good1,0]/in_Tp_all_3dp.Y[*,2]
Te_Ta_avg_a3io = temp_Tet.Y[good1]  /in_Ta_all_3dp.Y[*,0]
Te_Ta_per_a3io = temp_Teb.Y[good1,1]/in_Ta_all_3dp.Y[*,1]
Te_Ta_par_a3io = temp_Teb.Y[good1,0]/in_Ta_all_3dp.Y[*,2]
;;  Only good SWE and ALL 3DP times inside of MO
Te_Tp_avg_saio = temp_Tet.Y[good0]  /in_Tp_swe_all.Y[*,0]
Te_Tp_per_saio = temp_Teb.Y[good0,1]/in_Tp_swe_all.Y[*,1]
Te_Tp_par_saio = temp_Teb.Y[good0,0]/in_Tp_swe_all.Y[*,2]
Te_Ta_avg_saio = temp_Tet.Y[good0]  /in_Ta_swe_all.Y[*,0]
Te_Ta_per_saio = temp_Teb.Y[good0,1]/in_Ta_swe_all.Y[*,1]
Te_Ta_par_saio = temp_Teb.Y[good0,0]/in_Ta_swe_all.Y[*,2]
;;  Only good SWE and only good 3DP times inside of MO
Te_Tp_avg_s3io = temp_Tet.Y[good1]  /in_Tp_swe_3dp.Y[*,0]
Te_Tp_per_s3io = temp_Teb.Y[good1,1]/in_Tp_swe_3dp.Y[*,1]
Te_Tp_par_s3io = temp_Teb.Y[good1,0]/in_Tp_swe_3dp.Y[*,2]
Te_Ta_avg_s3io = temp_Tet.Y[good1]  /in_Ta_swe_3dp.Y[*,0]
Te_Ta_per_s3io = temp_Teb.Y[good1,1]/in_Ta_swe_3dp.Y[*,1]
Te_Ta_par_s3io = temp_Teb.Y[good1,0]/in_Ta_swe_3dp.Y[*,2]
;;  *********************
;;  ***  Outside MOs  ***
;;  *********************
good0          = out_mo_all
good1          = out_mo_3dp
;;  ALL SWE and ALL 3DP times outside of MO
Te_Tp_avg_aaoo = temp_Tet.Y[good0]  /ot_Tp_all_all.Y[*,0]
Te_Tp_per_aaoo = temp_Teb.Y[good0,1]/ot_Tp_all_all.Y[*,1]
Te_Tp_par_aaoo = temp_Teb.Y[good0,0]/ot_Tp_all_all.Y[*,2]
Te_Ta_avg_aaoo = temp_Tet.Y[good0]  /ot_Ta_all_all.Y[*,0]
Te_Ta_per_aaoo = temp_Teb.Y[good0,1]/ot_Ta_all_all.Y[*,1]
Te_Ta_par_aaoo = temp_Teb.Y[good0,0]/ot_Ta_all_all.Y[*,2]
;;  ALL SWE and only good 3DP times outside of MO
Te_Tp_avg_a3oo = temp_Tet.Y[good1]  /ot_Tp_all_3dp.Y[*,0]
Te_Tp_per_a3oo = temp_Teb.Y[good1,1]/ot_Tp_all_3dp.Y[*,1]
Te_Tp_par_a3oo = temp_Teb.Y[good1,0]/ot_Tp_all_3dp.Y[*,2]
Te_Ta_avg_a3oo = temp_Tet.Y[good1]  /ot_Ta_all_3dp.Y[*,0]
Te_Ta_per_a3oo = temp_Teb.Y[good1,1]/ot_Ta_all_3dp.Y[*,1]
Te_Ta_par_a3oo = temp_Teb.Y[good1,0]/ot_Ta_all_3dp.Y[*,2]
;;  Only good SWE and ALL 3DP times outside of MO
Te_Tp_avg_saoo = temp_Tet.Y[good0]  /ot_Tp_swe_all.Y[*,0]
Te_Tp_per_saoo = temp_Teb.Y[good0,1]/ot_Tp_swe_all.Y[*,1]
Te_Tp_par_saoo = temp_Teb.Y[good0,0]/ot_Tp_swe_all.Y[*,2]
Te_Ta_avg_saoo = temp_Tet.Y[good0]  /ot_Ta_swe_all.Y[*,0]
Te_Ta_per_saoo = temp_Teb.Y[good0,1]/ot_Ta_swe_all.Y[*,1]
Te_Ta_par_saoo = temp_Teb.Y[good0,0]/ot_Ta_swe_all.Y[*,2]
;;  Only good SWE and only good 3DP times outside of MO
Te_Tp_avg_s3oo = temp_Tet.Y[good1]  /ot_Tp_swe_3dp.Y[*,0]
Te_Tp_per_s3oo = temp_Teb.Y[good1,1]/ot_Tp_swe_3dp.Y[*,1]
Te_Tp_par_s3oo = temp_Teb.Y[good1,0]/ot_Tp_swe_3dp.Y[*,2]
Te_Ta_avg_s3oo = temp_Tet.Y[good1]  /ot_Ta_swe_3dp.Y[*,0]
Te_Ta_per_s3oo = temp_Teb.Y[good1,1]/ot_Ta_swe_3dp.Y[*,1]
Te_Ta_par_s3oo = temp_Teb.Y[good1,0]/ot_Ta_swe_3dp.Y[*,2]
;;----------------------------------------------------------------------------------------
;;  Define (Ta/Tp)_j ratios
;;----------------------------------------------------------------------------------------
;;  ALL SWE and ALL 3DP times including shocks
Ta_Tp_avg_aan  = 1d0/(t_Tp_all_all.Y[*,0]/t_Ta_all_all.Y[*,0])
Ta_Tp_per_aan  = 1d0/(t_Tp_all_all.Y[*,1]/t_Ta_all_all.Y[*,1])
Ta_Tp_par_aan  = 1d0/(t_Tp_all_all.Y[*,2]/t_Ta_all_all.Y[*,2])
;;  ALL SWE and only good 3DP times including shocks
Ta_Tp_avg_a3n  = 1d0/(f_Tp_all_3dp.Y[*,0]/f_Ta_all_3dp.Y[*,0])
Ta_Tp_per_a3n  = 1d0/(f_Tp_all_3dp.Y[*,1]/f_Ta_all_3dp.Y[*,1])
Ta_Tp_par_a3n  = 1d0/(f_Tp_all_3dp.Y[*,2]/f_Ta_all_3dp.Y[*,2])
;;  Only good SWE and ALL 3DP times including shocks
Ta_Tp_avg_san  = 1d0/(f_Tp_swe_all.Y[*,0]/f_Ta_swe_all.Y[*,0])
Ta_Tp_per_san  = 1d0/(f_Tp_swe_all.Y[*,1]/f_Ta_swe_all.Y[*,1])
Ta_Tp_par_san  = 1d0/(f_Tp_swe_all.Y[*,2]/f_Ta_swe_all.Y[*,2])
;;  Only good SWE and only good 3DP times including shocks
Ta_Tp_avg_s3n  = 1d0/(f_Tp_swe_3dp.Y[*,0]/f_Ta_swe_3dp.Y[*,0])
Ta_Tp_per_s3n  = 1d0/(f_Tp_swe_3dp.Y[*,1]/f_Ta_swe_3dp.Y[*,1])
Ta_Tp_par_s3n  = 1d0/(f_Tp_swe_3dp.Y[*,2]/f_Ta_swe_3dp.Y[*,2])
;;  ALL SWE and ALL 3DP times without shocks
Ta_Tp_avg_aas  = 1d0/(sh_Tp_all_all.Y[*,0]/sh_Ta_all_all.Y[*,0])
Ta_Tp_per_aas  = 1d0/(sh_Tp_all_all.Y[*,1]/sh_Ta_all_all.Y[*,1])
Ta_Tp_par_aas  = 1d0/(sh_Tp_all_all.Y[*,2]/sh_Ta_all_all.Y[*,2])
;;  ALL SWE and only good 3DP times without shocks
Ta_Tp_avg_a3s  = 1d0/(sh_Tp_all_3dp.Y[*,0]/sh_Ta_all_3dp.Y[*,0])
Ta_Tp_per_a3s  = 1d0/(sh_Tp_all_3dp.Y[*,1]/sh_Ta_all_3dp.Y[*,1])
Ta_Tp_par_a3s  = 1d0/(sh_Tp_all_3dp.Y[*,2]/sh_Ta_all_3dp.Y[*,2])
;;  Only good SWE and ALL 3DP times without shocks
Ta_Tp_avg_sas  = 1d0/(sh_Tp_swe_all.Y[*,0]/sh_Ta_swe_all.Y[*,0])
Ta_Tp_per_sas  = 1d0/(sh_Tp_swe_all.Y[*,1]/sh_Ta_swe_all.Y[*,1])
Ta_Tp_par_sas  = 1d0/(sh_Tp_swe_all.Y[*,2]/sh_Ta_swe_all.Y[*,2])
;;  Only good SWE and only good 3DP times without shocks
Ta_Tp_avg_s3s  = 1d0/(sh_Tp_swe_3dp.Y[*,0]/sh_Ta_swe_3dp.Y[*,0])
Ta_Tp_per_s3s  = 1d0/(sh_Tp_swe_3dp.Y[*,1]/sh_Ta_swe_3dp.Y[*,1])
Ta_Tp_par_s3s  = 1d0/(sh_Tp_swe_3dp.Y[*,2]/sh_Ta_swe_3dp.Y[*,2])
;;  ALL SWE and ALL 3DP times inside of MO
Ta_Tp_avg_aaio = 1d0/(in_Tp_all_all.Y[*,0]/in_Ta_all_all.Y[*,0])
Ta_Tp_per_aaio = 1d0/(in_Tp_all_all.Y[*,1]/in_Ta_all_all.Y[*,1])
Ta_Tp_par_aaio = 1d0/(in_Tp_all_all.Y[*,2]/in_Ta_all_all.Y[*,2])
;;  ALL SWE and only good 3DP times inside of MO
Ta_Tp_avg_a3io = 1d0/(in_Tp_all_3dp.Y[*,0]/in_Ta_all_3dp.Y[*,0])
Ta_Tp_per_a3io = 1d0/(in_Tp_all_3dp.Y[*,1]/in_Ta_all_3dp.Y[*,1])
Ta_Tp_par_a3io = 1d0/(in_Tp_all_3dp.Y[*,2]/in_Ta_all_3dp.Y[*,2])
;;  Only good SWE and ALL 3DP times inside of MO
Ta_Tp_avg_saio = 1d0/(in_Tp_swe_all.Y[*,0]/in_Ta_swe_all.Y[*,0])
Ta_Tp_per_saio = 1d0/(in_Tp_swe_all.Y[*,1]/in_Ta_swe_all.Y[*,1])
Ta_Tp_par_saio = 1d0/(in_Tp_swe_all.Y[*,2]/in_Ta_swe_all.Y[*,2])
;;  Only good SWE and only good 3DP times inside of MO
Ta_Tp_avg_s3io = 1d0/(in_Tp_swe_3dp.Y[*,0]/in_Ta_swe_3dp.Y[*,0])
Ta_Tp_per_s3io = 1d0/(in_Tp_swe_3dp.Y[*,1]/in_Ta_swe_3dp.Y[*,1])
Ta_Tp_par_s3io = 1d0/(in_Tp_swe_3dp.Y[*,2]/in_Ta_swe_3dp.Y[*,2])
;;  ALL SWE and ALL 3DP times outside of MO
Ta_Tp_avg_aaoo = 1d0/(ot_Tp_all_all.Y[*,0]/ot_Ta_all_all.Y[*,0])
Ta_Tp_per_aaoo = 1d0/(ot_Tp_all_all.Y[*,1]/ot_Ta_all_all.Y[*,1])
Ta_Tp_par_aaoo = 1d0/(ot_Tp_all_all.Y[*,2]/ot_Ta_all_all.Y[*,2])
;;  ALL SWE and only good 3DP times outside of MO
Ta_Tp_avg_a3oo = 1d0/(ot_Tp_all_3dp.Y[*,0]/ot_Ta_all_3dp.Y[*,0])
Ta_Tp_per_a3oo = 1d0/(ot_Tp_all_3dp.Y[*,1]/ot_Ta_all_3dp.Y[*,1])
Ta_Tp_par_a3oo = 1d0/(ot_Tp_all_3dp.Y[*,2]/ot_Ta_all_3dp.Y[*,2])
;;  Only good SWE and ALL 3DP times outside of MO
Ta_Tp_avg_saoo = 1d0/(ot_Tp_swe_all.Y[*,0]/ot_Ta_swe_all.Y[*,0])
Ta_Tp_per_saoo = 1d0/(ot_Tp_swe_all.Y[*,1]/ot_Ta_swe_all.Y[*,1])
Ta_Tp_par_saoo = 1d0/(ot_Tp_swe_all.Y[*,2]/ot_Ta_swe_all.Y[*,2])
;;  Only good SWE and only good 3DP times outside of MO
Ta_Tp_avg_s3oo = 1d0/(ot_Tp_swe_3dp.Y[*,0]/ot_Ta_swe_3dp.Y[*,0])
Ta_Tp_per_s3oo = 1d0/(ot_Tp_swe_3dp.Y[*,1]/ot_Ta_swe_3dp.Y[*,1])
Ta_Tp_par_s3oo = 1d0/(ot_Tp_swe_3dp.Y[*,2]/ot_Ta_swe_3dp.Y[*,2])



;;  Clean up
DELVAR,temp_ne,temp_np,temp_na,temp_Ve,temp_Vpx,temp_Vpy,temp_Vpz
DELVAR,temp_Vax,temp_Vay,temp_Vaz,temp_Teb,temp_Tet,temp_Bo
DELVAR,temp_VTpav,temp_VTper,temp_VTpar,temp_VTaav,temp_VTaer,temp_VTaar
DELVAR,temp_QF,temp_dnp,temp_dna,temp_dVTpav,temp_dVTaav
DELVAR,good,good0,good1,new_t_sh,new_t1_sh,new_t_in,new_t_ot,new_t1_in,new_t1_ot,l0,l1
DELVAR,test_bst,gen_info_str,asy_info_str,bvn_info_str,key_info_str,ups_info_str,dns_info_str,tdates_bst,tura_all
DELVAR,new_t,new_t1,swe_t,test,unix,punx,aunx,testp,testa










;IF (bd_swe_p[0] GT 0) THEN temp_Tp_all.Y[bad_swe_p,*] = f
;IF (bd_swe_p[0] GT 0) THEN temp_Vp.Y[bad_swe_p,*] = f
;IF (bd_swe_p[0] GT 0) THEN temp_np.Y[bad_swe_p] = f
;IF (bd_swe_a[0] GT 0) THEN temp_Ta_all.Y[bad_swe_a,*] = f
;IF (bd_swe_a[0] GT 0) THEN temp_Va.Y[bad_swe_a,*] = f
;IF (bd_swe_a[0] GT 0) THEN temp_na.Y[bad_swe_a] = f

;IF (N_ELEMENTS(temp_all) GT 0) THEN unqa = UNIQ(temp_all,SORT(temp_all))
;IF (N_ELEMENTS(temp_3dp) GT 0) THEN unq3 = UNIQ(temp_3dp,SORT(temp_3dp))
;IF (N_ELEMENTS(temp_all) GT 0) THEN good_new_all = temp_all[unqa]
;IF (N_ELEMENTS(temp_3dp) GT 0) THEN good_new_3dp = temp_3dp[unq3]
;  IF (N_ELEMENTS(temp_all) GT 0) THEN unq = UNIQ(temp_all,SORT(temp_all))                               & $
;  IF (N_ELEMENTS(temp_all) GT 0) THEN temp_all = temp_all[unq]                                          & $
;  IF (N_ELEMENTS(temp_3dp) GT 0) THEN unq = UNIQ(temp_3dp,SORT(temp_3dp))                               & $
;  IF (N_ELEMENTS(temp_3dp) GT 0) THEN temp_3dp = temp_3dp[unq]                                          & $
;  IF (N_ELEMENTS(temp_all) GT 0) THEN good_new_all = temp_all                                           & $
;  IF (N_ELEMENTS(temp_3dp) GT 0) THEN good_new_3dp = temp_3dp
