;+
;*****************************************************************************************
;
;  BATCH    :   example_load_Wind_mfi_swe_waves_3dp_spectra_1_batch.pro
;  PURPOSE  :   Loads data into TPLOT and creates stacked-line plots of the
;                 3DP particle spectra.  This is a companion batch file to
;                 example_load_Wind_mfi_swe_waves_3dp_spectra_0_batch.pro
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               t_stacked_ener_pad_spec_2_tplot.pro
;               pesa_high_bad_bins.pro
;               options.pro
;               tnames.pro
;               get_data.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               Usage:  Copy the following in the command line [*** AFTER changing the directory path accordingly ***]
;               @/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_3dp_cribs/example_load_Wind_mfi_swe_waves_3dp_spectra_1_batch.pro
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  User must call example_load_Wind_mfi_swe_waves_3dp_spectra_0_batch.pro
;                     prior to this batch file!
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/28/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/28/2021   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;----------------------------------------------------------------------------------------
;;  Combine survey and burst mode structures (if both present)
;;----------------------------------------------------------------------------------------
test_el        = TOTAL([(nel_[0] GT 0),(nelb[0] GT 0)])
test_eh        = TOTAL([(neh_[0] GT 0),(nehb[0] GT 0)])
test_pl        = TOTAL([(npl_[0] GT 0),(nplb[0] GT 0)])
test_ph        = TOTAL([(nph_[0] GT 0),(nphb[0] GT 0)])
test_sf        = TOTAL([(nsf_[0] GT 0),(nsfb[0] GT 0)])
test_so        = TOTAL([(nso_[0] GT 0),(nsob[0] GT 0)])
IF (test_el[0] GT 1) THEN all_el = {S:ael_,B:aelb} ELSE IF (test_el[0] EQ 1) THEN all_el = {S:ael_,B:0}
IF (test_eh[0] GT 1) THEN all_eh = {S:aeh_,B:aehb} ELSE IF (test_eh[0] EQ 1) THEN all_eh = {S:aeh_,B:0}
IF (test_pl[0] GT 1) THEN all_pl = {S:apl_,B:aplb} ELSE IF (test_pl[0] EQ 1) THEN all_pl = {S:apl_,B:0}
IF (test_ph[0] GT 1) THEN all_ph = {S:aph_,B:aphb} ELSE IF (test_ph[0] EQ 1) THEN all_ph = {S:aph_,B:0}
IF (test_sf[0] GT 1) THEN all_sf = {S:asf_,B:asfb} ELSE IF (test_sf[0] EQ 1) THEN all_sf = {S:asf_,B:0}
IF (test_so[0] GT 1) THEN all_so = {S:aso_,B:asob} ELSE IF (test_so[0] EQ 1) THEN all_so = {S:aso_,B:0}
;;  Clean up
DELVAR,ael_,aelb,aeh_,aehb,apl_,aplb,aph_,aphb,asf_,asfb,aso_,asob
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate stacked spectra and send to TPLOT  [using FACs]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  The following illustrates various ways to call t_stacked_ener_pad_spec_2_tplot.pro,
;;    which generates both an omnidirectional energy spectra TPLOT handle and a series
;;    of pitch-angle distribution handles.  The routine allows the user to do this in
;;    the spacecraft or bulk flow reference frame (defined by the VSW) structure tag
;;    in each instrument type distribution.  Some of the following inputs can be changed
;;    for the preference of each user/situation, but some should not to avoid issues
;;    with the routines.  I have attempted to mark the variables accordingly.
;;----------------------------------------------------------------------------------------
;;  Define a time range and TPLOT handle prefix [change at will]
tr_all_day     = trange
tpn_prefs      = scpref[0]+'magf_'
;;  Define the units of the output [change at will]
;units          = 'df'       ;;  phase space density [# s^(+3) km^(-3) cm^(-3)]
units          = 'flux'     ;;  number flux or intensity [# cm^(-2) sr^(-1) s^(-1) eV^(-1)]
;units          = 'eflux'    ;;  energy flux [eV cm^(-2) sr^(-1) s^(-1) eV^(-1)]
;;  Define the reference frame of the output [change at will]
no_trans       = 0b         ;;  Output will be in bulk flow rest frame
;no_trans       = 1b         ;;  Output will be in spacecraft rest frame
;;--------------------------------------------
;;  EESA Low
;;--------------------------------------------
;;  Define the "good" solid angle bins of the output [*** Do not recommend changing ***]
IF (test_el[0] GE 1) THEN bins = REPLICATE(1b,all_el[0].S[0].NBINS) ELSE bins = REPLICATE(0b,88)
;;  Define the number of pitch-angle bins of the output [*** Do not recommend changing ***]
num_pa         = 8L
;;  Define the allowed energy range of the output [change within limits of instrument]
erange         = [3e0,1e4]       ;;  Energy bin range to keep/use [eV]
;;  Define TPLOT handle base name [change at will]
name           = tpn_prefs[0]+'eesa_low_spec'
;;  Define 1st data structure type (survey)  [*** Do NOT change ***]
IF (test_el[0] GE 1) THEN dat  = all_el[0].S ELSE dat  = 0
;;  Define 2nd data structure type (survey)  [*** Do NOT change ***]
IF (test_el[0] GE 2) THEN dat2 = all_el[0].B ELSE dat2 = 0
IF (test_el[0] GE 2) THEN bin2 = REPLICATE(1b,all_el.B[0].NBINS) ELSE bin2 = 0
;;  Call spectra routine
IF (test_el[0] GE 1) THEN t_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,        $
                                                              ERANGE=erange,NAME=name,NO_TRANS=no_trans,  $
                                                              TRANGE=tr_all_day,TPN_STRUC=tpn_str_eesa_l, $
                                                              DAT_STR2=dat2,B2INS=bin2
;;  Clean up
DELVAR,dat,dat2,bins,bin2
;;--------------------------------------------
;;  EESA High
;;--------------------------------------------
;;  Define the "bad" solid angle bins of the output [*** Do NOT change ***]
badbins        = [00, 02, 04, 06, 08, 09, 10, 11, 13, 15, 17, 19, $
                   20, 21, 66, 68, 70, 72, 74, 75, 76, 77, 79, 81, $
                   83, 85, 86, 87]
;;  Follow rules from above for the following
IF (test_eh[0] GE 1) THEN bins = REPLICATE(1b,all_eh[0].S[0].NBINS) ELSE bins = REPLICATE(0b,88)
erange         = [1e2,1e5]       ;;  Energy bin range to keep/use [eV]
name           = tpn_prefs[0]+'eesa_high_corr_spec'
IF (test_eh[0] GE 1) THEN dat  = all_eh[0].S ELSE dat  = 0
IF (test_eh[0] GE 2) THEN dat2 = all_eh[0].B ELSE dat2 = 0
IF (test_eh[0] GE 2) THEN bin2 = REPLICATE(1b,all_eh.B[0].NBINS) ELSE bin2 = 0
;;  Kill "bad" solid angle bins
IF (test_eh[0] GE 1) THEN dat.ENERGY[*,badbins]  = f
IF (test_eh[0] GE 1) THEN dat.DATA[*,badbins]    = f
IF (test_eh[0] GE 2) THEN dat2.ENERGY[*,badbins] = f
IF (test_eh[0] GE 2) THEN dat2.DATA[*,badbins]   = f
IF (test_eh[0] GE 1) THEN t_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,        $
                                                              ERANGE=erange,NAME=name,NO_TRANS=no_trans,  $
                                                              TRANGE=tr_all_day,TPN_STRUC=tpn_str_eesa_hc,$
                                                              DAT_STR2=dat2,B2INS=bin2
;;  Clean up
DELVAR,dat,dat2,bins,bin2
;;--------------------------------------------
;;  PESA Low
;;--------------------------------------------
;;  Follow rules from above for the following
no_trans       = 1b              ;;  Calculate in SCF [this data defines Vsw so SCF is appropriate]
erange         = [1e1,1e5]       ;;  Energy bin range to keep/use [eV]
name           = tpn_prefs[0]+'pesa_low_spec'
IF (test_pl[0] GE 1) THEN bins = REPLICATE(1b,all_pl.S[0].NBINS) ELSE bins = REPLICATE(0b,25)
IF (test_pl[0] GE 1) THEN dat  = all_pl[0].S ELSE dat  = 0
IF (test_pl[0] GE 2) THEN dat2 = all_pl[0].B ELSE dat2 = 0
IF (test_pl[0] GE 2) THEN bin2 = REPLICATE(1b,all_pl.B[0].NBINS) ELSE bin2 = 0
IF (test_pl[0] GE 1) THEN t_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,        $
                                                              ERANGE=erange,NAME=name,NO_TRANS=no_trans,  $
                                                              TRANGE=tr_all_day,TPN_STRUC=tpn_str_pesa_l, $
                                                              DAT_STR2=dat2,B2INS=bin2
;;  Clean up
DELVAR,dat,dat2,bins,bin2
;;--------------------------------------------
;;  PESA High
;;--------------------------------------------
no_trans       = 1b              ;;  Output will be in spacecraft rest frame [SCF]
erange         = [0e0,1e9]       ;;  Energy bin range to keep/use [eV]
name           = tpn_prefs[0]+'pesa_high_corr_spec'
IF (test_ph[0] GE 1) THEN bins = REPLICATE(1b,all_ph.S[0].NBINS) ELSE bins = REPLICATE(0b,88)
;;  Remove "bad" PESA High bins
IF (test_ph[0] GE 1) THEN dat  = all_ph[0].S ELSE dat  = 0
IF (test_ph[0] GE 1) THEN pesa_high_bad_bins,dat
IF (test_ph[0] GE 2) THEN dat2 = all_ph[0].B ELSE dat2 = 0
IF (test_ph[0] GE 2) THEN bin2 = REPLICATE(1b,all_ph.B[0].NBINS) ELSE bin2 = 0
IF (test_ph[0] GE 2) THEN pesa_high_bad_bins,dat2
IF (test_ph[0] GE 1) THEN t_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,        $
                                                              ERANGE=erange,NAME=name,NO_TRANS=no_trans,  $
                                                              TRANGE=tr_all_day,TPN_STRUC=tpn_str_pesa_hc,$
                                                              DAT_STR2=dat2,B2INS=bin2
;;  Clean up
DELVAR,dat,dat2,bins,bin2
;;--------------------------------------------
;;  SST Foil
;;--------------------------------------------
no_trans       = 0b                          ;;  Output will be in bulk flow rest frame
erange         = [1e3,1e7]                   ;;  Energy bin range to keep/use [eV]
name           = tpn_prefs[0]+'sst_foil_corr_spec'
;;  Define "bad" solid-angle bins [personal communication with L. Wang, 2010]
sun_dir_bins   = [7,8,9,15,31,32,33]         ;;  7 bins  [noisy]
small_gf_bins  = [20,21,22,23,44,45,46,47]   ;;  8 bins  [don't remove:  (Personal Communication, D. Larson, July 18, 2011)]
IF (test_sf[0] GE 1) THEN bins = REPLICATE(1b,all_sf[0].S[0].NBINS) ELSE bins = REPLICATE(0b,48)
;;  Remove "bad" SST bins
IF (test_sf[0] GE 1) THEN dat  = all_sf[0].S ELSE dat  = 0
IF (test_sf[0] GE 1) THEN dat.ENERGY[*,sun_dir_bins] = f
IF (test_sf[0] GE 1) THEN dat.DATA[*,sun_dir_bins]   = f
IF (test_sf[0] GE 2) THEN dat2 = all_sf[0].B ELSE dat2 = 0
IF (test_sf[0] GE 2) THEN bin2 = REPLICATE(1b,all_sf.B[0].NBINS) ELSE bin2 = 0
IF (test_sf[0] GE 2) THEN dat2.ENERGY[*,sun_dir_bins] = f
IF (test_sf[0] GE 2) THEN dat2.DATA[*,sun_dir_bins]   = f
IF (test_sf[0] GE 1) THEN t_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,        $
                                                              ERANGE=erange,NAME=name,NO_TRANS=no_trans,  $
                                                              TRANGE=tr_all_day,TPN_STRUC=tpn_str_sst_fc, $
                                                              DAT_STR2=dat2,B2INS=bin2
;;  Clean up
DELVAR,dat,dat2,bins,bin2
;;--------------------------------------------
;;  SST Open
;;--------------------------------------------
erange         = [1e3,1e8]       ;;  Energy bin range to keep/use [eV]
name           = tpn_prefs[0]+'sst_open_corr_spec'
;;  Define "bad" solid-angle bins [personal communication with L. Wang, 2010]
sun_dir_bins   = [7,8,9,15,31,32,33]         ;;  7 bins
small_gf_bins  = [20,21,22,23,44,45,46,47]   ;;  8 bins  [don't remove:  (Personal Communication, D. Larson, July 18, 2011)]
noisy_bins     = [0,1,24,25]                 ;;  4 bins
all_bad_bins   = [sun_dir_bins,noisy_bins]
sp             = SORT(all_bad_bins)
all_bad_bins   = all_bad_bins[sp]
;;  Remove "bad" SST bins
IF (test_so[0] GE 1) THEN bins = REPLICATE(1b,all_so[0].S[0].NBINS) ELSE bins = REPLICATE(0b,48)
IF (test_so[0] GE 1) THEN dat  = all_so[0].S ELSE dat  = 0
IF (test_so[0] GE 1) THEN dat.ENERGY[*,all_bad_bins] = f
IF (test_so[0] GE 1) THEN dat.DATA[*,all_bad_bins]   = f
IF (test_so[0] GE 2) THEN dat2 = all_so[0].B ELSE dat2 = 0
IF (test_so[0] GE 2) THEN bin2 = REPLICATE(1b,all_so.B[0].NBINS) ELSE bin2 = 0
IF (test_so[0] GE 2) THEN dat2.ENERGY[*,all_bad_bins] = f
IF (test_so[0] GE 2) THEN dat2.DATA[*,all_bad_bins]   = f
IF (test_so[0] GE 1) THEN t_stacked_ener_pad_spec_2_tplot,dat,UNITS=units,BINS=bins,NUM_PA=num_pa,        $
                                                              ERANGE=erange,NAME=name,NO_TRANS=no_trans,  $
                                                              TRANGE=tr_all_day,TPN_STRUC=tpn_str_sst_oc, $
                                                              DAT_STR2=dat2,B2INS=bin2
;;  Clean up
DELVAR,dat,dat2,bins,bin2
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Fix PESA Low and High issues
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Remove any YRANGE estimates
all_flux_tpn   = tnames('*_flux*')
options,all_flux_tpn,   'YRANGE'
options,all_flux_tpn,   'YRANGE',/DEF
;;  Fix PESA Low issues
plomni_fac     = tnames( tpn_str_pesa_l.OMNI.SPEC_TPLOT_NAME)
plpad_omni_fac = tnames( tpn_str_pesa_l.PAD.SPEC_TPLOT_NAME)
plpad_spec_fac = tnames( tpn_str_pesa_l.PAD.PAD_TPLOT_NAMES)
planisotro_fac = tnames([tpn_str_pesa_l.ANIS.(0),tpn_str_pesa_l.ANIS.(1)])
all_pl_tpn     = [plomni_fac,plpad_spec_fac]
;;  Get PESA Low flux
get_data,plomni_fac[0],DATA=temp,DLIM=dlim,LIM=lim
zsub_ttle      = dlim.YSUBTITLE
;;  Change from a stacked line plot to a dynamic color-scale spectra plot
ysub_ttle      = '[Energy (eV)]'
options,all_pl_tpn,SPEC=1,ZLOG=1,ZTICKS=3,YSUBTITLE=ysub_ttle[0],$
                   ZTITLE=zsub_ttle[0],/DEF
;;  Remove remaining options
options,all_pl_tpn,     'SPEC'
options,all_pl_tpn,   'YRANGE'
options,all_pl_tpn,   'YTITLE'
options,all_pl_tpn,   'ZTITLE'
options,all_pl_tpn,   'ZRANGE'
options,all_pl_tpn,'YSUBTITLE'
;;  Clean up
DELVAR,temp,dlim,lim
;;----------------------------------------------------------------------------------------
;;  Fix PESA High issues
;;----------------------------------------------------------------------------------------
phomni_fac     = tnames(tpn_str_pesa_hc.OMNI.SPEC_TPLOT_NAME)
phpad_omni_fac = tnames(tpn_str_pesa_hc.PAD.SPEC_TPLOT_NAME)
phpad_spec_fac = tnames(tpn_str_pesa_hc.PAD.PAD_TPLOT_NAMES)
phanisotro_fac = tnames([tpn_str_pesa_hc.ANIS.(0),tpn_str_pesa_hc.ANIS.(1)])
all_ph_tpn     = [phomni_fac,phpad_spec_fac]
;;  Get PESA Low flux
get_data,phomni_fac[0],DATA=temp,DLIM=dlim,LIM=lim
zsub_ttle      = dlim.YSUBTITLE
;;  Change from a stacked line plot to a dynamic color-scale spectra plot
ysub_ttle      = '[Energy (eV)]'
options,all_ph_tpn,SPEC=1,ZLOG=1,ZTICKS=3,YSUBTITLE=ysub_ttle[0],$
                   ZTITLE=zsub_ttle[0],/DEF
;;  Remove remaining options
options,all_ph_tpn,     'SPEC'
options,all_ph_tpn,   'YRANGE'
options,all_ph_tpn,   'YTITLE'
options,all_ph_tpn,   'ZTITLE'
options,all_ph_tpn,   'ZRANGE'
options,all_ph_tpn,'YSUBTITLE'
;;  Clean up
DELVAR,temp,dlim,lim







