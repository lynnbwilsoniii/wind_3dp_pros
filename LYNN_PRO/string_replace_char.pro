;+
;*****************************************************************************************
;
;  FUNCTION :   string_replace_char.pro
;  PURPOSE  :   Replaces designated character with user defined character.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               STRS      :  N-Element string array which, on input, contain the
;                              string OLD_CHAR which you wish to replace with
;                              NEW_CHAR
;               OLD_CHAR  :  Scalar string specifying the specific character in each
;                              element of STRS that you wish to replace with NEW_CHAR
;               NEW_CHAR  :  Scalar string that replaces OLD_CHAR
;
;  EXAMPLES:    
;               ; => Replace '/' with ' '
;               strs     = '2001-11-14/01:14:06.127 UT'
;               old_char = '/'
;               new_char = ' '
;               PRINT, string_replace_char(strs,old_char,new_char)
;                 2001-11-14 01:14:06.127 UT
;
;               ; => Or replace '-' with '/'
;               strs     = '2001-11-14/01:14:06.127 UT'
;               old_char = '-'
;               new_char = '/'
;               PRINT, string_replace_char(strs,old_char,new_char)
;                 2001/11/14/01:14:06.127 UT
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Added error handling to check input string and each individual string
;                   if input is an array of strings                [10/15/2010   v1.1.0]
;             2)  Fixed an issue that occurred when user passed a null string as the
;                   new string to replace the old string           [03/25/2011   v1.1.1]
;             3)  Fixed an issue that occurred when user passed '[' string value as the
;                   old string which has issues with STRMATCH      [04/11/2011   v1.1.2]
;
;   NOTES:      
;               1)  Do NOT use '*' in either OLD_CHAR or NEW_CHAR
;
;   CREATED:  07/14/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/11/2011   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION string_replace_char,strs,old_char,new_char

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
sst    = REFORM(strs)
ochar  = old_char[0]
nchar  = new_char[0]
ns     = N_ELEMENTS(sst)
gposis = LONARR(ns)
olen   = STRLEN(ochar[0])
nlen   = STRLEN(nchar[0])
;-----------------------------------------------------------------------------------------
; => Check input to make sure it contains the old string character(s)
;-----------------------------------------------------------------------------------------
IF (ochar[0] EQ '[') THEN BEGIN
  test0  = TOTAL(STRMATCH(sst[*],'*\'+ochar+'*',/FOLD_CASE),/NAN) GT 0
ENDIF ELSE BEGIN
  test0  = TOTAL(STRMATCH(sst[*],'*'+ochar+'*',/FOLD_CASE),/NAN) GT 0
ENDELSE

IF NOT test0 THEN BEGIN
  badmssg = 'The input does not contain the string pattern:  '+ochar
  MESSAGE,badmssg,/INFORMATIONAL,/CONTINUE
  RETURN,sst
ENDIF
; => check to see if new_char = ''
IF (nchar[0] EQ '' OR olen[0] NE nlen[0]) THEN BEGIN
  IF (nchar[0] EQ '') THEN BEGIN
    ; => user wishes to erase old_char
    nnch  = REPLICATE(' ',olen[0])
  ENDIF ELSE BEGIN
    ; => new_char length does not equal old_char length
    IF (nlen[0] EQ 1) THEN BEGIN
      nnch  = REPLICATE(nchar[0],olen[0])
    ENDIF ELSE BEGIN
      dlen = (olen[0] - nlen[0]) > (nlen[0] - olen[0])
      nnch = nchar[0]+STRJOIN(REPLICATE(' ',dlen[0]),/SINGLE)
    ENDELSE
  ENDELSE
  nchar = STRJOIN(nnch,/SINGLE)
ENDIF
;-----------------------------------------------------------------------------------------
; => Replace string characters with new ones
;-----------------------------------------------------------------------------------------
cc = 1
WHILE(cc) DO BEGIN
  ; => Test for a consistent pattern in the input
  gposi  = STRPOS(sst[*],ochar)
  unq    = N_ELEMENTS(UNIQ(gposi,SORT(gposi)))
  IF (unq EQ 1) THEN BEGIN
    ; => position of old string is consistent in all input strings
    STRPUT,sst,nchar,gposi[0]
  ENDIF ELSE BEGIN
    ; => multiple positions of old string in input strings
    bb = 1
    j  = 0L
    WHILE(bb) DO BEGIN
      tt     = sst[j]
      ; => Find the position of the character you wish to replace
      gposi  = STRPOS(sst[j],ochar)
      IF (gposi GE 0) THEN BEGIN
        ; => Replace the character
        STRPUT,tt,nchar,gposi[0]
        sst[j] = tt[0]
      ENDIF ELSE BEGIN
        sst[j] = sst[j]
      ENDELSE
      j += 1L
      IF (j LE ns - 1L) THEN bb = 1 ELSE bb = 0
    ENDWHILE
  ENDELSE
  ; => Be careful with '[' string
  IF (ochar[0] EQ '[') THEN BEGIN
    cc = TOTAL(STRMATCH(sst,'*\'+ochar+'*',/FOLD_CASE),/NAN) GT 0
  ENDIF ELSE BEGIN
    cc = TOTAL(STRMATCH(sst,'*'+ochar+'*',/FOLD_CASE),/NAN) GT 0
  ENDELSE
ENDWHILE


RETURN, sst
END