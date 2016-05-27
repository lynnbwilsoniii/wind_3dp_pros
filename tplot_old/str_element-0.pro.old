;+
;PROCEDURE:  str_element, struct,  tagname, value
;PURPOSE:
; Find (or add) an element of a structure. 
; This procedure will not 
; Input:
;   struct,  generic structure
;   tagname,    string  (tag name)
; Output:
;   value,  Named variable in which value of the structure element is returned.
; Purpose:
;   Retrieves the value of a structure element.  This function will not produce
;   an error if the tag and/or structure does not exist.  
;KEYWORDS:
;  SUCCESS:  Named variable that will contain a 1 if the element was found
;     or a 0 if not found.
;  INDEX: a named variable in which the element index is returned.  The index
;     will be -2 if struct is not a structure,  -1 if the tag is not found, 
;     and >= 0 if successful.
;  ADD_REPLACE:  Set this keyword to add or replace a structure element.
;  DELETE:   Set this keyword to delete the tagname.
;  CLOSEST:  Set this keyword to allow near matchs (useful with _extra)
;  VALUE: (obsolete) alternate method of returning value. (Will not work with recursion)
;Notes:
;  Value remains unchanged if the structure element does not exist.
;  If tagname contains a '.' then the structure is recursively searched and
;    index will be an array of indices.
;  If struct is an array then results may be unpredictable.
;
;Modifications:
;  5/7/97: Added recursive searching of structure hierarchy.  D. Larson
;
;CREATED BY:	Davin Larson
;FILE:  str_element.pro  
;VERSION  1.10
;LAST MODIFICATION: 01/10/08
;-
pro str_element,struct,tagname,value,  $
   ADD_REPLACE = add_rep, $
   DELETE = delete, $
   CLOSEST = closest, $
   SUCCESS = success, $
   VALUE = value2,   $   ;obsolete keyword
   INDEX = index

pos = strpos(tagname,'.')
if pos ge 0 then begin
   base_name = strupcase( strmid(tagname,0,pos) )
   ext  = strmid(tagname,pos+1,100) 
endif else base_name=strupcase(tagname)

;closest = 1
success = 0
if data_type(struct) ne 8 then  index = -2 else begin
   tags = tag_names(struct)
   index = (where(base_name eq tags,count))[0]
   if count gt 1 then message,/info,'More than one exact match of '+base_name+' found.'
   if count eq 0 and keyword_set(closest) then begin
      p = intarr(n_elements(tags))
      for i=0,n_elements(tags)-1 do   p[i] = strpos(base_name,tags[i])
      mx = max((p eq 0) * strlen(tags),index)
      if mx eq 0 then index=-1
 ;printdat,tags
 ;printdat,p
 ;printdat,index
      w = where(p eq 0,count)
      if count ge 2 then  $
        message,/info,'Warning: multiple close matchs of '+base_name+' found:'+string(/print,tags[w])
      if count eq 1 then message,/info,'Near match of '+base_name+' found: '+tags[index]
   endif
endelse

n = index

if pos ge 0 then begin          ; make recursive call
   if index ge 0 then new_struct= struct.(index)
   str_element,new_struct,ext,value, index=i, success=success,  $
          add_rep=add_rep,delete=delete
   if keyword_set(add_rep) then $
          str_element,struct,base_name,new_struct,/add_rep
   index = [index,i]
   return
endif

if keyword_set(add_rep) and (n_elements(value) eq 0) then delete=1

if keyword_set(delete) then begin
   delete_var = n
   add_rep = n ge 0
endif else delete_var=-1


if keyword_set(add_rep) or keyword_set(delete) then begin

  if n_elements(struct) gt 1 then begin    ; special case:  arrays of structs
    replace = keyword_set(delete)
    replace = replace or ( n lt 0 )
;    replace = replace or (data_type(value) eq 8)
    if not replace then begin
      s1 = size(struct.(n))
      s2 = size(value)
      w = where(s1 ne s2,diff_type)
      replace = replace or (diff_type ne 0)
    endif
    if not replace and (data_type(value) eq 8) then begin
       new_tags= tag_names_r(value[0],data_type=new_dt)
       old_tags= tag_names_r(struct[0].(n),data_type=old_dt)
       replace =  n_elements(new_tags) ne n_elements(old_tags)
       w = where(new_tags ne old_tags,diff_type)
       replace = replace or (diff_type ne 0)
       w = where(new_dt ne old_dt,diff_type)
       replace = replace or (diff_type ne 0)
    endif
    if replace then begin
;      message,/info,'Testing...  Adding '+base_name+' to array of structures'
      s0 = struct[0]
;      d = dimen(value)
      v0 = value[0]   ;needs work: should be all but last dimension
      str_element,/add,s0,base_name,v0,delete=delete,index=nj
;  help,nj,s0,v0,/st
      new_struct = make_array(value=s0,dim=dimen(struct))
      ntags = n_tags(new_struct)
      tags = tag_names(new_struct)
;      old_tags = tag_names(struct)
      for i=0,ntags-1 do begin
;         if i ne delete_var then begin
           str_element,s0,tags[i],index=j
           if i eq nj then new_value = value else new_value=struct.(j)
;           str_element,s0,old_tags[i],index=j
           new_struct.(i) = new_value
;         endif
      endfor
;      str_element,s0,base_name,index=j
;      if not keyword_set(delete) then new_struct.(j) = value
      struct=new_struct
    endif else begin
      struct.(n)=value
    endelse
    return
  endif


  case n of
      -2:  if n_elements(value) ne 0  then $
                struct = create_struct(base_name,value)  ; struct did not exist
      -1:  if n_elements(value) ne 0  then $
                struct = create_struct(struct,base_name,value)   ; add new tag
    else:  begin
       replace = keyword_set(delete)
       replace = replace or (data_type(value) eq 8)
       if not replace then begin
          s1 = size(struct.(n))
          s2 = size(value)
          w = where(s1 ne s2,diff_type)
          replace = replace or (diff_type ne 0)
       endif
       if replace then begin  ;       new type: replace value
          ntags = n_elements(tags)
          new_struct = 0
          for i=0,ntags-1 do begin
             if i ne delete_var then begin
               if i eq n then new_value=value else new_value=struct.(i)
               if not keyword_set(new_struct) then  $
                    new_struct = create_struct(tags[i],new_value) $
               else new_struct = create_struct(new_struct,tags[i],new_value)   
             endif
          endfor
          struct = new_struct
       endif  else struct.(n)=value         ;same type: copy value
    endelse
  endcase
  success = 1
  if n lt 0 then index = n_tags(struct)-1

endif else begin

   if n ge 0 then begin
      value = struct.(n)
      value2 = value
      success=1
   endif

endelse

return
end


