;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;; => Electron mass [kg]
mp             = 1.6726217770d-27     ;; => Proton mass [kg]
ma             = 6.6446567500d-27     ;; => Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;; => Speed of light in vacuum [m/s]
epo            = 8.8541878170d-12     ;; => Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;; => Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;; => Fundamental charge [C]
kB             = 1.3806488000d-23     ;; => Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;; => Planck Constant [J s]
GG             = 6.6738400000d-11     ;; => Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;; => Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;; => Energy associated with 1 eV of energy [J]
;; => Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K
R_E            = 6.37814d3            ;; => Earth's Equitorial Radius [km]

wpefac         = SQRT(1d6*qq[0]^2/(epo[0]*me[0]))
wpifac         = SQRT(1d6*qq[0]^2/(epo[0]*mp[0]))
wcefac         = qq[0]*1d-9/me[0]
wcifac         = qq[0]*1d-9/mp[0]
ckm            = c[0]*1d-3            ;;  m --> km
;;  Setup margins
!X.MARGIN      = [15,5]
!Y.MARGIN      = [8,4]
;;----------------------------------------------------------------------------------------
;; => Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init

;;  Compile critical Mach number routines
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/genarr.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/zbrent.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/crit_mf.pro

.compile shock_enthalpy_rate
.compile read_thm_j_E_S_corr
.compile thm_load_bowshock_rhsolns
.compile thm_load_bowshock_ascii
.compile find_j2_eta_k_from_h
.compile temp_calc_j2_eta_k_S_from_h

.compile get_thm_entropy_diss_data
.compile temp_thm_entropy_diss_plots
;;----------------------------------------------------------------------------------------
;;  Get ASCII data
;;----------------------------------------------------------------------------------------
thm_load_bowshock_ascii,R_STRUCT=Jo_dE_DS_corr

thm_load_bowshock_ascii,R_STRUCT=Jo_dE_US_corr,/UPSAMPLE

dummy          = get_thm_entropy_diss_data(/UPSAMPLE,JES_STR=Jo_dE_US_corr)

;;  Define parameters
Evec_nifgse    = dummy.MICRO_PARAMS.EVEC_NIF_GSE_JES        ;;  E [mV/m, in NIF and GSE basis]
jvec_nifncb    = dummy.MICRO_PARAMS.JVEC_NIF_NCB_JES        ;;  j-vector [µA m^(-2), in NIF and NCB basis]
;;  Calculate |∂E|    [mV/m]
Emag_nifgse    = SQRT(TOTAL(Evec_nifgse^2,2L,/NAN))
;;  Calculate |j|  [µA m^(-2)]
jmag_nifncb    = SQRT(TOTAL(jvec_nifncb^2,2L,/NAN))

;;    Let ∆∑ = (ƒ T ∆s)/∆t
;;
;;  Define £ = (*eta* |j|^2)/∆∑  [unitless]
r_etajsq_dsdt  = dummy.MICRO_PARAMS.RAT_ETAJSQ_DSDT         ;;  [N,4]-Element array
;;  Define € = |(∂E . j)|/∆∑  [unitless]
r_Edotj_dsdt   = dummy.MICRO_PARAMS.RAT_EDOTJ_DSDT          ;;  [N]-Element array
;;  Define ø = (*eta* |j|^2)/(∆K/∆t)  [unitless]
r_etajsq_dKdt  = dummy.MICRO_PARAMS.RAT_ETAJSQ_DKDT         ;;  [N]-Element array
;;  Define Ω = |Jo . ∂E|/(∆K/∆t)  [unitless]
r_Edotj_dKdt   = dummy.MICRO_PARAMS.RAT_EDOTJ_DKDT          ;;  [N]-Element array
;;----------------------------------------------------------------------------------------
;;  Setup plot parameters
;;----------------------------------------------------------------------------------------
;;  Setup windows
WINDOW,1,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Energy Dissipation 1'
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

upbasis        = '_upsample'
symb           = 3
n_sum          = 1L
;;  Define CONTOUR LIMITS structure
nlev           = 5L
ccols          = LINDGEN(nlev)*(250L - 30L)/(nlev - 1L) + 30L
con_lim        = {NLEVELS:nlev,C_COLORS:ccols}
;;  Define Y = X line
yx_line_ra     = [1d-8,1d6]
yx_line_x      = DINDGEN(10)*(yx_line_ra[1] - yx_line_ra[0])/9 + yx_line_ra[0]
yx_line_y      = yx_line_x
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot (*eta* |j|^2)/∆∑ vs. |(∂E . j)|/∆∑
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define XY Data and Ranges
xdata          = r_Edotj_dsdt
ydata          = REFORM(r_etajsq_dsdt[*,0])
xran           = [1d-3,1d6]
yran           = [1d-8,1d6]
;xyran          = [1d-8,1d6]
;;  Define only finite, positive points
testf          = FINITE(xdata) AND FINITE(ydata)
testp          = (xdata GT 0)  AND (ydata GT 0)
good           = WHERE(testf AND testp,gd)
gxdat          = xdata[good]
gydat          = ydata[good]
;;  Sort by X
sp             = SORT(gxdat)
px             = gxdat[sp]
py             = gydat[sp]
;;  NSUM keyword screws up location of points
;;    -->  Try just taking every N_SUM point in array?
n_sum          = 5L
nsum_str       = STRTRIM(STRING(n_sum[0],FORMAT='(I3.3)'),2L)
gran           = [0L,gd[0]]
ng             = gd[0]/n_sum[0]
gfac           = (gran[1] - gran[0])/(ng[0] - 1L)
gind           = LINDGEN(ng[0])*gfac[0] + gran[0]
;;  Determine tick marks
good_tv        = WHERE(xytv GE xran[0] AND xytv LE xran[1],gdtv)
xxtv_0         = xytv[good_tv]
xxtn_0         = xytn[good_tv]
xxts_0         = gdtv - 1L
good_tv        = WHERE(xytv GE yran[0] AND xytv LE yran[1],gdtv)
yytv_0         = xytv[good_tv]
yytn_0         = xytn[good_tv]
yyts_0         = gdtv - 1L
;;  Define plot titles
xttle          = '|Jo.dE|/(ds/dt) [unitless]'
yttle          = '(*eta* |Jo|^2)/(ds/dt) [unitless]'
pttle          = 'Y_psi vs. R_psi'
;;  Define plot structure
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,    $
                  YMINOR:9L,XMINOR:9L,XRANGE:xran,YRANGE:yran,YSTYLE:1,XSTYLE:1,   $
                  XTICKNAME:xxtn_0,XTICKV:xxtv_0,XTICKS:xxts_0,                    $
                  YTICKNAME:yytn_0,YTICKV:yytv_0,YTICKS:yyts_0}
nxsm           = 30L
symb           = 3
WSET,1
WSHOW,1
  ;;  Initialize plot
  PLOT,px,py,_EXTRA=pstr
    ;;  Plot data points [All when to X11]
    OPLOT,px,py,PSYM=symb[0],SYMSIZE=2.0
    ;;  Plot y = x line
    OPLOT,yx_line_x,yx_line_y,LINESTYLE=2,THICK=2
    ;;  Plot y = 1 line
    OPLOT,[1d0,1d0],yx_line_ra,LINESTYLE=2,THICK=2
    ;;  Plot x = 1 line
    OPLOT,yx_line_ra,[1d0,1d0],LINESTYLE=2,THICK=2
    ;;-------------------------------------
    ;;  Overplot contours
    ;;-------------------------------------
    density_contour_plot,px,py,XMIN=xyran[0],XMAX=xyran[1],NX=nxsm[0],  $
                               YMIN=xyran[0],YMAX=xyran[1],NY=nxsm[0],  $
                               /OVERPLOT,LIMITS=con_lim,                $
                               X_LOG=pstr.XLOG,Y_LOG=pstr.YLOG,/SMCONT, $
                               CPATH_OUT=cpath_out_0,HIST2D_OUT=hist2d_out
;;-------------------------------------
;;  Save Plot
;;-------------------------------------
symb           = 3
cpath_out      = cpath_out_0
nconts         = N_ELEMENTS(cpath_out.INFO)    ;;  # of contours
xy_cpaths      = REFORM(cpath_out.XY)          ;;  [2,N]-Element array
lev_nums       = cpath_out.INFO.LEVEL          ;;  Level number of contour

fname          = 'Ypsi_vs_Rpsi_contours_black-dots_NSUM-'+nsum_str[0]
popen,fname[0],/LAND
  ;;  Initialize plot
  PLOT,px[gind],py[gind],_EXTRA=pstr
    ;;  Plot data points
    OPLOT,px[gind],py[gind],PSYM=symb[0]
    ;;  Plot y = x line
    OPLOT,yx_line_x,yx_line_y,LINESTYLE=2,THICK=2
    ;;  Plot y = 1 line
    OPLOT,[1d0,1d0],yx_line_ra,LINESTYLE=2,THICK=2
    ;;  Plot x = 1 line
    OPLOT,yx_line_ra,[1d0,1d0],LINESTYLE=2,THICK=2
    ;;-------------------------------------
    ;;  Overplot contours
    ;;-------------------------------------
    FOR j=0L, nconts - 1L DO BEGIN $
      inds_j = [LINDGEN(cpath_out.INFO[j].N),0L]  & $
      i0_j   = cpath_out.INFO[j].OFFSET[0]        & $
      PLOTS,xy_cpaths[*, (inds_j + i0_j[0]) ],/DATA,COLOR=ccols[lev_nums[j]],THICK=thck
pclose

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot (*eta* |j|^2)/(∆K/∆t) vs. |(∂E . j)|/(∆K/∆t)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define XY Data and Ranges
xdata          = r_Edotj_dKdt
ydata          = REFORM(r_etajsq_dKdt[*,0])
xran           = [1d-3,1d6]
yran           = [1d-8,1d6]
;xyran          = [1d-8,1d6]
;;  Define only finite, positive points
testf          = FINITE(xdata) AND FINITE(ydata)
testp          = (xdata GT 0)  AND (ydata GT 0)
good           = WHERE(testf AND testp,gd)
gxdat          = xdata[good]
gydat          = ydata[good]
;;  Sort by X
sp             = SORT(gxdat)
px             = gxdat[sp]
py             = gydat[sp]
;;  NSUM keyword screws up location of points
;;    -->  Try just taking every N_SUM point in array?
n_sum          = 5L
nsum_str       = STRTRIM(STRING(n_sum[0],FORMAT='(I3.3)'),2L)
gran           = [0L,gd[0]]
ng             = gd[0]/n_sum[0]
gfac           = (gran[1] - gran[0])/(ng[0] - 1L)
gind           = LINDGEN(ng[0])*gfac[0] + gran[0]
;;  Determine tick marks
good_tv        = WHERE(xytv GE xran[0] AND xytv LE xran[1],gdtv)
xxtv_0         = xytv[good_tv]
xxtn_0         = xytn[good_tv]
xxts_0         = gdtv - 1L
good_tv        = WHERE(xytv GE yran[0] AND xytv LE yran[1],gdtv)
yytv_0         = xytv[good_tv]
yytn_0         = xytn[good_tv]
yyts_0         = gdtv - 1L
;;  Define plot titles
xttle          = '|Jo.dE|/(dk/dt) [unitless]'
yttle          = '(*eta* |Jo|^2)/(dk/dt) [unitless]'
pttle          = 'Z_psi vs. T_psi'
;;  Define plot structure
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,    $
                  YMINOR:9L,XMINOR:9L,XRANGE:xran,YRANGE:yran,YSTYLE:1,XSTYLE:1,   $
                  XTICKNAME:xxtn_0,XTICKV:xxtv_0,XTICKS:xxts_0,                    $
                  YTICKNAME:yytn_0,YTICKV:yytv_0,YTICKS:yyts_0}
nxsm           = 30L
symb           = 3
WSET,1
WSHOW,1
  ;;  Initialize plot
  PLOT,px,py,_EXTRA=pstr
    ;;  Plot data points [All when to X11]
    OPLOT,px,py,PSYM=symb[0],SYMSIZE=2.0
    ;;  Plot y = x line
    OPLOT,yx_line_x,yx_line_y,LINESTYLE=2,THICK=2
    ;;  Plot y = 1 line
    OPLOT,[1d0,1d0],yx_line_ra,LINESTYLE=2,THICK=2
    ;;  Plot x = 1 line
    OPLOT,yx_line_ra,[1d0,1d0],LINESTYLE=2,THICK=2
    ;;-------------------------------------
    ;;  Overplot contours
    ;;-------------------------------------
    density_contour_plot,px,py,XMIN=xyran[0],XMAX=xyran[1],NX=nxsm[0],  $
                               YMIN=xyran[0],YMAX=xyran[1],NY=nxsm[0],  $
                               /OVERPLOT,LIMITS=con_lim,                $
                               X_LOG=pstr.XLOG,Y_LOG=pstr.YLOG,/SMCONT, $
                               CPATH_OUT=cpath_out_1,HIST2D_OUT=hist2d_out
;;-------------------------------------
;;  Save Plot
;;-------------------------------------
symb           = 3
cpath_out      = cpath_out_1
nconts         = N_ELEMENTS(cpath_out.INFO)    ;;  # of contours
xy_cpaths      = REFORM(cpath_out.XY)          ;;  [2,N]-Element array
lev_nums       = cpath_out.INFO.LEVEL          ;;  Level number of contour

fname          = 'Zpsi_vs_Tpsi_contours_black-dots_NSUM-'+nsum_str[0]
popen,fname[0],/LAND
  ;;  Initialize plot
  PLOT,px[gind],py[gind],_EXTRA=pstr
    ;;  Plot data points
    OPLOT,px[gind],py[gind],PSYM=symb[0]
    ;;  Plot y = x line
    OPLOT,yx_line_x,yx_line_y,LINESTYLE=2,THICK=2
    ;;  Plot y = 1 line
    OPLOT,[1d0,1d0],yx_line_ra,LINESTYLE=2,THICK=2
    ;;  Plot x = 1 line
    OPLOT,yx_line_ra,[1d0,1d0],LINESTYLE=2,THICK=2
    ;;-------------------------------------
    ;;  Overplot contours
    ;;-------------------------------------
    FOR j=0L, nconts - 1L DO BEGIN $
      inds_j = [LINDGEN(cpath_out.INFO[j].N),0L]  & $
      i0_j   = cpath_out.INFO[j].OFFSET[0]        & $
      PLOTS,xy_cpaths[*, (inds_j + i0_j[0]) ],/DATA,COLOR=ccols[lev_nums[j]],THICK=thck
pclose

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot |∂E| vs. |j|
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define XY Data and Ranges
xdata          = jmag_nifncb
ydata          = Emag_nifgse
xyran          = [1d-2,5d2]
;;  Determine tick marks
good_tv        = WHERE(xytv GE xyran[0] AND xytv LE xyran[1],gdtv)
xytv_0         = xytv[good_tv]
xytn_0         = xytn[good_tv]
xyts_0         = gdtv - 1L
;;  Define plot titles
xttle          = '|Jo| [microamps/m^2]'
yttle          = '|dE| [mV/m]'
pttle          = '|dE| vs. |Jo|'
;;  Define plot structure
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,    $
                  YMINOR:9L,XMINOR:9L,XRANGE:xyran,YRANGE:xyran,YSTYLE:1,XSTYLE:1,$
                  XTICKNAME:xytn_0,XTICKV:xytv_0,XTICKS:xyts_0,                    $
                  YTICKNAME:xytn_0,YTICKV:xytv_0,YTICKS:xyts_0}
nxsm           = 30L
n_sum          = 10L
symb           = 3
WSET,1
WSHOW,1
  ;;  Initialize plot
  PLOT,xdata,ydata,_EXTRA=pstr
    ;;  Plot data points
    OPLOT,xdata,ydata,PSYM=symb[0],SYMSIZE=2.0,NSUM=n_sum[0]
    ;;  Plot y = x line
    OPLOT,xyran,xyran,LINESTYLE=2,THICK=2
    ;;  Plot y = 1 line
    OPLOT,[1d0,1d0],xyran,LINESTYLE=2,THICK=2
    ;;  Plot x = 1 line
    OPLOT,xyran,[1d0,1d0],LINESTYLE=2,THICK=2
    ;;-------------------------------------
    ;;  Overplot contours
    ;;-------------------------------------
    density_contour_plot,xdata,ydata,XMIN=xyran[0],XMAX=xyran[1],NX=nxsm[0],  $
                                     YMIN=xyran[0],YMAX=xyran[1],NY=nxsm[0],  $
                                     /OVERPLOT,LIMITS=con_lim,                $
                                     X_LOG=pstr.XLOG,Y_LOG=pstr.YLOG,/SMCONT, $
                                     CPATH_OUT=cpath_out_2,HIST2D_OUT=hist2d_out

;;  Now we can plot without re-calling density_contour_plot.pro
cpath_out      = cpath_out_2
nconts         = N_ELEMENTS(cpath_out.INFO)    ;;  # of contours
xy_cpaths      = REFORM(cpath_out.XY)          ;;  [2,N]-Element array

;;  Define the largest contour
inds_0         = [LINDGEN(cpath_out.INFO[0].N),0L]
i0_0           = cpath_out.INFO[0].OFFSET[0]
clev0          = REFORM(xy_cpaths[*,inds_0 + i0_0[0]])

;;  Define only finite points
test           = FINITE(xdata) AND FINITE(ydata)
good           = WHERE(test,gd)
gxdat          = xdata[good]
gydat          = ydata[good]
;;  Sort by X
sp             = SORT(gxdat)
gxdat          = gxdat[sp]
gydat          = gydat[sp]
;;----------------------------------------------------------------------------------------
;;  Find points inside/outside of largest contour
;;----------------------------------------------------------------------------------------
WINDOW,2,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Energy Dissipation 2'
vt             = TRANSPOSE(clev0)
px             = gxdat
py             = gydat
test           = poly_winding_number2d(px,py,vt)

goodin         = WHERE(test NE 0,gdin,COMPLEMENT=badin,NCOMPLEMENT=bdin)
PRINT,';;',gdin,bdin
;;      634054      306680

;;  Plot results
symb           = 8
thck           = 2.0
;;  Defined user symbol for outputing locations of data on contour
xxo            = FINDGEN(17)*(!PI*2./16.)
USERSYM,0.15*COS(xxo),0.15*SIN(xxo),/FILL

WSET,2
WSHOW,2
  ;;  Initialize plot
  PLOT,px,py,_EXTRA=pstr
    ;;  Plot data points inside lowest contour
    IF (gdin GT 0) THEN OPLOT,px[goodin],py[goodin],PSYM=symb[0],COLOR=100
    ;;  Plot data points outside lowest contour
    IF (bdin GT 0) THEN OPLOT,px[badin],py[badin],PSYM=symb[0],COLOR=200
    ;;  Plot y = x line
    OPLOT,xyran,xyran,LINESTYLE=2,THICK=2
    ;;  Plot y = 1 line
    OPLOT,[1d0,1d0],xyran,LINESTYLE=2,THICK=2
    ;;  Plot x = 1 line
    OPLOT,xyran,[1d0,1d0],LINESTYLE=2,THICK=2
    ;;-------------------------------------
    ;;  Overplot contours
    ;;-------------------------------------
    FOR j=0L, nconts - 1L DO BEGIN $
      inds_j = [LINDGEN(cpath_out.INFO[j].N),0L]  & $
      i0_j   = cpath_out.INFO[j].OFFSET[0]        & $
      PLOTS,xy_cpaths[*, (inds_j + i0_j[0]) ],/DATA,COLOR=ccols[j],THICK=thck

;;-------------------------------------
;;  Save Plot
;;-------------------------------------
n_sum          = 5L
nsum_str       = STRTRIM(STRING(n_sum[0],FORMAT='(I3.3)'),2L)
symb           = 3
fname          = 'dE_vs_Jo_contours_inside-outside-color-coded_NSUM-'+nsum_str[0]
;;  NSUM keyword screws up location of points
;;    -->  Try just taking every N_SUM point in array?
gran           = [0L,gdin[0]]
ng             = gdin[0]/n_sum[0]
gfac           = (gran[1] - gran[0])/(ng[0] - 1L)
gind           = LINDGEN(ng[0])*gfac[0] + gran[0]
bran           = [0L,bdin[0]]
nb             = bdin[0]/n_sum[0]
bfac           = (bran[1] - bran[0])/(nb[0] - 1L)
bind           = LINDGEN(nb[0])*bfac[0] + bran[0]
popen,fname[0],/LAND
  ;;  Initialize plot
  PLOT,px,py,_EXTRA=pstr
    ;;  Plot data points inside lowest contour
    IF (gdin GT 0) THEN OPLOT,px[goodin[gind]],py[goodin[gind]],PSYM=symb[0],COLOR=100
    ;;  Plot data points outside lowest contour
    IF (bdin GT 0) THEN OPLOT,px[badin[bind]],py[badin[bind]],PSYM=symb[0],COLOR=200
    ;;  Plot y = x line
    OPLOT,xyran,xyran,LINESTYLE=2,THICK=2
    ;;  Plot y = 1 line
    OPLOT,[1d0,1d0],xyran,LINESTYLE=2,THICK=2
    ;;  Plot x = 1 line
    OPLOT,xyran,[1d0,1d0],LINESTYLE=2,THICK=2
    ;;-------------------------------------
    ;;  Overplot contours
    ;;-------------------------------------
    FOR j=0L, nconts - 1L DO BEGIN $
      inds_j = [LINDGEN(cpath_out.INFO[j].N),0L]  & $
      i0_j   = cpath_out.INFO[j].OFFSET[0]        & $
      PLOTS,xy_cpaths[*, (inds_j + i0_j[0]) ],/DATA,COLOR=ccols[j],THICK=thck
pclose

fname          = 'dE_vs_Jo_contours_black-dots_NSUM-'+nsum_str[0]
popen,fname[0],/LAND
  ;;  Initialize plot
  PLOT,px,py,_EXTRA=pstr
    ;;  Plot data points inside lowest contour
    IF (gdin GT 0) THEN OPLOT,px[goodin[gind]],py[goodin[gind]],PSYM=symb[0]
    ;;  Plot data points outside lowest contour
    IF (bdin GT 0) THEN OPLOT,px[badin[bind]],py[badin[bind]],PSYM=symb[0]
    ;;  Plot y = x line
    OPLOT,xyran,xyran,LINESTYLE=2,THICK=2
    ;;  Plot y = 1 line
    OPLOT,[1d0,1d0],xyran,LINESTYLE=2,THICK=2
    ;;  Plot x = 1 line
    OPLOT,xyran,[1d0,1d0],LINESTYLE=2,THICK=2
    ;;-------------------------------------
    ;;  Overplot contours
    ;;-------------------------------------
    FOR j=0L, nconts - 1L DO BEGIN $
      inds_j = [LINDGEN(cpath_out.INFO[j].N),0L]  & $
      i0_j   = cpath_out.INFO[j].OFFSET[0]        & $
      PLOTS,xy_cpaths[*, (inds_j + i0_j[0]) ],/DATA,COLOR=ccols[j],THICK=thck
pclose





























