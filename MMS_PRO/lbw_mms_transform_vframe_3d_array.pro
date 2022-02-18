;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_mms_transform_vframe_3d_array.pro
;  PURPOSE  :   This routine transforms an array of MMS FPI velocity distribution
;                 functions (VDFs), input as IDL structures, into a user-defined
;                 reference frame.
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
;               delete_variable.pro
;               energy_to_vel.pro
;               my_dot_prod.pro
;               mag__vec.pro
;               relativistic_gamma.pro
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
;               data   = lbw_mms_transform_vframe_3d_array(dat ,vtrans)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See also:
;                     transform_vframe_3d.pro
;                     transform_vframe_3d_array.pro
;                     rel_lorentz_trans_3vec.pro
;                     relativistic_gamma.pro
;                     energy_to_vel.pro
;                     energy_angle_to_velocity.pro
;                     lbw_mms_energy_angle_to_velocity_array.pro
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
;               9)  Ipavich, F.M. "The Compton-Getting effect for low energy particles,"
;                      Geophys. Res. Lett. 1(4), pp. 149-152, (1974).
;              10)  Jackson, J.D. "Classical Electrodynamics," 3rd Edition,
;                     ISBN 0-471-30932-X. John Wiley & Sons, Inc., (1999)
;                     [e.g., see Chapter 11]
;
;   CREATED:  06/29/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/29/2021   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_mms_transform_vframe_3d_array,dat_arr,vtrans

;;****************************************************************************************
ex_start       = SYSTIME(1)
;;****************************************************************************************
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
ckm            = c[0]                     ;;  Speed of light in vacuum [km/s]
ckm           *= 1d-3                     ;;  m --> km
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
;;  Define DAT structure parameters
;;----------------------------------------------------------------------------------------
mass           = dat[0].MASS[0]                          ;;  particle mass [eV km^(-2) s^(2)]
ndat           = N_ELEMENTS(dat_arr)                     ;;  # of VDFs
n_e            = dat[0].NENERGY                          ;;  # of energy bins
nph            = N_ELEMENTS(REFORM(dat[0].DATA[0,*,0]))  ;;  # of azimuthal bins
nth            = N_ELEMENTS(REFORM(dat[0].DATA[0,0,*]))  ;;  # of latitudinal/poloidal bins
n_a            = nph[0]*nth[0]
;;  Check consistency in sizes
test           = (TOTAL(dat_arr.NENERGY[0] EQ n_e[0]) NE ndat[0]) OR $
                 (TOTAL(dat_arr.NBINS[0] EQ n_a[0]) NE ndat[0])
IF (test[0]) THEN BEGIN
  ;;  Should not occur, but just in case...
  MESSAGE,"FPI structures must have constant sizes/dimensions...",/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define types to avoid "Conflicting data structures" error
szt_dtpe       = [SIZE(dat_arr.DATA,/TYPE),SIZE(dat_arr.THETA,/TYPE),SIZE(dat_arr.PHI,/TYPE),$
                  SIZE(dat_arr.ENERGY,/TYPE)]
;;  Define the particle charge [N/A] and spacecraft potential [eV]
kk             = n_e[0]*nph[0]*nth[0]
charge_2d      = dat_arr.CHARGE[0] # REPLICATE(1,kk[0])  ;;  Sign of particle charge
sc_pot_2d      = dat_arr.SC_POT[0] # REPLICATE(1,kk[0])  ;;  Spacecraft potential [eV]
;;  Reform charge and spacecraft potential to match dimensions of other params below
charge_4d      = REFORM(charge_2d,ndat[0],n_e[0],nph[0],nth[0])
sc_pot_4d      = REFORM(sc_pot_2d,ndat[0],n_e[0],nph[0],nth[0])
ener___4d      = TRANSPOSE(dat_arr.ENERGY,[3,0,1,2])     ;;  To undo --> ener_old = TRANSPOSE(ener___4d,[1,2,3,0])
;;data___4d      = TRANSPOSE(dat_arr.DATA,[3,0,1,2])
theta__4d      = TRANSPOSE(dat_arr.THETA,[3,0,1,2])
phi____4d      = TRANSPOSE(dat_arr.PHI,[3,0,1,2])
;;  Clean up
delete_variable,charge_2d,sc_pot_2d
;;  Add sign to SC potential for offset
sc_pot_4d     *= charge_4d                      ;;  ø < 0 (electrons), ø > 0 (ions)
;;  Offset energies by SC Potential
ener___4d     += sc_pot_4d
;;  Clean up
delete_variable,charge_4d,sc_pot_4d
;;  Check for "bad" or low energies
;;    --> Note:  This all assumes the user got DAT from conv_vdftpn_2_f_vs_vxyz_mms.pro
;;                 which already kills data below ~130% of the spacecraft potential to
;;                 avoid interpolation etc.  Thus, it is not necessary to redo this step.
bad            = WHERE(ener___4d LE 0,bd)
IF (bd GT 0) THEN BEGIN
  ;;  Remove negative energies
  ener___4d[bad] = f
ENDIF
;;----------------------------------------------------------------------------------------
;;  Convert (Energy,Theta,Phi) --> (Vx,Vy,Vz)
;;----------------------------------------------------------------------------------------
;;  Convert energies [eV] to speeds [km/s]
speed__4d      = energy_to_vel(ener___4d,mass[0])   ;;  Speed [km/s] equivalents of energies [eV]
;;  Define sines and cosines of angles
coth           = COS(theta__4d*!DPI/18d1)
sith           = SIN(theta__4d*!DPI/18d1)
coph           = COS(phi____4d*!DPI/18d1)
siph           = SIN(phi____4d*!DPI/18d1)
;;  Define (Vx,Vy,Vz) [km/s]
velx___4d      = speed__4d*coth*coph
vely___4d      = speed__4d*coth*siph
velz___4d      = speed__4d*sith
;;  Clean up
delete_variable,coth,coph,siph,sith,ener___4d,phi____4d,theta__4d
;;  Define single, 3-vector array
vels___5d      = DBLARR(ndat[0],n_e[0],nph[0],nth[0],3L)
FOR k=0L, 2L DO BEGIN
  CASE k[0] OF
    0L    :  vv = velx___4d
    1L    :  vv = vely___4d
    2L    :  vv = velz___4d
    ELSE  :  STOP   ;;  should not happen --> debug
  ENDCASE
  vels___5d[*,*,*,*,k] = vv
ENDFOR
;;  Define 5D transformation velocities
vtrans_5d      = REPLICATE(1d0,ndat[0],n_e[0],nph[0],nth[0],3L)
FOR j=0L, ndat[0] - 1L DO FOR k=0L, 2L DO vtrans_5d[j,*,*,*,k] = vtran2d[j,k]
;;  Reform arrays to 1D for operations
vtran1d        = REFORM(vtrans_5d,ndat[0]*kk[0],3L)
vels_1d        = REFORM(vels___5d,ndat[0]*kk[0],3L)    ;;  [M,3]-Element array
;;speed1d        = REFORM(speed__4d,ndat[0]*kk[0])       ;;  [M]-Element array
;;  Compute dot-products and magnitudes
u_d_v          = my_dot_prod(vels_1d,vtran1d,/NOM)            ;;  V_3d . VTRANS  ([M]-Element array)
v_mag          = mag__vec(vtran1d,/NAN,/TWO)                  ;;  |VTRANS|       ([M,3]-Element array)
;;  Clean up
delete_variable,vtrans_5d,vels___5d,speed__4d,velx___4d,vely___4d,velz___4d,vv
;;----------------------------------------------------------------------------------------
;;  Define parallel/perpendicular components of V_3d relative to VTRANS
;;
;;              (U . V)
;;    U_//  =  --------- V
;;              |V . V|
;;
;;    U_|_  = U - U_//
;;
;;----------------------------------------------------------------------------------------
u_d_v_2d       = REPLICATE(d,ndat[0]*kk[0],3L)  ;;  [M,3]-Element array
FOR k=0L, 2L DO u_d_v_2d[*,k] = u_d_v
u_para         = (u_d_v_2d/v_mag^2)*vtran1d     ;;  = U_//
u_perp         = vels_1d - u_para               ;;  = U_|_
;;  Clean up
delete_variable,u_d_v,vels_1d
;;----------------------------------------------------------------------------------------
;;  Define relativistic Lorentz factor
;;
;;                            -1/2
;;          [       |V . V| ]
;;    ¥  =  [ 1  -  ------- ]
;;          [         c^2   ]
;;
;;
;;----------------------------------------------------------------------------------------
rl_gamma       = relativistic_gamma(v_mag,/SPEED)  ;;  [M,3]-Element array
;;----------------------------------------------------------------------------------------
;;  Compute velocity addition from K-frame to K'-frame
;;
;;                 U_//  - V
;;    U'_//  =  ---------------
;;                     |U . V|
;;               1  -  -------
;;                       c^2  
;;
;;                      U_|_
;;    U'_|_  =  -------------------
;;                 [      |U . V|]
;;               ¥ [1  -  -------]
;;                 [        c^2  ]
;;
;;----------------------------------------------------------------------------------------
denom_fac      = 1d0 - (u_d_v_2d/ckm[0]^2)
u_para_p       = (u_para - vtran1d)/denom_fac                  ;;  =  U'_//
u_perp_p       = u_perp/(rl_gamma*denom_fac)                   ;;  =  U'_|_
;;  Define Lorentz transformed output velocity
u_rl_trans     = u_para_p + u_perp_p                           ;;  [M,3]-Element array
u_rl_tranmg    = mag__vec(u_rl_trans,/NAN)                     ;;  [M]-Element array
;;  Clean up
delete_variable,u_para_p,u_perp_p,denom_fac,rl_gamma,u_para,u_perp
delete_variable,v_mag,u_d_v_2d,vtran1d
;;----------------------------------------------------------------------------------------
;;  Reform arrays
;;----------------------------------------------------------------------------------------
vel_kprime5d   = REFORM(u_rl_trans ,ndat[0],n_e[0],nph[0],nth[0],3L)   ;;  [N,E,P,T,3]-Element array
vmg_kprime4d   = REFORM(u_rl_tranmg,ndat[0],n_e[0],nph[0],nth[0])      ;;  [N,E,P,T]-Element array
;;  Clean up
delete_variable,u_rl_trans,u_rl_tranmg
;;----------------------------------------------------------------------------------------
;;  Define new angles [deg]
;;    Poloidal   -->   -90 < theta <  +90
;;    Azimuthal  -->  -180 <  phi  < +180
;;----------------------------------------------------------------------------------------
;;  Both are [N,E,P,T]-Element arrays
n_the_4d       = ASIN(vel_kprime5d[*,*,*,*,2]/vmg_kprime4d)*18d1/!DPI
n_phi_4d       = ATAN(vel_kprime5d[*,*,*,*,1],vel_kprime5d[*,*,*,*,0])*18d1/!DPI
;;  Shift azimuthal angles to {   0 < phi < +360 }
n_phi_4d       = (n_phi_4d + 36d1) MOD 36d1
;;----------------------------------------------------------------------------------------
;;  Define new energies [eV]
;;----------------------------------------------------------------------------------------
eners__0       = energy_to_vel(vmg_kprime4d,mass[0],/INVERSE)      ;;  [N,E,P,T]-Element array [eV]
IF (szt_dtpe[1] EQ 4) THEN the_4d  = FLOAT(n_the_4d)  ELSE the_4d  = DOUBLE(n_the_4d)
IF (szt_dtpe[2] EQ 4) THEN phi_4d  = FLOAT(n_phi_4d)  ELSE phi_4d  = DOUBLE(n_phi_4d)
IF (szt_dtpe[3] EQ 4) THEN ener_4d = FLOAT(eners__0)  ELSE ener_4d = DOUBLE(eners__0)
;;  Clean up
delete_variable,eners__0,n_the_4d,n_phi_4d,vmg_kprime4d,vel_kprime5d
;;----------------------------------------------------------------------------------------
;;  Redefine structure tag values
;;----------------------------------------------------------------------------------------
dat_out        = dat_arr
dat_out.ENERGY = TRANSPOSE(ener_4d,[1,2,3,0])
dat_out.THETA  = TRANSPOSE(the_4d ,[1,2,3,0])
dat_out.PHI    = TRANSPOSE(phi_4d ,[1,2,3,0])
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;****************************************************************************************
ex_time        = SYSTIME(1) - ex_start[0]
MESSAGE,STRING(ex_time[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;;****************************************************************************************

RETURN,dat_out
END





















