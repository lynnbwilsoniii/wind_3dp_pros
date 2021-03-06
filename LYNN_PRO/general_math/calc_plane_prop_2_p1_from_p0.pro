;+
;*****************************************************************************************
;
;  FUNCTION :   calc_plane_prop_2_p1_from_p0.pro
;  PURPOSE  :   This routine calculates the propagation time of an infinite plane from
;                 point P0 to point P1.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               unit_vec.pro
;               perturb_dot_prod_angle.pro
;               mag__vec.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               R_SC       :  [3]-Element [numeric] array defining the 3-vector for the
;                               point P0, i.e., the starting or observation point relative
;                               to the origin at [0,0,0]
;                               [e.g., km/s]
;               N_PL       :  [3]-Element [numeric] array defining the 3-vector of the
;                               unit normal to the infinite plane to be propagated
;               V_PL       :  Scalar [numeric] defining the speed of the plane along the
;                               unit normal
;                               [e.g., km]
;
;  EXAMPLES:    
;               [calling sequence]
;               dtarr = calc_plane_prop_2_p1_from_p0(r_sc,n_pl,v_pl [,ORIGIN=origin]       $
;                                                    [,D_R_SC=d_r_sc] [,D_N_PL=d_n_pl]     $
;                                                    [,D_V_PL=d_v_pl] [,T_SC_0=t_sc_0]     $
;                                                    [,R_P_OUT=r_p_out] [,D_R_OUT=d_r_out] $
;                                                    [,TARR_OUT=tarr_out]                  $
;                                                    [,PHI_OUT=phi_out]                    $
;                                                    [,/USE_MED] [,/USE_STAND] [,/USE_STDMN])
;
;  KEYWORDS:    
;               ORIGIN     :  [3]-Element [numeric] array defining the 3-vector for the
;                               origin relative to which all vectors herein are defined
;                               [Default = [0,0,0] ]
;               D_R_SC     :  [3]-Element [numeric] array defining the uncertainties for
;                               components of R_SC
;                               [Default = 1% of R_SC]
;               D_N_PL     :  [3]-Element [numeric] array defining the uncertainties for
;                               components of N_PL
;                               [Default = 1% of N_PL]
;               D_V_PL     :  Scalar [numeric] defining the uncertainty of V_PL
;                               [Default = 1% of V_PL]
;               T_SC_0     :  Scalar [double] defining the Unix time when the plane is at
;                               P0
;                               [Default = 0d0]
;               R_P_OUT    :  Set to a named variable to return the 3-vector from the
;                               ORIGIN to the infinite plane along the unit normal
;                                 Output = [2,3]-element array, [0,*] is vector and
;                                          [1,*] is the uncertainties
;               D_R_OUT    :  Set to a named variable to return the 3-vector displacement
;                               along the planar surface between R_SC and R_P_OUT[0,*]
;                                 Output = [2,3]-element array, [0,*] is vector and
;                                          [1,*] is the uncertainties
;               TARR_OUT   :  Set to a named variable to return the arrival time at the
;                               ORIGIN of the infinite plane in Unix time relative to
;                               T_SC_0
;                                 Output = [2]-element array, [0]([1]) is earliest(latest)
;               PHI_OUT    :  Set to a named variable to return the angle [deg] between
;                               R_SC and N_PL
;                                 Output = [2]-element array, [0] is the angle and
;                                          [1] is the uncertainty
;               USE_MED    :  If set, routine will use the median instead of the mean
;                               for the output angle values
;                               [Default = FALSE]
;               USE_STAND  :  If set, routine will use the standard deviation instead
;                               of the range for the output angle uncertainties
;                               [Default = FALSE]
;               USE_STDMN  :  If set, routine will use the standard deviation of the mean
;                               instead of the range for the output angle uncertainties
;                               [Default = FALSE]
;
;   CHANGED:  1)  Added keywords: USE_MED, USE_STAND, and USE_STDMN
;                                                                   [07/12/2018   v1.0.1]
;
;   NOTES:      
;               1)  The algorithm assumes the plane propagates along N_PL and is infinite
;                     in the orthogonal directions.
;
;                                Plane
;                                .
;                               .
;                              .
;                             .
;                            .
;                           .
;                          .
;                         .
;                        .
;                       .. .
;                      .  .    .
;                     .    .       .
;                    .      .          .     .
;                   .        .  PHI        . .
;                  .          .           ....  N_PL
;                 .            .
;                .              .
;          D_R  .                .
;              .                  .
;             .                    .  R_SC
;            .                      .
;           .                        .
;          .                          .
;         .                            .
;        .     .                        .
;       .           .                    .
;      .                 .                .
;     .               R_p     .            .
;    .                             .        .
;                                       .    .
;                                             X ORIGIN
;
;                     R_SC     = R_p + D_R
;                     Cos(PHI) = (R_SC . N_PL)/|R_SC|
;                     |R_p|    = |R_SC| Cos(PHI)
;                     ∆t       = -(R_p . N_PL)/|V_PL|
;
;                     The routine computes uncertainties from either user-defined or
;                     default values.
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/11/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/12/2018   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION calc_plane_prop_2_p1_from_p0,r_sc0,n_pl0,v_pl0,ORIGIN=origin,D_R_SC=d_r_sc,      $
                                      D_N_PL=d_n_pl,D_V_PL=d_v_pl,T_SC_0=t_sc_0,          $
                                      R_P_OUT=r_p_out,D_R_OUT=d_r_out,TARR_OUT=tarr_out,  $
                                      PHI_OUT=phi_out,USE_MED=use_med,USE_STAND=use_stand,$
                                      USE_STDMN=use_stdmn

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
pert           = [-1,0,1]
r_p_out        = REPLICATE(d,2L,3L)
d_r_out        = r_p_out
tarr_out       = REPLICATE(d,2L)
phi_out        = tarr_out
;;  Error messages
noinput_mssg   = 'No or incorrectly formatted input was supplied...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 3) OR (N_ELEMENTS(r_sc0) NE 3) OR                          $
                 (N_ELEMENTS(n_pl0) NE 3) OR (N_ELEMENTS(v_pl0) LT 1) OR                   $
                 (is_a_number(r_sc0,/NOMSSG) EQ 0) OR (is_a_number(n_pl0,/NOMSSG) EQ 0) OR $
                 (is_a_number(v_pl0,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define parameters
r_sc           = DOUBLE(REFORM(r_sc0,1,3))
n_sh           = unit_vec(DOUBLE(REFORM(n_pl0,1,3)))      ;;  Renormalize, just in case
vshn           = 1d0*ABS(v_pl0[0])
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check ORIGIN
test           = ((N_ELEMENTS(origin) EQ 3) AND is_a_number(origin,/NOMSSG))
IF (test[0]) THEN orig = DOUBLE(REFORM(origin,1,3)) ELSE orig = REPLICATE(0d0,1L,3L)
;;  Check D_R_SC
test           = ((N_ELEMENTS(d_r_sc) EQ 3) AND is_a_number(d_r_sc,/NOMSSG))
IF (test[0]) THEN drsc = DOUBLE(REFORM(d_r_sc,1,3)) ELSE drsc = 1d-2*r_sc
;;  Check D_N_PL
test           = ((N_ELEMENTS(d_n_pl) EQ 3) AND is_a_number(d_n_pl,/NOMSSG))
IF (test[0]) THEN dnsh = DOUBLE(REFORM(d_n_pl,1,3)) ELSE dnsh = 1d-2*ABS(n_sh)
;;  Check D_V_PL
test           = ((N_ELEMENTS(d_v_pl) GT 0) AND is_a_number(d_v_pl,/NOMSSG))
IF (test[0]) THEN dvsh = 1d0*ABS(d_v_pl[0]) ELSE dvsh = 1d-2*vshn[0]
;;  Check T_SC_0
test           = ((N_ELEMENTS(t_sc_0) GT 0) AND is_a_number(t_sc_0,/NOMSSG))
IF (test[0]) THEN t0 = DOUBLE(t_sc_0[0]) ELSE t0 = 0d0
;;  Check USE_MED
IF ((N_ELEMENTS(use_med) GE 1) AND KEYWORD_SET(use_med)) THEN med_on = 1b ELSE med_on = 0b
;;  Check USE_STAND
IF ((N_ELEMENTS(use_stand) GE 1) AND KEYWORD_SET(use_stand)) THEN stand_on = 1b ELSE stand_on = 0b
;;  Check USE_STDMN
IF ((N_ELEMENTS(use_stdmn) GE 1) AND KEYWORD_SET(use_stdmn)) THEN stdmn_on = 1b ELSE stdmn_on = 0b
IF (stdmn_on[0]) THEN stand_on = 0b  ;;  Make sure USE_STAND is off
;;----------------------------------------------------------------------------------------
;;  Calculate relevant parameters
;;
;;  n_sh  :  Unit normal vector of plane
;;  Vshn  :  Observation frame plane normal speed [km/s]
;;  R_p   :  Earth-to-plane vector parallel to plane normal [km]
;;  R_sc  :  Earth-to-P0 vector [km]
;;  ∆r    :  Displacement along planar surface between intersections of R_p and R_sc [km]
;;  phi   :  Angle between R_sc and n_sh [deg]
;;  ∆t    :  Transit time from spacecraft-to-Earth of plane
;;
;;    Cos(phi)  =  (R_sc . n_sh)/|R_sc|
;;    |R_p|     = |R_sc| Cos(phi)
;;    ∆t        = |R_sc| Cos(phi)/|Vshn|
;;----------------------------------------------------------------------------------------
;;  Adjust vectors so they are relative to new origin
r_sc          -= orig
;;  First, find PHI
phi_dphi       = perturb_dot_prod_angle(r_sc,n_sh,DELTA_V1=drsc,DELTA_V2=dnsh,USE_MED=med_on,USE_STAND=stand_on)
;;  Perturb R_sc by uncertainty to find perturbed |R_p|
rsc_pert       = DBLARR(3,3)
rpm_pert       = DBLARR(3,3)
tarr_pert      = DBLARR(3,3,3)
rpv_pert       = DBLARR(3,3,3,3)
phi_pert       = ((phi_dphi[0] + pert*phi_dphi[1]) > 0) MOD 18d1  ;;  Perturbed PHI
vsh_pert       = (vshn[0] + pert*dvsh[0]) > 0                     ;;  Perturbed Vshn
cph_pert       = COS(phi_pert*!DPI/18d1)
cph_sign       = sign(cph_pert)
FOR j=0L, 2L DO BEGIN
  temp          = r_sc + pert[j]*drsc
  rsc_pert[j,*] = temp
  rscmag        = mag__vec(temp,/NAN)
  FOR k=0L, 2L DO BEGIN
    ;;  Calculate |R_p| = |R_sc| Cos(phi)
    trp              = rscmag[0]*ABS(cph_pert[k])
    rpm_pert[j,k]    = trp[0]
    ;;  Calculate ∆t = -1*Sign(R_p . n_sh)*|R_sc| Cos(phi)/|Vshn|
    tar              = (trp[0]/vsh_pert)*(-1d0*cph_sign[k])
    tarr_pert[j,k,*] = tar
    FOR i=0L, 2L DO BEGIN
      tnsh               = n_sh + pert[i]*dnsh
      ;;  Calculate R_p = |R_p|*n_sh
      rpv_pert[j,k,i,*]  = (trp[0]*cph_sign[k])*tnsh
    ENDFOR
  ENDFOR
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Calculate R_p and ∆r
;;----------------------------------------------------------------------------------------
;;  Calculate R_p = |R_p|*n_sh
IF (med_on[0]) THEN BEGIN
  rpvec_avg0     = MEDIAN(rpv_pert,/DOUBLE,DIMENSION=1)      ;;  [3,3,3]-Element array
  rpvec_avg1     = MEDIAN(rpvec_avg0,/DOUBLE,DIMENSION=1)    ;;  [3,3]-Element array
  rpvec_avg      = MEDIAN(rpvec_avg1,/DOUBLE,DIMENSION=1)    ;;  [3]-Element array
ENDIF ELSE BEGIN
  rpvec_avg0     = MEAN(rpv_pert,/NAN,/DOUBLE,DIMENSION=1)      ;;  [3,3,3]-Element array
  rpvec_avg1     = MEAN(rpvec_avg0,/NAN,/DOUBLE,DIMENSION=1)    ;;  [3,3]-Element array
  rpvec_avg      = MEAN(rpvec_avg1,/NAN,/DOUBLE,DIMENSION=1)    ;;  [3]-Element array
ENDELSE
IF (stdmn_on[0]) THEN BEGIN
  ;;  Use standard deviation of the mean
  drp_x          = STDDEV(rpv_pert[*,*,*,0],/NAN,/DOUBLE)/SQRT(1d0*N_ELEMENTS(rpv_pert[*,*,*,0]))
  drp_y          = STDDEV(rpv_pert[*,*,*,1],/NAN,/DOUBLE)/SQRT(1d0*N_ELEMENTS(rpv_pert[*,*,*,1]))
  drp_z          = STDDEV(rpv_pert[*,*,*,2],/NAN,/DOUBLE)/SQRT(1d0*N_ELEMENTS(rpv_pert[*,*,*,2]))
ENDIF ELSE BEGIN
  IF (stand_on[0]) THEN BEGIN
    ;;  Use standard deviation
    drp_x          = STDDEV(rpv_pert[*,*,*,0],/NAN,/DOUBLE)
    drp_y          = STDDEV(rpv_pert[*,*,*,1],/NAN,/DOUBLE)
    drp_z          = STDDEV(rpv_pert[*,*,*,2],/NAN,/DOUBLE)
  ENDIF ELSE BEGIN
    ;;  Use range [default]
    drp_x          = ABS((MAX(rpv_pert[*,*,*,0],/NAN) - MIN(rpv_pert[*,*,*,0],/NAN)))/2d0
    drp_y          = ABS((MAX(rpv_pert[*,*,*,1],/NAN) - MIN(rpv_pert[*,*,*,1],/NAN)))/2d0
    drp_z          = ABS((MAX(rpv_pert[*,*,*,2],/NAN) - MIN(rpv_pert[*,*,*,2],/NAN)))/2d0
  ENDELSE
ENDELSE
;;  Calculate ∆r = R_sc - R_p
rp_x_pert      = rpvec_avg[0] + pert*drp_x[0]
rp_y_pert      = rpvec_avg[1] + pert*drp_y[0]
rp_z_pert      = rpvec_avg[2] + pert*drp_z[0]
dr_x_pert      = rsc_pert[*,0] - rp_x_pert
dr_y_pert      = rsc_pert[*,1] - rp_y_pert
dr_z_pert      = rsc_pert[*,2] - rp_z_pert
IF (stdmn_on[0]) THEN BEGIN
  ddr_x          = STDDEV(dr_x_pert,/NAN,/DOUBLE)/SQRT(1d0*N_ELEMENTS(dr_x_pert))
  ddr_y          = STDDEV(dr_y_pert,/NAN,/DOUBLE)/SQRT(1d0*N_ELEMENTS(dr_y_pert))
  ddr_z          = STDDEV(dr_z_pert,/NAN,/DOUBLE)/SQRT(1d0*N_ELEMENTS(dr_z_pert))
ENDIF ELSE BEGIN
  IF (stand_on[0]) THEN BEGIN
    ddr_x          = STDDEV(dr_x_pert,/NAN,/DOUBLE)
    ddr_y          = STDDEV(dr_y_pert,/NAN,/DOUBLE)
    ddr_z          = STDDEV(dr_z_pert,/NAN,/DOUBLE)
  ENDIF ELSE BEGIN
    ddr_x          = ABS((MAX(dr_x_pert,/NAN) - MIN(dr_x_pert,/NAN)))/2d0
    ddr_y          = ABS((MAX(dr_y_pert,/NAN) - MIN(dr_y_pert,/NAN)))/2d0
    ddr_z          = ABS((MAX(dr_z_pert,/NAN) - MIN(dr_z_pert,/NAN)))/2d0
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define outputs
;;----------------------------------------------------------------------------------------
;;  Define R_P_OUT
r_p_out[0,*]   = rpvec_avg
;r_p_out[0,0]   = r_p_x[0] & r_p_out[0,1] = r_p_y[0] & r_p_out[0,2] = r_p_z[0]
r_p_out[1,0]   = drp_x[0] & r_p_out[1,1] = drp_y[0] & r_p_out[1,2] = drp_z[0]
;;  Define D_R_OUT
IF (med_on[0]) THEN BEGIN
  d_r_out[0,0]   = MEDIAN(dr_x_pert,/DOUBLE) & d_r_out[0,1] = MEDIAN(dr_y_pert,/DOUBLE) & d_r_out[0,2] = MEDIAN(dr_z_pert,/DOUBLE)
ENDIF ELSE BEGIN
  d_r_out[0,0]   = MEAN(dr_x_pert,/NAN,/DOUBLE) & d_r_out[0,1] = MEAN(dr_y_pert,/NAN,/DOUBLE) & d_r_out[0,2] = MEAN(dr_z_pert,/NAN,/DOUBLE)
ENDELSE
d_r_out[1,0]   = ddr_x[0] & d_r_out[1,1] = ddr_y[0] & d_r_out[1,2] = ddr_z[0]
;;  Define TARR_OUT
tarr_ran       = [MIN(tarr_pert,/NAN),MAX(tarr_pert,/NAN)]
tarr_out       = t0[0] + tarr_ran
;;  Define PHI_OUT
phi_out        = REFORM(phi_dphi)
;;  Define return value
output         = tarr_ran
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END

































