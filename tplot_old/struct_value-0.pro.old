;+
;FUNCTION: struct_value(struc,name,default=default,index=index)
;PURPOSE:  Returns the value of a structure element.
;   Function equivalent to the procedure: "STR_ELEMENT"
;   if "name" is an array then a new structure is returned with only the named values.
;Author:  Davin Larson, 2006
;-


function struct_value,str,name,default=default,index=index
index = -1
if n_elements(default) ne 0 then value = default
if n_elements(value)     eq 0 then value = 0
if size(/type,str) ne 8 then return,value
if size(/type,name) ne 7 then return,value
if size(/n_dimen,name) gt 0 then begin
   value = create_struct(idl_validname(name[0]),struct_value(str,name[0],default=default))
   for i = 1,n_elements(name)-1 do  $
       value=create_struct(value,idl_validname(name[i]),struct_value(str,name[i],default=default))
   return,value
endif
str_element,str,name,value,index=index
return,value
end

