;+
;*****************************************************************************************
;
;  CRIBSHEET:   example_load_Wind_data_and_fit_3dp_eesa_low_vdf_crib.pro
;  PURPOSE  :   Similar to example_load_Wind_mfi_swe_3dp_waves_data_crib.pro but here
;                 the additional step of fitting an example VDF is performed to
;                 illustrate how to use the velocity distribution function fitting
;                 software.  This crib also shows how to improve the anode response
;                 function for individual distributions.
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
;               tnames.pro
;               estimate_scpot_wind_eesa_low.pro
;               t_remove_nans_y.pro
;               add_vsw2.pro
;               file_name_times.pro
;               find_strahl_direction.pro
;               mag__vec.pro
;               dat_3dp_str_names.pro
;               sign.pro
;               conv_units.pro
;               conv_vdfidlstr_2_f_vs_vxyz_thm_wi.pro
;               trange_str.pro
;               num2int_str.pro
;               wrapper_fit_vdf_2_sumof3funcs.pro
;               time_string.pro
;               lbw_fitel3d.pro
;               lbw_eldf.pro
;               lbw_el_response.pro
;               lbw_eesal_counts.pro
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
;               3)  The anode response corrections are still a work in progress so take
;                     with a grain of salt (i.e., take care not to blindly trust)
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
;   CREATED:  05/13/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/13/2021   v1.0.1
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
WSET,0
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
;;  ****************************************************************************************************************************
;;  ***  Know from other cribsheet that the inflection point and minimum in f_j(E) are most reliable methods                 ***
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
;;  Add correct spacecraft potentials to VDFs
;;----------------------------------------------------------------------------------------
;;  Define array of all EESA Low VDFs
IF (nelb[0] GT 0) THEN all_el = [ael_,aelb] ELSE all_el = ael_
sp             = SORT(all_el.TIME)
all_el         = all_el[sp]
n_el           = N_ELEMENTS(all_el)
;;  Add SC potentials [eV]
min_scpot      = MIN(scpot_ilmnflu,/NAN,DIMENSION=2,lnind)
max_scpot      = MAX(scpot_ilmnflu,/NAN,DIMENSION=2,lxind)
med_scpot      = MEDIAN(scpot_ilmnflu,DIMENSION=2)
all_el.SC_POT  = med_scpot
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
;;  Add Vp to EESA Low structures
vgse_tpn       = tnames(scpref[0]+'Vp')
add_vsw2,all_el,vgse_tpn[0]
add_vsw2,all_el,vgse_tpn[0],/LEAVE_ALONE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot 2D contour in SWF, in FAC coordinate basis, and fit
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define time ranges
tran_el_        = [[all_el.TIME],[all_el.END_TIME]]
;;  Define file name suffixes
fnm_el_        = file_name_times(tran_el_[*,0],PREC=3)
;;  Define some conversion factors
vte2tekfac      = 1d6*me[0]/2d0/kB[0]      ;;  Converts thermal speed squared to temperature [K]
vte2teevfac     = vte2tekfac[0]*K2eV[0]    ;;  Converts thermal speed squared to temperature [eV]
;;  Define some defaults
dfra_aelb      = [1e-18,1e-9]     ;;  Default VDF range for EESA Low Burst
vlim_aelb      = 20e3             ;;  Default velocity range for EESA Low Burst
xname          = 'Bo'
yname          = 'Vsw'
ttle_ext       = 'SWF'
dfra           = dfra_aelb        ;;  Default VDF range for PESA Low Burst
vlim           = vlim_aelb        ;;  Default velocity range for PESA Low Burst
plane          = 'xy'                        ;;  Y vs. X plane
IF (plane[0] EQ 'xy') THEN k = 0L ELSE   $
  IF (plane[0] EQ 'xz') THEN k = 1L ELSE $
  IF (plane[0] EQ 'yz') THEN k = 2L
;;  Find strahl direction signs (relative to Bo)
strahl         = find_strahl_direction(TRANSPOSE(all_el.MAGF))
;;  Define specific EESA Low Burst VDF [could just as well define PESA Low Burst VDFs]
jj             = 200L
dat0           = all_el[jj]         ;;  EESA Low Burst
;;  Define some more defaults
dumbfix        = REPLICATE(0b,6)
sm_cuts        = 1b                 ;;  Do smooth cuts
sm_cont        = 1b                 ;;  Do smooth contours
nlev           = 30L
ngrid          = 101L
vec1           = REFORM(dat0[0].MAGF)
vec2           = REFORM(dat0[0].VSW)
;;  Define an initial guess for the bi-self-similar parameters of the core electrons
cparm          = [6.5d0,22d2,25d2,-4d2,1d1,3d0]
;;  Define an initial guess for the bi-kappa parameters of the halo electrons
hparm          = [4d-1,50d2,50d2, 2d3,0d0,3d0]
;;  Define an initial guess for the bi-kappa parameters of the strahl electrons
bparm          = [3d-2,50d2,65d2, 4d3,0d0,3d0]
emin_ch        = 2.90d0                   ;;  Lowest energy [eV] to allow for core+halo fits
emin_b         = 10d1                     ;;  Lowest energy [eV] to allow for beam fits
;;  Prevent interpolation below SC potential
IF (dat0.SC_POT[0] GT 0e0) THEN dat0.DATA[WHERE(dat0.ENERGY LE 1.3e0*dat0.SC_POT[0])] = f
;;  Define transformation velocity
vframe         = REFORM(dat0[0].VSW)  ;;  Transformation velocity [km/s]
vfmag          = mag__vec(vframe,/NAN)
;;  Define some plot title stuff
strn_el_       = dat_3dp_str_names(dat0[0])
data_str_el_   = strn_el_[0].SN[0]
fname_mid      = data_str_el_[0]+'-'+fnm_el_[0].F_TIME[jj]
pttl_midf      = strn_el_[0].LC[0]
pttl_pref      = sc[0]+' ['+ttle_ext[0]+'] '+pttl_midf[0]
;;----------------------------------------------------------------------------------------
;;  Account for strahl and define/set limits
;;----------------------------------------------------------------------------------------
;;  Drift Speed constraints
voahalorn      = [1,1,0d0,15d3]
voabeamrn      = [1,1,2d3,15d3]
IF (ABS(strahl[jj]) GT 0) THEN hparm[3]      *= (-1*strahl[jj])
IF (ABS(strahl[jj]) GT 0) THEN bparm[3]      *= (-1*sign(hparm[3]))
IF (ABS(strahl[jj]) GT 0) THEN voabeamrn[2]   = (-1*sign(hparm[3]))*ABS(voabeamrn[2])
IF (ABS(strahl[jj]) GT 0) THEN voabeamrn[3]   = (-1*sign(hparm[3]))*ABS(voabeamrn[3])
IF (ABS(strahl[jj]) GT 0) THEN sp             = SORT(voabeamrn[2:3])
IF (ABS(strahl[jj]) GT 0) THEN IF (sp[0] NE 0) THEN voabeamrn[2:3] = voabeamrn[[3,2]]

IF (ABS(strahl[jj]) GT 0) THEN voahalorn[2:3]   = (-1*strahl[jj])*ABS(voahalorn[2:3])
IF (ABS(strahl[jj]) GT 0) THEN sp               = SORT(voahalorn[2:3])
IF (ABS(strahl[jj]) GT 0) THEN IF (sp[0] NE 0) THEN voahalorn[2:3] = voahalorn[[3,2]]   ;;  Make sure in proper order
IF (ABS(strahl[jj]) GT 0) THEN test           = (sign(hparm[3]) EQ sign(bparm[3])) OR ((sign(voabeamrn[3]) EQ sign(voahalorn[3])) AND (voahalorn[0] GT 0))
IF (test[0]) THEN STOP      ;;  Make sure sign is not screwed up
;;  Thermal Speed constraints
vtahalorn      = [1,1,125d-2*cparm[1],1d4]
vtehalorn      = [1,1,125d-2*cparm[2],1d4]
vtabeamrn      = [1,1,125d-2*cparm[1],1d4]
vtebeamrn      = [1,1,125d-2*cparm[2],1d4]
;;  Exponent constraints
;;    Note that while the kappa value can, in principle, go down to 3/2, I have found
;;      that any values below 2.0 start to look like unrealistic ``spiky'' fits, which
;;      do not seem to care about the data at all.  That is, the output looks obviously
;;      wrong/bad and even though the reduced chi-squared may look okay.
expcorern      = [1,1,2d0,1d1]        ;;  Use the ES2CORERN keyword if CFUNC = 'AS' --> also need to change values of CPARM[4] and CPARM[5]
exphalorn      = [1,1,1.75d0,10d1]
expbeamrn      = exphalorn

fixed_c        = dumbfix
fixed_h        = dumbfix
fixed_b        = dumbfix
fixed_h[4]     = 1b                       ;;  Prevent fit routines from varying perpendicular drift velocity
fixed_b[4]     = 1b                       ;;  Prevent fit routines from varying perpendicular drift velocity
;;  Setup fit function stuff
cfunc          = 'SS'
hfunc          = 'KK'
bfunc          = 'KK'
;;----------------------------------------------------------------------------------------
;;  Define VDF, errors, and weights
;;----------------------------------------------------------------------------------------
;;  Define one-count level VDF
datc           = dat0[0]
datc.DATA      = 1e0            ;;  Create a one-count copy
;;  Define Poisson statistics VDF
datp           = dat0[0]
datp.DATA      = SQRT(dat0[0].DATA)
;;  Convert to phase space density [# cm^(-3) km^(-3) s^(+3)]
;;    [works on Wind 3DP or THEMIS ESA distributions sent in as IDL structures]
dat_df         = conv_units(dat0,'df')
dat_1c         = conv_units(datc,'df')
dat_ps         = conv_units(datp,'df')
;;  Convert F(energy,theta,phi) to F(Vx,Vy,Vz)
;;    [works on Wind 3DP or THEMIS ESA distributions sent in as IDL structures]
dat_fvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_df)
dat_1cxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_1c)
dat_psxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_ps)
;;  Define EX_VECS stuff  (for general_vdf_contour_plot.pro)
dumb_exv       = {VEC:REPLICATE(0e0,3L),NAME:''}
ex_vecs        = REPLICATE(dumb_exv[0],4L)
ex_vecs[0]     = {VEC:FLOAT(dat_df[0].VSW),NAME:'Vsw'}
ex_vecs[1]     = {VEC:FLOAT(dat_df[0].MAGF),NAME:'Bo'}
ex_vecs[2]     = {VEC:FLOAT([0e0,1e0,0e0]),NAME:'Ygse'}
ex_vecs[3]     = {VEC:[1e0,0e0,0e0],NAME:'Sun'}
;;  Define EX_INFO stuff  (for general_vdf_contour_plot.pro)
x_inds         = [0L,2L,1L]
y_inds         = [1L,0L,2L]
ex_info        = {SCPOT:dat_df[0].SC_POT,VSW:dat_df[0].VSW,MAGF:dat_df[0].MAGF}
sm_cuts        = 1b               ;;  Do not smooth cuts
sm_cont        = 1b               ;;  Do not smooth contours
IF (vfmag[0] LT 1e0) THEN vxy_offs = [ex_info.VSW[xyind[0:1]]] ELSE vxy_offs = [0e0,0e0]  ;;  XY-Offsets of crosshairs

ptitle         = pttl_pref[0]+': '+trange_str(tran_el_[jj,0],tran_el_[jj,1],/MSEC)
;;  Define data arrays
data_1d        = dat_fvxyz.VDF                  ;;  [N]-Element [numeric] array of phase space densities [# s^(+3) km^(-3) cm^(-3)]
vels_1d        = dat_fvxyz.VELXYZ               ;;  [N,3]-Element [numeric] array of 3-vector velocities [km/s] corresponding to the phase space densities
onec_1d        = dat_1cxyz.VDF                  ;;  [N]-Element [numeric] array of one-count levels in units of phase space densities [# s^(+3) km^(-3) cm^(-3)]
pois_1d        = dat_psxyz.VDF                  ;;  [N]-Element [numeric] array of Poisson statistics [# cm^(-3) km^(-3) s^(+3)]
;;----------------------------------------------------------------------------------------
;;  Fit to sum of 3 functions
;;----------------------------------------------------------------------------------------
;;  Compile necessary routines to make sure IDL paths are okay and routines are available
.compile mpfit.pro
.compile mpfit2dfun.pro
.compile get_defaults_4_parinfo_struc4mpfit_4_vdfs.pro
.compile test_ranges_4_mpfitparinfostruc.pro
.compile plot_vdfs_4_fitvdf2sumof3funcs.pro
.compile wrapper_fit_vdf_2_sumof3funcs.pro
;;  Define file name
vlim_str       = num2int_str(vlim[0],NUM_CHAR=6L,/ZERO_PAD)
fname_end      = 'para-red_perp-blue_1count-green_plane-'+plane[0]+'_VLIM-'+vlim_str[0]+'km_s'
fname_pre      = scpref[0]+'df_'+ttle_ext[0]+'_'
fnams_out2     = fname_pre[0]+fname_mid+'_'+fname_end[0]+'_Fits_Core-SS_Halo-KK_wo-strahl_Beam-KK'

;;  Save Plot [showing each 1D cut individually and total sum of three fits]
out_struc      = 0
wrapper_fit_vdf_2_sumof3funcs,data_1d,vels_1d,VFRAME=vframe,VEC1=vec1,VEC2=vec2,COREP=cparm,$
                          HALOP=hparm,BEAMP=bparm,CFUNC=cfunc,HFUNC=hfunc,BFUNC=bfunc,      $
                          VLIM=vlim[0],PLANE=plane[0],NLEV=nlev,NGRID=ngrid,DFRA=dfra,      $
                          SM_CUTS=sm_cuts,SM_CONT=sm_cont,XNAME=xname,YNAME=yname,          $
                          EX_VECS=ex_vecs,EX_INFO=ex_info,V_0X=vxy_offs[0],                 $
                          V_0Y=vxy_offs[1],/SLICE2D,ONE_C=onec_1d,P_TITLE=ptitle,           $
                          /STRAHL,V1ISB=strahl[jj],OUTSTRC=out_struc,                       $
                          FIXED_C=fixed_c,FIXED_H=fixed_h,FIXED_B=fixed_b,                  $
                          VOABEAMRN=voabeamrn,VOAHALORN=voahalorn,VOACORERN=voacorern,      $
                          VTABEAMRN=vtabeamrn,VTEBEAMRN=vtebeamrn,NBEAM_RAN=nbeam_ran,      $
                          VTACORERN=vtacorern,VTECORERN=vtecorern,NCORE_RAN=ncore_ran,      $
                          VTAHALORN=vtahalorn,VTEHALORN=vtehalorn,NHALO_RAN=nhalo_ran,      $
                          EXPCORERN=expcorern,EXPBEAMRN=expbeamrn,EXPHALORN=exphalorn,      $
                          ES2CORERN=es2corern,ES2HALORN=es2halorn,ES2BEAMRN=es2beamrn,      $
                          EMIN_CH=emin__ch,EMIN_B=emin__b,EMAX_CH=emax__ch,EMAX_B=emax__b,  $
                          FTOL=def_ftol,GTOL=def_gtol,XTOL=def_xtol,POISSON=pois_1d,        $
                          /PLOT_BOTH,NOUSECTAB=nousectab,S_SIGN=s_sign,                     $
                          /SAVEF,/KEEPNAN,FILENAME=fnams_out2[0]

;;  Wind [SWF] Eesa Low Burst: 2008-09-01/05:28:55.568 - 05:28:58.625
;;  
;;  
;;  N_oc     =  +5.5294e+00 +/- 5.9901e-03  cm^(-3)
;;  V_Tcpar  =  +2.1085e+03 +/- 1.0506e+00  km s^(-1)
;;  V_Tcper  =  +2.1110e+03 +/- 9.9517e-01  km s^(-1)
;;  V_ocpar  =  -0.0000e+00 +/- 0.0000e+00  km s^(-1)
;;  V_ocper  =  -2.0137e+01 +/- 9.2333e-01  km s^(-1)
;;  SS expc  =  +2.0000e+00 +/- 0.0000e+00  
;;  Model Fit Status  = 000002
;;  # of Iterations   = 000005
;;  Deg. of Freedom   = 0000010195
;;  Chi-Squared       = 1.0458e+04
;;  Red. Chi-Squared  = 1.0258e+00
;;  
;;  N_oh     =  +2.5571e-01 +/- 1.8108e-03  cm^(-3)
;;  V_Thpar  =  +4.3833e+03 +/- 8.1217e+00  km s^(-1)
;;  V_Thper  =  +4.4354e+03 +/- 8.1044e+00  km s^(-1)
;;  V_ohpar  =  -0.0000e+00 +/- 0.0000e+00  km s^(-1)
;;  V_ohper  =  -0.0000e+00 +/- 0.0000e+00  km s^(-1)
;;  kappah   =  +9.4744e+00 +/- 5.4821e-02  
;;  Model Fit Status  = 000002
;;  # of Iterations   = 000025
;;  Deg. of Freedom   = 0000010196
;;  Chi-Squared       = 8.2198e+03
;;  Red. Chi-Squared  = 8.0618e-01
;;  
;;  N_ob     =  +1.2119e-01 +/- 1.5868e-03  cm^(-3)
;;  V_Tbpar  =  +3.3834e+03 +/- 1.5772e+01  km s^(-1)
;;  V_Tbper  =  +3.2896e+03 +/- 1.6403e+01  km s^(-1)
;;  V_obpar  =  -2.0000e+03 +/- 0.0000e+00  km s^(-1)
;;  V_obper  =  -0.0000e+00 +/- 0.0000e+00  km s^(-1)
;;  kappab   =  +3.6149e+00 +/- 2.6033e-02  
;;  Model Fit Status  = 000002
;;  # of Iterations   = 000026
;;  Deg. of Freedom   = 0000010196
;;  Chi-Squared       = 6.5075e+03
;;  Red. Chi-Squared  = 6.3824e-01
;;  

PRINT,';;  Wind [SWF] Eesa Low Burst: '+time_string(tran_el_[jj,0L],PREC=3)+'  --  '+time_string(tran_el_[jj,1L],PREC=3)  & $
PRINT,';;  Fit Flags = ',out_struc.FIT_FLAGS
;;  Wind [SWF] Eesa Low Burst: 2008-09-01/05:28:55.568  --  2008-09-01/05:28:58.625
;;  Fit Flags =           10          10          10


;;  Check against other known values
ntnr_at_vdf    = t_resample_tplot_struc(netnr_str,REFORM(tran_el_[jj,*]),/NO_EXTRAPOLATE,/IGNORE_INT)
n3dp_at_vdf    = t_resample_tplot_struc(t_3DP_Np,REFORM(tran_el_[jj,*]),/NO_EXTRAPOLATE,/IGNORE_INT)
nfit_sum_3s    = out_struc.CORE.FIT_PARAMS[0] + out_struc.HALO.FIT_PARAMS[0] + out_struc.BEAM.FIT_PARAMS[0]

;;  Print comparison
PRINT,';;  Wind [SWF] Eesa Low Burst: '+time_string(tran_el_[jj,0L],PREC=3)+'  --  '+time_string(tran_el_[jj,1L],PREC=3)  & $
PRINT,';;  Ne[TNR] [cm^(-3)] : ',MEAN(ntnr_at_vdf.Y,/NAN)                                                                 & $
PRINT,';;  Np[3DP] [cm^(-3)] : ',MEAN(n3dp_at_vdf.Y,/NAN)                                                                 & $
PRINT,';;  Ne[Fit] [cm^(-3)] : ',nfit_sum_3s[0]
;;  Wind [SWF] Eesa Low Burst: 2008-09-01/05:28:55.568  --  2008-09-01/05:28:58.625
;;  Ne[TNR] [cm^(-3)] :        7.5527095
;;  Np[3DP] [cm^(-3)] :        6.6589519
;;  Ne[Fit] [cm^(-3)] :        5.9062454


;;  Check the percent error between these two "standards"
perc_tnr       = (MEAN(ntnr_at_vdf.Y,/NAN) - nfit_sum_3s[0])/MEAN(ntnr_at_vdf.Y,/NAN)*1d2
perc_3dp       = (MEAN(n3dp_at_vdf.Y,/NAN) - nfit_sum_3s[0])/MEAN(n3dp_at_vdf.Y,/NAN)*1d2
PRINT,';;  Wind [SWF] Eesa Low Burst: '+time_string(tran_el_[jj,0L],PREC=3)+'  --  '+time_string(tran_el_[jj,1L],PREC=3)  & $
PRINT,';;  ∆Ne[TNR] [%] : ',perc_tnr[0]                                                                                   & $
PRINT,';;  ∆Ne[3DP] [%] : ',perc_3dp[0]
;;  Wind [SWF] Eesa Low Burst: 2008-09-01/05:28:55.568  --  2008-09-01/05:28:58.625
;;  ∆Ne[TNR] [%] :        21.799648
;;  ∆Ne[3DP] [%] :        11.303677



;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate the instrument response
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  So the above shows that the default anode efficiency corrections to the geometric
;;    factor are not good enough, so let's see if we can improve on that.

;;----------------------------------------------------------------------------------------
;;  Start with a 1D fit
;;----------------------------------------------------------------------------------------

;;  Compile necessary routines
.compile lbw_photo_eflux.pro
.compile lbw_mcp_e_eff.pro
.compile lbw_eldf.pro
.compile lbw_el_response.pro
.compile lbw_eesal_counts.pro
.compile lbw_fit_el_for_response.pro
.compile lbw_fitel3d.pro
.compile get_1d_cut_from_2d_model_vdf.pro

;;  Get dummy structure for format
DELVAR,pstruc1,opts1
test           = lbw_fitel3d(GUESS=pstruc1,OPTIONS=opts1)
;;  Define specific EESA Low Burst VDF [could just as well define PESA Low Burst VDFs]
jj             = 200L
dat0           = all_el[jj]         ;;  EESA Low Burst
;;  Define some values from the fit parameters above
no_ec_tot      = out_struc.CORE.FIT_PARAMS[0]                                             ;;  n_ec [cm^(-3)]
vo_ec_par      = out_struc.CORE.FIT_PARAMS[3]                                             ;;  V_oec,// [km/s]
T__ec_par      = (out_struc.CORE.FIT_PARAMS[1]/vtefac[0])^2d0                             ;;  Tec,para [eV]
T__ec_per      = (out_struc.CORE.FIT_PARAMS[2]/vtefac[0])^2d0                             ;;  Tec,perp [eV]
T__ec_avg      = (T__ec_par[0] + 2d0*T__ec_per[0])/3d0                                    ;;  T_ec = (Tec,para + 2*Tec,perp)/3 [eV]
A__ec_KP6      = out_struc.CORE.FIT_PARAMS[2]/out_struc.CORE.FIT_PARAMS[1] - 1d0          ;;  A = Tperp/Tpara - 1
no_eh_tot      = out_struc.HALO.FIT_PARAMS[0]                                             ;;  n_eh [cm^(-3)]
vo_eh_par      = out_struc.HALO.FIT_PARAMS[3]                                             ;;  V_oeh,// [km/s]
T__eh_par      = (out_struc.HALO.FIT_PARAMS[1]/vtefac[0])^2d0                             ;;  Teh,para [eV]
T__eh_per      = (out_struc.HALO.FIT_PARAMS[2]/vtefac[0])^2d0                             ;;  Teh,perp [eV]
T__eh_avg      = (T__eh_par[0] + 2d0*T__eh_per[0])/3d0                                    ;;  T_eh = (Teh,para + 2*Teh,perp)/3 [eV]
V_Teh_avg      = vtefac[0]*SQRT(T__eh_avg[0])                                             ;;  Veh,th [km/s]
kappa_h__      = out_struc.HALO.FIT_PARAMS[5]                                             ;;  kappa exponent of halo
no_eb_tot      = out_struc.BEAM.FIT_PARAMS[0]                                             ;;  n_eb [cm^(-3)]
vo_eb_par      = out_struc.BEAM.FIT_PARAMS[3]                                             ;;  V_oeb,// [km/s]
T__eb_par      = (out_struc.BEAM.FIT_PARAMS[1]/vtefac[0])^2d0                             ;;  Teb,para [eV]
T__eb_per      = (out_struc.BEAM.FIT_PARAMS[2]/vtefac[0])^2d0                             ;;  Teb,perp [eV]
T__eb_avg      = (T__eb_par[0] + 2d0*T__eb_per[0])/3d0                                    ;;  T_eb = (Teb,para + 2*Teb,perp)/3 [eV]
V_Teb_avg      = vtefac[0]*SQRT(T__eb_avg[0])                                             ;;  Veb,th [km/s]
kappa_b__      = out_struc.BEAM.FIT_PARAMS[5]                                             ;;  kappa exponent of beam/strahl
;;  Use combined halo+strahl for fit
no_es_tot      = no_eh_tot[0] + no_eb_tot[0]                                              ;;  n_es [cm^(-3)]
vo_es_par      = (no_eh_tot[0]*vo_eh_par[0] + no_eb_tot[0]*vo_eb_par[0])/no_es_tot[0]     ;;  V_oes,// [km/s]
T__es_avg      = (no_eh_tot[0]*T__eh_avg[0] + no_eb_tot[0]*T__eb_avg[0])/no_es_tot[0]     ;;  T_es [eV]
V_Tes_avg      = vtefac[0]*SQRT(T__es_avg[0])                                             ;;  Ves,th [km/s]
kappa_s__      = MEAN([kappa_h__[0],kappa_b__[0]])                                        ;;  mean kappa exponent of suprathermal electrons
;;  Fill values accordingly
pstruc1.SC_POT    = dat0[0].SC_POT[0]
pstruc1.VSW       = REFORM(dat0[0].VSW)
pstruc1.MAGF      = REFORM(dat0[0].MAGF)
pstruc1.NTOT      = MEAN(ntnr_at_vdf.Y,/NAN)
pstruc1.CORE.N    = no_ec_tot[0]
pstruc1.CORE.T    = T__ec_per[0]
pstruc1.CORE.V    = vo_ec_par[0]
pstruc1.CORE.TDIF = A__ec_KP6[0]
pstruc1.HALO.N    = no_es_tot[0]
pstruc1.HALO.V    = vo_es_par[0]
pstruc1.HALO.VTH  = V_Tes_avg[0]
pstruc1.HALO.K    = kappa_s__[0]
;;  Alter OPTIONS structure
opts1.EMIN     = 0e0
opts1.EMAX     = 1e3
opts1.DFMIN    = 1e-16
;;  Try fitting to model
opts           = opts1
fitres         = 1
dat1           = dat0[0]
guess          = pstruc1
fit_str        = lbw_fitel3d(dat1,OPTIONS=opts,GUESS=guess,FDAT=fdat,XCHI=xchi,FITRESULT=fitres)
;;  Print results
scpot_fit      = fit_str[0].SC_POT[0]                                 ;;  SC potential [eV]
netot_fit      = fit_str[0].NTOT[0]                                   ;;  ne    [cm^(-3)]
tperc_fit      = fit_str[0].CORE[0].T[0]                              ;;  Tperp [eV]
tparc_fit      = tperc_fit[0]/(1d0 + fit_str[0].CORE[0].TDIF[0])      ;;  Tpara [eV]
vo_ec_fit      = fit_str[0].CORE[0].V[0]                              ;;  Vo,// [km/s]
n__ec_fit      = fit_str[0].CORE[0].N[0]                              ;;  ne    [cm^(-3)]

vtheh_fit      = fit_str[0].HALO[0].VTH[0]                            ;;  Vth [km/s]
ttoth_fit      = (vtheh_fit[0]/vtefac[0])^2d0                         ;;  T_tot [eV]
n__eh_fit      = fit_str[0].HALO[0].N[0]                              ;;  ne    [cm^(-3)]
kapph_fit      = fit_str[0].HALO[0].K[0]                              ;;  kappa exponent
vo_eh_fit      = fit_str[0].HALO[0].V[0]                              ;;  Vo,// [km/s]
PRINT,';;  For EESA Low at '+time_string(dat0[0].TIME,PREC=3)    & $
PRINT,';;  ',netot_fit[0],n__ec_fit[0],n__eh_fit[0],scpot_fit[0] & $
PRINT,';;  ',tparc_fit[0],tperc_fit[0],ttoth_fit[0],vo_ec_fit[0],vo_eh_fit[0],kapph_fit[0]
;;  For EESA Low at 2008-09-01/05:28:55.568
;;         4.7363951       4.4608114      0.27558372       7.4129438
;;         11.084827       10.683894       49.801772      -72.300771      -432.24737       10.895649

;;----------------------------------------------------------------------------------------
;;  Now try to find anode corrections
;;----------------------------------------------------------------------------------------
;;  Model results
DELVAR,pstr0
dumb               = lbw_eldf(PARAM=pstr0)
pstr0.SC_POT       = dat0[0].SC_POT[0]
pstr0.VSW          = REFORM(dat0[0].VSW)
pstr0.MAGF         = REFORM(dat0[0].MAGF)
pstr0.NTOT         = MEAN(ntnr_at_vdf.Y,/NAN)
pstr0.FIX_SCP_WGHT = 1
;;  Define core and halo values
pstr0.CORE.N       = n__ec_fit[0]
pstr0.CORE.T       = (tparc_fit[0] + 2d0*tperc_fit[0])/3d0
pstr0.CORE.V       = vo_ec_fit[0]
pstr0.CORE.TRAT    = tparc_fit[0]/tperc_fit[0]
pstr0.HALO.N       = n__eh_fit[0]
pstr0.HALO.T       = ttoth_fit[0]
pstr0.HALO.V       = vo_eh_fit[0]
pstr0.HALO.TRAT    = 1d0
;;  Define VDF params
nen                = dat0[0].NENERGY[0]
nan                = dat0[0].NBINS[0]
eners              = dat0[0].ENERGY
the                = dat0[0].THETA
phi                = dat0[0].PHI
pstr               = pstr0
vdf1               = lbw_eldf(eners,the,phi,PARAM=pstr)
;;  Calculate instrument response
ps1                = pstruc1
nn                 = dat0[0].NENERGY[0]
expnd              = ps1.EXPAND*2
volt1              = dat0[0].VOLTS + ps1[0].V_SHIFT
resp1              = lbw_el_response(volt1,ener1,dener1,NSTEPS=expnd[0]*nn[0])
;;  Determine analyzer efficiencies
DELVAR,pstruc2
dumb               = lbw_eesal_counts(PARAMETERS=pstruc2)
pstruc2.MP         = pstr
pstruc             = pstruc2
t_cnts             = REFORM(dat0[0].DATA,nen[0]*nan[0])
dat_cc             = lbw_eesal_counts(dat0,ENERGY=ener_out,PARAMETERS=pstruc)
ratio_cc           = dat_cc/t_cnts
;;  compute analyzer constant by anode
anode              = BYTE((90 - dat0[0].THETA)/22.5)
good_a0            = WHERE(anode EQ 0b,gd_a0)
good_a1            = WHERE(anode EQ 1b,gd_a1)
good_a2            = WHERE(anode EQ 2b,gd_a2)
good_a3            = WHERE(anode EQ 3b,gd_a3)
good_a4            = WHERE(anode EQ 4b,gd_a4)
good_a5            = WHERE(anode EQ 5b,gd_a5)
good_a6            = WHERE(anode EQ 6b,gd_a6)
good_a7            = WHERE(anode EQ 7b,gd_a7)
PRINT,';;  ',gd_a0[0],gd_a1[0],gd_a2[0],gd_a3[0],gd_a4[0],gd_a5[0],gd_a6[0],gd_a7[0]
;;            60         120         240         240         240         240         120          60

;;  Clean up response plotting windows
WDELETE,5
WDELETE,6
WDELETE,7
;;  Calculate one-variable stats on these corrections
onevs_ra0      = calc_1var_stats(ratio_cc[good_a0],/NAN)
onevs_ra1      = calc_1var_stats(ratio_cc[good_a1],/NAN)
onevs_ra2      = calc_1var_stats(ratio_cc[good_a2],/NAN)
onevs_ra3      = calc_1var_stats(ratio_cc[good_a3],/NAN)
onevs_ra4      = calc_1var_stats(ratio_cc[good_a4],/NAN)
onevs_ra5      = calc_1var_stats(ratio_cc[good_a5],/NAN)
onevs_ra6      = calc_1var_stats(ratio_cc[good_a6],/NAN)
onevs_ra7      = calc_1var_stats(ratio_cc[good_a7],/NAN)

PRINT,';;  jj = ',jj[0],'  -->  '+time_string(dat0[0].TIME,PREC=3)    & $
PRINT,';;  Anode 0 : ',onevs_ra0                                      & $
PRINT,';;  Anode 1 : ',onevs_ra1                                      & $
PRINT,';;  Anode 2 : ',onevs_ra2                                      & $
PRINT,';;  Anode 3 : ',onevs_ra3                                      & $
PRINT,';;  Anode 4 : ',onevs_ra4                                      & $
PRINT,';;  Anode 5 : ',onevs_ra5                                      & $
PRINT,';;  Anode 6 : ',onevs_ra6                                      & $
PRINT,';;  Anode 7 : ',onevs_ra7
;;                    Min               Max             Mean           Median         StdDev.        StDvMn.           Skew.           Kurt.            Q1               Q2             IQM           Tot.  #         Fin.  #
;;  jj =          200  -->  2008-09-01/05:28:55.568
;;  Anode 0 :    0.00099652998       3.1055824       1.0225713      0.88367148      0.71097846     0.093356045       1.3413093       1.6862987      0.71899361       1.1306406      0.90892600       60.000000       58.000000
;;  Anode 1 :     0.0017051991       3.3379807       1.0896276      0.90136793      0.75283633     0.070820885       1.4119679       1.5219580      0.71814045       1.1329352      0.91074525       120.00000       113.00000
;;  Anode 2 :     0.0013025617       3.6260627       1.1622542      0.93178427      0.79489424     0.053230056       1.5132705       1.8472274      0.76203243       1.2031010      0.96471432       240.00000       223.00000
;;  Anode 3 :    0.00027371238       4.1029255       1.1802768       1.0009687      0.81536884     0.054117931       1.5798484       2.4097519      0.78707885       1.2509240       1.0091824       240.00000       227.00000
;;  Anode 4 :     0.0024100597       4.2044795       1.2005643      0.96672356      0.86556771     0.057449747       1.6871045       2.5194214      0.79345108       1.2027420      0.98421109       240.00000       227.00000
;;  Anode 5 :    0.00043062260       3.8930462       1.1428691      0.96735574      0.82801282     0.054836489       1.7220823       2.7436773      0.79320509       1.1167606      0.96068631       240.00000       228.00000
;;  Anode 6 :     0.0014429395       3.3459006       1.0610395      0.93194724      0.74803964     0.068862631       1.4082634       1.8727380      0.77832873       1.0702006      0.93037756       120.00000       118.00000
;;  Anode 7 :     0.0025224652       3.0745993       1.0495376      0.96496248      0.62433879     0.081979699       1.1786811       1.9675281      0.83367133       1.1583405      0.97015999       60.000000       58.000000

def_anode_eff  = [0.977,1.019,0.990,1.125,1.154,0.998,0.977,1.005]
avg_anode_eff  = [onevs_ra0[2],onevs_ra1[2],onevs_ra2[2],onevs_ra3[2],onevs_ra4[2],onevs_ra5[2],onevs_ra6[2],onevs_ra7[2]]
med_anode_eff  = [onevs_ra0[3],onevs_ra1[3],onevs_ra2[3],onevs_ra3[3],onevs_ra4[3],onevs_ra5[3],onevs_ra6[3],onevs_ra7[3]]
PRINT,';;  jj = ',jj[0],'  -->  '+time_string(dat0[0].TIME,PREC=3)    & $
PRINT,';;  Mean Eff.     :  ',avg_anode_eff,FORMAT='(a21,8f12.3)'     & $
PRINT,';;  Median Eff.   :  ',med_anode_eff,FORMAT='(a21,8f12.3)'
;;----------------------------------------------------------------------------------------------------------------------
;;                         Anode 0     Anode 1     Anode 2     Anode 3     Anode 4     Anode 5     Anode 6     Anode 7
;;  Default Eff.  ;         0.977       1.019       0.990       1.125       1.154       0.998       0.977       1.005
;;----------------------------------------------------------------------------------------------------------------------
;;  jj =          200  -->  2008-09-01/05:28:55.568
;;  Mean Eff.     :         1.023       1.090       1.162       1.180       1.201       1.143       1.061       1.050
;;  Median Eff.   :         0.884       0.901       0.932       1.001       0.967       0.967       0.932       0.965
;;----------------------------------------------------------------------------------------------------------------------

diff_def2avg   = (def_anode_eff - avg_anode_eff)
diff_def2med   = (def_anode_eff - med_anode_eff)
perc_def2avg   = 1d2*diff_def2avg/def_anode_eff
perc_def2med   = 1d2*diff_def2med/def_anode_eff
sep            = '"  |"'
nform          = 'f9.3'
mform          = '(a40,'+nform[0]+','+sep[0]+','+nform[0]+','+sep[0]+','+nform[0]+','+sep[0]+','+nform[0]+','+sep[0]+','+nform[0]+','+sep[0]+','+nform[0]+','+sep[0]+','+nform[0]+','+sep[0]+','+nform[0]+')'
PRINT,';;  jj = ',jj[0],'  -->  '+time_string(dat0[0].TIME,PREC=3)                     & $
PRINT,';;  (Eff_def - Eff_avg)/Eff_def [%]  :  ',perc_def2avg,FORMAT=mform[0]          & $
PRINT,';;  (Eff_def - Eff_med)/Eff_med [%]  :  ',perc_def2med,FORMAT=mform[0]
;;                                        Anode 0     Anode 1     Anode 2     Anode 3     Anode 4     Anode 5     Anode 6     Anode 7
;;  jj =          200  -->  2008-09-01/05:28:55.568
;;  (Eff_def - Eff_avg)/Eff_def [%]  :     -4.664  |   -6.931  |  -17.399  |   -4.913  |   -4.035  |  -14.516  |   -8.602  |   -4.432
;;  (Eff_def - Eff_med)/Eff_med [%]  :      9.553  |   11.544  |    5.880  |   11.025  |   16.228  |    3.071  |    4.611  |    3.984



;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Now use this instrument response and update 2D fit results
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define specific EESA Low Burst VDF [could just as well define PESA Low Burst VDFs]
jj             = 200L
dat0           = all_el[jj]         ;;  EESA Low Burst
;;  Use the median values for instrument response
anode          = BYTE((90 - dat0[0].THETA)/22.5)
relgeom        = 4*FLOAT(med_anode_eff)
dat0[0].GF     = relgeom[anode]
;;  Define some more defaults
dumbfix        = REPLICATE(0b,6)
sm_cuts        = 1b                 ;;  Do smooth cuts
sm_cont        = 1b                 ;;  Do smooth contours
nlev           = 30L
ngrid          = 101L
vec1           = REFORM(dat0[0].MAGF)
vec2           = REFORM(dat0[0].VSW)
;;  Prevent interpolation below SC potential
IF (dat0.SC_POT[0] GT 0e0) THEN dat0.DATA[WHERE(dat0.ENERGY LE 1.3e0*dat0.SC_POT[0])] = f
;;  Use the same initial guesses as before so do not change...
;;  Define one-count level VDF
datc           = dat0[0]
datc.DATA      = 1e0            ;;  Create a one-count copy
;;  Define Poisson statistics VDF
datp           = dat0[0]
datp.DATA      = SQRT(dat0[0].DATA)
;;  Convert to phase space density [# cm^(-3) km^(-3) s^(+3)]
;;    [works on Wind 3DP or THEMIS ESA distributions sent in as IDL structures]
dat_df         = conv_units(dat0,'df')
dat_1c         = conv_units(datc,'df')
dat_ps         = conv_units(datp,'df')
;;  Convert F(energy,theta,phi) to F(Vx,Vy,Vz)
;;    [works on Wind 3DP or THEMIS ESA distributions sent in as IDL structures]
dat_fvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_df)
dat_1cxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_1c)
dat_psxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_ps)
;;  Define data arrays
data_1d        = dat_fvxyz.VDF                  ;;  [N]-Element [numeric] array of phase space densities [# s^(+3) km^(-3) cm^(-3)]
vels_1d        = dat_fvxyz.VELXYZ               ;;  [N,3]-Element [numeric] array of 3-vector velocities [km/s] corresponding to the phase space densities
onec_1d        = dat_1cxyz.VDF                  ;;  [N]-Element [numeric] array of one-count levels in units of phase space densities [# s^(+3) km^(-3) cm^(-3)]
pois_1d        = dat_psxyz.VDF                  ;;  [N]-Element [numeric] array of Poisson statistics [# cm^(-3) km^(-3) s^(+3)]
;;  Compile necessary routines to make sure IDL paths are okay and routines are available
.compile mpfit.pro
.compile mpfit2dfun.pro
.compile get_defaults_4_parinfo_struc4mpfit_4_vdfs.pro
.compile test_ranges_4_mpfitparinfostruc.pro
.compile plot_vdfs_4_fitvdf2sumof3funcs.pro
.compile wrapper_fit_vdf_2_sumof3funcs.pro
;;  Define file name
vlim_str       = num2int_str(vlim[0],NUM_CHAR=6L,/ZERO_PAD)
fname_end      = 'para-red_perp-blue_1count-green_plane-'+plane[0]+'_VLIM-'+vlim_str[0]+'km_s'
fname_pre      = scpref[0]+'df_'+ttle_ext[0]+'_'
fnams_out2     = fname_pre[0]+fname_mid+'_'+fname_end[0]+'_Fits_Core-SS_Halo-KK_wo-strahl_Beam-KK_corr'

;;  Save Plot [showing each 1D cut individually and total sum of three fits]
out_strcc      = 0
wrapper_fit_vdf_2_sumof3funcs,data_1d,vels_1d,VFRAME=vframe,VEC1=vec1,VEC2=vec2,COREP=cparm,$
                          HALOP=hparm,BEAMP=bparm,CFUNC=cfunc,HFUNC=hfunc,BFUNC=bfunc,      $
                          VLIM=vlim[0],PLANE=plane[0],NLEV=nlev,NGRID=ngrid,DFRA=dfra,      $
                          SM_CUTS=sm_cuts,SM_CONT=sm_cont,XNAME=xname,YNAME=yname,          $
                          EX_VECS=ex_vecs,EX_INFO=ex_info,V_0X=vxy_offs[0],                 $
                          V_0Y=vxy_offs[1],/SLICE2D,ONE_C=onec_1d,P_TITLE=ptitle,           $
                          /STRAHL,V1ISB=strahl[jj],OUTSTRC=out_strcc,                       $
                          FIXED_C=fixed_c,FIXED_H=fixed_h,FIXED_B=fixed_b,                  $
                          VOABEAMRN=voabeamrn,VOAHALORN=voahalorn,VOACORERN=voacorern,      $
                          VTABEAMRN=vtabeamrn,VTEBEAMRN=vtebeamrn,NBEAM_RAN=nbeam_ran,      $
                          VTACORERN=vtacorern,VTECORERN=vtecorern,NCORE_RAN=ncore_ran,      $
                          VTAHALORN=vtahalorn,VTEHALORN=vtehalorn,NHALO_RAN=nhalo_ran,      $
                          EXPCORERN=expcorern,EXPBEAMRN=expbeamrn,EXPHALORN=exphalorn,      $
                          ES2CORERN=es2corern,ES2HALORN=es2halorn,ES2BEAMRN=es2beamrn,      $
                          EMIN_CH=emin__ch,EMIN_B=emin__b,EMAX_CH=emax__ch,EMAX_B=emax__b,  $
                          FTOL=def_ftol,GTOL=def_gtol,XTOL=def_xtol,POISSON=pois_1d,        $
                          /PLOT_BOTH,NOUSECTAB=nousectab,S_SIGN=s_sign,                     $
                          /SAVEF,/KEEPNAN,FILENAME=fnams_out2[0]

;;  
;;  N_oc     =  +6.0183e+00 +/- 6.5214e-03  cm^(-3)
;;  V_Tcpar  =  +2.1070e+03 +/- 1.0585e+00  km s^(-1)
;;  V_Tcper  =  +2.1051e+03 +/- 9.9525e-01  km s^(-1)
;;  V_ocpar  =  -0.0000e+00 +/- 0.0000e+00  km s^(-1)
;;  V_ocper  =  +3.3241e+00 +/- 9.2053e-01  km s^(-1)
;;  SS expc  =  +2.0000e+00 +/- 0.0000e+00  
;;  Model Fit Status  = 000002
;;  # of Iterations   = 000006
;;  Deg. of Freedom   = 0000010195
;;  Chi-Squared       = 9.1453e+03
;;  Red. Chi-Squared  = 8.9703e-01
;;  
;;  N_oh     =  +2.8863e-01 +/- 2.0402e-03  cm^(-3)
;;  V_Thpar  =  +4.3645e+03 +/- 8.0769e+00  km s^(-1)
;;  V_Thper  =  +4.4212e+03 +/- 8.0570e+00  km s^(-1)
;;  V_ohpar  =  -0.0000e+00 +/- 0.0000e+00  km s^(-1)
;;  V_ohper  =  -0.0000e+00 +/- 0.0000e+00  km s^(-1)
;;  kappah   =  +9.3697e+00 +/- 5.3467e-02  
;;  Model Fit Status  = 000002
;;  # of Iterations   = 000024
;;  Deg. of Freedom   = 0000010196
;;  Chi-Squared       = 7.9447e+03
;;  Red. Chi-Squared  = 7.7920e-01
;;  
;;  N_ob     =  +1.2713e-01 +/- 1.7373e-03  cm^(-3)
;;  V_Tbpar  =  +3.3507e+03 +/- 1.6417e+01  km s^(-1)
;;  V_Tbper  =  +3.2312e+03 +/- 1.6957e+01  km s^(-1)
;;  V_obpar  =  -2.0000e+03 +/- 0.0000e+00  km s^(-1)
;;  V_obper  =  -0.0000e+00 +/- 0.0000e+00  km s^(-1)
;;  kappab   =  +3.4986e+00 +/- 2.5337e-02  
;;  Model Fit Status  = 000001
;;  # of Iterations   = 000029
;;  Deg. of Freedom   = 0000010196
;;  Chi-Squared       = 5.8437e+03
;;  Red. Chi-Squared  = 5.7314e-01
;;  

PRINT,';;  Wind [SWF] Eesa Low Burst: '+time_string(tran_el_[jj,0L],PREC=3)+'  --  '+time_string(tran_el_[jj,1L],PREC=3)  & $
PRINT,';;  Fit Flags = ',out_strcc.FIT_FLAGS
;;  Wind [SWF] Eesa Low Burst: 2008-09-01/05:28:55.568  --  2008-09-01/05:28:58.625
;;  Fit Flags =           10          10          10

;;  Check against other known values
ntnr_at_vdf    = t_resample_tplot_struc(netnr_str,REFORM(tran_el_[jj,*]),/NO_EXTRAPOLATE,/IGNORE_INT)
n3dp_at_vdf    = t_resample_tplot_struc(t_3DP_Np,REFORM(tran_el_[jj,*]),/NO_EXTRAPOLATE,/IGNORE_INT)
nfit_sum_3n    = out_strcc.CORE.FIT_PARAMS[0] + out_strcc.HALO.FIT_PARAMS[0] + out_strcc.BEAM.FIT_PARAMS[0]

;;  Print comparison
PRINT,';;  Wind [SWF] Eesa Low Burst: '+time_string(tran_el_[jj,0L],PREC=3)+'  --  '+time_string(tran_el_[jj,1L],PREC=3)  & $
PRINT,';;  Ne[TNR] [cm^(-3)] : ',MEAN(ntnr_at_vdf.Y,/NAN)                                                                 & $
PRINT,';;  Np[3DP] [cm^(-3)] : ',MEAN(n3dp_at_vdf.Y,/NAN)                                                                 & $
PRINT,';;  Ne[Old] [cm^(-3)] : ',nfit_sum_3s[0]                                                                           & $
PRINT,';;  Ne[New] [cm^(-3)] : ',nfit_sum_3n[0]
;;  Wind [SWF] Eesa Low Burst: 2008-09-01/05:28:55.568  --  2008-09-01/05:28:58.625
;;  Ne[TNR] [cm^(-3)] :        7.5527095
;;  Np[3DP] [cm^(-3)] :        6.6589519
;;  Ne[Old] [cm^(-3)] :        5.9062454
;;  Ne[New] [cm^(-3)] :        6.4340843

;;  Check the percent error between these two "standards"
pern_tnr       = (MEAN(ntnr_at_vdf.Y,/NAN) - nfit_sum_3n[0])/MEAN(ntnr_at_vdf.Y,/NAN)*1d2
pern_3dp       = (MEAN(n3dp_at_vdf.Y,/NAN) - nfit_sum_3n[0])/MEAN(n3dp_at_vdf.Y,/NAN)*1d2
pern_old       = (nfit_sum_3s[0] - nfit_sum_3n[0])/nfit_sum_3s[0]*1d2
PRINT,';;  Wind [SWF] Eesa Low Burst: '+time_string(tran_el_[jj,0L],PREC=3)+'  --  '+time_string(tran_el_[jj,1L],PREC=3)  & $
PRINT,';;  ∆Ne[TNR] [%] : ',pern_tnr[0]                                                                                   & $
PRINT,';;  ∆Ne[3DP] [%] : ',pern_3dp[0]                                                                                   & $
PRINT,';;  ∆Ne[Old] [%] : ',pern_old[0]
;;  Wind [SWF] Eesa Low Burst: 2008-09-01/05:28:55.568  --  2008-09-01/05:28:58.625
;;  ∆Ne[TNR] [%] :        14.810913
;;  ∆Ne[3DP] [%] :        3.3769213
;;  ∆Ne[Old] [%] :       -8.9369613





