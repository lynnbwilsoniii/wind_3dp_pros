;+
;*****************************************************************************************
;
;  PROCEDURE:   density_contour_plot_wrapper.pro
;  PURPOSE  :   This is a wrapping routine for density_contour_plot.pro that color-codes
;                 the outputted data values in addition to overplotting contours.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               test_window_number.pro
;               format_limits_struc.pro
;               extract_tags.pro
;               struct_value.pro
;               lbw_window.pro
;               density_contour_plot.pro
;               num2int_str.pro
;               str_element.pro
;               poly_winding_number2d.pro
;               cgsetdifference.pro
;               lbw_oplot_clines_from_struc.pro
;               popen.pro
;               pclose.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Coyote IDL Libraries
;
;  INPUT:
;               XDATA       :  [N]-Element array [float/double] of independent data points
;               YDATA       :  [N]-Element array [float/double] of   dependent data points
;
;  EXAMPLES:    
;               [calling sequence]
;               density_contour_plot_wrapper, xdata, ydata,                          $
;                                 [,PLIMITS=plimits] [,WIND_N=wind_n]                $
;                                 [,FILE_NAME=file_name] [,XTITLE=xtitle]            $
;                                 [,YTITLE=ytitle] [,YLOG=y_log] [,XLOG=x_log]       $
;                                 [,XMIN=xmin] [,XMAX=xmax] [,NX=nx] [,YMIN=ymin]    $
;                                 [,YMAX=ymax] [,NY=ny] [,CLIMITS=climits]           $
;                                 [,CLABS=clabs] [,SMCONT=smcont] [,SMWDTH=smwdth]   $
;                                 [,USE_SMOOTH=use_smooth] [,LEVEL_PER=level_per]    $
;                                 [,CPATH_OUT=cpath_out] [,HIST2D_OUT=hist2d_out]    $
;                                 [,N_SUM=n_sum] [,_EXTRA=ex_str]
;
;  KEYWORDS:    
;               PLIMITS     :  Scalar [structure] defining the plot limits structure
;                                with tag names matching acceptable keywords in
;                                PLOT.PRO to be passed using _EXTRA
;               [X,Y]TITLE  :  Scalar [string] defining the [X,Y]-Axis title to use
;                                {ignored if set in PLIMITS}
;                                [Default = '[X,Y]TITLE']
;               [X,Y]LOG    :  Scalar [long] defining whether the [X,Y]-Axis should be
;                                put on a log-scale
;                                {ignored if set in PLIMITS}
;                                [Default = FALSE]
;               WIND_N      :  Scalar [integer] defining the plot window in which data
;                                are plotted/shown
;               FILE_NAME   :  Scalar [string] defining the output PS file name.  If not
;                                set then routine will not save a PS file.
;                                [Default = FALSE]
;               N_SUM       :  Scalar [integer] defining the number of points by which
;                                to downsample the input.  This is useful for large
;                                input arrays.  An input of N_SUM=1 corresponds to using
;                                all input points.
;                                [Default = 1]
;               ******************************************
;               ***  density_contour_plot.pro  INPUTS  ***
;               ******************************************
;               [X,Y]MIN    :  Scalar [float/double] defining the Min. [X,Y]-Axis plot
;                                value and the corresponding Min. value to consider when
;                                constructing the 2D histogram.
;                                { Default = MIN([X,Y]DATA) }
;               [X,Y]MAX    :  Scalar [float/double] defining the Max. [X,Y]-Axis plot
;                                value and the corresponding Max. value to consider when
;                                constructing the 2D histogram.
;                                { Default = MAX([X,Y]DATA) }
;               N[X,Y]      :  Scalar [long] defining the # of [X,Y]-Axis bins to use
;                                [Default = 100L]
;               CLIMITS     :  Scalar [structure] defining the plot limits structure
;                                with tag names matching acceptable keywords in
;                                CONTOUR.PRO to be passed using _EXTRA
;               CLABS       :  If set, routine will plot the contours with labels
;                                indicating the percentage of data points within each
;                                contour
;                                [Default = FALSE]
;               SMCONT      :  If set, routine will smooth the contours prior to plotting
;                                [Default = FALSE]
;               USE_SMOOTH  :  If set, routine will use SMOOTH.PRO instead of
;                                MIN_CURVE_SURF.PRO to smooth the contours.  Setting
;                                this keyword makes the routine run much much faster.
;                                [Default = FALSE]
;               LEVEL_PER   :  [L]-Element array [float/double] defining the relative
;                                percent of the maximum density from the 2D histogram
;                                to use for each level in the contour plot output
;               SMWDTH      :  Scalar [integer/long] defining the number of elements over
;                                 which to smooth the 2D histogram (only applies when the
;                                 USE_SMOOTH keyword is set)
;                                [Default = 4]
;               **********************************
;               ***      INDIRECT OUTPUTS      ***
;               **********************************
;               CPATH_OUT   :  Set to a named variable to return the contour path
;                                information in data coordinates
;               HIST2D_OUT  :  Set to a named variable to return the 2D histogram used
;                                to create the contours for CONTOUR.PRO
;               CSTR_OUT    :  Set to a named variable to return the structure containing
;                                information for the color-coded points shown on output
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [11/01/2017   v1.0.0]
;             2)  Added N_SUM keyword and a little more error handling
;                                                                   [11/03/2017   v1.0.1]
;             3)  Added error handling for plotting color-coded data points when none
;                   fall within a contour and
;                   added keyword:  SMWDTH
;                                                                   [09/20/2018   v1.0.2]
;             4)  Added keyword:  CSTR_OUT
;                                                                   [07/29/2024   v1.0.3]
;
;   NOTES:      
;               1)  See also:  density_contour_plot.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  10/30/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/29/2024   v1.0.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO density_contour_plot_wrapper,xdata,ydata,                                        $
                                 PLIMITS=plimits,WIND_N=wind_n,FILE_NAME=file_name,  $
                                 N_SUM=n_sum,XTITLE=xtitle,YTITLE=ytitle,            $
                                 YLOG=y_log,XLOG=x_log,XMIN=xmin,XMAX=xmax,NX=nx,    $
                                 YMIN=ymin,YMAX=ymax,NY=ny,CLIMITS=climits,          $
                                 CLABS=clabs,SMCONT=smcont,SMWDTH=smwdth,            $
                                 USE_SMOOTH=use_smooth,LEVEL_PER=level_per,          $
                                 CPATH_OUT=cpath_out,HIST2D_OUT=hist2d_out,          $  ;; outputs
                                 CSTR_OUT=gcont_str,_EXTRA=ex_str

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_nsum       = 1L
;;  Dummy tick mark arrays
exp_val        = LINDGEN(501) - 250L                  ;;  Array of exponent values
exp_str        = STRTRIM(STRING(exp_val,FORMAT='(I)'),2L)
log10_tickn    = '10!U'+exp_str+'!N'                  ;;  Powers of 10 tick names
log10_tickv    = 1d1^DOUBLE(exp_val[*])               ;;  " " values
xyz_str        = ['x','y','z']
;;  All [XYZ]{Suffix} graphics tags
xyz_tags       = [xyz_str+'charsize',xyz_str+'gridstyle',xyz_str+'margin',            $
                  xyz_str+'minor',xyz_str+'range',xyz_str+'style',xyz_str+'thick',    $
                  xyz_str+'tickformat',xyz_str+'tickinterval',xyz_str+'ticklayout',   $
                  xyz_str+'ticklen',xyz_str+'tickname',xyz_str+'ticks',               $
                  xyz_str+'tickunits',xyz_str+'tickv',xyz_str+'tick_get',             $
                  xyz_str+'title']
;;  Define
;;    - symbol to use for plotting points
;;    - symbol size
;;    - thickness of lines
;;    - line style for "info" lines
;;    - Default popen.pro structure
symb           = 3
syms           = 2.0
thck           = 2.0
lsty           = 2
postruc        = {LANDSCAPE:1,PORT:0,UNITS:'inches',XSIZE:10.5,YSIZE:8.,ASPECT:0}
;;  Define default plot structure
plotposi       = [0.1,0.1,0.9,0.9]
def_pstr       = {NODATA:1,YSTYLE:1,XSTYLE:1,POSITION:plotposi}
;;  Dummy error messages
noinpt_msg     = 'No input supplied...'
nofint_msg     = 'No finite data...'
badinp_msg     = 'XDATA and YDATA must both be [N]-element [numeric] arrays...'
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (is_a_number(xdata,/NOMSSG) EQ 0) OR    $
                 (is_a_number(ydata,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  No input
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check format
szdt0          = SIZE(xdata,/DIMENSIONS)
szdt1          = SIZE(ydata,/DIMENSIONS)
test           = ((N_ELEMENTS(szdt0) GT 1) OR (N_ELEMENTS(szdt1) GT 1)) OR   $
                 (N_ELEMENTS(xdata) NE N_ELEMENTS(ydata))
IF (test[0]) THEN BEGIN
  ;;  Bad input
  MESSAGE,badinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Define data
px             = REFORM(xdata)
py             = REFORM(ydata)
;;  Define default [X,Y]-Range
test_x         = FINITE(px)
test_y         = FINITE(py)
good_xra       = WHERE(test_x,gdx)
good_yra       = WHERE(test_y,gdy)
good_xy        = WHERE(test_x AND test_y,gdxy)
test           = (gdx[0] EQ 0) OR (gdy[0] EQ 0) OR (gdxy[0] LT 10)
IF (test[0]) THEN BEGIN
  ;;  Bad input
  MESSAGE,nofint_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Redefine arrays to contain only good data
px             = TEMPORARY(px[good_xy])
py             = TEMPORARY(py[good_xy])
;;  Sort by x
sp             = SORT(px)
px             = TEMPORARY(px[sp])
py             = TEMPORARY(py[sp])
nn             = N_ELEMENTS(px)
;;  Define ranges
mnmx_x         = [MIN(px[good_xra],/NAN),MAX(px[good_xra],/NAN)]
mnmx_y         = [MIN(py[good_yra],/NAN),MAX(py[good_yra],/NAN)]
IF (mnmx_x[1] LT mnmx_x[0]) THEN mnmx_x = REVERSE(mnmx_x)
IF (mnmx_y[1] LT mnmx_y[0]) THEN mnmx_y = REVERSE(mnmx_y)
def_xyran      = [MIN([mnmx_x,mnmx_y],/NAN),MAX([mnmx_x,mnmx_y],/NAN)]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check WINDN
test           = test_window_number(wind_n,DAT_OUT=windn)
IF (test[0] EQ 0) THEN windn = 0L
;;  Check [X,Y]TITLE
test           = (SIZE(xtitle,/TYPE) NE 7) OR (N_ELEMENTS(xtitle) LT 1)
IF (test[0]) THEN xttl = 'XTITLE' ELSE xttl = xtitle[0]
test           = (SIZE(ytitle,/TYPE) NE 7) OR (N_ELEMENTS(ytitle) LT 1)
IF (test[0]) THEN yttl = 'YTITLE' ELSE yttl = ytitle[0]
;;  Check FILE_NAME
test           = (SIZE(file_name,/TYPE) NE 7) OR (N_ELEMENTS(file_name) LT 1)
IF (test[0]) THEN save_on = 0b ELSE save_on = 1b
IF (save_on[0]) THEN fname = file_name[0]
;;  Check [X,Y]LOG
test           = (is_a_number(x_log,/NOMSSG) EQ 0) OR ~KEYWORD_SET(x_log)
IF (test[0]) THEN xlog = 0b ELSE xlog = 1b
test           = (is_a_number(y_log,/NOMSSG) EQ 0) OR ~KEYWORD_SET(y_log)
IF (test[0]) THEN ylog = 0b ELSE ylog = 1b
;;  Check [X,Y]MIN
test           = (is_a_number(xmin,/NOMSSG) EQ 0)
IF (test[0]) THEN x_min = def_xyran[0] ELSE x_min = xmin[0]
test           = (is_a_number(ymin,/NOMSSG) EQ 0)
IF (test[0]) THEN y_min = def_xyran[0] ELSE y_min = ymin[0]
;;  Check [X,Y]MAX
test           = (is_a_number(xmax,/NOMSSG) EQ 0)
IF (test[0]) THEN x_max = def_xyran[1] ELSE x_max = xmax[0]
test           = (is_a_number(ymax,/NOMSSG) EQ 0)
IF (test[0]) THEN y_max = def_xyran[1] ELSE y_max = ymax[0]
;;  Check PLIMITS
def_xran       = [x_min[0],x_max[0]]
def_yran       = [y_min[0],y_max[0]]
IF (xlog[0]) THEN xminor = 9L ELSE xminor = 10L
IF (ylog[0]) THEN yminor = 9L ELSE yminor = 10L
lim0           = {XTITLE:xttl,YTITLE:yttl,YLOG:xlog,XLOG:ylog,YMINOR:yminor,XMINOR:xminor,$
                  XRANGE:def_xran,YRANGE:def_yran}
test_plim      = format_limits_struc(LIMITS=plimits,PTYPE=0)
IF (SIZE(test_plim,/TYPE) NE 8) THEN BEGIN
  plim = def_pstr
  extract_tags,plim,lim0
ENDIF ELSE BEGIN
  extract_tags,plim,lim0
  extract_tags,plim,test_plim
ENDELSE
;;  Define [X,Y]RANGE
xran           = struct_value(plim,'XRANGE',INDEX=i_xran,DEFAULT=def_xran)
yran           = struct_value(plim,'YRANGE',INDEX=i_yran,DEFAULT=def_yran)
;;  Check CLIMITS
test_clim      = format_limits_struc(LIMITS=climits,PTYPE=2)
IF (SIZE(test_clim,/TYPE) NE 8) THEN clim = 0 ELSE clim = test_clim
;;  Check N_SUM
test           = (is_a_number(n_sum,/NOMSSG) EQ 0)
IF (test[0]) THEN nsum = def_nsum[0] ELSE nsum = (LONG(n_sum[0]) < (nn[0]/5L)) > 1
;;----------------------------------------------------------------------------------------
;;  Downsample if necessary
;;----------------------------------------------------------------------------------------
IF (nsum[0] GT 1) THEN BEGIN
  ;;  User wants to limit data points shown on plot (will not alter contour calculations)
  ;;    --> *** NSUM keyword screws up location of points ***
  px_show = px[0L:*:nsum[0]]
  py_show = py[0L:*:nsum[0]]
ENDIF ELSE BEGIN
  px_show = px
  py_show = py
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Open X-window window
;;----------------------------------------------------------------------------------------
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*7d-1
win_str        = {RETAIN:2,XSIZE:wsz[1],YSIZE:wsz[1],XPOS:10,YPOS:10}
lbw_window,WIND_N=windn[0],_EXTRA=win_str
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Initialize and construct plot output
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
WSET,windn[0]
WSHOW,windn[0]
  ;;  Initialize plot
  PLOT,px,py,_EXTRA=plim
    ;;  Plot data points
    OPLOT,px,py,PSYM=symb[0],SYMSIZE=syms[0]
    ;;  Overplot contours
    density_contour_plot,px,py,XMIN=xran[0],XMAX=xran[1],NX=nx,                   $
                               YMIN=yran[0],YMAX=yran[1],NY=ny,CLABS=clabs,       $
                               XTTL=struct_value(plim,'XTITLE',DEFAULT=xttl[0]),  $
                               YTTL=struct_value(plim,'YTITLE',DEFAULT=yttl[0]),  $
                               /OVERPLOT,LIMITS=clim,SMWDTH=smwdth,               $
                               X_LOG=xlog,Y_LOG=ylog,SMCONT=smcont,               $
                               USE_SMOOTH=use_smooth,LEVEL_PER=level_per,         $
                               CPATH_OUT=cpath_out,HIST2D_OUT=hist2d_out,         $
                               CLIM_OUT=clim_out,RAN_H2DN=ran_h2dn
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define path info stuff
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
IF (SIZE(cpath_out,/TYPE) NE 8) THEN STOP
;;  Define path info parameters
xy_cpaths      = REFORM(cpath_out.XY)          ;;  [2,N]-Element array
c_info         = cpath_out.INFO                ;;  [C]-Element [structure] array
nconts         = N_ELEMENTS(c_info)            ;;  # of contours = C
IF (SIZE(xy_cpaths,/N_DIMENSIONS) NE 2) THEN BEGIN
  MESSAGE,'No contour paths were returned',/INFORMATIONAL,/CONTINUE
  ;;--------------------------------------------------------------------------------------
  ;;  Still plot something
  ;;--------------------------------------------------------------------------------------
  !P.MULTI       = 0
  WSET,windn[0]
  WSHOW,windn[0]
  PLOT,px_show,py_show,_EXTRA=plim
    OPLOT,px_show,py_show,PSYM=symb[0],SYMSIZE=syms[0],COLOR=50L
  ;;--------------------------------------------------------------------------------------
  ;;  Still save something
  ;;--------------------------------------------------------------------------------------
  IF (save_on[0]) THEN BEGIN
    !P.MULTI       = 0
    popen,fname[0],_EXTRA=postruc
      PLOT,px_show,py_show,_EXTRA=plim
        OPLOT,px_show,py_show,PSYM=symb[0],SYMSIZE=syms[0],COLOR=50L
    pclose
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Return to user
  ;;--------------------------------------------------------------------------------------
  RETURN
ENDIF
;;  Define level info
lev_nums       = c_info.LEVEL
unq            = UNIQ(lev_nums,SORT(lev_nums))
n_lev          = N_ELEMENTS(unq)                                ;;  L = # of unique levels to be plotted (may differ from # of contours)
lev_n_ind      = c_info.N                                       ;;  [L]-Element [numeric] array of index array elements from PATH_XY
lev_ind_off    = c_info.OFFSET[0]                               ;;  [L]-Element [numeric] array of offsets
;;  Define contour colors
mnmx_col       = [50L,250L]
ccol_fac       = (mnmx_col[1] - mnmx_col[0])/(n_lev[0] - 1L)
def_c_cols     = LINDGEN(n_lev[0])*ccol_fac[0] + mnmx_col[0]
all_cols       = [30L,def_c_cols]
;;  Define number of points and dummy array of indices
all_ind        = LINDGEN(nn[0])
;;  Define default contour limits structure (in case CLIMITS undefined)
def_clim       = {NLEVELS:n_lev[0],C_COLORS:def_c_cols}
clim           = clim_out
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Determine points inside/outside of each contour
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
tags           = 'T'+num2int_str(LINDGEN(50),NUM_CHAR=3L,/ZERO_PAD)
;;  Define all contours
FOR j=0L, nconts[0] - 1L DO BEGIN
  lev_nj      = lev_nums[j]
  inds_j      = [LINDGEN(lev_n_ind[j]),0L]
  i0_j        = lev_ind_off[j]
  xy_0        = xy_cpaths[*, (inds_j + i0_j[0]) ]
  str_element,xy_cpth,tags[j],xy_0,/ADD_REPLACE
  ;;  Find points inside each contour (use 2D winding number to determine)
  vt0         = TRANSPOSE(xy_0)
  test        = poly_winding_number2d(px_show,py_show,vt0,/INCLUDE_EDGE,/NOMSSG)
  str_element,test_str,tags[j],test,/ADD_REPLACE
  good0       = WHERE(test NE 0,gdin)
  IF (gdin[0] EQ 0) THEN good0 = [good0[0]]
  str_element,gind_str,tags[j],good0,/ADD_REPLACE
ENDFOR
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Combine all points by contour level
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Initialize level structure
FOR j=0L, n_lev[0] - 1L DO str_element,glev_str,tags[j],-1L,/ADD_REPLACE

FOR j=0L, nconts[0] - 1L DO BEGIN
  glev        = WHERE(lev_nums EQ j[0],gdl)
  IF (gdl[0] EQ 0) THEN CONTINUE
  dumb        = TEMPORARY(gind0)                  ;;  Erase copy of old array
  FOR k=0L, gdl[0] - 1L DO BEGIN
    ii   = glev[k]
    temp = gind_str.(ii)
    test = (k EQ 0) OR (N_ELEMENTS(gind0) EQ 0)
    IF (test[0]) THEN gind0 = temp ELSE gind0 = [temp,gind0]
  ENDFOR
  good0       = WHERE(gind0 GE 0,gd0)
  IF (gd0[0] GT 0) THEN gind = gind0[good0] ELSE gind = [-1L]
  sp          = SORT(gind)
  gind        = TEMPORARY(gind[sp])
  str_element,glev_str,tags[j],gind,/ADD_REPLACE
ENDFOR
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Find intersection at each level
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Initialize structure with points outside lowest level contour
l0             = all_ind
l1             = glev_str.(0)
ibtwn          = cgsetdifference(l0,l1,SUCCESS=success)   ;;  Find elements in L0 that are NOT in L1
IF (success[0] GT 0) THEN ind = ibtwn ELSE ind = all_ind
struc          = {IND:ind,COLOR:all_cols[0]}
str_element,gcont_str,tags[0],struc,/ADD_REPLACE
;;  Find points for each intermediate contour
FOR j=0L, n_lev[0] - 2L DO BEGIN
  k       = j + 1L
  l0      = glev_str.(j)
  l1      = glev_str.(k)
  IF (l1[0] LT 0) THEN BEGIN
    ;;  Use all of the lower level indices but the upper level color
    ind     = l0
    struc   = {IND:ind,COLOR:all_cols[k]}
  ENDIF ELSE BEGIN
    ;;  Find elements in L0 that are NOT in L1
    ibtwn   = cgsetdifference(l0,l1,SUCCESS=success)
    IF (success[0] GT 0) THEN BEGIN
      ind = ibtwn
      col = all_cols[k]
    ENDIF ELSE BEGIN
      ;;  Use all of the lower level indices but the upper level color
      ind = l0
      col = all_cols[k]
    ENDELSE
    struc   = {IND:ind,COLOR:col[0]}
  ENDELSE
  str_element,gcont_str,tags[k],struc,/ADD_REPLACE
ENDFOR
;;  Add points inside highest level contour
ibtwn          = glev_str.(n_lev[0] - 1L)
struc          = {IND:ibtwn,COLOR:all_cols[n_lev[0]]}
str_element,gcont_str,tags[n_lev[0]],struc,/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Replot points in color-coded manner
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
n_gcont        = N_TAGS(gcont_str)
ncnt           = 0L
FOR j=0L, n_gcont[0] - 1L DO BEGIN
  gind  = gcont_str.(j).IND
  IF (gind[0] GE 0) THEN BEGIN
    ncnt          += N_ELEMENTS(gind)
    ;;  Add X and Y points to output structure
    str_element,gcont_str,tags[j]+'.X',px_show[gind],/ADD_REPLACE
    str_element,gcont_str,tags[j]+'.Y',py_show[gind],/ADD_REPLACE
  ENDIF ELSE BEGIN
    ;;  Add dummy NaNs to output structure
    str_element,gcont_str,tags[j]+'.X',[d],/ADD_REPLACE
    str_element,gcont_str,tags[j]+'.Y',[d],/ADD_REPLACE
  ENDELSE
ENDFOR
;;  Inform user of mismatch in number of points but continue on...
IF (nn[0] NE ncnt[0]) THEN BEGIN
  PRINT,';;  Nx = ',nn[0],',   N_ind = ',ncnt[0]
ENDIF
!P.MULTI       = 0
dxpos          = 0.025
xpos0          = 0.900
ypos0          = 0.250
WSET,windn[0]
WSHOW,windn[0]
  ;;  Initialize plot
  PLOT,px_show,py_show,_EXTRA=plim
    ;;  Plot color-coded data points
    FOR j=0L, n_gcont[0] - 1L DO BEGIN
      gind           = gcont_str.(j).IND
      tcol           = gcont_str.(j).COLOR
      IF (N_ELEMENTS(gind) LE 1) THEN BEGIN
        ;;  Either plot single point or nothing and jump to next iteration
        IF (gind[0] LT 0) THEN CONTINUE ELSE OPLOT,[px_show[gind[0]]],[py_show[gind[0]]],PSYM=symb[0],SYMSIZE=syms[0],COLOR=tcol[0]
      ENDIF ELSE BEGIN
        ;;  Plot color-coded points as dots
        OPLOT,px_show[gind],py_show[gind],PSYM=symb[0],SYMSIZE=syms[0],COLOR=tcol[0]
      ENDELSE
    ENDFOR
    ;;  Overplot contours
    lbw_oplot_clines_from_struc,cpath_out,C_COLORS=clim.C_COLORS,THICK=thck[0],/DATA
    ;;  Output plot levels
    IF (SIZE(clim_out,/TYPE) EQ 8) THEN BEGIN
      lev_vals = struct_value(clim_out,'LEVELS',INDEX=i_lval,DEFAULT=-1)
      IF (i_lval[0] GE 0) THEN BEGIN
        lev_str = STRTRIM(STRING(lev_vals,FORMAT='(g10.3)'))
        yposi   = ypos0[0]
        xposi   = xpos0[0]
        dypos   = 0d0
        FOR ll=0L, N_ELEMENTS(lev_str) - 1L DO BEGIN
          IF (ll[0] NE 0) THEN yposi += dypos[0] ELSE yposi = ypos0[0]
          XYOUTS,xposi[0],yposi[0],lev_str[ll],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=1.5e0,COLOR=clim_out.C_COLORS[ll],WIDTH=dypos
        ENDFOR
        ;;  Output max value too
        xposi  += dxpos[0]
        XYOUTS,xposi[0],ypos0[0],'Max = '+STRTRIM(STRING(MAX(ABS(ran_h2dn),/NAN),FORMAT='(g10.3)')),CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=1.5e0
      ENDIF
    ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Save color-coded plot (if desired)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
IF (save_on[0]) THEN BEGIN
  ;;  Initialize PS File
  popen,fname[0],_EXTRA=postruc
    !P.MULTI       = 0
    ;;  Initialize plot
    PLOT,px_show,py_show,_EXTRA=plim
      ;;  Plot color-coded data points
      FOR j=0L, n_gcont[0] - 1L DO BEGIN
        gind = gcont_str.(j).IND
        tcol = gcont_str.(j).COLOR
        IF (N_ELEMENTS(gind) LE 1) THEN BEGIN
          IF (gind[0] LT 0) THEN CONTINUE ELSE OPLOT,[px_show[gind[0]]],[py_show[gind[0]]],PSYM=symb[0],SYMSIZE=syms[0],COLOR=tcol[0]
        ENDIF ELSE BEGIN
          OPLOT,px_show[gind],py_show[gind],PSYM=symb[0],SYMSIZE=syms[0],COLOR=tcol[0]
        ENDELSE
      ENDFOR
      ;;  Overplot contours
      lbw_oplot_clines_from_struc,cpath_out,C_COLORS=clim.C_COLORS,THICK=thck[0],/DATA
      ;;  Output plot levels
      IF (SIZE(clim_out,/TYPE) EQ 8) THEN BEGIN
        lev_vals = struct_value(clim_out,'LEVELS',INDEX=i_lval,DEFAULT=-1)
        IF (i_lval[0] GE 0) THEN BEGIN
          lev_str = STRTRIM(STRING(lev_vals,FORMAT='(g10.3)'))
          yposi   = ypos0[0]
          xposi   = xpos0[0]
          dypos   = 0d0
          FOR ll=0L, N_ELEMENTS(lev_str) - 1L DO BEGIN
            IF (ll[0] NE 0) THEN yposi += dypos[0] ELSE yposi = ypos0[0]
            XYOUTS,xposi[0],yposi[0],lev_str[ll],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=1.5e0,COLOR=clim_out.C_COLORS[ll],WIDTH=dypos
          ENDFOR
          ;;  Output max value too
          xposi  += dxpos[0]
          XYOUTS,xposi[0],ypos0[0],'Max = '+STRTRIM(STRING(MAX(ABS(ran_h2dn),/NAN),FORMAT='(g10.3)')),CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=1.5e0
        ENDIF
      ENDIF
  pclose
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END























