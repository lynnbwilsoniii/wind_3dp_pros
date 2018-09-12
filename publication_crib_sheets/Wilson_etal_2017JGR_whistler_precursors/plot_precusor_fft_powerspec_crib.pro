;;  plot_precusor_fft_powerspec_crib.pro

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
pmulti         = [0,3,3,0,0]
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}
;;  Define save/setup stuff for TPLOT
popen_str      = {PORT:0,LANDSCAPE:1,UNITS:'inches',YSIZE:8.5,XSIZE:11}
;;  Define spacecraft-specific variables
sc             = 'Wind'
scpref         = sc[0]+'_'
;;  Define save directory
slash          = get_os_slash()           ;;  '/' for Unix, '\' for Windows
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'low_beta_Ma_whistlers'+slash[0]+'fft_plots'+slash[0]
FILE_MKDIR,sav_dir[0]
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
;;  Define file names
;;----------------------------------------------------------------------------------------
fpref          = sav_dir[0]+'Wind_'+inst_pref[0]
fsuff          = '_Bmag_Bvec-GSE_FFT_PowerSpec'
ftimes         = STRARR(nprec[0])                    ;; e.g., '2000-06-08_0705x58.886-0706x01.992'
fnm_st         = file_name_times(prec_st,PREC=3)
fnm_en         = file_name_times(prec_en,PREC=3)
ftimes         = fnm_st.F_TIME+'-'+STRMID(fnm_en.F_TIME,11L)
fnames         = fpref[0]+ftimes+fsuff[0]
;;----------------------------------------------------------------------------------------
;;  Define parameters for input extra structure
;;----------------------------------------------------------------------------------------
;;  Define frequencies and associated labels
op_freq_vals   = [0.12,0.15,1.2,1.5]
op_freq_labs   = ['120mHz','150mHz','1.2Hz','1.5Hz']
;;  Define settings and field params
rm_offsets     = 1b
field_name     = 'Bo'
field_unit     = 'nT'
inbasisnme     = 'GSE'
file_nm_pref   = 'Wind_'+inst_pref[0]+'Bmag_Bvec-GSE_FFT_PowerSpec'
;;  Define frequency params
low_freq       = 1e-1
high_freq      = 2e1
;;  Compile necessary routines
.compile $HOME/Desktop/temp_idl/temp_plot_field_raw_filt_powspec.pro
.compile $HOME/Desktop/low_beta_Ma_whistlers/crib_sheets/load_ip_shocks_mfi_split_magvec.pro
.compile $HOME/Desktop/low_beta_Ma_whistlers/crib_sheets/load_ip_shocks_mfi_filter.pro
;;  Define dummy variables
tshft_on       = 0b
unix           = 0d0
FOR kk=0L, nprec[0] - 1L DO BEGIN                                                                 $
  tr_load        = time_double(REFORM(tran_brsts[kk,*]))                                        & $   ;;  Define time range [Unix] to load into TPLOT
  tr_ww_pred     = time_double(REFORM(tran__subs[kk,*],1,2))                                    & $   ;;  Define precursor interval time ranges [string]
  diff           = ABS(tr_ww_pred[1] - tr_ww_pred[0])                                           & $
  IF (diff[0] LT 15d0) THEN delt = ABS(15d0 - diff[0]) ELSE delt = 0d0                          & $
  tr_ww_pred[0] -= delt[0]                                                                      & $
  fran_int       = [low_freq[0],high_freq[0]]                                                   & $
  load_ip_shocks_mfi_filter,TRANGE=tr_load,PRECISION=prec,FREQ_RANGE=fran_int,/NO_INS_NAN       & $
  dc_bfield_tpn  = tnames(mfi_filt_lp[0])                                                       & $   ;;  Define DC- and AC-Coupled field TPLOT handles
  ac_bfield_tpn  = tnames(mfi_filt_dettp[0])                                                    & $   ;;  Define DC- and AC-Coupled field TPLOT handles
  test           = (dc_bfield_tpn[0] EQ '') OR (ac_bfield_tpn[0] EQ '')                         & $
  IF (test[0]) THEN CONTINUE                                                                    & $   ;;  Add to structures for later to save
  get_data,mfi_gse_tpn[0],DATA=temp,DLIMIT=dlim,LIMIT=lim                                       & $
  IF (SIZE(temp,/TYPE) NE 8) THEN CONTINUE                                                      & $
  unix           = t_get_struc_unix(temp,TSHFT_ON=tshft_on)                                     & $
  srate0         = sample_rate(unix,/AVE,OUT_MED_AVG=medavg)                                    & $
  new_highf      = CEIL(medavg[0])                                                              & $
  struc          = {X:unix,Y:temp.Y}                                                            & $
  temp_plot_field_raw_filt_powspec,struc,TRANGE=tr_ww_pred,PREC=3,LOW_FREQ=low_freq[0],           $
              HIGHFREQ=new_highf[0],OP_FREQ_VALS=op_freq_vals,OP_FREQ_LABS=op_freq_labs,          $
              RM_OFFSETS=rm_offsets,FIELD_NAME=field_name[0],FIELD_UNITS=field_unit[0],           $
              IN_BASIS_NAME=inbasisnme[0],FILE_NM_PREF=file_nm_pref[0]





