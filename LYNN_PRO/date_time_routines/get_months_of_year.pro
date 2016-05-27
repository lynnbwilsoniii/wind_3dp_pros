;+
;*****************************************************************************************
;
;  FUNCTION :   get_months_of_year.pro
;  PURPOSE  :   This routine returns a structure containing the months of the year as
;                 strings and integers in various forms.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               test = get_months_of_year()
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/26/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/26/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_months_of_year

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
tags           = ['MONTH_STRING','MONTH_3LETTERS','MONTH_INT','MONTH_STR_INT']
;;----------------------------------------------------------------------------------------
;;  Define strings associated with the months of the year
;;----------------------------------------------------------------------------------------
months_str     = ['January','February','March','April','May','June','July','August',$
                  'September','October','November','December']
months_3let    = STRMID(months_str[*],0L,3L)         ;;  e.g., 'Jan'
months_int     = LINDGEN(N_ELEMENTS(months_str)) + 1L
months_sint    = STRING(months_int,FORMAT='(I2.2)')  ;;  e.g., '01'
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
struc          = CREATE_STRUCT(tags,months_str,months_3let,months_int,months_sint)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END