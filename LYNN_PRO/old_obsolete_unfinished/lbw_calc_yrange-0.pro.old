;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_calc_yrange.pro
;  PURPOSE  :   Calculates an appropriate YRANGE array for a given input data array
;                 accounting for user-specified tests (e.g., log or linear scale).
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               get_posneg_els_arr.pro
;               fill_range.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               ARRAY     :  [N]-Element [numeric] array from which to calculate an
;                              appropriate array for YRANGE
;
;  EXAMPLES:    
;               [calling sequence]
;               yrange = lbw_calc_yrange(array [,/LOG] [,/POSITIVE] [,PERC_EX=perc_ex]  $
;                                        [,MIN_VALUE=min_value] [,MAX_VALUE=max_value]  )
;
;  KEYWORDS:    
;               LOG         :  If set, routine will assume data is plotted on a
;                                logarithmic scale and so will ensure at least one major
;                                tick mark (i.e., integer power of 10) is included in
;                                the output YRANGE array
;                                [Default = FALSE]
;               POSITIVE    :  If set, routine will consider only positive data values
;                                and ignore zeros
;                                [Default = FALSE]
;               PERC_EX     :  Scalar [numeric] defining the percentage beyond the actual
;                                data range to include as padding
;                                [Default = 5e-2 for 5%]
;               MIN_VALUE   :  Scalar [numeric] defining the minimum value to consider
;                                when defining the YRANGE array
;                                [Default = MIN(ARRAY)]
;               MAX_VALUE   :  Scalar [numeric] defining the maximum value to consider
;                                [Default = MAX(ARRAY)]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This routine is meant to return a [2]-element array to be used
;                     as the input for the YRANGE keyword in IDL plotting routines
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/05/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/05/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_calc_yrange,array,LOG=log,PERC_EX=perc_ex,POSITIVE=positive,$
                              MIN_VALUE=min_value,MAX_VALUE=max_value

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define defaults
pos_on         = 0b                             ;;  Logic:  TRUE = return positive-only values
log_on         = 0b                             ;;  Logic:  TRUE = log-scale plot
ctr_on         = 0b                             ;;  Logic:  TRUE = use the currently shown time range only
mnv_on         = 0b                             ;;  Logic:  TRUE = user set the MIN_VALUE keyword
mxv_on         = 0b                             ;;  Logic:  TRUE = user set the MAX_VALUE keyword
def_perc       = 5e-2                           ;;  Default padding percentage
init_mnv       = -1d30                          ;;  Initialization value for default MIN_VALUE setting
init_mxv       =  1d30                          ;;  Initialization value for default MAX_VALUE setting
;;  Dummy error messages
no_inpt_msg    = 'User must define ARRAY on input...'
baddfor_msg    = 'Incorrect input format:  ARRAY must be an [N]-element [numeric] array of non-identical values'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check for an input
IF (N_PARAMS() LT 1) THEN BEGIN
  ;;  No input
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check if numeric and an array
szdd           = SIZE(array,/DIMENSIONS)
szdt           = SIZE(array,/TYPE)
IF ((is_a_number(array,/NOMSSG) EQ 0) OR (szdd[0] EQ 0)) THEN BEGIN
  ;;  Input not numeric or not an array
  MESSAGE,baddfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check LOG
IF KEYWORD_SET(log) THEN log_on = 1b
;;  Check PERC_EX
IF (is_a_number(perc_ex,/NOMSSG)) THEN pad_perc = ABS(perc_ex[0]) ELSE pad_perc = def_perc[0]
;;  Check MIN_VALUE
IF (is_a_number(min_value,/NOMSSG)) THEN mnv_on = 1b
IF (mnv_on[0]) THEN BEGIN
  ;;  User set MIN_VALUE as a number --> Make sure it's finite
  mnval = min_value[0]
  IF (FINITE(mnval[0]) EQ 0) THEN BEGIN
    ;;  Non-finite setting --> shut off logic
    mnv_on = 0b
    mnval  = init_mnv[0]
  ENDIF
ENDIF ELSE BEGIN
  mnval = init_mnv[0]
ENDELSE
;;  Check MAX_VALUE
IF (is_a_number(max_value,/NOMSSG)) THEN mxv_on = 1b
IF (mxv_on[0]) THEN BEGIN
  mxval = max_value[0]
  IF (FINITE(mxval[0]) EQ 0) THEN BEGIN
    ;;  Non-finite setting --> shut off logic
    mxv_on = 0b
    mxval  = init_mxv[0]
  ENDIF
ENDIF ELSE BEGIN
  mxval = init_mxv[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define YRANGE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  First ensure ARRAY is 1D
data           = REFORM(array,N_ELEMENTS(array))
IF (pos_on[0]) THEN BEGIN
  ;;  Use only positive, non-negative values
  vals           = get_posneg_els_arr(data)
ENDIF ELSE BEGIN
  ;;  Use all values
  vals           = data
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Next make sure to limit to within MIN_VALUE and MAX_VALUE
;;----------------------------------------------------------------------------------------
IF (mnv_on[0] OR mxv_on[0]) THEN BEGIN
  IF (mnv_on[0] AND mxv_on[0]) THEN BEGIN
    ;;  Both are set
    test           = (vals GE mnval[0]) AND (vals LE mxval[0])
  ENDIF ELSE BEGIN
    ;;  Only one is set
    CASE 1 OF
      mnv_on[0]  :  test           = (vals GE mnval[0])
      mxv_on[0]  :  test           = (vals LE mxval[0])
    ENDCASE
  ENDELSE
  ;;  Limit to only those "good" values between MIN_VALUE and MAX_VALUE
  good           = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
  IF (bd[0] GT 0) THEN vals[bad] = f
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define initial YRANGE
;;----------------------------------------------------------------------------------------
;;  Define default range
def_yran       = [MIN(vals,/NAN),MAX(vals,/NAN)]
;;  Expand by PERC_EX
pad_yran       = def_yran*(1d0 + [-1,1]*pad_perc[0])
;;----------------------------------------------------------------------------------------
;;  Check for at least one major tick in YRANGE
;;----------------------------------------------------------------------------------------
IF (log_on[0]) THEN BEGIN
  ;;  Ensure positive in case user entered a percentage greater than unity
  IF (pad_yran[0] LE 0) THEN pad_yran[0] = pad_yran[0] > (1d-2*def_yran[0])
  ;;--------------------------------------------------------------------------------------
  ;;  Find nearest integer power of 10
  ;;--------------------------------------------------------------------------------------
  l10_yran       = ALOG10(pad_yran)
  l10_rex        = [FLOOR(l10_yran),CEIL(l10_yran)]
  exp_ran        = [MIN(l10_rex,/NAN) - 1,MAX(l10_rex,/NAN) + 1]
  int_exp        = fill_range(exp_ran[0],exp_ran[1],DIND=1)
  int_p10        = 1d1^int_exp
  ;;  See if YRANGE straddles any integer power of 10
  good           = WHERE(pad_yran[0] LE int_p10 AND pad_yran[1] GE int_p10,gd)
  IF (gd[0] EQ 0) THEN BEGIN
    ;;  Need to expand to include nearest integer power of 10
    np           = N_ELEMENTS(int_p10)
    diff         = REPLICATE(f,np[0],2L)
    FOR k=0L, 1L DO diff[*,k]    = ABS(pad_yran[k] - int_p10)
    mndff        = MIN(diff,ln,DIMENSION=1,/NAN)
    lnind        = ARRAY_INDICES(diff,ln)
    IF (mndff[0] LT mndff[1]) THEN BEGIN
      ;;  Expand to lower integer power of 10
      pad_yran[0] = int_p10[lnind[0,0]]
    ENDIF ELSE BEGIN
      ;;  Expand to upper integer power of 10
      pad_yran[1] = int_p10[lnind[0,1]]
    ENDELSE
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,pad_yran
END









