;;  plot_mva_stats_multifreq_precusor_by_freq_crib.pro

;;  ***  Need to start in SPEDAS mode, not UIDL64  ***
;;  Compile relevant routines
@comp_lynn_pros
thm_init

;;----------------------------------------------------------------------------------------
;;  Coordinates and vectors
;;----------------------------------------------------------------------------------------
;;  Define some coordinate strings
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_fac      = 'fac'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
vec_str        = ['x','y','z']
tensor_str     = ['x'+vec_str,'y'+vec_str[1:2],'zz']
fac_vec_str    = ['perp1','perp2','para']
fac_dir_str    = ['para','perp','anti']
vec_col        = [250,150, 50]
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}
;;  Define save/setup stuff for TPLOT
popen_str      = {PORT:1,LANDSCAPE:0,UNITS:'inches',YSIZE:11,XSIZE:8.5}
;;  Define spacecraft-specific variables
sc             = 'Wind'
scpref         = sc[0]+'_'
;;  Define save directory
slash          = get_os_slash()           ;;  '/' for Unix, '\' for Windows
mva_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'mva_sav'+slash[0]
;;  Define relevant TPLOT handles
mfi_gse_tpn    = 'Wind_B_htr_gse'
mfi_mag_tpn    = 'Wind_B_htr_mag'
mfi_filt_lp    = 'lowpass_Bo'
mfi_filt_hp    = 'highpass_Bo'
mfi_filt_dettp = 'highpass_Bo_detrended'
;;----------------------------------------------------------------------------------------
;;  Initialize and setup
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/print_ip_shocks_whistler_stats_batch.pro
;;  Convert zoom times to Unix
start_unix     = time_double(start_times)
end___unix     = time_double(end___times)
midt__unix     = (start_unix + end___unix)/2d0
;;----------------------------------------------------------------------------------------
;;  Define time ranges to load into TPLOT
;;----------------------------------------------------------------------------------------
delt           = [-1,1]*6d0*36d2        ;;  load ±6 hours about ramp
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/get_ip_shocks_whistler_ramp_times_batch.pro

all_stunix     = tura_mid + delt[0]
all_enunix     = tura_mid + delt[1]
all__trans     = [[all_stunix],[all_enunix]]
nprec          = N_ELEMENTS(tura_mid)
;;----------------------------------------------------------------------------------------
;;  Define burst and precursor intervals
;;----------------------------------------------------------------------------------------
tran_brsts     = time_string(all__trans,PREC=3)
tran__subs     = [[prec_st],[prec_en]]
;;----------------------------------------------------------------------------------------
;;  Define frequency filter range
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/load_ip_shocks_prec_freq_range_batch.pro

;;----------------------------------------------------------------------------------------
;;  Restore IDL save file containing all "best" MVA results for all burst intervals
;;----------------------------------------------------------------------------------------
fname_suff     = 'Filtered_MultiFreq_MFI_MVA_Results.sav'
fname_out      = STRUPCASE(scpref[0])+'All_*_Precursor_Ints_'+fname_suff[0]             ;;  e.g., 'WIND_All_113_Precursor_Ints_Filtered_MFI_OnlyBest_MVA_Results.sav'
fname          = FILE_SEARCH(mva_dir[0],fname_out[0])
IF (fname[0] NE '') THEN RESTORE,fname[0]

;;  Define indices relative to CfA database
good           = good_y_all0
gd             = gd_y_all[0]
ind1           = good_A
ind2           = good_A[good_y_all0]      ;;  All "good" shocks with whistlers [indices for CfA arrays]
;;  Get Precursor MVA Statistics
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/count_precusor_mva_stats_multifreq_batch.pro

good_lowf      = WHERE(f_lower LE 1d-1,gd_lowf)
good_midf      = WHERE(f_lower GT 1d-1 AND f_lower LE 5d-1,gd_midf)
good_upp0      = WHERE(f_lower GT 5d-1,gd_upp0)
good_upp1      = WHERE(f_lower GT 1d0, gd_upp1)
good_upp2      = WHERE(f_lower GT 1d-1,gd_upp2)
PRINT,';;  ',gd_lowf[0],gd_midf[0],gd_upp0[0],gd_upp1[0],gd_upp2[0]
;;           275         894         827         371        1721

;;  Define tag prefixes
date_tpre      = 'DATE_'        ;;  Dates
iint_tpre      = 'INT_'         ;;  precursor time intervals for each date
fint_tpre      = 'FR_'          ;;  frequency range tags
;;  Define date and precursor interval tags
scpref0        = sc[0]
date_tags      = date_tpre[0]+tdate_ramps
prec_tags      = iint_tpre[0]+'000'
suffxs         = ', on '+tdate_ramps+', with '+STRUPCASE(scpref0[0])
;;  Define output to summarize stats
cnt_str        = (num2int_str(tot_cnt[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdlowf_str     = (num2int_str(gd_lowf[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdmidf_str     = (num2int_str(gd_midf[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdupp0_str     = (num2int_str(gd_upp0[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdupp1_str     = (num2int_str(gd_upp1[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdupp2_str     = (num2int_str(gd_upp2[0],NUM_CHAR=6,/ZERO_PAD))[0]
gdmva_str      = (num2int_str(N_ELEMENTS(theta_kb),NUM_CHAR=6,/ZERO_PAD))[0]
allmva_str     = (num2int_str(all_mva_cnt[0],NUM_CHAR=8,/ZERO_PAD))[0]
suffixt        = ' Total Good MVA Intervals for '+scpref0[0]+' IP Shocks'
sout           = ';;  '+cnt_str[0]+' of '+gdmva_str[0]+suffixt[0]
sout1a         = ';;  '+gdlowf_str[0]+' of which have f ≤ 100 mHz'
sout1b         = ';;  '+gdmidf_str[0]+' of which have 100 mHz < f ≤ 500 mHz'
sout1c         = ';;  '+gdupp0_str[0]+' of which have 500 mHz < f'
sout1d         = ';;  '+gdupp1_str[0]+' of which have 1000 mHz < f'
sout1e         = ';;  '+gdupp2_str[0]+' of which have 100 mHz < f'
sout2          = ';;  From a total of '+allmva_str[0]+' Total MVA Intervals Analyzed'
PRINT,''          & $
PRINT,sout[0]     & $
PRINT,sout1a[0]   & $
PRINT,sout1b[0]   & $
PRINT,sout1c[0]   & $
PRINT,sout1d[0]   & $
PRINT,sout1e[0]   & $
PRINT,sout2[0]    & $
PRINT,''

;;  001996 of 002189 Total Good MVA Intervals for Wind IP Shocks
;;  000275 of which have f ≤ 100 mHz
;;  000894 of which have 100 mHz < f ≤ 500 mHz
;;  000827 of which have 500 mHz < f
;;  000371 of which have 1000 mHz < f
;;  001721 of which have 100 mHz < f
;;  From a total of 08790035 Total MVA Intervals Analyzed

;;----------------------------------------------------------------------------------------
;;  Define wave normal angles
;;----------------------------------------------------------------------------------------
;;  Define unit vectors
kvecsu         = unit_vec(kvecs)
;;  Force angles:  0 ≤ ø ≤ 90
thetakb_lowf   = theta_kb[good_lowf] < (18d1 - theta_kb[good_lowf])
thetakb_midf   = theta_kb[good_midf] < (18d1 - theta_kb[good_midf])
thetakb_upp0   = theta_kb[good_upp0] < (18d1 - theta_kb[good_upp0])
thetakb_upp1   = theta_kb[good_upp1] < (18d1 - theta_kb[good_upp1])
thetakb_upp2   = theta_kb[good_upp2] < (18d1 - theta_kb[good_upp2])

;;  theta_kb did not work for some reason --> calculate dot product here
bvecuup        = unit_vec(bvec_up)
k_dot_b        = my_dot_prod(kvecsu,bvecuup,/NOM)
theta2kb       = ACOS(k_dot_b)*18d1/!DPI
thetakb2lowf   = theta2kb[good_lowf] < (18d1 - theta2kb[good_lowf])
thetakb2midf   = theta2kb[good_midf] < (18d1 - theta2kb[good_midf])
thetakb2upp0   = theta2kb[good_upp0] < (18d1 - theta2kb[good_upp0])
thetakb2upp1   = theta2kb[good_upp1] < (18d1 - theta2kb[good_upp1])
thetakb2upp2   = theta2kb[good_upp2] < (18d1 - theta2kb[good_upp2])
;;  theta_kn did not work for some reason --> calculate dot product here
nvecuup        = unit_vec(nvec_up)
k_dot_n        = my_dot_prod(kvecsu,nvecuup,/NOM)
theta_kn       = ACOS(k_dot_n)*18d1/!DPI
;;  Define theta_kn by frequency
thetakn_lowf   = theta_kn[good_lowf] < (18d1 - theta_kn[good_lowf])
thetakn_midf   = theta_kn[good_midf] < (18d1 - theta_kn[good_midf])
thetakn_upp0   = theta_kn[good_upp0] < (18d1 - theta_kn[good_upp0])
thetakn_upp1   = theta_kn[good_upp1] < (18d1 - theta_kn[good_upp1])
thetakn_upp2   = theta_kn[good_upp2] < (18d1 - theta_kn[good_upp2])

;;----------------------------------------------------------------------------------------
;;  Define shock parameters
;;----------------------------------------------------------------------------------------
badcfaind      = WHERE(cfapreind LT 0,bdcfaind,COMPLEMENT=goodcfaind,NCOMPLEMENT=gdcfaind)
;;  Define theta_Bn [deg]
all_thbns      = thetbn_up[cfapreind]
;;  Define <Vsw>_up [km/s]
all_vi_up      = vi_gse_up[cfapreind,*]
all_vm_up      = mag__vec(all_vi_up,/NAN)
Vvecuup        = unit_vec(all_vi_up)
;;  Define <Ni>_up [cm^(-3)]
all_ni_up      = ni_avg_up[cfapreind]
;;  Define <|Bo|>_up [nT]
all_bm_up      = mag__vec(bvec_up,/NAN)


IF (bdcfaind[0] GT 0) THEN all_thbns[badcfaind] = d
IF (bdcfaind[0] GT 0) THEN Vvecuup[badcfaind,*] = d
IF (bdcfaind[0] GT 0) THEN all_vm_up[badcfaind] = d
;;  Define theta_kV [deg]
k_dot_V        = my_dot_prod(kvecsu,Vvecuup,/NOM)
theta_kV       = ACOS(k_dot_V)*18d1/!DPI
;;  Define theta_Bn by frequency
thetaBn_lowf   = all_thbns[good_lowf] < (18d1 - all_thbns[good_lowf])
thetaBn_midf   = all_thbns[good_midf] < (18d1 - all_thbns[good_midf])
thetaBn_upp0   = all_thbns[good_upp0] < (18d1 - all_thbns[good_upp0])
thetaBn_upp1   = all_thbns[good_upp1] < (18d1 - all_thbns[good_upp1])
thetaBn_upp2   = all_thbns[good_upp2] < (18d1 - all_thbns[good_upp2])
;;  Define theta_kV by frequency
thetakV_lowf   = theta_kV[good_lowf] < (18d1 - theta_kV[good_lowf])
thetakV_midf   = theta_kV[good_midf] < (18d1 - theta_kV[good_midf])
thetakV_upp0   = theta_kV[good_upp0] < (18d1 - theta_kV[good_upp0])
thetakV_upp1   = theta_kV[good_upp1] < (18d1 - theta_kV[good_upp1])
thetakV_upp2   = theta_kV[good_upp2] < (18d1 - theta_kV[good_upp2])
;;----------------------------------------------------------------------------------------
;;  Define wave normal angles relative to coplanarity plane
;;----------------------------------------------------------------------------------------
;;  k-latitude [deg, angle of k from <B>_up -- n plane]
n_cross_b      = my_crossp_2(nvecuup,bvecuup,/NOM)
norm2copl      = unit_vec(n_cross_b)
k_dot_n2c      = my_dot_prod(kvecsu,norm2copl,/NOM)
phi_00         = ACOS(k_dot_n)*18d1/!DPI
lat_k2cop      = 9d1 - phi_00

;;  Print stats
x              = lat_k2cop
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(lat_k2cop))]
PRINT,';;  k-vec latitude [deg] to coplanarity plane:  ',stats
;;  k-vec latitude [deg] to coplanarity plane:        -87.963733       86.565977      -1.6022893      -3.6604155       42.067355      0.89912967

x              = lat_k2cop[good_upp2]
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*gd_upp2[0])]
PRINT,';;  k-vec latitude [deg] to coplanarity plane:  ',stats
;;  100 mHz < f
;;  k-vec latitude [deg] to coplanarity plane:        -87.963733       86.565977      -1.1565313      -2.9052274       42.478256       1.0239441

lowthsh        = [5d0,10d0,15d0,20d0,25d0,30d0]
low_str        = num2int_str(lowthsh,NUM_CHAR=2)
x              = lat_k2cop[good_upp2]
nn             = gd_upp2[0]
FOR j=0L, N_ELEMENTS(lowthsh) - 1L DO BEGIN                              $
  good_upp       = WHERE(ABS(x) GE lowthsh[j],gd_upp)                  & $
  PRINT,';;'                                                           & $
  PRINT,';;  For k-vec latitude ≥ '+low_str[j]+' degrees'              & $
  PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*nn[0]))
;;
;;  For k-vec latitude ≥ 5 degrees
;;          1643       95.467751
;;
;;  For k-vec latitude ≥ 10 degrees
;;          1551       90.122022
;;
;;  For k-vec latitude ≥ 15 degrees
;;          1452       84.369553
;;
;;  For k-vec latitude ≥ 20 degrees
;;          1354       78.675189
;;
;;  For k-vec latitude ≥ 25 degrees
;;          1231       71.528181
;;
;;  For k-vec latitude ≥ 30 degrees
;;          1132       65.775712


;;  Vsw_up-latitude [deg, angle of <Vsw>_up from <B>_up -- n plane]
Vup_dot_n2c    = my_dot_prod(Vvecuup,norm2copl,/NOM)
phi_11         = ACOS(Vup_dot_n2c)*18d1/!DPI
lat_Vup2cop    = 9d1 - phi_11
;;  Print stats
x              = lat_Vup2cop[good_upp2]
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*gd_upp2[0])]
PRINT,';;  Vsw_up latitude [deg] to coplanarity plane:  ',stats
;;  Vsw_up latitude [deg] to coplanarity plane:        -42.036993       53.961262       1.4055518      -1.1464167       17.303111      0.41709383

x              = ABS(lat_Vup2cop[good_upp2])
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*gd_upp2[0])]
PRINT,';;  Vsw_up latitude [deg] to coplanarity plane:  ',stats
;;  Vsw_up latitude [deg] to coplanarity plane:      0.0093657978       53.961262       12.311114       9.5960683       12.236124      0.29495343


lowthsh        = [5d0,10d0,15d0,20d0,25d0,30d0]
low_str        = num2int_str(lowthsh,NUM_CHAR=2)
x              = lat_Vup2cop[good_upp2]
nn             = gd_upp2[0]
FOR j=0L, N_ELEMENTS(lowthsh) - 1L DO BEGIN                              $
  good_upp       = WHERE(ABS(x) GE lowthsh[j],gd_upp)                  & $
  PRINT,';;'                                                           & $
  PRINT,';;  For Vsw_up latitude ≥ '+low_str[j]+' degrees'             & $
  PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*nn[0]))
;;
;;  For Vsw_up latitude ≥ 5 degrees
;;          1126       65.427077
;;
;;  For Vsw_up latitude ≥ 10 degrees
;;           744       43.230680
;;
;;  For Vsw_up latitude ≥ 15 degrees
;;           485       28.181290
;;
;;  For Vsw_up latitude ≥ 20 degrees
;;           263       15.281813
;;
;;  For Vsw_up latitude ≥ 25 degrees
;;           189       10.981987
;;
;;  For Vsw_up latitude ≥ 30 degrees
;;           163       9.4712377


wi,1
LOADCT,39
;;  Plot latitude vs. angles
xdata          = thetaBn_upp2
ydata          = ABS(lat_k2cop[good_upp2])
xyran          = [0d0,9d1]
xttl           = 'Theta_Bn [deg]'
yttl           = 'k-Latitude [deg from coplanarity plane]'
pstr           = {XRANGE:xyran,YRANGE:xyran,XSTYLE:1,YSTYLE:1,XTITLE:xttl,YTITLE:yttl,NODATA:1}

WSET,1
WSHOW,1
PLOT,xdata,ydata,_EXTRA=pstr
  OPLOT,xdata,ydata,PSYM=4,COLOR=50


;;  Use ranges for uncertainties
t_ind          = cfapreind[good_upp2]
unq            = UNIQ(t_ind,SORT(t_ind))
n_unq          = N_ELEMENTS(unq)
gxdat          = REPLICATE(d,n_unq[0])
gydat          = REPLICATE(d,n_unq[0])
gdydt          = REPLICATE(d,n_unq[0],2L)
ydata          = ABS(lat_k2cop[good_upp2])
FOR j=0L, n_unq[0] - 1L DO BEGIN                                                   $
  k = unq[j]                                                                     & $
  IF (t_ind[k] LT 0) THEN CONTINUE                                               & $
  temp     = t_ind[k]                                                            & $
  goodt    = WHERE(t_ind EQ temp[0],gdt,COMPLEMENT=badt,NCOMPLEMENT=bdt)         & $
  IF (gdt[0] GT 0) THEN temp1 = ydata[goodt] ELSE temp1 = REPLICATE(d,3L)        & $
  gydat[j] = MEAN(temp1,/NAN)                                                    & $
  gdydt[j,0] = MIN(temp1,/NAN)                                                   & $
  gdydt[j,1] = MAX(temp1,/NAN)


xyran          = [0d0,9d1]
xttl           = 'Theta_Bn [deg]'
yttl           = 'k-Latitude [deg from coplanarity plane]'
pstr           = {XRANGE:xyran,YRANGE:xyran,XSTYLE:1,YSTYLE:1,XTITLE:xttl,YTITLE:yttl,NODATA:1}
gxdat          = thetaBn_upp2[unq]
WSET,1
WSHOW,1
PLOT,gxdat,gydat,_EXTRA=pstr,CHARSIZE=2
  OPLOT,gxdat,gydat,PSYM=6,COLOR=50,SYMSIZE=2
  ERRPLOT,gxdat,gdydt[*,0],gdydt[*,1],WIDTH=1d-2,/DATA,SYMSIZE=2


gxdat          = thetakV_upp2[unq]
xttl           = 'Theta_kV [deg]'
pstr           = {XRANGE:xyran,YRANGE:xyran,XSTYLE:1,YSTYLE:1,XTITLE:xttl,YTITLE:yttl,NODATA:1}
WSET,1
WSHOW,1
PLOT,gxdat,gydat,_EXTRA=pstr,CHARSIZE=2
  OPLOT,gxdat,gydat,PSYM=6,COLOR=50,SYMSIZE=2
  ERRPLOT,gxdat,gdydt[*,0],gdydt[*,1],WIDTH=1d-2,/DATA,SYMSIZE=2


;;  Plot histogram of k-latitude
xttl           = 'k-Latitude [deg from coplanarity plane]'
ttle           = 'Wave Vector Latitude from Coplanarity Plane'
data           = ABS(lat_k2cop[good_upp2])
xran           = [0d0,9d1]
nbins          = 10L
WSET,1
WSHOW,1
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

popen_str      = {LANDSCAPE:1,UNITS:'inches',XSIZE:10.75,YSIZE:8.25}
fnamelat       = STRUPCASE(scpref[0])+'All_Precursor_Ints_WaveVector_Latitudes_MultiFreqFilt'
freq_fsuffs    = ['FreqLE100mHz','100mHzGTFreqLE500mHz','500mHzGTFreq','1000mHzGTFreq','100mHzGTFreq']
freq_tsuffs    = ' ['+['f < 100 mHz','100 mHz < f < 500 mHz','500 mHz < f','1000 mHz < f','100 mHz < f']+']'

fname          = fnamelat[0]+'_'+freq_fsuffs[4]+'_clean_histogram'
ymax_cnt       = 40d1
ymax_prc       = 25d0
popen,fname[0],_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose


;;----------------------------------------------------------------------------------------
;;  Print wave polarization stats
;;----------------------------------------------------------------------------------------
r_handed       = righthand[good_upp2]
good_rh        = WHERE(r_handed GT 0,gd_rh)
good_lh        = WHERE(r_handed EQ 0,gd_lh)
bad_pol        = WHERE(r_handed LT 0,bd_pl)
PRINT,';;  ',gd_rh[0],gd_lh[0],bd_pl[0]                                          & $
PRINT,';;  ',1d2*[gd_rh[0],gd_lh[0],bd_pl[0]]/(1d0*gd_upp2[0])
;;  100 mHz < f
;;          1256         465           0
;;         72.980825       27.019175       0.0000000

flow_upp2      = f_lower[good_upp2]
fupp_upp2      = f_upper[good_upp2]
favg_upp2      = (flow_upp2 + fupp_upp2)/2d0

favg_upp2_rh   = favg_upp2[good_rh]
favg_upp2_lh   = favg_upp2[good_lh]

x              = favg_upp2_rh                                                                                            & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]  & $
PRINT,';;  fsc [Hz, RH Pol. Only]:  ',statx                                                                              & $
y              = favg_upp2_lh                                                                                            & $
staty          = [MIN(y,/NAN),MAX(y,/NAN),MEAN(y,/NAN),MEDIAN(y),STDDEV(y,/NAN),STDDEV(y,/NAN)/SQRT(1d0*N_ELEMENTS(y))]  & $
PRINT,';;  fsc [Hz, LH Pol. Only]:  ',staty
;;  fsc [Hz, RH Pol. Only]:        0.16500000       5.0000000       1.1408937      0.82500000      0.90203815     0.025452479
;;  fsc [Hz, LH Pol. Only]:        0.16500000       4.0000000      0.98447312      0.67500000      0.78989912     0.036630694

x              = thetakV_upp2[good_rh]                                                                                   & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]  & $
PRINT,';;  theta_kV [deg, RH Pol. Only]:  ',statx                                                                        & $
y              = thetakV_upp2[good_lh]                                                                                   & $
staty          = [MIN(y,/NAN),MAX(y,/NAN),MEAN(y,/NAN),MEDIAN(y),STDDEV(y,/NAN),STDDEV(y,/NAN)/SQRT(1d0*N_ELEMENTS(y))]  & $
PRINT,';;  theta_kV [deg, LH Pol. Only]:  ',staty
;;  theta_kV [deg, RH Pol. Only]:         1.7550525       89.850573       52.488209       52.673883       19.415100      0.54782875
;;  theta_kV [deg, LH Pol. Only]:         1.8226451       89.604809       52.538454       52.103959       22.171471       1.0281774

x              = (theta_kV[good_upp2])[good_rh]                                                                          & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]  & $
PRINT,';;  theta_kV [deg, RH Pol. Only]:  ',statx                                                                        & $
y              = (theta_kV[good_upp2])[good_lh]                                                                          & $
staty          = [MIN(y,/NAN),MAX(y,/NAN),MEAN(y,/NAN),MEDIAN(y),STDDEV(y,/NAN),STDDEV(y,/NAN)/SQRT(1d0*N_ELEMENTS(y))]  & $
PRINT,';;  theta_kV [deg, LH Pol. Only]:  ',staty
;;  theta_kV [deg, RH Pol. Only]:         2.5326966       178.24495       91.005927       92.041529       42.239662       1.1918610
;;  theta_kV [deg, LH Pol. Only]:         5.0620798       178.17735       89.964073       88.473741       43.565638       2.0203081


xran           = [0e0,6e0]
dth_kba        = 2e-1
hist_fau2rh    = HISTOGRAM(favg_upp2_rh,BINSIZE=dth_kba[0],LOCATIONS=locs_frh,MAX= xran[1],MIN=xran[0],/NAN)
hist_fau2lh    = HISTOGRAM(favg_upp2_lh,BINSIZE=dth_kba[0],LOCATIONS=locs_flh,MAX= xran[1],MIN=xran[0],/NAN)
yranrh         = [1d0,(1.05*MAX(ABS(hist_fau2rh),/NAN)) > 2d2]
yranlh         = [1d0,(1.05*MAX(ABS(hist_fau2lh),/NAN)) > 2d2]
yran           = [1d0,(MAX(yranrh,/NAN) > MAX(yranlh,/NAN))]

xttl           = 'f_sc [Hz, Avg. of bandpass range]'
yttl           = 'counts'
pstr           = {XRANGE:xran,YRANGE:yran,XSTYLE:1,YSTYLE:1,XTITLE:xttl,YTITLE:yttl,NODATA:1}
xdatr          = locs_frh
xdatl          = locs_flh
ydatr          = hist_fau2rh
ydatl          = hist_fau2lh
WSET,1
WSHOW,1
PLOT,xdatr,ydatr,_EXTRA=pstr,PSYM=10
  OPLOT,xdatr,ydatr,PSYM=10,COLOR=250
  OPLOT,xdatl,ydatl,PSYM=10,COLOR= 50



xran           = [0e0,9e1]
dth_kba        = 25e-1
hist_thkVrh    = HISTOGRAM(thetakV_upp2[good_rh],BINSIZE=dth_kba[0],LOCATIONS=locs_kvrh,MAX= xran[1],MIN=xran[0],/NAN)
hist_thkVlh    = HISTOGRAM(thetakV_upp2[good_lh],BINSIZE=dth_kba[0],LOCATIONS=locs_kvlh,MAX= xran[1],MIN=xran[0],/NAN)
yranrh         = [1d0,(1.05*MAX(ABS(hist_thkVrh),/NAN)) > 2d1]
yranlh         = [1d0,(1.05*MAX(ABS(hist_thkVlh),/NAN)) > 2d1]
yran           = [1d0,(MAX(yranrh,/NAN) > MAX(yranlh,/NAN))]
xttl           = 'theta_kV [deg, Red = LH, Blue = RH]'
yttl           = 'counts'
pstr           = {XRANGE:xran,YRANGE:yran,XSTYLE:1,YSTYLE:1,XTITLE:xttl,YTITLE:yttl,NODATA:1}
xdatr          = locs_kvrh
xdatl          = locs_kvlh
ydatr          = hist_thkVrh
ydatl          = hist_thkVlh
WSET,1
WSHOW,1
PLOT,xdatr,ydatr,_EXTRA=pstr,PSYM=10
  OPLOT,xdatr,ydatr,PSYM=10,COLOR= 50
  OPLOT,xdatl,ydatl,PSYM=10,COLOR=250

;;  Plot histogram of theta_kV
xttl           = 'theta_kV [deg, All]'
ttle           = 'Wave Normal Angle from Vsw_up'
data           = thetakV_upp2
xran           = [0d0,9d1]
nbins          = 10L
WSET,1
WSHOW,1
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1


xttl           = 'theta_kV [deg, RH-Only]'
ttle           = 'Wave Normal Angle from Vsw_up'
data           = thetakV_upp2[good_rh]
xran           = [0d0,9d1]
nbins          = 10L
WSET,1
WSHOW,1
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

xttl           = 'theta_kV [deg, LH-Only]'
ttle           = 'Wave Normal Angle from Vsw_up'
data           = thetakV_upp2[good_lh]
xran           = [0d0,9d1]
nbins          = 10L
WSET,1
WSHOW,1
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1


;;----------------------------------------------------------------------------------------
;;  Print MVA stats
;;----------------------------------------------------------------------------------------
x              = 1d0*cnt_by_date
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nprec[0])]
PRINT,';;  Good MVA Int. Stats:  ',stats
;;  Good MVA Int. Stats:         0.0000000       133.00000       17.663717       13.000000       19.943049       1.8760842

good_x         = WHERE(cnt_by_date GT 0,gd_x)
y              = x[good_x]
stats          = [MIN(y,/NAN),MAX(y,/NAN),MEAN(y,/NAN),MEDIAN(y),STDDEV(y,/NAN),STDDEV(y,/NAN)/SQRT(1d0*gd_x[0])]
PRINT,';;  Good MVA Int. Stats (Finite Only):  ',stats
;;  Good MVA Int. Stats (Finite Only):         1.0000000       133.00000       17.821429       13.000000       19.961772       1.8862101

lowthsh        = [2d0,3d0,4d0,11d0,15d0,20d0,30d0]
low_str        = num2int_str(lowthsh,NUM_CHAR=2)
x              = cnt_by_date
nn             = nprec[0]
FOR j=0L, N_ELEMENTS(lowthsh) - 1L DO BEGIN                             $
  good_upp       = WHERE(x GE lowthsh[j],gd_upp)                      & $
  PRINT,';;'                                                          & $
  PRINT,';;  For # ≥ '+low_str[j]+' MVA subintervals per date'        & $
  PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*nn[0]))
;;
;;  For # ≥ 2 MVA subintervals per date
;;           107       94.690265
;;
;;  For # ≥ 3 MVA subintervals per date
;;           104       92.035398
;;
;;  For # ≥ 4 MVA subintervals per date
;;            97       85.840708
;;
;;  For # ≥ 11 MVA subintervals per date
;;            62       54.867257
;;
;;  For # ≥ 15 MVA subintervals per date
;;            48       42.477876
;;
;;  For # ≥ 20 MVA subintervals per date
;;            36       31.858407
;;
;;  For # ≥ 30 MVA subintervals per date
;;            16       14.159292

uppthsh        = [0d0,2d0,5d0,10d0,15d0,20d0]
uppth22        = [-1d0,0d0,0d0,0d0,0d0,0d0]
upp_str        = num2int_str(uppthsh,NUM_CHAR=2)
FOR j=0L, N_ELEMENTS(uppthsh) - 1L DO BEGIN                             $
  good_low       = WHERE(x LE uppthsh[j] AND x GT uppth22[j],gd_low)  & $
  PRINT,';;'                                                          & $
  PRINT,';;  For # ≤ '+upp_str[j]+' MVA subintervals per date'        & $
  PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*nn[0]))
;;
;;  For # ≤ 0 MVA subintervals per date
;;             1      0.88495575
;;
;;  For # ≤ 2 MVA subintervals per date
;;             8       7.0796460
;;
;;  For # ≤ 5 MVA subintervals per date
;;            25       22.123894
;;
;;  For # ≤ 10 MVA subintervals per date
;;            50       44.247788
;;
;;  For # ≤ 15 MVA subintervals per date
;;            66       58.407080
;;
;;  For # ≤ 20 MVA subintervals per date
;;            78       69.026549


;;----------------------------------------------------------------------------------------
;;  Print wave amplitude stats
;;----------------------------------------------------------------------------------------
line0          = [';;  f ≤ 100 mHz',';;  100 mHz < f ≤ 500 mHz',';;  500 mHz < f',';;  1000 mHz < f',';;  100 mHz < f']
good_th        = WHERE(FINITE(thetakb_lowf),gd_th)
good_th        = WHERE(FINITE(thetakb_midf),gd_th)
good_th        = WHERE(FINITE(thetakb_upp0),gd_th)
good_th        = WHERE(FINITE(thetakb_upp1),gd_th)
good_th        = WHERE(FINITE(thetakb_upp2),gd_th)

line           = line0[0]
line           = line0[1]
line           = line0[2]
line           = line0[3]
line           = line0[4]

good_wamps     = wave_amp[good_th,*]
PRINT,line[0]                                                                                                       & $
x              = good_wamps[*,0]                                                                                    & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*gd_th[0])]  & $
PRINT,';;  ∂B_min [nT]:  ',stats                                                                                    & $
x              = good_wamps[*,1]                                                                                    & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*gd_th[0])]  & $
PRINT,';;  ∂B_mid [nT]:  ',stats                                                                                    & $
x              = good_wamps[*,2]                                                                                    & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*gd_th[0])]  & $
PRINT,';;  ∂B_max [nT]:  ',stats                                                                                    & $
x              = good_wamps[*,3]                                                                                    & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*gd_th[0])]  & $
PRINT,';;  |∂B| [nT]:  ',stats
;;  f ≤ 100 mHz
;;  ∂B_min [nT]:     3.1013065e-05      0.87529571     0.027744367    0.0086176374     0.074344333    0.0044831320
;;  ∂B_mid [nT]:       0.031007707       6.1968367      0.43114912      0.19824460      0.73862723     0.044540898
;;  ∂B_max [nT]:       0.050494416       7.8347084      0.50803050      0.26285871      0.85669352     0.051660563
;;  |∂B| [nT]:       0.031921112       5.0567051      0.31387601      0.15246653      0.54136779     0.032645706
;;
;;  100 mHz < f ≤ 500 mHz
;;  ∂B_min [nT]:     3.0760241e-05      0.87529571     0.016769899    0.0056731394     0.045719860    0.0015291009
;;  ∂B_mid [nT]:       0.031007707       6.1968367      0.28705284      0.14007160      0.48681423     0.016281503
;;  ∂B_max [nT]:       0.048164282       7.8347084      0.35410127      0.18328100      0.57276880     0.019156254
;;  |∂B| [nT]:       0.029851598       5.0567051      0.22350419      0.11614007      0.36330578     0.012150763
;;
;;  500 mHz < f
;;  ∂B_min [nT]:     3.0760241e-05      0.87529571     0.017259485    0.0057307668     0.047171663    0.0016413121
;;  ∂B_mid [nT]:       0.031007707       6.1968367      0.29722942      0.14414050      0.50258224     0.017487073
;;  ∂B_max [nT]:       0.048164282       7.8347084      0.36523472      0.18669342      0.59184086     0.020592777
;;  |∂B| [nT]:       0.029851598       5.0567051      0.23012984      0.11762465      0.37573901     0.013073632
;;
;;  1000 mHz < f
;;  ∂B_min [nT]:     3.1013065e-05      0.87529571     0.023580118    0.0061372297     0.066339483    0.0034488255
;;  ∂B_mid [nT]:       0.031007707       6.1968367      0.39850120      0.19161901      0.67542026     0.035113427
;;  ∂B_max [nT]:       0.048164282       7.8347084      0.47266257      0.24055766      0.78248067     0.040679233
;;  |∂B| [nT]:       0.031921112       5.0567051      0.29186357      0.15020419      0.49232803     0.025594915
;;
;;  100 mHz < f
;;  ∂B_min [nT]:     1.1595208e-05      0.87529571     0.012702708    0.0034569239     0.035998762   0.00086800722
;;  ∂B_mid [nT]:       0.028850230       6.1968367      0.23336270      0.11709646      0.39776960    0.0095910768
;;  ∂B_max [nT]:       0.046526427       7.8347084      0.28984672      0.15298777      0.46933618     0.011316700
;;  |∂B| [nT]:       0.029280894       5.0567051      0.18258250     0.098170990      0.29804988    0.0071866208

;;----------------------------------------------------------------------------------------
;;  Print theta_kB stats
;;----------------------------------------------------------------------------------------
x              = thetakb_lowf                                                                                    & $
nn             = gd_lowf[0]                                                                                      & $
PRINT,';;'                                                                                                       & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  f ≤ 100 mHz'                                                                                          & $
PRINT,';;  theta_kB [deg]:  ',stats                                                                              & $
x              = thetakb_midf                                                                                    & $
nn             = gd_midf[0]                                                                                      & $
PRINT,';;'                                                                                                       & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  100 mHz < f ≤ 500 mHz'                                                                                & $
PRINT,';;  theta_kB [deg]:  ',stats                                                                              & $
x              = thetakb_upp0                                                                                    & $
nn             = gd_upp0[0]                                                                                      & $
PRINT,';;'                                                                                                       & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  500 mHz < f'                                                                                          & $
PRINT,';;  theta_kB [deg]:  ',stats                                                                              & $
x              = thetakb_upp1                                                                                    & $
nn             = gd_upp1[0]                                                                                      & $
PRINT,';;'                                                                                                       & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  1000 mHz < f'                                                                                         & $
PRINT,';;  theta_kB [deg]:  ',stats                                                                              & $
x              = thetakb_upp2                                                                                    & $
nn             = gd_upp2[0]                                                                                      & $
PRINT,';;'                                                                                                       & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  100 mHz < f'                                                                                          & $
PRINT,';;  theta_kB [deg]:  ',stats
;;  f ≤ 100 mHz
;;  theta_kB [deg]:         4.0895447       89.345013       51.134521       53.521992       22.147042       1.3355169
;;
;;  100 mHz < f ≤ 500 mHz
;;  theta_kB [deg]:         3.7013590       89.949911       54.601561       56.529332       20.733309      0.69342559
;;
;;  500 mHz < f
;;  theta_kB [deg]:         3.8342233       89.771567       54.885818       57.924169       22.181139      0.77131377
;;
;;  1000 mHz < f
;;  theta_kB [deg]:         5.9032185       89.737894       58.672239       63.536469       22.221127       1.1536634
;;
;;  100 mHz < f
;;  theta_kB [deg]:         3.7013590       89.949911       54.738071       57.332241       21.435009      0.51669379

x              = thetakb2lowf                                                                                    & $
nn             = gd_lowf[0]                                                                                      & $
PRINT,';;'                                                                                                       & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  f ≤ 100 mHz'                                                                                          & $
PRINT,';;  theta_kB [deg]:  ',stats                                                                              & $
x              = thetakb2midf                                                                                    & $
nn             = gd_midf[0]                                                                                      & $
PRINT,';;'                                                                                                       & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  100 mHz < f ≤ 500 mHz'                                                                                & $
PRINT,';;  theta_kB [deg]:  ',stats                                                                              & $
x              = thetakb2upp0                                                                                    & $
nn             = gd_upp0[0]                                                                                      & $
PRINT,';;'                                                                                                       & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  500 mHz < f'                                                                                          & $
PRINT,';;  theta_kB [deg]:  ',stats                                                                              & $
x              = thetakb2upp1                                                                                    & $
nn             = gd_upp1[0]                                                                                      & $
PRINT,';;'                                                                                                       & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  1000 mHz < f'                                                                                         & $
PRINT,';;  theta_kB [deg]:  ',stats                                                                              & $
PRINT,';;'                                                                                                       & $
x              = thetakb2upp2                                                                                    & $
nn             = gd_upp2[0]                                                                                      & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  100 mHz < f'                                                                                          & $
PRINT,';;  theta_kB [deg]:  ',stats
;;  f ≤ 100 mHz
;;  theta_kB [deg]:         1.7909160       89.623112       35.449751       28.078873       24.750863       1.4925332
;;
;;  100 mHz < f ≤ 500 mHz
;;  theta_kB [deg]:        0.92168484       89.829676       36.425446       29.921425       25.294522      0.84597536
;;
;;  500 mHz < f
;;  theta_kB [deg]:        0.93966920       89.962623       36.764958       33.842611       23.789098      0.82722798
;;
;;  1000 mHz < f
;;  theta_kB [deg]:         4.0919958       89.962623       40.637937       38.286154       21.361753       1.1090470
;;
;;  100 mHz < f
;;  theta_kB [deg]:        0.92168484       89.962623       36.588594       31.554624       24.576095      0.59241009

line0          = [';;  f ≤ 100 mHz',';;  100 mHz < f ≤ 500 mHz',';;  500 mHz < f',';;  1000 mHz < f',';;  100 mHz < f']
uppthsh        = [30d0,45d0]
lowthsh        = uppthsh
low_str        = num2int_str(lowthsh,NUM_CHAR=2)
x              = thetakb2upp2
nn             = gd_upp2[0]
FOR j=0L, 1L DO BEGIN                                                   $
  good_low       = WHERE(x LE uppthsh[j],gd_low)                      & $
  good_upp       = WHERE(x GE lowthsh[j],gd_upp)                      & $
  PRINT,';;'                                                          & $
  PRINT,line0[4]                                                      & $
  PRINT,';;  For theta_kB ≤ '+low_str[j]+' deg'                       & $
  PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*nn[0]))                  & $
  PRINT,';;  For theta_kB ≥ '+low_str[j]+' deg'                       & $
  PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*nn[0]))
;;
;;  100 mHz < f
;;  For theta_kB ≤ 30 deg
;;           822       47.762929
;;  For theta_kB ≥ 30 deg
;;           899       52.237071
;;
;;  100 mHz < f
;;  For theta_kB ≤ 45 deg
;;          1133       65.833818
;;  For theta_kB ≥ 45 deg
;;           588       34.166182


;;----------------------------------------------------------------------------------------
;;  Print theta_kn stats
;;----------------------------------------------------------------------------------------
x              = thetakn_lowf                                                                                    & $
nn             = gd_lowf[0]                                                                                      & $
PRINT,';;'                                                                                                       & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  f ≤ 100 mHz'                                                                                          & $
PRINT,';;  theta_kn [deg]:  ',stats                                                                              & $
x              = thetakn_midf                                                                                    & $
nn             = gd_midf[0]                                                                                      & $
PRINT,';;'                                                                                                       & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  100 mHz < f ≤ 500 mHz'                                                                                & $
PRINT,';;  theta_kn [deg]:  ',stats                                                                              & $
x              = thetakn_upp0                                                                                    & $
nn             = gd_upp0[0]                                                                                      & $
PRINT,';;'                                                                                                       & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  500 mHz < f'                                                                                          & $
PRINT,';;  theta_kn [deg]:  ',stats                                                                              & $
x              = thetakn_upp1                                                                                    & $
nn             = gd_upp1[0]                                                                                      & $
PRINT,';;'                                                                                                       & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  1000 mHz < f'                                                                                         & $
PRINT,';;  theta_kn [deg]:  ',stats                                                                              & $
x              = thetakn_upp2                                                                                    & $
nn             = gd_upp2[0]                                                                                      & $
PRINT,';;'                                                                                                       & $
stats          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*nn[0])]  & $
PRINT,';;  100 mHz < f'                                                                                          & $
PRINT,';;  theta_kn [deg]:  ',stats
;;  f ≤ 100 mHz
;;  theta_kn [deg]:         6.3231412       89.578971       55.463488       54.116042       19.267148       1.1618528
;;
;;  100 mHz < f ≤ 500 mHz
;;  theta_kn [deg]:         2.0362670       89.986043       53.627661       53.614100       19.578728      0.65481062
;;
;;  500 mHz < f
;;  theta_kn [deg]:         3.6220880       89.544411       50.839748       49.661659       19.454519      0.67649989
;;
;;  1000 mHz < f
;;  theta_kn [deg]:         3.6220880       88.939399       50.739765       49.909097       20.790307       1.0793790

line0          = [';;  f ≤ 100 mHz',';;  100 mHz < f ≤ 500 mHz',';;  500 mHz < f',';;  1000 mHz < f',';;  100 mHz < f']
uppthsh        = [30d0,45d0]
lowthsh        = uppthsh
low_str        = num2int_str(lowthsh,NUM_CHAR=2)
x              = thetakn_upp2
nn             = gd_upp2[0]
FOR j=0L, 1L DO BEGIN                                                   $
  good_low       = WHERE(x LE uppthsh[j],gd_low)                      & $
  good_upp       = WHERE(x GE lowthsh[j],gd_upp)                      & $
  PRINT,';;'                                                          & $
  PRINT,line0[4]                                                      & $
  PRINT,';;  For theta_kn ≤ '+low_str[j]+' deg'                       & $
  PRINT,';;  ',gd_low[0],(1d2*gd_low[0]/(1d0*nn[0]))                  & $
  PRINT,';;  For theta_kn ≥ '+low_str[j]+' deg'                       & $
  PRINT,';;  ',gd_upp[0],(1d2*gd_upp[0]/(1d0*nn[0]))
;;
;;  100 mHz < f
;;  For theta_kn ≤ 30 deg
;;           226       13.131900
;;  For theta_kn ≥ 30 deg
;;          1495       86.868100
;;
;;  100 mHz < f
;;  For theta_kn ≤ 45 deg
;;           631       36.664730
;;  For theta_kn ≥ 45 deg
;;          1090       63.335270

;;----------------------------------------------------------------------------------------
;;  Plot results
;;----------------------------------------------------------------------------------------
wi,1
wi,2
wi,3
wi,4
popen_str      = {LANDSCAPE:1,UNITS:'inches',XSIZE:10.75,YSIZE:8.25}
LOADCT,39
;;  Define plot labels
yttl0          = 'Number of Events'
yttl1          = 'Percentage of Events'
xttlb          = 'Wave Normal Angle [deg, theta_kB]'
xttln          = 'Wave Normal Angle [deg, theta_kn]'
titleb         = 'Wave Normal Angle:  (k . <Bo>_up)'
titlen         = 'Wave Normal Angle:  (k . n_sh)'
xran           = [0d0,9d1]
nbins          = 10L

;;  Plot theta_kB angles
xttl           = xttlb[0]
ttle           = titleb[0]

data           = thetakb_lowf
WSET,1
WSHOW,1
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

data           = thetakb_midf
WSET,2
WSHOW,2
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

data           = thetakb_upp0
WSET,3
WSHOW,3
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

data           = thetakb_upp1
WSET,4
WSHOW,4
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

data           = thetakb_upp2
WSET,1
WSHOW,1
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

;;  theta_kB2
xttl           = xttlb[0]
ttle           = titleb[0]

data           = thetakb2lowf
WSET,1
WSHOW,1
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

data           = thetakb2midf
WSET,2
WSHOW,2
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

data           = thetakb2upp0
WSET,3
WSHOW,3
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

data           = thetakb2upp1
WSET,4
WSHOW,4
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

data           = thetakb2upp2
WSET,1
WSHOW,1
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1


;;  Plot theta_kn angles
xttl           = xttln[0]
ttle           = titlen[0]

data           = thetakn_lowf
WSET,1
WSHOW,1
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

data           = thetakn_midf
WSET,2
WSHOW,2
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

data           = thetakn_upp0
WSET,3
WSHOW,3
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

data           = thetakn_upp1
WSET,4
WSHOW,4
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

data           = thetakn_upp2
WSET,1
WSHOW,1
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1

;;----------------------------------------------------------------------------------------
;;  Save results
;;----------------------------------------------------------------------------------------
fnameb         = STRUPCASE(scpref[0])+'All_Precursor_Ints_Wave_Normal_Angles_Bup_MultiFreqFilt'
fnamen         = STRUPCASE(scpref[0])+'All_Precursor_Ints_Wave_Normal_Angles_nsh_MultiFreqFilt'
freq_fsuffs    = ['FreqLE100mHz','100mHzGTFreqLE500mHz','500mHzGTFreq','1000mHzGTFreq','100mHzGTFreq']
freq_tsuffs    = ' ['+['f < 100 mHz','100 mHz < f < 500 mHz','500 mHz < f','1000 mHz < f','100 mHz < f']+']'

;;  Plot theta_kB angles
xttl           = xttlb[0]
ttl0           = titleb[0]

ttle           = ttl0[0]+freq_tsuffs[0]
fname          = fnameb[0]+'_'+freq_fsuffs[0]+'_clean_histogram'
data           = thetakb2lowf
ymax_cnt       = 70d0
ymax_prc       = 25d0
popen,fname[0],_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose

ttle           = ttl0[0]+freq_tsuffs[1]
fname          = fnameb[0]+'_'+freq_fsuffs[1]+'_clean_histogram'
data           = thetakb2midf
ymax_cnt       = 20d1
ymax_prc       = 25d0
popen,fname[0],_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose

ttle           = ttl0[0]+freq_tsuffs[2]
fname          = fnameb[0]+'_'+freq_fsuffs[2]+'_clean_histogram'
data           = thetakb2upp0
ymax_cnt       = 18d1
ymax_prc       = 20d0
popen,fname[0],_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose

ttle           = ttl0[0]+freq_tsuffs[3]
fname          = fnameb[0]+'_'+freq_fsuffs[3]+'_clean_histogram'
data           = thetakb2upp1
ymax_cnt       = 10d1
ymax_prc       = 25d0
popen,fname[0],_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose

ttle           = ttl0[0]+freq_tsuffs[4]
fname          = fnameb[0]+'_'+freq_fsuffs[4]+'_clean_histogram'
data           = thetakb2upp2
ymax_cnt       = 40d1
ymax_prc       = 25d0
popen,fname[0],_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose


;;  Plot theta_kn angles
xttl           = xttln[0]
ttl0           = titlen[0]

ttle           = ttl0[0]+freq_tsuffs[0]
fname          = fnamen[0]+'_'+freq_fsuffs[0]+'_clean_histogram'
data           = thetakn_lowf
ymax_cnt       = 60d0
ymax_prc       = 25d0
popen,fname[0],_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose

ttle           = ttl0[0]+freq_tsuffs[1]
fname          = fnamen[0]+'_'+freq_fsuffs[1]+'_clean_histogram'
data           = thetakn_midf
ymax_cnt       = 20d1
ymax_prc       = 25d0
popen,fname[0],_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose

ttle           = ttl0[0]+freq_tsuffs[2]
fname          = fnamen[0]+'_'+freq_fsuffs[2]+'_clean_histogram'
data           = thetakn_upp0
ymax_cnt       = 20d1
ymax_prc       = 25d0
popen,fname[0],_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose

ttle           = ttl0[0]+freq_tsuffs[3]
fname          = fnamen[0]+'_'+freq_fsuffs[3]+'_clean_histogram'
data           = thetakn_upp1
ymax_cnt       = 80d0
ymax_prc       = 20d0
popen,fname[0],_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose

ttle           = ttl0[0]+freq_tsuffs[4]
fname          = fnamen[0]+'_'+freq_fsuffs[4]+'_clean_histogram'
data           = thetakn_upp2
ymax_cnt       = 40d1
ymax_prc       = 25d0
popen,fname[0],_EXTRA=popen_str
  my_histogram_plot,data,NBINS=nbins,XTTL=xttl,TTLE=ttle,DRANGE=xran,PREC=0,BARCOLOR=1,YRANGEC=ymax_cnt,YRANGEP=ymax_prc
pclose


