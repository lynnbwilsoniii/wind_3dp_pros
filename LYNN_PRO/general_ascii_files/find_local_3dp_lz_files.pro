;+
;*****************************************************************************************
;
;  PROCEDURE:   find_local_3dp_lz_files.pro
;  PURPOSE  :   Uses Unix to check whether files exist in the 3DP LZ directory and if so,
;                 return the full file path to those files.
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
;               add_os_slash.pro
;               get_valid_trange.pro
;               general_find_files_from_trange.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               find_3dp_lz_files [,TDATE=tdate] [,TRANGE=trange] [,OUT_FILES=out_files]
;
;  KEYWORDS:    
;               TDATE       :  Scalar [string] defining the date of interest of the form:
;                                'YYYY-MM-DD' [MM=month, DD=day, YYYY=year]
;                                [Default = prompted by get_valid_trange.pro]
;               TRANGE      :  [2]-Element [double] array specifying the Unix time
;                                range for which to limit the data in DATA
;                                [Default = prompted by get_valid_trange.pro]
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               OUT_FILES   :  Set to a named variable to return the full file path
;                                and file names for the desired files
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See also general_find_files_from_trange.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/15/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/15/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO find_local_3dp_lz_files,TDATE=tdate,TRANGE=trange,OUT_FILES=out_files

;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;  Default 3DP LZ file location
def_datloc     = '.'+slash[0]+'wind_3dp_pros'+slash[0]+'wind_data_dir'+slash[0]+$
                 'data1'+slash[0]+'wind'+slash[0]+'3dp'+slash[0]+'lz'+slash[0]
date_form      = 'YYYYMMDD'
test_umn       = test_file_path_format(def_datloc[0],EXISTS=umn_exists,DIR_OUT=dat_dir)
IF (~test_umn[0] OR ~umn_exists[0]) THEN RETURN

def_commands   = ['touch','-a']
fname_pref     = 'wi_lz_3dp_'
fname_format   = fname_pref[0]+date_form[0]+'_v??.dat'
;;----------------------------------------------------------------------------------------
;;  Define 3DP LZ file location
;;----------------------------------------------------------------------------------------
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF ~KEYWORD_SET(exists) THEN BEGIN
  datdir = dat_dir[0]
ENDIF ELSE BEGIN
  datdir = !wind3dp_umn.WIND_DATA1
  IF (datdir[0] EQ '') THEN BEGIN
    datdir  = add_os_slash(FILE_EXPAND_PATH(def_datloc[0]))
  ENDIF ELSE BEGIN
    datdir += '3dp'+slash[0]+'lz'+slash[0]
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check TDATE and TRANGE
test0          = test_tdate_format(tdate,/NOMSSG)
test1          = ((N_ELEMENTS(trange) EQ 2) AND is_a_number(trange,/NOMSSG))
test           = test0[0] OR test1[0]
IF (test[0]) THEN BEGIN
  ;;  At least one is set --> use that one
  IF (test0[0]) THEN time_ra = get_valid_trange(TDATE=tdate) ELSE time_ra = get_valid_trange(TRANGE=trange)
ENDIF ELSE BEGIN
  ;;  Prompt user and ask user for date/times
  time_ra        = get_valid_trange(TDATE=tdate,TRANGE=trange)
ENDELSE
;;  Define dates and time ranges
tra            = time_ra.UNIX_TRANGE
tdates         = time_ra.DATE_TRANGE        ;;  'YYYY-MM-DD'  e.g., '2009-07-13'
tdate          = tdates[0]                  ;;  Redefine TDATE on output
;;  Convert TDATEs to format used by 3DP LZ files [e.g., 'YYYYMMDD']
fdates         = STRMID(tdates,0L,4L)+STRMID(tdates,5L,2L)+STRMID(tdates,8L,2L)
;;----------------------------------------------------------------------------------------
;;  Find 3DP LZ files within time range
;;----------------------------------------------------------------------------------------
files          = general_find_files_from_trange(datdir[0],date_form[0],TRANGE=tra,FILE_PREF=fname_pref[0])
IF (SIZE(files,/TYPE) NE 7) THEN BEGIN
  errmsg = 'No 3DP LZ files found...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF ELSE BEGIN
  IF (files[0] EQ '') THEN BEGIN
    errmsg = 'No 3DP LZ files found...'
    MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
    RETURN
  ENDIF
ENDELSE
good           = WHERE(files NE '',gd)
IF (gd[0] GT 0) THEN out_files = files[good]
;SPAWN,/NOSHELL,/STDERR,EXIT_STATUS=status,commands,output
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END


