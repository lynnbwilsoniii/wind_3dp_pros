;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_mms_create_mask_2_remove_beams.pro
;  PURPOSE  :   This routine attempts to create a mask to remove "contamination" due
;                 to secondary beams (i.e., not the main core) measured by the MMS FPI
;                 DES and/or DIS instruments.  The routine does so through the
;                 following steps:
;                   1)  Transform into bulk flow (SW) rest frame
;                   2)  Create mask for data to remove values > V_thresh, where
;                         V_thresh can come from, e.g., the specular reflection ion
;                         gyrospeed estimate
;                   4)  Find remaining finite data bins to create a new mask
;                   5)  Return new mask to user
;                   6)  User can use new mask to keep only the desired bins when
;                         calculating new ion moments that are not contaminated by
;                         ion beams [e.g. gyrating ions] or UV-light-driven effects
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               lbw_test_mms_fpi_vdf_structure.pro
;               is_a_3_vector.pro
;               is_a_number.pro
;               lbw_mms_transform_vframe_3d_array.pro
;               energy_to_vel.pro
;               delete_variable.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  Scalar (or array) [structure] associated with a known
;                               MMS FPI DES or DIS data structure(s)
;               VTRANS     :  [N,3]-Element [numeric] array of transformation velocities
;                               [km/s] as an array of 3-vectors, where
;                               N = N_ELEMENTS(DAT)
;
;  EXAMPLES:    
;               [calling sequence]
;               mask_str = lbw_mms_create_mask_2_remove_beams(dat ,vtrans [,V_THRESH=v_thresh])
;
;  KEYWORDS:    
;               V_THRESH  :  Scalar [numeric] defining the largest speed [km/s] to use
;                              to isolate the "core" of the distribution in the bulk
;                              flow rest frame
;                              [Default = 500 km/s]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See also:
;                     lbw_mms_transform_vframe_3d_array.pro
;                     transform_vframe_3d_array.pro
;                     remove_uv_and_beam_ions.pro
;
;  REFERENCES:  
;               0)  Links:
;                      MMS Quick Look Plots:
;                        https://lasp.colorado.edu/mms/sdc/public/quicklook/
;                      SCM Quick Look Plots:
;                        http://mms.lpp.upmc.fr/?page=quicklook
;               1)  Pollock, C., T. Moore, A. Jacques, J. Burch, U. Gliese, Y. Saito,
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
;               2)  Ipavich, F.M. "The Compton-Getting effect for low energy particles,"
;                      Geophys. Res. Lett. 1(4), pp. 149-152, (1974).
;               3)  Jackson, J.D. "Classical Electrodynamics," 3rd Edition,
;                     ISBN 0-471-30932-X. John Wiley & Sons, Inc., (1999)
;                     [e.g., see Chapter 11]
;               4)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 1. Analysis Techniques and Methodology,"
;                      J. Geophys. Res. 119(8), pp. 6455--6474, 2014a.
;               5)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 2. Waves and Dissipation,"
;                      J. Geophys. Res. 119(8), pp. 6475--6495, 2014b.
;
;   CREATED:  06/29/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/29/2021   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_mms_create_mask_2_remove_beams,dat_arr,vtrans,V_THRESH=v_thresh

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
notstr_msg     = 'Must be an IDL structure...'
notvdf_msg     = 'Must be an ion velocity distribution IDL structure...'
badvfor_msg    = 'Incorrect input format:  VTRANS must be a [N,3]-element [numeric] arrays of 3-vectors'
badthm_msg     = 'For MMS FPI structures, they must be modified using add_velmagscpot_to_mms_dist.pro prior to calling this routine'
not3dp_msg     = 'Must be an ion velocity distribution IDL structure from MMS/FPI...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN RETURN,0b
str            = dat_arr[0]   ;;  in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,notstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
dat            = str[0]
test           = lbw_test_mms_fpi_vdf_structure(dat[0],/NOMSSG,POST=post)
IF (~test[0] OR post[0] LT 2) THEN BEGIN
  MESSAGE,badthm_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check VTRANS format
IF (is_a_3_vector(vtrans,V_OUT=vtran2d,/NOMSSG) EQ 0) THEN BEGIN
  MESSAGE,badvfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check V_THRESH
IF (is_a_number(v_thresh,/NOMSSG) EQ 0) THEN vthresh = 50d1 ELSE vthresh = ABS(v_thresh[0])
;;----------------------------------------------------------------------------------------
;;  Transform into bulk flow rest frame
;;----------------------------------------------------------------------------------------
;;  Lorentz transform the data into the bulk flow rest frame
ndat           = N_ELEMENTS(dat_arr)                     ;;  # of VDFs
dumb_i         = lbw_mms_transform_vframe_3d_array(dat_arr,vtran2d)
IF (SIZE(dumb_i,/TYPE) NE 8 AND N_ELEMENTS(dumb_i) NE ndat[0]) THEN RETURN,0b
;;----------------------------------------------------------------------------------------
;;  Define DAT structure parameters
;;----------------------------------------------------------------------------------------
mass           = dat[0].MASS[0]                          ;;  particle mass [eV km^(-2) s^(2)]
n_e            = dat[0].NENERGY                          ;;  # of energy bins
nph            = N_ELEMENTS(REFORM(dat[0].DATA[0,*,0]))  ;;  # of azimuthal bins
nth            = N_ELEMENTS(REFORM(dat[0].DATA[0,0,*]))  ;;  # of latitudinal/poloidal bins
;;  Define [N,E,P,T]-Element arrays
ener___4d      = TRANSPOSE(dumb_i.ENERGY,[3,0,1,2])      ;;  To undo --> ener_old = TRANSPOSE(ener___4d,[1,2,3,0])
;;  Convert energies [eV] to speeds [km/s]
speed__4d      = energy_to_vel(ener___4d,mass[0])   ;;  Speed [km/s] equivalents of energies [eV]
;;----------------------------------------------------------------------------------------
;;  Define |V| test(s)
;;----------------------------------------------------------------------------------------
test_f_v       = FINITE(speed__4d)
test_vth       = (speed__4d LE vthresh[0]) AND test_f_v
test_vou       = (speed__4d GT vthresh[0]) AND test_f_v
;;  Clean up
delete_variable,dumb_i,speed__4d,ener___4d
;;----------------------------------------------------------------------------------------
;;  Define masks
;;----------------------------------------------------------------------------------------
mask_s         = REPLICATE(0d0,ndat[0],n_e[0],nph[0],nth[0])      ;;  Elements of array to kill
mask_k         = mask_s                                           ;;  " " to save
dumb_s         = REFORM(mask_s[0L,*,*,*])
dumb_k         = dumb_s
FOR j=0L, ndat[0] - 1L DO BEGIN
  test           = test_vth[j,*,*,*]
  good           = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
  IF (gd[0] GT 0) THEN dumb_s[good] = 1d0
  test           = test_vou[j,*,*,*]
  good           = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
  IF (gd[0] GT 0) THEN dumb_k[good] = 1d0
  ;;  Define mask outputs
  mask_s[j,*,*,*] = dumb_s
  mask_k[j,*,*,*] = dumb_k
  ;;  Reset variables
  good            = 0L & bad = 0L & test = 0b
  dumb_s[*]       = 0d0
  dumb_k[*]       = 0d0
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Reform to 2D Arrays
;;----------------------------------------------------------------------------------------
mask_s2d       = REFORM(mask_s,ndat[0],n_e[0]*nph[0]*nth[0])
mask_k2d       = REFORM(mask_k,ndat[0],n_e[0]*nph[0]*nth[0])
;mask_s2d       = mask_s
;mask_k2d       = mask_k
;mask_k2d_1     = 1d0 - mask_s
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
tags           = 'MASK_'+['SAVE','KILL']
struc          = CREATE_STRUCT(tags,mask_s2d,mask_k2d)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END
