;+
;*****************************************************************************************
;
;  CRIBSHEET:   example_load_Wind_mfi_swe_3dp_waves_data_crib.pro
;  PURPOSE  :   Illustrates example of how to call a companion batch file, grab data
;                 from TPLOT, time-clip said data, re-sample data onto new time grid,
;                 and then find both the upper hybrid line from the WAVES radio data
;                 and the spacecraft potential from the 3DP EESA Low velocity
;                 distribution functions (VDFs).  The last part requires that the minimum
;                 energy of the VDFs, Emin, is below the spacecraft potential, phi_sc,
;                 because the methods look for a V-shaped kink in the output spectra.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               time_double.pro
;               example_load_Wind_mfi_swe_3dp_waves_data_batch.pro
;               get_data.pro
;               trange_clip_data.pro
;               t_resample_tplot_struc.pro
;               roundsig.pro
;               fill_range.pro
;               calc_1var_stats.pro
;               t_get_struc_unix.pro
;               store_data.pro
;               options.pro
;               estimate_scpot_wind_eesa_low.pro
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
;   CHANGED:  1)  Now sends best results to TPLOT and calculates velocity moments
;                                                                   [05/11/2021   v1.0.1]
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
;   CREATED:  05/10/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/11/2021   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;----------------------------------------------------------------------------------------
;;  Define Date/Time Range
;;----------------------------------------------------------------------------------------
tdate          = '2008-09-01'
;;  Define time range
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
tra_t          = tdate[0]+'/'+[start_of_day[0],end___of_day[0]]
trange         = time_double(tra_t)
;;  Defaults and general variables
def__lim       = {YSTYLE:1,YMINOR:10L,PANEL_SIZE:2.0,XMINOR:5,XTICKLEN:0.04}
def_dlim       = {LOG:0,SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:-1}
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Load MFI, 3DP, and orbit data
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Note:  ***  Change the following directory path accordingly  ***
;;  Enter the following, by hand, from the command line
@/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_3dp_cribs/example_load_Wind_mfi_swe_3dp_waves_data_batch.pro

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Get data
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Get Ni data [cm^(-3)]
get_data,scpref[0]+'Ni_tot_SWE',DATA=t_SNit,DLIMIT=dlim_SNit,LIMIT=lim__SNit
;;  Get Bo data [nT, GSE]
get_data,     new_wibgse_tpn[0],DATA=t_magf,DLIMIT=dlim_magf,LIMIT=lim__magf
;;  Get |Bo| data [nT, magnitude]
get_data,     new_wibmag_tpn[0],DATA=t_bmag,DLIMIT=dlim_bmag,LIMIT=lim__bmag
;;  Get WAVES radio spectra
get_data,scpref[0]+'WAVES_radio_spectra',DATA=s_waves,DLIMIT=dlim_waves,LIMIT=lim__waves
;;----------------------------------------------------------------------------------------
;;  Clip and resample data
;;----------------------------------------------------------------------------------------
;;  Clip the MFI, SWE, and WAVES data
clip_ni        = trange_clip_data( t_SNit,TRANGE=trange,PREC=3)
clip_wv        = trange_clip_data(s_waves,TRANGE=trange,PREC=3)
clip_bo        = trange_clip_data( t_magf,TRANGE=trange,PREC=3)
clip_bm        = trange_clip_data( t_bmag,TRANGE=trange,PREC=3)
;;  Resample MFI and SWE to WAVES times
clbo_wv        = t_resample_tplot_struc(clip_bo,clip_wv.X,/NO_EXTRAPOLATE,/IGNORE_INT)
clbm_wv        = t_resample_tplot_struc(clip_bm,clip_wv.X,/NO_EXTRAPOLATE,/IGNORE_INT)
clni_wv        = t_resample_tplot_struc(clip_ni,clip_wv.X,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Estimate fpe from Ni data
fpe_from_ni    = fpefac[0]*SQRT(clni_wv.Y)
frq_max        = 1.5d0*MAX(fpe_from_ni,/NAN)
frq_mxr        = roundsig(frq_max[0],SIG=1)
;;  Define initial guess at frequency range in which to search
fran           = [4d0,frq_mxr[0]*1e-3]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Find peak in frequency range and steepest slope immediately before
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
fran1          = fran
IF (tdate[0] EQ '2008-09-01') THEN fran1[0] = 15d0       ;;  Adjust by inspection to avoid ion-acoustic waves affecting results
;;  Define good elements of WAVES frequency array within bounds of frequency peak finding range
good_vf        = WHERE(s_waves.V LE fran1[1] AND s_waves.V GE fran1[0],gd_vf)
nc             = N_ELEMENTS(clip_wv.X)
mx_lx          = REPLICATE(-1L,nc[0])               ;;  Index of maximum power
slope          = REPLICATE(d,nc[0],gd_vf[0])        ;;  Slope = dP/df [dB kHz^(-1)]
ff             = s_waves.V[good_vf]                 ;;  Frequencies [kHz]
yy             = clip_wv.Y[*,good_vf]               ;;  Power [dB above background]
FOR j=0L, nc[0] - 1L DO BEGIN                                           $
  slope[j,*] = DERIV(ff,REFORM(yy[j,*]))                              & $
  mxyy       = MAX(REFORM(yy[j,*]),/NAN,lx)                           & $
  mx_lx[j]   = lx[0]

;;  Now search for point of maximum slope
f_uh_vals      = REPLICATE(d,nc[0])                 ;;  Dummy array of upper hybrid line values
find           = REPLICATE(-1L,nc[0])               ;;  " " maximum slope indices
FOR j=0L, nc[0] - 1L DO BEGIN                                           $
  low  = (mx_lx[j] - 3L) > 0L                                         & $
  upp  = mx_lx[j] + 1L                                                & $
  ind  = fill_range(low[0],upp[0],DIND=1)                             & $
  slps = REFORM(slope[j,low[0]:upp[0]])                               & $
  mxsl = MAX(slps,/NAN,lx)                                            & $
  find[j] = ind[lx[0]]

;;  Define upper hybrid line values [Hz]
f_uh_vals      = ff[find]*1d3
;;  Define electron cyclotron frequency [Hz] values at the same times
f_ce_vals      = fcefac[0]*REFORM(clbm_wv.Y)
;;  Define electron plasma frequency [Hz] values at the same times
f_pe_vals      = SQRT(f_uh_vals^2d0 - f_ce_vals^2d0)
;;  Convert to density [cm^(-3)]
;;    ne = (2π fpe)^2 * (epo me)/e^2
ne_m3          = neinvf[0]*f_pe_vals^2d0       ;;  Total electron density [m^(-3)]
ne_tot         = 1d-6*ne_m3                    ;;  m^(-3)  -->  cm^(-3)
;;  Print one-variable stats for ne [cm^(-3)]
;;  Calculate one-variable stats for (Ts/Tip)_j [UP]
conlim            = 9d-1
onvs_ran          = [2d0,1d2]
onvs_ne_tot       = calc_1var_stats(ne_tot,/NAN,CONLIM=conlim,PERCENTILES=perc_ne_tot,RANGE=onvs_ran)
temp              = '   For WAVES '+time_string(MIN(clip_wv.X,/NAN),PREC=1)+'  to  '+time_string(MAX(clip_wv.X,/NAN),PREC=1)
PRINT,';;'+temp[0]  & $
PRINT,';;  ne,tot [cm^(-3)] ',onvs_ne_tot[0],perc_ne_tot[0],onvs_ne_tot[8],onvs_ne_tot[2],onvs_ne_tot[3],onvs_ne_tot[9],perc_ne_tot[1],onvs_ne_tot[1]
;;-----------------------------------------------------------------------------------------------------------------------------------------------------
;;                             Min            05%              25%             Avg             Med             75%             95%             Max
;;=====================================================================================================================================================
;;   For WAVES 2008-09-01/00:00:00.0  to  2008-09-01/23:59:00.0
;;  ne,tot [cm^(-3)]        4.8972805       6.3509906       7.5526963       8.1205293       7.5527118       9.7249417       9.7946433       12.702073
;;-----------------------------------------------------------------------------------------------------------------------------------------------------

;;  Send results to TPLOT
netnr_tpn      = scpref[0]+'Ne_from_WAVES'
unix           = t_get_struc_unix(clip_wv)
netnr_str      = {X:unix,Y:ne_tot}
store_data,netnr_tpn[0],DATA=netnr_str,DLIMIT=def_dlim,LIMIT=def__lim
options,netnr_tpn[0],LABELS='Ne[TNR]',YTITLE='Ne [cm^(-3), TNR]',/DEFAULT

nna            = [tnames(scpref[0]+'magf_3s_*'),'N_i2',scpref[0]+['Np','Ni_tot_SWE'],netnr_tpn[0]]
tplot,nna
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Find spacecraft potential [eV] from EESA Low VDFs
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
ne_low         = 9d-1*ne_tot
ne_upp         = 11d-1*ne_tot
ne_struc       = {X:unix,Y:[[ne_low],[ne_upp]]}
scpmin         = 1e0
scpmax         = 2e1
scpot_str      = estimate_scpot_wind_eesa_low(ael_,aelb,NETNR=ne_struc,SCPMIN=scpmin,SCPMAX=scpmax)
WDELETE,5        ;;  Close X-Window that was opened/created by estimate_scpot_wind_eesa_low.pro
;;  ****************************************************************************************************************************
;;  ***  Visual inspection of output plots show the V-shaped kink in the VDF occurs around ~7 eV for all VDFs on 2008-09-01  ***
;;  ****************************************************************************************************************************


;;  Array dimensions are defined as:
;;    N  :  # of EESA Low VDFs (combined survey and burst VDFs)
;;    3  :  # of pitch-angle average directions, i.e., parallel, perpendicular, and anti-parallel
;;    2  :  [lower,upper] bounds corresponding to the [lower,upper] bounds of the total electron density provided on input
scpot_pcurv    = scpot_str.SCPOT_POS_CURV                      ;;  [N,3,2]-Element array of SC potential [eV] from positive curvature test
scpot_mxnfE    = scpot_str.SCPOT_DFDE_INFLECT                  ;;  [N,3,2]-Element array of " " from the inflection point where df/dE < 0 --> df/dE > 0
scpot_mnxcr    = scpot_str.SCPOT_MINMAX_CURV                   ;;  [N,3,2]-Element array of " " from minimum/maximum of curvature --> bounds on SC potential
scpot_mnf_E    = scpot_str.SCPOT_MIN_F_E                       ;;  [N,3]-Element array of " " from minimum in f_j(E)

;;  Print one-variable stats of output
conlim            = 9d-1
temp              = '   For 3DP EESA Low '+time_string(MIN(ael_.TIME,/NAN),PREC=1)+'  to  '+time_string(MAX(ael_.END_TIME,/NAN),PREC=1)
onvs_ran          = [scpmin[0],scpmax[0]]
onvs_scposcrv_l   = calc_1var_stats(scpot_pcurv[*,*,0L],/NAN,CONLIM=conlim,PERCENTILES=perc_scposcrv_l,RANGE=onvs_ran)
onvs_scposcrv_u   = calc_1var_stats(scpot_pcurv[*,*,1L],/NAN,CONLIM=conlim,PERCENTILES=perc_scposcrv_u,RANGE=onvs_ran)
onvs_scdfdein_l   = calc_1var_stats(scpot_mxnfE[*,*,0L],/NAN,CONLIM=conlim,PERCENTILES=perc_scdfdein_l,RANGE=onvs_ran)
onvs_scdfdein_u   = calc_1var_stats(scpot_mxnfE[*,*,1L],/NAN,CONLIM=conlim,PERCENTILES=perc_scdfdein_u,RANGE=onvs_ran)
onvs_scmnmxcr_l   = calc_1var_stats(scpot_mnxcr[*,*,0L],/NAN,CONLIM=conlim,PERCENTILES=perc_scmnmxcr_l,RANGE=onvs_ran)
onvs_scmnmxcr_u   = calc_1var_stats(scpot_mnxcr[*,*,1L],/NAN,CONLIM=conlim,PERCENTILES=perc_scmnmxcr_u,RANGE=onvs_ran)
onvs_scpot_minf   = calc_1var_stats(        scpot_mnf_E,/NAN,CONLIM=conlim,PERCENTILES=perc_scpot_minf,RANGE=onvs_ran)

PRINT,';;'+temp[0]  & $
PRINT,';;  SC_low_pc   [eV] ',onvs_scposcrv_l[0],perc_scposcrv_l[0],onvs_scposcrv_l[8],onvs_scposcrv_l[2],onvs_scposcrv_l[3],onvs_scposcrv_l[9],perc_scposcrv_l[1],onvs_scposcrv_l[1]  & $
PRINT,';;  SC_upp_pc   [eV] ',onvs_scposcrv_u[0],perc_scposcrv_u[0],onvs_scposcrv_u[8],onvs_scposcrv_u[2],onvs_scposcrv_u[3],onvs_scposcrv_u[9],perc_scposcrv_u[1],onvs_scposcrv_u[1]  & $
PRINT,';;  SC_low_df   [eV] ',onvs_scdfdein_l[0],perc_scdfdein_l[0],onvs_scdfdein_l[8],onvs_scdfdein_l[2],onvs_scdfdein_l[3],onvs_scdfdein_l[9],perc_scdfdein_l[1],onvs_scdfdein_l[1]  & $
PRINT,';;  SC_upp_df   [eV] ',onvs_scdfdein_u[0],perc_scdfdein_u[0],onvs_scdfdein_u[8],onvs_scdfdein_u[2],onvs_scdfdein_u[3],onvs_scdfdein_u[9],perc_scdfdein_u[1],onvs_scdfdein_u[1]  & $
PRINT,';;  SC_low_xc   [eV] ',onvs_scmnmxcr_l[0],perc_scmnmxcr_l[0],onvs_scmnmxcr_l[8],onvs_scmnmxcr_l[2],onvs_scmnmxcr_l[3],onvs_scmnmxcr_l[9],perc_scmnmxcr_l[1],onvs_scmnmxcr_l[1]  & $
PRINT,';;  SC_upp_xc   [eV] ',onvs_scmnmxcr_u[0],perc_scmnmxcr_u[0],onvs_scmnmxcr_u[8],onvs_scmnmxcr_u[2],onvs_scmnmxcr_u[3],onvs_scmnmxcr_u[9],perc_scmnmxcr_u[1],onvs_scmnmxcr_u[1]  & $
PRINT,';;  SC_min_ff   [eV] ',onvs_scpot_minf[0],perc_scpot_minf[0],onvs_scpot_minf[8],onvs_scpot_minf[2],onvs_scpot_minf[3],onvs_scpot_minf[9],perc_scpot_minf[1],onvs_scpot_minf[1]
;;-----------------------------------------------------------------------------------------------------------------------------------------------------
;;                             Min            05%              25%             Avg             Med             75%             95%             Max
;;=====================================================================================================================================================
;;   For 3DP EESA Low 2008-09-01/00:01:09.7  to  2008-09-01/23:59:28.0
;;  SC_low_pc   [eV]        5.1823433       5.1823433       5.1823433       5.1823433       5.1823433       5.1823433       5.1823433       5.1823433
;;  SC_upp_pc   [eV]        7.7521785       7.7521785       10.139631       11.268646       10.139631       19.838925       19.838925       19.838925
;;  SC_low_df   [eV]        5.6675102       6.7783590       6.7783590       7.0182156       7.0885537       7.0885537       7.0885537       7.0885537
;;  SC_upp_df   [eV]        6.1980980       7.4129436       7.4129436       7.6752554       7.7521785       7.7521785       7.7521785       7.7521785
;;  SC_low_xc   [eV]        5.1823433       5.1823433       5.1823433       5.1823433       5.1823433       5.1823433       5.1823433       5.1823433
;;  SC_upp_xc   [eV]        6.4817385       8.1069376       8.1069376       10.421639       9.2716286       12.681992       12.681992       18.140615
;;  SC_min_ff   [eV]        5.9268696       7.4129436       7.4129436       7.3979873       7.4129436       7.4129436       7.4129436       7.4129436
;;-----------------------------------------------------------------------------------------------------------------------------------------------------

;;  ****************************************************************************************************************************
;;  ***  Looks like the inflection point where df/dE < 0 --> df/dE > 0 and minimum in f_j(E) are most reliable methods       ***
;;  ****************************************************************************************************************************

;;  Send results to TPLOT
scpot_infl_lu  = MEDIAN(scpot_mxnfE,DIMENSION=2)            ;;  Use the median value of the parallel, perpendicular, and anti-parallel estimates
scpot_min___f  = MEDIAN(scpot_mnf_E,DIMENSION=2)
scpot_ilmnflu  = [[scpot_infl_lu[*,0]],[scpot_min___f],[scpot_infl_lu[*,1]]]
scpot_labs     = ['Infl.Pt. Low','Min(f)','Infl.Pt. Upp']
unix_scpot     = MEAN(scpot_str.UNIX,DIMENSION=2,/NAN)
scpot_tpn      = scpref[0]+'SCPot_from_3DP_EL_InL_MNF_InU'
scpot_str      = {X:unix_scpot,Y:scpot_ilmnflu}
store_data,scpot_tpn[0],DATA=scpot_str,DLIMIT=def_dlim,LIMIT=def__lim
options,scpot_tpn[0],LABELS=scpot_labs,YTITLE='Phi_sc [eV, 3DP]',COLORS=vec_col,/DEFAULT
;;  Plot the results for comparison
nna            = [tnames(scpref[0]+'magf_3s_*'),'sc_pot_2',scpot_tpn[0]]
tplot,nna

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Clean up onboard 3DP velocity moments
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Get Np data [cm^(-3)]
get_data,scpref[0]+'Np',DATA=t_3DP_Np,DLIMIT=dlim_3DP_Np,LIMIT=lim__3DP_Np
;;  Get Vp data [km/s]
get_data,scpref[0]+'Vp',DATA=t_3DP_Vp,DLIMIT=dlim_3DP_Vp,LIMIT=lim__3DP_Vp
;;  Clip the 3DP data
clip_Np        = trange_clip_data(t_3DP_Np,TRANGE=trange,PREC=3)
clip_Vp        = trange_clip_data(t_3DP_Vp,TRANGE=trange,PREC=3)
np__ran        = [1d0,1d2]
vpx_ran        = [-10d2,-10d1]
vpy_ran        = [-30d1, 30d1]
vpz_ran        = [-30d1, 30d1]
IF (tdate[0] EQ '2008-09-01') THEN np__ran        = [5d0,1d1]
IF (tdate[0] EQ '2008-09-01') THEN vpx_ran        = [-38d1,-31d1]
IF (tdate[0] EQ '2008-09-01') THEN vpy_ran        = [-30d0, 30d0]
IF (tdate[0] EQ '2008-09-01') THEN vpz_ran        = [-30d0, 30d0]
bad__np        = WHERE(clip_Np.Y LT np__ran[0] OR clip_Np.Y GT np__ran[1],bd__np)
bad_Vpx        = WHERE(clip_Vp.Y[*,0] LT vpx_ran[0] OR clip_Vp.Y[*,0] GT vpx_ran[1],bd_Vpx)
bad_Vpy        = WHERE(clip_Vp.Y[*,1] LT vpy_ran[0] OR clip_Vp.Y[*,1] GT vpy_ran[1],bd_Vpy)
bad_Vpz        = WHERE(clip_Vp.Y[*,2] LT vpz_ran[0] OR clip_Vp.Y[*,2] GT vpz_ran[1],bd_Vpz)
IF (bd__np[0] GT 0) THEN clip_Np.Y[bad__np]   = d
IF (bd_Vpx[0] GT 0) THEN clip_Vp.Y[bad_Vpx,0] = d
IF (bd_Vpy[0] GT 0) THEN clip_Vp.Y[bad_Vpy,1] = d
IF (bd_Vpz[0] GT 0) THEN clip_Vp.Y[bad_Vpz,2] = d
;;  Send back to TPLOT
store_data,scpref[0]+'Np',DATA=clip_Np,DLIMIT=dlim_3DP_Np,LIMIT=lim__3DP_Np
store_data,scpref[0]+'Vp',DATA=clip_Vp,DLIMIT=dlim_3DP_Vp,LIMIT=lim__3DP_Vp
;;  Remove NaNs from these
t_remove_nans_y,scpref[0]+'Np',/NO_EXTRAPOLATE
t_remove_nans_y,scpref[0]+'Vp',/NO_EXTRAPOLATE

;;  Define array of all EESA Low VDFs
IF (nelb[0] GT 0) THEN all_el = [ael_,aelb] ELSE all_el = ael_
sp             = SORT(all_el.TIME)
all_el         = all_el[sp]
n_el           = N_ELEMENTS(all_el)
;;  Add Vp to EESA Low structures
vgse_tpn       = tnames(scpref[0]+'Vp')
add_vsw2,all_el,vgse_tpn[0]
add_vsw2,all_el,vgse_tpn[0],/LEAVE_ALONE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate velocity moments
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
min_scpot      = MIN(scpot_ilmnflu,/NAN,DIMENSION=2,lnind)
max_scpot      = MAX(scpot_ilmnflu,/NAN,DIMENSION=2,lxind)
med_scpot      = MEDIAN(scpot_ilmnflu,DIMENSION=2)
ln_2d          = ARRAY_INDICES(scpot_ilmnflu,lnind)
lx_2d          = ARRAY_INDICES(scpot_ilmnflu,lxind)
ln_1d          = REFORM(ln_2d[1,*])
lx_1d          = REFORM(lx_2d[1,*])
zeros          = REPLICATE(0L,n_el[0])
ones           = zeros + 1L
twos           = ones + 1L
md_1d          = REPLICATE(-1L,n_el[0])
good_0         = WHERE(ln_1d NE 0 AND lx_1d NE 0,gd_0)
good_1         = WHERE(ln_1d NE 1 AND lx_1d NE 1,gd_1)
good_2         = WHERE(ln_1d NE 2 AND lx_1d NE 2,gd_2)
PRINT,';;  ',gd_0[0],gd_1[0],gd_2[0]
;;             4         670         201

IF (gd_0[0] GT 0) THEN md_1d[good_0] = 0L
IF (gd_1[0] GT 0) THEN md_1d[good_1] = 1L
IF (gd_2[0] GT 0) THEN md_1d[good_2] = 2L

;;  Define dummy structure to replicate
dat0           = all_el[0]
dumb           = moments_3d_new(dat0,MAGDIR=dat0[0].MAGF,SC_POT=min_scpot[0])
mom_min        = REPLICATE(dumb[0],n_el[0])
mom_med        = mom_min
mom_max        = mom_min
FOR j=0L, n_el[0] - 1L DO BEGIN                                                     $
  dat0           = all_el[j]                                                      & $
  dat1           = dat0[0]                                                        & $
  dat2           = dat0[0]                                                        & $
  magdir         = REFORM(dat0[0].MAGF)                                           & $
  dat0[0].SC_POT = min_scpot[j]                                                   & $
  dat1[0].SC_POT = med_scpot[j]                                                   & $
  dat2[0].SC_POT = max_scpot[j]                                                   & $
  mom0           = moments_3d_new(dat0,SC_POT=min_scpot[j],MAGDIR=magdir)         & $
  mom1           = moments_3d_new(dat1,SC_POT=med_scpot[j],MAGDIR=magdir)         & $
  mom2           = moments_3d_new(dat2,SC_POT=max_scpot[j],MAGDIR=magdir)         & $
  mom_min[j]     = mom0[0]                                                        & $
  mom_med[j]     = mom1[0]                                                        & $
  mom_max[j]     = mom2[0]

;;  Define velocity moments
vbulk_min      = TRANSPOSE(mom_min.VELOCITY)
vbulk_med      = TRANSPOSE(mom_med.VELOCITY)
vbulk_max      = TRANSPOSE(mom_max.VELOCITY)
tpara_min      =  mom_min.MAGT3[2]
tpara_med      =  mom_med.MAGT3[2]
tpara_max      =  mom_max.MAGT3[2]
tperp_min      = (mom_min.MAGT3[0] + mom_min.MAGT3[1])/2d0
tperp_med      = (mom_med.MAGT3[0] + mom_med.MAGT3[1])/2d0
tperp_max      = (mom_max.MAGT3[0] + mom_max.MAGT3[1])/2d0
tanis_min      = tperp_min/tpara_min
tanis_med      = tperp_med/tpara_med
tanis_max      = tperp_max/tpara_max
tavg__min      =  mom_min.AVGTEMP[0]
tavg__med      =  mom_med.AVGTEMP[0]
tavg__max      =  mom_max.AVGTEMP[0]
dens__min      = mom_min.DENSITY[0]
dens__med      = mom_med.DENSITY[0]
dens__max      = mom_max.DENSITY[0]
;;  Define arrays [min,med,max] for sending to TPLOT
vbulk_x        = [[vbulk_min[*,0]],[vbulk_med[*,0]],[vbulk_max[*,0]]]
vbulk_y        = [[vbulk_min[*,1]],[vbulk_med[*,1]],[vbulk_max[*,1]]]
vbulk_z        = [[vbulk_min[*,2]],[vbulk_med[*,2]],[vbulk_max[*,2]]]
tpara_e        = [[tpara_min],[tpara_med],[tpara_max]]
tperp_e        = [[tperp_min],[tperp_med],[tperp_max]]
tavg__e        = [[tavg__min],[tavg__med],[tavg__max]]
tanis_e        = [[tanis_min],[tanis_med],[tanis_max]]
dens__e        = [[dens__min],[dens__med],[dens__max]]
vmom_labs      = ['Min','Med','Max']
vmom_ysub      = '[EL Vel. Moms]'
vmom_tpn_suff  = '_min_med_max'
vbulk_x_tpn    = scpref[0]+'Vbulk_e_x'+vmom_tpn_suff[0]
vbulk_y_tpn    = scpref[0]+'Vbulk_e_y'+vmom_tpn_suff[0]
vbulk_z_tpn    = scpref[0]+'Vbulk_e_z'+vmom_tpn_suff[0]
tpara_e_tpn    = scpref[0]+'Tpara_e'+vmom_tpn_suff[0]
tperp_e_tpn    = scpref[0]+'Tperp_e'+vmom_tpn_suff[0]
tavg__e_tpn    = scpref[0]+'Tavg__e'+vmom_tpn_suff[0]
tanis_e_tpn    = scpref[0]+'Tanis_e'+vmom_tpn_suff[0]
dens__e_tpn    = scpref[0]+'Dens__e'+vmom_tpn_suff[0]
vmom_unix      = (all_el.END_TIME + all_el.TIME)/2d0
vbulk_x_str    = {X:vmom_unix,Y:vbulk_x}
vbulk_y_str    = {X:vmom_unix,Y:vbulk_y}
vbulk_z_str    = {X:vmom_unix,Y:vbulk_z}
tpara_e_str    = {X:vmom_unix,Y:tpara_e}
tperp_e_str    = {X:vmom_unix,Y:tperp_e}
tavg__e_str    = {X:vmom_unix,Y:tavg__e}
tanis_e_str    = {X:vmom_unix,Y:tanis_e}
dens__e_str    = {X:vmom_unix,Y:dens__e}
;;  Send to TPLOT
store_data,vbulk_x_tpn[0],DATA=vbulk_x_str,DLIMIT=def_dlim,LIMIT=def__lim
store_data,vbulk_y_tpn[0],DATA=vbulk_y_str,DLIMIT=def_dlim,LIMIT=def__lim
store_data,vbulk_z_tpn[0],DATA=vbulk_z_str,DLIMIT=def_dlim,LIMIT=def__lim
store_data,tpara_e_tpn[0],DATA=tpara_e_str,DLIMIT=def_dlim,LIMIT=def__lim
store_data,tperp_e_tpn[0],DATA=tperp_e_str,DLIMIT=def_dlim,LIMIT=def__lim
store_data,tavg__e_tpn[0],DATA=tavg__e_str,DLIMIT=def_dlim,LIMIT=def__lim
store_data,tanis_e_tpn[0],DATA=tanis_e_str,DLIMIT=def_dlim,LIMIT=def__lim
store_data,dens__e_tpn[0],DATA=dens__e_str,DLIMIT=def_dlim,LIMIT=def__lim
all_vmom_tpn   = tnames('*'+vmom_tpn_suff[0])
options,all_vmom_tpn,LABELS=vmom_labs,COLORS=vec_col,YSUBTITLE=vmom_ysub[0],/DEFAULT
options,vbulk_x_tpn[0],YTITLE='Vex [km/s, 3DP]',/DEFAULT
options,vbulk_y_tpn[0],YTITLE='Vey [km/s, 3DP]',/DEFAULT
options,vbulk_z_tpn[0],YTITLE='Vez [km/s, 3DP]',/DEFAULT
options,tpara_e_tpn[0],YTITLE='Te,para [eV, 3DP]',/DEFAULT
options,tperp_e_tpn[0],YTITLE='Te,perp [eV, 3DP]',/DEFAULT
options,tavg__e_tpn[0],YTITLE='Te,avg  [eV, 3DP]',/DEFAULT
options,tanis_e_tpn[0],YTITLE='(Tperp/Tpara)e [eV, 3DP]',/DEFAULT
options,dens__e_tpn[0],YTITLE='Ne [cm^(-3), 3DP]',/DEFAULT

;;  Plot results
nna            = [tnames(scpref[0]+'magf_3s_*'),all_vmom_tpn]
tplot,nna










