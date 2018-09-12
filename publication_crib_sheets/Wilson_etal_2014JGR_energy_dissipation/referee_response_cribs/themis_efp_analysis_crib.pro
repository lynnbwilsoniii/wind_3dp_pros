;;----------------------------------------------------------------------------------------
;;  Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;;  Electron mass [kg]
mp             = 1.6726217770d-27     ;;  Proton mass [kg]
ma             = 6.6446567500d-27     ;;  Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;;  Speed of light in vacuum [m/s]
epo            = 8.8541878170d-12     ;;  Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;;  Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;;  Fundamental charge [C]
kB             = 1.3806488000d-23     ;;  Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;;  Planck Constant [J s]
GG             = 6.6738400000d-11     ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [J]
;;  Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K
R_E            = 6.37814d3            ;;  Earth's Equitorial Radius [km]
;;----------------------------------------------------------------------------------------
;;  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  2009-09-26 [1 Crossing]
tdate          = '2009-09-26'
tr_00          = tdate[0]+'/'+['12:00:00','17:40:00']
date           = '092609'
probe          = 'a'
sc             = probe[0]
scu            = STRUPCASE(sc[0])
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
scpref         = 'th'+sc[0]+'_'
tr_jj          = time_double(tdate[0]+'/'+['15:48:20.000','15:58:25.000'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['15:53:09.911','15:53:10.249'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = d
t_ramp2        = d
traz           = t_ramp0[0] + [-1d0,1d0]*165d0  ;;  330 s window centered on ramp
;;  Example waveform times
tr_ww          = time_double(tdate[0]+'/'+['15:53:02.500','15:53:15.600'])
tr_esw0        = time_double(tdate[0]+'/'+['15:53:03.475','15:53:03.500'])  ;;  train of ESWs [efw, Int. 0]
tr_esw1        = time_double(tdate[0]+'/'+['15:53:04.474','15:53:04.503'])  ;;  train of ESWs [efw, Int. 0]
tr_esw2        = time_double(tdate[0]+'/'+['15:53:09.910','15:53:09.940'])  ;;  two      ESWs [efw, Int. 1]
tr_whi         = time_double(tdate[0]+'/'+['15:53:10.860','15:53:11.203'])  ;;  example whistlers [scw, Int. 1]
tr_ww1         = time_double(tdate[0]+'/'+['15:53:09.165','15:53:15.590'])
tr_ww2         = time_double(tdate[0]+'/'+['15:53:09.165','15:53:12.500'])
;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
def_dir        = '../Lynn_B_Wilson_III/LaTeX/First_Author_Papers/themis_energy_dissipation/crib_sheets/'
mdir           = FILE_EXPAND_PATH(def_dir[0])
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_'
fsuff          = 'efp-despiked_rmEconv-DC-despun_'
fname          = fpref[0]+fsuff[0]+'*.tplot'
file           = FILE_SEARCH(mdir,fname[0])
tplot_restore,FILENAME=file[0],VERBOSE=0
;;----------------------------------------------------------------------------------------
;;  Set defaults
;;----------------------------------------------------------------------------------------
!themis.VERBOSE = 2
tplot_options,'VERBOSE',2
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'
;;  Use default colors
coord_mag      = 'mag'
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
all_coords     = [coord_dsl[0],coord_gse[0],coord_gsm[0]]
FOR j=0L, N_ELEMENTS(all_coords) - 1L DO BEGIN       $
  options,tnames('*_'+all_coords[j]+'*'),'COLORS'  & $
  options,tnames('*_'+all_coords[j]+'*'),'COLORS',[250,150, 50],/DEF

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='THEMIS-'+scu[0]+' Plots ['+tdate[0]+']'

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
;;----------------------------------------------------------------------------------------
;;  Define relevant TPLOT handles
;;----------------------------------------------------------------------------------------
;;  Middle parts of TPLOT handles
;;  FGM...
modes_slh      = ['s','l','h']
mode_fgm       = 'fg'+modes_slh
fgm_pren       = scpref[0]+mode_fgm+'_'
;;  SCM...
modes_scm      = 'sc'+['p','w']
scm_midnm      = '_cal_'
;;  EFI...
modes_efi      = 'ef'+['p','w']
efi_midnm      = '_cal_'
efi_nodcnm     = '_cal_rmDCoffsets_'
low__suffx     = '_LowPassFilt_*Hz'
high_suffx     = '_HighPassFilt_*Hz'
efi_smthnm     = '_cal_detrended_'
efi_smdEdt     = '_cal_detrended_dEdt_'
efi_despke     = '_cal_rmDCoffsets_despiked_'
efi_despksm    = '_cal_rmDCoffsets_despiked_sm*'
efi_despke2    = '_cal_despiked_'
efi_despke3    = '_cal_despiked_rmEconv_'
efi_despk_nodc = '_cal_despiked_rmEconv_rmDC_'
efp_spinfitmod = '_cal_despiked_rmEconv_rmDC_spinfit_model_'
efp_rmspfitmod = '_cal_despiked_rmEconv_rmDC_rmspinfitmodel_'
efprmspftdspk0 = '_cal_despiked_rmEconv_rmDC_rmspinfitmodel_despiked_'
efp_rmspftDC_n = '_cal_rmspftmod_rm-upDCoff_'
efp_rmsfDCdtrd = '_cal_rmspftmod_rm-upDCoff_detrend*'
;;  State...
state_midnm    = 'state_'
sp_per_suff    = state_midnm[0]+'spinper'
sp_phs_suff    = state_midnm[0]+'spinphase'

;;  State TPLOT handles
sp_per_tpnm    = tnames(scpref[0]+sp_per_suff[0])
sp_phs_tpnm    = tnames(scpref[0]+sp_phs_suff[0])
spphs_int_tpnm = tnames(sp_phs_tpnm[0]+'_int')
dTdt_spphs_nm  = tnames(sp_phs_tpnm[0]+'_dTdt')
sunpulse_nm    = tnames(scpref[0]+state_midnm[0]+'sun_pulse')

;;  EFI TPLOT handles
efp_dsl_orig   = tnames(pref[0]+modes_efi[0]+efi_midnm[0]+coord_dsl[0])                  ;;  Level-1 efp data [DSL, mV/m]
efw_dsl_orig   = tnames(pref[0]+modes_efi[1]+efi_midnm[0]+coord_dsl[0])                  ;;  Level-1 efw data [DSL, mV/m]
efp_nodc_dsl   = tnames(pref[0]+modes_efi[0]+efi_nodcnm[0]+coord_dsl[0])                 ;;  Removed DC-offsets from EFP_DSL_ORIG
efp_nodclp_dsl = tnames(pref[0]+modes_efi[0]+efi_nodcnm[0]+coord_dsl[0]+low__suffx[0])   ;;  Low-Pass Filtered EFP_NODC_DSL
efp_nodchp_dsl = tnames(pref[0]+modes_efi[0]+efi_nodcnm[0]+coord_dsl[0]+high_suffx[0])   ;;  High-Pass Filtered EFP_NODC_DSL
efp_detrnd_dsl = tnames(pref[0]+modes_efi[0]+efi_smthnm[0]+coord_dsl[0])                 ;;  Detrended (i.e., keep high frequencies) version of EFP_DSL_ORIG
efp_smdEdt_dsl = tnames(pref[0]+modes_efi[0]+efi_smdEdt[0]+coord_dsl[0])                 ;;  Time derivative of EFP_DETRND_DSL
efp_dpkrDC_dsl = tnames(pref[0]+modes_efi[0]+efi_despke[0]+coord_dsl[0])                 ;;  De-spiked version of EFP_NODC_DSL
efp_dpkdtr_dsl = tnames(pref[0]+modes_efi[0]+efi_despksm[0]+coord_dsl[0])                ;;  Detrended version of EFP_DPKRDC_DSL
efp_despke_dsl = tnames(pref[0]+modes_efi[0]+efi_despke2[0]+coord_dsl[0])                ;;  De-spiked version of EFP_DSL_ORIG
efp_dpkrEc_dsl = tnames(pref[0]+modes_efi[0]+efi_despke3[0]+coord_dsl[0])                ;;  Removed convection E-field from EFP_DESPKE_DSL
efpdpkrEcDCdsl = tnames(pref[0]+modes_efi[0]+efi_despk_nodc[0]+coord_dsl[0])             ;;  Removed DC-offsets from EFP_DPKREC_DSL
efpdspkrEcdcsf = tnames(pref[0]+modes_efi[0]+efp_spinfitmod[0]+coord_dsl[0])             ;;  Spinfit Model of EFPDPKRECDCDSL
efp_rmspft_dsl = tnames(pref[0]+modes_efi[0]+efp_rmspfitmod[0]+coord_dsl[0])             ;;  EFPDPKRECDCDSL - EFPDSPKRECDCSF
efp_rmspftdspk = tnames(pref[0]+modes_efi[0]+efprmspftdspk0[0]+coord_dsl[0])             ;;  De-spiked version of EFP_RMSPFT_DSL
efp_rmspftDC_n = tnames(pref[0]+modes_efi[0]+efp_rmspftDC_n[0]+coord_dsl[0])             ;;  EFP_DSL_ORIG - EFPDSPKRECDCSF  (only near shock)
efp_rmsfDC_dtr = tnames(pref[0]+modes_efi[0]+efp_rmsfDCdtrd[0]+coord_dsl[0])             ;;  Detrended version of EFP_RMSPFTDC

;;  SCM TPLOT handles
scp_dsl_orig   = tnames(pref[0]+modes_scm[0]+scm_midnm[0]+coord_dsl[0])
scw_dsl_orig   = tnames(pref[0]+modes_scm[1]+scm_midnm[0]+coord_dsl[0])

;;  FGM TPLOT handles
fgm_mag        = tnames(fgm_pren[*]+'mag')
fgm_dsl        = tnames(fgm_pren[*]+coord_dsl[0])
fgm_gse        = tnames(fgm_pren[*]+coord_gse[0])
fgm_gsm        = tnames(fgm_pren[*]+coord_gsm[0])
fgs_mag_dsl    = [fgm_mag[0],fgm_dsl[0]]
fgl_mag_dsl    = [fgm_mag[1],fgm_dsl[1]]
fgh_mag_dsl    = [fgm_mag[2],fgm_dsl[2]]
fgm_tpn_str    = {T0:fgs_mag_dsl,T1:fgl_mag_dsl,T2:fgh_mag_dsl}
;;----------------------------------------------------------------------------------------
;;  Determine intervals
;;----------------------------------------------------------------------------------------
;;  Get EFI data
get_data,efp_dsl_orig[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
;;  Define parameters
efp_t          = temp_efp.X
efp_v          = temp_efp.Y
;;  1st remove any DC-offsets from efw
sratefp        = DOUBLE(sample_rate(efp_t,GAP_THRESH=6d0,/AVE))
se_pels        = t_interval_find(efp_t,GAP_THRESH=4d0/sratefp[0])
pint           = N_ELEMENTS(se_pels[*,0])
;;  Only use indices near shock
a_ind          = LINDGEN(N_ELEMENTS(efp_t))
gind           = LONG(a_ind[se_pels[2,0]:se_pels[2,1]])

;;  Clean up
DELVAR,temp_efp,dlim_efp,lim_efp,efp_t,efp_v
;;----------------------------------------------------------------------------------------
;;  Plot Data
;;----------------------------------------------------------------------------------------
fgm_mode       = 0L      ;;  fgs
fgm_mode       = 1L      ;;  fgl
fgm_mode       = 2L      ;;  fgh


all_efi_tpnm   = [efp_dsl_orig[0],efp_rmspftDC_n[0]]
all_fgm_tpnm   = fgm_tpn_str.(fgm_mode[0])
nna            = [all_fgm_tpnm,all_efi_tpnm]

WSET,0
  tplot,nna,TRANGE=traz
;;----------------------------------------------------------------------------------------
;;  Get data and use a Median filter
;;----------------------------------------------------------------------------------------
wi,1
wi,2
wi,3

;;  Get Eo [original] - (Spinfit Model) data
get_data,efp_rmspftDC_n[0],DATA=efp_rmspftDC,DLIM=dlim_efp_rmsfDC,LIM=lim_efp_rmsfDC
;;  Define parameters
vec_t          = efp_rmspftDC.X
vec_v          = efp_rmspftDC.Y
;;  Find |v| {or magnitude of vector v}
mag_v          = mag__vec(vec_v,/TWO)
;;  Find v/|v| {or unit vector}
vec_u          = unit_vec(vec_v)


;;  X-filtered
med_Eo_x       = MEDIAN(ydats[*,0])
med_Eo_x__64   = MEDIAN(ydats[*,0],64L)    ;;    64 bin median filter
med_Eo_x_128   = MEDIAN(ydats[*,0],128L)   ;;   128 bin median filter
med_Eo_x_256   = MEDIAN(ydats[*,0],256L)   ;;   256 bin median filter
med_Eo_x_512   = MEDIAN(ydats[*,0],512L)   ;;   512 bin median filter
med_Eo_x1024   = MEDIAN(ydats[*,0],1024L)  ;;  1024 bin median filter
PRINT, ';;', med_Eo_x[0] & PRINT, ';;', minmax(med_Eo_x__64) & $
PRINT, ';;', minmax(med_Eo_x_128) & PRINT, ';;', minmax(med_Eo_x_256) & $
PRINT, ';;', minmax(med_Eo_x_512) & PRINT, ';;', minmax(med_Eo_x1024)
;;       1.2395253
;;      -495.97841       7.7277904
;;      -438.60577       6.8497803
;;      -308.69037       6.7033724
;;      -121.17821       5.7788075
;;      -281.42799       5.3132564

;;  Y-filtered
med_Eo_y       = MEDIAN(ydats[*,1])
med_Eo_y__64   = MEDIAN(ydats[*,1],64L)    ;;    64 bin median filter
med_Eo_y_128   = MEDIAN(ydats[*,1],128L)   ;;   128 bin median filter
med_Eo_y_256   = MEDIAN(ydats[*,1],256L)   ;;   256 bin median filter
med_Eo_y_512   = MEDIAN(ydats[*,1],512L)   ;;   512 bin median filter
med_Eo_y1024   = MEDIAN(ydats[*,1],1024L)  ;;  1024 bin median filter
PRINT, ';;', med_Eo_y[0] & PRINT, ';;', minmax(med_Eo_y__64) & $
PRINT, ';;', minmax(med_Eo_y_128) & PRINT, ';;', minmax(med_Eo_y_256) & $
PRINT, ';;', minmax(med_Eo_y_512) & PRINT, ';;', minmax(med_Eo_y1024)
;;     -0.14427861
;;      -136.15651       178.92098
;;      -8.2855925       28.346428
;;      -4.8542650       5.6272626
;;      -3.9323827       3.8191541
;;      -22.275237       8.7555510

;;  Z-filtered
med_Eo_z       = MEDIAN(ydats[*,2])
med_Eo_z__64   = MEDIAN(ydats[*,2],64L)    ;;    64 bin median filter
med_Eo_z_128   = MEDIAN(ydats[*,2],128L)   ;;   128 bin median filter
med_Eo_z_256   = MEDIAN(ydats[*,2],256L)   ;;   256 bin median filter
med_Eo_z_512   = MEDIAN(ydats[*,2],512L)   ;;   512 bin median filter
med_Eo_z1024   = MEDIAN(ydats[*,2],1024L)  ;;  1024 bin median filter
PRINT, ';;', med_Eo_z[0] & PRINT, ';;', minmax(med_Eo_z__64) & $
PRINT, ';;', minmax(med_Eo_z_128) & PRINT, ';;', minmax(med_Eo_z_256) & $
PRINT, ';;', minmax(med_Eo_z_512) & PRINT, ';;', minmax(med_Eo_z1024)
;;      -3.7555603
;;      -22.881640       10.030278
;;      -22.161325       9.8244517
;;      -20.720031       8.4543842
;;      -17.222293       5.9797383
;;      -11.811772       2.4294152


tdat           = vec_t MOD 864d2
xdat_x         = ydats[*,0]
xdat_y         = ydats[*,1]
xdat_z         = ydats[*,2]
zdat_x0        = med_Eo_x_128
zdat_x1        = med_Eo_x_512
zdat_x2        = med_Eo_x1024
zdat_y0        = med_Eo_y_128
zdat_y1        = med_Eo_y_512
zdat_y2        = med_Eo_y1024
zdat_z0        = med_Eo_z_128
zdat_z1        = med_Eo_z_512
zdat_z2        = med_Eo_z1024


se             = [20000L,50000L]
yran           = [-2d2,5d1]
xran           = (vec_t[se] MOD 864d2)

WSET,3
!P.MULTI       = [0,1,3]
;;  X-filtered
PLOT,tdat,xdat_x,/NODATA,/XSTYLE,/YSTYLE,YRANGE=yran,XRANGE=xran
  OPLOT,tdat,xdat_x,COLOR=250
;  OPLOT,tdat,zdat_x0,COLOR=200,PSYM=1
  OPLOT,tdat,zdat_x1,COLOR= 30,LINESTYLE=3
  OPLOT,tdat,zdat_x2,COLOR=150,PSYM=3
;;  Y-filtered
PLOT,tdat,xdat_y,/NODATA,/XSTYLE,/YSTYLE,YRANGE=yran,XRANGE=xran
  OPLOT,tdat,xdat_y,COLOR=250
;  OPLOT,tdat,zdat_y0,COLOR=200,PSYM=1
  OPLOT,tdat,zdat_y1,COLOR= 30,LINESTYLE=3
  OPLOT,tdat,zdat_y2,COLOR=150,PSYM=3
;;  Z-filtered
PLOT,tdat,xdat_z,/NODATA,/XSTYLE,/YSTYLE,YRANGE=yran,XRANGE=xran
  OPLOT,tdat,xdat_z,COLOR=250
;  OPLOT,tdat,zdat_z0,COLOR=200,PSYM=1
  OPLOT,tdat,zdat_z1,COLOR= 30,LINESTYLE=3
  OPLOT,tdat,zdat_z2,COLOR=150,PSYM=3
!P.MULTI       = 0



;;----------------------------------------------------------------------------------------
;;  Get data and test zero-crossing routine
;;----------------------------------------------------------------------------------------
wi,1
wi,2
wi,3

;;  Get Eo [original] - (Spinfit Model) data
get_data,efp_rmspftDC_n[0],DATA=efp_rmspftDC,DLIM=dlim_efp_rmsfDC,LIM=lim_efp_rmsfDC
;;  Define parameters
vec_t          = efp_rmspftDC.X
vec_v          = efp_rmspftDC.Y

.compile /Users/lbwilson/Desktop/temp_idl/temp_zero_crossings.pro


xyz_thr        = 5d0*[1d0,2d0/5d0,1d0/5d0]
zeros_x        = temp_zero_crossings(vec_t,vec_v[*,0],THRESH_VAL=xyz_thr[0],KNOWN_AVG=0d0,THR_MERGE=4)
zeros_y        = temp_zero_crossings(vec_t,vec_v[*,1],THRESH_VAL=xyz_thr[1],KNOWN_AVG=0d0)
zeros_z        = temp_zero_crossings(vec_t,vec_v[*,2],THRESH_VAL=xyz_thr[2],KNOWN_AVG=0d0)

zarr           = zeros_x.ZERO_ARRAY
zind           = zeros_x.SE_ZC_INDEX
;;  Check results
se             = [30000L,33000L]
yran           = [-2d2,1d1]
xran           = (vec_t[se] MOD 864d2)
xdat           = vec_t MOD 864d2
ydats          = vec_v
zdats_t        = vec_t[REFORM(zind[*,0])] MOD 864d2
zdats_v        = vec_v[REFORM(zind[*,0]),*]
zdate_t        = vec_t[REFORM(zind[*,1])] MOD 864d2
zdate_v        = vec_v[REFORM(zind[*,1]),*]

WSET,1
PLOT,xdat,ydats[*,0],/NODATA,/XSTYLE,/YSTYLE,YRANGE=yran,XRANGE=xran
  OPLOT,xdat,ydats[*,0],COLOR=250
  OPLOT,zdats_t,zdats_v[*,0],COLOR=200,PSYM=4
  OPLOT,zdate_t,zdate_v[*,0],COLOR= 30,PSYM=2

  OPLOT,xdat,ABS(ydats[*,0]),COLOR=250


xdat           = vec_t MOD 864d2
;;  1st derivative [df/dt = f'(t)]
dydx_x         = DERIV(xdat,vec_v[*,0])
dydx_y         = DERIV(xdat,vec_v[*,1])
dydx_z         = DERIV(xdat,vec_v[*,2])
;;  2nd derivative [f"(t)]
d2ydx2_x       = DERIV(xdat,dydx_x)
d2ydx2_y       = DERIV(xdat,dydx_y)
d2ydx2_z       = DERIV(xdat,dydx_z)
;;  Avg. of 1st and 2nd derivatives
avg__x         = MEAN(ABS(dydx_x),/NAN)
avg__y         = MEAN(ABS(dydx_y),/NAN)
avg__z         = MEAN(ABS(dydx_z),/NAN)
avg__x2        = MEAN(ABS(d2ydx2_x),/NAN)
avg__y2        = MEAN(ABS(d2ydx2_y),/NAN)
avg__z2        = MEAN(ABS(d2ydx2_z),/NAN)

WSET,2
!P.MULTI       = [0,1,2]
;;  1st derivative
PLOT,xdat,ABS(dydx_x),/NODATA,/XSTYLE,/YSTYLE,/YLOG,XRANGE=xran,YMINOR=9
  OPLOT,xdat,ABS(dydx_x)
  OPLOT,xran,[avg__x[0],avg__x[0]],LINESTYLE=2,COLOR=250
  OPLOT,zdats_t,ABS(zdats_v[*,0]),COLOR=200,PSYM=4
  OPLOT,zdate_t,ABS(zdate_v[*,0]),COLOR= 30,PSYM=2
;;  2nd derivative
PLOT,xdat,ABS(d2ydx2_x),/NODATA,/XSTYLE,/YSTYLE,/YLOG,XRANGE=xran,YMINOR=9
  OPLOT,xdat,ABS(d2ydx2_x)
  OPLOT,xran,[avg__x2[0],avg__x2[0]],LINESTYLE=2,COLOR=250
  OPLOT,zdats_t,ABS(zdats_v[*,0]),COLOR=200,PSYM=4
  OPLOT,zdate_t,ABS(zdate_v[*,0]),COLOR= 30,PSYM=2
!P.MULTI       = 0



xdat           = vec_t MOD 864d2
;;  1st derivative [d|f|/dt = |f|'(t)]
abs_dydx_x     = DERIV(xdat,ABS(vec_v[*,0]))
abs_dydx_y     = DERIV(xdat,ABS(vec_v[*,1]))
abs_dydx_z     = DERIV(xdat,ABS(vec_v[*,2]))
;;  2nd derivative [|f|"(t)]
abs_d2ydx2_x   = DERIV(xdat,DERIV(xdat,ABS(vec_v[*,0])))
abs_d2ydx2_y   = DERIV(xdat,DERIV(xdat,ABS(vec_v[*,1])))
abs_d2ydx2_z   = DERIV(xdat,DERIV(xdat,ABS(vec_v[*,2])))
;;  Avg. of 1st and 2nd derivatives
abs_avg__x     = MEAN(ABS(abs_dydx_x),/NAN)
abs_avg__y     = MEAN(ABS(abs_dydx_y),/NAN)
abs_avg__z     = MEAN(ABS(abs_dydx_z),/NAN)
abs_avg__x2    = MEAN(ABS(abs_d2ydx2_x),/NAN)
abs_avg__y2    = MEAN(ABS(abs_d2ydx2_y),/NAN)
abs_avg__z2    = MEAN(ABS(abs_d2ydx2_z),/NAN)


WSET,3
PLOT,xdat,ABS(abs_dydx_x),/NODATA,/XSTYLE,/YSTYLE,/YLOG,XRANGE=xran,YMINOR=9
  OPLOT,xdat,ABS(abs_dydx_x)
  OPLOT,xran,[abs_avg__x[0],abs_avg__x[0]],LINESTYLE=2,COLOR=250



;;  Try to straighten spikes by treating them as a sawtooth wave
test4          = sawtooth_to_straight(ydats[*,0],TOLERANCE=10d0)
d_dt4          = DERIV(xdat,test4)
avg_d_dt4      = MEAN(d_dt4,/NAN)
std_d_dt4      = STDDEV(d_dt4,/NAN)
med_d_dt4      = MEDIAN(d_dt4)
med_d_dt4_128  = MEDIAN(d_dt4,128L)  ;;  128 bin median filter


fac            = 1d-3
thr            = -30d0
range          = avg_d_dt4[0] + [-1d0,1d0]*std_d_dt4[0]*fac[0]
test0          = (d_dt4 LT range[0]) OR (d_dt4 GT range[1])
test1          = (ydats[*,0] LT thr[0])
test           = (test0 OR test1)
bad            = WHERE(test,bd)
PRINT,';;',bd
;;        7540

new_d_dt4      = d_dt4
new_d_dt4[bad] = d

PLOT,new_d_dt4




















;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------



;;----------------------------------------------------------------------------------------
;;  Calculate spin fit of altered data
;;----------------------------------------------------------------------------------------
;;  Get spin phase and period
get_data,sp_per_tpnm[0],DATA=temp_sp_per,DLIM=dlim_sp_per,LIM=lim_sp_per
get_data,sp_phs_tpnm[0],DATA=temp_sp_phs,DLIM=dlim_sp_phs,LIM=lim_sp_phs
;;  Get Eo data [DSL]
get_data,efpdpkrEcDCdsl[0],DATA=temp_Eornodc,DLIM=dlim_Eornodc,LIM=lim_Eornodc
;;  Get sunpulse data
get_data,sunpulse_nm[0],DATA=thx_sunpulse_times,DLIM=dlim_sunpulse_times,LIM=lim_sunpulse_times
;;  Get spin phase model values interpolated for efp times
get_data,spphs_int_tpnm[0],DATA=spphs_int,DLIM=dlim_sp_phs,LIM=lim_sp_phs

;;  Define parameters
vec_t          = temp_Eornodc.X
vec_v          = temp_Eornodc.Y
sp_per_t       = temp_sp_per.X
sp_per_v       = temp_sp_per.Y
sp_phs_t       = temp_sp_phs.X
sp_phs_v       = temp_sp_phs.Y
sunp_t         = thx_sunpulse_times.X
sunp_v         = thx_sunpulse_times.Y
sphase_t       = spphs_int.X
sphase_v       = spphs_int.Y
sphase_vr      = sphase_v*!DPI/18d1

;;  First clean up de-spiked efp, without E_conv and DC-offsets
;;  Use a cubic spline to interpolate NaNs
t_efpvx        = remove_nans(vec_t,vec_v[*,0],/NO_EXTRAPOLATE,/SPLINE)
t_efpvy        = remove_nans(vec_t,vec_v[*,1],/NO_EXTRAPOLATE,/SPLINE)
t_efpvz        = remove_nans(vec_t,vec_v[*,2],/NO_EXTRAPOLATE,/SPLINE)
t_efpv         = [[t_efpvx],[t_efpvy],[t_efpvz]]
vec_v          = t_efpv

;;--------------------------------
;;  Find X-Axis fit
;;--------------------------------
plane_dim      = 0
axis_dim       = 0
sun2sensor     = 0d0
spinfit,$
          vec_t[gind],vec_v[gind,*],sunp_t,sunp_v,     $         ;;  Input
          a,b,c,spin_axis,med_axis,sig,npts,sun_data,  $         ;;  Output
          MIN_POINTS=min_points,ALPHA=alpha,BETA=beta, $
          PLANE_DIM=plane_dim,AXIS_DIM=axis_dim,PHASE_MASK_STARTS=phase_mask_starts,$
          PHASE_MASK_ENDS=phase_mask_ends,SUN2SENSOR=sun2sensor
;;  Redefine parameters
a_x            = a
b_x            = b
c_x            = c
sig_x          = sig
npt_x          = npts
t_x_fit        = sun_data
;;  Clean up
DELVAR,a,b,c,spin_axis,med_axis,sig,npts,sun_data

;;--------------------------------
;;  Find Y-Axis fit
;;--------------------------------
plane_dim      = 1
axis_dim       = 1
sun2sensor     = 0d0
spinfit,$
          vec_t[gind],vec_v[gind,*],sunp_t,sunp_v,     $         ;;  Input
          a,b,c,spin_axis,med_axis,sig,npts,sun_data,  $         ;;  Output
          MIN_POINTS=min_points,ALPHA=alpha,BETA=beta, $
          PLANE_DIM=plane_dim,AXIS_DIM=axis_dim,PHASE_MASK_STARTS=phase_mask_starts,$
          PHASE_MASK_ENDS=phase_mask_ends,SUN2SENSOR=sun2sensor
;;  Redefine parameters
a_y            = a
b_y            = b
c_y            = c
sig_y          = sig
npt_y          = npts
t_y_fit        = sun_data
;;  Clean up
DELVAR,a,b,c,spin_axis,med_axis,sig,npts,sun_data

;;--------------------------------
;;  Find Z-Axis fit
;;--------------------------------
plane_dim      = 2
axis_dim       = 2
sun2sensor     = 0d0
spinfit,$
          vec_t[gind],vec_v[gind,*],sunp_t,sunp_v,     $         ;;  Input
          a,b,c,spin_axis,med_axis,sig,npts,sun_data,  $         ;;  Output
          MIN_POINTS=min_points,ALPHA=alpha,BETA=beta, $
          PLANE_DIM=plane_dim,AXIS_DIM=axis_dim,PHASE_MASK_STARTS=phase_mask_starts,$
          PHASE_MASK_ENDS=phase_mask_ends,SUN2SENSOR=sun2sensor
;;  Redefine parameters
a_z            = a
b_z            = b
c_z            = c
sig_z          = sig
npt_z          = npts
t_z_fit        = sun_data
;;  Clean up
DELVAR,a,b,c,spin_axis,med_axis,sig,npts,sun_data

;;--------------------------------
;;  Send to TPLOT
;;--------------------------------
fit_tpns       = ['a','b','c','sig','npts']
boomfit        = ['x','y','z']
temp_tpn       = 'test_spinfit_efp_'+boomfit+'_'
ysubt          = '[Spinfit to efp, E'+boomfit+']'

lim__fits      = lim_Eornodc
dlim_fits      = dlim_Eornodc
str_element,lim__fits,'LABELS',/DELETE
str_element,dlim_fits,'LABELS',/DELETE
str_element,dlim_fits,'COLORS',50,/ADD_REPLACE
;;  X-Fits
store_data,temp_tpn[0]+fit_tpns[0],   DATA={X:t_x_fit,  Y:a_x},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[0]+fit_tpns[1],   DATA={X:t_x_fit,  Y:b_x},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[0]+fit_tpns[2],   DATA={X:t_x_fit,  Y:c_x},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[0]+fit_tpns[3],   DATA={X:t_x_fit,Y:sig_x},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[0]+fit_tpns[4],   DATA={X:t_x_fit,Y:npt_x},DLIM=dlim_fits,LIM=lim__fits
options,   temp_tpn[0]+fit_tpns[0],'YSUBTITLE',ysubt[0]
options,   temp_tpn[0]+fit_tpns[1],'YSUBTITLE',ysubt[0]
options,   temp_tpn[0]+fit_tpns[2],'YSUBTITLE',ysubt[0]
options,   temp_tpn[0]+fit_tpns[3],'YSUBTITLE',ysubt[0]
options,   temp_tpn[0]+fit_tpns[4],'YSUBTITLE',ysubt[0]
;;  Y-Fits
store_data,temp_tpn[1]+fit_tpns[0],   DATA={X:t_y_fit,  Y:a_y},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[1]+fit_tpns[1],   DATA={X:t_y_fit,  Y:b_y},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[1]+fit_tpns[2],   DATA={X:t_y_fit,  Y:c_y},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[1]+fit_tpns[3],   DATA={X:t_y_fit,Y:sig_y},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[1]+fit_tpns[4],   DATA={X:t_y_fit,Y:npt_y},DLIM=dlim_fits,LIM=lim__fits
options,   temp_tpn[1]+fit_tpns[0],'YSUBTITLE',ysubt[1]
options,   temp_tpn[1]+fit_tpns[1],'YSUBTITLE',ysubt[1]
options,   temp_tpn[1]+fit_tpns[2],'YSUBTITLE',ysubt[1]
options,   temp_tpn[1]+fit_tpns[3],'YSUBTITLE',ysubt[1]
options,   temp_tpn[1]+fit_tpns[4],'YSUBTITLE',ysubt[1]
;;  Z-Fits
store_data,temp_tpn[2]+fit_tpns[0],   DATA={X:t_z_fit,  Y:a_z},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[2]+fit_tpns[1],   DATA={X:t_z_fit,  Y:b_z},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[2]+fit_tpns[2],   DATA={X:t_z_fit,  Y:c_z},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[2]+fit_tpns[3],   DATA={X:t_z_fit,Y:sig_z},DLIM=dlim_fits,LIM=lim__fits
store_data,temp_tpn[2]+fit_tpns[4],   DATA={X:t_z_fit,Y:npt_z},DLIM=dlim_fits,LIM=lim__fits
options,   temp_tpn[2]+fit_tpns[0],'YSUBTITLE',ysubt[2]
options,   temp_tpn[2]+fit_tpns[1],'YSUBTITLE',ysubt[2]
options,   temp_tpn[2]+fit_tpns[2],'YSUBTITLE',ysubt[2]
options,   temp_tpn[2]+fit_tpns[3],'YSUBTITLE',ysubt[2]
options,   temp_tpn[2]+fit_tpns[4],'YSUBTITLE',ysubt[2]
;;  Fix Y-Axis title for both
options,tnames(temp_tpn[*]+fit_tpns[0]),'YTITLE','Spinfit Param. '+fit_tpns[0]
options,tnames(temp_tpn[*]+fit_tpns[1]),'YTITLE','Spinfit Param. '+fit_tpns[1]
options,tnames(temp_tpn[*]+fit_tpns[2]),'YTITLE','Spinfit Param. '+fit_tpns[2]
options,tnames(temp_tpn[*]+fit_tpns[3]),'YTITLE','Spinfit Param. '+fit_tpns[3]
options,tnames(temp_tpn[*]+fit_tpns[4]),'YTITLE','Spinfit Param. '+fit_tpns[4]


traz           = t_ramp0[0] + [-1d0,1d0]*165d0  ;;  330 s window centered on ramp
;traz           = t_ramp0[0] + [-1d0,1d0]*115d0  ;;  230 s window centered on ramp
;;  Plot X-Fits
nna            = [fgh_mag_dsl,efpdpkrEcDCdsl[0],temp_tpn[0]+'*']
  tplot,nna,TRANGE=traz
;;  Plot Y-Fits
nna            = [fgh_mag_dsl,efpdpkrEcDCdsl[0],temp_tpn[1]+'*']
  tplot,nna,TRANGE=traz
;;  Plot Z-Fits
nna            = [fgh_mag_dsl,efpdpkrEcDCdsl[0],temp_tpn[2]+'*']
  tplot,nna,TRANGE=traz
;;----------------------------------------------------------------------------------------
;;  Reconstruct E-field components
;;----------------------------------------------------------------------------------------
wi,1

;;  I am not sure why, but the spin phase (from model) needs to be shifted by -200 degrees...?
phase_off_x    = 36d1 - (135d0 + 25d0)
;phase_off_x    = 36d1 - (135d0 - 12.12d0)
smpts          = 10L      ;;  # of points to smooth
;;  Define parameters
vec_t          = temp_Eornodc.X
vec_v          = temp_Eornodc.Y
sphase_t       = spphs_int.X
sphase_v       = spphs_int.Y
sphase_vr      = (sphase_v - phase_off_x[0])*!DPI/18d1
;sphase_vr      = (sphase_v - 180d0 - 25d0)*!DPI/18d1
;sphase_vr      = sphase_v*!DPI/18d1
;sphase_vr      = (sphase_v + 180d0)*!DPI/18d1
;;  Use only time stamps near shock
up_t           = vec_t[gind]
;;  Reconstruct Eo_x
a_x_up         = interp(SMOOTH(a_x,smpts[0],/NAN,/EDGE_TRUNCATE),t_x_fit,up_t,/NO_EXTRAPOLATE)
b_x_up         = interp(SMOOTH(b_x,smpts[0],/NAN,/EDGE_TRUNCATE),t_x_fit,up_t,/NO_EXTRAPOLATE)
c_x_up         = interp(SMOOTH(c_x,smpts[0],/NAN,/EDGE_TRUNCATE),t_x_fit,up_t,/NO_EXTRAPOLATE)
Eo_x_fit       = a_x_up + b_x_up*COS(sphase_vr) + c_x_up*SIN(sphase_vr)
;;  Reconstruct Eo_y
a_y_up         = interp(SMOOTH(a_y,smpts[0],/NAN,/EDGE_TRUNCATE),t_y_fit,up_t,/NO_EXTRAPOLATE)
b_y_up         = interp(SMOOTH(b_y,smpts[0],/NAN,/EDGE_TRUNCATE),t_y_fit,up_t,/NO_EXTRAPOLATE)
c_y_up         = interp(SMOOTH(c_y,smpts[0],/NAN,/EDGE_TRUNCATE),t_y_fit,up_t,/NO_EXTRAPOLATE)
Eo_y_fit       = a_y_up + b_y_up*COS(sphase_vr) + c_y_up*SIN(sphase_vr)
;;  Reconstruct Eo_z
a_z_up         = interp(SMOOTH(a_z,smpts[0],/NAN,/EDGE_TRUNCATE),t_z_fit,up_t,/NO_EXTRAPOLATE)
b_z_up         = interp(SMOOTH(b_z,smpts[0],/NAN,/EDGE_TRUNCATE),t_z_fit,up_t,/NO_EXTRAPOLATE)
c_z_up         = interp(SMOOTH(c_z,smpts[0],/NAN,/EDGE_TRUNCATE),t_z_fit,up_t,/NO_EXTRAPOLATE)
Eo_z_fit       = a_z_up + b_z_up*COS(sphase_vr) + c_z_up*SIN(sphase_vr)



up_t_sod       = up_t MOD 864d2
;mnmx           = [0L,10000L]
mnmx           = [1000L,10000L]
mnmz           = [60000L,70000L]
;;  Plot X-Fits
WSET,1
PLOT,up_t_sod,Eo_x_fit,/NODATA,/XSTYLE,/YSTYLE,XRANGE=up_t_sod[mnmx]
  OPLOT,up_t_sod,Eo_x_fit,COLOR=250
  OPLOT,up_t_sod,vec_v[gind,0],COLOR= 50,PSYM=3
;;  Plot Y-Fits
WSET,1
PLOT,up_t_sod,Eo_y_fit,/NODATA,/XSTYLE,/YSTYLE,XRANGE=up_t_sod[mnmx]
  OPLOT,up_t_sod,Eo_y_fit,COLOR=250
  OPLOT,up_t_sod,vec_v[gind,1],COLOR= 50,PSYM=3
;;  Plot Z-Fits
WSET,1
PLOT,up_t_sod,Eo_z_fit,/NODATA,/XSTYLE,/YSTYLE,XRANGE=up_t_sod[mnmz]
  OPLOT,up_t_sod,Eo_z_fit,COLOR=250
  OPLOT,up_t_sod,vec_v[gind,2],COLOR= 50,PSYM=3

;;----------------------------------------------------------------------------------------
;;  Send reconstruct E-field to TPLOT
;;----------------------------------------------------------------------------------------
;;  Define Eo Spinfit Model data [DSL]
Eo_fit_v       = [[Eo_x_fit],[Eo_y_fit],[Eo_z_fit]]
;;  Get Eo data [DSL]
get_data,efpdpkrEcDCdsl[0],DATA=temp_Eornodc,DLIM=dlim_Eornodc,LIM=lim_Eornodc
;;  Define parameters
vec_t          = temp_Eornodc.X
vec_v          = temp_Eornodc.Y
gd_tp_t        = vec_t[gind]
gd_tp_v        = vec_v[gind,*]

;;  Define TPLOT parameters
efp_spinfitmod = '_cal_despiked_rmEconv_rmDC_spinfit_model_'
spinfit_mod_nm = 'Spinfit Model'
efpdspkrEcdcsf = pref[0]+modes_efi[0]+efp_spinfitmod[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E [efp, '+coord_up[0]+', mV/m]'+'!C'+'['+spinfit_mod_nm[0]+']'
str_element,dlim_Eornodc,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:gd_tp_t,Y:Eo_fit_v}
store_data,efpdspkrEcdcsf[0],DATA=struct,DLIM=dlim_Eornodc,LIM=lim_Eornodc
;;----------------------------------------------------------------------------------------
;;  Send difference to TPLOT
;;----------------------------------------------------------------------------------------
efp_rmspfitmod = '_cal_despiked_rmEconv_rmDC_rmspinfitmodel_'
rmspfit_mod_nm = 'Rm: Spinfit Model'
efp_rmspft_dsl = pref[0]+modes_efi[0]+efp_rmspfitmod[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E [efp, '+coord_up[0]+', mV/m]'+'!C'+'['+rmspfit_mod_nm[0]+']'
str_element,dlim_Eornodc,'YTITLE',yttl[0],/ADD_REPLACE
diff_Eo        = gd_tp_v - Eo_fit_v
struct         = {X:gd_tp_t,Y:diff_Eo}
store_data,efp_rmspft_dsl[0],DATA=struct,DLIM=dlim_Eornodc,LIM=lim_Eornodc

;;  Plot Spinfit Model with actual data
nna            = [fgh_mag_dsl,efpdpkrEcDCdsl[0],efpdspkrEcdcsf[0],efp_rmspft_dsl[0]]
WSET,0
  tplot,nna,TRANGE=traz

;;----------------------------------------------------------------------------------------
;;  Remove "spikes"
;;----------------------------------------------------------------------------------------
;;  Get Eo [removed spinfit] data [DSL]
get_data,efp_rmspft_dsl[0],DATA=temp_Eornodcspft,DLIM=dlim_Eornodcspft,LIM=lim_Eornodcspft
;;  Define parameters
vec_t          = temp_Eornodcspft.X
vec_v          = temp_Eornodcspft.Y
;;  Define Eo Spinfit Model data [DSL]
Eo_fit_v       = [[Eo_x_fit],[Eo_y_fit],[Eo_z_fit]]
;;  Define indices
spft_ind       = LINDGEN(N_ELEMENTS(Eo_fit_v[*,0]))

;;  Calculate derivative
t_efpvx        = DERIV(vec_t,vec_v[*,0])
t_efpvy        = DERIV(vec_t,vec_v[*,1])
t_efpvz        = DERIV(vec_t,vec_v[*,2])
dEdt_efpv      = [[t_efpvx],[t_efpvy],[t_efpvz]]

;;  Plot derivatives
WSET,1
;yfac           = 35d2
;yfac           = 10d2
yfac           = 1d2
;xran           = [10000L,50000L]
xran           = [32000L,45000L]
yran           = [-1d0,1d0]*yfac[0]
PLOT,t_efpvx,/NODATA,/XSTYLE,/YSTYLE,XRANGE=xran,YRANGE=yran
  OPLOT,t_efpvx,COLOR=250
  OPLOT,t_efpvy,COLOR=150
;  OPLOT,t_efpvz,COLOR= 50

;;  Define thresholds to test for spikes
thsh_noDC      = 25d0
thsh_noDC__x   = -10d0
thsh_dEdt_xy   = 25d0
thsh_dEdt__z   = 4d2
ramp_z_inds    = [32000L,41000L]
test_dEdt_xy   = (ABS(dEdt_efpv[*,0]) GE thsh_dEdt_xy[0])  OR $
                 (ABS(dEdt_efpv[*,1]) GE thsh_dEdt_xy[0])
test_dEdt__z   = (ABS(dEdt_efpv[*,2]) GE thsh_dEdt__z[0]) AND $
                 ((spft_ind LE ramp_z_inds[0]) OR (spft_ind GE ramp_z_inds[1]))
test_noDC      = (ABS(vec_v[*,0]) GE thsh_noDC[0]) OR $
                 (ABS(vec_v[*,1]) GE thsh_noDC[0])
test_noDC__x   = (vec_v[*,0] LE thsh_noDC__x[0])
;test           = (thsh_dEdt_xy OR test_noDC) OR (thsh_dEdt__z OR test_noDC)
test           = test_dEdt_xy OR test_dEdt__z OR test_noDC OR test_noDC__x
bad_spft       = WHERE(test,bd_spft,COMPLEMENT=good_spft,NCOMPLEMENT=gd_spft)
PRINT, ';;  ', bd_spft, gd_spft
;;          9749       67051

;;  Clean upstream X-component
thsh_noDCu__x  = -5d0
test_noDCu__x  = (vec_v[*,0] LE thsh_noDCu__x[0]) AND (spft_ind GE ramp_z_inds[1])
bad_spft_ux    = WHERE(test_noDCu__x,bd_spft_ux,COMPLEMENT=good_spft_ux,NCOMPLEMENT=gd_spft_ux)
PRINT, ';;  ', bd_spft_ux, gd_spft_ux
;;          1667       75133

;;  Set "bad" regions to NaNs
dspk_Eo_fit_v  = vec_v
IF (   bd_spft GT 0) THEN dspk_Eo_fit_v[bad_spft,*] = d
IF (bd_spft_ux GT 0) THEN dspk_Eo_fit_v[bad_spft_ux,*] = d

;;  Smooth to fill NaNs
;smpts          = 30L      ;;  # of points to smooth
;t_efpvx        = SMOOTH(dspk_Eo_fit_v[*,0],smpts[0],/NAN,/EDGE_TRUNCATE)
;t_efpvy        = SMOOTH(dspk_Eo_fit_v[*,1],smpts[0],/NAN,/EDGE_TRUNCATE)
;t_efpvz        = SMOOTH(dspk_Eo_fit_v[*,2],smpts[0],/NAN,/EDGE_TRUNCATE)
;dspk_Eo_fit_v  = [[t_efpvx],[t_efpvy],[t_efpvz]]

;;  Send de-spiked data to TPLOT
efprmspftdspk0 = '_cal_despiked_rmEconv_rmDC_rmspinfitmodel_despiked_'
rmspft_dspk_nm = 'Rm: Spinfit Model'+'!C'+'--> despiked'
efp_rmspftdspk = pref[0]+modes_efi[0]+efprmspftdspk0[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E [efp, '+coord_up[0]+', mV/m]'+'!C'+'['+rmspft_dspk_nm[0]+']'
str_element,dlim_Eornodcspft,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:vec_t,Y:dspk_Eo_fit_v}
store_data,efp_rmspftdspk[0],DATA=struct,DLIM=dlim_Eornodcspft,LIM=lim_Eornodcspft


;;  Remove "spikes" and edge-effects by hand
nna            = [efp_rmspftdspk[0]]
kill_data_tr,NAMES=nna



;;  Plot Spinfit Model with actual data and "corrected" data
nna            = [fgh_mag_dsl,efp_dsl_orig[0],efpdpkrEcDCdsl[0],efpdspkrEcdcsf[0],efp_rmspft_dsl[0],efp_rmspftdspk[0]]
WSET,0
  tplot,nna,TRANGE=traz


;;----------------------------------------------------------------------------------------
;;  Save plot
;;----------------------------------------------------------------------------------------
fgm_mode       = 0L      ;;  fgs
fgm_mode       = 1L      ;;  fgl
fgm_mode       = 2L      ;;  fgh
fgm_tpn_str    = {T0:fgs_mag_dsl,T1:fgl_mag_dsl,T2:fgh_mag_dsl}

tra            = t_ramp0[0] + [-1d0,1d0]*165d0  ;; 330 s window centered on ramp
tlimit,tra
traz           = t_get_current_trange()
coord          = coord_dsl[0]
all_efi_tpnm   = [efp_dsl_orig[0],efpdpkrEcDCdsl[0],efpdspkrEcdcsf[0],efp_rmspft_dsl[0],efp_rmspftdspk[0]]

;;  Setup options for better looking output
fgm_mag_yra    = [0d0,50d0]
magf__yra      = [-1d0,1d0]*5d1
efi_yra0       = [-1d0,1d0]*57d1
efi_yran       = [-1d0,1d0]*45d0
efi_ytv        = [-4d1,-3d1,-2d1,-1d1,0d0,1d1,2d1,3d1,4d1]
efi_ytn        = STRTRIM(STRING(efi_ytv,FORMAT='(I)'),2L)
efi_yts        = N_ELEMENTS(efi_ytn) - 1L
efi_ymn        = 5L

options,   fgl_mag_dsl[*],'YRANGE'                ;;  Remove any YRANGE present in LIMITS structure
options,   fgh_mag_dsl[*],'YRANGE'                ;;  Remove any YRANGE present in LIMITS structure
options,  all_efi_tpnm[*],'YRANGE'                ;;  Remove any YRANGE present in LIMITS structure
options,  all_efi_tpnm[*],'YTICKV'                ;;  Remove any YTICKV present in LIMITS structure
options,  all_efi_tpnm[*],'YTICKS'                ;;  Remove any YTICKS present in LIMITS structure
options,  all_efi_tpnm[*],'YTICKNAME'             ;;  Remove any YTICKNAME present in LIMITS structure
options,  all_efi_tpnm[*],'YMINOR'                ;;  Remove any YMINOR present in LIMITS structure

options,all_efi_tpnm[1:4],   'YRANGE',efi_yran,/DEF
options,all_efi_tpnm[1:4],   'YTICKV', efi_ytv,/DEF
options,all_efi_tpnm[1:4],   'YTICKS', efi_yts,/DEF
options,all_efi_tpnm[1:4],'YTICKNAME', efi_ytn,/DEF
options,all_efi_tpnm[1:4],   'YMINOR', efi_ymn,/DEF
options,  all_efi_tpnm[0],   'YRANGE',efi_yra0,/DEF
options,   fgl_mag_dsl[0],   'YRANGE',magf__yra,/DEF
options,   fgh_mag_dsl[0],   'YRANGE',magf__yra,/DEF
;options,   fgl_mag_dsl[0],   'YRANGE',fgm_mag_yra,/DEF
;options,   fgh_mag_dsl[0],   'YRANGE',fgm_mag_yra,/DEF
options,   fgl_mag_dsl[1],   'YRANGE',magf__yra,/DEF
options,   fgh_mag_dsl[1],   'YRANGE',magf__yra,/DEF

;;  Define file name prefix
;f_pref         = prefu[0]+mode_fgm[fgm_mode[0]]+'-mag-'+coord[0]
f_pref         = prefu[0]+mode_fgm[fgm_mode[0]]+'-mag-2ndYra-'+coord[0]
f_pref         = f_pref[0]+'_efp-plots-'+coord[0]+'_1-cal_2-despike-rmEswDC_'
f_pref         = f_pref[0]+'3-spinfit-model_4-plot2-spinfit_5-plot4-despiked_'
all_fgm_tpnm   = fgm_tpn_str.(fgm_mode[0])
nna            = [all_fgm_tpnm,all_efi_tpnm]

WSET,0
  tplot,nna,TRANGE=traz

;;  Define file name
traz           = t_get_current_trange()
fnm_tra        = file_name_times(traz,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
fnames         = f_pref[0]+ftime[0]
PRINT, fnames[0]

popen,fnames[0],/PORT
  tplot,nna,TRANGE=traz
pclose
  tplot,/NOM









;;----------------------------------------------------------------------------------------
;;  Check
;;----------------------------------------------------------------------------------------
options,   fgl_mag_dsl[*],'YRANGE'
options,   fgh_mag_dsl[*],'YRANGE'
options,  all_efi_tpnm[*],'YRANGE'
options,  all_efi_tpnm[*],'YTICKV'
options,  all_efi_tpnm[*],'YTICKS'
options,  all_efi_tpnm[*],'YTICKNAME'
options,  all_efi_tpnm[*],'YMINOR'
options,   fgl_mag_dsl[*],'YRANGE',/DEF
options,   fgh_mag_dsl[*],'YRANGE',/DEF
options,  all_efi_tpnm[*],'YRANGE',/DEF
options,  all_efi_tpnm[*],'YTICKV',/DEF
options,  all_efi_tpnm[*],'YTICKS',/DEF
options,  all_efi_tpnm[*],'YTICKNAME',/DEF
options,  all_efi_tpnm[*],'YMINOR',/DEF


ramp_z_inds    = [32000L,41000L]
;;  Get original Eo data [DSL]
get_data,efp_dsl_orig[0],DATA=temp_efp_orig,DLIM=dlim_efp_orig,LIM=lim_efp_orig
;;  Get original Eo, without DC-offsets, data [DSL]
get_data,efp_nodc_dsl[0],DATA=temp_efp_nodc,DLIM=dlim_efp_nodc,LIM=lim_efp_nodc
;;  Define Eo Spinfit Model data [DSL]
Eo_fit_v       = [[Eo_x_fit],[Eo_y_fit],[Eo_z_fit]]

;;  Only use indices near shock
a_ind          = LINDGEN(N_ELEMENTS(temp_efp_orig.X))
gind           = LONG(a_ind[se_pels[2,0]:se_pels[2,1]])
ng             = N_ELEMENTS(gind)
;;  Define parameters
vec_t          = temp_efp_orig.X[gind]
vec_v          = temp_efp_orig.Y[gind,*]
;;  Define upstream averages
se             = [ramp_z_inds[1],(N_ELEMENTS(gind) - 1L)]
avgx           = -6d0  ;;  "by eye"
avgy           = MEAN(vec_v[se[0]:se[1],1],/NAN)
avgz           = MEAN(vec_v[se[0]:se[1],2],/NAN)
PRINT, ';;  ', avgx, avgy, avgz
;;        -6.0000000       1.0572770      -34.232532

;;  Subtract Spinfit Model from original Eo data [DSL]
diff_Eorig_mod = vec_v - Eo_fit_v
;;  Subtract upstream DC-offsets
d_Eomoddc      = diff_Eorig_mod
avgs           = [avgx[0], avgy[0], avgz[0]]
FOR k=0L, 2L DO d_Eomoddc[*,k] -= avgs[k]
;;  Send result to TPLOT
efp_rmspftDC_n = '_cal_rmspftmod_rm-upDCoff_'
efp_rmspftDC   = pref[0]+modes_efi[0]+efp_rmspftDC_n[0]+coord_dsl[0]
store_data,efp_rmspftDC[0],DATA={X:vec_t,Y:d_Eomoddc},DLIM=dlim_efp_orig,LIM=lim_efp_orig
note           = '1) Subtracted spinfit model, 2) subtracted upstream DC-offsets'
options,efp_rmspftDC[0],'DATA_ATT.NOTE',note[0],/DEF

all_efi_tpnm   = [efp_dsl_orig[0],efpdspkrEcdcsf[0],efp_rmspftDC[0]]
nna            = [all_fgm_tpnm,all_efi_tpnm]
WSET,0
  tplot,nna,TRANGE=traz


;;  Now try detrending
want_Hz        = 60d0
give_sr        = 128d0
smpts          = LONG((give_sr[0]/want_Hz[0])*2)      ;;  # of points to smooth
nsms           = STRING(FORMAT='(I3.3)',smpts[0])
PRINT, ';;  ', smpts
;;            4

sm_efpvx       = SMOOTH(d_Eomoddc[*,0],smpts[0],/NAN,/EDGE_TRUNCATE)
sm_efpvy       = SMOOTH(d_Eomoddc[*,1],smpts[0],/NAN,/EDGE_TRUNCATE)
sm_efpvz       = SMOOTH(d_Eomoddc[*,2],smpts[0],/NAN,/EDGE_TRUNCATE)
sm_efpv        = [[sm_efpvx],[sm_efpvy],[sm_efpvz]]
;;  Subtract the smoothed field from the input field
d_Eomoddc_Esm  = d_Eomoddc - sm_efpv
;;  Send result to TPLOT
efp_rmsfDCdtrd = '_cal_rmspftmod_rm-upDCoff_detrend-'+nsms[0]+'pts_'
efp_rmsfDC_dtr = pref[0]+modes_efi[0]+efp_rmsfDCdtrd[0]+coord_dsl[0]
;store_data,efp_rmsfDC_dtr[0],DATA={X:vec_t,Y:sm_efpv},DLIM=dlim_efp_orig,LIM=lim_efp_orig
store_data,efp_rmsfDC_dtr[0],DATA={X:vec_t,Y:d_Eomoddc_Esm},DLIM=dlim_efp_orig,LIM=lim_efp_orig
note           = '1) Subtracted spinfit model, 2) subtracted upstream DC-offsets'
note           = note[0]+', 3) Subtracted smoothed Eo ['+nsms[0]+'pts]'
options,efp_rmsfDC_dtr[0],'DATA_ATT.NOTE',note[0],/DEF

all_efi_tpnm   = [efp_dsl_orig[0],efpdspkrEcdcsf[0],efp_rmspftDC[0],efp_rmsfDC_dtr[0]]
nna            = [all_fgm_tpnm,all_efi_tpnm]
WSET,0
  tplot,nna
;  tplot,nna,TRANGE=traz

;;----------------------------------------------------------------------------------------
;;  Temporary de-spiking algorithm
;;----------------------------------------------------------------------------------------
wi,1

.compile /Users/lbwilson/Desktop/temp_idl/temp_zero_crossings.pro

;xyz_thresh     = 5d-2/[MAX(ABS(d_Eomoddc[*,0]),/NAN),MAX(ABS(d_Eomoddc[*,1]),/NAN),MAX(ABS(d_Eomoddc[*,2]),/NAN)]
xyz_thresh     = 5d0*[1d0,2d0/5d0,1d0/5d0]
zeros_x        = temp_zero_crossings(vec_t,d_Eomoddc[*,0],THRESH_VAL=xyz_thresh[0],KNOWN_AVG=0d0)
zeros_y        = temp_zero_crossings(vec_t,d_Eomoddc[*,1],THRESH_VAL=xyz_thresh[1],KNOWN_AVG=0d0)
zeros_z        = temp_zero_crossings(vec_t,d_Eomoddc[*,2],THRESH_VAL=xyz_thresh[2],KNOWN_AVG=0d0)

zarr           = zeros_x.ZERO_ARRAY
;;  Check results
se             = [30000L,33000L]
yran           = [-1d2,1d1]
xran           = (vec_t[se] MOD 864d2)
xdat           = vec_t MOD 864d2
ydats          = d_Eomoddc
zdats_t        = vec_t[REFORM(zeros_x.SE_ZC_INDEX[*,0])] MOD 864d2
zdats_v        = d_Eomoddc[REFORM(zeros_x.SE_ZC_INDEX[*,0]),*]
zdate_t        = vec_t[REFORM(zeros_x.SE_ZC_INDEX[*,1])] MOD 864d2
zdate_v        = d_Eomoddc[REFORM(zeros_x.SE_ZC_INDEX[*,1]),*]

WSET,1
PLOT,xdat,ydats[*,0],/NODATA,/XSTYLE,/YSTYLE,YRANGE=yran,XRANGE=xran
  OPLOT,xdat,ydats[*,0],COLOR=250
  OPLOT,zdats_t,zdats_v[*,0],COLOR= 50,PSYM=4
  OPLOT,zdate_t,zdate_v[*,0],COLOR= 50,PSYM=5


;;----------------------------------------------------------------------------------------
;;  Save data for later
;;----------------------------------------------------------------------------------------
traz           = t_ramp0[0] + [-1d0,1d0]*165d0  ;;  330 s window centered on ramp
tlimit,traz

fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_'
fsuff          = 'efp-despiked_rmEconv-DC-despun_'
traz           = t_get_current_trange()
fnm_tra        = file_name_times(traz,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
fname          = fpref[0]+fsuff[0]+ftime[0]
PRINT, fname[0]

tplot_save,FILENAME=fname[0]




















;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------



;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
scu            = STRUPCASE(sc[0])
prefu          = STRUPCASE(pref[0])
scpref         = 'th'+sc[0]+'_'

themis_load_all_inst,DATE=date[0],PROBE=probe[0],TRANGE=time_double(tr_00)
;;----------------------------------------------------------------------------------------
;;  Correct ion bulk flow velocities
;;----------------------------------------------------------------------------------------
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
ion_mid_nm     = 'peib_velocity_'
vsw_nm_dsl     = tnames(scpref[0]+ion_mid_nm[0]+coord_dsl[0])
vsw_nm_gse     = tnames(scpref[0]+ion_mid_nm[0]+coord_gse[0])
vsw_nm_gsm     = tnames(scpref[0]+ion_mid_nm[0]+coord_gsm[0])

;;  Get TPLOT data
get_data,vsw_nm_gse[0],DATA=ti_vsw,DLIM=dlim,LIM=lim
vbulk          = ti_vsw.Y
;;  Define components of V_new
smvx           = vbulk[*,0]
smvy           = vbulk[*,1]
smvz           = vbulk[*,2]

;;  Corrected GSE velocities
bind           = [0431L,0432L,0433L,0434L,0435L,0436L,0437L,0438L,0439L,0440L,0441L,0442L,0443L,0444L,0445L,0446L,0447L,0448L,0449L,0450L,0451L,0452L,0453L,0454L,0455L,0456L,0457L,0458L,0459L,0460L,0461L,0462L,0463L,0464L,0465L,0466L,0467L,0468L,0469L,0470L,0471L,0472L]
vswx_fix_2     = [-137.9495d0,-110.2283d0,-105.3032d0,-105.9883d0, -71.2267d0,-102.2990d0,-109.5847d0, -66.4465d0, -75.5031d0, -87.8034d0,-100.6902d0, -95.5636d0, -83.2152d0, -80.4176d0, -61.3938d0,-268.7820d0,-228.2926d0,-175.1602d0,-145.4946d0, -72.1457d0,-208.7206d0,-225.9606d0, -58.1883d0,-209.6236d0,-185.5990d0,-242.4396d0,-227.9896d0,-206.2243d0,-281.9052d0,-246.9158d0,-275.3937d0,-293.4430d0,-276.7850d0,-288.7143d0,-289.0691d0,-293.1015d0,-307.5211d0,-295.7074d0,-302.7530d0,-311.4771d0,-300.4407d0,-304.2030d0]
vswy_fix_2     = [  75.6631d0, -14.8001d0,  50.6739d0,  95.4643d0,  35.3232d0,  52.1533d0,   9.4318d0,  18.5063d0,  36.7798d0,   6.7589d0, -14.2377d0,  14.5795d0,   8.9486d0,  30.5933d0, -11.2194d0, -52.9654d0, -59.7955d0, -86.4655d0,-114.5890d0, -78.5700d0,-126.2231d0, -34.1284d0,  86.0834d0, -44.8225d0, -42.6352d0, -53.9310d0, -36.0743d0, -38.2412d0,  51.1507d0, -26.6392d0,  44.2013d0,  31.3775d0,  78.9969d0,  83.1941d0,  86.6903d0,  79.7859d0,  71.0870d0,  82.1187d0,  72.7096d0,  58.5958d0,  71.0253d0,  69.0152d0]
vswz_fix_2     = [ 96.1632d0, 62.1760d0, 44.9703d0, 21.9975d0, 21.8700d0, 14.2218d0, 42.6332d0, 36.8999d0, -2.6429d0,  1.5962d0, 25.8590d0, 40.1858d0, -2.0704d0,  5.9990d0,  6.3821d0, 26.8731d0, 16.4429d0, -5.4312d0, 22.0415d0, 26.1776d0,-29.3434d0, 42.9462d0, -4.0278d0, 28.0028d0,-30.3545d0, 37.2253d0, 39.8258d0, 42.6363d0, 20.9123d0, 35.1928d0, 45.4029d0,  5.9471d0, 35.6257d0, 25.2030d0, 29.5523d0, 27.5498d0, 15.1370d0, 25.8282d0, 14.3992d0, 29.6708d0, 28.4041d0, 28.4948d0]

;; Replace "bad" values
smvx[bind]     = vswx_fix_2
smvy[bind]     = vswy_fix_2
smvz[bind]     = vswz_fix_2
smvel3         = [[smvx],[smvy],[smvz]]

;;  Send corrected GSE velocities to TPLOT
vnew_str       = {X:ti_vsw.X,Y:smvel3}                            ;;  TPLOT structure
vname_n3       = vsw_nm_gse[0]+'_fixed_3'                         ;;  TPLOT handle
yttl           = 'V!Dbulk!N [km/s, '+STRUPCASE(coord_gse[0])+']'  ;;  Y-Axis title
ysubt          = '[Shifted to DF Peak, 3s]'                       ;;  Y-Axix subtitle
str_element,dlim,'YTITLE',yttl[0],/ADD_REPLACE
str_element,dlim,'YSUBTITLE',ysubt[0],/ADD_REPLACE
store_data,vname_n3[0],DATA=vnew_str

;;  Rotate corrected GSE velocities to DSL and GSM
new_out_nms    = [vsw_nm_dsl[0],vsw_nm_gsm[0]]+'_fixed_3'
thm_cotrans,vname_n3[0],new_out_nms[0],IN_COORD=coord_gse[0],OUT_COORD=coord_dsl[0]
thm_cotrans,vname_n3[0],new_out_nms[1],IN_COORD=coord_gse[0],OUT_COORD=coord_gsm[0]

;;----------------------------------------------------------------------------------------
;;  Set defaults
;;----------------------------------------------------------------------------------------
!themis.VERBOSE = 2
tplot_options,'VERBOSE',2
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'
;;  Use default colors
all_coords     = [coord_dsl[0],coord_gse[0],coord_gsm[0]]
FOR j=0L, N_ELEMENTS(all_coords) - 1L DO BEGIN       $
  options,tnames('*_'+all_coords[j]+'*'),'COLORS'  & $
  options,tnames('*_'+all_coords[j]+'*'),'COLORS',[250,150, 50],/DEF

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='THEMIS-'+scu[0]+' Plots ['+tdate[0]+']'

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
;;----------------------------------------------------------------------------------------
;;  Fix Y-Axis subtitles
;;----------------------------------------------------------------------------------------
scpref         = 'th'+sc[0]+'_'

coord_dsl      = 'dsl'
modes_slh      = ['s','l','h']
mode_fgm       = 'fg'+modes_slh
fgm_pren       = scpref[0]+mode_fgm+'_'
fgm_mag        = tnames(fgm_pren[*]+'mag')
fgm_dsl        = tnames(fgm_pren[*]+coord_dsl[0])

tplot,fgm_mag
;;----------------------------------------------------------------------------------------
;;  Load E&B-Fields
;;----------------------------------------------------------------------------------------
mode           = 'efp efw'
coord_in       = 'dsl'
coord_out      = 'gse'
typee          = 'calibrated'
fmin_b         = 10.
fcut_b         = 10.
despinb        = 0
nk             = 256L
flow           = 0.1
no_extra       = 1
no_spec        = 1
tran_fac       = 0
poynt_flux     = 0
loadefi        = 1
loadscm        = 1
tclip_fs       = 0
tra            = time_double(tr_00)

wrapper_thm_load_efiscm,PROBE=probe,TRANGE=tra,/GET_SUPPORT,POYNT_FLUX=poynt_flux,    $
                        TRAN_FAC=tran_fac,COORD_IN=coord_in[0],DATATYPE=mode[0],      $
                        LOAD_EFI=loadefi,TYPE_E=typee[0],SE_T_EFI_OUT=se_tefi,        $
                        LOAD_SCM=loadscm,TYPE_B=typee[0],SE_T_SCM_OUT=se_tscm,NK=nk,  $
                        /EDGE_TRUN,FMIN_B=fmin_b,FCUT_B=fcut_b,                       $
                        DESPIN_B=despin_b,FLOW=flow,NO_EXTRA=no_extra,                $
                        NO_SPEC=no_spec,DIRECT_CROSS=direct,TCLIP_FIELDS=tclip_fs,    $
                        COORD_OUT=coord_out[0]
;;----------------------------------------------------------------------------------------
;;  Try removing DC-offsets from efw
;;----------------------------------------------------------------------------------------
coord_dsl      = 'dsl'
modes_efi      = 'ef'+['p','w']
modes_scm      = 'sc'+['p','w']
efi_midnm      = '_cal_'
scm_midnm      = '_cal_'
;;  EFI TPLOT handles
efp_names      = tnames(pref[0]+modes_efi[0]+efi_midnm[0]+coord_dsl[0]+'*')
efw_names      = tnames(pref[0]+modes_efi[1]+efi_midnm[0]+coord_dsl[0]+'*')
;;  SCM TPLOT handles
scp_names      = tnames(pref[0]+modes_scm[0]+scm_midnm[0]+coord_dsl[0]+'*')
scw_names      = tnames(pref[0]+modes_scm[1]+scm_midnm[0]+coord_dsl[0]+'*')

;;  Get EFI data
get_data,efp_names[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
;;  Define parameters
efp_t          = temp_efp.X
efp_v          = temp_efp.Y
;;  1st remove any DC-offsets from efw
sratefp        = DOUBLE(sample_rate(efp_t,GAP_THRESH=6d0,/AVE))
se_pels        = t_interval_find(efp_t,GAP_THRESH=4d0/sratefp[0])
pint           = N_ELEMENTS(se_pels[*,0])

;;  Smooth and then remove DC-offsets
mxpts          = 50L
efp_v_nodc     = REPLICATE(d,SIZE(efp_v,/DIMENSIONS))
FOR j=0L, pint - 1L DO BEGIN                                                           $
  st       = se_pels[j,0] + mxpts[0]                                                 & $  ;; stay away from end pts
  en       = se_pels[j,1] - mxpts[0]                                                 & $
  inds     = st[0] + LINDGEN(en[0] - st[0] + 1L)                                     & $
  t_efpvx  = SMOOTH(efp_v[inds,0],10L,/NAN,/EDGE_TRUNCATE)                           & $
  t_efpvy  = SMOOTH(efp_v[inds,1],10L,/NAN,/EDGE_TRUNCATE)                           & $
  t_efpvz  = SMOOTH(efp_v[inds,2],10L,/NAN,/EDGE_TRUNCATE)                           & $
  t_efpv   = [[t_efpvx],[t_efpvy],[t_efpvz]]                                         & $
  avgs     = [MEAN(t_efpv[*,0],/NAN),MEAN(t_efpv[*,1],/NAN),MEAN(t_efpv[*,2],/NAN)]  & $
  FOR k=0L, 2L DO efp_v_nodc[inds,k] = efp_v[inds,k] - avgs[k]


;;  Send efp without DC-offsets to TPLOT
efi_nodcnm     = '_cal_rmDCoffsets_'
rmDC_nm        = 'efp(rm DC-offsets)'
nodc_tpnm      = pref[0]+modes_efi[0]+efi_nodcnm[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E ['+rmDC_nm[0]+', '+coord_up[0]+', mV/m]'
str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:efp_t,Y:efp_v_nodc}
store_data,nodc_tpnm[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp

;;----------------------------------------------------------------------------------------
;;  Perform high and low pass filters
;;----------------------------------------------------------------------------------------
;;--------------------------------------------
;;  EFI data
;;--------------------------------------------
lowf0          = 1d-2
lowf1          = 1d1
midf           = 1d1
higf           = 1d5   ;;  Set well above Nyquist frequency
;;  Define the sample rate
srate          = sratefp[0]
;;  Define strings associated with sample rates and filters
cutf_str       = STRTRIM(STRING(lowf0[0],FORMAT='(f10.2)'),2L)
sr_str         = STRTRIM(STRING(srate[0],FORMAT='(I)'),2L)
lowf_str       = STRTRIM(STRING(lowf1[0],FORMAT='(I)'),2L)
midf_str       = STRTRIM(STRING(midf[0],FORMAT='(I)'),2L)
;;  Define dummy arrays
efp_v_lowp     = REPLICATE(d,SIZE(efp_v,/DIMENSIONS))
efp_v_higp     = REPLICATE(d,SIZE(efp_v,/DIMENSIONS))
FOR j=0L, pint - 1L DO BEGIN                                                           $
  t_efpv   = efp_v_nodc[se_pels[j,0]:se_pels[j,1],*]                                 & $
  vec_lp   = vector_bandpass(t_efpv,srate[0],lowf0[0],lowf1[0],/MIDF)                & $
  vec_hp   = vector_bandpass(t_efpv,srate[0],midf[0],higf[0],/MIDF)                  & $
  efp_v_lowp[se_pels[j,0]:se_pels[j,1],*] = vec_lp                                   & $
  efp_v_higp[se_pels[j,0]:se_pels[j,1],*] = vec_hp

;;  Define TPLOT handles
efi_midnm      = '_cal_rmDCoffsets_'
low__suffx     = '_LowPassFilt_'+cutf_str[0]+'-'+lowf_str[0]+'Hz'
high_suffx     = '_HighPassFilt_'+midf_str[0]+'Hz'
low__tpnm      = pref[0]+modes_efi[0]+efi_midnm[0]+coord_dsl[0]+low__suffx[0]
high_tpnm      = pref[0]+modes_efi[0]+efi_midnm[0]+coord_dsl[0]+high_suffx[0]
;;  Define new subtitles
coord_up       = STRUPCASE(coord_dsl[0])
rmDC_nm        = 'efp(rm DC-offsets)'
yttl           = 'E ['+rmDC_nm[0]+', '+coord_up[0]+', mV/m]'
yttl_sub_lp    = '['+sr_str[0]+' sps, LP: '+lowf_str[0]+'Hz]'
yttl_sub_hp    = '['+sr_str[0]+' sps, HP: '+midf_str[0]+'Hz]'

str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
str_element,dlim_efp,'YSUBTITLE',yttl_sub_lp[0],/ADD_REPLACE
struct         = {X:efp_t,Y:efp_v_lowp}
store_data,low__tpnm[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp

str_element,dlim_efp,'YSUBTITLE',yttl_sub_hp[0],/ADD_REPLACE
struct         = {X:efp_t,Y:efp_v_higp}
store_data,high_tpnm[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp

;;  Add note to explain 0.01 Hz cutoff at low end
cutf_str       = STRTRIM(STRING(lowf0[0],FORMAT='(I)'),2L)
opt_snm        = 'DATA_ATT.NOTE_FILT'
opt_str_lp     = '[Filtered:  '+cutf_str[0]+'-'+lowf_str[0]+' Hz]'
opt_str_hp     = '[Filtered:  >'+midf_str[0]+' Hz]'
nna            = [low__tpnm[0],high_tpnm[0]]
options,nna[0],opt_snm[0],opt_str_lp[0],/DEF
options,nna[1],opt_snm[0],opt_str_hp[0],/DEF

;;  Remove "spikes" and edge-effects by hand
nna            = [low__tpnm[0],high_tpnm[0]]
kill_data_tr,NAMES=nna
;;----------------------------------------------------------------------------------------
;;  Try detrending the data
;;----------------------------------------------------------------------------------------

;;  Smooth data
mxpts          =  0L
smpts          = 10L      ;;  # of points to smooth
efp_v_smth     = REPLICATE(d,SIZE(efp_v,/DIMENSIONS))
FOR j=0L, pint - 1L DO BEGIN                                                           $
  st       = se_pels[j,0] + mxpts[0]                                                 & $
  en       = se_pels[j,1] - mxpts[0]                                                 & $
  inds     = st[0] + LINDGEN(en[0] - st[0] + 1L)                                     & $
  t_efpvx  = SMOOTH(efp_v[inds,0],smpts[0],/NAN,/EDGE_TRUNCATE)                      & $
  t_efpvy  = SMOOTH(efp_v[inds,1],smpts[0],/NAN,/EDGE_TRUNCATE)                      & $
  t_efpvz  = SMOOTH(efp_v[inds,2],smpts[0],/NAN,/EDGE_TRUNCATE)                      & $
  t_efpv   = [[t_efpvx],[t_efpvy],[t_efpvz]]                                         & $
  FOR k=0L, 2L DO efp_v_smth[inds,k] = t_efpv[*,k]

;;  Subtract smoothed data from original
diff_efp       = efp_v - efp_v_smth

;;  Send detrended efp to TPLOT
efi_smthnm     = '_cal_detrended_'
rmDC_nm        = 'efp(detrended)'
smth_tpnm      = pref[0]+modes_efi[0]+efi_smthnm[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E ['+rmDC_nm[0]+', '+coord_up[0]+', mV/m]'
str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:efp_t,Y:diff_efp}
store_data,smth_tpnm[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp


;;----------------------------------------------------------------------------------------
;;  Use derivative to find and remove "spikes"
;;----------------------------------------------------------------------------------------
vec_t          = efp_t
vec_v          = diff_efp
mxpts          =  0L
efp_v_dEdt     = REPLICATE(d,SIZE(efp_v,/DIMENSIONS))
FOR j=0L, pint - 1L DO BEGIN                                                           $
  st       = se_pels[j,0] + mxpts[0]                                                 & $
  en       = se_pels[j,1] - mxpts[0]                                                 & $
  inds     = st[0] + LINDGEN(en[0] - st[0] + 1L)                                     & $
  t_efpvx  = DERIV(vec_t[inds],vec_v[inds,0])                                        & $
  t_efpvy  = DERIV(vec_t[inds],vec_v[inds,1])                                        & $
  t_efpvz  = DERIV(vec_t[inds],vec_v[inds,2])                                        & $
  t_efpv   = [[t_efpvx],[t_efpvy],[t_efpvz]]                                         & $
  FOR k=0L, 2L DO efp_v_dEdt[inds,k] = t_efpv[*,k]

;;  Send derivative of efp to TPLOT
efi_dEdtnm     = '_cal_detrended_dEdt_'
rmDC_nm        = 'efp(detrended --> dE/dt)'
dEdt_tpnm      = pref[0]+modes_efi[0]+efi_dEdtnm[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E ['+rmDC_nm[0]+', '+coord_up[0]+', mV/m]'
str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:vec_t,Y:efp_v_dEdt}
store_data,dEdt_tpnm[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp

;;  Get EFI data
get_data,nodc_tpnm[0],DATA=temp_efp_nodc,DLIM=dlim_efp_nodc,LIM=lim_efp_nodc
get_data,dEdt_tpnm[0],DATA=temp_efp_dEdt,DLIM=dlim_efp_dEdt,LIM=lim_efp_dEdt
;;  Define parameters
efp_nodc_t     = temp_efp_nodc.X
efp_nodc_v     = temp_efp_nodc.Y
efp_dEdt_t     = temp_efp_dEdt.X
efp_dEdt_v     = temp_efp_dEdt.Y

;;  Define "bad" regions
despiked_efp_v = efp_nodc_v
thsh_noDC      = 5d1
thsh_dEdt      = 2d1
test_dEdt      = (ABS(efp_dEdt_v[*,0]) GE thsh_dEdt[0]) OR $
                 (ABS(efp_dEdt_v[*,1]) GE thsh_dEdt[0])
test_noDC      = (ABS(efp_nodc_v[*,0]) GE thsh_noDC[0]) OR $
                 (ABS(efp_nodc_v[*,1]) GE thsh_noDC[0])
test           = test_dEdt OR test_noDC
bad            = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
PRINT, ';;  ', bd, gd
;;         72919      240937

;;  Set "bad" regions to NaNs
IF (bd GT 0) THEN despiked_efp_v[bad,0L:1L] = d

;;  Send de-spiked efp, without DC-offsets, to TPLOT
efi_despke     = '_cal_rmDCoffsets_despiked_'
despke_nm      = 'efp(rm DC-offsets --> de-spiked)'
despke_tp      = pref[0]+modes_efi[0]+efi_despke[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E ['+despke_nm[0]+', '+coord_up[0]+', mV/m]'
str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:efp_nodc_t,Y:despiked_efp_v}
store_data,despke_tp[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp


;;  Remove remaining "spikes" and edge-effects by hand
nna            = [despke_tp[0]]
kill_data_tr,NAMES=nna

;;----------------------------------------------------------------------------------------
;;  Smooth de-spiked efp and use to detrend
;;----------------------------------------------------------------------------------------
vec_t          = efp_nodc_t
vec_v          = despiked_efp_v
;;  Linearly interpolate NaNs
;;  Use a cubic spline to interpolate NaNs
IF (gd GT 0) THEN t_efpvx = remove_nans(vec_t,vec_v[*,0],/NO_EXTRAPOLATE,/SPLINE)
IF (gd GT 0) THEN t_efpvy = remove_nans(vec_t,vec_v[*,1],/NO_EXTRAPOLATE,/SPLINE)
IF (gd GT 0) THEN t_efpvz = remove_nans(vec_t,vec_v[*,2],/NO_EXTRAPOLATE,/SPLINE)
IF (gd GT 0) THEN t_efpv  = [[t_efpvx],[t_efpvy],[t_efpvz]]
IF (gd GT 0) THEN vec_v   = t_efpv

mxpts          =  0L
smpts          = 32L      ;;  # of points to smooth
nsms           = STRING(FORMAT='(I3.3)',smpts[0])
sm_suffx       = nsms[0]+'pts'
despk_sm_efp_v = REPLICATE(d,SIZE(vec_v,/DIMENSIONS))
FOR j=0L, pint - 1L DO BEGIN                                                           $
  st       = se_pels[j,0] + mxpts[0]                                                 & $
  en       = se_pels[j,1] - mxpts[0]                                                 & $
  inds     = st[0] + LINDGEN(en[0] - st[0] + 1L)                                     & $
  t_efpvx  = SMOOTH(vec_v[inds,0],smpts[0],/NAN,/EDGE_TRUNCATE)                      & $
  t_efpvy  = SMOOTH(vec_v[inds,1],smpts[0],/NAN,/EDGE_TRUNCATE)                      & $
  t_efpvz  = SMOOTH(vec_v[inds,2],smpts[0],/NAN,/EDGE_TRUNCATE)                      & $
  t_efpv   = [[t_efpvx],[t_efpvy],[t_efpvz]]                                         & $
  FOR k=0L, 2L DO despk_sm_efp_v[inds,k] = t_efpv[*,k]

;;  Send smoothed de-spiked efp, without DC-offsets, to TPLOT
efi_despksm    = '_cal_rmDCoffsets_despiked_sm'+sm_suffx[0]+'_'
despksm_nm     = 'efp(rm DC --> de-spiked, Sm:'+sm_suffx[0]+')'
despksm_tp     = pref[0]+modes_efi[0]+efi_despksm[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E ['+coord_up[0]+', mV/m]'+'!C'+'['+despksm_nm[0]+']'
str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:vec_t,Y:despk_sm_efp_v}
store_data,despksm_tp[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp

tplot,[38,30,109,115,117,120,122,123]
;;----------------------------------------------------------------------------------------
;;  Determine spin phase
;;----------------------------------------------------------------------------------------
state_midnm    = 'state_'
sp_per_suff    = state_midnm[0]+'spinper'
sp_phs_suff    = state_midnm[0]+'spinphase'
sp_per_tpnm    = tnames(scpref[0]+sp_per_suff[0])
sp_phs_tpnm    = tnames(scpref[0]+sp_phs_suff[0])

;;  Force Y-Range of spin phase to -5 -> 365
options,sp_phs_tpnm[0],'YRANGE',[-5d0,365d0],/DEF

;;  Get EFI data
get_data,efp_names[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp

;;  Get spin phase and period
get_data,sp_per_tpnm[0],DATA=temp_sp_per,DLIM=dlim_sp_per,LIM=lim_sp_per
get_data,sp_phs_tpnm[0],DATA=temp_sp_phs,DLIM=dlim_sp_phs,LIM=lim_sp_phs

;;  Define parameters
efp_t          = temp_efp.X
efp_v          = temp_efp.Y
sp_per_t       = temp_sp_per.X
sp_per_v       = temp_sp_per.Y
sp_phs_t       = temp_sp_phs.X
sp_phs_v       = temp_sp_phs.Y
;;  Define spin rate [deg s^(-1)]
fac            = 36d1
spin_rate      = fac[0]/sp_per_v

;;  Interpolate spin phase
model          = spinmodel_get_ptr(sc[0],USE_ECLIPSE_CORRECTIONS=use_eclipse_corrections)
spinmodel_interp_t,MODEL=model,TIME=efp_t,SPINPHASE=phase,SPINPER=spinper,USE_SPINPHASE_CORRECTION=1       ;a la J. L.
;;  Send to TPLOT
spphs_int_tpnm = tnames(sp_phs_tpnm[0])+'_int'
struct         = {X:efp_t,Y:phase}
store_data,spphs_int_tpnm[0],DATA=struct,DLIM=dlim_sp_phs,LIM=lim_sp_phs
yttl           = STRUPCASE(sc[0])+' Spin Phase'+'!C'+'[interpolated to efp]'
options,spphs_int_tpnm[0],'YTITLE'
options,spphs_int_tpnm[0],'YTITLE',yttl[0],/DEF
options,spphs_int_tpnm[0],'YRANGE',[-5d0,365d0],/DEF

nnw            = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01


;;  Find derivative of spin phase
new_t          = efp_t
new_v          = phase
dT_dt          = DERIV(new_t,new_v)

;;  Clean up first
DELVAR,neg_1st,gdneg1,pos_1st,gdpos1,last
;;  Find where f'(t) < 0  --> compare magnitude to pts where f'(t) > 0
last           = 0L
FOR j=0L, pint - 1L DO BEGIN                                                           $
  test           = (dT_dt[se_pels[j,0]:se_pels[j,1]] LT 0)                           & $
  tneg           = WHERE(test,gdn1,COMPLEMENT=tpos,NCOMPLEMENT=gdp1)                 & $
  tneg          += last[0]                                                           & $
  tpos          += last[0]                                                           & $
  IF (j EQ 0) THEN neg_1st = tneg ELSE neg_1st = [neg_1st,tneg]                      & $
  IF (j EQ 0) THEN pos_1st = tpos ELSE pos_1st = [pos_1st,tpos]                      & $
  IF (j EQ 0) THEN gdneg1  = gdn1[0] ELSE gdneg1 += gdn1[0]                          & $
  IF (j EQ 0) THEN gdpos1  = gdp1[0] ELSE gdpos1 += gdp1[0]                          & $
  last          += N_ELEMENTS(dT_dt[se_pels[j,0]:se_pels[j,1]])                      & $
  PRINT,'gdn1 = ', gdn1[0], ' gdp1 = ', gdp1[0]

PRINT, ';;  ', gdneg1, gdpos1
;;          1618      312238

;test           = (dT_dt LT 0)
;neg_1st        = WHERE(test,gdneg1,COMPLEMENT=pos_1st,NCOMPLEMENT=gdpos1)
;PRINT, ';;  ', gdneg1, gdpos1
;;;          1618      312238

;;  Send derivative to TPLOT
dTdt_spphs_nm  = sp_phs_tpnm[0]+'_dTdt'
yttl           = 'dT/dt'+'!C'+'[slope of spin phase]'
str_element,dlim_sp_phs,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:new_t,Y:dT_dt}
store_data,dTdt_spphs_nm[0],DATA=struct,DLIM=dlim_sp_phs,LIM=lim_sp_phs
;options,dTdt_spphs_nm[0],'YRANGE',[-1d0,1d0]*2d0,/DEF


;;  Define intervals
;new_t          = efp_t
;new_v          = dT_dt
;IF (gdneg1 GT 0) THEN new_v[neg_1st] = d
;IF (gdneg1 GT 0) THEN new_t[neg_1st] = d

;;----------------------------------------------------------------------------------------
;;  Turn sawtooth into straight line
;;----------------------------------------------------------------------------------------
sratefp        = DOUBLE(sample_rate(new_t,GAP_THRESH=6d0,/AVE))
n_efp          = N_ELEMENTS(efp_t)
se             = [0L,n_efp - 1L]
a_ind          = DINDGEN(n_efp)
;IF (gdneg1 GT 0) THEN FOR j=0L, gdneg1 - 1L DO a_ind[neg_1st[j]:se[1]] += 5d0
se_sphase0     = t_interval_find(a_ind[pos_1st],GAP_THRESH=1d0)
;;  Make sure this is indexed correctly
n_spint        = N_ELEMENTS(se_sphase0[*,1])
t_sphs         = pos_1st[se_sphase0]
;;  Redefine intervals
se_sphase      = t_sphs
n_spint        = N_ELEMENTS(se_sphase[*,1])
se_sphase[0L:(n_spint - 2L),1L] += 1L
se_sphase[1L:(n_spint - 1L),0L] -= 1L

diff           = se_sphase[*,0] - SHIFT(se_sphase[*,1],1)
diff[0]        = 0L
n_inds         = se_sphase[*,1] - se_sphase[*,0] + 1L  ;;  # of elements per interval

new_v          = phase
phase_line     = REPLICATE(d,n_efp)
phase_line     = new_v
;phase_line[se_sphase[0,0]:se_sphase[0,1]] = new_v[se_sphase[0,0]:se_sphase[0,1]]
FOR j=1L, n_spint - 1L DO BEGIN                                                        $
  last = j - 1L                                                                      & $
  lind = LINDGEN(n_inds[last]) + se_sphase[last,0]                                   & $
  gind = LINDGEN(n_inds[j]) + (se_sphase[last,1] + 1L)                               & $
;  gind = LINDGEN(n_inds[j] + diff[j] - 1L) + (se_sphase[last,1] + 1L)                & $
  check  = (MIN(gind,/NAN) - MAX(lind,/NAN))                                         & $
  IF (check LE 0) THEN PRINT,'bad j = ',j,' MAX - MIN = ',check                      & $
  mxlast  = MAX(phase_line[lind],/NAN)                                               & $
  mod360  = 36d1 - (mxlast[0] MOD 36d1)                                              & $
  mxlast += mod360[0]                                                                & $
  phase_line[gind] += mxlast[0]                                                      & $
  IF ((j MOD 50L) EQ 0) THEN PRINT,'mxlast = ',mxlast[0]


;;  Now that it works, create sine wave and use to detrend DC-Coupled E-field

wi,1
wset,1
tind = LINDGEN(10000L)
plot, phase_line[tind],/ylog,/xlog,xrange=[1d0,MAX(tind)]
;plot, phase_line,/ylog,/xlog,xrange=[1d0,313856d0]
  oplot,reform(se_sphase[1,*]),phase_line[reform(se_sphase[1,*])],color=250,psym=2


;;----------------------------------------------------------------------------------------
;;  Determine magnitude of original efp in DSL
;;----------------------------------------------------------------------------------------
coord_mag      = 'mag'
efi_nodcnm     = '_cal_rmDCoffsets_'
efi_midnm      = '_cal_'
efp_names      = tnames(pref[0]+modes_efi[0]+efi_midnm[0]+coord_dsl[0]+'*')
nodc_tpnm      = tnames(pref[0]+modes_efi[0]+efi_nodcnm[0]+coord_dsl[0])
efp_mag_tpnm   = pref[0]+modes_efi[0]+efi_midnm[0]+coord_mag[0]
PRINT, ';; ', efp_mag_tpnm[0] & PRINT, ';; ', efp_names[0]
;; tha_efp_cal_mag
;; tha_efp_cal_dsl

;;  Get EFI data [DSL]
get_data,efp_names[0],DATA=temp_e0,DLIM=dlim_e0,LIM=lim_e0
;;  Calcluate magnitude of vector
e0_vec         = temp_e0.Y
calc,'temp = "tha_efp_cal_dsl"^2'
e0_mag         = SQRT(TOTAL(temp,2,/NAN))
;;  Remove "spikes"
thsh_noDC      = 5d1
thsh_dEdt      = 2d1
test_dEdt      = (ABS(efp_dEdt_v[*,0]) GE thsh_dEdt[0]) OR $
                 (ABS(efp_dEdt_v[*,1]) GE thsh_dEdt[0])
test_noDC      = (ABS(efp_nodc_v[*,0]) GE thsh_noDC[0]) OR $
                 (ABS(efp_nodc_v[*,1]) GE thsh_noDC[0])
test           = test_dEdt OR test_noDC
bad            = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
PRINT, ';;  ', bd, gd
;;         72919      240937

e1_mag         = e0_mag
IF (bd GT 0) THEN e1_mag[bad] = d

store_data,efp_mag_tpnm[0],DATA={X:temp_e0.X,Y:e1_mag},DLIM=dlim_e0,LIM=lim_e0
options,efp_mag_tpnm[0],'COLORS'
options,efp_mag_tpnm[0],'COLORS',/DEF
options,efp_mag_tpnm[0],'LABELS'
options,efp_mag_tpnm[0],'LABELS',/DEF

;;  Remove NaNs (linearly) and then kill original data that exceeds |Eo|
vec_t          = temp_e0.X
vec_v          = e1_mag
IF (gd GT 0) THEN t_efpmg = remove_nans(vec_t,vec_v,/NO_EXTRAPOLATE)

store_data,efp_mag_tpnm[0],DATA={X:vec_t,Y:t_efpmg},DLIM=dlim_e0,LIM=lim_e0
options,efp_mag_tpnm[0],'YTITLE','|Eo| [mV/m]',/DEF
options,efp_mag_tpnm[0],'COLORS'
options,efp_mag_tpnm[0],'COLORS',/DEF
options,efp_mag_tpnm[0],'LABELS'
options,efp_mag_tpnm[0],'LABELS',/DEF

;;  Remove remaining "spikes" and edge-effects by hand
nna            = [efp_mag_tpnm[0]]
kill_data_tr,NAMES=nna

;;  Retrieve de-spiked |Eo|
get_data,efp_mag_tpnm[0],DATA=temp_emag0,DLIM=dlim_emag0,LIM=lim_emag0
e2_mag         = temp_emag0.Y


test           = (e0_mag GT e2_mag) OR (FINITE(e2_mag) EQ 0)
bad_emag       = WHERE(test,bd_emag,COMPLEMENT=good_emag,NCOMPLEMENT=gd_emag)
PRINT, ';;  ', bd_emag, gd_emag
;;         46272      267584

;;  Set "bad" regions to NaNs
e1_vec         = e0_vec
IF (bd_emag GT 0) THEN e1_vec[bad_emag,0L:1L] = d

efi_despke2    = '_cal_despiked_'
despke_nm2     = 'efp(de-spiked)'
despke_tp2     = pref[0]+modes_efi[0]+efi_despke2[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E ['+despke_nm2[0]+', '+coord_up[0]+', mV/m]'
str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
vec_t          = temp_e0.X
struct         = {X:vec_t,Y:e1_vec}
store_data,despke_tp2[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp

;;----------------------------------------------------------------------------------------
;;  Calculate E_conv = - Vsw x Bo
;;----------------------------------------------------------------------------------------
efac           = -1d0*1d3*1d-9*1d3    ;;  km --> m, nT --> T, V --> mV
;;  Get Vsw data [DSL]
get_data,vsw_nm_dsl[0]+'_fixed_3',DATA=Vsw_dsl,DLIM=dlim_Vsw_dsl,LIM=lim_Vsw_dsl
;;  Get Bo data [DSL]
get_data,all_fgh_tpnm[1],DATA=fgh_dsl,DLIM=dlim_fgh_dsl,LIM=lim_fgh_dsl

;;  Define Vsw and Bo parameters
vsw_t          = Vsw_dsl.X
vsw_v          = Vsw_dsl.Y
fgh_t          = fgh_dsl.X
fgh_v          = fgh_dsl.Y
;;  Upsample Vsw to Bo times
up_vsw_x       = interp(vsw_v[*,0],vsw_t,fgh_t,/NO_EXTRAPOLATE)
up_vsw_y       = interp(vsw_v[*,1],vsw_t,fgh_t,/NO_EXTRAPOLATE)
up_vsw_z       = interp(vsw_v[*,2],vsw_t,fgh_t,/NO_EXTRAPOLATE)
up_vsw_v       = [[up_vsw_x],[up_vsw_y],[up_vsw_z]]
;;  Calculate E_conv = - Vsw x Bo
e_conv         = efac[0]*my_crossp_2(up_vsw_v,fgh_v,/NOM)

;;  Linearly interpolate NaNs
vec_t          = temp_e0.X
vec_v          = e1_vec
t_efpvx        = remove_nans(vec_t,vec_v[*,0],/NO_EXTRAPOLATE)
t_efpvy        = remove_nans(vec_t,vec_v[*,1],/NO_EXTRAPOLATE)
t_efpvz        = remove_nans(vec_t,vec_v[*,2],/NO_EXTRAPOLATE)
t_efpv         = [[t_efpvx],[t_efpvy],[t_efpvz]]

;;  Remove E_conv from observed Eo
e0_rest        = t_efpv - e_conv

;;  Send de-spiked efp, without E_conv, to TPLOT
efi_despke3    = '_cal_despiked_rmEconv_'
despke_nm3     = 'efp(de-spiked --> Eo - E!Dconv!N'+')'
despke_tp3     = pref[0]+modes_efi[0]+efi_despke3[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E ['+coord_up[0]+', mV/m]'+'!C'+'['+despke_nm3[0]+']'
str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:vec_t,Y:e0_rest}
store_data,despke_tp3[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp

;;  Now remove DC-offsets from Eo_rest
get_data,despke_tp3[0],DATA=temp_Eor,DLIM=dlim_Eor,LIM=lim_Eor
;;  Smooth and then remove DC-offsets
vec_t          = temp_Eor.X
vec_v          = temp_Eor.Y
;;  Set "bad" regions to NaNs
vec_v1         = vec_v
IF (bd_emag GT 0) THEN vec_v1[bad_emag,0L:1L] = d
smpts          = 10L
mxpts          = 50L
Eor_v_nodc     = REPLICATE(d,SIZE(vec_v,/DIMENSIONS))
FOR j=0L, pint - 1L DO BEGIN                                                           $
  st       = se_pels[j,0] + mxpts[0]                                                 & $  ;; stay away from end pts
  en       = se_pels[j,1] - mxpts[0]                                                 & $
  inds     = st[0] + LINDGEN(en[0] - st[0] + 1L)                                     & $
  t_efpvx  = SMOOTH(vec_v1[inds,0],smpts[0],/NAN,/EDGE_TRUNCATE)                     & $
  t_efpvy  = SMOOTH(vec_v1[inds,1],smpts[0],/NAN,/EDGE_TRUNCATE)                     & $
  t_efpvz  = SMOOTH(vec_v1[inds,2],smpts[0],/NAN,/EDGE_TRUNCATE)                     & $
  t_efpv   = [[t_efpvx],[t_efpvy],[t_efpvz]]                                         & $
  avgs     = [MEAN(t_efpv[*,0],/NAN),MEAN(t_efpv[*,1],/NAN),MEAN(t_efpv[*,2],/NAN)]  & $
  FOR k=0L, 2L DO Eor_v_nodc[inds,k] = vec_v1[inds,k] - avgs[k]

;;  Send de-spiked efp, without E_conv and DC-offsets, to TPLOT
efi_despk_nodc = '_cal_despiked_rmEconv_rmDC_'
despk_nodc_nm  = 'Eo - E!Dconv!N -> rm DCoffsets'
despk_nodc_tp  = pref[0]+modes_efi[0]+efi_despk_nodc[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E [efp, '+coord_up[0]+', mV/m, de-spiked]'+'!C'+'['+despk_nodc_nm[0]+']'
str_element,dlim_Eor,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:vec_t,Y:Eor_v_nodc}
store_data,despk_nodc_tp[0],DATA=struct,DLIM=dlim_Eor,LIM=lim_Eor

;;  Remove "spikes" and edge-effects by hand
nna            = [despk_nodc_tp[0]]
kill_data_tr,NAMES=nna

;;----------------------------------------------------------------------------------------
;;  Plot results
;;----------------------------------------------------------------------------------------
coord          = coord_dsl[0]
all_fgl_tpnm   = [fgm_mag[1],fgm_dsl[1]]
all_fgh_tpnm   = [fgm_mag[2],fgm_dsl[2]]
all_fgm_tpnm   = all_fgl_tpnm
all_scp_tpnm   = scp_names[0]
all_efp_tpnm   = [efp_names[0],smth_tpnm[0],despke_tp2[0],despk_nodc_tp[0]]

nna            = [all_fgm_tpnm,all_scp_tpnm,all_efp_tpnm]
tra            = t_ramp0[0] + [-1d0,1d0]*115d0  ;; 230 s window centered on ramp
tplot,nna,TRANGE=tra

;;  fgl, EFI & SCM Plots
all_fgm_tpnm   = all_fgl_tpnm
f_pref         = prefu[0]+'fgl-mag-'+coord[0]+'_scp-cal-'+coord[0]+'_efp-cal-detrend-despike-rmEswDCoff-'+coord[0]+'_'
nna            = [all_fgm_tpnm,all_scp_tpnm[0],all_efp_tpnm]

;;  fgh, EFI & SCM Plots
all_fgm_tpnm   = all_fgh_tpnm
f_pref         = prefu[0]+'fgh-mag-'+coord[0]+'_scp-cal-'+coord[0]+'_efp-cal-detrend-despike-rmEswDCoff-'+coord[0]+'_'
nna            = [all_fgm_tpnm,all_scp_tpnm[0],all_efp_tpnm]


traz           = t_get_current_trange()
fnm_tra        = file_name_times(traz,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
fnames         = f_pref[0]+ftime[0]
PRINT, fnames[0]

popen,fnames[0],/PORT
  tplot,nna,TRANGE=traz
pclose
  tplot,/NOM

;;----------------------------------------------------------------------------------------
;;  Calculate spin fit of altered data
;;----------------------------------------------------------------------------------------
;;  Get spin phase and period
get_data,sp_per_tpnm[0],DATA=temp_sp_per,DLIM=dlim_sp_per,LIM=lim_sp_per
get_data,sp_phs_tpnm[0],DATA=temp_sp_phs,DLIM=dlim_sp_phs,LIM=lim_sp_phs
;;  Get Eo data [DSL]
get_data,despk_nodc_tp[0],DATA=temp_Eornodc,DLIM=dlim_Eornodc,LIM=lim_Eornodc
;;  Define parameters
vec_t          = temp_Eornodc.X
vec_v          = temp_Eornodc.Y
sp_per_t       = temp_sp_per.X
sp_per_v       = temp_sp_per.Y
sp_phs_t       = temp_sp_phs.X
sp_phs_v       = temp_sp_phs.Y
;;  Calculate sunpulse data
state_midnm    = 'state_'
sunpulse_nm    = scpref[0]+state_midnm[0]+'sun_pulse'
thm_sunpulse,sp_per_t,sp_phs_v,sp_per_v,sunpulse,sunp_spinper,PROBE=sc[0],SUNPULSE_NAME=sunpulse_nm[0]
;;  Get sunpulse
get_data,sunpulse_nm[0],DATA=thx_sunpulse_times
sunp_t         = thx_sunpulse_times.X
sunp_v         = thx_sunpulse_times.Y

;;  First clean up de-spiked efp, without E_conv and DC-offsets
;;  Use a cubic spline to interpolate NaNs
t_efpvx        = remove_nans(vec_t,vec_v[*,0],/NO_EXTRAPOLATE,/SPLINE)
t_efpvy        = remove_nans(vec_t,vec_v[*,1],/NO_EXTRAPOLATE,/SPLINE)
t_efpvz        = remove_nans(vec_t,vec_v[*,2],/NO_EXTRAPOLATE,/SPLINE)
t_efpv         = [[t_efpvx],[t_efpvy],[t_efpvz]]
vec_v          = t_efpv
;;  Only use indices near shock
gind           = LONG(a_ind[se_pels[2,0]:se_pels[2,1]])

;;  Find X-Axis fit
plane_dim      = 0
axis_dim       = 0
sun2sensor     = 0d0
spinfit,$
          vec_t[gind],vec_v[gind,*],sunp_t,sunp_v,     $         ;;  Input
          a,b,c,spin_axis,med_axis,sig,npts,sun_data,  $         ;;  Output
          MIN_POINTS=min_points,ALPHA=alpha,BETA=beta, $
          PLANE_DIM=plane_dim,AXIS_DIM=axis_dim,PHASE_MASK_STARTS=phase_mask_starts,$
          PHASE_MASK_ENDS=phase_mask_ends,SUN2SENSOR=sun2sensor

;;  Send to TPLOT
fit_tpns       = ['a','b','c','sig','npts']
boomfit        = 'x'
temp_tpn       = 'test_spinfit_efp_'+boomfit[0]+'_'
ysubt          = '[Spinfit to efp]'

str_element, lim_Eornodc,'LABELS',/DELETE
str_element,dlim_Eornodc,'LABELS',/DELETE
str_element,dlim_Eornodc,'COLORS',50,/ADD_REPLACE

store_data,temp_tpn[0]+fit_tpns[0],   DATA={X:sun_data,   Y:a},DLIM=dlim_Eornodc,LIM=lim_Eornodc
store_data,temp_tpn[0]+fit_tpns[1],   DATA={X:sun_data,   Y:b},DLIM=dlim_Eornodc,LIM=lim_Eornodc
store_data,temp_tpn[0]+fit_tpns[2],   DATA={X:sun_data,   Y:c},DLIM=dlim_Eornodc,LIM=lim_Eornodc
store_data,temp_tpn[0]+fit_tpns[3],   DATA={X:sun_data, Y:sig},DLIM=dlim_Eornodc,LIM=lim_Eornodc
store_data,temp_tpn[0]+fit_tpns[4],   DATA={X:sun_data,Y:npts},DLIM=dlim_Eornodc,LIM=lim_Eornodc
options,temp_tpn[0]+fit_tpns[0],'YTITLE','Spinfit Param. '+fit_tpns[0]
options,temp_tpn[0]+fit_tpns[1],'YTITLE','Spinfit Param. '+fit_tpns[1]
options,temp_tpn[0]+fit_tpns[2],'YTITLE','Spinfit Param. '+fit_tpns[2]
options,temp_tpn[0]+fit_tpns[3],'YTITLE','Spinfit Param. '+fit_tpns[3]
options,temp_tpn[0]+fit_tpns[4],'YTITLE','Spinfit Param. '+fit_tpns[4]
options,temp_tpn[0]+fit_tpns[0],'YSUBTITLE',ysubt[0]
options,temp_tpn[0]+fit_tpns[1],'YSUBTITLE',ysubt[0]
options,temp_tpn[0]+fit_tpns[2],'YSUBTITLE',ysubt[0]
options,temp_tpn[0]+fit_tpns[3],'YSUBTITLE',ysubt[0]
options,temp_tpn[0]+fit_tpns[4],'YSUBTITLE',ysubt[0]


nna            = [all_fgh_tpnm,despk_nodc_tp[0],temp_tpn[0]+'*']
  tplot,nna,TRANGE=traz


get_data,spphs_int_tpnm[0],DATA=spphs_int,DLIM=dlim_sp_phs,LIM=lim_sp_phs
sphase_t       = spphs_int.X
sphase_v       = spphs_int.Y
sphase_vr      = sphase_v*!DPI/18d1


;;  Reconstruct Eo_x
smpts          = 10L      ;;  # of points to smooth
up_t           = vec_t[gind]
a_up           = interp(SMOOTH(a,smpts[0],/NAN,/EDGE_TRUNCATE),sun_data,up_t,/NO_EXTRAPOLATE)
b_up           = interp(SMOOTH(b,smpts[0],/NAN,/EDGE_TRUNCATE),sun_data,up_t,/NO_EXTRAPOLATE)
c_up           = interp(SMOOTH(c,smpts[0],/NAN,/EDGE_TRUNCATE),sun_data,up_t,/NO_EXTRAPOLATE)
Eo_x_fit       = a_up + b_up*COS(sphase_vr) + c_up*SIN(sphase_vr)

wi,1
WSET,1
PLOT,Eo_x_fit,/NODATA,/XSTYLE,/YSTYLE
  OPLOT,Eo_x_fit,COLOR=250
  OPLOT,vec_v[gind,0],COLOR= 50,PSYM=3

;;----------------------------------------------------------------------------------------
;;  Save data for tomorrow
;;----------------------------------------------------------------------------------------
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_'
fsuff          = 'efp-despiked_rmEconv-DC-despun_'
traz           = t_get_current_trange()
fnm_tra        = file_name_times(traz,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
fname          = fpref[0]+fsuff[0]+ftime[0]
PRINT, fname[0]

tplot_save,FILENAME=fname[0]


;;----------------------------------------------------------------------------------------
;;  NOTE:  hypothesis = correct
;;  Test hypothesis that large spikes are due to shadow and wake effects
;;----------------------------------------------------------------------------------------

;;  Get spin phase data
get_data,spphs_int_tpnm[0],DATA=temp_sp0,DLIM=dlim_sp0,LIM=lim_sp0
;;  Get EFI data [DSL]
get_data,efp_names[0],DATA=temp_e0,DLIM=dlim_e0,LIM=lim_e0
;;  Get Vsw data [DSL]
get_data,vsw_nm_dsl[0]+'_fixed_3',DATA=Vsw_dsl,DLIM=dlim_Vsw_dsl,LIM=lim_Vsw_dsl

;;  Define spin phase parameters
sp0_d          = temp_sp0.Y
sp0_r          = temp_sp0.Y*!DPI/18d1        ;;  convert to radians
sp0_rn         = sp0_r/(2d0*!DPI)            ;;  normalize to 2π

;;  Define EFI parameters
e0_vec         = temp_e0.Y
e0_mag         = SQRT(TOTAL(e0_vec^2,2,/NAN))
e0_uvec        = e0_vec/(e0_mag # REPLICATE(1d0,3))
gind           = LONG(a_ind[se_pels[2,0]:se_pels[2,1]])  ;;  Only use indices near shock
up_t           = temp_e0.X[gind]  ;;  upsample times

;;  Define Vsw parameters
smvel3         = Vsw_dsl.Y
;;  Upsample to EFI times
up_vsw_x       = interp(smvel3[*,0],ti_vsw.X,up_t,/NO_EXTRAPOLATE)
up_vsw_y       = interp(smvel3[*,1],ti_vsw.X,up_t,/NO_EXTRAPOLATE)
up_vsw_z       = interp(smvel3[*,2],ti_vsw.X,up_t,/NO_EXTRAPOLATE)
up_vsw_v       = [[up_vsw_x],[up_vsw_y],[up_vsw_z]] 
up_vsw_m       = SQRT(TOTAL(up_vsw_v^2,2,/NAN))
upvsw_uv       = up_vsw_v/(up_vsw_m # REPLICATE(1d0,3))


;;-----------------------------------------
;;  Plot parameters
;;-----------------------------------------
wi,1


;;  Ex_u vs. ø [rad]
xdat           = sp0_r[gind]
ydat           = ABS(e0_uvec[gind,0])
xran           = [0d0,2d0*!DPI]
yran           = [0d0,1d0]
xlog           = 0
ylog           = 0
nsum           = 1

;;  |Ex_u|/|Vswx_u| vs. |Ey_u|/|Vswy_u|
xdat           = ABS(e0_uvec[gind,0])/ABS(upvsw_uv[*,0])
ydat           = ABS(e0_uvec[gind,1])/ABS(upvsw_uv[*,1])
xran           = [1d-2,2d1]
yran           = xran
xlog           = 1
ylog           = 1
nsum           = 20

WSET,1
pstr           = {XSTYLE:1,YSTYLE:1,XRANGE:xran,YRANGE:yran,XLOG:xlog,YLOG:ylog,NODATA:1}
PLOT,xdat,ydat,_EXTRA=pstr
  OPLOT,xdat,ydat,PSYM=2,COLOR=250,NSUM=nsum


;;  Ex_u vs. ø [deg]
xdat0          = sp0_d[gind]
xdat1          = (xdat0 + 9d1) MOD 36d1
ydat0          = ABS(e0_uvec[gind,0])
ydat1          = ABS(e0_uvec[gind,1])
xran           = [0d0,365d0]
yran           = [0d0,1.1d0]

;;  Ex_u vs. ø [deg, shifted]
;;  +Y-SPG is -45 deg from +X-SSL at start of sun pulse and
;;    +X-SPG is -135 deg from +X-SSL " "
;xdat0          = ((sp0_d[gind] - 135d0) + 36d1) MOD 36d1
xdat0          = ((sp0_d[gind] - 45d0) + 36d1) MOD 36d1
xdat1          = (xdat0 + 9d1) MOD 36d1
ydat0          = ABS(e0_uvec[gind,0])
ydat1          = ABS(e0_uvec[gind,1])
xran           = [0d0,365d0]
yran           = [0d0,1.1d0]

;;  (Ex_u vs. Vswx_u) and (Ey_u vs. Vswy_u)
xdat0          = ABS(upvsw_uv[*,0])
xdat1          = ABS(upvsw_uv[*,1])
ydat0          = ABS(e0_uvec[gind,0])
ydat1          = ABS(e0_uvec[gind,1])
xran           = [0d0,1d0]
yran           = [0d0,1d0]


WSET,1
pstr           = {XSTYLE:1,YSTYLE:1,XRANGE:xran,YRANGE:yran,NODATA:1}
PLOT,xdat0,ydat0,_EXTRA=pstr
  OPLOT,xdat0,ydat0,PSYM=1,COLOR=250
  OPLOT,xdat1,ydat1,PSYM=1,COLOR= 50











;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Wrong
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------



;;  Define initial and final conditions
efp_t_if       = [MIN(efp_t,/NAN),MAX(efp_t,/NAN)]
T_sp_if        = interp(sp_per_v,sp_per_t,efp_t_if,/NO_EXTRAPOLATE)
w_sp_if        = interp(spin_rate,sp_per_t,efp_t_if,/NO_EXTRAPOLATE)
phase_if       = interp(sp_phs_v,sp_phs_t,efp_t_if,/NO_EXTRAPOLATE)

test           = (sp_per_t GE efp_t_if[0]) AND (sp_per_t LE efp_t_if[1])
good_spp       = WHERE(test,gdspp)
test           = (sp_phs_t GE efp_t_if[0]) AND (sp_phs_t LE efp_t_if[1])
good_sph       = WHERE(test,gdsph)
PRINT, ';;  ', gdspp, gdsph
;;           306         306

;;  Find derivative of spin phase
dT_dt          = DERIV(sp_phs_t,sp_phs_v)
;;  Send derivative to TPLOT
dTdt_spphs_nm  = sp_phs_tpnm[0]+'_dTdt'
yttl           = 'dT/dt'+'!C'+'[slope of spin phase]'
str_element,dlim_sp_phs,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:sp_phs_t,Y:dT_dt}
store_data,dTdt_spphs_nm[0],DATA=struct,DLIM=dlim_sp_phs,LIM=lim_sp_phs
options,dTdt_spphs_nm[0],'YRANGE',[-1d0,1d0]*2d0,/DEF

;;  Find 2nd derivative of spin phase
d2T_dt2        = DERIV(sp_phs_t,dT_dt)
;;  Send 2nd derivative to TPLOT
dTdt2_spphs_nm = sp_phs_tpnm[0]+'_d2Tdt2'
yttl           = 'd!U2!NT/dt!U2!N'+'!C'+'[curvature of spin phase]'
str_element,dlim_sp_phs,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:sp_phs_t,Y:d2T_dt2}
store_data,dTdt2_spphs_nm[0],DATA=struct,DLIM=dlim_sp_phs,LIM=lim_sp_phs
options,dTdt2_spphs_nm[0],'YRANGE',[-1d0,1d0]*3d-2,/DEF

;;  Find 3rd derivative of spin phase
d3T_dt3        = DERIV(sp_phs_t,d2T_dt2)
;;  Send 3rd derivative to TPLOT
dTdt3_spphs_nm = sp_phs_tpnm[0]+'_d3Tdt3'
yttl           = 'd!U3!NT/dt!U3!N'+'!C'+'[jerk? of spin phase]'
str_element,dlim_sp_phs,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:sp_phs_t,Y:d3T_dt3}
store_data,dTdt3_spphs_nm[0],DATA=struct,DLIM=dlim_sp_phs,LIM=lim_sp_phs
options,dTdt3_spphs_nm[0],'YRANGE',[-1d0,1d0]*5d-4,/DEF



;;  Remove edge-effects by hand
nna            = [dTdt_spphs_nm[0],dTdt2_spphs_nm[0],dTdt3_spphs_nm[0]]
kill_data_tr,NAMES=nna


;;  Find where f'(t) < 0  --> compare magnitude to pts where f'(t) > 0
test           = (dT_dt LT 0)
neg_1st        = WHERE(test,gdneg1,COMPLEMENT=pos_1st,NCOMPLEMENT=gdpos1)
PRINT, ';;  ', gdneg1, gdpos1
;;           839         601

IF (gdneg1 GT 0) THEN only_neg1_v = dT_dt[neg_1st]
IF (gdpos1 GT 0) THEN only_pos1_v = dT_dt[pos_1st]
x              = ABS(only_neg1_v)
stats_neg1     = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x)]
x              = ABS(only_pos1_v)
stats_pos1     = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x)]
PRINT, ';;', stats_neg1  &  PRINT, ';;', stats_pos1
;;       1.0860140       1.2573963       1.2517498       1.2553566
;;       1.7426592       1.9095670       1.7477805       1.7446431



;;  1st pt where f"(t) < 0  --> roll over point
;;    => break up into intervals
test           = (d2T_dt2 LT 0)
neg_2nd        = WHERE(test,gdneg,COMPLEMENT=pos_2nd,NCOMPLEMENT=gdpos)
PRINT, ';;  ', gdneg2, gdpos2
;;           727         713

only_neg_t     = sp_phs_t
only_neg_v     = d2T_dt2
IF (gdneg2 GT 0) THEN only_neg_t = only_neg_t[neg_2nd]
IF (gdneg2 GT 0) THEN only_neg_v = only_neg_v[neg_2nd]

srate_sp       = DOUBLE(sample_rate(sp_phs_t,GAP_THRESH=61d0,/AVE))
se_spel        = t_interval_find(only_neg_t,GAP_THRESH=1d0/srate_sp[0])
spint          = N_ELEMENTS(se_spel[*,0])



;;  Look for large ∆f(t)
nsp            = N_ELEMENTS(sp_phs_t)
se             = [0L, nsp[0] - 1L]
diff           = sp_phs_v - SHIFT(sp_phs_v,1)
diff[se]       = d



.compile /Users/lbwilson/Desktop/temp_idl/find_inv_mod.pro
test = find_inv_mod(sp_phs_v[5],36d1)
print, test























;;  Load sun pulse times
sunpulse_nm    = scpref[0]+state_midnm[0]+'sun_pulse'
thm_sunpulse,sp_per_t,sp_phs_v,sp_per_v,sunpulse,sunp_spinper,PROBE=sc[0],SUNPULSE_NAME=sunpulse_nm[0]
;;  sunpulse     = sun pulse times
;;  sunp_spinper = spin period at sun pulse times

;;  Calculate spin phase at sun pulse times
new_t          = sunpulse
new_v          = sunp_spinper
thm_spin_phase,new_t,spinpha_int,new_t,new_v
;;  spinpha_int  = spin phase (interpolated) at sun pulse times



















;;----------------------------------------------------------------------------------------
;;  Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;;  Electron mass [kg]
mp             = 1.6726217770d-27     ;;  Proton mass [kg]
ma             = 6.6446567500d-27     ;;  Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;;  Speed of light in vacuum [m/s]
epo            = 8.8541878170d-12     ;;  Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;;  Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;;  Fundamental charge [C]
kB             = 1.3806488000d-23     ;;  Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;;  Planck Constant [J s]
GG             = 6.6738400000d-11     ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [J]
;;  Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K
R_E            = 6.37814d3            ;;  Earth's Equitorial Radius [km]
;;----------------------------------------------------------------------------------------
;;  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  2009-09-26 [1 Crossing]
tdate          = '2009-09-26'
tr_00          = tdate[0]+'/'+['12:00:00','17:40:00']
date           = '092609'
probe          = 'a'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
tr_jj          = time_double(tdate[0]+'/'+['15:48:20.000','15:58:25.000'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['15:53:09.911','15:53:10.249'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = d
t_ramp2        = d
;;  Example waveform times
tr_ww          = time_double(tdate[0]+'/'+['15:53:02.500','15:53:15.600'])
tr_esw0        = time_double(tdate[0]+'/'+['15:53:03.475','15:53:03.500'])  ;;  train of ESWs [efw, Int. 0]
tr_esw1        = time_double(tdate[0]+'/'+['15:53:04.474','15:53:04.503'])  ;;  train of ESWs [efw, Int. 0]
tr_esw2        = time_double(tdate[0]+'/'+['15:53:09.910','15:53:09.940'])  ;;  two      ESWs [efw, Int. 1]
tr_whi         = time_double(tdate[0]+'/'+['15:53:10.860','15:53:11.203'])  ;;  example whistlers [scw, Int. 1]
tr_ww1         = time_double(tdate[0]+'/'+['15:53:09.165','15:53:15.590'])
tr_ww2         = time_double(tdate[0]+'/'+['15:53:09.165','15:53:12.500'])
;;----------------------------------------------------------------------------------------
;;  Define timespan
;;----------------------------------------------------------------------------------------
timespan,tdate[0],1.0,/DAY

;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
scu            = STRUPCASE(sc[0])
prefu          = STRUPCASE(pref[0])

thm_load_fgm,  PROBE=sc[0],LEVEL=1,TYPE='raw'
thm_load_efi,  PROBE=sc[0],LEVEL=1,TYPE='raw'
thm_load_state,PROBE=sc[0],/GET_SUPPORT_DATA

options,[1,2,3,4,5,6],'COLORS'
options,[1,2,3,4,5,6],'COLORS',[250,150, 50],/DEF

;;----------------------------------------------------------------------------------------
;;  Set defaults
;;----------------------------------------------------------------------------------------
!themis.VERBOSE = 2
tplot_options,'VERBOSE',2
options,tnames(),'LABFLAG',2,/DEF
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='THEMIS-'+scu[0]+' Plots ['+tdate[0]+']'

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
;;----------------------------------------------------------------------------------------
;;  Plot
;;----------------------------------------------------------------------------------------
scpref         = 'th'+sc[0]+'_'

coord_dsl      = 'dsl'
modes_slh      = ['s','l','h']
mode_fgm       = 'fg'+modes_slh
fgm_pren       = scpref[0]+mode_fgm
fgm_tpnm       = tnames(fgm_pren[*])


;;  perform spin fit on fgh data and have it return A, B, C fit parameters plus the
;;  standard deviation and number of points remaining in curve.

;;  fit magnetic field data
thm_spinfit,scpref[0]+'fg?',/SIGMA,/NPOINTS

;;  fit electric field data
thm_spinfit,scpref[0]+'fg?',/SIGMA,/NPOINTS


;;  Now load on board spin fit data to compare.
thm_load_fit,PROBE=sc[0],TYPE='raw'
















