;+
;*****************************************************************************************
;
;  FUNCTION :   themis__sst_dummy_struc.pro
;  PURPOSE  :   This routine creates a dummy structure for the THEMIS SST instrument.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               dat_themis_esa_str_names.pro
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               dumb_sst = themis__sst_dummy_struc([PROBE=probe] [,INST_MODE=inst_mode]
;                                                  [,UNITS=units] [,UNIT_PROC=units_pro]
;                                                  [,NENER=nener] [,NANGL=nangl])
;
;  KEYWORDS:    
;               PROBE      :  Scalar [string] defining for which of the five THEMIS
;                               spacecraft with which the return structure will be
;                               associated [Accepts:  'a', 'b', 'c', 'd', or 'e']
;                               [Default : 'a']
;               INST_MODE  :  Scalar [string] defining the mode in which the SST
;                               instrument structure will be defined
;                               Accepted string inputs:
;                                 pse[f,r,b]  :  SST Electrons
;                                 psi[f,r,b]  :  SST Ions
;                                 [f,r,b]     :  [Full, Reduced, BURST]
;                               [Default : 'pseb']
;               UNITS      :  Scalar [string] defining the units for the DATA structure
;                               tag on output
;                               Accepted string inputs and their definitions:
;                                 'compressed'  =  # of counts
;                                 'counts'      =  # of counts
;                                 'rate'        =  # s^(-1)
;                                                  [count rate]
;                                 'eflux'       =  eV cm^(-2) s^(-1) sr^(-1) eV^(-1)
;                                                  [energy flux]
;                                 'flux'        =  # cm^(-2) s^(-1) sr^(-1) eV^(-1)
;                                                  [number flux]
;                                 'df'          =  cm^(-3) km^(3) s^(-3)
;                                                  [phase space density]
;                               [Default : 'counts']
;               UNIT_PROC  :  Scalar [string] defining the unit conversion routine to
;                               call when converting the units of DATA
;                               [Default : 'thm_sst_convert_units2']
;               NENER      :  Scalar [integer] defining the number of energy bins to use
;                               in output data structure arrays
;                               [Default : 16]
;               NANGL      :  Scalar [integer] defining the number of angle bins to use
;                               in output data structure arrays
;                               [Default : 64]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See also:  thm_sst_psi[f,r].pro, thm_sst_pse[b,f,r].pro,
;                     thm_sst_atten_scale.pro, thm_sst_dist3d_def2.pro,
;                     thm_sst_dist3d_16x64_2.pro, thm_sst_remove_sunpulse.pro
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
;                      "The THEMIS SST Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, (2008).
;               6)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS SST First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, (2008).
;               7)  Auster, H.U., K.-H. Glassmeier, W. Magnes, O. Aydogar, W. Baumjohann,
;                      D. Constantinescu, D. Fischer, K.H. Fornacon, E. Georgescu,
;                      P. Harvey, O. Hillenmaier, R. Kroth, M. Ludlam, Y. Narita,
;                      R. Nakamura, K. Okrafka, F. Plaschke, I. Richter, H. Schwarzl,
;                      B. Stoll, A. Valavanoglou, and M. Wiedemann "The THEMIS Fluxgate
;                      Magnetometer," Space Sci. Rev. 141, pp. 235-264, (2008).
;               8)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;               9)  Ni, B., Y. Shprits, M. Hartinger, V. Angelopoulos, X. Gu, and
;                      D. Larson "Analysis of radiation belt energetic electron phase
;                      space density using THEMIS SST measurements: Cross‐satellite
;                      calibration and a case study," J. Geophys. Res. 116, A03208,
;                      doi:10.1029/2010JA016104, 2011.
;              10)  Turner, D.L., V. Angelopoulos, Y. Shprits, A. Kellerman, P. Cruce,
;                      and D. Larson "Radial distributions of equatorial phase space
;                      density for outer radiation belt electrons," Geophys. Res. Lett.
;                      39, L09101, doi:10.1029/2012GL051722, 2012.
;
;   CREATED:  11/25/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/25/2015   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION themis__sst_dummy_struc,PROBE=probe0,INST_MODE=inst_mode0,UNITS=units0,$
                                 UNIT_PROC=units_pro0,NENER=n_e0,NANGL=n_a0

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
;;  Constants
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
ckm            = c[0]*1d-3                ;;  m --> km
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
me_eV          = me[0]*c[0]^2/qq[0]       ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c[0]^2/qq[0]       ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;  Dummy variables
b1             = 0b
i1             = 0s
l1             = 0L
f1             = !VALUES.F_NAN
d1             = !VALUES.D_NAN
f3             = REPLICATE(f1[0],3L)
f4             = REPLICATE(f1[0],4L)
d2             = REPLICATE(d1[0],2L)
d3             = REPLICATE(d1[0],3L)
;;  Define default values for Probe, Instrument Mode, Units, and Units Procedure
def_probe      = 'a'
def_inst_mode  = 'SST Electron Burst Distribution'
def_units      = 'counts'
def_units_pro  = 'thm_sst_convert_units2'
;;  Define default values for the number of energy and angle bins
def_n_e        = 16
def_n_a        = 64
;;  Define arrays of acceptable values
all_probes     = ['a', 'b', 'c', 'd', 'e']
all_emodes     = 'pse'+['f','r','b']
all_imodes     = 'psi'+['f','r','b']
all__modes     = [all_emodes,all_imodes]
all_units      = ['compressed','counts','rate','eflux','flux','df']
all_nener      = [16]
all_nangl      = [1,6,64]
all_ntypes     = [1,2,3,4,5,12,13,14,15]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check for PROBE
test           = (SIZE(probe0,/TYPE) EQ 7L)
IF (test[0]) THEN BEGIN
  ;;  Check if input string is an accepted input
  temp = STRLOWCASE(STRMID(STRTRIM(probe0[0],2L),0,1))
  test = TOTAL(temp[0] EQ all_probes) EQ 1
  IF (test[0]) THEN probe = temp[0] ELSE probe = def_probe[0]
ENDIF ELSE probe = def_probe[0]
;;  Check for INST_MODE
test           = (SIZE(inst_mode0,/TYPE) EQ 7L)
IF (test[0]) THEN BEGIN
  ;;  Check if input string is an accepted input
  temp = STRLOWCASE(STRTRIM(inst_mode0[0],2L))
  test = (SIZE(dat_themis_esa_str_names(temp[0],/NOM),/TYPE) EQ 8L)
  IF (test[0]) THEN inst_mode = temp[0] ELSE inst_mode = def_inst_mode[0]
ENDIF ELSE inst_mode = def_inst_mode[0]
;;  Check for UNITS
test           = (SIZE(units0,/TYPE) EQ 7L)
IF (test[0]) THEN BEGIN
  ;;  Check if input string is an accepted input
  temp = STRLOWCASE(STRTRIM(units0[0],2L))
  test = TOTAL(temp[0] EQ all_units) EQ 1
  IF (test[0]) THEN units = temp[0] ELSE units = def_units[0]
ENDIF ELSE units = def_units[0]
;;  Check for UNIT_PROC
test           = (SIZE(units_pro0,/TYPE) EQ 7L)
IF (test[0]) THEN units_pro = units_pro0[0] ELSE units_pro = def_units_pro[0]
;;  Check for NENER
test           = (N_ELEMENTS(n_e0) GT 0L)
IF (test[0]) THEN BEGIN
  ;;  Check if input has an accepted format
  temp = n_e0[0]
  test = is_a_number(temp,/NOMSSG)
  IF (test[0]) THEN n_e = (FIX(temp[0]))[0] ELSE n_e = def_n_e[0]
ENDIF ELSE n_e = def_n_e[0]
;;  Check for NANGL
test           = (N_ELEMENTS(n_a0) GT 0L)
IF (test[0]) THEN BEGIN
  ;;  Check if input has an accepted format
  temp = n_a0[0]
  test = is_a_number(temp,/NOMSSG) AND (TOTAL(temp[0] EQ all_nangl) EQ 1)
  IF (test[0]) THEN n_a = (FIX(temp[0]))[0] ELSE n_a = def_n_a[0]
ENDIF ELSE n_a = def_n_a[0]
;;  Define channel
strns          = dat_themis_esa_str_names(inst_mode[0],/NOM)
shname         = STRMID(strns.SN,0,3)
CASE [0] OF
  'pse'  :  BEGIN
    chan   = 'f_ft'
    charge = -1e0
    mass   = me_eV[0]/ckm[0]^2      ;;  particle mass [eV/c^2, with c in km/s]
  END
  'psi'  :  BEGIN
    chan   = 'o'
    charge =  1e0
    mass   = mp_eV[0]/ckm[0]^2      ;;  particle mass [eV/c^2, with c in km/s]
  END
  ELSE   :  STOP  ;;  How did this happen?
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Define output data structure
;;----------------------------------------------------------------------------------------
ExA_iarr       = INTARR(n_e[0],n_a[0])
ExA_farr       = FLTARR(n_e[0],n_a[0])
ExA_darr       = DBLARR(n_e[0],n_a[0])
f_ne           = REPLICATE(f1[0],n_e[0])
tpn_name       = 'th'+STRLOWCASE(probe[0])+'_'+inst_mode[0]+'_'+STRING(n_a[0],FORMAT='(I3.3)')

dat            = {PROJECT_NAME        :      'THEMIS', $   ;;  Scalar [string] defining the project/mission name (i.e., THEMIS here)
                  SPACECRAFT          :      probe[0], $   ;;  " " individual spacecraft/probe within the project/mission (e.g., 'a' for Probe A)
                  DATA_NAME           :  inst_mode[0], $   ;;  " " short string name that defines the instrument mode (e.g., 'pseb' for SST Electron Burst)
                  UNITS_NAME          :      units[0], $   ;;  " " current units for the values in the DATA array below (e.g., 'counts')
                  UNITS_PROCEDURE     :  units_pro[0], $   ;;  " " routine to use for any type of unit conversion
                  TPLOTNAME           :   tpn_name[0], $   ;;  " " the default TPLOT handle to use
                  TIME                :         d1[0], $   ;;  Scalar [numeric] defining the start time [Unix] of the distribution
                  TRANGE              :            d2, $   ;;  [2]-Element [numeric] array defining the start and end times [Unix] of the distribution (i.e., [TIME,END_TIME])
                  END_TIME            :         d1[0], $   ;;  Scalar [numeric] defining the end time [Unix] of the distribution
                  INDEX               :         l1[0], $   ;;  " " 
                  NBINS               :        n_a[0], $   ;;  " " # of solid angle bins
                  NENERGY             :        n_e[0], $   ;;  " " # of energy bins
                  MAGF                :            d3, $   ;;  [3]-Element [numeric] array defining the average magnetic field vector [nT] at the time of this distribution
                  SC_POT              :         f1[0], $   ;;  Scalar [numeric] defining the spacecraft potential [eV] at the time of this distribution
                  MASS                :       mass[0], $   ;;  " " particle mass [eV/c^2, with c in km/s]
                  CHARGE              :     charge[0], $   ;;  Scalar [numeric] defining the sign of the particle charge
                  VALID               :         i1[0], $   ;;  " " whether the distribution is valid or not (1 = valid, 0 = invalid)
                  APID                :         i1[0], $   ;;  " " the hex code identifier for the instrument mode (e.g., '45a'x = 1114)
                  MODE                :         i1[0], $   ;;  ?
                  CNFG                :         i1[0], $   ;;  ?
                  NSPINS              :         i1[0], $   ;;  ?
                  DATA                :      ExA_farr, $   ;;  [E,A]-Element [numeric] array of data [UNITS_NAME]
                  ENERGY              :      ExA_farr, $   ;;  " " midpoint energies [eV]
                  THETA               :      ExA_farr, $   ;;  " " midpoint elevation (i.e., latitude) angles [deg] from spacecraft spin plane
                  PHI                 :      ExA_farr, $   ;;  " " midpoint rotation (i.e., longitude) angles [deg] within spacecraft spin plane
                  DENERGY             :      ExA_farr, $   ;;  " " change in energy [eV] across each energy/angle bin (i.e., bin start/stop are ENERGY ± DENERGY/2)
                  DTHETA              :      ExA_farr, $   ;;  " " change in THETA [deg] across each energy/angle bin (i.e., " " THETA ± DTHETA/2)
                  DPHI                :      ExA_farr, $   ;;  " " change in PHI [deg] across each energy/angle bin (i.e., " " PHI ± DPHI/2)
                  BINS                :      ExA_iarr, $   ;;  " " defining the bins to use in any subsequent computation/use [unitless]
                  GF                  :      ExA_farr, $   ;;  " " geometric factor correction for each energy/angle bin
                  INTEG_T             :      ExA_farr, $   ;;  " " total intergration time for each energy/angle bin [s]
                  DEADTIME            :      ExA_farr, $   ;;  " " deadtime correction factor for each energy/angle bin
                  GEOM_FACTOR         :         f1[0], $   ;;  Scalar [numeric] defining the nominal (theoretical/optical) geometric factor for all energy/angle bins
                  ECLIPSE_DPHI        :         d1[0], $   ;;  " " angular deviation [deg] between the IDPU's spin model and the sunpulse+fgm spin model
                  ATTEN               :         i1[0], $   ;;  " " whether the attenuator is on or off [direct input for thm_sst_atten_scale.pro]
                  ATT                 :      ExA_farr, $   ;;  [E,A]-Element [numeric] array of attenuation scaling factors [SCALE_FACTORS keyword in thm_sst_atten_scale.pro] --> applied when attenuator is on
                  EFF                 :      ExA_farr, $   ;;  " " efficiencies for each energy bin [unitless]
                  EN_LOW              :          f_ne, $   ;;  [E]-Element [numeric] array of lower energy [keV] boundaries for each bin in this anode
                  EN_HIGH             :          f_ne, $   ;;  " " upper energy [keV] boundaries " "
                  DEAD_LAYER_OFFSETS  :            f4, $   ;;  [4]-Element [numeric] array of dead layer offsets for each look direction
                  CHANNEL             :       chan[0], $   ;;  Scalar [string] defining the instruments used [i.e., 'f','o','t','ft','ot','fto', or 'f_ft' (i.e., f & ft merged)]
                  VELOCITY            :            d3  }   ;;  [3]-Element [numeric] array defining the bulk flow velocity [km/s] at the time of this distribution
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,dat
END
