;+
;*****************************************************************************************
;
;  FUNCTION :   str_element.pro
;  PURPOSE  :   Find (or add) an element (i.e. tag name w/ or w/o data) of a structure.
;                 This program retrieves the value of a structure element.  This
;                 function will not produce an error if the tag and/or structure
;                 does not exist.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               str_element.pro
;               tag_names_r.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STRUCT       :  An IDL structure
;               TAGNAME      :  Scalar string defining either the structure tag you wish
;                                 to find or one you wish to add
;               VALUE        :  Either a named variable to be returned to the user 
;                                 with the data corresponding to the structure tag
;                                 [TAGNAME] or the value of the new data to use when the
;                                 keyword ADD_REPLACE is set
;
;  EXAMPLES:    
;               str_element,struct,'XRANGE',[-10.,10.],/ADD_REPLACE
;
;  KEYWORDS:    
;               ADD_REPLACE  :  If set, the data associated with the VALUE input
;                                 will be added to or replace the associated tag
;                                 in the structure
;               DELETE       :  Set this keyword to delete the tag associated with
;                                 TAGNAME input
;               CLOSEST      :  Set this keyword to allow near matches of structure
;                                 tags [useful with _EXTRA keyword in PLOT.PRO]
;               SUCCESS      :  Set to a named variable to return a 1 or 0 depending on
;                                 whether the tag was found or not, respectively
;               VALUE        :  Set to a named variable to return to the user
;                                 ** Obselete **
;               INDEX        :  Set to a named variable to return the structure tag
;                                 index.  Return values will be:
;                                 -2  :  STRUCT is not a structure
;                                 -1  :  TAGNAME is not found
;                                >=0  :  successful
;
;   CHANGED:  1)  Added recursive searching of structure hierarchy [05/07/1997   v1.0.9]
;             2)  Davin Larson modified something...               [10/08/2001   v1.0.10]
;             3)  Re-wrote and cleaned up                          [08/25/2009   v1.1.0]
;             4)  Updated to be in accordance with newest version of str_element.pro
;                   in TDAS IDL libraries
;                   A)  Cleaned up and added some comments
;                   B)  Calling sequence of tag_names_r.pro changed
;                   C)  no longer calls dimen.pro
;                                                                  [04/04/2012   v1.2.0]
;
;   NOTES:      
;               1)  This program currently only allows one input structure at a time
;                     [Even though it appears as though there is a place for structure
;                      arrays in the program, don't trust it to figure this out for
;                      you.]
;               2)  Value remains unchanged if the structure element does not exist.
;               3)  If tagname contains a '.' then the structure is recursively searched 
;                     and index will be an array of indices.
;               4)  If struct is an array of structures then results may be unpredictable.
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  04/04/2012   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO str_element,struct,tagname,value,ADD_REPLACE=add_rep,DELETE=delete,CLOSEST=closest,$
                                     SUCCESS=success,VALUE=value2,INDEX=index

;-----------------------------------------------------------------------------------------
; => Check tagname input for '.' to initiate recursive searching
;-----------------------------------------------------------------------------------------
pos = STRPOS(tagname[0],'.')
IF (pos GE 0) THEN BEGIN
   base_name = STRUPCASE(STRMID(tagname[0],0,pos))
   ext       = STRMID(tagname[0],pos + 1L)
ENDIF ELSE base_name = STRUPCASE(tagname)

;closest = 1
stype   = SIZE(struct,/TYPE)
success = 0
IF (stype NE 8) THEN BEGIN 
  index = -2 
ENDIF ELSE BEGIN
  tags = TAG_NAMES(struct)
  index = (WHERE(base_name EQ tags,count))[0]
  IF (count GT 1) THEN BEGIN
     MESSAGE,'More than one exact match of '+base_name+' found.',/INFORMATION
  ENDIF
  IF (count EQ 0 AND KEYWORD_SET(closest)) THEN BEGIN
    p  = INTARR(N_ELEMENTS(tags))
    FOR i=0L, N_ELEMENTS(tags) - 1L DO p[i] = STRPOS(base_name,tags[i])
    mx = MAX((p EQ 0) * STRLEN(tags),index,/NAN)
    IF (mx EQ 0) THEN index = -1
    w = WHERE(p EQ 0,count)
    IF (count GE 2) THEN BEGIN
      MESSAGE,'Warning: multiple close matchs of '+base_name+' found:'+STRING(/PRINT,tags[w]),/INFORMATION
    ENDIF
    IF (count EQ 1) THEN BEGIN
      MESSAGE,'Near match of '+base_name+' found: '+tags[index],/INFORMATION
    ENDIF
  ENDIF
ENDELSE
;-----------------------------------------------------------------------------------------
; => Make recursive call
;-----------------------------------------------------------------------------------------
n = index
IF (pos GE 0) THEN BEGIN
  IF (index GE 0) THEN new_struct = struct.(index)
  str_element,new_struct,ext,value,INDEX=i,SUCCESS=success,ADD_REPLACE=add_rep,$
                                   DELETE=delete
  IF KEYWORD_SET(add_rep) THEN BEGIN
    str_element,struct,base_name,new_struct,/ADD_REPLACE
  ENDIF
  index = [index,i]
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Determine whether to delete or add to structure
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(add_rep) AND (N_ELEMENTS(value) EQ 0) THEN delete = 1
IF KEYWORD_SET(delete) THEN BEGIN
  delete_var = n
  add_rep    = (n GE 0)
ENDIF ELSE delete_var = -1

n_str = N_ELEMENTS(struct)
IF (KEYWORD_SET(add_rep) OR KEYWORD_SET(delete)) THEN BEGIN
  IF (n_str GT 1) THEN BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Array of structures
    ;-------------------------------------------------------------------------------------
    replace  = KEYWORD_SET(delete)
    replace  = replace OR (n LT 0)
    IF (NOT replace) THEN BEGIN
      s1       = SIZE(struct.(n))
      s2       = SIZE(value)
      w        = WHERE(s1 NE s2,diff_type)
      replace  = replace OR (diff_type NE 0)
    ENDIF
    vtype = SIZE(value,/TYPE)
    IF (NOT replace AND vtype EQ 8) THEN BEGIN
;      new_tags  = tag_names_r(value[0],DATA_TYPE=new_dt)       ;  TDAS Update
;      old_tags  = tag_names_r(struct[0].(n),DATA_TYPE=old_dt)  ;  TDAS Update
      new_tags  = tag_names_r(value[0],TYPE=new_dt)
      old_tags  = tag_names_r(struct[0].(n),TYPE=old_dt)
      replace   = N_ELEMENTS(new_tags) NE N_ELEMENTS(old_tags)
      w         = WHERE(new_tags NE old_tags,diff_type)
      replace   = replace OR (diff_type NE 0)
      w         = WHERE(new_dt NE old_dt,diff_type)
      replace   = replace OR (diff_type NE 0)
    ENDIF
    IF (replace) THEN BEGIN
      ; => Replace values
      s0         = struct[0]
      v0         = value[0]
      ;  call itself
      str_element,s0,base_name,v0,DELETE=delete,INDEX=nj,/ADD_REPLACE
      ;  make an array of structures
      new_struct = MAKE_ARRAY(VALUE=s0,DIM=SIZE(struct,/DIMENSIONS))
      ntags      = N_TAGS(new_struct)
      tags       = TAG_NAMES(new_struct)
      FOR i=0L, ntags - 1L DO BEGIN
        str_element,s0,tags[i],INDEX=j
        IF (i EQ nj) THEN new_value = value ELSE new_value = struct.(j)
        new_struct.(i) = new_value
      ENDFOR
      struct = new_struct
    ENDIF ELSE BEGIN
      ; => Do not replace values, just define
      struct.(n) = value
    ENDELSE
    RETURN
  ENDIF
;  ENDIF ELSE IF (SIZE(struct,/TYPE) NE 0) THEN struct = struct[0]  ;  TDAS Update
  CASE n OF
    -2   : BEGIN
      IF (N_ELEMENTS(value) NE 0) THEN BEGIN
        ; => struct did not exist
        struct = CREATE_STRUCT(IDL_VALIDNAME(base_name,/CONVERT_ALL),value)
;        struct = CREATE_STRUCT(base_name,value)  ;  TDAS Update
      ENDIF
    END
    -1   : BEGIN
      IF (N_ELEMENTS(value) NE 0) THEN BEGIN
        ; =>  add new tag
        struct = CREATE_STRUCT(struct,IDL_VALIDNAME(base_name,/CONVERT_ALL),value)
;        struct = CREATE_STRUCT(struct,base_name,value)  ;  TDAS Update
      ENDIF
    END
    ELSE : BEGIN
      replace = KEYWORD_SET(delete)
      replace = replace OR (SIZE(value,/TYPE) EQ 8)
      IF (NOT replace) THEN BEGIN
        s1       = SIZE(struct.(n))
        s2       = SIZE(value)
        w        = WHERE(s1 NE s2,diff_type)
        replace  = replace OR (diff_type NE 0)
      ENDIF
      IF (replace) THEN BEGIN
        ntags      = N_ELEMENTS(tags)
        new_struct = 0
        FOR i=0L, ntags - 1L DO BEGIN
          IF (i NE delete_var) THEN BEGIN
            IF (i EQ n) THEN new_value = value ELSE new_value = struct.(i)
            IF (NOT KEYWORD_SET(new_struct)) THEN BEGIN
              new_struct = CREATE_STRUCT(IDL_VALIDNAME(tags[i],/CONVERT_ALL),new_value)
;              new_struct = CREATE_STRUCT(tags[i],new_value)  ;  TDAS Update
            ENDIF ELSE BEGIN
              new_struct = CREATE_STRUCT(new_struct,IDL_VALIDNAME(tags[i],/CONVERT_ALL),new_value)
;              new_struct = CREATE_STRUCT(new_struct,tags[i],new_value)  ;  TDAS Update
            ENDELSE
          ENDIF
        ENDFOR
        struct = new_struct
      ENDIF ELSE BEGIN
        struct.(n) = value  ; => same value =>> copy value
      ENDELSE
    END
  ENDCASE
  success = 1
  IF (n LT 0) THEN index = N_TAGS(struct) - 1L
ENDIF ELSE BEGIN
  IF (n GE 0) THEN BEGIN
    value   = struct.(n)
    value2  = value
    success = 1
  ENDIF
ENDELSE

RETURN
END
