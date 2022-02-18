;+
;*****************************************************************************************
;
;  CRIBSHEET:   example_find_wind_waves_fuh_line_crib.pro
;  PURPOSE  :   This is an example crib sheet that finds the upper hybrid line, fuh, for
;                 an entire day of interest to determine the total electron density for
;                 that interval.
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




