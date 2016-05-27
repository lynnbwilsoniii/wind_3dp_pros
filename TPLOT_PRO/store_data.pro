;+
;*****************************************************************************************
;
;  FUNCTION :   store_data.pro
;  PURPOSE  :   Store time series structures in static memory for later retrieval by the
;                 tplot routine.  Three structures can be associated with the string 
;                 'name':  a data structure (DATA) that typically contains the x and
;                 y data. A default limits structure (DLIMITS) and a user limits 
;                 structure (LIMITS) that will typically contain user defined 
;                 limits and options (typically plot and oplot keywords).  The 
;                 data structure and the default limits structure will be over written
;                 each time a new data set is loaded.  The limit structure is not 
;                 over-written.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               str_element.pro
;               find_handle.pro
;               tag_names_r.pro
;               array_union.pro
;               extract_tags.pro
;               minmax.pro
;               store_data.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NAME     :  Scalar string to be associated with the data structure
;                             and/or plot limit structure.  One can enter an index too.
;                             [Note:  NAME should NOT contain spaces or the characters
;                                      '*' and '?']
;
;  EXAMPLES:    
;               store_data,name,DATA=data,LIMITS=limits,DLIMITS=dlimits,$
;                               NEWNAME=newname,DELETE=delete
;
;  KEYWORDS:    
;               DATA     :  Set to a variable that contains the data structure to store
;               LIMITS   :  A structure containing the plot limit structure
;               DLIMITS  :  A structure containing the default plot limit structure
;               NEWNAME  :  Scalar string used to define new TPLOT handle(name)
;               MIN      :  If set, values less than this well be set to NaNs
;               MAX      :  If set, values greater than this well be set to NaNs
;               DELETE   :  Set to an array of TPLOT handles (or indices) to be deleted
;                             from the TPLOT list (common block)
;               VERBOSE  :  If set, program prints out information about the 
;                             TPLOT variable
;               NOSTRSW  :  If set, do not transpose multidimensional data arrays in
;                             structures [Default = transpose them]
;               DELALL   :  Set to a 2-element array of start and end TPLOT indices to 
;                             delete from the TPLOT list (common block)
;
;   NOTES:
;
;  SEE ALSO:
;               get_data.pro
;               tplot_names.pro
;               tplot.pro
;               options.pro
;
;   CHANGED:  1)  Peter Schroeder modified something...      [04/17/2002   v1.0.44]
;             2)  Added keyword:  DELALL                     [04/13/2008   v1.0.45]
;             3)  Re-wrote and cleaned up                    [08/11/2009   v1.1.0]
;             4)  Fixed syntax error produced when re-writing program
;                                                            [08/12/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/12/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO store_data,name,DATA=data,LIMITS=limits,DLIMITS=dlimits,NEWNAME=newname, $
                    MIN=min,MAX=max,DELETE=delete,VERBOSE=verbose,           $
                    NOSTRSW=nostrsw,DELALL=delall

;-----------------------------------------------------------------------------------------
; Set common blocks:
;-----------------------------------------------------------------------------------------
COMMON storeptrs,ptrlist,ptrnums
@tplot_com.pro
str_element,tplot_vars,'OPTIONS.VERBOSE',verbose

IF NOT KEYWORD_SET(ptrlist) THEN ptrlist = [PTR_NEW()]
IF NOT KEYWORD_SET(ptrnums) THEN ptrnums = [0]
;-----------------------------------------------------------------------------------------
; => If DELALL is set, delete appropriate TPLOT variables
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(delall) THEN BEGIN
  IF SIZE(delall,/L64,/N_DIMENSIONS) EQ 0 THEN BEGIN
    IF SIZE(delall,/TYPE,/L64) EQ 0 THEN BEGIN
      MESSAGE,'Improper keyword format:  DELALL (Invalid handle name or index)',/INFORMATION,/CONTINUE
      RETURN
    ENDIF ELSE BEGIN
      delete = delall
    ENDELSE
  ENDIF ELSE BEGIN
    CASE SIZE(delall,/L64,/N_DIMENSIONS) OF
      1 : BEGIN
        estart = delall[0]
        eend   = delall[1]
        delels = (eend-estart)+1
        delete = INTARR(delels)
        FOR i=0L, delels-1L DO delete[i] = estart + i
      END
      ELSE : BEGIN
        MESSAGE,'Improper keyword format:  DELALL (Improper dimensions)',/INFORMATION,/CONTINUE
        RETURN
      END
    ENDCASE
  ENDELSE
ENDIF 
;-----------------------------------------------------------------------------------------
; => If DELETE is set, delete appropriate TPLOT variables
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(delete) THEN BEGIN
  IF (N_ELEMENTS(name) NE 0) THEN delete = name
  FOR i=0L, N_ELEMENTS(delete) - 1L DO BEGIN
    dt = SIZE(delete[i],/TYPE)
    CASE dt[0] OF
      7L   : BEGIN
        index = find_handle(delete[i])
        name  = delete[i]
      END
      ELSE : BEGIN
        IF ((dt GE 1L) AND (dt LE 3L)) THEN BEGIN
          index = delete[i]
          name  = data_quants[index].NAME
          gtind = WHERE(delete GT index,count)
          IF (count NE 0) THEN delete[gtind] -= 1
        ENDIF ELSE BEGIN
          MESSAGE,'Improper keyword format:  DELETE (Invalid handle name or index)',/INFORMATION,/CONTINUE
        ENDELSE
      END
    ENDCASE
    ;-------------------------------------------------------------------------------------
    ; => Remove associated pointers from common blocks and TPLOT
    ;-------------------------------------------------------------------------------------
    IF (index EQ 0) THEN BEGIN
      PRINT,delete[i],' not a valid handle name'
    ENDIF ELSE BEGIN
      dq    = data_quants[index]
      names = STRSPLIT(dq.NAME,'.',/REGEX)
      dqtyp = SIZE(*dq.DH,/TYPE)
      IF (dqtyp EQ 8L) THEN BEGIN
        dqtags = tag_names_r(*dq.DH)
        nqts   = N_ELEMENTS(dqtags)
        FOR j=0L, nqts - 1L DO BEGIN
          str_element,*dq.DH,dqtags[j],foo
          pindx  = WHERE(ptrlist EQ foo,pnx,COMPLEMENT=pnindx,NCOMPLEMENT=pnnx)
          IF (ptrnums[pindx] EQ 1) THEN BEGIN
            PTR_FREE,foo
            ptrnums = ptrnums[pnindx]
            ptrlist = ptrlist[pnindx]
          ENDIF ELSE BEGIN
            ptrnums[pindx] -= 1        ; => Shift # of pointers down 1
          ENDELSE
        ENDFOR
      ENDIF
      PTR_FREE,dq.DH,dq.DL,dq.LH       ; => Clear pointers from IDL
      ind = WHERE(data_quants.NAME NE name,count)
      IF (count GT 0) THEN data_quants = data_quants[ind]
    ENDELSE
  ENDFOR
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Determine format of name input
;-----------------------------------------------------------------------------------------
dt  = SIZE(name,/TYPE)
ndn = SIZE(name,/N_DIMENSIONS)
IF (ndn NE 0) THEN BEGIN
  MESSAGE,'Improper input format:  NAME (must be a scalar value)',/INFORMATION,/CONTINUE
  RETURN
ENDIF
IF (dt[0] EQ 7L) THEN BEGIN          ; => Input was a TPLOT string handle
  test = TOTAL(array_union(BYTE(name),BYTE(' *?[]\')))
  ; => Note:  BYTE(' *?[]\') = [32,42,63,91,93,92]
  IF (test GE 0) THEN BEGIN
    MESSAGE,'Invalid name: "'+name+$
            '"; Name may not contain spaces, or the characters: "* ? [ ] \"',$
            /INFORMATION,/CONTINUE
    RETURN
  ENDIF
  n_quants = N_ELEMENTS(data_quants) EQ 0
  IF (n_quants) THEN index = 0 ELSE index = find_handle(name)
ENDIF ELSE BEGIN                     ; => " " integer handle
  IF ((dt GE 1) AND (dt LE 3)) THEN BEGIN
    index = name[0]
    name  = data_quants[index].NAME
  ENDIF ELSE BEGIN
    IF NOT KEYWORD_SET(delete) THEN BEGIN
      MESSAGE,'Invalid handle name or index: '+name,/INFORMATION,/CONTINUE
      RETURN
    ENDIF
  ENDELSE
ENDELSE
dq = {tplot_quant}    ; => force to be a structure
IF (N_ELEMENTS(data_quants) EQ 0) THEN data_quants = [dq]
;-----------------------------------------------------------------------------------------
; => Check index
;-----------------------------------------------------------------------------------------
IF (index EQ 0) THEN BEGIN
  orig_name      = name+'x'
  dq.NAME        = STRMID(orig_name,0,STRLEN(name))
  verb           = 'Creating'
  dq.LH          = PTR_NEW(0)
  dq.DL          = PTR_NEW(0)
  dq.DH          = PTR_NEW(0)
  data_quants    = [data_quants,dq]
  index          = N_ELEMENTS(data_quants) - 1L
  dq.CREATE_TIME = SYSTIME(1)
ENDIF ELSE BEGIN
  dq             = data_quants[index]
  verb           = 'Altering'
ENDELSE
;-----------------------------------------------------------------------------------------
; => Check MIN and MAX keywords
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(min) THEN BEGIN
  badlow = WHERE(data.Y LT min[0],clow)
  IF (clow GT 0) THEN data.Y[badlow] = !VALUES.F_NAN
ENDIF
IF KEYWORD_SET(max) THEN BEGIN
  badhigh = WHERE(data.Y GT max[0],chigh)
  IF (chigh GT 0) THEN data.Y[badhigh] = !VALUES.F_NAN
ENDIF
;-----------------------------------------------------------------------------------------
; => Define relevant TPLOT information for new data
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(newname) NE 0) THEN BEGIN
  test = TOTAL(array_union(BYTE(name),BYTE(' *?[]\')))
  ; => Note:  BYTE(' *?[]\') = [32,42,63,91,93,92]
  IF (test GE 0) THEN BEGIN
    MESSAGE,'Invalid name: "'+name+$
            '"; Name may not contain spaces, or the characters: "* ? [ ] \"',$
            /INFORMATION,/CONTINUE
    RETURN
  ENDIF
  nindex = WHERE(data_quants.NAME EQ newname,count)
  IF (count GT 0) THEN BEGIN
    MESSAGE,'Improper keyword format: NEWNAME (New name must not already be in use!)'
    RETURN
  ENDIF ELSE BEGIN
    dq.NAME = newname
  ENDELSE
ENDIF
;-----------------------------------------------------------------------------------------
; => Check LIMITS and DLIMITS keywords
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(limits) NE 0)  THEN *dq.LH = limits
IF (N_ELEMENTS(dlimits) NE 0) THEN *dq.DL = dlimits
;-----------------------------------------------------------------------------------------
; => Check DATA keyword
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(data) NE 0) THEN BEGIN
  IF (SIZE(data,/TYPE) EQ 8L) THEN BEGIN
    dq.CREATE_TIME = SYSTIME(1)
    IF KEYWORD_SET(verbose) THEN PRINT,verb+' tplot variable: ',dq.NAME
    mytags         = tag_names_r(data)
    myptrstr       = 0
    FOR i=0L, N_ELEMENTS(mytags) - 1L DO BEGIN
      str_element,data,mytags[i],foo
      footype = SIZE(foo,/TYPE) NE 10
      oldp    = PTR_NEW()
      str_element,*dq.DH,mytags[i],oldp
      IF (PTR_VALID(oldp)) THEN BEGIN
        oindx = WHERE(ptrlist EQ oldp,onx,COMPLEMENT=onindx,NCOMPLEMENT=onnx)
        pntst = ptrnums[oindx[0]] EQ 1
        IF (pntst) THEN BEGIN
          IF (onnx GT 0) THEN BEGIN
            ptrlist = ptrlist[onindx]
            ptrnums = ptrnums[onindx]
          ENDIF
          PTR_FREE,oldp                ; => Remove old pointer from TPLOT
        ENDIF ELSE BEGIN
          ptrnums[oindx] -= 1          ; => Shift pointer index number down by 1
        ENDELSE
      ENDIF
      ;-------------------------------------------------------------------------------------
      ;  =>  Check type of data being input
      ;-------------------------------------------------------------------------------------
      IF (footype) THEN BEGIN   ; => foo is not a pointer
        ptofoo = PTR_NEW(foo)
        str_element,myptrstr,mytags[i],ptofoo,/ADD_REPLACE
        ptrlist = [ptrlist,ptofoo]
        ptrnums = [ptrnums,1]
      ENDIF ELSE BEGIN          ; => foo is a pointer
        str_element,myptrstr,mytags[i],foo,/ADD_REPLACE
        pindx = WHERE(ptrlist EQ foo,cnt99)
        IF (cnt99 GT 0) THEN BEGIN
          ptrnums[pindx] += 1          ; => Shift pointer index number up by 1
        ENDIF ELSE BEGIN
          ptrlist = [ptrlist,foo]
          ptrnums = [ptrnums,1]
        ENDELSE
      ENDELSE
    ENDFOR
    *dq.DH = myptrstr
  ENDIF ELSE BEGIN
    *dq.DH = data
  ENDELSE
ENDIF
;-----------------------------------------------------------------------------------------
; => Get tags from data, dlimits, and limits and put into dstr
;-----------------------------------------------------------------------------------------
extract_tags,dstr,data
extract_tags,dstr,dlimits
extract_tags,dstr,limits
str_element,dstr,'X',VALUE=x
str_element,dstr,'Y',VALUE=y
str_element,dstr,'TIME',VALUE=time
xtyp = SIZE(x,/TYPE) EQ 10
ytyp = SIZE(y,/TYPE) EQ 10
ttyp = SIZE(time,/TYPE) EQ 10
IF (xtyp) THEN x    = *x         ; => X was a pointer
IF (ytyp) THEN y    = *y         ; => Y was a pointer
IF (ttyp) THEN time = *time      ; => TIME was a pointer
nnx = N_ELEMENTS(x)
nny = N_ELEMENTS(y)
nnt = N_ELEMENTS(time)
;-----------------------------------------------------------------------------------------
; => Redefine dq pointer quantities
;-----------------------------------------------------------------------------------------
IF (nnx NE 0 AND nny NE 0) THEN BEGIN
  dq.DTYPE  = 1
  dq.TRANGE = minmax(x)
ENDIF

IF (nnt NE 0) THEN BEGIN
  dq.DTYPE           = 2
  dq.TRANGE          = minmax(time)
  dqtags             = tag_names_r(*dq.DH)
  data_quants[index] = dq
  nqts               = N_ELEMENTS(dqtags)
  FOR i=0L, nqts - 1L DO BEGIN
    ttag = dqtags[i]
    IF (ttag NE 'TIME') THEN BEGIN
      subname = dq.NAME+'.'+ttag
      str_element,*dq.DH,ttag,foo
      ndim = SIZE(*foo,/N_DIMENSIONS) NE 1
      dims = SIZE(*foo,/DIMENSIONS)
      IF (ndim) THEN BEGIN
        IF (dims[0] NE N_ELEMENTS(time)) THEN BEGIN
          IF (KEYWORD_SET(nostrsw) EQ 0) THEN BEGIN
            *foo = TRANSPOSE(*foo)
          ENDIF
        ENDIF
      ENDIF
      store_data,subname,DATA={X:(*dq.DH).TIME,Y:foo},DLIMITS=*dq.DL,LIMITS=*dq.LH
    ENDIF
  ENDFOR
ENDIF
;-----------------------------------------------------------------------------------------
; => Check data and data type
;-----------------------------------------------------------------------------------------
ndata = N_ELEMENTS(data) NE 0
dtyp  = SIZE(data,/TYPE) EQ 7
IF (ndata) THEN IF (dtyp) THEN dq.DTYPE = 3
data_quants[index] = dq
RETURN
END
