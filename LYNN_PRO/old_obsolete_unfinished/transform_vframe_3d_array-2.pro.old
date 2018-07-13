;+
;*****************************************************************************************
;
;  FUNCTION :   transform_vframe_3d_array.pro
;  PURPOSE  :   This routine transforms an array of THEMIS ESA, Wind 3DP, etc. velocity
;                 distributions (given as IDL structures) into a new reference frame
;                 given by the user defined VTRANS.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               is_a_3_vector.pro
;               define_particle_charge.pro
;               test_wind_vs_themis_esa_struct.pro
;               dat_3dp_str_names.pro
;               pesa_high_bad_bins.pro
;               convert_ph_units.pro
;               conv_units.pro
;               str_element.pro
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
;                               THEMIS ESA or SST data structure(s)
;                               [e.g., see get_th?_p*@b.pro, ? = a-f, * = e,s @ = e,i]
;                               or a Wind/3DP data structure(s)
;                               [see get_?.pro, ? = el, elb, pl, ph, eh, etc.]
;                               [Note:  VSW or VELOCITY tag must be defined and finite]
;               VTRANS     :  [N,3]-Element array of transformation velocities [km/s] as
;                               an array of 3-vectors, where N = N_ELEMENTS(DAT)
;
;  EXAMPLES:    
;               [calling sequence]
;               data   = transform_vframe_3d_array(dat ,vtrans)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Continued to write routine
;                                                                  [12/01/2015   v1.0.0]
;             2)  Finished writing routine
;                                                                  [12/01/2015   v1.0.0]
;
;   NOTES:      
;               1)  See also:
;                     transform_vframe_3d.pro
;                     rel_lorentz_trans_3vec.pro
;                     relativistic_gamma.pro
;                     energy_to_vel.pro
;                     energy_angle_to_velocity.pro
;                     velocity_to_energy_angle.pro
;
;  REFERENCES:  
;               1)  Carlson et al., "An instrument for rapidly measuring
;                      plasma distribution functions with high resolution,"
;                      Adv. Space Res. Vol. 2, pp. 67-70, (1983).
;               2)  Curtis et al., "On-board data analysis techniques for
;                      space plasma particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372, (1989).
;               3)  Lin et al., "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125, (1995).
;               4)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst., (1998).
;               5)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, (2008).
;               6)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, (2008).
;               7)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;               8)  Ipavich, F.M. "The Compton-Getting effect for low energy particles,"
;                      Geophys. Res. Lett. 1(4), pp. 149-152, (1974).
;
;   CREATED:  12/01/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/01/2015   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION transform_vframe_3d_array,dat,vtrans

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, is_a_3_vector, define_particle_charge,            $
                 test_wind_vs_themis_esa_struct, dat_3dp_str_names, conv_units, $
                 energy_to_vel, my_dot_prod, mag__vec, relativistic_gamma
;;****************************************************************************************
ex_start       = SYSTIME(1)
;;****************************************************************************************
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
c              = 2.9979245800d+08     ;;  Speed of light in vacuum [m/s]
ckm            = c[0]                 ;;  Speed of light in vacuum [km/s]
ckm           *= 1d-3                 ;;  m --> km
def_uconv_r_th = ['thm_convert_esa_units_lbwiii','thm_convert_sst_units_lbwiii']
;;  Dummy error messages
notstr_msg     = 'Must be an array of IDL structures...'
badvfor_msg    = 'Incorrect input format:  VTRANS must be a [N,3]-element [numeric] arrays of 3-vectors'
baddfor_msg    = 'Incorrect input format:  DAT and VTRANS must both be a [N]-element arrays, one of structures, one of 3-vectors'
notvdf_msg     = 'Must be an array of ion velocity distributions as IDL structures...'
badthm_msg     = "If THEMIS ESA/SST structures used, then they must be modified to have LBW's unit conversion routines defined..."
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (is_a_number(vtrans,/NOMSSG) EQ 0) OR $
                 (SIZE(dat,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check VTRANS format
test           = (is_a_3_vector(vtrans,V_OUT=vtran2d,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,badvfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Make sure DAT and VTRANS have the same number of elements
n_d            = N_ELEMENTS(dat)
n_v            = N_ELEMENTS(vtran2d[*,0])
test           = (n_d[0] NE n_v[0])
IF (test[0]) THEN BEGIN
  MESSAGE,badvfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
data           = dat
dat0           = data[0]
;;  Define sign of particle charge and energy shift
charge         = define_particle_charge(dat0)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NOKILL_PH
IF KEYWORD_SET(nokill_ph) THEN nokill_ph = 1b ELSE nokill_ph = 0b
;;----------------------------------------------------------------------------------------
;;  Determine the spacecraft from which DAT originated
;;    --> convert to phase space density
;;----------------------------------------------------------------------------------------
test0          = test_wind_vs_themis_esa_struct(dat0,/NOM)
IF (test0.(0)) THEN BEGIN
  ;;-------------------------------------------
  ;; Wind
  ;;-------------------------------------------
  ;;  Check which instrument is being used
  strns   = dat_3dp_str_names(dat0[0])
  IF (SIZE(strns,/TYPE) NE 8) THEN BEGIN
    ;;  Return with nothing changed
    RETURN,0b
  ENDIF
  shnme   = STRLOWCASE(STRMID(strns.SN[0],0L,2L))
  CASE shnme[0] OF
    'ph' : BEGIN
      ;;  Remove data glitch if necessary in PH data
      IF NOT KEYWORD_SET(nokill_ph) THEN BEGIN
        pesa_high_bad_bins,data
      ENDIF
      convert_ph_units,data,'df'
    END
    ELSE : BEGIN
      data   = conv_units(data,'df')
    END
  ENDCASE
  ;;  Make sure not SST
  IF (STRMID(shnme[0],0L,1L) EQ 's') THEN yes_e_remove = 0b ELSE yes_e_remove = 1b
ENDIF ELSE BEGIN
  yes_e_remove = 0b  ;;  Do not kill data with large energy bins [later in routine]
  ;;-------------------------------------------
  ;; THEMIS
  ;;-------------------------------------------
  ;;  make sure the structure has been modified
  temp_proc = STRLOWCASE(dat0[0].UNITS_PROCEDURE)
  test_un   = (temp_proc[0] NE def_uconv_r_th[0]) AND (temp_proc[0] NE def_uconv_r_th[1])
  IF (test_un) THEN BEGIN
    MESSAGE,badthm_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0b
  ENDIF
  ;;  structure modified appropriately so convert units
  data   = conv_units(data,'df')
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define the spacecraft potentials
;;    -->  Assume charge does not change between structures
;;----------------------------------------------------------------------------------------
scpot          = data.SC_POT[0]*charge[0]  ;;  ø < 0 (electrons), ø > 0 (ions)
bad_scp        = WHERE(FINITE(scpot) EQ 0,bd_scp)
IF (bd_scp GT 0) THEN BEGIN
  scpot[bad_scp]       = 0e0
  data[bad_scp].SC_POT = 0e0
ENDIF
;;  Check for existence of E_SHIFT structure tag
n_str          = N_ELEMENTS(data)           ;;  # of data structures
str_element,dat0,'E_SHIFT',e_shift
IF (N_ELEMENTS(e_shift) GT 0) THEN BEGIN
  ;;  E_SHIFT tag exists --> define
  e_shift0 = data.E_SHIFT[0]
  e_sh_on  = 1b
ENDIF ELSE BEGIN
  ;;  E_SHIFT tag does not exists --> set to zero
  e_sh_on  = 0b
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define DAT structure parameters
;;----------------------------------------------------------------------------------------
n_e            = data[0].NENERGY            ;;  # of energy bins
n_a            = data[0].NBINS              ;;  # of angle bins
mass           = data[0].MASS[0]            ;;  particle mass [eV km^(-2) s^(2)]
;;  Change dimensions of SC_POT and E_SHIFT
scpot3d        = REPLICATE(0e0,n_e[0],n_a[0],n_str[0])
e_shift3d      = REPLICATE(0e0,n_e[0],n_a[0],n_str[0])
FOR j=0L, n_str[0] - 1L DO BEGIN
  scpot3d[*,*,j] = scpot[j]
  IF (e_sh_on[0]) THEN e_shift3d[*,*,j] = e_shift0[j]
ENDFOR
;;  Define energy bin values ([E,A,N]-Element array)
energy         = data.ENERGY + e_shift3d    ;;  Energy bin midpoint values [eV]
old_energy     = energy
denergy        = data.DENERGY               ;;  Range for each energy bin [eV]
phi            = data.PHI                   ;;  Azimuthal angle (from sun direction) [deg]
the            = data.THETA                 ;;  Poloidal angle (from ecliptic plane) [deg]
;;   Shift energies by SC-Potential
;;    -> Electrons gain energy => +(-e) ø = -e ø
;;    -> Ions lose energy      => +(+q) ø = +Z e ø
energy        += scpot3d
df_dat         = data.DATA               ;;  Data values [data.UNITS_NAME]
;;  Define types to avoid "Conflicting data structures" error
szt_dtpe       = [SIZE(data.DATA,/TYPE),SIZE(data.THETA,/TYPE),SIZE(data.PHI,/TYPE),$
                  SIZE(data.ENERGY,/TYPE)]
;;----------------------------------------------------------------------------------------
;;  Remove bins below ~1.3 ø_sc
;;----------------------------------------------------------------------------------------
test_old       = (old_energy LT ABS(scpot3d)*1.3)
bad            = WHERE(test_old,nbad,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (nbad GT 0) THEN BEGIN
  ;;  Remove low energy values
  df_dat[bad]  = f
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check for "bad" values
;;
;;    ** specifically looking for energy bin values in PESA High distributions that were
;;      produced using the 32-bit Darwin shared object libraries
;;----------------------------------------------------------------------------------------
bad_en         = WHERE(denergy GE 1e8,bden)
test_en        = (bden GT 0L) AND yes_e_remove[0]
IF (test_en[0]) THEN BEGIN
  ;;  Energies
  energy[bad_en]   = f
  denergy[bad_en]  = f
  ;;  Data
  df_dat[bad_en]   = f
ENDIF
;;----------------------------------------------------------------------------------------
;;  Convert energies to speeds [km/s]
;;----------------------------------------------------------------------------------------
speed          = energy_to_vel(energy,mass[0])        ;;  [E,A,N]-Element array
;;  Define unit vector directions
coth           = COS(the*!DPI/18d1)
sith           = SIN(the*!DPI/18d1)
coph           = COS(phi*!DPI/18d1)
siph           = SIN(phi*!DPI/18d1)
udir_str       = {X:coth*coph,Y:coth*siph,Z:sith}
;;  Check input type (i.e., do not want to make a double from float input)
IF (szt_dtpe[3] EQ 4) THEN BEGIN
  ;;  FLOAT
  facs  = [18e1,!PI,36e1]
  f_on  = 1b
  nan   = f
ENDIF ELSE BEGIN
  ;;  DOUBLE
  facs  = [18d1,!DPI,36d1]
  f_on  = 0b
  nan   = d
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define some dummy arrays to use as fillers (avoid replicating the same arrays)
;;----------------------------------------------------------------------------------------
;;  Let K = E*A, M = K*N
ExAxNx3_nans   = REPLICATE(nan,n_e[0],n_a[0],n_str[0],3L)
KxNx3_nans     = REFORM(ExAxNx3_nans,n_e[0]*n_a[0],n_str[0],3L)
Mx3_nans       = REFORM(ExAxNx3_nans,n_e[0]*n_a[0]*n_str[0],3L)
ExA_1s         = REPLICATE(1,n_e[0]*n_a[0])
;;----------------------------------------------------------------------------------------
;;  Convert energy/angles to 3D velocity vectors, then
;;    --> transform into new reference frame
;;----------------------------------------------------------------------------------------
vels_3d        = ExAxNx3_nans                                 ;;  [E,A,N,3]-Element array
;;  Define velocity in SCF
FOR k=0L, 2L DO vels_3d[*,*,*,k] = speed*udir_str.(k)
;;  Define 3D transformation velocities
vtran3d2       = KxNx3_nans
FOR j=0L, n_str[0] - 1L DO vtran3d2[*,j,*] = ExA_1s # REFORM(vtran2d[j,*])
;;  Reform arrays
vtran1d        = REFORM(vtran3d2,n_e[0]*n_a[0]*n_str[0],3L)
vels_1d        = REFORM(vels_3d,n_e[0]*n_a[0]*n_str[0],3L)    ;;  [M,3]-Element array
;;  Compute dot-products and magnitudes
u_d_v          = my_dot_prod(vels_1d,vtran1d,/NOM)            ;;  V_3d . VTRANS  ([M]-Element array)
v_mag          = mag__vec(vtran1d,/NAN,/TWO)                  ;;  |VTRANS|       ([M,3]-Element array)
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
u_d_v_2d       = Mx3_nans                       ;;  [M,3]-Element array
FOR k=0L, 2L DO u_d_v_2d[*,k] = u_d_v
u_para         = (u_d_v_2d/v_mag^2)*vtran1d     ;;  = U_//
u_perp         = vels_1d - u_para               ;;  = U_|_
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
;;----------------------------------------------------------------------------------------
;;  Reform arrays
;;----------------------------------------------------------------------------------------
vel_kprime3d   = REFORM(u_rl_trans,n_e[0],n_a[0],n_str[0],3L)  ;;  [E,A,N,3]-Element array
vmg_kprime3d   = REFORM(u_rl_tranmg,n_e[0],n_a[0],n_str[0])    ;;  [E,A,N]-Element array
;;----------------------------------------------------------------------------------------
;;  Define new angles [deg]
;;    Poloidal   -->   -90 < theta <  +90
;;    Azimuthal  -->  -180 <  phi  < +180
;;----------------------------------------------------------------------------------------
;;  Both are [E,A,N]-Element arrays
n_the          = ASIN(vel_kprime3d[*,*,*,2]/vmg_kprime3d)*facs[0]/facs[1]
n_phi          = ATAN(vel_kprime3d[*,*,*,1],vel_kprime3d[*,*,*,0])*facs[0]/facs[1]
;;  Shift azimuthal angles to {   0 < phi < +360 }
n_phi          = (n_phi + facs[2]) MOD facs[2]
;;----------------------------------------------------------------------------------------
;;  Define new energies [eV]
;;----------------------------------------------------------------------------------------
eners          = energy_to_vel(vmg_kprime3d,mass[0],/INVERSE)      ;;  [E,A,N]-Element array [eV]
IF (szt_dtpe[0] EQ 4) THEN data_3d = FLOAT(df_dat) ELSE data_3d = DOUBLE(df_dat)
IF (szt_dtpe[1] EQ 4) THEN the_3d  = FLOAT(n_the)  ELSE the_3d  = DOUBLE(n_the)
IF (szt_dtpe[2] EQ 4) THEN phi_3d  = FLOAT(n_phi)  ELSE phi_3d  = DOUBLE(n_phi)
IF (szt_dtpe[3] EQ 4) THEN ener_3d = FLOAT(eners)  ELSE ener_3d = DOUBLE(eners)
;;----------------------------------------------------------------------------------------
;;  Redefine structure tag values
;;----------------------------------------------------------------------------------------
data.DATA      = data_3d
data.ENERGY    = ener_3d
data.THETA     =  the_3d
data.PHI       =  phi_3d
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;****************************************************************************************
ex_time        = SYSTIME(1) - ex_start[0]
MESSAGE,STRING(ex_time[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;;****************************************************************************************

RETURN,data
END





;  vel3d = REFORM(vels_3d[*,*,j,*])                    ;;  [E,A,3]-Element array
;  vel2d = REFORM(vel3d,n_e[0]*n_a[0],3L)              ;;  [K,3]-Element array




;;;----------------------------------------------------------------------------------------
;;;  Calculate (relativistically correct) Lorentz transformation
;;;----------------------------------------------------------------------------------------
;;;  Let E*A = K
;vels_2d        = REFORM(vels_3d,n_e[0]*n_a[0],n_str[0],3L)    ;;  [K,N,3]-Element array
;vel_kprime2d   = DBLARR(n_e[0]*n_a[0],n_str[0],3L)            ;;  [K,N,3]-Element array
;vmg_kprime2d   = DBLARR(n_e[0]*n_a[0],n_str[0])               ;;  [K,N]-Element array
;;vmg_kprime2d   = DBLARR(n_e[0]*n_a[0],n_str[0],3L)            ;;  [K,N,3]-Element array
;
;FOR j=0L, n_str[0] - 1L DO BEGIN
;  vel2d = REFORM(vels_2d[*,j,*])                              ;;  [K,3]-Element array
;  vvtra = REFORM(vtran2d[j,*])                                ;;  [3]-Element array
;  v_tra = rel_lorentz_trans_3vec(vel2d,vvtra)                 ;;  Transformed velocities ([K,3]-Element array)
;  ;;  Define transformed velocities [km/s]
;  vel_kprime2d[*,j,*] = v_tra
;  ;;  Define transformed speeds [km/s]
;  vmg_kprime2d[*,j]   = mag__vec(v_tra,/NAN)
;;  vmg_kprime2d[*,j,*] = mag__vec(v_tra,/NAN,/TWO)             ;;  /TWO keeps this a [K,3]-Element array
;ENDFOR
;vel_kprime3d   = REFORM(vel_kprime2d,n_e[0],n_a[0],n_str[0],3L)  ;;  [E,A,N,3]-Element array
;;vmg_kprime3d   = REFORM(vmg_kprime2d,n_e[0],n_a[0],n_str[0],3L)
;vmg_kprime3d   = REFORM(vmg_kprime2d,n_e[0],n_a[0],n_str[0])     ;;  [E,A,N]-Element array
;;;----------------------------------------------------------------------------------------
;;;  Define new angles [deg]
;;;    Poloidal   -->   -90 < theta <  +90
;;;    Azimuthal  -->  -180 <  phi  < +180
;;;----------------------------------------------------------------------------------------
;;;  Both are [E,A,N]-Element arrays
;n_the          = ASIN(vel_kprime3d[*,*,*,2]/vmg_kprime3d)*facs[0]/facs[1]
;n_phi          = ATAN(vel_kprime3d[*,*,*,1],vel_kprime3d[*,*,*,0])*facs[0]/facs[1]
;;;  Shift azimuthal angles to {   0 < phi < +360 }
;n_phi          = (n_phi + facs[2]) MOD facs[2]














