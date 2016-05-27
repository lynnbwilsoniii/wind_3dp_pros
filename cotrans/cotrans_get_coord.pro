;+
;*****************************************************************************************
;
;  FUNCTION :   cotrans_get_coord.pro
;  PURPOSE  :   Determine the coordinate system of data by examining the contents of
;                 of its DLIMIT structure.
;
;  CALLED BY:   
;               cotrans.pro
;
;  CALLS:
;               get_data.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  THEMIS IDL Libraries
;
;  INPUT:
;               DL     :  Anonymous STRUCT. or TPLOT variable name
;
;  EXAMPLES:    
;               cotrans_get_coord, dl
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  kenb-mac changed something                   [05/01/2007   v1.0.?]
;             2)  Updated man page                             [01/04/2010   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  ?
;    LAST MODIFIED:  01/04/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION cotrans_get_coord, dl

mydl = dl
res  = 'unknown'

IF (SIZE(dl,/TYPE) EQ 7) THEN BEGIN
   dl_name=dl
   get_data,dl_name,DL=mydl
ENDIF

IF (SIZE(mydl,/TYPE) EQ 8) THEN BEGIN
  ; read tag dl.data_att.data_type without bombing if tag does not exist!
  str_element,mydl,'DATA_ATT',data_att,SUCCESS=has_data_att
  IF has_data_att THEN BEGIN
    str_element,data_att,'coord_sys',res,SUCCESS=has_coord_sys
    IF has_coord_sys THEN BEGIN
      res = STRLOWCASE(res)
    ENDIF 
  ENDIF
ENDIF

RETURN, res
END
