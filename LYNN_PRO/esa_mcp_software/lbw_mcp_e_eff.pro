;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_mcp_e_eff.pro
;  PURPOSE  :   Calculates the theoretical, relative electron detection efficiency of a
;                 microchanel plate (MCP) in a two-stack, chevron configuration with a
;                 carbon-coated, high transmission (94%) copper grid ~6 mm in front of
;                 first MCP.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               ENERGY  :  [N]- or [N,M]-element [numeric] array of incident electron
;                            kinetic energies [eV] for which to calculate the detection
;                            efficiency
;
;  EXAMPLES:    
;               [calling sequence]
;               eff = lbw_mcp_e_eff(energy)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  MCP Design:
;                     A MCP consists of a series of small (5 μm to 0.25 mm diameter) holes
;                     (or channels) in a thin plate (typically 0.4-3.0 mm thick) made of a
;                     conducting material specially fabricated to produce signals similar
;                     to a secondary electron analyzer.  MCPs are often used in pairs
;                     where a cross-sectional cut through two connecting channels creates
;                     a v-shaped tube, called a chevron pair. This prevents incident
;                     particles from directly impacting the detector behind the plates.
;                     When a particle impacts the channel wall, if it has enough energy,
;                     it will produce a shower of electrons. The number of electrons per
;                     incident particle impact is referred to as the gain of the detector.
;               2)  Open Area Ratio
;                     f_OAR = (π/6*SQRT(3))*(d/p)
;                   where
;                     d   :   channel diameter
;                     p   :   pitch or center-to-center channel spacing
;                   Typical MCPs have channel length-to-diameter ratios of 40:1 and
;                   f_OAR ~ 60-70%.
;               3)  MCP Efficiency
;                     delta   :  secondary emission yield function
;                     Tmax    :  maximum emission coefficient
;                     E       :  kinetic energy of incident electron [eV]
;                     Emax    :  energy at which efficiency reaches its maximum value [eV]
;                     ER      :  (E/Emax)
;                     dmax    :  maximum value of the secondary emission coefficient
;                     k       :  an adjustable parameter that depends upon dmax and a
;                                complicated probability
;                     X_1     :  probability that a process started by an electron with
;                                energy Eo terminates
;                     eff     :  relative detection efficiency
;                   Therefore, we can define the following:
;                     k     = dmax*(1 - X_1)
;                     delta = dmax*(ER)^(1 - a)*[term0/term1]
;                   where
;                     term0 = 1 - e^(-Tmax*(ER)^a)
;                     term1 = 1 - e^(-Tmax)
;                   then we have
;                     eff   = [1 - e^(-k*delta/dmax)]/[1 - e^(-k)]
;               4)  3DP EESA Low Values
;                     k     = 2.2
;                     Emax  = 325 eV
;                     Tmax  = 2.283
;                     dmax  = 1.0
;                     a     = 1.35
;               5)  The relative efficiency equation in Goruganthu and Wilson [1984] is
;                     missing a negative sign in the denominator for the factor k.
;
;  REFERENCES:  
;               0)  R.R. Goruganthu and W.G. Wilson "Relative electron detection
;                      efficiency of microchannel plates from 0-3 keV,"
;                      Rev. Sci. Instrum. Vol. 55(12), pp. 2030--2033,
;                      doi:10.1063/1.1137709, 1984.
;               1)  F. Bordoni "Channel electron multiplier efficiency for 10-1000 eV
;                      electrons," Nucl. Inst. & Meth. Vol. 97, pp. 405--408,
;                      doi:10.1016/0029-554X(71)90300-4, 1971.
;               2)  C. Meeks and P.B. Siegel "Dead time correction via the time series,"
;                      Amer. J. Phys. Vol. 76(6), pp. 589--590, doi:10.1119/1.2870432,
;                      2008.
;               3)  J.A. Schecker, M.M. Schauer, K. Holzscheiter, and M.H. Holzscheiter
;                      "The performance of a microchannel plate at cryogenic temperatures
;                      and in high magnetic fields, and the detection efficiency for low
;                      energy positive hydrogen ions," Nucl. Inst. & Meth. Vol. 320,
;                      pp. 556--561, doi:10.1016/0168-9002(92)90950-9, 1992.
;               4)  G.W. Fraser "The ion detection efficiency of microchannel plates
;                      (MCPs)," Int. J. Mass Spectrom. Vol. 215(1-3), pp. 13--30,
;                      doi:10.1016/S1387-3806(01)00553-X, 2002.
;               5)  B. Brehm, J. Grosser, T. Ruscheinski, and M. Zimmer "Absolute
;                      detection efficiencies of a microchannel plate detector for ions,"
;                      Meas. Sci. Technol. Vol. 6(7), pp. 953--958,
;                      doi:10.1088/0957-0233/6/7/015, 1995.
;               6)  G.W. Fraser "The electron detection efficiency of microchannel plates,"
;                      Nucl. Inst. & Meth. Phys. Res. Vol. 206(3), pp. 445--449,
;                      doi:10.1016/0167-5087(83)90381-2, 1983.
;               7)  M. Hellsing, L. Karlsson, H.-O. Andren, and H. Norden "Performance of
;                      a microchannel plate ion detector in the energy range 3-25 keV,"
;                      J. Phys. E Sci. Instrum. Vol. 18(11), pp. 920--925,
;                      doi:10.1088/0022-3735/18/11/009, 1985.
;               8)  R. Meier and P. Eberhardt "Velocity and ion species dependence of the
;                      gain of microchannel plates," Int. J. Mass Spectrom. Ion Proc.
;                      Vol. 123(1), pp. 19--27, doi:10.1016/0168-1176(93)87050-3, 1993.
;               9)  A. Muller, N. Djuric, G.H. Dunn, D.S. Belic "Absolute detection
;                      efficiencies of microchannel plates for 0.1-2.3 keV electrons and
;                      2.1-4.4 keV Mg^(+) ions," Rev. Sci. Inst. Vol. 57(3), pp. 349--353,
;                      doi:10.1063/1.1138944, 1986.
;              10)  J. Schou "Transport theory for kinetic emission of secondary electrons
;                      from solids," Phys. Rev. B Vol. 22(5), pp. 2141--2174,
;                      doi:10.1103/PhysRevB.22.2141, 1980.
;              11)  H.C. Straub, M.A. Mangan, B.G. Lindsay, K.A. Smith, R.F. Stebbings
;                      "Absolute detection efficiency of a microchannel plate detector for
;                      kilo-electron volt energy ions," Rev. Sci. Inst. Vol. 70(11),
;                      pp. 4238--4240, doi:10.1063/1.1150059, 1999.
;              12)  D.M. Suszcynsky and J.E. Borovsky "Modified Sternglass theory for the
;                      emission of secondary electrons by fast-electron impact,"
;                      Phys. Rev. A Vol. 45(9), pp. 6424--6428,
;                      doi:10.1103/PhysRevA.45.6424, 1992.
;              13)  E.M. Baroody "A Theory of Secondary Electron Emission from Metals,"
;                      Phys. Rev. Vol. 78(6), pp. 780--787, doi:10.1103/PhysRev.78.780,
;                      1950.
;              14)  E.J. Sternglass "Backscattering of Kilovolt Electrons from Solids,"
;                      Phys. Rev. Vol. 95(2), pp. 345--358, doi:10.1103/PhysRev.95.345,
;                      1954.
;              15)  E.J. Sternglass "Theory of Secondary Electron Emission by High-Speed
;                      Ions," Phys. Rev. Vol. 108(1), pp. 1--12,
;                      doi:10.1103/PhysRev.108.1, 1957.
;              16)  M. Rosler and W. Brauer "Theory of Electron Emission from Solids by
;                      Proton and Electron Bombardment," Phys. Stat. Sol. B Vol. 148(1),
;                      pp. 213--226, doi:10.1002/pssb.2221480119, 1988.
;              17)  K. Kanaya and H. Kawakatsu "Secondary electron emission due to primary
;                      and backscattered electrons," J. Phys. D Appl. Phys. Vol. 5(9),
;                      pp. 1727--1742, doi:10.1088/0022-3727/5/9/330, 1972.
;
;   ADAPTED FROM: mcp_efficiency.pro    BY: Davin Larson
;   CREATED:  02/26/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/26/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_mcp_e_eff,energy

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  MCP Parameters:  3DP EESA Low Values
kk             = 2.2d0          ;;  Numerical constant determined from fit for carbon and lead glass MCP
Emax           = 325d0          ;;  Energy [eV] at which the relative efficiency reaches a maximum for lead glass [Goruganthu and Wilson, 1984]
Tmax           = 2.283d0
dmax           = 1d0            ;;  maximum value of the secondary emission coefficient for lead glass [Goruganthu and Wilson, 1984]
alpha          = 1.35d0
;;  Dummy error messages
noinpt_msg     = 'No input supplied...'
notnum_msg     = 'Input must be of numeric type...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 1) THEN BEGIN
  ;;  no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_number(energy,/NOMSSG) EQ 0) OR (N_ELEMENTS(energy) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,notnum_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define params
ee             = DOUBLE(energy)        ;;  Keep the same dimensions
;;----------------------------------------------------------------------------------------
;;  Compute secondary emission yield function
;;----------------------------------------------------------------------------------------
erat           = (ee/Emax[0])                             ;;  ER
fac0           = dmax[0]*erat^(1d0 - alpha[0])            ;;  dmax*(ER)^(1 - a)
term0          = 1d0 - EXP(-1d0*Tmax[0]*erat^(alpha[0]))  ;;  1 - e^(-Tmax*(ER)^a)
term1          = 1d0 - EXP(-1d0*Tmax[0])                  ;;  1 - e^(-Tmax)
delta          = fac0*term0/term1[0]                      ;;  delta = dmax*(ER)^(1 - a)*[term0/term1]
;;----------------------------------------------------------------------------------------
;;  Compute detection efficiency
;;----------------------------------------------------------------------------------------
eterm0         = 1d0 - EXP(-1d0*kk[0]*delta/dmax[0])      ;;  1 - e^(-k*delta/dmax)
eterm1         = 1d0 - EXP(-1d0*kk[0])                    ;;  1 - e^(-k)
eff            = eterm0/eterm1[0]                         ;;  eff   = [1 - e^(-k*delta/dmax)]/[1 - e^(-k)]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,eff
END

