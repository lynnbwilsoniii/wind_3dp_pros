;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_mms_compute_counts_from_f_df.pro
;  PURPOSE  :   This routine computes the particle counts from the data and error,
;                 assuming a Poisson statistical approach was used for the errors.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               test_tplot_handle.pro
;               get_data.pro
;               tplot_struct_format_test.pro
;               t_get_struc_unix.pro
;               delete_variable.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries; and
;               2)  latest SPEDAS libraries
;
;  INPUT:
;               DAT_TPN    :  Scalar [string or integer] defining the TPLOT handle
;                                 associated with the particle data
;                                 [e.g., 'mms1_des_dist_brst']
;               ERR_TPN    :  Scalar [string or integer] defining the TPLOT handle
;                                 associated with the error in the particle data
;                                 [e.g., 'mms1_des_disterr_brst']
;
;  EXAMPLES:    
;               [calling sequence]
;               cnt_str = lbw_mms_compute_counts_from_f_df(dat_tpn, err_tpn          $
;                                                          [,FACTORS=factors]        )
;
;  KEYWORDS:    
;               FACTORS    :  Set to a named variable to return an [N,A,P,E]-element
;                               array of conversion factors between counts and the
;                               data in phase space density units [e.g., # s^(+3) cm^(-6)]
;                               where N = # of time stamps, A = # of azimuthal angle
;                               bins, P = # of poloidal/latitudinal angle bins, and E =
;                               # of energy bins.
;                               [output units = length^(+6) time^(-3)]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The units must be the same for DAT_TPN and ERR_TPN
;               2)  See also:  mms_get_fpi_dist.pro (SPEDAS),
;                              add_velmagscpot_to_mms_dist.pro,
;                              lbw_mms_energy_angle_to_velocity.pro,
;                              tplot_struct_format_test.pro
;               3)  ***  Be careful not to eat up too much of your RAM  ***
;               4)  This routine does NOT check whether inputs are on a uniform time grid
;                     -->  Best to use output from mms_load_fpi.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/05/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/05/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_mms_compute_counts_from_f_df,dat_tpn,err_tpn,FACTORS=factors

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
nottpn_suf     = ' is not a valid TPLOT handle...'
nottps_suf     = ' does not contain a valid TPLOT structure...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN RETURN,0b
;;  Check TPLOT handles
test           = test_tplot_handle(dat_tpn,TPNMS=tpn_dat,GIND=gind_dat)
IF (~test[0]) THEN BEGIN
  MESSAGE,'DAT_TPN'+nottpn_suf[0],/CONTINUE,/INFORMATIONAL
  RETURN,0b
ENDIF
test           = test_tplot_handle(err_tpn,TPNMS=tpn_err,GIND=gind_err)
IF (~test[0]) THEN BEGIN
  MESSAGE,'ERR_TPN'+nottpn_suf[0],/CONTINUE,/INFORMATIONAL
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check TPLOT structures
;;----------------------------------------------------------------------------------------
;;  Get DATA
get_data,tpn_dat[0],DATA=temp_dat,DLIMIT=dlim_dat,LIMIT=lim_dat
test           = tplot_struct_format_test(temp_dat,TEST_V123=test_v123,/NOMSSG)
IF (~test[0] OR ~test_v123[0]) THEN BEGIN
  MESSAGE,'DAT_TPN'+nottps_suf[0],/CONTINUE,/INFORMATIONAL
  RETURN,0b
ENDIF
;;  Define DATA variables
data_t         = t_get_struc_unix(temp_dat)
data_v         = DOUBLE(temp_dat.Y)
;;  Clean up to save space
delete_variable,temp_dat,dlim_dat,lim_dat
;;  Get ERROR
get_data,tpn_err[0],DATA=temp_err,DLIMIT=dlim_err,LIMIT=lim_err
test           = tplot_struct_format_test(temp_err,TEST_V123=test_v123,/NOMSSG)
IF (~test[0] OR ~test_v123[0]) THEN BEGIN
  MESSAGE,'ERR_TPN'+nottps_suf[0],/CONTINUE,/INFORMATIONAL
  RETURN,0b
ENDIF
;;  Define ERROR variables
err__v         = DOUBLE(temp_err.Y)
;;  Clean up to save space
delete_variable,temp_err,dlim_err,lim_err
;;----------------------------------------------------------------------------------------
;;  Calculate counts
;;
;;    Assume the following holds:
;;       f = A * C
;;      df = A * C^(1/2)
;;    where A is a unit conversion factor and C is the number of counts.  Then we can
;;    show that:
;;       C = (f/df)^2
;;       A = (f/C) = df^2/f
;;----------------------------------------------------------------------------------------
counts         = ((data_v/err__v)^2d0) > 0d0
factors        = (data_v/counts)
;;  Clean up to save space
delete_variable,data_v,err__v
;;  Define output structure
output         = {X:data_t,Y:counts}
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END

