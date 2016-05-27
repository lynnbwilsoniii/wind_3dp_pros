;+
;*****************************************************************************************
;
;  FUNCTION :   strfilter.pro
;  PURPOSE  :   Returns the subset of a string array that matches the search string.
;                 1)  '*' will match all (non-null) strings
;                 2)  ''  will match only the null string
;               RETURNS:
;                 1)  Array of matching strings.
;                 2)  Array of string indices.
;                 3)  Byte array with same dimension as input string.
;
;  CALLED BY:   
;               tnames.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               STR        :  N-Element string array to be filtered
;               MATCHS     :  Scalar string used to search for in STR
;                               [may contain wildcards like '*']
;
;  EXAMPLES:    
;               :  To print all files that do NOT end with *.pro
;               PRINT, strfilter(FINDFILE('*'),'*.pro',/NEGATE)    ; => Before Version 6.1
;               PRINT, strfilter(FILE_SEARCH('*'),'*.pro',/NEGATE) ; => After 6.1
;               
;
;  KEYWORDS:    
;               COUNT      :  A named variable that will contain the number of 
;                               matched strings.
;               WILDCARD   :  
;               FOLD_CASE  :  If set, then program is case insensitive
;               DELIMITER  :  
;               INDEX      :  If set, then matching indicies of the STR array with
;                               matching strings from MATCHS
;               STRING     :  If set, then matching strings are returned
;               BYTE       :  If set, then a byte array is returned
;               NEGATE     :  
;
;   CHANGED:  1)  Modified to use the IDL strmatch function so that '?' is accepted 
;                   for versions > 5.4                          [07/??/2000   v1.0.?]
;             2)  Davin Larson changed something...             [10/08/2001   v1.0.?]
;             3)  Re-wrote and cleaned up                       [09/08/2009   v1.1.0]
;
;   NOTES:      
;               1)  this routine is very similar to the STRMATCH routine introduced in 
;                     IDL 5.3 with some enhancements that make it more useful (i.e. 
;                     it can handle string arrays).
;
;   CREATED:  Feb. 1999
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/08/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION strfilter,str,matchs,COUNT=count,WILDCARD=wildcard,FOLD_CASE=fold_case,  $
                              DELIMITER=delimiter,INDEX=index,STRING=retstr,      $
                              BYTE=bt,NEGATE=negate

;-----------------------------------------------------------------------------------------
; => Check Version 5.3
;-----------------------------------------------------------------------------------------
IF (!VERSION.RELEASE GE '5.3') THEN BEGIN
  matcharray = KEYWORD_SET(matchs) ? matchs : ''
  IF (KEYWORD_SET(delimiter) AND SIZE(matcharray,/DIMENSIONS) EQ 0) THEN BEGIN
    matcharray = STRSPLIT(matcharray,delimiter,/EXTRACT)
  ENDIF
  IF KEYWORD_SET(wildcard) THEN MESSAGE,'Wildcard "'+wildcard+'" ignored',/INFORMATIONAL
  ret = 0b
  FOR k=0L, N_ELEMENTS(matcharray) - 1L DO BEGIN
    ret = STRMATCH(str,matcharray[k],FOLD_CASE=fold_case) OR ret
  ENDFOR
ENDIF ELSE BEGIN   ; Old version follows:
  ns  = STRLEN(str)
  ret = ns EQ -1   ; set to 0
  IF NOT KEYWORD_SET(wildcard) THEN wildcard = '*'
  FOR k=0L, N_ELEMENTS(matchs) - 1L DO BEGIN
    match = matchs[k]
;mss=str_sep(match,wildcard)
    mss   = STRSPLIT(match,wildcard,/EXTRACT)
    nmss  = KEYWORD_SET(match) ? N_ELEMENTS(mss) : 0
    ; => Quick test to improve speed,  required to find a null string
    IF (match EQ wildcard) THEN BEGIN
      ret[*] = 1
      GOTO,JUMP_SKIP   ; pass all strings
    ENDIF
    ; => Quick test to improve speed,  but not required
    IF (nmss EQ 1) THEN BEGIN  ; => No wildcards to match do the simple thing
      ret = (str EQ match) OR ret
      GOTO,JUMP_SKIP
    ENDIF
    lms = STRLEN(mss)
    ; =>  Unfortunately strmid and strpos don't allow pos to be vectors, so an extra
    ;       loop is required here
    FOR i=0L, N_ELEMENTS(str) - 1L DO BEGIN
      temp = str[i]
      p    = 0
      FOR j=0L, nmss - 1L DO BEGIN
        p2 = (j LT nmss-1) ? STRPOS(temp,mss[j],p) : RSTRPOS(temp,mss[j])
        IF (j EQ 0) THEN r = (p2 EQ 0) ELSE r = (p2 GE p)
        p = p2 + lms[j]
        IF (r EQ 0) THEN GOTO,JUMP_BREAK
      ENDFOR
      r      = (p EQ ns[i])
      ;===================================================================================
      JUMP_BREAK:
      ;===================================================================================
      ret[i] = (ret[i] OR r)
    ENDFOR
    ;=====================================================================================
    JUMP_SKIP:
    ;=====================================================================================
  ENDFOR
ENDELSE  ; => End of Old IDL version
;-----------------------------------------------------------------------------------------
; -Determine what to return
;-----------------------------------------------------------------------------------------

IF KEYWORD_SET(negate) THEN ret = (ret EQ 0)
ind  = WHERE(ret,count)
nstr = (count EQ 0) ?  '' : str[ind]
IF KEYWORD_SET(retstr) THEN RETURN, nstr
IF KEYWORD_SET(index)  THEN RETURN, ind
IF KEYWORD_SET(bt)     THEN RETURN, ret
;message,/info,'Please use KEYWORD, default will change to STRING'
RETURN,nstr   ; this default may change!
END
