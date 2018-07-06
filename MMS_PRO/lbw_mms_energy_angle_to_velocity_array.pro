;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_mms_energy_angle_to_velocity_array.pro
;  PURPOSE  :   This routine takes an array of velocity distribution functions (VDFs), in
;                 the form of IDL structures, and uses the energies, azimuthal, and
;                 poloidal angles to define equivalent 3-vector velocities [km/s].  The
;                 output will be an [D,E,P,T,3]-element array, where D = # of VDFs,
;                 E = # of energy bins, P = # of azimuthal angle bins, T = # of poloidal/
;                 latitudinal angle bins, and 3 = vector components.  The routine
;                 adjusts the energies by the spacecraft potential.  The output 3-vector
;                 velocities will be in the same basis as the input (theta,phi) angles.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               lbw_test_mms_fpi_vdf_structure.pro
;               delete_variable.pro
;               energy_to_vel.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries; and
;               2)  latest SPEDAS libraries
;
;  INPUT:
;               DAT_ARR  :  [N]-Element [structure] array of MMS velocity distributions
;                             from FPI DIS or DES
;
;  EXAMPLES:    
;               [calling sequence]
;               vel_5d = lbw_mms_energy_angle_to_velocity_array(dat_arr [,/RMLOW])
;
;  KEYWORDS:    
;               RMLOW    :  If set, the routine will remove/kill data that falls below
;                             the spacecraft potential in the DATA and ENERGY tags of
;                             the input structure array
;                             [Default = FALSE]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The data structures for the MMS FPI VDFs are originally loaded into
;                     TPLOT with the routine mms_load_fpi.pro and then modified with
;                     the routine mms_get_fpi_dist.pro.  The modifying routine is
;                     critical because the angles from the initial part are the
;                     instrument look directions but are converted to the particle
;                     trajectories by mms_get_fpi_dist.pro.  Then the user should have
;                     called add_velmagscpot_to_mms_dist.pro to add the VELOCITY, MAGF,
;                     and SC_POT tags the the VDFs.
;               2)  See also:  mms_get_fpi_dist.pro (SPEDAS), add_velmagscpot_to_mms_dist.pro,
;                              lbw_mms_energy_angle_to_velocity.pro
;               3)  ***  Be careful not to eat up too much of your RAM  ***
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/02/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/02/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_mms_energy_angle_to_velocity_array,dat_arr,RMLOW=rmlow

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
notstr_msg     = 'Must be an IDL structure...'
notvdf_msg     = 'Must be an ion velocity distribution IDL structure...'
badthm_msg     = 'For MMS FPI structures, they must be modified using add_velmagscpot_to_mms_dist.pro prior to calling this routine'
not3dp_msg     = 'Must be an ion velocity distribution IDL structure from MMS/FPI...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 1) THEN RETURN,0b
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
kk             = n_e[0]*nph[0]*nth[0]
charge_2d      = dat_arr.CHARGE[0] # REPLICATE(1,kk[0])  ;;  Sign of particle charge
sc_pot_2d      = dat_arr.SC_POT[0] # REPLICATE(1,kk[0])  ;;  Spacecraft potential [eV]
;;  Reform charge and spacecraft potential to match dimensions of other params below
charge_4d      = REFORM(charge_2d,ndat[0],n_e[0],nph[0],nth[0])
sc_pot_4d      = REFORM(sc_pot_2d,ndat[0],n_e[0],nph[0],nth[0])
ener___4d      = TRANSPOSE(dat_arr.ENERGY,[3,0,1,2])
data___4d      = TRANSPOSE(dat_arr.DATA,[3,0,1,2])
theta__4d      = TRANSPOSE(dat_arr.THETA,[3,0,1,2])
phi____4d      = TRANSPOSE(dat_arr.PHI,[3,0,1,2])
;;  Clean up
delete_variable,charge_2d,sc_pot_2d
;;  Offset energies by SC Potential
ener___4d     += (charge_4d*sc_pot_4d)
;;  Clean up
delete_variable,charge_4d,sc_pot_4d
;;  Check for "bad" or low energies
bad            = WHERE(ener___4d LE 0,bd)
IF (bd GT 0) THEN BEGIN
  ;;  Remove negative energies
  ener___4d[bad] = f
  IF KEYWORD_SET(rmlow) THEN BEGIN
    ;;  User wants to kill data in input structure as well
    data___4d[bad] = f
    dat_arr.DATA   = TRANSPOSE(data___4d,[1,2,3,0])
    dat_arr.ENERGY = TRANSPOSE(ener___4d,[1,2,3,0])
  ENDIF
ENDIF
;;  Clean up
delete_variable,data___4d
;;----------------------------------------------------------------------------------------
;;  Convert (Energy,Theta,Phi) --> (Vx,Vy,Vz)
;;----------------------------------------------------------------------------------------
;;  Convert energies [eV] to speeds [km/s]
speed__4d      = energy_to_vel(ener___4d,mass[0])   ;;  Speed [km/s] equivalents of energies [eV]
;;  Clean up
delete_variable,ener___4d
;;  Define sines and cosines of angles
coth           = COS(theta__4d*!DPI/18d1)
sith           = SIN(theta__4d*!DPI/18d1)
coph           = COS(phi____4d*!DPI/18d1)
siph           = SIN(phi____4d*!DPI/18d1)
;;  Clean up
delete_variable,theta__4d,phi____4d
;;  Define (Vx,Vy,Vz) [km/s]
velx___4d      = speed__4d*coth*coph
vely___4d      = speed__4d*coth*siph
velz___4d      = speed__4d*sith
;;  Clean up
delete_variable,coth,coph,siph,sith,speed__4d
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
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,vels___5d
END