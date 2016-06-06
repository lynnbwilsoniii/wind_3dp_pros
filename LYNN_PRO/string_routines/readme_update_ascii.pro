;+
;*****************************************************************************************
;
;  FUNCTION :   readme_update_ascii.pro
;  PURPOSE  :   This routine creates a list of manual pages for the routines in the
;                 user specified directory.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               directory_path_check.pro
;               readme_file_info.pro
;               read_gen_ascii.pro
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
;               BASE_DIR  :  Scalar string defining the full path to the directory where
;                              you wish to start searching for *.pro files
;               SUB_DIR   :  Scalar string defining the the directory where
;                              you wish to find the relevant *.pro files and create
;                              a README list of manual pages
;                           [format matches that of SUBDIRECTORY keyword in FILEPATH.PRO]
;               FINFO     :  If set, routine prints time of last modification with
;                              manual page print out
;
;   CHANGED:  1)  Cleaned up algorithm                          [03/14/2011   v1.1.0]
;             2)  Now program calls directory_path_check.pro and
;                   readme_file_info.pro is no longer part of this file
;                                                               [04/22/2011   v1.2.0]
;
;   NOTES:      
;               1)  This program will only search for files ending with *.pro,
;                     thus you should not try to create a readme list of crib sheets
;               2)  This program is kind of kludgy
;               3)  The FINFO reports the UTC time of last modification, but the man
;                     page may suggest a slightly earlier date.  The issue is simply
;                     that the dates in the man pages are local time and the program
;                     keyword options reports UTC.
;
;   CREATED:  03/11/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/22/2011   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO readme_update_ascii,BASE_DIR=direc,SUB_DIR=sub_dir,FINFO=finfo

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
baddir_mssg = 'DIREC is not a valid directory!'
nopros_mssg = 'There are no files with *.pro extension in '   ; => add directory onto end
pick_mssg   = 'Move to the desired directory and then click open or okay'

vers        = !VERSION.OS_FAMILY
IF (vers NE 'unix') THEN slash = '\' ELSE slash = '/'
;-----------------------------------------------------------------------------------------
; => Find directory of files of interest
;-----------------------------------------------------------------------------------------
test0       = directory_path_check(BASE_DIR=direc,SUB_DIR=sub_dir)
IF (test0[0] NE '') THEN BEGIN
  base_dir = test0[0]
ENDIF ELSE BEGIN
  MESSAGE,baddir_mssg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDELSE

; => check for trailing slash
dirlen = STRLEN(base_dir[0])
ll     = STRMID(base_dir[0],dirlen[0] - 1L)
IF (ll[0] EQ '') THEN base_dir[0] = base_dir[0]+slash[0]
dirlen = STRLEN(base_dir[0])
; => The length above will be used to truncate file names and remove files from 
;      folders burried deeper in directory trees
;-----------------------------------------------------------------------------------------
; => Get all file names associated with *.pro
;-----------------------------------------------------------------------------------------
file_pro  = FILE_SEARCH(base_dir[0],'*.pro',/TEST_REGULAR)
file_only = STRMID(file_pro[*],dirlen[0])  ; => Only file names
dir_test  = STRPOS(file_only,slash[0])

bad_dirs  = WHERE(dir_test GE 0,bddir,COMPLEMENT=good_files,NCOMPLEMENT=gdfile)
IF (gdfile EQ 0) THEN BEGIN
  MESSAGE,nopros_mssg+base_dir[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
dir_path  = FILE_DIRNAME(base_dir,/MARK_DIRECTORY)
; => Get ONLY the name of the directory with no path or extensions
dir_name  = STRMID(base_dir[0],STRLEN(dir_path[0]))
dir_name  = STRMID(dir_name[0],0L,STRLEN(dir_name[0])-1L)
;dir_name  = STRMID(dir_name[0],STRPOS(dir_name[0],'/',/REVERSE_SEARCH)+1L)
fname     = 'README_'+dir_name[0]+'.txt'

all_files = ''   ; => String array of the files with *.pro extension in current dir.
all_lines = 0L   ; => total # of text lines in each file

all_files  = file_pro[good_files]
IF KEYWORD_SET(finfo) THEN finfo = readme_file_info(all_files) ELSE finfo = REPLICATE('',gdfile)
all_nlines = FILE_LINES(all_files,/NOEXPAND_PATH)
nf         = N_ELEMENTS(all_files)
mxl        = MAX(all_nlines,/NAN)
;-----------------------------------------------------------------------------------------
; => Read in files
;-----------------------------------------------------------------------------------------
all_lines = STRARR(nf,mxl)  ; => String array to contain all the file lines
jj        = 0
WHILE (jj LE nf - 1L) DO BEGIN
  temp   = read_gen_ascii(all_files[jj])
  tempc  = STRCOMPRESS(temp,/REMOVE_ALL)
  nl0    = N_ELEMENTS(temp)
  ; => Find semi-colons
  plus   = WHERE(STRMID(temp[*],0L,3L)  EQ ';+',gdpl)
  minus  = WHERE(STRMID(temp[*],0L,3L)  EQ ';-',gdmn)
  stars  = WHERE(STRMID(temp[*],0L,2L)  EQ ';*',gdst)
  gdsum  = TOTAL([gdpl GT 0,gdmn GT 0])
  IF (gdsum LT 2) THEN BEGIN
    all_lines[jj,*] = ''
    jj             += 1
    CONTINUE
  ENDIF
  ; => Looking for a standard format of my Man. pages:
  ;   ;+
  ;   ;*************...
  ;   ;
  ;   ;  FUNCTION
  ;   .
  ;   .
  ;   .
  ;   ;  ....
  ;   ;
  ;   ;*************...
  ;   ;-
  ns         = N_ELEMENTS(stars)
  nm         = N_ELEMENTS(minus)
  np         = N_ELEMENTS(plus)
  starp      = stars - 1L        ; => Difference between ';+' and ';***...' positions
  starm      = stars + 1L        ; => Difference between ';-' and ';***...' positions
  diffmp     = LONARR(nm,np)     ; => Difference between ';-' and ';+' positions
  good_p     = REPLICATE(-1,np)  ; => Elements where ';-' - ';+' is minimized
  good_m     = REPLICATE(-1,nm)  ; => Elements where ';-' - ';+' is minimized
  FOR j=0L, nm - 1L DO diffmp[j,*] = minus[j] - plus[*]
  FOR i=0L, np - 1L DO BEGIN
    gpos = WHERE(diffmp[*,i] GT 0,gpo)
    IF (gpo GT 0) THEN BEGIN
      minp      = MIN(diffmp[gpos,i],/NAN,lmn)
      IF (minus[gpos[lmn]] GT plus[i]) THEN BEGIN
        good_m[i] = minus[gpos[lmn]]
        good_p[i] = plus[i]
      ENDIF
    ENDIF ELSE BEGIN
      good_m[i] = -1
      good_p[i] = -1
    ENDELSE
  ENDFOR
  good       = WHERE(good_m GT 0,gd)
  IF (gd EQ 0) THEN BEGIN
    all_lines[jj,*] = ''
    jj             += 1
    CONTINUE
  ENDIF ELSE good_m = good_m[good]
  minus      = REFORM(good_m)
  plus       = REFORM(good_p)
  ;---------------------------------------------------------------------------------------
  ; => Remove non-unique elements
  ;---------------------------------------------------------------------------------------
  unq        = UNIQ(plus,SORT(plus))
  plus       = plus[unq]
  unq        = UNIQ(minus,SORT(minus))
  minus      = minus[unq]
  np         = N_ELEMENTS(plus)
  nm         = N_ELEMENTS(minus)
  IF (np NE nm) THEN BEGIN
    good_m     = REPLICATE(-1,nm)  ; => Elements where ';-' - ';+' is minimized
    diffmp     = LONARR(nm,np)     ; => Difference between ';-' and ';+' positions
    FOR j=0L, nm - 1L DO diffmp[j,*] = minus[j] - plus[*]
    FOR j=0L, nm - 1L DO BEGIN
      gpos = WHERE(diffmp[j,*] GT 0,gpo)
      IF (gpo GT 0) THEN BEGIN
        minp      = MIN(diffmp[j,gpos],/NAN,lmn)
        IF (plus[gpos[lmn]] LT minus[j]) THEN BEGIN
          good_p[j] = plus[gpos[lmn]]
          good_m[j] = minus[j]
        ENDIF
      ENDIF ELSE BEGIN
        good_p[j] = -1
        good_m[j] = -1
      ENDELSE
    ENDFOR
    good       = WHERE(good_p GE 0,gd)
    IF (gd EQ 0) THEN BEGIN
      all_lines[jj,*] = ''
      jj             += 1
      CONTINUE
    ENDIF ELSE good_p = good_p[good]
  ENDIF
  minus      = REFORM(good_m)
  plus       = REFORM(good_p)
  nm         = N_ELEMENTS(minus)
  np         = N_ELEMENTS(plus)
  ;---------------------------------------------------------------------------------------
  ; => Remove non-unique elements
  ;---------------------------------------------------------------------------------------
  unq      = UNIQ(plus,SORT(plus))
  plus     = plus[unq]
  unq      = UNIQ(minus,SORT(minus))
  minus    = minus[unq]
  ; => Define initial guesses at start and end elements by plus and minus positions
  start_el = REFORM(plus)
  end_el   = REFORM(minus)
  n_pl     = N_ELEMENTS(plus)
  n_mn     = N_ELEMENTS(minus)
  ;---------------------------------------------------------------------------------------
  ; => Redefine start and end elements by plus and minus positions
  ;---------------------------------------------------------------------------------------
  nss      = N_ELEMENTS(start_el)
  IF (nss GT 1) THEN BEGIN
    cc       = 0
    FOR j=0L, nss - 1L DO BEGIN
      s0     = start_el[j]
      e0     = end_el[j]
      nel    = (e0 - s0 + 1L)
      IF (j EQ 0) THEN gels = LINDGEN(nel) + s0 ELSE gels = [gels,LINDGEN(nel) + s0]
    ENDFOR
    sp   = SORT(gels)
    gels = gels[sp]
  ENDIF ELSE BEGIN
    nl0      = end_el[0] - start_el[0] + 1L
    gels     = LINDGEN(nl0) + start_el[0]
  ENDELSE
  ; => Define all_lines
  nel = N_ELEMENTS(gels)
  all_lines[jj,0L:(nel - 1L)] = temp[gels]
  jj += 1
ENDWHILE
;-----------------------------------------------------------------------------------------
; => Write README file
;-----------------------------------------------------------------------------------------
a         = ''
file_name = base_dir[0]+fname[0]
OPENW,gunit,file_name[0],ERROR=err,/GET_LUN
  IF (err NE 0) THEN BEGIN
    PRINTF, -2, !ERROR_STATE.MSG
    RETURN
  ENDIF
  jj        = 0
  WHILE (jj LE nf - 1L) DO BEGIN
    tlines = REFORM(all_lines[jj,*])
    ; => Get rid of nulls
    good   = WHERE(tlines NE '',gd)
    IF (gd EQ 0) THEN BEGIN
      ; => No non-null strings
      jj             += 1
      CONTINUE
    ENDIF
    tinfo  = finfo[jj]
    tlines = tlines[good]
    tlines2 = tlines
    ; => Print to file
    nt2 = N_ELEMENTS(tlines2)
    ; => Print file info
    IF KEYWORD_SET(finfo) THEN BEGIN
      pref  = 'Last Modification =>  '
      PRINTF,gunit,pref[0]+tinfo[0]
    ENDIF
    FOR k=0L, nt2 - 1L DO BEGIN
      PRINTF,gunit,tlines2[k]
    ENDFOR
    PRINTF,gunit,''
    PRINTF,gunit,''
    ; => iterate
    jj += 1
  ENDWHILE
; => Close file
FREE_LUN,gunit

END









