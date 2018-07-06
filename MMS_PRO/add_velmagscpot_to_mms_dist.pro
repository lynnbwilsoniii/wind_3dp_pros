;+
;*****************************************************************************************
;
;  FUNCTION :   add_velmagscpot_to_mms_dist.pro
;  PURPOSE  :   This routine adds the following tags to the MMS VDF structures returned
;                 by the routine mms_get_fpi_dist.pro
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               test_tplot_handle.pro
;               t_resample_tplot_struc.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries; and
;               2)  latest SPEDAS libraries
;
;  INPUT:
;               DAT_ARR  :  [N]-Element [structure] array of MMS velocity distributions
;                             from FPI DIS or DES
;               MAG_TPN  :  Scalar [string] TPLOT handle that holds the magnetic field
;                             3-vector data [nT] in DBCS or DMPA coordinates
;               VEL_TPN  :  Scalar [string] TPLOT handle that holds the bulk flow
;                             velocity 3-vector data [km/s] in DBCS or DMPA coordinates
;               SCP_TPN  :  Scalar [string] TPLOT handle that holds the scalar spacecraft
;                             potential data [eV]
;
;  EXAMPLES:    
;               [calling sequence]
;               new_str = add_velmagscpot_to_mms_dist(dat_arr,mag_tpn,vel_tpn,scp_tpn)
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
;   CREATED:  07/02/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/02/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION add_velmagscpot_to_mms_dist,dat_arr,mag_tpn,vel_tpn,scp_tpn

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
no_inpt_msg    = 'User must supply an IDL structure and 3 TPLOT handles...'
badtpns_msg    = 'Incorrect input format:  [MAG,VEL,SCP]_TPN must be valid TPLOT handles'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 4) OR (SIZE(dat_arr,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
ndat           = N_ELEMENTS(dat_arr)
;;  Check TPLOT handles
test_mag       = test_tplot_handle(mag_tpn,TPNMS=tpn_mag,GIND=gind_mag)
test_vel       = test_tplot_handle(vel_tpn,TPNMS=tpn_vel,GIND=gind_vel)
test_scp       = test_tplot_handle(scp_tpn,TPNMS=tpn_scp,GIND=gind_scp)
IF (~test_mag[0] OR ~test_vel[0] OR ~test_scp[0]) THEN BEGIN
  MESSAGE,badtpns_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get TPLOT data
;;----------------------------------------------------------------------------------------
get_data,tpn_mag[0],DATA=temp_magf,DLIMIT=dlim_magf,LIMIT=lim_magf
get_data,tpn_vel[0],DATA=temp_vblk,DLIMIT=dlim_vblk,LIMIT=lim_vblk
get_data,tpn_scp[0],DATA=temp_scpt,DLIMIT=dlim_scpt,LIMIT=lim_scpt
;;----------------------------------------------------------------------------------------
;;  Interpolate Bo, Vbulk, and SC Potential to D[E,I]S times
;;----------------------------------------------------------------------------------------
des_ts         = dat_arr.TIME
des_te         = dat_arr.END_TIME
des_ta         = (des_ts + des_te)/2d0
magf_des_t     = t_resample_tplot_struc(temp_magf,des_ta,/NO_EXTRAPOLATE,/IGNORE_INT)
vblk_des_t     = t_resample_tplot_struc(temp_vblk,des_ta,/NO_EXTRAPOLATE,/IGNORE_INT)
scpt_des_t     = t_resample_tplot_struc(temp_scpt,des_ta,/NO_EXTRAPOLATE,/IGNORE_INT)
;;----------------------------------------------------------------------------------------
;;  Add tags to D[E,I]S structures
;;----------------------------------------------------------------------------------------
dumb           = dat_arr[0]
str_element,dumb,'VELOCITY',REPLICATE(0d0,3L),/ADD_REPLACE
str_element,dumb,    'MAGF',REPLICATE(0d0,3L),/ADD_REPLACE
str_element,dumb,  'SC_POT',              0d0,/ADD_REPLACE
des_vdf        = REPLICATE(dumb[0],ndat[0])
FOR j=0L, ndat[0] - 1L DO BEGIN
  temp       = dat_arr[j]
  temp_b     = REFORM(magf_des_t.Y[j,*])
  temp_v     = REFORM(vblk_des_t.Y[j,*])
  temp_s     = scpt_des_t.Y[j]
  str_element,temp,'VELOCITY',   temp_v,/ADD_REPLACE
  str_element,temp,    'MAGF',   temp_b,/ADD_REPLACE
  str_element,temp,  'SC_POT',temp_s[0],/ADD_REPLACE
  des_vdf[j] = temp[0]
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,des_vdf
END
