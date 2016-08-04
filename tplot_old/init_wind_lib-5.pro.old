;+
;*****************************************************************************************
;
;  PROCEDURE:   init_wind_lib.pro
;  PURPOSE  :   Initializes common block variables for the WIND 3DP library.  There is
;                 no reason for the typical user to execute this routine as it is
;                 automatically called from "LOAD_3DP_DATA".  However it can be used to
;                 overide the default directories and/or libraries.
;
;  CALLED BY:   
;               load_3dp_data.pro
;
;  CALLS:
;               get_os_slash.pro
;               setfileenv.pro
;               wind_com.pro
;               wind_3dp_umn_init.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  WindLib Libraries and the following shared objects:
;                     wind_lib.so
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               WLIB      :  Scalar string specifying the full pathname of the shared 
;                              object code for wind data extraction library.   
;                              [Default = $IDL_3DP_DIR/lib/wind_lib.so]
;               MASTFILE  :  Scalar string specifying the full pathname of the
;                              3DP master data file.
;                              [Default = $WIND_DATA_DIR/wi_lz_3dp_files]
;
;   CHANGED:  1)  Davin Larson changed something...
;                                                                   [04/18/2002   v1.0.12]
;             2)  Updated man page
;                                                                   [08/05/2009   v1.1.0]
;             3)  Fixed minor syntax error
;                                                                   [08/26/2009   v1.1.1]
;             4)  Updated man page, added shared object library and added error handling
;                                                                   [08/05/2010   v1.2.0]
;             5)  Changed hard coded default shared object library location
;                                                                   [07/25/2011   v1.2.1]
;             6)  Added multiple shared object libraries for different operating systems
;                                                                   [09/07/2011   v1.3.0]
;             7)  Added error handling to allow for PowerPC (on Mac OS X) and other
;                   architectures to incorporate new shared object libraries
;                                                                   [08/05/2013   v1.3.1]
;             8)  Cleaned up and now calls wind_3dp_umn_init.pro instead of
;                   umn_default_env.pro and added some extra error handling
;                                                                   [08/08/2013   v1.3.2]
;             9)  Now includes a 64-bit compiled shared object library for darwin
;                   OS and x86_64 architecture (Mac OS X)
;                                                                   [09/30/2015   v1.4.0]
;
;   NOTES:
;               Please see help_3dp.html for information on creating the master file
;                 for 3DP level zero data allocation.
;
;RESTRICTIONS:
;               This procedure is operating system dependent!  (UNIX ONLY)
;               This procedure expects to find two environment variables:
;                 1)  WIND_DATA_DIR : The directory containing the master 
;                                       file: 'wi_lz_3dp_files'
;                 2)  IDL_3DP_DIR   : The directory containing the source code and 
;                                       the sub-directory/file:  lib/wind_lib.so
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/30/2015   v1.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO init_wind_lib,WLIB=wlib,MASTFILE=mastfile

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
slash          = get_os_slash()
;;  Define strings identifying the possible shared object libraries
;mac_sofs       = ['wind3dp_lib_darwin_ppc.so','wind3dp_lib_darwin_i386.so']
mac_sofs       = ['wind3dp_lib_darwin_ppc.so','wind3dp_lib_darwin_i386.so','wind3dp_lib_darwin_x86_64.so']
sun_sofs       = ['wind3dp_lib_sunos_sparc.so']
unx_sofs       = ['wind3dp_lib_ss32.so','wind3dp_lib_ls32.so']
lnx_sofs       = ['wind3dp_lib_linux_x86.so','wind3dp_lib_linux_x86_64.so']
;;  Define default data directories
defdir         = slash[0]+'data1'+slash[0]+'wind'+slash[0]  ;;  e.g., '/data1/wind/
def3dp         = defdir[0]+'3dp'+slash[0]                   ;;  e.g., '/data1/wind/3dp/'
;;----------------------------------------------------------------------------------------
;;  Load common blocks and initialize LZ file locations
;;----------------------------------------------------------------------------------------
setfileenv
@wind_com.pro
;;----------------------------------------------------------------------------------------
;;  Check input parameters
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(wlib) NE 0) THEN wind_lib = wlib
IF KEYWORD_SET(mastfile) THEN lz_3dp_files = mastfile

test           = (N_ELEMENTS(data_directory) EQ 0)
IF (test) THEN BEGIN
  data_directory = GETENV('WIND_DATA_DIR')
  test           = (N_ELEMENTS(data_directory) EQ 0) OR (SIZE(data_directory,/TYPE) NE 7)
  IF (test) THEN BEGIN
    ;;  Not defined => Use default
    data_directory = def3dp[0]+'lz'+slash[0]  ;;  e.g., '/data1/wind/3dp/lz/'
    errmssg        = 'Environment Variable WIND_DATA_DIR not found!'
    warning        = '**WARNING**  Using default directory:  '+data_directory[0]
    MESSAGE,errmssg[0],/INFORMATIONAL,/CONTINUE
    MESSAGE,warning[0],/INFORMATIONAL,/CONTINUE
  ENDIF ELSE BEGIN
    ;;  Defined as a variable type, but is it useable?
    test_ll        = (data_directory[0] NE '')
    IF (test_ll) THEN BEGIN
      ;;  Check for trailing '/'
      ll             = STRMID(data_directory,STRLEN(data_directory) - 1L,1L)
      test_ll        = (ll[0] NE slash[0])
      IF (test_ll) THEN data_directory = data_directory[0]+slash[0]
    ENDIF ELSE BEGIN
      MESSAGE,'Environment Variable WIND_DATA_DIR not found!',/INFORMATIONAL,/CONTINUE
    ENDELSE
  ENDELSE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define master file location
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(lz_3dp_files) EQ 0) AND (N_ELEMENTS(data_directory) NE 0)
IF (test) THEN BEGIN
  ;;  Define the location of the master file list
  lz_3dp_files = data_directory[0]+'wi_lz_3dp_files'
ENDIF

test           = (N_ELEMENTS(project_name) EQ 0)
IF (test) THEN BEGIN
  project_name = 'Wind 3D Plasma'
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check to make sure we're running IDL in 32 bit mode
;;----------------------------------------------------------------------------------------
osname  = STRLOWCASE(!VERSION.OS_NAME)    ;;  e.g., 'Mac OS X'
osfam   = STRLOWCASE(!VERSION.OS_FAMILY)  ;;  e.g., 'unix'
arch    = STRLOWCASE(!VERSION.ARCH)       ;;  e.g., 'i386'
mbits   = !VERSION.MEMORY_BITS[0]         ;;  e.g., 32
vrel    = !VERSION.RELEASE                ;;  e.g., '7.1.1'
IF (vrel[0] GE '5.4') THEN BEGIN
  test  = (mbits[0] NE 32) AND (osname[0] NE 'linux')
  IF (test) THEN BEGIN
    wind_lib = 0
    errmssg  = 'Only 32 bit WIND/3DP library available at this time for your OS!'
    MESSAGE,errmssg[0],/INFORMATIONAL,/CONTINUE
    MESSAGE,'Start IDL using: idl -32'
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Initialize file locations
;;----------------------------------------------------------------------------------------
wind_lib_dir   = GETENV('IDL_3DP_LIB_DIR')
test           = (N_ELEMENTS(wind_lib_dir) EQ 0) OR (SIZE(wind_lib_dir,/TYPE) NE 7)
IF (test) THEN BEGIN
  ;;  Variable is not defined somehow
  DEFSYSV,'!wind3dp_umn',EXISTS=exists
  IF NOT KEYWORD_SET(exists) THEN wind_3dp_umn_init
  ;;  Define location of shared object libraries
  wind_lib_dir = !wind3dp_umn.IDL_3DP_LIB_DIR[0]+'WIND_PRO'
ENDIF ELSE BEGIN
  test           = (wind_lib_dir[0] EQ '')
  IF (test) THEN BEGIN
    DEFSYSV,'!wind3dp_umn',EXISTS=exists
    IF NOT KEYWORD_SET(exists) THEN wind_3dp_umn_init
    ;;  Define location of shared object libraries
    wind_lib_dir = !wind3dp_umn.IDL_3DP_LIB_DIR[0]+'WIND_PRO'
  ENDIF
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define shared object library to use
;;----------------------------------------------------------------------------------------
CASE osname[0] OF
  'solaris'  : libname = sun_sofs[0]  ;;  Sun Machine
  'linux'    : BEGIN                  ;;  Linux Machine
    IF (mbits[0] GT 32) THEN BEGIN
      ;;  Use 64-bit shared object libraries
      libname = lnx_sofs[1]
    ENDIF ELSE BEGIN
      ;;  Use 32-bit shared object libraries
      libname = lnx_sofs[0]
    ENDELSE
  END
  'mac os x' : BEGIN                  ;;  Mac OS X Machine
    CASE arch[0] OF
      'i386'    :  libname = mac_sofs[1]
      'x86_64'  :  libname = mac_sofs[2]
      ELSE      :  libname = mac_sofs[0]
    ENDCASE
;    IF (arch[0] EQ 'i386') THEN libname = mac_sofs[1] ELSE libname = mac_sofs[0]
  END
  ELSE       : BEGIN                  ;;  Unix Machine
    IF (vrel[0] GE '5.5') THEN BEGIN
      libname = unx_sofs[1]
    ENDIF ELSE BEGIN
      libname = unx_sofs[0]
    ENDELSE
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Check file location
;;----------------------------------------------------------------------------------------
IF (SIZE(wind_lib,/TYPE) NE 7) THEN BEGIN
  wind_lib = wind_lib_dir[0]+slash[0]+libname[0]
  IF (vrel[0] GE '5.4') THEN BEGIN
    IF (FILE_TEST(wind_lib) EQ 0) THEN BEGIN
      MESSAGE,'WIND3DP Library: "'+wind_lib+'" Not found!',/INFORMATIONAL,/CONTINUE
      wind_lib = 0
      RETURN
    ENDIF
  ENDIF
ENDIF
;;  Inform user what shared object is being used
MESSAGE,'Using wind library code at: '+wind_lib,/INFORMATIONAL,/CONTINUE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END


