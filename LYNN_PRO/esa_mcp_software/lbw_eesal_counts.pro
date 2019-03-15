;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_eesal_counts.pro
;  PURPOSE  :   Computes the counts that the detector should have registered if it were
;                 ideal for the purposes of performing in-flight calibration.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               lbw_eldf.pro
;               lbw_el_response.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT         :  Scalar [structure] associated with a known Wind/3DP
;                               EESA Low data structure
;                               [see get_?.pro, ? = el or elb]
;
;  EXAMPLES:    
;               [calling sequence]
;               cor_cnts = lbw_eesal_counts(dat [,/SET] [,ENERGY=energy] [,PARAMETERS=param] )
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               SET         :  If set, structure tags within DAT will be altered on output
;                                [Default = FALSE]
;               PARAMETERS  :   Scalar [structure] containing relevant information
;                                necessary for routine to compute the corrected counts
;                                [Default = routine defines structure (preferred)]
;               **********************************
;               ***       DIRECT OUTPUTS       ***
;               **********************************
;               ENERGY      :  Set to a named variable to return the energy values used
;                                for the calibration of the instrument
;               PARAMETERS  :  Set to a named variable to return the structure containing
;                                the relevant information necessary for routine to
;                                compute the corrected counts
;
;   CHANGED:  1)  Routine last modified by ??
;                                                                   [??/??/????   v1.0.0]
;             2)  Routine updated and renamed from eesal_counts.pro to lbw_eesal_counts.pro
;                   and now does all computations in double-precision
;                                                                   [03/04/2019   v1.0.1]
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
;   ADAPTED FROM: eesal_counts.pro    BY: Davin Larson
;   CREATED:  03/04/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/04/2019   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_eesal_counts,dat,SET=set,ENERGY=energy,PARAMETERS=param

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;  Define speed of light in km/s
c2             = c[0]^2
ckm            = c[0]*1d-3                ;;  m --> km
ckm2           = ckm[0]^2                 ;;  (km/s)^2
;;  Electromagnetic
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;;  Atomic
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
me_eV          = me[0]*c2[0]/qq[0]        ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c2[0]/qq[0]        ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
ma_eV          = ma[0]*c2[0]/qq[0]        ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
;;  Convert mass to units of energy per c^2 [eV km^(-2) s^(2)]
me_esa         = me_eV[0]/ckm2[0]
mp_esa         = mp_eV[0]/ckm2[0]
ma_esa         = ma_eV[0]/ckm2[0]
;;  Instrumental [the following values are from the original routine version]
def_vshift     = 0.31d0
def_dead_t     = 0.6d-6
def_a          = 2d5/me_esa[0]^2d0
;;  Instrumental [the following values are from the instrument paper]
esa_r1         = 3.75d0                 ;;  R_1 [cm]
dr_2_r1        = 0.075d0                ;;  ∆R/R_1 [N/A]
dr_21          = esa_r1[0]*dr_2_r1      ;;  ∆R ~ 0.28125 cm
esa_r2         = dr_21[0] + esa_r1[0]   ;;  R_2 ~ 4.03125 cm
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check PARAMETERS
IF NOT KEYWORD_SET(param) THEN BEGIN
  IF NOT KEYWORD_SET(model_name) THEN model_name = 'lbw_eldf'
  dummy = CALL_FUNCTION(model_name[0],PARAMETER=mp)
  param = {MODEL_NAME:model_name[0],MP:mp,V_SHIFT:def_vshift[0],DEADTIME:def_dead_t[0],EXPAND:16}
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() EQ 0) THEN RETURN,param
;;  Define some terms
mass           = me_esa[0]
a              = def_a[0]
theta          = 1d0*dat[0].THETA
phi            = 1d0*dat[0].PHI
expand0        = param[0].EXPAND[0]
;;----------------------------------------------------------------------------------------
;;  Check EXPAND
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(expand0) THEN BEGIN
  nn     = dat[0].NENERGY
  nb     = dat[0].NBINS
  ;;  Offset voltages accordingly
  vnew   = dat[0].VOLTS + param[0].V_SHIFT
  nn2    = expand0[0]*nn[0]
  ;;  Calculate instrument response and return proper energy bin values
  resp   = lbw_el_response(vnew,nrg2,NSTEPS=expand0[0]*nn[0])
  i      = REPLICATE(1d0,expand0[0])
  ;;  Expand energy bin values
  energy = nrg2[*] # REPLICATE(1d0,nb[0])
  phi    = REFORM(i # phi[*],nn2[0],nb[0])
  theta  = REFORM(i # theta[*],nn2[0],nb[0])
  ;;  Convolve energy bins with instrument response
  esteps = resp # nrg2
ENDIF ELSE BEGIN
  ;;  No expansion requested --> define VDF energy bins
  energy = dat[0].ENERGY
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Compute VDF given pre-defined parameters
;;----------------------------------------------------------------------------------------
f              = lbw_eldf(energy,theta,phi,PARAMETER=param[0].MP)
;;  Convert to energy flux from phase space density
eflux          = f * energy^2d0 * a[0]
;;  Check if user wants to convolve with instrument response
IF KEYWORD_SET(expand0) THEN BEGIN          ;;  integrate
  eflux  = resp # eflux
  energy = resp # energy
  theta  = resp # theta
  phi    = resp # phi
ENDIF
;;----------------------------------------------------------------------------------------
;;  Convert to proper unit set
;;----------------------------------------------------------------------------------------
units          = dat[0].UNITS_NAME

CASE STRLOWCASE(units[0]) OF
  'df'     :  data = eflux/energy^2d0/a[0]
  'flux'   :  data = eflux/energy
  'eflux'  :  data = eflux
  ELSE     : BEGIN
    ;;  Compute corrected count rate
    crate    =  dat[0].GEOMFACTOR * dat[0].GF * eflux
    ;;  Define the indices for the anodes
    anode    = BYTE((90 - dat[0].THETA)/22.5)
    ;;  Define the deadtimes for each anode
    deadtime = (param[0].DEADTIME[0]/[1.,1.,2.,4.,4.,2.,1.,1.])(anode)
    ;;  Define the raw count rate
    rate     = crate/(1+ deadtime * crate)
    bkgrate  = 0
    str_element,param,'BKGRATE',bkgrate        ;;  get background rate, if present, if not use 0.0
    rate    += bkgrate                         ;;  adjust by background rate
;    rate     = rate + bkgrate                  ;;  adjust by background rate
    CASE STRLOWCASE(units[0]) OF
       'crate'  :  data = crate
       'rate'   :  data = rate
       'counts' :  data = rate * dat[0].DT
    ENDCASE
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Check SET
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(set) THEN BEGIN
  ;;  User wishes to redefine structure tag values
  dat[0].DATA     = FLOAT(data)
  dat[0].ENERGY   = FLOAT(energy)
  dat[0].SC_POT   = FLOAT(param[0].MP.SC_POT[0])
  dat[0].VSW      = FLOAT(param[0].MP.VSW)
  dat[0].MAGF     = FLOAT(param[0].MAGF)
;  dat.e_shift = p.e_shift
;  str_element,/add,dat,'deadtime', deadtime
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check if bins should be on or off
;;----------------------------------------------------------------------------------------
str_element,dat,'BINS',VALUE=bins
IF (N_ELEMENTS(bins) GT 0) THEN BEGIN
  ind  = WHERE(bins)
  IF (ind[0] GE 0) THEN data = data[ind]
;   data = data(ind)
ENDIF ELSE data = REFORM(data,N_ELEMENTS(data),/OVERWRITE)

IF KEYWORD_SET(set) AND KEYWORD_SET(bins) THEN BEGIN
  ;;  Remove "bad" bins
  w = WHERE(bins EQ 0,c)
  IF ((c NE 0) AND (set EQ 2)) THEN dat[0].DATA[w] = !VALUES.F_NAN
;;  Original version has x.DATA but I cannot find the structure x --> assume dat was intended?
;  IF ((c ne 0)  and (set eq 2)) THEN x.data[w] = !values.f_nan
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,data
END









