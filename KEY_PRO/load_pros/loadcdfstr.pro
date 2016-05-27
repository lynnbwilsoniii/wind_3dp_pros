;+
;*****************************************************************************************
;
;  FUNCTION :   loadcdfstr.pro
;  PURPOSE  :   Loads data from a specified cdf file into an IDL data structure.
;
;  CALLED BY:   
;               loadallcdf.pro
;
;  CALLS:
;               cdf_info.pro
;               append_array.pro
;               str_element.pro
;               loadcdf2.pro
;               average_str.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA0        :  A named variable to return as the structure
;               NOVARDATA    :  A named variable to return the non-varying data
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               FILENAMES    :  String array of CDF filenames (or file id's)
;               PATH         :  Scalar string defining the file path
;               VARNAMES     :  String array of CDF variable name[s] to be loaded
;               TAGNAMES     :  Optional string array of structure tag names
;               NOVARNAMES   :  String array of CDF non-varying field names
;               RESOLUTION   :  Scalar value defining the time resolution of the returned
;                                 data in seconds
;               MEDIAN       :  
;               FILTER_PROC  :  
;               APPEND       :  If set, append CDF data to the end of DATA0
;               TIME         :  If set, will create tag TIME using the Epoch variable.
;
;   CHANGED:  1)  Davin Larson created
;                                                                  [??/??/????   v1.0.0]
;             2)  Davin Larson changed something...
;                                                                  [04/17/2002   v1.0.22]
;             3)  Re-wrote and cleaned up
;                                                                  [06/08/2011   v1.1.0]
;             4)  Fixed typo relating to ZVARS in CDF
;                                                                  [09/01/2011   v1.1.1]
;             5)  Fixed an issue created by a newer version of cdf_info.pro which no
;                   longer returns a structure with the tag name NVARS
;                                                                  [01/24/2014   v1.1.2]
;
;   NOTES:      
;               1)  FILENAMES can contain the full path to the data files, otherwise
;                     program requires PATH to be set
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  01/24/2014   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO loadcdfstr,data0,novardata,FILENAMES=cdf_files,PATH=path,             $
               VARNAMES=cdf_vars,TAGNAMES=tagnames,NOVARNAMES=novarnames, $
               RESOLUTION=res,MEDIAN=med,FILTER_PROC=filter_proc,         $
               APPEND=append,TIME=time

;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(cdf_files) EQ 0) THEN cdf_files = PICKFILE(FILTER="*.cdf",PATH=path,GET_PATH=path)
IF KEYWORD_SET(append) THEN index = N_ELEMENTS(data0)

FOR num=0L, N_ELEMENTS(cdf_files) - 1L DO BEGIN
  cdf_file = cdf_files[num]
  id       = 0
  cdftype  = SIZE(cdf_file,/TYPE)
  IF (cdftype EQ 7) THEN id = CDF_OPEN(cdf_file) ELSE id = cdf_file
;   if data_type(cdf_file) eq 7 then id = cdf_open(cdf_file) else id = cdf_file
  IF NOT KEYWORD_SET(silent) THEN PRINT,'Loading ',cdf_file
  ;;--------------------------------------------------------------------------------------
  ;;  Get CDF information
  ;;--------------------------------------------------------------------------------------
  inq = cdf_info(id)
  IF NOT KEYWORD_SET(cdf_vars) THEN BEGIN     ;get only variables that vary
    ;;------------------------------------------------------------------------------------
    ;;  Check return from cdf_info.pro
    ;;------------------------------------------------------------------------------------
    IF (SIZE(inq,/TYPE) EQ 8) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Check for NVARS tag
      ;;----------------------------------------------------------------------------------
      test_nv  = TOTAL(STRLOWCASE(TAG_NAMES(inq)) EQ 'nvars') EQ 0
      IF (test_nv) THEN BEGIN
        ;;  NVARS tag does not exist
        test_nv  = TOTAL(STRLOWCASE(TAG_NAMES(inq)) EQ 'nv') EQ 1
        IF (test_nv) THEN BEGIN
          ;;  NV tag exists
          FOR n=0L, inq.NV - 1L DO BEGIN
            vinq = CDF_VARINQ(id,n,ZVAR=inq.VARS[n].IS_ZVAR[0])
            IF (vinq.RECVAR EQ 'VARY') THEN append_array,cdf_vars,vinq.NAME
          ENDFOR
        ENDIF
      ENDIF ELSE BEGIN
        ;;  NVARS tag exists
        FOR n=0L, inq.NVARS - 1L DO BEGIN
          vinq = CDF_VARINQ(id,n)
          IF (vinq.RECVAR EQ 'VARY') THEN append_array,cdf_vars,vinq.NAME
        ENDFOR
      ENDELSE
      ;;----------------------------------------------------------------------------------
      ;;  Check for NZVARS tag
      ;;----------------------------------------------------------------------------------
      test_nv  = TOTAL(STRLOWCASE(TAG_NAMES(inq)) EQ 'nzvars') EQ 0
      IF (test_nv) THEN BEGIN
        ;;  NVARS tag does not exist => do nothing
      ENDIF ELSE BEGIN
        FOR n=0L, inq.NZVARS - 1L DO BEGIN
          vinq = CDF_VARINQ(id,n,/ZVAR)
          IF (vinq.RECVAR EQ 'VARY') THEN append_array,cdf_vars,vinq.NAME
        ENDFOR
      ENDELSE
    ENDIF
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Check for structure tag name definitions/preferences
  ;;--------------------------------------------------------------------------------------
  IF NOT KEYWORD_SET(tagnames) THEN tagnames = cdf_vars
  nvars    = N_ELEMENTS(cdf_vars)
  tagnames = STRCOMPRESS(tagnames,/REMOVE_ALL)
  IF NOT KEYWORD_SET(data0) THEN append = 0
  IF NOT KEYWORD_SET(append) THEN BEGIN      ;define the data structure:
;      if keyword_set(time) then dat = {TIME:0.d}
    FOR n=0L, nvars - 1L DO BEGIN
        vinq  = CDF_VARINQ(id,cdf_vars[n])
        ;;--------------------------------------------------------------------------------
        ;;  LBW III 06/08/2011
        ;;--------------------------------------------------------------------------------
        ;;  Determine data type
        CASE vinq.DATATYPE OF
          'CDF_REAL8' :   value = !VALUES.D_NAN
          'CDF_DOUBLE':   value = !VALUES.D_NAN
          'CDF_REAL4' :   value = !VALUES.F_NAN
          'CDF_FLOAT' :   value = !VALUES.F_NAN
          'CDF_INT4'  :   value = 0L
          'CDF_INT2'  :   value = 0
          'CDF_INT1'  :   value = 0b
          'CDF_UINT1' :   value = 0b
          'CDF_CHAR'  :   value = 0b
          'CDF_UCHAR' :   value = 0b
          'CDF_EPOCH' :   value = !VALUES.D_NAN
          ELSE        :   MESSAGE ,'Invalid type,  please fix source...'
        ENDCASE
        ;;--------------------------------------------------------------------------------
        ;;  Check structure tags
        ;;--------------------------------------------------------------------------------
        testv = STRLOWCASE(TAG_NAMES(vinq))
        testi = STRLOWCASE(TAG_NAMES(inq))
        goodv = WHERE(testv EQ 'dim',gdv)
        goodi = WHERE(testi EQ 'dim',gdi)
        gdinq = WHERE(testi EQ 'inq',gdq)
        gdvar = WHERE(testv EQ 'dimvar',gvv)  ;;  LBW III 09/01/2011
        IF (gdv EQ 0 AND gdi EQ 0) THEN BEGIN
          IF (gdq GT 0) THEN idim = inq.INQ.DIM ELSE idim = [0L]
          vdim = [0L]
        ENDIF ELSE BEGIN
          IF (gdv EQ 0 OR gdi EQ 0) THEN BEGIN
            IF (gdv EQ 0) THEN BEGIN
              vdim = [0L]
              idim = inq.DIM
            ENDIF ELSE BEGIN
              idim = [0L]
              vdim = vinq.DIM
            ENDELSE
          ENDIF ELSE BEGIN
            vdim = vinq.DIM
            idim = inq.DIM
          ENDELSE
        ENDELSE
        IF (gvv GT 0) THEN vvar = vinq.DIMVAR ELSE vvar = [0L]  ;;  LBW III 09/01/2011
        IF (vinq.IS_ZVAR) THEN dim = vdim ELSE dim = idim*vvar  ;;  LBW III 09/01/2011
;          IF (vinq.IS_ZVAR) THEN dim = vdim ELSE dim = idim*vdim
;          if vinq.is_zvar then dim = vinq.dim else dim = inq.dim*vinq.dimvar
        ;;--------------------------------------------------------------------------------
        ;;  LBW III 06/08/2011
        ;;--------------------------------------------------------------------------------
        w = WHERE(dim,ndim)
        IF (ndim GT 0) THEN dim = dim[w] ELSE dim = 0
;print,cdf_vars(n),ndim,dim
        IF (ndim GT 0) THEN dim = dim[w] ELSE dim = 0
        IF (ndim GT 0) THEN val = MAKE_ARRAY(VALUE=value,DIM=dim) ELSE val = value
        a  = STRPOS(tagnames[n],'%')
        aa = STRPOS(tagnames[n],'*')
        IF (a NE -1) THEN BEGIN
          b           = STRLEN(tagnames[n])
          oldname     = tagnames[n]
          tagnames[n] = STRMID(oldname,0,a)+'q'+STRMID(oldname,a+1,b)
        ENDIF
        IF (aa NE -1) THEN BEGIN
          b           = STRLEN(tagnames[n])
          oldname     = tagnames[n]
          tagnames[n] = STRMID(oldname,0,aa)+'x'+STRMID(oldname,aa+1,b)
        ENDIF
        str_element,dat,tagnames[n],val,/ADD_REPLACE
    ENDFOR
    IF KEYWORD_SET(time) THEN BEGIN
      w = WHERE(TAG_NAMES(dat) EQ 'TIME',c)
      IF (c EQ 0) THEN str_element,dat,'TIME',0d0,/ADD_REPLACE
    ENDIF
  ENDIF ELSE BEGIN
    dat = data0[0]
  ENDELSE
  vinq   = CDF_VARINQ(id,cdf_vars[0])
  !QUIET = 1
  CDF_CONTROL,id,VARIABLE=cdf_vars[0],GET_VAR_INFO=varinfo,ZVAR=vinq.IS_ZVAR
  !QUIET = 0
  nrecs  = varinfo.MAXREC + 1
  data   = REPLICATE(dat,nrecs)
  del    = 0
  IF KEYWORD_SET(time) THEN BEGIN
    test0 = CDF_ATTEXISTS(id,'DEPEND_0',cdf_vars[0],ZVAR=vinq.IS_ZVAR)
    IF (test0) THEN BEGIN
      CDF_ATTGET,id,'DEPEND_0',cdf_vars[0],epochnum,ZVAR=vinq.IS_ZVAR
    ENDIF ELSE BEGIN
      IF (SIZE(inq,/TYPE) EQ 8) THEN BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Check for NVARS tag
        ;;--------------------------------------------------------------------------------
        test_nv  = TOTAL(STRLOWCASE(TAG_NAMES(inq)) EQ 'nvars') EQ 0
        IF (test_nv) THEN BEGIN
          ;;  NVARS tag does not exist
          test_nv  = TOTAL(STRLOWCASE(TAG_NAMES(inq)) EQ 'nv') EQ 1
          IF (test_nv) THEN BEGIN
            ;;  NV tag exists
            FOR thisvar=0L, inq.NV - 1L DO BEGIN
              vinq = CDF_VARINQ(id,thisvar,ZVAR=inq.VARS[thisvar].IS_ZVAR[0])
              IF (vinq.DATATYPE EQ 'CDF_EPOCH') THEN epochnum = vinq.NAME
            ENDFOR
          ENDIF
        ENDIF ELSE BEGIN
          ;;  NVARS tag exists
          FOR thisvar=0L, inq.NVARS - 1L DO BEGIN
            vinq = CDF_VARINQ(id,thisvar)
            IF (vinq.DATATYPE EQ 'CDF_EPOCH') THEN epochnum = vinq.NAME
          ENDFOR
        ENDELSE
        ;;--------------------------------------------------------------------------------
        ;;  Check for NZVARS tag
        ;;--------------------------------------------------------------------------------
        IF (N_ELEMENTS(epochnum) EQ 0) THEN BEGIN
          test_nv  = TOTAL(STRLOWCASE(TAG_NAMES(inq)) EQ 'nzvars') EQ 1
          IF (test_nv) THEN BEGIN
            FOR thisvar=0L, inq.NZVARS - 1L DO BEGIN
              vinq = CDF_VARINQ(id,thisvar,/ZVAR)
              IF (vinq.DATATYPE EQ 'CDF_EPOCH') THEN epochnum = vinq.NAME
            ENDFOR
          ENDIF
        ENDIF
      ENDIF
    ENDELSE
    ;;------------------------------------------------------------------------------------
    ;;  Load CDF file
    ;;------------------------------------------------------------------------------------
    loadcdf2,id,epochnum,x
    epoch0    = 719528d0*24d0*36d2*1d3  ;; Jan 1, 1970
    data.TIME = (x - epoch0)/1d3
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  FOR n=0L, nvars - 1L DO BEGIN
    test0 = CDF_ATTEXISTS(id,'DEPEND_0',cdf_vars[n],ZVAR=vinq.IS_ZVAR)
    IF (test0) THEN BEGIN
      CDF_ATTGET,id,'DEPEND_0',cdf_vars[n],thisepoch,ZVAR=vinq.IS_ZVAR
    ENDIF ELSE BEGIN
      thisepoch = epochnum
    ENDELSE
    IF (n EQ 0 AND NOT KEYWORD_SET(time)) THEN epochnum = thisepoch
    IF (STRPOS(tagnames[n],'Epoch') NE -1) THEN thisepoch = tagnames[n]
    IF (thisepoch EQ epochnum) THEN BEGIN
      loadcdf2,id,cdf_vars[n],x,/NO_SHIFT,NRECS=nrecs
      test0 = CDF_ATTEXISTS(id,'FILLVAL',cdf_vars[n],ZVAR=vinq.IS_ZVAR)
      IF (test0) THEN BEGIN
        CASE SIZE(x,/TYPE) OF
          4L   : nan = !VALUES.F_NAN
          5L   : nan = !VALUES.D_NAN
          ELSE : nan = 0
        ENDCASE
        IF (nan NE 0) THEN BEGIN
          CDF_ATTGET,id,'FILLVAL',cdf_vars[n],fv,ZVAR=vinq.IS_ZVAR
          fvindx = WHERE(x EQ fv,fvcnt)
          IF (fvcnt GT 0) THEN x[fvindx] = nan
        ENDIF
      ENDIF
      str_element,data,tagnames[n],x,/ADD_REPLACE
    ENDIF ELSE BEGIN
      PRINT,'Variable '+cdf_vars[n]+' has different Epoch'
    ENDELSE
  ENDFOR
  ;;--------------------------------------------------------------------------------------
  ;;  Check input
  ;;--------------------------------------------------------------------------------------
  IF (num EQ 0 AND KEYWORD_SET(novarnames)) THEN BEGIN
    novardata = 0
    novartags = STRCOMPRESS(novarnames,/REMOVE_ALL)
    FOR i=0L, N_ELEMENTS(novarnames) - 1L DO BEGIN
      loadcdf2,id,novarnames[i],val
      str_element,novardata,novartags[i],val,/ADD_REPLACE
    ENDFOR
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Close CDF file
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(cdf_file,/TYPE) EQ 7) THEN CDF_CLOSE,id
  ;;  If user desires, filter the data
  IF KEYWORD_SET(filter_proc) THEN CALL_PROCEDURE,filter_proc,data
  IF KEYWORD_SET(res) THEN data = average_str(data,res,/NAN,MEDIAN=med)
  append_array,data0,data,INDEX=index
  append = 1
  ;======================================================================================
  SKIP:
  ;======================================================================================
  IF (id EQ 0) THEN PRINT,'Unable to open file: ',cdf_file
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Append data to end of array if desired
;;----------------------------------------------------------------------------------------
append_array,data0,INDEX=index,/DONE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END



