;;----------------------------------------------------------------------------------------
;;  Compile relevant routines
;;----------------------------------------------------------------------------------------
thm_init
;;----------------------------------------------------------------------------------------
;;  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  Probe A

;;  Probe B

;;  **********************************************
;;  **  variable names MUST exactly match these **
;;  **********************************************
probe          = 'b'
tdate          = '2008-07-14'
date           = '071408'
;th_data_dir    = './IDL_stuff/themis_data_dir/'      ;;  Change accordingly for your own machine

;;  Probe C

;;  Probe D

;;  Probe E
;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
@./wind_3dp_pros/wind_3dp_cribs/load_thm_fields_save_tplot_batch.pro

;;  Plot some data
magf__tpn      = scpref[0]+['fgh_'+[coord_mag[0],coord_gse[0]],'fgl_'+coord_mag[0]]
vbulk_tpn      = scpref[0]+'peib_velocity_'+coord_gse[0]
densi_tpn      = scpref[0]+'peib_density'
eitem_tpn      = scpref[0]+['peib','peeb']+'_avgtemp'
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'b') THEN options,eitem_tpn[0],MAX_VALUE=500.
nna            = [magf__tpn,vbulk_tpn[0],densi_tpn[0],eitem_tpn]
tplot,nna







