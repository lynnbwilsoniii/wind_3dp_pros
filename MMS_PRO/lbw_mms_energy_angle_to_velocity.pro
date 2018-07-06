;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_mms_energy_angle_to_velocity.pro
;  PURPOSE  :   This routine takes a velocity distribution function, in the form of an
;                 IDL structure, and uses the energies, azimuthal, and poloidal angles
;                 to define a 3D velocity vector [km/s] on output.  The output will be
;                 an [E,P,T,3]-element array, where E = # of energy bins, P = # of
;                 azimuthal angle bins, T = # of poloidal/latitudinal angle bins, and
;                 3 = vector components.  The routine accounts for
;                 spacecraft potential and any energy shifts defined within the IDL
;                 structure.  The output velocity vectors will be in the same basis as
;                 the {THETA,PHI}-angles (or {poloidal,azimuthal}-angles) in DATA.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               struct_value.pro
;               energy_to_vel.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries; and
;               2)  latest SPEDAS libraries
;
;  INPUT:
;               DATA     :  Scalar [structure] containing an MMS velocity distribution
;                             from FPI DIS or DES that has had the SC_POT tag added
;
;  EXAMPLES:    
;               [calling sequence]
;               vel_4d = lbw_mms_energy_angle_to_velocity(data)
;
;  KEYWORDS:    
;               NA
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
;               2)  See also:  mms_get_fpi_dist.pro (SPEDAS) and add_velmagscpot_to_mms_dist.pro
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

FUNCTION lbw_mms_energy_angle_to_velocity,data

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
str            = data[0]   ;;  in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,notstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
dat            = str[0]
charge         = struct_value(dat[0],'charge',INDEX=ind_c)
sc_pot         = struct_value(dat[0],'sc_pot',INDEX=ind_s)
IF (ind_c[0] LT 0 OR ind_s[0] LT 0) THEN BEGIN
  MESSAGE,badthm_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
eoffset        = charge[0]*sc_pot[0]          ;;  Energy offset [eV] to remove for DATA energies
;;----------------------------------------------------------------------------------------
;;  Define DAT structure parameters
;;----------------------------------------------------------------------------------------
mass           = dat[0].MASS[0]                          ;;  particle mass [eV km^(-2) s^(2)]
n_e            = dat[0].NENERGY                          ;;  # of energy bins
nph            = N_ELEMENTS(REFORM(dat[0].DATA[0,*,0]))  ;;  # of azimuthal bins
nth            = N_ELEMENTS(REFORM(dat[0].DATA[0,0,*]))  ;;  # of latitudinal/poloidal bins
n_a            = nph[0]*nth[0]                           ;;  # of solid angle bins
energy         = dat[0].ENERGY                           ;;  [E,T,P]-Element [numeric] array of energy bin values [eV]
phi            = dat[0].PHI                              ;;  Azimuthal angle [deg]
the            = dat[0].THETA                            ;;  Poloidal angle [deg]
;;   Shift energies by SC-Potential
;;    -> Electrons gain energy => +(-e) ø = -e ø
;;    -> Ions lose energy      => +(+q) ø = +Z e ø
energy        += eoffset[0]
;;  Convert energies to speeds [km/s]
speed          = energy_to_vel(energy,mass[0])
;;  Define unit vector directions
coth           = COS(the*!DPI/18d1)
sith           = SIN(the*!DPI/18d1)
coph           = COS(phi*!DPI/18d1)
siph           = SIN(phi*!DPI/18d1)
udir_str       = {X:coth*coph,Y:coth*siph,Z:sith}
;;----------------------------------------------------------------------------------------
;;  Convert energy/angles to 3D velocity vectors
;;----------------------------------------------------------------------------------------
velocities     = DBLARR(n_e[0],nph[0],nth[0],3L)         ;;  [E,T,P,3]-Element [numeric] array of 3-vector velocities [km/s]
FOR k=0L, 2L DO velocities[*,*,*,k] = speed*udir_str.(k)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,velocities
END

