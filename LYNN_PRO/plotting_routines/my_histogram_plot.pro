;+
;*****************************************************************************************
;
;  FUNCTION :   my_histogram_plot.pro
;  PURPOSE  :   Creates a histogram plot from a 1D input data array.
;
;  CALLED BY:   NA
;
;  CALLS:
;               my_histogram.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               M1        :  An N-Element array of data to be used for the histogram
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               NBINS     :  A scalar used to define the number of bins used to make the
;                              histogram [Default = 8]
;               YTTL      :  Set to a string defining the desired Y-Axis Title
;               XTTL      :  Set to a string defining the desired X-Axis Title
;               TTLE      :  Set to a string defining the desired plot title
;               DRANGE    :  Set to a 2-Element array to force bins to be determined by
;                              the range given in array instead of data
;                              [Useful for plotting multiple things on the same scales]
;               YRANGEC   :  A scalar used to define the max y-range value for counts
;               YRANGEP   :  A scalar used to define the max y-range value for percent
;                              [Best results if both YRANGEC and YRANGEP are set]
;               BARCOLOR  :  A scalar defining the color of the bars
;               PREC      :  Scalar defining the precision of the X-Axis bin range labels
;                              [Default = 2 for 8 bins or less, 1 for >8 bins]
;
;   CHANGED:  1)  Updated man page and fixed device issue  [01/09/2009   v1.0.1]
;             2)  Added output which defines number of points analyzed
;                                                          [01/13/2009   v1.0.2]
;             3)  Added keyword : DRANGE                   [01/24/2009   v1.0.3]
;             4)  Added keywords: YRANGEC and YRANGEP      [01/24/2009   v1.0.4]
;             5)  Changed # output for DRANGE alterations  [04/30/2009   v1.0.5]
;             6)  Changed string output when DRANGE set    [06/03/2009   v1.0.6]
;             7)  Added keyword :  BARCOLOR                [06/04/2009   v1.0.7]
;             8)  Added keyword :  PREC                    [03/31/2011   v1.0.8]
;
;   CREATED:  01/05/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/31/2011   v1.0.8
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO  my_histogram_plot,m1,NBINS=nbins,YTTL=yttl,XTTL=xttl,TTLE=ttle,    $
                          DRANGE=drange,YRANGEC=yrangec,YRANGEP=yrangep,$
                          BARCOLOR=barcolor,PREC=prec

;-----------------------------------------------------------------------------------------
;  ----DEFINE SOME USABLE COLORS----
;-----------------------------------------------------------------------------------------
DEVICE,GET_DECOMPOSED=decomp0
; => Keep track of original system vars
xyzp_win    = {X:!X,Y:!Y,Z:!Z,P:!P,DECOMP:decomp0}
IF (STRLOWCASE(!D.NAME) EQ 'x') THEN DEVICE,DECOMPOSED=0L
; => Load current colors [*_orig] so they can be reset after done with routine
COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
r_orig0 = r_orig
g_orig0 = g_orig
b_orig0 = b_orig


CASE !VERSION.OS_NAME OF
  'Mac OS X' : BEGIN
    IF (!D.TABLE_SIZE NE 256L) THEN BEGIN
      LOADCT,39
    ENDIF
  END
  'Solaris'  : BEGIN
    IF (!D.TABLE_SIZE NE 256L) THEN BEGIN
      LOADCT,39
    ENDIF
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Get histogram information
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(drange) THEN BEGIN  ; => Use data to set range
  nm1    = N_ELEMENTS(m1)
ENDIF ELSE BEGIN    ; => User defined range
  gras  = WHERE(m1 LE drange[1] AND m1 GE drange[0],nm1)
ENDELSE
myhist = my_histogram(m1,NBINS=nbins,DRANGE=drange,YRANGEC=yrangec,$
                      YRANGEP=yrangep,PREC=prec)
;-----------------------------------------------------------------------------------------
; => Define some labels and colors
;-----------------------------------------------------------------------------------------
c_str = myhist.CPLOT  ; => Plot str. containing YTITLE,XTICKNAME,XRANGE,etc. for counts
p_str = myhist.PPLOT  ; => " " for percentage

IF KEYWORD_SET(yttl) THEN BEGIN
  c_str.YTITLE += '!C'+yttl
  p_str.YTITLE += '!C'+yttl+" (%)"
ENDIF
IF KEYWORD_SET(xttl) THEN BEGIN
  c_str.XTITLE = xttl
  p_str.XTITLE = xttl
ENDIF
IF KEYWORD_SET(ttle) THEN BEGIN
  c_str.TITLE = ttle
ENDIF
;-----------------------------------------------------------------------------------------
; => Define colors of bars on bar graph
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(barcolor) THEN BEGIN
  IF (STRLOWCASE(!D.NAME) EQ 'x') THEN cc = 255L ELSE cc = 0L
ENDIF ELSE BEGIN
  cc = barcolor
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define rectangle locations for polyfill
;-----------------------------------------------------------------------------------------
xlocs  = myhist.REC.X_LOCS   ; => X-Locations of rectangles for histogram
ylocsc = myhist.REC.Y_LOCS_C ; => Y-Locations " " (counts)
ylocsp = myhist.REC.Y_LOCS_P ; => Y-Locations " " (percentage)
;-----------------------------------------------------------------------------------------
; => Define data
;-----------------------------------------------------------------------------------------
counts = myhist.CDATA        ; => # of counts in each bin (first is a dummy bin)
percen = myhist.PDATA        ; => % " "
nc     = N_ELEMENTS(counts)
;-----------------------------------------------------------------------------------------
; => Plot data
;-----------------------------------------------------------------------------------------
IF (STRLOWCASE(!D.NAME) EQ 'ps') THEN BEGIN
  IF (nc GT 6L) THEN chsz = 0.65 ELSE chsz = 0.8
ENDIF ELSE BEGIN
  IF (nc GT 6L) THEN chsz = 0.95 ELSE chsz = 1.2
ENDELSE

!P.MULTI = [0,1,2]

PLOT,counts,PSYM=10,_EXTRA=c_str,/NODATA,CHARSIZE=chsz
FOR j=1L, nc - 1L DO BEGIN
  POLYFILL,xlocs[j,*],ylocsc[j,*],COLOR=cc
ENDFOR

PLOT,percen,PSYM=10,_EXTRA=p_str,/NODATA,CHARSIZE=chsz
FOR j=1L, nc - 1L DO BEGIN
  POLYFILL,xlocs[j,*],ylocsp[j,*],COLOR=cc
ENDFOR

XYOUTS,.70,.92,'Total #: '+STRTRIM(nm1,2),/NORMAL,CHARSIZE=1.5
IF KEYWORD_SET(drange) THEN BEGIN  ; => Use data to set range
  perc_used = (nm1*1d0)/(N_ELEMENTS(m1)*1d0)*1d2  ; => % of data points in range
  perc_ustr = STRTRIM(STRING(FORMAT='(f10.1)',perc_used),2L)
  XYOUTS,.70,.89,'% of Input Pts. Used: '+perc_ustr,/NORMAL,CHARSIZE=1.5
ENDIF

;-----------------------------------------------------------------------------------------
; => Reset color table and plot parameters
;-----------------------------------------------------------------------------------------
TVLCT,r_orig0,g_orig0,b_orig0
; => Return plot window to original state
!X   = xyzp_win.X
!Y   = xyzp_win.Y
!Z   = xyzp_win.Z
!P   = xyzp_win.P
DEVICE,DECOMPOSED=xyzp_win.DECOMP

RETURN
END