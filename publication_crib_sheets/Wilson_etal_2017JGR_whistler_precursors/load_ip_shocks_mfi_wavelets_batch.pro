;;  @/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/load_ip_shocks_mfi_wavelets_batch.pro

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

ii             = jj[0]
;ii             = good[jj[0]]
tran           = REFORM(all__trans[ii[0],*])
tran_load      = tran + [-1,1]*5d0*6d1        ;;  load an extra 10 minutes but plot defined time range
wind_h2_mfi_2_tplot,/LOAD_GSE,TRANGE=tran_load
tplot,1,TRANGE=tran
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
;;----------------------------------------------------------------------------------------
;;  Calculate wavelet transforms for MFI data and send to TPLOT
;;----------------------------------------------------------------------------------------
;;  Define some wavelet-specific parameters
nscale         = 100L                           ;;  # of scales/periods/frequencies to use in wavelet calculation
mother         = 'Morlet'                       ;;  mother wavelet basis function name
bxyz_zttls     = 'B'+all_labs+' Power'+'!C'+'[(nT)!U2!N'+'/Hz]'
tpn_wav        = mfi_gse_tpn[0]+'_'+all_labs+'_wavelet'
nc             = N_ELEMENTS(tpn_wav)
FOR k=0L, nc[0] - 1L DO BEGIN                                                       $
  time    = unix                                                                  & $
  vecw    = temp.Y[*,k]                                                           & $
  test    = FINITE(vecw)                                                          & $
  good    = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)                          & $
  IF (bd GT 0) THEN vecw[bad] = 0e0                                               & $
  wavelet_to_tplot,time,vecw,NEW_NAME=tpn_wav[k],MOTHER=mother,NSCALE=nscale      & $
  options,tpn_wav[k],ZTITLE=bxyz_zttls[k],YTITLE='Frequency [Hz]',/DEF
;;  Remove Cone of Influence and 95% Conf. Level TPLOT handles
coi_tpns       = tnames('*_Cone_of_Influence')
cl95tpns       = tnames('*_Conf_Level_95')
store_data,DELETE=tnames(REFORM([coi_tpns,cl95tpns]))

;;  Clean up
DELVAR,time,vecw,test,good,bad,time
;;  Insert NaNs in gaps to prevent IDL from connecting lines across gaps
gapthsh        = 2d0/srate[0]
t_insert_nan_at_interval_se,tnames(),GAP_THRESH=gapthsh[0]
;;----------------------------------------------------------------------------------------
;;  Fix TPLOT options
;;----------------------------------------------------------------------------------------
IF (srate[0] LT 19e0) THEN yran_wav = [1e-2,5.5e0] ELSE yran_wav = [1e-3,11e0]
zran_wav       = [1e-4,1e0]
;;  Date-specific changes
tr_mid         = MEAN(tran,/NAN)
tdate          = STRMID(time_string(tr_mid[0],PREC=3),0L,10L)
IF (tdate[0] EQ '1998-02-18') THEN zran_wav       = [1e-3,1e1]
IF (tdate[0] EQ '1998-02-18') THEN yran_wav       = [4e-2,5.5e0]
IF (tdate[0] EQ '1999-08-23') THEN zran_wav       = [2e-4,1e0]
IF (tdate[0] EQ '1999-08-23') THEN yran_wav       = [1e-1,5.5e0]
IF (tdate[0] EQ '1999-11-05') THEN zran_wav       = [1e-4,1e0]
IF (tdate[0] EQ '1999-11-05') THEN yran_wav       = [5e-2,5.5e0]
IF (tdate[0] EQ '2000-02-05') THEN zran_wav       = [1e-4,5e-1]
IF (tdate[0] EQ '2000-02-05') THEN yran_wav       = [1e-1,5.5e0]
IF (tdate[0] EQ '2001-03-03') THEN zran_wav       = [2e-4,1.5e0]
IF (tdate[0] EQ '2001-03-03') THEN yran_wav       = [1e-1,5.5e0]
IF (tdate[0] EQ '2006-08-19') THEN zran_wav       = [1e-4,1e0]
IF (tdate[0] EQ '2006-08-19') THEN yran_wav       = [1e-1,5.5e0]
IF (tdate[0] EQ '2008-06-24') THEN zran_wav       = [1e-4,1e0]
IF (tdate[0] EQ '2008-06-24') THEN yran_wav       = [1e-1,5.5e0]
IF (tdate[0] EQ '2011-02-04') THEN zran_wav       = [1e-4,1e0]
IF (tdate[0] EQ '2011-02-04') THEN yran_wav       = [1e-1,5.5e0]
IF (tdate[0] EQ '2012-01-21') THEN zran_wav       = [1e-4,5e-1]
IF (tdate[0] EQ '2012-01-21') THEN yran_wav       = [1e-1,5.5e0]
IF (tdate[0] EQ '2013-07-12') THEN zran_wav       = [1e-4,1e0]
IF (tdate[0] EQ '2013-07-12') THEN yran_wav       = [1e-1,5.5e0]
IF (tdate[0] EQ '2013-10-26') THEN zran_wav       = [1e-4,1e0]
IF (tdate[0] EQ '2013-10-26') THEN yran_wav       = [1e-1,5.5e0]
IF (tdate[0] EQ '2014-04-19') THEN zran_wav       = [1e-4,1e0]
IF (tdate[0] EQ '2014-04-19') THEN yran_wav       = [1e-1,5.5e0]
IF (tdate[0] EQ '2014-05-07') THEN zran_wav       = [1e-4,1e0]
IF (tdate[0] EQ '2014-05-07') THEN yran_wav       = [1e-1,5.5e0]
IF (tdate[0] EQ '2014-05-29') THEN zran_wav       = [1e-4,1e0]
IF (tdate[0] EQ '2014-05-29') THEN yran_wav       = [1e-1,5.5e0]
;;  Fix YRANGEs and ZRANGEs
options,tpn_wav,'YRANGE'
options,tpn_wav,'ZRANGE'
options,tpn_wav,YRANGE=yran_wav,ZRANGE=zran_wav,/DEF
;;  Create preliminary plot
tra_plot       = tura_mid[ii[0]] + [-1,1]*36d1
tplot,[mfi_mag_tpn[0],mfi_gse_tpn[0],tpn_wav[3],tpn_wav[0:2]],TRANGE=tra_plot






