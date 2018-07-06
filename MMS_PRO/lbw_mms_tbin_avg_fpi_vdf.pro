;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_mms_tbin_avg_fpi_vdf.pro
;  PURPOSE  :   This routine averages adjacent VDFs from the FPI instruments on MMS
;                 within a user-defined time window DTIN using the tbin_avg.pro
;                 routine.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               lbw_test_mms_fpi_vdf_structure.pro
;               tbin_avg.pro
;               sample_rate.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT_ARR      :  [N]-Element [structure] array of MMS velocity
;                                 distribution functions (VDFs) from FPI DIS or DES
;               DTIN         :  Scalar [numeric] defining the new sample period [s] for
;                                 defining the output, uniformly spaced time stamps
;
;  EXAMPLES:    
;               [calling sequence]
;               tavg_struc = lbw_mms_tbin_avg_fpi_vdf(dat_arr, dtin [,TRANGE=trange] [,NAN_OUT=nan_out])
;
;  KEYWORDS:    
;               TRANGE       :  [2]-Element [double] array specifying the Unix time range
;                                 on which to define the new uniform time interval
;                                 [Default = [MIN(T_IN),MAX(T_IN)] ]
;               NAN_OUT      :  If set, bins with no data are set to NaNs on output
;                                 [Default = FALSE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The data structures for the MMS FPI VDFs are originally loaded into
;                     TPLOT with the routine mms_load_fpi.pro and then modified with
;                     the routine mms_get_fpi_dist.pro.  The modifying routine is
;                     critical because the angles from the initial part are the
;                     instrument look directions but are converted to the particle
;                     trajectories by mms_get_fpi_dist.pro.  Then the user should have
;                     called add_velmagscpot_to_mms_dist.pro to add the VELOCITY, MAGF,
;                     and SC_POT tags the the VDFs.
;               2)  See also:  mms_get_fpi_dist.pro (SPEDAS), add_velmagscpot_to_mms_dist.pro,
;                              lbw_mms_energy_angle_to_velocity.pro
;               3)  ***  Be careful not to eat up too much of your RAM  ***
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

FUNCTION lbw_mms_tbin_avg_fpi_vdf,dat_arr,dtin,TRANGE=trange,NAN_OUT=nan_out

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
notstr_msg     = 'Must be an IDL structure...'
notvdf_msg     = 'Must be an ion velocity distribution IDL structure...'
badthm_msg     = 'For MMS FPI structures, they must be modified using at least mms_get_fpi_dist.pro prior to calling this routine'
not3dp_msg     = 'Must be an ion velocity distribution IDL structure from MMS/FPI...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN RETURN,0b
str            = dat_arr[0]   ;;  in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,notstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
dat            = str[0]
test           = lbw_test_mms_fpi_vdf_structure(dat[0],/NOMSSG,POST=post)
IF (~test[0] OR post[0] LT 1) THEN BEGIN
  MESSAGE,badthm_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define parameters
des_ts         = dat_arr.TIME
des_te         = dat_arr.END_TIME
des_ta         = (des_ts + des_te)/2d0
;;----------------------------------------------------------------------------------------
;;  Time-average DATA, BINS, ENERGY, DENERGY, PHI, DPHI, THETA, and DTHETA
;;----------------------------------------------------------------------------------------
arr__4d        = TRANSPOSE(dat_arr.DATA,[3,0,1,2])
tavg_data      = tbin_avg(des_ta,arr__4d,dtin,TRANGE=trange,NAN_OUT=nan_out)
IF (SIZE(str,/TYPE) NE 8L) THEN RETURN,0b
arr__4d        = TRANSPOSE(dat_arr.BINS,[3,0,1,2])
tavg_bins      = tbin_avg(des_ta,arr__4d,dtin,TRANGE=trange,NAN_OUT=nan_out)
arr__4d        = TRANSPOSE(dat_arr.ENERGY,[3,0,1,2])
tavg_ener      = tbin_avg(des_ta,arr__4d,dtin,TRANGE=trange,NAN_OUT=nan_out)
arr__4d        = TRANSPOSE(dat_arr.DENERGY,[3,0,1,2])
tavg_denr      = tbin_avg(des_ta,arr__4d,dtin,TRANGE=trange,NAN_OUT=nan_out)
arr__4d        = TRANSPOSE(dat_arr.PHI,[3,0,1,2])
tavg__phi      = tbin_avg(des_ta,arr__4d,dtin,TRANGE=trange,NAN_OUT=nan_out)
arr__4d        = TRANSPOSE(dat_arr.DPHI,[3,0,1,2])
tavg_dphi      = tbin_avg(des_ta,arr__4d,dtin,TRANGE=trange,NAN_OUT=nan_out)
arr__4d        = TRANSPOSE(dat_arr.THETA,[3,0,1,2])
tavg__the      = tbin_avg(des_ta,arr__4d,dtin,TRANGE=trange,NAN_OUT=nan_out)
arr__4d        = TRANSPOSE(dat_arr.DTHETA,[3,0,1,2])
tavg_dthe      = tbin_avg(des_ta,arr__4d,dtin,TRANGE=trange,NAN_OUT=nan_out)
;;----------------------------------------------------------------------------------------
;;  Define new structures for output
;;----------------------------------------------------------------------------------------
n_out          = N_ELEMENTS(tavg_data.X)
dumb           = dat_arr[0]
out            = REPLICATE(dumb[0],n_out[0])
;;  New start/end times
srate0         = sample_rate(tavg_data.X,/AVERAGE,OUT_MED_AVG=medavg)
speri          = 1d0/medavg[0]
ts_new         = tavg_data.X - speri[0]/2d0
te_new         = tavg_data.X + speri[0]/2d0
;;  Define new values in structures
out.TIME       = ts_new
out.END_TIME   = te_new
out.DATA       = FLOAT(TRANSPOSE(tavg_data.Y,[1,2,3,0]))
out.BINS       = FLOAT(TRANSPOSE(tavg_bins.Y,[1,2,3,0]))
out.ENERGY     = FLOAT(TRANSPOSE(tavg_ener.Y,[1,2,3,0]))
out.DENERGY    = FLOAT(TRANSPOSE(tavg_denr.Y,[1,2,3,0]))
out.PHI        = FLOAT(TRANSPOSE(tavg__phi.Y,[1,2,3,0]))
out.DPHI       = FLOAT(TRANSPOSE(tavg_dphi.Y,[1,2,3,0]))
out.THETA      = FLOAT(TRANSPOSE(tavg__the.Y,[1,2,3,0]))
out.DTHETA     = FLOAT(TRANSPOSE(tavg_dthe.Y,[1,2,3,0]))
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,out
END

