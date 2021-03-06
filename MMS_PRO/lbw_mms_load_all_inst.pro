;+
;*****************************************************************************************
;
;  PROCEDURE:   lbw_mms_load_all_inst.pro
;  PURPOSE  :   This is a wrapping routine that loads all data products from the
;                 following instruments:  FGM, EDP, SCM, and FPI.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               num2int_str.pro
;               tplot_options.pro
;               get_valid_trange.pro
;               timespan.pro
;               timerange.pro
;               get_general_char_name.pro
;               timespan.pro
;               mms_load_state.pro
;               store_data.pro
;               tnames.pro
;               mms_load_mec.pro
;               mms_load_fgm.pro
;               get_data.pro
;               mag__vec.pro
;               t_get_struc_unix.pro
;               sample_rate.pro
;               options.pro
;               mms_load_scm.pro
;               mms_qcotrans.pro
;               str_element.pro
;               mms_load_edp.pro
;               test_tplot_handle.pro
;               mms_load_fpi.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries; and
;               2)  latest SPEDAS libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               lbw_mms_load_all_inst [,PROBE=probe] [,TRANGE=trange]                    $
;                              [,LOAD_DES_DF=load_des_df] [,LOAD_DIS_DF=load_dis_df]     $
;                              [,LOAD_SCM_HIB=load_scm_hib] [,LOAD_EDP_HIE=load_edp_hie] $
;                              [,RM_EDP_SPRT=rm_edp_sprt] [,RM_EDP_DSL=rm_edp_dsl]       $
;                              [,RM_FPI_SPRT=rm_fpi_sprt] [,RM_FPI_POLAR=rm_fpi_polar]   $
;                              [,SPDF=spdf]
;
;  KEYWORDS:    
;               TRANGE        :  [2]-Element [double] array specifying the Unix time
;                                  range for which to define/constrain data
;               PROBE         :  Scalar [string] defining the MMS probe for which to
;                                  load data.  Available inputs include:
;                                    '1'  :  Probe 1
;                                    '2'  :  Probe 2
;                                    '3'  :  Probe 3
;                                    '4'  :  Probe 4
;                                    '*'  :  All Probes [be careful...]
;                                  [Default = '1']
;               LOAD_DES_DF   :  If set, routine loads calibrated DES [Fast,Burst] data
;                                  structures with THETA/PHI angles and VELOCITY/MAGF
;                                  data in DBCS coordinates
;                                  [Default = FALSE]
;               LOAD_DIS_DF   :  If set, routine loads calibrated DIS [Fast,Burst] data
;                                  structures with THETA/PHI angles and VELOCITY/MAGF
;                                  data in DBCS coordinates
;                                  [Default = FALSE]
;               LOAD_SCM_HIB  :  If set, routine loads the highest rate burst B-field
;                                  data from the SCM instrument
;                                  [Default = FALSE]
;               LOAD_EDP_HIE  :  If set, routine loads the highest rate burst E-field
;                                  data from the EDP instrument
;                                  [Default = FALSE]
;               RM_EDP_SPRT   :  If set, routine removes the EDP support data TPLOT handles
;                                  [Default = FALSE]
;               RM_EDP_DSL    :  If set, routine removes the EDP TPLOT handles in the DSL
;                                  coordinate basis
;                                  [Default = FALSE]
;               RM_FPI_SPRT   :  If set, routine removes the FPI support data TPLOT handles
;                                  [Default = FALSE]
;               RM_FPI_POLAR  :  If set, routine removes the FPI TPLOT handle data in
;                                  polar angle format
;                                  [Default = FALSE]
;               SPDF          :  If set, routine will search for data through the SPDF
;                                  servers rather than the LASP servers
;                                  [Default = FALSE]
;
;   CHANGED:  1)  Finished writing routine, added TIME_CLIP setting to mms_load_*
;                   routine calls to force the use of the TRANGE keywords, and
;                   no longer uses DMPA coordinates, just DBCS
;                                                                   [07/12/2018   v1.0.0]
;             2)  Fixed an issue where routine called mms_cotrans.pro instead of
;                   mms_qcotrans.pro
;                                                                   [03/14/2019   v1.0.1]
;
;   NOTES:      
;               1)  Definitions:
;                     MMS    :  Magnetospheric MultiScale mission
;                     AFG    :  Analogue FluxGate magnetometer
;                     DFG    :  Digital FluxGate magnetometer
;                     FGM    :  FluxGate Magnetometer
;                     SDP    :  Spin-plane Double Probe
;                     ADP    :  Axial Double Probe
;                     EDI    :  Electron Drift Instrument
;                     DCE    :  spin-axis component of the DC E-field
;               2)  Coordinate Systems
;                     BCS    :  Body Coordinate System
;                     DBCS   :  despun-BCS
;                     SMPA   :  Spinning, Major Principal Axis (MPA)
;                     DMPA   :  Despun, Major Principal Axis (coordinate system)
;                     GSE    :  Geocentric Solar Ecliptic
;                     GSM    :  Geocentric Solar Magnetospheric
;               3)  Be careful setting PROBE='*' so as to avoid loading too much data...
;               4)  Instrument Mode/Type Definitions:
;                     EDP:
;                       'dcv'    :  DC-Coupled voltage (probe to spacecraft potential)
;                       'dce'    :  DC-Coupled E-field (at ~8192 sps [but could be higher?])
;                       'ace'    :  AC-Coupled E-field (" ", roll-up is around 100 Hz)
;                                   [not available after commissioning phase]
;                       'hmfe'   :  AC-Coupled E-field (at ~65536 sps nominal, up to ~260 ksps)
;                     SCM:
;                       'scb'    :  quasi-DC-coupled B-field in burst mode (at ~8192 sps)
;                                   [ f_cutoff ~ 0.5 Hz, f_min ~ 1.0 Hz ]
;                       'schb'   :  AC-Coupled B-field (at ~16384 sps)
;                                   [ f_cutoff ~ 16 Hz, f_min ~ 32 Hz ]
;                     FGM:
;                       'srvy'   :  Survey mode, DC-coupled B-field [~16 sps]
;                       'brst'   :  Burst mode, DC-coupled B-field [~128 sps]
;                       Support data TPLOT handle strings include:
;                       'etemp'       :  electronics temperature (part of support data)
;                       'stemp'       :  sensor temperature (part of support data)
;                       'hirange'     :  high/low range setting
;                       'flag'        :  data flag [0 = good]
;                       'mode'        :  instrument mode of operation
;                       'bdeltahalf'  :  ∆t/2 for B-field data
;                       'rdeltahalf'  :  ∆t/2 for ephemeris data
;
;  REFERENCES:  
;               0)  Links:
;                      MMS Quick Look Plots:
;                        https://lasp.colorado.edu/mms/sdc/public/quicklook/
;                      SCM Quick Look Plots:
;                        http://mms.lpp.upmc.fr/?page=quicklook
;               1)  Baker, D.N., L. Riesberg, C.K. Pankratz, R.S. Panneton, B.L. Giles,
;                      F.D. Wilder, and R.E. Ergun "Magnetospheric Multiscale Instrument
;                      Suite Operations and Data System," Space Sci. Rev. 199,
;                      pp. 545-575, doi:10.1007/s11214-014-0128-5, (2015).
;               2)  Goldstein, M.L., M. Ashour-Abdalla, A.F. Viñas, J. Dorelli,
;                      D. Wendel, A. Klimas, K.-J. Hwang, M. El-Alaoui, R.J. Walker,
;                      Q. Pan, and H. Liang "Mission Oriented Support and Theory (MOST)
;                      for MMS—the Goddard Space Flight Center/University of California
;                      Los Angeles Interdisciplinary Science Program,"
;                      Space Sci. Rev. 199, pp. 689-719, doi:10.1007/s11214-014-0127-6,
;                      (2015).
;               3)  Torbert, R.B., C.T. Russell, W. Magnes, R.E. Ergun, P.-A. Lindqvist,
;                      O. Le Contel, H. Vaith, J. Macri, S. Myers, D. Rau, J. Needell,
;                      B. King, M. Granoff, M. Chutter, I. Dors, G. Olsson,
;                      Y.V. Khotyaintsev, A. Eriksson, C.A. Kletzing, S. Bounds,
;                      B. Anderson, W. Baumjohann, M. Steller, K. Bromund, G. Le,
;                      R. Nakamura, R.J. Strangeway, H.K. Leinweber, S. Tucker,
;                      J. Westfall, D. Fischer, F. Plaschke, J. Porter, and
;                      K. Lappalainen "The FIELDS Instrument Suite on MMS: Scientific
;                      Objectives, Measurements, and Data Products," Space Sci. Rev. 199,
;                      pp. 105-135, doi:10.1007/s11214-014-0109-8, (2014).
;               4)  Russell, C.T., B.J. Anderson, W. Baumjohann, K.R. Bromund,
;                      D. Dearborn, D. Fischer, G. Le, H.K. Leinweber, D. Leneman,
;                      W. Magnes, J.D. Means, M.B. Moldwin, R. Nakamura, D. Pierce,
;                      F. Plaschke, K.M. Rowe, J.A. Slavin, R.J. Strangeway, R. Torbert,
;                      C. Hagen, I. Jernej, A. Valavanoglou, and I. Richter "The
;                      Magnetospheric Multiscale Magnetometers," Space Sci. Rev. 199,
;                      pp. 189-256, doi:10.1007/s11214-014-0057-3, (2014).
;               5)  Lindqvist, P.-A., G. Olsson, R.B. Torbert, B. King, M. Granoff,
;                      D. Rau, G. Needell, S. Turco, I. Dors, P. Beckman, J. Macri,
;                      C. Frost, J. Salwen, A. Eriksson, L. Åhlén, Y.V. Khotyaintsev,
;                      J. Porter, K. Lappalainen, R.E. Ergun, W. Wermeer, and S. Tucker
;                      "The Spin-Plane Double Probe Electric Field Instrument for MMS,"
;                      Space Sci. Rev. 199, pp. 137-165, doi:10.1007/s11214-014-0116-9,
;                      (2014).
;               6)  Ergun, R.E., S. Tucker, J. Westfall, K.A. Goodrich, D.M. Malaspina,
;                      D. Summers, J. Wallace, M. Karlsson, J. Mack, N. Brennan, B. Pyke,
;                      P. Withnell, R. Torbert, J. Macri, D. Rau, I. Dors, J. Needell,
;                      P.-A. Lindqvist, G. Olsson, and C.M. Cully "The Axial Double Probe
;                      and Fields Signal Processing for the MMS Mission," Space Sci. Rev.
;                      199, pp. 167-188, doi:10.1007/s11214-014-0115-x, (2014).
;               7)  Le Contel, O., P. Leroy, A. Roux, C. Coillot, D. Alison,
;                      A. Bouabdellah, L. Mirioni, L. Meslier, A. Galic, M.C. Vassal,
;                      R.B. Torbert, J. Needell, D. Rau, I. Dors, R.E. Ergun, J. Westfall,
;                      D. Summers, J. Wallace, W. Magnes, A. Valavanoglou, G. Olsson,
;                      M. Chutter, J. Macri, S. Myers, S. Turco, J. Nolin, D. Bodet,
;                      K. Rowe, M. Tanguy, and B. de la Porte "The Search-Coil
;                      Magnetometer for MMS," Space Sci. Rev. 199, pp. 257-282,
;                      doi:10.1007/s11214-014-0096-9, (2014).
;               8)  Pollock, C., T. Moore, A. Jacques, J. Burch, U. Gliese, Y. Saito,
;                      T. Omoto, L. Avanov, A. Barrie, V. Coffey, J. Dorelli, D. Gershman,
;                      B. Giles, T. Rosnack, C. Salo, S. Yokota, M. Adrian, C. Aoustin,
;                      C. Auletti, S. Aung, V. Bigio, N. Cao, M. Chandler, D. Chornay,
;                      K. Christian, G. Clark, G. Collinson, T. Corris, A. De Los Santos,
;                      R. Devlin, T. Diaz, T. Dickerson, C. Dickson, A. Diekmann,
;                      F. Diggs, C. Duncan, A.F.- Viñas, C. Firman, M. Freeman,
;                      N. Galassi, K. Garcia, G. Goodhart, D. Guererro, J. Hageman,
;                      J. Hanley, E. Hemminger, M. Holland, M. Hutchins, T. James,
;                      W. Jones, S. Kreisler, J. Kujawski, V. Lavu, J. Lobell,
;                      E. LeCompte, A. Lukemire, E. MacDonald, A. Mariano, T. Mukai,
;                      K. Narayanan, Q. Nguyan, M. Onizuka, W. Paterson, S. Persyn,
;                      B. Piepgrass, F. Cheney, A. Rager, T. Raghuram, A. Ramil,
;                      L. Reichenthal, H. Rodriguez, J. Rouzaud, A. Rucker, Y. Saito,
;                      M. Samara, J.-A. Sauvaud, D. Schuster, M. Shappirio, K. Shelton,
;                      D. Sher, D. Smith, K. Smith, S. Smith, D. Steinfeld,
;                      R. Szymkiewicz, K. Tanimoto, J. Taylor, C. Tucker, K. Tull,
;                      A. Uhl, J. Vloet, P. Walpole, S. Weidner, D. White, G. Winkert,
;                      P.-S. Yeh, and M. Zeuch "Fast Plasma Investigation for
;                      Magnetospheric Multiscale," Space Sci. Rev. 199, pp. 331-406,
;                      doi:10.1007/s11214-016-0245-4, (2016).
;
;   CREATED:  06/29/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/14/2019   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO lbw_mms_load_all_inst,TRANGE=trange,PROBE=probe,LOAD_DES_DF=load_des_df,   $
                          LOAD_DIS_DF=load_dis_df,RM_FGM_SPRT=rm_fgm_sprt,     $
                          LOAD_SCM_HIB=load_scm_hib,LOAD_EDP_HIE=load_edp_hie, $
                          RM_EDP_SPRT=rm_edp_sprt,RM_EDP_DSL=rm_edp_dsl,       $
                          RM_FPI_SPRT=rm_fpi_sprt,RM_FPI_POLAR=rm_fpi_polar,   $
                          SPDF=spdf

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
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
coord_mag      = 'mag'
coord_tot      = 'tot'
coord_bcs      = 'bcs'                    ;;  Body Coordinate System (of MMS spacecraft)
coord_dbcs     = 'dbcs'                   ;;  despun-BCS
coord_dmpa     = 'dmpa'                   ;;  Despun, Major Principal Axis (coordinate system)
vec_str        = ['x','y','z']
vec_col        = [250,150, 50]
probes         = ['1','2','3','4','*']
;;----------------------------------------------------------------------------------------
;;  Define some defaults
;;----------------------------------------------------------------------------------------
lab_flg        = -1
ssfb_str       = ['srvy','slow','fast','brst']
fpi_types      = ['des-dist', 'dis-dist', 'dis-moms', 'des-moms']
scm_types      = ['scb','schb']
edp_types      = ['dcv','dce','ace','hmfe']
fgm_supprt     = ['etemp','stemp','hirange','flag','mode','bdeltahalf','rdeltahalf']
edp_supprt     = ['res','err','bitmask','quality']
fpi_supprt     = ['err','errorflags','compressionloss','startdelphi','steptable','sector_despinp']
estring        = 'energy'+['',num2int_str(LINDGEN(20))]
fpi_ex_tpn     = '_'+[['pitch','energy']+'_index','pitchangdist','energyspectr','alpha',$
                      estring,'temp'+['para','perp']]+'_'
fpi_polart     = ['azimuth','zenith']
tplot_options,'XMARGIN',[ 20, 15]
tplot_options,'YMARGIN',[ 5, 5]
;;----------------------------------------------------------------------------------------
;;  Date/Times/Probes
;;----------------------------------------------------------------------------------------
tra_struc      = get_valid_trange(TRANGE=trange,PRECISION=prec)
tran           = tra_struc.UNIX_TRANGE            ;;  Unix time range
tdates         = tra_struc.DATE_TRANGE            ;;  Date range [e.g., 'YYYY-MM-DD']
;;  Set timespan/timerange
dt             = tran[1] - tran[0]
timespan,tran[0],dt[0],/SECONDS
IF ~KEYWORD_SET(trange) THEN tr = timerange() ELSE tr = tran
trs            = tr + [-1d0,1d0]*6d2  ;;  use longer time range for state and support data
;;----------------------------------------------------------------------------------------
;;  Define probe
;;----------------------------------------------------------------------------------------
IF ~KEYWORD_SET(probe) THEN probe0 = '*' ELSE probe0 = probe[0]
sc             = get_general_char_name(probes,CHARS=probe0[0],DEF__NAME='*')
scpref         = 'mms'+probe[0]+'_'
;;----------------------------------------------------------------------------------------
;; Load state data (position, spin, etc.)
;;----------------------------------------------------------------------------------------
mms_load_state,TRANGE=trs,PROBES=sc,DATATYPES='*',SPDF=spdf
;;  Remove MEC TPLOT handles
store_data,DELETE=tnames(scpref[0]+'mec_*')
;;  Load quaternions
mms_load_mec,TRANGE=trs,PROBE=sc,VARFORMAT='*_quat_*',/TIME_CLIP
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; Load level 2 quasi-static magnetic field data (FGM)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
mms_load_fgm,TRANGE=tran,PROBES=sc,DATA_RATE=ssfb_str[0],LEVEL='l2',$
             /GET_SUPPORT_DATA,/LATEST_VERSION,SPDF=spdf,/TIME_CLIP
mms_load_fgm,TRANGE=tran,PROBES=sc,DATA_RATE=ssfb_str[1],LEVEL='l2',$
             /GET_SUPPORT_DATA,/LATEST_VERSION,SPDF=spdf,/TIME_CLIP
mms_load_fgm,TRANGE=tran,PROBES=sc,DATA_RATE=ssfb_str[3],LEVEL='l2',$
             /GET_SUPPORT_DATA,/LATEST_VERSION,SPDF=spdf,/TIME_CLIP
;;----------------------------------------------------------------------------------------
;;  Remove BCS, *_bvec, and *_btot TPLOT handles
;;----------------------------------------------------------------------------------------
bad_tpns = tnames(scpref[0]+'fgm_*_bcs_*')
IF (bad_tpns[0] NE '') THEN store_data,DELETE=tnames(scpref[0]+'fgm_*_bcs_*')
;;  Remove *_bvec and *_btot TPLOT handles and redefine
bad_tpns = tnames(scpref[0]+'fgm_*_l2_bvec')
IF (bad_tpns[0] NE '') THEN store_data,DELETE=tnames(scpref[0]+'fgm_*_l2_bvec')
bad_tpns = tnames(scpref[0]+'fgm_*_l2_btot')
IF (bad_tpns[0] NE '') THEN store_data,DELETE=tnames(scpref[0]+'fgm_*_l2_btot')
;;  Check RM_FGM_SPRT
test           = KEYWORD_SET(rm_fgm_sprt)
IF (test[0]) THEN BEGIN
  bad_tpns = tnames(scpref[0]+'fgm_'+fgm_supprt+'_*')
  IF (bad_tpns[0] NE '') THEN store_data,DELETE=bad_tpns
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get data, remove "bad" TPLOT handles, and rename
;;----------------------------------------------------------------------------------------
fgm_btpn_pref  = scpref[0]+'fgm_b_'
fgm_btpn_suff  = '_'+ssfb_str+'_l2'
;;  Survey
fgm_gse_svtpn  = tnames(fgm_btpn_pref[0]+coord_gse[0]+fgm_btpn_suff[0])
fgm_gsm_svtpn  = tnames(fgm_btpn_pref[0]+coord_gsm[0]+fgm_btpn_suff[0])
;;  Slow
fgm_gse_sltpn  = tnames(fgm_btpn_pref[0]+coord_gse[0]+fgm_btpn_suff[1])
fgm_gsm_sltpn  = tnames(fgm_btpn_pref[0]+coord_gsm[0]+fgm_btpn_suff[1])
;;  Fast
fgm_gse_fatpn  = tnames(fgm_btpn_pref[0]+coord_gse[0]+fgm_btpn_suff[2])
fgm_gsm_fatpn  = tnames(fgm_btpn_pref[0]+coord_gsm[0]+fgm_btpn_suff[2])
;;  Burst
fgm_gse_bstpn  = tnames(fgm_btpn_pref[0]+coord_gse[0]+fgm_btpn_suff[3])
fgm_gsm_bstpn  = tnames(fgm_btpn_pref[0]+coord_gsm[0]+fgm_btpn_suff[3])
all_fgm_gse_tp = [fgm_gse_svtpn[0],fgm_gse_sltpn[0],fgm_gse_fatpn[0],fgm_gse_bstpn[0]]
all_fgm_gsm_tp = [fgm_gsm_svtpn[0],fgm_gsm_sltpn[0],fgm_gsm_fatpn[0],fgm_gsm_bstpn[0]]
all_fgm_mag_tp = REPLICATE('',4L)
n_fgm_tp       = N_ELEMENTS(all_fgm_gse_tp)
FOR j=0L, n_fgm_tp[0] - 1L DO BEGIN
  ;;  Make sure TPLOT handles are valid before moving forward
  test           = (all_fgm_gse_tp[j] EQ '') OR (all_fgm_gsm_tp[j] EQ '')
  IF (test[0]) THEN CONTINUE
  get_data,all_fgm_gse_tp[j],DATA=t_bgse_vm,DLIMIT=dlim_bgse,LIMIT=lim_bgse
  get_data,all_fgm_gsm_tp[j],DATA=t_bgsm_vm,DLIMIT=dlim_bgsm,LIMIT=lim_bgsm
  ;;  Define parameters
  bvec_gse       = REFORM(t_bgse_vm.Y[*,0:2])
  bvec_gsm       = REFORM(t_bgsm_vm.Y[*,0:2])
  bmag           = mag__vec(bvec_gse,/NAN)
  b_t0           = t_get_struc_unix(t_bgse_vm)
  t_off          = MIN(b_t0,/NAN)
  b__t           = b_t0 - t_off[0]
  srate0         = sample_rate(b__t,/AVERAGE)
  test           = (srate0[0] GT 10)
  IF (test[0]) THEN BEGIN
    srfac   = 1d0
    srunits = 'sps'
  ENDIF ELSE BEGIN
    srfac   = 1d3
    srunits = 'msps'
  ENDELSE
  srate_bo       = DOUBLE(ROUND(srate0[0]*srfac[0]))
  srate_str      = num2int_str(srate_bo[0])
  ;;  Define new YTITLEs, labels, etc.
  bv_labs        = 'B'+vec_str
  bm_yttls       = '|Bo| [nT]'
  bv_yttls       = 'Bo ['+STRUPCASE([coord_gse[0],coord_gsm[0]])+', nT]'
  bo_ysub        = '[FGM Samp. Rate: '+srate_str[0]+' '+srunits[0]+']'
  struc_bmag     = {X:b__t,Y:bmag,    TSHIFT:t_off[0]}
  struc_bgse     = {X:b__t,Y:bvec_gse,TSHIFT:t_off[0]}
  struc_bgsm     = {X:b__t,Y:bvec_gsm,TSHIFT:t_off[0]}
  fgm_mag_tpnout = scpref[0]+'fgm_'+ssfb_str[j]+'_l2_'+coord_tot[0]             ;;  Use TOT instead of MAG to avoid confusion with solar magnetic or other magnetic coordinate bases
  fgm_gse_tpnout = scpref[0]+'fgm_'+ssfb_str[j]+'_l2_'+coord_gse[0]
  fgm_gsm_tpnout = scpref[0]+'fgm_'+ssfb_str[j]+'_l2_'+coord_gsm[0]
  store_data,fgm_mag_tpnout[0],DATA=struc_bmag,DLIMIT=dlim_bgse,LIMIT=lim_bgse
  store_data,fgm_gse_tpnout[0],DATA=struc_bgse,DLIMIT=dlim_bgse,LIMIT=lim_bgse
  store_data,fgm_gsm_tpnout[0],DATA=struc_bgsm,DLIMIT=dlim_bgsm,LIMIT=lim_bgsm
  ;;  Fix options/labels/colors
  options,fgm_mag_tpnout[0],LABELS=['mag'],YTITLE=bm_yttls[0],YSUBTITLE=bo_ysub[0],COLORS=50,LABFLAG=lab_flg[0]-1,/DEF
  options,fgm_gse_tpnout[0],LABELS=bv_labs,YTITLE=bv_yttls[0],YSUBTITLE=bo_ysub[0],COLORS=vec_col,LABFLAG=lab_flg[0],/DEF
  options,fgm_gsm_tpnout[0],LABELS=bv_labs,YTITLE=bv_yttls[1],YSUBTITLE=bo_ysub[0],COLORS=vec_col,LABFLAG=lab_flg[0],/DEF
  nna            = [fgm_mag_tpnout[0],fgm_gse_tpnout[0],fgm_gsm_tpnout[0]]
  options,nna,'LABELS'
  options,nna,'COLORS'
  options,nna,'LABFLAG'
  ;;  Remove old versions that have combined magnitude and vector components
  store_data,DELETE=[all_fgm_gse_tp[j],all_fgm_gsm_tp[j]]
  ;;  Redefine all TPLOT handle arrays
  all_fgm_gse_tp[j] = fgm_gse_tpnout[0]
  all_fgm_gsm_tp[j] = fgm_gsm_tpnout[0]
  all_fgm_mag_tp[j] = fgm_mag_tpnout[0]
  ;;  Reset variables [save space]
  t_bgse_vm      = 0
  t_bgsm_vm      = 0
  bvec_gse       = 0
  bvec_gsm       = 0
  bmag           = 0
  b_t0           = 0
  b__t           = 0
  struc_bgse     = 0
  struc_bgsm     = 0
  struc_bmag     = 0
ENDFOR
;;  Clean up
IF (N_ELEMENTS(bvec_gse  ) GT 0) THEN dumb = TEMPORARY(bvec_gse  )
IF (N_ELEMENTS(bvec_gsm  ) GT 0) THEN dumb = TEMPORARY(bvec_gsm  )
IF (N_ELEMENTS(b_t0      ) GT 0) THEN dumb = TEMPORARY(b_t0      )
IF (N_ELEMENTS(b__t      ) GT 0) THEN dumb = TEMPORARY(b__t      )
IF (N_ELEMENTS(struc_bgse) GT 0) THEN dumb = TEMPORARY(struc_bgse)
IF (N_ELEMENTS(dlim_bgse ) GT 0) THEN dumb = TEMPORARY(dlim_bgse )
IF (N_ELEMENTS(lim_bgse  ) GT 0) THEN dumb = TEMPORARY(lim_bgse  )
IF (N_ELEMENTS(t_bgse_vm ) GT 0) THEN dumb = TEMPORARY(t_bgse_vm )
;;  Redefine all TPLOT handle arrays
all_fgm_gse_tp = tnames(all_fgm_gse_tp)
all_fgm_gsm_tp = tnames(all_fgm_gsm_tp)
all_fgm_mag_tp = tnames(all_fgm_mag_tp)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; Load level 2 AC magnetic field data (SCM)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check LOAD_SCM_HIB
test           = (~KEYWORD_SET(load_scm_hib) AND (N_ELEMENTS(load_scm_hib) GT 0)) OR $
                   (N_ELEMENTS(load_scm_hib) EQ 0)
IF (test[0]) THEN d_types = scm_types[0] ELSE d_types = scm_types
mms_load_scm,TRANGE=tran,PROBES=sc,DATA_RATE=ssfb_str[3],DATATYPE=d_types,$
             LEVEL='l2',/GET_SUPPORT_DATA,/LATEST_VERSION,SPDF=spdf,/TIME_CLIP
;;  Define TPLOT handles
scm_btpn_pref  = scpref[0]+'scm_acb_'
scm_btpn_suff  = '_'+d_types+'_'+ssfb_str[3]+'_l2'
;;----------------------------------------------------------------------------------------
;;  Get data, remove "bad" TPLOT handles, and rename
;;----------------------------------------------------------------------------------------
scm_tpn_old    = tnames(scm_btpn_pref[0]+coord_gse[0]+scm_btpn_suff)
scm_tpn_new    = scm_btpn_pref[0]+ssfb_str[3]+'_'+d_types+'_l2_'+coord_gse[0]
n_scm_tp       = N_ELEMENTS(scm_tpn_old)
FOR j=0L, n_scm_tp[0] - 1L DO BEGIN
  ;;  Make sure TPLOT handles are valid before moving forward
  test           = (scm_tpn_old[j] EQ '')
  IF (test[0]) THEN CONTINUE
  get_data,scm_tpn_old[j],DATA=t_bgse_vm,DLIMIT=dlim_bgse,LIMIT=lim_bgse
  test           = (SIZE(t_bgse_vm,/TYPE) NE 8)
  IF (test[0]) THEN CONTINUE
  ;;  Define parameters
  bvec_gse       = t_bgse_vm.Y
  b_t0           = t_get_struc_unix(t_bgse_vm)
  t_off          = MIN(b_t0,/NAN)
  b__t           = b_t0 - t_off[0]
  srate0         = sample_rate(b__t,/AVERAGE)
  test           = (srate0[0] GT 10)
  IF (test[0]) THEN BEGIN
    srfac   = 1d0
    srunits = 'sps'
  ENDIF ELSE BEGIN
    srfac   = 1d3
    srunits = 'msps'
  ENDELSE
  srate_bo       = DOUBLE(ROUND(srate0[0]*srfac[0]))
  srate_str      = num2int_str(srate_bo[0])
  ;;  Define new YTITLEs, labels, etc.
  bv_labs        = 'B'+vec_str
  bv_yttls       = 'B ['+STRUPCASE(coord_gse[0])+', nT]'
  bo_ysub        = '[SCM Samp. Rate: '+srate_str[0]+' '+srunits[0]+']'
  struc_bgse     = {X:b__t,Y:bvec_gse,TSHIFT:t_off[0]}
  store_data,scm_tpn_new[j],DATA=struc_bgse,DLIMIT=dlim_bgse,LIMIT=lim_bgse
  ;;  Fix options/labels/colors
  options,scm_tpn_new[j],LABELS=bv_labs,YTITLE=bv_yttls[0],YSUBTITLE=bo_ysub[0],COLORS=vec_col,LABFLAG=lab_flg[0],/DEF
  options,scm_tpn_new[j],'LABELS'
  options,scm_tpn_new[j],'COLORS'
  options,scm_tpn_new[j],'LABFLAG'
  ;;  Remove old versions that have combined magnitude and vector components
  store_data,DELETE=scm_tpn_old[j]
  ;;  Reset variables [save space]
  t_bgse_vm      = 0
  bvec_gse       = 0
  b_t0           = 0
  b__t           = 0
  struc_bgse     = 0
ENDFOR
;;  Clean up
IF (N_ELEMENTS(bvec_gse  ) GT 0) THEN dumb = TEMPORARY(bvec_gse  )
IF (N_ELEMENTS(bvec_gsm  ) GT 0) THEN dumb = TEMPORARY(bvec_gsm  )
IF (N_ELEMENTS(b_t0      ) GT 0) THEN dumb = TEMPORARY(b_t0      )
IF (N_ELEMENTS(b__t      ) GT 0) THEN dumb = TEMPORARY(b__t      )
IF (N_ELEMENTS(struc_bgse) GT 0) THEN dumb = TEMPORARY(struc_bgse)
IF (N_ELEMENTS(dlim_bgse ) GT 0) THEN dumb = TEMPORARY(dlim_bgse )
IF (N_ELEMENTS(lim_bgse  ) GT 0) THEN dumb = TEMPORARY(lim_bgse  )
IF (N_ELEMENTS(t_bgse_vm ) GT 0) THEN dumb = TEMPORARY(t_bgse_vm )
;;----------------------------------------------------------------------------------------
;;  Redefine all TPLOT handle arrays --> Rotate to GSM
;;----------------------------------------------------------------------------------------
all_scm_gse_tp = tnames(scm_tpn_new)
n_scm_tp       = N_ELEMENTS(all_scm_gse_tp)
FOR j=0L, n_scm_tp[0] - 1L DO BEGIN
  test           = (tnames(all_scm_gse_tp[j]) EQ '')
  IF (test[0]) THEN CONTINUE
  scut     = STRLEN(all_scm_gse_tp[j]) - 4L
  name_in  = STRMID(all_scm_gse_tp[j],0L,scut[0])
  mms_qcotrans,name_in[0],IN_COORD=coord_gse[0],OUT_COORD=coord_gsm[0],$
                          IN_SUFFIX='_'+coord_gse[0],OUT_SUFFIX='_'+coord_gsm[0]
  ;;  Check for TSHIFT tag
  get_data,name_in[0]+'_'+coord_gse[0],DATA=temp__in
  get_data,name_in[0]+'_'+coord_gsm[0],DATA=temp_out,DLIMIT=dlim,LIMIT=lim
  IF (SIZE(temp__in,/TYPE) NE 8 OR SIZE(temp_out,/TYPE) NE 8) THEN CONTINUE
  unix           = t_get_struc_unix(temp__in,TSHFT_ON=tshft_on)
  IF (tshft_on[0]) THEN delt = temp__in.TSHIFT[0] ELSE delt = 0d0
  str_element,temp_out,     'X',unix - delt[0],/ADD_REPLACE
  str_element,temp_out,'TSHIFT',       delt[0],/ADD_REPLACE
  store_data,name_in[0]+'_'+coord_gsm[0],DATA=temp_out,DLIMIT=dlim,LIMIT=lim
  ;;  Clean up
  dumb           = TEMPORARY(temp__in)
  dumb           = TEMPORARY(temp_out)
  dumb           = TEMPORARY(unix)
ENDFOR
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; Load level 2 electric field data (EDP)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check LOAD_EDP_HIE
test           = (~KEYWORD_SET(load_edp_hie) AND (N_ELEMENTS(load_edp_hie) GT 0)) OR $
                   (N_ELEMENTS(load_edp_hie) EQ 0)
IF (test[0]) THEN d_types = edp_types[0:2] ELSE d_types = edp_types
n_t            = N_ELEMENTS(d_types)
FOR j=0L, n_t[0] - 1L DO BEGIN
  mms_load_edp,TRANGE=tran,PROBES=sc,LEVEL='l2',DATATYPE=d_types[j],$
               DATA_RATE=ssfb_str[2],/GET_SUPPORT_DATA,/LATEST_VERSION,SPDF=spdf,/TIME_CLIP
  mms_load_edp,TRANGE=tran,PROBES=sc,LEVEL='l2',DATATYPE=d_types[j],$
               DATA_RATE=ssfb_str[3],/GET_SUPPORT_DATA,/LATEST_VERSION,SPDF=spdf,/TIME_CLIP
ENDFOR
;;  Check RM_EDP_SPRT
test           = KEYWORD_SET(rm_edp_sprt)
IF (test[0]) THEN BEGIN
  bad_tpns = tnames(scpref[0]+'edp_*'+edp_supprt+'_*')
  IF (bad_tpns[0] NE '') THEN store_data,DELETE=bad_tpns
ENDIF
;;  Load spacecraft potential [V]
;;    Relevant TPLOT handle of the form:
;;      mms?_edp_scpot_[MODE]_l2
mms_load_edp,TRANGE=tran,PROBES=sc,LEVEL='l2',DATATYPE='scpot',$
             DATA_RATE=ssfb_str[2],/GET_SUPPORT_DATA,/LATEST_VERSION,SPDF=spdf,/TIME_CLIP
;;----------------------------------------------------------------------------------------
;;  Get data, remove "bad" TPLOT handles, and rename
;;----------------------------------------------------------------------------------------
edp_btpn_pref  = scpref[0]+'edp_'
edp_btpn_suff  = '_'+ssfb_str+'_l2'
;;  Survey
edp_gse_svtpn  = edp_btpn_pref[0]+edp_types+'_'+coord_gse[0]+edp_btpn_suff[0]
edp_dsl_svtpn  = edp_btpn_pref[0]+edp_types+'_'+coord_dsl[0]+edp_btpn_suff[0]
;;  Slow
edp_gse_sltpn  = edp_btpn_pref[0]+edp_types+'_'+coord_gse[0]+edp_btpn_suff[1]
edp_dsl_sltpn  = edp_btpn_pref[0]+edp_types+'_'+coord_dsl[0]+edp_btpn_suff[1]
;;  Fast
edp_gse_fatpn  = edp_btpn_pref[0]+edp_types+'_'+coord_gse[0]+edp_btpn_suff[2]
edp_dsl_fatpn  = edp_btpn_pref[0]+edp_types+'_'+coord_dsl[0]+edp_btpn_suff[2]
;;  Burst
edp_gse_bstpn  = edp_btpn_pref[0]+edp_types+'_'+coord_gse[0]+edp_btpn_suff[3]
edp_dsl_bstpn  = edp_btpn_pref[0]+edp_types+'_'+coord_dsl[0]+edp_btpn_suff[3]
;;  Define by EDP mode
dcv_edp_gse_tp = [edp_gse_svtpn[0],edp_gse_sltpn[0],edp_gse_fatpn[0],edp_gse_bstpn[0]]
dce_edp_gse_tp = [edp_gse_svtpn[1],edp_gse_sltpn[1],edp_gse_fatpn[1],edp_gse_bstpn[1]]
ace_edp_gse_tp = [edp_gse_svtpn[2],edp_gse_sltpn[2],edp_gse_fatpn[2],edp_gse_bstpn[2]]
hbs_edp_gse_tp = [edp_gse_svtpn[3],edp_gse_sltpn[3],edp_gse_fatpn[3],edp_gse_bstpn[3]]

all_edp_gse_tp = [dce_edp_gse_tp,dcv_edp_gse_tp,ace_edp_gse_tp,hbs_edp_gse_tp]
all_edp_dsl_tp = [edp_dsl_svtpn,edp_dsl_sltpn,edp_dsl_fatpn,edp_dsl_bstpn]
;;  Check RM_EDP_DSL
test           = KEYWORD_SET(rm_edp_dsl)
IF (test[0]) THEN BEGIN
  bad_tpns = tnames(all_edp_dsl_tp)
  IF (bad_tpns[0] NE '') THEN store_data,DELETE=bad_tpns
ENDIF
;;----------------------------------------------------------------------------------------
;;  Rename E-Field TPLOT handles
;;----------------------------------------------------------------------------------------
edp_srv_tp_old = edp_gse_svtpn
edp_slv_tp_old = edp_gse_sltpn
edp_fav_tp_old = edp_gse_fatpn
edp_bsv_tp_old = edp_gse_bstpn
edp_srv_tp_new = edp_btpn_pref[0]+edp_types+edp_btpn_suff[0]+'_'+coord_gse[0]
edp_slv_tp_new = edp_btpn_pref[0]+edp_types+edp_btpn_suff[1]+'_'+coord_gse[0]
edp_fav_tp_new = edp_btpn_pref[0]+edp_types+edp_btpn_suff[2]+'_'+coord_gse[0]
edp_bsv_tp_new = edp_btpn_pref[0]+edp_types+edp_btpn_suff[3]+'_'+coord_gse[0]
edp_old_rates  = CREATE_STRUCT(ssfb_str,edp_srv_tp_old,edp_slv_tp_old,edp_fav_tp_old,$
                                        edp_bsv_tp_old)
edp_new_rates  = CREATE_STRUCT(ssfb_str,edp_srv_tp_new,edp_slv_tp_new,edp_fav_tp_new,$
                                        edp_bsv_tp_new)
n_r            = N_ELEMENTS(ssfb_str)
FOR j=0L, n_r[0] - 1L DO BEGIN
  test_old = test_tplot_handle(edp_old_rates.(j),TPNMS=old_tpns,GIND=good_otpn)
  new_tpns = edp_new_rates.(j)
  n_edp_tp = LONG(TOTAL(good_otpn GE 0))
  IF (n_edp_tp EQ 0) THEN CONTINUE        ;;  No old TPLOT handles --> jump to next rate
  FOR k=0L, n_edp_tp[0] - 1L DO BEGIN
    ;;  Make sure TPLOT handles are valid before moving forward
    gk             = good_otpn[k]
    get_data,old_tpns[k],DATA=t_bgse_vm,DLIMIT=dlim_bgse,LIMIT=lim_bgse
    test           = (SIZE(t_bgse_vm,/TYPE) NE 8)
    IF (test[0]) THEN CONTINUE
    ;;  Define parameters
    bvec_gse       = t_bgse_vm.Y
    b_t0           = t_get_struc_unix(t_bgse_vm)
    t_off          = MIN(b_t0,/NAN)
    b__t           = b_t0 - t_off[0]
    srate0         = sample_rate(b__t,/AVERAGE)
    test           = (srate0[0] GT 10)
    IF (test[0]) THEN BEGIN
      srfac   = 1d0
      srunits = 'sps'
    ENDIF ELSE BEGIN
      srfac   = 1d3
      srunits = 'msps'
    ENDELSE
    srate_bo       = DOUBLE(ROUND(srate0[0]*srfac[0]))
    srate_str      = num2int_str(srate_bo[0])
    ;;  Define new YTITLEs, labels, etc.
    bv_labs        = 'E'+vec_str
    bv_yttls       = 'E ['+STRUPCASE(coord_gse[0])+', mV/m]'
    bo_ysub        = '[EDP Samp. Rate: '+srate_str[0]+' '+srunits[0]+']'
    struc_bgse     = {X:b__t,Y:bvec_gse,TSHIFT:t_off[0]}
    store_data,new_tpns[gk],DATA=struc_bgse,DLIMIT=dlim_bgse,LIMIT=lim_bgse
    ;;  Fix options/labels/colors
    options,new_tpns[gk],LABELS=bv_labs,YTITLE=bv_yttls[0],YSUBTITLE=bo_ysub[0],COLORS=vec_col,LABFLAG=lab_flg[0],/DEF
    options,new_tpns[gk],'LABELS'
    options,new_tpns[gk],'COLORS'
    options,new_tpns[gk],'LABFLAG'
    ;;  Remove old versions
    store_data,DELETE=old_tpns[k]
    ;;  Reset variables [save space]
    t_bgse_vm      = 0
    bvec_gse       = 0
    b_t0           = 0
    b__t           = 0
    struc_bgse     = 0
  ENDFOR
ENDFOR
;;  Clean up
IF (N_ELEMENTS(bvec_gse  ) GT 0) THEN dumb = TEMPORARY(bvec_gse  )
IF (N_ELEMENTS(bvec_gsm  ) GT 0) THEN dumb = TEMPORARY(bvec_gsm  )
IF (N_ELEMENTS(b_t0      ) GT 0) THEN dumb = TEMPORARY(b_t0      )
IF (N_ELEMENTS(b__t      ) GT 0) THEN dumb = TEMPORARY(b__t      )
IF (N_ELEMENTS(struc_bgse) GT 0) THEN dumb = TEMPORARY(struc_bgse)
IF (N_ELEMENTS(dlim_bgse ) GT 0) THEN dumb = TEMPORARY(dlim_bgse )
IF (N_ELEMENTS(lim_bgse  ) GT 0) THEN dumb = TEMPORARY(lim_bgse  )
IF (N_ELEMENTS(t_bgse_vm ) GT 0) THEN dumb = TEMPORARY(t_bgse_vm )
;;----------------------------------------------------------------------------------------
;;  Rotate EDP data
;;----------------------------------------------------------------------------------------
;;  Define by EDP mode
dcv_edp_gse_tp = tnames([edp_gse_svtpn[0],edp_gse_sltpn[0],edp_gse_fatpn[0],edp_gse_bstpn[0]])
dce_edp_gse_tp = tnames([edp_gse_svtpn[1],edp_gse_sltpn[1],edp_gse_fatpn[1],edp_gse_bstpn[1]])
ace_edp_gse_tp = tnames([edp_gse_svtpn[2],edp_gse_sltpn[2],edp_gse_fatpn[2],edp_gse_bstpn[2]])
hbs_edp_gse_tp = tnames([edp_gse_svtpn[3],edp_gse_sltpn[3],edp_gse_fatpn[3],edp_gse_bstpn[3]])
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; Load level 2 electron and ion velocity distribution data (DES/DIS from FPI)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check LOAD_DES_DF
test           = (~KEYWORD_SET(load_des_df) AND (N_ELEMENTS(load_des_df) GT 0)) OR $
                   (N_ELEMENTS(load_des_df) EQ 0)
IF (test[0]) THEN fpi_types[0] = ''
;;  Check LOAD_DIS_DF
test           = (~KEYWORD_SET(load_dis_df) AND (N_ELEMENTS(load_dis_df) GT 0)) OR $
                   (N_ELEMENTS(load_dis_df) EQ 0)
IF (test[0]) THEN fpi_types[1] = ''
n_fpi_tp       = N_ELEMENTS(fpi_types)
;;  mms_load_fpi.pro expects the TIME_CLIP keyword to be set otherwise it will not follow TRANGE
FOR j=0L, n_fpi_tp[0] - 1L DO BEGIN
  test           = (fpi_types[j] EQ '')
  IF (test[0]) THEN CONTINUE
  ;;  Load Fast data
  mms_load_fpi,TRANGE=tran,PROBES=sc,LEVEL='l2',DATATYPE=fpi_types[j],DATA_RATE='fast',$
               /GET_SUPPORT_DATA,/LATEST_VERSION,SPDF=spdf,/TIME_CLIP
  ;;  Load Burst data
  mms_load_fpi,TRANGE=tran,PROBES=sc,LEVEL='l2',DATATYPE=fpi_types[j],DATA_RATE='brst',$
               /GET_SUPPORT_DATA,/LATEST_VERSION,SPDF=spdf,/TIME_CLIP
ENDFOR
;;  Currently all TPLOT handles with '*_gse_*' in their name have no data
;;    --> remove and rotate by hand after all sets are loaded
bad_tpni = tnames(scpref[0]+'dis_*'+coord_gse[0]+'*')
bad_tpne = tnames(scpref[0]+'des_*'+coord_gse[0]+'*')
bad_tpns = tnames([bad_tpni,bad_tpne])
IF (bad_tpns[0] NE '') THEN store_data,DELETE=bad_tpns
;;  Check RM_FPI_POLAR
test           = KEYWORD_SET(rm_fpi_polar)
IF (test[0]) THEN BEGIN
  bad_tpni = tnames(scpref[0]+'dis_*'+fpi_polart+'_*')
  bad_tpne = tnames(scpref[0]+'des_*'+fpi_polart+'_*')
  bad_tpns = tnames([bad_tpni,bad_tpne])
  IF (bad_tpns[0] NE '') THEN store_data,DELETE=bad_tpns
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check RM_FPI_SPRT
;;----------------------------------------------------------------------------------------
test           = KEYWORD_SET(rm_fpi_sprt)
IF (test[0]) THEN BEGIN
  bad_tpni = tnames(scpref[0]+'dis_*'+fpi_supprt+'_*')
  bad_tpne = tnames(scpref[0]+'des_*'+fpi_supprt+'_*')
  bad_tpns = tnames([bad_tpni,bad_tpne])
  IF (bad_tpns[0] NE '') THEN store_data,DELETE=bad_tpns
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Rotate Vbulk and Bo
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define Bo TPLOT handles
fgm_s__gse_tpn = tnames(scpref[0]+'fgm_'+ssfb_str[0]+'_l2_'+coord_gse[0])     ;;  Survey
fgm_l__gse_tpn = tnames(scpref[0]+'fgm_'+ssfb_str[1]+'_l2_'+coord_gse[0])     ;;  Slow/Low
fgm_f__gse_tpn = tnames(scpref[0]+'fgm_'+ssfb_str[2]+'_l2_'+coord_gse[0])     ;;  Fast/High
fgm_b__gse_tpn = tnames(scpref[0]+'fgm_'+ssfb_str[3]+'_l2_'+coord_gse[0])     ;;  Burst
;;  Define Vbulk TPLOT handles
dis_f_dbcs_tpn = tnames(scpref[0]+'dis_bulkv_'+coord_dbcs[0]+'_'+ssfb_str[2])
dis_b_dbcs_tpn = tnames(scpref[0]+'dis_bulkv_'+coord_dbcs[0]+'_'+ssfb_str[3])
des_f_dbcs_tpn = tnames(scpref[0]+'des_bulkv_'+coord_dbcs[0]+'_'+ssfb_str[2])
des_b_dbcs_tpn = tnames(scpref[0]+'des_bulkv_'+coord_dbcs[0]+'_'+ssfb_str[3])
;;----------------------------------------------------------------------------------------
;;  Rotate Bo from GSE to DBCS
;;----------------------------------------------------------------------------------------
;;  Define input coordinate (GSE) and output coordinate (DBCS) basis
in__coord      = coord_gse[0]
out_coord      = coord_dbcs[0]
;;  Define input and output TPLOT handles
in__names      = [fgm_s__gse_tpn[0],fgm_l__gse_tpn[0],fgm_f__gse_tpn[0],fgm_b__gse_tpn[0]]
out_names      = scpref[0]+'fgm_'+ssfb_str+'_l2_'+out_coord[0]
FOR j=0L, N_ELEMENTS(in__names) - 1L DO BEGIN
  ;;  Make sure TPLOT handles are valid before moving forward
  IF (in__names[j] EQ '') THEN CONTINUE
  in__name       = in__names[j]
  out_name       = out_names[j]
  mms_qcotrans,in__name[0],out_name[0],IN_COORD=in__coord[0],OUT_COORD=out_coord[0]
  ;;  Check for TSHIFT tag
  get_data,in__name[0],DATA=temp__in
  get_data,out_name[0],DATA=temp_out,DLIMIT=dlim,LIMIT=lim
  IF (SIZE(temp__in,/TYPE) NE 8 OR SIZE(temp_out,/TYPE) NE 8) THEN CONTINUE
  unix           = t_get_struc_unix(temp__in,TSHFT_ON=tshft_on)
  IF (tshft_on[0]) THEN delt = temp__in.TSHIFT[0] ELSE delt = 0d0
  str_element,temp_out,     'X',unix - delt[0],/ADD_REPLACE
  str_element,temp_out,'TSHIFT',       delt[0],/ADD_REPLACE
  store_data,out_name[0],DATA=temp_out,DLIMIT=dlim,LIMIT=lim
  ;;  Clean up
  dumb           = TEMPORARY(temp__in)
  dumb           = TEMPORARY(temp_out)
  dumb           = TEMPORARY(unix)
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Rotate Bo from GSE to GSM
;;----------------------------------------------------------------------------------------
;;  Define input coordinate (GSE) and output coordinate (GSM) basis
in__coord      = coord_gse[0]
out_coord      = coord_gsm[0]
;;  Define input and output TPLOT handles
in__names      = [fgm_s__gse_tpn[0],fgm_l__gse_tpn[0],fgm_f__gse_tpn[0],fgm_b__gse_tpn[0]]
out_names      = scpref[0]+'fgm_'+ssfb_str+'_l2_'+out_coord[0]
FOR j=0L, N_ELEMENTS(in__names) - 1L DO BEGIN
  ;;  Make sure TPLOT handles are valid before moving forward
  IF (in__names[j] EQ '') THEN CONTINUE
  in__name       = in__names[j]
  out_name       = out_names[j]
  mms_qcotrans,in__name[0],out_name[0],IN_COORD=in__coord[0],OUT_COORD=out_coord[0]
  ;;  Check for TSHIFT tag
  get_data,in__name[0],DATA=temp__in
  get_data,out_name[0],DATA=temp_out,DLIMIT=dlim,LIMIT=lim
  IF (SIZE(temp__in,/TYPE) NE 8 OR SIZE(temp_out,/TYPE) NE 8) THEN CONTINUE
  unix           = t_get_struc_unix(temp__in,TSHFT_ON=tshft_on)
  IF (tshft_on[0]) THEN delt = temp__in.TSHIFT[0] ELSE delt = 0d0
  str_element,temp_out,     'X',unix - delt[0],/ADD_REPLACE
  str_element,temp_out,'TSHIFT',       delt[0],/ADD_REPLACE
  store_data,out_name[0],DATA=temp_out,DLIMIT=dlim,LIMIT=lim
  ;;  Clean up
  dumb           = TEMPORARY(temp__in)
  dumb           = TEMPORARY(temp_out)
  dumb           = TEMPORARY(unix)
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Rotate Vbulk from DBCS to GSE
;;----------------------------------------------------------------------------------------
;;  Define input coordinate (DBCS) and output coordinate (GSE) basis
in__coord      = coord_dbcs[0]
out_coord      = coord_gse[0]
;;  Define input and output TPLOT handles
in__names      = [dis_f_dbcs_tpn[0],dis_b_dbcs_tpn[0],des_f_dbcs_tpn[0],des_b_dbcs_tpn[0]]
out_name0      = scpref[0]+['dis_bulkv_','des_bulkv_']+out_coord[0]+'_'
out_names      = [out_name0[0]+ssfb_str[2:3],out_name0[1]+ssfb_str[2:3]]
FOR j=0L, N_ELEMENTS(in__names) - 1L DO BEGIN
  ;;  Make sure TPLOT handles are valid before moving forward
  IF (in__names[j] EQ '') THEN CONTINUE
  in__name       = in__names[j]
  out_name       = out_names[j]
  mms_qcotrans,in__name[0],out_name[0],IN_COORD=in__coord[0],OUT_COORD=out_coord[0]
  ;;  Check for TSHIFT tag
  get_data,in__name[0],DATA=temp__in
  get_data,out_name[0],DATA=temp_out,DLIMIT=dlim,LIMIT=lim
  IF (SIZE(temp__in,/TYPE) NE 8 OR SIZE(temp_out,/TYPE) NE 8) THEN CONTINUE
  unix           = t_get_struc_unix(temp__in,TSHFT_ON=tshft_on)
  IF (tshft_on[0]) THEN delt = temp__in.TSHIFT[0] ELSE delt = 0d0
  str_element,temp_out,     'X',unix - delt[0],/ADD_REPLACE
  str_element,temp_out,'TSHIFT',       delt[0],/ADD_REPLACE
  store_data,out_name[0],DATA=temp_out,DLIMIT=dlim,LIMIT=lim
  ;;  Clean up
  dumb           = TEMPORARY(temp__in)
  dumb           = TEMPORARY(temp_out)
  dumb           = TEMPORARY(unix)
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Rotate Vbulk from GSE to GSM
;;----------------------------------------------------------------------------------------
;;  Define input coordinate (GSE) and output coordinate (GSM) basis
in__coord      = coord_gse[0]
out_coord      = coord_gsm[0]
;;  Rotate Vbulk from GSE to GSM
in__names      = tnames(out_names)
out_name0      = scpref[0]+['dis_bulkv_','des_bulkv_']+out_coord[0]+'_'
out_names      = [out_name0[0]+ssfb_str[2:3],out_name0[1]+ssfb_str[2:3]]
FOR j=0L, N_ELEMENTS(in__names) - 1L DO BEGIN
  ;;  Make sure TPLOT handles are valid before moving forward
  IF (in__names[j] EQ '') THEN CONTINUE
  in__name       = in__names[j]
  out_name       = out_names[j]
  mms_qcotrans,in__name[0],out_name[0],IN_COORD=in__coord[0],OUT_COORD=out_coord[0]
  ;;  Check for TSHIFT tag
  get_data,in__name[0],DATA=temp__in
  get_data,out_name[0],DATA=temp_out,DLIMIT=dlim,LIMIT=lim
  IF (SIZE(temp__in,/TYPE) NE 8 OR SIZE(temp_out,/TYPE) NE 8) THEN CONTINUE
  unix           = t_get_struc_unix(temp__in,TSHFT_ON=tshft_on)
  IF (tshft_on[0]) THEN delt = temp__in.TSHIFT[0] ELSE delt = 0d0
  str_element,temp_out,     'X',unix - delt[0],/ADD_REPLACE
  str_element,temp_out,'TSHIFT',       delt[0],/ADD_REPLACE
  store_data,out_name[0],DATA=temp_out,DLIMIT=dlim,LIMIT=lim
  ;;  Clean up
  dumb           = TEMPORARY(temp__in)
  dumb           = TEMPORARY(temp_out)
  dumb           = TEMPORARY(unix)
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Use my color scheme for vectors
;;----------------------------------------------------------------------------------------
temp0          = scpref[0]+['dis_bulkv_','des_bulkv_']
temp_dbcs      = temp0+coord_dbcs[0]+'_'
temp__gse      = temp0+coord_gse[0]+'_'
temp__gsm      = temp0+coord_gsm[0]+'_'
vbulk_tpns     = [temp_dbcs[0]+ssfb_str[2:3],temp_dbcs[1]+ssfb_str[2:3],         $
                  temp__gse[0]+ssfb_str[2:3],temp__gse[1]+ssfb_str[2:3],         $
                  temp__gsm[0]+ssfb_str[2:3],temp__gsm[1]+ssfb_str[2:3]]
IF ((tnames(vbulk_tpns))[0] NE '') THEN BEGIN
  options,tnames(vbulk_tpns),'COLORS'
  options,tnames(vbulk_tpns),'COLORS',vec_col,/DEFAULT
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END




















