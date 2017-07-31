;+
;*****************************************************************************************
;
;  PROCEDURE:   vbulk_change_list_options.pro
;  PURPOSE  :   Prints to screen all the optional values allowed for user input
;                 and their purpose.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
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
;               [calling sequence]
;               vbulk_change_list_options
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/17/2017   v1.0.0]
;             2)  Continued to write routine
;                                                                   [07/25/2017   v1.0.0]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/16/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/25/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO vbulk_change_list_options

;;----------------------------------------------------------------------------------------
;;  Print options to screen
;;----------------------------------------------------------------------------------------
PRINT,""
PRINT,"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
PRINT,"------------------------ POSSIBLE VBULK CHANGE COMMANDS ------------------------"
;;  Options:  Output and control
PRINT,"q          quit [Enter at any prompt to exit]"
;;  Options:  Plotting DFs
PRINT,""
PRINT,"zrange     change the DF range of the contour and cut plots"
PRINT,"zfloor     change the Min. DF-value to allow in plots"
PRINT,"zceil      change the Max. DF-value to allow in plots"
PRINT,"vrange     change the velocity range of contour plots"
PRINT,""
PRINT,"plane      change the plane of projection in contour plots"
PRINT,""
PRINT,"nsmcut     change the number of points to smooth in the contour plots"
PRINT,"nsmcon     change the number of points to smooth in the 1D cut plots"
PRINT,"sm_cut     change the smooth [NSMCUT pts] setting for 1D cut plots"
PRINT,"sm_con     change the smooth [NSMCON pts] setting for contour plots"
;;  Options:  DF Parameters
PRINT,""
PRINT,"vbulk      change the bulk flow velocity estimate"
PRINT,"vec1       change the 'parallel' or 'X' vector for orthonormal coordinate basis"
PRINT,"vec2       change the 2nd vector for constructing orthonormal coordinate basis"
PRINT,"v_0x       change the origin of vertical cut line in contour plots"
PRINT,"v_0y       change the origin of horizontal cut line in contour plots"
;;  Options:  Changing between DFs
PRINT,""
PRINT,"next       switch to next particle distribution"
PRINT,"prev       switch to previous particle distribution"
PRINT,"index      choose an index for the particle distribution"
;;  Options:  Printing/Saving
PRINT,""
PRINT,"save1      save the currently shown particle distribution plot"
PRINT,"save3      save all three planes of the current particle distribution"
PRINT,"--------------------------------------------------------------------------------"
PRINT,"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
PRINT,""
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END



;PRINT,"vcmax      change the magnitude/radius of the 'core' velocity circle"
;PRINT,"vbmax      change the magnitude/radius of the 'beam' velocity circle"
;PRINT,"vbeam      change the X- and Y-component of the 'beam' velocity"
;PRINT,"vb_reg     define a rectangular velocity region around 'beam'"
;;;  Options:  Fitting DFs
;PRINT,""
;PRINT,"zfill      change the DF-value used for MISSING points"
;PRINT,"zperc      change the lowest % of the peak DF to use in fits"
