;+
;*****************************************************************************************
;
;  FUNCTION :   my_histogram.pro
;  PURPOSE  :   Program returns a structure with all the relevant plot and data 
;                 information needed to make a histogram plot.  The structure
;                 contains substructures which are as follows:
;                   1)  REC   =  contains locations of the corners of the histogram
;                                  rectangles used in plotting with POLYFILL.PRO
;                   2)  CPLOT =  contains a plot structure for counts
;                   3)  PPLOT =  contains a plot structure for percentages
;                 [Note:  CPLOT and PPLOT are used in the plot rountine as follows:
;                          _EXTRA=myhist.PPLOT or _EXTRA=myhist.CPLOT, where
;                          _EXTRA is a keyword in PLOT.PRO]
;
;  CALLED BY:
;               my_histogram_plot.pro
;
;  CALLS:
;               my_histogram_bins.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               M1      :  An N-Element array of data to be used for the histogram
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               NBINS   :  A scalar used to define the number of bins used to make the
;                            histogram [Default = 8]
;               DRANGE  :  Set to a 2-Element array to force bins to be determined by
;                            the range given in array instead of data
;                            [Useful for plotting multiple things on the same scales]
;               YRANGEC :  A scalar used to define the max y-range value for counts
;               YRANGEP :  A scalar used to define the max y-range value for percent
;                            [Best results if both YRANGEC and YRANGEP are set]
;               PREC    :  Scalar defining the precision of the X-Axis bin range labels
;                            [Default = 2 for 8 bins or less, 1 for >8 bins]
;
;   CHANGED:  1)  Changed the YRANGE for the percentage data [01/13/2009   v1.0.1]
;             2)  Changed the XRANGE for both plots          [01/13/2009   v1.0.2]
;             3)  Added keyword : DRANGE                     [01/24/2009   v1.0.3]
;             4)  Added keywords: YRANGEC and YRANGEP        [01/24/2009   v1.0.4]
;             5)  Fixed possible issue if one enters a 2-Element array for either
;                   keyword YRANGEC or YRANGEP               [06/03/2009   v1.0.5]
;             6)  Added keyword :  PREC                      [03/31/2011   v1.0.6]
;
;   CREATED:  01/05/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/31/2011   v1.0.6
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION my_histogram,m1,NBINS=nbins,DRANGE=drange,YRANGEC=yrangec,$
                         YRANGEP=yrangep,PREC=prec

;-----------------------------------------------------------------------------------------
; => Bin data into defined number of data bins
;-----------------------------------------------------------------------------------------
v1pts   = N_ELEMENTS(m1)
v1      = REFORM(m1)
mybs    = my_histogram_bins(v1,NBINS=nbins,DRANGE=drange,PREC=prec)
;-----------------------------------------------------------------------------------------
; => Define bin locations for output
;-----------------------------------------------------------------------------------------
nb      = N_ELEMENTS(mybs.HEIGHT_C)
binvals = DINDGEN(nb) - 5d-1   ; => Use for XTICKV keyword in plot
;-----------------------------------------------------------------------------------------
; => Define rectangular area for histogram plots
;-----------------------------------------------------------------------------------------
binleft  = binvals - 25d-2
binright = binvals + 25d-2
xx1      = DBLARR(nb,4L)      ; => X-Locations of corners of rectangle
yy1c     = DBLARR(nb,4L)      ; => Y-Locations of corners of rectangle (counts)
yy1p     = DBLARR(nb,4L)      ; => Y-Locations of corners of rectangle (percentage)
ymins    = REPLICATE(0d0,nb)  ; => Min Y-Location of rectangle corners

xx1      = [[binleft],[binright],[binright],[binleft]]
yy1c     = [[ymins],[ymins],[mybs.HEIGHT_C],[mybs.HEIGHT_C]]
yy1p     = [[ymins],[ymins],[mybs.HEIGHT_P],[mybs.HEIGHT_P]]
;-----------------------------------------------------------------------------------------
; => Define plot structure information
;-----------------------------------------------------------------------------------------
;xrac  = [MIN(binleft[1:(nb-1L)],/NAN),MAX(xx1,/NAN)]
xrac  = [2d-1,MAX(xx1,/NAN) + 5d-1]
IF NOT KEYWORD_SET(yrangec) THEN BEGIN          ; => Use data to set range
  yrac  = [0d0,MAX(mybs.HEIGHT_C,/NAN)*1.05d0]  ; => Y-Range for counts
ENDIF ELSE BEGIN                                ; => User defined range
  IF (N_ELEMENTS(yrangec) GT 1L) THEN yrangec = MAX(yrangec,/NAN)
  yrac  = [0d0,yrangec]
ENDELSE
IF NOT KEYWORD_SET(yrangep) THEN BEGIN          ; => Use data to set range
  yrap  = [0d0,MAX(mybs.HEIGHT_P,/NAN)*1.05d0]  ; => Y-Range for percentage
ENDIF ELSE BEGIN                                ; => User defined range
  IF (N_ELEMENTS(yrangep) GT 1L) THEN yrangec = MAX(yrangep,/NAN)
  yrap  = [0d0,yrangep]
ENDELSE

c_str = CREATE_STRUCT('XTICKNAME',mybs.TICKNAMES,'XTICKS',nb-1L,'XTICKV',binvals,$
                      'YTITLE','Number of Events','YRANGE',yrac,'YSTYLE',1,      $
                      'XRANGE',xrac,'XSTYLE',1,'XTITLE','','TITLE','')
p_str = CREATE_STRUCT('XTICKNAME',mybs.TICKNAMES,'XTICKS',nb-1L,'XTICKV',binvals,$
                      'YTITLE','Number of Events (%)','YRANGE',yrap,'YSTYLE',1,  $
                      'XRANGE',xrac,'XSTYLE',1,'XTITLE','','TITLE','')
rec_str = CREATE_STRUCT('X_LOCS',xx1,'Y_LOCS_C',yy1c,'Y_LOCS_P',yy1p)
;-----------------------------------------------------------------------------------------
; => Return data
;-----------------------------------------------------------------------------------------
his_str = CREATE_STRUCT('REC',rec_str,'CPLOT',c_str,'PPLOT',p_str,               $
                        'CDATA',mybs.HEIGHT_C,'PDATA',mybs.HEIGHT_P)
RETURN,his_str
END