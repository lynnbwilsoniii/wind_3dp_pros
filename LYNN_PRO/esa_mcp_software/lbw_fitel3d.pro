;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_fitel3d.pro
;  PURPOSE  :   This is a wrapping routine for lbw_fit_el_for_response.pro and fit.pro
;                 to determine the electron velocity distribution function (VDF)
;                 fit parameters and then back out the necessary response required
;                 to get those values.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               str_element.pro
;               lbw_fit_el_for_response.pro
;               xlim.pro
;               units.pro
;               ylim.pro
;               options.pro
;               fill_nan.pro
;               conv_units.pro
;               fit.pro
;               array_union.pro
;               get_plot_state.pro
;               xyz_to_polar.pro
;               pangle.pro
;               zlim.pro
;               bytescale.pro
;               specplot.pro
;               lbw_spec3d.pro
;               get_1d_cut_from_2d_model_vdf.pro
;               restore_plot_state.pro
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
;               fit_str = lbw_fitel3d(dat [,OPTIONS=opts] [,GUESS=guess] [,FDAT=fdat]      $
;                                         [,NO_FIT=no_fit] [,XCHI=chi] [,FITRESULT=fitres] $
;                                         [,VERBOSE=verbose])
;
;  KEYWORDS:    
;               OPTIONS     :  Plot limits structure used for plotting data
;               GUESS       :  Scalar [structure] containing initial guess parameters
;                                with format of structure returned by the routine
;                                lbw_fit_el_for_response.pro
;               FDAT        :  Set to a named variable to return the altered version
;                                of DAT returned by lbw_fit_el_for_response.pro with
;                                the SET keyword set
;               NO_FIT      :  If set, routine will not call fit.pro
;               XCHI        :  Set to a named variable to return the array of chi values
;               FITRESULT   :  Set to a named variable to return the structure containing
;                                the fit results
;               VERBOSE     :  If set, informational output printed by fit.pro is suppressed
;
;   CHANGED:  1)  Routine last modified by ??
;                                                                   [??/??/????   v1.0.0]
;             2)  Routine updated and renamed from fitel3d.pro to lbw_fitel3d.pro
;                   and now does all computations in double-precision
;                                                                   [02/20/2020   v1.0.1]
;             3)  Now calls lbw_spec3d.pro instead of spec3d.pro and
;                   get_1d_cut_from_2d_model_vdf.pro
;                                                                   [02/21/2020   v1.0.2]
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
;   ADAPTED FROM: fitel3d.pro    BY: Davin Larson
;   CREATED:  02/20/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/21/2020   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_fitel3d,dat,OPTIONS=opts,GUESS=guess,FDAT=fdat,NO_FIT=no_fit,XCHI=chi, $
                         FITRESULT=fitres,VERBOSE=verbose

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
nan            = f[0]
chi2           = nan[0]
allnames       = ['CORE.N', 'CORE.T', 'CORE.TDIF', 'CORE.V', 'HALO.N', 'HALO.VTH', 'HALO.K', 'HALO.V', 'SC_POT', 'VSW[0]', 'VSW[1]', 'VSW[2]']
;;----------------------------------------------------------------------------------------
;;  Initialize relevant stuff
;;----------------------------------------------------------------------------------------
fname          = 'lbw_fit_el_for_response'
pnames         = 'core.n core.t core.tdif core.v halo.n halo.vth halo.k halo.v'
;pnames         = 'core.t core.tdif sc_pot halo.n halo.vth halo.v'
;pnames         = 'core.t core.tdif sc_pot halo vsw' ;halo.n halo.vth halo.v'
str_element,opts,'NAMES',pnames
;;  Initialize PARAMETERS structure with GUESS
dummy          = CALL_FUNCTION(fname[0],PARAMETERS=guess)
fitres         = {NITS:0,X2:REPLICATE(nan[0],15),ERANGE:[nan[0],nan[0]],VFLAGS:0L,CHI2:nan[0]}
;;----------------------------------------------------------------------------------------
;;  Check OPTIONS structure
;;----------------------------------------------------------------------------------------
IF (SIZE(opts,/TYPE) NE 8) THEN BEGIN
  ;;  Initialize LIM structure --> {XRANGE:[4e0,2e3],XSTYLE:1,XLOG:1}
  xlim,lim,4,2000,1
  ;;  Add UNITS tag to LIM with value of 'EFLUX'
  units,lim,'eflux'
  ;;  Add Y-Axis stuff --> {YRANGE:[1e4,3e9],YSTYLE:1,YLOG:1}
  ylim,lim,1e4,3e9,1
  ;;  Initialize ALIM structure --> {UNITS:'df'}
  units,alim,'df'
  ;;  Add Y-Axis stuff --> {YRANGE:[1e-18,1e-7],YSTYLE:1,YLOG:1}
  ylim,alim,1e-18,1e-7,1
  ;;  Add PSYM stuff --> {PSYM:2}
  options,alim,'PSYM',1
  ;;  Add A_COLOR stuff --> {A_COLOR:'sundir'}
  options,lim,'A_COLOR' ,'sundir'
  ;;  Add A_COLOR and COLORS stuff --> {A_COLOR:'phi',COLORS:'mbcgyr'}
  options,alim,'A_COLOR','phi'
  options,alim,'COLORS' ,'mbcgyr'
  ;;  Setup bins
  bins2          = BYTARR(15,88)
  bins2[*,[0,1,4,5,22,23,26,27,44,45,48,49,66,67,70,71]] = 1b
  ;;  Add BINS to LIM and ALIM structures
  options, lim,'BINS',bins2
  options,alim,'BINS',bins2
  ;;  Define default OPTIONS structure
  opts           = {EMIN:0.,EMAX:3000.,DFMIN:0.,NAMES:pnames,BINS:REPLICATE(1b,15,88), $
                    DISPLAY:1,DO_FIT:1,LIMITS:lim,ALIMITS:alim }
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(dat) THEN RETURN,guess
IF (dat[0].VALID EQ 0) THEN RETURN,fill_nan(guess)
;;  Get stuff from OPTIONS structure
emin           = 0e0
emax           = 3e3
str_element,opts,'EMIN',emin
str_element,opts,'EMAX',emax
str_element,opts,'BINS',bins
dat.BINS       = 1              ;;  Turn on all energy-angle bins
;;  Check BINS
IF KEYWORD_SET(bins) THEN dat[0].BINS = bins
;;  Check ENERGY values against Emin and Emax
w              = WHERE(dat[0].ENERGY LT emin[0],c)
IF (c[0] NE 0) THEN dat[0].BINS[w] = 0
w              = WHERE(dat[0].ENERGY GT emax[0],c)
IF (c[0] NE 0) THEN dat[0].BINS[w] = 0
;;  Get stuff from OPTIONS structure
str_element,opts,'DFMIN',dfmin
IF KEYWORD_SET(dfmin) THEN BEGIN
  ;;  Remove data below user-defined DFMIN
  df             = conv_units(dat,'df')
  w              = WHERE(df[0].DATA LT dfmin[0],c)
  IF (c[0] NE 0) THEN dat[0].BINS[w] = 0
ENDIF
bon            = WHERE(dat[0].BINS,bbo)
IF (bbo[0] EQ 0) THEN STOP         ;;  No BINS are on... debug
;;  Get stuff from OPTIONS structure
str_element,opts,'DISPLAY',display
str_element,opts, 'LIMITS',lim
str_element,opts,'ALIMITS',alim
;;----------------------------------------------------------------------------------------
;;  Calculate uncertainties in data
;;----------------------------------------------------------------------------------------
;;  ∂c = [ (c/20)^2 + (c + 2) ]^(1/2)
dat[0].DDATA   = SQRT((0.05*dat[0].DATA)^2e0 + (dat[0].DATA + 2e0))
;;  Define counts and dcounts arrays
cnts           =  dat[0].DATA[bon]
dcnts          = dat[0].DDATA[bon]
wghts          = 1d0/dcnts^2d0
bad            = WHERE(dcnts LE 3d0,bd)
IF (bd[0] GT 0) THEN wghts[bad] = 0d0
;;----------------------------------------------------------------------------------------
;;  Initialize fit stuff
;;----------------------------------------------------------------------------------------
fitr           = guess
fitr.MAGF      = dat[0].MAGF
dummy          = CALL_FUNCTION(fname[0],PARAMETERS=fitr)
IF (opts.DO_FIT AND NOT KEYWORD_SET(no_fit)) THEN BEGIN
  ;;  Call fit wrapper
  fit,dat,cnts,WEIGHT=wghts,FUNCTION_NAME=fname,NAMES=pnames,PARAMETERS=fitr,CHI2=chi2,$
               MAXPRINT=12,FULLNAMES=fullnames,ITER=iter,ITMAX=30,P_VALUES=p_values,   $
               P_SIGMA=p_sigma,FITVALUES=fitvals,QFLAG=qflag,SILENT=(KEYWORD_SET(verbose) EQ 0)
  IF (qflag[0] NE 0 OR FINITE(chi2) EQ 0) THEN BEGIN
    ;;  Fit failed --> Try to fit core and halo separately
    fitrc          = guess
    fitrc.MAGF     = dat[0].MAGF
    fitrh          = fitrc
    optsc          = opts
    optsh          = opts
    eran_c         = [0e0,50e0]
    eran_h         = [51e0,emax[0]]
    pnamec         = 'core.n core.t core.tdif core.v'
    pnameh         = 'halo.n halo.vth halo.k halo.v'
    str_element,optsc,'NAMES',pnamec[0],/ADD_REPLACE
    str_element,optsh,'NAMES',pnameh[0],/ADD_REPLACE
    str_element,optsc,'EMIN',eran_c[0],/ADD_REPLACE
    str_element,optsh,'EMIN',eran_h[0],/ADD_REPLACE
    str_element,optsc,'EMAX',eran_c[1],/ADD_REPLACE
    str_element,optsh,'EMAX',eran_h[1],/ADD_REPLACE
    ;;  Call fit wrapper
    fit,dat,cnts,WEIGHT=wghts,FUNCTION_NAME=fname,NAMES=pnamec,PARAMETERS=fitrc,CHI2=chi2c,$
                 MAXPRINT=12,FULLNAMES=fullnamesc,ITER=iterc,ITMAX=30,P_VALUES=p_valuec,   $
                 P_SIGMA=p_sigmc,FITVALUES=fitvalc,QFLAG=qflagc,SILENT=(KEYWORD_SET(verbose) EQ 0)
    IF (qflagc[0] EQ 0) THEN fitrh.CORE = fitrc.CORE  ;;  Success --> add new results to fith structure
    fit,dat,cnts,WEIGHT=wghts,FUNCTION_NAME=fname,NAMES=pnameh,PARAMETERS=fitrh,CHI2=chi2h,$
                 MAXPRINT=12,FULLNAMES=fullnamesh,ITER=iterh,ITMAX=30,P_VALUES=p_valueh,   $
                 P_SIGMA=p_sigmh,FITVALUES=fitvalh,QFLAG=qflagh,SILENT=(KEYWORD_SET(verbose) EQ 0)
    IF ((qflagc[0] NE 0 OR FINITE(chi2c) EQ 0) AND (qflagh[0] NE 0 OR FINITE(chi2h) EQ 0)) THEN BEGIN
      ;;  Both failed --> Quit
      MESSAGE,'Failed:  Total and Core+Halo separate fits...',/INFORMATIONAL,/CONTINUE
      RETURN,0b
    ENDIF ELSE BEGIN
      IF (qflagc[0] EQ 0 AND qflagh[0] EQ 0) THEN BEGIN
        ;;  Both succeeded --> use results
        fitr.CORE = fitrc.CORE
        fitr.HALO = fitrh.HALO
        chi2      = (chi2c[0] + chi2h[0])/2d0   ;;  kludge
        iter      = iterc[0] + iterh[0]         ;;  kludge
        emin      = MIN([eran_c,eran_h])
        emax      = MAX([eran_c,eran_h])
        fullnames = [fullnamesc,fullnamesh]
        qflag     = 0
      ENDIF ELSE BEGIN
        ;;  At least one succeeded --> use results
        IF (qflagc[0] NE 0 OR FINITE(chi2c) EQ 0) THEN BEGIN
          ;;  Halo Wins!
          fitr.HALO = fitrh.HALO
          temp      = fill_nan(fitrc.CORE)
          fitr.CORE = temp
          chi2      = chi2h[0]
          iter      = iterh[0]
          emin      = eran_h[0]
          emax      = eran_h[1]
          fullnames = fullnamesh
          qflag     = qflagh[0]
        ENDIF ELSE BEGIN
          ;;  Core Wins!
          fitr.CORE = fitrc.CORE
          temp      = fill_nan(fitrh.HALO)
          fitr.HALO = temp
          chi2      = chi2c[0]
          iter      = iterc[0]
          emin      = eran_c[0]
          emax      = eran_c[1]
          fullnames = fullnamesc
          qflag     = qflagc[0]
        ENDELSE
      ENDELSE
    ENDELSE
;    STOP    ;;  Check output...
  ENDIF
;  fit,dat,cnts,DY=dcnts,FUNCTION_NAME=fname,NAMES=pnames,PARAMETERS=fitr,CHI2=chi2,MAXPRINT=12,FULLNAMES=fullnames,ITER=iter,SILENT=(KEYWORD_SET(verbose) EQ 0)
ENDIF
IF (SIZE(fitres,/TYPE) NE 8) THEN STOP  ;;  Must be a structure to continue... debug
;;  Define tags within fit results structure
fitres.CHI2    = chi2[0]
fitres.NITS    = iter[0]
fitres.ERANGE  = [emin[0],emax[0]]
flags          = (array_union(allnames,fullnames) GE 0)
fitres.VFLAGS  = TOTAL( ISHFT( LONG(flags) , INDGEN( N_ELEMENTS(flags) ) ) )
;;  Set more values
dat[0].SC_POT  = fitr[0].SC_POT[0]
fdat           = dat[0]
dummy          = CALL_FUNCTION(fname[0],fdat,PARAMETERS=fitr,/SET) 
;;  Define chi-squared value
chi            = (dat[0].DATA - fdat[0].DATA)/dat[0].DDATA
fitres.X2      = MEAN(chi^2e0,DIMENSION=2)
;;----------------------------------------------------------------------------------------
;;  Check DISPLAY
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(display) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Need to open windows
  ;;--------------------------------------------------------------------------------------
  DEVICE,GET_SCREEN_SIZE=s_size
  wsz            = MIN(s_size)*7d-1
  win_ttl        = 'EESA Response Function Plots 5'
  win_str        = {RETAIN:2,XSIZE:wsz[0],YSIZE:wsz[0],TITLE:win_ttl[0],XPOS:10,YPOS:10}
  WINDOW,5,_EXTRA=win_str
  win_ttl        = 'EESA Response Function Plots 6'
  win_str        = {RETAIN:2,XSIZE:wsz[0],YSIZE:wsz[0],TITLE:win_ttl[0],XPOS:10,YPOS:10}
  WINDOW,6,_EXTRA=win_str
  win_ttl        = 'EESA Response Function Plots 7'
  win_str        = {RETAIN:2,XSIZE:wsz[0],YSIZE:wsz[0],TITLE:win_ttl[0],XPOS:10,YPOS:10}
  WINDOW,7,_EXTRA=win_str
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate residual and show
  ;;--------------------------------------------------------------------------------------
  z2             = ALOG10(dat[0].DATA/fdat[0].DATA)
  plt            = get_plot_state()
  pang           = 1
  sundir         = 1
  str_element,lim2,'PITCHANGLE',pang
  str_element,lim2,    'SUNDIR',sundir
  IF KEYWORD_SET(pang)   THEN str_element,dat,'MAGF',vec
  IF KEYWORD_SET(sundir) THEN vec = [-1e0,0e0,0e0]
  IF KEYWORD_SET(vec) THEN BEGIN
    phi            = MEAN(dat[0].PHI,DIMENSION=1,/NAN)
    theta          = MEAN(dat[0].THETA,DIMENSION=1,/NAN)
    xyz_to_polar,vec,theta=bth,phi=bph
    p              = pangle(theta,phi,bth,bph)
  ENDIF
  WSET,5
  ;;  Add to LIM2 structure
  ylim,lim2,4,2000,1
  xlim,lim2,-1,dat[0].NBINS[0]
  zlim,lim2,-0.5e0,0.5e0
  options,lim2,'NO_INTERP',1             ;;  Shut off interpolation
  options,lim2,  'XMARGIN',[10,10]       ;;  Define X-Margins
  ;;  Define X and Y data
  y2             = dat[0].ENERGY
  x2             = REPLICATE(1e0,dat[0].NENERGY) # INDGEN(dat[0].NBINS[0])
  b2             = dat[0].BINS
  IF KEYWORD_SET(p) THEN BEGIN
    s              = SORT(p)
    y2             = y2[*,s]
    z2             = z2[*,s]
;    x2             = x2[*,s]
    b2             = b2[*,s]
  ENDIF
  x              = MEAN(x2,DIMENSION=1)
  y              = MEAN(y2,DIMENSION=2)
  c              = bytescale(z2,RANGE=[-2,2])
  ;;--------------------------------------------------------------------------------------
  ;;  Plot energy (pitch-angle?) spectra
  ;;--------------------------------------------------------------------------------------
  specplot,FINDGEN(dat[0].NBINS[0]),y,TRANSPOSE(z2),LIMIT=lim2
  w              = WHERE(b2 EQ 0,c)
  IF (c[0] NE 0) THEN OPLOT,x2[w],y2[w],PSYM=7
  fdat[0].DDATA  = 0
  IF KEYWORD_SET(lim) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Plot 1D cuts with SC potential and energy shift overplotted(?)
    ;;------------------------------------------------------------------------------------
    WSET,6
    fdat1          = fdat[0]
    w              = WHERE(dat[0].BINS EQ 0,c)
    over           = 0
    lbw_spec3d,dat,LIMIT=lim,OVERPLOT=over,RM_PHOTO_E=0b
    foo            = lim[0]
    options,foo,'PSYM',-4
    lbw_spec3d,fdat1,LIMIT=foo,OVER=over,RM_PHOTO_E=0b
    hdat           = dat[0]
    hdat[0].DATA   = dat[0].DATA - fdat[0].DATA
    options,foo,'PSYM',-5
    OPLOT,fitr[0].SC_POT[0]*[1,1],1e1^(!Y.CRANGE),COLOR=50
    OPLOT,(fitr[0].SC_POT[0] - fitr[0].E_SHIFT[0])*[1,1],[1e-25,1e25],COLOR=100
    OPLOT,emin[0]*[1,1],1e1^(!Y.CRANGE),COLOR=150
    OPLOT,emax[0]*[1,1],1e1^(!Y.CRANGE),COLOR=150
  ENDIF
  IF KEYWORD_SET(alim) THEN BEGIN
    IF (qflag[0] EQ 0) THEN BEGIN
      ;;  Valid fit --> Get 1D cuts
      parmc          = REPLICATE(0d0,6)
      parmh          = parmc
      vlim           = 2d4
      nv             = 101L
      vpara          = DINDGEN(nv[0])*2d0*vlim[0]/(nv[0] - 1L) - vlim[0]
      vperp          = vpara
      parmc[0]       = fitr[0].CORE[0].N[0]
      parmc[2]       = fitr[0].CORE[0].T[0]
      parmc[1]       = parmc[2]/(1d0 + fitr[0].CORE[0].TDIF[0])
      parmc[3]       = fitr[0].CORE[0].V[0]
      parmc[5]       = 2d0
      parmh[0]       = fitr[0].HALO[0].N[0]
      parmh[3]       = fitr[0].HALO[0].V[0]
      parmh[1:2]     = fitr[0].HALO[0].VTH[0]
      parmh[5]       = fitr[0].HALO[0].K[0]
      check_ch       = [(TOTAL(FINITE(parmc)) EQ 6),(TOTAL(FINITE(parmh)) EQ 6)]
      ;;  Get 1D cuts
      IF (check_ch[0]) THEN f2dc = get_1d_cut_from_2d_model_vdf(vpara,vperp,parmc,/BIMAX,/ISTEMP,/ELECTRONS,PARAC=parac,PERPC=perpc)
      IF (check_ch[1]) THEN f2dh = get_1d_cut_from_2d_model_vdf(vpara,vperp,parmc,/BIKAP,/ELECTRONS,PARAC=parah,PERPC=perph)
    ENDIF
    WSET,7
    avlim          = alim
    xlim,avlim,1e3,2e4,1
    lbw_spec3d,dat,LIMIT=avlim,/VELOCITY
    avlim2          = avlim[0]
    options,alim2,'PSYM',-4
    lbw_spec3d,fdat,LIMIT=avlim2,/OVER,/VELOCITY
    ;;  Oplot cuts
    IF (qflag[0] EQ 0) THEN BEGIN
      IF (check_ch[0]) THEN OPLOT,vpara,parac,COLOR=250,THICK=3,LINESTYLE=2
      IF (check_ch[1]) THEN OPLOT,vpara,parah,COLOR=200,THICK=3,LINESTYLE=2
      IF (check_ch[0] AND check_ch[1]) THEN OPLOT,vpara,lbw__add(parac,parah,/NAN),COLOR=100,THICK=3,LINESTYLE=2
    ENDIF
  ENDIF
  ;;  Return to original plot state
  restore_plot_state,plt
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,fitr
END

















