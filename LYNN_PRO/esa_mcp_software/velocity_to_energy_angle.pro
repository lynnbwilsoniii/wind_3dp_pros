;+
;*****************************************************************************************
;
;  FUNCTION :   velocity_to_energy_angle.pro
;  PURPOSE  :   This routine takes an [N,3]-element array of velocities and converts them
;                 to the corresponding energies, azimuthal, and poloidal angles for
;                 THEMIS ESA, Wind 3DP, etc. type detectors.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               is_a_3_vector.pro
;               mag__vec.pro
;               energy_to_vel.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               KVEC      :  [N,3]- or [3]-Element [float/double] array defining the
;                              3-vector velocity [km/s] to transform into the
;                              corresponding energies [eV], azimuthal [deg], and
;                              poloidal [deg] angles
;               MASS      :  Scalar [numeric] defining the particle mass [eV/c^2]
;                              used for energy conversion
;                              [Default = /ELECTRON]
;
;  EXAMPLES:    
;               [calling sequence]
;               struct = velocity_to_energy_angle(kvec [,mass] [,/ELECTRON] [,/PROTON] $
;                                                 [,/NEUTRON] [,/ALPHA_P])
;
;  KEYWORDS:    
;               ELECTRON  :  If set, use electron mass
;                              [eV/ckm^2, ckm = c in units of km/s]
;                              [Default = TRUE]
;               PROTON    :  If set, use proton mass [eV/ckm^2]
;                              [Default = FALSE]
;               NEUTRON   :  If set, use neutron mass [eV/ckm^2]
;                              [Default = FALSE]
;               ALPHA_P   :  If set, use alpha-particle mass [eV/ckm^2]
;                              [Default = FALSE]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Does not currently allow for masses smaller than the electron
;               2)  Does not currently allow for superluminal speeds
;               3)  **  Speeds must be in units of km/s  **
;               4)  Mass Units:  eV/c^2, with c having units of km/s
;               5)  See also:  energy_angle_to_velocity.pro
;
;  REFERENCES:  
;               1)  Carlson et al., "An instrument for rapidly measuring
;                      plasma distribution functions with high resolution,"
;                      Adv. Space Res. Vol. 2, pp. 67-70, (1983).
;               2)  Curtis et al., "On-board data analysis techniques for
;                      space plasma particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372, (1989).
;               3)  Lin et al., "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125, (1995).
;               4)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst., (1998).
;               5)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, (2008).
;               6)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, (2008).
;               7)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;
;   CREATED:  12/01/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/01/2015   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION velocity_to_energy_angle,kvec,mass,ELECTRON=elec,PROTON=prot,$
                                  NEUTRON=neutron,ALPHA_P=alpha_p

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, is_a_3_vector, mag__vec, energy_to_vel
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
ckm            = c[0]*1d-3                ;;  m --> km
ckm2           = ckm[0]^2
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
ma_eV          = ma[0]*c[0]^2/qq[0]       ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
me_eV          = me[0]*c[0]^2/qq[0]       ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mn_eV          = mn[0]*c[0]^2/qq[0]       ;;  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c[0]^2/qq[0]       ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV/ckm^2 = eV km^(-2) s^(2)]
me_eVkms2      = me_eV[0]/ckm2[0]         ;;  Electron mass [eV km^(-2) s^(2)]
mp_eVkms2      = mp_eV[0]/ckm2[0]         ;;  Proton mass [eV km^(-2) s^(2)]
mn_eVkms2      = mn_eV[0]/ckm2[0]         ;;  Neutron mass [eV km^(-2) s^(2)]
ma_eVkms2      = ma_eV[0]/ckm2[0]         ;;  Alpha-Particle mass [eV km^(-2) s^(2)]
def_mass       = me_eVkms2[0]             ;;  Default mass [eV km^(-2) s^(2)]
keymasses      = [me_eVkms2[0],mp_eVkms2[0],mn_eVkms2[0],ma_eVkms2[0]]
;;  Dummy error messages
no_inpt_msg    = 'User must supply either a single or arrays of 3-vectors'
badvfor_msg    = 'Incorrect input format:  KVEC must be a [N,3]-element [numeric] arrays of 3-vectors'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (is_a_number(kvec,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_3_vector(kvec,V_OUT=vv2d,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,badvfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (N_PARAMS() LT 2) OR (is_a_number(mass,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  Mass not set --> Check keywords
  check  = [KEYWORD_SET(elec),KEYWORD_SET(prot),KEYWORD_SET(neutron),KEYWORD_SET(alpha_p)]
  good   = WHERE(check,gd)
  IF (gd[0] EQ 0) THEN mass = def_mass[0] ELSE mass = keymasses[good[0]]
ENDIF ELSE BEGIN
  ;;  Mass set --> check [*** keep between electron and alpha for now ***]
  test = (ABS(mass[0]) LT me_eVkms2[0]) OR (ABS(mass[0]) GT ma_eVkms2[0])
  IF (test[0]) THEN mass = def_mass[0] ELSE mass = mass[0]
ENDELSE
;;  Check input type (i.e., do not want to make a double from float input)
sztp           = SIZE(kvec,/TYPE)
IF (sztp[0] EQ 4) THEN BEGIN
  ;;  FLOAT
  facs  = [18e1,!PI,36e1]
  f_on  = 1b
ENDIF ELSE BEGIN
  ;;  DOUBLE
  facs  = [18d1,!DPI,36d1]
  f_on  = 0b
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define new velocity magnitudes [km/s] and convert speeds back to energies [eV]
;;----------------------------------------------------------------------------------------
vv_mag         = mag__vec(vv2d,/NAN)                         ;;  [N]-Element array [km/s]
eners          = energy_to_vel(vv_mag,mass[0],/INVERSE)      ;;  [N]-Element array [eV]
;;----------------------------------------------------------------------------------------
;;  Define new angles [deg]
;;    Poloidal   -->   -90 < theta <  +90
;;    Azimuthal  -->  -180 <  phi  < +180
;;----------------------------------------------------------------------------------------
n_the          = ASIN(vv2d[*,2]/vv_mag)*facs[0]/facs[1]
n_phi          = ATAN(vv2d[*,1],vv2d[*,0])*facs[0]/facs[1]
;;  Shift azimuthal angles to {   0 < phi < +360 }
n_phi          = (n_phi + facs[2]) MOD facs[2]
;;----------------------------------------------------------------------------------------
;;  Define outputs as [N]-element arrays
;;----------------------------------------------------------------------------------------
IF (f_on[0]) THEN BEGIN
  the_1d  = FLOAT(n_the)
  phi_1d  = FLOAT(n_phi)
  ener_1d = FLOAT(eners)
ENDIF ELSE BEGIN
  the_1d  = DOUBLE(n_the)
  phi_1d  = DOUBLE(n_phi)
  ener_1d = DOUBLE(eners)
ENDELSE

tags           = ['ENERGY','THETA','PHI']
struct         = CREATE_STRUCT(tags,ener_1d,the_1d,phi_1d)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END

