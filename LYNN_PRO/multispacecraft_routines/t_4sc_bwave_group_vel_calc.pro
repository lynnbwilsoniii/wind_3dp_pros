;*****************************************************************************************
;
;  FUNCTION :   calc_val_uncert_t4scbwave.pro
;  PURPOSE  :   Uses one-variable stats to calculate the value and uncertainty
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               calc_1var_stats.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X            :  [N]-Element [numeric] array of values on which to perform
;                                 one-variable stats
;
;  EXAMPLES:    
;               [calling sequence]
;               valunc = calc_val_uncert_t4scbwave(x)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   CREATED:  10/16/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/16/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION calc_val_uncert_t4scbwave,x

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
dumb           = REPLICATE(d,2L)
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 1) THEN RETURN,dumb
;;  Calculate one-variable stats
onvs           = calc_1var_stats(x,/NAN,/NOMSSG)
IF (N_ELEMENTS(onvs) NE 13) THEN RETURN,dumb
val            = onvs[3]
unc            = (onvs[9] - onvs[8])/2d0
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,[val[0],unc[0]]
END


;+
;*****************************************************************************************
;
;  FUNCTION :   t_4sc_bwave_group_vel_calc.pro
;  PURPOSE  :   This routine takes the TPLOT handles associated with spacecraft positions
;                 and magnetic fields, from at least 4 spacecraft, to calculate the
;                 group speed and group velocity unit vector of the waves within the user
;                 defined time ranges from each spacecraft.  If the user provides the
;                 bulk flow velocity of the plasma, then the rest frame group speed and
;                 velocity can be calculated.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               calc_val_uncert_t4scbwave.pro
;
;  CALLS:
;               is_a_number.pro
;               test_tplot_handle.pro
;               is_a_3_vector.pro
;               test_plot_axis_range.pro
;               get_data.pro
;               t_get_struc_unix.pro
;               sample_rate.pro
;               vector_bandpass.pro
;               trange_clip_data.pro
;               t_resample_tplot_struc.pro
;               lbw_diff.pro
;               lbw_lu_decomp_4sc_timing.pro
;               unit_vec.pro
;               calc_val_uncert_t4scbwave.pro
;               mag__vec.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TPN_POSI     :  [4]-Element [string] array defining set and valid TPLOT
;                                 handles associated with spacecraft positions all in
;                                 the same coordinate basis
;               TPN_MAGF     :  [4]-Element [string] array defining set and valid TPLOT
;                                 handles associated with magnetic field data all in
;                                 the same coordinate basis
;               TRAN_SE      :  [4,2]-Element [double] array defining the time stamps of
;                                 points of interest to use for calculating the normal
;                                 unit vector.
;
;  EXAMPLES:    
;               [calling sequence]
;               struc = t_4sc_bwave_group_vel_calc(tpn_posi,tpn_magf,tran_se [,PERTDT=pertdt] $
;                                                  [,VBULK=vbulk] [,DELVB=delvb] [,/NOMSSG])
;
;  KEYWORDS:    
;               PERTDT       :  Scalar [numeric] defining the delta-t for the perturbing
;                                 time stamps about the time of interest
;                                 [Default = 0.01]
;               VBULK        :  [3]-Element [numeric] array defining the plasma bulk
;                                 flow velocity to use to convert the spacecraft frame
;                                 group speed to the plasma rest frame speed [km/s]
;                                 [Default = [0,0,0]]
;               DELVB        :  [3]-Element [numeric] array defining the uncertainty in
;                                 VBULK [km/s]
;                                 [Default = [0,0,0]]
;               FRAN         :  [2]-Element [numeric] array defining the range of
;                                 frequencies to use to filter the data before applying
;                                 the cross-correlation algorithm
;                                 [Default = FALSE]
;               NOMSSG       :  If set, routine will not inform user of elapsed
;                                 computational time [s]
;                                 [Default = FALSE]
;
;   CHANGED:  1)  Added keyword: FRAN and
;                   now calls test_plot_axis_range.pro and vector_bandpass.pro
;                                                                   [10/07/2020   v1.0.1]
;             2)  Now includes wave unit vector in both plasma and spacecraft frames
;                                                                   [10/08/2020   v1.0.2]
;             3)  Now calls lbw_lu_decomp_4sc_timing.pro
;                                                                   [10/08/2020   v1.0.3]
;             4)  Fixed a typo in Man. page and cleaned up routine
;                                                                   [10/13/2020   v1.0.4]
;             5)  Fixed omission in Man. page and correctly normalized unit vectors
;                                                                   [10/15/2020   v1.0.5]
;             6)  Realized this routine is actually calculating group velocity, so major
;                   changes to fix this issue including renaming from
;                   t_4sc_bwave_phase_vel_calc.pro to t_4sc_bwave_group_vel_calc.pro and
;                   now includes calc_val_uncert_t4scbwave.pro
;                                                                   [10/16/2020   v2.0.0]
;             7)  Fixed an issue in the velocity transformation from SCF to PRF
;                                                                   [10/17/2020   v2.0.1]
;
;   NOTES:      
;               1)  This routine uses LU decomposition
;                     A . X = B
;                       A_ijm = (∆r_ij)_m
;                       B_ijm = (t_i - t_j)_m
;                       X     = (g/|g|)/V_gr,sc
;               2)  ∆r . k = V_gr,sc ∆t
;                       V_gr,sc         = 1/|X|
;                       (k/|k|)         = X/|X|
;                       V_gr,sc         = V_gr + Vsw
;                       V_gr            = V_gr,sc - Vsw
;               3)  ICB  =  Input Coordinate Basis
;               4)  Coordinate Systems
;                     SPG    :  Spinning Probe Geometric
;                     SSL    :  Spinning Sun-Sensor L-Vector
;                     DSL    :  Despun Sun-L-VectorZ (THEMIS and MMS Mission)
;                     BCS    :  Body Coordinate System (MMS Mission)
;                     DBCS   :  despun-BCS (MMS Mission)
;                     SMPA   :  Spinning, Major Principal Axis (MMS Mission)
;                     DMPA   :  Despun, Major Principal Axis (MMS Mission)
;                     GEI    :  Geocentric Equatorial Inertial
;                     GEO    :  Geographic
;                     GSE    :  Geocentric Solar Ecliptic
;                     GSM    :  Geocentric Solar Magnetospheric
;                     ICB    :  Input Coordinate Basis (e.g., GSE)
;
;  REFERENCES:  
;               0)  See IDL's documentation for:
;                     https://www.harrisgeospatial.com/docs/LA_LUDC.html
;                     https://www.harrisgeospatial.com/docs/LA_LUSOL.html
;                     https://www.harrisgeospatial.com/docs/C_CORRELATE.html
;               1)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;
;   CREATED:  10/02/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/17/2020   v2.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION t_4sc_bwave_group_vel_calc,tpn_posi,tpn_magf,tran_se,PERTDT=pertdt,VBULK=vbulk,$
                                    DELVB=delvb,FRAN=fran,NOMSSG=nomssg

ex_start       = SYSTIME(1)
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define defaults
npert          = 33L                                   ;;  # of perturbing points about selected time
npmid          = 16L                                   ;;  Element of midpoint in perturbing array
perd           = DINDGEN(npert[0]) - npmid[0]          ;;  Array of perturbing elements
usearr         = LINDGEN(5) + (npmid[0] - 2L)          ;;  Array of perturbing elements to use in analysis
del            = [-1d0,-5d-1,0d0,5d-1,1d0]
nd             = N_ELEMENTS(del)
;;----------------------------------------------------------------------------------------
;;  Coordinates and vectors
;;----------------------------------------------------------------------------------------
;;  Define some default strings
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_bcs      = 'bcs'                    ;;  Body Coordinate System (of MMS spacecraft)
coord_dbcs     = 'dbcs'                   ;;  despun-BCS
coord_dmpa     = 'dmpa'                   ;;  Despun, Major Principal Axis (coordinate system)
coordj2000     = 'j2000'                  ;;  GEI/J2000
coord_mag      = 'mag'
vec_str        = ['x','y','z']
vec_col        = [250,150, 50]
fac_lab        = ['par','per','tot']
start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
;;  Error messages
noinput_mssg   = 'No input was supplied...'
no_tpns_mssg   = 'Not enough valid TPLOT handles supplied...'
badinpt_mssg   = 'Incorrect input format was supplied:  TRAN_SE must be an [4,2]-element [double] array'
battpdt_mssg   = 'The TPLOT handles supplied did not contain data...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = ((N_PARAMS() LT 2) OR (SIZE(tpn_posi,/TYPE) NE 7) OR                 $
                  (SIZE(tpn_magf,/TYPE) NE 7) OR (is_a_number(tran_se,/NOMSSG) EQ 0))
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
testp          = test_tplot_handle(tpn_posi,TPNMS=tpnposi)
testm          = test_tplot_handle(tpn_magf,TPNMS=tpnmagf)
test           = testp[0] AND testm[0]
goodp          = WHERE(tpnposi NE '',gdp)
goodm          = WHERE(tpnmagf NE '',gdm)
IF (gdp[0] LT 4 OR gdm[0] LT 4 OR ~test[0]) THEN BEGIN
  MESSAGE,no_tpns_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
sznd           = SIZE(tran_se,/N_DIMENSIONS)
szdd           = SIZE(tran_se,/DIMENSIONS)
test           = ((N_ELEMENTS(tran_se) MOD 4) NE 0) OR ((sznd[0] NE 2) AND (N_ELEMENTS(tran_se) NE 8))
IF (test[0]) THEN BEGIN
  MESSAGE,badinpt_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define time ranges
IF (szdd[1] NE 2) THEN trans = TRANSPOSE(tran_se) ELSE trans = REFORM(tran_se,4,2)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check PERTDT
IF (is_a_number(pertdt,/NOMSSG)) THEN pdt = ABS(1d0*pertdt[0]) ELSE pdt = 1d-2
;;  Define perturbing time array
pert           = perd*pdt[0]                             ;;  Converted to ∆t about t_j
;;  Check VBULK
test           = (is_a_3_vector(vbulk,V_OUT=vswo ,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  vbulk_on = 0b
  delvb_on = 0b
  vswo     = REPLICATE(0d0,3L)
ENDIF ELSE BEGIN
  ;;  VBULK is on --> check if it's properly used
  vswo     = REFORM(vswo)
  vbulk_on = (TOTAL(FINITE(vswo)) EQ 3)
  IF (vbulk_on[0]) THEN BEGIN
    ;;  Check DELVB
    test   = (is_a_3_vector(delvb,V_OUT=dvsw ,/NOMSSG) EQ 0)
    IF (test[0]) THEN BEGIN
      delvb_on = 0b
    ENDIF ELSE BEGIN
      dvsw     = ABS(REFORM(dvsw))
      delvb_on = (TOTAL(FINITE(dvsw)) EQ 3)
    ENDELSE
  ENDIF ELSE delvb_on = 0b
ENDELSE
;;  Check FRAN
IF (test_plot_axis_range(fran,/NOMSSG)) THEN BEGIN
  frq_ran = 1d0*fran[SORT(fran)]
  filt_on = 1b
ENDIF ELSE BEGIN
  filt_on = 0b
  frq_ran = REPLICATE(d,2L)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Get TPLOT data
;;----------------------------------------------------------------------------------------
;;  Get Bo [nT, GSE]
get_data,tpn_magf[0],DATA=temp_magfv_1
get_data,tpn_magf[1],DATA=temp_magfv_2
get_data,tpn_magf[2],DATA=temp_magfv_3
get_data,tpn_magf[3],DATA=temp_magfv_4
;;  Get SC positions [km, GSE]
get_data,tpn_posi[0],DATA=mms_gsepos_1
get_data,tpn_posi[1],DATA=mms_gsepos_2
get_data,tpn_posi[2],DATA=mms_gsepos_3
get_data,tpn_posi[3],DATA=mms_gsepos_4
;;  Make sure we haven't grabbed nothing from TPLOT
test           = (SIZE(temp_magfv_1,/TYPE) NE 8) OR (SIZE(temp_magfv_2,/TYPE) NE 8) OR $
                 (SIZE(temp_magfv_3,/TYPE) NE 8) OR (SIZE(temp_magfv_4,/TYPE) NE 8) OR $
                 (SIZE(mms_gsepos_1,/TYPE) NE 8) OR (SIZE(mms_gsepos_2,/TYPE) NE 8) OR $
                 (SIZE(mms_gsepos_3,/TYPE) NE 8) OR (SIZE(mms_gsepos_4,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,battpdt_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Filter data if user desires
;;----------------------------------------------------------------------------------------
IF (filt_on[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Define and check parameters
  ;;--------------------------------------------------------------------------------------
  bunix_1        = t_get_struc_unix(temp_magfv_1)
  bunix_2        = t_get_struc_unix(temp_magfv_2)
  bunix_3        = t_get_struc_unix(temp_magfv_3)
  bunix_4        = t_get_struc_unix(temp_magfv_4)
  ;;  Calculate sample rate [samples per second]
  srate          = sample_rate(bunix_1,/AVE)
  ;;  Make sure the lower frequency bound isn't above the Nyquist frequency
  test           = (frq_ran[0] LT (95d-2*srate[0]/2d0))
  IF (test[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Seems like the lower bound is okay but make sure it's at least zero
    ;;------------------------------------------------------------------------------------
    nn1            = N_ELEMENTS(bunix_1) & nn2 = N_ELEMENTS(bunix_2) & nn3 = N_ELEMENTS(bunix_3) & nn4 = N_ELEMENTS(bunix_4)
    frq_ran[0]     = frq_ran[0] > 0d0
    filt1          = vector_bandpass(temp_magfv_1.Y,srate[0],frq_ran[0],frq_ran[1],/MIDF)
    filt2          = vector_bandpass(temp_magfv_2.Y,srate[0],frq_ran[0],frq_ran[1],/MIDF)
    filt3          = vector_bandpass(temp_magfv_3.Y,srate[0],frq_ran[0],frq_ran[1],/MIDF)
    filt4          = vector_bandpass(temp_magfv_4.Y,srate[0],frq_ran[0],frq_ran[1],/MIDF)
    ;;------------------------------------------------------------------------------------
    ;;  Check output
    ;;------------------------------------------------------------------------------------
    szdb1          = SIZE(filt1,/DIMENSIONS)
    szdb2          = SIZE(filt2,/DIMENSIONS)
    szdb3          = SIZE(filt3,/DIMENSIONS)
    szdb4          = SIZE(filt4,/DIMENSIONS)
    testv          = is_a_3_vector(filt1,/NOMSSG) AND is_a_3_vector(filt2,/NOMSSG) AND $
                     is_a_3_vector(filt3,/NOMSSG) AND is_a_3_vector(filt4,/NOMSSG)
    testf          = (TOTAL(FINITE(filt1)) EQ TOTAL(FINITE(temp_magfv_1.Y)))       AND $
                     (TOTAL(FINITE(filt2)) EQ TOTAL(FINITE(temp_magfv_2.Y)))       AND $
                     (TOTAL(FINITE(filt3)) EQ TOTAL(FINITE(temp_magfv_3.Y)))       AND $
                     (TOTAL(FINITE(filt4)) EQ TOTAL(FINITE(temp_magfv_4.Y)))
    test           = (nn1[0] EQ szdb1[0]) AND (nn2[0] EQ szdb2[0]) AND $
                     (nn3[0] EQ szdb3[0]) AND (nn4[0] EQ szdb4[0]) AND $
                     testv[0] AND testf[0]
    IF (test[0]) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Seems like the output is okay --> redefine structures
      ;;----------------------------------------------------------------------------------
      temp_magfv_1   = {X:bunix_1,Y:filt1}
      temp_magfv_2   = {X:bunix_2,Y:filt2}
      temp_magfv_3   = {X:bunix_3,Y:filt3}
      temp_magfv_4   = {X:bunix_4,Y:filt4}
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  Clean up
    ;;------------------------------------------------------------------------------------
    dumb           = TEMPORARY(filt1) & dumb = TEMPORARY(filt2) & dumb = TEMPORARY(filt3) & dumb = TEMPORARY(filt4)
    dumb           = TEMPORARY(bunix_1) & dumb = TEMPORARY(bunix_2) & dumb = TEMPORARY(bunix_3) & dumb = TEMPORARY(bunix_4)
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Clip to time range of interest
;;----------------------------------------------------------------------------------------
bgse_clip_1    = trange_clip_data(temp_magfv_1,TRANGE=REFORM(trans[0,*]),PRECISION=3)
bgse_clip_2    = trange_clip_data(temp_magfv_2,TRANGE=REFORM(trans[1,*]),PRECISION=3)
bgse_clip_3    = trange_clip_data(temp_magfv_3,TRANGE=REFORM(trans[2,*]),PRECISION=3)
bgse_clip_4    = trange_clip_data(temp_magfv_4,TRANGE=REFORM(trans[3,*]),PRECISION=3)
bunix_1        = t_get_struc_unix(bgse_clip_1)
bunix_2        = t_get_struc_unix(bgse_clip_2)
bunix_3        = t_get_struc_unix(bgse_clip_3)
bunix_4        = t_get_struc_unix(bgse_clip_4)
bgsev_1        = bgse_clip_1.Y
bgsev_2        = bgse_clip_2.Y
bgsev_3        = bgse_clip_3.Y
bgsev_4        = bgse_clip_4.Y
;;----------------------------------------------------------------------------------------
;;  Trim off excess edge points
;;----------------------------------------------------------------------------------------
nn1            = N_ELEMENTS(bunix_1) & nn2 = N_ELEMENTS(bunix_2) & nn3 = N_ELEMENTS(bunix_3) & nn4 = N_ELEMENTS(bunix_4)
nmin           = MIN([nn1[0],nn2[0],nn3[0],nn4[0]],ln)
nmnodd         = (nmin[0] MOD 2) NE 0                   ;;  Check if odd or even
IF (ln[0] EQ 0) THEN IF (nmnodd[0]) THEN ind1 = LINDGEN(nn1[0] - 1L) ELSE ind1 = LINDGEN(nn1[0])
IF (ln[0] EQ 1) THEN IF (nmnodd[0]) THEN ind2 = LINDGEN(nn2[0] - 1L) ELSE ind2 = LINDGEN(nn2[0])
IF (ln[0] EQ 2) THEN IF (nmnodd[0]) THEN ind3 = LINDGEN(nn3[0] - 1L) ELSE ind3 = LINDGEN(nn3[0])
IF (ln[0] EQ 3) THEN IF (nmnodd[0]) THEN ind4 = LINDGEN(nn4[0] - 1L) ELSE ind4 = LINDGEN(nn4[0])
nmin           = ([N_ELEMENTS(ind1),N_ELEMENTS(ind2),N_ELEMENTS(ind3),N_ELEMENTS(ind4)])[ln[0]]
ndif           = [nn1[0],nn2[0],nn3[0],nn4[0]] - nmin[0]
IF (ln[0] NE 0) THEN ind1 = LINDGEN(nmin[0]) + ndif[0]/2L
IF (ln[0] NE 1) THEN ind2 = LINDGEN(nmin[0]) + ndif[1]/2L
IF (ln[0] NE 2) THEN ind3 = LINDGEN(nmin[0]) + ndif[2]/2L
IF (ln[0] NE 3) THEN ind4 = LINDGEN(nmin[0]) + ndif[3]/2L
;;  Redefine parameters
bunix_1        = bunix_1[ind1]
bunix_2        = bunix_2[ind2]
bunix_3        = bunix_3[ind3]
bunix_4        = bunix_4[ind4]
bgsev_1        = bgsev_1[ind1,*]
bgsev_2        = bgsev_2[ind2,*]
bgsev_3        = bgsev_3[ind3,*]
bgsev_4        = bgsev_4[ind4,*]
;;----------------------------------------------------------------------------------------
;;  Resample data
;;----------------------------------------------------------------------------------------
;;  Resample position data
posi_clip_1    = t_resample_tplot_struc(mms_gsepos_1,bunix_1,/ISPLINE,/NO_EXTRAPOLATE,/IGNORE_INT)
posi_clip_2    = t_resample_tplot_struc(mms_gsepos_2,bunix_2,/ISPLINE,/NO_EXTRAPOLATE,/IGNORE_INT)
posi_clip_3    = t_resample_tplot_struc(mms_gsepos_3,bunix_3,/ISPLINE,/NO_EXTRAPOLATE,/IGNORE_INT)
posi_clip_4    = t_resample_tplot_struc(mms_gsepos_4,bunix_4,/ISPLINE,/NO_EXTRAPOLATE,/IGNORE_INT)
;;----------------------------------------------------------------------------------------
;;  Cross-correlate field data
;;----------------------------------------------------------------------------------------
;;  Define index shift array
nshft          = nmin[0] - 3L
jshft          = LINDGEN(nshft[0]) - nshft[0]/2L
;;  Cross-correlation between 1 and 2
bx_12_cc       = C_CORRELATE(bgsev_1[*,0],bgsev_2[*,0],jshft,/DOUBLE)
by_12_cc       = C_CORRELATE(bgsev_1[*,1],bgsev_2[*,1],jshft,/DOUBLE)
bz_12_cc       = C_CORRELATE(bgsev_1[*,2],bgsev_2[*,2],jshft,/DOUBLE)
;;  Cross-correlation between 1 and 3
bx_13_cc       = C_CORRELATE(bgsev_1[*,0],bgsev_3[*,0],jshft,/DOUBLE)
by_13_cc       = C_CORRELATE(bgsev_1[*,1],bgsev_3[*,1],jshft,/DOUBLE)
bz_13_cc       = C_CORRELATE(bgsev_1[*,2],bgsev_3[*,2],jshft,/DOUBLE)
;;  Cross-correlation between 1 and 4
bx_14_cc       = C_CORRELATE(bgsev_1[*,0],bgsev_4[*,0],jshft,/DOUBLE)
by_14_cc       = C_CORRELATE(bgsev_1[*,1],bgsev_4[*,1],jshft,/DOUBLE)
bz_14_cc       = C_CORRELATE(bgsev_1[*,2],bgsev_4[*,2],jshft,/DOUBLE)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Determine the best time lag
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Shift between 1 and 2
mx_bx12_cc     = MAX(ABS(bx_12_cc),/NAN,ix_bx12)
mx_by12_cc     = MAX(ABS(by_12_cc),/NAN,ix_by12)
mx_bz12_cc     = MAX(ABS(bz_12_cc),/NAN,ix_bz12)
;;  Shift between 1 and 3
mx_bx13_cc     = MAX(ABS(bx_13_cc),/NAN,ix_bx13)
mx_by13_cc     = MAX(ABS(by_13_cc),/NAN,ix_by13)
mx_bz13_cc     = MAX(ABS(bz_13_cc),/NAN,ix_bz13)
;;  Shift between 1 and 4
mx_bx14_cc     = MAX(ABS(bx_14_cc),/NAN,ix_bx14)
mx_by14_cc     = MAX(ABS(by_14_cc),/NAN,ix_by14)
mx_bz14_cc     = MAX(ABS(bz_14_cc),/NAN,ix_bz14)
;;  Find the maximum CC coefficient to use as the correct shift index value
mx_cc_12       = MAX([mx_bx12_cc[0],mx_by12_cc[0],mx_bz12_cc[0]],ix_mx_12)
mx_cc_13       = MAX([mx_bx13_cc[0],mx_by13_cc[0],mx_bz13_cc[0]],ix_mx_13)
mx_cc_14       = MAX([mx_bx14_cc[0],mx_by14_cc[0],mx_bz14_cc[0]],ix_mx_14)
mx_cc_ij       = [mx_cc_12[0],mx_cc_13[0],mx_cc_14[0]]
;;  Define proper shift value and corresponding array index
ii_b_12        = ([ix_bx12[0],ix_by12[0],ix_bz12[0]])[ix_mx_12[0]]
ii_b_13        = ([ix_bx13[0],ix_by13[0],ix_bz13[0]])[ix_mx_13[0]]
ii_b_14        = ([ix_bx14[0],ix_by14[0],ix_bz14[0]])[ix_mx_14[0]]
jshft_arr      = [jshft[ii_b_12[0]],jshft[ii_b_13[0]],jshft[ii_b_14[0]]]
;;----------------------------------------------------------------------------------------
;;  Shift applies to first
;;    --> add or subtract JSHFT sample periods to first array times to make data match up
;;    --> ∆t_12 = (t_2 - t_1)
;;      --> t_1 = MEAN(t_1) + JSHFT[0]*T_peri[0]
;;      --> t_2 = MEAN(t_2)
;;----------------------------------------------------------------------------------------
;;  Calculate sample rate [samples per second]
srate          = sample_rate(bunix_1,/AVE)
speri          = 1d0/srate[0]
;;  Define midpoint times for each spacecraft (SC1 will have 3)
t_234          = [MEAN(bunix_2),MEAN(bunix_3),MEAN(bunix_4)]
t_12_j         = REPLICATE(d,3L)
FOR k=0L, 2L DO t_12_j[k] = MEAN(bunix_1) + speri[0]*jshft_arr[k[0]]
;;  Define dummy arrays
;;  [P,S,V] {P = # of perturbed pts, S = # of SC, V = # of vector components}
t_1j_all       = REPLICATE(d,5L,4L,3L)
FOR k=0L, 3L DO BEGIN
  FOR j=0L, 2L DO BEGIN
    IF (k EQ 0) THEN t_1j_all[*,k,j] = t_12_j[j]     + pert[usearr]
    IF (k EQ 1) THEN t_1j_all[*,k,j] = t_234[k - 1L] + pert[usearr]
    IF (k EQ 2) THEN t_1j_all[*,k,j] = t_234[k - 1L] + pert[usearr]
    IF (k EQ 3) THEN t_1j_all[*,k,j] = t_234[k - 1L] + pert[usearr]
  ENDFOR
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Re-interpolate positions to new times
;;----------------------------------------------------------------------------------------
d_spl_12       = t_resample_tplot_struc(mms_gsepos_1,t_12_j[0] + pert,/ISPLINE,/NO_EXTRAPOLATE,/IGNORE_INT)
d_spl_13       = t_resample_tplot_struc(mms_gsepos_1,t_12_j[1] + pert,/ISPLINE,/NO_EXTRAPOLATE,/IGNORE_INT)
d_spl_14       = t_resample_tplot_struc(mms_gsepos_1,t_12_j[2] + pert,/ISPLINE,/NO_EXTRAPOLATE,/IGNORE_INT)
d_spl_2        = t_resample_tplot_struc(mms_gsepos_2, t_234[0] + pert,/ISPLINE,/NO_EXTRAPOLATE,/IGNORE_INT)
d_spl_3        = t_resample_tplot_struc(mms_gsepos_3, t_234[1] + pert,/ISPLINE,/NO_EXTRAPOLATE,/IGNORE_INT)
d_spl_4        = t_resample_tplot_struc(mms_gsepos_4, t_234[2] + pert,/ISPLINE,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Define dummy arrays
;;  [P,S,V] {P = # of perturbed pts, S = # of SC, V = # of vector components}
new_p1j          = REPLICATE(d,5L,3L,3L)
new_p234         = REPLICATE(d,5L,3L,3L)
new_posi         = REPLICATE(d,5L,4L,3L)
new_unix         = REPLICATE(d,5L,4L)
new_p1j[*,0L,*]  = REFORM(d_spl_12.Y[usearr,*])
new_p1j[*,1L,*]  = REFORM(d_spl_13.Y[usearr,*])
new_p1j[*,2L,*]  = REFORM(d_spl_14.Y[usearr,*])
new_p234[*,0L,*] = REFORM(d_spl_2.Y[usearr,*])
new_p234[*,1L,*] = REFORM(d_spl_3.Y[usearr,*])
new_p234[*,2L,*] = REFORM(d_spl_4.Y[usearr,*])
;;  Define output spacecraft median positions and times
new_posi[*,0L,*] = MEDIAN(new_p1j,DIMENSION=2)
FOR k=0L, 2L DO new_posi[*,(k + 1L),*] = new_p234[*,k,*]
new_unix[*,0L]   = MEDIAN(REFORM(t_1j_all[*,0L,*]),DIMENSION=2)
FOR k=1L, 3L DO new_unix[*,k]          = t_1j_all[*,k,0L]
;;----------------------------------------------------------------------------------------
;;  Define differences
;;----------------------------------------------------------------------------------------
;;  ∆r_ij = r_i - r_j
dr_12_12_all   = lbw_diff(REFORM(new_p1j[*,0L,*]),REFORM(new_p234[*,0L,*]),/NAN)
dr_12_13_all   = lbw_diff(REFORM(new_p1j[*,0L,*]),REFORM(new_p234[*,1L,*]),/NAN)
dr_12_14_all   = lbw_diff(REFORM(new_p1j[*,0L,*]),REFORM(new_p234[*,2L,*]),/NAN)
dr_13_12_all   = lbw_diff(REFORM(new_p1j[*,1L,*]),REFORM(new_p234[*,0L,*]),/NAN)
dr_13_13_all   = lbw_diff(REFORM(new_p1j[*,1L,*]),REFORM(new_p234[*,1L,*]),/NAN)
dr_13_14_all   = lbw_diff(REFORM(new_p1j[*,1L,*]),REFORM(new_p234[*,2L,*]),/NAN)
dr_14_12_all   = lbw_diff(REFORM(new_p1j[*,2L,*]),REFORM(new_p234[*,0L,*]),/NAN)
dr_14_13_all   = lbw_diff(REFORM(new_p1j[*,2L,*]),REFORM(new_p234[*,1L,*]),/NAN)
dr_14_14_all   = lbw_diff(REFORM(new_p1j[*,2L,*]),REFORM(new_p234[*,2L,*]),/NAN)
;;  ∆t_ij = t_i - t_j
dt_12_12_all   = lbw_diff(REFORM(t_1j_all[*,0L,0L]),REFORM(t_1j_all[*,1L,0L]),/NAN)
dt_12_13_all   = lbw_diff(REFORM(t_1j_all[*,0L,0L]),REFORM(t_1j_all[*,2L,0L]),/NAN)
dt_12_14_all   = lbw_diff(REFORM(t_1j_all[*,0L,0L]),REFORM(t_1j_all[*,3L,0L]),/NAN)
dt_13_12_all   = lbw_diff(REFORM(t_1j_all[*,0L,1L]),REFORM(t_1j_all[*,1L,1L]),/NAN)
dt_13_13_all   = lbw_diff(REFORM(t_1j_all[*,0L,1L]),REFORM(t_1j_all[*,2L,1L]),/NAN)
dt_13_14_all   = lbw_diff(REFORM(t_1j_all[*,0L,1L]),REFORM(t_1j_all[*,3L,1L]),/NAN)
dt_14_12_all   = lbw_diff(REFORM(t_1j_all[*,0L,2L]),REFORM(t_1j_all[*,1L,2L]),/NAN)
dt_14_13_all   = lbw_diff(REFORM(t_1j_all[*,0L,2L]),REFORM(t_1j_all[*,2L,2L]),/NAN)
dt_14_14_all   = lbw_diff(REFORM(t_1j_all[*,0L,2L]),REFORM(t_1j_all[*,3L,2L]),/NAN)
;;----------------------------------------------------------------------------------------
;;  Define tensors
;;----------------------------------------------------------------------------------------
dr_tens_12_all = REPLICATE(d,5L,3L,3L)
dr_tens_13_all = dr_tens_12_all
dr_tens_14_all = dr_tens_12_all
dt_tens_12_all = REFORM(dr_tens_12_all[*,*,0L])
dt_tens_13_all = dt_tens_12_all
dt_tens_14_all = dt_tens_12_all
FOR k=0L, 4L DO BEGIN
  ;;  (∆r_ij)_m = r_i,m - r_j,m
  dr_tens_12_all[k,*,*] = [[REFORM(dr_12_12_all[k,*])],[REFORM(dr_12_13_all[k,*])],[REFORM(dr_12_14_all[k,*])]]
  dr_tens_13_all[k,*,*] = [[REFORM(dr_13_12_all[k,*])],[REFORM(dr_13_13_all[k,*])],[REFORM(dr_13_14_all[k,*])]]
  dr_tens_14_all[k,*,*] = [[REFORM(dr_14_12_all[k,*])],[REFORM(dr_14_13_all[k,*])],[REFORM(dr_14_14_all[k,*])]]
  ;;  (∆t_ij)_m = t_i,m - t_j,m
  dt_tens_12_all[k,*]   = [[dt_12_12_all[k]],[dt_12_13_all[k]],[dt_12_14_all[k]]]
  dt_tens_13_all[k,*]   = [[dt_13_12_all[k]],[dt_13_13_all[k]],[dt_13_14_all[k]]]
  dt_tens_14_all[k,*]   = [[dt_14_12_all[k]],[dt_14_13_all[k]],[dt_14_14_all[k]]]
ENDFOR
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Decompose tensors
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  - Use LU decomposition to find (i.e., t_4sc_normal_calc.pro)
;;      A . X = B
;;        A_ijm = (∆r_ij)_m
;;        B_ijm = (t_i - t_j)_m
;;        X     = (g/|g|)/V_gr,sc
;;  - V_gr,sc = 1/|X| and (g/|g|) = X/|X|
;;  - V_gr,sc (g/|g|) = V_gr (g/|g|) + (g/|g|) . Vsw
;;       V_gr (g/|g|) = V_gr,sc (g/|g|) - [(g/|g|) . Vsw]
V_gr_12        = REPLICATE(d,5L,2L)      ;;  Speed along outward normal [distance units per second]
V_gr_13        = V_gr_12
V_gr_14        = V_gr_12
ghat_12        = REPLICATE(d,5L,3L,2L)   ;;  Outward normal unit vector [ICB]
ghat_13        = ghat_12
ghat_14        = ghat_12
dr_ten_str     = {T0:dr_tens_12_all,T1:dr_tens_13_all,T2:dr_tens_14_all}
dt_ten_str     = {T0:dt_tens_12_all,T1:dt_tens_13_all,T2:dt_tens_14_all}
nt             = N_TAGS(dr_ten_str)
FOR k=0L, 4L DO BEGIN
  dr_tensor      = {T0:REFORM(dr_tens_12_all[k,*,*]),T1:REFORM(dr_tens_13_all[k,*,*]),T2:REFORM(dr_tens_14_all[k,*,*])}
  dt_tensor      = {T0:REFORM(dt_tens_12_all[k,*,*]),T1:REFORM(dt_tens_13_all[k,*,*]),T2:REFORM(dt_tens_14_all[k,*,*])}
  struc          = lbw_lu_decomp_4sc_timing(dr_tensor,dt_tensor,DEL_R=1d0,DEL_T=50d-6,NOMSSG=nomssg)
  ;;  Define group speed [km/s, SCF] and wave unit vector
  V_gr_12[k,*]   = struc.VGR_SC_SPD[0L,*]
  V_gr_13[k,*]   = struc.VGR_SC_SPD[1L,*]
  V_gr_14[k,*]   = struc.VGR_SC_SPD[2L,*]
  ghat_12[k,*,0] =   REFORM(unit_vec(struc.GHAT_ICB[0L,*,0],/NAN))
  ghat_13[k,*,0] =   REFORM(unit_vec(struc.GHAT_ICB[1L,*,0],/NAN))
  ghat_14[k,*,0] =   REFORM(unit_vec(struc.GHAT_ICB[2L,*,0],/NAN))
  ghat_12[k,*,1] =   struc.GHAT_ICB[0L,*,1]
  ghat_13[k,*,1] =   struc.GHAT_ICB[1L,*,1]
  ghat_14[k,*,1] =   struc.GHAT_ICB[2L,*,1]
ENDFOR
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define median SCF stuff
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
Vgrv__scf      = REPLICATE(d,3L,2L)
Vgrs__scf      = REPLICATE(d,2L)
dumbv          = REPLICATE(d,5L,nd[0],3L)
ghat__scf      = Vgrv__scf
;;  Define group velocity unit vector [ICB]
dumbgx         = calc_val_uncert_t4scbwave(REFORM([ghat_12[*,0L,0L],ghat_13[*,0L,0L],ghat_14[*,0L,0L]]))
dumbgy         = calc_val_uncert_t4scbwave(REFORM([ghat_12[*,1L,0L],ghat_13[*,1L,0L],ghat_14[*,1L,0L]]))
dumbgz         = calc_val_uncert_t4scbwave(REFORM([ghat_12[*,2L,0L],ghat_13[*,2L,0L],ghat_14[*,2L,0L]]))
ghat__scf[*,0] = REFORM(unit_vec([dumbgx[0],dumbgy[0],dumbgz[0]],/NAN))
ghat__scf[0,1] = dumbgx[1]
ghat__scf[1,1] = dumbgy[1]
ghat__scf[2,1] = dumbgz[1]
;;  Define SCF group speed and associated velocity [km/s, ICB]
FOR i=0L, nd[0] - 1L DO BEGIN         ;;  ∂V_gr
  vgr1d          =        [[V_gr_12[*,0]],[V_gr_13[*,0]],[V_gr_14[*,0]]] + $
                   del[i]*[[V_gr_12[*,1]],[V_gr_13[*,1]],[V_gr_14[*,1]]]
  dumbv[*,i,*]   = vgr1d
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define SCF scalar group speed [km/s]
;;----------------------------------------------------------------------------------------
Vgrs__scf      = calc_val_uncert_t4scbwave(dumbv)
;;----------------------------------------------------------------------------------------
;;  Define SCF vector group velocity
;;----------------------------------------------------------------------------------------
dumbv          = REPLICATE(d,nd[0],nd[0],3L)
FOR l=0L, nd[0] - 1L DO BEGIN           ;;  ghat
  ghat                  = REFORM(unit_vec(ghat__scf[*,0L] + del[l]*ghat__scf[*,1L],/NAN))
  FOR i=0L, nd[0] - 1L DO BEGIN         ;;  ∂V_gr
    vgr1d          = Vgrs__scf[0] + del[i]*Vgrs__scf[1]
    dumbv[l,i,*]   = vgr1d[0]*ghat
  ENDFOR
ENDFOR
dumbgx         = calc_val_uncert_t4scbwave(dumbv[*,*,0])
dumbgy         = calc_val_uncert_t4scbwave(dumbv[*,*,1])
dumbgz         = calc_val_uncert_t4scbwave(dumbv[*,*,2])
Vgrv__scf[*,0] = REFORM([dumbgx[0],dumbgy[0],dumbgz[0]])
Vgrv__scf[0,1] = dumbgx[1]
Vgrv__scf[1,1] = dumbgy[1]
Vgrv__scf[2,1] = dumbgz[1]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Find rest frame group speed
;;    V_gr = V_gr,sc - Vup
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
IF (vbulk_on[0]) THEN BEGIN
  IF (delvb_on[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;  Calculate rest frame group velocity with ∂Vbulk included
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    Vgr_rest_120   = REPLICATE(d,5L,nd[0],nd[0],nd[0],3L)           ;;  [pert,ghat,V_gr,Vup,xyz]
    Vgr_rest_130   = Vgr_rest_120
    Vgr_rest_140   = Vgr_rest_120
    FOR l=0L, nd[0] - 1L DO BEGIN             ;;  ghat
      ghat                  = REFORM(unit_vec(ghat__scf[*,0L] + del[l]*ghat__scf[*,1L],/NAN))
      ghat2d                = REPLICATE(1d0,5L) # ghat
      FOR m=0L, nd[0] - 1L DO BEGIN           ;;  ∂Vup
        Vup1d  = REFORM(vswo + del[m]*dvsw)
        Vup2d  = REPLICATE(1d0,5L) # Vup1d
        FOR i=0L, nd[0] - 1L DO BEGIN         ;;  ∂V_gr,sc
          v12                     = (V_gr_12[*,0L] + del[i]*V_gr_12[*,1L]) # REPLICATE(1d0,3L)
          v13                     = (V_gr_13[*,0L] + del[i]*V_gr_13[*,1L]) # REPLICATE(1d0,3L)
          v14                     = (V_gr_14[*,0L] + del[i]*V_gr_14[*,1L]) # REPLICATE(1d0,3L)
          Vgr_rest_120[*,l,i,m,*] = (v12*ghat2d) - Vup2d
          Vgr_rest_130[*,l,i,m,*] = (v13*ghat2d) - Vup2d
          Vgr_rest_140[*,l,i,m,*] = (v14*ghat2d) - Vup2d
        ENDFOR
      ENDFOR
    ENDFOR
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;  Calculate rest frame group velocity without ∂Vbulk included
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    ;;------------------------------------------------------------------------------------
    Vgr_rest_120   = REPLICATE(d,5L,nd[0],nd[0],3L)                 ;;  [pert,ghat,V_gr,xyz]
    Vgr_rest_130   = Vgr_rest_120
    Vgr_rest_140   = Vgr_rest_120
    Vup2d          = REPLICATE(1d0,5L) # vswo
    FOR l=0L, nd[0] - 1L DO BEGIN           ;;  ghat
      ghat                  = REFORM(unit_vec(ghat__scf[*,0L] + del[l]*ghat__scf[*,1L],/NAN))
      ghat2d                = REPLICATE(1d0,5L) # ghat
      FOR i=0L, nd[0] - 1L DO BEGIN         ;;  ∂V_gr,sc
        v12                   = (V_gr_12[*,0L] + del[i]*V_gr_12[*,1L]) # REPLICATE(1d0,3L)
        v13                   = (V_gr_13[*,0L] + del[i]*V_gr_13[*,1L]) # REPLICATE(1d0,3L)
        v14                   = (V_gr_14[*,0L] + del[i]*V_gr_14[*,1L]) # REPLICATE(1d0,3L)
        Vgr_rest_120[*,l,i,*] = (v12*ghat2d) - Vup2d
        Vgr_rest_130[*,l,i,*] = (v13*ghat2d) - Vup2d
        Vgr_rest_140[*,l,i,*] = (v14*ghat2d) - Vup2d
      ENDFOR
    ENDFOR
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  Define rest frame group speeds and uncertainties [km/s, scalar]
  ;;--------------------------------------------------------------------------------------
  Vgrvrest_12    = REPLICATE(d,3L,2L)
  Vgrvrest_13    = Vgrvrest_12
  Vgrvrest_14    = Vgrvrest_12
  FOR k=0L, 2L DO BEGIN
    IF (delvb_on[0]) THEN BEGIN
      Vgrvrest_12[k,*] = calc_val_uncert_t4scbwave(Vgr_rest_120[*,*,*,*,k])
      Vgrvrest_13[k,*] = calc_val_uncert_t4scbwave(Vgr_rest_130[*,*,*,*,k])
      Vgrvrest_14[k,*] = calc_val_uncert_t4scbwave(Vgr_rest_140[*,*,*,*,k])
    ENDIF ELSE BEGIN
      Vgrvrest_12[k,*] = calc_val_uncert_t4scbwave(Vgr_rest_120[*,*,*,k])
      Vgrvrest_13[k,*] = calc_val_uncert_t4scbwave(Vgr_rest_130[*,*,*,k])
      Vgrvrest_14[k,*] = calc_val_uncert_t4scbwave(Vgr_rest_140[*,*,*,k])
    ENDELSE
  ENDFOR
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;  Define rest frame group speeds and uncertainties [km/s, ICB]
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  Vgrs_rest_120  = REPLICATE(d,nd[0],nd[0],nd[0])                      ;;  [pert,ghat,V_gr]
  Vgrs_rest_130  = Vgrs_rest_120
  Vgrs_rest_140  = Vgrs_rest_120
  FOR l=0L, nd[0] - 1L DO BEGIN         ;;  ghat
    ghat                  = REFORM(unit_vec(ghat__scf[*,0L] + del[l]*ghat__scf[*,1L],/NAN))
    ghat2d                = REPLICATE(1d0,5L) # ghat
    FOR i=0L, nd[0] - 1L DO BEGIN       ;;  V_gr
      v12                   = (V_gr_12[*,0L] + del[i]*V_gr_12[*,1L]) # REPLICATE(1d0,3L)
      v13                   = (V_gr_13[*,0L] + del[i]*V_gr_13[*,1L]) # REPLICATE(1d0,3L)
      v14                   = (V_gr_14[*,0L] + del[i]*V_gr_14[*,1L]) # REPLICATE(1d0,3L)
      Vgrs_rest_120[*,l,i]  = mag__vec(v12*ghat2d,/NAN)
      Vgrs_rest_130[*,l,i]  = mag__vec(v13*ghat2d,/NAN)
      Vgrs_rest_140[*,l,i]  = mag__vec(v14*ghat2d,/NAN)
    ENDFOR
  ENDFOR
  ;;--------------------------------------------------------------------------------------
  ;;  Reduce three sets of solutions to one
  ;;--------------------------------------------------------------------------------------
  dumbvv         = REPLICATE(d,nd[0],3L,3L)                      ;;  [V_gr,3solns,xyz]
  dumbv          = REPLICATE(d,nd[0],3L)
  dumbg          = dumbv
  Vgrv_rest      = dumbv[0L:2L,0L:1L]
  ghat_rest      = Vgrv_rest
  Vgrs_rest      = dumbv[0L:1L,0L]
  ;;  Calculate one-variable stats on results
  FOR k=0L, 2L DO BEGIN
    FOR i=0L, nd[0] - 1L DO BEGIN       ;;  V_gr
      v12                   = (Vgrvrest_12[k,0L] + del[i]*Vgrvrest_12[k,1L])
      v13                   = (Vgrvrest_13[k,0L] + del[i]*Vgrvrest_13[k,1L])
      v14                   = (Vgrvrest_14[k,0L] + del[i]*Vgrvrest_14[k,1L])
      dumbvv[i,0L,k]        = v12
      dumbvv[i,1L,k]        = v13
      dumbvv[i,2L,k]        = v14
    ENDFOR
  ENDFOR
  ;;  Define rest frame group velocities and uncertainties [km/s, ICB]
  FOR k=0L, 2L DO Vgrv_rest[k,*] = calc_val_uncert_t4scbwave(dumbvv[*,*,k])
;  Vgrv_rx        = [Vgrv_rest_120[*,*,0L],Vgrv_rest_130[*,*,0L],Vgrv_rest_140[*,*,0L]]
;  Vgrv_ry        = [Vgrv_rest_120[*,*,1L],Vgrv_rest_130[*,*,1L],Vgrv_rest_140[*,*,1L]]
;  Vgrv_rz        = [Vgrv_rest_120[*,*,2L],Vgrv_rest_130[*,*,2L],Vgrv_rest_140[*,*,2L]]
;  dumbgx         = calc_val_uncert_t4scbwave(Vgrv_rx)
;  dumbgy         = calc_val_uncert_t4scbwave(Vgrv_ry)
;  dumbgz         = calc_val_uncert_t4scbwave(Vgrv_rz)
;  ;;  Define rest frame group velocities and uncertainties [km/s, ICB]
;  Vgrv_rest[*,0] = REFORM([dumbgx[0],dumbgy[0],dumbgz[0]])
;  Vgrv_rest[0,1] = dumbgx[1]
;  Vgrv_rest[1,1] = dumbgy[1]
;  Vgrv_rest[2,1] = dumbgz[1]
  ;;  Perturb rest frame group velocities
  FOR i=0L, nd[0] - 1L DO BEGIN         ;;  ∂V_gr
    vgr1d          = Vgrv_rest[*,0] + del[i]*Vgrv_rest[*,1]
    vmag           = mag__vec(vgr1d,/NAN)
    dumbv[i,*]     = vmag[0]
    dumbg[i,*]     = REFORM(unit_vec(vgr1d,/NAN))
  ENDFOR
  ;;  Define scalar group speed [km/s] with uncertainty
  Vgrs_rest[0]   = MEDIAN(dumbv[*,0])
  Vgrs_rest[1]   = STDDEV(dumbv[*,0],/NAN)
  ghat_rest[*,0] = REFORM(unit_vec(MEDIAN(dumbg,DIMENSION=1),/NAN))
  ghat_rest[*,1] = STDDEV(dumbg,/NAN,DIMENSION=1)
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Cannot calculate rest frame group velocity
  ;;--------------------------------------------------------------------------------------
  Vgrv_rest      = REPLICATE(d,3L,2L)
  Vgrs_rest      = REPLICATE(d,2L)
  ghat_rest      = Vgrv_rest
ENDELSE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
tags           = ['UNIX','SC_POSI','VGR_SC_SPD','VGR_SC_VEC','VGR_RF_SPD','VGR_RF_VEC',$
                  'GHAT_SC_ICB','GHAT_RF_ICB','MAX_CC_IJ','CC_SHIFT_ARR']
struc          = CREATE_STRUCT(tags,new_unix,new_posi,Vgrs__scf,Vgrv__scf,Vgrs_rest,   $
                               Vgrv_rest,ghat__scf,ghat_rest,mx_cc_ij,jshft_arr)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
ex_time        = SYSTIME(1) - ex_start[0]
IF ~KEYWORD_SET(nomssg) THEN MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL

RETURN,struc[0]
END


