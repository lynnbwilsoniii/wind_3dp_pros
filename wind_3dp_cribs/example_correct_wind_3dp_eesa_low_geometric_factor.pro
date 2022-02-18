;+
;*****************************************************************************************
;
;  CRIBSHEET:   example_correct_wind_3dp_eesa_low_geometric_factor.pro
;  PURPOSE  :   This is an example crib sheet that finds the upper hybrid line, fuh, for
;                 an entire day of interest to determine the total electron density for
;                 that interval.  Then it finds the spacecraft potential, when possible,
;                 from the photoelectron peaks in the 3DP EESA Low data.  Finally, the
;                 crib sheet shows how to integrate the 3DP EESA Low velocity distribution
;                 functions (VDFs) to find the total number density and then adjust the
;                 geometric factor until the integrated density matches that from the
;                 upper hybrid line.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               load_constants_fund_em_atomic_c2014_batch.pro
;               load_constants_extra_part_co2014_ci2015_batch.pro
;               load_constants_astronomical_aa2015_batch.pro
;               time_double.pro
;               general_load_and_save_wind_3dp_data.pro
;               tnames.pro
;               get_data.pro
;               t_remove_nans_y.pro
;               waves_merge_tnr_rad_to_tplot.pro
;               store_data.pro
;               options.pro
;               tplot.pro
;               kill_data_tr.pro
;               lbw_window.pro
;               trange_clip_data.pro
;               t_resample_tplot_struc.pro
;               mag__vec.pro
;               roundsig.pro
;               fill_range.pro
;               calc_1var_stats.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               0)  The first part of this crib sheet up to finding Ne is the same as
;                     that in example_find_wind_waves_fuh_line_crib.pro
;               1)  This is meant to be entered by hand in a terminal on the command line
;               2)  User is responsible for obtaining and correctly placing the necessary
;                     data files (see TPLOT tutorial in this folder for more info)
;
;  REFERENCES:  
;               1)  Lavraud, B., and D.E. Larson "Correcting moments of in situ particle
;                      distribution functions for spacecraft electrostatic charging,"
;                      J. Geophys. Res. 121, pp. 8462--8474, doi:10.1002/2016JA022591,
;                      2016.
;               2)  Meyer-Vernet, N., and C. Perche "Tool kit for antennae and thermal
;                      noise near the plasma frequency," J. Geophys. Res. 94(A3),
;                      pp. 2405--2415, doi:10.1029/JA094iA03p02405, 1989.
;               3)  Meyer-Vernet, N., K. Issautier, and M. Moncuquet "Quasi-thermal noise
;                      spectroscopy: The art and the practice," J. Geophys. Res. 122(8),
;                      pp. 7925--7945, doi:10.1002/2017JA024449, 2017.
;               4)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               5)  Lin et al., "A Three-Dimensional Plasma and Energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev.
;                      71, pp. 125--153, 1995.
;               6)  Bougeret, J.-L., M.L. Kaiser, P.J. Kellogg, R. Manning, K. Goetz,
;                      S.J. Monson, N. Monge, L. Friel, C.A. Meetre, C. Perche,
;                      L. Sitruk, and S. Hoang "WAVES:  The Radio and Plasma Wave
;                      Investigation on the Wind Spacecraft," Space Sci. Rev. 71,
;                      pp. 231--263, doi:10.1007/BF00751331, 1995.
;               7)  M. Wüest, D.S. Evans, and R. von Steiger "Calibration of Particle
;                      Instruments in Space Physics," ESA Publications Division,
;                      Keplerlaan 1, 2200 AG Noordwijk, The Netherlands, 2007.
;               8)  M. Wüest, et al., "Review of Instruments," ISSI Sci. Rep. Ser.
;                      Vol. 7, pp. 11--116, 2007.
;
;   CREATED:  12/22/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/22/2021   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN

start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
;;  Get fundamental and astronomical
@load_constants_fund_em_atomic_c2014_batch.pro
@load_constants_extra_part_co2014_ci2015_batch.pro
@load_constants_astronomical_aa2015_batch.pro
;;  Conversion factors
;;    Energy and Temperature
f_1eV          = qq[0]/hh[0]                       ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]                    ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]                       ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> eV2K*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]                       ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> K2eV*Temp{K} = energy{eV}]
;;  Frequency factors
wcefac         = 1d-9*qq[0]/me[0]
fcefac         = wcefac[0]/(2d0*!DPI)
neinvf         = (2d0*!DPI)^2d0*epo[0]*me[0]/qq[0]^2d0
wpefac         = SQRT(1d6*qq[0]^2d0/(me[0]*epo[0]))
fpefac         = wpefac[0]/(2d0*!DPI)
;;  Speed factors
vtefac         = SQRT(2d0*eV2J[0]/me[0])*1d-3

;;  Scalars in different units
Re_km          = R_ea__m[0]*1d-3                   ;;  m --> km
;;  Defaults
badbins        = [00, 02, 04, 06, 08, 09, 10, 11, 13, 15, 17, 19, $
                   20, 21, 66, 68, 70, 72, 74, 75, 76, 77, 79, 81, $
                   83, 85, 86, 87]
;;  Define popen structure
popen_str      = {PORT:1,UNITS:'inches',XSIZE:8e0,YSIZE:11e0,ASPECT:0}
;;  Defaults and general variables
def__lim       = {YSTYLE:1,YMINOR:10L,PANEL_SIZE:2.0,XMINOR:5,XTICKLEN:0.04}
def_dlim       = {LOG:0,SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:-1}
;;  Define default 3DP EESA Low optical geometric factor (GF)
def_anode_eff  = [0.977,1.019,0.990,1.125,1.154,0.998,0.977,1.005]
;;----------------------------------------------------------------------------------------
;;  Define Date/Time Range
;;----------------------------------------------------------------------------------------
sc             = 'Wind'
scpref         = sc[0]+'_'
;;  Define time range
tdate          = '2020-04-20'
tra_t          = tdate[0]+'/'+[start_of_day[0],end___of_day[0]]
trand          = time_double(tra_t)
tran_3dp       = trand
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Load MFI, 3DP, SWE, and orbit data
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
general_load_and_save_wind_3dp_data,TRANGE=trand,/LOAD_EESA,/LOAD_PESA,/LOAD__SST,     $
                                    /LOAD_SWEFC,/NO_CLEANT,/NO_SAVE,                   $
                                    EESA_OUT=eesa_out,PESA_OUT=pesa_out,               $
                                    SST_FOUT=sst_fout,SST_OOUT=sst_oout,BURST_ON=burst_on
;;----------------------------------------------------------------------------------------
;;  Define relevant TPLOT handles
;;----------------------------------------------------------------------------------------
swe_tpns       = [tnames('*_SWE_*'),tnames('*_Ni_tot_SWE')]
swe_tpnf       = tnames('*_fit_flag_SWE')
;;  Remove data for bad fit flags
get_data,swe_tpnf[0],DATA=swe_fflag_str
swe_fflag      = swe_fflag_str.Y
bad            = WHERE(swe_fflag LE 9e0,bd)
nstp           = N_ELEMENTS(swe_tpns)
FOR j=0L, nstp[0] - 1L DO BEGIN                                      $
  get_data,swe_tpns[j],DATA=temp,DLIMIT=dlim,LIMIT=lim             & $
  IF (SIZE(temp,/TYPE) NE 8) THEN CONTINUE                         & $
  data           = temp.Y                                          & $
  sznd           = SIZE(data,/N_DIMENSIONS)                        & $
  IF (bd[0] GT 0) THEN IF (sznd[0] EQ 1) THEN data[bad] = d ELSE IF (sznd[0] EQ 2) THEN data[bad,*] = d  & $
  temp.Y         = data                                            & $
  store_data,swe_tpns[j],DATA=temp,DLIMIT=dlim,LIMIT=lim           & $
  IF (bd[0] GT 0) THEN t_remove_nans_y,swe_tpns[j],/NO_EXTRAPOLATE


;;  Plot Data
mfi_tpns       = tnames(scpref[0]+'magf_3s_'+['mag','gse'])
nna            = [mfi_tpns,swe_tpns[[0,4,16,17]]]
tplot,nna

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Load Wind WAVES data
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;    Need to get ASCII files from https://solar-radio.gsfc.nasa.gov then rename
;;      to the following format:
;;        TNR  Data:  TNR_YYYYMMDD.txt
;;        RAD1 Data:  RAD1_YYYYMMDD.txt
;;        RAD2 Data:  RAD2_YYYYMMDD.txt
;;      then put the files in the following folder (TNR example):
;;        ~/wind_data_dir/Wind_WAVES_Data/TNR__ASCII/
;;----------------------------------------------------------------------------------------
.compile waves_get_ascii_file_wrapper.pro
.compile waves_tnr_rad_to_tplot.pro
.compile waves_merge_tnr_rad_to_tplot.pro

flow           = 4d0
fupp           = 14d3
waves_merge_tnr_rad_to_tplot,FLOW=flow,FUPP=fupp,TRANGE=trand,/FSMTH,ZRANGE=[9.5d-1,1d1]
;;  Remove the individual receiver TPLOT handles
store_data,DELETE=tnames(['TNR_*','RAD1_*','RAD2_*'])
;;  Remove any "spikes" or "glitches" in the WAVES data
;;    *** The following will permanently remove data from TPLOT variable ***
waves_tpn      = tnames(scpref[0]+'WAVES_radio_spectra ')
options,waves_tpn[0],'PANEL_SIZE',2e0

nna            = [mfi_tpns,waves_tpn[0]]
WSET,0
WSHOW,0
tplot,nna

;;  From inspection, fuh never falls below ~19 kHz or goes above ~65 kHz on 2020-04-20
frq_mnr        = 19d3
fuh_max        = 65d3

kill_data_tr,NAMES=waves_tpn[0],NKILL=1
;;  Alter color bar and frequency ranges
options,waves_tpn[0],   'YTICKS',/DEFAULT
options,waves_tpn[0],   'YTICKV',/DEFAULT
options,waves_tpn[0],'YTICKNAME',/DEFAULT
options,waves_tpn[0],YRANGE=[3.5e0,1e2],ZRANGE=[1e0,6e0],/DEFAULT
;;----------------------------------------------------------------------------------------
;;  Open windows
;;----------------------------------------------------------------------------------------
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*7d-1

win_ttl        = 'WAVES Plots'
win_str        = {RETAIN:2,XSIZE:wsz[0],YSIZE:wsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
lbw_window,WIND_N=1,NEW_W=1,_EXTRA=win_str,/CLEAN

win_ttl        = '3DP Plots'
win_str        = {RETAIN:2,XSIZE:wsz[0],YSIZE:wsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
lbw_window,WIND_N=2,NEW_W=1,_EXTRA=win_str,/CLEAN

DEVICE,GET_SCREEN_SIZE=s_size
wsz            = LONG(MIN(s_size*7d-1))
xywsz          = [wsz[0],LONG(wsz[0]*1.375d0)]
win_ttl        = 'Wind VDF 2D Slice'
win_str        = {RETAIN:2,XSIZE:xywsz[0],YSIZE:xywsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
lbw_window,WIND_N=5,NEW_W=1,_EXTRA=win_str,/CLEAN
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot WAVES data to find fuh
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Get Ni data
get_data,scpref[0]+'Ni_tot_SWE',DATA=t_SNit,DLIMIT=dlim_SNit,LIMIT=lim__SNit
;;  Get Bo data
get_data,scpref[0]+'magf_3s_gse',DATA=t_magf,DLIMIT=dlim_magf,LIMIT=lim__magf
;;  Get spectra
get_data,scpref[0]+'WAVES_radio_spectra',DATA=s_waves,DLIMIT=dlim_waves,LIMIT=lim__waves
;;  Clip the MFI, SWE, and WAVES data
tran_cp        = tran_3dp + [-1,1]*1d0*6d1
clip_ni        = trange_clip_data( t_SNit,TRANGE=tran_cp,PREC=3)
clip_wv        = trange_clip_data(s_waves,TRANGE=tran_cp,PREC=3)
clip_bo        = trange_clip_data( t_magf,TRANGE=tran_cp,PREC=3)
;;  Resample MFI and SWE to WAVES times
clbo_wv        = t_resample_tplot_struc(clip_bo,clip_wv.X,/NO_EXTRAPOLATE,/IGNORE_INT)
clni_wv        = t_resample_tplot_struc(clip_ni,clip_wv.X,/NO_EXTRAPOLATE,/IGNORE_INT)
clbm_wv        = mag__vec(clbo_wv.Y,/NAN)
;;  Estimate fpe from Ni data
fpe_from_ni    = fpefac[0]*SQRT(clni_wv.Y)
frq_max        = 1.5d0*MAX(fpe_from_ni,/NAN) < fuh_max[0]
frq_mxr        = roundsig(frq_max[0],SIG=1)
good_wi        = WHERE(s_waves.V LE frq_mxr[0]*1e-3 AND s_waves.V GE frq_mnr[0]*1e-3,gd_wi)
IF (gd_wi[0] GT 0) THEN dbmin = 7d-1*MEDIAN(clip_wv.Y[*,good_wi])    ELSE dbmin = 7d-1*MEDIAN(clip_wv.Y)
IF (gd_wi[0] GT 0) THEN dbmax = 11d-1*MAX(clip_wv.Y[*,good_wi],/NAN) ELSE dbmax = 11d-1*MAX(clip_wv.Y,/NAN)

;;  Plot results
nc             = N_ELEMENTS(clip_wv.X)
scols          = LINDGEN(nc[0])*(250L - 30L)/(nc[0] - 1L) + 30L
fran           = [frq_mnr[0],frq_mxr[0]]*1e-3
WSET,1
WSHOW,1
PLOT,s_waves.V,REFORM(clip_wv.Y[0,*]),/NODATA,/XSTYLE,/YSTYLE,XRANGE=fran,YRANGE=[dbmin[0],dbmax[0]],/YLOG
  FOR j=0L, nc[0] - 1L DO OPLOT,s_waves.V,REFORM(clip_wv.Y[j,*]),COLOR=scols[j]
  FOR j=0L, nc[0] - 1L DO OPLOT,s_waves.V,SMOOTH(REFORM(clip_wv.Y[j,*]),3L,/NAN,/EDGE_TRUNCATE),COLOR=scols[j],THICK=2,LINESTYLE=1

;;  Find peak in frequency range and steepest slope immediately before
good_vf        = WHERE(s_waves.V LE fran[1] AND s_waves.V GE fran[0],gd_vf)
mx_lx          = REPLICATE(-1L,nc[0])
slope          = REPLICATE(d,nc[0],gd_vf[0])
ff             = s_waves.V[good_vf]
yy             = clip_wv.Y[*,good_vf]
FOR j=0L, nc[0] - 1L DO BEGIN                                           $
  slope[j,*] = DERIV(ff,REFORM(yy[j,*]))                              & $
  mxyy       = MAX(REFORM(yy[j,*]),/NAN,lx)                           & $
  mx_lx[j]   = lx[0]

f_uh_vals      = REPLICATE(d,nc[0])
find           = REPLICATE(-1L,nc[0])
FOR j=0L, nc[0] - 1L DO BEGIN                                           $
  low  = (mx_lx[j] - 3L)                                              & $
  upp  = mx_lx[j]                                                     & $
  ind  = fill_range(low[0],upp[0],DIND=1)                             & $
  slps = REFORM(slope[j,low[0]:upp[0]])                               & $
  mxsl = MAX(slps,/NAN,lx)                                            & $
  find[j] = ind[lx[0]]

;;  Define fuh and Calculate fpe [Hz]
f_uh_vals      = ff[find]*1d3
;;  Send to TPLOT and merge with WAVES TPLOT handle
fuh_str        = {X:clip_wv.X,Y:f_uh_vals*1d-3}
store_data,'Wind_WAVES_fuh_estimate',DATA=fuh_str,DLIMIT=def_dlim,LIMIT=def__lim
options,'Wind_WAVES_fuh_estimate',YRANGE=[3.5e0,1e2],YTITLE='fuh [kHz, WAVES]',COLORS=250,LABELS='fuh',/DEFAULT
;;  Merge with WAVES
wave2_tpn      = 'Wind_WAVES_radio_spec_with_fuh'
store_data,wave2_tpn[0],DATA=[waves_tpn[0],'Wind_WAVES_fuh_estimate']
options,wave2_tpn[0],YRANGE=[3.5e0,1e2],/DEFAULT
options,wave2_tpn[0],'PANEL_SIZE',2e0

WSET,0
WSHOW,0
nna            = [mfi_tpns,'Wind_WAVES_fuh_estimate',wave2_tpn[0]]
tplot,nna

;;  Remove "bad" intervals by hand
;;    --  I found at least 7 instances where routine found some higher frequency noise for 2020-04-20
;;    --  All "spikes" occurred after 08:00:00 UTC
kill_data_tr,NAMES='Wind_WAVES_fuh_estimate',NKILL=1

;;  Linearly interpolate out NaNs
t_remove_nans_y,'Wind_WAVES_fuh_estimate',/NO_EXTRAPOLATE

;;  Get fuh data
get_data,'Wind_WAVES_fuh_estimate',DATA=fuh_str,DLIMIT=fuh_dlim,LIMIT=fuh__lim
f_uh_vals      = fuh_str.Y*1d3
;;  Calculate fpe [Hz]
f_ce_vals      = fcefac[0]*REFORM(clbm_wv)
f_pe_vals      = SQRT(f_uh_vals^2d0 - f_ce_vals^2d0)
;;  Convert to density [cm^(-3)]
;;    ne = (2π fpe)^2 * (epo me)/e^2
ne_m3          = neinvf[0]*f_pe_vals^2d0
ne_tot         = 1d-6*ne_m3
;;  Send Ne [cm^(-3)] to TPLOT
net_str        = {X:clip_wv.X,Y:ne_tot}
store_data,'Wind_WAVES_net_estimate',DATA=net_str,DLIMIT=def_dlim,LIMIT=def__lim
options,'Wind_WAVES_net_estimate',YRANGE=[1e0,1e2],YLOG=1,YMINOR=9,YTITLE='Ne,tot [cm^(-3)]',YSUBYTITLE='[from WAVES fuh]',COLORS= 50,LABELS='Ne',/DEFAULT
;;  Linearly interpolate out NaNs
t_remove_nans_y,'Wind_WAVES_net_estimate',/NO_EXTRAPOLATE
;;  Get Ne data
get_data,'Wind_WAVES_net_estimate',DATA=net_str,DLIMIT=net_dlim,LIMIT=net__lim

;;  Plot data
WSET,0
WSHOW,0
nna            = [mfi_tpns,wave2_tpn[0],'Wind_WAVES_net_estimate']
tplot,nna

;;----------------------------------------------------------------------------------------
;;  Print one-variable statistics of results
;;----------------------------------------------------------------------------------------
conlim            = 9d-1
onvs_fuh_waves    = calc_1var_stats(f_uh_vals*1d-3,/NAN,CONLIM=conlim,PERCENTILES=perc_fuh)
onvs_fce___mfi    = calc_1var_stats(     f_ce_vals,/NAN,CONLIM=conlim,PERCENTILES=perc_fce)
onvs_fpe_waves    = calc_1var_stats(f_pe_vals*1d-3,/NAN,CONLIM=conlim,PERCENTILES=perc_fpe)
onvs_net_waves    = calc_1var_stats(        ne_tot,/NAN,CONLIM=conlim,PERCENTILES=perc_net)

temp              = '   For Wind WAVES and MFI '+time_string(MIN(fuh_str.X,/NAN),PREC=1)+'  to  '+time_string(MAX(fuh_str.X,/NAN),PREC=1)
PRINT,';;  '+temp[0]                                                                                                                                             & $
PRINT,';;  fce     [Hz]:  ',onvs_fce___mfi[0],perc_fce[0],onvs_fce___mfi[8],onvs_fce___mfi[2],onvs_fce___mfi[3],onvs_fce___mfi[9],perc_fce[1],onvs_fce___mfi[1]  & $
PRINT,';;  fpe    [kHz]:  ',onvs_fpe_waves[0],perc_fpe[0],onvs_fpe_waves[8],onvs_fpe_waves[2],onvs_fpe_waves[3],onvs_fpe_waves[9],perc_fpe[1],onvs_fpe_waves[1]  & $
PRINT,';;  fuh    [kHz]:  ',onvs_fuh_waves[0],perc_fuh[0],onvs_fuh_waves[8],onvs_fuh_waves[2],onvs_fuh_waves[3],onvs_fuh_waves[9],perc_fuh[1],onvs_fuh_waves[1]  & $
PRINT,';;  ne [cm^(-3)]:  ',onvs_net_waves[0],perc_net[0],onvs_net_waves[8],onvs_net_waves[2],onvs_net_waves[3],onvs_net_waves[9],perc_net[1],onvs_net_waves[1]
;;-----------------------------------------------------------------------------------------------------------------------------------------------------
;;                           Min             05%             25%             Avg             Med             75%             95%             Max
;;=====================================================================================================================================================
;;     For Wind WAVES and MFI 2020-04-20/00:00:00.0  to  2020-04-20/23:59:00.0
;;  fce     [Hz]:         48.702729       78.664077       223.26170       341.21777       410.01788       433.50053       444.98333       458.44056
;;  fpe    [kHz]:         19.869585       19.999832       23.995965       31.164250       27.996731       34.894027       55.999208       64.000233
;;  fuh    [kHz]:         19.869766       20.000000       24.000000       31.137245       28.000000       34.896343       56.000000       64.000252
;;  ne [cm^(-3)]:         4.8972727       4.9616870       7.1425472       13.360506       9.7227990       15.103544       38.899179       50.808900


;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot 3DP data to find SC Potential
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Define 3DP EL VDFs
;;----------------------------------------------------------------------------------------
IF (SIZE(eesa_out.EL_,/TYPE) EQ 8) THEN gael_ = eesa_out.EL_ ELSE gael_ = 0
IF (SIZE(eesa_out.ELB,/TYPE) EQ 8) THEN gaelb = eesa_out.ELB ELSE gaelb = 0
IF (SIZE(eesa_out.EH_,/TYPE) EQ 8) THEN gaeh_ = eesa_out.EH_ ELSE gaeh_ = 0
IF (SIZE(eesa_out.EHB,/TYPE) EQ 8) THEN gaehb = eesa_out.EHB ELSE gaehb = 0
IF (SIZE(gael_,/TYPE) EQ 8) THEN nel_ = N_ELEMENTS(gael_) ELSE nel_ = 0
IF (SIZE(gaelb,/TYPE) EQ 8) THEN nelb = N_ELEMENTS(gaelb) ELSE nelb = 0
IF (SIZE(gaeh_,/TYPE) EQ 8) THEN neh_ = N_ELEMENTS(gaeh_) ELSE neh_ = 0
IF (SIZE(gaehb,/TYPE) EQ 8) THEN nehb = N_ELEMENTS(gaehb) ELSE nehb = 0

;;  Define relevant 3DP VDFs
st_el_         = gael_.TIME
en_el_         = gael_.END_TIME
st_eh_         = gaeh_.TIME
en_eh_         = gaeh_.END_TIME
good_el_       = WHERE(st_el_ GE tran_3dp[0] AND en_el_ LE tran_3dp[1],gd_el_)
good_eh_       = WHERE(st_eh_ GE tran_3dp[0] AND en_eh_ LE tran_3dp[1],gd_eh_)

PRINT,';;  ',gd_el_[0],gd_eh_[0]
;;           862         862

IF (gd_eh_[0] EQ 0) THEN good_eh_ = VALUE_LOCATE(st_eh_,st_el_)
IF (gd_eh_[0] EQ 0 AND good_eh_[0] NE -1) THEN gd_eh_ = 1L ELSE gd_eh_ = N_ELEMENTS(good_eh_)

il             = good_el_[0]
ih             = good_eh_[0]
dat_l          = gael_[il]
dat_h          = gaeh_[ih]
;;  Define energy bins of EESA Low and High
ebstr_l        = dat_3dp_energy_bins(dat_l[0])
ebstr_h        = dat_3dp_energy_bins(dat_h[0])
ebins_l        = ebstr_l.ALL_ENERGIES
ebins_h        = ebstr_h.ALL_ENERGIES
;;  Plot EL combined with EH
cutran         = 22.5d0
pang           = 1b
units          = 'eflux'
esa_eran       = [1e0,1.2e3]
sst_eran       = [1e2,3e4]
esa_yran       = [1e4,4e8]
sst_yran       = [1e3,1e8]
esa_lim        = {YRANGE:esa_yran,XLOG:0,YLOG:1,XSTYLE:1,YSTYLE:1}
sst_lim        = {YRANGE:sst_yran,XLOG:0,YLOG:1,XSTYLE:1,YSTYLE:1}
dath1          = dat_h[0]
dath1.DATA[*,badbins] = f

WSET,2
WSHOW,2
plot_esa_sst_combined_spec3d,dat_l[0],dath1[0],ESA_ERAN=esa_eran,SST_ERAN=sst_eran,$
                             /SC_FRAME,CUT_RAN=cutran,P_ANGLE=pang,RM_PHOTO_E=0b,  $
                             UNITS=units,LIM_ESA=esa_lim,LIM_SST=sst_lim,          $
                             XDAT_ESA=xdat_esa,YDAT_ESA=ydat_esa,                  $
                             XDAT_SST=xdat__eh,YDAT_SST=ydat__eh
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Find spacecraft potential [eV] from EESA Low VDFs
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
ne_low         = 9d-1*net_str.Y
ne_upp         = 11d-1*net_str.Y
ne_struc       = {X:net_str.X,Y:[[ne_low],[ne_upp]]}
scpmin         = 1e0
scpmax         = 2e1
IF (nel_[0] GT 0) THEN inel_ = gael_ ELSE inel_ = 0
IF (nelb[0] GT 0) THEN inelb = gaelb ELSE inelb = 0
scpot_str      = estimate_scpot_wind_eesa_low(inel_,inelb,NETNR=ne_struc,SCPMIN=scpmin,SCPMAX=scpmax)

;;  ******************************************************************************************************************************
;;  ***  Visual inspection of output plots show the V-shaped kink in the VDF occurs around ~5-8 eV for all VDFs on 2020-04-20  ***
;;  ***    -- There is a few hour time period where Emin > phi_sc around ~04:00 to ~07:00 UTC, unfortunately                   ***
;;  ******************************************************************************************************************************

;;  Array dimensions are defined as:
;;    N  :  # of EESA Low VDFs (combined survey and burst VDFs)
;;    3  :  # of pitch-angle average directions, i.e., parallel, perpendicular, and anti-parallel
;;    2  :  [lower,upper] bounds corresponding to the [lower,upper] bounds of the total electron density provided on input
scpot_pcurv    = scpot_str.SCPOT_POS_CURV                      ;;  [N,3,2]-Element array of SC potential [eV] from positive curvature test
scpot_mxnfE    = scpot_str.SCPOT_DFDE_INFLECT                  ;;  [N,3,2]-Element array of " " from the inflection point where df/dE < 0 --> df/dE > 0
scpot_mnxcr    = scpot_str.SCPOT_MINMAX_CURV                   ;;  [N,3,2]-Element array of " " from minimum/maximum of curvature --> bounds on SC potential
scpot_mnf_E    = scpot_str.SCPOT_MIN_F_E                       ;;  [N,3]-Element array of " " from minimum in f_j(E)
;;  Print one-variable stats of output
conlim         = 9d-1
temp           = '   For 3DP EESA Low '+time_string(MIN(inel_.TIME,/NAN),PREC=1)+'  to  '+time_string(MAX(inel_.END_TIME,/NAN),PREC=1)
onvs_ran       = [scpmin[0],scpmax[0]]
onvs_scpcrv_l  = calc_1var_stats(scpot_pcurv[*,*,0L],/NAN,CONLIM=conlim,PERCENTILES=perc_scpcrv_l,RANGE=onvs_ran)
onvs_scpcrv_u  = calc_1var_stats(scpot_pcurv[*,*,1L],/NAN,CONLIM=conlim,PERCENTILES=perc_scpcrv_u,RANGE=onvs_ran)
onvs_scdfde_l  = calc_1var_stats(scpot_mxnfE[*,*,0L],/NAN,CONLIM=conlim,PERCENTILES=perc_scdfde_l,RANGE=onvs_ran)
onvs_scdfde_u  = calc_1var_stats(scpot_mxnfE[*,*,1L],/NAN,CONLIM=conlim,PERCENTILES=perc_scdfde_u,RANGE=onvs_ran)
onvs_scnxcr_l  = calc_1var_stats(scpot_mnxcr[*,*,0L],/NAN,CONLIM=conlim,PERCENTILES=perc_scnxcr_l,RANGE=onvs_ran)
onvs_scnxcr_u  = calc_1var_stats(scpot_mnxcr[*,*,1L],/NAN,CONLIM=conlim,PERCENTILES=perc_scnxcr_u,RANGE=onvs_ran)
onvs_scp_minf  = calc_1var_stats(        scpot_mnf_E,/NAN,CONLIM=conlim,PERCENTILES=perc_scp_minf,RANGE=onvs_ran)

PRINT,';;'+temp[0]  & $
PRINT,';;  SC_low_pc   [eV] ',onvs_scpcrv_l[0],perc_scpcrv_l[0],onvs_scpcrv_l[8],onvs_scpcrv_l[2],onvs_scpcrv_l[3],onvs_scpcrv_l[9],perc_scpcrv_l[1],onvs_scpcrv_l[1]  & $
PRINT,';;  SC_upp_pc   [eV] ',onvs_scpcrv_u[0],perc_scpcrv_u[0],onvs_scpcrv_u[8],onvs_scpcrv_u[2],onvs_scpcrv_u[3],onvs_scpcrv_u[9],perc_scpcrv_u[1],onvs_scpcrv_u[1]  & $
PRINT,';;  SC_low_df   [eV] ',onvs_scdfde_l[0],perc_scdfde_l[0],onvs_scdfde_l[8],onvs_scdfde_l[2],onvs_scdfde_l[3],onvs_scdfde_l[9],perc_scdfde_l[1],onvs_scdfde_l[1]  & $
PRINT,';;  SC_upp_df   [eV] ',onvs_scdfde_u[0],perc_scdfde_u[0],onvs_scdfde_u[8],onvs_scdfde_u[2],onvs_scdfde_u[3],onvs_scdfde_u[9],perc_scdfde_u[1],onvs_scdfde_u[1]  & $
PRINT,';;  SC_low_xc   [eV] ',onvs_scnxcr_l[0],perc_scnxcr_l[0],onvs_scnxcr_l[8],onvs_scnxcr_l[2],onvs_scnxcr_l[3],onvs_scnxcr_l[9],perc_scnxcr_l[1],onvs_scnxcr_l[1]  & $
PRINT,';;  SC_upp_xc   [eV] ',onvs_scnxcr_u[0],perc_scnxcr_u[0],onvs_scnxcr_u[8],onvs_scnxcr_u[2],onvs_scnxcr_u[3],onvs_scnxcr_u[9],perc_scnxcr_u[1],onvs_scnxcr_u[1]  & $
PRINT,';;  SC_min_ff   [eV] ',onvs_scp_minf[0],perc_scp_minf[0],onvs_scp_minf[8],onvs_scp_minf[2],onvs_scp_minf[3],onvs_scp_minf[9],perc_scp_minf[1],onvs_scp_minf[1]
;;-----------------------------------------------------------------------------------------------------------------------------------------------------
;;                             Min            05%              25%             Avg             Med             75%             95%             Max
;;=====================================================================================================================================================
;;   For 3DP EESA Low 2020-04-20/00:00:26.7  to  2020-04-20/23:59:44.3
;;  SC_low_pc   [eV]        1.0000000       1.0000000       5.1823447       4.4242118       5.1823447       5.6675115       5.1823447       5.6675115
;;  SC_upp_pc   [eV]        5.1305212       5.1305212       5.1305212       16.428310       19.838919       19.838919       19.838919       19.838919
;;  SC_low_df   [eV]        1.0000000       1.0000000       5.6675115       5.3837567       6.4817396       6.7783601       7.0885547       7.0885547
;;  SC_upp_df   [eV]        5.1305212       5.1305212       6.1980992       6.6534265       7.0885547       7.4129446       7.7521793       7.7521793
;;  SC_low_xc   [eV]        1.0000000       1.0000000       5.1823447       4.7399685       5.1823447       5.9268709       5.9268709       5.9268709
;;  SC_upp_xc   [eV]        5.1305212       5.1305212       12.681991       10.777495       12.681991       18.140611       12.681991       18.140611
;;  SC_min_ff   [eV]        4.4233996       4.9961994       5.9268709       6.4635105       7.0885547       7.4129446       7.4129446       7.4129446

;;  ****************************************************************************************************************************
;;  ***  Looks like the inflection point where df/dE < 0 --> df/dE > 0 and minimum in f_j(E) are most reliable methods       ***
;;  ****************************************************************************************************************************
scp_infl_lu    = MEDIAN(scpot_mxnfE,DIMENSION=2)            ;;  Use the median value of the parallel, perpendicular, and anti-parallel estimates
scp_min___f    = MEDIAN(scpot_mnf_E,DIMENSION=2)

;;  Determine when minimum in f_(E) equals Emin
;;    --> Hopefully this will ID the VDFs where Emin > phi_sc
bad_scp        = WHERE(scp_min___f LE MIN(MIN(inel_.ENERGY,/NAN,DIMENSION=1),/NAN,DIMENSION=1),bd_scp,COMPLEMENT=good_scp,NCOMPLEMENT=gd_scp)
PRINT,';;  ',bd_scp[0],gd_scp[0]
;;           159         703


;;  Print updated one-variable stats using only those VDFs where Emin < phi_sc
onvs_scdfde_l  = calc_1var_stats(scp_infl_lu[good_scp,0L],/NAN,CONLIM=conlim,PERCENTILES=perc_scdfde_l,RANGE=onvs_ran)
onvs_scdfde_u  = calc_1var_stats(scp_infl_lu[good_scp,1L],/NAN,CONLIM=conlim,PERCENTILES=perc_scdfde_u,RANGE=onvs_ran)
onvs_scp_minf  = calc_1var_stats(scpot_mnf_E[good_scp]   ,/NAN,CONLIM=conlim,PERCENTILES=perc_scp_minf,RANGE=onvs_ran)
PRINT,';;'+temp[0]  & $
PRINT,';;  SC_low_df   [eV] ',onvs_scdfde_l[0],perc_scdfde_l[0],onvs_scdfde_l[8],onvs_scdfde_l[2],onvs_scdfde_l[3],onvs_scdfde_l[9],perc_scdfde_l[1],onvs_scdfde_l[1]  & $
PRINT,';;  SC_upp_df   [eV] ',onvs_scdfde_u[0],perc_scdfde_u[0],onvs_scdfde_u[8],onvs_scdfde_u[2],onvs_scdfde_u[3],onvs_scdfde_u[9],perc_scdfde_u[1],onvs_scdfde_u[1]  & $
PRINT,';;  SC_min_ff   [eV] ',onvs_scp_minf[0],perc_scp_minf[0],onvs_scp_minf[8],onvs_scp_minf[2],onvs_scp_minf[3],onvs_scp_minf[9],perc_scp_minf[1],onvs_scp_minf[1]
;;-----------------------------------------------------------------------------------------------------------------------------------------------------
;;                             Min            05%              25%             Avg             Med             75%             95%             Max
;;=====================================================================================================================================================
;;   For 3DP EESA Low 2020-04-20/00:00:26.7  to  2020-04-20/23:59:44.3
;;  SC_low_df   [eV]        5.4195017       5.4195017       6.4817396       6.3717168       6.7783601       7.0885547       7.0885547       7.0885547
;;  SC_upp_df   [eV]        5.9268709       5.9268709       7.0885547       6.9682316       7.4129446       7.7521793       7.7521793       7.7521793
;;  SC_min_ff   [eV]        5.9268709       5.9268709       5.9268709       6.8233493       7.0885547       7.4129446       7.4129446       7.4129446

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Iteratively adjust default GF until integrated Ne matches WAVES Ne
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define some default parameters
ngrid          = 121L                                     ;;  Define # of grid points for Delaunay triangulation
vlim           = 15d3
vec1           = [1d0,0d0,0d0]
vec2           = [0d0,1d0,0d0]
vframe         = [0d0,0d0,0d0]
;;  Define EESA Low parameters
cal_el_        = inel_[good_scp]
cal_el_.SC_POT = scpot_mnf_E[good_scp]
tav_el_        = (cal_el_.TIME + cal_el_.END_TIME)/2d0
net_wv_at_el_  = t_resample_tplot_struc(net_str,tav_el_,/NO_EXTRAPOLATE,/IGNORE_INT)
ncel           = N_ELEMENTS(cal_el_)
empir_eff      = REPLICATE(d,ncel[0],N_ELEMENTS(def_anode_eff))
thrsh          = 6.5d0

ex_start       = SYSTIME(1)
;FOR j=1L, 10L DO BEGIN                                                                 $
FOR j=0L, ncel[0] - 1L DO BEGIN                                                                 $
  dat0c          = cal_el_[j]                                                                 & $
  netwv          = net_wv_at_el_.Y[j]                                                         & $
  IF (FINITE(netwv[0]) EQ 0) THEN CONTINUE                                                    & $
  anode          = BYTE((90 - dat0c[0].THETA)/22.5)                                           & $
  relgeom_el     = 4*def_anode_eff                                                            & $
  dat0c.GF       = relgeom_el[anode]                                                          & $
  temp           = dat0c[0].DATA                                                              & $
  bad            = WHERE(dat0c[0].ENERGY LE 1.0e0*dat0c[0].SC_POT,bd)                         & $
  IF (bd[0] GT 0) THEN temp[bad] = f                                                          & $
  dat0c[0].DATA  = temp                                                                       & $
  datcfvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat0c)                                   & $
  mag_dir        = REFORM(dat0c[0].MAGF)                                                      & $
  vels           = datcfvxyz.VELXYZ                                                           & $
  data           = datcfvxyz.VDF                                                              & $
  ffit_momc      = lbw_nintegrate_3d_vdf(vels,data,VLIM=vlim,NGRID=ngrid,/SLICE2D,              $
                                         VFRAME=vframe,/ELECTRON,MAG_DIR=mag_dir,VEC1=vec1,     $
                                         VEC2=vec2,/N_S_ONLY)                                 & $
  IF (SIZE(ffit_momc,/TYPE) NE 8) THEN CONTINUE                                               & $
  IF (FINITE(ffit_momc[0].N_S[0]) EQ 0) THEN CONTINUE                                         & $
  diff_perc      = ABS(ffit_momc[0].N_S[0] - netwv[0])/netwv[0]*1d2                           & $
  IF (diff_perc[0] LE thrsh[0]) THEN empir_eff[j,*] = relgeom_el/4d0                          & $
  IF (diff_perc[0] LE thrsh[0]) THEN CONTINUE                                                 & $
  yes_inc        = ffit_momc[0].N_S[0] GT netwv[0]                                            & $
  fact           = ([9d-1,11d-1])[yes_inc[0]]                                                 & $
  true           = 0b                                                                         & $
  REPEAT BEGIN                                                                                  $
    relgeom_el    *= fact[0]                                                                  & $
    dat0c.GF       = relgeom_el[anode]                                                        & $
    datcfvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat0c)                                 & $
    vels           = datcfvxyz.VELXYZ                                                         & $
    data           = datcfvxyz.VDF                                                            & $
    ffit_momc      = lbw_nintegrate_3d_vdf(vels,data,VLIM=vlim,NGRID=ngrid,/SLICE2D,            $
                                           VFRAME=vframe,/ELECTRON,MAG_DIR=mag_dir,VEC1=vec1,   $
                                           VEC2=vec2,/N_S_ONLY)                               & $
    IF (SIZE(ffit_momc,/TYPE) NE 8) THEN BREAK                                                & $
    IF (FINITE(ffit_momc[0].N_S[0]) EQ 0) THEN BREAK                                          & $
    diff_perc      = ABS(ffit_momc[0].N_S[0] - netwv[0])/netwv[0]*1d2                         & $
    IF (diff_perc[0] LE thrsh[0]) THEN empir_eff[j,*] = relgeom_el/4d0                        & $
    IF (diff_perc[0] LE thrsh[0]) THEN true = 1b                                              & $
    yes_inc        = ffit_momc[0].N_S[0] GT netwv[0]                                          & $
    fact           = ([9d-1,11d-1])[yes_inc[0]]                                               & $
  ENDREP UNTIL true[0]                                                                        & $
  IF ((j[0] MOD 30) EQ 0) THEN PRINT,'j = ',j[0],',  '+STRING(SYSTIME(1) - ex_start[0])+' elapsed seconds...'
ex_time        = SYSTIME(1) - ex_start[0]
MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL


;;  Calculate one-variable stats on the corrected GFs for each anode to see the amount of variability
diff_per_a1    = (empir_eff[*,0] - def_anode_eff[0])/def_anode_eff[0]*1d2
diff_per_a2    = (empir_eff[*,1] - def_anode_eff[1])/def_anode_eff[1]*1d2
diff_per_a3    = (empir_eff[*,2] - def_anode_eff[2])/def_anode_eff[2]*1d2
diff_per_a4    = (empir_eff[*,3] - def_anode_eff[3])/def_anode_eff[3]*1d2
diff_per_a5    = (empir_eff[*,4] - def_anode_eff[4])/def_anode_eff[4]*1d2
diff_per_a6    = (empir_eff[*,5] - def_anode_eff[5])/def_anode_eff[5]*1d2
diff_per_a7    = (empir_eff[*,6] - def_anode_eff[6])/def_anode_eff[6]*1d2
diff_per_a8    = (empir_eff[*,7] - def_anode_eff[7])/def_anode_eff[7]*1d2

;;  Compute one-variable stats of analyzer efficiencies
conlim             = 9d-1
onevs_ra1          = calc_1var_stats(diff_per_a1,/NAN,CONLIM=conlim,PERCENTILES=perc_ra1)
onevs_ra2          = calc_1var_stats(diff_per_a2,/NAN,CONLIM=conlim,PERCENTILES=perc_ra2)
onevs_ra3          = calc_1var_stats(diff_per_a3,/NAN,CONLIM=conlim,PERCENTILES=perc_ra3)
onevs_ra4          = calc_1var_stats(diff_per_a4,/NAN,CONLIM=conlim,PERCENTILES=perc_ra4)
onevs_ra5          = calc_1var_stats(diff_per_a5,/NAN,CONLIM=conlim,PERCENTILES=perc_ra5)
onevs_ra6          = calc_1var_stats(diff_per_a6,/NAN,CONLIM=conlim,PERCENTILES=perc_ra6)
onevs_ra7          = calc_1var_stats(diff_per_a7,/NAN,CONLIM=conlim,PERCENTILES=perc_ra7)
onevs_ra8          = calc_1var_stats(diff_per_a8,/NAN,CONLIM=conlim,PERCENTILES=perc_ra8)
temp           = '   For 3DP EESA Low '+time_string(MIN(cal_el_.TIME,/NAN),PREC=1)+'  to  '+time_string(MAX(cal_el_.END_TIME,/NAN),PREC=1)
PRINT,';;'+temp[0]  & $
PRINT,';;  Anode 1   [%] ',onevs_ra1[0],perc_ra1[0],onevs_ra1[8],onevs_ra1[2],onevs_ra1[3],onevs_ra1[9],perc_ra1[1],onevs_ra1[1]  & $
PRINT,';;  Anode 2   [%] ',onevs_ra2[0],perc_ra2[0],onevs_ra2[8],onevs_ra2[2],onevs_ra2[3],onevs_ra2[9],perc_ra2[1],onevs_ra2[1]  & $
PRINT,';;  Anode 3   [%] ',onevs_ra3[0],perc_ra3[0],onevs_ra3[8],onevs_ra3[2],onevs_ra3[3],onevs_ra3[9],perc_ra3[1],onevs_ra3[1]  & $
PRINT,';;  Anode 4   [%] ',onevs_ra4[0],perc_ra4[0],onevs_ra4[8],onevs_ra4[2],onevs_ra4[3],onevs_ra4[9],perc_ra4[1],onevs_ra4[1]  & $
PRINT,';;  Anode 5   [%] ',onevs_ra5[0],perc_ra5[0],onevs_ra5[8],onevs_ra5[2],onevs_ra5[3],onevs_ra5[9],perc_ra5[1],onevs_ra5[1]  & $
PRINT,';;  Anode 6   [%] ',onevs_ra6[0],perc_ra6[0],onevs_ra6[8],onevs_ra6[2],onevs_ra6[3],onevs_ra6[9],perc_ra6[1],onevs_ra6[1]  & $
PRINT,';;  Anode 7   [%] ',onevs_ra7[0],perc_ra7[0],onevs_ra7[8],onevs_ra7[2],onevs_ra7[3],onevs_ra7[9],perc_ra7[1],onevs_ra7[1]  & $
PRINT,';;  Anode 8   [%] ',onevs_ra8[0],perc_ra8[0],onevs_ra8[8],onevs_ra8[2],onevs_ra8[3],onevs_ra8[9],perc_ra8[1],onevs_ra8[1]
;;-----------------------------------------------------------------------------------------------------------------------------------------------------
;;                          Min            05%              25%             Avg             Med             75%             95%             Max
;;=====================================================================================================================================================
;;   For 3DP EESA Low 2020-04-20/00:00:26.7  to  2020-04-20/23:59:44.3
;;  Anode 1   [%]       -52.170310      -40.951000      -34.390000      -32.373024      -34.390000      -27.100000      -19.000000       61.051000
;;  Anode 2   [%]       -52.170310      -40.951000      -34.390000      -32.373024      -34.390000      -27.100000      -19.000000       61.051000
;;  Anode 3   [%]       -52.170310      -40.951000      -34.390000      -32.373024      -34.390000      -27.100000      -19.000000       61.051000
;;  Anode 4   [%]       -52.170310      -40.951000      -34.390000      -32.373024      -34.390000      -27.100000      -19.000000       61.051000
;;  Anode 5   [%]       -52.170310      -40.951000      -34.390000      -32.373024      -34.390000      -27.100000      -19.000000       61.051000
;;  Anode 6   [%]       -52.170310      -40.951000      -34.390000      -32.373024      -34.390000      -27.100000      -19.000000       61.051000
;;  Anode 7   [%]       -52.170310      -40.951000      -34.390000      -32.373024      -34.390000      -27.100000      -19.000000       61.051000
;;  Anode 8   [%]       -52.170310      -40.951000      -34.390000      -32.373024      -34.390000      -27.100000      -19.000000       61.051000


;;  The values are relatively stable
;;    --> Use median array to define new GF corrections
med_arper          = [onevs_ra1[3],onevs_ra2[3],onevs_ra3[3],onevs_ra4[3],onevs_ra5[3],onevs_ra6[3],onevs_ra7[3],onevs_ra8[3]]
med_arfac          = (1d2 + med_arper)*1d-2
med_array          = def_anode_eff*med_arfac
temp               = 'Anode corrections [Adjusted until Integrated Ne = Ne from WAVES] for 3DP EESA Low '+time_string(MIN(cal_el_.TIME,/NAN),PREC=1)+'  to  '+time_string(MAX(cal_el_.END_TIME,/NAN),PREC=1)
PRINT,';;'+temp[0]  & $
PRINT,';;  Default Eff.  :  ',1d0*def_anode_eff  & $
PRINT,';;  Empirical Eff.:  ',med_array
;;-----------------------------------------------------------------------------------------------------------------------------------------------------
;;                           Anode 1         Anode 2         Anode 3         Anode 4         Anode 5         Anode 6         Anode 7         Anode 8
;;=====================================================================================================================================================
;;Anode corrections [Adjusted until Integrated Ne = Ne from WAVES] for 3DP EESA Low 2020-04-20/00:00:26.7  to  2020-04-20/23:59:44.3
;;  Default Eff.  :        0.97700000       1.0190001      0.99000001       1.1250000       1.1540000      0.99800003      0.97700000       1.0050000
;;  Empirical Eff.:        0.64100970      0.66856594      0.64953901      0.73811250      0.75713943      0.65478782      0.64100970      0.65938050


;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Now compute velocity moments for all VDFs
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define some default parameters
ngrid          = 121L                                     ;;  Define # of grid points for Delaunay triangulation
vlim           = 15d3
vec1           = [1d0,0d0,0d0]
vec2           = [0d0,1d0,0d0]
vframe         = [0d0,0d0,0d0]
;;  Define empirical correction to GF
empir_gfc      = [0.64100970d0,0.66856594d0,0.64953901d0,0.73811250d0,0.75713943d0,0.65478782d0,0.64100970d0,0.65938050d0]
;;  Define Ne from WAVES at EESA Low times
tav_el0        = (inel_.TIME + inel_.END_TIME)/2d0
net_wv_at_el0  = t_resample_tplot_struc(net_str,tav_el0,/NO_EXTRAPOLATE,/IGNORE_INT)
nael           = N_ELEMENTS(inel_)
inel_.SC_POT   = scp_min___f
;;  Define dummy arrays to fill
scp_int_3dp    = REPLICATE(d,nael[0])                  ;;  phi_sc [eV] used for velocity moments
ne__int_3dp    = REPLICATE(d,nael[0])                  ;;  Ne [cm^(-3)]
Tpa_int_3dp    = REPLICATE(d,nael[0])                  ;;  Te,para [eV]
Tpe_int_3dp    = REPLICATE(d,nael[0])                  ;;  Te,perp [eV]
Tav_int_3dp    = REPLICATE(d,nael[0])                  ;;  Te, tot [eV]
Ve__int_3dp    = REPLICATE(d,nael[0],3L)               ;;  Ve [km/s, GSE]
qev_int_3dp    = REPLICATE(d,nael[0],3L)               ;;  Qe [eV km s^(-1) cm^(-3), FAC]
qen_int_3dp    = REPLICATE(d,nael[0],3L)               ;;  Qe/qo [N/A, FAC]
thrsh          = 6.5d0

ex_start       = SYSTIME(1)
;FOR j=0L, 10L DO BEGIN                                                                 $
;FOR j=77L, 80L DO BEGIN                                                                 $
FOR j=0L, nael[0] - 1L DO BEGIN                                                                 $
  dat0c          = inel_[j]                                                                   & $
  netwv          = net_wv_at_el0.Y[j]                                                         & $
  anode          = BYTE((90 - dat0c[0].THETA)/22.5)                                           & $
  relgeom_el     = 4*empir_gfc                                                                & $
  dat0c.GF       = relgeom_el[anode]                                                          & $
  temp           = dat0c[0].DATA                                                              & $
  bad            = WHERE(dat0c[0].ENERGY LE 1.0e0*dat0c[0].SC_POT,bd)                         & $
  IF (bd[0] GT 0) THEN temp[bad] = f                                                          & $
  dat0c[0].DATA  = temp                                                                       & $
  datcfvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat0c)                                   & $
  mag_dir        = REFORM(dat0c[0].MAGF)                                                      & $
  vels           = datcfvxyz.VELXYZ                                                           & $
  data           = datcfvxyz.VDF                                                              & $
  ffit_momc      = lbw_nintegrate_3d_vdf(vels,data,VLIM=vlim,NGRID=ngrid,/SLICE2D,              $
                                         VFRAME=vframe,/ELECTRON,MAG_DIR=mag_dir,VEC1=vec1,     $
                                         VEC2=vec2)                                           & $
  IF (SIZE(ffit_momc,/TYPE) NE 8) THEN CONTINUE                                               & $
  IF (FINITE(ffit_momc[0].N_S[0]) EQ 0) THEN CONTINUE                                         & $
  diff_perc      = ABS(ffit_momc[0].N_S[0] - netwv[0])/netwv[0]*1d2                           & $
  test           = (TOTAL(j[0] EQ bad_scp) EQ 1) AND (diff_perc[0] GT thrsh[0])               & $
  IF (TOTAL(j[0] EQ bad_scp) EQ 1) THEN bad_on = 1b ELSE bad_on = 0b                          & $
  scpot1         = dat0c[0].SC_POT[0]                                                         & $
  REPEAT BEGIN                                                                                  $
    IF (~bad_on[0]) THEN BREAK                                                                & $
    IF (ffit_momc.N_S[0] GT netwv[0]) THEN scpot1 *= 1.1 ELSE scpot1 *= 0.9                   & $
    dat0c          = inel_[j]                                                                 & $
    dat0c.GF       = relgeom_el[anode]                                                        & $
    dat0c.SC_POT   = scpot1[0]                                                                & $
    temp           = dat0c[0].DATA                                                            & $
    bad            = WHERE(dat0c[0].ENERGY LE 1.0e0*dat0c[0].SC_POT,bd)                       & $
    IF (bd[0] GT 0) THEN temp[bad] = f                                                        & $
    dat0c[0].DATA  = temp                                                                     & $
    datcfvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat0c)                                 & $
    mag_dir        = REFORM(dat0c[0].MAGF)                                                    & $
    vels           = datcfvxyz.VELXYZ                                                         & $
    data           = datcfvxyz.VDF                                                            & $
    ffit_momc      = lbw_nintegrate_3d_vdf(vels,data,VLIM=vlim,NGRID=ngrid,/SLICE2D,            $
                                           VFRAME=vframe,/ELECTRON,MAG_DIR=mag_dir,VEC1=vec1,   $
                                           VEC2=vec2)                                         & $
    IF (SIZE(ffit_momc,/TYPE) NE 8) THEN BREAK                                                & $
    IF (FINITE(ffit_momc[0].N_S[0]) EQ 0) THEN BREAK                                          & $
    diff_perc      = ABS(ffit_momc[0].N_S[0] - netwv[0])/netwv[0]*1d2                         & $
    IF (diff_perc[0] LE thrsh[0]) THEN bad_on = 0b ELSE bad_on = 1b                           & $
  ENDREP UNTIL ~bad_on[0]                                                                     & $
  scp_int_3dp[j]   = dat0c[0].SC_POT[0]                                                       & $
  ne__int_3dp[j]   = ffit_momc[0].N_S[0]                                                      & $
  Tpa_int_3dp[j]   = ffit_momc[0].TEMP_3FAC[2]                                                & $
  Tpe_int_3dp[j]   = (ffit_momc[0].TEMP_3FAC[0] + ffit_momc[0].TEMP_3FAC[1])/2d0              & $
  Tav_int_3dp[j]   = ffit_momc[0].TAVG[0]                                                     & $
  Ve__int_3dp[j,*] = ffit_momc[0].VOS_XYZ                                                     & $
  qev_int_3dp[j,*] = ffit_momc[0].QFLUX_FAC_VEC                                               & $
  qen_int_3dp[j,*] = ffit_momc[0].QFLUX_FAC_NOR                                               & $
  IF ((j[0] MOD 30) EQ 0) THEN PRINT,'j = ',j[0],',  '+STRING(SYSTIME(1) - ex_start[0])+' elapsed seconds...'
ex_time        = SYSTIME(1) - ex_start[0]
MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL

;;-----------------------------------------------------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------------------------------------------------------
;;  Send results to TPLOT
;;-----------------------------------------------------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------------------------------------------------------
;;  Define TPLOT handles
scp_int_tpn    = 'Wind_3dp_int_sc_pot_used'
ne__int_tpn    = 'Wind_3dp_int_Ne'
Tpa_int_tpn    = 'Wind_3dp_int_Te_para'
Tpe_int_tpn    = 'Wind_3dp_int_Te_perp'
Tav_int_tpn    = 'Wind_3dp_int_Te__tot'
Ve__int_tpn    = 'Wind_3dp_int_Ve_gse'
qev_int_tpn    = 'Wind_3dp_int_Qe_fac'
qen_int_tpn    = 'Wind_3dp_int_Qe_qo_fac'
;;  Define TPLOT structures
scp_int_str    = {X:tav_el0,Y:scp_int_3dp}
ne__int_str    = {X:tav_el0,Y:ne__int_3dp}
Tpa_int_str    = {X:tav_el0,Y:Tpa_int_3dp}
Tpe_int_str    = {X:tav_el0,Y:Tpe_int_3dp}
Tav_int_str    = {X:tav_el0,Y:Tav_int_3dp}
Ve__int_str    = {X:tav_el0,Y:Ve__int_3dp}
qev_int_str    = {X:tav_el0,Y:qev_int_3dp}
qen_int_str    = {X:tav_el0,Y:qen_int_3dp}
;;  Define TPLOT YTITLEs
scp_int_ytt    = 'SC Pot. [eV]'
ne__int_ytt    = 'Ne [cm^(-3)]'
Tpa_int_ytt    = 'Te,para [eV]'
Tpe_int_ytt    = 'Te,perp [eV]'
Tav_int_ytt    = 'Te, tot [eV]'
Ve__int_ytt    = 'Ve [km/s, GSE]'
qev_int_ytt    = 'Qe [eV km s^(-1) cm^(-3), FAC]'
qen_int_ytt    = 'Qe/qo [N/A, FAC]'
all_int_ysb    = '[3DP Integ. Calib. GF]'
;;  Send to TPLOT
store_data,scp_int_tpn[0],DATA=scp_int_str,DLIMIT=def_dlim,LIMIT=def__lim
store_data,ne__int_tpn[0],DATA=ne__int_str,DLIMIT=def_dlim,LIMIT=def__lim
store_data,Tpa_int_tpn[0],DATA=Tpa_int_str,DLIMIT=def_dlim,LIMIT=def__lim
store_data,Tpe_int_tpn[0],DATA=Tpe_int_str,DLIMIT=def_dlim,LIMIT=def__lim
store_data,Tav_int_tpn[0],DATA=Tav_int_str,DLIMIT=def_dlim,LIMIT=def__lim
store_data,Ve__int_tpn[0],DATA=Ve__int_str,DLIMIT=def_dlim,LIMIT=def__lim
store_data,qev_int_tpn[0],DATA=qev_int_str,DLIMIT=def_dlim,LIMIT=def__lim
store_data,qen_int_tpn[0],DATA=qen_int_str,DLIMIT=def_dlim,LIMIT=def__lim
;;  Fix options
options,scp_int_tpn[0],YTITLE=scp_int_ytt[0],YSUBTITLE=all_int_ysb[0],COLORS= 50,LABELS='phi_sc',/DEFAULT
options,ne__int_tpn[0],YTITLE=ne__int_ytt[0],YSUBTITLE=all_int_ysb[0],COLORS= 50,YRANGE=[1e0,1e2],YLOG=1,YMINOR=9,LABELS='Ne',/DEFAULT
options,Tpa_int_tpn[0],YTITLE=Tpa_int_ytt[0],YSUBTITLE=all_int_ysb[0],COLORS= 50,LABELS='Te,para',/DEFAULT
options,Tpe_int_tpn[0],YTITLE=Tpe_int_ytt[0],YSUBTITLE=all_int_ysb[0],COLORS= 50,LABELS='Te,perp',/DEFAULT
options,Tav_int_tpn[0],YTITLE=Tav_int_ytt[0],YSUBTITLE=all_int_ysb[0],COLORS= 50,LABELS='Te, tot',/DEFAULT
options,Ve__int_tpn[0],YTITLE=Ve__int_ytt[0],YSUBTITLE=all_int_ysb[0],COLORS=[250,200, 50],LABELS='Ve'+['x','y','z'],/DEFAULT
options,qev_int_tpn[0],YTITLE=qev_int_ytt[0],YSUBTITLE=all_int_ysb[0],COLORS=[250,200, 50],LABELS='Qe'+['perp1','perp2','para'],/DEFAULT
options,qen_int_tpn[0],YTITLE=qen_int_ytt[0],YSUBTITLE=all_int_ysb[0],COLORS=[250,200, 50],LABELS='Qe'+['perp1','perp2','para']+'/qo',/DEFAULT


;;  Plot to examine
all_int_tpn    = [scp_int_tpn[0],ne__int_tpn[0],Tpa_int_tpn[0],Tpe_int_tpn[0],Tav_int_tpn[0],Ve__int_tpn[0],qev_int_tpn[0],qen_int_tpn[0]]
nna            = [mfi_tpns,'Wind_WAVES_net_estimate',ne__int_tpn[0],Tav_int_tpn[0],Ve__int_tpn[0]]
WSET,0
WSHOW,0
tplot,nna
;;----------------------------------------------------------------------------------------
;;  Save TPLOT file
;;----------------------------------------------------------------------------------------
fsuffx         = t_get_current_trange_fsuffx(PREC=3,FORMFN=1,/KEEPDATE)
tp_savenm      = 'Wind_MFI_3DP_PL_SWE_Fits_WAVES_CorrectedSCPotential_with_calibrated_eVDF_integrated_results_'+fsuffx[0]
tplot_save,FILENAME=tp_savenm[0]




















;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
ngrid          = 121L                                     ;;  Define # of grid points for Delaunay triangulation
vlim           = 15d3
vec1           = [1d0,0d0,0d0]
vec2           = [0d0,1d0,0d0]
vframe         = [0d0,0d0,0d0]

tav_el0        = (inel_.TIME + inel_.END_TIME)/2d0
net_wv_at_el0  = t_resample_tplot_struc(net_str,tav_el0,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Define empirical correction to GF
empir_gfc      = [0.64100970d0,0.66856594d0,0.64953901d0,0.73811250d0,0.75713943d0,0.65478782d0,0.64100970d0,0.65938050d0]
dat0c          = inel_[bad_scp[0]]
net_0          = net_wv_at_el0.Y[bad_scp[0]]
anode          = BYTE((90 - dat0c[0].THETA)/22.5)
relgeom_el     = 4*empir_gfc
dat0c.GF       = relgeom_el[anode]
scpot0         = scp_min___f[bad_scp[0]]                ;;  Initial SC potential [eV] guess
dat0c.SC_POT   = scpot0[0]
;;  Prevent interpolation below SC potential
temp           = dat0c[0].DATA
bad            = WHERE(dat0c[0].ENERGY LE 1.0e0*dat0c[0].SC_POT,bd)
IF (bd[0] GT 0) THEN temp[bad] = f
dat0c[0].DATA  = temp
;;  Define F(Vx,Vy,Vz)
datcfvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat0c)
mag_dir        = REFORM(dat0c[0].MAGF)
vels           = datcfvxyz.VELXYZ         ;;  [N,3]-Element [numeric] array of 3-vector velocities
data           = datcfvxyz.VDF            ;;  [N]-Element [numeric] array of data [# cm^(-3) km^(-3) s^(+3)]

fnor_momc      = lbw_nintegrate_3d_vdf(vels,data,VLIM=vlim,NGRID=ngrid,/SLICE2D,          $
                                       VFRAME=vframe,/ELECTRON,MAG_DIR=mag_dir,VEC1=vec1, $
                                       VEC2=vec2)

PRINT,';;  ',(fnor_momc.N_S[0] - net_0[0])/net_0[0]*1d2
;;         13.429661

;;  Integrated Ne > WAVES Ne
;;    -->  Increase spacecraft potential
scpot1         = scpot0[0]
IF (fnor_momc.N_S[0] GT net_0[0]) THEN scpot1 *= 1.1 ELSE scpot1 *= 0.9

;;  Recalculate
dat0c          = inel_[bad_scp[0]]
anode          = BYTE((90 - dat0c[0].THETA)/22.5)
relgeom_el     = 4*empir_gfc
dat0c.GF       = relgeom_el[anode]
dat0c.SC_POT   = scpot1[0]
;;  Prevent interpolation below SC potential
temp           = dat0c[0].DATA
bad            = WHERE(dat0c[0].ENERGY LE 1.0e0*dat0c[0].SC_POT,bd)
IF (bd[0] GT 0) THEN temp[bad] = f
dat0c[0].DATA  = temp
;;  Define F(Vx,Vy,Vz)
datcfvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat0c)
mag_dir        = REFORM(dat0c[0].MAGF)
vels           = datcfvxyz.VELXYZ         ;;  [N,3]-Element [numeric] array of 3-vector velocities
data           = datcfvxyz.VDF            ;;  [N]-Element [numeric] array of data [# cm^(-3) km^(-3) s^(+3)]

fpr1_momc      = lbw_nintegrate_3d_vdf(vels,data,VLIM=vlim,NGRID=ngrid,/SLICE2D,          $
                                       VFRAME=vframe,/ELECTRON,MAG_DIR=mag_dir,VEC1=vec1, $
                                       VEC2=vec2)
PRINT,';;  ',(fpr1_momc.N_S[0] - net_0[0])/net_0[0]*1d2
;;         7.6877230














