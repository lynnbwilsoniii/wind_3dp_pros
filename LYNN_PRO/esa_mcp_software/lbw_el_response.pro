;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_el_response.pro
;  PURPOSE  :   This routine computes the response of the EESA Low electrostatic
;                 analyzer.
;
;  CALLED BY:   
;               
;
;  INCLUDES:
;               NA
;
;  COMMON BLOCKS:
;               LBW_EL_RESPONSE_COM
;
;  CALLS:
;               dgen.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VOLTS      :  [A,E]-Element [numeric] array of voltages [V] at which
;                               to numerically calculate the electron instrument response
;                                 A  :  # of anodes
;                                 E  :  # of energy bins
;               ENERGY     :  [E,S]-Element [numeric] array of energies [eV] at which
;                               to numerically calculate the electron instrument response
;                                 E  :  # of energy bins
;                                 S  :  # of solid angles
;               DENERGY    :  [E,S]-Element [numeric] array of energy bin widths [eV]
;                               at which to numerically calculate the electron
;                               instrument response
;                                 E  :  # of energy bins
;                                 S  :  # of solid angles
;
;  EXAMPLES:    
;               [calling sequence]
;               resp = lbw_el_response(volts, energy, denergy [,NSTEPS=nsteps])
;
;  KEYWORDS:    
;               NSTEPS     :  Scalar [numeric] value defining the number of energy
;                               bins
;
;   CHANGED:  1)  Routine last modified by ??
;                                                                   [??/??/????   v1.0.0]
;             2)  Routine updated and renamed from el_response.pro to lbw_el_response.pro
;                   and now does all computations in double-precision
;                                                                   [02/28/2019   v1.0.1]
;             3)  Continued to update routine and cleaned up a bit
;                                                                   [02/28/2019   v1.0.2]
;             4)  Continued to update routine
;                                                                   [03/01/2019   v1.0.3]
;             5)  Continued to update routine
;                                                                   [03/04/2019   v1.0.4]
;
;   NOTES:      
;               0a)  3DP Notes from Lin et al. [1995]:
;                     --  All MCPs are ~1 mm thick in chevron configuration with a bias
;                           angle of ~8 degrees
;                     --  AMPTEK A111 preamps with 24-bit counters (8C24)
;                     --  energies swept logarithmically and counters sampled 1024/spin
;                         or ~3 ms sample period
;                     --  ~2 MB burst memory
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
;                     --  EH:
;                           R_1    ~ 8.00 cm
;                           ∆R/R_1 ~ 0.075
;                           ∆R     ~ 0.600 cm
;                           R_2    ~ 8.600 cm
;                           <R>    ~ 8.300 cm
;                           R_v    ~ 8.2891566 cm
;                           ∆R_tc  ~ 1.20 cm  [top-cap separation]
;                           GF_op  ~ 0.20*E [cm^(+2) sr]
;                           €_mcp  ~ 70%
;                           T_grid ~ 73%
;                           €_i    ~ 0.1022*E [cm^(+2) sr]
;                           ∆psi   ~ 19 deg
;                           <R>/∆R ~ 13.8333
;                     --  PH:
;                           GF_op  ~ 0.04*E [cm^(+2) sr]
;                           €_mcp  ~ 50%
;                           T_grid ~ 75%
;                           €_i    ~ 0.015*E [cm^(+2) sr]
;                     --  PL:
;                           *** signal attenuated by factor ~50 by a collimator ***
;                           €_i    ~ 0.00016*E [cm^(+2) sr]
;                     --  EL:
;                           *** e- post accelerated by ~500 V to increase efficiency to ~70% ***
;                           €_i    ~ 0.013*E [cm^(+2) sr]
;               0b)  ESA Notes from Carlson et al. [1983]:
;                     --  ESA parameters used in paper
;                           R_1              :  radius of inner hemisphere
;                           V                :  voltage applied to inner hemisphere
;                           R_1 + ∆_1        :  radius of outer hemisphere
;                           R_1 + ∆_1 + ∆_2  :  radius of top-cap section
;                           theta            :  half-angle subtended by small, circular
;                                               hole in outer hemisphere
;                           sigma            :  truncation angle (~83 degrees in example shown)
;                           ∆_2/∆_1          :  optimum if near unity
;                                               *** change of ~50% only changes azumuthal angle response by ~1.5 deg ***
;                           ∆_1/R_1       <-->  <R>/R_1
;                           T_inf/qV      <-->  (E/q)/∆V ~ k/2
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
;               2)  MCP Notes:
;                     --  "MCPs are electron multipliers produced by a voltage bias
;                          across a resistive glass tube that generates an electron
;                          cascade through secondary electron production..."
;                          [Wüest, Evans, and von Steiger, 2007, pgs 18-19, Ch 2]
;                     --  "MCPs consist of an array of microscopic glass tubes (typically
;                          12-25 µm spacing), hexagonally packed...and sliced as thin
;                          wafers (0.5 or 1.0 mm thick) with typical microchannel length
;                          to diameter (L:D) ratios between 40:1 and 80:1..."
;                          [Wüest, Evans, and von Steiger, 2007, pg 19, Ch 2]
;                     --  "MCP wafers (typically 0.5 or 1.0 mm thick) are sliced at a
;                          small bias angle (typically 8-12 deg) relative to the
;                          microchannel axis.  They are stacked in pairs (Chevron
;                          configuration) or in triplets (Z-stack), with adjacent wafers
;                          having opposite bias angles...to prevent ion feedback..."
;                          [Wüest, Evans, and von Steiger, 2007, pg 19, Ch 2]
;                     --  "The bias voltage is generally chosen so the secondary electron
;                          production at the back of the MCP stack is near the
;                          microchannel saturation, resulting in a roughly fixed charge
;                          per microchannel firing..."
;                          [Wüest, Evans, and von Steiger, 2007, pg 19, Ch 2]
;                     --  "Pulse height distributions (PHDs) with a roughly Gaussian
;                          shape and a FWHM equivalent to ∼50–100% of the peak height
;                          are typical, with the FWHM depend- ing upon the MCP gain..."
;                          [Wüest, Evans, and von Steiger, 2007, pg 19, Ch 2]
;                     --  "For high count rates, discrete anodes are preferred since
;                          individual preamps are readily available that count at
;                          ~10^(7) counts per second allowing total instrument rates of
;                          ~10^(8) counts per second."
;                          [Wüest, Evans, and von Steiger, 2007, pgs 21-22, Ch 2]
;                     --  "A general rule of thumb is to try to keep the average charge
;                          pulse current at the highest counting rates (using nominal
;                          gain) to less than 20% of the MCP current."
;                          [Wüest, Evans, and von Steiger, 2007, pg 23, Ch 2]
;               3)  Lead Glass Notes:
;                     --  Corning 8161 Glass [aka Potash Rubium Lead]
;                           rho     :  Density ~ 3.98 ± 0.01 g cm^(-3)
;                           ∑       :  Dielectric Constant ~ 8.3
;                                      UCLA Tech. Rep.:
;                                           ∑    ~ 8.35--8.59
;                                           LF   ~ 0.50--0.76%
;                                           dmax ~ 2.9--3.5
;                           LF x C  :  loss factor (LF) times capacitance ~ 4-5
;                                        [ C ~ ∑ * 0.225/wall thickness ]
;                           Composition (company's results):
;                           PbO     :  51.40%    [lead monoxide]
;                           SiO2    :  38.70%    [silicon dioxide or silica]
;                           K2O     :   6.60%    [potassium oxide or Kalium oxide]
;                           BaO     :   2.00%    [barium oxide]
;                           Sb2O3   :   0.38%    [antimonous oxide]
;                           CaO     :   0.30%    [calcium oxide]
;                           Al2O3   :   0.20%    [aluminum oxide or alumina]
;                           Na2O    :   0.20%    [sodium oxide]
;                           MgO     :   0.04%    [magnesium oxide or magnesia]
;                           As2O3   :   0.04%    [arsenic trioxide]
;                     --  T_c = R_c C_c ~ K d [Ladislas Wiza, 1979]
;                           T_c  :  channel recovery time ~ 10-20 ms per channel
;                           R_c  :  effective single channel resistance ~ 2.75 x 10^(14) Ω
;                           C_c  :  effective single channel capacitance ~ 7.27 x 10^(-17) F
;                           K    :  proportionality constant ~ 4 x 10^(-13)
;                           d    :  channel diameter ~ 10--100 µm
;               4)  Poisson Statistics
;                       P_n    :  the probability to emit n electrons
;                       G_e    :  mean number of emitted electrons = secondary electron yield
;                       n      :  # of emitted electrons
;                       P_n = (G_e^n)/n! e^(-G_e)
;                     Barat et al. [2000] found that G_e depends upon the mass, Mi, and
;                     velocity, Vi, of the incident particle finding:
;                       G_e = Mi^(ß) [Vi - Vo]
;                     where Vo = Vo(Mi) is a constant and they find ß ~ 0.9 for speeds
;                     between ~50-150 km/s for Na and K, where Vo ≤ 40 km/s and
;                     M is some goofy mass unit, e.g., C-60 has M ~ 720u.
;               5)  EESA Low Notes
;                     --  "The Wind 3D Plasma, EESA-L, sensor (180 deg FOV) has experienced
;                          the largest integrated fluxes, with a total count estimated as
;                          of late 2003 to be ∼10^(14) or ∼8 C cm^(−2) of charge extracted
;                          from the device active area."
;                          [Wüest, Evans, and von Steiger, 2007, pg 294, Ch 4]
;                     --  "The EESA-L sensor used MCPs manufactured by Mullard (currently
;                          Photonics) in the form of half-annulus rings L/D = 80 with
;                          resistivities of ~400 MΩ cm^(-2).  Bias voltages were increased
;                          several times during the first two years of operation (from
;                          2.2 kV to 2.4 kV), but no further increases have been required
;                          in recent years.  These MCPs were not scrubbed prior to flight,
;                          so the initial voltage increase was likely necessitated by gain
;                          loss from in-flight scrubbing.  The Wind high voltage supply
;                          currently has an additional 1.2 kV of capability for future
;                          voltage increases."
;                          [Wüest, Evans, and von Steiger, 2007, pg 294, Ch 4]
;                     --  "For example, MCPs produce background counts from radioactive
;                          decay in the glass, edge effects, and through a process called
;                          'after-emission'.  Radioactive decay will contribute a
;                          background rate of ∼0.2–1.0 count s^(-1) cm^(-2) of MCP area.
;                          The edges of MCPs are always a source of noise and care should
;                          be taken to design the MCP mounting so that collection anodes
;                          do not collect charge from within 2 mm of the MCP edge."
;                          [Wüest, Evans, and von Steiger, 2007, pg 308, Ch 4]
;                     --  EL, PL, and PH have
;                           R_1 ~ 3.75 cm and ∆R/R_1 ~ 0.075
;                           -->  ∆R ~ 0.28125 cm
;                           -->  R_2 ~ 4.03125 cm
;                           -->  <R> ~ 3.890625 cm
;                           -->  R_v ~ 3.8855422 cm
;                         EH has
;                           R_1 ~ 8.00 cm and ∆R/R_1 ~ 0.075
;                           -->  ∆R ~ 0.600 cm
;                           -->  R_2 ~ 8.600 cm
;                           -->  <R> ~ 8.300 cm
;                           -->  R_v ~ 8.2891566 cm
;                          [Wüest, Evans, and von Steiger, 2007, pg 349, Ch 4]
;                     --  "The Wind 3D Plasma sensors used AMPTEK A111 preamplifiers that
;                          do not have well defined dead times.  The A111 dead time
;                          depends upon the amplitude of both the initial and trailing
;                          charge pulse, with larger initial pulses requiring longer
;                          recovery times before a second pulse can be registered.  Dead
;                          time correction therefore requires a complex average that
;                          depends upon the MCP pulse height distribution."
;                          [Wüest, Evans, and von Steiger, 2007, pg 350, Ch 4]
;                     --  "The primary EESA-L in-flight calibration effort involved
;                          determining the spacecraft potential and any temperature-
;                          produced offsets in the HV sweep. A sweep mode was operated
;                          several times that allowed the inner hemisphere voltage to be
;                          driven negative.  A dropout in the photo-electron flux
;                          signaled the value where inner hemisphere voltage crossed
;                          through zero, and therefore determined the sweep HV offset.
;                          Since the Wind spacecraft rarely experiences eclipse, its
;                          temperature is stable and the HV offset was assumed constant.
;                          Spacecraft potential determination on Wind was difficult given
;                          no direct measurement from DC electric field probes.  Since the
;                          electron density and temperature both impact the spacecraft
;                          potential, a fitting algorithm was developed that assumed the
;                          measured electrons could be fit to a combination of a drifting
;                          bi-Maxwellian core and suprathermal tail, plus a fixed
;                          photo-electron spectrum. For primarily radial electron
;                          trajectories, the spacecraft potential marks the boundary
;                          between photo-electrons generated from the spacecraft and the
;                          ambient plasma electrons.  The photo-electron spectra were
;                          determined from measurements in the low density magnetotail
;                          lobe regions that extended out to ∼60 eV.  The fitting assumes
;                          the actual finite energy width of measurement bins as
;                          determined from folding the analyzer response with the change
;                          in sweep energy during a counter accumulation.  Using the
;                          actual energy response was critical since the energy
;                          resolution was relatively coarse across the boundary between
;                          photo-electrons and plasma electrons.  The fitting algorithm
;                          is primarily a minimization of the difference between the
;                          measured counts and functional fit with several parameters:
;                          spacecraft potential, Ne, vd, Te//, Te_|_, and optionally a
;                          suprathermal drifting Kappa or bi-Maxwellian.  The fit is
;                          limited to energies below ~3 Te and does not rely on any
;                          other sensor measurements."
;                          [Wüest, Evans, and von Steiger, 2007, pg 353, Ch 4]
;                     --  Space Physics Terms, Appendix A.7.2 of Wüest, Evans, and
;                          von Steiger [2007], pg. 535 [and Table A.40 on pgs 536--537]
;                            j       :  spin step/index
;                            i       :  energy step/index
;                            €_i     :  efficiency at energy step/index i
;                            G_ij    :  geometric factor [cm^(2) sr] at energy i, angle j
;                            E_i     :  center energy [eV] at step/index i
;                            ∆E_i    :  energy passband [eV] of analyzer at E_i
;                            t_ji    :  accumulation time [s] at energy i, angle j
;                            c_ji    :  raw counts [#] at energy i, angle j
;                            r_ji    :  uncorrected counts per accumulation period [#/s]
;                                       = c_ji/t_ji
;                            R_ji    :  corrected counts per accumulation period [#/s]
;                                       = r_ji/€_i
;                            C_ji    :  counts per unit time [#/s]
;                                       = R_ji/∆t
;                            J*_ji   :  modified number flux [# cm^(-2) s^(-1) sr^(-1)]
;                                       = C_ji/G_ji
;                            j_ji    :  differential-directional number flux [# cm^(-2) s^(-1) sr^(-1) eV^(-1)]
;                                       = J*_ji/∆E_i { = 2 M^(-2) E_i f_ji ~ v^(+2) M^(-1) f_ji }
;                            J_ji    :  directional number flux [# cm^(-2) s^(-1) sr^(-1)]
;                                       = J*_ji/(∆E_i/E_i) { d/dE (J_ji) = j_ji }
;                            f_ji    :  velocity distribution function [# cm^(-3) km^(-3) s^(+3)]
;                                       = M^(+2)/2 J_ji E_i^(-2)
;                            e_ji    :  differential-directional energy flux [eV cm^(-2) s^(-1) sr^(-1) eV^(-1)]
;                                       = E_i j_ji
;                            F_ji    :  number flux density [# cm^(-2) s^(-1)]
;                                       = ∫∫ j_ji dE dΩ
;                            GF_ji   :  energy-dependent geometric factor [cm^(+2) sr eV]
;                                       = (count rate)/J_ji
;                            €_ji    :  sensor efficiency [N/A]
;                                       = (sensor count rate)/(incident count rate)
;               6)  Units Notes
;                     1 Pa   = 10^(-2)  mbar = 9.87 x 10^(-6)  atm = 7.5 x 10^(-3)  Torr = 1.45 x 10^(-4)  psi
;                     1 nPa  = 10^(-11) mbar = 9.87 x 10^(-15) atm = 7.5 x 10^(-12) Torr = 1.45 x 10^(-13) psi
;                     1 Torr = 1 mm Hg = 1.33 mbar = 1.316 x 10^(-3)  atm = 1.934 x 10^(-2)  psi
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
;              13)  G.A. Collinson and D.O. Kataria "On variable geometric factor systems
;                      for top-hat electrostatic space plasma analyzers,"
;                      Meas. Sci. Technol. Vol. 21(10), pp. 105903,
;                      doi:10.1088/0957-0233/21/10/105903, 2010.
;
;   ADAPTED FROM: el_response.pro    BY: Davin Larson
;   CREATED:  02/28/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/01/2019   v1.0.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_el_response,volts,energy,denergy,NSTEPS=nsteps

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
;;  Instrumental [the following values are from the original routine version]
k_an           = 6.42d0                 ;;  ESA instrument analyzer constant (energy [eV] per volt)
fwhm           = 0.22d0                 ;;  Full Width at Half Maximum (correction?) [FWHM]
;;  Instrumental [the following values are from the instrument paper]
esa_r1         = 3.75d0                 ;;  R_1 [cm]
dr_2_r1        = 0.075d0                ;;  ∆R/R_1 [N/A]
dr_21          = esa_r1[0]*dr_2_r1      ;;  ∆R ~ 0.28125 cm
esa_r2         = dr_21[0] + esa_r1[0]   ;;  R_2 ~ 4.03125 cm
;;  Given the parameters from Lin et al. [1995] and the definition that k = <R>/∆R
;;    my estimate gives k ~ 13.833 for <R> ~ 3.890625 cm and ∆R ~ 0.28125 cm.  Suppose I
;;    divide this in two which will give k/2 ~ 6.91667.  Note also that the following
;;    is given as:  [2 (2 ln 2)^(1/2)]^(-1) ~ 0.4246609 and (2 ln 2)^(-1/2) ~ 0.8493218.
;;
;;  Using the following formula:  k = E_o/(q V)
;;    from Collinson and Kataria [2010], where E_o is the peak of the accepted energy
;;    bandpass, q is the particle charge, and V is the voltage applied to the inner
;;    hemisphere I find the following values by using:
;;      E_o   -->  dat[0].ENERGY
;;      V     -->  dat[0].VOLTS
;;    5.3501 ≤ k ≤ 8.1509 with Mean(k) ~ 6.609 and Median(k) ~ 6.542 and StdDev(k) ~ 0.584.
;;    If we look at the range of average and median values for the anodes, we find:
;;    5.5838 ≤   Mean(k's) ≤ 7.7266, MEAN(  Mean(k's)) ~ 6.61997, MEDIAN(  Mean(k's)) ~ 6.75626
;;    5.4292 ≤ Median(k's) ≤ 7.9349, MEAN(Median(k's)) ~ 6.63831, MEDIAN(Median(k's)) ~ 6.79239
;;
;;    The above computations were for the example EESA Low VDF 1999-10-21/01:28:05.594 UTC

;;----------------------------------------------------------------------------------------
;;  Define common block
;;----------------------------------------------------------------------------------------
COMMON lbw_el_response_com,resp0,volts0,energy0,denergy0,nsteps0
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NSTEPS0
IF KEYWORD_SET(nsteps0) THEN BEGIN
  IF (nsteps EQ nsteps0 AND TOTAL(volts ne volts0) EQ 0) THEN BEGIN
    ;;  Data was already computed for this set of voltages
    ;;    --> Redefine inputs and return
    energy  = energy0
    denergy = denergy0
    RETURN,resp0
  ENDIF
ENDIF
MESSAGE,/INFORMATIONAL,'Computing instrument response.'
;;  Check NSTEPS
IF KEYWORD_SET(nsteps) THEN BEGIN
  ;;  Define energies and energy bin widths
  v_ran   = [MIN(volts,/NAN),MAX(volts,/NAN)]
  erange  = k_an[0]*v_ran*([1d0 - fwhm[0],1d0 + fwhm[0]])^2d0
  energy  = dgen(nsteps,/LOG,RANGE=erange)
  i       = LINDGEN(nsteps)
  denergy = ABS(energy[i + 1L] - energy[i - 1L])/2d0
ENDIF
nn             = N_ELEMENTS(energy)       ;;  # of energy bins
nv             = N_ELEMENTS(volts)        ;;  # of voltages
dim            = SIZE(volts,/DIMENSIONS)
;;----------------------------------------------------------------------------------------
;;  Correct for analyzer constant
;;----------------------------------------------------------------------------------------
;;  Correct voltages by instrument constant
es             = REPLICATE(1.,nv[0]) # energy
kvs            = REFORM(k_an[0]*volts,nv[0]) # REPLICATE(1.,nn[0])
;;  Calculate variance of Gaussian
;;    FWHM = 2 (ln|2|)^(1/2) V_th
sig            = fwhm[0]/(2d0*SQRT(2d0*ALOG(2d0))) * kvs
;;----------------------------------------------------------------------------------------
;;  Compute instrument response
;;----------------------------------------------------------------------------------------
;;  Compute initial response
resp           = EXP(-((es - kvs)/sig)^2d0/2d0) / SQRT(2d0*!DPI)/sig
;;  Finalize response
resp          *= (REPLICATE(1.,nv[0]) # denergy)
;;  Check if response needs to be resized and summed
IF (N_ELEMENTS(dim) EQ 2) THEN BEGIN
  ;;  Resize array
  resp        = REFORM(resp,dim[0],dim[1],nn[0])
  ;;  Sum over 1st dimension (should be the anodes)
  resp        = TOTAL(resp,1,/NAN)/dim[0]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Redefine common block variables
;;----------------------------------------------------------------------------------------
volts0         = volts
resp0          = resp
energy0        = energy
denergy0       = denergy
nsteps0        = nsteps
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,resp
END



;plot,energy,resp(14,*),/xl
;for i=0,dimen1(resp)-1 do oplot,energy,resp(i,*)

