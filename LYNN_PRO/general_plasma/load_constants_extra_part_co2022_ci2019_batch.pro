;+
;*****************************************************************************************
;
;  BATCH    :   load_constants_extra_part_co2022_ci2019_batch.pro
;  PURPOSE  :   This routine locally defines variables from the 2022 CODATA and
;                 2019 CIAAW/IUPAC definitions for  heavy ion masses and all particle
;                 masses in different units.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  COMMON BLOCKS:
;               NA
;
;  CALLS:
;               @load_constants_fund_em_atomic_c2022_batch.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               @load_constants_extra_part_co2022_ci2019_batch.pro
;
;  KEYWORDS:    
;               NA
;
;  DEFINED VARIABLES:
;
;               MMUON      :  muon particle mass [kg, 2022 CODATA/NIST]
;               M_TAU      :  tau particle mass [kg, 2022 CODATA/NIST]
;               M__H2      :  deuteron (hydrogen-2 or deuterium) mass [kg, 2022 CODATA/NIST]
;               M_HE3      :  helion (helium-3) mass [kg, 2022 CODATA/NIST]
;               M__H3      :  triton (hydrogen-3 or tritium) mass [kg, 2022 CODATA/NIST]
;               MC12       :  Carbon-12 mass [kg, 2019 CIAAW/IUPAC]
;               MN14       :  Nitrogen-14 mass [kg, 2019 CIAAW/IUPAC]
;               MO16       :  Oxygen-16 mass [kg, 2019 CIAAW/IUPAC]
;               ME_EV      :  ~0.51099895069(16) [MeV, 2022 CODATA/NIST]
;               MP_EV      :  ~938.27208943(29) [MeV, 2022 CODATA/NIST]
;               MN_EV      :  ~939.56542194(48) [MeV, 2022 CODATA/NIST]
;               MA_EV      :  ~3727.3794118(12) [MeV, 2022 CODATA/NIST]
;               MMUON_EV   :  ~105.6583755(23) [MeV, 2022 CODATA/NIST]
;               M_TAU_EV   :  ~1776.86(12) [MeV, 2022 CODATA/NIST]
;               M__H2_EV   :  ~1875.61294500(58) [MeV, 2022 CODATA/NIST]
;               M_HE3_EV   :  ~2808.39161112(88) [MeV, 2022 CODATA/NIST]
;               M__H3_EV   :  ~2808.92113668(88) [MeV, 2022 CODATA/NIST]
;               MC12_EV    :  ~11177.9292446228 [MeV, 2022 CODATA/NIST]
;               MN14_EV    :  ~13047.3028441410 [MeV, 2022 CODATA/NIST]
;               MO16_EV    :  ~14903.3467630349 [MeV, 2022 CODATA/NIST]
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
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
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
;               1)  2022 CODATA/NIST at:
;                     https://physics.nist.gov/cuu/Constants/index.html
;               2)  2021 Astronomical Almanac at:
;                     https://aa.usno.navy.mil/downloads/publications/Constants_2021.pdf
;               3)  2019 CIAAW/IUPAC
;                     https://www.degruyterbrill.com/document/doi/10.1515/pac-2019-0603/html
;
;   CREATED:  06/25/2025
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/25/2025   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


;;----------------------------------------------------------------------------------------
;;  Define fundamental, electromagnetic, and atomic constants
;;----------------------------------------------------------------------------------------
@load_constants_fund_em_atomic_c2022_batch.pro
;;----------------------------------------------------------------------------------------
;;  Define new constants
;;----------------------------------------------------------------------------------------
;;  Fundamental
c2             = c[0]^2d0                 ;;  c^2 [m^(+2) s^(-2), 2022 CODATA/NIST]
ckm            = c[0]*1d-3                ;;  m --> km
ckm2           = ckm[0]^2d0               ;;  c^2 [km^(+2) s^(-2), 2022 CODATA/NIST]
;;  Atomic
mmuon          = 1.8835316270d-28         ;;  muon particle mass [kg, 2022 CODATA/NIST]
m_tau          = 3.1675400000d-27         ;;  tau particle mass [kg, 2022 CODATA/NIST]
m__h2          = 3.3435837768d-27         ;;  deuteron (hydrogen-2 or deuterium) mass [kg, 2022 CODATA/NIST]
m_he3          = 5.0064127862d-27         ;;  helion (helium-3) mass [kg, 2022 CODATA/NIST]
m__h3          = 5.0073567512d-27         ;;  triton (hydrogen-3 or tritium) mass [kg, 2022 CODATA/NIST]
mc12           = 12d0*amu[0]              ;;  Carbon-12 mass [kg, defined as exactly 12 AMUs, 2018 CIAAW/IUPAC]
mn14           = 14.006855000d0*amu[0]    ;;  Nitrogen-14 mass [kg, Avg of two valued-range from 2018 CIAAW/IUPAC]
mo16           = 15.999400000d0*amu[0]    ;;  Oxygen-16 mass [kg, Avg of two valued-range from 2018 CIAAW/IUPAC]
;;  --> Define mass of particles in units of energy [eV]
me_eV          = me[0]*c2[0]/qq[0]        ;;  ~0.51099895069(16) [MeV, 2022 CODATA/NIST]
mp_eV          = mp[0]*c2[0]/qq[0]        ;;  ~938.27208943(29) [MeV, 2022 CODATA/NIST]
mn_eV          = mn[0]*c2[0]/qq[0]        ;;  ~939.56542194(48) [MeV, 2022 CODATA/NIST]
ma_eV          = ma[0]*c2[0]/qq[0]        ;;  ~3727.3794118(12) [MeV, 2022 CODATA/NIST]
mmuon_eV       = mmuon[0]*c2[0]/qq[0]     ;;  ~105.6583755(23) [MeV, 2022 CODATA/NIST]
m_tau_eV       = m_tau[0]*c2[0]/qq[0]     ;;  ~1776.86(12) [MeV, 2022 CODATA/NIST]
m__h2_eV       = m__h2[0]*c2[0]/qq[0]     ;;  ~1875.61294500(58) [MeV, 2022 CODATA/NIST]
m_he3_eV       = m_he3[0]*c2[0]/qq[0]     ;;  ~2808.39161112(88) [MeV, 2022 CODATA/NIST]
m__h3_eV       = m__h3[0]*c2[0]/qq[0]     ;;  ~2808.92113668(88) [MeV, 2022 CODATA/NIST]
mc12_eV        = mc12[0]*c2[0]/qq[0]      ;;  ~11177.9292446228 [MeV, 2022 CODATA/NIST]
mn14_eV        = mn14[0]*c2[0]/qq[0]      ;;  ~13047.3028441410 [MeV, 2022 CODATA/NIST]
mo16_eV        = mo16[0]*c2[0]/qq[0]      ;;  ~14903.3467630349 [MeV, 2022 CODATA/NIST]
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



