;;  Coordinate Systems
;;    BCS    :  Body Coordinate System
;;    DBCS   :  despun-BCS
;;    SMPA   :  Spinning, Major Principal Axis (MPA)
;;    DMPA   :  Despun, Major Principal Axis (coordinate system)
;;    GSE    :  Geocentric Solar Ecliptic
;;    GSM    :  Geocentric Solar Magnetospheric

;;  /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_3dp_cribs/example_mms_des_vdf_fitting_crib.pro

;;----------------------------------------------------------------------------------------
;;  Compile relevant routines (different for each person's personal IDL stuff)
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
;;  Define some conversion factors
vte2tekfac     = 1d6*me[0]/2d0/kB[0]              ;;  Converts thermal speed squared to temperature [K]
vte2teevfac    = vte2tekfac[0]*K2eV[0]            ;;  Converts thermal speed squared to temperature [eV]
vtefac         = SQRT(1d0/vte2teevfac[0])         ;;  Converts square root of temperature [eV] to thermal speed [km/s]
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
fpi_tran       = tdate[0]+'/'+['05:28:00.000','05:29:15.000']
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
des_b_dens_tpn = tnames(scpref[0]+'des_numberdensity_brst')
des_b_tpar_tpn = tnames(scpref[0]+'des_temppara_brst')
des_b_tper_tpn = tnames(scpref[0]+'des_tempperp_brst')
get_data,fgm_b_dbcs_tpn[0],DATA=temp_magf,DLIMIT=dlim_magf,LIMIT=lim_magf
get_data,dis_b_dbcs_tpn[0],DATA=temp_vblki,DLIMIT=dlim_vblki,LIMIT=lim_vblki
get_data,des_b_dbcs_tpn[0],DATA=temp_vblke,DLIMIT=dlim_vblke,LIMIT=lim_vblke
get_data,des_b_dens_tpn[0],DATA=temp_dense,DLIMIT=dlim_dense,LIMIT=lim_dense
get_data,des_b_tpar_tpn[0],DATA=temp_tpare,DLIMIT=dlim_tpare,LIMIT=lim_tpare
get_data,des_b_tper_tpn[0],DATA=temp_tpere,DLIMIT=dlim_tpere,LIMIT=lim_tpere
;;  Get spacecraft potential
scp_f_xxxx_tpn = tnames(scpref[0]+'edp_scpot_fast_l2')
get_data,scp_f_xxxx_tpn[0],DATA=temp_scpt,DLIMIT=dlim_scpt,LIMIT=lim_scpt

;;  Compile relevant routines
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/MMS_PRO/add_velmagscpot_to_mms_dist.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/MMS_PRO/lbw_test_mms_fpi_vdf_structure.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/MMS_PRO/lbw_mms_tbin_avg_fpi_vdf.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/MMS_PRO/lbw_mms_energy_angle_to_velocity_array.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/MMS_PRO/lbw_mms_compute_counts_from_f_df.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/MMS_PRO/lbw_mms_nbin_sum_fpi_vdf.pro

;;----------------------------------------------------------------------------------------
;;  Get DES & DIS distributions
;;----------------------------------------------------------------------------------------
dis_vdf_tpn    = tnames(scpref[0]+'dis_dist_brst')
des_vdf_tpn    = tnames(scpref[0]+'des_dist_brst')
;;get_data,dis_vdf_tpn[0],DATA=temp_idist
;;HELP, temp_idist
;;** Structure <a44bc68>, 5 tags, length=1061156664, data length=1061156664, refs=1:
;;   X               DOUBLE    Array[16127]
;;   Y               FLOAT     Array[16127, 32, 16, 32]
;;   V1              FLOAT     Array[16127, 32]
;;   V2              FLOAT     Array[16]
;;   V3              FLOAT     Array[16127, 32]
dat_iarr       = mms_get_fpi_dist(dis_vdf_tpn[0],TRANGE=fpi_tdbl,/STRUCTURE,SPECIES='i',PROBE=probe[0])
dat_earr       = mms_get_fpi_dist(des_vdf_tpn[0],TRANGE=fpi_tdbl,/STRUCTURE,SPECIES='e',PROBE=probe[0])
;;  Get counts
des_err_tpn    = tnames(scpref[0]+'des_disterr_brst')
cnt_des_str    = lbw_mms_compute_counts_from_f_df(des_vdf_tpn[0],des_err_tpn[0],FACTORS=cnts2psd_des),TRANGE=trange)
;;  Define one-count and Poisson stats levels
one_cnt_des    = cnt_des_str
poisson_des    = cnt_des_str
one_cnt_des.Y  = 1e0
poisson_des.Y  = SQRT(poisson_des.Y)
;;  Convert back to phase space density
one_cnt_des.Y *= cnts2psd_des
poisson_des.Y *= cnts2psd_des

;;  Send to TPLOT
one_cnt_tpn    = scpref[0]+'des_onecnt_brst'
poisson_tpn    = scpref[0]+'des_poissn_brst'
;;  Get the DES structure for the V[1,2,3] tags
get_data,des_vdf_tpn[0],DATA=des_vdf_str,DLIMIT=dlim,LIMIT=lim
;;  Extract them to add to the one-count and Poisson structures
extract_tags,one_cnt_des,des_vdf_str,TAGS=['V1','V2','V3']
extract_tags,poisson_des,des_vdf_str,TAGS=['V1','V2','V3']
;;  Send result back to TPLOT (solely to take advantage of built-in SPEDAS software)
store_data,one_cnt_tpn[0],DATA=one_cnt_des,DLIMIT=dlim,LIMIT=lim
store_data,poisson_tpn[0],DATA=poisson_des,DLIMIT=dlim,LIMIT=lim
;;  Clean up
delete_variable,dis_vdf_str,dlim,lim,cnt_des_str,poisson_des,one_cnt_des,cnts2psd_des
;;  Convert one-count data to proper structure
onec_earr      = mms_get_fpi_dist(one_cnt_tpn[0],TRANGE=fpi_tdbl,/STRUCTURE,SPECIES='e',PROBE=probe[0])
pois_earr      = mms_get_fpi_dist(poisson_tpn[0],TRANGE=fpi_tdbl,/STRUCTURE,SPECIES='e',PROBE=probe[0])
;;----------------------------------------------------------------------------------------
;;  Add VELOCITY, MAGF, and SC_POT tags to array
;;----------------------------------------------------------------------------------------
des_vdf0       = add_velmagscpot_to_mms_dist(dat_earr,fgm_b_dbcs_tpn[0],des_b_dbcs_tpn[0],scp_f_xxxx_tpn[0])
des_vdf        = des_vdf0
;;  Clean up
delete_variable,dat_earr,des_vdf0
;;  Check format of DATA --> Make sure its an array of valid FPI structures
test1          = lbw_test_mms_fpi_vdf_structure(des_vdf,POST=post,/NOM)

;;  Define # of times, energies, and angles
nts_e          = N_ELEMENTS(REFORM(des_vdf))                 ;;  # of times
nes_e          = N_ELEMENTS(REFORM(des_vdf[0].DATA[*,0,0]))  ;;  # of energy bins
nph_e          = N_ELEMENTS(REFORM(des_vdf[0].DATA[0,*,0]))  ;;  # of azimuthal bins
nth_e          = N_ELEMENTS(REFORM(des_vdf[0].DATA[0,0,*]))  ;;  # of latitudinal/poloidal bins
kk_e           = nes_e[0]*nph_e[0]*nth_e[0]
;;  Determine strahl direction signs (relative to Bo)
strahl         = find_strahl_direction(TRANSPOSE(des_vdf.MAGF))
;;----------------------------------------------------------------------------------------
;;  Remove data below SC Potential to prevent interpolation/smoothing later
;;----------------------------------------------------------------------------------------
sc_pot_all     = REPLICATE(0e0,nes_e[0],nph_e[0],nth_e[0],nts_e[0])
FOR j=0L, nts_e[0] - 1L DO sc_pot_all[*,*,*,j] = des_vdf[j].SC_POT[0]
tempe          = des_vdf.ENERGY
tempd          = des_vdf.DATA
bad_sc         = WHERE(tempe LE 1.3e0*sc_pot_all,bd_sc)
IF (bd_sc[0] GT 0) THEN tempd[bad_sc] = f
des_vdf.DATA   = tempd
;;  Clean up
delete_variable,tempe,tempd,bad_sc,bd_sc,sc_pot_all
;;----------------------------------------------------------------------------------------
;;  Define necessary arrays for fitting software
;;----------------------------------------------------------------------------------------
des_ts         = des_vdf.TIME
des_te         = des_vdf.END_TIME
tran_des       = [[des_ts],[des_te]]
des_tm         = MEAN(tran_des,/NAN,DIMENSION=2)
;;  Define a GSE sun vector TPLOT handle
sunv_gse       = REPLICATE(1d0,nts_e[0]) # [1e0,0e0,0e0]
sunv_gse_str   = {X:des_tm,Y:sunv_gse}
store_data,'Sun_vec_gse',DATA=sunv_gse_str
;;  Rotate to DBCS
mms_qcotrans,'Sun_vec_gse','Sun_vec_'+scpref[0]+coord_dbcs[0],IN_COORD=coord_gse[0],OUT_COORD=coord_dbcs[0],PROBE=probe[0]
get_data,'Sun_vec_'+scpref[0]+coord_dbcs[0],DATA=sunv_dbcs_str
;;  Clean up
delete_variable,sunv_gse,sunv_gse_str

;;  Get 5D velocities [*** May alter structure on return ***]
vels_e_5d      = lbw_mms_energy_angle_to_velocity_array(des_vdf)
;;  Reform arrays
;;                    0 1 2 3
;;    dat.DATA  -->  [E,A,P,N]
;;   data_e_4d  -->  [N,E,A,P]
;;  Want
;;      arrays  -->  [N,E,A,P]
;;  Define 4D f(vx,vy,vz) and corresponding one-count and Poisson stats arrays
data_e_4d      = TRANSPOSE(  des_vdf.DATA,[3,0,1,2])*1d15    ;;  cm^(-3)  -->  km^(-3)
onec_e_4d      = TRANSPOSE(onec_earr.DATA,[3,0,1,2])*1d15    ;;  cm^(-3)  -->  km^(-3)
pois_e_4d      = TRANSPOSE(pois_earr.DATA,[3,0,1,2])*1d15    ;;  cm^(-3)  -->  km^(-3)
;;  Reform to 2D arrays
data_e_2d      = REFORM(data_e_4d,nts_e[0],kk_e[0])
onec_e_2d      = REFORM(onec_e_4d,nts_e[0],kk_e[0])
pois_e_2d      = REFORM(pois_e_4d,nts_e[0],kk_e[0])
vels_e_2d      = REFORM(vels_e_5d,nts_e[0],kk_e[0],3L)
;;  Clean up
delete_variable,data_e_4d,vels_e_5d,onec_e_4d,pois_e_4d
;;  Define electron velocity moment structures within desired time range for indexing as initial guess values
dens_des_b     = trange_clip_data(temp_dense,TRANGE=fpi_tdbl,PREC=6)
tpar_des_b     = trange_clip_data(temp_tpare,TRANGE=fpi_tdbl,PREC=6)
tper_des_b     = trange_clip_data(temp_tpere,TRANGE=fpi_tdbl,PREC=6)
;;  Clean up
delete_variable,temp_dense,temp_tpare,temp_tpere

;;----------------------------------------------------------------------------------------
;;  Setup plot stuff
;;----------------------------------------------------------------------------------------
;;  All of these can change according to the actual/specific VDF
vlim           = 2d4
nlev           = 30L
ngrid          = 101L
vxy_offs       = REPLICATE(0d0,2)
dfra           = [1d-15,2d-10]
dumbfix        = REPLICATE(0b,6)
sm_cuts        = 1b               ;;  Do smooth cuts
sm_cont        = 1b               ;;  Do smooth contours
nousectab      = 1b
;;  Default fit stuff
def_ftol       = 1d-14
def_gtol       = 1d-14
def_xtol       = 1d-13
;;  Plot title and file name stuff
fnm__des       = file_name_times(tran_des[*,0],PREC=3)
ft___des       = fnm__des[0].F_TIME                       ;;  e.g., '1998-08-09_0801x09.494'
pttl_midf      = 'DES Burst'
ttle_ext       = 'SWF'
pttl_pref      = 'MMS'+probe[0]+' ['+ttle_ext[0]+'] '+pttl_midf[0]
;;  File name stuff
plane          = 'xy'                        ;;  Y vs. X plane
fname_mid      = 'des-'+ft___des
vlim_str       = num2int_str(vlim[0],NUM_CHAR=6L,/ZERO_PAD)
fname_end      = 'para-red_perp-blue_1count-green_plane-'+plane[0]+'_VLIM-'+vlim_str[0]+'km_s'
fname_pre      = scpref[0]+'df_'+ttle_ext[0]+'_'
fnams_out0     = fname_pre[0]+fname_mid+'_'+fname_end[0]
;;  Define dummy variables useful to fitting software
dumb_exv       = {VEC:REPLICATE(0e0,3L),NAME:''}
ex_vecs        = REPLICATE(dumb_exv[0],3L)
xname          = 'Bo'
yname          = 'Vsw'
dumbfix        = REPLICATE(0b,6)
;;----------------------------------------------------------------------------------------
;;  Setup fit function stuff
;;----------------------------------------------------------------------------------------
cfunc          = 'SS'
hfunc          = 'KK'
bfunc          = 'KK'
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot arbitrary example
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
jj             = 550L                 ;;  e.g., Mid-Time = 2015-11-04/05:28:20.516724
dat_df         = des_vdf[jj]
;;  Define plot title and file name
fname_out0     = fnams_out0[jj]+'_Fits_Core-'+cfunc[0]+'_Halo-KK_wo-strahl_Beam-KK'
ptitle         = pttl_pref[0]+': '+trange_str(tran_des[jj,0],tran_des[jj,1],/MSEC)
;;  Define EX_VECS stuff (defined in input coordinate basis, i.e., DBCS or DMPA)
ex_vecs[0]     = {VEC:FLOAT(dat_df[0].VELOCITY),NAME:'Vsw'}
ex_vecs[1]     = {VEC:FLOAT(dat_df[0].MAGF),NAME:'Bo'}
ex_vecs[2]     = {VEC:REFORM(FLOAT(sunv_dbcs_str.Y[jj,*])),NAME:'Sun'}
;;  Define EX_INFO stuff
ex_info        = {SCPOT:dat_df[0].SC_POT,VSW:dat_df[0].VELOCITY,MAGF:dat_df[0].MAGF}
;;----------------------------------------------------------------------------------------
;;  Define VDF-specific initial guesses
;;----------------------------------------------------------------------------------------
cparm          = [9d-1*dens_des_b.Y[jj],vtefac[0]*SQRT(tpar_des_b.Y[jj]),$
                  vtefac[0]*SQRT(tper_des_b.Y[jj]),1d1,1d1,3d0]
hparm          = cparm
bparm          = cparm
hparm[0]      *= 25d-2
hparm[1:2]    *= 2d0
hparm[4]       = 0d0
bparm[0]      *= 15d-2
bparm[1:2]    *= 2d0
bparm[3]       = 3d3
bparm[4]       = 0d0
;;----------------------------------------------------------------------------------------
;;  Define VDF-specific limits/constraints
;;----------------------------------------------------------------------------------------
;;  Density constraints
ncore_ran      = [1,1,75d-2*cparm[0],125d-2*cparm[0]]
nhalo_ran      = [1,1,25d-2*hparm[0],90d-2*ncore_ran[2]]
nbeam_ran      = [1,1,25d-2*bparm[0],90d-2*ncore_ran[2]]
;;  Thermal Speed constraints
vtacorern      = [1,1,65d-2*cparm[1],135d-2*cparm[1]]
vtecorern      = [1,1,65d-2*cparm[2],135d-2*cparm[2]]
vtahalorn      = [1,1,125d-2*cparm[1],1d4]
vtehalorn      = [1,1,125d-2*cparm[2],1d4]
vtabeamrn      = [1,1,125d-2*cparm[1],1d4]
vtebeamrn      = [1,1,125d-2*cparm[2],1d4]
;;  Drift Speed constraints
voahalorn      = [1,1,0d0,15d3]
voabeamrn      = [1,1,2d3,15d3]
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
fixed_h[4]     = 1b         ;;  Prevent halo perp. drift from changing
fixed_b[4]     = 1b         ;;  Prevent beam perp. drift from changing
;;----------------------------------------------------------------------------------------
;;  Account for strahl
;;----------------------------------------------------------------------------------------
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

;;  Define some plot-specific changes
vec1           = REFORM(dat_df[0].MAGF)
vec2           = REFORM(dat_df[0].VELOCITY)
vframe         = vec2
;;  Define data
data_1d        = REFORM(data_e_2d[jj,*])
vels_1d        = REFORM(vels_e_2d[jj,*,*])
onec_1d        = REFORM(onec_e_2d[jj,*])
pois_1d        = REFORM(pois_e_2d[jj,*])
;;  Make sure data above one-count level
diff_1d        = lbw_diff(data_1d,onec_1d*2d0,/NAN)
bad_1d         = WHERE(diff_1d LT 0 OR FINITE(diff_1d) EQ 0,bd_1d)
IF (bd_1d[0] GT 0) THEN data_1d[bad_1d] = f
;;----------------------------------------------------------------------------------------
;;  Plot and save
;;----------------------------------------------------------------------------------------
fname_out      = fname_out0[0]
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
                          /SAVEF,/KEEPNAN,FILENAME=fname_out[0]















