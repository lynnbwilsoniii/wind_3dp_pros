;+
;*****************************************************************************************
;
;  FUNCTION :   options.pro
;  PURPOSE  :   Add (or change) an element of a structure.  This routine is useful for
;                 changing plotting options for tplot, but can also be used for
;                 creating limit structures for other routines such as "SPEC3D"
;                 or "CONT2D"
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               get_data.pro
;               str_element.pro
;               extract_tags.pro
;               tnames.pro
;               store_data.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STRUCT    :  Either a string [scalar or array], a number
;                              [scalar or array], or a single structure
;                              String     :  The limit structure associated with the
;                                              "TPLOT" handle name is altered.
;                                              [Warning!  wildcards accepted!  "*" will
;                                               change ALL tplot quantities!]
;                              Number     :  The limit structure for the given "TPLOT"
;                                              quantity is altered.  The number/name
;                                              association is given by "TPLOT_NAMES"
;                              Structure  :  A structure to be created, added to,
;                                              or changed/destroyed
;               TAG_NAME  :  Scalar string defining either the structure tag name
;                              in STRUCT to deal with or a string defining the keyword
;                              associated with a PLOT.PRO etc. to change/alter
;               VALUE     :  [any type or dimension] The new value associated with
;                              TAG_NAME
;
;  EXAMPLES:    
;               ; => Change the Y-Axis range of a TPLOT handle called 'density'
;               ;      to the following:  0.0 to 10.0
;               ;
;               ;       [STRUCT] , [TAG_NAME] ,  [VALUE]
;               options,'density',  'YRANGE'  , [0.0,10.0]
;
;  KEYWORDS:    
;  **Obsolete** DELETE    :  If set, then the corresponding tag_name is removed.
;  **Obsolete** GET       :  If set, return the current value for the tag name in a
;                              structure or array of structures.  To use this keyword,
;                              the value variable must be previously defined.
;               DEFAULT   :  If set, program will modify the default limits structure
;                              rather than the regular limits structure
;               _EXTRA    :  Similar to the built-in IDL inheritance keyword
;                              [see IDL's documentation for details]
;
;   CHANGED:  1)  Davin Larson changed something...        [04/07/1999   v1.0.19]
;             2)  Re-wrote and cleaned up                  [08/04/2011   v1.1.0]
;
;   NOTES:      
;               1)  if VALUE is undefined then it will be DELETED from the structure
;               2)  if TAG_NAME is undefined, then the entire limit structure is deleted
;               3)  See Also:
;                      A)  get_data.pro
;                      B)  store_data.pro
;                      C)  str_element.pro
;                      D)  tnames.pro
;
;   CREATED:  ??/??/????
;   CREATED BY: Jasper Halekas
;    LAST MODIFIED:  08/04/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO options,struct,tag_name,value,DELETE=delete,GET=get,DEFAULT=default,_EXTRA=ex

;-----------------------------------------------------------------------------------------
; => Load common blocks
;-----------------------------------------------------------------------------------------
@tplot_com
;-----------------------------------------------------------------------------------------
; => Check obsolete keywords
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(delete) THEN MESSAGE,/INFORMATIONAL,'Unnecessary use of DELETE keyword'

IF KEYWORD_SET(get) THEN BEGIN
  MESSAGE,/INFORMATIONAL,'Unnecessary use of get keyword'
  n     = N_ELEMENTS(struct)
  value = value[0]
  FOR i=0L, n - 1L DO BEGIN
    get_data,struct[i],ALIMIT=limit
    str_element,limit,tag_name,VALUE=v
    value = [value,v]
  ENDFOR
  value = value[1L:n]
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
typv = SIZE(value,/TYPE)
IF (typv[0] EQ 0 AND NOT KEYWORD_SET(ex)) THEN delete = 1
dt   = SIZE(struct,/TYPE)

IF ((dt EQ 8) OR NOT KEYWORD_SET(struct)) THEN BEGIN
  IF KEYWORD_SET(tag_name) THEN BEGIN
    str_element,struct,tag_name,value,DELETE=delete,/ADD_REPLACE
  ENDIF ELSE BEGIN
    extract_tags,struct,ex
  ENDELSE
ENDIF ELSE BEGIN
  ; => struct is a TPLOT variable
  names = tnames(REFORM(struct),n)      ; => Added use of REFORM in case struct = [1,N]-Element array
  FOR i=0L, n - 1L DO BEGIN
    name = names[i]
    IF KEYWORD_SET(default) THEN BEGIN
      ; => Get stored default limit
      get_data,name[0],DLIMIT=limit
    ENDIF ELSE BEGIN
      ; => Get stored limit
      get_data,name[0],LIMIT=limit
    ENDELSE
    ; => Check TAG_NAME
    IF KEYWORD_SET(tag_name) THEN BEGIN
      str_element,limit,tag_name,value,DELETE=delete,/ADD_REPLACE
    ENDIF ELSE BEGIN
      extract_tags,limit,ex
    ENDELSE
    IF KEYWORD_SET(default) THEN BEGIN
      ; => Store new limit structure
      store_data,name[0],DLIMIT=limit
    ENDIF ELSE BEGIN
      ; => Store new limit structure
      store_data,name[0],LIMIT=limit
    ENDELSE
  ENDFOR
  IF (n EQ 0) THEN BEGIN
    errmsg = 'No TPLOT names found that match: '+STRING(struct,/PRINT)
    MESSAGE,errmsg[0],/INFORMATIONAL
  ENDIF
ENDELSE
;-----------------------------------------------------------------------------------------
RETURN
END
