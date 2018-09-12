;+
;*****************************************************************************************
;
;  FUNCTION :   get_posneg_els_arr.pro
;  PURPOSE  :   This routine returns either the positive- or negative-only elements of
;                 an input [numeric] array and returns either a new length or original
;                 length array with user-defined fill values for the latter.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_zeros_mins_maxs_type.pro
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               ARRAY     :  [N]-Element [numeric] array from which to extract the
;                              positive- or negative-only elements
;
;  EXAMPLES:    
;               [calling sequence]
;               posneg = get_posneg_els_arr(array [,/NEGATIVE] [,/INCZEROS] [,FILL_VAL=fill_val])
;
;               ;;  **************************************
;               ;;  Examples
;               ;;  **************************************
;               n              = 8L
;               x              = FINDGEN(n[0]) - 3e0
;
;               xp             = get_posneg_els_arr(x)
;               HELP, x, xp
;                   X               FLOAT     = Array[8]
;                   XP              FLOAT     = Array[4]
;               PRINT,';;  ',FIX(x)
;               ;;        -3      -2      -1       0       1       2       3       4
;
;               xpz            = get_posneg_els_arr(x,FILL_VAL=0e0)
;               HELP, x, xpz
;                   X               FLOAT     = Array[8]
;                   XPZ             FLOAT     = Array[8]
;               PRINT,';;  ',FIX(xpz)
;               ;;         0       0       0       0       1       2       3       4
;
;               xpzz           = get_posneg_els_arr(x,/INCZEROS,FILL_VAL=!VALUES.F_NAN)
;               HELP, x, xpzz
;                   X               FLOAT     = Array[8]
;                   XPZZ            FLOAT     = Array[8]
;               PRINT,';;  ',xpzz
;               ;;            NaN          NaN          NaN      0.00000      1.00000      2.00000      3.00000      4.00000
;
;               xnz            = get_posneg_els_arr(x,/NEGATIVE,FILL_VAL=!VALUES.F_NAN)
;               HELP, x, xnz
;                   X               FLOAT     = Array[8]
;                   XNZ             FLOAT     = Array[8]
;               PRINT,';;  ',xnz
;               ;;       -3.00000     -2.00000     -1.00000          NaN          NaN          NaN          NaN          NaN
;
;               xnzz           = get_posneg_els_arr(x,/NEGATIVE,/INCZEROS,FILL_VAL=!VALUES.F_NAN)
;               HELP, x, xnzz
;                   X               FLOAT     = Array[8]
;                   XNZZ            FLOAT     = Array[8]
;               PRINT,';;  ',xnzz
;               ;;       -3.00000     -2.00000     -1.00000      0.00000          NaN          NaN          NaN          NaN
;
;  KEYWORDS:    
;               NEGATIVE  :  If set, routine will return the negative-only values of
;                              ARRAY, including zeros if INCZEROS is TRUE
;                              [Default = FALSE]
;               INCZEROS  :  If set, routine will include zeros as within the realm of
;                              positive- or negative-only elements of ARRAY
;                              [Default = FALSE]
;               FILL_VAL  :  Scalar [numeric] defining the fill values to include to
;                              maintain the same number of elements as ARRAY for the
;                              output array.  That is, the values that do not satisfy
;                              the NEGATIVE and INCZEROS settings will be replaced with
;                              FILL_VAL.  If this keyword is not set, the output array
;                              will change in the number of elements to include only
;                              those satisfying the NEGATIVE and INCZEROS settings.
;                              [Default = 0]
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
;   CREATED:  09/04/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/04/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_posneg_els_arr,array,NEGATIVE=negative,INCZEROS=inczeros,FILL_VAL=fill_val

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define allowed numeric types
all_num_type   = [1,2,3,4,5,6,9,12,13,14,15]
;;  Define allowed types
all_type_str   = get_zeros_mins_maxs_type()     ;;  Get all type info for system
all_ok_type    = all_type_str.TYPES             ;;  i.e., [1L,2L,3L,4L,5L,6L,7L,9L,12L,13L,14L,15L]
;;  Define defaults
pos_on         = 1b                             ;;  Logic:  TRUE = return positive-only values
inz_on         = 0b                             ;;  Logic:  TRUE = include zeros as within realm of desired values
;;  Dummy error messages
notstr1msg     = 'User must define ARRAY on input...'
notstr2msg     = 'ARRAY must be an [N]-element [numeric] array...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check for an input
IF (N_PARAMS() LT 1) THEN BEGIN
  ;;  No input
  MESSAGE,notstr1msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
szdd           = SIZE(array,/DIMENSIONS)
szdt           = SIZE(array,/TYPE)
IF ((is_a_number(array,/NOMSSG) EQ 0) OR (szdd[0] EQ 0)) THEN BEGIN
  ;;  Input not numeric or not an array
  MESSAGE,notstr2msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Determine numeric type
good           = WHERE(all_ok_type EQ szdt[0],gd)
zero           = all_type_str.ZEROS.(good[0])
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NEGATIVE
IF KEYWORD_SET(negative) THEN pos_on = 0b
;;  Check INCZEROS
IF KEYWORD_SET(inczeros) THEN inz_on = 1b
;;  Check FILL_VAL
IF (is_a_number(fill_val,/NOMSSG)) THEN keep_sz = 1b ELSE keep_sz = 0b
IF (keep_sz[0]) THEN fill = fill_val[0] ELSE fill = zero[0]
;;----------------------------------------------------------------------------------------
;;  Get values of interest
;;----------------------------------------------------------------------------------------
IF (pos_on[0]) THEN BEGIN
  ;;  Positive-only --> check if zeros are included
  IF (inz_on[0]) THEN BEGIN
    ;;  Include zeros
    good  = WHERE(array GE 0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
  ENDIF ELSE BEGIN
    ;;  Exclude zeros
    good  = WHERE(array GT 0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Negative-only --> check if zeros are included
  IF (inz_on[0]) THEN BEGIN
    ;;  Include zeros
    good  = WHERE(array LE 0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
  ENDIF ELSE BEGIN
    ;;  Exclude zeros
    good  = WHERE(array LT 0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
IF (keep_sz[0]) THEN BEGIN
  ;;  Maintain the original array size --> replace "bad" elements with fill values
  output         = array
  IF (bd[0] GT 0) THEN output[bad] = fill[0]
ENDIF ELSE BEGIN
  ;;  Only keep "good" elements
  IF (gd[0] GT 0) THEN output = array[good] ELSE output = zero[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END

















