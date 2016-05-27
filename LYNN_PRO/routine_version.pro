;+
;*****************************************************************************************
;
;  FUNCTION :   routine_version.pro
;  PURPOSE  :   This routine determines the version number associated with an input
;                 file name by examining the man page of the IDL routine defined by
;                 the file name.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               add_os_slash.pro
;               read_gen_ascii.pro
;               time_string.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               FNAME  :  Scalar [string] defining the name of the IDL routine to find the
;                           version number for
;               *************************
;               ***  Optional Inputs  ***
;               *************************
;               FDIR   :  Scalar [string] defining the full directory path to FNAME
;
;  EXAMPLES:    
;               ;;*************************************************************
;               ;;  With a well defined path specified before calling
;               ;;*************************************************************
;               UMN> fname = 'routine_version.pro'
;               UMN> fdir  = FILE_EXPAND_PATH('wind_3dp_pros/LYNN_PRO/')+'/'
;               UMN> vers  = routine_version(fname,fdir)
;               UMN> PRINT, vers
;               routine_version.pro : 08/08/2012   v1.0.0, 2012-08-08/14:27:08.951
;               ;;*************************************************************
;               ;;  User supplies no variable for file path
;               ;;*************************************************************
;               UMN> fname = 'routine_version.pro'
;               UMN> vers  = routine_version(fname)
;               UMN> PRINT, vers
;               routine_version.pro : 10/01/2015   v1.1.0, 2015-10-01/20:59:00.564
;               ;;*************************************************************
;               ;;  User supplies an undefined variable for file path
;               ;;*************************************************************
;               UMN> HELP,fdir
;               FDIR            UNDEFINED = <Undefined>
;               UMN> PRINT,routine_version('routine_version.pro',fdir)
;               UMN> routine_version.pro : 10/01/2015   v1.1.0, 2015-10-01/21:45:28.789
;               UMN> HELP,fdir
;               FDIR            STRING    = '/Users/lbwilson/Desktop/temp_idl/'
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Updated Man. page and
;                   now calls get_os_slash.pro, add_os_slash.pro
;                                                                   [10/01/2015   v1.1.0]
;             2)  Continued to update routine
;                                                                   [10/01/2015   v1.1.0]
;
;   NOTES:      
;               1)  FNAME must have a man page with version history with the following
;                     format (I added extra spaces to prevent error when calling itself):
;                        ;+
;                        .
;                        .
;                        .
;                        ;     CREATED:  MM/DD/YYYY
;                        ;     CREATED BY:  Lynn B. Wilson III
;                        ;      LAST MODIFIED:  MM/DD/YYYY   v1.0.0
;                        ;      MODIFIED BY: Lynn B. Wilson III
;                        .
;                        .
;                        .
;                        ;-
;               2)  See also:  man.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/08/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/01/2015   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION routine_version,fname,fdir

FORWARD_FUNCTION get_os_slash, add_os_slash
;;----------------------------------------------------------------------------------------
;;  Define some system-dependent variables
;;----------------------------------------------------------------------------------------
;;  Get file path separator or slash
slash          = get_os_slash()
vers           = !VERSION.OS_FAMILY     ;;  e.g., 'unix'
vern           = !VERSION.RELEASE       ;;  e.g., '7.1.1'
;;  Get current working directory
test           = (vern[0] GE '6.0')
IF (test[0]) THEN cwd_char = FILE_DIRNAME('',/MARK_DIRECTORY) ELSE cwd_char = '.'+slash[0]
cur_wdir       = add_os_slash(FILE_EXPAND_PATH(cwd_char[0]))
;;  Get list of currently compiled procedures and functions
comp_pros      = ROUTINE_INFO(/SOURCE)
comp_func      = ROUTINE_INFO(/SOURCE,/FUNCTIONS)
comp_pros_n    = comp_pros.NAME
comp_pros_p    = comp_pros.PATH
comp_func_n    = comp_func.NAME
comp_func_p    = comp_func.PATH
all_routine_n  = STRLOWCASE([comp_pros_n,comp_func_n])
all_routine_p  = [comp_pros_p,comp_func_p]
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
;mdir       = 'wind_3dp_pros'+slash[0]+'LYNN_PRO'+slash[0]
;def_dir    = FILE_EXPAND_PATH(mdir[0])+slash[0]
def_dir        = cur_wdir[0]
def_fnm        = 'routine_version.pro'
;;  Dummy error messages
no_inpt_msg    = 'User must supply at least a routine name (FNAME) as a scalar string...'
notdir_msg     = 'FDIR is not an existing directory...'
notfnm_msg     = 'FNAME is not an IDL routine...'
badnfor_msg    = 'Incorrect input format:  FNAME must be a scalar [string] defining the name of a compiled IDL routine'
baddfor_msg    = 'Incorrect input format:  FDIR must be a scalar [string] defining the full path to FNAME'
undeferr_msg   = ' variable was passed as an undefined variable...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1)
IF (test[0]) THEN BEGIN
  ;;  User did not supply anything
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,''
ENDIF
;;  User at least supplied a routine name --> check format
test           = (SIZE(fname,/TYPE) NE 7)
IF (test[0]) THEN BEGIN
  ;;  User did not supply a string
  MESSAGE,badnfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,''
ENDIF
;;  Correct variable type --> look for routine
fnm_full       = STRTRIM(fname[0],2L)
fnm_suff       = STRLOWCASE(STRMID(fnm_full[0],3L,/REVERSE_OFFSET))
test           = (fnm_full[0] EQ '') OR (fnm_suff[0] NE '.pro')
IF (test[0]) THEN BEGIN
  ;;  User provided a name, but not a routine name --> will not search blindly for it...
  MESSAGE,notfnm_msg,/INFORMATIONAL,/CONTINUE
  RETURN,''
ENDIF
;;  Check if user supplied a file path as well
test           = (N_PARAMS() LT 2) OR (SIZE(fdir,/TYPE) EQ 0)
IF (test[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  User provided routine name, but no file path --> find path
  ;;--------------------------------------------------------------------------------------
  ;;  First check that routine has been compiled [cannot find it unless user supplies the path]
  gposi          = STRPOS(fnm_full[0],'.pro')
  fnm_pref       = STRLOWCASE(STRMID(fnm_full[0],0L,gposi[0]))  ;;  e.g., 'routine_version'
  test           = TOTAL(all_routine_n EQ fnm_pref[0]) EQ 0
  IF (test[0]) THEN BEGIN
    ;;  User provided a name for an uncompiled routine --> will not search blindly for it...
    MESSAGE,badnfor_msg,/INFORMATIONAL,/CONTINUE
    RETURN,''
  ENDIF
  ;;  Routine found --> check associated path
  good           = WHERE(all_routine_n EQ fnm_pref[0],gd)
  test           = (all_routine_p[good[0]] EQ '')
  IF (test[0]) THEN BEGIN
    ;;  User provided a name for an uncompiled routine --> will not search blindly for it...
    MESSAGE,badnfor_msg,/INFORMATIONAL,/CONTINUE
    RETURN,''
  ENDIF
  ;;  Routine and path found --> define full file path
  fdir0          = all_routine_p[good[0]]
  srlen          = STRLEN(fnm_full[0])
  sdlen          = STRLEN(fdir0[0])
  slen           = sdlen[0] - srlen[0]
  fdir           = STRMID(fdir0[0],0L,slen[0])     ;;  get path only (i.e., without routine name)
  RETURN,routine_version(fnm_full[0],fdir[0])
ENDIF
;;----------------------------------------------------------------------------------------
;;  Both provided --> check path format
;;----------------------------------------------------------------------------------------
;test           = (SIZE(fdir,/TYPE) NE 7) OR (SIZE(fdir,/TYPE) EQ 0)
test           = (SIZE(fdir,/TYPE) NE 7) OR (FILE_TEST(fdir,/DIRECTORY) NE 1)
IF (test[0]) THEN BEGIN
  ;;  User supplied a path, but it is not valid or not a string
  ;;    -->  See if routine can find it alone
  test           = (SIZE(fdir,/TYPE) NE 7)
  IF (test[0]) THEN errmsg = baddfor_msg[0] ELSE errmsg = notdir_msg[0]
;  IF (test[0]) THEN errmsg = baddfor_msg[0] ELSE errmsg = 'FDIR'+undeferr_msg[0]
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  vers           = routine_version(fnm_full[0],fdir1)
  test           = (vers[0] NE '')
  IF (test[0]) THEN BEGIN
    fdir = fdir1[0]
    RETURN,vers
  ENDIF ELSE BEGIN
    RETURN,''
  ENDELSE
ENDIF
;;########################################################################################
;;  Define version for output
;;########################################################################################
file       = FILE_SEARCH(fdir[0],fnm_full[0])
IF (file[0] NE '') THEN BEGIN
  fstring  = read_gen_ascii(file[0])
  test     = STRPOS(fstring,';    LAST MODIFIED:  ') GE 0
  gposi    = WHERE(test,gpf)
  shifts   = STRLEN(';    LAST MODIFIED:  ')
  vers     = STRMID(fstring[gposi[0]],shifts[0])
ENDIF ELSE BEGIN
  vers     = '(Not Found)'
ENDELSE
vers0    = fnm_full[0]+' : '+vers[0]+', '
version  = vers0[0]+time_string(SYSTIME(1,/SECONDS),PREC=3)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,version
END

