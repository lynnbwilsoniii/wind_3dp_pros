;+
;*****************************************************************************************
;
;  CRIBSHEET:   example_load_and_plot_wind_3dp_lz_vdfs.pro
;  PURPOSE  :   This is an example crib sheet meant to illustrate how to load and
;                 plot the 3D velocity distribution functions (VDFs) from the Wind
;                 3DP detectors.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               load_constants_fund_em_atomic_c2014_batch.pro
;               load_constants_extra_part_co2014_ci2015_batch.pro
;               load_constants_astronomical_aa2015_batch.pro
;               time_double.pro
;               general_load_and_save_wind_3dp_data.pro
;               tplot_options.pro
;               tplot.pro
;               tlimit.pro
;               waves_merge_tnr_rad_to_tplot.pro
;               store_data.pro
;               tnames.pro
;               kill_data_tr.pro
;               delete_variable.pro
;               get_data.pro
;               lbw__add.pro
;               calc_wind_scpot_norm.pro
;               t_get_struc_unix.pro
;               t_resample_tplot_struc.pro
;               options.pro
;               test_tplot_handle.pro
;               add_vsw2.pro
;               add_magf2.pro
;               add_scpot.pro
;               lbw_window.pro
;               file_name_times.pro
;               num2int_str.pro
;               struct_value.pro
;               conv_units.pro
;               conv_vdfidlstr_2_f_vs_vxyz_thm_wi.pro
;               trange_str.pro
;               general_vdf_contour_plot.pro
;               popen.pro
;               pclose.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  The following data:
;                     Wind/3DP level zero files
;                     Wind/MFI H0 CDF files
;                     Wind/SWE H1 CDF files
;                     Wind Attitude/Orbit ASCII files
;                     Wind/WAVES Radio ASCII files
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
;               1)  Follow notes in crib and enter each line by hand in the command line
;               2)  Definitions
;                     SWF  :  solar wind frame of reference
;                     FAC  :  field-aligned coordinates
;                     VDF  :  velocity distribution function
;               3)  The spacecraft (SC) potential estimates given below are really a
;                     proxy, not the real values.  This is because the deadtime and
;                     efficiency estimates for each solid angle bin are currently
;                     defined as the analytical estimates from theory for electrons
;                     incident on chevron MCPs.  The SC potential estimates are adjusted
;                     manually until the total electron density determined from the fits
;                     matches (roughly) the density determined from the upper hybrid
;                     line observed by the WAVES TNR instrument (i.e., the only
;                     unambiguous measure of the total electron density).
;               4)  For an explanation of the deadtime and efficiency estimates for MCPs
;                     see the work by Goruganthu and Wilson [1984],
;                     Meeks and Siegel [2008], and Schecker et al. [1992].
;               5)  Data Sources and Formats:
;                     Get particle and magnetic field data
;                       *** You need to download the data yourself unlike SPEDAS ***
;
;                     3DP Data:
;                       There is a routine that grabs the 3DP data called get_http_3dp_lz_files.pro.
;
;                       Get the 3DP lz data from http://sprg.ssl.berkeley.edu/wind3dp/data/wi/3dp/lz/ and put
;                       the files in the following year-based folders:
;                         ~/wind_data_dir/data1/wind/3dp/lz/YYYY/
;
;                     MFI Data:
;                       Get the MFI data from SPDF/CDAWeb and get the wi_h0_YYYYMMDD_v05.cdf files.  Put the
;                       the files in the following folder:
;                         ~/wind_data_dir/MFI_CDF/
;
;                     Attitude/Orbit Data:
;                       Get the attitude/orbit data from https://sscweb.gsfc.nasa.gov/ and make sure the
;                       the data format is consistent with the description in the routine
;                       read_wind_orbit.pro (actually in subroutine read_wind_ascii_orbit.pro).  I have
;                       attached an example file to show the proper format.  Put the files in the
;                       following folder:
;                         ~/wind_data_dir/Wind_Orbit_Data/
;                       Make sure the file naming format is consistent with that provided in the example.
;
;                     WAVES Radio Data:
;                     Need to get ASCII files from https://solar-radio.gsfc.nasa.gov then rename
;                       to the following format:
;                         TNR  Data:  TNR_YYYYMMDD.txt
;                         RAD1 Data:  RAD1_YYYYMMDD.txt
;                         RAD2 Data:  RAD2_YYYYMMDD.txt
;                       then put the files in the following folder (TNR example):
;                         ~/wind_data_dir/Wind_WAVES_Data/TNR__ASCII/
;
;  REFERENCES:  
;               0)  Barnes, A. "Collisionless Heating of the Solar-Wind Plasma I. Theory
;                      of the Heating of Collisionless Plasma by Hydromagnetic Waves,"
;                      Astrophys. J. 154, pp. 751--759, 1968.
;               1)  Mace, R.L. and R.D. Sydora "Parallel whistler instability in a plasma
;                      with an anisotropic bi-kappa distribution," J. Geophys. Res. 115,
;                      pp. A07206, doi:10.1029/2009JA015064, 2010.
;               2)  Livadiotis, G. "Introduction to special section on Origins and
;                      Properties of Kappa Distributions: Statistical Background and
;                      Properties of Kappa Distributions in Space Plasmas,"
;                      J. Geophys. Res. 120, pp. 1607--1619, doi:10.1002/2014JA020825,
;                      2015.
;               3)  Dum, C.T., et al., "Turbulent Heating and Quenching of the Ion Sound
;                      Instability," Phys. Rev. Lett. 32(22), pp. 1231--1234, 1974.
;               4)  Dum, C.T. "Strong-turbulence theory and the transition from Landau
;                      to collisional damping," Phys. Rev. Lett. 35(14), pp. 947--950,
;                      1975.
;               5)  Jain, H.C. and S.R. Sharma "Effect of flat top electron distribution
;                      on the turbulent heating of a plasma," Beitraega aus der
;                      Plasmaphysik 19, pp. 19--24, 1979.
;               6)  Goldman, M.V. "Strong turbulence of plasma waves," Rev. Modern Phys.
;                      56(4), pp. 709--735, 1984.
;               7)  Horton, W., et al., "Ion-acoustic heating from renormalized
;                      turbulence theory," Phys. Rev. A 14(1), pp. 424--433, 1976.
;               8)  Horton, W. and D.-I. Choi "Renormalized turbulence theory for the
;                      ion acoustic problem," Phys. Rep. 49(3), pp. 273--410, 1979.
;               9)  Livadiotis, G. "Statistical origin and properties of kappa
;                      distributions," J. Phys.: Conf. Ser. 900(1), pp. 012014, 2017.
;              10)  Livadiotis, G. "Derivation of the entropic formula for the
;                      statistical mechanics of space plasmas,"
;                      Nonlin. Proc. Geophys. 25(1), pp. 77-88, 2018.
;              11)  Livadiotis, G. "Modeling anisotropic Maxwell-Jüttner distributions:
;                      derivation and properties," Ann. Geophys. 34(1),
;                      pp. 1145-1158, 2016.
;              12)  Markwardt, C. B. "Non-Linear Least Squares Fitting in IDL with
;                     MPFIT," in proc. Astronomical Data Analysis Software and Systems
;                     XVIII, Quebec, Canada, ASP Conference Series, Vol. 411,
;                     Editors: D. Bohlender, P. Dowler & D. Durand, (Astronomical
;                     Society of the Pacific: San Francisco), pp. 251-254,
;                     ISBN:978-1-58381-702-5, 2009.
;              13)  Moré, J. 1978, "The Levenberg-Marquardt Algorithm: Implementation and
;                     Theory," in Numerical Analysis, Vol. 630, ed. G. A. Watson
;                     (Springer-Verlag: Berlin), pp. 105, doi:10.1007/BFb0067690, 1978.
;              14)  Moré, J. and S. Wright "Optimization Software Guide," SIAM,
;                     Frontiers in Applied Mathematics, Number 14,
;                     ISBN:978-0-898713-22-0, 1993.
;              15)  The IDL MINPACK routines can be found on Craig B. Markwardt's site at:
;                     http://cow.physics.wisc.edu/~craigm/idl/fitting.html
;              16)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 1. Analysis Techniques and Methodology,"
;                      J. Geophys. Res. 119(8), pp. 6455--6474, 2014a.
;              17)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 2. Waves and Dissipation,"
;                      J. Geophys. Res. 119(8), pp. 6475--6495, 2014b.
;              18)  Wilson III, L.B., et al., "Relativistic electrons produced by
;                      foreshock disturbances observed upstream of the Earth’s bow
;                      shock," Phys. Rev. Lett. 117(21), pp. 215101, 2016.
;              19)  Location of MPFIT software
;                     https://www.physics.wisc.edu/~craigm/idl/fitting.html
;              20)  Goruganthu, R.R. and W.G. Wilson "Relative electron detection
;                      efficiency of microchannel plates from 0-3 keV,"
;                      Rev. Sci. Inst. Vol. 55, pp. 2030-–2033, doi:10.1063/1.1137709,
;                      1984.
;              21)  Meeks, C. and P.B. Siegel "Dead time correction via the time series,"
;                      Amer. J. Phys. Vol. 76, pp. 589--590, doi:10.1119/1.2870432, 2008.
;              22)  Schecker, J.A., et al., "The performance of a microchannel plate at
;                      cryogenic temperatures and in high magnetic fields, and the
;                      detection efficiency for low energy positive hydrogen ions,"
;                      Nucl. Inst. & Meth. in Phys. Res. A Vol. 320, pp. 556--561,
;                      doi:10.1016/0168-9002(92)90950-9, 1992.
;              23)  Wilson III, L.B., et al., "The Statistical Properties of Solar Wind
;                      Temperature Parameters Near 1 au," Astrophys. J. Suppl. 236(2),
;                      pp. 41, doi:10.3847/1538-4365/aab71c, 2019.
;              24)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      Astrophys. J. Suppl. 243(8), doi:10.3847/1538-4365/ab22bd, 2019.
;              25)  Wilson III, L.B., et al., "Supplement to: Electron energy partition
;                      across interplanetary shocks," Zenodo Dataset,
;                      doi:10.5281/zenodo.2875806, 2019.
;
;   CREATED:  08/15/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/15/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;  Get fundamental and astronomical
@load_constants_fund_em_atomic_c2014_batch.pro
@load_constants_extra_part_co2014_ci2015_batch.pro
@load_constants_astronomical_aa2015_batch.pro
;;  Conversion factors
;;    Energy and Temperature
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> eV2K*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> K2eV*Temp{K} = energy{eV}]
;;    Speed and Frequency
vtefac         = SQRT(2d0*eV2J[0]/me[0])*1d-3
vtpfac         = SQRT(2d0*eV2J[0]/mp[0])*1d-3
;;  Define 1 AU in km
aukm           = au[0]*1d-3           ;;  m --> km
;;  Defaults and general variables
def__lim       = {YSTYLE:1,YMINOR:10L,PANEL_SIZE:2.0,XMINOR:5,XTICKLEN:0.04}
def_dlim       = {LOG:0,SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:-1}
sc             = 'Wind'
scpref         = sc[0]+'_'
pa_str         = ['p','a']
lmu_str        = ['low','med','upp']
chb_shrt_str   = ['c','h','b']
chb_long_str   = ['core','halo','beam']
vec_str        = ['x','y','z']
vec_col        = [250,150,50]
fac_swe        = ['avg','perp','para']
;;  Define some coordinate strings
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_fac      = 'fac'
coord_mag      = 'mag'
vec_gse_str    = vec_str+coord_gse[0]
;;  Define proton onboard moment TPLOT handles
pmom_tsuffs    = ['Np','Eff','Tp','Vp','Vp_mag','Vp_th','Vp_phi','VVp','VTHp','VTHp/Vp','Na/Np','Na','Ta','Va','Va_mag','Va_th','Va_phi','VVa','VTHa','RVVp','T3p','Tp_rat','magf']
pmom_tpns      = scpref[0]+pmom_tsuffs
pmam_tpns      = pmom_tpns[10:18]
pmom_tpn0      = [pmom_tpns[0L],pmom_tpns[2L:*]]
;;  Define SWE FC TPLOT handles
swe_suffx      = '_SWE_nonlin'
swe_midtpn     = ['Vbulk','VTh','N']
pvec_arr       = pa_str[0]+'_'+[coord_mag[0],vec_gse_str]
avec_arr       = pa_str[1]+'_'+[coord_mag[0],vec_gse_str]
pfac_arr       = pa_str[0]+'_'+['_'+fac_swe[0],fac_swe[1:2]]
afac_arr       = pa_str[1]+'_'+['_'+fac_swe[0],fac_swe[1:2]]
swe_vbulk_ap_t = scpref[0]+swe_midtpn[0]+'_'+[pvec_arr,avec_arr]+swe_suffx[0]
swe_vbulk_i_tp = scpref[0]+swe_midtpn[0]+'_'+coord_gse[0]+swe_suffx[0]
swe_n_api_tpn  = scpref[0]+swe_midtpn[2]+[pa_str,'i_tot']+[swe_suffx[0],swe_suffx[0],'_SWE']
swe_vth_ap_tpn = scpref[0]+swe_midtpn[1]+'_'+[pfac_arr,afac_arr]+swe_suffx[0]
swe_fit_tpns   = [swe_n_api_tpn,swe_vbulk_i_tp[0],swe_vbulk_ap_t,swe_vth_ap_tpn]
;;----------------------------------------------------------------------------------------
;;  Define times and load Wind data
;;----------------------------------------------------------------------------------------
sodt           = '00:00:00.000'
eodt           = '23:59:59.999'
;;  Change the following dates as necessary
tdate0         = '1995-04-02'
tdate1         = '1995-04-03'

tr_str         = [tdate0[0],tdate1[0]]+'/'+sodt[0]
trange         = time_double(tr_str)
;;----------------------------------------------------------------------------------------
;;  Get particle and magnetic field data
;;    *** You need to download the data yourself unlike SPEDAS ***
;;
;;  3DP Data:
;;    There is a routine that grabs the 3DP data called get_http_3dp_lz_files.pro.
;;
;;    Get the 3DP lz data from http://sprg.ssl.berkeley.edu/wind3dp/data/wi/3dp/lz/ and put
;;    the files in the following year-based folders:
;;      ~/wind_data_dir/data1/wind/3dp/lz/YYYY/
;;
;;  MFI Data:
;;    Get the MFI data from SPDF/CDAWeb and get the wi_h0_YYYYMMDD_v05.cdf files.  Put the
;;    the files in the following folder:
;;      ~/wind_data_dir/MFI_CDF/
;;
;;  Attitude/Orbit Data:
;;    Get the attitude/orbit data from https://sscweb.gsfc.nasa.gov/ and make sure the
;;    the data format is consistent with the description in the routine
;;    read_wind_orbit.pro (actually in subroutine read_wind_ascii_orbit.pro).  I have
;;    attached an example file to show the proper format.  Put the files in the
;;    following folder:
;;      ~/wind_data_dir/Wind_Orbit_Data/
;;    Make sure the file naming format is consistent with that provided in the example.
;;----------------------------------------------------------------------------------------
tran           = trange
general_load_and_save_wind_3dp_data,TRANGE=tran,/LOAD_SWEFC,/NO_CLEANT,/LOAD_EESA,     $
                                    /LOAD_PESA,/LOAD__SST,/NO_SAVE,                    $
                                    EESA_OUT=eesa_out,PESA_OUT=pesa_out,               $
                                    SST_FOUT=sst_fout,SST_OOUT=sst_oout
;;  Change default TPLOT options
tplot_options,'THICK',1.5
tplot_options,'CHARTHICK',1.5
tplot_options,'CHARSIZE',1.5
;;  Replot
tplot
tlimit,/FULL
;;----------------------------------------------------------------------------------------
;;  Load Wind WAVES data
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
waves_merge_tnr_rad_to_tplot,FLOW=flow,FUPP=fupp,TRANGE=tran,/FSMTH,ZRANGE=[9.5d-1,1d1]
;;  Remove the individual receiver TPLOT handles
store_data,DELETE=tnames(['TNR_*','RAD1_*','RAD2_*'])
;;  Remove any "spikes" or "glitches" in the WAVES data
;;    *** The following will permanently remove data from TPLOT variable ***
waves_tpn      = tnames(scpref[0]+'WAVES_radio_spectra ')
kill_data_tr,NAMES=waves_tpn[0]
;;----------------------------------------------------------------------------------------
;;  Define EESA Low E_min values
;;----------------------------------------------------------------------------------------
IF (SIZE(eesa_out,/TYPE) EQ 8) THEN IF (SIZE(eesa_out.EL_,/TYPE) EQ 8) THEN ael_  = eesa_out.EL_  ELSE ael_  = 0
IF (SIZE(eesa_out,/TYPE) EQ 8) THEN IF (SIZE(eesa_out.ELB,/TYPE) EQ 8) THEN aelb  = eesa_out.ELB  ELSE aelb  = 0
IF (SIZE(ael_,/TYPE) EQ 8) THEN n_el_ = N_ELEMENTS(ael_) ELSE n_el_ = 0L
IF (SIZE(aelb,/TYPE) EQ 8) THEN n_elb = N_ELEMENTS(aelb) ELSE n_elb = 0L
IF (n_el_[0] EQ 0 AND n_elb[0] EQ 0) THEN STOP           ;;  No EESA data at all???
IF (n_el_[0] GT 0) THEN ener_el_ = ael_.ENERGY
IF (n_el_[0] GT 0) THEN emin_el_ = MIN(MIN(ener_el_,/NAN,DIMENSION=1),/NAN,DIMENSION=1)
IF (n_el_[0] GT 0) THEN unix_el_ = (ael_.TIME + ael_.END_TIME)/2d0
IF (n_elb[0] GT 0) THEN ener_elb = aelb.ENERGY
IF (n_elb[0] GT 0) THEN emin_elb = MIN(MIN(ener_elb,/NAN,DIMENSION=1),/NAN,DIMENSION=1)
IF (n_elb[0] GT 0) THEN unix_elb = (aelb.TIME + aelb.END_TIME)/2d0
IF (n_elb[0] GT 0) THEN unix_ael = [unix_el_,unix_elb] ELSE unix_ael = unix_el_
IF (n_elb[0] GT 0) THEN emin_ael = [emin_el_,emin_elb] ELSE emin_ael = emin_el_
IF (n_elb[0] GT 0) THEN vdf__ael = [ael_,aelb]         ELSE vdf__ael = ael_
unix_ael       = unix_ael.SORT(INDICES=sp)
emin_ael       = emin_ael[sp]
vdf__ael       = vdf__ael[sp]
emin_ael_str   = {X:unix_ael,Y:emin_ael}
n_vdf          = N_ELEMENTS(vdf__ael)
;;  Clean up (save RAM)
delete_variable,ael_,aelb,ener_el_,ener_elb,emin_el_,emin_elb
delete_variable,unix_el_,unix_elb,sp
;;----------------------------------------------------------------------------------------
;;  Calculate corrected spacecraft potentials
;;----------------------------------------------------------------------------------------
get_data,scpref[0]+'Np',DATA=t_np_pl,DLIMIT=dlim_np_pl,LIMIT=lim__np_pl
get_data,scpref[0]+'Na',DATA=t_na_pl,DLIMIT=dlim_na_pl,LIMIT=lim__na_pl
np_all_dat     = t_np_pl.Y
na_all_dat     = t_na_pl.Y
ni_all_dat     = lbw__add(np_all_dat,2d0*na_all_dat,/NAN)
ni_smth        = SMOOTH(ni_all_dat,3,/NAN,/EDGE_ZERO,/EDGE_TRUNCATE,MISSING=d)
;;  Get normalized spacecraft potential
norm_scpot     = calc_wind_scpot_norm(ni_smth)
unix_ni        = t_get_struc_unix(t_np_pl)
;;  Interpolate Emin to Ni time stamps
emin_ael__ni   = t_resample_tplot_struc(emin_ael_str,unix_ni,/NO_EXTRAPOLATE,/IGNORE_INT)
;;  Define proper spacecraft potentials [eV]
phi_sc_lower   = SMOOTH(5d0*norm_scpot.MIN - emin_ael__ni.Y,3,/NAN,/EDGE_ZERO,/EDGE_TRUNCATE,MISSING=d)
phi_sc_upper   = SMOOTH(5d0*norm_scpot.MAX - emin_ael__ni.Y,3,/NAN,/EDGE_ZERO,/EDGE_TRUNCATE,MISSING=d)
phi_sc___med   = SMOOTH(5d0*norm_scpot.MED - emin_ael__ni.Y,3,/NAN,/EDGE_ZERO,/EDGE_TRUNCATE,MISSING=d)
phi_sc_arr     = [[phi_sc_lower],[phi_sc___med],[phi_sc_upper]]
bad_phi        = WHERE(phi_sc_arr LE 0 OR phi_sc_arr GT 25d0,bd_phi)
IF (bd_phi[0] GT 0) THEN phi_sc_arr[bad_phi] = d
;;  Define structures for TPLOT
phi_sc_min     = {X:unix_ni,Y:phi_sc_arr[*,0]}
phi_sc_str     = {X:unix_ni,Y:phi_sc_arr}
store_data,'corrected_phi_sc_min',DATA=phi_sc_min,DLIMIT=def_dlim,LIMIT=def__lim
store_data,'corrected_phi_sc_lmu',DATA=phi_sc_str,DLIMIT=def_dlim,LIMIT=def__lim
options,'corrected_phi_sc_min',LABELS=lmu_str[0],COLORS=100,YTITLE='phi_sc [eV]',YSUBTITLE='[WilsonIII 2019a]',/DEFAULT
options,'corrected_phi_sc_lmu',LABELS=lmu_str,COLORS=[100,50,200],YTITLE='phi_sc [eV]',YSUBTITLE='[WilsonIII 2019a]',/DEFAULT
;;----------------------------------------------------------------------------------------
;;  Add relevant parameters to structures
;;----------------------------------------------------------------------------------------
new_wibgse_tpn = scpref[0]+'magf_3s_'+coord_gse[0]
scpot_tpn      = 'corrected_phi_sc_min'
Bgse_tpnm      = new_wibgse_tpn[0]
test           = test_tplot_handle(scpref[0]+'Vp',TPNMS=tpname_vsw)
IF (test[0] EQ 0) THEN test = test_tplot_handle('V_sw2',TPNMS=tpname_vsw)
IF (test[0] EQ 0) THEN test = test_tplot_handle(swe_vbulk_i_tp[0],TPNMS=tpname_vsw)

IF (SIZE(eesa_out,/TYPE) EQ 8) THEN IF (SIZE(eesa_out.EL_,/TYPE) EQ 8) THEN ael_  = eesa_out.EL_  ELSE ael_  = 0
IF (SIZE(eesa_out,/TYPE) EQ 8) THEN IF (SIZE(eesa_out.ELB,/TYPE) EQ 8) THEN aelb  = eesa_out.ELB  ELSE aelb  = 0
IF (SIZE(eesa_out,/TYPE) EQ 8) THEN IF (SIZE(eesa_out.EH_,/TYPE) EQ 8) THEN aeh_  = eesa_out.EH_  ELSE aeh_  = 0
IF (SIZE(eesa_out,/TYPE) EQ 8) THEN IF (SIZE(eesa_out.EHB,/TYPE) EQ 8) THEN aehb  = eesa_out.EHB  ELSE aehb  = 0
IF (SIZE(pesa_out,/TYPE) EQ 8) THEN IF (SIZE(pesa_out.PL_,/TYPE) EQ 8) THEN apl_  = pesa_out.PL_  ELSE apl_  = 0
IF (SIZE(pesa_out,/TYPE) EQ 8) THEN IF (SIZE(pesa_out.PLB,/TYPE) EQ 8) THEN aplb  = pesa_out.PLB  ELSE aplb  = 0
IF (SIZE(pesa_out,/TYPE) EQ 8) THEN IF (SIZE(pesa_out.PH_,/TYPE) EQ 8) THEN aph_  = pesa_out.PH_  ELSE aph_  = 0
IF (SIZE(pesa_out,/TYPE) EQ 8) THEN IF (SIZE(pesa_out.PHB,/TYPE) EQ 8) THEN aphb  = pesa_out.PHB  ELSE aphb  = 0
IF (SIZE(sst_fout,/TYPE) EQ 8) THEN IF (SIZE(sst_fout.SF_,/TYPE) EQ 8) THEN asf_  = sst_fout.SF_  ELSE asf_  = 0
IF (SIZE(sst_fout,/TYPE) EQ 8) THEN IF (SIZE(sst_fout.SFB,/TYPE) EQ 8) THEN asfb  = sst_fout.SFB  ELSE asfb  = 0
IF (SIZE(sst_oout,/TYPE) EQ 8) THEN IF (SIZE(sst_oout.SO_,/TYPE) EQ 8) THEN aso_  = sst_oout.SO_  ELSE aso_  = 0
IF (SIZE(sst_oout,/TYPE) EQ 8) THEN IF (SIZE(sst_oout.SOB,/TYPE) EQ 8) THEN asob  = sst_oout.SOB  ELSE asob  = 0
IF (SIZE(ael_,/TYPE) EQ 8) THEN n_el_ = N_ELEMENTS(ael_) ELSE n_el_ = 0L
IF (SIZE(aelb,/TYPE) EQ 8) THEN n_elb = N_ELEMENTS(aelb) ELSE n_elb = 0L
IF (SIZE(aeh_,/TYPE) EQ 8) THEN n_eh_ = N_ELEMENTS(aeh_) ELSE n_eh_ = 0L
IF (SIZE(aehb,/TYPE) EQ 8) THEN n_ehb = N_ELEMENTS(aehb) ELSE n_ehb = 0L
IF (SIZE(apl_,/TYPE) EQ 8) THEN n_pl_ = N_ELEMENTS(apl_) ELSE n_pl_ = 0L
IF (SIZE(aplb,/TYPE) EQ 8) THEN n_plb = N_ELEMENTS(aplb) ELSE n_plb = 0L
IF (SIZE(aph_,/TYPE) EQ 8) THEN n_ph_ = N_ELEMENTS(aph_) ELSE n_ph_ = 0L
IF (SIZE(aphb,/TYPE) EQ 8) THEN n_phb = N_ELEMENTS(aphb) ELSE n_phb = 0L
IF (SIZE(asf_,/TYPE) EQ 8) THEN n_sf_ = N_ELEMENTS(asf_) ELSE n_sf_ = 0L
IF (SIZE(asfb,/TYPE) EQ 8) THEN n_sfb = N_ELEMENTS(asfb) ELSE n_sfb = 0L
IF (SIZE(aso_,/TYPE) EQ 8) THEN n_so_ = N_ELEMENTS(aso_) ELSE n_so_ = 0L
IF (SIZE(asob,/TYPE) EQ 8) THEN n_sob = N_ELEMENTS(asob) ELSE n_sob = 0L

IF (n_el_[0] GT 0) THEN add_vsw2,ael_,tpname_vsw[0],VBULK_TAG='VSW'
IF (n_elb[0] GT 0) THEN add_vsw2,aelb,tpname_vsw[0],VBULK_TAG='VSW'
IF (n_eh_[0] GT 0) THEN add_vsw2,aeh_,tpname_vsw[0],VBULK_TAG='VSW'
IF (n_ehb[0] GT 0) THEN add_vsw2,aehb,tpname_vsw[0],VBULK_TAG='VSW'
IF (n_pl_[0] GT 0) THEN add_vsw2,apl_,tpname_vsw[0],VBULK_TAG='VSW'
IF (n_plb[0] GT 0) THEN add_vsw2,aplb,tpname_vsw[0],VBULK_TAG='VSW'
IF (n_ph_[0] GT 0) THEN add_vsw2,aph_,tpname_vsw[0],VBULK_TAG='VSW'
IF (n_phb[0] GT 0) THEN add_vsw2,aphb,tpname_vsw[0],VBULK_TAG='VSW'
IF (n_sf_[0] GT 0) THEN add_vsw2,asf_,tpname_vsw[0],VBULK_TAG='VSW'
IF (n_sfb[0] GT 0) THEN add_vsw2,asfb,tpname_vsw[0],VBULK_TAG='VSW'
IF (n_so_[0] GT 0) THEN add_vsw2,aso_,tpname_vsw[0],VBULK_TAG='VSW'
IF (n_sob[0] GT 0) THEN add_vsw2,asob,tpname_vsw[0],VBULK_TAG='VSW'
IF (n_el_[0] GT 0) THEN add_magf2,ael_,Bgse_tpnm[0],MAGF_TAG='MAGF'
IF (n_elb[0] GT 0) THEN add_magf2,aelb,Bgse_tpnm[0],MAGF_TAG='MAGF'
IF (n_eh_[0] GT 0) THEN add_magf2,aeh_,Bgse_tpnm[0],MAGF_TAG='MAGF'
IF (n_ehb[0] GT 0) THEN add_magf2,aehb,Bgse_tpnm[0],MAGF_TAG='MAGF'
IF (n_pl_[0] GT 0) THEN add_magf2,apl_,Bgse_tpnm[0],MAGF_TAG='MAGF'
IF (n_plb[0] GT 0) THEN add_magf2,aplb,Bgse_tpnm[0],MAGF_TAG='MAGF'
IF (n_ph_[0] GT 0) THEN add_magf2,aph_,Bgse_tpnm[0],MAGF_TAG='MAGF'
IF (n_phb[0] GT 0) THEN add_magf2,aphb,Bgse_tpnm[0],MAGF_TAG='MAGF'
IF (n_sf_[0] GT 0) THEN add_magf2,asf_,Bgse_tpnm[0],MAGF_TAG='MAGF'
IF (n_sfb[0] GT 0) THEN add_magf2,asfb,Bgse_tpnm[0],MAGF_TAG='MAGF'
IF (n_so_[0] GT 0) THEN add_magf2,aso_,Bgse_tpnm[0],MAGF_TAG='MAGF'
IF (n_sob[0] GT 0) THEN add_magf2,asob,Bgse_tpnm[0],MAGF_TAG='MAGF'
IF (n_el_[0] GT 0) THEN add_scpot,ael_,scpot_tpn[0]
IF (n_elb[0] GT 0) THEN add_scpot,aelb,scpot_tpn[0]
IF (n_eh_[0] GT 0) THEN add_scpot,aeh_,scpot_tpn[0]
IF (n_ehb[0] GT 0) THEN add_scpot,aehb,scpot_tpn[0]
IF (n_pl_[0] GT 0) THEN add_scpot,apl_,scpot_tpn[0]
IF (n_plb[0] GT 0) THEN add_scpot,aplb,scpot_tpn[0]
IF (n_ph_[0] GT 0) THEN add_scpot,aph_,scpot_tpn[0]
IF (n_phb[0] GT 0) THEN add_scpot,aphb,scpot_tpn[0]
IF (n_sf_[0] GT 0) THEN add_scpot,asf_,scpot_tpn[0]
IF (n_sfb[0] GT 0) THEN add_scpot,asfb,scpot_tpn[0]
IF (n_so_[0] GT 0) THEN add_scpot,aso_,scpot_tpn[0]
IF (n_sob[0] GT 0) THEN add_scpot,asob,scpot_tpn[0]
IF (n_el_[0] GT 0) THEN add_vsw2,ael_,tpname_vsw[0],VBULK_TAG='VSW',/LEAVE_ALONE
IF (n_elb[0] GT 0) THEN add_vsw2,aelb,tpname_vsw[0],VBULK_TAG='VSW',/LEAVE_ALONE
IF (n_eh_[0] GT 0) THEN add_vsw2,aeh_,tpname_vsw[0],VBULK_TAG='VSW',/LEAVE_ALONE
IF (n_ehb[0] GT 0) THEN add_vsw2,aehb,tpname_vsw[0],VBULK_TAG='VSW',/LEAVE_ALONE
IF (n_pl_[0] GT 0) THEN add_vsw2,apl_,tpname_vsw[0],VBULK_TAG='VSW',/LEAVE_ALONE
IF (n_plb[0] GT 0) THEN add_vsw2,aplb,tpname_vsw[0],VBULK_TAG='VSW',/LEAVE_ALONE
IF (n_ph_[0] GT 0) THEN add_vsw2,aph_,tpname_vsw[0],VBULK_TAG='VSW',/LEAVE_ALONE
IF (n_phb[0] GT 0) THEN add_vsw2,aphb,tpname_vsw[0],VBULK_TAG='VSW',/LEAVE_ALONE
IF (n_sf_[0] GT 0) THEN add_vsw2,asf_,tpname_vsw[0],VBULK_TAG='VSW',/LEAVE_ALONE
IF (n_sfb[0] GT 0) THEN add_vsw2,asfb,tpname_vsw[0],VBULK_TAG='VSW',/LEAVE_ALONE
IF (n_so_[0] GT 0) THEN add_vsw2,aso_,tpname_vsw[0],VBULK_TAG='VSW',/LEAVE_ALONE
IF (n_sob[0] GT 0) THEN add_vsw2,asob,tpname_vsw[0],VBULK_TAG='VSW',/LEAVE_ALONE
IF (n_el_[0] GT 0) THEN add_magf2,ael_,Bgse_tpnm[0],MAGF_TAG='MAGF',/LEAVE_ALONE
IF (n_elb[0] GT 0) THEN add_magf2,aelb,Bgse_tpnm[0],MAGF_TAG='MAGF',/LEAVE_ALONE
IF (n_eh_[0] GT 0) THEN add_magf2,aeh_,Bgse_tpnm[0],MAGF_TAG='MAGF',/LEAVE_ALONE
IF (n_ehb[0] GT 0) THEN add_magf2,aehb,Bgse_tpnm[0],MAGF_TAG='MAGF',/LEAVE_ALONE
IF (n_pl_[0] GT 0) THEN add_magf2,apl_,Bgse_tpnm[0],MAGF_TAG='MAGF',/LEAVE_ALONE
IF (n_plb[0] GT 0) THEN add_magf2,aplb,Bgse_tpnm[0],MAGF_TAG='MAGF',/LEAVE_ALONE
IF (n_ph_[0] GT 0) THEN add_magf2,aph_,Bgse_tpnm[0],MAGF_TAG='MAGF',/LEAVE_ALONE
IF (n_phb[0] GT 0) THEN add_magf2,aphb,Bgse_tpnm[0],MAGF_TAG='MAGF',/LEAVE_ALONE
IF (n_sf_[0] GT 0) THEN add_magf2,asf_,Bgse_tpnm[0],MAGF_TAG='MAGF',/LEAVE_ALONE
IF (n_sfb[0] GT 0) THEN add_magf2,asfb,Bgse_tpnm[0],MAGF_TAG='MAGF',/LEAVE_ALONE
IF (n_so_[0] GT 0) THEN add_magf2,aso_,Bgse_tpnm[0],MAGF_TAG='MAGF',/LEAVE_ALONE
IF (n_sob[0] GT 0) THEN add_magf2,asob,Bgse_tpnm[0],MAGF_TAG='MAGF',/LEAVE_ALONE
IF (n_el_[0] GT 0) THEN add_scpot,ael_,scpot_tpn[0],/LEAVE_ALONE
IF (n_elb[0] GT 0) THEN add_scpot,aelb,scpot_tpn[0],/LEAVE_ALONE
IF (n_eh_[0] GT 0) THEN add_scpot,aeh_,scpot_tpn[0],/LEAVE_ALONE
IF (n_ehb[0] GT 0) THEN add_scpot,aehb,scpot_tpn[0],/LEAVE_ALONE
IF (n_pl_[0] GT 0) THEN add_scpot,apl_,scpot_tpn[0],/LEAVE_ALONE
IF (n_plb[0] GT 0) THEN add_scpot,aplb,scpot_tpn[0],/LEAVE_ALONE
IF (n_ph_[0] GT 0) THEN add_scpot,aph_,scpot_tpn[0],/LEAVE_ALONE
IF (n_phb[0] GT 0) THEN add_scpot,aphb,scpot_tpn[0],/LEAVE_ALONE
IF (n_sf_[0] GT 0) THEN add_scpot,asf_,scpot_tpn[0],/LEAVE_ALONE
IF (n_sfb[0] GT 0) THEN add_scpot,asfb,scpot_tpn[0],/LEAVE_ALONE
IF (n_so_[0] GT 0) THEN add_scpot,aso_,scpot_tpn[0],/LEAVE_ALONE
IF (n_sob[0] GT 0) THEN add_scpot,asob,scpot_tpn[0],/LEAVE_ALONE
;;  Add back into structure
IF (n_el_[0] GT 0) THEN eesa_out.EL_ = ael_
IF (n_elb[0] GT 0) THEN eesa_out.ELB = aelb
IF (n_eh_[0] GT 0) THEN eesa_out.EH_ = aeh_
IF (n_ehb[0] GT 0) THEN eesa_out.EHB = aehb
IF (n_pl_[0] GT 0) THEN pesa_out.PL_ = apl_
IF (n_plb[0] GT 0) THEN pesa_out.PLB = aplb
IF (n_ph_[0] GT 0) THEN pesa_out.PH_ = aph_
IF (n_phb[0] GT 0) THEN pesa_out.PHB = aphb
IF (n_sf_[0] GT 0) THEN sst_fout.SF_ = asf_
IF (n_sfb[0] GT 0) THEN sst_fout.SFB = asfb
IF (n_so_[0] GT 0) THEN sst_oout.SO_ = aso_
IF (n_sob[0] GT 0) THEN sst_oout.SOB = asob
;;  Clean up (save RAM)
delete_variable,ael_,aelb,aeh_,aehb,apl_,aplb,aph_,aphb
delete_variable,asf_,asfb,aso_,asob
;;----------------------------------------------------------------------------------------
;;  Setup for plotting 3DP distributions
;;----------------------------------------------------------------------------------------
;;  Open plot window
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = LONG(MIN(s_size*7d-1))
xywsz          = [wsz[0],LONG(wsz[0]*1.375d0)]
win_ttl        = 'Wind VDF 2D Slice'
win_str        = {RETAIN:2,XSIZE:xywsz[0],YSIZE:xywsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
lbw_window,WIND_N=4,NEW_W=1,_EXTRA=win_str,/CLEAN
;;  Define defaults
ttle_ext       = 'SWF'
xname          = 'Bo'
yname          = 'Vsw'
scname         = STRUPCASE(STRMID(scpref[0],0L,4L))
nlev           = 30L                                      ;;  Defines number of contour levels
ngrid          = 101L                                     ;;  Define # of grid points for Delaunay triangulation
plane          = 'xy'                                     ;;  Defines slice plane in coordinate basis
fname_pre      = scpref[0]+'df_'+ttle_ext[0]+'_'
;;  Define file name stuff
el__ts         = eesa_out.EL_.TIME
el__te         = eesa_out.EL_.END_TIME
tran_des       = [[el__ts],[el__te]]
fnm__des       = file_name_times(tran_des[*,0],PREC=5)
ft___des       = fnm__des[0].F_TIME           ;;  e.g., '1998-08-09_0801x09.49412'
fname_mids     = '3dp_el__'+ft___des
vlim_des       = 2d4
vlim_stre      = num2int_str(vlim_des[0],NUM_CHAR=6L,/ZERO_PAD)
vlim_sufe      = '_VLIM-'+vlim_stre[0]+'km_s'
fname_end      = 'para-red_perp-blue_plane-'+plane[0]+vlim_sufe[0]
fnams_oute     = fname_pre[0]+fname_mids+'_'+fname_end[0]
;;  Define popen structure
popen_str      = {PORT:1,UNITS:'inches',XSIZE:8e0,YSIZE:11e0,ASPECT:0}
;;----------------------------------------------------------------------------------------
;;  Plot 3DP distributions
;;----------------------------------------------------------------------------------------
;;  Define plot defaults
vlim           = vlim_des[0]                ;;  20,000 km/s speed range
dfra           = [1d-16,1.5d-10]            ;;  Phase space density [# cm^(-3) km^(-3) s^(+3)] range
inst_mids      = des_vdf[0].DATA_NAME[0]
sm_cont        = 1b                         ;;  Turn on contour smoothing
sm_cuts        = 1b                         ;;  Turn on 1D cut smoothing
nsmcut         = 3L                         ;;  Define # of points over which to smooth cuts
nsmcon         = 3L                         ;;  Define # of points over which to smooth contours
;;  Define plot title
pttl_pref      = scname[0]+' ['+ttle_ext[0]+'] '+inst_mids[0]
;;  Define parameters for plotting
jj             = 10L                        ;;  Define index of EESA Low array
dat0           = eesa_out.EL_[jj]
temp           = dat0[0].DATA
;;  Make sure structure tag value is finite and present
IF (FINITE(dat0[0].SC_POT[0]) EQ 0) THEN STOP
;;  Prevent interpolation below SC potential
bad            = WHERE(dat0[0].ENERGY LE 1.3e0*dat0[0].SC_POT,bd)
IF (bd[0] GT 0) THEN temp[bad] = f
dat0[0].DATA   = temp
;;  Check for E_SHIFT tag
;;    If found --> Adjust by E_SHIFT then set to zero
eshift  = struct_value(dat0,'E_SHIFT',DEFAULT=0e0,INDEX=ind_eshft)
IF (ind_eshft[0] GE 0) THEN dat0[0].ENERGY  += eshift[0]
IF (ind_eshft[0] GE 0) THEN dat0[0].E_SHIFT *= 0
;;  Define one-count levels
datc           = dat0[0]
datc.DATA      = 1e0                  ;;  Create a one-count copy
;;  Convert to phase space density [# cm^(-3) km^(-3) s^(+3)]
dat_df         = conv_units(dat0,'df')
dat_1c         = conv_units(datc,'df')
;;  Convert F(energy,theta,phi) to F(Vx,Vy,Vz)
dat_fvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_df)
dat_1cxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_1c)
;;  Define some plot-specific changes
vec1           = REFORM(dat0[0].MAGF)
vec2           = REFORM(dat0[0].VSW)
vframe         = REFORM(dat0[0].VSW)
;;  Define data
data_1d        = dat_fvxyz.VDF            ;;  [N]-Element [numeric] array of data [# cm^(-3) km^(-3) s^(+3)]
vels_1d        = dat_fvxyz.VELXYZ         ;;  [N,3]-Element [numeric] array of 3-vector velocities
onec_1d        = dat_1cxyz.VDF            ;;  [N]-Element [numeric] array of one-count [# cm^(-3) km^(-3) s^(+3)]
;;  Define EX_INFO stuff  (for general_vdf_contour_plot.pro)
ex_info        = {SCPOT:dat0[0].SC_POT,VSW:dat0[0].VSW,MAGF:dat0[0].MAGF}
ptitle         = pttl_pref[0]+'!C'+trange_str(tran_des[jj,0],tran_des[jj,1],/MSEC)
;;    Y vs. X plane
WSET,4
WSHOW,4
general_vdf_contour_plot,data_1d,vels_1d,VFRAME=vframe,VEC1=vec1,VEC2=vec2,VLIM=vlim,       $
                         PLANE=plane,DFRA=dfra,SM_CUTS=sm_cuts,SM_CONT=sm_cont,             $
                         NSMCUT=nsmcut,NSMCON=nsmcon,XNAME=xname,YNAME=yname,               $
                         P_TITLE=ptitle,NLEV=nlev,EX_INFO=ex_info,NGRID=ngrid,              $
                         /SLICE2D,ONE_C=one_c,DAT_OUT=dat_out,ROT_OUT=rot_out,F3D_QH=f3d_qh

;;  Save plot
;;    Define file
fname          = fnams_oute[jj]+'_L2-Vbulk'
popen,fname[0],_EXTRA=popen_str
  general_vdf_contour_plot,data_1d,vels_1d,VFRAME=vframe,VEC1=vec1,VEC2=vec2,VLIM=vlim,       $
                           PLANE=plane,DFRA=dfra,SM_CUTS=sm_cuts,SM_CONT=sm_cont,             $
                           NSMCUT=nsmcut,NSMCON=nsmcon,XNAME=xname,YNAME=yname,               $
                           P_TITLE=ptitle,NLEV=nlev,EX_INFO=ex_info,NGRID=ngrid,              $
                           /SLICE2D,ONE_C=one_c
pclose



