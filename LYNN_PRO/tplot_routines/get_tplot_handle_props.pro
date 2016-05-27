;+
;*****************************************************************************************
;
;  FUNCTION :   check_handle_format.pro
;  PURPOSE  :   Determines whether an input TPLOT handle is formatted appropriately for
;                 TPLOT use.
;
;  CALLED BY:   
;               get_tplot_handle_props.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STRUCT  :  An IDL structure with at least the following two tags: X and Y
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  04/06/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/06/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION check_handle_format,struct

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f           = !VALUES.F_NAN
d           = !VALUES.D_NAN
; => Dummy error messages
noinpt_msg  = 'No input supplied...'
notstr_mssg = 'Must be an IDL structure...'
badstr_mssg = 'Not an appropriate TPLOT structure...'
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 1) THEN BEGIN
  ; => no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

str = struct[0]   ; => in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,notstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;-----------------------------------------------------------------------------------------
; => Examine input
;-----------------------------------------------------------------------------------------
tags   = STRLOWCASE(TAG_NAMES(str))
ntags  = N_TAGS(str)
testx  = WHERE(tags EQ 'x',gdx)
testy  = WHERE(tags EQ 'y',gdy)
true   = (gdx EQ 1) AND (gdy EQ 1)  ; => 1 = Good TPLOT structure, 0 = fail
;-----------------------------------------------------------------------------------------
; => Return result
;-----------------------------------------------------------------------------------------

RETURN,true
END


;+
;*****************************************************************************************
;
;  FUNCTION :   check_struct_tag_coord.pro
;  PURPOSE  :   Looks for quantities within an IDL structure defined by the input TAG.
;
;  CALLED BY:   
;               get_tplot_handle_props.pro
;
;  CALLS:
;               check_struct_tag_coord.pro
;               find_struc_values.pro
;               get_coord_list.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STRUCT  :  An IDL structure
;               TAG     :  Scalar string the user wishes to match to one of the structure
;                            tags or subtags
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  see also :  find_struc_values.pro
;
;   CREATED:  04/06/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/06/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION check_struct_tag_coord,struct,tag

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f           = !VALUES.F_NAN
d           = !VALUES.D_NAN
badstr_mssg = 'Not an appropriate structure tag...'
tagnotfound = 'No structure tags are associated with input TAG...'
;-----------------------------------------------------------------------------------------
; => Check for input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 1) THEN BEGIN
  ; => no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;-----------------------------------------------------------------------------------------
; => Check input format
;-----------------------------------------------------------------------------------------
str = struct[0]   ; => in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,notstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;-----------------------------------------------------------------------------------------
; => Get desired information
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(tag) THEN BEGIN
  ;;  user defined a string to search for
  stag     = IDL_VALIDNAME(tag[0])
  IF (stag EQ '') THEN BEGIN
    MESSAGE,badstr_mssg,/INFORMATIONAL,/CONTINUE
    ;;  use default tag
    RETURN, check_struct_tag_coord(str,'coord')
  ENDIF
  ;;  define upper/lower case versions
  low_tag = STRLOWCASE(stag[0])
  upp_tag = STRUPCASE(stag[0])
  struct_0 = find_struc_values(str,low_tag[0])
  IF (SIZE(struct_0,/TYPE) EQ 8L) THEN BEGIN
    all_cor    = get_coord_list()
    all_c      = all_cor.SHORT
    all_l      = all_cor.LONG
    all_coords = STRLOWCASE(REFORM([all_c.(0L),all_c.(1L),all_c.(2L),all_c.(3L),all_c.(4L)]))
    all_coordl = STRLOWCASE(REFORM([all_l.(0L),all_l.(1L),all_l.(2L),all_l.(3L),all_l.(4L)]))
    nn         = N_TAGS(struct_0)
    nc         = N_ELEMENTS(all_coords)
    j          = 0L
    FOR k=0L, nn - 1L DO BEGIN
      str_str = STRLOWCASE(struct_0.(k))
      ;;  check if name is long (e.g. 'GSE>Geocentric Solar Ecliptic')
      lon_str = STRLEN(str_str[0]) GT 5L
      REPEAT BEGIN
        sstring  = all_coords[j]
        IF (lon_str) THEN BEGIN
          ;;  input is longer than 5 characters
          lstring  = STRSPLIT(all_coordl[j],' ',/EXTRACT)
          spstrs   = STRPOS(str_str[0],sstring[0]) GE 0
          spstrl   = STRPOS(str_str[0],lstring[0]) GE 0
          test0    = spstrs AND spstrl
        ENDIF ELSE BEGIN
          ;;  input is longer ≤ 5 characters
;          spstr    = STRSPLIT(str_str[0],sstring[0],/REGEX)
;          test0    = N_ELEMENTS(spstr) GT 1
          test0    = STRPOS(str_str[0],sstring[0]) GE 0
        ENDELSE
        good     = WHERE(test0,gd)
        j       += (gd EQ 0L)
      ENDREP UNTIL ((gd GT 0L) OR (j EQ nc - 1L))
      IF (gd GT 0L) THEN BEGIN
        good_coord = STRUPCASE(all_coords[j])
        str_element,struc_out,upp_tag[0],good_coord[0],/ADD_REPLACE
      ENDIF
      IF (gd GT 0L) THEN BREAK
    ENDFOR
  ENDIF
ENDIF ELSE BEGIN
  ;;  tag not set, so use default
  RETURN, check_struct_tag_coord(str,'coord')
ENDELSE
;-----------------------------------------------------------------------------------------
; => Check output
;-----------------------------------------------------------------------------------------
IF (SIZE(struc_out,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,tagnotfound,/INFORMATIONAL,/CONTINUE
  struc_out = 0b
ENDIF
;-----------------------------------------------------------------------------------------
; => Return result
;-----------------------------------------------------------------------------------------
RETURN,struc_out
END


;+
;*****************************************************************************************
;
;  FUNCTION :   get_tplot_handle_props.pro
;  PURPOSE  :   Gets the relevant properties from an input TPLOT handle and returns them
;                 to the user.  The user specifies which properties to obtain using the
;                 associated keywords (see below).
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tnames.pro
;               get_data.pro
;               check_handle_format.pro
;               check_struct_tag_coord.pro
;               find_struc_values.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               HANDLE      :  TPLOT handle that the user desires information about
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               COORDS      :  If set, routine attempts to determine the coordinate
;                                system of the data associated with HANDLE and adds
;                                it to the output structure
;               UNITS       :  If set, routine attempts to determine the units of the
;                                data associated with HANDLE and adds them to the output
;                                structure
;               INSTRUMENT  :  If set, routine attempts to determine the instrument which
;                                measured the data and adds it to the output structure
;                                [** Not implemented yet **]
;               YTITLE      :  If set, routine checks for a Y-Axis title and adds
;                                it to the output structure
;               YSUBTITLE   :  If set, routine checks for a Y-Axis subtitle and adds
;                                it to the output structure
;               COLORS      :  If set, routine checks for colors associated with each
;                                component of HANDLE and adds them to the output
;                                [If HANDLE is a 1D line plot, this keyword is ignored]
;               LABELS      :  If set, routine checks for TPLOT labels associated with
;                                each component of HANDLE and adds them to the output
;                                [If HANDLE is a 1D line plot, this keyword is ignored]
;               FORMAT      :  If set, routine only checks the format of HANDLE to make
;                                sure it is a valid TPLOT handle
;                                [If /FORMAT, then all other keywords are ignored]
;               SPACECRAFT  :  If set, routine attempts to determine the spacecraft which
;                                measured the data and adds it to the output structure
;                                [** Not implemented yet **]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  TPLOT data must be loaded prior to calling this routine
;               2)  The routine checks the TPLOT format regardless of whether the
;                     FORMAT is set.  Only set this keyword if you do not want a
;                     structure on return, just a TRUE/FALSE result.
;
;   CREATED:  04/06/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/06/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_tplot_handle_props,handle,COORDS=coords,UNITS=units,INSTRUMENT=instrum,  $
                                       YTITLE=yttle,YSUBTITLE=ysubttle,COLORS=cols,   $
                                       LABELS=labs,FORMAT=form,SPACECRAFT=scraft

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
; => Dummy error messages
noinpt_msg = 'No input supplied...'
notstr_msg = 'Must be a [2]-element string array...'
nofint_msg = 'No finite data...'
nottpn_msg = 'Not valid TPLOT handles'
notidl_msg = 'DAT must be an array of IDL structures...'
nolims_msg = 'No TPLOT limits structure definitions...'
; => Define dummy list of coordinate system names
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 1) THEN BEGIN
  ; => no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;-----------------------------------------------------------------------------------------
; => Check HANDLE
;-----------------------------------------------------------------------------------------
hand       = handle[0]
check      = tnames(hand)
bad        = TOTAL(check EQ '') GT 0
IF (bad) THEN BEGIN
  ; => no input???
  MESSAGE,nottpn_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;-----------------------------------------------------------------------------------------
; => Get time series and format structure
;-----------------------------------------------------------------------------------------
t_name     = REFORM(handle)
get_data,t_name[0],DATA=tp_name0,ALIMITS_STR=alim_0
;-----------------------------------------------------------------------------------------
; => Check TPLOT structure format
;-----------------------------------------------------------------------------------------
test       = check_handle_format(tp_name0)
IF (KEYWORD_SET(form) OR test NE 1) THEN RETURN,test
;-----------------------------------------------------------------------------------------
; => Get desired information
;-----------------------------------------------------------------------------------------
IF (SIZE(alim_0,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,nolims_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;-----------------------------------------------------------------------------------------
; => Check for coordinates
;-----------------------------------------------------------------------------------------
g_coord = check_struct_tag_coord(alim_0,'coord')
IF (SIZE(g_coord,/TYPE) EQ 8L AND KEYWORD_SET(coords)) THEN BEGIN
  good_coord = g_coord.COORD
  str_element,struc_out,'COORD',good_coord[0],/ADD_REPLACE
ENDIF
;-----------------------------------------------------------------------------------------
; => Check for units
;-----------------------------------------------------------------------------------------
g_units = find_struc_values(alim_0,'unit')
IF (SIZE(g_units,/TYPE) EQ 8L AND KEYWORD_SET(units)) THEN BEGIN
  ;;  found tags associated with units
  nu = N_TAGS(g_units)
  IF (nu GT 1) THEN BEGIN
    ;;  more than one tag 
    s_arr = ''
    FOR j=0L, nu - 1L DO s_arr = [g_units.(j),s_arr[0]]
    bad   = WHERE(s_arr EQ '',bd,COMPLEMENT=good,NCOMPLEMENT=gd)
    IF (gd GT 0) THEN BEGIN
      s_arr = s_arr[good]
      l_arr = STRLOWCASE(s_arr)
      IF (SIZE(g_coord,/TYPE) EQ 8L) THEN BEGIN
        ;;  find one without coordinates
        gcord = STRLOWCASE(g_coord.COORD)
        g_arr = WHERE(STRPOS(l_arr,gcord[0]) LT 0,ga)
        IF (ga GT 0) THEN gunit = s_arr[g_arr[0]] ELSE gunit = s_arr[0]
      ENDIF ELSE BEGIN
        ;;  find one with less characters
        mnlen = MIN(STRLEN(s_arr),mln,/NAN)
        gunit = s_arr[mln[0]]
      ENDELSE
      str_element,struc_out,'UNITS',gunit[0],/ADD_REPLACE
    ENDIF
  ENDIF ELSE BEGIN
    ;;  only one tag
    str_element,struc_out,'UNITS',g_units.(0L),/ADD_REPLACE
  ENDELSE
ENDIF
;-----------------------------------------------------------------------------------------
; => Check for INSTRUMENT
;-----------------------------------------------------------------------------------------
;;  ** Not implemented yet **

;-----------------------------------------------------------------------------------------
; => Check for Y-axis title
;-----------------------------------------------------------------------------------------
g_yttl = find_struc_values(alim_0,'ytitle')
IF (SIZE(g_yttl,/TYPE) EQ 8L AND KEYWORD_SET(yttle)) THEN BEGIN
  ;;  use first found
  str_element,struc_out,'YTITLE',g_yttl.(0L),/ADD_REPLACE
ENDIF
;-----------------------------------------------------------------------------------------
; => Check for Y-axis subtitle
;-----------------------------------------------------------------------------------------
g_ysub = find_struc_values(alim_0,'ysubtitle')
IF (SIZE(g_ysub,/TYPE) EQ 8L AND KEYWORD_SET(ysubttle)) THEN BEGIN
  ;;  use first found
  str_element,struc_out,'YSUBTITLE',g_ysub.(0L),/ADD_REPLACE
ENDIF
;-----------------------------------------------------------------------------------------
; => Check for COLORS
;-----------------------------------------------------------------------------------------
g_cols = find_struc_values(alim_0,'colors')
IF (SIZE(g_cols,/TYPE) EQ 8L AND KEYWORD_SET(cols)) THEN BEGIN
  ;;  use first found
  str_element,struc_out,'COLORS',g_cols.(0L),/ADD_REPLACE
ENDIF
;-----------------------------------------------------------------------------------------
; => Check for LABELS
;-----------------------------------------------------------------------------------------
g_labs = find_struc_values(alim_0,'labels')
IF (SIZE(g_labs,/TYPE) EQ 8L AND KEYWORD_SET(labs)) THEN BEGIN
  ;;  use first found
  str_element,struc_out,'LABELS',g_labs.(0L),/ADD_REPLACE
ENDIF
;-----------------------------------------------------------------------------------------
; => Check for SPACECRAFT
;-----------------------------------------------------------------------------------------
;;  ** Not implemented yet **

;-----------------------------------------------------------------------------------------
; => Check output
;-----------------------------------------------------------------------------------------
IF (SIZE(struc_out,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,tagnotfound,/INFORMATIONAL,/CONTINUE
  struc_out = 0b
ENDIF
;-----------------------------------------------------------------------------------------
; => Return result
;-----------------------------------------------------------------------------------------
RETURN,struc_out
END
