;;  .compile $HOME/Desktop/low_beta_Ma_whistlers/crib_sheets/load_ip_shocks_mfi_split_magvec.pro

PRO load_ip_shocks_mfi_split_magvec,TRANGE=trange,PRECISION=prec

;;  Requires:  TRANGE     :  [2]-element [numeric] time range [Unix]
;;  Optional:  PRECISION  :  Scalar [numeric] defining the # of Sig. Figs.
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
;;  Define defaults
def_tramp      = '1995-04-17/23:33:07.755'         ;;  Midpoint of 1st ramp with precursor
def_delt       = [-1,1]*36d2                       ;;  default to a 2 hour window
;;----------------------------------------------------------------------------------------
;;  Check TPLOT and keywords
;;----------------------------------------------------------------------------------------
nna            = tnames()
IF (nna[0] NE '') THEN store_data,DELETE=nna  ;;  Make sure nothing is already loaded

;;  Check keywords
test           = (N_ELEMENTS(trange) NE 2) OR (is_a_number(trange,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  Default to first precursor event
  tran           = time_double(def_tramp[0]) + def_delt
  outmssg        = 'Defaulting to ±1 hour window about 1995-04-17/23:33:07.755 UTC'
  MESSAGE,outmssg[0],/INFORMATIONAL,/CONTINUE
ENDIF ELSE BEGIN
  temp           = get_valid_trange(TRANGE=trange,PRECISION=prec)
  tran           = temp.UNIX_TRANGE
ENDELSE
;;  load an extra 10 minutes but plot defined time range
tran_load      = tran + [-1,1]*5d0*6d1
;;----------------------------------------------------------------------------------------
;;  Load MFI into TPLOT
;;----------------------------------------------------------------------------------------
wind_h2_mfi_2_tplot,/LOAD_GSE,TRANGE=tran_load
;;  Make sure data was loaded
nna            = tnames(mfi_gse_tpn[0])
IF (nna[0] EQ '') THEN STOP    ;;  Something's wrong --> Debug!
;;  Plot output for user-defined time range
tplot,[mfi_gse_tpn[0]],TRANGE=tran
;;----------------------------------------------------------------------------------------
;;  Get MFI data and split magnitude and vectors
;;----------------------------------------------------------------------------------------
;;  Get data
get_data,mfi_gse_tpn[0],DATA=temp,DLIM=dlim,LIM=lim
;;  Remove original TPLOT handle so order of variables can be magnitude then vectors
store_data,DELETE=mfi_gse_tpn[0]
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
store_data,mfi_mag_tpn[0],DATA=strucm,DLIM=dlim,LIM=lim
store_data,mfi_gse_tpn[0],DATA=strucv,DLIM=dlim,LIM=lim
;;  Fix options
options,mfi_mag_tpn[0],COLORS=cols[3L],LABELS=labs[3L],YTITLE=yttl_bmag[0],/DEF
options,mfi_gse_tpn[0],COLORS=cols[0L:2L],LABELS=labs[0L:2L],YTITLE=yttl_bvec[0],/DEF
;;  Plot output
tplot,[mfi_mag_tpn[0],mfi_gse_tpn[0]],TRANGE=tran
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END