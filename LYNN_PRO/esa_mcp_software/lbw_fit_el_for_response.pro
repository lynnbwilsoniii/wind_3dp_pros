;*****************************************************************************************
;
;  FUNCTION :   lbw_el_df.pro
;  PURPOSE  :   This is a modified version of lbw_eldf.pro specific to the fitting
;                 routine that expects a slightly altered version of the PARAM structure.
;
;  CALLED BY:   
;               lbw_fit_el_for_response.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               @load_constants_fund_em_atomic_c2014_batch.pro
;               @load_constants_extra_part_co2014_ci2015_batch.pro
;               @load_constants_astronomical_aa2015_batch.pro
;               energy_to_vel.pro
;               sphere_to_cart.pro
;               unit_vec.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               ENERGY      :  [E,A]-Element [numeric] array of energy bin values [eV]
;               THETA       :  [E,A]-Element [numeric] array of poloidal angles [deg]
;               PHI         :  [E,A]-Element [numeric] array of azimuthal angles [deg]
;
;  EXAMPLES:    
;               [calling sequence]
;               ff = lbw_el_df(energy,theta,phi [,PARAMETERS=parameters])
;
;  KEYWORDS:    
;               PARAMETERS  :  Scalar [structure] containing relevant fit and photo-
;                                electron energy flux information (see code for more)
;
;   CHANGED:  1)  Routine last modified by ??
;                                                                   [??/??/????   v1.0.0]
;             2)  Routine updated and renamed from el_df.pro to lbw_el_df.pro
;                   and now does all computations in double-precision
;                                                                   [02/20/2020   v1.0.1]
;
;   NOTES:      
;               1)  User should not call this routine directly
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: el_df.pro    BY: Davin Larson
;   CREATED:  02/20/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/20/2020   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION lbw_el_df,energy,theta,phi,PARAMETERS=p

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Get fundamental and astronomical
@load_constants_fund_em_atomic_c2014_batch.pro
@load_constants_extra_part_co2014_ci2015_batch.pro
@load_constants_astronomical_aa2015_batch.pro
mass           = me_esa[0]
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF N_PARAMS() EQ 1 THEN BEGIN
  ;;  Set default angles
  the0   = 0e0
  phi0   = 0e0
ENDIF ELSE BEGIN
  the0   = 1d0*theta
  phi0   = 1d0*phi
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define some relevant parameters
;;----------------------------------------------------------------------------------------
;;  Define the electron energy at infinity
dener          = DOUBLE(energy)
nrg_inf        = DOUBLE(dener - p[0].SC_POT[0])
;;  Define the electron velocities [km/s] in cartesian coordinates
spd            = energy_to_vel((nrg_inf > 0.01d0),mass[0])     ;;  Particle speed [km/s] far from potential
sphere_to_cart,spd,the0,phi0,vx,vy,vz
magf           = p[0].MAGF
bdir           = unit_vec(magf,/NAN)
bx             = bdir[0]
by             = bdir[1]
bz             = bdir[2]
vsw            = p[0].VSW
szdde          = SIZE(dener,/DIMENSIONS)
sznde          = SIZE(dener,/N_DIMENSIONS)
nn2            = szdde[0]
IF (nn2[0] GT 2) THEN BEGIN
  IF (sznde[0] GE 2) THEN BEGIN
    e0 = SHIFT(dener,1,0)   & e0[0L,*]            = e0[1L,*]
    e2 = SHIFT(dener,-1,0)  & e2[(nn2[0] - 1L),*] = e2[(nn2[0] - 2L),*]
  ENDIF ELSE BEGIN
    e0 = SHIFT(dener,1)   & e0[0L]                = e0[1L]
    e2 = SHIFT(dener,-1)  & e2[(nn2[0] - 1L)]     = e2[(nn2[0] - 2L)]
  ENDELSE
  ;;  Define ∆E = E_2 - E_1
  de   = ABS(e2 - e0)
  ;;  Define weights for every energy bin
  wght =  0d0 > ((dener + e0 - 2d0*p[0].SC_POT[0])/de) < 1d0
ENDIF ELSE wght = DOUBLE(dener GT p[0].SC_POT[0])
;;----------------------------------------------------------------------------------------
;;  Define photoelectron [df,flux,eflux] contribution
;;----------------------------------------------------------------------------------------
;;  Initialize photoelectron distribution variables
f              = 0d0
a              = 2d0/mass[0]/mass[0]/1d5
photo          = p[0].PH
IF KEYWORD_SET(photo.EFLUX[0]) THEN BEGIN
  ;;  Interpolate with double-precision and return to single-precision after completion
  pener  = DOUBLE(photo.NRG)
  peflx  = DOUBLE(photo.EFLUX)
  ;;  Determine the type of spline interpolation to be used
  eflx2  = SPL_INIT(ALOG(pener),ALOG(peflx),/DOUBLE)
  ;;  Spline interpolation in log-space
  splef  = SPL_INTERP(ALOG(pener),ALOG(peflx),eflx2,ALOG(dener),/DOUBLE)
  ;;  Convert back to linear space and renormalize
  fphoto = EXP(splef)/dener^2d0/a[0]
  f     += (((1d0 - wght) * fphoto))
ENDIF
;;----------------------------------------------------------------------------------------
;;  Add core electron [df,flux,eflux] contribution
;;----------------------------------------------------------------------------------------
IF (p[0].CORE.N NE 0) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Define CORE structure
  ;;--------------------------------------------------------------------------------------
  maxw  = p[0].CORE
  ;;  Remove field-aligned drift
  vrel  = vsw + (bdir * maxw.V[0])        ;;  V_rel = V_sw + (Vo.b) b
  vsx   = vx - vrel[0] 
  vsy   = vy - vrel[1]
  vsz   = vz - vrel[2]
  ;;  Compute V'.V' [km^(+2) s^(-2)]
  vtot2 = vsx*vsx + vsy*vsy + vsz*vsz
  ;;  Compute:  cos(a)^2 = (V'.b)^2/(V'.V')
  cos2a = (vsx*bx + vsy*by + vsz*bz)^2d0/vtot2
  ;;  Compute Exponent in terms of (V'.V') and ∆T
  ;;    ∆T = Tperp/Tpara - 1
  e     = EXP(-0.5d0*mass[0]*vtot2/maxw.T[0]*(1d0 + cos2a*maxw.TDIF[0]))                     ;;  Exponential : e  = -[m (V'.V')/(2 T) * [1 + ∆T * Cos(2a)] ]
  k     = 1d10*(mass[0]/2d0/!DPI)^(3d0/2d0)                                                  ;;  Constant    : k  = [m/(2 π)]^(3/2)
  fcore = (k[0]*maxw.N[0]*SQRT( (1d0 + maxw.TDIF[0])/maxw.T[0]^3d0 ))*e
  ;;  Accumulate to f(v)
  f    += (wght*fcore)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Add halo electron [df,flux,eflux] contribution
;;----------------------------------------------------------------------------------------
IF (p[0].HALO.N NE 0) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Define HALO structure
  ;;--------------------------------------------------------------------------------------
  maxw  = p[0].HALO
  ;;  Remove field-aligned drift
  vrel  = vsw + (bdir * maxw.V[0])
  vsx   = vx - vrel[0] 
  vsy   = vy - vrel[1]
  vsz   = vz - vrel[2]
  ;;  Compute V'.V' [km^(+2) s^(-2)]
  vtot2 = vsx*vsx + vsy*vsy + vsz*vsz
  ;;  Compute:  cos(a)^2 = (V'.b)^2/(V'.V')
  cos2a = (vsx*bx + vsy*by + vsz*bz)^2d0/vtot2
  ;;  Compute constant
  vh2   = (maxw.K[0] - 3d0/2d0)*maxw.VTH[0]^2d0
  kc    = 1d10*GAMMA(maxw.K[0] + 1d0)/GAMMA(maxw.K[0] - 1d0/2d0)*(!DPI*vh2)^(-3d0/2d0)
  ;;  Compute halo contribution
  fhalo = maxw.N[0]*kc*( 1d0 + (vtot2/vh2) )^(-1d0*(maxw.K[0] + 1d0))
  ;;  Accumulate to f(v)
  f    += (wght*fhalo)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to main calling routine
;;----------------------------------------------------------------------------------------

RETURN,f
END


;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_fit_el_for_response.pro
;  PURPOSE  :   This is a wrapping routine that attempts to fit to a given velocity
;                 distribution function (VDF) a core+halo model and then determine the
;                 corrections to each anode geometric factor that would be necessary
;                 to give the "correct" result.  The output accuracy is heavily dependent
;                 upon knowing the spacecraft potential and total electron density.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               lbw_el_df.pro
;
;  CALLS:
;               @load_constants_fund_em_atomic_c2014_batch.pro
;               @load_constants_extra_part_co2014_ci2015_batch.pro
;               @load_constants_astronomical_aa2015_batch.pro
;               str_element.pro
;               lbw_el_response.pro
;               lbw_el_df.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X           :  Scalar [structure] associated with a known Wind/3DP
;                                EESA Low data structure
;                                [see get_?.pro, ? = el or elb]
;
;  EXAMPLES:    
;               [calling sequence]
;               data = lbw_fit_el_for_response(x [,SET=set] [,TYPE=type] [,PARAMETERS=parameters] )
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               SET         :  If set, routine will alter structure tag values within X
;                                [Default = FALSE]
;               TYPE        :  ***  Obsolete/Not Used  ***
;               PARAMETERS  :  Scalar [structure] containing relevant fit and photo-
;                                electron energy flux information (see code for more)
;               **********************************
;               ***       DIRECT OUTPUTS       ***
;               **********************************
;               PARAMETERS  :  Set to a named variable to return the structure containing
;                                the relevant information necessary for routine to
;                                compute the corrected counts
;
;   CHANGED:  1)  Routine last modified by ??
;                                                                   [??/??/????   v1.0.0]
;             2)  Routine updated and renamed from elfit7.pro to lbw_fit_el_for_response.pro
;                   and now does all computations in double-precision
;                                                                   [02/20/2020   v1.0.1]
;
;   NOTES:      
;               0a)  3DP Notes from Lin et al. [1995]:
;                     --  All MCPs are ~1 mm thick in chevron configuration with a bias
;                           angle of ~8 degrees
;                     --  EL and PL have 16 anodes, EH and PH have 24
;                     --  EL, PL, and PH:
;                           R_1    ~ 3.75 cm
;                           ∆R/R_1 ~ 0.075
;                           ∆R     ~ 0.28125 cm
;                           R_2    ~ 4.03125 cm
;                           <R>    ~ 3.890625 cm
;                           R_v    ~ 3.8855422 cm
;                           ∆E/E   ~ 0.20 FWHM
;                           ∆R_tc  ~ 0.56 cm  [top-cap separation]
;                                  = R_tc - R_2
;                           ∆psi   ~ 7 deg (~7.5 deg FWHM)
;                           <R>/∆R ~ 13.8333
;                     --  EL:
;                           *** e- post accelerated by ~500 V to increase efficiency to ~70% ***
;                           €_i    ~ 0.013*E [cm^(+2) sr]
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
;                     --  E = q (V_2 - V_1)/[2 ln|R_2/R_1|]
;                           E    :  energy of incident particle allowed by analyzer
;                           q    :  charge of incident particle
;                           V_j  :  voltage on jth electrode (2 = outer)
;                           R_j  :  radius of jth hemisphere (2 = outer)
;                     --  k = <R>/∆R or K ~ 2 (E/q)/∆V
;                           k    :  analyzer constant
;                           K    :  analyzer constant
;                           <R>  :  mean radius = (R_1 + R_2)/2
;                           ∆R   :  gap distance = (R_2 - R_1)
;                           ∆V   :  potential difference = (V_2 - V_1)
;                           ∆E   :  intrinsic passband energy = q ∆V = (E_2 - E_1)
;                           <E>  :  mean energy = (E_1 + E_2)/2
;                           E_1  :  lower energy bound = (2 <E> - ∆E)/2
;                           E_2  :  upper energy bound = (2 <E> + ∆E)/2
;                           R_v  :  mid-radius between hemispheres
;                                   = (R_1 R_2)/<R>
;                     --  E/q = R/2 dV/dR ~ 1/2 ∆V/∆R (R_1 R_2)/R
;                           E/q  :  energy per charge
;                              Lim_{R --> R_v} (E/q) ~ 1/2 ∆V k
;                           R    :  radius actually traveled by incident particle
;                     --  ∆E/E ~ Mean[ 8^(1/2) ∆R/(R_1 R_2) R] ~ 0.2047
;                              where:  R_1 ≤ R ≤ R_2 and extra 2^(1/2) comes from FWHM?
;                              *** This is how I get the ∆E/E to match the 3DP paper values ***
;                     --  or let ∆E/E ~ Mean[2 (2 ln 2)^(1/2) ∆R/(R_1 R_2) R] ~ 0.1705
;                          *** Mean[ ] --> 0.2046 if constructed in ln space ***
;                          [Paschmann and Daly, 1998, pgs 99--105, Ch 5]
;
;  REFERENCES:  
;               1)  Carlson et al., "An instrument for rapidly measuring plasma
;                      distribution functions with high resolution,"
;                      Adv. Space Res. Vol. 2, pp. 67-70, 1983.
;               2)  Curtis et al., "On-board data analysis techniques for space plasma
;                      particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372, 1989.
;               3)  Lin et al., "A Three-Dimensional Plasma and Energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125, 1995.
;               4)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                      Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst., 1998.
;               5)  R.R. Goruganthu and W.G. Wilson "Relative electron detection
;                      efficiency of microchannel plates from 0-3 keV,"
;                      Rev. Sci. Instrum. Vol. 55(12), pp. 2030--2033,
;                      doi:10.1063/1.1137709, 1984.
;               6)  F. Bordoni "Channel electron multiplier efficiency for 10-1000 eV
;                      electrons," Nucl. Inst. & Meth. Vol. 97, pp. 405--408,
;                      doi:10.1016/0029-554X(71)90300-4, 1971.
;               7)  M. Wüest, D.S. Evans, and R. von Steiger "Calibration of Particle
;                      Instruments in Space Physics," ESA Publications Division,
;                      Keplerlaan 1, 2200 AG Noordwijk, The Netherlands, 2007.
;               8)  M. Wüest, et al., "Review of Instruments," ISSI Sci. Rep. Ser.
;                      Vol. 7, pp. 11--116, 2007.
;               9)  J. Ladislas Wiza "Microchannel plate detectors," Nucl. Inst. & Meth.
;                      Vol. 162(1), pp. 587--601, doi:10.1016/0029-554X(79)90734-1, 1979.
;              10)  J.D. Mackenzie "MCP Glass Analysis Studies" Technical Report,
;                      Contract No. DAAG 53-75-C-0222, prepared for Night Vision Lab.,
;                      prepared by J.D. Mackenzie at UCLA.
;              11)  R.S. Gao, et al., "Absolute and angular efficiencies of a
;                      microchannel-plate position-sensitive detector," Rev. Sci. Inst.
;                      Vol. 55(11), pp. 1756--1759, doi:10.1063/1.1137671, 1984.
;              11)  M. Barat, J.C. Brenot, J A. Fayeton, and Y.J. Picard "Absolute
;                      detection efficiency of a microchannel plate detector for
;                      neutral atoms," Rev. Sci. Inst. Vol. 71(5), pp. 2050--2052,
;                      doi:10.1063/1.1150615, 2000.
;              12)  A. Brunelle, et al., "Secondary Electron Emission Yields from a CsI
;                      Surface Under Impacts of Large Molecules at Low Velocities
;                      (5–70 km/s)", Rapid Commun. Mass Spectrom. Vol. 11(4),
;                      pp. 353--362, 1997.
;              13)  C. Meeks and P.B. Siegel "Dead time correction via the time series,"
;                      Amer. J. Phys. Vol. 76(6), pp. 589--590, doi:10.1119/1.2870432,
;                      2008.
;              14)  J.A. Schecker, M.M. Schauer, K. Holzscheiter, and M.H. Holzscheiter
;                      "The performance of a microchannel plate at cryogenic temperatures
;                      and in high magnetic fields, and the detection efficiency for low
;                      energy positive hydrogen ions," Nucl. Inst. & Meth. Vol. 320,
;                      pp. 556--561, doi:10.1016/0168-9002(92)90950-9, 1992.
;              15)  G.W. Fraser "The ion detection efficiency of microchannel plates
;                      (MCPs)," Int. J. Mass Spectrom. Vol. 215(1-3), pp. 13--30,
;                      doi:10.1016/S1387-3806(01)00553-X, 2002.
;              16)  B. Brehm, J. Grosser, T. Ruscheinski, and M. Zimmer "Absolute
;                      detection efficiencies of a microchannel plate detector for ions,"
;                      Meas. Sci. Technol. Vol. 6(7), pp. 953--958,
;                      doi:10.1088/0957-0233/6/7/015, 1995.
;              17)  G.W. Fraser "The electron detection efficiency of microchannel plates,"
;                      Nucl. Inst. & Meth. Phys. Res. Vol. 206(3), pp. 445--449,
;                      doi:10.1016/0167-5087(83)90381-2, 1983.
;              18)  M. Hellsing, L. Karlsson, H.-O. Andren, and H. Norden "Performance of
;                      a microchannel plate ion detector in the energy range 3-25 keV,"
;                      J. Phys. E Sci. Instrum. Vol. 18(11), pp. 920--925,
;                      doi:10.1088/0022-3735/18/11/009, 1985.
;              19)  R. Meier and P. Eberhardt "Velocity and ion species dependence of the
;                      gain of microchannel plates," Int. J. Mass Spectrom. Ion Proc.
;                      Vol. 123(1), pp. 19--27, doi:10.1016/0168-1176(93)87050-3, 1993.
;              20)  A. Muller, N. Djuric, G.H. Dunn, D.S. Belic "Absolute detection
;                      efficiencies of microchannel plates for 0.1-2.3 keV electrons and
;                      2.1-4.4 keV Mg^(+) ions," Rev. Sci. Inst. Vol. 57(3), pp. 349--353,
;                      doi:10.1063/1.1138944, 1986.
;              21)  J. Schou "Transport theory for kinetic emission of secondary electrons
;                      from solids," Phys. Rev. B Vol. 22(5), pp. 2141--2174,
;                      doi:10.1103/PhysRevB.22.2141, 1980.
;              22)  H.C. Straub, M.A. Mangan, B.G. Lindsay, K.A. Smith, R.F. Stebbings
;                      "Absolute detection efficiency of a microchannel plate detector for
;                      kilo-electron volt energy ions," Rev. Sci. Inst. Vol. 70(11),
;                      pp. 4238--4240, doi:10.1063/1.1150059, 1999.
;              23)  D.M. Suszcynsky and J.E. Borovsky "Modified Sternglass theory for the
;                      emission of secondary electrons by fast-electron impact,"
;                      Phys. Rev. A Vol. 45(9), pp. 6424--6428,
;                      doi:10.1103/PhysRevA.45.6424, 1992.
;              24)  E.M. Baroody "A Theory of Secondary Electron Emission from Metals,"
;                      Phys. Rev. Vol. 78(6), pp. 780--787, doi:10.1103/PhysRev.78.780,
;                      1950.
;              25)  E.J. Sternglass "Backscattering of Kilovolt Electrons from Solids,"
;                      Phys. Rev. Vol. 95(2), pp. 345--358, doi:10.1103/PhysRev.95.345,
;                      1954.
;              26)  E.J. Sternglass "Theory of Secondary Electron Emission by High-Speed
;                      Ions," Phys. Rev. Vol. 108(1), pp. 1--12,
;                      doi:10.1103/PhysRev.108.1, 1957.
;              27)  M. Rosler and W. Brauer "Theory of Electron Emission from Solids by
;                      Proton and Electron Bombardment," Phys. Stat. Sol. B Vol. 148(1),
;                      pp. 213--226, doi:10.1002/pssb.2221480119, 1988.
;              28)  K. Kanaya and H. Kawakatsu "Secondary electron emission due to primary
;                      and backscattered electrons," J. Phys. D Appl. Phys. Vol. 5(9),
;                      pp. 1727--1742, doi:10.1088/0022-3727/5/9/330, 1972.
;
;   ADAPTED FROM: elfit7.pro    BY: Davin Larson
;   CREATED:  02/20/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/20/2020   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_fit_el_for_response,x,SET=set,TYPE=type,PARAMETERS=p

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Get fundamental and astronomical
@load_constants_fund_em_atomic_c2014_batch.pro
@load_constants_extra_part_co2014_ci2015_batch.pro
@load_constants_astronomical_aa2015_batch.pro
;;  Conversion factors
;;    Energy and Temperature
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> eV2K*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> K2eV*Temp{K} = energy{eV}]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check PARAMETER
IF (SIZE(p,/TYPE) NE 8) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Define default PARAM structure
  ;;--------------------------------------------------------------------------------------
  ;;  Define photon energy flux at specific energies
  pnrg  = [5.18234e00, 5.92896e00, 7.25627e00, 9.41315e00, 1.28144e01, 1.82895e01, 2.72489e01, 4.17663e01, 6.52431e01, 1.03320e02, 1.64957e02, 2.64837e02, 4.26769e02, 6.89161e02, 1.11299e03]
  eflux = [3.39420e08, 2.77170e08, 2.05402e08, 1.49702e08, 9.07756e07, 3.88106e07, 2.41517e07, 1.01327e07, 2.40907e06, 4.00220e05, 3.68695e05, 2.71865e05, 1.45748e05, 5.93220e04, 2.63676e04]
  photo = {EFLUX:eflux,NRG:pnrg}
  ;;  Define electron structures
  ;;    N     :  number density [cm^(-3)]
  ;;    T     :  scalar average temperature [eV] or Tperp [eV], depending
  ;;    TRAT  :  Tpara/Tperp ratio
  ;;    TDIF  :  Tperp/Tpara - 1
  ;;    VTH   :  most probable thermal speed [km/s]
  ;;    V     :  parallel drift speed [km/s] in VSW frame
  core  = {N:10d0,T:10d0,TDIF:0d0,V:0d0}           ;;  Fit parameter guesses for core electrons
  halo  = {N:0.1d0,VTH:5000d0,K:4.3d0,V:0d0}       ;;  Fit parameter guesses for halo electrons
  p13   = {PH:photo,CORE:core,HALO:halo,       $
           E_SHIFT:0d0,                        $   ;;  Scalar energy shift [eV] to be applied to energy bins
           V_SHIFT:0.31d0,                     $   ;;  Scalar voltage shift [V] to be applied to analyzer voltages
           SC_POT:5d0,                         $   ;;  Scalar spacecraft potential [eV]
           VSW:[500d0,0d0,0d0],                $   ;;  Bulk flow velocity [km/s] guess
           MAGF:[0e0,0e0,1e0],                 $   ;;  Quasi-static magnetic field [nT] guess
           NTOT:10d0,                          $   ;;  Total number density [cm^(-3)] guess
           DFLAG:0,                            $   ;;  Logic variable defining whether to use NTOT
           DEADTIME:0.6d-6,                    $   ;;  analyzer deadtime [s]
           EXPAND:8 }                              ;;  Scalar [numeric] value of elements by which to expand arrays
  ;;  Redefine output keyword
  p     = p13
ENDIF
;;  Check densities
IF (p[0].DFLAG[0]) THEN p[0].CORE.N = (p[0].NTOT[0] - p[0].HALO.N[0]) ELSE p[0].NTOT = (p[0].CORE.N[0] + p[0].HALO.N[0])
;;----------------------------------------------------------------------------------------
;;  Set limits on parameters
;;----------------------------------------------------------------------------------------
IF (SIZE(x,/TYPE) NE 8) THEN BEGIN
  p.SC_POT       =  0.10e0    > p[0].SC_POT[0]     < 50e0
  p.NTOT         =  0.05e0    > p[0].NTOT[0]       < 200e0
  p.CORE.N       =  0.05e0    > p[0].CORE.N[0]     < 200e0
  p.CORE.T       =  3.00e0    > p[0].CORE.T[0]     < 90e0
  p.CORE.TDIF    = -0.70e0    > p[0].CORE.TDIF[0]  < 0.60e0
  p.CORE.V       =  -500e0    > p[0].CORE.V        < 500e0
  p.HALO.N       =  0.002e0   > p[0].HALO.N        < 5e0
  p.HALO.VTH     =  2000e0    > ABS(p[0].HALO.VTH) < 10000e0
  p.HALO.V       = -9000e0    > p[0].HALO.V        < 9000e0
  p.HALO.K       =  1.75e0    > p[0].HALO.K        < 15e0
  p.VSW          = [-900.,-200.,-200.] > p[0].VSW  < [200.,200.,200.]
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
mass           = x[0].MASS[0]
theta          = x[0].THETA
phi            = x[0].PHI
IF KEYWORD_SET(p.EXPAND) THEN expand = 16
str_element,x,'VOLTS',volts     ;;  Get array of MCP voltages from structure X
IF NOT KEYWORD_SET(volts) THEN expand = 0
;;----------------------------------------------------------------------------------------
;;  Check EXPAND
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(expand) THEN BEGIN
  nn     = x[0].NENERGY
  nb     = x[0].NBINS
  ;;  Offset voltages accordingly
  vnew   = x[0].VOLTS + p[0].V_SHIFT
  nn2    = expand[0]*nn[0]
  ;;  Calculate instrument response and return proper energy bin values
  resp   = lbw_el_response(vnew,nrg2,NSTEPS=nn2[0])
  i      = REPLICATE(1d0,expand[0])
  ;;  Expand energy bin values
  energy = nrg2[*] # REPLICATE(1d0,nb[0])
  phi    = REFORM(i # phi[*],nn2[0],nb[0])
  theta  = REFORM(i # theta[*],nn2[0],nb[0])
  ;;  Convolve energy bins with instrument response
  esteps = resp # nrg2
ENDIF ELSE BEGIN
  ;;  No expansion requested --> define VDF energy bins
  energy = x[0].ENERGY
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Compute VDF given pre-defined parameters
;;----------------------------------------------------------------------------------------
f              = lbw_el_df(energy,theta,phi,PARAMETERS=p)
;;  Convert to energy flux [eV cm^(-2) s^(-1) sr^(-1) eV^(-1)]
a              = 2d0/mass[0]/mass[0]/1d5
eflux          = f * energy^2d0 * a[0]
IF KEYWORD_SET(expand) THEN BEGIN
  eflux          = (resp # eflux)
  energy         = (resp # energy)
  theta          = (resp # theta)
  phi            = (resp # phi)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Convert units
;;----------------------------------------------------------------------------------------
units          = x[0].UNITS_NAME[0]
CASE STRLOWCASE(units[0]) OF
  'df'     :  data = eflux/energy^2d0/a[0]
  'flux'   :  data = eflux/energy
  'eflux'  :  data = eflux
  ELSE     : BEGIN
    crate    =  x[0].GEOMFACTOR * x[0].GF * eflux
    anode    = BYTE((90 - x[0].THETA)/22.5)
    deadtime = (p[0].DEADTIME/[1.,1.,2.,4.,4.,2.,1.,1.])[anode]
    rate     = crate/(1+ deadtime *crate)
    bkgrate  = 0
    str_element,p,'BKGRATE',bkgrate
    rate    += bkgrate
    CASE STRLOWCASE(units[0]) OF
      'crate'  :  data = crate
      'rate'   :  data = rate
      'counts' :  data = rate * x[0].DT
    ENDCASE
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Check SET
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(set) THEN BEGIN
  ;;  User wishes to redefine structure tag values
  x[0].DATA     = FLOAT(data)
  x[0].ENERGY   = FLOAT(energy)
  x[0].E_SHIFT  = FLOAT(p[0].E_SHIFT[0])
  str_element,x,'SC_POT',FLOAT(p[0].SC_POT[0]),/ADD_REPLACE
  x[0].VSW      = FLOAT(p[0].VSW)
  x[0].MAGF     = FLOAT(p[0].MAGF)
  str_element,x,'DEADTIME',deadtime,/ADD_REPLACE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check BINS
;;----------------------------------------------------------------------------------------
str_element,x,'BINS',VALUE=bins
IF (N_ELEMENTS(bins) GT 0) THEN BEGIN
  ind  = WHERE(bins)
  data = data(ind)
ENDIF ELSE data = REFORM(data,N_ELEMENTS(data),/OVERWRITE)

IF KEYWORD_SET(set) AND KEYWORD_SET(bins) THEN BEGIN
  w = WHERE(bins EQ 0,c)
  IF ((c NE 0)  AND (set EQ 2)) THEN x.data[w] = !VALUES.F_NAN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,data
END





