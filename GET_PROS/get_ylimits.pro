;+
;*****************************************************************************************
;
;  FUNCTION :   get_ylimits.pro
;  PURPOSE  :   Calculates appropriate ylimits for a string array of "TPLOT" variables
;                 to be plotted in the same panel.
;
;  CALLED BY: 
;               tplot.pro
;
;  CALLS:
;               str_element.pro
;               get_data.pro
;               ndimen.pro
;               minmax.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATASTR  :  N-Element string array of TPLOT variables
;               LIMITS   :  Limit structure to be modified [usually the limits
;                             structure of the TPLOT variable whose data field 
;                             is a string array of TPLOT variables]
;               TRG      :  2-Element array of Unix times defining time range 
;                             over which to calculate the Y-Axis limits
;
;  EXAMPLES:    NA
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  Peter Schroeder changed something...    [04/17/2002   v1.0.?]
;             2)  Re-wrote and cleaned up                 [06/21/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Peter Schroeder
;    LAST MODIFIED:  06/21/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO get_ylimits,datastr,limits,trg

;-----------------------------------------------------------------------------------------
; => Get relevant information from limits structure
;-----------------------------------------------------------------------------------------
miny = 0.
maxy = 0.
str_element,limits,'MIN_VALUE',min_value
str_element,limits,'MAX_VALUE',max_value
str_element,limits,'YTYPE',ytype

FOR i=0L, N_ELEMENTS(datastr) - 1L DO BEGIN
  get_data,datastr[i],DATA=data,DTYPE=dtype
  IF (dtype EQ 1L AND KEYWORD_SET(data)) THEN BEGIN
    evlength = MAX(data.X,/NAN) - MIN(data.X,/NAN)    ; => Amount of total time available
    ndat     = N_ELEMENTS(data.X)
    nsps     = ((ndat - 1L)/evlength)                 ; -Approx Sample Rate
    ; => Only use finite data
    good     = WHERE(FINITE(data.X),count)
    ;-------------------------------------------------------------------------------------
    IF (count EQ 0) THEN MESSAGE,'No valid X data'
    ;-------------------------------------------------------------------------------------
    ind = WHERE(data.X[good] GE trg[0] AND data.X[good] LE trg[1],count)
    IF (count EQ 0) THEN BEGIN
      sss = 1
      dt  = 0d0
      cc  = 0L
      WHILE(sss) DO BEGIN
        delta  = 1d0 + dt
        tr_new = [trg[0] - delta,trg[1] + delta]
        ind = WHERE(data.X[good] GE tr_new[0] AND data.X[good] LE tr_new[1],count)
        IF (count GT 0L) THEN sss = 0 ELSE sss = 1
        IF (sss) THEN cc += 1L
        IF (sss) THEN dt += 2d0/nsps
        IF (cc LT 20L AND sss) THEN sss = 1 ELSE sss = 0 ; keep from repeating too much
      ENDWHILE
      ind = good[ind]
    ENDIF ELSE BEGIN
      ind = good[ind]
    ENDELSE
    ndx = ndimen(data.X)
    IF (ndx[0] EQ 1) THEN BEGIN
      yrange = minmax(data.Y[ind,*],POSITIVE=ytype,$
                      MAX_VALUE=max_value,MIN_VALUE=min_value)
    ENDIF ELSE BEGIN
      yrange = minmax(data.Y[ind],POSITIVE=ytype,$
                      MAX_VALUE=max_value,MIN_VALUE=min_value)
    ENDELSE
    IF (miny NE maxy) THEN BEGIN
      IF (yrange[0] LT miny) THEN miny = yrange[0]
      IF (yrange[1] GT maxy) THEN maxy = yrange[1]
    ENDIF ELSE BEGIN
      miny = yrange[0]
      maxy = yrange[1]
    ENDELSE
  ENDIF
ENDFOR

str_element,limits,'YRANGE',[miny, maxy],/ADD_REPLACE

RETURN
END