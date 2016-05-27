;+
;*****************************************************************************************
;
;  FUNCTION :   get_power_of_ten_ticks.pro
;  PURPOSE  :   This routine returns a structure containing the [X,Y,Z]-tick mark tags
;                 and associated values.  The routine does not assume the component for
;                 which the input RANGE corresponds, rather it just returns a structure
;                 with copies of the values for the different component tags.  This
;                 format allows for easier extraction and use of the output structure
;                 in plotting routines.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               sign.pro
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               RANGE  :  [2]-Element [numeric] array specifying the range of values
;                           overwhich to define tick marks for ploting on logarithmic
;                           scales in IDL
;
;  EXAMPLES:    
;               test = get_power_of_ten_ticks(range)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [07/23/2015   v1.0.0]
;             2)  Now calls test_plot_axis_range.pro
;                                                                   [10/23/2015   v1.0.1]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/21/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/23/2015   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_power_of_ten_ticks,range

;;  Let IDL know that the following are functions
FORWARD_FUNCTION sign, is_a_number, test_plot_axis_range
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define some constants, dummy variables, and defaults
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Dummy variables
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;--------------------------------------------
;;  Setup dummy log-scale tick marks
;;--------------------------------------------
nt_pow0        = 50L
ntp            = (2L*nt_pow0[0]) + 1L
tickpows       = DINDGEN(ntp[0]) - (1d0*nt_pow0[0])
ticksigns      = sign(tickpows)
signs_str      = ['-','+']
xytns_str      = STRARR(N_ELEMENTS(ticksigns))
good_plus      = WHERE(ticksigns GE 0,gdpl,COMPLEMENT=good__neg,NCOMPLEMENT=gdng)
IF (gdng GT 0) THEN xytns_str[good__neg] = signs_str[0]
IF (gdpl GT 0) THEN xytns_str[good_plus] = signs_str[1]
xytv           = 1d1^tickpows
tickpow_str    = xytns_str+STRTRIM(STRING(ABS(tickpows),FORMAT='(I2.2)'),2)
xytn           = '10!U'+tickpow_str+'!N'
;;--------------------------------------------
;;  Dummy error messages
;;--------------------------------------------
noinpt_msg     = 'User must supply RANGE:  [2]-Element [numeric] array'
badinpt_msg    = 'RANGE must be a [2]-element [numeric] array with unique values'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (is_a_number(range,/NOMSSG) EQ 0) OR    $
                 (N_ELEMENTS(range) NE 2)
IF (test) THEN BEGIN
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (test_plot_axis_range(range) EQ 0)
;test           = (range[0] EQ range[1])
IF (test) THEN BEGIN
  MESSAGE,badinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define good tick marks
;;----------------------------------------------------------------------------------------
def_xyran      = range                   ;;  test_plot_axis_range.pro sorts the input RANGE values
;def_xyran      = range[SORT(range)]
good_tv        = WHERE(xytv GE def_xyran[0] AND xytv LE def_xyran[1],gdtv)
IF (gdtv EQ 0) THEN BEGIN
  ;;  XYRANGE between two powers of 10
  ;;    --> expand
  topbot         = [0L,N_ELEMENTS(xytv) - 1L]
  addsub         = [1,-1]
  vind           = VALUE_LOCATE(xytv,def_xyran[0]) > 0
  check          = WHERE(vind[0] EQ topbot,ch)
  IF (ch GT 0) THEN vind += addsub[check[0]]
  ;;  Redefine indices enclosing XYRANGE
  good_tv        = vind[0] + [-1,1]
ENDIF
xytv_0         = xytv[good_tv]
xytn_0         = xytn[good_tv]
xyts_0         = N_ELEMENTS(xytv_0) - 1L
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
tag_suff       = ['TICKNAME','TICKV','TICKS']
tags           = ['X'+tag_suff,'Y'+tag_suff,'Z'+tag_suff]
struc          = CREATE_STRUCT(tags,xytn_0,xytv_0,xyts_0[0],xytn_0,xytv_0,xyts_0[0],$
                                    xytn_0,xytv_0,xyts_0[0])
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END



