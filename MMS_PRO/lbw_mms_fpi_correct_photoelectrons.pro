;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_mms_fpi_correct_photoelectrons.pro
;  PURPOSE  :   This routine acts like mms_fpi_correct_photoelectrons.pro but allows
;                 for the use of the TRANGE keyword to avoid absurd memory overflow
;                 issues.  That is, it returns an array of 3D VDF structures for the
;                 FPI DES instrument after having removed the photoelectrons.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_data.pro
;               dprint.pro
;               is_a_number.pro
;               minmax.pro
;               t_get_struc_unix.pro
;               mms_part_des_photoelectrons.pro
;               test_tplot_handle.pro
;               mms_load_edp.pro
;               mms_get_dist.pro
;               t_resample_tplot_struc.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries; and
;               2)  latest SPEDAS libraries
;
;  INPUT:
;               TPNAME     :  Scalar [string] TPLOT handle associated with an array
;                               of FPI DES particle distributions
;
;  EXAMPLES:    
;               [calling sequence]
;               dists = lbw_mms_fpi_correct_photoelectrons(tpname [,SCPOT=scpot]        $
;                                                      [,TRANGE=trange] [,_EXTRA=_extra])
;
;  KEYWORDS:    
;               SCPOT      :  Scalar [string] TPLOT handle associated with the
;                               spacecraft potential
;               TRANGE     :  [2]-Element [double] array specifying the Unix time
;                               range for which to limit the data in DATA
;                               [Default = range defined by all FPI DES VDFs]
;               _EXTRA     :  Keywords handled by mms_get_dist.pro
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Same as mms_fpi_correct_photoelectrons.pro but allows for TRANGE
;                     as a valid keyword to avoid overflow memory issues
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
;   ADAPTED FROM: mms_fpi_correct_photoelectrons.pro    BY: Eric Grimes
;   CREATED:  07/05/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/05/2021   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_mms_fpi_correct_photoelectrons,in_tvarname,SCPOT=scpot,TRANGE=trange,_EXTRA=_extra

;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
get_data,in_tvarname,DATA=indata
IF (SIZE(indata,/TYPE) NE 8) THEN BEGIN
  dprint,DLEVEL=0,'Error, '+in_tvarname[0]+' not found.'
  RETURN, -1
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check TRANGE
test           = ((N_ELEMENTS(trange) EQ 2) AND is_a_number(trange,/NOMSSG))
IF (~test[0]) THEN BEGIN
  ;;  Default to entire time range of all DES VDFs
  trange         = minmax(t_get_struc_unix(indata))
ENDIF
;;----------------------------------------------------------------------------------------
;;  Launch/Load necessary photoelectron data
;;----------------------------------------------------------------------------------------
fpi_photoe     = mms_part_des_photoelectrons(in_tvarname[0])
IF ((SIZE(fpi_photoe,/TYPE) NE 8) && (fpi_photoe EQ -1)) THEN BEGIN              ;;  && instead of AND --> checks first only if that one fails
  dprint,DLEVEL=0,'Photoelectron model missing for this date; re-run without photoelectron corrections'
  RETURN, -1
ENDIF
var_info       = STREGEX(in_tvarname[0],'mms([1-4])_d([ei])s_dist(err)?_(brst|fast|slow).*',/SUBEXPR,/EXTRACT)
;;  Infer info from TPLOT handle
IF (var_info[0] NE '') THEN BEGIN
  probe          = var_info[1]
  species        = var_info[2]
  data_rate      = var_info[4]
ENDIF
test           = test_tplot_handle(scpot,TPNMS=sc_pot,GIND=gind)
IF (~test[0]) THEN BEGIN
  mms_load_edp,TRANGE=minmax(indata.X),PROBE=probe,DATA_RATE=data_rate,DATATYPE='scpot',/TIME_CLIP
  sc_pot         = 'mms'+probe[0]+'_edp_scpot_'+data_rate[0]+'_l2'
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get SC Potential [eV]
;;----------------------------------------------------------------------------------------
get_data,sc_pot[0],DATA=scpotdata
;;  Determine data necessary depending on data rate
IF (data_rate[0] EQ 'brst') THEN BEGIN
  scprefix       = (STRSPLIT(in_tvarname,'_',/EXTRACT))[0]
  get_data,scprefix[0]+'_des_steptable_parity_brst',DATA=parity
  ; the following is so that we can use scope_varfetch using the parity_num found in the loop over times
  ; (scope_varfetch doesn't work with structure.structure syntax)
  bg_dist_p0     = fpi_photoe.BGDIST_P0
  bg_dist_p1     = fpi_photoe.BGDIST_P1
  n_0            = fpi_photoe.N_0
  n_1            = fpi_photoe.N_1
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get VDFs
;;----------------------------------------------------------------------------------------
dists          = mms_get_dist(in_tvarname,/STRUCTURE,PROBE=probe,SPECIES=species, $
                              INSTRUMENT='fpi',TRANGE=trange,_EXTRA=_extra)
;;  Get longitude table info
get_data,'mms'+probe[0]+'_des_startdelphi_count_'+data_rate[0],DATA=startdelphi
;;----------------------------------------------------------------------------------------
;;  Interpolate to VDF midtimes
;;----------------------------------------------------------------------------------------
vdf_mtime      = (dists.TIME + dists.END_TIME)/2d0
scpot_dat      = t_resample_tplot_struc(scpotdata,vdf_mtime,/NO_EXTRAPOLATE,/IGNORE_INT)
IF (data_rate[0] EQ 'brst') THEN BEGIN
  parunix        = t_get_struc_unix(parity)
  ind_parity     = VALUE_LOCATE(parunix,dists.TIME)
  IF (ind_parity[0] LT 0) THEN STOP                ;;  Something is wrong
ENDIF
stdunix        = t_get_struc_unix(startdelphi)
ind_stdelphi   = VALUE_LOCATE(stdunix,dists.TIME)
IF (ind_stdelphi[0] LT 0) THEN STOP                ;;  Something is wrong
;;  Define relevant parameters
sc_pot_data    = scpot_dat.Y
;;----------------------------------------------------------------------------------------
;;  Correct distributions
;;----------------------------------------------------------------------------------------
FOR i=0L, N_ELEMENTS(dists) - 1L DO BEGIN
  ;;  From Dan Gershman's release notes on the FPI photoelectron model:
  ;;    Find the index I in the startdelphi_counts_brst or startdelphi_counts_fast array
  ;;    [360 possibilities] whose corresponding value is closest to the measured
  ;;    startdelphi_count_brst or startdelphi_count_fast for the skymap of interest. The
  ;;    closest index can be approximated by I = floor(startdelphi_count_brst/16) or I =
  ;;    floor(startdelphi_count_fast/16)
  jj             = ind_stdelphi[i]
  start_delphi_I = FLOOR(startdelphi.Y[jj]/16.)
  IF (data_rate[0] EQ 'brst') THEN BEGIN
    ;;  Burst mode
    kk             = ind_parity[i]
    parity_num     = STRCOMPRESS(STRING(FIX(parity.Y[kk])),/REMOVE_ALL)
    bg_dist        = SCOPE_VARFETCH('bg_dist_p'+parity_num[0])
    n_value        = SCOPE_VARFETCH('n_'+parity_num[0])
    ;;  Define model photoelectron flux
    fphoto         = bg_dist.Y[start_delphi_I[0], *, *, *]
    ;;  Interpolate using the measured SC potential to get Nphoto
    nphoto_scdep   = REFORM(n_value.Y[start_delphi_I[0],*])
    nphoto         = INTERPOL(nphoto_scdep,n_value.V,sc_pot_data[i])
  ENDIF ELSE BEGIN
    ;;  Fast survey mode
    fphoto         = fpi_photoe.BG_DIST.Y[start_delphi_I[0], *, *, *]
    ;;  Interpolate using the measured SC potential to get Nphoto
    nphoto_scdep   = REFORM(fpi_photoe.N.Y[start_delphi_I[0],*])
    nphoto         = INTERPOL(nphoto_scdep,fpi_photoe.N.V,sc_pot_data[i])
  ENDELSE
  ;;  Remove photoelectrons:  f_corrected = f - fphoto*nphoto
  ;;    Note:  transpose is to shuffle fphoto*nphoto to energy-azimuth-elevation, to match dist.DATA
  dists[i].DATA -= TRANSPOSE(REFORM(fphoto*nphoto),[2,0,1])
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,dists
END











