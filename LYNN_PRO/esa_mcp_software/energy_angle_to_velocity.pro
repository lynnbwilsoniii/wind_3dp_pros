;+
;*****************************************************************************************
;
;  FUNCTION :   energy_angle_to_velocity.pro
;  PURPOSE  :   This routine takes a velocity distribution function, in the form of an
;                 IDL structure, and uses the energies, azimuthal, and poloidal angles
;                 to define a 3D velocity vector [km/s] on output.  The output will be
;                 an [E,A,3]-element array, where E = # of energy bins, A = # of solid
;                 angle bins, and 3 = vector components.  The routine accounts for
;                 spacecraft potential and any energy shifts defined within the IDL
;                 structure.  The output velocity vectors will be in the same basis as
;                 the {THETA,PHI}-angles (or {poloidal,azimuthal}-angles) in DATA.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               define_particle_charge.pro
;               str_element.pro
;               energy_to_vel.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA       :  Scalar [structure] associated with a known THEMIS ESA
;                               data structure [see get_th?_peib.pro, ? = a-f]
;                               or a Wind/3DP data structure
;                               [see get_?.pro, ? = el, elb, pl, ph, eh, etc.]
;
;  EXAMPLES:    
;               ;;=======================================================================
;               ;;  The following example assumes the user has loaded 3DP data into
;               ;;    TPLOT using load_3dp_data.pro.  See tutorials for more
;               ;;    information.
;               ;;=======================================================================
;               ;;  Define a time of interest
;               to      = time_double('1998-08-09/16:00:00')
;               ;;  Get a Wind 3DP PESA High data structure from level zero files
;               dat     = get_ph(to)
;               ;;....................................................................
;               ;;  in the following lines, the strings correspond to TPLOT handles
;               ;;      and thus may be different for each user's preference
;               ;;....................................................................
;               add_vsw2,dat,'V_sw2'          ;;  Add solar wind velocity to struct.
;               add_magf2,dat,'wi_B3(GSE)'    ;;  Add magnetic field to struct.
;               add_scpot,dat,'sc_pot_3'      ;;  Add spacecraft potential to struct.
;               ;;....................................................................
;               ;;  Convert energies/angles to 3D velocity vectors
;               ;;....................................................................
;               velocities = energy_angle_to_velocity(dat)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Now calls define_particle_charge.pro in place of
;                   test_wind_vs_themis_esa_struct.pro and dat_3dp_str_names.pro
;                                                                   [10/02/2014   v1.1.0]
;
;   NOTES:      
;               1)  If DATA is from THEMIS/ESA, make sure it has been modified by
;                     modify_themis_esa_struc.pro and rotate_esa_thetaphi_to_gse.pro.
;                     The former will ensure consistent structure tags are used while
;                     the latter will ensure the {THETA,PHI}-angles are in the GSE
;                     basis, not the DSL basis.  Technically, the routine does not
;                     (and cannot) check whether the {THETA,PHI}-angles in DATA were
;                     rotated into the GSE basis.  So if you wish to find the velocities
;                     in the DSL basis, then only use modify_themis_esa_struc.pro.
;
;  REFERENCES:  
;               1)  Lin, R.P., K.A. Anderson, S. Ashford, C. Carlson, D. Curtis,
;                      R. Ergun, D. Larson, J. McFadden, M. McCarthy, G.K. Parks,
;                      H. Rème, J.M. Bosqued, J. Coutelier, F. Cotin, C. D'Uston,
;                      K.-P. Wenzel, T.R. Sanderson, J. Henrion, J.C. Ronnet, and
;                      G. Paschmann "A Three-Dimensional Plasma and Energetic Particle
;                      Investigation for the Wind Spacecraft," Space Sci. Rev. Vol. 71,
;                      pp. 125-153, doi:10.1007/BF00751328, (1995).
;               2)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, (2008).
;               3)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, (2008).
;
;   CREATED:  09/10/2014
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/02/2014   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION energy_angle_to_velocity,data

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
notstr_msg     = 'Must be an IDL structure...'
notvdf_msg     = 'Must be an ion velocity distribution IDL structure...'
badthm_msg     = 'If THEMIS ESA structures used, then they must be modified using modify_themis_esa_struc.pro'
not3dp_msg     = 'Must be an ion velocity distribution IDL structure from Wind/3DP...'
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
charge         = define_particle_charge(dat,E_SHIFT=e_shift)
IF (charge[0] EQ 0) THEN BEGIN
  MESSAGE,notvdf_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define energy shift
test           = (N_ELEMENTS(e_shift) EQ 0) OR (SIZE(e_shift,/TYPE) LE 2)
IF (test[0]) THEN e_shift = 0e0
;;----------------------------------------------------------------------------------------
;;  Define spacecraft potential offset
;;----------------------------------------------------------------------------------------
str_element,dat,'SC_POT',scpot
test           = (N_ELEMENTS(scpot) EQ 0) OR (FINITE(scpot) EQ 0)
IF (test[0]) THEN scpot = 0e0 ELSE scpot = dat[0].SC_POT[0]*charge[0]  ;; ø < 0 (electrons), ø > 0 (ions)
;;----------------------------------------------------------------------------------------
;;  Define DAT structure parameters
;;----------------------------------------------------------------------------------------
mass           = dat[0].MASS[0]               ;;  particle mass [eV km^(-2) s^(2)]
n_e            = dat[0].NENERGY               ;;  # of energy bins
n_a            = dat[0].NBINS                 ;;  # of angle bins
energy         = dat[0].ENERGY + e_shift[0]   ;;  Energy bin values [eV]
denergy        = dat[0].DENERGY               ;;  Uncertainty in ENERGY [eV]
phi            = dat[0].PHI                   ;;  Azimuthal angle (from sun direction) [deg]
dphi           = dat[0].DPHI                  ;;  Uncertainty in phi [deg]
the            = dat[0].THETA                 ;;  Poloidal angle (from ecliptic plane) [deg]
dthe           = dat[0].DTHETA                ;;  Uncertainty in theta [deg]
;;   Shift energies by SC-Potential
;;    -> Electrons gain energy => +(-e) ø = -e ø
;;    -> Ions lose energy      => +(+q) ø = +Z e ø
energy        += scpot[0]
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
velocities     = DBLARR(n_e[0],n_a[0],3L)
FOR k=0L, 2L DO velocities[*,*,k] = speed*udir_str.(k)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,velocities
END

