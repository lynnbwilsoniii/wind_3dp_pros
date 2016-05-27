;+
;*****************************************************************************************
;
;  FUNCTION :   energy_to_vel.pro
;  PURPOSE  :   Converts an input energy [eV] into a corresponding speed [km/s] and
;                 vice versa.  All calculations include relativistic corrections.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               relativistic_gamma.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NRG       :  [N]-Element [numeric] array of energies [eV] or
;                              speeds [km/s] if INVERSE keyword is set
;                              [Default = assumes values are energies]
;               MASS      :  Scalar [numeric] particle mass [eV/(km/sec)^2]
;                              [semi-optional if keywords are set]
;
;  EXAMPLES:    
;               [calling sequence]
;               spd = energy_to_vel(nrg [,MASS] [,/ELECTRON] [,/PROTON] [,/INVERSE]  $
;                                   [,/ALPHA_P] [,/MUON_P] [,/TAU_P] [,/DEUTERON]    $
;                                   [,/HELIUM_3] [,/TRITON])
;
;               ;;  Determine the speed [km/s] of a 10 eV electron
;               PRINT,';; ', energy_to_vel(10d0,/ELECTRON)
;               ;;        1875.5097
;
;               ;;  Determine the speed [c] of a 10 keV electron
;               ckm    = 2.99792458d5      ; => Speed of light in vacuum [km/s]
;               PRINT,';; ', energy_to_vel(10d3,/ELECTRON)/ckm[0]
;               ;;       0.19498561
;
;               ;;  Determine the speed [km/s] of a 1 keV proton
;               PRINT,';; ', energy_to_vel(1d3,/PROTON)
;               ;;        437.69436
;
;               ;;  Determine the energy [eV] of a 1000 km/s proton
;               PRINT,';; ', energy_to_vel(1d3,/PROTON,/INVERSE)
;               ;;        5219.8860
;
;  KEYWORDS:    
;               ELECTRON  :  If set, use electron mass [eV/(km/sec)^2]
;                               [Default = TRUE if MASS = FALSE]
;               PROTON    :  If set, use proton mass [eV/(km/sec)^2]
;                               [Default = FALSE]
;               INVERSE   :  If set, routine assumes user input speeds [km/s]
;                               and wishes to return energies [eV]
;                               [Default = FALSE]
;               ALPHA_P   :  If set, use alpha-particle mass [eV/(km/sec)^2]
;                              [Default = FALSE]
;               MUON_P    :  If set, use the muon particle mass [eV/(km/sec)^2]
;                              [Default = FALSE]
;               TAU_P     :  If set, use the tau particle mass [eV/(km/sec)^2]
;                              [Default = FALSE]
;               DEUTERON  :  If set, use the deuterium particle mass [eV/(km/sec)^2]
;                              [Default = FALSE]
;               HELIUM_3  :  If set, use the helium-3 particle mass [eV/(km/sec)^2]
;                              [Default = FALSE]
;               TRITON    :  If set, use the tritium particle mass [eV/(km/sec)^2]
;                              [Default = FALSE]
;
;   CHANGED:  1)  Updated Man. page and
;                  added keywords:  ALPHA_P, MUON_P, TAU_P, DEUTERON, HELIUM_3, TRITON
;                  and now calls is_a_number.pro and relativistic_gamma.pro
;                                                                   [01/26/2016   v1.1.0]
;
;   NOTES:      
;               1)  This is similar to velocity.pro, but it always uses relativistic
;                     corrections, it has more error handling, and more comments
;               2)  Note that if one inputs large energies (i.e., >1 TeV) for, say,
;                     protons and converts those to speeds then tries to convert back
;                     to energies, the results will not match the initial input energies.
;                     The reason is a propagation of rounding errors, even with the
;                     use of double-precision values for all computations.
;                       Example:
;                       ener  = [1d3,1d6,1d9,1d12,1d15]             ;;  energies [eV]
;                       spds  = energy_to_vel(ener,/PROTON)         ;;  speeds [km/s]
;                       eners = energy_to_vel(spds,/PROTON,/INVER)  ;;  energies [eV]
;                       PRINT,';; ',ABS(eners - ener)/ener
;                       ;;    3.4732410e-08   3.4827621e-08   3.4827621e-08   3.4950916e-08   3.0674764e-05
;
;  REFERENCES:  
;               [Any modern physics or E&M textbook would suffice]
;
;   CREATED:  04/19/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/26/2016   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION energy_to_vel,nrg,mass,ELECTRON=electron,PROTON=proton,INVERSE=inverse,   $
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
;;  Electromagnetic
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
;;  Atomic
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
amu            = 1.6605390400d-27         ;;  Atomic mass constant [kg, 2014 CODATA/NIST]
mmuon          = 1.8835315940d-28         ;;  muon particle mass [kg, 2014 CODATA/NIST]
m_tau          = 3.1674700000d-27         ;;  tau particle mass [kg, 2014 CODATA/NIST]
m__h2          = 3.3435837190d-27         ;;  deuteron (hydrogen-2 or deuterium) mass [kg, 2014 CODATA/NIST]
m_he3          = 5.0064127000d-27         ;;  helion (helium-3) mass [kg, 2014 CODATA/NIST]
m__h3          = 5.0073566650d-27         ;;  triton (hydrogen-3 or tritium) mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
me_eV          = me[0]*c2[0]/qq[0]        ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c2[0]/qq[0]        ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
ma_eV          = ma[0]*c2[0]/qq[0]        ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
mmuon_eV       = mmuon[0]*c2[0]/qq[0]     ;;  ~105.6583745(24) [MeV, 2014 CODATA/NIST]
m_tau_eV       = m_tau[0]*c2[0]/qq[0]     ;;  ~1776.82(16) [MeV, 2014 CODATA/NIST]
m__h2_eV       = m__h2[0]*c2[0]/qq[0]     ;;  ~1875.612928(12) [MeV, 2014 CODATA/NIST]
m_he3_eV       = m_he3[0]*c2[0]/qq[0]     ;;  ~2808.391586(17) [MeV, 2014 CODATA/NIST]
m__h3_eV       = m__h3[0]*c2[0]/qq[0]     ;;  ~2808.921112(17) [MeV, 2014 CODATA/NIST]
;;  Convert mass to units of energy per c^2 [eV km^(-2) s^(2)]
me_esa         = me_eV[0]/ckm2[0]
mp_esa         = mp_eV[0]/ckm2[0]
ma_esa         = ma_eV[0]/ckm2[0]
mmuon_esa      = mmuon_eV[0]/ckm2[0]
m_tau_esa      = m_tau_eV[0]/ckm2[0]
m__h2_esa      = m__h2_eV[0]/ckm2[0]
m_he3_esa      = m_he3_eV[0]/ckm2[0]
m__h3_esa      = m__h3_eV[0]/ckm2[0]
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
max_ms         = 300d0*amu[0]             ;;  Limit ion mass to < 300 amu's [the atomic mass of element 118 is currently listed as 294 amu's]
max_ms_eV      = max_ms[0]*c[0]^2/qq[0]   ;;  kg --> eV
max_ms_esa     = max_ms_eV[0]/ckm2[0]     ;;  eV --> eV km^(-2) s^(2)
min_ms_esa     = me_esa[0]

def_m_all      = [me_esa[0],mp_esa[0],ma_esa[0],mmuon_esa[0],m_tau_esa[0],m__h2_esa[0],$
                  m_he3_esa[0],m__h3_esa[0]]
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (is_a_number(nrg) EQ 0)
IF (test[0]) THEN RETURN,-1    ;;  Bad input --> Exit routine
;;  Check MASS
test_ms        = (N_ELEMENTS(mass) GT 0) AND is_a_number(mass,/NOMSSG)
;;  Check ELECTRON through TRITON keywords
test_all       = [(N_ELEMENTS(electron) GT 0) AND KEYWORD_SET(electron),    $
                  (N_ELEMENTS(proton) GT 0) AND KEYWORD_SET(proton),        $
                  (N_ELEMENTS(alpha_p) GT 0) AND KEYWORD_SET(alpha_p),      $
                  (N_ELEMENTS(muon_p) GT 0) AND KEYWORD_SET(muon_p),        $
                  (N_ELEMENTS(tau_p) GT 0) AND KEYWORD_SET(tau_p),          $
                  (N_ELEMENTS(deuteron) GT 0) AND KEYWORD_SET(deuteron),    $
                  (N_ELEMENTS(helium_3) GT 0) AND KEYWORD_SET(helium_3),    $
                  (N_ELEMENTS(triton) GT 0) AND KEYWORD_SET(triton)         ]
good_all       = WHERE(test_all,gd_all)
;;  Check INVERSE
test_inv       = (N_ELEMENTS(inverse) GT 0) AND KEYWORD_SET(inverse)
IF (test_inv[0]) THEN inv = 1b ELSE inv = 0b
;;----------------------------------------------------------------------------------------
;;  Define particle mass
;;----------------------------------------------------------------------------------------
use_def_mq     = (test_ms[0] EQ 0) AND (gd_all[0] EQ 0)     ;;  TRUE --> force defaults
IF (use_def_mq[0]) THEN BEGIN
  ;;  Use electron mass
  mass = me_esa[0]
ENDIF ELSE BEGIN
  ;;  Either a particle keyword was set or MASS was set
  test           = (gd_all[0] GT 0)
  IF (test[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  One of the specific particle keywords was set --> use 2014 CODATA/NIST results
    ;;------------------------------------------------------------------------------------
    mass = def_m_all[good_all[0]]
  ENDIF ELSE BEGIN
    ;;  MASS was set --> check
    test           = (mass[0] LT min_ms_esa[0]) OR (mass[0] GT max_ms_esa[0])
    IF (test[0]) THEN BEGIN
      ;;  BAD --> Use default
      mass = me_esa[0]
    ENDIF
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define relativistic gamma
;;----------------------------------------------------------------------------------------
;;  Convert MASS to kg
ms_eV          = mass[0]*ckm2[0]         ;;  eV km^(-2) s^(2)  -->  eV
ms             = ms_eV[0]*(qq[0]/c2[0])  ;;  eV  -->  kg
IF (inv[0]) THEN BEGIN
  ;;  User input speeds
  gamm = relativistic_gamma(nrg,ms[0],/SPEED)
ENDIF ELSE BEGIN
  ;;  User input energies
  gamm = relativistic_gamma(nrg,ms[0])
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Calculate speed [km/s] or energy [eV]
;;----------------------------------------------------------------------------------------
IF (inv[0]) THEN BEGIN
  ;;  User input speeds   --> energies
  ;;    KE = mc^2 (¥ - 1)
  output = ms_eV[0]*(gamm - 1d0)
ENDIF ELSE BEGIN
  ;;  User input energies --> speeds
  fac    = ckm2[0] - (ckm2[0]/gamm/gamm)
  output = SQRT(fac)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END
