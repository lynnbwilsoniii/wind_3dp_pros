;+
;*****************************************************************************************
;
;  FUNCTION :   vbulk_change_test_vdf_str_form.pro
;  PURPOSE  :   This routine tests the structure format of the input velocity
;                 distribution functions (VDFs).
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               struct_value.pro
;               is_a_number.pro
;               is_a_3_vector.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Vbulk Change IDL Libraries
;
;  INPUT:
;               DAT        :  Scalar [structure] containing a particle velocity
;                               distribution function (VDF) with the following
;                               structure tags:
;                                 VDF     :  [N]-Element [float/double] array defining
;                                              the VDF in units of phase space density
;                                              [i.e., # s^(+3) km^(-3) cm^(-3)]
;                                 VELXYZ  :  [N,3]-Element [float/double] array defining
;                                              the particle velocity 3-vectors for each
;                                              element of VDF
;                                              [km/s]
;
;  EXAMPLES:    
;               [calling sequence]
;               test = vbulk_change_test_vdf_str_form(dat [,DAT_OUT=dat_out])
;
;  KEYWORDS:    
;               DAT_OUT    :  Set to a named variable to return a properly formatted
;                               version of DAT that has the expected structure tags
;                               and dimensions
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This is meant to be called by other routines within the
;                     Vbulk Change library of routines
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/17/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/17/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION vbulk_change_test_vdf_str_form,dat,DAT_OUT=dat_out

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define required tags
def_tags       = ['vdf','velxyz']
;;  Initialize outputs
dat_out        = 0
;;  Dummy error messages
notstr_msg     = 'User must input DAT as a scalar IDL structure...'
notvdf_msg     = 'DAT must be a velocity distribution as an IDL structure...'
badstr_msg     = 'DAT must have the following structure tags:  VDF and VELXYZ'
badfor1msg     = 'The VDF tag within DAT must be an [N]-element [numeric] array of phase space densities...'
badfor2msg     = 'The VELXYZ tag within DAT must be an [N,3]-element [numeric] array of 3-vector velocities...'
badfor_msg     = 'VDF and VELXYZ must have the same number of elements in their first dimension...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check for an input
test           = (N_ELEMENTS(dat)  EQ 0) OR (N_PARAMS() NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check input type
str            = dat[0]
test           = (SIZE(str,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,notvdf_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Verify # of structure tags
tags           = STRLOWCASE(TAG_NAMES(str[0]))
nt             = N_ELEMENTS(tags)
test           = (nt[0] LT 2)
IF (test[0]) THEN BEGIN
  MESSAGE,badstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Verify structure tag minimum requirements
test           = (TOTAL(tags EQ def_tags[0]) LT 1) OR (TOTAL(tags EQ def_tags[1]) LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,badstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Verify structure tag formats
;;  Check that VDF values exist and are numeric
vdf            = struct_value(str,def_tags[0],INDEX=i_vdf)
velxyz         = struct_value(str,def_tags[1],INDEX=i_vel)
test           = (is_a_number(vdf,/NOMSSG) EQ 0) OR (i_vdf[0] LT 0) OR (SIZE(vdf,/N_DIMENSIONS) NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,badfor1msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check that VELXYZ values exist and are numeric 3-vectors
test           = (is_a_3_vector(velxyz,V_OUT=v_out,/NOMSSG) EQ 0) OR (i_vel[0] LT 0) OR (SIZE(velxyz,/N_DIMENSIONS) NE 2)
IF (test[0]) THEN BEGIN
  MESSAGE,badfor2msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check that VELXYZ and VDF share the same value for N
n_vdf          = N_ELEMENTS(vdf)
n_vel          = N_ELEMENTS(v_out[*,0])
test           = (n_vdf[0] NE n_vel[0])
IF (test[0]) THEN BEGIN
  MESSAGE,badfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define output structure to ensure proper format in future use
;;----------------------------------------------------------------------------------------
str_element,dat_out,def_tags[0],REFORM(vdf),/ADD_REPLACE
str_element,dat_out,def_tags[1],v_out,/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END
