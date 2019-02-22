;+
;*****************************************************************************************
;
;  PROCEDURE:   calc_relevant_speeds.pro
;  PURPOSE  :   This routine returns several characteristic speeds in plasmas as passive
;                 outputs through named variable keywords.  The speeds on output can
;                 include, depending on inputs, all with units of km/s:
;                   - Alfvén speed
;                       V_A      = B_o/[ µ_o n_o M_i ]^(1/2)
;                   - ion-acoustic sound speed
;                       C_s      = [k_B (Z_i ¥_e T_e + ¥_i T_i)/(M_i + m_e)]^(1/2)
;                   - root mean square (thermal) speed
;                       V_Trms,j = [k_B T_j/M_j]^(1/2)
;                   - most probable (thermal) speed
;                       V_Tmps,j = [2 k_B T_j/M_j]^(1/2)
;                   - MHD slow mode speed
;                       V_s      = [(b^2 - [b^4 + c^2]^(1/2))/2]^(1/2)
;                   - MHD fast mode speed
;                       V_f      = [(b^2 + [b^4 + c^2]^(1/2))/2]^(1/2)
;                 where we have used the following definitions:
;                       µ_o      = permeability of free space
;                       M_i      = ion mass
;                       m_e      = electron mass
;                       k_B      = Boltzmann constant
;                       ¥_j      = adiabatic or polytrope index of species j
;                                    (where j = e or i)
;                       Z_i      = charge state of the ions
;                       n_o      = # density of plasma (assumes n_e = Z_i n_i)
;                       B_o      = magnitude of magnetic field
;                       T_j      = average temperature of species j
;                       b        = V_ms (i.e., MHD magnetosonic speed)
;                       V_ms     = [V_A^2 + C_s^2]^(1/2)
;                       c        = 2 V_A C_s Sin(ø)
;                       ø        = wave normal angle relative to direction of B_o
;
;  CALLED BY:   
;               t_calc_and_send_machs_2_tplot.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NO          :  [N]-Element [numeric] array of plasma # densities
;                                [with units cm^(-3)]
;               BO          :  [N]-Element [numeric] array of magnetic field magnitudes
;                                [with units nT]
;
;  EXAMPLES:    
;               [calling sequence]
;               calc_relevant_speeds, no, bo [,TEMP_E=temp_e] [,TEMP_I=temp_i]       $
;                                     [,GAMM_E=gamm_e] [,GAMM_I=gamm_i] [,Z_I=z_i]   $
;                                     [,M_I=m_i] [,THETA=theta] [,V_A_OUT=v_a_out]   $
;                                     [,C_S_OUT=c_s_out] [,V_S_OUT=v_s_out]          $
;                                     [,V_F_OUT=v_f_out] [,V_MS_OUT=v_ms_out]        $
;                                     [,V_TRMS_OUT=v_trms_out] [,V_TMPS_OUT=v_tmps_out]
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               TEMP_E      :  [N]-Element [numeric] array defining the average electron
;                                temperatures [with units eV]
;                                 [Default = TEMP_I if set, else not used]
;               TEMP_I      :  [N]-Element [numeric] array defining the average ion
;                                temperatures [with units eV]
;                                 [Default = TEMP_E if set, else not used]
;               GAMM_E      :  Scalar [numeric] defining the adiabatic or polytrope index
;                                of the electrons (i.e., ratio of specific heats)
;                                 [Default = GAMM_I if set, else = 1]
;               GAMM_I      :  Scalar [numeric] defining the adiabatic or polytrope index
;                                of the ions (i.e., ratio of specific heats)
;                                 [Default = 5/3]
;               M_I         :  Scalar [numeric] defining the ion mass [with units kg]
;                                 [Default = M_p (i.e., proton mass)]
;               Z_I         :  Scalar [numeric] defining the charge state of the ions
;                                (e.g., enter +2 for alpha-particles)
;                                 [Default = 1 (i.e., protons)]
;               THETA       :  [N]-Element [numeric] array defining the wave normal angle
;                                with respect to the quasi-static magnetic field [degrees]
;                                 [Default = 90]
;               **********************************
;               ***       DIRECT OUTPUTS       ***
;               **********************************
;               V_A_OUT     :  Set to a named variable to return the Alfvén speed
;                                --> [N]-element array on output [with units km/s]
;               C_S_OUT     :  Set to a named variable to return the ion-acoustic
;                                sound speed
;                                --> [N]-element array on output [with units km/s]
;               V_S_OUT     :  Set to a named variable to return the MHD slow mode speed
;                                --> [N]-element array on output [with units km/s]
;               V_F_OUT     :  Set to a named variable to return the MHD fast mode speed
;                                --> [N]-element array on output [with units km/s]
;               V_MS_OUT    :  Set to a named variable to return the MHD magnetosonic
;                                speed
;                                --> [N]-element array on output [with units km/s]
;               V_TRMS_OUT  :  Set to a named variable to return the root mean square
;                                speed (i.e., thermal speed) on output
;                                --> [N,2]-element array on output (one for each species)
;                                    [with units km/s]
;               V_TMPS_OUT  :  Set to a named variable to return the most probable
;                                speed (i.e., thermal speed) on output
;                                --> [N,2]-element array on output (one for each species)
;                                    [with units km/s]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [01/15/2016   v1.0.0]
;             2)  Fixed typos in checking of M_I and Z_I keywords
;                                                                   [01/26/2016   v1.0.1]
;             3)  Fixed typo in calculation of MHD speeds
;                                                                   [01/28/2016   v1.0.2]
;             4)  Fixed a bug when user entered only one temperature type
;                                                                   [08/04/2017   v1.0.3]
;
;   NOTES:      
;               0)  ***  Still needs more testing  ***
;
;               1)  If the Z_I is set to a value not equal to +1, then the M_I keyword
;                     MUST be set to the corresponding ion mass
;               2)  Rules for TEMP_E and TEMP_I keywords:
;                     A)  TEMP_E = TRUE,  TEMP_I = FALSE  -->  ignore Ti in C_s calculation
;                     B)  TEMP_E = FALSE, TEMP_I = TRUE   -->  ignore Te in C_s calculation
;                     C)  TEMP_E = FALSE, TEMP_I = FALSE  -->  Ignore all T-dependent speeds
;                     D)  TEMP_E = TRUE,  TEMP_I = TRUE   -->  Proceed normally
;               3)  Rules for V_TRMS_OUT and V_TMPS_OUT keywords:
;                     V_T{RMS,MPS}_OUT[*,0] = electron thermal speeds
;                     V_T{RMS,MPS}_OUT[*,1] = ion thermal speeds
;
;  REFERENCES:  
;               1)  Viñas, A.F. and J.D. Scudder (1986), "Fast and Optimal Solution to
;                      the 'Rankine-Hugoniot Problem'," J. Geophys. Res. 91, pp. 39-58.
;               2)  A. Szabo (1994), "An improved solution to the 'Rankine-Hugoniot'
;                      problem," J. Geophys. Res. 99, pp. 14,737-14,746.
;               3)  Koval, A. and A. Szabo (2008), "Modified 'Rankine-Hugoniot' shock
;                      fitting technique:  Simultaneous solution for shock normal and
;                      speed," J. Geophys. Res. 113, pp. A10110.
;               4)  Russell, C.T., J.T. Gosling, R.D. Zwickl, and E.J. Smith (1983),
;                      "Multiple spacecraft observations of interplanetary shocks:  ISEE
;                      Three-Dimensional Plasma Measurements," J. Geophys. Res. 88,
;                      pp. 9941-9947.
;               5)  Gurnett, D.A. and A. Bhattacharjee (2005), "Introduction to Plasma
;                      Physics:  With Space and Laboratory Applications," Cambridge
;                      University Press, Cambridge, UK, ISBN:0-521-36483-3.
;               6)  Stix, T.H. (1962), "The Theory of Plasma Waves,"
;                      McGraw-Hill Book Company, USA.
;               7)  See the notes and Refs. in the following Stack Exchange post:
;                     http://physics.stackexchange.com/a/179057/59023
;               8)  2014 CODATA/NIST at:
;                     http://physics.nist.gov/cuu/Constants/index.html
;               9)  2015 Astronomical Almanac at:
;                     http://asa.usno.navy.mil/SecK/Constants.html
;
;   CREATED:  01/14/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/04/2017   v1.0.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO calc_relevant_speeds,no,bo,TEMP_E=temp_e,TEMP_I=temp_i,GAMM_E=gamm_e,GAMM_I=gamm_i, $
                               Z_I=z_i,M_I=m_i,THETA=theta,V_A_OUT=v_a_out,             $
                               C_S_OUT=c_s_out,V_S_OUT=v_s_out,V_F_OUT=v_f_out,         $
                               V_MS_OUT=v_ms_out,V_TRMS_OUT=v_trms_out,                 $
                               V_TMPS_OUT=v_tmps_out

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
ckm            = c[0]*1d-3                ;;  m --> km
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
SB             = 5.6703670000d-08         ;;  Stefan-Boltzmann Constant [W m^(-2) K^(-4), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;  Electromagnetic
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;;  Atomic
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
amu            = 1.6605390400d-27         ;;  Atomic mass constant [kg, 2014 CODATA/NIST]
max_mi         = 300d0*amu[0]             ;;  Limit ion mass to < 300 amu's
;;  --> Define mass of particles in units of energy [eV]
ma_eV          = ma[0]*c[0]^2/qq[0]       ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
me_eV          = me[0]*c[0]^2/qq[0]       ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mn_eV          = mn[0]*c[0]^2/qq[0]       ;;  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c[0]^2/qq[0]       ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;----------------------------------------------------------------------------------------
;;  Conversion Factors
;;----------------------------------------------------------------------------------------
;;  Energy and Temperature
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
J_1eV          = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
K_eV           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
eV_K           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
;;  Speeds
vte_mps_fac    = SQRT(2d0*J_1eV[0]/me[0]) ;;  factor for electron thermal speed [m s^(-1) eV^(-1/2)] (most probable speed)
vtp_mps_fac    = SQRT(2d0*J_1eV[0]/mp[0]) ;;  factor for proton thermal speed [m s^(-1) eV^(-1/2)] (most probable speed)
vte_rms_fac    = SQRT(J_1eV[0]/me[0])     ;;  factor for electron thermal speed [m s^(-1) eV^(-1/2)] (rms speed)
vtp_rms_fac    = SQRT(J_1eV[0]/mp[0])     ;;  factor for proton thermal speed [m s^(-1) eV^(-1/2)] (rms speed)
valfenp_fac    = 1d-9                     ;;  factor for (proton-only) Alfvén speed [m s^(-1) nT^(-1) cm^(-3/2)]
valfenp_fac   /= SQRT(muo[0]*mp[0]*1d6)
;;----------------------------------------------------------------------------------------
;;  Error messages
;;----------------------------------------------------------------------------------------
noinput_mssg   = 'Incorrect number of inputs were supplied...'
baddfor_msg    = 'Incorrect input format:  NO and BO must have the same # of elements...'
baddinp_msg    = 'Incorrect input:  NO and BO must both be [N]-element numeric arrays...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 2) OR (is_a_number(no) EQ 0) OR (is_a_number(bo) EQ 0)
IF (test) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check size of inputs
n_o            = REFORM(no)
b_o            = REFORM(bo)
szdno          = SIZE(n_o,/DIMENSIONS)
szdbo          = SIZE(b_o,/DIMENSIONS)
;;  Make sure data format is okay
test           = (N_ELEMENTS(szdno) NE 1) OR (N_ELEMENTS(szdbo) NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,baddinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
test           = (szdno[0] NE szdbo[0])
IF (test[0]) THEN BEGIN
  MESSAGE,baddfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Define N
nn             = szdno[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords [Inputs]
;;----------------------------------------------------------------------------------------
;;  Check TEMP_E and TEMP_I
test_te        = (N_ELEMENTS(temp_e) EQ nn[0]) AND is_a_number(temp_e,/NOMSSG)
test_ti        = (N_ELEMENTS(temp_i) EQ nn[0]) AND is_a_number(temp_i,/NOMSSG)
;;  Check GAMM_E and GAMM_I
test_ge        = (N_ELEMENTS(gamm_e) GT 0) AND is_a_number(gamm_e,/NOMSSG)
test_gi        = (N_ELEMENTS(gamm_i) GT 0) AND is_a_number(gamm_i,/NOMSSG)
;;  Check M_I and Z_I
test_mi        = (N_ELEMENTS(m_i) GT 0) AND is_a_number(m_i,/NOMSSG)
test_zi        = (N_ELEMENTS(z_i) GT 0) AND is_a_number(z_i,/NOMSSG)
;test_mi        = (N_ELEMENTS(m_i) EQ nn[0]) AND is_a_number(m_i,/NOMSSG)
;test_zi        = (N_ELEMENTS(z_i) EQ nn[0]) AND is_a_number(z_i,/NOMSSG)
;;  Check THETA
test_th        = (N_ELEMENTS(theta) EQ nn[0]) AND is_a_number(theta,/NOMSSG)
;;----------------------------------------------------------------------------------------
;;  Define ion charge state
;;----------------------------------------------------------------------------------------
IF (test_zi[0]) THEN zi = z_i[0] ELSE zi = 1d0
;;  Make sure charge state is positive definite
zi             = ABS(zi[0])
;;----------------------------------------------------------------------------------------
;;  Define ion mass
;;----------------------------------------------------------------------------------------
IF (test_mi[0]) THEN mi = m_i[0] ELSE mi = mp[0]
;;  M_I is set  -->  Make sure  (m_e ≤ M_I < MAX)
test           = (mi[0] LT me[0]) OR (mi[0] GT max_mi[0])
IF (test[0]) THEN BEGIN
  ;;  BAD  -->  Force to proton parameters!
  mid_str        = (['EQ','NE'])[(zi[0] NE 1)]
  bad_mssg       = '(Z_i '+mid_str[0]+' 1) --> M_i [kg] must satisfy:  (m_e ≤ M_i < 300 amu [kg])'
  MESSAGE,bad_mssg[0],/INFORMATIONAL,/CONTINUE
  ;;  Redefine to proton parameters regardless of input
  mi             = mp[0]   ;;  Redefine to proton mass
  zi             = 1d0     ;;  Redefine to proton charge state
ENDIF
;;  Check if Z_i ≠ +1 and M_I NOT set
test           = (zi[0] NE 1) AND (test_mi[0] EQ 0)
IF (test[0]) THEN BEGIN
  ;;  BAD  -->  Force to proton parameters!
  bad_mssg       = 'If M_I is NOT set  -->  Z_i MUST equal +1'
  MESSAGE,bad_mssg[0],/INFORMATIONAL,/CONTINUE
  zi             = 1d0     ;;  Redefine to proton charge state
ENDIF
;;  Define µ = M_i/M_p
mu             = mi[0]/mp[0]
mu_1sqrt       = SQRT(1d0/mu[0])
;;----------------------------------------------------------------------------------------
;;  Define polytrope indices
;;----------------------------------------------------------------------------------------
IF (test_gi[0]) THEN g_i = gamm_i[0] ELSE g_i = 5d0/3d0
IF (test_ge[0]) THEN g_e = gamm_e[0] ELSE g_e = ([1d0,g_i[0]])[(test_gi[0])]
;;----------------------------------------------------------------------------------------
;;  Define wave normal angles [deg]
;;----------------------------------------------------------------------------------------
IF (test_th[0]) THEN the = REFORM(theta) ELSE the = REPLICATE(90d0,nn[0])
;;----------------------------------------------------------------------------------------
;;  Define Alfvén speed [km/s]
;;----------------------------------------------------------------------------------------
;;  Modify factor
valfenp_fac   *= mu_1sqrt[0]                     ;;  factor for (proton-only) Alfvén speed [m s^(-1) nT^(-1) cm^(-3/2)]
;;  Calculate Alfvén speed [m/s]
v_a_out        = valfenp_fac[0]*b_o/SQRT(n_o)
v_a_out       *= 1d-3                             ;;  m --> km
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define temperature-dependent speeds [km/s]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
test           = (test_te[0] EQ 0) AND (test_ti[0] EQ 0)
IF (test[0]) THEN RETURN                          ;;  Te and Ti not set  -->  Exit
;;  Define dummy fill values
dumb_n         = REPLICATE(0d0,nn[0])
good           = WHERE([(test_te[0]),(test_ti[0])],gd)
;good           = WHERE([(test_te[0] EQ 0),(test_ti[0] EQ 0)],gd)
ignore_te      = 0b
ignore_ti      = 0b
IF (gd[0] EQ 1) THEN BEGIN
  ;;  ONLY one temperature is set
  CASE good[0] OF
    0  :  BEGIN
      ;;  Te set --> Set Ti = Te
      t_e            = REFORM(temp_e)
      t_i            = t_e
      ignore_ti      = 1b
    END
    1  :  BEGIN
      ;;  Ti set --> Set Te = Ti
      t_i            = REFORM(temp_i)
      t_e            = t_i
      ignore_te      = 1b
    END
  ENDCASE
ENDIF ELSE BEGIN
  ;;  BOTH temperatures are set
  t_i            = REFORM(temp_i)
  t_e            = REFORM(temp_e)
ENDELSE
;;  Define temperatures multiplied by ¥_j and/or Z_i
IF (ignore_te[0]) THEN zgte = dumb_n ELSE zgte = zi[0]*g_e[0]*t_e
IF (ignore_ti[0]) THEN g_ti = dumb_n ELSE g_ti = g_i[0]*t_i
;;----------------------------------------------------------------------------------------
;;  Define ion-acoustic sound speed [km/s]
;;----------------------------------------------------------------------------------------
;;  Calculate ion-acoustic sound speed [m/s]
cs_fac         = SQRT(J_1eV[0]/(me[0] + mi[0]))
c_s_out        = cs_fac[0]*SQRT(zgte + g_ti)      ;;  Cs [m/s]
c_s_out       *= 1d-3                             ;;  m --> km
;;----------------------------------------------------------------------------------------
;;  Define the thermal speeds [km/s]
;;----------------------------------------------------------------------------------------
;;  Modify factors
vti_mps_fac    = vtp_mps_fac[0]*mu_1sqrt[0]
vti_rms_fac    = vtp_rms_fac[0]*mu_1sqrt[0]
;;  Calculate electron thermal speeds [m/s]
vte_mps        = vte_mps_fac[0]*SQRT(t_e)
vte_rms        = vte_rms_fac[0]*SQRT(t_e)
;;  Calculate ion thermal speeds [m/s]
vti_mps        = vti_mps_fac[0]*SQRT(t_i)
vti_rms        = vti_rms_fac[0]*SQRT(t_i)
;;  Define outputs
v_trms_out     = [[vte_rms],[vti_rms]]
v_tmps_out     = [[vte_mps],[vti_mps]]
v_trms_out    *= 1d-3                             ;;  m --> km
v_tmps_out    *= 1d-3                             ;;  m --> km
;;----------------------------------------------------------------------------------------
;;  Define MHD speeds [km/s]
;;----------------------------------------------------------------------------------------
;;  Calculate magnetosonic speed [km/s]
v_ms_out       = SQRT(c_s_out^2 + v_a_out^2)
;;  Calculate parameters for fast/slow speed
ac_parm        = 4d0*c_s_out^2*v_a_out^2*SIN(the*!DPI/18d1)^2
;sq_parm        = SQRT(v_ms_out^4 + ac_parm)
;sl2_fac        = v_ms_out^2 - sq_parm
;fa2_fac        = v_ms_out^2 + sq_parm
;;  LBW III  01/28/2016   v1.0.2
b__parm        = ABS(c_s_out^2 - v_a_out^2)^2
sq_parm        = SQRT(b__parm + ac_parm)
sl2_fac        = ABS(v_ms_out^2 - sq_parm)
fa2_fac        = ABS(v_ms_out^2 + sq_parm)
;;  Calculate slow speed [km/s]
v_s_out        = SQRT(sl2_fac/2d0)
v_f_out        = SQRT(fa2_fac/2d0)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END


