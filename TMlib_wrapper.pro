;+
;*****************************************************************************************
;
;  FUNCTION :   TMlib_wrapper.pro
;  PURPOSE  :   Compiles STEREO TM-Library software if available.
;
;  CALLED BY:   
;               start_umn_3dp.pro
;
;  CALLS:
;               TMlib.pro
;               TMlib_Time.pro
;               TM_Client_Info.pro
;
;  REQUIRES:    
;               TMlib software package for STEREO
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               @TMlib_wrapper
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  10/22/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/22/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
FORWARD_FUNCTION TMlib, TMlib_Time, TM_Client_Info

.compile TMlib.pro
.compile TMlib_Time.pro
err = TM_Client_Info()
