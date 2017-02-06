;+
;*****************************************************************************************
;
;  FUNCTION :   compute_1c_level.pro
;  PURPOSE  :   This routine computes the one-count level (from 'rate' or 'counts') for
;                 a given input IDL data structure with a format similar to those
;                 associated with Wind/3DP or THEMIS ESA and SST.  The return structure
;                 has the same format as the input but all values in the DATA tag are
;                 re-defined to 1.0 in units of 'rate' or 'counts' (user specified)
;                 prior to converting back to the original input units.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               dat_3dp_str_names.pro
;               dat_themis_esa_str_names.pro
;               struct_value.pro
;               conv_units.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  Scalar [structure] associated with a known THEMIS ESA or
;                               SST data structure
;                               [e.g., see get_th?_p{e,s}*b.pro, ? = a-f]
;                               or a Wind/3DP data structure
;                               [e.g., see get_?.pro, ? = el, elb, pl, ph, eh, etc.].
;                               *********************
;                               ***  Please Read  ***
;                               *********************
;                               Note that so long as the input is a structure and has
;                               the correct tags and a properly defined unit conversion
;                               routine in the UNITS_PROCEDURE tag, this routine should
;                               function correctly.  Note that if the UNITS_PROCEDURE
;                               tag is not present or not defined as scalar string, the
;                               routine will exit without computation.
;
;  EXAMPLES:    
;               [calling sequence]
;               dat_1c = compute_1c_level(dat [,/COUNTS] [,/CRATE] [,/FRAC_CNTS])
;
;  KEYWORDS:    
;               COUNTS     :  If set, routine will define the one-count level in units of
;                               'counts' [see NOTES for unit definitions]
;                               [Default = TRUE]
;               CRATE      :  If set, routine will define the one-count level in units of
;                               'crate' (or 'rate' for THEMIS SST and Wind PESA High)
;                               [see NOTES for unit definitions]
;                               [Default = FALSE]
;               FRAC_CNTS  :  If set, routine will allow for fractional counts to be
;                               used rather than rounded to nearest whole count.
;                               [Default = TRUE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Unit definitions:
;                     'counts'      ;  # of counts
;                     'rate'        ;  raw count rate
;                                      [# s^(-1)]
;                     'crate'       ;  scaled count rate
;                                      [# s^(-1)]
;                     'flux'        ;  corrected # flux (or intensity or fluence)
;                                      [# cm^(-2) s^(-1) sr^(-1) eV^(-1)]
;                     'eflux'       ;  energy flux
;                                      [eV cm^(-2) s^(-1) sr^(-1) eV^(-1)]
;                     'df'          ;  phase space density
;                                      [# cm^(-3) km^(3) s^(-3)]
;
;  REFERENCES:  
;               1)  Carlson et al., (1983), "An instrument for rapidly measuring
;                      plasma distribution functions with high resolution,"
;                      Adv. Space Res. Vol. 2, pp. 67-70.
;               2)  Curtis et al., (1989), "On-board data analysis techniques for
;                      space plasma particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372.
;               3)  Lin et al., (1995), "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125.
;               4)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               5)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, (2008).
;               6)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, (2008).
;               7)  Auster, H.U., K.-H. Glassmeier, W. Magnes, O. Aydogar, W. Baumjohann,
;                      D. Constantinescu, D. Fischer, K.H. Fornacon, E. Georgescu,
;                      P. Harvey, O. Hillenmaier, R. Kroth, M. Ludlam, Y. Narita,
;                      R. Nakamura, K. Okrafka, F. Plaschke, I. Richter, H. Schwarzl,
;                      B. Stoll, A. Valavanoglou, and M. Wiedemann "The THEMIS Fluxgate
;                      Magnetometer," Space Sci. Rev. 141, pp. 235-264, (2008).
;               8)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;               9)  Bordoni, F. "Channel electron multiplier efficiency for 10-1000 eV
;                      electrons," Nucl. Inst. & Meth. 97, pp. 405, (1971).
;              10)  Goruganthu, R.R. and W.G. Wilson "Relative electron detection
;                      efficiency of microchannel plates from 0-3 keV,"
;                      Rev. Sci. Inst. 55, pp. 2030-2033, (1984).
;              11)  Meeks, C. and P.B. Siegel "Dead time correction via the time series,"
;                      Amer. J. Phys. 76, pp. 589-590, (2008).
;              12)  Schecker, J.A., M.M. Schauer, K. Holzscheiter, and M.H. Holzscheiter
;                      "The performance of a microchannel plate at cryogenic temperatures
;                      and in high magnetic fields, and the detection efficiency for
;                      low energy positive hydrogen ions,"
;                      Nucl. Inst. & Meth. in Phys. Res. A 320, pp. 556-561, (1992).
;
;   CREATED:  02/19/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/19/2016   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION compute_1c_level,dat,COUNTS=counts,CRATE=crate,FRAC_CNTS=frac_cnts

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
noinpt_msg     = 'User must supply a velocity distribution function as an IDL structure...'
notstr_msg     = 'DAT must be an IDL structure...'
notvdf_msg     = 'DAT must be a velocity distribution function as an IDL structure...'
badvdf_msg     = 'Input must be an IDL structure with similar format to Wind/3DP or THEMIS/ESA...'
not3dp_msg     = 'Input must be a velocity distribution IDL structure from Wind/3DP...'
notthm_msg     = 'Input must be a velocity distribution IDL structure from THEMIS/ESA...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 1) THEN BEGIN
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (SIZE(dat,/TYPE) NE 8L OR N_ELEMENTS(dat) LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check to make sure distribution has the correct format
test0          = test_wind_vs_themis_esa_struct(dat[0],/NOM)
test           = (test0.(0) + test0.(1)) NE 1
IF (test[0]) THEN BEGIN
  MESSAGE,notvdf_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Determine instrument (i.e., ESA or 3DP) and define electric charge
dat0           = dat[0]
IF (test0.(0)) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Wind
  ;;--------------------------------------------------------------------------------------
  mission      = 'Wind'
  strns        = dat_3dp_str_names(dat0[0])
  IF (SIZE(strns,/TYPE) NE 8) THEN BEGIN
    ;;  Neither Wind/3DP nor THEMIS/ESA VDF
    MESSAGE,not3dp_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0b
  ENDIF
ENDIF ELSE BEGIN
  IF (test0.(1)) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  THEMIS
    ;;------------------------------------------------------------------------------------
    mission      = 'THEMIS'
    strns        = dat_themis_esa_str_names(dat0[0])
    IF (SIZE(strns,/TYPE) NE 8) THEN BEGIN
      ;;  Neither Wind/3DP nor THEMIS/ESA VDF
      MESSAGE,notthm_msg[0],/INFORMATIONAL,/CONTINUE
      RETURN,0b
    ENDIF
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Other mission?
    ;;------------------------------------------------------------------------------------
    ;;  Not handling any other missions yet  [Need to know the format of their distributions]
    MESSAGE,badvdf_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0b
  ENDELSE
ENDELSE
data_str       = strns.SN[0]                           ;;  e.g., 'el' for Wind EESA Low or 'peeb' for THEMIS EESA
sn2char        = STRMID(STRLOWCASE(data_str[0]),0,2)
;;  Check if must use 'rate' instead of 'crate'
rate_on        = 0b              ;;  TRUE --> force units to 'rate'
CASE sn2char[0] OF
  'ph'  :  rate_on = 1b
  'ps'  :  rate_on = 1b
  ELSE  :  ;;  Do nothing
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check COUNTS
test           = KEYWORD_SET(counts) OR (N_ELEMENTS(counts) EQ 0)
IF (test[0]) THEN cnts_on = 1b ELSE cnts_on = 0b
;;  Check CRATE
IF KEYWORD_SET(crate) THEN crate_on = 1b ELSE crate_on = 0b
;;  Check FRAC_CNTS
test           = KEYWORD_SET(frac_cnts) OR (N_ELEMENTS(frac_cnts) EQ 0)
IF (test[0]) THEN fcnts_on = 1b ELSE fcnts_on = 0b
;;----------------------------------------------------------------------------------------
;;  Convert to appropriate "count" unit to use for one-count
;;----------------------------------------------------------------------------------------
;;  Define count-like units to use
IF (crate_on[0]) THEN BEGIN
  ;;  use 'crate' or 'rate'
  IF (rate_on[0]) THEN units_1c = 'rate' ELSE units_1c = 'crate'
ENDIF ELSE BEGIN
  ;;  use 'counts'
  units_1c = 'counts'
ENDELSE
;;  Define old units
old_unit       = struct_value(dat[0],'UNITS_NAME',INDEX=index)
IF (index[0] LT 0) THEN STOP      ;;  should not happen --> debug
;;  Convert to count-like units
dat_1c         = conv_units(dat,units_1c[0],FRACTIONAL_COUNTS=fcnts_on[0])
;;----------------------------------------------------------------------------------------
;;  Redefine DATA tag and return to input units
;;    *** Note:  return to input units may be limited... see unit conversion routines  ***
;;----------------------------------------------------------------------------------------
dat_1c.DATA    = 1e0              ;;  Force all values to 1.0
;;  Convert back to input units
dat_out_1c     = conv_units(dat_1c,old_unit[0],FRACTIONAL_COUNTS=fcnts_on[0])
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,dat_out_1c
END
