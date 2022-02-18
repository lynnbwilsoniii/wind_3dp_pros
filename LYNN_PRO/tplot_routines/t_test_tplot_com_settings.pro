;+
;*****************************************************************************************
;
;  FUNCTION :   t_test_tplot_com_settings.pro
;  PURPOSE  :   This routine checks to see if the TPLOT_COM common block variables
;                 have been properly set.  The output is a bitwise value that informs
;                 the user of what has and has not been set, defined as:
;                     0  :  Nothing is set
;                     1  :  Only the reference date, REFDATE tag, is set
;                     2  :  Only the TRANGE tag is set
;                     4  :  Only the TRANGE_CUR is set
;                     8  :  Only the TRANGE_FULL is set
;                    16  :  Only the TRANGE_OLD is set
;                 Combinations
;                     3 = 1 + 2               :  Both REFDATE and TRANGE are set
;                     5 = 1 + 4               :  Both REFDATE and TRANGE_CUR are set
;                     6 = 2 + 4               :  Both TRANGE and TRANGE_CUR are set
;                     7 = 1 + 2 + 4           :  The REFDATE, TRANGE, and TRANGE_CUR are set
;                     9 = 1 + 8               :  Both REFDATE and TRANGE_FULL are set
;                    10 = 2 + 8               :  Both TRANGE and TRANGE_FULL
;                    11 = 1 + 2 + 8           :  REFDATE, TRANGE, and TRANGE_FULL
;                    12 = 4 + 8               :  Both TRANGE_CUR and TRANGE_FULL
;                    13 = 1 + 4 + 8           :  REFDATE, TRANGE_CUR, and TRANGE_FULL
;                    14 = 2 + 4 + 8           :  TRANGE, TRANGE_CUR, and TRANGE_FULL
;                    15 = 1 + 2 + 4 + 8       :  REFDATE, TRANGE, TRANGE_CUR, and TRANGE_FULL
;                    17 = 1 + 16              :  Both REFDATE and TRANGE_OLD
;                    18 = 2 + 16              :  Both TRANGE and TRANGE_OLD
;                    19 = 1 + 2 + 16          :  REFDATE, TRANGE, and TRANGE_OLD
;                    20 = 4 + 16              :  Both TRANGE_CUR and TRANGE_OLD
;                    21 = 1 + 4 + 16          :  REFDATE, TRANGE_CUR, and TRANGE_OLD
;                    22 = 2 + 4 + 16          :  TRANGE, TRANGE_CUR, and TRANGE_OLD
;                    23 = 1 + 2 + 4 + 16      :  REFDATE, TRANGE, TRANGE_CUR, and TRANGE_OLD
;                    24 = 8 + 16              :  Both TRANGE_FULL and TRANGE_OLD
;                    25 = 1 + 8 + 16          :  REFDATE, TRANGE_FULL, and TRANGE_OLD
;                    26 = 2 + 8 + 16          :  TRANGE, TRANGE_FULL, and TRANGE_OLD
;                    27 = 1 + 2 + 8 + 16      :  REFDATE, TRANGE, TRANGE_FULL, and TRANGE_OLD
;                    28 = 4 + 8 + 16          :  TRANGE_CUR, TRANGE_FULL, and TRANGE_OLD
;                    29 = 1 + 4 + 8 + 16      :  REFDATE, TRANGE_CUR, TRANGE_FULL, and TRANGE_OLD
;                    30 = 2 + 4 + 8 + 16      :  TRANGE, TRANGE_CUR, TRANGE_FULL, and TRANGE_OLD
;                    31 = 1 + 2 + 4 + 8 + 16  :  REFDATE, TRANGE, TRANGE_CUR, TRANGE_FULL, and TRANGE_OLD
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               tplot_com.pro
;               str_element.pro
;               test_tdate_format.pro
;               test_plot_axis_range.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               test = t_test_tplot_com_settings([,REFDATE=refdate] [,TRANGE=trange]     $
;                                     [,CUR_TRANGE=cur_trange] [,FULL_TRANGE=ful_trange] $
;                                     [,OLD_TRANGE=old_trange])
;
;  KEYWORDS:    
;               REFDATE      :  Set to a named variable to return the scalar [string]
;                                 reference date
;               TRANGE       :  Set to a named variable to return the [2]-element
;                                 [numeric] array defining the time range
;               TRANGE_CUR   :  Set to a named variable to return the [2]-element
;                                 [numeric] array defining the current time range
;               TRANGE_FULL  :  Set to a named variable to return the [2]-element
;                                 [numeric] array defining the full time range
;               TRANGE_OLD   :  Set to a named variable to return the [2]-element
;                                 [numeric] array defining the previous time range
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See above for definition of output possibilities
;
;  REFERENCES:  
;               NA
;
;   CREATED:  06/30/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/30/2021   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION t_test_tplot_com_settings,REFDATE=refdate,TRANGE=trange_set,CUR_TRANGE=trange_cur,$
                                   FULL_TRANGE=trange_ful,OLD_TRANGE=trange_old

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Set defaults
test_rdate     = 0b
test_trset     = 0b
test_trcur     = 0b
test_trful     = 0b
test_trold     = 0b
;;----------------------------------------------------------------------------------------
;;  Load common block
;;----------------------------------------------------------------------------------------
@tplot_com.pro
;;----------------------------------------------------------------------------------------
;;  Define common block variables
;;----------------------------------------------------------------------------------------
;;  Determine current settings
str_element,tplot_vars,'OPTIONS.REFDATE'     ,refdate
str_element,tplot_vars,'OPTIONS.TRANGE'      ,trange_set
str_element,tplot_vars,'OPTIONS.TRANGE_CUR'  ,trange_cur
str_element,tplot_vars,'OPTIONS.TRANGE_FULL' ,trange_ful
str_element,tplot_vars,'SETTINGS.TRANGE_OLD' ,trange_old
;;  Check if old settings need to be defined
test_rdate     = test_tdate_format(refdate,/NOMSSG)           ;;  1
test_trset     = test_plot_axis_range(trange_set,/NOMSSG)     ;;  2
test_trcur     = test_plot_axis_range(trange_cur,/NOMSSG)     ;;  4
test_trful     = test_plot_axis_range(trange_ful,/NOMSSG)     ;;  8
test_trold     = test_plot_axis_range(trange_old,/NOMSSG)     ;;  16
;;  Define output test
test           = 0b + test_rdate[0]
IF (test_trset[0]) THEN test += 2b
IF (test_trcur[0]) THEN test += 4b
IF (test_trful[0]) THEN test += 8b
IF (test_trold[0]) THEN test += 16b
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,test
END

