;+
;*****************************************************************************************
;
;  PROCEDURE:   thm_convert_esa_units_lbwiii.pro
;  PURPOSE  :   Converts the data of THEMIS ESA data structure to the user defined
;                 units.  The input data structure tags DATA, DDATA, and UNITS_NAME are
;                 altered by this routine.
;
;  CALLED BY:   
;               conv_units.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               test_themis_esa_struc_format.pro
;               struct_value.pro
;               dprint.pro
;               time_string.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA               :  [N]-element array of THEMIS ESA data structures
;               UNITS              :  Scalar [string] defining to which the units to
;                                       convert.  The following inputs are allowed:
;                                         'compressed'  ;  # of counts
;                                         'counts'      ;  # of counts
;                                         'rate'        ;  [s^(-1)]
;                                         'crate'       ;  [s^(-1)] scaled rate
;                                         'eflux'       ;  energy flux
;                                         'flux'        ;  number flux
;                                         'df'          ;  phase space density
;
;  EXAMPLES:    
;               thm_convert_esa_units_lbwiii,data,units,SCALE=scale
;
;  KEYWORDS:    
;               SCALE              :  Set to a named variable to return the conversion
;                                       factor array used to scale the data
;               FRACTIONAL_COUNTS  :  If set, routine will allow for fractional counts
;                                       to be used rather than rounded to nearest whole
;                                       count.  This has been defaulted to TRUE to avoid
;                                       rounding errors which results in quantization
;                                       artifacts.
;                                       [Default = TRUE]
;               ZERO_DEAD_TIME     :  If set, routine sets all dead time estimates to
;                                       zero seconds
;                                       [Default = FALSE]
;
;   CHANGED:  1)  Davin Larson created
;                                                                   [??/??/????   v1.0.0]
;             2)  Re-wrote, cleaned up, and vectorized allowing for arrays of input
;                   data structures
;                                                                   [03/13/2012   v1.1.0]
;             3)  Updated man page and fixed dimensional issue with matrix multiplication
;                                                                   [03/14/2012   v1.1.1]
;             4)  Updated to allow for input structures with pre-defined DEADTIME
;                   structure tag values introduced by the routine
;                   themis_esa_pad.pro
;                                                                   [08/15/2012   v1.2.0]
;             5)  Added keyword:  FRACTIONAL_COUNTS
;                                                                   [09/12/2014   v1.3.0]
;             6)  Updated in accordance with latest version of SPEDAS [11-16-2015 build]
;                   - Updated Man. page
;                   - Added ZERO_DEAD_TIME keyword
;                     - Implemented functionality
;                                                                   [11/16/2015   v1.4.0]
;             7)  Fixed an issue that caused rounding errors between the following
;                   two algorithms (and others):
;                     1)  (2e0/mass[0]/mass[0]*1e5)
;                     2)  (2e5/mass[0]^2)
;                                                                   [01/19/2016   v1.5.0]
;             8)  Fixed explanation of FRACTIONAL_COUNTS keyword and cleaned up
;                                                                   [02/19/2016   v1.5.1]
;
;   NOTES:      
;               1)  Original version can be found in the latest SPEDAS release,
;                     called:  thm_convert_esa_units.pro
;                     found at:
;                     http://themis.ssl.berkeley.edu/socware/bleeding_edge/
;               2)  If you wish to calculate the one-count level, then it is wise to
;                     use the FRACTIONAL_COUNTS keyword during that process as the
;                     deadtime correction will cause sub-unity levels to round to zero,
;                     which is useless.
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
;   ADAPTED FROM:  thm_convert_esa_units.pro
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  01/19/2016   v1.5.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO thm_convert_esa_units_lbwiii,data,units,SCALE=scale,FRACTIONAL_COUNTS=fractional_counts,$
                                 ZERO_DEAD_TIME=zero_dead_time

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
notstr_mssg    = 'Must be an IDL structure...'
badstr_themis  = 'Not an appropriate THEMIS ESA structure...'
notstring_msg  = 'UNITS must be a scalar string...'

cc3d           = FINDGEN(256)
;;  so scale gets passed back even if units = data.units_name
scale          = 1d0
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN RETURN
str            = data[0]   ;;  in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8) THEN BEGIN
  MESSAGE,notstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  check to make sure input is a THEMIS ESA structure
test           = test_themis_esa_struc_format(str) NE 1
IF (test[0]) THEN RETURN
;;  check to make sure input is a string
IF (SIZE(units,/TYPE) NE 7) THEN BEGIN
  MESSAGE,notstring_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check to make sure user is actually changing units
old_unit       = data[0].UNITS_NAME
new_unit       = units[0]
IF (STRUPCASE(new_unit[0]) EQ STRUPCASE(old_unit[0])) THEN RETURN
;;----------------------------------------------------------------------------------------
;;  These are vectorized for array of data structures
;;----------------------------------------------------------------------------------------
n_e            = data[0].NENERGY            ;;  Number of energy bins
nbins          = data[0].NBINS              ;;  Number of angle bins
n_str          = N_ELEMENTS(data)           ;;  Number of data structures
energy         = DOUBLE(data.ENERGY)        ;;  [n_e,nbins,n_str]-Element array of energies [eV]
;;  Define the total geometry factor of the detector [cm^2 sr]
gf_facs        = DBLARR(n_e,nbins,n_str)
mass           = DBLARR(n_e,nbins,n_str)    ;; Particle mass [eV/c^2, with c in km/s]
dt             = DBLARR(n_e,nbins,n_str)    ;; total accumulation times [s]
dead0          = struct_value(data[0],'deadtime',INDEX=index)
;;  check for DEADTIME tag
IF (index[0] GE 0) THEN BEGIN
  ;;  Define A121 preamp dead time [s]
  dead  = DOUBLE(data.DEADTIME)
  gdead = 1
ENDIF ELSE BEGIN
  dead  = DBLARR(n_e,nbins,n_str)
  gdead = 0
ENDELSE
;;  Fill arrays
FOR j=0L, n_str - 1L DO BEGIN
  gf_facs[*,*,j] = DOUBLE(data[j].GEOM_FACTOR[0])
  ;;  Define the average time needed for the 1024 counter readouts per spin [s]
  ;;      [= (data.END_TIME - data.TIME)/1024.]
  dt[*,*,j]      = DOUBLE(data[j].INTEG_T[0])
  IF (gdead NE 1) THEN BEGIN
    ;;  Define A121 preamp dead time [s]
    dead[*,*,j]    = DOUBLE(data[j].DEAD[0])
  ENDIF
  ;;  Define Particle mass [eV/(km/sec)^2]
  mass[*,*,j]    = DOUBLE(data[j].MASS[0])
ENDFOR
IF KEYWORD_SET(zero_dead_time) THEN dead = 0d0
gf             = DOUBLE(gf_facs*data.GF*data.EFF)
;;  Define anode accumulation times per bin for rate and dead time corrections
dt_arr         = DOUBLE(data.DT_ARR)
;;----------------------------------------------------------------------------------------
;;  Define scale factors to new units
;;----------------------------------------------------------------------------------------
scale          = 1.
CASE STRUPCASE(old_unit[0]) OF
  'COMPRESSED'  :  sfact = 1d0
  'COUNTS'      :  sfact = 1d0
  'RATE'        :  sfact = 1d0 * dt * dt_arr                      ;;  # s^(-1)
  'CRATE'       :  sfact = 1d0 * dt_arr                           ;;  # s^(-1) [corrected for dead time rate]
  'EFLUX'       :  sfact = 1d0 * gf                               ;;  eV cm^(-2) s^(-1) sr^(-1) eV^(-1)
  'FLUX'        :  sfact = 1d0 * gf * energy                      ;;  # cm^(-2) s^(-1) sr^(-1) eV^(-1)
  'DF'          :  sfact = 1d0 * gf * energy^2d0 * 2d5/mass^2d0   ;;  # cm^(-3) km^(3) s^(-3)
  ELSE          : BEGIN
    MESSAGE,'Undefined units: ',old_unit[0]
    RETURN
  END
ENDCASE
;;  Adjust SCALE by factor associated with input units
scale         *= sfact
;;----------------------------------------------------------------------------------------
;;  Convert to counts
;;----------------------------------------------------------------------------------------
tmp            = DOUBLE(data.DATA)
IF (STRUPCASE(old_unit[0]) EQ 'COMPRESSED') THEN tmp = cc3d[BYTE(tmp)]
;;  Adjust DATA by factor associated with input units
tmp           *= scale
;;----------------------------------------------------------------------------------------
;;  Remove dead time corrections
;;----------------------------------------------------------------------------------------
test           = (STRUPCASE(old_unit[0]) NE 'COUNTS') AND (STRUPCASE(old_unit[0]) NE 'RATE') $
                  AND (STRUPCASE(old_unit[0]) NE 'COMPRESSED')
IF (test[0]) THEN BEGIN
  ;;  changed this to the default because rounding causes quantization artifacts in many cases (interpolation, flux->eflux, etc...) (pcruce 2013-07-25)
  IF (KEYWORD_SET(fractional_counts) OR N_ELEMENTS(fractional_counts) EQ 0) THEN BEGIN
    test = (dt*tmp)/(1d0 + (tmp*dead)/dt_arr)
    tmp  = test
  ENDIF ELSE BEGIN
    test = ROUND( (dt*tmp)/(1d0 + (tmp*dead)/dt_arr) )
    tmp  = test
  ENDELSE
ENDIF
;;  clean memory
test           = 0b
;;----------------------------------------------------------------------------------------
;;  Define scale factors for new units
;;----------------------------------------------------------------------------------------
CASE STRUPCASE(new_unit[0]) OF 
  'COMPRESSED'  :  sfact = 1d0
  'COUNTS'      :  sfact = 1d0
  'RATE'        :  sfact = 1d0 / (dt * dt_arr)
  'CRATE'       :  sfact = 1d0 / (dt * dt_arr)
  'EFLUX'       :  sfact = 1d0 / (dt * gf)
  'FLUX'        :  sfact = 1d0 / (dt * gf * energy)
  'DF'          :  sfact = 1d0 / (dt * gf * energy^2d0 * 2d5/mass^2d0)
  ELSE: BEGIN
    MESSAGE,'Undefined units: ',new_unit[0]
    RETURN
  END
ENDCASE
;;  DEFINE 2nd scale factor associated with new units
scale1         = sfact
;;----------------------------------------------------------------------------------------
;;  Dead time correct data if not counts or rate
;;----------------------------------------------------------------------------------------
test           = (STRUPCASE(new_unit[0]) NE 'COUNTS') AND (STRUPCASE(new_unit[0]) NE 'RATE') $
                  AND (STRUPCASE(new_unit[0]) NE 'COMPRESSED')
IF (test[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Correct for deadtime [so long as input units were not 'counts', 'rate', or 'compressed']
  ;;--------------------------------------------------------------------------------------
  denom = 1d0 - (dead/dt_arr)*(tmp/dt)
  tmp2  = DBLARR(n_e,nbins,n_str)
  FOR j=0L, n_str - 1L DO BEGIN
    void  = WHERE(denom[*,*,j] LT 1d-1,count)
    IF (count GT 0) THEN BEGIN
      dprint,DLEVEL=1,MIN(denom[*,*,j],ind)
      denom[*,*,j] = denom[*,*,j] > .1            ;;  force all to be > 0.1
      ;;  print error messages
      dprint,DLEVEL=1,' Error: convert_peace_units dead time error.'
      dprint,DLEVEL=1,' Dead time correction limited to x10 for ',count,' bins'
      dprint,DLEVEL=1,' Time= ',time_string(data[j].TIME[0],/MSEC)
    ENDIF
  ENDFOR
  ;;  Define new DATA values corrected for deadtimes
  tmp2 = tmp/denom
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Do not correct for dead time
  ;;--------------------------------------------------------------------------------------
  tmp2 = tmp
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Scale to new units
;;----------------------------------------------------------------------------------------
data.UNITS_NAME = units[0]
ddata0         = struct_value(data[0],'ddata',INDEX=index)
IF (index[0] GE 0) THEN data.DDATA = FLOAT(scale1 * tmp2^(1d0/2d0))

IF (STRUPCASE(new_unit[0]) EQ 'COMPRESSED') THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Go to compressed units
  ;;--------------------------------------------------------------------------------------
  ind   = WHERE(tmp2 GE 0.,npts)
  ntmp  = N_ELEMENTS(tmp2)
  IF (npts[0] GT 0) THEN BEGIN
    FOR j=0L, npts[0] - 1L DO BEGIN
      minval       = MIN(ABS(cc3d - tmp2[ind[j]]),jj)
      tmp2[ind[j]] = jj[0]
    ENDFOR
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Check for zeroed elements
  ;;--------------------------------------------------------------------------------------
  IF (npts[0] NE ntmp[0]) THEN BEGIN
    ;;  Set zeroed elements to 255
    tmp3 = INTARR(ntmp)
    IF (npts[0] GT 0) THEN tmp3[ind] = 1
    ind2 = WHERE(tmp3 EQ 0,in2)
    IF (in2[0] GT 0) THEN tmp2[ind2] = 255
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Redefine DATA tag and define output SCALE
;;----------------------------------------------------------------------------------------
data.DATA      = FLOAT(scale1 * tmp2)
scale          = FLOAT(TEMPORARY(scale)*scale1)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
