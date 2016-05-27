;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_gyrofrequency.pro
;  PURPOSE  :   This routine calculates the particle gyrofrequency (relativistically
;                 correct if necessary) given the particle mass [m_s] (, kinetic
;                 energy/speed [ke]), magnetic field magnitude [Bo], and particle charge
;                 state [Z_s].  Then the corresponding angular gyrofrequency is given by:
;                     w_cs  =  (Z_s e Bo)/(¥ m_s)
;                 where e = fundamental charge and ¥ = relativistic Lorentz factor,
;                 given by:
;                     ¥  =  [ 1 - (v/c)^2 ]^(-1/2)
;                 where v = particle speed and c = speed of light in vacuum.
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
;               BO          :  [N]-Element [numeric] array of magnetic field magnitudes
;                                [nT] for which to calculate the particle gyrofrequency
;
;  EXAMPLES:    
;               [calling sequence]
;               gyrofreq = lbw_gyrofrequency(bo [,M_S=m_s] [,Z_S=z_s]                   $
;                                            [,SP_OR_EN=sp_or_en] [,/SPEED] [,/ANGULAR] $
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
;               SP_OR_EN  :  [N]-Element [float/double] array of speeds [km/s] or
;                              energies [eV]
;                              [Default = assumes values are energies]
;               SPEED     :  If set, program assumes SP_OR_EN input is a speed [km/s].
;                              If not set, then the routine assumes SP_OR_EN is an
;                              array of energies [eV].
;                              [Default = FALSE]
;               ANGULAR   :  If set, the output will be the angular gyrofrequency [rad/s],
;                              otherwise the output will scalar gyrofrequency [Hz]
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
;               0)  Rules for Z_S and M_S keywords:
;                     A) Z_S = TRUE, M_S = FALSE  :
;                           Set both to defaults --> M_S = m_e, Z_S = -1
;                     B) Z_S = FALSE, M_S = TRUE  :
;                           Set Z_S to default   --> Z_S = -1
;                     C) Z_S = FALSE, M_S = FALSE :
;                           Set both to defaults --> M_S = m_e, Z_S = -1
;                     D) Z_S = TRUE, M_S = TRUE   :
;                           Proceed normally (unless M_S < m_e or M_S > 300 amu)
;               1)  For electrons, the return values will be < 0
;               2)  Z_S must be an integer, i.e., no fractional charges
;               3)  Any of the following keywords will take priority over the M_S keyword:
;                     ELECTRON
;                     PROTON
;                     ALPHA_P
;                     MUON_P
;                     TAU_P
;                     DEUTERON
;                     HELIUM_3
;                     TRITON
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

FUNCTION lbw_gyrofrequency,bo,M_S=m_s,Z_S=z_s,SP_OR_EN=sp_or_en,SPEED=speed,     $
                              ANGULAR=angular,ELECTRON=electron,PROTON=proton,   $
                              ALPHA_P=alpha_p,MUON_P=muon_p,TAU_P=tau_p,         $
                              DEUTERON=deuteron,HELIUM_3=helium_3,TRITON=triton

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
ckm            = c[0]*1d-3                ;;  m --> km
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
SB             = 5.6703670000d-08         ;;  Stefan-Boltzmann Constant [W m^(-2) K^(-4), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;  Electromagnetic
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
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
me_eV          = me[0]*c[0]^2/qq[0]       ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c[0]^2/qq[0]       ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
ma_eV          = ma[0]*c[0]^2/qq[0]       ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
mmuon_eV       = mmuon[0]*c[0]^2/qq[0]    ;;  ~105.6583745(24) [MeV, 2014 CODATA/NIST]
m_tau_eV       = m_tau[0]*c[0]^2/qq[0]    ;;  ~1776.82(16) [MeV, 2014 CODATA/NIST]
m__h2_eV       = m__h2[0]*c[0]^2/qq[0]    ;;  ~1875.612928(12) [MeV, 2014 CODATA/NIST]
m_he3_eV       = m_he3[0]*c[0]^2/qq[0]    ;;  ~2808.391586(17) [MeV, 2014 CODATA/NIST]
m__h3_eV       = m__h3[0]*c[0]^2/qq[0]    ;;  ~2808.921112(17) [MeV, 2014 CODATA/NIST]
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
max_ms         = 300d0*amu[0]             ;;  Limit ion mass to < 300 amu's [the atomic mass of element 118 is currently listed as 294 amu's]
def_ms         = me[0]
def_zs         = -1d0

def_q_ele      = -1d0
def_q_pro      =  1d0
def_q_alp      =  2d0
def_qmuon      = -1d0
def_q_tau      = -1d0
def_q__h2      =  1d0
def_q_he3      =  2d0
def_q__h3      =  1d0

def_q_all      = [def_q_ele[0],def_q_pro[0],def_q_alp[0],def_qmuon[0],def_q_tau[0],$
                  def_q__h2[0],def_q_he3[0],def_q__h3[0]]
def_m_all      = [me[0],mp[0],ma[0],mmuon[0],m_tau[0],m__h2[0],m_he3[0],m__h3[0]]
;;----------------------------------------------------------------------------------------
;;  Conversion Factors
;;----------------------------------------------------------------------------------------
;;  Energy and Temperature
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
J_1eV          = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
K_eV           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
eV_K           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
;;  Frequency
wc_all_fac     = qq[0]*def_q_all*1d-9/def_m_all
;;----------------------------------------------------------------------------------------
;;  Error messages
;;----------------------------------------------------------------------------------------
noinput_mssg   = 'Incorrect number of inputs were supplied...'
baddfor_msg    = 'Incorrect input format:  SP_OR_EN must have the same # of elements as BO...'
baddinp_msg    = 'Incorrect input:  BO must be an [N]-element numeric arrays...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 1) OR (is_a_number(bo) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  No input --> return to user
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check size of inputs
b_o            = REFORM(bo)
szdbo          = SIZE(b_o,/DIMENSIONS)
test           = (N_ELEMENTS(szdbo) NE 1)
IF (test[0]) THEN BEGIN
  ;;  More than one dimension --> return to user
  MESSAGE,baddinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define N
nn             = szdbo[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords [Inputs]
;;----------------------------------------------------------------------------------------
;;  Check M_I and Z_I
test_ms        = (N_ELEMENTS(m_s) GT 0) AND is_a_number(m_s,/NOMSSG)
test_zs        = (N_ELEMENTS(z_s) GT 0) AND is_a_number(z_s,/NOMSSG)
;;  Check SP_OR_EN
test_se        = (N_ELEMENTS(sp_or_en) EQ nn[0]) AND is_a_number(sp_or_en,/NOMSSG)
;;  Check SPEED and ANGULAR
test_sp        = (N_ELEMENTS(speed) GT 0)   AND KEYWORD_SET(speed)
test_an        = (N_ELEMENTS(angular) GT 0) AND KEYWORD_SET(angular)
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
;;----------------------------------------------------------------------------------------
;;  Define particle charge state and mass
;;----------------------------------------------------------------------------------------
use_def_mq0    = ( test_zs[0]       AND (test_ms[0] EQ 0)) OR $
                 ((test_zs[0] EQ 0) AND (test_ms[0] EQ 0))
use_def_mq     = use_def_mq0[0] AND (gd_all[0] EQ 0)     ;;  TRUE --> force defaults
IF (use_def_mq[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Force default M_S and Z_S
  ;;--------------------------------------------------------------------------------------
  bad_mssg       = 'Setting M_S and Z_S --> electron parameters'
  MESSAGE,bad_mssg[0],/INFORMATIONAL,/CONTINUE
  ;;  BAD  -->  Force to electron parameters!
  ms             = def_ms[0]
  zs             = def_zs[0]
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  something was okay --> check
  ;;--------------------------------------------------------------------------------------
  test           = (gd_all[0] GT 0)
  IF (test[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  One of the specific particle keywords was set --> use 2014 CODATA/NIST results
    ;;------------------------------------------------------------------------------------
    ms = def_m_all[good_all[0]]
    zs = def_q_all[good_all[0]]
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  (Z_S = FALSE, M_S = TRUE) OR (Z_S = TRUE, M_S = TRUE)
    ;;------------------------------------------------------------------------------------
    test           = ((test_zs[0] EQ 0) AND (test_ms[0] EQ 0))
    IF (test[0]) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Both FALSE --> Force to electron parameters!
      ;;----------------------------------------------------------------------------------
      bad_mssg       = 'Neither M_S or Z_S was set --> Using electron parameters'
      MESSAGE,bad_mssg[0],/INFORMATIONAL,/CONTINUE
      ms             = def_ms[0]
      zs             = def_zs[0]
    ENDIF ELSE BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  (Z_S = TRUE, M_S = TRUE)  -->  Check M_S magnitude but otherwise proceed
      ;;----------------------------------------------------------------------------------
      zs             = 1d0*LONG(z_s[0])
      ms             = ABS(m_s[0])
      test           = (ms[0] LT me[0]) OR (ms[0] GT max_ms[0])
      IF (test[0]) THEN BEGIN
        ;;  (M_S < m_e or M_S > 300 amu) --> Force to electron parameters!
        bad_mssg       = 'BAD M_S input --> M_S [kg] must satisfy:  (m_e ≤ M_S < 300 amu [kg])'
        MESSAGE,bad_mssg[0],/INFORMATIONAL,/CONTINUE
        bad_mssg       = 'Setting M_S and Z_S --> electron parameters'
        MESSAGE,bad_mssg[0],/INFORMATIONAL,/CONTINUE
        ms = def_ms[0]
        zs = def_zs[0]
      ENDIF
    ENDELSE
  ENDELSE
ENDELSE
;;  Define scalar angular frequency conversion factor
wcs_fac        = qq[0]*zs[0]*1d-9/ms[0]
;;  Re-define values on output
m_s            = ms[0]
z_s            = zs[0]
;;----------------------------------------------------------------------------------------
;;  Define relativistic gamma
;;----------------------------------------------------------------------------------------
IF (test_se[0]) THEN BEGIN
  ;;  User defined SP_OR_EN  -->  Calculate relativistic Lorentz factor
  nrg    = REFORM(sp_or_en)
  rgamma = relativistic_gamma(nrg,ms[0],SPEED=test_sp[0])
ENDIF ELSE BEGIN
  ;;  User wants non-relativistic results or SP_OR_EN was incorrectly set
  rgamma = REPLICATE(1d0,nn[0])
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define relativistic gyrofrequency [rad/s]
;;----------------------------------------------------------------------------------------
wcs            = wcs_fac[0]*b_o/rgamma       ;;  Ω_cs [rad/s]
IF (test_an[0]) THEN output = wcs ELSE output = wcs/(2d0*!DPI)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END
