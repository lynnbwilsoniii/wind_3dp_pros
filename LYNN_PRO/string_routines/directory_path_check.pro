;+
;*****************************************************************************************
;
;  FUNCTION :   directory_path_check.pro
;  PURPOSE  :   This is a simple wrapping routine with error handling used to evaluate
;                 a directory path.
;
;  CALLED BY:   
;               wind_3dp_save_file_get.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               DIREC     :  Scalar string defining the full path to the directory
;                              user wishes to check/verify
;
;  EXAMPLES:    
;               mdir = FILE_EXPAND_PATH('')  ; => Default IDL working directory
;               test = directory_path_check(mdir[0])
;
;  KEYWORDS:    
;               BASE_DIR  :  Scalar string defining the full path to the directory of
;                              interest
;               SUB_DIR   :  Scalar string defining the the subdirectory user wishes
;                              to focus on
;                           [format matches that of SUBDIRECTORY keyword in FILEPATH.PRO]
;               GET_NEW   :  If set, program will let user define new file path
;                              to desired directory IF the input directory is
;                              determined to be invalid
;
;   CHANGED:  1)  Fixed an issue that occurs if one enters a full file path with
;                   the SUB_DIR keyword instead of just the subdirectory name
;                                                                  [04/22/2011   v1.0.1]
;             2)  Attempted to deal with issue occurring when SUB_DIR is only the 
;                   directory name without a file path             [06/12/2011   v1.0.2]
;
;   NOTES:      
;               1)  When using the SUB_DIR keyword, one need only add the extra path
;                     to that specific directory from the directory defined by the
;                     BASE_DIR keyword
;
;   CREATED:  03/25/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/12/2011   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION directory_path_check,BASE_DIR=direc0,SUB_DIR=sub_dir,GET_NEW=getn

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
vers        = !VERSION.OS_FAMILY
IF (vers NE 'unix') THEN slash = '\' ELSE slash = '/'


badinp_mssg       = 'Input type must be string [DIREC]!'
baddir_mssg       = ' is not a valid directory!'
pick_mssg         = 'Move to the desired directory and then click open or okay'
default           = FILE_EXPAND_PATH('')  ; => Default IDL working directory
default           = default[0]+slash[0]   ; => add trailing slash
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(direc0) THEN BEGIN
  good_base = (FILE_TEST(direc0[0],/DIRECTORY) EQ 1)
ENDIF ELSE BEGIN
  good_base = 0
ENDELSE
IF KEYWORD_SET(sub_dir) THEN BEGIN
  ; => check to see if sub_dir is just the directory name or a path to the directory
  gposi     = STRPOS(sub_dir[0],slash[0])
  IF (sub_dir[0] NE '' AND gposi[0] GE 0) THEN BEGIN
    ; => sub_dir appears to have a path associated with it
    good_subd = (FILE_TEST(sub_dir[0],/DIRECTORY) EQ 1)
  ENDIF ELSE BEGIN
    ; => trust the user [I know, dangerous...]
    good_subd = 1
  ENDELSE
ENDIF ELSE BEGIN
  good_subd = 0
ENDELSE
good = WHERE([good_base,good_subd],gd)

IF (gd EQ 0) THEN BEGIN
  ; => Neither BASE_DIR nor SUB_DIR were fully qualified paths
  ttl   = pick_mssg
  IF KEYWORD_SET(getn) THEN BEGIN
    test0 = DIALOG_PICKFILE(PATH=default[0],GET_PATH=base_dir,/DIRECTORY,TITLE=pick_mssg)
    RETURN,base_dir[0]
  ENDIF ELSE RETURN,default[0]
ENDIF ELSE BEGIN
  CASE gd OF
    1 : BEGIN
      ; => Only one of the BASE_DIR or SUB_DIR keywords were set correctly
      IF (good[0] EQ 0) THEN BEGIN
        ; => BASE_DIR keyword was set correctly
        base_dir = FILEPATH('',ROOT_DIR=direc0[0])
      ENDIF ELSE BEGIN
        ; => SUB_DIR keyword was set correctly
        base_dir = FILEPATH('',SUBDIRECTORY=sub_dir[0])
      ENDELSE
    END
    2 : BEGIN
      ; => Both BASE_DIR and SUB_DIR keywords were set correctly
      subdir0  = FILE_BASENAME(sub_dir[0])   ; => removes file path if present
      base_dir = FILE_SEARCH(direc0[0],subdir0[0],/TEST_DIRECTORY,/MARK_DIRECTORY)
;      base_dir = FILEPATH('',ROOT_DIR=direc0[0],SUBDIRECTORY=subdir0[0])
    END
  ENDCASE
ENDELSE
direc = base_dir[0]

IF (SIZE(direc[0],/TYPE) NE 7) THEN BEGIN
  MESSAGE,badinp_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,default[0]
ENDIF ELSE BEGIN
  default_location  = direc[0]
ENDELSE

test = STRLEN(default_location[0]+baddir_mssg[0]) GT 80   ; => max 80 chars wide
IF (test) THEN BEGIN
  gposi             = STRPOS(default_location[0],slash[0],/REVERSE_OFFSET,/REVERSE_SEARCH)
  IF (gposi[0] GT 0) THEN BEGIN
    default_extension = '~'+STRMID(default_location[0],gposi[0])
  ENDIF ELSE BEGIN
    MESSAGE,badinp_mssg[0],/INFORMATIONAL,/CONTINUE
    RETURN,default[0]
  ENDELSE
ENDIF ELSE BEGIN
  default_extension = default_location[0]
ENDELSE
;-----------------------------------------------------------------------------------------
; => Test directory  [ = 0 if not valid, = 1 if valid path]
;-----------------------------------------------------------------------------------------
good = (FILE_TEST(default_location[0],/DIRECTORY) EQ 1)
IF (~good) THEN BEGIN
  ; => Not a valid directory path
  MESSAGE,default_extension[0]+baddir_mssg,/INFORMATIONAL,/CONTINUE
  IF KEYWORD_SET(getn) THEN BEGIN
    ; => Pick new directory
    ttl   = pick_mssg
    test0 = DIALOG_PICKFILE(PATH=default[0],GET_PATH=default_location,/DIRECTORY,TITLE=pick_mssg)
    RETURN,base_dir[0]
  ENDIF ELSE BEGIN
    RETURN,default[0]
  ENDELSE
ENDIF ELSE BEGIN
  ; => Change extension to just the directory of interest
  default_extension = FILE_BASENAME(default_location[0])
ENDELSE
; => Define base directory
base_dir = FILEPATH('',ROOT_DIR=default_location[0])
;-----------------------------------------------------------------------------------------
; => Define specific directory in case multiple exist in base_dir
;-----------------------------------------------------------------------------------------
test_dir = FILE_SEARCH(base_dir,'*',/TEST_DIRECTORY)  ; => Returns a list of directories
ndirs    = N_ELEMENTS(test_dir)
; => Check with user
IF (ndirs GT 1) THEN BEGIN
  yesno = ''
  PRINT,'There are multiple directories in your file path.  Do you want to use only'
  PRINT,'  the currently selected directory given by:'
  PRINT,''
  PRINT,base_dir
  PRINT,''
  PRINT,'Or do you wish to narrow your search?'
  WHILE (yesno NE '1' AND yesno NE '2') DO BEGIN
    READ,yesno,PROMPT='Type 1 to choose specific directory, 2 to use current: '
    yesno = STRMID(STRTRIM(yesno,2),0L,3L)
  ENDWHILE
  current = ([0,1])[WHERE(['1','2'] EQ yesno[0])]
  CASE current[0] OF
    0 : BEGIN
      ; => Narrow directory tree
      test0  = DIALOG_PICKFILE(PATH=default[0],GET_PATH=base_dir,/DIRECTORY,TITLE=pick_mssg)
    END
    ELSE : 
  ENDCASE
ENDIF
;-----------------------------------------------------------------------------------------
; => check for trailing slash
;-----------------------------------------------------------------------------------------
dirlen = STRLEN(base_dir[0])
ll     = STRMID(base_dir[0],dirlen[0] - 1L)
IF (ll[0] EQ '') THEN base_dir[0] = base_dir[0]+slash[0]

RETURN,base_dir[0]
END