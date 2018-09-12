;;  wind_load_dust_and_3dp_then_save_combined.pro

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
eV2K           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
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
;;  Find and restore dust impact TPLOT files
;;----------------------------------------------------------------------------------------
tplot_dir      = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'HGI_2014_Dust'+slash[0]+'tpn_save_dir'+slash[0]
fname          = 'wind_dustimpact_Bgse_SWEgse_SSN_F107_EarthPosi_MeteorStreams.tplot'
gfile          = FILE_SEARCH(tplot_dir[0],fname[0])
;;  Restore if file found
IF (gfile[0] NE '') THEN tplot_restore,FILENAME=gfile[0],/APPEND,/SORT
;;  Remove dust TPLOT handles
bad_tpns       = [tnames('*_dust_*'),tnames('Ex_*'),tnames('Ey_*'),tnames('PosE*'),  $
                  tnames('All_Ex_Ey_*'),tnames('daily_*'),tnames('annual_*'),        $
                  tnames('Total_*'),tnames('CfA_*')]
IF (bad_tpns[0] NE '') THEN store_data,DELETE=bad_tpns
;;----------------------------------------------------------------------------------------
;;  Define date/time of interest
;;----------------------------------------------------------------------------------------
tdate0         = '1995-01-01'
tdate1         = '2005-01-01'
;;  Define time string
tr_str         = [tdate0[0],tdate1[0]]+'/'+start_of_day[0]
tran           = time_double(tr_str)
;;  Define time suffix for output files
fnm            = file_name_times(tran,PREC=0)
ftime0         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
ftimes         = STRMID(ftime0[*],0L,15L)
tsuffx         = ftimes[0]+'_'+ftimes[1]
;;----------------------------------------------------------------------------------------
;;  Redefine time range of data so it does not extend more than 1 day beyond 3DP
;;----------------------------------------------------------------------------------------
tr_lim         = tran + [-1,1]*864d2
;;  Remove the 1 hour B-field data and replace with 3s data
store_data,DELETE=tnames('Wind_B_1hr_gse')
;;  Replace with 1 minute B-field data
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'temp_idl'+slash[0]+'solar_wind_stats'+slash[0]+'sav_files'+slash[0]
fname          = scpref[0]+'1min_MFI_*-*.tplot'
gfile = FILE_SEARCH(sav_dir[0],fname[0])
IF (gfile[0] NE '') THEN tplot_restore,FILENAME=gfile[0],/APPEND,/SORT
;wind_h0_mfi_2_tplot,/B1MIN,/LOAD_GSE,TRANGE=tr_lim
;;  Clip to 3DP time range
all_tpns       = tnames()
ntpns          = N_ELEMENTS(all_tpns)
FOR j=0L, ntpns[0] - 1L DO BEGIN                                            $
  get_data,all_tpns[j],DATA=temp,DLIMIT=dlim,LIMIT=lim                    & $
  IF (SIZE(temp,/TYPE) NE 8) THEN CONTINUE                                & $
  dumb = trange_clip_data(temp,TRANGE=tr_lim,PREC=3)                      & $
  IF (SIZE(dumb,/TYPE) NE 8) THEN CONTINUE                                & $
  store_data,all_tpns[j],DATA=dumb,DLIMIT=dlim,LIMIT=lim
;;  Set TPLOT timespan
delt           = tran[1] - tran[0]
timespan,tran[0],delt[0],/SECONDS
;;----------------------------------------------------------------------------------------
;;  Find and restore 3DP TPLOT files
;;----------------------------------------------------------------------------------------
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'temp_idl'+slash[0]+'solar_wind_stats'+slash[0]+'sav_files'+slash[0]
fname_out      = scpref[0]+'3dp_emfits_*'
gfile          = FILE_SEARCH(sav_dir[0],fname_out[0])
IF (gfile[0] NE '') THEN tplot_restore,FILENAME=gfile[0],/APPEND,/SORT

new_tpns       = ['Ne_3dp','Te_pape_3dp','Te_anis_3dp','Te_totl_3dp','Qe_para_3dp',     $
                  'Ve_3dp_gse','Quality_Flag_3dp']
;;  Kill times where Ne > 150 cm^(-3)
thsh           = 15e1
get_data,new_tpns[0],DATA=temp,DLIMIT=dlim,LIMIT=lim
dumb           = temp.Y
bad            = WHERE(dumb GE thsh[0] OR dumb LE 0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0) THEN dumb[bad] = f
temp.Y         = dumb
store_data,new_tpns[0],DATA=temp,DLIMIT=dlim,LIMIT=lim

;;  Use bad intervals to remove other 3DP parameter values
ntpns          = N_ELEMENTS(new_tpns)
FOR j=1L, ntpns[0] - 1L DO BEGIN                                            $
  IF (bd EQ 0) THEN CONTINUE                                              & $
  get_data,new_tpns[j],DATA=temp,DLIMIT=dlim,LIMIT=lim                    & $
  IF (SIZE(temp,/TYPE) NE 8) THEN CONTINUE                                & $
  dumb           = temp.Y                                                 & $
  sznd           = SIZE(dumb,/N_DIMENSIONS)                               & $
  test           = (sznd[0] EQ 1)                                         & $
  IF (test[0]) THEN dumb[bad] = f ELSE dumb[bad,*] = f                    & $
  temp.Y         = dumb                                                   & $
  store_data,new_tpns[j],DATA=temp,DLIMIT=dlim,LIMIT=lim
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Save TPLOT file
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'temp_idl'+slash[0]+'solar_wind_stats'+slash[0]+'sav_files'+slash[0]
fname_out      = scpref[0]+'EarthPosi_SCPosi_SWE_MFI_3dp_emfits_'+tsuffx[0]
fname          = sav_dir[0]+fname_out[0]
tplot_save,FILENAME=fname[0]
