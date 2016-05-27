;+
;*****************************************************************************************
;
;  FUNCTION :   cotrans_set_coord.pro
;  PURPOSE  :   Sets the coordinate system of data by setting the data_att structure 
;                 of its DLIMIT structure.
;
;  CALLED BY:   
;               cotrans.pro
;
;  CALLS:
;               str_element.pro
;               store_data.pro
;
;  REQUIRES:    
;               1)  THEMIS IDL Libraries
;
;  INPUT:
;               DL     :  Anonymous STRUCT.
;               COORD  :  Scalar string defining the coordinate system
;
;  EXAMPLES:    
;               cotrans_set_coord, dl, 'gei'
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  kenb-mac changed something                   [08/01/2007   v1.0.?]
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

PRO cotrans_set_coord,dl,coord

IF N_PARAMS() EQ 1 THEN coord = 'unknown'

IF (SIZE(dl,/TYPE) EQ 8) THEN BEGIN
   ;; set tag dl.DATA_ATT.COORD_SYS without bombing if data_att does not exist
   str_element,dl,'DATA_ATT',data_att, SUCCESS=has_data_att
   IF has_data_att THEN BEGIN
      str_element, data_att, 'COORD_SYS',coord,/ADD_REPLACE
   ENDIF ELSE data_att = {COORD_SYS:coord}
   str_element,dl,'DATA_ATT',data_att,/ADD_REPLACE
ENDIF ELSE dl = {DATA_ATT:{COORD_SYS:coord}}

END
