;+
;*****************************************************************************************
;
;  PROCEDURE:   tplot_restore.pro
;  PURPOSE  :   Restores a TPLOT save file to TPLOT
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               @tplot_com.pro
;               tplot_quant__define.pro
;               dprint.pro
;               get_data.pro
;               is_struct.pro
;               str_element.pro
;               struct_value.pro
;               ndimen.pro
;               store_data.pro
;               tplot_sort.pro
;
;  REQUIRES:    
;               1)  SPEDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               tplot_restore [,FILENAMES=filenames] [,ALL=all] [,APPEND=append]         $
;                             [,SORT=sort] [,VERBOSE=verbose] [,GET_TVARS=get_tvars]     $
;                             [,RESTORED_VARNAMES=restored_varnames] [,DIRECTORY=directory]
;
;  KEYWORDS:    
;               FILENAMES          :  [N]-Element [string] array of TPLOT save file names
;                                       If no file name is chosen and /ALL is not set,
;                                       routine will look for and restore a file called
;                                       saved.tplot
;               ALL                :  If set, routine will restore all files in directory
;                                       defined by DIRECTORY keyword
;               APPEND             :  If set, append new TPLOT data to currently loaded
;                                       TPLOT data
;               SORT               :  IF set, sort data by time after it is loaded
;               VERBOSE            :  Set to provide additional info about data being
;                                       loaded and other useful info
;               GET_TVARS          :  If set, then routine will load data within the
;                                       tplot_tvars structure (within tplot_com.pro
;                                       COMMON block) even if such a structure already
;                                       exists in the current session.  The default is to
;                                       only load these if no such structure currently
;                                       exists in the session.
;               RESTORED_VARNAMES  :  Set to a named variable to return the TPLOT handles
;                                       of the data loaded into TPLOT
;               DIRECTORY          :  Scalar [string] defining the directory in which to
;                                       look for .tplot files when /ALL keyword is set
;
;   CHANGED:  1)  Jim McTiernan modified something
;                                                                   [06/19/2007   v1.0.?]
;             2)  CG changed obsolete IDL routine str_sep to strsplit
;                                                                   [05/21/2008   v1.0.?]
;             3)  Removed additional output text - Use dprint,debug=3  to restore text
;                                                                   [11/01/2008   v1.0.?]
;             4)  Tried to fix an issue with error handling
;                                                                   [02/03/2016   v1.1.0]
;             5)  Tried to fix an issue with 3D TPLOT handle data
;                                                                   [01/31/2018   v1.2.0]
;             6)  Fixed bug on macOS when saving figures of restored data using
;                   makepng/makegif/makejpg
;                                                                   [01/24/2019   v1.2.1]
;             7)  ALI modified something
;                                                                   [03/05/2020   v1.2.2]
;             8)  Jim McTiernan modified something
;                                                                   [11/19/2021   v1.2.3]
;             9)  Cleaned up and added some comments
;                                                                   [03/28/2025   v1.3.0]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   CREATED:  ??/??/????
;   CREATED BY:  Peter Schroeder
;    LAST MODIFIED:  03/28/2025   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO tplot_restore,FILENAMES=filenames,ALL=all,APPEND=append,SORT=sort,VERBOSE=verbose,$
                  GET_TVARS=get_tvars,RESTORED_VARNAMES=restored_varnames,            $
                  DIRECTORY=directory

;;----------------------------------------------------------------------------------------
;;  Initialize common block
;;----------------------------------------------------------------------------------------
COMPILE_OPT IDL2
@tplot_com.pro

;IF !d.name eq 'X' THEN BEGIN
;  IF !version.os_family eq 'unix' THEN device,retain=2  ; Unix family does not provide backing store by default
;ENDIF

;;----------------------------------------------------------------------------------------
;;  Initialize TPLOT data definitions
;;----------------------------------------------------------------------------------------
tplot_quant__define
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check DIRECTORY
IF KEYWORD_SET(directory) AND ~KEYWORD_SET(all) THEN BEGIN
  dprint,DLEVEL=0,'Warning: directory keyword only used when /all keyword set'
ENDIF

IF KEYWORD_SET(directory) THEN BEGIN
  ;;  First check for a slash
  n = N_ELEMENTS(directory)
  IF (n[0] EQ 0) THEN dirslash = '/' ELSE BEGIN
    dirslash = directory
    FOR j=0, n[0] - 1L DO BEGIN
      temp_string = STRTRIM(directory[j], 2)
      ll          = STRMID(temp_string[0],STRLEN(temp_string[0]) - 1L, 1L)
      IF (ll[0] NE '/' AND ll[0] NE '\') THEN temp_string = temp_string[0]+'/'
      dirslash[j] = TEMPORARY(temp_string)
    ENDFOR
  ENDELSE
  restore_dir = dirslash
ENDIF ELSE restore_dir = ''
;;  Check ALL
IF KEYWORD_SET(all) THEN filenames = FILE_SEARCH(restore_dir+'*.tplot')
;;  Check FILENAMES
IF (SIZE(/TYPE,filenames) NE 7) THEN filenames = 'saved.tplot'
;;----------------------------------------------------------------------------------------
;;  Restore files and load into TPLOT
;;----------------------------------------------------------------------------------------
n                 = N_ELEMENTS(filenames)
restored_varnames = ''

FOR i=0L, n[0] - 1L DO BEGIN
  ;;  FOR i=0,n-1 DO BEGIN
  fi                = FILE_INFO(filenames[i])
  IF (fi.EXISTS[0] EQ 0) THEN BEGIN
    ;;  File not found
    dprint,DLEVEL=1,'File '+filenames[i]+' Does not exist! Skipping.'
    CONTINUE
  ENDIF
  ;;  Restore TPLOT save file
  dprint,DLEVEL=2,'Restoring tplot file '+filenames[i]
;  dprint,DLEVEL=2,'Restoring tplot file '+file_info_string(filenames[i])
  RESTORE,filenames[i],/RELAXED
  ;;  Check for TV variable
  IF KEYWORD_SET(tv) THEN BEGIN
    chkverb = WHERE(TAG_NAMES(tv.OPTIONS) EQ 'VERBOSE',verbosethere)
    IF (NOT verbosethere[0]) THEN BEGIN
      optstruct = tv.OPTIONS
      setstruct = tv.SETTINGS
      newopt    = CREATE_STRUCT(optstruct,'VERBOSE',0)
      tv        = 0
      tv        = {OPTIONS:newopt,SETTINGS:setstruct}
      optstruct = 0
      setstruct = 0
      newopt    = 0
    ENDIF
  ENDIF
  ;;  Check GET_TVARS
  IF ((N_ELEMENTS(tplot_vars) EQ 0) OR KEYWORD_SET(get_tvars)) THEN IF KEYWORD_SET(tv) THEN tplot_vars = tv
  ;;  Load data if DQ variable defined (DQ = data quantity)
  IF KEYWORD_SET(dq) THEN BEGIN
    ;;  Loop through all DQ TPLOT handles
    FOR j=0L, N_ELEMENTS(dq.NAME) - 1L DO BEGIN
      ;;  	FOR j=0,N_ELEMENTS(dq.name)-1 DO BEGIN
      thisdq            = dq[j]
      dprint,DLEVEL=3, 'The tplot variable '+thisdq.NAME[0]+' is being restored.'
      restored_varnames = [restored_varnames, thisdq.NAME[0]]
      names             = STRSPLIT(thisdq.NAME[0],'.')
      ;;  Check APPEND
      IF KEYWORD_SET(append) THEN BEGIN
        ;;  Add to currently existing TPLOT handle, if present
        get_data,thisdq.NAME[0],PTR=olddata
        IF (SIZE(olddata,/TYPE) EQ 8) THEN BEGIN
          tagnm0          = STRLOWCASE(TAG_NAMES(olddata))
          test            = TOTAL([tagnm0 EQ 'x',tagnm0 EQ 'y']) EQ 2
          IF (test[0]) THEN IF (~PTR_VALID(olddata.X) || ~PTR_VALID(olddata.Y)) THEN BEGIN
            dprint,DLEVEL=1,'Invalid pointer to existing tplot variable ('+thisdq.NAME[0]+'); Skipping...'
            CONTINUE
          ENDIF
        ENDIF
;        IF (is_struct(olddata) && (~PTR_VALID(olddata.X) || ~PTR_VALID(olddata.Y))) THEN BEGIN
;          dprint,DLEVEL=1,'Invalid pointer to existing tplot variable ('+thisdq.NAME[0]+'); Skipping...'
;          CONTINUE
;        ENDIF
      ENDIF
      ;;  Data exists --> Append if user wants
      IF (KEYWORD_SET(append) AND is_struct(olddata)) THEN BEGIN   ;;  olddata needs to be a structure, jmm, 2021-10-19
        IF KEYWORD_SET(*thisdq.DH) THEN BEGIN
          ;;  Data Handle (DH) exists --> look deeper
          IF (thisdq.DTYPE[0] EQ 1) THEN BEGIN
            ;;  Data Type EQ 1
            IF PTR_VALID((*thisdq.DH).Y) THEN BEGIN
              ;;  check y dimensions prior to appending, jmm, 2019-11-22
              n1          = SIZE(*olddata.Y,/N_DIMENSIONS)
              n2          = SIZE(*(*thisdq.DH).Y, /N_DIMENSIONS)
              s1          = SIZE(*olddata.Y, /DIMENSIONS)
              s2          = SIZE(*(*thisdq.DH).Y, /DIMENSIONS)
              IF (N_ELEMENTS(s1) EQ 2) THEN s12 = s1[1] > s2[1]
              IF ((n1[0] ne n2[0]) || (N_ELEMENTS(s1) GT 2 && ~ARRAY_EQUAL(s1[1:*], s2[1:*]))) THEN BEGIN
                dprint,DLEVEL=1,'Variable '+thisdq.name+' Y size mismatch; not appended'
                CONTINUE
              ENDIF
              IF (N_ELEMENTS(s1) EQ 2 && s1[1] NE s2[1]) THEN BEGIN
                dprint,DLEVEL=3,'Variable '+thisdq.name+' Y size mismatch; matching sizes!'
                oldy                    = REPLICATE(!VALUES.F_NAN,[s1[0],s12])
                newy                    = REPLICATE(!VALUES.F_NAN,[s2[0],s12])
                oldy[*,0L:(s1[1] - 1L)] = *olddata.Y
                newy[*,0L:(s2[1] - 1L)] = *(*thisdq.DH).Y
                newy                    = PTR_NEW([oldy,newy])
              ENDIF ELSE newy = PTR_NEW([*olddata.Y,*(*thisdq.DH).Y])
            ENDIF ELSE newy = PTR_NEW(*olddata.Y)
            IF PTR_VALID((*thisdq.DH).X) THEN newx = PTR_NEW([*olddata.x,*(*thisdq.DH).X]) ELSE newx = PTR_NEW(*olddata.X)
            ;ptr_free,(*thisdq.dh).x,(*thisdq.dh).y ;this line is not compatible with tplot variables that share their time pointers (Deja Vu!)
            ;;  Initialize dummy pointer
            oldv          = PTR_NEW()
            ;;  Get data in V structure tag from OLDV (if present)
            str_element,olddata,'v',oldv
            IF PTR_VALID(oldv) THEN BEGIN
              ;;  V tag is present
              IF (ndimen(*oldv) EQ 1) THEN BEGIN
                ;;  1D --> no need to append
                IF ~ARRAY_EQUAL(oldv,(*thisdq.DH).V) THEN BEGIN
                  oldw                    = REPLICATE(!VALUES.F_NAN,[s1[0],s12])
                  newv                    = REPLICATE(!VALUES.F_NAN,[s2[0],s12])
                  oldw[*,0L:(s1[1] - 1L)] = REPLICATE(1.,s1[0]) # (*oldv)
                  IF (ndimen(*(*thisdq.DH).V) EQ 1) THEN *(*thisdq.DH).V = REPLICATE(1.,s2[0]) # (*(*thisdq.DH).V)
                  newv[*,0L:(s2[1] - 1L)] = *(*thisdq.DH).V
                  newv = PTR_NEW([oldw,newv])
                ENDIF ELSE newv = PTR_NEW(*oldv)
              ENDIF ELSE BEGIN
                ;;  2D --> need to append (IF present)
                IF (struct_value((*thisdq.DH),'v')) THEN BEGIN
                  ;;  present --> append
                  IF (ndimen(*(*thisdq.DH).V) EQ 1) THEN *(*thisdq.DH).V = REPLICATE(1.,s2[0]) # (*(*thisdq.DH).V)
                  IF (s1[1] NE s2[1]) THEN BEGIN
                    oldw                    = REPLICATE(!VALUES.F_NAN,[s1[0],s12])
                    newv                    = REPLICATE(!VALUES.F_NAN,[s2[0],s12])
                    oldw[*,0L:(s1[1] - 1L)] = *oldv
                    newv[*,0L:(s2[1] - 1L)] = *(*thisdq.dh).v
                    newv                    = PTR_NEW([oldw,newv])
                  ENDIF ELSE newv = PTR_NEW([*oldv,*(*thisdq.DH).V])
                ENDIF ELSE BEGIN
                  ;;  not present --> replicate old to make dimensions correct???
                  szdox                      = SIZE(*olddata.X,/DIMENSIONS)
                  szdnx                      = SIZE(*newx,/DIMENSIONS)
                  szdo                       = SIZE(*oldv,/DIMENSIONS)
                  dumb                       = MAKE_ARRAY(szdnx[0],szdo[1],TYPE=SIZE(*oldv,/TYPE))
                  avgo                       = TOTAL(*oldv,1,/NAN)/TOTAL(FINITE(*oldv),1,/NAN)
                  dumb[0L:(szdox[0] - 1L),*] = *oldv
                  FOR kk=0L, szdo[1] - 1L DO dumb[szdox[0]:(szdnx[0] - 1L),kk] = avgo[kk]
                  newv = PTR_NEW(dumb)
                ENDELSE
              ENDELSE
              ;  						IF ndimen(*oldv) eq 1 THEN $
              ;  							newv = PTR_NEW(*oldv) else $
              ;  							newv = PTR_NEW([*oldv,*(*thisdq.dh).v])
              IF (struct_value((*thisdq.DH),'v')) THEN PTR_FREE,(*thisdq.DH).V
              ;  						ptr_free,(*thisdq.dh).v
              newdata = {X:newx,Y:newy,V:newv}
              ;  					ENDIF else newdata={x: newx, y: newy}
            ENDIF ELSE BEGIN
              ;;  V tag is not present --> Only X and Y tags should be present
              newdata = {X:newx,Y:newy}
            ENDELSE
            olddata = 0
          ENDIF ELSE BEGIN
            ;;  Data Type NE 1
            newdata = olddata
            dattags = TAG_NAMES(olddata)
            FOR k=0L, N_ELEMENTS(dattags) - 1L DO BEGIN
               str_element,*thisdq.DH,dattags[k],foo
               foo   = *foo
               IF (SIZE(olddata,/TYPE) EQ 8) THEN BEGIN
                 str_element,olddata,dattags[k],boo
                 boo       = *boo
               ENDIF ELSE BEGIN
                 boo       = *olddata[k]
               ENDELSE
               str_element,newdata,dattags[k],[boo,foo],/ADD
            ENDFOR
          ENDELSE
          store_data,VERBOSE=verbose,thisdq.NAME,DATA=newdata
        ENDIF
      ENDIF ELSE BEGIN
        ;;  Do not append, just store data (overwrites old TPLOT data if TPLOT handle already defined)
        store_data,VERBOSE=verbose,thisdq.NAME,DATA=*thisdq.DH,LIMIT=*thisdq.LH,DLIMIT=*thisdq.DL,/NOSTRSW
        dprint,DLEVEL=3,'The tplot variable '+thisdq.NAME+' has been restored.'
      ENDELSE
      IF KEYWORD_SET(sort) THEN tplot_sort,thisdq.NAME
    ENDFOR
    PTR_FREE,dq.DH,dq.DL,dq.LH
  ENDIF
  ;;  Reset variables
  dq = 0
  tv = 0
ENDFOR

IF (N_ELEMENTS(restored_varnames) GT 1) THEN restored_varnames = restored_varnames[1:*]

;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END





