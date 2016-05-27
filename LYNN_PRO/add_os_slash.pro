;+
;*****************************************************************************************
;
;  FUNCTION :   add_os_slash.pro
;  PURPOSE  :   This routine appends the file path separator specific the calling OS,
;                 if that separator is not already present.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DIR  :  Scalar or [N]-element [string] array of file paths
;                         (i.e., directory locations) to which the user wishes to
;                         add a trailing file path separator (or slash)
;
;  EXAMPLES:    
;               s_dir = add_os_slash(dir)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See also:  get_os_slash.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/20/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/20/2015   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION add_os_slash,dir

;;  Let IDL know that the following are functions
FORWARD_FUNCTION get_os_slash
;;----------------------------------------------------------------------------------------
;;  Constants/Defaults
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
s              = ''
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;  Error messages
noinput_mssg   = 'No or incorrect input was supplied...'
bad_in_for_msg = 'Incorrect input format was supplied:  DIR must be of string type...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,s[0]
ENDIF
test           = (SIZE(dir,/TYPE) NE 7)
IF (test[0]) THEN BEGIN
  MESSAGE,bad_in_for_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,dir
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define parameters
;;----------------------------------------------------------------------------------------
s_dir          = REFORM(dir)
s_len          = STRLEN(s_dir) - 1L
n_dir          = N_ELEMENTS(s_dir)
;;----------------------------------------------------------------------------------------
;;  Check for trailing slash
;;----------------------------------------------------------------------------------------
FOR j=0L, n_dir[0] - 1L DO BEGIN
  dr             = s_dir[j]
  ll             = STRMID(dr[0],s_len[j],1L)
  test_ll        = (ll[0] NE slash[0]); AND (dr[0] NE s[0])
  IF (test_ll[0]) THEN s_dir[j] = s_dir[j]+slash[0]
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,s_dir
END

