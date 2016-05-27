;+
;*****************************************************************************************
;
;  FUNCTION :   find_struc_values.pro
;  PURPOSE  :   Recursively searches an input structure for a tag matching the input.
;
;  CALLED BY:   
;               get_tplot_handle_props.pro
;
;  CALLS:
;               tag_names_r.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STRUCT  :  An IDL structure
;               TAG     :  Scalar string the user wishes to match to one of the structure
;                            tags or subtags
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  04/06/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/06/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION find_struc_values,struct,tag

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f           = !VALUES.F_NAN
d           = !VALUES.D_NAN
; => Dummy error messages
noinpt_msg  = 'No input supplied...'
notstr_mssg = 'Must be an IDL structure...'
badstr_mssg = 'Not an appropriate structure tag...'
tagnotfound = 'No structure tags are associated with input TAG...'
; => EXECUTE string prefix and suffix
expref      = 'str_element,struc_out,new_tag[0],str.'
exsuff      = ',/ADD_REPLACE'
;-----------------------------------------------------------------------------------------
; => Check for input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN BEGIN
  ; => no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;-----------------------------------------------------------------------------------------
; => Check input format
;-----------------------------------------------------------------------------------------
str = struct[0]   ; => in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,notstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  make sure tag is okay
stag = IDL_VALIDNAME(tag[0])
IF (stag EQ '') THEN BEGIN
  MESSAGE,badstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;-----------------------------------------------------------------------------------------
; => Find tag within structure
;-----------------------------------------------------------------------------------------
;;  define the base level structure tag names
base_tags  = STRLOWCASE(TAG_NAMES(str))
n_baset    = N_TAGS(str)
;;  get ALL the tags and subtags
def_tags   = STRLOWCASE(tag_names_r(str))
;; check for TAG
IF (def_tags[0] NE '') THEN BEGIN
  check_d0 = WHERE(STRPOS(def_tags,stag[0]) GE 0,chd0)
  IF (chd0 GT 0) THEN BEGIN
    ;-------------------------------------------------------------------------------------
    ; => found tag(s), now check if subtag(s) or base level tag(s)
    ;-------------------------------------------------------------------------------------
    FOR j=0L, chd0 - 1L DO BEGIN
      jstr    = STRING(j,FORMAT='(I4.4)')
      ;;  define new tag for output (in case multiple found)
      new_tag  = stag[0]+'_'+jstr[0]
      tag0     = def_tags[check_d0[j]]
      ;;  define string used by EXECUTE
      exstring = expref[0]+tag0[0]+exsuff[0]
      result   = EXECUTE(exstring[0])
      IF (result EQ 0) THEN BEGIN
        ;;  did not work
        IF (j EQ 0) THEN struc_out = 0b
        IF (j GT 0) THEN BEGIN
          str_element,struc_out,new_tag[0],/DELETE
        ENDIF
      ENDIF
    ENDFOR
  ENDIF ELSE BEGIN
    ;-------------------------------------------------------------------------------------
    ; => no tag found
    ;-------------------------------------------------------------------------------------
    struc_out = 0b
  ENDELSE
ENDIF
;-----------------------------------------------------------------------------------------
; => Check output
;-----------------------------------------------------------------------------------------
IF (SIZE(struc_out,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,tagnotfound,/INFORMATIONAL,/CONTINUE
  struc_out = 0b
ENDIF
;-----------------------------------------------------------------------------------------
; => Return result
;-----------------------------------------------------------------------------------------
RETURN,struc_out
END
