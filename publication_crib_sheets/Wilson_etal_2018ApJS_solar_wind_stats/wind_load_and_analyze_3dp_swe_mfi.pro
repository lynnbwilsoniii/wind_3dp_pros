;;  wind_load_and_analyze_3dp_swe_mfi.pro

;;----------------------------------------------------------------------------------------
;;  Load batch file
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_batch.pro
;;----------------------------------------------------------------------------------------
;;  Print one-variable stats
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/print_wind_3dp_swe_onevar_stats_batch.pro

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
;;  Setup Plot Stuff
symb           = 3
n_sum          = 1L      ;;  Reduce resolution of data to avoid overflow
nsum_str       = num2int_str(n_sum[0],NUM_CHAR=3L,/ZERO_PAD)
nlev           = 5L      ;;  Default Levels:  20%, 35%, 50%, 65%, 80%
ccols          = LINDGEN(nlev)*(250L - 30L)/(nlev - 1L) + 30L
con_lim        = {NLEVELS:nlev,C_COLORS:ccols}
;;  Define plot position
plotposi       = [0.1,0.1,0.9,0.9]
syms           = 2.0
thck           = 2.0
lsty           = 2
nxsm           = 30L
;;  Compile routines
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgerrormsg.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgreverseindices.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgsetunion.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgsetdifference.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/Coyote_Lib/cgsetintersection.pro

.compile isleft2d.pro
.compile poly_winding_number2d.pro
.compile density_contour_plot_wrapper.pro
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot 2D scatter with contours
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  (Tperp/Tpara)_p vs. beta_p_par
;;----------------------------------------------------------------------------------------
spec_sub       = 'p'
xran           = [1d-3,1d2]
yran           = [1d-1,1d1]
;;  Determine XY-tick marks
good_tx        = WHERE(xytv GE xran[0] AND xytv LE xran[1],gdtx)
xytv_0         = xytv[good_tx]
xytn_0         = xytn[good_tx]
xyts_0         = gdtx[0] - 1L
good_ty        = WHERE(xytv GE yran[0] AND xytv LE yran[1],gdty)
yytv_0         = xytv[good_ty]
yytn_0         = xytn[good_ty]
yyts_0         = gdty[0] - 1L
;;************************************************************
;;  (Tperp/Tpara)_p vs. beta_p_par [Only good SWE, ALL Conditions]
;;************************************************************
ydat           = gstr_Tp_all.Y[*,1]/gstr_Tp_all.Y[*,2]
xdat           = beta_ppar_gsp
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE, ALL Conditions]'
x_t_prefx      = 'beta_'+spec_sub[0]+'_par'
y_t_prefx      = '(Tperp/Tpara)_'+spec_sub[0]
file_pref      = 'Wind_Tanis-'+spec_sub[0]+'_vs_beta_'+spec_sub[0]+'_par_SWE_ALL_ALL'
;;************************************************************
;;  (Tperp/Tpara)_p vs. beta_p_par [Only good SWE and 3DP, ALL Conditions]
;;************************************************************
ydat           = f_Tp_swe_3dp.Y[*,1]/f_Tp_swe_3dp.Y[*,2]
xdat           = beta_ppar_s3n
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, ALL Conditions]'
x_t_prefx      = 'beta_'+spec_sub[0]+'_par'
y_t_prefx      = '(Tperp/Tpara)_'+spec_sub[0]
file_pref      = 'Wind_Tanis-'+spec_sub[0]+'_vs_beta_'+spec_sub[0]+'_par_SWE_3DP_ALL'

;;************************************************************
;;  (Tperp/Tpara)_p vs. beta_p_par [Only good SWE and 3DP, No Shocks]
;;************************************************************
ydat           = sh_Tp_swe_3dp.Y[*,1]/sh_Tp_swe_3dp.Y[*,2]
xdat           = beta_ppar_s3s
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, No IP Shocks]'
x_t_prefx      = 'beta_'+spec_sub[0]+'_par'
y_t_prefx      = '(Tperp/Tpara)_'+spec_sub[0]
file_pref      = 'Wind_Tanis-'+spec_sub[0]+'_vs_beta_'+spec_sub[0]+'_par_SWE_3DP_No_Shocks'

;;************************************************************
;;  (Tperp/Tpara)_p vs. beta_p_par [Only good SWE and 3DP, Inside  MOs]
;;************************************************************
ydat           = in_Tp_swe_3dp.Y[*,1]/in_Tp_swe_3dp.Y[*,2]
xdat           = beta_ppar_s3io
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, Inside  MOs]'
x_t_prefx      = 'beta_'+spec_sub[0]+'_par'
y_t_prefx      = '(Tperp/Tpara)_'+spec_sub[0]
file_pref      = 'Wind_Tanis-'+spec_sub[0]+'_vs_beta_'+spec_sub[0]+'_par_SWE_3DP_Inside__MOs'

;;************************************************************
;;  (Tperp/Tpara)_p vs. beta_p_par [Only good SWE and 3DP, Outside MOs]
;;************************************************************
ydat           = ot_Tp_swe_3dp.Y[*,1]/ot_Tp_swe_3dp.Y[*,2]
xdat           = beta_ppar_s3oo
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, Outside MOs]'
x_t_prefx      = 'beta_'+spec_sub[0]+'_par'
y_t_prefx      = '(Tperp/Tpara)_'+spec_sub[0]
file_pref      = 'Wind_Tanis-'+spec_sub[0]+'_vs_beta_'+spec_sub[0]+'_par_SWE_3DP_Outside_MOs'

;;----------------------------------------------------------------------------------------
;;  (Tperp/Tpara)_a vs. beta_a_par
;;----------------------------------------------------------------------------------------
spec_sub       = 'a'
xran           = [1d-3,1d2]
yran           = [1d-1,1d1]
;;  Determine XY-tick marks
good_tx        = WHERE(xytv GE xran[0] AND xytv LE xran[1],gdtx)
xytv_0         = xytv[good_tx]
xytn_0         = xytn[good_tx]
xyts_0         = gdtx[0] - 1L
good_ty        = WHERE(xytv GE yran[0] AND xytv LE yran[1],gdty)
yytv_0         = xytv[good_ty]
yytn_0         = xytn[good_ty]
yyts_0         = gdty[0] - 1L
;;************************************************************
;;  (Tperp/Tpara)_a vs. beta_a_par [Only good SWE, ALL Conditions]
;;************************************************************
ydat           = gstr_Ta_all.Y[*,1]/gstr_Ta_all.Y[*,2]
xdat           = beta_apar_gsp
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE, ALL Conditions]'
x_t_prefx      = 'beta_'+spec_sub[0]+'_par'
y_t_prefx      = '(Tperp/Tpara)_'+spec_sub[0]
file_pref      = 'Wind_Tanis-'+spec_sub[0]+'_vs_beta_'+spec_sub[0]+'_par_SWE_ALL_ALL'
;;************************************************************
;;  (Tperp/Tpara)_a vs. beta_a_par [Only good SWE and 3DP, ALL Conditions]
;;************************************************************
ydat           = f_Ta_swe_3dp.Y[*,1]/f_Ta_swe_3dp.Y[*,2]
xdat           = beta_apar_s3n
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, ALL Conditions]'
x_t_prefx      = 'beta_'+spec_sub[0]+'_par'
y_t_prefx      = '(Tperp/Tpara)_'+spec_sub[0]
file_pref      = 'Wind_Tanis-'+spec_sub[0]+'_vs_beta_'+spec_sub[0]+'_par_SWE_3DP_ALL'

;;************************************************************
;;  (Tperp/Tpara)_a vs. beta_a_par [Only good SWE and 3DP, No Shocks]
;;************************************************************
ydat           = sh_Ta_swe_3dp.Y[*,1]/sh_Ta_swe_3dp.Y[*,2]
xdat           = beta_apar_s3s
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, No IP Shocks]'
x_t_prefx      = 'beta_'+spec_sub[0]+'_par'
y_t_prefx      = '(Tperp/Tpara)_'+spec_sub[0]
file_pref      = 'Wind_Tanis-'+spec_sub[0]+'_vs_beta_'+spec_sub[0]+'_par_SWE_3DP_No_Shocks'

;;************************************************************
;;  (Tperp/Tpara)_a vs. beta_a_par [Only good SWE and 3DP, Inside  MOs]
;;************************************************************
ydat           = in_Ta_swe_3dp.Y[*,1]/in_Ta_swe_3dp.Y[*,2]
xdat           = beta_apar_s3io
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, Inside  MOs]'
x_t_prefx      = 'beta_'+spec_sub[0]+'_par'
y_t_prefx      = '(Tperp/Tpara)_'+spec_sub[0]
file_pref      = 'Wind_Tanis-'+spec_sub[0]+'_vs_beta_'+spec_sub[0]+'_par_SWE_3DP_Inside__MOs'

;;************************************************************
;;  (Tperp/Tpara)_a vs. beta_a_par [Only good SWE and 3DP, Outside MOs]
;;************************************************************
ydat           = ot_Ta_swe_3dp.Y[*,1]/ot_Ta_swe_3dp.Y[*,2]
xdat           = beta_apar_s3oo
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, Outside MOs]'
x_t_prefx      = 'beta_'+spec_sub[0]+'_par'
y_t_prefx      = '(Tperp/Tpara)_'+spec_sub[0]
file_pref      = 'Wind_Tanis-'+spec_sub[0]+'_vs_beta_'+spec_sub[0]+'_par_SWE_3DP_Outside_MOs'

;;----------------------------------------------------------------------------------------
;;  (Tperp/Tpara)_e vs. beta_e_par
;;----------------------------------------------------------------------------------------
;;  Get Te_j [eV]
get_data,t_3dp_tpns[1],DATA=temp_Teb,DLIMIT=dlim_Teb,LIMIT=lim_Teb
spec_sub       = 'e'
xran           = [1d-3,1d2]
yran           = [1d-1,1d1]
;;  Determine XY-tick marks
good_tx        = WHERE(xytv GE xran[0] AND xytv LE xran[1],gdtx)
xytv_0         = xytv[good_tx]
xytn_0         = xytn[good_tx]
xyts_0         = gdtx[0] - 1L
good_ty        = WHERE(xytv GE yran[0] AND xytv LE yran[1],gdty)
yytv_0         = xytv[good_ty]
yytn_0         = xytn[good_ty]
yyts_0         = gdty[0] - 1L
;;************************************************************
;;  Calculate (Tperp/Tpara)_e [Only good 3DP, ALL Conditions]
;;************************************************************
good           = good_3dp
ydat           = temp_Teb.Y[good,1]/temp_Teb.Y[good,0]
xdat           = beta_epar_all[good]
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good 3DP, ALL Conditions]'
x_t_prefx      = 'beta_'+spec_sub[0]+'_par'
y_t_prefx      = '(Tperp/Tpara)_'+spec_sub[0]
file_pref      = 'Wind_Tanis-'+spec_sub[0]+'_vs_beta_'+spec_sub[0]+'_par_ALL_3DP_ALL'

;;************************************************************
;;  Calculate (Tperp/Tpara)_e [Only good 3DP, No Shocks]
;;************************************************************
good           = good_new_3dp
ydat           = temp_Teb.Y[good,1]/temp_Teb.Y[good,0]
xdat           = beta_epar_all[good]
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good 3DP, No IP Shocks]'
x_t_prefx      = 'beta_'+spec_sub[0]+'_par'
y_t_prefx      = '(Tperp/Tpara)_'+spec_sub[0]
file_pref      = 'Wind_Tanis-'+spec_sub[0]+'_vs_beta_'+spec_sub[0]+'_par_ALL_3DP_No_Shocks'

;;************************************************************
;;  Calculate (Tperp/Tpara)_e [Only good 3DP, Inside  MOs]
;;************************************************************
good           = in__mo_3dp
ydat           = temp_Teb.Y[good,1]/temp_Teb.Y[good,0]
xdat           = beta_epar_all[good]
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good 3DP, Inside  MOs]'
x_t_prefx      = 'beta_'+spec_sub[0]+'_par'
y_t_prefx      = '(Tperp/Tpara)_'+spec_sub[0]
file_pref      = 'Wind_Tanis-'+spec_sub[0]+'_vs_beta_'+spec_sub[0]+'_par_ALL_3DP_Inside__MOs'

;;************************************************************
;;  Calculate (Tperp/Tpara)_e [Only good 3DP, Outside MOs]
;;************************************************************
good           = out_mo_3dp
ydat           = temp_Teb.Y[good,1]/temp_Teb.Y[good,0]
xdat           = beta_epar_all[good]
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good 3DP, Outside MOs]'
x_t_prefx      = 'beta_'+spec_sub[0]+'_par'
y_t_prefx      = '(Tperp/Tpara)_'+spec_sub[0]
file_pref      = 'Wind_Tanis-'+spec_sub[0]+'_vs_beta_'+spec_sub[0]+'_par_ALL_3DP_Outside_MOs'

;;----------------------------------------------------------------------------------------
;;  (Tperp/Tpara)_p vs. (Tperp/Tpara)_e
;;----------------------------------------------------------------------------------------
spec_subx      = 'e'
spec_suby      = 'p'
xran           = [1d-1,1d1]
yran           = [1d-1,1d1]
;;  Determine XY-tick marks
good_tx        = WHERE(xytv GE xran[0] AND xytv LE xran[1],gdtx)
xytv_0         = xytv[good_tx]
xytn_0         = xytn[good_tx]
xyts_0         = gdtx[0] - 1L
good_ty        = WHERE(xytv GE yran[0] AND xytv LE yran[1],gdty)
yytv_0         = xytv[good_ty]
yytn_0         = xytn[good_ty]
yyts_0         = gdty[0] - 1L
;;************************************************************
;;  (Tperp/Tpara)_p vs. (Tperp/Tpara)_e [Only good SWE and 3DP, ALL Conditions]
;;************************************************************
good           = good_3dp
xdat           = temp_Teb.Y[good,1]/temp_Teb.Y[good,0]
ydat           = f_Tp_swe_3dp.Y[*,1]/f_Tp_swe_3dp.Y[*,2]
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, ALL Conditions]'
x_t_prefx      = '(Tperp/Tpara)_'+spec_subx[0]
y_t_prefx      = '(Tperp/Tpara)_'+spec_suby[0]
file_pref      = 'Wind_Tanis-'+spec_suby[0]+'_vs_Tanis-'+spec_subx[0]+'_SWE_3DP_ALL'
;;************************************************************
;;  (Tperp/Tpara)_p vs. (Tperp/Tpara)_e [Only good SWE and 3DP, No Shocks]
;;************************************************************
good           = good_new_3dp
xdat           = temp_Teb.Y[good,1]/temp_Teb.Y[good,0]
ydat           = sh_Tp_swe_3dp.Y[*,1]/sh_Tp_swe_3dp.Y[*,2]
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, No IP Shocks]'
x_t_prefx      = '(Tperp/Tpara)_'+spec_subx[0]
y_t_prefx      = '(Tperp/Tpara)_'+spec_suby[0]
file_pref      = 'Wind_Tanis-'+spec_suby[0]+'_vs_Tanis-'+spec_subx[0]+'_SWE_3DP_No_Shocks'
;;************************************************************
;;  (Tperp/Tpara)_p vs. (Tperp/Tpara)_e [Only good SWE and 3DP, Inside  MOs]
;;************************************************************
good           = in__mo_3dp
xdat           = temp_Teb.Y[good,1]/temp_Teb.Y[good,0]
ydat           = in_Tp_swe_3dp.Y[*,1]/in_Tp_swe_3dp.Y[*,2]
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, Inside  MOs]'
x_t_prefx      = '(Tperp/Tpara)_'+spec_subx[0]
y_t_prefx      = '(Tperp/Tpara)_'+spec_suby[0]
file_pref      = 'Wind_Tanis-'+spec_suby[0]+'_vs_Tanis-'+spec_subx[0]+'_SWE_3DP_Inside__MOs'
;;************************************************************
;;  (Tperp/Tpara)_p vs. (Tperp/Tpara)_e [Only good SWE and 3DP, Outside MOs]
;;************************************************************
good           = out_mo_3dp
xdat           = temp_Teb.Y[good,1]/temp_Teb.Y[good,0]
ydat           = ot_Tp_swe_3dp.Y[*,1]/ot_Tp_swe_3dp.Y[*,2]
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, Outside MOs]'
x_t_prefx      = '(Tperp/Tpara)_'+spec_subx[0]
y_t_prefx      = '(Tperp/Tpara)_'+spec_suby[0]
file_pref      = 'Wind_Tanis-'+spec_suby[0]+'_vs_Tanis-'+spec_subx[0]+'_SWE_3DP_Outside_MOs'

;;----------------------------------------------------------------------------------------
;;  (Tperp/Tpara)_a vs. (Tperp/Tpara)_p
;;----------------------------------------------------------------------------------------
spec_subx      = 'p'
spec_suby      = 'a'
xran           = [1d-1,1d1]
yran           = [1d-1,1d1]
;;  Determine XY-tick marks
good_tx        = WHERE(xytv GE xran[0] AND xytv LE xran[1],gdtx)
xytv_0         = xytv[good_tx]
xytn_0         = xytn[good_tx]
xyts_0         = gdtx[0] - 1L
good_ty        = WHERE(xytv GE yran[0] AND xytv LE yran[1],gdty)
yytv_0         = xytv[good_ty]
yytn_0         = xytn[good_ty]
yyts_0         = gdty[0] - 1L
;;************************************************************
;;  (Tperp/Tpara)_a vs. (Tperp/Tpara)_p [Only good SWE and 3DP, ALL Conditions]
;;************************************************************
xdat           = f_Tp_swe_3dp.Y[*,1]/f_Tp_swe_3dp.Y[*,2]
ydat           = f_Ta_swe_3dp.Y[*,1]/f_Ta_swe_3dp.Y[*,2]
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, ALL Conditions]'
x_t_prefx      = '(Tperp/Tpara)_'+spec_subx[0]
y_t_prefx      = '(Tperp/Tpara)_'+spec_suby[0]
file_pref      = 'Wind_Tanis-'+spec_suby[0]+'_vs_Tanis-'+spec_subx[0]+'_SWE_3DP_ALL'
;;************************************************************
;;  (Tperp/Tpara)_a vs. (Tperp/Tpara)_p [Only good SWE and 3DP, No Shocks]
;;************************************************************
xdat           = sh_Tp_swe_3dp.Y[*,1]/sh_Tp_swe_3dp.Y[*,2]
ydat           = sh_Ta_swe_3dp.Y[*,1]/sh_Ta_swe_3dp.Y[*,2]
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, No IP Shocks]'
x_t_prefx      = '(Tperp/Tpara)_'+spec_subx[0]
y_t_prefx      = '(Tperp/Tpara)_'+spec_suby[0]
file_pref      = 'Wind_Tanis-'+spec_suby[0]+'_vs_Tanis-'+spec_subx[0]+'_SWE_3DP_No_Shocks'
;;************************************************************
;;  (Tperp/Tpara)_a vs. (Tperp/Tpara)_p [Only good SWE and 3DP, Inside  MOs]
;;************************************************************
xdat           = in_Tp_swe_3dp.Y[*,1]/in_Tp_swe_3dp.Y[*,2]
ydat           = in_Ta_swe_3dp.Y[*,1]/in_Ta_swe_3dp.Y[*,2]
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, Inside  MOs]'
x_t_prefx      = '(Tperp/Tpara)_'+spec_subx[0]
y_t_prefx      = '(Tperp/Tpara)_'+spec_suby[0]
file_pref      = 'Wind_Tanis-'+spec_suby[0]+'_vs_Tanis-'+spec_subx[0]+'_SWE_3DP_Inside__MOs'
;;************************************************************
;;  (Tperp/Tpara)_a vs. (Tperp/Tpara)_p [Only good SWE and 3DP, Outside MOs]
;;************************************************************
xdat           = ot_Tp_swe_3dp.Y[*,1]/ot_Tp_swe_3dp.Y[*,2]
ydat           = ot_Ta_swe_3dp.Y[*,1]/ot_Ta_swe_3dp.Y[*,2]
;;  Define plot titles and file name prefixes/suffixes
xyt_suffx      = ' [Only good SWE and 3DP, Outside MOs]'
x_t_prefx      = '(Tperp/Tpara)_'+spec_subx[0]
y_t_prefx      = '(Tperp/Tpara)_'+spec_suby[0]
file_pref      = 'Wind_Tanis-'+spec_suby[0]+'_vs_Tanis-'+spec_subx[0]+'_SWE_3DP_Outside_MOs'


;;--------------------------------------------------
;;  Plot 2D histograms
;;--------------------------------------------------
;;  Sort by x
sp             = SORT(xdat)
ydat           = TEMPORARY(ydat[sp])
xdat           = TEMPORARY(xdat[sp])
;;  Define plot titles
pttle          = y_t_prefx[0]+' vs. '+x_t_prefx[0]
xttle          = x_t_prefx[0]+xyt_suffx[0]
yttle          = y_t_prefx[0]+xyt_suffx[0]
;;  Define plot structure
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,    $
                  YMINOR:9L,XMINOR:9L,XRANGE:xran,YRANGE:yran,YSTYLE:1,XSTYLE:1,   $
                  XTICKNAME:xytn_0,XTICKV:xytv_0,XTICKS:xyts_0,                    $
                  YTICKNAME:yytn_0,YTICKV:yytv_0,YTICKS:yyts_0,                    $
                  POSITION:plotposi}
;;  Define file name and Plot [N_SUM = 1]
n_sum          = 1L      ;;  Reduce resolution of data to avoid overflow
nsum_str       = num2int_str(n_sum[0],NUM_CHAR=3L,/ZERO_PAD)
file_name      = file_pref[0]+'_NSUM-'+nsum_str[0]
density_contour_plot_wrapper,xdat,ydat,                                          $
                             PLIMITS=pstr,WIND_N=1,FILE_NAME=file_name,          $
                             XTITLE=xttle,YTITLE=yttle,/YLOG,/XLOG,              $
                             XMIN=xran[0],XMAX=xran[1],NX=nxsm[0],               $
                             YMIN=yran[0],YMAX=yran[1],NY=nxsm[0],               $
                             CLIMITS=con_lim,/SMCONT,N_SUM=n_sum[0],             $
                             CPATH_OUT=cpath_out,HIST2D_OUT=hist2d_out,          $  ;; outputs
                             _EXTRA=ex_str

;;  Define file name and Plot [N_SUM = 5]
n_sum          = 5L      ;;  Reduce resolution of data to avoid overflow
nsum_str       = num2int_str(n_sum[0],NUM_CHAR=3L,/ZERO_PAD)
file_name      = file_pref[0]+'_NSUM-'+nsum_str[0]
density_contour_plot_wrapper,xdat,ydat,                                          $
                             PLIMITS=pstr,WIND_N=1,FILE_NAME=file_name,          $
                             XTITLE=xttle,YTITLE=yttle,/YLOG,/XLOG,              $
                             XMIN=xran[0],XMAX=xran[1],NX=nxsm[0],               $
                             YMIN=yran[0],YMAX=yran[1],NY=nxsm[0],               $
                             CLIMITS=con_lim,/SMCONT,N_SUM=n_sum[0],             $
                             CPATH_OUT=cpath_out,HIST2D_OUT=hist2d_out,          $  ;; outputs
                             _EXTRA=ex_str

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot histograms
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Plot beta_s_avg ratios
;;----------------------------------------------------------------------------------------
xran           = [1d-3,1d2]
yran           = [1d0,1d6]
deltax         = 2d0
yttl0          = 'Number of Events'
ttle0          = 'beta_s_avg Ratios'

xttls          = ['beta_e_avg [ALL, ALL, ALL]','beta_p_avg [ALL, ALL, ALL]','beta_a_avg [ALL, ALL, ALL]','beta_e_avg [ALL, ALL, No Shocks]','beta_p_avg [ALL, ALL, No Shocks]','beta_a_avg [ALL, ALL, No Shocks]','beta_e_avg [ALL, ALL, Inside  MOs]','beta_p_avg [ALL, ALL, Inside  MOs]','beta_a_avg [ALL, ALL, Inside  MOs]','beta_e_avg [ALL, ALL, Outside MOs]','beta_p_avg [ALL, ALL, Outside MOs]','beta_a_avg [ALL, ALL, Outside MOs]']
fnames         = ['beta_e_avg_ALL_ALL_ALL','beta_p_avg_ALL_ALL_ALL','beta_a_avg_ALL_ALL_ALL','beta_e_avg_ALL_ALL_No_Shocks','beta_p_avg_ALL_ALL_No_Shocks','beta_a_avg_ALL_ALL_No_Shocks','beta_e_avg_ALL_ALL_Inside__MOs','beta_p_avg_ALL_ALL_Inside__MOs','beta_a_avg_ALL_ALL_Inside__MOs','beta_e_avg_ALL_ALL_Outside_MOs','beta_p_avg_ALL_ALL_Outside_MOs','beta_a_avg_ALL_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_eavg_all,beta_pavg_all,beta_aavg_all,beta_eavg_aas,beta_pavg_aas,beta_aavg_aas,beta_eavg_aaio,beta_pavg_aaio,beta_aavg_aaio,beta_eavg_aaoo,beta_pavg_aaoo,beta_aavg_aaoo)

xttls          = ['beta_e_avg [ALL, 3DP, ALL]','beta_p_avg [ALL, 3DP, ALL]','beta_a_avg [ALL, 3DP, ALL]','beta_e_avg [ALL, 3DP, No Shocks]','beta_p_avg [ALL, 3DP, No Shocks]','beta_a_avg [ALL, 3DP, No Shocks]','beta_e_avg [ALL, 3DP, Inside  MOs]','beta_p_avg [ALL, 3DP, Inside  MOs]','beta_a_avg [ALL, 3DP, Inside  MOs]','beta_e_avg [ALL, 3DP, Outside MOs]','beta_p_avg [ALL, 3DP, Outside MOs]','beta_a_avg [ALL, 3DP, Outside MOs]']
fnames         = ['beta_e_avg_ALL_3DP_ALL','beta_p_avg_ALL_3DP_ALL','beta_a_avg_ALL_3DP_ALL','beta_e_avg_ALL_3DP_No_Shocks','beta_p_avg_ALL_3DP_No_Shocks','beta_a_avg_ALL_3DP_No_Shocks','beta_e_avg_ALL_3DP_Inside__MOs','beta_p_avg_ALL_3DP_Inside__MOs','beta_a_avg_ALL_3DP_Inside__MOs','beta_e_avg_ALL_3DP_Outside_MOs','beta_p_avg_ALL_3DP_Outside_MOs','beta_a_avg_ALL_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_eavg_3dp,beta_pavg_a3n,beta_aavg_a3n,beta_eavg_a3s,beta_pavg_a3s,beta_aavg_a3s,beta_eavg_a3io,beta_pavg_a3io,beta_aavg_a3io,beta_eavg_a3oo,beta_pavg_a3oo,beta_aavg_a3oo)

xttls          = ['beta_p_avg [SWE, ALL, ALL]','beta_a_avg [SWE, ALL, ALL]','beta_p_avg [SWE, ALL, No Shocks]','beta_a_avg [SWE, ALL, No Shocks]','beta_p_avg [SWE, ALL, Inside  MOs]','beta_a_avg [SWE, ALL, Inside  MOs]','beta_p_avg [SWE, ALL, Outside MOs]','beta_a_avg [SWE, ALL, Outside MOs]']
fnames         = ['beta_p_avg_SWE_ALL_ALL','beta_a_avg_SWE_ALL_ALL','beta_p_avg_SWE_ALL_No_Shocks','beta_a_avg_SWE_ALL_No_Shocks','beta_p_avg_SWE_ALL_Inside__MOs','beta_a_avg_SWE_ALL_Inside__MOs','beta_p_avg_SWE_ALL_Outside_MOs','beta_a_avg_SWE_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_pavg_gsp,beta_aavg_gsp,beta_pavg_sas,beta_aavg_sas,beta_pavg_saio,beta_aavg_saio,beta_pavg_saoo,beta_aavg_saoo)

xttls          = ['beta_p_avg [SWE, 3DP, ALL]','beta_a_avg [SWE, 3DP, ALL]','beta_p_avg [SWE, 3DP, No Shocks]','beta_a_avg [SWE, 3DP, No Shocks]','beta_p_avg [SWE, 3DP, Inside  MOs]','beta_a_avg [SWE, 3DP, Inside  MOs]','beta_p_avg [SWE, 3DP, Outside MOs]','beta_a_avg [SWE, 3DP, Outside MOs]']
fnames         = ['beta_p_avg_SWE_3DP_ALL','beta_a_avg_SWE_3DP_ALL','beta_p_avg_SWE_3DP_No_Shocks','beta_a_avg_SWE_3DP_No_Shocks','beta_p_avg_SWE_3DP_Inside__MOs','beta_a_avg_SWE_3DP_Inside__MOs','beta_p_avg_SWE_3DP_Outside_MOs','beta_a_avg_SWE_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_pavg_s3n,beta_aavg_s3n,beta_pavg_s3s,beta_aavg_s3s,beta_pavg_s3io,beta_aavg_s3io,beta_pavg_s3oo,beta_aavg_s3oo)

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]                                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1

;;----------------------------------------------------------------------------------------
;;  Plot beta_s_per ratios
;;----------------------------------------------------------------------------------------
xran           = [1d-3,1d2]
yran           = [1d0,1d6]
deltax         = 2d0
yttl0          = 'Number of Events'
ttle0          = 'beta_s_per Ratios'

xttls          = ['beta_e_per [ALL, ALL, ALL]','beta_p_per [ALL, ALL, ALL]','beta_a_per [ALL, ALL, ALL]','beta_e_per [ALL, ALL, No Shocks]','beta_p_per [ALL, ALL, No Shocks]','beta_a_per [ALL, ALL, No Shocks]','beta_e_per [ALL, ALL, Inside  MOs]','beta_p_per [ALL, ALL, Inside  MOs]','beta_a_per [ALL, ALL, Inside  MOs]','beta_e_per [ALL, ALL, Outside MOs]','beta_p_per [ALL, ALL, Outside MOs]','beta_a_per [ALL, ALL, Outside MOs]']
fnames         = ['beta_e_per_ALL_ALL_ALL','beta_p_per_ALL_ALL_ALL','beta_a_per_ALL_ALL_ALL','beta_e_per_ALL_ALL_No_Shocks','beta_p_per_ALL_ALL_No_Shocks','beta_a_per_ALL_ALL_No_Shocks','beta_e_per_ALL_ALL_Inside__MOs','beta_p_per_ALL_ALL_Inside__MOs','beta_a_per_ALL_ALL_Inside__MOs','beta_e_per_ALL_ALL_Outside_MOs','beta_p_per_ALL_ALL_Outside_MOs','beta_a_per_ALL_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_eper_all,beta_pper_all,beta_aper_all,beta_eper_aas,beta_pper_aas,beta_aper_aas,beta_eper_aaio,beta_pper_aaio,beta_aper_aaio,beta_eper_aaoo,beta_pper_aaoo,beta_aper_aaoo)

xttls          = ['beta_e_per [ALL, 3DP, ALL]','beta_p_per [ALL, 3DP, ALL]','beta_a_per [ALL, 3DP, ALL]','beta_e_per [ALL, 3DP, No Shocks]','beta_p_per [ALL, 3DP, No Shocks]','beta_a_per [ALL, 3DP, No Shocks]','beta_e_per [ALL, 3DP, Inside  MOs]','beta_p_per [ALL, 3DP, Inside  MOs]','beta_a_per [ALL, 3DP, Inside  MOs]','beta_e_per [ALL, 3DP, Outside MOs]','beta_p_per [ALL, 3DP, Outside MOs]','beta_a_per [ALL, 3DP, Outside MOs]']
fnames         = ['beta_e_per_ALL_3DP_ALL','beta_p_per_ALL_3DP_ALL','beta_a_per_ALL_3DP_ALL','beta_e_per_ALL_3DP_No_Shocks','beta_p_per_ALL_3DP_No_Shocks','beta_a_per_ALL_3DP_No_Shocks','beta_e_per_ALL_3DP_Inside__MOs','beta_p_per_ALL_3DP_Inside__MOs','beta_a_per_ALL_3DP_Inside__MOs','beta_e_per_ALL_3DP_Outside_MOs','beta_p_per_ALL_3DP_Outside_MOs','beta_a_per_ALL_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_eper_3dp,beta_pper_a3n,beta_aper_a3n,beta_eper_a3s,beta_pper_a3s,beta_aper_a3s,beta_eper_a3io,beta_pper_a3io,beta_aper_a3io,beta_eper_a3oo,beta_pper_a3oo,beta_aper_a3oo)

xttls          = ['beta_p_per [SWE, ALL, ALL]','beta_a_per [SWE, ALL, ALL]','beta_p_per [SWE, ALL, No Shocks]','beta_a_per [SWE, ALL, No Shocks]','beta_p_per [SWE, ALL, Inside  MOs]','beta_a_per [SWE, ALL, Inside  MOs]','beta_p_per [SWE, ALL, Outside MOs]','beta_a_per [SWE, ALL, Outside MOs]']
fnames         = ['beta_p_per_SWE_ALL_ALL','beta_a_per_SWE_ALL_ALL','beta_p_per_SWE_ALL_No_Shocks','beta_a_per_SWE_ALL_No_Shocks','beta_p_per_SWE_ALL_Inside__MOs','beta_a_per_SWE_ALL_Inside__MOs','beta_p_per_SWE_ALL_Outside_MOs','beta_a_per_SWE_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_pper_gsp,beta_aper_gsp,beta_pper_sas,beta_aper_sas,beta_pper_saio,beta_aper_saio,beta_pper_saoo,beta_aper_saoo)

xttls          = ['beta_p_per [SWE, 3DP, ALL]','beta_a_per [SWE, 3DP, ALL]','beta_p_per [SWE, 3DP, No Shocks]','beta_a_per [SWE, 3DP, No Shocks]','beta_p_per [SWE, 3DP, Inside  MOs]','beta_a_per [SWE, 3DP, Inside  MOs]','beta_p_per [SWE, 3DP, Outside MOs]','beta_a_per [SWE, 3DP, Outside MOs]']
fnames         = ['beta_p_per_SWE_3DP_ALL','beta_a_per_SWE_3DP_ALL','beta_p_per_SWE_3DP_No_Shocks','beta_a_per_SWE_3DP_No_Shocks','beta_p_per_SWE_3DP_Inside__MOs','beta_a_per_SWE_3DP_Inside__MOs','beta_p_per_SWE_3DP_Outside_MOs','beta_a_per_SWE_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_pper_s3n,beta_aper_s3n,beta_pper_s3s,beta_aper_s3s,beta_pper_s3io,beta_aper_s3io,beta_pper_s3oo,beta_aper_s3oo)

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]                                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1

;;----------------------------------------------------------------------------------------
;;  Plot beta_s_par ratios
;;----------------------------------------------------------------------------------------
xran           = [1d-3,1d2]
yran           = [1d0,1d6]
deltax         = 2d0
yttl0          = 'Number of Events'
ttle0          = 'beta_s_par Ratios'

xttls          = ['beta_e_par [ALL, ALL, ALL]','beta_p_par [ALL, ALL, ALL]','beta_a_par [ALL, ALL, ALL]','beta_e_par [ALL, ALL, No Shocks]','beta_p_par [ALL, ALL, No Shocks]','beta_a_par [ALL, ALL, No Shocks]','beta_e_par [ALL, ALL, Inside  MOs]','beta_p_par [ALL, ALL, Inside  MOs]','beta_a_par [ALL, ALL, Inside  MOs]','beta_e_par [ALL, ALL, Outside MOs]','beta_p_par [ALL, ALL, Outside MOs]','beta_a_par [ALL, ALL, Outside MOs]']
fnames         = ['beta_e_par_ALL_ALL_ALL','beta_p_par_ALL_ALL_ALL','beta_a_par_ALL_ALL_ALL','beta_e_par_ALL_ALL_No_Shocks','beta_p_par_ALL_ALL_No_Shocks','beta_a_par_ALL_ALL_No_Shocks','beta_e_par_ALL_ALL_Inside__MOs','beta_p_par_ALL_ALL_Inside__MOs','beta_a_par_ALL_ALL_Inside__MOs','beta_e_par_ALL_ALL_Outside_MOs','beta_p_par_ALL_ALL_Outside_MOs','beta_a_par_ALL_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_epar_all,beta_ppar_all,beta_apar_all,beta_epar_aas,beta_ppar_aas,beta_apar_aas,beta_epar_aaio,beta_ppar_aaio,beta_apar_aaio,beta_epar_aaoo,beta_ppar_aaoo,beta_apar_aaoo)

xttls          = ['beta_e_par [ALL, 3DP, ALL]','beta_p_par [ALL, 3DP, ALL]','beta_a_par [ALL, 3DP, ALL]','beta_e_par [ALL, 3DP, No Shocks]','beta_p_par [ALL, 3DP, No Shocks]','beta_a_par [ALL, 3DP, No Shocks]','beta_e_par [ALL, 3DP, Inside  MOs]','beta_p_par [ALL, 3DP, Inside  MOs]','beta_a_par [ALL, 3DP, Inside  MOs]','beta_e_par [ALL, 3DP, Outside MOs]','beta_p_par [ALL, 3DP, Outside MOs]','beta_a_par [ALL, 3DP, Outside MOs]']
fnames         = ['beta_e_par_ALL_3DP_ALL','beta_p_par_ALL_3DP_ALL','beta_a_par_ALL_3DP_ALL','beta_e_par_ALL_3DP_No_Shocks','beta_p_par_ALL_3DP_No_Shocks','beta_a_par_ALL_3DP_No_Shocks','beta_e_par_ALL_3DP_Inside__MOs','beta_p_par_ALL_3DP_Inside__MOs','beta_a_par_ALL_3DP_Inside__MOs','beta_e_par_ALL_3DP_Outside_MOs','beta_p_par_ALL_3DP_Outside_MOs','beta_a_par_ALL_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_epar_3dp,beta_ppar_a3n,beta_apar_a3n,beta_epar_a3s,beta_ppar_a3s,beta_apar_a3s,beta_epar_a3io,beta_ppar_a3io,beta_apar_a3io,beta_epar_a3oo,beta_ppar_a3oo,beta_apar_a3oo)

xttls          = ['beta_p_par [SWE, ALL, ALL]','beta_a_par [SWE, ALL, ALL]','beta_p_par [SWE, ALL, No Shocks]','beta_a_par [SWE, ALL, No Shocks]','beta_p_par [SWE, ALL, Inside  MOs]','beta_a_par [SWE, ALL, Inside  MOs]','beta_p_par [SWE, ALL, Outside MOs]','beta_a_par [SWE, ALL, Outside MOs]']
fnames         = ['beta_p_par_SWE_ALL_ALL','beta_a_par_SWE_ALL_ALL','beta_p_par_SWE_ALL_No_Shocks','beta_a_par_SWE_ALL_No_Shocks','beta_p_par_SWE_ALL_Inside__MOs','beta_a_par_SWE_ALL_Inside__MOs','beta_p_par_SWE_ALL_Outside_MOs','beta_a_par_SWE_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_ppar_gsp,beta_apar_gsp,beta_ppar_sas,beta_apar_sas,beta_ppar_saio,beta_apar_saio,beta_ppar_saoo,beta_apar_saoo)

xttls          = ['beta_p_par [SWE, 3DP, ALL]','beta_a_par [SWE, 3DP, ALL]','beta_p_par [SWE, 3DP, No Shocks]','beta_a_par [SWE, 3DP, No Shocks]','beta_p_par [SWE, 3DP, Inside  MOs]','beta_a_par [SWE, 3DP, Inside  MOs]','beta_p_par [SWE, 3DP, Outside MOs]','beta_a_par [SWE, 3DP, Outside MOs]']
fnames         = ['beta_p_par_SWE_3DP_ALL','beta_a_par_SWE_3DP_ALL','beta_p_par_SWE_3DP_No_Shocks','beta_a_par_SWE_3DP_No_Shocks','beta_p_par_SWE_3DP_Inside__MOs','beta_a_par_SWE_3DP_Inside__MOs','beta_p_par_SWE_3DP_Outside_MOs','beta_a_par_SWE_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,beta_ppar_s3n,beta_apar_s3n,beta_ppar_s3s,beta_apar_s3s,beta_ppar_s3io,beta_apar_s3io,beta_ppar_s3oo,beta_apar_s3oo)

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]                                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1

;;----------------------------------------------------------------------------------------
;;  Plot (Ts/Te)_avg ratios
;;----------------------------------------------------------------------------------------
xran           = [1d-3,5d1]
yran           = [1d0,1d6]
deltax         = 2d0
yttl0          = 'Number of Events'
ttle0          = '(Ts/Te)_avg Ratios'

xttls          = ['(Te/Tp)_avg [ALL, ALL, ALL]','(Te/Ta)_avg [ALL, ALL, ALL]','(Te/Tp)_avg [ALL, ALL, No Shocks]','(Te/Ta)_avg [ALL, ALL, No Shocks]','(Te/Tp)_avg [ALL, ALL, Inside  MOs]','(Te/Ta)_avg [ALL, ALL, Inside  MOs]','(Te/Tp)_avg [ALL, ALL, Outside MOs]','(Te/Ta)_avg [ALL, ALL, Outside MOs]']
fnames         = ['Te_Tp_avg_ALL_ALL_ALL','Te_Ta_avg_ALL_ALL_ALL','Te_Tp_avg_ALL_ALL_No_Shocks','Te_Ta_avg_ALL_ALL_No_Shocks','Te_Tp_avg_ALL_ALL_Inside__MOs','Te_Ta_avg_ALL_ALL_Inside__MOs','Te_Tp_avg_ALL_ALL_Outside_MOs','Te_Ta_avg_ALL_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Te_Tp_avg_aan,Te_Ta_avg_aan,Te_Tp_avg_aas,Te_Ta_avg_aas,Te_Tp_avg_aaio,Te_Ta_avg_aaio,Te_Tp_avg_aaoo,Te_Ta_avg_aaoo)

xttls          = ['(Te/Tp)_avg [ALL, 3DP, ALL]','(Te/Ta)_avg [ALL, 3DP, ALL]','(Te/Tp)_avg [ALL, 3DP, No Shocks]','(Te/Ta)_avg [ALL, 3DP, No Shocks]','(Te/Tp)_avg [ALL, 3DP, Inside  MOs]','(Te/Ta)_avg [ALL, 3DP, Inside  MOs]','(Te/Tp)_avg [ALL, 3DP, Outside MOs]','(Te/Ta)_avg [ALL, 3DP, Outside MOs]']
fnames         = ['Te_Tp_avg_ALL_3DP_ALL','Te_Ta_avg_ALL_3DP_ALL','Te_Tp_avg_ALL_3DP_No_Shocks','Te_Ta_avg_ALL_3DP_No_Shocks','Te_Tp_avg_ALL_3DP_Inside__MOs','Te_Ta_avg_ALL_3DP_Inside__MOs','Te_Tp_avg_ALL_3DP_Outside_MOs','Te_Ta_avg_ALL_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Te_Tp_avg_a3n,Te_Ta_avg_a3n,Te_Tp_avg_a3s,Te_Ta_avg_a3s,Te_Tp_avg_a3io,Te_Ta_avg_a3io,Te_Tp_avg_a3oo,Te_Ta_avg_a3oo)

xttls          = ['(Te/Tp)_avg [SWE, ALL, ALL]','(Te/Ta)_avg [SWE, ALL, ALL]','(Te/Tp)_avg [SWE, ALL, No Shocks]','(Te/Ta)_avg [SWE, ALL, No Shocks]','(Te/Tp)_avg [SWE, ALL, Inside  MOs]','(Te/Ta)_avg [SWE, ALL, Inside  MOs]','(Te/Tp)_avg [SWE, ALL, Outside MOs]','(Te/Ta)_avg [SWE, ALL, Outside MOs]']
fnames         = ['Te_Tp_avg_SWE_ALL_ALL','Te_Ta_avg_SWE_ALL_ALL','Te_Tp_avg_SWE_ALL_No_Shocks','Te_Ta_avg_SWE_ALL_No_Shocks','Te_Tp_avg_SWE_ALL_Inside__MOs','Te_Ta_avg_SWE_ALL_Inside__MOs','Te_Tp_avg_SWE_ALL_Outside_MOs','Te_Ta_avg_SWE_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Te_Tp_avg_san,Te_Ta_avg_san,Te_Tp_avg_sas,Te_Ta_avg_sas,Te_Tp_avg_saio,Te_Ta_avg_saio,Te_Tp_avg_saoo,Te_Ta_avg_saoo)

xttls          = ['(Te/Tp)_avg [SWE, 3DP, ALL]','(Te/Ta)_avg [SWE, 3DP, ALL]','(Te/Tp)_avg [SWE, 3DP, No Shocks]','(Te/Ta)_avg [SWE, 3DP, No Shocks]','(Te/Tp)_avg [SWE, 3DP, Inside  MOs]','(Te/Ta)_avg [SWE, 3DP, Inside  MOs]','(Te/Tp)_avg [SWE, 3DP, Outside MOs]','(Te/Ta)_avg [SWE, 3DP, Outside MOs]']
fnames         = ['Te_Tp_avg_SWE_3DP_ALL','Te_Ta_avg_SWE_3DP_ALL','Te_Tp_avg_SWE_3DP_No_Shocks','Te_Ta_avg_SWE_3DP_No_Shocks','Te_Tp_avg_SWE_3DP_Inside__MOs','Te_Ta_avg_SWE_3DP_Inside__MOs','Te_Tp_avg_SWE_3DP_Outside_MOs','Te_Ta_avg_SWE_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Te_Tp_avg_s3n,Te_Ta_avg_s3n,Te_Tp_avg_s3s,Te_Ta_avg_s3s,Te_Tp_avg_s3io,Te_Ta_avg_s3io,Te_Tp_avg_s3oo,Te_Ta_avg_s3oo)

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]                                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1

;;----------------------------------------------------------------------------------------
;;  Plot (Ts/Te)_per ratios
;;----------------------------------------------------------------------------------------
xran           = [1d-3,1d2]
deltax         = 2d0
yttl0          = 'Number of Events'
ttle0          = '(Ts/Te)_per Ratios'
yran           = [1d0,1d6]

xttls          = ['(Te/Tp)_per [ALL, ALL, ALL]','(Te/Ta)_per [ALL, ALL, ALL]','(Te/Tp)_per [ALL, ALL, No Shocks]','(Te/Ta)_per [ALL, ALL, No Shocks]','(Te/Tp)_per [ALL, ALL, Inside  MOs]','(Te/Ta)_per [ALL, ALL, Inside  MOs]','(Te/Tp)_per [ALL, ALL, Outside MOs]','(Te/Ta)_per [ALL, ALL, Outside MOs]']
fnames         = ['Te_Tp_per_ALL_ALL_ALL','Te_Ta_per_ALL_ALL_ALL','Te_Tp_per_ALL_ALL_No_Shocks','Te_Ta_per_ALL_ALL_No_Shocks','Te_Tp_per_ALL_ALL_Inside__MOs','Te_Ta_per_ALL_ALL_Inside__MOs','Te_Tp_per_ALL_ALL_Outside_MOs','Te_Ta_per_ALL_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Te_Tp_per_aan,Te_Ta_per_aan,Te_Tp_per_aas,Te_Ta_per_aas,Te_Tp_per_aaio,Te_Ta_per_aaio,Te_Tp_per_aaoo,Te_Ta_per_aaoo)

xttls          = ['(Te/Tp)_per [ALL, 3DP, ALL]','(Te/Ta)_per [ALL, 3DP, ALL]','(Te/Tp)_per [ALL, 3DP, No Shocks]','(Te/Ta)_per [ALL, 3DP, No Shocks]','(Te/Tp)_per [ALL, 3DP, Inside  MOs]','(Te/Ta)_per [ALL, 3DP, Inside  MOs]','(Te/Tp)_per [ALL, 3DP, Outside MOs]','(Te/Ta)_per [ALL, 3DP, Outside MOs]']
fnames         = ['Te_Tp_per_ALL_3DP_ALL','Te_Ta_per_ALL_3DP_ALL','Te_Tp_per_ALL_3DP_No_Shocks','Te_Ta_per_ALL_3DP_No_Shocks','Te_Tp_per_ALL_3DP_Inside__MOs','Te_Ta_per_ALL_3DP_Inside__MOs','Te_Tp_per_ALL_3DP_Outside_MOs','Te_Ta_per_ALL_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Te_Tp_per_a3n,Te_Ta_per_a3n,Te_Tp_per_a3s,Te_Ta_per_a3s,Te_Tp_per_a3io,Te_Ta_per_a3io,Te_Tp_per_a3oo,Te_Ta_per_a3oo)

xttls          = ['(Te/Tp)_per [SWE, ALL, ALL]','(Te/Ta)_per [SWE, ALL, ALL]','(Te/Tp)_per [SWE, ALL, No Shocks]','(Te/Ta)_per [SWE, ALL, No Shocks]','(Te/Tp)_per [SWE, ALL, Inside  MOs]','(Te/Ta)_per [SWE, ALL, Inside  MOs]','(Te/Tp)_per [SWE, ALL, Outside MOs]','(Te/Ta)_per [SWE, ALL, Outside MOs]']
fnames         = ['Te_Tp_per_SWE_ALL_ALL','Te_Ta_per_SWE_ALL_ALL','Te_Tp_per_SWE_ALL_No_Shocks','Te_Ta_per_SWE_ALL_No_Shocks','Te_Tp_per_SWE_ALL_Inside__MOs','Te_Ta_per_SWE_ALL_Inside__MOs','Te_Tp_per_SWE_ALL_Outside_MOs','Te_Ta_per_SWE_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Te_Tp_per_san,Te_Ta_per_san,Te_Tp_per_sas,Te_Ta_per_sas,Te_Tp_per_saio,Te_Ta_per_saio,Te_Tp_per_saoo,Te_Ta_per_saoo)

xttls          = ['(Te/Tp)_per [SWE, 3DP, ALL]','(Te/Ta)_per [SWE, 3DP, ALL]','(Te/Tp)_per [SWE, 3DP, No Shocks]','(Te/Ta)_per [SWE, 3DP, No Shocks]','(Te/Tp)_per [SWE, 3DP, Inside  MOs]','(Te/Ta)_per [SWE, 3DP, Inside  MOs]','(Te/Tp)_per [SWE, 3DP, Outside MOs]','(Te/Ta)_per [SWE, 3DP, Outside MOs]']
fnames         = ['Te_Tp_per_SWE_3DP_ALL','Te_Ta_per_SWE_3DP_ALL','Te_Tp_per_SWE_3DP_No_Shocks','Te_Ta_per_SWE_3DP_No_Shocks','Te_Tp_per_SWE_3DP_Inside__MOs','Te_Ta_per_SWE_3DP_Inside__MOs','Te_Tp_per_SWE_3DP_Outside_MOs','Te_Ta_per_SWE_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Te_Tp_per_s3n,Te_Ta_per_s3n,Te_Tp_per_s3s,Te_Ta_per_s3s,Te_Tp_per_s3io,Te_Ta_per_s3io,Te_Tp_per_s3oo,Te_Ta_per_s3oo)

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]                                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1

;;----------------------------------------------------------------------------------------
;;  Plot (Ts/Te)_par ratios
;;----------------------------------------------------------------------------------------
xran           = [1d-3,3d2]
deltax         = 2d0
yttl0          = 'Number of Events'
ttle0          = '(Ts/Te)_par Ratios'
yran           = [1d0,1d6]

xttls          = ['(Te/Tp)_par [ALL, ALL, ALL]','(Te/Ta)_par [ALL, ALL, ALL]','(Te/Tp)_par [ALL, ALL, No Shocks]','(Te/Ta)_par [ALL, ALL, No Shocks]','(Te/Tp)_par [ALL, ALL, Inside  MOs]','(Te/Ta)_par [ALL, ALL, Inside  MOs]','(Te/Tp)_par [ALL, ALL, Outside MOs]','(Te/Ta)_par [ALL, ALL, Outside MOs]']
fnames         = ['Te_Tp_par_ALL_ALL_ALL','Te_Ta_par_ALL_ALL_ALL','Te_Tp_par_ALL_ALL_No_Shocks','Te_Ta_par_ALL_ALL_No_Shocks','Te_Tp_par_ALL_ALL_Inside__MOs','Te_Ta_par_ALL_ALL_Inside__MOs','Te_Tp_par_ALL_ALL_Outside_MOs','Te_Ta_par_ALL_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Te_Tp_par_aan,Te_Ta_par_aan,Te_Tp_par_aas,Te_Ta_par_aas,Te_Tp_par_aaio,Te_Ta_par_aaio,Te_Tp_par_aaoo,Te_Ta_par_aaoo)

xttls          = ['(Te/Tp)_par [ALL, 3DP, ALL]','(Te/Ta)_par [ALL, 3DP, ALL]','(Te/Tp)_par [ALL, 3DP, No Shocks]','(Te/Ta)_par [ALL, 3DP, No Shocks]','(Te/Tp)_par [ALL, 3DP, Inside  MOs]','(Te/Ta)_par [ALL, 3DP, Inside  MOs]','(Te/Tp)_par [ALL, 3DP, Outside MOs]','(Te/Ta)_par [ALL, 3DP, Outside MOs]']
fnames         = ['Te_Tp_par_ALL_3DP_ALL','Te_Ta_par_ALL_3DP_ALL','Te_Tp_par_ALL_3DP_No_Shocks','Te_Ta_par_ALL_3DP_No_Shocks','Te_Tp_par_ALL_3DP_Inside__MOs','Te_Ta_par_ALL_3DP_Inside__MOs','Te_Tp_par_ALL_3DP_Outside_MOs','Te_Ta_par_ALL_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Te_Tp_par_a3n,Te_Ta_par_a3n,Te_Tp_par_a3s,Te_Ta_par_a3s,Te_Tp_par_a3io,Te_Ta_par_a3io,Te_Tp_par_a3oo,Te_Ta_par_a3oo)

xttls          = ['(Te/Tp)_par [SWE, ALL, ALL]','(Te/Ta)_par [SWE, ALL, ALL]','(Te/Tp)_par [SWE, ALL, No Shocks]','(Te/Ta)_par [SWE, ALL, No Shocks]','(Te/Tp)_par [SWE, ALL, Inside  MOs]','(Te/Ta)_par [SWE, ALL, Inside  MOs]','(Te/Tp)_par [SWE, ALL, Outside MOs]','(Te/Ta)_par [SWE, ALL, Outside MOs]']
fnames         = ['Te_Tp_par_SWE_ALL_ALL','Te_Ta_par_SWE_ALL_ALL','Te_Tp_par_SWE_ALL_No_Shocks','Te_Ta_par_SWE_ALL_No_Shocks','Te_Tp_par_SWE_ALL_Inside__MOs','Te_Ta_par_SWE_ALL_Inside__MOs','Te_Tp_par_SWE_ALL_Outside_MOs','Te_Ta_par_SWE_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Te_Tp_par_san,Te_Ta_par_san,Te_Tp_par_sas,Te_Ta_par_sas,Te_Tp_par_saio,Te_Ta_par_saio,Te_Tp_par_saoo,Te_Ta_par_saoo)

xttls          = ['(Te/Tp)_par [SWE, 3DP, ALL]','(Te/Ta)_par [SWE, 3DP, ALL]','(Te/Tp)_par [SWE, 3DP, No Shocks]','(Te/Ta)_par [SWE, 3DP, No Shocks]','(Te/Tp)_par [SWE, 3DP, Inside  MOs]','(Te/Ta)_par [SWE, 3DP, Inside  MOs]','(Te/Tp)_par [SWE, 3DP, Outside MOs]','(Te/Ta)_par [SWE, 3DP, Outside MOs]']
fnames         = ['Te_Tp_par_SWE_3DP_ALL','Te_Ta_par_SWE_3DP_ALL','Te_Tp_par_SWE_3DP_No_Shocks','Te_Ta_par_SWE_3DP_No_Shocks','Te_Tp_par_SWE_3DP_Inside__MOs','Te_Ta_par_SWE_3DP_Inside__MOs','Te_Tp_par_SWE_3DP_Outside_MOs','Te_Ta_par_SWE_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Te_Tp_par_s3n,Te_Ta_par_s3n,Te_Tp_par_s3s,Te_Ta_par_s3s,Te_Tp_par_s3io,Te_Ta_par_s3io,Te_Tp_par_s3oo,Te_Ta_par_s3oo)

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]                                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1


;;----------------------------------------------------------------------------------------
;;  Plot (Ta/Tp)_avg ratios
;;----------------------------------------------------------------------------------------
xran           = [1d-3,5d1]
yran           = [1d0,1d6]
deltax         = 2d0
yttl0          = 'Number of Events'
ttle0          = '(Ta/Tp)_avg Ratios'

xttls          = ['(Ta/Tp)_avg [ALL, ALL, ALL]','(Ta/Tp)_avg [ALL, ALL, No Shocks]','(Ta/Tp)_avg [ALL, ALL, Inside  MOs]','(Ta/Tp)_avg [ALL, ALL, Outside MOs]']
fnames         = ['Ta_Tp_avg_ALL_ALL_ALL','Ta_Tp_avg_ALL_ALL_No_Shocks','Ta_Tp_avg_ALL_ALL_Inside__MOs','Ta_Tp_avg_ALL_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Ta_Tp_avg_aan,Ta_Tp_avg_aas,Ta_Tp_avg_aaio,Ta_Tp_avg_aaoo)

xttls          = ['(Ta/Tp)_avg [ALL, 3DP, ALL]','(Ta/Tp)_avg [ALL, 3DP, No Shocks]','(Ta/Tp)_avg [ALL, 3DP, Inside  MOs]','(Ta/Tp)_avg [ALL, 3DP, Outside MOs]']
fnames         = ['Ta_Tp_avg_ALL_3DP_ALL','Ta_Tp_avg_ALL_3DP_No_Shocks','Ta_Tp_avg_ALL_3DP_Inside__MOs','Ta_Tp_avg_ALL_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Ta_Tp_avg_a3n,Ta_Tp_avg_a3s,Ta_Tp_avg_a3io,Ta_Tp_avg_a3oo)

xttls          = ['(Ta/Tp)_avg [SWE, ALL, ALL]','(Ta/Tp)_avg [SWE, ALL, No Shocks]','(Ta/Tp)_avg [SWE, ALL, Inside  MOs]','(Ta/Tp)_avg [SWE, ALL, Outside MOs]']
fnames         = ['Ta_Tp_avg_SWE_ALL_ALL','Ta_Tp_avg_SWE_ALL_No_Shocks','Ta_Tp_avg_SWE_ALL_Inside__MOs','Ta_Tp_avg_SWE_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Ta_Tp_avg_san,Ta_Tp_avg_sas,Ta_Tp_avg_saio,Ta_Tp_avg_saoo)

xttls          = ['(Ta/Tp)_avg [SWE, 3DP, ALL]','(Ta/Tp)_avg [SWE, 3DP, No Shocks]','(Ta/Tp)_avg [SWE, 3DP, Inside  MOs]','(Ta/Tp)_avg [SWE, 3DP, Outside MOs]']
fnames         = ['Ta_Tp_avg_SWE_3DP_ALL','Ta_Tp_avg_SWE_3DP_No_Shocks','Ta_Tp_avg_SWE_3DP_Inside__MOs','Ta_Tp_avg_SWE_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Ta_Tp_avg_s3n,Ta_Tp_avg_s3s,Ta_Tp_avg_s3io,Ta_Tp_avg_s3oo)

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]                                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1

;;----------------------------------------------------------------------------------------
;;  Plot (Ta/Tp)_per ratios
;;----------------------------------------------------------------------------------------
xran           = [1d-3,5d1]
yran           = [1d0,1d6]
deltax         = 2d0
yttl0          = 'Number of Events'
ttle0          = '(Ta/Tp)_per Ratios'

xttls          = ['(Ta/Tp)_per [ALL, ALL, ALL]','(Ta/Tp)_per [ALL, ALL, No Shocks]','(Ta/Tp)_per [ALL, ALL, Inside  MOs]','(Ta/Tp)_per [ALL, ALL, Outside MOs]']
fnames         = ['Ta_Tp_per_ALL_ALL_ALL','Ta_Tp_per_ALL_ALL_No_Shocks','Ta_Tp_per_ALL_ALL_Inside__MOs','Ta_Tp_per_ALL_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Ta_Tp_per_aan,Ta_Tp_per_aas,Ta_Tp_per_aaio,Ta_Tp_per_aaoo)

xttls          = ['(Ta/Tp)_per [ALL, 3DP, ALL]','(Ta/Tp)_per [ALL, 3DP, No Shocks]','(Ta/Tp)_per [ALL, 3DP, Inside  MOs]','(Ta/Tp)_per [ALL, 3DP, Outside MOs]']
fnames         = ['Ta_Tp_per_ALL_3DP_ALL','Ta_Tp_per_ALL_3DP_No_Shocks','Ta_Tp_per_ALL_3DP_Inside__MOs','Ta_Tp_per_ALL_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Ta_Tp_per_a3n,Ta_Tp_per_a3s,Ta_Tp_per_a3io,Ta_Tp_per_a3oo)

xttls          = ['(Ta/Tp)_per [SWE, ALL, ALL]','(Ta/Tp)_per [SWE, ALL, No Shocks]','(Ta/Tp)_per [SWE, ALL, Inside  MOs]','(Ta/Tp)_per [SWE, ALL, Outside MOs]']
fnames         = ['Ta_Tp_per_SWE_ALL_ALL','Ta_Tp_per_SWE_ALL_No_Shocks','Ta_Tp_per_SWE_ALL_Inside__MOs','Ta_Tp_per_SWE_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Ta_Tp_per_san,Ta_Tp_per_sas,Ta_Tp_per_saio,Ta_Tp_per_saoo)

xttls          = ['(Ta/Tp)_per [SWE, 3DP, ALL]','(Ta/Tp)_per [SWE, 3DP, No Shocks]','(Ta/Tp)_per [SWE, 3DP, Inside  MOs]','(Ta/Tp)_per [SWE, 3DP, Outside MOs]']
fnames         = ['Ta_Tp_per_SWE_3DP_ALL','Ta_Tp_per_SWE_3DP_No_Shocks','Ta_Tp_per_SWE_3DP_Inside__MOs','Ta_Tp_per_SWE_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Ta_Tp_per_s3n,Ta_Tp_per_s3s,Ta_Tp_per_s3io,Ta_Tp_per_s3oo)

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]                                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1

;;----------------------------------------------------------------------------------------
;;  Plot (Ta/Tp)_par ratios
;;----------------------------------------------------------------------------------------
xran           = [1d-3,5d1]
yran           = [1d0,1d6]
deltax         = 2d0
yttl0          = 'Number of Events'
ttle0          = '(Ta/Tp)_par Ratios'

xttls          = ['(Ta/Tp)_par [ALL, ALL, ALL]','(Ta/Tp)_par [ALL, ALL, No Shocks]','(Ta/Tp)_par [ALL, ALL, Inside  MOs]','(Ta/Tp)_par [ALL, ALL, Outside MOs]']
fnames         = ['Ta_Tp_par_ALL_ALL_ALL','Ta_Tp_par_ALL_ALL_No_Shocks','Ta_Tp_par_ALL_ALL_Inside__MOs','Ta_Tp_par_ALL_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Ta_Tp_par_aan,Ta_Tp_par_aas,Ta_Tp_par_aaio,Ta_Tp_par_aaoo)

xttls          = ['(Ta/Tp)_par [ALL, 3DP, ALL]','(Ta/Tp)_par [ALL, 3DP, No Shocks]','(Ta/Tp)_par [ALL, 3DP, Inside  MOs]','(Ta/Tp)_par [ALL, 3DP, Outside MOs]']
fnames         = ['Ta_Tp_par_ALL_3DP_ALL','Ta_Tp_par_ALL_3DP_No_Shocks','Ta_Tp_par_ALL_3DP_Inside__MOs','Ta_Tp_par_ALL_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Ta_Tp_par_a3n,Ta_Tp_par_a3s,Ta_Tp_par_a3io,Ta_Tp_par_a3oo)

xttls          = ['(Ta/Tp)_par [SWE, ALL, ALL]','(Ta/Tp)_par [SWE, ALL, No Shocks]','(Ta/Tp)_par [SWE, ALL, Inside  MOs]','(Ta/Tp)_par [SWE, ALL, Outside MOs]']
fnames         = ['Ta_Tp_par_SWE_ALL_ALL','Ta_Tp_par_SWE_ALL_No_Shocks','Ta_Tp_par_SWE_ALL_Inside__MOs','Ta_Tp_par_SWE_ALL_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Ta_Tp_par_san,Ta_Tp_par_sas,Ta_Tp_par_saio,Ta_Tp_par_saoo)

xttls          = ['(Ta/Tp)_par [SWE, 3DP, ALL]','(Ta/Tp)_par [SWE, 3DP, No Shocks]','(Ta/Tp)_par [SWE, 3DP, Inside  MOs]','(Ta/Tp)_par [SWE, 3DP, Outside MOs]']
fnames         = ['Ta_Tp_par_SWE_3DP_ALL','Ta_Tp_par_SWE_3DP_No_Shocks','Ta_Tp_par_SWE_3DP_Inside__MOs','Ta_Tp_par_SWE_3DP_Outside_MOs']
xdat           = CREATE_STRUCT(fnames,Ta_Tp_par_s3n,Ta_Tp_par_s3s,Ta_Tp_par_s3io,Ta_Tp_par_s3oo)

ndat           = N_TAGS(xdat)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR j=0L, ndat[0] - 1L DO BEGIN                                                                          $
  xdata = xdat.(j)                                                                                     & $
  fname = 'Wind_'+fnames[j]                                                                            & $
  xttle = xttls[j]                                                                                     & $
  temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                             TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                             WIND_N=1



;;----------------------------------------------------------------------------------------
;;  Plot Temp ratios on uniform axes ranges
;;----------------------------------------------------------------------------------------
;;  Define some params that are uniform across all plot types
xran           = [1d-3,1d2]
yran           = [1d0,1d6]
deltax         = 2d0
yttl0          = 'Number of Events'
avpape_str     = ['avg','par','per']                                                      ;;  Index:  i
file_suffxs    = ['ALL','No_Shocks','Inside__MOs','Outside_MOs']                          ;;  Index:  j
xyt_suffx_pre  = ' [SWE, 3DP, '
xyt_suffx_suf  = ['ALL','No Shocks','Inside  MOs','Outside MOs']
xyt_suffxs     = xyt_suffx_pre[0]+xyt_suffx_suf+']'                                       ;;  Index:  j

;;---------------------------------------------------------
;;  Plot (Te/Tp)_i ratios
;;---------------------------------------------------------
spec_sub1      = 'e'
spec_sub2      = 'p'
;;  Define type specific params
x_t_prefx      = '(T'+spec_sub1[0]+'/T'+spec_sub2[0]+')_'+avpape_str                      ;;  Index:  i
ttle_avpape    = x_t_prefx+' Ratios'                                                      ;;  Index:  i
file_pref      = 'T'+spec_sub1[0]+'_T'+spec_sub2[0]+'_'+avpape_str+'_SWE_3DP_'            ;;  Index:  i
;;  (Te/Tp)_avg ratios
itags          = 'I'+num2int_str(LINDGEN(20),NUM_CHAR=2L,/ZERO_PAD)
fname_avg_j    = file_pref[0]+file_suffxs+'_2'
fname_par_j    = file_pref[1]+file_suffxs+'_2'
fname_per_j    = file_pref[2]+file_suffxs+'_2'
xttls_avg_j    = x_t_prefx[0]+xyt_suffxs
xttls_par_j    = x_t_prefx[1]+xyt_suffxs
xttls_per_j    = x_t_prefx[2]+xyt_suffxs
xdat_avg_j     = CREATE_STRUCT(fname_avg_j,Te_Tp_avg_s3n,Te_Tp_avg_s3s,Te_Tp_avg_s3io,Te_Tp_avg_s3oo)
xdat_par_j     = CREATE_STRUCT(fname_par_j,Te_Tp_par_s3n,Te_Tp_par_s3s,Te_Tp_par_s3io,Te_Tp_par_s3oo)
xdat_per_j     = CREATE_STRUCT(fname_per_j,Te_Tp_per_s3n,Te_Tp_per_s3s,Te_Tp_per_s3io,Te_Tp_per_s3oo)

;;---------------------------------------------------------
;;  Plot (Te/Ta)_i ratios
;;---------------------------------------------------------
spec_sub1      = 'e'
spec_sub2      = 'a'
;;  Define type specific params
x_t_prefx      = '(T'+spec_sub1[0]+'/T'+spec_sub2[0]+')_'+avpape_str                      ;;  Index:  i
ttle_avpape    = x_t_prefx+' Ratios'                                                      ;;  Index:  i
file_pref      = 'T'+spec_sub1[0]+'_T'+spec_sub2[0]+'_'+avpape_str+'_SWE_3DP_'            ;;  Index:  i

;;  (Te/Ta)_avg ratios
itags          = 'I'+num2int_str(LINDGEN(20),NUM_CHAR=2L,/ZERO_PAD)
fname_avg_j    = file_pref[0]+file_suffxs+'_2'
fname_par_j    = file_pref[1]+file_suffxs+'_2'
fname_per_j    = file_pref[2]+file_suffxs+'_2'
xttls_avg_j    = x_t_prefx[0]+xyt_suffxs
xttls_par_j    = x_t_prefx[1]+xyt_suffxs
xttls_per_j    = x_t_prefx[2]+xyt_suffxs
xdat_avg_j     = CREATE_STRUCT(fname_avg_j,Te_Ta_avg_s3n,Te_Ta_avg_s3s,Te_Ta_avg_s3io,Te_Ta_avg_s3oo)
xdat_par_j     = CREATE_STRUCT(fname_par_j,Te_Ta_par_s3n,Te_Ta_par_s3s,Te_Ta_par_s3io,Te_Ta_par_s3oo)
xdat_per_j     = CREATE_STRUCT(fname_per_j,Te_Ta_per_s3n,Te_Ta_per_s3s,Te_Ta_per_s3io,Te_Ta_per_s3oo)

;;---------------------------------------------------------
;;  Plot (Ta/Tp)_i ratios
;;---------------------------------------------------------
spec_sub1      = 'a'
spec_sub2      = 'p'
;;  Define type specific params
x_t_prefx      = '(T'+spec_sub1[0]+'/T'+spec_sub2[0]+')_'+avpape_str                      ;;  Index:  i
ttle_avpape    = x_t_prefx+' Ratios'                                                      ;;  Index:  i
file_pref      = 'T'+spec_sub1[0]+'_T'+spec_sub2[0]+'_'+avpape_str+'_SWE_3DP_'            ;;  Index:  i

;;  (Ta/Tp)_avg ratios
itags          = 'I'+num2int_str(LINDGEN(20),NUM_CHAR=2L,/ZERO_PAD)
fname_avg_j    = file_pref[0]+file_suffxs+'_2'
fname_par_j    = file_pref[1]+file_suffxs+'_2'
fname_per_j    = file_pref[2]+file_suffxs+'_2'
xttls_avg_j    = x_t_prefx[0]+xyt_suffxs
xttls_par_j    = x_t_prefx[1]+xyt_suffxs
xttls_per_j    = x_t_prefx[2]+xyt_suffxs
xdat_avg_j     = CREATE_STRUCT(fname_avg_j,Ta_Tp_avg_s3n,Ta_Tp_avg_s3s,Ta_Tp_avg_s3io,Te_Tp_avg_s3oo)
xdat_par_j     = CREATE_STRUCT(fname_par_j,Ta_Tp_par_s3n,Ta_Tp_par_s3s,Ta_Tp_par_s3io,Te_Tp_par_s3oo)
xdat_per_j     = CREATE_STRUCT(fname_per_j,Ta_Tp_per_s3n,Ta_Tp_per_s3s,Ta_Tp_per_s3io,Te_Tp_per_s3oo)

;;---------------------------------------------------------
;;  Combine and plot
;;---------------------------------------------------------
xdat_i         = CREATE_STRUCT(itags[0:2], xdat_avg_j, xdat_par_j, xdat_per_j)
xttls_i        = CREATE_STRUCT(itags[0:2],xttls_avg_j,xttls_par_j,xttls_per_j)
fname_i        = CREATE_STRUCT(itags[0:2],fname_avg_j,fname_par_j,fname_per_j)
ni             = N_TAGS(xdat_i)
nj             = N_TAGS(xdat_avg_j)
.compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_hist_quick_plot.pro
FOR i=0L, ni[0] - 1L DO BEGIN                                                                              $
  xdat  = xdat_i.(i)                                                                                     & $
  fnams = fname_i.(i)                                                                                    & $
  xttls = xttls_i.(i)                                                                                    & $
  ttle0 = ttle_avpape[i]                                                                                 & $
  FOR j=0L, nj[0] - 1L DO BEGIN                                                                            $
    xdata = xdat.(j)                                                                                     & $
    fname = 'Wind_'+fnams[j]                                                                             & $
    xttle = xttls[j]                                                                                     & $
    temp_hist_quick_plot,xdata,XTITLE=xttle[0],YTITLE=yttl0[0],XRANGE=xran,YRANGE=yran,                    $
                               TITLE=ttle0[0],DELTAX=deltax[0],FILE_NAME=fname[0],                         $
                               WIND_N=1






;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Plot (Ts/Te)_tot, (Ts/Te)_perp, and (Ts/Te)_para ratios
;;----------------------------------------------------------------------------------------
xran           = [1d-3,5d1]
del_Trat       = 2d0
thck           = 2e0
yttl0          = 'Number of Events'
xttl0          = 'Te/Tp [Avg]'
xttl1          = 'Te/Ta [Avg]'
gd_trat        = N_ELEMENTS(Te_Tp_avg)
tot_cnt_out    = 'Total #: '+(num2int_str(gd_trat[0],NUM_CHAR=8,/ZERO_PAD))[0]
;;  Calculate histograms
;hist_TeTp_avg  = HISTOGRAM(Te_Tp_avg,BINSIZE=del_Trat[0],LOCATIONS=locs_TeTp_avg,MAX=xran[1],MIN=xran[0],/NAN)
;hist_TeTa_avg  = HISTOGRAM(Te_Ta_avg,BINSIZE=del_Trat[0],LOCATIONS=locs_TeTa_avg,MAX=xran[1],MIN=xran[0],/NAN)
l10hist_TeTpav = HISTOGRAM(ALOG10(Te_Tp_avg),BINSIZE=ALOG10(del_Trat[0]),LOCATIONS=l10locs_TeTp_avg,MAX=ALOG10(xran[1]),MIN=ALOG10(xran[0]),/NAN)
l10hist_TeTaav = HISTOGRAM(ALOG10(Te_Ta_avg),BINSIZE=ALOG10(del_Trat[0]),LOCATIONS=l10locs_TeTa_avg,MAX=ALOG10(xran[1]),MIN=ALOG10(xran[0]),/NAN)
;;  Define plot limits structures
;yranp          = [1d0,(1.05*MAX(ABS(hist_TeTp_avg),/NAN)) > 2d2]
;yrana          = [1d0,(1.05*MAX(ABS(hist_TeTa_avg),/NAN)) > 2d2]
yranp          = [1d0,(2.00*MAX(ABS(l10hist_TeTpav),/NAN)) > 2d2]
yrana          = [1d0,(2.00*MAX(ABS(l10hist_TeTaav),/NAN)) > 2d2]
pstrp          = {XRANGE:xran,XSTYLE:1,YRANGE:yranp,YSTYLE:1,XTICKS:9,XMINOR:10,NODATA:1,$
                  PSYM:10,XTITLE:xttl0[0],YLOG:1,YMINOR:9L,YTITLE:yttl0[0],XLOG:1,CHARSIZE:2}
pstra          = {XRANGE:xran,XSTYLE:1,YRANGE:yrana,YSTYLE:1,XTICKS:9,XMINOR:10,NODATA:1,$
                  PSYM:10,XTITLE:xttl1[0],YLOG:1,YMINOR:9L,YTITLE:yttl0[0],XLOG:1,CHARSIZE:2}
;;  Define mean and median
avg_TeTp       = MEAN(Te_Tp_avg,/NAN)
avg_TeTa       = MEAN(Te_Ta_avg,/NAN)
med_TeTp       = MEDIAN(Te_Tp_avg)
med_TeTa       = MEDIAN(Te_Ta_avg)
;;  Plot theta_kB angles
;xdata0         = locs_TeTp_avg
;xdata1         = locs_TeTa_avg
;ydata0         = hist_TeTp_avg
;ydata1         = hist_TeTa_avg
xdata0         = 1d1^(l10locs_TeTp_avg)
xdata1         = 1d1^(l10locs_TeTa_avg)
ydata0         = l10hist_TeTpav
ydata1         = l10hist_TeTaav
pstr0          = pstrp
pstr1          = pstra
WSET,1
WSHOW,1
!P.MULTI       = [0,1,2]
PLOT,xdata0,ydata0,_EXTRA=pstr0;,TITLE=titleb[0]
  OPLOT,xdata0,ydata0,PSYM=10,COLOR= 50,THICK=thck[0]
  OPLOT,[avg_TeTp[0],avg_TeTp[0]],yranp,COLOR=250,THICK=thck[0]
  OPLOT,[med_TeTp[0],med_TeTp[0]],yranp,COLOR=200,THICK=thck[0]
PLOT,xdata1,ydata1,_EXTRA=pstr1;,TITLE=titleb[0]
  OPLOT,xdata1,ydata1,PSYM=10,COLOR= 50,THICK=thck[0]
  OPLOT,[avg_TeTa[0],avg_TeTa[0]],yranp,COLOR=250,THICK=thck[0]
  OPLOT,[med_TeTa[0],med_TeTa[0]],yranp,COLOR=200,THICK=thck[0]
  XYOUTS,0.45,0.90,tot_cnt_out[0],/NORMAL,COLOR=250,CHARSIZE=1.
!P.MULTI       = 0



;;  
;;  -- get 3DP electron fits
;;    --  limit to QF > 5 and R > 30 Re for 3DP set
;;    --  interpolate to SWE data time stamps
;;  --  Analysis
;;    --  compute (Tp/Te)_tot, (Tp/Te)_perp, and (Tp/Te)_para for entire set
;;    --  compute (Ta/Te)_tot, (Ta/Te)_perp, and (Ta/Te)_para for entire set
;;    --  compute (beta_p/beta_e)_j (np may not equal ne)
;;    --  compare ∂B to these parameters
;;    --  separate by solar wind speed
;;  





















