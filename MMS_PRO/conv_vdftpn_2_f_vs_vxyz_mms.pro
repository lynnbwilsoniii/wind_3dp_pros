;+
;*****************************************************************************************
;
;  FUNCTION :   conv_vdftpn_2_f_vs_vxyz_mms.pro
;  PURPOSE  :   This routine converts an input IDL structure containing the velocity
;                 distribution function, measured by the MMS FPI instrument, to a
;                 structure with the following tag values:
;                   UNIX    :  [K]-Element [double] array defining the midpoint Unix time
;                   VDF     :  [K,N]-Element [float/double] array defining the VDF in
;                                units of phase space density
;                                [i.e., # s^(+3) km^(-3) cm^(-3)]
;                   VELXYZ  :  [K,N,3]-Element [float/double] array defining the particle
;                                velocity 3-vectors for each element of the VDF
;                                [km/s]
;                 The routine is specific to the TPLOT structures from the SPEDAS
;                 libraries, thus should not be used for general purposes.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               test_tplot_handle.pro
;               is_a_number.pro
;               get_valid_trange.pro
;               tnames.pro
;               mms_get_fpi_dist.pro
;               add_velmagscpot_to_mms_dist.pro
;               delete_variable.pro
;               lbw_test_mms_fpi_vdf_structure.pro
;               lbw_mms_energy_angle_to_velocity_array.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries; and
;               2)  latest SPEDAS libraries
;
;  INPUT:
;               TPNAME     :  Scalar [string] TPLOT handle associated with an array
;                               of FPI particle distributions
;
;  EXAMPLES:    
;               [calling sequence]
;               struc = conv_vdftpn_2_f_vs_vxyz_mms(tpname [,TRANGE=trange]               $
;                                                   [,BTPNAME=btpname] [,VTPNAME=vtpname] $
;                                                   [,STPNAME=stpname] [,FPIVDF=dis_vdf])
;
;  KEYWORDS:    
;               ***  INPUTS  ***
;               TRANGE     :  [2]-Element [double] array specifying the Unix time
;                               range for which to limit the data in DATA
;                               [Default = prompted by get_valid_trange.pro]
;               BTPNAME    :  Scalar [string] TPLOT handle associated with the quasi-
;                               static magnetic field 3-vector in DBCS coordinates
;               VTPNAME    :  Scalar [string] TPLOT handle associated with the bulk
;                               flow velocity 3-vector in DBCS coordinates
;               STPNAME    :  Scalar [string] TPLOT handle associated with the
;                               spacecraft potential
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               FPIVDF     :  Set to a named variable to return the array of IDL
;                               structures associated with the TPNAME VDFs
;
;   CHANGED:  1)  Fixed an indexing bug
;                                                                   [08/06/2020   v1.0.1]
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
;   CREATED:  08/05/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/06/2020   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION conv_vdftpn_2_f_vs_vxyz_mms,tpname,TRANGE=trange,BTPNAME=btpname,VTPNAME=vtpname,$
                                            STPNAME=stpname,FPIVDF=dis_vdf

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
notstr_msg     = 'Must be an IDL structure...'
nottpn_msg     = 'TPNAME must be an existing TPLOT handle...'
notmms_msg     = 'TPNAME must be an existing TPLOT handle for an MMS data product...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (N_ELEMENTS(tpname) EQ 0) OR (SIZE(tpname,/TYPE) NE 7)
IF (test[0]) THEN RETURN,0b
;;  Check TPLOT handle
test           = test_tplot_handle(tpname,TPNMS=fpi_vdf_tpn,GIND=gind)
IF (~test[0]) THEN BEGIN
  MESSAGE,nottpn_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Make sure its from MMS
test           = (STRPOS(fpi_vdf_tpn[0],'mms') EQ 0)
IF (~test[0]) THEN BEGIN
  MESSAGE,notmms_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Determine probe
probe          = STRMID(fpi_vdf_tpn[0],3,1)
scpref         = 'mms'+probe[0]+'_'
;;  Determine if ions or electrons
species        = (['i','e'])[STRPOS(fpi_vdf_tpn[0],'_des_') GE 0]
;;  Determine FPI mode
mode           = (['fast','brst'])[STRPOS(fpi_vdf_tpn[0],'_brst') GE 0]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check TRANGE
test           = ((N_ELEMENTS(trange) EQ 2) AND is_a_number(trange,/NOMSSG))
IF (test[0]) THEN BEGIN
  time_ra        = get_valid_trange(TDATE=tdate,TRANGE=trange,PREC=5)
ENDIF
;;  Check [B,V,S]TPNAME
test           = test_tplot_handle(btpname,TPNMS=fgm_dbcs_tpn,GIND=gind)
IF (~test[0]) THEN BEGIN
  ;;  Try to find B-field TPLOT handle
  check          = tnames(scpref[0]+'fgm_*dbcs*')
  IF (check[0] EQ '') THEN STOP  ;;  No B-field TPLOT handle?
  IF (N_ELEMENTS(check) GT 1) THEN BEGIN
    CASE mode[0] OF
      'fast'  :  fgm_dbcs_tpn = check[(WHERE(STRPOS(check,'srvy') GE 0))[0]]
      'brst'  :  fgm_dbcs_tpn = check[(WHERE(STRPOS(check,'brst') GE 0))[0]]
    ENDCASE
  ENDIF ELSE fgm_dbcs_tpn = check[0]
ENDIF
test           = test_tplot_handle(vtpname,TPNMS=vel_dbcs_tpn,GIND=gind)
IF (~test[0]) THEN BEGIN
  ;;  Try to find bulk velocity TPLOT handle
  check          = tnames(scpref[0]+'des_bulkv_*dbcs*')
  IF (check[0] EQ '') THEN STOP  ;;  No B-field TPLOT handle?
  IF (N_ELEMENTS(check) GT 1) THEN BEGIN
    CASE mode[0] OF
      'fast'  :  vel_dbcs_tpn = check[(WHERE(STRPOS(check,'fast') GE 0))[0]]
      'brst'  :  vel_dbcs_tpn = check[(WHERE(STRPOS(check,'brst') GE 0))[0]]
    ENDCASE
  ENDIF ELSE vel_dbcs_tpn = check[0]
ENDIF
test           = test_tplot_handle(stpname,TPNMS=sc_poten_tpn,GIND=gind)
IF (~test[0]) THEN BEGIN
  ;;  Try to find spacecraft potential TPLOT handle
  check          = tnames(scpref[0]+'edp_scpot_fast*')
  IF (check[0] EQ '') THEN STOP  ;;  No B-field TPLOT handle?
  sc_poten_tpn   = check[0]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get FPI distributions
;;----------------------------------------------------------------------------------------
dat_iarr       = mms_get_fpi_dist(fpi_vdf_tpn[0],TRANGE=trange,/STRUCTURE,SPECIES=species[0],PROBE=probe[0])
dis_vdf        = add_velmagscpot_to_mms_dist(dat_iarr,fgm_dbcs_tpn[0],vel_dbcs_tpn[0],sc_poten_tpn[0])
;;  Clean up
delete_variable,dat_iarr
;;  Check format of DATA --> Make sure its an array of valid FPI structures
test           = lbw_test_mms_fpi_vdf_structure(dis_vdf,POST=post,/NOM)
IF (~test[0] OR post[0] NE 2) THEN BEGIN
  ;;  Manipulation failure --> exit without further computation
  MESSAGE,'Failed to manipulate structure into proper format...',/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define # of times, energies, and angles
nts_i          = N_ELEMENTS(REFORM(dis_vdf))                 ;;  # of times
nes_i          = N_ELEMENTS(REFORM(dis_vdf[0].DATA[*,0,0]))  ;;  # of energy bins
nph_i          = N_ELEMENTS(REFORM(dis_vdf[0].DATA[0,*,0]))  ;;  # of azimuthal bins
nth_i          = N_ELEMENTS(REFORM(dis_vdf[0].DATA[0,0,*]))  ;;  # of latitudinal/poloidal bins
kk_i           = nes_i[0]*nph_i[0]*nth_i[0]
;;----------------------------------------------------------------------------------------
;;  Remove data below SC Potential to prevent interpolation/smoothing later
;;----------------------------------------------------------------------------------------
IF (species[0] EQ 'e') THEN BEGIN
  ;;  Only do this for DES electrons
  sc_pot_all     = REPLICATE(0e0,nes_i[0],nph_i[0],nth_i[0],nts_i[0])
  FOR j=0L, nts_i[0] - 1L DO sc_pot_all[*,*,*,j] = dis_vdf[j].SC_POT[0]
  tempe          = dis_vdf.ENERGY
  tempd          = dis_vdf.DATA
  bad_sc         = WHERE(tempe LE 1.3e0*sc_pot_all,bd_sc)
  IF (bd_sc[0] GT 0) THEN tempd[bad_sc] = f
  dis_vdf.DATA   = tempd
  ;;  Clean up
  delete_variable,sc_pot_all,tempe,tempd
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define necessary arrays
;;----------------------------------------------------------------------------------------
dis_ts         = dis_vdf.TIME
dis_te         = dis_vdf.END_TIME
tran_dis       = [[dis_ts],[dis_te]]
dis_tm         = MEAN(tran_dis,/NAN,DIMENSION=2)
;;  Get 5D velocities [*** May alter structure on return ***]
vels_i_5d      = lbw_mms_energy_angle_to_velocity_array(dis_vdf)
;;  Reform arrays
;;                    0 1 2 3
;;    dat.DATA  -->  [E,A,P,N]
;;   data_e_4d  -->  [N,E,A,P]
;;  Want
;;      arrays  -->  [N,E,A,P]
data_i_4d      = TRANSPOSE(  dis_vdf.DATA,[3,0,1,2])*1d15    ;;  cm^(-3)  -->  km^(-3)
;;  Reform to 2D arrays
data_i_2d      = REFORM(data_i_4d,nts_i[0],kk_i[0])
vels_i_2d      = REFORM(vels_i_5d,nts_i[0],kk_i[0],3L)
;;  Clean up
delete_variable,vels_i_5d,data_i_4d
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
struct         = {UNIX:dis_tm,VDF:data_i_2d,VELXYZ:vels_i_2d}
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END

