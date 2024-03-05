;+
;*****************************************************************************************
;
;  FUNCTION :   minmax.pro
;  PURPOSE  :   Returns a two element array containing the minimum and maximum values
;                 of a data input.  The values can be forced to be positive and the
;                 indices of the max and min values can be returned as well.  One can
;                 also find the relative min-max values in between two values defined
;                 by the keywords MAX_VALUE and MIN_VALUE.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               TDATA          :  [N]-Element array of finite data
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               MAX_VALUE      :  Scalar defining the maximum value the program should
;                                   consider when calculating the min-max range
;               MIN_VALUE      :  Scalar defining the minimum value the program should
;                                   consider when calculating the min-max range
;               POSITIVE       :  If set, only positive real results will be returned
;                                   [Effective for Log-Scale plot ranges]
;               MXSUBSCRIPT    :  Set to a named variable to return the element 
;                                   associated with the maximum value returned
;               MNSUBSCRIPT    :  Set to a named variable to return the element 
;                                   associated with the minimum value returned
;               SUBSCRIPT_MIN  :  Same as MNSUBSCRIPT
;               SUBSCRIPT_MAX  :  Same as MXSUBSCRIPT
;               NAN            :  Not yet implemented
;
;   CHANGED:  1)  Davin Larson changed something...                [04/17/2002   v1.0.2]
;             2)  Added /NAN keywords to MIN.PRO and MAX.PRO function calls 
;                                                                  [03/13/2008   v1.0.3]
;             3)  Re-wrote and cleaned up                          [08/11/2009   v1.1.0]
;             4)  Re-wrote and cleaned up and updated to be in accordance with newest
;                   version of TDAS
;                   A)  added keywords:  SUBSCRIPT_MIN, SUBSCRIPT_MAX, NAN, 
;                   B)  no longer uses () for arrays
;                                                                  [03/28/2012   v1.2.0]
;             5)  Updated to be in accordance with newest version of specplot.pro
;                   in TDAS IDL libraries [tdas_8_00]
;                   A)  now implements SUBSCRIPT_MIN and SUBSCRIPT_MAX
;                                                                  [07/30/2013   v1.3.0]
;
;   NOTES:      
;               1)  If BOTH MIN_VALUE and POSITIVE are set AND MIN_VALUE < 0, then
;                     the program will let the keyword POSITIVE trump MIN_VALUE
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  07/30/2013   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION minmax,tdata,MAX_VALUE=max_value,MIN_VALUE=min_value,POSITIVE=positive,$
                      MXSUBSCRIPT=mxsubs,MNSUBSCRIPT=mnsubs,                    $
                      SUBSCRIPT_MIN = subscript_min, $   ; Not yet implemented
                      SUBSCRIPT_MAX = subscript_max, $   ; Not yet implemented
                      NAN = nan                          ; Not yet implemented

;;----------------------------------------------------------------------------------------
;;  Check input format and define defaults
;;----------------------------------------------------------------------------------------
dtype     = SIZE(tdata,/TYPE)
badreturn = MAKE_ARRAY(2,TYPE=dtype)
IF KEYWORD_SET(positive) THEN gposi = 1 ELSE gposi = 0
;;----------------------------------------------------------------------------------------
;;  Check to see if data is finite
;;----------------------------------------------------------------------------------------
wf = WHERE(FINITE(tdata),count)
IF (count EQ 0) THEN BEGIN
  RETURN, badreturn
ENDIF
data = tdata[wf]
IF NOT KEYWORD_SET(max_value) THEN BEGIN
  mx_val = MAX(data,lx,/NAN)
  mxsubs = wf[lx]                         ;;  Element of maximum value in array
ENDIF ELSE BEGIN
  wx   = WHERE(data LT max_value ,cx)
  IF (cx GT 0) THEN BEGIN
    mx_val = MAX(data[wx],lx,/NAN)
    mxsubs = wf[wx[lx]]                   ;;  Element of maximum value in array
  ENDIF ELSE RETURN, badreturn
ENDELSE

IF (KEYWORD_SET(min_value) AND gposi EQ 1) THEN BEGIN
  IF (min_value[0] LT 0) THEN BEGIN
    MESSAGE,'Conflicting keywords:  MIN_VALUE AND POSITIVE',/INFORMATION,/CONTINUE
    MESSAGE,'Using default option:  POSITIVE = 1',/INFORMATION,/CONTINUE
    min_value = min_value > 0
    gposi     = 1
  ENDIF
ENDIF

IF (NOT KEYWORD_SET(min_value) AND gposi NE 1) THEN BEGIN
  mn_val = MIN(data,ln,/NAN)
  mnsubs = wf[ln]                         ;;  Element of minimum value in array
ENDIF ELSE BEGIN
  IF (gposi EQ 1) THEN min_value = 0
  wn        = WHERE(data GT min_value ,cn)
  IF (cn GT 0) THEN BEGIN
    mn_val = MIN(data[wn],ln,/NAN)
    mnsubs = wf[wn[ln]]                   ;;  Element of minimum value in array
  ENDIF ELSE RETURN, badreturn
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
subscript_min  = mnsubs[0]
subscript_max  = mxsubs[0]
mx             = mx_val[0]
mn             = mn_val[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,[mn,mx]
END

