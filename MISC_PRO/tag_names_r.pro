;+
;*****************************************************************************************
;
;  FUNCTION :   tag_names_r.pro
;  PURPOSE  :   Very similar to the TAG_NAMES function but recursively obtains all
;                 structure names within imbedded structures as well.
;
;  CALLED BY:   
;               str_element.pro
;
;  CALLS:
;               tag_names_r.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STRUCTURE  :  Scalar IDL structure
;
;  EXAMPLES:    
;               test = tag_names_r(structure, [TYPE=dt])
;
;  KEYWORDS:    
;               TYPE       :  Set to a named variable to return an array of data types
;                               corresponding to the tags in STRUCTURE
;               COUNT      :  Set to a named variable to return the number of tags
;                               in STRUCTURE
;
;   CHANGED:  1)  Updated to be in accordance with newest version of tag_names_r.pro
;                   in TDAS IDL libraries
;                   A)  Cleaned up and added some comments
;                   B)  no longer calls data_type.pro or append_array.pro
;                   C)  new keywords:  TYPE and COUNT
;                                                                  [04/04/2012   v1.1.0]
;
;   NOTES:      
;               1)  If STRUCTURE is not an IDL structure, then routine returns a null
;                     string
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  04/04/2012   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION tag_names_r,structure,TYPE=dtype,COUNT=count

;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
count = 0
dtype = SIZE(structure,/TYPE)
IF (dtype NE 8) THEN BEGIN
  RETURN,''
ENDIF ELSE BEGIN
  struct0 = structure[0]
  tags    = TAG_NAMES(struct0)
  FOR i=0L, N_ELEMENTS(tags) - 1L DO BEGIN
    tgs       = tag_names_r(struct0.(i),TYPE=dt)
    dtype     = (i EQ 0) ? dt      : [dtype,dt]
    IF KEYWORD_SET(tgs) THEN BEGIN
      tgs     = tags[i] + '.' + tgs
      alltags = (i EQ 0) ? tgs     : [alltags,tgs]
    ENDIF ELSE BEGIN
      alltags = (i EQ 0) ? tags[i] : [alltags,tags[i]]
    ENDELSE
  ENDFOR
  count = N_ELEMENTS(dtype)
  RETURN,alltags
ENDELSE

END

