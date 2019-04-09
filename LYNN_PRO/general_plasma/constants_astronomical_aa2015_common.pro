;+
;*****************************************************************************************
;
;  COMMON   :   constants_astronomical_aa2015_common.pro
;  PURPOSE  :   Common block to use certain variables as global variables for
;                 astronomical constants from the 2015 AA values.
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
;               @constants_astronomical_aa2015_common.pro
;
;  KEYWORDS:    
;               NA
;
;  COMMON BLOCK VARIABLES:
;
;               R_S___M  :  Sun's Mean Equatorial Radius [m, 2015 AA values]
;               R_ME__M  :  Mercury's Mean Equatorial Radius [m, 2015 AA values]
;               R_VE__M  :  Venus' Mean Equatorial Radius [m, 2015 AA values]
;               R_EA__M  :  Earth's Mean Equatorial Radius [m, 2015 AA values]
;               R_MA__M  :  Mars' Mean Equatorial Radius [m, 2015 AA values]
;               R_JU__M  :  Jupiter's Mean Equatorial Radius [m, 2015 AA values]
;               R_SA__M  :  Saturn's Mean Equatorial Radius [m, 2015 AA values]
;               R_UR__M  :  Uranus's Mean Equatorial Radius [m, 2015 AA values]
;               R_NE__M  :  Neptune's Mean Equatorial Radius [m, 2015 AA values]
;               R_PL__M  :  Pluto's Mean Equatorial Radius [m, 2015 AA values]
;               MS_M_ME  :  Ratio of sun-to-Mercury's mass [unitless, 2015 AA values]
;               MS_M_VE  :  Ratio of sun-to-Venus' mass [unitless, 2015 AA values]
;               MS_M_EA  :  Ratio of sun-to-Earth's mass [unitless, 2015 AA values]
;               MS_M_MA  :  Ratio of sun-to-Mars' mass [unitless, 2015 AA values]
;               MS_M_JU  :  Ratio of sun-to-Jupiter's mass [unitless, 2015 AA values]
;               MS_M_SA  :  Ratio of sun-to-Saturn's mass [unitless, 2015 AA values]
;               MS_M_UR  :  Ratio of sun-to-Uranus's mass [unitless, 2015 AA values]
;               MS_M_NE  :  Ratio of sun-to-Neptune's mass [unitless, 2015 AA values]
;               MS_M_PL  :  Ratio of sun-to-Pluto's mass [unitless, 2015 AA values]
;               M_E__KG  :  Earth's mass [kg, 2015 AA values]
;               M_S__KG  :  Sun's mass [kg, 2015 AA values]
;               M_ME_KG  :  Mercury's mass [kg, 2015 AA values]
;               M_VE_KG  :  Venus' mass [kg, 2015 AA values]
;               M_EA_KG  :  Earth's mass [kg, 2015 AA values]
;               M_MA_KG  :  Mars' mass [kg, 2015 AA values]
;               M_JU_KG  :  Jupiter's mass [kg, 2015 AA values]
;               M_SA_KG  :  Saturn's mass [kg, 2015 AA values]
;               M_UR_KG  :  Uranus's mass [kg, 2015 AA values]
;               M_NE_KG  :  Neptune's mass [kg, 2015 AA values]
;               M_PL_KG  :  Pluto's mass [kg, 2015 AA values]
;               AU       :  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
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

COMMON constants_astronomical_aa2015_common,R_S___m,R_Me__m,R_Ve__m,R_Ea__m,R_Ma__m,R_Ju__m,$
                                            R_Sa__m,R_Ur__m,R_Ne__m,R_Pl__m,M_E__kg,M_S__kg,$
                                            au,Ms_M_Me,Ms_M_Ve,Ms_M_Ea,Ms_M_Ma,Ms_M_Ju,     $
                                            Ms_M_Sa,Ms_M_Ur,Ms_M_Ne,Ms_M_Pl,M_Me_kg,M_Ve_kg,$
                                            M_Ea_kg,M_Ma_kg,M_Ju_kg,M_Sa_kg,M_Ur_kg,M_Ne_kg,$
                                            M_Pl_kg


