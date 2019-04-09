;+
;*****************************************************************************************
;
;  PROCEDURE:   set_common_constants_astronomical_aa2015.pro
;  PURPOSE  :   This routine defines the common block variables for
;                 constants_astronomical_aa2015_common.pro
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  COMMON BLOCKS:
;               constants_astronomical_aa2015_common.pro
;
;  CALLS:
;               constants_astronomical_aa2015_common.pro
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

PRO set_common_constants_astronomical_aa2015

;;----------------------------------------------------------------------------------------
;;  Load Common Block
;;----------------------------------------------------------------------------------------
@constants_astronomical_aa2015_common.pro
;;----------------------------------------------------------------------------------------
;;  Define constants
;;----------------------------------------------------------------------------------------
;;  Radii of celestial bodies
R_S___m        = 6.9600000d08             ;;  Sun's Mean Equatorial Radius [m, 2015 AA values]
R_Me__m        = 2.4397000d06             ;;  Mercury's Mean Equatorial Radius [m, 2015 AA values]
R_Ve__m        = 6.0518000d06             ;;  Venus' Mean Equatorial Radius [m, 2015 AA values]
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
R_Ma__m        = 3.3961900d06             ;;  Mars' Mean Equatorial Radius [m, 2015 AA values]
R_Ju__m        = 7.1492000d07             ;;  Jupiter's Mean Equatorial Radius [m, 2015 AA values]
R_Sa__m        = 6.0268000d07             ;;  Saturn's Mean Equatorial Radius [m, 2015 AA values]
R_Ur__m        = 2.5559000d07             ;;  Uranus's Mean Equatorial Radius [m, 2015 AA values]
R_Ne__m        = 2.4764000d07             ;;  Neptune's Mean Equatorial Radius [m, 2015 AA values]
R_Pl__m        = 1.1950000d06             ;;  Pluto's Mean Equatorial Radius [m, 2015 AA values]
;;  --> Planetary masses as ratio to sun's mass
Ms_M_Me        = 6.023600000d06           ;;  Ratio of sun-to-Mercury's mass [unitless, 2015 AA values]
Ms_M_Ve        = 4.085237190d05           ;;  Ratio of sun-to-Venus' mass [unitless, 2015 AA values]
Ms_M_Ea        = 3.329460487d05           ;;  Ratio of sun-to-Earth's mass [unitless, 2015 AA values]
Ms_M_Ma        = 3.098703590d06           ;;  Ratio of sun-to-Mars' mass [unitless, 2015 AA values]
Ms_M_Ju        = 1.047348644d03           ;;  Ratio of sun-to-Jupiter's mass [unitless, 2015 AA values]
Ms_M_Sa        = 3.497901800d03           ;;  Ratio of sun-to-Saturn's mass [unitless, 2015 AA values]
Ms_M_Ur        = 2.290298000d04           ;;  Ratio of sun-to-Uranus's mass [unitless, 2015 AA values]
Ms_M_Ne        = 1.941226000d04           ;;  Ratio of sun-to-Neptune's mass [unitless, 2015 AA values]
Ms_M_Pl        = 1.365660000d08           ;;  Ratio of sun-to-Pluto's mass [unitless, 2015 AA values]
;;  --> Planetary masses in SI units
M_E__kg        = 5.9722000d24             ;;  Earth's mass [kg, 2015 AA values]
M_S__kg        = 1.9884000d30             ;;  Sun's mass [kg, 2015 AA values]
M_Me_kg        = M_S__kg[0]/Ms_M_Me[0]    ;;  Mercury's mass [kg, 2015 AA values]
M_Ve_kg        = M_S__kg[0]/Ms_M_Ve[0]    ;;  Venus' mass [kg, 2015 AA values]
M_Ea_kg        = M_S__kg[0]/Ms_M_Ea[0]    ;;  Earth's mass [kg, 2015 AA values]
M_Ma_kg        = M_S__kg[0]/Ms_M_Ma[0]    ;;  Mars' mass [kg, 2015 AA values]
M_Ju_kg        = M_S__kg[0]/Ms_M_Ju[0]    ;;  Jupiter's mass [kg, 2015 AA values]
M_Sa_kg        = M_S__kg[0]/Ms_M_Sa[0]    ;;  Saturn's mass [kg, 2015 AA values]
M_Ur_kg        = M_S__kg[0]/Ms_M_Ur[0]    ;;  Uranus's mass [kg, 2015 AA values]
M_Ne_kg        = M_S__kg[0]/Ms_M_Ne[0]    ;;  Neptune's mass [kg, 2015 AA values]
M_Pl_kg        = M_S__kg[0]/Ms_M_Pl[0]    ;;  Pluto's mass [kg, 2015 AA values]
;;  Astronomical unit (AU)
au             = 1.49597870700d+11        ;;  1 AU [m, from Mathematica 10.1 on 2015-04-21]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
