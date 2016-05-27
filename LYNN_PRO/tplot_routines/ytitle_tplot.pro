;+
;*****************************************************************************************
;
;  FUNCTION :   ytitle_tplot.pro
;  PURPOSE  :   Returns either the set Y-Axis title for the given input TPLOT handle
;                 or alters the predefined TPLOT handle Y-Title by adding a
;                 desired string onto the end of the original.
;
;  CALLED BY:   
;               energy_remove_split.pro
;               clean_spec_spikes.pro
;               spec_2dim_shift.pro
;               spec_3dim_shift.pro
;
;  CALLS:
;               tnames.pro
;               get_data.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NAME     :  Scalar string specifying the TPLOT handle for which one
;                             wants to find or alter the corresponding Y-Title
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               EX_STR   :  Scalar or array of strings to add onto the existing Y-Axis
;                             title.  If EX_STR is a 2-element array, then the end 
;                             result will be:  
;                                  yttl0 = dat.YTITLE
;                                  yttl1 = yttl0+'!C'+ex_str[0]+'!C'+ex_str[1]
;               PRE_STR  :  Scalar string to add as prefix to existing Y-Title
;                             [Note:  No '!C' is added]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Be careful NOT to add too much onto the Y-Axis title if using
;                     the EX_STR keyword.  Doing so may negatively alter margins
;                     or produce outputs without Y-Axis titles.
;
;   CREATED:  10/07/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/07/2008   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION ytitle_tplot,name,EX_STR=ex_str,PRE_STR=pre_str

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
; => Define default tag names for 3D Spectra TPLOT Variables
dum3dt     = ['YTITLE','X','Y','V1','V2','YLOG','LABELS','PANEL_SIZE']
; => Define default tag names for 2D Spectra TPLOT Variables
dum2dt     = ['X','Y','V']
def_3d_str = 0                   ; => Logic:  1 if default 3D structure ELSE 0
def_labs   = ''                  ; => Dummy array of default labels
dumytag    = 'YTITLE'
tags       = ['T0','T1','T2']
IF KEYWORD_SET(ex_str) THEN BEGIN
  nsuff = N_ELEMENTS(ex_str)
  suffx = ''
  ; => Prevent Y-Title from getting too long
  IF (nsuff GT 3L) THEN ex_str = ex_str[0:2]
  FOR j=0L, nsuff - 1L DO suffx += '!C'+ex_str[j]
ENDIF ELSE suffx = ''

IF KEYWORD_SET(pre_str) THEN pre_x = pre_str[0] ELSE pre_x = ''
;-----------------------------------------------------------------------------------------
; -Make sure name is either a tplot index or tplot string name
;-----------------------------------------------------------------------------------------
n_check = (SIZE(name,/TYPE) GT 1L) AND (SIZE(name,/TYPE) LT 8L) AND $
          (SIZE(name,/TYPE) NE 6L)
CASE n_check[0] OF
  1    : BEGIN
    gname = (tnames(name[0]))[0]
  END
  ELSE : BEGIN
    MESSAGE,'Incorrect input format:  NAME must be a string or integer',/INFORMATION,/CONTINUE
    RETURN,''
  END
ENDCASE
; => Get TPLOT structure info
get_data,gname,DATA=dat,DLIM=dlim,LIM=lim
;-----------------------------------------------------------------------------------------
; -Make sure dat is a structure
;-----------------------------------------------------------------------------------------
mtags       = ''           ; => Structure tags
glimtags    = ''           ; => Plot LIMIT structure tags
gdeftags    = ''           ; => Default TPLOT LIMIT structure tags
ntags       = 0            ; => Number of tags for structure d

IF (SIZE(dat,/TYPE) NE 8) THEN BEGIN
  MESSAGE,'Incorrect input format:  NAME must be a TPLOT handle',/INFORMATION,/CONTINUE
  RETURN,''
ENDIF
mtags       = STRLOWCASE(TAG_NAMES(dat))
ntags       = N_TAGS(dat)
IF (SIZE(dlim,/TYPE) NE 8) THEN gdeftags = '' ELSE gdeftags = STRLOWCASE(TAG_NAMES(dlim))
IF (SIZE(lim,/TYPE)  NE 8) THEN glimtags = '' ELSE glimtags = STRLOWCASE(TAG_NAMES(lim))
;-----------------------------------------------------------------------------------------
; => Determine where or if YTITLE is set
;-----------------------------------------------------------------------------------------
tplot_datch = WHERE(mtags    EQ STRLOWCASE(dumytag),gdatch)
tplot_dlmch = WHERE(gdeftags EQ STRLOWCASE(dumytag),gdlmch)
tplot_limch = WHERE(glimtags EQ STRLOWCASE(dumytag),glimch)
good        = WHERE([gdatch,gdlmch,glimch] GT 0,gd)

tag_str     = CREATE_STRUCT(tags,mtags,gdeftags,glimtags)
str_str     = CREATE_STRUCT(tags,dat,dlim,lim)
chk_str     = CREATE_STRUCT(tags,tplot_datch,tplot_dlmch,tplot_limch)
;-----------------------------------------------------------------------------------------
; => Define new YTITLE
;-----------------------------------------------------------------------------------------
IF (gd GT 0) THEN BEGIN
  IF (gd GT 1) THEN BEGIN
    CASE good[0] OF
      1    : BEGIN
        ; => Extra YTITLE tag is in the Default Limits structure
        gddd = good[1]
      END
      ELSE : BEGIN
        ; => Extra YTITLE tag is in the plot Limits structure or TPLOT structure
        gddd = good[0]
      END
    ENDCASE
  ENDIF ELSE gddd = good
  g_strs  = str_str.(gddd[0])        ; => The structure with the YTITLE tag
  g_yels  = chk_str.(gddd[0])[0]     ; => Tag element corresponding to the YTITLE tag
  yttle0  = g_strs.(g_yels)[0]       ; => The value associated with g_yels tag
  n_yttle = pre_x+yttle0+suffx
ENDIF ELSE BEGIN
  MESSAGE,'No previous Y-Title:  Using TPLOT handle...',/INFORMATION,/CONTINUE
  n_yttle = pre_x+gname
ENDELSE

RETURN,n_yttle
END