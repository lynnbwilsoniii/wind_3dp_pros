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
;  INCLUDES:
;               NA
;
;  CALLS:
;               my_histogram_bins.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               M1      :  [N]-Element [numeric] array of data to bin
;
;  EXAMPLES:    
;               [calling sequence]
;               hist_out = my_histogram(m1 [,NBINS=nbins] [,DRANGE=drange]             $
;                                       [,YRANGEC=yrangec] [,YRANGEP=yrangep]          $
;                                       [,PREC=prec] )
;
;  KEYWORDS:    
;               NBINS   :  Scalar [numeric] defining the number of histogram bins, less
;                            one, used in creating plot
;                            [Default = 8]
;               DRANGE  :  [2]-Element [numeric] array defining the range of values
;                            that will be included in the binning and the plot range
;                            [Default = defined by data range]
;               YRANGEC :  Scalar [numeric] defining the maximum value used to
;                            define the vertical axis range (minimum at zero) for the
;                            counts plot
;                            [Default = defined by binned data]
;               YRANGEP :  Scalar [numeric] defining the maximum value used to
;                            define the vertical axis range (minimum at zero) for the
;                            percent plot
;                            [Default = defined by binned data]
;               PREC    :  Scalar [numeric] defining the precision of the horizontal
;                            axis bin labels
;                            [Default = 2 for 8 bins or less, 1 for >8 bins]
;
;   CHANGED:  1)  Changed the YRANGE for the percentage data
;                                                                   [01/13/2009   v1.0.1]
;             2)  Changed the XRANGE for both plots
;                                                                   [01/13/2009   v1.0.2]
;             3)  Added keyword : DRANGE
;                                                                   [01/24/2009   v1.0.3]
;             4)  Added keywords: YRANGEC and YRANGEP
;                                                                   [01/24/2009   v1.0.4]
;             5)  Fixed possible issue if one enters a 2-Element array for either
;                   keyword YRANGEC or YRANGEP
;                                                                   [06/03/2009   v1.0.5]
;             6)  Added keyword :  PREC
;                                                                   [03/31/2011   v1.0.6]
;             7)  Updated Man. page, cleaned up, and added error handling and
;                   now calls is_a_number.pro
;                                                                   [04/07/2017   v1.1.0]
;
;   NOTES:      
;               1)  The YRANGE[C,P] keyword names are misleading, as they imply one
;                     should enter a two element array but the routine expects a scalar
;
;  REFERENCES:  
;               NA
;
;   CREATED:  01/05/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/07/2017   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION my_histogram,m1,NBINS=nbins,DRANGE=drange,YRANGEC=yrangec,YRANGEP=yrangep, $
                         PREC=prec

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
no_inpt_msg    = 'User must supply at least a valid IDL [numeric] array...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (is_a_number(m1,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
v1pts          = N_ELEMENTS(m1)
v1             = REFORM(m1)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NBINS
test           = (N_ELEMENTS(nbins) LT 1) OR (is_a_number(nbins,/NOMSSG) EQ 0)
IF (test[0]) THEN nb = 8L ELSE nb = LONG(nbins[0]) > 1L
;;  Check DRANGE
test           = (N_ELEMENTS(drange) GE 2) AND is_a_number(drange,/NOMSSG)
IF (test[0]) THEN test = (drange[0] NE drange[1])
IF (test[0]) THEN xrange = (drange[SORT(drange)])[0:1]
;;  Check YRANGEC
test           = (N_ELEMENTS(yrangec) LT 1) OR (is_a_number(yrangec,/NOMSSG) EQ 0)
IF (test[0]) THEN yranc_off = 1b ELSE yranc_off = 0b
;;  Check YRANGEP
test           = (N_ELEMENTS(yrangep) LT 1) OR (is_a_number(yrangep,/NOMSSG) EQ 0)
IF (test[0]) THEN yranp_off = 1b ELSE yranp_off = 0b

;;----------------------------------------------------------------------------------------
;;  Bin data into defined number of data bins
;;----------------------------------------------------------------------------------------
mybs           = my_histogram_bins(v1,NBINS=nb,DRANGE=xrange,PREC=prec)
;mybs           = my_histogram_bins(v1,NBINS=nbins,DRANGE=drange,PREC=prec)
;;----------------------------------------------------------------------------------------
;;  Define bin locations for output
;;----------------------------------------------------------------------------------------
nb             = N_ELEMENTS(mybs.HEIGHT_C)
binvals        = DINDGEN(nb[0]) - 5d-1              ;;  Use for XTICKV keyword in plot
;;----------------------------------------------------------------------------------------
;;  Define rectangular area for histogram plots
;;----------------------------------------------------------------------------------------
binleft         = binvals - 25d-2
binright        = binvals + 25d-2
xx1             = DBLARR(nb[0],4L)        ;;  X-Locations of corners of rectangle
yy1c            = DBLARR(nb[0],4L)        ;;  Y-Locations of corners of rectangle (counts)
yy1p            = DBLARR(nb[0],4L)        ;;  Y-Locations of corners of rectangle (percentage)
ymins           = REPLICATE(0d0,nb[0])    ;;  Min Y-Location of rectangle corners

xx1             = [[binleft],[binright],[binright],[binleft]]
yy1c            = [[ymins],[ymins],[mybs.HEIGHT_C],[mybs.HEIGHT_C]]
yy1p            = [[ymins],[ymins],[mybs.HEIGHT_P],[mybs.HEIGHT_P]]
;;----------------------------------------------------------------------------------------
;;  Define plot structure information
;;----------------------------------------------------------------------------------------
xrac           = [2d-1,MAX(xx1,/NAN) + 5d-1]
;IF NOT KEYWORD_SET(yrangec) THEN BEGIN          ;;  Use data to set range
IF (yranc_off) THEN BEGIN
  ;;  Use data to set range
  yrac  = [0d0,MAX(mybs.HEIGHT_C,/NAN)*1.05d0]  ;;  Y-Range for counts
ENDIF ELSE BEGIN
  ;;  User defined range
  IF (N_ELEMENTS(yrangec) GT 1L) THEN yranc = MAX(ABS(yrangec),/NAN) ELSE yranc = ABS(yrangec[0])
  yrac  = [0d0,yranc[0]]
ENDELSE
;IF NOT KEYWORD_SET(yrangep) THEN BEGIN          ;;  Use data to set range
IF (yranp_off) THEN BEGIN
  ;;  Use data to set range
  yrap  = [0d0,MAX(mybs.HEIGHT_P,/NAN)*1.05d0]  ;;  Y-Range for percentage
ENDIF ELSE BEGIN
  ;;  User defined range
  IF (N_ELEMENTS(yrangep) GT 1L) THEN yranp = MAX(ABS(yrangep),/NAN) ELSE yranp = ABS(yrangep[0])
  yrap  = [0d0,yranp[0]]
ENDELSE
;;  Create structures for counts and percent plots
xts            = nb[0] - 1L
c_str          = CREATE_STRUCT('XTICKNAME',mybs.TICKNAMES,'XTICKS',xts[0],'XTICKV',binvals,$
                               'YTITLE','Number of Events','YRANGE',yrac,'YSTYLE',1,      $
                               'XRANGE',xrac,'XSTYLE',1,'XTITLE','','TITLE','')
p_str          = CREATE_STRUCT('XTICKNAME',mybs.TICKNAMES,'XTICKS',xts[0],'XTICKV',binvals,$
                               'YTITLE','Number of Events (%)','YRANGE',yrap,'YSTYLE',1,  $
                               'XRANGE',xrac,'XSTYLE',1,'XTITLE','','TITLE','')
rec_str        = CREATE_STRUCT('X_LOCS',xx1,'Y_LOCS_C',yy1c,'Y_LOCS_P',yy1p)
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
his_str        = CREATE_STRUCT('REC',rec_str,'CPLOT',c_str,'PPLOT',p_str,               $
                               'CDATA',mybs.HEIGHT_C,'PDATA',mybs.HEIGHT_P)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,his_str
END


