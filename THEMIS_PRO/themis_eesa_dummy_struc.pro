;+
;*****************************************************************************************
;
;  FUNCTION :   themis_eesa_dummy_struc.pro
;  PURPOSE  :   This routine creates a dummy structure for the THEMIS EESA instrument.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               dat_themis_esa_str_names.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries and UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ;;  To return the default EESA 3D Burst structure with
;               ;;  [32,88]-[Energy,Angle]-bins, for Probe-A, in units of counts,
;               ;;  with the default unit conversion procedure, then enter the
;               ;;  following:
;               dummy = themis_eesa_dummy_struc()
;               ;;  which is equivalent to the following:
;               dummy = themis_eesa_dummy_struc(PROBE='a',INST_MODE='peeb',          $
;                                   UNITS='counts',UNIT_PROC='thm_convert_esa_units',$
;                                   NENER=32,NANGL=88)
;
;  KEYWORDS:    
;               PROBE      :  Scalar [string] defining for which of the five THEMIS
;                               spacecraft with which the return structure will be
;                               associated [Accepts:  'a', 'b', 'c', 'd', or 'e']
;                               [Default : 'a']
;               INST_MODE  :  Scalar [string] defining the mode in which the EESA
;                               instrument structure will be defined
;                               [Default : 'peeb']
;                               Accepted string inputs:
;                                 'pee[f,r,b]'  =  for 'EESA 3D [Full,Reduced,Burst]'
;               UNITS      :  Scalar [string] defining the units for the DATA structure
;                               tag on output
;                               [Default : 'counts']
;                               Accepted string inputs and their definitions:
;                                 'compressed'  =  # of counts
;                                 'counts'      =  # of counts
;                                 'rate'        =  # s^(-1)
;                                 'crate'       =  # s^(-1) [scaled rate]
;                                 'eflux'       =  eV cm^(-2) s^(-1) sr^(-1) eV^(-1)
;                                 'flux'        =  # cm^(-2) s^(-1) sr^(-1) eV^(-1)
;                                 'df'          =  cm^(-3) km^(3) s^(-3)
;               UNIT_PROC  :  Scalar [string] defining the unit conversion routine to
;                               call when converting the units of DATA
;                               [Default : 'thm_convert_esa_units']
;               NENER      :  Scalar [integer] defining the number of energy bins to use
;                               in output data structure arrays
;                               [Default : 32]
;               NANGL      :  Scalar [integer] defining the number of angle bins to use
;                               in output data structure arrays
;                               [Default : 88]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Below are the possible instrument modes for EESA
;                    EESA Burst
;                      nspins        = [1,1,1,1,1,1,1,1]         ;;  # of spins between measurements in mode
;                      nenergy       = [32,32,32,32,32,32,32,32] ;;  # of energies in mode
;                      nangle        = [88,88,88,88,88,88,88,88] ;;  # of angles in mode
;                      dat_len       = nenergy*nangle            ;;  size data arrays
;                      spin_decode   = [1,1,1,1,1,1,1,1]         ;;  # measurements in packet
;                      case_decode   = [0,0,0,0,0,0,0,0]         ;;  datl[16,32,96,192,1152,1200]==>size[0,1,2,3,4,5]
;                      angle_decode  = [0,0,0,0,0,0,0,0]         ;;  angle mode index
;                      energy_decode = [0,1,1,2,2,1,3,3]         ;;  energy mode index
;
;                    EESA Full
;                      nspins        = [3,128,32,128,32,1,128,32] ;;  # of spins between measurements in mode
;                      nenergy       = [32,32,32,32,32,15,32,32]  ;;  # of energies in mode
;                      nangle        = [88,88,88,88,88,88,88,88]  ;;  # of angles in mode
;                      dat_len       = nenergy*nangle             ;;  size data arrays
;                      spin_decode   = [1,1,1,1,1,3,1,1]          ;;  # measurements in packet
;                      case_decode   = [0,0,0,0,0,1,0,0]          ;;  datl[2861,2861,2861,2861,2861,1320]==>size[0,0,0,0,0,1]
;                      angle_decode  = [0,0,0,0,0,1,0,0]          ;;  angle mode index
;                      energy_decode = [0,1,1,2,2,3,4,4]          ;;  energy mode index
;
;                    EESA Reduced
;                      nspins        = [1,1,1,1,1,1,1,1]          ;;  # of spins between measurements in mode
;                      nenergy       = [16,32,32,32,32,32,32,32]  ;;  # of energies in mode
;                      nangle        = [1,1,6,1,6,1,1,6]          ;;  # of angles in mode
;                      dat_len       = nenergy*nangle             ;;  size data arrays
;                      spin_decode   = [160,96,16,96,16,96,96,16] ;;  # measurements in packet
;                      case_decode   = [0,1,3,1,3,1,1,3]          ;;  datl[16,32,96,192]==>size[0,1,2,3]
;                      angle_decode  = [0,1,2,1,2,1,1,2]          ;;  angle mode index
;                      energy_decode = [0,1,1,2,2,1,3,3]          ;;  energy mode index
;
;  REFERENCES:  
;               1)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, (2008).
;               2)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, (2008).
;               3)  Auster, H.U., K.-H. Glassmeier, W. Magnes, O. Aydogar, W. Baumjohann,
;                      D. Constantinescu, D. Fischer, K.H. Fornacon, E. Georgescu,
;                      P. Harvey, O. Hillenmaier, R. Kroth, M. Ludlam, Y. Narita,
;                      R. Nakamura, K. Okrafka, F. Plaschke, I. Richter, H. Schwarzl,
;                      B. Stoll, A. Valavanoglou, and M. Wiedemann "The THEMIS Fluxgate
;                      Magnetometer," Space Sci. Rev. 141, pp. 235-264, (2008).
;               4)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;
;   CREATED:  12/08/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/08/2014   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION themis_eesa_dummy_struc,PROBE=probe0,INST_MODE=inst_mode0,UNITS=units0,$
                                 UNIT_PROC=units_pro0,NENER=n_e0,NANGL=n_a0

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
b1             = 0B
i1             = 0S
f1             = !VALUES.F_NAN
d1             = !VALUES.D_NAN
f3             = REPLICATE(f1[0],3L)
d3             = REPLICATE(d1[0],3L)
;;  Define default values for Probe, Instrument Mode, Units, and Units Procedure
probe          = 'a'
inst_mode      = 'EESA 3D Burst'
units          = 'counts'
units_pro      = 'thm_convert_esa_units'
;;  Define default values for the number of energy and angle bins
N_E            = 32
N_A            = 88
;;  Define arrays of acceptable values
all_probes     = ['a', 'b', 'c', 'd', 'e']
all_imodes     = 'pee'+['f','r','b']
all_units      = ['compressed','counts','rate','crate','eflux','flux','df']
all_nener      = [15,16,32]
all_nangl      = [1,6,88]
all_ntypes     = [1,2,3,4,5,12,13,14,15]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check for PROBE
test           = (SIZE(probe0,/TYPE) EQ 7L)
IF (test) THEN BEGIN
  ;;  Check if input string is an accepted input
  temp = STRLOWCASE(STRMID(STRTRIM(probe0[0],2L),0,1))
  test = TOTAL(temp[0] EQ all_probes) EQ 1
  IF (test) THEN probe = temp[0]
ENDIF
;;  Check for INST_MODE
test           = (SIZE(inst_mode0,/TYPE) EQ 7L)
IF (test) THEN BEGIN
  ;;  Check if input string is an accepted input
  temp = STRLOWCASE(STRTRIM(inst_mode0[0],2L))
  test = (SIZE(dat_themis_esa_str_names(temp[0],/NOM),/TYPE) EQ 8L)
  IF (test) THEN inst_mode = temp[0]
ENDIF
;;  Check for UNITS
test           = (SIZE(units0,/TYPE) EQ 7L)
IF (test) THEN BEGIN
  ;;  Check if input string is an accepted input
  temp = STRLOWCASE(STRTRIM(units0[0],2L))
  test = TOTAL(temp[0] EQ all_units) EQ 1
  IF (test) THEN units = temp[0]
ENDIF
;;  Check for UNIT_PROC
;;    --> Need to assume the user has not entered a bad string
test           = (SIZE(units_pro0,/TYPE) EQ 7L)
IF (test) THEN units_pro = units_pro0[0]
;;  Check for NENER
test           = (N_ELEMENTS(n_e0) GT 0L)
IF (test) THEN BEGIN
  ;;  Check if input has an accepted format
  temp = n_e0[0]
  test = TOTAL(SIZE(temp[0],/TYPE) EQ all_ntypes) EQ 1
  IF (test) THEN N_E = (FIX(temp[0]))[0]
ENDIF
;;  Check for NANGL
test           = (N_ELEMENTS(n_a0) GT 0L)
IF (test) THEN BEGIN
  ;;  Check if input has an accepted format
  temp = n_a0[0]
  test = TOTAL(SIZE(temp[0],/TYPE) EQ all_ntypes) EQ 1
  IF (test) THEN N_A = (FIX(temp[0]))[0]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define output data structure
;;----------------------------------------------------------------------------------------
ExA_iarr       = INTARR(N_E[0],N_A[0])
ExA_farr       = FLTARR(N_E[0],N_A[0])
ExA_darr       = DBLARR(N_E[0],N_A[0])
dat            = {PROJECT_NAME   :      'THEMIS', $
                  SPACECRAFT     :      probe[0], $
                  DATA_NAME      :  inst_mode[0], $
                  APID           :         i1[0], $
                  UNITS_NAME     :      units[0], $
                  UNITS_PROCEDURE:  units_pro[0], $
                  VALID          :         b1[0], $
                  TIME           :         d1[0], $
                  END_TIME       :         d1[0], $
                  DELTA_T        :         d1[0], $
                  INTEG_T        :         d1[0], $
                  DT_ARR         :      ExA_farr, $
                  CONFIG1        :         b1[0], $
                  CONFIG2        :         b1[0], $
                  AN_IND         :         i1[0], $
                  EN_IND         :         i1[0], $
                  MODE           :         i1[0], $
                  NENERGY        :        N_E[0], $
                  ENERGY         :      ExA_farr, $
                  DENERGY        :      ExA_farr, $
                  EFF            :      ExA_darr, $
                  BINS           :      ExA_iarr, $
                  NBINS          :        N_A[0], $
                  THETA          :      ExA_farr, $
                  DTHETA         :      ExA_farr, $
                  PHI            :      ExA_farr, $
                  DPHI           :      ExA_farr, $
                  DOMEGA         :      ExA_farr, $
                  GF             :      ExA_farr, $
                  GEOM_FACTOR    :         f1[0], $
                  DEAD           :         f1[0], $
                  MASS           :         f1[0], $
                  CHARGE         :         f1[0], $
                  SC_POT         :         f1[0], $
                  ECLIPSE_DPHI   :         d1[0], $
                  MAGF           :            d3, $
                  BKG            :      ExA_farr, $
                  DATA           :      ExA_farr, $
                  VELOCITY       :            d3  }
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,dat
END

