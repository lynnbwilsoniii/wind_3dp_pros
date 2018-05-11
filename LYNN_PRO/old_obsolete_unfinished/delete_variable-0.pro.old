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
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               V[??]  :  Variables to delete
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See:  http://idlastro.gsfc.nasa.gov/
;
;   ADAPTED FROM:  delvarx.pro [Astronomy library, GSFC]
;   CREATED:  08/29/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/29/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO delete_variable,v00,v01,v02,v03,v04,v05,v06,v07,v08,v09,v10,v11,v12,v13,v14,v15

;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1)
IF (test) THEN RETURN
;;----------------------------------------------------------------------------------------
;; => Define variable strings
;;----------------------------------------------------------------------------------------
nparm          = N_PARAMS()
nstr           = STRTRIM(STRING(LINDGEN(nparm),FORMAT='(I2.2)'),2L)
vstr           = 'v'+nstr
;;----------------------------------------------------------------------------------------
;; => Free variables
;;----------------------------------------------------------------------------------------
FOR i=0L, nparm[0] - 1L DO BEGIN
  defined = N_ELEMENTS(SCOPE_VARFETCH(vstr[i],LEVEL=0))
  IF LOGICAL_TRUE(defined) THEN BEGIN
    ;; Steps/Method
    ;;   1)  Create a new pointer with the same name as the original
    ;;         A)  The NO_COPY sets the original variable to UNDEFINED
    ;;   2)  Release the new pointer using HEAP_FREE
    ;;         =>  Nothing remains
             HEAP_FREE, PTR_NEW(SCOPE_VARFETCH(vstr[i],LEVEL=0),/NO_COPY)
  ENDIF
ENDFOR
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
