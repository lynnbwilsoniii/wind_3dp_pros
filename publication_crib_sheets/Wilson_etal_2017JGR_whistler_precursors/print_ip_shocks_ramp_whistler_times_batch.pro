;;  @/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/print_ip_shocks_ramp_whistler_times_batch.pro

;;  Requires:  jj  :  Scalar [numeric]
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
all_labs       = ['x','y','z','mag']
all_cols       = [250,200,75,25]
vec_str        = ['x','y','z']
vec_col        = [250,150,50]
mfi_gse_tpn    = 'Wind_B_htr_gse'
mfi_mag_tpn    = 'Wind_B_htr_mag'
mfi_filt_tp    = 'highpass_Bo'
yttl_filt      = 'HPFilt. Bo [nT, GSE]'
yttl_bvec      = 'Bo [nT, GSE]'
yttl_bmag      = '|Bo| [nT]'
;;----------------------------------------------------------------------------------------
;;  Load MFI into TPLOT
;;----------------------------------------------------------------------------------------
nna            = tnames()
IF (nna[0] NE '') THEN store_data,DELETE=nna  ;;  Make sure nothing is already loaded

ii             = good[jj[0]]
tran           = REFORM(all__trans[ii[0],*])
tran_load      = tran + [-1,1]*5d0*6d1        ;;  load an extra 10 minutes but plot defined time range
wind_h2_mfi_2_tplot,/LOAD_GSE,TRANGE=tran_load
tplot,1,TRANGE=tran
;;----------------------------------------------------------------------------------------
;;  Get MFI data and split magnitude and vectors
;;----------------------------------------------------------------------------------------
;;  Get data
get_data,1,DATA=temp,DLIM=dlim,LIM=lim
;;  Define params
unix           = t_get_struc_unix(temp,TSHFT_ON=tshft_on)
IF KEYWORD_SET(tshft_on) THEN tshft = temp.TSHIFT[0] ELSE tshft = 0d0
vecs           = temp.Y[*,0L:2L]
bmag           = temp.Y[*,3L]
labs           = struct_value(dlim,'LABELS',DEFAULT=all_labs,INDEX=ind_labs)
cols           = struct_value(dlim,'COLORS',DEFAULT=all_cols,INDEX=ind_cols)
;;  Define TPLOT structures
strucv         = {X:unix,Y:vecs,TSHIFT:tshft[0]}
strucm         = {X:unix,Y:bmag,TSHIFT:tshft[0]}
;;  Send to TPLOT
store_data,mfi_gse_tpn[0],DATA=strucv,DLIM=dlim,LIM=lim
store_data,mfi_mag_tpn[0],DATA=strucm,DLIM=dlim,LIM=lim
;;  Fix options
options,mfi_gse_tpn[0],COLORS=cols[0L:2L],LABELS=labs[0L:2L],YTITLE=yttl_bvec[0],/DEF
options,mfi_mag_tpn[0],COLORS=cols[3L],LABELS=labs[3L],YTITLE=yttl_bmag[0],/DEF
;;----------------------------------------------------------------------------------------
;;  Perform high pass filter
;;----------------------------------------------------------------------------------------
srate          = sample_rate(unix,/AVERAGE)
lf             = 5e-2
hf             = srate[0]
highpass       = vector_bandpass(vecs,srate[0],lf[0],hf[0],/MIDF)
struc          = {X:unix,Y:highpass,TSHIFT:tshft[0]}
;;  Send to TPLOT
store_data,mfi_filt_tp[0],DATA=struc,DLIM=dlim,LIM=lim
options,mfi_filt_tp[0],'COLORS'
options,mfi_filt_tp[0],'LABELS'
options,mfi_filt_tp[0],'YTITLE'
options,mfi_filt_tp[0],COLORS=vec_col,LABELS=vec_str,YTITLE=yttl_filt[0],/DEF
tpnm_str       = tnames()
options,tpnm_str,'THICK'
options,tpnm_str,'THICK',2e0,/DEF
;;  Insert NaNs in gaps to prevent IDL from connecting lines across gaps
gapthsh        = 2d0/srate[0]
t_insert_nan_at_interval_se,tnames(),GAP_THRESH=gapthsh[0]
;;  Plot all
tplot,[mfi_mag_tpn[0],mfi_gse_tpn[0],mfi_filt_tp[0]]
