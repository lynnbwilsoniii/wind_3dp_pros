;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_photo_eflux.pro
;  PURPOSE  :   Loads and stores in common block the photo electron response specific
;                 to the Wind 3DP electrostatic analyzer EESA Low.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  COMMON BLOCKS:
;               LBW_PHOTO_EFLUX_COM
;
;  CALLS:
;               get_os_slash.pro
;               test_file_path_format.pro
;               is_a_number.pro
;               interp.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  IDL save file of photoelectron energy fluxes, photo_eflux.sav
;
;  INPUT:
;               ENER         :  [N]- or [N,M]-element [numeric] array of energy bin
;                                 values [eV] at which the user wishes to determine the
;                                 associated energy flux of photoelectrons for removal
;                                 from observed distributions
;
;  EXAMPLES:    
;               [calling sequence]
;               eflux_phe = lbw_photo_eflux(ener [,NOEXTRAP_EF=noextrap_ef])
;
;  KEYWORDS:    
;               NOEXTRAP_EF  :  Set to a named variable to return the energy fluxes at
;                                 the associated ENER values but removing any values
;                                 where ENER extended beyond the range of values at which
;                                 the photoelectron energy flux was calculated in the
;                                 IDL save file
;
;   CHANGED:  1)  Routine last modified by ??
;                                                                   [??/??/????   v1.0.0]
;             2)  Routine updated and renamed from photo_eflux.pro to lbw_photo_eflux.pro
;                   and now does all computations in double-precision
;                                                                   [02/19/2020   v1.0.1]
;
;   NOTES:      
;               1)  I honestly do not know from where these fluxes arose, only that
;                     they are used in some of the instrument response calibrartion
;                     routines and cribs I found while digging through the original
;                     software libraries.
;               2)  Energy flux units in the Wind 3DP software are defined as:
;                     eV cm^(-2) s^(-1) sr^(-1) eV^(-1)
;                     or energy per unit area per unit time per unit steradian per unit
;                     energy.
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
;   ADAPTED FROM: photo_eflux.pro    BY: Davin Larson
;   CREATED:  02/19/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/19/2020   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_photo_eflux,ener,NOEXTRAP_EF=noextrap_ef

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define file path
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;  Default IDL save file location
def_savloc     = '.'+slash[0]+'wind_3dp_pros'+slash[0]+'DAVIN_PRO'+slash[0]+$
                 'eesa_low'+slash[0]
;;----------------------------------------------------------------------------------------
;;  Check for directory and file necessary for further steps
;;----------------------------------------------------------------------------------------
;;  Check for !WIND3DP_UMN system variable
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF ~KEYWORD_SET(exists) THEN BEGIN
  ;;  Does not exist --> define manually
  test           = test_file_path_format(def_savloc[0],EXISTS=exists,DIR_OUT=savdir)
ENDIF ELSE BEGIN
  st_dir         = !WIND3DP_UMN.IDL_3DP_LIB_DIR
  test           = test_file_path_format(st_dir[0]+'DAVIN_PRO'+slash[0]+'eesa_low'+slash[0],EXISTS=exists,DIR_OUT=savdir)
ENDELSE
;;   Make sure directory is at least found
IF (savdir[0] EQ '') THEN BEGIN
  ;;  Directory not found --> exit
  errmsg = 'Directory of photoelectron eflux file not found:  Exiting without execution...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check for file now
gfile          = FILE_SEARCH(savdir[0],'photo_eflux.sav')
IF (gfile[0] EQ '') THEN BEGIN
  ;;  Directory not found --> exit
  errmsg = 'Photoelectron eflux file not found:  Exiting without execution...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define common block
;;----------------------------------------------------------------------------------------
COMMON lbw_photo_eflux_com,lg_photo_e,lg_photo_ef
;;----------------------------------------------------------------------------------------
;;  Restore data if natural log of energy fluxes are not already present
;;----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(lg_photo_ef) THEN BEGIN
  RESTORE,FILENAME=gfile[0]
  ;;  Define natural log of output (automatically saves copies to COMMON block)
  lg_photo_e  = ALOG(1d0*photo_e)
  lg_photo_ef = ALOG(1d0*photo_ef)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF ((N_PARAMS() LT 1) OR (is_a_number(ener) EQ 0)) THEN BEGIN
  ;;  Directory not found --> exit
  errmsg = 'User must provide an [N]-element array of energies [eV]:  Exiting without execution...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define energy bin values [eV]
en             = DOUBLE(ener)                      ;;  Force to double-precision
;;----------------------------------------------------------------------------------------
;;  Interpolate to input energy bin values [eV]
;;----------------------------------------------------------------------------------------
;;  Note:  interp.pro can handle 2D input arrays for U and will return array of same dimensions
eflux_at_e     = EXP(interp(lg_photo_ef,lg_photo_e,ALOG(en),/IGNORE_NAN))
noextrap_ef    = EXP(interp(lg_photo_ef,lg_photo_e,ALOG(en),/NO_EXTRAPOLATE,/IGNORE_NAN))
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,eflux_at_e
END
