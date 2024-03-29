;+
;*****************************************************************************************

;  PROCEDURE:   set_common_constants_extra_part_co2014_ci2015.pro
;  PURPOSE  :   This routine defines the common block variables for
;                 constants_extra_part_mass_units_co2014_ci2015_common.pro
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  COMMON BLOCKS:
;               constants_fund_em_atomic_c2014_common.pro
;               constants_extra_part_mass_units_co2014_ci2015_common.pro
;
;  CALLS:
;               set_common_constants_fund_em_atomic_c2014.pro
;               constants_fund_em_atomic_c2014_common.pro
;               constants_extra_part_mass_units_co2014_ci2015_common.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               set_common_constants_astronomical_aa2015
;
;  KEYWORDS:    
;               NA
;
;  COMMON BLOCK VARIABLES:
;
;               MMUON      :  muon particle mass [kg, 2014 CODATA/NIST]
;               M_TAU      :  tau particle mass [kg, 2014 CODATA/NIST]
;               M__H2      :  deuteron (hydrogen-2 or deuterium) mass [kg, 2014 CODATA/NIST]
;               M_HE3      :  helion (helium-3) mass [kg, 2014 CODATA/NIST]
;               M__H3      :  triton (hydrogen-3 or tritium) mass [kg, 2014 CODATA/NIST]
;               MC12       :  Carbon-12 mass [kg, 2015 CIAAW/IUPAC]
;               MN14       :  Nitrogen-14 mass [kg, 2015 CIAAW/IUPAC]
;               MO16       :  Oxygen-16 mass [kg, 2015 CIAAW/IUPAC]
;               ME_EV      :  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
;               MP_EV      :  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;               MN_EV      :  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
;               MA_EV      :  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
;               MMUON_EV   :  ~105.6583745(24) [MeV, 2014 CODATA/NIST]
;               M_TAU_EV   :  ~1776.82(16) [MeV, 2014 CODATA/NIST]
;               M__H2_EV   :  ~1875.612928(12) [MeV, 2014 CODATA/NIST]
;               M_HE3_EV   :  ~2808.391586(17) [MeV, 2014 CODATA/NIST]
;               M__H3_EV   :  ~2808.921112(17) [MeV, 2014 CODATA/NIST]
;               MC12_EV    :  ~11177.92914(20) [MeV, 2014 CODATA/NIST]
;               MN14_EV    :  ~13043.78074(90) [MeV, 2014 CODATA/NIST]
;               MO16_EV    :  ~14899.16852(13) [MeV, 2014 CODATA/NIST]
;               ME_ESA     :  electron mass per c^2 [eV km^(-2) s^(2)]
;               MP_ESA     :  proton mass per c^2 [eV km^(-2) s^(2)]
;               MN_ESA     :  neutron mass per c^2 [eV km^(-2) s^(2)]
;               MA_ESA     :  alpha-particle mass per c^2 [eV km^(-2) s^(2)]
;               MMUON_ESA  :  muon mass per c^2 [eV km^(-2) s^(2)]
;               M_TAU_ESA  :  tau mass per c^2 [eV km^(-2) s^(2)]
;               M__H2_ESA  :  deuteron mass per c^2 [eV km^(-2) s^(2)]
;               M_HE3_ESA  :  helion mass per c^2 [eV km^(-2) s^(2)]
;               M__H3_ESA  :  triton mass per c^2 [eV km^(-2) s^(2)]
;               MC12_ESA   :  Carbon-12 mass per c^2 [eV km^(-2) s^(2)]
;               MN14_ESA   :  Nitrogen-14 mass per c^2 [eV km^(-2) s^(2)]
;               MO16_ESA   :  Oxygen-16 mass per c^2 [eV km^(-2) s^(2)]
;
;   CHANGED:  1)  Fixed bug of unidentified variable c2
;                                                                   [03/29/2019   v1.0.1]
;             2)  Now calls set_common_constants_fund_em_atomic_c2014.pro and associated
;                   common block
;                                                                   [03/29/2019   v1.0.2]
;
;   NOTES:      
;               Units
;                 [H]  = kg m^(+2) C^(-2) = T m^(+2) A^(-1)         :  henry
;                 [F]  = s^(+2) C^(+2) kg^(-1) m^(-2)               :  farad
;                 [T]  = kg C^(-1) s^(-1) = N A^(-1) m^(-1)         :  tesla
;                 [Wb] = kg m^(+2) s^(-1) C^(-1) = H A              :  weber
;                 [V]  = kg m^(+2) C^(-1) s^(-2) = T m^(+2) s^(-1)  :  volt
;
;  REFERENCES:  
;               1)  2014 CODATA/NIST at:
;                     http://physics.nist.gov/cuu/Constants/index.html
;               2)  2015 Astronomical Almanac at:
;                     http://asa.usno.navy.mil/SecK/Constants.html
;               3)  2015 CIAAW/IUPAC
;                     https://iupac.org/projects/project-details/
;
;   CREATED:  03/15/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/29/2019   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO set_common_constants_extra_part_co2014_ci2015

;;----------------------------------------------------------------------------------------
;;  Define fundamental constants
;;----------------------------------------------------------------------------------------
set_common_constants_fund_em_atomic_c2014
;;----------------------------------------------------------------------------------------
;;  Load Common Blocks
;;----------------------------------------------------------------------------------------
@constants_fund_em_atomic_c2014_common.pro
@constants_extra_part_mass_units_co2014_ci2015_common.pro
;;----------------------------------------------------------------------------------------
;;  Define constants
;;----------------------------------------------------------------------------------------
;;  Fundamental
c2             = c[0]^2d0                 ;;  c^2 [m^(+2) s^(-2), 2014 CODATA/NIST]
ckm            = c[0]*1d-3                ;;  m --> km
ckm2           = ckm[0]^2d0               ;;  c^2 [km^(+2) s^(-2), 2014 CODATA/NIST]
;;  Atomic
mmuon          = 1.8835315940d-28         ;;  muon particle mass [kg, 2014 CODATA/NIST]
m_tau          = 3.1674700000d-27         ;;  tau particle mass [kg, 2014 CODATA/NIST]
m__h2          = 3.3435837190d-27         ;;  deuteron (hydrogen-2 or deuterium) mass [kg, 2014 CODATA/NIST]
m_he3          = 5.0064127000d-27         ;;  helion (helium-3) mass [kg, 2014 CODATA/NIST]
m__h3          = 5.0073566650d-27         ;;  triton (hydrogen-3 or tritium) mass [kg, 2014 CODATA/NIST]
mc12           = 12d0*amu[0]              ;;  Carbon-12 mass [kg, 2015 CIAAW/IUPAC]
mn14           = 14.003074004d0*amu[0]    ;;  Nitrogen-14 mass [kg, 2015 CIAAW/IUPAC]
mo16           = 15.994914620d0*amu[0]    ;;  Oxygen-16 mass [kg, 2015 CIAAW/IUPAC]
;;  --> Define mass of particles in units of energy [eV]
me_eV          = me[0]*c2[0]/qq[0]        ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c2[0]/qq[0]        ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
mn_eV          = mn[0]*c2[0]/qq[0]        ;;  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
ma_eV          = ma[0]*c2[0]/qq[0]        ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
mmuon_eV       = mmuon[0]*c2[0]/qq[0]     ;;  ~105.6583745(24) [MeV, 2014 CODATA/NIST]
m_tau_eV       = m_tau[0]*c2[0]/qq[0]     ;;  ~1776.82(16) [MeV, 2014 CODATA/NIST]
m__h2_eV       = m__h2[0]*c2[0]/qq[0]     ;;  ~1875.612928(12) [MeV, 2014 CODATA/NIST]
m_he3_eV       = m_he3[0]*c2[0]/qq[0]     ;;  ~2808.391586(17) [MeV, 2014 CODATA/NIST]
m__h3_eV       = m__h3[0]*c2[0]/qq[0]     ;;  ~2808.921112(17) [MeV, 2014 CODATA/NIST]
mc12_eV        = mc12[0]*c2[0]/qq[0]      ;;  ~11177.92914(20) [MeV, 2014 CODATA/NIST]
mn14_eV        = mn14[0]*c2[0]/qq[0]      ;;  ~13043.78074(90) [MeV, 2014 CODATA/NIST]
mo16_eV        = mo16[0]*c2[0]/qq[0]      ;;  ~14899.16852(13) [MeV, 2014 CODATA/NIST]
;;  Convert mass to units of energy per c^2 [eV km^(-2) s^(2)]
me_esa         = me_eV[0]/ckm2[0]
mp_esa         = mp_eV[0]/ckm2[0]
mn_esa         = mn_eV[0]/ckm2[0]
ma_esa         = ma_eV[0]/ckm2[0]
mmuon_esa      = mmuon_eV[0]/ckm2[0]
m_tau_esa      = m_tau_eV[0]/ckm2[0]
m__h2_esa      = m__h2_eV[0]/ckm2[0]
m_he3_esa      = m_he3_eV[0]/ckm2[0]
m__h3_esa      = m__h3_eV[0]/ckm2[0]
mc12_esa       = mc12_eV[0]/ckm2[0]
mn14_esa       = mn14_eV[0]/ckm2[0]
mo16_esa       = mo16_eV[0]/ckm2[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END

;c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
;GG             = 6.6742800000d-11         ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1), 2018 AA values]
;kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
;SB             = 5.6703670000d-08         ;;  Stefan-Boltzmann Constant [W m^(-2) K^(-4), 2014 CODATA/NIST]
;hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;  Electromagnetic
;qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
;epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
;muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;;  Physico-Chemical
;amu            = 1.6605390400d-27         ;;  Atomic mass constant [kg, 2014 CODATA/NIST]
;;  Atomic
;me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
;mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
;mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
;ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]

