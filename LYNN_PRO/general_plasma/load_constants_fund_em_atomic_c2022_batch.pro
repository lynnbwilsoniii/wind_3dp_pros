;+
;*****************************************************************************************
;
;  BATCH    :   load_constants_fund_em_atomic_c2022_batch.pro
;  PURPOSE  :   This routine locally defines variables from the 2022 CODATA definitions
;                 for fundamental, electromagnetic, and atomic constants.
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
;               @load_constants_fund_em_atomic_c2022_batch.pro
;
;  KEYWORDS:    
;               NA
;
;  DEFINED VARIABLES:
;
;               C    :  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
;               GG   :  Newtonian Constant [m^(3) kg^(-1) s^(-1), 2018 AA values]
;               KB   :  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
;               SB   :  Stefan-Boltzmann Constant [W m^(-2) K^(-4), 2014 CODATA/NIST]
;               HH   :  Planck Constant [J s, 2014 CODATA/NIST]
;               QQ   :  Fundamental charge [C, 2014 CODATA/NIST]
;               EPO  :  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
;               MUO  :  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;               ME   :  Electron mass [kg, 2014 CODATA/NIST]
;               MP   :  Proton mass [kg, 2014 CODATA/NIST]
;               MN   :  Neutron mass [kg, 2014 CODATA/NIST]
;               MA   :  Alpha particle mass [kg, 2014 CODATA/NIST]
;               AMU  :  Atomic mass constant [kg, 2014 CODATA/NIST]
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
;;  Define constants
;;----------------------------------------------------------------------------------------
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2022 CODATA/NIST]
GG             = 6.6743000000d-11         ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1), 2022 CODATA/NIST]
kB             = 1.3806490000d-23         ;;  Boltzmann Constant [J K^(-1), 2022 CODATA/NIST]
SB             = 5.6703744190d-08         ;;  Stefan-Boltzmann Constant [W m^(-2) K^(-4), 2022 CODATA/NIST]
hh             = 6.6260701500d-34         ;;  Planck Constant [J s, 2022 CODATA/NIST]
;;  Electromagnetic
qq             = 1.6021766340d-19         ;;  Fundamental charge [C, 2022 CODATA/NIST]
epo            = 8.8541878188d-12         ;;  Permittivity of free space [F m^(-1), 2022 CODATA/NIST]
muo            = 1.25663706127d-7         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2022 CODATA/NIST]
;;  Atomic
me             = 9.1093837139d-31         ;;  Electron mass [kg, 2022 CODATA/NIST]
mp             = 1.67262192595d-27        ;;  Proton mass [kg, 2022 CODATA/NIST]
mn             = 1.67492750056d-27        ;;  Neutron mass [kg, 2022 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2022 CODATA/NIST]
;;  Physico-Chemical
amu            = 1.66053906892d-27        ;;  Atomic mass constant [kg, 2022 CODATA/NIST]
N_Ava          = 6.02214076000d+23        ;;  Avagadro's constant [# mol^(-1), 2022 CODATA/NIST]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------



