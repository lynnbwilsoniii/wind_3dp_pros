;;  @/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_new_batch.pro

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
;;  Ts = ms VTs^2/kB  [K]
Tp_fac         = 1e6*mp[0]/kB[0]*K2eV[0]
Ta_fac         = 1e6*ma[0]/kB[0]*K2eV[0]
;;  Define factor for plasma beta
beta_fac       = 2d0*muo[0]*1d6*eV2J[0]/(1d-9^2)
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
t_swe_fflg_tpn = scprefu[0]+'fit_flag_SWE'
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
;;  3DP and SWE Quality Flags
get_data,    t_3dp_tpns[6],DATA=temp_QF,DLIMIT=dlim_QF,LIMIT=lim_QF
get_data,t_swe_fflg_tpn[0],DATA=temp_FF,DLIMIT=dlim_FF,LIMIT=lim_FF
;;----------------------------------------------------------------------------------------
;;  Define time stamps for each
;;----------------------------------------------------------------------------------------
unix_3dp_all   = t_get_struc_unix(temp_ne)
unix_swe_all   = t_get_struc_unix(temp_np)
unix_mfi_all   = t_get_struc_unix(temp_Bo)
;;----------------------------------------------------------------------------------------
;;  Define relevant TPLOT data
;;----------------------------------------------------------------------------------------
;;  Ts = ms VTs^2/kB  [K]
Tp_avg         = Tp_fac[0]*(temp_VTpav.Y)^2      ;;   Tp [eV]
Tp_per         = Tp_fac[0]*(temp_VTper.Y)^2      ;;   Tp_perp [eV]
Tp_par         = Tp_fac[0]*(temp_VTpar.Y)^2      ;;   Tp_para [eV]
Ta_avg         = Ta_fac[0]*(temp_VTaav.Y)^2      ;;   Ta [eV]
Ta_per         = Ta_fac[0]*(temp_VTaer.Y)^2      ;;   Ta_perp [eV]
Ta_par         = Ta_fac[0]*(temp_VTaar.Y)^2      ;;   Ta_para [eV]
;;  Combine 3DP temps
Te_all         = [[temp_Tet.Y],[temp_Teb.Y[*,0]],[temp_Teb.Y[*,1]]]      ;;  Te[avg,per,par] as a [N,3]-element array [eV]
temp_Te        = {X:unix_3dp_all,Y:Te_all}
;;  Combine SWE temps
Tp_all         = [[Tp_avg],[Tp_per],[Tp_par]]                            ;;  Tp[avg,per,par] as a [N,3]-element array [eV]
Ta_all         = [[Ta_avg],[Ta_per],[Ta_par]]                            ;;  Ta[avg,per,par] as a [N,3]-element array [eV]
temp_Tp        = {X:unix_swe_all,Y:Tp_all}
temp_Ta        = {X:unix_swe_all,Y:Ta_all}
;;  Combine SWE velocities
vel_p          = [[temp_Vpx.Y],[temp_Vpy.Y],[temp_Vpz.Y]]
vel_a          = [[temp_Vax.Y],[temp_Vay.Y],[temp_Vaz.Y]]
temp_Vp        = {X:unix_swe_all,Y:vel_p}
temp_Va        = {X:unix_swe_all,Y:vel_a}
;;  Clean up
DELVAR,Tp_avg, Tp_per, Tp_par, Ta_avg, Ta_per, Ta_par, Tp_all, Ta_all, Te_all, vel_p, vel_a
;;----------------------------------------------------------------------------------------
;;  Define "bad" SWE times
;;----------------------------------------------------------------------------------------
;;  Assign "bad" to:
;;    FF < 10
test           = (temp_FF.Y LT 10) OR (FINITE(temp_FF.Y) EQ 0)
bad_swe        = WHERE(test,bd_swe,COMPLEMENT=good_swe,NCOMPLEMENT=gd_swe)
IF (gd_swe[0] EQ 0) THEN STOP
;;----------------------------------------------------------------------------------------
;;  Define "bad" 3DP times
;;----------------------------------------------------------------------------------------
;;  Assign "bad" to:
;;    QF < 5
test           = (temp_QF.Y LT 5) OR (FINITE(temp_QF.Y) EQ 0)
bad_3dp        = WHERE(test,bd_3dp,COMPLEMENT=good_3dp,NCOMPLEMENT=gd_3dp)
IF (gd_3dp[0] EQ 0) THEN STOP
;;----------------------------------------------------------------------------------------
;;  Find nearest neighbor time stamps
;;    1)  Define a regular grid from Min to Max Unix times
;;    2)  Find the fractional location of time stamps in that grid
;;    3)  Use FLOOR to define bin value
;;----------------------------------------------------------------------------------------
dx             = 2d0*6d1                     ;;  Use 2 minute bins
mnmx_unix      = minmax(unix_3dp_all,/POS) + [-1,1]*dx[0]
delt           = ABS(mnmx_unix[1] - mnmx_unix[0])
nx             = ROUND(delt[0]/dx[0])
bins           = LINDGEN(nx[0])
bin_unix       = bins*dx[0] + mnmx_unix[0] + 5d-1*dx[0]     ;;  Use midpoint time of bins
;;  Compute fractional times
funx_3dp_all   = (unix_3dp_all - mnmx_unix[0])/delt[0]*nx[0]
funx_swe_all   = (unix_swe_all - mnmx_unix[0])/delt[0]*nx[0]
funx_3dp_3dp   = (unix_3dp_all[good_3dp] - mnmx_unix[0])/delt[0]*nx[0]
funx_swe_swe   = (unix_swe_all[good_swe] - mnmx_unix[0])/delt[0]*nx[0]
funx_mfi_all   = (unix_mfi_all - mnmx_unix[0])/delt[0]*nx[0]
;;  Compute bin values [bin value for each time stamp for each instrument]
bins_3dp_all   = FLOOR(funx_3dp_all)
bins_swe_all   = FLOOR(funx_swe_all)
bins_3dp_3dp   = FLOOR(funx_3dp_3dp)         ;;  Only good 3DP times
bins_swe_swe   = FLOOR(funx_swe_swe)         ;;  Only good 3DP times
bins_mfi_all   = FLOOR(funx_mfi_all)
;;----------------------------------------------------------------------------------------
;;  Regrid data to new bin times
;;----------------------------------------------------------------------------------------
nn_3dp_all     = N_ELEMENTS(unix_3dp_all)
nn_swe_all     = N_ELEMENTS(unix_swe_all)
nn_3dp_3dp     = gd_3dp[0]
nn_swe_swe     = gd_swe[0]
nn_mfi_all     = N_ELEMENTS(unix_mfi_all)
;;  Define dummy arrays of # of points per bin
nbns_3dp_all   = LONARR(nx[0])
nbns_swe_all   = LONARR(nx[0])
nbns_3dp_3dp   = LONARR(nx[0])
nbns_swe_swe   = LONARR(nx[0])
;;  [N,3,2]  :  [*,*,0] = ALL, [*,*,1] = Only good elements for that instrument
gdens_epa      = REPLICATE(0d0,nx[0],3L,2L)            ;;  [Ne,Np,Na] as a [N,3,2]-element array [# cm^(-3)]
gtavg_epa      = REPLICATE(0d0,nx[0],3L,2L)            ;;  Avg. [Te,Tp,Ta] as a [N,3,2]-element array [eV]
gtper_epa      = REPLICATE(0d0,nx[0],3L,2L)            ;;  Per. [Te,Tp,Ta] as a [N,3,2]-element array [eV]
gtpar_epa      = REPLICATE(0d0,nx[0],3L,2L)            ;;  Par. [Te,Tp,Ta] as a [N,3,2]-element array [eV]
dumb1          = REPLICATE(d,1L)
dumb3          = REPLICATE(d,1L,3L)

gbins          = bins_3dp_all
FOR j=0L, nn_3dp_all[0] - 1L DO BEGIN                                                                  $
  test = (gbins[j] GE 0 AND gbins[j] LT nx[0])                                                       & $
  IF (~test[0]) THEN CONTINUE                                                                        & $
  k    = j[0]                                                                                        & $
  gdens_epa[gbins[j],0,0] += TOTAL(temp_Ne.Y[k],/NAN)                                                & $
  gtavg_epa[gbins[j],0,0] += TOTAL(temp_Te.Y[k,0],/NAN)                                              & $
  gtper_epa[gbins[j],0,0] += TOTAL(temp_Te.Y[k,1],/NAN)                                              & $
  gtpar_epa[gbins[j],0,0] += TOTAL(temp_Te.Y[k,2],/NAN)                                              & $
  nbns_3dp_all[gbins[j]]  += 1

gbins          = bins_3dp_3dp
FOR j=0L, nn_3dp_3dp[0] - 1L DO BEGIN                                                                  $
  test = (gbins[j] GE 0 AND gbins[j] LT nx[0])                                                       & $
  IF (~test[0]) THEN CONTINUE                                                                        & $
  k    = good_3dp[j[0]]                                                                              & $
  gdens_epa[gbins[j],0,1] += TOTAL(temp_Ne.Y[k],/NAN)                                                & $
  gtavg_epa[gbins[j],0,1] += TOTAL(temp_Te.Y[k,0],/NAN)                                              & $
  gtper_epa[gbins[j],0,1] += TOTAL(temp_Te.Y[k,1],/NAN)                                              & $
  gtpar_epa[gbins[j],0,1] += TOTAL(temp_Te.Y[k,2],/NAN)                                              & $
  nbns_3dp_3dp[gbins[j]]  += 1

gbins          = bins_swe_all
FOR j=0L, nn_swe_all[0] - 1L DO BEGIN                                                                  $
  test = (gbins[j] GE 0 AND gbins[j] LT nx[0])                                                       & $
  IF (~test[0]) THEN CONTINUE                                                                        & $
  k    = j[0]                                                                                        & $
  gdens_epa[gbins[j],1,0] += TOTAL(temp_Np.Y[k],/NAN)                                                & $
  gdens_epa[gbins[j],2,0] += TOTAL(temp_Na.Y[k],/NAN)                                                & $
  gtavg_epa[gbins[j],1,0] += TOTAL(temp_Tp.Y[k,0],/NAN)                                              & $
  gtper_epa[gbins[j],1,0] += TOTAL(temp_Tp.Y[k,1],/NAN)                                              & $
  gtpar_epa[gbins[j],1,0] += TOTAL(temp_Tp.Y[k,2],/NAN)                                              & $
  gtavg_epa[gbins[j],2,0] += TOTAL(temp_Ta.Y[k,0],/NAN)                                              & $
  gtper_epa[gbins[j],2,0] += TOTAL(temp_Ta.Y[k,1],/NAN)                                              & $
  gtpar_epa[gbins[j],2,0] += TOTAL(temp_Ta.Y[k,2],/NAN)                                              & $
  nbns_swe_all[gbins[j]]  += 1

gbins          = bins_swe_swe
FOR j=0L, nn_swe_swe[0] - 1L DO BEGIN                                                                  $
  test = (gbins[j] GE 0 AND gbins[j] LT nx[0])                                                       & $
  IF (~test[0]) THEN CONTINUE                                                                        & $
  k    = good_swe[j[0]]                                                                              & $
  gdens_epa[gbins[j],1,1] += TOTAL(temp_Np.Y[k],/NAN)                                                & $
  gdens_epa[gbins[j],2,1] += TOTAL(temp_Na.Y[k],/NAN)                                                & $
  gtavg_epa[gbins[j],1,1] += TOTAL(temp_Tp.Y[k,0],/NAN)                                              & $
  gtper_epa[gbins[j],1,1] += TOTAL(temp_Tp.Y[k,1],/NAN)                                              & $
  gtpar_epa[gbins[j],1,1] += TOTAL(temp_Tp.Y[k,2],/NAN)                                              & $
  gtavg_epa[gbins[j],2,1] += TOTAL(temp_Ta.Y[k,0],/NAN)                                              & $
  gtper_epa[gbins[j],2,1] += TOTAL(temp_Ta.Y[k,1],/NAN)                                              & $
  gtpar_epa[gbins[j],2,1] += TOTAL(temp_Ta.Y[k,2],/NAN)                                              & $
  nbns_swe_swe[gbins[j]]  += 1

;  gtavg_epa[gbins[j],1,1] += TOTAL(temp_Tp.Y[k,0],/NAN)                                              & $
;  gtavg_epa[gbins[j],1,1] += TOTAL(temp_Tp.Y[k,1],/NAN)                                              & $
;  gtper_epa[gbins[j],1,1] += TOTAL(temp_Tp.Y[k,2],/NAN)                                              & $
;  gtper_epa[gbins[j],2,1] += TOTAL(temp_Ta.Y[k,0],/NAN)                                              & $
;  gtpar_epa[gbins[j],2,1] += TOTAL(temp_Ta.Y[k,1],/NAN)                                              & $
;  gtpar_epa[gbins[j],2,1] += TOTAL(temp_Ta.Y[k,2],/NAN)                                              & $
;  gtavg_epa[gbins[j],1,1] += TOTAL(temp_Tp.Y[k,0],/NAN)                                              & $
;  gtavg_epa[gbins[j],2,1] += TOTAL(temp_Tp.Y[k,1],/NAN)                                              & $
;  gtper_epa[gbins[j],1,1] += TOTAL(temp_Tp.Y[k,2],/NAN)                                              & $
;  gtper_epa[gbins[j],2,1] += TOTAL(temp_Ta.Y[k,0],/NAN)                                              & $
;  gtpar_epa[gbins[j],1,1] += TOTAL(temp_Ta.Y[k,1],/NAN)                                              & $
;  gtpar_epa[gbins[j],2,1] += TOTAL(temp_Ta.Y[k,2],/NAN)                                              & $

nbns_mfi_all   = LONARR(nx[0])
gbvec_mfi      = REPLICATE(0d0,nx[0],3L)               ;;  [Bx,By,Bz] as a [N,3]-element array [nT]
gbins          = bins_mfi_all
FOR j=0L, nn_mfi_all[0] - 1L DO BEGIN                                                                  $
  test = (gbins[j] GE 0 AND gbins[j] LT nx[0])                                                       & $
  IF (~test[0]) THEN CONTINUE                                                                        & $
  k    = j[0]                                                                                        & $
  gbvec_mfi[gbins[j],*] += TOTAL(REFORM(temp_Bo.Y[k,0:2],1,3),1L,/NAN)                               & $
  nbns_mfi_all[gbins[j]]  += 1

;;  Keep values ≥ 0
gdens_epa      = gdens_epa > 0e0
gtavg_epa      = gtavg_epa > 0e0
gtper_epa      = gtper_epa > 0e0
gtpar_epa      = gtpar_epa > 0e0

;;  Compute average values per bin
gind_3dp_all   = WHERE(nbns_3dp_all GT 0,gnd_3dp_all)
gind_swe_all   = WHERE(nbns_swe_all GT 0,gnd_swe_all)
gind_3dp_3dp   = WHERE(nbns_3dp_3dp GT 0,gnd_3dp_3dp)
gind_swe_swe   = WHERE(nbns_swe_swe GT 0,gnd_swe_swe)
gind_mfi_all   = WHERE(nbns_mfi_all GT 0,gnd_mfi_all)
PRINT,';;  ',gnd_3dp_all[0],gnd_3dp_3dp[0],gnd_swe_all[0],gnd_swe_swe[0],gnd_mfi_all[0]
;;       1436477      820091     2333476     1137445     2630161

;;  Define Avg. Ns [# cm^(-3)]
gdens_epa[gind_3dp_all,0,0] = gdens_epa[gind_3dp_all,0,0]/nbns_3dp_all[gind_3dp_all]
gdens_epa[gind_swe_all,1,0] = gdens_epa[gind_swe_all,1,0]/nbns_swe_all[gind_swe_all]
gdens_epa[gind_swe_all,2,0] = gdens_epa[gind_swe_all,2,0]/nbns_swe_all[gind_swe_all]
gdens_epa[gind_3dp_3dp,0,1] = gdens_epa[gind_3dp_3dp,0,1]/nbns_3dp_3dp[gind_3dp_3dp]
gdens_epa[gind_swe_swe,1,1] = gdens_epa[gind_swe_swe,1,1]/nbns_swe_swe[gind_swe_swe]
gdens_epa[gind_swe_swe,2,1] = gdens_epa[gind_swe_swe,2,1]/nbns_swe_swe[gind_swe_swe]
;;  Define Avg. Ts_avg [eV]
gtavg_epa[gind_3dp_all,0,0] = gtavg_epa[gind_3dp_all,0,0]/nbns_3dp_all[gind_3dp_all]
gtavg_epa[gind_swe_all,1,0] = gtavg_epa[gind_swe_all,1,0]/nbns_swe_all[gind_swe_all]
gtavg_epa[gind_swe_all,2,0] = gtavg_epa[gind_swe_all,2,0]/nbns_swe_all[gind_swe_all]
gtavg_epa[gind_3dp_3dp,0,1] = gtavg_epa[gind_3dp_3dp,0,1]/nbns_3dp_all[gind_3dp_3dp]
gtavg_epa[gind_swe_swe,1,1] = gtavg_epa[gind_swe_swe,1,1]/nbns_swe_swe[gind_swe_swe]
gtavg_epa[gind_swe_swe,2,1] = gtavg_epa[gind_swe_swe,2,1]/nbns_swe_swe[gind_swe_swe]
;;  Define Avg. Ts_per [eV]
gtper_epa[gind_3dp_all,0,0] = gtper_epa[gind_3dp_all,0,0]/nbns_3dp_all[gind_3dp_all]
gtper_epa[gind_swe_all,1,0] = gtper_epa[gind_swe_all,1,0]/nbns_swe_all[gind_swe_all]
gtper_epa[gind_swe_all,2,0] = gtper_epa[gind_swe_all,2,0]/nbns_swe_all[gind_swe_all]
gtper_epa[gind_3dp_3dp,0,1] = gtper_epa[gind_3dp_3dp,0,1]/nbns_3dp_all[gind_3dp_3dp]
gtper_epa[gind_swe_swe,1,1] = gtper_epa[gind_swe_swe,1,1]/nbns_swe_swe[gind_swe_swe]
gtper_epa[gind_swe_swe,2,1] = gtper_epa[gind_swe_swe,2,1]/nbns_swe_swe[gind_swe_swe]
;;  Define Avg. Ts_par [eV]
gtpar_epa[gind_3dp_all,0,0] = gtpar_epa[gind_3dp_all,0,0]/nbns_3dp_all[gind_3dp_all]
gtpar_epa[gind_swe_all,1,0] = gtpar_epa[gind_swe_all,1,0]/nbns_swe_all[gind_swe_all]
gtpar_epa[gind_swe_all,2,0] = gtpar_epa[gind_swe_all,2,0]/nbns_swe_all[gind_swe_all]
gtpar_epa[gind_3dp_3dp,0,1] = gtpar_epa[gind_3dp_3dp,0,1]/nbns_3dp_all[gind_3dp_3dp]
gtpar_epa[gind_swe_swe,1,1] = gtpar_epa[gind_swe_swe,1,1]/nbns_swe_swe[gind_swe_swe]
gtpar_epa[gind_swe_swe,2,1] = gtpar_epa[gind_swe_swe,2,1]/nbns_swe_swe[gind_swe_swe]
;;  Define Avg. Bo [nT, GSE]
gbvec_mfi[gind_mfi_all,0]   = gbvec_mfi[gind_mfi_all,0]/nbns_mfi_all[gind_mfi_all]
gbvec_mfi[gind_mfi_all,1]   = gbvec_mfi[gind_mfi_all,1]/nbns_mfi_all[gind_mfi_all]
gbvec_mfi[gind_mfi_all,2]   = gbvec_mfi[gind_mfi_all,2]/nbns_mfi_all[gind_mfi_all]
;;----------------------------------------------------------------------------------------
;;  Define "bad" values
;;----------------------------------------------------------------------------------------
;;  Bad is defined as:
;;    Ts_avg  ≥  1000 eV
;;    (Ts_par  ≥  1200 eV) OR (Ts_per  ≥  1200 eV)
;;    |Bo_j| ≥ 120 nT
threshs        = [1e3,12e2,12e1]
test_bo        = (ABS(gbvec_mfi[*,0]) GE threshs[2]) OR (ABS(gbvec_mfi[*,1]) GE threshs[2]) OR (ABS(gbvec_mfi[*,2]) GE threshs[2])
test_tt        = (ABS(gtavg_epa[*,0,0]) GE threshs[0]) OR (ABS(gtavg_epa[*,1,0]) GE threshs[0]) OR (ABS(gtavg_epa[*,2,0]) GE threshs[0]) OR $
                 (ABS(gtavg_epa[*,0,1]) GE threshs[0]) OR (ABS(gtavg_epa[*,1,1]) GE threshs[0]) OR (ABS(gtavg_epa[*,2,1]) GE threshs[0])
test_tp        = (ABS(gtper_epa[*,0,0]) GE threshs[1]) OR (ABS(gtper_epa[*,1,0]) GE threshs[1]) OR (ABS(gtper_epa[*,2,0]) GE threshs[1]) OR $
                 (ABS(gtper_epa[*,0,1]) GE threshs[1]) OR (ABS(gtper_epa[*,1,1]) GE threshs[1]) OR (ABS(gtper_epa[*,2,1]) GE threshs[1])
test_ta        = (ABS(gtpar_epa[*,0,0]) GE threshs[1]) OR (ABS(gtpar_epa[*,1,0]) GE threshs[1]) OR (ABS(gtpar_epa[*,2,0]) GE threshs[1]) OR $
                 (ABS(gtpar_epa[*,0,1]) GE threshs[1]) OR (ABS(gtpar_epa[*,1,1]) GE threshs[1]) OR (ABS(gtpar_epa[*,2,1]) GE threshs[1])
test           = test_bo OR test_tt OR test_tp OR test_ta
;test           = test_bo; OR test_tt OR test_tp OR test_ta
bad            = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
;;  Inform user of good vs. bad
PRINT,';;'
PRINT,';;  # of points satisfying threshold conditions     :  ',gd[0]
PRINT,';;  # of points NOT satisfying threshold conditions :  ',bd[0]
PRINT,';;'
;;
;;  # of points satisfying threshold conditions     :       2628003
;;  # of points NOT satisfying threshold conditions :          2158
;;
IF (bd[0] GT 0) THEN gdens_epa[bad,*,*] = f
IF (bd[0] GT 0) THEN gtavg_epa[bad,*,*] = f
IF (bd[0] GT 0) THEN gtper_epa[bad,*,*] = f
IF (bd[0] GT 0) THEN gtpar_epa[bad,*,*] = f
IF (bd[0] GT 0) THEN gbvec_mfi[bad,*]   = f
;;  Define Avg. |Bo| [nT]
gbmag_mfi                   = mag__vec(gbvec_mfi,/NAN)

;;  Inform user of status
PRINT,';;'
PRINT,';;  Finished rebinning data into a uniform temporal grid...'
PRINT,';;'

;;  Clean Up
DELVAR,test_bo,test_tt,test_tp,test_ta,bad,good
;;----------------------------------------------------------------------------------------
;;  Get Rankine-Hugoniot results, if available
;;----------------------------------------------------------------------------------------
test_bst       = read_shocks_jck_database_new(/CFA_METH_ONLY,GIND_3D=gind_3d_bst)
;;  Define internal structures
gen_info_str   = test_bst.GEN_INFO
;;  Define general info
tdates_bst     = gen_info_str.TDATES
tura_all       = gen_info_str.ARRT_UNIX.Y         ;;  Shock ramp mid time [Unix]
;;  Limit array to data interval
bad_sh         = WHERE(tura_all GT MAX(bin_unix,/NAN),bd_sh,COMPLEMENT=good_sh,NCOMPLEMENT=gd_sh)
IF (gd_sh[0] EQ 0) THEN STOP
good_tura      = tura_all[good_sh]
;;  Define "bad" time ranges as:
;;    Start:  Shock Arrival - 5 hours
;;    End  :  Shock Arrival + 1 day
tfacs          = [-5d0*36d2,864d2]
bad_tst        = good_tura + tfacs[0]
bad_ten        = good_tura + tfacs[1]
bad_tra        = [[bad_tst],[bad_ten]]
n_bad          = N_ELEMENTS(bad_tst)
;;  Clean up
DELVAR,temp_all,temp_3dp,test_bst,gen_info_str,tdates_bst,tura_all
;;  Determine time elements inside and outside IP shock time ranges
FOR j=0L, n_bad[0] - 1L DO BEGIN                                                                          $
  test_new_all   = (bin_unix GE bad_tra[j,0]) AND (bin_unix LE bad_tra[j,1])                            & $
  bad_all0       = WHERE(test_new_all,bd_all0,COMPLEMENT=good_all0,NCOMPLEMENT=gd_all0)                 & $
  IF (bd_all0[0] GT 0) THEN IF (j EQ 0) THEN temp_all = bad_all0 ELSE temp_all = [temp_all,bad_all0]

;;  Clean up
DELVAR,bad_all0,bad_3dp0
IF (N_ELEMENTS(temp_all)     GT 0) THEN unqa         = UNIQ(temp_all,SORT(temp_all))
IF (N_ELEMENTS(temp_all)     GT 0) THEN in__ip_shock = temp_all[unqa] ELSE in__ip_shock = -1L
IF (N_ELEMENTS(in__ip_shock) GT 0) THEN good_all0    = cgsetdifference(bins,in__ip_shock,SUCCESS=success)   ;;  Find elements in L0 that are NOT in TEMP_ALL
IF (N_ELEMENTS(good_all0)    GT 0) THEN out_ip_shock = good_all0 ELSE out_ip_shock = -1L
;;  Clean up
DELVAR,temp_all,temp_3dp,bad_all0,bad_3dp0,good_all0,good_3dp0
;;----------------------------------------------------------------------------------------
;;  Get Magnetic Obstacle (MO) start/end times
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/wind_mo_start_times_and_durations_batch.pro

;;  Limit array to data interval
bad_mo         = WHERE(mo_tstart_unix GT MAX(bin_unix,/NAN),bd_mo,COMPLEMENT=good_mo,NCOMPLEMENT=gd_mo)
IF (gd_mo[0] EQ 0) THEN STOP
good_mo_sunix  = mo_tstart_unix[good_mo]
good_mo_eunix  = mo_t__end_unix[good_mo]
mo_tran        = [[good_mo_sunix],[good_mo_eunix]]
;;  Clean up
DELVAR,temp_all,temp_3dp
;;  Determine "bad" time elements
n_mo           = N_ELEMENTS(good_mo_sunix)
FOR j=0L, n_mo[0] - 1L DO BEGIN                                                                          $
  test_new_all   = (bin_unix GE mo_tran[j,0]) AND (bin_unix LE mo_tran[j,1])                           & $
  bad_all0       = WHERE(test_new_all,bd_all0,COMPLEMENT=good_all0,NCOMPLEMENT=gd_all0)                 & $
  IF (bd_all0[0] GT 0) THEN IF (j EQ 0) THEN temp_all = bad_all0 ELSE temp_all = [temp_all,bad_all0]
;;  Clean up
DELVAR,bad_all0,bad_3dp0
IF (N_ELEMENTS(temp_all)   GT 0) THEN unqa       = UNIQ(temp_all,SORT(temp_all))
IF (N_ELEMENTS(temp_all)   GT 0) THEN in__mo_all = temp_all[unqa] ELSE in__mo_all = -1L
IF (N_ELEMENTS(in__mo_all) GT 0) THEN good_all0  = cgsetdifference(bins,in__mo_all,SUCCESS=success)   ;;  Find elements in L0 that are NOT in OUT_MO_ALL
IF (N_ELEMENTS(good_all0)  GT 0) THEN out_mo_all = good_all0 ELSE out_mo_all = -1L
;;  Clean up
DELVAR,temp_all,temp_3dp,bad_all0,bad_3dp0,good_all0,good_3dp0
;;----------------------------------------------------------------------------------------
;;  Define beta_sj = C[0]*N_s*T_sj/Bo^2
;;----------------------------------------------------------------------------------------
beta_avg_epa   = REPLICATE(0d0,nx[0],3L,2L)            ;;  Avg. Beta_[e,p,a] as a [N,3,2]-element array [unitless]
beta_per_epa   = REPLICATE(0d0,nx[0],3L,2L)            ;;  Per. Beta_[e,p,a] as a [N,3,2]-element array [unitless]
beta_par_epa   = REPLICATE(0d0,nx[0],3L,2L)            ;;  Par. Beta_[e,p,a] as a [N,3,2]-element array [unitless]
bmag_sq        = gbmag_mfi*gbmag_mfi                   ;;  |Bo|^2  [nT^2]
FOR j=0L, 1L DO BEGIN                                                                    $     ;;  [All,Good]
  FOR i=0L, 2L DO BEGIN                                                                  $     ;;  [e,p,a]
    beta_avg_epa[*,i,j] = beta_fac[0]*gdens_epa[*,i,j]*gtavg_epa[*,i,j]/bmag_sq        & $
    beta_per_epa[*,i,j] = beta_fac[0]*gdens_epa[*,i,j]*gtper_epa[*,i,j]/bmag_sq        & $
    beta_par_epa[*,i,j] = beta_fac[0]*gdens_epa[*,i,j]*gtpar_epa[*,i,j]/bmag_sq

;;  Inform user of status
PRINT,';;'
PRINT,';;  Finished computing plasma betas...'
PRINT,';;'
;;----------------------------------------------------------------------------------------
;;  Define (Te/Ts)_tot, (Te/Ts)_perp, and (Te/Ts)_para ratios
;;----------------------------------------------------------------------------------------
Tr_avg_epeaap  = REPLICATE(0d0,nx[0],3L,2L,2L)         ;;  (Ts1/Ts2)_avg [e2p,e2a,a2p] as a [N,3,2,2]-element array [unitless]
Tr_per_epeaap  = REPLICATE(0d0,nx[0],3L,2L,2L)         ;;  (Ts1/Ts2)_per [e2p,e2a,a2p] as a [N,3,2,2]-element array [unitless]
Tr_par_epeaap  = REPLICATE(0d0,nx[0],3L,2L,2L)         ;;  (Ts1/Ts2)_par [e2p,e2a,a2p] as a [N,3,2,2]-element array [unitless]

FOR j=0L, 1L DO BEGIN                                                                    $     ;;  [All,Good]-SWE
  FOR k=0L, 1L DO BEGIN                                                                  $     ;;  [All,Good]-3DP
    Tr_avg_epeaap[*,0,j,k] = gtavg_epa[*,0,k]/gtavg_epa[*,1,j]                         & $     ;;  (Te/Tp)_avg
    Tr_avg_epeaap[*,1,j,k] = gtavg_epa[*,0,k]/gtavg_epa[*,2,j]                         & $     ;;  (Te/Ta)_avg
    Tr_avg_epeaap[*,2,j,k] = gtavg_epa[*,2,j]/gtavg_epa[*,1,j]                         & $     ;;  (Ta/Tp)_avg
    Tr_per_epeaap[*,0,j,k] = gtper_epa[*,0,k]/gtper_epa[*,1,j]                         & $     ;;  (Te/Tp)_per
    Tr_per_epeaap[*,1,j,k] = gtper_epa[*,0,k]/gtper_epa[*,2,j]                         & $     ;;  (Te/Ta)_per
    Tr_per_epeaap[*,2,j,k] = gtper_epa[*,2,j]/gtper_epa[*,1,j]                         & $     ;;  (Ta/Tp)_per
    Tr_par_epeaap[*,0,j,k] = gtpar_epa[*,0,k]/gtpar_epa[*,1,j]                         & $     ;;  (Te/Tp)_par
    Tr_par_epeaap[*,1,j,k] = gtpar_epa[*,0,k]/gtpar_epa[*,2,j]                         & $     ;;  (Te/Ta)_par
    Tr_par_epeaap[*,2,j,k] = gtpar_epa[*,2,j]/gtpar_epa[*,1,j]                                 ;;  (Ta/Tp)_par

;;  Inform user of status
PRINT,';;'
PRINT,';;  Finished computing temperature ratios...'
PRINT,';;'
;;----------------------------------------------------------------------------------------
;;  Convert zeros to NaNs
;;----------------------------------------------------------------------------------------
bad_dens       = WHERE(gdens_epa     LE 0 OR FINITE(gdens_epa)     EQ 0,bd_dens    )
bad_tavg       = WHERE(gtavg_epa     LE 0 OR FINITE(gtavg_epa)     EQ 0,bd_tavg    )
bad_tper       = WHERE(gtper_epa     LE 0 OR FINITE(gtper_epa)     EQ 0,bd_tper    )
bad_tpar       = WHERE(gtpar_epa     LE 0 OR FINITE(gtpar_epa)     EQ 0,bd_tpar    )
bad_bvec       = WHERE(gbvec_mfi     LE 0 OR FINITE(gbvec_mfi)     EQ 0,bd_bvec    )
bad_bmag       = WHERE(gbmag_mfi     LE 0 OR FINITE(gbmag_mfi)     EQ 0,bd_bmag    )
bad_beta_avg   = WHERE(beta_avg_epa  LE 0 OR FINITE(beta_avg_epa)  EQ 0,bd_beta_avg)
bad_beta_per   = WHERE(beta_per_epa  LE 0 OR FINITE(beta_per_epa)  EQ 0,bd_beta_per)
bad_beta_par   = WHERE(beta_par_epa  LE 0 OR FINITE(beta_par_epa)  EQ 0,bd_beta_par)
bad_Trat_avg   = WHERE(Tr_avg_epeaap LE 0 OR FINITE(Tr_avg_epeaap) EQ 0,bd_Trat_avg)
bad_Trat_per   = WHERE(Tr_per_epeaap LE 0 OR FINITE(Tr_per_epeaap) EQ 0,bd_Trat_per)
bad_Trat_par   = WHERE(Tr_par_epeaap LE 0 OR FINITE(Tr_par_epeaap) EQ 0,bd_Trat_par)

IF (bd_dens[0]     GT 0) THEN gdens_epa[bad_dens]         = f
IF (bd_tavg[0]     GT 0) THEN gtavg_epa[bad_tavg]         = f
IF (bd_tper[0]     GT 0) THEN gtper_epa[bad_tper]         = f
IF (bd_tpar[0]     GT 0) THEN gtpar_epa[bad_tpar]         = f
IF (bd_bvec[0]     GT 0) THEN gbvec_mfi[bad_bvec]         = f
IF (bd_bmag[0]     GT 0) THEN gbmag_mfi[bad_bmag]         = f
IF (bd_beta_avg[0] GT 0) THEN beta_avg_epa[bad_beta_avg]  = f
IF (bd_beta_per[0] GT 0) THEN beta_per_epa[bad_beta_per]  = f
IF (bd_beta_par[0] GT 0) THEN beta_par_epa[bad_beta_par]  = f
IF (bd_Trat_avg[0] GT 0) THEN Tr_avg_epeaap[bad_Trat_avg] = f
IF (bd_Trat_per[0] GT 0) THEN Tr_per_epeaap[bad_Trat_per] = f
IF (bd_Trat_par[0] GT 0) THEN Tr_par_epeaap[bad_Trat_par] = f

;;  Clean Up
DELVAR,bad_dens,bad_tavg,bad_tper,bad_tpar,bad_bvec,bad_bmag,bad_beta_avg,bad_beta_per,bad_beta_par,bad_Trat_avg,bad_Trat_per,bad_Trat_par


STOP




;gdens_epa      = REPLICATE(0d0,nx[0],3L,2L)            ;;  [Ne,Np,Na] as a [N,3,2]-element array [# cm^(-3)]
;gtavg_epa      = REPLICATE(0d0,nx[0],3L,2L)            ;;  Avg. [Te,Tp,Ta] as a [N,3,2]-element array [eV]
;gtper_epa      = REPLICATE(0d0,nx[0],3L,2L)            ;;  Per. [Te,Tp,Ta] as a [N,3,2]-element array [eV]
;gtpar_epa      = REPLICATE(0d0,nx[0],3L,2L)            ;;  Par. [Te,Tp,Ta] as a [N,3,2]-element array [eV]
























;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;
;gbins          = bins_3dp_all
;FOR j=0L, nn_3dp_all[0] - 1L DO BEGIN                                                                  $
;  test = (gbins[j] GE 0 AND gbins[j] LT nx[0])                                                       & $
;  IF (test[0]) THEN gdens_epa[gbins[j],0,0] += TOTAL(temp_Ne.Y[j],/NAN)                              & $
;  IF (test[0]) THEN gtavg_epa[gbins[j],0,0] += TOTAL(temp_Te.Y[j,0],/NAN)                            & $
;  IF (test[0]) THEN gtper_epa[gbins[j],0,0] += TOTAL(temp_Te.Y[j,1],/NAN)                            & $
;  IF (test[0]) THEN gtpar_epa[gbins[j],0,0] += TOTAL(temp_Te.Y[j,2],/NAN)                            & $
;  IF (test[0]) THEN nbns_3dp_all[gbins[j]]  += 1
;
;gbins          = bins_3dp_3dp
;FOR j=0L, nn_3dp_3dp[0] - 1L DO BEGIN                                                                  $
;  test = (gbins[j] GE 0 AND gbins[j] LT nx[0])                                                       & $
;  IF (test[0]) THEN gdens_epa[gbins[j],0,1] += TOTAL(temp_Ne.Y[j],/NAN)                              & $
;  IF (test[0]) THEN gtavg_epa[gbins[j],0,1] += TOTAL(temp_Te.Y[j,0],/NAN)                            & $
;  IF (test[0]) THEN gtper_epa[gbins[j],0,1] += TOTAL(temp_Te.Y[j,1],/NAN)                            & $
;  IF (test[0]) THEN gtpar_epa[gbins[j],0,1] += TOTAL(temp_Te.Y[j,2],/NAN)                            & $
;  IF (test[0]) THEN nbns_3dp_3dp[gbins[j]]  += 1
;
;gbins          = bins_swe_all
;FOR j=0L, nn_swe_all[0] - 1L DO BEGIN                                                                  $
;  test = (gbins[j] GE 0 AND gbins[j] LT nx[0])                                                       & $
;  IF (test[0]) THEN gdens_epa[gbins[j],1,0] += TOTAL(temp_Np.Y[j],/NAN)                              & $
;  IF (test[0]) THEN gdens_epa[gbins[j],2,0] += TOTAL(temp_Na.Y[j],/NAN)                              & $
;  IF (test[0]) THEN gtavg_epa[gbins[j],1,0] += TOTAL(temp_Tp.Y[j,0],/NAN)                            & $
;  IF (test[0]) THEN gtper_epa[gbins[j],1,0] += TOTAL(temp_Tp.Y[j,1],/NAN)                            & $
;  IF (test[0]) THEN gtpar_epa[gbins[j],1,0] += TOTAL(temp_Tp.Y[j,2],/NAN)                            & $
;  IF (test[0]) THEN gtavg_epa[gbins[j],2,0] += TOTAL(temp_Ta.Y[j,0],/NAN)                            & $
;  IF (test[0]) THEN gtper_epa[gbins[j],2,0] += TOTAL(temp_Ta.Y[j,1],/NAN)                            & $
;  IF (test[0]) THEN gtpar_epa[gbins[j],2,0] += TOTAL(temp_Ta.Y[j,2],/NAN)                            & $
;  IF (test[0]) THEN nbns_swe_all[gbins[j]]  += 1
;
;gbins          = bins_swe_swe
;FOR j=0L, nn_swe_swe[0] - 1L DO BEGIN                                                                  $
;  test = (gbins[j] GE 0 AND gbins[j] LT nx[0])                                                       & $
;  IF (test[0]) THEN gdens_epa[gbins[j],1,1] += TOTAL(temp_Np.Y[j],/NAN)                              & $
;  IF (test[0]) THEN gdens_epa[gbins[j],2,1] += TOTAL(temp_Na.Y[j],/NAN)                              & $
;  IF (test[0]) THEN gtavg_epa[gbins[j],1,1] += TOTAL(temp_Tp.Y[j,0],/NAN)                            & $
;  IF (test[0]) THEN gtavg_epa[gbins[j],2,1] += TOTAL(temp_Tp.Y[j,1],/NAN)                            & $
;  IF (test[0]) THEN gtper_epa[gbins[j],1,1] += TOTAL(temp_Tp.Y[j,2],/NAN)                            & $
;  IF (test[0]) THEN gtper_epa[gbins[j],2,1] += TOTAL(temp_Ta.Y[j,0],/NAN)                            & $
;  IF (test[0]) THEN gtpar_epa[gbins[j],1,1] += TOTAL(temp_Ta.Y[j,1],/NAN)                            & $
;  IF (test[0]) THEN gtpar_epa[gbins[j],2,1] += TOTAL(temp_Ta.Y[j,2],/NAN)                            & $
;  IF (test[0]) THEN nbns_swe_swe[gbins[j]]  += 1
;
;gbins          = bins_mfi_all
;FOR j=0L, nn_mfi_all[0] - 1L DO BEGIN                                                                  $
;  test = (gbins[j] GE 0 AND gbins[j] LT nx[0])                                                       & $
;  IF (test[0]) THEN gbvec_mfi[gbins[j],*] += TOTAL(REFORM(temp_Bo.Y[j,*],1,3),2L,/NAN)               & $
;  IF (test[0]) THEN nbns_mfi_all[gbins[j]]  += 1
;
;FOR j=0L, nn_3dp_all[0] - 1L DO BEGIN                                                                  $
;  IF (bins_3dp_all[j] GE 0 AND bins_3dp_all[j] LT nx[0]) THEN nbns_3dp_all[bins_3dp_all[j]] += 1
;
;FOR j=0L, nn_swe_all[0] - 1L DO BEGIN                                                                  $
;  IF (bins_swe_all[j] GE 0 AND bins_swe_all[j] LT nx[0]) THEN nbns_swe_all[bins_swe_all[j]] += 1
;
;FOR j=0L, nn_3dp_3dp[0] - 1L DO BEGIN                                                                  $
;  IF (bins_3dp_3dp[j] GE 0 AND bins_3dp_3dp[j] LT nx[0]) THEN nbns_3dp_3dp[bins_3dp_3dp[j]] += 1
;
;FOR j=0L, nn_swe_swe[0] - 1L DO BEGIN                                                                  $
;  IF (bins_swe_swe[j] GE 0 AND bins_swe_swe[j] LT nx[0]) THEN nbns_swe_swe[bins_swe_swe[j]] += 1
;
;FOR j=0L, nn_mfi_all[0] - 1L DO BEGIN                                                                  $
;  IF (bins_mfi_all[j] GE 0 AND bins_mfi_all[j] LT nx[0]) THEN nbns_mfi_all[bins_mfi_all[j]] += 1
;
;FOR j=0L, nx[0] - 1L DO BEGIN                                                                          $
;  ggood_3dp_all    = WHERE(bins_3dp_all EQ j[0],ggd_3dp_all)                                         & $
;  ggood_swe_all    = WHERE(bins_swe_all EQ j[0],ggd_swe_all)                                         & $
;  ggood_3dp_3dp    = WHERE(bins_3dp_3dp EQ j[0],ggd_3dp_3dp)                                         & $
;  ggood_swe_swe    = WHERE(bins_swe_swe EQ j[0],ggd_swe_swe)                                         & $
;  ggood_mfi_all    = WHERE(bins_mfi_all EQ j[0],ggd_mfi_all)                                         & $
;  IF (ggd_3dp_all[0] GT 0) THEN dTe_3dp_all = temp_Te.Y[ggood_3dp_all,*]   ELSE dTe_3dp_all = dumb3  & $
;  IF (ggd_3dp_all[0] GT 0) THEN dNe_3dp_all = temp_Ne.Y[ggood_3dp_all]     ELSE dNe_3dp_all = dumb1  & $
;  IF (ggd_swe_all[0] GT 0) THEN dTp_swe_all = temp_Tp.Y[ggood_swe_all,*]   ELSE dTp_swe_all = dumb3  & $
;  IF (ggd_swe_all[0] GT 0) THEN dTa_swe_all = temp_Ta.Y[ggood_swe_all,*]   ELSE dTa_swe_all = dumb3  & $
;  IF (ggd_swe_all[0] GT 0) THEN dNp_swe_all = temp_Np.Y[ggood_swe_all]     ELSE dNp_swe_all = dumb1  & $
;  IF (ggd_swe_all[0] GT 0) THEN dNa_swe_all = temp_Na.Y[ggood_swe_all]     ELSE dNa_swe_all = dumb1  & $
;  IF (ggd_3dp_3dp[0] GT 0) THEN dTe_3dp_3dp = temp_Te.Y[ggood_3dp_3dp,*]   ELSE dTe_3dp_3dp = dumb3  & $
;  IF (ggd_3dp_3dp[0] GT 0) THEN dNe_3dp_3dp = temp_Ne.Y[ggood_3dp_3dp]     ELSE dNe_3dp_3dp = dumb1  & $
;  IF (ggd_swe_swe[0] GT 0) THEN dTp_swe_swe = temp_Tp.Y[ggood_swe_swe,*]   ELSE dTp_swe_swe = dumb3  & $
;  IF (ggd_swe_swe[0] GT 0) THEN dTa_swe_swe = temp_Ta.Y[ggood_swe_swe,*]   ELSE dTa_swe_swe = dumb3  & $
;  IF (ggd_swe_swe[0] GT 0) THEN dNp_swe_swe = temp_Np.Y[ggood_swe_swe]     ELSE dNp_swe_swe = dumb1  & $
;  IF (ggd_swe_swe[0] GT 0) THEN dNa_swe_swe = temp_Na.Y[ggood_swe_swe]     ELSE dNa_swe_swe = dumb1  & $
;  IF (ggd_mfi_all[0] GT 0) THEN dBo_mfi_all = temp_Bo.Y[ggood_mfi_all,0:2] ELSE dBo_mfi_all = dumb3  & $
;  t_Te_3dp_all     = MEAN(dTe_3dp_all,DIMENSION=1,/NAN)                                              & $
;  t_Te_3dp_3dp     = MEAN(dTe_3dp_3dp,DIMENSION=1,/NAN)                                              & $
;  t_Tp_swe_all     = MEAN(dTp_swe_all,DIMENSION=1,/NAN)                                              & $
;  t_Tp_swe_swe     = MEAN(dTp_swe_swe,DIMENSION=1,/NAN)                                              & $
;  t_Ta_swe_all     = MEAN(dTa_swe_all,DIMENSION=1,/NAN)                                              & $
;  t_Ta_swe_swe     = MEAN(dTa_swe_swe,DIMENSION=1,/NAN)                                              & $
;  t_Bo_mfi_all     = MEAN(dBo_mfi_all,DIMENSION=1,/NAN)                                              & $
;  gdens_epa[j,*,0] = [MEAN(dNe_3dp_all,/NAN),MEAN(dNp_swe_all,/NAN),MEAN(dNa_swe_all,/NAN)]          & $
;  gdens_epa[j,*,1] = [MEAN(dNe_3dp_3dp,/NAN),MEAN(dNp_swe_swe,/NAN),MEAN(dNa_swe_swe,/NAN)]          & $
;  gtavg_epa[j,*,0] = [t_Te_3dp_all[0],t_Tp_swe_all[0],t_Ta_swe_all[0]]                               & $
;  gtavg_epa[j,*,1] = [t_Te_3dp_3dp[0],t_Tp_swe_swe[0],t_Ta_swe_swe[0]]                               & $
;  gtper_epa[j,*,0] = [t_Te_3dp_all[1],t_Tp_swe_all[1],t_Ta_swe_all[1]]                               & $
;  gtper_epa[j,*,1] = [t_Te_3dp_3dp[1],t_Tp_swe_swe[1],t_Ta_swe_swe[1]]                               & $
;  gtpar_epa[j,*,0] = [t_Te_3dp_all[2],t_Tp_swe_all[2],t_Ta_swe_all[2]]                               & $
;  gtpar_epa[j,*,1] = [t_Te_3dp_3dp[2],t_Tp_swe_swe[2],t_Ta_swe_swe[2]]                               & $
;  gbvec_mfi[j,*]   = t_Bo_mfi_all
;
;;;  Compute instrument indices
;inds_3dp_all   = LINDGEN(nn_3dp_all[0])
;inds_swe_all   = LINDGEN(nn_swe_all[0])
;inds_3dp_3dp   = LINDGEN(nn_3dp_3dp[0])
;inds_swe_swe   = LINDGEN(nn_swe_swe[0])
;inds_mfi_all   = LINDGEN(nn_mfi_all[0])
;
;  IF (ggd_3dp_all[0] GT 0) THEN dTe_3dp_all = temp_Te.Y[ggood_3dp_all,*]   ELSE dTe_3dp_all = dumb3  & $
;  IF (ggd_3dp_all[0] GT 0) THEN dNe_3dp_all = temp_Ne.Y[ggood_3dp_all]     ELSE dNe_3dp_all = dumb1  & $
;  IF (ggd_swe_all[0] GT 0) THEN dTp_swe_all = temp_Tp.Y[ggood_swe_all,*]   ELSE dTp_swe_all = dumb3  & $
;  IF (ggd_swe_all[0] GT 0) THEN dTa_swe_all = temp_Ta.Y[ggood_swe_all,*]   ELSE dTa_swe_all = dumb3  & $
;  IF (ggd_swe_all[0] GT 0) THEN dNp_swe_all = temp_Np.Y[ggood_swe_all]     ELSE dNp_swe_all = dumb1  & $
;  IF (ggd_swe_all[0] GT 0) THEN dNa_swe_all = temp_Na.Y[ggood_swe_all]     ELSE dNa_swe_all = dumb1  & $
;  IF (ggd_3dp_3dp[0] GT 0) THEN dTe_3dp_3dp = temp_Te.Y[ggood_3dp_3dp,*]   ELSE dTe_3dp_3dp = dumb3  & $
;  IF (ggd_3dp_3dp[0] GT 0) THEN dNe_3dp_3dp = temp_Ne.Y[ggood_3dp_3dp]     ELSE dNe_3dp_3dp = dumb1  & $
;  IF (ggd_swe_swe[0] GT 0) THEN dTp_swe_swe = temp_Tp.Y[ggood_swe_swe,*]   ELSE dTp_swe_swe = dumb3  & $
;  IF (ggd_swe_swe[0] GT 0) THEN dTa_swe_swe = temp_Ta.Y[ggood_swe_swe,*]   ELSE dTa_swe_swe = dumb3  & $
;  IF (ggd_swe_swe[0] GT 0) THEN dNp_swe_swe = temp_Np.Y[ggood_swe_swe]     ELSE dNp_swe_swe = dumb1  & $
;  IF (ggd_swe_swe[0] GT 0) THEN dNa_swe_swe = temp_Na.Y[ggood_swe_swe]     ELSE dNa_swe_swe = dumb1  & $
;  IF (ggd_mfi_all[0] GT 0) THEN dBo_mfi_all = temp_Bo.Y[ggood_mfi_all,0:2] ELSE dBo_mfi_all = dumb3  & $
;  t_Te_3dp_all     = MEAN(dTe_3dp_all,DIMENSION=1,/NAN)                                              & $
;  t_Te_3dp_3dp     = MEAN(dTe_3dp_3dp,DIMENSION=1,/NAN)                                              & $
;  t_Tp_swe_all     = MEAN(dTp_swe_all,DIMENSION=1,/NAN)                                              & $
;  t_Tp_swe_swe     = MEAN(dTp_swe_swe,DIMENSION=1,/NAN)                                              & $
;  t_Ta_swe_all     = MEAN(dTa_swe_all,DIMENSION=1,/NAN)                                              & $
;  t_Ta_swe_swe     = MEAN(dTa_swe_swe,DIMENSION=1,/NAN)                                              & $
;  t_Bo_mfi_all     = MEAN(dBo_mfi_all,DIMENSION=1,/NAN)                                              & $
;  gdens_epa[j,*,0] = [MEAN(dNe_3dp_all,/NAN),MEAN(dNp_swe_all,/NAN),MEAN(dNa_swe_all,/NAN)]          & $
;  gdens_epa[j,*,1] = [MEAN(dNe_3dp_3dp,/NAN),MEAN(dNp_swe_swe,/NAN),MEAN(dNa_swe_swe,/NAN)]          & $
;  gtavg_epa[j,*,0] = [t_Te_3dp_all[0],t_Tp_swe_all[0],t_Ta_swe_all[0]]                               & $
;  gtavg_epa[j,*,1] = [t_Te_3dp_3dp[0],t_Tp_swe_swe[0],t_Ta_swe_swe[0]]                               & $
;  gtper_epa[j,*,0] = [t_Te_3dp_all[1],t_Tp_swe_all[1],t_Ta_swe_all[1]]                               & $
;  gtper_epa[j,*,1] = [t_Te_3dp_3dp[1],t_Tp_swe_swe[1],t_Ta_swe_swe[1]]                               & $
;  gtpar_epa[j,*,0] = [t_Te_3dp_all[2],t_Tp_swe_all[2],t_Ta_swe_all[2]]                               & $
;  gtpar_epa[j,*,1] = [t_Te_3dp_3dp[2],t_Tp_swe_swe[2],t_Ta_swe_swe[2]]                               & $
;  gbvec_mfi[j,*]   = t_Bo_mfi_all
;
;  t_N_epa_all      = [MEAN(dNe_3dp_all,/NAN),MEAN(dNp_swe_all,/NAN),MEAN(dNa_swe_all,/NAN)]          & $
;  t_N_epa_g3s      = [MEAN(dNe_3dp_3dp,/NAN),MEAN(dNp_swe_swe,/NAN),MEAN(dNa_swe_swe,/NAN)]          & $
;  gdens_epa[j,*,0] = t_N_epa_all                                                                     & $
;  gdens_epa[j,*,1] = t_N_epa_g3s                                                                     & $



;gap_thsh       = 864d2*5d1
;se_int_3dp     = t_interval_find(unix_3dp_all,/NAN,GAP_THRESH=gap_thsh[0])
;
;loc_swe_at_3dp = VALUE_LOCATE(unix_3dp_all,unix_swe_all)










































