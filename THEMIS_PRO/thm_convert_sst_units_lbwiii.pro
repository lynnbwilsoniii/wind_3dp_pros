;+
;*****************************************************************************************
;
;  PROCEDURE:   thm_convert_sst_units_lbwiii.pro
;  PURPOSE  :   Converts the data of THEMIS SST data structure to the user defined
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
;               in_set.pro
;               thm_sst_atten_scale.pro
;               thm_part_decomp16.pro
;               dprint.pro
;               time_string.pro
;               struct_value.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP and SPEDAS IDL Libraries
;
;  INPUT:
;               DATA               :  [N]-element array of THEMIS SST data structures
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
;               thm_convert_sst_units_lbwiii,data,units,SCALE=scale
;
;  KEYWORDS:    
;               SCALE              :  Set to a named variable to return the conversion
;                                       factor array used to scale the data
;
;   CHANGED:  1)  Pat Cruce changed something...
;                                                                   [09/06/2013   v1.?.?]
;             2)  Re-wrote, cleaned up, and vectorized allowing for arrays of input
;                   data structures
;                                                                   [11/16/2015   v2.0.0]
;             3)  Fixed a typo in the modified geometry factor calculation
;                                                                   [11/24/2015   v2.0.1]
;             4)  Fixed bug in unit conversion when input units are not counts, rate,
;                   or compressed and
;                   fixed an issue that caused rounding errors between the following
;                   two algorithms (and others):
;                     1)  (2e0/mass[0]/mass[0]*1e5)
;                     2)  (2e5/mass[0]^2)
;                                                                   [01/19/2016   v2.1.0]
;             5)  Cleaned up routine
;                                                                   [02/19/2016   v2.1.1]
;
;   NOTES:      
;               1)  Original version can be found in the latest SPEDAS release,
;                     called:  thm_sst_convert_units2.pro
;                     found at:
;                     http://themis.ssl.berkeley.edu/socware/bleeding_edge/
;               2)  Fractional counts are forced to be used as default
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
;               9)  Ni, B., Y. Shprits, M. Hartinger, V. Angelopoulos, X. Gu, and
;                      D. Larson "Analysis of radiation belt energetic electron phase
;                      space density using THEMIS SST measurements: Cross‐satellite
;                      calibration and a case study," J. Geophys. Res. 116, A03208,
;                      doi:10.1029/2010JA016104, 2011.
;              10)  Turner, D.L., V. Angelopoulos, Y. Shprits, A. Kellerman, P. Cruce,
;                      and D. Larson "Radial distributions of equatorial phase space
;                      density for outer radiation belt electrons," Geophys. Res. Lett.
;                      39, L09101, doi:10.1029/2012GL051722, 2012.
;              11)  Bordoni, F. "Channel electron multiplier efficiency for 10-1000 eV
;                      electrons," Nucl. Inst. & Meth. 97, pp. 405, (1971).
;              12)  Goruganthu, R.R. and W.G. Wilson "Relative electron detection
;                      efficiency of microchannel plates from 0-3 keV,"
;                      Rev. Sci. Inst. 55, pp. 2030-2033, (1984).
;              13)  Meeks, C. and P.B. Siegel "Dead time correction via the time series,"
;                      Amer. J. Phys. 76, pp. 589-590, (2008).
;              14)  Schecker, J.A., M.M. Schauer, K. Holzscheiter, and M.H. Holzscheiter
;                      "The performance of a microchannel plate at cryogenic temperatures
;                      and in high magnetic fields, and the detection efficiency for
;                      low energy positive hydrogen ions,"
;                      Nucl. Inst. & Meth. in Phys. Res. A 320, pp. 556-561, (1992).
;
;   ADAPTED FROM:  thm_sst_convert_units2.pro
;   CREATED:  ??/??/????
;   CREATED BY:  Pat Cruce
;    LAST MODIFIED:  02/19/2016   v2.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO thm_convert_sst_units_lbwiii,data,units,SCALE=scale

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
str            = data[0]   ; => in case it is an array of structures of the same format
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
;;  check to make sure user is actually changing units
old_unit       = data[0].UNITS_NAME
new_unit       = units[0]
IF (STRUPCASE(new_unit[0]) EQ STRUPCASE(old_unit[0])) THEN RETURN
;;----------------------------------------------------------------------------------------
;;  These are vectorized for array of data structures
;;----------------------------------------------------------------------------------------
n_e            = data[0].NENERGY                 ;;  Number of energy bins
nbins          = data[0].NBINS                   ;;  Number of angle bins
n_str          = N_ELEMENTS(data)                ;;  Number of data structures
tags           = STRLOWCASE(TAG_NAMES(data[0]))  ;;  Structure tags names
;;  Define efficiencies
IF in_set(tags,'eff') THEN BEGIN
  eff = data.EFF
ENDIF ELSE BEGIN
  eff = 1e0
ENDELSE
;energy         = data.ENERGY                     ;;  [n_e,nbins,n_str]-Element array of energies (eV)
;denergy        = data.DENERGY                    ;;  [n_e,nbins,n_str]-Element array of energy ranges (eV)
;gf_facs        = FLTARR(n_e,nbins,n_str)
;mass           = FLTARR(n_e,nbins,n_str)         ;;  Particle mass [eV/c^2, with c in km/s]
;IF in_set(tags,'att') THEN att = data.ATT ELSE att = REPLICATE(1e0,n_e,nbins,n_str)
;dead           = data.DEADTIME                   ;;  Define detector dead time [s]
energy         = DOUBLE(data.ENERGY)             ;;  [n_e,nbins,n_str]-Element array of energies (eV)
denergy        = DOUBLE(data.DENERGY)            ;;  [n_e,nbins,n_str]-Element array of energy ranges (eV)
;;  Define the total geometry factor of the detector [cm^2 sr]
gf_facs        = DBLARR(n_e,nbins,n_str)
mass           = DBLARR(n_e,nbins,n_str)         ;;  Particle mass [eV/c^2, with c in km/s]
atten          = INTARR(n_e,nbins,n_str)         ;;  4-bit attenuator flags
IF in_set(tags,'att') THEN att = DOUBLE(data.ATT) ELSE att = REPLICATE(1d0,n_e,nbins,n_str)
dead           = DOUBLE(data.DEADTIME)           ;;  Define detector dead time [s]
dt             = DOUBLE(data.INTEG_T)            ;;  Total accumulation times [s]
;;  Define attenuator values, geometry factors, mass, etc.
dims           = SIZE(REFORM(data[0].DATA),/DIMENSIONS)
FOR j=0L, n_str - 1L DO BEGIN
  ;;  Total geometry factor of the detector [cm^2 sr]
  gf_facs[*,*,j]  = DOUBLE(data[j].GEOM_FACTOR[0])
  ;;  Particle mass [eV/c^2, with c in km/s]
  mass[*,*,j]     = DOUBLE(data[j].MASS[0])
  ;;  Attenuator values
  t_att           = REFORM(att[*,*,j])
  atten[*,*,j]    = thm_sst_atten_scale(data[j].ATTEN,dims,SCALE_FACTORS=t_att)
ENDFOR
;;  Define modified geometry factors
gf             = DOUBLE(gf_facs*data.GF*atten*denergy*eff)
;;----------------------------------------------------------------------------------------
;;  Define scale factors to new units
;;----------------------------------------------------------------------------------------
scale          = 1.
CASE STRUPCASE(old_unit[0]) OF
;  'EFLUX'       :  sfact = 1d0 * dt * gf / DOUBLE(energy)                ;;  eV cm^(-2) s^(-1) sr^(-1) eV^(-1)
;  'DF'          :  sfact = 1d0 * dt * gf * DOUBLE(energy) * 2d5/mass^2   ;;  # cm^(-3) km^(3) s^(-3)
  'COMPRESSED'  :  sfact = 1d0
  'COUNTS'      :  sfact = 1d0                                   ;;  #
  'RATE'        :  sfact = 1d0 * dt                              ;;  # s^(-1)
  'EFLUX'       :  sfact = 1d0 * dt * gf / energy                ;;  eV cm^(-2) s^(-1) sr^(-1) eV^(-1)
  'FLUX'        :  sfact = 1d0 * dt * gf                         ;;  # cm^(-2) s^(-1) sr^(-1) eV^(-1)
  'DF'          :  sfact = 1d0 * dt * gf * energy * 2d5/mass^2   ;;  # cm^(-3) km^(3) s^(-3)
  ELSE          : BEGIN
    MESSAGE,'Unknown starting units: ',old_unit[0]
    RETURN
  END
ENDCASE
;;  Adjust SCALE by factor associated with input units
scale         *= sfact
;;----------------------------------------------------------------------------------------
;;  Convert back to counts
;;----------------------------------------------------------------------------------------
tmp            = DOUBLE(data.DATA)
IF (STRUPCASE(old_unit[0]) EQ 'COMPRESSED') THEN tmp = thm_part_decomp16(BYTE(tmp))
;;  Adjust DATA by factor associated with input units
tmp           *= scale
;;----------------------------------------------------------------------------------------
;;  Remove dead time corrections
;;----------------------------------------------------------------------------------------
test           = (STRUPCASE(old_unit[0]) NE 'COUNTS') AND (STRUPCASE(old_unit[0]) NE 'RATE') $
                  AND (STRUPCASE(old_unit[0]) NE 'COMPRESSED')
IF (test[0]) THEN BEGIN
  temp  = 1d0 / (1d0 + (DOUBLE(dead)/dt)*tmp)
  tmp  *= temp
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define scale factors for new units
;;----------------------------------------------------------------------------------------
CASE STRUPCASE(new_unit[0]) OF
;  'EFLUX'       :  sfact = 1d0 / (dt * gf) * DOUBLE(energy)
;  'DF'          :  sfact = 1d0 / (dt * gf) / (DOUBLE(energy) * 2d5/mass^2)
  'COUNTS'      :  sfact = 1d0
  'RATE'        :  sfact = 1d0 / (dt)
  'EFLUX'       :  sfact = 1d0 / (dt * gf) * energy
  'FLUX'        :  sfact = 1d0 / (dt * gf)
  'DF'          :  sfact = 1d0 / (dt * gf) / (energy * 2d5/mass^2)
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
test           = (STRUPCASE(new_unit[0]) NE 'COUNTS') AND (STRUPCASE(new_unit[0]) NE 'RATE')
IF (test[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  correct for dead time
  ;;--------------------------------------------------------------------------------------
  temp  = DBLARR(n_e,nbins)
;  denom = 1d0 - (DOUBLE(dead)*tmp/dt)
  denom = 1d0 - (dead*tmp/dt)
  tmp2  = DBLARR(n_e,nbins,n_str)
  FOR j=0L, n_str - 1L DO BEGIN
    temp  = REFORM(denom[*,*,j])
    void  = WHERE(temp LT 2d-1,count)
    IF (count GT 0) THEN BEGIN
      dprint,DLEVEL=1,MIN(denom,ind)
      dprint,DLEVEL=1,' Error: sst_convert_units dead time error.'
      dprint,DLEVEL=1,' Dead time correction limited to x5 for ',count,' bins'
      dprint,DLEVEL=1,' Time= ',time_string(data[j].TIME[0],/MSEC)
      temp[void] = !VALUES.F_NAN
    ENDIF
    temp         = (2d-1 > temp) < 1d0
    ;;  Fill denom
    denom[*,*,j] = temp
  ENDFOR
  ;;  Define corrected values
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
;;----------------------------------------------------------------------------------------
;;  Redefine DATA tag and define output SCALE
;;----------------------------------------------------------------------------------------
temp           = scale1 * tmp2
scale          = FLOAT(TEMPORARY(scale)*scale1)
;scale         *= FLOAT(scale1)
;;  Check output [set NaNs to zeros]
idx            = WHERE(~FINITE(temp),c)
IF (c GT 0) THEN BEGIN
  temp[idx] = 0
ENDIF
data.DATA      = FLOAT(temp)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END





