;+
;*****************************************************************************************
;
;  FUNCTION :   get_os_slash.pro
;  PURPOSE  :   This routine determines the directory separator used for the current
;                 operating system (OS).  For instance, if this routine is called
;                 using a Mac or Unix OS, the return will be '/'.
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
;               NA
;
;  EXAMPLES:    
;               UMN> slash = get_os_slash()
;               UMN> PRINT, slash[0]
;               /
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Now takes advantage of the built-in PATH_SEP.PRO and added error
;                   handling for older versions of IDL
;                                                                  [08/08/2013   v1.1.0]
;
;   NOTES:      
;               NA
;
;   CREATED:  03/21/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/08/2013   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_os_slash

;;----------------------------------------------------------------------------------------
;;  Determine OS
;;----------------------------------------------------------------------------------------
vers           = !VERSION
osfam          = vers.OS_FAMILY                  ;;  e.g., 'unix'
vrel           = !VERSION.RELEASE                ;;  e.g., '7.1.1'
IF (vrel[0] GE '5.4') THEN BEGIN
  IF (vrel[0] GE '5.5') THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Using IDL ≥ v5.5
    ;;------------------------------------------------------------------------------------
    slash = PATH_SEP()
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Using IDL v5.4
    ;;------------------------------------------------------------------------------------
    ;;  Check for trailing '/'
    mdir           = FILE_EXPAND_PATH('')
    ll             = STRMID(mdir, STRLEN(mdir) - 1L,1L)
    CASE ll[0] OF
      '/'  : BEGIN  ;;  Unix
        slash = '/'
      END
      '\'  : BEGIN  ;;  Windows
        slash = '\'
      END
      ELSE : BEGIN
        IF (osfam[0] NE 'unix') THEN BEGIN
          ;;  Windows
          slash = '\'
        ENDIF ELSE BEGIN
          ;;  Unix
          slash = '/'
        ENDELSE
      END
    ENDCASE
  ENDELSE
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Using IDL pre-v5.4
  ;;--------------------------------------------------------------------------------------
  temp  = 'not_real_file'
  ;;  Define subdirectory
  test  = FILEPATH(temp[0])
  ;;  Remove 'not_real_file' and determine separator
  mdir  = STRMID(test[0],0L,STRLEN(test[0]) -STRLEN(temp))
  slash = STRMID(mdir, STRLEN(mdir) - 1L,1L)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return slash
;;----------------------------------------------------------------------------------------

RETURN,slash
END