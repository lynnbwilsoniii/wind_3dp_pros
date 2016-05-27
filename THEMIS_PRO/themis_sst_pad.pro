;*****************************************************************************************
;
;  FUNCTION :   themis_sst_pad_template.pro
;  PURPOSE  :   Create a dummy pitch-angle distribution (PAD) structure formatted for
;                 the themis_sst_pad.pro routine.
;
;  CALLED BY:   
;               themis_sst_pad.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               test_themis_esa_struc_format.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT    :  Scalar [structure] associated with a known THEMIS SST data
;                           structure
;                           [see get_th?_pe%$.pro, ? = a-f, % = i,e, $ = b,f,r]
;
;  EXAMPLES:    
;               [calling sequence]
;               pad_temp = themis_sst_pad_template([dat] [,ESTEPS=esteps] [,NUM_PA=num_pa])
;
;  KEYWORDS:    
;               ESTEPS :  [2]-Element [numeric] array specifying the first and last
;                           energy bins to keep in the returned structure
;                           [Default = [0,DAT.NENERGY - 1L]]
;               NUM_PA :  Scalar [numeric] defining the number of pitch-angle bins to
;                           compute from the input solid angle bin values
;                           [Default = 8]
;
;   CHANGED:  1)  Cleaned up and improved error handling and
;                   now calls is_a_number.pro
;                                                                   [11/30/2015   v1.1.0]
;             2)  Altered main routine
;                                                                   [11/30/2015   v1.2.0]
;             3)  Added keyword:  NUM_EN_OUT
;                                                                   [12/02/2015   v1.3.0]
;
;   NOTES:      
;               1)  The important structure tags are those used by my_padplot_both.pro
;                     and thm_convert_esa_units_lbwiii.pro
;               2)  User should not call this routine
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
;   CREATED:  11/24/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/02/2015   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION themis_sst_pad_template,dat,NUM_PA=num_pa,ESTEPS=esteps,NUM_EN_OUT=num_en_out

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN  ;;  dummy scalar [float]
d              = !VALUES.D_NAN  ;;  dummy scalar [double]
s              = ''             ;;  dummy scalar [string]
i              = 0              ;;  dummy scalar [integer]
l              = 0L             ;;  dummy scalar [long integer]
b              = 0b             ;;  dummy scalar [byte]
;;  Define default # of energy and solid angle bins
n_e            = 16L               ;;  Default # of energy bins
n_a            = 64L               ;;  Default # of solid angle bins
enbins         = [0L,n_e - 1L]
;;  Define original SST structure tags
old_tags       = ['PROJECT_NAME','SPACECRAFT','DATA_NAME','UNITS_NAME','UNITS_PROCEDURE',$
                  'TPLOTNAME','TIME','TRANGE','END_TIME','INDEX','NBINS','NENERGY',      $
                  'MAGF','SC_POT','MASS','CHARGE','VALID','APID','MODE','CNFG','NSPINS', $
                  'DATA','ENERGY','THETA','PHI','DENERGY','DTHETA','DPHI','BINS','GF',   $
                  'INTEG_T','DEADTIME','GEOM_FACTOR','ECLIPSE_DPHI','ATTEN','ATT',       $
                  'EFF','EN_LOW','EN_HIGH','DEAD_LAYER_OFFSETS','CHANNEL','VELOCITY']
;; Define new SST PAD structure tags
new_tags       = ['DEAD','VSW','BTH','BPH','ANGLES']
;; Define SST PAD structure tags
tags           = [old_tags,new_tags]
;;  Dummy error messages
notstr_mssg    = 'Must be an IDL structure...'
badstr_themis  = 'Not an appropriate THEMIS SST structure...'
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NUM_PA
test           = is_a_number(num_pa,/NOMSSG)
IF (test[0]) THEN pang  = (num_pa[0] < n_a[0]/3L) > 1L ELSE pang = 8L
;;  Check ESTEPS
test           = is_a_number(esteps,/NOMSSG) AND (N_ELEMENTS(esteps) EQ 2L)
IF (test[0]) THEN BEGIN
  nener  = esteps[SORT(esteps)]
  est_on = 1b
ENDIF ELSE BEGIN
  nener = enbins
  est_on = 0b
ENDELSE
;IF (test[0]) THEN nener = esteps[SORT(esteps)] ELSE nener = enbins
;;  Check NUM_EN_OUT
test           = is_a_number(num_en_out,/NOMSSG) AND (N_ELEMENTS(num_en_out) GT 0)
IF (test[0]) THEN BEGIN
  n_e_out = num_en_out[0] < n_e[0]
ENDIF ELSE BEGIN
  IF (est_on[0]) THEN n_e_out = nener[1] - nener[0] + 1L ELSE n_e_out = n_e[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define dummy arrays for filling template structure
;;----------------------------------------------------------------------------------------
;;  Redefine default # of energy and solid angle bins
;n_e            = nener[1] - nener[0] + 1L  ;;  # of energy bins on output
n_a            = pang[0]                   ;;  # of pitch-angle bins on output
;;  Define dummy arrays for structure
f_16           = REPLICATE(f,n_e_out[0])
f_16x64        = REPLICATE(f,n_e_out[0],n_a[0])
d_16x64        = REPLICATE(d,n_e_out[0],n_a[0])
i_16x64        = REPLICATE(i,n_e_out[0],n_a[0])
;f_16           = REPLICATE(f,n_e)
;f_16x64        = REPLICATE(f,n_e,n_a)
;d_16x64        = REPLICATE(d,n_e,n_a)
;i_16x64        = REPLICATE(i,n_e,n_a)
f_4            = REPLICATE(f,4L)
f_3            = REPLICATE(f,3L)
d_2            = REPLICATE(d,2L)
d_3            = REPLICATE(d,3L)
;;  Define dummy return structure
dumb_str       = CREATE_STRUCT(tags,'THEMIS-',s,s,s,s,s,d,d_2,d,l,l,l,d_3,f,f,f,i,i,  $
                               i,i,i,f_16x64,f_16x64,f_16x64,f_16x64,f_16x64,f_16x64, $
                               f_16x64,i_16x64,f_16x64,f_16x64,f_16x64,f,d,i,f_16x64, $
                               f_16x64,f_16,f_16,f_4,s,d_3,d,d_3,f,f,f_16x64)
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() EQ 0) THEN BEGIN
  ;; no input --> return default
  RETURN,dumb_str
ENDIF
str            = dat[0]   ;;  in case it is an array of structures of the same format
tests          = (SIZE(str,/TYPE) NE 8L)
IF (tests[0]) THEN BEGIN
  MESSAGE,notstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dumb_str
ENDIF

testf          = test_themis_esa_struc_format(str,/NOM) NE 1
IF (testf[0]) THEN BEGIN
  MESSAGE,badstr_themis[0],/INFORMATIONAL,/CONTINUE
  RETURN,dumb_str
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define structure information
;;----------------------------------------------------------------------------------------
;;  Define header information
proj_name      = dat[0].PROJECT_NAME         ;;  e.g. 'THEMIS-B'
sc_name        = dat[0].SPACECRAFT           ;;  e.g. 'b'
data_name      = dat[0].DATA_NAME+' PAD'     ;;  e.g. 'SST 3D burst PAD'
unit_name      = dat[0].UNITS_NAME           ;;  e.g. 'counts'
unit_proc      = dat[0].UNITS_PROCEDURE      ;;  e.g. 'thm_convert_sst_units_lbwiii'
tpname         = dat[0].TPLOTNAME            ;;  e.g. 'thc_pseb_064'
time_val       = dat[0].TIME                 ;;  Unix time at start of distribution
trange         = dat[0].TRANGE
etime_val      = dat[0].END_TIME             ;;  Unix time at end   of distribution
index          = dat[0].INDEX
magf           = dat[0].MAGF                 ;;  magnetic field vector [nT]
sc_pot         = dat[0].SC_POT               ;;  spacecraft potential [eV] estimate
mass           = dat[0].MASS                 ;;  particle mass [eV/c^2, with c in km/s]
charge         = dat[0].CHARGE               ;;  sign of particle charge
valid_val      = dat[0].VALID
apid_val       = dat[0].APID
mode           = dat[0].MODE
cnfg           = dat[0].CNFG
nspins         = dat[0].NSPINS
;;  Define structure constants
intt_val       = dat[0].INTEG_T              ;;  = DELTA_T/1024
deadtime       = dat[0].DEADTIME             ;;  detector dead time for each bin [s]
geomfac        = dat[0].GEOM_FACTOR          ;;  total geometry factor [cm^(2) sr]
ecl_dphi       = dat[0].ECLIPSE_DPHI
atten          = dat[0].ATTEN
dlayoffs       = dat[0].DEAD_LAYER_OFFSETS
chan           = dat[0].CHANNEL
veloc          = dat[0].VELOCITY             ;;  bulk flow velocity estimate [km/s]
deadt          = MEAN(deadtime,/NAN)
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
scnames        = ['THEMIS-'+STRUPCASE(sc_name[0]),sc_name[0]]
dumb_str       = CREATE_STRUCT(tags,scnames[0],scnames[1],data_name[0],unit_name[0],   $
                               unit_proc[0],tpname[0],time_val[0],trange,etime_val[0], $
                               index[0],FIX(n_a[0]),FIX(n_e[0]),magf,sc_pot[0],mass[0],$
                               charge[0],valid_val[0],apid_val[0],mode[0],cnfg[0],     $
                               nspins[0],f_16x64,f_16x64,f_16x64,f_16x64,f_16x64,      $
                               f_16x64,f_16x64,i_16x64,f_16x64,f_16x64,f_16x64,        $
                               geomfac[0],ecl_dphi[0],atten[0],f_16x64,f_16x64,f_16,   $
                               f_16,dlayoffs,chan[0],veloc,deadt[0],veloc,f,f,f_16x64  )
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,dumb_str
END

;+
;*****************************************************************************************
;
;  FUNCTION :   themis_sst_pad.pro
;  PURPOSE  :   Creates a pitch-angle distribution (PAD) from a THEMIS SST data
;                 structure that can be plotted using my_padplot_both.pro.
;
;  CALLED BY:   
;               my_padplot_both.pro
;
;  INCLUDES:
;               themis_sst_pad_template.pro
;
;  CALLS:
;               themis_sst_pad_template.pro
;               test_themis_esa_struc_format.pro
;               thm_sst_atten_scale.pro
;               is_a_number.pro
;               format_esa_bins_keyword.pro
;               is_a_3_vector.pro
;               str_element.pro
;               xyz_to_polar.pro
;               pangle.pro
;               interp.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT    :  Scalar [structure] associated with a known THEMIS SST data
;                           structure
;                           [see get_th?_pe%$.pro, ? = a-f, % = i,e, $ = b,f,r]
;
;  EXAMPLES:    
;               [calling sequence]
;               pad = themis_sst_pad(dat [,MAGF=magf] [,ESTEPS=esteps] [,BINS=bins] $
;                                                      [,NUM_PA=num_pa])
;
;  KEYWORDS:    
;               MAGF   :  [3]-Element [numeric] array defining the magnetic field
;                           3-vector to use to create the PAD
;                           [Default = DAT.MAGF]
;               ESTEPS :  [2]-Element [numeric] array specifying the first and last
;                           energy bins to keep in the returned structure
;                           [Default = [0,DAT.NENERGY - 1L]]
;               BINS   :  [N]-Element [numeric] array define which solid angle bins to
;                           sum over when calculating the PAD
;                           [Default = INDGEN(DAT.NBINS)]
;               NUM_PA :  Scalar [numeric] defining the number of pitch-angle bins to
;                           compute from the input solid angle bin values
;                           [Default = 8]
;
;   CHANGED:  1)  Cleaned up and improved error handling and
;                   now calls is_a_number.pro, is_a_3_vector.pro, str_element.pro
;                                                                   [11/30/2015   v1.1.0]
;             2)  Now calls format_esa_bins_keyword.pro
;                                                                   [11/30/2015   v1.2.0]
;             3)  Added keyword:  NUM_EN_OUT
;                                                                   [12/02/2015   v1.3.0]
;
;   NOTES:      
;               1)  This routine is specific to THEMIS SST data structures
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
;   CREATED:  11/24/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/02/2015   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION themis_sst_pad,dat,MAGF=magf,ESTEPS=esteps,BINS=bins,NUM_PA=num_pa,$
                            NUM_EN_OUT=num_en_out

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN  ;; dummy scalar [float]
d              = !VALUES.D_NAN  ;; dummy scalar [double]
;;  Dummy error messages
notstr_mssg    = 'Must be an IDL structure...'
badstr_themis  = 'Not an appropriate THEMIS SST structure...'
badmagtag_msg  = 'MAGF structure tag either not set in DAT or not finite...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() EQ 0) THEN BEGIN
  ;; no input --> return default
  RETURN,themis_sst_pad_template(NUM_PA=num_pa,ESTEPS=esteps,NUM_EN_OUT=num_en_out)
;  RETURN,themis_sst_pad_template()
ENDIF
;;  Check input format
str            = dat[0]   ;;  in case it is an array of structures of the same format
tests          = (SIZE(str,/TYPE) NE 8L)
testf          = test_themis_esa_struc_format(str,/NOM) NE 1
test           = tests OR testf
IF (test[0]) THEN BEGIN
  ;;  Input is not a SST structure
  MESSAGE,badstr_themis[0],/INFORMATIONAL,/CONTINUE
  RETURN,themis_sst_pad_template(str,NUM_PA=num_pa,ESTEPS=esteps,NUM_EN_OUT=num_en_out)
;  RETURN,themis_sst_pad_template(str)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define data structure parameters
;;----------------------------------------------------------------------------------------
;;  Define default # of energy and solid angle bins
n_e            = dat[0].NENERGY                   ;;  default # of energy bins
n_a            = dat[0].NBINS                     ;;  default # of solid angle bins

data0          = dat[0].DATA
geom0          = dat[0].GF                        ;;  relative geometry factor per bin
dt0            = dat[0].INTEG_T                   ;;  total accumulation times [unitless]
energy0        = dat[0].ENERGY                    ;;  energy bin values [eV]
denergy0       = dat[0].DENERGY
;count0         = REPLICATE(0,n_e,n_a)             ;;  # of points calculated
deadtime0      = dat[0].DEADTIME                  ;;  detector dead time for each bin [s]
eff0           = dat[0].EFF                       ;;  efficiency and deadtime corrections
att0           = dat[0].ATT                       ;;  attenuation scaling factors
theta0         = dat[0].THETA
phi0           = dat[0].PHI
bins0          = dat[0].BINS                      ;;  good/bad bins
def_bins       = TOTAL(bins0,1,/NAN)
;;  Calculate attenuation factors
dims           = SIZE(REFORM(data0),/DIMENSIONS)
atten_fac      = thm_sst_atten_scale(dat[0].ATTEN,dims,SCALE_FACTORS=att0)
;;  Adjust modified geometry factors
geom0         *= atten_fac
;;  Calculate the average energy bin values [eV]
avg_ener       = TOTAL(energy0,2L,/NAN)/TOTAL(FINITE(energy0),2L,/NAN)
avg_dener      = TOTAL(denergy0,2L,/NAN)/TOTAL(FINITE(denergy0),2L,/NAN)
test_e         = ((avg_ener LE 0.0) OR (FINITE(avg_ener) EQ 0)) OR $
                 ((avg_dener LE 0.0) OR (FINITE(avg_dener) EQ 0))
bad_e          = WHERE(test_e,bd_e,COMPLEMENT=good_e,NCOMPLEMENT=gd_e)
;bad_e          = WHERE(avg_ener LE 0.0 OR FINITE(avg_ener) EQ 0,bd_e,COMPLEMENT=good_e,NCOMPLEMENT=gd_e)
IF (bd_e[0] EQ n_e[0]) THEN BEGIN
  ;;  input is not an ESA structure
  MESSAGE,'There are no finite energy bin values for DAT...',/INFORMATIONAL,/CONTINUE
  RETURN,themis_sst_pad_template(str,NUM_PA=num_pa,ESTEPS=esteps,NUM_EN_OUT=num_en_out)
;  RETURN,themis_sst_pad_template(str)
ENDIF
enbins         = [0L,n_e - 1L]                    ;;  Default start/end energy bin indices
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NUM_PA
;;    --> Define # of pitch-angle bins on output
test           = is_a_number(num_pa,/NOMSSG)
IF (test[0]) THEN pang  = (num_pa[0] < n_a[0]/3L) > 1L ELSE pang = 8L
;;  Check ESTEPS
;;    --> Define # of energy bins on output
test           = is_a_number(esteps,/NOMSSG) AND (N_ELEMENTS(esteps) EQ 2L)
IF (test[0]) THEN BEGIN
  nener  = esteps[SORT(esteps)]
  est_on = 1b
ENDIF ELSE BEGIN
  nener = enbins
  est_on = 0b
ENDELSE
;IF (test[0]) THEN nener = esteps[SORT(esteps)] ELSE nener = enbins
;;  Make sure energy bin indices only correspond to finite energy bins
;;    *** Some structures have NaNs for highest energy bins ***
;;      --> constrain energy bin definition
mnmx_gde       = [MIN(good_e,len),MAX(good_e,lex)]
mnmx_gde       = mnmx_gde[SORT(mnmx_gde)]
nener[0]       = (nener[0] > mnmx_gde[0]) < mnmx_gde[1]
nener[1]       = (nener[1] > mnmx_gde[0]) < mnmx_gde[1]
;nener[0]       = (nener[0] > MIN(good_e)) < MAX(good_e)
;nener[1]       = (nener[1] > MIN(good_e)) < MAX(good_e)
;;  Check BINS
;;    --> Define # of solid angle bins to sum over
test           = is_a_number(bins,/NOMSSG) AND (N_ELEMENTS(bins) EQ n_a[0])
IF (test[0]) THEN BEGIN
  bstr           = format_esa_bins_keyword(dat,BINS=bins)
  IF (SIZE(bstr,/TYPE) EQ 8) THEN BEGIN
    ind = bstr.BINS_GOOD_INDS
  ENDIF ELSE ind = WHERE(def_bins GT 0)
ENDIF ELSE ind = WHERE(def_bins GT 0)
test           = (ind[0] LT 0)
IF (test[0]) THEN ind = INDGEN(dat[0].NBINS)
;;  Check NUM_EN_OUT
test           = is_a_number(num_en_out,/NOMSSG) AND (N_ELEMENTS(num_en_out) GT 0)
IF (test[0]) THEN BEGIN
  n_e_out = num_en_out[0] < n_e[0]
ENDIF ELSE BEGIN
  IF (est_on[0]) THEN n_e_out = nener[1] - nener[0] + 1L ELSE n_e_out = n_e[0]
ENDELSE
;;  Check MAGF
test           = is_a_3_vector(magf,/NOMSSG)
IF (test[0]) THEN test = (TOTAL(FINITE(magf)) EQ 3)
IF (test[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  MAGF set correctly with finite values
  ;;--------------------------------------------------------------------------------------
  magf = REFORM(magf)
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  MAGF not set --> check if structure tag available
  ;;--------------------------------------------------------------------------------------
  str_element,dat,'MAGF',magf
  test           = is_a_3_vector(magf,/NOMSSG)
  IF (test[0]) THEN BEGIN
    test = (TOTAL(FINITE(magf)) NE 3)
    IF (test[0]) THEN BEGIN
      ;;  MAGF tag exists, but not finite --> Return to user
      MESSAGE,'FINITE:  '+badmagtag_msg[0],/INFORMATIONAL,/CONTINUE
      RETURN,themis_sst_pad_template(str,NUM_PA=pang[0],ESTEPS=nener,NUM_EN_OUT=n_e_out[0])
    ENDIF
;    test = (TOTAL(FINITE(magf)) EQ 3)
;    IF (test[0]) THEN BEGIN
;      ;;  GOOD --> Re-call routine with MAGF set
;      RETURN,themis_sst_pad(dat,MAGF=magf,ESTEPS=nener,BINS=bins,NUM_PA=pang)
;    ENDIF ELSE BEGIN
;      ;;  MAGF tag exists, but not finite --> Return to user
;      MESSAGE,'FINITE:  '+badmagtag_msg[0],/INFORMATIONAL,/CONTINUE
;      RETURN,themis_sst_pad_template(str)
;    ENDELSE
  ENDIF ELSE BEGIN
    ;;  MAGF tag does NOT exists --> Return to user
    MESSAGE,'EXIST:  '+badmagtag_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN,themis_sst_pad_template(str,NUM_PA=pang[0],ESTEPS=nener,NUM_EN_OUT=n_e_out[0])
;    RETURN,themis_sst_pad_template(str)
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define dummy data variables
;;----------------------------------------------------------------------------------------
e_ind          = LINDGEN(n_e)                  ;;  indices for energies
nbins          = N_ELEMENTS(ind)
f_32x88        = REPLICATE(f,n_e_out[0],pang[0])
z_32x88        = REPLICATE(0e0,n_e_out[0],pang[0])

data           = z_32x88                       ;;  Dummy array of PAD data
geom           = z_32x88                       ;;  " " geometry factor data
int_t          = z_32x88                       ;;  " " Integration times (s)
energy         = z_32x88                       ;;  " " energies (eV)
denergy        = z_32x88                       ;;  " " differential energies (eV)
count          = z_32x88                       ;;  " " # of points calculated
deadtime       = z_32x88                       ;;  " " times when plate detector is off (s)
eff            = z_32x88                       ;;  SST efficiency
att            = z_32x88                       ;;  attenuation scaling factors
pangles        = z_32x88                       ;;  " " pitch-angles (deg)
;data           = FLTARR(n_e[0],pang[0])        ;;  Dummy array of PAD data
;geom           = FLTARR(n_e[0],pang[0])        ;;  " " geometry factor data
;int_t          = FLTARR(n_e[0],pang[0])        ;;  " " Integration times (s)
;energy         = FLTARR(n_e[0],pang[0])        ;;  " " energies (eV)
;denergy        = FLTARR(n_e[0],pang[0])        ;;  " " differential energies (eV)
;count          = FLTARR(n_e[0],pang[0])        ;;  " " # of points calculated
;deadtime       = FLTARR(n_e[0],pang[0])        ;;  " " times when plate detector is off (s)
;eff            = FLTARR(n_e[0],pang[0])        ;;  SST efficiency
;att            = FLTARR(n_e[0],pang[0])        ;;  attenuation scaling factors
;pangles        = FLTARR(n_e[0],pang[0])        ;;  " " pitch-angles (deg)
;;  Replace NaNs in DATA array with zeros to avoid causing too many bins
;;    --> NaNs occur from the addition of any number with a NaN (see operations below)
bad0           = WHERE(data0 LE 0e0 OR FINITE(data0) EQ 0,bd0,COMPLEMENT=good0,NCOMPLEMENT=gd0)
IF (bd0 GT 0) THEN data0[bad0] = 0e0
;;----------------------------------------------------------------------------------------
;;  Convert B-field vector to polar coordinates and calculate pitch-angles
;;----------------------------------------------------------------------------------------
xyz_to_polar,magf,THETA=bth,PHI=bph
;;  Calculate Pitch-Angles from data and B-field
pa             = pangle(theta0,phi0,bth,bph)
pab            = FIX(pa/18e1*pang[0])  < (pang[0] - 1)
IF (ABS(bth) GT 9e1) THEN pab[*,*] = 0   ;;  remove non-physical solutions
;;----------------------------------------------------------------------------------------
;;  Calculate Pitch-Angle Distributions (PADs)
;;----------------------------------------------------------------------------------------
FOR i=0L, nbins - 1L DO BEGIN
  b        = ind[i]            ;;  Solid angle index
  n_b      = pab[e_ind,b]      ;;  Bins to use for pitch-angle estimates
  ;;  Define the elements of PAB to sum over
  n_b_indx = WHERE(n_b GE 0 AND n_b LT pang[0],n_b_cnt)
  IF (n_b_cnt GT 0) THEN BEGIN
    e2                 = e_ind[n_b_indx]   ;;  good energy bin elements
    ne2                = e2
    nb2                = n_b[n_b_indx]
    ;;------------------------------------------------------------------------------------
    ;; sum constituent elements
    ;;------------------------------------------------------------------------------------
    data[ne2,nb2]     += data0[e2,b]       ;;  data
    energy[ne2,nb2]   += energy0[e2,b]     ;;  energies [eV]
    geom[ne2,nb2]     += geom0[e2,b]       ;;  geometry factors
    int_t[ne2,nb2]    += dt0[e2,b]         ;;  total accumulation times
    denergy[ne2,nb2]  += denergy0[e2,b]    ;;  uncertainty in energies [eV]
    count[ne2,nb2]    += 1e0
    deadtime[ne2,nb2] += deadtime0[e2,b]   ;;  deadtimes [s]
    eff[ne2,nb2]      += eff0[e2,b]        ;;  efficiencies
    att[ne2,nb2]      += att0[e2,b]        ;;  attenuation scaling factors
    pangles[ne2,nb2]  += pa[e2,b]          ;;  pitch-angles [deg]
  ENDIF
ENDFOR
;;  Normalize by the # of PAs calculated
energy        /= count
denergy       /= count
pangles       /= count
eff           /= count
att           /= count
IF (STRLOWCASE(dat[0].UNITS_NAME) NE 'counts') THEN data /= count
;;----------------------------------------------------------------------------------------
;;  Get rid of non-finite or negative energy bin values
;;----------------------------------------------------------------------------------------
bad            = WHERE(energy LE 0.0 OR FINITE(energy) EQ 0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0) THEN BEGIN
  ;;  get rid of "bad" energy bin values
  avge_2d     = avg_ener # REPLICATE(1e0,pang[0])
  energy[bad] = avge_2d[bad]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get rid of non-finite or negative PAs
;;----------------------------------------------------------------------------------------
avg_pangs      = TOTAL(pangles,1,/NAN)/TOTAL(FINITE(pangles),1,/NAN)
bad            = WHERE(pangles LE 0.0 OR FINITE(pangles) EQ 0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0) THEN BEGIN
  ;;  get rid of "bad" PAs data
  avgpa_2d     =  REPLICATE(1e0,n_e[0]) # avg_pangs
  pangles[bad] = avgpa_2d[bad]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Interpolate across "bad" data points
;;    *** this part seems to be increasing the # of bad points, not decreasing ***
;;----------------------------------------------------------------------------------------
bad            = WHERE(data LE 0.0 OR FINITE(data) EQ 0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0) THEN BEGIN
  ;;  get rid of "bad" data
  FOR j=0L, n_e[0] - 1L DO BEGIN
    t_data = REFORM(data[j,*])
    t_pang = REFORM(pangles[j,*])
    bad    = WHERE(t_data LE 0.0 OR FINITE(t_data) EQ 0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
    IF (gd GT 3) THEN BEGIN
      ;;  > 3 finite points --> linearly interpolate over PAs w/o extrapolation
      temp   = interp(t_data[good],t_pang[good],t_pang,/NO_EXTRAP)
    ENDIF ELSE BEGIN
      ;;  ≤ 3 finite points --> do nothing
      temp   = t_data
    ENDELSE
    data[j,*] = temp
  ENDFOR
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define desired energy bins
;;----------------------------------------------------------------------------------------
;;  Redefine default # of energy and solid angle bins
n_e            = nener[1] - nener[0] + 1L  ;;  # of energy bins on output
;;  Find energy bin indices
mine           = MIN(avg_ener[nener],/NAN,len)
maxe           = MAX(avg_ener[nener],/NAN,lex)
;;  SST energy bin values go from HIGH -> LOW
s_e            = nener[lex[0]] < nener[len[0]]
e_e            = nener[len[0]] > nener[lex[0]]
e_ind          = LINDGEN(n_e) + s_e[0]     ;;  indices for energies
;;----------------------------------------------------------------------------------------
;;  Get dummy structure to fill
;;----------------------------------------------------------------------------------------
pad_str        = themis_sst_pad_template(dat[0],ESTEPS=nener,NUM_PA=pang[0],NUM_EN_OUT=n_e_out[0])
;pad_str        = themis_sst_pad_template(dat[0],ESTEPS=nener,NUM_PA=pang[0])
;;----------------------------------------------------------------------------------------
;;  Keep only desired energy bins
;;----------------------------------------------------------------------------------------
n__data        = f_32x88
n__geom        = f_32x88
n_int_t        = f_32x88
n__ener        = f_32x88
n_dener        = f_32x88
n__pang        = f_32x88
n_count        = f_32x88
n_deadt        = f_32x88
n___eff        = f_32x88
n___att        = f_32x88
;;  Fill arrays
n__data[e_ind,*] =     data[e_ind,*]
n__geom[e_ind,*] =     geom[e_ind,*]
n_int_t[e_ind,*] =     int_t[e_ind,*]
n__ener[e_ind,*] =   energy[e_ind,*]
n_dener[e_ind,*] =  denergy[e_ind,*]
n_deadt[e_ind,*] = deadtime[e_ind,*]
n___eff[e_ind,*] =      eff[e_ind,*]
n___att[e_ind,*] =      att[e_ind,*]
n__pang[e_ind,*] =  pangles[e_ind,*]
n_count[e_ind,*] =    count[e_ind,*]
;newd           = data[e_ind,*]
;geom           = geom[e_ind,*]
;int_t          = int_t[e_ind,*]
;energy         = energy[e_ind,*]
;denergy        = denergy[e_ind,*]
;count          = count[e_ind,*]
;deadtime       = deadtime[e_ind,*]
;eff            = eff[e_ind,*]
;att            = att[e_ind,*]
;newp           = pangles[e_ind,*]
;;  Redefine low/high energies [i.e., EN_LOW and EN_HIGH structure tags]
del_e          = n_dener/2e0
elow_2d        = n__ener - del_e
ehig_2d        = n__ener + del_e
;del_e          = denergy/2e0
;elow_2d        = energy - del_e
;ehig_2d        = energy + del_e
elow           = TOTAL(elow_2d,2,/NAN)/n_e[0]*1d-3     ;;  eV --> keV
ehig           = TOTAL(ehig_2d,2,/NAN)/n_e[0]*1d-3     ;;  eV --> keV
bins_out       = FIX(z_32x88)
good           = WHERE(FINITE(n__data),gd)
;bins_out       = REPLICATE(0,n_e[0],pang[0])
;good           = WHERE(FINITE(newd),gd)
IF (gd GT 0) THEN bins_out[good] = 1
;;----------------------------------------------------------------------------------------
;;  Fill dummy structure
;;----------------------------------------------------------------------------------------
str_element,pad_str,    'DATA', n__data,/ADD_REPLACE
str_element,pad_str,      'GF', n__geom,/ADD_REPLACE
str_element,pad_str, 'INTEG_T', n_int_t,/ADD_REPLACE
str_element,pad_str,  'ENERGY', n__ener,/ADD_REPLACE
str_element,pad_str, 'DENERGY', n_dener,/ADD_REPLACE
str_element,pad_str,'DEADTIME', n_deadt,/ADD_REPLACE
str_element,pad_str,     'EFF', n___eff,/ADD_REPLACE
str_element,pad_str,     'ATT', n___att,/ADD_REPLACE
str_element,pad_str,     'BTH',     bth,/ADD_REPLACE
str_element,pad_str,     'BPH',     bph,/ADD_REPLACE
str_element,pad_str,  'ANGLES', n__pang,/ADD_REPLACE
str_element,pad_str,  'EN_LOW',    elow,/ADD_REPLACE
str_element,pad_str, 'EN_HIGH',    ehig,/ADD_REPLACE
str_element,pad_str,    'BINS',bins_out,/ADD_REPLACE
;str_element,pad_str,    'DATA',    newd,/ADD_REPLACE
;str_element,pad_str,      'GF',    geom,/ADD_REPLACE
;str_element,pad_str, 'INTEG_T',   int_t,/ADD_REPLACE
;str_element,pad_str,  'ENERGY',  energy,/ADD_REPLACE
;str_element,pad_str, 'DENERGY', denergy,/ADD_REPLACE
;str_element,pad_str,'DEADTIME',deadtime,/ADD_REPLACE
;str_element,pad_str,     'EFF',     eff,/ADD_REPLACE
;str_element,pad_str,     'ATT',     att,/ADD_REPLACE
;str_element,pad_str,  'ANGLES',    newp,/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Return structure to user
;;----------------------------------------------------------------------------------------

RETURN,pad_str
END