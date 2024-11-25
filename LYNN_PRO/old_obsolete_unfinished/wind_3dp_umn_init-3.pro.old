;+
;*****************************************************************************************
;
;  FUNCTION :   umn_default_env.pro
;  PURPOSE  :   Sets up the default structure of the new system variable, !WIND3DP_UMN.
;
;  CALLED BY:   
;               wind_3dp_umn_init.pro
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
;               structure_format = umn_default_env()
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Changed output structure format
;                                                                 [09/24/2009   v1.1.0]
;             2)  Added HTR MFI directory to structure format
;                                                                 [11/23/2011   v1.2.0]
;             3)  Added WAVES radio receiver directory to structure format
;                                                                 [03/21/2013   v1.3.0]
;             4)  Added /data1/... directory to structure format, which contains
;                   level zero and other data types for 3DP
;                                                                 [08/08/2013   v1.4.0]
;
;   NOTES:      
;               NA
;
;   CREATED:  09/16/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/08/2013   v1.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION umn_default_env

;;----------------------------------------------------------------------------------------
;;  Define structure
;;----------------------------------------------------------------------------------------
tags           = ['ASCII_FILE_DIR','WIND_MFI_CDF_DIR','WIND_HTR_MFI_CDF_DIR',$
                  'WIND_3DP_SAVE_FILE_DIR','WIND_DATA_DIR','WIND_ORBIT_DIR',$
                  'IDL_3DP_LIB_DIR','WIND_WAVES_DIR','WIND_DATA1']
ascii_files    = GETENV(tags[0])
mag_files      = GETENV(tags[1])
htr_files      = GETENV(tags[2])
wind_base      = GETENV(tags[3])
base_data      = GETENV(tags[4])
idl_3dp_path   = GETENV(tags[5])
waves_files    = GETENV(tags[6])
str            = CREATE_STRUCT(tags,ascii_files,mag_files,htr_files,'',wind_base, $
                               base_data,idl_3dp_path,waves_files,'',             $
                               NAME='retrieve_struct')
;;----------------------------------------------------------------------------------------
;;  Return structure
;;----------------------------------------------------------------------------------------

RETURN, str
END

;+
;*****************************************************************************************
;
;  PROCEDURE:   wind_3dp_umn_init.pro
;  PURPOSE  :   Called by start_umn_3dp.pro and intializes a new system
;                 variable, !WIND3DP_UMN, for later use with directory calls.
;
;  CALLED BY:   
;               start_umn_3dp.pro
;
;  CALLS:
;               umn_default_env.pro
;               get_os_slash.pro
;
;  REQUIRES:    
;               UMN Edited 3DP Libraries
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
;   CHANGED:  1)  Changed start_umn_3dp.pro compile list           
;                                                                 [09/17/2009   v1.0.1]
;             2)  Changed output system variable format            
;                                                                 [09/24/2009   v1.1.0]
;             3)  Fixed a typo in WIND_ORBIT_DIR definition        
;                                                                 [11/12/2009   v1.1.1]
;             4)  Added HTR MFI directory to structure format      
;                                                                 [11/23/2011   v1.2.0]
;             5)  Fixed usage of slashes [e.g. '/' vs '\']         
;                                                                 [08/23/2012   v1.3.0]
;             6)  Added WAVES radio receiver directory to structure format
;                   and now calls get_os_slash.pro
;                                                                 [03/21/2013   v1.4.0]
;             7)  Added /data1/... directory to structure format, which contains
;                   level zero and other data types for 3DP
;                                                                 [08/08/2013   v1.5.0]
;
;   NOTES:      
;               1)  This program should be called at startup by start_umn_3dp.pro
;
;   CREATED:  09/16/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/08/2013   v1.5.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO wind_3dp_umn_init

;;----------------------------------------------------------------------------------------
;;  Get/Set default IDL_PATHs and data directories
;;----------------------------------------------------------------------------------------
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF NOT KEYWORD_SET(exists) THEN BEGIN
  structure = umn_default_env()
  DEFSYSV,'!wind3dp_umn',structure
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define system variable parameters
;;----------------------------------------------------------------------------------------
mdir           = FILE_EXPAND_PATH('')
slash          = get_os_slash()
;;  Check for trailing '/'
vers           = !VERSION.OS_FAMILY
ll             = STRMID(mdir, STRLEN(mdir) - 1L,1L)
test_ll        = (ll[0] EQ '/') OR (ll[0] EQ '\')
IF (test_ll) THEN BEGIN
  mdir  = mdir[0]
ENDIF ELSE BEGIN
  mdir  = mdir[0]+slash[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define/Alter system variable
;;----------------------------------------------------------------------------------------
base_ext       = ''      ;;  Base directory extension of file path
data_ext       = ''      ;;  Base data directory extension of file path
idls_ext       = ''      ;;  IDL save file location, if necessary

base_ext       = 'wind_3dp_pros'+slash[0]
data_ext       = base_ext[0]+'wind_data_dir'+slash[0]
idls_ext       = data_ext[0]+'Wind_3DP_DATA'+slash[0]+'IDL_Save_Files'+slash[0]
base_dir       = mdir[0]+base_ext[0]
data_dir       = mdir[0]+data_ext[0]
;;  Define location of 3DP software
!wind3dp_umn.IDL_3DP_LIB_DIR        = base_dir[0]
;;  Define location of MFI data
!wind3dp_umn.WIND_MFI_CDF_DIR       = data_dir[0]+'MFI_CDF'+slash[0]
!wind3dp_umn.WIND_HTR_MFI_CDF_DIR   = data_dir[0]+'HTR_MFI_CDF'+slash[0]
;;  Define base location of Wind data
!wind3dp_umn.WIND_DATA_DIR          = data_dir[0]
;;  Define location of Wind orbit data
!wind3dp_umn.WIND_ORBIT_DIR         = data_dir[0]+'Wind_Orbit_Data'+slash[0]
;;  Define location of J.C. Kasper's Rankine-Hugoniot database results
!wind3dp_umn.ASCII_FILE_DIR         = data_dir[0]+'JCK_Data-Base'+slash[0]
;;  Define location of Wind 3DP IDL save file data
!wind3dp_umn.WIND_3DP_SAVE_FILE_DIR = mdir[0]+idls_ext[0]
;;  Define location of Wind WAVES radio data
!wind3dp_umn.WIND_WAVES_DIR         = data_dir[0]+'Wind_WAVES_Data'+slash[0]
;;  Define location of Wind 3DP level zero (lz) data
!wind3dp_umn.WIND_DATA1             = data_dir[0]+'data1'+slash[0]+'wind'+slash[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
