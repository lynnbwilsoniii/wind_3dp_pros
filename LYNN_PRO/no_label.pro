;+
;*****************************************************************************************
;
;  FUNCTION :   no_label.pro
;  PURPOSE  :   This function used to stop labeling of tick marks for plotting over a
;                 previous plot.
;
;  CALLED BY:   
;               oplot_tplot_spec.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               AXIS   :  The plot axis number (0=X, 1=Y, 2=Z)
;               INDEX  :  Tick mark index [indices start at zero]
;               T      :  Data value at tick mark [Double]
;
;  EXAMPLES:    
;               ; => To suppress X-Axis labels
;               x = FINDGEN(20)*(2d0*!DPI)/19L
;               y = SIN(x)
;               PLOT, x, y, XTICKFORMAT='no_label'
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This program assumes the [XYZ]TICKUNITS keyword[s] is[are] 
;                     NOT specified
;
;   CREATED:  09/13/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/13/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION no_label, axis, index, t

RETURN, " "
END
