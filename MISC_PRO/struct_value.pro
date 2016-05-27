;+
;*****************************************************************************************
;
;  FUNCTION :   struct_value.pro
;  PURPOSE  :   Returns the value of a structure element.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               struct_value.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STR      :  An IDL structure
;               NAME     :  [N]-Element string array of structure tags
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               DEFAULT  :  Set to define the default value associated with NAME
;               INDEX    :  Set to a named variable to return the structure tag
;                             index.  Return values will be:
;                                 -2  :  STRUCT is not a structure
;                                 -1  :  TAGNAME is not found
;                                >=0  :  successful
;
;   CHANGED:  1)  Created by Davin Larson                          [??/??/2006   v1.0.0]
;             2)  Re-wrote and cleaned up                          [04/03/2012   v1.1.0]
;
;   NOTES:      
;               1)  Function is equivalent to the procedure: "STR_ELEMENT"
;               2)  if "name" is an array then a new structure is returned with only
;                     the named values
;
;   CREATED:  ??/??/2006
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  04/03/2012   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION struct_value,str,name,DEFAULT=default,INDEX=index

;-----------------------------------------------------------------------------------------
; => Set up initial values and check input
;-----------------------------------------------------------------------------------------
index = -1
IF (N_ELEMENTS(default) NE 0) THEN value = default
IF (N_ELEMENTS(value)   EQ 0) THEN value = 0
IF (SIZE(str,/TYPE) NE 8) THEN RETURN,value
IF (SIZE(name,/TYPE) NE 7) THEN RETURN,value

IF (SIZE(name,/N_DIMENSIONS) GT 0) THEN BEGIN
  value = CREATE_STRUCT(IDL_VALIDNAME(name[0]),struct_value(str,name[0],DEFAULT=default))
  FOR i=1L, N_ELEMENTS(name) - 1L DO BEGIN
    value=CREATE_STRUCT(value,IDL_VALIDNAME(name[i]),struct_value(str,name[i],DEFAULT=default))
  ENDFOR
  RETURN,value
ENDIF

str_element,str,name,value,INDEX=index
RETURN,value
END

