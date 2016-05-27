;+
;*****************************************************************************************
;
;  FUNCTION :   specplot_wrapper.pro
;  PURPOSE  :   This is a wrapping program meant to create a useable interface between
;                 specplot.pro and the user without going through TPLOT or requiring
;                 the use of UNIX times as the X-Axis variable.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               str_element.pro
;               plot_positions.pro
;               box.pro
;               specplot.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X             :  X-axis values => Dimension N.
;               Y             :  Y-axis values => Dimension M. or [N,M]
;               Z             :  Color axis values:  Dimension [N,M].
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               LIMITS        :  A structure that may contain any combination of the 
;                                  following elements:
;=========================================================================================
;                                  ALL plot keywords such as:
;                                  XLOG,   YLOG,   ZLOG,
;                                  XRANGE, YRANGE, ZRANGE,
;                                  XTITLE, YTITLE,
;                                  TITLE, POSITION, REGION  etc. (see IDL
;                                    documentation for a description)
;                                  The following elements can be included in 
;                                    LIMITS to effect DRAW_COLOR_SCALE:
;                                      ZTICKS, ZRANGE, ZTITLE, ZPOSITION, ZOFFSET
; **[Note: Program deals with these by itself, so just set them if necessary and let 
;           it do the rest.  Meaning, if you know what the tick marks should be on 
;           your color bar, define them under the ZTICK[V,NAME,S] keywords in the 
;           structure ahead of time.]**
;=========================================================================================
;               DATA          :  A structure that provides an alternate means of
;                                   supplying the data and options.  This is the 
;                                   method used by "TPLOT".
;               MULTIPLOTS    :  Not finished yet, but it is intended to allow one to
;                                  plot as many plots as necessary while only using this
;                                  routine to plot the specific spectrograms desired
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  If using the DATA keyword, then make sure you use it in the following
;                     manner:
;                     X-Axis Values:  label with X structure tag
;                     Y-Axis Values:  label with V structure tag
;                     Z-Axis Values:  label with Y structure tag
;
;   CREATED:  03/05/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/05/2010   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO specplot_wrapper,x,y,z,LIMITS=lims,DATA=data,MULTIPLOTS=multp

;-----------------------------------------------------------------------------------------
; => Define some defaults
;-----------------------------------------------------------------------------------------
chsize   = !P.CHARSIZE
IF (chsize EQ 0.) THEN chsize = 1.

def_opts = {YMARGIN:[4.,2.],XMARGIN:[12.,15.],POSITION:FLTARR(4),TITLE:'', $
            YTITLE:'',XTITLE:'',XRANGE:DBLARR(2),VERSION:3,                $
            WINDOW:-1, WSHOW:0,XSTYLE:1,CHARSIZE:chsize,NOERASE:0,         $
            OVERPLOT:0,SPEC:1                                               }

str_element,def_opts,'YGAP',VALUE=ygap
str_element,def_opts,'CHARSIZE',VALUE=chsize

IF KEYWORD_SET(multp) THEN nd = multp[0] ELSE nd = 1
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (KEYWORD_SET(data) AND SIZE(data,/TYPE) EQ 8) THEN BEGIN
  tags  = TAG_NAMES(data)
  testx = WHERE(STRMATCH(tags,'x',/FOLD_CASE),gx)
  testy = WHERE(STRMATCH(tags,'v',/FOLD_CASE),gy)
  testz = WHERE(STRMATCH(tags,'y',/FOLD_CASE),gz)
  IF (gx GT 0 AND gy GT 0 AND gz GT 0) THEN BEGIN
    gdata = data
  ENDIF ELSE BEGIN
    MESSAGE,'Invalid structure format!',/CONTINUE,/INFORMATIONAL
    IF N_PARAMS() NE 3 THEN RETURN
  ENDELSE
ENDIF ELSE BEGIN
  ; => if you didn't enter an x, y, AND z, then leave program
  IF N_PARAMS() NE 3 THEN RETURN
  gdata = {X:x,V:y,Y:z}
ENDELSE
;-----------------------------------------------------------------------------------------
; => Plot and window structure info
;-----------------------------------------------------------------------------------------
sizes = REPLICATE(2.,nd)
plt   = {X:!x,Y:!y,Z:!z,P:!p}
;-----------------------------------------------------------------------------------------
; => Get plot position(s)
;-----------------------------------------------------------------------------------------
str_element,def_opts,'YGAP',VALUE=ygap
str_element,def_opts,'CHARSIZE',VALUE=chsize
nvlabs            = [0.,0.,0.,1.,0.]
nvl               = N_ELEMENTS(var_label) + nvlabs(def_opts.VERSION) 
def_opts.YMARGIN += [nvl,0.]

!P.MULTI = 0
pos      = plot_positions(YSIZES=sizes,OPTIONS=def_opts,YGAP=ygap)
;-----------------------------------------------------------------------------------------
; => Define plot structure info
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(lims) THEN extract_tags,def_opts,lims

init_opts        = def_opts
init_opts.XSTYLE = 5
; => erase old window if necessary
IF (init_opts.NOERASE EQ 0) THEN ERASE
init_opts.NOERASE = 1
str_element,init_opts,'YSTYLE',5,/ADD_REPLACE

; => Plot an empty axes-less box for defining window positions etc.
box,init_opts

def_opts.NOERASE  = 1
def_opts.POSITION = pos
newlim            = def_opts
;-----------------------------------------------------------------------------------------
; => Plot spectrogram
;-----------------------------------------------------------------------------------------
IF (newlim.SPEC NE 0) THEN routine = 'specplot' ELSE routine = 'mplot'
str_element,newlim,'TPLOT_ROUTINE',VALUE=routine

specplot,DATA=gdata,LIMITS=newlim

RETURN
END