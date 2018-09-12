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
amu            = 1.6605390400d-27         ;;  Atomic mass constant [kg, 2014 CODATA/NIST]
;;  Astronomical
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
aukm           = au[0]*1d-3               ;;  m --> km
;;  --> Planetary radii [m]
R_S___m        = 6.9600000d08             ;;  Sun's Mean Equatorial Radius [m, 2015 AA values]
R_Me__m        = 2.4397000d06             ;;  Mercury's Mean Equatorial Radius [m, 2015 AA values]
R_Ve__m        = 6.0518000d06             ;;  Venus' Mean Equatorial Radius [m, 2015 AA values]
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
R_Ma__m        = 3.3961900d06             ;;  Mars' Mean Equatorial Radius [m, 2015 AA values]
R_Ju__m        = 7.1492000d07             ;;  Jupiter's Mean Equatorial Radius [m, 2015 AA values]
R_Sa__m        = 6.0268000d07             ;;  Saturn's Mean Equatorial Radius [m, 2015 AA values]
R_Ur__m        = 2.5559000d07             ;;  Uranus's Mean Equatorial Radius [m, 2015 AA values]
R_Ne__m        = 2.4764000d07             ;;  Neptune's Mean Equatorial Radius [m, 2015 AA values]
R_Pl__m        = 1.1950000d06             ;;  Pluto's Mean Equatorial Radius [m, 2015 AA values]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km
;;  --> Planetary masses as ratio to sun's mass
Ms_M_Me        = 6.023600000d06           ;;  Ratio of sun-to-Mercury's mass [unitless, 2015 AA values]
Ms_M_Ve        = 4.085237190d05           ;;  Ratio of sun-to-Venus' mass [unitless, 2015 AA values]
Ms_M_Ea        = 3.329460487d05           ;;  Ratio of sun-to-Earth's mass [unitless, 2015 AA values]
Ms_M_Ma        = 3.098703590d06           ;;  Ratio of sun-to-Mars' mass [unitless, 2015 AA values]
Ms_M_Ju        = 1.047348644d03           ;;  Ratio of sun-to-Jupiter's mass [unitless, 2015 AA values]
Ms_M_Sa        = 3.497901800d03           ;;  Ratio of sun-to-Saturn's mass [unitless, 2015 AA values]
Ms_M_Ur        = 2.290298000d04           ;;  Ratio of sun-to-Uranus's mass [unitless, 2015 AA values]
Ms_M_Ne        = 1.941226000d04           ;;  Ratio of sun-to-Neptune's mass [unitless, 2015 AA values]
Ms_M_Pl        = 1.365660000d08           ;;  Ratio of sun-to-Pluto's mass [unitless, 2015 AA values]
;;  --> Planetary masses in SI units
M_E            = 5.9722000d24             ;;  Earth's mass [kg, 2015 AA values]
M_S__kg        = 1.9884000d30             ;;  Sun's mass [kg, 2015 AA values]
M_Me_kg        = M_S__kg[0]/Ms_M_Me[0]    ;;  Mercury's mass [kg, 2015 AA values]
M_Ve_kg        = M_S__kg[0]/Ms_M_Ve[0]    ;;  Venus' mass [kg, 2015 AA values]
M_Ea_kg        = M_S__kg[0]/Ms_M_Ea[0]    ;;  Earth's mass [kg, 2015 AA values]
M_Ma_kg        = M_S__kg[0]/Ms_M_Ma[0]    ;;  Mars' mass [kg, 2015 AA values]
M_Ju_kg        = M_S__kg[0]/Ms_M_Ju[0]    ;;  Jupiter's mass [kg, 2015 AA values]
M_Sa_kg        = M_S__kg[0]/Ms_M_Sa[0]    ;;  Saturn's mass [kg, 2015 AA values]
M_Ur_kg        = M_S__kg[0]/Ms_M_Ur[0]    ;;  Uranus's mass [kg, 2015 AA values]
M_Ne_kg        = M_S__kg[0]/Ms_M_Ne[0]    ;;  Neptune's mass [kg, 2015 AA values]
M_Pl_kg        = M_S__kg[0]/Ms_M_Pl[0]    ;;  Pluto's mass [kg, 2015 AA values]
;;----------------------------------------------------------------------------------------
;;  Reference:
;;              http://ssd.jpl.nasa.gov/horizons.cgi
;;
;;    Reference epoch: J2000.0
;;    xy-plane: plane of the Earth's orbit at the reference epoch
;;    x-axis  : out along ascending node of instantaneous plane of the Earth's
;;              orbit and the Earth's mean equator at the reference epoch
;;    z-axis  : perpendicular to the xy-plane in the directional (+ or -) sense
;;              of Earth's north pole at the reference epoch.
;;
;;
;;  Earth
;;                       X (AU)                 Y (AU)                 Z (AU)
;;  2008-07-14:  3.766886704702259E-01 -9.388009102928850E-01 -2.925253880117857E-05
;;  2008-08-19:  8.403285929237175E-01 -5.571254698030120E-01 -3.771719863369167E-05
;;  2008-09-08:  9.743696540543839E-01 -2.457700499663959E-01 -3.742483566647666E-05
;;  2008-09-16:  9.971381612752165E-01 -1.111148763798198E-01 -4.350789151617495E-05
;;
;;  Jupiter
;;                       X (AU)                 Y (AU)                 Z (AU)
;;  2008-07-14:  1.576075640618435E+00 -4.925110679120953E+00 -1.487592648671362E-02
;;  2008-08-19:  1.829152160839093E+00 -4.822637278324840E+00 -2.096568771831694E-02
;;  2008-09-08:  1.967593491563886E+00 -4.759882115575692E+00 -2.432476824082488E-02
;;  2008-09-16:  2.022500446591080E+00 -4.733624570412998E+00 -2.566267089754535E-02
;;----------------------------------------------------------------------------------------
tdates         = ['2008-07-14','2008-08-19','2008-09-08','2008-09-16']
;;  Define Earth's cartesian position [AU]
x_E_ecl_pos    = [ 3.766886704702259E-01, 8.403285929237175E-01, 9.743696540543839E-01, 9.971381612752165E-01]
y_E_ecl_pos    = [-9.388009102928850E-01,-5.571254698030120E-01,-2.457700499663959E-01,-1.111148763798198E-01]
z_E_ecl_pos    = [-2.925253880117857E-05,-3.771719863369167E-05,-3.742483566647666E-05,-4.350789151617495E-05]
E_ecl_vec      = [[x_E_ecl_pos],[z_E_ecl_pos],[y_E_ecl_pos]]
;;  Define Jovian cartesian position [AU]
x_J_ecl_pos    = [ 1.576075640618435E+00, 1.829152160839093E+00, 1.967593491563886E+00, 2.022500446591080E+00]
y_J_ecl_pos    = [-4.925110679120953E+00,-4.822637278324840E+00,-4.759882115575692E+00,-4.733624570412998E+00]
z_J_ecl_pos    = [-1.487592648671362E-02,-2.096568771831694E-02,-2.432476824082488E-02,-2.566267089754535E-02]
J_ecl_vec      = [[x_J_ecl_pos],[z_J_ecl_pos],[y_J_ecl_pos]]
;;  Define corresponding unit vectors
E_ecl_uvec     = unit_vec(E_ecl_vec)
J_ecl_uvec     = unit_vec(J_ecl_vec)
;;  Define angle [deg] between Sun-Earth and Sun-Jupiter vectors
S2E_dot_S2J    = my_dot_prod(E_ecl_uvec,J_ecl_uvec,/NOM)
ang_EJ_tot     = ACOS(S2E_dot_S2J)*18d1/!DPI
ang_E2J_ca     = ang_EJ_tot < (18d1 - ang_EJ_tot)       ;;  The complementary angle [deg]
;;  Define vector between Earth and Jupiter and magnitude [AU]
r_E2J_vec      = J_ecl_vec - E_ecl_vec
r_E2J_mag      = mag__vec(r_E2J_vec,/NAN)
;;  Print output
mform          = '(";;  ",a12," ",f10.3,f15.2)'
nd             = N_ELEMENTS(tdates)
FOR j=0L, nd[0] - 1L DO PRINT,FORMAT=mform[0],tdates[j],r_E2J_mag[j],ang_E2J_ca[j]
;;       Date        ∆R [AU]        ø [deg]
;;==========================================
;;    2008-07-14      4.163           4.12
;;    2008-08-19      4.379          35.69
;;    2008-09-08      4.622          53.39
;;    2008-09-16      4.735          60.51




;;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;          Center Time                     Box            Boy            Boz           Vix            Viy            Viz             Ni            Ti              Te        Enhancement?            Bmax
;;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;------------------------------------------
;;  SLAMS
;;------------------------------------------
;;  2008-08-19/21:48:55                  -4.45233       -0.06901       -1.15697     -469.44272       34.38181        1.61049        2.50447      151.28587       17.68887         Yes                 10.0
;;  2008-08-19/21:53:45                  -4.45233       -0.06901       -1.15697     -469.44272       34.38181        1.61049        2.50447      151.28587       17.68887         Yes                 27.0
;;  2008-08-19/22:18:30                  -4.39718        0.28863        0.06444     -467.18404       77.76149       10.80489        2.19373      235.13506       20.04340         Yes                 14.5
;;  2008-08-19/22:22:30                  -1.93209       -0.12498        0.49713     -425.21411       51.14974       17.56595        0.98637      397.24945       22.39241         Yes                 16.0
;;  2008-09-08/20:24:50                   2.57605        1.74533       -1.17876     -485.02222       96.29847        9.82804        2.84599      207.16648       10.41375         Yes                 17.0
;;------------------------------------------
;;  HFAS
;;------------------------------------------
;;  2008-08-19/12:50:57                  -0.59589        2.11973        1.65043     -537.10808       66.54217       -3.81991        1.87271       99.05405       11.60155         Yes                 24.0
;;  2008-09-08/17:01:41                   2.24290        1.82921       -2.58035     -524.98055       82.47949       20.57287        2.51951       61.53185       10.34733         Yes                 21.0
;;------------------------------------------
;;  FBS
;;------------------------------------------
;;  2008-07-14/21:55:45                   2.67225       -2.01985       -0.68892     -611.82270       67.34560       34.61422        1.40825      136.74590       10.34374         Yes                 12.0
;;  2008-07-14/21:58:10                   2.67225       -2.01985       -0.68892     -611.82270       67.34560       34.61422        1.40825      136.74590       10.34374         Yes                 27.0
;;  2008-08-19/21:51:45                  -4.45233       -0.06901       -1.15697     -469.44272       34.38181        1.61049        2.50447      151.28587       17.68887         Yes                 25.0
;;  2008-09-08/20:25:22                   2.57605        1.74533       -1.17876     -485.02222       96.29847        9.82804        2.84599      207.16648       10.41375         Yes                 36.0
;;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

;;  Define energy [eV] bin values for SSTe and SSTi
enere          = [31d0,41d0,52d0,66d0,93d0,139d0,204d0,293d0]*1d3
enerp          = [38d0,49d0,63d0,75d0,103d0,152d0,214d0,303d0,427d0]*1d3
nne            = N_ELEMENTS(enere)
nnp            = N_ELEMENTS(enerp)
;;          Center Time                                                  Ni            Ti              Te        Enhancement?            Bmax
;;  2008-08-19/21:48:55                                                2.50447      151.28587       17.68887         Yes                 10.0
;;  2008-08-19/21:53:45                                                2.50447      151.28587       17.68887         Yes                 27.0
;;  2008-08-19/22:18:30                                                2.19373      235.13506       20.04340         Yes                 14.5
;;  2008-08-19/22:22:30                                                0.98637      397.24945       22.39241         Yes                 16.0
;;  2008-09-08/20:24:50                                                2.84599      207.16648       10.41375         Yes                 17.0
;;  2008-08-19/12:50:57                                                1.87271       99.05405       11.60155         Yes                 24.0
;;  2008-09-08/17:01:41                                                2.51951       61.53185       10.34733         Yes                 21.0
;;  2008-07-14/21:55:45                                                1.40825      136.74590       10.34374         Yes                 12.0
;;  2008-07-14/21:58:10                                                1.40825      136.74590       10.34374         Yes                 27.0
;;  2008-08-19/21:51:45                                                2.50447      151.28587       17.68887         Yes                 25.0
;;  2008-09-08/20:25:22                                                2.84599      207.16648       10.41375         Yes                 36.0

;;  Define <Bo>_up for events with enhancements
bo_up_all      = [[  -4.45233d0,  -0.06901d0,  -1.15697d0],$
                  [  -4.45233d0,  -0.06901d0,  -1.15697d0],$
                  [  -4.39718d0,   0.28863d0,   0.06444d0],$
                  [  -1.93209d0,  -0.12498d0,   0.49713d0],$
                  [   2.57605d0,   1.74533d0,  -1.17876d0],$
                  [  -0.59589d0,   2.11973d0,   1.65043d0],$
                  [   2.24290d0,   1.82921d0,  -2.58035d0],$
                  [   2.67225d0,  -2.01985d0,  -0.68892d0],$
                  [   2.67225d0,  -2.01985d0,  -0.68892d0],$
                  [  -4.45233d0,  -0.06901d0,  -1.15697d0],$
                  [   2.57605d0,   1.74533d0,  -1.17876d0] ]
;;  Define <Vbulk>_up for events with enhancements
Vi_up_all      = [[ -469.44272d0,  34.38181d0,   1.61049d0],$
                  [ -469.44272d0,  34.38181d0,   1.61049d0],$
                  [ -467.18404d0,  77.76149d0,  10.80489d0],$
                  [ -425.21411d0,  51.14974d0,  17.56595d0],$
                  [ -485.02222d0,  96.29847d0,   9.82804d0],$
                  [ -537.10808d0,  66.54217d0,  -3.81991d0],$
                  [ -524.98055d0,  82.47949d0,  20.57287d0],$
                  [ -611.82270d0,  67.34560d0,  34.61422d0],$
                  [ -611.82270d0,  67.34560d0,  34.61422d0],$
                  [ -469.44272d0,  34.38181d0,   1.61049d0],$
                  [ -485.02222d0,  96.29847d0,   9.82804d0] ]
;;  fix form
bo_up_all      = TRANSPOSE(bo_up_all)
Vi_up_all      = TRANSPOSE(Vi_up_all)
;;  Define <Ni>_up for events with enhancements
ni_up_all      = [ 2.50447d0, 2.50447d0, 2.19373d0, 0.98637d0, 2.84599d0, 1.87271d0,  $
                   2.51951d0, 1.40825d0, 1.40825d0, 2.50447d0, 2.84599d0]
;;  Define <Ti>_up for events with enhancements
Ti_up_all      = [ 151.28587d0, 151.28587d0, 235.13506d0, 397.24945d0, 207.16648d0,   $
                    99.05405d0,  61.53185d0, 136.74590d0, 136.74590d0, 151.28587d0,   $
                   207.16648d0]
;;  Define <Te>_up for events with enhancements
Te_up_all      = [ 17.68887d0, 17.68887d0, 20.04340d0, 22.39241d0, 10.41375d0,        $
                   11.60155d0, 10.34733d0, 10.34374d0, 10.34374d0, 17.68887d0,        $
                   10.41375d0]
;;  Define Bo_max value associated with TIFP
bmax_tifp      = [ 10.0d0, 27.0d0, 14.5d0, 16.0d0, 17.0d0, 24.0d0, 21.0d0, 12.0d0,    $
                   27.0d0, 25.0d0, 36.0d0]

















