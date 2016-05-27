;+
;*****************************************************************************************
;
;  FUNCTION :   coord_trans_geos.pro
;  PURPOSE  :   Returns the transformation matricies for converting from one
;                 coordinate system to another, given the dates and times desired.  The
;                 relevant coordinate system transformations do not require position
;                 vectors, thus the list of possible coordinates is limited.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               my_str_date.pro
;               doy_convert.pro
;               eulerf.pro        => Located at bottom of program
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               date = '082896'
;               time = '16:44:57.8160'   ; => UTC time, or 16:46:00 in TT
;               coord_trans_geos,DATE=date,UT_TIME=time,ROT_MAT=rot_mat
;
;  KEYWORDS:    
;               DATE       :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               UT_TIME    :  String defining the UT of interest for determining the
;                               Julian Day ['HH:MM:SS.ssss']
;               TIME_DATE  :  String defining date AND time of interest
;                               ['YYYY-MM-DD/HH:MM:SS']
;               ROT_MAT    :  Set to a named variable in which to return the
;                               rotation matricies structure
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               See coord_trans_documentation.txt for explanation of each 
;                 coordinate system.  Calculations come from the paper:
;
;                  M. Fränz and D. Harper (2002), "Heliospheric Coordinate Systems," 
;                    Planetary and Space Science, Vol. 50, pages 217-233.
;               *******************************
;               **List of acronyms in program**
;               *******************************
;               TAI      :  International Atomic Time
;               UTC      :  Coordinated Universal Time
;               UT1      :  Universal Time, defined by mean solar day
;               TDB      :  Barycentric Dynamical Time
;                             Defined as:  TDB = UTC + 32.184 + ∆A
;                             {where: ∆A = leap seconds elapsed to date}
;               **********************************
;               **List of definitions in program**
;               **********************************
;               subterrestrial pt. = Apparent center of the visible disk, from Earth,
;                                      of the Sun whose heliocentric longitude is the
;                                      apparent longitude of the Earth (defined in
;                                      Sect. 3.2.1 of Fränz)
;
;               1)  Corrections to Fränz and Harper [2002] show that the numerical
;                     example in Appendix B should have said 16:46:00 TT, NOT
;                     16:46:00 UTC
;               2)  For higher precision expansions, look at:
;                     Explanatory Supplement to the Astronomical Ephemeris (ESAE)
;                       http://aa.usno.navy.mil/data/
;                     and the Astronomical Almanac (AA)
;                       http://asa.usno.navy.mil/
;               3)  e_0J2000 = 23.439279444444 degrees as of 2009 (AA)
;                     [Fränz and Harper use: 23.439291111111]
;               4)  See also:  
;                     J.L. Simon et. al. (1994), "Numerical Expressions for precession
;                       formulae and mean elements for the Moon and the planets," 
;                       Astron. Astrophys. Vol. 282, pages 663-683.
;               5)  See also:  
;                     J.H. Lieske et. al. (1977), "Expressions for the Precession
;                       Quantities Based upon the IAU (1976) System of Astronomical
;                       Constants," Astron. Astrophys. Vol. 58, pages 1-16.
;
;   CREATED:  08/03/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/03/2010   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO coord_trans_geos,DATE=date,UT_TIME=uttime,TIME_DATE=time_date,ROT_MAT=rot_mat

;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(time_date) THEN BEGIN
  date_struct = time_struct(REFORM(time_date[0]))
  yyr         = STRTRIM(STRING(FORMAT='(I4.4)',date_struct.YEAR),2)   ; => 'YYYY'
  mmn         = STRTRIM(STRING(FORMAT='(I2.2)',date_struct.MONTH),2)  ; => 'MM'
  ddy         = STRTRIM(STRING(FORMAT='(I2.2)',date_struct.DATE),2)   ; => 'DD'
  IF NOT KEYWORD_SET(date) THEN date = mmn[0]+ddy[0]+STRMID(yyr[0],2L,2L)  ; => 'MMDDYY'
  unix_time   = time_double(date_struct)
ENDIF
;-----------------------------------------------------------------------------------------
; -Determine date of interest
;-----------------------------------------------------------------------------------------
mydate = my_str_date(DATE=date)
date   = mydate.S_DATE     ; -('MMDDYY')
mdate  = mydate.DATE       ; -('YYYYMMDD')
tdate  = mydate.TDATE      ; => 'YYYY-MM-DD'
ldate  = mdate
yyr    = STRMID(date,4,2)  ; -('YY')
mmn    = STRMID(date,0,2)  ; -('MM')
ddy    = STRMID(date,2,2)  ; -('DD')
;-----------------------------------------------------------------------------------------
; -Find Day of Year (DOY) and corresponding Julian Day number
;-----------------------------------------------------------------------------------------
;jjd  = 1d0
mdoy = doy_convert(YEAR=yyr,MONTH=mmn,DAY=ddy,DATE=date,DOY=doy,$
                   JULIAN=jjd,UNIX_TIME=unix_time,UT_TIME=uttime)
;-----------------------------------------------------------------------------------------
; -Define some constants
;-----------------------------------------------------------------------------------------
astrounit   = 149597871464d0      ; => Astronomical Unit (m) [from AA, 2009 constants]
rad_earth   = 6378136.6d0         ; => Earth Radius (m)      [from AA, 2009 constants]
newtonsG    = 6.67428d-11         ; => Gravitational Constant [m^(3) kg^(-1) s^(-2)]
mass_E      = 5.9721986d24        ; => Mass of Earth (kg)
mass_s      = 1.9884d30           ; => Mass of sun (kg)
mu_M        = 0.0123000383d0      ; => Moon-Earth mass ratio
mumu        = mu_M/(1d0 + mu_M)
kk          = 0.01720209895d0     ; => SQRT(Newton's G) [AU^(3/2) M_sun^(-1/2) day^(-1)]
mu_energy   = kk^2*(mass_E + mass_s)
ct_AU       = 499.0047863852d0    ; => Time for light to travel 1 AU [seconds]
; => Section 5.8.3 of Simon et. al. [1994]
semi_aEMB   = 1.0000010178d0      ; => Semi-major axis of EMB orbit in HAE_J2000
; => Fränz Table 4
;semi_aEMB   = 1.0000010d0         ; => Semi-major axis of EMB orbit in HAE_J2000
energy_E    = -1d0*mu_energy/(semi_aEMB*astrounit)

astd        = 1d0/36d2            ; => Conversion factor from arc sec. to degrees
amtd        = 1d0/6d1             ; => Conversion factor from arc min. to degrees
dtor        = !DPI/18d1           ; => Conversion factor from degrees to radians
;-----------------------------------------------------------------------------------------
; -Define the variables
;-----------------------------------------------------------------------------------------
aaa        = 0d0  ; => Correction to lge for light aberration [~20"]                     ||  (immediately after Eq. for Lamda_s)
tto        = 0d0  ; => Julian Centuries                                                  ||  (Eq. 2 of Fränz)
ddo        = 0d0  ; => Epoch day # defined from J2000.0                                  ||  (Eq. 1 of Fränz)
yyo        = 0d0  ; => Julian years                                                      ||  (Eq. 2 of Fränz)
e_0J2000   = 0d0  ; => Obliquity of the ecliptic at epoch J2000.0 w/rt mean at J2000.0   ||  (Eq. 3 of Fränz)
e_0D       = 0d0  ; => Mean obliquity of the ecliptic of date w/rt mean equator of date  ||  (Eq. 4 of Fränz)
e_D        = 0d0  ; => True obliquity of date                                            ||  (in paragraph just after Eq. 4 of Fränz)
                  ;     [also called the ecliptic plane of date]
del_e      = 0d0  ; => Nutation effects of the obliquity                                 ||  (Eq. 5 of Fränz)
del_psi    = 0d0  ; => Longitudinal nutation                                             ||  (Eq. 6 of Fränz)
iio        = 0d0  ; => Inclination of solar equator [rad]                                ||  (Eq. 14 of Fränz)
gge        = 0d0  ; => Mean anomaly for the EMB [Earth-Moon Barycenter]                  ||  (just after Eq. 36 of Fränz)
Omega_s    = 0d0  ; => Longitude of ascending node                                       ||  (Eq. 14 of Fränz)
Lamda_s    = 0d0  ; => Ecliptic longitude or Apparent longitude of Earth                 ||  (2nd paragraph after Eq. 15 of Fränz)
Lamda_geo  = 0d0  ; => Geometric ecliptic longitude                                      ||  (Eq. 36 of Fränz)
theta_s    = 0d0  ; => Angular offset of heliographic prime meridian crossing pt.        ||
                  ;     on the subterrestrial pt. of the solar disc and                  ||
                  ;     the ascending node                                               ||  (Eq. 17 of Fränz)
theta_gms  = 0d0  ; => The hour angle between the meridian of Greenwich and the          ||
                  ;     mean equinox of date at 00:00 UT1                                ||  (Eq. 20 of Fränz)
Lamda_mean = 0d0  ; => Mean Longitude in HAE_J2000                                       ||  (Table 4 of Fränz)
Lamda_EMB  = 0d0  ; => Mean Longitude of EMB in HAE_J2000 from position vector in HAE_J2000
Omega_bar  = 0d0  ; => Longitude of periapsis in HAE_J2000                               ||  (Table 4 of Fränz)
incl_EMB   = 0d0  ; => Inclination of EMB                                                ||  (Table 4 of Fränz)
Omega_EMB  = 0d0  ; => Ascending node of EMB                                             ||  (Table 4 of Fränz)
ecc_EMB    = 0d0  ; => Eccentricity of EMB                                               ||  (Table 4 of Fränz)
;-----------------------------------------------------------------------------------------
; => Precession Constants and Variables
;-----------------------------------------------------------------------------------------
pi_A      = 0d0  ; => Inclination of the ecliptic plane of date with respect to the     ||  (Eq. 8 of Fränz)
                 ;      ecliptic plane at another date
Ppi_A     = 0d0  ; => Ascending node longitude of " "                                   ||  (Eq. 8 of Fränz)
p_A       = 0d0  ; => Diff. in the angular distances of the vernal equinoxes from the   ||  (Eq. 8 of Fränz)
                 ;      ascending node
;#########################################################################################
; => Precession Matrix = eulerf(Ppi_A,pi_A,-1d0*p_A - Ppi_A,/DEG)                       ||  (Eq. 9 of Fränz)
;      for transforming from HAE_J2000 to HAE_D
;#########################################################################################
delaunay  = 0d0  ; => Delaunay Argument D from Sect. 3.5 of Simon et. al., [1994]
r_E       = 0d0  ; => Heliocentric position of the Earth (km)                           ||  (Eq. 32 of Fränz)
r_EMB     = 0d0  ; => Heliocentric position of Earth-Moon Barycenter (km) in HAE_J2000
Lambda_E  = 0d0  ; => Longitude of Earth-Moon Barycenter (deg)                          ||  (Eq. 32 of Fränz)
r_geo     = 0d0  ; => ||  (Eq. 36 of Fränz)
;#########################################################################################
; => Eq. 32 of Fränz describes the rotation of the Earth around the Earth-Moon Barycenter
;      where in vector form:  r_E[j] = r_EMB[j] - r_gM[j] * ( mu_M/(1d0 + mu_M) )
;      {where r_gM is the geocentric position of the Moon}
;#########################################################################################
;-----------------------------------------------------------------------------------------
; -Define Earth Magnetic Pole Variables
;-----------------------------------------------------------------------------------------
lamda_Dip = 0d0   ; => Geographic longitude of Earth's magnetic pole                    ||  (Eq. 22 of Fränz)
Phi_Dipol = 0d0   ; => Geographic latitude of Earth's magnetic pole                     ||  (Eq. 22 of Fränz)
dip_mom   = 0d0   ; => Dipole moment of the Earth                                       ||  (Eq. 22 of Fränz)
geo_pos   = 0d0   ; => Geographic position of Earth's dipole                            ||  (Sec. 3.3 of Hapgood [1992])
;-----------------------------------------------------------------------------------------
; -Find relevant parameters for coordinate conversions
;-----------------------------------------------------------------------------------------
r_EMB       = astrounit*semi_aEMB*1d-3

ddo         = jjd[0] - 2451545d0                  ; => Ok if negative (different approach)
tto         = ddo[0]/36525d0
yyo         = ddo[0]/36525d-2

iio         = 7.25d0
aaa         = (2d1 + 0.49551d0)*astd*dtor  ; ~20 arc seconds (degrees)
;aaa         = 2d1/36d2*(!DPI/18d1)             ; ~20 arc seconds (degrees)
e_0J2000    = 23d0 + 26d0*amtd + 21.448d0*astd
e_0D        = e_0J2000 - (46.8150d0*tto + 0.00059d0*tto^2 - 0.001813d0*tto^3)*astd

; => Corrections to Table 4. of Fränz given in Table 6 of Simon et. al. [1994]
mu          = 0.3595362d0*tto[0]/1d1 ; => Correction due to mean motions of Jupiter and Saturn
                                     ;     (Eq. 17 of Simon)
pimu        = [16002d0,21863d0,32004d0,10931d0,14529d0,16368d0,15318d0,32794d0]*mu  ; => p_i * mu from Table 6 of Simon et. al. [1994]
qimu        = [1d1,16002d0,21863d0,10931d0,1473d0,32004d0,4387d0,73d0]*mu           ; => q_i * mu from Table 6 of Simon et. al. [1994]

C_ia        = [64d0,-152d0,62d0,-8d0,32d0,-41d0,19d0,-11d0]*1d-7                    ; => C_{i}^{a} from Table 6 of Simon et. al. [1994] in meters
S_ia        = [-15d1,-46d0,68d0,54d0,14d0,24d0,-28d0,22d0]*1d-7                     ; => S_{i}^{a} from Table 6 of Simon et. al. [1994] in meters

C_la        = [-325d0,-322d0,-79d0,232d0,-52d0,97d0,55d0,-41d0]*1d-7/dtor           ; => C_{l}^{a} from Table 6 of Simon et. al. [1994] in degrees
S_la        = [-105d0,-137d0,258d0,35d0,-116d0,-88d0,-112d0,-8d1]*1d-7/dtor         ; => S_{l}^{a} from Table 6 of Simon et. al. [1994] in degrees

ia_factor   = DBLARR(8)
la_factor   = DBLARR(8)
FOR j=0L, 7L DO BEGIN
  ia_factor[j]   = C_ia[j]*COS(pimu[j]) + S_ia[j]*SIN(pimu[j])
  la_factor[j]   = C_la[j]*COS(qimu[j]) + S_la[j]*SIN(qimu[j])
ENDFOR

Lamda_EMB_correction = TOTAL(la_factor,/NAN)
semia_EMB_correction = TOTAL(ia_factor,/NAN)
;-----------------------------------------------------------------------------------------
; -Define Earth Magnetic Pole Variables
;-----------------------------------------------------------------------------------------
lamda_Dip = (288.44d0 - 0.04236d0*yyo)*!DPI/18d1
Phi_Dipol = (79.53d0 + 0.03556d0*yyo)*!DPI/18d1
geo_pos   = rad_earth[0]*[COS(Phi_Dipol)*COS(lamda_Dip),COS(Phi_Dipol)*SIN(lamda_Dip),$
                          SIN(Phi_Dipol)]
;#########################################################################################
; => From Simon et. al., [1994]
;e_0D        = e_0J2000 - (46.80927d0*astd)*tto - (0.000152d0*astd)*tto^2 + $
;              (0.0019989d0*astd)*tto^3 - (5.1d-7*astd)*tto^4 - (2.5d-8*astd)*tto^5
;#########################################################################################
semi_aEMB  += semia_EMB_correction
del_e       = 0.0026d0*COS((125d0 - 0.05295d0*ddo)*dtor) + $
              0.0002d0*COS((200.9d0 + 1.97129d0*ddo)*dtor)

del_psi     = -0.0048d0*SIN((125d0 - 0.05295d0*ddo)*dtor) - $
               0.0004d0*SIN((200.9d0 + 1.97129d0*ddo)*dtor)

e_D         = e_0D + del_e
; => Section 5.8.3 of Simon et. al. [1994]
Lamda_mean  = 100.46645683d0 + (1295977422.83429d0*astd)*tto*1d-1 - $
                (2.04411d0*astd)*(tto*1d-1)^2 - (0.00523d0*astd)*(tto*1d-1)^3 + $
                Lamda_EMB_correction
incl_EMB    = (469.97289d0*astd)*(tto*1d-1) - (3.35053d0*astd)*(tto*1d-1)^2 - $
                (0.12374d0*astd)*(tto*1d-1)^3 + (0.00027d0*astd)*(tto*1d-1)^4 - $
                (0.00001d0*astd)*(tto*1d-1)^5 + (0.00001d0*astd)*(tto*1d-1)^6
Omega_EMB   = 174.87317577d0 - (8679.27034d0*astd)*(tto*1d-1) + (15.34191d0*astd)*(tto*1d-1)^2 + $
                (0.00532d0*astd)*(tto*1d-1)^3 - (0.03734d0*astd)*(tto*1d-1)^4 - $
                (0.00073d0*astd)*(tto*1d-1)^5 + (0.00004d0*astd)*(tto*1d-1)^6
Omega_bar   = 102.93734808d0 + (11612.3529d0*astd)*(tto*1d-1) + (53.27577d0*astd)*(tto*1d-1)^2 - $
                (0.14095d0*astd)*(tto*1d-1)^3 + (0.1144d0*astd)*(tto*1d-1)^4 + $
                (0.00478d0*astd)*(tto*1d-1)^5
ecc_EMB     = 0.0167086342d0 - (0.0004203654d0)*(tto*1d-1) - (0.0000126734d0)*(tto*1d-1)^2 + $
                (1444d-10)*(tto*1d-1)^3 - (2d-10)*(tto*1d-1)^4 + (3d-10)*(tto*1d-1)^5
; => Table 4 of Fränz and Harper, [2002]
;Lamda_mean  = (100.4664568d0 + 35999.3728565d0*tto) + Lamda_EMB_correction
;incl_EMB    = 0.0130548d0*tto
;Omega_EMB   = 174.8731758d0 - 0.2410908d0*tto
;Omega_bar   = (102.9373481d0 + 0.3225654d0*tto)
;ecc_EMB     = (167086d0 - 420d0*tto)*1d-7

Omega_s     = (75.76d0 + 1.397d0*tto)
gge         = Lamda_mean - Omega_bar
Lamda_geo   = Lamda_mean + 1.915d0*SIN(gge*dtor) + 0.020d0*SIN(2d0*gge*dtor)
Lamda_s     = Lamda_geo - aaa
theta_s     = ATAN(COS(iio*dtor)*SIN((Lamda_s - Omega_s)*dtor),$
                   COS((Lamda_s - Omega_s)*dtor))*18d1/!DPI
theta_gms   = 280.46061837d0 + 360.98564736629d0*ddo + 0.0003875d0*tto^2 - 2.6d-8*tto^3

Lamda_geo   = (Lamda_geo MOD 18d1)   ; => Force to be -180 < Lamda_geo < 180
Lamda_mean  = (Lamda_mean MOD 18d1)  ; => Force to be -180 < Lamda_EMB < 180
IF (theta_s LT 0d0) THEN theta_s += 36d1
IF (ABS(theta_gms) GT 36d1) THEN BEGIN
  theta_gms = (theta_gms MOD 36d1)
  IF (theta_gms LT 0d0) THEN theta_gms += 36d1   ; => Force to be 0 < theta_gms < 360
ENDIF

nu_anom     = Lamda_mean[0] - Omega_bar[0]
ecc_anom    = ACOS((ecc_EMB + COS(nu_anom*dtor))/(1d0 + ecc_EMB*COS(nu_anom*dtor)))/dtor
; => Find the Earth's heliocentric position
;#########################################################################################
; => From Simon et. al., [1994]
;#########################################################################################
delaunay   = 297.85020420d0 + (1602961601.4603d0 - 5.8679d0*tto + 0.006609d0*tto^2 - $
                               0.00003169d0*tto^3)*tto*astd
IF (ABS(delaunay) GT 36d1) THEN delaunay = (delaunay MOD 360d0)

r_geo      = (1.00014d0 - 0.01671d0*COS(gge*dtor) - 0.00014d0*COS(2d0*gge*dtor))*astrounit
r_E        = (r_geo + 4613d3*COS(delaunay*dtor))
;r_E        = (r_EMB + 4613d0*COS(delaunay*dtor))*1d3
Lambda_E   = (Lamda_geo[0]) + 6.468d0*astd*SIN(delaunay*dtor)
;Lambda_E   = (Lamda_mean[0]) + 6.468d0*astd*SIN(delaunay*dtor)
;#########################################################################################
; => From Simon et. al., [1994]
;p_A        = (5028.8200d0*astd)*t + (1.112022d0*astd)*t^2 + (7.73d-5*astd)*t^3 - $
;             (2.353d-5*astd)*t^4 - (1.8d-8*astd)*t^5 + (2d-10*astd)*t^6
;#########################################################################################
p_A        = (5029.0966d0*tto + 1.11113d0*tto^2 - 0.000006d0*tto^3)*astd
pi_A       = (47.0029d0*tto - 0.03302d0*tto^2 + 0.000060d0*tto^3)*astd
Ppi_A      = (174d0 + 52d0*amtd + 34.982d0*astd) + (-869.8089d0 + 0.03536d0*tto)*tto*astd

theta_A    = (2004.3109d0*tto - 0.42665d0*tto^2 - 0.041833d0*tto^3)*astd
zeta_A     = (2306.2181d0*tto + 0.30188d0*tto^2 + 0.017998d0*tto^3)*astd
z_A        = (2306.2181d0*tto + 1.09468d0*tto^2 + 0.018203d0*tto^3)*astd
;-----------------------------------------------------------------------------------------
; => Test Date:  08/28/1996 at 16:46:00 TT
;
;  => TT  = UTC + (leap seconds) + 32.184(s)  [TT also called TBD]
;  => UTC = TT  - (leap seconds) - 32.184(s)
;
; => Test Date:  08/28/1996 at 16:44:57.8160 UTC
;
; PRINT, jjd, tto, FORMAT='(f25.8,f25.16)'
;         2450324.19861111      -0.0334237204350195
; => Expected values from Fränz are:
;         2450324.19861111      -0.0334237204350195
;
; => PRINT, Lamda_EMB_correction, semia_EMB_correction
;   -0.0029074025   1.4586429e-06
;
; => PRINT, delaunay, Lambda_E, semi_aEMB
;      -184.63325      -24.305543       1.0000025
; => Expected values from Fränz are:
;      -184.63320      -24.305442       1.0000025
;
; PRINT, Lamda_geo[0], e_0D[0], Omega_bar[0]
;      -24.305688       23.439726       102.92657
; => Expected values from Fränz are:
;      -24.302838       23.439726       102.92657
;
; PRINT, Omega_EMB[0], incl_EMB[0], theta_s[0], theta_gms[0]
;       174.88123  -0.00043635047       259.90181       228.68095
; => Expected values from Fränz are:
;       174.88123  -0.00043635047       259.89919       228.68095
;
; PRINT, ecc_EMB[0], r_geo[0]/astrounit, r_E[0]/astrounit
;     0.016710039       1.0099347       1.0099040
; => Expected values from Fränz are:
;     0.016710039       1.0099340       1.0099033
;
; PRINT, Lamda_mean[0], del_psi[0], del_e[0]
;      -22.769425    0.0010899629   -0.0024234765
; => Expected values from Fränz are:
;      -22.769425    0.0011126098   -0.0024222837
;
; PRINT, lamda_dip*18d1/!DPI, phi_dipol*18d1/!DPI
;       288.58158       79.411145
; => Expected values from Fränz are:
;       288.58158       79.411145
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
; => Calculate possible rotation matricies
;-----------------------------------------------------------------------------------------
T_HAEJ_HAED = DBLARR(3,3)  ; -" " HAE_J2000 to HAE_D                                    ||  (Eq. 9 of Fränz)
T_GEIJ_GEID = DBLARR(3,3)  ; -" " GEI_J2000 to GEI_D                                    ||  (Eq. 10 of Fränz)
T_HAED_HAEJ = DBLARR(3,3)  ; -" " HAE_D to HAE_J2000
T_HAED_GSE  = DBLARR(3,3)  ; -Transformation matrix from HAE_D to GSE                   ||  (Sect. 3.3.3 of Fränz)
T_HAED_HCD  = DBLARR(3,3)  ; -" " HAE_D to HCD                                          ||  (Sect. 3.2.2 of Fränz)
T_HAED_HEED = DBLARR(3,3)  ; -" " HAE_D to HEE_D                                        ||  (Sect. 3.2.2 of Fränz)
T_HAED_HEEQ = DBLARR(3,3)  ; -" " HAE_D to HEEQ                                         ||  (Sect. 3.2.2 of Fränz)
T_GEIT_GEO  = DBLARR(3,3)  ; -" " GEI_T to GEO                                          ||  (Sect. 3.3.3 of Fränz)
T_GEID_GEIT = DBLARR(3,3)  ; -" " GEI_D to GEI_T                                        ||  (Eq. 7 of Fränz)
T_GEID_GSED = DBLARR(3,3)  ; -" " GEI_D to GSE_D                                        ||  (Sect. 3.3.3 of Fränz)
T_GEID_HAED = DBLARR(3,3)  ; -" " GEI_D to HAE_D                                        ||  (Sect. 3.1 of Fränz)
T_GSE_HAED  = DBLARR(3,3)  ; -Transformation matrix from GSE to HAE_D                   ||  (Sect. 3.3.3 of Fränz)
T_HCD_HAED  = DBLARR(3,3)  ; -" " HCD to HAE_D                                          ||  (Sect. 3.2.2 of Fränz)
T_HEED_HAED = DBLARR(3,3)  ; -" " HEE_D to HAE_D                                        ||  (Sect. 3.2.2 of Fränz)
T_HEEQ_HAED = DBLARR(3,3)  ; -" " HEEQ to HAE_D                                         ||  (Sect. 3.2.2 of Fränz)

T_HAEJ_HAED = eulerf(Ppi_A,pi_A,-1d0*p_A - Ppi_A,/DEG)
T_GEIJ_GEID = eulerf(9d1 - zeta_A,theta_A,-1d0*z_A - 9d1,/DEG)

T_HAED_HAEJ = LA_INVERT(T_HAEJ_HAED)  ; => HAE_D to HAE_J2000
T_HAED_GSE  = eulerf(0d0,0d0,Lamda_geo + 18d1,/DEG)
T_GSE_HAED  = LA_INVERT(T_HAED_GSE,/DOUBLE)

euler_1     = eulerf(0d0,-1d0*e_D,0d0,/DEG)
euler_2     = eulerf(-1d0*del_psi,0d0,0d0,/DEG)
euler_3     = eulerf(0d0,e_0D,0d0,/DEG)
T_GEID_GEIT = euler_1 ## (euler_2 ## euler_3)
T_GEIT_GEO  = eulerf(0d0,0d0,theta_gms,/DEG)
T_GEID_HAED = eulerf(0d0,e_D,0d0,/DEG)

T_HAED_GSE  = eulerf(0d0,0d0,Lamda_geo + 18d1,/DEG)
T_HAED_HEED = eulerf(0d0,0d0,Lamda_geo,/DEG)
T_HAED_HEEQ = eulerf(Omega_s,iio,theta_s,/DEG)
T_HAED_HCD  = eulerf(Omega_s,iio,0d0,/DEG)

T_GEID_GSED = T_HAED_GSE ## T_GEID_HAED

T_GSE_HAED  = LA_INVERT(T_HAED_GSE,/DOUBLE)
T_HCD_HAED  = LA_INVERT(T_HAED_HCD,/DOUBLE)
T_HEED_HAED = LA_INVERT(T_HAED_HEED,/DOUBLE)
T_HEEQ_HAED = LA_INVERT(T_HAED_HEEQ,/DOUBLE)

T_GEO_GEIT  = LA_INVERT(T_GEIT_GEO,/DOUBLE)   ; -" " GEO to GEI_T
T_GEIT_GEID = LA_INVERT(T_GEID_GEIT,/DOUBLE)  ; -" " GEI_T to GEI_D
T_GEO_GSED  = T_GEID_GSED ## (T_GEIT_GEID ## T_GEO_GEIT)
; => use rotation to get GSE to GSM
edip_in_gse = REFORM(T_GEO_GSED ## geo_pos)/rad_earth[0]
psi_gsm     = ATAN(edip_in_gse[1],edip_in_gse[2])*18d1/!DPI
T_GSED_GSM  = eulerf(0d0,-1d0*psi_gsm,0d0,/DEG)
;-----------------------------------------------------------------------------------------
;  T_HAE_D ## [[x],[y],[z]]  = same as matrix multiplication on a Ti-83 or on 
;                               paper
;-----------------------------------------------------------------------------------------
rot_mat     = CREATE_STRUCT('HAED2HCD' ,T_HAED_HCD ,'HAED2GSE' ,T_HAED_GSE ,$
                            'HCD2HAED' ,T_HCD_HAED ,'GSE2HAED' ,T_GSE_HAED ,$
                            'HAED2HEED',T_HAED_HEED,'HEED2HAED',T_HEED_HAED,$
                            'HAED2HEEQ',T_HAED_HEEQ,'HEED2HAEQ',T_HEED_HAED,$
                            'GEID2GEIT',T_GEID_GEIT,'GEIT2GEO',T_GEIT_GEO,  $
                            'GEID2HAED',T_GEID_HAED,'GEID2GSED',T_GEID_GSED );,$
;                            'GSED2GSM',T_GSED_GSM)
RETURN;, rot_mat
END



;+
;*****************************************************************************************
;
;  FUNCTION :  eulerf.pro
;  PURPOSE  :  Given three angles, this program will return the Euler matrix for those
;                input angles [Note: Make sure to define the units using the keywords].
;                The format is specific to match the format given in the Fränz paper
;                cited below.
;
;  CALLED BY:   NA
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               OMEGA  :  First rotation angle about original z-axis
;               THETA  :  Second rotation angle about X'-Axis
;               PHI    :  Third rotation angle about Z"-Axix
;
;  EXAMPLES:
;
;  KEYWORDS:
;               DEG : If set, tells program the angles are in degrees (default)
;               RAD : If set, tells program the angles are in radians
;
;   CHANGED:  1)  Updated man page                               [09/15/2009   v1.0.1]
;
;  NOTES:  
;               See coord_trans_documentation.txt for explanation of each 
;                 coordinate system.  Calculations come from the paper:
;
;                  M. Fränz and D. Harper, "Heliospheric Coordinate Systems," 
;                    Planetary and Space Science Vol. 50, 217-233, (2002).
;
;   CREATED:  07/22/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/15/2009   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION eulerf,Omega,Theta,Phi,DEG=deg,RAD=rad

;*****************************************************************************************
; -Convert angles to radians
;*****************************************************************************************
IF KEYWORD_SET(rad) THEN BEGIN
  ome = Omega
  the = Theta
  phh = Phi
ENDIF ELSE BEGIN
  IF KEYWORD_SET(deg) THEN BEGIN
    ome = Omega*!DTOR
    the = Theta*!DTOR
    phh = Phi*!DTOR
  ENDIF ELSE BEGIN
    print,'Program assumed you sent in angles in degrees!'
    ome = Omega*!DTOR
    the = Theta*!DTOR
    phh = Phi*!DTOR    
  ENDELSE
ENDELSE
;*****************************************************************************************
; -Define cosine and sine of each angle
;*****************************************************************************************
come = COS(ome)
cthe = COS(the)
cphi = COS(phh)
some = SIN(ome)
sthe = SIN(the)
sphi = SIN(phh)

myeuler = [[    cphi*come - sphi*some*cthe    ,  cphi*some + sphi*come*cthe  , sphi*sthe ],$
           [-1d0*(sphi*come + cphi*some*cthe) , -sphi*some + cphi*come*cthe  , cphi*sthe ],$
           [            some*sthe             ,        -1d0*come*sthe        ,    cthe   ]]

;myeuler = [[come*cthe - some*sthe*cphi   ,  come*sthe + some*cthe*cphi, some*sphi ],$
;           [-(some*cthe + come*sthe*cphi), -some*sthe + come*cthe*cphi, come*sphi ],$
;           [         sthe*sphi           ,         -cthe*sphi         ,   cphi    ] ]

RETURN, myeuler
END
