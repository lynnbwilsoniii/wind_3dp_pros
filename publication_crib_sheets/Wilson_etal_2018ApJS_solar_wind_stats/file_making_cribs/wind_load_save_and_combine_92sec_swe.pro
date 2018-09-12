;;  wind_load_save_and_combine_92sec_swe.pro

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
;;  Define date/time of interest
;;----------------------------------------------------------------------------------------
tdate0         = '1995-01-01'
tdate1         = '2004-12-31'
yr_st_en       = STRMID([tdate0[0],tdate1[0]],0L,4L)
all_tdates_gd  = fill_tdates_btwn_start_end(tdate0[0],tdate1[0])
nyr            = LONG(yr_st_en[1]) - LONG(yr_st_en[0]) + 1L  ;;  # of years to print
years          = LINDGEN(nyr[0]) + LONG(yr_st_en[0])
;;----------------------------------------------------------------------------------------
;;  Create yearly MFI TPLOT files
;;----------------------------------------------------------------------------------------
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_make_92sec_swe_save_by_year.pro
FOR j=0L, nyr[0] - 1L DO temp_make_92sec_swe_save_by_year,YEAR=years[j]
;;----------------------------------------------------------------------------------------
;;  Find all yearly MFI TPLOT files and merge
;;----------------------------------------------------------------------------------------
fname_pre      = scpref[0]+'92sec_SWE_'
years2         = [years,2005L]
n              = nyr[0]
x              = LINDGEN(n[0])
y              = x + 1L
years_str      = num2int_str(years2,NUM_CHAR=4)
year_rans      = years_str[x]+'-'+years_str[y]
fnames         = fname_pre[0]+year_rans+'.tplot'
;;  Find files
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'temp_idl'+slash[0]+'solar_wind_stats'+slash[0]+'sav_files'+slash[0]
;;  Restore if file found
FOR j=0L, n[0] - 1L DO BEGIN                                                             $
  gfile = FILE_SEARCH(sav_dir[0],fnames[j])                                            & $
  IF (gfile[0] NE '') THEN tplot_restore,FILENAME=gfile[0],/APPEND,/SORT
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Save TPLOT file
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define full time range
year2_str      = num2int_str(minmax(years2),NUM_CHAR=4)
year_ran2      = year2_str[0]+'-'+year2_str[1]
fname          = fname_pre[0]+year_ran2[0]
tplot_save,FILENAME=sav_dir[0]+fname[0]

;;  Remove yearly files
FOR j=0L, n[0] - 1L DO BEGIN                                                             $
  gfile = FILE_SEARCH(sav_dir[0],fnames[j])                                            & $
  IF (gfile[0] NE '') THEN FILE_DELETE,gfile[0],/ALLOW_NONEXISTENT
