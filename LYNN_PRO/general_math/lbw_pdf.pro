;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_pdf.pro
;  PURPOSE  :   This routine generates a 1D probability density function (PDF) of an
;                 arbitrary input array of data.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               test_plot_axis_range.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA       :  [N]-Element [numeric] array of data to be analyzed
;
;  EXAMPLES:    
;               [calling sequence]
;               pdf = lbw_pdf(data [,DELX=delx] [,/XLOG] [,XRANGE=xrange] [,NBINS=nbins] $
;                                  [,XLOCS=xlocs] [,XCDF=xcdf])
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               DELX       :  Scalar [numeric] value defining the bin width
;                               [Default = (MAX - MIN)/(NBINS - 1)]
;               XLOG       :  If set, PDF is constructed in log-space
;                               [Default = FALSE]
;               XRANGE     :  [2]-Element [numeric] array defining the range of DATA
;                               values to use when constructing the PDF
;                               [Default = {MIN,MAX}]
;               NBINS      :  Scalar [numeric] value defining the number of bins to use
;                               when constructing the PDF
;                               [Default = 10]
;               **********************************
;               ***       DIRECT OUTPUTS       ***
;               **********************************
;               XLOCS      :  Set to a named variable to return the start locations of
;                               the discrete bins used to construct the PDF
;               XCDF       :  Set to a named variable to return the cumulative
;                               distribution function (CDF) of the constructed PDF
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Note that N > 10 as a bare minimum number of input elements for DATA
;
;  REFERENCES:  
;               NA
;
;   CREATED:  01/22/2024
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/22/2024   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_pdf,data,DELX=delx,XLOG=xlog,XRANGE=xrange,NBINS=nbins,XLOCS=xlocs,XCDF=xcdf

;;----------------------------------------------------------------------------------------
;;  Constants and Defaults
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define some default parameters
def_xlog       = 0b
def_nbin       = 10L
;;  Error messages
noinput_mssg   = 'No input was supplied...'
badinpt_mssg   = 'Incorrect input format was supplied:  DATA must be an [N]-element [numeric] array'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 1) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = ((is_a_number(data[0],/NOMSSG) EQ 0) OR (N_ELEMENTS(data) LE 10))
IF (test[0]) THEN BEGIN
  MESSAGE,'0:  '+badinpt_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
sznd           = SIZE(data,/N_DIMENSIONS)
IF (sznd[0] NE 1) THEN BEGIN
  MESSAGE,'1:  '+badinpt_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define some default parameters
def_xran       = [MIN(data,/NAN),MAX(data,/NAN)]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check XRANGE keyword
IF (test_plot_axis_range(xrange,/NOMSSG) EQ 0) THEN xran = def_xran ELSE xran = DOUBLE([MIN(xrange,/NAN),MAX(xrange,/NAN)])
;;  Check NBINS keyword
IF (is_a_number(nbins,/NOMSSG) EQ 0) THEN nb = def_nbin[0] ELSE nb = LONG(ABS(nbins[0])) > 10L
;;  Check XLOG keyword
IF KEYWORD_SET(xlog) THEN log_on = 1b ELSE log_on = 0b
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Construct PDF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define default DELX
def_delx       = ABS(xran[1] - xran[0])/(nb[0] - 1L)
IF (log_on[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  PDF to be constructed in log-space
  ;;--------------------------------------------------------------------------------------
  l10dat         = ALOG10(data)
  l10xr          = ALOG10(xran)
  ;;  Redefine default DELX
  def_delx       = ABS(l10xr[1] - l10xr[0])/(nb[0] - 1L)
  ;;  Check DELX keyword
  IF (is_a_number(delx,/NOMSSG) EQ 0)  THEN l10dx = def_delx[0] ELSE l10dx = ABS(ALOG10(ABS(delx[0])))
  ;;  Compute histogram
  l10_hist       = HISTOGRAM(l10dat,BINSIZE=l10dx[0],LOCATIONS=l10xlocs,MAX=l10xr[1],MIN=l10xr[0],/NAN)
  ;;  Normalize
  sumhist        = TOTAL(l10_hist,/NAN)
  norhist        = l10_hist/sumhist[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Define output keywords
  ;;--------------------------------------------------------------------------------------
  xlocs          = 1d1^(l10xlocs)
  IF ARG_PRESENT(xcdf) THEN xcdf = TOTAL(norhist,/NAN,/CUMULATIVE)
ENDIF ELSE BEGIN
  ;;  Check DELX keyword
  IF (is_a_number(delx,/NOMSSG) EQ 0)  THEN dx = def_delx[0] ELSE dx = ABS(delx[0])
  ;;--------------------------------------------------------------------------------------
  ;;  PDF to be constructed in linear-space
  ;;--------------------------------------------------------------------------------------
  lin_hist       = HISTOGRAM(data,BINSIZE=dx[0],LOCATIONS=linxlocs,MAX=xran[1],MIN=xran[0],/NAN)
  ;;  Normalize
  sumhist        = TOTAL(lin_hist,/NAN)
  norhist        = lin_hist/sumhist[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Define output keywords
  ;;--------------------------------------------------------------------------------------
  xlocs          = linxlocs
  IF ARG_PRESENT(xcdf) THEN xcdf = TOTAL(norhist,/NAN,/CUMULATIVE)
ENDELSE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN,norhist
END













