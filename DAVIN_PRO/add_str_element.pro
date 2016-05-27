;+
;PROCEDURE:   add_str_element, struct, tag_name, value
;PURPOSE:
;  Obsolete.
;Replacement procedure:
;  str_element,/add, struct,tag_name,value 
;PURPOSE:   add an element to a structure (or change an element)
;SEE ALSO:
;  "str_element"
;Warning:
;  This procedure is slow when adding elements to large structures.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)add_str_element.pro	1.19 97/05/30
;
;-
pro add_str_element,struct,tag_name,value,delete=delete,replace=replace
str_element,struct,tag_name,value,delete=delete,/add_replace
return
end





