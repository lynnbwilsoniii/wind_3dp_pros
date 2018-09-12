;+
;*****************************************************************************************
;
;  FUNCTION :   t_calc_yrange.pro
;  PURPOSE  :   Calculates an appropriate YRANGE array for a given input TPLOT structure
;                 accounting for user-specified tests (e.g., log or linear scale).
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               tplot_struct_format_test.pro
;               is_a_number.pro
;               t_get_current_trange.pro
;               trange_clip_data.pro
;               lbw_calc_yrange.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TPSTRUC     :  Scalar [structure] defining a valid TPLOT structure for
;                                which the user wishes to determine an appropriate
;                                array for YRANGE
;
;  EXAMPLES:    
;               [calling sequence]
;               yran = t_calc_yrange(tpstruc [,/LOG] [,/USE_CURTR] [,/POSITIVE]        $
;                                    [,PERC_EX=perc_ex] [,MIN_VALUE=min_value]         $
;                                    [,MAX_VALUE=max_value])
;
;  KEYWORDS:    
;               LOG         :  If set, routine will assume data is plotted on a
;                                logarithmic scale and so will ensure at least one major
;                                tick mark (i.e., integer power of 10) is included in
;                                the output YRANGE array
;                                [Default = FALSE]
;               PERC_EX     :  Scalar [numeric] defining the percentage beyond the actual
;                                data range to include as padding
;                                [Default = 5e-2 for 5%]
;               USE_CURTR   :  If set, routine will only consider data values within the
;                                currently plotted TPLOT time range when defining the
;                                data range
;                                [Default = FALSE]
;               POSITIVE    :  If set, routine will consider only positive data values
;                                and ignore zeros
;                                [Default = FALSE]
;               MIN_VALUE   :  Scalar [numeric] defining the minimum value to consider
;                                when defining the YRANGE array
;                                [Default = MIN(ARRAY)]
;               MAX_VALUE   :  Scalar [numeric] defining the maximum value to consider
;                                [Default = MAX(ARRAY)]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [09/05/2018   v1.0.0]
;             2)  Now calls lbw_calc_yrange.pro and
;                   added keywords MIN_VALUE and MAX_VALUE
;                                                                   [09/05/2018   v1.1.0]
;
;   NOTES:      
;               1)  This routine is meant to return a [2]-element array to be used
;                     as the input for the YRANGE keyword in IDL plotting routines
;               2)  See also:  lbw_calc_yrange.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/04/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/05/2018   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION t_calc_yrange,tpstruc,LOG=log,PERC_EX=perc_ex,USE_CURTR=use_curtr,              $
                               POSITIVE=positive,MIN_VALUE=min_value,MAX_VALUE=max_value

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define defaults
pos_on         = 0b                             ;;  Logic:  TRUE = return positive-only values
log_on         = 0b                             ;;  Logic:  TRUE = log-scale plot
ctr_on         = 0b                             ;;  Logic:  TRUE = use the currently shown time range only
def_perc       = 5e-2                           ;;  Default padding percentage
;;  Dummy error messages
notstr1msg     = 'User must define TPSTRUC on input...'
baddfor_msg    = 'Incorrect input format:  TPSTRUC must be an IDL TPLOT structure'
no_inpt_msg    = 'User must have loaded and plotted some data in TPLOT...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check for an input
IF (N_PARAMS() LT 1) THEN BEGIN
  ;;  No input
  MESSAGE,notstr1msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check if TPLOT structure
test           = tplot_struct_format_test(tpstruc,TEST__V=test__v,TEST_V1_V2=test_v1_v2,$
                                          TEST_DY=test_dy,/NOMSSG)
IF (test[0] EQ 0) THEN BEGIN
  MESSAGE,baddfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check LOG
IF KEYWORD_SET(log) THEN log_on = 1b
;;  Check USE_CURTR
IF KEYWORD_SET(use_curtr) THEN ctr_on = 1b
;;  Check USE_CURTR
IF (KEYWORD_SET(positive) OR log_on[0]) THEN pos_on = 1b
;;  Check PERC_EX
IF (is_a_number(perc_ex,/NOMSSG)) THEN pad_perc = ABS(perc_ex[0]) ELSE pad_perc = def_perc[0]
;;----------------------------------------------------------------------------------------
;;  Define data array
;;----------------------------------------------------------------------------------------
IF (ctr_on[0]) THEN BEGIN
  tran           = t_get_current_trange()
  IF (TOTAL(FINITE(tran)) NE 2) THEN BEGIN
    MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
    RETURN,0b
  ENDIF
  ;;  Clip data to currently shown time range
  struc          = trange_clip_data(tpstruc,TRANGE=tran)
  data           = REFORM(struc.Y,N_ELEMENTS(struc.Y))
  ;;  Clean up
  struc          = 0
ENDIF ELSE BEGIN
  ;;  Use all data
  data           = REFORM(tpstruc.Y,N_ELEMENTS(tpstruc.Y))
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define YRANGE
;;----------------------------------------------------------------------------------------
yrange         = lbw_calc_yrange(data,LOG=log_on[0],PERC_EX=pad_perc[0],POSITIVE=pos_on[0],$
                                 MIN_VALUE=min_value,MAX_VALUE=max_value)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,yrange
END
