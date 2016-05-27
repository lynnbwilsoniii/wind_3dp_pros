;+
;*****************************************************************************************
;
;  FUNCTION :   setfileenv.pro
;  PURPOSE  :   Sets up environment variables giving information on the location
;                 of master index files and file paths of WIND 3DP data.
;
;  CALLED BY:   
;               init_wind_lib.pro
;
;  CALLS:
;               get_os_slash.pro
;               wind_3dp_umn_init.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  P. Schroeder changed something...
;                                                                  [09/25/2003   v1.0.26]
;             2)  Changed path locations
;                                                                  [01/08/2008   v1.1.0]
;             3)  Updated man page and added error handling for multiple OS's and
;                   computer systems
;                                                                  [08/05/2010   v1.2.0]
;             4)  Updated file paths for other data quantities
;                                                                  [06/08/2011   v1.2.1]
;             5)  Updated file paths for House Keeping quantities and removed
;                   unnecessary environment variables
;                                                                  [06/17/2011   v1.2.2]
;             6)  Changed path locations, fixed a few typos, and updated to match
;                   new directory tree structure for data and now calls get_os_slash.pro
;                                                                  [08/07/2013   v1.3.0]
;             7)  Cleaned up and rewrote, now taking into account that the level zero
;                   data is located in the ~/wind_3dp_pros/wind_data_dir/data1/...
;                   directory and now calls wind_3dp_umn_init.pro instead of
;                   umn_default_env.pro
;                                                                  [08/08/2013   v2.0.0]
;             8)  Added 'h1' as a data type option for the SWE instrument
;                                                                  [01/24/2014   v2.0.1]
;
;   NOTES:      
;               1)  Users may have to change certain file paths accordingly for their
;                     own machines
;               2)  If done correctly, users will not need masterfile lists as this
;                     routine will create an environment variable that is used by
;                     loadallcdf.pro or other CDF file loading routines.  The files
;                     are found by cdf_file_names.pro, which is why the environment
;                     variables below use '*' in their definitions.
;               3)  Check paths are correct with:
;                     HELP,OUTPUT=oo,/SOURCE_FILES
;                     PRINT, TRANSPOSE(oo)
;
;   CREATED:  ??/??/????
;   CREATED BY:  Peter Schroeder
;    LAST MODIFIED:  01/24/2014   v2.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO setfileenv

;;----------------------------------------------------------------------------------------
;;  Define system variable parameters
;;----------------------------------------------------------------------------------------
vers           = !VERSION
mdir           = FILE_EXPAND_PATH('')
slash          = get_os_slash()         ;;  '/' for Unix, '\' for Windows
;;  Check for trailing '/' or '\'
ll             = STRMID(mdir, STRLEN(mdir) - 1L,1L)
test_ll        = (ll[0] NE slash[0])
IF (test_ll) THEN mdir = mdir[0]+slash[0]
;;----------------------------------------------------------------------------------------
;;  Setup environment variables
;;----------------------------------------------------------------------------------------
defdir         = ''    ;;  Default data directory
def3dp         = ''    ;;  Default 3DP data directory
defswe         = ''    ;;  Default 3DP data directory
mfidir1        = ''    ;;  Location of MFI CDF files
phwrite        = ''    ;;  Place to write PH stuff to ???
wind_so        = ''    ;;  Location of shared object libraries
basedir        = ''    ;;  Location of the 3DP lz files

defdir         = slash[0]+'data1'+slash[0]+'wind'+slash[0]  ;;  e.g., '/data1/wind/
def3dp         = defdir[0]+'3dp'+slash[0]                   ;;  e.g., '/data1/wind/3dp/'
defswe         = defdir[0]+'swe'+slash[0]                   ;;  e.g., '/data1/wind/swe/'
;;  Define environment variable to be checked later to avoid multiple calls to this routine
SETENV,'FILE_ENV_SET=1'

DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF NOT KEYWORD_SET(exists) THEN BEGIN
  wind_3dp_umn_init
ENDIF
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;  Note to users:  You may need to change the Dir. location for the
;;                      Wind MFI CDF files.
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;  Define locations of relevant data
mfidir1        = !wind3dp_umn.WIND_MFI_CDF_DIR[0]
phwrite        = !wind3dp_umn.IDL_3DP_LIB_DIR[0]+'ARJUN_PRO'
wind_so        = !wind3dp_umn.IDL_3DP_LIB_DIR[0]+'WIND_PRO'  ;;  location of shared object libraries
;;  Define location to Wind CDF files
defdir         = !wind3dp_umn.WIND_DATA1[0]     ;;  e.g., '~/wind_3dp_pros/wind_data_dir/data1/wind/'
def3dp         = defdir[0]+'3dp'+slash[0]                   ;;  e.g., '/data1/wind/3dp/'
defswe         = defdir[0]+'swe'+slash[0]                   ;;  e.g., '/data1/wind/swe/'
basedir        = def3dp[0]+'lz'
;;  Check to see if base directory is set
IF NOT KEYWORD_SET(basedir) THEN BEGIN
  basedir = slash[0]+'data1'+slash[0]+'wind'+slash[0]+'3dp'+slash[0]+'lz'
  MESSAGE,/INFO,'Warning! Environment variable "BASE_DATA_DIR" is not set!;'
  MESSAGE,/INFO,'Using default value: "'+basedir+'"'
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define environment variables
;;----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(GETENV('WIND_DATA_DIR')) THEN BEGIN
  SETENV,'WIND_DATA_DIR='+basedir[0]
ENDIF

;;  I/O-Related environment variables
SETENV,'PH_DIR_WRITE='        +phwrite
SETENV,'IDL_3DP_LIB_DIR='     +wind_so

;;  SWE-Related environment variables
SETENV,'WI_K0_SWE_FILES='     +defswe[0]+'k0'+slash[0]+'????'+slash[0]+'wi_k0_swe*.cdf'
SETENV,'WI_SWE_K0_FILES='     +defswe[0]+'k0'+slash[0]+'????'+slash[0]+'wi_k0_swe*.cdf'
SETENV,'WI_SWE_K0_B_FILES='   +defswe[0]+'k0'+slash[0]+'bartel'+slash[0]+'wi_swe_k0*.cdf'
SETENV,'WI_H1_SWE_FILES='     +defswe[0]+'h1'+slash[0]+'????'+slash[0]+'wi_h1_swe*.cdf'

;;  MFI-Related environment variables
SETENV,'WI_K0_MFI_FILES='     +mfidir1[0]+'wi_k0_mfi*.cdf'
SETENV,'WI_K0_MFI_B_FILES='   +mfidir1[0]+'wi_*.cdf'
SETENV,'WI_SP_MFI_FILES='     +mfidir1[0]+'wi_sp_mfi*.cdf'
SETENV,'WI_H0_MFI_FILES='     +mfidir1[0]+'wi_h0_mfi*.cdf'
SETENV,'WI_H0_MFI_INDEX='     +mfidir1[0]
SETENV,'WI_H0_MFI_V3_FILES='  +mfidir1[0]+'wi_h0_mfi*.cdf'

;;  LZ 3DP environment variables
SETENV,'WI_LZ_3DP_FILES='     +def3dp[0]+  'lz'+slash[0]+'????'+slash[0]+'wi_lz_3dp_*.dat'
SETENV,'WI_3DP_LZ_FILES='     +def3dp[0]+  'lz'+slash[0]+'????'+slash[0]+'wi_lz_3dp_*.dat'
;;  Other 3DP-related environment variables
SETENV,'WI_K0_3DP_FILES='     +def3dp[0]+  'k0'+slash[0]+'????'+slash[0]+'wi_k0_3dp*.cdf'
SETENV,'WI_3DP_K0_FILES='     +def3dp[0]+  'k0'+slash[0]+'????'+slash[0]+'wi_k0_3dp*.cdf'
SETENV,'WI_HKP_3DP_FILES='    +def3dp[0]+ 'hkp'+slash[0]+'????'+slash[0]+'wi_hkp_3dp*'
SETENV,'WI_3DP_PLSP_FILES='   +def3dp[0]+'plsp'+slash[0]+'????'+slash[0]+'wi_plsp_3dp*.cdf'
SETENV,'WI_PLSP_3DP_FILES='   +def3dp[0]+'plsp'+slash[0]+'????'+slash[0]+'wi_plsp_3dp*.cdf'
SETENV,'WI_3DP_ELSP_FILES='   +def3dp[0]+'elsp'+slash[0]+'????'+slash[0]+'wi_elsp_3dp*.cdf'
SETENV,'WI_ELSP_3DP_FILES='   +def3dp[0]+'elsp'+slash[0]+'????'+slash[0]+'wi_elsp_3dp*.cdf'
SETENV,'WI_3DP_PLSP_B_FILES=' +def3dp[0]+'plsp'+slash[0]+'bartel'+slash[0]+'wi_3dp_plsp_B*.cdf'
SETENV,'WI_3DP_ELSP_B_FILES=' +def3dp[0]+'elsp'+slash[0]+'bartel'+slash[0]+'wi_3dp_elsp_B*.cdf'
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
