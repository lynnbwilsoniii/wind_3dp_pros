;+
;*****************************************************************************************
;
;  FUNCTION :   test_file_path_format.pro
;  PURPOSE  :   This routine tests to make sure an input string or array of strings
;                 have the correct format to be valid file paths.
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
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               PATH       :  Scalar [string] file path whose format is to be tested.
;                               If BASE_DIR is properly set, then PATH is assumed to be
;                               a subdirectory of BASE_DIR.
;
;  EXAMPLES:    
;               [calling sequence]
;               test = test_file_path_format(path [,BASE_DIR=direc0] [,EXISTS=exists] $
;                                            [,DIR_OUT=dir_out]                       )
;
;               ;;****************************************************************
;               ;;  Example Usage
;               ;;****************************************************************
;               ;;  Try valid input
;               DELVAR,test,exists,dir_out,base_dir
;               path           = '/Users/lbwilson/Desktop/swidl-0.1/'
;               test           = test_file_path_format(path,BASE_DIR=base_dir,EXISTS=exists,DIR_OUT=dir_out)
;               PRINT,';;  ',test[0],'  ',exists[0],'  ',dir_out[0]
;               ;;     1     1  /Users/lbwilson/Desktop/swidl-0.1/
;
;               ;;  Try valid, but undefined input
;               DELVAR,test,exists,dir_out
;               path           = '/Users/lbwilson/Desktop/swidl-0.1/temporary/'
;               test           = test_file_path_format(path,BASE_DIR=base_dir,EXISTS=exists,DIR_OUT=dir_out)
;               PRINT,';;  ',test[0],'  ',exists[0],'  ',dir_out[0]
;               ;;     1     0  /Users/lbwilson/Desktop/swidl-0.1/temporary/
;
;               ;;  Try invalid input
;               DELVAR,test,exists,dir_out
;               path           = '/he walks/# to the !/Desktop/swidl-0.1/'
;               test           = test_file_path_format(path,BASE_DIR=base_dir,EXISTS=exists,DIR_OUT=dir_out)
;               PRINT,';;  ',test[0],'  ',exists[0],'  ',dir_out[0]
;               ;;     0     0  
;
;               ;;  Try valid, but "bad" input
;               DELVAR,test,exists,dir_out
;               path           = '$HOME/Desktop/swidl-0.@/'
;               test           = test_file_path_format(path,BASE_DIR=base_dir,EXISTS=exists,DIR_OUT=dir_out)
;               PRINT,';;  ',test[0],'  ',exists[0],'  ',dir_out[0]
;               ;;     1     0  /Users/lbwilson/Desktop/swidl-0.@/
;
;               ;;  Try invalid input
;               DELVAR,test,exists,dir_out
;               path           = '$HOME/Desktop/swidl-0.[#^`%]/'
;               test           = test_file_path_format(path,BASE_DIR=base_dir,EXISTS=exists,DIR_OUT=dir_out)
;               PRINT,';;  ',test[0],'  ',exists[0],'  ',dir_out[0]
;               ;;     0     0  
;
;               ;;  Try invalid input
;               DELVAR,test,exists,dir_out
;               path           = "/I am not good at defining # % good file paths/to/my/data\because\I mix OS's and don't read instructions/"
;               test           = test_file_path_format(path,BASE_DIR=base_dir,EXISTS=exists,DIR_OUT=dir_out)
;               PRINT,';;  ',test[0],'  ',exists[0],'  ',dir_out[0]
;               ;;     0     0  
;
;  KEYWORDS:    
;               BASE_DIR   :  Scalar [string] defining the full path to the directory of
;                               interest.  If set, then the PATH input is treated as
;                               just the directory name located within BASE_DIR.
;                               [Default = FALSE]
;               EXISTS     :  Set to a named variable that defines whether the directory
;                               at the end of the input file path currently exists
;               DIR_OUT    :  Set to a named variable to return a properly formatted
;                               version of PATH that has the expected file path format
;                               and is fully expanded
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/24/2017   v1.0.0]
;             2)  Finished writing and cleaned up
;                                                                   [05/24/2017   v1.0.0]
;
;   NOTES:      
;               1)  There are situations where FILE_MKDIR.PRO works but some of the
;                     IDL built-in search routines cannot find the directory.  In these
;                     cases, I use the output of FILE_SEARCH.PRO to determine if IDL
;                     would even be able to find the directory if it were created.  If
;                     not, then the routine outputs FALSE.
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM:  valid_dirname.pro by Dominic Zarro [Part of the SolarSoft Library]
;   CREATED:  05/22/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/24/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION test_file_path_format,path,BASE_DIR=direc0,EXISTS=exists,DIR_OUT=dir_out

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Initialize outputs
dir_out        = ''
value_out      = 0b
exists         = 0b
base_dir       = ''
;;  Define OS- and IDL-dependent version variables
ver_os         = !VERSION.OS                           ;;  'linux' or 'darwin' or 'Win32' or 'sunos' or 'vms' or 'hp-ux' or 'IRIX' or 'AIX' or 'ultrix' or 'DG/UX'
verosn         = !VERSION.OS_NAME                      ;;  'Mac OS X' ('MacOS' pre-2001) or 'linux' or 'Microsoft Windows' or 'Solaris'
ver_ar         = !VERSION.ARCH                         ;;  'sparc' or 'i386' or 'x86' or 'x86_64' or 'vax' or 'alpha' or 'mipsel'
vers           = !VERSION.OS_FAMILY                    ;;  'unix' or 'Windows'
vern           = !VERSION.RELEASE                      ;;  e.g., '7.1.1'
slash          = get_os_slash()                        ;;  '/' for Unix-like, '\' for Windows
windows        = (STRLOWCASE(vers[0]) EQ 'windows')    ;;  logic test for Windows-like OS
unix           = (STRLOWCASE(vers[0]) EQ 'unix')       ;;  logic test for Unix-like OS
;;  Define the current working directory character
;;    e.g., './' [for unix and linux] otherwise guess './' or '.\'
test           = (vern[0] GE '6.0')
IF (test[0]) THEN cwd_char0 = FILE_DIRNAME('',/MARK_DIRECTORY) ELSE cwd_char0 = '.'+slash[0]
;;  Expand to a fully qualified path
cwd_char       = FILE_SEARCH(cwd_char0[0],/FULLY_QUALIFY_PATH,/MARK_DIRECTORY)
;;  Dummy error messages
notstr_msg     = 'User must input PATH as a scalar [string]...'
badtyp_msg     = 'PATH must be of string type...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check for an input
test           = (N_ELEMENTS(path) EQ 0) OR (N_PARAMS() NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,value_out[0]
ENDIF
;;  Check input type
str            = path[0]
test           = (SIZE(str,/TYPE) NE 7)
IF (test[0]) THEN BEGIN
  MESSAGE,badtyp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,value_out[0]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Setup error handling
;;----------------------------------------------------------------------------------------
error          = 0
CATCH, error
IF (error[0] NE 0) THEN BEGIN
 CATCH,/CANCEL
 RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check BASE_DIR
test           = (N_ELEMENTS(direc0) GT 0) AND (SIZE(direc0,/TYPE) EQ 7)
IF (test[0]) THEN BEGIN
  test           = FILE_TEST(direc0[0],/DIRECTORY)
  IF (test[0]) THEN BEGIN
    base_dir = (FILE_SEARCH(direc0[0],/FULLY_QUALIFY_PATH,/MARK_DIRECTORY))[0]
  ENDIF
ENDIF
;;  If BASE_DIR set --> add PATH onto it
test           = (base_dir[0] NE '')
IF (test[0]) THEN BEGIN
  ;;  Check for a leading file path separator
  test           = (STRMID(path[0],0,1) EQ slash[0])
  IF (test[0]) THEN dir0 = STRMID(path[0],1) ELSE dir0 = path[0]      ;;  Could be an issue for \\host\share\... directories on Windows machines
  dirname        = add_os_slash(base_dir[0]+dir0[0])
ENDIF ELSE BEGIN
  dirname        = add_os_slash(path[0])
  ;;  Check for a base directory
  base_dir       = FILE_DIRNAME(dirname[0],/MARK_DIRECTORY)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check if PATH currently exists
;;----------------------------------------------------------------------------------------
test0          = FILE_TEST(dirname[0],/DIRECTORY)
test1          = ((FILE_SEARCH(dirname[0],/FULLY_QUALIFY_PATH,/TEST_DIRECTORY))[0] NE '')
test           = test0[0] AND test1[0]
IF (test[0]) THEN exists = 1b ELSE exists = 0b
IF (exists[0]) THEN BEGIN
  dir_out        = (FILE_SEARCH(dirname[0],/FULLY_QUALIFY_PATH,/MARK_DIRECTORY))[0]
  RETURN,1b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check for environment or system variables (e.g., '$' or '.')
;;----------------------------------------------------------------------------------------
gpos_d         = STRPOS(base_dir[0],'$')
gpos_p         = STRPOS(base_dir[0],'.')
test           = (gpos_d[0] GE 0) OR (gpos_p[0] GE 0)
IF (test[0]) THEN BEGIN
  basedir = (FILE_SEARCH(base_dir[0],/FULLY_QUALIFY_PATH,/MARK_DIRECTORY))[0]
ENDIF ELSE basedir = add_os_slash(base_dir[0])
;;  Get the subdirectory name
sub_dir        = FILE_BASENAME(dirname[0])
;;  Define the output
dirname        = add_os_slash(basedir[0]+sub_dir[0])
;;----------------------------------------------------------------------------------------
;;  Create dummy directory to determine if name is valid
;;----------------------------------------------------------------------------------------
;;  Note:  If directory already exists, nothing to do here bc it's already valid (see above)
;;           Assume paths have already been expanded
FILE_MKDIR,dirname[0],/NOEXPAND_PATH  ;;  Go to CATCH if fails
;;  Define output keyword
dir_out        = (FILE_SEARCH(dirname[0],/FULLY_QUALIFY_PATH,/MARK_DIRECTORY))[0]
;;  If still alive --> Clean up by removing dummy directory
FILE_DELETE,dirname[0],/ALLOW_NONEXISTENT,/NOEXPAND_PATH,/QUIET
;;----------------------------------------------------------------------------------------
;;  Check in case FILE_MKDIR.PRO worked but should not have
;;----------------------------------------------------------------------------------------
;;  Define output
value_out      = (dir_out[0] NE '')
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,value_out[0]
END
