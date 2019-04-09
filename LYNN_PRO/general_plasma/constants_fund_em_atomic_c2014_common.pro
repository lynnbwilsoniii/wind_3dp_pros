;+
;*****************************************************************************************
;
;  COMMON   :   constants_fund_em_atomic_c2014_common.pro
;  PURPOSE  :   Common block to use certain variables as global variables for
;                 fundamental, electromagnetic, and atomic constants from the
;                 2014 CODATA definitions.
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
;               @constants_fund_em_atomic_c2014_common.pro
;
;  KEYWORDS:    
;               NA
;
;  COMMON BLOCK VARIABLES:
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
;               1)  2014 CODATA/NIST at:
;                     http://physics.nist.gov/cuu/Constants/index.html
;               2)  2015 Astronomical Almanac at:
;                     http://asa.usno.navy.mil/SecK/Constants.html
;
;   CREATED:  03/15/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/15/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

COMMON constants_fund_em_atomic_c2014_common,c,GG,kB,SB,hh,qq,epo,muo,me,mp,mn,ma,amu





