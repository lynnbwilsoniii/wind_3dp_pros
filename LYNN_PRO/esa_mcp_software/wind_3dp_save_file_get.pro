;+
;*****************************************************************************************
;
;  FUNCTION :   wind_3dp_save_file_get.pro
;  PURPOSE  :   Restores and returns IDL save files to user and user can return only
;                 data within a specified time range if memory is an issue.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               time_range_define.pro
;               directory_path_check.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  IDL Save files produced using similar steps to those found in
;                     the crib sheet named:  my_3DP_moments_save-files.txt
;                     found in the directory:  ~/wind_3dp_pros/wind_3dp_cribs/
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ymdb    = ['1998-08-25/01:30:00','1998-08-28/12:45:00']
;               tra     = time_double(ymdb)
;               eesa    = 1
;               pesa    = 1
;               sstf    = 1
;               ssto    = 1
;               test    = wind_3dp_save_file_get(TRANGE=tra,EESA=eesa,PESA=pesa,$
;                                                SSTF=sstf,SSTO=ssto)
;
;  KEYWORDS:    
;               DATE    :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               EESA    :  Set to a named variable to return a structure with all
;                            EESA structures relevant to date of interest
;               PESA    :  Set to a named variable to return a structure with all
;                            EESA structures relevant to date of interest
;               SSTF    :  Set to a named variable to return a structure with all
;                            SST Foil structures relevant to date of interest
;               SSTO    :  Set to a named variable to return a structure with all
;                            SST Open structures relevant to date of interest
;               TRANGE  :  [Double] 2 element array specifying the time range for
;                            the data you wish to return [Unix time]
;
;   CHANGED:  1)  Finished writing routine                         [02/02/2012   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  03/25/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/02/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION wind_3dp_save_file_get,DATE=date,EESA=eesa,PESA=pesa,SSTF=sf,SSTO=so, $
                                TRANGE=trange

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
vers        = !VERSION.OS_FAMILY
IF (vers NE 'unix') THEN slash = '\' ELSE slash = '/'


baddir_mssg       = ' is not a valid directory!'
nopros_mssg       = 'There are no files with *.sav extension in '   ; => add directory onto end
pick_mssg         = 'Move to the desired directory and then click open or okay'
default_extension = slash[0]+'wind_3dp_pros'+slash[0]+'wind_data_dir'+$
                    slash[0]+'Wind_3DP_DATA'+slash[0]+'IDL_Save_Files'+slash[0]
default_location  = default_extension

etags             = ['EL','ELB','EH','EHB']
ptags             = ['PL','PLB','PH','PHB']
ftags             = ['SF','SFB']
otags             = ['SO','SOB']
;-----------------------------------------------------------------------------------------
; => Determine time range of interest
;-----------------------------------------------------------------------------------------
zdate0   = ''    ; => Start date ['YYYY-MM-DD']
zdate1   = ''    ; => End date   ['YYYY-MM-DD']
time_ra  = time_range_define(DATE=date,TRANGE=trange)

tra      = time_ra.TR_UNIX
tdate    = time_ra.TDATE_SE
zdate0   = tdate[0]
zdate1   = tdate[1]
dir_date = time_ra.S_DATE_SE[0]  ; => ['MMDDYY']

;-----------------------------------------------------------------------------------------
; => Find Wind/3DP IDL Save File Directory
;-----------------------------------------------------------------------------------------
default_location += dir_date[0]+slash[0]

DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF NOT KEYWORD_SET(exists) THEN BEGIN
  mdir  = FILE_EXPAND_PATH('')+default_location
ENDIF ELSE BEGIN
  mdir  = !wind3dp_umn.WIND_3DP_SAVE_FILE_DIR+dir_date[0]+slash[0]
ENDELSE
IF (mdir EQ '') THEN mdir = default_location
; => test out directory
test      = directory_path_check(BASE_DIR=mdir[0],/GET_NEW)
mdir      = test[0]
dirlen    = STRLEN(mdir[0])  ; => use to get only file names

dir_path  = FILE_DIRNAME(mdir,/MARK_DIRECTORY)
; => Get ONLY the name of the directory with no path or extensions
dir_name  = STRMID(mdir[0],STRLEN(dir_path[0])-1L)
;dir_name  = STRMID(dir_name[0],0L,STRLEN(dir_name[0])-1L)  ; => Remove the trailing slash
;-----------------------------------------------------------------------------------------
; => Find files
;-----------------------------------------------------------------------------------------
mfiles    = FILE_SEARCH(mdir,'*.sav')
;-----------------------------------------------------------------------------------------
; => Test files
;-----------------------------------------------------------------------------------------
good      = WHERE(mfiles NE '',gd)
IF (gd GT 0) THEN BEGIN
  mfiles  = mfiles[good]
ENDIF ELSE BEGIN
  MESSAGE,nopros_mssg[0]+'~'+dir_name[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE
nfiles    = gd
;-----------------------------------------------------------------------------------------
; => Determine the types of save files available
;-----------------------------------------------------------------------------------------
file_only = STRMID(mfiles[*],dirlen[0])  ; => Only file names
f_len     = STRLEN(file_only)
g_eesa    = STRPOS(STRLOWCASE(file_only[*]),'eesa') GE 0        ; => logic:  test for EESA
g_pesa    = STRPOS(STRLOWCASE(file_only[*]),'pesa') GE 0        ; => logic:  test for PESA
g_stfo    = STRPOS(STRLOWCASE(file_only[*]),'foil-open_') GE 0  ; => logic:  test for Foil and Open
g_sstf    = STRPOS(STRLOWCASE(file_only[*]),'foil') GE 0        ; => logic:  test for Foil
g_ssto    = STRPOS(STRLOWCASE(file_only[*]),'open') GE 0        ; => logic:  test for Open

good_ee   = WHERE(g_eesa,gdee)
good_pe   = WHERE(g_pesa,gdpe)
good_sf   = WHERE(g_sstf,gdsf)
good_so   = WHERE(g_ssto,gdso)
good_fo   = WHERE(g_stfo,gdfo)
;-----------------------------------------------------------------------------------------
; => Restore files desired by user
;-----------------------------------------------------------------------------------------
ael  = 0 & aelb = 0 & apl  = 0 & aplb = 0
aeh  = 0 & aehb = 0 & aph  = 0 & aphb = 0
asf  = 0 & asfb = 0 & aso  = 0 & asob = 0

ael0 = 0 & aelb0 = 0 & apl0 = 0 & aplb0 = 0
aeh0 = 0 & aehb0 = 0 & aph0 = 0 & aphb0 = 0
asf0 = 0 & asfb0 = 0 & aso0 = 0 & asob0 = 0
;-----------------------------------------------------------------------------------------
; => Load EESA
;-----------------------------------------------------------------------------------------
IF (gdee GT 0 AND KEYWORD_SET(eesa)) THEN BEGIN
  FOR j=0L, gdee - 1L DO BEGIN
    gfile = mfiles[good_ee[j]]
    RESTORE,gfile[0]
    nel   = (N_ELEMENTS(ael)  GT 0) AND (SIZE(ael[0], /TYPE) EQ 8)
    nelb  = (N_ELEMENTS(aelb) GT 0) AND (SIZE(aelb[0],/TYPE) EQ 8)
    neh   = (N_ELEMENTS(aeh)  GT 0) AND (SIZE(aeh[0], /TYPE) EQ 8)
    nehb  = (N_ELEMENTS(aehb) GT 0) AND (SIZE(aehb[0],/TYPE) EQ 8)
    IF (j EQ 0) THEN BEGIN
      ; => define new dummy arrays of structures
      IF (nel ) THEN ael0  = ael
      IF (nelb) THEN aelb0 = aelb
      IF (neh ) THEN aeh0  = aeh
      IF (nehb) THEN aehb0 = aehb
    ENDIF ELSE BEGIN
      ; => define new dummy arrays of structures
      IF (nel  AND SIZE(ael0[0], /TYPE) EQ 8)   THEN ael0  = [ ael, ael0] ELSE $
        IF (nel  AND SIZE(ael0[0], /TYPE) NE 8) THEN ael0  = ael
      IF (nelb AND SIZE(aelb0[0],/TYPE) EQ 8)   THEN aelb0 = [aelb,aelb0] ELSE $
        IF (nelb AND SIZE(aelb0[0],/TYPE) NE 8) THEN aelb0 = aelb
      IF (neh  AND SIZE(aeh0[0], /TYPE) EQ 8)   THEN aeh0  = [ aeh, aeh0] ELSE $
        IF (neh  AND SIZE(aeh0[0], /TYPE) NE 8) THEN aeh0  = aeh
      IF (nehb AND SIZE(aehb0[0],/TYPE) EQ 8)   THEN aehb0 = [aehb,aehb0] ELSE $
        IF (nehb AND SIZE(aehb0[0],/TYPE) NE 8) THEN aehb0 = aehb
    ENDELSE
    ; => delete old definitions
    ael  = 0
    aelb = 0
    aeh  = 0
    aehb = 0
  ENDFOR
ENDIF ELSE BEGIN
  ; => No EESA files found
  nopros_mssg = 'There are no EESA files with *.sav extension in '
  MESSAGE,nopros_mssg[0]+'~'+dir_name[0],/INFORMATIONAL,/CONTINUE
  ael0        = 0
  aelb0       = 0
  aeh0        = 0
  aehb0       = 0
ENDELSE
;-----------------------------------------------------------------------------------------
; => Sort data, keep only that within selected time range, and define return structure
;-----------------------------------------------------------------------------------------
nel   = (N_ELEMENTS(ael0)  GT 0) AND (SIZE(ael0[0], /TYPE) EQ 8)
nelb  = (N_ELEMENTS(aelb0) GT 0) AND (SIZE(aelb0[0],/TYPE) EQ 8)
neh   = (N_ELEMENTS(aeh0)  GT 0) AND (SIZE(aeh0[0], /TYPE) EQ 8)
nehb  = (N_ELEMENTS(aehb0) GT 0) AND (SIZE(aehb0[0],/TYPE) EQ 8)
eesa  = CREATE_STRUCT(etags,ael0,aelb0,aeh0,aehb0)
nesa  = CREATE_STRUCT(etags,nel,nelb,neh,nehb)
FOR j=0L, 3L DO BEGIN
  IF (nesa.(j)) THEN BEGIN
    dat3d = eesa.(j)
    unix  = dat3d.TIME
    sp    = SORT(unix)
    IF (KEYWORD_SET(tra)) THEN BEGIN
      ; => Time range specified
      good  = WHERE(unix[sp] GE tra[0] AND unix[sp] LE tra[1],gd)
      IF (gd GT 0) THEN gels = sp[good] ELSE gels = -1
    ENDIF ELSE BEGIN
      ; => Time range not specified
      gels  = sp
    ENDELSE
    IF (gels[0] GE 0) THEN BEGIN
      ; => Good elements exist
      dat3d = dat3d[gels]
      str_element,eesa,etags[j],dat3d,/ADD_REPLACE
    ENDIF ELSE BEGIN
      ; => Good elements do not exist
      dat3d = 0
      str_element,eesa,etags[j],dat3d,/ADD_REPLACE
    ENDELSE
  ENDIF ELSE BEGIN
    ; => No structures
    dat3d = 0
    str_element,eesa,etags[j],dat3d,/ADD_REPLACE
  ENDELSE
ENDFOR
;-----------------------------------------------------------------------------------------
; => Load PESA
;-----------------------------------------------------------------------------------------
IF (gdpe GT 0 AND KEYWORD_SET(pesa)) THEN BEGIN
  FOR j=0L, gdpe - 1L DO BEGIN
    gfile = mfiles[good_pe[j]]
    RESTORE,gfile[0]
    npl   = (N_ELEMENTS(apl)  GT 0) AND (SIZE(apl[0], /TYPE) EQ 8)
    nplb  = (N_ELEMENTS(aplb) GT 0) AND (SIZE(aplb[0],/TYPE) EQ 8)
    nph   = (N_ELEMENTS(aph)  GT 0) AND (SIZE(aph[0], /TYPE) EQ 8)
    nphb  = (N_ELEMENTS(aphb) GT 0) AND (SIZE(aphb[0],/TYPE) EQ 8)
    IF (j EQ 0) THEN BEGIN
      ; => define new dummy arrays of structures
      IF (npl ) THEN apl0  = apl
      IF (nplb) THEN aplb0 = aplb
      IF (nph ) THEN aph0  = aph
      IF (nphb) THEN aphb0 = aphb
    ENDIF ELSE BEGIN
      ; => define new dummy arrays of structures
      IF (npl  AND SIZE(apl0[0], /TYPE) EQ 8)   THEN apl0  = [ apl, apl0] ELSE $
        IF (npl  AND SIZE(apl0[0], /TYPE) NE 8) THEN apl0  = apl
      IF (nplb AND SIZE(aplb0[0],/TYPE) EQ 8)   THEN aplb0 = [aplb,aplb0] ELSE $
        IF (nplb AND SIZE(aplb0[0],/TYPE) NE 8) THEN aplb0 = aplb
      IF (nph  AND SIZE(aph0[0], /TYPE) EQ 8)   THEN aph0  = [ aph, aph0] ELSE $
        IF (nph  AND SIZE(aph0[0], /TYPE) NE 8) THEN aph0  = aph
      IF (nphb AND SIZE(aphb0[0],/TYPE) EQ 8)   THEN aphb0 = [aphb,aphb0] ELSE $
        IF (nphb AND SIZE(aphb0[0],/TYPE) NE 8) THEN aphb0 = aphb
    ENDELSE
    ; => delete old definitions
    apl  = 0
    aplb = 0
    aph  = 0
    aphb = 0
  ENDFOR
ENDIF ELSE BEGIN
  ; => No PESA files found
  nopros_mssg = 'There are no PESA files with *.sav extension in '
  MESSAGE,nopros_mssg[0]+'~'+dir_name[0],/INFORMATIONAL,/CONTINUE
  apl0        = 0
  aplb0       = 0
  aph0        = 0
  aphb0       = 0
ENDELSE
;-----------------------------------------------------------------------------------------
; => Sort data, keep only that within selected time range, and define return structure
;-----------------------------------------------------------------------------------------
npl   = (N_ELEMENTS(apl0)  GT 0) AND (SIZE(apl0[0], /TYPE) EQ 8)
nplb  = (N_ELEMENTS(aplb0) GT 0) AND (SIZE(aplb0[0],/TYPE) EQ 8)
nph   = (N_ELEMENTS(aph0)  GT 0) AND (SIZE(aph0[0], /TYPE) EQ 8)
nphb  = (N_ELEMENTS(aphb0) GT 0) AND (SIZE(aphb0[0],/TYPE) EQ 8)
pesa  = CREATE_STRUCT(ptags,apl0,aplb0,aph0,aphb0)
npsa  = CREATE_STRUCT(ptags,npl,nplb,nph,nphb)
FOR j=0L, 3L DO BEGIN
  IF (npsa.(j)) THEN BEGIN
    dat3d = pesa.(j)
    unix  = dat3d.TIME
    sp    = SORT(unix)
    IF (KEYWORD_SET(tra)) THEN BEGIN
      ; => Time range specified
      good  = WHERE(unix[sp] GE tra[0] AND unix[sp] LE tra[1],gd)
      IF (gd GT 0) THEN gels = sp[good] ELSE gels = -1
    ENDIF ELSE BEGIN
      ; => Time range not specified
      gels  = sp
    ENDELSE
    IF (gels[0] GE 0) THEN BEGIN
      ; => Good elements exist
      dat3d = dat3d[gels]
      str_element,pesa,ptags[j],dat3d,/ADD_REPLACE
    ENDIF ELSE BEGIN
      ; => Good elements do not exist
      dat3d = 0
      str_element,pesa,ptags[j],dat3d,/ADD_REPLACE
    ENDELSE
  ENDIF ELSE BEGIN
    ; => No structures
    dat3d = 0
    str_element,pesa,ptags[j],dat3d,/ADD_REPLACE
  ENDELSE
ENDFOR
;-----------------------------------------------------------------------------------------
; => Load SST
;-----------------------------------------------------------------------------------------
test_set  = KEYWORD_SET(sf) OR KEYWORD_SET(so)
test_chck = (gdfo GT 0) OR (gdsf GT 0) OR (gdso GT 0)
; Test for Foil and Open in same files
test_easy = ((gdfo EQ gdsf) AND (gdfo EQ gdso)) AND (gdfo GT 0)
; Test for Foil and Open in different files
test_hard = ((gdfo NE gdsf)  OR (gdfo NE gdso)) AND ((gdsf GT 0) OR (gdso GT 0))

good_chck = WHERE([(gdfo GT 0),(gdsf GT 0),(gdso GT 0)],gdck)
IF (test_easy AND test_set) THEN BEGIN
  ;---------------------------------------------------------------------------------------
  ; => Easiest case works
  ;---------------------------------------------------------------------------------------
  FOR j=0L, gdfo - 1L DO BEGIN
    gfile = mfiles[good_fo[j]]
    RESTORE,gfile[0]
    nsf   = (N_ELEMENTS(asf)  GT 0) AND (SIZE(asf[0], /TYPE) EQ 8)
    nsfb  = (N_ELEMENTS(asfb) GT 0) AND (SIZE(asfb[0],/TYPE) EQ 8)
    nso   = (N_ELEMENTS(aso)  GT 0) AND (SIZE(aso[0], /TYPE) EQ 8)
    nsob  = (N_ELEMENTS(asob) GT 0) AND (SIZE(asob[0],/TYPE) EQ 8)
    IF (j EQ 0) THEN BEGIN
      ; => define new dummy arrays of structures
      IF (nsf ) THEN asf0  = asf
      IF (nsfb) THEN asfb0 = asfb
      IF (nso ) THEN aso0  = aso
      IF (nsob) THEN asob0 = asob
    ENDIF ELSE BEGIN
      ; => define new dummy arrays of structures
      IF (nsf  AND SIZE(asf0[0], /TYPE) EQ 8)   THEN asf0  = [ asf, asf0] ELSE $
        IF (nsf  AND SIZE(asf0[0], /TYPE) NE 8) THEN asf0  = asf
      IF (nsfb AND SIZE(asfb0[0],/TYPE) EQ 8)   THEN asfb0 = [asfb,asfb0] ELSE $
        IF (nsfb AND SIZE(asfb0[0],/TYPE) NE 8) THEN asfb0 = asfb
      IF (nso  AND SIZE(aso0[0], /TYPE) EQ 8)   THEN aso0  = [ aso, aso0] ELSE $
        IF (nso  AND SIZE(aso0[0], /TYPE) NE 8) THEN aso0  = aso
      IF (nsob AND SIZE(asob0[0],/TYPE) EQ 8)   THEN asob0 = [asob,asob0] ELSE $
        IF (nsob AND SIZE(asob0[0],/TYPE) NE 8) THEN asob0 = asob
    ENDELSE
    ; => delete old definitions
    asf  = 0
    asfb = 0
    aso  = 0
    asob = 0
  ENDFOR
ENDIF ELSE BEGIN
  ;---------------------------------------------------------------------------------------
  ; => Easiest case not found, so make sure SST files exist
  ;---------------------------------------------------------------------------------------
  IF (gdck GT 0 AND test_set) THEN BEGIN
    ; => Check Foil
    IF (gdsf GT 0) THEN BEGIN
      ;-----------------------------------------------------------------------------------
      ; => SST Foil do files exist
      ;-----------------------------------------------------------------------------------
      FOR j=0L, gdsf - 1L DO BEGIN
        gfile = mfiles[good_sf[j]]
        RESTORE,gfile[0]
        nsf   = (N_ELEMENTS(asf)  GT 0) AND (SIZE(asf[0], /TYPE) EQ 8)
        nsfb  = (N_ELEMENTS(asfb) GT 0) AND (SIZE(asfb[0],/TYPE) EQ 8)
        IF (j EQ 0) THEN BEGIN
          ; => define new dummy arrays of structures
          IF (nsf ) THEN asf0  = asf
          IF (nsfb) THEN asfb0 = asfb
        ENDIF ELSE BEGIN
          ; => define new dummy arrays of structures
          IF (nsf  AND SIZE(asf0[0], /TYPE) EQ 8)   THEN asf0  = [ asf, asf0] ELSE $
            IF (nsf  AND SIZE(asf0[0], /TYPE) NE 8) THEN asf0  = asf
          IF (nsfb AND SIZE(asfb0[0],/TYPE) EQ 8)   THEN asfb0 = [asfb,asfb0] ELSE $
            IF (nsfb AND SIZE(asfb0[0],/TYPE) NE 8) THEN asfb0 = asfb
        ENDELSE
        ; => delete old definitions
        asf  = 0
        asfb = 0
      ENDFOR
    ENDIF ELSE BEGIN
      ;-----------------------------------------------------------------------------------
      ; => SST Foil do not files exist
      ;-----------------------------------------------------------------------------------
      nopros_mssg = 'There are no SST Foil files with *.sav extension in '
      MESSAGE,nopros_mssg[0]+'~'+dir_name[0],/INFORMATIONAL,/CONTINUE
      asf0        = 0
      asfb0       = 0
    ENDELSE
    ; => Check Open
    IF (gdso GT 0) THEN BEGIN
      ;-----------------------------------------------------------------------------------
      ; => SST Open do files exist
      ;-----------------------------------------------------------------------------------
      FOR j=0L, gdso - 1L DO BEGIN
        gfile = mfiles[good_so[j]]
        RESTORE,gfile[0]
        nso   = (N_ELEMENTS(aso)  GT 0) AND (SIZE(aso[0], /TYPE) EQ 8)
        nsob  = (N_ELEMENTS(asob) GT 0) AND (SIZE(asob[0],/TYPE) EQ 8)
        IF (j EQ 0) THEN BEGIN
          ; => define new dummy arrays of structures
          IF (nso ) THEN aso0  = aso
          IF (nsob) THEN asob0 = asob
        ENDIF ELSE BEGIN
          ; => define new dummy arrays of structures
          IF (nso  AND SIZE(aso0[0], /TYPE) EQ 8)   THEN aso0  = [ aso, aso0] ELSE $
            IF (nso  AND SIZE(aso0[0], /TYPE) NE 8) THEN aso0  = aso
          IF (nsob AND SIZE(asob0[0],/TYPE) EQ 8)   THEN asob0 = [asob,asob0] ELSE $
            IF (nsob AND SIZE(asob0[0],/TYPE) NE 8) THEN asob0 = asob
        ENDELSE
        ; => delete old definitions
        aso  = 0
        asob = 0
      ENDFOR
    ENDIF ELSE BEGIN
      ;-----------------------------------------------------------------------------------
      ; => SST Open do not files exist
      ;-----------------------------------------------------------------------------------
      nopros_mssg = 'There are no SST Open files with *.sav extension in '
      MESSAGE,nopros_mssg[0]+'~'+dir_name[0],/INFORMATIONAL,/CONTINUE
      aso0        = 0
      asob0       = 0
    ENDELSE
  ENDIF ELSE BEGIN
    ;-------------------------------------------------------------------------------------
    ; => SST do not files exist
    ;-------------------------------------------------------------------------------------
    nopros_mssg = 'There are no SST files with *.sav extension in '
    MESSAGE,nopros_mssg[0]+'~'+dir_name[0],/INFORMATIONAL,/CONTINUE
    asf0        = 0
    asfb0       = 0
    aso0        = 0
    asob0       = 0
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Sort data, keep only that within selected time range, and define return structure
;-----------------------------------------------------------------------------------------
nsf   = (N_ELEMENTS(asf0)  GT 0) AND (SIZE(asf0[0], /TYPE) EQ 8)
nsfb  = (N_ELEMENTS(asfb0) GT 0) AND (SIZE(asfb0[0],/TYPE) EQ 8)
sf    = CREATE_STRUCT(ftags,asf0,asfb0)
nsft  = CREATE_STRUCT(ftags,nsf,nsfb)
FOR j=0L, N_ELEMENTS(ftags) - 1L DO BEGIN
  IF (nsft.(j)) THEN BEGIN
    dat3d = sf.(j)
    unix  = dat3d.TIME
    sp    = SORT(unix)
    IF (KEYWORD_SET(tra)) THEN BEGIN
      ; => Time range specified
      good  = WHERE(unix[sp] GE tra[0] AND unix[sp] LE tra[1],gd)
      IF (gd GT 0) THEN gels = sp[good] ELSE gels = -1
    ENDIF ELSE BEGIN
      ; => Time range not specified
      gels  = sp
    ENDELSE
    IF (gels[0] GE 0) THEN BEGIN
      ; => Good elements exist
      dat3d = dat3d[gels]
      str_element,sf,ftags[j],dat3d,/ADD_REPLACE
    ENDIF ELSE BEGIN
      ; => Good elements do not exist
      dat3d = 0
      str_element,sf,ftags[j],dat3d,/ADD_REPLACE
    ENDELSE
  ENDIF ELSE BEGIN
    ; => No structures
    dat3d = 0
    str_element,sf,ftags[j],dat3d,/ADD_REPLACE
  ENDELSE
ENDFOR

nso   = (N_ELEMENTS(aso0)  GT 0) AND (SIZE(aso0[0], /TYPE) EQ 8)
nsob  = (N_ELEMENTS(asob0) GT 0) AND (SIZE(asob0[0],/TYPE) EQ 8)
so    = CREATE_STRUCT(otags,aso0,asob0)
nsot  = CREATE_STRUCT(otags,nso,nsob)
FOR j=0L, N_ELEMENTS(otags) - 1L DO BEGIN
  IF (nsot.(j)) THEN BEGIN
    dat3d = so.(j)
    unix  = dat3d.TIME
    sp    = SORT(unix)
    IF (KEYWORD_SET(tra)) THEN BEGIN
      ; => Time range specified
      good  = WHERE(unix[sp] GE tra[0] AND unix[sp] LE tra[1],gd)
      IF (gd GT 0) THEN gels = sp[good] ELSE gels = -1
    ENDIF ELSE BEGIN
      ; => Time range not specified
      gels  = sp
    ENDELSE
    IF (gels[0] GE 0) THEN BEGIN
      ; => Good elements exist
      dat3d = dat3d[gels]
      str_element,so,otags[j],dat3d,/ADD_REPLACE
    ENDIF ELSE BEGIN
      ; => Good elements do not exist
      dat3d = 0
      str_element,so,otags[j],dat3d,/ADD_REPLACE
    ENDELSE
  ENDIF ELSE BEGIN
    ; => No structures
    dat3d = 0
    str_element,so,otags[j],dat3d,/ADD_REPLACE
  ENDELSE
ENDFOR

;-----------------------------------------------------------------------------------------
; => Return
;-----------------------------------------------------------------------------------------

RETURN,1
END
