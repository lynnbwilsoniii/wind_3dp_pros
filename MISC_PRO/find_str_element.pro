;+
; **** OBSOLETE!!! Please use "str_element"instead! ***
;
;FUNCTION:  find_str_element
;PURPOSE:  find an element within a structure
; Input:
;   struct,  generic structure
;   name,    string  (tag name)
; Purpose:
;   Returns index of structure tag.
;   Returns -1 if not found   
;   Returns -2 if struct is not a structure
;KEYWORDS:
;  If VALUE is set to a named variable then  the value of that element is
;   returned in it.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)find_str_element.pro	1.6 95/10/06
;-
function find_str_element,struct,name,  $
   VALUE = value;   value of structure element returned in this variable
if data_type(struct) ne 8 then return,-2
tags = tag_names(struct)
n = where(strupcase(name) eq tags,count)
if count eq 0 then return, -1
i = n(0)
value = struct.(i)
return,i
end


