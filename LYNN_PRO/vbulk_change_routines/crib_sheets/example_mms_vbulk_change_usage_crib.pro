;;  Coordinate Systems
;;    BCS    :  Body Coordinate System
;;    DBCS   :  despun-BCS
;;    SMPA   :  Spinning, Major Principal Axis (MPA)
;;    DMPA   :  Despun, Major Principal Axis (coordinate system)
;;    GSE    :  Geocentric Solar Ecliptic
;;    GSM    :  Geocentric Solar Magnetospheric


;;  example_mms_vbulk_change_usage_crib.pro

;;----------------------------------------------------------------------------------------
;;  Compile relevant routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;;  IDL system and OS stuff
;;----------------------------------------------------------------------------------------
vers           = !VERSION.OS_FAMILY   ;;  e.g., 'unix'
vern           = !VERSION.RELEASE     ;;  e.g., '7.1.1'
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;  Electromagnetic
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;;  Atomic
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
ma_eV          = ma[0]*c[0]^2/qq[0]       ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
me_eV          = me[0]*c[0]^2/qq[0]       ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mn_eV          = mn[0]*c[0]^2/qq[0]       ;;  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c[0]^2/qq[0]       ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;  Astronomical
R_S___m        = 6.9600000d08             ;;  Sun's Mean Equatorial Radius [m, 2015 AA values]
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
M_E            = 5.9722000d24             ;;  Earth's mass [kg, 2015 AA values]
M_S__kg        = 1.9884000d30             ;;  Sun's mass [kg, 2015 AA values]
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
;;----------------------------------------------------------------------------------------
;;  Conversion Factors
;;----------------------------------------------------------------------------------------
;;  Energy and Temperature
f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]          ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]          ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
;;----------------------------------------------------------------------------------------
;;  Coordinates and vectors
;;----------------------------------------------------------------------------------------
;;  Define some default strings
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_bcs      = 'bcs'                    ;;  Body Coordinate System (of MMS spacecraft)
coord_dbcs     = 'dbcs'                   ;;  despun-BCS
coord_dmpa     = 'dmpa'                   ;;  Despun, Major Principal Axis (coordinate system)
coord_mag      = 'mag'
vec_str        = ['x','y','z']
vec_col        = [250,150, 50]
start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
;;----------------------------------------------------------------------------------------
;;  Define some defaults
;;----------------------------------------------------------------------------------------
tplot_options,'XMARGIN',[ 20, 15]
tplot_options,'YMARGIN',[ 5, 5]
all_probes     = ['1','2','3','4','*']
;;----------------------------------------------------------------------------------------
;;  Date/Times/Probes
;;----------------------------------------------------------------------------------------
;;  PROBE 1
probe          = '1'

;;  PROBE 2
probe          = '2'

;;  PROBE 3
probe          = '3'

;;  PROBE 4
probe          = '4'
tdate          = '2015-11-04'
start_t        = '05:20:00.000'
end___t        = '06:00:00.000'
;;  SCM burst intervals analyzed
tr_brst_int    = time_double(tdate[0]+'/'+['05:28:10.000','05:29:00.000'])
fpi_tran       = tdate[0]+'/'+['05:28:20.000','05:29:00.400']
fpi_tdbl       = time_double(fpi_tran)

;;----------------------------------------------------------------------------------------
;;  Load MMS TPLOT, Interval, and Frequency data
;;----------------------------------------------------------------------------------------
scpref         = 'mms'+probe[0]+'_'
IF (SIZE(start_t,/TYPE) NE 7) THEN start_t = start_of_day[0]
IF (SIZE(end___t,/TYPE) NE 7) THEN end___t = end___of_day[0]
t              = [tdate[0]+'/'+start_t[0],tdate[0]+'/'+end___t[0]]
trange         = time_double(t)

;;  Download
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/MMS_PRO/lbw_mms_load_all_inst.pro
lbw_mms_load_all_inst,TRANGE=trange,PROBE=probe,/RM_FGM_SPRT,/RM_EDP_SPRT,/RM_EDP_DSL,$
                       /RM_FPI_POLAR,/LOAD_DES_DF,/LOAD_DIS_DF



;;----------------------------------------------------------------------------------------
;;  Remove unnecessary TPLOT handles
;;----------------------------------------------------------------------------------------
store_data,DELETE=tnames(scpref[0]+'d*s_energyspectr_*')
store_data,DELETE=tnames(scpref[0]+'d*s_pitchangdist_*')
store_data,DELETE=tnames(scpref[0]+'d*s_densityextrapolation_*')
store_data,DELETE=tnames(scpref[0]+'d*s_heatq_*')
store_data,DELETE=tnames(scpref[0]+'d*s_temptensor_*')
store_data,DELETE=tnames(scpref[0]+'d*s_prestensor_*')
store_data,DELETE=tnames(scpref[0]+'d*s_alpha_*')
store_data,DELETE=tnames(scpref[0]+'d*s_compressionloss_*')
store_data,DELETE=tnames(scpref[0]+'d*s_errorflags_*')
store_data,DELETE=tnames(scpref[0]+'d*s_phi_*')
store_data,DELETE=tnames(scpref[0]+'d*s_theta_*')
store_data,DELETE=tnames(scpref[0]+'d*s_energy_*')
store_data,DELETE=tnames(scpref[0]+'d*s_spectr_*')
store_data,DELETE=tnames(scpref[0]+'d*s_steptable_*')
store_data,DELETE=tnames(scpref[0]+'d*s_startdelphi_*')

;;  Get Bo and Vbulk in DBCS
fgm_b_dbcs_tpn = tnames(scpref[0]+'fgm_brst_l2_'+coord_dbcs[0])
dis_b_dbcs_tpn = tnames(scpref[0]+'dis_bulkv_'+coord_dbcs[0]+'_brst')
des_b_dbcs_tpn = tnames(scpref[0]+'des_bulkv_'+coord_dbcs[0]+'_brst')
get_data,fgm_b_dbcs_tpn[0],DATA=temp_magf,DLIMIT=dlim_magf,LIMIT=lim_magf
get_data,dis_b_dbcs_tpn[0],DATA=temp_vblki,DLIMIT=dlim_vblki,LIMIT=lim_vblki
get_data,des_b_dbcs_tpn[0],DATA=temp_vblke,DLIMIT=dlim_vblke,LIMIT=lim_vblke
;;  Get spacecraft potential
scp_f_xxxx_tpn = tnames(scpref[0]+'edp_scpot_fast_l2')
get_data,scp_f_xxxx_tpn[0],DATA=temp_scpt,DLIMIT=dlim_scpt,LIMIT=lim_scpt

;;  Compile relevant routines
;;    ***  Change lines accordingly for your own machine  ***
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/MMS_PRO/add_velmagscpot_to_mms_dist.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/MMS_PRO/lbw_test_mms_fpi_vdf_structure.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/MMS_PRO/lbw_mms_tbin_avg_fpi_vdf.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/MMS_PRO/lbw_mms_energy_angle_to_velocity_array.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/MMS_PRO/lbw_mms_compute_counts_from_f_df.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/MMS_PRO/lbw_mms_nbin_sum_fpi_vdf.pro

;;----------------------------------------------------------------------------------------
;;  Get DIS distributions
;;----------------------------------------------------------------------------------------
dis_vdf_tpn    = tnames(scpref[0]+'dis_dist_brst')
;;get_data,dis_vdf_tpn[0],DATA=temp_idist
;;HELP, temp_idist
;;** Structure <a44bc68>, 5 tags, length=1061156664, data length=1061156664, refs=1:
;;   X               DOUBLE    Array[16127]
;;   Y               FLOAT     Array[16127, 32, 16, 32]
;;   V1              FLOAT     Array[16127, 32]
;;   V2              FLOAT     Array[16]
;;   V3              FLOAT     Array[16127, 32]
;;  Put into IDL structure format
dat_iarr       = mms_get_fpi_dist(dis_vdf_tpn[0],TRANGE=fpi_tdbl,/STRUCTURE,SPECIES='i',PROBE=probe[0])

;;  Get DIS counts
dis_err_tpn    = tnames(scpref[0]+'dis_disterr_brst')
cnt_str        = lbw_mms_compute_counts_from_f_df(dis_vdf_tpn[0],dis_err_tpn[0],FACTORS=factors,TRANGE=fpi_tdbl)
;;  Need the factors output but not the counts array --> clean up
delete_variable,cnt_str
;;----------------------------------------------------------------------------------------
;;  Add VELOCITY, MAGF, and SC_POT tags to array of structures
;;----------------------------------------------------------------------------------------
dis_vdf        = add_velmagscpot_to_mms_dist(dat_iarr,fgm_b_dbcs_tpn[0],dis_b_dbcs_tpn[0],scp_f_xxxx_tpn[0])
;;  Clean up
delete_variable,dat_iarr
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Fix Vbulk frame values -->  Use new Vbulk change routines
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Compile necessary routines
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/testing_routines/vbulk_change_get_default_struc.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/testing_routines/vbulk_change_test_cont_str_form.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/testing_routines/vbulk_change_test_plot_str_form.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/testing_routines/vbulk_change_test_vdf_str_form.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/testing_routines/vbulk_change_test_vdfinfo_str_form.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/testing_routines/vbulk_change_test_windn.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/prompting_routines/vbulk_change_list_options.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/prompting_routines/vbulk_change_prompts.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/prompting_routines/vbulk_change_options.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/misc_routines/vbulk_change_get_fname_ptitle.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/misc_routines/vbulk_change_print_index_time.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/prompting_routines/vbulk_change_keywords_init.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/prompting_routines/vbulk_change_change_parameter.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/vbulk_change_vdf_plot_wrapper.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/wrapper_vbulk_change_thm_wi.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/wrapper_vbulk_change____mms.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/wrapper_vbulk_change_thm_wi_mms.pro

data           = dis_vdf
dfra_in        = [1d-12,2d-6]
wrapper_vbulk_change_thm_wi_mms,data,FACTORS=factors,DFRA_IN=dfra_in,STRUC_OUT=struc_out


















