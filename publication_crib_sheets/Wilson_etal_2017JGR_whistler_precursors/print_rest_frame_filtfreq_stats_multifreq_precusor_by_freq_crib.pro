;;  print_rest_frame_filtfreq_stats_multifreq_precusor_by_freq_crib.pro

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
;;----------------------------------------------------------------------------------------
;;  Get Precursor MVA Statistics
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/count_precusor_mva_stats_multifreq_batch.pro
;;----------------------------------------------------------------------------------------
;;  Get Precursor Filter Frequency Statistics
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/count_precusor_filter_stats_multifreq_batch.pro

;;  Print stats
PRINT,';;  Total # of Good Filters:  ',TOTAL(all_nfilt,/NAN)
;;  Total # of Good Filters:         332.00000

;;  Define only finite values
test           = FINITE(all_flower) AND FINITE(all_fupper)
good           = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
PRINT,';;',gd[0]
;;         332

PRINT,';;'                                                                                                                 & $
x              = all_flower[good]                                                                                          & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  f_lower [Hz, All]:  ',statx                                                                                     & $
PRINT,';;'                                                                                                                 & $
x              = all_fupper[good]                                                                                          & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  f_upper [Hz, All]:  ',statx
;;
;;  f_lower [Hz, All]:      0.0060000000       3.2000000      0.69381325      0.47000000      0.67964363     0.037300290
;;
;;  f_upper [Hz, All]:       0.034000000       7.0000000       1.4938855       1.0000000       1.3783060     0.075644370

;;  Limit to only those values > 100 mHz
test0          = FINITE(all_flower) AND FINITE(all_fupper)
test1          = (all_flower GT 1d-1)
good_100       = WHERE(test0 AND test1,gd_100)
PRINT,';;',gd_100[0]
;;         278


PRINT,';;'                                                                                                                 & $
x              = all_flower[good_100]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  f_lower [Hz, fsc_low > 100 mHz Only]:  ',statx                                                                  & $
PRINT,';;'                                                                                                                 & $
x              = all_fupper[good_100]                                                                                      & $
statx          = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),STDDEV(x,/NAN)/SQRT(1d0*N_ELEMENTS(x))]    & $
PRINT,';;  f_upper [Hz, fsc_low > 100 mHz Only]:  ',statx
;;
;;  f_lower [Hz, fsc_low > 100 mHz Only]:        0.11000000       3.2000000      0.81573741      0.60000000      0.67831144     0.040682416
;;
;;  f_upper [Hz, fsc_low > 100 mHz Only]:        0.20000000       7.0000000       1.7435612       1.2000000       1.3721821     0.082298012







