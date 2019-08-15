;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_gyroradius.pro
;  PURPOSE  :   This routine calculates the particle gyroradius (relativistically
;                 correct if necessary) given the particle mass [m_s] (, kinetic
;                 energy/speed [ke]), magnetic field magnitude [Bo], and particle charge
;                 state [Z_s].  Then the corresponding angular gyrofrequency is given by:
;                     w_cs  =  (Z_s e Bo)/(¥ m_s)
;                 where e = fundamental charge and ¥ = relativistic Lorentz factor,
;                 given by:
;                     ¥  =  [ 1 - (v/c)^2 ]^(-1/2)
;                 where v = particle speed and c = speed of light in vacuum.  Then, given
;                 the particle kinetic energy or speed [ke] orthogonal to Bo, the
;                 gyroradius is given by:
;                     r_cs  =  ke/w_cs
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               lbw_gyrofrequency.pro
;               energy_to_vel.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               BO        :  [N]-Element [numeric] array of magnetic field magnitudes
;                              [nT] for which to calculate the particle gyroradius
;               SP_OR_EN  :  [N]-Element [float/double] array of speeds [km/s] or
;                              energies [eV]
;                              [Default = assumes values are energies]
;
;  EXAMPLES:    
;               [calling sequence]
;               rho_cs = lbw_gyroradius(bo, sp_or_en [,M_S=m_s] [,Z_S=z_s] [,/SPEED]  $
;                                            [,/ELECTRON] [,/PROTON] [,/ALPHA_P]      $
;                                            [,/MUON_P] [,/TAU_P] [,/DEUTERON]        $
;                                            [,/HELIUM_3] [,/TRITON])
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               M_S       :  Scalar [numeric] defining the particle mass [kg]
;                              [Default = m_e (i.e., electron mass)]
;               Z_S       :  Scalar [numeric integer] defining the particle charge state
;                              (e.g., enter +2 for alpha-particles)
;                              [Default = -1 (e.g., electrons)]
;               SPEED     :  If set, program assumes SP_OR_EN input is a speed [km/s].
;                              If not set, then the routine assumes SP_OR_EN is an
;                              array of energies [eV].
;                              [Default = FALSE]
;               ELECTRON  :  If set, use electron mass [kg]
;                              [Default = TRUE]
;               PROTON    :  If set, use proton mass [kg]
;                              [Default = FALSE]
;               ALPHA_P   :  If set, use alpha-particle mass [kg]
;                              [Default = FALSE]
;               MUON_P    :  If set, use the muon particle mass [kg]
;                              [Default = FALSE]
;               TAU_P     :  If set, use the tau particle mass [kg]
;                              [Default = FALSE]
;               DEUTERON  :  If set, use the deuterium particle mass [kg]
;                              [Default = FALSE]
;               HELIUM_3  :  If set, use the helium-3 particle mass [kg]
;                              [Default = FALSE]
;               TRITON    :  If set, use the tritium particle mass [kg]
;                              [Default = FALSE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See NOTES section in Man. page of lbw_gyrofrequency.pro
;
;  REFERENCES:  
;               1)  Gurnett, D.A. and A. Bhattacharjee (2005), "Introduction to Plasma
;                      Physics:  With Space and Laboratory Applications," Cambridge
;                      University Press, Cambridge, UK, ISBN:0-521-36483-3.
;               2)  Stix, T.H. (1962), "The Theory of Plasma Waves,"
;                      McGraw-Hill Book Company, USA.
;               3)  2014 CODATA/NIST at:
;                     http://physics.nist.gov/cuu/Constants/index.html
;               4)  2015 Astronomical Almanac at:
;                     http://asa.usno.navy.mil/SecK/Constants.html
;
;   CREATED:  01/26/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/26/2016   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_gyroradius,bo,sp_or_en,M_S=m_s,Z_S=z_s,SPEED=speed,                       $
                                    ELECTRON=electron,PROTON=proton,                   $
                                    ALPHA_P=alpha_p,MUON_P=muon_p,TAU_P=tau_p,         $
                                    DEUTERON=deuteron,HELIUM_3=helium_3,TRITON=triton

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
c2             = c[0]^2                   ;;  (m/s)^2
ckm            = c[0]*1d-3                ;;  m --> km
ckm2           = ckm[0]^2                 ;;  (km/s)^2
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
SB             = 5.6703670000d-08         ;;  Stefan-Boltzmann Constant [W m^(-2) K^(-4), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;  Electromagnetic
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;;----------------------------------------------------------------------------------------
;;  Conversion Factors
;;----------------------------------------------------------------------------------------
;;  Energy and Temperature
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
J_1eV          = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
K_eV           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
eV_K           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
;;----------------------------------------------------------------------------------------
;;  Error messages
;;----------------------------------------------------------------------------------------
noinput_mssg   = 'Incorrect number of inputs were supplied...'
baddfor_msg    = 'Incorrect input format:  SP_OR_EN must have the same # of elements as BO...'
baddinp_msg    = 'Incorrect input:  Both BO and SP_OR_EN must an [N]-element numeric arrays...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 2) OR (is_a_number(bo) EQ 0) OR (is_a_number(sp_or_en) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  No input --> return to user
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check size of inputs
nrg            = ABS(REFORM(sp_or_en))
b_o            = ABS(REFORM(bo))
szdno          = SIZE(nrg,/DIMENSIONS)
szdbo          = SIZE(b_o,/DIMENSIONS)
;;  Make sure data format is okay
test           = (N_ELEMENTS(szdno) NE 1) OR (N_ELEMENTS(szdbo) NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,baddinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (szdno[0] NE szdbo[0])
IF (test[0]) THEN BEGIN
  MESSAGE,baddfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define N
nn             = szdno[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords [Inputs]
;;----------------------------------------------------------------------------------------
;;  Check SPEED
test_sp        = (N_ELEMENTS(speed) GT 0)   AND KEYWORD_SET(speed)
;;----------------------------------------------------------------------------------------
;;  Calculate angular gyrofrequency
;;----------------------------------------------------------------------------------------
wcs            = lbw_gyrofrequency(b_o,M_S=m_s,Z_S=z_s,SP_OR_EN=nrg,SPEED=test_sp[0], $
                                   /ANGULAR,ELECTRON=electron,PROTON=proton,          $
                                   ALPHA_P=alpha_p,MUON_P=muon_p,TAU_P=tau_p,         $
                                   DEUTERON=deuteron,HELIUM_3=helium_3,TRITON=triton  )
;;  Define mass and charge state returned by lbw_gyrofrequency.pro
ms             = m_s[0]
zs             = z_s[0]
;;  Convert mass to units of energy per c^2 [eV km^(-2) s^(2)]
ms_eV          = ms[0]*c2[0]/qq[0]        ;;  particle mass energy equivalent [eV]
ms_eVkms2      = ms_eV[0]/ckm2[0]         ;;  particle mass [eV km^(-2) s^(2)]
;;----------------------------------------------------------------------------------------
;;  Convert energy to speed (if necessary)
;;----------------------------------------------------------------------------------------
IF (test_sp[0]) THEN BEGIN
  ;;  Already speed [km/s] --> do nothing
  spd            = nrg
ENDIF ELSE BEGIN
  ;;  energy --> convert to speed [km/s]
  spd            = energy_to_vel(nrg,ms_eVkms2[0])
ENDELSE
;;  Make sure speeds are not in excess of c
bad            = WHERE(spd GE ckm[0],bd)
IF (bd[0] GT 0) THEN spd[bad] = d       ;;  kill points with unrealistic speeds
;;----------------------------------------------------------------------------------------
;;  Calculate particle gyroradius [km]
;;----------------------------------------------------------------------------------------
rho_cs         = spd/ABS(wcs)     ;;  Need |Ω_cs| in case Z_S < 0
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,rho_cs
END
