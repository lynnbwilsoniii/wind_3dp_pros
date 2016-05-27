;+
;*****************************************************************************************
;
;  FUNCTION :   find_handle.pro
;  PURPOSE  :   Returns the index associated with a string name.  This function is 
;                 used by the "TPLOT" routines.  If the tag is not found, the program
;                 returns a zero.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NAME  :  [String] A defined TPLOT variable name with associated spectra
;                          data separated by pitch-angle as TPLOT variables
;                          [e.g. 'nelb_pads']
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Davin Larson changed something...        [02/26/1999   v1.0.14]
;             2)  Re-wrote and cleaned up                  [08/16/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/16/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION find_handle,name
@tplot_com.pro
IF (N_ELEMENTS(data_quants) EQ 0) THEN BEGIN
  MESSAGE,'No Data stored yet!',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF

IF (N_ELEMENTS(name) NE 1) THEN BEGIN
  MESSAGE,'Incorrect input format:  '+name,/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF

dt = SIZE(name,/TYPE)
IF (dt EQ 7) THEN BEGIN
  index = WHERE(data_quants.NAME EQ name,count)
  IF (count EQ 0) THEN RETURN,0
  RETURN, index[0]
ENDIF

IF (dt GE 1 AND dt LE 5) THEN BEGIN
  index = ROUND(name)
  IF (index GT 0 AND index LT N_ELEMENTS(data_quants)) THEN BEGIN
    name = data_quants[index].NAME
  ENDIF ELSE BEGIN
    index = 0
  ENDELSE
  RETURN,index
ENDIF
RETURN,0
END
