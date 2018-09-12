;;  plot_and_save_precusor_mva_multifreqfilt_crib.pro

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
                 'low_beta_Ma_whistlers'+slash[0]+'mva_multifreq_plots'+slash[0]
FILE_MKDIR,mva_dir[0]
inst_pref      = 'mfi_'
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
;;  Define file name and plot stuff
;;----------------------------------------------------------------------------------------
date_in_pre0   = 'EventDate_'+tdate_ramps
date_in_pre    = 'EventDate_'+tdate_ramps+'_'
date_mid_0     = 'Event Date: '+tdate_ramps
scpref0        = sc[0]
num_ip_str     = num2int_str(nprec[0],NUM_CHAR=3,/ZERO_PAD)

fname_suff     = 'Filtered_MultiFreq_MFI_MVA_Results.sav'
fname_prefs    = STRUPCASE(scpref[0])+date_in_pre+'_*'+fname_suff[0]             ;;  e.g., 'WIND_2015-10-16_*Filtered_MFI_MVA_Results.sav'
;;  Define tag prefixes
date_tpre      = 'DATE_'        ;;  Dates
iint_tpre      = 'INT_'         ;;  precursor time intervals for each date
fint_tpre      = 'FR_'          ;;  frequency range tags
num_strs       = num2int_str(LINDGEN(20),NUM_CHAR=3,/ZERO_PAD)
;;  Define date, precursor interval, and frequency tags
tdate_tags     = STRMID(tdate_ramps,0L,4L)+STRMID(tdate_ramps,5L,2L)+STRMID(tdate_ramps,8L,2L)
date_tags      = date_tpre[0]+tdate_tags
prec_tags      = iint_tpre[0]+'000'
freq_tags      = fint_tpre[0]+num_strs
;;  Define indices relative to CfA database
good           = good_y_all0
gd             = gd_y_all[0]
ind1           = good_A
ind2           = good_A[good_y_all0]      ;;  All "good" shocks with whistlers [indices for CfA arrays]
;;  Define upstream average vectors
bvecup         = bo_gse_up[ind2,*]
d_bvecup       = ABS(asy_info_str.MAGF_GSE.DY[ind2,*,0])
nvecup         = n_gse__up[ind2,*]
d_nvecup       = ABS(bvn_info_str.SH_N_GSE.DY[ind2,*])
;;  Plot and save
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/plot_and_save_precusor_mva_multifreqfilt_batch.pro

;;----------------------------------------------------------------------------------------
;;  Create IDL save file containing all "best" MVA results for all burst intervals
;;----------------------------------------------------------------------------------------
mva_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'mva_sav'+slash[0]
FILE_MKDIR,mva_dir[0]
fname_suff     = 'Filtered_MultiFreq_MFI_MVA_Results.sav'
fname_out      = STRUPCASE(scpref[0])+'All_'+num_ip_str[0]+'_Precursor_Ints_'+fname_suff[0]             ;;  e.g., 'WIND_All_113_Precursor_Ints_Filtered_MFI_OnlyBest_MVA_Results.sav'
test           = (SIZE(all___mva__res,/TYPE) EQ 8) AND (SIZE(all_polwav_res,/TYPE) EQ 8)
IF (test[0]) THEN SAVE,all___mva__res,best_subin_res,best__mva__res,all_polwav_res,FILENAME=mva_dir[0]+fname_out[0]






