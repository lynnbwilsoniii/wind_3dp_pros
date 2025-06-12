;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_euler_rmat_helio_calc.pro
;  PURPOSE  :   This routine constructs the Euler rotation matrices to convert between
;                 numerous heliospheric coordinate bases.  Note the matrices are rank-2
;                 tensors and only rotate the coordinate basis.  They do not translate or
;                 transform into a new reference frame.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               utc_to_julian_day.pro
;               eulerf.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               UTC_IN   :  Scalar [string] defining a UTC time with format:
;                             'YYYY-MM-DD/hh:mm:ss.xxx'
;                             where the fraction of seconds is optional
;
;  EXAMPLES:    
;               [calling sequence]
;               rmats = lbw_euler_rmat_helio_calc(utc_in [,HCD_POS=hcd_pos])
;
;  KEYWORDS:    
;               HCD_POS  :  [3]-Element [numeric] array of positions in Heliocentric of
;                             Date (HCD) coordinate basis
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  List of initialisms/acronyms in for time conventions:
;                 JD   :  Julian Day Number = # of 86400 second days since 12:00:00
;                           (Greenwich mean noon) on Jan. 1, 4713 B.C.
;                           {1 Julian century = 36525 days, each 86400 seconds long}
;                 TAI  :  International Atomic Time
;                           --> measures time according to a number of atomic clocks.
;                           There are exactly 86400 TAI seconds in a TAI day.  The TAI
;                           second is based on the Earth's average rotation rate between
;                           1750 and 1892.  A UT1 day is now a couple of milliseconds
;                           longer (on average) than is a TAI day thanks to the slowing
;                           of the Earth's rotation rate.
;                           TAI = UTC + ∆A
;                 ∆A   :  total algebraic sum of leap seconds to the date/time of interest
;                 UT1  :  Universal Time, defined by mean solar day
;                           --> measures the Earth's rotation with respect to the distant
;                           stars (quasars, nowadays), scaled by a factor of
;                           (one mean solar day)/(one sidereal day), with small adjustments
;                           for polar motion. There are exactly 86400 UT1 seconds in a
;                           UT1 day.
;                           --> UT1 is not really a time but a way to express Earth's
;                           rotation angle
;                 UTC  :  Coordinated Universal Time
;                           UTC  =  TAI - ∆A
;                                =  TT - ∆A - 32.184(s)
;                 TDT  :  Terrestrial Dynamical Time
;                           --> coordinate systems centered at Earth, or the proper time
;                           in general relativity parlance
;                 TDB  :  Barycentric Dynamical Time
;                           --> coordinate systems centered at solar system center, or
;                           the coordinate time in general relativity parlance
;                           TDB = UTC + 32.184 + ∆A
;                           TDB = TT + 0.001658"*sin(g) + 0.000014"*sin(2g)
;                                {where: g = Earth's mean orbital anomaly}
;                 TT   :  Terrestrial Time {SI Second}
;                           TT  =  TAI + 32.184(s)  =  (UTC + ∆A) + 32.184(s)
;                           [also known as TDT or Terrestrial Dynamical Time]
;               2)  SI Second = duration of 9,192,631,770 periods of the radiation
;                     corresponding to the transition between two hyperfine levels of
;                     the ground state of the cesium-133 atom.
;               3)  Unix time = # of seconds elapsed since Jan. 1, 1970 00:00:00 UTC
;                     **********************************
;                     *** not including leap seconds ***
;                     **********************************
;               4)  The difference between ephemeris time, TBD, and TT is < 2 ms
;               5)  The difference between UTC and UT1 is < 0.9 s.  That is:
;                     dUT = UT1 - UTC
;                     -0.9 s < dUT < 0.9 s
;               6)  The UTC_IN expects there to be leap seconds included
;               7)  Examples from https://aa.usno.navy.mil/data/JulianDate
;                     JD 2450324.197976  =  1996-08-28/16:45:05.200 UT1
;                     1996-08-28/16:44:57.800 UT1  =  JD 2450324.197891
;                     dUT = 119.5808 ms for 1996-08-28
;                     JD 2450324.19861111  =  1996-08-28/16:46:00.000 UT1
;                     -->  UT1 is roughly TT here
;
;   DEFINITIONS:
;               subterrestrial pt. = Apparent center of the visible disk, from Earth,
;                                      of the Sun whose heliocentric longitude is the
;                                      apparent longitude of the Earth (defined in
;                                      Sect. 3.2.1 of Fränz)
;  
;  Ascending Node      = The point in a satellite's orbit where it crosses the plane of 
;                          the celestial equator (or ecliptic for a sun orbiting object) 
;                          going north.
;  
;  Celestial Equator   = The plane of the Earth's equator projected onto the celestial 
;                          sphere.  The celestial equator is tilted 23.5 degrees in 
;                          relation to the plane of the Earth's orbit (the ecliptic).  
;                          The ecliptic and the celestial equator cross at two points, 
;                          the vernal equinox and the autumnal equinox.
;  
;  Ecliptic            = The plane of the Earth's orbit around the sun.  The ecliptic 
;                          is the apparent path of the sun across the celestial sphere 
;                          over the period of one year.
;  
;  Ecliptic Latitude   = The angle between the position of an astronomical body at the 
;                          time of interest and the plane of the ecliptic.
;  
;  Ecliptic Longitude  = The angle of an astronomical body from the vernal equinox, 
;                          measured EAST along the ecliptic.
;  
;  Inclination         = The angle between the plane of the orbit and the plane of the 
;                          celestial equator for Earth orbiting satellites (or the plane 
;                          of the ecliptic for sun orbiting satellites).
;  
;  Longitude of the 
;    Ascending Node    = The angle between the vernal equinox and the ascending node, 
;                          measured counter-clockwise.
;  
;  Longitude of 
;    Perigee           = The angle between the vernal equinox  and perigee (or 
;                          perihelion) measured in the direction of the object’s motion.  
;                          It is equal to the sum of the Argument of Perigee and the 
;                          Longitude of the Ascending Node
;  
;  Mean Anomaly        = The angle that a satellite would have moved since last passing 
;                          perigee (or perihelion), assuming that the satellite moved at 
;                          a constant speed in a orbit on a circle of the same area as 
;                          the actual orbital ellipse. Equal to the True Anomaly at 
;                          perigee and apogee only for elliptical orbits, or at all times 
;                          for circular orbits.
;  
;  Obliquity of 
;    the Ecliptic      = The angle between the celestial equator and the ecliptic.
;  
;  Right Ascension     = A measure of the angle between the vernal equinox and a given 
;                          astronomical object (star, planet, or satellite), as seen from 
;                          the Earth. In astronomy, Right Ascension (RA) is expressed 
;                          in units of time. The RA is the time that elapses between the 
;                          transit of the vernal equinox across any given meridian and 
;                          the transit of the given object across the same meridian, 
;                          expressed in a 24 hour format. Right Ascension can also be 
;                          expressed as the angle between the vernal equinox and the object, 
;                          measured EAST of the vernal equinox along the celestial equator.
;  
;  Right Ascension of 
;    the Ascending 
;    Node              = Another term for Longitude of the Ascending Node, It is the angle of 
;                          the ascending node measured EAST of the vernal equinox along the 
;                          celestial equator.
;  
;  Sidereal Day        = A sidereal day is the amount of time it takes the Earth to rotate 
;                          once on it axis relative to the stars. A mean sidereal day is 
;                          equal to 0.99727 mean solar days, or 23 hours, 56 minutes, 4.1 
;                          seconds. The mean solar day and the mean sidereal day differ 
;                          due to the fact the Earth is orbiting the sun in 365.2422 
;                          mean solar days, resulting in the sun moving slightly across 
;                          the celestial sphere during one solar day (24 hours)
;  
;  True Anomaly        = The actual angle that a satellite has moved since last passing 
;                          perigee (or perihelion).
;  
;  Vernal Equinox      = One of two points where the ecliptic crosses the celestial 
;                          equator, the other being the Autumnal Equinox.  The Vernal 
;                          Equinox is the point where the ecliptic crosses the celestial 
;                          equator with the sun passing from south to north.  
;                          Unfortunately for students of astronomy, the same term, 
;                          Vernal Equinox, is used to describe both the POINT on the 
;                          celestial sphere where the crossing occurs (its meaning 
;                          throughout these explanations), AND the MOMENT IN TIME when 
;                          the crossing occurs (the first moment of spring).  Which is 
;                          the intended meaning in any given sentence must be determined
;                          by the context on the statement.
;
;               Coordinate Basis Abbreviation Definitions:
;                 GEI_J2000 or GEIJ  :  Geocentric Earth Equatorial at J2000.0
;                 GEI_D              :  Mean Geocentric Earth Equatorial of date
;                 GEI_T              :  True Geocentric Earth Equatorial of date
;                 HAE_J2000 or HAEJ  :  Heliocentric Aries Ecliptic at J2000.0
;                 HAE_D              :  Heliocentric Aries Ecliptic of date
;                 HGC                :  Heliographic Coordinates of date
;                 HEE_D or HEE       :  Heliocentric Earth Ecliptic of date
;                 HEEQ               :  Heliocentric Earth Equatorial of date
;                 HCD                :  Heliocentric of date
;                 GEO                :  Geographic Coordinates of date
;                 GSE_D or GSE       :  Geocentric Solar Ecliptic of date
;                 GSM                :  Geocentric Solar Magnetospheric
;                 RTN or HGRTN       :  Heliocentric Radial-Tangential-Normal of date
;
;  REFERENCES:  
;               0)  M. Fränz and D. Harper, "Heliospheric Coordinate Systems," 
;                    Planetary and Space Science Vol. 50, 217-233, 
;                    doi:10.1016/s0032-0633(01)00119-2, 2002.
;               1)  2017 Erratum to Fränz and Harper [2002]
;               2)  J.L. Simon et. al., "Numerical Expressions for precession formulae
;                       and mean elements for the Moon and the planets," 
;                       Astron. & Astrophys. 282(2), 663-683, (ISSN 0004-6361), 1994.
;               3)  J.H. Lieske et. al., "Expressions for the Precession Quantities
;                       Based upon the IAU (1976) System of Astronomical Constants,"
;                       Astron. & Astrophys. 58(1-2), 1-16, 1977.
;               4)  https://aa.usno.navy.mil/data/JulianDate
;               5)  https://www.cnmoc.usff.navy.mil/Our-Commands/United-States-Naval-Observatory/Precise-Time-Department/Global-Positioning-System/USNO-GPS-Time-Transfer/Leap-Seconds/
;               6)  https://hpiers.obspm.fr/eop-pc/index.php
;
;   CREATED:  06/12/2025
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/12/2025   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_euler_rmat_helio_calc,utc_in,HCD_POS=hcd_pos

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Astronomical constants
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
astrounit      = 1.49597870700d+11        ;;  1 AU [m, from Mathematica 10.1 on 2015-04-21]
rad_earth      = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
newtonsG       = 6.6742800000d-11         ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1), 2018 AA values]
M_S__kg        = 1.9884000d30             ;;  Sun's mass [kg, 2015 AA values]
M_E__kg        = 5.9722000d24             ;;  Earth's mass [kg, 2015 AA values]
mu_M           = 1.23000371d-2            ;;  Moon-to-Earth mass ratio [N/A, 2021 AA value]
mumu           = mu_M/(1d0 + mu_M)
G_MsAUday      = newtonsG[0]*M_S__kg[0]*(864d2^2d0)/(astrounit[0]^3d0)
kk             = SQRT(G_MsAUday[0])       ;;  SQRT(Newton's G) [AU^(3/2) M_sun^(-1/2) day^(-1)]
ct_AU          = 499.00478384d0           ;;  Time for light to travel 1 AU [s, 2021 AA value]
;;  Section 5.8.3 of Simon et. al. [1994]
;;    EMB  =  Earth-Moon Barycenter
semi_aEMB      = 1.0000010178d0           ;;  Semi-major axis of EMB orbit in HAE_J2000
astd           = 1d0/36d2                 ;;  Conversion factor from arc sec. to degrees
amtd           = 1d0/6d1                  ;;  Conversion factor from arc min. to degrees
dtor           = !DPI/18d1                ;;  Conversion factor from degrees to radians
;;  Define some Julian day epochs
jjd1900        = 2415020d0               ;;  Julian Day number for Jan. 1st, 1900 at 12:00:00 TDB
jjd1950        = 24332825d-1             ;;  " " Jan. 1st, 1950 at 00:00:00 TDB
jjd2000        = 2451545d0               ;;  " " Jan. 1st, 2000 at 12:00:00 TDB
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Initialize and define variables
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
aaa            = (2d1 + 0.49551d0)*astd[0]*dtor[0]  ;;  Correction to lge for light aberration [~20"]                     ||  (immediately after Eq. for Lamda_s)
tto            = 0d0                                ;;  Julian Centuries                                                  ||  (Eq. 2 of Fränz)
ddo            = 0d0                                ;;  Epoch day # defined from J2000.0                                  ||  (Eq. 1 of Fränz)
yyo            = 0d0                                ;;  Julian years                                                      ||  (Eq. 2 of Fränz)
e_0J2000       = 0d0                                ;;  Obliquity of the ecliptic at epoch J2000.0 w/rt mean at J2000.0   ||  (Eq. 3 of Fränz)
e_0D           = 0d0                                ;;  Mean obliquity of the ecliptic of date w/rt mean equator of date  ||  (Eq. 4 of Fränz)
e_D            = 0d0                                ;;  True obliquity of date                                            ||  (in paragraph just after Eq. 4 of Fränz)
                                                    ;;   [also called the ecliptic plane of date]
del_e          = 0d0                                ;;  Nutation effects of the obliquity                                 ||  (Eq. 5 of Fränz)
del_psi        = 0d0                                ;;  Longitudinal nutation                                             ||  (Eq. 6 of Fränz)
iio            = 7.25d0                             ;;  Inclination of solar equator [rad]                                ||  (Eq. 14 of Fränz)
gge            = 0d0                                ;;  Mean anomaly for the EMB [Earth-Moon Barycenter]                  ||  (just after Eq. 36 of Fränz)
Omega_s        = 0d0                                ;;  Longitude of ascending node                                       ||  (Eq. 14 of Fränz)
Lamda_s        = 0d0                                ;;  Ecliptic longitude or Apparent longitude of Earth                 ||  (2nd paragraph after Eq. 15 of Fränz)
Lamda_geo      = 0d0                                ;;  Geometric ecliptic longitude                                      ||  (Eq. 36 of Fränz)
theta_s        = 0d0                                ;;  Angular offset of heliographic prime meridian crossing pt.        ||
                                                    ;;   on the subterrestrial pt. of the solar disc and                  ||
                                                    ;;   the ascending node                                               ||  (Eq. 17 of Fränz)
theta_gms      = 0d0                                ;;  The hour angle between the meridian of Greenwich and the          ||
                                                    ;;   mean equinox of date at 00:00 UT1                                ||  (Eq. 20 of Fränz)
Lamda_mean     = 0d0                                ;;  Mean Longitude in HAE_J2000                                       ||  (Table 4 of Fränz)
Lamda_EMB      = 0d0                                ;;  Mean Longitude of EMB in HAE_J2000 from position vector in HAE_J2000
Omega_bar      = 0d0                                ;;  Longitude of periapsis in HAE_J2000                               ||  (Table 4 of Fränz)
incl_EMB       = 0d0                                ;;  Inclination of EMB                                                ||  (Table 4 of Fränz)
Omega_EMB      = 0d0                                ;;  Ascending node of EMB                                             ||  (Table 4 of Fränz)
ecc_EMB        = 0d0                                ;;  Eccentricity of EMB                                               ||  (Table 4 of Fränz)
;;----------------------------------------------------------------------------------------
;;  Precession Constants and Variables
;;----------------------------------------------------------------------------------------
pi_A           = 0d0                                ;;  Inclination of the ecliptic plane of date with respect to the     ||  (Eq. 8 of Fränz)
                                                    ;;    ecliptic plane at another date
Ppi_A          = 0d0                                ;;  Ascending node longitude of " "                                   ||  (Eq. 8 of Fränz)
p_A            = 0d0                                ;;  Diff. in the angular distances of the vernal equinoxes from the   ||  (Eq. 8 of Fränz)
                                                    ;;    ascending node
;;  Precession Matrix = eulerf(Ppi_A,pi_A,-1d0*p_A - Ppi_A,/DEG)                                                ||  (Eq. 9 of Fränz)
;;    for transforming from HAE_J2000 to HAE_D
delaunay       = 0d0                                ;;  Delaunay Argument D from Sect. 3.5 of Simon et. al., [1994]
r_E            = 0d0                                ;;  Heliocentric position of the Earth (km)                           ||  (Eq. 32 of Fränz)
r_EMB          = 0d0                                ;;  Heliocentric position of Earth-Moon Barycenter (km) in HAE_J2000
Lambda_E       = 0d0                                ;;  Longitude of Earth-Moon Barycenter (deg)                          ||  (Eq. 32 of Fränz)
;;  Eq. 32 of Fränz describes the rotation of the Earth around the EMB
;;      where in vector form:  r_E[j] = r_EMB[j] - r_gM[j] * ( mu_M/(1d0 + mu_M) )
;;      {where r_gM is the geocentric position of the Moon}
;;----------------------------------------------------------------------------------------
;;  Earth Magnetic Pole Variables
;;----------------------------------------------------------------------------------------
lamda_Dip      = 0d0                                ;;  Geographic longitude of Earth's magnetic pole                    ||  (Eq. 22 of Fränz)
Phi_Dipol      = 0d0                                ;;  Geographic latitude of Earth's magnetic pole                     ||  (Eq. 22 of Fränz)
dip_mom        = 0d0                                ;;  Dipole moment of the Earth                                       ||  (Eq. 22 of Fränz)
geo_pos        = 0d0                                ;;  Geographic position of Earth's dipole                            ||  (Sec. 3.3 of Hapgood [1992])
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate Julian Day Number (JD)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
jjd            = utc_to_julian_day(utc_in)
IF (SIZE(jjd,/TYPE) NE 5) THEN RETURN,0b
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate relevant parameters for coordinate conversions
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
r_EMB          = astrounit[0]*1d-3*semi_aEMB
;;  Define the epoch day number for the epoch of date  ||  (Eq. 1 of Fränz)
ddo            = jjd[0] - jjd2000[0]                 ;;  Ok if negative (different approach)
;;  Define the Julian centuries and year               ||  (Eq. 2 of Fränz)
tto            = ddo[0]/36525d0                      ;;  T_o in most of Eqs in Fränz
yyo            = ddo[0]/36525d-2
;;  Define the distance (Julian Centuries) between a fixed epoch and J2000 epoch
;;     [T_o in Eqs 8 - 11 of Fränz]
;;  Note:  We let the 2nd fixed epoch be J1950 {= Jan. 1st, 1950 at 00:00 TBD = JD 2433282.5d0}
ddo_f_j        = jjd1950[0] - jjd2000[0]
tto_f_j        = ddo_f_j[0]/36525d0 
;;  Define the distance (Julian Centuries) between the epoch of date and J1950 epoch
;;     [Small t in Eqs 8 - 11 of Fränz]
ddo_d_f        = ddo[0] - jjd1950[0]
tto_d_f        = ddo_d_f[0]/36525d0 
;;  Define obliquities
e_0J2000       = 23d0 + 26d0*amtd[0] + 21.448d0*astd[0]
e_0D           = e_0J2000[0] - (46.8150d0*tto[0] + 0.00059d0*tto[0]^2 - 0.001813d0*tto[0]^3)*astd[0]
;;  Corrections to Table 4. of Fränz given in Table 6 of Simon et. al. [1994]
;;    (Eq. 17 of Simon)
mu             = 0.3595362d0*tto[0]/1d1                 ;;  Correction due to mean motions of Jupiter and Saturn
;;  Parameters from Table 6 of Simon et. al. [1994]
pimu           = [16002d0,21863d0,32004d0,10931d0,14529d0,16368d0,15318d0,32794d0]*mu[0]    ;;  p_i * mu
qimu           = [1d1,16002d0,21863d0,10931d0,1473d0,32004d0,4387d0,73d0]*mu[0]             ;;  q_i * mu
C_ia           = [64d0,-152d0,62d0,-8d0,32d0,-41d0,19d0,-11d0]*1d-7                         ;;  C_{i}^{a} [meters]
S_ia           = [-15d1,-46d0,68d0,54d0,14d0,24d0,-28d0,22d0]*1d-7                          ;;  S_{i}^{a} [meters]
C_la           = [-325d0,-322d0,-79d0,232d0,-52d0,97d0,55d0,-41d0]*1d-7/dtor[0]             ;;  C_{l}^{a} [degrees]
S_la           = [-105d0,-137d0,258d0,35d0,-116d0,-88d0,-112d0,-8d1]*1d-7/dtor[0]           ;;  S_{l}^{a} [degrees]
;;  Define factors dependent upon these values
ia_factor      = DBLARR(8)
la_factor      = DBLARR(8)
FOR j=0L, 7L DO BEGIN
  ia_factor[j]   = C_ia[j]*COS(pimu[j]) + S_ia[j]*SIN(pimu[j])
  la_factor[j]   = C_la[j]*COS(qimu[j]) + S_la[j]*SIN(qimu[j])
ENDFOR
;;  Define EMB corrections
Lamda_EMB_corr = TOTAL(la_factor,/NAN)
semia_EMB_corr = TOTAL(ia_factor,/NAN)
;;----------------------------------------------------------------------------------------
;;  Calculate Earth magnetic pole parameters
;;----------------------------------------------------------------------------------------
lamda_Dip      = (288.44d0 - 0.04236d0*yyo[0])*!DPI/18d1
Phi_Dipol      = (79.53d0 + 0.03556d0*yyo[0])*!DPI/18d1
geo_pos        = rad_earth[0]*[COS(Phi_Dipol[0])*COS(lamda_Dip[0]),COS(Phi_Dipol[0])*SIN(lamda_Dip[0]),$
                               SIN(Phi_Dipol[0])]
;;  From Simon et. al., [1994]
;;    e_0D        = e_0J2000 - (46.80927d0*astd)*tto - (0.000152d0*astd)*tto^2 + $
;;                  (0.0019989d0*astd)*tto^3 - (5.1d-7*astd)*tto^4 - (2.5d-8*astd)*tto^5
semi_aEMB     += semia_EMB_corr[0]
gse_pos_s      = gse_pos  + [semi_aEMB[0],0d0,0d0]*astrounit[0]/rad_earth[0]
del_e          =  0.0026d0*COS((125.0d0 - 0.05295d0*ddo[0])*dtor[0]) + $
                  0.0002d0*COS((200.9d0 + 1.97129d0*ddo[0])*dtor[0])
del_psi        = -0.0048d0*SIN((125.0d0 - 0.05295d0*ddo[0])*dtor[0]) - $
                  0.0004d0*SIN((200.9d0 + 1.97129d0*ddo[0])*dtor[0])
e_D            = e_0D[0] + del_e[0]
;;  Section 5.8.3 of Simon et. al. [1994]
Lamda_mean     = 100.46645683d0 + (1295977422.83429d0*astd[0])*tto[0]*1d-1 - $
                   (2.04411d0*astd[0])*(tto[0]*1d-1)^2d0 - (0.00523d0*astd[0])*(tto[0]*1d-1)^3d0 + $
                   Lamda_EMB_corr[0]
incl_EMB       = (469.97289d0*astd[0])*(tto[0]*1d-1)     - (3.35053d0*astd[0])*(tto[0]*1d-1)^2d0 - $
                   (0.12374d0*astd[0])*(tto[0]*1d-1)^3d0 + (0.00027d0*astd[0])*(tto[0]*1d-1)^4d0 - $
                   (0.00001d0*astd[0])*(tto[0]*1d-1)^5d0 + (0.00001d0*astd[0])*(tto[0]*1d-1)^6d0
Omega_EMB      = 174.87317577d0 - (8679.27034d0*astd[0])*(tto[0]*1d-1)     + (15.34191d0*astd[0])*(tto[0]*1d-1)^2d0 + $
                                  (   0.00532d0*astd[0])*(tto[0]*1d-1)^3d0 - ( 0.03734d0*astd[0])*(tto[0]*1d-1)^4d0 - $
                                  (   0.00073d0*astd[0])*(tto[0]*1d-1)^5d0 + ( 0.00004d0*astd[0])*(tto[0]*1d-1)^6d0
Omega_bar      = 102.93734808d0 + (11612.35290d0*astd[0])*(tto[0]*1d-1)     + (53.27577d0*astd)*(tto[0]*1d-1)^2d0 - $
                                  (    0.14095d0*astd[0])*(tto[0]*1d-1)^3d0 + ( 0.11440d0*astd)*(tto[0]*1d-1)^4d0 + $
                                  (    0.00478d0*astd[0])*(tto[0]*1d-1)^5d0
ecc_EMB        = 0.0167086342d0 - 0.0004203654d0*(tto[0]*1d-1) - 0.0000126734d0*(tto[0]*1d-1)^2d0 + $
                   1444d-10*(tto[0]*1d-1)^3d0 - 2d-10*(tto[0]*1d-1)^4d0 + 3d-10*(tto[0]*1d-1)^5d0
;;  Table 4 of Fränz and Harper, [2002] (check erratum for updates)
Omega_s0       = 75.76d0
Omega_s        = (Omega_s0[0] + 1.397d0*tto[0])
gge            = Lamda_mean[0] - Omega_bar[0]
Lamda_geo      = Lamda_mean[0] + 1.915d0*SIN(gge[0]*dtor[0]) + 0.020d0*SIN(2d0*gge[0]*dtor[0])
theta_s        = ATAN(COS(iio[0]*dtor[0])*SIN((Lamda_s[0] - Omega_s[0])*dtor[0]),$
                      COS((Lamda_s[0] - Omega_s[0])*dtor[0]))*18d1/!DPI
theta_gms      = 280.46061837d0 + 360.98564736629d0*ddo[0] + 0.0003875d0*tto[0]^2d0 - 2.6d-8*tto[0]^3d0
;;  Force some angles to fall between -180 and +180 degrees
Lamda_geo      = (Lamda_geo[0] MOD 18d1)
Lamda_s        = Lamda_geo[0] - aaa[0]
Lamda_mean     = (Lamda_mean[0] MOD 18d1)
IF (theta_s[0] LT 0d0) THEN theta_s += 36d1
IF (ABS(theta_gms[0]) GT 36d1) THEN BEGIN
  theta_gms = (theta_gms[0] MOD 36d1)
  IF (theta_gms[0] LT 0d0) THEN theta_gms += 36d1   ;;  Force to be 0 < theta_gms < 360
ENDIF
nu_anom        = Lamda_mean[0] - Omega_bar[0]
ecc_anom       = ACOS((ecc_EMB[0] + COS(nu_anom[0]*dtor[0]))/(1d0 + ecc_EMB[0]*COS(nu_anom[0]*dtor[0])))/dtor[0]
;;----------------------------------------------------------------------------------------
;;  Calculate Earth's heliocentric position
;;----------------------------------------------------------------------------------------
delaunay       = 297.85020420d0 + (1602961601.4603d0 - 5.8679d0*tto[0] + $
                 0.006609d0*tto[0]^2d0 - 0.00003169d0*tto[0]^3d0)*tto[0]*astd[0]
IF (ABS(delaunay[0]) GT 36d1) THEN delaunay = (delaunay[0] MOD 360d0)
r_E            = r_EMB[0] + 4613d0*COS(delaunay[0])
Lambda_E       = (Lamda_mean[0]) + 6.468d0*astd[0]*SIN(delaunay[0]*dtor[0])
;;  From Simon et. al., [1994]
Ppi_Afac       = 174d0 + 52d0*amtd[0] + 34.982d0*astd[0]
p_A            = ((5029.0966d0 + 2.22226d0*tto_f_j[0] - 0.000042d0*tto_f_j[0]^2)*tto_d_f[0] + $
                  (1.11113d0 - 0.000042d0*tto_f_j[0])*tto_d_f[0]^2d0 - 0.000006d0*tto_d_f[0]^3d0)*astd[0]
pi_A           = ((47.0029d0 - 0.06603d0*tto_f_j[0] + 0.000598d0*tto_f_j[0]^2d0)*tto_d_f[0] + $
                  (-0.03302d0 + 0.000598d0*tto_f_j[0])*tto_d_f[0]^2d0 + 0.000060d0*tto_d_f[0]^3d0)*astd[0]
Ppi_A          = Ppi_Afac[0] + (3289.4789d0*tto_f_j[0] + 0.60622d0*tto_f_j[0]^2d0 - $
                 (869.8089d0 + 0.50491d0*tto_f_j[0])*tto_d_f[0] + 0.03536d0*tto_d_f[0]^2d0)*astd[0]
theta_A        = ((2004.3109d0 - 0.85330d0*tto_f_j[0] - 0.000217d0*tto_f_j[0]^2d0)*tto_d_f[0] - $
                  (0.42665d0 + 0.000217d0*tto_f_j[0])*tto_d_f[0]^2d0 - 0.041833d0*tto_d_f[0]^3d0)*astd[0]
zeta_A         = ((2306.2181d0 + 1.39656d0*tto_f_j[0] - 0.000139d0*tto_f_j[0]^2d0)*tto_d_f[0] + $
                  (0.30188d0 - 0.000344d0*tto_f_j[0])*tto_d_f[0]^2d0 + 0.017998d0*tto_d_f[0]^3d0)*astd[0]
z_A            = ((2306.2181d0 + 1.39656d0*tto_f_j[0] - 0.000139d0*tto_f_j[0]^2d0)*tto_d_f[0] + $
                  (1.09468d0 + 0.000066d0*tto_f_j[0])*tto_d_f[0]^2d0 + 0.018203d0*tto_d_f[0]^3d0)*astd[0]
e_J2000A       = e_0D[0] - SIN(pi_A[0]*dtor[0])*COS(Ppi_A[0]*dtor[0])
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Construct Euler rotation matrices
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Initialize variables for rotation matrices
;;    Note that to use these in IDL, you would do:
;;      [rotated 3-vector variable] = [Rotation matrix variable] ## [original 3-vector variable]
T_HAED_GSE     = REPLICATE(d,3,3)                   ;;  Transformation matrix from HAE_D to GSE                   ||  (Sect. 3.3.3 of Fränz)
T_HAEJ_HAED    = T_HAED_GSE                         ;;  " " HAE_J2000 to HAE_D                                    ||  (Eq. 9 of Fränz)
T_GEIJ_GEID    = T_HAED_GSE                         ;;  " " GEI_J2000 to GEI_D                                    ||  (Eq. 10 of Fränz)
T_HAED_HCD     = T_HAED_GSE                         ;;  " " HAE_D to HCD                                          ||  (Sect. 3.2.2 of Fränz)
T_HAED_HEED    = T_HAED_GSE                         ;;  " " HAE_D to HEE_D                                        ||  (Sect. 3.2.2 of Fränz)
T_HAED_HEEQ    = T_HAED_GSE                         ;;  " " HAE_D to HEEQ                                         ||  (Sect. 3.2.2 of Fränz)
T_HAEJ_HCI     = T_HAED_GSE                         ;;  " " HAE_J2000 to HCI                                      ||  (Sect. 3.2.2 of Fränz)
T_GEIT_GEO     = T_HAED_GSE                         ;;  " " GEI_T to GEO                                          ||  (Sect. 3.3.3 of Fränz)
T_GEID_GEIT    = T_HAED_GSE                         ;;  " " GEI_D to GEI_T                                        ||  (Eq. 7 of Fränz)
T_GEID_HAED    = T_HAED_GSE                         ;;  " " GEI_D to HAE_D                                        ||  (Sect. 3.1 of Fränz)
T_GEID_GSED    = T_HAED_GSE                         ;;  " " GEI_D to GSE_D                                        ||  (Sect. 3.3.3 of Fränz)
T_GSE_HAED     = T_HAED_GSE                         ;;  Transformation matrix from GSE to HAE_D                   ||  (Sect. 3.3.3 of Fränz)
T_HCD_HAED     = T_HAED_GSE                         ;;  " " HCD to HAE_D                                          ||  (Sect. 3.2.2 of Fränz)
T_HEED_HAED    = T_HAED_GSE                         ;;  " " HEE_D to HAE_D                                        ||  (Sect. 3.2.2 of Fränz)
T_HEEQ_HAED    = T_HAED_GSE                         ;;  " " HEEQ to HAE_D                                         ||  (Sect. 3.2.2 of Fränz)
T_HAED_HAEJ    = T_HAED_GSE                         ;;  " " HAE_D to HAE_J2000
T_GEO_GEIT     = T_HAED_GSE                         ;;  " " GEO to GEI_T
T_GEIT_GEID    = T_HAED_GSE                         ;;  " " GEI_T to GEI_D
T_GEO_GSED     = T_HAED_GSE                         ;;  " " GEO to GSE_D
T_GSED_GSM     = T_HAED_GSE                         ;;  " " GSE_D to GSM
T_HCD_RTN      = T_HAED_GSE                         ;;  " " HCD to RTN
;;----------------------------------------------------------------------------------------
;;  Construct Euler rotation matrices
;;----------------------------------------------------------------------------------------
euler_1        = eulerf(0d0, -1d0*e_D[0], 0d0,/DEG)
euler_2        = eulerf(-1d0*del_psi[0], 0d0, 0d0,/DEG)
euler_3        = eulerf(0d0, e_0D[0], 0d0,/DEG)

T_HAED_GSE     = eulerf(0d0, 0d0, Lamda_geo[0] + 18d1,/DEG)
T_HAEJ_HAED    = eulerf(Ppi_A[0], pi_A[0], -1d0*p_A[0] - Ppi_A[0],/DEG)
T_GEIJ_GEID    = eulerf(9d1 - zeta_A[0], theta_A[0], -1d0*z_A[0] - 9d1,/DEG)
T_HAED_HCD     = eulerf(Omega_s[0], iio[0], 0d0,/DEG)
T_HAED_HEED    = eulerf(0d0, 0d0, Lamda_geo[0],/DEG)
T_HAED_HEEQ    = eulerf(Omega_s[0], iio[0], theta_s[0],/DEG)
T_HAEJ_HCI     = eulerf(Omega_s0[0], iio[0], 0d0,/DEG)
T_GEIT_GEO     = eulerf(0d0, 0d0, theta_gms[0],/DEG)
T_GEID_GEIT    = euler_1 ## (euler_2 ## euler_3)
T_GEID_HAED    = eulerf(0d0 ,e_D[0], 0d0,/DEG)
T_GEID_GSED    = T_HAED_GSE ## T_GEID_HAED
T_GSE_HAED     = LA_INVERT(T_HAED_GSE,/DOUBLE)
T_HCD_HAED     = LA_INVERT(T_HAED_HCD,/DOUBLE)
T_HEED_HAED    = LA_INVERT(T_HAED_HEED,/DOUBLE)
T_HEEQ_HAED    = LA_INVERT(T_HAED_HEEQ,/DOUBLE)
T_HAED_HAEJ    = LA_INVERT(T_HAEJ_HAED,/DOUBLE)
T_GEO_GEIT     = LA_INVERT(T_GEIT_GEO,/DOUBLE)
T_GEIT_GEID    = LA_INVERT(T_GEID_GEIT,/DOUBLE)
T_GEO_GSED     = T_GEID_GSED ## (T_GEIT_GEID ## T_GEO_GEIT)
;;  Use rotation to get GSE to GSM
edip_in_gse    = REFORM(T_GEO_GSED ## geo_pos)/rad_earth[0]
psi_gsm        = ATAN(edip_in_gse[1],edip_in_gse[2])*18d1/!DPI
T_GSED_GSM     = eulerf(0d0,-1d0*psi_gsm,0d0,/DEG)
IF (N_ELEMENTS() EQ 3) THEN BEGIN
  ;;  User provided HCD position [units are not critical]
  hcd_rxy        = SQRT(TOTAL(hcd_pos[0:1]^2,/NAN))
  hcd_phi        = ATAN(hcd_pos[1],hcd_pos[0])*18d1/!DPI
  hcd_the        = ATAN(hcd_rxy,hcd_pos[2])*18d1/!DPI
  T_HCD_RTN      = eulerf(hcd_phi[0] - 9d1,hcd_the[0],9d1,/DEG)
ENDIF ELSE BEGIN
  ;;  User did not supply an HCD position at UCT_IN time  --> return NaNs
  T_HCD_RTN      = REPLICATE(d,3,3)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
rmat_str       = CREATE_STRUCT('HAED2HCD' ,T_HAED_HCD ,'HAED2GSE' ,T_HAED_GSE ,$
                               'HCD2HAED' ,T_HCD_HAED ,'GSE2HAED' ,T_GSE_HAED ,$
                               'HAED2HEED',T_HAED_HEED,'HEED2HAED',T_HEED_HAED,$
                               'HAED2HEEQ',T_HAED_HEEQ,'HEED2HAEQ',T_HEED_HAED,$
                               'GEID2GEIT',T_GEID_GEIT,'GEIT2GEO' ,T_GEIT_GEO ,$
                               'GEID2HAED',T_GEID_HAED,'GEID2GSED',T_GEID_GSED,$
                               'GSED2GSM' ,T_GSED_GSM ,'HCD2RTN'  ,T_HCD_RTN  ,$
                               'HAEJ2HCI' ,T_HAEJ_HCI)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to User
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN,rmat_str
END

















