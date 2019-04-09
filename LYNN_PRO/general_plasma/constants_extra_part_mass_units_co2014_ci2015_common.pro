;+
;*****************************************************************************************
;
;  COMMON   :   constants_extra_part_mass_units_co2014_ci2015_common.pro
;  PURPOSE  :   Common block to use certain variables as global variables for
;                 heavy ion masses and all particle masses in different units
;                 from the 2014 CODATA and 2015 CIAAW/IUPAC definitions.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               @constants_extra_part_mass_units_co2014_ci2015_common.pro
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
;               1)  2014 CODATA/NIST at:
;                     http://physics.nist.gov/cuu/Constants/index.html
;               2)  2015 Astronomical Almanac at:
;                     http://asa.usno.navy.mil/SecK/Constants.html
;               3)  2015 CIAAW/IUPAC
;                     https://iupac.org/projects/project-details/
;
;   CREATED:  03/15/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/15/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

COMMON constants_extra_part_mass_units_co2014_ci2015_common,                           $
                mmuon,m_tau,m__h2,m_he3,m__h3,mc12,mn14,mo16,me_ev,mp_ev,mn_ev,ma_ev,  $
                mmuon_ev,m_tau_ev,m__h2_ev,m_he3_ev,m__h3_ev,mc12_ev,mn14_ev,mo16_ev,  $
                me_esa,mp_esa,mn_esa,ma_esa,mmuon_esa,m_tau_esa,m__h2_esa,m_he3_esa,   $
                m__h3_esa,mc12_esa,mn14_esa,mo16_esa





