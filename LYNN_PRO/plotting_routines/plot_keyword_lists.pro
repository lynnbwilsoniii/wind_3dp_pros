;+
;*****************************************************************************************
;
;  FUNCTION :   plot_keyword_lists.pro
;  PURPOSE  :   This routine returns a string array of acceptable keywords for different
;                 types of plotting routines in IDL.  Use the keywords defined below
;                 to tell the program which type of plot you will be using.
;
;  CALLED BY:   
;               plot_struct_format_test.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ;+++++++++++++++++++++++++++++++++++++++++++++
;               ; => Get list of keywords accepted by PLOT.PRO
;               ;+++++++++++++++++++++++++++++++++++++++++++++
;               test = plot_keyword_lists(/PLOT)
;
;  KEYWORDS:    
;               OPLOT       :  If set, returns the keywords accepted by OPLOT
;               PLOT        :  If set, returns the keywords accepted by PLOT
;               SPLOT       :  If set, returns the keywords accepted by PLOTS
;               CONTOUR     :  If set, returns the keywords accepted by CONTOUR
;               AXIS        :  If set, returns the keywords accepted by AXIS
;               SCALE3      :  If set, returns the keywords accepted by SCALE3
;               SURFACE     :  If set, returns the keywords accepted by SURFACE
;               SHADE_SURF  :  If set, returns the keywords accepted by SHADE_SURF
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  03/09/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/09/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION plot_keyword_lists,OPLOT=oplt,PLOT=plt,SPLOT=plts,CONTOUR=contr,$
                            AXIS=axs,SCALE3=scl3,SURFACE=surfc,SHADE_SURF=shsurf

;-----------------------------------------------------------------------------------------
; => Define dummy variables and check input
;-----------------------------------------------------------------------------------------
vec       = ['x','y','z']
xyzlog    = vec[*]+'log'
; => Some basic plot routine keywords
base_plot = ['isotropic','max_value','min_value','nsum',$
             'polar','thick',xyzlog,'ynozero']

unps = ['data','device','normal']
nost = 'no'+['clip','data','erase']

bkgd = 'background'
clip = 'clip'
font = 'font'
subt = 'subtitle'
t3ds = 't3d'
smsz = 'symsize'
psym = 'psym'
poss = 'position'
lsty = 'linestyle'
thks = 'thick'
chss = 'charsize'
chtk = 'charthick'
col  = 'color'
cols = 'colors'

rans = 'range'
ttls = 'title'
mins = 'minor'
tcgs = 'tick_get'
tcfs = 'tickformat'
tcis = 'tickinterval'
tcly = 'ticklayout'
tcln = 'ticklen'
tcns = 'tickname'
tcss = 'ticks'
tcus = 'tickunits'
tcvs = 'tickv'
zval = 'zvalue'

grds = 'gridstyle'
marg = 'margin'
stys = 'style'

lowo = 'lower_only'
upro = 'upper_only'
horz = 'horizontal'
bott = 'bottom'
mnvl = 'min_value'
mxvl = 'max_value'

xyzchss = vec[*]+chss[0]     ; => [X,Y,Z]CHARSIZE
xyzgrds = vec[*]+grds[0]     ; => [X,Y,Z]GRIDSTYLE
xyzmarg = vec[*]+marg[0]     ; => [X,Y,Z]MARGIN
xyzmins = vec[*]+mins[0]     ; => [X,Y,Z]MINOR
xyzrans = vec[*]+rans[0]     ; => [X,Y,Z]RANGE
xyzstys = vec[*]+stys[0]     ; => [X,Y,Z]STYLE
xyzthks = vec[*]+thks[0]     ; => [X,Y,Z]THICK
xyztcgs = vec[*]+tcgs[0]     ; => [X,Y,Z]TICK_GET
xyztcfs = vec[*]+tcfs[0]     ; => [X,Y,Z]TICKFORMAT
xyztcis = vec[*]+tcis[0]     ; => [X,Y,Z]TICKINTERVAL
xyztcly = vec[*]+tcly[0]     ; => [X,Y,Z]TICKLAYOUT
xyztcln = vec[*]+tcln[0]     ; => [X,Y,Z]TICKLEN
xyztcns = vec[*]+tcns[0]     ; => [X,Y,Z]TICKNAME
xyztcss = vec[*]+tcss[0]     ; => [X,Y,Z]TICKS
xyztcus = vec[*]+tcus[0]     ; => [X,Y,Z]TICKUNITS
xyztcvs = vec[*]+tcvs[0]     ; => [X,Y,Z]TICKV
xyzttls = vec[*]+ttls[0]     ; => [X,Y,Z]TITLE

xyzaxis = vec[*]+'axis'

; => Contour Specific
cotags  = ['c_annotation','c_'+chss[0],'c_'+chtk[0],'c_'+cols[0],'c_labels',  $
           'c_'+lsty[0],'c_orientation','c_spacing','c_'+thks[0],'cell_fill', $
           'fill','closed','downhill','follow','irregular','levels',          $
           'nlevels','overplot','path_data_coords','path_filename',           $
           'path_info','path_xy','triangulation','path_double']
;-----------------------------------------------------------------------------------------
; => Check Keywords
;-----------------------------------------------------------------------------------------
; => CONTOUR keyword set
IF KEYWORD_SET(contr) THEN BEGIN
  temp  = plot_keyword_lists(/PLOT)
  bad   = array_where([psym,smsz,lsty],temp,/N_UNIQ,NCOMP1=comp1,NCOMP2=comp2)
  ptags = temp[comp2]  ; => PLOT keywords minus PSYM, SYMSIZE, and LINESTYLE
  tags  = [cotags,ptags]
ENDIF

; => OPLOT keyword set
IF KEYWORD_SET(oplt) THEN                                                    $
  tags = [base_plot[1:5],clip,col,lsty,nost[0],psym,smsz,t3ds,zval]

; => PLOT keyword set
IF KEYWORD_SET(plt) THEN                                                     $
  tags = [bkgd,chss,chtk,clip,col,unps,font,lsty,nost,base_plot,poss,psym,   $
          subt,smsz,t3ds,tcln,ttls,xyzchss,xyzgrds,xyzmarg,xyzmins,xyzrans,  $
          xyzstys,xyzthks,xyztcgs,xyztcfs,xyztcis,xyztcly,xyztcln,xyztcns,   $
          xyztcss,xyztcus,xyztcvs,xyzttls,zval]

; => PLOTS keyword set
IF KEYWORD_SET(plts) THEN                                                    $
  tags = ['continue',clip,col,unps,lsty,nost[0],psym,smsz,t3ds,thks,'z']


; => AXIS keyword set
IF KEYWORD_SET(axs) THEN                                                     $
  tags = ['save',xyzaxis,xyzlog[0:1],'ynozero',chss,chtk,col,unps,font,      $
          nost[1:2],subt,t3ds,tcln,xyzchss,xyzgrds,xyzmarg,xyzmins,xyzrans,  $
          xyzstys,xyzthks,xyztcfs,xyztcis,xyztcly,xyztcln,xyztcns,           $
          xyztcss,xyztcus,xyztcvs,xyztcgs,xyzttls,zval]

; => SCALE3 keyword set
IF KEYWORD_SET(scl3) THEN                                                    $
  tags = ['xrange','yrange','zrange','ax','az']


; => SHADE_SURF keyword set
IF KEYWORD_SET(shsurf) THEN BEGIN
  temp   = plot_keyword_lists(/PLOT)
  except = ['isotropic','nsum','polar','ynozero',bkgd,clip,lsty,nost[[0,2]],psym,smsz]
  shtags = ['ax','az','image','pixels','save','shades']
  bad    = array_where(except,temp,/N_UNIQ,NCOMP1=comp1,NCOMP2=comp2)
  ptags  = temp[comp2]  ; => PLOT keywords minus values not accepted by SHADE_SURF
  tags   = [shtags,ptags]
ENDIF

; => SURFACE keyword set
IF KEYWORD_SET(surfc) THEN BEGIN
  temp  = plot_keyword_lists(/PLOT)
  bad   = array_where(['psym','symsize'],temp,/N_UNIQ,NCOMP1=comp1,NCOMP2=comp2)
  ptags = temp[comp2]  ; => PLOT keywords minus PSYM and SYMSIZE
  tags  = ['ax','az',bott,horz,'lego',lowo,upro,mnvl,mxvl,'save','shades',    $
           'skirt',xyzlog,'zaxis',ptags]
ENDIF



RETURN,tags
END
