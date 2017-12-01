;;  temp_test_2d_density_contour_wrapper_crib.pro

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;  Setup margins
!X.MARGIN      = [15,5]
!Y.MARGIN      = [8,4]
;;  Setup log-scale tick marks
tickpows       = DINDGEN(51) - 25d0
ticksigns      = sign(tickpows)
signs_str      = ['-','+']
xytns_str      = STRARR(N_ELEMENTS(ticksigns))
good_plus      = WHERE(ticksigns GE 0,gdpl,COMPLEMENT=good__neg,NCOMPLEMENT=gdng)
IF (gdng GT 0) THEN xytns_str[good__neg] = signs_str[0]
IF (gdpl GT 0) THEN xytns_str[good_plus] = signs_str[1]
xytv           = 1d1^tickpows
tickpow_str    = xytns_str+STRTRIM(STRING(ABS(tickpows),FORMAT='(I2.2)'),2)
xytn           = '10!U'+tickpow_str+'!N'
;;----------------------------------------------------------------------------------------
;;  Construct dummy points
;;----------------------------------------------------------------------------------------
nn             = 500L
z1d0           = RANDOMU(seed0,nn[0],/DOUBLE,GAMMA=3)
z1d1           = RANDOMU(seed1,nn[0],/DOUBLE,POISSON=3)
z1d2           = RANDOMU(seed2,nn[0],/DOUBLE,POISSON=35)
z1d3           = RANDOMU(seed3,nn[0],/DOUBLE,POISSON=10)
PRINT,';;',minmax(z1d0,/POS) & $
PRINT,';;',minmax(z1d1,/POS) & $
PRINT,';;',minmax(z1d2,/POS) & $
PRINT,';;',minmax(z1d3,/POS)

;;  Setup Plot Stuff
xyran          = [1d-1,1d2]
symb           = 3
n_sum          = 1L
;;  Define CONTOUR LIMITS structure
nlev           = 5L
ccols          = LINDGEN(nlev)*(250L - 30L)/(nlev - 1L) + 30L
con_lim        = {NLEVELS:nlev,C_COLORS:ccols}
;;  Determine XY-tick marks
good_tv        = WHERE(xytv GE xyran[0] AND xytv LE xyran[1],gdtv)
xytv_0         = xytv[good_tv]
xytn_0         = xytn[good_tv]
xyts_0         = gdtv - 1L
;;  Define plot titles
xttle          = 'X [x-units]'
yttle          = 'Y [y-units]'
pttle          = 'Y vs. X'
;;  Define plot position
plotposi       = [0.1,0.1,0.9,0.9]
;;  Define plot structure
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,    $
                  YMINOR:9L,XMINOR:9L,XRANGE:xyran,YRANGE:xyran,YSTYLE:1,XSTYLE:1, $
                  XTICKNAME:xytn_0,XTICKV:xytv_0,XTICKS:xyts_0,                    $
                  YTICKNAME:xytn_0,YTICKV:xytv_0,YTICKS:xyts_0,                    $
                  POSITION:plotposi}
;;  Define
;;    - number of histogram bins to use
;;    - symbol to use for plotting points
;;    - symbol size
;;    - thickness of lines
;;    - line style for "info" lines
nxsm           = 30L
symb           = 3
syms           = 2.0
thck           = 2.0
lsty           = 2
;px             = z1d0 + z1d1
;py             = z1d2
;px             = z1d0
;py             = z1d2 + z1d1
px             = [z1d0,z1d2]
py             = [z1d1,z1d3]
;;----------------------------------------------------------------------------------------
;;  Plot color-coded scatter plot with contours
;;----------------------------------------------------------------------------------------
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgerrormsg.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgreverseindices.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgsetunion.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgsetdifference.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgsetintersection.pro

.compile isleft2d.pro
.compile poly_winding_number2d.pro
.compile /Users/lbwilson/Desktop/temp_idl/density_contour_plot_wrapper.pro

file_name      = 'test_density_contour'

density_contour_plot_wrapper,px,py,                                              $
                             PLIMITS=pstr,WIND_N=1,FILE_NAME=file_name,          $
                             XTITLE=xttle,YTITLE=yttle,/YLOG,/XLOG,              $
                             XMIN=xyran[0],XMAX=xyran[1],NX=nxsm[0],             $
                             YMIN=xyran[0],YMAX=xyran[1],NY=nxsm[0],             $
                             CLIMITS=con_lim,/SMCONT,                            $
                             CPATH_OUT=cpath_out,HIST2D_OUT=hist2d_out,          $  ;; outputs
                             _EXTRA=ex_str




























;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Open window and plot
;;----------------------------------------------------------------------------------------
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*7d-1
win_ttl        = 'Test Plot'
win_str        = {RETAIN:2,XSIZE:wsz[1],YSIZE:wsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
lbw_window,WIND_N=1,_EXTRA=win_str
;;  Plot output
WSET,1
WSHOW,1
  ;;  Initialize plot
  PLOT,px,py,_EXTRA=pstr
    ;;  Plot data points
    OPLOT,px,py,PSYM=symb[0],SYMSIZE=syms[0]
    ;;  Overplot contours
    density_contour_plot,px,py,XMIN=xyran[0],XMAX=xyran[1],NX=nxsm[0],  $
                               YMIN=xyran[0],YMAX=xyran[1],NY=nxsm[0],  $
                               /OVERPLOT,LIMITS=con_lim,                $
                               X_LOG=pstr.XLOG,Y_LOG=pstr.YLOG,/SMCONT, $
                               CPATH_OUT=cpath_out,HIST2D_OUT=hist2d_out
;;----------------------------------------------------------------------------------------
;;  Define path info stuff
;;----------------------------------------------------------------------------------------
;;  Define path info parameters
xy_cpaths      = REFORM(cpath_out.XY)          ;;  [2,N]-Element array
c_info         = cpath_out.INFO                ;;  [C]-Element [structure] array
nconts         = N_ELEMENTS(c_info)            ;;  # of contours = C
;;  Define level info
lev_nums       = c_info.LEVEL
unq            = UNIQ(lev_nums,SORT(lev_nums))
n_lev          = N_ELEMENTS(unq)               ;;  L = # of unique levels to be plotted (may differ from # of contours)
lev_n_ind      = c_info.N                      ;;  [L]-Element [numeric] array of index array elements from PATH_XY
lev_ind_off    = c_info.OFFSET[0]              ;;  [L]-Element [numeric] array of offsets
;;  Define contour colors
mnmx_col       = [50L,250L]
ccol_fac       = (mnmx_col[1] - mnmx_col[0])/(n_lev[0] - 1L)
def_c_cols     = LINDGEN(n_lev[0])*ccol_fac[0] + mnmx_col[0]

PRINT,';;',nconts[0],n_lev[0]
;;           8           5

;;----------------------------------------------------------------------------------------
;;  Determine points inside/outside of each contour
;;----------------------------------------------------------------------------------------
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgerrormsg.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgreverseindices.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgsetunion.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgsetdifference.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgsetintersection.pro

.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/setintersection.pro
.compile isleft2d.pro
.compile poly_winding_number2d.pro


tags           = 'T'+num2int_str(LINDGEN(50),NUM_CHAR=3L,/ZERO_PAD)
;;  Define all contours
FOR j=0L, nconts[0] - 1L DO BEGIN                                                   $
  lev_nj = lev_nums[j]                                                            & $
  inds_j = [LINDGEN(lev_n_ind[j]),0L]                                             & $
  i0_j   = lev_ind_off[j]                                                         & $
  xy_0   = xy_cpaths[*, (inds_j + i0_j[0]) ]                                      & $
  str_element,xy_cpth,tags[j],xy_0,/ADD_REPLACE                                   & $
  vt0    = TRANSPOSE(xy_0)                                                        & $
  test   = poly_winding_number2d(px,py,vt0,/INCLUDE_EDGE,/NOMSSG)                 & $
  str_element,test_str,tags[j],test,/ADD_REPLACE                                  & $
  good0  = WHERE(test NE 0,gdin)                                                  & $
  str_element,gind_str,tags[j],good0,/ADD_REPLACE

gind0          = 0L
FOR j=0L, nconts[0] - 1L DO BEGIN                                                   $
  glev  = WHERE(lev_nums EQ j[0],gdl)                                             & $
  IF (gdl[0] EQ 0) THEN CONTINUE                                                  & $
  dumb  = TEMPORARY(gind0)                                                        & $
  FOR k=0L, gdl[0] - 1L DO BEGIN                                                    $
    ii = glev[k]                                                                  & $
    test = (k EQ 0) OR (N_ELEMENTS(gind0) EQ 0)                                   & $
    temp = gind_str.(ii)                                                          & $
    IF (test[0]) THEN gind0 = temp ELSE gind0 = [temp,gind0]                      & $
  ENDFOR                                                                          & $
  good0  = WHERE(gind0 GE 0,gd0)                                                  & $
  IF (gd0[0] GT 0) THEN gind = gind0[good0] ELSE gind = -1L                       & $
  str_element,glev_str,tags[j],gind,/ADD_REPLACE

;;  Find intersection at each level
nx             = N_ELEMENTS(px)
all_ind        = LINDGEN(nx[0])
all_cols       = [30L,def_c_cols]
l0             = all_ind
l1             = glev_str.(0)
ibtwn          = cgsetdifference(l0,l1,SUCCESS=success)   ;;  Find elements in L0 that are NOT in L1
struc          = {IND:ibtwn,COLOR:all_cols[0]}
str_element,gcont_str,tags[0],struc,/ADD_REPLACE

FOR j=0L, n_lev[0] - 2L DO BEGIN                                                    $
  k  = j + 1L                                                                     & $
  l0 = glev_str.(j)                                                               & $
  l1 = glev_str.(k)                                                               & $
;  IF (j EQ 0) THEN l0 = all_ind ELSE l0 = glev_str.(k)                            & $
;  l1 = glev_str.(j)                                                               & $
  ibtwn = cgsetdifference(l0,l1,SUCCESS=success)                                  & $
  IF (success[0] GT 0) THEN ind = ibtwn ELSE ind = -1L                            & $
  struc = {IND:ind,COLOR:all_cols[j+1L]}                                          & $
  str_element,gcont_str,tags[j+1L],struc,/ADD_REPLACE

ibtwn          = glev_str.(n_lev[0] - 1L)
struc          = {IND:ibtwn,COLOR:all_cols[n_lev[0]]}
str_element,gcont_str,tags[n_lev[0]],struc,/ADD_REPLACE

;;----------------------------------------------------------------------------------------
;;  Replot points in color-coded manner
;;----------------------------------------------------------------------------------------
n_gcont        = N_TAGS(gcont_str)
thck           = 2
postruc        = {LANDSCAPE:1,UNITS:'inches',XSIZE:8.,YSIZE:8.,ASPECT:1.}
;;  Plot output
WSET,1
WSHOW,1
  ;;  Initialize plot
  PLOT,px,py,_EXTRA=pstr
    ;;  Plot data points
    FOR j=0L, n_gcont[0] - 1L DO BEGIN                                              $
      gind = gcont_str.(j).IND                                                    & $
      tcol = gcont_str.(j).COLOR                                                  & $
      OPLOT,px[gind],py[gind],PSYM=symb[0],SYMSIZE=syms[0],COLOR=tcol[0]
    ;;  Overplot contours
    lbw_oplot_clines_from_struc,cpath_out,C_COLORS=con_lim.C_COLORS,THICK=thck[0],/DATA


;;  Test saved version
popen,'test_density_contour',_EXTRA=postruc
  ;;  Initialize plot
  PLOT,px,py,_EXTRA=pstr
    ;;  Plot data points
    FOR j=0L, n_gcont[0] - 1L DO BEGIN                                              $
      gind = gcont_str.(j).IND                                                    & $
      tcol = gcont_str.(j).COLOR                                                  & $
      OPLOT,px[gind],py[gind],PSYM=symb[0],SYMSIZE=syms[0],COLOR=tcol[0]
    ;;  Overplot contours
    lbw_oplot_clines_from_struc,cpath_out,C_COLORS=con_lim.C_COLORS,THICK=thck[0],/DATA
pclose
























