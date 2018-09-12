;;  @/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/calc_ip_shocks_ramp_precursor_amps_batch.pro

;;  Requires:  jj  :  Scalar [numeric] index relative to events with whistlers
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
;;  Define dates/times
;;----------------------------------------------------------------------------------------
;;  Define indices
;ii             = jj[0]
ii             = good[jj[0]]
kk             = good_A[ii[0]]          ;;  index for CfA shock database params
;;  Define date
tran           = REFORM(all__trans[jj[0],*])
tr_mid         = MEAN(tran,/NAN)
tdate          = STRMID(time_string(tr_mid[0],PREC=3),0L,10L)
tra_prec       = [whis_st[jj[0]],whis_en[jj[0]]]
tran_load      = tran + [-1,1]*5d0*6d1        ;;  load an extra 10 minutes but plot defined time range
;;----------------------------------------------------------------------------------------
;;  Load MFI into TPLOT
;;----------------------------------------------------------------------------------------
nna            = tnames()
IF (nna[0] NE '') THEN store_data,DELETE=nna  ;;  Make sure nothing is already loaded

wind_h2_mfi_2_tplot,/LOAD_GSE,TRANGE=tran_load
tplot,mfi_gse_tpn[0],TRANGE=tran
;;----------------------------------------------------------------------------------------
;;  Get MFI data and split magnitude and vectors
;;----------------------------------------------------------------------------------------
;;  Get data
get_data,mfi_gse_tpn[0],DATA=temp,DLIM=dlim,LIM=lim
;;  Define params
unix           = t_get_struc_unix(temp,TSHFT_ON=tshft_on)
srate          = sample_rate(unix,/AVERAGE)
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
;;  Insert NaNs in gaps to prevent IDL from connecting lines across gaps
mag_tpns       = [mfi_mag_tpn[0],mfi_gse_tpn[0]]
gapthsh        = 2d0/srate[0]
t_insert_nan_at_interval_se,mag_tpns,GAP_THRESH=gapthsh[0]
;;----------------------------------------------------------------------------------------
;;  Perform high pass filter
;;----------------------------------------------------------------------------------------
;;  Default frequency filter range
fran_whf       = [1e-1,srate[0]]
;;  Define frequency filter ranges
IF (tdate[0] EQ '1998-02-18') THEN fran_whf       = [2e-1,srate[0]]
IF (tdate[0] EQ '1999-08-23') THEN fran_whf       = [1e-1,srate[0]]
IF (tdate[0] EQ '1999-11-05') THEN fran_whf       = [1e-1,srate[0]]
IF (tdate[0] EQ '2000-02-05') THEN fran_whf       = [4e-1,srate[0]]
IF (tdate[0] EQ '2001-03-03') THEN fran_whf       = [2e-1,srate[0]]
IF (tdate[0] EQ '2006-08-19') THEN fran_whf       = [1e-1,srate[0]]
IF (tdate[0] EQ '2008-06-24') THEN fran_whf       = [2e-1,srate[0]]
IF (tdate[0] EQ '2011-02-04') THEN fran_whf       = [2e-1,srate[0]]
IF (tdate[0] EQ '2012-01-21') THEN fran_whf       = [5e-1,srate[0]]
IF (tdate[0] EQ '2013-07-12') THEN fran_whf       = [3e-1,srate[0]]
IF (tdate[0] EQ '2013-10-26') THEN fran_whf       = [3e-1,srate[0]]
IF (tdate[0] EQ '2014-04-19') THEN fran_whf       = [2e-1,srate[0]]
IF (tdate[0] EQ '2014-05-07') THEN fran_whf       = [2e-1,srate[0]]
IF (tdate[0] EQ '2014-05-29') THEN fran_whf       = [2e-1,srate[0]]

;;  Filter data
lf             = fran_whf[0]
hf             = fran_whf[1]
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
t_insert_nan_at_interval_se,mfi_filt_tp[0],GAP_THRESH=gapthsh[0]
;;  Plot results
tplot,[mfi_mag_tpn[0],mfi_gse_tpn[0],mfi_filt_tp[0]]
;;----------------------------------------------------------------------------------------
;;  Define whistler amplitude and compare to shock ramp amplitude
;;----------------------------------------------------------------------------------------
bmag_up        = bo_mag_up[kk[0]]       ;;  < |Bo| >_up [nT]
bmag_dn        = bo_mag_dn[kk[0]]       ;;  < |Bo| >_dn [nT]
ramp_amp       = ABS(bmag_dn[0] - bmag_up[0])
;;  Get filtered data
get_data,mfi_filt_tp[0],DATA=tfilt,DLIM=dlim_f,LIM=lim_f
;;  Extract only fields during defined precursor times
diff           = MAX(tra_prec,/NAN) - MIN(tra_prec,/NAN)
IF (diff LT 2e0) THEN tra0 = tra_prec + [-1,1]*1d0 ELSE tra0 = tra_prec
prec_bvec      = trange_clip_data(tfilt,TRANGE=tra0,PREC=3)
IF (SIZE(prec_bvec,/TYPE) NE 8) THEN STOP
;;  Define params
time_ww        = t_get_struc_unix(prec_bvec,TSHFT_ON=tshft_on)
bvec_ww        = prec_bvec.Y
smwdth         = 5L
len            = 4L
off            = 4L
nolim          = 1b
envelope       = find_vector_waveform_envelope(time_ww,bvec_ww,SM_WIDTH=smwdth[0],RM_EDGES=0b,$
                                               NO_LIM_OFF=nolim[0],LENGTH=len[0],OFFSET=off[0])
;;  Define outer envelope of waveform and associated time stamps
env_t          = envelope.TIME
env_vlow       = envelope.V.ENV_VALS[*,0]
env_vupp       = envelope.V.ENV_VALS[*,1]
env_amp_pkpk   = ABS(env_vupp - env_vlow)
;;  Define ratio and print stats
xx             = env_amp_pkpk/ramp_amp[0]
nx             = N_ELEMENTS(xx)
stats          = [MIN(xx,/NAN),MAX(xx,/NAN),MEAN(xx,/NAN),MEDIAN(xx),STDDEV(xx,/NAN)*[1d0,1d0/SQRT(1d0*nx[0])]]
mform          = '(a75,6e12.4)'
PRINT,';;  '+tdate[0]+'::  (Precursor Amp.)/(Ramp Amp.) [Min,Max,Avg,Med,Std,SoM]:  ',stats,FORMAT=mform[0]
;;  1998-02-18::  (Precursor Amp.)/(Ramp Amp.) [Min,Max,Avg,Med,Std,SoM]:    2.0786e-02  2.7982e+00  3.1666e-01  1.8854e-01  3.6017e-01  2.3495e-02

STOP


wi,1
tt             = envelope.TIME MOD 864d2
tw             = time_ww MOD 864d2      
ev_vl          = envelope.V.ENV_VALS[*,0]
ev_vh          = envelope.V.ENV_VALS[*,1]
WSET,1
WSHOW,1
PLOT,tw,bvec_ww[*,0],YRANGE=[-1,1]*9,/YSTYLE,/XSTYLE,/NODATA
  OPLOT,tw,bvec_ww[*,0],COLOR=250
  OPLOT,tw,bvec_ww[*,1],COLOR=150
  OPLOT,tw,bvec_ww[*,2],COLOR= 50
  OPLOT,tt,ev_vl,COLOR=200
  OPLOT,tt,ev_vh,COLOR=100

;good_neg       = WHERE(bvec_ww LT 0,gd_neg)
;good_pos       = WHERE(bvec_ww GT 0,gd_pos)








