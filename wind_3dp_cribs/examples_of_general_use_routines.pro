;+
;*****************************************************************************************
;
;  CRIBSHEET:   examples_of_general_use_routines.pro
;  PURPOSE  :   This is a crib sheet meant to illustrate the usage of several of the
;                 general usage routines in ~/LYNN_PRO.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               is_a_3_vector.pro
;               test_tdate_format.pro
;               fill_range.pro
;               merge_overlap_int.pro
;               expand_index_array.pro
;               get_general_char_name.pro
;               file_name_times.pro
;               fill_tdates_btwn_start_end.pro
;               add_os_slash.pro
;               time_double.pro
;               general_find_files_from_trange.pro
;               num2int_str.pro
;               general_prompt_routine.pro
;               get_valid_trange.pro
;               sample_rate.pro
;               vector_bandpass.pro
;               find_intersect_2_curves.pro
;               eulermat.pro
;               vm_matrix.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This should not be called as a batch file or run like a program
;               2)  This is meant to be a simple crib sheet to illustrate examples
;                     for how one might use the various routines exhibited herein
;
;  REFERENCES:  
;               NA
;
;   CREATED:  02/05/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/05/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Logic/Testing routines
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------


;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  test = is_a_number(x [,/NOMSSG])
;;----------------------------------------------------------------------------------------
;;  Input :  Numeric Array of 3-vectors
;;  Output:  TRUE
xx             = FINDGEN(10,3)
PRINT,';;  ', is_a_number(xx,/NOMSSG)
;;     1

;;  Would also work for the following:
;;    BINDGEN.PRO
;;    INDGEN.PRO
;;    LINDGEN.PRO
;;    FINDGEN.PRO
;;    CINDGEN.PRO
;;    DINDGEN.PRO
;;    DCINDGEN.PRO
;;    L64INDGEN.PRO
;;    INDGEN.PRO
;;    UINDGEN.PRO
;;    ULINDGEN.PRO
;;    UL64INDGEN.PRO

;;  Input :  String Array of 3-vectors
;;  Output:  FALSE
xx             = REPLICATE('',10,3)
PRINT,';;  ', is_a_number(xx,/NOMSSG)
;;     0

;;  Input :  Structure
;;  Output:  FALSE
xx             = REPLICATE({X:15,Y:FINDGEN(3)},3)
PRINT,';;  ', is_a_number(xx,/NOMSSG)
;;     0

;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  test = is_a_3_vector(vv [,V_OUT=v_out] [,/NOMSSG])
;;----------------------------------------------------------------------------------------
;;  Input :  Numeric Array of 3-vectors
;;  Output:  TRUE
vv             = FINDGEN(10,3)
PRINT,';;  ', is_a_3_vector(vv,/NOMSSG)
;;     1

;;  Input:  Numeric Array of 4-vectors
;;  Output:  FALSE
vv             = FINDGEN(10,4)
PRINT,';;  ', is_a_3_vector(vv,/NOMSSG)
;;     0

;;  Input:  Numeric Array of 2-vectors
;;  Output:  FALSE
vv             = FINDGEN(10,2)
PRINT,';;  ', is_a_3_vector(vv,/NOMSSG)
;;     0

;;  Input:  Numeric Single 3-vector
;;  Output:  TRUE
vv             = FINDGEN(3)
PRINT,';;  ', is_a_3_vector(vv,/NOMSSG)
;;     1


;;  Input:  Numeric Single 4-vector
;;  Output:  FALSE
vv             = FINDGEN(4)
PRINT,';;  ', is_a_3_vector(vv,/NOMSSG)
;;     0

;;  Input:  Numeric [9]-element array
;;  Output:  FALSE
vv             = FINDGEN(9)
PRINT,';;  ', is_a_3_vector(vv,/NOMSSG)
;;     0

;;  Input :  String Array of 3-vectors
;;  Output:  FALSE
vv             = REPLICATE('',10,3)
PRINT,';;  ', is_a_3_vector(vv,/NOMSSG)
;;     0

;;  Input :  Structure
;;  Output:  FALSE
vv             = REPLICATE({X:15,Y:FINDGEN(3)},3)
PRINT,';;  ', is_a_3_vector(vv,/NOMSSG)
;;     0

;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  test = test_tdate_format(tdate [,/NOMSSG])
;;----------------------------------------------------------------------------------------
;;  Input :  Valid date with format 'YYYY-MM-DD'
;;  Output:  TRUE
tdate          = '2015-10-21'
PRINT,';;  ', test_tdate_format(tdate,/NOMSSG)
;;     1

;;  Input :  Valid date with format 'YYYYMMDD'
;;  Output:  FALSE
tdate          = '20151021'
PRINT,';;  ', test_tdate_format(tdate,/NOMSSG)
;;     0

;;  Input :  Valid date with format 'MMDDYY'
;;  Output:  FALSE
tdate          = '102115'
PRINT,';;  ', test_tdate_format(tdate,/NOMSSG)
;;     0

;;  Input :  Any non-string type
;;  Output:  FALSE
tdate          = 20151021L
PRINT,';;  ', test_tdate_format(tdate,/NOMSSG)
;;     0



;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  General array routines
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  array = fill_range(st, en [,DIND=dind] [,UNIFORM=uniform])
;;----------------------------------------------------------------------------------------
;;  Output array maintains input data type
s              = 0
e              = 25
ind            = fill_range(s,e)
HELP, ind, MIN(ind,/NAN), MAX(ind,/NAN), OUTPUT=out
FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';; ',out[j]
;; IND             INT       = Array[26]
;; <Expression>    INT       =        0
;; <Expression>    INT       =       25

;;  Output array maintains input data type
s              = 0d0
e              = 25d3
ind            = fill_range(s,e)
HELP, ind, MIN(ind,/NAN), MAX(ind,/NAN), OUTPUT=out
FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';; ',out[j]
;; IND             DOUBLE    = Array[25001]
;; <Expression>    DOUBLE    =        0.0000000
;; <Expression>    DOUBLE    =        25000.000

;;  Example of DIND keyword usage
s              = 0
e              = 25
di             = 5
ind            = fill_range(s,e,DIND=di)
HELP, ind, MIN(ind,/NAN), MAX(ind,/NAN), OUTPUT=out
FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';; ',out[j]
;; IND             INT       = Array[6]
;; <Expression>    INT       =        0
;; <Expression>    INT       =       25

;;  Example of UNIFORM keyword usage (output 5-element array)
s              = 0
e              = 25
uni            = 5
ind            = fill_range(s,e,UNIFORM=uni)
HELP, ind, MIN(ind,/NAN), MAX(ind,/NAN), OUTPUT=out
FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';; ',out[j]
;; IND             INT       = Array[5]
;; <Expression>    INT       =        0
;; <Expression>    INT       =       25

;;  UNIFORM keyword takes precidence over DIND keyword
s              = 0d0
e              = 25d0
uni            = 5
di             = 5
ind            = fill_range(s,e,DIND=di,UNIFORM=uni)
HELP, ind, MIN(ind,/NAN), MAX(ind,/NAN), uni, di, OUTPUT=out
FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';; ',out[j]
;; IND             DOUBLE    = Array[5]
;; <Expression>    DOUBLE    =        0.0000000
;; <Expression>    DOUBLE    =        25.000000
;; UNI             LONG      =            5
;; DI              DOUBLE    =        6.2500000

;;  Example of bad UNIFORM keyword usage
s              = 0d0
e              = 25d0
uni            = 5d30
ind            = fill_range(s,e,UNIFORM=uni)
;% FILL_RANGE: # of array elements setting (i.e., UNIFORM) is too large!
;% Program caused arithmetic error: Floating illegal operand
HELP, ind, MIN(ind,/NAN), MAX(ind,/NAN), uni, OUTPUT=out
FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';; ',out[j]
;; IND             BYTE      =    0
;; <Expression>    BYTE      =    0
;; <Expression>    BYTE      =    0
;; UNI             DOUBLE    =    5.0000000e+30


;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  new_se = merge_overlap_int(se_i [,GAP_THRSH=gap_thrsh] [,MIN_INT=min_int] $
;;                             [,MAX_INT=max_int] [,COUNT=count])
;;----------------------------------------------------------------------------------------
gap_thsh       = 3L                       ;;  gap threshold for merging intervals
min_lgth       = 2L                       ;;  Min. interval length below which they are removed
max_lgth       = 200L                     ;;  Max. " " above which they are split up
st_e           = [  0L, 54L, 75L,119L,250L,323L,465L]
en_e           = [ 49L, 74L,120L,248L,322L,466L,488L]
se_i           = [[st_e],[en_e]]
new_se         = merge_overlap_int(se_i,GAP_THRSH=gap_thsh[0],MIN_INT=min_lgth[0],       $
                                   MAX_INT=max_lgth[0],COUNT=count)
PRINT,';;',count & $
PRINT,';;',new_se[*,0] & $
PRINT,';;',new_se[*,1]
;;      4.00000
;;           0          54         254         454
;;          49         254         454         488

gap_thsh       = 1L                       ;;  gap threshold for merging intervals
min_lgth       = 2L                       ;;  Min. interval length below which they are removed
max_lgth       = 200L                     ;;  Max. " " above which they are split up
st_e           = [  0L, 54L, 75L,119L,250L,323L,465L]
en_e           = [ 49L, 74L,120L,248L,322L,466L,488L]
se_i           = [[st_e],[en_e]]
new_se         = merge_overlap_int(se_i,GAP_THRSH=gap_thsh[0],MIN_INT=min_lgth[0],       $
                                   MAX_INT=max_lgth[0],COUNT=count)
PRINT,';;',count & $
PRINT,';;',new_se[*,0] & $
PRINT,';;',new_se[*,1]
;;      4.00000
;;           0          54         250         450
;;          49         248         450         488


gap_thsh       = 1L                       ;;  gap threshold for merging intervals
min_lgth       = 2L                       ;;  Min. interval length below which they are removed
max_lgth       = 500L                     ;;  Max. " " above which they are split up
st_e           = [  0L, 54L, 75L,119L,250L,323L,465L]
en_e           = [ 49L, 74L,120L,248L,322L,466L,488L]
se_i           = [[st_e],[en_e]]
new_se         = merge_overlap_int(se_i,GAP_THRSH=gap_thsh[0],MIN_INT=min_lgth[0],       $
                                   MAX_INT=max_lgth[0],COUNT=count)
PRINT,';;',count & $
PRINT,';;',new_se[*,0] & $
PRINT,';;',new_se[*,1]
;;           3
;;           0          54         250
;;          49         248         488


;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  expand_index_array [,SI__IN=si__in] [,EI__IN=ei__in] [,ARR_IN=arr_in]   $
;;                     [,D_AR_IN=d_ar_in] [,EX_A_IN=ex_a_in]                $
;;                     [,NO_WRAP=no_wrap] [,SI_OUT=si_out] [,EI_OUT=ei_out] $
;;                     [,ARROUT=arrout] [,D_AROUT=d_arout]
;;----------------------------------------------------------------------------------------

;;  Cleanup to avoid previous definition contamination
DELVAR,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout,no_wrap
si__in         = 5703L          ;;  Valid start index
ei__in         = 5703L          ;;  Valid end   index
expand_index_array,SI__IN=si__in,EI__IN=ei__in,ARR_IN=arr_in,       $
                   D_AR_IN=d_ar_in,EX_A_IN=ex_a_in,NO_WRAP=no_wrap, $
                   SI_OUT=si_out,EI_OUT=ei_out,ARROUT=arrout,       $
                   D_AROUT=d_arout
HELP,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout
;SI__IN          LONG      =         5703
;EI__IN          LONG      =         5703
;ARR_IN          LONG      =         5703
;D_AR_IN         LONG      =            1
;EX_A_IN         LONG      =            1
;SI_OUT          LONG      =         5703
;EI_OUT          LONG      =         5703
;ARROUT          LONG      = Array[3]
;D_AROUT         LONG      =            1
PRINT,';;',arr_in & $
PRINT,';;',arrout
;;        5703
;;        5703        5703        5703

;;  Cleanup to avoid previous definition contamination
DELVAR,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout,no_wrap
si__in         = 5703L          ;;  Valid start index
ei__in         = 5713L          ;;  Valid end   index
d_ar_in        = 2L             ;;  Valid step length
expand_index_array,SI__IN=si__in,EI__IN=ei__in,ARR_IN=arr_in,       $
                   D_AR_IN=d_ar_in,EX_A_IN=ex_a_in,NO_WRAP=no_wrap, $
                   SI_OUT=si_out,EI_OUT=ei_out,ARROUT=arrout,       $
                   D_AROUT=d_arout
HELP,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout
;SI__IN          LONG      =         5703
;EI__IN          LONG      =         5713
;ARR_IN          LONG      = Array[6]
;D_AR_IN         LONG      =            2
;EX_A_IN         LONG      =            2
;SI_OUT          LONG      =         5711
;EI_OUT          LONG      =         5709
;ARROUT          LONG      = Array[10]
;D_AROUT         LONG      =            2
PRINT,';;',arr_in & $
PRINT,';;',arrout
;;        5703        5705        5707        5709        5711        5713
;;        5711        5713        5703        5705        5707        5709        5711        5713        5703        5705

;;  Cleanup to avoid previous definition contamination
DELVAR,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout,no_wrap
si__in         = 5703L          ;;  Valid start index
ei__in         = 5706L          ;;  Valid end   index
ex_a_in        = 2L             ;;  Valid expansion number
expand_index_array,SI__IN=si__in,EI__IN=ei__in,ARR_IN=arr_in,       $
                   D_AR_IN=d_ar_in,EX_A_IN=ex_a_in,NO_WRAP=no_wrap, $
                   SI_OUT=si_out,EI_OUT=ei_out,ARROUT=arrout,       $
                   D_AROUT=d_arout
HELP,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout
;SI__IN          LONG      =         5703
;EI__IN          LONG      =         5706
;ARR_IN          LONG      = Array[4]
;D_AR_IN         LONG      =            1
;EX_A_IN         LONG      =            2
;SI_OUT          LONG      =         5705
;EI_OUT          LONG      =         5704
;ARROUT          LONG      = Array[8]
;D_AROUT         LONG      =            1
PRINT,';;',arr_in & $
PRINT,';;',arrout
;;        5703        5704        5705        5706
;;        5705        5706        5703        5704        5705        5706        5703        5704


DELVAR,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout,no_wrap
arr_in         = LINDGEN(5) + 5703L   ;;  Valid input array
ex_a_in        = 2L                   ;;  Valid expansion number
expand_index_array,SI__IN=si__in,EI__IN=ei__in,ARR_IN=arr_in,       $
                   D_AR_IN=d_ar_in,EX_A_IN=ex_a_in,NO_WRAP=no_wrap, $
                   SI_OUT=si_out,EI_OUT=ei_out,ARROUT=arrout,       $
                   D_AROUT=d_arout
HELP,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout
;SI__IN          LONG      =         5703
;EI__IN          LONG      =         5707
;ARR_IN          LONG      = Array[5]
;D_AR_IN         LONG      =            1
;EX_A_IN         LONG      =            2
;SI_OUT          LONG      =         5706
;EI_OUT          LONG      =         5705
;ARROUT          LONG      = Array[9]
;D_AROUT         LONG      =            1
PRINT,';;',arr_in & $
PRINT,';;',arrout
;;        5703        5704        5705        5706        5707
;;        5706        5707        5703        5704        5705        5706        5707        5703        5704


DELVAR,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout,no_wrap
arr_in         = LINDGEN(5) + 5703L   ;;  Valid input array
ex_a_in        = 2L                   ;;  Valid expansion number
no_wrap        = 1L                   ;;  Shut off array wrapping
expand_index_array,SI__IN=si__in,EI__IN=ei__in,ARR_IN=arr_in,       $
                   D_AR_IN=d_ar_in,EX_A_IN=ex_a_in,NO_WRAP=no_wrap, $
                   SI_OUT=si_out,EI_OUT=ei_out,ARROUT=arrout,       $
                   D_AROUT=d_arout
HELP,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout
;SI__IN          LONG      =         5703
;EI__IN          LONG      =         5707
;ARR_IN          LONG      = Array[5]
;D_AR_IN         LONG      =            1
;EX_A_IN         LONG      =            2
;SI_OUT          LONG      =         5701
;EI_OUT          LONG      =         5709
;ARROUT          LONG      = Array[9]
;D_AROUT         LONG      =            1
PRINT,';;',arr_in & $
PRINT,';;',arrout
;;        5703        5704        5705        5706        5707
;;        5701        5702        5703        5704        5705        5706        5707        5708        5709

DELVAR,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout,no_wrap
si__in         = 0L
ei__in         = 4L
ex_a_in        = 2L
no_wrap        = 1L                   ;;  Shut off array wrapping
expand_index_array,SI__IN=si__in,EI__IN=ei__in,ARR_IN=arr_in,       $
                   D_AR_IN=d_ar_in,EX_A_IN=ex_a_in,NO_WRAP=no_wrap, $
                   SI_OUT=si_out,EI_OUT=ei_out,ARROUT=arrout,       $
                   D_AROUT=d_arout
HELP,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout
;SI__IN          LONG      =            0
;EI__IN          LONG      =            4
;ARR_IN          LONG      = Array[5]
;D_AR_IN         LONG      =            1
;EX_A_IN         LONG      =            2
;SI_OUT          LONG      =           -2
;EI_OUT          LONG      =            6
;ARROUT          LONG      = Array[9]
;D_AROUT         LONG      =            1
PRINT,';;',arr_in & $
PRINT,';;',arrout
;;           0           1           2           3           4
;;          -2          -1           0           1           2           3           4           5           6

DELVAR,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout,no_wrap
si__in         = 0L
ei__in         = 4L
expand_index_array,SI__IN=si__in,EI__IN=ei__in,ARR_IN=arr_in,       $
                   D_AR_IN=d_ar_in,EX_A_IN=ex_a_in,NO_WRAP=no_wrap, $
                   SI_OUT=si_out,EI_OUT=ei_out,ARROUT=arrout,       $
                   D_AROUT=d_arout
HELP,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout
;SI__IN          LONG      =            0
;EI__IN          LONG      =            4
;ARR_IN          LONG      = Array[5]
;D_AR_IN         LONG      =            1
;EX_A_IN         LONG      =            1
;SI_OUT          LONG      =            4
;EI_OUT          LONG      =            3
;ARROUT          LONG      = Array[7]
;D_AROUT         LONG      =            1
PRINT,';;',arr_in & $
PRINT,';;',arrout
;;           0           1           2           3           4
;;           4           0           1           2           3           4           0

DELVAR,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout,no_wrap
arr_in         = LINDGEN(5) + 20L
expand_index_array,SI__IN=si__in,EI__IN=ei__in,ARR_IN=arr_in,       $
                   D_AR_IN=d_ar_in,EX_A_IN=ex_a_in,NO_WRAP=no_wrap, $
                   SI_OUT=si_out,EI_OUT=ei_out,ARROUT=arrout,       $
                   D_AROUT=d_arout
HELP,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout
;SI__IN          LONG      =           20
;EI__IN          LONG      =           24
;ARR_IN          LONG      = Array[5]
;D_AR_IN         LONG      =            1
;EX_A_IN         LONG      =            1
;SI_OUT          LONG      =           24
;EI_OUT          LONG      =           23
;ARROUT          LONG      = Array[7]
;D_AROUT         LONG      =            1
PRINT,';;',arr_in & $
PRINT,';;',arrout
;;          20          21          22          23          24
;;          24          20          21          22          23          24          20

DELVAR,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout,no_wrap
arr_in         = LINDGEN(5) + 20L
no_wrap        = 1b
expand_index_array,SI__IN=si__in,EI__IN=ei__in,ARR_IN=arr_in,       $
                   D_AR_IN=d_ar_in,EX_A_IN=ex_a_in,NO_WRAP=no_wrap, $
                   SI_OUT=si_out,EI_OUT=ei_out,ARROUT=arrout,       $
                   D_AROUT=d_arout
HELP,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout
;SI__IN          LONG      =           20
;EI__IN          LONG      =           24
;ARR_IN          LONG      = Array[5]
;D_AR_IN         LONG      =            1
;EX_A_IN         LONG      =            1
;SI_OUT          LONG      =           19
;EI_OUT          LONG      =           25
;ARROUT          LONG      = Array[7]
;D_AROUT         LONG      =            1
PRINT,';;',arr_in & $
PRINT,';;',arrout
;;          20          21          22          23          24
;;          19          20          21          22          23          24          25

DELVAR,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout,no_wrap
arr_in         = LINDGEN(5) + 20L
si__in         = 0L
ei__in         = 4L
d_ar_in        = 2L
expand_index_array,SI__IN=si__in,EI__IN=ei__in,ARR_IN=arr_in,       $
                   D_AR_IN=d_ar_in,EX_A_IN=ex_a_in,NO_WRAP=no_wrap, $
                   SI_OUT=si_out,EI_OUT=ei_out,ARROUT=arrout,       $
                   D_AROUT=d_arout
HELP,si__in,ei__in,arr_in,d_ar_in,ex_a_in,si_out,ei_out,arrout,d_arout
;SI__IN          LONG      =           20
;EI__IN          LONG      =           24
;ARR_IN          LONG      = Array[5]
;D_AR_IN         LONG      =            1
;EX_A_IN         LONG      =            1
;SI_OUT          LONG      =           24
;EI_OUT          LONG      =           23
;ARROUT          LONG      = Array[7]
;D_AROUT         LONG      =            1
PRINT,';;',arr_in & $
PRINT,';;',arrout
;;          20          21          22          23          24
;;          24          20          21          22          23          24          20



;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  General string routines
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  str = get_general_char_name(all_pos_ch [,CHARS=chars] [,DEF__NAME=def__name])
;;----------------------------------------------------------------------------------------
;;  ***  INCORRECT calling sequence  ***
all_probes     = ['a','b','c','d','e','f']
def_probe      = 'h'
probe          = 'k'
sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
PRINT,';;  ',sat[0]
;;  a

;;  ***  INCORRECT calling sequence  ***
all_probes     = ['a','b','c','d','e','f']
def_probe      = 'd'
probe          = 1
sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
PRINT,';;  ',sat[0]
;;  d

;;  ***  INCORRECT calling sequence  ***
all_probes     = ['a','b','c','d','e','f']
def_probe      = 4.2
probe          = 'b'
sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
PRINT,';;  ',sat[0]
;;  b

;;  ***  INCORRECT calling sequence  ***
all_probes     = LINDGEN(5)
def_probe      = 'a'
probe          = 'b'
sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
;% GET_GENERAL_CHAR_NAME: User must supply an [N]-Element [string] array on input...
PRINT,';;  ',sat[0]
;;     0

;;============================================
;;  Examples:  Changes on return
;;============================================
;;  ***  INCORRECT calling sequence  ***
all_probes     = ['a','b','c','d','e','f']
def_probe      = 'h'
probe          = 'c'
sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
PRINT,';;  ',sat[0],'  ',def_probe[0]
;;  c  a

;;  ***  INCORRECT calling sequence  ***
all_probes     = ['a','b','c','d','e','f']
def_probe      = 'x'
probe          = 'y'
sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
PRINT,';;  ',sat[0],'  ',def_probe[0]
;;  a  a

;;  ***  INCORRECT calling sequence  ***
all_probes     = 0
dummy          = TEMPORARY(all_probes)     ;;  Method to undefine variable
HELP,all_probes,OUTPUT=output
FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  ',output[j]
;;  ALL_PROBES      UNDEFINED = <Undefined>
def_probe      = 'a'
probe          = 'c'
sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
;% GET_GENERAL_CHAR_NAME: User must supply an [N]-Element [string] array on input...
PRINT,';;  ',sat[0],'  ',def_probe[0]
;;     0  a

;;============================================
;;  Examples:  Calling sequence
;;============================================
;;  ***  CORRECT calling sequence  ***
all_probes     = ['a','b','c','d','e','f']
def_probe      = 'a'
probe          = 'f'
sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
PRINT,';;  ',sat[0]
;;  f


;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  fnstruc = file_name_times(tt [,PREC=prec] [,FORMFN=formfn])
;;----------------------------------------------------------------------------------------
tnrt           = ['1998-09-24/21:40:00','1998-09-25/01:40:00']
fnstruc        = file_name_times(tnrt,PREC=5)
HELP,fnstruc
;** Structure <174d038>, 5 tags, length=144, data length=144, refs=1:
;   F_TIME          STRING    Array[2]
;   UT_TIME         STRING    Array[2]
;   UNIX            DOUBLE    Array[2]
;   TIME            STRING    Array[2]
;   DATE            STRING    Array[2]
PRINT,';;', fnstruc.F_TIME
;; 1998-09-24_2140x00.00000 1998-09-25_0140x00.00000

;;  Try non-default output format
tnrt           = ['1998-09-24/21:40:00','1998-09-25/01:40:00']
fnstruc        = file_name_times(tnrt,PREC=5,FORMFN=3)
PRINT,';;', fnstruc.F_TIME
;; 19980924_2140-00x00000 19980925_0140-00x00000


;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  all_tdates = fill_tdates_btwn_start_end( tdate_st, tdate_en)
;;----------------------------------------------------------------------------------------
tdate_st       = '1998-09-24'
tdate_en       = '1998-09-28'
PRINT,';;', fill_tdates_btwn_start_end(tdate_st[0],tdate_en[0])
;; 1998-09-24 1998-09-25 1998-09-26 1998-09-27 1998-09-28

tdate_st       = '1996-12-30'
tdate_en       = '1997-01-07'
PRINT,';;', fill_tdates_btwn_start_end(tdate_st[0],tdate_en[0])
;; 1996-12-30 1996-12-31 1997-01-01 1997-01-02 1997-01-03 1997-01-04 1997-01-05 1997-01-06 1997-01-07


;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  files = general_find_files_from_trange(base_dir, date_form [,TDATE=tdate] $
;;                                    [,TRANGE=trange] [,FILE_PREF=file_pref] $
;;                                    [,FILE_SUFF=file_suff])
;;----------------------------------------------------------------------------------------
;;  Default CDF file location [i.e., location of Wind MFI H0 files]
def_cdfloc     = '.'+slash[0]+'wind_3dp_pros'+slash[0]+'wind_data_dir'+slash[0]+$
                 'MFI_CDF'+slash[0]
cdfdir         = add_os_slash(FILE_EXPAND_PATH(def_cdfloc[0]))
date_form      = 'YYYYMMDD'     ;;  Define date format (see Man. page for all possible forms)
;;  Define a valid time range
ymdb__st       = '1996-12-30/00:00:00.000'
ymdb__en       = '1997-01-07/00:00:00.000'
trange         = time_double([ymdb__st[0],ymdb__en[0]])
;;  Find files
files          = general_find_files_from_trange(cdfdir[0],date_form[0],TRANGE=trange)
PRINT,files
/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_data_dir/MFI_CDF/wi_h0_mfi_19961230_v05.cdf
/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_data_dir/MFI_CDF/wi_h0_mfi_19961231_v05.cdf
/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_data_dir/MFI_CDF/wi_h0_mfi_19970101_v05.cdf
/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_data_dir/MFI_CDF/wi_h0_mfi_19970102_v05.cdf
/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_data_dir/MFI_CDF/wi_h0_mfi_19970103_v05.cdf
/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_data_dir/MFI_CDF/wi_h0_mfi_19970104_v05.cdf
/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_data_dir/MFI_CDF/wi_h0_mfi_19970105_v05.cdf
/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_data_dir/MFI_CDF/wi_h0_mfi_19970106_v05.cdf
/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_data_dir/MFI_CDF/wi_h0_mfi_19970107_v05.cdf


;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  int_str = num2int_str( input [,NUM_CHAR=num_char] [,/NO_TRIM] [,/ZERO_PAD])
;;----------------------------------------------------------------------------------------
;;  Output WITHOUT excess empty spaces
input          = 15
num_char       = 5L
PRINT,';;', num2int_str(input,NUM_CHAR=num_char)
;;15

;;  Output WITH excess empty spaces
PRINT,';;', num2int_str(input,NUM_CHAR=num_char,/NO_TRIM)
;;   15

;;  Output WITH zeros in excess empty spaces
PRINT,';;', num2int_str(input,NUM_CHAR=num_char,/NO_TRIM,/ZERO_PAD)
;;00015

;;  Output WITH excess empty spaces but use default character width
input          = 15
PRINT,';;', num2int_str(input,/NO_TRIM)
;;          15

;;  Output WITH excess empty spaces replaced with zeros and use default character width
input          = 15
PRINT,';;', num2int_str(input,/NO_TRIM,/ZERO_PAD)
;;000000000015

;;  Make sure NUM_CHAR is large enough otherwise output is a string of asterisks
;;    NUM_CHAR characters in length [e.g., see below]
input          = [-2,300,5e5,4d0,15]
num_char       = 4L
PRINT,';;', num2int_str(input,NUM_CHAR=num_char)
;; -2 300 **** 4 15

PRINT,';;  ', num2int_str(input,NUM_CHAR=num_char,/NO_TRIM)
;;     -2  300 ****    4   15

;;  Use large enough NUM_CHAR
input          = [-2,300,5e5,4d0,15]
num_char       = 15L
PRINT,';;', num2int_str(input,NUM_CHAR=num_char,/NO_TRIM)
;;              -2             300          500000               4              15



;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  General prompt routine
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  val__out = general_prompt_routine([test_in] [,STR_OUT=str_out]         $
;;                                    [,PRO_OUT=pro_out] [,ERRMSG=errmsg]  $
;;                                    [,FORM_OUT=form_out]                 )
;;----------------------------------------------------------------------------------------
;;************************************
;;  For additional usage examples and possible error handling options, see also
;;    get_valid_trange.pro
;;************************************
yearmin        = 1957L                   ;;  Year Sputnik 1 spacecraft was launched --> cannot start before this
yearmax        = 2017L                   ;;  Year as of the creation of this crib sheet
;;  Define instructions at prompt
pro_out        = ["Here I attempt to illustrate one possible use of the PRO_OUT",$
                  "keyword and the resulting output seen by the user.  Please",  $
                  "forgive my verbose pontification beyond the first sentence,", $
                  "as anything else is really unnecessary other than to provide",$
                  "a specific example."]
;;  Define specific prompts
prompt_yy      = "Please enter a year between "+num2int_str(yearmin[0],NUM_CHAR=4)+$
                 " and "+num2int_str(yearmax[0],NUM_CHAR=4)+" [YYYY]:"
prompt_mm      = "Please enter a month between 1 and 12 [MM]:"
prompt_dd      = "Please enter a day between 1 and 31 [DD]:"
;;  Initialization values for type codes
read_out       = 0L
val__out       = 0L
;;  Ask user for year of interest
val__out       = general_prompt_routine(read_out,STR_OUT=prompt_yy[0],PRO_OUT=pro_out)
;;************************************
;;  The immediate following is the output to the screen and would not normally
;;  have the preceeding semi-colons, which were added to prevent future users from
;;  entering these lines into IDL.
;;************************************
;
;-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
;Here I attempt to illustrate one possible use of the PRO_OUT
;keyword and the resulting output seen by the user.  Please
;forgive my verbose pontification beyond the first sentence,
;as anything else is really unnecessary other than to provide
;a specific example.
;-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
;
;
;=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
;Please enter a year between 1957 and 2017 [YYYY]:2001
;<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=
;
good_year      = val__out[0]
PRINT,';;',good_year[0]
;;        2001

;;  Ask user for month of interest
read_out       = 0L
val__out       = 0L
val__out       = general_prompt_routine(read_out,STR_OUT=prompt_mm[0])
;;************************************
;;  As one can see below, the routine does not stop the user from entering "bad"
;;  values.   Thus, the user should incorporate error handling that ensures the
;;  output is valid and meaningful.
;;************************************
;
;=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
;Please enter a month between 1 and 12 [MM]:15
;<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=
;
good_mnth      = val__out[0]
PRINT,';;',good_mnth[0]
;;          15

;;  Ask user for day of month of interest
read_out       = 0L
val__out       = 0L
val__out       = general_prompt_routine(read_out,STR_OUT=prompt_dd[0])
;
;=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
;Please enter a day between 1 and 31 [DD]:10
;<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=
;
good_daym      = val__out[0]
PRINT,';;',good_daym[0]
;;          10



;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Useful time range definition routine
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  struc = get_valid_trange([,TDATE=tdate] [,TRANGE=trange] [,PRECISION=prec])
;;----------------------------------------------------------------------------------------
;;  Define a valid time range
ymdb__st       = '1996-12-30/00:00:00.000'
ymdb__en       = '1997-01-07/00:00:00.000'
trange         = time_double([ymdb__st[0],ymdb__en[0]])
tra_old        = trange
;;  TRANGE Usage
struc          = get_valid_trange(TRANGE=trange)
HELP,struc
;** Structure <2287a08>, 4 tags, length=88, data length=84, refs=1:
;   DATE_TRANGE     STRING    Array[2]
;   DOY_TRANGE      INT       Array[2]
;   STRING_TRANGE   STRING    Array[2]
;   UNIX_TRANGE     DOUBLE    Array[2]
PRINT,';;',struc.DATE_TRANGE   & $
PRINT,';;',struc.DOY_TRANGE    & $
PRINT,';;',struc.STRING_TRANGE & $
PRINT,';;',struc.UNIX_TRANGE - tra_old
;; 1996-12-30 1997-01-07
;;     365       7
;; 1996-12-30/00:00:00 1997-01-07/00:00:00
;;       0.0000000       0.0000000

;;  TRANGE and PRECISION Usage
trange         = tra_old
struc          = get_valid_trange(TRANGE=trange,PREC=3L)
PRINT,';;',struc.DATE_TRANGE   & $
PRINT,';;',struc.DOY_TRANGE    & $
PRINT,';;',struc.STRING_TRANGE & $
PRINT,';;',struc.UNIX_TRANGE - tra_old
;; 1996-12-30 1997-01-07
;;     365       7
;; 1996-12-30/00:00:00.000 1997-01-07/00:00:00.000
;;       0.0000000       0.0000000

;;  TDATE Usage
tdate          = '1996-12-30'
struc          = get_valid_trange(TDATE=tdate)
PRINT,';;',struc.DATE_TRANGE   & $
PRINT,';;',struc.DOY_TRANGE    & $
PRINT,';;',struc.STRING_TRANGE & $
PRINT,';;',(struc.UNIX_TRANGE MOD 864d2)
;; 1996-12-30 1996-12-30
;;     365     365
;; 1996-12-30/00:00:00 1996-12-30/23:59:59
;;       0.0000000       86400.000

;;  TDATE and PRECISION Usage
tdate          = '1996-12-30'
struc          = get_valid_trange(TDATE=tdate,PREC=6L)
PRINT,';;',struc.DATE_TRANGE   & $
PRINT,';;',struc.DOY_TRANGE    & $
PRINT,';;',struc.STRING_TRANGE & $
PRINT,';;',(struc.UNIX_TRANGE MOD 864d2)
;; 1996-12-30 1996-12-30
;;     365     365
;; 1996-12-30/00:00:00.000000 1996-12-30/23:59:59.999999
;;       0.0000000       86400.000



;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Useful Fourier [box] bandpass filter routine
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  filt = vector_bandpass(dat, sr [,lf] [,hf] [,LOWF=lowf] [,MIDF=midf] $
;;                                     [,HIGHF=highf])
;;----------------------------------------------------------------------------------------
;;  Define some dummy arrays
nn             = 2L^16L
tt             = DINDGEN(nn)*(12d0*!DPI)/250d3
xx             = SIN(tt) + SIN(5*tt) + SIN(tt/120d0)
yy             = COS(tt) + COS(tt/120d0) + COS(tt/5) + COS(5*tt)
zz             = SIN(tt)*COS(tt) + COS(tt^2) + SIN(tt^2)
vec            = [[xx],[yy],[zz]]
HELP,vec
;VEC             DOUBLE    = Array[65536, 3]

PRINT,';;',MIN(vec,/NAN),MAX(vec,/NAN)
;;      -1.9607415       4.0000000

;;  Calculate sample rate [samples per second or sps]
srate          = sample_rate(tt,/AVERAGE)
PRINT,';;',srate[0]
;;       6631.4560

;;  Define low and high frequency [Hz] bounds for filter
lf             = 1d2        ;;  100 Hz
hf             = 1d3        ;;  1  kHz
;;***********************************************
;;  Perform bandpass filter
;;***********************************************
filt           = vector_bandpass(vec,srate[0],lf[0],hf[0],/MIDF)
PRINT,';;',MIN(filt,/NAN),MAX(filt,/NAN)
;;     -0.54069146       1.9458319

;;***********************************************
;;  Perform low-pass filter below 100 Hz
;;***********************************************
lf             = 1d2        ;;  100 Hz
hf             = 1d3        ;;  irrelevant here
lowpfilt       = vector_bandpass(vec,srate[0],lf[0],hf[0],/LOWF)
PRINT,';;',MIN(lowpfilt,/NAN),MAX(lowpfilt,/NAN)
;;      -2.0807097       3.6556768
;;**************************************************
;;  ***  larger values result from edge effects  ***
;;**************************************************


;;***********************************************
;;  Compare to bandpass with range 0--100 Hz
;;***********************************************
lf             = 0d0        ;;    0 Hz
hf             = 1d2        ;;  100 Hz
bandpfilt      = vector_bandpass(vec,srate[0],lf[0],hf[0],/MIDF)
diff           = bandpfilt - lowpfilt
PRINT,';;',MIN(bandpfilt,/NAN),MAX(bandpfilt,/NAN) & $
PRINT,';;',MIN(diff,/NAN),MAX(diff,/NAN)
;;      -2.0807097       3.6556768
;;       0.0000000       0.0000000

;;***********************************************
;;  Perform high-pass filter above 100 Hz
;;***********************************************
lf             = 0d0        ;;  irrelevant here
hf             = 1d2        ;;  100 Hz
highpfilt      = vector_bandpass(vec,srate[0],lf[0],hf[0],/HIGHF)
PRINT,';;',MIN(highpfilt,/NAN),MAX(highpfilt,/NAN)
;;     -0.53851182       1.9396829

;;***********************************************
;;  Compare to bandpass with range ≥100 Hz
;;***********************************************
lf             = 1d2           ;;  100 Hz
hf             = 2d0*srate[0]  ;;  set way above Nyquist frequency
bandpfilt      = vector_bandpass(vec,srate[0],lf[0],hf[0],/MIDF)
diff           = bandpfilt - highpfilt
PRINT,';;',MIN(bandpfilt,/NAN),MAX(bandpfilt,/NAN) & $
PRINT,';;',MIN(diff,/NAN),MAX(diff,/NAN)
;;     -0.53851182       1.9396829
;;       0.0000000       0.0000000



;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Useful intersection finding routine
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  find_intersect_2_curves, xx1, yy1, xx2, yy2 [,XY=xy] [,/SHOW_PLOT]
;;----------------------------------------------------------------------------------------
;;  Define some dummy arrays
nn1            = 2L^18L
nn2            = nn[0];*2L/3L
xx1            = DINDGEN(nn1[0])*(12d0*!DPI)/250d3;/(nn1[0] - 1L)
yy1            = SIN(xx1) + SIN(5*xx1) + SIN(xx1/120d0)
xx2            = DINDGEN(nn2[0])*(12d0*!DPI)/125d3;/(nn2[0] - 1L)
yy2            = COS(xx2) + COS(xx2/120d0) + COS(xx2/5) + COS(5*xx2)
find_intersect_2_curves,xx1,yy1,xx2,yy2,XY=xy
HELP,xy
;XY              DOUBLE    = Array[2, 20]

PRINT,';;',MIN(xx1,/NAN),MAX(xx1,/NAN) & $
PRINT,';;',MIN(xx2,/NAN),MAX(xx2,/NAN) & $
PRINT,';;',MIN(yy1,/NAN),MAX(yy1,/NAN) & $
PRINT,';;',MIN(yy2,/NAN),MAX(yy2,/NAN)
;;       0.0000000       39.530233
;;       0.0000000       19.764890
;;      -1.9607415       2.3214406
;;      -2.0085549       4.0000000

;;  Plot and show intersections
pstr           = {XRANGE:[0e0,2e1],YRANGE:[-1,1]*4.5,XSTYLE:1,YSTYLE:1,NODATA:1,$
                  XMINOR:5L,YMINOR:5}
;;  Open window for plot
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*7d-1
xysz           = MIN(wsz)
win_ttl        = 'Example Plot'
win_str        = {RETAIN:2,XSIZE:xysz[0],YSIZE:xysz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
WINDOW,1,_EXTRA=win_str
;;  Plot
WSET,1
WSHOW,1
!P.MULTI       = 0
PLOT,xx1,yy1,_EXTRA=pstr
  OPLOT,xx1,yy1,COLOR=250,THICK=2
  OPLOT,xx2,yy2,COLOR= 50,THICK=2
  OPLOT,REFORM(xy[0,*]),REFORM(xy[1,*]),COLOR=150,PSYM=2


;;***********************************************
;;  Additional examples
;;***********************************************

;;=================================================================
;;  Example 1 [show plot too]
;;=================================================================
x1             = [0.1,0.2,0.6,0.7]
x2             = [0.5,0.4,0.5,0.3]
y1             = [1,2,3,4]
y2             = y1
find_intersect_2_curves,x1,y1,x2,y2,XY=xy,/SHOW_PLOT
PRINT,';;',xy
;;      0.46666664       2.6666665

;;=================================================================
;;  Example 2 [horizontal line and sine wave]
;;=================================================================
n1             = 100L
n2             = 150L
x1             = DINDGEN(n1[0])*6d0*!DPI/(n1[0] - 1L)
y1             = SIN(x1)
x2             = DINDGEN(n2[0])*6d0*!DPI/(n2[0] - 1L)
y2             = REPLICATE(5d-1,n2[0])
find_intersect_2_curves,x1,y1,x2,y2,XY=xy,/SHOW_PLOT
HELP, xy
;XY              DOUBLE    = Array[2, 6]
FOR j=0L, N_ELEMENTS(xy[0,*]) - 1L DO PRINT,';;',REFORM(xy[*,j])
;;      0.52540586      0.50000000
;;       2.6158625      0.50000000
;;       6.8085912      0.50000000
;;       8.8990478      0.50000000
;;       13.091776      0.50000000
;;       15.182233      0.50000000

;;=================================================================
;;  Example 3 [straight line and sine wave]
;;=================================================================
n1             = 150L
n2             = 100L
x1             = DINDGEN(n1[0])*6d0*!DPI/(n1[0] - 1L)
y1             = SIN(x1)
x2             = DINDGEN(n2[0])*6d0*!DPI/(n2[0] - 1L)
y2             = x2/(3d0*!DPI) - 1d0
find_intersect_2_curves,x1,y1,x2,y2,XY=xy,/SHOW_PLOT
HELP, xy
;XY              DOUBLE    = Array[2, 5]
FOR j=0L, N_ELEMENTS(xy[0,*]) - 1L DO PRINT,';;',REFORM(xy[*,j])
;;       3.7837324     -0.59853353
;;       5.8989870     -0.37409804
;;       9.4247780   5.0306981e-17
;;       12.950569      0.37409804
;;       15.065824      0.59853353



;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Useful vectorized 3x3 matrix multiplication routine
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  [calling sequence]
;;  c_matrix = vm_matrix(a_matrix, b_matrix)
;;----------------------------------------------------------------------------------------
;;  Define Euler rotation matrix for 30 degrees about the Z-Axis
zrot           = eulermat(0d0,3d1,0d0,/DEG)
;;  Define Euler rotation matrix for 180 degrees about the X-Axis
xrot           = eulermat(0d0,0d0,18d1,/DEG)
;;  Define single matrix combining two rotations
brot           = eulermat(0d0,3d1,18d1,/DEG)
FOR j=0L, 2L DO PRINT,';;',zrot[*,j]
FOR j=0L, 2L DO PRINT,';;',xrot[*,j]
FOR j=0L, 2L DO PRINT,';;',brot[*,j]
FOR j=0L, 2L DO PRINT,';;',(zrot # xrot)[*,j]
FOR j=0L, 2L DO PRINT,';;',(xrot ## zrot)[*,j]
;;      0.86602540      0.50000000       0.0000000
;;     -0.50000000      0.86602540       0.0000000
;;       0.0000000      -0.0000000       1.0000000
;;
;;       1.0000000       0.0000000       0.0000000
;;      -0.0000000      -1.0000000   1.2246468e-16
;;       0.0000000  -1.2246468e-16      -1.0000000
;;
;;      0.86602540      0.50000000       0.0000000
;;      0.50000000     -0.86602540   1.2246468e-16
;;   6.1232340e-17  -1.0605752e-16      -1.0000000
;;
;;      0.86602540      0.50000000       0.0000000
;;      0.50000000     -0.86602540   1.2246468e-16
;;   6.1232340e-17  -1.0605752e-16      -1.0000000
;;
;;      0.86602540      0.50000000       0.0000000
;;      0.50000000     -0.86602540   1.2246468e-16
;;   6.1232340e-17  -1.0605752e-16      -1.0000000


;;  Create a bunch of copies of these matrices
nn             = 1000L
dumb           = REPLICATE(0d0,nn[0],3L,3L)
a_matrix       = dumb
b_matrix       = dumb
FOR j=0L, nn[0] - 1L DO BEGIN                      $
  a_matrix[j,*,*] = xrot                         & $
  b_matrix[j,*,*] = zrot

;;  Compare computation times
;;    Benchmarked on Late-2013 15-inch Macbook Pro with
;;      Processor:  2.6 GHz Intel Core i7
;;      Memory   :  16 GB 1600 MHz DDR3

;;  *** Slowest ***
amat           = a_matrix
bmat           = b_matrix
c_matrix0      = dumb
ex_start       = SYSTIME(1)                ;;  start time
FOR k=0L, nn[0] - 1L DO BEGIN                      $
  FOR i=0L, 2L DO BEGIN                            $
    FOR j=0L, 2L DO BEGIN                          $
      c_matrix0[k,j,i] = TOTAL(REFORM(a_matrix[k,*,i])*REFORM(b_matrix[k,j,*]),/NAN)
ex__end0       = SYSTIME(1) - ex_start[0]  ;;  end   time
PRINT,';;  Computation time [s]:  ',ex__end0[0]
;;  Computation time [s]:       0.019510031

;;  *** Medium ***
amat           = a_matrix
bmat           = b_matrix
c_matrix1      = dumb
ex_start       = SYSTIME(1)                ;;  start time
FOR j=0L, nn[0] - 1L DO BEGIN                      $
  c_matrix1[j,*,*] = REFORM(REFORM(a_matrix[j,*,*]) ## REFORM(b_matrix[j,*,*]))
ex__end1       = SYSTIME(1) - ex_start[0]  ;;  end   time
PRINT,';;  Computation time [s]:  ',ex__end1[0]
;;  Computation time [s]:      0.0082859993

;;  *** Fastest ***
amat           = a_matrix
bmat           = b_matrix
ex_start       = SYSTIME(1)                ;;  start time
c_matrix2      = vm_matrix(amat,bmat)
ex__end2       = SYSTIME(1) - ex_start[0]  ;;  end   time
PRINT,';;  Computation time [s]:  ',ex__end2[0]
;;  Computation time [s]:      0.0040540695

diff10         = c_matrix1 - c_matrix0
diff20         = c_matrix2 - c_matrix0
PRINT,';;',MIN(diff10,/NAN),MAX(diff10,/NAN) & $
PRINT,';;',MIN(diff20,/NAN),MAX(diff20,/NAN)
;;       0.0000000       0.0000000
;;       0.0000000       0.0000000

PRINT,';;  Computation time reduction factors:' & $
PRINT,';;',ex__end0[0]/ex__end1[0],ex__end0[0]/ex__end2[0]
;;  Computation time reduction factors:
;;       2.3545779       4.8124559











































































































































