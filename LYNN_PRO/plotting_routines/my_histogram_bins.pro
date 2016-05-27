;+
;*****************************************************************************************
;
;  FUNCTION :   my_histogram_bins.pro
;  PURPOSE  :   Creates and returns a structure which defines the tickmark names and 
;                 heights associated with a histogram of absolute counts and a 
;                 histogram of percentages.
;
;  CALLED BY:   
;               my_histogram.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               M1      :  An N-Element array of data to be used for the histogram
;
;  EXAMPLES:
;               hist_data = my_histogram_bins(m1,NBINS=8L,DRANGE=[10.,20.])
;
;  KEYWORDS:  
;               NBINS   :  A scalar used to define the number of bins used to make the
;                            histogram [Default = 8]
;               DRANGE  :  Set to a 2-Element array to force bins to be determined by
;                            the range given in array instead of data
;                            [Useful for plotting multiple things on the same scales]
;               PREC    :  Scalar defining the precision of the X-Axis bin range labels
;                            [Default = 2 for 8 bins or less, 1 for >8 bins]
;
;   CHANGED:  1)  Added keyword: DRANGE                        [01/24/2009   v1.0.1]
;             2)  Dealt with negative numbers                  [06/03/2009   v1.0.2]
;             3)  Fixed issue with DRANGE                      [04/11/2010   v1.1.0]
;             4)  Changed the bin label format statements      [05/12/2010   v1.1.1]
;             5)  Added keyword :  PREC                        [03/31/2011   v1.1.2]
;
;   CREATED:  01/05/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/31/2011   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION my_histogram_bins,m1,NBINS=nbins,DRANGE=drange,PREC=prec

;-----------------------------------------------------------------------------------------
; => Find absolute range of data
;-----------------------------------------------------------------------------------------
lv1  = REFORM(m1)
IF NOT KEYWORD_SET(drange) THEN BEGIN  ; => Use data to set range
  lm1  = MIN(lv1,/NAN)
  hm1  = MAX(lv1,/NAN)
ENDIF ELSE BEGIN    ; => User defined range
  lm1  = drange[0L]
  hm1  = drange[1L]
ENDELSE

IF KEYWORD_SET(nbins) THEN nb = nbins ELSE nb = 8L
h12l = DBLARR(nb)  ; => Location of left edge of each histogram
h12l = DINDGEN(nb)*(hm1 - lm1)/(nb - 1L) + lm1
;-----------------------------------------------------------------------------------------
; => Find elements of m1 which fall in each histogram region
;-----------------------------------------------------------------------------------------
upel = LINDGEN(nb - 1L) + 1L
dnel = LINDGEN(nb - 1L)
har1 = LINDGEN(nb - 1L)  ; => # of points in each bin
FOR i = 0L, nb - 2L DO BEGIN
  uplim   = h12l[upel[i]]
  dnlim   = h12l[dnel[i]]
;  j       = i + 1L
  hao     = WHERE(lv1 LT uplim[0] AND lv1 GE dnlim[0],hno)
  IF (i EQ nb-2L) THEN hao = WHERE(lv1 LT uplim[0]+5d-2 AND lv1 GE dnlim[0],hno)
  har1[i] = hno
ENDFOR
;-----------------------------------------------------------------------------------------
; => Define the tick mark labels
;-----------------------------------------------------------------------------------------
hlabs = STRARR(nb)     ; => Labels associated with tick names
hname = STRARR(nb)     ; => Tick names used for plotting
hpref = STRARR(nb)     ; => Possibly require '(' if tick labels are of negative numbers
hsufx = STRARR(nb)     ; => Possibly require ')' if tick labels are of negative numbers
IF NOT KEYWORD_SET(prec) THEN BEGIN
  ; => User did not define precision, so use default
  IF (nb GT 8L) THEN form = '(f15.1)' ELSE form = '(f15.2)'
ENDIF ELSE BEGIN
  ; => User defined precision
  prcs = STRTRIM(STRING(FORMAT='(f15.0)',prec[0]),2L)
  ppos = STRPOS(prcs[0],'.')
  prcs = STRMID(prcs[0],0L,ppos[0])
  form = '(f15.'+prcs[0]+')'
ENDELSE

hlabs = STRTRIM(STRING(FORMAT=form,h12l),2L)
low_h = WHERE(h12l LT 0.,l_h,COMPLEMENT=hig_h,NCOMPLEMENT=h_h)
IF (l_h GT 0L) THEN BEGIN
  hpref[low_h] = '('
  hsufx[low_h] = ')'
ENDIF

x     = LINDGEN(nb-1L) + 1L
y     = LINDGEN(nb-1L)
hname[1:(nb-1L)] = hpref+hlabs[y]+hsufx+"-"+hpref+hlabs[x]+hsufx
hname[0]         = " "
;-----------------------------------------------------------------------------------------
; => Define histogram heights in terms of counts and percentages
;-----------------------------------------------------------------------------------------
heightc = DBLARR(nb)            ; => Height in terms of absolute counts
heightp = DBLARR(nb)            ; => " " percentage
htotal  = TOTAL(har1*1d0,/NAN)  ; => magnitude of all values used for percentage

heightc[1:(nb-1L)] = 1d0*har1
heightc[0L]        = heightc[1L]
heightp[1:(nb-1L)] = 1d2*har1/htotal
heightp[0L]        = heightp[1L]
;-----------------------------------------------------------------------------------------
; => Return structure associated with data
;-----------------------------------------------------------------------------------------
bstr = CREATE_STRUCT('HEIGHT_C',heightc,'HEIGHT_P',heightp,'TICKNAMES',hname)
RETURN,bstr
END