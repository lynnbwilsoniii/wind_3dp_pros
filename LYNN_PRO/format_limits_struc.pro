;+
;*****************************************************************************************
;
;  FUNCTION :   format_limits_struc.pro
;  PURPOSE  :   This routine tests an input plot limits structure that would be passed
;                 to an IDL built-in plotting routine using _EXTRA.  The routine removes
;                 unnecessary or unacceptable structure tags, if present, and returns
;                 the "fixed" structure to the user.  If the input is "bad" or
;                 nonexistent, then the routine returns FALSE.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               extract_tags.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ;;  Test a LIMITS structure for PLOT
;               xyran  = [-1d0,1d0]
;               xttl   = 'X-Axis Title'
;               yttl   = 'Y-Axis Title'
;               posi   = [0.22941,0.515,0.77059,0.915]
;               pttl   = 'Plot Title'
;               lim0   = {XRANGE:xyran,XSTYLE:1,XLOG:0,XTITLE:xttl,XMINOR:10, $
;                         YRANGE:xyran,YSTYLE:1,YLOG:0,YTITLE:yttl,YMINOR:10, $
;                         POSITION:posi,TITLE:pttl,NODATA:1}
;               test   = format_limits_struc(LIMITS=limits,PTYPE=0)
;               HELP, test
;
;  KEYWORDS:    
;               LIMITS   :  Scalar [structure] defining the plot limits structure
;                             with tag names matching acceptable keywords in CONTOUR.PRO,
;                             PLOT.PRO, OPLOT.PRO, AXIS.PRO, or XYOUTS.PRO that is
;                             to be passed using _EXTRA
;               PTYPE    :  Scalar [integer] defining the type of plot/output for which
;                             the limits structure will be used.
;                             {Default = 0}
;                             The accepted values are:
;                               0  :  PLOT
;                               1  :  OPLOT
;                               2  :  CONTOUR
;                               3  :  AXIS
;                               4  :  XYOUTS
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  05/01/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/01/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION format_limits_struc,LIMITS=limits,PTYPE=ptype,_EXTRA=ex_str

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
noinpt_msg     = 'Must supply LIMITS [structure]...'
notstr_msg     = 'LIMITS must be an IDL structure...'
notags_msg     = 'LIMITS structure tags must match those of the corresponding plot/output routine...'
;;----------------------------------------------------------------------------------------
;;  Check input for LIMITS
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(limits) EQ 0) THEN BEGIN
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

IF (SIZE(limits,/TYPE) NE 8) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define dummy structure tags
;;----------------------------------------------------------------------------------------
xyz_str        = ['x','y','z']
;;  All [XYZ]{Suffix} graphics tags
xyz_tags       = [xyz_str+'charsize',xyz_str+'gridstyle',xyz_str+'margin',            $
                  xyz_str+'minor',xyz_str+'range',xyz_str+'style',xyz_str+'thick',    $
                  xyz_str+'tickformat',xyz_str+'tickinterval',xyz_str+'ticklayout',   $
                  xyz_str+'ticklen',xyz_str+'tickname',xyz_str+'ticks',               $
                  xyz_str+'tickunits',xyz_str+'tickv',xyz_str+'tick_get',             $
                  xyz_str+'title']
;;---------------------------------------------
;;  OPLOT.PRO keywords
;;---------------------------------------------
;;  Graphics keywords for OPLOT.PRO
oplot_grph     = ['clip','color','linestyle','noclip','psym','symsize','t3d','zvalue']
;;  Keywords for OPLOT.PRO
oplot_tag0     = ['max_value','min_value','nsum','polar','thick']
oplot_tags     = [oplot_tag0,oplot_grph]
;;---------------------------------------------
;;  PLOT.PRO keywords
;;---------------------------------------------
;;  Graphics keywords for PLOT.PRO
plot_grph      = ['am_pm','background','charsize','charthick','clip','color','data',  $
                  'days_of_week','device','font','linestyle','months','noclip',       $
                  'nodata','noerase','normal','position','psym','subtitle','symsize', $
                  't3d','thick','ticklen','title',xyz_tags,'zvalue']
;;  Keywords for PLOT.PRO
plot_tag0      = ['isotropic','max_value','min_value','nsum','polar','thick','xlog', $
                  'ylog','ynozero']
plot_tags      = [plot_tag0,plot_grph]
;;---------------------------------------------
;;  CONTOUR.PRO keywords
;;---------------------------------------------
;;  Graphics keywords for CONTOUR.PRO
cont_grph      = ['background','charsize','charthick','clip','color','data','device', $
                  'font','noclip','nodata','noerase','normal','position','subtitle',  $
                  't3d','thick','ticklen','title',xyz_tags,'zvalue']
;;  Keywords for CONTOUR.PRO
cont_tag0      = ['c_annotation','c_charsize','c_charthick','c_colors','c_labels',   $
                  'c_linestyle','c_orientation','c_spacing','c_thick','cell_fill',   $
                  'fill','closed','downhill','follow','irregular','isotropic',       $
                  'levels','nlevels','max_value','min_value','overplot',             $
                  'path_data_coords','path_filename','path_info','path_xy',          $
                  'triangulation','path_double','xlog','ylog','zaxis']
cont_tags      = [cont_tag0,cont_grph]
;;---------------------------------------------
;;  AXIS.PRO keywords
;;---------------------------------------------
;;  Graphics keywords for AXIS.PRO
axis_grph      = ['am_pm','charsize','charthick','color','data','days_of_week',       $
                  'device','font','nodata','noerase','normal','subtitle','t3d',       $
                  'ticklen','months',xyz_tags,'zvalue']
;;  Keywords for AXIS.PRO
axis_tag0      = ['save','xaxis','yaxis','zaxis','xlog','ynozero','ylog']
axis_tags      = [axis_tag0,axis_grph]
;;---------------------------------------------
;;  XYOUTS.PRO keywords
;;---------------------------------------------
;;  Graphics keywords for XYOUTS.PRO
xyouts_grph    = ['clip','color','data','device','font','noclip','normal',            $
                  'orientation','t3d','z']
;;  Keywords for XYOUTS.PRO
xyouts_tag0    = ['alignment','charsize','charthick','text_axes','width']
xyouts_tags    = [xyouts_tag0,xyouts_grph]
;;----------------------------------------------------------------------------------------
;;  Determine the desired plot type
;;----------------------------------------------------------------------------------------
szp            = SIZE(ptype,/TYPE)
test           = (N_ELEMENTS(ptype) EQ 0) OR ((szp[0] LT 1) OR (szp[0] GT 5))
IF (test) THEN type = 0 ELSE type = ptype[0]

CASE type[0] OF
  0    :  gtags = plot_tags
  1    :  gtags = oplot_tags
  2    :  gtags = cont_tags
  3    :  gtags = axis_tags
  4    :  gtags = xyouts_tags
  ELSE :  gtags = plot_tags
ENDCASE

lim0           = limits[0]
;;----------------------------------------------------------------------------------------
;;  Determine if LIMITS has acceptable tags
;;----------------------------------------------------------------------------------------
ltags          = STRLOWCASE(TAG_NAMES(lim0))
nlt            = N_TAGS(lim0)
ngt            = N_ELEMENTS(gtags)

extract_tags,new_lim,lim0[0],TAGS=gtags,_EXTRA=ex_str
IF (SIZE(new_lim,/TYPE) NE 8) THEN BEGIN
  MESSAGE,notags_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,new_lim
END

