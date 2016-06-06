;+
;*****************************************************************************************
;
;  FUNCTION :   get_coord_list.pro
;  PURPOSE  :   Returns a list of strings defining different possible coordinate system
;                 names used by the space physics community.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               coords = get_coord_list()
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               See coord_trans_documentation.txt for explanation of each 
;                 coordinate system.  Calculations come from the paper:
;
;                  M. Fränz and D. Harper, "Heliospheric Coordinate Systems," 
;                    Planetary and Space Science Vol. 50, 217-233, (2002).
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
;                     J.L. Simon et. al., "Numerical Expressions for precession formulae
;                       and mean elements for the Moon and the planets," 
;                       Astron. Astrophys. Vol. 282, 663-683, (1994).
;               5)  See also:  
;                     J.H. Lieske et. al., "Expressions for the Precession Quantities
;                       Based upon the IAU (1976) System of Astronomical Constants,"
;                       Astron. Astrophys. Vol. 58, 1-16, (1977).
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
;    Node              = Another term for Longitude of the Ascending Node, It is the
;                          angle of the ascending node measured EAST of the vernal
;                          equinox along the celestial equator.
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
;  Solar Rotations
;                          Let R = Carrington Rotations
;                                = starts when the heliographic prime meridian crosses
;                                    the subterrestrial point of the solar disc
;                              Ø = ArcTan[Cos(i_o) Tan(lam_o - Ω_o)] = angular offset
;                                    between prime meridian and ascending node
;
;
; ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ;; => Define position dependent coordinate system names
; ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ========================================
; HGRTN = Heliocentric Radial, Tangential, Normal (or RTN)
; ========================================
;   X-Axis  :  Sun-SC line
;   Y-Axis  :  Cross-product of heliographic polar axis and +X-axis 
;   Z-Axis  :  Normal vector to Earth's Magnetopause [MV]
;
; ========================================
; DMS = Dipole Meridian System (or DM)
; ========================================
;   X-Axis  :  vector from dipole direction to SC center
;   Y-Axis  :  Cross-product of dipole polar axis and X-Axis
;
; ========================================
; SCSE = Spacecraft Solar Ecliptic
; ========================================
;   XY-Plane:  Earth mean ecliptic of date
;   X-Axis  :  projection of SC-Sun vector on XY-Plane
;   Z-Axis  :  ecliptic south pole
;
; ========================================
; SAE = Spin Axis Ecliptic
; ========================================
;   Z-Axis  :  spacecraft spin axis
;   X-Axis  :  Cross-product of ecliptic polar axis of date and Z-Axis
;
; ========================================
; SAS = Spin Axis Sun pulse
; ========================================
;   Z-Axis  :  spacecraft spin axis
;   Y-Axis  :  Cross-product of Z-Axis and SC-Sun vector
;
; ========================================
; HDZ = Used for ground magnetometers
; ========================================
;   H-Axis  :  horizontal field strength, in the plane formed by Z and GEO graphic north
;                [should be a projection onto a basis vector pointing north from station in nT]
;   D-Axis  :  field strength in the Z x X direction in nT (not degrees)
;                [should be a projection onto a basis vector perpendicular to H in the horizontal plane]
;   Z-Axis  :  downward field strength
;
; ========================================
; ENP = Spacecraft position coordinate system
; ========================================
;   E-Axis  :  sat to earth (in orbtial plane)
;   N-Axis  :  east (in orbital plane)
;   P-Axis  :  north (perpendicular to orbtial plane)
;     Defined relative to another coordinate system:
;         P_sat = spacecraft position in geocentric inertial coordinate system
;         V_sat = deriv(P_sat)   (spacecraft velocity in the same coordinate system.)
;
;         P_enp = P_sat cross V_sat
;         E_enp = -P_sat
;         N_enp = P_enp cross P_sat
;
; ========================================
; FAC = Field-Aligned Coordinates
; ========================================
;   Z-Axis  :  parallel to Bo (ambient B-field vector)
;   Y-Axis  :  (Bo x V), where V is the 2nd vector used to create basis
;   X-Axis  :  (Bo x V) x Bo
;
; ========================================
; RXY = Spacecraft Centric Solar Magnetospheric
; ========================================
;   X-Axis  :  Radial position vector projected into the XY-GSM-plane
;                [normalized to 1; > 0 points from Earth to SC]
;   Z-Axis  :  Z-GSM (see below)
;
; ========================================
; XGSE = Field-Aligned Coordinates
; ========================================
;   Z-Axis  :  parallel to Bo (ambient B-field vector)
;   Y-Axis  :  (Bo x Xgse)
;   X-Axis  :  (Bo x Xgse) x Bo
;
; ========================================
; SSE = Moon-Sun Ecliptic
; ========================================
;   X-Axis  :  Moon-Sun line (Earth's moon)
;   Y-Axis  :  Cross-product of ecliptic north and X-Axis
;
; ========================================
; MVA = Minimum Variance Coordinates
; ========================================
;   Z-Axis  :  parallel to minimum variance eigenvector
;   Y-Axis  :  parallel to intermediate variance eigenvector
;   X-Axis  :  parallel to maximum variance eigenvector
;
;
; ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ;; => Define THEMIS specific list of coordinate system names
; ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ========================================
; SPG = Spinning Probe Geometric [for THEMIS]
; ========================================
;   Origin  :  the geometric center of the separation plane - the lowest reaching
;                portion of the attachment ring (whose center is aligned with Z-axis)
;                - of the probe
;   Z-Axis  :  the probe normal to the attachment plane
;   X-Axis  :  normal to face sheet of Solar Panel 1
;
; ========================================
; SSL = Spinning SunSensor - L - vectorZ [for THEMIS]
; ========================================
;   X-Axis  :  points towards the Sun Sensor look direction
;   Z-Axis  :  Z-geometric axis of probe
;
; ========================================
; DSL = Despun SunSensor - L - vectorZ [for THEMIS]
; ========================================
;   Z-Axis  :  spacecraft spin axis
;   Y-Axis  :  normal to Z-axis and Spacecraft Sun direction viewed from probe
;
;
; ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ;; => Define Geocentric systems
; ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ========================================
; GEO = Geographic Coordinates
; ========================================
;   XY-Plane:  true Earth equator of date
;   X-Axis  :  intersection of Greenwich meridian and Earth equator
;
; ========================================
; GSE = Geocentric Solar Ecliptic
; ========================================
;   XY-Plane:  Earth mean ecliptic of date
;   X-Axis  :  Earth-Sun line of date
;
; ========================================
; GSM = Geocentric Solar Magnetospheric
; ========================================
;   X-Axis  :  Earth-Sun line of date
;   Z-Axis  :  Projection of northern dipole axis on GSE_D YZ-Plane
;
; ========================================
; LMN = Boundary Normal Coordinates
; ========================================
;   Y-Axis  :  Cross-product of +Z-axis with GSM Z-axis
;   Z-Axis  :  Normal vector to Earth's Magnetopause [MV]
;
; ========================================
; SM = Solar Magnetic
; ========================================
;   Z-Axis  :  Northern Earth dipole axis of date
;   Y-Axis  :  Cross product of Z-Axis and Earth-Sun vector of date
;
; ========================================
; MAG = Geomagnetic
; ========================================
;   Z-Axis  :  Northern Earth dipole axis of date
;   Y-Axis  :  Cross product of Geographic North Pole of date and Z-Axis
;
;
; ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ;; => Define Heliographic systems
; ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ========================================
; HGC = Heliographic Coordinates
; ========================================
;   latitude  = solar equator towards north -> positive
;   longitude = positive westward (i.e. direction of planetary motion) from the
;                solar prime meridian [passed through the ascending node on
;                the ecliptic of date on January 1st, 1854 noon (JD 2398220.0)]
;   XY-Plane:  solar equator of date
;   X-Axis  :  ascending node on January 1st, 1854 noon (JD 2398220.0)
;
; ========================================
; HEED = Heliocentric Earth Ecliptic (of date)
; ========================================
;   XY-Plane:  Earth mean ecliptic of date
;   X-Axis  :  Sun-Earth vector
;
; ========================================
; HEEQ = Heliocentric Earth Equatorial
; ========================================
;   XY-Plane:  Solar equator of date
;   X-Axis  :  Intersection of solar equator and solar central meridian of date
;
; ========================================
; HCI = Heliocentric Inertial
; ========================================
;   XY-Plane:  Solar equator of J2000.0
;   X-Axis  :  Solar ascending node on ecliptic of J2000.0
;
; ========================================
; HCD = Heliocentric of Date
; ========================================
;   XY-Plane:  Solar equator of date
;   X-Axis  :  Solar ascending node on ecliptic of date 
;
;
; ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ;; => Define Celestial systems
; ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ========================================
; GEI_J2 = Geocentric Earth Equatorial
; ========================================
;   XY-Plane:  Earth mean equator at J2000.0
;   X-Axis  :  Earth-Sun line of vernal equinox at epoch J2000.0 
;              [i.e. first point of Aries]
;
; ========================================
; GEI_D = Mean Geocentric Earth Equatorial
; ========================================
;   XY-Plane:  Earth mean equator of date
;   X-Axis  :  Earth-Sun line of vernal equinox at epoch J2000.0
;
; ========================================
; GEI_T = True Geocentric Earth Equatorial
; ========================================
;   XY-Plane:  Earth true equator of date
;   X-Axis  :  Earth-Sun line of vernal equinox at epoch J2000.0
;
; ========================================
; HAE_J2 = Heliocentric Aries Ecliptic
; ========================================
;   XY-Plane:  Earth mean ecliptic at J2000.0
;   X-Axis  :  Earth-Sun line of vernal equinox at epoch J2000.0 
;              [i.e. first point of Aries]
;
; ========================================
; HAE_D = Heliocentric Aries Ecliptic
; ========================================
;   XY-Plane:  Earth mean ecliptic of date
;   X-Axis  :  Earth-Sun line of vernal equinox at epoch J2000.0 
;              [i.e. first point of Aries]
;
;   CREATED:  04/06/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/06/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_coord_list

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
tags         = ['POS_COORDS','THEMIS_COORDS','GEO_COORDS','HELIO_COORDS','CELEST_COORDS']
;;----------------------------------------------------------------------------------------
;; => Define position dependent coordinate system names
;;----------------------------------------------------------------------------------------
coord_slist  = ['rtn','dms','scse','sae','sas','hdz','enp','fac','rxy','xgse','sse',   $
                'mva','minvar']

coord_llist  = ['Heliocentric Radial, Tangential, Normal','Dipole Meridian System',    $
                'Spacecraft Solar Ecliptic','Spin Axis Ecliptic','Spin Axis Sun pulse',$
                'HDZ','ENP','Field-Aligned Coordinates',                               $
                'Spacecraft Centric Solar Magnetospheric','Field-Aligned Coordinates', $
                'Moon-Sun Ecliptic','Minimum Variance Coordinates',                    $
                'Minimum Variance Coordinates']
;;----------------------------------------------------------------------------------------
;; => Define THEMIS specific list of coordinate system names
;;----------------------------------------------------------------------------------------
themis_slist = ['ssl','dsl','spg']
themis_llist = ['Spinning SunSensor-L-vectorZ','Despun SunSensor-L-vectorZ',$
                'Spinning Probe Geometric']
;;----------------------------------------------------------------------------------------
;; => Define Geocentric systems
;;----------------------------------------------------------------------------------------
geocen_slist = ['geo','gse','gsm','lmn','sm','mag']
geocen_llist = ['Geographic Coordinates','Geocentric Solar Ecliptic',              $
                'Geocentric Solar Magnetospheric','Boundary Normal Coordinates',   $
                'Solar Magnetic','Geomagnetic']
;;----------------------------------------------------------------------------------------
;; => Define Heliographic systems
;;----------------------------------------------------------------------------------------
heliog_slist = ['hgc','heed','heeq','hci','hcd']
heliog_llist = ['Heliographic Coordinates','Heliocentric Earth Ecliptic',      $
                'Heliocentric Earth Equatorial','Heliocentric Inertial',       $
                'Heliocentric of Date']
;;----------------------------------------------------------------------------------------
;; => Define Celestial system names
;;----------------------------------------------------------------------------------------
celest_slist = ['geij','geid','geit','haej','haed']
celest_llist = ['Geocentric Earth Equatorial','Mean Geocentric Earth Equatorial',  $
                'True Geocentric Earth Equatorial',                                $
                'Heliocentric Aries Ecliptic at J2000',                            $
                'Heliocentric Aries Ecliptic of Date']
;-----------------------------------------------------------------------------------------
; => Create return structure
;-----------------------------------------------------------------------------------------
tags        = ['POS_COORDS','THEMIS_COORDS','GEO_COORDS','HELIO_COORDS','CELEST_COORDS']
sstruct     = CREATE_STRUCT(tags,coord_slist,themis_slist,geocen_slist,heliog_slist,$
                            celest_slist)
lstruct     = CREATE_STRUCT(tags,coord_llist,themis_llist,geocen_llist,heliog_llist,$
                            celest_llist)
struct      = {SHORT:sstruct,LONG:lstruct}

RETURN,struct
END

