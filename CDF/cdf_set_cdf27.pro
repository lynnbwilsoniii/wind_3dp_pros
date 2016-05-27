;+
; NAME: cdf_set_cdf27
; SYNTAX: 
;   cdf_set_cdf27 [, /yes | /no]
; PURPOSE:
;   Call CDF_SET_CDF27_BACKWARD_COMPATIBLE but don't bomb unnecessarily when
;   run on an (unpatched) pre-IDL 6.3, pre-CDF 3.1 installation of IDL.
; VERSION:
;   $LastChangedBy: kenb-mac $
;   $LastChangedDate: 2006-12-13 11:21:07 -0800 (Wed, 13 Dec 2006) $
;   $LastChangedRevision: 88 $
;   $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/ssl_general/trunk/CDF/cdf_set_cdf27.pro $
;-
PRO cdf_set_cdf27, YES=yes, NO=no
  CDF_LIB_INFO, VERS=vers, REL=rel
  version = vers+rel/10.0
  IF version LT 3.1 THEN BEGIN
     IF KEYWORD_SET(no) THEN MESSAGE, 'Error: CDF 3.1 required'
  ENDIF ELSE BEGIN
     CDF_SET_CDF27_BACKWARD_COMPATIBLE, YES=yes, NO=no
  ENDELSE
END

