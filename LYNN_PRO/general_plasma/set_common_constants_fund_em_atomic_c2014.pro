;+
;*****************************************************************************************
;
;  PROCEDURE:   set_common_constants_fund_em_atomic_c2014.pro
;  PURPOSE  :   This routine defines the common block variables for
;                 constants_fund_em_atomic_c2014_common.pro
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  COMMON BLOCKS:
;               constants_fund_em_atomic_c2014_common.pro
;
;  CALLS:
;               constants_fund_em_atomic_c2014_common.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               set_common_constants_fund_em_atomic_c2014
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
;               1)  This routine should only be called once
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

PRO set_common_constants_fund_em_atomic_c2014

;;----------------------------------------------------------------------------------------
;;  Load Common Block
;;----------------------------------------------------------------------------------------
@constants_fund_em_atomic_c2014_common.pro
;;----------------------------------------------------------------------------------------
;;  Define constants
;;----------------------------------------------------------------------------------------
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
GG             = 6.6742800000d-11         ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1), 2018 AA values]
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
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
;;  Physico-Chemical
amu            = 1.6605390400d-27         ;;  Atomic mass constant [kg, 2014 CODATA/NIST]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END