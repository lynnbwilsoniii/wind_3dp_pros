;+
;*****************************************************************************************
;
;  FUNCTION :   vbulk_change_test_plot_str_form.pro
;  PURPOSE  :   This routine tests the structure format of the plotting structure used
;                 by and returned by general_cursor_select.pro.
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
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Vbulk Change IDL Libraries
;
;  INPUT:
;               PLOT_STR   :  Scalar [structure] that defines the scaling factors for the
;                               contour plot shown in window WINDN to be used by
;                               general_cursor_select.pro.  The structure must contain
;                               the following tags:
;                                 XSCALE  :  [2]-Element array defining the scale factors
;                                              for converting between X-NORMAL and X-DATA
;                                              coordinates
;                                 YSCALE  :  [2]-Element array defining the scale factors
;                                              for converting between Y-NORMAL and Y-DATA
;                                              coordinates
;                                 XFACT   :  Scalar defining a scale factor that was used
;                                              when plotting the data that defined XSCALE
;                                 YFACT   :  Scalar defining a scale factor that was used
;                                              when plotting the data that defined YSCALE
;
;  EXAMPLES:    
;               [calling sequence]
;               test = vbulk_change_test_plot_str_form(plot_str [,DAT_OUT=dat_out])
;
;  KEYWORDS:    
;               DAT_OUT    :  Set to a named variable to return a properly formatted
;                               version of PLOT_STR that has the expected structure tags
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

FUNCTION vbulk_change_test_plot_str_form,plot_str,DAT_OUT=dat_out

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define required tags
def_tags       = ['xscale','yscale','xfact','yfact']
def_nt         = N_ELEMENTS(def_tags)
;;  Initialize outputs
dat_out        = 0
;;  Dummy error messages
notstr1msg     = 'User must input PLOT_STR as a scalar IDL structure...'
notstr2msg     = 'PLOT_STR must be a scalar IDL structure...'
badstr_msg     = 'PLOT_STR must have the following structure tags:  XSCALE, YSCALE, XFACT, and YFACT'
badfor1msg     = 'The XSCALE tag within PLOT_STR must be a [2]-element [numeric] array of conversion factors...'
badfor2msg     = 'The YSCALE tag within PLOT_STR must be a [2]-element [numeric] array of conversion factors...'
badfor3msg     = 'The XFACT tag within PLOT_STR must be a scalar [numeric] scale factor...'
badfor4msg     = 'The YFACT tag within PLOT_STR must be a scalar [numeric] scale factor...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check for an input
test           = (N_ELEMENTS(plot_str)  EQ 0) OR (N_PARAMS() NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr1msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check input type
str            = plot_str[0]
test           = (SIZE(str,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr2msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Verify # of structure tags
tags           = STRLOWCASE(TAG_NAMES(str[0]))
nt             = N_ELEMENTS(tags)
test           = (nt[0] LT def_nt[0])
IF (test[0]) THEN BEGIN
  MESSAGE,badstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Verify structure tag minimum requirements
xscl           = struct_value(str,def_tags[0],INDEX=i_xsc)
yscl           = struct_value(str,def_tags[1],INDEX=i_ysc)
xfac           = struct_value(str,def_tags[2],INDEX=i_xfc)
yfac           = struct_value(str,def_tags[3],INDEX=i_yfc)
;;  Check that XSCALE values exist and are numeric
test           = (is_a_number(xscl,/NOMSSG) EQ 0) OR (i_xsc[0] LT 0) OR (N_ELEMENTS(xscl) NE 2)
IF (test[0]) THEN BEGIN
  MESSAGE,badfor1msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check that YSCALE values exist and are numeric
test           = (is_a_number(yscl,/NOMSSG) EQ 0) OR (i_ysc[0] LT 0) OR (N_ELEMENTS(yscl) NE 2)
IF (test[0]) THEN BEGIN
  MESSAGE,badfor2msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check that XFACT values exist and are numeric
test           = (is_a_number(xfac,/NOMSSG) EQ 0) OR (i_xfc[0] LT 0) OR (N_ELEMENTS(xfac) NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,badfor3msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check that XFACT values exist and are numeric
test           = (is_a_number(yfac,/NOMSSG) EQ 0) OR (i_yfc[0] LT 0) OR (N_ELEMENTS(yfac) NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,badfor4msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define output structure to ensure proper format in future use
;;----------------------------------------------------------------------------------------
str_element,dat_out,def_tags[0],REFORM(xscl),/ADD_REPLACE
str_element,dat_out,def_tags[1],REFORM(yscl),/ADD_REPLACE
str_element,dat_out,def_tags[2],xfac[0],/ADD_REPLACE
str_element,dat_out,def_tags[3],yfac[0],/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END
