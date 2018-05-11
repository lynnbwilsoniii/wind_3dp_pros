;+
;*****************************************************************************************
;
;  PROCEDURE:   delete_variable.pro
;  PURPOSE  :   This routine removes any variables supplied (up to 16) similar to the
;                 DELVAR.PRO IDL built-in, but does not need to be called from the
;                 $MAIN$ level.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               V[00-15]  :  Variables [any type] to delete
;
;  EXAMPLES:    
;               [calling sequence]
;               delete_variable,v00 [,v01] [,v02] [,v03] [,v04] [,v05] [,v06] [,v07] $
;                               [,v08] [,v09] [,v10] [,v11] [,v12] [,v13] [,v14] [,v15]
;
;               ;;  Example
;               x = findgen(10)
;               y = ptr_new()
;               z = 'alphabet'
;               w = {x:x,z:z}
;               HELP,x,y,z,w
;                 X               FLOAT     = Array[10]
;                 Y               POINTER   = <NullPointer>
;                 Z               STRING    = 'alphabet'
;                 W               STRUCT    = -> <Anonymous> Array[1]
;               delete_variable,x,y,z,w
;               HELP,x,y,z,w
;                 X               UNDEFINED = <Undefined>
;                 Y               UNDEFINED = <Undefined>
;                 Z               UNDEFINED = <Undefined>
;                 W               UNDEFINED = <Undefined>
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Updated Man. page and now avoids the use of pointer heap variables
;                                                                   [04/30/2018   v1.1.0]
;
;   NOTES:      
;               0)  Only one variable input is required
;               1)  See:  http://idlastro.gsfc.nasa.gov/
;               2)  Using TEMPORARY avoids unnecessary pointer heap variable use
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM:  delvarx.pro [Astronomy library, GSFC]
;   CREATED:  08/29/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/30/2018   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO delete_variable,v00,v01,v02,v03,v04,v05,v06,v07,v08,v09,v10,v11,v12,v13,v14,v15

;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1)
IF (test[0]) THEN RETURN
verns                   = !VERSION.RELEASE     ;;  e.g., '7.1.1'
vernn                   = FLOAT(STRMID(verns[0],0L,3L))
IF (vernn[0] LT 4.0) THEN RETURN      ;;  Cannot handle pre-v4.0 IDL
;;----------------------------------------------------------------------------------------
;;  Define variable strings
;;----------------------------------------------------------------------------------------
nparm          = N_PARAMS()
nstr           = STRTRIM(STRING(LINDGEN(nparm),FORMAT='(I2.2)'),2L)
vstr           = 'v'+nstr
;;----------------------------------------------------------------------------------------
;;  Free variables
;;----------------------------------------------------------------------------------------
FOR i=0L, nparm[0] - 1L DO BEGIN
  IF (vernn[0] GE 6.1) THEN BEGIN
    ;;  Post v6.1
    defined = N_ELEMENTS(SCOPE_VARFETCH(vstr[i],LEVEL=0))
    IF (defined[0] GT 0) THEN dumb = N_ELEMENTS(TEMPORARY(SCOPE_VARFETCH(vstr[i],LEVEL=0)))
  ENDIF ELSE BEGIN
    ;;  Post v4.0 and Per v6.1
    exstr = 'dumb = N_ELEMENTS(TEMPORARY('+vstr[i]+'))'
    temp  = EXECUTE(exstr[0])
  ENDELSE
  ;;  Cleanup
  temp    = 0
  exstr   = ''
  dumb    = 0
  defined = 0
;  IF LOGICAL_TRUE(defined) THEN BEGIN
;    ;; Steps/Method
;    ;;   1)  Create a new pointer with the same name as the original
;    ;;         A)  The NO_COPY sets the original variable to UNDEFINED
;    ;;   2)  Release the new pointer using HEAP_FREE
;    ;;         =>  Nothing remains
;             HEAP_FREE, PTR_NEW(SCOPE_VARFETCH(vstr[i],LEVEL=0),/NO_COPY)
;  ENDIF
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
