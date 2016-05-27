;+
;*****************************************************************************************
;
;  FUNCTION :   contour_3dp_plot_limits.pro
;  PURPOSE  :   Creates a default limit structure for plotting a contour of the
;                 distribution function (DF) for a 3DP particle structure.  The program
;                 assumes you wish to plot the parallel and perpendicular cuts of
;                 the DF below the contour plot and that you've already ran the 
;                 3DP particle structure through the program add_df2d_to_ph.pro to
;                 calculate the distribution function.
;
;  CALLED BY: 
;               my_ph_cont2d.pro
;               eh_cont3d.pro
;
;  CALLS:
;               str_element.pro
;               extract_tags.pro
;               dat_3dp_str_names.pro
;               roundsig.pro
;               minmax.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT      :  3DP data structure either from get_eh.pro etc.
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               VLIM     :  Limit for x-y velocity axes over which to plot data
;                             [Default = max vel. from energy bin values]
;               NGRID    :  # of isotropic velocity grids to use to triangulate the data
;                             [Default = 20L]
;               DFMIN    :  Set to a scalar value defining the lower limit on the DF 
;                             you wish to plot (s^3/km^3/cm^3)
;                             [Default = 1e-14 (for PH)]
;               CMIN     :  Set to a scalar value defining the lowests color index to
;                             start with [Default = 30L (=purple if loadct,39)]
;               DFRA     :  2-Element array specifying a DF range (s^3/km^3/cm^3) for the
;                             cuts of the contour plot
;               MAGNETO  :  If set, tells program that the data was taken in the
;                              magnetosphere, thus to alter the upper and lower 
;                              limits on the distributions
;
;   CHANGED:  1)  Fixed syntax error                         [07/13/2009   v1.0.1]
;             2)  Fixed contour labeling issue for EL(B)     [07/18/2009   v1.0.2]
;             3)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                                                            [08/10/2009   v1.1.0]
;             4)  Changed contour level and Y-Range determination scheme
;                                                            [08/27/2009   v1.2.0]
;             5)  Changed plot axis labels                   [08/28/2009   v1.2.1]
;             6)  Fixed plot axis ranges                     [08/31/2009   v1.2.2]
;             7)  Now calls exponential_round.pro to alter the contour level labels
;                                                            [08/31/2009   v1.2.3]
;             8)  Changed contour level determination        [09/18/2009   v1.2.4]
;             9)  Changed case statement regarding conditional structure names used
;                                                            [09/23/2009   v1.3.0]
;            10)  Fixed a typo in min-max axis range calc.   [11/03/2009   v1.3.1]
;            11)  Changed min-max axis range calc.           [11/12/2009   v1.3.2]
;            12)  Added keyword:  MAGNETO                    [12/10/2009   v1.4.0]
;            13)  Fixed issue with DFRA keyword              [09/16/2010   v1.4.1]
;            14)  Now calls roundsig.pro instead of exponential_round.pro
;                                                            [10/01/2010   v1.5.0]
;            15)  Updated man page                           [10/13/2010   v1.5.1]
;            16)  Changed min/max range determinations       [12/15/2011   v1.5.2]
;            17)  Fixed an anomalous syntax error            [01/06/2012   v1.5.3]
;            18)  Changed contour level determination        [01/13/2012   v1.5.4]
;
;   CREATED:  06/24/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/13/2012   v1.5.4
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION contour_3dp_plot_limits,dat,VLIM=vlim,NGRID=ngrid,DFMIN=dfmin,CMIN=cmin,$
                                     DFRA=dfra,MAGNETO=magneto

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
f        = !VALUES.F_NAN
d        = !VALUES.D_NAN

IF NOT KEYWORD_SET(ngrid) THEN ngrid  = 20L    ; => # of levels to use for contour.pro
IF NOT KEYWORD_SET(cmin)  THEN minclr = 30L    ; => Min color index 

IF NOT KEYWORD_SET(vlim) THEN BEGIN
  vlim = MAX(SQRT(2*dat.ENERGY/dat.MASS),/NAN)  ; => velocity limit (km/s)
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)  ; => velocity limit (km/s)
ENDELSE
mincnt   = 0.
plim     = vlim                         ; => Plot limits
dgs      = vlim/5e1
gs       = [dgs,dgs]
;gs       = [vlim,vlim]/dgs              ; => [parallel grids, perpendicular grids]
xylim    = [-1*vlim,-1*vlim,vlim,vlim]  ; => triangulation limits

ytitle   = 'V perpendicular  (1000 km/sec)'
xtitle   = 'V parallel  (1000 km/sec)'
; => Define contour plot limit structure
lim1     = {XRANGE:[-vlim,vlim]*1d-3,XSTYLE:1,XLOG:0,XTITLE:xtitle, $
            YRANGE:[-vlim,vlim]*1d-3,YSTYLE:1,YLOG:0,YTITLE:ytitle, $
            XMINOR:5,YMINOR:5}
;-----------------------------------------------------------------------------------------
; => Define some plot parameters
;-----------------------------------------------------------------------------------------
; => Position define such that PS output is square
mypos3   = [0.22941,0.515,0.77059,0.915]
str_element,lim1,'POSITION',mypos3,/ADD_REPLACE
title0   = dat.PROJECT_NAME+'  '+dat.DATA_NAME
levels   = REPLICATE(f,ngrid)

str_element,contstuff,'XTITLE','',/ADD_REPLACE
str_element,contstuff,'YTITLE','',/ADD_REPLACE
str_element,contstuff,'LEVELS',levels,/ADD_REPLACE
str_element,contstuff,'OVERPLOT',1,/ADD_REPLACE
extract_tags,contstuff,lim1,/CONTOUR

xtitle   = 'Velocity (1000 km/sec)'
ytitle   = 'df (sec!U3!N/km!U3!N/cm!U3!N)'
mypos2   = [0.22941,0.05,0.77059,0.45]  ; -position of second plot
lim2     = {XRANGE:[-vlim,vlim]*1d-3,XSTYLE:1,XLOG:0,XTITLE:xtitle,   $
            YRANGE:[-1d0,1d0],YSTYLE:1,YLOG:1,YTITLE:ytitle,       $
            POSITION:mypos2,XMINOR:5,YMINOR:9}
;-----------------------------------------------------------------------------------------
; -Check input
;-----------------------------------------------------------------------------------------
tags = ['PLOT_LIMS','CONT','CUTS']
dumb = CREATE_STRUCT(tags,lim1,contstuff,lim2)

dtype = SIZE(dat,/TYPE) NE 8
IF (dtype) THEN BEGIN
  MESSAGE,'Incorrect input format:  DAT',/CONTINUE,/INFORMATIONAL
  RETURN,dumb
ENDIF
;-----------------------------------------------------------------------------------------
; => Define some relevant parameters
;-----------------------------------------------------------------------------------------
gd_tags    = STRUPCASE(TAG_NAMES(dat))
gd_tests   = [(gd_tags EQ 'DF_PARA'),(gd_tags EQ 'DF_PERP'),(gd_tags EQ 'DF_SMOOTH')]
gd_dfpp    = WHERE(gd_tests NE 0,gd_d)
IF (gd_d GT 0) THEN BEGIN
  dfpara   = SMOOTH(dat.DF_PARA,3L,/EDGE_TRUNCATE,/NAN)
  dfperp   = SMOOTH(dat.DF_PERP,3L,/EDGE_TRUNCATE,/NAN)
  dfdat    = dat.DF_SMOOTH
  vpara    = dat.VX2D
  gpara    = WHERE(ABS(vpara) LE 875e-3*vlim,gpa)
  npara    = N_ELEMENTS(vpara)
  ; => Define a default Y-Range minimum and maximum for CUT plots
  def_low  = MIN([dfpara,dfperp],/NAN)
  def_high = MAX([dfpara,dfperp],/NAN)
ENDIF ELSE BEGIN
  MESSAGE,'Incorrect structure format:  DAT',/CONTINUE,/INFORMATIONAL
  RETURN,dumb
ENDELSE
;-----------------------------------------------------------------------------------------
; => Make sure name is in the correct format
;-----------------------------------------------------------------------------------------
strn   = dat_3dp_str_names(dat)
sname  = STRMID(strn.SN,0L,2L)
ssname = STRMID(strn.SN,0L,1L)
;-----------------------------------------------------------------------------------------
; => Define default contour/data ranges
;-----------------------------------------------------------------------------------------
CASE ssname[0] OF
  's'  : BEGIN
    lower_limit = 1e-39
    upper_limit = 1e-14
    IF NOT KEYWORD_SET(dfmin) THEN fmin = def_low ELSE fmin  = (REFORM(dfmin))[0]
  END
  'p'  : BEGIN
    CASE sname[0] OF
      'ph' : BEGIN
;        IF NOT KEYWORD_SET(dfmin) THEN fmin = 1e-14 ELSE fmin = (REFORM(dfmin))[0]
        ; LBW III 12/15/2011
        IF NOT KEYWORD_SET(dfmin) THEN fmin = 1e-17 ELSE fmin = (REFORM(dfmin))[0]
        IF NOT KEYWORD_SET(magneto) THEN BEGIN
          ; => In the solar wind
          lower_limit = 1e-17       ; LBW III 12/15/2011
          upper_limit = 1e-4        ; LBW III 12/15/2011
        ENDIF ELSE BEGIN
          ; => In the magnetosphere
          lower_limit = 1e-17       ; LBW III 12/15/2011
          upper_limit = 1e-4
        ENDELSE
      END
      ELSE : BEGIN
        lower_limit = 1e-18
        upper_limit = 1e-4          ; LBW III 12/15/2011
;        IF NOT KEYWORD_SET(dfmin) THEN fmin = lower_limit ELSE fmin  = (REFORM(dfmin))[0]
      END
      ; LBW III 12/15/2011
;      IF NOT KEYWORD_SET(dfmin) THEN fmin = lower_limit ELSE fmin  = (REFORM(dfmin))[0]
    ENDCASE
    ;  LBW III  01/06/2012
    IF NOT KEYWORD_SET(dfmin) THEN fmin = lower_limit ELSE fmin  = (REFORM(dfmin))[0]
  END
  'e'  : BEGIN
    IF (STRUPCASE(sname) EQ 'EL') THEN BEGIN
      lower_limit = 1e-18       ; LBW III 12/15/2011
      upper_limit = 1e-4        ; LBW III 12/15/2011
    ENDIF ELSE BEGIN
      lower_limit = 1e-18       ; LBW III 12/15/2011
      upper_limit = 1e-4        ; LBW III 12/15/2011
    ENDELSE
    ; =>  If in magnetosphere, these ranges can change rather dramatically -> check
    IF NOT KEYWORD_SET(dfmin) THEN fmin = lower_limit ELSE fmin  = (REFORM(dfmin))[0]
  END
  ELSE : BEGIN
    lower_limit = 1e-18
    upper_limit = 1e-4          ; LBW III 12/15/2011
    IF NOT KEYWORD_SET(dfmin) THEN fmin = lower_limit ELSE fmin  = (REFORM(dfmin))[0]
  END
ENDCASE
; => Determine Y-Axis min value
ymin_val    = fmin*1.05e0
gpara       = WHERE(ABS(vpara) LE 8e-1*vlim,gpa)
IF (gpa GT 0) THEN BEGIN
  def_low  = MIN([dfpara[gpara],dfperp[gpara]],/NAN) > lower_limit
  def_high = MAX([dfpara[gpara],dfperp[gpara]],/NAN) < upper_limit
  ymin_val = def_low*1.05
ENDIF ELSE BEGIN
  def_low  = lower_limit
  def_high = upper_limit
  ymin_val = def_low*1.05
ENDELSE

IF NOT KEYWORD_SET(dfra) THEN BEGIN
  df_ra = [ymin_val,def_high] 
  dfran = [(MIN(dfdat,/NAN) > lower_limit),(MAX(dfdat,/NAN) < upper_limit)/1.05]
ENDIF ELSE BEGIN
  df_ra = REFORM(dfra)
  dfran = df_ra
ENDELSE
mxdf     = df_ra[1]
cut_ra   = df_ra       ; => Set DF Cuts YRANGE
; => Round the multiples of the powers of 10 in the contour ranges
;     [i.e. 1.0103834e-37 --> 1.0e-37]
r_dfran  = roundsig(dfran,SIGFIG=2)
range    = ALOG10(r_dfran)
;--------------------------------------------
;  => LBW 10/01/2010
;r_dfran  = exponential_round(dfran)
; => Check system variable status  
;DEFSYSV,'!exp_round_count',EXISTS=exists
;IF KEYWORD_SET(exists) THEN BEGIN
;  !exp_round_count = 0
;ENDIF
;  => LBW 10/01/2010
;facts    = r_dfran.FACTORS
;expos    = r_dfran.EXPONENTS
;range    = minmax(expos)
;--------------------------------------------
IF (KEYWORD_SET(magneto) AND sname[0] EQ 'ph') THEN BEGIN
  range[0] = ALOG10(1e1^(range[0])*1e1)
  range[1] = ALOG10(1e1^(range[1])/1e1)
ENDIF
cpd      = FIX(ngrid/(range[1] - range[0])) > 1
nlevs    = FIX((range[1] - range[0] + 1)*cpd)
; => Determine the number of orders of magnitude
;      1) IF orders >= 5  =>> use more levels ELSE use ngrid levels
orders   = MAX(ABS(range),/NAN) - MIN(ABS(range),/NAN)
IF (orders GE 5) THEN BEGIN
  nglevs   = (nlevs > 2)
ENDIF ELSE BEGIN
  nglevs   = (nlevs > 2) < ngrid
ENDELSE
;  LBW III  01/13/2012
nglevs   = ngrid
;levels   = REVERSE((FIX(FLOOR(range[1]*cpd)) - FINDGEN(nglevs))/cpd)
;levels   = 1e1^(levels)
;r_levels = roundsig(levels,SIGFIG=1)
;levels   = r_levels

;  LBW III  01/13/2012
lg_levs  = FINDGEN(ngrid)*(range[1] - range[0])/(ngrid - 1L) + range[0]
levels   = roundsig(1e1^(lg_levs),SIGFIG=1)
;levels   = ALOG10(r_levels)
;--------------------------------------------
;  => LBW 10/01/2010
;levels   = r_levels.ROUNDED_EXP
; => Check system variable status
;DEFSYSV,'!exp_round_count',EXISTS=exists
;IF KEYWORD_SET(exists) THEN BEGIN
;  !exp_round_count = 0
;ENDIF
;--------------------------------------------

;-----------------------------------------------------------------------------------------
; => Determine plot ranges and contour levels
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(dfra) THEN BEGIN
  CASE sname[0] OF
; LBW III 12/15/2011
;    'ph' : BEGIN
;      IF NOT KEYWORD_SET(magneto) THEN BEGIN
        ; => In the solar wind
;        levels   = fmin*(1e1^(22e-2*FINDGEN(ngrid)))
;      ENDIF ELSE BEGIN
        ; => In the magnetosphere
;        levels   = levels/1.1
;      ENDELSE
;    END
    ELSE : 
  ENDCASE
ENDIF
;-----------------------------------------------------------------------------------------
; => Define some plot parameters
;-----------------------------------------------------------------------------------------
str_element,contstuff,'MIN_VALUE',fmin/3e0,/ADD_REPLACE
IF (nglevs NE ngrid) THEN ncols = nglevs ELSE ncols = ngrid
c_colors = minclr + LINDGEN(ncols)*(250L - minclr)/(ncols - 1L) ; => corresponding colors

str_element,contstuff,'XTITLE',xtitle,/ADD_REPLACE
str_element,contstuff,'YTITLE',ytitle,/ADD_REPLACE
str_element,contstuff,'C_COLORS',c_colors,/ADD_REPLACE
str_element,contstuff,'LEVELS',levels,/ADD_REPLACE
str_element,contstuff,'OVERPLOT',1,/ADD_REPLACE
;-----------------------------------------------------------------------------------------
; => Get contour tags from lim1 structure and add to contstuff structure
;-----------------------------------------------------------------------------------------
extract_tags,contstuff,lim1,/CONTOUR
;-----------------------------------------------------------------------------------------
; => Define DF cuts plot limit structure
;-----------------------------------------------------------------------------------------
exp_val  = LINDGEN(50) - 50L                    ; => Array of exponent values
ytns     = '10!U'+STRTRIM(exp_val[*],2L)+'!N'   ; => Y-Axis tick names
ytvs     = 1d1^exp_val[*]                       ; => Y-Axis tick values
xtitle   = 'Velocity (1000 km/sec)'
ytitle   = 'df (sec!U3!N/km!U3!N/cm!U3!N)'
mypos2   = [0.22941,0.05,0.77059,0.45]  ; -position of second plot

;yra_2lim = [ymin_val,mxdf]
goodyl   = WHERE(ytvs LE cut_ra[1] AND ytvs GE cut_ra[0],gdyl)
IF (gdyl LT 20 AND gdyl GT 0) THEN BEGIN
  lim2     = {XRANGE:[-vlim,vlim]*1d-3,XSTYLE:1,XLOG:0,XTITLE:xtitle,            $
              YRANGE:cut_ra,YSTYLE:1,YLOG:1,YTITLE:ytitle,YTICKV:ytvs[goodyl],   $
              YTICKNAME:ytns[goodyl],YTICKS:gdyl-1L,POSITION:mypos2,XMINOR:5,    $
              YMINOR:9}
ENDIF ELSE BEGIN
  lim2     = {XRANGE:[-vlim,vlim]*1d-3,XSTYLE:1,XLOG:0,XTITLE:xtitle,   $
              YRANGE:cut_ra,YSTYLE:1,YLOG:1,YTITLE:ytitle,              $
              POSITION:mypos2,XMINOR:5,YMINOR:9}
ENDELSE
title    = title0+'!C'+trange_str(dat.TIME,dat.END_TIME)
str_element,lim1,'TITLE',title,/ADD_REPLACE
;-----------------------------------------------------------------------------------------
; => Return structures
;-----------------------------------------------------------------------------------------
gstr = CREATE_STRUCT(tags,lim1,contstuff,lim2)
RETURN,gstr
END