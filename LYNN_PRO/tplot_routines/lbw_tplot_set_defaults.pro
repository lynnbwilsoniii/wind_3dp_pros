;+
;*****************************************************************************************
;
;  PROCEDURE:   lbw_tplot_set_defaults.pro
;  PURPOSE  :   This routine defines default settings for TPLOT for the preferences of
;                 Lynn B. Wilson III.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               tnames.pro
;               tplot_options.pro
;               options.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS 8.0 or SPEDAS 1.0 (or greater) IDL libraries or
;                     UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               lbw_tplot_set_defaults
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Changed default XMARGIN and LABFLAG settings and
;                   updated Man. page
;                                                                   [10/23/2015   v1.0.1]
;
;   NOTES:      
;               1)  This routine requires that TPLOT data be loaded before options are set
;               2)  See also:  tnames.pro, tplot_options.pro, options.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/07/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/23/2015   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO lbw_tplot_set_defaults

;;  Let IDL know that the following are functions
FORWARD_FUNCTION tnames
;;----------------------------------------------------------------------------------------
;;  Define default values
;;----------------------------------------------------------------------------------------
def_verbose    = 2
def_nointer    = 0
def___thick    = 1.5
def_charsze    = 1.0
def_xmargin    = [20,10]
def_ymargin    = [4,4]
;;  LABFLAG settings:  defines lable positions
;;    2  :  locations at vertical location of last component data point shown
;;    1  :  equally spaced with zeroth component at bottom
;;    0  :  no labels shown
;;   -1  :  equally spaced with zeroth component at top
def_labflag    = -1
def__ystyle    = 1
def_pansize    = 2.0
def__xminor    = 5
def_xtcklen    = 0.04
def_ytcklen    = 0.01
;;----------------------------------------------------------------------------------------
;;  First check to see if data were loaded into TPLOT
;;----------------------------------------------------------------------------------------
test           = ((tnames())[0] EQ '')
IF (test) THEN BEGIN
  notplot_msg = 'There was no TPLOT data found --> No defaults will be set'
  MESSAGE,notplot_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Set defaults
;;----------------------------------------------------------------------------------------
DEFSYSV,'!themis',EXISTS=exists
IF KEYWORD_SET(exists) THEN !themis.VERBOSE = 2
tplot_options,  'VERBOSE',def_verbose
tplot_options,'NO_INTERP',def_nointer    ;;  Allow interpolation in spectrograms [looks "better"]
tplot_options,    'THICK',def___thick
tplot_options, 'CHARSIZE',def_charsze
tplot_options,  'XMARGIN',def_xmargin
tplot_options,  'YMARGIN',def_ymargin
tplot_options, 'LABFLAG',def_labflag
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'

nnw            = tnames()
options,nnw,    'YSTYLE',def__ystyle,/DEF
options,nnw,'PANEL_SIZE',def_pansize,/DEF
options,nnw,    'XMINOR',def__xminor,/DEF
options,nnw,  'XTICKLEN',def_xtcklen,/DEF
options,nnw,  'YTICKLEN',def_ytcklen,/DEF
options,nnw,   'LABFLAG',def_labflag,/DEF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END

