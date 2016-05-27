;+
;*****************************************************************************************
;
;  PROCEDURE:   beam_fit_list_options.pro
;  PURPOSE  :   Prints to screen all the optional values allowed for user input
;                 and their purpose.
;
;  CALLED BY:   
;               beam_fit_options.pro
;               wrapper_beam_fit_array.pro
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
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Continued to write routine                       [08/27/2012   v1.0.0]
;             2)  Continued to write routine                       [08/28/2012   v1.0.0]
;             3)  Continued to write routine                       [08/31/2012   v1.0.0]
;             4)  Continued to write routine                       [09/07/2012   v1.0.0]
;
;   NOTES:      
;               1)  Only used by wrapper_beam_fit_array.pro
;               2)  All of these options can be set initially when calling
;                     wrapper_beam_fit_array.pro using the associated keywords
;
;   CREATED:  08/25/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/07/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO beam_fit_list_options


PRINT,""
PRINT,"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
PRINT,"----------------------- WRAPPER_BEAM_FIT_ARRAY COMMANDS ------------------------"
;; => Options:  Output and control
;PRINT,"print      print output..."
PRINT,"q          quit [Enter at any time to leave program]"
;; => Options:  Plotting DFs
PRINT,""
PRINT,"zrange     change the DF range of the contour and cut plots"
PRINT,"zfloor     change the Min. DF-value to allow in plots"
PRINT,"zceil      change the Max. DF-value to allow in plots"
PRINT,"vrange     change the velocity range of the plots"
PRINT,"nsmooth    change the number of points to smooth in the plots"
PRINT,"plane      change the plane of projection in contour plots"
PRINT,"sm_con     if set, then smooth [NSMOOTH pts] contour plots"
PRINT,"sm_cut     if set, then smooth [NSMOOTH pts] cut plots"
;; => Options:  DF Parameters
PRINT,"vbulk      change the bulk flow velocity estimate"
PRINT,"vcmax      change the magnitude/radius of the 'core' velocity circle"
PRINT,"vbmax      change the magnitude/radius of the 'beam' velocity circle"
PRINT,"vbeam      change the X- and Y-component of the 'beam' velocity"
PRINT,"vb_reg     define a rectangular velocity region around 'beam'"
;; => Options:  Fitting DFs
PRINT,""
PRINT,"zfill      change the DF-value used for MISSING points"
PRINT,"zperc      change the lowest % of the peak DF to use in fits"
;; => Options:  Changing between DFs
PRINT,""
PRINT,"next       switch to next particle distribution"
PRINT,"prev       switch to previous particle distribution"
PRINT,"index      choose an index for the particle distribution"
PRINT,"--------------------------------------------------------------------------------"
PRINT,"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
PRINT,""


END


