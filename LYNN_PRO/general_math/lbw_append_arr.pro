;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_append_arr.pro
;  PURPOSE  :   Appends an [N]-dimensional array onto another [N]-dimensional array
;                 with the option to allow for incompatible dimensions where the
;                 user can choose to use the larger or smaller sized array as the output
;                 dimensions.
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
;               A1          :  [N,M,K,L,J]-Element [numeric] array of values onto which
;                                the elements of A2 will be appended
;               A2          :  [T,U,V,X,W]-Element [numeric] array of values to append
;                                onto A1
;
;  EXAMPLES:    
;               [calling sequence]
;               aout = lbw_append_arr(a1, a2 [,LARGER=larger] [,SMALLER=smaller] $
;                                            [,USE_A1_DIM=use_a1_dim]            $
;                                            [,USE_A2_DIM=use_a2_dim]            $
;                                            [,DIM_OUT=dim_out])
;
;               ;;**************************************
;               ;;  Example input and outputs
;               ;;**************************************
;               a1     = REPLICATE(0d0,10)
;               a2     = REPLICATE(1d0,15)
;               aout   = lbw_append_arr(a1,a2)
;               HELP,aout
;               AOUT            DOUBLE    = Array[20]
;               
;               a1     = REPLICATE(0d0,10,20)
;               a2     = REPLICATE(1d0,15,35)
;               aout   = lbw_append_arr(a1,a2)
;               HELP,aout
;               AOUT            DOUBLE    = Array[20, 20]
;               
;               a1     = REPLICATE(0d0,10,20)
;               a2     = REPLICATE(1d0,15,35)
;               aout   = lbw_append_arr(a1,a2,LARGER=1)
;               HELP,aout
;               AOUT            DOUBLE    = Array[30, 20]
;               
;               a1     = REPLICATE(0d0,10,20)
;               a2     = REPLICATE(1d0,15,35)
;               aout   = lbw_append_arr(a2,a1,LARGER=1)
;               HELP,aout
;               AOUT            DOUBLE    = Array[30, 35]
;               
;               a1     = REPLICATE(0d0,10,20)
;               a2     = REPLICATE(1d0,15,35)
;               aout   = lbw_append_arr(a1,a2,LARGER=-1)
;               HELP,aout
;               AOUT            DOUBLE    = Array[30, 35]
;               
;               a1     = REPLICATE(0d0,10,20)
;               a2     = REPLICATE(1d0,15,35)
;               aout   = lbw_append_arr(a1,a2,SMALLER=1)
;               HELP,aout
;               AOUT            DOUBLE    = Array[20, 20]
;               
;               a1     = REPLICATE(0d0,10,20)
;               a2     = REPLICATE(1d0,15,35)
;               aout   = lbw_append_arr(a1,a2,SMALLER=2)
;               HELP,aout
;               AOUT            DOUBLE    = Array[20, 20]
;               
;               a1     = REPLICATE(0d0,10,20)
;               a2     = REPLICATE(1d0,15,35)
;               aout   = lbw_append_arr(a1,a2,SMALLER=-1)
;               HELP,aout
;               AOUT            DOUBLE    = Array[20, 20]
;               
;               a1     = REPLICATE(0d0,10,20,7)
;               a2     = REPLICATE(1d0,15,35,5)
;               aout   = lbw_append_arr(a1,a2,/USE_A1_DIM)
;               HELP,aout
;               AOUT            DOUBLE    = Array[20, 20, 7]
;               
;               a1     = REPLICATE(0d0,10,20,7)
;               a2     = REPLICATE(1d0,15,35,5)
;               aout   = lbw_append_arr(a1,a2,/USE_A2_DIM)
;               HELP,aout
;               AOUT            DOUBLE    = Array[30, 35, 5]
;               
;               a1     = REPLICATE(0d0,10,20,7,6,8)
;               a2     = REPLICATE(1d0,15,35,5,7,4)
;               aout   = lbw_append_arr(a1,a2,/USE_A2_DIM)
;               HELP,aout
;               AOUT            DOUBLE    = Array[30, 35, 5, 7, 4]
;               
;               a1     = REPLICATE(0d0,10,20,7,6,8)
;               a2     = REPLICATE(1d0,15,35,5,7,4)
;               aout   = lbw_append_arr(a1,a2,DIM_OUT=[25,40,8,9,5])
;               HELP,aout
;               AOUT            DOUBLE    = Array[50, 40, 8, 9, 5]
;               
;               ;;**************************************
;               ;;  Check keyword precedence
;               ;;**************************************
;               a1     = REPLICATE(0d0,10,20,7,6,8)
;               a2     = REPLICATE(1d0,15,35,5,7,4)
;               aout   = lbw_append_arr(a1,a2,SMALLER=-1,LARGER=-1)
;               HELP,aout
;               AOUT            DOUBLE    = Array[30, 35, 5, 7, 4]
;               
;               a1     = REPLICATE(0d0,10,20,7,6,8)
;               a2     = REPLICATE(1d0,15,35,5,7,4)
;               aout   = lbw_append_arr(a1,a2,/USE_A1_DIM,/USE_A2_DIM)
;               HELP,aout
;               AOUT            DOUBLE    = Array[20, 20, 7, 6, 8]
;               
;               ;;**************************************
;               ;;  Try screwing up the routine...
;               ;;**************************************
;               a1     = REPLICATE(0d0,10,20,7,6,8)
;               a2     = REPLICATE(1d0,15,35,5,7,4)
;               aout   = lbw_append_arr(a1,a2,DIM_OUT=[25,40,8,9,5],/USE_A2_DIM)
;               HELP,aout
;               AOUT            DOUBLE    = Array[50, 40, 8, 9, 5]
;               
;               a1     = REPLICATE(0d0,10,20,7,6,8)
;               a2     = REPLICATE(1d0,15,35,5,7,4)
;               aout   = lbw_append_arr(a1,a2,DIM_OUT=[25,40,8,9,5],LARGER=-1)
;               HELP,aout
;               AOUT            DOUBLE    = Array[50, 40, 8, 9, 5]
;               
;               a1     = REPLICATE(0d0,10,20,7,6,8)
;               a2     = REPLICATE(1d0,15,35,5,7,4)
;               aout   = lbw_append_arr(a1,a2,DIM_OUT=[25,40])
;               HELP,aout
;               % LBW_APPEND_ARR: Bad input format for DIM_OUT --> Using default
;               AOUT            DOUBLE    = Array[20, 20, 7, 6, 8]
;
;  KEYWORDS:    
;               LARGER      :  If set, routine will use the array with the larger number
;                                of elements in the dimension defined by the numeric value
;                                of LARGER.  If LARGER < 0, then the smaller will be
;                                reduced/increased to the dimensions of the array with
;                                more total elements.  If LARGER > 0, then the output
;                                dimensions will match that of A1 except for the dimension
;                                specified by LARGER if the corresponding size in A2 is
;                                larger.
;                                [Default = FALSE]
;               SMALLER     :  If set, routine will use the array with the smaller number
;                                of elements in the dimension defined by the numeric value
;                                of SMALLER.  If SMALLER < 0, then the larger will be
;                                reduced/increased to the dimensions of the array with
;                                fewer elements total.  If SMALLER > 0, then the output
;                                dimensions will match that of A1 except for the dimension
;                                specified by SMALLER if the corresponding size in A2 is
;                                smaller.
;                                [Default = FALSE]
;               USE_A1_DIM  :  If set, routine will output an array where the appended
;                                A2 has been reduced/increased to the dimensions of A1
;                                [Default = TRUE]
;               USE_A2_DIM  :  If set, routine will output an array where the appended
;                                A1 has been reduced/increased to the dimensions of A2
;                                [Default = FALSE]
;               DIM_OUT     :  [D]-element array defining the output dimensions that both
;                                A1 and A2 will be reduced/increased to prior to appending
;                                [Default = SIZE(A1,/DIMENSIONS)]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Note that M,K,L,J can all be unity (i.e., 1D array) and U,V,X,W
;                     as well.  What matters is that A1 and A2 have the same number
;                     of dimensions, not the number of elements within each dimension
;               2)  When using LARGER or SMALLER, the values for specific dimensions
;                     should start at 1
;               3)  Keyword order of precedence
;                     1  :  DIM_OUT
;                     2  :  USE_A1_DIM
;                     3  :  USE_A2_DIM
;                     4  :  LARGER
;                     5  :  SMALLER
;               4)  If none of the keywords are set, then the output will be a size given
;                     by the following equivalent on output from HELP
;                       Array[2*N,M,K,L,J]
;                     assuming the size/dimensions are the same as those shown in the
;                     INPUT field above.  If M, K, L, and J are all unity (i.e., 1D input)
;                     then the output will be a 1D array with 2*N elements.
;
;  REFERENCES:  
;               https://www.harrisgeospatial.com/docs/MAKE_ARRAY.html
;               https://www.harrisgeospatial.com/docs/SIZE.html
;               
;
;   CREATED:  05/09/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/09/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_append_arr,a1,a2,LARGER=larger,SMALLER=smaller,USE_A1_DIM=use_a1_dim,$
                              USE_A2_DIM=use_a2_dim,DIM_OUT=dim_out

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
zeros          = get_zeros_mins_maxs_type()
def__types     = zeros.TYPES
def__zeros     = zeros.ZEROS
;;  Dummy error messages
no_input_msg   = 'User must define A1 and A2 as numeric arrays on input...'
baddfor_mssg   = 'Incorrect input format:  A1 and A2 must have the same number of dimensions not exceeding 5...'
badtype_mssg   = 'Incorrect input format:  A1 and A2 must be a valid numeric type...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check for an input
test           = (N_ELEMENTS(a1) LE 0) OR (N_ELEMENTS(a2) LE 0) OR (N_PARAMS() NE 2)
IF (test[0]) THEN BEGIN
  MESSAGE,no_input_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
szdd_1         = SIZE(a1,/DIMENSIONS)
szdd_2         = SIZE(a2,/DIMENSIONS)
sznd_1         = SIZE(a1,/N_DIMENSIONS)
sznd_2         = SIZE(a2,/N_DIMENSIONS)
test           = (sznd_1[0] NE sznd_2[0]) OR ((sznd_1[0] GT 5) OR (sznd_2[0] GT 5))
IF (test[0]) THEN BEGIN
  MESSAGE,baddfor_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
def_dim_out    = szdd_1
mx_ndim        = MAX([sznd_1[0],sznd_2[0]])
mn_ndim        = MIN([sznd_1[0],sznd_2[0]])
nn_1           = N_ELEMENTS(a1)
nn_2           = N_ELEMENTS(a2)
ty_1           = SIZE(a1,/TYPE)
ty_2           = SIZE(a2,/TYPE)
type_out       = ty_1[0] > ty_2[0]      ;;  Up-convert type
;;  Define associated zero for array making later
good_type      = WHERE(def__types EQ type_out[0],gd_type)
IF (gd_type[0] EQ 0) THEN BEGIN
  MESSAGE,badtype_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define allowed zero
def_zero       = def__zeros.(good_type[0])
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check LARGER
IF (is_a_number(larger,/NOMSSG))  THEN lrg_on = 1b ELSE lrg_on = 0b
;;  Check SMALLER
IF (is_a_number(smaller,/NOMSSG)) THEN sml_on = 1b ELSE sml_on = 0b
;;  Check format of LARGER and SMALLER, if either is set
IF (lrg_on[0] OR sml_on[0]) THEN BEGIN
  IF (lrg_on[0]) THEN lrg_on = (larger[0] LT 0) OR ((larger[0] GT 0) AND (larger[0] LE mx_ndim[0]))
  IF (sml_on[0]) THEN sml_on = (smaller[0] LT 0) OR ((smaller[0] GT 0) AND (smaller[0] LE mn_ndim[0]))
ENDIF
IF (lrg_on[0] AND sml_on[0]) THEN sml_on = 0b             ;;  Default to LARGER if both are set
;;  Check USE_A1_DIM and USE_A2_DIM
IF KEYWORD_SET(use_a1_dim) THEN use_a1_on = 1b ELSE use_a1_on = 0b
IF KEYWORD_SET(use_a2_dim) THEN use_a2_on = 1b ELSE use_a2_on = 0b
IF (use_a1_on[0] AND use_a2_on[0]) THEN use_a2_on = 0b    ;;  Default to USE_A1_DIM if both are set
IF (use_a1_on[0] OR use_a2_on[0]) THEN BEGIN
  ;;  Make sure to shut off LARGER and SMALLER if either USE_A1_DIM or USE_A2_DIM are set
  lrg_on = 0b
  sml_on = 0b
ENDIF
other_ar       = [lrg_on[0],sml_on[0],use_a1_on[0],use_a2_on[0]]
other_on       = (TOTAL(other_ar) GT 0)
;;----------------------------------------------------------------------------------------
;;  If something is already set --> define initial DIM_OUT
;;----------------------------------------------------------------------------------------
IF (other_on[0]) THEN BEGIN
  ;;  Something set --> use it
  good_oth       = WHERE(other_ar,gd_oth)
  CASE good_oth[0] OF
    0  :  BEGIN
      ;;0000000000000000000000000000000000000000000000000000000000000000000000000000000000
      ;;  Use larger
      CASE 1 OF
        (larger[0] LT 0)  :  IF (nn_1[0] GE nn_2[0]) THEN dim_out0 = szdd_1 ELSE dim_out0 = szdd_2
        ELSE              :  BEGIN
          dim_out0 = def_dim_out
          CASE larger[0] OF
            1  :  dim_out0[0] = szdd_1[0] > szdd_2[0]
            2  :  dim_out0[1] = szdd_1[1] > szdd_2[1]
            3  :  dim_out0[2] = szdd_1[2] > szdd_2[2]
            4  :  dim_out0[3] = szdd_1[3] > szdd_2[3]
            5  :  dim_out0[4] = szdd_1[4] > szdd_2[4]
          ENDCASE
        END
      ENDCASE
      ;;0000000000000000000000000000000000000000000000000000000000000000000000000000000000
    END
    1  :  BEGIN
      ;;1111111111111111111111111111111111111111111111111111111111111111111111111111111111
      ;;  Use smaller
      CASE 1 OF
        (smaller[0] LT 0)  :  IF (nn_1[0] GE nn_2[0]) THEN dim_out0 = szdd_2 ELSE dim_out0 = szdd_1
        ELSE               :  BEGIN
          dim_out0 = def_dim_out
          CASE smaller[0] OF
            1  :  dim_out0[0] = szdd_1[0] < szdd_2[0]
            2  :  dim_out0[1] = szdd_1[1] < szdd_2[1]
            3  :  dim_out0[2] = szdd_1[2] < szdd_2[2]
            4  :  dim_out0[3] = szdd_1[3] < szdd_2[3]
            5  :  dim_out0[4] = szdd_1[4] < szdd_2[4]
          ENDCASE
        END
      ENDCASE
      ;;1111111111111111111111111111111111111111111111111111111111111111111111111111111111
    END
    2  :  BEGIN
      ;;2222222222222222222222222222222222222222222222222222222222222222222222222222222222
      ;;  Use A1 dimensions
      dim_out0 = def_dim_out
      ;;2222222222222222222222222222222222222222222222222222222222222222222222222222222222
    END
    3  :  BEGIN
      ;;3333333333333333333333333333333333333333333333333333333333333333333333333333333333
      ;;  Use A2 dimensions
      dim_out0 = szdd_2
      ;;3333333333333333333333333333333333333333333333333333333333333333333333333333333333
    END
    ELSE  :  STOP     ;;  Should not happen!!! --> Debug
  ENDCASE
ENDIF ELSE BEGIN
  ;;  Use default
  dim_out0 = def_dim_out
ENDELSE
;;  Check DIM_OUT
IF (is_a_number(dim_out,/NOMSSG)) THEN BEGIN
  szdd_o         = dim_out
  sznd_o         = N_ELEMENTS(szdd_o)
  IF (sznd_o[0] NE sznd_1[0]) THEN BEGIN
    ;;  Bad format for input DIM_OUT --> Use default
    MESSAGE,'Bad input format for DIM_OUT --> Using default',/INFORMATIONAL,/CONTINUE
    dim_out = dim_out0
  ENDIF ELSE BEGIN
    ;;  Check for keyword conflicts
    ;;    DIM_OUT supercedes others --> shut off any that may be on
    lrg_on    = 0b
    sml_on    = 0b
    use_a1_on = 0b
    use_a2_on = 0b
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Use default
  dim_out = dim_out0
ENDELSE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define new arrays with proper output dimensions
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
ndim_out       = N_ELEMENTS(dim_out)
IF (ndim_out[0] EQ 1) THEN dimout = dim_out[0] ELSE dimout = dim_out       ;;  prevent [1]-element array from screwing up MAKE_ARRAY.PRO
dumb_out       = MAKE_ARRAY(dimout,TYPE=type_out[0],VALUE=def_zero[0])
upp1           = (dim_out - 1L) < (szdd_1 - 1L)
upp2           = (dim_out - 1L) < (szdd_2 - 1L)
;;  Define dummy arrays to fill prior to appending for output
b1             = dumb_out
b2             = dumb_out
CASE ndim_out[0] OF
  ;;11111111111111111111111111111111111111111111111111111111111111111111111111111111111111
  1     :  BEGIN
    b1[0L:upp1[0]]   = a1[0L:upp1[0]]
    b2[0L:upp2[0]]   = a2[0L:upp2[0]]
  END
  ;;22222222222222222222222222222222222222222222222222222222222222222222222222222222222222
  2     :  BEGIN
    b1[0L:upp1[0],0L:upp1[1]]   = a1[0L:upp1[0],0L:upp1[1]]
    b2[0L:upp2[0],0L:upp2[1]]   = a2[0L:upp2[0],0L:upp2[1]]
  END
  ;;33333333333333333333333333333333333333333333333333333333333333333333333333333333333333
  3     :  BEGIN
    b1[0L:upp1[0],0L:upp1[1],0L:upp1[2]]   = a1[0L:upp1[0],0L:upp1[1],0L:upp1[2]]
    b2[0L:upp2[0],0L:upp2[1],0L:upp2[2]]   = a2[0L:upp2[0],0L:upp2[1],0L:upp2[2]]
  END
  ;;44444444444444444444444444444444444444444444444444444444444444444444444444444444444444
  4     :  BEGIN
    b1[0L:upp1[0],0L:upp1[1],0L:upp1[2],0L:upp1[3]]   = a1[0L:upp1[0],0L:upp1[1],0L:upp1[2],0L:upp1[3]]
    b2[0L:upp2[0],0L:upp2[1],0L:upp2[2],0L:upp2[3]]   = a2[0L:upp2[0],0L:upp2[1],0L:upp2[2],0L:upp2[3]]
  END
  ;;55555555555555555555555555555555555555555555555555555555555555555555555555555555555555
  5     :  BEGIN
    b1[0L:upp1[0],0L:upp1[1],0L:upp1[2],0L:upp1[3],0L:upp1[4]]   = a1[0L:upp1[0],0L:upp1[1],0L:upp1[2],0L:upp1[3],0L:upp1[4]]
    b2[0L:upp2[0],0L:upp2[1],0L:upp2[2],0L:upp2[3],0L:upp2[4]]   = a2[0L:upp2[0],0L:upp2[1],0L:upp2[2],0L:upp2[3],0L:upp2[4]]
  END
  ELSE  :  STOP     ;;  Should not happen!!! --> Debug
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Append arrays for output
;;----------------------------------------------------------------------------------------
aout           = [b1,b2]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,aout
END