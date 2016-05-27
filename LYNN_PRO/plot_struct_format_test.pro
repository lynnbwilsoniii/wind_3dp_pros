;+
;*****************************************************************************************
;
;  FUNCTION :   plot_struct_format_test.pro
;  PURPOSE  :   This program can help the user define plot routine keyword structures.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               plot_keyword_lists.pro
;               array_where.pro
;               struct_new_el_add.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STRUCT      :  IDL structure with tags acceptable by one of the
;                                IDL plotting routines listed below in the keywords.
;
;  OUTPUT:
;               [1,0]       :  For use of any ONE keyword except REMOVE_BAD and EXCEPT
;               IDL Struct  :  For use of REMOVE_BAD or EXCEPT with appropriate plot
;                                type keyword
;
;  EXAMPLES:    
;               oldstr = {XRANGE:[0.,1.],YTITLE:'Dependent Data',XSTYLE:1}
;               ;+++++++++++++++++++++++++++++++++++
;               ; => Example of using EXCEPT keyword
;               ;+++++++++++++++++++++++++++++++++++
;               test = plot_struct_format_test(oldstr,EXCEPT='YTITLE',/PLOT)
;               ;++++++++++++++++++++++++++++++++++++++++
;               ; => Example of using REMOVE_BAD keyword
;               ;++++++++++++++++++++++++++++++++++++++++
;               oldstr = {XRANGE:[0.,1.],YTITLE:'Dependent Data',ZEBRA:1}
;               test   = plot_struct_format_test(oldstr,/REMOVE_BAD,/PLOT)
;
;  KEYWORDS:    
;               OPLOT       :  If set, tells IDL to use the keywords associated with 
;                                OPLOT
;               PLOT        :  If set, tells IDL to use the keywords associated with 
;                                PLOT
;               SPLOT       :  If set, tells IDL to use the keywords associated with 
;                                PLOTS
;               CONTOUR     :  If set, tells IDL to use the keywords associated with 
;                                CONTOUR
;               AXIS        :  If set, tells IDL to use the keywords associated with 
;                                AXIS
;               SCALE3      :  If set, tells IDL to use the keywords associated with 
;                                SCALE3
;               SURFACE     :  If set, tells IDL to use the keywords associated with 
;                                SURFACE
;               SHADE_SURF  :  If set, tells IDL to use the keywords associated with 
;                                SHADE_SURF
;               REMOVE_BAD  :  If set, routine removes bad keyword values from return
;                                structure
;               EXCEPT      :  String array of keywords to exclude from return
;                                structure
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See IDL documentation for more information about acceptable keywords
;                     for each relevant plotting routine.
;               2)  The appropriate IDL structure format should match what one would
;                     pass to any of the above listed plotting routines using
;                     _EXTRA=[structure].
;
;   CREATED:  03/09/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/09/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION plot_struct_format_test,struct,OPLOT=oplt,PLOT=plt,SPLOT=plts,CONTOUR=contr,$
                                 AXIS=axs,SCALE3=scl3,SURFACE=surfc,SHADE_SURF=shsurf,$
                                 REMOVE_BAD=rmvbad,EXCEPT=excpts

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
notstr_mssg    = 'Must be an IDL structure...'
badkey_mssg    = 'Incorrect use of keywords:  Only one plot type per call...'
notag_mssg     = 'Structure tags in keyword EXCEPT do not exist... Using existing values'
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF N_PARAMS() EQ 0 THEN RETURN,0b
str = struct[0]   ; => in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,notstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;-----------------------------------------------------------------------------------------
; => Define dummy variables and check input
;-----------------------------------------------------------------------------------------
s_tags = STRLOWCASE(TAG_NAMES(str))
nts    = N_TAGS(str)
;-----------------------------------------------------------------------------------------
; => Check Keywords
;-----------------------------------------------------------------------------------------
keyws = [KEYWORD_SET(oplt),KEYWORD_SET(plt),KEYWORD_SET(plts),KEYWORD_SET(contr),$
         KEYWORD_SET(axs),KEYWORD_SET(scl3),KEYWORD_SET(surfc),KEYWORD_SET(shsurf)]
test  = TOTAL(keyws) NE 1
IF (test) THEN BEGIN
  MESSAGE,badkey_mssg,/INFORMATIONAL,/CONTINUE
  ; => Set default of PLOT = 1
  oplt   = 0
  plt    = 1
  plts   = 0
  contr  = 0
  axs    = 0
  scl3   = 0
  surfc  = 0
  shsurf = 0
ENDIF
gtags = plot_keyword_lists(OPLOT=oplt,PLOT=plt,SPLOT=plts,CONTOUR=contr,$
                           AXIS=axs,SCALE3=scl3,SURFACE=surfc,SHADE_SURF=shsurf)
; => Check input structure tags against accepted tags
good  = array_where(s_tags,gtags,/N_UNIQ,NCOMP1=comp1,NCOMP2=comp2)
;-----------------------------------------------------------------------------------------
; => Remove keywords not acceptable by chosen plotting routine
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(rmvbad) THEN BEGIN
  IF (good[0] LT 0) THEN RETURN,0
  gels   = REFORM(good[*,0])
  gstags = s_tags[gels]
  ; => create new structure made of good elements of old
  struct_new_el_add,'',0d0,str,newstruct,GOLD_T=gstags
  RETURN,newstruct
ENDIF
;-----------------------------------------------------------------------------------------
; => Keep all tags except those defined by EXCEPT keyword
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(excpts) THEN BEGIN
  ecpts  = STRLOWCASE(excpts)
  bad    = array_where(s_tags,ecpts,/N_UNIQ,NCOMP1=comp1,NCOMP2=comp2)
  nc1    = N_ELEMENTS(comp1)
  IF (bad[0] LT 0) THEN BEGIN
    MESSAGE,notag_mssg,/INFORMATIONAL,/CONTINUE
    gels   = LINDGEN(nts)
  ENDIF ELSE BEGIN
    IF (nc1 EQ 0) THEN BEGIN
      ; => Every tag is matched by the user defined exceptions
      RETURN,0
    ENDIF ELSE BEGIN
      gels   = comp1
    ENDELSE
  ENDELSE
  gstags = s_tags[gels]
  ; => create new structure made of good elements of old
  struct_new_el_add,'',0d0,str,newstruct,GOLD_T=gstags
  RETURN,newstruct
ENDIF
;-----------------------------------------------------------------------------------------
; => Test input structure
;-----------------------------------------------------------------------------------------
IF (good[0] LT 0) THEN RETURN,0 ELSE RETURN,struct

END

