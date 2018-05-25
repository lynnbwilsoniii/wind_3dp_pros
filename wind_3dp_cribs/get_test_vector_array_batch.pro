;+
;*****************************************************************************************
;
;  BATCH    :   get_test_vector_array_batch.pro
;  PURPOSE  :   This is a batch routine meant to restore an IDL save file created solely
;                 for the purpose of testing 3-vector array routines.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               test_file_path_format.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  The IDL save file test_vector_array.sav
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               @[path to IDL libraries]/wind_3dp_pros/wind_3dp_cribs/get_test_vector_array_batch.pro
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The two arrays in the file test_vector_array.sav are VEC1 and VEC2,
;                     which were created from the VSW and MAGF tags in the EESA Low
;                     Burst IDL structures for the date 1995-08-22 (Aug. 22, 1995).
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/23/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/23/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;----------------------------------------------------------------------------------------
;;  IDL system and OS stuff
;;----------------------------------------------------------------------------------------
vers           = !VERSION.OS_FAMILY   ;;  e.g., 'unix'
vern           = !VERSION.RELEASE     ;;  e.g., '7.1.1'
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
dumbv          = REPLICATE(f,1,3)
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
;;  Default 3DP LZ file location
def_datloc     = '.'+slash[0]+'wind_3dp_pros'+slash[0]+'wind_3dp_cribs'+slash[0]
;;  Define location where files will be written
test_umn       = test_file_path_format(def_datloc[0],EXISTS=umn_exists,DIR_OUT=localdir)
IF (~test_umn[0] OR ~umn_exists[0]) THEN vec1 = dumbv
IF (~test_umn[0] OR ~umn_exists[0]) THEN vec2 = dumbv
IF (~test_umn[0] OR ~umn_exists[0]) THEN STOP
;;----------------------------------------------------------------------------------------
;;  Find and restore file
;;----------------------------------------------------------------------------------------
;;  Define file name
fname          = 'test_vector_array.sav'
;;  Find file
gfile          = FILE_SEARCH(localdir[0]+fname[0])
IF (gfile[0] EQ '') THEN vec1 = dumbv
IF (gfile[0] EQ '') THEN vec2 = dumbv
IF (gfile[0] EQ '') THEN STOP
RESTORE,FILENAME=gfile[0],/VERBOSE

